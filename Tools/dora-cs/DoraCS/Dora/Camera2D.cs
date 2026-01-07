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
		public static extern int32_t camera2d_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void camera2d_set_rotation(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float camera2d_get_rotation(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void camera2d_set_zoom(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float camera2d_get_zoom(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void camera2d_set_position(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t camera2d_get_position(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t camera2d_new(int64_t name);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A struct for 2D camera object in the game engine.
	/// </summary>
	public partial class Camera2D : Camera
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.camera2d_type(), From);
		}
		protected Camera2D(long raw) : base(raw) { }
		internal static new Camera2D From(long raw)
		{
			return new Camera2D(raw);
		}
		internal static new Camera2D? FromOpt(long raw)
		{
			return raw == 0 ? null : new Camera2D(raw);
		}
		/// <summary>
		/// The rotation angle of the camera in degrees.
		/// </summary>
		public float Rotation
		{
			set => Native.camera2d_set_rotation(Raw, value);
			get => Native.camera2d_get_rotation(Raw);
		}
		/// <summary>
		/// The factor by which to zoom the camera. If set to 1.0, the view is normal sized. If set to 2.0, items will appear double in size.
		/// </summary>
		public float Zoom
		{
			set => Native.camera2d_set_zoom(Raw, value);
			get => Native.camera2d_get_zoom(Raw);
		}
		/// <summary>
		/// The position of the camera in the game world.
		/// </summary>
		public Vec2 Position
		{
			set => Native.camera2d_set_position(Raw, value.Raw);
			get => Vec2.From(Native.camera2d_get_position(Raw));
		}
		/// <summary>
		/// Creates a new Camera2D object with the given name.
		/// </summary>
		/// <param name="name">The name of the Camera2D object.</param>
		/// <returns>A new instance of the Camera2D object.</returns>
		public Camera2D(string name = "") : this(Native.camera2d_new(Bridge.FromString(name))) { }
	}
} // namespace Dora
