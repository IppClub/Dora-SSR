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
		public static extern int32_t spriteeffect_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spriteeffect_new(int64_t vert_shader, int64_t frag_shader);
	}
} // namespace Dora

namespace Dora
{
	/// A struct that is a specialization of Effect for rendering 2D sprites.
	public partial class SpriteEffect : Effect
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.spriteeffect_type(), From);
		}
		protected SpriteEffect(long raw) : base(raw) { }
		internal static new SpriteEffect From(long raw)
		{
			return new SpriteEffect(raw);
		}
		internal static new SpriteEffect? FromOpt(long raw)
		{
			return raw == 0 ? null : new SpriteEffect(raw);
		}
		/// A method that allows you to create a new SpriteEffect object.
		///
		/// # Arguments
		///
		/// * `vert_shader` - The vertex shader file string.
		/// * `frag_shader` - The fragment shader file string. A shader file string must be one of the formats:
		///     * "builtin:" + theBuiltinShaderName
		///     * "Shader/compiled_shader_file.bin"
		///
		/// # Returns
		///
		/// * `SpriteEffect` - A new SpriteEffect object.
		public SpriteEffect(string vert_shader, string frag_shader) : this(Native.spriteeffect_new(Bridge.FromString(vert_shader), Bridge.FromString(frag_shader))) { }
	}
} // namespace Dora
