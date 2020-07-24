typedef unsigned int ImGuiID;
typedef unsigned int ImGuiCol;
typedef int ImGuiWindowFlags;
typedef Uint32 ImU32;
typedef char* CString;

class Buffer : public Object
{
	void resize(Uint32 size);
	void zeroMemory();
	tolua_readonly tolua_property__qt Uint32 size;
	void setString(String str);
	Slice toString();
	static Buffer* create(Uint32 size = 0);
};

namespace ImGui
{
	void Binding::LoadFontTTF @ LoadFontTTF(String ttfFontFile, float fontSize, String glyphRanges = "Default");
	void Binding::ShowStats @ ShowStats();
	void Binding::ShowLog @ ShowLog();
	bool Binding::Begin @ Begin(const char* name, String windowsFlags = nullptr);
	bool Binding::Begin @ Begin(const char* name, bool* p_open, String windowsFlags = nullptr);
	bool Binding::BeginChild @ BeginChild(const char* str_id, Vec2 size = Vec2::zero, bool border = false, String windowsFlags = nullptr);
	bool Binding::BeginChild @ BeginChild(ImGuiID id, Vec2 size = Vec2::zero, bool border = false, String windowsFlags = nullptr);
	void Binding::SetNextWindowPos @ SetNextWindowPos(Vec2 pos, String setCond = nullptr);
	void Binding::SetNextWindowPosCenter @ SetNextWindowPosCenter(String setCond = nullptr);
	void Binding::SetNextWindowSize @ SetNextWindowSize(Vec2 size, String setCond = nullptr);
	void Binding::SetNextWindowCollapsed @ SetNextWindowCollapsed(bool collapsed, String setCond = nullptr);
	void Binding::SetWindowPos @ SetWindowPos(const char* name, Vec2 pos, String setCond = nullptr);
	void Binding::SetWindowSize @ SetWindowSize(const char* name, Vec2 size, String setCond = nullptr);
	void Binding::SetWindowCollapsed @ SetWindowCollapsed(const char* name, bool collapsed, String setCond = nullptr);
	void Binding::SetColorEditOptions @ SetColorEditOptions(String colorEditMode);
	bool Binding::InputText @ InputText(const char* label, Buffer* buffer, String inputTextFlags = nullptr);
	bool Binding::InputTextMultiline @ InputTextMultiline(const char* label, Buffer* buffer, Vec2 size = Vec2::zero, String inputTextFlags = nullptr);
	bool Binding::InputFloat @ InputFloat(const char* label, float* v, float step = 0.0f, float step_fast = 0.0f, String format = "%.1f", String inputTextFlags = nullptr);
	bool Binding::InputInt @ InputInt(const char* label, int* v, int step = 1, int step_fast = 100, String inputTextFlags = nullptr);
	bool Binding::TreeNodeEx @ TreeNodeEx(const char* label, String treeNodeFlags = nullptr);
	void Binding::SetNextItemOpen @ SetNextItemOpen(bool is_open, String setCond = nullptr);
	bool Binding::CollapsingHeader @ CollapsingHeader(const char* label, String treeNodeFlags = nullptr);
	bool Binding::CollapsingHeader @ CollapsingHeader(const char* label, bool* p_open, String treeNodeFlags = nullptr);
	bool Binding::Selectable @ Selectable(const char* label, bool selected = false, String selectableFlags = nullptr, Vec2 size = Vec2::zero);
	bool Binding::Selectable @ Selectable(const char* label, bool* p_selected, String selectableFlags = nullptr, Vec2 size = Vec2::zero);
	bool Binding::BeginPopupModal @ BeginPopupModal(const char* name, String windowsFlags = nullptr);
	bool Binding::BeginPopupModal @ BeginPopupModal(const char* name, bool* p_open, String windowsFlags = nullptr);
	bool Binding::BeginChildFrame @ BeginChildFrame(ImGuiID id, Vec2 size, String windowsFlags = nullptr);

	void Binding::PushStyleColor @ PushStyleColor(String name, Color color);
	void Binding::PushStyleVar @ PushStyleVar(String name, float val);
	void Binding::PushStyleVar @ PushStyleVar(String name, Vec2 val);

	bool Binding::TreeNodeEx @ TreeNodeEx(const char* str_id, String treeNodeFlags, const char* text);

	void Binding::Text @ Text(String text);
	void Binding::TextColored @ TextColored(Color color, String text);
	void Binding::TextDisabled @ TextDisabled(String text);
	void Binding::TextWrapped @ TextWrapped(String text);
	void Binding::LabelText @ LabelText(const char* label, const char* text);
	void Binding::BulletText @ BulletText(const char* text);
	bool Binding::TreeNode @ TreeNode(const char* str_id, const char* text);
	void Binding::SetTooltip @ SetTooltip(const char* text);

	bool Binding::ColorEdit3 @ ColorEdit3(const char* label, Color3& color3);
	bool Binding::ColorEdit4 @ ColorEdit4(const char* label, Color& color, bool show_alpha = true);

	void Binding::Image @ Image(Texture2D* user_texture, Vec2 size, Vec2 uv0 = Vec2::zero, Vec2 uv1 = NewVec2(1,1), Color tint_col = Color(0xffffffff), Color border_col = Color(0x0));
	bool Binding::ImageButton @ ImageButton(Texture2D* user_texture, Vec2 size, Vec2 uv0 = Vec2::zero, Vec2 uv1 = NewVec2(1,1), int frame_padding = -1, Color bg_col = Color(0x0), Color tint_col = Color(0xffffffff));

	bool Binding::ColorButton @ ColorButton(const char* desc_id, Color col, String flags = nullptr, Vec2 size = Vec2::zero);
	
	void Binding::Columns @ Columns(int count = 1, bool border = true);
	void Binding::Columns @ Columns(int count, bool border, const char* id);

	void Binding::SetStyleVar @ SetStyleVar(String name, bool var);
	void Binding::SetStyleVar @ SetStyleVar(String name, float var);
	void Binding::SetStyleVar @ SetStyleVar(String name, Vec2 var);
	void Binding::SetStyleColor @ SetStyleColor(String name, Color color);
	
	bool Binding::Combo @ Combo(const char* label, int* current_item, char* items[tolua_len], int height_in_items = -1);

	bool Binding::DragFloat2 @ DragFloat2(const char* label, Vec2& v, float v_speed = 1.0f, float v_min = 0.0f, float v_max = 0.0f, const char* display_format = "%.3f", float power = 1.0f);
	bool Binding::DragInt2 @ DragInt2(const char* label, Vec2& v, float v_speed = 1.0f, int v_min = 0, int v_max = 0, const char* display_format = "%.0f");
	bool Binding::InputFloat2 @ InputFloat2(const char* label, Vec2& v, String format = "%.1f", String extra_flags = nullptr);
	bool Binding::InputInt2 @ InputInt2(const char* label, Vec2& v, String extra_flags = nullptr);
	bool Binding::SliderFloat2 @ SliderFloat2(const char* label, Vec2& v, float v_min, float v_max, const char* display_format = "%.3f", float power = 1.0f);
	bool Binding::SliderInt2 @ SliderInt2(const char* label, Vec2& v, int v_min, int v_max, const char* display_format = "%.0f");

	void ShowDemoWindow();
	void End();
	void EndChild();
	Vec2 GetContentRegionMax();
	Vec2 GetContentRegionAvail();
	Vec2 GetWindowContentRegionMin();
	Vec2 GetWindowContentRegionMax();
	float GetWindowContentRegionWidth();
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
	void PushAllowKeyboardFocus(bool v);
	void PopAllowKeyboardFocus();
	void PushButtonRepeat(bool repeat);
	void PopButtonRepeat();

	void Separator();
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


	void PushID(CString str_id);
	void PushID(int int_id);
	void PopID();
	ImGuiID GetID(CString str_id);

	void Bullet();
	bool Button(CString label, Vec2 size = Vec2::zero);
	bool SmallButton(CString label);
	bool InvisibleButton(CString str_id, Vec2 size);
	bool Checkbox(CString label, bool* v);
	bool RadioButton(CString label, bool active);
	bool RadioButton(CString label, int* v, int v_button);
	void PlotLines(CString label, float values[tolua_len], int values_offset = 0, CString overlay_text = nullptr, float scale_min = FLT_MAX, float scale_max = FLT_MAX, Vec2 graph_size = Vec2::zero, int stride = sizeof(float));
	void PlotHistogram(CString label, float values[tolua_len], int values_offset = 0, CString overlay_text = nullptr, float scale_min = FLT_MAX, float scale_max = FLT_MAX, Vec2 graph_size = Vec2::zero, int stride = sizeof(float));
	void ProgressBar(float fraction, Vec2 size_arg = NewVec2(-1,0), CString overlay = nullptr);

	bool ListBox(const char* label, int* current_item, char* items[tolua_len], int height_in_items = -1);

	bool DragFloat(CString label, float* v, float v_speed = 1.0f, float v_min = 0.0f, float v_max = 0.0f, CString display_format = "%.3f", float power = 1.0f);
	bool DragFloatRange2(CString label, float* v_current_min, float* v_current_max, float v_speed = 1.0f, float v_min = 0.0f, float v_max = 0.0f, CString display_format = "%.3f", CString display_format_max = nullptr, float power = 1.0f);
	bool DragInt(CString label, int* v, float v_speed = 1.0f, int v_min = 0, int v_max = 0, CString display_format = "%.0f");
	bool DragIntRange2(CString label, int* v_current_min, int* v_current_max, float v_speed = 1.0f, int v_min = 0, int v_max = 0, CString display_format = "%.0f", CString display_format_max = nullptr);

	bool SliderFloat(CString label, float* v, float v_min, float v_max, CString display_format = "%.3f", float power = 1.0f);
	bool SliderAngle(CString label, float* v_rad, float v_degrees_min = -360.0f, float v_degrees_max = 360.0f);
	bool SliderInt(CString label, int* v, int v_min, int v_max, CString display_format = "%.0f");
	bool VSliderFloat(CString label, Vec2 size, float* v, float v_min, float v_max, CString display_format = "%.3f", float power = 1.0f);
	bool VSliderInt(CString label, Vec2 size, int* v, int v_min, int v_max, CString display_format = "%.0f");

	bool TreeNode(CString label);
	void TreePush(CString str_id = nullptr);
	void TreePop();
	float GetTreeNodeToLabelSpacing();
	bool ListBoxHeader(CString label, Vec2 size = Vec2::zero);
	bool ListBoxHeader(CString label, int items_count, int height_in_items = -1);
	void ListBoxFooter();

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
	bool Binding::BeginPopupContextItem @ BeginPopupContextItem(CString str_id = nullptr, String popupFlags = nullptr);
	bool Binding::BeginPopupContextWindow @ BeginPopupContextWindow(CString str_id = nullptr, String popupFlags = nullptr);
	bool Binding::BeginPopupContextVoid @ BeginPopupContextVoid(CString str_id = nullptr, String popupFlags = nullptr);
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
	void SetItemAllowOverlap();
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
