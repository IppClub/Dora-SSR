import { NodeType as Node } from "Dora";

declare module 'Ruler' {

interface Param {
	x?: number;
	y?: number;
	width: number;
	height: number;
	fontName?: string;
	fontSize?: number;
	fixed?: boolean;
}

class Ruler extends Node {
	private constructor();
	value: number;
	show(defaultValue: number, min: number, max: number, indent: number, callback: (this: void, value: number) => void): void;
	hide(): void;
}

export namespace Ruler {
	type Type = Ruler;
}

interface RulerClass {
	(this: void, param: Param): Ruler;
}

const rulerClass: RulerClass;
export = rulerClass;

} // module 'Ruler'
