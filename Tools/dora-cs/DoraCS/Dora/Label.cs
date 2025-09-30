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
		public static extern int32_t label_type();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_alignment(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t label_get_alignment(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_alpha_ref(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float label_get_alpha_ref(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_text_width(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float label_get_text_width(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_spacing(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float label_get_spacing(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_line_gap(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float label_get_line_gap(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_outline_color(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t label_get_outline_color(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_outline_width(int64_t self, float val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float label_get_outline_width(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_smooth(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t label_get_smooth(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_text(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t label_get_text(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_blend_func(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t label_get_blend_func(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_depth_write(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t label_is_depth_write(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_batched(int64_t self, int32_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t label_is_batched(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void label_set_effect(int64_t self, int64_t val);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t label_get_effect(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t label_get_character_count(int64_t self);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t label_get_character(int64_t self, int32_t index);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float label_get_automatic_width();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t label_new(int64_t font_name, int32_t font_size, int32_t sdf);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t label_with_str(int64_t font_str);
	}
} // namespace Dora

namespace Dora
{
	/// A node for rendering text using a TrueType font.
	public partial class Label : Node
	{
		public static new (int typeId, CreateFunc func) GetTypeInfo()
		{
			return (Native.label_type(), From);
		}
		protected Label(long raw) : base(raw) { }
		internal static new Label From(long raw)
		{
			return new Label(raw);
		}
		internal static new Label? FromOpt(long raw)
		{
			return raw == 0 ? null : new Label(raw);
		}
		/// the text alignment setting.
		public TextAlign Alignment
		{
			set => Native.label_set_alignment(Raw, (int)value);
			get => (TextAlign)Native.label_get_alignment(Raw);
		}
		/// the alpha threshold value. Pixels with alpha values below this value will not be drawn.
		/// Only works with `label.effect = SpriteEffect::new("builtin:vs_sprite", "builtin:fs_spritealphatest")`.
		public float AlphaRef
		{
			set => Native.label_set_alpha_ref(Raw, value);
			get => Native.label_get_alpha_ref(Raw);
		}
		/// the width of the text used for text wrapping.
		/// Set to `Label::AutomaticWidth` to disable wrapping.
		/// Default is `Label::AutomaticWidth`.
		public float TextWidth
		{
			set => Native.label_set_text_width(Raw, value);
			get => Native.label_get_text_width(Raw);
		}
		/// the gap in pixels between characters.
		public float Spacing
		{
			set => Native.label_set_spacing(Raw, value);
			get => Native.label_get_spacing(Raw);
		}
		/// the gap in pixels between lines of text.
		public float LineGap
		{
			set => Native.label_set_line_gap(Raw, value);
			get => Native.label_get_line_gap(Raw);
		}
		/// the color of the outline, only works with SDF label.
		public Color OutlineColor
		{
			set => Native.label_set_outline_color(Raw, (int)value.ToARGB());
			get => new Color((uint)Native.label_get_outline_color(Raw));
		}
		/// the width of the outline, only works with SDF label.
		public float OutlineWidth
		{
			set => Native.label_set_outline_width(Raw, value);
			get => Native.label_get_outline_width(Raw);
		}
		/// the smooth value of the text, only works with SDF label, default is (0.7, 0.7).
		public Vec2 Smooth
		{
			set => Native.label_set_smooth(Raw, value.Raw);
			get => Vec2.From(Native.label_get_smooth(Raw));
		}
		/// the text to be rendered.
		public string Text
		{
			set => Native.label_set_text(Raw, Bridge.FromString(value));
			get => Bridge.ToString(Native.label_get_text(Raw));
		}
		/// the blend function for the label.
		public BlendFunc BlendFunc
		{
			set => Native.label_set_blend_func(Raw, value.Raw);
			get => BlendFunc.From(Native.label_get_blend_func(Raw));
		}
		/// whether depth writing is enabled. (Default is false)
		public bool IsDepthWrite
		{
			set => Native.label_set_depth_write(Raw, value ? 1 : 0);
			get => Native.label_is_depth_write(Raw) != 0;
		}
		/// whether the label is using batched rendering.
		/// When using batched rendering the `label.get_character()` function will no longer work, but it provides better rendering performance. Default is true.
		public bool IsBatched
		{
			set => Native.label_set_batched(Raw, value ? 1 : 0);
			get => Native.label_is_batched(Raw) != 0;
		}
		/// the sprite effect used to render the text.
		public SpriteEffect Effect
		{
			set => Native.label_set_effect(Raw, value.Raw);
			get => SpriteEffect.From(Native.label_get_effect(Raw));
		}
		/// the number of characters in the label.
		public int CharacterCount
		{
			get => Native.label_get_character_count(Raw);
		}
		/// Returns the sprite for the character at the specified index.
		///
		/// # Arguments
		///
		/// * `index` - The index of the character sprite to retrieve.
		///
		/// # Returns
		///
		/// * `Option<Sprite>` - The sprite for the character, or `None` if the index is out of range.
		public Sprite? GetCharacter(int index)
		{
			return Sprite.FromOpt(Native.label_get_character(Raw, index));
		}
		/// the value to use for automatic width calculation
		public float AutomaticWidth
		{
			get => Native.label_get_automatic_width();
		}
		/// Creates a new Label object with the specified font name and font size.
		///
		/// # Arguments
		///
		/// * `font_name` - The name of the font to use for the label. Can be font file path with or without file extension.
		/// * `font_size` - The size of the font to use for the label.
		/// * `sdf` - Whether to use SDF rendering or not. With SDF rendering, the outline feature will be enabled.
		///
		/// # Returns
		///
		/// * `Label` - The new Label object.
		public Label(string font_name, int font_size, bool sdf) : this(Native.label_new(Bridge.FromString(font_name), font_size, sdf ? 1 : 0)) { }
		public static Label? TryCreate(string font_name, int font_size, bool sdf)
		{
			var raw = Native.label_new(Bridge.FromString(font_name), font_size, sdf ? 1 : 0);
			return raw == 0 ? null : new Label(raw);
		}
		/// Creates a new Label object with the specified font string.
		///
		/// # Arguments
		///
		/// * `font_str` - The font string to use for the label. Should be in the format "fontName;fontSize;sdf", where `sdf` should be "true" or "false".
		///
		/// # Returns
		///
		/// * `Label` - The new Label object.
		public static Label? WithStr(string font_str)
		{
			return Label.FromOpt(Native.label_with_str(Bridge.FromString(font_str)));
		}
	}
} // namespace Dora
