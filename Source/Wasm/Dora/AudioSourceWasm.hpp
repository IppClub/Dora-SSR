/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t audiosource_type() {
	return DoraType<AudioSource>();
}
DORA_EXPORT void audiosource_set_volume(int64_t self, float val) {
	r_cast<AudioSource*>(self)->setVolume(val);
}
DORA_EXPORT float audiosource_get_volume(int64_t self) {
	return r_cast<AudioSource*>(self)->getVolume();
}
DORA_EXPORT void audiosource_set_pan(int64_t self, float val) {
	r_cast<AudioSource*>(self)->setPan(val);
}
DORA_EXPORT float audiosource_get_pan(int64_t self) {
	return r_cast<AudioSource*>(self)->getPan();
}
DORA_EXPORT void audiosource_set_looping(int64_t self, int32_t val) {
	r_cast<AudioSource*>(self)->setLooping(val != 0);
}
DORA_EXPORT int32_t audiosource_is_looping(int64_t self) {
	return r_cast<AudioSource*>(self)->isLooping() ? 1 : 0;
}
DORA_EXPORT int32_t audiosource_is_playing(int64_t self) {
	return r_cast<AudioSource*>(self)->isPlaying() ? 1 : 0;
}
DORA_EXPORT void audiosource_seek(int64_t self, double start_time) {
	r_cast<AudioSource*>(self)->seek(start_time);
}
DORA_EXPORT void audiosource_schedule_stop(int64_t self, double time_to_stop) {
	r_cast<AudioSource*>(self)->scheduleStop(time_to_stop);
}
DORA_EXPORT void audiosource_stop(int64_t self, double fade_time) {
	r_cast<AudioSource*>(self)->stop(fade_time);
}
DORA_EXPORT int32_t audiosource_play(int64_t self) {
	return r_cast<AudioSource*>(self)->play() ? 1 : 0;
}
DORA_EXPORT int32_t audiosource_play_with_delay(int64_t self, double delay_time) {
	return r_cast<AudioSource*>(self)->play(delay_time) ? 1 : 0;
}
DORA_EXPORT int32_t audiosource_play_background(int64_t self) {
	return r_cast<AudioSource*>(self)->playBackground() ? 1 : 0;
}
DORA_EXPORT int32_t audiosource_play_3d(int64_t self) {
	return r_cast<AudioSource*>(self)->play3D() ? 1 : 0;
}
DORA_EXPORT int32_t audiosource_play_3d_with_delay(int64_t self, double delay_time) {
	return r_cast<AudioSource*>(self)->play3D(delay_time) ? 1 : 0;
}
DORA_EXPORT void audiosource_set_protected(int64_t self, int32_t value) {
	r_cast<AudioSource*>(self)->setProtected(value != 0);
}
DORA_EXPORT void audiosource_set_loop_point(int64_t self, double loop_start_time) {
	r_cast<AudioSource*>(self)->setLoopPoint(loop_start_time);
}
DORA_EXPORT void audiosource_set_velocity(int64_t self, float vx, float vy, float vz) {
	r_cast<AudioSource*>(self)->setVelocity(vx, vy, vz);
}
DORA_EXPORT void audiosource_set_min_max_distance(int64_t self, float min, float max) {
	r_cast<AudioSource*>(self)->setMinMaxDistance(min, max);
}
DORA_EXPORT void audiosource_set_attenuation(int64_t self, int32_t model, float factor) {
	r_cast<AudioSource*>(self)->setAttenuation(s_cast<AudioSource::AttenuationModel>(model), factor);
}
DORA_EXPORT void audiosource_set_doppler_factor(int64_t self, float factor) {
	r_cast<AudioSource*>(self)->setDopplerFactor(factor);
}
DORA_EXPORT int64_t audiosource_new(int64_t filename, int32_t auto_remove) {
	return Object_From(AudioSource::create(*Str_From(filename), auto_remove != 0));
}
DORA_EXPORT int64_t audiosource_with_bus(int64_t filename, int32_t auto_remove, int64_t bus) {
	return Object_From(AudioSource::create(*Str_From(filename), auto_remove != 0, r_cast<AudioBus*>(bus)));
}
} // extern "C"

static void linkAudioSource(wasm3::module3& mod) {
	mod.link_optional("*", "audiosource_type", audiosource_type);
	mod.link_optional("*", "audiosource_set_volume", audiosource_set_volume);
	mod.link_optional("*", "audiosource_get_volume", audiosource_get_volume);
	mod.link_optional("*", "audiosource_set_pan", audiosource_set_pan);
	mod.link_optional("*", "audiosource_get_pan", audiosource_get_pan);
	mod.link_optional("*", "audiosource_set_looping", audiosource_set_looping);
	mod.link_optional("*", "audiosource_is_looping", audiosource_is_looping);
	mod.link_optional("*", "audiosource_is_playing", audiosource_is_playing);
	mod.link_optional("*", "audiosource_seek", audiosource_seek);
	mod.link_optional("*", "audiosource_schedule_stop", audiosource_schedule_stop);
	mod.link_optional("*", "audiosource_stop", audiosource_stop);
	mod.link_optional("*", "audiosource_play", audiosource_play);
	mod.link_optional("*", "audiosource_play_with_delay", audiosource_play_with_delay);
	mod.link_optional("*", "audiosource_play_background", audiosource_play_background);
	mod.link_optional("*", "audiosource_play_3d", audiosource_play_3d);
	mod.link_optional("*", "audiosource_play_3d_with_delay", audiosource_play_3d_with_delay);
	mod.link_optional("*", "audiosource_set_protected", audiosource_set_protected);
	mod.link_optional("*", "audiosource_set_loop_point", audiosource_set_loop_point);
	mod.link_optional("*", "audiosource_set_velocity", audiosource_set_velocity);
	mod.link_optional("*", "audiosource_set_min_max_distance", audiosource_set_min_max_distance);
	mod.link_optional("*", "audiosource_set_attenuation", audiosource_set_attenuation);
	mod.link_optional("*", "audiosource_set_doppler_factor", audiosource_set_doppler_factor);
	mod.link_optional("*", "audiosource_new", audiosource_new);
	mod.link_optional("*", "audiosource_with_bus", audiosource_with_bus);
}