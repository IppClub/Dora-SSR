/* Copyright (c) 2023 Jin Li, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "GUI/ImGuiBinding.h"

#include "Cache/ClipCache.h"
#include "Cache/TextureCache.h"
#include "GUI/ImGuiDora.h"

#include "Wasm/WasmRuntime.h"

NS_DOROTHY_BEGIN

/* Buffer */

Buffer::Buffer(uint32_t size)
	: _data(size) {
	zeroMemory();
}

void Buffer::resize(uint32_t size) {
	_data.resize(s_cast<size_t>(size));
}

void Buffer::zeroMemory() {
	std::memset(_data.data(), 0, _data.size());
}

char* Buffer::get() {
	return _data.data();
}

uint32_t Buffer::size() const {
	return s_cast<uint32_t>(_data.size());
}

void Buffer::setString(String str) {
	if (_data.empty()) return;
	size_t length = std::min(_data.size() - 1, str.size());
	std::memcpy(_data.data(), str.begin(), length);
	_data[length] = '\0';
}

Slice Buffer::toString() {
	size_t size = 0;
	for (auto ch : _data) {
		if (ch == '\0') {
			break;
		}
		size++;
	}
	return Slice(_data.data(), size);
}

NS_DOROTHY_END

NS_BEGIN(ImGui::Binding)

std::vector<std::string> EmptyOptions;

static ImGuiSliderFlags_ getSliderFlag(String flag) {
	switch (Switch::hash(flag)) {
		case "AlwaysClamp"_hash:
			return ImGuiSliderFlags_AlwaysClamp;
		case "Logarithmic"_hash:
			return ImGuiSliderFlags_Logarithmic;
		case "NoRoundToFormat"_hash:
			return ImGuiSliderFlags_NoRoundToFormat;
		case "NoInput"_hash:
			return ImGuiSliderFlags_NoInput;
		case ""_hash: return ImGuiSliderFlags_None;
		default:
			Issue("ImGui slider flag named \"{}\" is invalid.", flag);
			break;
	}
	return ImGuiSliderFlags_None;
}

static uint32_t SliderFlags(Slice* flags, int count) {
	uint32_t result = 0;
	for (int i = 0; i < count; i++) {
		result |= getSliderFlag(flags[i]);
	}
	return result;
}

static uint32_t SliderFlags(const std::vector<std::string>& flags) {
	uint32_t result = 0;
	for (const auto& flag : flags) {
		result |= getSliderFlag(flag);
	}
	return result;
}

static ImGuiWindowFlags_ getWindowFlag(String style) {
	switch (Switch::hash(style)) {
		case "NoNav"_hash: return ImGuiWindowFlags_NoNav;
		case "NoDecoration"_hash: return ImGuiWindowFlags_NoDecoration;
		case "NoTitleBar"_hash: return ImGuiWindowFlags_NoTitleBar;
		case "NoResize"_hash: return ImGuiWindowFlags_NoResize;
		case "NoMove"_hash: return ImGuiWindowFlags_NoMove;
		case "NoScrollbar"_hash: return ImGuiWindowFlags_NoScrollbar;
		case "NoScrollWithMouse"_hash: return ImGuiWindowFlags_NoScrollWithMouse;
		case "NoCollapse"_hash: return ImGuiWindowFlags_NoCollapse;
		case "AlwaysAutoResize"_hash: return ImGuiWindowFlags_AlwaysAutoResize;
		case "NoSavedSettings"_hash: return ImGuiWindowFlags_NoSavedSettings;
		case "NoInputs"_hash: return ImGuiWindowFlags_NoInputs;
		case "MenuBar"_hash: return ImGuiWindowFlags_MenuBar;
		case "HorizontalScrollbar"_hash: return ImGuiWindowFlags_HorizontalScrollbar;
		case "NoFocusOnAppearing"_hash: return ImGuiWindowFlags_NoFocusOnAppearing;
		case "NoBringToFrontOnFocus"_hash: return ImGuiWindowFlags_NoBringToFrontOnFocus;
		case "AlwaysVerticalScrollbar"_hash: return ImGuiWindowFlags_AlwaysVerticalScrollbar;
		case "AlwaysHorizontalScrollbar"_hash: return ImGuiWindowFlags_AlwaysHorizontalScrollbar;
		case "AlwaysUseWindowPadding"_hash: return ImGuiWindowFlags_AlwaysUseWindowPadding;
		case ""_hash: return ImGuiWindowFlags_(0);
		default:
			Issue("ImGui window flag named \"{}\" is invalid.", style);
			break;
	}
	return ImGuiWindowFlags_(0);
}

static uint32_t WindowFlags(Slice* flags, int count) {
	uint32_t result = 0;
	for (int i = 0; i < count; i++) {
		result |= getWindowFlag(flags[i]);
	}
	return result;
}

static uint32_t WindowFlags(const std::vector<std::string>& flags) {
	uint32_t result = 0;
	for (const auto& flag : flags) {
		result |= getWindowFlag(flag);
	}
	return result;
}

static ImGuiInputTextFlags_ getInputTextFlag(String flag) {
	switch (Switch::hash(flag)) {
		case "CharsDecimal"_hash: return ImGuiInputTextFlags_CharsDecimal;
		case "CharsHexadecimal"_hash: return ImGuiInputTextFlags_CharsHexadecimal;
		case "CharsUppercase"_hash: return ImGuiInputTextFlags_CharsUppercase;
		case "CharsNoBlank"_hash: return ImGuiInputTextFlags_CharsNoBlank;
		case "AutoSelectAll"_hash: return ImGuiInputTextFlags_AutoSelectAll;
		case "EnterReturnsTrue"_hash: return ImGuiInputTextFlags_EnterReturnsTrue;
		case "CallbackCompletion"_hash: return ImGuiInputTextFlags_CallbackCompletion;
		case "CallbackHistory"_hash: return ImGuiInputTextFlags_CallbackHistory;
		case "CallbackAlways"_hash: return ImGuiInputTextFlags_CallbackAlways;
		case "CallbackCharFilter"_hash: return ImGuiInputTextFlags_CallbackCharFilter;
		case "AllowTabInput"_hash: return ImGuiInputTextFlags_AllowTabInput;
		case "CtrlEnterForNewLine"_hash: return ImGuiInputTextFlags_CtrlEnterForNewLine;
		case "NoHorizontalScroll"_hash: return ImGuiInputTextFlags_NoHorizontalScroll;
		case "AlwaysOverwrite"_hash: return ImGuiInputTextFlags_AlwaysOverwrite;
		case "ReadOnly"_hash: return ImGuiInputTextFlags_ReadOnly;
		case "Password"_hash: return ImGuiInputTextFlags_Password;
		case ""_hash: return ImGuiInputTextFlags_(0);
		default:
			Issue("ImGui input text flag named \"{}\" is invalid.", flag);
			return ImGuiInputTextFlags_(0);
	}
}

static uint32_t InputTextFlags(Slice* flags, int count) {
	uint32_t result = 0;
	for (int i = 0; i < count; i++) {
		result |= getInputTextFlag(flags[i]);
	}
	return result;
}

static uint32_t InputTextFlags(const std::vector<std::string>& flags) {
	uint32_t result = 0;
	for (const auto& flag : flags) {
		result |= getInputTextFlag(flag);
	}
	return result;
}

static ImGuiTreeNodeFlags_ getTreeNodeFlag(String flag) {
	switch (Switch::hash(flag)) {
		case "Selected"_hash: return ImGuiTreeNodeFlags_Selected;
		case "Framed"_hash: return ImGuiTreeNodeFlags_Framed;
		case "AllowOverlap"_hash: return ImGuiTreeNodeFlags_AllowOverlap;
		case "NoTreePushOnOpen"_hash: return ImGuiTreeNodeFlags_NoTreePushOnOpen;
		case "NoAutoOpenOnLog"_hash: return ImGuiTreeNodeFlags_NoAutoOpenOnLog;
		case "DefaultOpen"_hash: return ImGuiTreeNodeFlags_DefaultOpen;
		case "OpenOnDoubleClick"_hash: return ImGuiTreeNodeFlags_OpenOnDoubleClick;
		case "OpenOnArrow"_hash: return ImGuiTreeNodeFlags_OpenOnArrow;
		case "Leaf"_hash: return ImGuiTreeNodeFlags_Leaf;
		case "Bullet"_hash: return ImGuiTreeNodeFlags_Bullet;
		case "CollapsingHeader"_hash: return ImGuiTreeNodeFlags_CollapsingHeader;
		case ""_hash: return ImGuiTreeNodeFlags_(0);
		default:
			Issue("ImGui tree node flag named \"{}\" is invalid.", flag);
			return ImGuiTreeNodeFlags_(0);
	}
}

static uint32_t TreeNodeFlags(Slice* flags, int count) {
	uint32_t result = 0;
	for (int i = 0; i < count; i++) {
		result |= getTreeNodeFlag(flags[i]);
	}
	return result;
}

static uint32_t TreeNodeFlags(const std::vector<std::string>& flags) {
	uint32_t result = 0;
	for (const auto& flag : flags) {
		result |= getTreeNodeFlag(flag);
	}
	return result;
}

static ImGuiSelectableFlags_ getSelectableFlag(String flag) {
	switch (Switch::hash(flag)) {
		case "DontClosePopups"_hash: return ImGuiSelectableFlags_DontClosePopups;
		case "SpanAllColumns"_hash: return ImGuiSelectableFlags_SpanAllColumns;
		case "AllowDoubleClick"_hash: return ImGuiSelectableFlags_AllowDoubleClick;
		case "Disabled"_hash: return ImGuiSelectableFlags_Disabled;
		case "AllowOverlap"_hash: return ImGuiSelectableFlags_AllowOverlap;
		case ""_hash: return ImGuiSelectableFlags_None;
		default:
			Issue("ImGui selectable flag named \"{}\" is invalid.", flag);
			return ImGuiSelectableFlags_None;
	}
}

static uint32_t SelectableFlags(Slice* flags, int count) {
	uint32_t result = 0;
	for (int i = 0; i < count; i++) {
		result |= getSelectableFlag(flags[i]);
	}
	return result;
}

static uint32_t SelectableFlags(const std::vector<std::string>& flags) {
	uint32_t result = 0;
	for (const auto& flag : flags) {
		result |= getSelectableFlag(flag);
	}
	return result;
}

static uint32_t ColorIndex(String col) {
	switch (Switch::hash(col)) {
		case "Text"_hash: return ImGuiCol_Text;
		case "TextDisabled"_hash: return ImGuiCol_TextDisabled;
		case "WindowBg"_hash: return ImGuiCol_WindowBg;
		case "ChildBg"_hash: return ImGuiCol_ChildBg;
		case "PopupBg"_hash: return ImGuiCol_PopupBg;
		case "Border"_hash: return ImGuiCol_Border;
		case "BorderShadow"_hash: return ImGuiCol_BorderShadow;
		case "FrameBg"_hash: return ImGuiCol_FrameBg;
		case "FrameBgHovered"_hash: return ImGuiCol_FrameBgHovered;
		case "FrameBgActive"_hash: return ImGuiCol_FrameBgActive;
		case "TitleBg"_hash: return ImGuiCol_TitleBg;
		case "TitleBgActive"_hash: return ImGuiCol_TitleBgActive;
		case "TitleBgCollapsed"_hash: return ImGuiCol_TitleBgCollapsed;
		case "MenuBarBg"_hash: return ImGuiCol_MenuBarBg;
		case "ScrollbarBg"_hash: return ImGuiCol_ScrollbarBg;
		case "ScrollbarGrab"_hash: return ImGuiCol_ScrollbarGrab;
		case "ScrollbarGrabHovered"_hash: return ImGuiCol_ScrollbarGrabHovered;
		case "ScrollbarGrabActive"_hash: return ImGuiCol_ScrollbarGrabActive;
		case "CheckMark"_hash: return ImGuiCol_CheckMark;
		case "SliderGrabActive"_hash: return ImGuiCol_SliderGrabActive;
		case "Button"_hash: return ImGuiCol_Button;
		case "ButtonHovered"_hash: return ImGuiCol_ButtonHovered;
		case "ButtonActive"_hash: return ImGuiCol_ButtonActive;
		case "Header"_hash: return ImGuiCol_Header;
		case "HeaderHovered"_hash: return ImGuiCol_HeaderHovered;
		case "HeaderActive"_hash: return ImGuiCol_HeaderActive;
		case "Separator"_hash: return ImGuiCol_Separator;
		case "SeparatorHovered"_hash: return ImGuiCol_SeparatorHovered;
		case "SeparatorActive"_hash: return ImGuiCol_SeparatorActive;
		case "ResizeGrip"_hash: return ImGuiCol_ResizeGrip;
		case "ResizeGripHovered"_hash: return ImGuiCol_ResizeGripHovered;
		case "ResizeGripActive"_hash: return ImGuiCol_ResizeGripActive;
		case "Tab"_hash: return ImGuiCol_Tab;
		case "TabHovered"_hash: return ImGuiCol_TabHovered;
		case "TabActive"_hash: return ImGuiCol_TabActive;
		case "TabUnfocused"_hash: return ImGuiCol_TabUnfocused;
		case "TabUnfocusedActive"_hash: return ImGuiCol_TabUnfocusedActive;
		case "PlotLines"_hash: return ImGuiCol_PlotLines;
		case "PlotLinesHovered"_hash: return ImGuiCol_PlotLinesHovered;
		case "PlotHistogram"_hash: return ImGuiCol_PlotHistogram;
		case "PlotHistogramHovered"_hash: return ImGuiCol_PlotHistogramHovered;
		case "TableHeaderBg"_hash: return ImGuiCol_TableHeaderBg;
		case "TableBorderStrong"_hash: return ImGuiCol_TableBorderStrong;
		case "TableBorderLight"_hash: return ImGuiCol_TableBorderLight;
		case "TableRowBg"_hash: return ImGuiCol_TableRowBg;
		case "TableRowBgAlt"_hash: return ImGuiCol_TableRowBgAlt;
		case "TextSelectedBg"_hash: return ImGuiCol_TextSelectedBg;
		case "DragDropTarget"_hash: return ImGuiCol_DragDropTarget;
		case "NavHighlight"_hash: return ImGuiCol_NavHighlight;
		case "NavWindowingHighlight"_hash: return ImGuiCol_NavWindowingHighlight;
		case "NavWindowingDimBg"_hash: return ImGuiCol_NavWindowingDimBg;
		case "ModalWindowDimBg"_hash: return ImGuiCol_ModalWindowDimBg;
		default:
			Issue("ImGui color index named \"{}\" is invalid.", col);
			return ImGuiCol_(0);
	}
}

static uint32_t ColorEditFlag(String mode) {
	switch (Switch::hash(mode)) {
		case "RGB"_hash: return ImGuiColorEditFlags_DisplayRGB;
		case "HSV"_hash: return ImGuiColorEditFlags_DisplayHSV;
		case "HEX"_hash: return ImGuiColorEditFlags_DisplayHex;
		case ""_hash: return ImGuiColorEditFlags_None;
		default:
			Issue("ImGui color edit flag named \"{}\" is invalid.", mode);
			return ImGuiColorEditFlags_None;
	}
}

static uint32_t SetCondFlag(String cond) {
	switch (Switch::hash(cond)) {
		case "Always"_hash: return ImGuiCond_Always;
		case "Once"_hash: return ImGuiCond_Once;
		case "FirstUseEver"_hash: return ImGuiCond_FirstUseEver;
		case "Appearing"_hash: return ImGuiCond_Appearing;
		case ""_hash: return ImGuiCond_(0);
		default:
			Issue("ImGui set cond named \"{}\" is invalid.", cond);
			return ImGuiCond_(0);
	}
}

static ImGuiPopupFlags getPopupFlag(String flag) {
	switch (Switch::hash(flag)) {
		case "MouseButtonLeft"_hash: return ImGuiPopupFlags_MouseButtonLeft;
		case "MouseButtonRight"_hash: return ImGuiPopupFlags_MouseButtonRight;
		case "MouseButtonMiddle"_hash: return ImGuiPopupFlags_MouseButtonMiddle;
		case "NoOpenOverExistingPopup"_hash: return ImGuiPopupFlags_NoOpenOverExistingPopup;
		case "NoOpenOverItems"_hash: return ImGuiPopupFlags_NoOpenOverItems;
		case "AnyPopupId"_hash: return ImGuiPopupFlags_AnyPopupId;
		case "AnyPopupLevel"_hash: return ImGuiPopupFlags_AnyPopupLevel;
		case "AnyPopup"_hash: return ImGuiPopupFlags_AnyPopup;
		case ""_hash: return ImGuiPopupFlags_None;
		default:
			Issue("ImGui popup flag named \"{}\" is invalid.", flag);
			return ImGuiPopupFlags_None;
	}
}

static uint32_t PopupFlags(Slice* flags, int count) {
	uint32_t result = 0;
	for (int i = 0; i < count; i++) {
		result |= getPopupFlag(flags[i]);
	}
	return result;
}

static uint32_t PopupFlags(const std::vector<std::string>& flags) {
	uint32_t result = 0;
	for (const auto& flag : flags) {
		result |= getPopupFlag(flag);
	}
	return result;
}

static ImGuiTableFlags_ getTableFlags(String flag) {
	switch (Switch::hash(flag)) {
		case "Resizable"_hash: return ImGuiTableFlags_Resizable;
		case "Reorderable"_hash: return ImGuiTableFlags_Reorderable;
		case "Hideable"_hash: return ImGuiTableFlags_Hideable;
		case "Sortable"_hash: return ImGuiTableFlags_Sortable;
		case "NoSavedSettings"_hash: return ImGuiTableFlags_NoSavedSettings;
		case "ContextMenuInBody"_hash: return ImGuiTableFlags_ContextMenuInBody;
		case "RowBg"_hash: return ImGuiTableFlags_RowBg;
		case "BordersInnerH"_hash: return ImGuiTableFlags_BordersInnerH;
		case "BordersOuterH"_hash: return ImGuiTableFlags_BordersOuterH;
		case "BordersInnerV"_hash: return ImGuiTableFlags_BordersInnerV;
		case "BordersOuterV"_hash: return ImGuiTableFlags_BordersOuterV;
		case "BordersH"_hash: return ImGuiTableFlags_BordersH;
		case "BordersV"_hash: return ImGuiTableFlags_BordersV;
		case "BordersInner"_hash: return ImGuiTableFlags_BordersInner;
		case "BordersOuter"_hash: return ImGuiTableFlags_BordersOuter;
		case "Borders"_hash: return ImGuiTableFlags_Borders;
		case "NoBordersInBody"_hash: return ImGuiTableFlags_NoBordersInBody;
		case "NoBordersInBodyUntilResize"_hash: return ImGuiTableFlags_NoBordersInBodyUntilResize;
		case "SizingFixedFit"_hash: return ImGuiTableFlags_SizingFixedFit;
		case "SizingFixedSame"_hash: return ImGuiTableFlags_SizingFixedSame;
		case "SizingStretchProp"_hash: return ImGuiTableFlags_SizingStretchProp;
		case "SizingStretchSame"_hash: return ImGuiTableFlags_SizingStretchSame;
		case "NoHostExtendX"_hash: return ImGuiTableFlags_NoHostExtendX;
		case "NoHostExtendY"_hash: return ImGuiTableFlags_NoHostExtendY;
		case "NoKeepColumnsVisible"_hash: return ImGuiTableFlags_NoKeepColumnsVisible;
		case "PreciseWidths"_hash: return ImGuiTableFlags_PreciseWidths;
		case "NoClip"_hash: return ImGuiTableFlags_NoClip;
		case "PadOuterX"_hash: return ImGuiTableFlags_PadOuterX;
		case "NoPadOuterX"_hash: return ImGuiTableFlags_NoPadOuterX;
		case "NoPadInnerX"_hash: return ImGuiTableFlags_NoPadInnerX;
		case "ScrollX"_hash: return ImGuiTableFlags_ScrollX;
		case "ScrollY"_hash: return ImGuiTableFlags_ScrollY;
		case "SortMulti"_hash: return ImGuiTableFlags_SortMulti;
		case ""_hash: return ImGuiTableFlags_None;
		default:
			Issue("ImGui table flag named \"{}\" is invalid.", flag);
			return ImGuiTableFlags_None;
	}
	return ImGuiTableFlags_None;
}

static uint32_t TableFlags(Slice* flags, int count) {
	uint32_t result = 0;
	for (int i = 0; i < count; i++) {
		result |= getTableFlags(flags[i]);
	}
	return result;
}

static uint32_t TableFlags(const std::vector<std::string>& flags) {
	uint32_t result = 0;
	for (const auto& flag : flags) {
		result |= getTableFlags(flag);
	}
	return result;
}

static uint32_t TableRowFlag(String flag) {
	switch (Switch::hash(flag)) {
		case "Headers"_hash: return ImGuiTableRowFlags_Headers;
		case ""_hash: return ImGuiTableRowFlags_None;
		default:
			Issue("ImGui table row flag named \"{}\" is invalid.", flag);
			return ImGuiTableRowFlags_None;
	}
	return ImGuiTableRowFlags_None;
}

static ImGuiTableColumnFlags_ getTableColumnFlags(String flag) {
	switch (Switch::hash(flag)) {
		case "DefaultHide"_hash: return ImGuiTableColumnFlags_DefaultHide;
		case "DefaultSort"_hash: return ImGuiTableColumnFlags_DefaultSort;
		case "WidthStretch"_hash: return ImGuiTableColumnFlags_WidthStretch;
		case "WidthFixed"_hash: return ImGuiTableColumnFlags_WidthFixed;
		case "NoResize"_hash: return ImGuiTableColumnFlags_NoResize;
		case "NoReorder"_hash: return ImGuiTableColumnFlags_NoReorder;
		case "NoHide"_hash: return ImGuiTableColumnFlags_NoHide;
		case "NoClip"_hash: return ImGuiTableColumnFlags_NoClip;
		case "NoSort"_hash: return ImGuiTableColumnFlags_NoSort;
		case "NoSortAscending"_hash: return ImGuiTableColumnFlags_NoSortAscending;
		case "NoSortDescending"_hash: return ImGuiTableColumnFlags_NoSortDescending;
		case "NoHeaderWidth"_hash: return ImGuiTableColumnFlags_NoHeaderWidth;
		case "PreferSortAscending"_hash: return ImGuiTableColumnFlags_PreferSortAscending;
		case "PreferSortDescending"_hash: return ImGuiTableColumnFlags_PreferSortDescending;
		case "IndentEnable"_hash: return ImGuiTableColumnFlags_IndentEnable;
		case "IndentDisable"_hash: return ImGuiTableColumnFlags_IndentDisable;
		case "IsEnabled"_hash: return ImGuiTableColumnFlags_IsEnabled;
		case "IsVisible"_hash: return ImGuiTableColumnFlags_IsVisible;
		case "IsSorted"_hash: return ImGuiTableColumnFlags_IsSorted;
		case "IsHovered"_hash: return ImGuiTableColumnFlags_IsHovered;
		case ""_hash: return ImGuiTableColumnFlags_None;
		default:
			Issue("ImGui table column flag named \"{}\" is invalid.", flag);
			return ImGuiTableColumnFlags_None;
	}
	return ImGuiTableColumnFlags_None;
}

static uint32_t TableColumnFlags(Slice* flags, int count) {
	uint32_t result = 0;
	for (int i = 0; i < count; i++) {
		result |= getTableColumnFlags(flags[i]);
	}
	return result;
}

static uint32_t TableColumnFlags(const std::vector<std::string>& flags) {
	uint32_t result = 0;
	for (const auto& flag : flags) {
		result |= getTableColumnFlags(flag);
	}
	return result;
}

void LoadFontTTFAsync(String ttfFontFile, float fontSize, String glyphRanges, const std::function<void(bool)>& handler) {
	SharedImGui.loadFontTTFAsync(ttfFontFile, fontSize, glyphRanges, handler);
}

bool IsFontLoaded() {
	return SharedImGui.isFontLoaded();
}

void ShowStats(const std::function<void()>& extra) {
	SharedImGui.showStats(extra);
}

void ShowConsole() {
	SharedImGui.showConsole();
}

bool Begin(const char* name, Slice* windowsFlags, int flagCount) {
	return ImGui::Begin(name, nullptr, WindowFlags(windowsFlags, flagCount));
}

bool Begin(const char* name, bool* p_open, Slice* windowsFlags, int flagCount) {
	return ImGui::Begin(name, p_open, WindowFlags(windowsFlags, flagCount));
}

bool BeginChild(const char* str_id, const Vec2& size, bool border, Slice* windowsFlags, int flagCount) {
	return ImGui::BeginChild(str_id, size, border, WindowFlags(windowsFlags, flagCount));
}

bool BeginChild(ImGuiID id, const Vec2& size, bool border, Slice* windowsFlags, int flagCount) {
	return ImGui::BeginChild(id, size, border, WindowFlags(windowsFlags, flagCount));
}

void SetNextWindowPos(const Vec2& pos, String setCond, const Vec2& pivot) {
	ImGui::SetNextWindowPos(pos, SetCondFlag(setCond), pivot);
}

void SetNextWindowPosCenter(String setCond, const Vec2& pivot) {
	ImGui::SetNextWindowPos(Vec2(ImGui::GetIO().DisplaySize) * 0.5f, SetCondFlag(setCond), pivot);
}

void SetNextWindowSize(const Vec2& size, String setCond) {
	ImGui::SetNextWindowSize(size, SetCondFlag(setCond));
}

void SetNextWindowCollapsed(bool collapsed, String setCond) {
	ImGui::SetNextWindowCollapsed(collapsed, SetCondFlag(setCond));
}

void SetWindowPos(const char* name, const Vec2& pos, String setCond) {
	ImGui::SetWindowPos(name, pos, SetCondFlag(setCond));
}

void SetWindowSize(const char* name, const Vec2& size, String setCond) {
	ImGui::SetWindowSize(name, size, SetCondFlag(setCond));
}

void SetWindowCollapsed(const char* name, bool collapsed, String setCond) {
	ImGui::SetWindowCollapsed(name, collapsed, SetCondFlag(setCond));
}

void SetColorEditOptions(String colorEditMode) {
	ImGui::SetColorEditOptions(ColorEditFlag(colorEditMode));
}

bool InputText(const char* label, Buffer* buffer, Slice* inputTextFlags, int flagCount) {
	if (!buffer) return false;
	return ImGui::InputText(label, buffer->get(), buffer->size(), InputTextFlags(inputTextFlags, flagCount));
}

bool InputTextMultiline(const char* label, Buffer* buffer, const Vec2& size, Slice* inputTextFlags, int flagCount) {
	if (!buffer) return false;
	return ImGui::InputTextMultiline(label, buffer->get(), buffer->size(), size, InputTextFlags(inputTextFlags, flagCount));
}

bool TreeNodeEx(const char* label, Slice* treeNodeFlags, int flagCount) {
	return ImGui::TreeNodeEx(label, TreeNodeFlags(treeNodeFlags, flagCount));
}

void SetNextItemOpen(bool is_open, String setCond) {
	ImGui::SetNextItemOpen(is_open, SetCondFlag(setCond));
}

bool CollapsingHeader(const char* label, Slice* treeNodeFlags, int flagCount) {
	return ImGui::CollapsingHeader(label, TreeNodeFlags(treeNodeFlags, flagCount));
}

bool CollapsingHeader(const char* label, bool* p_open, Slice* treeNodeFlags, int flagCount) {
	return ImGui::CollapsingHeader(label, p_open, TreeNodeFlags(treeNodeFlags, flagCount));
}

bool Selectable(const char* label, Slice* selectableFlags, int flagCount) {
	return ImGui::Selectable(label, false, SelectableFlags(selectableFlags, flagCount), Vec2::zero);
}

bool Selectable(const char* label, bool* p_selected, const Vec2& size, Slice* selectableFlags, int flagCount) {
	return ImGui::Selectable(label, p_selected, SelectableFlags(selectableFlags, flagCount), size);
}

bool BeginPopupModal(const char* name, Slice* windowsFlags, int flagCount) {
	return ImGui::BeginPopupModal(name, nullptr, WindowFlags(windowsFlags, flagCount));
}

bool BeginPopupModal(const char* name, bool* p_open, Slice* windowsFlags, int flagCount) {
	return ImGui::BeginPopupModal(name, p_open, WindowFlags(windowsFlags, flagCount));
}

bool BeginChildFrame(ImGuiID id, const Vec2& size, Slice* windowsFlags, int flagCount) {
	return ImGui::BeginChildFrame(id, size, WindowFlags(windowsFlags, flagCount));
}

bool BeginPopupContextItem(const char* name, Slice* popupFlags, int flagCount) {
	return ImGui::BeginPopupContextItem(name, PopupFlags(popupFlags, flagCount));
}

bool BeginPopupContextWindow(const char* name, Slice* popupFlags, int flagCount) {
	return ImGui::BeginPopupContextWindow(name, PopupFlags(popupFlags, flagCount));
}

bool BeginPopupContextVoid(const char* name, Slice* popupFlags, int flagCount) {
	return ImGui::BeginPopupContextVoid(name, PopupFlags(popupFlags, flagCount));
}

void PushStyleColor(String name, Color color) {
	ImGui::PushStyleColor(ColorIndex(name), color.toVec4());
}

void PushStyleVar(String name, const Vec2& val) {
	ImGuiStyleVar_ styleVar = ImGuiStyleVar_WindowPadding;
	switch (Switch::hash(name)) {
		case "WindowPadding"_hash: styleVar = ImGuiStyleVar_WindowPadding; break;
		case "WindowMinSize"_hash: styleVar = ImGuiStyleVar_WindowMinSize; break;
		case "WindowTitleAlign"_hash: styleVar = ImGuiStyleVar_WindowTitleAlign; break;
		case "FramePadding"_hash: styleVar = ImGuiStyleVar_FramePadding; break;
		case "ItemSpacing"_hash: styleVar = ImGuiStyleVar_ItemSpacing; break;
		case "ItemInnerSpacing"_hash: styleVar = ImGuiStyleVar_ItemInnerSpacing; break;
		case "CellPadding"_hash: styleVar = ImGuiStyleVar_CellPadding; break;
		case "ButtonTextAlign"_hash: styleVar = ImGuiStyleVar_ButtonTextAlign; break;
		case "SelectableTextAlign"_hash: styleVar = ImGuiStyleVar_SelectableTextAlign; break;
		default:
			Issue("ImGui style var name \"{}\" is invalid.", name);
			break;
	}
	ImGui::PushStyleVar(styleVar, val);
}

void PushStyleVar(String name, float val) {
	ImGuiStyleVar_ styleVar = ImGuiStyleVar_Alpha;
	switch (Switch::hash(name)) {
		case "Alpha"_hash: styleVar = ImGuiStyleVar_Alpha; break;
		case "WindowRounding"_hash: styleVar = ImGuiStyleVar_WindowRounding; break;
		case "WindowBorderSize"_hash: styleVar = ImGuiStyleVar_WindowBorderSize; break;
		case "ChildRounding"_hash: styleVar = ImGuiStyleVar_ChildRounding; break;
		case "ChildBorderSize"_hash: styleVar = ImGuiStyleVar_ChildBorderSize; break;
		case "PopupRounding"_hash: styleVar = ImGuiStyleVar_PopupRounding; break;
		case "PopupBorderSize"_hash: styleVar = ImGuiStyleVar_PopupBorderSize; break;
		case "FrameRounding"_hash: styleVar = ImGuiStyleVar_FrameRounding; break;
		case "FrameBorderSize"_hash: styleVar = ImGuiStyleVar_FrameBorderSize; break;
		case "IndentSpacing"_hash: styleVar = ImGuiStyleVar_IndentSpacing; break;
		case "ScrollbarSize"_hash: styleVar = ImGuiStyleVar_ScrollbarSize; break;
		case "ScrollbarRounding"_hash: styleVar = ImGuiStyleVar_ScrollbarRounding; break;
		case "GrabMinSize"_hash: styleVar = ImGuiStyleVar_GrabMinSize; break;
		case "GrabRounding"_hash: styleVar = ImGuiStyleVar_GrabRounding; break;
		case "TabRounding"_hash: styleVar = ImGuiStyleVar_TabRounding; break;
		default:
			Issue("ImGui style var name \"{}\" is invalid.", name);
			break;
	}
	ImGui::PushStyleVar(styleVar, val);
}

bool TreeNodeEx(const char* str_id, const char* text, Slice* treeNodeFlags, int flagCount) {
	return ImGui::TreeNodeEx(str_id, TreeNodeFlags(treeNodeFlags, flagCount), "%s", text);
}

void Text(String text) {
	ImGui::TextUnformatted(text.begin(), text.end());
}

void TextColored(Color color, String text) {
	ImGui::PushStyleColor(ImGuiCol_Text, color.toVec4());
	ImGui::TextUnformatted(text.begin(), text.end());
	ImGui::PopStyleColor();
}

void TextDisabled(String text) {
	ImGui::PushStyleColor(ImGuiCol_Text, ImGui::GetStyle().Colors[ImGuiCol_TextDisabled]);
	ImGui::TextUnformatted(text.begin(), text.end());
	ImGui::PopStyleColor();
}

void TextWrapped(String text) {
	ImGui::TextWrappedUnformatted(text.begin(), text.end());
}

void LabelText(const char* label, const char* text) {
	ImGui::LabelText(label, "%s", text);
}

void BulletText(const char* text) {
	ImGui::BulletText("%s", text);
}

bool TreeNode(const char* str_id, const char* text) {
	return ImGui::TreeNode(str_id, "%s", text);
}

void SetTooltip(const char* text) {
	ImGui::SetTooltip("%s", text);
}

bool Combo(const char* label, int* current_item, const char* const* items, int items_count, int height_in_items) {
	--(*current_item); // for lua index start with 1
	bool changed = ImGui::Combo(label, current_item, items, items_count, height_in_items);
	++(*current_item);
	return changed;
}

bool DragFloat(const char* label, float* v, float v_speed, float v_min, float v_max, const char* display_format, Slice* flags, int flagCount) {
	return ImGui::DragFloat(label, v, v_speed, v_min, v_max, display_format, SliderFlags(flags, flagCount));
}

bool DragFloat2(const char* label, float* v1, float* v2, float v_speed, float v_min, float v_max, const char* display_format, Slice* flags, int flagCount) {
	float floats[2] = {*v1, *v2};
	bool changed = ImGui::DragFloat2(label, floats, v_speed, v_min, v_max, display_format, SliderFlags(flags, flagCount));
	*v1 = floats[0];
	*v2 = floats[1];
	return changed;
}

bool DragInt(const char* label, int* v, float v_speed, int v_min, int v_max, const char* display_format, Slice* flags, int flagCount) {
	return ImGui::DragInt(label, v, v_speed, v_min, v_max, display_format, SliderFlags(flags, flagCount));
}

bool DragInt2(const char* label, int* v1, int* v2, float v_speed, int v_min, int v_max, const char* display_format, Slice* flags, int flagCount) {
	int ints[2] = {*v1, *v2};
	bool changed = ImGui::DragInt2(label, ints, v_speed, v_min, v_max, display_format, SliderFlags(flags, flagCount));
	*v1 = ints[0];
	*v2 = ints[1];
	return changed;
}

bool InputFloat(const char* label, float* v, float step, float step_fast, const char* format, Slice* flags, int flagCount) {
	return ImGui::InputFloat(label, v, step, step_fast, format, InputTextFlags(flags, flagCount));
}

bool InputFloat2(const char* label, float* v1, float* v2, const char* format, Slice* flags, int flagCount) {
	float floats[2] = {*v1, *v2};
	bool changed = ImGui::InputFloat2(label, floats, format, InputTextFlags(flags, flagCount));
	*v1 = floats[0];
	*v2 = floats[1];
	return changed;
}

bool InputInt(const char* label, int* v, int step, int step_fast, Slice* flags, int flagCount) {
	return ImGui::InputInt(label, v, step, step_fast, InputTextFlags(flags, flagCount));
}

bool InputInt2(const char* label, int* v1, int* v2, Slice* flags, int flagCount) {
	int ints[2] = {*v1, *v2};
	bool changed = ImGui::InputInt2(label, ints, InputTextFlags(flags, flagCount));
	*v1 = ints[0];
	*v2 = ints[1];
	return changed;
}

bool SliderFloat(const char* label, float* v, float v_min, float v_max, const char* format, Slice* flags, int flagCount) {
	return ImGui::SliderFloat(label, v, v_min, v_max, format, SliderFlags(flags, flagCount));
}

bool SliderFloat2(const char* label, float* v1, float* v2, float v_min, float v_max, const char* display_format, Slice* flags, int flagCount) {
	float floats[2] = {*v1, *v2};
	bool changed = ImGui::SliderFloat2(label, floats, v_min, v_max, display_format, SliderFlags(flags, flagCount));
	*v1 = floats[0];
	*v2 = floats[1];
	return changed;
}

bool SliderInt(const char* label, int* v, int v_min, int v_max, const char* format, Slice* flags, int flagCount) {
	return ImGui::SliderInt(label, v, v_min, v_max, format, SliderFlags(flags, flagCount));
}

bool SliderInt2(const char* label, int* v1, int* v2, int v_min, int v_max, const char* display_format, Slice* flags, int flagCount) {
	int ints[2] = {*v1, *v2};
	bool changed = ImGui::SliderInt2(label, ints, v_min, v_max, display_format, SliderFlags(flags, flagCount));
	*v1 = ints[0];
	*v2 = ints[1];
	return changed;
}

bool DragFloatRange2(const char* label, float* v_current_min, float* v_current_max, float v_speed, float v_min, float v_max, const char* format, const char* format_max, Slice* flags, int flagCount) {
	return ImGui::DragFloatRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max, SliderFlags(flags, flagCount));
}

bool DragIntRange2(const char* label, int* v_current_min, int* v_current_max, float v_speed, int v_min, int v_max, const char* format, const char* format_max, Slice* flags, int flagCount) {
	return ImGui::DragIntRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max, SliderFlags(flags, flagCount));
}

bool VSliderFloat(const char* label, const Vec2& size, float* v, float v_min, float v_max, const char* format, Slice* flags, int flagCount) {
	return ImGui::VSliderFloat(label, size, v, v_min, v_max, format, SliderFlags(flags, flagCount));
}

bool VSliderInt(const char* label, const Vec2& size, int* v, int v_min, int v_max, const char* format, Slice* flags, int flagCount) {
	return ImGui::VSliderInt(label, size, v, v_min, v_max, format, SliderFlags(flags, flagCount));
}

bool ColorEdit3(const char* label, Color3* color3) {
	Vec3 vec3 = color3->toVec3();
	bool changed = ImGui::ColorEdit3(label, vec3);
	*color3 = vec3;
	return changed;
}

bool ColorEdit4(const char* label, Color* color, bool show_alpha) {
	Vec4 vec4 = color->toVec4();
	bool changed = ImGui::ColorEdit4(label, vec4);
	*color = vec4;
	return changed;
}

void Image(String clipStr, const Vec2& size, Color tint_col, Color border_col) {
	Texture2D* tex = nullptr;
	Rect rect;
	std::tie(tex, rect) = SharedClipCache.loadTexture(clipStr);
	union {
		ImTextureID ptr;
		struct {
			bgfx::TextureHandle handle;
		} s;
	} texture;
	texture.s.handle = tex->getHandle();
	Vec2 texSize{s_cast<float>(tex->getWidth()), s_cast<float>(tex->getHeight())};
	Vec2 uv0 = rect.origin / texSize;
	Vec2 uv1 = (rect.origin + Vec2{1, 1} * rect.size) / texSize;
	ImGui::Image(texture.ptr, size, uv0, uv1, tint_col.toVec4(), border_col.toVec4());
}

bool ImageButton(const char* str_id, String clipStr, const Vec2& size, Color bg_col, Color tint_col) {
	Texture2D* tex = nullptr;
	Rect rect;
	std::tie(tex, rect) = SharedClipCache.loadTexture(clipStr);
	union {
		ImTextureID ptr;
		struct {
			bgfx::TextureHandle handle;
		} s;
	} texture;
	texture.s.handle = tex->getHandle();
	Vec2 texSize{s_cast<float>(tex->getWidth()), s_cast<float>(tex->getHeight())};
	Vec2 uv0 = rect.origin / texSize;
	Vec2 uv1 = (rect.origin + Vec2{1, 1} * rect.size) / texSize;
	return ImGui::ImageButton(str_id, texture.ptr, size, uv0, uv1, bg_col.toVec4(), tint_col.toVec4());
}

bool ColorButton(const char* desc_id, Color col, String flags, const Vec2& size) {
	return ImGui::ColorButton(desc_id, col.toVec4(), ColorEditFlag(flags), size);
}

void Columns(int count, bool border) {
	ImGui::Columns(count, nullptr, border);
}

void Columns(int count, bool border, const char* id) {
	ImGui::Columns(count, id, border);
}

bool BeginTable(const char* str_id, int column, const Vec2& outer_size, float inner_width, Slice* flags, int flagCount) {
	return ImGui::BeginTable(str_id, column, TableFlags(flags, flagCount), outer_size, inner_width);
}

bool BeginTable(const std::string& str_id, int column, const Vec2& outer_size, float inner_width, const std::vector<std::string>& tableFlags) {
	return ImGui::BeginTable(str_id.c_str(), column, TableFlags(tableFlags), outer_size, inner_width);
}

void TableNextRow(float min_row_height, String row_flag) {
	ImGui::TableNextRow(TableRowFlag(row_flag), min_row_height);
}

void TableSetupColumn(const char* label, float init_width_or_weight, ImU32 user_id, Slice* flags, int flagCount) {
	ImGui::TableSetupColumn(label, TableColumnFlags(flags, flagCount), init_width_or_weight, user_id);
}

void TableSetupColumn(const std::string& label, float init_width_or_weight, uint32_t user_id, const std::vector<std::string>& tableColumnFlags) {
	ImGui::TableSetupColumn(label.c_str(), TableColumnFlags(tableColumnFlags), init_width_or_weight, user_id);
}

void SetStyleVar(String name, const Vec2& var) {
	ImGuiStyle& style = ImGui::GetStyle();
	switch (Switch::hash(name)) {
		case "WindowPadding"_hash: style.WindowPadding = var; break;
		case "WindowMinSize"_hash: style.WindowMinSize = var; break;
		case "WindowTitleAlign"_hash: style.WindowTitleAlign = var; break;
		case "FramePadding"_hash: style.FramePadding = var; break;
		case "ItemSpacing"_hash: style.ItemSpacing = var; break;
		case "ItemInnerSpacing"_hash: style.ItemInnerSpacing = var; break;
		case "TouchExtraPadding"_hash: style.TouchExtraPadding = var; break;
		case "ButtonTextAlign"_hash: style.ButtonTextAlign = var; break;
		case "DisplayWindowPadding"_hash: style.DisplayWindowPadding = var; break;
		case "DisplaySafeAreaPadding"_hash: style.DisplaySafeAreaPadding = var; break;
		default:
			Issue("ImGui style var name \"{}\" is invalid.", name);
			break;
	}
}

void SetStyleVar(String name, float var) {
	ImGuiStyle& style = ImGui::GetStyle();
	switch (Switch::hash(name)) {
		case "Alpha"_hash: style.Alpha = var; break;
		case "WindowRounding"_hash: style.WindowRounding = var; break;
		case "WindowBorderSize"_hash: style.WindowBorderSize = var; break;
		case "ChildRounding"_hash: style.ChildRounding = var; break;
		case "ChildBorderSize"_hash: style.ChildBorderSize = var; break;
		case "PopupRounding"_hash: style.PopupRounding = var; break;
		case "PopupBorderSize"_hash: style.PopupBorderSize = var; break;
		case "FrameRounding"_hash: style.FrameRounding = var; break;
		case "FrameBorderSize"_hash: style.FrameBorderSize = var; break;
		case "IndentSpacing"_hash: style.IndentSpacing = var; break;
		case "ColumnsMinSpacing"_hash: style.ColumnsMinSpacing = var; break;
		case "ScrollbarSize"_hash: style.ScrollbarSize = var; break;
		case "ScrollbarRounding"_hash: style.ScrollbarRounding = var; break;
		case "GrabMinSize"_hash: style.GrabMinSize = var; break;
		case "GrabRounding"_hash: style.GrabRounding = var; break;
		case "TabRounding"_hash: style.TabRounding = var; break;
		case "TabBorderSize"_hash: style.TabBorderSize = var; break;
		case "CurveTessellationTol"_hash: style.CurveTessellationTol = var; break;
		default:
			Issue("ImGui style var name \"{}\" is invalid.", name);
			break;
	}
}

void SetStyleVar(String name, bool var) {
	ImGuiStyle& style = ImGui::GetStyle();
	switch (Switch::hash(name)) {
		case "AntiAliasedLines"_hash: style.AntiAliasedLines = var; break;
		case "AntiAliasedLinesUseTex"_hash: style.AntiAliasedLinesUseTex = var; break;
		case "AntiAliasedFill"_hash: style.AntiAliasedFill = var; break;
		default:
			Issue("ImGui style var name \"{}\" is invalid.", name);
			break;
	}
}

void SetStyleColor(String name, Color color) {
	uint32_t index = ColorIndex(name);
	ImGuiStyle& style = ImGui::GetStyle();
	style.Colors[index] = color.toVec4();
}

bool Begin(
	const std::string& name,
	const std::vector<std::string>& windowsFlags) {
	return ImGui::Begin(name.c_str(), nullptr, WindowFlags(windowsFlags));
}

bool Begin(
	const std::string& name,
	CallStack* stack, // p_open
	const std::vector<std::string>& windowsFlags) {
	bool p_open = std::get<bool>(stack->pop());
	bool changed = ImGui::Begin(name.c_str(), &p_open, WindowFlags(windowsFlags));
	stack->push(p_open);
	return changed;
}

bool BeginChild(
	const std::string& str_id,
	const Vec2& size,
	bool border,
	const std::vector<std::string>& windowsFlags) {
	return ImGui::BeginChild(str_id.c_str(), size, border, WindowFlags(windowsFlags));
}

bool BeginChild(
	ImGuiID id,
	const Vec2& size,
	bool border,
	const std::vector<std::string>& windowsFlags) {
	return ImGui::BeginChild(id, size, border, WindowFlags(windowsFlags));
}

void SetWindowPos(
	const std::string& name,
	const Vec2& pos,
	String setCond) {
	SetWindowPos(name.c_str(), pos, setCond);
}

void SetWindowSize(
	const std::string& name,
	const Vec2& size,
	String setCond) {
	SetWindowSize(name.c_str(), size, setCond);
}

void SetWindowCollapsed(
	const std::string& name,
	bool collapsed,
	String setCond) {
	SetWindowCollapsed(name.c_str(), collapsed, setCond);
}

bool InputText(
	const std::string& label,
	Buffer* buffer,
	const std::vector<std::string>& inputTextFlags) {
	return ImGui::InputText(label.c_str(), buffer->get(), buffer->size(), InputTextFlags(inputTextFlags));
}

bool InputTextMultiline(
	const std::string& label,
	Buffer* buffer,
	const Vec2& size,
	const std::vector<std::string>& inputTextFlags) {
	return ImGui::InputTextMultiline(label.c_str(), buffer->get(), buffer->size(), size, InputTextFlags(inputTextFlags));
}

bool TreeNodeEx(
	const std::string& label,
	const std::vector<std::string>& treeNodeFlags) {
	return ImGui::TreeNodeEx(label.c_str(), TreeNodeFlags(treeNodeFlags));
}

bool TreeNodeEx(
	const std::string& str_id,
	const std::string& text,
	const std::vector<std::string>& treeNodeFlags) {
	return ImGui::TreeNodeEx(str_id.c_str(), TreeNodeFlags(treeNodeFlags), "%s", text.c_str());
}

bool CollapsingHeader(
	const std::string& label,
	const std::vector<std::string>& treeNodeFlags) {
	return ImGui::CollapsingHeader(label.c_str(), TreeNodeFlags(treeNodeFlags));
}

bool CollapsingHeader(
	const std::string& label,
	CallStack* stack, // p_open
	const std::vector<std::string>& treeNodeFlags) {
	bool p_open = std::get<bool>(stack->pop());
	bool changed = ImGui::CollapsingHeader(label.c_str(), &p_open, TreeNodeFlags(treeNodeFlags));
	stack->push(p_open);
	return changed;
}

bool Selectable(
	const std::string& label,
	const std::vector<std::string>& selectableFlags) {
	return ImGui::Selectable(label.c_str(), SelectableFlags(selectableFlags));
}

bool Selectable(
	const std::string& label,
	CallStack* stack, // p_selected
	const Vec2& size,
	const std::vector<std::string>& selectableFlags) {
	bool p_selected = std::get<bool>(stack->pop());
	bool changed = ImGui::Selectable(label.c_str(), &p_selected, SelectableFlags(selectableFlags), size);
	stack->push(p_selected);
	return changed;
}

bool BeginPopupModal(
	const std::string& name,
	const std::vector<std::string>& windowsFlags) {
	return ImGui::BeginPopupModal(name.c_str(), nullptr, PopupFlags(windowsFlags));
}

bool BeginPopupModal(
	const std::string& name,
	CallStack* stack, // p_open
	const std::vector<std::string>& windowsFlags) {
	bool p_open = std::get<bool>(stack->pop());
	bool changed = ImGui::BeginPopupModal(name.c_str(), &p_open, PopupFlags(windowsFlags));
	stack->push(p_open);
	return changed;
}

bool BeginChildFrame(
	ImGuiID id,
	const Vec2& size,
	const std::vector<std::string>& windowsFlags) {
	return ImGui::BeginChildFrame(id, size, WindowFlags(windowsFlags));
}

bool BeginPopupContextItem(
	const std::string& name,
	const std::vector<std::string>& popupFlags) {
	return ImGui::BeginPopupContextItem(name.c_str(), PopupFlags(popupFlags));
}

bool BeginPopupContextWindow(
	const std::string& name,
	const std::vector<std::string>& popupFlags) {
	return ImGui::BeginPopupContextWindow(name.c_str(), PopupFlags(popupFlags));
}

bool BeginPopupContextVoid(
	const std::string& name,
	const std::vector<std::string>& popupFlags) {
	return ImGui::BeginPopupContextWindow(name.c_str(), PopupFlags(popupFlags));
}

void LabelText(const std::string& label, const std::string& text) {
	LabelText(label.c_str(), text.c_str());
}

void BulletText(const std::string& text) {
	BulletText(text.c_str());
}

bool TreeNode(const std::string& str_id, const std::string& text) {
	return TreeNode(str_id.c_str(), text.c_str());
}

void SetTooltip(const std::string& text) {
	SetTooltip(text.c_str());
}

bool Combo(
	const std::string& label,
	CallStack* stack, // current_item
	const std::vector<std::string>& items,
	int height_in_items) {
	std::vector<const char*> cItems;
	cItems.reserve(items.size());
	for (const auto& item : items) {
		cItems.push_back(item.c_str());
	}
	int current_item = s_cast<int>(std::get<int64_t>(stack->pop()));
	bool changed = Combo(label.c_str(), &current_item, cItems.data(), static_cast<int>(items.size()), height_in_items);
	stack->push(s_cast<int64_t>(current_item));
	return changed;
}

bool DragFloat(
	const std::string& label,
	CallStack* stack, // v
	float v_speed,
	float v_min,
	float v_max,
	const std::string& display_format,
	const std::vector<std::string>& flags) {
	float v = s_cast<float>(std::get<double>(stack->pop()));
	bool changed = ImGui::DragFloat(label.c_str(), &v, v_speed, v_min, v_max, display_format.c_str(), SliderFlags(flags));
	stack->push(v);
	return changed;
}

bool DragFloat2(
	const std::string& label,
	CallStack* stack, // v1, v2
	float v_speed,
	float v_min,
	float v_max,
	const std::string& display_format,
	const std::vector<std::string>& flags) {
	float floats[2] = {
		s_cast<float>(std::get<double>(stack->pop())),
		s_cast<float>(std::get<double>(stack->pop()))};
	bool changed = ImGui::DragFloat2(label.c_str(), floats, v_speed, v_min, v_max, display_format.c_str(), SliderFlags(flags));
	stack->push(floats[0]);
	stack->push(floats[1]);
	return changed;
}

bool DragInt(
	const std::string& label,
	CallStack* stack, // v
	float v_speed,
	int v_min,
	int v_max,
	const std::string& display_format,
	const std::vector<std::string>& flags) {
	int v = s_cast<int>(std::get<int64_t>(stack->pop()));
	bool changed = ImGui::DragInt(label.c_str(), &v, v_speed, v_min, v_max, display_format.c_str(), SliderFlags(flags));
	stack->push(s_cast<int64_t>(v));
	return changed;
}

bool DragInt2(
	const std::string& label,
	CallStack* stack, // v1, v2
	float v_speed,
	int v_min,
	int v_max,
	const std::string& display_format,
	const std::vector<std::string>& flags) {
	int ints[] = {
		s_cast<int>(std::get<int64_t>(stack->pop())),
		s_cast<int>(std::get<int64_t>(stack->pop()))};
	bool changed = ImGui::DragInt2(label.c_str(), ints, v_speed, v_min, v_max, display_format.c_str(), SliderFlags(flags));
	stack->push(s_cast<int64_t>(ints[0]));
	stack->push(s_cast<int64_t>(ints[1]));
	return changed;
}

bool InputFloat(
	const std::string& label,
	CallStack* stack, // v
	float step,
	float step_fast,
	const std::string& format,
	const std::vector<std::string>& flags) {
	float v = s_cast<float>(std::get<double>(stack->pop()));
	bool changed = ImGui::InputFloat(label.c_str(), &v, step, step_fast, format.c_str(), InputTextFlags(flags));
	stack->push(v);
	return changed;
}

bool InputFloat2(
	const std::string& label,
	CallStack* stack, // v1, v2
	const std::string& format,
	const std::vector<std::string>& flags) {
	float floats[2] = {
		s_cast<float>(std::get<double>(stack->pop())),
		s_cast<float>(std::get<double>(stack->pop()))};
	bool changed = ImGui::InputFloat2(label.c_str(), floats, format.c_str(), InputTextFlags(flags));
	stack->push(floats[0]);
	stack->push(floats[1]);
	return changed;
}

bool InputInt(
	const std::string& label,
	CallStack* stack, // v
	int step,
	int step_fast,
	const std::vector<std::string>& flags) {
	int v = s_cast<int>(std::get<int64_t>(stack->pop()));
	bool changed = ImGui::InputInt(label.c_str(), &v, step, step_fast, InputTextFlags(flags));
	stack->push(s_cast<int64_t>(v));
	return changed;
}

bool InputInt2(
	const std::string& label,
	CallStack* stack, // v1, v2
	const std::vector<std::string>& flags) {
	int ints[] = {
		s_cast<int>(std::get<int64_t>(stack->pop())),
		s_cast<int>(std::get<int64_t>(stack->pop()))};
	bool changed = ImGui::InputInt2(label.c_str(), ints, InputTextFlags(flags));
	stack->push(s_cast<int64_t>(ints[0]));
	stack->push(s_cast<int64_t>(ints[1]));
	return changed;
}

bool SliderFloat(
	const std::string& label,
	CallStack* stack, // v
	float v_min,
	float v_max,
	const std::string& format,
	const std::vector<std::string>& flags) {
	float v = s_cast<float>(std::get<double>(stack->pop()));
	bool changed = ImGui::SliderFloat(label.c_str(), &v, v_min, v_max, format.c_str(), SliderFlags(flags));
	stack->push(v);
	return changed;
}

bool SliderFloat2(
	const std::string& label,
	CallStack* stack, // v1, v2
	float v_min,
	float v_max,
	const std::string& display_format,
	const std::vector<std::string>& flags) {
	float floats[2] = {
		s_cast<float>(std::get<double>(stack->pop())),
		s_cast<float>(std::get<double>(stack->pop()))};
	bool changed = ImGui::SliderFloat2(label.c_str(), floats, v_min, v_max, display_format.c_str(), SliderFlags(flags));
	stack->push(floats[0]);
	stack->push(floats[1]);
	return changed;
}

bool SliderInt(
	const std::string& label,
	CallStack* stack, // v
	int v_min,
	int v_max,
	const std::string& format,
	const std::vector<std::string>& flags) {
	int v = s_cast<int>(std::get<int64_t>(stack->pop()));
	bool changed = ImGui::SliderInt(label.c_str(), &v, v_min, v_max, format.c_str(), SliderFlags(flags));
	stack->push(s_cast<int64_t>(v));
	return changed;
}

bool SliderInt2(
	const std::string& label,
	CallStack* stack, // v1, v2
	int v_min,
	int v_max,
	const std::string& display_format,
	const std::vector<std::string>& flags) {
	int ints[] = {
		s_cast<int>(std::get<int64_t>(stack->pop())),
		s_cast<int>(std::get<int64_t>(stack->pop()))};
	bool changed = ImGui::SliderInt2(label.c_str(), ints, v_min, v_max, display_format.c_str(), SliderFlags(flags));
	stack->push(s_cast<int64_t>(ints[0]));
	stack->push(s_cast<int64_t>(ints[1]));
	return changed;
}

bool DragFloatRange2(
	const std::string& label,
	CallStack* stack, // v_current_min, v_current_max
	float v_speed,
	float v_min,
	float v_max,
	const std::string& format,
	const std::string& format_max,
	const std::vector<std::string>& flags) {
	float v_current_min = s_cast<float>(std::get<double>(stack->pop()));
	float v_current_max = s_cast<float>(std::get<double>(stack->pop()));
	bool changed = ImGui::DragFloatRange2(label.c_str(), &v_current_min, &v_current_max, v_speed, v_min, v_max, format.c_str(), format_max.c_str(), SliderFlags(flags));
	stack->push(v_current_min);
	stack->push(v_current_max);
	return changed;
}

bool DragIntRange2(
	const std::string& label,
	CallStack* stack, // v_current_min, v_current_max
	float v_speed,
	int v_min,
	int v_max,
	const std::string& format,
	const std::string& format_max,
	const std::vector<std::string>& flags) {
	int v_current_min = s_cast<int>(std::get<int64_t>(stack->pop()));
	int v_current_max = s_cast<int>(std::get<int64_t>(stack->pop()));
	bool changed = ImGui::DragIntRange2(label.c_str(), &v_current_min, &v_current_max, v_speed, v_min, v_max, format.c_str(), format_max.c_str(), SliderFlags(flags));
	stack->push(s_cast<int64_t>(v_current_min));
	stack->push(s_cast<int64_t>(v_current_max));
	return changed;
}

bool VSliderFloat(
	const std::string& label,
	const Vec2& size,
	CallStack* stack, // v,
	float v_min,
	float v_max,
	const std::string& format,
	const std::vector<std::string>& flags) {
	float v = s_cast<float>(std::get<double>(stack->pop()));
	bool changed = ImGui::VSliderFloat(label.c_str(), size, &v, v_min, v_max, format.c_str(), SliderFlags(flags));
	stack->push(v);
	return changed;
}

bool VSliderInt(
	const std::string& label,
	const Vec2& size,
	CallStack* stack, // v
	int v_min,
	int v_max,
	const std::string& format,
	const std::vector<std::string>& flags) {
	int v = s_cast<int>(std::get<int64_t>(stack->pop()));
	bool changed = ImGui::VSliderInt(label.c_str(), size, &v, v_min, v_max, format.c_str(), SliderFlags(flags));
	stack->push(s_cast<int64_t>(v));
	return changed;
}

bool ColorEdit3(const std::string& label, CallStack* stack) {
	Color3 color3{s_cast<uint32_t>(std::get<int64_t>(stack->pop()))};
	bool changed = ColorEdit3(label.c_str(), &color3);
	stack->push(s_cast<int64_t>(color3.toRGB()));
	return changed;
}

bool ColorEdit4(
	const std::string& label,
	CallStack* stack,
	bool show_alpha) {
	Color color{s_cast<uint32_t>(std::get<int64_t>(stack->pop()))};
	bool changed = ColorEdit4(label.c_str(), &color, show_alpha);
	stack->push(s_cast<int64_t>(color.toARGB()));
	return changed;
}

bool ImageButton(
	const std::string& str_id,
	String clipStr,
	const Vec2& size,
	Color bg_col,
	Color tint_col) {
	return ImageButton(str_id.c_str(), clipStr, size, bg_col, tint_col);
}

bool ColorButton(
	const std::string& desc_id,
	Color col,
	String flags,
	const Vec2& size) {
	return ColorButton(desc_id.c_str(), col, flags, size);
}

void Columns(
	int count,
	bool border,
	const std::string& str_id) {
	Columns(count, border, str_id.c_str());
}

NS_END(ImGui::Binding)
