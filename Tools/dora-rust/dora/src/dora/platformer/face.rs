/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn platformer_face_type() -> i32;
	fn platformer_face_add_child(slf: i64, face: i64);
	fn platformer_face_to_node(slf: i64) -> i64;
	fn platformer_face_new(face_str: i64, point: i64, scale: f32, angle: f32) -> i64;
	fn platformer_face_with_func(func0: i32, stack0: i64, point: i64, scale: f32, angle: f32) -> i64;
}
use crate::dora::IObject;
/// Represents a definition for a visual component of a game bullet or other visual item.
pub struct Face { raw: i64 }
crate::dora_object!(Face);
impl Face {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { platformer_face_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Face { raw: raw }))
			}
		})
	}
	/// Adds a child `Face` definition to it.
	///
	/// # Arguments
	///
	/// * `face` - The child `Face` to add.
	pub fn add_child(&mut self, face: &crate::dora::platformer::Face) {
		unsafe { platformer_face_add_child(self.raw(), face.raw()); }
	}
	/// Returns a node that can be added to a scene tree for rendering.
	///
	/// # Returns
	///
	/// * `Node` - The `Node` representing this `Face`.
	pub fn to_node(&mut self) -> crate::dora::Node {
		unsafe { return crate::dora::Node::from(platformer_face_to_node(self.raw())).unwrap(); }
	}
	/// Creates a new `Face` definition using the specified attributes.
	///
	/// # Arguments
	///
	/// * `face_str` - A string for creating the `Face` component. Could be 'Image/file.png' and 'Image/items.clip|itemA'.
	/// * `point` - The position of the `Face` component.
	/// * `scale` - The scale of the `Face` component.
	/// * `angle` - The angle of the `Face` component.
	///
	/// # Returns
	///
	/// * `Face` - The new `Face` component.
	pub fn new(face_str: &str, point: &crate::dora::Vec2, scale: f32, angle: f32) -> Face {
		unsafe { return Face { raw: platformer_face_new(crate::dora::from_string(face_str), point.into_i64(), scale, angle) }; }
	}
	/// Creates a new `Face` definition using the specified attributes.
	///
	/// # Arguments
	///
	/// * `create_func` - A function that returns a `Node` representing the `Face` component.
	/// * `point` - The position of the `Face` component.
	/// * `scale` - The scale of the `Face` component.
	/// * `angle` - The angle of the `Face` component.
	///
	/// # Returns
	///
	/// * `Face` - The new `Face` component.
	pub fn with_func(mut create_func: Box<dyn FnMut() -> crate::dora::Node>, point: &crate::dora::Vec2, scale: f32, angle: f32) -> Face {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = create_func();
			stack0.push_object(&result);
		}));
		unsafe { return Face { raw: platformer_face_with_func(func_id0, stack_raw0, point.into_i64(), scale, angle) }; }
	}
}