/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn body3d_type() -> i32;
	fn body3d_get_world(slf: i64) -> i64;
	fn body3d_get_body_def(slf: i64) -> i64;
	fn body3d_get_type(slf: i64) -> i32;
	fn body3d_set_linear_velocity(slf: i64, val: i64);
	fn body3d_get_linear_velocity(slf: i64) -> i64;
	fn body3d_set_angular_velocity(slf: i64, val: i64);
	fn body3d_get_angular_velocity(slf: i64) -> i64;
	fn body3d_set_collision_layer(slf: i64, val: i32);
	fn body3d_get_collision_layer(slf: i64) -> i32;
	fn body3d_set_collision_mask(slf: i64, val: i32);
	fn body3d_get_collision_mask(slf: i64) -> i32;
	fn body3d_set_sensor(slf: i64, val: i32);
	fn body3d_is_sensor(slf: i64) -> i32;
	fn body3d_apply_force(slf: i64, force: i64);
	fn body3d_apply_linear_impulse(slf: i64, impulse: i64);
	fn body3d_on_contact_enter(slf: i64, func0: i32, stack0: i64);
	fn body3d_on_contact_stay(slf: i64, func0: i32, stack0: i64);
	fn body3d_on_contact_exit(slf: i64, func0: i32, stack0: i64);
	fn body3d_new(body_def: i64, world: i64, position: i64, angles: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode3D;
impl INode3D for Body3D { }
/// A 3D rigid body node owned by a PhysicsWorld3D.
pub struct Body3D { raw: i64 }
crate::dora_object!(Body3D);
impl IBody3D for Body3D { }
pub trait IBody3D: INode3D {
	/// Gets the physics world that owns this body.
	fn get_world(&self) -> Option<crate::dora::PhysicsWorld3D> {
		return unsafe { crate::dora::PhysicsWorld3D::from(body3d_get_world(self.raw())) };
	}
	/// Gets the immutable definition used to create this body.
	fn get_body_def(&self) -> crate::dora::BodyDef3D {
		return unsafe { crate::dora::BodyDef3D::from(body3d_get_body_def(self.raw())).unwrap() };
	}
	/// Gets the body's motion type.
	fn get_type(&self) -> crate::dora::BodyType3D {
		return unsafe { core::mem::transmute(body3d_get_type(self.raw())) };
	}
	/// Sets the world-space linear velocity.
	fn set_linear_velocity(&mut self, val: &crate::dora::Vec3) {
		unsafe { body3d_set_linear_velocity(self.raw(), val.raw()) };
	}
	/// Gets the world-space linear velocity.
	fn get_linear_velocity(&self) -> crate::dora::Vec3 {
		return unsafe { crate::dora::Vec3::from(body3d_get_linear_velocity(self.raw())) };
	}
	/// Sets the world-space angular velocity in radians per second.
	fn set_angular_velocity(&mut self, val: &crate::dora::Vec3) {
		unsafe { body3d_set_angular_velocity(self.raw(), val.raw()) };
	}
	/// Gets the world-space angular velocity in radians per second.
	fn get_angular_velocity(&self) -> crate::dora::Vec3 {
		return unsafe { crate::dora::Vec3::from(body3d_get_angular_velocity(self.raw())) };
	}
	/// Sets the collision layer in the range 0 through 31.
	fn set_collision_layer(&mut self, val: i32) {
		unsafe { body3d_set_collision_layer(self.raw(), val) };
	}
	/// Gets the collision layer in the range 0 through 31.
	fn get_collision_layer(&self) -> i32 {
		return unsafe { body3d_get_collision_layer(self.raw()) };
	}
	/// Sets the bit mask of collision layers accepted by this body.
	fn set_collision_mask(&mut self, val: i32) {
		unsafe { body3d_set_collision_mask(self.raw(), val) };
	}
	/// Gets the bit mask of collision layers accepted by this body.
	fn get_collision_mask(&self) -> i32 {
		return unsafe { body3d_get_collision_mask(self.raw()) };
	}
	/// Sets whether this body reports contacts without collision response.
	fn set_sensor(&mut self, val: bool) {
		unsafe { body3d_set_sensor(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether this body reports contacts without collision response.
	fn is_sensor(&self) -> bool {
		return unsafe { body3d_is_sensor(self.raw()) != 0 };
	}
	/// Applies a continuous force at the center of mass.
	fn apply_force(&mut self, force: &crate::dora::Vec3) {
		unsafe { body3d_apply_force(self.raw(), force.raw()); }
	}
	/// Applies an instantaneous impulse at the center of mass.
	fn apply_linear_impulse(&mut self, impulse: &crate::dora::Vec3) {
		unsafe { body3d_apply_linear_impulse(self.raw(), impulse.raw()); }
	}
	/// Sets the persistent contact-enter callback.
	fn on_contact_enter(&mut self, mut handler: Box<dyn FnMut(&crate::dora::Body3D, &crate::dora::Vec3, &crate::dora::Vec3)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			handler(&stack0.pop_cast::<crate::dora::Body3D>().unwrap(), &stack0.pop_vec3().unwrap(), &stack0.pop_vec3().unwrap())
		}));
		unsafe { body3d_on_contact_enter(self.raw(), func_id0, stack_raw0); }
	}
	/// Sets the persistent contact-stay callback.
	fn on_contact_stay(&mut self, mut handler: Box<dyn FnMut(&crate::dora::Body3D, &crate::dora::Vec3, &crate::dora::Vec3)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			handler(&stack0.pop_cast::<crate::dora::Body3D>().unwrap(), &stack0.pop_vec3().unwrap(), &stack0.pop_vec3().unwrap())
		}));
		unsafe { body3d_on_contact_stay(self.raw(), func_id0, stack_raw0); }
	}
	/// Sets the persistent contact-exit callback.
	fn on_contact_exit(&mut self, mut handler: Box<dyn FnMut(&crate::dora::Body3D, &crate::dora::Vec3, &crate::dora::Vec3)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			handler(&stack0.pop_cast::<crate::dora::Body3D>().unwrap(), &stack0.pop_vec3().unwrap(), &stack0.pop_vec3().unwrap())
		}));
		unsafe { body3d_on_contact_exit(self.raw(), func_id0, stack_raw0); }
	}
}
impl Body3D {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { body3d_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Body3D { raw: raw }))
			}
		})
	}
	/// Creates a body node from a body definition.
	pub fn new(body_def: &crate::dora::BodyDef3D, world: &crate::dora::PhysicsWorld3D, position: &crate::dora::Vec3, angles: &crate::dora::Vec3) -> Body3D {
		unsafe { return Body3D { raw: body3d_new(body_def.raw(), world.raw(), position.raw(), angles.raw()) }; }
	}
}