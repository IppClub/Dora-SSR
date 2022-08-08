extern "C" {
	fn action_type() -> i32;
	fn action_get_duration(slf: i64) -> f32;
	fn action_is_running(slf: i64) -> i32;
	fn action_is_paused(slf: i64) -> i32;
	fn action_set_reversed(slf: i64, var: i32);
	fn action_is_reversed(slf: i64) -> i32;
	fn action_set_speed(slf: i64, var: f32);
	fn action_get_speed(slf: i64) -> f32;
	fn action_pause(slf: i64);
	fn action_resume(slf: i64);
	fn action_update_to(slf: i64, eclapsed: f32, reversed: i32);
}
use crate::dora::Object;
pub struct Action { raw: i64 }
crate::dora_object!(Action);
impl Action {
	pub fn get_duration(&self) -> f32 {
		return unsafe { action_get_duration(self.raw()) };
	}
	pub fn is_running(&self) -> bool {
		return unsafe { action_is_running(self.raw()) != 0 };
	}
	pub fn is_paused(&self) -> bool {
		return unsafe { action_is_paused(self.raw()) != 0 };
	}
	pub fn set_reversed(&mut self, var: bool) {
		unsafe { action_set_reversed(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_reversed(&self) -> bool {
		return unsafe { action_is_reversed(self.raw()) != 0 };
	}
	pub fn set_speed(&mut self, var: f32) {
		unsafe { action_set_speed(self.raw(), var) };
	}
	pub fn get_speed(&self) -> f32 {
		return unsafe { action_get_speed(self.raw()) };
	}
	pub fn pause(&mut self) {
		unsafe { action_pause(self.raw()) };
	}
	pub fn resume(&mut self) {
		unsafe { action_resume(self.raw()) };
	}
	pub fn update_to(&mut self, eclapsed: f32, reversed: bool) {
		unsafe { action_update_to(self.raw(), eclapsed, if reversed { 1 } else { 0 }) };
	}
}