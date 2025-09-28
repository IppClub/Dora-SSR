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
		public static extern int32_t line_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void line_set_depth_write(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t line_is_depth_write(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void line_set_blend_func(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t line_get_blend_func(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void line_add(int64_t self, int64_t verts, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void line_set(int64_t self, int64_t verts, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void line_clear(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t line_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t line_with_vec_color(int64_t verts, int32_t color);
	}
} // namespace Dora

namespace Dora
{
	/// A struct provides functionality for drawing lines using vertices.
	public partial class Line : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.node_type(), From);
		}
		protected Line(long raw) : base(raw) { }
		internal static new Line From(long raw)
		{
			return new Line(raw);
		}
		internal static new Line? FromOpt(long raw)
		{
			return raw == 0 ? null : new Line(raw);
		}
		/// whether the depth should be written. (Default is false)
		public bool IsDepthWrite
		{
			set => Native.line_set_depth_write(Raw, value ? 1 : 0);
			get => Native.line_is_depth_write(Raw) != 0;
		}
		/// the blend function for the line node.
		public BlendFunc BlendFunc
		{
			set => Native.line_set_blend_func(Raw, value.Raw);
			get => BlendFunc.From(Native.line_get_blend_func(Raw));
		}
		/// Adds vertices to the line.
		///
		/// # Arguments
		///
		/// * `verts` - A vector of vertices to add to the line.
		/// * `color` - Optional. The color of the line.
		public void Add(IEnumerable<Vec2> verts, Color color)
		{
			Native.line_add(Raw, Bridge.FromArray(verts), (int)color.ToArgb());
		}
		/// Sets vertices of the line.
		///
		/// # Arguments
		///
		/// * `verts` - A vector of vertices to set.
		/// * `color` - Optional. The color of the line.
		public void Set(IEnumerable<Vec2> verts, Color color)
		{
			Native.line_set(Raw, Bridge.FromArray(verts), (int)color.ToArgb());
		}
		/// Clears all the vertices of line.
		public void Clear()
		{
			Native.line_clear(Raw);
		}
		/// Creates and returns a new empty Line object.
		///
		/// # Returns
		///
		/// * A new `Line` object.
		public Line() : this(Native.line_new()) { }
		/// Creates and returns a new Line object.
		///
		/// # Arguments
		///
		/// * `verts` - A vector of vertices to add to the line.
		/// * `color` - The color of the line.
		///
		/// # Returns
		///
		/// * A new `Line` object.
		public Line(IEnumerable<Vec2> verts, Color color) : this(Native.line_with_vec_color(Bridge.FromArray(verts), (int)color.ToArgb())) { }
	}
} // namespace Dora
