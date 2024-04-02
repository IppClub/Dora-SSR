/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static int32_t platformer_decision_tree_type() {
	return DoraType<Platformer::Decision::Leaf>();
}
static int64_t platformer_decision_leaf_sel(int64_t nodes) {
	return from_object(DSel(from_dtree_vec(nodes)));
}
static int64_t platformer_decision_leaf_seq(int64_t nodes) {
	return from_object(DSeq(from_dtree_vec(nodes)));
}
static int64_t platformer_decision_leaf_con(int64_t name, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	return from_object(DCon(*str_from(name), [func, args, deref](Platformer::Unit* unit) {
		args->clear();
		args->push(unit);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	}));
}
static int64_t platformer_decision_leaf_act(int64_t action_name) {
	return from_object(DAct(*str_from(action_name)));
}
static int64_t platformer_decision_leaf_act_dynamic(int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	return from_object(DAct([func, args, deref](Platformer::Unit* unit) {
		args->clear();
		args->push(unit);
		SharedWasmRuntime.invoke(func);
		return std::get<std::string>(args->pop());
	}));
}
static int64_t platformer_decision_leaf_accept() {
	return from_object(DAccept());
}
static int64_t platformer_decision_leaf_reject() {
	return from_object(DReject());
}
static int64_t platformer_decision_leaf_behave(int64_t name, int64_t root) {
	return from_object(DBehave(*str_from(name), r_cast<Platformer::Behavior::Leaf*>(root)));
}
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