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
pub struct PhysicsWorld { raw: i64 }
crate::dora_object!(PhysicsWorld);
impl IPhysicsWorld for PhysicsWorld { }
pub trait IPhysicsWorld: INode {
	fn set_show_debug(&mut self, var: bool) {
		unsafe { physicsworld_set_show_debug(self.raw(), if var { 1 } else { 0 }) };
	}
	fn is_show_debug(&self) -> bool {
		return unsafe { physicsworld_is_show_debug(self.raw()) != 0 };
	}
	fn query(&mut self, rect: &crate::dora::Rect, mut handler: Box<dyn FnMut(&dyn crate::dora::IBody) -> bool>) -> bool {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = handler(&stack.pop_cast::<crate::dora::Body>().unwrap());
			stack.push_bool(result);
		}));
		unsafe { return physicsworld_query(self.raw(), rect.raw(), func_id, stack_raw) != 0; }
	}
	fn raycast(&mut self, start: &crate::dora::Vec2, stop: &crate::dora::Vec2, closest: bool, mut handler: Box<dyn FnMut(&dyn crate::dora::IBody, &crate::dora::Vec2, &crate::dora::Vec2) -> bool>) -> bool {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = handler(&stack.pop_cast::<crate::dora::Body>().unwrap(), &stack.pop_vec2().unwrap(), &stack.pop_vec2().unwrap());
			stack.push_bool(result);
		}));
		unsafe { return physicsworld_raycast(self.raw(), start.into_i64(), stop.into_i64(), if closest { 1 } else { 0 }, func_id, stack_raw) != 0; }
	}
	fn set_iterations(&mut self, velocity_iter: i32, position_iter: i32) {
		unsafe { physicsworld_set_iterations(self.raw(), velocity_iter, position_iter); }
	}
	fn set_should_contact(&mut self, group_a: i32, group_b: i32, contact: bool) {
		unsafe { physicsworld_set_should_contact(self.raw(), group_a, group_b, if contact { 1 } else { 0 }); }
	}
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
	pub fn set_scale_factor(var: f32) {
		unsafe { physicsworld_set_scale_factor(var) };
	}
	pub fn get_scale_factor() -> f32 {
		return unsafe { physicsworld_get_scale_factor() };
	}
	pub fn new() -> PhysicsWorld {
		unsafe { return PhysicsWorld { raw: physicsworld_new() }; }
	}
}