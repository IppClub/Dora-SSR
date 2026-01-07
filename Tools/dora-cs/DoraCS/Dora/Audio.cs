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
		public static extern void audio_play_stream(int64_t filename, int32_t looping, float crossFadeTime);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_stop_stream(float fadeTime);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_stop_all(float fadeTime);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_set_pause_all_current(int32_t pause);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_set_listener_at(float atX, float atY, float atZ);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_set_listener_up(float upX, float upY, float upZ);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void audio_set_listener_velocity(float velocityX, float velocityY, float velocityZ);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A interface of an audio player.
	/// </summary>
	public static partial class Audio
	{
		/// <summary>
		/// The speed of the 3D sound.
		/// </summary>
		public static float SoundSpeed
		{
			set => Native.audio_set_sound_speed(value);
			get => Native.audio_get_sound_speed();
		}
		/// <summary>
		/// The global volume of the audio. The value is between 0.0 and 1.0.
		/// </summary>
		public static float GlobalVolume
		{
			set => Native.audio_set_global_volume(value);
			get => Native.audio_get_global_volume();
		}
		/// <summary>
		/// The 3D listener as a node of the audio.
		/// </summary>
		public static Node? Listener
		{
			set
			{
				if (value == null) Native.audio_set_listener_null();
				else Native.audio_set_listener(value.Raw);
			}
			get => Node.FromOpt(Native.audio_get_listener());
		}
		/// <summary>
		/// Plays a sound effect and returns a handler for the audio.
		/// </summary>
		/// <param name="filename">The path to the sound effect file (must be a WAV file).</param>
		/// <param name="looping">Optional. Whether to loop the sound effect. Default is `false`.</param>
		/// <returns>A handler for the audio that can be used to stop the sound effect.</returns>
		public static int Play(string filename, bool looping = false)
		{
			return Native.audio_play(Bridge.FromString(filename), looping ? 1 : 0);
		}
		/// <summary>
		/// Stops a sound effect that is currently playing.
		/// </summary>
		/// <param name="handle">The handler for the audio that is returned by the `play` function.</param>
		public static void Stop(int handle)
		{
			Native.audio_stop(handle);
		}
		/// <summary>
		/// Plays a streaming audio file.
		/// </summary>
		/// <param name="filename">The path to the streaming audio file (can be OGG, WAV, MP3, or FLAC).</param>
		/// <param name="looping">Whether to loop the streaming audio.</param>
		/// <param name="crossFadeTime">The time (in seconds) to crossfade between the previous and new streaming audio.</param>
		public static void PlayStream(string filename, bool looping = false, float crossFadeTime = 0.0f)
		{
			Native.audio_play_stream(Bridge.FromString(filename), looping ? 1 : 0, crossFadeTime);
		}
		/// <summary>
		/// Stops a streaming audio file that is currently playing.
		/// </summary>
		/// <param name="fadeTime">The time (in seconds) to fade out the streaming audio.</param>
		public static void StopStream(float fadeTime = 0.0f)
		{
			Native.audio_stop_stream(fadeTime);
		}
		/// <summary>
		/// Stops all the playing audio sources.
		/// </summary>
		/// <param name="fadeTime">The time (in seconds) to fade out the audio sources.</param>
		public static void StopAll(float fadeTime = 0.0f)
		{
			Native.audio_stop_all(fadeTime);
		}
		/// <summary>
		/// Pauses all the current audio.
		/// </summary>
		/// <param name="pause">Whether to pause the audio.</param>
		public static void SetPauseAllCurrent(bool pause)
		{
			Native.audio_set_pause_all_current(pause ? 1 : 0);
		}
		/// <summary>
		/// Sets the position of the 3D listener.
		/// </summary>
		/// <param name="atX">The X coordinate of the listener position.</param>
		/// <param name="atY">The Y coordinate of the listener position.</param>
		/// <param name="atZ">The Z coordinate of the listener position.</param>
		public static void SetListenerAt(float atX, float atY, float atZ)
		{
			Native.audio_set_listener_at(atX, atY, atZ);
		}
		/// <summary>
		/// Sets the up vector of the 3D listener.
		/// </summary>
		/// <param name="upX">The X coordinate of the listener up vector.</param>
		/// <param name="upY">The Y coordinate of the listener up vector.</param>
		/// <param name="upZ">The Z coordinate of the listener up vector.</param>
		public static void SetListenerUp(float upX, float upY, float upZ)
		{
			Native.audio_set_listener_up(upX, upY, upZ);
		}
		/// <summary>
		/// Sets the velocity of the 3D listener.
		/// </summary>
		/// <param name="velocityX">The X coordinate of the listener velocity.</param>
		/// <param name="velocityY">The Y coordinate of the listener velocity.</param>
		/// <param name="velocityZ">The Z coordinate of the listener velocity.</param>
		public static void SetListenerVelocity(float velocityX, float velocityY, float velocityZ)
		{
			Native.audio_set_listener_velocity(velocityX, velocityY, velocityZ);
		}
	}
} // namespace Dora
