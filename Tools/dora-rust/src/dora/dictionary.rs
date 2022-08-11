extern "C" {
	fn dictionary_type() -> i32;
	fn dictionary_get_count(slf: i64) -> i32;
	fn dictionary_get_keys(slf: i64) -> i64;
	fn dictionary_clear(slf: i64);
	fn dictionary_new() -> i64;
}
use crate::dora::IObject;
pub struct Dictionary { raw: i64 }
crate::dora_object!(Dictionary);
impl Dictionary {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { dictionary_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Dictionary { raw: raw }))
			}
		})
	}
	pub fn get_count(&self) -> i32 {
		return unsafe { dictionary_get_count(self.raw()) };
	}
	pub fn get_keys(&self) -> Vec<String> {
		return unsafe { crate::dora::Vector::to_str(dictionary_get_keys(self.raw())) };
	}
	pub fn clear(&mut self) {
		unsafe { dictionary_clear(self.raw()); }
	}
	pub fn new() -> Dictionary {
		unsafe { return Dictionary { raw: dictionary_new() }; }
	}
}