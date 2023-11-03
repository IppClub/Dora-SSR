static int32_t line_type() {
	return DoraType<Line>();
}
static void line_set_depth_write(int64_t self, int32_t var) {
	r_cast<Line*>(self)->setDepthWrite(var != 0);
}
static int32_t line_is_depth_write(int64_t self) {
	return r_cast<Line*>(self)->isDepthWrite() ? 1 : 0;
}
static void line_set_blend_func(int64_t self, int64_t var) {
	r_cast<Line*>(self)->setBlendFunc(BlendFunc(s_cast<uint64_t>(var)));
}
static int64_t line_get_blend_func(int64_t self) {
	return s_cast<int64_t>(r_cast<Line*>(self)->getBlendFunc().toValue());
}
static void line_add(int64_t self, int64_t verts, int32_t color) {
	r_cast<Line*>(self)->add(from_vec2_vec(verts), Color(s_cast<uint32_t>(color)));
}
static void line_set(int64_t self, int64_t verts, int32_t color) {
	r_cast<Line*>(self)->set(from_vec2_vec(verts), Color(s_cast<uint32_t>(color)));
}
static void line_clear(int64_t self) {
	r_cast<Line*>(self)->clear();
}
static int64_t line_new() {
	return from_object(Line::create());
}
static int64_t line_with_vec_color(int64_t verts, int32_t color) {
	return from_object(Line::create(from_vec2_vec(verts), Color(s_cast<uint32_t>(color))));
}
static void linkLine(wasm3::module3& mod) {
	mod.link_optional("*", "line_type", line_type);
	mod.link_optional("*", "line_set_depth_write", line_set_depth_write);
	mod.link_optional("*", "line_is_depth_write", line_is_depth_write);
	mod.link_optional("*", "line_set_blend_func", line_set_blend_func);
	mod.link_optional("*", "line_get_blend_func", line_get_blend_func);
	mod.link_optional("*", "line_add", line_add);
	mod.link_optional("*", "line_set", line_set);
	mod.link_optional("*", "line_clear", line_clear);
	mod.link_optional("*", "line_new", line_new);
	mod.link_optional("*", "line_with_vec_color", line_with_vec_color);
}