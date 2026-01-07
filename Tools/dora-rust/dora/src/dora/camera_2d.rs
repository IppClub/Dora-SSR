/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn camera2d_type() -> i32;
	fn camera2d_set_rotation(slf: i64, val: f32);
	fn camera2d_get_rotation(slf: i64) -> f32;
	fn camera2d_set_zoom(slf: i64, val: f32);
	fn camera2d_get_zoom(slf: i64) -> f32;
	fn camera2d_set_position(slf: i64, val: i64);
	fn camera2d_get_position(slf: i64) -> i64;
	fn camera2d_new(name: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::ICamera;
impl ICamera for Camera2D { }
/// A struct for 2D camera object in the game engine.
pub struct Camera2D { raw: i64 }
crate::dora_object!(Camera2D);
impl Camera2D {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { camera2d_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Camera2D { raw: raw }))
			}
		})
	}
	/// Sets the rotation angle of the camera in degrees.
	pub fn set_rotation(&mut self, val: f32) {
		unsafe { camera2d_set_rotation(self.raw(), val) };
	}
	/// Gets the rotation angle of the camera in degrees.
	pub fn get_rotation(&self) -> f32 {
		return unsafe { camera2d_get_rotation(self.raw()) };
	}
	/// Sets the factor by which to zoom the camera. If set to 1.0, the view is normal sized. If set to 2.0, items will appear double in size.
	pub fn set_zoom(&mut self, val: f32) {
		unsafe { camera2d_set_zoom(self.raw(), val) };
	}
	/// Gets the factor by which to zoom the camera. If set to 1.0, the view is normal sized. If set to 2.0, items will appear double in size.
	pub fn get_zoom(&self) -> f32 {
		return unsafe { camera2d_get_zoom(self.raw()) };
	}
	/// Sets the position of the camera in the game world.
	pub fn set_position(&mut self, val: &crate::dora::Vec2) {
		unsafe { camera2d_set_position(self.raw(), val.into_i64()) };
	}
	/// Gets the position of the camera in the game world.
	pub fn get_position(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(camera2d_get_position(self.raw())) };
	}
	/// Creates a new Camera2D object with the given name.
	///
	/// # Arguments
	///
	/// * `name` - The name of the Camera2D object.
	///
	/// # Returns
	///
	/// * `Camera2D` - A new instance of the Camera2D object.
	pub fn new(name: &str) -> Camera2D {
		unsafe { return Camera2D { raw: camera2d_new(crate::dora::from_string(name)) }; }
	}
}