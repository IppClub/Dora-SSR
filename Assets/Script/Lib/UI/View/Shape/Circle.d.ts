import { NodeType } from 'Dora';

interface Param {
	/** default 0 */
	x?: number;
	/** default 0 */
	y?: number;
	radius: number;
	/** default 0x00000000 */
	fillColor?: number;
	/** default 0x00000000 */
	borderColor?: number;
	/** default 0 */
	fillOrder?: number;
	/** default 0 */
	lineOrder?: number;
}
declare function Circle(param: Param): NodeType;
export = Circle;
