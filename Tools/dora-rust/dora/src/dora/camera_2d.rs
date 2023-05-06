extern "C" {
	fn camera2d_type() -> i32;
	fn camera2d_set_rotation(slf: i64, var: f32);
	fn camera2d_get_rotation(slf: i64) -> f32;
	fn camera2d_set_zoom(slf: i64, var: f32);
	fn camera2d_get_zoom(slf: i64) -> f32;
	fn camera2d_set_position(slf: i64, var: i64);
	fn camera2d_get_position(slf: i64) -> i64;
	fn camera2d_new(name: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::ICamera;
impl ICamera for Camera2D { }
pub struct Camera2D { raw: i64 }
crate::dora_object!(Camera2D);
impl Camera2D {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { camera2d_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Camera2D { raw: raw }))
			}
		})
	}
	pub fn set_rotation(&mut self, var: f32) {
		unsafe { camera2d_set_rotation(self.raw(), var) };
	}
	pub fn get_rotation(&self) -> f32 {
		return unsafe { camera2d_get_rotation(self.raw()) };
	}
	pub fn set_zoom(&mut self, var: f32) {
		unsafe { camera2d_set_zoom(self.raw(), var) };
	}
	pub fn get_zoom(&self) -> f32 {
		return unsafe { camera2d_get_zoom(self.raw()) };
	}
	pub fn set_position(&mut self, var: &crate::dora::Vec2) {
		unsafe { camera2d_set_position(self.raw(), var.into_i64()) };
	}
	pub fn get_position(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(camera2d_get_position(self.raw())) };
	}
	pub fn new(name: &str) -> Camera2D {
		unsafe { return Camera2D { raw: camera2d_new(crate::dora::from_string(name)) }; }
	}
}