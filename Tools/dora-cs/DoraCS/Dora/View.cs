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
		public static extern int64_t view_get_size();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float view_get_standard_distance();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float view_get_aspect_ratio();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void view_set_near_plane_distance(float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float view_get_near_plane_distance();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void view_set_far_plane_distance(float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float view_get_far_plane_distance();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void view_set_field_of_view(float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float view_get_field_of_view();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void view_set_scale(float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float view_get_scale();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void view_set_post_effect(int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void view_set_post_effect_null();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t view_get_post_effect();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void view_set_vsync(int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t view_is_vsync();
	}
} // namespace Dora

namespace Dora
{
	/// A struct that provides access to the 3D graphic view.
	public static partial class View
	{
		/// the size of the view in pixels.
		public static Size Size
		{
			get => Size.From(Native.view_get_size());
		}
		/// the standard distance of the view from the origin.
		public static float StandardDistance
		{
			get => Native.view_get_standard_distance();
		}
		/// the aspect ratio of the view.
		public static float AspectRatio
		{
			get => Native.view_get_aspect_ratio();
		}
		/// the distance to the near clipping plane.
		public static float NearPlaneDistance
		{
			set => Native.view_set_near_plane_distance(value);
			get => Native.view_get_near_plane_distance();
		}
		/// the distance to the far clipping plane.
		public static float FarPlaneDistance
		{
			set => Native.view_set_far_plane_distance(value);
			get => Native.view_get_far_plane_distance();
		}
		/// the field of view of the view in degrees.
		public static float FieldOfView
		{
			set => Native.view_set_field_of_view(value);
			get => Native.view_get_field_of_view();
		}
		/// the scale factor of the view.
		public static float Scale
		{
			set => Native.view_set_scale(value);
			get => Native.view_get_scale();
		}
		/// the post effect applied to the view.
		public static SpriteEffect? PostEffect
		{
			set
			{
				if (value == null) Native.view_set_post_effect_null();
				else Native.view_set_post_effect(value.Raw);
			}
			get => SpriteEffect.FromOpt(Native.view_get_post_effect());
		}
		/// whether or not vertical sync is enabled.
		public static bool IsVsync
		{
			set => Native.view_set_vsync(value ? 1 : 0);
			get => Native.view_is_vsync() != 0;
		}
	}
} // namespace Dora
