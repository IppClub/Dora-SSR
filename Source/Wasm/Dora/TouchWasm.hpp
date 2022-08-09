static int32_t touch_type()
{
	return DoraType<Touch>();
}
static void touch_set_enabled(int64_t self, int32_t var)
{
	r_cast<Touch*>(self)->setEnabled(var != 0);
}
static int32_t touch_is_enabled(int64_t self)
{
	return r_cast<Touch*>(self)->isEnabled() ? 1 : 0;
}
static int32_t touch_is_from_mouse(int64_t self)
{
	return r_cast<Touch*>(self)->isMouse() ? 1 : 0;
}
static int32_t touch_is_first(int64_t self)
{
	return r_cast<Touch*>(self)->isFirst() ? 1 : 0;
}
static int32_t touch_get_id(int64_t self)
{
	return s_cast<int32_t>(r_cast<Touch*>(self)->getId());
}
static int64_t touch_get_delta(int64_t self)
{
	return vec2_retain(r_cast<Touch*>(self)->getDelta());
}
static int64_t touch_get_location(int64_t self)
{
	return vec2_retain(r_cast<Touch*>(self)->getLocation());
}
static int64_t touch_get_world_location(int64_t self)
{
	return vec2_retain(r_cast<Touch*>(self)->getWorldLocation());
}
static void linkTouch(wasm3::module& mod)
{
	mod.link_optional("*", "touch_type", touch_type);
	mod.link_optional("*", "touch_set_enabled", touch_set_enabled);
	mod.link_optional("*", "touch_is_enabled", touch_is_enabled);
	mod.link_optional("*", "touch_is_from_mouse", touch_is_from_mouse);
	mod.link_optional("*", "touch_is_first", touch_is_first);
	mod.link_optional("*", "touch_get_id", touch_get_id);
	mod.link_optional("*", "touch_get_delta", touch_get_delta);
	mod.link_optional("*", "touch_get_location", touch_get_location);
	mod.link_optional("*", "touch_get_world_location", touch_get_world_location);
}