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
		public static extern int32_t sprite_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sprite_set_depth_write(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t sprite_is_depth_write(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sprite_set_alpha_ref(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float sprite_get_alpha_ref(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sprite_set_texture_rect(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sprite_get_texture_rect(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sprite_get_texture(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sprite_set_blend_func(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sprite_get_blend_func(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sprite_set_effect(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sprite_get_effect(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sprite_set_uwrap(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t sprite_get_uwrap(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sprite_set_vwrap(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t sprite_get_vwrap(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sprite_set_filter(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t sprite_get_filter(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void sprite_set_effect_as_default(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sprite_new();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sprite_with_texture_rect(int64_t texture, int64_t textureRect);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sprite_with_texture(int64_t texture);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t sprite_with_file(int64_t clipStr);
	}
} // namespace Dora

namespace Dora
{
	/// <summary>
	/// A struct to render texture in game scene tree hierarchy.
	/// </summary>
	public partial class Sprite : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.sprite_type(), From);
		}
		protected Sprite(long raw) : base(raw) { }
		internal static new Sprite From(long raw)
		{
			return new Sprite(raw);
		}
		internal static new Sprite? FromOpt(long raw)
		{
			return raw == 0 ? null : new Sprite(raw);
		}
		/// <summary>
		/// Whether the depth buffer should be written to when rendering the sprite.
		/// </summary>
		public bool IsDepthWrite
		{
			set => Native.sprite_set_depth_write(Raw, value ? 1 : 0);
			get => Native.sprite_is_depth_write(Raw) != 0;
		}
		/// <summary>
		/// The alpha reference value for alpha testing. Pixels with alpha values less than or equal to this value will be discarded.
		/// Only works with `sprite.effect = SpriteEffect::new("builtin:vs_sprite", "builtin:fs_spritealphatest");`.
		/// </summary>
		public float AlphaRef
		{
			set => Native.sprite_set_alpha_ref(Raw, value);
			get => Native.sprite_get_alpha_ref(Raw);
		}
		/// <summary>
		/// The texture rectangle for the sprite.
		/// </summary>
		public Rect TextureRect
		{
			set => Native.sprite_set_texture_rect(Raw, value.Raw);
			get => Dora.Rect.From(Native.sprite_get_texture_rect(Raw));
		}
		/// <summary>
		/// The texture for the sprite.
		/// </summary>
		public Texture2D? Texture
		{
			get => Texture2D.FromOpt(Native.sprite_get_texture(Raw));
		}
		/// <summary>
		/// The blend function for the sprite.
		/// </summary>
		public BlendFunc BlendFunc
		{
			set => Native.sprite_set_blend_func(Raw, value.Raw);
			get => BlendFunc.From(Native.sprite_get_blend_func(Raw));
		}
		/// <summary>
		/// The sprite shader effect.
		/// </summary>
		public SpriteEffect Effect
		{
			set => Native.sprite_set_effect(Raw, value.Raw);
			get => SpriteEffect.From(Native.sprite_get_effect(Raw));
		}
		/// <summary>
		/// The texture wrapping mode for the U (horizontal) axis.
		/// </summary>
		public TextureWrap Uwrap
		{
			set => Native.sprite_set_uwrap(Raw, (int)value);
			get => (TextureWrap)Native.sprite_get_uwrap(Raw);
		}
		/// <summary>
		/// The texture wrapping mode for the V (vertical) axis.
		/// </summary>
		public TextureWrap Vwrap
		{
			set => Native.sprite_set_vwrap(Raw, (int)value);
			get => (TextureWrap)Native.sprite_get_vwrap(Raw);
		}
		/// <summary>
		/// The texture filtering mode for the sprite.
		/// </summary>
		public TextureFilter Filter
		{
			set => Native.sprite_set_filter(Raw, (int)value);
			get => (TextureFilter)Native.sprite_get_filter(Raw);
		}
		/// <summary>
		/// Removes the sprite effect and sets the default effect.
		/// </summary>
		public void SetEffectAsDefault()
		{
			Native.sprite_set_effect_as_default(Raw);
		}
		/// <summary>
		/// A method for creating a Sprite object.
		/// </summary>
		/// <returns>A new instance of the Sprite class.</returns>
		public Sprite() : this(Native.sprite_new()) { }
		/// <summary>
		/// A method for creating a Sprite object.
		/// </summary>
		/// <param name="texture">The texture to be used for the sprite.</param>
		/// <param name="textureRect">An optional rectangle defining the portion of the texture to use for the sprite. If not provided, the whole texture will be used for rendering.</param>
		/// <returns>A new instance of the Sprite class.</returns>
		public Sprite(Texture2D texture, Rect textureRect) : this(Native.sprite_with_texture_rect(texture.Raw, textureRect.Raw)) { }
		/// <summary>
		/// A method for creating a Sprite object.
		/// </summary>
		/// <param name="texture">The texture to be used for the sprite.</param>
		/// <returns>A new instance of the Sprite class.</returns>
		public Sprite(Texture2D texture) : this(Native.sprite_with_texture(texture.Raw)) { }
		/// <summary>
		/// A method for creating a Sprite object.
		/// </summary>
		/// <param name="clipStr">The string containing format for loading a texture file. Can be "Image/file.png" and "Image/items.clip|itemA". Supports image file format: jpg, png, dds, pvr, ktx.</param>
		/// <returns>A new instance of the Sprite class. If the texture file is not found, it will return `None`.</returns>
		public Sprite(string clipStr) : this(Native.sprite_with_file(Bridge.FromString(clipStr))) { }
		public static Sprite? TryCreate(string clipStr)
		{
			var raw = Native.sprite_with_file(Bridge.FromString(clipStr));
			return raw == 0 ? null : new Sprite(raw);
		}
	}
} // namespace Dora
