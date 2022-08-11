extern "C" {
	fn platformer_behavior_blackboard_get_delta_time(slf: i64) -> f64;
	fn platformer_behavior_blackboard_get_owner(slf: i64) -> i64;
}
pub struct Blackboard { raw: i64 }
impl Blackboard {
	pub fn from(raw: i64) -> Option<Blackboard> {
		match raw {
			0 => None,
			_ => Some(Blackboard { raw: raw })
		}
	}
	pub fn raw(&self) -> i64 { self.raw }
	pub fn get_delta_time(&self) -> f64 {
		return unsafe { platformer_behavior_blackboard_get_delta_time(self.raw()) };
	}
	pub fn get_owner(&self) -> crate::dora::platformer::Unit {
		return unsafe { crate::dora::platformer::Unit::from(platformer_behavior_blackboard_get_owner(self.raw())).unwrap() };
	}
}