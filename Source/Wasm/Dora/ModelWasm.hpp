/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t model_type() {
	return DoraType<Model>();
}
DORA_EXPORT float model_get_duration(int64_t self) {
	return r_cast<Model*>(self)->getDuration();
}
DORA_EXPORT void model_set_reversed(int64_t self, int32_t val) {
	r_cast<Model*>(self)->setReversed(val != 0);
}
DORA_EXPORT int32_t model_is_reversed(int64_t self) {
	return r_cast<Model*>(self)->isReversed() ? 1 : 0;
}
DORA_EXPORT int32_t model_is_playing(int64_t self) {
	return r_cast<Model*>(self)->isPlaying() ? 1 : 0;
}
DORA_EXPORT int32_t model_is_paused(int64_t self) {
	return r_cast<Model*>(self)->isPaused() ? 1 : 0;
}
DORA_EXPORT int32_t model_has_animation(int64_t self, int64_t name) {
	return r_cast<Model*>(self)->hasAnimation(*Str_From(name)) ? 1 : 0;
}
DORA_EXPORT void model_pause(int64_t self) {
	r_cast<Model*>(self)->pause();
}
DORA_EXPORT void model_resume(int64_t self) {
	r_cast<Model*>(self)->resume();
}
DORA_EXPORT void model_resume_animation(int64_t self, int64_t name, int32_t looping) {
	r_cast<Model*>(self)->resume(*Str_From(name), looping != 0);
}
DORA_EXPORT void model_reset(int64_t self) {
	r_cast<Model*>(self)->reset();
}
DORA_EXPORT void model_update_to(int64_t self, float elapsed, int32_t reversed) {
	r_cast<Model*>(self)->updateTo(elapsed, reversed != 0);
}
DORA_EXPORT int64_t model_get_node_by_name(int64_t self, int64_t name) {
	return Object_From(r_cast<Model*>(self)->getNodeByName(*Str_From(name)));
}
DORA_EXPORT int32_t model_each_node(int64_t self, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	return r_cast<Model*>(self)->eachNode([func0, args0, deref0](Node* node) {
		args0->clear();
		args0->push(node);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(false);
	}) ? 1 : 0;
}
DORA_EXPORT int64_t model_new(int64_t filename) {
	return Object_From(Model::create(*Str_From(filename)));
}
DORA_EXPORT int64_t model_dummy() {
	return Object_From(Model::dummy());
}
DORA_EXPORT int64_t model_get_clip_file(int64_t filename) {
	return Str_Retain(Model_GetClipFilename(*Str_From(filename)));
}
DORA_EXPORT int64_t model_get_looks(int64_t filename) {
	return Vec_To(Model_GetLookNames(*Str_From(filename)));
}
DORA_EXPORT int64_t model_get_animations(int64_t filename) {
	return Vec_To(Model_GetAnimationNames(*Str_From(filename)));
}
} // extern "C"

static void linkModel(wasm3::module3& mod) {
	mod.link_optional("*", "model_type", model_type);
	mod.link_optional("*", "model_get_duration", model_get_duration);
	mod.link_optional("*", "model_set_reversed", model_set_reversed);
	mod.link_optional("*", "model_is_reversed", model_is_reversed);
	mod.link_optional("*", "model_is_playing", model_is_playing);
	mod.link_optional("*", "model_is_paused", model_is_paused);
	mod.link_optional("*", "model_has_animation", model_has_animation);
	mod.link_optional("*", "model_pause", model_pause);
	mod.link_optional("*", "model_resume", model_resume);
	mod.link_optional("*", "model_resume_animation", model_resume_animation);
	mod.link_optional("*", "model_reset", model_reset);
	mod.link_optional("*", "model_update_to", model_update_to);
	mod.link_optional("*", "model_get_node_by_name", model_get_node_by_name);
	mod.link_optional("*", "model_each_node", model_each_node);
	mod.link_optional("*", "model_new", model_new);
	mod.link_optional("*", "model_dummy", model_dummy);
	mod.link_optional("*", "model_get_clip_file", model_get_clip_file);
	mod.link_optional("*", "model_get_looks", model_get_looks);
	mod.link_optional("*", "model_get_animations", model_get_animations);
}