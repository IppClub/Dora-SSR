/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static int32_t audio_play(int64_t filename, int32_t looping) {
	return s_cast<int32_t>(SharedAudio.play(*str_from(filename), looping != 0));
}
static void audio_stop(int32_t handle) {
	SharedAudio.stop(s_cast<uint32_t>(handle));
}
static void audio_play_stream(int64_t filename, int32_t looping, float cross_fade_time) {
	SharedAudio.playStream(*str_from(filename), looping != 0, cross_fade_time);
}
static void audio_stop_stream(float fade_time) {
	SharedAudio.stopStream(fade_time);
}
static void linkAudio(wasm3::module3& mod) {
	mod.link_optional("*", "audio_play", audio_play);
	mod.link_optional("*", "audio_stop", audio_stop);
	mod.link_optional("*", "audio_play_stream", audio_play_stream);
	mod.link_optional("*", "audio_stop_stream", audio_stop_stream);
}