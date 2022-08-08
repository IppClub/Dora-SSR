extern "C" {
	fn texture2d_type() -> i32;
	fn texture2d_get_width(slf: i64) -> i32;
	fn texture2d_get_height(slf: i64) -> i32;
}
use crate::dora::Object;
pub struct Texture2D { raw: i64 }
crate::dora_object!(Texture2D);
impl Texture2D {
	pub fn get_width(&self) -> i32 {
		return unsafe { texture2d_get_width(self.raw()) };
	}
	pub fn get_height(&self) -> i32 {
		return unsafe { texture2d_get_height(self.raw()) };
	}
}