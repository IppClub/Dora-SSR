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
		public static extern int32_t application_get_frame();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t application_get_buffer_size();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t application_get_visual_size();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float application_get_device_pixel_ratio();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t application_get_platform();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t application_get_version();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t application_get_deps();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern double application_get_delta_time();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern double application_get_elapsed_time();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern double application_get_total_time();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern double application_get_running_time();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t application_get_rand();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_get_max_fps();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_is_debugging();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_locale(int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t application_get_locale();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_theme_color(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_get_theme_color();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_seed(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_get_seed();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_target_fps(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_get_target_fps();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_win_size(int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t application_get_win_size();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_win_position(int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t application_get_win_position();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_fps_limited(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_is_fps_limited();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_idled(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_is_idled();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_full_screen(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_is_full_screen();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_set_always_on_top(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t application_is_always_on_top();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void application_shutdown();
	}
} // namespace Dora

namespace Dora
{
	/// A struct representing an application.
	public static partial class App
	{
		/// the current passed frame number.
		public static int Frame
		{
			get => Native.application_get_frame();
		}
		/// the size of the main frame buffer texture used for rendering.
		public static Size BufferSize
		{
			get => Size.From(Native.application_get_buffer_size());
		}
		/// the logic visual size of the screen.
		/// The visual size only changes when application window size changes.
		/// And it won't be affacted by the view buffer scaling factor.
		public static Size VisualSize
		{
			get => Size.From(Native.application_get_visual_size());
		}
		/// the ratio of the pixel density displayed by the device
		/// Can be calculated as the size of the rendering buffer divided by the size of the application window.
		public static float DevicePixelRatio
		{
			get => Native.application_get_device_pixel_ratio();
		}
		/// the platform the game engine is running on.
		public static string Platform
		{
			get => Bridge.ToString(Native.application_get_platform());
		}
		/// the version string of the game engine.
		/// Should be in format of "v0.0.0".
		public static string Version
		{
			get => Bridge.ToString(Native.application_get_version());
		}
		/// the dependencies of the game engine.
		public static string Deps
		{
			get => Bridge.ToString(Native.application_get_deps());
		}
		/// the time in seconds since the last frame update.
		public static double DeltaTime
		{
			get => Native.application_get_delta_time();
		}
		/// the elapsed time since current frame was started, in seconds.
		public static double ElapsedTime
		{
			get => Native.application_get_elapsed_time();
		}
		/// the total time the game engine has been running until last frame ended, in seconds.
		/// Should be a contant number when invoked in a same frame for multiple times.
		public static double TotalTime
		{
			get => Native.application_get_total_time();
		}
		/// the total time the game engine has been running until this field being accessed, in seconds.
		/// Should be a increasing number when invoked in a same frame for multiple times.
		public static double RunningTime
		{
			get => Native.application_get_running_time();
		}
		/// a random number generated by a random number engine based on Mersenne Twister algorithm.
		/// So that the random number generated by a same seed should be consistent on every platform.
		public static long Rand
		{
			get => Native.application_get_rand();
		}
		/// the maximum valid frames per second the game engine is allowed to run at.
		/// The max FPS is being inferred by the device screen max refresh rate.
		public static int MaxFps
		{
			get => Native.application_get_max_fps();
		}
		/// whether the game engine is running in debug mode.
		public static bool IsDebugging
		{
			get => Native.application_is_debugging() != 0;
		}
		/// the system locale string, in format like: `zh-Hans`, `en`.
		public static string Locale
		{
			set => Native.application_set_locale(Bridge.FromString(value));
			get => Bridge.ToString(Native.application_get_locale());
		}
		/// the theme color for Dora SSR.
		public static Color ThemeColor
		{
			set => Native.application_set_theme_color((int)value.ToArgb());
			get => new Color((uint)Native.application_get_theme_color());
		}
		/// the random number seed.
		public static int Seed
		{
			set => Native.application_set_seed(value);
			get => Native.application_get_seed();
		}
		/// the target frames per second the game engine is supposed to run at.
		/// Only works when `fpsLimited` is set to true.
		public static int TargetFps
		{
			set => Native.application_set_target_fps(value);
			get => Native.application_get_target_fps();
		}
		/// the application window size.
		/// May differ from visual size due to the different DPIs of display devices.
		/// It is not available to set this property on platform Android and iOS.
		public static Size WinSize
		{
			set => Native.application_set_win_size(value.Raw);
			get => Size.From(Native.application_get_win_size());
		}
		/// the application window position.
		/// It is not available to set this property on platform Android and iOS.
		public static Vec2 WinPosition
		{
			set => Native.application_set_win_position(value.Raw);
			get => Vec2.From(Native.application_get_win_position());
		}
		/// whether the game engine is limiting the frames per second.
		/// Set `fpsLimited` to true, will make engine run in a busy loop to track the  precise frame time to switch to the next frame. And this behavior can lead to 100% CPU usage. This is usually common practice on Windows PCs for better CPU usage occupation. But it also results in extra heat and power consumption.
		public static bool IsFpsLimited
		{
			set => Native.application_set_fps_limited(value ? 1 : 0);
			get => Native.application_is_fps_limited() != 0;
		}
		/// whether the game engine is currently idled.
		/// Set `idled` to true, will make game logic thread use a sleep time and going idled for next frame to come. Due to the imprecision in sleep time. This idled state may cause game engine over slept for a few frames to lost.
		/// `idled` state can reduce some CPU usage.
		public static bool IsIdled
		{
			set => Native.application_set_idled(value ? 1 : 0);
			get => Native.application_is_idled() != 0;
		}
		/// whether the game engine is running in full screen mode.
		/// It is not available to set this property on platform Android and iOS.
		public static bool IsFullScreen
		{
			set => Native.application_set_full_screen(value ? 1 : 0);
			get => Native.application_is_full_screen() != 0;
		}
		/// whether the game engine window is always on top. Default is true.
		/// It is not available to set this property on platform Android and iOS.
		public static bool IsAlwaysOnTop
		{
			set => Native.application_set_always_on_top(value ? 1 : 0);
			get => Native.application_is_always_on_top() != 0;
		}
		/// Shuts down the game engine.
		/// It is not working and acts as a dummy function for platform Android and iOS to follow the specification of how mobile platform applications should operate.
		public static void Shutdown()
		{
			Native.application_shutdown();
		}
	}
} // namespace Dora
