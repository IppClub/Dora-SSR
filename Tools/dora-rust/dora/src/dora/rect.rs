/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn rect_release(raw: i64);
	fn rect_set_origin(slf: i64, val: i64);
	fn rect_get_origin(slf: i64) -> i64;
	fn rect_set_size(slf: i64, val: i64);
	fn rect_get_size(slf: i64) -> i64;
	fn rect_set_x(slf: i64, val: f32);
	fn rect_get_x(slf: i64) -> f32;
	fn rect_set_y(slf: i64, val: f32);
	fn rect_get_y(slf: i64) -> f32;
	fn rect_set_width(slf: i64, val: f32);
	fn rect_get_width(slf: i64) -> f32;
	fn rect_set_height(slf: i64, val: f32);
	fn rect_get_height(slf: i64) -> f32;
	fn rect_set_left(slf: i64, val: f32);
	fn rect_get_left(slf: i64) -> f32;
	fn rect_set_right(slf: i64, val: f32);
	fn rect_get_right(slf: i64) -> f32;
	fn rect_set_center_x(slf: i64, val: f32);
	fn rect_get_center_x(slf: i64) -> f32;
	fn rect_set_center_y(slf: i64, val: f32);
	fn rect_get_center_y(slf: i64) -> f32;
	fn rect_set_bottom(slf: i64, val: f32);
	fn rect_get_bottom(slf: i64) -> f32;
	fn rect_set_top(slf: i64, val: f32);
	fn rect_get_top(slf: i64) -> f32;
	fn rect_set_lower_bound(slf: i64, val: i64);
	fn rect_get_lower_bound(slf: i64) -> i64;
	fn rect_set_upper_bound(slf: i64, val: i64);
	fn rect_get_upper_bound(slf: i64) -> i64;
	fn rect_set(slf: i64, x: f32, y: f32, width: f32, height: f32);
	fn rect_contains_point(slf: i64, point: i64) -> i32;
	fn rect_intersects_rect(slf: i64, rect: i64) -> i32;
	fn rect_equals(slf: i64, other: i64) -> i32;
	fn rect_new(origin: i64, size: i64) -> i64;
	fn rect_zero() -> i64;
}
impl PartialEq for Rect {
	/// Checks if two rectangles are equal.
	///
	/// # Arguments
	///
	/// * `other` - The other rectangle to compare to, represented by a Rect object.
	///
	/// # Returns
	///
	/// * `bool` - Whether or not the two rectangles are equal.
	fn eq(&self, other: &Self) -> bool {
		unsafe { return rect_equals(self.raw(), other.raw()) != 0 }
	}
}
/// A rectangle object with a left-bottom origin position and a size.
pub struct Rect { raw: i64 }
impl Drop for Rect {
	fn drop(&mut self) { unsafe { rect_release(self.raw); } }
}
impl Rect {
	pub(crate) fn raw(&self) -> i64 {
		self.raw
	}
	pub(crate) fn from(raw: i64) -> Rect {
		Rect { raw: raw }
	}
	/// Sets the position of the origin of the rectangle.
	pub fn set_origin(&mut self, val: &crate::dora::Vec2) {
		unsafe { rect_set_origin(self.raw(), val.into_i64()) };
	}
	/// Gets the position of the origin of the rectangle.
	pub fn get_origin(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(rect_get_origin(self.raw())) };
	}
	/// Sets the dimensions of the rectangle.
	pub fn set_size(&mut self, val: &crate::dora::Size) {
		unsafe { rect_set_size(self.raw(), val.into_i64()) };
	}
	/// Gets the dimensions of the rectangle.
	pub fn get_size(&self) -> crate::dora::Size {
		return unsafe { crate::dora::Size::from(rect_get_size(self.raw())) };
	}
	/// Sets the x-coordinate of the origin of the rectangle.
	pub fn set_x(&mut self, val: f32) {
		unsafe { rect_set_x(self.raw(), val) };
	}
	/// Gets the x-coordinate of the origin of the rectangle.
	pub fn get_x(&self) -> f32 {
		return unsafe { rect_get_x(self.raw()) };
	}
	/// Sets the y-coordinate of the origin of the rectangle.
	pub fn set_y(&mut self, val: f32) {
		unsafe { rect_set_y(self.raw(), val) };
	}
	/// Gets the y-coordinate of the origin of the rectangle.
	pub fn get_y(&self) -> f32 {
		return unsafe { rect_get_y(self.raw()) };
	}
	/// Sets the width of the rectangle.
	pub fn set_width(&mut self, val: f32) {
		unsafe { rect_set_width(self.raw(), val) };
	}
	/// Gets the width of the rectangle.
	pub fn get_width(&self) -> f32 {
		return unsafe { rect_get_width(self.raw()) };
	}
	/// Sets the height of the rectangle.
	pub fn set_height(&mut self, val: f32) {
		unsafe { rect_set_height(self.raw(), val) };
	}
	/// Gets the height of the rectangle.
	pub fn get_height(&self) -> f32 {
		return unsafe { rect_get_height(self.raw()) };
	}
	/// Sets the left edge in x-axis of the rectangle.
	pub fn set_left(&mut self, val: f32) {
		unsafe { rect_set_left(self.raw(), val) };
	}
	/// Gets the left edge in x-axis of the rectangle.
	pub fn get_left(&self) -> f32 {
		return unsafe { rect_get_left(self.raw()) };
	}
	/// Sets the right edge in x-axis of the rectangle.
	pub fn set_right(&mut self, val: f32) {
		unsafe { rect_set_right(self.raw(), val) };
	}
	/// Gets the right edge in x-axis of the rectangle.
	pub fn get_right(&self) -> f32 {
		return unsafe { rect_get_right(self.raw()) };
	}
	/// Sets the x-coordinate of the center of the rectangle.
	pub fn set_center_x(&mut self, val: f32) {
		unsafe { rect_set_center_x(self.raw(), val) };
	}
	/// Gets the x-coordinate of the center of the rectangle.
	pub fn get_center_x(&self) -> f32 {
		return unsafe { rect_get_center_x(self.raw()) };
	}
	/// Sets the y-coordinate of the center of the rectangle.
	pub fn set_center_y(&mut self, val: f32) {
		unsafe { rect_set_center_y(self.raw(), val) };
	}
	/// Gets the y-coordinate of the center of the rectangle.
	pub fn get_center_y(&self) -> f32 {
		return unsafe { rect_get_center_y(self.raw()) };
	}
	/// Sets the bottom edge in y-axis of the rectangle.
	pub fn set_bottom(&mut self, val: f32) {
		unsafe { rect_set_bottom(self.raw(), val) };
	}
	/// Gets the bottom edge in y-axis of the rectangle.
	pub fn get_bottom(&self) -> f32 {
		return unsafe { rect_get_bottom(self.raw()) };
	}
	/// Sets the top edge in y-axis of the rectangle.
	pub fn set_top(&mut self, val: f32) {
		unsafe { rect_set_top(self.raw(), val) };
	}
	/// Gets the top edge in y-axis of the rectangle.
	pub fn get_top(&self) -> f32 {
		return unsafe { rect_get_top(self.raw()) };
	}
	/// Sets the lower bound (left-bottom) of the rectangle.
	pub fn set_lower_bound(&mut self, val: &crate::dora::Vec2) {
		unsafe { rect_set_lower_bound(self.raw(), val.into_i64()) };
	}
	/// Gets the lower bound (left-bottom) of the rectangle.
	pub fn get_lower_bound(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(rect_get_lower_bound(self.raw())) };
	}
	/// Sets the upper bound (right-top) of the rectangle.
	pub fn set_upper_bound(&mut self, val: &crate::dora::Vec2) {
		unsafe { rect_set_upper_bound(self.raw(), val.into_i64()) };
	}
	/// Gets the upper bound (right-top) of the rectangle.
	pub fn get_upper_bound(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(rect_get_upper_bound(self.raw())) };
	}
	/// Sets the properties of the rectangle.
	///
	/// # Arguments
	///
	/// * `x` - The x-coordinate of the origin of the rectangle.
	/// * `y` - The y-coordinate of the origin of the rectangle.
	/// * `width` - The width of the rectangle.
	/// * `height` - The height of the rectangle.
	pub fn set(&mut self, x: f32, y: f32, width: f32, height: f32) {
		unsafe { rect_set(self.raw(), x, y, width, height); }
	}
	/// Checks if a point is inside the rectangle.
	///
	/// # Arguments
	///
	/// * `point` - The point to check, represented by a Vec2 object.
	///
	/// # Returns
	///
	/// * `bool` - Whether or not the point is inside the rectangle.
	pub fn contains_point(&self, point: &crate::dora::Vec2) -> bool {
		unsafe { return rect_contains_point(self.raw(), point.into_i64()) != 0; }
	}
	/// Checks if the rectangle intersects with another rectangle.
	///
	/// # Arguments
	///
	/// * `rect` - The other rectangle to check for intersection with, represented by a Rect object.
	///
	/// # Returns
	///
	/// * `bool` - Whether or not the rectangles intersect.
	pub fn intersects_rect(&self, rect: &crate::dora::Rect) -> bool {
		unsafe { return rect_intersects_rect(self.raw(), rect.raw()) != 0; }
	}
	/// Creates a new rectangle object using a Vec2 object for the origin and a Size object for the size.
	///
	/// # Arguments
	///
	/// * `origin` - The origin of the rectangle, represented by a Vec2 object.
	/// * `size` - The size of the rectangle, represented by a Size object.
	///
	/// # Returns
	///
	/// * `Rect` - A new rectangle object.
	pub fn new(origin: &crate::dora::Vec2, size: &crate::dora::Size) -> crate::dora::Rect {
		unsafe { return crate::dora::Rect::from(rect_new(origin.into_i64(), size.into_i64())); }
	}
	/// Gets a rectangle object with all properties set to 0.
	pub fn zero() -> crate::dora::Rect {
		unsafe { return crate::dora::Rect::from(rect_zero()); }
	}
}