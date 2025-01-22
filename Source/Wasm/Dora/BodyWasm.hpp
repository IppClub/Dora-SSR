/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t body_type() {
	return DoraType<Body>();
}
int64_t body_get_world(int64_t self) {
	return Object_From(r_cast<Body*>(self)->getPhysicsWorld());
}
int64_t body_get_body_def(int64_t self) {
	return Object_From(r_cast<Body*>(self)->getBodyDef());
}
float body_get_mass(int64_t self) {
	return r_cast<Body*>(self)->getMass();
}
int32_t body_is_sensor(int64_t self) {
	return r_cast<Body*>(self)->isSensor() ? 1 : 0;
}
void body_set_velocity_x(int64_t self, float val) {
	r_cast<Body*>(self)->setVelocityX(val);
}
float body_get_velocity_x(int64_t self) {
	return r_cast<Body*>(self)->getVelocityX();
}
void body_set_velocity_y(int64_t self, float val) {
	r_cast<Body*>(self)->setVelocityY(val);
}
float body_get_velocity_y(int64_t self) {
	return r_cast<Body*>(self)->getVelocityY();
}
void body_set_velocity(int64_t self, int64_t val) {
	r_cast<Body*>(self)->setVelocity(Vec2_From(val));
}
int64_t body_get_velocity(int64_t self) {
	return Vec2_Retain(r_cast<Body*>(self)->getVelocity());
}
void body_set_angular_rate(int64_t self, float val) {
	r_cast<Body*>(self)->setAngularRate(val);
}
float body_get_angular_rate(int64_t self) {
	return r_cast<Body*>(self)->getAngularRate();
}
void body_set_group(int64_t self, int32_t val) {
	r_cast<Body*>(self)->setGroup(s_cast<uint8_t>(val));
}
int32_t body_get_group(int64_t self) {
	return s_cast<int32_t>(r_cast<Body*>(self)->getGroup());
}
void body_set_linear_damping(int64_t self, float val) {
	r_cast<Body*>(self)->setLinearDamping(val);
}
float body_get_linear_damping(int64_t self) {
	return r_cast<Body*>(self)->getLinearDamping();
}
void body_set_angular_damping(int64_t self, float val) {
	r_cast<Body*>(self)->setAngularDamping(val);
}
float body_get_angular_damping(int64_t self) {
	return r_cast<Body*>(self)->getAngularDamping();
}
void body_set_owner(int64_t self, int64_t val) {
	r_cast<Body*>(self)->setOwner(r_cast<Object*>(val));
}
int64_t body_get_owner(int64_t self) {
	return Object_From(r_cast<Body*>(self)->getOwner());
}
void body_set_receiving_contact(int64_t self, int32_t val) {
	r_cast<Body*>(self)->setReceivingContact(val != 0);
}
int32_t body_is_receiving_contact(int64_t self) {
	return r_cast<Body*>(self)->isReceivingContact() ? 1 : 0;
}
void body_apply_linear_impulse(int64_t self, int64_t impulse, int64_t pos) {
	r_cast<Body*>(self)->applyLinearImpulse(Vec2_From(impulse), Vec2_From(pos));
}
void body_apply_angular_impulse(int64_t self, float impulse) {
	r_cast<Body*>(self)->applyAngularImpulse(impulse);
}
int64_t body_get_sensor_by_tag(int64_t self, int32_t tag) {
	return Object_From(r_cast<Body*>(self)->getSensorByTag(s_cast<int>(tag)));
}
int32_t body_remove_sensor_by_tag(int64_t self, int32_t tag) {
	return r_cast<Body*>(self)->removeSensorByTag(s_cast<int>(tag)) ? 1 : 0;
}
int32_t body_remove_sensor(int64_t self, int64_t sensor) {
	return r_cast<Body*>(self)->removeSensor(r_cast<Sensor*>(sensor)) ? 1 : 0;
}
void body_attach(int64_t self, int64_t fixture_def) {
	r_cast<Body*>(self)->attach(r_cast<FixtureDef*>(fixture_def));
}
int64_t body_attach_sensor(int64_t self, int32_t tag, int64_t fixture_def) {
	return Object_From(r_cast<Body*>(self)->attachSensor(s_cast<int>(tag), r_cast<FixtureDef*>(fixture_def)));
}
void body_on_contact_filter(int64_t self, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	r_cast<Body*>(self)->onContactFilter([func0, args0, deref0](Body* body) {
		args0->clear();
		args0->push(body);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(false);
	});
}
int64_t body_new(int64_t def, int64_t world, int64_t pos, float rot) {
	return Object_From(Body::create(r_cast<BodyDef*>(def), r_cast<PhysicsWorld*>(world), Vec2_From(pos), rot));
}
} // extern "C"

static void linkBody(wasm3::module3& mod) {
	mod.link_optional("*", "body_type", body_type);
	mod.link_optional("*", "body_get_world", body_get_world);
	mod.link_optional("*", "body_get_body_def", body_get_body_def);
	mod.link_optional("*", "body_get_mass", body_get_mass);
	mod.link_optional("*", "body_is_sensor", body_is_sensor);
	mod.link_optional("*", "body_set_velocity_x", body_set_velocity_x);
	mod.link_optional("*", "body_get_velocity_x", body_get_velocity_x);
	mod.link_optional("*", "body_set_velocity_y", body_set_velocity_y);
	mod.link_optional("*", "body_get_velocity_y", body_get_velocity_y);
	mod.link_optional("*", "body_set_velocity", body_set_velocity);
	mod.link_optional("*", "body_get_velocity", body_get_velocity);
	mod.link_optional("*", "body_set_angular_rate", body_set_angular_rate);
	mod.link_optional("*", "body_get_angular_rate", body_get_angular_rate);
	mod.link_optional("*", "body_set_group", body_set_group);
	mod.link_optional("*", "body_get_group", body_get_group);
	mod.link_optional("*", "body_set_linear_damping", body_set_linear_damping);
	mod.link_optional("*", "body_get_linear_damping", body_get_linear_damping);
	mod.link_optional("*", "body_set_angular_damping", body_set_angular_damping);
	mod.link_optional("*", "body_get_angular_damping", body_get_angular_damping);
	mod.link_optional("*", "body_set_owner", body_set_owner);
	mod.link_optional("*", "body_get_owner", body_get_owner);
	mod.link_optional("*", "body_set_receiving_contact", body_set_receiving_contact);
	mod.link_optional("*", "body_is_receiving_contact", body_is_receiving_contact);
	mod.link_optional("*", "body_apply_linear_impulse", body_apply_linear_impulse);
	mod.link_optional("*", "body_apply_angular_impulse", body_apply_angular_impulse);
	mod.link_optional("*", "body_get_sensor_by_tag", body_get_sensor_by_tag);
	mod.link_optional("*", "body_remove_sensor_by_tag", body_remove_sensor_by_tag);
	mod.link_optional("*", "body_remove_sensor", body_remove_sensor);
	mod.link_optional("*", "body_attach", body_attach);
	mod.link_optional("*", "body_attach_sensor", body_attach_sensor);
	mod.link_optional("*", "body_on_contact_filter", body_on_contact_filter);
	mod.link_optional("*", "body_new", body_new);
}