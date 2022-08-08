static int32_t action_type()
{
	return DoraType<Action>();
}
static float action_get_duration(int64_t self)
{
	return r_cast<Action*>(self)->getDuration();
}
static int32_t action_is_running(int64_t self)
{
	return r_cast<Action*>(self)->isRunning() ? 1 : 0;
}
static int32_t action_is_paused(int64_t self)
{
	return r_cast<Action*>(self)->isPaused() ? 1 : 0;
}
static void action_set_reversed(int64_t self, int32_t var)
{
	r_cast<Action*>(self)->setReversed(var != 0);
}
static int32_t action_is_reversed(int64_t self)
{
	return r_cast<Action*>(self)->isReversed() ? 1 : 0;
}
static void action_set_speed(int64_t self, float var)
{
	r_cast<Action*>(self)->setSpeed(var);
}
static float action_get_speed(int64_t self)
{
	return r_cast<Action*>(self)->getSpeed();
}
static void action_pause(int64_t self)
{
	r_cast<Action*>(self)->pause();
}
static void action_resume(int64_t self)
{
	r_cast<Action*>(self)->resume();
}
static void action_update_to(int64_t self, float eclapsed, int32_t reversed)
{
	r_cast<Action*>(self)->updateTo(eclapsed, reversed != 0);
}
static void linkAction(wasm3::module& mod)
{
	mod.link_optional("*", "action_type", action_type);
	mod.link_optional("*", "action_get_duration", action_get_duration);
	mod.link_optional("*", "action_is_running", action_is_running);
	mod.link_optional("*", "action_is_paused", action_is_paused);
	mod.link_optional("*", "action_set_reversed", action_set_reversed);
	mod.link_optional("*", "action_is_reversed", action_is_reversed);
	mod.link_optional("*", "action_set_speed", action_set_speed);
	mod.link_optional("*", "action_get_speed", action_get_speed);
	mod.link_optional("*", "action_pause", action_pause);
	mod.link_optional("*", "action_resume", action_resume);
	mod.link_optional("*", "action_update_to", action_update_to);
}