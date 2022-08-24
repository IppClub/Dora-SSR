static double platformer_behavior_blackboard_get_delta_time(int64_t self) {
	return r_cast<Platformer::Behavior::Blackboard*>(self)->getDeltaTime();
}
static int64_t platformer_behavior_blackboard_get_owner(int64_t self) {
	return from_object(r_cast<Platformer::Behavior::Blackboard*>(self)->getOwner());
}
static void linkPlatformerBehaviorBlackboard(wasm3::module& mod) {
	mod.link_optional("*", "platformer_behavior_blackboard_get_delta_time", platformer_behavior_blackboard_get_delta_time);
	mod.link_optional("*", "platformer_behavior_blackboard_get_owner", platformer_behavior_blackboard_get_owner);
}