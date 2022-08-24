static int32_t motorjoint_type() {
	return DoraType<MotorJoint>();
}
static void motorjoint_set_enabled(int64_t self, int32_t var) {
	r_cast<MotorJoint*>(self)->setEnabled(var != 0);
}
static int32_t motorjoint_is_enabled(int64_t self) {
	return r_cast<MotorJoint*>(self)->isEnabled() ? 1 : 0;
}
static void motorjoint_set_force(int64_t self, float var) {
	r_cast<MotorJoint*>(self)->setForce(var);
}
static float motorjoint_get_force(int64_t self) {
	return r_cast<MotorJoint*>(self)->getForce();
}
static void motorjoint_set_speed(int64_t self, float var) {
	r_cast<MotorJoint*>(self)->setSpeed(var);
}
static float motorjoint_get_speed(int64_t self) {
	return r_cast<MotorJoint*>(self)->getSpeed();
}
static void linkMotorJoint(wasm3::module& mod) {
	mod.link_optional("*", "motorjoint_type", motorjoint_type);
	mod.link_optional("*", "motorjoint_set_enabled", motorjoint_set_enabled);
	mod.link_optional("*", "motorjoint_is_enabled", motorjoint_is_enabled);
	mod.link_optional("*", "motorjoint_set_force", motorjoint_set_force);
	mod.link_optional("*", "motorjoint_get_force", motorjoint_get_force);
	mod.link_optional("*", "motorjoint_set_speed", motorjoint_set_speed);
	mod.link_optional("*", "motorjoint_get_speed", motorjoint_get_speed);
}