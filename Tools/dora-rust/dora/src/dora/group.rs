/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn group_type() -> i32;
	fn entitygroup_get_count(slf: i64) -> i32;
	fn entitygroup_get_first(slf: i64) -> i64;
	fn entitygroup_find(slf: i64, func0: i32, stack0: i64) -> i64;
	fn entitygroup_new(components: i64) -> i64;
}
use crate::dora::IObject;
/// A struct representing a group of entities in the ECS game systems.
pub struct Group { raw: i64 }
crate::dora_object!(Group);
impl Group {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { group_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Group { raw: raw }))
			}
		})
	}
	/// Gets the number of entities in the group.
	pub fn get_count(&self) -> i32 {
		return unsafe { entitygroup_get_count(self.raw()) };
	}
	/// Gets the first entity in the group.
	pub fn get_first(&self) -> Option<crate::dora::Entity> {
		return unsafe { crate::dora::Entity::from(entitygroup_get_first(self.raw())) };
	}
	/// Finds the first entity in the group that satisfies a predicate function.
	///
	/// # Arguments
	///
	/// * `predicate` - The predicate function to test each entity with.
	///
	/// # Returns
	///
	/// * `Option<Entity>` - The first entity that satisfies the predicate, or None if no entity does.
	pub fn find(&self, mut predicate: Box<dyn FnMut(&crate::dora::Entity) -> bool>) -> Option<crate::dora::Entity> {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = predicate(&stack0.pop_cast::<crate::dora::Entity>().unwrap());
			stack0.push_bool(result);
		}));
		unsafe { return crate::dora::Entity::from(entitygroup_find(self.raw(), func_id0, stack_raw0)); }
	}
	/// A method that creates a new group with the specified component names.
	///
	/// # Arguments
	///
	/// * `components` - A vector listing the names of the components to include in the group.
	///
	/// # Returns
	///
	/// * `Group` - The new group.
	pub fn new(components: &Vec<&str>) -> Group {
		unsafe { return Group { raw: entitygroup_new(crate::dora::Vector::from_str(components)) }; }
	}
}