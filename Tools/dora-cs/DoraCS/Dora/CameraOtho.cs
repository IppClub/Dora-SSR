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
		public static extern int32_t cameraotho_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void cameraotho_set_position(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t cameraotho_get_position(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t cameraotho_new(int64_t name);
	}
} // namespace Dora

namespace Dora
{
	/// A struct for an orthographic camera object in the game engine.
	public partial class CameraOtho : Camera
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.cameraotho_type(), From);
		}
		protected CameraOtho(long raw) : base(raw) { }
		internal static new CameraOtho From(long raw)
		{
			return new CameraOtho(raw);
		}
		internal static new CameraOtho? FromOpt(long raw)
		{
			return raw == 0 ? null : new CameraOtho(raw);
		}
		/// the position of the camera in the game world.
		public Vec2 Position
		{
			set => Native.cameraotho_set_position(Raw, value.Raw);
			get => Vec2.From(Native.cameraotho_get_position(Raw));
		}
		/// Creates a new CameraOtho object with the given name.
		///
		/// # Arguments
		///
		/// * `name` - The name of the CameraOtho object.
		///
		/// # Returns
		///
		/// * `CameraOtho` - A new instance of the CameraOtho object.
		public CameraOtho(string name) : this(Native.cameraotho_new(Bridge.FromString(name))) { }
	}
} // namespace Dora
