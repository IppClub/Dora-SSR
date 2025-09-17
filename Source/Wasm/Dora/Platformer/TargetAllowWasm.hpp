/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT void platformer_targetallow_release(int64_t raw) {
	delete r_cast<Platformer::TargetAllow*>(raw);
}
DORA_EXPORT void platformer_targetallow_set_terrain_allowed(int64_t self, int32_t val) {
	r_cast<Platformer::TargetAllow*>(self)->setTerrainAllowed(val != 0);
}
DORA_EXPORT int32_t platformer_targetallow_is_terrain_allowed(int64_t self) {
	return r_cast<Platformer::TargetAllow*>(self)->isTerrainAllowed() ? 1 : 0;
}
DORA_EXPORT void platformer_targetallow_allow(int64_t self, int32_t relation, int32_t allow) {
	r_cast<Platformer::TargetAllow*>(self)->allow(s_cast<Platformer::Relation>(relation), allow != 0);
}
DORA_EXPORT int32_t platformer_targetallow_is_allow(int64_t self, int32_t relation) {
	return r_cast<Platformer::TargetAllow*>(self)->isAllow(s_cast<Platformer::Relation>(relation)) ? 1 : 0;
}
DORA_EXPORT int32_t platformer_targetallow_to_value(int64_t self) {
	return s_cast<int32_t>(r_cast<Platformer::TargetAllow*>(self)->toValue());
}
DORA_EXPORT int64_t platformer_targetallow_new() {
	return r_cast<int64_t>(new Platformer::TargetAllow{});
}
DORA_EXPORT int64_t platformer_targetallow_with_value(int32_t value) {
	return r_cast<int64_t>(new Platformer::TargetAllow{s_cast<uint32_t>(value)});
}
} // extern "C"

static void linkPlatformerTargetAllow(wasm3::module3& mod) {
	mod.link_optional("*", "platformer_targetallow_release", platformer_targetallow_release);
	mod.link_optional("*", "platformer_targetallow_set_terrain_allowed", platformer_targetallow_set_terrain_allowed);
	mod.link_optional("*", "platformer_targetallow_is_terrain_allowed", platformer_targetallow_is_terrain_allowed);
	mod.link_optional("*", "platformer_targetallow_allow", platformer_targetallow_allow);
	mod.link_optional("*", "platformer_targetallow_is_allow", platformer_targetallow_is_allow);
	mod.link_optional("*", "platformer_targetallow_to_value", platformer_targetallow_to_value);
	mod.link_optional("*", "platformer_targetallow_new", platformer_targetallow_new);
	mod.link_optional("*", "platformer_targetallow_with_value", platformer_targetallow_with_value);
}