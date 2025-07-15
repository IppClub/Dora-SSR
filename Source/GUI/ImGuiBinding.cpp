/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "GUI/ImGuiBinding.h"

#include "Cache/ClipCache.h"
#include "Cache/TextureCache.h"
#include "GUI/ImGuiDora.h"

#include "Wasm/WasmRuntime.h"

#include "imgui/imgui_internal.h"

NS_DORA_BEGIN

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

void Buffer::setText(String str) {
	if (_data.empty()) return;
	size_t length = std::min(_data.size() - 1, str.size());
	std::memcpy(_data.data(), str.begin(), length);
	_data[length] = '\0';
}

Slice Buffer::getText() {
	size_t size = 0;
	for (auto ch : _data) {
		if (ch == '\0') {
			break;
		}
		size++;
	}
	return Slice(_data.data(), size);
}

NS_DORA_END

NS_BEGIN(ImGui::Binding)

static ImGuiSliderFlags_ getSliderFlag(String flag) {
	switch (Switch::hash(flag)) {
		case "Logarithmic"_hash:
			return ImGuiSliderFlags_Logarithmic;
		case "NoRoundToFormat"_hash:
			return ImGuiSliderFlags_NoRoundToFormat;
		case "NoInput"_hash:
			return ImGuiSliderFlags_NoInput;
		case "WrapAround"_hash:
			return ImGuiSliderFlags_WrapAround;
		case "ClampOnInput"_hash:
			return ImGuiSliderFlags_ClampOnInput;
		case "ClampZeroRange"_hash:
			return ImGuiSliderFlags_ClampZeroRange;
		case "AlwaysClamp"_hash:
			return ImGuiSliderFlags_AlwaysClamp;
		case ""_hash: return ImGuiSliderFlags_None;
		default:
			Issue("ImGui slider flag named \"{}\" is invalid.", flag.toString());
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
		case "NoNavInputs"_hash: return ImGuiWindowFlags_NoNavInputs;
		case "NoNavFocus"_hash: return ImGuiWindowFlags_NoNavFocus;
		case "UnsavedDocument"_hash: return ImGuiWindowFlags_UnsavedDocument;
		case ""_hash: return ImGuiWindowFlags_(0);
		default:
			Issue("ImGui window flag named \"{}\" is invalid.", style.toString());
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

static ImGuiChildFlags_ getChildFlag(String style) {
	switch (Switch::hash(style)) {
		case "Borders"_hash: return ImGuiChildFlags_Borders;
		case "AlwaysUseWindowPadding"_hash: return ImGuiChildFlags_AlwaysUseWindowPadding;
		case "ResizeX"_hash: return ImGuiChildFlags_ResizeX;
		case "ResizeY"_hash: return ImGuiChildFlags_ResizeY;
		case "AutoResizeX"_hash: return ImGuiChildFlags_AutoResizeX;
		case "AutoResizeY"_hash: return ImGuiChildFlags_AutoResizeY;
		case "AlwaysAutoResize"_hash: return ImGuiChildFlags_AlwaysAutoResize;
		case "FrameStyle"_hash: return ImGuiChildFlags_FrameStyle;
		case ""_hash: return ImGuiChildFlags_None;
		default:
			Issue("ImGui child flag named \"{}\" is invalid.", style.toString());
			break;
	}
	return ImGuiChildFlags_(0);
}

static uint32_t ChildFlags(Slice* flags, int count) {
	uint32_t result = 0;
	for (int i = 0; i < count; i++) {
		result |= getChildFlag(flags[i]);
	}
	return result;
}

static ImGuiInputTextFlags_ getInputTextFlag(String flag) {
	switch (Switch::hash(flag)) {
		case "CharsDecimal"_hash: return ImGuiInputTextFlags_CharsDecimal;
		case "CharsHexadecimal"_hash: return ImGuiInputTextFlags_CharsHexadecimal;
		case "CharsScientific"_hash: return ImGuiInputTextFlags_CharsScientific;
		case "CharsUppercase"_hash: return ImGuiInputTextFlags_CharsUppercase;
		case "CharsNoBlank"_hash: return ImGuiInputTextFlags_CharsNoBlank;
		case "AllowTabInput"_hash: return ImGuiInputTextFlags_AllowTabInput;
		case "EnterReturnsTrue"_hash: return ImGuiInputTextFlags_EnterReturnsTrue;
		case "EscapeClearsAll"_hash: return ImGuiInputTextFlags_EscapeClearsAll;
		case "CtrlEnterForNewLine"_hash: return ImGuiInputTextFlags_CtrlEnterForNewLine;
		case "ReadOnly"_hash: return ImGuiInputTextFlags_ReadOnly;
		case "Password"_hash: return ImGuiInputTextFlags_Password;
		case "AlwaysOverwrite"_hash: return ImGuiInputTextFlags_AlwaysOverwrite;
		case "AutoSelectAll"_hash: return ImGuiInputTextFlags_AutoSelectAll;
		case "ParseEmptyRefVal"_hash: return ImGuiInputTextFlags_ParseEmptyRefVal;
		case "DisplayEmptyRefVal"_hash: return ImGuiInputTextFlags_DisplayEmptyRefVal;
		case "NoHorizontalScroll"_hash: return ImGuiInputTextFlags_NoHorizontalScroll;
		case "NoUndoRedo"_hash: return ImGuiInputTextFlags_NoUndoRedo;
		case "ElideLeft"_hash: return ImGuiInputTextFlags_ElideLeft;
		case "CallbackCompletion"_hash: return ImGuiInputTextFlags_CallbackCompletion;
		case "CallbackHistory"_hash: return ImGuiInputTextFlags_CallbackHistory;
		case "CallbackAlways"_hash: return ImGuiInputTextFlags_CallbackAlways;
		case "CallbackCharFilter"_hash: return ImGuiInputTextFlags_CallbackCharFilter;
		case "CallbackResize"_hash: return ImGuiInputTextFlags_CallbackResize;
		case "CallbackEdit"_hash: return ImGuiInputTextFlags_CallbackEdit;
		case ""_hash: return ImGuiInputTextFlags_None;
		default:
			Issue("ImGui input text flag named \"{}\" is invalid.", flag.toString());
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
		case "FramePadding"_hash: return ImGuiTreeNodeFlags_FramePadding;
		case "SpanAvailWidth"_hash: return ImGuiTreeNodeFlags_SpanAvailWidth;
		case "SpanFullWidth"_hash: return ImGuiTreeNodeFlags_SpanFullWidth;
		case "SpanLabelWidth"_hash: return ImGuiTreeNodeFlags_SpanLabelWidth;
		case "SpanAllColumns"_hash: return ImGuiTreeNodeFlags_SpanAllColumns;
		case "LabelSpanAllColumns"_hash: return ImGuiTreeNodeFlags_LabelSpanAllColumns;
		case "NavLeftJumpsToParent"_hash: return ImGuiTreeNodeFlags_NavLeftJumpsToParent;
		case "CollapsingHeader"_hash: return ImGuiTreeNodeFlags_CollapsingHeader;
		case ""_hash: return ImGuiTreeNodeFlags_(0);
		default:
			Issue("ImGui tree node flag named \"{}\" is invalid.", flag.toString());
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

static ImGuiSelectableFlags_ getSelectableFlag(String flag) {
	switch (Switch::hash(flag)) {
		case "NoAutoClosePopups"_hash: return ImGuiSelectableFlags_NoAutoClosePopups;
		case "SpanAllColumns"_hash: return ImGuiSelectableFlags_SpanAllColumns;
		case "AllowDoubleClick"_hash: return ImGuiSelectableFlags_AllowDoubleClick;
		case "Disabled"_hash: return ImGuiSelectableFlags_Disabled;
		case "AllowOverlap"_hash: return ImGuiSelectableFlags_AllowOverlap;
		case ""_hash: return ImGuiSelectableFlags_None;
		default:
			Issue("ImGui selectable flag named \"{}\" is invalid.", flag.toString());
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
		case "TabSelected"_hash: return ImGuiCol_TabSelected;
		case "TabDimmed"_hash: return ImGuiCol_TabDimmed;
		case "TabDimmedSelected"_hash: return ImGuiCol_TabDimmedSelected;
		case "TabDimmedSelectedOverline"_hash: return ImGuiCol_TabDimmedSelectedOverline;
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
		case "NavCursor"_hash: return ImGuiCol_NavCursor;
		case "NavWindowingHighlight"_hash: return ImGuiCol_NavWindowingHighlight;
		case "NavWindowingDimBg"_hash: return ImGuiCol_NavWindowingDimBg;
		case "ModalWindowDimBg"_hash: return ImGuiCol_ModalWindowDimBg;
		default:
			Issue("ImGui color index named \"{}\" is invalid.", col.toString());
			return ImGuiCol_(0);
	}
}

static uint32_t getColorEditFlag(String mode) {
	switch (Switch::hash(mode)) {
		case "NoAlpha"_hash: return ImGuiColorEditFlags_NoAlpha;
		case "NoPicker"_hash: return ImGuiColorEditFlags_NoPicker;
		case "NoOptions"_hash: return ImGuiColorEditFlags_NoOptions;
		case "NoSmallPreview"_hash: return ImGuiColorEditFlags_NoSmallPreview;
		case "NoInputs"_hash: return ImGuiColorEditFlags_NoInputs;
		case "NoTooltip"_hash: return ImGuiColorEditFlags_NoTooltip;
		case "NoLabel"_hash: return ImGuiColorEditFlags_NoLabel;
		case "NoSidePreview"_hash: return ImGuiColorEditFlags_NoSidePreview;
		case "NoDragDrop"_hash: return ImGuiColorEditFlags_NoDragDrop;
		case "NoBorder"_hash: return ImGuiColorEditFlags_NoBorder;
		case "AlphaOpaque"_hash: return ImGuiColorEditFlags_AlphaOpaque;
		case "AlphaNoBg"_hash: return ImGuiColorEditFlags_AlphaNoBg;
		case "AlphaBar"_hash: return ImGuiColorEditFlags_AlphaBar;
		case "AlphaPreviewHalf"_hash: return ImGuiColorEditFlags_AlphaPreviewHalf;
		case "HDR"_hash: return ImGuiColorEditFlags_HDR;
		case "DisplayRGB"_hash: return ImGuiColorEditFlags_DisplayRGB;
		case "DisplayHSV"_hash: return ImGuiColorEditFlags_DisplayHSV;
		case "DisplayHex"_hash: return ImGuiColorEditFlags_DisplayHex;
		case "Uint8"_hash: return ImGuiColorEditFlags_Uint8;
		case "Float"_hash: return ImGuiColorEditFlags_Float;
		case "PickerHueBar"_hash: return ImGuiColorEditFlags_PickerHueBar;
		case "PickerHueWheel"_hash: return ImGuiColorEditFlags_PickerHueWheel;
		case "InputRGB"_hash: return ImGuiColorEditFlags_InputRGB;
		case "InputHSV"_hash: return ImGuiColorEditFlags_InputHSV;
		case ""_hash: return ImGuiColorEditFlags_None;
		default:
			Issue("ImGui color edit flag named \"{}\" is invalid.", mode.toString());
			return ImGuiColorEditFlags_None;
	}
}

static uint32_t ColorEditFlags(Slice* flags, int count) {
	uint32_t result = 0;
	for (int i = 0; i < count; i++) {
		result |= getColorEditFlag(flags[i]);
	}
	return result;
}

static uint32_t SetCondFlag(String cond) {
	switch (Switch::hash(cond)) {
		case "Always"_hash: return ImGuiCond_Always;
		case "Once"_hash: return ImGuiCond_Once;
		case "FirstUseEver"_hash: return ImGuiCond_FirstUseEver;
		case "Appearing"_hash: return ImGuiCond_Appearing;
		case ""_hash: return ImGuiCond_(0);
		default:
			Issue("ImGui set cond named \"{}\" is invalid.", cond.toString());
			return ImGuiCond_(0);
	}
}

static ImGuiPopupFlags getPopupFlag(String flag) {
	switch (Switch::hash(flag)) {
		case "MouseButtonLeft"_hash: return ImGuiPopupFlags_MouseButtonLeft;
		case "MouseButtonRight"_hash: return ImGuiPopupFlags_MouseButtonRight;
		case "MouseButtonMiddle"_hash: return ImGuiPopupFlags_MouseButtonMiddle;
		case "NoReopen"_hash: return ImGuiPopupFlags_NoReopen;
		case "NoOpenOverExistingPopup"_hash: return ImGuiPopupFlags_NoOpenOverExistingPopup;
		case "NoOpenOverItems"_hash: return ImGuiPopupFlags_NoOpenOverItems;
		case "AnyPopupId"_hash: return ImGuiPopupFlags_AnyPopupId;
		case "AnyPopupLevel"_hash: return ImGuiPopupFlags_AnyPopupLevel;
		case "AnyPopup"_hash: return ImGuiPopupFlags_AnyPopup;
		case ""_hash: return ImGuiPopupFlags_None;
		default:
			Issue("ImGui popup flag named \"{}\" is invalid.", flag.toString());
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
		case "SortTristate"_hash: return ImGuiTableFlags_SortTristate;
		case "HighlightHoveredColumn"_hash: return ImGuiTableFlags_HighlightHoveredColumn;
		case ""_hash: return ImGuiTableFlags_None;
		default:
			Issue("ImGui table flag named \"{}\" is invalid.", flag.toString());
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

static uint32_t TableRowFlag(String flag) {
	switch (Switch::hash(flag)) {
		case "Headers"_hash: return ImGuiTableRowFlags_Headers;
		case ""_hash: return ImGuiTableRowFlags_None;
		default:
			Issue("ImGui table row flag named \"{}\" is invalid.", flag.toString());
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
			Issue("ImGui table column flag named \"{}\" is invalid.", flag.toString());
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

void SetDefaultFont(String ttfFontFile, float fontSize) {
	SharedImGui.setDefaultFont(ttfFontFile, fontSize);
}

void ShowStats(bool* pOpen, Slice* flags, int count, const std::function<void()>& extra) {
	SharedImGui.showStats(pOpen, WindowFlags(flags, count), extra);
}

void ShowStats(const std::function<void()>& extra) {
	SharedImGui.showStats(nullptr, ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_AlwaysAutoResize, extra);
}

void ShowConsole(bool initOnly) {
	SharedImGui.showConsole(initOnly);
}

bool Begin(const char* name, Slice* windowFlags, int flagCount) {
	return ImGui::Begin(name, nullptr, WindowFlags(windowFlags, flagCount));
}

bool Begin(const char* name, bool* p_open, Slice* windowFlags, int flagCount) {
	return ImGui::Begin(name, p_open, WindowFlags(windowFlags, flagCount));
}

bool BeginChild(
	const char* str_id,
	const Vec2& size,
	Slice* childFlags,
	int childFlagCount,
	Slice* windowFlags,
	int windowFlagCount) {
	return ImGui::BeginChild(str_id, size, ChildFlags(childFlags, childFlagCount), WindowFlags(windowFlags, windowFlagCount));
}

bool BeginChild(
	ImGuiID id,
	const Vec2& size,
	Slice* childFlags,
	int childFlagCount,
	Slice* windowFlags,
	int windowFlagCount) {
	return ImGui::BeginChild(id, size, ChildFlags(childFlags, childFlagCount), WindowFlags(windowFlags, windowFlagCount));
}

void SetNextWindowPos(const Vec2& pos, String setCond, const Vec2& pivot) {
	ImGui::SetNextWindowPos(pos, SetCondFlag(setCond), pivot);
}

void SetNextWindowPosCenter(String setCond, const Vec2& pivot) {
	ImGui::SetNextWindowPos(Vec2(ImGui::GetIO().DisplaySize) * 0.5f, SetCondFlag(setCond), pivot);
}

void SetNextWindowPosCenter(uint32_t setCond, const Vec2& pivot) {
	ImGui::SetNextWindowPos(Vec2(ImGui::GetIO().DisplaySize) * 0.5f, setCond, pivot);
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

void SetColorEditOptions(Slice* colorEditFlags, int colorEditFlagCount) {
	ImGui::SetColorEditOptions(ColorEditFlags(colorEditFlags, colorEditFlagCount));
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

bool BeginPopupModal(const char* name, Slice* windowFlags, int flagCount) {
	return ImGui::BeginPopupModal(name, nullptr, WindowFlags(windowFlags, flagCount));
}

bool BeginPopupModal(const char* name, bool* p_open, Slice* windowFlags, int flagCount) {
	return ImGui::BeginPopupModal(name, p_open, WindowFlags(windowFlags, flagCount));
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

void PushStyleColor(uint32_t name, Color color) {
	ImGui::PushStyleColor(name, color.toVec4());
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
		case "SeparatorTextAlign"_hash: styleVar = ImGuiStyleVar_SeparatorTextAlign; break;
		case "SeparatorTextPadding"_hash: styleVar = ImGuiStyleVar_SeparatorTextPadding; break;
		default:
			Issue("ImGui style var name \"{}\" is invalid.", name.toString());
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
		case "SeparatorTextBorderSize"_hash: styleVar = ImGuiStyleVar_SeparatorTextBorderSize; break;
		default:
			Issue("ImGui style var name \"{}\" is invalid.", name.toString());
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

bool ColorEdit3(const char* label, Color3* color3, Slice* colorEditFlags, int colorEditFlagCount) {
	Vec3 vec3 = color3->toVec3();
	bool changed = ImGui::ColorEdit3(label, &vec3.x, ColorEditFlags(colorEditFlags, colorEditFlagCount));
	*color3 = vec3;
	return changed;
}

bool ColorEdit4(const char* label, Color* color, Slice* colorEditFlags, int colorEditFlagCount) {
	Vec4 vec4 = color->toVec4();
	bool changed = ImGui::ColorEdit4(label, &vec4.x, ColorEditFlags(colorEditFlags, colorEditFlagCount));
	*color = vec4;
	return changed;
}

void Image(String clipStr, const Vec2& size, Color bg_col, Color tint_col) {
	Texture2D* tex = nullptr;
	Rect rect;
	std::tie(tex, rect) = SharedClipCache.loadTexture(clipStr);
	AssertUnless(tex, "failed to get resource for ImGui.Image");
	Vec2 texSize{s_cast<float>(tex->getWidth()), s_cast<float>(tex->getHeight())};
	Vec2 uv0 = rect.origin / texSize;
	Vec2 uv1 = (rect.origin + Vec2{1, 1} * rect.size) / texSize;
	ImGui::ImageWithBg(r_cast<ImTextureID>(tex), size, uv0, uv1, bg_col.toVec4(), tint_col.toVec4());
}

bool ImageButton(const char* str_id, String clipStr, const Vec2& size, Color bg_col, Color tint_col) {
	Texture2D* tex = nullptr;
	Rect rect;
	std::tie(tex, rect) = SharedClipCache.loadTexture(clipStr);
	AssertUnless(tex, "failed to get resource for ImGui.ImageButton");
	Vec2 texSize{s_cast<float>(tex->getWidth()), s_cast<float>(tex->getHeight())};
	Vec2 uv0 = rect.origin / texSize;
	Vec2 uv1 = (rect.origin + Vec2{1, 1} * rect.size) / texSize;
	return ImGui::ImageButton(str_id, r_cast<ImTextureID>(tex), size, uv0, uv1, bg_col.toVec4(), tint_col.toVec4());
}

bool ColorButton(const char* desc_id, Color col, Slice* flags, int flagCount, const Vec2& size) {
	return ImGui::ColorButton(desc_id, col.toVec4(), ColorEditFlags(flags, flagCount), size);
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

bool BeginTable(const std::string& str_id, int column, const Vec2& outer_size, float inner_width, uint32_t tableFlags) {
	return ImGui::BeginTable(str_id.c_str(), column, tableFlags, outer_size, inner_width);
}

void TableNextRow(float min_row_height, String row_flag) {
	ImGui::TableNextRow(TableRowFlag(row_flag), min_row_height);
}

void TableSetupColumn(const char* label, float init_width_or_weight, ImU32 user_id, Slice* flags, int flagCount) {
	ImGui::TableSetupColumn(label, TableColumnFlags(flags, flagCount), init_width_or_weight, user_id);
}

void TableSetupColumn(const std::string& label, float init_width_or_weight, uint32_t user_id, uint32_t tableColumnFlags) {
	ImGui::TableSetupColumn(label.c_str(), tableColumnFlags, init_width_or_weight, user_id);
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
			Issue("ImGui style var name \"{}\" is invalid.", name.toString());
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
			Issue("ImGui style var name \"{}\" is invalid.", name.toString());
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
			Issue("ImGui style var name \"{}\" is invalid.", name.toString());
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
	uint32_t windowFlags) {
	return ImGui::Begin(name.c_str(), nullptr, windowFlags);
}

bool Begin(
	const std::string& name,
	CallStack* stack, // p_open
	uint32_t windowFlags) {
	bool p_open = std::get<bool>(stack->pop());
	bool changed = ImGui::Begin(name.c_str(), &p_open, windowFlags);
	stack->push(p_open);
	return changed;
}

bool BeginChild(
	const std::string& str_id,
	const Vec2& size,
	uint32_t childFlags,
	uint32_t windowFlags) {
	return ImGui::BeginChild(str_id.c_str(), size, childFlags, windowFlags);
}

bool BeginChild(
	ImGuiID id,
	const Vec2& size,
	uint32_t childFlags,
	uint32_t windowFlags) {
	return ImGui::BeginChild(id, size, childFlags, windowFlags);
}

void SetWindowPos(
	const std::string& name,
	const Vec2& pos,
	String setCond) {
	SetWindowPos(name.c_str(), pos, setCond);
}

void SetWindowPos(
	const std::string& name,
	const Vec2& pos,
	uint32_t setCond) {
	ImGui::SetWindowPos(name.c_str(), pos, setCond);
}

void SetWindowSize(
	const std::string& name,
	const Vec2& size,
	String setCond) {
	SetWindowSize(name.c_str(), size, setCond);
}

void SetWindowSize(
	const std::string& name,
	const Vec2& size,
	uint32_t setCond) {
	ImGui::SetWindowSize(name.c_str(), size, setCond);
}

void SetWindowCollapsed(
	const std::string& name,
	bool collapsed,
	String setCond) {
	SetWindowCollapsed(name.c_str(), collapsed, setCond);
}

void SetWindowCollapsed(
	const std::string& name,
	bool collapsed,
	uint32_t setCond) {
	ImGui::SetWindowCollapsed(name.c_str(), collapsed, setCond);
}

bool InputText(
	const std::string& label,
	Buffer* buffer,
	uint32_t inputTextFlags) {
	return ImGui::InputText(label.c_str(), buffer->get(), buffer->size(), inputTextFlags);
}

bool InputTextMultiline(
	const std::string& label,
	Buffer* buffer,
	const Vec2& size,
	uint32_t inputTextFlags) {
	return ImGui::InputTextMultiline(label.c_str(), buffer->get(), buffer->size(), size, inputTextFlags);
}

bool TreeNodeEx(
	const std::string& label,
	uint32_t treeNodeFlags) {
	return ImGui::TreeNodeEx(label.c_str(), treeNodeFlags);
}

bool TreeNodeEx(
	const std::string& str_id,
	const std::string& text,
	uint32_t treeNodeFlags) {
	return ImGui::TreeNodeEx(str_id.c_str(), treeNodeFlags, "%s", text.c_str());
}

bool CollapsingHeader(
	const std::string& label,
	uint32_t treeNodeFlags) {
	return ImGui::CollapsingHeader(label.c_str(), treeNodeFlags);
}

bool CollapsingHeader(
	const std::string& label,
	CallStack* stack, // p_open
	uint32_t treeNodeFlags) {
	bool p_open = std::get<bool>(stack->pop());
	bool changed = ImGui::CollapsingHeader(label.c_str(), &p_open, treeNodeFlags);
	stack->push(p_open);
	return changed;
}

bool Selectable(
	const std::string& label,
	uint32_t selectableFlags) {
	return ImGui::Selectable(label.c_str(), selectableFlags);
}

bool Selectable(
	const std::string& label,
	CallStack* stack, // p_selected
	const Vec2& size,
	uint32_t selectableFlags) {
	bool p_selected = std::get<bool>(stack->pop());
	bool changed = ImGui::Selectable(label.c_str(), &p_selected, selectableFlags, size);
	stack->push(p_selected);
	return changed;
}

bool BeginPopupModal(
	const std::string& name,
	uint32_t windowFlags) {
	return ImGui::BeginPopupModal(name.c_str(), nullptr, windowFlags);
}

bool BeginPopupModal(
	const std::string& name,
	CallStack* stack, // p_open
	uint32_t windowFlags) {
	bool p_open = std::get<bool>(stack->pop());
	bool changed = ImGui::BeginPopupModal(name.c_str(), &p_open, windowFlags);
	stack->push(p_open);
	return changed;
}

bool BeginPopupContextItem(
	const std::string& name,
	uint32_t popupFlags) {
	return ImGui::BeginPopupContextItem(name.c_str(), popupFlags);
}

bool BeginPopupContextWindow(
	const std::string& name,
	uint32_t popupFlags) {
	return ImGui::BeginPopupContextWindow(name.c_str(), popupFlags);
}

bool BeginPopupContextVoid(
	const std::string& name,
	uint32_t popupFlags) {
	return ImGui::BeginPopupContextWindow(name.c_str(), popupFlags);
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
	bool changed = ImGui::Combo(label.c_str(), &current_item, cItems.data(), static_cast<int>(items.size()), height_in_items);
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
	uint32_t sliderFlags) {
	float v = s_cast<float>(std::get<double>(stack->pop()));
	bool changed = ImGui::DragFloat(label.c_str(), &v, v_speed, v_min, v_max, display_format.c_str(), sliderFlags);
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
	uint32_t sliderFlags) {
	float floats[2] = {
		s_cast<float>(std::get<double>(stack->pop())),
		s_cast<float>(std::get<double>(stack->pop()))};
	bool changed = ImGui::DragFloat2(label.c_str(), floats, v_speed, v_min, v_max, display_format.c_str(), sliderFlags);
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
	uint32_t sliderFlags) {
	int v = s_cast<int>(std::get<int64_t>(stack->pop()));
	bool changed = ImGui::DragInt(label.c_str(), &v, v_speed, v_min, v_max, display_format.c_str(), sliderFlags);
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
	uint32_t sliderFlags) {
	int ints[] = {
		s_cast<int>(std::get<int64_t>(stack->pop())),
		s_cast<int>(std::get<int64_t>(stack->pop()))};
	bool changed = ImGui::DragInt2(label.c_str(), ints, v_speed, v_min, v_max, display_format.c_str(), sliderFlags);
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
	uint32_t inputTextFlags) {
	float v = s_cast<float>(std::get<double>(stack->pop()));
	bool changed = ImGui::InputFloat(label.c_str(), &v, step, step_fast, format.c_str(), inputTextFlags);
	stack->push(v);
	return changed;
}

bool InputFloat2(
	const std::string& label,
	CallStack* stack, // v1, v2
	const std::string& format,
	uint32_t inputTextFlags) {
	float floats[2] = {
		s_cast<float>(std::get<double>(stack->pop())),
		s_cast<float>(std::get<double>(stack->pop()))};
	bool changed = ImGui::InputFloat2(label.c_str(), floats, format.c_str(), inputTextFlags);
	stack->push(floats[0]);
	stack->push(floats[1]);
	return changed;
}

bool InputInt(
	const std::string& label,
	CallStack* stack, // v
	int step,
	int step_fast,
	uint32_t inputTextFlags) {
	int v = s_cast<int>(std::get<int64_t>(stack->pop()));
	bool changed = ImGui::InputInt(label.c_str(), &v, step, step_fast, inputTextFlags);
	stack->push(s_cast<int64_t>(v));
	return changed;
}

bool InputInt2(
	const std::string& label,
	CallStack* stack, // v1, v2
	uint32_t inputTextFlags) {
	int ints[] = {
		s_cast<int>(std::get<int64_t>(stack->pop())),
		s_cast<int>(std::get<int64_t>(stack->pop()))};
	bool changed = ImGui::InputInt2(label.c_str(), ints, inputTextFlags);
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
	uint32_t sliderFlags) {
	float v = s_cast<float>(std::get<double>(stack->pop()));
	bool changed = ImGui::SliderFloat(label.c_str(), &v, v_min, v_max, format.c_str(), sliderFlags);
	stack->push(v);
	return changed;
}

bool SliderFloat2(
	const std::string& label,
	CallStack* stack, // v1, v2
	float v_min,
	float v_max,
	const std::string& display_format,
	uint32_t sliderFlags) {
	float floats[2] = {
		s_cast<float>(std::get<double>(stack->pop())),
		s_cast<float>(std::get<double>(stack->pop()))};
	bool changed = ImGui::SliderFloat2(label.c_str(), floats, v_min, v_max, display_format.c_str(), sliderFlags);
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
	uint32_t sliderFlags) {
	int v = s_cast<int>(std::get<int64_t>(stack->pop()));
	bool changed = ImGui::SliderInt(label.c_str(), &v, v_min, v_max, format.c_str(), sliderFlags);
	stack->push(s_cast<int64_t>(v));
	return changed;
}

bool SliderInt2(
	const std::string& label,
	CallStack* stack, // v1, v2
	int v_min,
	int v_max,
	const std::string& display_format,
	uint32_t sliderFlags) {
	int ints[] = {
		s_cast<int>(std::get<int64_t>(stack->pop())),
		s_cast<int>(std::get<int64_t>(stack->pop()))};
	bool changed = ImGui::SliderInt2(label.c_str(), ints, v_min, v_max, display_format.c_str(), sliderFlags);
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
	uint32_t sliderFlags) {
	float v_current_min = s_cast<float>(std::get<double>(stack->pop()));
	float v_current_max = s_cast<float>(std::get<double>(stack->pop()));
	bool changed = ImGui::DragFloatRange2(label.c_str(), &v_current_min, &v_current_max, v_speed, v_min, v_max, format.c_str(), format_max.c_str(), sliderFlags);
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
	uint32_t sliderFlags) {
	int v_current_min = s_cast<int>(std::get<int64_t>(stack->pop()));
	int v_current_max = s_cast<int>(std::get<int64_t>(stack->pop()));
	bool changed = ImGui::DragIntRange2(label.c_str(), &v_current_min, &v_current_max, v_speed, v_min, v_max, format.c_str(), format_max.c_str(), sliderFlags);
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
	uint32_t sliderFlags) {
	float v = s_cast<float>(std::get<double>(stack->pop()));
	bool changed = ImGui::VSliderFloat(label.c_str(), size, &v, v_min, v_max, format.c_str(), sliderFlags);
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
	uint32_t sliderFlags) {
	int v = s_cast<int>(std::get<int64_t>(stack->pop()));
	bool changed = ImGui::VSliderInt(label.c_str(), size, &v, v_min, v_max, format.c_str(), sliderFlags);
	stack->push(s_cast<int64_t>(v));
	return changed;
}

bool ColorEdit3(
	const std::string& label,
	CallStack* stack,
	uint32_t colorEditFlags) {
	auto color3 = Color3{s_cast<uint32_t>(std::get<int64_t>(stack->pop()))}.toVec3();
	bool changed = ImGui::ColorEdit3(label.c_str(), &color3.x, colorEditFlags);
	stack->push(s_cast<int64_t>(Color3(color3).toRGB()));
	return changed;
}

bool ColorEdit4(
	const std::string& label,
	CallStack* stack,
	uint32_t colorEditFlags) {
	auto color = Color{s_cast<uint32_t>(std::get<int64_t>(stack->pop()))}.toVec4();
	bool changed = ImGui::ColorEdit4(label.c_str(), &color.x, colorEditFlags);
	stack->push(s_cast<int64_t>(Color(color).toARGB()));
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
	uint32_t colorEditFlags,
	const Vec2& size) {
	return ImGui::ColorButton(desc_id.c_str(), col.toVec4(), colorEditFlags, size);
}

void Columns(
	int count,
	bool border,
	const std::string& str_id) {
	Columns(count, border, str_id.c_str());
}

void ScrollWhenDraggingOnVoid() {
	ImGuiButtonFlags button_flags = ImGuiButtonFlags_MouseButtonLeft;
	ImGuiContext& g = *ImGui::GetCurrentContext();
	ImGuiWindow* window = g.CurrentWindow;
	bool hovered = false;
	static bool held = false;
	ImGuiID id = window->GetID("##scrolldraggingoverlay");
	ImGui::KeepAliveID(id);
	bool lastHeld = held;
	if (g.HoveredId == 0) {
		ImGui::ButtonBehavior(window->Rect(), id, &hovered, &held, button_flags);
	}
	if (lastHeld != held) {
		return;
	}
	if (held) {
		ImVec2 mouse_delta = ImGui::GetIO().MouseDelta;
		ImVec2 delta(-mouse_delta.x, -mouse_delta.y);
		if (delta.x != 0.0f) {
			ImGui::SetScrollX(window, window->Scroll.x + delta.x);
		}
		if (delta.y != 0.0f) {
			ImGui::SetScrollY(window, window->Scroll.y + delta.y);
		}
	}
}

bool Checkbox(String label, CallStack* stack) {
	bool v = std::get<bool>(stack->pop());
	bool changed = ImGui::Checkbox(label.c_str(), &v);
	stack->push(v);
	return changed;
}

bool RadioButton(String label, CallStack* stack, int v_button) {
	int v = s_cast<int>(std::get<int64_t>(stack->pop()));
	bool changed = ImGui::RadioButton(label.c_str(), &v, v_button);
	stack->push(s_cast<int64_t>(v));
	return changed;
}

void PlotLines(String label, const std::vector<float>& values, int values_offset, String overlay_text, float scale_min, float scale_max, Vec2 graph_size) {
	ImGui::PlotLines(label.c_str(), values.data(), s_cast<int>(values.size()), values_offset, overlay_text.c_str(), scale_min, scale_max, graph_size);
}

void PlotHistogram(String label, const std::vector<float>& values, int values_offset, String overlay_text, float scale_min, float scale_max, Vec2 graph_size) {
	ImGui::PlotHistogram(label.c_str(), values.data(), s_cast<int>(values.size()), values_offset, overlay_text.c_str(), scale_min, scale_max, graph_size);
}

bool ListBox(String label, CallStack* stack, const std::vector<std::string>& items, int height_in_items) {
	std::vector<const char*> cItems;
	cItems.reserve(items.size());
	for (const auto& item : items) {
		cItems.push_back(item.c_str());
	}
	int current_item = s_cast<int>(std::get<int64_t>(stack->pop()));
	bool changed = ImGui::ListBox(label.c_str(), &current_item, cItems.data(), s_cast<int>(cItems.size()), height_in_items);
	stack->push(s_cast<int64_t>(current_item));
	return changed;
}

bool SliderAngle(String label, CallStack* stack, float v_degrees_min, float v_degrees_max) {
	float v_rad = s_cast<float>(std::get<double>(stack->pop()));
	bool changed = ImGui::SliderAngle(label.c_str(), &v_rad, v_degrees_min, v_degrees_max);
	stack->push(s_cast<double>(v_rad));
	return changed;
}

static ImGuiItemFlags_ getItemFlag(String flag) {
	switch (Switch::hash(flag)) {
		case ""_hash: return ImGuiItemFlags_None;
		case "NoTabStop"_hash: return ImGuiItemFlags_NoTabStop;
		case "NoNav"_hash: return ImGuiItemFlags_NoNav;
		case "NoNavDefaultFocus"_hash: return ImGuiItemFlags_NoNavDefaultFocus;
		case "ButtonRepeat"_hash: return ImGuiItemFlags_ButtonRepeat;
		case "AutoClosePopups"_hash: return ImGuiItemFlags_AutoClosePopups;
		case "AllowDuplicateId"_hash: return ImGuiItemFlags_AllowDuplicateId;
		default:
			Issue("ImGui item flag named \"{}\" is invalid.", flag.toString());
			return ImGuiItemFlags_None;
	}
}

void PushItemFlag(Slice* options, int optionCount, bool enabled) {
	uint32_t flags = 0;
	for (int i = 0; i < optionCount; i++) {
		flags |= getItemFlag(options[i]);
	}
	ImGui::PushItemFlag(s_cast<int>(flags), enabled);
}

static ImGuiTabBarFlags_ getTabBarFlag(String flag) {
	switch (Switch::hash(flag)) {
		case ""_hash: return ImGuiTabBarFlags_None;
		case "Reorderable"_hash: return ImGuiTabBarFlags_Reorderable;
		case "AutoSelectNewTabs"_hash: return ImGuiTabBarFlags_AutoSelectNewTabs;
		case "TabListPopupButton"_hash: return ImGuiTabBarFlags_TabListPopupButton;
		case "NoCloseWithMiddleMouseButton"_hash: return ImGuiTabBarFlags_NoCloseWithMiddleMouseButton;
		case "NoTabListScrollingButtons"_hash: return ImGuiTabBarFlags_NoTabListScrollingButtons;
		case "NoTooltip"_hash: return ImGuiTabBarFlags_NoTooltip;
		case "DrawSelectedOverline"_hash: return ImGuiTabBarFlags_DrawSelectedOverline;
		case "FittingPolicyResizeDown"_hash: return ImGuiTabBarFlags_FittingPolicyResizeDown;
		case "FittingPolicyScroll"_hash: return ImGuiTabBarFlags_FittingPolicyScroll;
		default:
			Issue("ImGui tab bar flag named \"{}\" is invalid.", flag.toString());
			return ImGuiTabBarFlags_None;
	}
}

static uint32_t TabBarFlags(Slice* flags, int flagCount) {
	uint32_t result = 0;
	for (int i = 0; i < flagCount; i++) {
		result |= getTabBarFlag(flags[i]);
	}
	return result;
}

static ImGuiTabItemFlags_ getTabItemFlag(String flag) {
	switch (Switch::hash(flag)) {
		case ""_hash: return ImGuiTabItemFlags_None;
		case "UnsavedDocument"_hash: return ImGuiTabItemFlags_UnsavedDocument;
		case "SetSelected"_hash: return ImGuiTabItemFlags_SetSelected;
		case "NoCloseWithMiddleMouseButton"_hash: return ImGuiTabItemFlags_NoCloseWithMiddleMouseButton;
		case "NoPushId"_hash: return ImGuiTabItemFlags_NoPushId;
		case "NoTooltip"_hash: return ImGuiTabItemFlags_NoTooltip;
		case "NoReorder"_hash: return ImGuiTabItemFlags_NoReorder;
		case "Leading"_hash: return ImGuiTabItemFlags_Leading;
		case "Trailing"_hash: return ImGuiTabItemFlags_Trailing;
		case "NoAssumedClosure"_hash: return ImGuiTabItemFlags_NoAssumedClosure;
		default:
			Issue("ImGui tab item flag named \"{}\" is invalid.", flag.toString());
			return ImGuiTabItemFlags_None;
	}
}

uint32_t TabItemFlags(Slice* flags, int flagCount) {
	uint32_t result = 0;
	for (int i = 0; i < flagCount; i++) {
		result |= getTabItemFlag(flags[i]);
	}
	return result;
}

bool BeginTabBar(const std::string& str_id, uint32_t flags) {
	return ImGui::BeginTabBar(str_id.c_str(), flags);
}

bool BeginTabBar(const char* str_id, Slice* flags, int flagCount) {
	return ImGui::BeginTabBar(str_id, TabBarFlags(flags, flagCount));
}

bool BeginTabItem(const std::string& label, uint32_t flags) {
	return ImGui::BeginTabItem(label.c_str(), nullptr, flags);
}

bool BeginTabItem(const char* label, Slice* flags, int flagCount) {
	return ImGui::BeginTabItem(label, nullptr, TabItemFlags(flags, flagCount));
}

bool BeginTabItem(const std::string& label, CallStack* stack, uint32_t flags) {
	bool p_open = std::get<bool>(stack->pop());
	bool result = ImGui::BeginTabItem(label.c_str(), &p_open, flags);
	stack->push(p_open);
	return result;
}

bool BeginTabItem(const char* label, bool* p_open, Slice* flags, int flagCount) {
	return ImGui::BeginTabItem(label, p_open, TabItemFlags(flags, flagCount));
}

bool BeginTabItem(const char* label, CallStack* stack, Slice* flags, int flagCount) {
	bool p_open = std::get<bool>(stack->pop());
	bool result = ImGui::BeginTabItem(label, &p_open, TabItemFlags(flags, flagCount));
	stack->push(p_open);
	return result;
}

bool TabItemButton(const std::string& label, uint32_t flags) {
	return ImGui::TabItemButton(label.c_str(), flags);
}

bool TabItemButton(const char* label, Slice* flags, int flagCount) {
	return ImGui::TabItemButton(label, TabItemFlags(flags, flagCount));
}

NS_END(ImGui::Binding)
