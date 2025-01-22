/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
void vertexcolor_release(int64_t raw) {
	delete r_cast<VertexColor*>(raw);
}
void vertexcolor_set_vertex(int64_t self, int64_t val) {
	r_cast<VertexColor*>(self)->vertex = Vec2_From(val);
}
int64_t vertexcolor_get_vertex(int64_t self) {
	return Vec2_Retain(r_cast<VertexColor*>(self)->vertex);
}
void vertexcolor_set_color(int64_t self, int32_t val) {
	r_cast<VertexColor*>(self)->color = Color(s_cast<uint32_t>(val));
}
int32_t vertexcolor_get_color(int64_t self) {
	return r_cast<VertexColor*>(self)->color.toARGB();
}
int64_t vertexcolor_new(int64_t vec, int32_t color) {
	return r_cast<int64_t>(new VertexColor{Vec2_From(vec), Color(s_cast<uint32_t>(color))});
}
} // extern "C"

static void linkVertexColor(wasm3::module3& mod) {
	mod.link_optional("*", "vertexcolor_release", vertexcolor_release);
	mod.link_optional("*", "vertexcolor_set_vertex", vertexcolor_set_vertex);
	mod.link_optional("*", "vertexcolor_get_vertex", vertexcolor_get_vertex);
	mod.link_optional("*", "vertexcolor_set_color", vertexcolor_set_color);
	mod.link_optional("*", "vertexcolor_get_color", vertexcolor_get_color);
	mod.link_optional("*", "vertexcolor_new", vertexcolor_new);
}