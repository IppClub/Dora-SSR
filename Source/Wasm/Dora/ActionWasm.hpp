/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t action_type() {
	return DoraType<Action>();
}
float action_get_duration(int64_t self) {
	return r_cast<Action*>(self)->getDuration();
}
int32_t action_is_running(int64_t self) {
	return r_cast<Action*>(self)->isRunning() ? 1 : 0;
}
int32_t action_is_paused(int64_t self) {
	return r_cast<Action*>(self)->isPaused() ? 1 : 0;
}
void action_set_reversed(int64_t self, int32_t val) {
	r_cast<Action*>(self)->setReversed(val != 0);
}
int32_t action_is_reversed(int64_t self) {
	return r_cast<Action*>(self)->isReversed() ? 1 : 0;
}
void action_set_speed(int64_t self, float val) {
	r_cast<Action*>(self)->setSpeed(val);
}
float action_get_speed(int64_t self) {
	return r_cast<Action*>(self)->getSpeed();
}
void action_pause(int64_t self) {
	r_cast<Action*>(self)->pause();
}
void action_resume(int64_t self) {
	r_cast<Action*>(self)->resume();
}
void action_update_to(int64_t self, float elapsed, int32_t reversed) {
	r_cast<Action*>(self)->updateTo(elapsed, reversed != 0);
}
int64_t action_new(int64_t def) {
	return Object_From(Action::create(std::move(*r_cast<ActionDef*>(def))));
}
} // extern "C"

static void linkAction(wasm3::module3& mod) {
	mod.link_optional("*", "action_type", action_type);
	mod.link_optional("*", "action_get_duration", action_get_duration);
	mod.link_optional("*", "action_is_running", action_is_running);
	mod.link_optional("*", "action_is_paused", action_is_paused);
	mod.link_optional("*", "action_set_reversed", action_set_reversed);
	mod.link_optional("*", "action_is_reversed", action_is_reversed);
	mod.link_optional("*", "action_set_speed", action_set_speed);
	mod.link_optional("*", "action_get_speed", action_get_speed);
	mod.link_optional("*", "action_pause", action_pause);
	mod.link_optional("*", "action_resume", action_resume);
	mod.link_optional("*", "action_update_to", action_update_to);
	mod.link_optional("*", "action_new", action_new);
}