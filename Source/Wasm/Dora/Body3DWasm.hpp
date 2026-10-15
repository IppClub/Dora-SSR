/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t body3d_type() {
	return DoraType<Body3D>();
}
DORA_EXPORT int64_t body3d_get_world(int64_t self) {
	return Object_From(r_cast<Body3D*>(self)->getPhysicsWorld());
}
DORA_EXPORT int64_t body3d_get_body_def(int64_t self) {
	return Object_From(r_cast<Body3D*>(self)->getBodyDef());
}
DORA_EXPORT int32_t body3d_get_type(int64_t self) {
	return s_cast<int32_t>(r_cast<Body3D*>(self)->getType());
}
DORA_EXPORT void body3d_set_linear_velocity(int64_t self, int64_t val) {
	r_cast<Body3D*>(self)->setLinearVelocity(Vec3_From(val));
}
DORA_EXPORT int64_t body3d_get_linear_velocity(int64_t self) {
	return Vec3_Retain(r_cast<Body3D*>(self)->getLinearVelocity());
}
DORA_EXPORT void body3d_set_angular_velocity(int64_t self, int64_t val) {
	r_cast<Body3D*>(self)->setAngularVelocity(Vec3_From(val));
}
DORA_EXPORT int64_t body3d_get_angular_velocity(int64_t self) {
	return Vec3_Retain(r_cast<Body3D*>(self)->getAngularVelocity());
}
DORA_EXPORT void body3d_set_collision_layer(int64_t self, int32_t val) {
	r_cast<Body3D*>(self)->setCollisionLayer(s_cast<uint8_t>(val));
}
DORA_EXPORT int32_t body3d_get_collision_layer(int64_t self) {
	return s_cast<int32_t>(r_cast<Body3D*>(self)->getCollisionLayer());
}
DORA_EXPORT void body3d_set_collision_mask(int64_t self, int32_t val) {
	r_cast<Body3D*>(self)->setCollisionMask(s_cast<uint32_t>(val));
}
DORA_EXPORT int32_t body3d_get_collision_mask(int64_t self) {
	return s_cast<int32_t>(r_cast<Body3D*>(self)->getCollisionMask());
}
DORA_EXPORT void body3d_set_sensor(int64_t self, int32_t val) {
	r_cast<Body3D*>(self)->setSensor(val != 0);
}
DORA_EXPORT int32_t body3d_is_sensor(int64_t self) {
	return r_cast<Body3D*>(self)->isSensor() ? 1 : 0;
}
DORA_EXPORT void body3d_apply_force(int64_t self, int64_t force) {
	r_cast<Body3D*>(self)->applyForce(Vec3_From(force));
}
DORA_EXPORT void body3d_apply_linear_impulse(int64_t self, int64_t impulse) {
	r_cast<Body3D*>(self)->applyLinearImpulse(Vec3_From(impulse));
}
DORA_EXPORT void body3d_on_contact_enter(int64_t self, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	r_cast<Body3D*>(self)->onContactEnter([func0, args0, deref0](Body3D* other, Vec3 point, Vec3 normal) {
		args0->clear();
		args0->push(other);
		args0->push(point);
		args0->push(normal);
		SharedWasmRuntime.invoke(func0);
	});
}
DORA_EXPORT void body3d_on_contact_stay(int64_t self, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	r_cast<Body3D*>(self)->onContactStay([func0, args0, deref0](Body3D* other, Vec3 point, Vec3 normal) {
		args0->clear();
		args0->push(other);
		args0->push(point);
		args0->push(normal);
		SharedWasmRuntime.invoke(func0);
	});
}
DORA_EXPORT void body3d_on_contact_exit(int64_t self, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	r_cast<Body3D*>(self)->onContactExit([func0, args0, deref0](Body3D* other, Vec3 point, Vec3 normal) {
		args0->clear();
		args0->push(other);
		args0->push(point);
		args0->push(normal);
		SharedWasmRuntime.invoke(func0);
	});
}
DORA_EXPORT int64_t body3d_new(int64_t body_def, int64_t world, int64_t position, int64_t angles) {
	return Object_From(Body3D::create(r_cast<BodyDef3D*>(body_def), r_cast<PhysicsWorld3D*>(world), Vec3_From(position), Vec3_From(angles)));
}
} // extern "C"

static void linkBody3D(wasm3::module3& mod) {
	mod.link_optional("*", "body3d_type", body3d_type);
	mod.link_optional("*", "body3d_get_world", body3d_get_world);
	mod.link_optional("*", "body3d_get_body_def", body3d_get_body_def);
	mod.link_optional("*", "body3d_get_type", body3d_get_type);
	mod.link_optional("*", "body3d_set_linear_velocity", body3d_set_linear_velocity);
	mod.link_optional("*", "body3d_get_linear_velocity", body3d_get_linear_velocity);
	mod.link_optional("*", "body3d_set_angular_velocity", body3d_set_angular_velocity);
	mod.link_optional("*", "body3d_get_angular_velocity", body3d_get_angular_velocity);
	mod.link_optional("*", "body3d_set_collision_layer", body3d_set_collision_layer);
	mod.link_optional("*", "body3d_get_collision_layer", body3d_get_collision_layer);
	mod.link_optional("*", "body3d_set_collision_mask", body3d_set_collision_mask);
	mod.link_optional("*", "body3d_get_collision_mask", body3d_get_collision_mask);
	mod.link_optional("*", "body3d_set_sensor", body3d_set_sensor);
	mod.link_optional("*", "body3d_is_sensor", body3d_is_sensor);
	mod.link_optional("*", "body3d_apply_force", body3d_apply_force);
	mod.link_optional("*", "body3d_apply_linear_impulse", body3d_apply_linear_impulse);
	mod.link_optional("*", "body3d_on_contact_enter", body3d_on_contact_enter);
	mod.link_optional("*", "body3d_on_contact_stay", body3d_on_contact_stay);
	mod.link_optional("*", "body3d_on_contact_exit", body3d_on_contact_exit);
	mod.link_optional("*", "body3d_new", body3d_new);
}