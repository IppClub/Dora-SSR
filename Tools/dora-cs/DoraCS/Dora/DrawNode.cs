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
		public static extern void drawnode_draw_circle(int64_t self, int64_t center, float radius, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_rect(int64_t self, int64_t rect, int32_t fillColor, float borderWidth, int32_t borderColor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_ellipse(int64_t self, int64_t center, float radiusX, float radiusY, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_segment(int64_t self, int64_t from, int64_t to, float radius, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_polyline(int64_t self, int64_t verts, float radius, int32_t color, int32_t closed);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_arc(int64_t self, int64_t center, float radius, float startAngle, float endAngle, float lineRadius, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_rounded_rect(int64_t self, int64_t rect, float cornerRadius, int32_t fillColor, float borderWidth, int32_t borderColor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_ring(int64_t self, int64_t center, float innerRadius, float outerRadius, int32_t fillColor, float borderWidth, int32_t borderColor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_sector(int64_t self, int64_t center, float radius, float startAngle, float endAngle, int32_t fillColor, float borderWidth, int32_t borderColor);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_quadratic_bezier(int64_t self, int64_t from, int64_t control, int64_t to, float radius, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_cubic_bezier(int64_t self, int64_t from, int64_t control1, int64_t control2, int64_t to, float radius, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void drawnode_draw_polygon(int64_t self, int64_t verts, int32_t fillColor, float borderWidth, int32_t borderColor);
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
	/// <summary>
	/// A scene node that draws simple shapes such as dots, lines, and polygons.
	/// </summary>
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
		/// <summary>
		/// Whether to write to the depth buffer when drawing (default is false).
		/// </summary>
		public bool IsDepthWrite
		{
			set => Native.drawnode_set_depth_write(Raw, value ? 1 : 0);
			get => Native.drawnode_is_depth_write(Raw) != 0;
		}
		/// <summary>
		/// The blend function for the draw node.
		/// </summary>
		public BlendFunc BlendFunc
		{
			set => Native.drawnode_set_blend_func(Raw, value.Raw);
			get => BlendFunc.From(Native.drawnode_get_blend_func(Raw));
		}
		/// <summary>
		/// Draws a dot at a specified position with a specified radius and color.
		/// </summary>
		/// <param name="pos">The position of the dot.</param>
		/// <param name="radius">The radius of the dot.</param>
		/// <param name="color">The color of the dot.</param>
		public void DrawDot(Vec2 pos, float radius, Color color)
		{
			Native.drawnode_draw_dot(Raw, pos.Raw, radius, (int)color.ToARGB());
		}
		/// <summary>
		/// Draws a circle at a specified center with a specified radius and color.
		/// </summary>
		/// <param name="center">The center of the circle.</param>
		/// <param name="radius">The radius of the circle.</param>
		/// <param name="color">The color of the circle.</param>
		public void DrawCircle(Vec2 center, float radius, Color color)
		{
			Native.drawnode_draw_circle(Raw, center.Raw, radius, (int)color.ToARGB());
		}
		/// <summary>
		/// Draws a rectangle with an optional border.
		/// </summary>
		/// <param name="rect">The rectangle to draw.</param>
		/// <param name="fillColor">The fill color of the rectangle.</param>
		/// <param name="borderWidth">Half of the border width, extending to both sides of the outline.</param>
		/// <param name="borderColor">The color of the border.</param>
		public void DrawRect(Rect rect, Color fillColor, float borderWidth, Color borderColor)
		{
			Native.drawnode_draw_rect(Raw, rect.Raw, (int)fillColor.ToARGB(), borderWidth, (int)borderColor.ToARGB());
		}
		/// <summary>
		/// Draws a filled ellipse at a specified center.
		/// </summary>
		/// <param name="center">The center of the ellipse.</param>
		/// <param name="radiusX">The horizontal radius of the ellipse.</param>
		/// <param name="radiusY">The vertical radius of the ellipse.</param>
		/// <param name="color">The color of the ellipse.</param>
		public void DrawEllipse(Vec2 center, float radiusX, float radiusY, Color color)
		{
			Native.drawnode_draw_ellipse(Raw, center.Raw, radiusX, radiusY, (int)color.ToARGB());
		}
		/// <summary>
		/// Draws a line segment between two points with a specified radius and color.
		/// </summary>
		/// <param name="from">The starting point of the line.</param>
		/// <param name="to">The ending point of the line.</param>
		/// <param name="radius">The radius of the line.</param>
		/// <param name="color">The color of the line.</param>
		public void DrawSegment(Vec2 from, Vec2 to, float radius, Color color)
		{
			Native.drawnode_draw_segment(Raw, from.Raw, to.Raw, radius, (int)color.ToARGB());
		}
		/// <summary>
		/// Draws a connected stroke with round caps and miter joins, beveling long miters. Radius is half the width; adjacent duplicates are ignored.
		/// </summary>
		/// <param name="verts">The vertices of the polyline.</param>
		/// <param name="radius">Half of the line width.</param>
		/// <param name="color">The color of the polyline.</param>
		/// <param name="closed">Whether to connect the last vertex back to the first.</param>
		public void DrawPolyline(IEnumerable<Vec2> verts, float radius, Color color, bool closed)
		{
			Native.drawnode_draw_polyline(Raw, Bridge.FromArray(verts), radius, (int)color.ToARGB(), closed ? 1 : 0);
		}
		/// <summary>
		/// Draws an arc in degrees: zero points along +X and increasing angles turn toward +Y. The signed sweep is limited to one revolution; full circles close without caps. Line radius is half the width.
		/// </summary>
		/// <param name="center">The center of the arc.</param>
		/// <param name="radius">The radius from the center to the arc.</param>
		/// <param name="startAngle">The starting angle in degrees.</param>
		/// <param name="endAngle">The ending angle in degrees.</param>
		/// <param name="lineRadius">Half of the line width.</param>
		/// <param name="color">The color of the arc.</param>
		public void DrawArc(Vec2 center, float radius, float startAngle, float endAngle, float lineRadius, Color color)
		{
			Native.drawnode_draw_arc(Raw, center.Raw, radius, startAngle, endAngle, lineRadius, (int)color.ToARGB());
		}
		/// <summary>Draws a rounded rectangle. The corner radius is clamped to half the smaller dimension; zero draws a rectangle. Border width is a half width centered on the outline.</summary>
		public void DrawRoundedRect(Rect rect, float cornerRadius, Color fillColor, float borderWidth, Color borderColor)
		{
			Native.drawnode_draw_rounded_rect(Raw, rect.Raw, cornerRadius, (int)fillColor.ToARGB(), borderWidth, (int)borderColor.ToARGB());
		}
		/// <summary>Draws a ring with 0 <= innerRadius < outerRadius. Zero inner radius fills the center. Optional centered borders surround both contours; border width is a half width.</summary>
		public void DrawRing(Vec2 center, float innerRadius, float outerRadius, Color fillColor, float borderWidth, Color borderColor)
		{
			Native.drawnode_draw_ring(Raw, center.Raw, innerRadius, outerRadius, (int)fillColor.ToARGB(), borderWidth, (int)borderColor.ToARGB());
		}
		/// <summary>Draws a filled sector in degrees from +X toward +Y. Signed sweep is limited to one revolution. Full circles omit radial edges; equal angles draw nothing. Border width is a half width.</summary>
		public void DrawSector(Vec2 center, float radius, float startAngle, float endAngle, Color fillColor, float borderWidth, Color borderColor)
		{
			Native.drawnode_draw_sector(Raw, center.Raw, radius, startAngle, endAngle, (int)fillColor.ToARGB(), borderWidth, (int)borderColor.ToARGB());
		}
		/// <summary>Draws a quadratic Bezier stroke with round caps; coincident endpoints close the stroke. Radius is half the width. Adaptive subdivision targets 0.25 local units, with at most 1024 segments.</summary>
		public void DrawQuadraticBezier(Vec2 from, Vec2 control, Vec2 to, float radius, Color color)
		{
			Native.drawnode_draw_quadratic_bezier(Raw, from.Raw, control.Raw, to.Raw, radius, (int)color.ToARGB());
		}
		/// <summary>Draws a cubic Bezier stroke with round caps; coincident endpoints close the stroke. Radius is half the width. Adaptive subdivision targets 0.25 local units, with at most 1024 segments.</summary>
		public void DrawCubicBezier(Vec2 from, Vec2 control1, Vec2 control2, Vec2 to, float radius, Color color)
		{
			Native.drawnode_draw_cubic_bezier(Raw, from.Raw, control1.Raw, control2.Raw, to.Raw, radius, (int)color.ToARGB());
		}
		/// <summary>
		/// Draws a simple convex or concave polygon in boundary order with either winding. Self-intersections and holes are unsupported; the border is centered on the outline.
		/// </summary>
		/// <param name="verts">The vertices of the polygon.</param>
		/// <param name="fillColor">The fill color of the polygon.</param>
		/// <param name="borderWidth">Half of the border width, extending to both sides of the outline.</param>
		/// <param name="borderColor">The color of the border.</param>
		public void DrawPolygon(IEnumerable<Vec2> verts, Color fillColor, float borderWidth, Color borderColor)
		{
			Native.drawnode_draw_polygon(Raw, Bridge.FromArray(verts), (int)fillColor.ToARGB(), borderWidth, (int)borderColor.ToARGB());
		}
		/// <summary>
		/// Draws a set of vertices as triangles, each vertex with its own color.
		/// </summary>
		/// <param name="verts">The list of vertices and their colors. Each element is a tuple where the first element is a `Vec2` and the second element is a `Color`.</param>
		public void DrawVertices(IEnumerable<VertexColor> verts)
		{
			Native.drawnode_draw_vertices(Raw, Bridge.FromArray(verts));
		}
		/// <summary>
		/// Clears all previously drawn shapes from the node.
		/// </summary>
		public void Clear()
		{
			Native.drawnode_clear(Raw);
		}
		/// <summary>
		/// Creates a new DrawNode object.
		/// </summary>
		public DrawNode() : this(Native.drawnode_new()) { }
	}
} // namespace Dora
