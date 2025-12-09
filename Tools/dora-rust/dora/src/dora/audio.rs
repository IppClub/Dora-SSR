/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn audio_set_sound_speed(val: f32);
	fn audio_get_sound_speed() -> f32;
	fn audio_set_global_volume(val: f32);
	fn audio_get_global_volume() -> f32;
	fn audio_set_listener(val: i64);
	fn audio_get_listener() -> i64;
	fn audio_play(filename: i64, looping: i32) -> i32;
	fn audio_stop(handle: i32);
	fn audio_play_stream(filename: i64, looping: i32, cross_fade_time: f32);
	fn audio_stop_stream(fade_time: f32);
	fn audio_stop_all(fade_time: f32);
	fn audio_set_pause_all_current(pause: i32);
	fn audio_set_listener_at(at_x: f32, at_y: f32, at_z: f32);
	fn audio_set_listener_up(up_x: f32, up_y: f32, up_z: f32);
	fn audio_set_listener_velocity(velocity_x: f32, velocity_y: f32, velocity_z: f32);
}
/// A interface of an audio player.
pub struct Audio { }
impl Audio {
	/// Sets The speed of the 3D sound.
	pub fn set_sound_speed(val: f32) {
		unsafe { audio_set_sound_speed(val) };
	}
	/// Gets The speed of the 3D sound.
	pub fn get_sound_speed() -> f32 {
		return unsafe { audio_get_sound_speed() };
	}
	/// Sets The global volume of the audio. The value is between 0.0 and 1.0.
	pub fn set_global_volume(val: f32) {
		unsafe { audio_set_global_volume(val) };
	}
	/// Gets The global volume of the audio. The value is between 0.0 and 1.0.
	pub fn get_global_volume() -> f32 {
		return unsafe { audio_get_global_volume() };
	}
	/// Sets The 3D listener as a node of the audio.
	pub fn set_listener(val: &dyn crate::dora::INode) {
		unsafe { audio_set_listener(val.raw()) };
	}
	/// Gets The 3D listener as a node of the audio.
	pub fn get_listener() -> Option<crate::dora::Node> {
		return unsafe { crate::dora::Node::from(audio_get_listener()) };
	}
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
	/// Stops all the playing audio sources.
	///
	/// # Arguments
	///
	/// * `fade_time` - The time (in seconds) to fade out the audio sources.
	pub fn stop_all(fade_time: f32) {
		unsafe { audio_stop_all(fade_time); }
	}
	/// Pauses all the current audio.
	///
	/// # Arguments
	///
	/// * `pause` - Whether to pause the audio.
	pub fn set_pause_all_current(pause: bool) {
		unsafe { audio_set_pause_all_current(if pause { 1 } else { 0 }); }
	}
	/// Sets the position of the 3D listener.
	///
	/// # Arguments
	///
	/// * `atX` - The X coordinate of the listener position.
	/// * `atY` - The Y coordinate of the listener position.
	/// * `atZ` - The Z coordinate of the listener position.
	pub fn set_listener_at(at_x: f32, at_y: f32, at_z: f32) {
		unsafe { audio_set_listener_at(at_x, at_y, at_z); }
	}
	/// Sets the up vector of the 3D listener.
	///
	/// # Arguments
	///
	/// * `upX` - The X coordinate of the listener up vector.
	/// * `upY` - The Y coordinate of the listener up vector.
	/// * `upZ` - The Z coordinate of the listener up vector.
	pub fn set_listener_up(up_x: f32, up_y: f32, up_z: f32) {
		unsafe { audio_set_listener_up(up_x, up_y, up_z); }
	}
	/// Sets the velocity of the 3D listener.
	///
	/// # Arguments
	///
	/// * `velocityX` - The X coordinate of the listener velocity.
	/// * `velocityY` - The Y coordinate of the listener velocity.
	/// * `velocityZ` - The Z coordinate of the listener velocity.
	pub fn set_listener_velocity(velocity_x: f32, velocity_y: f32, velocity_z: f32) {
		unsafe { audio_set_listener_velocity(velocity_x, velocity_y, velocity_z); }
	}
}