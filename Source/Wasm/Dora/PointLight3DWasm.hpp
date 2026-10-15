/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t pointlight3d_type() {
	return DoraType<PointLight3D>();
}
DORA_EXPORT void pointlight3d_set_color(int64_t self, int32_t val) {
	r_cast<PointLight3D*>(self)->setColor(Color3(s_cast<uint32_t>(val)));
}
DORA_EXPORT int32_t pointlight3d_get_color(int64_t self) {
	return r_cast<PointLight3D*>(self)->getColor().toRGB();
}
DORA_EXPORT void pointlight3d_set_intensity(int64_t self, float val) {
	r_cast<PointLight3D*>(self)->setIntensity(val);
}
DORA_EXPORT float pointlight3d_get_intensity(int64_t self) {
	return r_cast<PointLight3D*>(self)->getIntensity();
}
DORA_EXPORT void pointlight3d_set_range(int64_t self, float val) {
	r_cast<PointLight3D*>(self)->setRange(val);
}
DORA_EXPORT float pointlight3d_get_range(int64_t self) {
	return r_cast<PointLight3D*>(self)->getRange();
}
DORA_EXPORT int64_t pointlight3d_new() {
	return Object_From(PointLight3D::create());
}
} // extern "C"

static void linkPointLight3D(wasm3::module3& mod) {
	mod.link_optional("*", "pointlight3d_type", pointlight3d_type);
	mod.link_optional("*", "pointlight3d_set_color", pointlight3d_set_color);
	mod.link_optional("*", "pointlight3d_get_color", pointlight3d_get_color);
	mod.link_optional("*", "pointlight3d_set_intensity", pointlight3d_set_intensity);
	mod.link_optional("*", "pointlight3d_get_intensity", pointlight3d_get_intensity);
	mod.link_optional("*", "pointlight3d_set_range", pointlight3d_set_range);
	mod.link_optional("*", "pointlight3d_get_range", pointlight3d_get_range);
	mod.link_optional("*", "pointlight3d_new", pointlight3d_new);
}