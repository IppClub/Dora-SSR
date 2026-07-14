/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn view3d_type() -> i32;
	fn view3d_get_scene(slf: i64) -> i64;
	fn view3d_get_stats(slf: i64) -> i64;
	fn view3d_set_show_a_a_b_b(slf: i64, val: i32);
	fn view3d_is_show_a_a_b_b(slf: i64) -> i32;
	fn view3d_set_shadow_map_size(slf: i64, val: i32);
	fn view3d_get_shadow_map_size(slf: i64) -> i32;
	fn view3d_add_child_3d(slf: i64, child: i64);
	fn view3d_get_ray_origin(slf: i64, view_point: i64) -> i64;
	fn view3d_get_ray_direction(slf: i64, view_point: i64) -> i64;
	fn view3d_pick(slf: i64, view_point: i64) -> i64;
	fn view3d_set_environment_map(slf: i64, path: i64) -> i32;
	fn view3d_set_environment_intensity(slf: i64, diffuse: f32, specular: f32, exposure: f32);
	fn view3d_new() -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for View3D { }
/// A 2D scene node that owns a 3D scene tree.
pub struct View3D { raw: i64 }
crate::dora_object!(View3D);
impl IView3D for View3D { }
pub trait IView3D: INode {
	/// Gets the root 3D scene node.
	fn get_scene(&self) -> crate::dora::Node3D {
		return unsafe { crate::dora::Node3D::from(view3d_get_scene(self.raw())).unwrap() };
	}
	/// Gets statistics from the most recent 3D render and current 3D registries.
	fn get_stats(&self) -> crate::dora::RenderStats3D {
		return unsafe { crate::dora::RenderStats3D::from(view3d_get_stats(self.raw())) };
	}
	/// Sets whether current world AABBs are drawn for debugging.
	fn set_show_a_a_b_b(&mut self, val: bool) {
		unsafe { view3d_set_show_a_a_b_b(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether current world AABBs are drawn for debugging.
	fn is_show_a_a_b_b(&self) -> bool {
		return unsafe { view3d_is_show_a_a_b_b(self.raw()) != 0 };
	}
	/// Sets the directional shadow-map resolution for this view.
	fn set_shadow_map_size(&mut self, val: i32) {
		unsafe { view3d_set_shadow_map_size(self.raw(), val) };
	}
	/// Gets the directional shadow-map resolution for this view.
	fn get_shadow_map_size(&self) -> i32 {
		return unsafe { view3d_get_shadow_map_size(self.raw()) };
	}
	/// Adds a 3D child node to the scene root.
	fn add_child_3d(&mut self, child: &dyn crate::dora::INode3D) {
		unsafe { view3d_add_child_3d(self.raw(), child.raw()); }
	}
	/// Gets the world-space origin of the screen ray for a SharedView logical coordinate.
	fn get_ray_origin(&mut self, view_point: &crate::dora::Vec2) -> crate::dora::Vec3 {
		unsafe { return crate::dora::Vec3::from(view3d_get_ray_origin(self.raw(), view_point.into_i64())); }
	}
	/// Gets the normalized world-space direction of the screen ray.
	fn get_ray_direction(&mut self, view_point: &crate::dora::Vec2) -> crate::dora::Vec3 {
		unsafe { return crate::dora::Vec3::from(view3d_get_ray_direction(self.raw(), view_point.into_i64())); }
	}
	/// Returns the nearest Model3D whose current world AABB intersects the screen ray.
	fn pick(&mut self, view_point: &crate::dora::Vec2) -> Option<crate::dora::Model3D> {
		unsafe { return crate::dora::Model3D::from(view3d_pick(self.raw(), view_point.into_i64())); }
	}
	/// Sets the environment map used by this 3D view.
	fn set_environment_map(&mut self, path: &str) -> bool {
		unsafe { return view3d_set_environment_map(self.raw(), crate::dora::from_string(path)) != 0; }
	}
	/// Sets the environment lighting intensity used by this 3D view.
	fn set_environment_intensity(&mut self, diffuse: f32, specular: f32, exposure: f32) {
		unsafe { view3d_set_environment_intensity(self.raw(), diffuse, specular, exposure); }
	}
}
impl View3D {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { view3d_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(View3D { raw: raw }))
			}
		})
	}
	/// Creates a new 3D view node.
	pub fn new() -> View3D {
		unsafe { return View3D { raw: view3d_new() }; }
	}
}