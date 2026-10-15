/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn platformer_behavior_blackboard_get_delta_time(slf: i64) -> f64;
	fn platformer_behavior_blackboard_get_owner(slf: i64) -> i64;
}
/// A blackboard object that can be used to store data for behavior tree nodes.
pub struct Blackboard { raw: i64 }
impl Blackboard {
	pub(crate) fn from(raw: i64) -> Option<Blackboard> {
		match raw {
			0 => None,
			_ => Some(Blackboard { raw: raw })
		}
	}
	pub(crate) fn raw(&self) -> i64 { self.raw }
	/// Gets the time since the last frame update in seconds.
	pub fn get_delta_time(&self) -> f64 {
		return unsafe { platformer_behavior_blackboard_get_delta_time(self.raw()) };
	}
	/// Gets the unit that the AI agent belongs to.
	pub fn get_owner(&self) -> crate::dora::platformer::Unit {
		return unsafe { crate::dora::platformer::Unit::from(platformer_behavior_blackboard_get_owner(self.raw())).unwrap() };
	}
}