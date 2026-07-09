use super::camera3d;
use super::model_loader;
use super::node3d;
use super::renderer3d;
use super::shader;
use super::types::{mat4_from_bgfx_array, mat4_to_bgfx_array, Quaternion, Vec3};
use super::visual3d;
use super::{Dora3DHandle, INVALID_HANDLE};
use std::ffi::CStr;
use std::os::raw::c_char;

fn opt_str<'a>(ptr: *const c_char) -> Option<&'a str> {
	if ptr.is_null() {
		return None;
	}
	unsafe { CStr::from_ptr(ptr).to_str().ok() }
}

fn write_vec3(out: *mut f32, value: Vec3) -> bool {
	if out.is_null() {
		return false;
	}
	unsafe {
		let data = [value.x, value.y, value.z];
		std::ptr::copy_nonoverlapping(data.as_ptr(), out, data.len());
	}
	true
}

fn write_quat(out: *mut f32, value: Quaternion) -> bool {
	if out.is_null() {
		return false;
	}
	unsafe {
		let data = [value.x, value.y, value.z, value.w];
		std::ptr::copy_nonoverlapping(data.as_ptr(), out, data.len());
	}
	true
}

fn write_mat4(out: *mut f32, matrix: super::types::Mat4) -> bool {
	if out.is_null() {
		return false;
	}
	unsafe {
		let packed = mat4_to_bgfx_array(&matrix);
		std::ptr::copy_nonoverlapping(packed.as_ptr(), out, packed.len());
	}
	true
}

fn read_mat4(ptr: *const f32) -> Option<super::types::Mat4> {
	if ptr.is_null() {
		return None;
	}
	let packed = unsafe {
		let mut data = [0.0f32; 16];
		std::ptr::copy_nonoverlapping(ptr, data.as_mut_ptr(), data.len());
		data
	};
	Some(mat4_from_bgfx_array(&packed))
}

#[no_mangle]
pub extern "C" fn dora_3d_cleanup() {
	renderer3d::clear_queue();
	model_loader::clear_registry();
	visual3d::clear_registry();
	super::material::clear_registry();
	shader::clear_environment_cache();
	super::mesh::clear_registry();
	super::texture::clear_registry();
	camera3d::clear_registry();
	node3d::clear_registry();
}

#[no_mangle]
pub extern "C" fn dora_3d_set_view_state(
	view_id: u16,
	view_proj: *const f32,
	eye_x: f32,
	eye_y: f32,
	eye_z: f32,
) {
	let Some(view_proj) = read_mat4(view_proj) else {
		return;
	};
	renderer3d::set_view_state(view_id, view_proj, Vec3::new(eye_x, eye_y, eye_z));
}

#[no_mangle]
pub extern "C" fn dora_3d_set_view_frustum_culling(view_id: u16, enabled: i32) {
	renderer3d::set_view_frustum_culling(view_id, enabled != 0);
}

#[no_mangle]
pub extern "C" fn dora_3d_render_node(view_id: u16, node: Dora3DHandle) -> i32 {
	renderer3d::render_node(view_id, node) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_render_with_view(view_id: u16) -> i32 {
	renderer3d::render_view(view_id) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_set_environment_equirect(path: *const c_char) -> i32 {
	let Some(path) = opt_str(path) else {
		return 0;
	};
	shader::prepare_environment_equirect(path) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_set_environment_intensity(diffuse: f32, specular: f32, exposure: f32) {
	let _ = shader::set_view_environment(0, "", diffuse, specular, exposure);
}

#[no_mangle]
pub extern "C" fn dora_3d_prepare_environment_equirect(path: *const c_char) -> i32 {
	let Some(path) = opt_str(path) else {
		return 0;
	};
	shader::prepare_environment_equirect(path) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_set_view_environment(
	view_id: u16,
	path: *const c_char,
	diffuse: f32,
	specular: f32,
	exposure: f32,
) -> i32 {
	let Some(path) = opt_str(path) else {
		return 0;
	};
	shader::set_view_environment(view_id, path, diffuse, specular, exposure) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_queue_visual(visual: Dora3DHandle, view_id: u16, sort_key: u64) -> i32 {
	renderer3d::queue_visual(visual, view_id, sort_key) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_node_create() -> Dora3DHandle {
	node3d::create()
}

#[no_mangle]
pub extern "C" fn dora_3d_node_destroy(node: Dora3DHandle) {
	let _ = node3d::destroy(node);
}

#[no_mangle]
pub extern "C" fn dora_3d_node_exists(node: Dora3DHandle) -> i32 {
	node3d::exists(node) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_node_add_child(
	parent: Dora3DHandle,
	child: Dora3DHandle,
	order: i32,
	tag: *const c_char,
) -> i32 {
	node3d::add_child(parent, child, order, opt_str(tag)) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_node_remove_child(parent: Dora3DHandle, child: Dora3DHandle) -> i32 {
	node3d::remove_child(parent, child) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_node_remove_from_parent(node: Dora3DHandle) -> i32 {
	node3d::remove_from_parent(node) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_node_set_position(node: Dora3DHandle, x: f32, y: f32, z: f32) {
	let _ = node3d::set_position(node, Vec3::new(x, y, z));
}

#[no_mangle]
pub extern "C" fn dora_3d_node_get_position(node: Dora3DHandle, out: *mut f32) {
	if let Some(position) = node3d::get_position(node) {
		let _ = write_vec3(out, position);
	}
}

#[no_mangle]
pub extern "C" fn dora_3d_node_set_rotation(node: Dora3DHandle, x: f32, y: f32, z: f32, w: f32) {
	let _ = node3d::set_rotation(node, Quaternion::from_xyzw(x, y, z, w));
}

#[no_mangle]
pub extern "C" fn dora_3d_node_get_rotation(node: Dora3DHandle, out: *mut f32) {
	if let Some(rotation) = node3d::get_rotation(node) {
		let _ = write_quat(out, rotation);
	}
}

#[no_mangle]
pub extern "C" fn dora_3d_node_set_euler(node: Dora3DHandle, x: f32, y: f32, z: f32) {
	let _ = node3d::set_euler_deg(node, Vec3::new(x, y, z));
}

#[no_mangle]
pub extern "C" fn dora_3d_node_get_euler(node: Dora3DHandle, out: *mut f32) {
	if let Some(euler) = node3d::get_euler_deg(node) {
		let _ = write_vec3(out, euler);
	}
}

#[no_mangle]
pub extern "C" fn dora_3d_node_set_scale(node: Dora3DHandle, x: f32, y: f32, z: f32) {
	let _ = node3d::set_scale(node, Vec3::new(x, y, z));
}

#[no_mangle]
pub extern "C" fn dora_3d_node_get_scale(node: Dora3DHandle, out: *mut f32) {
	if let Some(scale) = node3d::get_scale(node) {
		let _ = write_vec3(out, scale);
	}
}

#[no_mangle]
pub extern "C" fn dora_3d_node_set_tag(node: Dora3DHandle, tag: *const c_char) {
	let Some(tag) = opt_str(tag) else {
		return;
	};
	let _ = node3d::set_tag(node, tag);
}

#[no_mangle]
pub extern "C" fn dora_3d_node_set_visible(node: Dora3DHandle, visible: i32) {
	let _ = node3d::set_visible(node, visible != 0);
}

#[no_mangle]
pub extern "C" fn dora_3d_node_is_visible(node: Dora3DHandle) -> i32 {
	node3d::is_visible(node) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_node_get_world_matrix(node: Dora3DHandle, out: *mut f32) {
	if let Some(matrix) = node3d::world_matrix(node) {
		let _ = write_mat4(out, matrix);
	}
}

#[no_mangle]
pub extern "C" fn dora_3d_node_convert_to_world(
	node: Dora3DHandle,
	x: f32,
	y: f32,
	z: f32,
	out: *mut f32,
) {
	if let Some(point) = node3d::convert_to_world_space(node, Vec3::new(x, y, z)) {
		let _ = write_vec3(out, point);
	}
}

#[no_mangle]
pub extern "C" fn dora_3d_node_convert_to_node(
	node: Dora3DHandle,
	x: f32,
	y: f32,
	z: f32,
	out: *mut f32,
) {
	if let Some(point) = node3d::convert_to_node_space(node, Vec3::new(x, y, z)) {
		let _ = write_vec3(out, point);
	}
}

#[no_mangle]
pub extern "C" fn dora_3d_camera_create() -> Dora3DHandle {
	camera3d::create()
}

#[no_mangle]
pub extern "C" fn dora_3d_camera_destroy(camera: Dora3DHandle) {
	let _ = camera3d::destroy(camera);
}

#[no_mangle]
pub extern "C" fn dora_3d_camera_set_perspective(
	camera: Dora3DHandle,
	fov: f32,
	aspect: f32,
	near: f32,
	far: f32,
) {
	let _ = camera3d::set_perspective(camera, fov, aspect, near, far);
}

#[no_mangle]
pub extern "C" fn dora_3d_camera_set_lookat(
	camera: Dora3DHandle,
	ex: f32,
	ey: f32,
	ez: f32,
	tx: f32,
	ty: f32,
	tz: f32,
) {
	let _ = camera3d::look_at(
		camera,
		Vec3::new(ex, ey, ez),
		Vec3::new(tx, ty, tz),
		Vec3::Y,
	);
}

#[no_mangle]
pub extern "C" fn dora_3d_camera_get_view_proj(camera: Dora3DHandle, out: *mut f32) {
	if let Some(matrix) = camera3d::view_projection_matrix(camera) {
		let _ = write_mat4(out, matrix);
	}
}

#[no_mangle]
pub extern "C" fn dora_3d_load_gltf(path: *const c_char) -> Dora3DHandle {
	let Some(path) = opt_str(path) else {
		return INVALID_HANDLE;
	};
	model_loader::load_gltf(path).unwrap_or(INVALID_HANDLE)
}

#[no_mangle]
pub extern "C" fn dora_3d_model_destroy(model: Dora3DHandle) {
	let _ = model_loader::destroy(model);
}

#[no_mangle]
pub extern "C" fn dora_3d_model_get_visual(model: Dora3DHandle, index: u32) -> Dora3DHandle {
	model_loader::get_visual(model, index).unwrap_or(INVALID_HANDLE)
}

#[no_mangle]
pub extern "C" fn dora_3d_model_attach_to_node(model: Dora3DHandle, node: Dora3DHandle) -> i32 {
	model_loader::attach_to_node(model, node) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_model_instantiate(
	model: Dora3DHandle,
	node: Dora3DHandle,
) -> Dora3DHandle {
	model_loader::instantiate(model, node).unwrap_or(INVALID_HANDLE)
}

#[no_mangle]
pub extern "C" fn dora_3d_model_instance_destroy(instance: Dora3DHandle) {
	let _ = model_loader::destroy_instance(instance);
}

#[no_mangle]
pub extern "C" fn dora_3d_model_play(
	instance: Dora3DHandle,
	name: *const c_char,
	looping: i32,
) -> f32 {
	model_loader::play_instance(instance, opt_str(name), looping != 0).unwrap_or(-1.0)
}

#[no_mangle]
pub extern "C" fn dora_3d_model_stop(instance: Dora3DHandle) {
	let _ = model_loader::stop_instance(instance);
}

#[no_mangle]
pub extern "C" fn dora_3d_model_pause(instance: Dora3DHandle) {
	let _ = model_loader::pause_instance(instance);
}

#[no_mangle]
pub extern "C" fn dora_3d_model_resume(instance: Dora3DHandle) {
	let _ = model_loader::resume_instance(instance);
}

#[no_mangle]
pub extern "C" fn dora_3d_model_is_paused(instance: Dora3DHandle) -> i32 {
	model_loader::is_paused_instance(instance) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_model_set_speed(instance: Dora3DHandle, speed: f32) {
	let _ = model_loader::set_speed_instance(instance, speed);
}

#[no_mangle]
pub extern "C" fn dora_3d_model_get_speed(instance: Dora3DHandle) -> f32 {
	model_loader::get_speed_instance(instance)
}

#[no_mangle]
pub extern "C" fn dora_3d_model_get_elapsed(instance: Dora3DHandle) -> f32 {
	model_loader::get_elapsed_instance(instance)
}

#[no_mangle]
pub extern "C" fn dora_3d_model_get_duration(instance: Dora3DHandle) -> f32 {
	model_loader::get_duration_instance(instance)
}

#[no_mangle]
pub extern "C" fn dora_3d_model_update(instance: Dora3DHandle, delta_time: f32) -> i32 {
	model_loader::update_instance(instance, delta_time) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_visual_add_to_node(visual: Dora3DHandle, node: Dora3DHandle) {
	let _ = visual3d::set_node(visual, node);
}

#[no_mangle]
pub extern "C" fn dora_3d_visual_set_frustum_culling(visual: Dora3DHandle, enabled: i32) {
	let _ = visual3d::set_frustum_culling(visual, enabled != 0);
}
