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
		public static extern int32_t scheduler_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void scheduler_set_time_scale(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float scheduler_get_time_scale(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void scheduler_set_fixed_fps(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t scheduler_get_fixed_fps(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t scheduler_update(int64_t self, double delta_time);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t scheduler_new();
	}
} // namespace Dora

namespace Dora
{
	/// A scheduler that manages the execution of scheduled tasks.
	public partial class Scheduler : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.scheduler_type(), From);
		}
		protected Scheduler(long raw) : base(raw) { }
		internal static new Scheduler From(long raw)
		{
			return new Scheduler(raw);
		}
		internal static new Scheduler? FromOpt(long raw)
		{
			return raw == 0 ? null : new Scheduler(raw);
		}
		/// the time scale factor for the scheduler.
		/// This factor is applied to deltaTime that the scheduled functions will receive.
		public float TimeScale
		{
			set => Native.scheduler_set_time_scale(Raw, value);
			get => Native.scheduler_get_time_scale(Raw);
		}
		/// the target frame rate (in frames per second) for a fixed update mode.
		/// The fixed update will ensure a constant frame rate, and the operation handled in a fixed update can use a constant delta time value.
		/// It is used for preventing weird behavior of a physics engine or synchronizing some states via network communications.
		public int FixedFps
		{
			set => Native.scheduler_set_fixed_fps(Raw, value);
			get => Native.scheduler_get_fixed_fps(Raw);
		}
		/// Used for manually updating the scheduler if it is created by the user.
		///
		/// # Arguments
		///
		/// * `deltaTime` - The time in seconds since the last frame update.
		///
		/// # Returns
		///
		/// * `bool` - `true` if the scheduler was stoped, `false` otherwise.
		public bool Update(double delta_time)
		{
			return Native.scheduler_update(Raw, delta_time) != 0;
		}
		/// Creates a new Scheduler object.
		public Scheduler() : this(Native.scheduler_new()) { }
	}
} // namespace Dora
