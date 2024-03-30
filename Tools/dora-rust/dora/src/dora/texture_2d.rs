extern "C" {
	fn texture2d_type() -> i32;
	fn texture2d_get_width(slf: i64) -> i32;
	fn texture2d_get_height(slf: i64) -> i32;
	fn texture2d_with_file(filename: i64) -> i64;
}
use crate::dora::IObject;
/// A struct represents a 2D texture.
pub struct Texture2D { raw: i64 }
crate::dora_object!(Texture2D);
impl Texture2D {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { texture2d_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Texture2D { raw: raw }))
			}
		})
	}
	/// Gets the width of the texture, in pixels.
	pub fn get_width(&self) -> i32 {
		return unsafe { texture2d_get_width(self.raw()) };
	}
	/// Gets the height of the texture, in pixels.
	pub fn get_height(&self) -> i32 {
		return unsafe { texture2d_get_height(self.raw()) };
	}
	/// Creates a texture object from the given file.
	///
	/// # Arguments
	///
	/// * `filename` - The file name of the texture.
	///
	/// # Returns
	///
	/// * `Texture2D` - The texture object.
	pub fn with_file(filename: &str) -> Option<Texture2D> {
		unsafe { return Texture2D::from(texture2d_with_file(crate::dora::from_string(filename))); }
	}
}