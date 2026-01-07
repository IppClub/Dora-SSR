/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn platformer_actionupdate_type() -> i32;
	fn platformer_wasmactionupdate_new(func0: i32, stack0: i64) -> i64;
}
use crate::dora::IObject;
pub struct ActionUpdate { raw: i64 }
crate::dora_object!(ActionUpdate);
impl ActionUpdate {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { platformer_actionupdate_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(ActionUpdate { raw: raw }))
			}
		})
	}
	pub fn new(mut update: Box<dyn FnMut(&crate::dora::platformer::Unit, &crate::dora::platformer::UnitAction, f32) -> bool>) -> ActionUpdate {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = update(&stack0.pop_cast::<crate::dora::platformer::Unit>().unwrap(), &crate::dora::platformer::UnitAction::from(stack0.pop_i64().unwrap()).unwrap(), stack0.pop_f32().unwrap());
			stack0.push_bool(result);
		}));
		unsafe { return ActionUpdate { raw: platformer_wasmactionupdate_new(func_id0, stack_raw0) }; }
	}
}