import {NodeType} from 'dora';

interface Param {
	x: number;
	y: number;
	radius: number;
	fillColor: number;
	borderColor: number;
	fillOrder: number;
	lineOrder: number;
}
declare function Circle(param: Param): NodeType;
export = Circle;
