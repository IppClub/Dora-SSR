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
		public static extern void audio_set_sound_speed(float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float audio_get_sound_speed();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_set_global_volume(float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float audio_get_global_volume();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_set_listener(int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_set_listener_null();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t audio_get_listener();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t audio_play(int64_t filename, int32_t looping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_stop(int32_t handle);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_play_stream(int64_t filename, int32_t looping, float cross_fade_time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_stop_stream(float fade_time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_set_pause_all_current(int32_t pause);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_set_listener_at(float at_x, float at_y, float at_z);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_set_listener_up(float up_x, float up_y, float up_z);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_set_listener_velocity(float velocity_x, float velocity_y, float velocity_z);
	}
} // namespace Dora

namespace Dora
{
	/// A interface of an audio player.
	public static partial class Audio
	{
		/// The speed of the 3D sound.
		public static float SoundSpeed
		{
			set => Native.audio_set_sound_speed(value);
			get => Native.audio_get_sound_speed();
		}
		/// The global volume of the audio. The value is between 0.0 and 1.0.
		public static float GlobalVolume
		{
			set => Native.audio_set_global_volume(value);
			get => Native.audio_get_global_volume();
		}
		/// The 3D listener as a node of the audio.
		public static Node? Listener
		{
			set
			{
				if (value == null) Native.audio_set_listener_null();
				else Native.audio_set_listener(value.Raw);
			}
			get => Node.FromOpt(Native.audio_get_listener());
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
		public static int Play(string filename, bool looping)
		{
			return Native.audio_play(Bridge.FromString(filename), looping ? 1 : 0);
		}
		/// Stops a sound effect that is currently playing.
		///
		/// # Arguments
		///
		/// * `handler` - The handler for the audio that is returned by the `play` function.
		public static void Stop(int handle)
		{
			Native.audio_stop(handle);
		}
		/// Plays a streaming audio file.
		///
		/// # Arguments
		///
		/// * `filename` - The path to the streaming audio file (can be OGG, WAV, MP3, or FLAC).
		/// * `loop` - Whether to loop the streaming audio.
		/// * `crossFadeTime` - The time (in seconds) to crossfade between the previous and new streaming audio.
		public static void PlayStream(string filename, bool looping, float cross_fade_time)
		{
			Native.audio_play_stream(Bridge.FromString(filename), looping ? 1 : 0, cross_fade_time);
		}
		/// Stops a streaming audio file that is currently playing.
		///
		/// # Arguments
		///
		/// * `fade_time` - The time (in seconds) to fade out the streaming audio.
		public static void StopStream(float fade_time)
		{
			Native.audio_stop_stream(fade_time);
		}
		/// Pauses all the current audio.
		///
		/// # Arguments
		///
		/// * `pause` - Whether to pause the audio.
		public static void SetPauseAllCurrent(bool pause)
		{
			Native.audio_set_pause_all_current(pause ? 1 : 0);
		}
		/// Sets the position of the 3D listener.
		///
		/// # Arguments
		///
		/// * `atX` - The X coordinate of the listener position.
		/// * `atY` - The Y coordinate of the listener position.
		/// * `atZ` - The Z coordinate of the listener position.
		public static void SetListenerAt(float at_x, float at_y, float at_z)
		{
			Native.audio_set_listener_at(at_x, at_y, at_z);
		}
		/// Sets the up vector of the 3D listener.
		///
		/// # Arguments
		///
		/// * `upX` - The X coordinate of the listener up vector.
		/// * `upY` - The Y coordinate of the listener up vector.
		/// * `upZ` - The Z coordinate of the listener up vector.
		public static void SetListenerUp(float up_x, float up_y, float up_z)
		{
			Native.audio_set_listener_up(up_x, up_y, up_z);
		}
		/// Sets the velocity of the 3D listener.
		///
		/// # Arguments
		///
		/// * `velocityX` - The X coordinate of the listener velocity.
		/// * `velocityY` - The Y coordinate of the listener velocity.
		/// * `velocityZ` - The Z coordinate of the listener velocity.
		public static void SetListenerVelocity(float velocity_x, float velocity_y, float velocity_z)
		{
			Native.audio_set_listener_velocity(velocity_x, velocity_y, velocity_z);
		}
	}
} // namespace Dora
