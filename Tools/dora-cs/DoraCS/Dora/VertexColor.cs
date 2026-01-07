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
		public static extern void vertexcolor_release(int64_t raw);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void vertexcolor_set_vertex(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t vertexcolor_get_vertex(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void vertexcolor_set_color(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t vertexcolor_get_color(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t vertexcolor_new(int64_t vec, int32_t color);
	}
} // namespace Dora

namespace Dora
{
	public partial class VertexColor
	{
		private VertexColor(long raw)
		{
			if (raw == 0) throw new InvalidOperationException("failed to create VertexColor");
			Raw = raw;
		}
		~VertexColor()
		{
			Native.vertexcolor_release(Raw);
		}
		internal long Raw { get; private set; }
		internal static VertexColor From(long raw)
		{
			return new VertexColor(raw);
		}
		public Vec2 Vertex
		{
			set => Native.vertexcolor_set_vertex(Raw, value.Raw);
			get => Vec2.From(Native.vertexcolor_get_vertex(Raw));
		}
		public Color Color
		{
			set => Native.vertexcolor_set_color(Raw, (int)value.ToARGB());
			get => new Color((uint)Native.vertexcolor_get_color(Raw));
		}
		public VertexColor(Vec2 vec, Color color) : this(Native.vertexcolor_new(vec.Raw, (int)color.ToARGB())) { }
	}
} // namespace Dora
