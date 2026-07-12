/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn directionallight3d_type() -> i32;
	fn directionallight3d_set_color(slf: i64, val: i32);
	fn directionallight3d_get_color(slf: i64) -> i32;
	fn directionallight3d_set_intensity(slf: i64, val: f32);
	fn directionallight3d_get_intensity(slf: i64) -> f32;
	fn directionallight3d_set_cast_shadow(slf: i64, val: i32);
	fn directionallight3d_is_cast_shadow(slf: i64) -> i32;
	fn directionallight3d_set_shadow_bias(slf: i64, val: f32);
	fn directionallight3d_get_shadow_bias(slf: i64) -> f32;
	fn directionallight3d_set_shadow_normal_bias(slf: i64, val: f32);
	fn directionallight3d_get_shadow_normal_bias(slf: i64) -> f32;
	fn directionallight3d_new() -> i64;
}
use crate::dora::IObject;
use crate::dora::INode3D;
impl INode3D for DirectionalLight3D { }
/// A directional light whose direction follows the node world rotation.
pub struct DirectionalLight3D { raw: i64 }
crate::dora_object!(DirectionalLight3D);
impl DirectionalLight3D {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { directionallight3d_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(DirectionalLight3D { raw: raw }))
			}
		})
	}
	/// Sets the light color in sRGB space.
	pub fn set_color(&mut self, val: &crate::dora::Color3) {
		unsafe { directionallight3d_set_color(self.raw(), val.to_rgb() as i32) };
	}
	/// Gets the light color in sRGB space.
	pub fn get_color(&self) -> crate::dora::Color3 {
		return unsafe { crate::dora::Color3::from(directionallight3d_get_color(self.raw())) };
	}
	/// Sets the light intensity.
	pub fn set_intensity(&mut self, val: f32) {
		unsafe { directionallight3d_set_intensity(self.raw(), val) };
	}
	/// Gets the light intensity.
	pub fn get_intensity(&self) -> f32 {
		return unsafe { directionallight3d_get_intensity(self.raw()) };
	}
	/// Sets whether the light casts a shadow.
	pub fn set_cast_shadow(&mut self, val: bool) {
		unsafe { directionallight3d_set_cast_shadow(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether the light casts a shadow.
	pub fn is_cast_shadow(&self) -> bool {
		return unsafe { directionallight3d_is_cast_shadow(self.raw()) != 0 };
	}
	/// Sets the constant shadow depth bias.
	pub fn set_shadow_bias(&mut self, val: f32) {
		unsafe { directionallight3d_set_shadow_bias(self.raw(), val) };
	}
	/// Gets the constant shadow depth bias.
	pub fn get_shadow_bias(&self) -> f32 {
		return unsafe { directionallight3d_get_shadow_bias(self.raw()) };
	}
	/// Sets the slope-dependent shadow normal bias.
	pub fn set_shadow_normal_bias(&mut self, val: f32) {
		unsafe { directionallight3d_set_shadow_normal_bias(self.raw(), val) };
	}
	/// Gets the slope-dependent shadow normal bias.
	pub fn get_shadow_normal_bias(&self) -> f32 {
		return unsafe { directionallight3d_get_shadow_normal_bias(self.raw()) };
	}
	/// Creates a directional light.
	pub fn new() -> DirectionalLight3D {
		unsafe { return DirectionalLight3D { raw: directionallight3d_new() }; }
	}
}