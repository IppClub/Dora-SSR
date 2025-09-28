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
	/// Another implementation of the 'Playable' animation interface.
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
		/// the duration of the current animation.
		public float Duration
		{
			get => Native.model_get_duration(Raw);
		}
		/// whether the animation model will be played in reverse.
		public bool IsReversed
		{
			set => Native.model_set_reversed(Raw, value ? 1 : 0);
			get => Native.model_is_reversed(Raw) != 0;
		}
		/// whether the animation model is currently playing.
		public bool IsPlaying
		{
			get => Native.model_is_playing(Raw) != 0;
		}
		/// whether the animation model is currently paused.
		public bool IsPaused
		{
			get => Native.model_is_paused(Raw) != 0;
		}
		/// Checks if an animation exists in the model.
		///
		/// # Arguments
		///
		/// * `name` - The name of the animation to check.
		///
		/// # Returns
		///
		/// * `bool` - Whether the animation exists in the model or not.
		public bool HasAnimation(string name)
		{
			return Native.model_has_animation(Raw, Bridge.FromString(name)) != 0;
		}
		/// Pauses the currently playing animation.
		public void Pause()
		{
			Native.model_pause(Raw);
		}
		/// Resumes the currently paused animation,
		public void Resume()
		{
			Native.model_resume(Raw);
		}
		/// Resumes the currently paused animation, or plays a new animation if specified.
		///
		/// # Arguments
		///
		/// * `name` - The name of the animation to play.
		/// * `loop` - Whether to loop the animation or not.
		public void ResumeAnimation(string name, bool looping)
		{
			Native.model_resume_animation(Raw, Bridge.FromString(name), looping ? 1 : 0);
		}
		/// Resets the current animation to its initial state.
		public void Reset()
		{
			Native.model_reset(Raw);
		}
		/// Updates the animation to the specified time, and optionally in reverse.
		///
		/// # Arguments
		///
		/// * `elapsed` - The time to update to.
		/// * `reversed` - Whether to play the animation in reverse.
		public void UpdateTo(float elapsed, bool reversed)
		{
			Native.model_update_to(Raw, elapsed, reversed ? 1 : 0);
		}
		/// Gets the node with the specified name.
		///
		/// # Arguments
		///
		/// * `name` - The name of the node to get.
		///
		/// # Returns
		///
		/// * The node with the specified name.
		public Node GetNodeByName(string name)
		{
			return Node.From(Native.model_get_node_by_name(Raw, Bridge.FromString(name)));
		}
		/// Calls the specified function for each node in the model, and stops if the function returns `false`.
		///
		/// # Arguments
		///
		/// * `visitorFunc` - The function to call for each node.
		///
		/// # Returns
		///
		/// * `bool` - Whether the function was called for all nodes or not.
		public bool EachNode(Func<Node, bool> visitor_func)
		{
			var stack0 = new CallStack();
			var stack_raw0 = stack0.Raw;
			var func_id0 = Bridge.PushFunction(() =>
			{
				var result = visitor_func((Node)stack0.PopObject());
				stack0.Push(result);;
			});
			return Native.model_each_node(Raw, func_id0, stack_raw0) != 0;
		}
		/// Creates a new instance of 'Model' from the specified model file.
		///
		/// # Arguments
		///
		/// * `filename` - The filename of the model file to load. Can be filename with or without extension like: "Model/item" or "Model/item.model".
		///
		/// # Returns
		///
		/// * A new instance of 'Model'.
		public Model(string filename) : this(Native.model_new(Bridge.FromString(filename))) { }
		public static new Model? TryCreate(string filename)
		{
			var raw = Native.model_new(Bridge.FromString(filename));
			return raw == 0 ? null : new Model(raw);
		}
		/// Returns a new dummy instance of 'Model' that can do nothing.
		///
		/// # Returns
		///
		/// * A new dummy instance of 'Model'.
		public static Model Dummy()
		{
			return Model.From(Native.model_dummy());
		}
		/// Gets the clip file from the specified model file.
		///
		/// # Arguments
		///
		/// * `filename` - The filename of the model file to search.
		///
		/// # Returns
		///
		/// * A `String` representing the name of the clip file.
		public static string GetClipFile(string filename)
		{
			return Bridge.ToString(Native.model_get_clip_file(Bridge.FromString(filename)));
		}
		/// Gets an array of look names from the specified model file.
		///
		/// # Arguments
		///
		/// * `filename` - The filename of the model file to search.
		///
		/// # Returns
		///
		/// * A `Vec<String>` representing an array of look names found in the model file.
		public static string[] GetLooks(string filename)
		{
			return Bridge.ToStringArray(Native.model_get_looks(Bridge.FromString(filename)));
		}
		/// Gets an array of animation names from the specified model file.
		///
		/// # Arguments
		///
		/// * `filename` - The filename of the model file to search.
		///
		/// # Returns
		///
		/// * A `Vec<String>` representing an array of animation names found in the model file.
		public static string[] GetAnimations(string filename)
		{
			return Bridge.ToStringArray(Native.model_get_animations(Bridge.FromString(filename)));
		}
	}
} // namespace Dora
