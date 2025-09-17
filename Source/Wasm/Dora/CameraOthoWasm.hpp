/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t cameraotho_type() {
	return DoraType<CameraOtho>();
}
DORA_EXPORT void cameraotho_set_position(int64_t self, int64_t val) {
	r_cast<CameraOtho*>(self)->setPosition(Vec2_From(val));
}
DORA_EXPORT int64_t cameraotho_get_position(int64_t self) {
	return Vec2_Retain(r_cast<CameraOtho*>(self)->getPosition());
}
DORA_EXPORT int64_t cameraotho_new(int64_t name) {
	return Object_From(CameraOtho::create(*Str_From(name)));
}
} // extern "C"

static void linkCameraOtho(wasm3::module3& mod) {
	mod.link_optional("*", "cameraotho_type", cameraotho_type);
	mod.link_optional("*", "cameraotho_set_position", cameraotho_set_position);
	mod.link_optional("*", "cameraotho_get_position", cameraotho_get_position);
	mod.link_optional("*", "cameraotho_new", cameraotho_new);
}