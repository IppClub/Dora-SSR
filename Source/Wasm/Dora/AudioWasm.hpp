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