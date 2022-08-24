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
static void linkPlatformerDecisionAI(wasm3::module& mod) {
	mod.link_optional("*", "platformer_decision_ai_get_units_by_relation", platformer_decision_ai_get_units_by_relation);
	mod.link_optional("*", "platformer_decision_ai_get_detected_units", platformer_decision_ai_get_detected_units);
	mod.link_optional("*", "platformer_decision_ai_get_detected_bodies", platformer_decision_ai_get_detected_bodies);
	mod.link_optional("*", "platformer_decision_ai_get_nearest_unit", platformer_decision_ai_get_nearest_unit);
	mod.link_optional("*", "platformer_decision_ai_get_nearest_unit_distance", platformer_decision_ai_get_nearest_unit_distance);
	mod.link_optional("*", "platformer_decision_ai_get_units_in_attack_range", platformer_decision_ai_get_units_in_attack_range);
	mod.link_optional("*", "platformer_decision_ai_get_bodies_in_attack_range", platformer_decision_ai_get_bodies_in_attack_range);
}