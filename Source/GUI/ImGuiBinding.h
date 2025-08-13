/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "imgui/imgui.h"

#include "Support/Common.h"

NS_DORA_BEGIN

class CallStack;

/* Buffer */
class Buffer : public Object {
public:
	void resize(uint32_t size);
	void zeroMemory();
	char* get();
	uint32_t size() const;
	void setText(String str);
	Slice getText();
	CREATE_FUNC_NOT_NULL(Buffer);

protected:
	Buffer(uint32_t size = 0);

private:
	std::vector<char> _data;
	DORA_TYPE_OVERRIDE(Buffer);
};

NS_DORA_END

NS_BEGIN(ImGui::Binding)

using namespace Dora;

void SetDefaultFont(String ttfFontFile, float fontSize);
void ShowStats(bool* pOpen, Slice* flags, int count, const std::function<void()>& extra = nullptr);
void ShowStats(const std::function<void()>& extra = nullptr);
void ShowConsole(bool initOnly = false);

bool Begin(
	const char* name,
	Slice* windowFlags = nullptr,
	int flagCount = 0);

bool Begin(
	const char* name,
	bool* p_open,
	Slice* windowFlags = nullptr,
	int flagCount = 0);

bool Begin(
	const std::string& name,
	uint32_t windowFlags = 0); //

bool Begin(
	const std::string& name,
	CallStack* stack, // p_open
	uint32_t windowFlags = 0); //

bool BeginChild(
	const char* str_id,
	const Vec2& size = Vec2::zero,
	Slice* childFlags = nullptr,
	int childFlagCount = 0,
	Slice* windowFlags = nullptr,
	int windowFlagCount = 0);

bool BeginChild(
	ImGuiID id,
	const Vec2& size = Vec2::zero,
	Slice* childFlags = nullptr,
	int childFlagCount = 0,
	Slice* windowFlags = nullptr,
	int windowFlagCount = 0);

bool BeginChild(
	const std::string& str_id,
	const Vec2& size = Vec2::zero,
	uint32_t childFlags = 0,
	uint32_t windowFlags = 0); //

bool BeginChild(
	ImGuiID id,
	const Vec2& size,
	uint32_t childFlags,
	uint32_t windowFlags); //

void SetNextWindowPos(
	const Vec2& pos,
	String setCond = nullptr,
	const Vec2& pivot = Vec2::zero);

void SetNextWindowPosCenter(
	String setCond = nullptr,
	const Vec2& pivot = Vec2::zero);

void SetNextWindowPosCenter(
	uint32_t setCond,
	const Vec2& pivot = Vec2::zero);

void SetNextWindowSize(
	const Vec2& size,
	String setCond = nullptr);

void SetNextWindowCollapsed(
	bool collapsed,
	String setCond = nullptr);

void SetWindowPos(
	const char* name,
	const Vec2& pos,
	String setCond = nullptr);

void SetWindowPos(
	const std::string& name,
	const Vec2& pos,
	String setCond = nullptr); //

void SetWindowPos(
	const std::string& name,
	const Vec2& pos,
	uint32_t setCond);

void SetWindowSize(
	const char* name,
	const Vec2& size,
	String setCond = nullptr);

void SetWindowSize(
	const std::string& name,
	const Vec2& size,
	String setCond = nullptr); //

void SetWindowSize(
	const std::string& name,
	const Vec2& size,
	uint32_t setCond);

void SetWindowCollapsed(
	const char* name,
	bool collapsed,
	String setCond = nullptr);

void SetWindowCollapsed(
	const std::string& name,
	bool collapsed,
	String setCond = nullptr); //

void SetWindowCollapsed(
	const std::string& name,
	bool collapsed,
	uint32_t setCond);

void SetColorEditOptions(
	Slice* colorEditFlags = nullptr,
	int colorEditFlagCount = 0);

bool InputText(
	const char* label,
	Buffer* buffer,
	Slice* inputTextFlags = nullptr,
	int flagCount = 0);

bool InputText(
	const std::string& label,
	Buffer* buffer,
	uint32_t inputTextFlags = 0); //

bool InputTextMultiline(
	const char* label,
	Buffer* buffer,
	const Vec2& size = Vec2::zero,
	Slice* inputTextFlags = nullptr,
	int flagCount = 0);

bool InputTextMultiline(
	const std::string& label,
	Buffer* buffer,
	const Vec2& size = Vec2::zero,
	uint32_t inputTextFlags = 0); //

bool TreeNodeEx(
	const char* label,
	Slice* treeNodeFlags = nullptr,
	int flagCount = 0);

bool TreeNodeEx(
	const std::string& label,
	uint32_t treeNodeFlags = 0); //

bool TreeNodeEx(
	const char* str_id,
	const char* text,
	Slice* treeNodeFlags = nullptr,
	int flagCount = 0);

bool TreeNodeEx(
	const std::string& str_id,
	const std::string& text,
	uint32_t treeNodeFlags = 0); //

void SetNextItemOpen(
	bool is_open,
	String setCond = nullptr);

bool CollapsingHeader(
	const char* label,
	Slice* treeNodeFlags = nullptr,
	int flagCount = 0);

bool CollapsingHeader(
	const char* label,
	bool* p_open,
	Slice* treeNodeFlags = nullptr,
	int flagCount = 0);

bool CollapsingHeader(
	const std::string& label,
	uint32_t treeNodeFlags = 0); //

bool CollapsingHeader(
	const std::string& label,
	CallStack* stack, // p_open
	uint32_t treeNodeFlags = 0); //

bool Selectable(
	const char* label,
	Slice* selectableFlags = nullptr,
	int flagCount = 0);

bool Selectable(
	const char* label,
	bool* p_selected,
	const Vec2& size = Vec2::zero,
	Slice* selectableFlags = nullptr,
	int flagCount = 0);

bool Selectable(
	const std::string& label,
	uint32_t selectableFlags = 0); //

bool Selectable(
	const std::string& label,
	CallStack* stack, // p_selected
	const Vec2& size = Vec2::zero,
	uint32_t selectableFlags = 0); //

bool BeginPopupModal(
	const char* name,
	Slice* windowFlags = nullptr,
	int flagCount = 0);

bool BeginPopupModal(
	const char* name,
	bool* p_open,
	Slice* windowFlags = nullptr,
	int flagCount = 0);

bool BeginPopupModal(
	const std::string& name,
	uint32_t windowFlags = 0); //

bool BeginPopupModal(
	const std::string& name,
	CallStack* stack, // p_open
	uint32_t windowFlags = 0); //

bool BeginPopupContextItem(
	const char* name,
	Slice* popupFlags = nullptr,
	int flagCount = 0);

bool BeginPopupContextWindow(
	const char* name,
	Slice* popupFlags = nullptr,
	int flagCount = 0);

bool BeginPopupContextVoid(
	const char* name,
	Slice* popupFlags = nullptr,
	int flagCount = 0);

bool BeginPopupContextItem(
	const std::string& name,
	uint32_t popupFlags = 0); //

bool BeginPopupContextWindow(
	const std::string& name,
	uint32_t popupFlags = 0); //

bool BeginPopupContextVoid(
	const std::string& name,
	uint32_t popupFlags = 0); //

void PushStyleColor(String name, Color color);
void PushStyleVar(String name, float val);
void PushStyleVar(String name, const Vec2& val);

void PushStyleColor(uint32_t name, Color color);

void Text(String text);
void TextColored(Color color, String text);
void TextDisabled(String text);
void TextWrapped(String text);
void LabelText(const char* label, const char* text);
void BulletText(const char* text);
bool TreeNode(const char* str_id, const char* text);
void SetTooltip(const char* text);

void LabelText(const std::string& label, const std::string& text); //
void BulletText(const std::string& text); //
bool TreeNode(const std::string& str_id, const std::string& text); //
void SetTooltip(const std::string& text); //

bool Combo(
	const char* label,
	int* current_item,
	const char* const* items,
	int items_count,
	int height_in_items = -1);

bool Combo(
	const std::string& label,
	CallStack* stack, // current_item
	const std::vector<std::string>& items,
	int height_in_items = -1); //

bool DragFloat(
	const char* label,
	float* v,
	float v_speed,
	float v_min,
	float v_max,
	const char* display_format = "%.2f",
	Slice* flags = nullptr,
	int flagCount = 0);

bool DragFloat(
	const std::string& label,
	CallStack* stack, // v
	float v_speed,
	float v_min,
	float v_max,
	const std::string& display_format = "%.2f"s,
	uint32_t sliderFlags = 0); //

bool DragFloat2(
	const char* label,
	float* v1,
	float* v2,
	float v_speed,
	float v_min,
	float v_max,
	const char* display_format = "%.2f",
	Slice* flags = nullptr,
	int flagCount = 0);

bool DragFloat2(
	const std::string& label,
	CallStack* stack, // v1, v2
	float v_speed,
	float v_min,
	float v_max,
	const std::string& display_format = "%.2f"s,
	uint32_t sliderFlags = 0); //

bool DragInt(
	const char* label,
	int* v,
	float v_speed,
	int v_min,
	int v_max,
	const char* display_format = "%d",
	Slice* flags = nullptr,
	int flagCount = 0);

bool DragInt(
	const std::string& label,
	CallStack* stack, // v
	float v_speed,
	int v_min,
	int v_max,
	const std::string& display_format = "%d"s,
	uint32_t sliderFlags = 0); //

bool DragInt2(
	const char* label,
	int* v1,
	int* v2,
	float v_speed,
	int v_min,
	int v_max,
	const char* display_format = "%d",
	Slice* flags = nullptr,
	int flagCount = 0);

bool DragInt2(
	const std::string& label,
	CallStack* stack, // v1, v2
	float v_speed,
	int v_min,
	int v_max,
	const std::string& display_format = "%d"s,
	uint32_t sliderFlags = 0); //

bool InputFloat(
	const char* label,
	float* v,
	float step = 0.0f,
	float step_fast = 0.0f,
	const char* format = "%.2f",
	Slice* flags = nullptr,
	int flagCount = 0);

bool InputFloat(
	const std::string& label,
	CallStack* stack, // v
	float step = 0.0f,
	float step_fast = 0.0f,
	const std::string& format = "%.2f"s,
	uint32_t inputTextFlags = 0); //

bool InputFloat2(
	const char* label,
	float* v1,
	float* v2,
	const char* format = "%.2f",
	Slice* flags = nullptr,
	int flagCount = 0);

bool InputFloat2(
	const std::string& label,
	CallStack* stack, // v1, v2
	const std::string& format = "%.2f"s,
	uint32_t inputTextFlags = 0); //

bool InputInt(
	const char* label,
	int* v,
	int step = 1,
	int step_fast = 100,
	Slice* flags = nullptr,
	int flagCount = 0);

bool InputInt(
	const std::string& label,
	CallStack* stack, // v
	int step = 1,
	int step_fast = 100,
	uint32_t inputTextFlags = 0); //

bool InputInt2(
	const char* label,
	int* v1,
	int* v2,
	Slice* flags = nullptr,
	int flagCount = 0);

bool InputInt2(
	const std::string& label,
	CallStack* stack, // v1, v2
	uint32_t inputTextFlags = 0); //

bool SliderFloat(
	const char* label,
	float* v,
	float v_min,
	float v_max,
	const char* format = "%.2f",
	Slice* flags = nullptr,
	int flagCount = 0);

bool SliderFloat(
	const std::string& label,
	CallStack* stack, // v
	float v_min,
	float v_max,
	const std::string& format = "%.2f"s,
	uint32_t sliderFlags = 0); //

bool SliderFloat2(
	const char* label,
	float* v1,
	float* v2,
	float v_min,
	float v_max,
	const char* display_format = "%.2f",
	Slice* flags = nullptr,
	int flagCount = 0);

bool SliderFloat2(
	const std::string& label,
	CallStack* stack, // v1, v2
	float v_min,
	float v_max,
	const std::string& display_format = "%.2f"s,
	uint32_t sliderFlags = 0); //

bool SliderInt(
	const char* label,
	int* v,
	int v_min,
	int v_max,
	const char* format = "%d",
	Slice* flags = nullptr,
	int flagCount = 0);

bool SliderInt(
	const std::string& label,
	CallStack* stack, // v
	int v_min,
	int v_max,
	const std::string& format = "%d"s,
	uint32_t sliderFlags = 0); //

bool SliderInt2(
	const char* label,
	int* v1,
	int* v2,
	int v_min,
	int v_max,
	const char* display_format = "%d",
	Slice* flags = nullptr,
	int flagCount = 0);

bool SliderInt2(
	const std::string& label,
	CallStack* stack, // v1, v2
	int v_min,
	int v_max,
	const std::string& display_format = "%d"s,
	uint32_t sliderFlags = 0); //

bool DragFloatRange2(
	const char* label,
	float* v_current_min,
	float* v_current_max,
	float v_speed = 1.0f,
	float v_min = 0.0f,
	float v_max = 0.0f,
	const char* format = "%.2f",
	const char* format_max = nullptr,
	Slice* flags = nullptr,
	int flagCount = 0);

bool DragFloatRange2(
	const std::string& label,
	CallStack* stack, // v_current_min, v_current_max
	float v_speed,
	float v_min,
	float v_max,
	const std::string& format = "%.2f"s,
	const std::string& format_max = Slice::Empty,
	uint32_t sliderFlags = 0); //

bool DragIntRange2(
	const char* label,
	int* v_current_min,
	int* v_current_max,
	float v_speed = 1.0f,
	int v_min = 0,
	int v_max = 0,
	const char* format = "%d",
	const char* format_max = nullptr,
	Slice* flags = nullptr,
	int flagCount = 0);

bool DragIntRange2(
	const std::string& label,
	CallStack* stack, // v_current_min, v_current_max
	float v_speed,
	int v_min,
	int v_max,
	const std::string& format = "%d"s,
	const std::string& format_max = Slice::Empty,
	uint32_t sliderFlags = 0); //

bool VSliderFloat(
	const char* label,
	const Vec2& size,
	float* v,
	float v_min,
	float v_max,
	const char* format = "%.2f",
	Slice* flags = nullptr,
	int flagCount = 0);

bool VSliderFloat(
	const std::string& label,
	const Vec2& size,
	CallStack* stack, // v
	float v_min,
	float v_max,
	const std::string& format = "%.2f"s,
	uint32_t sliderFlags = 0); //

bool VSliderInt(
	const char* label,
	const Vec2& size,
	int* v,
	int v_min,
	int v_max,
	const char* format = "%d",
	Slice* flags = nullptr,
	int flagCount = 0);

bool VSliderInt(
	const std::string& label,
	const Vec2& size,
	CallStack* stack, // v
	int v_min,
	int v_max,
	const std::string& format = "%d"s,
	uint32_t sliderFlags = 0); //

bool ColorEdit3(const char* label, Color3* color3, Slice* colorEditFlags = nullptr, int colorEditFlagCount = 0);

bool ColorEdit3(const std::string& label, CallStack* stack /* color3 */, uint32_t colorEditFlags = 0);

bool ColorEdit4(
	const char* label,
	Color* color,
	Slice* colorEditFlags = nullptr,
	int colorEditFlagCount = 0);

bool ColorEdit4(
	const std::string& label,
	CallStack* stack, // color4
	uint32_t colorEditFlags = 0); //

void Image(
	String clipStr,
	const Vec2& size,
	Color bg_col = Color(0x0),
	Color tint_col = Color(0xffffffff));

bool ImageButton(
	const char* str_id,
	String clipStr,
	const Vec2& size,
	Color bg_col = Color(0x0),
	Color tint_col = Color(0xffffffff));

bool ImageButton(
	const std::string& str_id,
	String clipStr,
	const Vec2& size,
	Color bg_col = Color(0x0),
	Color tint_col = Color(0xffffffff)); //

bool ColorButton(
	const char* desc_id,
	Color col,
	Slice* colorEditFlags = nullptr,
	int colorEditFlagCount = 0,
	const Vec2& size = Vec2::zero);

bool ColorButton(
	const std::string& desc_id,
	Color col,
	uint32_t colorEditFlags = 0,
	const Vec2& size = Vec2::zero); //

void Columns(
	int count = 1,
	bool border = true);

void Columns(
	int count,
	bool border,
	const char* str_id);

void Columns(
	int count,
	bool border,
	const std::string& str_id); //

bool BeginTable(
	const char* str_id,
	int column,
	const Vec2& outer_size = Vec2::zero,
	float inner_width = 0.0f,
	Slice* flags = nullptr,
	int flagCount = 0);

bool BeginTable(
	const std::string& str_id,
	int column,
	const Vec2& outer_size = Vec2::zero,
	float inner_width = 0.0f,
	uint32_t tableFlags = 0); //

void TableNextRow(
	float min_row_height = 0.0f,
	String tableRowFlag = nullptr);

void TableSetupColumn(
	const char* label,
	float init_width_or_weight = 0.0f,
	ImU32 user_id = 0,
	Slice* flags = nullptr,
	int flagCount = 0);

void TableSetupColumn(
	const std::string& label,
	float init_width_or_weight = 0.0f,
	uint32_t user_id = 0,
	uint32_t tableColumnFlags = 0); //

void SetStyleVar(String name, bool var);
void SetStyleVar(String name, float var);
void SetStyleVar(String name, const Vec2& var);
void SetStyleColor(String name, Color color);

void ScrollWhenDraggingOnVoid();

inline void SetWindowFocus(String name) { ImGui::SetWindowFocus(name.c_str()); }
inline void SeparatorText(String text) { ImGui::SeparatorText(text.c_str()); }
inline void TableHeader(String label) { ImGui::TableHeader(label.c_str()); }
inline void PushID(String str_id) { ImGui::PushID(str_id.c_str()); }
inline uint32_t GetID(String str_id) { return ImGui::GetID(str_id.c_str()); }
inline bool Button(String label, Vec2 size) { return ImGui::Button(label.c_str(), size); };
inline bool SmallButton(String label) { return ImGui::SmallButton(label.c_str()); }
inline bool InvisibleButton(String str_id, Vec2 size) { return ImGui::InvisibleButton(str_id.c_str(), size); }

bool Checkbox(String label, CallStack* stack);
bool RadioButton(String label, CallStack* stack, int v_button);

void PlotLines(String label, const std::vector<float>& values, int values_offset = 0, String overlay_text = nullptr, float scale_min = FLT_MIN, float scale_max = FLT_MAX, Vec2 graph_size = Vec2::zero);

void PlotHistogram(String label, const std::vector<float>& values, int values_offset = 0, String overlay_text = nullptr, float scale_min = FLT_MIN, float scale_max = FLT_MAX, Vec2 graph_size = Vec2::zero);

inline void ProgressBar(float fraction, Vec2 size_arg = Vec2{-1, 0}, String overlay = nullptr) { ImGui::ProgressBar(fraction, size_arg, overlay.c_str()); }

bool ListBox(String label, CallStack* stack, const std::vector<std::string>& items, int height_in_items = -1);

bool SliderAngle(String label, CallStack* stack, float v_degrees_min, float v_degrees_max);

void PushItemFlag(Slice* options, int optionCount, bool enabled);

inline void TreePush(String str_id) { ImGui::TreePush(str_id.c_str()); }
inline bool BeginListBox(String label, Vec2 size) { return ImGui::BeginListBox(label.c_str(), size); }
inline void Value(String prefix, bool b) { ImGui::Value(prefix.c_str(), b); }
inline bool BeginMenu(String label, bool enabled) { return ImGui::BeginMenu(label.c_str(), enabled); };
inline bool MenuItem(String label, String shortcut, bool selected, bool enabled) { return ImGui::MenuItem(label.c_str(), shortcut.c_str(), selected, enabled); }
inline void OpenPopup(String str_id) { ImGui::OpenPopup(str_id.c_str()); }
inline bool BeginPopup(String str_id) { return ImGui::BeginPopup(str_id.c_str()); }

inline bool TextLink(String label) { return ImGui::TextLink(label.c_str()); }

bool BeginTabBar(const std::string& str_id, uint32_t flags = 0);
bool BeginTabBar(const char* str_id, Slice* flags = nullptr, int flagCount = 0);
bool BeginTabItem(const std::string& label, uint32_t flags = 0);
bool BeginTabItem(const char* label, Slice* flags = nullptr, int flagCount = 0);
bool BeginTabItem(const std::string& label, CallStack* stack, uint32_t flags = 0);
bool BeginTabItem(const char* label, bool* p_open, Slice* flags = nullptr, int flagCount = 0);
bool TabItemButton(const std::string& label, uint32_t flags = 0);
bool TabItemButton(const char* label, Slice* flags = nullptr, int flagCount = 0);
inline void SetTabItemClosed(const std::string& tab_or_docked_window_label) {
	ImGui::SetTabItemClosed(tab_or_docked_window_label.c_str());
}

NS_END(ImGui::Binding)
