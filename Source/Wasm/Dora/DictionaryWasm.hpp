/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t dictionary_type() {
	return DoraType<Dictionary>();
}
int32_t dictionary_get_count(int64_t self) {
	return s_cast<int32_t>(r_cast<Dictionary*>(self)->getCount());
}
int64_t dictionary_get_keys(int64_t self) {
	return Vec_To(r_cast<Dictionary*>(self)->getKeys());
}
void dictionary_clear(int64_t self) {
	r_cast<Dictionary*>(self)->clear();
}
int64_t dictionary_new() {
	return Object_From(Dictionary::create());
}
} // extern "C"

static void linkDictionary(wasm3::module3& mod) {
	mod.link_optional("*", "dictionary_type", dictionary_type);
	mod.link_optional("*", "dictionary_get_count", dictionary_get_count);
	mod.link_optional("*", "dictionary_get_keys", dictionary_get_keys);
	mod.link_optional("*", "dictionary_clear", dictionary_clear);
	mod.link_optional("*", "dictionary_new", dictionary_new);
}