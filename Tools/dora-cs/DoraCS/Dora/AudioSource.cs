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
		public static extern int32_t audiosource_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_volume(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float audiosource_get_volume(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_pan(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float audiosource_get_pan(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_looping(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_is_looping(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_is_playing(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_seek(int64_t self, double startTime);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_schedule_stop(int64_t self, double timeToStop);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_stop(int64_t self, double fadeTime);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_play(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_play_with_delay(int64_t self, double delayTime);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_play_background(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_play_3d(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_play_3d_with_delay(int64_t self, double delayTime);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_protected(int64_t self, int32_t value);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_loop_point(int64_t self, double loopStartTime);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_velocity(int64_t self, float vx, float vy, float vz);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_min_max_distance(int64_t self, float min, float max);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_attenuation(int64_t self, int32_t model, float factor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_doppler_factor(int64_t self, float factor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t audiosource_new(int64_t filename, int32_t autoRemove);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t audiosource_with_bus(int64_t filename, int32_t autoRemove, int64_t bus);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A class that represents an audio source node.
	/// </summary>
	public partial class AudioSource : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.audiosource_type(), From);
		}
		protected AudioSource(long raw) : base(raw) { }
		internal static new AudioSource From(long raw)
		{
			return new AudioSource(raw);
		}
		internal static new AudioSource? FromOpt(long raw)
		{
			return raw == 0 ? null : new AudioSource(raw);
		}
		/// <summary>
		/// The volume of the audio source. The value is between 0.0 and 1.0.
		/// </summary>
		public float Volume
		{
			set => Native.audiosource_set_volume(Raw, value);
			get => Native.audiosource_get_volume(Raw);
		}
		/// <summary>
		/// The pan of the audio source. The value is between -1.0 and 1.0.
		/// </summary>
		public float Pan
		{
			set => Native.audiosource_set_pan(Raw, value);
			get => Native.audiosource_get_pan(Raw);
		}
		/// <summary>
		/// Whether the audio source is looping.
		/// </summary>
		public bool IsLooping
		{
			set => Native.audiosource_set_looping(Raw, value ? 1 : 0);
			get => Native.audiosource_is_looping(Raw) != 0;
		}
		/// <summary>
		/// Whether the audio source is playing.
		/// </summary>
		public bool IsPlaying
		{
			get => Native.audiosource_is_playing(Raw) != 0;
		}
		/// <summary>
		/// Seeks the audio source to the given time.
		/// </summary>
		/// <param name="startTime">The time to seek to.</param>
		public void Seek(double startTime)
		{
			Native.audiosource_seek(Raw, startTime);
		}
		/// <summary>
		/// Schedules the audio source to stop at the given time.
		/// </summary>
		/// <param name="timeToStop">The time to wait before stopping the audio source.</param>
		public void ScheduleStop(double timeToStop)
		{
			Native.audiosource_schedule_stop(Raw, timeToStop);
		}
		/// <summary>
		/// Stops the audio source.
		/// </summary>
		/// <param name="fadeTime">The time to fade out the audio source.</param>
		public void Stop(double fadeTime = 0.0)
		{
			Native.audiosource_stop(Raw, fadeTime);
		}
		/// <summary>
		/// Plays the audio source.
		/// </summary>
		/// <returns>`true` if the audio source was played successfully, `false` otherwise.</returns>
		public bool Play()
		{
			return Native.audiosource_play(Raw) != 0;
		}
		/// <summary>
		/// Plays the audio source with a delay.
		/// </summary>
		/// <param name="delayTime">The time to wait before playing the audio source.</param>
		/// <returns>`true` if the audio source was played successfully, `false` otherwise.</returns>
		public bool Play(double delayTime = 0.0)
		{
			return Native.audiosource_play_with_delay(Raw, delayTime) != 0;
		}
		/// <summary>
		/// Plays the audio source as a background audio.
		/// </summary>
		/// <returns>`true` if the audio source was played successfully, `false` otherwise.</returns>
		public bool PlayBackground()
		{
			return Native.audiosource_play_background(Raw) != 0;
		}
		/// <summary>
		/// Plays the audio source as a 3D audio.
		/// </summary>
		/// <returns>`true` if the audio source was played successfully, `false` otherwise.</returns>
		public bool Play3D()
		{
			return Native.audiosource_play_3d(Raw) != 0;
		}
		/// <summary>
		/// Plays the audio source as a 3D audio with a delay.
		/// </summary>
		/// <param name="delayTime">The time to wait before playing the audio source.</param>
		/// <returns>`true` if the audio source was played successfully, `false` otherwise.</returns>
		public bool Play3D(double delayTime = 0.0)
		{
			return Native.audiosource_play_3d_with_delay(Raw, delayTime) != 0;
		}
		/// <summary>
		/// Sets the protected state of the audio source.
		/// </summary>
		/// <param name="value">The protected state.</param>
		public void SetProtected(bool value)
		{
			Native.audiosource_set_protected(Raw, value ? 1 : 0);
		}
		/// <summary>
		/// Sets the loop point of the audio source.
		/// </summary>
		/// <param name="loopStartTime">The time to start the loop.</param>
		public void SetLoopPoint(double loopStartTime)
		{
			Native.audiosource_set_loop_point(Raw, loopStartTime);
		}
		/// <summary>
		/// Sets the velocity of the audio source.
		/// </summary>
		/// <param name="vx">The X coordinate of the velocity.</param>
		/// <param name="vy">The Y coordinate of the velocity.</param>
		/// <param name="vz">The Z coordinate of the velocity.</param>
		public void SetVelocity(float vx, float vy, float vz)
		{
			Native.audiosource_set_velocity(Raw, vx, vy, vz);
		}
		/// <summary>
		/// Sets the minimum and maximum distance of the audio source.
		/// </summary>
		/// <param name="min">The minimum distance.</param>
		/// <param name="max">The maximum distance.</param>
		public void SetMinMaxDistance(float min, float max)
		{
			Native.audiosource_set_min_max_distance(Raw, min, max);
		}
		/// <summary>
		/// Sets the attenuation of the audio source.
		/// </summary>
		/// <param name="model">The attenuation model.</param>
		/// <param name="factor">The factor of the attenuation.</param>
		public void SetAttenuation(AttenuationModel model, float factor)
		{
			Native.audiosource_set_attenuation(Raw, (int)model, factor);
		}
		/// <summary>
		/// Sets the Doppler factor of the audio source.
		/// </summary>
		/// <param name="factor">The factor of the Doppler effect.</param>
		public void SetDopplerFactor(float factor)
		{
			Native.audiosource_set_doppler_factor(Raw, factor);
		}
		/// <summary>
		/// Creates a new audio source.
		/// </summary>
		/// <param name="filename">The path to the audio file.</param>
		/// <param name="autoRemove">Whether to automatically remove the audio source when it is stopped.</param>
		/// <returns>The created audio source node.</returns>
		public AudioSource(string filename, bool autoRemove = true) : this(Native.audiosource_new(Bridge.FromString(filename), autoRemove ? 1 : 0)) { }
		public static AudioSource? TryCreate(string filename, bool autoRemove = true)
		{
			var raw = Native.audiosource_new(Bridge.FromString(filename), autoRemove ? 1 : 0);
			return raw == 0 ? null : new AudioSource(raw);
		}
		/// <summary>
		/// Creates a new audio source.
		/// </summary>
		/// <param name="filename">The path to the audio file.</param>
		/// <param name="autoRemove">Whether to automatically remove the audio source when it is stopped.</param>
		/// <param name="bus">The audio bus to use for the audio source.</param>
		/// <returns>The created audio source node.</returns>
		public AudioSource(string filename, bool autoRemove, AudioBus bus) : this(Native.audiosource_with_bus(Bridge.FromString(filename), autoRemove ? 1 : 0, bus.Raw)) { }
		public static AudioSource? TryCreate(string filename, bool autoRemove, AudioBus bus)
		{
			var raw = Native.audiosource_with_bus(Bridge.FromString(filename), autoRemove ? 1 : 0, bus.Raw);
			return raw == 0 ? null : new AudioSource(raw);
		}
	}
} // namespace Dora
