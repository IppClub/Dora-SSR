-- 用于提供 WASM 相关功能的模块。
local record Wasm
	-- 加载并执行一个主 WASM 模块文件 (例如 init.wasm)。
	-- @param filename (string) 主 WASM 模块文件的名称。
	executeMainFile: function(self: Wasm, filename: string)

	-- 异步加载并执行一个主 WASM 模块文件 (例如 init.wasm)。
	-- @param filename (string) 主 WASM 模块文件的名称。
	-- @return (boolean) 是否成功执行主 WASM 模块文件。
	executeMainFileAsync: function(self: Wasm, filename: string): boolean

	-- 从 Wa-lang 项目异步构建一个 WASM 模块文件 (例如 init.wasm)。
	-- @param fullPath (string) Wa-lang 项目的完整路径。
	-- @return (string) 构建 WASM 模块文件的结果。
	-- @usage
	-- thread(function()
	-- 	local result = Wasm:buildWaAsync("/path/to/wa-lang/project/")
	-- 	if result == "" then
	-- 		print("Built successfully!")
	-- 	else
	-- 		print("Failed to build, due to " .. result)
	-- 	end
	-- end)
	buildWaAsync: function(self: Wasm, fullPath: string): string

	-- 异步格式化一个 Wa-lang 代码文件。
	-- @param fullPath (string) Wa-lang 代码文件的完整路径。
	-- @return (string) 格式化 Wa-lang 代码文件的结果。
	-- @usage
	-- thread(function()
	-- 	local result = Wasm:formatWaAsync("/path/to/wa-lang/code/file.wa")
	-- 	if success == "" then
	-- 		print("Failed to format")
	-- 	else
	-- 		print("Formated code:" .. result)
	-- 	end
	-- end)
	formatWaAsync: function(self: Wasm, fullPath: string): string

	-- 清除正在运行的 WASM 模块并停止相关 WASM 运行时。
	clear: function(self: Wasm)
end

local wasm: Wasm
return wasm
