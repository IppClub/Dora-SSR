local record yue
	enum LoadMode
		"b"
		"t"
		"bt"
	end
	record Config
		lint_global: boolean
		implicit_return_root: boolean
		reserve_line_number: boolean
		space_over_tab: boolean
		same_module: boolean
		line_offset: integer
	end
	dirsep: string
	yue_compiled: {string:string}
	version: string
	to_lua: function(code: string, config: Config): string, string
	file_exist: function(filename: string): boolean
	read_file: function(filename: string): string
	insert_loader: function(pos: integer): boolean
	remove_loader: function(): boolean
	loader: function(name: string): string, string
	loadstring: function(input: string, chunkname: string, mode: LoadMode, ...: {any:any}): function(...: any): (any...), string
	loadfile: function(filename: string, chunkname: string, mode: LoadMode, ...: {any:any}): function(...: any): (any...), string
	dofile: function(filename: string, chunkname: string, mode: LoadMode, ...: {any:any}): any...
	create_yuepath: function(package_path: string): string
	find_modulepath: function(name: string): string
	pcall: function(f: function, ...: any): boolean, any...
	require: function(name: string): any...
	p: function(...: any)
	options: {string: string}
	metamethod __call: function(self: yue, module: string): any...
end
return yue
