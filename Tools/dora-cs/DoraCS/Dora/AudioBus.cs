/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

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
		public static extern void audiobus_fade_volume(int64_t self, double time, float toVolume);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_fade_pan(int64_t self, double time, float toPan);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_fade_play_speed(int64_t self, double time, float toPlaySpeed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_set_filter(int64_t self, int32_t index, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_set_filter_parameter(int64_t self, int32_t index, int32_t attrId, float value);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float audiobus_get_filter_parameter(int64_t self, int32_t index, int32_t attrId);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiobus_fade_filter_parameter(int64_t self, int32_t index, int32_t attrId, float to, double time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t audiobus_new();
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A class that represents an audio bus.
	/// </summary>
	public partial class AudioBus : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.audiobus_type(), From);
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
		/// <summary>
		/// The volume of the audio bus. The value is between 0.0 and 1.0.
		/// </summary>
		public float Volume
		{
			set => Native.audiobus_set_volume(Raw, value);
			get => Native.audiobus_get_volume(Raw);
		}
		/// <summary>
		/// The pan of the audio bus. The value is between -1.0 and 1.0.
		/// </summary>
		public float Pan
		{
			set => Native.audiobus_set_pan(Raw, value);
			get => Native.audiobus_get_pan(Raw);
		}
		/// <summary>
		/// The play speed of the audio bus. The value 1.0 is the normal speed. 0.5 is half speed. 2.0 is double speed.
		/// </summary>
		public float PlaySpeed
		{
			set => Native.audiobus_set_play_speed(Raw, value);
			get => Native.audiobus_get_play_speed(Raw);
		}
		/// <summary>
		/// Fades the volume of the audio bus to the given value over the given time.
		/// </summary>
		/// <param name="time">The time to fade the volume.</param>
		/// <param name="toVolume">The target volume.</param>
		public void FadeVolume(double time, float toVolume)
		{
			Native.audiobus_fade_volume(Raw, time, toVolume);
		}
		/// <summary>
		/// Fades the pan of the audio bus to the given value over the given time.
		/// </summary>
		/// <param name="time">The time to fade the pan.</param>
		/// <param name="toPan">The target pan. The value is between -1.0 and 1.0.</param>
		public void FadePan(double time, float toPan)
		{
			Native.audiobus_fade_pan(Raw, time, toPan);
		}
		/// <summary>
		/// Fades the play speed of the audio bus to the given value over the given time.
		/// </summary>
		/// <param name="time">The time to fade the play speed.</param>
		/// <param name="toPlaySpeed">The target play speed.</param>
		public void FadePlaySpeed(double time, float toPlaySpeed)
		{
			Native.audiobus_fade_play_speed(Raw, time, toPlaySpeed);
		}
		/// <summary>
		/// Sets the filter of the audio bus.
		/// </summary>
		/// <param name="index">The index of the filter.</param>
		/// <param name="name">The name of the filter.</param>
		public void SetFilter(int index, string name)
		{
			Native.audiobus_set_filter(Raw, index, Bridge.FromString(name));
		}
		/// <summary>
		/// Sets the filter parameter of the audio bus.
		/// </summary>
		/// <param name="index">The index of the filter.</param>
		/// <param name="attrId">The attribute ID of the filter.</param>
		/// <param name="value">The value of the filter parameter.</param>
		public void SetFilterParameter(int index, int attrId, float value)
		{
			Native.audiobus_set_filter_parameter(Raw, index, attrId, value);
		}
		/// <summary>
		/// Gets the filter parameter of the audio bus.
		/// </summary>
		/// <param name="index">The index of the filter.</param>
		/// <param name="attrId">The attribute ID of the filter.</param>
		/// <returns>The value of the filter parameter.</returns>
		public float GetFilterParameter(int index, int attrId)
		{
			return Native.audiobus_get_filter_parameter(Raw, index, attrId);
		}
		/// <summary>
		/// Fades the filter parameter of the audio bus to the given value over the given time.
		/// </summary>
		/// <param name="index">The index of the filter.</param>
		/// <param name="attrId">The attribute ID of the filter.</param>
		/// <param name="to">The target value of the filter parameter.</param>
		/// <param name="time">The time to fade the filter parameter.</param>
		public void FadeFilterParameter(int index, int attrId, float to, double time)
		{
			Native.audiobus_fade_filter_parameter(Raw, index, attrId, to, time);
		}
		/// <summary>
		/// Creates a new audio bus.
		/// </summary>
		/// <returns>The created audio bus.</returns>
		public AudioBus() : this(Native.audiobus_new()) { }
	}
} // namespace Dora
