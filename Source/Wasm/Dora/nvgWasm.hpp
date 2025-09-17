/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT void nvg_save() {
	nvg::Save();
}
DORA_EXPORT void nvg_restore() {
	nvg::Restore();
}
DORA_EXPORT void nvg_reset() {
	nvg::Reset();
}
DORA_EXPORT int32_t nvg__create_image(int32_t w, int32_t h, int64_t filename, int32_t image_flags) {
	return s_cast<int32_t>(nvg::CreateImage(s_cast<int>(w), s_cast<int>(h), *Str_From(filename), s_cast<int>(image_flags)));
}
DORA_EXPORT int32_t nvg_create_font(int64_t name) {
	return s_cast<int32_t>(nvg::CreateFont(*Str_From(name)));
}
DORA_EXPORT float nvg_text_bounds(float x, float y, int64_t text, int64_t bounds) {
	return nvg::TextBounds(x, y, *Str_From(text), *r_cast<Rect*>(bounds));
}
DORA_EXPORT int64_t nvg_text_box_bounds(float x, float y, float break_row_width, int64_t text) {
	return r_cast<int64_t>(new Rect{nvg::TextBoxBounds(x, y, break_row_width, *Str_From(text))});
}
DORA_EXPORT float nvg_text(float x, float y, int64_t text) {
	return nvg::Text(x, y, *Str_From(text));
}
DORA_EXPORT void nvg_text_box(float x, float y, float break_row_width, int64_t text) {
	nvg::TextBox(x, y, break_row_width, *Str_From(text));
}
DORA_EXPORT void nvg_stroke_color(int32_t color) {
	nvg::StrokeColor(Color(s_cast<uint32_t>(color)));
}
DORA_EXPORT void nvg_stroke_paint(int64_t paint) {
	nvg::StrokePaint(*r_cast<NVGpaint*>(paint));
}
DORA_EXPORT void nvg_fill_color(int32_t color) {
	nvg::FillColor(Color(s_cast<uint32_t>(color)));
}
DORA_EXPORT void nvg_fill_paint(int64_t paint) {
	nvg::FillPaint(*r_cast<NVGpaint*>(paint));
}
DORA_EXPORT void nvg_miter_limit(float limit) {
	nvg::MiterLimit(limit);
}
DORA_EXPORT void nvg_stroke_width(float size) {
	nvg::StrokeWidth(size);
}
DORA_EXPORT void nvg__line_cap(int32_t cap) {
	nvg::LineCap(s_cast<int>(cap));
}
DORA_EXPORT void nvg__line_join(int32_t join) {
	nvg::LineJoin(s_cast<int>(join));
}
DORA_EXPORT void nvg_global_alpha(float alpha) {
	nvg::GlobalAlpha(alpha);
}
DORA_EXPORT void nvg_reset_transform() {
	nvg::ResetTransform();
}
DORA_EXPORT void nvg_apply_transform(int64_t node) {
	nvg::ApplyTransform(r_cast<Node*>(node));
}
DORA_EXPORT void nvg_translate(float x, float y) {
	nvg::Translate(x, y);
}
DORA_EXPORT void nvg_rotate(float angle) {
	nvg::Rotate(angle);
}
DORA_EXPORT void nvg_skew_x(float angle) {
	nvg::SkewX(angle);
}
DORA_EXPORT void nvg_skew_y(float angle) {
	nvg::SkewY(angle);
}
DORA_EXPORT void nvg_scale(float x, float y) {
	nvg::Scale(x, y);
}
DORA_EXPORT int64_t nvg_image_size(int32_t image) {
	return Size_Retain(nvg::ImageSize(s_cast<int>(image)));
}
DORA_EXPORT void nvg_delete_image(int32_t image) {
	nvg::DeleteImage(s_cast<int>(image));
}
DORA_EXPORT int64_t nvg_linear_gradient(float sx, float sy, float ex, float ey, int32_t icol, int32_t ocol) {
	return r_cast<int64_t>(new NVGpaint{nvg::LinearGradient(sx, sy, ex, ey, Color(s_cast<uint32_t>(icol)), Color(s_cast<uint32_t>(ocol)))});
}
DORA_EXPORT int64_t nvg_box_gradient(float x, float y, float w, float h, float r, float f, int32_t icol, int32_t ocol) {
	return r_cast<int64_t>(new NVGpaint{nvg::BoxGradient(x, y, w, h, r, f, Color(s_cast<uint32_t>(icol)), Color(s_cast<uint32_t>(ocol)))});
}
DORA_EXPORT int64_t nvg_radial_gradient(float cx, float cy, float inr, float outr, int32_t icol, int32_t ocol) {
	return r_cast<int64_t>(new NVGpaint{nvg::RadialGradient(cx, cy, inr, outr, Color(s_cast<uint32_t>(icol)), Color(s_cast<uint32_t>(ocol)))});
}
DORA_EXPORT int64_t nvg_image_pattern(float ox, float oy, float ex, float ey, float angle, int32_t image, float alpha) {
	return r_cast<int64_t>(new NVGpaint{nvg::ImagePattern(ox, oy, ex, ey, angle, s_cast<int>(image), alpha)});
}
DORA_EXPORT void nvg_scissor(float x, float y, float w, float h) {
	nvg::Scissor(x, y, w, h);
}
DORA_EXPORT void nvg_intersect_scissor(float x, float y, float w, float h) {
	nvg::IntersectScissor(x, y, w, h);
}
DORA_EXPORT void nvg_reset_scissor() {
	nvg::ResetScissor();
}
DORA_EXPORT void nvg_begin_path() {
	nvg::BeginPath();
}
DORA_EXPORT void nvg_move_to(float x, float y) {
	nvg::MoveTo(x, y);
}
DORA_EXPORT void nvg_line_to(float x, float y) {
	nvg::LineTo(x, y);
}
DORA_EXPORT void nvg_bezier_to(float c_1x, float c_1y, float c_2x, float c_2y, float x, float y) {
	nvg::BezierTo(c_1x, c_1y, c_2x, c_2y, x, y);
}
DORA_EXPORT void nvg_quad_to(float cx, float cy, float x, float y) {
	nvg::QuadTo(cx, cy, x, y);
}
DORA_EXPORT void nvg_arc_to(float x_1, float y_1, float x_2, float y_2, float radius) {
	nvg::ArcTo(x_1, y_1, x_2, y_2, radius);
}
DORA_EXPORT void nvg_close_path() {
	nvg::ClosePath();
}
DORA_EXPORT void nvg__path_winding(int32_t dir) {
	nvg::PathWinding(s_cast<int>(dir));
}
DORA_EXPORT void nvg__arc(float cx, float cy, float r, float a_0, float a_1, int32_t dir) {
	nvg::Arc(cx, cy, r, a_0, a_1, s_cast<int>(dir));
}
DORA_EXPORT void nvg_rect(float x, float y, float w, float h) {
	nvg::Rectangle(x, y, w, h);
}
DORA_EXPORT void nvg_rounded_rect(float x, float y, float w, float h, float r) {
	nvg::RoundedRect(x, y, w, h, r);
}
DORA_EXPORT void nvg_rounded_rect_varying(float x, float y, float w, float h, float rad_top_left, float rad_top_right, float rad_bottom_right, float rad_bottom_left) {
	nvg::RoundedRectVarying(x, y, w, h, rad_top_left, rad_top_right, rad_bottom_right, rad_bottom_left);
}
DORA_EXPORT void nvg_ellipse(float cx, float cy, float rx, float ry) {
	nvg::Ellipse(cx, cy, rx, ry);
}
DORA_EXPORT void nvg_circle(float cx, float cy, float r) {
	nvg::Circle(cx, cy, r);
}
DORA_EXPORT void nvg_fill() {
	nvg::Fill();
}
DORA_EXPORT void nvg_stroke() {
	nvg::Stroke();
}
DORA_EXPORT int32_t nvg_find_font(int64_t name) {
	return s_cast<int32_t>(nvg::FindFont(*Str_From(name)));
}
DORA_EXPORT int32_t nvg_add_fallback_font_id(int32_t base_font, int32_t fallback_font) {
	return s_cast<int32_t>(nvg::AddFallbackFontId(s_cast<int>(base_font), s_cast<int>(fallback_font)));
}
DORA_EXPORT int32_t nvg_add_fallback_font(int64_t base_font, int64_t fallback_font) {
	return s_cast<int32_t>(nvg::AddFallbackFont(*Str_From(base_font), *Str_From(fallback_font)));
}
DORA_EXPORT void nvg_font_size(float size) {
	nvg::FontSize(size);
}
DORA_EXPORT void nvg_font_blur(float blur) {
	nvg::FontBlur(blur);
}
DORA_EXPORT void nvg_text_letter_spacing(float spacing) {
	nvg::TextLetterSpacing(spacing);
}
DORA_EXPORT void nvg_text_line_height(float line_height) {
	nvg::TextLineHeight(line_height);
}
DORA_EXPORT void nvg__text_align(int32_t h_align, int32_t v_align) {
	nvg::TextAlign(s_cast<int>(h_align), s_cast<int>(v_align));
}
DORA_EXPORT void nvg_font_face_id(int32_t font) {
	nvg::FontFaceId(s_cast<int>(font));
}
DORA_EXPORT void nvg_font_face(int64_t font) {
	nvg::FontFace(*Str_From(font));
}
DORA_EXPORT void nvg_dora_ssr() {
	nvg::DoraSSR();
}
DORA_EXPORT int64_t nvg_get_dora_ssr(float scale) {
	return Object_From(nvg::GetDoraSSR(scale));
}
} // extern "C"

static void linknvg(wasm3::module3& mod) {
	mod.link_optional("*", "nvg_save", nvg_save);
	mod.link_optional("*", "nvg_restore", nvg_restore);
	mod.link_optional("*", "nvg_reset", nvg_reset);
	mod.link_optional("*", "nvg__create_image", nvg__create_image);
	mod.link_optional("*", "nvg_create_font", nvg_create_font);
	mod.link_optional("*", "nvg_text_bounds", nvg_text_bounds);
	mod.link_optional("*", "nvg_text_box_bounds", nvg_text_box_bounds);
	mod.link_optional("*", "nvg_text", nvg_text);
	mod.link_optional("*", "nvg_text_box", nvg_text_box);
	mod.link_optional("*", "nvg_stroke_color", nvg_stroke_color);
	mod.link_optional("*", "nvg_stroke_paint", nvg_stroke_paint);
	mod.link_optional("*", "nvg_fill_color", nvg_fill_color);
	mod.link_optional("*", "nvg_fill_paint", nvg_fill_paint);
	mod.link_optional("*", "nvg_miter_limit", nvg_miter_limit);
	mod.link_optional("*", "nvg_stroke_width", nvg_stroke_width);
	mod.link_optional("*", "nvg__line_cap", nvg__line_cap);
	mod.link_optional("*", "nvg__line_join", nvg__line_join);
	mod.link_optional("*", "nvg_global_alpha", nvg_global_alpha);
	mod.link_optional("*", "nvg_reset_transform", nvg_reset_transform);
	mod.link_optional("*", "nvg_apply_transform", nvg_apply_transform);
	mod.link_optional("*", "nvg_translate", nvg_translate);
	mod.link_optional("*", "nvg_rotate", nvg_rotate);
	mod.link_optional("*", "nvg_skew_x", nvg_skew_x);
	mod.link_optional("*", "nvg_skew_y", nvg_skew_y);
	mod.link_optional("*", "nvg_scale", nvg_scale);
	mod.link_optional("*", "nvg_image_size", nvg_image_size);
	mod.link_optional("*", "nvg_delete_image", nvg_delete_image);
	mod.link_optional("*", "nvg_linear_gradient", nvg_linear_gradient);
	mod.link_optional("*", "nvg_box_gradient", nvg_box_gradient);
	mod.link_optional("*", "nvg_radial_gradient", nvg_radial_gradient);
	mod.link_optional("*", "nvg_image_pattern", nvg_image_pattern);
	mod.link_optional("*", "nvg_scissor", nvg_scissor);
	mod.link_optional("*", "nvg_intersect_scissor", nvg_intersect_scissor);
	mod.link_optional("*", "nvg_reset_scissor", nvg_reset_scissor);
	mod.link_optional("*", "nvg_begin_path", nvg_begin_path);
	mod.link_optional("*", "nvg_move_to", nvg_move_to);
	mod.link_optional("*", "nvg_line_to", nvg_line_to);
	mod.link_optional("*", "nvg_bezier_to", nvg_bezier_to);
	mod.link_optional("*", "nvg_quad_to", nvg_quad_to);
	mod.link_optional("*", "nvg_arc_to", nvg_arc_to);
	mod.link_optional("*", "nvg_close_path", nvg_close_path);
	mod.link_optional("*", "nvg__path_winding", nvg__path_winding);
	mod.link_optional("*", "nvg__arc", nvg__arc);
	mod.link_optional("*", "nvg_rect", nvg_rect);
	mod.link_optional("*", "nvg_rounded_rect", nvg_rounded_rect);
	mod.link_optional("*", "nvg_rounded_rect_varying", nvg_rounded_rect_varying);
	mod.link_optional("*", "nvg_ellipse", nvg_ellipse);
	mod.link_optional("*", "nvg_circle", nvg_circle);
	mod.link_optional("*", "nvg_fill", nvg_fill);
	mod.link_optional("*", "nvg_stroke", nvg_stroke);
	mod.link_optional("*", "nvg_find_font", nvg_find_font);
	mod.link_optional("*", "nvg_add_fallback_font_id", nvg_add_fallback_font_id);
	mod.link_optional("*", "nvg_add_fallback_font", nvg_add_fallback_font);
	mod.link_optional("*", "nvg_font_size", nvg_font_size);
	mod.link_optional("*", "nvg_font_blur", nvg_font_blur);
	mod.link_optional("*", "nvg_text_letter_spacing", nvg_text_letter_spacing);
	mod.link_optional("*", "nvg_text_line_height", nvg_text_line_height);
	mod.link_optional("*", "nvg__text_align", nvg__text_align);
	mod.link_optional("*", "nvg_font_face_id", nvg_font_face_id);
	mod.link_optional("*", "nvg_font_face", nvg_font_face);
	mod.link_optional("*", "nvg_dora_ssr", nvg_dora_ssr);
	mod.link_optional("*", "nvg_get_dora_ssr", nvg_get_dora_ssr);
}