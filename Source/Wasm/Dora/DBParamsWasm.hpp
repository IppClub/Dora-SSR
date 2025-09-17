/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT void dbparams_release(int64_t raw) {
	delete r_cast<DBParams*>(raw);
}
DORA_EXPORT void dbparams_add(int64_t self, int64_t params) {
	r_cast<DBParams*>(self)->add(r_cast<Array*>(params));
}
DORA_EXPORT int64_t dbparams_new() {
	return r_cast<int64_t>(new DBParams{});
}
} // extern "C"

static void linkDBParams(wasm3::module3& mod) {
	mod.link_optional("*", "dbparams_release", dbparams_release);
	mod.link_optional("*", "dbparams_add", dbparams_add);
	mod.link_optional("*", "dbparams_new", dbparams_new);
}