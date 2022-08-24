static int32_t effect_type() {
	return DoraType<Effect>();
}
static void effect_add(int64_t self, int64_t pass) {
	r_cast<Effect*>(self)->add(r_cast<Pass*>(pass));
}
static int64_t effect_get(int64_t self, int64_t index) {
	return from_object(effect_get_pass(r_cast<Effect*>(self), s_cast<int64_t>(index)));
}
static void effect_clear(int64_t self) {
	r_cast<Effect*>(self)->clear();
}
static int64_t effect_new(int64_t vert_shader, int64_t frag_shader) {
	return from_object(Effect::create(*str_from(vert_shader), *str_from(frag_shader)));
}
static void linkEffect(wasm3::module& mod) {
	mod.link_optional("*", "effect_type", effect_type);
	mod.link_optional("*", "effect_add", effect_add);
	mod.link_optional("*", "effect_get", effect_get);
	mod.link_optional("*", "effect_clear", effect_clear);
	mod.link_optional("*", "effect_new", effect_new);
}