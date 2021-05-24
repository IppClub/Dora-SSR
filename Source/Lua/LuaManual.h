/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

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

/* Path */
int Path_create(lua_State* L);

/* Content */
void __Content_loadFile(lua_State* L, Content* self, String filename);
#define Content_loadFile(self,filename) {__Content_loadFile(tolua_S,self,filename);return 1;}
void __Content_getDirs(lua_State* L, Content* self, String path);
#define Content_getDirs(self,path) {__Content_getDirs(tolua_S,self,path);return 1;}
void __Content_getFiles(lua_State* L, Content* self, String path);
#define Content_getFiles(self,path) {__Content_getFiles(tolua_S,self,path);return 1;}
void __Content_getAllFiles(lua_State* L, Content* self, String path);
#define Content_getAllFiles(self,path) {__Content_getAllFiles(tolua_S,self,path);return 1;}
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
	static void loadAsync(String filename, const std::function<void()>& callback);
	static void update(String filename, String content);
	static void update(String filename, Texture2D* texture);
	static void unload();
	static bool unload(String name);
	static void removeUnused();
	static void removeUnused(String type);
};

/* Sprite */
Sprite* Sprite_create(String clipStr);
int Sprite_GetUWrap(lua_State* L);
int Sprite_SetUWrap(lua_State* L);
int Sprite_GetVWrap(lua_State* L);
int Sprite_SetVWrap(lua_State* L);
int Sprite_GetTextureFilter(lua_State* L);
int Sprite_SetTextureFilter(lua_State* L);

/* Label */
Sprite* Label_getCharacter(Label* self, int index);
int Label_GetTextAlign(lua_State* L);
int Label_SetTextAlign(lua_State* L);

/* Vec2 */
Vec2* Vec2_create(float x, float y);
Vec2* Vec2_create(const Size& size);

/* Size */
Size* Size_create(float width, float height);
Size* Size_create(const Vec2& vec);

/* BlendFunc */
BlendFunc* BlendFunc_create(String src, String dst);
uint32_t BlendFunc_get(String func);

/* Action */
int Action_create(lua_State* L);

/* Model */
void __Model_getClipFile(lua_State* L, String filename);
#define Model_getClipFile(filename) {__Model_getClipFile(tolua_S,filename);return 1;}
void __Model_getLookNames(lua_State* L, String filename);
#define Model_getLookNames(filename) {__Model_getLookNames(tolua_S,filename);return 1;}
void __Model_getAnimationNames(lua_State* L, String filename);
#define Model_getAnimationNames(filename) {__Model_getAnimationNames(tolua_S, filename);return 1;}

/* Spine */
void __Spine_getLookNames(lua_State* L, String spineStr);
#define Spine_getLookNames(spineStr) {__Spine_getLookNames(tolua_S,spineStr);return 1;}
void __Spine_getAnimationNames(lua_State* L, String spineStr);
#define Spine_getAnimationNames(spineStr) {__Spine_getAnimationNames(tolua_S, spineStr);return 1;}

/* BodyDef */

int BodyDef_GetType(lua_State* L);
int BodyDef_SetType(lua_State* L);

/* Body */
Body* Body_create(BodyDef* def, PhysicsWorld* world, Vec2 pos, float rot);

/* Dictionary */
Array* __Dictionary_getKeys(Dictionary* self);
#define Dictionary_getKeys() __Dictionary_getKeys(self)
int Dictionary_get(lua_State* L);
int Dictionary_set(lua_State* L);

/* Array */
int Array_getFirst(lua_State* L);
int Array_getLast(lua_State* L);
int Array_getRandomObject(lua_State* L);
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
	void resize(uint32_t size);
	void zeroMemory();
	char* get();
	uint32_t size() const;
	void setString(String str);
	Slice toString();
	CREATE_FUNC(Buffer);
protected:
	Buffer(uint32_t size = 0);
private:
	std::vector<char> _data;
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

/* SVGDef */
SVGDef* SVGDef_create(String filename);

/* QLearner */
int QLearner_pack(lua_State* L);
int QLearner_load(lua_State* L);
int QLearner_getMatrix(lua_State* L);

NS_DOROTHY_END

NS_DOROTHY_PLATFORMER_BEGIN

/* TargetAllow */
void TargetAllow_allow(TargetAllow* self, String flag, bool allow);
bool TargetAllow_isAllow(TargetAllow* self, String flag);

/* AI */
inline Decision::AI* AI_shared() { return &SharedAI; }
Array* AI_getUnitsByRelation(Decision::AI* self, String relation);
Unit* AI_getNearestUnit(Decision::AI* self, String relation);
float AI_getNearestUnitDistance(Decision::AI* self, String relation);

/* Blackboard */
int Blackboard_get(lua_State* L);
int Blackboard_set(lua_State* L);

/* Bullet */
Bullet* Bullet_create(BulletDef* def, Unit* unit);

/* Data */
inline Data* Data_shared() { return &SharedData; }
void Data_setRelation(Data* self, uint8_t groupA, uint8_t groupB, String relation);
Slice Data_getRelation(Data* self, uint8_t groupA, uint8_t groupB);
Slice Data_getRelation(Data* self, Body* bodyA, Body* bodyB);

/* DB */
inline DB* DB_shared() { return &SharedDB; }
int DB_transaction(lua_State* L);
int DB_query(lua_State* L);
int DB_insert(lua_State* L);
int DB_exec(lua_State* L);
int DB_queryAsync(lua_State* L);
int DB_insertAsync(lua_State* L);
int DB_execAsync(lua_State* L);

/* Effect */
Pass* Effect_get(Effect* self, size_t index);

NS_DOROTHY_PLATFORMER_END

using namespace Dorothy;

/* ImGui */
namespace ImGui { namespace Binding
{
	void LoadFontTTF(String ttfFontFile, float fontSize, String glyphRanges = "Default"_slice);
	void ShowStats();
	void ShowConsole();
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
	bool TreeNodeEx(const char* label, String treeNodeFlags = nullptr);
	void SetNextItemOpen(bool is_open, String setCond = nullptr);
	bool CollapsingHeader(const char* label, String treeNodeFlags = nullptr);
	bool CollapsingHeader(const char* label, bool* p_open, String treeNodeFlags = nullptr);
	bool Selectable(const char* label, bool selected = false, String selectableFlags = nullptr, const Vec2& size = Vec2::zero);
	bool Selectable(const char* label, bool* p_selected, String selectableFlags = nullptr, const Vec2& size = Vec2::zero);
	bool BeginPopupModal(const char* name, String windowsFlags = nullptr);
	bool BeginPopupModal(const char* name, bool* p_open = nullptr, String windowsFlags = nullptr);
	bool BeginChildFrame(ImGuiID id, const Vec2& size, String windowsFlags = nullptr);
	bool BeginPopupContextItem(const char* name, String popupFlags);
	bool BeginPopupContextWindow(const char* name, String popupFlags);
	bool BeginPopupContextVoid(const char* name, String popupFlags);

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

	bool DragFloat(const char* label, float* v, float v_speed, float v_min, float v_max, const char* display_format = "%.3f", String flags = nullptr);
	bool DragFloat2(const char* label, float* v1, float* v2, float v_speed = 1.0f, float v_min = 0.0f, float v_max = 0.0f, const char* display_format = "%.3f", String flags = nullptr);
	bool DragInt(const char* label, int* v, float v_speed, int v_min, int v_max, const char* display_format = "%d", String flags = nullptr);
	bool DragInt2(const char* label, int* v1, int* v2, float v_speed = 1.0f, int v_min = 0, int v_max = 0, const char* display_format = "%.0f", String flags = nullptr);
	bool InputFloat(const char* label, float* v, float step = 0.0f, float step_fast = 0.0f, const char* format = "%.3f", String flags = nullptr);
	bool InputFloat2(const char* label, float* v1, float* v2, const char* format = "%.1f", String flags = nullptr);
	bool InputInt(const char* label, int* v, int step = 1, int step_fast = 100, String flags = nullptr);
	bool InputInt2(const char* label, int* v1, int* v2, String flags = nullptr);
	bool SliderFloat(const char* label, float* v, float v_min, float v_max, const char* format = "%.3f", String flags = nullptr);
	bool SliderFloat2(const char* label, float* v1, float* v2, float v_min, float v_max, const char* display_format = "%.3f", String flags = nullptr);
	bool SliderInt(const char* label, int* v, int v_min, int v_max, const char* format = "%d", String flags = nullptr);
	bool SliderInt2(const char* label, int* v1, int* v2, int v_min, int v_max, const char* display_format = "%.0f", String flags = nullptr);
	bool DragFloatRange2(const char* label, float* v_current_min, float* v_current_max, float v_speed = 1.0f, float v_min = 0.0f, float v_max = 0.0f, const char* format = "%.3f", const char* format_max = nullptr, String flags = nullptr);
	bool DragIntRange2(const char* label, int* v_current_min, int* v_current_max, float v_speed = 1.0f, int v_min = 0, int v_max = 0, const char* format = "%d", const char* format_max = nullptr, String flags = nullptr);
	bool VSliderFloat(const char* label, const ImVec2& size, float* v, float v_min, float v_max, const char* format = "%.3f", String flags = nullptr);
	bool VSliderInt(const char* label, const ImVec2& size, int* v, int v_min, int v_max, const char* format = "%d", String flags = nullptr);

	bool ColorEdit3(const char* label, Color3& color3);
	bool ColorEdit4(const char* label, Color& color, bool show_alpha = true);

	void Image(String clipStr, const Vec2& size, Color tint_col = Color(0xffffffff), Color border_col = Color(0x0));
	bool ImageButton(String clipStr, const Vec2& size, int frame_padding = -1, Color bg_col = Color(0x0), Color tint_col = Color(0xffffffff));

	bool ColorButton(const char* desc_id, Color col, String flags = nullptr, const Vec2& size = Vec2::zero);

	void Columns(int count = 1, bool border = true);
	void Columns(int count, bool border, const char* id);

	bool BeginTable(const char* str_id, int column, String flags = nullptr, const Vec2& outer_size = Vec2::zero, float inner_width = 0.0f);
	void TableNextRow(String row_flags = nullptr, float min_row_height = 0.0f);
	void TableSetupColumn(const char* label, String flags = nullptr, float init_width_or_weight = 0.0f, ImU32 user_id = 0);

	void SetStyleVar(String name, bool var);
	void SetStyleVar(String name, float var);
	void SetStyleVar(String name, const Vec2& var);
	void SetStyleColor(String name, Color color);

	ImGuiWindowFlags_ getWindowFlags(String flag);
	uint32_t getWindowCombinedFlags(String flags);
	ImGuiSliderFlags_ getSliderFlag(String flag);
	uint32_t getSliderCombinedFlags(String flags);
	ImGuiInputTextFlags_ getInputTextFlag(String flag);
	uint32_t getInputTextCombinedFlags(String flags);
	ImGuiTreeNodeFlags_ getTreeNodeFlags(String flag);
	ImGuiSelectableFlags_ getSelectableFlags(String flag);
	ImGuiCol_ getColorIndex(String col);
	ImGuiColorEditFlags_ getColorEditFlags(String mode);
	ImGuiCond_ getSetCond(String cond);
	ImGuiPopupFlags getPopupFlag(String flag);
	uint32_t getPopupCombinedFlags(String flags);
	ImGuiTableFlags_ getTableFlags(String flag);
	uint32_t getTableCombinedFlags(String flags);
	ImGuiTableRowFlags_ getTableRowFlags(String flag);
	uint32_t getTableRowCombinedFlags(String flags);
	ImGuiTableColumnFlags_ getTableColumnFlags(String flag);
	uint32_t getTableColumnCombinedFlags(String flags);
} }
