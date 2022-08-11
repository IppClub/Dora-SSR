extern "C" {
	fn platformer_targetallow_release(raw: i64);
	fn platformer_targetallow_set_terrain_allowed(slf: i64, var: i32);
	fn platformer_targetallow_is_terrain_allowed(slf: i64) -> i32;
	fn platformer_targetallow_allow(slf: i64, relation: i32, allow: i32);
	fn platformer_targetallow_is_allow(slf: i64, relation: i32) -> i32;
	fn platformer_targetallow_to_value(slf: i64) -> i32;
	fn platformer_targetallow_new() -> i64;
	fn platformer_targetallow_with_value(value: i32) -> i64;
}
pub struct TargetAllow { raw: i64 }
impl Drop for TargetAllow {
	fn drop(&mut self) { unsafe { platformer_targetallow_release(self.raw); } }
}
impl TargetAllow {
	pub fn raw(&self) -> i64 {
		self.raw
	}
	pub fn from(raw: i64) -> TargetAllow {
		TargetAllow { raw: raw }
	}
	pub fn set_terrain_allowed(&mut self, var: bool) {
		unsafe { platformer_targetallow_set_terrain_allowed(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_terrain_allowed(&self) -> bool {
		return unsafe { platformer_targetallow_is_terrain_allowed(self.raw()) != 0 };
	}
	pub fn allow(&mut self, relation: crate::dora::platformer::Relation, allow: bool) {
		unsafe { platformer_targetallow_allow(self.raw(), relation as i32, if allow { 1 } else { 0 }); }
	}
	pub fn is_allow(&mut self, relation: crate::dora::platformer::Relation) -> bool {
		unsafe { return platformer_targetallow_is_allow(self.raw(), relation as i32) != 0; }
	}
	pub fn to_value(&mut self) -> i32 {
		unsafe { return platformer_targetallow_to_value(self.raw()); }
	}
	pub fn new() -> crate::dora::platformer::TargetAllow {
		unsafe { return crate::dora::platformer::TargetAllow::from(platformer_targetallow_new()); }
	}
	pub fn with_value(value: i32) -> crate::dora::platformer::TargetAllow {
		unsafe { return crate::dora::platformer::TargetAllow::from(platformer_targetallow_with_value(value)); }
	}
}