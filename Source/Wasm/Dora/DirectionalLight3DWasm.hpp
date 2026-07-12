/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t directionallight3d_type() {
	return DoraType<DirectionalLight3D>();
}
DORA_EXPORT void directionallight3d_set_color(int64_t self, int32_t val) {
	r_cast<DirectionalLight3D*>(self)->setColor(Color3(s_cast<uint32_t>(val)));
}
DORA_EXPORT int32_t directionallight3d_get_color(int64_t self) {
	return r_cast<DirectionalLight3D*>(self)->getColor().toRGB();
}
DORA_EXPORT void directionallight3d_set_intensity(int64_t self, float val) {
	r_cast<DirectionalLight3D*>(self)->setIntensity(val);
}
DORA_EXPORT float directionallight3d_get_intensity(int64_t self) {
	return r_cast<DirectionalLight3D*>(self)->getIntensity();
}
DORA_EXPORT void directionallight3d_set_cast_shadow(int64_t self, int32_t val) {
	r_cast<DirectionalLight3D*>(self)->setCastShadow(val != 0);
}
DORA_EXPORT int32_t directionallight3d_is_cast_shadow(int64_t self) {
	return r_cast<DirectionalLight3D*>(self)->isCastShadow() ? 1 : 0;
}
DORA_EXPORT void directionallight3d_set_shadow_bias(int64_t self, float val) {
	r_cast<DirectionalLight3D*>(self)->setShadowBias(val);
}
DORA_EXPORT float directionallight3d_get_shadow_bias(int64_t self) {
	return r_cast<DirectionalLight3D*>(self)->getShadowBias();
}
DORA_EXPORT void directionallight3d_set_shadow_normal_bias(int64_t self, float val) {
	r_cast<DirectionalLight3D*>(self)->setShadowNormalBias(val);
}
DORA_EXPORT float directionallight3d_get_shadow_normal_bias(int64_t self) {
	return r_cast<DirectionalLight3D*>(self)->getShadowNormalBias();
}
DORA_EXPORT int64_t directionallight3d_new() {
	return Object_From(DirectionalLight3D::create());
}
} // extern "C"

static void linkDirectionalLight3D(wasm3::module3& mod) {
	mod.link_optional("*", "directionallight3d_type", directionallight3d_type);
	mod.link_optional("*", "directionallight3d_set_color", directionallight3d_set_color);
	mod.link_optional("*", "directionallight3d_get_color", directionallight3d_get_color);
	mod.link_optional("*", "directionallight3d_set_intensity", directionallight3d_set_intensity);
	mod.link_optional("*", "directionallight3d_get_intensity", directionallight3d_get_intensity);
	mod.link_optional("*", "directionallight3d_set_cast_shadow", directionallight3d_set_cast_shadow);
	mod.link_optional("*", "directionallight3d_is_cast_shadow", directionallight3d_is_cast_shadow);
	mod.link_optional("*", "directionallight3d_set_shadow_bias", directionallight3d_set_shadow_bias);
	mod.link_optional("*", "directionallight3d_get_shadow_bias", directionallight3d_get_shadow_bias);
	mod.link_optional("*", "directionallight3d_set_shadow_normal_bias", directionallight3d_set_shadow_normal_bias);
	mod.link_optional("*", "directionallight3d_get_shadow_normal_bias", directionallight3d_get_shadow_normal_bias);
	mod.link_optional("*", "directionallight3d_new", directionallight3d_new);
}