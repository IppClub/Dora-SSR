static int32_t spriteeffect_type() {
	return DoraType<SpriteEffect>();
}
static int64_t spriteeffect_new(int64_t vert_shader, int64_t frag_shader) {
	return from_object(SpriteEffect::create(*str_from(vert_shader), *str_from(frag_shader)));
}
static void linkSpriteEffect(wasm3::module& mod) {
	mod.link_optional("*", "spriteeffect_type", spriteeffect_type);
	mod.link_optional("*", "spriteeffect_new", spriteeffect_new);
}