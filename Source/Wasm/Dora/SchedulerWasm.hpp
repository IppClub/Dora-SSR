static int32_t scheduler_type() {
	return DoraType<Scheduler>();
}
static void scheduler_set_time_scale(int64_t self, float var) {
	r_cast<Scheduler*>(self)->setTimeScale(var);
}
static float scheduler_get_time_scale(int64_t self) {
	return r_cast<Scheduler*>(self)->getTimeScale();
}
static void scheduler_schedule(int64_t self, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	r_cast<Scheduler*>(self)->schedule([func, args, deref](double deltaTime) {
		args->clear();
		args->push(deltaTime);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	});
}
static int64_t scheduler_new() {
	return from_object(Scheduler::create());
}
static void linkScheduler(wasm3::module& mod) {
	mod.link_optional("*", "scheduler_type", scheduler_type);
	mod.link_optional("*", "scheduler_set_time_scale", scheduler_set_time_scale);
	mod.link_optional("*", "scheduler_get_time_scale", scheduler_get_time_scale);
	mod.link_optional("*", "scheduler_schedule", scheduler_schedule);
	mod.link_optional("*", "scheduler_new", scheduler_new);
}