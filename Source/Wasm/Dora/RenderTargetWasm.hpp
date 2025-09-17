/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t rendertarget_type() {
	return DoraType<RenderTarget>();
}
DORA_EXPORT int32_t rendertarget_get_width(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderTarget*>(self)->getWidth());
}
DORA_EXPORT int32_t rendertarget_get_height(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderTarget*>(self)->getHeight());
}
DORA_EXPORT void rendertarget_set_camera(int64_t self, int64_t val) {
	r_cast<RenderTarget*>(self)->setCamera(r_cast<Camera*>(val));
}
DORA_EXPORT int64_t rendertarget_get_camera(int64_t self) {
	return Object_From(r_cast<RenderTarget*>(self)->getCamera());
}
DORA_EXPORT int64_t rendertarget_get_texture(int64_t self) {
	return Object_From(r_cast<RenderTarget*>(self)->getTexture());
}
DORA_EXPORT void rendertarget_render(int64_t self, int64_t target) {
	r_cast<RenderTarget*>(self)->render(r_cast<Node*>(target));
}
DORA_EXPORT void rendertarget_render_clear(int64_t self, int32_t color, float depth, int32_t stencil) {
	r_cast<RenderTarget*>(self)->renderWithClear(Color(s_cast<uint32_t>(color)), depth, s_cast<uint8_t>(stencil));
}
DORA_EXPORT void rendertarget_render_clear_with_target(int64_t self, int64_t target, int32_t color, float depth, int32_t stencil) {
	r_cast<RenderTarget*>(self)->renderWithClear(r_cast<Node*>(target), Color(s_cast<uint32_t>(color)), depth, s_cast<uint8_t>(stencil));
}
DORA_EXPORT void rendertarget_save_async(int64_t self, int64_t filename, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	r_cast<RenderTarget*>(self)->saveAsync(*Str_From(filename), [func0, args0, deref0](bool success) {
		args0->clear();
		args0->push(success);
		SharedWasmRuntime.invoke(func0);
	});
}
DORA_EXPORT int64_t rendertarget_new(int32_t width, int32_t height) {
	return Object_From(RenderTarget::create(s_cast<uint16_t>(width), s_cast<uint16_t>(height)));
}
} // extern "C"

static void linkRenderTarget(wasm3::module3& mod) {
	mod.link_optional("*", "rendertarget_type", rendertarget_type);
	mod.link_optional("*", "rendertarget_get_width", rendertarget_get_width);
	mod.link_optional("*", "rendertarget_get_height", rendertarget_get_height);
	mod.link_optional("*", "rendertarget_set_camera", rendertarget_set_camera);
	mod.link_optional("*", "rendertarget_get_camera", rendertarget_get_camera);
	mod.link_optional("*", "rendertarget_get_texture", rendertarget_get_texture);
	mod.link_optional("*", "rendertarget_render", rendertarget_render);
	mod.link_optional("*", "rendertarget_render_clear", rendertarget_render_clear);
	mod.link_optional("*", "rendertarget_render_clear_with_target", rendertarget_render_clear_with_target);
	mod.link_optional("*", "rendertarget_save_async", rendertarget_save_async);
	mod.link_optional("*", "rendertarget_new", rendertarget_new);
}