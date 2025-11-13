local Vec2 = require("Vec2").Type
local Buffer = require("Buffer").Type
local Color = require("Color").Type
local Color3 = require("Color3").Type
local record ImGui
	enum StyleColor
		"Text"
		"TextDisabled"
		"WindowBg"
		"ChildBg"
		"PopupBg"
		"Border"
		"BorderShadow"
		"FrameBg"
		"FrameBgHovered"
		"FrameBgActive"
		"TitleBg"
		"TitleBgActive"
		"TitleBgCollapsed"
		"MenuBarBg"
		"ScrollbarBg"
		"ScrollbarGrab"
		"ScrollbarGrabHovered"
		"ScrollbarGrabActive"
		"CheckMark"
		"SliderGrabActive"
		"Button"
		"ButtonHovered"
		"ButtonActive"
		"Header"
		"HeaderHovered"
		"HeaderActive"
		"Separator"
		"SeparatorHovered"
		"SeparatorActive"
		"ResizeGrip"
		"ResizeGripHovered"
		"ResizeGripActive"
		"TabHovered"
		"Tab"
		"TabSelected"
		"TabDimmed"
		"TabDimmedSelected"
		"TabDimmedSelectedOverline"
		"PlotLines"
		"PlotLinesHovered"
		"PlotHistogram"
		"PlotHistogramHovered"
		"TableHeaderBg"
		"TableBorderStrong"
		"TableBorderLight"
		"TableRowBg"
		"TableRowBgAlt"
		"TextSelectedBg"
		"TextLink"
		"DragDropTarget"
		"NavCursor"
		"NavWindowingHighlight"
		"NavWindowingDimBg"
		"ModalWindowDimBg"
	end
	enum StyleVarNum
		"Alpha"
		"WindowRounding"
		"WindowBorderSize"
		"ChildRounding"
		"ChildBorderSize"
		"PopupRounding"
		"PopupBorderSize"
		"FrameRounding"
		"FrameBorderSize"
		"IndentSpacing"
		"ScrollbarSize"
		"ScrollbarRounding"
		"GrabMinSize"
		"GrabRounding"
		"TabRounding"
		"SeparatorTextBorderSize"
	end
	enum StyleVarVec
		"WindowPadding"
		"WindowMinSize"
		"WindowTitleAlign"
		"FramePadding"
		"ItemSpacing"
		"ItemInnerSpacing"
		"CellPadding"
		"ButtonTextAlign"
		"SelectableTextAlign"
		"SeparatorTextAlign"
		"SeparatorTextPadding"
	end
	enum StyleVarBool
		"AntiAliasedLines"
		"AntiAliasedLinesUseTex"
		"AntiAliasedFill"
	end
	enum WindowFlag
		""
		"NoNav"
		"NoDecoration"
		"NoTitleBar"
		"NoResize"
		"NoMove"
		"NoScrollbar"
		"NoScrollWithMouse"
		"NoCollapse"
		"AlwaysAutoResize"
		"NoSavedSettings"
		"NoInputs"
		"MenuBar"
		"HorizontalScrollbar"
		"NoFocusOnAppearing"
		"NoBringToFrontOnFocus"
		"AlwaysVerticalScrollbar"
		"AlwaysHorizontalScrollbar"
		"NoNavInputs"
		"NoNavFocus"
		"UnsavedDocument"
	end
	enum ChildFlag
		""
		"Borders"
		"AlwaysUseWindowPadding"
		"ResizeX"
		"ResizeY"
		"AutoResizeX"
		"AutoResizeY"
		"AlwaysAutoResize"
		"FrameStyle"
	end
	enum SetCond
		""
		"Always"
		"Once"
		"FirstUseEver"
		"Appearing"
	end
	enum ColorEditFlag
		"NoAlpha"
		"NoPicker"
		"NoOptions"
		"NoSmallPreview"
		"NoInputs"
		"NoTooltip"
		"NoLabel"
		"NoSidePreview"
		"NoDragDrop"
		"NoBorder"
		"AlphaOpaque"
		"AlphaNoBg"
		"AlphaBar"
		"AlphaPreviewHalf"
		"HDR"
		"DisplayRGB"
		"DisplayHSV"
		"DisplayHex"
		"Uint8"
		"Float"
		"PickerHueBar"
		"PickerHueWheel"
		"InputRGB"
		"InputHSV"
	end
	enum InputTextFlag
		""
		"CharsDecimal"
		"CharsHexadecimal"
		"CharsScientific"
		"CharsUppercase"
		"CharsNoBlank"
		"AllowTabInput"
		"EnterReturnsTrue"
		"EscapeClearsAll"
		"CtrlEnterForNewLine"
		"ReadOnly"
		"Password"
		"AlwaysOverwrite"
		"AutoSelectAll"
		"ParseEmptyRefVal"
		"DisplayEmptyRefVal"
		"NoHorizontalScroll"
		"NoUndoRedo"
		"ElideLeft"
		"CallbackCompletion"
		"CallbackHistory"
		"CallbackAlways"
		"CallbackCharFilter"
		"CallbackResize"
		"CallbackEdit"
	end
	enum TreeNodeFlag
		""
		"Selected"
		"Framed"
		"AllowOverlap"
		"NoTreePushOnOpen"
		"NoAutoOpenOnLog"
		"DefaultOpen"
		"OpenOnDoubleClick"
		"OpenOnArrow"
		"Leaf"
		"Bullet"
		"FramePadding"
		"SpanAvailWidth"
		"SpanFullWidth"
		"SpanLabelWidth"
		"SpanAllColumns"
		"LabelSpanAllColumns"
		"NavLeftJumpsToParent"
		"CollapsingHeader"
	end
	enum SelectableFlag
		""
		"NoAutoClosePopups"
		"SpanAllColumns"
		"AllowDoubleClick"
		"Disabled"
		"AllowItemOverlap"
	end
	enum TableFlag
		""
		"Resizable"
		"Reorderable"
		"Hideable"
		"Sortable"
		"NoSavedSettings"
		"ContextMenuInBody"
		"RowBg"
		"BordersInnerH"
		"BordersOuterH"
		"BordersInnerV"
		"BordersOuterV"
		"BordersH"
		"BordersV"
		"BordersInner"
		"BordersOuter"
		"Borders"
		"NoBordersInBody"
		"NoBordersInBodyUntilResize"
		"SizingFixedFit"
		"SizingFixedSame"
		"SizingStretchProp"
		"SizingStretchSame"
		"NoHostExtendX"
		"NoHostExtendY"
		"NoKeepColumnsVisible"
		"PreciseWidths"
		"NoClip"
		"PadOuterX"
		"NoPadOuterX"
		"NoPadInnerX"
		"ScrollX"
		"ScrollY"
		"SortMulti"
		"SortTristate"
		"HighlightHoveredColumn"
	end
	enum TableRowFlag
		""
		"Headers"
	end
	enum TableColumnFlag
		""
		"DefaultHide"
		"DefaultSort"
		"WidthStretch"
		"WidthFixed"
		"NoResize"
		"NoReorder"
		"NoHide"
		"NoClip"
		"NoSort"
		"NoSortAscending"
		"NoSortDescending"
		"NoHeaderWidth"
		"PreferSortAscending"
		"PreferSortDescending"
		"IndentEnable"
		"IndentDisable"
		"IsEnabled"
		"IsVisible"
		"IsSorted"
		"IsHovered"
	end
	enum SliderFlag
		""
		"Logarithmic"
		"NoRoundToFormat"
		"NoInput"
		"WrapAround"
		"ClampOnInput"
		"ClampZeroRange"
		"AlwaysClamp"
	end
	enum PopupFlag
		""
		"MouseButtonLeft"
		"MouseButtonRight"
		"MouseButtonMiddle"
		"NoReopen"
		"NoOpenOverExistingPopup"
		"NoOpenOverItems"
		"AnyPopupId"
		"AnyPopupLevel"
		"AnyPopup"
	end
	enum ItemFlags
		""
		"NoTabStop"
		"NoNav"
		"NoNavDefaultFocus"
		"ButtonRepeat"
		"AutoClosePopups"
		"AllowDuplicateId"
	end
	enum TabBarFlag
		"Reorderable"
		"AutoSelectNewTabs"
		"TabListPopupButton"
		"NoCloseWithMiddleMouseButton"
		"NoTabListScrollingButtons"
		"NoTooltip"
		"DrawSelectedOverline"
		"FittingPolicyShrink"
		"FittingPolicyScroll"
	end
	enum TabItemFlag
		"UnsavedDocument"
		"SetSelected"
		"NoCloseWithMiddleMouseButton"
		"NoPushId"
		"NoTooltip"
		"NoReorder"
		"Leading"
		"Trailing"
		"NoAssumedClosure"
	end
	SetDefaultFont: function(ttfFontFile: string, fontSize: number)
	ShowStats: function()
	ShowStats: function(open: boolean, windowsFlags: {WindowFlag}, extra?: function()): boolean
	ShowConsole: function(initOnly?: boolean)
	Begin: function(
		name: string,
		windowsFlags: {WindowFlag},
		inside: function()
	)
	Begin: function(
		name: string,
		inside: function()
	)
	Begin: function(
		name: string,
		p_open: boolean,
		windowsFlags: {WindowFlag},
		inside: function()
	): boolean
	Begin: function(
		name: string,
		p_open: boolean,
		inside: function()
	): boolean
	BeginChild: function(
		str_id: string,
		size: Vec2,
		childFlags: {ChildFlag},
		windowFlags: {WindowFlag},
		inside: function()
	)
	BeginChild: function(
		str_id: string,
		size: Vec2,
		childFlags: {ChildFlag},
		inside: function()
	)
	BeginChild: function(
		str_id: string,
		size: Vec2,
		inside: function()
	)
	BeginChild: function(
		str_id: string,
		inside: function()
	)
	BeginChild: function(
		id: integer,
		size: Vec2,
		childFlags: {ChildFlag},
		windowsFlags: {WindowFlag},
		inside: function()
	)
	BeginChild: function(
		id: integer,
		size: Vec2,
		childFlags: {ChildFlag},
		inside: function()
	)
	BeginChild: function(
		id: integer,
		size: Vec2,
		inside: function()
	)
	BeginChild: function(
		id: integer,
		inside: function()
	)
	SetNextWindowBgAlpha: function(alpha: number)
	SetNextWindowPos: function(
		pos: Vec2,
		setCond?: SetCond --[[""]],
		pivot?: Vec2 --[[Vec2.zero]]
	)
	SetNextWindowPosCenter: function(
		setCond?: SetCond --[[""]],
		pivot?: Vec2 --[[Vec2.zero]]
	)
	SetNextWindowSize: function(
		size: Vec2,
		setCond?: SetCond --[[""]]
	)
	SetNextWindowCollapsed: function(
		collapsed: boolean,
		setCond?: SetCond --[[""]]
	)
	SetWindowPos: function(
		name: string,
		pos: Vec2,
		setCond?: SetCond --[[""]]
	)
	SetWindowSize: function(
		name: string,
		size: Vec2,
		setCond?: SetCond --[[""]]
	)
	SetWindowCollapsed: function(
		name: string,
		collapsed: boolean,
		setCond?: SetCond --[[""]]
	)
	SetColorEditOptions: function(colorEditFlags: {ColorEditFlag})
	InputText: function(
		label: string,
		buffer: Buffer,
		inputTextFlags?: {InputTextFlag} --[[nil]]
	): boolean
	InputTextMultiline: function(
		label: string,
		buffer: Buffer,
		size?: Vec2 --[[Vec2.zero]],
		inputTextFlags?: {InputTextFlag} --[[nil]]
	): boolean
	TreeNodeEx: function(
		label: string,
		treeNodeFlags?: {TreeNodeFlag},
		inside: function()
	): boolean
	TreeNodeEx: function(
		label: string,
		inside: function()
	): boolean
	TreeNodeEx: function(
		str_id: string,
		text: string,
		treeNodeFlags?: {TreeNodeFlag},
		inside: function()
	): boolean
	TreeNodeEx: function(
		str_id: string,
		text: string,
		inside: function()
	): boolean
	SetNextItemOpen: function(
		is_open: boolean,
		setCond?: SetCond --[[""]]
	): boolean
	CollapsingHeader: function(
		label: string,
		treeNodeFlags?: {TreeNodeFlag} --[[nil]]
	): boolean
	CollapsingHeader: function(
		label: string,
		p_open: boolean,
		treeNodeFlags?: {TreeNodeFlag} --[[nil]]
	): boolean, boolean
	Selectable: function(
		label: string,
		selectableFlags?: {SelectableFlag} --[[nil]]
	): boolean
	Selectable: function(
		label: string,
		p_selected: boolean,
		size?: Vec2 --[[Vec2.zero]],
		selectableFlags?: {SelectableFlag} --[[nil]]
	): boolean, boolean
	BeginPopupModal: function(
		name: string,
		windowsFlags: {WindowFlag} --[[nil]],
		inside: function()
	)
	BeginPopupModal: function(
		name: string,
		inside: function()
	)
	BeginPopupModal: function(
		name: string,
		p_open: boolean,
		windowsFlags: {WindowFlag} --[[nil]],
		inside: function()
	): boolean
	BeginPopupModal: function(
		name: string,
		p_open: boolean,
		inside: function()
	): boolean

	PushStyleColor: function(name: StyleColor, color: Color, inside: function())
	PushStyleVar: function(name: StyleVarNum, val: number, inside: function())
	PushStyleVar: function(name: StyleVarVec, val: Vec2, inside: function())

	Text: function(text: string)
	TextColored: function(color: Color, text: string)
	TextDisabled: function(text: string)
	TextWrapped: function(text: string)
	LabelText: function(label: string, text: string)
	BulletText: function(text: string)
	SetTooltip: function(text: string)

	ColorEdit3: function(
		label: string,
		color3: Color3,
		flags?: {ColorEditFlag}
	): boolean
	ColorEdit4: function(
		label: string,
		color: Color,
		flags?: {ColorEditFlag}
	): boolean

	Image: function(
		clipStr: string,
		size: Vec2,
		bg_col?: Color,
		tint_col?: Color
	)
	ImageButton: function(
		str_id: string,
		clipStr: string,
		size: Vec2,
		frame_padding?: integer --[[-1]],
		bg_col?: Color --[[0x0]],
		tint_col?: Color --[[0xffffffff]]
	): boolean

	ColorButton: function(
		desc_id: string,
		col: Color,
		flags?: {ColorEditFlag} --[[""]],
		size?: Vec2 --[[Vec2.zero]]
	): boolean

	Columns: function(
		count?: integer --[[1]],
		border?: boolean --[[true]]
	)
	Columns: function(count: integer, border: boolean, id: string)

	BeginTable: function(
		str_id: string,
		column: integer,
		outer_size?: Vec2 --[[Vec2.zero]],
		inner_width?: number --[[0.0]],
		flags?: {TableFlag} --[[nil]],
		inside: function()
	)
	BeginTable: function(
		str_id: string,
		column: integer,
		outer_size: Vec2,
		inner_width: number,
		inside: function()
	)
	BeginTable: function(
		str_id: string,
		column: integer,
		outer_size: Vec2,
		inside: function()
	)
	BeginTable: function(
		str_id: string,
		column: integer,
		inside: function()
	)
	TableNextRow: function(
		min_row_height?: number --[[0.0]],
		row_flags?: {TableRowFlag} --[[nil]]
	)
	TableSetupColumn: function(
		label: string,
		init_width_or_weight?: number --[[0.0]],
		user_id?: integer --[[0]],
		flags?: {TableColumnFlag} --[[nil]]
	)

	SetStyleVar: function(name: StyleVarBool, var: boolean)
	SetStyleVar: function(name: StyleVarNum, var: number)
	SetStyleVar: function(name: StyleVarVec, var: Vec2)
	SetStyleColor: function(name: StyleColor, color: Color)

	Combo: function(
		label: string,
		p_current_item: integer,
		items: {string},
		height_in_items?: integer --[[-1]]
	): boolean, integer

	DragFloat: function(
		label: string,
		p_v: number,
		v_speed: number,
		v_min: number,
		v_max: number,
		display_format?: string --[["%.3f"]],
		flags?: {SliderFlag} --[[nil]]
	): boolean, number
	DragFloat2: function(
		label: string,
		p_v1: number,
		p_v2: number,
		v_speed?: number --[[1.0]],
		v_min?: number --[[0.0]],
		v_max?: number --[[0.0]],
		display_format?: string --[["%.3f"]],
		flags?: {SliderFlag} --[[nil]]
	): boolean, number, number
	DragInt: function(
		label: string,
		p_v: integer,
		v_speed: number,
		v_min: integer,
		v_max: integer,
		display_format?: string --[["%d"]],
		flags?: {SliderFlag} --[[nil]]
	): boolean, integer, integer
	DragInt2: function(
		label: string,
		v1: integer,
		v2: integer,
		v_speed?: number --[[1.0]],
		v_min?: integer --[[0]],
		v_max?: integer --[[0]],
		display_format?: string --[["%.0f"]],
		flags?: {SliderFlag} --[[nil]]
	): boolean, integer, integer
	InputFloat: function(
		label: string,
		p_v: number,
		step?: number --[[0.0]],
		step_fast?: number --[[0.0]],
		format?: string --[["%.3f"]],
		flags?: {SliderFlag} --[[nil]]
	): boolean, number
	InputFloat2: function(
		label: string,
		p_v1: number,
		p_v2: number,
		format?: string --[["%.1f"]],
		flags?: {SliderFlag} --[[nil]]
	): boolean, number, number
	InputInt: function(
		label: string,
		p_v: integer,
		step?: integer --[[1]],
		step_fast?: integer --[[100]],
		flags?: {SliderFlag} --[[nil]]
	): boolean, integer
	InputInt2: function(
		label: string,
		p_v1: integer,
		p_v2: integer,
		flags?: {SliderFlag} --[[nil]]
	): boolean, integer, integer
	SliderFloat: function(
		label: string,
		p_v: number,
		v_min: number,
		v_max: number,
		format?: string --[["%.3f"]],
		flags?: {SliderFlag} --[[nil]]
	): boolean, number
	SliderFloat2: function(
		label: string,
		p_v1: number,
		p_v2: number,
		v_min: number,
		v_max: number,
		display_format?: string --[["%.3f"]],
		flags?: {SliderFlag} --[[nil]]
	): boolean, number, number
	SliderInt: function(
		label: string,
		p_v: integer,
		v_min: integer,
		v_max: integer,
		format?: string --[["%d"]],
		flags?: {SliderFlag} --[[nil]]
	): boolean, integer
	SliderInt2: function(
		label: string,
		p_v1: integer,
		p_v2: integer,
		v_min: integer,
		v_max: integer,
		display_format?: string --[["%.0f"]],
		flags?: {SliderFlag} --[[nil]]
	): boolean, integer, integer
	DragFloatRange2: function(
		label: string,
		p_current_min: number,
		p_current_max: number,
		v_speed?: number --[[1.0]],
		v_min?: number --[[0.0]],
		v_max?: number --[[0.0]],
		format?: string --[["%.3f"]],
		format_max?: string --[[""]],
		flags?: {SliderFlag} --[[nil]]
	): boolean, number, number
	DragIntRange2: function(
		label: string,
		p_current_min: integer,
		p_current_max: integer,
		v_speed?: number --[[1.0]],
		v_min?: integer --[[0]],
		v_max?: integer --[[0]],
		format?: string --[["%d"]],
		format_max?: string --[[""]],
		flags?: {SliderFlag} --[[nil]]
	): boolean, integer, integer
	VSliderFloat: function(
		label: string,
		size: Vec2,
		p_v: number,
		v_min: number,
		v_max: number,
		format?: string --[["%.3f"]],
		flags?: {SliderFlag} --[[nil]]
	): boolean, number
	VSliderInt: function(
		label: string,
		size: Vec2,
		p_v: integer,
		v_min: integer,
		v_max: integer,
		format?: string --[["%d"]],
		flags?: {SliderFlag} --[[nil]]
	): boolean, integer

	ShowDemoWindow: function()
	GetContentRegionAvail: function(): Vec2
	GetWindowContentRegionWidth: function(): number
	GetWindowPos: function(): Vec2
	GetWindowSize: function(): Vec2
	GetWindowWidth: function(): number
	GetWindowHeight: function(): number
	IsWindowCollapsed: function(): boolean
	SetNextWindowSizeConstraints: function(size_min: Vec2, size_max: Vec2)
	SetNextWindowContentSize: function(size: Vec2)
	SetNextWindowFocus: function()
	SetWindowFocus: function(name: string)
	GetScrollX: function(): number
	GetScrollY: function(): number
	GetScrollMaxX: function(): number
	GetScrollMaxY: function(): number
	SetScrollX: function(scroll_x: number)
	SetScrollY: function(scroll_y: number)
	SetScrollHereY: function(center_y_ratio?: number --[[0.5]])
	SetScrollFromPosY: function(
		pos_y: number,
		center_y_ratio?: number --[[0.5]]
	)
	SetKeyboardFocusHere: function(offset?: integer --[[0]])

	SetNextItemWidth: function(item_width: number)
	PushItemWidth: function(item_width: number, inside: function())
	CalcItemWidth: function(): number
	PushTextWrapPos: function(wrap_pos_x: number --[[0.0]], inside: function())
	PushTextWrapPos: function(inside: function())
	PushAllowKeyboardFocus: function(v: boolean, inside: function())
	PushItemFlag: function(flags: {ItemFlags}, enabled: boolean, inside: function())

	Separator: function()
	SeparatorText: function(text: string)
	SameLine: function(
		pos_x?: number --[[0.0]],
		spacing_w?: number --[[-1.0]]
	)
	NewLine: function()
	Spacing: function()
	Dummy: function(size: Vec2)
	Indent: function(indent_w?: number --[[0.0]])
	Unindent: function(indent_w?: number --[[0.0]])
	BeginGroup: function(inside: function())
	GetCursorPos: function(): Vec2
	GetCursorPosX: function(): number
	GetCursorPosY: function(): number
	SetCursorPos: function(local_pos: Vec2)
	SetCursorPosX: function(x: number)
	SetCursorPosY: function(y: number)
	GetCursorStartPos: function(): Vec2
	GetCursorScreenPos: function(): Vec2
	SetCursorScreenPos: function(pos: Vec2)
	AlignTextToFramePadding: function()
	GetTextLineHeight: function(): number
	GetTextLineHeightWithSpacing: function(): number

	NextColumn: function()
	GetColumnIndex: function(): integer
	GetColumnOffset: function(column_index?: integer --[[-1]]): number
	SetColumnOffset: function(column_index: integer, offset_x: number)
	GetColumnWidth: function(column_index?: integer --[[-1]]): number
	GetColumnsCount: function(): integer

	TableNextColumn: function(): boolean
	TableSetColumnIndex: function(column_n: integer): boolean
	TableSetupScrollFreeze: function(cols: integer, rows: integer)
	TableHeadersRow: function()
	TableHeader: function(label: string)

	PushID: function(str_id: string, inside: function())
	PushID: function(int_id: integer, inside: function())
	GetID: function(str_id: string): integer

	BulletItem: function()
	TextLink: function(label: string): boolean
	Button: function(
		label: string,
		size?: Vec2 --[[Vec2.zero]]
	): boolean
	SmallButton: function(label: string): boolean
	InvisibleButton: function(str_id: string, size: Vec2): boolean
	Checkbox: function(label: string, p_v: boolean): boolean, boolean
	RadioButton: function(label: string,  p_v: integer, v_button: integer): boolean, integer
	RadioButton: function(label: string, active: boolean): boolean
	PlotLines: function(
		label: string,
		values: {number},
		values_offset?: integer --[[0]],
		overlay_text?: string --[[""]],
		scale_min?: number --[[min]],
		scale_max?: number --[[[max]],
		graph_size?: Vec2 --[[Vec2.zero]]
	)
	PlotHistogram: function(
		label: string,
		values: {number},
		values_offset?: integer --[[0]],
		overlay_text?: string --[[""]],
		scale_min?: number --[[min]],
		scale_max?: number --[[max]],
		graph_size?: Vec2 --[[Vec2.zero]]
	)
	ProgressBar: function(
		fraction: number,
		size_arg?: Vec2 --[[Vec2(-1,0)]],
		overlay?: string --[[""]]
	)

	ListBox: function(
		label: string,
		current_item: integer,
		items: {string},
		height_in_items?: integer --[[-1]]
	): boolean, integer

	SliderAngle: function(
		label: string,
		p_rad: number,
		v_degrees_min?: number --[[-360.0]],
		v_degrees_max?: number --[[360.0]]
	): boolean, number

	TreeNode: function(label: string, inside: function()): boolean
	TreeNode: function(str_id: string, text: string, inside: function()): boolean
	TreePush: function(
		str_id: string --[[""]],
		inside: function()
	)
	TreePush: function(inside: function())
	GetTreeNodeToLabelSpacing: function(): number
	BeginListBox: function(
		label: string,
		size: Vec2,
		inside: function()
	)
	BeginListBox: function(
		label: string,
		inside: function()
	)

	Value: function(prefix: string, b: boolean)
	Value: function(prefix: string, v: integer)
	Value: function(
		prefix: string,
		v: number,
		float_format?: string --[[""]]
	)

	BeginDisabled: function(inside: function())
	BeginTooltip: function(inside: function())

	BeginMainMenuBar: function(inside: function())
	BeginMenuBar: function(inside: function())
	BeginMenu: function(
		label: string,
		enabled: boolean --[[true]],
		inside: function()
	)
	BeginMenu: function(
		label: string,
		inside: function()
	)
	MenuItem: function(
		label: string,
		shortcut?: string --[[""]],
		selected?: boolean --[[false]],
		enabled?: boolean --[[true]]
	): boolean
	MenuItemToggle: function(
		label: string,
		shortcut: string,
		p_selected: boolean,
		enabled?: boolean --[[true]]
	): boolean, boolean

	OpenPopup: function(str_id: string)
	BeginPopup: function(str_id: string, inside: function())
	BeginPopupContextItem: function(
		str_id: string,
		popupFlags: {PopupFlag} --[[nil]],
		inside: function()
	)
	BeginPopupContextItem: function(
		str_id: string,
		inside: function()
	)
	BeginPopupContextWindow: function(
		str_id: string,
		popupFlags: {PopupFlag} --[[nil]],
		inside: function()
	)
	BeginPopupContextWindow: function(
		str_id: string,
		inside: function()
	)
	BeginPopupContextVoid: function(
		str_id: string --[[""]],
		popupFlags: {PopupFlag} --[[nil]],
		inside: function()
	)
	BeginPopupContextVoid: function(
		str_id: string,
		inside: function()
	)
	BeginPopupContextVoid: function(
		inside: function()
	)
	CloseCurrentPopup: function()

	PushClipRect: function(
		clip_rect_min: Vec2,
		clip_rect_max: Vec2,
		intersect_with_current_clip_rect: boolean,
		inside: function()
	)

	IsItemHovered: function(): boolean
	IsItemActive: function(): boolean
	IsItemClicked: function(
		mouse_button?: integer --[[0]]
	): boolean
	IsItemVisible: function(): boolean
	IsAnyItemHovered: function(): boolean
	IsAnyItemActive: function(): boolean
	GetItemRectMin: function(): Vec2
	GetItemRectMax: function(): Vec2
	GetItemRectSize: function(): Vec2
	SetItemAllowOverlap: function(): boolean
	IsWindowHovered: function(): boolean
	IsWindowFocused: function(): boolean
	IsRectVisible: function(size: Vec2): boolean
	IsRectVisible: function(rect_min: Vec2, rect_max: Vec2): boolean
	IsMouseDown: function(button: integer): boolean
	IsMouseClicked: function(
		button: integer,
		repeated?: boolean --[[false]]
	): boolean
	IsMouseDoubleClicked: function(button: integer): boolean
	IsMouseReleased: function(button: integer): boolean
	IsMouseHoveringRect: function(
		r_min: Vec2,
		r_max: Vec2,
		clip?: boolean --[[true]]): boolean
	IsMouseDragging: function(
		button?: integer --[[0]],
		lock_threshold?: number --[[-1.0]]
	): boolean
	GetMousePos: function(): Vec2
	GetMousePosOnOpeningCurrentPopup: function(): Vec2
	GetMouseDragDelta: function(
		button?: integer --[[0]],
		lock_threshold?: number --[[-1.0]]
	): Vec2
	ResetMouseDragDelta: function(
		button?: integer --[[0]]
	)
	ScrollWhenDraggingOnVoid: function()

	BeginTabBar: function(str_id: string, inside: function())
	BeginTabBar: function(str_id: string, flags: {TabBarFlag}, inside: function())

	BeginTabItem: function(label: string, inside: function())
	BeginTabItem: function(label: string, flags: {TabItemFlag}, inside: function())
	BeginTabItem: function(label: string, opened: boolean, inside: function()): boolean
	BeginTabItem: function(label: string, opened: boolean, flags: {TabItemFlag}, inside: function()): boolean

	TabItemButton: function(label: string)
	TabItemButton: function(label: string, flags: {TabItemFlag})
	SetTabItemClosed: function(tab_or_docked_window_label: string)
end
local imgui: ImGui
return imgui
