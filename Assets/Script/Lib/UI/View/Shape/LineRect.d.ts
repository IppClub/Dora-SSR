import {NodeType} from 'Dora';

interface Param {
	/** default 0 */
	x?: number;
	/** default 0 */
	y?: number;
	width: number;
	height: number;
	/** default 0xffffffff */
	color?: number;
	/** default 0 */
	renderOrder?: number;
}

declare function LineRect(this: void, param: Param): NodeType;
export = LineRect;
