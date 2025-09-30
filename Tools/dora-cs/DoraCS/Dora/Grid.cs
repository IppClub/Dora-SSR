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
		public static extern int32_t grid_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t grid_get_grid_x(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t grid_get_grid_y(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grid_set_depth_write(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t grid_is_depth_write(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grid_set_blend_func(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_get_blend_func(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grid_set_effect(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_get_effect(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grid_set_texture_rect(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_get_texture_rect(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grid_set_texture(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grid_set_texture_null(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_get_texture(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grid_set_pos(int64_t self, int32_t x, int32_t y, int64_t pos, float z);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_get_pos(int64_t self, int32_t x, int32_t y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grid_set_color(int64_t self, int32_t x, int32_t y, int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t grid_get_color(int64_t self, int32_t x, int32_t y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void grid_move_uv(int64_t self, int32_t x, int32_t y, int64_t offset);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_new(float width, float height, int32_t grid_x, int32_t grid_y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_with_texture_rect(int64_t texture, int64_t texture_rect, int32_t grid_x, int32_t grid_y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_with_texture(int64_t texture, int32_t grid_x, int32_t grid_y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_with_file(int64_t clip_str, int32_t grid_x, int32_t grid_y);
	}
} // namespace Dora

namespace Dora
{
	/// A struct used to render a texture as a grid of sprites, where each sprite can be positioned, colored, and have its UV coordinates manipulated.
	public partial class Grid : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.grid_type(), From);
		}
		protected Grid(long raw) : base(raw) { }
		internal static new Grid From(long raw)
		{
			return new Grid(raw);
		}
		internal static new Grid? FromOpt(long raw)
		{
			return raw == 0 ? null : new Grid(raw);
		}
		/// the number of columns in the grid. And there are `gridX + 1` vertices horizontally for rendering.
		public int GridX
		{
			get => Native.grid_get_grid_x(Raw);
		}
		/// the number of rows in the grid. And there are `gridY + 1` vertices vertically for rendering.
		public int GridY
		{
			get => Native.grid_get_grid_y(Raw);
		}
		/// whether depth writes are enabled.
		public bool IsDepthWrite
		{
			set => Native.grid_set_depth_write(Raw, value ? 1 : 0);
			get => Native.grid_is_depth_write(Raw) != 0;
		}
		/// the blend function for the grid.
		public BlendFunc BlendFunc
		{
			set => Native.grid_set_blend_func(Raw, value.Raw);
			get => BlendFunc.From(Native.grid_get_blend_func(Raw));
		}
		/// the sprite effect applied to the grid.
		/// Default is `SpriteEffect::new("builtin:vs_sprite", "builtin:fs_sprite")`.
		public SpriteEffect Effect
		{
			set => Native.grid_set_effect(Raw, value.Raw);
			get => SpriteEffect.From(Native.grid_get_effect(Raw));
		}
		/// the rectangle within the texture that is used for the grid.
		public Rect TextureRect
		{
			set => Native.grid_set_texture_rect(Raw, value.Raw);
			get => Dora.Rect.From(Native.grid_get_texture_rect(Raw));
		}
		/// the texture used for the grid.
		public Texture2D? Texture
		{
			set
			{
				if (value == null) Native.grid_set_texture_null(Raw);
				else Native.grid_set_texture(Raw, value.Raw);
			}
			get => Texture2D.FromOpt(Native.grid_get_texture(Raw));
		}
		/// Sets the position of a vertex in the grid.
		///
		/// # Arguments
		///
		/// * `x` - The x-coordinate of the vertex in the grid.
		/// * `y` - The y-coordinate of the vertex in the grid.
		/// * `pos` - The new position of the vertex, represented by a Vec2 object.
		/// * `z` - The new z-coordinate of the vertex.
		public void SetPos(int x, int y, Vec2 pos, float z)
		{
			Native.grid_set_pos(Raw, x, y, pos.Raw, z);
		}
		/// Gets the position of a vertex in the grid.
		///
		/// # Arguments
		///
		/// * `x` - The x-coordinate of the vertex in the grid.
		/// * `y` - The y-coordinate of the vertex in the grid.
		///
		/// # Returns
		///
		/// * `Vec2` - The current position of the vertex.
		public Vec2 GetPos(int x, int y)
		{
			return Vec2.From(Native.grid_get_pos(Raw, x, y));
		}
		/// Sets the color of a vertex in the grid.
		///
		/// # Arguments
		///
		/// * `x` - The x-coordinate of the vertex in the grid.
		/// * `y` - The y-coordinate of the vertex in the grid.
		/// * `color` - The new color of the vertex, represented by a Color object.
		public void SetColor(int x, int y, Color color)
		{
			Native.grid_set_color(Raw, x, y, (int)color.ToARGB());
		}
		/// Gets the color of a vertex in the grid.
		///
		/// # Arguments
		///
		/// * `x` - The x-coordinate of the vertex in the grid.
		/// * `y` - The y-coordinate of the vertex in the grid.
		///
		/// # Returns
		///
		/// * `Color` - The current color of the vertex.
		public Color GetColor(int x, int y)
		{
			return new Color((uint)Native.grid_get_color(Raw, x, y));
		}
		/// Moves the UV coordinates of a vertex in the grid.
		///
		/// # Arguments
		///
		/// * `x` - The x-coordinate of the vertex in the grid.
		/// * `y` - The y-coordinate of the vertex in the grid.
		/// * `offset` - The offset by which to move the UV coordinates, represented by a Vec2 object.
		public void MoveUv(int x, int y, Vec2 offset)
		{
			Native.grid_move_uv(Raw, x, y, offset.Raw);
		}
		/// Creates a new Grid with the specified dimensions and grid size.
		///
		/// # Arguments
		///
		/// * `width` - The width of the grid.
		/// * `height` - The height of the grid.
		/// * `grid_x` - The number of columns in the grid.
		/// * `grid_y` - The number of rows in the grid.
		///
		/// # Returns
		///
		/// * `Grid` - The new Grid instance.
		public Grid(float width, float height, int grid_x, int grid_y) : this(Native.grid_new(width, height, grid_x, grid_y)) { }
		/// Creates a new Grid with the specified texture, texture rectangle, and grid size.
		///
		/// # Arguments
		///
		/// * `texture` - The texture to use for the grid.
		/// * `texture_rect` - The rectangle within the texture to use for the grid.
		/// * `grid_x` - The number of columns in the grid.
		/// * `grid_y` - The number of rows in the grid.
		///
		/// # Returns
		///
		/// * `Grid` - The new Grid instance.
		public Grid(Texture2D texture, Rect texture_rect, int grid_x, int grid_y) : this(Native.grid_with_texture_rect(texture.Raw, texture_rect.Raw, grid_x, grid_y)) { }
		/// Creates a new Grid with the specified texture, texture rectangle, and grid size.
		///
		/// # Arguments
		///
		/// * `texture` - The texture to use for the grid.
		/// * `grid_x` - The number of columns in the grid.
		/// * `grid_y` - The number of rows in the grid.
		///
		/// # Returns
		///
		/// * `Grid` - The new Grid instance.
		public Grid(Texture2D texture, int grid_x, int grid_y) : this(Native.grid_with_texture(texture.Raw, grid_x, grid_y)) { }
		/// Creates a new Grid with the specified clip string and grid size.
		///
		/// # Arguments
		///
		/// * `clip_str` - The clip string to use for the grid. Can be "Image/file.png" and "Image/items.clip|itemA".
		/// * `grid_x` - The number of columns in the grid.
		/// * `grid_y` - The number of rows in the grid.
		///
		/// # Returns
		///
		/// * `Grid` - The new Grid instance.
		public Grid(string clip_str, int grid_x, int grid_y) : this(Native.grid_with_file(Bridge.FromString(clip_str), grid_x, grid_y)) { }
		public static Grid? TryCreate(string clip_str, int grid_x, int grid_y)
		{
			var raw = Native.grid_with_file(Bridge.FromString(clip_str), grid_x, grid_y);
			return raw == 0 ? null : new Grid(raw);
		}
	}
} // namespace Dora
