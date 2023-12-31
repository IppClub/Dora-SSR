import {NodeType} from 'dora';

interface Param {
	x?: number;
	y?: number;
	width: number;
	height: number;
	fillColor: number;
	borderColor: number;
	fillOrder: number;
	lineOrder: number;
}

declare function Rectangle(this: void, param: Param): NodeType;
export = Rectangle;
