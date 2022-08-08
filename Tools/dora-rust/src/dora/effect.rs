extern "C" {
	fn effect_type() -> i32;
	fn effect_add(slf: i64, pass: i64);
	fn effect_get(slf: i64, index: i64) -> i64;
	fn effect_clear(slf: i64);
	fn effect_new(vert_shader: i64, frag_shader: i64) -> i64;
}
use crate::dora::Object;
pub struct Effect { raw: i64 }
crate::dora_object!(Effect);
impl IEffect for Effect { }
pub trait IEffect: Object {
	fn add(&mut self, pass: &crate::dora::Pass) {
		unsafe { effect_add(self.raw(), pass.raw()) };
	}
	fn get(&self, index: i64) -> Option<crate::dora::Pass> {
		return crate::dora::Pass::from(unsafe { effect_get(self.raw(), index) });
	}
	fn clear(&mut self) {
		unsafe { effect_clear(self.raw()) };
	}
}
impl Effect {
	pub fn new(vert_shader: &str, frag_shader: &str) -> Effect {
		return Effect { raw: unsafe { effect_new(crate::dora::from_string(vert_shader), crate::dora::from_string(frag_shader)) } };
	}
}