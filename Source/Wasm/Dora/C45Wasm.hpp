static void c45_build_decision_tree_async(int64_t data, int32_t max_depth, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	MLBuildDecisionTreeAsync(*str_from(data), s_cast<int>(max_depth), [func, args, deref](double depth, String name, String op, String value) {
		args->clear();
		args->push(depth);
		args->push(name);
		args->push(op);
		args->push(value);
		SharedWasmRuntime.invoke(func);
	});
}
static void linkC45(wasm3::module& mod) {
	mod.link_optional("*", "c45_build_decision_tree_async", c45_build_decision_tree_async);
}