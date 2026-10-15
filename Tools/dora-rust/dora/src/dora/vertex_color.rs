/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn vertexcolor_release(raw: i64);
	fn vertexcolor_set_vertex(slf: i64, val: i64);
	fn vertexcolor_get_vertex(slf: i64) -> i64;
	fn vertexcolor_set_color(slf: i64, val: i32);
	fn vertexcolor_get_color(slf: i64) -> i32;
	fn vertexcolor_new(vec: i64, color: i32) -> i64;
}
pub struct VertexColor { raw: i64 }
impl Drop for VertexColor {
	fn drop(&mut self) { unsafe { vertexcolor_release(self.raw); } }
}
impl VertexColor {
	pub(crate) fn raw(&self) -> i64 {
		self.raw
	}
	pub(crate) fn from(raw: i64) -> VertexColor {
		VertexColor { raw: raw }
	}
	pub fn set_vertex(&mut self, val: &crate::dora::Vec2) {
		unsafe { vertexcolor_set_vertex(self.raw(), val.into_i64()) };
	}
	pub fn get_vertex(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(vertexcolor_get_vertex(self.raw())) };
	}
	pub fn set_color(&mut self, val: &crate::dora::Color) {
		unsafe { vertexcolor_set_color(self.raw(), val.to_argb() as i32) };
	}
	pub fn get_color(&self) -> crate::dora::Color {
		return unsafe { crate::dora::Color::from(vertexcolor_get_color(self.raw())) };
	}
	pub fn new(vec: &crate::dora::Vec2, color: &crate::dora::Color) -> crate::dora::VertexColor {
		unsafe { return crate::dora::VertexColor::from(vertexcolor_new(vec.into_i64(), color.to_argb() as i32)); }
	}
}