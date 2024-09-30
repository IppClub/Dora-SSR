import { Size, NodeType as Node, Menu } from "Dora";
type Size = Size.Type;
type Menu = Menu.Type;

declare module 'ScrollArea' {

interface Param {
	x?: number; // default 0
	y?: number; // default 0
	width?: number; // default 0
	height?: number; // default 0
	viewWidth?: number; // default 0
	viewHeight?: number; // default 0
	paddingX?: number; // default 200
	paddingY?: number; // default 200
	visible?: boolean; // default true
	scrollBar?: boolean; // default true
	scrollBarColor3?: number; // default App.themeColor.toARGB()
	clipping?: boolean; // default true
}

export const enum AlignMode {
	Auto = "Auto",
	Vertical = "Vertical",
	Horizontal = "Horizontal",
}

class ScrollArea extends Node {
	private constructor();
	readonly area: Node;
	readonly view: Menu;
	scrollToPosY(posY: number, time?: number): void; // Default time is 0.3
	adjustSizeWithAlign(alignMode?: AlignMode, padding?: number, size?: Size, viewSize?: Size): void; // Default padding is 10
}

export namespace ScrollArea {
	type Type = ScrollArea;
}

interface ScrollAreaClass {
	(this: void, param: Param): ScrollArea;
}

const scrollAreaClass: ScrollAreaClass;
export = scrollAreaClass;

} // module 'ScrollArea'
