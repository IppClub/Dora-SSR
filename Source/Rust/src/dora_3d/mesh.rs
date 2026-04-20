use super::types::{Aabb, Vec3};
use super::{next_handle, Dora3DHandle};
use crate::bgfx_rs::bgfx_sys;
use std::collections::HashMap;
use std::mem::MaybeUninit;
use std::sync::{Mutex, OnceLock};

#[repr(C)]
#[derive(Debug, Clone, Copy, Default)]
pub struct Vertex {
    pub position: [f32; 3],
    pub normal: [f32; 3],
    pub tangent: [f32; 4],
    pub uv0: [f32; 2],
    pub color: u32,
    pub joint_indices: [u16; 4],
    pub joint_weights: [f32; 4],
}

#[derive(Debug, Clone)]
pub struct SubMesh {
    pub start_index: u32,
    pub index_count: u32,
    pub material_slot: u32,
}

#[derive(Debug)]
pub struct MeshData {
    pub handle: Dora3DHandle,
    pub vertices: Vec<Vertex>,
    pub indices: Vec<u32>,
    pub sub_meshes: Vec<SubMesh>,
    pub bounds: Aabb,
    pub vertex_layout: bgfx_sys::bgfx_vertex_layout_t,
    pub vertex_buffer: bgfx_sys::bgfx_vertex_buffer_handle_t,
    pub index_buffer: bgfx_sys::bgfx_index_buffer_handle_t,
}

impl Drop for MeshData {
    fn drop(&mut self) {
        unsafe {
            if self.vertex_buffer.idx != u16::MAX {
                bgfx_sys::bgfx_destroy_vertex_buffer(self.vertex_buffer);
            }
            if self.index_buffer.idx != u16::MAX {
                bgfx_sys::bgfx_destroy_index_buffer(self.index_buffer);
            }
        }
    }
}

fn registry() -> &'static Mutex<HashMap<Dora3DHandle, MeshData>> {
    static REGISTRY: OnceLock<Mutex<HashMap<Dora3DHandle, MeshData>>> = OnceLock::new();
    REGISTRY.get_or_init(|| Mutex::new(HashMap::new()))
}

fn create_vertex_layout() -> bgfx_sys::bgfx_vertex_layout_t {
    let mut layout = MaybeUninit::<bgfx_sys::bgfx_vertex_layout_t>::zeroed();
    unsafe {
        let layout_ptr = layout.as_mut_ptr();
        bgfx_sys::bgfx_vertex_layout_begin(layout_ptr, bgfx_sys::bgfx_get_renderer_type());
        bgfx_sys::bgfx_vertex_layout_add(
            layout_ptr,
            bgfx_sys::BGFX_ATTRIB_POSITION as _,
            3,
            bgfx_sys::BGFX_ATTRIB_TYPE_FLOAT as _,
            false,
            false,
        );
        bgfx_sys::bgfx_vertex_layout_add(
            layout_ptr,
            bgfx_sys::BGFX_ATTRIB_NORMAL as _,
            3,
            bgfx_sys::BGFX_ATTRIB_TYPE_FLOAT as _,
            false,
            false,
        );
        bgfx_sys::bgfx_vertex_layout_add(
            layout_ptr,
            bgfx_sys::BGFX_ATTRIB_TANGENT as _,
            4,
            bgfx_sys::BGFX_ATTRIB_TYPE_FLOAT as _,
            false,
            false,
        );
        bgfx_sys::bgfx_vertex_layout_add(
            layout_ptr,
            bgfx_sys::BGFX_ATTRIB_TEXCOORD0 as _,
            2,
            bgfx_sys::BGFX_ATTRIB_TYPE_FLOAT as _,
            false,
            false,
        );
        bgfx_sys::bgfx_vertex_layout_add(
            layout_ptr,
            bgfx_sys::BGFX_ATTRIB_COLOR0 as _,
            4,
            bgfx_sys::BGFX_ATTRIB_TYPE_UINT8 as _,
            true,
            false,
        );
        bgfx_sys::bgfx_vertex_layout_add(
            layout_ptr,
            bgfx_sys::BGFX_ATTRIB_INDICES as _,
            4,
            bgfx_sys::BGFX_ATTRIB_TYPE_INT16 as _,
            false,
            false,
        );
        bgfx_sys::bgfx_vertex_layout_add(
            layout_ptr,
            bgfx_sys::BGFX_ATTRIB_WEIGHT as _,
            4,
            bgfx_sys::BGFX_ATTRIB_TYPE_FLOAT as _,
            false,
            false,
        );
        bgfx_sys::bgfx_vertex_layout_end(layout_ptr);
        layout.assume_init()
    }
}

fn create_vertex_buffer(
    vertices: &[Vertex],
    layout: &bgfx_sys::bgfx_vertex_layout_t,
) -> bgfx_sys::bgfx_vertex_buffer_handle_t {
    unsafe {
        let memory = bgfx_sys::bgfx_copy(
            vertices.as_ptr() as *const _,
            std::mem::size_of_val(vertices) as u32,
        );
        bgfx_sys::bgfx_create_vertex_buffer(memory, layout, bgfx_sys::BGFX_BUFFER_NONE as u16)
    }
}

fn create_index_buffer(indices: &[u32]) -> bgfx_sys::bgfx_index_buffer_handle_t {
    unsafe {
        let memory = bgfx_sys::bgfx_copy(
            indices.as_ptr() as *const _,
            std::mem::size_of_val(indices) as u32,
        );
        bgfx_sys::bgfx_create_index_buffer(memory, bgfx_sys::BGFX_BUFFER_INDEX32 as u16)
    }
}

fn build_bounds(vertices: &[Vertex]) -> Aabb {
    let points: Vec<Vec3> = vertices
        .iter()
        .map(|vertex| Vec3::from_array(vertex.position))
        .collect();
    Aabb::from_points(&points)
}

pub fn create(
    vertices: Vec<Vertex>,
    indices: Vec<u32>,
    sub_meshes: Option<Vec<SubMesh>>,
) -> Dora3DHandle {
    let handle = next_handle();
    let layout = create_vertex_layout();
    let vertex_buffer = create_vertex_buffer(&vertices, &layout);
    let index_buffer = create_index_buffer(&indices);
    let bounds = build_bounds(&vertices);
    let mesh = MeshData {
        handle,
        vertices,
        indices: indices.clone(),
        sub_meshes: sub_meshes.unwrap_or_else(|| {
            vec![SubMesh {
                start_index: 0,
                index_count: indices.len() as u32,
                material_slot: 0,
            }]
        }),
        bounds,
        vertex_layout: layout,
        vertex_buffer,
        index_buffer,
    };
    registry().lock().unwrap().insert(handle, mesh);
    handle
}

pub fn destroy(handle: Dora3DHandle) -> bool {
    registry().lock().unwrap().remove(&handle).is_some()
}

pub fn with_mesh<R>(handle: Dora3DHandle, f: impl FnOnce(&MeshData) -> R) -> Option<R> {
    let meshes = registry().lock().unwrap();
    meshes.get(&handle).map(f)
}

pub fn bounds(handle: Dora3DHandle) -> Option<Aabb> {
    with_mesh(handle, |mesh| mesh.bounds)
}

pub fn clear_registry() {
    registry().lock().unwrap().clear();
}
