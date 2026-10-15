/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t charactercontroller3d_type() {
	return DoraType<CharacterController3D>();
}
DORA_EXPORT int64_t charactercontroller3d_get_node(int64_t self) {
	return Object_From(r_cast<CharacterController3D*>(self)->getNode());
}
DORA_EXPORT int64_t charactercontroller3d_get_world(int64_t self) {
	return Object_From(r_cast<CharacterController3D*>(self)->getPhysicsWorld());
}
DORA_EXPORT void charactercontroller3d_set_desired_velocity(int64_t self, int64_t val) {
	r_cast<CharacterController3D*>(self)->setDesiredVelocity(Vec3_From(val));
}
DORA_EXPORT int64_t charactercontroller3d_get_desired_velocity(int64_t self) {
	return Vec3_Retain(r_cast<CharacterController3D*>(self)->getDesiredVelocity());
}
DORA_EXPORT int64_t charactercontroller3d_get_velocity(int64_t self) {
	return Vec3_Retain(r_cast<CharacterController3D*>(self)->getVelocity());
}
DORA_EXPORT int64_t charactercontroller3d_get_ground_normal(int64_t self) {
	return Vec3_Retain(r_cast<CharacterController3D*>(self)->getGroundNormal());
}
DORA_EXPORT int32_t charactercontroller3d_is_grounded(int64_t self) {
	return r_cast<CharacterController3D*>(self)->isGrounded() ? 1 : 0;
}
DORA_EXPORT void charactercontroller3d_set_collision_layer(int64_t self, int32_t val) {
	r_cast<CharacterController3D*>(self)->setCollisionLayer(s_cast<uint8_t>(val));
}
DORA_EXPORT int32_t charactercontroller3d_get_collision_layer(int64_t self) {
	return s_cast<int32_t>(r_cast<CharacterController3D*>(self)->getCollisionLayer());
}
DORA_EXPORT void charactercontroller3d_set_collision_mask(int64_t self, int32_t val) {
	r_cast<CharacterController3D*>(self)->setCollisionMask(s_cast<uint32_t>(val));
}
DORA_EXPORT int32_t charactercontroller3d_get_collision_mask(int64_t self) {
	return s_cast<int32_t>(r_cast<CharacterController3D*>(self)->getCollisionMask());
}
DORA_EXPORT void charactercontroller3d_jump(int64_t self, float speed) {
	r_cast<CharacterController3D*>(self)->jump(speed);
}
DORA_EXPORT void charactercontroller3d_destroy(int64_t self) {
	r_cast<CharacterController3D*>(self)->destroy();
}
} // extern "C"

static void linkCharacterController3D(wasm3::module3& mod) {
	mod.link_optional("*", "charactercontroller3d_type", charactercontroller3d_type);
	mod.link_optional("*", "charactercontroller3d_get_node", charactercontroller3d_get_node);
	mod.link_optional("*", "charactercontroller3d_get_world", charactercontroller3d_get_world);
	mod.link_optional("*", "charactercontroller3d_set_desired_velocity", charactercontroller3d_set_desired_velocity);
	mod.link_optional("*", "charactercontroller3d_get_desired_velocity", charactercontroller3d_get_desired_velocity);
	mod.link_optional("*", "charactercontroller3d_get_velocity", charactercontroller3d_get_velocity);
	mod.link_optional("*", "charactercontroller3d_get_ground_normal", charactercontroller3d_get_ground_normal);
	mod.link_optional("*", "charactercontroller3d_is_grounded", charactercontroller3d_is_grounded);
	mod.link_optional("*", "charactercontroller3d_set_collision_layer", charactercontroller3d_set_collision_layer);
	mod.link_optional("*", "charactercontroller3d_get_collision_layer", charactercontroller3d_get_collision_layer);
	mod.link_optional("*", "charactercontroller3d_set_collision_mask", charactercontroller3d_set_collision_mask);
	mod.link_optional("*", "charactercontroller3d_get_collision_mask", charactercontroller3d_get_collision_mask);
	mod.link_optional("*", "charactercontroller3d_jump", charactercontroller3d_jump);
	mod.link_optional("*", "charactercontroller3d_destroy", charactercontroller3d_destroy);
}