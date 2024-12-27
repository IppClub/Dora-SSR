/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t clipnode_type() {
	return DoraType<ClipNode>();
}
void clipnode_set_stencil(int64_t self, int64_t val) {
	r_cast<ClipNode*>(self)->setStencil(r_cast<Node*>(val));
}
int64_t clipnode_get_stencil(int64_t self) {
	return Object_From(r_cast<ClipNode*>(self)->getStencil());
}
void clipnode_set_alpha_threshold(int64_t self, float val) {
	r_cast<ClipNode*>(self)->setAlphaThreshold(val);
}
float clipnode_get_alpha_threshold(int64_t self) {
	return r_cast<ClipNode*>(self)->getAlphaThreshold();
}
void clipnode_set_inverted(int64_t self, int32_t val) {
	r_cast<ClipNode*>(self)->setInverted(val != 0);
}
int32_t clipnode_is_inverted(int64_t self) {
	return r_cast<ClipNode*>(self)->isInverted() ? 1 : 0;
}
int64_t clipnode_new(int64_t stencil) {
	return Object_From(ClipNode::create(r_cast<Node*>(stencil)));
}
} // extern "C"

static void linkClipNode(wasm3::module3& mod) {
	mod.link_optional("*", "clipnode_type", clipnode_type);
	mod.link_optional("*", "clipnode_set_stencil", clipnode_set_stencil);
	mod.link_optional("*", "clipnode_get_stencil", clipnode_get_stencil);
	mod.link_optional("*", "clipnode_set_alpha_threshold", clipnode_set_alpha_threshold);
	mod.link_optional("*", "clipnode_get_alpha_threshold", clipnode_get_alpha_threshold);
	mod.link_optional("*", "clipnode_set_inverted", clipnode_set_inverted);
	mod.link_optional("*", "clipnode_is_inverted", clipnode_is_inverted);
	mod.link_optional("*", "clipnode_new", clipnode_new);
}