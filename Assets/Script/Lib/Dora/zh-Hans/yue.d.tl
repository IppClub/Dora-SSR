-- 月之脚本语言库。
local record yue

	-- 月之脚本版本。
	version: string

	-- 当前平台的文件分隔符。
	dirsep: string

	-- 编译模块代码缓存。
	yue_compiled: {string: string}

	-- 编译器编译选项。
	record Config

		-- 编译器是否应该收集代码中出现的全局变量。
		lint_global: boolean

		-- 编译器是否应该对根层级的代码块进行隐式的表达式返回。
		implicit_return_root: boolean

		-- 编译器是否应该在编译后的代码中保留原始行号。
		reserve_line_number: boolean

		-- 编译器是否应该在编译后的代码中使用空格字符而不是制表符字符。
		space_over_tab: boolean

		-- 编译器是否应该将要编译的代码视为当前正在编译的模块。仅供编译器内部使用。
		same_module: boolean

		-- 编译器错误消息是否应该包含行号偏移量。仅供编译器内部使用。
		line_offset: integer

		-- 目标 Lua 版本枚举。
		enum LuaTarget
			"5.1"
			"5.2"
			"5.3"
			"5.4"
			"5.5"
		end

		-- 额外编译器选项定义。
		record Options

			-- 编译目标 Lua 版本。
			target: LuaTarget

			-- 额外模块搜索路径。
			path: string

			-- 是否在回溯错误消息中输出代码块的局部变量。默认为 false。
			dump_locals: boolean

			-- 是否简化输出的错误消息。默认为 true。
			simplified: boolean

			-- 设置选项的元方法。
			-- @param key (string) 键。
			-- @param value (string) 值。
			metamethod __newindex: function(self: Options, key: string, value: string)

			-- 获取选项的元方法。
			-- @param key (string) 键。
			-- @return (string) 值。
			metamethod __index: function(self: Options, key: string): string
		end

		-- 要传递给编译函数的额外选项。
		options: Options
	end

	-- 月之脚本的编译函数。它将 YueScript 代码编译为 Lua 代码。
	-- @param code (string) YueScript 代码。
	-- @param config (Config) [可选] 编译器选项。
	-- @return (string | nil) 编译后的 Lua 代码，如果编译失败则为 nil。
	-- @return (string | nil) 错误消息，如果编译成功则为 nil。
	-- @return ({{string, integer, integer}} | nil) 代码中出现的全局变量（带有名称、行和列），如果编译器选项 `lint_global` 为 false 则为 nil。
	to_lua: function(code: string, config?: Config):
		--[[codes]] string | nil,
		--[[error]] string | nil,
		--[[globals]] {{string, integer, integer}} | nil

	-- 检查源文件是否存在的函数。可以覆盖该函数以自定义行为。
	-- @param filename (string) 文件名。
	-- @return (boolean) 文件是否存在。
	file_exist: function(filename: string): boolean

	-- 读取源文件的函数。可以覆盖该函数以自定义行为。
	-- @param filename (string) 文件名。
	-- @return (string) 文件内容。
	read_file: function(filename: string): string

	-- 将 YueScript 加载器插入到 Lua 包加载器（搜索器）中。
	-- @param pos (integer) [可选] 要插入加载器的位置。默认为 3。
	-- @return (boolean) 是否成功插入加载器。如果加载器已经插入，则返回失败。
	insert_loader: function(pos?: integer): boolean

	-- 从 Lua 包加载器（搜索器）中移除 YueScript 加载器。
	-- @return (boolean) 是否成功移除加载器。如果加载器未插入，则返回失败。
	remove_loader: function(): boolean

	-- 将 YueScript 代码字符串加载为一个函数。
	-- @param input (string) YueScript 代码。
	-- @param chunkname (string) 代码块的名称。
	-- @param env (table) 环境表。
	-- @param config (Config) [可选] 编译器选项。
	-- @return (function | nil) 加载的函数，如果加载失败则为 nil。
	-- @return (string | nil) 错误消息，如果加载成功则为 nil。
	loadstring: function(input: string, chunkname: string, env: table, config?: Config):
		--[[loaded function]] nil | function(...: any): (any...),
		--[[error]] string | nil

	-- 将 YueScript 代码字符串加载为一个函数。
	-- @param input (string) YueScript 代码。
	-- @param chunkname (string) 代码块的名称。
	-- @param config (Config) [可选] 编译器选项。
	-- @return (function | nil) 加载的函数，如果加载失败则为 nil。
	-- @return (string | nil) 错误消息，如果加载成功则为 nil。
	loadstring: function(input: string, chunkname: string, config?: Config):
		--[[loaded function]] nil | function(...: any): (any...),
		--[[error]] string | nil

	-- 将 YueScript 代码字符串加载为一个函数。
	-- @param input (string) YueScript 代码。
	-- @param config (Config) [可选] 编译器选项。
	-- @return (function | nil) 加载的函数，如果加载失败则为 nil。
	-- @return (string | nil) 错误消息，如果加载成功则为 nil。
	loadstring: function(input: string, config?: Config):
		--[[loaded function]] nil | function(...: any): (any...),
		--[[error]] string | nil

	-- 将 YueScript 代码文件加载为一个函数。
	-- @param filename (string) 文件名。
	-- @param env (table) 环境表。
	-- @param config (Config) [可选] 编译器选项。
	-- @return (function | nil) 加载的函数，如果加载失败则为 nil。
	-- @return (string | nil) 错误消息，如果加载成功则为 nil。
	loadfile: function(filename: string, env: table, config?: Config):
		nil | function(...: any): (any...),
		string | nil

	-- 将 YueScript 代码文件加载为一个函数。
	-- @param filename (string) 文件名。
	-- @param config (Config) [可选] 编译器选项。
	-- @return (function | nil) 加载的函数，如果加载失败则为 nil。
	-- @return (string | nil) 错误消息，如果加载成功则为 nil。
	loadfile: function(filename: string, config?: Config):
		nil | function(...: any): (any...),
		string | nil

	-- 将 YueScript 代码文件加载为一个函数并执行。
	-- @param filename (string) 文件名。
	-- @param env (table) 环境表。
	-- @param config (Config) [可选] 编译器选项。
	-- @return (any...) 加载的函数执行后的返回值。
	dofile: function(filename: string, env: table, config?: Config): any...

	-- 将 YueScript 代码文件加载为一个函数并执行。
	-- @param filename (string) 文件名。
	-- @param config (Config) [可选] 编译器选项。
	-- @return (any...) 加载的函数执行后的返回值。
	dofile: function(filename: string, config?: Config): any...

	-- 将 YueScript 模块名解析为文件路径。
	-- @param name (string) 模块名。
	-- @return (string) 文件路径。
	find_modulepath: function(name: string): string

	-- 在保护模式下调用一个函数。
	-- 会捕获任何错误，执行成功则返回成功状态和结果，否则为失败状态和错误信息。
	-- 当发生错误时，将错误信息中的代码行号重写为 YueScript 代码中的原始行号。
	-- @param f (function) 要调用的函数。
	-- @param ... (any) 要传递给函数的参数。
	-- @return (boolean, ...) 状态码和函数结果或错误信息。
	pcall: function(f: function, ...: any): boolean, any...

	-- 加载给定的模块。可以是 Lua 模块或 YueScript 模块。
	-- 如果模块是 YueScript 模块且加载失败，则将错误信息中的代码行号重写为 YueScript 代码中的原始行号。
	-- @param modname (string) 要加载的模块名。
	-- @return (any) 如果模块已经加载，则返回 package.loaded[modname] 中存储的值。
	-- 否则，尝试查找加载器并返回 package.loaded[modname] 的最终值和加载器数据作为第二个结果。
	require: function(name: string): any...

	-- 检查传递的值的内部结构，并打印值出它的字符串表示。
	-- @param ... (any) 要检查的值。
	p: function(...: any)

	-- 当前编译器选项。
	options: Config.Options

	-- 重写堆栈跟踪中的行号为 YueScript 代码中的原始行号的 traceback 函数。
	-- @param message (string) 堆栈跟踪消息。
	-- @return (string) 重写后的堆栈跟踪消息。
	traceback: function(message: string): string

	type CompileCodeHandler = function(
		codes: string,
		err: string,
		globals: {{string, integer, integer}}
	): string | nil

	-- 在线程中异步将 YueScript 代码编译为 Lua 代码。
	-- @param sourceFile (string) 源文件名。
	-- @param targetFile (string) 目标文件名。
	-- @param searchPath (string) 额外模块搜索路径。
	-- @param compileCodesHandler (CompileCodeHandler) 处理编译后的代码的回调函数。
	-- @param callback (function) 处理结果的回调函数。
	compile: function(
		sourceFile: string,
		targetFile: string,
		searchPath: string,
		compileCodesHandler: CompileCodeHandler,
		callback: function(result: boolean)
	)

	-- 检查代码是否匹配指定的 AST。
	-- @param astName (string) AST 名称。
	-- @param code (string) 代码。
	-- @return (boolean) 代码是否匹配 AST。
	is_ast: function(astName: string, code: string): boolean

	-- AST 类型定义，带有名称、行、列和子节点。
	type AST = {string, integer, integer, any}

	-- 将代码转换为 AST。
	-- @param code (string) 代码。
	-- @param flattenLevel (integer) [可选] 扁平化级别。级别越高，会消除更多的 AST 结构的嵌套。默认为 0。最大为 2。
	to_ast: function(code: string, flattenLevel?: number, astName?: string):
		--[[AST]] AST | nil,
		--[[error]] nil | string

	-- 在异步线程中检查 YueScript 代码中的问题。
	-- 只能在协程线程中调用。
	-- @param yueCodes (string) YueScript 代码。
	-- @param searchPath (string) 额外模块搜索路径。
	-- @param lax (boolean) 是否以宽松模式进行。
	-- @return ({info}) 包含类型、消息、行和列的问题信息数组。
	-- @return (string | nil) 当未发现问题时获得编译后的 Lua 代码，如果检查失败则为 nil。
	checkAsync: function(yueCodes: string, searchPath: string, lax: boolean):
		--[[info]] {{
			--[[type]] string,
			--[[msg]] string,
			--[[line]] integer,
			--[[col]] integer
		}},
		--[[luaCodes]] string | nil

	-- 清除缓存中的编译后的宏函数。
	clear: function()

	-- 导入 YueScript 模块。
	-- 如果发生加载失败，则将错误信息中的代码行号重写为 YueScript 代码中的原始行号。
	-- @param module (string) 模块名。
	-- @return (any) 模块值。
	metamethod __call: function(self: yue, module: string): any...
end

return yue
