/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static int32_t vgnode_type() {
	return DoraType<VGNode>();
}
static int64_t vgnode_get_surface(int64_t self) {
	return from_object(r_cast<VGNode*>(self)->getSurface());
}
static void vgnode_render(int64_t self, int32_t func) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	r_cast<VGNode*>(self)->render([func, deref]() {
		SharedWasmRuntime.invoke(func);
	});
}
static int64_t vgnode_new(float width, float height, float scale, int32_t edge_aa) {
	return from_object(VGNode::create(width, height, scale, s_cast<int>(edge_aa)));
}
static void linkVGNode(wasm3::module3& mod) {
	mod.link_optional("*", "vgnode_type", vgnode_type);
	mod.link_optional("*", "vgnode_get_surface", vgnode_get_surface);
	mod.link_optional("*", "vgnode_render", vgnode_render);
	mod.link_optional("*", "vgnode_new", vgnode_new);
}