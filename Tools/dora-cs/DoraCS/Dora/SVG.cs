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
		public static extern int32_t svg_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float svgdef_get_width(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float svgdef_get_height(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void svgdef_render(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t svgdef_new(int64_t filename);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A struct used for Scalable Vector Graphics rendering.
	/// </summary>
	public partial class SVG : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.svg_type(), From);
		}
		protected SVG(long raw) : base(raw) { }
		internal static new SVG From(long raw)
		{
			return new SVG(raw);
		}
		internal static new SVG? FromOpt(long raw)
		{
			return raw == 0 ? null : new SVG(raw);
		}
		/// <summary>
		/// The width of the SVG object.
		/// </summary>
		public float Width
		{
			get => Native.svgdef_get_width(Raw);
		}
		/// <summary>
		/// The height of the SVG object.
		/// </summary>
		public float Height
		{
			get => Native.svgdef_get_height(Raw);
		}
		/// <summary>
		/// Renders the SVG object, should be called every frame for the render result to appear.
		/// </summary>
		public void Render()
		{
			Native.svgdef_render(Raw);
		}
		/// <summary>
		/// Creates a new SVG object from the specified SVG file.
		/// </summary>
		/// <param name="filename">The path to the SVG format file.</param>
		/// <returns>The created SVG object.</returns>
		public SVG(string filename) : this(Native.svgdef_new(Bridge.FromString(filename))) { }
		public static SVG? TryCreate(string filename)
		{
			var raw = Native.svgdef_new(Bridge.FromString(filename));
			return raw == 0 ? null : new SVG(raw);
		}
	}
} // namespace Dora
