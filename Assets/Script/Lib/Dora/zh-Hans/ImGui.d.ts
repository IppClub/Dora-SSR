/// <reference path="Dora.d.ts" />

declare module 'ImGui' {
import {
	Vec2,
	Buffer,
	Color,
	Color3
} from "Dora";

type Vec2 = Vec2.Type;
type Buffer = Buffer.Type;
type Color = Color.Type;
type Color3 = Color3.Type;

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
	TabHovered = "TabHovered",
	Tab = "Tab",
	TabSelected = "TabSelected",
	TabDimmed = "TabDimmed",
	TabDimmedSelected = "TabDimmedSelected",
	TabDimmedSelectedOverline = "TabDimmedSelectedOverline",
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
	TextLink = "TextLink",
	DragDropTarget = "DragDropTarget",
	NavCursor = "NavCursor",
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
	TabRounding = "TabRounding",
	SeparatorTextBorderSize = "SeparatorTextBorderSize"
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
	SelectableTextAlign = "SelectableTextAlign",
	SeparatorTextAlign = "SeparatorTextAlign",
	SeparatorTextPadding = "SeparatorTextPadding"
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
	AlwaysHorizontalScrollbar = "AlwaysHorizontalScrollbar",
	NoNavInputs = "NoNavInputs",
	NoNavFocus = "NoNavFocus",
	UnsavedDocument = "UnsavedDocument"
}

export const enum ChildFlag {
	None = "",
	Borders = "Borders",
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

export const enum ColorEditFlag {
	None = "",
	NoAlpha = "NoAlpha",
	NoPicker = "NoPicker",
	NoOptions = "NoOptions",
	NoSmallPreview = "NoSmallPreview",
	NoInputs = "NoInputs",
	NoTooltip = "NoTooltip",
	NoLabel = "NoLabel",
	NoSidePreview = "NoSidePreview",
	NoDragDrop = "NoDragDrop",
	NoBorder = "NoBorder",
	AlphaOpaque = "AlphaOpaque",
	AlphaNoBg = "AlphaNoBg",
	AlphaBar = "AlphaBar",
	AlphaPreviewHalf = "AlphaPreviewHalf",
	HDR = "HDR",
	DisplayRGB = "DisplayRGB",
	DisplayHSV = "DisplayHSV",
	DisplayHex = "DisplayHex",
	Uint8 = "Uint8",
	Float = "Float",
	PickerHueBar = "PickerHueBar",
	PickerHueWheel = "PickerHueWheel",
	InputRGB = "InputRGB",
	InputHSV = "InputHSV"
}

export const enum InputTextFlag {
	None = "",
	CharsDecimal = "CharsDecimal",
	CharsHexadecimal = "CharsHexadecimal",
	CharsScientific = "CharsScientific",
	CharsUppercase = "CharsUppercase",
	CharsNoBlank = "CharsNoBlank",
	AllowTabInput = "AllowTabInput",
	EnterReturnsTrue = "EnterReturnsTrue",
	EscapeClearsAll = "EscapeClearsAll",
	CtrlEnterForNewLine = "CtrlEnterForNewLine",
	ReadOnly = "ReadOnly",
	Password = "Password",
	AlwaysOverwrite = "AlwaysOverwrite",
	AutoSelectAll = "AutoSelectAll",
	ParseEmptyRefVal = "ParseEmptyRefVal",
	DisplayEmptyRefVal = "DisplayEmptyRefVal",
	NoHorizontalScroll = "NoHorizontalScroll",
	NoUndoRedo = "NoUndoRedo",
	ElideLeft = "ElideLeft",
	CallbackCompletion = "CallbackCompletion",
	CallbackHistory = "CallbackHistory",
	CallbackAlways = "CallbackAlways",
	CallbackCharFilter = "CallbackCharFilter",
	CallbackResize = "CallbackResize",
	CallbackEdit = "CallbackEdit"
}

export const enum TreeNodeFlag {
	None = "",
	Selected = "Selected",
	Framed = "Framed",
	AllowOverlap = "AllowOverlap",
	NoTreePushOnOpen = "NoTreePushOnOpen",
	NoAutoOpenOnLog = "NoAutoOpenOnLog",
	DefaultOpen = "DefaultOpen",
	OpenOnDoubleClick = "OpenOnDoubleClick",
	OpenOnArrow = "OpenOnArrow",
	Leaf = "Leaf",
	Bullet = "Bullet",
	FramePadding = "FramePadding",
	SpanAvailWidth = "SpanAvailWidth",
	SpanFullWidth = "SpanFullWidth",
	SpanLabelWidth = "SpanLabelWidth",
	SpanAllColumns = "SpanAllColumns",
	LabelSpanAllColumns = "LabelSpanAllColumns",
	NavLeftJumpsToParent = "NavLeftJumpsToParent",
	CollapsingHeader = "CollapsingHeader"
}

export const enum SelectableFlag {
	None = "",
	NoAutoClosePopups = "NoAutoClosePopups",
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
	SortMulti = "SortMulti",
	SortTristate = "SortTristate",
	HighlightHoveredColumn = "HighlightHoveredColumn"
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
	Logarithmic = "Logarithmic",
	NoRoundToFormat = "NoRoundToFormat",
	NoInput = "NoInput",
	WrapAround = "WrapAround",
	ClampOnInput = "ClampOnInput",
	ClampZeroRange = "ClampZeroRange",
	AlwaysClamp = "AlwaysClamp"
}

export const enum PopupFlag {
	None = "",
	MouseButtonLeft = "MouseButtonLeft",
	MouseButtonRight = "MouseButtonRight",
	MouseButtonMiddle = "MouseButtonMiddle",
	NoReopen = "NoReopen",
	NoOpenOverExistingPopup = "NoOpenOverExistingPopup",
	NoOpenOverItems = "NoOpenOverItems",
	AnyPopupId = "AnyPopupId",
	AnyPopupLevel = "AnyPopupLevel",
	AnyPopup = "AnyPopup"
}

export const enum ItemFlags {
	None = "",
	NoTabStop = "NoTabStop",
	NoNav = "NoNav",
	NoNavDefaultFocus = "NoNavDefaultFocus",
	ButtonRepeat = "ButtonRepeat",
	AutoClosePopups = "AutoClosePopups",
	AllowDuplicateId = "AllowDuplicateId",
}

export const enum TabBarFlag {
	Reorderable = "Reorderable",
	AutoSelectNewTabs = "AutoSelectNewTabs",
	TabListPopupButton = "TabListPopupButton",
	NoCloseWithMiddleMouseButton = "NoCloseWithMiddleMouseButton",
	NoTabListScrollingButtons = "NoTabListScrollingButtons",
	NoTooltip = "NoTooltip",
	DrawSelectedOverline = "DrawSelectedOverline",
	FittingPolicyShrink = "FittingPolicyShrink",
	FittingPolicyScroll = "FittingPolicyScroll",
}

export const enum TabItemFlag {
	UnsavedDocument = "UnsavedDocument",
	SetSelected = "SetSelected",
	NoCloseWithMiddleMouseButton = "NoCloseWithMiddleMouseButton",
	NoPushId = "NoPushId",
	NoTooltip = "NoTooltip",
	NoReorder = "NoReorder",
	Leading = "Leading",
	Trailing = "Trailing",
	NoAssumedClosure = "NoAssumedClosure",
}

export function SetDefaultFont(this: void, ttfFontFile: string, fontSize: number): void;
export function ShowStats(this: void): void;
export function ShowStats(this: void, open: boolean, extra?: (this: void) => void): boolean;
export function ShowConsole(this: void): void;
export function ShowConsole(this: void, open: boolean, initOnly?: boolean): boolean;
export function Begin(this: void, name: string, windowsFlags: WindowFlag[], inside: (this: void) => void): void;
export function Begin(this: void, name: string, inside: (this: void) => void): void;
export function Begin(this: void, name: string, p_open: boolean, windowsFlags: WindowFlag[], inside: (this: void) => void): boolean;
export function Begin(this: void, name: string, p_open: boolean, inside: (this: void) => void): boolean;
export function BeginChild(this: void, str_id: string, size: Vec2, childFlags: ChildFlag[], windowFlags: WindowFlag[], inside: (this: void) => void): void;
export function BeginChild(this: void, str_id: string, size: Vec2, childFlags: ChildFlag[], inside: (this: void) => void): void;
export function BeginChild(this: void, str_id: string, size: Vec2, inside: (this: void) => void): void;
export function BeginChild(this: void, str_id: string, inside: (this: void) => void): void;
export function BeginChild(this: void, id: number, size: Vec2, childFlags: ChildFlag[], windowsFlags: WindowFlag[], inside: (this: void) => void): void;
export function BeginChild(this: void, id: number, size: Vec2, childFlags: ChildFlag[], inside: (this: void) => void): void;
export function BeginChild(this: void, id: number, size: Vec2, inside: (this: void) => void): void;
export function BeginChild(this: void, id: number, inside: (this: void) => void): void;
export function SetNextWindowBgAlpha(this: void, alpha: number): void;
export function SetNextWindowPos(this: void, pos: Vec2, setCond?: SetCond, pivot?: Vec2): void;
export function SetNextWindowPosCenter(this: void, setCond?: SetCond, pivot?: Vec2): void;
export function SetNextWindowSize(this: void, size: Vec2, setCond?: SetCond): void;
export function SetNextWindowCollapsed(this: void, collapsed: boolean, setCond?: SetCond): void;
export function SetWindowPos(this: void, name: string, pos: Vec2, setCond?: SetCond): void;
export function SetWindowSize(this: void, name: string, size: Vec2, setCond?: SetCond): void;
export function SetWindowCollapsed(this: void, name: string, collapsed: boolean, setCond?: SetCond): void;
export function SetColorEditOptions(this: void, colorEditFlags: ColorEditFlag[]): void;
export function InputText(this: void, label: string, buffer: Buffer, inputTextFlags?: InputTextFlag[]): boolean;
export function InputTextMultiline(this: void, label: string, buffer: Buffer, size?: Vec2, inputTextFlags?: InputTextFlag[]): boolean;
export function TreeNodeEx(this: void, label: string, treeNodeFlags: TreeNodeFlag[], inside: (this: void) => void): boolean;
export function TreeNodeEx(this: void, label: string, inside: (this: void) => void): boolean;
export function TreeNodeEx(this: void, str_id: string, text: string, treeNodeFlags: TreeNodeFlag[], inside: (this: void) => void): boolean;
export function TreeNodeEx(this: void, str_id: string, text: string, inside: (this: void) => void): boolean;
export function SetNextItemOpen(this: void, is_open: boolean, setCond?: SetCond): boolean;
export function CollapsingHeader(this: void, label: string, treeNodeFlags?: TreeNodeFlag[]): boolean;
export function CollapsingHeader(this: void, label: string, p_open: boolean, treeNodeFlags?: TreeNodeFlag[]): boolean;
export function Selectable(this: void, label: string, selectableFlags?: SelectableFlag[]): boolean;
export function Selectable(this: void, label: string, p_selected: boolean, size?: Vec2, selectableFlags?: SelectableFlag[]): boolean;
export function BeginPopupModal(this: void, name: string, windowsFlags: WindowFlag[], inside: (this: void) => void): void;
export function BeginPopupModal(this: void, name: string, inside: (this: void) => void): void;
export function BeginPopupModal(this: void, name: string, p_open: boolean, windowsFlags: WindowFlag[], inside: (this: void) => void): boolean;
export function BeginPopupModal(this: void, name: string, p_open: boolean, inside: (this: void) => void): boolean;
export function PushStyleColor(this: void, name: StyleColor, color: Color, inside: (this: void) => void): void;
export function PushStyleVar(this: void, name: StyleVarNum, val: number, inside: (this: void) => void): void;
export function PushStyleVar(this: void, name: StyleVarVec, val: Vec2, inside: (this: void) => void): void;
export function Text(this: void, text: string): void;
export function TextColored(this: void, color: Color, text: string): void;
export function TextDisabled(this: void, text: string): void;
export function TextWrapped(this: void, text: string): void;
export function LabelText(this: void, label: string, text: string): void;
export function BulletText(this: void, text: string): void;
export function SetTooltip(this: void, text: string): void;

export function ColorEdit3(this: void, label: string, color3: Color3, flags?: ColorEditFlag[]): boolean;
export function ColorEdit4(this: void, label: string, color: Color, flags?: ColorEditFlag[]): boolean;

export function Image(this: void, clipStr: string, size: Vec2, bg_col?: Color, tint_col?: Color): void;
export function ImageButton(this: void, str_id: string, clipStr: string, size: Vec2, frame_padding?: number, bg_col?: Color, tint_col?: Color): boolean;

export function ColorButton(this: void, desc_id: string, col: Color, flags?: ColorEditFlag[], size?: Vec2): boolean;

export function Columns(this: void, count?: number, border?: boolean, id?: string): void;

export function BeginTable(this: void, str_id: string, column: number, inside: (this: void) => void): void;
export function BeginTable(this: void, str_id: string, column: number, outer_size: Vec2, inside: (this: void) => void): void;
export function BeginTable(this: void, str_id: string, column: number, outer_size: Vec2, inner_width: number, inside: (this: void) => void): void;
export function BeginTable(this: void, str_id: string, column: number, outer_size: Vec2, inner_width: number, flags: TableFlag[], inside: (this: void) => void): void;
export function TableNextRow(this: void, min_row_height?: number, row_flags?: TableRowFlag[]): void;
export function TableSetupColumn(this: void, label: string, init_width_or_weight?: number, user_id?: number, flags?: TableColumnFlag[]): void;

export function SetStyleVar(this: void, name: StyleVarBool, value: boolean): void;
export function SetStyleVar(this: void, name: StyleVarNum, value: number): void;
export function SetStyleVar(this: void, name: StyleVarVec, value: Vec2): void;

export function SetStyleColor(this: void, name: StyleColor, color: Color): void;

export function Combo(this: void, label: string, p_current_item: number, items: string[], height_in_items?: number): LuaMultiReturn<[boolean, number]>;

export function DragFloat(this: void, label: string, p_v: number, v_speed: number, v_min: number, v_max: number, display_format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number]>;
export function DragFloat2(this: void, label: string, p_v1: number, p_v2: number, v_speed?: number, v_min?: number, v_max?: number, display_format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number, number]>;
export function DragInt(this: void, label: string, p_v: number, v_speed: number, v_min: number, v_max: number, display_format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number]>;
export function DragInt2(this: void, label: string, v1: number, v2: number, v_speed?: number, v_min?: number, v_max?: number, display_format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number, number]>;

export function InputFloat(
		this: void,
		label: string,
		p_v: number,
		step?: number, // Default: 0.0
		step_fast?: number, // Default: 0.0
		format?: string, // Default: "%.3f"
		flags?: SliderFlag[] // Default: nil
	): LuaMultiReturn<[boolean, number]>;

export function InputFloat2(
		this: void,
		label: string,
		p_v1: number,
		p_v2: number,
		format?: string, // Default: "%.1f"
		flags?: SliderFlag[]
	): LuaMultiReturn<[boolean, number, number]>;

export function InputInt(
		this: void,
		label: string,
		p_v: number,
		step?: number, // Default: 1
		step_fast?: number, // Default: 100
		flags?: SliderFlag[]
	): LuaMultiReturn<[boolean, number]>;

export function InputInt2(
		this: void,
		label: string,
		p_v1: number,
		p_v2: number,
		flags?: SliderFlag[]
	): LuaMultiReturn<[boolean, number, number]>;

export function SliderFloat(this: void, label: string, p_v: number, v_min: number, v_max: number, format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number]>;
export function SliderFloat2(this: void, label: string, p_v1: number, p_v2: number, v_min: number, v_max: number, display_format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number, number]>;
export function SliderInt(this: void, label: string, p_v: number, v_min: number, v_max: number, format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number]>;
export function SliderInt2(this: void, label: string, p_v1: number, p_v2: number, v_min: number, v_max: number, display_format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number, number]>;
export function DragFloatRange2(this: void, label: string, p_current_min: number, p_current_max: number, v_speed?: number, v_min?: number, v_max?: number, format?: string, format_max?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number, number]>;
export function DragIntRange2(this: void, label: string, p_current_min: number, p_current_max: number, v_speed?: number, v_min?: number, v_max?: number, format?: string, format_max?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number, number]>;
export function VSliderFloat(this: void, label: string, size: Vec2, p_v: number, v_min: number, v_max: number, format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number]>;
export function VSliderInt(this: void, label: string, size: Vec2, p_v: number, v_min: number, v_max: number, format?: string, flags?: SliderFlag[]): LuaMultiReturn<[boolean, number]>;

export function SetNextItemWidth(this: void, item_width: number): void;
export function PushItemWidth(this: void, item_width: number, inside: (this: void) => void): void;
export function CalcItemWidth(this: void): number;
export function PushTextWrapPos(this: void, wrap_pos_x: number, inside: (this: void) => void): void; // Default: 0.0
export function PushTextWrapPos(this: void, inside: (this: void) => void): void; // Default: 0.0
export function PushAllowKeyboardFocus(this: void, v: boolean, inside: (this: void) => void): void;
export function PushButtonRepeat(this: void, repeated: boolean, inside: (this: void) => void): void;
export function PushItemFlag(flags: ItemFlags[], enabled: boolean, inside: (this: void) => void): void;

export function ShowDemoWindow(this: void): void;
export function GetContentRegionAvail(this: void): Vec2;
export function GetWindowContentRegionWidth(this: void): number;
export function GetWindowPos(this: void): Vec2;
export function GetWindowSize(this: void): Vec2;
export function GetWindowWidth(this: void): number;
export function GetWindowHeight(this: void): number;
export function IsWindowCollapsed(this: void): boolean;
export function SetNextWindowSizeConstraints(this: void, size_min: Vec2, size_max: Vec2): void;
export function SetNextWindowContentSize(this: void, size: Vec2): void;
export function SetNextWindowFocus(this: void): void;
export function SetWindowFocus(this: void, name: string): void;
export function GetScrollX(this: void): number;
export function GetScrollY(this: void): number;
export function GetScrollMaxX(this: void): number;
export function GetScrollMaxY(this: void): number;
export function SetScrollX(this: void, scroll_x: number): void;
export function SetScrollY(this: void, scroll_y: number): void;
export function SetScrollHereY(this: void, center_y_ratio?: number): void;
export function SetScrollFromPosY(this: void, pos_y: number, center_y_ratio?: number): void;
export function SetKeyboardFocusHere(this: void, offset?: number): void;

export function Separator(this: void): void;
export function SeparatorText(this: void, text: string): void;
export function SameLine(this: void, pos_x?: number, spacing_w?: number): void;
export function NewLine(this: void): void;
export function Spacing(this: void): void;
export function Dummy(this: void, size: Vec2): void;
export function Indent(this: void, indent_w?: number): void;
export function Unindent(this: void, indent_w?: number): void;
export function BeginGroup(this: void, inside: (this: void) => void): void;
export function GetCursorPos(this: void): Vec2;
export function GetCursorPosX(this: void): number;
export function GetCursorPosY(this: void): number;
export function SetCursorPos(this: void, local_pos: Vec2): void;
export function SetCursorPosX(this: void, x: number): void;
export function SetCursorPosY(this: void, y: number): void;
export function GetCursorStartPos(this: void): Vec2;
export function GetCursorScreenPos(this: void): Vec2;
export function SetCursorScreenPos(this: void, pos: Vec2): void;
export function AlignTextToFramePadding(this: void): void;
export function GetTextLineHeight(this: void): number;
export function GetTextLineHeightWithSpacing(this: void): number;

export function NextColumn(this: void): void;
export function GetColumnIndex(this: void): number;
export function GetColumnOffset(this: void, column_index?: number): number;
export function SetColumnOffset(this: void, column_index: number, offset_x: number): void;
export function GetColumnWidth(this: void, column_index?: number): number;
export function GetColumnsCount(this: void): number;

export function TableNextColumn(this: void): boolean;
export function TableSetColumnIndex(this: void, column_n: number): boolean;
export function TableSetupScrollFreeze(this: void, cols: number, rows: number): void;
export function TableHeadersRow(this: void): void;
export function TableHeader(this: void, label: string): void;

export function PushID(this: void, str_id: string, inside: (this: void) => void): void;
export function PushID(this: void, int_id: number, inside: (this: void) => void): void;
export function GetID(this: void, str_id: string): number;

export function BulletItem(this: void): void;
export function TextLink(label: string): boolean;
export function Button(this: void, label: string, size?: Vec2): boolean;
export function SmallButton(this: void, label: string): boolean;
export function InvisibleButton(this: void, str_id: string, size: Vec2): boolean;
export function Checkbox(this: void, label: string, p_v: boolean): LuaMultiReturn<[boolean, boolean]>;
export function RadioButton(this: void, label: string, p_v: number, v_button: number): LuaMultiReturn<[boolean, number]>;
export function RadioButton(this: void, label: string, active: boolean): boolean;
export function PlotLines(
		this: void,
		label: string,
		values: number[],
		values_offset?: number,
		overlay_text?: string,
		scale_min?: number,
		scale_max?: number,
		graph_size?: Vec2
	): void;
export function PlotHistogram(
		this: void,
		label: string,
		values: number[],
		values_offset?: number,
		overlay_text?: string,
		scale_min?: number,
		scale_max?: number,
		graph_size?: Vec2
	): void;
export function ProgressBar(
		this: void,
		fraction: number,
		size_arg?: Vec2,
		overlay?: string
	): void;

export function ListBox(
		this: void,
		label: string,
		current_item: number,
		items: string[],
		height_in_items?: number
	): LuaMultiReturn<[boolean, number]>;

export function SliderAngle(
		this: void,
		label: string,
		p_rad: number,
		v_degrees_min?: number,
		v_degrees_max?: number
	): LuaMultiReturn<[boolean, number]>;

export function TreeNode(this: void, label: string, inside: (this: void) => void): boolean;
export function TreeNode(this: void, str_id: string, text: string, inside: (this: void) => void): boolean;
export function TreePush(this: void, str_id: string, inside: (this: void) => void): void;
export function TreePush(this: void, inside: (this: void) => void): void;
export function GetTreeNodeToLabelSpacing(this: void): number;
export function BeginListBox(this: void, label: string, inside: (this: void) => void): void;
export function BeginListBox(this: void, label: string, size: Vec2, inside: (this: void) => void): void;

export function Value(this: void, prefix: string, b: boolean): void;
export function Value(this: void, prefix: string, v: number): void;
export function Value(this: void, prefix: string, v: number, float_format?: string): void;

export function BeginDisabled(this: void, inside: (this: void) => void): void;
export function BeginTooltip(this: void, inside: (this: void) => void): void;

export function BeginMainMenuBar(this: void, inside: (this: void) => void): void;
export function BeginMenuBar(this: void, inside: (this: void) => void): void;
export function BeginMenu(this: void, label: string, enabled: boolean, inside: (this: void) => void): void;
export function BeginMenu(this: void, label: string, inside: (this: void) => void): void;
export function MenuItem(this: void, label: string, shortcut?: string, selected?: boolean, enabled?: boolean): boolean;
export function MenuItemToggle(this: void, label: string, shortcut: string, p_selected: boolean, enabled?: boolean): LuaMultiReturn<[boolean, boolean]>;

export function OpenPopup(this: void, str_id: string): void;
export function BeginPopup(this: void, str_id: string, inside: (this: void) => void): void;
export function BeginPopupContextItem(this: void, str_id: string, popupFlags: PopupFlag[], inside: (this: void) => void): void;
export function BeginPopupContextItem(this: void, str_id: string, inside: (this: void) => void): void;
export function BeginPopupContextWindow(this: void, str_id: string, popupFlags: PopupFlag[], inside: (this: void) => void): void;
export function BeginPopupContextWindow(this: void, str_id: string, inside: (this: void) => void): void;
export function BeginPopupContextVoid(this: void, str_id: string, popupFlags: PopupFlag[], inside: (this: void) => void): void;
export function BeginPopupContextVoid(this: void, str_id: string, inside: (this: void) => void): void;
export function BeginPopupContextVoid(this: void, inside: (this: void) => void): void;
export function CloseCurrentPopup(this: void): void;

export function PushClipRect(
		this: void,
		clip_rect_min: Vec2,
		clip_rect_max: Vec2,
		intersect_with_current_clip_rect: boolean,
		inside: (this: void) => void
	): void;

export function IsItemHovered(this: void): boolean;
export function IsItemActive(this: void): boolean;
export function IsItemClicked(this: void, mouse_button?: number): boolean;
export function IsItemVisible(this: void): boolean;
export function IsAnyItemHovered(this: void): boolean;
export function IsAnyItemActive(this: void): boolean;
export function GetItemRectMin(this: void): Vec2;
export function GetItemRectMax(this: void): Vec2;
export function GetItemRectSize(this: void): Vec2;
export function SetItemAllowOverlap(this: void): boolean;
export function IsWindowHovered(this: void): boolean;
export function IsWindowFocused(this: void): boolean;
export function IsRectVisible(this: void, size_or_rect_min: Vec2, rect_max?: Vec2): boolean;

export function IsMouseDown(this: void, button: number): boolean;
export function IsMouseClicked(
		this: void,
		button: number,
		repeated?: boolean // Default: false
	): boolean;
export function IsMouseDoubleClicked(this: void, button: number): boolean;
export function IsMouseReleased(this: void, button: number): boolean;
export function IsMouseHoveringRect(
		this: void,
		r_min: Vec2,
		r_max: Vec2,
		clip?: boolean // Default: true
	): boolean;
export function IsMouseDragging(
		this: void,
		button?: number, // Default: 0
		lock_threshold?: number // Default: -1.0
	): boolean;
export function GetMousePos(this: void): Vec2;
export function GetMousePosOnOpeningCurrentPopup(this: void): Vec2;
export function GetMouseDragDelta(
		this: void,
		button?: number, // Default: 0
		lock_threshold?: number // Default: -1.0
	): Vec2;
export function ResetMouseDragDelta(this: void, button?: number): void; // Default: 0
export function ScrollWhenDraggingOnVoid(this: void): void;

export function BeginTabBar(this: void, str_id: string, inside: (this: void) => void): void;
export function BeginTabBar(this: void, str_id: string, flags: TabBarFlag[], inside: (this: void) => void): void;

export function BeginTabItem(this: void, label: string, inside: (this: void) => void): void;
export function BeginTabItem(this: void, label: string, flags: TabItemFlag[], inside: (this: void) => void): void;
export function BeginTabItem(this: void, label: string, opened: boolean, inside: (this: void) => void): boolean;
export function BeginTabItem(this: void, label: string, opened: boolean, flags: TabItemFlag[], inside: (this: void) => void): boolean;

export function TabItemButton(this: void, label: string): void;
export function TabItemButton(this: void, label: string, flags: TabItemFlag[]): void;
export function SetTabItemClosed(this: void, tab_or_docked_window_label: string): void;

} // module 'ImGui'
