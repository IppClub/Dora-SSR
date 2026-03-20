declare module "yue" {
	export const enum LuaTarget {
		Lua51 = "5.1",
		Lua52 = "5.2",
		Lua53 = "5.3",
		Lua54 = "5.4",
		Lua55 = "5.5",
	}

	export interface Options {
		target: LuaTarget;
		path: string;
		dump_locals: boolean;
		simplified: boolean;
		[key: string]: string | boolean | undefined;
	}

	export interface Config {
		lint_global: boolean;
		implicit_return_root: boolean;
		reserve_line_number: boolean;
		space_over_tab: boolean;
		same_module: boolean;
		line_offset: number;
		options: Options;
	}

	export type GlobalItem = [
		name: string,
		row: number,
		col: number,
	];

	export type LoadedFunction = (...args: any[]) => any;

	export type CompileCodeHandler = (
		codes: string,
		err: string,
		globals: GlobalItem[],
	) => string | undefined;

	export type AST = [
		name: string,
		row: number,
		col: number,
		node: any,
	];

	export type CheckItem = [
		type: string,
		msg: string,
		line: number,
		col: number,
	];

	export const version: string;
	export const dirsep: string;
	export const yue_compiled: Record<string, string>;

	export function to_lua(
		code: string,
		config?: Config,
	): LuaMultiReturn<[codes: string | undefined, error: string | undefined, globals: GlobalItem[] | undefined]>;

	export function file_exist(filename: string): boolean;

	export function read_file(filename: string): string;

	export function insert_loader(pos?: number): boolean;

	export function remove_loader(): boolean;

	export function loadstring(
		input: string,
		chunkname: string,
		env: object,
		config?: Config,
	): LuaMultiReturn<[loadedFunction: LoadedFunction | undefined, error: string | undefined]>;

	export function loadstring(
		input: string,
		chunkname: string,
		config?: Config,
	): LuaMultiReturn<[loadedFunction: LoadedFunction | undefined, error: string | undefined]>;

	export function loadstring(
		input: string,
		config?: Config,
	): LuaMultiReturn<[loadedFunction: LoadedFunction | undefined, error: string | undefined]>;

	export function loadfile(
		filename: string,
		env: object,
		config?: Config,
	): LuaMultiReturn<[loadedFunction: LoadedFunction | undefined, error: string | undefined]>;

	export function loadfile(
		filename: string,
		config?: Config,
	): LuaMultiReturn<[loadedFunction: LoadedFunction | undefined, error: string | undefined]>;

	export function dofile(filename: string, env: object, config?: Config): LuaMultiReturn<any[]>;
	export function dofile(filename: string, config?: Config): LuaMultiReturn<any[]>;

	export function find_modulepath(name: string): string;

	export function pcall(f: (...args: any[]) => any, ...args: any[]): LuaMultiReturn<[success: boolean, ...results: any[]]>;

	export function require(name: string): LuaMultiReturn<any[]>;

	export function p(...args: any[]): void;

	export const options: Options;

	export function traceback(message: string): string;

	export function compile(
		sourceFile: string,
		targetFile: string,
		searchPath: string,
		compileCodesHandler: CompileCodeHandler,
		callback: (result: boolean) => void,
	): void;

	export function is_ast(astName: string, code: string): boolean;

	export function to_ast(
		code: string,
		flattenLevel?: number,
		astName?: string,
	): LuaMultiReturn<[ast: AST | undefined, error: string | undefined]>;

	export function checkAsync(
		yueCodes: string,
		searchPath: string,
		lax: boolean,
	): LuaMultiReturn<[info: CheckItem[], luaCodes: string | undefined]>;

	export function clear(): void;
}
