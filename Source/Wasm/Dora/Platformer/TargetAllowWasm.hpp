static void platformer_targetallow_release(int64_t raw)
{
	delete r_cast<Platformer::TargetAllow*>(raw);
}
static void platformer_targetallow_set_terrain_allowed(int64_t self, int32_t var)
{
	r_cast<Platformer::TargetAllow*>(self)->setTerrainAllowed(var != 0);
}
static int32_t platformer_targetallow_is_terrain_allowed(int64_t self)
{
	return r_cast<Platformer::TargetAllow*>(self)->isTerrainAllowed() ? 1 : 0;
}
static void platformer_targetallow_allow(int64_t self, int32_t relation, int32_t allow)
{
	r_cast<Platformer::TargetAllow*>(self)->allow(s_cast<Platformer::Relation>(relation), allow != 0);
}
static int32_t platformer_targetallow_is_allow(int64_t self, int32_t relation)
{
	return r_cast<Platformer::TargetAllow*>(self)->isAllow(s_cast<Platformer::Relation>(relation)) ? 1 : 0;
}
static int32_t platformer_targetallow_to_value(int64_t self)
{
	return s_cast<int32_t>(r_cast<Platformer::TargetAllow*>(self)->toValue());
}
static int64_t platformer_targetallow_new()
{
	return r_cast<int64_t>(new Platformer::TargetAllow{});
}
static int64_t platformer_targetallow_with_value(int32_t value)
{
	return r_cast<int64_t>(new Platformer::TargetAllow{s_cast<uint32_t>(value)});
}
static void linkPlatformerTargetAllow(wasm3::module& mod)
{
	mod.link_optional("*", "platformer_targetallow_release", platformer_targetallow_release);
	mod.link_optional("*", "platformer_targetallow_set_terrain_allowed", platformer_targetallow_set_terrain_allowed);
	mod.link_optional("*", "platformer_targetallow_is_terrain_allowed", platformer_targetallow_is_terrain_allowed);
	mod.link_optional("*", "platformer_targetallow_allow", platformer_targetallow_allow);
	mod.link_optional("*", "platformer_targetallow_is_allow", platformer_targetallow_is_allow);
	mod.link_optional("*", "platformer_targetallow_to_value", platformer_targetallow_to_value);
	mod.link_optional("*", "platformer_targetallow_new", platformer_targetallow_new);
	mod.link_optional("*", "platformer_targetallow_with_value", platformer_targetallow_with_value);
}