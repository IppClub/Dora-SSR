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
DORA_EXPORT int64_t physicsworld3d_create_box(int64_t self, int64_t node, int64_t half_extent, int32_t body_type) {
	return Object_From(r_cast<PhysicsWorld3D*>(self)->createBox(r_cast<Node3D*>(node), Vec3_From(half_extent), s_cast<BodyType3D>(body_type)));
}
DORA_EXPORT int64_t physicsworld3d_create_sphere(int64_t self, int64_t node, float radius, int32_t body_type) {
	return Object_From(r_cast<PhysicsWorld3D*>(self)->createSphere(r_cast<Node3D*>(node), radius, s_cast<BodyType3D>(body_type)));
}
DORA_EXPORT int64_t physicsworld3d_create_capsule(int64_t self, int64_t node, float half_height, float radius, int32_t body_type) {
	return Object_From(r_cast<PhysicsWorld3D*>(self)->createCapsule(r_cast<Node3D*>(node), half_height, radius, s_cast<BodyType3D>(body_type)));
}
DORA_EXPORT int64_t physicsworld3d_create_body(int64_t self, int64_t node, int64_t shape, int32_t body_type) {
	return Object_From(r_cast<PhysicsWorld3D*>(self)->createBody(r_cast<Node3D*>(node), r_cast<PhysicsShape3D*>(shape), s_cast<BodyType3D>(body_type)));
}
DORA_EXPORT int64_t physicsworld3d_create_character(int64_t self, int64_t node, float half_height, float radius, float max_slope_angle, float step_height) {
	return Object_From(r_cast<PhysicsWorld3D*>(self)->createCharacter(r_cast<Node3D*>(node), half_height, radius, max_slope_angle, step_height));
}
DORA_EXPORT int64_t physicsworld3d_create_fixed_constraint(int64_t self, int64_t first_body, int64_t second_body, int64_t anchor) {
	return Object_From(r_cast<PhysicsWorld3D*>(self)->createFixedConstraint(r_cast<Body3D*>(first_body), r_cast<Body3D*>(second_body), Vec3_From(anchor)));
}
DORA_EXPORT int64_t physicsworld3d_create_distance_constraint(int64_t self, int64_t first_body, int64_t second_body, int64_t first_anchor, int64_t second_anchor, float min_distance, float max_distance) {
	return Object_From(r_cast<PhysicsWorld3D*>(self)->createDistanceConstraint(r_cast<Body3D*>(first_body), r_cast<Body3D*>(second_body), Vec3_From(first_anchor), Vec3_From(second_anchor), min_distance, max_distance));
}
DORA_EXPORT int64_t physicsworld3d_create_hinge_constraint(int64_t self, int64_t first_body, int64_t second_body, int64_t anchor, int64_t axis, float min_angle, float max_angle) {
	return Object_From(r_cast<PhysicsWorld3D*>(self)->createHingeConstraint(r_cast<Body3D*>(first_body), r_cast<Body3D*>(second_body), Vec3_From(anchor), Vec3_From(axis), min_angle, max_angle));
}
DORA_EXPORT void physicsworld3d_destroy_body(int64_t self, int64_t body) {
	r_cast<PhysicsWorld3D*>(self)->destroyBody(r_cast<Body3D*>(body));
}
DORA_EXPORT void physicsworld3d_destroy_character(int64_t self, int64_t character) {
	r_cast<PhysicsWorld3D*>(self)->destroyCharacter(r_cast<CharacterController3D*>(character));
}
DORA_EXPORT void physicsworld3d_destroy_constraint(int64_t self, int64_t constraint) {
	r_cast<PhysicsWorld3D*>(self)->destroyConstraint(r_cast<Constraint3D*>(constraint));
}
DORA_EXPORT int32_t physicsworld3d_raycast(int64_t self, int64_t origin, int64_t direction, float distance, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	return r_cast<PhysicsWorld3D*>(self)->raycast(Vec3_From(origin), Vec3_From(direction), distance, [func0, args0, deref0](Body3D* body, Vec3 point, Vec3 normal, float hitDistance) {
		args0->clear();
		args0->push(body);
		args0->push(point);
		args0->push(normal);
		args0->push(hitDistance);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(false);
	}) ? 1 : 0;
}
DORA_EXPORT int32_t physicsworld3d_overlap_sphere(int64_t self, int64_t center, float radius, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	return r_cast<PhysicsWorld3D*>(self)->overlapSphere(Vec3_From(center), radius, [func0, args0, deref0](Body3D* body) {
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
	mod.link_optional("*", "physicsworld3d_create_box", physicsworld3d_create_box);
	mod.link_optional("*", "physicsworld3d_create_sphere", physicsworld3d_create_sphere);
	mod.link_optional("*", "physicsworld3d_create_capsule", physicsworld3d_create_capsule);
	mod.link_optional("*", "physicsworld3d_create_body", physicsworld3d_create_body);
	mod.link_optional("*", "physicsworld3d_create_character", physicsworld3d_create_character);
	mod.link_optional("*", "physicsworld3d_create_fixed_constraint", physicsworld3d_create_fixed_constraint);
	mod.link_optional("*", "physicsworld3d_create_distance_constraint", physicsworld3d_create_distance_constraint);
	mod.link_optional("*", "physicsworld3d_create_hinge_constraint", physicsworld3d_create_hinge_constraint);
	mod.link_optional("*", "physicsworld3d_destroy_body", physicsworld3d_destroy_body);
	mod.link_optional("*", "physicsworld3d_destroy_character", physicsworld3d_destroy_character);
	mod.link_optional("*", "physicsworld3d_destroy_constraint", physicsworld3d_destroy_constraint);
	mod.link_optional("*", "physicsworld3d_raycast", physicsworld3d_raycast);
	mod.link_optional("*", "physicsworld3d_overlap_sphere", physicsworld3d_overlap_sphere);
	mod.link_optional("*", "physicsworld3d_new", physicsworld3d_new);
}