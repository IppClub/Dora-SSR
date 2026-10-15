/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn entity_type() -> i32;
	fn entity_get_count() -> i32;
	fn entity_get_index(slf: i64) -> i32;
	fn entity_clear();
	fn entity_remove(slf: i64, key: i64);
	fn entity_destroy(slf: i64);
	fn entity_new() -> i64;
}
use crate::dora::IObject;
/// A struct representing an entity for an ECS game system.
pub struct Entity { raw: i64 }
crate::dora_object!(Entity);
impl Entity {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { entity_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Entity { raw: raw }))
			}
		})
	}
	/// Gets the number of all running entities.
	pub fn get_count() -> i32 {
		return unsafe { entity_get_count() };
	}
	/// Gets the index of the entity.
	pub fn get_index(&self) -> i32 {
		return unsafe { entity_get_index(self.raw()) };
	}
	/// Clears all entities.
	pub fn clear() {
		unsafe { entity_clear(); }
	}
	/// Removes a property of the entity.
	///
	/// This function will trigger events for Observer objects.
	///
	/// # Arguments
	///
	/// * `key` - The name of the property to remove.
	pub fn remove(&mut self, key: &str) {
		unsafe { entity_remove(self.raw(), crate::dora::from_string(key)); }
	}
	/// Destroys the entity.
	pub fn destroy(&mut self) {
		unsafe { entity_destroy(self.raw()); }
	}
	/// Creates a new entity.
	pub fn new() -> Entity {
		unsafe { return Entity { raw: entity_new() }; }
	}
}