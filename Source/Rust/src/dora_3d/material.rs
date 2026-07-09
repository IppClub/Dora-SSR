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
const DEFAULT_CLEARCOAT_SLOT: &str = "s_clearcoat";
const DEFAULT_CLEARCOAT_ROUGHNESS_SLOT: &str = "s_clearcoatRoughness";
const DEFAULT_CLEARCOAT_NORMAL_SLOT: &str = "s_clearcoatNormal";
const DEFAULT_SPECULAR_SLOT: &str = "s_specular";
const DEFAULT_SPECULAR_COLOR_SLOT: &str = "s_specularColor";
const DEFAULT_TRANSMISSION_SLOT: &str = "s_transmission";
const DEFAULT_THICKNESS_SLOT: &str = "s_thickness";
const DEFAULT_THICKNESS_SHEEN_SLOT: &str = "s_thicknessSheen";
const DEFAULT_SHEEN_COLOR_SLOT: &str = "s_sheenColor";
const DEFAULT_SHEEN_ROUGHNESS_SLOT: &str = "s_sheenRoughness";
const DEFAULT_BASE_COLOR_UV: &str = "u_uvBaseColor";
const DEFAULT_BASE_COLOR_UV_OFFSET: &str = "u_uvBaseColorOffset";
const DEFAULT_METALLIC_ROUGHNESS_UV: &str = "u_uvMetallicRoughness";
const DEFAULT_METALLIC_ROUGHNESS_UV_OFFSET: &str = "u_uvMetallicRoughnessOffset";
const DEFAULT_NORMAL_UV: &str = "u_uvNormal";
const DEFAULT_NORMAL_UV_OFFSET: &str = "u_uvNormalOffset";
const DEFAULT_EMISSIVE_UV: &str = "u_uvEmissive";
const DEFAULT_EMISSIVE_UV_OFFSET: &str = "u_uvEmissiveOffset";
const DEFAULT_OCCLUSION_UV: &str = "u_uvOcclusion";
const DEFAULT_OCCLUSION_UV_OFFSET: &str = "u_uvOcclusionOffset";
const DEFAULT_CLEARCOAT_UV: &str = "u_uvClearcoat";
const DEFAULT_CLEARCOAT_UV_OFFSET: &str = "u_uvClearcoatOffset";
const DEFAULT_CLEARCOAT_ROUGHNESS_UV: &str = "u_uvClearcoatRoughness";
const DEFAULT_CLEARCOAT_ROUGHNESS_UV_OFFSET: &str = "u_uvClearcoatRoughnessOffset";
const DEFAULT_CLEARCOAT_NORMAL_UV: &str = "u_uvClearcoatNormal";
const DEFAULT_CLEARCOAT_NORMAL_UV_OFFSET: &str = "u_uvClearcoatNormalOffset";
const DEFAULT_SPECULAR_UV: &str = "u_uvSpecular";
const DEFAULT_SPECULAR_UV_OFFSET: &str = "u_uvSpecularOffset";
const DEFAULT_SPECULAR_COLOR_UV: &str = "u_uvSpecularColor";
const DEFAULT_SPECULAR_COLOR_UV_OFFSET: &str = "u_uvSpecularColorOffset";
const DEFAULT_TRANSMISSION_UV: &str = "u_uvTransmission";
const DEFAULT_TRANSMISSION_UV_OFFSET: &str = "u_uvTransmissionOffset";
const DEFAULT_THICKNESS_UV: &str = "u_uvThickness";
const DEFAULT_THICKNESS_UV_OFFSET: &str = "u_uvThicknessOffset";
const DEFAULT_SHEEN_COLOR_UV: &str = "u_uvSheenColor";
const DEFAULT_SHEEN_COLOR_UV_OFFSET: &str = "u_uvSheenColorOffset";
const DEFAULT_SHEEN_ROUGHNESS_UV: &str = "u_uvSheenRoughness";
const DEFAULT_SHEEN_ROUGHNESS_UV_OFFSET: &str = "u_uvSheenRoughnessOffset";

#[derive(Debug, Clone, Copy)]
pub enum MaterialType {
	Unlit,
	Lambert,
	PbrMetallicRoughness,
	Custom,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AlphaMode {
	Opaque,
	Mask,
	Blend,
}

#[derive(Debug, Clone, Copy)]
pub struct TextureParam {
	pub texture: Dora3DHandle,
	pub bgfx_texture: bgfx_sys::bgfx_texture_handle_t,
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

#[derive(Debug, Clone)]
pub struct AppliedParam {
	pub uniform: bgfx_sys::bgfx_uniform_handle_t,
	pub param: ShaderParam,
}

#[derive(Debug)]
pub struct MaterialData {
	pub handle: Dora3DHandle,
	pub material_type: MaterialType,
	pub alpha_mode: AlphaMode,
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
	pub specular_factor: f32,
	pub specular_color: Vec3,
	pub ior: f32,
	pub clearcoat_factor: f32,
	pub clearcoat_roughness: f32,
	pub clearcoat_normal_scale: f32,
	pub transmission_factor: f32,
	pub thickness_factor: f32,
	pub attenuation_distance: f32,
	pub attenuation_color: Vec3,
	pub sheen_color: Vec3,
	pub sheen_roughness: f32,
	pub anisotropy_strength: f32,
	pub anisotropy_rotation: f32,
	pub anisotropy_texture: bool,
	pub shader_params: BTreeMap<String, ShaderParam>,
	pub applied_params: Vec<AppliedParam>,
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
			alpha_mode: AlphaMode::Opaque,
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
			specular_factor: 1.0,
			specular_color: Vec3::ONE,
			ior: 1.5,
			clearcoat_factor: 0.0,
			clearcoat_roughness: 0.0,
			clearcoat_normal_scale: 1.0,
			transmission_factor: 0.0,
			thickness_factor: 0.0,
			attenuation_distance: 0.0,
			attenuation_color: Vec3::ONE,
			sheen_color: Vec3::ZERO,
			sheen_roughness: 0.0,
			anisotropy_strength: 0.0,
			anisotropy_rotation: 0.0,
			anisotropy_texture: false,
			shader_params: BTreeMap::new(),
			applied_params: Vec::new(),
			uniforms: HashMap::new(),
			program: None,
		};
		material.seed_default_params();
		material
	}

	fn seed_default_params(&mut self) {
		set_shader_param(
			self,
			"u_baseColor",
			bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
			ShaderParam::Vec4(self.base_color),
		);
		set_shader_param(
			self,
			"u_emissiveFactor",
			bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
			ShaderParam::Vec3(self.emissive_factor),
		);
		set_shader_param(
			self,
			"u_metallicRoughness",
			bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
			ShaderParam::Vec4(Vec4::new(
				self.metallic,
				self.roughness,
				self.normal_scale,
				self.occlusion_strength,
			)),
		);
		set_shader_param(
			self,
			"u_alphaMode",
			bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
			ShaderParam::Vec4(Vec4::new(
				self.alpha_mode_value(),
				self.alpha_cutoff,
				0.0,
				0.0,
			)),
		);
		set_shader_param(
			self,
			"u_materialExt",
			bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
			ShaderParam::Vec4(Vec4::new(
				self.specular_factor,
				self.ior,
				self.unlit_value(),
				0.0,
			)),
		);
		set_shader_param(
			self,
			"u_specularColor",
			bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
			ShaderParam::Vec3(self.specular_color),
		);
		set_shader_param(
			self,
			"u_clearcoat",
			bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
			ShaderParam::Vec4(Vec4::new(
				self.clearcoat_factor,
				self.clearcoat_roughness,
				self.clearcoat_normal_scale,
				0.0,
			)),
		);
		set_shader_param(
			self,
			"u_transmission",
			bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
			ShaderParam::Vec4(Vec4::new(self.transmission_factor, 0.0, 0.0, 0.0)),
		);
		set_shader_param(
			self,
			"u_volume",
			bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
			ShaderParam::Vec4(Vec4::new(
				self.thickness_factor,
				self.attenuation_distance,
				0.0,
				0.0,
			)),
		);
		set_shader_param(
			self,
			"u_attenuationColor",
			bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
			ShaderParam::Vec3(self.attenuation_color),
		);
		set_shader_param(
			self,
			"u_sheen",
			bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
			ShaderParam::Vec4(Vec4::new(
				self.sheen_color.x,
				self.sheen_color.y,
				self.sheen_color.z,
				self.sheen_roughness,
			)),
		);
		set_shader_param(
			self,
			"u_anisotropy",
			bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
			ShaderParam::Vec4(Vec4::new(
				self.anisotropy_strength,
				self.anisotropy_rotation.cos(),
				self.anisotropy_rotation.sin(),
				if self.anisotropy_texture { 1.0 } else { 0.0 },
			)),
		);
		for (transform_name, offset_name) in DEFAULT_UV_TRANSFORMS {
			set_shader_param(
				self,
				transform_name,
				bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
				ShaderParam::Vec4(Vec4::new(1.0, 0.0, 0.0, 1.0)),
			);
			set_shader_param(
				self,
				offset_name,
				bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
				ShaderParam::Vec4(Vec4::ZERO),
			);
		}
	}

	fn alpha_mode_value(&self) -> f32 {
		match self.alpha_mode {
			AlphaMode::Opaque => 0.0,
			AlphaMode::Mask => 1.0,
			AlphaMode::Blend => 2.0,
		}
	}

	fn unlit_value(&self) -> f32 {
		if matches!(self.material_type, MaterialType::Unlit) {
			1.0
		} else {
			0.0
		}
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

fn set_shader_param(
	material: &mut MaterialData,
	name: &str,
	uniform_type: bgfx_sys::bgfx_uniform_type_t,
	param: ShaderParam,
) -> bool {
	let Some(uniform) = ensure_uniform(material, name, uniform_type) else {
		return false;
	};
	material
		.shader_params
		.insert(name.to_owned(), param.clone());
	if let Some(applied) = material
		.applied_params
		.iter_mut()
		.find(|applied| applied.uniform.idx == uniform.idx)
	{
		applied.param = param;
	} else {
		material
			.applied_params
			.push(AppliedParam { uniform, param });
	}
	true
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
	set_shader_param(
		material,
		"u_materialExt",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec4(Vec4::new(
			material.specular_factor,
			material.ior,
			material.unlit_value(),
			0.0,
		)),
	);
	true
}

pub fn set_base_color(handle: Dora3DHandle, base_color: Vec4) -> bool {
	let mut materials = registry().lock().unwrap();
	let Some(material) = materials.get_mut(&handle) else {
		return false;
	};
	material.base_color = base_color;
	set_shader_param(
		material,
		"u_baseColor",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec4(base_color),
	);
	true
}

pub fn set_emissive_factor(handle: Dora3DHandle, emissive_factor: Vec3) -> bool {
	let mut materials = registry().lock().unwrap();
	let Some(material) = materials.get_mut(&handle) else {
		return false;
	};
	material.emissive_factor = emissive_factor;
	set_shader_param(
		material,
		"u_emissiveFactor",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec3(emissive_factor),
	);
	true
}

pub fn set_pbr(handle: Dora3DHandle, metallic: f32, roughness: f32, alpha_cutoff: f32) -> bool {
	let mut materials = registry().lock().unwrap();
	let Some(material) = materials.get_mut(&handle) else {
		return false;
	};
	material.metallic = metallic;
	material.roughness = roughness;
	material.alpha_cutoff = alpha_cutoff;
	set_shader_param(
		material,
		"u_metallicRoughness",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec4(Vec4::new(
			material.metallic,
			material.roughness,
			material.normal_scale,
			material.occlusion_strength,
		)),
	);
	set_shader_param(
		material,
		"u_alphaMode",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec4(Vec4::new(
			material.alpha_mode_value(),
			alpha_cutoff,
			0.0,
			0.0,
		)),
	);
	true
}

pub fn set_alpha_mode(handle: Dora3DHandle, alpha_mode: AlphaMode, alpha_cutoff: f32) -> bool {
	let mut materials = registry().lock().unwrap();
	let Some(material) = materials.get_mut(&handle) else {
		return false;
	};
	material.alpha_mode = alpha_mode;
	material.transparent = alpha_mode == AlphaMode::Blend;
	material.depth_write = alpha_mode != AlphaMode::Blend;
	material.alpha_cutoff = alpha_cutoff;
	set_shader_param(
		material,
		"u_alphaMode",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec4(Vec4::new(
			material.alpha_mode_value(),
			material.alpha_cutoff,
			0.0,
			0.0,
		)),
	);
	true
}

pub fn set_normal_scale(handle: Dora3DHandle, normal_scale: f32) -> bool {
	let mut materials = registry().lock().unwrap();
	let Some(material) = materials.get_mut(&handle) else {
		return false;
	};
	material.normal_scale = normal_scale;
	set_shader_param(
		material,
		"u_metallicRoughness",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
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
	set_shader_param(
		material,
		"u_metallicRoughness",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec4(Vec4::new(
			material.metallic,
			material.roughness,
			material.normal_scale,
			material.occlusion_strength,
		)),
	);
	true
}

pub fn set_material_ext(
	handle: Dora3DHandle,
	specular_factor: f32,
	specular_color: Vec3,
	ior: f32,
) -> bool {
	let mut materials = registry().lock().unwrap();
	let Some(material) = materials.get_mut(&handle) else {
		return false;
	};
	material.specular_factor = specular_factor;
	material.specular_color = specular_color;
	material.ior = ior;
	set_shader_param(
		material,
		"u_materialExt",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec4(Vec4::new(
			material.specular_factor,
			material.ior,
			material.unlit_value(),
			0.0,
		)),
	);
	set_shader_param(
		material,
		"u_specularColor",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec3(material.specular_color),
	);
	true
}

pub fn set_clearcoat(handle: Dora3DHandle, factor: f32, roughness: f32, normal_scale: f32) -> bool {
	let mut materials = registry().lock().unwrap();
	let Some(material) = materials.get_mut(&handle) else {
		return false;
	};
	material.clearcoat_factor = factor;
	material.clearcoat_roughness = roughness;
	material.clearcoat_normal_scale = normal_scale;
	set_shader_param(
		material,
		"u_clearcoat",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec4(Vec4::new(
			material.clearcoat_factor,
			material.clearcoat_roughness,
			material.clearcoat_normal_scale,
			0.0,
		)),
	);
	true
}

pub fn set_transmission(handle: Dora3DHandle, factor: f32) -> bool {
	let mut materials = registry().lock().unwrap();
	let Some(material) = materials.get_mut(&handle) else {
		return false;
	};
	material.transmission_factor = factor.clamp(0.0, 1.0);
	if material.transmission_factor > 0.0 {
		material.transparent = true;
		material.depth_write = false;
	}
	set_shader_param(
		material,
		"u_transmission",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec4(Vec4::new(material.transmission_factor, 0.0, 0.0, 0.0)),
	);
	true
}

pub fn set_volume(
	handle: Dora3DHandle,
	thickness_factor: f32,
	attenuation_distance: f32,
	attenuation_color: Vec3,
) -> bool {
	let mut materials = registry().lock().unwrap();
	let Some(material) = materials.get_mut(&handle) else {
		return false;
	};
	material.thickness_factor = thickness_factor.max(0.0);
	material.attenuation_distance =
		if attenuation_distance.is_finite() && attenuation_distance > 0.0 {
			attenuation_distance
		} else {
			0.0
		};
	material.attenuation_color = attenuation_color.clamp(Vec3::ZERO, Vec3::ONE);
	if material.thickness_factor > 0.0 {
		material.transparent = true;
		material.depth_write = false;
	}
	set_shader_param(
		material,
		"u_volume",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec4(Vec4::new(
			material.thickness_factor,
			material.attenuation_distance,
			0.0,
			0.0,
		)),
	);
	set_shader_param(
		material,
		"u_attenuationColor",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec3(material.attenuation_color),
	);
	true
}

pub fn set_sheen(handle: Dora3DHandle, color: Vec3, roughness: f32) -> bool {
	let mut materials = registry().lock().unwrap();
	let Some(material) = materials.get_mut(&handle) else {
		return false;
	};
	material.sheen_color = color.clamp(Vec3::ZERO, Vec3::ONE);
	material.sheen_roughness = roughness.clamp(0.0, 1.0);
	set_shader_param(
		material,
		"u_sheen",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec4(Vec4::new(
			material.sheen_color.x,
			material.sheen_color.y,
			material.sheen_color.z,
			material.sheen_roughness,
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
	set_shader_param(
		material,
		name,
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Float(value),
	)
}

pub fn set_vec3(handle: Dora3DHandle, name: &str, value: Vec3) -> bool {
	let mut materials = registry().lock().unwrap();
	let Some(material) = materials.get_mut(&handle) else {
		return false;
	};
	set_shader_param(
		material,
		name,
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec3(value),
	)
}

pub fn set_vec4(handle: Dora3DHandle, name: &str, value: Vec4) -> bool {
	let mut materials = registry().lock().unwrap();
	let Some(material) = materials.get_mut(&handle) else {
		return false;
	};
	set_shader_param(
		material,
		name,
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec4(value),
	)
}

pub fn set_mat4(handle: Dora3DHandle, name: &str, value: Mat4) -> bool {
	let mut materials = registry().lock().unwrap();
	let Some(material) = materials.get_mut(&handle) else {
		return false;
	};
	set_shader_param(
		material,
		name,
		bgfx_sys::BGFX_UNIFORM_TYPE_MAT4,
		ShaderParam::Mat4(value),
	)
}

pub fn set_anisotropy(handle: Dora3DHandle, strength: f32, rotation: f32) -> bool {
	let mut materials = registry().lock().unwrap();
	let Some(material) = materials.get_mut(&handle) else {
		return false;
	};
	material.anisotropy_strength = strength.clamp(0.0, 1.0);
	material.anisotropy_rotation = rotation;
	set_shader_param(
		material,
		"u_anisotropy",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec4(Vec4::new(
			material.anisotropy_strength,
			material.anisotropy_rotation.cos(),
			material.anisotropy_rotation.sin(),
			if material.anisotropy_texture {
				1.0
			} else {
				0.0
			},
		)),
	)
}

pub fn set_anisotropy_texture(handle: Dora3DHandle, enabled: bool) -> bool {
	let mut materials = registry().lock().unwrap();
	let Some(material) = materials.get_mut(&handle) else {
		return false;
	};
	material.anisotropy_texture = enabled;
	set_shader_param(
		material,
		"u_anisotropy",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec4(Vec4::new(
			material.anisotropy_strength,
			material.anisotropy_rotation.cos(),
			material.anisotropy_rotation.sin(),
			if material.anisotropy_texture {
				1.0
			} else {
				0.0
			},
		)),
	)
}

pub fn set_texture(
	handle: Dora3DHandle,
	name: &str,
	texture_handle: Dora3DHandle,
	stage: u8,
) -> bool {
	set_texture_with_flags(handle, name, texture_handle, stage, u32::MAX)
}

pub fn set_texture_with_flags(
	handle: Dora3DHandle,
	name: &str,
	texture_handle: Dora3DHandle,
	stage: u8,
	flags: u32,
) -> bool {
	let mut materials = registry().lock().unwrap();
	let Some(material) = materials.get_mut(&handle) else {
		return false;
	};
	let bgfx_texture =
		texture::texture_handle(texture_handle).unwrap_or_else(texture::invalid_handle);
	set_shader_param(
		material,
		name,
		bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER,
		ShaderParam::Texture(TextureParam {
			texture: texture_handle,
			bgfx_texture,
			stage,
			flags,
		}),
	)
}

pub fn set_uv_transform(
	handle: Dora3DHandle,
	transform_name: &str,
	offset_name: &str,
	transform: Vec4,
	offset: Vec4,
) -> bool {
	let mut materials = registry().lock().unwrap();
	let Some(material) = materials.get_mut(&handle) else {
		return false;
	};
	set_shader_param(
		material,
		transform_name,
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec4(transform),
	) && set_shader_param(
		material,
		offset_name,
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
		ShaderParam::Vec4(offset),
	)
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
	let _ = ensure_uniform(material, "u_alphaMode", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4);
	let _ = ensure_uniform(material, "u_materialExt", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4);
	let _ = ensure_uniform(
		material,
		"u_specularColor",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
	);
	let _ = ensure_uniform(material, "u_clearcoat", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4);
	let _ = ensure_uniform(material, "u_transmission", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4);
	let _ = ensure_uniform(material, "u_volume", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4);
	let _ = ensure_uniform(
		material,
		"u_attenuationColor",
		bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
	);
	let _ = ensure_uniform(material, "u_sheen", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4);
	let _ = ensure_uniform(material, "u_anisotropy", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4);
	for (transform_name, offset_name) in DEFAULT_UV_TRANSFORMS {
		let _ = ensure_uniform(material, transform_name, bgfx_sys::BGFX_UNIFORM_TYPE_VEC4);
		let _ = ensure_uniform(material, offset_name, bgfx_sys::BGFX_UNIFORM_TYPE_VEC4);
	}
	for sampler in [
		DEFAULT_BASE_COLOR_SLOT,
		DEFAULT_METALLIC_ROUGHNESS_SLOT,
		DEFAULT_NORMAL_SLOT,
		DEFAULT_EMISSIVE_SLOT,
		DEFAULT_OCCLUSION_SLOT,
		DEFAULT_CLEARCOAT_SLOT,
		DEFAULT_CLEARCOAT_ROUGHNESS_SLOT,
		DEFAULT_CLEARCOAT_NORMAL_SLOT,
		DEFAULT_SPECULAR_SLOT,
		DEFAULT_SPECULAR_COLOR_SLOT,
		DEFAULT_TRANSMISSION_SLOT,
		DEFAULT_THICKNESS_SLOT,
		DEFAULT_THICKNESS_SHEEN_SLOT,
		DEFAULT_SHEEN_COLOR_SLOT,
		DEFAULT_SHEEN_ROUGHNESS_SLOT,
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
		for applied in &material.applied_params {
			let uniform = applied.uniform;
			if uniform.idx == u16::MAX {
				continue;
			}
			match &applied.param {
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
					bgfx_sys::bgfx_set_texture(
						binding.stage,
						uniform,
						binding.bgfx_texture,
						binding.flags,
					);
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

pub fn default_clearcoat_slot() -> &'static str {
	DEFAULT_CLEARCOAT_SLOT
}

pub fn default_clearcoat_roughness_slot() -> &'static str {
	DEFAULT_CLEARCOAT_ROUGHNESS_SLOT
}

pub fn default_clearcoat_normal_slot() -> &'static str {
	DEFAULT_CLEARCOAT_NORMAL_SLOT
}

pub fn default_specular_slot() -> &'static str {
	DEFAULT_SPECULAR_SLOT
}

pub fn default_specular_color_slot() -> &'static str {
	DEFAULT_SPECULAR_COLOR_SLOT
}

pub fn default_transmission_slot() -> &'static str {
	DEFAULT_TRANSMISSION_SLOT
}

pub fn default_thickness_slot() -> &'static str {
	DEFAULT_THICKNESS_SLOT
}

pub fn default_thickness_sheen_slot() -> &'static str {
	DEFAULT_THICKNESS_SHEEN_SLOT
}

pub fn default_sheen_color_slot() -> &'static str {
	DEFAULT_SHEEN_COLOR_SLOT
}

pub fn default_sheen_roughness_slot() -> &'static str {
	DEFAULT_SHEEN_ROUGHNESS_SLOT
}

const DEFAULT_UV_TRANSFORMS: &[(&str, &str)] = &[
	(DEFAULT_BASE_COLOR_UV, DEFAULT_BASE_COLOR_UV_OFFSET),
	(
		DEFAULT_METALLIC_ROUGHNESS_UV,
		DEFAULT_METALLIC_ROUGHNESS_UV_OFFSET,
	),
	(DEFAULT_NORMAL_UV, DEFAULT_NORMAL_UV_OFFSET),
	(DEFAULT_EMISSIVE_UV, DEFAULT_EMISSIVE_UV_OFFSET),
	(DEFAULT_OCCLUSION_UV, DEFAULT_OCCLUSION_UV_OFFSET),
	(DEFAULT_CLEARCOAT_UV, DEFAULT_CLEARCOAT_UV_OFFSET),
	(
		DEFAULT_CLEARCOAT_ROUGHNESS_UV,
		DEFAULT_CLEARCOAT_ROUGHNESS_UV_OFFSET,
	),
	(
		DEFAULT_CLEARCOAT_NORMAL_UV,
		DEFAULT_CLEARCOAT_NORMAL_UV_OFFSET,
	),
	(DEFAULT_SPECULAR_UV, DEFAULT_SPECULAR_UV_OFFSET),
	(DEFAULT_SPECULAR_COLOR_UV, DEFAULT_SPECULAR_COLOR_UV_OFFSET),
	(DEFAULT_TRANSMISSION_UV, DEFAULT_TRANSMISSION_UV_OFFSET),
	(DEFAULT_THICKNESS_UV, DEFAULT_THICKNESS_UV_OFFSET),
	(DEFAULT_SHEEN_COLOR_UV, DEFAULT_SHEEN_COLOR_UV_OFFSET),
	(
		DEFAULT_SHEEN_ROUGHNESS_UV,
		DEFAULT_SHEEN_ROUGHNESS_UV_OFFSET,
	),
];

pub fn default_base_color_uv_transform() -> (&'static str, &'static str) {
	(DEFAULT_BASE_COLOR_UV, DEFAULT_BASE_COLOR_UV_OFFSET)
}

pub fn default_metallic_roughness_uv_transform() -> (&'static str, &'static str) {
	(
		DEFAULT_METALLIC_ROUGHNESS_UV,
		DEFAULT_METALLIC_ROUGHNESS_UV_OFFSET,
	)
}

pub fn default_normal_uv_transform() -> (&'static str, &'static str) {
	(DEFAULT_NORMAL_UV, DEFAULT_NORMAL_UV_OFFSET)
}

pub fn default_emissive_uv_transform() -> (&'static str, &'static str) {
	(DEFAULT_EMISSIVE_UV, DEFAULT_EMISSIVE_UV_OFFSET)
}

pub fn default_occlusion_uv_transform() -> (&'static str, &'static str) {
	(DEFAULT_OCCLUSION_UV, DEFAULT_OCCLUSION_UV_OFFSET)
}

pub fn default_clearcoat_uv_transform() -> (&'static str, &'static str) {
	(DEFAULT_CLEARCOAT_UV, DEFAULT_CLEARCOAT_UV_OFFSET)
}

pub fn default_clearcoat_roughness_uv_transform() -> (&'static str, &'static str) {
	(
		DEFAULT_CLEARCOAT_ROUGHNESS_UV,
		DEFAULT_CLEARCOAT_ROUGHNESS_UV_OFFSET,
	)
}

pub fn default_clearcoat_normal_uv_transform() -> (&'static str, &'static str) {
	(
		DEFAULT_CLEARCOAT_NORMAL_UV,
		DEFAULT_CLEARCOAT_NORMAL_UV_OFFSET,
	)
}

pub fn default_specular_uv_transform() -> (&'static str, &'static str) {
	(DEFAULT_SPECULAR_UV, DEFAULT_SPECULAR_UV_OFFSET)
}

pub fn default_specular_color_uv_transform() -> (&'static str, &'static str) {
	(DEFAULT_SPECULAR_COLOR_UV, DEFAULT_SPECULAR_COLOR_UV_OFFSET)
}

pub fn default_transmission_uv_transform() -> (&'static str, &'static str) {
	(DEFAULT_TRANSMISSION_UV, DEFAULT_TRANSMISSION_UV_OFFSET)
}

pub fn default_thickness_uv_transform() -> (&'static str, &'static str) {
	(DEFAULT_THICKNESS_UV, DEFAULT_THICKNESS_UV_OFFSET)
}

pub fn default_sheen_color_uv_transform() -> (&'static str, &'static str) {
	(DEFAULT_SHEEN_COLOR_UV, DEFAULT_SHEEN_COLOR_UV_OFFSET)
}

pub fn default_sheen_roughness_uv_transform() -> (&'static str, &'static str) {
	(
		DEFAULT_SHEEN_ROUGHNESS_UV,
		DEFAULT_SHEEN_ROUGHNESS_UV_OFFSET,
	)
}

pub fn warn_missing_program(handle: Dora3DHandle) {
	if program(handle).is_none() {
		print_error(
			"Material has no bgfx program yet. Phase 3 still needs engine shader integration.",
		);
	}
}
