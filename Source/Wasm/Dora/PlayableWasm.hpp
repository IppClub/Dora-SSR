/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t playable_type() {
	return DoraType<Playable>();
}
DORA_EXPORT void playable_set_look(int64_t self, int64_t val) {
	r_cast<Playable*>(self)->setLook(*Str_From(val));
}
DORA_EXPORT int64_t playable_get_look(int64_t self) {
	return Str_Retain(r_cast<Playable*>(self)->getLook());
}
DORA_EXPORT void playable_set_speed(int64_t self, float val) {
	r_cast<Playable*>(self)->setSpeed(val);
}
DORA_EXPORT float playable_get_speed(int64_t self) {
	return r_cast<Playable*>(self)->getSpeed();
}
DORA_EXPORT void playable_set_recovery(int64_t self, float val) {
	r_cast<Playable*>(self)->setRecovery(val);
}
DORA_EXPORT float playable_get_recovery(int64_t self) {
	return r_cast<Playable*>(self)->getRecovery();
}
DORA_EXPORT void playable_set_fliped(int64_t self, int32_t val) {
	r_cast<Playable*>(self)->setFliped(val != 0);
}
DORA_EXPORT int32_t playable_is_fliped(int64_t self) {
	return r_cast<Playable*>(self)->isFliped() ? 1 : 0;
}
DORA_EXPORT int64_t playable_get_current(int64_t self) {
	return Str_Retain(r_cast<Playable*>(self)->getCurrent());
}
DORA_EXPORT int64_t playable_get_last_completed(int64_t self) {
	return Str_Retain(r_cast<Playable*>(self)->getLastCompleted());
}
DORA_EXPORT int64_t playable_get_key(int64_t self, int64_t name) {
	return Vec2_Retain(r_cast<Playable*>(self)->getKeyPoint(*Str_From(name)));
}
DORA_EXPORT float playable_play(int64_t self, int64_t name, int32_t looping) {
	return r_cast<Playable*>(self)->play(*Str_From(name), looping != 0);
}
DORA_EXPORT void playable_stop(int64_t self) {
	r_cast<Playable*>(self)->stop();
}
DORA_EXPORT void playable_set_slot(int64_t self, int64_t name, int64_t item) {
	r_cast<Playable*>(self)->setSlot(*Str_From(name), r_cast<Node*>(item));
}
DORA_EXPORT int64_t playable_get_slot(int64_t self, int64_t name) {
	return Object_From(r_cast<Playable*>(self)->getSlot(*Str_From(name)));
}
DORA_EXPORT int64_t playable_new(int64_t filename) {
	return Object_From(Playable::create(*Str_From(filename)));
}
} // extern "C"

static void linkPlayable(wasm3::module3& mod) {
	mod.link_optional("*", "playable_type", playable_type);
	mod.link_optional("*", "playable_set_look", playable_set_look);
	mod.link_optional("*", "playable_get_look", playable_get_look);
	mod.link_optional("*", "playable_set_speed", playable_set_speed);
	mod.link_optional("*", "playable_get_speed", playable_get_speed);
	mod.link_optional("*", "playable_set_recovery", playable_set_recovery);
	mod.link_optional("*", "playable_get_recovery", playable_get_recovery);
	mod.link_optional("*", "playable_set_fliped", playable_set_fliped);
	mod.link_optional("*", "playable_is_fliped", playable_is_fliped);
	mod.link_optional("*", "playable_get_current", playable_get_current);
	mod.link_optional("*", "playable_get_last_completed", playable_get_last_completed);
	mod.link_optional("*", "playable_get_key", playable_get_key);
	mod.link_optional("*", "playable_play", playable_play);
	mod.link_optional("*", "playable_stop", playable_stop);
	mod.link_optional("*", "playable_set_slot", playable_set_slot);
	mod.link_optional("*", "playable_get_slot", playable_get_slot);
	mod.link_optional("*", "playable_new", playable_new);
}