use super::material::{self, MaterialType};
use super::mesh;
use super::texture;
use super::types::{mat4_to_bgfx_array, Mat4, Vec3};
use super::Dora3DHandle;
use crate::bgfx_rs::bgfx_sys;
use crate::Content;
use image::GenericImageView;
use std::collections::HashMap;
use std::f32::consts::PI;
use std::ffi::CString;
use std::os::raw::c_char;
use std::sync::{Mutex, OnceLock};

pub const MAX_JOINTS: usize = 64;
const DEFAULT_IRRADIANCE_SIZE: u16 = 8;
const DEFAULT_PREFILTER_SIZE: u16 = 32;
const DEFAULT_PREFILTER_MIPS: u8 = 5;
const DEFAULT_BRDF_LUT_SIZE: u16 = 64;
const IRRADIANCE_SAMPLE_COUNT: u32 = 64;
const PREFILTER_SAMPLE_COUNT: u32 = 64;
const BRDF_SAMPLE_COUNT: u32 = 128;
#[repr(C)]
#[derive(Debug, Clone, Copy)]
struct JointUniforms {
	matrices: [f32; 16 * MAX_JOINTS],
}

#[derive(Debug, Clone, Copy)]
pub struct ShaderPrograms {
	pub unlit: bgfx_sys::bgfx_program_handle_t,
	pub lambert: bgfx_sys::bgfx_program_handle_t,
	pub sheen_roughness: bgfx_sys::bgfx_program_handle_t,
	pub thickness_sheen: bgfx_sys::bgfx_program_handle_t,
}

#[derive(Debug)]
struct ShaderState {
	programs: ShaderPrograms,
	u_camera_proj: bgfx_sys::bgfx_uniform_handle_t,
	u_model_inst: bgfx_sys::bgfx_uniform_handle_t,
	u_normal_model: bgfx_sys::bgfx_uniform_handle_t,
	u_uv: bgfx_sys::bgfx_uniform_handle_t,
	u_model_color: bgfx_sys::bgfx_uniform_handle_t,
	u_uv_inversed: bgfx_sys::bgfx_uniform_handle_t,
	u_view_pos: bgfx_sys::bgfx_uniform_handle_t,
	u_env_diffuse: bgfx_sys::bgfx_uniform_handle_t,
	u_env_specular: bgfx_sys::bgfx_uniform_handle_t,
	u_pbr_params: bgfx_sys::bgfx_uniform_handle_t,
	u_emissive_scaling: bgfx_sys::bgfx_uniform_handle_t,
	u_soft_particle_param: bgfx_sys::bgfx_uniform_handle_t,
	u_reconstruction_param1: bgfx_sys::bgfx_uniform_handle_t,
	u_reconstruction_param2: bgfx_sys::bgfx_uniform_handle_t,
	u_uv_inversed_back: bgfx_sys::bgfx_uniform_handle_t,
	u_misc_flags: bgfx_sys::bgfx_uniform_handle_t,
	s_base_color: bgfx_sys::bgfx_uniform_handle_t,
	s_metallic_roughness: bgfx_sys::bgfx_uniform_handle_t,
	s_normal: bgfx_sys::bgfx_uniform_handle_t,
	s_emissive: bgfx_sys::bgfx_uniform_handle_t,
	s_occlusion: bgfx_sys::bgfx_uniform_handle_t,
	s_clearcoat: bgfx_sys::bgfx_uniform_handle_t,
	s_clearcoat_roughness: bgfx_sys::bgfx_uniform_handle_t,
	s_clearcoat_normal: bgfx_sys::bgfx_uniform_handle_t,
	s_irradiance: bgfx_sys::bgfx_uniform_handle_t,
	s_prefilter: bgfx_sys::bgfx_uniform_handle_t,
	s_brdf_lut: bgfx_sys::bgfx_uniform_handle_t,
	s_specular: bgfx_sys::bgfx_uniform_handle_t,
	s_specular_color: bgfx_sys::bgfx_uniform_handle_t,
	s_transmission: bgfx_sys::bgfx_uniform_handle_t,
	s_thickness: bgfx_sys::bgfx_uniform_handle_t,
	s_thickness_sheen: bgfx_sys::bgfx_uniform_handle_t,
	s_sheen_color: bgfx_sys::bgfx_uniform_handle_t,
	s_sheen_roughness: bgfx_sys::bgfx_uniform_handle_t,
	u_joints: bgfx_sys::bgfx_uniform_handle_t,
	_white_texture: Dora3DHandle,
	white_texture_bgfx: bgfx_sys::bgfx_texture_handle_t,
	_black_texture: Dora3DHandle,
	black_texture_bgfx: bgfx_sys::bgfx_texture_handle_t,
	_flat_normal_texture: Dora3DHandle,
	flat_normal_texture_bgfx: bgfx_sys::bgfx_texture_handle_t,
	_irradiance_texture: Dora3DHandle,
	irradiance_texture_bgfx: bgfx_sys::bgfx_texture_handle_t,
	_prefilter_texture: Dora3DHandle,
	prefilter_texture_bgfx: bgfx_sys::bgfx_texture_handle_t,
	_brdf_lut_texture: Dora3DHandle,
	brdf_lut_texture_bgfx: bgfx_sys::bgfx_texture_handle_t,
}

#[derive(Debug, Clone, Copy)]
struct ViewState {
	view_id: bgfx_sys::bgfx_view_id_t,
}

#[derive(Debug)]
struct EquirectEnvironment {
	width: u32,
	height: u32,
	pixels: Vec<Vec3>,
}

#[derive(Debug, Clone)]
struct CubeFaceMip {
	side: u8,
	mip: u8,
	size: u16,
	pixels: Vec<[f32; 4]>,
}

#[derive(Debug, Clone)]
struct GeneratedEnvironment {
	irradiance: Vec<CubeFaceMip>,
	prefilter: Vec<CubeFaceMip>,
}

#[derive(Debug, Clone, Copy)]
struct EnvironmentTextures {
	irradiance_texture: bgfx_sys::bgfx_texture_handle_t,
	prefilter_texture: bgfx_sys::bgfx_texture_handle_t,
}

#[derive(Debug, Clone)]
struct EnvironmentSettings {
	diffuse_intensity: f32,
	specular_intensity: f32,
	exposure: f32,
}

impl Default for EnvironmentSettings {
	fn default() -> Self {
		Self {
			diffuse_intensity: 1.0,
			specular_intensity: 1.0,
			exposure: 1.0,
		}
	}
}

#[derive(Debug, Clone)]
struct ViewEnvironment {
	settings: EnvironmentSettings,
	textures: EnvironmentTextures,
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

extern "C" {
	fn dora_create_builtin_shader(name: *const c_char, renderer_type: u32) -> u16;
}

fn create_builtin_shader(name: &str) -> bgfx_sys::bgfx_shader_handle_t {
	let Ok(name) = CString::new(name) else {
		return bgfx_sys::bgfx_shader_handle_t { idx: u16::MAX };
	};
	let renderer = unsafe { bgfx_sys::bgfx_get_renderer_type() };
	let idx = unsafe { dora_create_builtin_shader(name.as_ptr(), renderer as u32) };
	bgfx_sys::bgfx_shader_handle_t { idx }
}

fn create_builtin_program(
	vertex_shader: &str,
	fragment_shader: &str,
) -> bgfx_sys::bgfx_program_handle_t {
	let vertex_shader = create_builtin_shader(vertex_shader);
	if vertex_shader.idx == u16::MAX {
		return invalid_program();
	}
	let fragment_shader = create_builtin_shader(fragment_shader);
	if fragment_shader.idx == u16::MAX {
		unsafe {
			bgfx_sys::bgfx_destroy_shader(vertex_shader);
		}
		return invalid_program();
	}
	unsafe { bgfx_sys::bgfx_create_program(vertex_shader, fragment_shader, true) }
}

fn create_white_texture() -> Dora3DHandle {
	texture::create_rgba8(
		1,
		1,
		&[255, 255, 255, 255],
		bgfx_sys::BGFX_SAMPLER_NONE as u64,
		Some("Dora3D White"),
	)
	.unwrap_or(0)
}

fn create_solid_texture(rgba: [u8; 4], name: &str) -> Dora3DHandle {
	texture::create_rgba8(1, 1, &rgba, bgfx_sys::BGFX_SAMPLER_NONE as u64, Some(name)).unwrap_or(0)
}

fn cube_direction(side: u8, x: u16, y: u16, size: u16) -> Vec3 {
	let s = (2.0 * (x as f32 + 0.5) / size as f32) - 1.0;
	let t = (2.0 * (y as f32 + 0.5) / size as f32) - 1.0;
	match side {
		0 => Vec3::new(1.0, -t, -s),
		1 => Vec3::new(-1.0, -t, s),
		2 => Vec3::new(s, 1.0, t),
		3 => Vec3::new(s, -1.0, -t),
		4 => Vec3::new(s, -t, 1.0),
		_ => Vec3::new(-s, -t, -1.0),
	}
	.normalize_or_zero()
}

fn linear_to_byte(value: f32) -> u8 {
	(value.clamp(0.0, 1.0) * 255.0).round() as u8
}

fn srgb_to_linear_component(value: f32) -> f32 {
	if value <= 0.04045 {
		value / 12.92
	} else {
		((value + 0.055) / 1.055).powf(2.4)
	}
}

fn soft_box(direction: Vec3, center: Vec3, half_width: f32, half_height: f32) -> f32 {
	let forward = center.normalize();
	let up_hint = if forward.y.abs() > 0.95 {
		Vec3::Z
	} else {
		Vec3::Y
	};
	let right = up_hint.cross(forward).normalize_or_zero();
	let up = forward.cross(right).normalize_or_zero();
	let projected = direction / direction.dot(forward).max(0.000_001);
	let x = projected.dot(right);
	let y = projected.dot(up);
	let edge_x = (1.0 - (x.abs() / half_width).powf(4.0)).clamp(0.0, 1.0);
	let edge_y = (1.0 - (y.abs() / half_height).powf(4.0)).clamp(0.0, 1.0);
	edge_x * edge_y
}

fn environment_color(direction: Vec3, roughness: f32) -> Vec3 {
	let sky = Vec3::new(0.55, 0.62, 0.72);
	let horizon = Vec3::new(0.78, 0.74, 0.68);
	let ground = Vec3::new(0.06, 0.055, 0.05);
	let y = direction.y.clamp(-1.0, 1.0);
	let mut color = if y >= 0.0 {
		sky.lerp(horizon, (1.0 - y).powf(2.0) * 0.35)
	} else {
		ground.lerp(horizon * 0.18, (1.0 + y).powf(2.0) * 0.25)
	};
	let sharpness = 1.0 - roughness * 0.65;
	color += Vec3::new(1.0, 0.96, 0.88)
		* soft_box(direction, Vec3::new(0.0, 0.02, 1.0), 0.72, 0.42)
		* 7.5 * sharpness;
	color += Vec3::new(1.0, 0.92, 0.78)
		* soft_box(direction, Vec3::new(-0.45, 0.35, 0.88), 0.18, 0.42)
		* 7.0 * sharpness;
	color += Vec3::new(0.55, 0.72, 1.0)
		* soft_box(direction, Vec3::new(0.62, 0.2, 0.76), 0.12, 0.32)
		* 5.0 * sharpness;
	color += Vec3::new(1.0, 0.96, 0.88)
		* soft_box(direction, Vec3::new(0.0, 0.9, 0.25), 0.55, 0.16)
		* 3.0 * sharpness;
	let sun_dir = Vec3::new(0.28, 0.68, 0.68).normalize();
	let sun = direction
		.dot(sun_dir)
		.max(0.0)
		.powf(256.0 / (1.0 + roughness * 48.0));
	color += Vec3::new(1.0, 0.86, 0.58) * sun * 8.0 * sharpness;
	let gray = Vec3::splat(color.dot(Vec3::new(0.2126, 0.7152, 0.0722)));
	color.lerp(gray, roughness * 0.45)
}

fn sample_environment(direction: Vec3) -> Vec3 {
	environment_color(direction.normalize_or_zero(), 0.0)
}

fn equirect_uv(direction: Vec3) -> (f32, f32) {
	let direction = direction.normalize_or_zero();
	let u = 0.5 + direction.z.atan2(direction.x) / (2.0 * PI);
	let v = 0.5 - direction.y.asin() / PI;
	(u.fract(), v.clamp(0.0, 1.0))
}

fn sample_equirect_environment(environment: &EquirectEnvironment, direction: Vec3) -> Vec3 {
	if environment.width == 0 || environment.height == 0 || environment.pixels.is_empty() {
		return sample_environment(direction);
	}
	let (u, v) = equirect_uv(direction);
	let x = u * environment.width as f32 - 0.5;
	let y = v * environment.height as f32 - 0.5;
	let x0 = x.floor() as i32;
	let y0 = y.floor() as i32;
	let tx = x - x0 as f32;
	let ty = y - y0 as f32;
	let fetch = |x: i32, y: i32| {
		let width = environment.width as i32;
		let height = environment.height as i32;
		let x = x.rem_euclid(width) as u32;
		let y = y.clamp(0, height - 1) as u32;
		environment.pixels[(y * environment.width + x) as usize]
	};
	let c00 = fetch(x0, y0);
	let c10 = fetch(x0 + 1, y0);
	let c01 = fetch(x0, y0 + 1);
	let c11 = fetch(x0 + 1, y0 + 1);
	c00.lerp(c10, tx).lerp(c01.lerp(c11, tx), ty)
}

fn environment_cache() -> &'static Mutex<HashMap<String, EnvironmentTextures>> {
	static CACHE: OnceLock<Mutex<HashMap<String, EnvironmentTextures>>> = OnceLock::new();
	CACHE.get_or_init(|| Mutex::new(HashMap::new()))
}

fn view_environments() -> &'static Mutex<HashMap<bgfx_sys::bgfx_view_id_t, ViewEnvironment>> {
	static ENVIRONMENTS: OnceLock<Mutex<HashMap<bgfx_sys::bgfx_view_id_t, ViewEnvironment>>> =
		OnceLock::new();
	ENVIRONMENTS.get_or_init(|| Mutex::new(HashMap::new()))
}

fn resolve_content_path(path: &str) -> String {
	let full_path = Content::get_full_path(path);
	if full_path.is_empty() {
		path.to_owned()
	} else {
		full_path
	}
}

fn load_equirect_environment(path: &str) -> Option<EquirectEnvironment> {
	let image = image::open(path).ok()?;
	let (width, height) = image.dimensions();
	if width == 0 || height == 0 {
		return None;
	}
	let rgba = image.to_rgba32f();
	let mut pixels = Vec::with_capacity(width as usize * height as usize);
	for pixel in rgba.pixels() {
		pixels.push(Vec3::new(
			srgb_to_linear_component(pixel[0]),
			srgb_to_linear_component(pixel[1]),
			srgb_to_linear_component(pixel[2]),
		));
	}
	Some(EquirectEnvironment {
		width,
		height,
		pixels,
	})
}

pub fn prepare_environment_equirect(path: &str) -> bool {
	environment_textures_for_path(path).is_some()
}

fn environment_textures_for_path(path: &str) -> Option<EnvironmentTextures> {
	let trimmed = path.trim();
	if trimmed.is_empty() {
		let state = shader_state();
		return Some(EnvironmentTextures {
			irradiance_texture: state.irradiance_texture_bgfx,
			prefilter_texture: state.prefilter_texture_bgfx,
		});
	}
	let resolved_path = resolve_content_path(path);
	if let Some(environment) = environment_cache()
		.lock()
		.unwrap()
		.get(&resolved_path)
		.copied()
	{
		return Some(environment);
	}

	let environment = load_equirect_environment(&resolved_path)?;
	let generated = GeneratedEnvironment {
		irradiance: generate_cube_faces(
			DEFAULT_IRRADIANCE_SIZE,
			1,
			|side, x, y, mip_size, _roughness| {
				let direction = cube_direction(side, x, y, mip_size);
				convolve_irradiance_with(direction, |sample_direction| {
					sample_equirect_environment(&environment, sample_direction)
				})
			},
		),
		prefilter: generate_cube_faces(
			DEFAULT_PREFILTER_SIZE,
			DEFAULT_PREFILTER_MIPS,
			|side, x, y, mip_size, roughness| {
				let direction = cube_direction(side, x, y, mip_size);
				prefilter_environment_with(direction, roughness, |sample_direction| {
					sample_equirect_environment(&environment, sample_direction)
				})
			},
		),
	};
	let textures = create_environment_textures(&resolved_path, &generated)?;
	environment_cache()
		.lock()
		.unwrap()
		.insert(resolved_path, textures);
	Some(textures)
}

pub fn set_view_environment(
	view_id: bgfx_sys::bgfx_view_id_t,
	path: &str,
	diffuse: f32,
	specular: f32,
	exposure: f32,
) -> bool {
	let Some(textures) = environment_textures_for_path(path) else {
		return false;
	};
	view_environments().lock().unwrap().insert(
		view_id,
		ViewEnvironment {
			settings: EnvironmentSettings {
				diffuse_intensity: diffuse.max(0.0),
				specular_intensity: specular.max(0.0),
				exposure: exposure.max(0.0),
			},
			textures,
		},
	);
	true
}

fn environment_for_view(view_id: bgfx_sys::bgfx_view_id_t) -> ViewEnvironment {
	let state = shader_state();
	view_environments()
		.lock()
		.unwrap()
		.get(&view_id)
		.cloned()
		.unwrap_or(ViewEnvironment {
			settings: EnvironmentSettings::default(),
			textures: EnvironmentTextures {
				irradiance_texture: state.irradiance_texture_bgfx,
				prefilter_texture: state.prefilter_texture_bgfx,
			},
		})
}

fn tangent_basis(normal: Vec3) -> (Vec3, Vec3) {
	let up = if normal.z.abs() < 0.999 {
		Vec3::Z
	} else {
		Vec3::X
	};
	let tangent = up.cross(normal).normalize_or_zero();
	let bitangent = normal.cross(tangent).normalize_or_zero();
	(tangent, bitangent)
}

fn sample_hemisphere(normal: Vec3, xi: [f32; 2]) -> Vec3 {
	let phi = 2.0 * PI * xi[0];
	let cos_theta = xi[1];
	let sin_theta = (1.0 - cos_theta * cos_theta).max(0.0).sqrt();
	let local = Vec3::new(phi.cos() * sin_theta, phi.sin() * sin_theta, cos_theta);
	let (tangent, bitangent) = tangent_basis(normal);
	(tangent * local.x + bitangent * local.y + normal * local.z).normalize_or_zero()
}

fn convolve_irradiance(normal: Vec3) -> Vec3 {
	convolve_irradiance_with(normal, sample_environment)
}

fn convolve_irradiance_with(normal: Vec3, mut sample: impl FnMut(Vec3) -> Vec3) -> Vec3 {
	let mut irradiance = Vec3::ZERO;
	for index in 0..IRRADIANCE_SAMPLE_COUNT {
		let light = sample_hemisphere(normal, hammersley(index, IRRADIANCE_SAMPLE_COUNT));
		let n_dot_l = normal.dot(light).max(0.0);
		irradiance += sample(light) * n_dot_l;
	}
	irradiance * (2.0 * PI / IRRADIANCE_SAMPLE_COUNT as f32)
}

fn prefilter_environment(reflection: Vec3, roughness: f32) -> Vec3 {
	prefilter_environment_with(reflection, roughness, sample_environment)
}

fn prefilter_environment_with(
	reflection: Vec3,
	roughness: f32,
	mut sample: impl FnMut(Vec3) -> Vec3,
) -> Vec3 {
	let normal = reflection.normalize_or_zero();
	let view = normal;
	let mut color = Vec3::ZERO;
	let mut total_weight = 0.0;
	for index in 0..PREFILTER_SAMPLE_COUNT {
		let half =
			importance_sample_ggx(hammersley(index, PREFILTER_SAMPLE_COUNT), roughness, normal);
		let light = (half * (2.0 * view.dot(half)) - view).normalize_or_zero();
		let n_dot_l = normal.dot(light).max(0.0);
		if n_dot_l > 0.0 {
			color += sample(light) * n_dot_l;
			total_weight += n_dot_l;
		}
	}
	color / total_weight.max(0.000_001)
}

fn update_generated_cube(
	handle: Dora3DHandle,
	size: u16,
	mip_count: u8,
	mut sample: impl FnMut(u8, u16, u16, u16, f32) -> Vec3,
) -> bool {
	let faces = generate_cube_faces(size, mip_count, |side, x, y, mip_size, roughness| {
		sample(side, x, y, mip_size, roughness)
	});
	update_cube_faces(handle, &faces)
}

fn generate_cube_faces(
	size: u16,
	mip_count: u8,
	mut sample: impl FnMut(u8, u16, u16, u16, f32) -> Vec3,
) -> Vec<CubeFaceMip> {
	let mut faces = Vec::new();
	for mip in 0..mip_count {
		let mip_size = (size >> mip).max(1);
		let roughness = if mip_count <= 1 {
			0.85
		} else {
			mip as f32 / (mip_count - 1) as f32
		};
		for side in 0..6 {
			let mut pixels = Vec::with_capacity(mip_size as usize * mip_size as usize);
			for y in 0..mip_size {
				for x in 0..mip_size {
					let color = sample(side, x, y, mip_size, roughness);
					pixels.push([color.x, color.y, color.z, 1.0]);
				}
			}
			faces.push(CubeFaceMip {
				side,
				mip,
				size: mip_size,
				pixels,
			});
		}
	}
	faces
}

fn update_cube_faces(handle: Dora3DHandle, faces: &[CubeFaceMip]) -> bool {
	for face in faces {
		if !texture::update_cube_rgba16f(handle, face.side, face.mip, face.size, &face.pixels) {
			return false;
		}
	}
	true
}

fn update_cube_faces_rgba8(handle: Dora3DHandle, faces: &[CubeFaceMip]) -> bool {
	for face in faces {
		let mut pixels = Vec::with_capacity(face.pixels.len() * 4);
		for pixel in &face.pixels {
			pixels.extend_from_slice(&[
				linear_to_byte(pixel[0]),
				linear_to_byte(pixel[1]),
				linear_to_byte(pixel[2]),
				linear_to_byte(pixel[3]),
			]);
		}
		if !texture::update_cube_rgba8(handle, face.side, face.mip, face.size, &pixels) {
			return false;
		}
	}
	true
}

fn create_environment_cube(
	size: u16,
	mip_count: u8,
	faces: &[CubeFaceMip],
	name: &str,
) -> Option<Dora3DHandle> {
	let flags = bgfx_sys::BGFX_SAMPLER_U_CLAMP as u64
		| bgfx_sys::BGFX_SAMPLER_V_CLAMP as u64
		| bgfx_sys::BGFX_SAMPLER_W_CLAMP as u64;
	if let Some(handle) = texture::create_cube_rgba16f(size, mip_count > 1, flags, Some(name)) {
		if update_cube_faces(handle, faces) {
			return Some(handle);
		}
		let _ = texture::destroy(handle);
	}
	let handle = texture::create_cube_rgba8(size, mip_count > 1, flags, Some(name))?;
	if update_cube_faces_rgba8(handle, faces) {
		Some(handle)
	} else {
		let _ = texture::destroy(handle);
		None
	}
}

fn create_environment_textures(
	label: &str,
	environment: &GeneratedEnvironment,
) -> Option<EnvironmentTextures> {
	let irradiance = create_environment_cube(
		DEFAULT_IRRADIANCE_SIZE,
		1,
		&environment.irradiance,
		&format!("Dora3D Irradiance {label}"),
	)?;
	let Some(prefilter) = create_environment_cube(
		DEFAULT_PREFILTER_SIZE,
		DEFAULT_PREFILTER_MIPS,
		&environment.prefilter,
		&format!("Dora3D Prefilter {label}"),
	) else {
		let _ = texture::destroy(irradiance);
		return None;
	};
	Some(EnvironmentTextures {
		irradiance_texture: texture::texture_handle(irradiance)
			.unwrap_or_else(texture::invalid_handle),
		prefilter_texture: texture::texture_handle(prefilter)
			.unwrap_or_else(texture::invalid_handle),
	})
}

pub fn clear_environment_cache() {
	environment_cache().lock().unwrap().clear();
	view_environments().lock().unwrap().clear();
}

fn create_generated_cube(
	size: u16,
	mip_count: u8,
	name: &str,
	mut sample: impl FnMut(u8, u16, u16, u16, f32) -> Vec3,
) -> Dora3DHandle {
	let flags = bgfx_sys::BGFX_SAMPLER_U_CLAMP as u64
		| bgfx_sys::BGFX_SAMPLER_V_CLAMP as u64
		| bgfx_sys::BGFX_SAMPLER_W_CLAMP as u64;
	if let Some(handle) = texture::create_cube_rgba16f(size, mip_count > 1, flags, Some(name)) {
		let _ = update_generated_cube(handle, size, mip_count, sample);
		return handle;
	}
	let Some(handle) = texture::create_cube_rgba8(size, mip_count > 1, flags, Some(name)) else {
		return 0;
	};
	for mip in 0..mip_count {
		let mip_size = (size >> mip).max(1);
		let roughness = if mip_count <= 1 {
			0.85
		} else {
			mip as f32 / (mip_count - 1) as f32
		};
		for side in 0..6 {
			let mut pixels = Vec::with_capacity(mip_size as usize * mip_size as usize * 4);
			for y in 0..mip_size {
				for x in 0..mip_size {
					let color = sample(side, x, y, mip_size, roughness);
					pixels.extend_from_slice(&[
						linear_to_byte(color.x),
						linear_to_byte(color.y),
						linear_to_byte(color.z),
						255,
					]);
				}
			}
			let _ = texture::update_cube_rgba8(handle, side, mip, mip_size, &pixels);
		}
	}
	handle
}

fn create_irradiance_cube(size: u16, name: &str) -> Dora3DHandle {
	create_generated_cube(size, 1, name, |side, x, y, mip_size, _roughness| {
		convolve_irradiance(cube_direction(side, x, y, mip_size))
	})
}

fn create_prefilter_cube(size: u16, mip_count: u8, name: &str) -> Dora3DHandle {
	create_generated_cube(size, mip_count, name, |side, x, y, mip_size, roughness| {
		prefilter_environment(cube_direction(side, x, y, mip_size), roughness)
	})
}

fn radical_inverse_vdc(mut bits: u32) -> f32 {
	bits = (bits << 16) | (bits >> 16);
	bits = ((bits & 0x5555_5555) << 1) | ((bits & 0xaaaa_aaaa) >> 1);
	bits = ((bits & 0x3333_3333) << 2) | ((bits & 0xcccc_cccc) >> 2);
	bits = ((bits & 0x0f0f_0f0f) << 4) | ((bits & 0xf0f0_f0f0) >> 4);
	bits = ((bits & 0x00ff_00ff) << 8) | ((bits & 0xff00_ff00) >> 8);
	bits as f32 * 2.328_306_4e-10
}

fn hammersley(index: u32, count: u32) -> [f32; 2] {
	[index as f32 / count as f32, radical_inverse_vdc(index)]
}

fn importance_sample_ggx(xi: [f32; 2], roughness: f32, normal: Vec3) -> Vec3 {
	let alpha = roughness * roughness;
	let phi = 2.0 * PI * xi[0];
	let cos_theta = ((1.0 - xi[1]) / (1.0 + (alpha * alpha - 1.0) * xi[1])).sqrt();
	let sin_theta = (1.0 - cos_theta * cos_theta).max(0.0).sqrt();
	let half = Vec3::new(phi.cos() * sin_theta, phi.sin() * sin_theta, cos_theta);
	let up = if normal.z.abs() < 0.999 {
		Vec3::Z
	} else {
		Vec3::X
	};
	let tangent = up.cross(normal).normalize_or_zero();
	let bitangent = normal.cross(tangent);
	(tangent * half.x + bitangent * half.y + normal * half.z).normalize_or_zero()
}

fn geometry_schlick_ggx_ibl(n_dot_v: f32, roughness: f32) -> f32 {
	let alpha = roughness * roughness;
	let k = (alpha * alpha) / 2.0;
	n_dot_v / (n_dot_v * (1.0 - k) + k).max(0.000_001)
}

fn geometry_smith_ibl(n_dot_v: f32, n_dot_l: f32, roughness: f32) -> f32 {
	geometry_schlick_ggx_ibl(n_dot_v, roughness) * geometry_schlick_ggx_ibl(n_dot_l, roughness)
}

fn integrate_brdf(roughness: f32, n_dot_v: f32) -> [f32; 2] {
	let view = Vec3::new((1.0 - n_dot_v * n_dot_v).max(0.0).sqrt(), 0.0, n_dot_v);
	let normal = Vec3::Z;
	let mut scale = 0.0;
	let mut bias = 0.0;
	for index in 0..BRDF_SAMPLE_COUNT {
		let half = importance_sample_ggx(hammersley(index, BRDF_SAMPLE_COUNT), roughness, normal);
		let light = (half * (2.0 * view.dot(half)) - view).normalize_or_zero();
		let n_dot_l = light.z.max(0.0);
		let n_dot_h = half.z.max(0.0);
		let v_dot_h = view.dot(half).max(0.0);
		if n_dot_l > 0.0 {
			let geometry = geometry_smith_ibl(n_dot_v, n_dot_l, roughness);
			let visibility = (geometry * v_dot_h) / (n_dot_h * n_dot_v).max(0.000_001);
			let fresnel = (1.0 - v_dot_h).powi(5);
			scale += (1.0 - fresnel) * visibility;
			bias += fresnel * visibility;
		}
	}
	[
		scale / BRDF_SAMPLE_COUNT as f32,
		bias / BRDF_SAMPLE_COUNT as f32,
	]
}

fn create_brdf_lut(size: u16) -> Dora3DHandle {
	let sampler_flags =
		bgfx_sys::BGFX_SAMPLER_U_CLAMP as u64 | bgfx_sys::BGFX_SAMPLER_V_CLAMP as u64;
	let mut pixels = Vec::with_capacity(size as usize * size as usize);
	for y in 0..size {
		let roughness = (y as f32 + 0.5) / size as f32;
		for x in 0..size {
			let n_dot_v = (x as f32 + 0.5) / size as f32;
			let brdf = integrate_brdf(roughness, n_dot_v);
			pixels.push([brdf[0], brdf[1], 0.0, 1.0]);
		}
	}
	if let Some(handle) =
		texture::create_rgba16f(size, size, &pixels, sampler_flags, Some("Dora3D BRDF LUT"))
	{
		return handle;
	}
	let mut rgba8 = Vec::with_capacity(size as usize * size as usize * 4);
	for pixel in pixels {
		rgba8.extend_from_slice(&[
			linear_to_byte(pixel[0]),
			linear_to_byte(pixel[1]),
			linear_to_byte(pixel[2]),
			linear_to_byte(pixel[3]),
		]);
	}
	texture::create_rgba8(size, size, &rgba8, sampler_flags, Some("Dora3D BRDF LUT")).unwrap_or(0)
}

fn shader_state() -> &'static ShaderState {
	static SHADER_STATE: OnceLock<ShaderState> = OnceLock::new();
	SHADER_STATE.get_or_init(|| {
		let unlit = create_builtin_program("vs_model3d", "fs_model3d");
		let sheen_roughness = create_builtin_program("vs_model3d", "fs_model3d_sheen");
		let thickness_sheen = create_builtin_program("vs_model3d", "fs_model3d_thickness_sheen");
		let white_texture = create_white_texture();
		let black_texture = create_solid_texture([0, 0, 0, 255], "Dora3D Black");
		let flat_normal_texture = create_solid_texture([128, 128, 255, 255], "Dora3D Flat Normal");
		let irradiance_texture =
			create_irradiance_cube(DEFAULT_IRRADIANCE_SIZE, "Dora3D Irradiance");
		let prefilter_texture = create_prefilter_cube(
			DEFAULT_PREFILTER_SIZE,
			DEFAULT_PREFILTER_MIPS,
			"Dora3D Prefilter",
		);
		let brdf_lut_texture = create_brdf_lut(DEFAULT_BRDF_LUT_SIZE);
		ShaderState {
			programs: ShaderPrograms {
				unlit,
				lambert: unlit,
				sheen_roughness,
				thickness_sheen,
			},
			u_camera_proj: create_uniform("u_mCameraProj", bgfx_sys::BGFX_UNIFORM_TYPE_MAT4, 1),
			u_model_inst: create_uniform("u_mModel_Inst", bgfx_sys::BGFX_UNIFORM_TYPE_MAT4, 40),
			u_normal_model: create_uniform("u_mNormal", bgfx_sys::BGFX_UNIFORM_TYPE_MAT4, 40),
			u_uv: create_uniform("u_fUV", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4, 40),
			u_model_color: create_uniform("u_fModelColor", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4, 40),
			u_uv_inversed: create_uniform("u_mUVInversed", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4, 1),
			u_view_pos: create_uniform("u_viewPos", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4, 1),
			u_env_diffuse: create_uniform("u_envDiffuse", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4, 1),
			u_env_specular: create_uniform("u_envSpecular", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4, 1),
			u_pbr_params: create_uniform("u_pbrParams", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4, 1),
			u_emissive_scaling: create_uniform(
				"u_fsfEmissiveScaling",
				bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
				1,
			),
			u_soft_particle_param: create_uniform(
				"u_fssoftParticleParam",
				bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
				1,
			),
			u_reconstruction_param1: create_uniform(
				"u_fsreconstructionParam1",
				bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
				1,
			),
			u_reconstruction_param2: create_uniform(
				"u_fsreconstructionParam2",
				bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
				1,
			),
			u_uv_inversed_back: create_uniform(
				"u_fsmUVInversedBack",
				bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
				1,
			),
			u_misc_flags: create_uniform("u_fsmiscFlags", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4, 1),
			s_base_color: create_uniform("s_baseColor", bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER, 1),
			s_metallic_roughness: create_uniform(
				"s_metallicRoughness",
				bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER,
				1,
			),
			s_normal: create_uniform("s_normal", bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER, 1),
			s_emissive: create_uniform("s_emissive", bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER, 1),
			s_occlusion: create_uniform("s_occlusion", bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER, 1),
			s_clearcoat: create_uniform("s_clearcoat", bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER, 1),
			s_clearcoat_roughness: create_uniform(
				"s_clearcoatRoughness",
				bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER,
				1,
			),
			s_clearcoat_normal: create_uniform(
				"s_clearcoatNormal",
				bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER,
				1,
			),
			s_irradiance: create_uniform("s_irradiance", bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER, 1),
			s_prefilter: create_uniform("s_prefilter", bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER, 1),
			s_brdf_lut: create_uniform("s_brdfLut", bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER, 1),
			s_specular: create_uniform("s_specular", bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER, 1),
			s_specular_color: create_uniform(
				"s_specularColor",
				bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER,
				1,
			),
			s_transmission: create_uniform(
				"s_transmission",
				bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER,
				1,
			),
			s_thickness: create_uniform("s_thickness", bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER, 1),
			s_thickness_sheen: create_uniform(
				"s_thicknessSheen",
				bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER,
				1,
			),
			s_sheen_color: create_uniform("s_sheenColor", bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER, 1),
			s_sheen_roughness: create_uniform(
				"s_sheenRoughness",
				bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER,
				1,
			),
			u_joints: create_uniform(
				"u_joints",
				bgfx_sys::BGFX_UNIFORM_TYPE_MAT4,
				MAX_JOINTS as u16,
			),
			_white_texture: white_texture,
			white_texture_bgfx: texture::texture_handle(white_texture)
				.unwrap_or_else(texture::invalid_handle),
			_black_texture: black_texture,
			black_texture_bgfx: texture::texture_handle(black_texture)
				.unwrap_or_else(texture::invalid_handle),
			_flat_normal_texture: flat_normal_texture,
			flat_normal_texture_bgfx: texture::texture_handle(flat_normal_texture)
				.unwrap_or_else(texture::invalid_handle),
			_irradiance_texture: irradiance_texture,
			irradiance_texture_bgfx: texture::texture_handle(irradiance_texture)
				.unwrap_or_else(texture::invalid_handle),
			_prefilter_texture: prefilter_texture,
			prefilter_texture_bgfx: texture::texture_handle(prefilter_texture)
				.unwrap_or_else(texture::invalid_handle),
			_brdf_lut_texture: brdf_lut_texture,
			brdf_lut_texture_bgfx: texture::texture_handle(brdf_lut_texture)
				.unwrap_or_else(texture::invalid_handle),
		}
	})
}

fn current_view_state() -> &'static Mutex<Option<ViewState>> {
	static CURRENT_VIEW: OnceLock<Mutex<Option<ViewState>>> = OnceLock::new();
	CURRENT_VIEW.get_or_init(|| Mutex::new(None))
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
			MaterialType::PbrMetallicRoughness
				if matches!(
					material
						.shader_params
						.get(material::default_thickness_sheen_slot()),
					Some(material::ShaderParam::Texture(_))
				) =>
			{
				state.programs.thickness_sheen
			}
			MaterialType::PbrMetallicRoughness
				if matches!(
					material
						.shader_params
						.get(material::default_sheen_roughness_slot()),
					Some(material::ShaderParam::Texture(_))
				) =>
			{
				state.programs.sheen_roughness
			}
			MaterialType::Lambert | MaterialType::PbrMetallicRoughness | MaterialType::Custom => {
				state.programs.lambert
			}
		}
	})
	.unwrap_or(state.programs.lambert)
}

fn apply_material_or_default(material_handle: Dora3DHandle) {
	if material::apply(material_handle) {
		return;
	}
	let state = bgfx_sys::BGFX_STATE_WRITE_RGB as u64
		| bgfx_sys::BGFX_STATE_WRITE_A as u64
		| bgfx_sys::BGFX_STATE_WRITE_Z as u64
		| bgfx_sys::BGFX_STATE_DEPTH_TEST_LESS as u64
		| bgfx_sys::BGFX_STATE_MSAA as u64;
	unsafe {
		bgfx_sys::bgfx_set_state(state, 0);
	}
}

unsafe fn bind_texture_or_skip(
	stage: u8,
	uniform: bgfx_sys::bgfx_uniform_handle_t,
	texture: bgfx_sys::bgfx_texture_handle_t,
) {
	if uniform.idx == u16::MAX {
		return;
	}
	if texture.idx == u16::MAX {
		return;
	}
	bgfx_sys::bgfx_set_texture(stage, uniform, texture, u32::MAX);
}

unsafe fn set_default_textures(state: &ShaderState, environment: &EnvironmentTextures) {
	bind_texture_or_skip(0, state.s_base_color, state.white_texture_bgfx);
	bind_texture_or_skip(1, state.s_metallic_roughness, state.white_texture_bgfx);
	bind_texture_or_skip(2, state.s_normal, state.flat_normal_texture_bgfx);
	bind_texture_or_skip(3, state.s_emissive, state.black_texture_bgfx);
	bind_texture_or_skip(4, state.s_occlusion, state.white_texture_bgfx);
	bind_texture_or_skip(5, state.s_clearcoat, state.white_texture_bgfx);
	bind_texture_or_skip(6, state.s_clearcoat_roughness, state.white_texture_bgfx);
	bind_texture_or_skip(7, state.s_clearcoat_normal, state.flat_normal_texture_bgfx);
	bind_texture_or_skip(8, state.s_irradiance, environment.irradiance_texture);
	bind_texture_or_skip(9, state.s_prefilter, environment.prefilter_texture);
	bind_texture_or_skip(10, state.s_brdf_lut, state.brdf_lut_texture_bgfx);
	bind_texture_or_skip(11, state.s_specular, state.white_texture_bgfx);
	bind_texture_or_skip(12, state.s_specular_color, state.white_texture_bgfx);
	bind_texture_or_skip(13, state.s_transmission, state.white_texture_bgfx);
	bind_texture_or_skip(14, state.s_thickness, state.white_texture_bgfx);
	bind_texture_or_skip(14, state.s_thickness_sheen, state.white_texture_bgfx);
	bind_texture_or_skip(15, state.s_sheen_color, state.white_texture_bgfx);
	bind_texture_or_skip(14, state.s_sheen_roughness, state.white_texture_bgfx);
}

unsafe fn set_uniform<T>(uniform: bgfx_sys::bgfx_uniform_handle_t, value: &T, num: u16) {
	if uniform.idx == u16::MAX {
		return;
	}
	bgfx_sys::bgfx_set_uniform(uniform, value as *const T as *const _, num);
}

pub fn ensure_shaders() -> ShaderPrograms {
	shader_state().programs
}

pub fn set_view_transforms(view_id: bgfx_sys::bgfx_view_id_t, view_proj: &Mat4, view_pos: Vec3) {
	let state = shader_state();
	let identity = Mat4::IDENTITY.to_cols_array();
	let combined = mat4_to_bgfx_array(view_proj);
	let view_pos_uniform = [view_pos.x, view_pos.y, view_pos.z, 0.0];
	let environment = environment_for_view(view_id);
	let env_diffuse = [1.0f32, 1.0, 1.0, environment.settings.diffuse_intensity];
	let env_specular = [
		1.0f32,
		(DEFAULT_PREFILTER_MIPS - 1) as f32,
		0.0,
		environment.settings.specular_intensity,
	];
	let pbr_params = [environment.settings.exposure, 0.0, 0.0, 0.0];
	let emissive_scaling = [1.0f32, 0.0, 0.0, 0.0];
	let uv_inversed = [0.0f32, 1.0, 0.0, 0.0];
	let zero = [0.0f32, 0.0, 0.0, 0.0];
	unsafe {
		// bgfx still needs a view/proj pair for internal view state; model shaders
		// consume the combined matrix through u_mCameraProj.
		bgfx_sys::bgfx_set_view_transform(
			view_id,
			identity.as_ptr() as *const _,
			combined.as_ptr() as *const _,
		);
		set_uniform(state.u_camera_proj, &combined, 1);
		set_uniform(state.u_uv_inversed, &uv_inversed, 1);
		set_uniform(state.u_view_pos, &view_pos_uniform, 1);
		set_uniform(state.u_env_diffuse, &env_diffuse, 1);
		set_uniform(state.u_env_specular, &env_specular, 1);
		set_uniform(state.u_pbr_params, &pbr_params, 1);
		set_uniform(state.u_emissive_scaling, &emissive_scaling, 1);
		set_uniform(state.u_soft_particle_param, &zero, 1);
		set_uniform(state.u_reconstruction_param1, &zero, 1);
		set_uniform(state.u_reconstruction_param2, &zero, 1);
		set_uniform(state.u_uv_inversed_back, &uv_inversed, 1);
		set_uniform(state.u_misc_flags, &zero, 1);
	}
	*current_view_state().lock().unwrap() = Some(ViewState { view_id });
}

unsafe fn apply_draw_uniforms(
	state: &ShaderState,
	model_matrix: &Mat4,
	joint_matrices: Option<&[Mat4]>,
) {
	let model = mat4_to_bgfx_array(model_matrix);
	let normal_model = mat4_to_bgfx_array(&model_matrix.inverse().transpose());
	let uv = [0.0f32, 0.0, 1.0, 1.0];
	let model_color = [1.0f32, 1.0, 1.0, 1.0];
	set_uniform(state.u_model_inst, &model, 1);
	set_uniform(state.u_normal_model, &normal_model, 1);
	set_uniform(state.u_uv, &uv, 1);
	set_uniform(state.u_model_color, &model_color, 1);
	if let Some(joint_matrices) = joint_matrices {
		let mut joints = JointUniforms {
			matrices: [0.0; 16 * MAX_JOINTS],
		};
		for joint_index in 0..MAX_JOINTS {
			let base = joint_index * 16;
			joints.matrices[base] = 1.0;
			joints.matrices[base + 5] = 1.0;
			joints.matrices[base + 10] = 1.0;
			joints.matrices[base + 15] = 1.0;
		}
		for (joint_index, matrix) in joint_matrices.iter().take(MAX_JOINTS).enumerate() {
			let packed = mat4_to_bgfx_array(matrix);
			let base = joint_index * 16;
			joints.matrices[base..base + 16].copy_from_slice(&packed);
		}
		set_uniform(state.u_joints, &joints.matrices, MAX_JOINTS as u16);
	}
}

pub fn submit_mesh(
	mesh_handle: Dora3DHandle,
	material_handle: Dora3DHandle,
	model_matrix: &Mat4,
	joint_matrices: Option<&[Mat4]>,
) -> bool {
	let _ = ensure_shaders();
	let state = shader_state();
	let view_state = current_view_state()
		.lock()
		.unwrap()
		.as_ref()
		.copied()
		.unwrap_or(ViewState { view_id: 0 });
	let program = choose_program(state, material_handle);
	if program.idx == u16::MAX {
		return false;
	}

	mesh::with_mesh(mesh_handle, |mesh_data| unsafe {
		let transform = mat4_to_bgfx_array(model_matrix);
		bgfx_sys::bgfx_set_transform(transform.as_ptr() as *const _, 1);
		apply_draw_uniforms(state, model_matrix, joint_matrices);
		bgfx_sys::bgfx_set_vertex_buffer(
			0,
			mesh_data.vertex_buffer,
			0,
			mesh_data.vertices.len() as u32,
		);
		for sub_mesh in &mesh_data.sub_meshes {
			let environment = environment_for_view(view_state.view_id);
			set_default_textures(state, &environment.textures);
			apply_material_or_default(material_handle);
			bgfx_sys::bgfx_set_index_buffer(
				mesh_data.index_buffer,
				sub_mesh.start_index,
				sub_mesh.index_count,
			);
			bgfx_sys::bgfx_submit(
				view_state.view_id,
				program,
				0,
				bgfx_sys::BGFX_DISCARD_NONE as u8,
			);
		}
	})
	.is_some()
}
