/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn dictionary_type() -> i32;
	fn dictionary_get_count(slf: i64) -> i32;
	fn dictionary_get_keys(slf: i64) -> i64;
	fn dictionary_clear(slf: i64);
	fn dictionary_new() -> i64;
}
use crate::dora::IObject;
/// A struct for storing pairs of string keys and various values.
pub struct Dictionary { raw: i64 }
crate::dora_object!(Dictionary);
impl Dictionary {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { dictionary_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Dictionary { raw: raw }))
			}
		})
	}
	/// Gets the number of items in the dictionary.
	pub fn get_count(&self) -> i32 {
		return unsafe { dictionary_get_count(self.raw()) };
	}
	/// Gets the keys of the items in the dictionary.
	pub fn get_keys(&self) -> Vec<String> {
		return unsafe { crate::dora::Vector::to_str(dictionary_get_keys(self.raw())) };
	}
	/// Removes all the items from the dictionary.
	pub fn clear(&mut self) {
		unsafe { dictionary_clear(self.raw()); }
	}
	/// Creates instance of the "Dictionary".
	pub fn new() -> Dictionary {
		unsafe { return Dictionary { raw: dictionary_new() }; }
	}
}