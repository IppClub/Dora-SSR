extern "C" {
	fn platformer_unitaction_set_reaction(slf: i64, var: f32);
	fn platformer_unitaction_get_reaction(slf: i64) -> f32;
	fn platformer_unitaction_set_recovery(slf: i64, var: f32);
	fn platformer_unitaction_get_recovery(slf: i64) -> f32;
	fn platformer_unitaction_get_name(slf: i64) -> i64;
	fn platformer_unitaction_is_doing(slf: i64) -> i32;
	fn platformer_unitaction_get_owner(slf: i64) -> i64;
	fn platformer_unitaction_get_eclapsed_time(slf: i64) -> f32;
	fn platformer_unitaction_clear();
}
pub struct UnitAction { raw: i64 }
impl UnitAction {
	pub fn from(raw: i64) -> Option<UnitAction> {
		match raw {
			0 => None,
			_ => Some(UnitAction { raw: raw })
		}
	}
	pub fn raw(&self) -> i64 { self.raw }
	pub fn set_reaction(&mut self, var: f32) {
		unsafe { platformer_unitaction_set_reaction(self.raw(), var) };
	}
	pub fn get_reaction(&self) -> f32 {
		return unsafe { platformer_unitaction_get_reaction(self.raw()) };
	}
	pub fn set_recovery(&mut self, var: f32) {
		unsafe { platformer_unitaction_set_recovery(self.raw(), var) };
	}
	pub fn get_recovery(&self) -> f32 {
		return unsafe { platformer_unitaction_get_recovery(self.raw()) };
	}
	pub fn get_name(&self) -> String {
		return unsafe { crate::dora::to_string(platformer_unitaction_get_name(self.raw())) };
	}
	pub fn is_doing(&self) -> bool {
		return unsafe { platformer_unitaction_is_doing(self.raw()) != 0 };
	}
	pub fn get_owner(&self) -> crate::dora::platformer::Unit {
		return unsafe { crate::dora::platformer::Unit::from(platformer_unitaction_get_owner(self.raw())).unwrap() };
	}
	pub fn get_eclapsed_time(&self) -> f32 {
		return unsafe { platformer_unitaction_get_eclapsed_time(self.raw()) };
	}
	pub fn clear() {
		unsafe { platformer_unitaction_clear(); }
	}
}