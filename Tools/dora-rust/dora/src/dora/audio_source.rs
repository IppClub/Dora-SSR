/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn audiosource_type() -> i32;
	fn audiosource_set_volume(slf: i64, val: f32);
	fn audiosource_get_volume(slf: i64) -> f32;
	fn audiosource_set_pan(slf: i64, val: f32);
	fn audiosource_get_pan(slf: i64) -> f32;
	fn audiosource_set_looping(slf: i64, val: i32);
	fn audiosource_is_looping(slf: i64) -> i32;
	fn audiosource_is_playing(slf: i64) -> i32;
	fn audiosource_seek(slf: i64, start_time: f64);
	fn audiosource_schedule_stop(slf: i64, time_to_stop: f64);
	fn audiosource_stop(slf: i64, fade_time: f64);
	fn audiosource_play(slf: i64) -> i32;
	fn audiosource_play_with_delay(slf: i64, delay_time: f64) -> i32;
	fn audiosource_play_background(slf: i64) -> i32;
	fn audiosource_play_3d(slf: i64) -> i32;
	fn audiosource_play_3d_with_delay(slf: i64, delay_time: f64) -> i32;
	fn audiosource_set_protected(slf: i64, value: i32);
	fn audiosource_set_loop_point(slf: i64, loop_start_time: f64);
	fn audiosource_set_velocity(slf: i64, vx: f32, vy: f32, vz: f32);
	fn audiosource_set_min_max_distance(slf: i64, min: f32, max: f32);
	fn audiosource_set_attenuation(slf: i64, model: i32, factor: f32);
	fn audiosource_set_doppler_factor(slf: i64, factor: f32);
	fn audiosource_new(filename: i64, auto_remove: i32) -> i64;
	fn audiosource_with_bus(filename: i64, auto_remove: i32, bus: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for AudioSource { }
/// A class that represents an audio source node.
pub struct AudioSource { raw: i64 }
crate::dora_object!(AudioSource);
impl AudioSource {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { audiosource_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(AudioSource { raw: raw }))
			}
		})
	}
	/// Sets The volume of the audio source. The value is between 0.0 and 1.0.
	pub fn set_volume(&mut self, val: f32) {
		unsafe { audiosource_set_volume(self.raw(), val) };
	}
	/// Gets The volume of the audio source. The value is between 0.0 and 1.0.
	pub fn get_volume(&self) -> f32 {
		return unsafe { audiosource_get_volume(self.raw()) };
	}
	/// Sets The pan of the audio source. The value is between -1.0 and 1.0.
	pub fn set_pan(&mut self, val: f32) {
		unsafe { audiosource_set_pan(self.raw(), val) };
	}
	/// Gets The pan of the audio source. The value is between -1.0 and 1.0.
	pub fn get_pan(&self) -> f32 {
		return unsafe { audiosource_get_pan(self.raw()) };
	}
	/// Sets Whether the audio source is looping.
	pub fn set_looping(&mut self, val: bool) {
		unsafe { audiosource_set_looping(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets Whether the audio source is looping.
	pub fn is_looping(&self) -> bool {
		return unsafe { audiosource_is_looping(self.raw()) != 0 };
	}
	/// Gets Whether the audio source is playing.
	pub fn is_playing(&self) -> bool {
		return unsafe { audiosource_is_playing(self.raw()) != 0 };
	}
	/// Seeks the audio source to the given time.
	///
	/// # Arguments
	///
	/// * `startTime` - The time to seek to.
	pub fn seek(&mut self, start_time: f64) {
		unsafe { audiosource_seek(self.raw(), start_time); }
	}
	/// Schedules the audio source to stop at the given time.
	///
	/// # Arguments
	///
	/// * `timeToStop` - The time to wait before stopping the audio source.
	pub fn schedule_stop(&mut self, time_to_stop: f64) {
		unsafe { audiosource_schedule_stop(self.raw(), time_to_stop); }
	}
	/// Stops the audio source.
	///
	/// # Arguments
	///
	/// * `fadeTime` - The time to fade out the audio source.
	pub fn stop(&mut self, fade_time: f64) {
		unsafe { audiosource_stop(self.raw(), fade_time); }
	}
	/// Plays the audio source.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the audio source was played successfully, `false` otherwise.
	pub fn play(&mut self) -> bool {
		unsafe { return audiosource_play(self.raw()) != 0; }
	}
	/// Plays the audio source with a delay.
	///
	/// # Arguments
	///
	/// * `delayTime` - The time to wait before playing the audio source.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the audio source was played successfully, `false` otherwise.
	pub fn play_with_delay(&mut self, delay_time: f64) -> bool {
		unsafe { return audiosource_play_with_delay(self.raw(), delay_time) != 0; }
	}
	/// Plays the audio source as a background audio.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the audio source was played successfully, `false` otherwise.
	pub fn play_background(&mut self) -> bool {
		unsafe { return audiosource_play_background(self.raw()) != 0; }
	}
	/// Plays the audio source as a 3D audio.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the audio source was played successfully, `false` otherwise.
	pub fn play_3d(&mut self) -> bool {
		unsafe { return audiosource_play_3d(self.raw()) != 0; }
	}
	/// Plays the audio source as a 3D audio with a delay.
	///
	/// # Arguments
	///
	/// * `delayTime` - The time to wait before playing the audio source.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the audio source was played successfully, `false` otherwise.
	pub fn play_3d_with_delay(&mut self, delay_time: f64) -> bool {
		unsafe { return audiosource_play_3d_with_delay(self.raw(), delay_time) != 0; }
	}
	/// Sets the protected state of the audio source.
	///
	/// # Arguments
	///
	/// * `value` - The protected state.
	pub fn set_protected(&mut self, value: bool) {
		unsafe { audiosource_set_protected(self.raw(), if value { 1 } else { 0 }); }
	}
	/// Sets the loop point of the audio source.
	///
	/// # Arguments
	///
	/// * `loopStartTime` - The time to start the loop.
	pub fn set_loop_point(&mut self, loop_start_time: f64) {
		unsafe { audiosource_set_loop_point(self.raw(), loop_start_time); }
	}
	/// Sets the velocity of the audio source.
	///
	/// # Arguments
	///
	/// * `vx` - The X coordinate of the velocity.
	/// * `vy` - The Y coordinate of the velocity.
	/// * `vz` - The Z coordinate of the velocity.
	pub fn set_velocity(&mut self, vx: f32, vy: f32, vz: f32) {
		unsafe { audiosource_set_velocity(self.raw(), vx, vy, vz); }
	}
	/// Sets the minimum and maximum distance of the audio source.
	///
	/// # Arguments
	///
	/// * `min` - The minimum distance.
	/// * `max` - The maximum distance.
	pub fn set_min_max_distance(&mut self, min: f32, max: f32) {
		unsafe { audiosource_set_min_max_distance(self.raw(), min, max); }
	}
	/// Sets the attenuation of the audio source.
	///
	/// # Arguments
	///
	/// * `model` - The attenuation model.
	/// * `factor` - The factor of the attenuation.
	pub fn set_attenuation(&mut self, model: crate::dora::AttenuationModel, factor: f32) {
		unsafe { audiosource_set_attenuation(self.raw(), model as i32, factor); }
	}
	/// Sets the Doppler factor of the audio source.
	///
	/// # Arguments
	///
	/// * `factor` - The factor of the Doppler effect.
	pub fn set_doppler_factor(&mut self, factor: f32) {
		unsafe { audiosource_set_doppler_factor(self.raw(), factor); }
	}
	/// Creates a new audio source.
	///
	/// # Arguments
	///
	/// * `filename` - The path to the audio file.
	/// * `autoRemove` - Whether to automatically remove the audio source when it is stopped.
	///
	/// # Returns
	///
	/// * `AudioSource` - The created audio source node.
	pub fn new(filename: &str, auto_remove: bool) -> Option<AudioSource> {
		unsafe { return AudioSource::from(audiosource_new(crate::dora::from_string(filename), if auto_remove { 1 } else { 0 })); }
	}
	/// Creates a new audio source.
	///
	/// # Arguments
	///
	/// * `filename` - The path to the audio file.
	/// * `autoRemove` - Whether to automatically remove the audio source when it is stopped.
	/// * `bus` - The audio bus to use for the audio source.
	///
	/// # Returns
	///
	/// * `AudioSource` - The created audio source node.
	pub fn with_bus(filename: &str, auto_remove: bool, bus: &crate::dora::AudioBus) -> Option<AudioSource> {
		unsafe { return AudioSource::from(audiosource_with_bus(crate::dora::from_string(filename), if auto_remove { 1 } else { 0 }, bus.raw())); }
	}
}