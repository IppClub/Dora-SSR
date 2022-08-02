static int32_t entity_type()
{
	return DoraType<Entity>();
}
static int32_t entity_get_count(int64_t self)
{
	return s_cast<int32_t>(Entity::getCount());
}
static int32_t entity_get_index(int64_t self)
{
	return s_cast<int32_t>(r_cast<Entity*>(self)->getIndex());
}
static void entity_clear()
{
	Entity::clear();
}
static void entity_remove(int64_t self, int64_t key)
{
	r_cast<Entity*>(self)->remove(*str_from(key));
}
static void entity_destroy(int64_t self)
{
	r_cast<Entity*>(self)->destroy();
}
static int64_t entity_new()
{
	return from_object(Entity::create());
}
static void linkEntity(wasm3::module& mod)
{
	mod.link_optional("*", "entity_type", entity_type);
	mod.link_optional("*", "entity_get_count", entity_get_count);
	mod.link_optional("*", "entity_get_index", entity_get_index);
	mod.link_optional("*", "entity_clear", entity_clear);
	mod.link_optional("*", "entity_remove", entity_remove);
	mod.link_optional("*", "entity_destroy", entity_destroy);
	mod.link_optional("*", "entity_new", entity_new);
}