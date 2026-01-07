/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn spine_type() -> i32;
	fn spine_set_hit_test_enabled(slf: i64, val: i32);
	fn spine_is_hit_test_enabled(slf: i64) -> i32;
	fn spine_set_bone_rotation(slf: i64, name: i64, rotation: f32) -> i32;
	fn spine_contains_point(slf: i64, x: f32, y: f32) -> i64;
	fn spine_intersects_segment(slf: i64, x_1: f32, y_1: f32, x_2: f32, y_2: f32) -> i64;
	fn spine_with_files(skel_file: i64, atlas_file: i64) -> i64;
	fn spine_new(spine_str: i64) -> i64;
	fn spine_get_looks(spine_str: i64) -> i64;
	fn spine_get_animations(spine_str: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::IPlayable;
impl IPlayable for Spine { }
use crate::dora::INode;
impl INode for Spine { }
/// An implementation of an animation system using the Spine engine.
pub struct Spine { raw: i64 }
crate::dora_object!(Spine);
impl Spine {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { spine_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Spine { raw: raw }))
			}
		})
	}
	/// Sets whether hit testing is enabled.
	pub fn set_hit_test_enabled(&mut self, val: bool) {
		unsafe { spine_set_hit_test_enabled(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether hit testing is enabled.
	pub fn is_hit_test_enabled(&self) -> bool {
		return unsafe { spine_is_hit_test_enabled(self.raw()) != 0 };
	}
	/// Sets the rotation of a bone in the Spine skeleton.
	///
	/// # Arguments
	///
	/// * `name` - The name of the bone to rotate.
	/// * `rotation` - The amount to rotate the bone, in degrees.
	///
	/// # Returns
	///
	/// * `bool` - Whether the rotation was successfully set or not.
	pub fn set_bone_rotation(&mut self, name: &str, rotation: f32) -> bool {
		unsafe { return spine_set_bone_rotation(self.raw(), crate::dora::from_string(name), rotation) != 0; }
	}
	/// Checks if a point in space is inside the boundaries of the Spine skeleton.
	///
	/// # Arguments
	///
	/// * `x` - The x-coordinate of the point to check.
	/// * `y` - The y-coordinate of the point to check.
	///
	/// # Returns
	///
	/// * `Option<String>` - The name of the bone at the point, or `None` if there is no bone at the point.
	pub fn contains_point(&mut self, x: f32, y: f32) -> String {
		unsafe { return crate::dora::to_string(spine_contains_point(self.raw(), x, y)); }
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
	/// * `Option<String>` - The name of the bone or slot at the intersection point, or `None` if no bone or slot is found.
	pub fn intersects_segment(&mut self, x_1: f32, y_1: f32, x_2: f32, y_2: f32) -> String {
		unsafe { return crate::dora::to_string(spine_intersects_segment(self.raw(), x_1, y_1, x_2, y_2)); }
	}
	/// Creates a new instance of 'Spine' using the specified skeleton file and atlas file.
	///
	/// # Arguments
	///
	/// * `skel_file` - The filename of the skeleton file to load.
	/// * `atlas_file` - The filename of the atlas file to load.
	///
	/// # Returns
	///
	/// * A new instance of 'Spine' with the specified skeleton file and atlas file. Returns `None` if the skeleton file or atlas file could not be loaded.
	pub fn with_files(skel_file: &str, atlas_file: &str) -> Option<Spine> {
		unsafe { return Spine::from(spine_with_files(crate::dora::from_string(skel_file), crate::dora::from_string(atlas_file))); }
	}
	/// Creates a new instance of 'Spine' using the specified Spine string.
	///
	/// # Arguments
	///
	/// * `spine_str` - The Spine file string for the new instance. A Spine file string can be a file path with the target file extension like "Spine/item" or file paths with all the related files like "Spine/item.skel|Spine/item.atlas" or "Spine/item.json|Spine/item.atlas".
	///
	/// # Returns
	///
	/// * A new instance of 'Spine'. Returns `None` if the Spine file could not be loaded.
	pub fn new(spine_str: &str) -> Option<Spine> {
		unsafe { return Spine::from(spine_new(crate::dora::from_string(spine_str))); }
	}
	/// Returns a list of available looks for the specified Spine2D file string.
	///
	/// # Arguments
	///
	/// * `spine_str` - The Spine2D file string to get the looks for.
	///
	/// # Returns
	///
	/// * A `Vec<String>` representing the available looks.
	pub fn get_looks(spine_str: &str) -> Vec<String> {
		unsafe { return crate::dora::Vector::to_str(spine_get_looks(crate::dora::from_string(spine_str))); }
	}
	/// Returns a list of available animations for the specified Spine2D file string.
	///
	/// # Arguments
	///
	/// * `spine_str` - The Spine2D file string to get the animations for.
	///
	/// # Returns
	///
	/// * A `Vec<String>` representing the available animations.
	pub fn get_animations(spine_str: &str) -> Vec<String> {
		unsafe { return crate::dora::Vector::to_str(spine_get_animations(crate::dora::from_string(spine_str))); }
	}
}