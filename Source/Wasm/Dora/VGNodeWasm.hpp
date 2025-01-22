/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t vgnode_type() {
	return DoraType<VGNode>();
}
int64_t vgnode_get_surface(int64_t self) {
	return Object_From(r_cast<VGNode*>(self)->getSurface());
}
void vgnode_render(int64_t self, int32_t func0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	r_cast<VGNode*>(self)->render([func0, deref0]() {
		SharedWasmRuntime.invoke(func0);
	});
}
int64_t vgnode_new(float width, float height, float scale, int32_t edge_aa) {
	return Object_From(VGNode::create(width, height, scale, s_cast<int>(edge_aa)));
}
} // extern "C"

static void linkVGNode(wasm3::module3& mod) {
	mod.link_optional("*", "vgnode_type", vgnode_type);
	mod.link_optional("*", "vgnode_get_surface", vgnode_get_surface);
	mod.link_optional("*", "vgnode_render", vgnode_render);
	mod.link_optional("*", "vgnode_new", vgnode_new);
}