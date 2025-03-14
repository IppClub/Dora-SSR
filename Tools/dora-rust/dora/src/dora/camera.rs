/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn camera_type() -> i32;
	fn camera_get_name(slf: i64) -> i64;
}
use crate::dora::IObject;
/// A struct for Camera object in the game engine.
pub struct Camera { raw: i64 }
crate::dora_object!(Camera);
impl ICamera for Camera { }
pub trait ICamera: IObject {
	/// Gets the name of the Camera.
	fn get_name(&self) -> String {
		return unsafe { crate::dora::to_string(camera_get_name(self.raw())) };
	}
}
impl Camera {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { camera_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Camera { raw: raw }))
			}
		})
	}
}