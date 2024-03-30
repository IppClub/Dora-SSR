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
/// Represents a touch input or mouse click event.
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
	/// Sets whether touch input is enabled or not.
	pub fn set_enabled(&mut self, var: bool) {
		unsafe { touch_set_enabled(self.raw(), if var { 1 } else { 0 }) };
	}
	/// Gets whether touch input is enabled or not.
	pub fn is_enabled(&self) -> bool {
		return unsafe { touch_is_enabled(self.raw()) != 0 };
	}
	/// Gets whether the touch event originated from a mouse click.
	pub fn is_from_mouse(&self) -> bool {
		return unsafe { touch_is_from_mouse(self.raw()) != 0 };
	}
	/// Gets whether this is the first touch event when multi-touches exist.
	pub fn is_first(&self) -> bool {
		return unsafe { touch_is_first(self.raw()) != 0 };
	}
	/// Gets the unique identifier assigned to this touch event.
	pub fn get_id(&self) -> i32 {
		return unsafe { touch_get_id(self.raw()) };
	}
	/// Gets the amount and direction of movement since the last touch event.
	pub fn get_delta(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(touch_get_delta(self.raw())) };
	}
	/// Gets the location of the touch event in the node's local coordinate system.
	pub fn get_location(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(touch_get_location(self.raw())) };
	}
	/// Gets the location of the touch event in world coordinate system.
	pub fn get_world_location(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(touch_get_world_location(self.raw())) };
	}
}