static int32_t texture2d_type() {
	return DoraType<Texture2D>();
}
static int32_t texture2d_get_width(int64_t self) {
	return s_cast<int32_t>(r_cast<Texture2D*>(self)->getWidth());
}
static int32_t texture2d_get_height(int64_t self) {
	return s_cast<int32_t>(r_cast<Texture2D*>(self)->getHeight());
}
static int64_t texture2d_with_file(int64_t filename) {
	return from_object(texture_2d_create(*str_from(filename)));
}
static void linkTexture2D(wasm3::module3& mod) {
	mod.link_optional("*", "texture2d_type", texture2d_type);
	mod.link_optional("*", "texture2d_get_width", texture2d_get_width);
	mod.link_optional("*", "texture2d_get_height", texture2d_get_height);
	mod.link_optional("*", "texture2d_with_file", texture2d_with_file);
}