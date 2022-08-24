static void platformer_unitaction_set_reaction(int64_t self, float var) {
	r_cast<Platformer::UnitAction*>(self)->reaction = s_cast<float>(var);
}
static float platformer_unitaction_get_reaction(int64_t self) {
	return r_cast<Platformer::UnitAction*>(self)->reaction;
}
static void platformer_unitaction_set_recovery(int64_t self, float var) {
	r_cast<Platformer::UnitAction*>(self)->recovery = s_cast<float>(var);
}
static float platformer_unitaction_get_recovery(int64_t self) {
	return r_cast<Platformer::UnitAction*>(self)->recovery;
}
static int64_t platformer_unitaction_get_name(int64_t self) {
	return str_retain(r_cast<Platformer::UnitAction*>(self)->getName());
}
static int32_t platformer_unitaction_is_doing(int64_t self) {
	return r_cast<Platformer::UnitAction*>(self)->isDoing() ? 1 : 0;
}
static int64_t platformer_unitaction_get_owner(int64_t self) {
	return from_object(r_cast<Platformer::UnitAction*>(self)->getOwner());
}
static float platformer_unitaction_get_eclapsed_time(int64_t self) {
	return r_cast<Platformer::UnitAction*>(self)->getEclapsedTime();
}
static void platformer_unitaction_clear() {
	Platformer::UnitAction::clear();
}
static void platformer_unitaction_add(int64_t name, int32_t priority, float reaction, float recovery, int32_t queued, int32_t func, int64_t stack, int32_t func1, int64_t stack1, int32_t func2, int64_t stack2) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	std::shared_ptr<void> deref1(nullptr, [func1](auto) {
		SharedWasmRuntime.deref(func1);
	});
	auto args1 = r_cast<CallStack*>(stack1);
	std::shared_ptr<void> deref2(nullptr, [func2](auto) {
		SharedWasmRuntime.deref(func2);
	});
	auto args2 = r_cast<CallStack*>(stack2);
	platformer_wasm_unit_action_add(*str_from(name), s_cast<int>(priority), reaction, recovery, queued != 0, [func, args, deref](Platformer::Unit* owner, Platformer::UnitAction* action) {
		args->clear();
		args->push(owner);
		args->push(r_cast<int64_t>(action));
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	}, [func1, args1, deref1](Platformer::Unit* owner, Platformer::UnitAction* action) {
		args1->clear();
		args1->push(owner);
		args1->push(r_cast<int64_t>(action));
		SharedWasmRuntime.invoke(func1);
		return *r_cast<Platformer::WasmActionUpdate*>(std::get<int64_t>(args1->pop()));
	}, [func2, args2, deref2](Platformer::Unit* owner, Platformer::UnitAction* action) {
		args2->clear();
		args2->push(owner);
		args2->push(r_cast<int64_t>(action));
		SharedWasmRuntime.invoke(func2);
	});
}
static void linkPlatformerUnitAction(wasm3::module& mod) {
	mod.link_optional("*", "platformer_unitaction_set_reaction", platformer_unitaction_set_reaction);
	mod.link_optional("*", "platformer_unitaction_get_reaction", platformer_unitaction_get_reaction);
	mod.link_optional("*", "platformer_unitaction_set_recovery", platformer_unitaction_set_recovery);
	mod.link_optional("*", "platformer_unitaction_get_recovery", platformer_unitaction_get_recovery);
	mod.link_optional("*", "platformer_unitaction_get_name", platformer_unitaction_get_name);
	mod.link_optional("*", "platformer_unitaction_is_doing", platformer_unitaction_is_doing);
	mod.link_optional("*", "platformer_unitaction_get_owner", platformer_unitaction_get_owner);
	mod.link_optional("*", "platformer_unitaction_get_eclapsed_time", platformer_unitaction_get_eclapsed_time);
	mod.link_optional("*", "platformer_unitaction_clear", platformer_unitaction_clear);
	mod.link_optional("*", "platformer_unitaction_add", platformer_unitaction_add);
}