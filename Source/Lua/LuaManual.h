/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "imgui/imgui.h"

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
int Content_GetSearchPaths(lua_State* L);
int Content_SetSearchPaths(lua_State* L);
void Content_insertSearchPath(Content* self, int index, String path);
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
bool Node_eachChild(Node* self, const LuaFunction<bool>& func);

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
Vec2 Model_getKey(Model* model, String key);
void __Model_getClipFile(lua_State* L, String filename);
#define Model_getClipFile(filename) {__Model_getClipFile(tolua_S,filename);return 1;}
void __Model_getLookNames(lua_State* L, String filename);
#define Model_getLookNames(filename) {__Model_getLookNames(tolua_S,filename);return 1;}
void __Model_getAnimationNames(lua_State* L, String filename);
#define Model_getAnimationNames(filename) {__Model_getAnimationNames(tolua_S, filename);return 1;}

/* Body */
Body* Body_create(BodyDef* def, PhysicsWorld* world, Vec2 pos, float rot);

/* Dictionary */
Array* __Dictionary_getKeys(Dictionary* self);
#define Dictionary_getKeys() __Dictionary_getKeys(self)
int Dictionary_get(lua_State* L);
int Dictionary_set(lua_State* L);

/* Array */
int Array_index(lua_State* L);
int Array_set(lua_State* L);
int Array_get(lua_State* L);
int Array_insert(lua_State* L);
int Array_add(lua_State* L);
int Array_contains(lua_State* L);
int Array_fastRemove(lua_State* L);
int Array_removeLast(lua_State* L);
int Array_create(lua_State* L);
void Array_swap(Array* self, int indexA, int indexB);
bool Array_removeAt(Array* self, int index);
bool Array_fastRemoveAt(Array* self, int index);
bool Array_each(Array* self, const LuaFunction<bool>& handler);

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
int Entity_getOld(lua_State* L);
int Entity_set(lua_State* L);
int Entity_setNext(lua_State* L);

/* EntityWorld */
EntityObserver* EntityObserver_create(String option, Slice components[], int count);

NS_DOROTHY_END

NS_DOROTHY_PLATFORMER_BEGIN

/* AI */
inline AI* AI_shared() { return &SharedAI; }

/* Bullet */
Bullet* Bullet_create(BulletDef* def, Unit* unit);

/* UnitDef */
int UnitDef_GetActions(lua_State* L);
int UnitDef_SetActions(lua_State* L);

/* Data */
inline Data* Data_shared() { return &SharedData; }

NS_DOROTHY_PLATFORMER_END

using namespace Dorothy;

/* ImGui */
namespace ImGui { namespace Binding
{
	void LoadFontTTF(String ttfFontFile, float fontSize, String glyphRanges = "Default"_slice);
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
