typedef unsigned int ImGuiID;
typedef char* CString;

class Buffer : public Object
{
	void resize(uint32_t size);
	void zeroMemory();
	tolua_readonly tolua_property__qt uint32_t size;
	void setString(String str);
	Slice toString();
	static Buffer* create(uint32_t size = 0);
};

namespace ImGui
{
	void Binding::LoadFontTTFAsync @ LoadFontTTF(String ttfFontFile, float fontSize, String glyphRanges, tolua_function_void handler);
	bool Binding::IsFontLoaded @ IsFontLoaded();
	void Binding::ShowStats @ ShowStats(tolua_function_void handler = nullptr);
	void Binding::ShowConsole @ ShowConsole();
	bool Binding::Begin @ Begin(CString name);
	bool Binding::Begin @ Begin(CString name, String windowsFlags[tolua_len]);
	bool Binding::Begin @ Begin(CString name, bool* p_open);
	bool Binding::Begin @ Begin(CString name, bool* p_open, String windowsFlags[tolua_len]);
	bool Binding::BeginChild @ BeginChild(CString str_id, Vec2 size = Vec2::zero, bool border = false);
	bool Binding::BeginChild @ BeginChild(CString str_id, Vec2 size, bool border, String windowsFlags[tolua_len]);
	bool Binding::BeginChild @ BeginChild(ImGuiID id, Vec2 size = Vec2::zero, bool border = false);
	bool Binding::BeginChild @ BeginChild(ImGuiID id, Vec2 size, bool border, String windowsFlags[tolua_len]);
	void Binding::SetNextWindowPos @ SetNextWindowPos(Vec2 pos, String setCond = nullptr, Vec2 pivot = Vec2::zero);
	void Binding::SetNextWindowPosCenter @ SetNextWindowPosCenter(String setCond = nullptr, Vec2 pivot = Vec2::zero);
	void Binding::SetNextWindowSize @ SetNextWindowSize(Vec2 size, String setCond = nullptr);
	void Binding::SetNextWindowCollapsed @ SetNextWindowCollapsed(bool collapsed, String setCond = nullptr);
	void Binding::SetWindowPos @ SetWindowPos(CString name, Vec2 pos, String setCond = nullptr);
	void Binding::SetWindowSize @ SetWindowSize(CString name, Vec2 size, String setCond = nullptr);
	void Binding::SetWindowCollapsed @ SetWindowCollapsed(CString name, bool collapsed, String setCond = nullptr);
	void Binding::SetColorEditOptions @ SetColorEditOptions(String colorEditMode);
	bool Binding::InputText @ InputText(CString label, Buffer* buffer);
	bool Binding::InputText @ InputText(CString label, Buffer* buffer, String inputTextFlags[tolua_len]);
	bool Binding::InputTextMultiline @ InputTextMultiline(CString label, Buffer* buffer, Vec2 size = Vec2::zero);
	bool Binding::InputTextMultiline @ InputTextMultiline(CString label, Buffer* buffer, Vec2 size, String inputTextFlags[tolua_len]);
	bool Binding::TreeNodeEx @ TreeNodeEx(CString label);
	bool Binding::TreeNodeEx @ TreeNodeEx(CString label, String treeNodeFlags[tolua_len]);
	bool Binding::TreeNodeEx @ TreeNodeEx(CString str_id, CString text);
	bool Binding::TreeNodeEx @ TreeNodeEx(CString str_id, CString text, String treeNodeFlags[tolua_len]);
	void Binding::SetNextItemOpen @ SetNextItemOpen(bool is_open, String setCond = nullptr);
	bool Binding::CollapsingHeader @ CollapsingHeader(CString label);
	bool Binding::CollapsingHeader @ CollapsingHeader(CString label, String treeNodeFlags[tolua_len]);
	bool Binding::CollapsingHeader @ CollapsingHeader(CString label, bool* p_open);
	bool Binding::CollapsingHeader @ CollapsingHeader(CString label, bool* p_open, String treeNodeFlags[tolua_len]);
	bool Binding::Selectable @ Selectable(CString label);
	bool Binding::Selectable @ Selectable(CString label, String selectableFlags[tolua_len]);
	bool Binding::Selectable @ Selectable(CString label, bool* p_selected, Vec2 size = Vec2::zero);
	bool Binding::Selectable @ Selectable(CString label, bool* p_selected, Vec2 size, String selectableFlags[tolua_len]);
	bool Binding::BeginPopupModal @ BeginPopupModal(CString name);
	bool Binding::BeginPopupModal @ BeginPopupModal(CString name, String windowsFlags[tolua_len]);
	bool Binding::BeginPopupModal @ BeginPopupModal(CString name, bool* p_open);
	bool Binding::BeginPopupModal @ BeginPopupModal(CString name, bool* p_open, String windowsFlags[tolua_len]);
	bool Binding::BeginChildFrame @ BeginChildFrame(ImGuiID id, Vec2 size);
	bool Binding::BeginChildFrame @ BeginChildFrame(ImGuiID id, Vec2 size, String windowsFlags[tolua_len]);

	void Binding::PushStyleColor @ PushStyleColor(String name, Color color);
	void Binding::PushStyleVar @ PushStyleVar(String name, float val);
	void Binding::PushStyleVar @ PushStyleVar(String name, Vec2 val);

	void Binding::Text @ Text(String text);
	void Binding::TextColored @ TextColored(Color color, String text);
	void Binding::TextDisabled @ TextDisabled(String text);
	void Binding::TextWrapped @ TextWrapped(String text);
	void Binding::LabelText @ LabelText(CString label, CString text);
	void Binding::BulletText @ BulletText(CString text);
	bool Binding::TreeNode @ TreeNode(CString str_id, CString text);
	void Binding::SetTooltip @ SetTooltip(CString text);

	bool Binding::ColorEdit3 @ ColorEdit3(CString label, Color3* color3);
	bool Binding::ColorEdit4 @ ColorEdit4(CString label, Color* color, bool show_alpha = true);

	void Binding::Image @ Image(String clipStr, Vec2 size, Color tint_col = Color(0xffffffff), Color border_col = Color(0x0));
	bool Binding::ImageButton @ ImageButton(const char* str_id, String clipStr, Vec2 size, Color bg_col = Color(0x0), Color tint_col = Color(0xffffffff));

	bool Binding::ColorButton @ ColorButton(CString desc_id, Color col, String flags = nullptr, Vec2 size = Vec2::zero);
	
	void Binding::Columns @ Columns(int count = 1, bool border = true);
	void Binding::Columns @ Columns(int count, bool border, CString id);

	bool Binding::BeginTable @ BeginTable(CString str_id, int column, Vec2 outer_size = Vec2::zero, float inner_width = 0.0f);
	bool Binding::BeginTable @ BeginTable(CString str_id, int column, Vec2 outer_size, float inner_width, String flags[tolua_len]);
	void Binding::TableNextRow @ TableNextRow(float min_row_height = 0.0f, String row_flag = nullptr);
	void Binding::TableSetupColumn @ TableSetupColumn(CString label, float init_width_or_weight = 0.0f, uint32_t user_id = 0);
	void Binding::TableSetupColumn @ TableSetupColumn(CString label, float init_width_or_weight, uint32_t user_id, String flags[tolua_len]);

	void Binding::SetStyleVar @ SetStyleVar(String name, bool var);
	void Binding::SetStyleVar @ SetStyleVar(String name, float var);
	void Binding::SetStyleVar @ SetStyleVar(String name, Vec2 var);
	void Binding::SetStyleColor @ SetStyleColor(String name, Color color);
	
	bool Binding::Combo @ Combo(CString label, int* current_item, CString items[tolua_len], int height_in_items = -1);

	bool Binding::DragFloat @ DragFloat(CString label, float* v, float v_speed, float v_min, float v_max, CString display_format = "%.3f");
	bool Binding::DragFloat @ DragFloat(CString label, float* v, float v_speed, float v_min, float v_max, CString display_format, String flags[tolua_len]);
	bool Binding::DragFloat2 @ DragFloat2(CString label, float* v1, float* v2, float v_speed = 1.0f, float v_min = 0.0f, float v_max = 0.0f, CString display_format = "%.3f");
	bool Binding::DragFloat2 @ DragFloat2(CString label, float* v1, float* v2, float v_speed, float v_min, float v_max, CString display_format, String flags[tolua_len]);
	bool Binding::DragInt @ DragInt(CString label, int* v, float v_speed, int v_min, int v_max, CString display_format = "%d");
	bool Binding::DragInt @ DragInt(CString label, int* v, float v_speed, int v_min, int v_max, CString display_format, String flags[tolua_len]);
	bool Binding::DragInt2 @ DragInt2(CString label, int* v1, int* v2, float v_speed = 1.0f, int v_min = 0, int v_max = 0, CString display_format = "%.0f");
	bool Binding::DragInt2 @ DragInt2(CString label, int* v1, int* v2, float v_speed, int v_min, int v_max, CString display_format, String flags[tolua_len]);
	bool Binding::InputFloat @ InputFloat(CString label, float* v, float step = 0.0f, float step_fast = 0.0f, CString format = "%.3f");
	bool Binding::InputFloat @ InputFloat(CString label, float* v, float step, float step_fast, CString format, String flags[tolua_len]);
	bool Binding::InputFloat2 @ InputFloat2(CString label, float* v1, float* v2, CString format = "%.1f");
	bool Binding::InputFloat2 @ InputFloat2(CString label, float* v1, float* v2, CString format, String flags[tolua_len]);
	bool Binding::InputInt @ InputInt(CString label, int* v, int step = 1, int step_fast = 100);
	bool Binding::InputInt @ InputInt(CString label, int* v, int step, int step_fast, String flags[tolua_len]);
	bool Binding::InputInt2 @ InputInt2(CString label, int* v1, int* v2);
	bool Binding::InputInt2 @ InputInt2(CString label, int* v1, int* v2, String flags[tolua_len]);
	bool Binding::SliderFloat @ SliderFloat(CString label, float* v, float v_min, float v_max, CString format = "%.3f");
	bool Binding::SliderFloat @ SliderFloat(CString label, float* v, float v_min, float v_max, CString format, String flags[tolua_len]);
	bool Binding::SliderFloat2 @ SliderFloat2(CString label, float* v1, float* v2, float v_min, float v_max, CString display_format = "%.3f");
	bool Binding::SliderFloat2 @ SliderFloat2(CString label, float* v1, float* v2, float v_min, float v_max, CString display_format, String flags[tolua_len]);
	bool Binding::SliderInt @ SliderInt(CString label, int* v, int v_min, int v_max, CString format = "%d");
	bool Binding::SliderInt @ SliderInt(CString label, int* v, int v_min, int v_max, CString format, String flags[tolua_len]);
	bool Binding::SliderInt2 @ SliderInt2(CString label, int* v1, int* v2, int v_min, int v_max, CString display_format = "%.0f");
	bool Binding::SliderInt2 @ SliderInt2(CString label, int* v1, int* v2, int v_min, int v_max, CString display_format, String flags[tolua_len]);
	bool Binding::DragFloatRange2 @ DragFloatRange2(CString label, float* v_current_min, float* v_current_max, float v_speed = 1.0f, float v_min = 0.0f, float v_max = 0.0f, CString format = "%.3f", CString format_max = nullptr);
	bool Binding::DragFloatRange2 @ DragFloatRange2(CString label, float* v_current_min, float* v_current_max, float v_speed, float v_min, float v_max, CString format, CString format_max, String flags[tolua_len]);
	bool Binding::DragIntRange2 @ DragIntRange2(CString label, int* v_current_min, int* v_current_max, float v_speed = 1.0f, int v_min = 0, int v_max = 0, CString format = "%d", CString format_max = nullptr);	
	bool Binding::DragIntRange2 @ DragIntRange2(CString label, int* v_current_min, int* v_current_max, float v_speed, int v_min, int v_max, CString format, CString format_max, String flags[tolua_len]);	
	bool Binding::VSliderFloat @ VSliderFloat(CString label, Vec2 size, float* v, float v_min, float v_max, CString format = "%.3f");
	bool Binding::VSliderFloat @ VSliderFloat(CString label, Vec2 size, float* v, float v_min, float v_max, CString format, String flags[tolua_len]);
	bool Binding::VSliderInt @ VSliderInt(CString label, Vec2 size, int* v, int v_min, int v_max, CString format = "%d");
	bool Binding::VSliderInt @ VSliderInt(CString label, Vec2 size, int* v, int v_min, int v_max, CString format, String flags[tolua_len]);

	void SetNextWindowBgAlpha(float alpha);
	void ShowDemoWindow();
	void End();
	void EndChild();
	Vec2 GetContentRegionMax();
	Vec2 GetContentRegionAvail();
	Vec2 GetWindowContentRegionMin();
	Vec2 GetWindowContentRegionMax();
	Vec2 GetWindowPos();
	Vec2 GetWindowSize();
	float GetWindowWidth();
	float GetWindowHeight();
	bool IsWindowCollapsed();
	void SetWindowFontScale(float scale);
	void SetNextWindowSizeConstraints(Vec2 size_min, Vec2 size_max);
	void SetNextWindowContentSize(Vec2 size);
	void SetNextWindowFocus();
	void SetWindowFocus(CString name);
	float GetScrollX();
	float GetScrollY();
	float GetScrollMaxX();
	float GetScrollMaxY();
	void SetScrollX(float scroll_x);
	void SetScrollY(float scroll_y);
	void SetScrollHereY(float center_y_ratio = 0.5f);
	void SetScrollFromPosY(float pos_y, float center_y_ratio = 0.5f);
	void SetKeyboardFocusHere(int offset = 0);

	void PopStyleColor(int count = 1);
	void PopStyleVar(int count = 1);

	void PushItemWidth(float item_width);
	void PopItemWidth();
	float CalcItemWidth();
	void PushTextWrapPos(float wrap_pos_x = 0.0f);
	void PopTextWrapPos();
	void PushTabStop(bool v);
	void PopTabStop();
	void PushButtonRepeat(bool repeat);
	void PopButtonRepeat();

	void Separator();
	void SeparatorText(CString text);
	void SameLine(float pos_x = 0.0f, float spacing_w = -1.0f);
	void NewLine();
	void Spacing();
	void Dummy(Vec2 size);
	void Indent(float indent_w = 0.0f);
	void Unindent(float indent_w = 0.0f);
	void BeginGroup();
	void EndGroup();
	Vec2 GetCursorPos();
	float GetCursorPosX();
	float GetCursorPosY();
	void SetCursorPos(Vec2 local_pos);
	void SetCursorPosX(float x);
	void SetCursorPosY(float y);
	Vec2 GetCursorStartPos();
	Vec2 GetCursorScreenPos();
	void SetCursorScreenPos(Vec2 pos);
	void AlignTextToFramePadding();
	float GetTextLineHeight();
	float GetTextLineHeightWithSpacing();

	void NextColumn();
	int GetColumnIndex();
	float GetColumnOffset(int column_index = -1);
	void SetColumnOffset(int column_index, float offset_x);
	float GetColumnWidth(int column_index = -1);
	int GetColumnsCount();

	void EndTable();
	bool TableNextColumn();
	bool TableSetColumnIndex(int column_n);
	void TableSetupScrollFreeze(int cols, int rows);
	void TableHeadersRow();
	void TableHeader(CString label);

	void PushID(CString str_id);
	void PushID(int int_id);
	void PopID();
	ImGuiID GetID(CString str_id);

	void Bullet @ BulletItem();
	bool Button(CString label, Vec2 size = Vec2::zero);
	bool SmallButton(CString label);
	bool InvisibleButton(CString str_id, Vec2 size);
	bool Checkbox(CString label, bool* v);
	bool RadioButton(CString label, int* v, int v_button);
	bool RadioButton(CString label, bool active);
	void PlotLines(CString label, float values[tolua_len], int values_offset = 0, CString overlay_text = nullptr, float scale_min = FLT_MAX, float scale_max = FLT_MAX, Vec2 graph_size = Vec2::zero);
	void PlotHistogram(CString label, float values[tolua_len], int values_offset = 0, CString overlay_text = nullptr, float scale_min = FLT_MAX, float scale_max = FLT_MAX, Vec2 graph_size = Vec2::zero);
	void ProgressBar(float fraction, Vec2 size_arg = NewVec2(-1,0), CString overlay = nullptr);

	bool ListBox(CString label, int* current_item, CString items[tolua_len], int height_in_items = -1);

	bool SliderAngle(CString label, float* v_rad, float v_degrees_min = -360.0f, float v_degrees_max = 360.0f);

	bool TreeNode(CString label);
	void TreePush(CString str_id = nullptr);
	void TreePop();
	float GetTreeNodeToLabelSpacing();
	bool BeginListBox(CString label, Vec2 size = Vec2::zero);
	void EndListBox();

	void Value(CString prefix, bool b);
	void Value(CString prefix, int v);
	void Value(CString prefix, float v, CString float_format = nullptr);

	void BeginTooltip();
	void EndTooltip();

	bool BeginMainMenuBar();
	void EndMainMenuBar();
	bool BeginMenuBar();
	void EndMenuBar();
	bool BeginMenu(CString label, bool enabled = true);
	void EndMenu();
	bool MenuItem(CString label, CString shortcut = nullptr, bool selected = false, bool enabled = true);
	bool MenuItem @ MenuItemToggle(CString label, CString shortcut, bool* p_selected, bool enabled = true);

	void OpenPopup(CString str_id);
	bool BeginPopup(CString str_id);
	bool Binding::BeginPopupContextItem @ BeginPopupContextItem(CString str_id = nullptr);
	bool Binding::BeginPopupContextItem @ BeginPopupContextItem(CString str_id, String popupFlags[tolua_len]);
	bool Binding::BeginPopupContextWindow @ BeginPopupContextWindow(CString str_id = nullptr);
	bool Binding::BeginPopupContextWindow @ BeginPopupContextWindow(CString str_id, String popupFlags[tolua_len]);
	bool Binding::BeginPopupContextVoid @ BeginPopupContextVoid(CString str_id = nullptr);
	bool Binding::BeginPopupContextVoid @ BeginPopupContextVoid(CString str_id = nullptr, String popupFlags[tolua_len]);
	void EndPopup();
	void CloseCurrentPopup();

	void PushClipRect(Vec2 clip_rect_min, Vec2 clip_rect_max, bool intersect_with_current_clip_rect);
	void PopClipRect();

	bool IsItemHovered();
	bool IsItemActive();
	bool IsItemClicked(int mouse_button = 0);
	bool IsItemVisible();
	bool IsAnyItemHovered();
	bool IsAnyItemActive();
	Vec2 GetItemRectMin();
	Vec2 GetItemRectMax();
	Vec2 GetItemRectSize();
	void SetNextItemAllowOverlap();
	bool IsWindowHovered();
	bool IsWindowFocused();
	bool IsRectVisible(Vec2 size);
	bool IsRectVisible(Vec2 rect_min, Vec2 rect_max);
	void EndChildFrame();
	bool IsMouseDown(int button);
	bool IsMouseClicked(int button, bool repeat = false);
	bool IsMouseDoubleClicked(int button);
	bool IsMouseReleased(int button);
	bool IsMouseHoveringRect(Vec2 r_min, Vec2 r_max, bool clip = true);
	bool IsMouseDragging(int button = 0, float lock_threshold = -1.0f);
	Vec2 GetMousePos();
	Vec2 GetMousePosOnOpeningCurrentPopup();
	Vec2 GetMouseDragDelta(int button = 0, float lock_threshold = -1.0f);
	void ResetMouseDragDelta(int button = 0);
};
