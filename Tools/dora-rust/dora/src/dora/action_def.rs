/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn actiondef_release(raw: i64);
	fn actiondef_prop(duration: f32, start: f32, stop: f32, prop: i32, easing: i32) -> i64;
	fn actiondef_tint(duration: f32, start: i32, stop: i32, easing: i32) -> i64;
	fn actiondef_roll(duration: f32, start: f32, stop: f32, easing: i32) -> i64;
	fn actiondef_spawn(defs: i64) -> i64;
	fn actiondef_sequence(defs: i64) -> i64;
	fn actiondef_delay(duration: f32) -> i64;
	fn actiondef_show() -> i64;
	fn actiondef_hide() -> i64;
	fn actiondef_event(event_name: i64, msg: i64) -> i64;
	fn actiondef_move_to(duration: f32, start: i64, stop: i64, easing: i32) -> i64;
	fn actiondef_scale(duration: f32, start: f32, stop: f32, easing: i32) -> i64;
	fn actiondef_frame(clip_str: i64, duration: f32) -> i64;
	fn actiondef_frame_with_frames(clip_str: i64, duration: f32, frames: i64) -> i64;
}
pub struct ActionDef { raw: i64 }
impl Drop for ActionDef {
	fn drop(&mut self) { unsafe { actiondef_release(self.raw); } }
}
impl ActionDef {
	pub(crate) fn raw(&self) -> i64 {
		self.raw
	}
	pub(crate) fn from(raw: i64) -> ActionDef {
		ActionDef { raw: raw }
	}
	/// Creates a new action definition object to change a property of a node.
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
	/// * `ActionDef` - A new ActionDef object.
	pub fn prop(duration: f32, start: f32, stop: f32, prop: crate::dora::Property, easing: crate::dora::EaseType) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(actiondef_prop(duration, start, stop, prop as i32, easing as i32)); }
	}
	/// Creates a new action definition object to change the color of a node.
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
	/// * `ActionDef` - A new ActionDef object.
	pub fn tint(duration: f32, start: &crate::dora::Color3, stop: &crate::dora::Color3, easing: crate::dora::EaseType) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(actiondef_tint(duration, start.to_rgb() as i32, stop.to_rgb() as i32, easing as i32)); }
	}
	/// Creates a new action definition object to rotate a node by smallest angle.
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
	/// * `ActionDef` - A new ActionDef object.
	pub fn roll(duration: f32, start: f32, stop: f32, easing: crate::dora::EaseType) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(actiondef_roll(duration, start, stop, easing as i32)); }
	}
	/// Creates a new action definition object to run a group of actions in parallel.
	///
	/// # Arguments
	///
	/// * `defs` - The actions to run in parallel.
	///
	/// # Returns
	///
	/// * `ActionDef` - A new ActionDef object.
	pub fn spawn(defs: &Vec<crate::dora::ActionDef>) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(actiondef_spawn(crate::dora::Vector::from_action_def(defs))); }
	}
	/// Creates a new action definition object to run a group of actions in sequence.
	///
	/// # Arguments
	///
	/// * `defs` - The actions to run in sequence.
	///
	/// # Returns
	///
	/// * `ActionDef` - A new ActionDef object.
	pub fn sequence(defs: &Vec<crate::dora::ActionDef>) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(actiondef_sequence(crate::dora::Vector::from_action_def(defs))); }
	}
	/// Creates a new action definition object to delay the execution of following action.
	///
	/// # Arguments
	///
	/// * `duration` - The duration of the delay.
	///
	/// # Returns
	///
	/// * `ActionDef` - A new ActionDef object.
	pub fn delay(duration: f32) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(actiondef_delay(duration)); }
	}
	/// Creates a new action definition object to show a node.
	pub fn show() -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(actiondef_show()); }
	}
	/// Creates a new action definition object to hide a node.
	pub fn hide() -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(actiondef_hide()); }
	}
	/// Creates a new action definition object to emit an event.
	///
	/// # Arguments
	///
	/// * `eventName` - The name of the event to emit.
	/// * `msg` - The message to send with the event.
	///
	/// # Returns
	///
	/// * `ActionDef` - A new ActionDef object.
	pub fn event(event_name: &str, msg: &str) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(actiondef_event(crate::dora::from_string(event_name), crate::dora::from_string(msg))); }
	}
	/// Creates a new action definition object to move a node.
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
	/// * `ActionDef` - A new ActionDef object.
	pub fn move_to(duration: f32, start: &crate::dora::Vec2, stop: &crate::dora::Vec2, easing: crate::dora::EaseType) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(actiondef_move_to(duration, start.into_i64(), stop.into_i64(), easing as i32)); }
	}
	/// Creates a new action definition object to scale a node.
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
	/// * `ActionDef` - A new ActionDef object.
	pub fn scale(duration: f32, start: f32, stop: f32, easing: crate::dora::EaseType) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(actiondef_scale(duration, start, stop, easing as i32)); }
	}
	/// Creates a new action definition object to do a frame animation. Can only be performed on a Sprite node.
	///
	/// # Arguments
	///
	/// * `clipStr` - The name of the image clip, which is a sprite sheet. Can be "Image/file.png" and "Image/items.clip|itemA". Supports image file format: jpg, png, dds, pvr, ktx.
	/// * `duration` - The duration of the action.
	///
	/// # Returns
	///
	/// * `ActionDef` - A new ActionDef object.
	pub fn frame(clip_str: &str, duration: f32) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(actiondef_frame(crate::dora::from_string(clip_str), duration)); }
	}
	/// Creates a new action definition object to do a frame animation with frames count for each frame. Can only be performed on a Sprite node.
	///
	/// # Arguments
	///
	/// * `clipStr` - The name of the image clip, which is a sprite sheet. Can be "Image/file.png" and "Image/items.clip|itemA". Supports image file format: jpg, png, dds, pvr, ktx.
	/// * `duration` - The duration of the action.
	/// * `frames` - The number of frames for each frame.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	pub fn frame_with_frames(clip_str: &str, duration: f32, frames: &Vec<i32>) -> crate::dora::ActionDef {
		unsafe { return crate::dora::ActionDef::from(actiondef_frame_with_frames(crate::dora::from_string(clip_str), duration, crate::dora::Vector::from_num(frames))); }
	}
}