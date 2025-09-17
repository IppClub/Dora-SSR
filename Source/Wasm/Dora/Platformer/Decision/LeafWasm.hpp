/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t platformer_decision_tree_type() {
	return DoraType<Platformer::Decision::Leaf>();
}
DORA_EXPORT int64_t platformer_decision_leaf_sel(int64_t nodes) {
	return Object_From(DSel(Vec_FromDtree(nodes)));
}
DORA_EXPORT int64_t platformer_decision_leaf_seq(int64_t nodes) {
	return Object_From(DSeq(Vec_FromDtree(nodes)));
}
DORA_EXPORT int64_t platformer_decision_leaf_con(int64_t name, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	return Object_From(DCon(*Str_From(name), [func0, args0, deref0](Platformer::Unit* unit) {
		args0->clear();
		args0->push(unit);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(false);
	}));
}
DORA_EXPORT int64_t platformer_decision_leaf_act(int64_t action_name) {
	return Object_From(DAct(*Str_From(action_name)));
}
DORA_EXPORT int64_t platformer_decision_leaf_act_dynamic(int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	return Object_From(DAct([func0, args0, deref0](Platformer::Unit* unit) {
		args0->clear();
		args0->push(unit);
		SharedWasmRuntime.invoke(func0);
		return args0->empty() ? ""s : std::get<std::string>(args0->pop());
	}));
}
DORA_EXPORT int64_t platformer_decision_leaf_accept() {
	return Object_From(DAccept());
}
DORA_EXPORT int64_t platformer_decision_leaf_reject() {
	return Object_From(DReject());
}
DORA_EXPORT int64_t platformer_decision_leaf_behave(int64_t name, int64_t root) {
	return Object_From(DBehave(*Str_From(name), r_cast<Platformer::Behavior::Leaf*>(root)));
}
} // extern "C"

static void linkPlatformerDecisionLeaf(wasm3::module3& mod) {
	mod.link_optional("*", "platformer_decision_tree_type", platformer_decision_tree_type);
	mod.link_optional("*", "platformer_decision_leaf_sel", platformer_decision_leaf_sel);
	mod.link_optional("*", "platformer_decision_leaf_seq", platformer_decision_leaf_seq);
	mod.link_optional("*", "platformer_decision_leaf_con", platformer_decision_leaf_con);
	mod.link_optional("*", "platformer_decision_leaf_act", platformer_decision_leaf_act);
	mod.link_optional("*", "platformer_decision_leaf_act_dynamic", platformer_decision_leaf_act_dynamic);
	mod.link_optional("*", "platformer_decision_leaf_accept", platformer_decision_leaf_accept);
	mod.link_optional("*", "platformer_decision_leaf_reject", platformer_decision_leaf_reject);
	mod.link_optional("*", "platformer_decision_leaf_behave", platformer_decision_leaf_behave);
}