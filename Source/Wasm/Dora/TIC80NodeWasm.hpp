/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t tic80node_type() {
	return DoraType<TIC80Node>();
}
DORA_EXPORT int64_t tic80node_new(int64_t cart_file) {
	return Object_From(TIC80Node::create(*Str_From(cart_file)));
}
DORA_EXPORT int64_t tic80node_with_code(int64_t resource_cart_file, int64_t code_file) {
	return Object_From(TIC80Node::create(*Str_From(resource_cart_file), *Str_From(code_file)));
}
DORA_EXPORT int64_t tic80node_code_from_cart(int64_t cart_file) {
	return Str_Retain(TIC80Node::codeFromCart(*Str_From(cart_file)));
}
DORA_EXPORT int32_t tic80node_merge_tic(int64_t output_file, int64_t resource_cart_file, int64_t code_file) {
	return TIC80Node::mergeTic(*Str_From(output_file), *Str_From(resource_cart_file), *Str_From(code_file)) ? 1 : 0;
}
DORA_EXPORT int32_t tic80node_merge_png(int64_t output_file, int64_t cover_png_file, int64_t resource_cart_file, int64_t code_file) {
	return TIC80Node::mergePng(*Str_From(output_file), *Str_From(cover_png_file), *Str_From(resource_cart_file), *Str_From(code_file)) ? 1 : 0;
}
} // extern "C"

static void linkTIC80Node(wasm3::module3& mod) {
	mod.link_optional("*", "tic80node_type", tic80node_type);
	mod.link_optional("*", "tic80node_new", tic80node_new);
	mod.link_optional("*", "tic80node_with_code", tic80node_with_code);
	mod.link_optional("*", "tic80node_code_from_cart", tic80node_code_from_cart);
	mod.link_optional("*", "tic80node_merge_tic", tic80node_merge_tic);
	mod.link_optional("*", "tic80node_merge_png", tic80node_merge_png);
}