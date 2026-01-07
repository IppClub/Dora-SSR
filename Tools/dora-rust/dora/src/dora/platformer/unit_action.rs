/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn platformer_unitaction_set_reaction(slf: i64, val: f32);
	fn platformer_unitaction_get_reaction(slf: i64) -> f32;
	fn platformer_unitaction_set_recovery(slf: i64, val: f32);
	fn platformer_unitaction_get_recovery(slf: i64) -> f32;
	fn platformer_unitaction_get_name(slf: i64) -> i64;
	fn platformer_unitaction_is_doing(slf: i64) -> i32;
	fn platformer_unitaction_get_owner(slf: i64) -> i64;
	fn platformer_unitaction_get_elapsed_time(slf: i64) -> f32;
	fn platformer_unitaction_clear();
	fn platformer_unitaction_add(name: i64, priority: i32, reaction: f32, recovery: f32, queued: i32, func0: i32, stack0: i64, func1: i32, stack1: i64, func2: i32, stack2: i64);
}
/// A struct that represents an action that can be performed by a "Unit".
pub struct UnitAction { raw: i64 }
impl UnitAction {
	pub(crate) fn from(raw: i64) -> Option<UnitAction> {
		match raw {
			0 => None,
			_ => Some(UnitAction { raw: raw })
		}
	}
	pub(crate) fn raw(&self) -> i64 { self.raw }
	/// Sets the length of the reaction time for the "UnitAction", in seconds.
	/// The reaction time will affect the AI check cycling time.
	pub fn set_reaction(&mut self, val: f32) {
		unsafe { platformer_unitaction_set_reaction(self.raw(), val) };
	}
	/// Gets the length of the reaction time for the "UnitAction", in seconds.
	/// The reaction time will affect the AI check cycling time.
	pub fn get_reaction(&self) -> f32 {
		return unsafe { platformer_unitaction_get_reaction(self.raw()) };
	}
	/// Sets the length of the recovery time for the "UnitAction", in seconds.
	/// The recovery time will mainly affect how long the `Playable` animation model will do transitions between animations played by different actions.
	pub fn set_recovery(&mut self, val: f32) {
		unsafe { platformer_unitaction_set_recovery(self.raw(), val) };
	}
	/// Gets the length of the recovery time for the "UnitAction", in seconds.
	/// The recovery time will mainly affect how long the `Playable` animation model will do transitions between animations played by different actions.
	pub fn get_recovery(&self) -> f32 {
		return unsafe { platformer_unitaction_get_recovery(self.raw()) };
	}
	/// Gets the name of the "UnitAction".
	pub fn get_name(&self) -> String {
		return unsafe { crate::dora::to_string(platformer_unitaction_get_name(self.raw())) };
	}
	/// Gets whether the "Unit" is currently performing the "UnitAction" or not.
	pub fn is_doing(&self) -> bool {
		return unsafe { platformer_unitaction_is_doing(self.raw()) != 0 };
	}
	/// Gets the "Unit" that owns this "UnitAction".
	pub fn get_owner(&self) -> crate::dora::platformer::Unit {
		return unsafe { crate::dora::platformer::Unit::from(platformer_unitaction_get_owner(self.raw())).unwrap() };
	}
	/// Gets the elapsed time since the "UnitAction" was started, in seconds.
	pub fn get_elapsed_time(&self) -> f32 {
		return unsafe { platformer_unitaction_get_elapsed_time(self.raw()) };
	}
	/// Removes all "UnitAction" objects from the "UnitActionClass".
	pub fn clear() {
		unsafe { platformer_unitaction_clear(); }
	}
	/// Adds a new "UnitAction" to the "UnitActionClass" with the specified name and parameters.
	///
	/// # Arguments
	///
	/// * `name` - The name of the "UnitAction".
	/// * `priority` - The priority level for the "UnitAction". `UnitAction` with higher priority (larger number) will replace the running lower priority `UnitAction`. If performing `UnitAction` having the same priority with the running `UnitAction` and the `UnitAction` to perform having the param 'queued' to be true, the running `UnitAction` won't be replaced.
	/// * `reaction` - The length of the reaction time for the "UnitAction", in seconds. The reaction time will affect the AI check cycling time. Set to 0.0 to make AI check run in every update.
	/// * `recovery` - The length of the recovery time for the "UnitAction", in seconds. The recovery time will mainly affect how long the `Playable` animation model will do transitions between animations played by different actions.
	/// * `queued` - Whether the "UnitAction" is currently queued or not. The queued "UnitAction" won't replace the running "UnitAction" with a same priority.
	/// * `available` - A function that takes a `Unit` object and a `UnitAction` object and returns a boolean value indicating whether the "UnitAction" is available to be performed.
	/// * `create` - A function that takes a `Unit` object and a `UnitAction` object and returns a `WasmActionUpdate` object that contains the update function for the "UnitAction".
	/// * `stop` - A function that takes a `Unit` object and a `UnitAction` object and stops the "UnitAction".
	pub fn add(name: &str, priority: i32, reaction: f32, recovery: f32, queued: bool, mut available: Box<dyn FnMut(&crate::dora::platformer::Unit, &crate::dora::platformer::UnitAction) -> bool>, mut create: Box<dyn FnMut(&crate::dora::platformer::Unit, &crate::dora::platformer::UnitAction) -> crate::dora::platformer::ActionUpdate>, mut stop: Box<dyn FnMut(&crate::dora::platformer::Unit, &crate::dora::platformer::UnitAction)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = available(&stack0.pop_cast::<crate::dora::platformer::Unit>().unwrap(), &crate::dora::platformer::UnitAction::from(stack0.pop_i64().unwrap()).unwrap());
			stack0.push_bool(result);
		}));
		let mut stack1 = crate::dora::CallStack::new();
		let stack_raw1 = stack1.raw();
		let func_id1 = crate::dora::push_function(Box::new(move || {
			let result = create(&stack1.pop_cast::<crate::dora::platformer::Unit>().unwrap(), &crate::dora::platformer::UnitAction::from(stack1.pop_i64().unwrap()).unwrap());
			stack1.push_object(&result);
		}));
		let mut stack2 = crate::dora::CallStack::new();
		let stack_raw2 = stack2.raw();
		let func_id2 = crate::dora::push_function(Box::new(move || {
			stop(&stack2.pop_cast::<crate::dora::platformer::Unit>().unwrap(), &crate::dora::platformer::UnitAction::from(stack2.pop_i64().unwrap()).unwrap())
		}));
		unsafe { platformer_unitaction_add(crate::dora::from_string(name), priority, reaction, recovery, if queued { 1 } else { 0 }, func_id0, stack_raw0, func_id1, stack_raw1, func_id2, stack_raw2); }
	}
}