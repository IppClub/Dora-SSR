/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn label_type() -> i32;
	fn label_set_alignment(slf: i64, val: i32);
	fn label_get_alignment(slf: i64) -> i32;
	fn label_set_alpha_ref(slf: i64, val: f32);
	fn label_get_alpha_ref(slf: i64) -> f32;
	fn label_set_text_width(slf: i64, val: f32);
	fn label_get_text_width(slf: i64) -> f32;
	fn label_set_spacing(slf: i64, val: f32);
	fn label_get_spacing(slf: i64) -> f32;
	fn label_set_line_gap(slf: i64, val: f32);
	fn label_get_line_gap(slf: i64) -> f32;
	fn label_set_outline_color(slf: i64, val: i32);
	fn label_get_outline_color(slf: i64) -> i32;
	fn label_set_outline_width(slf: i64, val: f32);
	fn label_get_outline_width(slf: i64) -> f32;
	fn label_set_smooth(slf: i64, val: i64);
	fn label_get_smooth(slf: i64) -> i64;
	fn label_set_text(slf: i64, val: i64);
	fn label_get_text(slf: i64) -> i64;
	fn label_set_blend_func(slf: i64, val: i64);
	fn label_get_blend_func(slf: i64) -> i64;
	fn label_set_depth_write(slf: i64, val: i32);
	fn label_is_depth_write(slf: i64) -> i32;
	fn label_set_batched(slf: i64, val: i32);
	fn label_is_batched(slf: i64) -> i32;
	fn label_set_effect(slf: i64, val: i64);
	fn label_get_effect(slf: i64) -> i64;
	fn label_get_character_count(slf: i64) -> i32;
	fn label_get_character(slf: i64, index: i32) -> i64;
	fn label_get_automatic_width() -> f32;
	fn label_new(font_name: i64, font_size: i32, sdf: i32) -> i64;
	fn label_with_str(font_str: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for Label { }
/// A node for rendering text using a TrueType font.
pub struct Label { raw: i64 }
crate::dora_object!(Label);
impl Label {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { label_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Label { raw: raw }))
			}
		})
	}
	/// Sets the text alignment setting.
	pub fn set_alignment(&mut self, val: crate::dora::TextAlign) {
		unsafe { label_set_alignment(self.raw(), val as i32) };
	}
	/// Gets the text alignment setting.
	pub fn get_alignment(&self) -> crate::dora::TextAlign {
		return unsafe { core::mem::transmute(label_get_alignment(self.raw())) };
	}
	/// Sets the alpha threshold value. Pixels with alpha values below this value will not be drawn.
	/// Only works with `label.effect = SpriteEffect::new("builtin:vs_sprite", "builtin:fs_spritealphatest")`.
	pub fn set_alpha_ref(&mut self, val: f32) {
		unsafe { label_set_alpha_ref(self.raw(), val) };
	}
	/// Gets the alpha threshold value. Pixels with alpha values below this value will not be drawn.
	/// Only works with `label.effect = SpriteEffect::new("builtin:vs_sprite", "builtin:fs_spritealphatest")`.
	pub fn get_alpha_ref(&self) -> f32 {
		return unsafe { label_get_alpha_ref(self.raw()) };
	}
	/// Sets the width of the text used for text wrapping.
	/// Set to `Label::AutomaticWidth` to disable wrapping.
	/// Default is `Label::AutomaticWidth`.
	pub fn set_text_width(&mut self, val: f32) {
		unsafe { label_set_text_width(self.raw(), val) };
	}
	/// Gets the width of the text used for text wrapping.
	/// Set to `Label::AutomaticWidth` to disable wrapping.
	/// Default is `Label::AutomaticWidth`.
	pub fn get_text_width(&self) -> f32 {
		return unsafe { label_get_text_width(self.raw()) };
	}
	/// Sets the gap in pixels between characters.
	pub fn set_spacing(&mut self, val: f32) {
		unsafe { label_set_spacing(self.raw(), val) };
	}
	/// Gets the gap in pixels between characters.
	pub fn get_spacing(&self) -> f32 {
		return unsafe { label_get_spacing(self.raw()) };
	}
	/// Sets the gap in pixels between lines of text.
	pub fn set_line_gap(&mut self, val: f32) {
		unsafe { label_set_line_gap(self.raw(), val) };
	}
	/// Gets the gap in pixels between lines of text.
	pub fn get_line_gap(&self) -> f32 {
		return unsafe { label_get_line_gap(self.raw()) };
	}
	/// Sets the color of the outline, only works with SDF label.
	pub fn set_outline_color(&mut self, val: &crate::dora::Color) {
		unsafe { label_set_outline_color(self.raw(), val.to_argb() as i32) };
	}
	/// Gets the color of the outline, only works with SDF label.
	pub fn get_outline_color(&self) -> crate::dora::Color {
		return unsafe { crate::dora::Color::from(label_get_outline_color(self.raw())) };
	}
	/// Sets the width of the outline, only works with SDF label.
	pub fn set_outline_width(&mut self, val: f32) {
		unsafe { label_set_outline_width(self.raw(), val) };
	}
	/// Gets the width of the outline, only works with SDF label.
	pub fn get_outline_width(&self) -> f32 {
		return unsafe { label_get_outline_width(self.raw()) };
	}
	/// Sets the smooth value of the text, only works with SDF label, default is (0.7, 0.7).
	pub fn set_smooth(&mut self, val: &crate::dora::Vec2) {
		unsafe { label_set_smooth(self.raw(), val.into_i64()) };
	}
	/// Gets the smooth value of the text, only works with SDF label, default is (0.7, 0.7).
	pub fn get_smooth(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(label_get_smooth(self.raw())) };
	}
	/// Sets the text to be rendered.
	pub fn set_text(&mut self, val: &str) {
		unsafe { label_set_text(self.raw(), crate::dora::from_string(val)) };
	}
	/// Gets the text to be rendered.
	pub fn get_text(&self) -> String {
		return unsafe { crate::dora::to_string(label_get_text(self.raw())) };
	}
	/// Sets the blend function for the label.
	pub fn set_blend_func(&mut self, val: crate::dora::BlendFunc) {
		unsafe { label_set_blend_func(self.raw(), val.to_value()) };
	}
	/// Gets the blend function for the label.
	pub fn get_blend_func(&self) -> crate::dora::BlendFunc {
		return unsafe { crate::dora::BlendFunc::from(label_get_blend_func(self.raw())) };
	}
	/// Sets whether depth writing is enabled. (Default is false)
	pub fn set_depth_write(&mut self, val: bool) {
		unsafe { label_set_depth_write(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether depth writing is enabled. (Default is false)
	pub fn is_depth_write(&self) -> bool {
		return unsafe { label_is_depth_write(self.raw()) != 0 };
	}
	/// Sets whether the label is using batched rendering.
	/// When using batched rendering the `label.get_character()` function will no longer work, but it provides better rendering performance. Default is true.
	pub fn set_batched(&mut self, val: bool) {
		unsafe { label_set_batched(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether the label is using batched rendering.
	/// When using batched rendering the `label.get_character()` function will no longer work, but it provides better rendering performance. Default is true.
	pub fn is_batched(&self) -> bool {
		return unsafe { label_is_batched(self.raw()) != 0 };
	}
	/// Sets the sprite effect used to render the text.
	pub fn set_effect(&mut self, val: &crate::dora::SpriteEffect) {
		unsafe { label_set_effect(self.raw(), val.raw()) };
	}
	/// Gets the sprite effect used to render the text.
	pub fn get_effect(&self) -> crate::dora::SpriteEffect {
		return unsafe { crate::dora::SpriteEffect::from(label_get_effect(self.raw())).unwrap() };
	}
	/// Gets the number of characters in the label.
	pub fn get_character_count(&self) -> i32 {
		return unsafe { label_get_character_count(self.raw()) };
	}
	/// Returns the sprite for the character at the specified index.
	///
	/// # Arguments
	///
	/// * `index` - The index of the character sprite to retrieve.
	///
	/// # Returns
	///
	/// * `Option<Sprite>` - The sprite for the character, or `None` if the index is out of range.
	pub fn get_character(&mut self, index: i32) -> Option<crate::dora::Sprite> {
		unsafe { return crate::dora::Sprite::from(label_get_character(self.raw(), index)); }
	}
	/// Gets the value to use for automatic width calculation
	pub fn get_automatic_width() -> f32 {
		return unsafe { label_get_automatic_width() };
	}
	/// Creates a new Label object with the specified font name and font size.
	///
	/// # Arguments
	///
	/// * `font_name` - The name of the font to use for the label. Can be font file path with or without file extension.
	/// * `font_size` - The size of the font to use for the label.
	/// * `sdf` - Whether to use SDF rendering or not. With SDF rendering, the outline feature will be enabled.
	///
	/// # Returns
	///
	/// * `Label` - The new Label object.
	pub fn new(font_name: &str, font_size: i32, sdf: bool) -> Option<Label> {
		unsafe { return Label::from(label_new(crate::dora::from_string(font_name), font_size, if sdf { 1 } else { 0 })); }
	}
	/// Creates a new Label object with the specified font string.
	///
	/// # Arguments
	///
	/// * `font_str` - The font string to use for the label. Should be in the format "fontName;fontSize;sdf", where `sdf` should be "true" or "false".
	///
	/// # Returns
	///
	/// * `Label` - The new Label object.
	pub fn with_str(font_str: &str) -> Option<crate::dora::Label> {
		unsafe { return crate::dora::Label::from(label_with_str(crate::dora::from_string(font_str))); }
	}
}