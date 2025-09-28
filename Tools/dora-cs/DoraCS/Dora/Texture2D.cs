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
		public static extern int32_t texture2d_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t texture2d_get_width(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t texture2d_get_height(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t texture2d_with_file(int64_t filename);
	}
} // namespace Dora

namespace Dora
{
	/// A struct represents a 2D texture.
	public partial class Texture2D : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.texture2d_type(), From);
		}
		protected Texture2D(long raw) : base(raw) { }
		internal static new Texture2D From(long raw)
		{
			return new Texture2D(raw);
		}
		internal static new Texture2D? FromOpt(long raw)
		{
			return raw == 0 ? null : new Texture2D(raw);
		}
		/// the width of the texture, in pixels.
		public int Width
		{
			get => Native.texture2d_get_width(Raw);
		}
		/// the height of the texture, in pixels.
		public int Height
		{
			get => Native.texture2d_get_height(Raw);
		}
		/// Creates a texture object from the given file.
		///
		/// # Arguments
		///
		/// * `filename` - The file name of the texture.
		///
		/// # Returns
		///
		/// * `Texture2D` - The texture object.
		public Texture2D(string filename) : this(Native.texture2d_with_file(Bridge.FromString(filename))) { }
		public static Texture2D? TryCreate(string filename)
		{
			var raw = Native.texture2d_with_file(Bridge.FromString(filename));
			return raw == 0 ? null : new Texture2D(raw);
		}
	}
} // namespace Dora
