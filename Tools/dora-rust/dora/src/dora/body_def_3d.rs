/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn bodydef3d_type() -> i32;
	fn bodydef3d_set_type(slf: i64, val: i32);
	fn bodydef3d_get_type(slf: i64) -> i32;
	fn bodydef3d_set_collision_layer(slf: i64, val: i32);
	fn bodydef3d_get_collision_layer(slf: i64) -> i32;
	fn bodydef3d_set_collision_mask(slf: i64, val: i32);
	fn bodydef3d_get_collision_mask(slf: i64) -> i32;
	fn bodydef3d_set_sensor(slf: i64, val: i32);
	fn bodydef3d_is_sensor(slf: i64) -> i32;
	fn bodydef3d_attach(slf: i64, fixture: i64, position: i64, angles: i64) -> i32;
	fn bodydef3d_new() -> i64;
}
use crate::dora::IObject;
/// A reusable 3D rigid body definition.
pub struct BodyDef3D { raw: i64 }
crate::dora_object!(BodyDef3D);
impl BodyDef3D {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { bodydef3d_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(BodyDef3D { raw: raw }))
			}
		})
	}
	/// Sets the body's motion type.
	pub fn set_type(&mut self, val: crate::dora::BodyType3D) {
		unsafe { bodydef3d_set_type(self.raw(), val as i32) };
	}
	/// Gets the body's motion type.
	pub fn get_type(&self) -> crate::dora::BodyType3D {
		return unsafe { core::mem::transmute(bodydef3d_get_type(self.raw())) };
	}
	/// Sets the collision layer in the range 0 through 31.
	pub fn set_collision_layer(&mut self, val: i32) {
		unsafe { bodydef3d_set_collision_layer(self.raw(), val) };
	}
	/// Gets the collision layer in the range 0 through 31.
	pub fn get_collision_layer(&self) -> i32 {
		return unsafe { bodydef3d_get_collision_layer(self.raw()) };
	}
	/// Sets the bit mask of collision layers accepted by this body.
	pub fn set_collision_mask(&mut self, val: i32) {
		unsafe { bodydef3d_set_collision_mask(self.raw(), val) };
	}
	/// Gets the bit mask of collision layers accepted by this body.
	pub fn get_collision_mask(&self) -> i32 {
		return unsafe { bodydef3d_get_collision_mask(self.raw()) };
	}
	/// Sets whether fixtures report contacts without collision response.
	pub fn set_sensor(&mut self, val: bool) {
		unsafe { bodydef3d_set_sensor(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether fixtures report contacts without collision response.
	pub fn is_sensor(&self) -> bool {
		return unsafe { bodydef3d_is_sensor(self.raw()) != 0 };
	}
	/// Attaches a fixture with a local transform.
	pub fn attach(&mut self, fixture: &crate::dora::FixtureDef3D, position: &crate::dora::Vec3, angles: &crate::dora::Vec3) -> bool {
		unsafe { return bodydef3d_attach(self.raw(), fixture.raw(), position.raw(), angles.raw()) != 0; }
	}
	/// Creates an empty body definition.
	pub fn new() -> BodyDef3D {
		unsafe { return BodyDef3D { raw: bodydef3d_new() }; }
	}
}