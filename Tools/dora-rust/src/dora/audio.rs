extern "C" {
	fn audio_play(filename: i64, looping: i32) -> i32;
	fn audio_stop(handle: i32);
	fn audio_play_stream(filename: i64, looping: i32, cross_fade_time: f32);
	fn audio_stop_stream(fade_time: f32);
}
pub struct Audio { }
impl Audio {
	pub fn play(filename: &str, looping: bool) -> i32 {
		unsafe { return audio_play(crate::dora::from_string(filename), if looping { 1 } else { 0 }); }
	}
	pub fn stop(handle: i32) {
		unsafe { audio_stop(handle); }
	}
	pub fn play_stream(filename: &str, looping: bool, cross_fade_time: f32) {
		unsafe { audio_play_stream(crate::dora::from_string(filename), if looping { 1 } else { 0 }, cross_fade_time); }
	}
	pub fn stop_stream(fade_time: f32) {
		unsafe { audio_stop_stream(fade_time); }
	}
}