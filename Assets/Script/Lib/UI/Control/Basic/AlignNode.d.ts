import { Vec2Type as Vec2, NodeType as Node } from "dora";

declare module 'AlignNode' {

export const enum HAlignMode {
	Left = "Left",
	Center = "Center",
	Right = "Right"
}

export const enum VAlignMode {
	Bottom = "Bottom",
	Center = "Center",
	Top = "Top"
}

export interface Param {
	isRoot?: boolean;
	inUI?: boolean;
	hAlign?: HAlignMode;
	vAlign?: VAlignMode;
	alignOffset?: Vec2;
	alignWidth?: string;
	alignHeight?: string;
}

class AlignNode extends Node {
	private constructor();
	alignLayout: () => void;
}

interface AlignNodeClass {
	(this: void, param: Param): AlignNode;
}

const alignNodeClass: AlignNodeClass;
export = alignNodeClass;

} // module 'AlignNode'
