use super::camera3d;
use super::jolt;
use super::light3d;
use super::material;
use super::model_loader;
use super::node3d;
use super::renderer3d;
use super::shader;
use super::types::{
	mat4_from_bgfx_array, mat4_to_bgfx_array, quaternion_from_euler_deg, Aabb, Quaternion, Vec3,
	Vec4,
};
use super::visual3d;
use super::{Dora3DHandle, INVALID_HANDLE};
use std::ffi::{c_void, CStr, CString};
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
	jolt::clear_registry();
	light3d::clear_registry();
	model_loader::clear_registry();
	visual3d::clear_registry();
	super::material::clear_registry();
	shader::clear_environment_cache();
	super::mesh::clear_registry();
	super::texture::clear_registry();
	camera3d::clear_registry();
	node3d::clear_registry();
	super::profile3d::clear();
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
pub extern "C" fn dora_3d_set_view_show_aabb(view_id: u16, enabled: i32) {
	renderer3d::set_view_show_aabb(view_id, enabled != 0);
}

#[no_mangle]
pub extern "C" fn dora_3d_queue_physics_debug_bounds(
	root: Dora3DHandle,
	min_x: f32,
	min_y: f32,
	min_z: f32,
	max_x: f32,
	max_y: f32,
	max_z: f32,
	red: f32,
	green: f32,
	blue: f32,
) {
	renderer3d::queue_physics_debug_bounds(
		root,
		Aabb {
			min: Vec3::new(min_x, min_y, min_z),
			max: Vec3::new(max_x, max_y, max_z),
		},
		Vec4::new(red, green, blue, 1.0),
	);
}

#[no_mangle]
pub extern "C" fn dora_3d_queue_physics_debug_shape(
	root: Dora3DHandle,
	kind: u8,
	x: f32,
	y: f32,
	z: f32,
	transform: *const f32,
	red: f32,
	green: f32,
	blue: f32,
) {
	let Some(transform) = read_mat4(transform) else {
		return;
	};
	renderer3d::queue_physics_debug_shape(
		root,
		kind,
		Vec3::new(x, y, z),
		transform,
		Vec4::new(red, green, blue, 1.0),
	);
}

#[no_mangle]
pub extern "C" fn dora_3d_render_node(view_id: u16, node: Dora3DHandle) -> i32 {
	renderer3d::render_node(view_id, node) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_render_node_with_shadow(
	view_id: u16,
	shadow_view_id: u16,
	node: Dora3DHandle,
) -> i32 {
	renderer3d::render_node_with_shadow(view_id, shadow_view_id, node) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_render_with_view(view_id: u16) -> i32 {
	renderer3d::render_view(view_id) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_get_render_stats(view_id: u16, out: *mut u64, count: u32) -> i32 {
	if out.is_null() || count < renderer3d::RENDER_STATS_VALUE_COUNT as u32 {
		return 0;
	}
	let values = renderer3d::get_render_stats(view_id).to_values();
	unsafe {
		std::ptr::copy_nonoverlapping(values.as_ptr(), out, values.len());
	}
	1
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
pub extern "C" fn dora_3d_environment_is_cached(path: *const c_char) -> i32 {
	let Some(path) = opt_str(path) else {
		return 0;
	};
	shader::is_environment_cached(path) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_prepare_environment_equirect_cpu(path: *const c_char) -> Dora3DHandle {
	let Some(path) = opt_str(path) else {
		return 0;
	};
	shader::prepare_environment_equirect_cpu(path).unwrap_or(0)
}

#[no_mangle]
pub extern "C" fn dora_3d_begin_environment_upload(prepared: Dora3DHandle) -> Dora3DHandle {
	shader::begin_environment_upload(prepared).unwrap_or(0)
}

#[no_mangle]
pub extern "C" fn dora_3d_step_environment_upload(
	job: Dora3DHandle,
	max_bytes: u64,
	uploaded_bytes: *mut u64,
) -> i32 {
	let (result, bytes) = shader::step_environment_upload(job, max_bytes);
	if !uploaded_bytes.is_null() {
		unsafe { *uploaded_bytes = bytes };
	}
	match result {
		shader::EnvironmentUploadStep::Pending => 0,
		shader::EnvironmentUploadStep::Complete => 1,
		shader::EnvironmentUploadStep::Failed => -1,
	}
}

#[no_mangle]
pub extern "C" fn dora_3d_cancel_environment_upload(job: Dora3DHandle) {
	let _ = shader::cancel_environment_upload(job);
}

#[no_mangle]
pub extern "C" fn dora_3d_discard_prepared_environment(prepared: Dora3DHandle) {
	let _ = shader::discard_prepared_environment(prepared);
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
	jolt::destroy_node(node);
	light3d::destroy_node(node);
	let _ = node3d::destroy(node);
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_world_create(max_bodies: u32) -> Dora3DHandle {
	jolt::create_world(max_bodies)
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_world_destroy(world: Dora3DHandle) {
	let _ = jolt::destroy_world(world);
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_world_set_gravity(world: Dora3DHandle, x: f32, y: f32, z: f32) {
	let _ = jolt::set_gravity(world, Vec3::new(x, y, z));
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_world_step(world: Dora3DHandle, delta_time: f32) -> i32 {
	jolt::fixed_update(world, delta_time) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_shape_create_box(x: f32, y: f32, z: f32) -> Dora3DHandle {
	jolt::create_box_shape(Vec3::new(x, y, z))
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_shape_create_sphere(radius: f32) -> Dora3DHandle {
	jolt::create_sphere_shape(radius)
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_shape_create_capsule(
	half_height: f32,
	radius: f32,
) -> Dora3DHandle {
	jolt::create_capsule_shape(half_height, radius)
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_shape_create_compound() -> Dora3DHandle {
	jolt::create_compound_shape_builder()
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_shape_add_child(
	compound: Dora3DHandle,
	shape: Dora3DHandle,
	position_x: f32,
	position_y: f32,
	position_z: f32,
	angle_x: f32,
	angle_y: f32,
	angle_z: f32,
) -> i32 {
	jolt::add_compound_shape_part(
		compound,
		shape,
		Vec3::new(position_x, position_y, position_z),
		quaternion_from_euler_deg(Vec3::new(angle_x, angle_y, angle_z)),
	) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_shape_build(shape: Dora3DHandle) -> i32 {
	jolt::build_compound_shape(shape) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_shape_is_built(shape: Dora3DHandle) -> i32 {
	jolt::shape_is_built(shape) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_shape_destroy(shape: Dora3DHandle) {
	let _ = jolt::destroy_shape(shape);
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_body_create_box(
	world: Dora3DHandle,
	node: Dora3DHandle,
	half_x: f32,
	half_y: f32,
	half_z: f32,
	motion: u8,
) -> Dora3DHandle {
	let motion = match motion {
		0 => jolt::MotionType::Static,
		1 => jolt::MotionType::Kinematic,
		_ => jolt::MotionType::Dynamic,
	};
	jolt::create_body(
		world,
		node,
		jolt::CollisionShape::Box {
			half_extent: Vec3::new(half_x, half_y, half_z),
		},
		motion,
	)
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_body_create_sphere(
	world: Dora3DHandle,
	node: Dora3DHandle,
	radius: f32,
	motion: u8,
) -> Dora3DHandle {
	let motion = match motion {
		0 => jolt::MotionType::Static,
		1 => jolt::MotionType::Kinematic,
		_ => jolt::MotionType::Dynamic,
	};
	jolt::create_body(world, node, jolt::CollisionShape::Sphere { radius }, motion)
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_body_create_capsule(
	world: Dora3DHandle,
	node: Dora3DHandle,
	half_height: f32,
	radius: f32,
	motion: u8,
) -> Dora3DHandle {
	let motion = match motion {
		0 => jolt::MotionType::Static,
		1 => jolt::MotionType::Kinematic,
		_ => jolt::MotionType::Dynamic,
	};
	jolt::create_body(
		world,
		node,
		jolt::CollisionShape::Capsule {
			half_height,
			radius,
		},
		motion,
	)
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_body_create_shape(
	world: Dora3DHandle,
	node: Dora3DHandle,
	shape: Dora3DHandle,
	motion: u8,
) -> Dora3DHandle {
	let motion = match motion {
		0 => jolt::MotionType::Static,
		1 => jolt::MotionType::Kinematic,
		_ => jolt::MotionType::Dynamic,
	};
	jolt::create_body_with_shape(world, node, shape, motion)
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_body_get_bounds(
	world: Dora3DHandle,
	body: Dora3DHandle,
	out: *mut f32,
) -> i32 {
	if out.is_null() {
		return 0;
	}
	let Some((min, max)) = jolt::body_bounds(world, body) else {
		return 0;
	};
	let values = [min.x, min.y, min.z, max.x, max.y, max.z];
	unsafe { std::ptr::copy_nonoverlapping(values.as_ptr(), out, values.len()) };
	1
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_constraint_create_fixed(
	world: Dora3DHandle,
	first: Dora3DHandle,
	second: Dora3DHandle,
	x: f32,
	y: f32,
	z: f32,
) -> Dora3DHandle {
	jolt::create_fixed_constraint(world, first, second, Vec3::new(x, y, z))
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_constraint_create_distance(
	world: Dora3DHandle,
	first: Dora3DHandle,
	second: Dora3DHandle,
	first_x: f32,
	first_y: f32,
	first_z: f32,
	second_x: f32,
	second_y: f32,
	second_z: f32,
	min_distance: f32,
	max_distance: f32,
) -> Dora3DHandle {
	jolt::create_distance_constraint(
		world,
		first,
		second,
		Vec3::new(first_x, first_y, first_z),
		Vec3::new(second_x, second_y, second_z),
		min_distance,
		max_distance,
	)
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_constraint_create_hinge(
	world: Dora3DHandle,
	first: Dora3DHandle,
	second: Dora3DHandle,
	anchor_x: f32,
	anchor_y: f32,
	anchor_z: f32,
	axis_x: f32,
	axis_y: f32,
	axis_z: f32,
	min_angle: f32,
	max_angle: f32,
) -> Dora3DHandle {
	jolt::create_hinge_constraint(
		world,
		first,
		second,
		Vec3::new(anchor_x, anchor_y, anchor_z),
		Vec3::new(axis_x, axis_y, axis_z),
		min_angle.to_radians(),
		max_angle.to_radians(),
	)
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_constraint_destroy(
	world: Dora3DHandle,
	constraint: Dora3DHandle,
) -> i32 {
	jolt::destroy_constraint(world, constraint) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_body_destroy(world: Dora3DHandle, body: Dora3DHandle) -> i32 {
	jolt::destroy_body(world, body) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_character_create_capsule(
	world: Dora3DHandle,
	node: Dora3DHandle,
	half_height: f32,
	radius: f32,
	max_slope_angle: f32,
	step_height: f32,
) -> Dora3DHandle {
	jolt::create_character_capsule(
		world,
		node,
		half_height,
		radius,
		max_slope_angle,
		step_height,
	)
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_character_destroy(
	world: Dora3DHandle,
	character: Dora3DHandle,
) -> i32 {
	jolt::destroy_character(world, character) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_character_set_velocity(
	world: Dora3DHandle,
	character: Dora3DHandle,
	x: f32,
	y: f32,
	z: f32,
) -> i32 {
	jolt::set_character_velocity(world, character, Vec3::new(x, y, z)) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_character_jump(
	world: Dora3DHandle,
	character: Dora3DHandle,
	speed: f32,
) -> i32 {
	jolt::jump_character(world, character, speed) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_character_set_filter(
	world: Dora3DHandle,
	character: Dora3DHandle,
	layer: u8,
	mask: u32,
) -> i32 {
	jolt::set_character_filter(world, character, layer, mask) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_character_get_state(
	world: Dora3DHandle,
	character: Dora3DHandle,
	velocity: *mut f32,
	ground_state: *mut u8,
	ground_normal: *mut f32,
) -> i32 {
	if velocity.is_null() || ground_state.is_null() || ground_normal.is_null() {
		return 0;
	}
	let Some(state) = jolt::character_state(world, character) else {
		return 0;
	};
	unsafe {
		std::ptr::copy_nonoverlapping(state.velocity.to_array().as_ptr(), velocity, 3);
		*ground_state = state.ground_state as u8;
		std::ptr::copy_nonoverlapping(state.ground_normal.to_array().as_ptr(), ground_normal, 3);
	}
	1
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_body_set_linear_velocity(
	world: Dora3DHandle,
	body: Dora3DHandle,
	x: f32,
	y: f32,
	z: f32,
) -> i32 {
	jolt::set_linear_velocity(world, body, Vec3::new(x, y, z)) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_body_get_linear_velocity(
	world: Dora3DHandle,
	body: Dora3DHandle,
	out: *mut f32,
) -> i32 {
	jolt::linear_velocity(world, body)
		.map(|velocity| write_vec3(out, velocity) as i32)
		.unwrap_or(0)
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_body_set_angular_velocity(
	world: Dora3DHandle,
	body: Dora3DHandle,
	x: f32,
	y: f32,
	z: f32,
) -> i32 {
	jolt::set_angular_velocity(world, body, Vec3::new(x, y, z)) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_body_get_angular_velocity(
	world: Dora3DHandle,
	body: Dora3DHandle,
	out: *mut f32,
) -> i32 {
	jolt::angular_velocity(world, body)
		.map(|velocity| write_vec3(out, velocity) as i32)
		.unwrap_or(0)
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_body_apply_force(
	world: Dora3DHandle,
	body: Dora3DHandle,
	x: f32,
	y: f32,
	z: f32,
) -> i32 {
	jolt::apply_force(world, body, Vec3::new(x, y, z)) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_body_apply_impulse(
	world: Dora3DHandle,
	body: Dora3DHandle,
	x: f32,
	y: f32,
	z: f32,
) -> i32 {
	jolt::apply_impulse(world, body, Vec3::new(x, y, z)) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_body_set_filter(
	world: Dora3DHandle,
	body: Dora3DHandle,
	layer: u8,
	mask: u32,
) -> i32 {
	jolt::set_filter(world, body, layer, mask) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_body_get_filter(
	world: Dora3DHandle,
	body: Dora3DHandle,
	layer: *mut u8,
	mask: *mut u32,
) -> i32 {
	let Some((value_layer, value_mask)) = jolt::filter(world, body) else {
		return 0;
	};
	unsafe {
		if !layer.is_null() {
			*layer = value_layer;
		}
		if !mask.is_null() {
			*mask = value_mask;
		}
	}
	1
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_body_set_sensor(
	world: Dora3DHandle,
	body: Dora3DHandle,
	sensor: i32,
) -> i32 {
	jolt::set_sensor(world, body, sensor != 0) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_body_is_sensor(world: Dora3DHandle, body: Dora3DHandle) -> i32 {
	jolt::is_sensor(world, body).unwrap_or(false) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_world_event_count(world: Dora3DHandle) -> u32 {
	jolt::event_count(world) as u32
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_world_event_get(
	world: Dora3DHandle,
	index: u32,
	event_type: *mut u8,
	body: *mut Dora3DHandle,
	other: *mut Dora3DHandle,
	point: *mut f32,
	normal: *mut f32,
) -> i32 {
	let Some(event) = jolt::event(world, index as usize) else {
		return 0;
	};
	unsafe {
		if !event_type.is_null() {
			*event_type = event.event_type as u8;
		}
		if !body.is_null() {
			*body = event.body;
		}
		if !other.is_null() {
			*other = event.other;
		}
	}
	write_vec3(point, event.point);
	write_vec3(normal, event.normal);
	1
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_world_event_clear(world: Dora3DHandle) {
	jolt::clear_events(world);
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_world_raycast(
	world: Dora3DHandle,
	origin_x: f32,
	origin_y: f32,
	origin_z: f32,
	direction_x: f32,
	direction_y: f32,
	direction_z: f32,
	distance: f32,
	body: *mut Dora3DHandle,
	point: *mut f32,
	normal: *mut f32,
	fraction: *mut f32,
) -> i32 {
	let Some(hit) = jolt::raycast(
		world,
		Vec3::new(origin_x, origin_y, origin_z),
		Vec3::new(direction_x, direction_y, direction_z),
		distance,
	) else {
		return 0;
	};
	unsafe {
		if !body.is_null() {
			*body = hit.body;
		}
		if !fraction.is_null() {
			*fraction = hit.distance;
		}
	}
	write_vec3(point, hit.point);
	write_vec3(normal, hit.normal);
	1
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_world_overlap_sphere(
	world: Dora3DHandle,
	x: f32,
	y: f32,
	z: f32,
	radius: f32,
	bodies: *mut Dora3DHandle,
	capacity: u32,
) -> u32 {
	let hits = jolt::overlap_sphere(world, Vec3::new(x, y, z), radius);
	if !bodies.is_null() {
		let count = hits.len().min(capacity as usize);
		unsafe {
			std::ptr::copy_nonoverlapping(hits.as_ptr(), bodies, count);
		}
		return count as u32;
	}
	hits.len() as u32
}

#[no_mangle]
pub extern "C" fn dora_3d_directional_light_create(node: Dora3DHandle) -> i32 {
	light3d::create_directional(node) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_directional_light_set_color(node: Dora3DHandle, r: f32, g: f32, b: f32) {
	let _ = light3d::set_directional_color(node, Vec3::new(r, g, b));
}

#[no_mangle]
pub extern "C" fn dora_3d_directional_light_get_color(node: Dora3DHandle, out: *mut f32) {
	if let Some(color) = light3d::directional_color(node) {
		let _ = write_vec3(out, color);
	}
}

#[no_mangle]
pub extern "C" fn dora_3d_directional_light_set_intensity(node: Dora3DHandle, intensity: f32) {
	let _ = light3d::set_directional_intensity(node, intensity);
}

#[no_mangle]
pub extern "C" fn dora_3d_directional_light_get_intensity(node: Dora3DHandle) -> f32 {
	light3d::directional_intensity(node).unwrap_or(0.0)
}

#[no_mangle]
pub extern "C" fn dora_3d_directional_light_set_cast_shadow(node: Dora3DHandle, enabled: i32) {
	let _ = light3d::set_directional_cast_shadow(node, enabled != 0);
}

#[no_mangle]
pub extern "C" fn dora_3d_directional_light_get_cast_shadow(node: Dora3DHandle) -> i32 {
	light3d::directional_cast_shadow(node).unwrap_or(false) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_directional_light_set_shadow_bias(node: Dora3DHandle, bias: f32) {
	let _ = light3d::set_directional_shadow_bias(node, bias);
}

#[no_mangle]
pub extern "C" fn dora_3d_directional_light_get_shadow_bias(node: Dora3DHandle) -> f32 {
	light3d::directional_shadow_bias(node).unwrap_or(0.0)
}

#[no_mangle]
pub extern "C" fn dora_3d_directional_light_set_shadow_normal_bias(node: Dora3DHandle, bias: f32) {
	let _ = light3d::set_directional_shadow_normal_bias(node, bias);
}

#[no_mangle]
pub extern "C" fn dora_3d_directional_light_get_shadow_normal_bias(node: Dora3DHandle) -> f32 {
	light3d::directional_shadow_normal_bias(node).unwrap_or(0.0)
}

#[no_mangle]
pub extern "C" fn dora_3d_scene_has_shadow_light(root: Dora3DHandle) -> i32 {
	light3d::scene_has_shadow_light(root) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_point_light_create(node: Dora3DHandle) -> i32 {
	light3d::create_point(node) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_point_light_set_color(node: Dora3DHandle, r: f32, g: f32, b: f32) {
	let _ = light3d::set_point_color(node, Vec3::new(r, g, b));
}

#[no_mangle]
pub extern "C" fn dora_3d_point_light_get_color(node: Dora3DHandle, out: *mut f32) {
	if let Some(color) = light3d::point_color(node) {
		let _ = write_vec3(out, color);
	}
}

#[no_mangle]
pub extern "C" fn dora_3d_point_light_set_intensity(node: Dora3DHandle, intensity: f32) {
	let _ = light3d::set_point_intensity(node, intensity);
}

#[no_mangle]
pub extern "C" fn dora_3d_point_light_get_intensity(node: Dora3DHandle) -> f32 {
	light3d::point_intensity(node).unwrap_or(0.0)
}

#[no_mangle]
pub extern "C" fn dora_3d_point_light_set_range(node: Dora3DHandle, range: f32) {
	let _ = light3d::set_point_range(node, range);
}

#[no_mangle]
pub extern "C" fn dora_3d_point_light_get_range(node: Dora3DHandle) -> f32 {
	light3d::point_range(node).unwrap_or(0.0)
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
pub extern "C" fn dora_3d_parse_gltf(path: *const c_char) -> Dora3DHandle {
	let Some(path) = opt_str(path) else {
		return INVALID_HANDLE;
	};
	model_loader::parse_gltf(path).unwrap_or(INVALID_HANDLE)
}

type GltfDependencyVisitor = extern "C" fn(*const c_char, *mut c_void);

#[no_mangle]
pub extern "C" fn dora_3d_collect_gltf_dependencies(
	path: *const c_char,
	data: *const u8,
	size: usize,
	visitor: Option<GltfDependencyVisitor>,
	user_data: *mut c_void,
) -> i32 {
	let (Some(path), Some(visitor)) = (opt_str(path), visitor) else {
		return 0;
	};
	if data.is_null() && size != 0 {
		return 0;
	}
	let bytes = if size == 0 {
		&[]
	} else {
		unsafe { std::slice::from_raw_parts(data, size) }
	};
	let Some(dependencies) = model_loader::collect_gltf_dependencies(path, bytes) else {
		return 0;
	};
	for dependency in dependencies {
		let Ok(dependency) = CString::new(dependency) else {
			return 0;
		};
		visitor(dependency.as_ptr(), user_data);
	}
	1
}

#[no_mangle]
pub extern "C" fn dora_3d_collect_gltf_buffer_dependencies(
	path: *const c_char,
	data: *const u8,
	size: usize,
	visitor: Option<GltfDependencyVisitor>,
	user_data: *mut c_void,
) -> i32 {
	let (Some(path), Some(visitor)) = (opt_str(path), visitor) else {
		return 0;
	};
	if data.is_null() && size != 0 {
		return 0;
	}
	let bytes = if size == 0 {
		&[]
	} else {
		unsafe { std::slice::from_raw_parts(data, size) }
	};
	let Some(dependencies) = model_loader::collect_gltf_buffer_dependencies(path, bytes) else {
		return 0;
	};
	for dependency in dependencies {
		let Ok(dependency) = CString::new(dependency) else {
			return 0;
		};
		visitor(dependency.as_ptr(), user_data);
	}
	1
}

type GltfResourceLoader =
	extern "C" fn(*const c_char, *mut *const u8, *mut usize, *mut c_void) -> i32;

#[no_mangle]
pub extern "C" fn dora_3d_physics_shape_create_mesh_data(
	path: *const c_char,
	data: *const u8,
	size: usize,
	loader: Option<GltfResourceLoader>,
	user_data: *mut c_void,
) -> Dora3DHandle {
	let (Some(path), Some(loader)) = (opt_str(path), loader) else {
		return INVALID_HANDLE;
	};
	if data.is_null() && size != 0 {
		return INVALID_HANDLE;
	}
	let bytes = if size == 0 {
		&[]
	} else {
		unsafe { std::slice::from_raw_parts(data, size) }
	};
	let Some((vertices, indices)) =
		model_loader::parse_mesh_collider_data(path, bytes, |resource_path| {
			let path = CString::new(resource_path.to_str()?).ok()?;
			let mut resource_data = std::ptr::null();
			let mut resource_size = 0;
			if loader(
				path.as_ptr(),
				&mut resource_data,
				&mut resource_size,
				user_data,
			) == 0
			{
				return None;
			}
			if resource_data.is_null() && resource_size != 0 {
				return None;
			}
			if resource_size == 0 {
				Some(Vec::new())
			} else {
				Some(unsafe { std::slice::from_raw_parts(resource_data, resource_size) }.to_vec())
			}
		})
	else {
		return INVALID_HANDLE;
	};
	jolt::create_mesh_shape(&vertices, &indices)
}

#[no_mangle]
pub extern "C" fn dora_3d_physics_shape_create_convex_hull_data(
	path: *const c_char,
	data: *const u8,
	size: usize,
	loader: Option<GltfResourceLoader>,
	user_data: *mut c_void,
) -> Dora3DHandle {
	let (Some(path), Some(loader)) = (opt_str(path), loader) else {
		return INVALID_HANDLE;
	};
	if data.is_null() && size != 0 {
		return INVALID_HANDLE;
	}
	let bytes = if size == 0 {
		&[]
	} else {
		unsafe { std::slice::from_raw_parts(data, size) }
	};
	let Some(points) = model_loader::parse_convex_hull_data(path, bytes, |resource_path| {
		let path = CString::new(resource_path.to_str()?).ok()?;
		let mut resource_data = std::ptr::null();
		let mut resource_size = 0;
		if loader(
			path.as_ptr(),
			&mut resource_data,
			&mut resource_size,
			user_data,
		) == 0
		{
			return None;
		}
		if resource_data.is_null() && resource_size != 0 {
			return None;
		}
		if resource_size == 0 {
			Some(Vec::new())
		} else {
			Some(unsafe { std::slice::from_raw_parts(resource_data, resource_size) }.to_vec())
		}
	}) else {
		return INVALID_HANDLE;
	};
	jolt::create_convex_hull_shape(&points)
}

#[no_mangle]
pub extern "C" fn dora_3d_parse_gltf_data(
	path: *const c_char,
	data: *const u8,
	size: usize,
	loader: Option<GltfResourceLoader>,
	user_data: *mut c_void,
) -> Dora3DHandle {
	let (Some(path), Some(loader)) = (opt_str(path), loader) else {
		return INVALID_HANDLE;
	};
	if data.is_null() && size != 0 {
		return INVALID_HANDLE;
	}
	let bytes = if size == 0 {
		&[]
	} else {
		unsafe { std::slice::from_raw_parts(data, size) }
	};
	model_loader::parse_gltf_data(path, bytes, |resource_path| {
		let path = CString::new(resource_path.to_str()?).ok()?;
		let mut resource_data = std::ptr::null();
		let mut resource_size = 0;
		if loader(
			path.as_ptr(),
			&mut resource_data,
			&mut resource_size,
			user_data,
		) == 0
		{
			return None;
		}
		if resource_data.is_null() && resource_size != 0 {
			return None;
		}
		if resource_size == 0 {
			Some(Vec::new())
		} else {
			Some(unsafe { std::slice::from_raw_parts(resource_data, resource_size) }.to_vec())
		}
	})
	.unwrap_or(INVALID_HANDLE)
}

#[no_mangle]
pub extern "C" fn dora_3d_upload_gltf(prepared: Dora3DHandle) -> Dora3DHandle {
	model_loader::upload_gltf(prepared).unwrap_or(INVALID_HANDLE)
}

#[no_mangle]
pub extern "C" fn dora_3d_begin_upload_gltf(prepared: Dora3DHandle) -> Dora3DHandle {
	model_loader::begin_upload_gltf(prepared).unwrap_or(INVALID_HANDLE)
}

#[no_mangle]
pub extern "C" fn dora_3d_step_upload_gltf(
	job: Dora3DHandle,
	max_bytes: u64,
	model_out: *mut Dora3DHandle,
	uploaded_bytes: *mut u64,
) -> i32 {
	let (result, bytes) = model_loader::step_upload_gltf(job, max_bytes);
	if !uploaded_bytes.is_null() {
		unsafe { *uploaded_bytes = bytes };
	}
	match result {
		model_loader::UploadStep::Pending => 0,
		model_loader::UploadStep::Complete(model) => {
			if !model_out.is_null() {
				unsafe { *model_out = model };
			}
			1
		}
		model_loader::UploadStep::Failed => -1,
	}
}

#[no_mangle]
pub extern "C" fn dora_3d_cancel_upload_gltf(job: Dora3DHandle) {
	let _ = model_loader::cancel_upload_gltf(job);
}

#[no_mangle]
pub extern "C" fn dora_3d_discard_prepared_gltf(prepared: Dora3DHandle) {
	let _ = model_loader::discard_prepared_gltf(prepared);
}

#[no_mangle]
pub extern "C" fn dora_3d_model_destroy(model: Dora3DHandle) {
	let _ = model_loader::destroy(model);
}

#[no_mangle]
pub extern "C" fn dora_3d_model_resident_bytes(model: Dora3DHandle) -> u64 {
	model_loader::resident_bytes(model)
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
pub extern "C" fn dora_3d_model_instance_animation_count(instance: Dora3DHandle) -> u32 {
	model_loader::animation_count_instance(instance) as u32
}

#[no_mangle]
pub extern "C" fn dora_3d_model_instance_animation_name(
	instance: Dora3DHandle,
	index: u32,
	output: *mut c_char,
	capacity: u32,
) -> u32 {
	let Some(name) = model_loader::animation_name_instance(instance, index as usize) else {
		return 0;
	};
	let bytes = name.as_bytes();
	if !output.is_null() && capacity > 0 {
		let count = bytes.len().min(capacity.saturating_sub(1) as usize);
		unsafe {
			std::ptr::copy_nonoverlapping(bytes.as_ptr(), output.cast::<u8>(), count);
			*output.add(count) = 0;
		}
	}
	bytes.len() as u32
}

#[no_mangle]
pub extern "C" fn dora_3d_model_instance_has_node(
	instance: Dora3DHandle,
	name: *const c_char,
) -> i32 {
	opt_str(name)
		.and_then(|name| model_loader::find_node_instance(instance, name))
		.is_some() as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_model_instance_attach_to_node(
	instance: Dora3DHandle,
	name: *const c_char,
	child: Dora3DHandle,
) -> i32 {
	opt_str(name)
		.map(|name| model_loader::attach_to_node_instance(instance, name, child))
		.unwrap_or(false) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_model_instance_bounds(
	instance: Dora3DHandle,
	world_space: i32,
	min: *mut f32,
	max: *mut f32,
) -> i32 {
	if min.is_null() || max.is_null() {
		return 0;
	}
	let Some(bounds) = model_loader::bounds_instance(instance, world_space != 0) else {
		return 0;
	};
	unsafe {
		std::ptr::copy_nonoverlapping(bounds.min.to_array().as_ptr(), min, 3);
		std::ptr::copy_nonoverlapping(bounds.max.to_array().as_ptr(), max, 3);
	}
	1
}

#[no_mangle]
pub extern "C" fn dora_3d_model_instance_material_count(instance: Dora3DHandle) -> u32 {
	model_loader::material_count_instance(instance) as u32
}

#[no_mangle]
pub extern "C" fn dora_3d_model_instance_material_get_base_color(
	instance: Dora3DHandle,
	index: u32,
	output: *mut f32,
) -> i32 {
	if output.is_null() {
		return 0;
	}
	let Some(color) = model_loader::material_base_color_instance(instance, index as usize) else {
		return 0;
	};
	unsafe { std::ptr::copy_nonoverlapping(color.to_array().as_ptr(), output, 4) };
	1
}

#[no_mangle]
pub extern "C" fn dora_3d_model_instance_material_set_base_color(
	instance: Dora3DHandle,
	index: u32,
	r: f32,
	g: f32,
	b: f32,
	a: f32,
) -> i32 {
	model_loader::set_material_base_color_instance(instance, index as usize, Vec4::new(r, g, b, a))
		as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_model_instance_material_get_emissive(
	instance: Dora3DHandle,
	index: u32,
	output: *mut f32,
) -> i32 {
	if output.is_null() {
		return 0;
	}
	let Some(color) = model_loader::material_emissive_instance(instance, index as usize) else {
		return 0;
	};
	unsafe { std::ptr::copy_nonoverlapping(color.to_array().as_ptr(), output, 3) };
	1
}

#[no_mangle]
pub extern "C" fn dora_3d_model_instance_material_set_emissive(
	instance: Dora3DHandle,
	index: u32,
	r: f32,
	g: f32,
	b: f32,
) -> i32 {
	model_loader::set_material_emissive_instance(instance, index as usize, Vec3::new(r, g, b))
		as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_model_instance_material_get_pbr(
	instance: Dora3DHandle,
	index: u32,
	metallic: *mut f32,
	roughness: *mut f32,
) -> i32 {
	if metallic.is_null() || roughness.is_null() {
		return 0;
	}
	let Some(values) = model_loader::material_pbr_instance(instance, index as usize) else {
		return 0;
	};
	unsafe {
		*metallic = values.0;
		*roughness = values.1;
	}
	1
}

#[no_mangle]
pub extern "C" fn dora_3d_model_instance_material_set_pbr(
	instance: Dora3DHandle,
	index: u32,
	metallic: f32,
	roughness: f32,
) -> i32 {
	model_loader::set_material_pbr_instance(instance, index as usize, metallic, roughness) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_model_instance_material_get_alpha(
	instance: Dora3DHandle,
	index: u32,
	alpha_cutoff: *mut f32,
) -> i32 {
	if alpha_cutoff.is_null() {
		return -1;
	}
	let Some((mode, cutoff)) = model_loader::material_alpha_instance(instance, index as usize)
	else {
		return -1;
	};
	unsafe { *alpha_cutoff = cutoff };
	match mode {
		material::AlphaMode::Opaque => 0,
		material::AlphaMode::Mask => 1,
		material::AlphaMode::Blend => 2,
	}
}

#[no_mangle]
pub extern "C" fn dora_3d_model_instance_material_set_alpha(
	instance: Dora3DHandle,
	index: u32,
	alpha_mode: u8,
	alpha_cutoff: f32,
) -> i32 {
	let mode = match alpha_mode {
		0 => material::AlphaMode::Opaque,
		1 => material::AlphaMode::Mask,
		2 => material::AlphaMode::Blend,
		_ => return 0,
	};
	model_loader::set_material_alpha_instance(instance, index as usize, mode, alpha_cutoff) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_model_instance_material_set_texture(
	instance: Dora3DHandle,
	index: u32,
	slot: u8,
	bgfx_texture: u16,
) -> i32 {
	model_loader::set_material_texture_instance(instance, index as usize, slot, bgfx_texture) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_model_instance_ray_cast(
	instance: Dora3DHandle,
	origin_x: f32,
	origin_y: f32,
	origin_z: f32,
	direction_x: f32,
	direction_y: f32,
	direction_z: f32,
) -> f32 {
	model_loader::ray_cast_instance(
		instance,
		Vec3::new(origin_x, origin_y, origin_z),
		Vec3::new(direction_x, direction_y, direction_z),
	)
	.unwrap_or(-1.0)
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
