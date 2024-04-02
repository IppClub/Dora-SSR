/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static int32_t scheduler_type() {
	return DoraType<Scheduler>();
}
static void scheduler_set_time_scale(int64_t self, float var) {
	r_cast<Scheduler*>(self)->setTimeScale(var);
}
static float scheduler_get_time_scale(int64_t self) {
	return r_cast<Scheduler*>(self)->getTimeScale();
}
static void scheduler_set_fixed_fps(int64_t self, int32_t var) {
	r_cast<Scheduler*>(self)->setFixedFPS(s_cast<int>(var));
}
static int32_t scheduler_get_fixed_fps(int64_t self) {
	return s_cast<int32_t>(r_cast<Scheduler*>(self)->getFixedFPS());
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
static void linkScheduler(wasm3::module3& mod) {
	mod.link_optional("*", "scheduler_type", scheduler_type);
	mod.link_optional("*", "scheduler_set_time_scale", scheduler_set_time_scale);
	mod.link_optional("*", "scheduler_get_time_scale", scheduler_get_time_scale);
	mod.link_optional("*", "scheduler_set_fixed_fps", scheduler_set_fixed_fps);
	mod.link_optional("*", "scheduler_get_fixed_fps", scheduler_get_fixed_fps);
	mod.link_optional("*", "scheduler_schedule", scheduler_schedule);
	mod.link_optional("*", "scheduler_new", scheduler_new);
}