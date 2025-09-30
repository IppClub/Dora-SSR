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
		public static extern int64_t grid_new(float width, float height, int32_t gridX, int32_t gridY);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_with_texture_rect(int64_t texture, int64_t textureRect, int32_t gridX, int32_t gridY);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_with_texture(int64_t texture, int32_t gridX, int32_t gridY);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t grid_with_file(int64_t clipStr, int32_t gridX, int32_t gridY);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A struct used to render a texture as a grid of sprites, where each sprite can be positioned, colored, and have its UV coordinates manipulated.
	/// </summary>
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
		/// <summary>
		/// The number of columns in the grid. And there are `gridX + 1` vertices horizontally for rendering.
		/// </summary>
		public int GridX
		{
			get => Native.grid_get_grid_x(Raw);
		}
		/// <summary>
		/// The number of rows in the grid. And there are `gridY + 1` vertices vertically for rendering.
		/// </summary>
		public int GridY
		{
			get => Native.grid_get_grid_y(Raw);
		}
		/// <summary>
		/// Whether depth writes are enabled.
		/// </summary>
		public bool IsDepthWrite
		{
			set => Native.grid_set_depth_write(Raw, value ? 1 : 0);
			get => Native.grid_is_depth_write(Raw) != 0;
		}
		/// <summary>
		/// The blend function for the grid.
		/// </summary>
		public BlendFunc BlendFunc
		{
			set => Native.grid_set_blend_func(Raw, value.Raw);
			get => BlendFunc.From(Native.grid_get_blend_func(Raw));
		}
		/// <summary>
		/// The sprite effect applied to the grid.
		/// Default is `SpriteEffect::new("builtin:vs_sprite", "builtin:fs_sprite")`.
		/// </summary>
		public SpriteEffect Effect
		{
			set => Native.grid_set_effect(Raw, value.Raw);
			get => SpriteEffect.From(Native.grid_get_effect(Raw));
		}
		/// <summary>
		/// The rectangle within the texture that is used for the grid.
		/// </summary>
		public Rect TextureRect
		{
			set => Native.grid_set_texture_rect(Raw, value.Raw);
			get => Dora.Rect.From(Native.grid_get_texture_rect(Raw));
		}
		/// <summary>
		/// The texture used for the grid.
		/// </summary>
		public Texture2D? Texture
		{
			set
			{
				if (value == null) Native.grid_set_texture_null(Raw);
				else Native.grid_set_texture(Raw, value.Raw);
			}
			get => Texture2D.FromOpt(Native.grid_get_texture(Raw));
		}
		/// <summary>
		/// Sets the position of a vertex in the grid.
		/// </summary>
		/// <param name="x">The x-coordinate of the vertex in the grid.</param>
		/// <param name="y">The y-coordinate of the vertex in the grid.</param>
		/// <param name="pos">The new position of the vertex, represented by a Vec2 object.</param>
		/// <param name="z">The new z-coordinate of the vertex.</param>
		public void SetPos(int x, int y, Vec2 pos, float z)
		{
			Native.grid_set_pos(Raw, x, y, pos.Raw, z);
		}
		/// <summary>
		/// Gets the position of a vertex in the grid.
		/// </summary>
		/// <param name="x">The x-coordinate of the vertex in the grid.</param>
		/// <param name="y">The y-coordinate of the vertex in the grid.</param>
		/// <returns>The current position of the vertex.</returns>
		public Vec2 GetPos(int x, int y)
		{
			return Vec2.From(Native.grid_get_pos(Raw, x, y));
		}
		/// <summary>
		/// Sets the color of a vertex in the grid.
		/// </summary>
		/// <param name="x">The x-coordinate of the vertex in the grid.</param>
		/// <param name="y">The y-coordinate of the vertex in the grid.</param>
		/// <param name="color">The new color of the vertex, represented by a Color object.</param>
		public void SetColor(int x, int y, Color color)
		{
			Native.grid_set_color(Raw, x, y, (int)color.ToARGB());
		}
		/// <summary>
		/// Gets the color of a vertex in the grid.
		/// </summary>
		/// <param name="x">The x-coordinate of the vertex in the grid.</param>
		/// <param name="y">The y-coordinate of the vertex in the grid.</param>
		/// <returns>The current color of the vertex.</returns>
		public Color GetColor(int x, int y)
		{
			return new Color((uint)Native.grid_get_color(Raw, x, y));
		}
		/// <summary>
		/// Moves the UV coordinates of a vertex in the grid.
		/// </summary>
		/// <param name="x">The x-coordinate of the vertex in the grid.</param>
		/// <param name="y">The y-coordinate of the vertex in the grid.</param>
		/// <param name="offset">The offset by which to move the UV coordinates, represented by a Vec2 object.</param>
		public void MoveUv(int x, int y, Vec2 offset)
		{
			Native.grid_move_uv(Raw, x, y, offset.Raw);
		}
		/// <summary>
		/// Creates a new Grid with the specified dimensions and grid size.
		/// </summary>
		/// <param name="width">The width of the grid.</param>
		/// <param name="height">The height of the grid.</param>
		/// <param name="gridX">The number of columns in the grid.</param>
		/// <param name="gridY">The number of rows in the grid.</param>
		/// <returns>The new Grid instance.</returns>
		public Grid(float width, float height, int gridX, int gridY) : this(Native.grid_new(width, height, gridX, gridY)) { }
		/// <summary>
		/// Creates a new Grid with the specified texture, texture rectangle, and grid size.
		/// </summary>
		/// <param name="texture">The texture to use for the grid.</param>
		/// <param name="textureRect">The rectangle within the texture to use for the grid.</param>
		/// <param name="gridX">The number of columns in the grid.</param>
		/// <param name="gridY">The number of rows in the grid.</param>
		/// <returns>The new Grid instance.</returns>
		public Grid(Texture2D texture, Rect textureRect, int gridX, int gridY) : this(Native.grid_with_texture_rect(texture.Raw, textureRect.Raw, gridX, gridY)) { }
		/// <summary>
		/// Creates a new Grid with the specified texture, texture rectangle, and grid size.
		/// </summary>
		/// <param name="texture">The texture to use for the grid.</param>
		/// <param name="gridX">The number of columns in the grid.</param>
		/// <param name="gridY">The number of rows in the grid.</param>
		/// <returns>The new Grid instance.</returns>
		public Grid(Texture2D texture, int gridX, int gridY) : this(Native.grid_with_texture(texture.Raw, gridX, gridY)) { }
		/// <summary>
		/// Creates a new Grid with the specified clip string and grid size.
		/// </summary>
		/// <param name="clipStr">The clip string to use for the grid. Can be "Image/file.png" and "Image/items.clip|itemA".</param>
		/// <param name="gridX">The number of columns in the grid.</param>
		/// <param name="gridY">The number of rows in the grid.</param>
		/// <returns>The new Grid instance.</returns>
		public Grid(string clipStr, int gridX, int gridY) : this(Native.grid_with_file(Bridge.FromString(clipStr), gridX, gridY)) { }
		public static Grid? TryCreate(string clipStr, int gridX, int gridY)
		{
			var raw = Native.grid_with_file(Bridge.FromString(clipStr), gridX, gridY);
			return raw == 0 ? null : new Grid(raw);
		}
	}
} // namespace Dora
