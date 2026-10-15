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
		public static extern int32_t camera_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t camera_get_name(int64_t self);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A struct for Camera object in the game engine.
	/// </summary>
	public partial class Camera : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.camera_type(), From);
		}
		protected Camera(long raw) : base(raw) { }
		internal static new Camera From(long raw)
		{
			return new Camera(raw);
		}
		internal static new Camera? FromOpt(long raw)
		{
			return raw == 0 ? null : new Camera(raw);
		}
		/// <summary>
		/// The name of the Camera.
		/// </summary>
		public string Name
		{
			get => Bridge.ToString(Native.camera_get_name(Raw));
		}
	}
} // namespace Dora
