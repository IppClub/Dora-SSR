/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn motorjoint_type() -> i32;
	fn motorjoint_set_enabled(slf: i64, val: i32);
	fn motorjoint_is_enabled(slf: i64) -> i32;
	fn motorjoint_set_force(slf: i64, val: f32);
	fn motorjoint_get_force(slf: i64) -> f32;
	fn motorjoint_set_speed(slf: i64, val: f32);
	fn motorjoint_get_speed(slf: i64) -> f32;
}
use crate::dora::IObject;
use crate::dora::IJoint;
impl IJoint for MotorJoint { }
/// A joint that applies a rotational or linear force to a physics body.
pub struct MotorJoint { raw: i64 }
crate::dora_object!(MotorJoint);
impl MotorJoint {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { motorjoint_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(MotorJoint { raw: raw }))
			}
		})
	}
	/// Sets whether or not the motor joint is enabled.
	pub fn set_enabled(&mut self, val: bool) {
		unsafe { motorjoint_set_enabled(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether or not the motor joint is enabled.
	pub fn is_enabled(&self) -> bool {
		return unsafe { motorjoint_is_enabled(self.raw()) != 0 };
	}
	/// Sets the force applied to the motor joint.
	pub fn set_force(&mut self, val: f32) {
		unsafe { motorjoint_set_force(self.raw(), val) };
	}
	/// Gets the force applied to the motor joint.
	pub fn get_force(&self) -> f32 {
		return unsafe { motorjoint_get_force(self.raw()) };
	}
	/// Sets the speed of the motor joint.
	pub fn set_speed(&mut self, val: f32) {
		unsafe { motorjoint_set_speed(self.raw(), val) };
	}
	/// Gets the speed of the motor joint.
	pub fn get_speed(&self) -> f32 {
		return unsafe { motorjoint_get_speed(self.raw()) };
	}
}