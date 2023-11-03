static int32_t playable_type() {
	return DoraType<Playable>();
}
static void playable_set_look(int64_t self, int64_t var) {
	r_cast<Playable*>(self)->setLook(*str_from(var));
}
static int64_t playable_get_look(int64_t self) {
	return str_retain(r_cast<Playable*>(self)->getLook());
}
static void playable_set_speed(int64_t self, float var) {
	r_cast<Playable*>(self)->setSpeed(var);
}
static float playable_get_speed(int64_t self) {
	return r_cast<Playable*>(self)->getSpeed();
}
static void playable_set_recovery(int64_t self, float var) {
	r_cast<Playable*>(self)->setRecovery(var);
}
static float playable_get_recovery(int64_t self) {
	return r_cast<Playable*>(self)->getRecovery();
}
static void playable_set_fliped(int64_t self, int32_t var) {
	r_cast<Playable*>(self)->setFliped(var != 0);
}
static int32_t playable_is_fliped(int64_t self) {
	return r_cast<Playable*>(self)->isFliped() ? 1 : 0;
}
static int64_t playable_get_current(int64_t self) {
	return str_retain(r_cast<Playable*>(self)->getCurrent());
}
static int64_t playable_get_last_completed(int64_t self) {
	return str_retain(r_cast<Playable*>(self)->getLastCompleted());
}
static int64_t playable_get_key(int64_t self, int64_t name) {
	return vec2_retain(r_cast<Playable*>(self)->getKeyPoint(*str_from(name)));
}
static float playable_play(int64_t self, int64_t name, int32_t looping) {
	return r_cast<Playable*>(self)->play(*str_from(name), looping != 0);
}
static void playable_stop(int64_t self) {
	r_cast<Playable*>(self)->stop();
}
static void playable_set_slot(int64_t self, int64_t name, int64_t item) {
	r_cast<Playable*>(self)->setSlot(*str_from(name), r_cast<Node*>(item));
}
static int64_t playable_get_slot(int64_t self, int64_t name) {
	return from_object(r_cast<Playable*>(self)->getSlot(*str_from(name)));
}
static int64_t playable_new(int64_t filename) {
	return from_object(Playable::create(*str_from(filename)));
}
static void linkPlayable(wasm3::module3& mod) {
	mod.link_optional("*", "playable_type", playable_type);
	mod.link_optional("*", "playable_set_look", playable_set_look);
	mod.link_optional("*", "playable_get_look", playable_get_look);
	mod.link_optional("*", "playable_set_speed", playable_set_speed);
	mod.link_optional("*", "playable_get_speed", playable_get_speed);
	mod.link_optional("*", "playable_set_recovery", playable_set_recovery);
	mod.link_optional("*", "playable_get_recovery", playable_get_recovery);
	mod.link_optional("*", "playable_set_fliped", playable_set_fliped);
	mod.link_optional("*", "playable_is_fliped", playable_is_fliped);
	mod.link_optional("*", "playable_get_current", playable_get_current);
	mod.link_optional("*", "playable_get_last_completed", playable_get_last_completed);
	mod.link_optional("*", "playable_get_key", playable_get_key);
	mod.link_optional("*", "playable_play", playable_play);
	mod.link_optional("*", "playable_stop", playable_stop);
	mod.link_optional("*", "playable_set_slot", playable_set_slot);
	mod.link_optional("*", "playable_get_slot", playable_get_slot);
	mod.link_optional("*", "playable_new", playable_new);
}