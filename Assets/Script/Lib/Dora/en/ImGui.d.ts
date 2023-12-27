/// <reference path="dora.d.ts" />

import {
	Vec2Type as Vec2,
	BufferType as Buffer,
	ColorType as Color,
	Color3Type as Color3
} from "dora";

declare module "ImGui" {

export const enum StyleColor {
	Text = "Text",
	TextDisabled = "TextDisabled",
	WindowBg = "WindowBg",
	ChildBg = "ChildBg",
	PopupBg = "PopupBg",
	Border = "Border",
	BorderShadow = "BorderShadow",
	FrameBg = "FrameBg",
	FrameBgHovered = "FrameBgHovered",
	FrameBgActive = "FrameBgActive",
	TitleBg = "TitleBg",
	TitleBgActive = "TitleBgActive",
	TitleBgCollapsed = "TitleBgCollapsed",
	MenuBarBg = "MenuBarBg",
	ScrollbarBg = "ScrollbarBg",
	ScrollbarGrab = "ScrollbarGrab",
	ScrollbarGrabHovered = "ScrollbarGrabHovered",
	ScrollbarGrabActive = "ScrollbarGrabActive",
	CheckMark = "CheckMark",
	SliderGrabActive = "SliderGrabActive",
	Button = "Button",
	ButtonHovered = "ButtonHovered",
	ButtonActive = "ButtonActive",
	Header = "Header",
	HeaderHovered = "HeaderHovered",
	HeaderActive = "HeaderActive",
	Separator = "Separator",
	SeparatorHovered = "SeparatorHovered",
	SeparatorActive = "SeparatorActive",
	ResizeGrip = "ResizeGrip",
	ResizeGripHovered = "ResizeGripHovered",
	ResizeGripActive = "ResizeGripActive",
	Tab = "Tab",
	TabHovered = "TabHovered",
	TabActive = "TabActive",
	TabUnfocused = "TabUnfocused",
	TabUnfocusedActive = "TabUnfocusedActive",
	PlotLines = "PlotLines",
	PlotLinesHovered = "PlotLinesHovered",
	PlotHistogram = "PlotHistogram",
	PlotHistogramHovered = "PlotHistogramHovered",
	TableHeaderBg = "TableHeaderBg",
	TableBorderStrong = "TableBorderStrong",
	TableBorderLight = "TableBorderLight",
	TableRowBg = "TableRowBg",
	TableRowBgAlt = "TableRowBgAlt",
	TextSelectedBg = "TextSelectedBg",
	DragDropTarget = "DragDropTarget",
	NavHighlight = "NavHighlight",
	NavWindowingHighlight = "NavWindowingHighlight",
	NavWindowingDimBg = "NavWindowingDimBg",
	ModalWindowDimBg = "ModalWindowDimBg"
}

export const enum StyleVarNum {
	Alpha = "Alpha",
	WindowRounding = "WindowRounding",
	WindowBorderSize = "WindowBorderSize",
	ChildRounding = "ChildRounding",
	ChildBorderSize = "ChildBorderSize",
	PopupRounding = "PopupRounding",
	PopupBorderSize = "PopupBorderSize",
	FrameRounding = "FrameRounding",
	FrameBorderSize = "FrameBorderSize",
	IndentSpacing = "IndentSpacing",
	ScrollbarSize = "ScrollbarSize",
	ScrollbarRounding = "ScrollbarRounding",
	GrabMinSize = "GrabMinSize",
	GrabRounding = "GrabRounding",
	TabRounding = "TabRounding"
}

export const enum StyleVarVec {
	WindowPadding = "WindowPadding",
	WindowMinSize = "WindowMinSize",
	WindowTitleAlign = "WindowTitleAlign",
	FramePadding = "FramePadding",
	ItemSpacing = "ItemSpacing",
	ItemInnerSpacing = "ItemInnerSpacing",
	CellPadding = "CellPadding",
	ButtonTextAlign = "ButtonTextAlign",
	SelectableTextAlign = "SelectableTextAlign"
}

export const enum StyleVarBool {
	AntiAliasedLines = "AntiAliasedLines",
	AntiAliasedLinesUseTex = "AntiAliasedLinesUseTex",
	AntiAliasedFill = "AntiAliasedFill"
}

export const enum WindowFlag {
	None = "",
	NoNav = "NoNav",
	NoDecoration = "NoDecoration",
	NoTitleBar = "NoTitleBar",
	NoResize = "NoResize",
	NoMove = "NoMove",
	NoScrollbar = "NoScrollbar",
	NoScrollWithMouse = "NoScrollWithMouse",
	NoCollapse = "NoCollapse",
	AlwaysAutoResize = "AlwaysAutoResize",
	NoSavedSettings = "NoSavedSettings",
	NoInputs = "NoInputs",
	MenuBar = "MenuBar",
	HorizontalScrollbar = "HorizontalScrollbar",
	NoFocusOnAppearing = "NoFocusOnAppearing",
	NoBringToFrontOnFocus = "NoBringToFrontOnFocus",
	AlwaysVerticalScrollbar = "AlwaysVerticalScrollbar",
	AlwaysHorizontalScrollbar = "AlwaysHorizontalScrollbar"
}

export const enum ChildFlag {
	None = "",
	Border = "Border",
	AlwaysUseWindowPadding = "AlwaysUseWindowPadding",
	ResizeX = "ResizeX",
	ResizeY = "ResizeY",
	AutoResizeX = "AutoResizeX",
	AutoResizeY = "AutoResizeY",
	AlwaysAutoResize = "AlwaysAutoResize",
	FrameStyle = "FrameStyle"
}

export const enum SetCond {
	None = "",
	Always = "Always",
	Once = "Once",
	FirstUseEver = "FirstUseEver",
	Appearing = "Appearing"
}

export const enum ColorEditMode {
	None = "",
	RGB = "RGB",
	HSV = "HSV",
	HEX = "HEX"
}

export const enum InputTextFlag {
	None = "",
	CharsDecimal = "CharsDecimal",
	CharsHexadecimal = "CharsHexadecimal",
	CharsUppercase = "CharsUppercase",
	CharsNoBlank = "CharsNoBlank",
	AutoSelectAll = "AutoSelectAll",
	EnterReturnsTrue = "EnterReturnsTrue",
	CallbackCompletion = "CallbackCompletion",
	CallbackHistory = "CallbackHistory",
	CallbackAlways = "CallbackAlways",
	CallbackCharFilter = "CallbackCharFilter",
	AllowTabInput = "AllowTabInput",
	CtrlEnterForNewLine = "CtrlEnterForNewLine",
	NoHorizontalScroll = "NoHorizontalScroll",
	AlwaysOverwrite = "AlwaysOverwrite",
	ReadOnly = "ReadOnly",
	Password = "Password"
}

export const enum TreeNodeFlag {
	None = "",
	Selected = "Selected",
	Framed = "Framed",
	AllowItemOverlap = "AllowItemOverlap",
	NoTreePushOnOpen = "NoTreePushOnOpen",
	NoAutoOpenOnLog = "NoAutoOpenOnLog",
	DefaultOpen = "DefaultOpen",
	OpenOnDoubleClick = "OpenOnDoubleClick",
	OpenOnArrow = "OpenOnArrow",
	Leaf = "Leaf",
	Bullet = "Bullet",
	CollapsingHeader = "CollapsingHeader"
}

export const enum SelectableFlag {
	None = "",
	DontClosePopups = "DontClosePopups",
	SpanAllColumns = "SpanAllColumns",
	AllowDoubleClick = "AllowDoubleClick",
	Disabled = "Disabled",
	AllowItemOverlap = "AllowItemOverlap"
}

export const enum TableFlag {
	None = "",
	Resizable = "Resizable",
	Reorderable = "Reorderable",
	Hideable = "Hideable",
	Sortable = "Sortable",
	NoSavedSettings = "NoSavedSettings",
	ContextMenuInBody = "ContextMenuInBody",
	RowBg = "RowBg",
	BordersInnerH = "BordersInnerH",
	BordersOuterH = "BordersOuterH",
	BordersInnerV = "BordersInnerV",
	BordersOuterV = "BordersOuterV",
	BordersH = "BordersH",
	BordersV = "BordersV",
	BordersInner = "BordersInner",
	BordersOuter = "BordersOuter",
	NoBordersInBody = "NoBordersInBody",
	NoBordersInBodyUntilResize = "NoBordersInBodyUntilResize",
	SizingFixedFit = "SizingFixedFit",
	SizingFixedSame = "SizingFixedSame",
	SizingStretchProp = "SizingStretchProp",
	SizingStretchSame = "SizingStretchSame",
	NoHostExtendX = "NoHostExtendX",
	NoHostExtendY = "NoHostExtendY",
	NoKeepColumnsVisible = "NoKeepColumnsVisible",
	PreciseWidths = "PreciseWidths",
	NoClip = "NoClip",
	PadOuterX = "PadOuterX",
	NoPadOuterX = "NoPadOuterX",
	NoPadInnerX = "NoPadInnerX",
	ScrollX = "ScrollX",
	ScrollY = "ScrollY",
	SortMulti = "SortMulti"
}

export const enum TableRowFlag {
	None = "",
	Headers = "Headers"
}

export const enum TableColumnFlag {
	None = "",
	DefaultHide = "DefaultHide",
	DefaultSort = "DefaultSort",
	WidthStretch = "WidthStretch",
	WidthFixed = "WidthFixed",
	NoResize = "NoResize",
	NoReorder = "NoReorder",
	NoHide = "NoHide",
	NoClip = "NoClip",
	NoSort = "NoSort",
	NoSortAscending = "NoSortAscending",
	NoSortDescending = "NoSortDescending",
	NoHeaderWidth = "NoHeaderWidth",
	PreferSortAscending = "PreferSortAscending",
	PreferSortDescending = "PreferSortDescending",
	IndentEnable = "IndentEnable",
	IndentDisable = "IndentDisable",
	IsEnabled = "IsEnabled",
	IsVisible = "IsVisible",
	IsSorted = "IsSorted",
	IsHovered = "IsHovered"
}

export const enum SliderFlag {
	None = "",
	AlwaysClamp = "AlwaysClamp",
	Logarithmic = "Logarithmic",
	NoRoundToFormat = "NoRoundToFormat",
	NoInput = "NoInput"
}

export const enum PopupFlag {
	None = "",
	MouseButtonLeft = "MouseButtonLeft",
	MouseButtonRight = "MouseButtonRight",
	MouseButtonMiddle = "MouseButtonMiddle",
	NoOpenOverExistingPopup = "NoOpenOverExistingPopup",
	NoOpenOverItems = "NoOpenOverItems",
	AnyPopupId = "AnyPopupId",
	AnyPopupLevel = "AnyPopupLevel",
	AnyPopup = "AnyPopup"
}

export const enum GlyphRange {
	Default = "Default",
	Chinese = "Chinese",
	Korean = "Korean",
	Japanese = "Japanese",
	Cyrillic = "Cyrillic",
	Thai = "Thai",
	Greek = "Greek",
	Vietnamese = "Vietnamese"
}

interface ImGui {
	LoadFontTTF(this: void, ttfFontFile: string, fontSize: number, glyphRanges: GlyphRange, callback: () => void): boolean;
	IsFontLoaded(this: void): boolean;
	ShowStats(this: void, extra?: () => void): void;
	ShowStats(this: void, open: boolean, extra?: () => void): boolean;
	ShowConsole(this: void): void;
	ShowConsole(this: void, open: boolean): boolean;
	Begin(this: void, name: string, windowsFlags: WindowFlag[], inside: () => void): void;
	Begin(this: void, name: string, inside: () => void): void;
	Begin(this: void, name: string, p_open: boolean, windowsFlags: WindowFlag[], inside: () => void): boolean;
	Begin(this: void, name: string, p_open: boolean, inside: () => void): boolean;
	BeginChild(this: void, str_id: string, size: Vec2, childFlags: ChildFlag[], windowFlags: WindowFlag[], inside: () => void): void;
	BeginChild(this: void, str_id: string, size: Vec2, childFlags: ChildFlag[], inside: () => void): void;
	BeginChild(this: void, str_id: string, size: Vec2, inside: () => void): void;
	BeginChild(this: void, str_id: string, inside: () => void): void;
	BeginChild(this: void, id: number, size: Vec2, childFlags: ChildFlag[], windowsFlags: WindowFlag[], inside: () => void): void;
	BeginChild(this: void, id: number, size: Vec2, childFlags: ChildFlag[], inside: () => void): void;
	BeginChild(this: void, id: number, size: Vec2, inside: () => void): void;
	BeginChild(this: void, id: number, inside: () => void): void;
	SetNextWindowBgAlpha(this: void, alpha: number): void;
	SetNextWindowPos(this: void, pos: Vec2, setCond?: SetCond, pivot?: Vec2): void;
	SetNextWindowPosCenter(this: void, setCond?: SetCond, pivot?: Vec2): void;
	SetNextWindowSize(this: void, size: Vec2, setCond?: SetCond): void;
	SetNextWindowCollapsed(this: void, collapsed: boolean, setCond?: SetCond): void;
	SetWindowPos(this: void, name: string, pos: Vec2, setCond?: SetCond): void;
	SetWindowSize(this: void, name: string, size: Vec2, setCond?: SetCond): void;
	SetWindowCollapsed(this: void, name: string, collapsed: boolean, setCond?: SetCond): void;
	SetColorEditOptions(this: void, colorEditMode: ColorEditMode): void;
	InputText(this: void, label: string, buffer: Buffer, inputTextFlags?: InputTextFlag): boolean;
	InputTextMultiline(this: void, label: string, buffer: Buffer, size?: Vec2, inputTextFlags?: InputTextFlag): boolean;
	TreeNodeEx(this: void, label: string, treeNodeFlags: TreeNodeFlag, inside: () => void): boolean;
	TreeNodeEx(this: void, label: string, inside: () => void): boolean;
	TreeNodeEx(this: void, str_id: string, text: string, treeNodeFlags: TreeNodeFlag, inside: () => void): boolean;
	TreeNodeEx(this: void, str_id: string, text: string, inside: () => void): boolean;
	SetNextItemOpen(this: void, is_open: boolean, setCond?: SetCond): boolean;
	CollapsingHeader(this: void, label: string, treeNodeFlags?: TreeNodeFlag): boolean;
	CollapsingHeader(this: void, label: string, p_open: boolean, treeNodeFlags?: TreeNodeFlag): boolean;
	Selectable(this: void, label: string, selectableFlags?: SelectableFlag): boolean;
	Selectable(this: void, label: string, p_selected: boolean, size?: Vec2, selectableFlags?: SelectableFlag): boolean;
	BeginPopupModal(this: void, name: string, windowsFlags: WindowFlag, inside: () => void): void;
	BeginPopupModal(this: void, name: string, inside: () => void): void;
	BeginPopupModal(this: void, name: string, p_open: boolean, windowsFlags: WindowFlag, inside: () => void): boolean;
	BeginPopupModal(this: void, name: string, p_open: boolean, inside: () => void): boolean;
	PushStyleColor(this: void, name: StyleColor, color: Color, inside: () => void): void;
	PushStyleVar(this: void, name: StyleVarNum, val: number, inside: () => void): void;
	PushStyleVar(this: void, name: StyleVarVec, val: Vec2, inside: () => void): void;
	Text(this: void, text: string): void;
	TextColored(this: void, color: Color, text: string): void;
	TextDisabled(this: void, text: string): void;
	TextWrapped(this: void, text: string): void;
	LabelText(this: void, label: string, text: string): void;
	BulletText(this: void, text: string): void;
	SetTooltip(this: void, text: string): void;

	ColorEdit3(this: void, label: string, color3: Color3): boolean;
	ColorEdit4(this: void, label: string, color: Color, show_alpha?: boolean): boolean;

	Image(this: void, clipStr: string, size: Vec2, tint_col?: Color, border_col?: Color): void;
	ImageButton(this: void, str_id: string, clipStr: string, size: Vec2, frame_padding?: number, bg_col?: Color, tint_col?: Color): boolean;

	ColorButton(this: void, desc_id: string, col: Color, flags?: ColorEditMode, size?: Vec2): boolean;

	Columns(this: void, count?: number, border?: boolean, id?: string): void;

	BeginTable(this: void, str_id: string, column: number, inside: () => void): boolean;
	BeginTable(this: void, str_id: string, column: number, outer_size: Vec2, inside: () => void): boolean;
	BeginTable(this: void, str_id: string, column: number, outer_size: Vec2, inner_width: number, inside: () => void): boolean;
	BeginTable(this: void, str_id: string, column: number, outer_size: Vec2, inner_width: number, flags: TableFlag[], inside: () => void): boolean;
	TableNextRow(this: void, min_row_height?: number, row_flags?: TableRowFlag[]): void;
	TableSetupColumn(this: void, label: string, init_width_or_weight?: number, user_id?: number, flags?: TableColumnFlag[]): void;

	SetStyleVar(this: void, name: StyleVarBool, value: boolean): void;
	SetStyleVar(this: void, name: StyleVarNum, value: number): void;
	SetStyleVar(this: void, name: StyleVarVec, value: Vec2): void;

	SetStyleColor(this: void, name: StyleColor, color: Color): void;

	Combo(this: void, label: string, p_current_item: number, items: string[], height_in_items?: number): LuaMultiReturn<[boolean, number]>;

	DragFloat(this: void, label: string, p_v: number, v_speed: number, v_min: number, v_max: number, display_format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number]>;
	DragFloat2(this: void, label: string, p_v1: number, p_v2: number, v_speed?: number, v_min?: number, v_max?: number, display_format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number, number]>;
	DragInt(this: void, label: string, p_v: number, v_speed: number, v_min: number, v_max: number, display_format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number]>;
	DragInt2(this: void, label: string, v1: number, v2: number, v_speed?: number, v_min?: number, v_max?: number, display_format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number, number]>;

	InputFloat(
		label: string,
		p_v: number,
		step?: number, // Default: 0.0
		step_fast?: number, // Default: 0.0
		format?: string, // Default: "%.3f"
		flags?: SliderFlag // Default: nil
	): LuaMultiReturn<[boolean, number]>;

	InputFloat2(
		label: string,
		p_v1: number,
		p_v2: number,
		format?: string, // Default: "%.1f"
		flags?: SliderFlag
	): LuaMultiReturn<[boolean, number, number]>;

	InputInt(
			label: string,
			p_v: number,
			step?: number, // Default: 1
			step_fast?: number, // Default: 100
			flags?: SliderFlag
	): LuaMultiReturn<[boolean, number]>;

	InputInt2(
			label: string,
			p_v1: number,
			p_v2: number,
			flags?: SliderFlag
	): LuaMultiReturn<[boolean, number, number]>;

	SliderFloat(label: string, p_v: number, v_min: number, v_max: number, format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number]>;
	SliderFloat2(label: string, p_v1: number, p_v2: number, v_min: number, v_max: number, display_format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number, number]>;
	SliderInt(label: string, p_v: number, v_min: number, v_max: number, format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number]>;
	SliderInt2(label: string, p_v1: number, p_v2: number, v_min: number, v_max: number, display_format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number, number]>;
	DragFloatRange2(label: string, p_current_min: number, p_current_max: number, v_speed?: number, v_min?: number, v_max?: number, format?: string, format_max?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number, number]>;
	DragIntRange2(label: string, p_current_min: number, p_current_max: number, v_speed?: number, v_min?: number, v_max?: number, format?: string, format_max?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number, number]>;
	VSliderFloat(label: string, size: Vec2, p_v: number, v_min: number, v_max: number, format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number]>;
	VSliderInt(label: string, size: Vec2, p_v: number, v_min: number, v_max: number, format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number]>;

	SetNextItemWidth(item_width: number): void;
	PushItemWidth(item_width: number, inside: () => void): void;
	CalcItemWidth(): number;
	PushTextWrapPos(wrap_pos_x: number, inside: () => void): void; // Default: 0.0
	PushTextWrapPos(inside: () => void): void; // Default: 0.0
	PushAllowKeyboardFocus(v: boolean, inside: () => void): void;
	PushButtonRepeat(repeated: boolean, inside: () => void): void;

	ShowDemoWindow: () => void;
	GetContentRegionMax: () => Vec2;
	GetContentRegionAvail: () => Vec2;
	GetWindowContentRegionMin: () => Vec2;
	GetWindowContentRegionMax: () => Vec2;
	GetWindowContentRegionWidth: () => number;
	GetWindowPos: () => Vec2;
	GetWindowSize: () => Vec2;
	GetWindowWidth: () => number;
	GetWindowHeight: () => number;
	IsWindowCollapsed: () => boolean;
	SetWindowFontScale: (scale: number) => void;
	SetNextWindowSizeConstraints: (size_min: Vec2, size_max: Vec2) => void;
	SetNextWindowContentSize: (size: Vec2) => void;
	SetNextWindowFocus: () => void;
	SetWindowFocus: (name: string) => void;
	GetScrollX: () => number;
	GetScrollY: () => number;
	GetScrollMaxX: () => number;
	GetScrollMaxY: () => number;
	SetScrollX: (scroll_x: number) => void;
	SetScrollY: (scroll_y: number) => void;
	SetScrollHereY: (center_y_ratio?: number) => void;
	SetScrollFromPosY: (pos_y: number, center_y_ratio?: number) => void;
	SetKeyboardFocusHere: (offset?: number) => void;

	Separator: () => void;
	SeparatorText: (text: string) => void;
	SameLine: (pos_x?: number, spacing_w?: number) => void;
	NewLine: () => void;
	Spacing: () => void;
	Dummy: (size: Vec2) => void;
	Indent: (indent_w?: number) => void;
	Unindent: (indent_w?: number) => void;
	BeginGroup: (inside: () => void) => void;
	GetCursorPos: () => Vec2;
	GetCursorPosX: () => number;
	GetCursorPosY: () => number;
	SetCursorPos: (local_pos: Vec2) => void;
	SetCursorPosX: (x: number) => void;
	SetCursorPosY: (y: number) => void;
	GetCursorStartPos: () => Vec2;
	GetCursorScreenPos: () => Vec2;
	SetCursorScreenPos: (pos: Vec2) => void;
	AlignTextToFramePadding: () => void;
	GetTextLineHeight: () => number;
	GetTextLineHeightWithSpacing: () => number;

	NextColumn(): void;
	GetColumnIndex(): number;
	GetColumnOffset(column_index?: number): number;
	SetColumnOffset(column_index: number, offset_x: number): void;
	GetColumnWidth(column_index?: number): number;
	GetColumnsCount(): number;

	TableNextColumn(): boolean;
	TableSetColumnIndex(column_n: number): boolean;
	TableSetupScrollFreeze(cols: number, rows: number): void;
	TableHeadersRow(): void;
	TableHeader(label: string): void;

	PushID(str_id: string, inside: () => void): void;
	PushID(int_id: number, inside: () => void): void;
	GetID(str_id: string): number;

	BulletItem(): void;
	Button(label: string, size?: Vec2): boolean;
	SmallButton(label: string): boolean;
	InvisibleButton(str_id: string, size: Vec2): boolean;
	Checkbox(label: string, p_v: boolean): [boolean, boolean];
	RadioButton(label: string, p_v: number, v_button: number): [boolean, number];
	RadioButton(label: string, active: boolean): boolean;
	PlotLines(
		label: string,
		values: number[],
		values_offset?: number,
		overlay_text?: string,
		scale_min?: number,
		scale_max?: number,
		graph_size?: Vec2
	): void;
	PlotHistogram(
		label: string,
		values: number[],
		values_offset?: number,
		overlay_text?: string,
		scale_min?: number,
		scale_max?: number,
		graph_size?: Vec2
	): void;
	ProgressBar(
		fraction: number,
		size_arg?: Vec2,
		overlay?: string
	): void;

	ListBox(
		label: string,
		current_item: number,
		items: string[],
		height_in_items?: number
	): [boolean, number];

	SliderAngle(
		label: string,
		p_rad: number,
		v_degrees_min?: number,
		v_degrees_max?: number
	): [boolean, number];

	TreeNode(label: string, inside: () => boolean): boolean;
	TreeNode(str_id: string, text: string, inside: () => boolean): boolean;
	TreePush(str_id: string, inside: () => void): void;
	TreePush(inside: () => void): void;
	GetTreeNodeToLabelSpacing(): number;
	BeginListBox(label: string, size?: Vec2): boolean;
	EndListBox(): void;

	Value(prefix: string, b: boolean): void;
	Value(prefix: string, v: number): void;
	Value(prefix: string, v: number, float_format?: string): void;

	BeginDisabled(inside: () => void): void;
	BeginTooltip(inside: () => void): void;

	BeginMainMenuBar(inside: () => void): void;
	BeginMenuBar(inside: () => void): void;
	BeginMenu(label: string, enabled: boolean, inside: () => void): void;
	BeginMenu(label: string, inside: () => void): void;
	MenuItem(label: string, shortcut?: string, selected?: boolean, enabled?: boolean): boolean;
	MenuItemToggle(label: string, shortcut: string, p_selected: boolean, enabled?: boolean): [boolean, boolean];

	OpenPopup(str_id: string): void;
	BeginPopup(str_id: string, inside: () => void): void;
	BeginPopupContextItem(str_id: string, popupFlags: PopupFlag[], inside: () => void): void;
	BeginPopupContextItem(str_id: string, inside: () => void): void;
	BeginPopupContextWindow(str_id: string, popupFlags: PopupFlag[], inside: () => void): void;
	BeginPopupContextWindow(str_id: string, inside: () => void): void;
	BeginPopupContextVoid(str_id: string, popupFlags: PopupFlag[], inside: () => void): void;
	BeginPopupContextVoid(str_id: string, inside: () => void): void;
	BeginPopupContextVoid(inside: () => void): void;
	CloseCurrentPopup(): void;

	PushClipRect: (
		clip_rect_min: Vec2,
		clip_rect_max: Vec2,
		intersect_with_current_clip_rect: boolean,
		inside: () => void
	) => void;

	IsItemHovered: () => boolean;
	IsItemActive: () => boolean;
	IsItemClicked: (mouse_button?: number) => boolean;
	IsItemVisible: () => boolean;
	IsAnyItemHovered: () => boolean;
	IsAnyItemActive: () => boolean;
	GetItemRectMin: () => Vec2;
	GetItemRectMax: () => Vec2;
	GetItemRectSize: () => Vec2;
	SetItemAllowOverlap: () => boolean;
	IsWindowHovered: () => boolean;
	IsWindowFocused: () => boolean;
	IsRectVisible: (size_or_rect_min: Vec2, rect_max?: Vec2) => boolean;

	IsMouseDown(button: number): boolean;
	IsMouseClicked(
		button: number,
		repeated?: boolean // Default: false
	): boolean;
	IsMouseDoubleClicked(button: number): boolean;
	IsMouseReleased(button: number): boolean;
	IsMouseHoveringRect(
		r_min: Vec2,
		r_max: Vec2,
		clip?: boolean // Default: true
	): boolean;
	IsMouseDragging(
		button?: number, // Default: 0
		lock_threshold?: number // Default: -1.0
	): boolean;
	GetMousePos(): Vec2;
	GetMousePosOnOpeningCurrentPopup(): Vec2;
	GetMouseDragDelta(
		button?: number, // Default: 0
		lock_threshold?: number // Default: -1.0
	): Vec2;
	ResetMouseDragDelta(button?: number): void; // Default: 0
}

const imgui: ImGui;
export = imgui;

} // module "ImGui"
