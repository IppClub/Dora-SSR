extern "C" {
	fn grabber_type() -> i32;
	fn grabber_set_camera(slf: i64, var: i64);
	fn grabber_get_camera(slf: i64) -> i64;
	fn grabber_set_effect(slf: i64, var: i64);
	fn grabber_get_effect(slf: i64) -> i64;
	fn grabber_set_blend_func(slf: i64, var: i64);
	fn grabber_get_blend_func(slf: i64) -> i64;
	fn grabber_set_clear_color(slf: i64, var: i32);
	fn grabber_get_clear_color(slf: i64) -> i32;
	fn grabber_set_pos(slf: i64, x: i32, y: i32, pos: i64, z: f32);
	fn grabber_get_pos(slf: i64, x: i32, y: i32) -> i64;
	fn grabber_set_color(slf: i64, x: i32, y: i32, color: i32);
	fn grabber_get_color(slf: i64, x: i32, y: i32) -> i32;
	fn grabber_move_uv(slf: i64, x: i32, y: i32, offset: i64);
}
use crate::dora::IObject;
/// A grabber which is used to render a part of the scene to a texture
/// by a grid of vertices.
pub struct Grabber { raw: i64 }
crate::dora_object!(Grabber);
impl Grabber {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { grabber_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Grabber { raw: raw }))
			}
		})
	}
	/// Sets the camera used to render the texture.
	pub fn set_camera(&mut self, var: &dyn crate::dora::ICamera) {
		unsafe { grabber_set_camera(self.raw(), var.raw()) };
	}
	/// Gets the camera used to render the texture.
	pub fn get_camera(&self) -> Option<crate::dora::Camera> {
		return unsafe { crate::dora::Camera::from(grabber_get_camera(self.raw())) };
	}
	/// Sets the sprite effect applied to the texture.
	pub fn set_effect(&mut self, var: &crate::dora::SpriteEffect) {
		unsafe { grabber_set_effect(self.raw(), var.raw()) };
	}
	/// Gets the sprite effect applied to the texture.
	pub fn get_effect(&self) -> Option<crate::dora::SpriteEffect> {
		return unsafe { crate::dora::SpriteEffect::from(grabber_get_effect(self.raw())) };
	}
	/// Sets the blend function applied to the texture.
	pub fn set_blend_func(&mut self, var: u64) {
		unsafe { grabber_set_blend_func(self.raw(), var as i64) };
	}
	/// Gets the blend function applied to the texture.
	pub fn get_blend_func(&self) -> u64 {
		return unsafe { grabber_get_blend_func(self.raw()) as u64 };
	}
	/// Sets the clear color used to clear the texture.
	pub fn set_clear_color(&mut self, var: &crate::dora::Color) {
		unsafe { grabber_set_clear_color(self.raw(), var.to_argb() as i32) };
	}
	/// Gets the clear color used to clear the texture.
	pub fn get_clear_color(&self) -> crate::dora::Color {
		return unsafe { crate::dora::Color::from(grabber_get_clear_color(self.raw())) };
	}
	/// Sets the position of a vertex in the grabber grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-index of the vertex in the grabber grid.
	/// * `y` - The y-index of the vertex in the grabber grid.
	/// * `pos` - The new position of the vertex, represented by a Vec2 object.
	/// * `z` - An optional argument representing the new z-coordinate of the vertex.
	pub fn set_pos(&mut self, x: i32, y: i32, pos: &crate::dora::Vec2, z: f32) {
		unsafe { grabber_set_pos(self.raw(), x, y, pos.into_i64(), z); }
	}
	/// Gets the position of a vertex in the grabber grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-index of the vertex in the grabber grid.
	/// * `y` - The y-index of the vertex in the grabber grid.
	///
	/// # Returns
	///
	/// * `Vec2` - The position of the vertex.
	pub fn get_pos(&self, x: i32, y: i32) -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(grabber_get_pos(self.raw(), x, y)); }
	}
	/// Sets the color of a vertex in the grabber grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-index of the vertex in the grabber grid.
	/// * `y` - The y-index of the vertex in the grabber grid.
	/// * `color` - The new color of the vertex, represented by a Color object.
	pub fn set_color(&mut self, x: i32, y: i32, color: &crate::dora::Color) {
		unsafe { grabber_set_color(self.raw(), x, y, color.to_argb() as i32); }
	}
	/// Gets the color of a vertex in the grabber grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-index of the vertex in the grabber grid.
	/// * `y` - The y-index of the vertex in the grabber grid.
	///
	/// # Returns
	///
	/// * `Color` - The color of the vertex.
	pub fn get_color(&self, x: i32, y: i32) -> crate::dora::Color {
		unsafe { return crate::dora::Color::from(grabber_get_color(self.raw(), x, y)); }
	}
	/// Sets the UV coordinates of a vertex in the grabber grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-index of the vertex in the grabber grid.
	/// * `y` - The y-index of the vertex in the grabber grid.
	/// * `offset` - The new UV coordinates of the vertex, represented by a Vec2 object.
	pub fn move_uv(&mut self, x: i32, y: i32, offset: &crate::dora::Vec2) {
		unsafe { grabber_move_uv(self.raw(), x, y, offset.into_i64()); }
	}
}