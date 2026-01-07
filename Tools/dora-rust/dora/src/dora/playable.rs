/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn playable_type() -> i32;
	fn playable_set_look(slf: i64, val: i64);
	fn playable_get_look(slf: i64) -> i64;
	fn playable_set_speed(slf: i64, val: f32);
	fn playable_get_speed(slf: i64) -> f32;
	fn playable_set_recovery(slf: i64, val: f32);
	fn playable_get_recovery(slf: i64) -> f32;
	fn playable_set_fliped(slf: i64, val: i32);
	fn playable_is_fliped(slf: i64) -> i32;
	fn playable_get_current(slf: i64) -> i64;
	fn playable_get_last_completed(slf: i64) -> i64;
	fn playable_get_key(slf: i64, name: i64) -> i64;
	fn playable_play(slf: i64, name: i64, looping: i32) -> f32;
	fn playable_stop(slf: i64);
	fn playable_set_slot(slf: i64, name: i64, item: i64);
	fn playable_get_slot(slf: i64, name: i64) -> i64;
	fn playable_new(filename: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for Playable { }
/// An interface for an animation model system.
pub struct Playable { raw: i64 }
crate::dora_object!(Playable);
impl IPlayable for Playable { }
pub trait IPlayable: INode {
	/// Sets the look of the animation.
	fn set_look(&mut self, val: &str) {
		unsafe { playable_set_look(self.raw(), crate::dora::from_string(val)) };
	}
	/// Gets the look of the animation.
	fn get_look(&self) -> String {
		return unsafe { crate::dora::to_string(playable_get_look(self.raw())) };
	}
	/// Sets the play speed of the animation.
	fn set_speed(&mut self, val: f32) {
		unsafe { playable_set_speed(self.raw(), val) };
	}
	/// Gets the play speed of the animation.
	fn get_speed(&self) -> f32 {
		return unsafe { playable_get_speed(self.raw()) };
	}
	/// Sets the recovery time of the animation, in seconds.
	/// Used for doing transitions from one animation to another animation.
	fn set_recovery(&mut self, val: f32) {
		unsafe { playable_set_recovery(self.raw(), val) };
	}
	/// Gets the recovery time of the animation, in seconds.
	/// Used for doing transitions from one animation to another animation.
	fn get_recovery(&self) -> f32 {
		return unsafe { playable_get_recovery(self.raw()) };
	}
	/// Sets whether the animation is flipped horizontally.
	fn set_fliped(&mut self, val: bool) {
		unsafe { playable_set_fliped(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether the animation is flipped horizontally.
	fn is_fliped(&self) -> bool {
		return unsafe { playable_is_fliped(self.raw()) != 0 };
	}
	/// Gets the current playing animation name.
	fn get_current(&self) -> String {
		return unsafe { crate::dora::to_string(playable_get_current(self.raw())) };
	}
	/// Gets the last completed animation name.
	fn get_last_completed(&self) -> String {
		return unsafe { crate::dora::to_string(playable_get_last_completed(self.raw())) };
	}
	/// Gets a key point on the animation model by its name.
	///
	/// # Arguments
	///
	/// * `name` - The name of the key point to get.
	///
	/// # Returns
	///
	/// * A `Vec2` representing the key point value.
	fn get_key(&mut self, name: &str) -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(playable_get_key(self.raw(), crate::dora::from_string(name))); }
	}
	/// Plays an animation from the model.
	///
	/// # Arguments
	///
	/// * `name` - The name of the animation to play.
	/// * `loop` - Whether to loop the animation or not.
	///
	/// # Returns
	///
	/// * The duration of the animation in seconds.
	fn play(&mut self, name: &str, looping: bool) -> f32 {
		unsafe { return playable_play(self.raw(), crate::dora::from_string(name), if looping { 1 } else { 0 }); }
	}
	/// Stops the currently playing animation.
	fn stop(&mut self) {
		unsafe { playable_stop(self.raw()); }
	}
	/// Attaches a child node to a slot on the animation model.
	///
	/// # Arguments
	///
	/// * `name` - The name of the slot to set.
	/// * `item` - The node to set the slot to.
	fn set_slot(&mut self, name: &str, item: &dyn crate::dora::INode) {
		unsafe { playable_set_slot(self.raw(), crate::dora::from_string(name), item.raw()); }
	}
	/// Gets the child node attached to the animation model.
	///
	/// # Arguments
	///
	/// * `name` - The name of the slot to get.
	///
	/// # Returns
	///
	/// * The node in the slot, or `None` if there is no node in the slot.
	fn get_slot(&mut self, name: &str) -> Option<crate::dora::Node> {
		unsafe { return crate::dora::Node::from(playable_get_slot(self.raw(), crate::dora::from_string(name))); }
	}
}
impl Playable {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { playable_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Playable { raw: raw }))
			}
		})
	}
	/// Creates a new instance of 'Playable' from the specified animation file.
	///
	/// # Arguments
	///
	/// * `filename` - The filename of the animation file to load. Supports DragonBone, Spine2D and Dora Model files.
	/// Should be one of the formats below:
	///     * "model:" + modelFile
	///     * "spine:" + spineStr
	///     * "bone:" + dragonBoneStr
	///
	/// # Returns
	///
	/// * A new instance of 'Playable'. If the file could not be loaded, then `None` is returned.
	pub fn new(filename: &str) -> Option<Playable> {
		unsafe { return Playable::from(playable_new(crate::dora::from_string(filename))); }
	}
}