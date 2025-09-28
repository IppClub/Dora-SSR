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
		public static extern int32_t motorjoint_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void motorjoint_set_enabled(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t motorjoint_is_enabled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void motorjoint_set_force(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float motorjoint_get_force(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void motorjoint_set_speed(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float motorjoint_get_speed(int64_t self);
	}
} // namespace Dora

namespace Dora
{
	/// A joint that applies a rotational or linear force to a physics body.
	public partial class MotorJoint : Joint
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.node_type(), From);
		}
		protected MotorJoint(long raw) : base(raw) { }
		internal static new MotorJoint From(long raw)
		{
			return new MotorJoint(raw);
		}
		internal static new MotorJoint? FromOpt(long raw)
		{
			return raw == 0 ? null : new MotorJoint(raw);
		}
		/// whether or not the motor joint is enabled.
		public bool IsEnabled
		{
			set => Native.motorjoint_set_enabled(Raw, value ? 1 : 0);
			get => Native.motorjoint_is_enabled(Raw) != 0;
		}
		/// the force applied to the motor joint.
		public float Force
		{
			set => Native.motorjoint_set_force(Raw, value);
			get => Native.motorjoint_get_force(Raw);
		}
		/// the speed of the motor joint.
		public float Speed
		{
			set => Native.motorjoint_set_speed(Raw, value);
			get => Native.motorjoint_get_speed(Raw);
		}
	}
} // namespace Dora
