use crate::dora_object;
use crate::dora::{IntoValue, Value};

extern "C" {
	fn array_type() -> i32;
	fn array_create() -> i64;
	fn array_set(array: i64, index: i32, item: i64) -> i32;
	fn array_get(array: i64, index: i32) -> i64;
	fn array_len(array: i64) -> i32;
	fn array_capacity(array: i64) -> i32;
	fn array_is_empty(array: i64) -> i32;
	fn array_add_range(array: i64, other: i64);
	fn array_remove_from(array: i64, other: i64);
	fn array_clear(array: i64);
	fn array_reverse(array: i64);
	fn array_shrink(array: i64);
	fn array_swap(array: i64, indexA: i32, indexB: i32);
	fn array_remove_at(array: i64, index: i32) -> i32;
	fn array_fast_remove_at(array: i64, index: i32) -> i32;
	fn array_first(array: i64) -> i64;
	fn array_last(array: i64) -> i64;
	fn array_random_object(array: i64) -> i64;
	fn array_add(array: i64, item: i64);
	fn array_insert(array: i64, index: i32, item: i64);
	fn array_contains(array: i64, item: i64) -> i32;
	fn array_index(array: i64, item: i64) -> i32;
	fn array_remove_last(array: i64) -> i64;
	fn array_fast_remove(array: i64, item: i64) -> i32;
}

pub struct Array { raw: i64 }
dora_object!(Array);

impl Array {
	pub fn new() -> Array {
		Array { raw: unsafe { array_create() } }
	}
	pub fn set<'a, T>(&mut self, index: i32, v: T) where T: IntoValue<'a> {
		if unsafe { array_set(self.raw, index, v.val().raw()) == 0 } {
			panic!("Out of bounds, expecting [0, {}), got {}", self.len(), index);
		}
	}
	pub fn get(&self, index: i32) -> Option<Value> {
		Value::from(unsafe { array_get(self.raw, index) })
	}
	pub fn first(&self) -> Option<Value> {
		Value::from(unsafe { array_first(self.raw) })
	}
	pub fn last(&self) -> Option<Value> {
		Value::from(unsafe { array_last(self.raw) })
	}
	pub fn random_object(&self) -> Option<Value> {
		Value::from(unsafe { array_random_object(self.raw) })
	}
	pub fn add<'a, T>(&mut self, v: T) where T: IntoValue<'a> {
		unsafe { array_add(self.raw, v.val().raw()); }
	}
	pub fn insert<'a, T>(&mut self, index: i32, v: T) where T: IntoValue<'a> {
		unsafe { array_insert(self.raw, index, v.val().raw()); }
	}
	pub fn contains<'a, T>(&self, v: T) -> bool where T: IntoValue<'a> {
		unsafe { array_contains(self.raw, v.val().raw()) != 0 }
	}
	pub fn index<'a, T>(&self, v: T) -> i32 where T: IntoValue<'a> {
		unsafe { array_index(self.raw, v.val().raw()) }
	}
	pub fn remove_last(&mut self) -> Option<Value> {
		Value::from(unsafe { array_remove_last(self.raw) })
	}
	pub fn fast_remove<'a, T>(&mut self, v: T) -> bool where T: IntoValue<'a> {
		unsafe { array_fast_remove(self.raw, v.val().raw()) != 0 }
	}
	pub fn len(&self) -> i32 {
		unsafe { array_len(self.raw) }
	}
	pub fn capacity(&self) -> i32 {
		unsafe { array_capacity(self.raw) }
	}
	pub fn is_empty(&self) -> bool {
		unsafe { array_is_empty(self.raw) != 0 }
	}
	pub fn add_range(&mut self, other: &Array) {
		unsafe { array_add_range(self.raw, other.raw); }
	}
	pub fn remove_from(&mut self, other: &Array) {
		unsafe { array_remove_from(self.raw, other.raw); }
	}
	pub fn clear(&mut self) {
		unsafe { array_clear(self.raw); }
	}
	pub fn reverse(&mut self) {
		unsafe { array_reverse(self.raw); }
	}
	pub fn shrink(&mut self) {
		unsafe { array_shrink(self.raw); }
	}
	pub fn swap(&mut self, index_a: i32, index_b: i32) {
		unsafe { array_swap(self.raw, index_a, index_b); }
	}
	pub fn remove_at(&mut self, index: i32) -> bool {
		unsafe { array_remove_at(self.raw, index) != 0 }
	}
	pub fn fast_remove_at(&mut self, index: i32) -> bool {
		unsafe { array_fast_remove_at(self.raw, index) != 0 }
	}
}