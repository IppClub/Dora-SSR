static void actiondef_release(int64_t raw) {
	delete r_cast<ActionDef*>(raw);
}
static void linkActionDef(wasm3::module& mod) {
	mod.link_optional("*", "actiondef_release", actiondef_release);
}