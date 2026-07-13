use super::node3d;
use super::types::{Quaternion, Vec3};
use super::{next_handle, Dora3DHandle, INVALID_HANDLE};
use std::collections::HashMap;
use std::ffi::c_void;
use std::sync::{Mutex, OnceLock};

const INVALID_BODY_ID: u32 = u32::MAX;

#[repr(u8)]
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum MotionType {
	Static = 0,
	Kinematic = 1,
	Dynamic = 2,
}

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum CollisionShape {
	Box { half_extent: Vec3 },
	Sphere { radius: f32 },
	Capsule { half_height: f32, radius: f32 },
}

#[derive(Clone, Copy, Debug)]
struct BodyBinding {
	native_body: u32,
	node: Dora3DHandle,
	motion: MotionType,
}

#[derive(Clone, Copy, Debug)]
struct CharacterBinding {
	native: *mut c_void,
	node: Dora3DHandle,
	desired_velocity: Vec3,
	pending_jump: f32,
}

#[derive(Clone, Copy, Debug)]
struct ConstraintBinding {
	native: *mut c_void,
	first_body: Dora3DHandle,
	second_body: Dora3DHandle,
}

#[repr(u8)]
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum CharacterGroundState {
	OnGround,
	OnSteepGround,
	NotSupported,
	InAir,
}

#[derive(Clone, Copy, Debug)]
pub struct CharacterState {
	pub velocity: Vec3,
	pub ground_state: CharacterGroundState,
	pub ground_normal: Vec3,
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default)]
struct NativeContactEvent {
	event_type: u8,
	first: u64,
	second: u64,
	point: [f32; 3],
	normal: [f32; 3],
}

#[repr(u8)]
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ContactEventType {
	Enter,
	Stay,
	Exit,
}

#[derive(Clone, Copy, Debug)]
pub struct ContactEvent {
	pub event_type: ContactEventType,
	pub body: Dora3DHandle,
	pub other: Dora3DHandle,
	pub point: Vec3,
	pub normal: Vec3,
}

#[derive(Clone, Copy, Debug)]
pub struct RaycastHit {
	pub body: Dora3DHandle,
	pub point: Vec3,
	pub normal: Vec3,
	pub distance: f32,
}

#[derive(Clone, Copy, Debug)]
pub struct CompoundShapePart {
	pub shape: Dora3DHandle,
	pub position: Vec3,
	pub rotation: Quaternion,
}

enum ShapeState {
	Native(*mut c_void),
	Compound(Vec<CompoundShapePart>),
}

struct ShapeBinding {
	state: ShapeState,
}

unsafe impl Send for ShapeBinding {}

impl Drop for ShapeBinding {
	fn drop(&mut self) {
		if let ShapeState::Native(native) = &self.state {
			unsafe { dora_jolt_shape_destroy(*native) };
		}
	}
}

pub struct PhysicsWorld3D {
	native: *mut c_void,
	bodies: HashMap<Dora3DHandle, BodyBinding>,
	characters: HashMap<Dora3DHandle, CharacterBinding>,
	constraints: HashMap<Dora3DHandle, ConstraintBinding>,
	events: Vec<ContactEvent>,
}

unsafe impl Send for PhysicsWorld3D {}

unsafe extern "C" {
	fn dora_jolt_world_create(max_bodies: u32) -> *mut c_void;
	fn dora_jolt_world_destroy(world: *mut c_void);
	fn dora_jolt_world_set_gravity(world: *mut c_void, x: f32, y: f32, z: f32);
	fn dora_jolt_world_step(world: *mut c_void, delta_time: f32);
	fn dora_jolt_world_event_count(world: *mut c_void) -> u32;
	fn dora_jolt_world_event_get(
		world: *mut c_void,
		index: u32,
		output: *mut NativeContactEvent,
	) -> bool;
	fn dora_jolt_world_event_clear(world: *mut c_void);
	fn dora_jolt_body_create_box(
		world: *mut c_void,
		half_extent: *const f32,
		motion: u8,
		position: *const f32,
		rotation: *const f32,
		user_data: u64,
	) -> u32;
	fn dora_jolt_body_create_sphere(
		world: *mut c_void,
		radius: f32,
		motion: u8,
		position: *const f32,
		rotation: *const f32,
		user_data: u64,
	) -> u32;
	fn dora_jolt_body_create_capsule(
		world: *mut c_void,
		half_height: f32,
		radius: f32,
		motion: u8,
		position: *const f32,
		rotation: *const f32,
		user_data: u64,
	) -> u32;
	fn dora_jolt_body_create_shape(
		world: *mut c_void,
		shape: *mut c_void,
		motion: u8,
		position: *const f32,
		rotation: *const f32,
		user_data: u64,
	) -> u32;
	fn dora_jolt_shape_create_box(half_extent: *const f32) -> *mut c_void;
	fn dora_jolt_shape_create_sphere(radius: f32) -> *mut c_void;
	fn dora_jolt_shape_create_capsule(half_height: f32, radius: f32) -> *mut c_void;
	fn dora_jolt_shape_create_compound(
		shapes: *const *mut c_void,
		positions: *const f32,
		rotations: *const f32,
		count: u32,
	) -> *mut c_void;
	fn dora_jolt_shape_create_mesh(
		vertices: *const f32,
		vertex_count: u32,
		indices: *const u32,
		index_count: u32,
	) -> *mut c_void;
	fn dora_jolt_shape_create_convex_hull(points: *const f32, point_count: u32) -> *mut c_void;
	fn dora_jolt_shape_destroy(shape: *mut c_void);
	fn dora_jolt_constraint_create_fixed(
		world: *mut c_void,
		first_body: u32,
		second_body: u32,
		anchor: *const f32,
	) -> *mut c_void;
	fn dora_jolt_constraint_create_distance(
		world: *mut c_void,
		first_body: u32,
		second_body: u32,
		first_anchor: *const f32,
		second_anchor: *const f32,
		min_distance: f32,
		max_distance: f32,
	) -> *mut c_void;
	fn dora_jolt_constraint_create_hinge(
		world: *mut c_void,
		first_body: u32,
		second_body: u32,
		anchor: *const f32,
		axis: *const f32,
		min_angle: f32,
		max_angle: f32,
	) -> *mut c_void;
	fn dora_jolt_constraint_destroy(world: *mut c_void, constraint: *mut c_void);
	fn dora_jolt_body_destroy(world: *mut c_void, body: u32);
	fn dora_jolt_body_set_transform(
		world: *mut c_void,
		body: u32,
		position: *const f32,
		rotation: *const f32,
		kinematic: bool,
		activate: bool,
		delta_time: f32,
	);
	fn dora_jolt_body_get_transform(
		world: *mut c_void,
		body: u32,
		position: *mut f32,
		rotation: *mut f32,
	) -> bool;
	fn dora_jolt_body_get_bounds(world: *mut c_void, body: u32, bounds: *mut f32) -> bool;
	fn dora_jolt_body_set_linear_velocity(world: *mut c_void, body: u32, velocity: *const f32);
	fn dora_jolt_body_get_linear_velocity(world: *mut c_void, body: u32, velocity: *mut f32);
	fn dora_jolt_body_set_angular_velocity(world: *mut c_void, body: u32, velocity: *const f32);
	fn dora_jolt_body_get_angular_velocity(world: *mut c_void, body: u32, velocity: *mut f32);
	fn dora_jolt_body_add_force(world: *mut c_void, body: u32, force: *const f32);
	fn dora_jolt_body_add_impulse(world: *mut c_void, body: u32, impulse: *const f32);
	fn dora_jolt_body_set_filter(world: *mut c_void, body: u32, layer: u8, mask: u32);
	fn dora_jolt_body_get_filter(world: *mut c_void, body: u32, layer: *mut u8, mask: *mut u32);
	fn dora_jolt_body_set_sensor(world: *mut c_void, body: u32, sensor: bool);
	fn dora_jolt_body_is_sensor(world: *mut c_void, body: u32) -> bool;
	fn dora_jolt_world_raycast(
		world: *mut c_void,
		origin: *const f32,
		direction: *const f32,
		distance: f32,
		body: *mut u64,
		point: *mut f32,
		normal: *mut f32,
		fraction: *mut f32,
	) -> bool;
	fn dora_jolt_world_overlap_sphere(
		world: *mut c_void,
		center: *const f32,
		radius: f32,
		bodies: *mut u64,
		capacity: u32,
	) -> u32;
	fn dora_jolt_character_create_capsule(
		world: *mut c_void,
		half_height: f32,
		radius: f32,
		position: *const f32,
		rotation: *const f32,
		max_slope_angle: f32,
		step_height: f32,
	) -> *mut c_void;
	fn dora_jolt_character_destroy(world: *mut c_void, character: *mut c_void);
	fn dora_jolt_character_update(
		world: *mut c_void,
		character: *mut c_void,
		delta_time: f32,
		desired_velocity: *const f32,
		jump_speed: f32,
	) -> bool;
	fn dora_jolt_character_get_transform(
		character: *mut c_void,
		position: *mut f32,
		rotation: *mut f32,
	) -> bool;
	fn dora_jolt_character_set_position(
		world: *mut c_void,
		character: *mut c_void,
		position: *const f32,
	) -> bool;
	fn dora_jolt_character_get_velocity(character: *mut c_void, velocity: *mut f32);
	fn dora_jolt_character_get_ground_state(character: *mut c_void) -> u8;
	fn dora_jolt_character_get_ground_normal(character: *mut c_void, normal: *mut f32);
	fn dora_jolt_character_set_filter(character: *mut c_void, layer: u8, mask: u32);
}

impl PhysicsWorld3D {
	pub fn new(max_bodies: u32) -> Option<Self> {
		let native = unsafe { dora_jolt_world_create(max_bodies) };
		(!native.is_null()).then(|| Self {
			native,
			bodies: HashMap::new(),
			characters: HashMap::new(),
			constraints: HashMap::new(),
			events: Vec::new(),
		})
	}

	pub fn set_gravity(&mut self, gravity: Vec3) {
		unsafe { dora_jolt_world_set_gravity(self.native, gravity.x, gravity.y, gravity.z) };
	}

	pub fn create_body(
		&mut self,
		node: Dora3DHandle,
		shape: CollisionShape,
		motion: MotionType,
	) -> Dora3DHandle {
		if !node3d::exists(node) || self.bodies.values().any(|binding| binding.node == node) {
			return INVALID_HANDLE;
		}
		let Some((position, rotation)) = node3d::world_position_rotation(node) else {
			return INVALID_HANDLE;
		};
		let position = position.to_array();
		let rotation = rotation.to_array();
		let handle = next_handle();
		let native_body = unsafe {
			match shape {
				CollisionShape::Box { half_extent } => {
					if half_extent.min_element() <= 0.0 {
						return INVALID_HANDLE;
					}
					dora_jolt_body_create_box(
						self.native,
						half_extent.to_array().as_ptr(),
						motion as u8,
						position.as_ptr(),
						rotation.as_ptr(),
						handle,
					)
				}
				CollisionShape::Sphere { radius } => {
					if radius <= 0.0 {
						return INVALID_HANDLE;
					}
					dora_jolt_body_create_sphere(
						self.native,
						radius,
						motion as u8,
						position.as_ptr(),
						rotation.as_ptr(),
						handle,
					)
				}
				CollisionShape::Capsule {
					half_height,
					radius,
				} => {
					if half_height <= 0.0 || radius <= 0.0 {
						return INVALID_HANDLE;
					}
					dora_jolt_body_create_capsule(
						self.native,
						half_height,
						radius,
						motion as u8,
						position.as_ptr(),
						rotation.as_ptr(),
						handle,
					)
				}
			}
		};
		if native_body == INVALID_BODY_ID {
			return INVALID_HANDLE;
		}
		self.bodies.insert(
			handle,
			BodyBinding {
				native_body,
				node,
				motion,
			},
		);
		handle
	}

	pub fn destroy_body(&mut self, handle: Dora3DHandle) -> bool {
		let attached_constraints: Vec<_> = self
			.constraints
			.iter()
			.filter_map(|(constraint, binding)| {
				(binding.first_body == handle || binding.second_body == handle)
					.then_some(*constraint)
			})
			.collect();
		for constraint in attached_constraints {
			self.destroy_constraint(constraint);
		}
		let Some(binding) = self.bodies.remove(&handle) else {
			return false;
		};
		unsafe { dora_jolt_body_destroy(self.native, binding.native_body) };
		true
	}

	pub fn sync_body_transform(&mut self, handle: Dora3DHandle) -> bool {
		let Some(binding) = self.bodies.get(&handle) else {
			return false;
		};
		let Some((position, rotation)) = node3d::world_position_rotation(binding.node) else {
			return false;
		};
		unsafe {
			dora_jolt_body_set_transform(
				self.native,
				binding.native_body,
				position.to_array().as_ptr(),
				rotation.to_array().as_ptr(),
				false,
				binding.motion == MotionType::Dynamic,
				0.0,
			)
		};
		true
	}

	fn body_pair(&self, first: Dora3DHandle, second: Dora3DHandle) -> Option<(u32, u32)> {
		if first == second {
			return None;
		}
		Some((
			self.bodies.get(&first)?.native_body,
			self.bodies.get(&second)?.native_body,
		))
	}

	fn register_constraint(
		&mut self,
		native: *mut c_void,
		first_body: Dora3DHandle,
		second_body: Dora3DHandle,
	) -> Dora3DHandle {
		if native.is_null() {
			return INVALID_HANDLE;
		}
		let handle = next_handle();
		self.constraints.insert(
			handle,
			ConstraintBinding {
				native,
				first_body,
				second_body,
			},
		);
		handle
	}

	pub fn create_fixed_constraint(
		&mut self,
		first: Dora3DHandle,
		second: Dora3DHandle,
		anchor: Vec3,
	) -> Dora3DHandle {
		let Some((first_native, second_native)) = self.body_pair(first, second) else {
			return INVALID_HANDLE;
		};
		let native = unsafe {
			dora_jolt_constraint_create_fixed(
				self.native,
				first_native,
				second_native,
				anchor.to_array().as_ptr(),
			)
		};
		self.register_constraint(native, first, second)
	}

	pub fn create_distance_constraint(
		&mut self,
		first: Dora3DHandle,
		second: Dora3DHandle,
		first_anchor: Vec3,
		second_anchor: Vec3,
		min_distance: f32,
		max_distance: f32,
	) -> Dora3DHandle {
		let Some((first_native, second_native)) = self.body_pair(first, second) else {
			return INVALID_HANDLE;
		};
		let native = unsafe {
			dora_jolt_constraint_create_distance(
				self.native,
				first_native,
				second_native,
				first_anchor.to_array().as_ptr(),
				second_anchor.to_array().as_ptr(),
				min_distance,
				max_distance,
			)
		};
		self.register_constraint(native, first, second)
	}

	pub fn create_hinge_constraint(
		&mut self,
		first: Dora3DHandle,
		second: Dora3DHandle,
		anchor: Vec3,
		axis: Vec3,
		min_angle: f32,
		max_angle: f32,
	) -> Dora3DHandle {
		let Some((first_native, second_native)) = self.body_pair(first, second) else {
			return INVALID_HANDLE;
		};
		let native = unsafe {
			dora_jolt_constraint_create_hinge(
				self.native,
				first_native,
				second_native,
				anchor.to_array().as_ptr(),
				axis.to_array().as_ptr(),
				min_angle,
				max_angle,
			)
		};
		self.register_constraint(native, first, second)
	}

	pub fn destroy_constraint(&mut self, handle: Dora3DHandle) -> bool {
		let Some(binding) = self.constraints.remove(&handle) else {
			return false;
		};
		unsafe { dora_jolt_constraint_destroy(self.native, binding.native) };
		true
	}

	fn create_body_with_native_shape(
		&mut self,
		node: Dora3DHandle,
		native_shape: *mut c_void,
		motion: MotionType,
	) -> Dora3DHandle {
		if native_shape.is_null()
			|| !node3d::exists(node)
			|| self.bodies.values().any(|binding| binding.node == node)
			|| self.characters.values().any(|binding| binding.node == node)
		{
			return INVALID_HANDLE;
		}
		let Some((position, rotation)) = node3d::world_position_rotation(node) else {
			return INVALID_HANDLE;
		};
		let handle = next_handle();
		let native_body = unsafe {
			dora_jolt_body_create_shape(
				self.native,
				native_shape,
				motion as u8,
				position.to_array().as_ptr(),
				rotation.to_array().as_ptr(),
				handle,
			)
		};
		if native_body == INVALID_BODY_ID {
			return INVALID_HANDLE;
		}
		self.bodies.insert(
			handle,
			BodyBinding {
				native_body,
				node,
				motion,
			},
		);
		handle
	}

	pub fn create_character_capsule(
		&mut self,
		node: Dora3DHandle,
		half_height: f32,
		radius: f32,
		max_slope_angle: f32,
		step_height: f32,
	) -> Dora3DHandle {
		if half_height <= 0.0
			|| radius <= 0.0
			|| !node3d::exists(node)
			|| self.characters.values().any(|binding| binding.node == node)
			|| self.bodies.values().any(|binding| binding.node == node)
		{
			return INVALID_HANDLE;
		}
		let Some((position, rotation)) = node3d::world_position_rotation(node) else {
			return INVALID_HANDLE;
		};
		let native = unsafe {
			dora_jolt_character_create_capsule(
				self.native,
				half_height,
				radius,
				position.to_array().as_ptr(),
				rotation.to_array().as_ptr(),
				max_slope_angle,
				step_height,
			)
		};
		if native.is_null() {
			return INVALID_HANDLE;
		}
		let handle = next_handle();
		self.characters.insert(
			handle,
			CharacterBinding {
				native,
				node,
				desired_velocity: Vec3::ZERO,
				pending_jump: 0.0,
			},
		);
		handle
	}

	pub fn destroy_character(&mut self, handle: Dora3DHandle) -> bool {
		let Some(binding) = self.characters.remove(&handle) else {
			return false;
		};
		unsafe { dora_jolt_character_destroy(self.native, binding.native) };
		true
	}

	pub fn set_character_velocity(&mut self, handle: Dora3DHandle, velocity: Vec3) -> bool {
		let Some(binding) = self.characters.get_mut(&handle) else {
			return false;
		};
		binding.desired_velocity = velocity;
		true
	}

	pub fn jump_character(&mut self, handle: Dora3DHandle, speed: f32) -> bool {
		let Some(binding) = self.characters.get_mut(&handle) else {
			return false;
		};
		if speed <= 0.0 {
			return false;
		}
		binding.pending_jump = speed;
		true
	}

	pub fn set_character_filter(&mut self, handle: Dora3DHandle, layer: u8, mask: u32) -> bool {
		if layer >= 32 {
			return false;
		}
		let Some(binding) = self.characters.get(&handle) else {
			return false;
		};
		unsafe { dora_jolt_character_set_filter(binding.native, layer, mask) };
		true
	}

	pub fn character_state(&self, handle: Dora3DHandle) -> Option<CharacterState> {
		let binding = self.characters.get(&handle)?;
		let mut velocity = [0.0; 3];
		let mut normal = [0.0; 3];
		unsafe {
			dora_jolt_character_get_velocity(binding.native, velocity.as_mut_ptr());
			dora_jolt_character_get_ground_normal(binding.native, normal.as_mut_ptr());
		}
		let ground_state = match unsafe { dora_jolt_character_get_ground_state(binding.native) } {
			0 => CharacterGroundState::OnGround,
			1 => CharacterGroundState::OnSteepGround,
			2 => CharacterGroundState::NotSupported,
			_ => CharacterGroundState::InAir,
		};
		Some(CharacterState {
			velocity: Vec3::from_array(velocity),
			ground_state,
			ground_normal: Vec3::from_array(normal),
		})
	}

	pub fn fixed_update(&mut self, delta_time: f32) {
		let missing: Vec<_> = self
			.bodies
			.iter()
			.filter_map(|(handle, binding)| (!node3d::exists(binding.node)).then_some(*handle))
			.collect();
		for handle in missing {
			self.destroy_body(handle);
		}
		let missing_characters: Vec<_> = self
			.characters
			.iter()
			.filter_map(|(handle, binding)| (!node3d::exists(binding.node)).then_some(*handle))
			.collect();
		for handle in missing_characters {
			self.destroy_character(handle);
		}

		for binding in self.bodies.values() {
			if binding.motion == MotionType::Dynamic {
				continue;
			}
			let Some((position, rotation)) = node3d::world_position_rotation(binding.node) else {
				continue;
			};
			unsafe {
				dora_jolt_body_set_transform(
					self.native,
					binding.native_body,
					position.to_array().as_ptr(),
					rotation.to_array().as_ptr(),
					binding.motion == MotionType::Kinematic,
					false,
					delta_time,
				)
			};
		}

		for binding in self.characters.values_mut() {
			if let Some((node_position, _)) = node3d::world_position_rotation(binding.node) {
				let mut character_position = [0.0; 3];
				let mut character_rotation = [0.0; 4];
				if unsafe {
					dora_jolt_character_get_transform(
						binding.native,
						character_position.as_mut_ptr(),
						character_rotation.as_mut_ptr(),
					)
				} && node_position.distance_squared(Vec3::from_array(character_position))
					> 1.0e-8
				{
					unsafe {
						dora_jolt_character_set_position(
							self.native,
							binding.native,
							node_position.to_array().as_ptr(),
						)
					};
					binding.pending_jump = 0.0;
				}
			}
			unsafe {
				dora_jolt_character_update(
					self.native,
					binding.native,
					delta_time,
					binding.desired_velocity.to_array().as_ptr(),
					binding.pending_jump,
				)
			};
			binding.pending_jump = 0.0;
		}

		unsafe { dora_jolt_world_step(self.native, delta_time) };
		self.collect_contact_events();

		for binding in self.bodies.values() {
			if binding.motion != MotionType::Dynamic {
				continue;
			}
			let mut position = [0.0; 3];
			let mut rotation = [0.0; 4];
			if unsafe {
				dora_jolt_body_get_transform(
					self.native,
					binding.native_body,
					position.as_mut_ptr(),
					rotation.as_mut_ptr(),
				)
			} {
				let _ = node3d::set_world_position_rotation(
					binding.node,
					Vec3::from_array(position),
					Quaternion::from_array(rotation),
				);
			}
		}
		for binding in self.characters.values() {
			let mut position = [0.0; 3];
			let mut rotation = [0.0; 4];
			if unsafe {
				dora_jolt_character_get_transform(
					binding.native,
					position.as_mut_ptr(),
					rotation.as_mut_ptr(),
				)
			} {
				let _ = node3d::set_world_position_rotation(
					binding.node,
					Vec3::from_array(position),
					Quaternion::from_array(rotation),
				);
			}
		}
	}

	fn collect_contact_events(&mut self) {
		self.events.clear();
		let count = unsafe { dora_jolt_world_event_count(self.native) };
		self.events.reserve(count as usize * 2);
		for index in 0..count {
			let mut event = NativeContactEvent::default();
			if !unsafe { dora_jolt_world_event_get(self.native, index, &mut event) } {
				continue;
			}
			if !self.bodies.contains_key(&event.first) || !self.bodies.contains_key(&event.second) {
				continue;
			}
			let event_type = match event.event_type {
				0 => ContactEventType::Enter,
				1 => ContactEventType::Stay,
				_ => ContactEventType::Exit,
			};
			let point = Vec3::from_array(event.point);
			let normal = Vec3::from_array(event.normal);
			self.events.push(ContactEvent {
				event_type,
				body: event.first,
				other: event.second,
				point,
				normal,
			});
			self.events.push(ContactEvent {
				event_type,
				body: event.second,
				other: event.first,
				point,
				normal: -normal,
			});
		}
		unsafe { dora_jolt_world_event_clear(self.native) };
	}

	pub fn events(&self) -> &[ContactEvent] {
		&self.events
	}

	fn binding(&self, body: Dora3DHandle) -> Option<BodyBinding> {
		self.bodies.get(&body).copied()
	}

	pub fn set_linear_velocity(&mut self, body: Dora3DHandle, velocity: Vec3) -> bool {
		let Some(binding) = self.binding(body) else {
			return false;
		};
		unsafe {
			dora_jolt_body_set_linear_velocity(
				self.native,
				binding.native_body,
				velocity.to_array().as_ptr(),
			)
		};
		true
	}

	pub fn linear_velocity(&self, body: Dora3DHandle) -> Option<Vec3> {
		let binding = self.binding(body)?;
		let mut value = [0.0; 3];
		unsafe {
			dora_jolt_body_get_linear_velocity(self.native, binding.native_body, value.as_mut_ptr())
		};
		Some(Vec3::from_array(value))
	}

	pub fn set_angular_velocity(&mut self, body: Dora3DHandle, velocity: Vec3) -> bool {
		let Some(binding) = self.binding(body) else {
			return false;
		};
		unsafe {
			dora_jolt_body_set_angular_velocity(
				self.native,
				binding.native_body,
				velocity.to_array().as_ptr(),
			)
		};
		true
	}

	pub fn angular_velocity(&self, body: Dora3DHandle) -> Option<Vec3> {
		let binding = self.binding(body)?;
		let mut value = [0.0; 3];
		unsafe {
			dora_jolt_body_get_angular_velocity(
				self.native,
				binding.native_body,
				value.as_mut_ptr(),
			)
		};
		Some(Vec3::from_array(value))
	}

	pub fn body_bounds(&self, body: Dora3DHandle) -> Option<(Vec3, Vec3)> {
		let binding = self.binding(body)?;
		let mut bounds = [0.0; 6];
		if unsafe {
			dora_jolt_body_get_bounds(self.native, binding.native_body, bounds.as_mut_ptr())
		} {
			Some((
				Vec3::new(bounds[0], bounds[1], bounds[2]),
				Vec3::new(bounds[3], bounds[4], bounds[5]),
			))
		} else {
			None
		}
	}

	pub fn apply_force(&mut self, body: Dora3DHandle, force: Vec3) -> bool {
		let Some(binding) = self.binding(body) else {
			return false;
		};
		unsafe {
			dora_jolt_body_add_force(self.native, binding.native_body, force.to_array().as_ptr())
		};
		true
	}

	pub fn apply_impulse(&mut self, body: Dora3DHandle, impulse: Vec3) -> bool {
		let Some(binding) = self.binding(body) else {
			return false;
		};
		unsafe {
			dora_jolt_body_add_impulse(
				self.native,
				binding.native_body,
				impulse.to_array().as_ptr(),
			)
		};
		true
	}

	pub fn set_filter(&mut self, body: Dora3DHandle, layer: u8, mask: u32) -> bool {
		if layer >= 32 {
			return false;
		}
		let Some(binding) = self.binding(body) else {
			return false;
		};
		unsafe { dora_jolt_body_set_filter(self.native, binding.native_body, layer, mask) };
		true
	}

	pub fn filter(&self, body: Dora3DHandle) -> Option<(u8, u32)> {
		let binding = self.binding(body)?;
		let mut layer = 0;
		let mut mask = 0;
		unsafe {
			dora_jolt_body_get_filter(self.native, binding.native_body, &mut layer, &mut mask)
		};
		Some((layer, mask))
	}

	pub fn set_sensor(&mut self, body: Dora3DHandle, sensor: bool) -> bool {
		let Some(binding) = self.binding(body) else {
			return false;
		};
		unsafe { dora_jolt_body_set_sensor(self.native, binding.native_body, sensor) };
		true
	}

	pub fn is_sensor(&self, body: Dora3DHandle) -> Option<bool> {
		let binding = self.binding(body)?;
		Some(unsafe { dora_jolt_body_is_sensor(self.native, binding.native_body) })
	}

	pub fn raycast(&self, origin: Vec3, direction: Vec3, distance: f32) -> Option<RaycastHit> {
		let mut body = INVALID_HANDLE;
		let mut point = [0.0; 3];
		let mut normal = [0.0; 3];
		let mut fraction = 0.0;
		if !unsafe {
			dora_jolt_world_raycast(
				self.native,
				origin.to_array().as_ptr(),
				direction.to_array().as_ptr(),
				distance,
				&mut body,
				point.as_mut_ptr(),
				normal.as_mut_ptr(),
				&mut fraction,
			)
		} || !self.bodies.contains_key(&body)
		{
			return None;
		}
		Some(RaycastHit {
			body,
			point: Vec3::from_array(point),
			normal: Vec3::from_array(normal),
			distance: fraction * distance,
		})
	}

	pub fn overlap_sphere(&self, center: Vec3, radius: f32) -> Vec<Dora3DHandle> {
		let center = center.to_array();
		let count = unsafe {
			dora_jolt_world_overlap_sphere(
				self.native,
				center.as_ptr(),
				radius,
				std::ptr::null_mut(),
				0,
			)
		};
		let mut bodies = vec![INVALID_HANDLE; count as usize];
		let written = unsafe {
			dora_jolt_world_overlap_sphere(
				self.native,
				center.as_ptr(),
				radius,
				bodies.as_mut_ptr(),
				count,
			)
		};
		bodies.truncate(written as usize);
		bodies.retain(|body| self.bodies.contains_key(body));
		bodies
	}

	fn destroy_node(&mut self, node: Dora3DHandle) {
		let bodies: Vec<_> = self
			.bodies
			.iter()
			.filter_map(|(handle, binding)| (binding.node == node).then_some(*handle))
			.collect();
		for body in bodies {
			self.destroy_body(body);
		}
		let characters: Vec<_> = self
			.characters
			.iter()
			.filter_map(|(handle, binding)| (binding.node == node).then_some(*handle))
			.collect();
		for character in characters {
			self.destroy_character(character);
		}
	}
}

impl Drop for PhysicsWorld3D {
	fn drop(&mut self) {
		for (_, binding) in self.constraints.drain() {
			unsafe { dora_jolt_constraint_destroy(self.native, binding.native) };
		}
		unsafe { dora_jolt_world_destroy(self.native) };
	}
}

fn shapes() -> &'static Mutex<HashMap<Dora3DHandle, ShapeBinding>> {
	static SHAPES: OnceLock<Mutex<HashMap<Dora3DHandle, ShapeBinding>>> = OnceLock::new();
	SHAPES.get_or_init(|| Mutex::new(HashMap::new()))
}

fn register_shape(native: *mut c_void) -> Dora3DHandle {
	if native.is_null() {
		return INVALID_HANDLE;
	}
	let handle = next_handle();
	shapes().lock().unwrap().insert(
		handle,
		ShapeBinding {
			state: ShapeState::Native(native),
		},
	);
	handle
}

pub fn create_compound_shape_builder() -> Dora3DHandle {
	let handle = next_handle();
	shapes().lock().unwrap().insert(
		handle,
		ShapeBinding {
			state: ShapeState::Compound(Vec::new()),
		},
	);
	handle
}

pub fn add_compound_shape_part(
	compound: Dora3DHandle,
	shape: Dora3DHandle,
	position: Vec3,
	rotation: Quaternion,
) -> bool {
	let mut registry = shapes().lock().unwrap();
	if !matches!(
		registry.get(&shape).map(|shape| &shape.state),
		Some(ShapeState::Native(_))
	) {
		return false;
	}
	let Some(ShapeBinding {
		state: ShapeState::Compound(parts),
	}) = registry.get_mut(&compound)
	else {
		return false;
	};
	parts.push(CompoundShapePart {
		shape,
		position,
		rotation,
	});
	true
}

pub fn build_compound_shape(compound: Dora3DHandle) -> bool {
	let mut registry = shapes().lock().unwrap();
	let Some(ShapeBinding {
		state: ShapeState::Compound(parts),
	}) = registry.get(&compound)
	else {
		return false;
	};
	if parts.is_empty() {
		return false;
	}
	let parts = parts.clone();
	let mut native_shapes = Vec::with_capacity(parts.len());
	let mut positions = Vec::with_capacity(parts.len() * 3);
	let mut rotations = Vec::with_capacity(parts.len() * 4);
	for part in &parts {
		let Some(ShapeBinding {
			state: ShapeState::Native(native),
		}) = registry.get(&part.shape)
		else {
			return false;
		};
		native_shapes.push(*native);
		positions.extend_from_slice(&part.position.to_array());
		rotations.extend_from_slice(&part.rotation.to_array());
	}
	let native = unsafe {
		dora_jolt_shape_create_compound(
			native_shapes.as_ptr(),
			positions.as_ptr(),
			rotations.as_ptr(),
			parts.len() as u32,
		)
	};
	if native.is_null() {
		return false;
	}
	registry.get_mut(&compound).unwrap().state = ShapeState::Native(native);
	true
}

pub fn shape_is_built(shape: Dora3DHandle) -> bool {
	shapes()
		.lock()
		.unwrap()
		.get(&shape)
		.is_some_and(|shape| matches!(&shape.state, ShapeState::Native(_)))
}

pub fn create_box_shape(half_extent: Vec3) -> Dora3DHandle {
	if half_extent.min_element() <= 0.0 {
		return INVALID_HANDLE;
	}
	register_shape(unsafe { dora_jolt_shape_create_box(half_extent.to_array().as_ptr()) })
}

pub fn create_sphere_shape(radius: f32) -> Dora3DHandle {
	if radius <= 0.0 {
		return INVALID_HANDLE;
	}
	register_shape(unsafe { dora_jolt_shape_create_sphere(radius) })
}

pub fn create_capsule_shape(half_height: f32, radius: f32) -> Dora3DHandle {
	if half_height < 0.0 || radius <= 0.0 {
		return INVALID_HANDLE;
	}
	register_shape(unsafe { dora_jolt_shape_create_capsule(half_height, radius) })
}

pub fn create_mesh_shape(vertices: &[[f32; 3]], indices: &[u32]) -> Dora3DHandle {
	if vertices.len() < 3
		|| indices.len() < 3
		|| !indices.len().is_multiple_of(3)
		|| vertices.len() > u32::MAX as usize
		|| indices.len() > u32::MAX as usize
	{
		return INVALID_HANDLE;
	}
	register_shape(unsafe {
		dora_jolt_shape_create_mesh(
			vertices.as_ptr().cast(),
			vertices.len() as u32,
			indices.as_ptr(),
			indices.len() as u32,
		)
	})
}

pub fn create_convex_hull_shape(points: &[[f32; 3]]) -> Dora3DHandle {
	if points.len() < 4
		|| points.len() > u32::MAX as usize
		|| points.iter().flatten().any(|value| !value.is_finite())
	{
		return INVALID_HANDLE;
	}
	register_shape(unsafe {
		dora_jolt_shape_create_convex_hull(points.as_ptr().cast(), points.len() as u32)
	})
}

pub fn create_compound_shape(parts: &[CompoundShapePart]) -> Dora3DHandle {
	if parts.is_empty() {
		return INVALID_HANDLE;
	}
	let registry = shapes().lock().unwrap();
	let mut native_shapes = Vec::with_capacity(parts.len());
	let mut positions = Vec::with_capacity(parts.len() * 3);
	let mut rotations = Vec::with_capacity(parts.len() * 4);
	for part in parts {
		let Some(ShapeBinding {
			state: ShapeState::Native(native),
		}) = registry.get(&part.shape)
		else {
			return INVALID_HANDLE;
		};
		native_shapes.push(*native);
		positions.extend_from_slice(&part.position.to_array());
		rotations.extend_from_slice(&part.rotation.to_array());
	}
	let native = unsafe {
		dora_jolt_shape_create_compound(
			native_shapes.as_ptr(),
			positions.as_ptr(),
			rotations.as_ptr(),
			parts.len() as u32,
		)
	};
	drop(registry);
	register_shape(native)
}

pub fn destroy_shape(shape: Dora3DHandle) -> bool {
	shapes().lock().unwrap().remove(&shape).is_some()
}

fn worlds() -> &'static Mutex<HashMap<Dora3DHandle, PhysicsWorld3D>> {
	static WORLDS: OnceLock<Mutex<HashMap<Dora3DHandle, PhysicsWorld3D>>> = OnceLock::new();
	WORLDS.get_or_init(|| Mutex::new(HashMap::new()))
}

pub fn create_world(max_bodies: u32) -> Dora3DHandle {
	let Some(world) = PhysicsWorld3D::new(max_bodies) else {
		return INVALID_HANDLE;
	};
	let handle = next_handle();
	worlds().lock().unwrap().insert(handle, world);
	handle
}

pub fn destroy_world(handle: Dora3DHandle) -> bool {
	worlds().lock().unwrap().remove(&handle).is_some()
}

pub fn set_gravity(handle: Dora3DHandle, gravity: Vec3) -> bool {
	let mut worlds = worlds().lock().unwrap();
	let Some(world) = worlds.get_mut(&handle) else {
		return false;
	};
	world.set_gravity(gravity);
	true
}

pub fn create_body(
	world: Dora3DHandle,
	node: Dora3DHandle,
	shape: CollisionShape,
	motion: MotionType,
) -> Dora3DHandle {
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| world.create_body(node, shape, motion))
		.unwrap_or(INVALID_HANDLE)
}

pub fn create_body_with_shape(
	world: Dora3DHandle,
	node: Dora3DHandle,
	shape: Dora3DHandle,
	motion: MotionType,
) -> Dora3DHandle {
	let native_shape = shapes()
		.lock()
		.unwrap()
		.get(&shape)
		.and_then(|shape| match &shape.state {
			ShapeState::Native(native) => Some(*native),
			ShapeState::Compound(_) => None,
		})
		.unwrap_or(std::ptr::null_mut());
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| world.create_body_with_native_shape(node, native_shape, motion))
		.unwrap_or(INVALID_HANDLE)
}

pub fn destroy_body(world: Dora3DHandle, body: Dora3DHandle) -> bool {
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| world.destroy_body(body))
		.unwrap_or(false)
}

pub fn sync_body_transform(world: Dora3DHandle, body: Dora3DHandle) -> bool {
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| world.sync_body_transform(body))
		.unwrap_or(false)
}

pub fn create_fixed_constraint(
	world: Dora3DHandle,
	first: Dora3DHandle,
	second: Dora3DHandle,
	anchor: Vec3,
) -> Dora3DHandle {
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| world.create_fixed_constraint(first, second, anchor))
		.unwrap_or(INVALID_HANDLE)
}

pub fn create_distance_constraint(
	world: Dora3DHandle,
	first: Dora3DHandle,
	second: Dora3DHandle,
	first_anchor: Vec3,
	second_anchor: Vec3,
	min_distance: f32,
	max_distance: f32,
) -> Dora3DHandle {
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| {
			world.create_distance_constraint(
				first,
				second,
				first_anchor,
				second_anchor,
				min_distance,
				max_distance,
			)
		})
		.unwrap_or(INVALID_HANDLE)
}

pub fn create_hinge_constraint(
	world: Dora3DHandle,
	first: Dora3DHandle,
	second: Dora3DHandle,
	anchor: Vec3,
	axis: Vec3,
	min_angle: f32,
	max_angle: f32,
) -> Dora3DHandle {
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| {
			world.create_hinge_constraint(first, second, anchor, axis, min_angle, max_angle)
		})
		.unwrap_or(INVALID_HANDLE)
}

pub fn destroy_constraint(world: Dora3DHandle, constraint: Dora3DHandle) -> bool {
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| world.destroy_constraint(constraint))
		.unwrap_or(false)
}

pub fn create_character_capsule(
	world: Dora3DHandle,
	node: Dora3DHandle,
	half_height: f32,
	radius: f32,
	max_slope_angle: f32,
	step_height: f32,
) -> Dora3DHandle {
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| {
			world.create_character_capsule(node, half_height, radius, max_slope_angle, step_height)
		})
		.unwrap_or(INVALID_HANDLE)
}

pub fn destroy_character(world: Dora3DHandle, character: Dora3DHandle) -> bool {
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| world.destroy_character(character))
		.unwrap_or(false)
}

pub fn set_character_velocity(
	world: Dora3DHandle,
	character: Dora3DHandle,
	velocity: Vec3,
) -> bool {
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| world.set_character_velocity(character, velocity))
		.unwrap_or(false)
}

pub fn jump_character(world: Dora3DHandle, character: Dora3DHandle, speed: f32) -> bool {
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| world.jump_character(character, speed))
		.unwrap_or(false)
}

pub fn set_character_filter(
	world: Dora3DHandle,
	character: Dora3DHandle,
	layer: u8,
	mask: u32,
) -> bool {
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| world.set_character_filter(character, layer, mask))
		.unwrap_or(false)
}

pub fn character_state(world: Dora3DHandle, character: Dora3DHandle) -> Option<CharacterState> {
	worlds()
		.lock()
		.unwrap()
		.get(&world)
		.and_then(|world| world.character_state(character))
}

pub fn fixed_update(world: Dora3DHandle, delta_time: f32) -> bool {
	let mut worlds = worlds().lock().unwrap();
	let Some(world) = worlds.get_mut(&world) else {
		return false;
	};
	world.fixed_update(delta_time);
	true
}

pub fn events(world: Dora3DHandle) -> Vec<ContactEvent> {
	worlds()
		.lock()
		.unwrap()
		.get(&world)
		.map(|world| world.events.clone())
		.unwrap_or_default()
}

pub fn event_count(world: Dora3DHandle) -> usize {
	worlds()
		.lock()
		.unwrap()
		.get(&world)
		.map(|world| world.events.len())
		.unwrap_or(0)
}

pub fn event(world: Dora3DHandle, index: usize) -> Option<ContactEvent> {
	worlds()
		.lock()
		.unwrap()
		.get(&world)
		.and_then(|world| world.events.get(index).copied())
}

pub fn clear_events(world: Dora3DHandle) {
	if let Some(world) = worlds().lock().unwrap().get_mut(&world) {
		world.events.clear();
	}
}

pub fn set_linear_velocity(world: Dora3DHandle, body: Dora3DHandle, velocity: Vec3) -> bool {
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| world.set_linear_velocity(body, velocity))
		.unwrap_or(false)
}

pub fn linear_velocity(world: Dora3DHandle, body: Dora3DHandle) -> Option<Vec3> {
	worlds()
		.lock()
		.unwrap()
		.get(&world)
		.and_then(|world| world.linear_velocity(body))
}

pub fn set_angular_velocity(world: Dora3DHandle, body: Dora3DHandle, velocity: Vec3) -> bool {
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| world.set_angular_velocity(body, velocity))
		.unwrap_or(false)
}

pub fn angular_velocity(world: Dora3DHandle, body: Dora3DHandle) -> Option<Vec3> {
	worlds()
		.lock()
		.unwrap()
		.get(&world)
		.and_then(|world| world.angular_velocity(body))
}

pub fn body_bounds(world: Dora3DHandle, body: Dora3DHandle) -> Option<(Vec3, Vec3)> {
	worlds()
		.lock()
		.unwrap()
		.get(&world)
		.and_then(|world| world.body_bounds(body))
}

pub fn apply_force(world: Dora3DHandle, body: Dora3DHandle, force: Vec3) -> bool {
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| world.apply_force(body, force))
		.unwrap_or(false)
}

pub fn apply_impulse(world: Dora3DHandle, body: Dora3DHandle, impulse: Vec3) -> bool {
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| world.apply_impulse(body, impulse))
		.unwrap_or(false)
}

pub fn set_filter(world: Dora3DHandle, body: Dora3DHandle, layer: u8, mask: u32) -> bool {
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| world.set_filter(body, layer, mask))
		.unwrap_or(false)
}

pub fn filter(world: Dora3DHandle, body: Dora3DHandle) -> Option<(u8, u32)> {
	worlds()
		.lock()
		.unwrap()
		.get(&world)
		.and_then(|world| world.filter(body))
}

pub fn set_sensor(world: Dora3DHandle, body: Dora3DHandle, sensor: bool) -> bool {
	worlds()
		.lock()
		.unwrap()
		.get_mut(&world)
		.map(|world| world.set_sensor(body, sensor))
		.unwrap_or(false)
}

pub fn is_sensor(world: Dora3DHandle, body: Dora3DHandle) -> Option<bool> {
	worlds()
		.lock()
		.unwrap()
		.get(&world)
		.and_then(|world| world.is_sensor(body))
}

pub fn raycast(
	world: Dora3DHandle,
	origin: Vec3,
	direction: Vec3,
	distance: f32,
) -> Option<RaycastHit> {
	worlds()
		.lock()
		.unwrap()
		.get(&world)
		.and_then(|world| world.raycast(origin, direction, distance))
}

pub fn overlap_sphere(world: Dora3DHandle, center: Vec3, radius: f32) -> Vec<Dora3DHandle> {
	worlds()
		.lock()
		.unwrap()
		.get(&world)
		.map(|world| world.overlap_sphere(center, radius))
		.unwrap_or_default()
}

pub fn destroy_node(node: Dora3DHandle) {
	for world in worlds().lock().unwrap().values_mut() {
		world.destroy_node(node);
	}
}

pub fn clear_registry() {
	worlds().lock().unwrap().clear();
	shapes().lock().unwrap().clear();
}
