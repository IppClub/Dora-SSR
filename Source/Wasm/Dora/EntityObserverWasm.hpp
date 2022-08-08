static int32_t observer_type()
{
	return DoraType<EntityObserver>();
}
static int64_t entityobserver_new(int32_t event, int64_t components)
{
	return from_object(EntityObserver::create(s_cast<int>(event), from_str_vec(components)));
}
static void linkEntityObserver(wasm3::module& mod)
{
	mod.link_optional("*", "observer_type", observer_type);
	mod.link_optional("*", "entityobserver_new", entityobserver_new);
}