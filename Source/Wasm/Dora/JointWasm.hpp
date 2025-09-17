/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t joint_type() {
	return DoraType<Joint>();
}
DORA_EXPORT int64_t joint_distance(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, float frequency, float damping) {
	return Object_From(Joint::distance(collision != 0, r_cast<Body*>(body_a), r_cast<Body*>(body_b), Vec2_From(anchor_a), Vec2_From(anchor_b), frequency, damping));
}
DORA_EXPORT int64_t joint_friction(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float max_force, float max_torque) {
	return Object_From(Joint::friction(collision != 0, r_cast<Body*>(body_a), r_cast<Body*>(body_b), Vec2_From(world_pos), max_force, max_torque));
}
DORA_EXPORT int64_t joint_gear(int32_t collision, int64_t joint_a, int64_t joint_b, float ratio) {
	return Object_From(Joint::gear(collision != 0, r_cast<Joint*>(joint_a), r_cast<Joint*>(joint_b), ratio));
}
DORA_EXPORT int64_t joint_spring(int32_t collision, int64_t body_a, int64_t body_b, int64_t linear_offset, float angular_offset, float max_force, float max_torque, float correction_factor) {
	return Object_From(Joint::spring(collision != 0, r_cast<Body*>(body_a), r_cast<Body*>(body_b), Vec2_From(linear_offset), angular_offset, max_force, max_torque, correction_factor));
}
DORA_EXPORT int64_t joint_move_target(int32_t collision, int64_t body, int64_t target_pos, float max_force, float frequency, float damping) {
	return Object_From(Joint::move(collision != 0, r_cast<Body*>(body), Vec2_From(target_pos), max_force, frequency, damping));
}
DORA_EXPORT int64_t joint_prismatic(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float axis_angle, float lower_translation, float upper_translation, float max_motor_force, float motor_speed) {
	return Object_From(Joint::prismatic(collision != 0, r_cast<Body*>(body_a), r_cast<Body*>(body_b), Vec2_From(world_pos), axis_angle, lower_translation, upper_translation, max_motor_force, motor_speed));
}
DORA_EXPORT int64_t joint_pulley(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, int64_t ground_anchor_a, int64_t ground_anchor_b, float ratio) {
	return Object_From(Joint::pulley(collision != 0, r_cast<Body*>(body_a), r_cast<Body*>(body_b), Vec2_From(anchor_a), Vec2_From(anchor_b), Vec2_From(ground_anchor_a), Vec2_From(ground_anchor_b), ratio));
}
DORA_EXPORT int64_t joint_revolute(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float lower_angle, float upper_angle, float max_motor_torque, float motor_speed) {
	return Object_From(Joint::revolute(collision != 0, r_cast<Body*>(body_a), r_cast<Body*>(body_b), Vec2_From(world_pos), lower_angle, upper_angle, max_motor_torque, motor_speed));
}
DORA_EXPORT int64_t joint_rope(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, float max_length) {
	return Object_From(Joint::rope(collision != 0, r_cast<Body*>(body_a), r_cast<Body*>(body_b), Vec2_From(anchor_a), Vec2_From(anchor_b), max_length));
}
DORA_EXPORT int64_t joint_weld(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float frequency, float damping) {
	return Object_From(Joint::weld(collision != 0, r_cast<Body*>(body_a), r_cast<Body*>(body_b), Vec2_From(world_pos), frequency, damping));
}
DORA_EXPORT int64_t joint_wheel(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float axis_angle, float max_motor_torque, float motor_speed, float frequency, float damping) {
	return Object_From(Joint::wheel(collision != 0, r_cast<Body*>(body_a), r_cast<Body*>(body_b), Vec2_From(world_pos), axis_angle, max_motor_torque, motor_speed, frequency, damping));
}
DORA_EXPORT int64_t joint_get_world(int64_t self) {
	return Object_From(r_cast<Joint*>(self)->getPhysicsWorld());
}
DORA_EXPORT void joint_destroy(int64_t self) {
	r_cast<Joint*>(self)->destroy();
}
DORA_EXPORT int64_t joint_new(int64_t def, int64_t item_dict) {
	return Object_From(Joint::create(r_cast<JointDef*>(def), r_cast<Dictionary*>(item_dict)));
}
} // extern "C"

static void linkJoint(wasm3::module3& mod) {
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