/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT void audio_set_sound_speed(float val) {
	SharedAudio.setSoundSpeed(val);
}
DORA_EXPORT float audio_get_sound_speed() {
	return SharedAudio.getSoundSpeed();
}
DORA_EXPORT void audio_set_global_volume(float val) {
	SharedAudio.setGlobalVolume(val);
}
DORA_EXPORT float audio_get_global_volume() {
	return SharedAudio.getGlobalVolume();
}
DORA_EXPORT void audio_set_listener(int64_t val) {
	SharedAudio.setListener(r_cast<Node*>(val));
}
DORA_EXPORT int64_t audio_get_listener() {
	return Object_From(SharedAudio.getListener());
}
DORA_EXPORT int32_t audio_play(int64_t filename, int32_t looping) {
	return s_cast<int32_t>(SharedAudio.play(*Str_From(filename), looping != 0));
}
DORA_EXPORT void audio_stop(int32_t handle) {
	SharedAudio.stop(s_cast<uint32_t>(handle));
}
DORA_EXPORT void audio_play_stream(int64_t filename, int32_t looping, float cross_fade_time) {
	SharedAudio.playStream(*Str_From(filename), looping != 0, cross_fade_time);
}
DORA_EXPORT void audio_stop_stream(float fade_time) {
	SharedAudio.stopStream(fade_time);
}
DORA_EXPORT void audio_stop_all(float fade_time) {
	SharedAudio.stopAll(fade_time);
}
DORA_EXPORT void audio_set_pause_all_current(int32_t pause) {
	SharedAudio.setPauseAllCurrent(pause != 0);
}
DORA_EXPORT void audio_set_listener_at(float at_x, float at_y, float at_z) {
	SharedAudio.setListenerAt(at_x, at_y, at_z);
}
DORA_EXPORT void audio_set_listener_up(float up_x, float up_y, float up_z) {
	SharedAudio.setListenerUp(up_x, up_y, up_z);
}
DORA_EXPORT void audio_set_listener_velocity(float velocity_x, float velocity_y, float velocity_z) {
	SharedAudio.setListenerVelocity(velocity_x, velocity_y, velocity_z);
}
} // extern "C"

static void linkAudio(wasm3::module3& mod) {
	mod.link_optional("*", "audio_set_sound_speed", audio_set_sound_speed);
	mod.link_optional("*", "audio_get_sound_speed", audio_get_sound_speed);
	mod.link_optional("*", "audio_set_global_volume", audio_set_global_volume);
	mod.link_optional("*", "audio_get_global_volume", audio_get_global_volume);
	mod.link_optional("*", "audio_set_listener", audio_set_listener);
	mod.link_optional("*", "audio_get_listener", audio_get_listener);
	mod.link_optional("*", "audio_play", audio_play);
	mod.link_optional("*", "audio_stop", audio_stop);
	mod.link_optional("*", "audio_play_stream", audio_play_stream);
	mod.link_optional("*", "audio_stop_stream", audio_stop_stream);
	mod.link_optional("*", "audio_stop_all", audio_stop_all);
	mod.link_optional("*", "audio_set_pause_all_current", audio_set_pause_all_current);
	mod.link_optional("*", "audio_set_listener_at", audio_set_listener_at);
	mod.link_optional("*", "audio_set_listener_up", audio_set_listener_up);
	mod.link_optional("*", "audio_set_listener_velocity", audio_set_listener_velocity);
}