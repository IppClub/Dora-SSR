/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn action_type() -> i32;
	fn action_get_duration(slf: i64) -> f32;
	fn action_is_running(slf: i64) -> i32;
	fn action_is_paused(slf: i64) -> i32;
	fn action_set_reversed(slf: i64, var: i32);
	fn action_is_reversed(slf: i64) -> i32;
	fn action_set_speed(slf: i64, var: f32);
	fn action_get_speed(slf: i64) -> f32;
	fn action_pause(slf: i64);
	fn action_resume(slf: i64);
	fn action_update_to(slf: i64, elapsed: f32, reversed: i32);
	fn action_prop(duration: f32, start: f32, stop: f32, prop: i32, easing: i32) -> i64;
	fn action_tint(duration: f32, start: i32, stop: i32, easing: i32) -> i64;
	fn action_roll(duration: f32, start: f32, stop: f32, easing: i32) -> i64;
	fn action_spawn(defs: i64) -> i64;
	fn action_sequence(defs: i64) -> i64;
	fn action_delay(duration: f32) -> i64;
	fn action_show() -> i64;
	fn action_hide() -> i64;
	fn action_event(event_name: i64, msg: i64) -> i64;
	fn action_move_to(duration: f32, start: i64, stop: i64, easing: i32) -> i64;
	fn action_scale(duration: f32, start: f32, stop: f32, easing: i32) -> i64;
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
	pub fn set_reversed(&mut self, var: bool) {
		unsafe { action_set_reversed(self.raw(), if var { 1 } else { 0 }) };
	}
	/// Gets whether the action should be run in reverse.
	pub fn is_reversed(&self) -> bool {
		return unsafe { action_is_reversed(self.raw()) != 0 };
	}
	/// Sets the speed at which the action should be run.
	/// Set to 1.0 to get normal speed, Set to 2.0 to get two times faster.
	pub fn set_speed(&mut self, var: f32) {
		unsafe { action_set_speed(self.raw(), var) };
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
	/// Creates a new Action object to change a property of a node.
	///
	/// # Arguments
	///
	/// * `duration` - The duration of the action.
	/// * `start` - The starting value of the property.
	/// * `stop` - The ending value of the property.
	/// * `prop` - The property to change.
	/// * `easing` - The easing function to use.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	pub fn prop(duration: f32, start: f32, stop: f32, prop: crate::dora::Property, easing: crate::dora::EaseType) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_prop(duration, start, stop, prop as i32, easing as i32)); }
	}
	/// Creates a new Action object to change the color of a node.
	///
	/// # Arguments
	///
	/// * `duration` - The duration of the action.
	/// * `start` - The starting color.
	/// * `stop` - The ending color.
	/// * `easing` - The easing function to use.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	pub fn tint(duration: f32, start: &crate::dora::Color3, stop: &crate::dora::Color3, easing: crate::dora::EaseType) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_tint(duration, start.to_rgb() as i32, stop.to_rgb() as i32, easing as i32)); }
	}
	/// Creates a new Action object to rotate a node by smallest angle.
	///
	/// # Arguments
	///
	/// * `duration` - The duration of the action.
	/// * `start` - The starting angle.
	/// * `stop` - The ending angle.
	/// * `easing` - The easing function to use.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	pub fn roll(duration: f32, start: f32, stop: f32, easing: crate::dora::EaseType) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_roll(duration, start, stop, easing as i32)); }
	}
	/// Creates a new Action object to run a group of actions in parallel.
	///
	/// # Arguments
	///
	/// * `defs` - The actions to run in parallel.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	pub fn spawn(defs: &Vec<crate::dora::ActionDef>) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_spawn(crate::dora::Vector::from_action_def(defs))); }
	}
	/// Creates a new Action object to run a group of actions in sequence.
	///
	/// # Arguments
	///
	/// * `defs` - The actions to run in sequence.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	pub fn sequence(defs: &Vec<crate::dora::ActionDef>) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_sequence(crate::dora::Vector::from_action_def(defs))); }
	}
	/// Creates a new Action object to delay the execution of following action.
	///
	/// # Arguments
	///
	/// * `duration` - The duration of the delay.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	pub fn delay(duration: f32) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_delay(duration)); }
	}
	/// Creates a new Action object to show a node.
	pub fn show() -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_show()); }
	}
	/// Creates a new Action object to hide a node.
	pub fn hide() -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_hide()); }
	}
	/// Creates a new Action object to emit an event.
	///
	/// # Arguments
	///
	/// * `eventName` - The name of the event to emit.
	/// * `msg` - The message to send with the event.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	pub fn event(event_name: &str, msg: &str) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_event(crate::dora::from_string(event_name), crate::dora::from_string(msg))); }
	}
	/// Creates a new Action object to move a node.
	///
	/// # Arguments
	///
	/// * `duration` - The duration of the action.
	/// * `start` - The starting position.
	/// * `stop` - The ending position.
	/// * `easing` - The easing function to use.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	pub fn move_to(duration: f32, start: &crate::dora::Vec2, stop: &crate::dora::Vec2, easing: crate::dora::EaseType) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_move_to(duration, start.into_i64(), stop.into_i64(), easing as i32)); }
	}
	/// Creates a new Action object to scale a node.
	///
	/// # Arguments
	///
	/// * `duration` - The duration of the action.
	/// * `start` - The starting scale.
	/// * `stop` - The ending scale.
	/// * `easing` - The easing function to use.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	pub fn scale(duration: f32, start: f32, stop: f32, easing: crate::dora::EaseType) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(action_scale(duration, start, stop, easing as i32)); }
	}
}