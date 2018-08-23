/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "imgui/imgui.h"
#include "nanovg/nanovg.h"

NS_DOROTHY_BEGIN

/* Application */
inline Application* Application_shared() { return &SharedApplication; }

/* Event */
int dora_emit(lua_State* L);

/* Content */
void __Content_loadFile(lua_State* L, Content* self, String filename);
#define Content_loadFile(self,filename) {__Content_loadFile(tolua_S,self,filename);return 1;}
void __Content_getDirs(lua_State* L, Content* self, String path);
#define Content_getDirs(self,path) {__Content_getDirs(tolua_S,self,path);return 1;}
void __Content_getFiles(lua_State* L, Content* self, String path);
#define Content_getFiles(self,path) {__Content_getFiles(tolua_S,self,path);return 1;}
void Content_setSearchPaths(Content* self, Slice paths[], int length);
inline Content* Content_shared() { return &SharedContent; }

/* Director */
inline Director* Director_shared() { return &SharedDirector; }

/* View */
inline View* View_shared() { return &SharedView; }

/* Log */
inline void Dora_Log(String msg) { Info("{}", msg); }

/* Node */
int Node_emit(lua_State* L);
int Node_slot(lua_State* L);
int Node_gslot(lua_State* L);
bool Node_eachChild(Node* self, const LuaFunctionBool& func);

/* Cache */
struct Cache
{
	static bool load(String filename);
	static void loadAsync(String filename, const function<void()>& callback);
	static void update(String filename, String content);
	static void update(String filename, Texture2D* texture);
	static void unload();
	static bool unload(String name);
	static void removeUnused();
	static void removeUnused(String type);
};

/* Sprite */
Sprite* Sprite_create(String clipStr);

/* Label */
Sprite* Label_getCharacter(Label* self, int index);

/* Vec2 */
Vec2* Vec2_create(float x, float y);
Vec2* Vec2_create(const Size& size);

/* Size */
Size* Size_create(float width, float height);
Size* Size_create(const Vec2& vec);

/* BlendFunc */
BlendFunc* BlendFunc_create(String src, String dst);
Uint32 BlendFunc_get(String func);

/* Action */
int Action_create(lua_State* L);

/* Model */
Model* Model_create(String filename);
Vec2 Model_getKey(Model* model, String key);
void __Model_getClipFile(lua_State* L, String filename);
#define Model_getClipFile(filename) {__Model_getClipFile(tolua_S,filename);return 1;}
void __Model_getLookNames(lua_State* L, String filename);
#define Model_getLookNames(filename) {__Model_getLookNames(tolua_S,filename);return 1;}
void __Model_getAnimationNames(lua_State* L, String filename);
#define Model_getAnimationNames(filename) {__Model_getAnimationNames(tolua_S, filename);return 1;}

/* Body */
typedef b2FixtureDef FixtureDef;
Body* Body_create(BodyDef* def, PhysicsWorld* world, Vec2 pos, float rot);

/* Dictionary */
Array* __Dictionary_getKeys(Dictionary* self);
#define Dictionary_getKeys() __Dictionary_getKeys(self)
int Dictionary_get(lua_State* L);
int Dictionary_set(lua_State* L);

/* Array */
void Array_swap(Array* self, int indexA, int indexB);
int Array_index(Array* self, Object* object);
void Array_set(Array* self, int index, Object* object);
Object* Array_get(Array* self, int index);
void Array_insert(Array* self, int index, Object* object);
bool Array_removeAt(Array* self, int index);
bool Array_fastRemoveAt(Array* self, int index);
bool Array_each(Array* self, const LuaFunctionBool& handler);

/* Buffer */
class Buffer : public Object
{
public:
	void resize(Uint32 size);
	void zeroMemory();
	char* get();
	Uint32 size() const;
	void setString(String str);
	Slice toString();
	CREATE_FUNC(Buffer);
protected:
	Buffer(Uint32 size = 0);
private:
	vector<char> _data;
	DORA_TYPE_OVERRIDE(Buffer);
};

/* Audio */
inline Audio* Audio_shared() { return &SharedAudio; }

/* Keyboard */
inline Keyboard* Keyboard_shared() { return &SharedKeyboard; }

/* Entity */
int Entity_get(lua_State* L);
int Entity_getCache(lua_State* L);
int Entity_set(lua_State* L);
int Entity_setNext(lua_State* L);

/* EntityWorld */
EntityObserver* EntityObserver_create(String option, Slice components[], int count);

NS_DOROTHY_END

NS_DOROTHY_PLATFORMER_BEGIN

/* AI */
inline AI* AI_shared() { return &SharedAI; }

/* UnitDef */
void UnitDef_setActions(UnitDef* self, Slice names[], int count);

NS_DOROTHY_PLATFORMER_END

using namespace Dorothy;

/* ImGui */
namespace ImGui { namespace Binding
{
	void LoadFontTTF(String ttfFontFile, float fontSize, String glyphRanges = "Default");
	void ShowStats();
	void ShowLog();
	bool Begin(const char* name, String windowsFlags = nullptr);
	bool Begin(const char* name, bool* p_open, String windowsFlags = nullptr);
	bool BeginChild(const char* str_id, const Vec2& size = Vec2::zero, bool border = false, String windowsFlags = nullptr);
	bool BeginChild(ImGuiID id, const Vec2& size = Vec2::zero, bool border = false, String windowsFlags = nullptr);
	void SetNextWindowPos(const Vec2& pos, String setCond = nullptr);
	void SetNextWindowPosCenter(String setCond = nullptr);
	void SetNextWindowSize(const Vec2& size, String setCond = nullptr);
	void SetNextWindowCollapsed(bool collapsed, String setCond = nullptr);
	void SetWindowPos(const char* name, const Vec2& pos, String setCond = nullptr);
	void SetWindowSize(const char* name, const Vec2& size, String setCond = nullptr);
	void SetWindowCollapsed(const char* name, bool collapsed, String setCond = nullptr);
	void SetColorEditOptions(String colorEditMode);
	bool InputText(const char* label, Buffer* buffer, String inputTextFlags = nullptr);
	bool InputTextMultiline(const char* label, Buffer* buffer, const Vec2& size = Vec2::zero, String inputTextFlags = nullptr);
	bool InputFloat(const char* label, float* v, float step = 0.0f, float step_fast = 0.0f, String format = "%.1f", String inputTextFlags = nullptr);
	bool InputInt(const char* label, int* v, int step = 1, int step_fast = 100, String inputTextFlags = nullptr);
	bool TreeNodeEx(const char* label, String treeNodeFlags = nullptr);
	void SetNextTreeNodeOpen(bool is_open, String setCond = nullptr);
	bool CollapsingHeader(const char* label, String treeNodeFlags = nullptr);
	bool CollapsingHeader(const char* label, bool* p_open, String treeNodeFlags = nullptr);
	bool Selectable(const char* label, bool selected = false, String selectableFlags = nullptr, const Vec2& size = Vec2::zero);
	bool Selectable(const char* label, bool* p_selected, String selectableFlags = nullptr, const Vec2& size = Vec2::zero);
	bool BeginPopupModal(const char* name, String windowsFlags = nullptr);
	bool BeginPopupModal(const char* name, bool* p_open = nullptr, String windowsFlags = nullptr);
	bool BeginChildFrame(ImGuiID id, const Vec2& size, String windowsFlags = nullptr);

	void PushStyleColor(String name, Color color);
	void PushStyleVar(String name, float val);
	void PushStyleVar(String name, const Vec2& val);

	bool TreeNodeEx(const char* str_id, String treeNodeFlags, const char* text);

	void Text(String text);
	void TextColored(Color color, String text);
	void TextDisabled(String text);
	void TextWrapped(String text);
	void LabelText(const char* label, const char* text);
	void BulletText(const char* text);
	bool TreeNode(const char* str_id, const char* text);
	void SetTooltip(const char* text);

	bool Combo(const char* label, int* current_item, const char* const* items, int items_count, int height_in_items = -1);

	bool DragFloat2(const char* label, Vec2& v, float v_speed = 1.0f, float v_min = 0.0f, float v_max = 0.0f, const char* display_format = "%.3f", float power = 1.0f);
	bool DragInt2(const char* label, Vec2& v, float v_speed = 1.0f, int v_min = 0, int v_max = 0, const char* display_format = "%.0f");
	bool InputFloat2(const char* label, Vec2& v, String format = "%.1f", String extra_flags = nullptr);
	bool InputInt2(const char* label, Vec2& v, String extra_flags = nullptr);
	bool SliderFloat2(const char* label, Vec2& v, float v_min, float v_max, const char* display_format = "%.3f", float power = 1.0f);
	bool SliderInt2(const char* label, Vec2& v, int v_min, int v_max, const char* display_format = "%.0f");

	bool ColorEdit3(const char* label, Color3& color3);
	bool ColorEdit4(const char* label, Color& color, bool show_alpha = true);

	void Image(Texture2D* user_texture, const Vec2& size, const Vec2& uv0 = Vec2::zero, const Vec2& uv1 = Vec2{1,1}, Color tint_col = Color(0xffffffff), Color border_col = Color(0x0));
	bool ImageButton(Texture2D* user_texture, const Vec2& size, const Vec2& uv0 = Vec2::zero, const Vec2& uv1 = Vec2{1,1}, int frame_padding = -1, Color bg_col = Color(0x0), Color tint_col = Color(0xffffffff));

	bool ColorButton(const char* desc_id, Color col, String flags = nullptr, const Vec2& size = Vec2::zero);

	void Columns(int count = 1, bool border = true);
	void Columns(int count, bool border, const char* id);

	void SetStyleVar(String name, bool var);
	void SetStyleVar(String name, float var);
	void SetStyleVar(String name, const Vec2& var);
	void SetStyleColor(String name, Color color);

	ImGuiWindowFlags_ getWindowFlags(String flag);
	Uint32 getWindowCombinedFlags(String flags);
	ImGuiInputTextFlags_ getInputTextFlags(String flag);
	ImGuiTreeNodeFlags_ getTreeNodeFlags(String flag);
	ImGuiSelectableFlags_ getSelectableFlags(String flag);
	ImGuiCol_ getColorIndex(String col);
	ImGuiColorEditFlags_ getColorEditFlags(String mode);
	ImGuiCond_ getSetCond(String cond);
} }

// NanoVG

inline NVGcolor nvgColor(Color color)
{
	return nvgRGBA(color.r, color.g, color.b, color.a);
}

inline NVGcontext* SharedNVG()
{
	static NVGcontext* nvg = SharedDirector.getNVG();
	return nvg;
}
#define NVG SharedNVG()

int nvgCreateImageRGBA(NVGcontext* ctx, int w, int h, int imageFlags, String filename);
int nvgCreateFont(NVGcontext* ctx, String name);
float nvgTextBounds(NVGcontext* ctx, float x, float y, String text, Rect& bounds);
void nvgTextBoxBounds(NVGcontext* ctx, float x, float y, float breakRowWidth, String text, Rect& bounds);
float nvgText(NVGcontext* ctx, float x, float y, String text);
void nvgTextBox(NVGcontext* ctx, float x, float y, float breakRowWidth, String text);

struct nvg
{
	struct Transform
	{
		float t[6];
		operator float*()
		{
			return t;
		}
		operator const float*() const
		{
			return t;
		}
		inline void indentity() { nvgTransformIdentity(t); }
		inline void translate(float tx, float ty) { nvgTransformTranslate(t, tx, ty); }
		inline void scale(float sx, float sy) { nvgTransformScale(t, sx, sy); }
		inline void rotate(float a) { nvgTransformRotate(t, a); }
		inline void skewX(float a) { nvgTransformSkewX(t, a); }
		inline void skewY(float a) { nvgTransformSkewY(t, a); }
		inline void multiply(const Transform& src) { nvgTransformMultiply(t, src); }
		inline bool inverseFrom(const Transform& src) { return nvgTransformInverse(t, src) != 0; }
		inline Vec2 point(Vec2 src) { Vec2 p; nvgTransformPoint(&p.x, &p.y, t, src.x, src.y); return p; }
	};
	static void Save() { nvgSave(NVG); }
	static void Restore() { nvgRestore(NVG); }
	static void Reset() { nvgReset(NVG); }
	static int CreateImageRGBA(int w, int h, int imageFlags, String filename) { return nvgCreateImageRGBA(NVG, w, h, imageFlags, filename); }
	static int CreateFont(String name) { return nvgCreateFont(NVG, name); }
	static float TextBounds(float x, float y, String text, Rect& bounds) { return nvgTextBounds(NVG, x, y, text, bounds); }
	static Rect TextBoxBounds(float x, float y, float breakRowWidth, String text) { Dorothy::Rect bounds; nvgTextBoxBounds(NVG, x, y, breakRowWidth, text, bounds); return bounds; }
	static float Text(float x, float y, String text) { return nvgText(NVG, x, y, text); }
	static void TextBox(float x, float y, float breakRowWidth, String text) { nvgTextBox(NVG, x, y, breakRowWidth, text); }
	static void StrokeColor(Color color) { nvgStrokeColor(NVG, nvgColor(color)); }
	static void StrokePaint(NVGpaint paint) { nvgStrokePaint(NVG, paint); }
	static void FillColor(Color color) { nvgFillColor(NVG, nvgColor(color)); }
	static void FillPaint(NVGpaint paint) { nvgFillPaint(NVG, paint); }
	static void MiterLimit(float limit) { nvgMiterLimit(NVG, limit); }
	static void StrokeWidth(float size) { nvgStrokeWidth(NVG, size); }
	static void LineCap(int cap) { nvgLineCap(NVG, cap); }
	static void LineJoin(int join) { nvgLineJoin(NVG, join); }
	static void GlobalAlpha(float alpha) { nvgGlobalAlpha(NVG, alpha); }
	static void ResetTransform() { nvgResetTransform(NVG); }
	static void CurrentTransform(Transform& t) { nvgCurrentTransform(NVG, t); }
	static void ApplyTransform(const Transform& t) { nvgTransform(NVG, t.t[0], t.t[1], t.t[2], t.t[3], t.t[4], t.t[5]); }
	static void Translate(float x, float y) { nvgTranslate(NVG, x, y); }
	static void Rotate(float angle) { nvgRotate(NVG, angle); }
	static void SkewX(float angle) { nvgSkewX(NVG, angle); }
	static void SkewY(float angle) { nvgSkewY(NVG, angle); }
	static void Scale(float x, float y) { nvgScale(NVG, x, y); }
	static Size ImageSize(int image) { int w, h; nvgImageSize(NVG, image, &w, &h); return Size{s_cast<float>(w), s_cast<float>(h)}; }
	static void DeleteImage(int image) { nvgDeleteImage(NVG, image); }
	static NVGpaint LinearGradient(float sx, float sy, float ex, float ey, Color icol, Color ocol) { return nvgLinearGradient(NVG, sx, sy, ex, ey, nvgColor(icol), nvgColor(ocol)); }
	static NVGpaint BoxGradient(float x, float y, float w, float h, float r, float f, Color icol, Color ocol) { return nvgBoxGradient(NVG, x, y, w, h, r, f, nvgColor(icol), nvgColor(ocol)); }
	static NVGpaint RadialGradient(float cx, float cy, float inr, float outr, Color icol, Color ocol) { return nvgRadialGradient(NVG, cx, cy, inr, outr, nvgColor(icol), nvgColor(ocol)); }
	static NVGpaint ImagePattern(float ox, float oy, float ex, float ey, float angle, int image, float alpha) { return nvgImagePattern(NVG, ox, oy, ex, ey, angle, image, alpha); }
	static void Scissor(float x, float y, float w, float h) { nvgScissor(NVG, x, y, w, h); }
	static void IntersectScissor(float x, float y, float w, float h) { nvgIntersectScissor(NVG, x, y, w, h); }
	static void ResetScissor() { nvgResetScissor(NVG); }
	static void BeginPath() { nvgBeginPath(NVG); }
	static void MoveTo(float x, float y) { nvgMoveTo(NVG, x, y); }
	static void LineTo(float x, float y) { nvgLineTo(NVG, x, y); }
	static void BezierTo(float c1x, float c1y, float c2x, float c2y, float x, float y) { nvgBezierTo(NVG, c1x, c1y, c2x, c2y, x, y); }
	static void QuadTo(float cx, float cy, float x, float y) { nvgQuadTo(NVG, cx, cy, x, y); }
	static void ArcTo(float x1, float y1, float x2, float y2, float radius) { nvgArcTo(NVG, x1, y1, x2, y2, radius); }
	static void ClosePath() { nvgClosePath(NVG); }
	static void PathWinding(int dir) { nvgPathWinding(NVG, dir); }
	static void Arc(float cx, float cy, float r, float a0, float a1, int dir) { nvgArc(NVG, cx, cy, r, a0, a1, dir); }
	static void Rect(float x, float y, float w, float h) { nvgRect(NVG, x, y, w, h); }
	static void RoundedRect(float x, float y, float w, float h, float r) { nvgRoundedRect(NVG, x, y, w, h, r); }
	static void RoundedRectVarying(float x, float y, float w, float h, float radTopLeft, float radTopRight, float radBottomRight, float radBottomLeft) { nvgRoundedRectVarying(NVG, x, y, w, h, radTopLeft, radTopRight, radBottomRight, radBottomLeft); }
	static void Ellipse(float cx, float cy, float rx, float ry) { nvgEllipse(NVG, cx, cy, rx, ry); }
	static void Circle(float cx, float cy, float r) { nvgCircle(NVG, cx, cy, r); }
	static void Fill() { nvgFill(NVG); }
	static void Stroke() { nvgStroke(NVG); }
	static int FindFont(const char* name) { return nvgFindFont(NVG, name); }
	static int AddFallbackFontId(int baseFont, int fallbackFont) { return nvgAddFallbackFontId(NVG, baseFont, fallbackFont); }
	static int AddFallbackFont(const char* baseFont, const char* fallbackFont) { return nvgAddFallbackFont(NVG, baseFont, fallbackFont); }
	static void FontSize(float size) { nvgFontSize(NVG, size); }
	static void FontBlur(float blur) { nvgFontBlur(NVG, blur); }
	static void TextLetterSpacing(float spacing) { nvgTextLetterSpacing(NVG, spacing); }
	static void TextLineHeight(float lineHeight) { nvgTextLineHeight(NVG, lineHeight); }
	static void TextAlign(int align) { nvgTextAlign(NVG, align); }
	static void FontFaceId(int font) { nvgFontFaceId(NVG, font); }
	static void FontFace(const char* font) { nvgFontFace(NVG, font); }
};
