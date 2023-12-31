static int32_t action_type() {
	return DoraType<Action>();
}
static float action_get_duration(int64_t self) {
	return r_cast<Action*>(self)->getDuration();
}
static int32_t action_is_running(int64_t self) {
	return r_cast<Action*>(self)->isRunning() ? 1 : 0;
}
static int32_t action_is_paused(int64_t self) {
	return r_cast<Action*>(self)->isPaused() ? 1 : 0;
}
static void action_set_reversed(int64_t self, int32_t var) {
	r_cast<Action*>(self)->setReversed(var != 0);
}
static int32_t action_is_reversed(int64_t self) {
	return r_cast<Action*>(self)->isReversed() ? 1 : 0;
}
static void action_set_speed(int64_t self, float var) {
	r_cast<Action*>(self)->setSpeed(var);
}
static float action_get_speed(int64_t self) {
	return r_cast<Action*>(self)->getSpeed();
}
static void action_pause(int64_t self) {
	r_cast<Action*>(self)->pause();
}
static void action_resume(int64_t self) {
	r_cast<Action*>(self)->resume();
}
static void action_update_to(int64_t self, float elapsed, int32_t reversed) {
	r_cast<Action*>(self)->updateTo(elapsed, reversed != 0);
}
static int64_t action_prop(float duration, float start, float stop, int32_t prop, int32_t easing) {
	return r_cast<int64_t>(new ActionDef{action_def_prop(duration, start, stop, s_cast<Property::Enum>(prop), s_cast<Ease::Enum>(easing))});
}
static int64_t action_tint(float duration, int32_t start, int32_t stop, int32_t easing) {
	return r_cast<int64_t>(new ActionDef{action_def_tint(duration, Color3(s_cast<uint32_t>(start)), Color3(s_cast<uint32_t>(stop)), s_cast<Ease::Enum>(easing))});
}
static int64_t action_roll(float duration, float start, float stop, int32_t easing) {
	return r_cast<int64_t>(new ActionDef{action_def_roll(duration, start, stop, s_cast<Ease::Enum>(easing))});
}
static int64_t action_spawn(int64_t defs) {
	return r_cast<int64_t>(new ActionDef{action_def_spawn(from_action_def_vec(defs))});
}
static int64_t action_sequence(int64_t defs) {
	return r_cast<int64_t>(new ActionDef{action_def_sequence(from_action_def_vec(defs))});
}
static int64_t action_delay(float duration) {
	return r_cast<int64_t>(new ActionDef{action_def_delay(duration)});
}
static int64_t action_show() {
	return r_cast<int64_t>(new ActionDef{action_def_show()});
}
static int64_t action_hide() {
	return r_cast<int64_t>(new ActionDef{action_def_hide()});
}
static int64_t action_event(int64_t event_name, int64_t msg) {
	return r_cast<int64_t>(new ActionDef{action_def_emit(*str_from(event_name), *str_from(msg))});
}
static int64_t action_move_to(float duration, int64_t start, int64_t stop, int32_t easing) {
	return r_cast<int64_t>(new ActionDef{action_def_move(duration, vec2_from(start), vec2_from(stop), s_cast<Ease::Enum>(easing))});
}
static int64_t action_scale(float duration, float start, float stop, int32_t easing) {
	return r_cast<int64_t>(new ActionDef{action_def_scale(duration, start, stop, s_cast<Ease::Enum>(easing))});
}
static void linkAction(wasm3::module3& mod) {
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
	mod.link_optional("*", "action_prop", action_prop);
	mod.link_optional("*", "action_tint", action_tint);
	mod.link_optional("*", "action_roll", action_roll);
	mod.link_optional("*", "action_spawn", action_spawn);
	mod.link_optional("*", "action_sequence", action_sequence);
	mod.link_optional("*", "action_delay", action_delay);
	mod.link_optional("*", "action_show", action_show);
	mod.link_optional("*", "action_hide", action_hide);
	mod.link_optional("*", "action_event", action_event);
	mod.link_optional("*", "action_move_to", action_move_to);
	mod.link_optional("*", "action_scale", action_scale);
}