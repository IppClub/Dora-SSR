/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Cache/TextureCache.h"
#include "Support/Common.h"

#include "nanovg/nanovg.h"

struct NVGLUframebuffer;

NS_DORA_BEGIN

class Node;

inline NVGcolor nvgColor(Color color) {
	return nvgRGBA(color.r, color.g, color.b, color.a);
}

struct nvg {
	struct Transform {
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
		inline Vec2 applyPoint(Vec2 src) {
			Vec2 p;
			nvgTransformPoint(&p.x, &p.y, t, src.x, src.y);
			return p;
		}
	};
	static void Save();
	static void Restore();
	static void Reset();
	static int CreateImage(int w, int h, String filename, Slice* imageFlags = nullptr, int flagCount = 0);
	static int CreateImage(int w, int h, String filename, int imageFlags);
	static int CreateFont(String name);
	static float TextBounds(float x, float y, String text, Dora::Rect& bounds);
	static Rect TextBoxBounds(float x, float y, float breakRowWidth, String text);
	static float Text(float x, float y, String text);
	static void TextBox(float x, float y, float breakRowWidth, String text);
	static void StrokeColor(Color color);
	static void StrokeColor(uint32_t color);
	static void StrokePaint(const NVGpaint& paint);
	static void FillColor(Color color);
	static void FillColor(uint32_t color);
	static void FillPaint(const NVGpaint& paint);
	static void MiterLimit(float limit);
	static void StrokeWidth(float size);
	static void LineCap(String cap = nullptr);
	static void LineCap(int cap);
	static void LineJoin(String join = nullptr);
	static void LineJoin(int join);
	static void GlobalAlpha(float alpha);
	static void ResetTransform();
	static void ApplyTransform(const Transform& t);
	static void ApplyTransform(NotNull<Node, 1> node);
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
	static void PathWinding(int dir);
	static void Arc(float cx, float cy, float r, float a0, float a1, String dir = nullptr);
	static void Arc(float cx, float cy, float r, float a0, float a1, int dir);
	static void Rectangle(float x, float y, float w, float h);
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
	static void TextAlign(String hAlign, String vAlign);
	static void TextAlign(int hAlign, int vAlign);
	static void FontFaceId(int font);
	static void FontFace(String font);
	static void BindContext(NVGcontext* context);
	static void DoraSSR();
	static Texture2D* GetDoraSSR(float scale = 1.0f);
	static NVGcontext* Context();

private:
	static NVGcontext* _currentContext;
};

void RenderDoraSSR(NVGcontext* context);

class VGTexture : public Texture2D {
public:
	PROPERTY_READONLY(NVGcontext*, Context);
	PROPERTY_READONLY(NVGLUframebuffer*, Framebuffer);
	virtual ~VGTexture();
	CREATE_FUNC_NOT_NULL(VGTexture);

protected:
	VGTexture(NotNull<NVGcontext, 1> context, NotNull<NVGLUframebuffer, 2> framebuffer, const bgfx::TextureInfo& info, uint64_t flags);
	NVGLUframebuffer* _framebuffer;
	NVGcontext* _context;
};

NS_DORA_END
