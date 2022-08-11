extern "C" {
	fn camera_type() -> i32;
	fn camera_get_name(slf: i64) -> i64;
}
use crate::dora::IObject;
pub struct Camera { raw: i64 }
crate::dora_object!(Camera);
impl ICamera for Camera { }
pub trait ICamera: IObject {
	fn get_name(&self) -> String {
		return unsafe { crate::dora::to_string(camera_get_name(self.raw())) };
	}
}
impl Camera {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { camera_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Camera { raw: raw }))
			}
		})
	}
}