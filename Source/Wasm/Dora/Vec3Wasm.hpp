/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT void vec3_release(int64_t raw) {
	delete r_cast<Vec3*>(raw);
}
DORA_EXPORT void vec3_set_x(int64_t self, float val) {
	r_cast<Vec3*>(self)->x = s_cast<float>(val);
}
DORA_EXPORT float vec3_get_x(int64_t self) {
	return r_cast<Vec3*>(self)->x;
}
DORA_EXPORT void vec3_set_y(int64_t self, float val) {
	r_cast<Vec3*>(self)->y = s_cast<float>(val);
}
DORA_EXPORT float vec3_get_y(int64_t self) {
	return r_cast<Vec3*>(self)->y;
}
DORA_EXPORT void vec3_set_z(int64_t self, float val) {
	r_cast<Vec3*>(self)->z = s_cast<float>(val);
}
DORA_EXPORT float vec3_get_z(int64_t self) {
	return r_cast<Vec3*>(self)->z;
}
DORA_EXPORT int64_t vec3_new(float x, float y, float z) {
	return Vec3_Retain(x, y, z);
}
DORA_EXPORT int64_t vec3_zero() {
	return Vec3_Retain(Vec3_GetZero());
}
} // extern "C"

static void linkVec3(wasm3::module3& mod) {
	mod.link_optional("*", "vec3_release", vec3_release);
	mod.link_optional("*", "vec3_set_x", vec3_set_x);
	mod.link_optional("*", "vec3_get_x", vec3_get_x);
	mod.link_optional("*", "vec3_set_y", vec3_set_y);
	mod.link_optional("*", "vec3_get_y", vec3_get_y);
	mod.link_optional("*", "vec3_set_z", vec3_set_z);
	mod.link_optional("*", "vec3_get_z", vec3_get_z);
	mod.link_optional("*", "vec3_new", vec3_new);
	mod.link_optional("*", "vec3_zero", vec3_zero);
}