/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t surface3d_type() {
	return DoraType<Surface3D>();
}
DORA_EXPORT void surface3d_set_content(int64_t self, int64_t val) {
	r_cast<Surface3D*>(self)->setContent(r_cast<Node*>(val));
}
DORA_EXPORT int64_t surface3d_get_content(int64_t self) {
	return Object_From(r_cast<Surface3D*>(self)->getContent());
}
DORA_EXPORT void surface3d_set_size(int64_t self, int64_t val) {
	r_cast<Surface3D*>(self)->setSize(Size_From(val));
}
DORA_EXPORT int64_t surface3d_get_size(int64_t self) {
	return Size_Retain(r_cast<Surface3D*>(self)->getSize());
}
DORA_EXPORT void surface3d_set_pixel_size(int64_t self, int64_t val) {
	r_cast<Surface3D*>(self)->setPixelSize(Size_From(val));
}
DORA_EXPORT int64_t surface3d_get_pixel_size(int64_t self) {
	return Size_Retain(r_cast<Surface3D*>(self)->getPixelSize());
}
DORA_EXPORT void surface3d_set_billboard(int64_t self, int32_t val) {
	r_cast<Surface3D*>(self)->setBillboard(s_cast<Billboard>(val));
}
DORA_EXPORT int32_t surface3d_get_billboard(int64_t self) {
	return s_cast<int32_t>(r_cast<Surface3D*>(self)->getBillboard());
}
DORA_EXPORT int32_t surface3d_is_using_texture(int64_t self) {
	return r_cast<Surface3D*>(self)->isUsingTexture() ? 1 : 0;
}
DORA_EXPORT int64_t surface3d_new(int64_t content, int64_t size, int64_t pixel_size) {
	return Object_From(Surface3D::create(r_cast<Node*>(content), Size_From(size), Size_From(pixel_size)));
}
} // extern "C"

static void linkSurface3D(wasm3::module3& mod) {
	mod.link_optional("*", "surface3d_type", surface3d_type);
	mod.link_optional("*", "surface3d_set_content", surface3d_set_content);
	mod.link_optional("*", "surface3d_get_content", surface3d_get_content);
	mod.link_optional("*", "surface3d_set_size", surface3d_set_size);
	mod.link_optional("*", "surface3d_get_size", surface3d_get_size);
	mod.link_optional("*", "surface3d_set_pixel_size", surface3d_set_pixel_size);
	mod.link_optional("*", "surface3d_get_pixel_size", surface3d_get_pixel_size);
	mod.link_optional("*", "surface3d_set_billboard", surface3d_set_billboard);
	mod.link_optional("*", "surface3d_get_billboard", surface3d_get_billboard);
	mod.link_optional("*", "surface3d_is_using_texture", surface3d_is_using_texture);
	mod.link_optional("*", "surface3d_new", surface3d_new);
}