/** 与 Lua 5.2 兼容的无符号 32 位运算库。 */
declare module "bit32" {
	/** 算术右移；负位移量表示左移。 */
	export function arshift(this: void, value: number, displacement: number): number;
	/** 对全部参数执行按位与；无参数时返回 `0xffffffff`。 */
	export function band(this: void, ...values: number[]): number;
	/** 在 32 位范围内执行按位取反。 */
	export function bnot(this: void, value: number): number;
	/** 对全部参数执行按位或；无参数时返回 `0`。 */
	export function bor(this: void, ...values: number[]): number;
	/** 判断全部参数按位与的结果是否非零。 */
	export function btest(this: void, ...values: number[]): boolean;
	/** 对全部参数执行按位异或。 */
	export function bxor(this: void, ...values: number[]): number;
	/** 从编号为 `field` 的位开始提取 `width` 位，位编号从 0 开始。 */
	export function extract(this: void, value: number, field: number, width?: number): number;
	/** 在 32 位表示范围内向左循环移位。 */
	export function lrotate(this: void, value: number, displacement: number): number;
	/** 逻辑左移；负位移量表示右移。 */
	export function lshift(this: void, value: number, displacement: number): number;
	/** 从编号为 `field` 的位开始替换 `width` 位。 */
	export function replace(this: void, value: number, replacement: number, field: number, width?: number): number;
	/** 在 32 位表示范围内向右循环移位。 */
	export function rrotate(this: void, value: number, displacement: number): number;
	/** 逻辑右移；负位移量表示左移。 */
	export function rshift(this: void, value: number, displacement: number): number;
}
