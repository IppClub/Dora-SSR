extern "C" {
	fn physicsworld_type() -> i32;
	fn physicsworld_set_show_debug(slf: i64, var: i32);
	fn physicsworld_is_show_debug(slf: i64) -> i32;
	fn physicsworld_query(slf: i64, rect: i64, func: i32, stack: i64) -> i32;
	fn physicsworld_raycast(slf: i64, start: i64, stop: i64, closest: i32, func: i32, stack: i64) -> i32;
	fn physicsworld_set_iterations(slf: i64, velocity_iter: i32, position_iter: i32);
	fn physicsworld_set_should_contact(slf: i64, group_a: i32, group_b: i32, contact: i32);
	fn physicsworld_get_should_contact(slf: i64, group_a: i32, group_b: i32) -> i32;
	fn physicsworld_set_scale_factor(var: f32);
	fn physicsworld_get_scale_factor() -> f32;
	fn physicsworld_new() -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for PhysicsWorld { }
/// A struct that represents a physics world in the game.
pub struct PhysicsWorld { raw: i64 }
crate::dora_object!(PhysicsWorld);
impl IPhysicsWorld for PhysicsWorld { }
pub trait IPhysicsWorld: INode {
	/// Sets whether debug graphic should be displayed for the physics world.
	fn set_show_debug(&mut self, var: bool) {
		unsafe { physicsworld_set_show_debug(self.raw(), if var { 1 } else { 0 }) };
	}
	/// Gets whether debug graphic should be displayed for the physics world.
	fn is_show_debug(&self) -> bool {
		return unsafe { physicsworld_is_show_debug(self.raw()) != 0 };
	}
	/// Queries the physics world for all bodies that intersect with the specified rectangle.
	///
	/// # Arguments
	///
	/// * `rect` - The rectangle to query for bodies.
	/// * `handler` - A function that is called for each body found in the query. The function takes a `Body` as an argument and returns a `bool` indicating whether to continue querying for more bodies. Return `false` to continue, `true` to stop.
	///
	/// # Returns
	///
	/// * `bool` - Whether the query was interrupted. `true` means interrupted, `false` otherwise.
	fn query(&mut self, rect: &crate::dora::Rect, mut handler: Box<dyn FnMut(&dyn crate::dora::IBody) -> bool>) -> bool {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = handler(&stack.pop_cast::<crate::dora::Body>().unwrap());
			stack.push_bool(result);
		}));
		unsafe { return physicsworld_query(self.raw(), rect.raw(), func_id, stack_raw) != 0; }
	}
	/// Casts a ray through the physics world and finds the first body that intersects with the ray.
	///
	/// # Arguments
	///
	/// * `start` - The starting point of the ray.
	/// * `stop` - The ending point of the ray.
	/// * `closest` - Whether to stop ray casting upon the closest body that intersects with the ray. Set `closest` to `true` to get a faster ray casting search.
	/// * `handler` - A function that is called for each body found in the raycast. The function takes a `Body`, a `Vec2` representing the point where the ray intersects with the body, and a `Vec2` representing the normal vector at the point of intersection as arguments, and returns a `bool` indicating whether to continue casting the ray for more bodies. Return `false` to continue, `true` to stop.
	///
	/// # Returns
	///
	/// * `bool` - Whether the raycast was interrupted. `true` means interrupted, `false` otherwise.
	fn raycast(&mut self, start: &crate::dora::Vec2, stop: &crate::dora::Vec2, closest: bool, mut handler: Box<dyn FnMut(&dyn crate::dora::IBody, &crate::dora::Vec2, &crate::dora::Vec2) -> bool>) -> bool {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = handler(&stack.pop_cast::<crate::dora::Body>().unwrap(), &stack.pop_vec2().unwrap(), &stack.pop_vec2().unwrap());
			stack.push_bool(result);
		}));
		unsafe { return physicsworld_raycast(self.raw(), start.into_i64(), stop.into_i64(), if closest { 1 } else { 0 }, func_id, stack_raw) != 0; }
	}
	/// Sets the number of velocity and position iterations to perform in the physics world.
	///
	/// # Arguments
	///
	/// * `velocity_iter` - The number of velocity iterations to perform.
	/// * `position_iter` - The number of position iterations to perform.
	fn set_iterations(&mut self, velocity_iter: i32, position_iter: i32) {
		unsafe { physicsworld_set_iterations(self.raw(), velocity_iter, position_iter); }
	}
	/// Sets whether two physics groups should make contact with each other or not.
	///
	/// # Arguments
	///
	/// * `groupA` - The first physics group.
	/// * `groupB` - The second physics group.
	/// * `contact` - Whether the two groups should make contact with each other.
	fn set_should_contact(&mut self, group_a: i32, group_b: i32, contact: bool) {
		unsafe { physicsworld_set_should_contact(self.raw(), group_a, group_b, if contact { 1 } else { 0 }); }
	}
	/// Gets whether two physics groups should make contact with each other or not.
	///
	/// # Arguments
	///
	/// * `groupA` - The first physics group.
	/// * `groupB` - The second physics group.
	///
	/// # Returns
	///
	/// * `bool` - Whether the two groups should make contact with each other.
	fn get_should_contact(&mut self, group_a: i32, group_b: i32) -> bool {
		unsafe { return physicsworld_get_should_contact(self.raw(), group_a, group_b) != 0; }
	}
}
impl PhysicsWorld {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { physicsworld_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(PhysicsWorld { raw: raw }))
			}
		})
	}
	/// Sets the factor used for converting physics engine meters value to pixel value.
	/// Default 100.0 is a good value since the physics engine can well simulate real life objects
	/// between 0.1 to 10 meters. Use value 100.0 we can simulate game objects
	/// between 10 to 1000 pixels that suite most games.
	/// You can change this value before any physics body creation.
	pub fn set_scale_factor(var: f32) {
		unsafe { physicsworld_set_scale_factor(var) };
	}
	/// Gets the factor used for converting physics engine meters value to pixel value.
	/// Default 100.0 is a good value since the physics engine can well simulate real life objects
	/// between 0.1 to 10 meters. Use value 100.0 we can simulate game objects
	/// between 10 to 1000 pixels that suite most games.
	/// You can change this value before any physics body creation.
	pub fn get_scale_factor() -> f32 {
		return unsafe { physicsworld_get_scale_factor() };
	}
	/// Creates a new `PhysicsWorld` object.
	///
	/// # Returns
	///
	/// * A new `PhysicsWorld` object.
	pub fn new() -> PhysicsWorld {
		unsafe { return PhysicsWorld { raw: physicsworld_new() }; }
	}
}