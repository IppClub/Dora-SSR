/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t material3d_type() {
	return DoraType<Material3D>();
}
DORA_EXPORT void material3d_set_base_color(int64_t self, int32_t val) {
	r_cast<Material3D*>(self)->setBaseColor(Color(s_cast<uint32_t>(val)));
}
DORA_EXPORT int32_t material3d_get_base_color(int64_t self) {
	return r_cast<Material3D*>(self)->getBaseColor().toARGB();
}
DORA_EXPORT void material3d_set_emissive(int64_t self, int32_t val) {
	r_cast<Material3D*>(self)->setEmissive(Color3(s_cast<uint32_t>(val)));
}
DORA_EXPORT int32_t material3d_get_emissive(int64_t self) {
	return r_cast<Material3D*>(self)->getEmissive().toRGB();
}
DORA_EXPORT void material3d_set_metallic(int64_t self, float val) {
	r_cast<Material3D*>(self)->setMetallic(val);
}
DORA_EXPORT float material3d_get_metallic(int64_t self) {
	return r_cast<Material3D*>(self)->getMetallic();
}
DORA_EXPORT void material3d_set_roughness(int64_t self, float val) {
	r_cast<Material3D*>(self)->setRoughness(val);
}
DORA_EXPORT float material3d_get_roughness(int64_t self) {
	return r_cast<Material3D*>(self)->getRoughness();
}
DORA_EXPORT void material3d_set_alpha_mode(int64_t self, int32_t val) {
	r_cast<Material3D*>(self)->setAlphaMode(s_cast<MaterialAlphaMode3D>(val));
}
DORA_EXPORT int32_t material3d_get_alpha_mode(int64_t self) {
	return s_cast<int32_t>(r_cast<Material3D*>(self)->getAlphaMode());
}
DORA_EXPORT void material3d_set_alpha_cutoff(int64_t self, float val) {
	r_cast<Material3D*>(self)->setAlphaCutoff(val);
}
DORA_EXPORT float material3d_get_alpha_cutoff(int64_t self) {
	return r_cast<Material3D*>(self)->getAlphaCutoff();
}
DORA_EXPORT void material3d_set_base_color_texture(int64_t self, int64_t texture) {
	r_cast<Material3D*>(self)->setBaseColorTexture(r_cast<Texture2D*>(texture));
}
DORA_EXPORT void material3d_clear_base_color_texture(int64_t self) {
	r_cast<Material3D*>(self)->clearBaseColorTexture();
}
DORA_EXPORT void material3d_set_metallic_roughness_texture(int64_t self, int64_t texture) {
	r_cast<Material3D*>(self)->setMetallicRoughnessTexture(r_cast<Texture2D*>(texture));
}
DORA_EXPORT void material3d_clear_metallic_roughness_texture(int64_t self) {
	r_cast<Material3D*>(self)->clearMetallicRoughnessTexture();
}
DORA_EXPORT void material3d_set_normal_texture(int64_t self, int64_t texture) {
	r_cast<Material3D*>(self)->setNormalTexture(r_cast<Texture2D*>(texture));
}
DORA_EXPORT void material3d_clear_normal_texture(int64_t self) {
	r_cast<Material3D*>(self)->clearNormalTexture();
}
DORA_EXPORT void material3d_set_emissive_texture(int64_t self, int64_t texture) {
	r_cast<Material3D*>(self)->setEmissiveTexture(r_cast<Texture2D*>(texture));
}
DORA_EXPORT void material3d_clear_emissive_texture(int64_t self) {
	r_cast<Material3D*>(self)->clearEmissiveTexture();
}
DORA_EXPORT void material3d_set_occlusion_texture(int64_t self, int64_t texture) {
	r_cast<Material3D*>(self)->setOcclusionTexture(r_cast<Texture2D*>(texture));
}
DORA_EXPORT void material3d_clear_occlusion_texture(int64_t self) {
	r_cast<Material3D*>(self)->clearOcclusionTexture();
}
} // extern "C"

static void linkMaterial3D(wasm3::module3& mod) {
	mod.link_optional("*", "material3d_type", material3d_type);
	mod.link_optional("*", "material3d_set_base_color", material3d_set_base_color);
	mod.link_optional("*", "material3d_get_base_color", material3d_get_base_color);
	mod.link_optional("*", "material3d_set_emissive", material3d_set_emissive);
	mod.link_optional("*", "material3d_get_emissive", material3d_get_emissive);
	mod.link_optional("*", "material3d_set_metallic", material3d_set_metallic);
	mod.link_optional("*", "material3d_get_metallic", material3d_get_metallic);
	mod.link_optional("*", "material3d_set_roughness", material3d_set_roughness);
	mod.link_optional("*", "material3d_get_roughness", material3d_get_roughness);
	mod.link_optional("*", "material3d_set_alpha_mode", material3d_set_alpha_mode);
	mod.link_optional("*", "material3d_get_alpha_mode", material3d_get_alpha_mode);
	mod.link_optional("*", "material3d_set_alpha_cutoff", material3d_set_alpha_cutoff);
	mod.link_optional("*", "material3d_get_alpha_cutoff", material3d_get_alpha_cutoff);
	mod.link_optional("*", "material3d_set_base_color_texture", material3d_set_base_color_texture);
	mod.link_optional("*", "material3d_clear_base_color_texture", material3d_clear_base_color_texture);
	mod.link_optional("*", "material3d_set_metallic_roughness_texture", material3d_set_metallic_roughness_texture);
	mod.link_optional("*", "material3d_clear_metallic_roughness_texture", material3d_clear_metallic_roughness_texture);
	mod.link_optional("*", "material3d_set_normal_texture", material3d_set_normal_texture);
	mod.link_optional("*", "material3d_clear_normal_texture", material3d_clear_normal_texture);
	mod.link_optional("*", "material3d_set_emissive_texture", material3d_set_emissive_texture);
	mod.link_optional("*", "material3d_clear_emissive_texture", material3d_clear_emissive_texture);
	mod.link_optional("*", "material3d_set_occlusion_texture", material3d_set_occlusion_texture);
	mod.link_optional("*", "material3d_clear_occlusion_texture", material3d_clear_occlusion_texture);
}