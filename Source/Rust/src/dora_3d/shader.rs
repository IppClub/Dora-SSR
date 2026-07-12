use super::light3d::DrawLights;
use super::material::{self, MaterialType};
use super::mesh;
use super::profile3d;
use super::texture;
use super::types::{mat4_to_bgfx_array, Aabb, Mat4, Vec3, Vec4};
use super::{next_handle, Dora3DHandle};
use crate::bgfx_rs::bgfx_sys;
use crate::Content;
use image::GenericImageView;
use std::collections::{HashMap, VecDeque};
use std::f32::consts::PI;
use std::ffi::CString;
use std::os::raw::c_char;
use std::sync::{Mutex, OnceLock};
use std::time::Instant;
use std::{mem::MaybeUninit, ptr};

pub const MAX_JOINTS: usize = 64;
const DEFAULT_IRRADIANCE_SIZE: u16 = 8;
const DEFAULT_PREFILTER_SIZE: u16 = 32;
const DEFAULT_PREFILTER_MIPS: u8 = 5;
const IRRADIANCE_SAMPLE_COUNT: u32 = 64;
const PREFILTER_SAMPLE_COUNT: u32 = 64;
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
	pub shadow: bgfx_sys::bgfx_program_handle_t,
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
	u_directional_light_direction: bgfx_sys::bgfx_uniform_handle_t,
	u_directional_light_color: bgfx_sys::bgfx_uniform_handle_t,
	u_point_light_position_range: bgfx_sys::bgfx_uniform_handle_t,
	u_point_light_color_intensity: bgfx_sys::bgfx_uniform_handle_t,
	u_overflow_light_sh: bgfx_sys::bgfx_uniform_handle_t,
	u_shadow_matrix: bgfx_sys::bgfx_uniform_handle_t,
	u_shadow_params: bgfx_sys::bgfx_uniform_handle_t,
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
	s_shadow_map: bgfx_sys::bgfx_uniform_handle_t,
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

#[derive(Debug)]
struct PreparedCubeFaceMip {
	side: u8,
	mip: u8,
	size: u16,
	rgba16f: Vec<u8>,
	rgba8: Vec<u8>,
}

#[derive(Debug)]
struct PreparedEnvironment {
	path: String,
	irradiance: VecDeque<PreparedCubeFaceMip>,
	prefilter: VecDeque<PreparedCubeFaceMip>,
}

#[derive(Debug, Clone, Copy)]
struct EnvironmentTextures {
	irradiance: Dora3DHandle,
	irradiance_texture: bgfx_sys::bgfx_texture_handle_t,
	prefilter: Dora3DHandle,
	prefilter_texture: bgfx_sys::bgfx_texture_handle_t,
}

#[derive(Debug)]
pub struct ShadowMap {
	pub frame_buffer: bgfx_sys::bgfx_frame_buffer_handle_t,
	pub texture: bgfx_sys::bgfx_texture_handle_t,
	pub size: u16,
}

#[derive(Debug, Clone, Copy)]
pub struct ShadowDrawState {
	pub matrix: Mat4,
	pub texture: bgfx_sys::bgfx_texture_handle_t,
	pub bias: f32,
	pub normal_bias: f32,
	pub inv_size: f32,
}

impl Drop for ShadowMap {
	fn drop(&mut self) {
		if self.frame_buffer.idx != u16::MAX {
			unsafe { bgfx_sys::bgfx_destroy_frame_buffer(self.frame_buffer) };
		}
	}
}

fn shadow_maps() -> &'static Mutex<HashMap<Dora3DHandle, ShadowMap>> {
	static MAPS: OnceLock<Mutex<HashMap<Dora3DHandle, ShadowMap>>> = OnceLock::new();
	MAPS.get_or_init(|| Mutex::new(HashMap::new()))
}

pub fn prepare_shadow_map(
	root: Dora3DHandle,
	view_id: bgfx_sys::bgfx_view_id_t,
	size: u16,
) -> Option<bgfx_sys::bgfx_texture_handle_t> {
	let mut maps = shadow_maps().lock().unwrap();
	let recreate = maps.get(&root).map(|map| map.size != size).unwrap_or(true);
	if recreate {
		maps.remove(&root);
		let flags = bgfx_sys::BGFX_TEXTURE_RT as u64
			| bgfx_sys::BGFX_SAMPLER_U_CLAMP as u64
			| bgfx_sys::BGFX_SAMPLER_V_CLAMP as u64
			| bgfx_sys::BGFX_SAMPLER_MIN_POINT as u64
			| bgfx_sys::BGFX_SAMPLER_MAG_POINT as u64;
		let color = unsafe {
			bgfx_sys::bgfx_create_texture_2d(
				size,
				size,
				false,
				1,
				bgfx_sys::BGFX_TEXTURE_FORMAT_RGBA8,
				flags,
				std::ptr::null(),
			)
		};
		let depth = unsafe {
			bgfx_sys::bgfx_create_texture_2d(
				size,
				size,
				false,
				1,
				bgfx_sys::BGFX_TEXTURE_FORMAT_D24S8,
				bgfx_sys::BGFX_TEXTURE_RT as u64,
				std::ptr::null(),
			)
		};
		if color.idx == u16::MAX || depth.idx == u16::MAX {
			unsafe {
				if color.idx != u16::MAX {
					bgfx_sys::bgfx_destroy_texture(color);
				}
				if depth.idx != u16::MAX {
					bgfx_sys::bgfx_destroy_texture(depth);
				}
			}
			return None;
		}
		let attachments = [color, depth];
		let frame_buffer = unsafe {
			bgfx_sys::bgfx_create_frame_buffer_from_handles(
				attachments.len() as u8,
				attachments.as_ptr(),
				true,
			)
		};
		if frame_buffer.idx == u16::MAX {
			unsafe {
				bgfx_sys::bgfx_destroy_texture(color);
				bgfx_sys::bgfx_destroy_texture(depth);
			}
			return None;
		}
		maps.insert(
			root,
			ShadowMap {
				frame_buffer,
				texture: color,
				size,
			},
		);
	}
	let map = maps.get(&root)?;
	unsafe {
		bgfx_sys::bgfx_set_view_rect(view_id, 0, 0, map.size, map.size);
		bgfx_sys::bgfx_set_view_frame_buffer(view_id, map.frame_buffer);
		bgfx_sys::bgfx_set_view_clear(
			view_id,
			(bgfx_sys::BGFX_CLEAR_COLOR | bgfx_sys::BGFX_CLEAR_DEPTH | bgfx_sys::BGFX_CLEAR_STENCIL)
				as u16,
			0xffff_ffff,
			1.0,
			0,
		);
	}
	Some(map.texture)
}

pub fn remove_shadow_map(root: Dora3DHandle) {
	shadow_maps().lock().unwrap().remove(&root);
}

pub fn clear_shadow_maps() {
	shadow_maps().lock().unwrap().clear();
}

#[repr(u8)]
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum EnvironmentUploadPhase {
	CreateIrradiance,
	UploadIrradiance,
	CreatePrefilter,
	UploadPrefilter,
	Finalize,
}

#[derive(Debug)]
struct EnvironmentUploadJob {
	prepared: PreparedEnvironment,
	phase: EnvironmentUploadPhase,
	irradiance: Option<(Dora3DHandle, bool)>,
	prefilter: Option<(Dora3DHandle, bool)>,
	face_x: u16,
	face_y: u16,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum EnvironmentUploadStep {
	Pending,
	Complete,
	Failed,
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

fn prepared_environment_registry() -> &'static Mutex<HashMap<Dora3DHandle, PreparedEnvironment>> {
	static REGISTRY: OnceLock<Mutex<HashMap<Dora3DHandle, PreparedEnvironment>>> = OnceLock::new();
	REGISTRY.get_or_init(|| Mutex::new(HashMap::new()))
}

fn environment_upload_job_registry() -> &'static Mutex<HashMap<Dora3DHandle, EnvironmentUploadJob>>
{
	static REGISTRY: OnceLock<Mutex<HashMap<Dora3DHandle, EnvironmentUploadJob>>> = OnceLock::new();
	REGISTRY.get_or_init(|| Mutex::new(HashMap::new()))
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
	let resolved_path = resolve_content_path(path);
	if is_environment_cached(&resolved_path) {
		return true;
	}
	let Some(prepared) = prepare_environment_equirect_cpu(&resolved_path) else {
		return false;
	};
	let Some(job) = begin_environment_upload(prepared) else {
		return false;
	};
	loop {
		match step_environment_upload(job, u64::MAX).0 {
			EnvironmentUploadStep::Pending => continue,
			EnvironmentUploadStep::Complete => return true,
			EnvironmentUploadStep::Failed => return false,
		}
	}
}

pub fn is_environment_cached(path: &str) -> bool {
	environment_cache().lock().unwrap().contains_key(path)
}

pub fn prepare_environment_equirect_cpu(path: &str) -> Option<Dora3DHandle> {
	if path.trim().is_empty() || is_environment_cached(path) {
		return None;
	}
	let environment = load_equirect_environment(path)?;
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
	let handle = next_handle();
	prepared_environment_registry().lock().unwrap().insert(
		handle,
		PreparedEnvironment {
			path: path.to_owned(),
			irradiance: prepare_environment_faces(generated.irradiance),
			prefilter: prepare_environment_faces(generated.prefilter),
		},
	);
	Some(handle)
}

pub fn begin_environment_upload(prepared: Dora3DHandle) -> Option<Dora3DHandle> {
	let prepared = prepared_environment_registry()
		.lock()
		.unwrap()
		.remove(&prepared)?;
	let handle = next_handle();
	environment_upload_job_registry().lock().unwrap().insert(
		handle,
		EnvironmentUploadJob {
			prepared,
			phase: EnvironmentUploadPhase::CreateIrradiance,
			irradiance: None,
			prefilter: None,
			face_x: 0,
			face_y: 0,
		},
	);
	Some(handle)
}

pub fn discard_prepared_environment(prepared: Dora3DHandle) -> bool {
	prepared_environment_registry()
		.lock()
		.unwrap()
		.remove(&prepared)
		.is_some()
}

pub fn step_environment_upload(job: Dora3DHandle, max_bytes: u64) -> (EnvironmentUploadStep, u64) {
	let Some(mut upload) = environment_upload_job_registry()
		.lock()
		.unwrap()
		.remove(&job)
	else {
		return (EnvironmentUploadStep::Failed, 0);
	};
	let phase = upload.phase as u8;
	let started = Instant::now();
	let (result, bytes) = step_environment_upload_job(&mut upload, max_bytes);
	profile3d::record_upload(1, phase, started.elapsed().as_micros() as u64, bytes);
	match result {
		EnvironmentUploadStep::Pending => {
			environment_upload_job_registry()
				.lock()
				.unwrap()
				.insert(job, upload);
			(EnvironmentUploadStep::Pending, bytes)
		}
		EnvironmentUploadStep::Complete => (EnvironmentUploadStep::Complete, bytes),
		EnvironmentUploadStep::Failed => {
			cleanup_environment_upload_job(upload);
			(EnvironmentUploadStep::Failed, 0)
		}
	}
}

pub fn cancel_environment_upload(job: Dora3DHandle) -> bool {
	let Some(upload) = environment_upload_job_registry()
		.lock()
		.unwrap()
		.remove(&job)
	else {
		return false;
	};
	cleanup_environment_upload_job(upload);
	true
}

fn environment_textures_for_path(path: &str) -> Option<EnvironmentTextures> {
	let trimmed = path.trim();
	if trimmed.is_empty() {
		let state = shader_state();
		return Some(EnvironmentTextures {
			irradiance: 0,
			irradiance_texture: state.irradiance_texture_bgfx,
			prefilter: 0,
			prefilter_texture: state.prefilter_texture_bgfx,
		});
	}
	let resolved_path = resolve_content_path(path);
	environment_cache()
		.lock()
		.unwrap()
		.get(&resolved_path)
		.copied()
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
				irradiance: 0,
				irradiance_texture: state.irradiance_texture_bgfx,
				prefilter: 0,
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

fn prepare_environment_faces(faces: Vec<CubeFaceMip>) -> VecDeque<PreparedCubeFaceMip> {
	faces
		.into_iter()
		.map(|face| {
			let rgba16f = texture::prepare_rgba16f(&face.pixels);
			let mut rgba8 = Vec::with_capacity(face.pixels.len() * 4);
			for pixel in &face.pixels {
				rgba8.extend_from_slice(&[
					linear_to_byte(pixel[0]),
					linear_to_byte(pixel[1]),
					linear_to_byte(pixel[2]),
					linear_to_byte(pixel[3]),
				]);
			}
			PreparedCubeFaceMip {
				side: face.side,
				mip: face.mip,
				size: face.size,
				rgba16f,
				rgba8,
			}
		})
		.collect()
}

fn create_empty_environment_cube(
	size: u16,
	mip_count: u8,
	name: &str,
) -> Option<(Dora3DHandle, bool)> {
	let flags = bgfx_sys::BGFX_SAMPLER_U_CLAMP as u64
		| bgfx_sys::BGFX_SAMPLER_V_CLAMP as u64
		| bgfx_sys::BGFX_SAMPLER_W_CLAMP as u64;
	if let Some(handle) = texture::create_cube_rgba16f(size, mip_count > 1, flags, Some(name)) {
		return Some((handle, true));
	}
	texture::create_cube_rgba8(size, mip_count > 1, flags, Some(name)).map(|handle| (handle, false))
}

fn upload_prepared_environment_face(
	texture: (Dora3DHandle, bool),
	face: &PreparedCubeFaceMip,
	x: u16,
	y: u16,
	max_bytes: u64,
) -> Option<(u64, u16, u16, bool)> {
	let (pixels, bytes_per_pixel) = if texture.1 {
		(face.rgba16f.as_slice(), 8usize)
	} else {
		(face.rgba8.as_slice(), 4usize)
	};
	let max_pixels = (max_bytes / bytes_per_pixel as u64).min(u32::MAX as u64) as usize;
	if max_pixels == 0 {
		return Some((0, x, y, false));
	}
	let (width, height) = texture::upload_region_size(face.size, face.size, x, y, max_pixels)?;
	let offset = (y as usize * face.size as usize + x as usize) * bytes_per_pixel;
	let bytes = width as usize * height as usize * bytes_per_pixel;
	let source = pixels.get(offset..offset.checked_add(bytes)?)?;
	if !texture::update_cube_bytes_region(
		texture.0,
		face.side,
		face.mip,
		x,
		y,
		width,
		height,
		source,
		bytes_per_pixel,
	) {
		return None;
	}
	let (next_x, next_y) = if height > 1 || width == face.size - x {
		(0, y + height)
	} else {
		(x + width, y)
	};
	Some((bytes as u64, next_x, next_y, next_y == face.size))
}

fn step_environment_upload_job(
	job: &mut EnvironmentUploadJob,
	max_bytes: u64,
) -> (EnvironmentUploadStep, u64) {
	match job.phase {
		EnvironmentUploadPhase::CreateIrradiance => {
			job.irradiance = create_empty_environment_cube(
				DEFAULT_IRRADIANCE_SIZE,
				1,
				&format!("Dora3D Irradiance {}", job.prepared.path),
			);
			if job.irradiance.is_none() {
				return (EnvironmentUploadStep::Failed, 0);
			}
			job.phase = EnvironmentUploadPhase::UploadIrradiance;
		}
		EnvironmentUploadPhase::UploadIrradiance => {
			let Some(face) = job.prepared.irradiance.front() else {
				job.phase = EnvironmentUploadPhase::CreatePrefilter;
				return (EnvironmentUploadStep::Pending, 0);
			};
			let Some((bytes, x, y, complete)) = upload_prepared_environment_face(
				job.irradiance.unwrap(),
				face,
				job.face_x,
				job.face_y,
				max_bytes,
			) else {
				return (EnvironmentUploadStep::Failed, 0);
			};
			job.face_x = x;
			job.face_y = y;
			if complete {
				job.prepared.irradiance.pop_front();
				job.face_x = 0;
				job.face_y = 0;
			}
			return (EnvironmentUploadStep::Pending, bytes);
		}
		EnvironmentUploadPhase::CreatePrefilter => {
			job.prefilter = create_empty_environment_cube(
				DEFAULT_PREFILTER_SIZE,
				DEFAULT_PREFILTER_MIPS,
				&format!("Dora3D Prefilter {}", job.prepared.path),
			);
			if job.prefilter.is_none() {
				return (EnvironmentUploadStep::Failed, 0);
			}
			job.phase = EnvironmentUploadPhase::UploadPrefilter;
		}
		EnvironmentUploadPhase::UploadPrefilter => {
			let Some(face) = job.prepared.prefilter.front() else {
				job.phase = EnvironmentUploadPhase::Finalize;
				return (EnvironmentUploadStep::Pending, 0);
			};
			let Some((bytes, x, y, complete)) = upload_prepared_environment_face(
				job.prefilter.unwrap(),
				face,
				job.face_x,
				job.face_y,
				max_bytes,
			) else {
				return (EnvironmentUploadStep::Failed, 0);
			};
			job.face_x = x;
			job.face_y = y;
			if complete {
				job.prepared.prefilter.pop_front();
				job.face_x = 0;
				job.face_y = 0;
			}
			return (EnvironmentUploadStep::Pending, bytes);
		}
		EnvironmentUploadPhase::Finalize => {
			let Some((irradiance, _)) = job.irradiance.take() else {
				return (EnvironmentUploadStep::Failed, 0);
			};
			let Some((prefilter, _)) = job.prefilter.take() else {
				let _ = texture::destroy(irradiance);
				return (EnvironmentUploadStep::Failed, 0);
			};
			let Some(irradiance_texture) = texture::texture_handle(irradiance) else {
				let _ = texture::destroy(irradiance);
				let _ = texture::destroy(prefilter);
				return (EnvironmentUploadStep::Failed, 0);
			};
			let Some(prefilter_texture) = texture::texture_handle(prefilter) else {
				let _ = texture::destroy(irradiance);
				let _ = texture::destroy(prefilter);
				return (EnvironmentUploadStep::Failed, 0);
			};
			environment_cache().lock().unwrap().insert(
				job.prepared.path.clone(),
				EnvironmentTextures {
					irradiance,
					irradiance_texture,
					prefilter,
					prefilter_texture,
				},
			);
			return (EnvironmentUploadStep::Complete, 0);
		}
	}
	(EnvironmentUploadStep::Pending, 0)
}

fn cleanup_environment_upload_job(mut job: EnvironmentUploadJob) {
	if let Some((handle, _)) = job.irradiance.take() {
		let _ = texture::destroy(handle);
	}
	if let Some((handle, _)) = job.prefilter.take() {
		let _ = texture::destroy(handle);
	}
}

fn update_cube_faces(handle: Dora3DHandle, faces: &[CubeFaceMip]) -> bool {
	for face in faces {
		if !texture::update_cube_rgba16f(handle, face.side, face.mip, face.size, &face.pixels) {
			return false;
		}
	}
	true
}

pub fn clear_environment_cache() {
	prepared_environment_registry().lock().unwrap().clear();
	let jobs: Vec<Dora3DHandle> = environment_upload_job_registry()
		.lock()
		.unwrap()
		.keys()
		.copied()
		.collect();
	for handle in jobs {
		let _ = cancel_environment_upload(handle);
	}
	let environments: Vec<EnvironmentTextures> = environment_cache()
		.lock()
		.unwrap()
		.drain()
		.map(|(_, textures)| textures)
		.collect();
	for environment in environments {
		if environment.irradiance != 0 {
			let _ = texture::destroy(environment.irradiance);
		}
		if environment.prefilter != 0 {
			let _ = texture::destroy(environment.prefilter);
		}
	}
	view_environments().lock().unwrap().clear();
}

pub fn environment_count() -> usize {
	environment_cache().lock().unwrap().len()
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

fn shader_state() -> &'static ShaderState {
	static SHADER_STATE: OnceLock<ShaderState> = OnceLock::new();
	SHADER_STATE.get_or_init(|| {
		let unlit = create_builtin_program("vs_model3d", "fs_model3d");
		let sheen_roughness = create_builtin_program("vs_model3d", "fs_model3d_sheen");
		let thickness_sheen = create_builtin_program("vs_model3d", "fs_model3d_thickness_sheen");
		let shadow = create_builtin_program("vs_shadow_model3d", "fs_shadow_model3d");
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
		ShaderState {
			programs: ShaderPrograms {
				unlit,
				lambert: unlit,
				sheen_roughness,
				thickness_sheen,
				shadow,
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
			u_directional_light_direction: create_uniform(
				"u_directionalLightDirection",
				bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
				1,
			),
			u_directional_light_color: create_uniform(
				"u_directionalLightColor",
				bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
				1,
			),
			u_point_light_position_range: create_uniform(
				"u_pointLightPositionRange",
				bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
				4,
			),
			u_point_light_color_intensity: create_uniform(
				"u_pointLightColorIntensity",
				bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
				4,
			),
			u_overflow_light_sh: create_uniform(
				"u_overflowLightSH",
				bgfx_sys::BGFX_UNIFORM_TYPE_VEC4,
				4,
			),
			u_shadow_matrix: create_uniform("u_shadowMatrix", bgfx_sys::BGFX_UNIFORM_TYPE_MAT4, 1),
			u_shadow_params: create_uniform("u_shadowParams", bgfx_sys::BGFX_UNIFORM_TYPE_VEC4, 1),
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
			s_shadow_map: create_uniform("s_shadowMap", bgfx_sys::BGFX_UNIFORM_TYPE_SAMPLER, 1),
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
		}
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
	bind_texture_or_skip(10, state.s_shadow_map, state.white_texture_bgfx);
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

pub fn program_index(material_handle: Dora3DHandle) -> u16 {
	choose_program(shader_state(), material_handle).idx
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
}

unsafe fn apply_draw_uniforms(
	state: &ShaderState,
	model_matrix: &Mat4,
	joint_matrices: Option<&[Mat4]>,
	lights: &DrawLights,
	shadow: Option<&ShadowDrawState>,
) {
	let model = mat4_to_bgfx_array(model_matrix);
	let normal_model = mat4_to_bgfx_array(&model_matrix.inverse().transpose());
	let uv = [0.0f32, 0.0, 1.0, 1.0];
	let model_color = [1.0f32, 1.0, 1.0, 1.0];
	set_uniform(state.u_model_inst, &model, 1);
	set_uniform(state.u_normal_model, &normal_model, 1);
	set_uniform(state.u_uv, &uv, 1);
	set_uniform(state.u_model_color, &model_color, 1);
	set_uniform(
		state.u_directional_light_direction,
		&lights.directional_direction,
		1,
	);
	set_uniform(
		state.u_directional_light_color,
		&lights.directional_color,
		1,
	);
	set_uniform(
		state.u_point_light_position_range,
		&lights.point_position_range,
		4,
	);
	set_uniform(
		state.u_point_light_color_intensity,
		&lights.point_color_intensity,
		4,
	);
	set_uniform(state.u_overflow_light_sh, &lights.overflow_sh, 4);
	let (shadow_matrix, shadow_params, shadow_texture) = if let Some(shadow) = shadow {
		(
			mat4_to_bgfx_array(&shadow.matrix),
			[shadow.bias, shadow.normal_bias, shadow.inv_size, 1.0],
			shadow.texture,
		)
	} else {
		(
			mat4_to_bgfx_array(&Mat4::IDENTITY),
			[0.0, 0.0, 0.0, 0.0],
			state.white_texture_bgfx,
		)
	};
	set_uniform(state.u_shadow_matrix, &shadow_matrix, 1);
	set_uniform(state.u_shadow_params, &shadow_params, 1);
	bind_texture_or_skip(10, state.s_shadow_map, shadow_texture);
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
	view_id: bgfx_sys::bgfx_view_id_t,
	mesh_handle: Dora3DHandle,
	material_handle: Dora3DHandle,
	model_matrix: &Mat4,
	joint_matrices: Option<&[Mat4]>,
	lights: &DrawLights,
	shadow: Option<&ShadowDrawState>,
	apply_material: bool,
) -> bool {
	let _ = ensure_shaders();
	let state = shader_state();
	let program = choose_program(state, material_handle);
	if program.idx == u16::MAX {
		return false;
	}

	mesh::with_mesh(mesh_handle, |mesh_data| unsafe {
		let transform = mat4_to_bgfx_array(model_matrix);
		bgfx_sys::bgfx_set_transform(transform.as_ptr() as *const _, 1);
		apply_draw_uniforms(state, model_matrix, joint_matrices, lights, shadow);
		mesh_data.bind_vertex_buffer();
		if apply_material {
			let environment = environment_for_view(view_id);
			set_default_textures(state, &environment.textures);
			apply_material_or_default(material_handle);
		}
		if let Some(shadow) = shadow {
			bind_texture_or_skip(10, state.s_shadow_map, shadow.texture);
		}
		for sub_mesh in &mesh_data.sub_meshes {
			mesh_data.bind_index_buffer(sub_mesh.start_index, sub_mesh.index_count);
			bgfx_sys::bgfx_submit(view_id, program, 0, bgfx_sys::BGFX_DISCARD_NONE as u8);
		}
	})
	.is_some()
}

pub fn set_shadow_view(view_id: bgfx_sys::bgfx_view_id_t, light_view_proj: &Mat4) {
	let state = shader_state();
	let identity = Mat4::IDENTITY.to_cols_array();
	let packed = mat4_to_bgfx_array(light_view_proj);
	unsafe {
		bgfx_sys::bgfx_set_view_transform(
			view_id,
			identity.as_ptr() as *const _,
			packed.as_ptr() as *const _,
		);
		set_uniform(state.u_camera_proj, &packed, 1);
	}
}

pub fn submit_shadow_mesh(
	view_id: bgfx_sys::bgfx_view_id_t,
	mesh_handle: Dora3DHandle,
	material_handle: Dora3DHandle,
	model_matrix: &Mat4,
	joint_matrices: Option<&[Mat4]>,
) -> bool {
	if !material::is_shadow_caster(material_handle) {
		return false;
	}
	let state = shader_state();
	let program = state.programs.shadow;
	if program.idx == u16::MAX {
		return false;
	}
	mesh::with_mesh(mesh_handle, |mesh_data| unsafe {
		let transform = mat4_to_bgfx_array(model_matrix);
		bgfx_sys::bgfx_set_transform(transform.as_ptr() as *const _, 1);
		apply_draw_uniforms(
			state,
			model_matrix,
			joint_matrices,
			&DrawLights::default(),
			None,
		);
		let caps = &*bgfx_sys::bgfx_get_caps();
		let depth_params = if caps.homogeneousDepth {
			[0.5f32, 0.5, 0.0, 0.0]
		} else {
			[1.0f32, 0.0, 0.0, 0.0]
		};
		set_uniform(state.u_shadow_params, &depth_params, 1);
		mesh_data.bind_vertex_buffer();
		let environment = environment_for_view(view_id);
		set_default_textures(state, &environment.textures);
		material::apply(material_handle);
		material::apply_shadow_state(material_handle);
		for sub_mesh in &mesh_data.sub_meshes {
			mesh_data.bind_index_buffer(sub_mesh.start_index, sub_mesh.index_count);
			bgfx_sys::bgfx_submit(view_id, program, 0, bgfx_sys::BGFX_DISCARD_NONE as u8);
		}
	})
	.is_some()
}

pub fn submit_debug_bounds(
	view_id: bgfx_sys::bgfx_view_id_t,
	bounds: &Aabb,
	mesh_handle: Dora3DHandle,
	material_handle: Dora3DHandle,
) -> bool {
	let Some(layout) = mesh::with_mesh(mesh_handle, |mesh| mesh.vertex_layout) else {
		return false;
	};
	submit_debug_bounds_with_layout(view_id, bounds, &layout, material_handle)
}

pub fn submit_debug_bounds_colored(
	view_id: bgfx_sys::bgfx_view_id_t,
	bounds: &Aabb,
	color: Vec4,
	material_handle: Dora3DHandle,
) -> bool {
	material::set_base_color(material_handle, color);
	let layout = mesh::create_vertex_layout();
	submit_debug_bounds_with_layout(view_id, bounds, &layout, material_handle)
}

pub fn submit_debug_shape_colored(
	view_id: bgfx_sys::bgfx_view_id_t,
	kind: u8,
	size: Vec3,
	transform: Mat4,
	color: Vec4,
	material_handle: Dora3DHandle,
) -> bool {
	material::set_base_color(material_handle, color);
	let mut positions = Vec::new();
	let mut segment = |start: Vec3, end: Vec3| {
		positions.push(transform.transform_point3(start));
		positions.push(transform.transform_point3(end));
	};
	match kind {
		1 => {
			let half = size;
			let corners = [
				Vec3::new(-half.x, -half.y, -half.z),
				Vec3::new(half.x, -half.y, -half.z),
				Vec3::new(half.x, half.y, -half.z),
				Vec3::new(-half.x, half.y, -half.z),
				Vec3::new(-half.x, -half.y, half.z),
				Vec3::new(half.x, -half.y, half.z),
				Vec3::new(half.x, half.y, half.z),
				Vec3::new(-half.x, half.y, half.z),
			];
			for (start, end) in [
				(0, 1),
				(1, 2),
				(2, 3),
				(3, 0),
				(4, 5),
				(5, 6),
				(6, 7),
				(7, 4),
				(0, 4),
				(1, 5),
				(2, 6),
				(3, 7),
			] {
				segment(corners[start], corners[end]);
			}
		}
		2 => append_sphere_debug_lines(&mut segment, size.x.max(0.0)),
		3 => append_capsule_debug_lines(&mut segment, size.x.max(0.0), size.y.max(0.0)),
		_ => return false,
	}
	let layout = mesh::create_vertex_layout();
	submit_debug_line_positions(view_id, &positions, &layout, material_handle)
}

fn append_sphere_debug_lines(segment: &mut impl FnMut(Vec3, Vec3), radius: f32) {
	const SEGMENTS: usize = 16;
	if radius <= 0.0 {
		return;
	}
	for plane in 0..3 {
		for index in 0..SEGMENTS {
			let angle = index as f32 * 2.0 * PI / SEGMENTS as f32;
			let next_angle = (index + 1) as f32 * 2.0 * PI / SEGMENTS as f32;
			let point = |angle: f32| match plane {
				0 => Vec3::new(angle.cos() * radius, angle.sin() * radius, 0.0),
				1 => Vec3::new(angle.cos() * radius, 0.0, angle.sin() * radius),
				_ => Vec3::new(0.0, angle.cos() * radius, angle.sin() * radius),
			};
			segment(point(angle), point(next_angle));
		}
	}
}

fn append_capsule_debug_lines(segment: &mut impl FnMut(Vec3, Vec3), half_height: f32, radius: f32) {
	const SEGMENTS: usize = 16;
	if radius <= 0.0 {
		return;
	}
	for y in [-half_height, half_height] {
		for index in 0..SEGMENTS {
			let angle = index as f32 * 2.0 * PI / SEGMENTS as f32;
			let next_angle = (index + 1) as f32 * 2.0 * PI / SEGMENTS as f32;
			segment(
				Vec3::new(angle.cos() * radius, y, angle.sin() * radius),
				Vec3::new(next_angle.cos() * radius, y, next_angle.sin() * radius),
			);
		}
	}
	for direction_angle in [0.0, PI * 0.5, PI, PI * 1.5] {
		let direction = Vec3::new(direction_angle.cos(), 0.0, direction_angle.sin());
		segment(
			direction * radius + Vec3::Y * half_height,
			direction * radius - Vec3::Y * half_height,
		);
		let mut top = Vec3::Y * (half_height + radius);
		let mut bottom = -Vec3::Y * (half_height + radius);
		for index in 1..=SEGMENTS / 2 {
			let angle = index as f32 * PI * 0.5 / (SEGMENTS / 2) as f32;
			let next_top =
				direction * (radius * angle.sin()) + Vec3::Y * (half_height + radius * angle.cos());
			let next_bottom =
				direction * (radius * angle.sin()) - Vec3::Y * (half_height + radius * angle.cos());
			segment(top, next_top);
			segment(bottom, next_bottom);
			top = next_top;
			bottom = next_bottom;
		}
	}
}

fn submit_debug_line_positions(
	view_id: bgfx_sys::bgfx_view_id_t,
	positions: &[Vec3],
	layout: &bgfx_sys::bgfx_vertex_layout_t,
	material_handle: Dora3DHandle,
) -> bool {
	if positions.is_empty() {
		return false;
	}
	let _ = ensure_shaders();
	let state = shader_state();
	let program = choose_program(state, material_handle);
	if program.idx == u16::MAX {
		return false;
	}
	let vertices: Vec<_> = positions
		.iter()
		.map(|position| mesh::Vertex {
			position: position.to_array(),
			normal: [0.0, 1.0, 0.0],
			tangent: [1.0, 0.0, 0.0, 1.0],
			color: u32::MAX,
			..Default::default()
		})
		.collect();
	unsafe {
		let mut buffer = MaybeUninit::<bgfx_sys::bgfx_transient_vertex_buffer_t>::zeroed();
		bgfx_sys::bgfx_alloc_transient_vertex_buffer(
			buffer.as_mut_ptr(),
			vertices.len() as u32,
			layout,
		);
		let buffer = buffer.assume_init();
		if buffer.data.is_null() {
			return false;
		}
		ptr::copy_nonoverlapping(
			vertices.as_ptr(),
			buffer.data.cast::<mesh::Vertex>(),
			vertices.len(),
		);
		bgfx_sys::bgfx_discard(bgfx_sys::BGFX_DISCARD_ALL as u8);
		let identity = Mat4::IDENTITY;
		let transform = mat4_to_bgfx_array(&identity);
		bgfx_sys::bgfx_set_transform(transform.as_ptr() as *const _, 1);
		apply_draw_uniforms(state, &identity, None, &DrawLights::default(), None);
		let environment = environment_for_view(view_id);
		set_default_textures(state, &environment.textures);
		material::apply(material_handle);
		let draw_state = bgfx_sys::BGFX_STATE_WRITE_RGB as u64
			| bgfx_sys::BGFX_STATE_WRITE_A as u64
			| bgfx_sys::BGFX_STATE_DEPTH_TEST_ALWAYS as u64
			| bgfx_sys::BGFX_STATE_PT_LINES as u64
			| bgfx_sys::BGFX_STATE_MSAA as u64;
		bgfx_sys::bgfx_set_state(draw_state, 0);
		bgfx_sys::bgfx_set_transient_vertex_buffer(0, &buffer, 0, vertices.len() as u32);
		bgfx_sys::bgfx_submit(view_id, program, 0, bgfx_sys::BGFX_DISCARD_ALL as u8);
	}
	true
}

fn submit_debug_bounds_with_layout(
	view_id: bgfx_sys::bgfx_view_id_t,
	bounds: &Aabb,
	layout: &bgfx_sys::bgfx_vertex_layout_t,
	material_handle: Dora3DHandle,
) -> bool {
	let _ = ensure_shaders();
	let state = shader_state();
	let program = choose_program(state, material_handle);
	if program.idx == u16::MAX {
		return false;
	}
	let min = bounds.min;
	let max = bounds.max;
	let corners = [
		[min.x, min.y, min.z],
		[max.x, min.y, min.z],
		[max.x, max.y, min.z],
		[min.x, max.y, min.z],
		[min.x, min.y, max.z],
		[max.x, min.y, max.z],
		[max.x, max.y, max.z],
		[min.x, max.y, max.z],
	];
	let edges = [
		(0, 1),
		(1, 2),
		(2, 3),
		(3, 0),
		(4, 5),
		(5, 6),
		(6, 7),
		(7, 4),
		(0, 4),
		(1, 5),
		(2, 6),
		(3, 7),
	];
	let mut vertices = Vec::with_capacity(edges.len() * 2);
	for (start, end) in edges {
		for position in [corners[start], corners[end]] {
			vertices.push(mesh::Vertex {
				position,
				normal: [0.0, 1.0, 0.0],
				tangent: [1.0, 0.0, 0.0, 1.0],
				color: u32::MAX,
				..Default::default()
			});
		}
	}

	unsafe {
		let mut buffer = MaybeUninit::<bgfx_sys::bgfx_transient_vertex_buffer_t>::zeroed();
		bgfx_sys::bgfx_alloc_transient_vertex_buffer(
			buffer.as_mut_ptr(),
			vertices.len() as u32,
			layout,
		);
		let buffer = buffer.assume_init();
		if buffer.data.is_null() {
			return false;
		}
		ptr::copy_nonoverlapping(
			vertices.as_ptr(),
			buffer.data.cast::<mesh::Vertex>(),
			vertices.len(),
		);
		// Mesh submissions preserve their index buffer for batching. Debug bounds
		// are non-indexed line pairs, so clear inherited bindings before drawing.
		bgfx_sys::bgfx_discard(bgfx_sys::BGFX_DISCARD_ALL as u8);
		let identity = Mat4::IDENTITY;
		let transform = mat4_to_bgfx_array(&identity);
		bgfx_sys::bgfx_set_transform(transform.as_ptr() as *const _, 1);
		apply_draw_uniforms(state, &identity, None, &DrawLights::default(), None);
		let environment = environment_for_view(view_id);
		set_default_textures(state, &environment.textures);
		material::apply(material_handle);
		let draw_state = bgfx_sys::BGFX_STATE_WRITE_RGB as u64
			| bgfx_sys::BGFX_STATE_WRITE_A as u64
			| bgfx_sys::BGFX_STATE_DEPTH_TEST_ALWAYS as u64
			| bgfx_sys::BGFX_STATE_PT_LINES as u64
			| bgfx_sys::BGFX_STATE_MSAA as u64;
		bgfx_sys::bgfx_set_state(draw_state, 0);
		bgfx_sys::bgfx_set_transient_vertex_buffer(0, &buffer, 0, vertices.len() as u32);
		bgfx_sys::bgfx_submit(view_id, program, 0, bgfx_sys::BGFX_DISCARD_ALL as u8);
	}
	true
}
