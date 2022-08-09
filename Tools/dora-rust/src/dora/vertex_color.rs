extern "C" {
	fn vertexcolor_release(raw: i64);
	fn vertexcolor_set_vertex(slf: i64, var: i64);
	fn vertexcolor_get_vertex(slf: i64) -> i64;
	fn vertexcolor_set_color(slf: i64, var: i32);
	fn vertexcolor_get_color(slf: i64) -> i32;
	fn vertexcolor_new(vec: i64, color: i32) -> i64;
}
pub struct VertexColor { raw: i64 }
impl Drop for VertexColor {
	fn drop(&mut self) { unsafe { vertexcolor_release(self.raw); } }
}
impl VertexColor {
	pub fn raw(&self) -> i64 {
		self.raw
	}
	pub fn from(raw: i64) -> VertexColor {
		VertexColor { raw: raw }
	}
	pub fn set_vertex(&mut self, var: &crate::dora::Vec2) {
		unsafe { vertexcolor_set_vertex(self.raw(), var.into_i64()) };
	}
	pub fn get_vertex(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(vertexcolor_get_vertex(self.raw())) };
	}
	pub fn set_color(&mut self, var: &crate::dora::Color) {
		unsafe { vertexcolor_set_color(self.raw(), var.to_argb() as i32) };
	}
	pub fn get_color(&self) -> crate::dora::Color {
		return unsafe { crate::dora::Color::from(vertexcolor_get_color(self.raw())) };
	}
	pub fn new(vec: &crate::dora::Vec2, color: &crate::dora::Color) -> crate::dora::VertexColor {
		return crate::dora::VertexColor::from(unsafe { vertexcolor_new(vec.into_i64(), color.to_argb() as i32) });
	}
}