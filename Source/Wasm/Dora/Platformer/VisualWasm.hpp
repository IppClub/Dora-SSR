/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t platformer_visual_type() {
	return DoraType<Platformer::Visual>();
}
DORA_EXPORT int32_t platformer_visual_is_playing(int64_t self) {
	return r_cast<Platformer::Visual*>(self)->isPlaying() ? 1 : 0;
}
DORA_EXPORT void platformer_visual_start(int64_t self) {
	r_cast<Platformer::Visual*>(self)->start();
}
DORA_EXPORT void platformer_visual_stop(int64_t self) {
	r_cast<Platformer::Visual*>(self)->stop();
}
DORA_EXPORT int64_t platformer_visual_auto_remove(int64_t self) {
	return Object_From(r_cast<Platformer::Visual*>(self)->autoRemove());
}
DORA_EXPORT int64_t platformer_visual_new(int64_t name) {
	return Object_From(Platformer::Visual::create(*Str_From(name)));
}
} // extern "C"

static void linkPlatformerVisual(wasm3::module3& mod) {
	mod.link_optional("*", "platformer_visual_type", platformer_visual_type);
	mod.link_optional("*", "platformer_visual_is_playing", platformer_visual_is_playing);
	mod.link_optional("*", "platformer_visual_start", platformer_visual_start);
	mod.link_optional("*", "platformer_visual_stop", platformer_visual_stop);
	mod.link_optional("*", "platformer_visual_auto_remove", platformer_visual_auto_remove);
	mod.link_optional("*", "platformer_visual_new", platformer_visual_new);
}