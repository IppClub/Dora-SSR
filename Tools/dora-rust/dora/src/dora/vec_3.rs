/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn vec3_release(raw: i64);
	fn vec3_set_x(slf: i64, val: f32);
	fn vec3_get_x(slf: i64) -> f32;
	fn vec3_set_y(slf: i64, val: f32);
	fn vec3_get_y(slf: i64) -> f32;
	fn vec3_set_z(slf: i64, val: f32);
	fn vec3_get_z(slf: i64) -> f32;
	fn vec3_new(x: f32, y: f32, z: f32) -> i64;
	fn vec3_zero() -> i64;
}
/// A 3D vector object with x, y and z components.
pub struct Vec3 { raw: i64 }
impl Drop for Vec3 {
	fn drop(&mut self) { unsafe { vec3_release(self.raw); } }
}
impl Vec3 {
	pub(crate) fn raw(&self) -> i64 {
		self.raw
	}
	pub(crate) fn from(raw: i64) -> Vec3 {
		Vec3 { raw: raw }
	}
	/// Sets the x component.
	pub fn set_x(&mut self, val: f32) {
		unsafe { vec3_set_x(self.raw(), val) };
	}
	/// Gets the x component.
	pub fn get_x(&self) -> f32 {
		return unsafe { vec3_get_x(self.raw()) };
	}
	/// Sets the y component.
	pub fn set_y(&mut self, val: f32) {
		unsafe { vec3_set_y(self.raw(), val) };
	}
	/// Gets the y component.
	pub fn get_y(&self) -> f32 {
		return unsafe { vec3_get_y(self.raw()) };
	}
	/// Sets the z component.
	pub fn set_z(&mut self, val: f32) {
		unsafe { vec3_set_z(self.raw(), val) };
	}
	/// Gets the z component.
	pub fn get_z(&self) -> f32 {
		return unsafe { vec3_get_z(self.raw()) };
	}
	/// Creates a new 3D vector.
	pub fn new(x: f32, y: f32, z: f32) -> crate::dora::Vec3 {
		unsafe { return crate::dora::Vec3::from(vec3_new(x, y, z)); }
	}
	/// Gets a zero 3D vector.
	pub fn zero() -> crate::dora::Vec3 {
		unsafe { return crate::dora::Vec3::from(vec3_zero()); }
	}
}