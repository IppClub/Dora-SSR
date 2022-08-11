static void platformer_unitaction_set_reaction(int64_t self, float var)
{
	r_cast<Platformer::UnitAction*>(self)->reaction = s_cast<float>(var);
}
static float platformer_unitaction_get_reaction(int64_t self)
{
	return r_cast<Platformer::UnitAction*>(self)->reaction;
}
static void platformer_unitaction_set_recovery(int64_t self, float var)
{
	r_cast<Platformer::UnitAction*>(self)->recovery = s_cast<float>(var);
}
static float platformer_unitaction_get_recovery(int64_t self)
{
	return r_cast<Platformer::UnitAction*>(self)->recovery;
}
static int64_t platformer_unitaction_get_name(int64_t self)
{
	return str_retain(r_cast<Platformer::UnitAction*>(self)->getName());
}
static int32_t platformer_unitaction_is_doing(int64_t self)
{
	return r_cast<Platformer::UnitAction*>(self)->isDoing() ? 1 : 0;
}
static int64_t platformer_unitaction_get_owner(int64_t self)
{
	return from_object(r_cast<Platformer::UnitAction*>(self)->getOwner());
}
static float platformer_unitaction_get_eclapsed_time(int64_t self)
{
	return r_cast<Platformer::UnitAction*>(self)->getEclapsedTime();
}
static void platformer_unitaction_clear()
{
	Platformer::UnitAction::clear();
}
static void linkPlatformerUnitAction(wasm3::module& mod)
{
	mod.link_optional("*", "platformer_unitaction_set_reaction", platformer_unitaction_set_reaction);
	mod.link_optional("*", "platformer_unitaction_get_reaction", platformer_unitaction_get_reaction);
	mod.link_optional("*", "platformer_unitaction_set_recovery", platformer_unitaction_set_recovery);
	mod.link_optional("*", "platformer_unitaction_get_recovery", platformer_unitaction_get_recovery);
	mod.link_optional("*", "platformer_unitaction_get_name", platformer_unitaction_get_name);
	mod.link_optional("*", "platformer_unitaction_is_doing", platformer_unitaction_is_doing);
	mod.link_optional("*", "platformer_unitaction_get_owner", platformer_unitaction_get_owner);
	mod.link_optional("*", "platformer_unitaction_get_eclapsed_time", platformer_unitaction_get_eclapsed_time);
	mod.link_optional("*", "platformer_unitaction_clear", platformer_unitaction_clear);
}