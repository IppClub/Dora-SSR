/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t touch_type() {
	return DoraType<Touch>();
}
DORA_EXPORT void touch_set_enabled(int64_t self, int32_t val) {
	r_cast<Touch*>(self)->setEnabled(val != 0);
}
DORA_EXPORT int32_t touch_is_enabled(int64_t self) {
	return r_cast<Touch*>(self)->isEnabled() ? 1 : 0;
}
DORA_EXPORT int32_t touch_is_first(int64_t self) {
	return r_cast<Touch*>(self)->isFirst() ? 1 : 0;
}
DORA_EXPORT int32_t touch_get_id(int64_t self) {
	return s_cast<int32_t>(r_cast<Touch*>(self)->getId());
}
DORA_EXPORT int64_t touch_get_delta(int64_t self) {
	return Vec2_Retain(r_cast<Touch*>(self)->getDelta());
}
DORA_EXPORT int64_t touch_get_location(int64_t self) {
	return Vec2_Retain(r_cast<Touch*>(self)->getLocation());
}
DORA_EXPORT int64_t touch_get_world_location(int64_t self) {
	return Vec2_Retain(r_cast<Touch*>(self)->getWorldLocation());
}
} // extern "C"

static void linkTouch(wasm3::module3& mod) {
	mod.link_optional("*", "touch_type", touch_type);
	mod.link_optional("*", "touch_set_enabled", touch_set_enabled);
	mod.link_optional("*", "touch_is_enabled", touch_is_enabled);
	mod.link_optional("*", "touch_is_first", touch_is_first);
	mod.link_optional("*", "touch_get_id", touch_get_id);
	mod.link_optional("*", "touch_get_delta", touch_get_delta);
	mod.link_optional("*", "touch_get_location", touch_get_location);
	mod.link_optional("*", "touch_get_world_location", touch_get_world_location);
}