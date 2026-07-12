/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn physicsworld3d_type() -> i32;
	fn physicsworld3d_set_gravity(slf: i64, val: i64);
	fn physicsworld3d_get_gravity(slf: i64) -> i64;
	fn physicsworld3d_create_box(slf: i64, node: i64, half_extent: i64, body_type: i32) -> i64;
	fn physicsworld3d_create_sphere(slf: i64, node: i64, radius: f32, body_type: i32) -> i64;
	fn physicsworld3d_create_capsule(slf: i64, node: i64, half_height: f32, radius: f32, body_type: i32) -> i64;
	fn physicsworld3d_create_body(slf: i64, node: i64, shape: i64, body_type: i32) -> i64;
	fn physicsworld3d_create_character(slf: i64, node: i64, half_height: f32, radius: f32, max_slope_angle: f32, step_height: f32) -> i64;
	fn physicsworld3d_create_fixed_constraint(slf: i64, first_body: i64, second_body: i64, anchor: i64) -> i64;
	fn physicsworld3d_create_distance_constraint(slf: i64, first_body: i64, second_body: i64, first_anchor: i64, second_anchor: i64, min_distance: f32, max_distance: f32) -> i64;
	fn physicsworld3d_create_hinge_constraint(slf: i64, first_body: i64, second_body: i64, anchor: i64, axis: i64, min_angle: f32, max_angle: f32) -> i64;
	fn physicsworld3d_destroy_body(slf: i64, body: i64);
	fn physicsworld3d_destroy_character(slf: i64, character: i64);
	fn physicsworld3d_destroy_constraint(slf: i64, constraint: i64);
	fn physicsworld3d_raycast(slf: i64, origin: i64, direction: i64, distance: f32, func0: i32, stack0: i64) -> i32;
	fn physicsworld3d_overlap_sphere(slf: i64, center: i64, radius: f32, func0: i32, stack0: i64) -> i32;
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
	/// Creates a box body using half extents.
	fn create_box(&mut self, node: &dyn crate::dora::INode3D, half_extent: &crate::dora::Vec3, body_type: crate::dora::BodyType3D) -> crate::dora::Body3D {
		unsafe { return crate::dora::Body3D::from(physicsworld3d_create_box(self.raw(), node.raw(), half_extent.raw(), body_type as i32)).unwrap(); }
	}
	/// Creates a sphere body.
	fn create_sphere(&mut self, node: &dyn crate::dora::INode3D, radius: f32, body_type: crate::dora::BodyType3D) -> crate::dora::Body3D {
		unsafe { return crate::dora::Body3D::from(physicsworld3d_create_sphere(self.raw(), node.raw(), radius, body_type as i32)).unwrap(); }
	}
	/// Creates a capsule body.
	fn create_capsule(&mut self, node: &dyn crate::dora::INode3D, half_height: f32, radius: f32, body_type: crate::dora::BodyType3D) -> crate::dora::Body3D {
		unsafe { return crate::dora::Body3D::from(physicsworld3d_create_capsule(self.raw(), node.raw(), half_height, radius, body_type as i32)).unwrap(); }
	}
	/// Creates a body using a reusable built collision shape.
	fn create_body(&mut self, node: &dyn crate::dora::INode3D, shape: &crate::dora::PhysicsShape3D, body_type: crate::dora::BodyType3D) -> crate::dora::Body3D {
		unsafe { return crate::dora::Body3D::from(physicsworld3d_create_body(self.raw(), node.raw(), shape.raw(), body_type as i32)).unwrap(); }
	}
	/// Creates a virtual capsule character whose node position represents its feet.
	fn create_character(&mut self, node: &dyn crate::dora::INode3D, half_height: f32, radius: f32, max_slope_angle: f32, step_height: f32) -> crate::dora::CharacterController3D {
		unsafe { return crate::dora::CharacterController3D::from(physicsworld3d_create_character(self.raw(), node.raw(), half_height, radius, max_slope_angle, step_height)).unwrap(); }
	}
	/// Creates a fixed constraint at a world-space anchor.
	fn create_fixed_constraint(&mut self, first_body: &crate::dora::Body3D, second_body: &crate::dora::Body3D, anchor: &crate::dora::Vec3) -> crate::dora::Constraint3D {
		unsafe { return crate::dora::Constraint3D::from(physicsworld3d_create_fixed_constraint(self.raw(), first_body.raw(), second_body.raw(), anchor.raw())).unwrap(); }
	}
	/// Creates a distance constraint between two world-space anchors.
	fn create_distance_constraint(&mut self, first_body: &crate::dora::Body3D, second_body: &crate::dora::Body3D, first_anchor: &crate::dora::Vec3, second_anchor: &crate::dora::Vec3, min_distance: f32, max_distance: f32) -> crate::dora::Constraint3D {
		unsafe { return crate::dora::Constraint3D::from(physicsworld3d_create_distance_constraint(self.raw(), first_body.raw(), second_body.raw(), first_anchor.raw(), second_anchor.raw(), min_distance, max_distance)).unwrap(); }
	}
	/// Creates a hinge around a world-space axis with limits in degrees.
	fn create_hinge_constraint(&mut self, first_body: &crate::dora::Body3D, second_body: &crate::dora::Body3D, anchor: &crate::dora::Vec3, axis: &crate::dora::Vec3, min_angle: f32, max_angle: f32) -> crate::dora::Constraint3D {
		unsafe { return crate::dora::Constraint3D::from(physicsworld3d_create_hinge_constraint(self.raw(), first_body.raw(), second_body.raw(), anchor.raw(), axis.raw(), min_angle, max_angle)).unwrap(); }
	}
	/// Removes a body from this world.
	fn destroy_body(&mut self, body: &crate::dora::Body3D) {
		unsafe { physicsworld3d_destroy_body(self.raw(), body.raw()); }
	}
	/// Removes a character from this world.
	fn destroy_character(&mut self, character: &crate::dora::CharacterController3D) {
		unsafe { physicsworld3d_destroy_character(self.raw(), character.raw()); }
	}
	/// Removes a constraint from this world.
	fn destroy_constraint(&mut self, constraint: &crate::dora::Constraint3D) {
		unsafe { physicsworld3d_destroy_constraint(self.raw(), constraint.raw()); }
	}
	/// Casts a ray and invokes the handler for the nearest hit.
	fn raycast(&mut self, origin: &crate::dora::Vec3, direction: &crate::dora::Vec3, distance: f32, mut handler: Box<dyn FnMut(&crate::dora::Body3D, &crate::dora::Vec3, &crate::dora::Vec3, f32) -> bool>) -> bool {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = handler(&stack0.pop_cast::<crate::dora::Body3D>().unwrap(), &stack0.pop_vec3().unwrap(), &stack0.pop_vec3().unwrap(), stack0.pop_f32().unwrap());
			stack0.push_bool(result);
		}));
		unsafe { return physicsworld3d_raycast(self.raw(), origin.raw(), direction.raw(), distance, func_id0, stack_raw0) != 0; }
	}
	/// Visits bodies overlapping a sphere until the handler returns true.
	fn overlap_sphere(&mut self, center: &crate::dora::Vec3, radius: f32, mut handler: Box<dyn FnMut(&crate::dora::Body3D) -> bool>) -> bool {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = handler(&stack0.pop_cast::<crate::dora::Body3D>().unwrap());
			stack0.push_bool(result);
		}));
		unsafe { return physicsworld3d_overlap_sphere(self.raw(), center.raw(), radius, func_id0, stack_raw0) != 0; }
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