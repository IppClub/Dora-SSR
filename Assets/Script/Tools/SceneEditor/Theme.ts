import { Color } from 'Dora';
import { WindowFlag, InputTextFlag } from 'ImGui';

export const themeColor = Color(0xffffcc33);
export const okColor = Color(0xff66d17a);
export const warnColor = Color(0xffffcc33);
export const redAxisColor = Color(0xccd45353);
export const greenAxisColor = Color(0xcc63b86a);
export const gridMinorColor = Color(0x3f586271);
export const gridMajorColor = Color(0x6f7b8797);
export const viewportBgColor = Color(0xff20242b);
export const viewportFrameColor = Color(0xaa5f6d80);
export const viewportGameFrameColor = Color(0xccd2aa3a);
export const selectionColor = Color(0xeed6b13f);
export const helperColor = Color(0xaa72a6c8);
export const panelBg = Color(0xee15191f);
export const scriptPanelBg = Color(0xf0181d24);
export const transparent = Color(0x00000000);

export const mainWindowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoMove,
	WindowFlag.NoCollapse,
	WindowFlag.NoNav,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoBringToFrontOnFocus,
	WindowFlag.NoScrollbar,
];

export const noScrollFlags = [
	WindowFlag.NoScrollbar,
	WindowFlag.NoScrollWithMouse,
];

export const inputTextFlags = [InputTextFlag.AutoSelectAll];
