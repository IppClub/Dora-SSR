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
		public static extern int32_t touch_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void touch_set_enabled(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t touch_is_enabled(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t touch_is_first(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t touch_get_id(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t touch_get_delta(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t touch_get_location(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t touch_get_world_location(int64_t self);
	}
} // namespace Dora

namespace Dora
{
	/// Represents a touch input or mouse click event.
	public partial class Touch : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.touch_type(), From);
		}
		protected Touch(long raw) : base(raw) { }
		internal static new Touch From(long raw)
		{
			return new Touch(raw);
		}
		internal static new Touch? FromOpt(long raw)
		{
			return raw == 0 ? null : new Touch(raw);
		}
		/// whether touch input is enabled or not.
		public bool IsEnabled
		{
			set => Native.touch_set_enabled(Raw, value ? 1 : 0);
			get => Native.touch_is_enabled(Raw) != 0;
		}
		/// whether this is the first touch event when multi-touches exist.
		public bool IsFirst
		{
			get => Native.touch_is_first(Raw) != 0;
		}
		/// the unique identifier assigned to this touch event.
		public int Id
		{
			get => Native.touch_get_id(Raw);
		}
		/// the amount and direction of movement since the last touch event.
		public Vec2 Delta
		{
			get => Vec2.From(Native.touch_get_delta(Raw));
		}
		/// the location of the touch event in the node's local coordinate system.
		public Vec2 Location
		{
			get => Vec2.From(Native.touch_get_location(Raw));
		}
		/// the location of the touch event in the world coordinate system.
		public Vec2 WorldLocation
		{
			get => Vec2.From(Native.touch_get_world_location(Raw));
		}
	}
} // namespace Dora
