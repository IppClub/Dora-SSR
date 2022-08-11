extern "C" {
	fn grabber_type() -> i32;
	fn grabber_set_camera(slf: i64, var: i64);
	fn grabber_get_camera(slf: i64) -> i64;
	fn grabber_set_effect(slf: i64, var: i64);
	fn grabber_get_effect(slf: i64) -> i64;
	fn grabber_set_blend_func(slf: i64, var: i64);
	fn grabber_get_blend_func(slf: i64) -> i64;
	fn grabber_set_clear_color(slf: i64, var: i32);
	fn grabber_get_clear_color(slf: i64) -> i32;
	fn grabber_set_pos(slf: i64, x: i32, y: i32, pos: i64, z: f32);
	fn grabber_get_pos(slf: i64, x: i32, y: i32) -> i64;
	fn grabber_set_color(slf: i64, x: i32, y: i32, color: i32);
	fn grabber_get_color(slf: i64, x: i32, y: i32) -> i32;
	fn grabber_move_uv(slf: i64, x: i32, y: i32, offset: i64);
}
use crate::dora::IObject;
pub struct Grabber { raw: i64 }
crate::dora_object!(Grabber);
impl Grabber {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { grabber_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Grabber { raw: raw }))
			}
		})
	}
	pub fn set_camera(&mut self, var: &dyn crate::dora::ICamera) {
		unsafe { grabber_set_camera(self.raw(), var.raw()) };
	}
	pub fn get_camera(&self) -> Option<crate::dora::Camera> {
		return unsafe { crate::dora::Camera::from(grabber_get_camera(self.raw())) };
	}
	pub fn set_effect(&mut self, var: &crate::dora::SpriteEffect) {
		unsafe { grabber_set_effect(self.raw(), var.raw()) };
	}
	pub fn get_effect(&self) -> Option<crate::dora::SpriteEffect> {
		return unsafe { crate::dora::SpriteEffect::from(grabber_get_effect(self.raw())) };
	}
	pub fn set_blend_func(&mut self, var: u64) {
		unsafe { grabber_set_blend_func(self.raw(), var as i64) };
	}
	pub fn get_blend_func(&self) -> u64 {
		return unsafe { grabber_get_blend_func(self.raw()) as u64 };
	}
	pub fn set_clear_color(&mut self, var: &crate::dora::Color) {
		unsafe { grabber_set_clear_color(self.raw(), var.to_argb() as i32) };
	}
	pub fn get_clear_color(&self) -> crate::dora::Color {
		return unsafe { crate::dora::Color::from(grabber_get_clear_color(self.raw())) };
	}
	pub fn set_pos(&mut self, x: i32, y: i32, pos: &crate::dora::Vec2, z: f32) {
		unsafe { grabber_set_pos(self.raw(), x, y, pos.into_i64(), z); }
	}
	pub fn get_pos(&self, x: i32, y: i32) -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(grabber_get_pos(self.raw(), x, y)); }
	}
	pub fn set_color(&mut self, x: i32, y: i32, color: &crate::dora::Color) {
		unsafe { grabber_set_color(self.raw(), x, y, color.to_argb() as i32); }
	}
	pub fn get_color(&self, x: i32, y: i32) -> crate::dora::Color {
		unsafe { return crate::dora::Color::from(grabber_get_color(self.raw(), x, y)); }
	}
	pub fn move_uv(&mut self, x: i32, y: i32, offset: &crate::dora::Vec2) {
		unsafe { grabber_move_uv(self.raw(), x, y, offset.into_i64()); }
	}
}