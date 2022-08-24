static int32_t jointdef_type() {
	return DoraType<JointDef>();
}
static void jointdef_set_center(int64_t self, int64_t var) {
	r_cast<JointDef*>(self)->center = vec2_from(var);
}
static int64_t jointdef_get_center(int64_t self) {
	return vec2_retain(r_cast<JointDef*>(self)->center);
}
static void jointdef_set_position(int64_t self, int64_t var) {
	r_cast<JointDef*>(self)->position = vec2_from(var);
}
static int64_t jointdef_get_position(int64_t self) {
	return vec2_retain(r_cast<JointDef*>(self)->position);
}
static void jointdef_set_angle(int64_t self, float var) {
	r_cast<JointDef*>(self)->angle = s_cast<float>(var);
}
static float jointdef_get_angle(int64_t self) {
	return r_cast<JointDef*>(self)->angle;
}
static int64_t jointdef_distance(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, float frequency, float damping) {
	return from_object(JointDef::distance(collision != 0, *str_from(body_a), *str_from(body_b), vec2_from(anchor_a), vec2_from(anchor_b), frequency, damping));
}
static int64_t jointdef_friction(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float max_force, float max_torque) {
	return from_object(JointDef::friction(collision != 0, *str_from(body_a), *str_from(body_b), vec2_from(world_pos), max_force, max_torque));
}
static int64_t jointdef_gear(int32_t collision, int64_t joint_a, int64_t joint_b, float ratio) {
	return from_object(JointDef::gear(collision != 0, *str_from(joint_a), *str_from(joint_b), ratio));
}
static int64_t jointdef_spring(int32_t collision, int64_t body_a, int64_t body_b, int64_t linear_offset, float angular_offset, float max_force, float max_torque, float correction_factor) {
	return from_object(JointDef::spring(collision != 0, *str_from(body_a), *str_from(body_b), vec2_from(linear_offset), angular_offset, max_force, max_torque, correction_factor));
}
static int64_t jointdef_prismatic(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float axis_angle, float lower_translation, float upper_translation, float max_motor_force, float motor_speed) {
	return from_object(JointDef::prismatic(collision != 0, *str_from(body_a), *str_from(body_b), vec2_from(world_pos), axis_angle, lower_translation, upper_translation, max_motor_force, motor_speed));
}
static int64_t jointdef_pulley(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, int64_t ground_anchor_a, int64_t ground_anchor_b, float ratio) {
	return from_object(JointDef::pulley(collision != 0, *str_from(body_a), *str_from(body_b), vec2_from(anchor_a), vec2_from(anchor_b), vec2_from(ground_anchor_a), vec2_from(ground_anchor_b), ratio));
}
static int64_t jointdef_revolute(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float lower_angle, float upper_angle, float max_motor_torque, float motor_speed) {
	return from_object(JointDef::revolute(collision != 0, *str_from(body_a), *str_from(body_b), vec2_from(world_pos), lower_angle, upper_angle, max_motor_torque, motor_speed));
}
static int64_t jointdef_rope(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, float max_length) {
	return from_object(JointDef::rope(collision != 0, *str_from(body_a), *str_from(body_b), vec2_from(anchor_a), vec2_from(anchor_b), max_length));
}
static int64_t jointdef_weld(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float frequency, float damping) {
	return from_object(JointDef::weld(collision != 0, *str_from(body_a), *str_from(body_b), vec2_from(world_pos), frequency, damping));
}
static int64_t jointdef_wheel(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float axis_angle, float max_motor_torque, float motor_speed, float frequency, float damping) {
	return from_object(JointDef::wheel(collision != 0, *str_from(body_a), *str_from(body_b), vec2_from(world_pos), axis_angle, max_motor_torque, motor_speed, frequency, damping));
}
static void linkJointDef(wasm3::module& mod) {
	mod.link_optional("*", "jointdef_type", jointdef_type);
	mod.link_optional("*", "jointdef_set_center", jointdef_set_center);
	mod.link_optional("*", "jointdef_get_center", jointdef_get_center);
	mod.link_optional("*", "jointdef_set_position", jointdef_set_position);
	mod.link_optional("*", "jointdef_get_position", jointdef_get_position);
	mod.link_optional("*", "jointdef_set_angle", jointdef_set_angle);
	mod.link_optional("*", "jointdef_get_angle", jointdef_get_angle);
	mod.link_optional("*", "jointdef_distance", jointdef_distance);
	mod.link_optional("*", "jointdef_friction", jointdef_friction);
	mod.link_optional("*", "jointdef_gear", jointdef_gear);
	mod.link_optional("*", "jointdef_spring", jointdef_spring);
	mod.link_optional("*", "jointdef_prismatic", jointdef_prismatic);
	mod.link_optional("*", "jointdef_pulley", jointdef_pulley);
	mod.link_optional("*", "jointdef_revolute", jointdef_revolute);
	mod.link_optional("*", "jointdef_rope", jointdef_rope);
	mod.link_optional("*", "jointdef_weld", jointdef_weld);
	mod.link_optional("*", "jointdef_wheel", jointdef_wheel);
}