/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn grid_type() -> i32;
	fn grid_get_grid_x(slf: i64) -> i32;
	fn grid_get_grid_y(slf: i64) -> i32;
	fn grid_set_depth_write(slf: i64, val: i32);
	fn grid_is_depth_write(slf: i64) -> i32;
	fn grid_set_blend_func(slf: i64, val: i64);
	fn grid_get_blend_func(slf: i64) -> i64;
	fn grid_set_effect(slf: i64, val: i64);
	fn grid_get_effect(slf: i64) -> i64;
	fn grid_set_texture_rect(slf: i64, val: i64);
	fn grid_get_texture_rect(slf: i64) -> i64;
	fn grid_set_texture(slf: i64, val: i64);
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
/// A struct used to render a texture as a grid of sprites, where each sprite can be positioned, colored, and have its UV coordinates manipulated.
pub struct Grid { raw: i64 }
crate::dora_object!(Grid);
impl Grid {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { grid_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Grid { raw: raw }))
			}
		})
	}
	/// Gets the number of columns in the grid. And there are `gridX + 1` vertices horizontally for rendering.
	pub fn get_grid_x(&self) -> i32 {
		return unsafe { grid_get_grid_x(self.raw()) };
	}
	/// Gets the number of rows in the grid. And there are `gridY + 1` vertices vertically for rendering.
	pub fn get_grid_y(&self) -> i32 {
		return unsafe { grid_get_grid_y(self.raw()) };
	}
	/// Sets whether depth writes are enabled.
	pub fn set_depth_write(&mut self, val: bool) {
		unsafe { grid_set_depth_write(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether depth writes are enabled.
	pub fn is_depth_write(&self) -> bool {
		return unsafe { grid_is_depth_write(self.raw()) != 0 };
	}
	/// Sets the blend function for the grid.
	pub fn set_blend_func(&mut self, val: crate::dora::BlendFunc) {
		unsafe { grid_set_blend_func(self.raw(), val.to_value()) };
	}
	/// Gets the blend function for the grid.
	pub fn get_blend_func(&self) -> crate::dora::BlendFunc {
		return unsafe { crate::dora::BlendFunc::from(grid_get_blend_func(self.raw())) };
	}
	/// Sets the sprite effect applied to the grid.
	/// Default is `SpriteEffect::new("builtin:vs_sprite", "builtin:fs_sprite")`.
	pub fn set_effect(&mut self, val: &crate::dora::SpriteEffect) {
		unsafe { grid_set_effect(self.raw(), val.raw()) };
	}
	/// Gets the sprite effect applied to the grid.
	/// Default is `SpriteEffect::new("builtin:vs_sprite", "builtin:fs_sprite")`.
	pub fn get_effect(&self) -> crate::dora::SpriteEffect {
		return unsafe { crate::dora::SpriteEffect::from(grid_get_effect(self.raw())).unwrap() };
	}
	/// Sets the rectangle within the texture that is used for the grid.
	pub fn set_texture_rect(&mut self, val: &crate::dora::Rect) {
		unsafe { grid_set_texture_rect(self.raw(), val.raw()) };
	}
	/// Gets the rectangle within the texture that is used for the grid.
	pub fn get_texture_rect(&self) -> crate::dora::Rect {
		return unsafe { crate::dora::Rect::from(grid_get_texture_rect(self.raw())) };
	}
	/// Sets the texture used for the grid.
	pub fn set_texture(&mut self, val: &crate::dora::Texture2D) {
		unsafe { grid_set_texture(self.raw(), val.raw()) };
	}
	/// Gets the texture used for the grid.
	pub fn get_texture(&self) -> Option<crate::dora::Texture2D> {
		return unsafe { crate::dora::Texture2D::from(grid_get_texture(self.raw())) };
	}
	/// Sets the position of a vertex in the grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-coordinate of the vertex in the grid.
	/// * `y` - The y-coordinate of the vertex in the grid.
	/// * `pos` - The new position of the vertex, represented by a Vec2 object.
	/// * `z` - The new z-coordinate of the vertex.
	pub fn set_pos(&mut self, x: i32, y: i32, pos: &crate::dora::Vec2, z: f32) {
		unsafe { grid_set_pos(self.raw(), x, y, pos.into_i64(), z); }
	}
	/// Gets the position of a vertex in the grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-coordinate of the vertex in the grid.
	/// * `y` - The y-coordinate of the vertex in the grid.
	///
	/// # Returns
	///
	/// * `Vec2` - The current position of the vertex.
	pub fn get_pos(&self, x: i32, y: i32) -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(grid_get_pos(self.raw(), x, y)); }
	}
	/// Sets the color of a vertex in the grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-coordinate of the vertex in the grid.
	/// * `y` - The y-coordinate of the vertex in the grid.
	/// * `color` - The new color of the vertex, represented by a Color object.
	pub fn set_color(&mut self, x: i32, y: i32, color: &crate::dora::Color) {
		unsafe { grid_set_color(self.raw(), x, y, color.to_argb() as i32); }
	}
	/// Gets the color of a vertex in the grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-coordinate of the vertex in the grid.
	/// * `y` - The y-coordinate of the vertex in the grid.
	///
	/// # Returns
	///
	/// * `Color` - The current color of the vertex.
	pub fn get_color(&self, x: i32, y: i32) -> crate::dora::Color {
		unsafe { return crate::dora::Color::from(grid_get_color(self.raw(), x, y)); }
	}
	/// Moves the UV coordinates of a vertex in the grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-coordinate of the vertex in the grid.
	/// * `y` - The y-coordinate of the vertex in the grid.
	/// * `offset` - The offset by which to move the UV coordinates, represented by a Vec2 object.
	pub fn move_uv(&mut self, x: i32, y: i32, offset: &crate::dora::Vec2) {
		unsafe { grid_move_uv(self.raw(), x, y, offset.into_i64()); }
	}
	/// Creates a new Grid with the specified dimensions and grid size.
	///
	/// # Arguments
	///
	/// * `width` - The width of the grid.
	/// * `height` - The height of the grid.
	/// * `grid_x` - The number of columns in the grid.
	/// * `grid_y` - The number of rows in the grid.
	///
	/// # Returns
	///
	/// * `Grid` - The new Grid instance.
	pub fn new(width: f32, height: f32, grid_x: i32, grid_y: i32) -> Grid {
		unsafe { return Grid { raw: grid_new(width, height, grid_x, grid_y) }; }
	}
	/// Creates a new Grid with the specified texture, texture rectangle, and grid size.
	///
	/// # Arguments
	///
	/// * `texture` - The texture to use for the grid.
	/// * `texture_rect` - The rectangle within the texture to use for the grid.
	/// * `grid_x` - The number of columns in the grid.
	/// * `grid_y` - The number of rows in the grid.
	///
	/// # Returns
	///
	/// * `Grid` - The new Grid instance.
	pub fn with_texture_rect(texture: &crate::dora::Texture2D, texture_rect: &crate::dora::Rect, grid_x: i32, grid_y: i32) -> Grid {
		unsafe { return Grid { raw: grid_with_texture_rect(texture.raw(), texture_rect.raw(), grid_x, grid_y) }; }
	}
	/// Creates a new Grid with the specified texture, texture rectangle, and grid size.
	///
	/// # Arguments
	///
	/// * `texture` - The texture to use for the grid.
	/// * `grid_x` - The number of columns in the grid.
	/// * `grid_y` - The number of rows in the grid.
	///
	/// # Returns
	///
	/// * `Grid` - The new Grid instance.
	pub fn with_texture(texture: &crate::dora::Texture2D, grid_x: i32, grid_y: i32) -> Grid {
		unsafe { return Grid { raw: grid_with_texture(texture.raw(), grid_x, grid_y) }; }
	}
	/// Creates a new Grid with the specified clip string and grid size.
	///
	/// # Arguments
	///
	/// * `clip_str` - The clip string to use for the grid. Can be "Image/file.png" and "Image/items.clip|itemA".
	/// * `grid_x` - The number of columns in the grid.
	/// * `grid_y` - The number of rows in the grid.
	///
	/// # Returns
	///
	/// * `Grid` - The new Grid instance.
	pub fn with_file(clip_str: &str, grid_x: i32, grid_y: i32) -> Option<Grid> {
		unsafe { return Grid::from(grid_with_file(crate::dora::from_string(clip_str), grid_x, grid_y)); }
	}
}