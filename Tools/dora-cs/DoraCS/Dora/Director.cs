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
		public static extern void director_set_clear_color(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t director_get_clear_color();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t director_get_ui();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t director_get_ui_3d();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t director_get_entry();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t director_get_post_node();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t director_get_current_camera();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void director_set_frustum_culling(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t director_is_frustum_culling();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void director_schedule(int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void director_schedule_posted(int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void director_push_camera(int64_t camera);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void director_pop_camera();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t director_remove_camera(int64_t camera);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void director_clear_camera();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void director_cleanup();
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A struct manages the game scene trees and provides access to root scene nodes for different game uses.
	/// </summary>
	public static partial class Director
	{
		/// <summary>
		/// The background color for the game world.
		/// </summary>
		public static Color ClearColor
		{
			set => Native.director_set_clear_color((int)value.ToARGB());
			get => new Color((uint)Native.director_get_clear_color());
		}
		/// <summary>
		/// The root node for 2D user interface elements like buttons and labels.
		/// </summary>
		public static Node UI
		{
			get => Node.From(Native.director_get_ui());
		}
		/// <summary>
		/// The root node for 3D user interface elements with 3D projection effect.
		/// </summary>
		public static Node UI3D
		{
			get => Node.From(Native.director_get_ui_3d());
		}
		/// <summary>
		/// The root node for the starting point of a game.
		/// </summary>
		public static Node Entry
		{
			get => Node.From(Native.director_get_entry());
		}
		/// <summary>
		/// The root node for post-rendering scene tree.
		/// </summary>
		public static Node PostNode
		{
			get => Node.From(Native.director_get_post_node());
		}
		/// <summary>
		/// The current active camera in Director's camera stack.
		/// </summary>
		public static Camera CurrentCamera
		{
			get => Camera.From(Native.director_get_current_camera());
		}
		/// <summary>
		/// Whether or not to enable frustum culling.
		/// </summary>
		public static bool IsFrustumCulling
		{
			set => Native.director_set_frustum_culling(value ? 1 : 0);
			get => Native.director_is_frustum_culling() != 0;
		}
		/// <summary>
		/// Schedule a function to be called every frame.
		/// </summary>
		/// <param name="updateFunc">The function to call every frame.</param>
		public static void Schedule(Func<double, bool> updateFunc)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = updateFunc(stack0.PopF64());
				stack0.Push(result);
			});
			Native.director_schedule(func_id0, stack_raw0);
		}
		/// <summary>
		/// Schedule a function to be called every frame for processing post game logic.
		/// </summary>
		/// <param name="updateFunc">The function to call every frame.</param>
		public static void SchedulePosted(Func<double, bool> updateFunc)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = updateFunc(stack0.PopF64());
				stack0.Push(result);
			});
			Native.director_schedule_posted(func_id0, stack_raw0);
		}
		/// <summary>
		/// Adds a new camera to Director's camera stack and sets it to the current camera.
		/// </summary>
		/// <param name="camera">The camera to add.</param>
		public static void PushCamera(Camera camera)
		{
			Native.director_push_camera(camera.Raw);
		}
		/// <summary>
		/// Removes the current camera from Director's camera stack.
		/// </summary>
		public static void PopCamera()
		{
			Native.director_pop_camera();
		}
		/// <summary>
		/// Removes a specified camera from Director's camera stack.
		/// </summary>
		/// <param name="camera">The camera to remove.</param>
		/// <returns>`true` if the camera was removed, `false` otherwise.</returns>
		public static bool RemoveCamera(Camera camera)
		{
			return Native.director_remove_camera(camera.Raw) != 0;
		}
		/// <summary>
		/// Removes all cameras from Director's camera stack.
		/// </summary>
		public static void ClearCamera()
		{
			Native.director_clear_camera();
		}
		/// <summary>
		/// Cleans up all resources managed by the Director, including scene trees and cameras.
		/// </summary>
		public static void Cleanup()
		{
			Native.director_cleanup();
		}
	}
} // namespace Dora
