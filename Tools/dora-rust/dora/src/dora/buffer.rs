/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn buffer_type() -> i32;
	fn buffer_set_text(slf: i64, val: i64);
	fn buffer_get_text(slf: i64) -> i64;
	fn buffer_resize(slf: i64, size: i32);
	fn buffer_zero_memory(slf: i64);
	fn buffer_get_size(slf: i64) -> i32;
}
use crate::dora::IObject;
pub struct Buffer { raw: i64 }
crate::dora_object!(Buffer);
impl Buffer {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { buffer_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Buffer { raw: raw }))
			}
		})
	}
	pub fn set_text(&mut self, val: &str) {
		unsafe { buffer_set_text(self.raw(), crate::dora::from_string(val)) };
	}
	pub fn get_text(&self) -> String {
		return unsafe { crate::dora::to_string(buffer_get_text(self.raw())) };
	}
	pub fn resize(&mut self, size: i32) {
		unsafe { buffer_resize(self.raw(), size); }
	}
	pub fn zero_memory(&mut self) {
		unsafe { buffer_zero_memory(self.raw()); }
	}
	pub fn get_size(&self) -> i32 {
		unsafe { return buffer_get_size(self.raw()); }
	}
}