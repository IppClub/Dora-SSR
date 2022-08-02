extern "C" {
	fn entity_type() -> i32;
	fn entity_get_count() -> i32;
	fn entity_get_index(slf: i64) -> i32;
	fn entity_clear();
	fn entity_remove(slf: i64, key: i64);
	fn entity_destroy(slf: i64);
	fn entity_new() -> i64;
}
use crate::dora::Object;
pub struct Entity { raw: i64 }
crate::dora_object!(Entity);
impl Entity {
	pub fn get_count() -> i32 {
		return unsafe { entity_get_count() };
	}
	pub fn get_index(&self) -> i32 {
		return unsafe { entity_get_index(self.raw()) };
	}
	pub fn clear() {
		unsafe { entity_clear() };
	}
	pub fn remove(&mut self, key: &str) {
		unsafe { entity_remove(self.raw(), crate::dora::from_string(key)) };
	}
	pub fn destroy(&mut self) {
		unsafe { entity_destroy(self.raw()) };
	}
	pub fn new() -> Entity {
		return Entity { raw: unsafe { entity_new() } };
	}
}