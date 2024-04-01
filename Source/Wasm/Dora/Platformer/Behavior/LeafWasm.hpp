static int32_t platformer_behavior_tree_type() {
	return DoraType<Platformer::Behavior::Leaf>();
}
static int64_t platformer_behavior_leaf_seq(int64_t nodes) {
	return from_object(BSeq(from_btree_vec(nodes)));
}
static int64_t platformer_behavior_leaf_sel(int64_t nodes) {
	return from_object(BSel(from_btree_vec(nodes)));
}
static int64_t platformer_behavior_leaf_con(int64_t name, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	return from_object(BCon(*str_from(name), [func, args, deref](Platformer::Behavior::Blackboard* blackboard) {
		args->clear();
		args->push(r_cast<int64_t>(blackboard));
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	}));
}
static int64_t platformer_behavior_leaf_act(int64_t action_name) {
	return from_object(BAct(*str_from(action_name)));
}
static int64_t platformer_behavior_leaf_command(int64_t action_name) {
	return from_object(BCommand(*str_from(action_name)));
}
static int64_t platformer_behavior_leaf_wait(double duration) {
	return from_object(BWait(duration));
}
static int64_t platformer_behavior_leaf_countdown(double time, int64_t node) {
	return from_object(BCountdown(time, r_cast<Platformer::Behavior::Leaf*>(node)));
}
static int64_t platformer_behavior_leaf_timeout(double time, int64_t node) {
	return from_object(BTimeout(time, r_cast<Platformer::Behavior::Leaf*>(node)));
}
static int64_t platformer_behavior_leaf_repeat(int32_t times, int64_t node) {
	return from_object(BRepeat(s_cast<int>(times), r_cast<Platformer::Behavior::Leaf*>(node)));
}
static int64_t platformer_behavior_leaf_repeat_forever(int64_t node) {
	return from_object(BRepeat(r_cast<Platformer::Behavior::Leaf*>(node)));
}
static int64_t platformer_behavior_leaf_retry(int32_t times, int64_t node) {
	return from_object(BRetry(s_cast<int>(times), r_cast<Platformer::Behavior::Leaf*>(node)));
}
static int64_t platformer_behavior_leaf_retry_until_pass(int64_t node) {
	return from_object(BRetry(r_cast<Platformer::Behavior::Leaf*>(node)));
}
static void linkPlatformerBehaviorLeaf(wasm3::module3& mod) {
	mod.link_optional("*", "platformer_behavior_tree_type", platformer_behavior_tree_type);
	mod.link_optional("*", "platformer_behavior_leaf_seq", platformer_behavior_leaf_seq);
	mod.link_optional("*", "platformer_behavior_leaf_sel", platformer_behavior_leaf_sel);
	mod.link_optional("*", "platformer_behavior_leaf_con", platformer_behavior_leaf_con);
	mod.link_optional("*", "platformer_behavior_leaf_act", platformer_behavior_leaf_act);
	mod.link_optional("*", "platformer_behavior_leaf_command", platformer_behavior_leaf_command);
	mod.link_optional("*", "platformer_behavior_leaf_wait", platformer_behavior_leaf_wait);
	mod.link_optional("*", "platformer_behavior_leaf_countdown", platformer_behavior_leaf_countdown);
	mod.link_optional("*", "platformer_behavior_leaf_timeout", platformer_behavior_leaf_timeout);
	mod.link_optional("*", "platformer_behavior_leaf_repeat", platformer_behavior_leaf_repeat);
	mod.link_optional("*", "platformer_behavior_leaf_repeat_forever", platformer_behavior_leaf_repeat_forever);
	mod.link_optional("*", "platformer_behavior_leaf_retry", platformer_behavior_leaf_retry);
	mod.link_optional("*", "platformer_behavior_leaf_retry_until_pass", platformer_behavior_leaf_retry_until_pass);
}