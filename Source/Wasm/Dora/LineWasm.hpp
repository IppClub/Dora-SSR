/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static int32_t line_type() {
	return DoraType<Line>();
}
static void line_set_depth_write(int64_t self, int32_t var) {
	r_cast<Line*>(self)->setDepthWrite(var != 0);
}
static int32_t line_is_depth_write(int64_t self) {
	return r_cast<Line*>(self)->isDepthWrite() ? 1 : 0;
}
static void line__set_blend_func(int64_t self, int64_t func) {
	r_cast<Line*>(self)->setBlendFunc(BlendFunc(s_cast<uint64_t>(func)));
}
static int64_t line__get_blend_func(int64_t self) {
	return s_cast<int64_t>(r_cast<Line*>(self)->getBlendFunc().toValue());
}
static void line_add(int64_t self, int64_t verts, int32_t color) {
	r_cast<Line*>(self)->add(from_vec2_vec(verts), Color(s_cast<uint32_t>(color)));
}
static void line_set(int64_t self, int64_t verts, int32_t color) {
	r_cast<Line*>(self)->set(from_vec2_vec(verts), Color(s_cast<uint32_t>(color)));
}
static void line_clear(int64_t self) {
	r_cast<Line*>(self)->clear();
}
static int64_t line_new() {
	return from_object(Line::create());
}
static int64_t line_with_vec_color(int64_t verts, int32_t color) {
	return from_object(Line::create(from_vec2_vec(verts), Color(s_cast<uint32_t>(color))));
}
static void linkLine(wasm3::module3& mod) {
	mod.link_optional("*", "line_type", line_type);
	mod.link_optional("*", "line_set_depth_write", line_set_depth_write);
	mod.link_optional("*", "line_is_depth_write", line_is_depth_write);
	mod.link_optional("*", "line__set_blend_func", line__set_blend_func);
	mod.link_optional("*", "line__get_blend_func", line__get_blend_func);
	mod.link_optional("*", "line_add", line_add);
	mod.link_optional("*", "line_set", line_set);
	mod.link_optional("*", "line_clear", line_clear);
	mod.link_optional("*", "line_new", line_new);
	mod.link_optional("*", "line_with_vec_color", line_with_vec_color);
}