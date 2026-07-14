/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn constraint3d_type() -> i32;
	fn constraint3d_get_world(slf: i64) -> i64;
	fn constraint3d_get_first_body(slf: i64) -> i64;
	fn constraint3d_get_second_body(slf: i64) -> i64;
	fn constraint3d_destroy(slf: i64);
	fn constraint3d_fixed(first_body: i64, second_body: i64, anchor: i64) -> i64;
	fn constraint3d_distance(first_body: i64, second_body: i64, first_anchor: i64, second_anchor: i64, min_distance: f32, max_distance: f32) -> i64;
	fn constraint3d_hinge(first_body: i64, second_body: i64, anchor: i64, axis: i64, min_angle: f32, max_angle: f32) -> i64;
}
use crate::dora::IObject;
/// A two-body constraint owned by a PhysicsWorld3D.
pub struct Constraint3D { raw: i64 }
crate::dora_object!(Constraint3D);
impl Constraint3D {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { constraint3d_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Constraint3D { raw: raw }))
			}
		})
	}
	/// Gets the physics world that owns this constraint.
	pub fn get_world(&self) -> Option<crate::dora::PhysicsWorld3D> {
		return unsafe { crate::dora::PhysicsWorld3D::from(constraint3d_get_world(self.raw())) };
	}
	/// Gets the first constrained body.
	pub fn get_first_body(&self) -> Option<crate::dora::Body3D> {
		return unsafe { crate::dora::Body3D::from(constraint3d_get_first_body(self.raw())) };
	}
	/// Gets the second constrained body.
	pub fn get_second_body(&self) -> Option<crate::dora::Body3D> {
		return unsafe { crate::dora::Body3D::from(constraint3d_get_second_body(self.raw())) };
	}
	/// Removes this constraint from its physics world.
	pub fn destroy(&mut self) {
		unsafe { constraint3d_destroy(self.raw()); }
	}
	/// Creates a fixed constraint at a world-space anchor.
	pub fn fixed(first_body: &crate::dora::Body3D, second_body: &crate::dora::Body3D, anchor: &crate::dora::Vec3) -> crate::dora::Constraint3D {
		unsafe { return crate::dora::Constraint3D::from(constraint3d_fixed(first_body.raw(), second_body.raw(), anchor.raw())).unwrap(); }
	}
	/// Creates a distance constraint between two world-space anchors.
	pub fn distance(first_body: &crate::dora::Body3D, second_body: &crate::dora::Body3D, first_anchor: &crate::dora::Vec3, second_anchor: &crate::dora::Vec3, min_distance: f32, max_distance: f32) -> crate::dora::Constraint3D {
		unsafe { return crate::dora::Constraint3D::from(constraint3d_distance(first_body.raw(), second_body.raw(), first_anchor.raw(), second_anchor.raw(), min_distance, max_distance)).unwrap(); }
	}
	/// Creates a hinge around a world-space axis with limits in degrees.
	pub fn hinge(first_body: &crate::dora::Body3D, second_body: &crate::dora::Body3D, anchor: &crate::dora::Vec3, axis: &crate::dora::Vec3, min_angle: f32, max_angle: f32) -> crate::dora::Constraint3D {
		unsafe { return crate::dora::Constraint3D::from(constraint3d_hinge(first_body.raw(), second_body.raw(), anchor.raw(), axis.raw(), min_angle, max_angle)).unwrap(); }
	}
}