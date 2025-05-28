-- The YueScript language library.
local record yue

	-- The YueScript version.
	version: string

	-- The file separator for the current platform.
	dirsep: string

	-- The compiled module code cache.
	yue_compiled: {string: string}

	-- The compiler compile options.
	record Config

		-- Whether the compiler should collect the global variables appearing in the code.
		lint_global: boolean

		-- Whether the compiler should do an implicit return for the root code block.
		implicit_return_root: boolean

		-- Whether the compiler should reserve the original line number in the compiled code.
		reserve_line_number: boolean

		-- Whether the compiler should use the space character instead of the tab character in the compiled code.
		space_over_tab: boolean

		-- Whether the compiler should treat the code to be compiled as the same currently being compiled module. For internal use only.
		same_module: boolean

		-- Whether the compiler error message should include the line number offset. For internal use only.
		line_offset: integer

		-- The target Lua version enumeration.
		enum LuaTarget
			"5.1"
			"5.2"
			"5.3"
			"5.4"
			"5.5"
		end

		-- The extra compiler options definition.
		record Options

			-- The target Lua version for the compilation.
			target: LuaTarget

			-- The extra module search path.
			path: string

			-- Whether to dump the local variables in the traceback error message. Default is false.
			dump_locals: boolean

			-- Whether to simplify the error message. Default is true.
			simplified: boolean

			-- The setter metamethod for the Options record.
			-- @param key (string) The key.
			-- @param value (string) The value.
			metamethod __newindex: function(self: Options, key: string, value: string)

			-- The getter metamethod for the Options record.
			-- @param key (string) The key.
			-- @return (string) The value.
			metamethod __index: function(self: Options, key: string): string
		end

		-- The extra options to be passed to the compilation function.
		options: Options
	end

	-- The YueScript compiling function. It compiles the YueScript code to Lua code.
	-- @param code (string) The YueScript code.
	-- @param config (Config) [Optional] The compiler options.
	-- @return (string | nil) The compiled Lua code, or nil if the compilation failed.
	-- @return (string | nil) The error message, or nil if the compilation succeeded.
	-- @return ({{string, integer, integer}} | nil) The global variables appearing in the code (with name, row and column), or nil if the compiler option `lint_global` is false.
	to_lua: function(code: string, config?: Config):
		--[[codes]] string | nil,
		--[[error]] string | nil,
		--[[globals]] {{string, integer, integer}} | nil

	-- The source file existence checking function. Can be overridden to customize the behavior.
	-- @param filename (string) The file name.
	-- @return (boolean) Whether the file exists.
	file_exist: function(filename: string): boolean

	-- The source file reading function. Can be overridden to customize the behavior.
	-- @param filename (string) The file name.
	-- @return (string) The file content.
	read_file: function(filename: string): string

	-- Insert the YueScript loader to the package loaders (searchers).
	-- @param pos (integer) [Optional] The position to insert the loader. Default is 3.
	-- @return (boolean) Whether the loader is inserted successfully. It will fail if the loader is already inserted.
	insert_loader: function(pos?: integer): boolean

	-- Remove the YueScript loader from the package loaders (searchers).
	-- @return (boolean) Whether the loader is removed successfully. It will fail if the loader is not inserted.
	remove_loader: function(): boolean

	-- Loads YueScript code from a string into a function.
	-- @param input (string) The YueScript code.
	-- @param chunkname (string) The name of the code chunk.
	-- @param env (table) The environment table.
	-- @param config (Config) [Optional] The compiler options.
	-- @return (function | nil) The loaded function, or nil if the loading failed.
	-- @return (string | nil) The error message, or nil if the loading succeeded.
	loadstring: function(input: string, chunkname: string, env: table, config?: Config):
		--[[loaded function]] nil | function(...: any): (any...),
		--[[error]] string | nil

	-- Loads YueScript code from a string into a function.
	-- @param input (string) The YueScript code.
	-- @param chunkname (string) The name of the code chunk.
	-- @param config (Config) [Optional] The compiler options.
	-- @return (function | nil) The loaded function, or nil if the loading failed.
	-- @return (string | nil) The error message, or nil if the loading succeeded.
	loadstring: function(input: string, chunkname: string, config?: Config):
		--[[loaded function]] nil | function(...: any): (any...),
		--[[error]] string | nil

	-- Loads YueScript code from a string into a function.
	-- @param input (string) The YueScript code.
	-- @param config (Config) [Optional] The compiler options.
	-- @return (function | nil) The loaded function, or nil if the loading failed.
	-- @return (string | nil) The error message, or nil if the loading succeeded.
	loadstring: function(input: string, config?: Config):
		--[[loaded function]] nil | function(...: any): (any...),
		--[[error]] string | nil

	-- Loads YueScript code from a file into a function.
	-- @param filename (string) The file name.
	-- @param env (table) The environment table.
	-- @param config (Config) [Optional] The compiler options.
	-- @return (function | nil) The loaded function, or nil if the loading failed.
	-- @return (string | nil) The error message, or nil if the loading succeeded.
	loadfile: function(filename: string, env: table, config?: Config):
		nil | function(...: any): (any...),
		string | nil

	-- Loads YueScript code from a file into a function.
	-- @param filename (string) The file name.
	-- @param config (Config) [Optional] The compiler options.
	-- @return (function | nil) The loaded function, or nil if the loading failed.
	-- @return (string | nil) The error message, or nil if the loading succeeded.
	loadfile: function(filename: string, config?: Config):
		nil | function(...: any): (any...),
		string | nil

	-- Loads YueScript code from a file into a function and executes it.
	-- @param filename (string) The file name.
	-- @param env (table) The environment table.
	-- @param config (Config) [Optional] The compiler options.
	-- @return (any...) The return values of the loaded function.
	dofile: function(filename: string, env: table, config?: Config): any...

	-- Loads YueScript code from a file into a function and executes it.
	-- @param filename (string) The file name.
	-- @param config (Config) [Optional] The compiler options.
	-- @return (any...) The return values of the loaded function.
	dofile: function(filename: string, config?: Config): any...

	-- Resolves the YueScript module name to the file path.
	-- @param name (string) The module name.
	-- @return (string) The file path.
	find_modulepath: function(name: string): string

	-- Calls a function in protected mode.
	-- Catches any errors and returns a status code and results or error object.
	-- Rewrites the error line number to the original line number in the YueScript code when errors occur.
	-- @param f (function) The function to call.
	-- @param ... (any) Arguments to pass to the function.
	-- @return (boolean, ...) Status code and function results or error object.
	pcall: function(f: function, ...: any): boolean, any...

	-- Loads a given module. Can be either a Lua module or a YueScript module.
	-- Rewrites the error line number to the original line number in the YueScript code if the module is a YueScript module and loading fails.
	-- @param modname (string) The name of the module to load.
	-- @return (any) The value stored at package.loaded[modname] if the module is already loaded.
	-- Otherwise, tries to find a loader and returns the final value of package.loaded[modname] and a loader data as a second result.
	require: function(name: string): any...

	-- Inspects the structures of the passed values and prints string representations.
	-- @param ... (any) The values to inspect.
	p: function(...: any)

	-- The current compiler options.
	options: Config.Options

	-- The traceback function that rewrites the stack trace line numbers to the original line numbers in the YueScript code.
	-- @param message (string) The traceback message.
	-- @return (string) The rewritten traceback message.
	traceback: function(message: string): string

	type CompileCodeHandler = function(
		codes: string,
		err: string,
		globals: {{string, integer, integer}}
	): string | nil

	-- Compiles the YueScript code to Lua code in a thread.
	-- @param sourceFile (string) The source file name.
	-- @param targetFile (string) The target file name.
	-- @param searchPath (string) The extra module search path.
	-- @param compileCodesHandler (CompileCodeHandler) The callback function to handle the compiled codes.
	-- @param callback (function) The callback function to handle the result.
	compile: function(
		sourceFile: string,
		targetFile: string,
		searchPath: string,
		compileCodesHandler: CompileCodeHandler,
		callback: function(result: boolean)
	)

	-- Checks whether the code matches the specified AST.
	-- @param astName (string) The AST name.
	-- @param code (string) The code.
	-- @return (boolean) Whether the code matches the AST.
	is_ast: function(astName: string, code: string): boolean

	-- The AST type definition with name, row, column and sub nodes.
	type AST = {string, integer, integer, any}

	-- Converts the code to the AST.
	-- @param code (string) The code.
	-- @param flattenLevel (integer) [Optional] The flatten level. Higher level means more flattening. Default is 0. Maximum is 2.
	-- @param astName (string) [Optional] The AST name. Default is "File".
	-- @return (AST | nil) The AST, or nil if the conversion failed.
	-- @return (string | nil) The error message, or nil if the conversion succeeded.
	to_ast: function(code: string, flattenLevel?: number, astName?: string):
		--[[AST]] AST | nil,
		--[[error]] nil | string

	-- Checks for the problems in the YueScript code asynchronously.
	-- Should be called in a coroutine thread.
	-- @param yueCodes (string) The YueScript code.
	-- @param searchPath (string) The extra module search path.
	-- @param lax (boolean) Using lax mode.
	-- @return ({info}) The problem information with type, message, line and column as an array.
	-- @return (string | nil) The Lua codes when no problem found, or nil if the checking failed.
	checkAsync: function(yueCodes: string, searchPath: string, lax: boolean):
		--[[info]] {{
			--[[type]] string,
			--[[msg]] string,
			--[[line]] integer,
			--[[col]] integer
		}},
		--[[luaCodes]] string | nil

	-- Clears the compiled macro functions in cache.
	clear: function()

	-- Requires the YueScript module.
	-- Rewrites the error line number to the original line number in the YueScript code when loading fails.
	-- @param module (string) The module name.
	-- @return (any) The module value.
	metamethod __call: function(self: yue, module: string): any...
end

return yue
