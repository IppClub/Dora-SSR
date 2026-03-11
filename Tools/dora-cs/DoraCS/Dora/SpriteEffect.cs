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
		public static extern int32_t spriteeffect_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t spriteeffect_new(int64_t vertShader, int64_t fragShader);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A struct that is a specialization of Effect for rendering 2D sprites.
	/// </summary>
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
		/// <summary>
		/// A method that allows you to create a new SpriteEffect object.
		/// </summary>
		/// <param name="vertShader">The vertex shader file string.</param>
		/// <param name="fragShader">The fragment shader file string.</param>
		/// <remarks>
		/// A shader file string must be one of the formats:
		/// <c>builtin:</c> + theBuiltinShaderName
		/// <c>shader_compiled_file.bin</c>
		/// <c>Shader/shader_source_file.sc</c>
		///
		/// Details:
		/// <list type="bullet">
		/// <item><description><c>"builtin:" + name</c> loads an embedded built-in shader.</description></item>
		/// <item><description>For <c>.sc</c> files, the given path is loaded as shader source and compiled immediately.</description></item>
		/// <item><description>For <c>.bin</c> files, if the given path exists, it is loaded directly.</description></item>
		/// <item><description>Otherwise the engine tries <c>renderer_dir/filename.bin</c>, where <c>renderer_dir</c> depends on the active backend, such as <c>dx11</c>, <c>metal</c>, <c>glsl</c>, <c>essl</c>, or <c>spirv</c>.</description></item>
		/// </list>
		/// </remarks>
		/// <returns>A new SpriteEffect object.</returns>
		public SpriteEffect(string vertShader, string fragShader) : this(Native.spriteeffect_new(Bridge.FromString(vertShader), Bridge.FromString(fragShader))) { }
	}
} // namespace Dora
