/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */


using System.Runtime.InteropServices;
using int64_t = long;
using int32_t = int;

namespace Dora
{
	internal static partial class Native
	{
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiobus_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_set_volume(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float audiobus_get_volume(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_set_pan(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float audiobus_get_pan(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_set_play_speed(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float audiobus_get_play_speed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_fade_volume(int64_t self, double time, float to_volume);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_fade_pan(int64_t self, double time, float to_pan);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_fade_play_speed(int64_t self, double time, float to_play_speed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_set_filter(int64_t self, int32_t index, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_set_filter_parameter(int64_t self, int32_t index, int32_t attr_id, float value);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float audiobus_get_filter_parameter(int64_t self, int32_t index, int32_t attr_id);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_fade_filter_parameter(int64_t self, int32_t index, int32_t attr_id, float to, double time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t audiobus_new();
	}
} // namespace Dora

namespace Dora
{
	/// A class that represents an audio bus.
	public partial class AudioBus : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.node_type(), From);
		}
		protected AudioBus(long raw) : base(raw) { }
		internal static new AudioBus From(long raw)
		{
			return new AudioBus(raw);
		}
		internal static new AudioBus? FromOpt(long raw)
		{
			return raw == 0 ? null : new AudioBus(raw);
		}
		/// The volume of the audio bus. The value is between 0.0 and 1.0.
		public float Volume
		{
			set => Native.audiobus_set_volume(Raw, value);
			get => Native.audiobus_get_volume(Raw);
		}
		/// The pan of the audio bus. The value is between -1.0 and 1.0.
		public float Pan
		{
			set => Native.audiobus_set_pan(Raw, value);
			get => Native.audiobus_get_pan(Raw);
		}
		/// The play speed of the audio bus. The value 1.0 is the normal speed. 0.5 is half speed. 2.0 is double speed.
		public float PlaySpeed
		{
			set => Native.audiobus_set_play_speed(Raw, value);
			get => Native.audiobus_get_play_speed(Raw);
		}
		/// Fades the volume of the audio bus to the given value over the given time.
		///
		/// # Arguments
		///
		/// * `time` - The time to fade the volume.
		/// * `toVolume` - The target volume.
		public void FadeVolume(double time, float to_volume)
		{
			Native.audiobus_fade_volume(Raw, time, to_volume);
		}
		/// Fades the pan of the audio bus to the given value over the given time.
		///
		/// # Arguments
		///
		/// * `time` - The time to fade the pan.
		/// * `toPan` - The target pan. The value is between -1.0 and 1.0.
		public void FadePan(double time, float to_pan)
		{
			Native.audiobus_fade_pan(Raw, time, to_pan);
		}
		/// Fades the play speed of the audio bus to the given value over the given time.
		///
		/// # Arguments
		///
		/// * `time` - The time to fade the play speed.
		/// * `toPlaySpeed` - The target play speed.
		public void FadePlaySpeed(double time, float to_play_speed)
		{
			Native.audiobus_fade_play_speed(Raw, time, to_play_speed);
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
		public void SetFilter(int index, string name)
		{
			Native.audiobus_set_filter(Raw, index, Bridge.FromString(name));
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
		public void SetFilterParameter(int index, int attr_id, float value)
		{
			Native.audiobus_set_filter_parameter(Raw, index, attr_id, value);
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
		public float GetFilterParameter(int index, int attr_id)
		{
			return Native.audiobus_get_filter_parameter(Raw, index, attr_id);
		}
		/// Fades the filter parameter of the audio bus to the given value over the given time.
		///
		/// # Arguments
		///
		/// * `index` - The index of the filter.
		/// * `attrId` - The attribute ID of the filter.
		/// * `to` - The target value of the filter parameter.
		/// * `time` - The time to fade the filter parameter.
		public void FadeFilterParameter(int index, int attr_id, float to, double time)
		{
			Native.audiobus_fade_filter_parameter(Raw, index, attr_id, to, time);
		}
		/// Creates a new audio bus.
		///
		/// # Returns
		///
		/// * `AudioBus` - The created audio bus.
		public AudioBus() : this(Native.audiobus_new()) { }
	}
} // namespace Dora
