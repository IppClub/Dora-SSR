/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t scheduler_type() {
	return DoraType<Scheduler>();
}
DORA_EXPORT void scheduler_set_time_scale(int64_t self, float val) {
	r_cast<Scheduler*>(self)->setTimeScale(val);
}
DORA_EXPORT float scheduler_get_time_scale(int64_t self) {
	return r_cast<Scheduler*>(self)->getTimeScale();
}
DORA_EXPORT void scheduler_set_fixed_fps(int64_t self, int32_t val) {
	r_cast<Scheduler*>(self)->setFixedFPS(s_cast<int>(val));
}
DORA_EXPORT int32_t scheduler_get_fixed_fps(int64_t self) {
	return s_cast<int32_t>(r_cast<Scheduler*>(self)->getFixedFPS());
}
DORA_EXPORT int32_t scheduler_update(int64_t self, double delta_time) {
	return r_cast<Scheduler*>(self)->update(delta_time) ? 1 : 0;
}
DORA_EXPORT int64_t scheduler_new() {
	return Object_From(Scheduler::create());
}
} // extern "C"

static void linkScheduler(wasm3::module3& mod) {
	mod.link_optional("*", "scheduler_type", scheduler_type);
	mod.link_optional("*", "scheduler_set_time_scale", scheduler_set_time_scale);
	mod.link_optional("*", "scheduler_get_time_scale", scheduler_get_time_scale);
	mod.link_optional("*", "scheduler_set_fixed_fps", scheduler_set_fixed_fps);
	mod.link_optional("*", "scheduler_get_fixed_fps", scheduler_get_fixed_fps);
	mod.link_optional("*", "scheduler_update", scheduler_update);
	mod.link_optional("*", "scheduler_new", scheduler_new);
}