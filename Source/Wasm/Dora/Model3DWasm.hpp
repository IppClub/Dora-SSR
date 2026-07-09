/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t model3d_type() {
	return DoraType<Model3D>();
}
DORA_EXPORT void model3d_set_speed(int64_t self, float val) {
	r_cast<Model3D*>(self)->setSpeed(val);
}
DORA_EXPORT float model3d_get_speed(int64_t self) {
	return r_cast<Model3D*>(self)->getSpeed();
}
DORA_EXPORT float model3d_get_duration(int64_t self) {
	return r_cast<Model3D*>(self)->getDuration();
}
DORA_EXPORT float model3d_get_elapsed(int64_t self) {
	return r_cast<Model3D*>(self)->getElapsed();
}
DORA_EXPORT int32_t model3d_is_playing(int64_t self) {
	return r_cast<Model3D*>(self)->isPlaying() ? 1 : 0;
}
DORA_EXPORT int32_t model3d_is_paused(int64_t self) {
	return r_cast<Model3D*>(self)->isPaused() ? 1 : 0;
}
DORA_EXPORT float model3d_play(int64_t self, int64_t name, int32_t looped) {
	return r_cast<Model3D*>(self)->play(*Str_From(name), looped != 0);
}
DORA_EXPORT void model3d_stop(int64_t self) {
	r_cast<Model3D*>(self)->stop();
}
DORA_EXPORT void model3d_pause(int64_t self) {
	r_cast<Model3D*>(self)->pause();
}
DORA_EXPORT void model3d_resume(int64_t self) {
	r_cast<Model3D*>(self)->resume();
}
DORA_EXPORT int64_t model3d_new(int64_t path) {
	return Object_From(Model3D::create(*Str_From(path)));
}
} // extern "C"

static void linkModel3D(wasm3::module3& mod) {
	mod.link_optional("*", "model3d_type", model3d_type);
	mod.link_optional("*", "model3d_set_speed", model3d_set_speed);
	mod.link_optional("*", "model3d_get_speed", model3d_get_speed);
	mod.link_optional("*", "model3d_get_duration", model3d_get_duration);
	mod.link_optional("*", "model3d_get_elapsed", model3d_get_elapsed);
	mod.link_optional("*", "model3d_is_playing", model3d_is_playing);
	mod.link_optional("*", "model3d_is_paused", model3d_is_paused);
	mod.link_optional("*", "model3d_play", model3d_play);
	mod.link_optional("*", "model3d_stop", model3d_stop);
	mod.link_optional("*", "model3d_pause", model3d_pause);
	mod.link_optional("*", "model3d_resume", model3d_resume);
	mod.link_optional("*", "model3d_new", model3d_new);
}