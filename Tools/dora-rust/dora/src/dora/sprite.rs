/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn sprite_type() -> i32;
	fn sprite_set_depth_write(slf: i64, val: i32);
	fn sprite_is_depth_write(slf: i64) -> i32;
	fn sprite_set_alpha_ref(slf: i64, val: f32);
	fn sprite_get_alpha_ref(slf: i64) -> f32;
	fn sprite_set_texture_rect(slf: i64, val: i64);
	fn sprite_get_texture_rect(slf: i64) -> i64;
	fn sprite_get_texture(slf: i64) -> i64;
	fn sprite_set_blend_func(slf: i64, val: i64);
	fn sprite_get_blend_func(slf: i64) -> i64;
	fn sprite_set_effect(slf: i64, val: i64);
	fn sprite_get_effect(slf: i64) -> i64;
	fn sprite_set_uwrap(slf: i64, val: i32);
	fn sprite_get_uwrap(slf: i64) -> i32;
	fn sprite_set_vwrap(slf: i64, val: i32);
	fn sprite_get_vwrap(slf: i64) -> i32;
	fn sprite_set_filter(slf: i64, val: i32);
	fn sprite_get_filter(slf: i64) -> i32;
	fn sprite_set_effect_as_default(slf: i64);
	fn sprite_new() -> i64;
	fn sprite_with_texture_rect(texture: i64, texture_rect: i64) -> i64;
	fn sprite_with_texture(texture: i64) -> i64;
	fn sprite_with_file(clip_str: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for Sprite { }
/// A struct to render texture in game scene tree hierarchy.
pub struct Sprite { raw: i64 }
crate::dora_object!(Sprite);
impl ISprite for Sprite { }
pub trait ISprite: INode {
	/// Sets whether the depth buffer should be written to when rendering the sprite.
	fn set_depth_write(&mut self, val: bool) {
		unsafe { sprite_set_depth_write(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether the depth buffer should be written to when rendering the sprite.
	fn is_depth_write(&self) -> bool {
		return unsafe { sprite_is_depth_write(self.raw()) != 0 };
	}
	/// Sets the alpha reference value for alpha testing. Pixels with alpha values less than or equal to this value will be discarded.
	/// Only works with `sprite.effect = SpriteEffect::new("builtin:vs_sprite", "builtin:fs_spritealphatest");`.
	fn set_alpha_ref(&mut self, val: f32) {
		unsafe { sprite_set_alpha_ref(self.raw(), val) };
	}
	/// Gets the alpha reference value for alpha testing. Pixels with alpha values less than or equal to this value will be discarded.
	/// Only works with `sprite.effect = SpriteEffect::new("builtin:vs_sprite", "builtin:fs_spritealphatest");`.
	fn get_alpha_ref(&self) -> f32 {
		return unsafe { sprite_get_alpha_ref(self.raw()) };
	}
	/// Sets the texture rectangle for the sprite.
	fn set_texture_rect(&mut self, val: &crate::dora::Rect) {
		unsafe { sprite_set_texture_rect(self.raw(), val.raw()) };
	}
	/// Gets the texture rectangle for the sprite.
	fn get_texture_rect(&self) -> crate::dora::Rect {
		return unsafe { crate::dora::Rect::from(sprite_get_texture_rect(self.raw())) };
	}
	/// Gets the texture for the sprite.
	fn get_texture(&self) -> Option<crate::dora::Texture2D> {
		return unsafe { crate::dora::Texture2D::from(sprite_get_texture(self.raw())) };
	}
	/// Sets the blend function for the sprite.
	fn set_blend_func(&mut self, val: crate::dora::BlendFunc) {
		unsafe { sprite_set_blend_func(self.raw(), val.to_value()) };
	}
	/// Gets the blend function for the sprite.
	fn get_blend_func(&self) -> crate::dora::BlendFunc {
		return unsafe { crate::dora::BlendFunc::from(sprite_get_blend_func(self.raw())) };
	}
	/// Sets the sprite shader effect.
	fn set_effect(&mut self, val: &crate::dora::SpriteEffect) {
		unsafe { sprite_set_effect(self.raw(), val.raw()) };
	}
	/// Gets the sprite shader effect.
	fn get_effect(&self) -> crate::dora::SpriteEffect {
		return unsafe { crate::dora::SpriteEffect::from(sprite_get_effect(self.raw())).unwrap() };
	}
	/// Sets the texture wrapping mode for the U (horizontal) axis.
	fn set_uwrap(&mut self, val: crate::dora::TextureWrap) {
		unsafe { sprite_set_uwrap(self.raw(), val as i32) };
	}
	/// Gets the texture wrapping mode for the U (horizontal) axis.
	fn get_uwrap(&self) -> crate::dora::TextureWrap {
		return unsafe { core::mem::transmute(sprite_get_uwrap(self.raw())) };
	}
	/// Sets the texture wrapping mode for the V (vertical) axis.
	fn set_vwrap(&mut self, val: crate::dora::TextureWrap) {
		unsafe { sprite_set_vwrap(self.raw(), val as i32) };
	}
	/// Gets the texture wrapping mode for the V (vertical) axis.
	fn get_vwrap(&self) -> crate::dora::TextureWrap {
		return unsafe { core::mem::transmute(sprite_get_vwrap(self.raw())) };
	}
	/// Sets the texture filtering mode for the sprite.
	fn set_filter(&mut self, val: crate::dora::TextureFilter) {
		unsafe { sprite_set_filter(self.raw(), val as i32) };
	}
	/// Gets the texture filtering mode for the sprite.
	fn get_filter(&self) -> crate::dora::TextureFilter {
		return unsafe { core::mem::transmute(sprite_get_filter(self.raw())) };
	}
	/// Removes the sprite effect and sets the default effect.
	fn set_effect_as_default(&mut self) {
		unsafe { sprite_set_effect_as_default(self.raw()); }
	}
}
impl Sprite {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { sprite_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Sprite { raw: raw }))
			}
		})
	}
	/// A method for creating a Sprite object.
	///
	/// # Returns
	///
	/// * `Sprite` - A new instance of the Sprite class.
	pub fn new() -> Sprite {
		unsafe { return Sprite { raw: sprite_new() }; }
	}
	/// A method for creating a Sprite object.
	///
	/// # Arguments
	///
	/// * `texture` - The texture to be used for the sprite.
	/// * `texture_rect` - An optional rectangle defining the portion of the texture to use for the sprite. If not provided, the whole texture will be used for rendering.
	///
	/// # Returns
	///
	/// * `Sprite` - A new instance of the Sprite class.
	pub fn with_texture_rect(texture: &crate::dora::Texture2D, texture_rect: &crate::dora::Rect) -> Sprite {
		unsafe { return Sprite { raw: sprite_with_texture_rect(texture.raw(), texture_rect.raw()) }; }
	}
	/// A method for creating a Sprite object.
	///
	/// # Arguments
	///
	/// * `texture` - The texture to be used for the sprite.
	///
	/// # Returns
	///
	/// * `Sprite` - A new instance of the Sprite class.
	pub fn with_texture(texture: &crate::dora::Texture2D) -> Sprite {
		unsafe { return Sprite { raw: sprite_with_texture(texture.raw()) }; }
	}
	/// A method for creating a Sprite object.
	///
	/// # Arguments
	///
	/// * `clip_str` - The string containing format for loading a texture file. Can be "Image/file.png" and "Image/items.clip|itemA". Supports image file format: jpg, png, dds, pvr, ktx.
	///
	/// # Returns
	///
	/// * `Option<Sprite>` - A new instance of the Sprite class. If the texture file is not found, it will return `None`.
	pub fn with_file(clip_str: &str) -> Option<Sprite> {
		unsafe { return Sprite::from(sprite_with_file(crate::dora::from_string(clip_str))); }
	}
}