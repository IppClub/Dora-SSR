/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn drawnode_type() -> i32;
	fn drawnode_set_depth_write(slf: i64, val: i32);
	fn drawnode_is_depth_write(slf: i64) -> i32;
	fn drawnode_set_blend_func(slf: i64, val: i64);
	fn drawnode_get_blend_func(slf: i64) -> i64;
	fn drawnode_draw_dot(slf: i64, pos: i64, radius: f32, color: i32);
	fn drawnode_draw_circle(slf: i64, center: i64, radius: f32, color: i32);
	fn drawnode_draw_rect(slf: i64, rect: i64, fill_color: i32, border_width: f32, border_color: i32);
	fn drawnode_draw_ellipse(slf: i64, center: i64, radius_x: f32, radius_y: f32, color: i32);
	fn drawnode_draw_segment(slf: i64, from: i64, to: i64, radius: f32, color: i32);
	fn drawnode_draw_polyline(slf: i64, verts: i64, radius: f32, color: i32, closed: i32);
	fn drawnode_draw_arc(slf: i64, center: i64, radius: f32, start_angle: f32, end_angle: f32, line_radius: f32, color: i32);
	fn drawnode_draw_rounded_rect(slf: i64, rect: i64, corner_radius: f32, fill_color: i32, border_width: f32, border_color: i32);
	fn drawnode_draw_ring(slf: i64, center: i64, inner_radius: f32, outer_radius: f32, fill_color: i32, border_width: f32, border_color: i32);
	fn drawnode_draw_sector(slf: i64, center: i64, radius: f32, start_angle: f32, end_angle: f32, fill_color: i32, border_width: f32, border_color: i32);
	fn drawnode_draw_quadratic_bezier(slf: i64, from: i64, control: i64, to: i64, radius: f32, color: i32);
	fn drawnode_draw_cubic_bezier(slf: i64, from: i64, control_1: i64, control_2: i64, to: i64, radius: f32, color: i32);
	fn drawnode_draw_polygon(slf: i64, verts: i64, fill_color: i32, border_width: f32, border_color: i32);
	fn drawnode_draw_vertices(slf: i64, verts: i64);
	fn drawnode_clear(slf: i64);
	fn drawnode_new() -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for DrawNode { }
/// A scene node that draws simple shapes such as dots, lines, and polygons.
pub struct DrawNode { raw: i64 }
crate::dora_object!(DrawNode);
impl DrawNode {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { drawnode_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(DrawNode { raw: raw }))
			}
		})
	}
	/// Sets whether to write to the depth buffer when drawing (default is false).
	pub fn set_depth_write(&mut self, val: bool) {
		unsafe { drawnode_set_depth_write(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether to write to the depth buffer when drawing (default is false).
	pub fn is_depth_write(&self) -> bool {
		return unsafe { drawnode_is_depth_write(self.raw()) != 0 };
	}
	/// Sets the blend function for the draw node.
	pub fn set_blend_func(&mut self, val: crate::dora::BlendFunc) {
		unsafe { drawnode_set_blend_func(self.raw(), val.to_value()) };
	}
	/// Gets the blend function for the draw node.
	pub fn get_blend_func(&self) -> crate::dora::BlendFunc {
		return unsafe { crate::dora::BlendFunc::from(drawnode_get_blend_func(self.raw())) };
	}
	/// Draws a dot at a specified position with a specified radius and color.
	///
	/// # Arguments
	///
	/// * `pos` - The position of the dot.
	/// * `radius` - The radius of the dot.
	/// * `color` - The color of the dot.
	pub fn draw_dot(&mut self, pos: &crate::dora::Vec2, radius: f32, color: &crate::dora::Color) {
		unsafe { drawnode_draw_dot(self.raw(), pos.into_i64(), radius, color.to_argb() as i32); }
	}
	/// Draws a circle at a specified center with a specified radius and color.
	///
	/// # Arguments
	///
	/// * `center` - The center of the circle.
	/// * `radius` - The radius of the circle.
	/// * `color` - The color of the circle.
	pub fn draw_circle(&mut self, center: &crate::dora::Vec2, radius: f32, color: &crate::dora::Color) {
		unsafe { drawnode_draw_circle(self.raw(), center.into_i64(), radius, color.to_argb() as i32); }
	}
	/// Draws a rectangle with an optional border.
	///
	/// # Arguments
	///
	/// * `rect` - The rectangle to draw.
	/// * `fill_color` - The fill color of the rectangle.
	/// * `border_width` - Half of the border width, extending to both sides of the outline.
	/// * `border_color` - The color of the border.
	pub fn draw_rect(&mut self, rect: &crate::dora::Rect, fill_color: &crate::dora::Color, border_width: f32, border_color: &crate::dora::Color) {
		unsafe { drawnode_draw_rect(self.raw(), rect.raw(), fill_color.to_argb() as i32, border_width, border_color.to_argb() as i32); }
	}
	/// Draws a filled ellipse at a specified center.
	///
	/// # Arguments
	///
	/// * `center` - The center of the ellipse.
	/// * `radius_x` - The horizontal radius of the ellipse.
	/// * `radius_y` - The vertical radius of the ellipse.
	/// * `color` - The color of the ellipse.
	pub fn draw_ellipse(&mut self, center: &crate::dora::Vec2, radius_x: f32, radius_y: f32, color: &crate::dora::Color) {
		unsafe { drawnode_draw_ellipse(self.raw(), center.into_i64(), radius_x, radius_y, color.to_argb() as i32); }
	}
	/// Draws a line segment between two points with a specified radius and color.
	///
	/// # Arguments
	///
	/// * `from` - The starting point of the line.
	/// * `to` - The ending point of the line.
	/// * `radius` - The radius of the line.
	/// * `color` - The color of the line.
	pub fn draw_segment(&mut self, from: &crate::dora::Vec2, to: &crate::dora::Vec2, radius: f32, color: &crate::dora::Color) {
		unsafe { drawnode_draw_segment(self.raw(), from.into_i64(), to.into_i64(), radius, color.to_argb() as i32); }
	}
	/// Draws a connected stroke with round caps and miter joins, beveling long miters. Radius is half the width; adjacent duplicates are ignored.
	///
	/// # Arguments
	///
	/// * `verts` - The vertices of the polyline.
	/// * `radius` - Half of the line width.
	/// * `color` - The color of the polyline.
	/// * `closed` - Whether to connect the last vertex back to the first.
	pub fn draw_polyline(&mut self, verts: &Vec<crate::dora::Vec2>, radius: f32, color: &crate::dora::Color, closed: bool) {
		unsafe { drawnode_draw_polyline(self.raw(), crate::dora::Vector::from_vec2(verts), radius, color.to_argb() as i32, if closed { 1 } else { 0 }); }
	}
	/// Draws an arc in degrees: zero points along +X and increasing angles turn toward +Y. The signed sweep is limited to one revolution; full circles close without caps. Line radius is half the width.
	///
	/// # Arguments
	///
	/// * `center` - The center of the arc.
	/// * `radius` - The radius from the center to the arc.
	/// * `start_angle` - The starting angle in degrees.
	/// * `end_angle` - The ending angle in degrees.
	/// * `line_radius` - Half of the line width.
	/// * `color` - The color of the arc.
	pub fn draw_arc(&mut self, center: &crate::dora::Vec2, radius: f32, start_angle: f32, end_angle: f32, line_radius: f32, color: &crate::dora::Color) {
		unsafe { drawnode_draw_arc(self.raw(), center.into_i64(), radius, start_angle, end_angle, line_radius, color.to_argb() as i32); }
	}
	/// Draws a rounded rectangle. The corner radius is clamped to half the smaller dimension; zero draws a rectangle. Border width is a half width centered on the outline.
	pub fn draw_rounded_rect(&mut self, rect: &crate::dora::Rect, corner_radius: f32, fill_color: &crate::dora::Color, border_width: f32, border_color: &crate::dora::Color) {
		unsafe { drawnode_draw_rounded_rect(self.raw(), rect.raw(), corner_radius, fill_color.to_argb() as i32, border_width, border_color.to_argb() as i32); }
	}
	/// Draws a ring with 0 <= innerRadius < outerRadius. Zero inner radius fills the center. Optional centered borders surround both contours; border width is a half width.
	pub fn draw_ring(&mut self, center: &crate::dora::Vec2, inner_radius: f32, outer_radius: f32, fill_color: &crate::dora::Color, border_width: f32, border_color: &crate::dora::Color) {
		unsafe { drawnode_draw_ring(self.raw(), center.into_i64(), inner_radius, outer_radius, fill_color.to_argb() as i32, border_width, border_color.to_argb() as i32); }
	}
	/// Draws a filled sector in degrees from +X toward +Y. Signed sweep is limited to one revolution. Full circles omit radial edges; equal angles draw nothing. Border width is a half width.
	pub fn draw_sector(&mut self, center: &crate::dora::Vec2, radius: f32, start_angle: f32, end_angle: f32, fill_color: &crate::dora::Color, border_width: f32, border_color: &crate::dora::Color) {
		unsafe { drawnode_draw_sector(self.raw(), center.into_i64(), radius, start_angle, end_angle, fill_color.to_argb() as i32, border_width, border_color.to_argb() as i32); }
	}
	/// Draws a quadratic Bezier stroke with round caps; coincident endpoints close the stroke. Radius is half the width. Adaptive subdivision targets 0.25 local units, with at most 1024 segments.
	pub fn draw_quadratic_bezier(&mut self, from: &crate::dora::Vec2, control: &crate::dora::Vec2, to: &crate::dora::Vec2, radius: f32, color: &crate::dora::Color) {
		unsafe { drawnode_draw_quadratic_bezier(self.raw(), from.into_i64(), control.into_i64(), to.into_i64(), radius, color.to_argb() as i32); }
	}
	/// Draws a cubic Bezier stroke with round caps; coincident endpoints close the stroke. Radius is half the width. Adaptive subdivision targets 0.25 local units, with at most 1024 segments.
	pub fn draw_cubic_bezier(&mut self, from: &crate::dora::Vec2, control_1: &crate::dora::Vec2, control_2: &crate::dora::Vec2, to: &crate::dora::Vec2, radius: f32, color: &crate::dora::Color) {
		unsafe { drawnode_draw_cubic_bezier(self.raw(), from.into_i64(), control_1.into_i64(), control_2.into_i64(), to.into_i64(), radius, color.to_argb() as i32); }
	}
	/// Draws a simple convex or concave polygon in boundary order with either winding. Self-intersections and holes are unsupported; the border is centered on the outline.
	///
	/// # Arguments
	///
	/// * `verts` - The vertices of the polygon.
	/// * `fill_color` - The fill color of the polygon.
	/// * `border_width` - Half of the border width, extending to both sides of the outline.
	/// * `border_color` - The color of the border.
	pub fn draw_polygon(&mut self, verts: &Vec<crate::dora::Vec2>, fill_color: &crate::dora::Color, border_width: f32, border_color: &crate::dora::Color) {
		unsafe { drawnode_draw_polygon(self.raw(), crate::dora::Vector::from_vec2(verts), fill_color.to_argb() as i32, border_width, border_color.to_argb() as i32); }
	}
	/// Draws a set of vertices as triangles, each vertex with its own color.
	///
	/// # Arguments
	///
	/// * `verts` - The list of vertices and their colors. Each element is a tuple where the first element is a `Vec2` and the second element is a `Color`.
	pub fn draw_vertices(&mut self, verts: &Vec<crate::dora::VertexColor>) {
		unsafe { drawnode_draw_vertices(self.raw(), crate::dora::Vector::from_vertex_color(verts)); }
	}
	/// Clears all previously drawn shapes from the node.
	pub fn clear(&mut self) {
		unsafe { drawnode_clear(self.raw()); }
	}
	/// Creates a new DrawNode object.
	///
	/// # Returns
	///
	/// * A new `DrawNode` object.
	pub fn new() -> DrawNode {
		unsafe { return DrawNode { raw: drawnode_new() }; }
	}
}
