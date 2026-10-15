/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn platformer_platformcamera_type() -> i32;
	fn platformer_platformcamera_set_position(slf: i64, val: i64);
	fn platformer_platformcamera_get_position(slf: i64) -> i64;
	fn platformer_platformcamera_set_rotation(slf: i64, val: f32);
	fn platformer_platformcamera_get_rotation(slf: i64) -> f32;
	fn platformer_platformcamera_set_zoom(slf: i64, val: f32);
	fn platformer_platformcamera_get_zoom(slf: i64) -> f32;
	fn platformer_platformcamera_set_boundary(slf: i64, val: i64);
	fn platformer_platformcamera_get_boundary(slf: i64) -> i64;
	fn platformer_platformcamera_set_follow_ratio(slf: i64, val: i64);
	fn platformer_platformcamera_get_follow_ratio(slf: i64) -> i64;
	fn platformer_platformcamera_set_follow_offset(slf: i64, val: i64);
	fn platformer_platformcamera_get_follow_offset(slf: i64) -> i64;
	fn platformer_platformcamera_set_follow_target(slf: i64, val: i64);
	fn platformer_platformcamera_get_follow_target(slf: i64) -> i64;
	fn platformer_platformcamera_set_follow_target_null(slf: i64);
	fn platformer_platformcamera_new(name: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::ICamera;
impl ICamera for PlatformCamera { }
/// A platform camera for 2D platformer games that can track a game unit's movement and keep it within the camera's view.
pub struct PlatformCamera { raw: i64 }
crate::dora_object!(PlatformCamera);
impl PlatformCamera {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { platformer_platformcamera_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(PlatformCamera { raw: raw }))
			}
		})
	}
	/// Sets The camera's position.
	pub fn set_position(&mut self, val: &crate::dora::Vec2) {
		unsafe { platformer_platformcamera_set_position(self.raw(), val.into_i64()) };
	}
	/// Gets The camera's position.
	pub fn get_position(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(platformer_platformcamera_get_position(self.raw())) };
	}
	/// Sets The camera's rotation in degrees.
	pub fn set_rotation(&mut self, val: f32) {
		unsafe { platformer_platformcamera_set_rotation(self.raw(), val) };
	}
	/// Gets The camera's rotation in degrees.
	pub fn get_rotation(&self) -> f32 {
		return unsafe { platformer_platformcamera_get_rotation(self.raw()) };
	}
	/// Sets The camera's zoom factor, 1.0 means the normal size, 2.0 mean zoom to doubled size.
	pub fn set_zoom(&mut self, val: f32) {
		unsafe { platformer_platformcamera_set_zoom(self.raw(), val) };
	}
	/// Gets The camera's zoom factor, 1.0 means the normal size, 2.0 mean zoom to doubled size.
	pub fn get_zoom(&self) -> f32 {
		return unsafe { platformer_platformcamera_get_zoom(self.raw()) };
	}
	/// Sets The rectangular area within which the camera is allowed to view.
	pub fn set_boundary(&mut self, val: &crate::dora::Rect) {
		unsafe { platformer_platformcamera_set_boundary(self.raw(), val.raw()) };
	}
	/// Gets The rectangular area within which the camera is allowed to view.
	pub fn get_boundary(&self) -> crate::dora::Rect {
		return unsafe { crate::dora::Rect::from(platformer_platformcamera_get_boundary(self.raw())) };
	}
	/// Sets the ratio at which the camera should move to keep up with the target's position.
	/// For example, set to `Vec2(1.0, 1.0)`, then the camera will keep up to the target's position right away.
	/// Set to Vec2(0.5, 0.5) or smaller value, then the camera will move halfway to the target's position each frame, resulting in a smooth and gradual movement.
	pub fn set_follow_ratio(&mut self, val: &crate::dora::Vec2) {
		unsafe { platformer_platformcamera_set_follow_ratio(self.raw(), val.into_i64()) };
	}
	/// Gets the ratio at which the camera should move to keep up with the target's position.
	/// For example, set to `Vec2(1.0, 1.0)`, then the camera will keep up to the target's position right away.
	/// Set to Vec2(0.5, 0.5) or smaller value, then the camera will move halfway to the target's position each frame, resulting in a smooth and gradual movement.
	pub fn get_follow_ratio(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(platformer_platformcamera_get_follow_ratio(self.raw())) };
	}
	/// Sets the offset at which the camera should follow the target.
	pub fn set_follow_offset(&mut self, val: &crate::dora::Vec2) {
		unsafe { platformer_platformcamera_set_follow_offset(self.raw(), val.into_i64()) };
	}
	/// Gets the offset at which the camera should follow the target.
	pub fn get_follow_offset(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(platformer_platformcamera_get_follow_offset(self.raw())) };
	}
	/// Sets the game unit that the camera should track.
	pub fn set_follow_target(&mut self, val: &dyn crate::dora::INode) {
		unsafe { platformer_platformcamera_set_follow_target(self.raw(), val.raw()) };
	}
	/// Gets the game unit that the camera should track.
	pub fn get_follow_target(&self) -> Option<crate::dora::Node> {
		return unsafe { crate::dora::Node::from(platformer_platformcamera_get_follow_target(self.raw())) };
	}
	/// Removes the target that the camera is following.
	pub fn set_follow_target_null(&mut self) {
		unsafe { platformer_platformcamera_set_follow_target_null(self.raw()); }
	}
	/// Creates a new instance of `PlatformCamera`.
	///
	/// # Arguments
	///
	/// * `name` - An optional string that specifies the name of the new instance. Default is an empty string.
	///
	/// # Returns
	///
	/// * A new `PlatformCamera` instance.
	pub fn new(name: &str) -> PlatformCamera {
		unsafe { return PlatformCamera { raw: platformer_platformcamera_new(crate::dora::from_string(name)) }; }
	}
}