/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t jointdef_type() {
	return DoraType<JointDef>();
}
DORA_EXPORT void jointdef_set_center(int64_t self, int64_t val) {
	r_cast<JointDef*>(self)->center = Vec2_From(val);
}
DORA_EXPORT int64_t jointdef_get_center(int64_t self) {
	return Vec2_Retain(r_cast<JointDef*>(self)->center);
}
DORA_EXPORT void jointdef_set_position(int64_t self, int64_t val) {
	r_cast<JointDef*>(self)->position = Vec2_From(val);
}
DORA_EXPORT int64_t jointdef_get_position(int64_t self) {
	return Vec2_Retain(r_cast<JointDef*>(self)->position);
}
DORA_EXPORT void jointdef_set_angle(int64_t self, float val) {
	r_cast<JointDef*>(self)->angle = s_cast<float>(val);
}
DORA_EXPORT float jointdef_get_angle(int64_t self) {
	return r_cast<JointDef*>(self)->angle;
}
DORA_EXPORT int64_t jointdef_distance(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, float frequency, float damping) {
	return Object_From(JointDef::distance(collision != 0, *Str_From(body_a), *Str_From(body_b), Vec2_From(anchor_a), Vec2_From(anchor_b), frequency, damping));
}
DORA_EXPORT int64_t jointdef_friction(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float max_force, float max_torque) {
	return Object_From(JointDef::friction(collision != 0, *Str_From(body_a), *Str_From(body_b), Vec2_From(world_pos), max_force, max_torque));
}
DORA_EXPORT int64_t jointdef_gear(int32_t collision, int64_t joint_a, int64_t joint_b, float ratio) {
	return Object_From(JointDef::gear(collision != 0, *Str_From(joint_a), *Str_From(joint_b), ratio));
}
DORA_EXPORT int64_t jointdef_spring(int32_t collision, int64_t body_a, int64_t body_b, int64_t linear_offset, float angular_offset, float max_force, float max_torque, float correction_factor) {
	return Object_From(JointDef::spring(collision != 0, *Str_From(body_a), *Str_From(body_b), Vec2_From(linear_offset), angular_offset, max_force, max_torque, correction_factor));
}
DORA_EXPORT int64_t jointdef_prismatic(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float axis_angle, float lower_translation, float upper_translation, float max_motor_force, float motor_speed) {
	return Object_From(JointDef::prismatic(collision != 0, *Str_From(body_a), *Str_From(body_b), Vec2_From(world_pos), axis_angle, lower_translation, upper_translation, max_motor_force, motor_speed));
}
DORA_EXPORT int64_t jointdef_pulley(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, int64_t ground_anchor_a, int64_t ground_anchor_b, float ratio) {
	return Object_From(JointDef::pulley(collision != 0, *Str_From(body_a), *Str_From(body_b), Vec2_From(anchor_a), Vec2_From(anchor_b), Vec2_From(ground_anchor_a), Vec2_From(ground_anchor_b), ratio));
}
DORA_EXPORT int64_t jointdef_revolute(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float lower_angle, float upper_angle, float max_motor_torque, float motor_speed) {
	return Object_From(JointDef::revolute(collision != 0, *Str_From(body_a), *Str_From(body_b), Vec2_From(world_pos), lower_angle, upper_angle, max_motor_torque, motor_speed));
}
DORA_EXPORT int64_t jointdef_rope(int32_t collision, int64_t body_a, int64_t body_b, int64_t anchor_a, int64_t anchor_b, float max_length) {
	return Object_From(JointDef::rope(collision != 0, *Str_From(body_a), *Str_From(body_b), Vec2_From(anchor_a), Vec2_From(anchor_b), max_length));
}
DORA_EXPORT int64_t jointdef_weld(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float frequency, float damping) {
	return Object_From(JointDef::weld(collision != 0, *Str_From(body_a), *Str_From(body_b), Vec2_From(world_pos), frequency, damping));
}
DORA_EXPORT int64_t jointdef_wheel(int32_t collision, int64_t body_a, int64_t body_b, int64_t world_pos, float axis_angle, float max_motor_torque, float motor_speed, float frequency, float damping) {
	return Object_From(JointDef::wheel(collision != 0, *Str_From(body_a), *Str_From(body_b), Vec2_From(world_pos), axis_angle, max_motor_torque, motor_speed, frequency, damping));
}
} // extern "C"

static void linkJointDef(wasm3::module3& mod) {
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