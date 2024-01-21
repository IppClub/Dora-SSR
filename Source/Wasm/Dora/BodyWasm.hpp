static int32_t body_type() {
	return DoraType<Body>();
}
static int64_t body_get_world(int64_t self) {
	return from_object(r_cast<Body*>(self)->getPhysicsWorld());
}
static int64_t body_get_body_def(int64_t self) {
	return from_object(r_cast<Body*>(self)->getBodyDef());
}
static float body_get_mass(int64_t self) {
	return r_cast<Body*>(self)->getMass();
}
static int32_t body_is_sensor(int64_t self) {
	return r_cast<Body*>(self)->isSensor() ? 1 : 0;
}
static void body_set_velocity_x(int64_t self, float var) {
	r_cast<Body*>(self)->setVelocityX(var);
}
static float body_get_velocity_x(int64_t self) {
	return r_cast<Body*>(self)->getVelocityX();
}
static void body_set_velocity_y(int64_t self, float var) {
	r_cast<Body*>(self)->setVelocityY(var);
}
static float body_get_velocity_y(int64_t self) {
	return r_cast<Body*>(self)->getVelocityY();
}
static void body_set_velocity(int64_t self, int64_t var) {
	r_cast<Body*>(self)->setVelocity(vec2_from(var));
}
static int64_t body_get_velocity(int64_t self) {
	return vec2_retain(r_cast<Body*>(self)->getVelocity());
}
static void body_set_angular_rate(int64_t self, float var) {
	r_cast<Body*>(self)->setAngularRate(var);
}
static float body_get_angular_rate(int64_t self) {
	return r_cast<Body*>(self)->getAngularRate();
}
static void body_set_group(int64_t self, int32_t var) {
	r_cast<Body*>(self)->setGroup(s_cast<uint8_t>(var));
}
static int32_t body_get_group(int64_t self) {
	return s_cast<int32_t>(r_cast<Body*>(self)->getGroup());
}
static void body_set_linear_damping(int64_t self, float var) {
	r_cast<Body*>(self)->setLinearDamping(var);
}
static float body_get_linear_damping(int64_t self) {
	return r_cast<Body*>(self)->getLinearDamping();
}
static void body_set_angular_damping(int64_t self, float var) {
	r_cast<Body*>(self)->setAngularDamping(var);
}
static float body_get_angular_damping(int64_t self) {
	return r_cast<Body*>(self)->getAngularDamping();
}
static void body_set_owner(int64_t self, int64_t var) {
	r_cast<Body*>(self)->setOwner(r_cast<Object*>(var));
}
static int64_t body_get_owner(int64_t self) {
	return from_object(r_cast<Body*>(self)->getOwner());
}
static void body_set_receiving_contact(int64_t self, int32_t var) {
	r_cast<Body*>(self)->setReceivingContact(var != 0);
}
static int32_t body_is_receiving_contact(int64_t self) {
	return r_cast<Body*>(self)->isReceivingContact() ? 1 : 0;
}
static void body_apply_linear_impulse(int64_t self, int64_t impulse, int64_t pos) {
	r_cast<Body*>(self)->applyLinearImpulse(vec2_from(impulse), vec2_from(pos));
}
static void body_apply_angular_impulse(int64_t self, float impulse) {
	r_cast<Body*>(self)->applyAngularImpulse(impulse);
}
static int64_t body_get_sensor_by_tag(int64_t self, int32_t tag) {
	return from_object(r_cast<Body*>(self)->getSensorByTag(s_cast<int>(tag)));
}
static int32_t body_remove_sensor_by_tag(int64_t self, int32_t tag) {
	return r_cast<Body*>(self)->removeSensorByTag(s_cast<int>(tag)) ? 1 : 0;
}
static int32_t body_remove_sensor(int64_t self, int64_t sensor) {
	return r_cast<Body*>(self)->removeSensor(r_cast<Sensor*>(sensor)) ? 1 : 0;
}
static void body_attach(int64_t self, int64_t fixture_def) {
	r_cast<Body*>(self)->attach(r_cast<FixtureDef*>(fixture_def));
}
static int64_t body_attach_sensor(int64_t self, int32_t tag, int64_t fixture_def) {
	return from_object(r_cast<Body*>(self)->attachSensor(s_cast<int>(tag), r_cast<FixtureDef*>(fixture_def)));
}
static void body_on_contact_filter(int64_t self, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	r_cast<Body*>(self)->onContactFilter([func, args, deref](Body* body) {
		args->clear();
		args->push(body);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	});
}
static int64_t body_new(int64_t def, int64_t world, int64_t pos, float rot) {
	return from_object(Body::create(r_cast<BodyDef*>(def), r_cast<PhysicsWorld*>(world), vec2_from(pos), rot));
}
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