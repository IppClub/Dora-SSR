/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn platformer_targetallow_release(raw: i64);
	fn platformer_targetallow_set_terrain_allowed(slf: i64, val: i32);
	fn platformer_targetallow_is_terrain_allowed(slf: i64) -> i32;
	fn platformer_targetallow_allow(slf: i64, relation: i32, allow: i32);
	fn platformer_targetallow_is_allow(slf: i64, relation: i32) -> i32;
	fn platformer_targetallow_to_value(slf: i64) -> i32;
	fn platformer_targetallow_new() -> i64;
	fn platformer_targetallow_with_value(value: i32) -> i64;
}
/// A struct to specifies how a bullet object should interact with other game objects or units based on their relationship.
pub struct TargetAllow { raw: i64 }
impl Drop for TargetAllow {
	fn drop(&mut self) { unsafe { platformer_targetallow_release(self.raw); } }
}
impl TargetAllow {
	pub(crate) fn raw(&self) -> i64 {
		self.raw
	}
	pub(crate) fn from(raw: i64) -> TargetAllow {
		TargetAllow { raw: raw }
	}
	/// Sets whether the bullet object can collide with terrain.
	pub fn set_terrain_allowed(&mut self, val: bool) {
		unsafe { platformer_targetallow_set_terrain_allowed(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether the bullet object can collide with terrain.
	pub fn is_terrain_allowed(&self) -> bool {
		return unsafe { platformer_targetallow_is_terrain_allowed(self.raw()) != 0 };
	}
	/// Allows or disallows the bullet object to interact with a game object or unit, based on their relationship.
	///
	/// # Arguments
	///
	/// * `relation` - The relationship between the bullet object and the other game object or unit.
	/// * `allow` - Whether the bullet object should be allowed to interact.
	pub fn allow(&mut self, relation: crate::dora::platformer::Relation, allow: bool) {
		unsafe { platformer_targetallow_allow(self.raw(), relation as i32, if allow { 1 } else { 0 }); }
	}
	/// Determines whether the bullet object is allowed to interact with a game object or unit, based on their relationship.
	///
	/// # Arguments
	///
	/// * `relation` - The relationship between the bullet object and the other game object or unit.
	///
	/// # Returns
	///
	/// * `bool` - Whether the bullet object is allowed to interact.
	pub fn is_allow(&mut self, relation: crate::dora::platformer::Relation) -> bool {
		unsafe { return platformer_targetallow_is_allow(self.raw(), relation as i32) != 0; }
	}
	/// Converts the object to a value that can be used for interaction settings.
	///
	/// # Returns
	///
	/// * `usize` - The value that can be used for interaction settings.
	pub fn to_value(&mut self) -> i32 {
		unsafe { return platformer_targetallow_to_value(self.raw()); }
	}
	/// Creates a new TargetAllow object with default settings.
	pub fn new() -> crate::dora::platformer::TargetAllow {
		unsafe { return crate::dora::platformer::TargetAllow::from(platformer_targetallow_new()); }
	}
	/// Creates a new TargetAllow object with the specified value.
	///
	/// # Arguments
	///
	/// * `value` - The value to use for the new TargetAllow object.
	pub fn with_value(value: i32) -> crate::dora::platformer::TargetAllow {
		unsafe { return crate::dora::platformer::TargetAllow::from(platformer_targetallow_with_value(value)); }
	}
}