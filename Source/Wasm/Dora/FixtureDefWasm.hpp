static int32_t fixturedef_type() {
	return DoraType<FixtureDef>();
}
static void linkFixtureDef(wasm3::module& mod) {
	mod.link_optional("*", "fixturedef_type", fixturedef_type);
}