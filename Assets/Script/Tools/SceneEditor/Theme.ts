import { Color } from 'Dora';
import { WindowFlag, InputTextFlag } from 'ImGui';

export const themeColor = Color(0xffffcc33);
export const okColor = Color(0xff66d17a);
export const warnColor = Color(0xffffcc33);
export const redAxisColor = Color(0xffff1f1f);
export const greenAxisColor = Color(0xff22ff44);
export const gridMinorColor = Color(0xdd8796b0);
export const gridMajorColor = Color(0xffffffff);
export const transparent = Color(0x00000000);

export const mainWindowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoMove,
	WindowFlag.NoCollapse,
	WindowFlag.NoNav,
	WindowFlag.NoScrollbar,
];

export const noScrollFlags = [
	WindowFlag.NoScrollbar,
	WindowFlag.NoScrollWithMouse,
];

export const inputTextFlags = [InputTextFlag.AutoSelectAll];
