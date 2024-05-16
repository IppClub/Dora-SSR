import { NodeType as Node } from "Dora";

declare module 'CircleButton' {

interface Param {
	text: string;
	x?: number;
	y?: number;
	radius: number;
	fontName?: string;
	fontSize?: number;
}

class CircleButton extends Node {
	private constructor();
	text: string;
}

export namespace CircleButton {
	type Type = CircleButton;
}

interface CircleButtonClass {
	(this: void, param: Param): CircleButton;
}

const circleButtonClass: CircleButtonClass;
export = circleButtonClass;

} // module 'CircleButton'
