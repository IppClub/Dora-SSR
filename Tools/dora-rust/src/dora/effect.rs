extern "C" {
	fn effect_type() -> i32;
	fn effect_add(slf: i64, pass: i64);
	fn effect_get(slf: i64, index: i64) -> i64;
	fn effect_clear(slf: i64);
	fn effect_new(vert_shader: i64, frag_shader: i64) -> i64;
}
use crate::dora::IObject;
pub struct Effect { raw: i64 }
crate::dora_object!(Effect);
impl IEffect for Effect { }
pub trait IEffect: IObject {
	fn add(&mut self, pass: &crate::dora::Pass) {
		unsafe { effect_add(self.raw(), pass.raw()); }
	}
	fn get(&self, index: i64) -> Option<crate::dora::Pass> {
		unsafe { return crate::dora::Pass::from(effect_get(self.raw(), index)); }
	}
	fn clear(&mut self) {
		unsafe { effect_clear(self.raw()); }
	}
}
impl Effect {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { effect_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Effect { raw: raw }))
			}
		})
	}
	pub fn new(vert_shader: &str, frag_shader: &str) -> Effect {
		unsafe { return Effect { raw: effect_new(crate::dora::from_string(vert_shader), crate::dora::from_string(frag_shader)) }; }
	}
}