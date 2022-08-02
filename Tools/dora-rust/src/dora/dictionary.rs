use crate::dora_object;
use crate::dora::{IntoValue, Value, Vector, from_string};

extern "C" {
	fn dictionary_type() -> i32;
	fn dictionary_create() -> i64;
	fn dictionary_set(dict: i64, key: i64, value: i64);
	fn dictionary_get(dict: i64, key: i64) -> i64;
	fn dictionary_len(dict: i64) -> i32;
	fn dictionary_get_keys(dict: i64) -> i64;
	fn dictionary_clear(dict: i64);
}

pub struct Dictionary { raw: i64 }
dora_object!(Dictionary);

impl Dictionary {
	pub fn new() -> Dictionary {
		Dictionary { raw: unsafe { dictionary_create() } }
	}
	pub fn set<'a, T>(&mut self, key: &str, v: T) where T: IntoValue<'a> {
		unsafe { dictionary_set(self.raw, from_string(key), v.val().raw()); }
	}
	pub fn get(&self, key: &str) -> Option<Value> {
		Value::from(unsafe { dictionary_get(self.raw, from_string(key)) })
	}
	pub fn len(&self) -> i32 {
		unsafe { dictionary_len(self.raw) }
	}
	pub fn get_keys(&self) -> Vec<String> {
		Vector::to_str(unsafe { dictionary_get_keys(self.raw) })
	}
	pub fn clear(&mut self) {
		unsafe { dictionary_clear(self.raw); }
	}
}
