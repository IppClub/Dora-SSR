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
		public static extern int32_t effect_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void effect_add(int64_t self, int64_t pass);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t effect_get(int64_t self, int64_t index);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void effect_clear(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t effect_new(int64_t vertShader, int64_t fragShader);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A struct for managing multiple render pass objects.
	/// </summary>
	/// <summary>
	/// Effect objects allow you to combine multiple passes to create more complex shader effects.
	/// </summary>
	public partial class Effect : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.effect_type(), From);
		}
		protected Effect(long raw) : base(raw) { }
		internal static new Effect From(long raw)
		{
			return new Effect(raw);
		}
		internal static new Effect? FromOpt(long raw)
		{
			return raw == 0 ? null : new Effect(raw);
		}
		/// <summary>
		/// Adds a Pass object to this Effect.
		/// </summary>
		/// <param name="pass">The Pass object to add.</param>
		public void Add(Pass pass)
		{
			Native.effect_add(Raw, pass.Raw);
		}
		/// <summary>
		/// Retrieves a Pass object from this Effect by index.
		/// </summary>
		/// <param name="index">The index of the Pass object to retrieve.</param>
		/// <returns>The Pass object at the given index.</returns>
		public Pass? Get(long index)
		{
			return Pass.FromOpt(Native.effect_get(Raw, index));
		}
		/// <summary>
		/// Removes all Pass objects from this Effect.
		/// </summary>
		public void Clear()
		{
			Native.effect_clear(Raw);
		}
		/// <summary>
		/// A method that allows you to create a new Effect object.
		/// </summary>
		/// <param name="vertShader">The vertex shader file string.</param>
		/// <param name="fragShader">The fragment shader file string. A shader file string must be one of the formats:</param>
		/// <returns>A new Effect object.</returns>
		public Effect(string vertShader, string fragShader) : this(Native.effect_new(Bridge.FromString(vertShader), Bridge.FromString(fragShader))) { }
	}
} // namespace Dora
