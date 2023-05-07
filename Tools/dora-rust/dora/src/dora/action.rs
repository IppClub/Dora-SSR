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
	fn action_prop(duration: f32, start: f32, stop: f32, prop: i32, easing: i32) -> i64;
	fn action_tint(duration: f32, start: i32, stop: i32, easing: i32) -> i64;
	fn action_roll(duration: f32, start: f32, stop: f32, easing: i32) -> i64;
	fn action_spawn(defs: i64) -> i64;
	fn action_sequence(defs: i64) -> i64;
	fn action_delay(duration: f32) -> i64;
	fn action_show() -> i64;
	fn action_hide() -> i64;
	fn action_event(event_name: i64, msg: i64) -> i64;
	fn action_move_to(duration: f32, start: i64, stop: i64, easing: i32) -> i64;
	fn action_scale(duration: f32, start: f32, stop: f32, easing: i32) -> i64;
}
use crate::dora::IObject;
pub struct Action { raw: i64 }
crate::dora_object!(Action);
impl Action {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { action_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Action { raw: raw }))
			}
		})
	}
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
		unsafe { action_pause(self.raw()); }
	}
	pub fn resume(&mut self) {
		unsafe { action_resume(self.raw()); }
	}
	pub fn update_to(&mut self, eclapsed: f32, reversed: bool) {
		unsafe { action_update_to(self.raw(), eclapsed, if reversed { 1 } else { 0 }); }
	}
	pub fn prop(duration: f32, start: f32, stop: f32, prop: crate::dora::Property, easing: crate::dora::EaseType) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_prop(duration, start, stop, prop as i32, easing as i32)); }
	}
	pub fn tint(duration: f32, start: &crate::dora::Color3, stop: &crate::dora::Color3, easing: crate::dora::EaseType) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_tint(duration, start.to_rgb() as i32, stop.to_rgb() as i32, easing as i32)); }
	}
	pub fn roll(duration: f32, start: f32, stop: f32, easing: crate::dora::EaseType) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_roll(duration, start, stop, easing as i32)); }
	}
	pub fn spawn(defs: &Vec<crate::dora::ActionDef>) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_spawn(crate::dora::Vector::from_action_def(defs))); }
	}
	pub fn sequence(defs: &Vec<crate::dora::ActionDef>) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_sequence(crate::dora::Vector::from_action_def(defs))); }
	}
	pub fn delay(duration: f32) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_delay(duration)); }
	}
	pub fn show() -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_show()); }
	}
	pub fn hide() -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_hide()); }
	}
	pub fn event(event_name: &str, msg: &str) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_event(crate::dora::from_string(event_name), crate::dora::from_string(msg))); }
	}
	pub fn move_to(duration: f32, start: &crate::dora::Vec2, stop: &crate::dora::Vec2, easing: crate::dora::EaseType) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_move_to(duration, start.into_i64(), stop.into_i64(), easing as i32)); }
	}
	pub fn scale(duration: f32, start: f32, stop: f32, easing: crate::dora::EaseType) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_scale(duration, start, stop, easing as i32)); }
	}
}