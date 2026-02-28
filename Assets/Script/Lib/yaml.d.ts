declare module 'yaml' {
	export function parse(str: string): LuaMultiReturn<[undefined, string]> | LuaMultiReturn<[Record<string, any>, undefined]>;
} // module 'yaml'
