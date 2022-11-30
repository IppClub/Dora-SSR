static int32_t buffer_type() {
	return DoraType<Buffer>();
}
static void buffer_resize(int64_t self, int32_t size) {
	r_cast<Buffer*>(self)->resize(s_cast<uint32_t>(size));
}
static void buffer_zero_memory(int64_t self) {
	r_cast<Buffer*>(self)->zeroMemory();
}
static int32_t buffer_size(int64_t self) {
	return s_cast<int32_t>(r_cast<Buffer*>(self)->size());
}
static void buffer_set_string(int64_t self, int64_t str) {
	r_cast<Buffer*>(self)->setString(*str_from(str));
}
static int64_t buffer_to_string(int64_t self) {
	return str_retain(r_cast<Buffer*>(self)->toString());
}
static void linkBuffer(wasm3::module& mod) {
	mod.link_optional("*", "buffer_type", buffer_type);
	mod.link_optional("*", "buffer_resize", buffer_resize);
	mod.link_optional("*", "buffer_zero_memory", buffer_zero_memory);
	mod.link_optional("*", "buffer_size", buffer_size);
	mod.link_optional("*", "buffer_set_string", buffer_set_string);
	mod.link_optional("*", "buffer_to_string", buffer_to_string);
}