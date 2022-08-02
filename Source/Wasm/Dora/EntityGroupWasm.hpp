static int32_t group_type()
{
	return DoraType<EntityGroup>();
}
static int32_t entity_group_get_count(int64_t self)
{
	return s_cast<int32_t>(r_cast<EntityGroup*>(self)->getCount());
}
static int64_t entity_group_new(int64_t components)
{
	return from_object(EntityGroup::create(from_str_vec(components)));
}
static void linkEntityGroup(wasm3::module& mod)
{
	mod.link_optional("*", "group_type", group_type);
	mod.link_optional("*", "entity_group_get_count", entity_group_get_count);
	mod.link_optional("*", "entity_group_new", entity_group_new);
}