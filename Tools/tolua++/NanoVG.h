struct NVGpaint @ VGPaint
{
	~NVGpaint();
}

namespace nvg
{
	void Save();
	void Restore();
	void Reset();
	int CreateImage(int w, int h, String filename);
	int CreateImage(int w, int h, String filename, String imageFlags[tolua_len]);
	int CreateFont(String name);
	float TextBounds(float x, float y, String text, Rect bounds);
	Rect TextBoxBounds(float x, float y, float breakRowWidth, String text);
	float Text(float x, float y, String text);
	void TextBox(float x, float y, float breakRowWidth, String text);
	void StrokeColor(uint32_t color);
	void StrokeColor(Color color);
	void StrokePaint(NVGpaint paint);
	void FillColor(uint32_t color);
	void FillColor(Color color);
	void FillPaint(NVGpaint paint);
	void MiterLimit(float limit);
	void StrokeWidth(float size);
	void LineCap(String cap);
	void LineJoin(String join);
	void GlobalAlpha(float alpha);
	void ResetTransform();
	void ApplyTransform(Node* node);
	void Translate(float x, float y);
	void Rotate(float angle);
	void SkewX(float angle);
	void SkewY(float angle);
	void Scale(float x, float y);
	Size ImageSize(int image);
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
	void PathWinding(String dir);
	void Arc(float cx, float cy, float r, float a0, float a1, String dir);
	void Rectangle @ Rect(float x, float y, float w, float h);
	void RoundedRect(float x, float y, float w, float h, float r);
	void RoundedRectVarying(float x, float y, float w, float h, float radTopLeft, float radTopRight, float radBottomRight, float radBottomLeft);
	void Ellipse(float cx, float cy, float rx, float ry);
	void Circle(float cx, float cy, float r);
	void Fill();
	void Stroke();
	int FindFont(String name);
	int AddFallbackFontId(int baseFont, int fallbackFont);
	int AddFallbackFont(String baseFont, String fallbackFont);
	void FontSize(float size);
	void FontBlur(float blur);
	void TextLetterSpacing(float spacing);
	void TextLineHeight(float lineHeight);
	void TextAlign(String hAlign, String vAlign);
	void FontFaceId(int font);
	void FontFace(String font);
	void DoraSSR();
	Texture2D* GetDoraSSR(float scale = 1.0f);
};

class VGNode : public Node
{
	tolua_readonly tolua_property__common Sprite* surface;
	void render(tolua_function_void func);
	static VGNode* create(float width, float height, float scale = 1.0f, int edgeAA = 1);
};

