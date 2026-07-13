/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t physicsworld3d_type() {
	return DoraType<PhysicsWorld3D>();
}
DORA_EXPORT void physicsworld3d_set_gravity(int64_t self, int64_t val) {
	r_cast<PhysicsWorld3D*>(self)->setGravity(Vec3_From(val));
}
DORA_EXPORT int64_t physicsworld3d_get_gravity(int64_t self) {
	return Vec3_Retain(r_cast<PhysicsWorld3D*>(self)->getGravity());
}
DORA_EXPORT int64_t physicsworld3d_create_character(int64_t self, int64_t node, float half_height, float radius, float max_slope_angle, float step_height) {
	return Object_From(r_cast<PhysicsWorld3D*>(self)->createCharacter(r_cast<Node3D*>(node), half_height, radius, max_slope_angle, step_height));
}
DORA_EXPORT void physicsworld3d_destroy_character(int64_t self, int64_t character) {
	r_cast<PhysicsWorld3D*>(self)->destroyCharacter(r_cast<CharacterController3D*>(character));
}
DORA_EXPORT int32_t physicsworld3d_raycast(int64_t self, int64_t start, int64_t stop, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	return r_cast<PhysicsWorld3D*>(self)->raycast(Vec3_From(start), Vec3_From(stop), [func0, args0, deref0](Body3D* body, Vec3 point, Vec3 normal) {
		args0->clear();
		args0->push(body);
		args0->push(point);
		args0->push(normal);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(false);
	}) ? 1 : 0;
}
DORA_EXPORT int32_t physicsworld3d_query_sphere(int64_t self, int64_t center, float radius, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	return r_cast<PhysicsWorld3D*>(self)->querySphere(Vec3_From(center), radius, [func0, args0, deref0](Body3D* body) {
		args0->clear();
		args0->push(body);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(false);
	}) ? 1 : 0;
}
DORA_EXPORT int64_t physicsworld3d_new() {
	return Object_From(PhysicsWorld3D::create());
}
} // extern "C"

static void linkPhysicsWorld3D(wasm3::module3& mod) {
	mod.link_optional("*", "physicsworld3d_type", physicsworld3d_type);
	mod.link_optional("*", "physicsworld3d_set_gravity", physicsworld3d_set_gravity);
	mod.link_optional("*", "physicsworld3d_get_gravity", physicsworld3d_get_gravity);
	mod.link_optional("*", "physicsworld3d_create_character", physicsworld3d_create_character);
	mod.link_optional("*", "physicsworld3d_destroy_character", physicsworld3d_destroy_character);
	mod.link_optional("*", "physicsworld3d_raycast", physicsworld3d_raycast);
	mod.link_optional("*", "physicsworld3d_query_sphere", physicsworld3d_query_sphere);
	mod.link_optional("*", "physicsworld3d_new", physicsworld3d_new);
}