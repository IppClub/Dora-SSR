/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn dragonbone_type() -> i32;
	fn dragonbone_set_hit_test_enabled(slf: i64, val: i32);
	fn dragonbone_is_hit_test_enabled(slf: i64) -> i32;
	fn dragonbone_contains_point(slf: i64, x: f32, y: f32) -> i64;
	fn dragonbone_intersects_segment(slf: i64, x_1: f32, y_1: f32, x_2: f32, y_2: f32) -> i64;
	fn dragonbone_with_files(bone_file: i64, atlas_file: i64) -> i64;
	fn dragonbone_new(bone_str: i64) -> i64;
	fn dragonbone_get_looks(bone_str: i64) -> i64;
	fn dragonbone_get_animations(bone_str: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::IPlayable;
impl IPlayable for DragonBone { }
use crate::dora::INode;
impl INode for DragonBone { }
/// An implementation of the 'Playable' record using the DragonBones animation system.
pub struct DragonBone { raw: i64 }
crate::dora_object!(DragonBone);
impl DragonBone {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { dragonbone_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(DragonBone { raw: raw }))
			}
		})
	}
	/// Sets whether hit testing is enabled.
	pub fn set_hit_test_enabled(&mut self, val: bool) {
		unsafe { dragonbone_set_hit_test_enabled(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether hit testing is enabled.
	pub fn is_hit_test_enabled(&self) -> bool {
		return unsafe { dragonbone_is_hit_test_enabled(self.raw()) != 0 };
	}
	/// Checks if a point is inside the boundaries of the instance and returns the name of the bone or slot at that point, or `None` if no bone or slot is found.
	///
	/// # Arguments
	///
	/// * `x` - The x-coordinate of the point to check.
	/// * `y` - The y-coordinate of the point to check.
	///
	/// # Returns
	///
	/// * `String` - The name of the bone or slot at the point.
	pub fn contains_point(&mut self, x: f32, y: f32) -> String {
		unsafe { return crate::dora::to_string(dragonbone_contains_point(self.raw(), x, y)); }
	}
	/// Checks if a line segment intersects the boundaries of the instance and returns the name of the bone or slot at the intersection point, or `None` if no bone or slot is found.
	///
	/// # Arguments
	///
	/// * `x1` - The x-coordinate of the start point of the line segment.
	/// * `y1` - The y-coordinate of the start point of the line segment.
	/// * `x2` - The x-coordinate of the end point of the line segment.
	/// * `y2` - The y-coordinate of the end point of the line segment.
	///
	/// # Returns
	///
	/// * `String` - The name of the bone or slot at the intersection point.
	pub fn intersects_segment(&mut self, x_1: f32, y_1: f32, x_2: f32, y_2: f32) -> String {
		unsafe { return crate::dora::to_string(dragonbone_intersects_segment(self.raw(), x_1, y_1, x_2, y_2)); }
	}
	/// Creates a new instance of 'DragonBone' using the specified bone file and atlas file. This function only loads the first armature.
	///
	/// # Arguments
	///
	/// * `bone_file` - The filename of the bone file to load.
	/// * `atlas_file` - The filename of the atlas file to load.
	///
	/// # Returns
	///
	/// * A new instance of 'DragonBone' with the specified bone file and atlas file. Returns `None` if the bone file or atlas file is not found.
	pub fn with_files(bone_file: &str, atlas_file: &str) -> Option<DragonBone> {
		unsafe { return DragonBone::from(dragonbone_with_files(crate::dora::from_string(bone_file), crate::dora::from_string(atlas_file))); }
	}
	/// Creates a new instance of 'DragonBone' using the specified bone string.
	///
	/// # Arguments
	///
	/// * `bone_str` - The DragonBone file string for the new instance. A DragonBone file string can be a file path with the target file extension like "DragonBone/item" or file paths with all the related files like "DragonBone/item_ske.json|DragonBone/item_tex.json". An armature name can be added following a separator of ';'. like "DragonBone/item;mainArmature" or "DragonBone/item_ske.json|DragonBone/item_tex.json;mainArmature".
	///
	/// # Returns
	///
	/// * A new instance of 'DragonBone'. Returns `None` if the bone file or atlas file is not found.
	pub fn new(bone_str: &str) -> Option<DragonBone> {
		unsafe { return DragonBone::from(dragonbone_new(crate::dora::from_string(bone_str))); }
	}
	/// Returns a list of available looks for the specified DragonBone file string.
	///
	/// # Arguments
	///
	/// * `bone_str` - The DragonBone file string to get the looks for.
	///
	/// # Returns
	///
	/// * A `Vec<String>` representing the available looks.
	pub fn get_looks(bone_str: &str) -> Vec<String> {
		unsafe { return crate::dora::Vector::to_str(dragonbone_get_looks(crate::dora::from_string(bone_str))); }
	}
	/// Returns a list of available animations for the specified DragonBone file string.
	///
	/// # Arguments
	///
	/// * `bone_str` - The DragonBone file string to get the animations for.
	///
	/// # Returns
	///
	/// * A `Vec<String>` representing the available animations.
	pub fn get_animations(bone_str: &str) -> Vec<String> {
		unsafe { return crate::dora::Vector::to_str(dragonbone_get_animations(crate::dora::from_string(bone_str))); }
	}
}