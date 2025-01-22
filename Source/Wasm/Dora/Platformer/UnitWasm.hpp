/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t platformer_unit_type() {
	return DoraType<Platformer::Unit>();
}
void platformer_unit_set_playable(int64_t self, int64_t val) {
	r_cast<Platformer::Unit*>(self)->setPlayable(r_cast<Playable*>(val));
}
int64_t platformer_unit_get_playable(int64_t self) {
	return Object_From(r_cast<Platformer::Unit*>(self)->getPlayable());
}
void platformer_unit_set_detect_distance(int64_t self, float val) {
	r_cast<Platformer::Unit*>(self)->setDetectDistance(val);
}
float platformer_unit_get_detect_distance(int64_t self) {
	return r_cast<Platformer::Unit*>(self)->getDetectDistance();
}
void platformer_unit_set_attack_range(int64_t self, int64_t val) {
	r_cast<Platformer::Unit*>(self)->setAttackRange(Size_From(val));
}
int64_t platformer_unit_get_attack_range(int64_t self) {
	return Size_Retain(r_cast<Platformer::Unit*>(self)->getAttackRange());
}
void platformer_unit_set_face_right(int64_t self, int32_t val) {
	r_cast<Platformer::Unit*>(self)->setFaceRight(val != 0);
}
int32_t platformer_unit_is_face_right(int64_t self) {
	return r_cast<Platformer::Unit*>(self)->isFaceRight() ? 1 : 0;
}
void platformer_unit_set_receiving_decision_trace(int64_t self, int32_t val) {
	r_cast<Platformer::Unit*>(self)->setReceivingDecisionTrace(val != 0);
}
int32_t platformer_unit_is_receiving_decision_trace(int64_t self) {
	return r_cast<Platformer::Unit*>(self)->isReceivingDecisionTrace() ? 1 : 0;
}
void platformer_unit_set_decision_tree(int64_t self, int64_t val) {
	r_cast<Platformer::Unit*>(self)->setDecisionTreeName(*Str_From(val));
}
int64_t platformer_unit_get_decision_tree(int64_t self) {
	return Str_Retain(r_cast<Platformer::Unit*>(self)->getDecisionTreeName());
}
int32_t platformer_unit_is_on_surface(int64_t self) {
	return r_cast<Platformer::Unit*>(self)->isOnSurface() ? 1 : 0;
}
int64_t platformer_unit_get_ground_sensor(int64_t self) {
	return Object_From(r_cast<Platformer::Unit*>(self)->getGroundSensor());
}
int64_t platformer_unit_get_detect_sensor(int64_t self) {
	return Object_From(r_cast<Platformer::Unit*>(self)->getDetectSensor());
}
int64_t platformer_unit_get_attack_sensor(int64_t self) {
	return Object_From(r_cast<Platformer::Unit*>(self)->getAttackSensor());
}
int64_t platformer_unit_get_unit_def(int64_t self) {
	return Object_From(r_cast<Platformer::Unit*>(self)->getUnitDef());
}
int64_t platformer_unit_get_current_action(int64_t self) {
	return r_cast<int64_t>(r_cast<Platformer::Unit*>(self)->getCurrentAction());
}
float platformer_unit_get_width(int64_t self) {
	return r_cast<Platformer::Unit*>(self)->getWidth();
}
float platformer_unit_get_height(int64_t self) {
	return r_cast<Platformer::Unit*>(self)->getHeight();
}
int64_t platformer_unit_get_entity(int64_t self) {
	return Object_From(r_cast<Platformer::Unit*>(self)->getEntity());
}
int64_t platformer_unit_attach_action(int64_t self, int64_t name) {
	return r_cast<int64_t>(r_cast<Platformer::Unit*>(self)->attachAction(*Str_From(name)));
}
void platformer_unit_remove_action(int64_t self, int64_t name) {
	r_cast<Platformer::Unit*>(self)->removeAction(*Str_From(name));
}
void platformer_unit_remove_all_actions(int64_t self) {
	r_cast<Platformer::Unit*>(self)->removeAllActions();
}
int64_t platformer_unit_get_action(int64_t self, int64_t name) {
	return r_cast<int64_t>(r_cast<Platformer::Unit*>(self)->getAction(*Str_From(name)));
}
void platformer_unit_each_action(int64_t self, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	r_cast<Platformer::Unit*>(self)->eachAction([func0, args0, deref0](Platformer::UnitAction* action) {
		args0->clear();
		args0->push(r_cast<int64_t>(action));
		SharedWasmRuntime.invoke(func0);
	});
}
int32_t platformer_unit_start(int64_t self, int64_t name) {
	return r_cast<Platformer::Unit*>(self)->start(*Str_From(name)) ? 1 : 0;
}
void platformer_unit_stop(int64_t self) {
	r_cast<Platformer::Unit*>(self)->stop();
}
int32_t platformer_unit_is_doing(int64_t self, int64_t name) {
	return r_cast<Platformer::Unit*>(self)->isDoing(*Str_From(name)) ? 1 : 0;
}
int64_t platformer_unit_new(int64_t unit_def, int64_t physics_world, int64_t entity, int64_t pos, float rot) {
	return Object_From(Platformer::Unit::create(r_cast<Dictionary*>(unit_def), r_cast<PhysicsWorld*>(physics_world), r_cast<Entity*>(entity), Vec2_From(pos), rot));
}
int64_t platformer_unit_with_store(int64_t unit_def_name, int64_t physics_world_name, int64_t entity, int64_t pos, float rot) {
	return Object_From(Platformer::Unit::create(*Str_From(unit_def_name), *Str_From(physics_world_name), r_cast<Entity*>(entity), Vec2_From(pos), rot));
}
} // extern "C"

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