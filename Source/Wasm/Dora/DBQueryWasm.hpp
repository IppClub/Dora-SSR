/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
void dbquery_release(int64_t raw) {
	delete r_cast<DBQuery*>(raw);
}
void dbquery_add_with_params(int64_t self, int64_t sql, int64_t params) {
	r_cast<DBQuery*>(self)->addWithParams(*Str_From(sql), *r_cast<DBParams*>(params));
}
void dbquery_add(int64_t self, int64_t sql) {
	r_cast<DBQuery*>(self)->add(*Str_From(sql));
}
int64_t dbquery_new() {
	return r_cast<int64_t>(new DBQuery{});
}
} // extern "C"

static void linkDBQuery(wasm3::module3& mod) {
	mod.link_optional("*", "dbquery_release", dbquery_release);
	mod.link_optional("*", "dbquery_add_with_params", dbquery_add_with_params);
	mod.link_optional("*", "dbquery_add", dbquery_add);
	mod.link_optional("*", "dbquery_new", dbquery_new);
}