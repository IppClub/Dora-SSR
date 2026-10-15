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
		public static extern int32_t model_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float model_get_duration(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void model_set_reversed(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t model_is_reversed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t model_is_playing(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t model_is_paused(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t model_has_animation(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void model_pause(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void model_resume(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void model_resume_animation(int64_t self, int64_t name, int32_t looping);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void model_reset(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void model_update_to(int64_t self, float elapsed, int32_t reversed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model_get_node_by_name(int64_t self, int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t model_each_node(int64_t self, int32_t func0, int64_t stack0);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model_new(int64_t filename);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model_dummy();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model_get_clip_file(int64_t filename);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model_get_looks(int64_t filename);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t model_get_animations(int64_t filename);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// Another implementation of the 'Playable' animation interface.
	/// </summary>
	public partial class Model : Playable
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.model_type(), From);
		}
		protected Model(long raw) : base(raw) { }
		internal static new Model From(long raw)
		{
			return new Model(raw);
		}
		internal static new Model? FromOpt(long raw)
		{
			return raw == 0 ? null : new Model(raw);
		}
		/// <summary>
		/// The duration of the current animation.
		/// </summary>
		public float Duration
		{
			get => Native.model_get_duration(Raw);
		}
		/// <summary>
		/// Whether the animation model will be played in reverse.
		/// </summary>
		public bool IsReversed
		{
			set => Native.model_set_reversed(Raw, value ? 1 : 0);
			get => Native.model_is_reversed(Raw) != 0;
		}
		/// <summary>
		/// Whether the animation model is currently playing.
		/// </summary>
		public bool IsPlaying
		{
			get => Native.model_is_playing(Raw) != 0;
		}
		/// <summary>
		/// Whether the animation model is currently paused.
		/// </summary>
		public bool IsPaused
		{
			get => Native.model_is_paused(Raw) != 0;
		}
		/// <summary>
		/// Checks if an animation exists in the model.
		/// </summary>
		/// <param name="name">The name of the animation to check.</param>
		/// <returns>Whether the animation exists in the model or not.</returns>
		public bool HasAnimation(string name)
		{
			return Native.model_has_animation(Raw, Bridge.FromString(name)) != 0;
		}
		/// <summary>
		/// Pauses the currently playing animation.
		/// </summary>
		public void Pause()
		{
			Native.model_pause(Raw);
		}
		/// <summary>
		/// Resumes the currently paused animation,
		/// </summary>
		public void Resume()
		{
			Native.model_resume(Raw);
		}
		/// <summary>
		/// Resumes the currently paused animation, or plays a new animation if specified.
		/// </summary>
		/// <param name="name">The name of the animation to play.</param>
		/// <param name="looping">Whether to loop the animation or not.</param>
		public void ResumeAnimation(string name, bool looping = false)
		{
			Native.model_resume_animation(Raw, Bridge.FromString(name), looping ? 1 : 0);
		}
		/// <summary>
		/// Resets the current animation to its initial state.
		/// </summary>
		public void Reset()
		{
			Native.model_reset(Raw);
		}
		/// <summary>
		/// Updates the animation to the specified time, and optionally in reverse.
		/// </summary>
		/// <param name="elapsed">The time to update to.</param>
		/// <param name="reversed">Whether to play the animation in reverse.</param>
		public void UpdateTo(float elapsed, bool reversed = false)
		{
			Native.model_update_to(Raw, elapsed, reversed ? 1 : 0);
		}
		/// <summary>
		/// Gets the node with the specified name.
		/// </summary>
		/// <param name="name">The name of the node to get.</param>
		public Node GetNodeByName(string name)
		{
			return Node.From(Native.model_get_node_by_name(Raw, Bridge.FromString(name)));
		}
		/// <summary>
		/// Calls the specified function for each node in the model, and stops if the function returns `false`.
		/// </summary>
		/// <param name="visitorFunc">The function to call for each node.</param>
		/// <returns>Whether the function was called for all nodes or not.</returns>
		public bool EachNode(Func<Node, bool> visitorFunc)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = visitorFunc((Node)stack0.PopObject());
				stack0.Push(result);
			});
			return Native.model_each_node(Raw, func_id0, stack_raw0) != 0;
		}
		/// <summary>
		/// Creates a new instance of 'Model' from the specified model file.
		/// </summary>
		/// <param name="filename">The filename of the model file to load. Can be filename with or without extension like: "Model/item" or "Model/item.model".</param>
		public Model(string filename) : this(Native.model_new(Bridge.FromString(filename))) { }
		public static new Model? TryCreate(string filename)
		{
			var raw = Native.model_new(Bridge.FromString(filename));
			return raw == 0 ? null : new Model(raw);
		}
		/// <summary>
		/// Returns a new dummy instance of 'Model' that can do nothing.
		/// </summary>
		public static Model Dummy()
		{
			return Model.From(Native.model_dummy());
		}
		/// <summary>
		/// Gets the clip file from the specified model file.
		/// </summary>
		/// <param name="filename">The filename of the model file to search.</param>
		public static string GetClipFile(string filename)
		{
			return Bridge.ToString(Native.model_get_clip_file(Bridge.FromString(filename)));
		}
		/// <summary>
		/// Gets an array of look names from the specified model file.
		/// </summary>
		/// <param name="filename">The filename of the model file to search.</param>
		public static string[] GetLooks(string filename)
		{
			return Bridge.ToStringArray(Native.model_get_looks(Bridge.FromString(filename)));
		}
		/// <summary>
		/// Gets an array of animation names from the specified model file.
		/// </summary>
		/// <param name="filename">The filename of the model file to search.</param>
		public static string[] GetAnimations(string filename)
		{
			return Bridge.ToStringArray(Native.model_get_animations(Bridge.FromString(filename)));
		}
	}
} // namespace Dora
