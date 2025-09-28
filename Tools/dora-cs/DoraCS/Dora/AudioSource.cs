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
		public static extern void audiosource_seek(int64_t self, double start_time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_schedule_stop(int64_t self, double time_to_stop);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_stop(int64_t self, double fade_time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_play(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_play_with_delay(int64_t self, double delay_time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_play_background(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_play_3d(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audiosource_play_3d_with_delay(int64_t self, double delay_time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_protected(int64_t self, int32_t value);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_loop_point(int64_t self, double loop_start_time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_velocity(int64_t self, float vx, float vy, float vz);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_min_max_distance(int64_t self, float min, float max);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_attenuation(int64_t self, int32_t model, float factor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audiosource_set_doppler_factor(int64_t self, float factor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t audiosource_new(int64_t filename, int32_t auto_remove);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t audiosource_with_bus(int64_t filename, int32_t auto_remove, int64_t bus);
	}
} // namespace Dora

namespace Dora
{
	/// A class that represents an audio source node.
	public partial class AudioSource : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.node_type(), From);
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
		/// The volume of the audio source. The value is between 0.0 and 1.0.
		public float Volume
		{
			set => Native.audiosource_set_volume(Raw, value);
			get => Native.audiosource_get_volume(Raw);
		}
		/// The pan of the audio source. The value is between -1.0 and 1.0.
		public float Pan
		{
			set => Native.audiosource_set_pan(Raw, value);
			get => Native.audiosource_get_pan(Raw);
		}
		/// Whether the audio source is looping.
		public bool IsLooping
		{
			set => Native.audiosource_set_looping(Raw, value ? 1 : 0);
			get => Native.audiosource_is_looping(Raw) != 0;
		}
		/// Whether the audio source is playing.
		public bool IsPlaying
		{
			get => Native.audiosource_is_playing(Raw) != 0;
		}
		/// Seeks the audio source to the given time.
		///
		/// # Arguments
		///
		/// * `startTime` - The time to seek to.
		public void Seek(double start_time)
		{
			Native.audiosource_seek(Raw, start_time);
		}
		/// Schedules the audio source to stop at the given time.
		///
		/// # Arguments
		///
		/// * `timeToStop` - The time to wait before stopping the audio source.
		public void ScheduleStop(double time_to_stop)
		{
			Native.audiosource_schedule_stop(Raw, time_to_stop);
		}
		/// Stops the audio source.
		///
		/// # Arguments
		///
		/// * `fadeTime` - The time to fade out the audio source.
		public void Stop(double fade_time)
		{
			Native.audiosource_stop(Raw, fade_time);
		}
		/// Plays the audio source.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the audio source was played successfully, `false` otherwise.
		public bool Play()
		{
			return Native.audiosource_play(Raw) != 0;
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
		public bool PlayWithDelay(double delay_time)
		{
			return Native.audiosource_play_with_delay(Raw, delay_time) != 0;
		}
		/// Plays the audio source as a background audio.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the audio source was played successfully, `false` otherwise.
		public bool PlayBackground()
		{
			return Native.audiosource_play_background(Raw) != 0;
		}
		/// Plays the audio source as a 3D audio.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the audio source was played successfully, `false` otherwise.
		public bool Play3D()
		{
			return Native.audiosource_play_3d(Raw) != 0;
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
		public bool Play3DWithDelay(double delay_time)
		{
			return Native.audiosource_play_3d_with_delay(Raw, delay_time) != 0;
		}
		/// Sets the protected state of the audio source.
		///
		/// # Arguments
		///
		/// * `value` - The protected state.
		public void SetProtected(bool value)
		{
			Native.audiosource_set_protected(Raw, value ? 1 : 0);
		}
		/// Sets the loop point of the audio source.
		///
		/// # Arguments
		///
		/// * `loopStartTime` - The time to start the loop.
		public void SetLoopPoint(double loop_start_time)
		{
			Native.audiosource_set_loop_point(Raw, loop_start_time);
		}
		/// Sets the velocity of the audio source.
		///
		/// # Arguments
		///
		/// * `vx` - The X coordinate of the velocity.
		/// * `vy` - The Y coordinate of the velocity.
		/// * `vz` - The Z coordinate of the velocity.
		public void SetVelocity(float vx, float vy, float vz)
		{
			Native.audiosource_set_velocity(Raw, vx, vy, vz);
		}
		/// Sets the minimum and maximum distance of the audio source.
		///
		/// # Arguments
		///
		/// * `min` - The minimum distance.
		/// * `max` - The maximum distance.
		public void SetMinMaxDistance(float min, float max)
		{
			Native.audiosource_set_min_max_distance(Raw, min, max);
		}
		/// Sets the attenuation of the audio source.
		///
		/// # Arguments
		///
		/// * `model` - The attenuation model.
		/// * `factor` - The factor of the attenuation.
		public void SetAttenuation(AttenuationModel model, float factor)
		{
			Native.audiosource_set_attenuation(Raw, (int)model, factor);
		}
		/// Sets the Doppler factor of the audio source.
		///
		/// # Arguments
		///
		/// * `factor` - The factor of the Doppler effect.
		public void SetDopplerFactor(float factor)
		{
			Native.audiosource_set_doppler_factor(Raw, factor);
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
		public AudioSource(string filename, bool auto_remove) : this(Native.audiosource_new(Bridge.FromString(filename), auto_remove ? 1 : 0)) { }
		public static AudioSource? TryCreate(string filename, bool auto_remove)
		{
			var raw = Native.audiosource_new(Bridge.FromString(filename), auto_remove ? 1 : 0);
			return raw == 0 ? null : new AudioSource(raw);
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
		public AudioSource(string filename, bool auto_remove, AudioBus bus) : this(Native.audiosource_with_bus(Bridge.FromString(filename), auto_remove ? 1 : 0, bus.Raw)) { }
		public static AudioSource? TryCreate(string filename, bool auto_remove, AudioBus bus)
		{
			var raw = Native.audiosource_with_bus(Bridge.FromString(filename), auto_remove ? 1 : 0, bus.Raw);
			return raw == 0 ? null : new AudioSource(raw);
		}
	}
} // namespace Dora
