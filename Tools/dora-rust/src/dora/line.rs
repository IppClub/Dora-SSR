extern "C" {
	fn line_type() -> i32;
	fn line_set_depth_write(slf: i64, var: i32);
	fn line_is_depth_write(slf: i64) -> i32;
	fn line_set_blend_func(slf: i64, var: i64);
	fn line_get_blend_func(slf: i64) -> i64;
	fn line_add(slf: i64, verts: i64, color: i32);
	fn line_set(slf: i64, verts: i64, color: i32);
	fn line_clear(slf: i64);
	fn line_new() -> i64;
	fn line_with_vec_color(verts: i64, color: i32) -> i64;
}
use crate::dora::Object;
use crate::dora::INode;
impl INode for Line { }
pub struct Line { raw: i64 }
crate::dora_object!(Line);
impl Line {
	pub fn set_depth_write(&mut self, var: bool) {
		unsafe { line_set_depth_write(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_depth_write(&self) -> bool {
		return unsafe { line_is_depth_write(self.raw()) != 0 };
	}
	pub fn set_blend_func(&mut self, var: u64) {
		unsafe { line_set_blend_func(self.raw(), var as i64) };
	}
	pub fn get_blend_func(&self) -> u64 {
		return unsafe { line_get_blend_func(self.raw()) as u64 };
	}
	pub fn add(&mut self, verts: &Vec<crate::dora::Vec2>, color: &crate::dora::Color) {
		unsafe { line_add(self.raw(), crate::dora::Vector::from_vec2(verts), color.to_argb() as i32) };
	}
	pub fn set(&mut self, verts: &Vec<crate::dora::Vec2>, color: &crate::dora::Color) {
		unsafe { line_set(self.raw(), crate::dora::Vector::from_vec2(verts), color.to_argb() as i32) };
	}
	pub fn clear(&mut self) {
		unsafe { line_clear(self.raw()) };
	}
	pub fn new() -> Line {
		return Line { raw: unsafe { line_new() } };
	}
	pub fn with_vec_color(verts: &Vec<crate::dora::Vec2>, color: &crate::dora::Color) -> Line {
		return Line { raw: unsafe { line_with_vec_color(crate::dora::Vector::from_vec2(verts), color.to_argb() as i32) } };
	}
}