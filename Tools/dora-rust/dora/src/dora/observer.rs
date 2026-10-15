/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn observer_type() -> i32;
	fn entityobserver_new(event: i32, components: i64) -> i64;
}
use crate::dora::IObject;
/// A struct representing an observer of entity changes in the game systems.
pub struct Observer { raw: i64 }
crate::dora_object!(Observer);
impl Observer {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { observer_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Observer { raw: raw }))
			}
		})
	}
	/// A method that creates a new observer with the specified component filter and action to watch for.
	///
	/// # Arguments
	///
	/// * `event` - The type of event to watch for.
	/// * `components` - A vector listing the names of the components to filter entities by.
	///
	/// # Returns
	///
	/// * `Observer` - The new observer.
	pub fn new(event: crate::dora::EntityEvent, components: &Vec<&str>) -> Observer {
		unsafe { return Observer { raw: entityobserver_new(event as i32, crate::dora::Vector::from_str(components)) }; }
	}
}