/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn texture2d_type() -> i32;
	fn texture2d_get_width(slf: i64) -> i32;
	fn texture2d_get_height(slf: i64) -> i32;
	fn texture2d_with_file(filename: i64) -> i64;
}
use crate::dora::IObject;
/// A struct represents a 2D texture.
pub struct Texture2D { raw: i64 }
crate::dora_object!(Texture2D);
impl Texture2D {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { texture2d_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Texture2D { raw: raw }))
			}
		})
	}
	/// Gets the width of the texture, in pixels.
	pub fn get_width(&self) -> i32 {
		return unsafe { texture2d_get_width(self.raw()) };
	}
	/// Gets the height of the texture, in pixels.
	pub fn get_height(&self) -> i32 {
		return unsafe { texture2d_get_height(self.raw()) };
	}
	/// Creates a texture object from the given file.
	///
	/// # Arguments
	///
	/// * `filename` - The file name of the texture.
	///
	/// # Returns
	///
	/// * `Texture2D` - The texture object.
	pub fn with_file(filename: &str) -> Option<Texture2D> {
		unsafe { return Texture2D::from(texture2d_with_file(crate::dora::from_string(filename))); }
	}
}