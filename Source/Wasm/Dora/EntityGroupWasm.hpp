static int32_t group_type() {
	return DoraType<EntityGroup>();
}
static int32_t entitygroup_get_count(int64_t self) {
	return s_cast<int32_t>(r_cast<EntityGroup*>(self)->getCount());
}
static int64_t entitygroup_find(int64_t self, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	return from_object(r_cast<EntityGroup*>(self)->find([func, args, deref](Entity* e) {
		args->clear();
		args->push(e);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	}));
}
static int64_t entitygroup_new(int64_t components) {
	return from_object(EntityGroup::create(from_str_vec(components)));
}
static void linkEntityGroup(wasm3::module& mod) {
	mod.link_optional("*", "group_type", group_type);
	mod.link_optional("*", "entitygroup_get_count", entitygroup_get_count);
	mod.link_optional("*", "entitygroup_find", entitygroup_find);
	mod.link_optional("*", "entitygroup_new", entitygroup_new);
}