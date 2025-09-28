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
		public static extern int32_t action_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float action_get_duration(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t action_is_running(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t action_is_paused(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void action_set_reversed(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t action_is_reversed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void action_set_speed(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float action_get_speed(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void action_pause(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void action_resume(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void action_update_to(int64_t self, float elapsed, int32_t reversed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t action_new(int64_t def);
	}
} // namespace Dora

namespace Dora
{
	/// Represents an action that can be run on a node.
	public partial class Action : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.action_type(), From);
		}
		protected Action(long raw) : base(raw) { }
		internal static new Action From(long raw)
		{
			return new Action(raw);
		}
		internal static new Action? FromOpt(long raw)
		{
			return raw == 0 ? null : new Action(raw);
		}
		/// the duration of the action.
		public float Duration
		{
			get => Native.action_get_duration(Raw);
		}
		/// whether the action is currently running.
		public bool IsRunning
		{
			get => Native.action_is_running(Raw) != 0;
		}
		/// whether the action is currently paused.
		public bool IsPaused
		{
			get => Native.action_is_paused(Raw) != 0;
		}
		/// whether the action should be run in reverse.
		public bool IsReversed
		{
			set => Native.action_set_reversed(Raw, value ? 1 : 0);
			get => Native.action_is_reversed(Raw) != 0;
		}
		/// the speed at which the action should be run.
		/// Set to 1.0 to get normal speed, Set to 2.0 to get two times faster.
		public float Speed
		{
			set => Native.action_set_speed(Raw, value);
			get => Native.action_get_speed(Raw);
		}
		/// Pauses the action.
		public void Pause()
		{
			Native.action_pause(Raw);
		}
		/// Resumes the action.
		public void Resume()
		{
			Native.action_resume(Raw);
		}
		/// Updates the state of the Action.
		///
		/// # Arguments
		///
		/// * `elapsed` - The amount of time in seconds that has elapsed to update action to.
		/// * `reversed` - Whether or not to update the Action in reverse.
		public void UpdateTo(float elapsed, bool reversed)
		{
			Native.action_update_to(Raw, elapsed, reversed ? 1 : 0);
		}
		/// Creates a new Action object.
		///
		/// # Arguments
		///
		/// * `def` - The definition of the action.
		///
		/// # Returns
		///
		/// * `Action` - A new Action object.
		public Action(ActionDef def) : this(Native.action_new(def.Raw)) { }
	}
} // namespace Dora
