extern "C" {
	fn array_type() -> i32;
	fn array_get_count(slf: i64) -> i64;
	fn array_is_empty(slf: i64) -> i32;
	fn array_add_range(slf: i64, other: i64);
	fn array_remove_from(slf: i64, other: i64);
	fn array_clear(slf: i64);
	fn array_reverse(slf: i64);
	fn array_shrink(slf: i64);
	fn array_swap(slf: i64, index_a: i32, index_b: i32);
	fn array_remove_at(slf: i64, index: i32) -> i32;
	fn array_fast_remove_at(slf: i64, index: i32) -> i32;
	fn array_new() -> i64;
}
use crate::dora::IObject;
pub struct Array { raw: i64 }
crate::dora_object!(Array);
impl Array {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { array_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Array { raw: raw }))
			}
		})
	}
	pub fn get_count(&self) -> i64 {
		return unsafe { array_get_count(self.raw()) };
	}
	pub fn is_empty(&self) -> bool {
		return unsafe { array_is_empty(self.raw()) != 0 };
	}
	pub fn add_range(&mut self, other: &crate::dora::Array) {
		unsafe { array_add_range(self.raw(), other.raw()); }
	}
	pub fn remove_from(&mut self, other: &crate::dora::Array) {
		unsafe { array_remove_from(self.raw(), other.raw()); }
	}
	pub fn clear(&mut self) {
		unsafe { array_clear(self.raw()); }
	}
	pub fn reverse(&mut self) {
		unsafe { array_reverse(self.raw()); }
	}
	pub fn shrink(&mut self) {
		unsafe { array_shrink(self.raw()); }
	}
	pub fn swap(&mut self, index_a: i32, index_b: i32) {
		unsafe { array_swap(self.raw(), index_a, index_b); }
	}
	pub fn remove_at(&mut self, index: i32) -> bool {
		unsafe { return array_remove_at(self.raw(), index) != 0; }
	}
	pub fn fast_remove_at(&mut self, index: i32) -> bool {
		unsafe { return array_fast_remove_at(self.raw(), index) != 0; }
	}
	pub fn new() -> Array {
		unsafe { return Array { raw: array_new() }; }
	}
}