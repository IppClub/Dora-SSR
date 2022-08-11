static int32_t joint_type()
{
	return DoraType<Joint>();
}
static int64_t joint_distance(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, float frequency, float damping)
{
	return from_object(Joint::distance(collision != 0, r_cast<Body*>(body_a), r_cast<Body*>(body_b), vec2_from(anchor_a), vec2_from(anchor_b), frequency, damping));
}
static int64_t joint_friction(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float max_force, float max_torque)
{
	return from_object(Joint::friction(collision != 0, r_cast<Body*>(body_a), r_cast<Body*>(body_b), vec2_from(world_pos), max_force, max_torque));
}
static int64_t joint_gear(int32_t collision, int64_t joint_a, int64_t joint_b, float ratio)
{
	return from_object(Joint::gear(collision != 0, r_cast<Joint*>(joint_a), r_cast<Joint*>(joint_b), ratio));
}
static int64_t joint_spring(int32_t collision, int64_t body_a, int64_t body_b, int64_t linear_offset, float angular_offset, float max_force, float max_torque, float correction_factor)
{
	return from_object(Joint::spring(collision != 0, r_cast<Body*>(body_a), r_cast<Body*>(body_b), vec2_from(linear_offset), angular_offset, max_force, max_torque, correction_factor));
}
static int64_t joint_move_target(int32_t collision, int64_t body, int64_t target_pos, float max_force, float frequency, float damping)
{
	return from_object(Joint::move(collision != 0, r_cast<Body*>(body), vec2_from(target_pos), max_force, frequency, damping));
}
static int64_t joint_prismatic(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float axis_angle, float lower_translation, float upper_translation, float max_motor_force, float motor_speed)
{
	return from_object(Joint::prismatic(collision != 0, r_cast<Body*>(body_a), r_cast<Body*>(body_b), vec2_from(world_pos), axis_angle, lower_translation, upper_translation, max_motor_force, motor_speed));
}
static int64_t joint_pulley(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, int64_t ground_anchor_a, int64_t ground_anchor_b, float ratio)
{
	return from_object(Joint::pulley(collision != 0, r_cast<Body*>(body_a), r_cast<Body*>(body_b), vec2_from(anchor_a), vec2_from(anchor_b), vec2_from(ground_anchor_a), vec2_from(ground_anchor_b), ratio));
}
static int64_t joint_revolute(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float lower_angle, float upper_angle, float max_motor_torque, float motor_speed)
{
	return from_object(Joint::revolute(collision != 0, r_cast<Body*>(body_a), r_cast<Body*>(body_b), vec2_from(world_pos), lower_angle, upper_angle, max_motor_torque, motor_speed));
}
static int64_t joint_rope(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, float max_length)
{
	return from_object(Joint::rope(collision != 0, r_cast<Body*>(body_a), r_cast<Body*>(body_b), vec2_from(anchor_a), vec2_from(anchor_b), max_length));
}
static int64_t joint_weld(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float frequency, float damping)
{
	return from_object(Joint::weld(collision != 0, r_cast<Body*>(body_a), r_cast<Body*>(body_b), vec2_from(world_pos), frequency, damping));
}
static int64_t joint_wheel(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float axis_angle, float max_motor_torque, float motor_speed, float frequency, float damping)
{
	return from_object(Joint::wheel(collision != 0, r_cast<Body*>(body_a), r_cast<Body*>(body_b), vec2_from(world_pos), axis_angle, max_motor_torque, motor_speed, frequency, damping));
}
static int64_t joint_get_world(int64_t self)
{
	return from_object(r_cast<Joint*>(self)->getPhysicsWorld());
}
static void joint_destroy(int64_t self)
{
	r_cast<Joint*>(self)->destroy();
}
static int64_t joint_new(int64_t def, int64_t item_dict)
{
	return from_object(Joint::create(r_cast<JointDef*>(def), r_cast<Dictionary*>(item_dict)));
}
static void linkJoint(wasm3::module& mod)
{
	mod.link_optional("*", "joint_type", joint_type);
	mod.link_optional("*", "joint_distance", joint_distance);
	mod.link_optional("*", "joint_friction", joint_friction);
	mod.link_optional("*", "joint_gear", joint_gear);
	mod.link_optional("*", "joint_spring", joint_spring);
	mod.link_optional("*", "joint_move_target", joint_move_target);
	mod.link_optional("*", "joint_prismatic", joint_prismatic);
	mod.link_optional("*", "joint_pulley", joint_pulley);
	mod.link_optional("*", "joint_revolute", joint_revolute);
	mod.link_optional("*", "joint_rope", joint_rope);
	mod.link_optional("*", "joint_weld", joint_weld);
	mod.link_optional("*", "joint_wheel", joint_wheel);
	mod.link_optional("*", "joint_get_world", joint_get_world);
	mod.link_optional("*", "joint_destroy", joint_destroy);
	mod.link_optional("*", "joint_new", joint_new);
}