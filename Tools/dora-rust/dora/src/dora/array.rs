/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

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
/// An array data structure that supports various operations.
pub struct Array { raw: i64 }
crate::dora_object!(Array);
impl Array {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { array_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Array { raw: raw }))
			}
		})
	}
	/// Gets the number of items in the array.
	pub fn get_count(&self) -> i64 {
		return unsafe { array_get_count(self.raw()) };
	}
	/// Gets whether the array is empty or not.
	pub fn is_empty(&self) -> bool {
		return unsafe { array_is_empty(self.raw()) != 0 };
	}
	/// Adds all items from another array to the end of this array.
	///
	/// # Arguments
	///
	/// * `other` - Another array object.
	pub fn add_range(&mut self, other: &crate::dora::Array) {
		unsafe { array_add_range(self.raw(), other.raw()); }
	}
	/// Removes all items from this array that are also in another array.
	///
	/// # Arguments
	///
	/// * `other` - Another array object.
	pub fn remove_from(&mut self, other: &crate::dora::Array) {
		unsafe { array_remove_from(self.raw(), other.raw()); }
	}
	/// Removes all items from the array.
	pub fn clear(&mut self) {
		unsafe { array_clear(self.raw()); }
	}
	/// Reverses the order of the items in the array.
	pub fn reverse(&mut self) {
		unsafe { array_reverse(self.raw()); }
	}
	/// Removes any empty slots from the end of the array.
	/// This method is used to release the unused memory this array holds.
	pub fn shrink(&mut self) {
		unsafe { array_shrink(self.raw()); }
	}
	/// Swaps the items at two given indices.
	///
	/// # Arguments
	///
	/// * `index_a` - The first index.
	/// * `index_b` - The second index.
	pub fn swap(&mut self, index_a: i32, index_b: i32) {
		unsafe { array_swap(self.raw(), index_a, index_b); }
	}
	/// Removes the item at the given index.
	///
	/// # Arguments
	///
	/// * `index` - The index to remove.
	///
	/// # Returns
	///
	/// * `bool` - `true` if an item was removed, `false` otherwise.
	pub fn remove_at(&mut self, index: i32) -> bool {
		unsafe { return array_remove_at(self.raw(), index) != 0; }
	}
	/// Removes the item at the given index without preserving the order of the array.
	///
	/// # Arguments
	///
	/// * `index` - The index to remove.
	///
	/// # Returns
	///
	/// * `bool` - `true` if an item was removed, `false` otherwise.
	pub fn fast_remove_at(&mut self, index: i32) -> bool {
		unsafe { return array_fast_remove_at(self.raw(), index) != 0; }
	}
	/// Creates a new array object
	pub fn new() -> Array {
		unsafe { return Array { raw: array_new() }; }
	}
}