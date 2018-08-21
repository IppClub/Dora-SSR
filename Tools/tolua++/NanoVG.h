struct NVGpaint
{
	~NVGpaint();
}

struct nvg
{
	#define NVG_CCW @ CCW
	#define NVG_CW @ CW
	#define NVG_SOLID @ SOLID
	#define NVG_HOLE @ HOLE
	#define NVG_BUTT @ BUTT
	#define NVG_ROUND @ ROUND
	#define NVG_SQUARE @ SQUARE
	#define NVG_BEVEL @ BEVEL
	#define NVG_MITER @ MITER
	#define NVG_ALIGN_LEFT @ ALIGN_LEFT
	#define NVG_ALIGN_CENTER @ ALIGN_CENTER
	#define NVG_ALIGN_RIGHT @ ALIGN_RIGHT
	#define NVG_ALIGN_TOP @ ALIGN_TOP
	#define NVG_ALIGN_MIDDLE @ ALIGN_MIDDLE
	#define NVG_ALIGN_BOTTOM @ ALIGN_BOTTOM
	#define NVG_ALIGN_BASELINE @ ALIGN_BASELINE
};

namespace nvg
{
	void Save();
	void Restore();
	void Reset();
	int CreateImageRGBA(int w, int h, int imageFlags, String filename);
	int CreateFont(String name);
	float TextBounds(float x, float y, String text, Rect& bounds);
	void TextBoxBounds(float x, float y, float breakRowWidth, String text, Rect& bounds);
	float Text(float x, float y, String text);
	void TextBox(float x, float y, float breakRowWidth, String text);
	void StrokeColor(Color color);
	void StrokePaint(NVGpaint paint);
	void FillColor(Color color);
	void FillPaint(NVGpaint paint);
	void MiterLimit(float limit);
	void StrokeWidth(float size);
	void LineCap(int cap);
	void LineJoin(int join);
	void GlobalAlpha(float alpha);
	void ResetTransform();
	void Translate(float x, float y);
	void Rotate(float angle);
	void SkewX(float angle);
	void SkewY(float angle);
	void Scale(float x, float y);
	void ImageSize(int image, int* w, int* h);
	void DeleteImage(int image);
	NVGpaint LinearGradient(float sx, float sy, float ex, float ey, Color icol, Color ocol);
	NVGpaint BoxGradient(float x, float y, float w, float h, float r, float f, Color icol, Color ocol);
	NVGpaint RadialGradient(float cx, float cy, float inr, float outr, Color icol, Color ocol);
	NVGpaint ImagePattern(float ox, float oy, float ex, float ey, float angle, int image, float alpha);
	void Scissor(float x, float y, float w, float h);
	void IntersectScissor(float x, float y, float w, float h);
	void ResetScissor();
	void BeginPath();
	void MoveTo(float x, float y);
	void LineTo(float x, float y);
	void BezierTo(float c1x, float c1y, float c2x, float c2y, float x, float y);
	void QuadTo(float cx, float cy, float x, float y);
	void ArcTo(float x1, float y1, float x2, float y2, float radius);
	void ClosePath();
	void PathWinding(int dir);
	void Arc(float cx, float cy, float r, float a0, float a1, int dir);
	void Rect(float x, float y, float w, float h);
	void RoundedRect(float x, float y, float w, float h, float r);
	void RoundedRectVarying(float x, float y, float w, float h, float radTopLeft, float radTopRight, float radBottomRight, float radBottomLeft);
	void Ellipse(float cx, float cy, float rx, float ry);
	void Circle(float cx, float cy, float r);
	void Fill();
	void Stroke();
	int FindFont(const char* name);
	int AddFallbackFontId(int baseFont, int fallbackFont);
	int AddFallbackFont(const char* baseFont, const char* fallbackFont);
	void FontSize(float size);
	void FontBlur(float blur);
	void TextLetterSpacing(float spacing);
	void TextLineHeight(float lineHeight);
	void TextAlign(int align);
	void FontFaceId(int font);
	void FontFace(const char* font);
};

