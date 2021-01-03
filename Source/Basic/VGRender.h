/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Cache/TextureCache.h"
#include "nanovg/nanovg.h"
#include "Support/Common.h"

struct NVGLUframebuffer;

NS_DOROTHY_BEGIN

inline NVGcolor nvgColor(Color color)
{
	return nvgRGBA(color.r, color.g, color.b, color.a);
}

struct nvg
{
	struct Transform
	{
		float t[6] = {};
		inline operator float*() { return t; }
		inline operator const float*() const { return t; }
		inline void indentity() { nvgTransformIdentity(t); }
		inline void translate(float tx, float ty) { nvgTransformTranslate(t, tx, ty); }
		inline void scale(float sx, float sy) { nvgTransformScale(t, sx, sy); }
		inline void rotate(float a) { nvgTransformRotate(t, bx::toRad(a)); }
		inline void skewX(float a) { nvgTransformSkewX(t, bx::toRad(a)); }
		inline void skewY(float a) { nvgTransformSkewY(t, bx::toRad(a)); }
		inline void multiply(const Transform& src) { nvgTransformMultiply(t, src); }
		inline bool inverseFrom(const Transform& src) { return nvgTransformInverse(t, src) != 0; }
		inline Vec2 applyPoint(Vec2 src) { Vec2 p; nvgTransformPoint(&p.x, &p.y, t, src.x, src.y); return p; }
	};
	static Vec2 TouchPos();
	static bool LeftButtonPressed();
	static bool RightButtonPressed();
	static bool MiddleButtonPressed();
	static float MouseWheel();
	static void Save();
	static void Restore();
	static void Reset();
	static int CreateImage(int w, int h, int imageFlags, String filename);
	static int CreateFont(String name);
	static float TextBounds(float x, float y, String text, Dorothy::Rect& bounds);
	static Rect TextBoxBounds(float x, float y, float breakRowWidth, String text);
	static float Text(float x, float y, String text);
	static void TextBox(float x, float y, float breakRowWidth, String text);
	static void StrokeColor(Color color);
	static void StrokePaint(const NVGpaint& paint);
	static void FillColor(Color color);
	static void FillPaint(const NVGpaint& paint);
	static void MiterLimit(float limit);
	static void StrokeWidth(float size);
	static void LineCap(String cap = nullptr);
	static void LineJoin(String join = nullptr);
	static void GlobalAlpha(float alpha);
	static void ResetTransform();
	static void ApplyTransform(const Transform& t);
	static void CurrentTransform(Transform& t);
	static void Translate(float x, float y);
	static void Rotate(float angle);
	static void SkewX(float angle);
	static void SkewY(float angle);
	static void Scale(float x, float y);
	static Size ImageSize(int image);
	static void DeleteImage(int image);
	static NVGpaint LinearGradient(float sx, float sy, float ex, float ey, Color icol, Color ocol);
	static NVGpaint BoxGradient(float x, float y, float w, float h, float r, float f, Color icol, Color ocol);
	static NVGpaint RadialGradient(float cx, float cy, float inr, float outr, Color icol, Color ocol);
	static NVGpaint ImagePattern(float ox, float oy, float ex, float ey, float angle, int image, float alpha);
	static void Scissor(float x, float y, float w, float h);
	static void IntersectScissor(float x, float y, float w, float h);
	static void ResetScissor();
	static void BeginPath();
	static void MoveTo(float x, float y);
	static void LineTo(float x, float y);
	static void BezierTo(float c1x, float c1y, float c2x, float c2y, float x, float y);
	static void QuadTo(float cx, float cy, float x, float y);
	static void ArcTo(float x1, float y1, float x2, float y2, float radius);
	static void ClosePath();
	static void PathWinding(String dir);
	static void Arc(float cx, float cy, float r, float a0, float a1, String dir = nullptr);
	static void Rect(float x, float y, float w, float h);
	static void RoundedRect(float x, float y, float w, float h, float r);
	static void RoundedRectVarying(float x, float y, float w, float h, float radTopLeft, float radTopRight, float radBottomRight, float radBottomLeft);
	static void Ellipse(float cx, float cy, float rx, float ry);
	static void Circle(float cx, float cy, float r);
	static void Fill();
	static void Stroke();
	static int FindFont(String name);
	static int AddFallbackFontId(int baseFont, int fallbackFont);
	static int AddFallbackFont(String baseFont, String fallbackFont);
	static void FontSize(float size);
	static void FontBlur(float blur);
	static void TextLetterSpacing(float spacing);
	static void TextLineHeight(float lineHeight);
	static void TextAlign(String align);
	static void FontFaceId(int font);
	static void FontFace(String font);
	static void BindContext(NVGcontext* context);
	static void DorothySSR();
	static void DorothySSRWhite();
	static void DorothySSRHappy();
	static void DorothySSRHappyWhite();
	static NVGcontext* Context();
private:
	static NVGcontext* _currentContext;
};

void RenderDorothySSR(NVGcontext* context);
void RenderDorothySSRWhite(NVGcontext* context);

void RenderDorothySSRHappy(NVGcontext* context);
void RenderDorothySSRHappyWhite(NVGcontext* context);

class VGTexture : public Texture2D
{
public:
	PROPERTY_READONLY(NVGcontext*, Context);
	PROPERTY_READONLY(NVGLUframebuffer*, Framebuffer);
	virtual ~VGTexture();
	CREATE_FUNC(VGTexture);
protected:
	VGTexture(NVGcontext* context, NVGLUframebuffer* framebuffer, const bgfx::TextureInfo& info, Uint64 flags);
	NVGLUframebuffer* _framebuffer;
	NVGcontext* _context;
};

VGTexture* GetDorothySSR(float scale = 1.0f);
VGTexture* GetDorothySSRWhite(float scale = 1.0f);
VGTexture* GetDorothySSRHappy(float scale = 1.0f);
VGTexture* GetDorothySSRHappyWhite(float scale = 1.0f);

NS_DOROTHY_END
