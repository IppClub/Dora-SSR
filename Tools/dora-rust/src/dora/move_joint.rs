extern "C" {
	fn movejoint_type() -> i32;
	fn movejoint_set_position(slf: i64, var: i64);
	fn movejoint_get_position(slf: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::IJoint;
impl IJoint for MoveJoint { }
pub struct MoveJoint { raw: i64 }
crate::dora_object!(MoveJoint);
impl MoveJoint {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { movejoint_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(MoveJoint { raw: raw }))
			}
		})
	}
	pub fn set_position(&mut self, var: &crate::dora::Vec2) {
		unsafe { movejoint_set_position(self.raw(), var.into_i64()) };
	}
	pub fn get_position(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(movejoint_get_position(self.raw())) };
	}
}