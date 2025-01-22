/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t buffer_type() {
	return DoraType<Buffer>();
}
void buffer_set_text(int64_t self, int64_t val) {
	r_cast<Buffer*>(self)->setText(*Str_From(val));
}
int64_t buffer_get_text(int64_t self) {
	return Str_Retain(r_cast<Buffer*>(self)->getText());
}
void buffer_resize(int64_t self, int32_t size) {
	r_cast<Buffer*>(self)->resize(s_cast<uint32_t>(size));
}
void buffer_zero_memory(int64_t self) {
	r_cast<Buffer*>(self)->zeroMemory();
}
int32_t buffer_get_size(int64_t self) {
	return s_cast<int32_t>(r_cast<Buffer*>(self)->size());
}
} // extern "C"

static void linkBuffer(wasm3::module3& mod) {
	mod.link_optional("*", "buffer_type", buffer_type);
	mod.link_optional("*", "buffer_set_text", buffer_set_text);
	mod.link_optional("*", "buffer_get_text", buffer_get_text);
	mod.link_optional("*", "buffer_resize", buffer_resize);
	mod.link_optional("*", "buffer_zero_memory", buffer_zero_memory);
	mod.link_optional("*", "buffer_get_size", buffer_get_size);
}