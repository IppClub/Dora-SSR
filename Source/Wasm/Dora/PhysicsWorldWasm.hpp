static int32_t physicsworld_type() {
	return DoraType<PhysicsWorld>();
}
static void physicsworld_set_show_debug(int64_t self, int32_t var) {
	r_cast<PhysicsWorld*>(self)->setShowDebug(var != 0);
}
static int32_t physicsworld_is_show_debug(int64_t self) {
	return r_cast<PhysicsWorld*>(self)->isShowDebug() ? 1 : 0;
}
static int32_t physicsworld_query(int64_t self, int64_t rect, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	return r_cast<PhysicsWorld*>(self)->query(*r_cast<Rect*>(rect), [func, args, deref](Body* body) {
		args->clear();
		args->push(body);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	}) ? 1 : 0;
}
static int32_t physicsworld_raycast(int64_t self, int64_t start, int64_t stop, int32_t closest, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	return r_cast<PhysicsWorld*>(self)->raycast(vec2_from(start), vec2_from(stop), closest != 0, [func, args, deref](Body* body, Vec2 point, Vec2 normal) {
		args->clear();
		args->push(body);
		args->push(point);
		args->push(normal);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	}) ? 1 : 0;
}
static void physicsworld_set_iterations(int64_t self, int32_t velocity_iter, int32_t position_iter) {
	r_cast<PhysicsWorld*>(self)->setIterations(s_cast<int>(velocity_iter), s_cast<int>(position_iter));
}
static void physicsworld_set_should_contact(int64_t self, int32_t group_a, int32_t group_b, int32_t contact) {
	r_cast<PhysicsWorld*>(self)->setShouldContact(s_cast<uint8_t>(group_a), s_cast<uint8_t>(group_b), contact != 0);
}
static int32_t physicsworld_get_should_contact(int64_t self, int32_t group_a, int32_t group_b) {
	return r_cast<PhysicsWorld*>(self)->getShouldContact(s_cast<uint8_t>(group_a), s_cast<uint8_t>(group_b)) ? 1 : 0;
}
static void physicsworld_set_b2_factor(int64_t self, float var) {
	r_cast<PhysicsWorld*>(self)->b2Factor = s_cast<float>(var);
}
static float physicsworld_get_b2_factor(int64_t self) {
	return PhysicsWorld::b2Factor;
}
static int64_t physicsworld_new() {
	return from_object(PhysicsWorld::create());
}
static void linkPhysicsWorld(wasm3::module& mod) {
	mod.link_optional("*", "physicsworld_type", physicsworld_type);
	mod.link_optional("*", "physicsworld_set_show_debug", physicsworld_set_show_debug);
	mod.link_optional("*", "physicsworld_is_show_debug", physicsworld_is_show_debug);
	mod.link_optional("*", "physicsworld_query", physicsworld_query);
	mod.link_optional("*", "physicsworld_raycast", physicsworld_raycast);
	mod.link_optional("*", "physicsworld_set_iterations", physicsworld_set_iterations);
	mod.link_optional("*", "physicsworld_set_should_contact", physicsworld_set_should_contact);
	mod.link_optional("*", "physicsworld_get_should_contact", physicsworld_get_should_contact);
	mod.link_optional("*", "physicsworld_set_b2_factor", physicsworld_set_b2_factor);
	mod.link_optional("*", "physicsworld_get_b2_factor", physicsworld_get_b2_factor);
	mod.link_optional("*", "physicsworld_new", physicsworld_new);
}