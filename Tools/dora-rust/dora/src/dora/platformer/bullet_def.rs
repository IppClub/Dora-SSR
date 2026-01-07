/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn platformer_bulletdef_type() -> i32;
	fn platformer_bulletdef_set_tag(slf: i64, val: i64);
	fn platformer_bulletdef_get_tag(slf: i64) -> i64;
	fn platformer_bulletdef_set_end_effect(slf: i64, val: i64);
	fn platformer_bulletdef_get_end_effect(slf: i64) -> i64;
	fn platformer_bulletdef_set_life_time(slf: i64, val: f32);
	fn platformer_bulletdef_get_life_time(slf: i64) -> f32;
	fn platformer_bulletdef_set_damage_radius(slf: i64, val: f32);
	fn platformer_bulletdef_get_damage_radius(slf: i64) -> f32;
	fn platformer_bulletdef_set_high_speed_fix(slf: i64, val: i32);
	fn platformer_bulletdef_is_high_speed_fix(slf: i64) -> i32;
	fn platformer_bulletdef_set_gravity(slf: i64, val: i64);
	fn platformer_bulletdef_get_gravity(slf: i64) -> i64;
	fn platformer_bulletdef_set_face(slf: i64, val: i64);
	fn platformer_bulletdef_get_face(slf: i64) -> i64;
	fn platformer_bulletdef_get_body_def(slf: i64) -> i64;
	fn platformer_bulletdef_get_velocity(slf: i64) -> i64;
	fn platformer_bulletdef_set_as_circle(slf: i64, radius: f32);
	fn platformer_bulletdef_set_velocity(slf: i64, angle: f32, speed: f32);
	fn platformer_bulletdef_new() -> i64;
}
use crate::dora::IObject;
/// A struct type that specifies the properties and behaviors of a bullet object in the game.
pub struct BulletDef { raw: i64 }
crate::dora_object!(BulletDef);
impl BulletDef {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { platformer_bulletdef_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(BulletDef { raw: raw }))
			}
		})
	}
	/// Sets the tag for the bullet object.
	pub fn set_tag(&mut self, val: &str) {
		unsafe { platformer_bulletdef_set_tag(self.raw(), crate::dora::from_string(val)) };
	}
	/// Gets the tag for the bullet object.
	pub fn get_tag(&self) -> String {
		return unsafe { crate::dora::to_string(platformer_bulletdef_get_tag(self.raw())) };
	}
	/// Sets the effect that occurs when the bullet object ends its life.
	pub fn set_end_effect(&mut self, val: &str) {
		unsafe { platformer_bulletdef_set_end_effect(self.raw(), crate::dora::from_string(val)) };
	}
	/// Gets the effect that occurs when the bullet object ends its life.
	pub fn get_end_effect(&self) -> String {
		return unsafe { crate::dora::to_string(platformer_bulletdef_get_end_effect(self.raw())) };
	}
	/// Sets the amount of time in seconds that the bullet object remains active.
	pub fn set_life_time(&mut self, val: f32) {
		unsafe { platformer_bulletdef_set_life_time(self.raw(), val) };
	}
	/// Gets the amount of time in seconds that the bullet object remains active.
	pub fn get_life_time(&self) -> f32 {
		return unsafe { platformer_bulletdef_get_life_time(self.raw()) };
	}
	/// Sets the radius of the bullet object's damage area.
	pub fn set_damage_radius(&mut self, val: f32) {
		unsafe { platformer_bulletdef_set_damage_radius(self.raw(), val) };
	}
	/// Gets the radius of the bullet object's damage area.
	pub fn get_damage_radius(&self) -> f32 {
		return unsafe { platformer_bulletdef_get_damage_radius(self.raw()) };
	}
	/// Sets whether the bullet object should be fixed for high speeds.
	pub fn set_high_speed_fix(&mut self, val: bool) {
		unsafe { platformer_bulletdef_set_high_speed_fix(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether the bullet object should be fixed for high speeds.
	pub fn is_high_speed_fix(&self) -> bool {
		return unsafe { platformer_bulletdef_is_high_speed_fix(self.raw()) != 0 };
	}
	/// Sets the gravity vector that applies to the bullet object.
	pub fn set_gravity(&mut self, val: &crate::dora::Vec2) {
		unsafe { platformer_bulletdef_set_gravity(self.raw(), val.into_i64()) };
	}
	/// Gets the gravity vector that applies to the bullet object.
	pub fn get_gravity(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(platformer_bulletdef_get_gravity(self.raw())) };
	}
	/// Sets the visual item of the bullet object.
	pub fn set_face(&mut self, val: &crate::dora::platformer::Face) {
		unsafe { platformer_bulletdef_set_face(self.raw(), val.raw()) };
	}
	/// Gets the visual item of the bullet object.
	pub fn get_face(&self) -> crate::dora::platformer::Face {
		return unsafe { crate::dora::platformer::Face::from(platformer_bulletdef_get_face(self.raw())).unwrap() };
	}
	/// Gets the physics body definition for the bullet object.
	pub fn get_body_def(&self) -> crate::dora::BodyDef {
		return unsafe { crate::dora::BodyDef::from(platformer_bulletdef_get_body_def(self.raw())).unwrap() };
	}
	/// Gets the velocity vector of the bullet object.
	pub fn get_velocity(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(platformer_bulletdef_get_velocity(self.raw())) };
	}
	/// Sets the bullet object's physics body as a circle.
	///
	/// # Arguments
	///
	/// * `radius` - The radius of the circle.
	pub fn set_as_circle(&mut self, radius: f32) {
		unsafe { platformer_bulletdef_set_as_circle(self.raw(), radius); }
	}
	/// Sets the velocity of the bullet object.
	///
	/// # Arguments
	///
	/// * `angle` - The angle of the velocity in degrees.
	/// * `speed` - The speed of the velocity.
	pub fn set_velocity(&mut self, angle: f32, speed: f32) {
		unsafe { platformer_bulletdef_set_velocity(self.raw(), angle, speed); }
	}
	/// Creates a new bullet object definition with default settings.
	///
	/// # Returns
	///
	/// * `BulletDef` - The new bullet object definition.
	pub fn new() -> BulletDef {
		unsafe { return BulletDef { raw: platformer_bulletdef_new() }; }
	}
}