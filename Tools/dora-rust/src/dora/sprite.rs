extern "C" {
	fn sprite_type() -> i32;
	fn sprite_set_depth_write(slf: i64, var: i32);
	fn sprite_is_depth_write(slf: i64) -> i32;
	fn sprite_set_alpha_ref(slf: i64, var: f32);
	fn sprite_get_alpha_ref(slf: i64) -> f32;
	fn sprite_set_texture_rect(slf: i64, var: i64);
	fn sprite_get_texture_rect(slf: i64) -> i64;
	fn sprite_get_texture(slf: i64) -> i64;
	fn sprite_set_blend_func(slf: i64, var: i64);
	fn sprite_get_blend_func(slf: i64) -> i64;
	fn sprite_set_effect(slf: i64, var: i64);
	fn sprite_get_effect(slf: i64) -> i64;
	fn sprite_set_uwrap(slf: i64, var: i32);
	fn sprite_get_uwrap(slf: i64) -> i32;
	fn sprite_set_vwrap(slf: i64, var: i32);
	fn sprite_get_vwrap(slf: i64) -> i32;
	fn sprite_set_filter(slf: i64, var: i32);
	fn sprite_get_filter(slf: i64) -> i32;
	fn sprite_new() -> i64;
	fn sprite_with_texture_rect(texture: i64, texture_rect: i64) -> i64;
	fn sprite_with_texture(texture: i64) -> i64;
	fn sprite_with_file(clip_str: i64) -> i64;
}
use crate::dora::Object;
use crate::dora::INode;
impl INode for Sprite { }
pub struct Sprite { raw: i64 }
crate::dora_object!(Sprite);
impl Sprite {
	pub fn set_depth_write(&mut self, var: bool) {
		unsafe { sprite_set_depth_write(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_depth_write(&self) -> bool {
		return unsafe { sprite_is_depth_write(self.raw()) != 0 };
	}
	pub fn set_alpha_ref(&mut self, var: f32) {
		unsafe { sprite_set_alpha_ref(self.raw(), var) };
	}
	pub fn get_alpha_ref(&self) -> f32 {
		return unsafe { sprite_get_alpha_ref(self.raw()) };
	}
	pub fn set_texture_rect(&mut self, var: &crate::dora::Rect) {
		unsafe { sprite_set_texture_rect(self.raw(), var.raw()) };
	}
	pub fn get_texture_rect(&self) -> crate::dora::Rect {
		return unsafe { crate::dora::Rect::from(sprite_get_texture_rect(self.raw())) };
	}
	pub fn get_texture(&self) -> Option<crate::dora::Texture2D> {
		return unsafe { crate::dora::Texture2D::from(sprite_get_texture(self.raw())) };
	}
	pub fn set_blend_func(&mut self, var: u64) {
		unsafe { sprite_set_blend_func(self.raw(), var as i64) };
	}
	pub fn get_blend_func(&self) -> u64 {
		return unsafe { sprite_get_blend_func(self.raw()) as u64 };
	}
	pub fn set_effect(&mut self, var: &crate::dora::SpriteEffect) {
		unsafe { sprite_set_effect(self.raw(), var.raw()) };
	}
	pub fn get_effect(&self) -> crate::dora::SpriteEffect {
		return unsafe { crate::dora::SpriteEffect::from(sprite_get_effect(self.raw())).unwrap() };
	}
	pub fn set_uwrap(&mut self, var: crate::dora::TextureWrap) {
		unsafe { sprite_set_uwrap(self.raw(), var as i32) };
	}
	pub fn get_uwrap(&self) -> crate::dora::TextureWrap {
		return unsafe { core::mem::transmute(sprite_get_uwrap(self.raw())) };
	}
	pub fn set_vwrap(&mut self, var: crate::dora::TextureWrap) {
		unsafe { sprite_set_vwrap(self.raw(), var as i32) };
	}
	pub fn get_vwrap(&self) -> crate::dora::TextureWrap {
		return unsafe { core::mem::transmute(sprite_get_vwrap(self.raw())) };
	}
	pub fn set_filter(&mut self, var: crate::dora::TextureFilter) {
		unsafe { sprite_set_filter(self.raw(), var as i32) };
	}
	pub fn get_filter(&self) -> crate::dora::TextureFilter {
		return unsafe { core::mem::transmute(sprite_get_filter(self.raw())) };
	}
	pub fn new() -> Sprite {
		return Sprite { raw: unsafe { sprite_new() } };
	}
	pub fn with_texture_rect(texture: &crate::dora::Texture2D, texture_rect: &crate::dora::Rect) -> Sprite {
		return Sprite { raw: unsafe { sprite_with_texture_rect(texture.raw(), texture_rect.raw()) } };
	}
	pub fn with_texture(texture: &crate::dora::Texture2D) -> Sprite {
		return Sprite { raw: unsafe { sprite_with_texture(texture.raw()) } };
	}
	pub fn with_file(clip_str: &str) -> Option<Sprite> {
		return Sprite::from(unsafe { sprite_with_file(crate::dora::from_string(clip_str)) });
	}
}