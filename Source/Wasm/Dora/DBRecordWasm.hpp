/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
void dbrecord_release(int64_t raw) {
	delete r_cast<DBRecord*>(raw);
}
int32_t dbrecord_is_valid(int64_t self) {
	return r_cast<DBRecord*>(self)->isValid() ? 1 : 0;
}
int32_t dbrecord_read(int64_t self, int64_t record) {
	return r_cast<DBRecord*>(self)->read(r_cast<Array*>(record)) ? 1 : 0;
}
} // extern "C"

static void linkDBRecord(wasm3::module3& mod) {
	mod.link_optional("*", "dbrecord_release", dbrecord_release);
	mod.link_optional("*", "dbrecord_is_valid", dbrecord_is_valid);
	mod.link_optional("*", "dbrecord_read", dbrecord_read);
}