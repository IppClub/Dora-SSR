use super::texture;
use super::types::{mat4_to_bgfx_array, Mat4, Vec3, Vec4};
use super::{next_handle, Dora3DHandle};
use crate::bgfx_rs::bgfx_sys;
use crate::print_error;
use std::collections::{BTreeMap, HashMap};
use std::ffi::CString;
use std::fs;
use std::path::Path;
use std::sync::{Mutex, OnceLock};

const DEFAULT_BASE_COLOR_SLOT: &str = "s_baseColor";
const DEFAULT_METALLIC_ROUGHNESS_SLOT: &str = "s_metallicRoughness";
const DEFAULT_NORMAL_SLOT: &str = "s_normal";
const DEFAULT_EMISSIVE_SLOT: &str = "s_emissive";
const DEFAULT_OCCLUSION_SLOT: &str = "s_occlusion";

#[derive(Debug, Clone, Copy)]
pub enum MaterialType {
    Unlit,
    Lambert,
    PbrMetallicRoughness,
    Custom,
}

#[derive(Debug, Clone, Copy)]
pub struct TextureParam {
    pub texture: Dora3DHandle,
    pub stage: u8,
    pub flags: u32,
}

#[derive(Debug, Clone)]
pub enum ShaderParam {
    Float(f32),
    Vec3(Vec3),
    Vec4(Vec4),
    Mat4(Mat4),
    Texture(TextureParam),
}

#[derive(Debug)]
pub struct MaterialData {
    pub handle: Dora3DHandle,
    pub material_type: MaterialType,
    pub transparent: bool,
    pub double_sided: bool,
    pub depth_test: bool,
    pub depth_write: bool,
    pub base_color: Vec4,
    pub emissive_factor: Vec3,
    pub metallic: f32,
    pub roughness: f32,
    pub normal_scale: f32,
    pub occlusion_strength: f32,
    pub alpha_cutoff: f32,
    pub shader_params: BTreeMap<String, ShaderParam>,
    pub uniforms: HashMap<String, bgfx_sys::bgfx_uniform_handle_t>,
    pub program: Option<bgfx_sys::bgfx_program_handle_t>,
}

impl Drop for MaterialData {
    fn drop(&mut self) {
        unsafe {
            for uniform in self.uniforms.values() {
                if uniform.idx != u16::MAX {
                    bgfx_sys::bgfx_destroy_uniform(*uniform);
                }
            }
            if let Some(program) = self.program {
                if program.idx != u16::MAX {
                    bgfx_sys::bgfx_destroy_program(program);
                }
            }
        }
    }
}

impl MaterialData {
    fn new(handle: Dora3DHandle) -> Self {
        let mut material = Self {
            handle,
            material_type: MaterialType::PbrMetallicRoughness,
            transparent: false,
            double_sided: false,
            depth_test: true,
            depth_write: true,
            base_color: Vec4::ONE,
            emissive_factor: Vec3::ZERO,
            metallic: 1.0,
            roughness: 1.0,
            normal_scale: 1.0,
            occlusion_strength: 1.0,
            alpha_cutoff: 0.5,
            shader_params: BTreeMap::new(),
            uniforms: HashMap::new(),
            program: None,
        };
        material.seed_default_params();
        material
    }

    fn seed_default_params(&mut self) {
        self.shader_params.insert(
            "u_baseColor".to_owned(),
            ShaderParam::Vec4(self.base_color),
        );
        self.shader_params.insert(
            "u_emissiveFactor".to_owned(),
            ShaderParam::Vec3(self.emissive_factor),
        );
        self.shader_params.insert(
            "u_metallicRoughness".to_owned(),
            ShaderParam::Vec4(Vec4::new(
                self.metallic,
                self.roughness,
                self.normal_scale,
                self.occlusion_strength,
            )),
        );
        self.shader_params.insert(
            "u_alphaCutoff".to_owned(),
            ShaderParam::Float(self.alpha_cutoff),
        );
    }

    fn state_flags(&self) -> u64 {
        let mut state = bgfx_sys::BGFX_STATE_WRITE_RGB as u64
            | bgfx_sys::BGFX_STATE_WRITE_A as u64
            | bgfx_sys::BGFX_STATE_MSAA as u64;
        if self.depth_test {
            state |= bgfx_sys::BGFX_STATE_DEPTH_TEST_LESS as u64;
        }
        if self.depth_write {
            state |= bgfx_sys::BGFX_STATE_WRITE_Z as u64;
        }
        if self.transparent {
            state |= blend_func(
                bgfx_sys::BGFX_STATE_BLEND_SRC_ALPHA as u64,
                bgfx_sys::BGFX_STATE_BLEND_INV_SRC_ALPHA as u64,
            );
        }
        if !self.double_sided {
            state |= bgfx_sys::BGFX_STATE_CULL_CW as u64;
        }
        state
    }
}

fn registry() -> &'static Mutex<HashMap<Dora3DHandle, MaterialData>> {
    static REGISTRY: OnceLock<Mutex<HashMap<Dora3DHandle, MaterialData>>> = OnceLock::new();
    REGISTRY.get_or_init(|| Mutex::new(HashMap::new()))
}

fn blend_func(src: u64, dst: u64) -> u64 {
    let shift = bgfx_sys::BGFX_STATE_BLEND_SHIFT as u64;
    let src_value = src >> shift;
    let dst_value = dst >> shift;
    ((src_value | (dst_value << 4)) | ((src_value | (dst_value << 4)) << 8)) << shift
}

fn invalid_uniform() -> bgfx_sys::bgfx_uniform_handle_t {
    bgfx_sys::bgfx_uniform_handle_t { idx: u16::MAX }
}

fn ensure_uniform(
    material: &mut MaterialData,
    name: &str,
    uniform_type: bgfx_sys::bgfx_uniform_type_t,
) -> Option<bgfx_sys::bgfx_uniform_handle_t> {
    if let Some(handle) = material.uniforms.get(name) {
        return Some(*handle);
    }
    let c_name = CString::new(name).ok()?;
    let uniform = unsafe { bgfx_sys::bgfx_create_uniform(c_name.as_ptr(), uniform_type, 1) };
    material.uniforms.insert(name.to_owned(), uniform);
    Some(uniform)
}

fn load_shader(path: &Path) -> Option<bgfx_sys::bgfx_shader_handle_t> {
    let bytes = fs::read(path).ok()?;
    unsafe {
        let memory = bgfx_sys::bgfx_copy(bytes.as_ptr() as *const _, bytes.len() as u32);
        Some(bgfx_sys::bgfx_create_shader(memory))
    }
}

pub fn create() -> Dora3DHandle {
    let handle = next_handle();
    registry()
        .lock()
        .unwrap()
        .insert(handle, MaterialData::new(handle));
    handle
}

pub fn destroy(handle: Dora3DHandle) -> bool {
    registry().lock().unwrap().remove(&handle).is_some()
}

pub fn set_type(handle: Dora3DHandle, material_type: MaterialType) -> bool {
    let mut materials = registry().lock().unwrap();
    let Some(material) = materials.get_mut(&handle) else {
        return false;
    };
    material.material_type = material_type;
    true
}

pub fn set_base_color(handle: Dora3DHandle, base_color: Vec4) -> bool {
    let mut materials = registry().lock().unwrap();
    let Some(material) = materials.get_mut(&handle) else {
        return false;
    };
    material.base_color = base_color;
    material
        .shader_params
        .insert("u_baseColor".to_owned(), ShaderParam::Vec4(base_color));
    true
}

pub fn set_emissive_factor(handle: Dora3DHandle, emissive_factor: Vec3) -> bool {
    let mut materials = registry().lock().unwrap();
    let Some(material) = materials.get_mut(&handle) else {
        return false;
    };
    material.emissive_factor = emissive_factor;
    material.shader_params.insert(
        "u_emissiveFactor".to_owned(),
        ShaderParam::Vec3(emissive_factor),
    );
    true
}

pub fn set_pbr(
    handle: Dora3DHandle,
    metallic: f32,
    roughness: f32,
    alpha_cutoff: f32,
) -> bool {
    let mut materials = registry().lock().unwrap();
    let Some(material) = materials.get_mut(&handle) else {
        return false;
    };
    material.metallic = metallic;
    material.roughness = roughness;
    material.alpha_cutoff = alpha_cutoff;
    material.shader_params.insert(
        "u_metallicRoughness".to_owned(),
        ShaderParam::Vec4(Vec4::new(
            material.metallic,
            material.roughness,
            material.normal_scale,
            material.occlusion_strength,
        )),
    );
    material.shader_params.insert(
        "u_alphaCutoff".to_owned(),
        ShaderParam::Float(alpha_cutoff),
    );
    true
}

pub fn set_normal_scale(handle: Dora3DHandle, normal_scale: f32) -> bool {
    let mut materials = registry().lock().unwrap();
    let Some(material) = materials.get_mut(&handle) else {
        return false;
    };
    material.normal_scale = normal_scale;
    material.shader_params.insert(
        "u_metallicRoughness".to_owned(),
        ShaderParam::Vec4(Vec4::new(
            material.metallic,
            material.roughness,
            material.normal_scale,
            material.occlusion_strength,
        )),
    );
    true
}

pub fn set_occlusion_strength(handle: Dora3DHandle, occlusion_strength: f32) -> bool {
    let mut materials = registry().lock().unwrap();
    let Some(material) = materials.get_mut(&handle) else {
        return false;
    };
    material.occlusion_strength = occlusion_strength;
    material.shader_params.insert(
        "u_metallicRoughness".to_owned(),
        ShaderParam::Vec4(Vec4::new(
            material.metallic,
            material.roughness,
            material.normal_scale,
            material.occlusion_strength,
        )),
    );
    true
}

pub fn set_flags(
    handle: Dora3DHandle,
    transparent: bool,
    double_sided: bool,
    depth_test: bool,
    depth_write: bool,
) -> bool {
    let mut materials = registry().lock().unwrap();
    let Some(material) = materials.get_mut(&handle) else {
        return false;
    };
    material.transparent = transparent;
    material.double_sided = double_sided;
    material.depth_test = depth_test;
    material.depth_write = depth_write;
    true
}

pub fn set_float(handle: Dora3DHandle, name: &str, value: f32) -> bool {
    let mut materials = registry().lock().unwrap();
    let Some(material) = materials.get_mut(&handle) else {
        return false;
    };
    let _ = ensure_uniform(material, name, bgfx_sys::BGFX_UNIFORM_TYPE_VEC4);
    material
        .shader_params
        .insert(name.to_owned(), ShaderParam::Float(value));
    true
}

pub fn set_vec3(handle: Dora3DHandle, name: &str, value: Vec3) -> bool {
    let mut materials = registry().lock().unwrap();
    let Some(material) = materials.get_mut(&handle) else {
        return false;
    };
    let _ = ensure_uniform(material, name, bgfx_sys::BGFX_UNIFORM_TYPE_VEC4);
    material
        .shader_params
        .insert(name.to_owned(), ShaderParam::Vec3(value));
    true
}

pub fn set_vec4(handle: Dora3DHandle, name: &str, value: Vec4) -> bool {
    let mut materials = registry().lock().unwrap();
    let Some(material) = materials.get_mut(&handle) else {
        return false;
    };
    let _ = ensure_uniform(material, name, bgfx_sys::BGFX_UNIFORM_TYPE_VEC4);
    material
        .shader_params
        .insert(name.to_owned(), ShaderParam::Vec4(value));
    true
}

pub fn set_mat4(handle: Dora3DHandle, name: &str, value: Mat4) -> bool {
    let mut materials = registry().lock().unwrap();
    let Some(material) = materials.get_mut(&handle) else {
        return false;
    };
    let _ = ensure_uniform(material, name, bgfx_sys::BGFX_UNIFORM_TYPE_MAT4);
    material
        .shader_params
        .insert(name.to_owned(), ShaderParam::Mat4(value));
    true
}

pub fn set_texture(handle: Dora3DHandle, name: &str, texture_handle: Dora3DHandle, stage: u8) -> bool {
    let mut materials = registry().lock().unwrap();
    let Some(material) = materials.get_mut(&handle) else {
        return false;
    };
    let _ = ensure_uniform(material, name, bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER);
    material.shader_params.insert(
        name.to_owned(),
        ShaderParam::Texture(TextureParam {
            texture: texture_handle,
            stage,
            flags: u32::MAX,
        }),
    );
    true
}

pub fn set_program_from_files(
    handle: Dora3DHandle,
    vertex_shader_path: &str,
    fragment_shader_path: &str,
) -> bool {
    let vertex_shader = match load_shader(Path::new(vertex_shader_path)) {
        Some(shader) => shader,
        None => return false,
    };
    let fragment_shader = match load_shader(Path::new(fragment_shader_path)) {
        Some(shader) => shader,
        None => {
            unsafe {
                bgfx_sys::bgfx_destroy_shader(vertex_shader);
            }
            return false;
        }
    };
    let program = unsafe { bgfx_sys::bgfx_create_program(vertex_shader, fragment_shader, true) };
    let mut materials = registry().lock().unwrap();
    let Some(material) = materials.get_mut(&handle) else {
        unsafe {
            bgfx_sys::bgfx_destroy_program(program);
        }
        return false;
    };
    if let Some(old_program) = material.program.replace(program) {
        unsafe {
            if old_program.idx != u16::MAX {
                bgfx_sys::bgfx_destroy_program(old_program);
            }
        }
    }
    true
}

pub fn ensure_default_pbr_material(handle: Dora3DHandle) -> bool {
    let mut materials = registry().lock().unwrap();
    let Some(material) = materials.get_mut(&handle) else {
        return false;
    };
    material.material_type = MaterialType::PbrMetallicRoughness;
    material.seed_default_params();
    let _ = ensure_uniform(material, "u_baseColor", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4);
    let _ = ensure_uniform(
        material,
        "u_emissiveFactor",
        bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
    );
    let _ = ensure_uniform(
        material,
        "u_metallicRoughness",
        bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
    );
    let _ = ensure_uniform(material, "u_alphaCutoff", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4);
    for sampler in [
        DEFAULT_BASE_COLOR_SLOT,
        DEFAULT_METALLIC_ROUGHNESS_SLOT,
        DEFAULT_NORMAL_SLOT,
        DEFAULT_EMISSIVE_SLOT,
        DEFAULT_OCCLUSION_SLOT,
    ] {
        let _ = ensure_uniform(material, sampler, bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER);
    }
    true
}

pub fn with_material<R>(handle: Dora3DHandle, f: impl FnOnce(&MaterialData) -> R) -> Option<R> {
    let materials = registry().lock().unwrap();
    materials.get(&handle).map(f)
}

pub fn apply(handle: Dora3DHandle) -> bool {
    let materials = registry().lock().unwrap();
    let Some(material) = materials.get(&handle) else {
        return false;
    };
    unsafe {
        bgfx_sys::bgfx_set_state(material.state_flags(), 0);
        for (name, param) in &material.shader_params {
            let uniform = material.uniforms.get(name).copied().unwrap_or_else(invalid_uniform);
            if uniform.idx == u16::MAX {
                continue;
            }
            match param {
                ShaderParam::Float(value) => {
                    let packed = [*value, 0.0, 0.0, 0.0];
                    bgfx_sys::bgfx_set_uniform(uniform, packed.as_ptr() as *const _, 1);
                }
                ShaderParam::Vec3(value) => {
                    let packed = [value.x, value.y, value.z, 0.0];
                    bgfx_sys::bgfx_set_uniform(uniform, packed.as_ptr() as *const _, 1);
                }
                ShaderParam::Vec4(value) => {
                    let packed = value.to_array();
                    bgfx_sys::bgfx_set_uniform(uniform, packed.as_ptr() as *const _, 1);
                }
                ShaderParam::Mat4(value) => {
                    let packed = mat4_to_bgfx_array(value);
                    bgfx_sys::bgfx_set_uniform(uniform, packed.as_ptr() as *const _, 1);
                }
                ShaderParam::Texture(binding) => {
                    let Some(texture_handle) = texture::texture_handle(binding.texture) else {
                        continue;
                    };
                    bgfx_sys::bgfx_set_texture(binding.stage, uniform, texture_handle, binding.flags);
                }
            }
        }
    }
    true
}

pub fn program(handle: Dora3DHandle) -> Option<bgfx_sys::bgfx_program_handle_t> {
    with_material(handle, |material| material.program).flatten()
}

pub fn is_transparent(handle: Dora3DHandle) -> bool {
    with_material(handle, |material| material.transparent).unwrap_or(false)
}

pub fn clear_registry() {
    registry().lock().unwrap().clear();
}

pub fn default_base_color_slot() -> &'static str {
    DEFAULT_BASE_COLOR_SLOT
}

pub fn default_metallic_roughness_slot() -> &'static str {
    DEFAULT_METALLIC_ROUGHNESS_SLOT
}

pub fn default_normal_slot() -> &'static str {
    DEFAULT_NORMAL_SLOT
}

pub fn default_emissive_slot() -> &'static str {
    DEFAULT_EMISSIVE_SLOT
}

pub fn default_occlusion_slot() -> &'static str {
    DEFAULT_OCCLUSION_SLOT
}

pub fn warn_missing_program(handle: Dora3DHandle) {
    if program(handle).is_none() {
        print_error("Material has no bgfx program yet. Phase 3 still needs engine shader integration.");
    }
}
