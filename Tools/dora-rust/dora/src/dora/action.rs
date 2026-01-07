/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn action_type() -> i32;
	fn action_get_duration(slf: i64) -> f32;
	fn action_is_running(slf: i64) -> i32;
	fn action_is_paused(slf: i64) -> i32;
	fn action_set_reversed(slf: i64, val: i32);
	fn action_is_reversed(slf: i64) -> i32;
	fn action_set_speed(slf: i64, val: f32);
	fn action_get_speed(slf: i64) -> f32;
	fn action_pause(slf: i64);
	fn action_resume(slf: i64);
	fn action_update_to(slf: i64, elapsed: f32, reversed: i32);
	fn action_new(def: i64) -> i64;
}
use crate::dora::IObject;
/// Represents an action that can be run on a node.
pub struct Action { raw: i64 }
crate::dora_object!(Action);
impl Action {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { action_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Action { raw: raw }))
			}
		})
	}
	/// Gets the duration of the action.
	pub fn get_duration(&self) -> f32 {
		return unsafe { action_get_duration(self.raw()) };
	}
	/// Gets whether the action is currently running.
	pub fn is_running(&self) -> bool {
		return unsafe { action_is_running(self.raw()) != 0 };
	}
	/// Gets whether the action is currently paused.
	pub fn is_paused(&self) -> bool {
		return unsafe { action_is_paused(self.raw()) != 0 };
	}
	/// Sets whether the action should be run in reverse.
	pub fn set_reversed(&mut self, val: bool) {
		unsafe { action_set_reversed(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether the action should be run in reverse.
	pub fn is_reversed(&self) -> bool {
		return unsafe { action_is_reversed(self.raw()) != 0 };
	}
	/// Sets the speed at which the action should be run.
	/// Set to 1.0 to get normal speed, Set to 2.0 to get two times faster.
	pub fn set_speed(&mut self, val: f32) {
		unsafe { action_set_speed(self.raw(), val) };
	}
	/// Gets the speed at which the action should be run.
	/// Set to 1.0 to get normal speed, Set to 2.0 to get two times faster.
	pub fn get_speed(&self) -> f32 {
		return unsafe { action_get_speed(self.raw()) };
	}
	/// Pauses the action.
	pub fn pause(&mut self) {
		unsafe { action_pause(self.raw()); }
	}
	/// Resumes the action.
	pub fn resume(&mut self) {
		unsafe { action_resume(self.raw()); }
	}
	/// Updates the state of the Action.
	///
	/// # Arguments
	///
	/// * `elapsed` - The amount of time in seconds that has elapsed to update action to.
	/// * `reversed` - Whether or not to update the Action in reverse.
	pub fn update_to(&mut self, elapsed: f32, reversed: bool) {
		unsafe { action_update_to(self.raw(), elapsed, if reversed { 1 } else { 0 }); }
	}
	/// Creates a new Action object.
	///
	/// # Arguments
	///
	/// * `def` - The definition of the action.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	pub fn new(def: crate::dora::ActionDef) -> Action {
		unsafe { return Action { raw: action_new(def.raw()) }; }
	}
}