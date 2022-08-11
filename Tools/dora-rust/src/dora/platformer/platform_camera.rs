extern "C" {
	fn platformer_platformcamera_type() -> i32;
	fn platformer_platformcamera_set_position(slf: i64, var: i64);
	fn platformer_platformcamera_get_position(slf: i64) -> i64;
	fn platformer_platformcamera_set_rotation(slf: i64, var: f32);
	fn platformer_platformcamera_get_rotation(slf: i64) -> f32;
	fn platformer_platformcamera_set_zoom(slf: i64, var: f32);
	fn platformer_platformcamera_get_zoom(slf: i64) -> f32;
	fn platformer_platformcamera_set_boundary(slf: i64, var: i64);
	fn platformer_platformcamera_get_boundary(slf: i64) -> i64;
	fn platformer_platformcamera_set_follow_ratio(slf: i64, var: i64);
	fn platformer_platformcamera_get_follow_ratio(slf: i64) -> i64;
	fn platformer_platformcamera_set_follow_offset(slf: i64, var: i64);
	fn platformer_platformcamera_get_follow_offset(slf: i64) -> i64;
	fn platformer_platformcamera_set_follow_target(slf: i64, var: i64);
	fn platformer_platformcamera_get_follow_target(slf: i64) -> i64;
	fn platformer_platformcamera_new(name: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::ICamera;
impl ICamera for PlatformCamera { }
pub struct PlatformCamera { raw: i64 }
crate::dora_object!(PlatformCamera);
impl PlatformCamera {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { platformer_platformcamera_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(PlatformCamera { raw: raw }))
			}
		})
	}
	pub fn set_position(&mut self, var: &crate::dora::Vec2) {
		unsafe { platformer_platformcamera_set_position(self.raw(), var.into_i64()) };
	}
	pub fn get_position(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(platformer_platformcamera_get_position(self.raw())) };
	}
	pub fn set_rotation(&mut self, var: f32) {
		unsafe { platformer_platformcamera_set_rotation(self.raw(), var) };
	}
	pub fn get_rotation(&self) -> f32 {
		return unsafe { platformer_platformcamera_get_rotation(self.raw()) };
	}
	pub fn set_zoom(&mut self, var: f32) {
		unsafe { platformer_platformcamera_set_zoom(self.raw(), var) };
	}
	pub fn get_zoom(&self) -> f32 {
		return unsafe { platformer_platformcamera_get_zoom(self.raw()) };
	}
	pub fn set_boundary(&mut self, var: &crate::dora::Rect) {
		unsafe { platformer_platformcamera_set_boundary(self.raw(), var.raw()) };
	}
	pub fn get_boundary(&self) -> crate::dora::Rect {
		return unsafe { crate::dora::Rect::from(platformer_platformcamera_get_boundary(self.raw())) };
	}
	pub fn set_follow_ratio(&mut self, var: &crate::dora::Vec2) {
		unsafe { platformer_platformcamera_set_follow_ratio(self.raw(), var.into_i64()) };
	}
	pub fn get_follow_ratio(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(platformer_platformcamera_get_follow_ratio(self.raw())) };
	}
	pub fn set_follow_offset(&mut self, var: &crate::dora::Vec2) {
		unsafe { platformer_platformcamera_set_follow_offset(self.raw(), var.into_i64()) };
	}
	pub fn get_follow_offset(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(platformer_platformcamera_get_follow_offset(self.raw())) };
	}
	pub fn set_follow_target(&mut self, var: &dyn crate::dora::INode) {
		unsafe { platformer_platformcamera_set_follow_target(self.raw(), var.raw()) };
	}
	pub fn get_follow_target(&self) -> crate::dora::Node {
		return unsafe { crate::dora::Node::from(platformer_platformcamera_get_follow_target(self.raw())).unwrap() };
	}
	pub fn new(name: &str) -> PlatformCamera {
		unsafe { return PlatformCamera { raw: platformer_platformcamera_new(crate::dora::from_string(name)) }; }
	}
}