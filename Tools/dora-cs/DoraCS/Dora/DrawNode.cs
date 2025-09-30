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
		public static extern int32_t drawnode_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_set_depth_write(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t drawnode_is_depth_write(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_set_blend_func(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t drawnode_get_blend_func(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_dot(int64_t self, int64_t pos, float radius, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_segment(int64_t self, int64_t from, int64_t to, float radius, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_polygon(int64_t self, int64_t verts, int32_t fill_color, float border_width, int32_t border_color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_vertices(int64_t self, int64_t verts);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_clear(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t drawnode_new();
	}
} // namespace Dora

namespace Dora
{
	/// A scene node that draws simple shapes such as dots, lines, and polygons.
	public partial class DrawNode : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.drawnode_type(), From);
		}
		protected DrawNode(long raw) : base(raw) { }
		internal static new DrawNode From(long raw)
		{
			return new DrawNode(raw);
		}
		internal static new DrawNode? FromOpt(long raw)
		{
			return raw == 0 ? null : new DrawNode(raw);
		}
		/// whether to write to the depth buffer when drawing (default is false).
		public bool IsDepthWrite
		{
			set => Native.drawnode_set_depth_write(Raw, value ? 1 : 0);
			get => Native.drawnode_is_depth_write(Raw) != 0;
		}
		/// the blend function for the draw node.
		public BlendFunc BlendFunc
		{
			set => Native.drawnode_set_blend_func(Raw, value.Raw);
			get => BlendFunc.From(Native.drawnode_get_blend_func(Raw));
		}
		/// Draws a dot at a specified position with a specified radius and color.
		///
		/// # Arguments
		///
		/// * `pos` - The position of the dot.
		/// * `radius` - The radius of the dot.
		/// * `color` - The color of the dot.
		public void DrawDot(Vec2 pos, float radius, Color color)
		{
			Native.drawnode_draw_dot(Raw, pos.Raw, radius, (int)color.ToARGB());
		}
		/// Draws a line segment between two points with a specified radius and color.
		///
		/// # Arguments
		///
		/// * `from` - The starting point of the line.
		/// * `to` - The ending point of the line.
		/// * `radius` - The radius of the line.
		/// * `color` - The color of the line.
		public void DrawSegment(Vec2 from, Vec2 to, float radius, Color color)
		{
			Native.drawnode_draw_segment(Raw, from.Raw, to.Raw, radius, (int)color.ToARGB());
		}
		/// Draws a polygon defined by a list of vertices with a specified fill color and border.
		///
		/// # Arguments
		///
		/// * `verts` - The vertices of the polygon.
		/// * `fill_color` - The fill color of the polygon.
		/// * `border_width` - The width of the border.
		/// * `border_color` - The color of the border.
		public void DrawPolygon(IEnumerable<Vec2> verts, Color fill_color, float border_width, Color border_color)
		{
			Native.drawnode_draw_polygon(Raw, Bridge.FromArray(verts), (int)fill_color.ToARGB(), border_width, (int)border_color.ToARGB());
		}
		/// Draws a set of vertices as triangles, each vertex with its own color.
		///
		/// # Arguments
		///
		/// * `verts` - The list of vertices and their colors. Each element is a tuple where the first element is a `Vec2` and the second element is a `Color`.
		public void DrawVertices(IEnumerable<VertexColor> verts)
		{
			Native.drawnode_draw_vertices(Raw, Bridge.FromArray(verts));
		}
		/// Clears all previously drawn shapes from the node.
		public void Clear()
		{
			Native.drawnode_clear(Raw);
		}
		/// Creates a new DrawNode object.
		///
		/// # Returns
		///
		/// * A new `DrawNode` object.
		public DrawNode() : this(Native.drawnode_new()) { }
	}
} // namespace Dora
