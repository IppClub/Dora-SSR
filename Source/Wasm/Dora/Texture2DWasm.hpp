/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t texture2d_type() {
	return DoraType<Texture2D>();
}
DORA_EXPORT int32_t texture2d_get_width(int64_t self) {
	return s_cast<int32_t>(r_cast<Texture2D*>(self)->getWidth());
}
DORA_EXPORT int32_t texture2d_get_height(int64_t self) {
	return s_cast<int32_t>(r_cast<Texture2D*>(self)->getHeight());
}
DORA_EXPORT int64_t texture2d_with_file(int64_t filename) {
	return Object_From(Texture2D_Create(*Str_From(filename)));
}
} // extern "C"

static void linkTexture2D(wasm3::module3& mod) {
	mod.link_optional("*", "texture2d_type", texture2d_type);
	mod.link_optional("*", "texture2d_get_width", texture2d_get_width);
	mod.link_optional("*", "texture2d_get_height", texture2d_get_height);
	mod.link_optional("*", "texture2d_with_file", texture2d_with_file);
}