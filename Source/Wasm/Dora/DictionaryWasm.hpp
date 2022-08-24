static int32_t dictionary_type() {
	return DoraType<Dictionary>();
}
static int32_t dictionary_get_count(int64_t self) {
	return s_cast<int32_t>(r_cast<Dictionary*>(self)->getCount());
}
static int64_t dictionary_get_keys(int64_t self) {
	return to_vec(r_cast<Dictionary*>(self)->getKeys());
}
static void dictionary_clear(int64_t self) {
	r_cast<Dictionary*>(self)->clear();
}
static int64_t dictionary_new() {
	return from_object(Dictionary::create());
}
static void linkDictionary(wasm3::module& mod) {
	mod.link_optional("*", "dictionary_type", dictionary_type);
	mod.link_optional("*", "dictionary_get_count", dictionary_get_count);
	mod.link_optional("*", "dictionary_get_keys", dictionary_get_keys);
	mod.link_optional("*", "dictionary_clear", dictionary_clear);
	mod.link_optional("*", "dictionary_new", dictionary_new);
}