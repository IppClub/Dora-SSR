extern "C" {
	fn grid_type() -> i32;
	fn grid_get_grid_x(slf: i64) -> i32;
	fn grid_get_grid_y(slf: i64) -> i32;
	fn grid_set_depth_write(slf: i64, var: i32);
	fn grid_is_depth_write(slf: i64) -> i32;
	fn grid_set_blend_func(slf: i64, var: i64);
	fn grid_get_blend_func(slf: i64) -> i64;
	fn grid_set_effect(slf: i64, var: i64);
	fn grid_get_effect(slf: i64) -> i64;
	fn grid_set_texture_rect(slf: i64, var: i64);
	fn grid_get_texture_rect(slf: i64) -> i64;
	fn grid_set_texture(slf: i64, var: i64);
	fn grid_get_texture(slf: i64) -> i64;
	fn grid_set_pos(slf: i64, x: i32, y: i32, pos: i64, z: f32);
	fn grid_get_pos(slf: i64, x: i32, y: i32) -> i64;
	fn grid_set_color(slf: i64, x: i32, y: i32, color: i32);
	fn grid_get_color(slf: i64, x: i32, y: i32) -> i32;
	fn grid_move_uv(slf: i64, x: i32, y: i32, offset: i64);
	fn grid_new(width: f32, height: f32, grid_x: i32, grid_y: i32) -> i64;
	fn grid_with_texture_rect(texture: i64, texture_rect: i64, grid_x: i32, grid_y: i32) -> i64;
	fn grid_with_texture(texture: i64, grid_x: i32, grid_y: i32) -> i64;
	fn grid_with_file(clip_str: i64, grid_x: i32, grid_y: i32) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for Grid { }
pub struct Grid { raw: i64 }
crate::dora_object!(Grid);
impl Grid {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { grid_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Grid { raw: raw }))
			}
		})
	}
	pub fn get_grid_x(&self) -> i32 {
		return unsafe { grid_get_grid_x(self.raw()) };
	}
	pub fn get_grid_y(&self) -> i32 {
		return unsafe { grid_get_grid_y(self.raw()) };
	}
	pub fn set_depth_write(&mut self, var: bool) {
		unsafe { grid_set_depth_write(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_depth_write(&self) -> bool {
		return unsafe { grid_is_depth_write(self.raw()) != 0 };
	}
	pub fn set_blend_func(&mut self, var: u64) {
		unsafe { grid_set_blend_func(self.raw(), var as i64) };
	}
	pub fn get_blend_func(&self) -> u64 {
		return unsafe { grid_get_blend_func(self.raw()) as u64 };
	}
	pub fn set_effect(&mut self, var: &crate::dora::SpriteEffect) {
		unsafe { grid_set_effect(self.raw(), var.raw()) };
	}
	pub fn get_effect(&self) -> crate::dora::SpriteEffect {
		return unsafe { crate::dora::SpriteEffect::from(grid_get_effect(self.raw())).unwrap() };
	}
	pub fn set_texture_rect(&mut self, var: &crate::dora::Rect) {
		unsafe { grid_set_texture_rect(self.raw(), var.raw()) };
	}
	pub fn get_texture_rect(&self) -> crate::dora::Rect {
		return unsafe { crate::dora::Rect::from(grid_get_texture_rect(self.raw())) };
	}
	pub fn set_texture(&mut self, var: &crate::dora::Texture2D) {
		unsafe { grid_set_texture(self.raw(), var.raw()) };
	}
	pub fn get_texture(&self) -> Option<crate::dora::Texture2D> {
		return unsafe { crate::dora::Texture2D::from(grid_get_texture(self.raw())) };
	}
	pub fn set_pos(&mut self, x: i32, y: i32, pos: &crate::dora::Vec2, z: f32) {
		unsafe { grid_set_pos(self.raw(), x, y, pos.into_i64(), z); }
	}
	pub fn get_pos(&self, x: i32, y: i32) -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(grid_get_pos(self.raw(), x, y)); }
	}
	pub fn set_color(&mut self, x: i32, y: i32, color: &crate::dora::Color) {
		unsafe { grid_set_color(self.raw(), x, y, color.to_argb() as i32); }
	}
	pub fn get_color(&self, x: i32, y: i32) -> crate::dora::Color {
		unsafe { return crate::dora::Color::from(grid_get_color(self.raw(), x, y)); }
	}
	pub fn move_uv(&mut self, x: i32, y: i32, offset: &crate::dora::Vec2) {
		unsafe { grid_move_uv(self.raw(), x, y, offset.into_i64()); }
	}
	pub fn new(width: f32, height: f32, grid_x: i32, grid_y: i32) -> Grid {
		unsafe { return Grid { raw: grid_new(width, height, grid_x, grid_y) }; }
	}
	pub fn with_texture_rect(texture: &crate::dora::Texture2D, texture_rect: &crate::dora::Rect, grid_x: i32, grid_y: i32) -> Grid {
		unsafe { return Grid { raw: grid_with_texture_rect(texture.raw(), texture_rect.raw(), grid_x, grid_y) }; }
	}
	pub fn with_texture(texture: &crate::dora::Texture2D, grid_x: i32, grid_y: i32) -> Grid {
		unsafe { return Grid { raw: grid_with_texture(texture.raw(), grid_x, grid_y) }; }
	}
	pub fn with_file(clip_str: &str, grid_x: i32, grid_y: i32) -> Option<Grid> {
		unsafe { return Grid::from(grid_with_file(crate::dora::from_string(clip_str), grid_x, grid_y)); }
	}
}