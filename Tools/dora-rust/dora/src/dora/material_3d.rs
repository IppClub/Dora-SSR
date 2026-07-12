/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn material3d_type() -> i32;
	fn material3d_set_base_color(slf: i64, val: i32);
	fn material3d_get_base_color(slf: i64) -> i32;
	fn material3d_set_emissive(slf: i64, val: i32);
	fn material3d_get_emissive(slf: i64) -> i32;
	fn material3d_set_metallic(slf: i64, val: f32);
	fn material3d_get_metallic(slf: i64) -> f32;
	fn material3d_set_roughness(slf: i64, val: f32);
	fn material3d_get_roughness(slf: i64) -> f32;
	fn material3d_set_alpha_mode(slf: i64, val: i32);
	fn material3d_get_alpha_mode(slf: i64) -> i32;
	fn material3d_set_alpha_cutoff(slf: i64, val: f32);
	fn material3d_get_alpha_cutoff(slf: i64) -> f32;
	fn material3d_set_base_color_texture(slf: i64, texture: i64);
	fn material3d_clear_base_color_texture(slf: i64);
	fn material3d_set_metallic_roughness_texture(slf: i64, texture: i64);
	fn material3d_clear_metallic_roughness_texture(slf: i64);
	fn material3d_set_normal_texture(slf: i64, texture: i64);
	fn material3d_clear_normal_texture(slf: i64);
	fn material3d_set_emissive_texture(slf: i64, texture: i64);
	fn material3d_clear_emissive_texture(slf: i64);
	fn material3d_set_occlusion_texture(slf: i64, texture: i64);
	fn material3d_clear_occlusion_texture(slf: i64);
}
use crate::dora::IObject;
/// A per-instance material slot owned by a Model3D instance.
pub struct Material3D { raw: i64 }
crate::dora_object!(Material3D);
impl Material3D {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { material3d_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Material3D { raw: raw }))
			}
		})
	}
	/// Sets the base color tint.
	pub fn set_base_color(&mut self, val: &crate::dora::Color) {
		unsafe { material3d_set_base_color(self.raw(), val.to_argb() as i32) };
	}
	/// Gets the base color tint.
	pub fn get_base_color(&self) -> crate::dora::Color {
		return unsafe { crate::dora::Color::from(material3d_get_base_color(self.raw())) };
	}
	/// Sets the emissive color factor.
	pub fn set_emissive(&mut self, val: &crate::dora::Color3) {
		unsafe { material3d_set_emissive(self.raw(), val.to_rgb() as i32) };
	}
	/// Gets the emissive color factor.
	pub fn get_emissive(&self) -> crate::dora::Color3 {
		return unsafe { crate::dora::Color3::from(material3d_get_emissive(self.raw())) };
	}
	/// Sets the metallic factor.
	pub fn set_metallic(&mut self, val: f32) {
		unsafe { material3d_set_metallic(self.raw(), val) };
	}
	/// Gets the metallic factor.
	pub fn get_metallic(&self) -> f32 {
		return unsafe { material3d_get_metallic(self.raw()) };
	}
	/// Sets the roughness factor.
	pub fn set_roughness(&mut self, val: f32) {
		unsafe { material3d_set_roughness(self.raw(), val) };
	}
	/// Gets the roughness factor.
	pub fn get_roughness(&self) -> f32 {
		return unsafe { material3d_get_roughness(self.raw()) };
	}
	/// Sets the alpha rendering mode.
	pub fn set_alpha_mode(&mut self, val: crate::dora::MaterialAlphaMode3D) {
		unsafe { material3d_set_alpha_mode(self.raw(), val as i32) };
	}
	/// Gets the alpha rendering mode.
	pub fn get_alpha_mode(&self) -> crate::dora::MaterialAlphaMode3D {
		return unsafe { core::mem::transmute(material3d_get_alpha_mode(self.raw())) };
	}
	/// Sets the alpha mask cutoff.
	pub fn set_alpha_cutoff(&mut self, val: f32) {
		unsafe { material3d_set_alpha_cutoff(self.raw(), val) };
	}
	/// Gets the alpha mask cutoff.
	pub fn get_alpha_cutoff(&self) -> f32 {
		return unsafe { material3d_get_alpha_cutoff(self.raw()) };
	}
	/// Replaces or clears the base color texture.
	pub fn set_base_color_texture(&mut self, texture: &crate::dora::Texture2D) {
		unsafe { material3d_set_base_color_texture(self.raw(), texture.raw()); }
	}
	/// Clears the base color texture override.
	pub fn clear_base_color_texture(&mut self) {
		unsafe { material3d_clear_base_color_texture(self.raw()); }
	}
	/// Replaces or clears the metallic-roughness texture.
	pub fn set_metallic_roughness_texture(&mut self, texture: &crate::dora::Texture2D) {
		unsafe { material3d_set_metallic_roughness_texture(self.raw(), texture.raw()); }
	}
	/// Clears the metallic-roughness texture override.
	pub fn clear_metallic_roughness_texture(&mut self) {
		unsafe { material3d_clear_metallic_roughness_texture(self.raw()); }
	}
	/// Replaces or clears the normal texture.
	pub fn set_normal_texture(&mut self, texture: &crate::dora::Texture2D) {
		unsafe { material3d_set_normal_texture(self.raw(), texture.raw()); }
	}
	/// Clears the normal texture override.
	pub fn clear_normal_texture(&mut self) {
		unsafe { material3d_clear_normal_texture(self.raw()); }
	}
	/// Replaces or clears the emissive texture.
	pub fn set_emissive_texture(&mut self, texture: &crate::dora::Texture2D) {
		unsafe { material3d_set_emissive_texture(self.raw(), texture.raw()); }
	}
	/// Clears the emissive texture override.
	pub fn clear_emissive_texture(&mut self) {
		unsafe { material3d_clear_emissive_texture(self.raw()); }
	}
	/// Replaces or clears the occlusion texture.
	pub fn set_occlusion_texture(&mut self, texture: &crate::dora::Texture2D) {
		unsafe { material3d_set_occlusion_texture(self.raw(), texture.raw()); }
	}
	/// Clears the occlusion texture override.
	pub fn clear_occlusion_texture(&mut self) {
		unsafe { material3d_clear_occlusion_texture(self.raw()); }
	}
}