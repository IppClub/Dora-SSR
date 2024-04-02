/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static int32_t camera2d_type() {
	return DoraType<Camera2D>();
}
static void camera2d_set_rotation(int64_t self, float var) {
	r_cast<Camera2D*>(self)->setRotation(var);
}
static float camera2d_get_rotation(int64_t self) {
	return r_cast<Camera2D*>(self)->getRotation();
}
static void camera2d_set_zoom(int64_t self, float var) {
	r_cast<Camera2D*>(self)->setZoom(var);
}
static float camera2d_get_zoom(int64_t self) {
	return r_cast<Camera2D*>(self)->getZoom();
}
static void camera2d_set_position(int64_t self, int64_t var) {
	r_cast<Camera2D*>(self)->setPosition(vec2_from(var));
}
static int64_t camera2d_get_position(int64_t self) {
	return vec2_retain(r_cast<Camera2D*>(self)->getPosition());
}
static int64_t camera2d_new(int64_t name) {
	return from_object(Camera2D::create(*str_from(name)));
}
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