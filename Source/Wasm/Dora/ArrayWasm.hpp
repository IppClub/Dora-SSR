/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t array_type() {
	return DoraType<Array>();
}
DORA_EXPORT int64_t array_get_count(int64_t self) {
	return s_cast<int64_t>(r_cast<Array*>(self)->getCount());
}
DORA_EXPORT int32_t array_is_empty(int64_t self) {
	return r_cast<Array*>(self)->isEmpty() ? 1 : 0;
}
DORA_EXPORT void array_add_range(int64_t self, int64_t other) {
	r_cast<Array*>(self)->addRange(r_cast<Array*>(other));
}
DORA_EXPORT void array_remove_from(int64_t self, int64_t other) {
	r_cast<Array*>(self)->removeFrom(r_cast<Array*>(other));
}
DORA_EXPORT void array_clear(int64_t self) {
	r_cast<Array*>(self)->clear();
}
DORA_EXPORT void array_reverse(int64_t self) {
	r_cast<Array*>(self)->reverse();
}
DORA_EXPORT void array_shrink(int64_t self) {
	r_cast<Array*>(self)->shrink();
}
DORA_EXPORT void array_swap(int64_t self, int32_t index_a, int32_t index_b) {
	r_cast<Array*>(self)->swap(s_cast<int>(index_a), s_cast<int>(index_b));
}
DORA_EXPORT int32_t array_remove_at(int64_t self, int32_t index) {
	return r_cast<Array*>(self)->removeAt(s_cast<int>(index)) ? 1 : 0;
}
DORA_EXPORT int32_t array_fast_remove_at(int64_t self, int32_t index) {
	return r_cast<Array*>(self)->fastRemoveAt(s_cast<int>(index)) ? 1 : 0;
}
DORA_EXPORT int64_t array_new() {
	return Object_From(Array::create());
}
} // extern "C"

static void linkArray(wasm3::module3& mod) {
	mod.link_optional("*", "array_type", array_type);
	mod.link_optional("*", "array_get_count", array_get_count);
	mod.link_optional("*", "array_is_empty", array_is_empty);
	mod.link_optional("*", "array_add_range", array_add_range);
	mod.link_optional("*", "array_remove_from", array_remove_from);
	mod.link_optional("*", "array_clear", array_clear);
	mod.link_optional("*", "array_reverse", array_reverse);
	mod.link_optional("*", "array_shrink", array_shrink);
	mod.link_optional("*", "array_swap", array_swap);
	mod.link_optional("*", "array_remove_at", array_remove_at);
	mod.link_optional("*", "array_fast_remove_at", array_fast_remove_at);
	mod.link_optional("*", "array_new", array_new);
}