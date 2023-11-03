static int32_t platformer_unit_type() {
	return DoraType<Platformer::Unit>();
}
static void platformer_unit_set_playable(int64_t self, int64_t var) {
	r_cast<Platformer::Unit*>(self)->setPlayable(r_cast<Playable*>(var));
}
static int64_t platformer_unit_get_playable(int64_t self) {
	return from_object(r_cast<Platformer::Unit*>(self)->getPlayable());
}
static void platformer_unit_set_detect_distance(int64_t self, float var) {
	r_cast<Platformer::Unit*>(self)->setDetectDistance(var);
}
static float platformer_unit_get_detect_distance(int64_t self) {
	return r_cast<Platformer::Unit*>(self)->getDetectDistance();
}
static void platformer_unit_set_attack_range(int64_t self, int64_t var) {
	r_cast<Platformer::Unit*>(self)->setAttackRange(size_from(var));
}
static int64_t platformer_unit_get_attack_range(int64_t self) {
	return size_retain(r_cast<Platformer::Unit*>(self)->getAttackRange());
}
static void platformer_unit_set_face_right(int64_t self, int32_t var) {
	r_cast<Platformer::Unit*>(self)->setFaceRight(var != 0);
}
static int32_t platformer_unit_is_face_right(int64_t self) {
	return r_cast<Platformer::Unit*>(self)->isFaceRight() ? 1 : 0;
}
static void platformer_unit_set_receiving_decision_trace(int64_t self, int32_t var) {
	r_cast<Platformer::Unit*>(self)->setReceivingDecisionTrace(var != 0);
}
static int32_t platformer_unit_is_receiving_decision_trace(int64_t self) {
	return r_cast<Platformer::Unit*>(self)->isReceivingDecisionTrace() ? 1 : 0;
}
static void platformer_unit_set_decision_tree(int64_t self, int64_t var) {
	r_cast<Platformer::Unit*>(self)->setDecisionTreeName(*str_from(var));
}
static int64_t platformer_unit_get_decision_tree(int64_t self) {
	return str_retain(r_cast<Platformer::Unit*>(self)->getDecisionTreeName());
}
static int32_t platformer_unit_is_on_surface(int64_t self) {
	return r_cast<Platformer::Unit*>(self)->isOnSurface() ? 1 : 0;
}
static int64_t platformer_unit_get_ground_sensor(int64_t self) {
	return from_object(r_cast<Platformer::Unit*>(self)->getGroundSensor());
}
static int64_t platformer_unit_get_detect_sensor(int64_t self) {
	return from_object(r_cast<Platformer::Unit*>(self)->getDetectSensor());
}
static int64_t platformer_unit_get_attack_sensor(int64_t self) {
	return from_object(r_cast<Platformer::Unit*>(self)->getAttackSensor());
}
static int64_t platformer_unit_get_unit_def(int64_t self) {
	return from_object(r_cast<Platformer::Unit*>(self)->getUnitDef());
}
static int64_t platformer_unit_get_current_action(int64_t self) {
	return r_cast<int64_t>(r_cast<Platformer::Unit*>(self)->getCurrentAction());
}
static float platformer_unit_get_width(int64_t self) {
	return r_cast<Platformer::Unit*>(self)->getWidth();
}
static float platformer_unit_get_height(int64_t self) {
	return r_cast<Platformer::Unit*>(self)->getHeight();
}
static int64_t platformer_unit_get_entity(int64_t self) {
	return from_object(r_cast<Platformer::Unit*>(self)->getEntity());
}
static int64_t platformer_unit_attach_action(int64_t self, int64_t name) {
	return r_cast<int64_t>(r_cast<Platformer::Unit*>(self)->attachAction(*str_from(name)));
}
static void platformer_unit_remove_action(int64_t self, int64_t name) {
	r_cast<Platformer::Unit*>(self)->removeAction(*str_from(name));
}
static void platformer_unit_remove_all_actions(int64_t self) {
	r_cast<Platformer::Unit*>(self)->removeAllActions();
}
static int64_t platformer_unit_get_action(int64_t self, int64_t name) {
	return r_cast<int64_t>(r_cast<Platformer::Unit*>(self)->getAction(*str_from(name)));
}
static void platformer_unit_each_action(int64_t self, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	r_cast<Platformer::Unit*>(self)->eachAction([func, args, deref](Platformer::UnitAction* action) {
		args->clear();
		args->push(r_cast<int64_t>(action));
		SharedWasmRuntime.invoke(func);
	});
}
static int32_t platformer_unit_start(int64_t self, int64_t name) {
	return r_cast<Platformer::Unit*>(self)->start(*str_from(name)) ? 1 : 0;
}
static void platformer_unit_stop(int64_t self) {
	r_cast<Platformer::Unit*>(self)->stop();
}
static int32_t platformer_unit_is_doing(int64_t self, int64_t name) {
	return r_cast<Platformer::Unit*>(self)->isDoing(*str_from(name)) ? 1 : 0;
}
static int64_t platformer_unit_new(int64_t unit_def, int64_t physicsworld, int64_t entity, int64_t pos, float rot) {
	return from_object(Platformer::Unit::create(r_cast<Dictionary*>(unit_def), r_cast<PhysicsWorld*>(physicsworld), r_cast<Entity*>(entity), vec2_from(pos), rot));
}
static int64_t platformer_unit_with_store(int64_t def_name, int64_t world_name, int64_t entity, int64_t pos, float rot) {
	return from_object(Platformer::Unit::create(*str_from(def_name), *str_from(world_name), r_cast<Entity*>(entity), vec2_from(pos), rot));
}
static void linkPlatformerUnit(wasm3::module3& mod) {
	mod.link_optional("*", "platformer_unit_type", platformer_unit_type);
	mod.link_optional("*", "platformer_unit_set_playable", platformer_unit_set_playable);
	mod.link_optional("*", "platformer_unit_get_playable", platformer_unit_get_playable);
	mod.link_optional("*", "platformer_unit_set_detect_distance", platformer_unit_set_detect_distance);
	mod.link_optional("*", "platformer_unit_get_detect_distance", platformer_unit_get_detect_distance);
	mod.link_optional("*", "platformer_unit_set_attack_range", platformer_unit_set_attack_range);
	mod.link_optional("*", "platformer_unit_get_attack_range", platformer_unit_get_attack_range);
	mod.link_optional("*", "platformer_unit_set_face_right", platformer_unit_set_face_right);
	mod.link_optional("*", "platformer_unit_is_face_right", platformer_unit_is_face_right);
	mod.link_optional("*", "platformer_unit_set_receiving_decision_trace", platformer_unit_set_receiving_decision_trace);
	mod.link_optional("*", "platformer_unit_is_receiving_decision_trace", platformer_unit_is_receiving_decision_trace);
	mod.link_optional("*", "platformer_unit_set_decision_tree", platformer_unit_set_decision_tree);
	mod.link_optional("*", "platformer_unit_get_decision_tree", platformer_unit_get_decision_tree);
	mod.link_optional("*", "platformer_unit_is_on_surface", platformer_unit_is_on_surface);
	mod.link_optional("*", "platformer_unit_get_ground_sensor", platformer_unit_get_ground_sensor);
	mod.link_optional("*", "platformer_unit_get_detect_sensor", platformer_unit_get_detect_sensor);
	mod.link_optional("*", "platformer_unit_get_attack_sensor", platformer_unit_get_attack_sensor);
	mod.link_optional("*", "platformer_unit_get_unit_def", platformer_unit_get_unit_def);
	mod.link_optional("*", "platformer_unit_get_current_action", platformer_unit_get_current_action);
	mod.link_optional("*", "platformer_unit_get_width", platformer_unit_get_width);
	mod.link_optional("*", "platformer_unit_get_height", platformer_unit_get_height);
	mod.link_optional("*", "platformer_unit_get_entity", platformer_unit_get_entity);
	mod.link_optional("*", "platformer_unit_attach_action", platformer_unit_attach_action);
	mod.link_optional("*", "platformer_unit_remove_action", platformer_unit_remove_action);
	mod.link_optional("*", "platformer_unit_remove_all_actions", platformer_unit_remove_all_actions);
	mod.link_optional("*", "platformer_unit_get_action", platformer_unit_get_action);
	mod.link_optional("*", "platformer_unit_each_action", platformer_unit_each_action);
	mod.link_optional("*", "platformer_unit_start", platformer_unit_start);
	mod.link_optional("*", "platformer_unit_stop", platformer_unit_stop);
	mod.link_optional("*", "platformer_unit_is_doing", platformer_unit_is_doing);
	mod.link_optional("*", "platformer_unit_new", platformer_unit_new);
	mod.link_optional("*", "platformer_unit_with_store", platformer_unit_with_store);
}