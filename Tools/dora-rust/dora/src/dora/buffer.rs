extern "C" {
	fn buffer_type() -> i32;
	fn buffer_resize(slf: i64, size: i32);
	fn buffer_zero_memory(slf: i64);
	fn buffer_size(slf: i64) -> i32;
	fn buffer_set_string(slf: i64, str: i64);
	fn buffer_to_string(slf: i64) -> i64;
}
use crate::dora::IObject;
pub struct Buffer { raw: i64 }
crate::dora_object!(Buffer);
impl Buffer {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { buffer_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Buffer { raw: raw }))
			}
		})
	}
	pub fn resize(&mut self, size: i32) {
		unsafe { buffer_resize(self.raw(), size); }
	}
	pub fn zero_memory(&mut self) {
		unsafe { buffer_zero_memory(self.raw()); }
	}
	pub fn size(&self) -> i32 {
		unsafe { return buffer_size(self.raw()); }
	}
	pub fn set_string(&mut self, str: &str) {
		unsafe { buffer_set_string(self.raw(), crate::dora::from_string(str)); }
	}
	pub fn to_string(&mut self) -> String {
		unsafe { return crate::dora::to_string(buffer_to_string(self.raw())); }
	}
}