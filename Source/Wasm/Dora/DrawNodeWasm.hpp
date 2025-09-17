/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t drawnode_type() {
	return DoraType<DrawNode>();
}
DORA_EXPORT void drawnode_set_depth_write(int64_t self, int32_t val) {
	r_cast<DrawNode*>(self)->setDepthWrite(val != 0);
}
DORA_EXPORT int32_t drawnode_is_depth_write(int64_t self) {
	return r_cast<DrawNode*>(self)->isDepthWrite() ? 1 : 0;
}
DORA_EXPORT void drawnode_set_blend_func(int64_t self, int64_t val) {
	r_cast<DrawNode*>(self)->setBlendFunc(BlendFunc(s_cast<uint64_t>(val)));
}
DORA_EXPORT int64_t drawnode_get_blend_func(int64_t self) {
	return s_cast<int64_t>(r_cast<DrawNode*>(self)->getBlendFunc().toValue());
}
DORA_EXPORT void drawnode_draw_dot(int64_t self, int64_t pos, float radius, int32_t color) {
	r_cast<DrawNode*>(self)->drawDot(Vec2_From(pos), radius, Color(s_cast<uint32_t>(color)));
}
DORA_EXPORT void drawnode_draw_segment(int64_t self, int64_t from, int64_t to, float radius, int32_t color) {
	r_cast<DrawNode*>(self)->drawSegment(Vec2_From(from), Vec2_From(to), radius, Color(s_cast<uint32_t>(color)));
}
DORA_EXPORT void drawnode_draw_polygon(int64_t self, int64_t verts, int32_t fill_color, float border_width, int32_t border_color) {
	r_cast<DrawNode*>(self)->drawPolygon(Vec_FromVec2(verts), Color(s_cast<uint32_t>(fill_color)), border_width, Color(s_cast<uint32_t>(border_color)));
}
DORA_EXPORT void drawnode_draw_vertices(int64_t self, int64_t verts) {
	r_cast<DrawNode*>(self)->drawVertices(Vec_FromVertexColor(verts));
}
DORA_EXPORT void drawnode_clear(int64_t self) {
	r_cast<DrawNode*>(self)->clear();
}
DORA_EXPORT int64_t drawnode_new() {
	return Object_From(DrawNode::create());
}
} // extern "C"

static void linkDrawNode(wasm3::module3& mod) {
	mod.link_optional("*", "drawnode_type", drawnode_type);
	mod.link_optional("*", "drawnode_set_depth_write", drawnode_set_depth_write);
	mod.link_optional("*", "drawnode_is_depth_write", drawnode_is_depth_write);
	mod.link_optional("*", "drawnode_set_blend_func", drawnode_set_blend_func);
	mod.link_optional("*", "drawnode_get_blend_func", drawnode_get_blend_func);
	mod.link_optional("*", "drawnode_draw_dot", drawnode_draw_dot);
	mod.link_optional("*", "drawnode_draw_segment", drawnode_draw_segment);
	mod.link_optional("*", "drawnode_draw_polygon", drawnode_draw_polygon);
	mod.link_optional("*", "drawnode_draw_vertices", drawnode_draw_vertices);
	mod.link_optional("*", "drawnode_clear", drawnode_clear);
	mod.link_optional("*", "drawnode_new", drawnode_new);
}