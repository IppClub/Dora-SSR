extern "C" {
	fn motorjoint_type() -> i32;
	fn motorjoint_set_enabled(slf: i64, var: i32);
	fn motorjoint_is_enabled(slf: i64) -> i32;
	fn motorjoint_set_force(slf: i64, var: f32);
	fn motorjoint_get_force(slf: i64) -> f32;
	fn motorjoint_set_speed(slf: i64, var: f32);
	fn motorjoint_get_speed(slf: i64) -> f32;
}
use crate::dora::IObject;
use crate::dora::IJoint;
impl IJoint for MotorJoint { }
pub struct MotorJoint { raw: i64 }
crate::dora_object!(MotorJoint);
impl MotorJoint {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { motorjoint_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(MotorJoint { raw: raw }))
			}
		})
	}
	pub fn set_enabled(&mut self, var: bool) {
		unsafe { motorjoint_set_enabled(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_enabled(&self) -> bool {
		return unsafe { motorjoint_is_enabled(self.raw()) != 0 };
	}
	pub fn set_force(&mut self, var: f32) {
		unsafe { motorjoint_set_force(self.raw(), var) };
	}
	pub fn get_force(&self) -> f32 {
		return unsafe { motorjoint_get_force(self.raw()) };
	}
	pub fn set_speed(&mut self, var: f32) {
		unsafe { motorjoint_set_speed(self.raw(), var) };
	}
	pub fn get_speed(&self) -> f32 {
		return unsafe { motorjoint_get_speed(self.raw()) };
	}
}