/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn fixturedef3d_type() -> i32;
	fn fixturedef3d_is_built(slf: i64) -> i32;
	fn fixturedef3d_add_child(slf: i64, shape: i64, position: i64, angles: i64) -> i32;
	fn fixturedef3d_build(slf: i64) -> i32;
	fn fixturedef3d_with_box(half_extent: i64) -> i64;
	fn fixturedef3d_with_sphere(radius: f32) -> i64;
	fn fixturedef3d_with_capsule(half_height: f32, radius: f32) -> i64;
	fn fixturedef3d_with_compound() -> i64;
	fn fixturedef3d_load_mesh_async(filename: i64, func0: i32, stack0: i64);
	fn fixturedef3d_load_convex_hull_async(filename: i64, func0: i32, stack0: i64);
}
use crate::dora::IObject;
/// A reusable immutable Jolt collision shape or a compound shape builder.
pub struct FixtureDef3D { raw: i64 }
crate::dora_object!(FixtureDef3D);
impl FixtureDef3D {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { fixturedef3d_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(FixtureDef3D { raw: raw }))
			}
		})
	}
	/// Gets whether this shape can be used to create bodies.
	pub fn is_built(&self) -> bool {
		return unsafe { fixturedef3d_is_built(self.raw()) != 0 };
	}
	/// Adds a child to an unbuilt compound shape using local position and XYZ Euler angles in degrees.
	pub fn add_child(&mut self, shape: &crate::dora::FixtureDef3D, position: &crate::dora::Vec3, angles: &crate::dora::Vec3) -> bool {
		unsafe { return fixturedef3d_add_child(self.raw(), shape.raw(), position.raw(), angles.raw()) != 0; }
	}
	/// Freezes a compound shape. A built shape cannot be modified.
	pub fn build(&mut self) -> bool {
		unsafe { return fixturedef3d_build(self.raw()) != 0; }
	}
	/// Creates a box shape using half extents.
	pub fn with_box(half_extent: &crate::dora::Vec3) -> FixtureDef3D {
		unsafe { return FixtureDef3D { raw: fixturedef3d_with_box(half_extent.raw()) }; }
	}
	/// Creates a sphere shape.
	pub fn with_sphere(radius: f32) -> FixtureDef3D {
		unsafe { return FixtureDef3D { raw: fixturedef3d_with_sphere(radius) }; }
	}
	/// Creates a capsule shape.
	pub fn with_capsule(half_height: f32, radius: f32) -> FixtureDef3D {
		unsafe { return FixtureDef3D { raw: fixturedef3d_with_capsule(half_height, radius) }; }
	}
	/// Creates an empty compound shape builder.
	pub fn with_compound() -> FixtureDef3D {
		unsafe { return FixtureDef3D { raw: fixturedef3d_with_compound() }; }
	}
	/// Loads and cooks a static triangle mesh shape through Content asynchronously.
	pub fn load_mesh_async(filename: &str, mut handler: Box<dyn FnMut(&crate::dora::FixtureDef3D)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			handler(&stack0.pop_cast::<crate::dora::FixtureDef3D>().unwrap())
		}));
		unsafe { fixturedef3d_load_mesh_async(crate::dora::from_string(filename), func_id0, stack_raw0); }
	}
	/// Loads model vertices through Content asynchronously and cooks a convex hull suitable for dynamic bodies.
	pub fn load_convex_hull_async(filename: &str, mut handler: Box<dyn FnMut(&crate::dora::FixtureDef3D)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			handler(&stack0.pop_cast::<crate::dora::FixtureDef3D>().unwrap())
		}));
		unsafe { fixturedef3d_load_convex_hull_async(crate::dora::from_string(filename), func_id0, stack_raw0); }
	}
}