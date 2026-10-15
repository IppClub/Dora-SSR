/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn platformer_visual_type() -> i32;
	fn platformer_visual_is_playing(slf: i64) -> i32;
	fn platformer_visual_start(slf: i64);
	fn platformer_visual_stop(slf: i64);
	fn platformer_visual_auto_remove(slf: i64) -> i64;
	fn platformer_visual_new(name: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for Visual { }
/// A struct represents a visual effect object like Particle, Frame Animation or just a Sprite.
pub struct Visual { raw: i64 }
crate::dora_object!(Visual);
impl Visual {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { platformer_visual_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Visual { raw: raw }))
			}
		})
	}
	/// Gets whether the visual effect is currently playing or not.
	pub fn is_playing(&self) -> bool {
		return unsafe { platformer_visual_is_playing(self.raw()) != 0 };
	}
	/// Starts playing the visual effect.
	pub fn start(&mut self) {
		unsafe { platformer_visual_start(self.raw()); }
	}
	/// Stops playing the visual effect.
	pub fn stop(&mut self) {
		unsafe { platformer_visual_stop(self.raw()); }
	}
	/// Automatically removes the visual effect from the game world when it finishes playing.
	///
	/// # Returns
	///
	/// * `Visual` - The same `Visual` object that was passed in as a parameter.
	pub fn auto_remove(&mut self) -> crate::dora::platformer::Visual {
		unsafe { return crate::dora::platformer::Visual::from(platformer_visual_auto_remove(self.raw())).unwrap(); }
	}
	/// Creates a new `Visual` object with the specified name.
	///
	/// # Arguments
	///
	/// * `name` - The name of the new `Visual` object. Could be a particle file, a frame animation file or an image file.
	///
	/// # Returns
	///
	/// * `Visual` - The new `Visual` object.
	pub fn new(name: &str) -> Visual {
		unsafe { return Visual { raw: platformer_visual_new(crate::dora::from_string(name)) }; }
	}
}