static int32_t platformer_decision_tree_type()
{
	return DoraType<Platformer::Decision::Leaf>();
}
static int64_t platformer_decision_leaf_sel(int64_t nodes)
{
	return from_object(DSel(from_dtree_vec(nodes)));
}
static int64_t platformer_decision_leaf_seq(int64_t nodes)
{
	return from_object(DSeq(from_dtree_vec(nodes)));
}
static int64_t platformer_decision_leaf_con(int64_t name, int32_t func, int64_t stack)
{
	std::shared_ptr<void> deref(nullptr, [func](auto)
	{
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	return from_object(DCon(*str_from(name), [func, args, deref](Platformer::Unit* unit)
	{
		args->clear();
		args->push(unit);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	}));
}
static int64_t platformer_decision_leaf_act(int64_t action)
{
	return from_object(DAct(*str_from(action)));
}
static int64_t platformer_decision_leaf_act_dynamic(int32_t func, int64_t stack)
{
	std::shared_ptr<void> deref(nullptr, [func](auto)
	{
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	return from_object(DAct([func, args, deref](Platformer::Unit* unit)
	{
		args->clear();
		args->push(unit);
		SharedWasmRuntime.invoke(func);
		return std::get<std::string>(args->pop());
	}));
}
static int64_t platformer_decision_leaf_accept()
{
	return from_object(DAccept());
}
static int64_t platformer_decision_leaf_reject()
{
	return from_object(DReject());
}
static int64_t platformer_decision_leaf_behave(int64_t name, int64_t root)
{
	return from_object(DBehave(*str_from(name), r_cast<Platformer::Behavior::Leaf*>(root)));
}
static void linkPlatformerDecisionLeaf(wasm3::module& mod)
{
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