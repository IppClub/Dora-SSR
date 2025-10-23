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
		public static extern int32_t pass_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void pass_set_grab_pass(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t pass_is_grab_pass(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void pass_set(int64_t self, int64_t name, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void pass_set_vec4(int64_t self, int64_t name, float val1, float val2, float val3, float val4);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void pass_set_color(int64_t self, int64_t name, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t pass_new(int64_t vertShader, int64_t fragShader);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A struct representing a shader pass.
	/// </summary>
	public partial class Pass : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.pass_type(), From);
		}
		protected Pass(long raw) : base(raw) { }
		internal static new Pass From(long raw)
		{
			return new Pass(raw);
		}
		internal static new Pass? FromOpt(long raw)
		{
			return raw == 0 ? null : new Pass(raw);
		}
		/// <summary>
		/// Whether this Pass should be a grab pass.
		/// A grab pass will render a portion of game scene into a texture frame buffer.
		/// Then use this texture frame buffer as an input for next render pass.
		/// </summary>
		public bool IsGrabPass
		{
			set => Native.pass_set_grab_pass(Raw, value ? 1 : 0);
			get => Native.pass_is_grab_pass(Raw) != 0;
		}
		/// <summary>
		/// Sets the value of shader parameters.
		/// </summary>
		/// <param name="name">The name of the parameter to set.</param>
		/// <param name="val">The numeric value to set.</param>
		public void Set(string name, float val)
		{
			Native.pass_set(Raw, Bridge.FromString(name), val);
		}
		/// <summary>
		/// Sets the values of shader parameters.
		/// </summary>
		/// <param name="name">The name of the parameter to set.</param>
		/// <param name="val1">The first numeric value to set.</param>
		/// <param name="val2">An optional second numeric value to set.</param>
		/// <param name="val3">An optional third numeric value to set.</param>
		/// <param name="val4">An optional fourth numeric value to set.</param>
		public void SetVec4(string name, float val1, float val2 = 0.0f, float val3 = 0.0f, float val4 = 0.0f)
		{
			Native.pass_set_vec4(Raw, Bridge.FromString(name), val1, val2, val3, val4);
		}
		/// <summary>
		/// Another function that sets the values of shader parameters.
		/// Works the same as:
		/// pass.set("varName", color.r / 255.0, color.g / 255.0, color.b / 255.0, color.opacity);
		/// </summary>
		/// <param name="name">The name of the parameter to set.</param>
		/// <param name="val">The Color object to set.</param>
		public void SetColor(string name, Color val)
		{
			Native.pass_set_color(Raw, Bridge.FromString(name), (int)val.ToARGB());
		}
		/// <summary>
		/// Creates a new Pass object.
		/// </summary>
		/// <param name="vertShader">The vertex shader in binary form file string.</param>
		/// <param name="fragShader">The fragment shader file string. A shader file string must be one of the formats:</param>
		/// <returns>A new Pass object.</returns>
		public Pass(string vertShader, string fragShader) : this(Native.pass_new(Bridge.FromString(vertShader), Bridge.FromString(fragShader))) { }
	}
} // namespace Dora
