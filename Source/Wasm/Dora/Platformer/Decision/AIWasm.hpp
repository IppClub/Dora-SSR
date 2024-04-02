/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static int64_t platformer_decision_ai_get_units_by_relation(int32_t relation) {
	return from_object(SharedAI.getUnitsByRelation(s_cast<Platformer::Relation>(relation)));
}
static int64_t platformer_decision_ai_get_detected_units() {
	return from_object(SharedAI.getDetectedUnits());
}
static int64_t platformer_decision_ai_get_detected_bodies() {
	return from_object(SharedAI.getDetectedBodies());
}
static int64_t platformer_decision_ai_get_nearest_unit(int32_t relation) {
	return from_object(SharedAI.getNearestUnit(s_cast<Platformer::Relation>(relation)));
}
static float platformer_decision_ai_get_nearest_unit_distance(int32_t relation) {
	return SharedAI.getNearestUnitDistance(s_cast<Platformer::Relation>(relation));
}
static int64_t platformer_decision_ai_get_units_in_attack_range() {
	return from_object(SharedAI.getUnitsInAttackRange());
}
static int64_t platformer_decision_ai_get_bodies_in_attack_range() {
	return from_object(SharedAI.getBodiesInAttackRange());
}
static void linkPlatformerDecisionAI(wasm3::module3& mod) {
	mod.link_optional("*", "platformer_decision_ai_get_units_by_relation", platformer_decision_ai_get_units_by_relation);
	mod.link_optional("*", "platformer_decision_ai_get_detected_units", platformer_decision_ai_get_detected_units);
	mod.link_optional("*", "platformer_decision_ai_get_detected_bodies", platformer_decision_ai_get_detected_bodies);
	mod.link_optional("*", "platformer_decision_ai_get_nearest_unit", platformer_decision_ai_get_nearest_unit);
	mod.link_optional("*", "platformer_decision_ai_get_nearest_unit_distance", platformer_decision_ai_get_nearest_unit_distance);
	mod.link_optional("*", "platformer_decision_ai_get_units_in_attack_range", platformer_decision_ai_get_units_in_attack_range);
	mod.link_optional("*", "platformer_decision_ai_get_bodies_in_attack_range", platformer_decision_ai_get_bodies_in_attack_range);
}