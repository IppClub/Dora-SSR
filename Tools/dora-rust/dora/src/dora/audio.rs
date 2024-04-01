extern "C" {
	fn audio_play(filename: i64, looping: i32) -> i32;
	fn audio_stop(handle: i32);
	fn audio_play_stream(filename: i64, looping: i32, cross_fade_time: f32);
	fn audio_stop_stream(fade_time: f32);
}
/// A interface of an audio player.
pub struct Audio { }
impl Audio {
	/// Plays a sound effect and returns a handler for the audio.
	///
	/// # Arguments
	///
	/// * `filename` - The path to the sound effect file (must be a WAV file).
	/// * `loop` - Optional. Whether to loop the sound effect. Default is `false`.
	///
	/// # Returns
	///
	/// * `i32` - A handler for the audio that can be used to stop the sound effect.
	pub fn play(filename: &str, looping: bool) -> i32 {
		unsafe { return audio_play(crate::dora::from_string(filename), if looping { 1 } else { 0 }); }
	}
	/// Stops a sound effect that is currently playing.
	///
	/// # Arguments
	///
	/// * `handler` - The handler for the audio that is returned by the `play` function.
	pub fn stop(handle: i32) {
		unsafe { audio_stop(handle); }
	}
	/// Plays a streaming audio file.
	///
	/// # Arguments
	///
	/// * `filename` - The path to the streaming audio file (can be OGG, WAV, MP3, or FLAC).
	/// * `loop` - Whether to loop the streaming audio.
	/// * `crossFadeTime` - The time (in seconds) to crossfade between the previous and new streaming audio.
	pub fn play_stream(filename: &str, looping: bool, cross_fade_time: f32) {
		unsafe { audio_play_stream(crate::dora::from_string(filename), if looping { 1 } else { 0 }, cross_fade_time); }
	}
	/// Stops a streaming audio file that is currently playing.
	///
	/// # Arguments
	///
	/// * `fade_time` - The time (in seconds) to fade out the streaming audio.
	pub fn stop_stream(fade_time: f32) {
		unsafe { audio_stop_stream(fade_time); }
	}
}