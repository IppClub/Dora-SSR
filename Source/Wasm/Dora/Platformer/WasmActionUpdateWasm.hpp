static void platformer_actionupdate_release(int64_t raw) {
	delete r_cast<Platformer::WasmActionUpdate*>(raw);
}
static int64_t platformer_wasmactionupdate_new(int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	return r_cast<int64_t>(new Platformer::WasmActionUpdate{[func, args, deref](Platformer::Unit* owner, Platformer::UnitAction* action, float deltaTime) {
		args->clear();
		args->push(owner);
		args->push(r_cast<int64_t>(action));
		args->push(deltaTime);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	}});
}
static void linkPlatformerWasmActionUpdate(wasm3::module& mod) {
	mod.link_optional("*", "platformer_actionupdate_release", platformer_actionupdate_release);
	mod.link_optional("*", "platformer_wasmactionupdate_new", platformer_wasmactionupdate_new);
}