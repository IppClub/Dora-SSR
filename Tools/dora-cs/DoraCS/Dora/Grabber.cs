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
		public static extern int32_t grabber_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grabber_set_camera(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grabber_set_camera_null(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grabber_get_camera(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grabber_set_effect(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grabber_set_effect_null(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grabber_get_effect(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grabber_set_blend_func(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grabber_get_blend_func(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grabber_set_clear_color(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t grabber_get_clear_color(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grabber_set_pos(int64_t self, int32_t x, int32_t y, int64_t pos, float z);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grabber_get_pos(int64_t self, int32_t x, int32_t y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grabber_set_color(int64_t self, int32_t x, int32_t y, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t grabber_get_color(int64_t self, int32_t x, int32_t y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grabber_move_uv(int64_t self, int32_t x, int32_t y, int64_t offset);
	}
} // namespace Dora

namespace Dora
{
	/// A grabber which is used to render a part of the scene to a texture
	/// by a grid of vertices.
	public partial class Grabber : Object
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.grabber_type(), From);
		}
		protected Grabber(long raw) : base(raw) { }
		internal static new Grabber From(long raw)
		{
			return new Grabber(raw);
		}
		internal static new Grabber? FromOpt(long raw)
		{
			return raw == 0 ? null : new Grabber(raw);
		}
		/// the camera used to render the texture.
		public Camera? Camera
		{
			set
			{
				if (value == null) Native.grabber_set_camera_null(Raw);
				else Native.grabber_set_camera(Raw, value.Raw);
			}
			get => Camera.FromOpt(Native.grabber_get_camera(Raw));
		}
		/// the sprite effect applied to the texture.
		public SpriteEffect? Effect
		{
			set
			{
				if (value == null) Native.grabber_set_effect_null(Raw);
				else Native.grabber_set_effect(Raw, value.Raw);
			}
			get => SpriteEffect.FromOpt(Native.grabber_get_effect(Raw));
		}
		/// the blend function for the grabber.
		public BlendFunc BlendFunc
		{
			set => Native.grabber_set_blend_func(Raw, value.Raw);
			get => BlendFunc.From(Native.grabber_get_blend_func(Raw));
		}
		/// the clear color used to clear the texture.
		public Color ClearColor
		{
			set => Native.grabber_set_clear_color(Raw, (int)value.ToARGB());
			get => new Color((uint)Native.grabber_get_clear_color(Raw));
		}
		/// Sets the position of a vertex in the grabber grid.
		///
		/// # Arguments
		///
		/// * `x` - The x-index of the vertex in the grabber grid.
		/// * `y` - The y-index of the vertex in the grabber grid.
		/// * `pos` - The new position of the vertex, represented by a Vec2 object.
		/// * `z` - An optional argument representing the new z-coordinate of the vertex.
		public void SetPos(int x, int y, Vec2 pos, float z)
		{
			Native.grabber_set_pos(Raw, x, y, pos.Raw, z);
		}
		/// Gets the position of a vertex in the grabber grid.
		///
		/// # Arguments
		///
		/// * `x` - The x-index of the vertex in the grabber grid.
		/// * `y` - The y-index of the vertex in the grabber grid.
		///
		/// # Returns
		///
		/// * `Vec2` - The position of the vertex.
		public Vec2 GetPos(int x, int y)
		{
			return Vec2.From(Native.grabber_get_pos(Raw, x, y));
		}
		/// Sets the color of a vertex in the grabber grid.
		///
		/// # Arguments
		///
		/// * `x` - The x-index of the vertex in the grabber grid.
		/// * `y` - The y-index of the vertex in the grabber grid.
		/// * `color` - The new color of the vertex, represented by a Color object.
		public void SetColor(int x, int y, Color color)
		{
			Native.grabber_set_color(Raw, x, y, (int)color.ToARGB());
		}
		/// Gets the color of a vertex in the grabber grid.
		///
		/// # Arguments
		///
		/// * `x` - The x-index of the vertex in the grabber grid.
		/// * `y` - The y-index of the vertex in the grabber grid.
		///
		/// # Returns
		///
		/// * `Color` - The color of the vertex.
		public Color GetColor(int x, int y)
		{
			return new Color((uint)Native.grabber_get_color(Raw, x, y));
		}
		/// Sets the UV coordinates of a vertex in the grabber grid.
		///
		/// # Arguments
		///
		/// * `x` - The x-index of the vertex in the grabber grid.
		/// * `y` - The y-index of the vertex in the grabber grid.
		/// * `offset` - The new UV coordinates of the vertex, represented by a Vec2 object.
		public void MoveUv(int x, int y, Vec2 offset)
		{
			Native.grabber_move_uv(Raw, x, y, offset.Raw);
		}
	}
} // namespace Dora
