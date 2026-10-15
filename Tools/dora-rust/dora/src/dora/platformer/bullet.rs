/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn platformer_bullet_type() -> i32;
	fn platformer_bullet_set_target_allow(slf: i64, val: i32);
	fn platformer_bullet_get_target_allow(slf: i64) -> i32;
	fn platformer_bullet_is_face_right(slf: i64) -> i32;
	fn platformer_bullet_set_hit_stop(slf: i64, val: i32);
	fn platformer_bullet_is_hit_stop(slf: i64) -> i32;
	fn platformer_bullet_get_emitter(slf: i64) -> i64;
	fn platformer_bullet_get_bullet_def(slf: i64) -> i64;
	fn platformer_bullet_set_face(slf: i64, val: i64);
	fn platformer_bullet_get_face(slf: i64) -> i64;
	fn platformer_bullet_destroy(slf: i64);
	fn platformer_bullet_new(def: i64, owner: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::IBody;
impl IBody for Bullet { }
use crate::dora::INode;
impl INode for Bullet { }
/// A struct that defines the properties and behavior of a bullet object instance in the game.
pub struct Bullet { raw: i64 }
crate::dora_object!(Bullet);
impl Bullet {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { platformer_bullet_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Bullet { raw: raw }))
			}
		})
	}
	/// Sets the value from a `Platformer.TargetAllow` object for the bullet object.
	pub fn set_target_allow(&mut self, val: i32) {
		unsafe { platformer_bullet_set_target_allow(self.raw(), val) };
	}
	/// Gets the value from a `Platformer.TargetAllow` object for the bullet object.
	pub fn get_target_allow(&self) -> i32 {
		return unsafe { platformer_bullet_get_target_allow(self.raw()) };
	}
	/// Gets whether the bullet object is facing right.
	pub fn is_face_right(&self) -> bool {
		return unsafe { platformer_bullet_is_face_right(self.raw()) != 0 };
	}
	/// Sets whether the bullet object should stop on impact.
	pub fn set_hit_stop(&mut self, val: bool) {
		unsafe { platformer_bullet_set_hit_stop(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether the bullet object should stop on impact.
	pub fn is_hit_stop(&self) -> bool {
		return unsafe { platformer_bullet_is_hit_stop(self.raw()) != 0 };
	}
	/// Gets the `Unit` object that fired the bullet.
	pub fn get_emitter(&self) -> crate::dora::platformer::Unit {
		return unsafe { crate::dora::platformer::Unit::from(platformer_bullet_get_emitter(self.raw())).unwrap() };
	}
	/// Gets the `BulletDef` object that defines the bullet's properties and behavior.
	pub fn get_bullet_def(&self) -> crate::dora::platformer::BulletDef {
		return unsafe { crate::dora::platformer::BulletDef::from(platformer_bullet_get_bullet_def(self.raw())).unwrap() };
	}
	/// Sets the `Node` object that appears as the bullet's visual item.
	pub fn set_face(&mut self, val: &dyn crate::dora::INode) {
		unsafe { platformer_bullet_set_face(self.raw(), val.raw()) };
	}
	/// Gets the `Node` object that appears as the bullet's visual item.
	pub fn get_face(&self) -> crate::dora::Node {
		return unsafe { crate::dora::Node::from(platformer_bullet_get_face(self.raw())).unwrap() };
	}
	/// Destroys the bullet object instance.
	pub fn destroy(&mut self) {
		unsafe { platformer_bullet_destroy(self.raw()); }
	}
	/// A method that creates a new `Bullet` object instance with the specified `BulletDef` and `Unit` objects.
	///
	/// # Arguments
	///
	/// * `def` - The `BulletDef` object that defines the bullet's properties and behavior.
	/// * `owner` - The `Unit` object that fired the bullet.
	///
	/// # Returns
	///
	/// * `Bullet` - The new `Bullet` object instance.
	pub fn new(def: &crate::dora::platformer::BulletDef, owner: &crate::dora::platformer::Unit) -> Bullet {
		unsafe { return Bullet { raw: platformer_bullet_new(def.raw(), owner.raw()) }; }
	}
}