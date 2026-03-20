declare module "teal" {
	export const enum ErrorType {
		Parsing = "parsing",
		Syntax = "syntax",
		Type = "type",
		Warning = "warning",
		Crash = "crash",
	}

	/**
	 * A Teal diagnostic item returned as a Lua array-like tuple.
	 * Order: type, filename, row, column, message.
	 */
	export type CheckResult = [
		type: ErrorType,
		filename: string,
		row: number,
		col: number,
		msg: string,
	];

	export const enum CompleteItemType {
		Variable = "variable",
		Function = "function",
		Method = "method",
		Field = "field",
		Keyword = "keyword",
	}

	/**
	 * A completion item returned as a Lua array-like tuple.
	 * Order: label, description, item type.
	 */
	export type CompleteResult = [
		label: string,
		desc: string,
		type: CompleteItemType,
	];

	export interface InferResult {
		desc: string;
		file: string;
		row: number;
		col: number;
		key?: string;
	}

	/**
	 * Compiles Teal code to Lua code.
	 * Returns the compiled Lua code on success, or `undefined` with an error message on failure.
	 */
	export function tolua(
		this: void,
		codes: string,
		moduleName: string,
		searchPath: string,
	): LuaMultiReturn<[luaCodes: string, error: undefined]> | LuaMultiReturn<[luaCodes: undefined, error: string]>;

	/**
	 * Compiles Teal code to Lua code asynchronously.
	 * Must be called from a coroutine thread in Dora SSR.
	 */
	export function toluaAsync(
		this: void,
		codes: string,
		moduleName: string,
		searchPath: string,
	): LuaMultiReturn<[luaCodes: string, error: undefined]> | LuaMultiReturn<[luaCodes: undefined, error: string]>;

	/**
	 * Checks Teal code asynchronously.
	 * Must be called from a coroutine thread in Dora SSR.
	 */
	export function checkAsync(
		this: void,
		codes: string,
		moduleName: string,
		lax: boolean,
		searchPath: string,
	): LuaMultiReturn<[passed: boolean, result: CheckResult[] | undefined]>;

	/**
	 * Gets completion suggestions asynchronously.
	 * Must be called from a coroutine thread in Dora SSR.
	 */
	export function completeAsync(
		this: void,
		codes: string,
		line: string,
		row: number,
		searchPath: string,
	): CompleteResult[];

	/**
	 * Infers symbol information asynchronously.
	 * Must be called from a coroutine thread in Dora SSR.
	 */
	export function inferAsync(
		this: void,
		codes: string,
		line: string,
		row: number,
		searchPath: string,
	): InferResult | undefined;

	/**
	 * Gets signature information asynchronously.
	 * Must be called from a coroutine thread in Dora SSR.
	 */
	export function getSignatureAsync(
		this: void,
		codes: string,
		line: string,
		row: number,
		searchPath: string,
	): InferResult[];

	/**
	 * Clears the Teal analysis cache.
	 * @param reset Whether to fully reset the internal state. Default is `false`.
	 */
	export function clear(this: void, reset?: boolean): void;
}
