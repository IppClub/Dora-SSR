extern "C" {
	fn platformer_behavior_blackboard_get_delta_time(slf: i64) -> f64;
	fn platformer_behavior_blackboard_get_owner(slf: i64) -> i64;
}
/// A blackboard object that can be used to store data for behavior tree nodes.
pub struct Blackboard { raw: i64 }
impl Blackboard {
	pub fn from(raw: i64) -> Option<Blackboard> {
		match raw {
			0 => None,
			_ => Some(Blackboard { raw: raw })
		}
	}
	pub fn raw(&self) -> i64 { self.raw }
	/// Gets the time since the last frame update in seconds.
	pub fn get_delta_time(&self) -> f64 {
		return unsafe { platformer_behavior_blackboard_get_delta_time(self.raw()) };
	}
	/// Gets the unit that the AI agent belongs to.
	pub fn get_owner(&self) -> crate::dora::platformer::Unit {
		return unsafe { crate::dora::platformer::Unit::from(platformer_behavior_blackboard_get_owner(self.raw())).unwrap() };
	}
}