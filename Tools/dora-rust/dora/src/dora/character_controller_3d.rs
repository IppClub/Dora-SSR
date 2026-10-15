/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn charactercontroller3d_type() -> i32;
	fn charactercontroller3d_get_node(slf: i64) -> i64;
	fn charactercontroller3d_get_world(slf: i64) -> i64;
	fn charactercontroller3d_set_desired_velocity(slf: i64, val: i64);
	fn charactercontroller3d_get_desired_velocity(slf: i64) -> i64;
	fn charactercontroller3d_get_velocity(slf: i64) -> i64;
	fn charactercontroller3d_get_ground_normal(slf: i64) -> i64;
	fn charactercontroller3d_is_grounded(slf: i64) -> i32;
	fn charactercontroller3d_set_collision_layer(slf: i64, val: i32);
	fn charactercontroller3d_get_collision_layer(slf: i64) -> i32;
	fn charactercontroller3d_set_collision_mask(slf: i64, val: i32);
	fn charactercontroller3d_get_collision_mask(slf: i64) -> i32;
	fn charactercontroller3d_jump(slf: i64, speed: f32);
	fn charactercontroller3d_destroy(slf: i64);
}
use crate::dora::IObject;
/// A virtual capsule character controller owned by a PhysicsWorld3D.
pub struct CharacterController3D { raw: i64 }
crate::dora_object!(CharacterController3D);
impl CharacterController3D {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { charactercontroller3d_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(CharacterController3D { raw: raw }))
			}
		})
	}
	/// Gets the Node3D synchronized with this character.
	pub fn get_node(&self) -> Option<crate::dora::Node3D> {
		return unsafe { crate::dora::Node3D::from(charactercontroller3d_get_node(self.raw())) };
	}
	/// Gets the physics world that owns this character.
	pub fn get_world(&self) -> Option<crate::dora::PhysicsWorld3D> {
		return unsafe { crate::dora::PhysicsWorld3D::from(charactercontroller3d_get_world(self.raw())) };
	}
	/// Sets the desired horizontal movement velocity.
	pub fn set_desired_velocity(&mut self, val: &crate::dora::Vec3) {
		unsafe { charactercontroller3d_set_desired_velocity(self.raw(), val.raw()) };
	}
	/// Gets the desired horizontal movement velocity.
	pub fn get_desired_velocity(&self) -> crate::dora::Vec3 {
		return unsafe { crate::dora::Vec3::from(charactercontroller3d_get_desired_velocity(self.raw())) };
	}
	/// Gets the current world-space velocity including gravity and jumping.
	pub fn get_velocity(&self) -> crate::dora::Vec3 {
		return unsafe { crate::dora::Vec3::from(charactercontroller3d_get_velocity(self.raw())) };
	}
	/// Gets the current supporting surface normal.
	pub fn get_ground_normal(&self) -> crate::dora::Vec3 {
		return unsafe { crate::dora::Vec3::from(charactercontroller3d_get_ground_normal(self.raw())) };
	}
	/// Gets whether the character is standing on walkable ground.
	pub fn is_grounded(&self) -> bool {
		return unsafe { charactercontroller3d_is_grounded(self.raw()) != 0 };
	}
	/// Sets the collision layer in the range 0 through 31.
	pub fn set_collision_layer(&mut self, val: i32) {
		unsafe { charactercontroller3d_set_collision_layer(self.raw(), val) };
	}
	/// Gets the collision layer in the range 0 through 31.
	pub fn get_collision_layer(&self) -> i32 {
		return unsafe { charactercontroller3d_get_collision_layer(self.raw()) };
	}
	/// Sets the bit mask of collision layers accepted by this character.
	pub fn set_collision_mask(&mut self, val: i32) {
		unsafe { charactercontroller3d_set_collision_mask(self.raw(), val) };
	}
	/// Gets the bit mask of collision layers accepted by this character.
	pub fn get_collision_mask(&self) -> i32 {
		return unsafe { charactercontroller3d_get_collision_mask(self.raw()) };
	}
	/// Requests a jump with the given upward speed.
	pub fn jump(&mut self, speed: f32) {
		unsafe { charactercontroller3d_jump(self.raw(), speed); }
	}
	/// Removes this character from its physics world.
	pub fn destroy(&mut self) {
		unsafe { charactercontroller3d_destroy(self.raw()); }
	}
}