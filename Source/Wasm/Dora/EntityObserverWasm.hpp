static int32_t observer_type()
{
	return DoraType<EntityObserver>();
}
static void linkEntityObserver(wasm3::module& mod)
{
	mod.link_optional("*", "observer_type", observer_type);
}