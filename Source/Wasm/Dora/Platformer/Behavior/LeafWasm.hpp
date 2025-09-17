/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t platformer_behavior_tree_type() {
	return DoraType<Platformer::Behavior::Leaf>();
}
DORA_EXPORT int64_t platformer_behavior_leaf_seq(int64_t nodes) {
	return Object_From(BSeq(Vec_FromBtree(nodes)));
}
DORA_EXPORT int64_t platformer_behavior_leaf_sel(int64_t nodes) {
	return Object_From(BSel(Vec_FromBtree(nodes)));
}
DORA_EXPORT int64_t platformer_behavior_leaf_con(int64_t name, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	return Object_From(BCon(*Str_From(name), [func0, args0, deref0](Platformer::Behavior::Blackboard* blackboard) {
		args0->clear();
		args0->push(r_cast<int64_t>(blackboard));
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(false);
	}));
}
DORA_EXPORT int64_t platformer_behavior_leaf_act(int64_t action_name) {
	return Object_From(BAct(*Str_From(action_name)));
}
DORA_EXPORT int64_t platformer_behavior_leaf_command(int64_t action_name) {
	return Object_From(BCommand(*Str_From(action_name)));
}
DORA_EXPORT int64_t platformer_behavior_leaf_wait(double duration) {
	return Object_From(BWait(duration));
}
DORA_EXPORT int64_t platformer_behavior_leaf_countdown(double time, int64_t node) {
	return Object_From(BCountdown(time, r_cast<Platformer::Behavior::Leaf*>(node)));
}
DORA_EXPORT int64_t platformer_behavior_leaf_timeout(double time, int64_t node) {
	return Object_From(BTimeout(time, r_cast<Platformer::Behavior::Leaf*>(node)));
}
DORA_EXPORT int64_t platformer_behavior_leaf_repeat(int32_t times, int64_t node) {
	return Object_From(BRepeat(s_cast<int>(times), r_cast<Platformer::Behavior::Leaf*>(node)));
}
DORA_EXPORT int64_t platformer_behavior_leaf_repeat_forever(int64_t node) {
	return Object_From(BRepeat(r_cast<Platformer::Behavior::Leaf*>(node)));
}
DORA_EXPORT int64_t platformer_behavior_leaf_retry(int32_t times, int64_t node) {
	return Object_From(BRetry(s_cast<int>(times), r_cast<Platformer::Behavior::Leaf*>(node)));
}
DORA_EXPORT int64_t platformer_behavior_leaf_retry_until_pass(int64_t node) {
	return Object_From(BRetry(r_cast<Platformer::Behavior::Leaf*>(node)));
}
} // extern "C"

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