/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t audiobus_type() {
	return DoraType<AudioBus>();
}
DORA_EXPORT void audiobus_set_volume(int64_t self, float val) {
	r_cast<AudioBus*>(self)->setVolume(val);
}
DORA_EXPORT float audiobus_get_volume(int64_t self) {
	return r_cast<AudioBus*>(self)->getVolume();
}
DORA_EXPORT void audiobus_set_pan(int64_t self, float val) {
	r_cast<AudioBus*>(self)->setPan(val);
}
DORA_EXPORT float audiobus_get_pan(int64_t self) {
	return r_cast<AudioBus*>(self)->getPan();
}
DORA_EXPORT void audiobus_set_play_speed(int64_t self, float val) {
	r_cast<AudioBus*>(self)->setPlaySpeed(val);
}
DORA_EXPORT float audiobus_get_play_speed(int64_t self) {
	return r_cast<AudioBus*>(self)->getPlaySpeed();
}
DORA_EXPORT void audiobus_fade_volume(int64_t self, double time, float to_volume) {
	r_cast<AudioBus*>(self)->fadeVolume(time, to_volume);
}
DORA_EXPORT void audiobus_fade_pan(int64_t self, double time, float to_pan) {
	r_cast<AudioBus*>(self)->fadePan(time, to_pan);
}
DORA_EXPORT void audiobus_fade_play_speed(int64_t self, double time, float to_play_speed) {
	r_cast<AudioBus*>(self)->fadePlaySpeed(time, to_play_speed);
}
DORA_EXPORT void audiobus_set_filter(int64_t self, int32_t index, int64_t name) {
	r_cast<AudioBus*>(self)->setFilter(s_cast<uint32_t>(index), *Str_From(name));
}
DORA_EXPORT void audiobus_set_filter_parameter(int64_t self, int32_t index, int32_t attr_id, float value) {
	r_cast<AudioBus*>(self)->setFilterParameter(s_cast<uint32_t>(index), s_cast<uint32_t>(attr_id), value);
}
DORA_EXPORT float audiobus_get_filter_parameter(int64_t self, int32_t index, int32_t attr_id) {
	return r_cast<AudioBus*>(self)->getFilterParameter(s_cast<uint32_t>(index), s_cast<uint32_t>(attr_id));
}
DORA_EXPORT void audiobus_fade_filter_parameter(int64_t self, int32_t index, int32_t attr_id, float to, double time) {
	r_cast<AudioBus*>(self)->fadeFilterParameter(s_cast<uint32_t>(index), s_cast<uint32_t>(attr_id), to, time);
}
DORA_EXPORT int64_t audiobus_new() {
	return Object_From(AudioBus::create());
}
} // extern "C"

static void linkAudioBus(wasm3::module3& mod) {
	mod.link_optional("*", "audiobus_type", audiobus_type);
	mod.link_optional("*", "audiobus_set_volume", audiobus_set_volume);
	mod.link_optional("*", "audiobus_get_volume", audiobus_get_volume);
	mod.link_optional("*", "audiobus_set_pan", audiobus_set_pan);
	mod.link_optional("*", "audiobus_get_pan", audiobus_get_pan);
	mod.link_optional("*", "audiobus_set_play_speed", audiobus_set_play_speed);
	mod.link_optional("*", "audiobus_get_play_speed", audiobus_get_play_speed);
	mod.link_optional("*", "audiobus_fade_volume", audiobus_fade_volume);
	mod.link_optional("*", "audiobus_fade_pan", audiobus_fade_pan);
	mod.link_optional("*", "audiobus_fade_play_speed", audiobus_fade_play_speed);
	mod.link_optional("*", "audiobus_set_filter", audiobus_set_filter);
	mod.link_optional("*", "audiobus_set_filter_parameter", audiobus_set_filter_parameter);
	mod.link_optional("*", "audiobus_get_filter_parameter", audiobus_get_filter_parameter);
	mod.link_optional("*", "audiobus_fade_filter_parameter", audiobus_fade_filter_parameter);
	mod.link_optional("*", "audiobus_new", audiobus_new);
}