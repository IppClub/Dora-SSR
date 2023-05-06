extern "C" {
	fn drawnode_type() -> i32;
	fn drawnode_set_depth_write(slf: i64, var: i32);
	fn drawnode_is_depth_write(slf: i64) -> i32;
	fn drawnode_set_blend_func(slf: i64, var: i64);
	fn drawnode_get_blend_func(slf: i64) -> i64;
	fn drawnode_draw_dot(slf: i64, pos: i64, radius: f32, color: i32);
	fn drawnode_draw_segment(slf: i64, from: i64, to: i64, radius: f32, color: i32);
	fn drawnode_draw_polygon(slf: i64, verts: i64, fill_color: i32, border_width: f32, border_color: i32);
	fn drawnode_draw_vertices(slf: i64, verts: i64);
	fn drawnode_clear(slf: i64);
	fn drawnode_new() -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for DrawNode { }
pub struct DrawNode { raw: i64 }
crate::dora_object!(DrawNode);
impl DrawNode {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { drawnode_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(DrawNode { raw: raw }))
			}
		})
	}
	pub fn set_depth_write(&mut self, var: bool) {
		unsafe { drawnode_set_depth_write(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_depth_write(&self) -> bool {
		return unsafe { drawnode_is_depth_write(self.raw()) != 0 };
	}
	pub fn set_blend_func(&mut self, var: u64) {
		unsafe { drawnode_set_blend_func(self.raw(), var as i64) };
	}
	pub fn get_blend_func(&self) -> u64 {
		return unsafe { drawnode_get_blend_func(self.raw()) as u64 };
	}
	pub fn draw_dot(&mut self, pos: &crate::dora::Vec2, radius: f32, color: &crate::dora::Color) {
		unsafe { drawnode_draw_dot(self.raw(), pos.into_i64(), radius, color.to_argb() as i32); }
	}
	pub fn draw_segment(&mut self, from: &crate::dora::Vec2, to: &crate::dora::Vec2, radius: f32, color: &crate::dora::Color) {
		unsafe { drawnode_draw_segment(self.raw(), from.into_i64(), to.into_i64(), radius, color.to_argb() as i32); }
	}
	pub fn draw_polygon(&mut self, verts: &Vec<crate::dora::Vec2>, fill_color: &crate::dora::Color, border_width: f32, border_color: &crate::dora::Color) {
		unsafe { drawnode_draw_polygon(self.raw(), crate::dora::Vector::from_vec2(verts), fill_color.to_argb() as i32, border_width, border_color.to_argb() as i32); }
	}
	pub fn draw_vertices(&mut self, verts: &Vec<crate::dora::VertexColor>) {
		unsafe { drawnode_draw_vertices(self.raw(), crate::dora::Vector::from_vertex_color(verts)); }
	}
	pub fn clear(&mut self) {
		unsafe { drawnode_clear(self.raw()); }
	}
	pub fn new() -> DrawNode {
		unsafe { return DrawNode { raw: drawnode_new() }; }
	}
}