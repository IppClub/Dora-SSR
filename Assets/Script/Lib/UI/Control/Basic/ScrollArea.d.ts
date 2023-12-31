import { SizeType as Size, NodeType as Node } from "dora";

declare module 'ScrollArea' {

interface Param {
	x: number;
	y: number;
	width: number;
	height: number;
	viewWidth: number;
	viewHeight: number;
	visible: boolean;
	scrollBar: boolean;
	scrollBarColor3: boolean;
	clipping: boolean;
}

const enum AlignMode {
	Auto = "Auto",
	Vertical = "Vertical",
	Horizontal = "Horizontal",
}

class ScrollArea extends Node {
	private constructor();
	scrollToPosY(posY: number, time?: number): void; // Default time is 0.3
	adjustSizeWithAlign(alignMode?: AlignMode, padding?: number, size?: Size, viewSize?: Size): void; // Default padding is 10
}

interface ScrollAreaClass {
	(this: void, param: Param): ScrollArea;
}

const scrollAreaClass: ScrollAreaClass;
export = scrollAreaClass;

} // module 'ScrollArea'
