extern "C" {
	fn sensor_type() -> i32;
	fn sensor_set_enabled(slf: i64, var: i32);
	fn sensor_is_enabled(slf: i64) -> i32;
	fn sensor_get_tag(slf: i64) -> i32;
	fn sensor_get_owner(slf: i64) -> i64;
	fn sensor_is_sensed(slf: i64) -> i32;
	fn sensor_get_sensed_bodies(slf: i64) -> i64;
	fn sensor_contains(slf: i64, body: i64) -> i32;
}
use crate::dora::IObject;
pub struct Sensor { raw: i64 }
crate::dora_object!(Sensor);
impl Sensor {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { sensor_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Sensor { raw: raw }))
			}
		})
	}
	pub fn set_enabled(&mut self, var: bool) {
		unsafe { sensor_set_enabled(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_enabled(&self) -> bool {
		return unsafe { sensor_is_enabled(self.raw()) != 0 };
	}
	pub fn get_tag(&self) -> i32 {
		return unsafe { sensor_get_tag(self.raw()) };
	}
	pub fn get_owner(&self) -> crate::dora::Body {
		return unsafe { crate::dora::Body::from(sensor_get_owner(self.raw())).unwrap() };
	}
	pub fn is_sensed(&self) -> bool {
		return unsafe { sensor_is_sensed(self.raw()) != 0 };
	}
	pub fn get_sensed_bodies(&self) -> crate::dora::Array {
		return unsafe { crate::dora::Array::from(sensor_get_sensed_bodies(self.raw())).unwrap() };
	}
	pub fn contains(&mut self, body: &dyn crate::dora::IBody) -> bool {
		unsafe { return sensor_contains(self.raw(), body.raw()) != 0; }
	}
}