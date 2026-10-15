/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn effeknode_type() -> i32;
	fn effeknode_play(slf: i64, filename: i64, pos: i64, z: f32) -> i32;
	fn effeknode_stop(slf: i64, handle: i32);
	fn effeknode_new() -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for EffekNode { }
/// A struct for playing Effekseer effects.
pub struct EffekNode { raw: i64 }
crate::dora_object!(EffekNode);
impl EffekNode {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { effeknode_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(EffekNode { raw: raw }))
			}
		})
	}
	/// Plays an effect at the specified position.
	///
	/// # Arguments
	///
	/// * `filename` - The filename of the effect to play.
	/// * `pos` - The xy-position to play the effect at.
	/// * `z` - The z-position of the effect.
	///
	/// # Returns
	///
	/// * `int` - The handle of the effect.
	pub fn play(&mut self, filename: &str, pos: &crate::dora::Vec2, z: f32) -> i32 {
		unsafe { return effeknode_play(self.raw(), crate::dora::from_string(filename), pos.into_i64(), z); }
	}
	/// Stops an effect with the specified handle.
	///
	/// # Arguments
	///
	/// * `handle` - The handle of the effect to stop.
	pub fn stop(&mut self, handle: i32) {
		unsafe { effeknode_stop(self.raw(), handle); }
	}
	/// Creates a new EffekNode object.
	///
	/// # Returns
	///
	/// * `EffekNode` - A new EffekNode object.
	pub fn new() -> EffekNode {
		unsafe { return EffekNode { raw: effeknode_new() }; }
	}
}