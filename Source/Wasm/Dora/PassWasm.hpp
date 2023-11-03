static int32_t pass_type() {
	return DoraType<Pass>();
}
static void pass_set_grab_pass(int64_t self, int32_t var) {
	r_cast<Pass*>(self)->setGrabPass(var != 0);
}
static int32_t pass_is_grab_pass(int64_t self) {
	return r_cast<Pass*>(self)->isGrabPass() ? 1 : 0;
}
static void pass_set(int64_t self, int64_t name, float var) {
	r_cast<Pass*>(self)->set(*str_from(name), var);
}
static void pass_set_vec4(int64_t self, int64_t name, float var_1, float var_2, float var_3, float var_4) {
	r_cast<Pass*>(self)->set(*str_from(name), var_1, var_2, var_3, var_4);
}
static void pass_set_color(int64_t self, int64_t name, int32_t var) {
	r_cast<Pass*>(self)->set(*str_from(name), Color(s_cast<uint32_t>(var)));
}
static int64_t pass_new(int64_t vert_shader, int64_t frag_shader) {
	return from_object(Pass::create(*str_from(vert_shader), *str_from(frag_shader)));
}
static void linkPass(wasm3::module3& mod) {
	mod.link_optional("*", "pass_type", pass_type);
	mod.link_optional("*", "pass_set_grab_pass", pass_set_grab_pass);
	mod.link_optional("*", "pass_is_grab_pass", pass_is_grab_pass);
	mod.link_optional("*", "pass_set", pass_set);
	mod.link_optional("*", "pass_set_vec4", pass_set_vec4);
	mod.link_optional("*", "pass_set_color", pass_set_color);
	mod.link_optional("*", "pass_new", pass_new);
}