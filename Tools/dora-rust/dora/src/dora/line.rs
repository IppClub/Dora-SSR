/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn line_type() -> i32;
	fn line_set_depth_write(slf: i64, val: i32);
	fn line_is_depth_write(slf: i64) -> i32;
	fn line_set_blend_func(slf: i64, val: i64);
	fn line_get_blend_func(slf: i64) -> i64;
	fn line_add(slf: i64, verts: i64, color: i32);
	fn line_set(slf: i64, verts: i64, color: i32);
	fn line_clear(slf: i64);
	fn line_new() -> i64;
	fn line_with_vec_color(verts: i64, color: i32) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for Line { }
/// A struct provides functionality for drawing lines using vertices.
pub struct Line { raw: i64 }
crate::dora_object!(Line);
impl Line {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { line_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Line { raw: raw }))
			}
		})
	}
	/// Sets whether the depth should be written. (Default is false)
	pub fn set_depth_write(&mut self, val: bool) {
		unsafe { line_set_depth_write(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether the depth should be written. (Default is false)
	pub fn is_depth_write(&self) -> bool {
		return unsafe { line_is_depth_write(self.raw()) != 0 };
	}
	/// Sets the blend function for the line node.
	pub fn set_blend_func(&mut self, val: crate::dora::BlendFunc) {
		unsafe { line_set_blend_func(self.raw(), val.to_value()) };
	}
	/// Gets the blend function for the line node.
	pub fn get_blend_func(&self) -> crate::dora::BlendFunc {
		return unsafe { crate::dora::BlendFunc::from(line_get_blend_func(self.raw())) };
	}
	/// Adds vertices to the line.
	///
	/// # Arguments
	///
	/// * `verts` - A vector of vertices to add to the line.
	/// * `color` - Optional. The color of the line.
	pub fn add(&mut self, verts: &Vec<crate::dora::Vec2>, color: &crate::dora::Color) {
		unsafe { line_add(self.raw(), crate::dora::Vector::from_vec2(verts), color.to_argb() as i32); }
	}
	/// Sets vertices of the line.
	///
	/// # Arguments
	///
	/// * `verts` - A vector of vertices to set.
	/// * `color` - Optional. The color of the line.
	pub fn set(&mut self, verts: &Vec<crate::dora::Vec2>, color: &crate::dora::Color) {
		unsafe { line_set(self.raw(), crate::dora::Vector::from_vec2(verts), color.to_argb() as i32); }
	}
	/// Clears all the vertices of line.
	pub fn clear(&mut self) {
		unsafe { line_clear(self.raw()); }
	}
	/// Creates and returns a new empty Line object.
	///
	/// # Returns
	///
	/// * A new `Line` object.
	pub fn new() -> Line {
		unsafe { return Line { raw: line_new() }; }
	}
	/// Creates and returns a new Line object.
	///
	/// # Arguments
	///
	/// * `verts` - A vector of vertices to add to the line.
	/// * `color` - The color of the line.
	///
	/// # Returns
	///
	/// * A new `Line` object.
	pub fn with_vec_color(verts: &Vec<crate::dora::Vec2>, color: &crate::dora::Color) -> Line {
		unsafe { return Line { raw: line_with_vec_color(crate::dora::Vector::from_vec2(verts), color.to_argb() as i32) }; }
	}
}