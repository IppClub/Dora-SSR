extern "C" {
	fn cameraotho_type() -> i32;
	fn cameraotho_set_position(slf: i64, var: i64);
	fn cameraotho_get_position(slf: i64) -> i64;
	fn cameraotho_new(name: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::ICamera;
impl ICamera for CameraOtho { }
pub struct CameraOtho { raw: i64 }
crate::dora_object!(CameraOtho);
impl CameraOtho {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { cameraotho_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(CameraOtho { raw: raw }))
			}
		})
	}
	pub fn set_position(&mut self, var: &crate::dora::Vec2) {
		unsafe { cameraotho_set_position(self.raw(), var.into_i64()) };
	}
	pub fn get_position(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(cameraotho_get_position(self.raw())) };
	}
	pub fn new(name: &str) -> CameraOtho {
		unsafe { return CameraOtho { raw: cameraotho_new(crate::dora::from_string(name)) }; }
	}
}