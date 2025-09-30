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
		public static extern void rect_release(int64_t raw);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_origin(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t rect_get_origin(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_size(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t rect_get_size(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_x(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_x(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_y(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_y(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_width(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_width(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_height(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_height(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_left(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_left(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_right(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_right(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_center_x(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_center_x(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_center_y(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_center_y(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_bottom(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_bottom(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_top(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float rect_get_top(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_lower_bound(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t rect_get_lower_bound(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set_upper_bound(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t rect_get_upper_bound(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void rect_set(int64_t self, float x, float y, float width, float height);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t rect_contains_point(int64_t self, int64_t point);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t rect_intersects_rect(int64_t self, int64_t rect);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t rect_equals(int64_t self, int64_t other);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t rect_new(int64_t origin, int64_t size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t rect_zero();
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A rectangle object with a left-bottom origin position and a size.
	/// </summary>
	public partial class Rect
	{
		private Rect(long raw)
		{
			if (raw == 0) throw new InvalidOperationException("failed to create Rect");
			Raw = raw;
		}
		~Rect()
		{
			Native.rect_release(Raw);
		}
		internal long Raw { get; private set; }
		internal static Rect From(long raw)
		{
			return new Rect(raw);
		}
		/// <summary>
		/// The position of the origin of the rectangle.
		/// </summary>
		public Vec2 Origin
		{
			set => Native.rect_set_origin(Raw, value.Raw);
			get => Vec2.From(Native.rect_get_origin(Raw));
		}
		/// <summary>
		/// The dimensions of the rectangle.
		/// </summary>
		public Size Size
		{
			set => Native.rect_set_size(Raw, value.Raw);
			get => Size.From(Native.rect_get_size(Raw));
		}
		/// <summary>
		/// The x-coordinate of the origin of the rectangle.
		/// </summary>
		public float X
		{
			set => Native.rect_set_x(Raw, value);
			get => Native.rect_get_x(Raw);
		}
		/// <summary>
		/// The y-coordinate of the origin of the rectangle.
		/// </summary>
		public float Y
		{
			set => Native.rect_set_y(Raw, value);
			get => Native.rect_get_y(Raw);
		}
		/// <summary>
		/// The width of the rectangle.
		/// </summary>
		public float Width
		{
			set => Native.rect_set_width(Raw, value);
			get => Native.rect_get_width(Raw);
		}
		/// <summary>
		/// The height of the rectangle.
		/// </summary>
		public float Height
		{
			set => Native.rect_set_height(Raw, value);
			get => Native.rect_get_height(Raw);
		}
		/// <summary>
		/// The left edge in x-axis of the rectangle.
		/// </summary>
		public float Left
		{
			set => Native.rect_set_left(Raw, value);
			get => Native.rect_get_left(Raw);
		}
		/// <summary>
		/// The right edge in x-axis of the rectangle.
		/// </summary>
		public float Right
		{
			set => Native.rect_set_right(Raw, value);
			get => Native.rect_get_right(Raw);
		}
		/// <summary>
		/// The x-coordinate of the center of the rectangle.
		/// </summary>
		public float CenterX
		{
			set => Native.rect_set_center_x(Raw, value);
			get => Native.rect_get_center_x(Raw);
		}
		/// <summary>
		/// The y-coordinate of the center of the rectangle.
		/// </summary>
		public float CenterY
		{
			set => Native.rect_set_center_y(Raw, value);
			get => Native.rect_get_center_y(Raw);
		}
		/// <summary>
		/// The bottom edge in y-axis of the rectangle.
		/// </summary>
		public float Bottom
		{
			set => Native.rect_set_bottom(Raw, value);
			get => Native.rect_get_bottom(Raw);
		}
		/// <summary>
		/// The top edge in y-axis of the rectangle.
		/// </summary>
		public float Top
		{
			set => Native.rect_set_top(Raw, value);
			get => Native.rect_get_top(Raw);
		}
		/// <summary>
		/// The lower bound (left-bottom) of the rectangle.
		/// </summary>
		public Vec2 LowerBound
		{
			set => Native.rect_set_lower_bound(Raw, value.Raw);
			get => Vec2.From(Native.rect_get_lower_bound(Raw));
		}
		/// <summary>
		/// The upper bound (right-top) of the rectangle.
		/// </summary>
		public Vec2 UpperBound
		{
			set => Native.rect_set_upper_bound(Raw, value.Raw);
			get => Vec2.From(Native.rect_get_upper_bound(Raw));
		}
		/// <summary>
		/// Sets the properties of the rectangle.
		/// </summary>
		/// <param name="x">The x-coordinate of the origin of the rectangle.</param>
		/// <param name="y">The y-coordinate of the origin of the rectangle.</param>
		/// <param name="width">The width of the rectangle.</param>
		/// <param name="height">The height of the rectangle.</param>
		public void Set(float x, float y, float width, float height)
		{
			Native.rect_set(Raw, x, y, width, height);
		}
		/// <summary>
		/// Checks if a point is inside the rectangle.
		/// </summary>
		/// <param name="point">The point to check, represented by a Vec2 object.</param>
		/// <returns>Whether or not the point is inside the rectangle.</returns>
		public bool ContainsPoint(Vec2 point)
		{
			return Native.rect_contains_point(Raw, point.Raw) != 0;
		}
		/// <summary>
		/// Checks if the rectangle intersects with another rectangle.
		/// </summary>
		/// <param name="rect">The other rectangle to check for intersection with, represented by a Rect object.</param>
		/// <returns>Whether or not the rectangles intersect.</returns>
		public bool IntersectsRect(Rect rect)
		{
			return Native.rect_intersects_rect(Raw, rect.Raw) != 0;
		}
		/// <summary>
		/// Checks if two rectangles are equal.
		/// </summary>
		/// <param name="other">The other rectangle to compare to, represented by a Rect object.</param>
		/// <returns>Whether or not the two rectangles are equal.</returns>
		public bool Equals(Rect other)
		{
			return Native.rect_equals(Raw, other.Raw) != 0;
		}
		/// <summary>
		/// Creates a new rectangle object using a Vec2 object for the origin and a Size object for the size.
		/// </summary>
		/// <param name="origin">The origin of the rectangle, represented by a Vec2 object.</param>
		/// <param name="size">The size of the rectangle, represented by a Size object.</param>
		/// <returns>A new rectangle object.</returns>
		public Rect(Vec2 origin, Size size) : this(Native.rect_new(origin.Raw, size.Raw)) { }
		/// <summary>
		/// Gets a rectangle object with all properties set to 0.
		/// </summary>
		public static Rect Zero()
		{
			return Dora.Rect.From(Native.rect_zero());
		}
	}
} // namespace Dora
