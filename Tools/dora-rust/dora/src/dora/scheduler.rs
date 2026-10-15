/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn scheduler_type() -> i32;
	fn scheduler_set_time_scale(slf: i64, val: f32);
	fn scheduler_get_time_scale(slf: i64) -> f32;
	fn scheduler_set_fixed_fps(slf: i64, val: i32);
	fn scheduler_get_fixed_fps(slf: i64) -> i32;
	fn scheduler_update(slf: i64, delta_time: f64) -> i32;
	fn scheduler_new() -> i64;
}
use crate::dora::IObject;
/// A scheduler that manages the execution of scheduled tasks.
pub struct Scheduler { raw: i64 }
crate::dora_object!(Scheduler);
impl Scheduler {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { scheduler_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Scheduler { raw: raw }))
			}
		})
	}
	/// Sets the time scale factor for the scheduler.
	/// This factor is applied to deltaTime that the scheduled functions will receive.
	pub fn set_time_scale(&mut self, val: f32) {
		unsafe { scheduler_set_time_scale(self.raw(), val) };
	}
	/// Gets the time scale factor for the scheduler.
	/// This factor is applied to deltaTime that the scheduled functions will receive.
	pub fn get_time_scale(&self) -> f32 {
		return unsafe { scheduler_get_time_scale(self.raw()) };
	}
	/// Sets the target frame rate (in frames per second) for a fixed update mode.
	/// The fixed update will ensure a constant frame rate, and the operation handled in a fixed update can use a constant delta time value.
	/// It is used for preventing weird behavior of a physics engine or synchronizing some states via network communications.
	pub fn set_fixed_fps(&mut self, val: i32) {
		unsafe { scheduler_set_fixed_fps(self.raw(), val) };
	}
	/// Gets the target frame rate (in frames per second) for a fixed update mode.
	/// The fixed update will ensure a constant frame rate, and the operation handled in a fixed update can use a constant delta time value.
	/// It is used for preventing weird behavior of a physics engine or synchronizing some states via network communications.
	pub fn get_fixed_fps(&self) -> i32 {
		return unsafe { scheduler_get_fixed_fps(self.raw()) };
	}
	/// Used for manually updating the scheduler if it is created by the user.
	///
	/// # Arguments
	///
	/// * `deltaTime` - The time in seconds since the last frame update.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the scheduler was stoped, `false` otherwise.
	pub fn update(&mut self, delta_time: f64) -> bool {
		unsafe { return scheduler_update(self.raw(), delta_time) != 0; }
	}
	/// Creates a new Scheduler object.
	pub fn new() -> Scheduler {
		unsafe { return Scheduler { raw: scheduler_new() }; }
	}
}