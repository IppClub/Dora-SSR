/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t camera2d_type() {
	return DoraType<Camera2D>();
}
DORA_EXPORT void camera2d_set_rotation(int64_t self, float val) {
	r_cast<Camera2D*>(self)->setRotation(val);
}
DORA_EXPORT float camera2d_get_rotation(int64_t self) {
	return r_cast<Camera2D*>(self)->getRotation();
}
DORA_EXPORT void camera2d_set_zoom(int64_t self, float val) {
	r_cast<Camera2D*>(self)->setZoom(val);
}
DORA_EXPORT float camera2d_get_zoom(int64_t self) {
	return r_cast<Camera2D*>(self)->getZoom();
}
DORA_EXPORT void camera2d_set_position(int64_t self, int64_t val) {
	r_cast<Camera2D*>(self)->setPosition(Vec2_From(val));
}
DORA_EXPORT int64_t camera2d_get_position(int64_t self) {
	return Vec2_Retain(r_cast<Camera2D*>(self)->getPosition());
}
DORA_EXPORT int64_t camera2d_new(int64_t name) {
	return Object_From(Camera2D::create(*Str_From(name)));
}
} // extern "C"

static void linkCamera2D(wasm3::module3& mod) {
	mod.link_optional("*", "camera2d_type", camera2d_type);
	mod.link_optional("*", "camera2d_set_rotation", camera2d_set_rotation);
	mod.link_optional("*", "camera2d_get_rotation", camera2d_get_rotation);
	mod.link_optional("*", "camera2d_set_zoom", camera2d_set_zoom);
	mod.link_optional("*", "camera2d_get_zoom", camera2d_get_zoom);
	mod.link_optional("*", "camera2d_set_position", camera2d_set_position);
	mod.link_optional("*", "camera2d_get_position", camera2d_get_position);
	mod.link_optional("*", "camera2d_new", camera2d_new);
}