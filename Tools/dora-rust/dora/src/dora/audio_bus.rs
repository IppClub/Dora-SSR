/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn audiobus_type() -> i32;
	fn audiobus_set_volume(slf: i64, val: f32);
	fn audiobus_get_volume(slf: i64) -> f32;
	fn audiobus_set_pan(slf: i64, val: f32);
	fn audiobus_get_pan(slf: i64) -> f32;
	fn audiobus_set_play_speed(slf: i64, val: f32);
	fn audiobus_get_play_speed(slf: i64) -> f32;
	fn audiobus_fade_volume(slf: i64, time: f64, to_volume: f32);
	fn audiobus_fade_pan(slf: i64, time: f64, to_pan: f32);
	fn audiobus_fade_play_speed(slf: i64, time: f64, to_play_speed: f32);
	fn audiobus_set_filter(slf: i64, index: i32, name: i64);
	fn audiobus_set_filter_parameter(slf: i64, index: i32, attr_id: i32, value: f32);
	fn audiobus_get_filter_parameter(slf: i64, index: i32, attr_id: i32) -> f32;
	fn audiobus_fade_filter_parameter(slf: i64, index: i32, attr_id: i32, to: f32, time: f64);
	fn audiobus_new() -> i64;
}
use crate::dora::IObject;
/// A class that represents an audio bus.
pub struct AudioBus { raw: i64 }
crate::dora_object!(AudioBus);
impl AudioBus {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { audiobus_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(AudioBus { raw: raw }))
			}
		})
	}
	/// Sets The volume of the audio bus. The value is between 0.0 and 1.0.
	pub fn set_volume(&mut self, val: f32) {
		unsafe { audiobus_set_volume(self.raw(), val) };
	}
	/// Gets The volume of the audio bus. The value is between 0.0 and 1.0.
	pub fn get_volume(&self) -> f32 {
		return unsafe { audiobus_get_volume(self.raw()) };
	}
	/// Sets The pan of the audio bus. The value is between -1.0 and 1.0.
	pub fn set_pan(&mut self, val: f32) {
		unsafe { audiobus_set_pan(self.raw(), val) };
	}
	/// Gets The pan of the audio bus. The value is between -1.0 and 1.0.
	pub fn get_pan(&self) -> f32 {
		return unsafe { audiobus_get_pan(self.raw()) };
	}
	/// Sets The play speed of the audio bus. The value 1.0 is the normal speed. 0.5 is half speed. 2.0 is double speed.
	pub fn set_play_speed(&mut self, val: f32) {
		unsafe { audiobus_set_play_speed(self.raw(), val) };
	}
	/// Gets The play speed of the audio bus. The value 1.0 is the normal speed. 0.5 is half speed. 2.0 is double speed.
	pub fn get_play_speed(&self) -> f32 {
		return unsafe { audiobus_get_play_speed(self.raw()) };
	}
	/// Fades the volume of the audio bus to the given value over the given time.
	///
	/// # Arguments
	///
	/// * `time` - The time to fade the volume.
	/// * `toVolume` - The target volume.
	pub fn fade_volume(&mut self, time: f64, to_volume: f32) {
		unsafe { audiobus_fade_volume(self.raw(), time, to_volume); }
	}
	/// Fades the pan of the audio bus to the given value over the given time.
	///
	/// # Arguments
	///
	/// * `time` - The time to fade the pan.
	/// * `toPan` - The target pan. The value is between -1.0 and 1.0.
	pub fn fade_pan(&mut self, time: f64, to_pan: f32) {
		unsafe { audiobus_fade_pan(self.raw(), time, to_pan); }
	}
	/// Fades the play speed of the audio bus to the given value over the given time.
	///
	/// # Arguments
	///
	/// * `time` - The time to fade the play speed.
	/// * `toPlaySpeed` - The target play speed.
	pub fn fade_play_speed(&mut self, time: f64, to_play_speed: f32) {
		unsafe { audiobus_fade_play_speed(self.raw(), time, to_play_speed); }
	}
	/// Sets the filter of the audio bus.
	///
	/// # Arguments
	///
	/// * `index` - The index of the filter.
	/// * `name` - The name of the filter.
	/// 	- "": No filter.
	/// 	- "BassBoost": The bass boost filter.
	/// 	- "BiquadResonant": The biquad resonant filter.
	/// 	- "DCRemoval": The DC removal filter.
	/// 	- "Echo": The echo filter.
	/// 	- "Eq": The equalizer filter.
	/// 	- "FFT": The FFT filter.
	/// 	- "Flanger": The flanger filter.
	/// 	- "FreeVerb": The freeverb filter.
	/// 	- "Lofi": The lofi filter.
	/// 	- "Robotize": The robotize filter.
	/// 	- "WaveShaper": The wave shaper filter.
	pub fn set_filter(&mut self, index: i32, name: &str) {
		unsafe { audiobus_set_filter(self.raw(), index, crate::dora::from_string(name)); }
	}
	/// Sets the filter parameter of the audio bus.
	///
	/// # Arguments
	///
	/// * `index` - The index of the filter.
	/// * `attrId` - The attribute ID of the filter.
	/// * `value` - The value of the filter parameter.
	/// 	- "BassBoost": The bass boost filter.
	/// 		- param0: WET, float, min: 0, max: 1
	/// 		- param1: BOOST, float, min: 0, max: 10
	/// 	- "BiquadResonant": The biquad resonant filter.
	/// 		- param0: WET, float, min: 0, max: 1
	/// 		- param1: TYPE, int, values: 0 - LOWPASS, 1 - HIGHPASS, 2 - BANDPASS
	/// 		- param2: FREQUENCY, float, min: 10, max: 8000
	/// 		- param3: RESONANCE, float, min: 0.1, max: 20
	/// 	- "DCRemoval": The DC removal filter.
	/// 		- param0: WET, float, min: 0, max: 1
	/// 	- "Echo": The echo filter.
	/// 		- param0: WET, float, min: 0, max: 1
	/// 		- param1: DELAY, float, min: 0, max: 1
	/// 		- param2: DECAY, float, min: 0, max: 1
	/// 		- param3: FILTER, float, min: 0, max: 1
	/// 	- "Eq": The equalizer filter.
	/// 		- param0: WET, float, min: 0, max: 1
	/// 		- param1: BAND0, float, min: 0, max: 4
	/// 		- param2: BAND1, float, min: 0, max: 4
	/// 		- param3: BAND2, float, min: 0, max: 4
	/// 		- param4: BAND3, float, min: 0, max: 4
	/// 		- param5: BAND4, float, min: 0, max: 4
	/// 		- param6: BAND5, float, min: 0, max: 4
	/// 		- param7: BAND6, float, min: 0, max: 4
	/// 		- param8: BAND7, float, min: 0, max: 4
	/// 	- "FFT": The FFT filter.
	/// 		- param0: WET, float, min: 0, max: 1
	/// 	- "Flanger": The flanger filter.
	/// 		- param0: WET, float, min: 0, max: 1
	/// 		- param1: DELAY, float, min: 0.001, max: 0.1
	/// 		- param2: FREQ, float, min: 0.001, max: 100
	/// 	- "FreeVerb": The freeverb filter.
	/// 		- param0: WET, float, min: 0, max: 1
	/// 		- param1: FREEZE, float, min: 0, max: 1
	/// 		- param2: ROOMSIZE, float, min: 0, max: 1
	/// 		- param3: DAMP, float, min: 0, max: 1
	/// 		- param4: WIDTH, float, min: 0, max: 1
	/// 	- "Lofi": The lofi filter.
	/// 		- param0: WET, float, min: 0, max: 1
	/// 		- param1: SAMPLE_RATE, float, min: 100, max: 22000
	/// 		- param2: BITDEPTH, float, min: 0.5, max: 16
	/// 	- "Robotize": The robotize filter.
	/// 		- param0: WET, float, min: 0, max: 1
	/// 		- param1: FREQ, float, min: 0.1, max: 100
	/// 		- param2: WAVE, float, min: 0, max: 6
	/// 	- "WaveShaper": The wave shaper filter.
	/// 		- param0: WET, float, min: 0, max: 1
	/// 		- param1: AMOUNT, float, min: -1, max: 1
	pub fn set_filter_parameter(&mut self, index: i32, attr_id: i32, value: f32) {
		unsafe { audiobus_set_filter_parameter(self.raw(), index, attr_id, value); }
	}
	/// Gets the filter parameter of the audio bus.
	///
	/// # Arguments
	///
	/// * `index` - The index of the filter.
	/// * `attrId` - The attribute ID of the filter.
	///
	/// # Returns
	///
	/// * `float` - The value of the filter parameter.
	pub fn get_filter_parameter(&mut self, index: i32, attr_id: i32) -> f32 {
		unsafe { return audiobus_get_filter_parameter(self.raw(), index, attr_id); }
	}
	/// Fades the filter parameter of the audio bus to the given value over the given time.
	///
	/// # Arguments
	///
	/// * `index` - The index of the filter.
	/// * `attrId` - The attribute ID of the filter.
	/// * `to` - The target value of the filter parameter.
	/// * `time` - The time to fade the filter parameter.
	pub fn fade_filter_parameter(&mut self, index: i32, attr_id: i32, to: f32, time: f64) {
		unsafe { audiobus_fade_filter_parameter(self.raw(), index, attr_id, to, time); }
	}
	/// Creates a new audio bus.
	///
	/// # Returns
	///
	/// * `AudioBus` - The created audio bus.
	pub fn new() -> AudioBus {
		unsafe { return AudioBus { raw: audiobus_new() }; }
	}
}