/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn svg_type() -> i32;
	fn svgdef_get_width(slf: i64) -> f32;
	fn svgdef_get_height(slf: i64) -> f32;
	fn svgdef_render(slf: i64);
	fn svgdef_new(filename: i64) -> i64;
}
use crate::dora::IObject;
/// A struct used for Scalable Vector Graphics rendering.
pub struct SVG { raw: i64 }
crate::dora_object!(SVG);
impl SVG {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { svg_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(SVG { raw: raw }))
			}
		})
	}
	/// Gets the width of the SVG object.
	pub fn get_width(&self) -> f32 {
		return unsafe { svgdef_get_width(self.raw()) };
	}
	/// Gets the height of the SVG object.
	pub fn get_height(&self) -> f32 {
		return unsafe { svgdef_get_height(self.raw()) };
	}
	/// Renders the SVG object, should be called every frame for the render result to appear.
	pub fn render(&mut self) {
		unsafe { svgdef_render(self.raw()); }
	}
	/// Creates a new SVG object from the specified SVG file.
	///
	/// # Arguments
	///
	/// * `filename` - The path to the SVG format file.
	///
	/// # Returns
	///
	/// * `Svg` - The created SVG object.
	pub fn new(filename: &str) -> Option<SVG> {
		unsafe { return SVG::from(svgdef_new(crate::dora::from_string(filename))); }
	}
}