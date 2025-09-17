/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t alignnode_type() {
	return DoraType<AlignNode>();
}
DORA_EXPORT void alignnode_css(int64_t self, int64_t style) {
	r_cast<AlignNode*>(self)->css(*Str_From(style));
}
DORA_EXPORT int64_t alignnode_new(int32_t is_window_root) {
	return Object_From(AlignNode::create(is_window_root != 0));
}
} // extern "C"

static void linkAlignNode(wasm3::module3& mod) {
	mod.link_optional("*", "alignnode_type", alignnode_type);
	mod.link_optional("*", "alignnode_css", alignnode_css);
	mod.link_optional("*", "alignnode_new", alignnode_new);
}