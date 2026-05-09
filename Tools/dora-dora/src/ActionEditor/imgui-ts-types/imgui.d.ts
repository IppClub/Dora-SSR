/* eslint-disable no-var, @typescript-eslint/no-duplicate-enum-values */
export interface XY {
    x: number;
    y: number;
}
export interface XYZ extends XY {
    z: number;
}
export interface XYZW extends XYZ {
    w: number;
}
export interface RGB {
    r: number;
    g: number;
    b: number;
}
export interface RGBA extends RGB {
    a: number;
}
import * as Bind from "./bind-imgui";
export { Bind };
declare let bind: Bind.Module;
export declare let FLT_MIN: number;
export declare let FLT_MAX: number;
export default function (value?: Partial<Bind.Module>): Promise<void>;
export { bind };
export declare var isMobile: {
    Android: () => RegExpMatchArray;
    BlackBerry: () => RegExpMatchArray;
    iOS: () => RegExpMatchArray;
    Opera: () => RegExpMatchArray;
    Windows: () => RegExpMatchArray;
    any: () => RegExpMatchArray;
    isPortrait: () => boolean;
};
export { IMGUI_VERSION as VERSION };
export declare const IMGUI_VERSION: string;
export { IMGUI_VERSION_NUM as VERSION_NUM };
export declare const IMGUI_VERSION_NUM: number;
export { IMGUI_CHECKVERSION as CHECKVERSION };
export declare function IMGUI_CHECKVERSION(): boolean;
export declare const IMGUI_HAS_TABLE: boolean;
export declare function ASSERT(c: any): asserts c;
export declare function IM_ASSERT(c: any): asserts c;
export { IM_ARRAYSIZE as ARRAYSIZE };
export declare function IM_ARRAYSIZE(_ARR: ArrayLike<any> | ImStringBuffer): number;
export { ImStringBuffer as StringBuffer };
export declare class ImStringBuffer {
    size: number;
    buffer: string;
    constructor(size: number, buffer?: string);
}
export type ImAccess<T> = Bind.ImAccess<T>;
export { ImAccess as Access };
export type ImScalar<T> = Bind.ImScalar<T>;
export { ImScalar as Scalar };
export type ImTuple2<T> = Bind.ImTuple2<T>;
export { ImTuple2 as Tuple2 };
export type ImTuple3<T> = Bind.ImTuple3<T>;
export { ImTuple3 as Tuple3 };
export type ImTuple4<T> = Bind.ImTuple4<T>;
export { ImTuple4 as Tuple4 };
export { ImTextureID as TextureID };
export type ImTextureID = WebGLTexture;
export { ImGuiID as ID };
export type ImGuiID = Bind.ImGuiID;
export { ImGuiWindowFlags as WindowFlags };
export declare enum ImGuiWindowFlags {
    None = 0,
    NoTitleBar = 1,// Disable title-bar
    NoResize = 2,// Disable user resizing with the lower-right grip
    NoMove = 4,// Disable user moving the window
    NoScrollbar = 8,// Disable scrollbars (window can still scroll with mouse or programatically)
    NoScrollWithMouse = 16,// Disable user vertically scrolling with mouse wheel. On child window, mouse wheel will be forwarded to the parent unless NoScrollbar is also set.
    NoCollapse = 32,// Disable user collapsing window by double-clicking on it
    AlwaysAutoResize = 64,// Resize every window to its content every frame
    NoBackground = 128,// Disable drawing background color (WindowBg, etc.) and outside border. Similar as using SetNextWindowBgAlpha(0.0f).
    NoSavedSettings = 256,// Never load/save settings in .ini file
    NoMouseInputs = 512,// Disable catching mouse or keyboard inputs, hovering test with pass through.
    MenuBar = 1024,// Has a menu-bar
    HorizontalScrollbar = 2048,// Allow horizontal scrollbar to appear (off by default). You may use SetNextWindowContentSize(ImVec2(width,0.0f)); prior to calling Begin() to specify width. Read code in imgui_demo in the "Horizontal Scrolling" section.
    NoFocusOnAppearing = 4096,// Disable taking focus when transitioning from hidden to visible state
    NoBringToFrontOnFocus = 8192,// Disable bringing window to front when taking focus (e.g. clicking on it or programatically giving it focus)
    AlwaysVerticalScrollbar = 16384,// Always show vertical scrollbar (even if ContentSize.y < Size.y)
    AlwaysHorizontalScrollbar = 32768,// Always show horizontal scrollbar (even if ContentSize.x < Size.x)
    AlwaysUseWindowPadding = 65536,// Ensure child windows without border uses style.WindowPadding (ignored by default for non-bordered child windows, because more convenient)
    NoNavInputs = 262144,// No gamepad/keyboard navigation within the window
    NoNavFocus = 524288,// No focusing toward this window with gamepad/keyboard navigation (e.g. skipped by CTRL+TAB)
    UnsavedDocument = 1048576,// Append '*' to title without affecting the ID, as a convenience to avoid using the ### operator. When used in a tab/docking context, tab is selected on closure and closure is deferred by one frame to allow code to cancel the closure (with a confirmation popup, etc.) without flicker.
    NoNav = 786432,
    NoDecoration = 43,
    NoInputs = 786944,
    NavFlattened = 8388608,// (WIP) Allow gamepad/keyboard navigation to cross over parent border to this child (only use on child that have no scrolling!)
    ChildWindow = 16777216,// Don't use! For internal use by BeginChild()
    Tooltip = 33554432,// Don't use! For internal use by BeginTooltip()
    Popup = 67108864,// Don't use! For internal use by BeginPopup()
    Modal = 134217728,// Don't use! For internal use by BeginPopupModal()
    ChildMenu = 268435456
}
export { ImGuiInputTextFlags as InputTextFlags };
export declare enum ImGuiInputTextFlags {
    None = 0,
    CharsDecimal = 1,// Allow 0123456789.+-*/
    CharsHexadecimal = 2,// Allow 0123456789ABCDEFabcdef
    CharsUppercase = 4,// Turn a..z into A..Z
    CharsNoBlank = 8,// Filter out spaces, tabs
    AutoSelectAll = 16,// Select entire text when first taking mouse focus
    EnterReturnsTrue = 32,// Return 'true' when Enter is pressed (as opposed to when the value was modified)
    CallbackCompletion = 64,// Call user function on pressing TAB (for completion handling)
    CallbackHistory = 128,// Call user function on pressing Up/Down arrows (for history handling)
    CallbackAlways = 256,// Call user function every time. User code may query cursor position, modify text buffer.
    CallbackCharFilter = 512,// Call user function to filter character. Modify data->EventChar to replace/filter input, or return 1 to discard character.
    AllowTabInput = 1024,// Pressing TAB input a '\t' character into the text field
    CtrlEnterForNewLine = 2048,// In multi-line mode, unfocus with Enter, add new line with Ctrl+Enter (default is opposite: unfocus with Ctrl+Enter, add line with Enter).
    NoHorizontalScroll = 4096,// Disable following the cursor horizontally
    AlwaysInsertMode = 8192,// Insert mode
    ReadOnly = 16384,// Read-only mode
    Password = 32768,// Password mode, display all characters as '*'
    NoUndoRedo = 65536,// Disable undo/redo. Note that input text owns the text data while active, if you want to provide your own undo/redo stack you need e.g. to call ClearActiveID().
    CharsScientific = 131072,// Allow 0123456789.+-*/eE (Scientific notation input)
    CallbackResize = 262144,// Allow buffer capacity resize + notify when the string wants to be resized (for string types which hold a cache of their Size) (see misc/stl/imgui_stl.h for an example of using this)
    CallbackEdit = 524288,// Callback on any edit (note that InputText() already returns true on edit, the callback is useful mainly to manipulate the underlying buffer while focus is active)
    Multiline = 1048576,// For internal use by InputTextMultiline()
    NoMarkEdited = 2097152
}
export { ImGuiTreeNodeFlags as TreeNodeFlags };
export declare enum ImGuiTreeNodeFlags {
    None = 0,
    Selected = 1,// Draw as selected
    Framed = 2,// Full colored frame (e.g. for CollapsingHeader)
    AllowItemOverlap = 4,// Hit testing to allow subsequent widgets to overlap this one
    NoTreePushOnOpen = 8,// Don't do a TreePush() when open (e.g. for CollapsingHeader) = no extra indent nor pushing on ID stack
    NoAutoOpenOnLog = 16,// Don't automatically and temporarily open node when Logging is active (by default logging will automatically open tree nodes)
    DefaultOpen = 32,// Default node to be open
    OpenOnDoubleClick = 64,// Need double-click to open node
    OpenOnArrow = 128,// Only open when clicking on the arrow part. If OpenOnDoubleClick is also set, single-click arrow or double-click all box to open.
    Leaf = 256,// No collapsing, no arrow (use as a convenience for leaf nodes).
    Bullet = 512,// Display a bullet instead of arrow
    FramePadding = 1024,// Use FramePadding (even for an unframed text node) to vertically align text baseline to regular widget height. Equivalent to calling AlignTextToFramePadding().
    SpanAvailWidth = 2048,// Extend hit box to the right-most edge, even if not framed. This is not the default in order to allow adding other items on the same line. In the future we may refactor the hit system to be front-to-back, allowing natural overlaps and then this can become the default.
    SpanFullWidth = 4096,// Extend hit box to the left-most and right-most edges (bypass the indented area).
    NavLeftJumpsBackHere = 8192,// (WIP) Nav: left direction may move to this TreeNode() from any of its child (items submitted between TreeNode and TreePop)
    CollapsingHeader = 26
}
export { ImGuiPopupFlags as PopupFlags };
export declare enum ImGuiPopupFlags {
    None = 0,
    MouseButtonLeft = 0,// For BeginPopupContext*(): open on Left Mouse release. Guaranteed to always be == 0 (same as ImGuiMouseButton_Left)
    MouseButtonRight = 1,// For BeginPopupContext*(): open on Right Mouse release. Guaranteed to always be == 1 (same as ImGuiMouseButton_Right)
    MouseButtonMiddle = 2,// For BeginPopupContext*(): open on Middle Mouse release. Guaranteed to always be == 2 (same as ImGuiMouseButton_Middle)
    MouseButtonMask_ = 31,
    MouseButtonDefault_ = 1,
    NoOpenOverExistingPopup = 32,// For OpenPopup*(), BeginPopupContext*(): don't open if there's already a popup at the same level of the popup stack
    NoOpenOverItems = 64,// For BeginPopupContextWindow(): don't return true when hovering items, only when hovering empty space
    AnyPopupId = 128,// For IsPopupOpen(): ignore the ImGuiID parameter and test for any popup.
    AnyPopupLevel = 256,// For IsPopupOpen(): search/test at any level of the popup stack (default test in the current level)
    AnyPopup = 384
}
export { ImGuiSelectableFlags as SelectableFlags };
export declare enum ImGuiSelectableFlags {
    None = 0,
    DontClosePopups = 1,// Clicking this don't close parent popup window
    SpanAllColumns = 2,// Selectable frame can span all columns (text will still fit in current column)
    AllowDoubleClick = 4,// Generate press events on double clicks too
    Disabled = 8,// Cannot be selected, display greyed out text
    AllowItemOverlap = 16
}
export { ImGuiComboFlags as ComboFlags };
export declare enum ImGuiComboFlags {
    None = 0,
    PopupAlignLeft = 1,// Align the popup toward the left by default
    HeightSmall = 2,// Max ~4 items visible. Tip: If you want your combo popup to be a specific size you can use SetNextWindowSizeConstraints() prior to calling BeginCombo()
    HeightRegular = 4,// Max ~8 items visible (default)
    HeightLarge = 8,// Max ~20 items visible
    HeightLargest = 16,// As many fitting items as possible
    NoArrowButton = 32,// Display on the preview box without the square arrow button
    NoPreview = 64,// Display only a square arrow button
    HeightMask_ = 30
}
export { ImGuiTabBarFlags as TabBarFlags };
export declare enum ImGuiTabBarFlags {
    None = 0,
    Reorderable = 1,// Allow manually dragging tabs to re-order them + New tabs are appended at the end of list
    AutoSelectNewTabs = 2,// Automatically select new tabs when they appear
    TabListPopupButton = 4,
    NoCloseWithMiddleMouseButton = 8,// Disable behavior of closing tabs (that are submitted with p_open != NULL) with middle mouse button. You can still repro this behavior on user's side with if (IsItemHovered() && IsMouseClicked(2)) *p_open = false.
    NoTabListScrollingButtons = 16,
    NoTooltip = 32,// Disable tooltips when hovering a tab
    FittingPolicyResizeDown = 64,// Resize tabs when they don't fit
    FittingPolicyScroll = 128,// Add scroll buttons when tabs don't fit
    FittingPolicyMask_ = 192,
    FittingPolicyDefault_ = 64
}
export { ImGuiTabItemFlags as TabItemFlags };
export declare enum ImGuiTabItemFlags {
    None = 0,
    UnsavedDocument = 1,// Append '*' to title without affecting the ID, as a convenience to avoid using the ### operator. Also: tab is selected on closure and closure is deferred by one frame to allow code to undo it without flicker.
    SetSelected = 2,// Trigger flag to programatically make the tab selected when calling BeginTabItem()
    NoCloseWithMiddleMouseButton = 4,// Disable behavior of closing tabs (that are submitted with p_open != NULL) with middle mouse button. You can still repro this behavior on user's side with if (IsItemHovered() && IsMouseClicked(2)) *p_open = false.
    NoPushId = 8,// Don't call PushID(tab->ID)/PopID() on BeginTabItem()/EndTabItem()
    NoTooltip = 16,// Disable tooltip for the given tab
    NoReorder = 32,// Disable reordering this tab or having another tab cross over this tab
    Leading = 64,// Enforce the tab position to the left of the tab bar (after the tab list popup button)
    Trailing = 128
}
export { ImGuiTableFlags as TableFlags };
export declare enum ImGuiTableFlags {
    None = 0,
    Resizable = 1,// Enable resizing columns.
    Reorderable = 2,// Enable reordering columns in header row (need calling TableSetupColumn() + TableHeadersRow() to display headers)
    Hideable = 4,// Enable hiding/disabling columns in context menu.
    Sortable = 8,// Enable sorting. Call TableGetSortSpecs() to obtain sort specs. Also see ImGuiTableFlags_SortMulti and ImGuiTableFlags_SortTristate.
    NoSavedSettings = 16,// Disable persisting columns order, width and sort settings in the .ini file.
    ContextMenuInBody = 32,// Right-click on columns body/contents will display table context menu. By default it is available in TableHeadersRow().
    RowBg = 64,// Set each RowBg color with ImGuiCol_TableRowBg or ImGuiCol_TableRowBgAlt (equivalent of calling TableSetBgColor with ImGuiTableBgFlags_RowBg0 on each row manually)
    BordersInnerH = 128,// Draw horizontal borders between rows.
    BordersOuterH = 256,// Draw horizontal borders at the top and bottom.
    BordersInnerV = 512,// Draw vertical borders between columns.
    BordersOuterV = 1024,// Draw vertical borders on the left and right sides.
    BordersH = 384,// Draw horizontal borders.
    BordersV = 1536,// Draw vertical borders.
    BordersInner = 640,// Draw inner borders.
    BordersOuter = 1280,// Draw outer borders.
    Borders = 1920,// Draw all borders.
    NoBordersInBody = 2048,// [ALPHA] Disable vertical borders in columns Body (borders will always appears in Headers). -> May move to style
    NoBordersInBodyUntilResize = 4096,// [ALPHA] Disable vertical borders in columns Body until hovered for resize (borders will always appears in Headers). -> May move to style
    SizingFixedFit = 8192,// Columns default to _WidthFixed or _WidthAuto (if resizable or not resizable), matching contents width.
    SizingFixedSame = 16384,// Columns default to _WidthFixed or _WidthAuto (if resizable or not resizable), matching the maximum contents width of all columns. Implicitly enable ImGuiTableFlags_NoKeepColumnsVisible.
    SizingStretchProp = 24576,// Columns default to _WidthStretch with default weights proportional to each columns contents widths.
    SizingStretchSame = 32768,// Columns default to _WidthStretch with default weights all equal, unless overriden by TableSetupColumn().
    NoHostExtendX = 65536,// Make outer width auto-fit to columns, overriding outer_size.x value. Only available when ScrollX/ScrollY are disabled and Stretch columns are not used.
    NoHostExtendY = 131072,// Make outer height stop exactly at outer_size.y (prevent auto-extending table past the limit). Only available when ScrollX/ScrollY are disabled. Data below the limit will be clipped and not visible.
    NoKeepColumnsVisible = 262144,// Disable keeping column always minimally visible when ScrollX is off and table gets too small. Not recommended if columns are resizable.
    PreciseWidths = 524288,// Disable distributing remainder width to stretched columns (width allocation on a 100-wide table with 3 columns: Without this flag: 33,33,34. With this flag: 33,33,33). With larger number of columns, resizing will appear to be less smooth.
    NoClip = 1048576,// Disable clipping rectangle for every individual columns (reduce draw command count, items will be able to overflow into other columns). Generally incompatible with TableSetupScrollFreeze().
    PadOuterX = 2097152,// Default if BordersOuterV is on. Enable outer-most padding. Generally desirable if you have headers.
    NoPadOuterX = 4194304,// Default if BordersOuterV is off. Disable outer-most padding.
    NoPadInnerX = 8388608,// Disable inner padding between columns (double inner padding if BordersOuterV is on, single inner padding if BordersOuterV is off).
    ScrollX = 16777216,// Enable horizontal scrolling. Require 'outer_size' parameter of BeginTable() to specify the container size. Changes default sizing policy. Because this create a child window, ScrollY is currently generally recommended when using ScrollX.
    ScrollY = 33554432,// Enable vertical scrolling. Require 'outer_size' parameter of BeginTable() to specify the container size.
    SortMulti = 67108864,// Hold shift when clicking headers to sort on multiple column. TableGetSortSpecs() may return specs where (SpecsCount > 1).
    SortTristate = 134217728,// Allow no sorting, disable default sorting. TableGetSortSpecs() may return specs where (SpecsCount == 0).
    SizingMask_ = 57344
}
export { ImGuiTableColumnFlags as TableColumnFlags };
export declare enum ImGuiTableColumnFlags {
    None = 0,
    DefaultHide = 1,// Default as a hidden/disabled column.
    DefaultSort = 2,// Default as a sorting column.
    WidthStretch = 4,// Column will stretch. Preferable with horizontal scrolling disabled (default if table sizing policy is _SizingStretchSame or _SizingStretchProp).
    WidthFixed = 8,// Column will not stretch. Preferable with horizontal scrolling enabled (default if table sizing policy is _SizingFixedFit and table is resizable).
    NoResize = 16,// Disable manual resizing.
    NoReorder = 32,// Disable manual reordering this column, this will also prevent other columns from crossing over this column.
    NoHide = 64,// Disable ability to hide/disable this column.
    NoClip = 128,// Disable clipping for this column (all NoClip columns will render in a same draw command).
    NoSort = 256,// Disable ability to sort on this field (even if ImGuiTableFlags_Sortable is set on the table).
    NoSortAscending = 512,// Disable ability to sort in the ascending direction.
    NoSortDescending = 1024,// Disable ability to sort in the descending direction.
    NoHeaderWidth = 2048,// Disable header text width contribution to automatic column width.
    PreferSortAscending = 4096,// Make the initial sort direction Ascending when first sorting on this column (default).
    PreferSortDescending = 8192,// Make the initial sort direction Descending when first sorting on this column.
    IndentEnable = 16384,// Use current Indent value when entering cell (default for column 0).
    IndentDisable = 32768,// Ignore current Indent value when entering cell (default for columns > 0). Indentation changes _within_ the cell will still be honored.
    IsEnabled = 1048576,// Status: is enabled == not hidden by user/api (referred to as "Hide" in _DefaultHide and _NoHide) flags.
    IsVisible = 2097152,// Status: is visible == is enabled AND not clipped by scrolling.
    IsSorted = 4194304,// Status: is currently part of the sort specs
    IsHovered = 8388608,// Status: is hovered by mouse
    WidthMask_ = 12,
    IndentMask_ = 49152,
    StatusMask_ = 15728640,
    NoDirectResize_ = 1073741824
}
export { ImGuiTableRowFlags as TableRowFlags };
export declare enum ImGuiTableRowFlags {
    None = 0,
    Headers = 1
}
export { ImGuiTableBgTarget as TableBgTarget };
export declare enum ImGuiTableBgTarget {
    None = 0,
    RowBg0 = 1,// Set row background color 0 (generally used for background, automatically set when ImGuiTableFlags_RowBg is used)
    RowBg1 = 2,// Set row background color 1 (generally used for selection marking)
    CellBg = 3
}
export { ImGuiFocusedFlags as FocusedFlags };
export declare enum ImGuiFocusedFlags {
    None = 0,
    ChildWindows = 1,// IsWindowFocused(): Return true if any children of the window is focused
    RootWindow = 2,// IsWindowFocused(): Test from root window (top most parent of the current hierarchy)
    AnyWindow = 4,// IsWindowFocused(): Return true if any window is focused
    RootAndChildWindows = 3
}
export { ImGuiHoveredFlags as HoveredFlags };
export declare enum ImGuiHoveredFlags {
    None = 0,// Return true if directly over the item/window, not obstructed by another window, not obstructed by an active popup or modal blocking inputs under them.
    ChildWindows = 1,// IsWindowHovered() only: Return true if any children of the window is hovered
    RootWindow = 2,// IsWindowHovered() only: Test from root window (top most parent of the current hierarchy)
    AnyWindow = 4,// IsWindowHovered() only: Return true if any window is hovered
    AllowWhenBlockedByPopup = 8,// Return true even if a popup window is normally blocking access to this item/window
    AllowWhenBlockedByActiveItem = 32,// Return true even if an active item is blocking access to this item/window. Useful for Drag and Drop patterns.
    AllowWhenOverlapped = 64,// Return true even if the position is overlapped by another window
    AllowWhenDisabled = 128,// Return true even if the item is disabled
    RectOnly = 104,
    RootAndChildWindows = 3
}
export { ImGuiDragDropFlags as DragDropFlags };
export declare enum ImGuiDragDropFlags {
    None = 0,
    SourceNoPreviewTooltip = 1,// By default, a successful call to BeginDragDropSource opens a tooltip so you can display a preview or description of the source contents. This flag disable this behavior.
    SourceNoDisableHover = 2,// By default, when dragging we clear data so that IsItemHovered() will return true, to avoid subsequent user code submitting tooltips. This flag disable this behavior so you can still call IsItemHovered() on the source item.
    SourceNoHoldToOpenOthers = 4,// Disable the behavior that allows to open tree nodes and collapsing header by holding over them while dragging a source item.
    SourceAllowNullID = 8,// Allow items such as Text(), Image() that have no unique identifier to be used as drag source, by manufacturing a temporary identifier based on their window-relative position. This is extremely unusual within the dear imgui ecosystem and so we made it explicit.
    SourceExtern = 16,// External source (from outside of imgui), won't attempt to read current item/window info. Will always return true. Only one Extern source can be active simultaneously.
    SourceAutoExpirePayload = 32,// Automatically expire the payload if the source cease to be submitted (otherwise payloads are persisting while being dragged)
    AcceptBeforeDelivery = 1024,// AcceptDragDropPayload() will returns true even before the mouse button is released. You can then call IsDelivery() to test if the payload needs to be delivered.
    AcceptNoDrawDefaultRect = 2048,// Do not draw the default highlight rectangle when hovering over target.
    AcceptNoPreviewTooltip = 4096,// Request hiding the BeginDragDropSource tooltip from the BeginDragDropTarget site.
    AcceptPeekOnly = 3072
}
export declare const IMGUI_PAYLOAD_TYPE_COLOR_3F: string;
export declare const IMGUI_PAYLOAD_TYPE_COLOR_4F: string;
export { ImGuiDataType as DataType };
export declare enum ImGuiDataType {
    S8 = 0,// char
    U8 = 1,// unsigned char
    S16 = 2,// short
    U16 = 3,// unsigned short
    S32 = 4,// int
    U32 = 5,// unsigned int
    S64 = 6,// long long, __int64
    U64 = 7,// unsigned long long, unsigned __int64
    Float = 8,// float
    Double = 9,// double
    COUNT = 10
}
export { ImGuiDir as Dir };
export declare enum ImGuiDir {
    None = -1,
    Left = 0,
    Right = 1,
    Up = 2,
    Down = 3,
    COUNT = 4
}
export { ImGuiSortDirection as SortDirection };
export declare enum ImGuiSortDirection {
    None = 0,
    Ascending = 1,// Ascending = 0->9, A->Z etc.
    Descending = 2
}
export { ImGuiKey as Key };
export declare enum ImGuiKey {
    Tab = 0,
    LeftArrow = 1,
    RightArrow = 2,
    UpArrow = 3,
    DownArrow = 4,
    PageUp = 5,
    PageDown = 6,
    Home = 7,
    End = 8,
    Insert = 9,
    Delete = 10,
    Backspace = 11,
    Space = 12,
    Enter = 13,
    Escape = 14,
    KeyPadEnter = 15,
    A = 16,// for text edit CTRL+A: select all
    C = 17,// for text edit CTRL+C: copy
    V = 18,// for text edit CTRL+V: paste
    X = 19,// for text edit CTRL+X: cut
    Y = 20,// for text edit CTRL+Y: redo
    Z = 21,// for text edit CTRL+Z: undo
    COUNT = 22
}
export { ImGuiKeyModFlags as KeyModFlags };
export declare enum ImGuiKeyModFlags {
    None = 0,
    Ctrl = 1,
    Shift = 2,
    Alt = 4,
    Super = 8
}
export { ImGuiNavInput as NavInput };
export declare enum ImGuiNavInput {
    Activate = 0,// activate / open / toggle / tweak value       // e.g. Circle (PS4), A (Xbox), B (Switch), Space (Keyboard)
    Cancel = 1,// cancel / close / exit                        // e.g. Cross  (PS4), B (Xbox), A (Switch), Escape (Keyboard)
    Input = 2,// text input / on-screen keyboard              // e.g. Triang.(PS4), Y (Xbox), X (Switch), Return (Keyboard)
    Menu = 3,// tap: toggle menu / hold: focus, move, resize // e.g. Square (PS4), X (Xbox), Y (Switch), Alt (Keyboard)
    DpadLeft = 4,// move / tweak / resize window (w/ PadMenu)    // e.g. D-pad Left/Right/Up/Down (Gamepads), Arrow keys (Keyboard)
    DpadRight = 5,//
    DpadUp = 6,//
    DpadDown = 7,//
    LStickLeft = 8,// scroll / move window (w/ PadMenu)            // e.g. Left Analog Stick Left/Right/Up/Down
    LStickRight = 9,//
    LStickUp = 10,//
    LStickDown = 11,//
    FocusPrev = 12,// next window (w/ PadMenu)                     // e.g. L1 or L2 (PS4), LB or LT (Xbox), L or ZL (Switch)
    FocusNext = 13,// prev window (w/ PadMenu)                     // e.g. R1 or R2 (PS4), RB or RT (Xbox), R or ZL (Switch)
    TweakSlow = 14,// slower tweaks                                // e.g. L1 or L2 (PS4), LB or LT (Xbox), L or ZL (Switch)
    TweakFast = 15,// faster tweaks                                // e.g. R1 or R2 (PS4), RB or RT (Xbox), R or ZL (Switch)
    KeyMenu_ = 16,// toggle menu                                  // = io.KeyAlt
    KeyLeft_ = 17,// move left                                    // = Arrow keys
    KeyRight_ = 18,// move right
    KeyUp_ = 19,// move up
    KeyDown_ = 20,// move down
    COUNT = 21,
    InternalStart_ = 16
}
export { ImGuiConfigFlags as ConfigFlags };
export declare enum ImGuiConfigFlags {
    None = 0,
    NavEnableKeyboard = 1,// Master keyboard navigation enable flag. NewFrame() will automatically fill io.NavInputs[] based on io.KeyDown[].
    NavEnableGamepad = 2,// Master gamepad navigation enable flag. This is mostly to instruct your imgui back-end to fill io.NavInputs[].
    NavEnableSetMousePos = 4,// Request navigation to allow moving the mouse cursor. May be useful on TV/console systems where moving a virtual mouse is awkward. Will update io.MousePos and set io.WantMoveMouse=true. If enabled you MUST honor io.WantMoveMouse requests in your binding, otherwise ImGui will react as if the mouse is jumping around back and forth.
    NavNoCaptureKeyboard = 8,// Do not set the io.WantCaptureKeyboard flag with io.NavActive is set.
    NoMouse = 16,// Instruct imgui to clear mouse position/buttons in NewFrame(). This allows ignoring the mouse information back-end
    NoMouseCursorChange = 32,// Instruct back-end to not alter mouse cursor shape and visibility.
    IsSRGB = 1048576,// Application is SRGB-aware.
    IsTouchScreen = 2097152
}
export { ImGuiCol as Col };
export declare enum ImGuiCol {
    Text = 0,
    TextDisabled = 1,
    WindowBg = 2,// Background of normal windows
    ChildBg = 3,// Background of child windows
    PopupBg = 4,// Background of popups, menus, tooltips windows
    Border = 5,
    BorderShadow = 6,
    FrameBg = 7,// Background of checkbox, radio button, plot, slider, text input
    FrameBgHovered = 8,
    FrameBgActive = 9,
    TitleBg = 10,
    TitleBgActive = 11,
    TitleBgCollapsed = 12,
    MenuBarBg = 13,
    ScrollbarBg = 14,
    ScrollbarGrab = 15,
    ScrollbarGrabHovered = 16,
    ScrollbarGrabActive = 17,
    CheckMark = 18,
    SliderGrab = 19,
    SliderGrabActive = 20,
    Button = 21,
    ButtonHovered = 22,
    ButtonActive = 23,
    Header = 24,
    HeaderHovered = 25,
    HeaderActive = 26,
    Separator = 27,
    SeparatorHovered = 28,
    SeparatorActive = 29,
    ResizeGrip = 30,
    ResizeGripHovered = 31,
    ResizeGripActive = 32,
    Tab = 33,
    TabHovered = 34,
    TabActive = 35,
    TabUnfocused = 36,
    TabUnfocusedActive = 37,
    PlotLines = 38,
    PlotLinesHovered = 39,
    PlotHistogram = 40,
    PlotHistogramHovered = 41,
    TableHeaderBg = 42,// Table header background
    TableBorderStrong = 43,// Table outer and header borders (prefer using Alpha=1.0 here)
    TableBorderLight = 44,// Table inner borders (prefer using Alpha=1.0 here)
    TableRowBg = 45,// Table row background (even rows)
    TableRowBgAlt = 46,// Table row background (odd rows)
    TextSelectedBg = 47,
    DragDropTarget = 48,
    NavHighlight = 49,// Gamepad/keyboard: current highlighted item
    NavWindowingHighlight = 50,// Highlight window when using CTRL+TAB
    NavWindowingDimBg = 51,// Darken/colorize entire screen behind the CTRL+TAB window list, when active
    ModalWindowDimBg = 52,// Darken/colorize entire screen behind a modal window, when one is active
    COUNT = 53
}
export { ImGuiStyleVar as StyleVar };
export declare enum ImGuiStyleVar {
    Alpha = 0,// float     Alpha
    WindowPadding = 1,// ImVec2    WindowPadding
    WindowRounding = 2,// float     WindowRounding
    WindowBorderSize = 3,// float     WindowBorderSize
    WindowMinSize = 4,// ImVec2    WindowMinSize
    WindowTitleAlign = 5,// ImVec2    WindowTitleAlign
    ChildRounding = 6,// float     ChildRounding
    ChildBorderSize = 7,// float     ChildBorderSize
    PopupRounding = 8,// float     PopupRounding
    PopupBorderSize = 9,// float     PopupBorderSize
    FramePadding = 10,// ImVec2    FramePadding
    FrameRounding = 11,// float     FrameRounding
    FrameBorderSize = 12,// float     FrameBorderSize
    ItemSpacing = 13,// ImVec2    ItemSpacing
    ItemInnerSpacing = 14,// ImVec2    ItemInnerSpacing
    IndentSpacing = 15,// float     IndentSpacing
    CellPadding = 16,// ImVec2    CellPadding
    ScrollbarSize = 17,// float     ScrollbarSize
    ScrollbarRounding = 18,// float     ScrollbarRounding
    GrabMinSize = 19,// float     GrabMinSize
    GrabRounding = 20,// float     GrabRounding
    TabRounding = 21,// float     TabRounding
    ButtonTextAlign = 22,// ImVec2    ButtonTextAlign
    SelectableTextAlign = 23,// ImVec2    SelectableTextAlign
    COUNT = 24
}
export { ImGuiBackendFlags as BackendFlags };
export declare enum ImGuiBackendFlags {
    None = 0,
    HasGamepad = 1,// Back-end has a connected gamepad.
    HasMouseCursors = 2,// Back-end can honor GetMouseCursor() values and change the OS cursor shape.
    HasSetMousePos = 4,// Back-end can honor io.WantSetMousePos and reposition the mouse (only used if ImGuiConfigFlags_NavEnableSetMousePos is set).
    RendererHasVtxOffset = 8
}
export { ImGuiButtonFlags as ButtonFlags };
export declare enum ImGuiButtonFlags {
    None = 0,
    MouseButtonLeft = 1,// React on left mouse button (default)
    MouseButtonRight = 2,// React on right mouse button
    MouseButtonMiddle = 4,// React on center mouse button
    MouseButtonMask_ = 7,
    MouseButtonDefault_ = 1
}
export { ImGuiColorEditFlags as ColorEditFlags };
export declare enum ImGuiColorEditFlags {
    None = 0,
    NoAlpha = 2,//              // ColorEdit, ColorPicker, ColorButton: ignore Alpha component (read 3 components from the input pointer).
    NoPicker = 4,//              // ColorEdit: disable picker when clicking on colored square.
    NoOptions = 8,//              // ColorEdit: disable toggling options menu when right-clicking on inputs/small preview.
    NoSmallPreview = 16,//              // ColorEdit, ColorPicker: disable colored square preview next to the inputs. (e.g. to show only the inputs)
    NoInputs = 32,//              // ColorEdit, ColorPicker: disable inputs sliders/text widgets (e.g. to show only the small preview colored square).
    NoTooltip = 64,//              // ColorEdit, ColorPicker, ColorButton: disable tooltip when hovering the preview.
    NoLabel = 128,//              // ColorEdit, ColorPicker: disable display of inline text label (the label is still forwarded to the tooltip and picker).
    NoSidePreview = 256,//              // ColorPicker: disable bigger color preview on right side of the picker, use small colored square preview instead.
    NoDragDrop = 512,//              // ColorEdit: disable drag and drop target. ColorButton: disable drag and drop source.
    NoBorder = 1024,//              // ColorButton: disable border (which is enforced by default)
    AlphaBar = 65536,//              // ColorEdit, ColorPicker: show vertical alpha bar/gradient in picker.
    AlphaPreview = 131072,//              // ColorEdit, ColorPicker, ColorButton: display preview as a transparent color over a checkerboard, instead of opaque.
    AlphaPreviewHalf = 262144,//              // ColorEdit, ColorPicker, ColorButton: display half opaque / half checkerboard, instead of opaque.
    HDR = 524288,//              // (WIP) ColorEdit: Currently only disable 0.0f..1.0f limits in RGBA edition (note: you probably want to use Float flag as well).
    DisplayRGB = 1048576,// [Inputs]     // ColorEdit: choose one among RGB/HSV/HEX. ColorPicker: choose any combination using RGB/HSV/HEX.
    DisplayHSV = 2097152,// [Inputs]     // "
    DisplayHex = 4194304,// [Inputs]     // "
    Uint8 = 8388608,// [DataType]   // ColorEdit, ColorPicker, ColorButton: _display_ values formatted as 0..255.
    Float = 16777216,// [DataType]   // ColorEdit, ColorPicker, ColorButton: _display_ values formatted as 0.0f..1.0f floats instead of 0..255 integers. No round-trip of value via integers.
    PickerHueBar = 33554432,// [PickerMode] // ColorPicker: bar for Hue, rectangle for Sat/Value.
    PickerHueWheel = 67108864,// [PickerMode] // ColorPicker: wheel for Hue, triangle for Sat/Value.
    InputRGB = 134217728,// [Input]      // ColorEdit, ColorPicker: input and output data in RGB format.
    InputHSV = 268435456,// [Input]      // ColorEdit, ColorPicker: input and output data in HSV format.
    _OptionsDefault = 177209344,
    _DisplayMask = 7340032,
    _DataTypeMask = 25165824,
    _PickerMask = 100663296,
    _InputMask = 402653184
}
export { ImGuiSliderFlags as SliderFlags };
export declare enum ImGuiSliderFlags {
    None = 0,
    AlwaysClamp = 16,// Clamp value to min/max bounds when input manually with CTRL+Click. By default CTRL+Click allows going out of bounds.
    Logarithmic = 32,// Make the widget logarithmic (linear otherwise). Consider using ImGuiSliderFlags_NoRoundToFormat with this if using a format-string with small amount of digits.
    NoRoundToFormat = 64,// Disable rounding underlying value to match precision of the display format string (e.g. %.3f values are rounded to those 3 digits)
    NoInput = 128,// Disable CTRL+Click or Enter key allowing to input text directly into the widget
    InvalidMask_ = 1879048207
}
export { ImGuiMouseButton as MouseButton };
export declare enum ImGuiMouseButton {
    Left = 0,
    Right = 1,
    Middle = 2,
    COUNT = 5
}
export { ImGuiMouseCursor as MouseCursor };
export declare enum ImGuiMouseCursor {
    None = -1,
    Arrow = 0,
    TextInput = 1,// When hovering over InputText, etc.
    ResizeAll = 2,// (Unused by imgui functions)
    ResizeNS = 3,// When hovering over an horizontal border
    ResizeEW = 4,// When hovering over a vertical border or a column
    ResizeNESW = 5,// When hovering over the bottom-left corner of a window
    ResizeNWSE = 6,// When hovering over the bottom-right corner of a window
    Hand = 7,// (Unused by imgui functions. Use for e.g. hyperlinks)
    NotAllowed = 8,// When hovering something with disallowed interaction. Usually a crossed circle.
    COUNT = 9
}
export { ImGuiCond as Cond };
export declare enum ImGuiCond {
    None = 0,// No condition (always set the variable), same as _Always
    Always = 1,// Set the variable
    Once = 2,// Set the variable once per runtime session (only the first call with succeed)
    FirstUseEver = 4,// Set the variable if the window has no saved data (if doesn't exist in the .ini file)
    Appearing = 8
}
export { ImDrawCornerFlags as DrawCornerFlags };
export declare enum ImDrawCornerFlags {
    None = 0,
    TopLeft = 1,// 0x1
    TopRight = 2,// 0x2
    BotLeft = 4,// 0x4
    BotRight = 8,// 0x8
    Top = 3,// 0x3
    Bot = 12,// 0xC
    Left = 5,// 0x5
    Right = 10,// 0xA
    All = 15
}
export { ImDrawListFlags as wListFlags };
export declare enum ImDrawListFlags {
    None = 0,
    AntiAliasedLines = 1,
    AntiAliasedLinesUseTex = 2,// Enable anti-aliased lines/borders using textures when possible. Require backend to render with bilinear filtering.
    AntiAliasedFill = 4,// Enable anti-aliased edge around filled shapes (rounded rectangles, circles).
    AllowVtxOffset = 8
}
export { ImU32 as U32 };
export type ImU32 = Bind.ImU32;
export { interface_ImVec2 } from "./bind-imgui";
export { reference_ImVec2 } from "./bind-imgui";
export { ImVec2 as Vec2 };
export declare class ImVec2 implements Bind.interface_ImVec2 {
    x: number;
    y: number;
    static readonly ZERO: Readonly<ImVec2>;
    static readonly UNIT: Readonly<ImVec2>;
    static readonly UNIT_X: Readonly<ImVec2>;
    static readonly UNIT_Y: Readonly<ImVec2>;
    constructor(x?: number, y?: number);
    Set?(x: number, y: number): this;
    Copy?(other: Readonly<Bind.interface_ImVec2>): this;
    Equals?(other: Readonly<Bind.interface_ImVec2>): boolean;
}
export { interface_ImVec4 } from "./bind-imgui";
export { reference_ImVec4 } from "./bind-imgui";
export { ImVec4 as Vec4 };
export declare class ImVec4 implements Bind.interface_ImVec4 {
    x: number;
    y: number;
    z: number;
    w: number;
    static readonly ZERO: Readonly<ImVec4>;
    static readonly UNIT: Readonly<ImVec4>;
    static readonly UNIT_X: Readonly<ImVec4>;
    static readonly UNIT_Y: Readonly<ImVec4>;
    static readonly UNIT_Z: Readonly<ImVec4>;
    static readonly UNIT_W: Readonly<ImVec4>;
    static readonly BLACK: Readonly<ImVec4>;
    static readonly WHITE: Readonly<ImVec4>;
    constructor(x?: number, y?: number, z?: number, w?: number);
    Set?(x: number, y: number, z: number, w: number): this;
    Copy?(other: Readonly<Bind.interface_ImVec4>): this;
    Equals?(other: Readonly<Bind.interface_ImVec4>): boolean;
}
export { interface_ImMat2 } from "./bind-imgui";
export { reference_ImMat2 } from "./bind-imgui";
export declare class ImMat2 implements Bind.interface_ImMat2 {
    m11: number;
    m12: number;
    m21: number;
    m22: number;
    static readonly IDENTITY: Readonly<ImMat2>;
    constructor(m11?: number, m12?: number, m21?: number, m22?: number);
    Set?(m11: number, m12: number, m21: number, m22: number): this;
    Copy?(other: Readonly<Bind.interface_ImMat2>): this;
    Equals?(other: Readonly<Bind.interface_ImMat2>): boolean;
    Identity(): void;
    Transpose(): ImMat2;
    SetRotate(radius: number): this;
    Multiply(other: Readonly<Bind.interface_ImMat2>): Bind.interface_ImMat2;
    Transform(p: Readonly<Bind.interface_ImVec2>): Bind.interface_ImVec2;
    TransposeTo(target: ImMat2): void;
    MultiplyTo(other: Readonly<Bind.interface_ImMat2>, target: ImMat2): void;
    TransformTo(p: Readonly<Bind.interface_ImVec2>, target: ImVec2): void;
}
export { ImTransform as Transform };
export declare class ImTransform implements Bind.interface_ImTransform {
    rotate: Bind.interface_ImMat2;
    translate: Bind.interface_ImVec2;
    scale: Bind.interface_ImVec2;
    constructor(rotate?: Bind.interface_ImMat2, translate?: Bind.interface_ImVec2, scale?: Bind.interface_ImVec2);
    Identity(): void;
    Multiply(m: Readonly<Bind.interface_ImTransform>): Bind.interface_ImTransform;
    Transform(point: Readonly<Bind.interface_ImVec2>): Bind.interface_ImVec2;
    Invert(): Bind.interface_ImTransform;
    MultiplyTo(other: ImTransform, target: ImTransform): void;
    TransformTo(point: Readonly<Bind.interface_ImVec2>, target: Bind.interface_ImVec2): void;
    InvertTo(target: Bind.interface_ImTransform): void;
}
export { interface_ImBlend } from "./bind-imgui";
export { reference_ImBlend } from "./bind-imgui";
export declare enum ImBlend_ {
    ZERO = 1,
    ONE = 2,
    SRC_COLOR = 3,
    INV_SRC_COLOR = 4,
    SRC_ALPHA = 5,
    INV_SRC_ALPHA = 6,
    DST_ALPHA = 7,
    INV_DST_ALPHA = 8,
    DST_COLOR = 9,
    INV_DST_COLOR = 10,
    SRC_ALPHA_SATURATE = 11,
    BOTH_SRC_ALPHA = 12,
    BOTH_INV_SRC_ALPHA = 13,
    BLEND_FACTOR = 14,
    INV_BLEND_FACTOR = 15
}
export { ImBlend as Blend };
export declare class ImBlend implements Bind.interface_ImBlend {
    src: number;
    dst: number;
    constructor(src?: number, dst?: number);
    static readonly ADD: Readonly<ImBlend>;
    static readonly ALPHA: Readonly<ImBlend>;
}
export { ImVector as Vector };
export declare class ImVector<T> extends Array<T> {
    get Size(): number;
    Data: T[];
    empty(): boolean;
    clear(): void;
    pop_back(): T | undefined;
    push_back(value: T): void;
    front(): T;
    back(): T;
    size(): number;
    resize(new_size: number, v?: (index: number) => T): void;
    contains(value: T): boolean;
    find_erase_unsorted(value: T): void;
}
export { IM_UNICODE_CODEPOINT_MAX as UNICODE_CODEPOINT_MAX };
export declare const IM_UNICODE_CODEPOINT_MAX: number;
export { ImGuiTextFilter as TextFilter };
export declare class ImGuiTextFilter {
    constructor(default_filter?: string);
    Draw(label?: string, width?: number): boolean;
    PassFilter(text: string, text_end?: number | null): boolean;
    Build(): void;
    Clear(): void;
    IsActive(): boolean;
    InputBuf: ImStringBuffer;
    CountGrep: number;
}
export { ImGuiTextBuffer as TextBuffer };
export declare class ImGuiTextBuffer {
    Buf: string;
    begin(): string;
    size(): number;
    clear(): void;
    append(text: string): void;
}
export declare class ImGuiStorage {
}
export { ImGuiPayload as Payload };
export interface ImGuiPayload<T> {
    Data: T;
}
export declare const IM_COL32_R_SHIFT: number;
export declare const IM_COL32_G_SHIFT: number;
export declare const IM_COL32_B_SHIFT: number;
export declare const IM_COL32_A_SHIFT: number;
export declare const IM_COL32_A_MASK: number;
export { IM_COL32 as COL32 };
export declare function IM_COL32(R: number, G: number, B: number, A?: number): number;
export declare const IM_COL32_WHITE: number;
export { IM_COL32_WHITE as COL32_WHITE };
export declare const IM_COL32_BLACK: number;
export { IM_COL32_BLACK as COL32_BLACK };
export declare const IM_COL32_BLACK_TRANS: number;
export { IM_COL32_BLACK_TRANS as COL32_BLACK_TRANS };
export { ImColor as Color };
export declare class ImColor {
    Value: ImVec4;
    constructor();
    constructor(r: number, g: number, b: number);
    constructor(r: number, g: number, b: number, a: number);
    constructor(rgba: Bind.ImU32);
    constructor(col: Readonly<Bind.interface_ImVec4>);
    toImU32(): Bind.ImU32;
    toImVec4(): ImVec4;
    SetHSV(h: number, s: number, v: number, a?: number): void;
    static HSV(h: number, s: number, v: number, a?: number): ImColor;
}
export { ImGuiInputTextDefaultSize as InputTextDefaultSize };
export declare const ImGuiInputTextDefaultSize: number;
export { ImGuiInputTextCallback as InputTextCallback };
export type ImGuiInputTextCallback<T> = (data: ImGuiInputTextCallbackData<T>) => number;
export { ImGuiInputTextCallbackData as InputTextCallbackData };
export declare class ImGuiInputTextCallbackData<T> {
    readonly native: Bind.reference_ImGuiInputTextCallbackData;
    readonly UserData: T | null;
    constructor(native: Bind.reference_ImGuiInputTextCallbackData, UserData?: T | null);
    get EventFlag(): ImGuiInputTextFlags;
    get Flags(): ImGuiInputTextFlags;
    get EventChar(): Bind.ImWchar;
    set EventChar(value: Bind.ImWchar);
    get EventKey(): ImGuiKey;
    get Buf(): string;
    set Buf(value: string);
    get BufTextLen(): number;
    set BufTextLen(value: number);
    get BufSize(): number;
    set BufDirty(value: boolean);
    get CursorPos(): number;
    set CursorPos(value: number);
    get SelectionStart(): number;
    set SelectionStart(value: number);
    get SelectionEnd(): number;
    set SelectionEnd(value: number);
    DeleteChars(pos: number, bytes_count: number): void;
    InsertChars(pos: number, text: string, text_end?: number | null): void;
    SelectAll(): void;
    ClearSelection(): void;
    HasSelection(): boolean;
}
export { ImGuiSizeCallback as SizeCallback };
export type ImGuiSizeCallback<T> = (data: ImGuiSizeCallbackData<T>) => void;
export { ImGuiSizeCallbackData as SizeCallbackData };
export declare class ImGuiSizeCallbackData<T> {
    readonly native: Bind.reference_ImGuiSizeCallbackData;
    readonly UserData: T;
    constructor(native: Bind.reference_ImGuiSizeCallbackData, UserData: T);
    get Pos(): Readonly<Bind.interface_ImVec2>;
    get CurrentSize(): Readonly<Bind.interface_ImVec2>;
    get DesiredSize(): Bind.interface_ImVec2;
}
export { ImGuiTableColumnSortSpecs as TableColumnSortSpecs };
export declare class ImGuiTableColumnSortSpecs {
    readonly native: Bind.reference_ImGuiTableColumnSortSpecs;
    constructor(native: Bind.reference_ImGuiTableColumnSortSpecs);
    get ColumnUserID(): ImGuiID;
    get ColumnIndex(): Bind.ImS16;
    get SortOrder(): Bind.ImS16;
    get SortDirection(): ImGuiSortDirection;
}
export { ImGuiTableSortSpecs as TableSortSpecs };
export declare class ImGuiTableSortSpecs {
    readonly native: Bind.reference_ImGuiTableSortSpecs;
    constructor(native: Bind.reference_ImGuiTableSortSpecs);
    private _Specs;
    get Specs(): Readonly<ImGuiTableColumnSortSpecs[]>;
    get SpecsCount(): number;
    get SpecsDirty(): boolean;
    set SpecsDirty(value: boolean);
}
export { ImGuiListClipper as ListClipper };
export declare class ImGuiListClipper {
    private _native;
    private get native();
    get DisplayStart(): number;
    get DisplayEnd(): number;
    get ItemsCount(): number;
    get StepNo(): number;
    get ItemsFrozen(): number;
    get ItemsHeight(): number;
    get StartPosY(): number;
    delete(): void;
    Begin(items_count: number, items_height?: number): void;
    End(): void;
    Step(): boolean;
}
export declare const IM_DRAWLIST_TEX_LINES_WIDTH_MAX: number;
export type ImDrawCallback = (parent_list: Readonly<ImDrawList>, cmd: Readonly<ImDrawCmd>) => void;
export declare const ImDrawCallback_ResetRenderState = -1;
export { ImDrawCmd as DrawCmd };
export declare class ImDrawCmd {
    readonly native: Bind.reference_ImDrawCmd;
    constructor(native: Bind.reference_ImDrawCmd);
    get ElemCount(): number;
    get ClipRect(): Readonly<Bind.reference_ImVec4>;
    get TextureId(): ImTextureID | null;
    get Blend(): Readonly<Bind.reference_ImBlend>;
    get VtxOffset(): number;
    get IdxOffset(): number;
    get UserCallback(): ImDrawCallback | null;
    get UserCallbackData(): any;
}
export { ImDrawIdxSize as DrawIdxSize };
export declare const ImDrawIdxSize: number;
export { ImDrawIdx as DrawIdx };
export type ImDrawIdx = number;
export { ImDrawVertSize as DrawVertSize };
export declare const ImDrawVertSize: number;
export { ImDrawVertPosOffset as DrawVertPosOffset };
export declare const ImDrawVertPosOffset: number;
export { ImDrawVertUVOffset as DrawVertUVOffset };
export declare const ImDrawVertUVOffset: number;
export { ImDrawVertColOffset as DrawVertColOffset };
export declare const ImDrawVertColOffset: number;
export { ImDrawVert as DrawVert };
export declare class ImDrawVert {
    pos: Float32Array;
    uv: Float32Array;
    col: Uint32Array;
    constructor(buffer: ArrayBuffer, byteOffset?: number);
}
export declare class ImDrawCmdHeader {
}
export declare class ImDrawChannel {
}
export declare class ImDrawListSharedData {
    readonly native: Bind.reference_ImDrawListSharedData;
    constructor(native: Bind.reference_ImDrawListSharedData);
}
export { ImDrawList as DrawList };
export declare class ImDrawList {
    readonly native: Bind.reference_ImDrawList;
    constructor(native: Bind.reference_ImDrawList);
    IterateDrawCmds(callback: (draw_cmd: ImDrawCmd, ElemStart: number) => void): void;
    get IdxBuffer(): Uint8Array;
    get VtxBuffer(): Uint8Array;
    get Flags(): ImDrawListFlags;
    set Flags(value: ImDrawListFlags);
    PushClipRect(clip_rect_min: Readonly<Bind.interface_ImVec2>, clip_rect_max: Readonly<Bind.interface_ImVec2>, intersect_with_current_clip_rect?: boolean): void;
    PushClipRectFullScreen(): void;
    PopClipRect(): void;
    PushTextureID(texture_id: ImTextureID): void;
    PopTextureID(): void;
    GetClipRectMin(out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
    GetClipRectMax(out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
    SetBlend(blend: Readonly<Bind.interface_ImBlend>): void;
    AddLine(a: Readonly<Bind.interface_ImVec2>, b: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32, thickness?: number): void;
    AddRect(a: Readonly<Bind.interface_ImVec2>, b: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32, rounding?: number, rounding_corners_flags?: ImDrawCornerFlags, thickness?: number): void;
    AddRectFilled(a: Readonly<Bind.interface_ImVec2>, b: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32, rounding?: number, rounding_corners_flags?: ImDrawCornerFlags): void;
    AddRectFilledMultiColor(a: Readonly<Bind.interface_ImVec2>, b: Readonly<Bind.interface_ImVec2>, col_upr_left: Bind.ImU32, col_upr_right: Bind.ImU32, col_bot_right: Bind.ImU32, col_bot_left: Bind.ImU32): void;
    AddQuad(a: Readonly<Bind.interface_ImVec2>, b: Readonly<Bind.interface_ImVec2>, c: Readonly<Bind.interface_ImVec2>, d: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32, thickness?: number): void;
    AddQuadFilled(a: Readonly<Bind.interface_ImVec2>, b: Readonly<Bind.interface_ImVec2>, c: Readonly<Bind.interface_ImVec2>, d: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32): void;
    AddTriangle(a: Readonly<Bind.interface_ImVec2>, b: Readonly<Bind.interface_ImVec2>, c: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32, thickness?: number): void;
    AddTriangleFilled(a: Readonly<Bind.interface_ImVec2>, b: Readonly<Bind.interface_ImVec2>, c: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32): void;
    AddCircle(centre: Readonly<Bind.interface_ImVec2>, radius: number, col: Bind.ImU32, num_segments?: number, thickness?: number): void;
    AddCircleFilled(centre: Readonly<Bind.interface_ImVec2>, radius: number, col: Bind.ImU32, num_segments?: number): void;
    AddNgon(centre: Readonly<Bind.interface_ImVec2>, radius: number, col: Bind.ImU32, num_segments: number, thickness?: number): void;
    AddNgonFilled(centre: Readonly<Bind.interface_ImVec2>, radius: number, col: Bind.ImU32, num_segments: number): void;
    AddText(pos: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32, text_begin: string, text_end?: number | null): void;
    AddText(font: ImFont, font_size: number, pos: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32, text_begin: string, text_end?: number | null, wrap_width?: number, cpu_fine_clip_rect?: Readonly<Bind.interface_ImVec4> | null): void;
    AddPolyline(points: Array<Readonly<Bind.interface_ImVec2>>, num_points: number, col: Bind.ImU32, closed: boolean, thickness: number): void;
    AddConvexPolyFilled(points: Array<Readonly<Bind.interface_ImVec2>>, num_points: number, col: Bind.ImU32): void;
    AddBezierCubic(p1: Readonly<Bind.interface_ImVec2>, p2: Readonly<Bind.interface_ImVec2>, p3: Readonly<Bind.interface_ImVec2>, p4: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32, thickness?: number, num_segments?: number): void;
    AddBezierQuadratic(p1: Readonly<Bind.interface_ImVec2>, p2: Readonly<Bind.interface_ImVec2>, p3: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32, thickness?: number, num_segments?: number): void;
    AddImage(user_texture_id: ImTextureID | null, a: Readonly<Bind.interface_ImVec2>, b: Readonly<Bind.interface_ImVec2>, uv_a?: Readonly<Bind.interface_ImVec2>, uv_b?: Readonly<Bind.interface_ImVec2>, col?: Bind.ImU32): void;
    AddImageQuad(user_texture_id: ImTextureID | null, a: Readonly<Bind.interface_ImVec2>, b: Readonly<Bind.interface_ImVec2>, c: Readonly<Bind.interface_ImVec2>, d: Readonly<Bind.interface_ImVec2>, uv_a?: Readonly<Bind.interface_ImVec2>, uv_b?: Readonly<Bind.interface_ImVec2>, uv_c?: Readonly<Bind.interface_ImVec2>, uv_d?: Readonly<Bind.interface_ImVec2>, col?: Bind.ImU32): void;
    AddImageRounded(user_texture_id: ImTextureID | null, a: Readonly<Bind.interface_ImVec2>, b: Readonly<Bind.interface_ImVec2>, uv_a: Readonly<Bind.interface_ImVec2>, uv_b: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32, rounding: number, rounding_corners?: ImDrawCornerFlags): void;
    PathClear(): void;
    PathLineTo(pos: Readonly<Bind.interface_ImVec2>): void;
    PathLineToMergeDuplicate(pos: Readonly<Bind.interface_ImVec2>): void;
    PathFillConvex(col: Bind.ImU32): void;
    PathStroke(col: Bind.ImU32, closed: boolean, thickness?: number): void;
    PathArcTo(centre: Readonly<Bind.interface_ImVec2>, radius: number, a_min: number, a_max: number, num_segments?: number): void;
    PathArcToFast(centre: Readonly<Bind.interface_ImVec2>, radius: number, a_min_of_12: number, a_max_of_12: number): void;
    PathBezierCubicCurveTo(p2: Readonly<Bind.interface_ImVec2>, p3: Readonly<Bind.interface_ImVec2>, p4: Readonly<Bind.interface_ImVec2>, num_segments?: number): void;
    PathBezierQuadraticCurveTo(p2: Readonly<Bind.interface_ImVec2>, p3: Readonly<Bind.interface_ImVec2>, num_segments?: number): void;
    PathRect(rect_min: Readonly<Bind.interface_ImVec2>, rect_max: Readonly<Bind.interface_ImVec2>, rounding?: number, rounding_corners_flags?: ImDrawCornerFlags): void;
    ChannelsSplit(channels_count: number): void;
    ChannelsMerge(): void;
    ChannelsSetCurrent(channel_index: number): void;
    AddCallback(callback: ImDrawCallback, callback_data: any): void;
    AddDrawCmd(): void;
    PrimReserve(idx_count: number, vtx_count: number): void;
    PrimUnreserve(idx_count: number, vtx_count: number): void;
    PrimRect(a: Readonly<Bind.interface_ImVec2>, b: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32): void;
    PrimRectUV(a: Readonly<Bind.interface_ImVec2>, b: Readonly<Bind.interface_ImVec2>, uv_a: Readonly<Bind.interface_ImVec2>, uv_b: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32): void;
    PrimQuadUV(a: Readonly<Bind.interface_ImVec2>, b: Readonly<Bind.interface_ImVec2>, c: Readonly<Bind.interface_ImVec2>, d: Readonly<Bind.interface_ImVec2>, uv_a: Readonly<Bind.interface_ImVec2>, uv_b: Readonly<Bind.interface_ImVec2>, uv_c: Readonly<Bind.interface_ImVec2>, uv_d: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32): void;
    PrimWriteVtx(pos: Readonly<Bind.interface_ImVec2>, uv: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32): void;
    PrimWriteIdx(idx: ImDrawIdx): void;
    PrimVtx(pos: Readonly<Bind.interface_ImVec2>, uv: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32): void;
    AddRectFilledMultiColorRound(a: Readonly<Bind.interface_ImVec2>, b: Readonly<Bind.interface_ImVec2>, col_lt: ImU32, col_rt: ImU32, col_lb: ImU32, col_rb: ImU32, rounding: number, rounding_corners_flags: ImDrawCornerFlags): void;
    GetVertexSize(): number;
    Transform(tm: Readonly<Bind.interface_ImTransform>, start: number, end?: number): void;
}
export { ImDrawData as DrawData };
export declare class ImDrawData {
    readonly native: Bind.reference_ImDrawData;
    constructor(native: Bind.reference_ImDrawData);
    IterateDrawLists(callback: (draw_list: ImDrawList) => void): void;
    get Valid(): boolean;
    get CmdListsCount(): number;
    get TotalIdxCount(): number;
    get TotalVtxCount(): number;
    get DisplayPos(): Readonly<Bind.reference_ImVec2>;
    get DisplaySize(): Readonly<Bind.reference_ImVec2>;
    get FramebufferScale(): Readonly<Bind.reference_ImVec2>;
    DeIndexAllBuffers(): void;
    ScaleClipRects(fb_scale: Readonly<Bind.interface_ImVec2>): void;
}
export declare class script_ImFontConfig implements Bind.interface_ImFontConfig {
    FontData: DataView | null;
    FontDataOwnedByAtlas: boolean;
    FontNo: number;
    SizePixels: number;
    OversampleH: number;
    OversampleV: number;
    PixelSnapH: boolean;
    GlyphExtraSpacing: ImVec2;
    GlyphOffset: ImVec2;
    GlyphRanges: number | null;
    GlyphMinAdvanceX: number;
    GlyphMaxAdvanceX: number;
    MergeMode: boolean;
    RasterizerFlags: number;
    RasterizerMultiply: number;
    EllipsisChar: number;
    Name: string;
    DstFont: Bind.reference_ImFont | null;
}
export { ImFontConfig as FontConfig };
export declare class ImFontConfig {
    readonly internal: Bind.interface_ImFontConfig;
    constructor(internal?: Bind.interface_ImFontConfig);
    get FontData(): DataView | null;
    get FontDataOwnedByAtlas(): boolean;
    get FontNo(): number;
    get SizePixels(): number;
    get OversampleH(): number;
    get OversampleV(): number;
    get PixelSnapH(): boolean;
    get GlyphExtraSpacing(): ImVec2;
    get GlyphOffset(): ImVec2;
    get GlyphRanges(): number | null;
    get GlyphMinAdvanceX(): number;
    get GlyphMaxAdvanceX(): number;
    get MergeMode(): boolean;
    get RasterizerFlags(): number;
    get RasterizerMultiply(): number;
    get Name(): string;
    set Name(value: string);
    get DstFont(): ImFont | null;
}
export declare class script_ImFontGlyph implements Bind.interface_ImFontGlyph {
    Codepoint: number;
    Visible: boolean;
    AdvanceX: number;
    X0: number;
    Y0: number;
    X1: number;
    Y1: number;
    U0: number;
    V0: number;
    U1: number;
    V1: number;
    TexID: number;
    Char: number;
}
export { ImFontGlyph as FontGlyph };
export declare class ImFontGlyph implements Bind.interface_ImFontGlyph {
    readonly internal: Bind.interface_ImFontGlyph;
    constructor(internal?: Bind.interface_ImFontGlyph);
    get Codepoint(): number;
    get Visible(): boolean;
    get AdvanceX(): number;
    set AdvanceX(v: number);
    get X0(): number;
    set X0(v: number);
    get Y0(): number;
    set Y0(v: number);
    get X1(): number;
    set X1(v: number);
    get Y1(): number;
    set Y1(v: number);
    get U0(): number;
    set U0(v: number);
    get V0(): number;
    set V0(v: number);
    get U1(): number;
    set U1(v: number);
    get V1(): number;
    set V1(v: number);
    get TexID(): number;
    get TextureID(): ImTextureID | null;
    set TextureID(v: ImTextureID | null);
    get Char(): number;
}
export declare class ImFontAtlasCustomRect {
}
export { ImFontAtlasFlags as FontAtlasFlags };
export declare enum ImFontAtlasFlags {
    None = 0,
    NoPowerOfTwoHeight = 1,// Don't round the height to next power of two
    NoMouseCursors = 2,// Don't build software mouse cursors into the atlas
    NoBakedLines = 4
}
export { ImFontAtlas as FontAtlas };
export declare class ImFontAtlas {
    readonly native: Bind.reference_ImFontAtlas;
    constructor(native: Bind.reference_ImFontAtlas);
    AddFontDefault(font_cfg?: Bind.interface_ImFontConfig | null): ImFont;
    AddFontFromMemoryTTF(data: ArrayBuffer, size_pixels: number, font_cfg?: ImFontConfig | null, glyph_ranges?: number | null): ImFont;
    ClearTexData(): void;
    ClearInputData(): void;
    ClearFonts(): void;
    Clear(): void;
    Build(): boolean;
    IsBuilt(): boolean;
    GetTexDataAsAlpha8(): {
        pixels: Uint8ClampedArray;
        width: number;
        height: number;
        bytes_per_pixel: number;
    };
    GetTexDataAsRGBA32(): {
        pixels: Uint8ClampedArray;
        width: number;
        height: number;
        bytes_per_pixel: number;
    };
    SetTexID(id: ImTextureID | null): void;
    GetGlyphRangesDefault(): number;
    GetGlyphRangesKorean(): number;
    GetGlyphRangesJapanese(): number;
    GetGlyphRangesChineseFull(): number;
    GetGlyphRangesChineseSimplifiedCommon(): number;
    GetGlyphRangesCyrillic(): number;
    GetGlyphRangesThai(): number;
    GetGlyphRangesVietnamese(): number;
    get Locked(): boolean;
    set Locked(value: boolean);
    get Flags(): ImFontAtlasFlags;
    set Flags(value: ImFontAtlasFlags);
    get TexID(): ImTextureID | null;
    set TexID(value: ImTextureID | null);
    get TexDesiredWidth(): number;
    set TexDesiredWidth(value: number);
    get TexGlyphPadding(): number;
    set TexGlyphPadding(value: number);
    get TexWidth(): number;
    get TexHeight(): number;
    get TexUvScale(): Readonly<Bind.reference_ImVec2>;
    get TexUvWhitePixel(): Readonly<Bind.reference_ImVec2>;
    get Fonts_(): ImVector<ImFont>;
    get Fonts(): ImVector<ImFont>;
    _Fonts?: ImVector<ImFont>;
    get CurrentFont(): ImFont;
}
export interface DOMFontConfig {
    name: string;
    fontsize: number;
    ascent?: number;
    descent?: number;
}
export { ImFont as Font };
export declare class ImFont {
    readonly native: Bind.reference_ImFont;
    constructor(native: Bind.reference_ImFont);
    setFont(config: DOMFontConfig): void;
    get FontStyle(): string;
    set FontStyle(v: string);
    get FontName(): string;
    set FontName(v: string);
    get FontSize(): number;
    set FontSize(v: number);
    get SpaceX(): number[];
    set SpaceX(v: number[]);
    get Scale(): number;
    set Scale(value: number);
    get Glyphs(): ImVector<ImFontGlyph>;
    get IndexAdvanceX(): number[];
    get IndexAdvanceXSize(): number;
    get NotReadyChar(): number[];
    get NotReadyCharSize(): number;
    get FallbackGlyph(): ImFontGlyph | null;
    set FallbackGlyph(value: ImFontGlyph | null);
    get FallbackAdvanceX(): number;
    get FallbackChar(): number;
    get EllipsisChar(): number;
    get ConfigDataCount(): number;
    get ConfigData(): ImFontConfig;
    get ContainerAtlas(): ImFontAtlas | null;
    get Ascent(): number;
    set Ascent(v: number);
    get Descent(): number;
    set Descent(v: number);
    get MetricsTotalSurface(): number;
    ClearOutputData(): void;
    BuildLookupTable(): void;
    FindGlyph(c: number): Readonly<ImFontGlyph> | null;
    FindGlyphNoFallback(c: number): ImFontGlyph | null;
    SetFallbackChar(c: number): void;
    GetCharAdvance(c: number): number;
    IsLoaded(): boolean;
    GetDebugName(): string;
    CalcTextSizeA(size: number, max_width: number, wrap_width: number, text_begin: string, text_end?: number | null, remaining?: Bind.ImScalar<number> | null, isready?: Bind.ImScalar<boolean> | null): Bind.interface_ImVec2;
    CalcWordWrapPositionA(scale: number, text: string, text_end: number | null, wrap_width: number): number;
    RenderChar(draw_list: ImDrawList, size: number, pos: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32, c: Bind.ImWchar): void;
    RenderText(draw_list: ImDrawList, size: number, pos: Readonly<Bind.interface_ImVec2>, col: Bind.ImU32, clip_rect: Readonly<Bind.interface_ImVec4>, text_begin: string, text_end?: number | null, wrap_width?: number, cpu_fine_clip?: boolean): void;
    IsGlyphRangeUnused(c_begin: number, c_last: number): boolean;
    get GlyphToCreate(): ImFontGlyph | null;
    get IterateGlyphToCreate(): ImFontGlyph[];
    GlyphCreated(glyph: ImFontGlyph): void;
    ClearGlyphCreated(): void;
    CreateGlyph(text: string): void;
    AddFontRange(start: number, end: number): void;
    ClearFontRange(): void;
    MergeFont(font: ImFont): void;
    ClearSubFont(): void;
    InRange(c: number): boolean;
    GetAdvanceX(c: number): number;
    GetNotReadyChar(i: number): number;
}
export { ImGuiStyle as Style };
export declare class ImGuiStyle {
    readonly internal: Bind.interface_ImGuiStyle;
    constructor(internal?: Bind.interface_ImGuiStyle);
    get Alpha(): number;
    set Alpha(value: number);
    get WindowPadding(): Bind.interface_ImVec2;
    get WindowRounding(): number;
    set WindowRounding(value: number);
    get WindowBorderSize(): number;
    set WindowBorderSize(value: number);
    get WindowMinSize(): Bind.interface_ImVec2;
    get WindowTitleAlign(): Bind.interface_ImVec2;
    get WindowMenuButtonPosition(): ImGuiDir;
    set WindowMenuButtonPosition(value: ImGuiDir);
    get ChildRounding(): number;
    set ChildRounding(value: number);
    get ChildBorderSize(): number;
    set ChildBorderSize(value: number);
    get PopupRounding(): number;
    set PopupRounding(value: number);
    get PopupBorderSize(): number;
    set PopupBorderSize(value: number);
    get FramePadding(): Bind.interface_ImVec2;
    get FrameRounding(): number;
    set FrameRounding(value: number);
    get FrameBorderSize(): number;
    set FrameBorderSize(value: number);
    get ItemSpacing(): Bind.interface_ImVec2;
    get ItemInnerSpacing(): Bind.interface_ImVec2;
    get CellPadding(): Bind.interface_ImVec2;
    get TouchExtraPadding(): Bind.interface_ImVec2;
    get IndentSpacing(): number;
    set IndentSpacing(value: number);
    get ColumnsMinSpacing(): number;
    set ColumnsMinSpacing(value: number);
    get ScrollbarSize(): number;
    set ScrollbarSize(value: number);
    get ScrollbarRounding(): number;
    set ScrollbarRounding(value: number);
    get GrabMinSize(): number;
    set GrabMinSize(value: number);
    get GrabRounding(): number;
    set GrabRounding(value: number);
    get LogSliderDeadzone(): number;
    set LogSliderDeadzone(value: number);
    get TabRounding(): number;
    set TabRounding(value: number);
    get TabBorderSize(): number;
    set TabBorderSize(value: number);
    get TabMinWidthForCloseButton(): number;
    set TabMinWidthForCloseButton(value: number);
    get ColorButtonPosition(): number;
    set ColorButtonPosition(value: number);
    get ButtonTextAlign(): Bind.interface_ImVec2;
    get SelectableTextAlign(): Bind.interface_ImVec2;
    get DisplayWindowPadding(): Bind.interface_ImVec2;
    get DisplaySafeAreaPadding(): Bind.interface_ImVec2;
    get MouseCursorScale(): number;
    set MouseCursorScale(value: number);
    get AntiAliasedLines(): boolean;
    set AntiAliasedLines(value: boolean);
    get AntiAliasedLinesUseTex(): boolean;
    set AntiAliasedLinesUseTex(value: boolean);
    get AntiAliasedFill(): boolean;
    set AntiAliasedFill(value: boolean);
    get CurveTessellationTol(): number;
    set CurveTessellationTol(value: number);
    get CircleSegmentMaxError(): number;
    set CircleSegmentMaxError(value: number);
    Colors: Bind.interface_ImVec4[];
    Copy?(other: Readonly<ImGuiStyle>): this;
    ScaleAllSizes(scale_factor: number): void;
}
export { ImGuiIO as IO };
export declare class ImGuiIO {
    readonly native: Bind.reference_ImGuiIO;
    constructor(native: Bind.reference_ImGuiIO);
    get ConfigFlags(): ImGuiConfigFlags;
    set ConfigFlags(value: ImGuiConfigFlags);
    get BackendFlags(): ImGuiBackendFlags;
    set BackendFlags(value: ImGuiBackendFlags);
    get DisplaySize(): Bind.reference_ImVec2;
    get DeltaTime(): number;
    set DeltaTime(value: number);
    get IniSavingRate(): number;
    set IniSavingRate(value: number);
    get IniFilename(): string;
    set IniFilename(value: string);
    get LogFilename(): string;
    set LogFilename(value: string);
    get MouseDoubleClickTime(): number;
    set MouseDoubleClickTime(value: number);
    get MouseDoubleClickMaxDist(): number;
    set MouseDoubleClickMaxDist(value: number);
    get MouseDragThreshold(): number;
    set MouseDragThreshold(value: number);
    KeyMap: number[];
    get KeyRepeatDelay(): number;
    set KeyRepeatDelay(value: number);
    get KeyRepeatRate(): number;
    set KeyRepeatRate(value: number);
    get UserData(): any;
    set UserData(value: any);
    get Fonts(): ImFontAtlas;
    get FontGlobalScale(): number;
    set FontGlobalScale(value: number);
    get FontAllowUserScaling(): boolean;
    set FontAllowUserScaling(value: boolean);
    get FontDefault(): ImFont | null;
    set FontDefault(value: ImFont | null);
    get DisplayFramebufferScale(): Bind.reference_ImVec2;
    get ConfigMacOSXBehaviors(): boolean;
    set ConfigMacOSXBehaviors(value: boolean);
    get ConfigInputTextCursorBlink(): boolean;
    set ConfigInputTextCursorBlink(value: boolean);
    get ConfigDragClickToInputText(): boolean;
    set ConfigDragClickToInputText(value: boolean);
    get ConfigWindowsResizeFromEdges(): boolean;
    set ConfigWindowsResizeFromEdges(value: boolean);
    get ConfigWindowsMoveFromTitleBarOnly(): boolean;
    set ConfigWindowsMoveFromTitleBarOnly(value: boolean);
    get ConfigMemoryCompactTimer(): number;
    set ConfigMemoryCompactTimer(value: number);
    get BackendPlatformName(): string | null;
    set BackendPlatformName(value: string | null);
    get BackendRendererName(): string | null;
    set BackendRendererName(value: string | null);
    get BackendPlatformUserData(): string | null;
    set BackendPlatformUserData(value: string | null);
    get BackendRendererUserData(): string | null;
    set BackendRendererUserData(value: string | null);
    get BackendLanguageUserData(): string | null;
    set BackendLanguageUserData(value: string | null);
    get GetClipboardTextFn(): ((user_data: any) => string) | null;
    set GetClipboardTextFn(value: ((user_data: any) => string) | null);
    get SetClipboardTextFn(): ((user_data: any, text: string) => void) | null;
    set SetClipboardTextFn(value: ((user_data: any, text: string) => void) | null);
    get ClipboardUserData(): any;
    set ClipboardUserData(value: any);
    get MousePos(): Bind.reference_ImVec2;
    MouseDown: boolean[];
    get MouseWheel(): number;
    set MouseWheel(value: number);
    get MouseWheelH(): number;
    set MouseWheelH(value: number);
    get MouseDrawCursor(): boolean;
    set MouseDrawCursor(value: boolean);
    get KeyCtrl(): boolean;
    set KeyCtrl(value: boolean);
    get KeyShift(): boolean;
    set KeyShift(value: boolean);
    get KeyAlt(): boolean;
    set KeyAlt(value: boolean);
    get KeySuper(): boolean;
    set KeySuper(value: boolean);
    KeysDown: boolean[];
    NavInputs: number[];
    AddInputCharacter(c: number): void;
    AddInputCharacterUTF16(c: number): void;
    AddInputCharactersUTF8(utf8_chars: string): void;
    ClearInputCharacters(): void;
    get WantCaptureMouse(): boolean;
    set WantCaptureMouse(value: boolean);
    get WantCaptureKeyboard(): boolean;
    set WantCaptureKeyboard(value: boolean);
    get WantTextInput(): boolean;
    set WantTextInput(value: boolean);
    get WantSetMousePos(): boolean;
    set WantSetMousePos(value: boolean);
    get WantSaveIniSettings(): boolean;
    set WantSaveIniSettings(value: boolean);
    get NavActive(): boolean;
    set NavActive(value: boolean);
    get NavVisible(): boolean;
    set NavVisible(value: boolean);
    get Framerate(): number;
    get MetricsRenderVertices(): number;
    get MetricsRenderIndices(): number;
    get MetricsRenderWindows(): number;
    get MetricsActiveWindows(): number;
    get MetricsActiveAllocations(): number;
    get MouseDelta(): Readonly<Bind.reference_ImVec2>;
    MouseClickedPos: Array<Readonly<Bind.reference_ImVec2>>;
    MouseDownDuration: number[];
    KeysDownDuration: number[];
    NavInputsDownDuration: number[];
}
export declare class ImGuiContext {
    readonly native: Bind.WrapImGuiContext;
    static current_ctx: ImGuiContext | null;
    static getTexture(index: number): ImTextureID | null;
    static setTexture(texture: ImTextureID | null): number;
    private static textures;
    constructor(native: Bind.WrapImGuiContext);
    private _getTexture;
    private _setTexture;
}
export declare function CreateContext(shared_font_atlas?: ImFontAtlas | null): ImGuiContext | null;
export declare function DestroyContext(ctx?: ImGuiContext | null): void;
export declare function GetCurrentContext(): ImGuiContext | null;
export declare function SetCurrentContext(ctx: ImGuiContext | null): void;
export declare function GetIO(): ImGuiIO;
export declare function GetStyle(): ImGuiStyle;
export declare function NewFrame(): void;
export declare function EndFrame(): void;
export declare function Render(): void;
export declare function GetDrawData(): ImDrawData | null;
export declare function ShowDemoWindow(p_open?: Bind.ImScalar<boolean> | null): void;
export declare function ShowMetricsWindow(p_open?: Bind.ImScalar<boolean> | Bind.ImAccess<boolean> | null): void;
export declare function ShowAboutWindow(p_open?: Bind.ImScalar<boolean> | Bind.ImAccess<boolean> | null): void;
export declare function ShowStyleEditor(ref?: ImGuiStyle | null): void;
export declare function ShowStyleSelector(label: string): boolean;
export declare function ShowFontSelector(label: string): void;
export declare function ShowUserGuide(): void;
export declare function GetVersion(): string;
export declare function StyleColorsDark(dst?: ImGuiStyle | null): void;
export declare function StyleColorsLight(dst?: ImGuiStyle | null): void;
export declare function StyleColorsClassic(dst?: ImGuiStyle | null): void;
export declare function Begin(name: string, open?: Bind.ImScalar<boolean> | Bind.ImAccess<boolean> | null, flags?: ImGuiWindowFlags): boolean;
export declare function End(): void;
export declare function BeginChild(id: string | ImGuiID, size?: Readonly<Bind.interface_ImVec2>, border?: boolean, flags?: ImGuiWindowFlags): boolean;
export declare function EndChild(): void;
export declare function IsWindowAppearing(): boolean;
export declare function IsWindowCollapsed(): boolean;
export declare function IsWindowFocused(flags?: ImGuiFocusedFlags): boolean;
export declare function IsWindowHovered(flags?: ImGuiHoveredFlags): boolean;
export declare function GetWindowDrawList(): ImDrawList;
export declare function GetWindowPos(out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
export declare function GetWindowSize(out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
export declare function GetWindowWidth(): number;
export declare function GetWindowHeight(): number;
export declare function SetNextWindowPos(pos: Readonly<Bind.interface_ImVec2>, cond?: ImGuiCond, pivot?: Readonly<Bind.interface_ImVec2>): void;
export declare function SetNextWindowSize(pos: Readonly<Bind.interface_ImVec2>, cond?: ImGuiCond): void;
export declare function SetNextWindowSizeConstraints(size_min: Readonly<Bind.interface_ImVec2>, size_max: Readonly<Bind.interface_ImVec2>): void;
export declare function SetNextWindowSizeConstraints<T>(size_min: Readonly<Bind.interface_ImVec2>, size_max: Readonly<Bind.interface_ImVec2>, custom_callback: ImGuiSizeCallback<T>, custom_callback_data?: T): void;
export declare function SetNextWindowContentSize(size: Readonly<Bind.interface_ImVec2>): void;
export declare function SetNextWindowCollapsed(collapsed: boolean, cond?: ImGuiCond): void;
export declare function SetNextWindowFocus(): void;
export declare function SetNextWindowBgAlpha(alpha: number): void;
export declare function SetWindowPos(name_or_pos: string | Readonly<Bind.interface_ImVec2>, pos_or_cond?: Readonly<Bind.interface_ImVec2> | ImGuiCond, cond?: ImGuiCond): void;
export declare function SetWindowSize(name_or_size: string | Readonly<Bind.interface_ImVec2>, size_or_cond?: Readonly<Bind.interface_ImVec2> | ImGuiCond, cond?: ImGuiCond): void;
export declare function SetWindowCollapsed(name_or_collapsed: string | boolean, collapsed_or_cond?: boolean | ImGuiCond, cond?: ImGuiCond): void;
export declare function SetWindowFocus(name?: string): void;
export declare function SetWindowFontScale(scale: number): void;
export declare function GetContentRegionAvail(out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
export declare function GetContentRegionMax(out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
export declare function GetWindowContentRegionMin(out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
export declare function GetWindowContentRegionMax(out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
export declare function GetWindowContentRegionWidth(): number;
export declare function GetScrollX(): number;
export declare function GetScrollY(): number;
export declare function SetScrollX(scroll_x: number): void;
export declare function SetScrollY(scroll_y: number): void;
export declare function GetScrollMaxX(): number;
export declare function GetScrollMaxY(): number;
export declare function SetScrollHereX(center_x_ratio?: number): void;
export declare function SetScrollHereY(center_y_ratio?: number): void;
export declare function SetScrollFromPosX(pos_x: number, center_x_ratio?: number): void;
export declare function SetScrollFromPosY(pos_y: number, center_y_ratio?: number): void;
export declare function PushFont(font: ImFont | null): void;
export declare function PopFont(): void;
export declare function PushStyleColor(idx: ImGuiCol, col: Bind.ImU32 | Readonly<Bind.interface_ImVec4> | Readonly<ImColor>): void;
export declare function PopStyleColor(count?: number): void;
export declare function PushStyleVar(idx: ImGuiStyleVar, val: number | Readonly<Bind.interface_ImVec2>): void;
export declare function PopStyleVar(count?: number): void;
export declare function PushAllowKeyboardFocus(allow_keyboard_focus: boolean): void;
export declare function PopAllowKeyboardFocus(): void;
export declare function PushButtonRepeat(repeat: boolean): void;
export declare function PopButtonRepeat(): void;
export declare function PushItemWidth(item_width: number): void;
export declare function PopItemWidth(): void;
export declare function SetNextItemWidth(item_width: number): void;
export declare function CalcItemWidth(): number;
export declare function PushTextWrapPos(wrap_pos_x?: number): void;
export declare function PopTextWrapPos(): void;
export declare function GetFont(): ImFont;
export declare function GetFontSize(): number;
export declare function GetFontTexUvWhitePixel(out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
export declare function GetColorU32(idx: ImGuiCol, alpha_mul?: number): Bind.ImU32;
export declare function GetColorU32(col: Readonly<Bind.interface_ImVec4>): Bind.ImU32;
export declare function GetColorU32(col: Bind.ImU32): Bind.ImU32;
export declare function GetStyleColorVec4(idx: ImGuiCol): Readonly<Bind.reference_ImVec4>;
export declare function Separator(): void;
export declare function SameLine(pos_x?: number, spacing_w?: number): void;
export declare function NewLine(): void;
export declare function Spacing(): void;
export declare function Dummy(size: Readonly<Bind.interface_ImVec2>): void;
export declare function Indent(indent_w?: number): void;
export declare function Unindent(indent_w?: number): void;
export declare function BeginGroup(): void;
export declare function EndGroup(): void;
export declare function GetCursorPos(out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
export declare function GetCursorPosX(): number;
export declare function GetCursorPosY(): number;
export declare function SetCursorPos(local_pos: Readonly<Bind.interface_ImVec2>): void;
export declare function SetCursorPosX(x: number): void;
export declare function SetCursorPosY(y: number): void;
export declare function GetCursorStartPos(out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
export declare function GetCursorScreenPos(out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
export declare function SetCursorScreenPos(pos: Readonly<Bind.interface_ImVec2>): void;
export declare function AlignTextToFramePadding(): void;
export declare function GetTextLineHeight(): number;
export declare function GetTextLineHeightWithSpacing(): number;
export declare function GetFrameHeight(): number;
export declare function GetFrameHeightWithSpacing(): number;
export declare function PushID(id: string | number): void;
export declare function PopID(): void;
export declare function GetID(id: string | number): ImGuiID;
export declare function TextUnformatted(text: string, text_end?: number | null): void;
export declare function Text(text: string): void;
export declare function TextColored(col: Readonly<Bind.interface_ImVec4> | Readonly<ImColor>, text: string): void;
export declare function TextDisabled(text: string): void;
export declare function TextWrapped(text: string): void;
export declare function LabelText(label: string, text: string): void;
export declare function BulletText(text: string): void;
export declare function Button(label: string, size?: Readonly<Bind.interface_ImVec2>): boolean;
export declare function SmallButton(label: string): boolean;
export declare function ArrowButton(str_id: string, dir: ImGuiDir): boolean;
export declare function InvisibleButton(str_id: string, size: Readonly<Bind.interface_ImVec2>, flags?: ImGuiButtonFlags): boolean;
export declare function Image(user_texture_id: ImTextureID | null, size: Readonly<Bind.interface_ImVec2>, uv0?: Readonly<Bind.interface_ImVec2>, uv1?: Readonly<Bind.interface_ImVec2>, tint_col?: Readonly<Bind.interface_ImVec4>, border_col?: Readonly<Bind.interface_ImVec4>): void;
export declare function ImageButton(user_texture_id: ImTextureID | null, size?: Readonly<Bind.interface_ImVec2>, uv0?: Readonly<Bind.interface_ImVec2>, uv1?: Readonly<Bind.interface_ImVec2>, frame_padding?: number, bg_col?: Readonly<Bind.interface_ImVec4>, tint_col?: Readonly<Bind.interface_ImVec4>): boolean;
export declare function Checkbox(label: string, v: Bind.ImScalar<boolean> | Bind.ImAccess<boolean>): boolean;
export declare function CheckboxFlags(label: string, flags: Bind.ImAccess<number> | Bind.ImScalar<number>, flags_value: number): boolean;
export declare function RadioButton(label: string, active: boolean): boolean;
export declare function RadioButton(label: string, v: Bind.ImAccess<number> | Bind.ImScalar<number>, v_button: number): boolean;
export declare function ProgressBar(fraction: number, size_arg?: Readonly<Bind.interface_ImVec2>, overlay?: string | null): void;
export declare function Bullet(): void;
export declare function BeginCombo(label: string, preview_value?: string | null, flags?: ImGuiComboFlags): boolean;
export declare function EndCombo(): void;
export type ComboValueGetter<T> = (data: T, idx: number, out_text: [string]) => boolean;
export declare function Combo(label: string, current_item: Bind.ImAccess<number> | Bind.ImScalar<number>, items: string[], items_count?: number, popup_max_height_in_items?: number): boolean;
export declare function Combo(label: string, current_item: Bind.ImAccess<number> | Bind.ImScalar<number>, items_separated_by_zeros: string, popup_max_height_in_items?: number): boolean;
export declare function Combo<T>(label: string, current_item: Bind.ImAccess<number> | Bind.ImScalar<number>, items_getter: ComboValueGetter<T>, data: T, items_count: number, popup_max_height_in_items?: number): boolean;
export declare function DragFloat(label: string, v: Bind.ImAccess<number> | Bind.ImScalar<number> | XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number>, v_speed?: number, v_min?: number, v_max?: number, display_format?: string | null, flags?: ImGuiSliderFlags): boolean;
export declare function DragFloat2(label: string, v: XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number> | ImVec2, v_speed?: number, v_min?: number, v_max?: number, display_format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function DragFloat3(label: string, v: XYZ | XYZW | Bind.ImTuple3<number> | Bind.ImTuple4<number>, v_speed?: number, v_min?: number, v_max?: number, display_format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function DragFloat4(label: string, v: XYZW | Bind.ImTuple4<number> | ImVec4, v_speed?: number, v_min?: number, v_max?: number, display_format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function DragFloatRange2(label: string, v_current_min: Bind.ImAccess<number> | Bind.ImScalar<number> | XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number>, v_current_max: Bind.ImAccess<number> | Bind.ImScalar<number> | XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number>, v_speed?: number, v_min?: number, v_max?: number, display_format?: string, display_format_max?: string | null, flags?: ImGuiSliderFlags): boolean;
export declare function DragInt(label: string, v: Bind.ImAccess<number> | Bind.ImScalar<number> | XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number>, v_speed?: number, v_min?: number, v_max?: number, format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function DragInt2(label: string, v: XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number>, v_speed?: number, v_min?: number, v_max?: number, format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function DragInt3(label: string, v: XYZ | XYZW | Bind.ImTuple3<number> | Bind.ImTuple4<number>, v_speed?: number, v_min?: number, v_max?: number, format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function DragInt4(label: string, v: XYZW | Bind.ImTuple4<number>, v_speed?: number, v_min?: number, v_max?: number, format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function DragIntRange2(label: string, v_current_min: Bind.ImAccess<number> | Bind.ImScalar<number> | XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number>, v_current_max: Bind.ImAccess<number> | Bind.ImScalar<number> | XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number>, v_speed?: number, v_min?: number, v_max?: number, format?: string, format_max?: string | null, flags?: ImGuiSliderFlags): boolean;
export declare function DragScalar(label: string, v: Int8Array | Uint8Array | Int16Array | Uint16Array | Int32Array | Uint32Array | Float32Array | Float64Array, v_speed: number, v_min?: number | null, v_max?: number | null, format?: string | null, flags?: ImGuiSliderFlags): boolean;
export declare function SliderFloat(label: string, v: Bind.ImAccess<number> | Bind.ImScalar<number> | XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number>, v_min: number, v_max: number, format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function SliderFloat2(label: string, v: XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number> | Bind.interface_ImVec2, v_min: number, v_max: number, format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function SliderFloat3(label: string, v: XYZ | XYZW | Bind.ImTuple3<number> | Bind.ImTuple4<number>, v_min: number, v_max: number, format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function SliderFloat4(label: string, v: XYZW | Bind.ImTuple4<number> | XYZW, v_min: number, v_max: number, format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function SliderAngle(label: string, v_rad: Bind.ImAccess<number> | Bind.ImScalar<number> | XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number>, v_degrees_min?: number, v_degrees_max?: number, format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function SliderAngle3(label: string, v_rad: XYZ | XYZW | Bind.ImTuple3<number> | Bind.ImTuple4<number>, v_degrees_min?: number, v_degrees_max?: number, format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function SliderInt(label: string, v: Bind.ImAccess<number> | Bind.ImScalar<number> | XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number>, v_min: number, v_max: number, format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function SliderInt2(label: string, v: XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number>, v_min: number, v_max: number, format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function SliderInt3(label: string, v: XYZ | XYZW | Bind.ImTuple3<number> | Bind.ImTuple4<number>, v_min: number, v_max: number, format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function SliderInt4(label: string, v: XYZW | Bind.ImTuple4<number>, v_min: number, v_max: number, format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function SliderScalar(label: string, v: Int8Array | Uint8Array | Int16Array | Uint16Array | Int32Array | Uint32Array | Float32Array | Float64Array, v_min: number, v_max: number, format?: string | null, flags?: ImGuiSliderFlags): boolean;
export declare function VSliderFloat(label: string, size: Readonly<Bind.interface_ImVec2>, v: Bind.ImAccess<number> | Bind.ImScalar<number> | XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number>, v_min: number, v_max: number, format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function VSliderInt(label: string, size: Readonly<Bind.interface_ImVec2>, v: Bind.ImAccess<number> | Bind.ImScalar<number> | XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number>, v_min: number, v_max: number, format?: string, flags?: ImGuiSliderFlags): boolean;
export declare function VSliderScalar(label: string, size: Readonly<Bind.interface_ImVec2>, data_type: ImGuiDataType, v: Bind.ImAccess<number> | Bind.ImScalar<number>, v_min: number, v_max: number, format?: string | null, flags?: ImGuiSliderFlags): boolean;
export declare function InputText<T>(label: string, buf: ImStringBuffer | Bind.ImAccess<string> | Bind.ImScalar<string>, buf_size?: number, flags?: ImGuiInputTextFlags, callback?: ImGuiInputTextCallback<T> | null, user_data?: T | null): boolean;
export declare function InputTextMultiline<T>(label: string, buf: ImStringBuffer | Bind.ImAccess<string> | Bind.ImScalar<string>, buf_size?: number, size?: Readonly<Bind.interface_ImVec2>, flags?: ImGuiInputTextFlags, callback?: ImGuiInputTextCallback<T> | null, user_data?: T | null): boolean;
export declare function InputTextWithHint<T>(label: string, hint: string, buf: ImStringBuffer | Bind.ImAccess<string> | Bind.ImScalar<string>, buf_size?: number, flags?: ImGuiInputTextFlags, callback?: ImGuiInputTextCallback<T> | null, user_data?: T | null): boolean;
export declare function InputFloat(label: string, v: Bind.ImAccess<number> | Bind.ImScalar<number> | XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number>, step?: number, step_fast?: number, format?: string, flags?: ImGuiInputTextFlags): boolean;
export declare function InputFloat2(label: string, v: XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number>, format?: string, flags?: ImGuiInputTextFlags): boolean;
export declare function InputFloat3(label: string, v: XYZ | XYZW | Bind.ImTuple3<number> | Bind.ImTuple4<number>, format?: string, flags?: ImGuiInputTextFlags): boolean;
export declare function InputFloat4(label: string, v: XYZW | Bind.ImTuple4<number>, format?: string, flags?: ImGuiInputTextFlags): boolean;
export declare function InputInt(label: string, v: Bind.ImAccess<number> | Bind.ImScalar<number> | XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number>, step?: number, step_fast?: number, flags?: ImGuiInputTextFlags): boolean;
export declare function InputInt2(label: string, v: XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number>, flags?: ImGuiInputTextFlags): boolean;
export declare function InputInt3(label: string, v: XYZ | XYZW | Bind.ImTuple3<number> | Bind.ImTuple4<number>, flags?: ImGuiInputTextFlags): boolean;
export declare function InputInt4(label: string, v: XYZW | Bind.ImTuple4<number>, flags?: ImGuiInputTextFlags): boolean;
export declare function InputDouble(label: string, v: Bind.ImAccess<number> | Bind.ImScalar<number> | XY | XYZ | XYZW | Bind.ImTuple2<number> | Bind.ImTuple3<number> | Bind.ImTuple4<number>, step?: number, step_fast?: number, format?: string, flags?: ImGuiInputTextFlags): boolean;
export declare function InputScalar(label: string, v: Int8Array | Uint8Array | Int16Array | Uint16Array | Int32Array | Uint32Array | Float32Array | Float64Array, step?: number | null, step_fast?: number | null, format?: string | null, flags?: ImGuiInputTextFlags): boolean;
export declare function ColorEdit3(label: string, col: RGB | RGBA | Bind.ImTuple3<number> | Bind.ImTuple4<number> | Bind.interface_ImVec4, flags?: ImGuiColorEditFlags): boolean;
export declare function ColorEdit4(label: string, col: RGBA | Bind.ImTuple4<number> | Bind.interface_ImVec4, flags?: ImGuiColorEditFlags): boolean;
export declare function ColorPicker3(label: string, col: RGB | RGBA | Bind.ImTuple3<number> | Bind.ImTuple4<number> | Bind.interface_ImVec4, flags?: ImGuiColorEditFlags): boolean;
export declare function ColorPicker4(label: string, col: RGBA | Bind.ImTuple4<number> | Bind.interface_ImVec4, flags?: ImGuiColorEditFlags, ref_col?: Bind.ImTuple4<number> | Bind.interface_ImVec4 | null): boolean;
export declare function ColorButton(desc_id: string, col: Readonly<Bind.interface_ImVec4>, flags?: ImGuiColorEditFlags, size?: Readonly<Bind.interface_ImVec2>): boolean;
export declare function SetColorEditOptions(flags: ImGuiColorEditFlags): void;
export declare function TreeNode(label: string): boolean;
export declare function TreeNode(label: string, fmt: string): boolean;
export declare function TreeNode(label: number, fmt: string): boolean;
export declare function TreeNodeEx(label: string, flags?: ImGuiTreeNodeFlags): boolean;
export declare function TreeNodeEx(str_id: string, flags: ImGuiTreeNodeFlags, fmt: string): boolean;
export declare function TreeNodeEx(ptr_id: number, flags: ImGuiTreeNodeFlags, fmt: string): boolean;
export declare function TreePush(str_id: string): void;
export declare function TreePush(ptr_id: number): void;
export declare function TreePop(): void;
export declare function GetTreeNodeToLabelSpacing(): number;
export declare function CollapsingHeader(label: string, flags?: ImGuiTreeNodeFlags): boolean;
export declare function CollapsingHeader(label: string, p_open: Bind.ImScalar<boolean> | Bind.ImAccess<boolean>, flags?: ImGuiTreeNodeFlags): boolean;
export declare function SetNextItemOpen(is_open: boolean, cond?: ImGuiCond): void;
export declare function Selectable(label: string, selected?: boolean, flags?: ImGuiSelectableFlags, size?: Readonly<Bind.interface_ImVec2>): boolean;
export declare function Selectable(label: string, p_selected: Bind.ImScalar<boolean> | Bind.ImAccess<boolean>, flags?: ImGuiSelectableFlags, size?: Readonly<Bind.interface_ImVec2>): boolean;
export type ListBoxItemGetter<T> = (data: T, idx: number, out_text: [string]) => boolean;
export declare function ListBox(label: string, current_item: Bind.ImAccess<number> | Bind.ImScalar<number>, items: string[], items_count?: number, height_in_items?: number): boolean;
export declare function ListBox<T>(label: string, current_item: Bind.ImAccess<number> | Bind.ImScalar<number>, items_getter: ListBoxItemGetter<T>, data: T, items_count: number, height_in_items?: number): boolean;
export declare function ListBoxHeader(label: string, size: Readonly<Bind.interface_ImVec2>): boolean;
export declare function ListBoxHeader(label: string, items_count: number, height_in_items?: number): boolean;
export declare function ListBoxFooter(): void;
export type PlotLinesValueGetter<T> = (data: T, idx: number) => number;
export declare function PlotLines(label: string, values: ArrayLike<number>, values_count?: number, value_offset?: number, overlay_text?: string | null, scale_min?: number, scale_max?: number, graph_size?: Readonly<Bind.interface_ImVec2>, stride?: number): void;
export declare function PlotLines<T>(label: string, values_getter: PlotLinesValueGetter<T>, data: T, values_count?: number, value_offset?: number, overlay_text?: string | null, scale_min?: number, scale_max?: number, graph_size?: Readonly<Bind.interface_ImVec2>): void;
export type PlotHistogramValueGetter<T> = (data: T, idx: number) => number;
export declare function PlotHistogram(label: string, values: ArrayLike<number>, values_count?: number, value_offset?: number, overlay_text?: string | null, scale_min?: number, scale_max?: number, graph_size?: Readonly<Bind.interface_ImVec2>, stride?: number): void;
export declare function PlotHistogram<T>(label: string, values_getter: PlotHistogramValueGetter<T>, data: T, values_count?: number, value_offset?: number, overlay_text?: string | null, scale_min?: number, scale_max?: number, graph_size?: Readonly<Bind.interface_ImVec2>): void;
export declare function Value(prefix: string, b: boolean): void;
export declare function Value(prefix: string, v: number): void;
export declare function Value(prefix: string, v: number, float_format?: string | null): void;
export declare function Value(prefix: string, v: any): void;
export declare function BeginMenuBar(): boolean;
export declare function EndMenuBar(): void;
export declare function BeginMainMenuBar(): boolean;
export declare function EndMainMenuBar(): void;
export declare function BeginMenu(label: string, enabled?: boolean): boolean;
export declare function EndMenu(): void;
export declare function MenuItem(label: string, shortcut?: string | null, selected?: boolean, enabled?: boolean): boolean;
export declare function MenuItem(label: string, shortcut: string | null, p_selected: Bind.ImScalar<boolean> | Bind.ImAccess<boolean> | null, enabled?: boolean): boolean;
export declare function BeginTooltip(): void;
export declare function EndTooltip(): void;
export declare function SetTooltip(fmt: string): void;
export declare function BeginPopup(str_id: string, flags?: ImGuiWindowFlags): boolean;
export declare function BeginPopupModal(str_id: string, p_open?: Bind.ImScalar<boolean> | Bind.ImAccess<boolean> | null, flags?: ImGuiWindowFlags): boolean;
export declare function EndPopup(): void;
export declare function OpenPopup(str_id: string, popup_flags?: ImGuiPopupFlags): void;
export declare function OpenPopupOnItemClick(str_id?: string | null, popup_flags?: ImGuiPopupFlags): void;
export declare function CloseCurrentPopup(): void;
export declare function BeginPopupContextItem(str_id?: string | null, popup_flags?: ImGuiPopupFlags): boolean;
export declare function BeginPopupContextWindow(str_id?: string | null, popup_flags?: ImGuiPopupFlags): boolean;
export declare function BeginPopupContextVoid(str_id?: string | null, popup_flags?: ImGuiPopupFlags): boolean;
export declare function IsPopupOpen(str_id: string, flags?: ImGuiPopupFlags): boolean;
export declare function BeginTable(str_id: string, column: number, flags?: ImGuiTableFlags, outer_size?: Bind.interface_ImVec2, inner_width?: number): boolean;
export declare function EndTable(): void;
export declare function TableNextRow(row_flags?: ImGuiTableRowFlags, min_row_height?: number): void;
export declare function TableNextColumn(): boolean;
export declare function TableSetColumnIndex(column_n: number): boolean;
export declare function TableSetupColumn(label: string, flags?: ImGuiTableColumnFlags, init_width_or_weight?: number, user_id?: Bind.ImU32): void;
export declare function TableSetupScrollFreeze(cols: number, rows: number): void;
export declare function TableHeadersRow(): void;
export declare function TableHeader(label: string): void;
export declare function TableGetSortSpecs(): ImGuiTableSortSpecs | null;
export declare function TableGetColumnCount(): number;
export declare function TableGetColumnIndex(): number;
export declare function TableGetRowIndex(): number;
export declare function TableGetColumnName(column_n?: number): string;
export declare function TableGetColumnFlags(column_n?: number): ImGuiTableColumnFlags;
export declare function TableSetBgColor(target: ImGuiTableBgTarget, color: Bind.ImU32, column_n?: number): void;
export declare function Columns(count?: number, id?: string | null, border?: boolean): void;
export declare function NextColumn(): void;
export declare function GetColumnIndex(): number;
export declare function GetColumnWidth(column_index?: number): number;
export declare function SetColumnWidth(column_index: number, width: number): void;
export declare function GetColumnOffset(column_index?: number): number;
export declare function SetColumnOffset(column_index: number, offset_x: number): void;
export declare function GetColumnsCount(): number;
export declare function BeginTabBar(str_id: string, flags?: ImGuiTabBarFlags): boolean;
export declare function EndTabBar(): void;
export declare function BeginTabItem(label: string, p_open?: Bind.ImScalar<boolean> | Bind.ImAccess<boolean> | null, flags?: ImGuiTabItemFlags): boolean;
export declare function EndTabItem(): void;
export declare function TabItemButton(label: string, flags?: ImGuiTabItemFlags): boolean;
export declare function SetTabItemClosed(tab_or_docked_window_label: string): void;
export declare function LogToTTY(max_depth?: number): void;
export declare function LogToFile(max_depth?: number, filename?: string | null): void;
export declare function LogToClipboard(max_depth?: number): void;
export declare function LogFinish(): void;
export declare function LogButtons(): void;
export declare function LogText(fmt: string): void;
export declare function BeginDragDropSource(flags?: ImGuiDragDropFlags): boolean;
export declare function SetDragDropPayload<T>(type: string, data: T, cond?: ImGuiCond): boolean;
export declare function EndDragDropSource(): void;
export declare function BeginDragDropTarget(): boolean;
export declare function AcceptDragDropPayload<T>(type: string, flags?: ImGuiDragDropFlags): ImGuiPayload<T> | null;
export declare function EndDragDropTarget(): void;
export declare function GetDragDropPayload<T>(): ImGuiPayload<T> | null;
export declare function PushClipRect(clip_rect_min: Readonly<Bind.interface_ImVec2>, clip_rect_max: Readonly<Bind.interface_ImVec2>, intersect_with_current_clip_rect: boolean): void;
export declare function PopClipRect(): void;
export declare function SetItemDefaultFocus(): void;
export declare function SetKeyboardFocusHere(offset?: number): void;
export declare function IsItemHovered(flags?: ImGuiHoveredFlags): boolean;
export declare function IsItemActive(): boolean;
export declare function IsItemFocused(): boolean;
export declare function IsItemClicked(mouse_button?: ImGuiMouseButton): boolean;
export declare function IsItemVisible(): boolean;
export declare function IsItemEdited(): boolean;
export declare function IsItemActivated(): boolean;
export declare function IsItemDeactivated(): boolean;
export declare function IsItemDeactivatedAfterEdit(): boolean;
export declare function IsItemToggledOpen(): boolean;
export declare function IsAnyItemHovered(): boolean;
export declare function IsAnyItemActive(): boolean;
export declare function IsAnyItemFocused(): boolean;
export declare function GetItemRectMin(out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
export declare function GetItemRectMax(out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
export declare function GetItemRectSize(out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
export declare function SetItemAllowOverlap(): void;
export declare function IsRectVisible(size: Readonly<Bind.interface_ImVec2>): boolean;
export declare function IsRectVisible(rect_min: Readonly<Bind.interface_ImVec2>, rect_max: Readonly<Bind.interface_ImVec2>): boolean;
export declare function GetTime(): number;
export declare function GetFrameCount(): number;
export declare function GetBackgroundDrawList(): ImDrawList;
export declare function GetForegroundDrawList(): ImDrawList;
export declare function GetDrawListSharedData(): ImDrawListSharedData;
export declare function GetStyleColorName(idx: ImGuiCol): string;
export declare function CalcListClipping(items_count: number, items_height: number, out_items_display_start: Bind.ImScalar<number>, out_items_display_end: Bind.ImScalar<number>): void;
export declare function BeginChildFrame(id: ImGuiID, size: Readonly<Bind.interface_ImVec2>, flags?: ImGuiWindowFlags): boolean;
export declare function EndChildFrame(): void;
export declare function CalcTextSize(text: string, text_end?: number | null, hide_text_after_double_hash?: boolean, wrap_width?: number, out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
export declare function ColorConvertU32ToFloat4(in_: Bind.ImU32, out?: Bind.interface_ImVec4): Bind.interface_ImVec4;
export declare function ColorConvertFloat4ToU32(in_: Readonly<Bind.interface_ImVec4>): Bind.ImU32;
export declare function ColorConvertRGBtoHSV(r: number, g: number, b: number, out_h: Bind.ImScalar<number>, out_s: Bind.ImScalar<number>, out_v: Bind.ImScalar<number>): void;
export declare function ColorConvertHSVtoRGB(h: number, s: number, v: number, out_r: Bind.ImScalar<number>, out_g: Bind.ImScalar<number>, out_b: Bind.ImScalar<number>): void;
export declare function GetKeyIndex(imgui_key: ImGuiKey): number;
export declare function IsKeyDown(user_key_index: number): boolean;
export declare function IsKeyPressed(user_key_index: number, repeat?: boolean): boolean;
export declare function IsKeyReleased(user_key_index: number): boolean;
export declare function GetKeyPressedAmount(user_key_index: number, repeat_delay: number, rate: number): number;
export declare function CaptureKeyboardFromApp(capture?: boolean): void;
export declare function IsMouseDown(button: number): boolean;
export declare function IsMouseClicked(button: number, repeat?: boolean): boolean;
export declare function IsMouseDoubleClicked(button: number): boolean;
export declare function IsMouseReleased(button: number): boolean;
export declare function IsMouseHoveringRect(r_min: Readonly<Bind.interface_ImVec2>, r_max: Readonly<Bind.interface_ImVec2>, clip?: boolean): boolean;
export declare function IsMousePosValid(mouse_pos?: Readonly<Bind.interface_ImVec2> | null): boolean;
export declare function IsAnyMouseDown(): boolean;
export declare function GetMousePos(out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
export declare function GetMousePosOnOpeningCurrentPopup(out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
export declare function IsMouseDragging(button?: number, lock_threshold?: number): boolean;
export declare function GetMouseDragDelta(button?: number, lock_threshold?: number, out?: Bind.interface_ImVec2): Bind.interface_ImVec2;
export declare function ResetMouseDragDelta(button?: number): void;
export declare function GetMouseCursor(): ImGuiMouseCursor;
export declare function SetMouseCursor(type: ImGuiMouseCursor): void;
export declare function CaptureMouseFromApp(capture?: boolean): void;
export declare function GetClipboardText(): string;
export declare function SetClipboardText(text: string): void;
export declare function LoadIniSettingsFromDisk(ini_filename: string): void;
export declare function LoadIniSettingsFromMemory(ini_data: string, ini_size?: number): void;
export declare function SaveIniSettingsToDisk(ini_filename: string): void;
export declare function SaveIniSettingsToMemory(out_ini_size?: Bind.ImScalar<number> | null): string;
export declare function DebugCheckVersionAndDataLayout(version_str: string, sz_io: number, sz_style: number, sz_vec2: number, sz_vec4: number, sz_draw_vert: number, sz_draw_idx: number): boolean;
export declare function SetAllocatorFunctions(alloc_func: (sz: number, user_data: any) => number, free_func: (ptr: number, user_data: any) => void, user_data?: any): void;
export declare function MemAlloc(sz: number): void;
export declare function MemFree(ptr: any): void;
export { ImGuiWindow as Window };
export declare class ImGuiWindow {
    readonly native: Bind.reference_ImGuiWindow;
    constructor(native: Bind.reference_ImGuiWindow);
    get ID(): ImGuiID;
    get Flags(): ImGuiWindowFlags;
    set Flags(f: ImGuiWindowFlags);
    get Pos(): Bind.interface_ImVec2;
    set Pos(v: Bind.interface_ImVec2);
    get Size(): Bind.interface_ImVec2;
    set Size(v: Bind.interface_ImVec2);
    get SizeFull(): Bind.interface_ImVec2;
    set SizeFull(v: Bind.interface_ImVec2);
    get ContentSize(): Bind.interface_ImVec2;
    set ContentSize(v: Bind.interface_ImVec2);
    get ContentSizeIdeal(): Bind.interface_ImVec2;
    set ContentSizeIdeal(v: Bind.interface_ImVec2);
    get ContentSizeExplicit(): Bind.interface_ImVec2;
    set ContentSizeExplicit(v: Bind.interface_ImVec2);
    get WindowPadding(): Bind.interface_ImVec2;
    set WindowPadding(v: Bind.interface_ImVec2);
    get WindowRounding(): number;
    set WindowRounding(v: number);
    get WindowBorderSize(): number;
    set WindowBorderSize(v: number);
    get Scroll(): Bind.interface_ImVec2;
    set Scroll(v: Bind.interface_ImVec2);
    get ScrollMax(): Bind.interface_ImVec2;
    set ScrollMax(v: Bind.interface_ImVec2);
    get ScrollTarget(): Bind.interface_ImVec2;
    set ScrollTarget(v: Bind.interface_ImVec2);
    get ScrollTargetCenterRatio(): Bind.interface_ImVec2;
    set ScrollTargetCenterRatio(v: Bind.interface_ImVec2);
    get ScrollTargetEdgeSnapDist(): Bind.interface_ImVec2;
    set ScrollTargetEdgeSnapDist(v: Bind.interface_ImVec2);
    get ScrollbarSizes(): Bind.interface_ImVec2;
    set ScrollbarSizes(v: Bind.interface_ImVec2);
    get ScrollbarX(): boolean;
    get ScrollbarY(): boolean;
    get Active(): boolean;
    get WasActive(): boolean;
    get ItemWidthDefault(): number;
    set ItemWidthDefault(v: number);
    get ParentWindow(): ImGuiWindow | null;
    get RootWindow(): ImGuiWindow | null;
    get RootWindowForTitleBarHighlight(): ImGuiWindow | null;
    get RootWindowForNav(): ImGuiWindow | null;
}
export { ImGuiInputTextState as InputTextState };
export declare class ImGuiInputTextState {
    readonly native: Bind.reference_ImGuiInputTextState;
    constructor(native: Bind.reference_ImGuiInputTextState);
    get ID(): ImGuiID;
    get Flags(): ImGuiInputTextFlags;
    get FrameBB(): Readonly<Bind.interface_ImRect>;
    get Text(): string;
    set Text(t: string);
}
export declare function GetCurrentWindow(): ImGuiWindow;
export declare function GetHoveredWindow(): ImGuiWindow | null;
export declare function GetHoveredRootWindow(): ImGuiWindow | null;
export declare function GetMovingWindow(): ImGuiWindow | null;
export declare function GetActiveWindow(): ImGuiWindow | null;
export declare function GetHoveredId(): ImGuiID;
export declare function GetHoveredIdPreviousFrame(): ImGuiID;
export declare function GetActiveId(): ImGuiID;
export declare function GetActiveIdPreviousFrame(): ImGuiID;
export declare function SetActiveId(id: ImGuiID): void;
export declare function GetInputTextState(id: ImGuiID): ImGuiInputTextState;
export declare function GetInputTextId(): ImGuiID;
export declare function Vec4_toRGBA(col: ImVec4): string;
export declare function Font_toString(font: ImFont): string;
export declare function CreateFont(name: string, size: number, style?: string): ImFont;
