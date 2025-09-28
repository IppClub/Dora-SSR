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
		public static extern void nvg_save();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_restore();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_reset();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t nvg__create_image(int32_t w, int32_t h, int64_t filename, int32_t image_flags);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t nvg_create_font(int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float nvg_text_bounds(float x, float y, int64_t text, int64_t bounds);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t nvg_text_box_bounds(float x, float y, float break_row_width, int64_t text);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern float nvg_text(float x, float y, int64_t text);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_text_box(float x, float y, float break_row_width, int64_t text);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_stroke_color(int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_stroke_paint(int64_t paint);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_fill_color(int32_t color);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_fill_paint(int64_t paint);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_miter_limit(float limit);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_stroke_width(float size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg__line_cap(int32_t cap);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg__line_join(int32_t join);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_global_alpha(float alpha);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_reset_transform();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_apply_transform(int64_t node);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_translate(float x, float y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_rotate(float angle);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_skew_x(float angle);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_skew_y(float angle);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_scale(float x, float y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t nvg_image_size(int32_t image);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_delete_image(int32_t image);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t nvg_linear_gradient(float sx, float sy, float ex, float ey, int32_t icol, int32_t ocol);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t nvg_box_gradient(float x, float y, float w, float h, float r, float f, int32_t icol, int32_t ocol);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t nvg_radial_gradient(float cx, float cy, float inr, float outr, int32_t icol, int32_t ocol);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t nvg_image_pattern(float ox, float oy, float ex, float ey, float angle, int32_t image, float alpha);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_scissor(float x, float y, float w, float h);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_intersect_scissor(float x, float y, float w, float h);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_reset_scissor();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_begin_path();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_move_to(float x, float y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_line_to(float x, float y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_bezier_to(float c_1x, float c_1y, float c_2x, float c_2y, float x, float y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_quad_to(float cx, float cy, float x, float y);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_arc_to(float x_1, float y_1, float x_2, float y_2, float radius);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_close_path();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg__path_winding(int32_t dir);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg__arc(float cx, float cy, float r, float a_0, float a_1, int32_t dir);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_rect(float x, float y, float w, float h);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_rounded_rect(float x, float y, float w, float h, float r);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_rounded_rect_varying(float x, float y, float w, float h, float rad_top_left, float rad_top_right, float rad_bottom_right, float rad_bottom_left);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_ellipse(float cx, float cy, float rx, float ry);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_circle(float cx, float cy, float r);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_fill();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_stroke();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t nvg_find_font(int64_t name);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t nvg_add_fallback_font_id(int32_t base_font, int32_t fallback_font);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int32_t nvg_add_fallback_font(int64_t base_font, int64_t fallback_font);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_font_size(float size);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_font_blur(float blur);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_text_letter_spacing(float spacing);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_text_line_height(float line_height);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg__text_align(int32_t h_align, int32_t v_align);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_font_face_id(int32_t font);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_font_face(int64_t font);
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern void nvg_dora_ssr();
		[DllImport(Dll, CallingConvention = CallingConvention.Cdecl)]
		public static extern int64_t nvg_get_dora_ssr(float scale);
	}
} // namespace Dora

namespace Dora
{
	public static partial class Nvg
	{
		public static void Save()
		{
			Native.nvg_save();
		}
		public static void Restore()
		{
			Native.nvg_restore();
		}
		public static void Reset()
		{
			Native.nvg_reset();
		}
		public static int _CreateImage(int w, int h, string filename, int image_flags)
		{
			return Native.nvg__create_image(w, h, Bridge.FromString(filename), image_flags);
		}
		public static int CreateFont(string name)
		{
			return Native.nvg_create_font(Bridge.FromString(name));
		}
		public static float TextBounds(float x, float y, string text, Rect bounds)
		{
			return Native.nvg_text_bounds(x, y, Bridge.FromString(text), bounds.Raw);
		}
		public static Rect TextBoxBounds(float x, float y, float break_row_width, string text)
		{
			return Dora.Rect.From(Native.nvg_text_box_bounds(x, y, break_row_width, Bridge.FromString(text)));
		}
		public static float Text(float x, float y, string text)
		{
			return Native.nvg_text(x, y, Bridge.FromString(text));
		}
		public static void TextBox(float x, float y, float break_row_width, string text)
		{
			Native.nvg_text_box(x, y, break_row_width, Bridge.FromString(text));
		}
		public static void StrokeColor(Color color)
		{
			Native.nvg_stroke_color((int)color.ToArgb());
		}
		public static void StrokePaint(VGPaint paint)
		{
			Native.nvg_stroke_paint(paint.Raw);
		}
		public static void FillColor(Color color)
		{
			Native.nvg_fill_color((int)color.ToArgb());
		}
		public static void FillPaint(VGPaint paint)
		{
			Native.nvg_fill_paint(paint.Raw);
		}
		public static void MiterLimit(float limit)
		{
			Native.nvg_miter_limit(limit);
		}
		public static void StrokeWidth(float size)
		{
			Native.nvg_stroke_width(size);
		}
		public static void _LineCap(int cap)
		{
			Native.nvg__line_cap(cap);
		}
		public static void _LineJoin(int join)
		{
			Native.nvg__line_join(join);
		}
		public static void GlobalAlpha(float alpha)
		{
			Native.nvg_global_alpha(alpha);
		}
		public static void ResetTransform()
		{
			Native.nvg_reset_transform();
		}
		public static void ApplyTransform(Node node)
		{
			Native.nvg_apply_transform(node.Raw);
		}
		public static void Translate(float x, float y)
		{
			Native.nvg_translate(x, y);
		}
		public static void Rotate(float angle)
		{
			Native.nvg_rotate(angle);
		}
		public static void SkewX(float angle)
		{
			Native.nvg_skew_x(angle);
		}
		public static void SkewY(float angle)
		{
			Native.nvg_skew_y(angle);
		}
		public static void Scale(float x, float y)
		{
			Native.nvg_scale(x, y);
		}
		public static Size ImageSize(int image)
		{
			return Size.From(Native.nvg_image_size(image));
		}
		public static void DeleteImage(int image)
		{
			Native.nvg_delete_image(image);
		}
		public static VGPaint LinearGradient(float sx, float sy, float ex, float ey, Color icol, Color ocol)
		{
			return VGPaint.From(Native.nvg_linear_gradient(sx, sy, ex, ey, (int)icol.ToArgb(), (int)ocol.ToArgb()));
		}
		public static VGPaint BoxGradient(float x, float y, float w, float h, float r, float f, Color icol, Color ocol)
		{
			return VGPaint.From(Native.nvg_box_gradient(x, y, w, h, r, f, (int)icol.ToArgb(), (int)ocol.ToArgb()));
		}
		public static VGPaint RadialGradient(float cx, float cy, float inr, float outr, Color icol, Color ocol)
		{
			return VGPaint.From(Native.nvg_radial_gradient(cx, cy, inr, outr, (int)icol.ToArgb(), (int)ocol.ToArgb()));
		}
		public static VGPaint ImagePattern(float ox, float oy, float ex, float ey, float angle, int image, float alpha)
		{
			return VGPaint.From(Native.nvg_image_pattern(ox, oy, ex, ey, angle, image, alpha));
		}
		public static void Scissor(float x, float y, float w, float h)
		{
			Native.nvg_scissor(x, y, w, h);
		}
		public static void IntersectScissor(float x, float y, float w, float h)
		{
			Native.nvg_intersect_scissor(x, y, w, h);
		}
		public static void ResetScissor()
		{
			Native.nvg_reset_scissor();
		}
		public static void BeginPath()
		{
			Native.nvg_begin_path();
		}
		public static void MoveTo(float x, float y)
		{
			Native.nvg_move_to(x, y);
		}
		public static void LineTo(float x, float y)
		{
			Native.nvg_line_to(x, y);
		}
		public static void BezierTo(float c_1x, float c_1y, float c_2x, float c_2y, float x, float y)
		{
			Native.nvg_bezier_to(c_1x, c_1y, c_2x, c_2y, x, y);
		}
		public static void QuadTo(float cx, float cy, float x, float y)
		{
			Native.nvg_quad_to(cx, cy, x, y);
		}
		public static void ArcTo(float x_1, float y_1, float x_2, float y_2, float radius)
		{
			Native.nvg_arc_to(x_1, y_1, x_2, y_2, radius);
		}
		public static void ClosePath()
		{
			Native.nvg_close_path();
		}
		public static void _PathWinding(int dir)
		{
			Native.nvg__path_winding(dir);
		}
		public static void _Arc(float cx, float cy, float r, float a_0, float a_1, int dir)
		{
			Native.nvg__arc(cx, cy, r, a_0, a_1, dir);
		}
		public static void Rect(float x, float y, float w, float h)
		{
			Native.nvg_rect(x, y, w, h);
		}
		public static void RoundedRect(float x, float y, float w, float h, float r)
		{
			Native.nvg_rounded_rect(x, y, w, h, r);
		}
		public static void RoundedRectVarying(float x, float y, float w, float h, float rad_top_left, float rad_top_right, float rad_bottom_right, float rad_bottom_left)
		{
			Native.nvg_rounded_rect_varying(x, y, w, h, rad_top_left, rad_top_right, rad_bottom_right, rad_bottom_left);
		}
		public static void Ellipse(float cx, float cy, float rx, float ry)
		{
			Native.nvg_ellipse(cx, cy, rx, ry);
		}
		public static void Circle(float cx, float cy, float r)
		{
			Native.nvg_circle(cx, cy, r);
		}
		public static void Fill()
		{
			Native.nvg_fill();
		}
		public static void Stroke()
		{
			Native.nvg_stroke();
		}
		public static int FindFont(string name)
		{
			return Native.nvg_find_font(Bridge.FromString(name));
		}
		public static int AddFallbackFontId(int base_font, int fallback_font)
		{
			return Native.nvg_add_fallback_font_id(base_font, fallback_font);
		}
		public static int AddFallbackFont(string base_font, string fallback_font)
		{
			return Native.nvg_add_fallback_font(Bridge.FromString(base_font), Bridge.FromString(fallback_font));
		}
		public static void FontSize(float size)
		{
			Native.nvg_font_size(size);
		}
		public static void FontBlur(float blur)
		{
			Native.nvg_font_blur(blur);
		}
		public static void TextLetterSpacing(float spacing)
		{
			Native.nvg_text_letter_spacing(spacing);
		}
		public static void TextLineHeight(float line_height)
		{
			Native.nvg_text_line_height(line_height);
		}
		public static void _TextAlign(int h_align, int v_align)
		{
			Native.nvg__text_align(h_align, v_align);
		}
		public static void FontFaceId(int font)
		{
			Native.nvg_font_face_id(font);
		}
		public static void FontFace(string font)
		{
			Native.nvg_font_face(Bridge.FromString(font));
		}
		public static void DoraSSR()
		{
			Native.nvg_dora_ssr();
		}
		public static Texture2D GetDoraSSR(float scale)
		{
			return Texture2D.From(Native.nvg_get_dora_ssr(scale));
		}
	}
} // namespace Dora
