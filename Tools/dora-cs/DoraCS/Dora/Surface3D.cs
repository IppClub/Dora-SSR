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
		public static extern int32_t surface3d_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void surface3d_set_content(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t surface3d_get_content(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void surface3d_set_size(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t surface3d_get_size(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void surface3d_set_pixel_size(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t surface3d_get_pixel_size(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void surface3d_set_billboard(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t surface3d_get_billboard(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t surface3d_is_using_texture(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t surface3d_new(int64_t content, int64_t size, int64_t pixelSize);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>A 2D node subtree displayed in a 3D scene.</summary>
	public partial class Surface3D : Node3D
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.surface3d_type(), From);
		}
		protected Surface3D(long raw) : base(raw) { }
		internal static new Surface3D From(long raw)
		{
			return new Surface3D(raw);
		}
		internal static new Surface3D? FromOpt(long raw)
		{
			return raw == 0 ? null : new Surface3D(raw);
		}
		public Node Content
		{
			set => Native.surface3d_set_content(Raw, value.Raw);
			get => Node.From(Native.surface3d_get_content(Raw));
		}
		/// <summary>Physical width and height in world units.</summary>
		public Size Size
		{
			set => Native.surface3d_set_size(Raw, value.Raw);
			get => Size.From(Native.surface3d_get_size(Raw));
		}
		/// <summary>Raster size used by the automatic render-target fallback.</summary>
		public Size PixelSize
		{
			set => Native.surface3d_set_pixel_size(Raw, value.Raw);
			get => Size.From(Native.surface3d_get_pixel_size(Raw));
		}
		public Billboard Billboard
		{
			set => Native.surface3d_set_billboard(Raw, (int)value);
			get => (Billboard)Native.surface3d_get_billboard(Raw);
		}
		public bool IsUsingTexture
		{
			get => Native.surface3d_is_using_texture(Raw) != 0;
		}
		public Surface3D(Node content, Size size, Size pixelSize) : this(Native.surface3d_new(content.Raw, size.Raw, pixelSize.Raw)) { }
	}
} // namespace Dora
