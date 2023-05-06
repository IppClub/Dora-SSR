extern "C" {
	fn touch_type() -> i32;
	fn touch_set_enabled(slf: i64, var: i32);
	fn touch_is_enabled(slf: i64) -> i32;
	fn touch_is_from_mouse(slf: i64) -> i32;
	fn touch_is_first(slf: i64) -> i32;
	fn touch_get_id(slf: i64) -> i32;
	fn touch_get_delta(slf: i64) -> i64;
	fn touch_get_location(slf: i64) -> i64;
	fn touch_get_world_location(slf: i64) -> i64;
}
use crate::dora::IObject;
pub struct Touch { raw: i64 }
crate::dora_object!(Touch);
impl Touch {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { touch_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Touch { raw: raw }))
			}
		})
	}
	pub fn set_enabled(&mut self, var: bool) {
		unsafe { touch_set_enabled(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_enabled(&self) -> bool {
		return unsafe { touch_is_enabled(self.raw()) != 0 };
	}
	pub fn is_from_mouse(&self) -> bool {
		return unsafe { touch_is_from_mouse(self.raw()) != 0 };
	}
	pub fn is_first(&self) -> bool {
		return unsafe { touch_is_first(self.raw()) != 0 };
	}
	pub fn get_id(&self) -> i32 {
		return unsafe { touch_get_id(self.raw()) };
	}
	pub fn get_delta(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(touch_get_delta(self.raw())) };
	}
	pub fn get_location(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(touch_get_location(self.raw())) };
	}
	pub fn get_world_location(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(touch_get_world_location(self.raw())) };
	}
}