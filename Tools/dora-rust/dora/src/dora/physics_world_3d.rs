/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn physicsworld3d_type() -> i32;
	fn physicsworld3d_set_gravity(slf: i64, val: i64);
	fn physicsworld3d_get_gravity(slf: i64) -> i64;
	fn physicsworld3d_create_character(slf: i64, node: i64, half_height: f32, radius: f32, max_slope_angle: f32, step_height: f32) -> i64;
	fn physicsworld3d_destroy_character(slf: i64, character: i64);
	fn physicsworld3d_raycast(slf: i64, start: i64, stop: i64, func0: i32, stack0: i64) -> i32;
	fn physicsworld3d_query_sphere(slf: i64, center: i64, radius: f32, func0: i32, stack0: i64) -> i32;
	fn physicsworld3d_new() -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for PhysicsWorld3D { }
/// A fixed-step 3D physics world backed by Jolt Physics.
pub struct PhysicsWorld3D { raw: i64 }
crate::dora_object!(PhysicsWorld3D);
impl IPhysicsWorld3D for PhysicsWorld3D { }
pub trait IPhysicsWorld3D: INode {
	/// Sets the world gravity in units per second squared.
	fn set_gravity(&mut self, val: &crate::dora::Vec3) {
		unsafe { physicsworld3d_set_gravity(self.raw(), val.raw()) };
	}
	/// Gets the world gravity in units per second squared.
	fn get_gravity(&self) -> crate::dora::Vec3 {
		return unsafe { crate::dora::Vec3::from(physicsworld3d_get_gravity(self.raw())) };
	}
	/// Creates a virtual capsule character whose node position represents its feet.
	fn create_character(&mut self, node: &dyn crate::dora::INode3D, half_height: f32, radius: f32, max_slope_angle: f32, step_height: f32) -> crate::dora::CharacterController3D {
		unsafe { return crate::dora::CharacterController3D::from(physicsworld3d_create_character(self.raw(), node.raw(), half_height, radius, max_slope_angle, step_height)).unwrap(); }
	}
	/// Removes a character from this world.
	fn destroy_character(&mut self, character: &crate::dora::CharacterController3D) {
		unsafe { physicsworld3d_destroy_character(self.raw(), character.raw()); }
	}
	/// Casts a segment and invokes the handler for the nearest hit.
	fn raycast(&mut self, start: &crate::dora::Vec3, stop: &crate::dora::Vec3, mut handler: Box<dyn FnMut(&crate::dora::Body3D, &crate::dora::Vec3, &crate::dora::Vec3) -> bool>) -> bool {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = handler(&stack0.pop_cast::<crate::dora::Body3D>().unwrap(), &stack0.pop_vec3().unwrap(), &stack0.pop_vec3().unwrap());
			stack0.push_bool(result);
		}));
		unsafe { return physicsworld3d_raycast(self.raw(), start.raw(), stop.raw(), func_id0, stack_raw0) != 0; }
	}
	/// Visits bodies overlapping a sphere until the handler returns true.
	fn query_sphere(&mut self, center: &crate::dora::Vec3, radius: f32, mut handler: Box<dyn FnMut(&crate::dora::Body3D) -> bool>) -> bool {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = handler(&stack0.pop_cast::<crate::dora::Body3D>().unwrap());
			stack0.push_bool(result);
		}));
		unsafe { return physicsworld3d_query_sphere(self.raw(), center.raw(), radius, func_id0, stack_raw0) != 0; }
	}
}
impl PhysicsWorld3D {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { physicsworld3d_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(PhysicsWorld3D { raw: raw }))
			}
		})
	}
	/// Creates a 3D physics world.
	pub fn new() -> PhysicsWorld3D {
		unsafe { return PhysicsWorld3D { raw: physicsworld3d_new() }; }
	}
}