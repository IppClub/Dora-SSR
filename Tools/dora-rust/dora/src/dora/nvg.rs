/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn nvg_save();
	fn nvg_restore();
	fn nvg_reset();
	fn nvg__create_image(w: i32, h: i32, filename: i64, image_flags: i32) -> i32;
	fn nvg_create_font(name: i64) -> i32;
	fn nvg_text_bounds(x: f32, y: f32, text: i64, bounds: i64) -> f32;
	fn nvg_text_box_bounds(x: f32, y: f32, break_row_width: f32, text: i64) -> i64;
	fn nvg_text(x: f32, y: f32, text: i64) -> f32;
	fn nvg_text_box(x: f32, y: f32, break_row_width: f32, text: i64);
	fn nvg_stroke_color(color: i32);
	fn nvg_stroke_paint(paint: i64);
	fn nvg_fill_color(color: i32);
	fn nvg_fill_paint(paint: i64);
	fn nvg_miter_limit(limit: f32);
	fn nvg_stroke_width(size: f32);
	fn nvg__line_cap(cap: i32);
	fn nvg__line_join(join: i32);
	fn nvg_global_alpha(alpha: f32);
	fn nvg_reset_transform();
	fn nvg_apply_transform(node: i64);
	fn nvg_translate(x: f32, y: f32);
	fn nvg_rotate(angle: f32);
	fn nvg_skew_x(angle: f32);
	fn nvg_skew_y(angle: f32);
	fn nvg_scale(x: f32, y: f32);
	fn nvg_image_size(image: i32) -> i64;
	fn nvg_delete_image(image: i32);
	fn nvg_linear_gradient(sx: f32, sy: f32, ex: f32, ey: f32, icol: i32, ocol: i32) -> i64;
	fn nvg_box_gradient(x: f32, y: f32, w: f32, h: f32, r: f32, f: f32, icol: i32, ocol: i32) -> i64;
	fn nvg_radial_gradient(cx: f32, cy: f32, inr: f32, outr: f32, icol: i32, ocol: i32) -> i64;
	fn nvg_image_pattern(ox: f32, oy: f32, ex: f32, ey: f32, angle: f32, image: i32, alpha: f32) -> i64;
	fn nvg_scissor(x: f32, y: f32, w: f32, h: f32);
	fn nvg_intersect_scissor(x: f32, y: f32, w: f32, h: f32);
	fn nvg_reset_scissor();
	fn nvg_begin_path();
	fn nvg_move_to(x: f32, y: f32);
	fn nvg_line_to(x: f32, y: f32);
	fn nvg_bezier_to(c_1x: f32, c_1y: f32, c_2x: f32, c_2y: f32, x: f32, y: f32);
	fn nvg_quad_to(cx: f32, cy: f32, x: f32, y: f32);
	fn nvg_arc_to(x_1: f32, y_1: f32, x_2: f32, y_2: f32, radius: f32);
	fn nvg_close_path();
	fn nvg__path_winding(dir: i32);
	fn nvg__arc(cx: f32, cy: f32, r: f32, a_0: f32, a_1: f32, dir: i32);
	fn nvg_rect(x: f32, y: f32, w: f32, h: f32);
	fn nvg_rounded_rect(x: f32, y: f32, w: f32, h: f32, r: f32);
	fn nvg_rounded_rect_varying(x: f32, y: f32, w: f32, h: f32, rad_top_left: f32, rad_top_right: f32, rad_bottom_right: f32, rad_bottom_left: f32);
	fn nvg_ellipse(cx: f32, cy: f32, rx: f32, ry: f32);
	fn nvg_circle(cx: f32, cy: f32, r: f32);
	fn nvg_fill();
	fn nvg_stroke();
	fn nvg_find_font(name: i64) -> i32;
	fn nvg_add_fallback_font_id(base_font: i32, fallback_font: i32) -> i32;
	fn nvg_add_fallback_font(base_font: i64, fallback_font: i64) -> i32;
	fn nvg_font_size(size: f32);
	fn nvg_font_blur(blur: f32);
	fn nvg_text_letter_spacing(spacing: f32);
	fn nvg_text_line_height(line_height: f32);
	fn nvg__text_align(h_align: i32, v_align: i32);
	fn nvg_font_face_id(font: i32);
	fn nvg_font_face(font: i64);
	fn nvg_dora_ssr();
	fn nvg_get_dora_ssr(scale: f32) -> i64;
}
pub struct Nvg { }
impl Nvg {
	pub fn save() {
		unsafe { nvg_save(); }
	}
	pub fn restore() {
		unsafe { nvg_restore(); }
	}
	pub fn reset() {
		unsafe { nvg_reset(); }
	}
	pub(crate) fn _create_image(w: i32, h: i32, filename: &str, image_flags: i32) -> i32 {
		unsafe { return nvg__create_image(w, h, crate::dora::from_string(filename), image_flags); }
	}
	pub fn create_font(name: &str) -> i32 {
		unsafe { return nvg_create_font(crate::dora::from_string(name)); }
	}
	pub fn text_bounds(x: f32, y: f32, text: &str, bounds: &crate::dora::Rect) -> f32 {
		unsafe { return nvg_text_bounds(x, y, crate::dora::from_string(text), bounds.raw()); }
	}
	pub fn text_box_bounds(x: f32, y: f32, break_row_width: f32, text: &str) -> crate::dora::Rect {
		unsafe { return crate::dora::Rect::from(nvg_text_box_bounds(x, y, break_row_width, crate::dora::from_string(text))); }
	}
	pub fn text(x: f32, y: f32, text: &str) -> f32 {
		unsafe { return nvg_text(x, y, crate::dora::from_string(text)); }
	}
	pub fn text_box(x: f32, y: f32, break_row_width: f32, text: &str) {
		unsafe { nvg_text_box(x, y, break_row_width, crate::dora::from_string(text)); }
	}
	pub fn stroke_color(color: &crate::dora::Color) {
		unsafe { nvg_stroke_color(color.to_argb() as i32); }
	}
	pub fn stroke_paint(paint: &crate::dora::VGPaint) {
		unsafe { nvg_stroke_paint(paint.raw()); }
	}
	pub fn fill_color(color: &crate::dora::Color) {
		unsafe { nvg_fill_color(color.to_argb() as i32); }
	}
	pub fn fill_paint(paint: &crate::dora::VGPaint) {
		unsafe { nvg_fill_paint(paint.raw()); }
	}
	pub fn miter_limit(limit: f32) {
		unsafe { nvg_miter_limit(limit); }
	}
	pub fn stroke_width(size: f32) {
		unsafe { nvg_stroke_width(size); }
	}
	pub(crate) fn _line_cap(cap: i32) {
		unsafe { nvg__line_cap(cap); }
	}
	pub(crate) fn _line_join(join: i32) {
		unsafe { nvg__line_join(join); }
	}
	pub fn global_alpha(alpha: f32) {
		unsafe { nvg_global_alpha(alpha); }
	}
	pub fn reset_transform() {
		unsafe { nvg_reset_transform(); }
	}
	pub fn apply_transform(node: &dyn crate::dora::INode) {
		unsafe { nvg_apply_transform(node.raw()); }
	}
	pub fn translate(x: f32, y: f32) {
		unsafe { nvg_translate(x, y); }
	}
	pub fn rotate(angle: f32) {
		unsafe { nvg_rotate(angle); }
	}
	pub fn skew_x(angle: f32) {
		unsafe { nvg_skew_x(angle); }
	}
	pub fn skew_y(angle: f32) {
		unsafe { nvg_skew_y(angle); }
	}
	pub fn scale(x: f32, y: f32) {
		unsafe { nvg_scale(x, y); }
	}
	pub fn image_size(image: i32) -> crate::dora::Size {
		unsafe { return crate::dora::Size::from(nvg_image_size(image)); }
	}
	pub fn delete_image(image: i32) {
		unsafe { nvg_delete_image(image); }
	}
	pub fn linear_gradient(sx: f32, sy: f32, ex: f32, ey: f32, icol: &crate::dora::Color, ocol: &crate::dora::Color) -> crate::dora::VGPaint {
		unsafe { return crate::dora::VGPaint::from(nvg_linear_gradient(sx, sy, ex, ey, icol.to_argb() as i32, ocol.to_argb() as i32)); }
	}
	pub fn box_gradient(x: f32, y: f32, w: f32, h: f32, r: f32, f: f32, icol: &crate::dora::Color, ocol: &crate::dora::Color) -> crate::dora::VGPaint {
		unsafe { return crate::dora::VGPaint::from(nvg_box_gradient(x, y, w, h, r, f, icol.to_argb() as i32, ocol.to_argb() as i32)); }
	}
	pub fn radial_gradient(cx: f32, cy: f32, inr: f32, outr: f32, icol: &crate::dora::Color, ocol: &crate::dora::Color) -> crate::dora::VGPaint {
		unsafe { return crate::dora::VGPaint::from(nvg_radial_gradient(cx, cy, inr, outr, icol.to_argb() as i32, ocol.to_argb() as i32)); }
	}
	pub fn image_pattern(ox: f32, oy: f32, ex: f32, ey: f32, angle: f32, image: i32, alpha: f32) -> crate::dora::VGPaint {
		unsafe { return crate::dora::VGPaint::from(nvg_image_pattern(ox, oy, ex, ey, angle, image, alpha)); }
	}
	pub fn scissor(x: f32, y: f32, w: f32, h: f32) {
		unsafe { nvg_scissor(x, y, w, h); }
	}
	pub fn intersect_scissor(x: f32, y: f32, w: f32, h: f32) {
		unsafe { nvg_intersect_scissor(x, y, w, h); }
	}
	pub fn reset_scissor() {
		unsafe { nvg_reset_scissor(); }
	}
	pub fn begin_path() {
		unsafe { nvg_begin_path(); }
	}
	pub fn move_to(x: f32, y: f32) {
		unsafe { nvg_move_to(x, y); }
	}
	pub fn line_to(x: f32, y: f32) {
		unsafe { nvg_line_to(x, y); }
	}
	pub fn bezier_to(c_1x: f32, c_1y: f32, c_2x: f32, c_2y: f32, x: f32, y: f32) {
		unsafe { nvg_bezier_to(c_1x, c_1y, c_2x, c_2y, x, y); }
	}
	pub fn quad_to(cx: f32, cy: f32, x: f32, y: f32) {
		unsafe { nvg_quad_to(cx, cy, x, y); }
	}
	pub fn arc_to(x_1: f32, y_1: f32, x_2: f32, y_2: f32, radius: f32) {
		unsafe { nvg_arc_to(x_1, y_1, x_2, y_2, radius); }
	}
	pub fn close_path() {
		unsafe { nvg_close_path(); }
	}
	pub(crate) fn _path_winding(dir: i32) {
		unsafe { nvg__path_winding(dir); }
	}
	pub(crate) fn _arc(cx: f32, cy: f32, r: f32, a_0: f32, a_1: f32, dir: i32) {
		unsafe { nvg__arc(cx, cy, r, a_0, a_1, dir); }
	}
	pub fn rect(x: f32, y: f32, w: f32, h: f32) {
		unsafe { nvg_rect(x, y, w, h); }
	}
	pub fn rounded_rect(x: f32, y: f32, w: f32, h: f32, r: f32) {
		unsafe { nvg_rounded_rect(x, y, w, h, r); }
	}
	pub fn rounded_rect_varying(x: f32, y: f32, w: f32, h: f32, rad_top_left: f32, rad_top_right: f32, rad_bottom_right: f32, rad_bottom_left: f32) {
		unsafe { nvg_rounded_rect_varying(x, y, w, h, rad_top_left, rad_top_right, rad_bottom_right, rad_bottom_left); }
	}
	pub fn ellipse(cx: f32, cy: f32, rx: f32, ry: f32) {
		unsafe { nvg_ellipse(cx, cy, rx, ry); }
	}
	pub fn circle(cx: f32, cy: f32, r: f32) {
		unsafe { nvg_circle(cx, cy, r); }
	}
	pub fn fill() {
		unsafe { nvg_fill(); }
	}
	pub fn stroke() {
		unsafe { nvg_stroke(); }
	}
	pub fn find_font(name: &str) -> i32 {
		unsafe { return nvg_find_font(crate::dora::from_string(name)); }
	}
	pub fn add_fallback_font_id(base_font: i32, fallback_font: i32) -> i32 {
		unsafe { return nvg_add_fallback_font_id(base_font, fallback_font); }
	}
	pub fn add_fallback_font(base_font: &str, fallback_font: &str) -> i32 {
		unsafe { return nvg_add_fallback_font(crate::dora::from_string(base_font), crate::dora::from_string(fallback_font)); }
	}
	pub fn font_size(size: f32) {
		unsafe { nvg_font_size(size); }
	}
	pub fn font_blur(blur: f32) {
		unsafe { nvg_font_blur(blur); }
	}
	pub fn text_letter_spacing(spacing: f32) {
		unsafe { nvg_text_letter_spacing(spacing); }
	}
	pub fn text_line_height(line_height: f32) {
		unsafe { nvg_text_line_height(line_height); }
	}
	pub(crate) fn _text_align(h_align: i32, v_align: i32) {
		unsafe { nvg__text_align(h_align, v_align); }
	}
	pub fn font_face_id(font: i32) {
		unsafe { nvg_font_face_id(font); }
	}
	pub fn font_face(font: &str) {
		unsafe { nvg_font_face(crate::dora::from_string(font)); }
	}
	pub fn dora_ssr() {
		unsafe { nvg_dora_ssr(); }
	}
	pub fn get_dora_ssr(scale: f32) -> crate::dora::Texture2D {
		unsafe { return crate::dora::Texture2D::from(nvg_get_dora_ssr(scale)).unwrap(); }
	}
}