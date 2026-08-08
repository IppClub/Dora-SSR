/** Lua 5.2-compatible unsigned 32-bit bitwise operations. */
declare module "bit32" {
	/** Arithmetic right shift. Negative displacements shift left. */
	export function arshift(this: void, value: number, displacement: number): number;
	/** Bitwise AND of all arguments. With no arguments, returns `0xffffffff`. */
	export function band(this: void, ...values: number[]): number;
	/** Bitwise complement restricted to 32 bits. */
	export function bnot(this: void, value: number): number;
	/** Bitwise OR of all arguments. With no arguments, returns `0`. */
	export function bor(this: void, ...values: number[]): number;
	/** Returns whether the bitwise AND of all arguments is nonzero. */
	export function btest(this: void, ...values: number[]): boolean;
	/** Bitwise exclusive OR of all arguments. */
	export function bxor(this: void, ...values: number[]): number;
	/** Extracts `width` bits starting at zero-based bit `field`. */
	export function extract(this: void, value: number, field: number, width?: number): number;
	/** Rotates a value left inside its 32-bit representation. */
	export function lrotate(this: void, value: number, displacement: number): number;
	/** Logical left shift. Negative displacements shift right. */
	export function lshift(this: void, value: number, displacement: number): number;
	/** Replaces `width` bits starting at zero-based bit `field`. */
	export function replace(this: void, value: number, replacement: number, field: number, width?: number): number;
	/** Rotates a value right inside its 32-bit representation. */
	export function rrotate(this: void, value: number, displacement: number): number;
	/** Logical right shift. Negative displacements shift left. */
	export function rshift(this: void, value: number, displacement: number): number;
}
