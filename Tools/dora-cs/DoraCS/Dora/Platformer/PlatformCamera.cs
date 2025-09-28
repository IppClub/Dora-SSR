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
		public static extern int32_t platformer_platformcamera_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformcamera_set_position(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformcamera_get_position(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformcamera_set_rotation(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_platformcamera_get_rotation(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformcamera_set_zoom(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float platformer_platformcamera_get_zoom(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformcamera_set_boundary(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformcamera_get_boundary(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformcamera_set_follow_ratio(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformcamera_get_follow_ratio(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformcamera_set_follow_offset(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformcamera_get_follow_offset(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformcamera_set_follow_target(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void platformer_platformcamera_set_follow_target_null(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformcamera_get_follow_target(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t platformer_platformcamera_new(int64_t name);
	}
} // namespace Dora

namespace Dora.Platformer
{
	/// A platform camera for 2D platformer games that can track a game unit's movement and keep it within the camera's view.
	public partial class PlatformCamera : Camera
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.node_type(), From);
		}
		protected PlatformCamera(long raw) : base(raw) { }
		internal static new PlatformCamera From(long raw)
		{
			return new PlatformCamera(raw);
		}
		internal static new PlatformCamera? FromOpt(long raw)
		{
			return raw == 0 ? null : new PlatformCamera(raw);
		}
		/// The camera's position.
		public Vec2 Position
		{
			set => Native.platformer_platformcamera_set_position(Raw, value.Raw);
			get => Vec2.From(Native.platformer_platformcamera_get_position(Raw));
		}
		/// The camera's rotation in degrees.
		public float Rotation
		{
			set => Native.platformer_platformcamera_set_rotation(Raw, value);
			get => Native.platformer_platformcamera_get_rotation(Raw);
		}
		/// The camera's zoom factor, 1.0 means the normal size, 2.0 mean zoom to doubled size.
		public float Zoom
		{
			set => Native.platformer_platformcamera_set_zoom(Raw, value);
			get => Native.platformer_platformcamera_get_zoom(Raw);
		}
		/// The rectangular area within which the camera is allowed to view.
		public Rect Boundary
		{
			set => Native.platformer_platformcamera_set_boundary(Raw, value.Raw);
			get => Dora.Rect.From(Native.platformer_platformcamera_get_boundary(Raw));
		}
		/// the ratio at which the camera should move to keep up with the target's position.
		/// For example, set to `Vec2(1.0, 1.0)`, then the camera will keep up to the target's position right away.
		/// Set to Vec2(0.5, 0.5) or smaller value, then the camera will move halfway to the target's position each frame, resulting in a smooth and gradual movement.
		public Vec2 FollowRatio
		{
			set => Native.platformer_platformcamera_set_follow_ratio(Raw, value.Raw);
			get => Vec2.From(Native.platformer_platformcamera_get_follow_ratio(Raw));
		}
		/// the offset at which the camera should follow the target.
		public Vec2 FollowOffset
		{
			set => Native.platformer_platformcamera_set_follow_offset(Raw, value.Raw);
			get => Vec2.From(Native.platformer_platformcamera_get_follow_offset(Raw));
		}
		/// the game unit that the camera should track.
		public Node? FollowTarget
		{
			set
			{
				if (value == null) Native.platformer_platformcamera_set_follow_target_null(Raw);
				else Native.platformer_platformcamera_set_follow_target(Raw, value.Raw);
			}
			get => Node.FromOpt(Native.platformer_platformcamera_get_follow_target(Raw));
		}
		/// Creates a new instance of `PlatformCamera`.
		///
		/// # Arguments
		///
		/// * `name` - An optional string that specifies the name of the new instance. Default is an empty string.
		///
		/// # Returns
		///
		/// * A new `PlatformCamera` instance.
		public PlatformCamera(string name) : this(Native.platformer_platformcamera_new(Bridge.FromString(name))) { }
	}
} // namespace Dora.Platformer
