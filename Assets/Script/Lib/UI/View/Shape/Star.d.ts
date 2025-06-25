import { NodeType } from 'Dora';

interface Param {
	x?: number;
	y?: number;
	size: number;
	fillColor?: number;
	borderColor?: number;
	fillOrder?: number;
	lineOrder?: number;
}
declare function Star(param: Param): NodeType;
export = Star;
