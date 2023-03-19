static void dbparams_release(int64_t raw) {
	delete r_cast<DBParams*>(raw);
}
static void dbparams_add(int64_t self, int64_t params) {
	r_cast<DBParams*>(self)->add(r_cast<Array*>(params));
}
static void linkDBParams(wasm3::module& mod) {
	mod.link_optional("*", "dbparams_release", dbparams_release);
	mod.link_optional("*", "dbparams_add", dbparams_add);
}