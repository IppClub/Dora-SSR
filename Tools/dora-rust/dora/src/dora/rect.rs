extern "C" {
	fn rect_release(raw: i64);
	fn rect_set_origin(slf: i64, var: i64);
	fn rect_get_origin(slf: i64) -> i64;
	fn rect_set_size(slf: i64, var: i64);
	fn rect_get_size(slf: i64) -> i64;
	fn rect_set_x(slf: i64, var: f32);
	fn rect_get_x(slf: i64) -> f32;
	fn rect_set_y(slf: i64, var: f32);
	fn rect_get_y(slf: i64) -> f32;
	fn rect_set_width(slf: i64, var: f32);
	fn rect_get_width(slf: i64) -> f32;
	fn rect_set_height(slf: i64, var: f32);
	fn rect_get_height(slf: i64) -> f32;
	fn rect_set_left(slf: i64, var: f32);
	fn rect_get_left(slf: i64) -> f32;
	fn rect_set_right(slf: i64, var: f32);
	fn rect_get_right(slf: i64) -> f32;
	fn rect_set_center_x(slf: i64, var: f32);
	fn rect_get_center_x(slf: i64) -> f32;
	fn rect_set_center_y(slf: i64, var: f32);
	fn rect_get_center_y(slf: i64) -> f32;
	fn rect_set_bottom(slf: i64, var: f32);
	fn rect_get_bottom(slf: i64) -> f32;
	fn rect_set_top(slf: i64, var: f32);
	fn rect_get_top(slf: i64) -> f32;
	fn rect_set_lower_bound(slf: i64, var: i64);
	fn rect_get_lower_bound(slf: i64) -> i64;
	fn rect_set_upper_bound(slf: i64, var: i64);
	fn rect_get_upper_bound(slf: i64) -> i64;
	fn rect_set(slf: i64, x: f32, y: f32, width: f32, height: f32);
	fn rect_contains_point(slf: i64, point: i64) -> i32;
	fn rect_intersects_rect(slf: i64, rect: i64) -> i32;
	fn rect_equals(slf: i64, other: i64) -> i32;
	fn rect_new(origin: i64, size: i64) -> i64;
	fn rect_zero() -> i64;
}
impl PartialEq for Rect {
	fn eq(&self, other: &Self) -> bool {
		unsafe { return rect_equals(self.raw(), other.raw()) != 0 }
	}
}
pub struct Rect { raw: i64 }
impl Drop for Rect {
	fn drop(&mut self) { unsafe { rect_release(self.raw); } }
}
impl Rect {
	pub fn raw(&self) -> i64 {
		self.raw
	}
	pub fn from(raw: i64) -> Rect {
		Rect { raw: raw }
	}
	pub fn set_origin(&mut self, var: &crate::dora::Vec2) {
		unsafe { rect_set_origin(self.raw(), var.into_i64()) };
	}
	pub fn get_origin(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(rect_get_origin(self.raw())) };
	}
	pub fn set_size(&mut self, var: &crate::dora::Size) {
		unsafe { rect_set_size(self.raw(), var.into_i64()) };
	}
	pub fn get_size(&self) -> crate::dora::Size {
		return unsafe { crate::dora::Size::from(rect_get_size(self.raw())) };
	}
	pub fn set_x(&mut self, var: f32) {
		unsafe { rect_set_x(self.raw(), var) };
	}
	pub fn get_x(&self) -> f32 {
		return unsafe { rect_get_x(self.raw()) };
	}
	pub fn set_y(&mut self, var: f32) {
		unsafe { rect_set_y(self.raw(), var) };
	}
	pub fn get_y(&self) -> f32 {
		return unsafe { rect_get_y(self.raw()) };
	}
	pub fn set_width(&mut self, var: f32) {
		unsafe { rect_set_width(self.raw(), var) };
	}
	pub fn get_width(&self) -> f32 {
		return unsafe { rect_get_width(self.raw()) };
	}
	pub fn set_height(&mut self, var: f32) {
		unsafe { rect_set_height(self.raw(), var) };
	}
	pub fn get_height(&self) -> f32 {
		return unsafe { rect_get_height(self.raw()) };
	}
	pub fn set_left(&mut self, var: f32) {
		unsafe { rect_set_left(self.raw(), var) };
	}
	pub fn get_left(&self) -> f32 {
		return unsafe { rect_get_left(self.raw()) };
	}
	pub fn set_right(&mut self, var: f32) {
		unsafe { rect_set_right(self.raw(), var) };
	}
	pub fn get_right(&self) -> f32 {
		return unsafe { rect_get_right(self.raw()) };
	}
	pub fn set_center_x(&mut self, var: f32) {
		unsafe { rect_set_center_x(self.raw(), var) };
	}
	pub fn get_center_x(&self) -> f32 {
		return unsafe { rect_get_center_x(self.raw()) };
	}
	pub fn set_center_y(&mut self, var: f32) {
		unsafe { rect_set_center_y(self.raw(), var) };
	}
	pub fn get_center_y(&self) -> f32 {
		return unsafe { rect_get_center_y(self.raw()) };
	}
	pub fn set_bottom(&mut self, var: f32) {
		unsafe { rect_set_bottom(self.raw(), var) };
	}
	pub fn get_bottom(&self) -> f32 {
		return unsafe { rect_get_bottom(self.raw()) };
	}
	pub fn set_top(&mut self, var: f32) {
		unsafe { rect_set_top(self.raw(), var) };
	}
	pub fn get_top(&self) -> f32 {
		return unsafe { rect_get_top(self.raw()) };
	}
	pub fn set_lower_bound(&mut self, var: &crate::dora::Vec2) {
		unsafe { rect_set_lower_bound(self.raw(), var.into_i64()) };
	}
	pub fn get_lower_bound(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(rect_get_lower_bound(self.raw())) };
	}
	pub fn set_upper_bound(&mut self, var: &crate::dora::Vec2) {
		unsafe { rect_set_upper_bound(self.raw(), var.into_i64()) };
	}
	pub fn get_upper_bound(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(rect_get_upper_bound(self.raw())) };
	}
	pub fn set(&mut self, x: f32, y: f32, width: f32, height: f32) {
		unsafe { rect_set(self.raw(), x, y, width, height); }
	}
	pub fn contains_point(&self, point: &crate::dora::Vec2) -> bool {
		unsafe { return rect_contains_point(self.raw(), point.into_i64()) != 0; }
	}
	pub fn intersects_rect(&self, rect: &crate::dora::Rect) -> bool {
		unsafe { return rect_intersects_rect(self.raw(), rect.raw()) != 0; }
	}
	pub fn new(origin: &crate::dora::Vec2, size: &crate::dora::Size) -> crate::dora::Rect {
		unsafe { return crate::dora::Rect::from(rect_new(origin.into_i64(), size.into_i64())); }
	}
	pub fn zero() -> crate::dora::Rect {
		unsafe { return crate::dora::Rect::from(rect_zero()); }
	}
}