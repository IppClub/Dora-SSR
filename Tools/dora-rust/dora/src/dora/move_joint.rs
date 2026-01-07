/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn movejoint_type() -> i32;
	fn movejoint_set_position(slf: i64, val: i64);
	fn movejoint_get_position(slf: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::IJoint;
impl IJoint for MoveJoint { }
/// A type of joint that allows a physics body to move to a specific position.
pub struct MoveJoint { raw: i64 }
crate::dora_object!(MoveJoint);
impl MoveJoint {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { movejoint_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(MoveJoint { raw: raw }))
			}
		})
	}
	/// Sets the current position of the move joint in the game world.
	pub fn set_position(&mut self, val: &crate::dora::Vec2) {
		unsafe { movejoint_set_position(self.raw(), val.into_i64()) };
	}
	/// Gets the current position of the move joint in the game world.
	pub fn get_position(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(movejoint_get_position(self.raw())) };
	}
}