local record yue
	dirsep: string
	yue_compiled: {string:string}
	version: string

	record Config
		lint_global: boolean
		implicit_return_root: boolean
		reserve_line_number: boolean
		space_over_tab: boolean
		same_module: boolean
		line_offset: integer
	end

	to_lua: function(code: string, config?: Config): --[[codes]] string | nil, --[[error]] string | nil, --[[globals]] {{string, integer, integer}} | nil

	file_exist: function(filename: string): boolean
	read_file: function(filename: string): string
	insert_loader: function(pos: integer): boolean
	remove_loader: function(): boolean
	loader: function(name: string): string, string

	enum LoadMode
		"b"
		"t"
		"bt"
	end
	loadstring: function(input: string, chunkname?: string, mode?: LoadMode, env?: table, config?: Config): function(...: any): (any...), string
	loadfile: function(filename: string, chunkname?: string, mode?: LoadMode, env?: table, config?: Config): function(...: any): (any...), string
	dofile: function(filename: string, chunkname?: string, mode?: LoadMode, env?: table, config?: Config): any...
	create_yuepath: function(package_path: string): string
	find_modulepath: function(name: string): string
	pcall: function(f: function, ...: any): boolean, any...
	require: function(name: string): any...
	p: function(...: any)
	options: {string: string}

	type CompileCodeHandler = function(
		codes: string,
		err: string,
		globals: {{string, integer, integer}}
	): string | nil

	compile: function(
		sourceFile: string,
		targetFile: string,
		searchPath: string,
		compileCodesHandler: CompileCodeHandler,
		callback: function(result: boolean)
	)

	checkAsync: function(yueCodes: string, searchPath: string): {{--[[type]] string, --[[msg]] string, --[[line]] integer, --[[col]] integer}}, --[[luaCodes]] string | nil

	clear: function()

	metamethod __call: function(self: yue, module: string): any...
end
return yue
