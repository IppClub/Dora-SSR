extern "C" {
	fn label_type() -> i32;
	fn label_set_alignment(slf: i64, var: i32);
	fn label_get_alignment(slf: i64) -> i32;
	fn label_set_alpha_ref(slf: i64, var: f32);
	fn label_get_alpha_ref(slf: i64) -> f32;
	fn label_set_text_width(slf: i64, var: f32);
	fn label_get_text_width(slf: i64) -> f32;
	fn label_set_spacing(slf: i64, var: f32);
	fn label_get_spacing(slf: i64) -> f32;
	fn label_set_line_gap(slf: i64, var: f32);
	fn label_get_line_gap(slf: i64) -> f32;
	fn label_set_text(slf: i64, var: i64);
	fn label_get_text(slf: i64) -> i64;
	fn label_set_blend_func(slf: i64, var: i64);
	fn label_get_blend_func(slf: i64) -> i64;
	fn label_set_depth_write(slf: i64, var: i32);
	fn label_is_depth_write(slf: i64) -> i32;
	fn label_set_batched(slf: i64, var: i32);
	fn label_is_batched(slf: i64) -> i32;
	fn label_set_effect(slf: i64, var: i64);
	fn label_get_effect(slf: i64) -> i64;
	fn label_get_character_count(slf: i64) -> i32;
	fn label_get_character(slf: i64, index: i32) -> i64;
	fn label_get_automatic_width() -> f32;
	fn label_new(font_name: i64, font_size: i32) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for Label { }
pub struct Label { raw: i64 }
crate::dora_object!(Label);
impl Label {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { label_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Label { raw: raw }))
			}
		})
	}
	pub fn set_alignment(&mut self, var: crate::dora::TextAlign) {
		unsafe { label_set_alignment(self.raw(), var as i32) };
	}
	pub fn get_alignment(&self) -> crate::dora::TextAlign {
		return unsafe { core::mem::transmute(label_get_alignment(self.raw())) };
	}
	pub fn set_alpha_ref(&mut self, var: f32) {
		unsafe { label_set_alpha_ref(self.raw(), var) };
	}
	pub fn get_alpha_ref(&self) -> f32 {
		return unsafe { label_get_alpha_ref(self.raw()) };
	}
	pub fn set_text_width(&mut self, var: f32) {
		unsafe { label_set_text_width(self.raw(), var) };
	}
	pub fn get_text_width(&self) -> f32 {
		return unsafe { label_get_text_width(self.raw()) };
	}
	pub fn set_spacing(&mut self, var: f32) {
		unsafe { label_set_spacing(self.raw(), var) };
	}
	pub fn get_spacing(&self) -> f32 {
		return unsafe { label_get_spacing(self.raw()) };
	}
	pub fn set_line_gap(&mut self, var: f32) {
		unsafe { label_set_line_gap(self.raw(), var) };
	}
	pub fn get_line_gap(&self) -> f32 {
		return unsafe { label_get_line_gap(self.raw()) };
	}
	pub fn set_text(&mut self, var: &str) {
		unsafe { label_set_text(self.raw(), crate::dora::from_string(var)) };
	}
	pub fn get_text(&self) -> String {
		return unsafe { crate::dora::to_string(label_get_text(self.raw())) };
	}
	pub fn set_blend_func(&mut self, var: u64) {
		unsafe { label_set_blend_func(self.raw(), var as i64) };
	}
	pub fn get_blend_func(&self) -> u64 {
		return unsafe { label_get_blend_func(self.raw()) as u64 };
	}
	pub fn set_depth_write(&mut self, var: bool) {
		unsafe { label_set_depth_write(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_depth_write(&self) -> bool {
		return unsafe { label_is_depth_write(self.raw()) != 0 };
	}
	pub fn set_batched(&mut self, var: bool) {
		unsafe { label_set_batched(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_batched(&self) -> bool {
		return unsafe { label_is_batched(self.raw()) != 0 };
	}
	pub fn set_effect(&mut self, var: &crate::dora::SpriteEffect) {
		unsafe { label_set_effect(self.raw(), var.raw()) };
	}
	pub fn get_effect(&self) -> crate::dora::SpriteEffect {
		return unsafe { crate::dora::SpriteEffect::from(label_get_effect(self.raw())).unwrap() };
	}
	pub fn get_character_count(&self) -> i32 {
		return unsafe { label_get_character_count(self.raw()) };
	}
	pub fn get_character(&mut self, index: i32) -> Option<crate::dora::Sprite> {
		unsafe { return crate::dora::Sprite::from(label_get_character(self.raw(), index)); }
	}
	pub fn get_automatic_width() -> f32 {
		return unsafe { label_get_automatic_width() };
	}
	pub fn new(font_name: &str, font_size: i32) -> Label {
		unsafe { return Label { raw: label_new(crate::dora::from_string(font_name), font_size) }; }
	}
}