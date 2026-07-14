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
		public static extern int32_t pointlight3d_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void pointlight3d_set_color(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t pointlight3d_get_color(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void pointlight3d_set_intensity(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float pointlight3d_get_intensity(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void pointlight3d_set_range(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float pointlight3d_get_range(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t pointlight3d_new();
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A point light whose position follows the node world transform.
	/// </summary>
	public partial class PointLight3D : Node3D
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.pointlight3d_type(), From);
		}
		protected PointLight3D(long raw) : base(raw) { }
		internal static new PointLight3D From(long raw)
		{
			return new PointLight3D(raw);
		}
		internal static new PointLight3D? FromOpt(long raw)
		{
			return raw == 0 ? null : new PointLight3D(raw);
		}
		/// <summary>
		/// The light color in sRGB space.
		/// </summary>
		public Color3 Color
		{
			set => Native.pointlight3d_set_color(Raw, (int)value.ToRGB());
			get => new Color3((uint)Native.pointlight3d_get_color(Raw));
		}
		/// <summary>
		/// The light intensity.
		/// </summary>
		public float Intensity
		{
			set => Native.pointlight3d_set_intensity(Raw, value);
			get => Native.pointlight3d_get_intensity(Raw);
		}
		/// <summary>
		/// The maximum effective range of the light.
		/// </summary>
		public float Range
		{
			set => Native.pointlight3d_set_range(Raw, value);
			get => Native.pointlight3d_get_range(Raw);
		}
		/// <summary>
		/// Creates a point light.
		/// </summary>
		public PointLight3D() : this(Native.pointlight3d_new()) { }
	}
} // namespace Dora
