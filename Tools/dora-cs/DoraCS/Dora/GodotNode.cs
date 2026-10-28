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
		public static extern int32_t godotnode_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t godotnode_get_unsupported_reason();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t godotnode_get_project_path(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t godotnode_get_scene_file(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t godotnode_get_last_error(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t godotnode_is_running(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t godotnode_is_paused(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t godotnode_get_viewport_size(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t godotnode_resize_viewport(int64_t self, int32_t width, int32_t height);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void godotnode_pause(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void godotnode_resume(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t godotnode_restart(int64_t self, int64_t sceneFile);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void godotnode_send_pointer(int64_t self, double x, double y, int32_t button, int32_t pressed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void godotnode_send_pointer_move(int64_t self, double x, double y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void godotnode_send_key(int64_t self, int64_t name, int32_t pressed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void godotnode_send_text(int64_t self, int64_t text);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t godotnode_new(int64_t projectPath, int64_t sceneFile, int32_t width, int32_t height, int32_t buffers);
	}
} // namespace Dora

namespace Dora
{
	public partial class GodotNode : Sprite
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.godotnode_type(), From);
		}
		protected GodotNode(long raw) : base(raw) { }
		internal static new GodotNode From(long raw)
		{
			return new GodotNode(raw);
		}
		internal static new GodotNode? FromOpt(long raw)
		{
			return raw == 0 ? null : new GodotNode(raw);
		}
		/// Empty when the current GPU/backend supports GodotNode; does not load the runtime library.
		public static string GetUnsupportedReason()
		{
			return Bridge.ToString(Native.godotnode_get_unsupported_reason());
		}
		/// <summary>Resolved Godot project directory or exported .pck path.</summary>
		public string ProjectPath
		{
			get => Bridge.ToString(Native.godotnode_get_project_path(Raw));
		}
		/// <summary>Requested Godot scene path; empty uses the project main scene.</summary>
		public string SceneFile
		{
			get => Bridge.ToString(Native.godotnode_get_scene_file(Raw));
		}
		/// <summary>Most recent asynchronous runtime error, or an empty string.</summary>
		public string LastError
		{
			get => Bridge.ToString(Native.godotnode_get_last_error(Raw));
		}
		/// <summary>Whether asynchronous startup completed and the node is active.</summary>
		public new bool IsRunning
		{
			get => Native.godotnode_is_running(Raw) != 0;
		}
		/// <summary>Requested native SceneTree pause state.</summary>
		public bool IsPaused
		{
			get => Native.godotnode_is_paused(Raw) != 0;
		}
		/// <summary>Committed native viewport pixel size; updated after asynchronous texture publication.</summary>
		public Size ViewportSize
		{
			get => Size.From(Native.godotnode_get_viewport_size(Raw));
		}
		/// <summary>Request a native viewport resize; false when invalid, busy or unsupported.</summary>
		public bool ResizeViewport(int width, int height)
		{
			return Native.godotnode_resize_viewport(Raw, width, height) != 0;
		}
		/// <summary>Pause the SceneTree; Always-process nodes continue running. Works before startup completes.</summary>
		public void Pause()
		{
			Native.godotnode_pause(Raw);
		}
		/// <summary>Resume the SceneTree without rebuilding the project.</summary>
		public void Resume()
		{
			Native.godotnode_resume(Raw);
		}
		/// <summary>Request scene reload; empty reloads the current scene. Errors are asynchronous.</summary>
		public bool Restart(string sceneFile = "")
		{
			return Native.godotnode_restart(Raw, Bridge.FromString(sceneFile)) != 0;
		}
		/// <summary>Forward a pointer button in viewport pixels, with top-left origin. Godot button numbering applies.</summary>
		public void SendPointer(double x, double y, int button, bool pressed)
		{
			Native.godotnode_send_pointer(Raw, x, y, button, pressed ? 1 : 0);
		}
		/// <summary>Forward pointer motion in viewport pixels, with top-left origin.</summary>
		public void SendPointerMove(double x, double y)
		{
			Native.godotnode_send_pointer_move(Raw, x, y);
		}
		/// <summary>Forward a named key, such as Space. Pair presses with releases.</summary>
		public void SendKey(string name, bool pressed)
		{
			Native.godotnode_send_key(Raw, Bridge.FromString(name), pressed ? 1 : 0);
		}
		/// <summary>Forward committed UTF-8 text. IME composition is not implemented.</summary>
		public void SendText(string text)
		{
			Native.godotnode_send_text(Raw, Bridge.FromString(text));
		}
		/// <summary>Create an experimental embedded Godot node. Requires a matching optional runtime and supported GPU backend. Only one active node/project is supported.</summary>
		public GodotNode(string projectPath, string sceneFile = "", int width = 640, int height = 360, int buffers = 3) : this(Native.godotnode_new(Bridge.FromString(projectPath), Bridge.FromString(sceneFile), width, height, buffers)) { }
		public static GodotNode? TryCreate(string projectPath, string sceneFile = "", int width = 640, int height = 360, int buffers = 3)
		{
			var raw = Native.godotnode_new(Bridge.FromString(projectPath), Bridge.FromString(sceneFile), width, height, buffers);
			return raw == 0 ? null : new GodotNode(raw);
		}
	}
} // namespace Dora
