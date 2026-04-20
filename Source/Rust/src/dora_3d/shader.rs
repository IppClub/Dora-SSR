use super::material::{self, MaterialType};
use super::mesh;
use super::types::{mat4_to_bgfx_array, Mat4, Vec3};
use super::Dora3DHandle;
use crate::bgfx_rs::bgfx_sys;
use std::ffi::CString;
use std::ptr;
use std::sync::{Mutex, OnceLock};

pub const MAX_JOINTS: usize = 64;

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct FrameUniforms {
    view_proj: [[f32; 4]; 4],
    view_pos: [f32; 4],
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct DrawUniforms {
    model: [[f32; 4]; 4],
    base_color: [f32; 4],
    normal_metallic: [f32; 4],
    emissive: [f32; 4],
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct JointUniforms {
    matrices: [[f32; 4]; 4 * MAX_JOINTS],
}

#[derive(Debug, Clone, Copy)]
pub struct ShaderPrograms {
    pub unlit: bgfx_sys::bgfx_program_handle_t,
    pub lambert: bgfx_sys::bgfx_program_handle_t,
}

#[derive(Debug)]
struct ShaderState {
    programs: ShaderPrograms,
    u_frame: bgfx_sys::bgfx_uniform_handle_t,
    u_draw: bgfx_sys::bgfx_uniform_handle_t,
    u_joints: bgfx_sys::bgfx_uniform_handle_t,
}

#[derive(Debug, Clone, Copy)]
struct ViewState {
    view_id: bgfx_sys::bgfx_view_id_t,
    frame: FrameUniforms,
}

fn invalid_program() -> bgfx_sys::bgfx_program_handle_t {
    bgfx_sys::bgfx_program_handle_t { idx: u16::MAX }
}

fn invalid_uniform() -> bgfx_sys::bgfx_uniform_handle_t {
    bgfx_sys::bgfx_uniform_handle_t { idx: u16::MAX }
}

fn create_uniform(
    name: &str,
    uniform_type: bgfx_sys::bgfx_uniform_type_t,
    count: u16,
) -> bgfx_sys::bgfx_uniform_handle_t {
    let Ok(name) = CString::new(name) else {
        return invalid_uniform();
    };
    unsafe { bgfx_sys::bgfx_create_uniform(name.as_ptr(), uniform_type, count) }
}

fn shader_state() -> &'static ShaderState {
    static SHADER_STATE: OnceLock<ShaderState> = OnceLock::new();
    SHADER_STATE.get_or_init(|| ShaderState {
        programs: ShaderPrograms {
            // TODO: embed compiled shader binaries.
            unlit: invalid_program(),
            // TODO: embed compiled shader binaries.
            lambert: invalid_program(),
        },
        u_frame: create_uniform("u_frame", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4, 5),
        u_draw: create_uniform("u_draw", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4, 7),
        u_joints: create_uniform(
            "u_joints",
            bgfx_sys::BGFX_UNIFORM_TYPE_MAT4,
            MAX_JOINTS as u16,
        ),
    })
}

fn current_view_state() -> &'static Mutex<Option<ViewState>> {
    static CURRENT_VIEW: OnceLock<Mutex<Option<ViewState>>> = OnceLock::new();
    CURRENT_VIEW.get_or_init(|| Mutex::new(None))
}

unsafe fn upload_uniform_bytes(
    uniform: bgfx_sys::bgfx_uniform_handle_t,
    bytes: *const u8,
    size: usize,
    num: u16,
) {
    if uniform.idx == u16::MAX || bytes.is_null() || size == 0 {
        return;
    }
    let memory = bgfx_sys::bgfx_alloc(size as u32);
    if memory.is_null() {
        return;
    }
    ptr::copy_nonoverlapping(bytes, (*memory).data, size);
    bgfx_sys::bgfx_set_uniform(uniform, (*memory).data as *const _, num);
}

fn build_draw_uniforms(material_handle: Dora3DHandle, model_matrix: &Mat4) -> DrawUniforms {
    material::with_material(material_handle, |material| DrawUniforms {
        model: model_matrix.to_cols_array_2d(),
        base_color: material.base_color.to_array(),
        normal_metallic: [
            material.normal_scale,
            material.metallic,
            material.roughness,
            material.occlusion_strength,
        ],
        emissive: [
            material.emissive_factor.x,
            material.emissive_factor.y,
            material.emissive_factor.z,
            1.0,
        ],
    })
    .unwrap_or(DrawUniforms {
        model: model_matrix.to_cols_array_2d(),
        base_color: [1.0, 1.0, 1.0, 1.0],
        normal_metallic: [1.0, 1.0, 1.0, 1.0],
        emissive: [0.0, 0.0, 0.0, 1.0],
    })
}

fn choose_program(
    state: &ShaderState,
    material_handle: Dora3DHandle,
) -> bgfx_sys::bgfx_program_handle_t {
    material::with_material(material_handle, |material| {
        if let Some(program) = material.program {
            if program.idx != u16::MAX {
                return program;
            }
        }
        match material.material_type {
            MaterialType::Unlit => state.programs.unlit,
            MaterialType::Lambert
            | MaterialType::PbrMetallicRoughness
            | MaterialType::Custom => state.programs.lambert,
        }
    })
    .unwrap_or(state.programs.lambert)
}

pub fn ensure_shaders() -> ShaderPrograms {
    shader_state().programs
}

pub fn set_view_transforms(view_id: bgfx_sys::bgfx_view_id_t, view_proj: &Mat4, view_pos: Vec3) {
    let frame = FrameUniforms {
        view_proj: view_proj.to_cols_array_2d(),
        view_pos: [view_pos.x, view_pos.y, view_pos.z, 0.0],
    };
    let identity = Mat4::IDENTITY.to_cols_array();
    let combined = mat4_to_bgfx_array(view_proj);
    unsafe {
        // bgfx needs separate view/proj matrices; for now we provide identity view
        // and use the combined matrix in the projection slot while shaders read u_frame.
        bgfx_sys::bgfx_set_view_transform(view_id, identity.as_ptr() as *const _, combined.as_ptr() as *const _);
    }
    *current_view_state().lock().unwrap() = Some(ViewState { view_id, frame });
}

pub fn submit_mesh(
    mesh_handle: Dora3DHandle,
    material_handle: Dora3DHandle,
    model_matrix: &Mat4,
    view_proj: &Mat4,
    view_pos: Vec3,
    joint_matrices: Option<&[Mat4]>,
) -> bool {
    let _ = ensure_shaders();
    let state = shader_state();
    let view_state = current_view_state()
        .lock()
        .unwrap()
        .as_ref()
        .copied()
        .unwrap_or(ViewState {
            view_id: 0,
            frame: FrameUniforms {
                view_proj: view_proj.to_cols_array_2d(),
                view_pos: [view_pos.x, view_pos.y, view_pos.z, 0.0],
            },
        });
    let draw = build_draw_uniforms(material_handle, model_matrix);
    let program = choose_program(state, material_handle);
    if program.idx == u16::MAX {
        return false;
    }
    mesh::with_mesh(mesh_handle, |mesh_data| unsafe {
        let transform = mat4_to_bgfx_array(model_matrix);
        bgfx_sys::bgfx_set_transform(transform.as_ptr() as *const _, 1);
        upload_uniform_bytes(
            state.u_frame,
            &view_state.frame as *const FrameUniforms as *const u8,
            std::mem::size_of::<FrameUniforms>(),
            5,
        );
        upload_uniform_bytes(
            state.u_draw,
            &draw as *const DrawUniforms as *const u8,
            std::mem::size_of::<DrawUniforms>(),
            7,
        );
        if let Some(joint_matrices) = joint_matrices {
            let mut joints = JointUniforms {
                matrices: [[0.0; 4]; 4 * MAX_JOINTS],
            };
            for (joint_index, matrix) in joint_matrices.iter().take(MAX_JOINTS).enumerate() {
                let rows = matrix.to_cols_array_2d();
                let base = joint_index * 4;
                joints.matrices[base..base + 4].copy_from_slice(&rows);
            }
            upload_uniform_bytes(
                state.u_joints,
                &joints as *const JointUniforms as *const u8,
                std::mem::size_of::<JointUniforms>(),
                MAX_JOINTS as u16,
            );
        }
        bgfx_sys::bgfx_set_vertex_buffer(
            0,
            mesh_data.vertex_buffer,
            0,
            mesh_data.vertices.len() as u32,
        );
        for sub_mesh in &mesh_data.sub_meshes {
            let _ = material::apply(material_handle);
            bgfx_sys::bgfx_set_index_buffer(
                mesh_data.index_buffer,
                sub_mesh.start_index,
                sub_mesh.index_count,
            );
            bgfx_sys::bgfx_submit(
                view_state.view_id,
                program,
                0,
                bgfx_sys::BGFX_DISCARD_ALL as u8,
            );
        }
    })
    .is_some()
}
