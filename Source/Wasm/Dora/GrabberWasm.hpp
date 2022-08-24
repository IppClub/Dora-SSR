static int32_t grabber_type() {
	return DoraType<Grabber>();
}
static void grabber_set_camera(int64_t self, int64_t var) {
	r_cast<Grabber*>(self)->setCamera(r_cast<Camera*>(var));
}
static int64_t grabber_get_camera(int64_t self) {
	return from_object(r_cast<Grabber*>(self)->getCamera());
}
static void grabber_set_effect(int64_t self, int64_t var) {
	r_cast<Grabber*>(self)->setEffect(r_cast<SpriteEffect*>(var));
}
static int64_t grabber_get_effect(int64_t self) {
	return from_object(r_cast<Grabber*>(self)->getEffect());
}
static void grabber_set_blend_func(int64_t self, int64_t var) {
	r_cast<Grabber*>(self)->setBlendFunc(BlendFunc(s_cast<uint64_t>(var)));
}
static int64_t grabber_get_blend_func(int64_t self) {
	return s_cast<int64_t>(r_cast<Grabber*>(self)->getBlendFunc().toValue());
}
static void grabber_set_clear_color(int64_t self, int32_t var) {
	r_cast<Grabber*>(self)->setClearColor(Color(s_cast<uint32_t>(var)));
}
static int32_t grabber_get_clear_color(int64_t self) {
	return r_cast<Grabber*>(self)->getClearColor().toARGB();
}
static void grabber_set_pos(int64_t self, int32_t x, int32_t y, int64_t pos, float z) {
	r_cast<Grabber*>(self)->setPos(s_cast<int>(x), s_cast<int>(y), vec2_from(pos), z);
}
static int64_t grabber_get_pos(int64_t self, int32_t x, int32_t y) {
	return vec2_retain(r_cast<Grabber*>(self)->getPos(s_cast<int>(x), s_cast<int>(y)));
}
static void grabber_set_color(int64_t self, int32_t x, int32_t y, int32_t color) {
	r_cast<Grabber*>(self)->setColor(s_cast<int>(x), s_cast<int>(y), Color(s_cast<uint32_t>(color)));
}
static int32_t grabber_get_color(int64_t self, int32_t x, int32_t y) {
	return r_cast<Grabber*>(self)->getColor(s_cast<int>(x), s_cast<int>(y)).toARGB();
}
static void grabber_move_uv(int64_t self, int32_t x, int32_t y, int64_t offset) {
	r_cast<Grabber*>(self)->moveUV(s_cast<int>(x), s_cast<int>(y), vec2_from(offset));
}
static void linkGrabber(wasm3::module& mod) {
	mod.link_optional("*", "grabber_type", grabber_type);
	mod.link_optional("*", "grabber_set_camera", grabber_set_camera);
	mod.link_optional("*", "grabber_get_camera", grabber_get_camera);
	mod.link_optional("*", "grabber_set_effect", grabber_set_effect);
	mod.link_optional("*", "grabber_get_effect", grabber_get_effect);
	mod.link_optional("*", "grabber_set_blend_func", grabber_set_blend_func);
	mod.link_optional("*", "grabber_get_blend_func", grabber_get_blend_func);
	mod.link_optional("*", "grabber_set_clear_color", grabber_set_clear_color);
	mod.link_optional("*", "grabber_get_clear_color", grabber_get_clear_color);
	mod.link_optional("*", "grabber_set_pos", grabber_set_pos);
	mod.link_optional("*", "grabber_get_pos", grabber_get_pos);
	mod.link_optional("*", "grabber_set_color", grabber_set_color);
	mod.link_optional("*", "grabber_get_color", grabber_get_color);
	mod.link_optional("*", "grabber_move_uv", grabber_move_uv);
}