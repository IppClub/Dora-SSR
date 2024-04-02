/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static int32_t buffer_type() {
	return DoraType<Buffer>();
}
static void buffer_resize(int64_t self, int32_t size) {
	r_cast<Buffer*>(self)->resize(s_cast<uint32_t>(size));
}
static void buffer_zero_memory(int64_t self) {
	r_cast<Buffer*>(self)->zeroMemory();
}
static int32_t buffer_size(int64_t self) {
	return s_cast<int32_t>(r_cast<Buffer*>(self)->size());
}
static void buffer_set_string(int64_t self, int64_t str) {
	r_cast<Buffer*>(self)->setString(*str_from(str));
}
static int64_t buffer_to_string(int64_t self) {
	return str_retain(r_cast<Buffer*>(self)->toString());
}
static void linkBuffer(wasm3::module3& mod) {
	mod.link_optional("*", "buffer_type", buffer_type);
	mod.link_optional("*", "buffer_resize", buffer_resize);
	mod.link_optional("*", "buffer_zero_memory", buffer_zero_memory);
	mod.link_optional("*", "buffer_size", buffer_size);
	mod.link_optional("*", "buffer_set_string", buffer_set_string);
	mod.link_optional("*", "buffer_to_string", buffer_to_string);
}