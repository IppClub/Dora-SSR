/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn view_get_size() -> i64;
	fn view_get_standard_distance() -> f32;
	fn view_get_aspect_ratio() -> f32;
	fn view_set_near_plane_distance(val: f32);
	fn view_get_near_plane_distance() -> f32;
	fn view_set_far_plane_distance(val: f32);
	fn view_get_far_plane_distance() -> f32;
	fn view_set_field_of_view(val: f32);
	fn view_get_field_of_view() -> f32;
	fn view_set_scale(val: f32);
	fn view_get_scale() -> f32;
	fn view_set_post_effect(val: i64);
	fn view_get_post_effect() -> i64;
	fn view_set_post_effect_null();
	fn view_set_vsync(val: i32);
	fn view_is_vsync() -> i32;
}
use crate::dora::IObject;
/// A struct that provides access to the 3D graphic view.
pub struct View { }
impl View {
	/// Gets the size of the view in pixels.
	pub fn get_size() -> crate::dora::Size {
		return unsafe { crate::dora::Size::from(view_get_size()) };
	}
	/// Gets the standard distance of the view from the origin.
	pub fn get_standard_distance() -> f32 {
		return unsafe { view_get_standard_distance() };
	}
	/// Gets the aspect ratio of the view.
	pub fn get_aspect_ratio() -> f32 {
		return unsafe { view_get_aspect_ratio() };
	}
	/// Sets the distance to the near clipping plane.
	pub fn set_near_plane_distance(val: f32) {
		unsafe { view_set_near_plane_distance(val) };
	}
	/// Gets the distance to the near clipping plane.
	pub fn get_near_plane_distance() -> f32 {
		return unsafe { view_get_near_plane_distance() };
	}
	/// Sets the distance to the far clipping plane.
	pub fn set_far_plane_distance(val: f32) {
		unsafe { view_set_far_plane_distance(val) };
	}
	/// Gets the distance to the far clipping plane.
	pub fn get_far_plane_distance() -> f32 {
		return unsafe { view_get_far_plane_distance() };
	}
	/// Sets the field of view of the view in degrees.
	pub fn set_field_of_view(val: f32) {
		unsafe { view_set_field_of_view(val) };
	}
	/// Gets the field of view of the view in degrees.
	pub fn get_field_of_view() -> f32 {
		return unsafe { view_get_field_of_view() };
	}
	/// Sets the scale factor of the view.
	pub fn set_scale(val: f32) {
		unsafe { view_set_scale(val) };
	}
	/// Gets the scale factor of the view.
	pub fn get_scale() -> f32 {
		return unsafe { view_get_scale() };
	}
	/// Sets the post effect applied to the view.
	pub fn set_post_effect(val: &crate::dora::SpriteEffect) {
		unsafe { view_set_post_effect(val.raw()) };
	}
	/// Gets the post effect applied to the view.
	pub fn get_post_effect() -> Option<crate::dora::SpriteEffect> {
		return unsafe { crate::dora::SpriteEffect::from(view_get_post_effect()) };
	}
	/// Removes the post effect applied to the view.
	pub fn set_post_effect_null() {
		unsafe { view_set_post_effect_null(); }
	}
	/// Sets whether or not vertical sync is enabled.
	pub fn set_vsync(val: bool) {
		unsafe { view_set_vsync(if val { 1 } else { 0 }) };
	}
	/// Gets whether or not vertical sync is enabled.
	pub fn is_vsync() -> bool {
		return unsafe { view_is_vsync() != 0 };
	}
}