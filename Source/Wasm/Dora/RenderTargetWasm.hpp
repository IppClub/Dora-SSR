static int32_t rendertarget_type() {
	return DoraType<RenderTarget>();
}
static int32_t rendertarget_get_width(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderTarget*>(self)->getWidth());
}
static int32_t rendertarget_get_height(int64_t self) {
	return s_cast<int32_t>(r_cast<RenderTarget*>(self)->getHeight());
}
static void rendertarget_set_camera(int64_t self, int64_t var) {
	r_cast<RenderTarget*>(self)->setCamera(r_cast<Camera*>(var));
}
static int64_t rendertarget_get_camera(int64_t self) {
	return from_object(r_cast<RenderTarget*>(self)->getCamera());
}
static int64_t rendertarget_get_texture(int64_t self) {
	return from_object(r_cast<RenderTarget*>(self)->getTexture());
}
static void rendertarget_render(int64_t self, int64_t target) {
	r_cast<RenderTarget*>(self)->render(r_cast<Node*>(target));
}
static void rendertarget_render_clear(int64_t self, int32_t color, float depth, int32_t stencil) {
	r_cast<RenderTarget*>(self)->renderWithClear(Color(s_cast<uint32_t>(color)), depth, s_cast<uint8_t>(stencil));
}
static void rendertarget_render_clear_with_target(int64_t self, int64_t target, int32_t color, float depth, int32_t stencil) {
	r_cast<RenderTarget*>(self)->renderWithClear(r_cast<Node*>(target), Color(s_cast<uint32_t>(color)), depth, s_cast<uint8_t>(stencil));
}
static void rendertarget_save_async(int64_t self, int64_t filename, int32_t func) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	r_cast<RenderTarget*>(self)->saveAsync(*str_from(filename), [func, deref]() {
		SharedWasmRuntime.invoke(func);
	});
}
static int64_t rendertarget_new(int32_t width, int32_t height) {
	return from_object(RenderTarget::create(s_cast<uint16_t>(width), s_cast<uint16_t>(height)));
}
static void linkRenderTarget(wasm3::module& mod) {
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