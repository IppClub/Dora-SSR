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
		public static extern void vec3_release(int64_t raw);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void vec3_set_x(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float vec3_get_x(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void vec3_set_y(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float vec3_get_y(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void vec3_set_z(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float vec3_get_z(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t vec3_new(float x, float y, float z);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t vec3_zero();
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A 3D vector object with x, y and z components.
	/// </summary>
	public partial class Vec3
	{
		private Vec3(long raw)
		{
			if (raw == 0) throw new InvalidOperationException("failed to create Vec3");
			Raw = raw;
		}
		~Vec3()
		{
			Native.vec3_release(Raw);
		}
		internal long Raw { get; private set; }
		internal static Vec3 From(long raw)
		{
			return new Vec3(raw);
		}
		/// <summary>
		/// The x component.
		/// </summary>
		public float X
		{
			set => Native.vec3_set_x(Raw, value);
			get => Native.vec3_get_x(Raw);
		}
		/// <summary>
		/// The y component.
		/// </summary>
		public float Y
		{
			set => Native.vec3_set_y(Raw, value);
			get => Native.vec3_get_y(Raw);
		}
		/// <summary>
		/// The z component.
		/// </summary>
		public float Z
		{
			set => Native.vec3_set_z(Raw, value);
			get => Native.vec3_get_z(Raw);
		}
		/// <summary>
		/// Creates a new 3D vector.
		/// </summary>
		public Vec3(float x, float y, float z) : this(Native.vec3_new(x, y, z)) { }
		/// <summary>
		/// Gets a zero 3D vector.
		/// </summary>
		public static Vec3 Zero()
		{
			return Vec3.From(Native.vec3_zero());
		}
	}
} // namespace Dora
