-- 用于提供 WASM 相关功能的模块。
local record Wasm
	-- 加载并执行一个主 WASM 模块文件 (例如 init.wasm)。
	-- @param filename (string) 主 WASM 模块文件的名称。
	executeMainFile: function(filename: string)

	-- 异步加载并执行一个主 WASM 模块文件 (例如 init.wasm)。
	-- @param filename (string) 主 WASM 模块文件的名称。
	-- @return (boolean) 是否成功执行主 WASM 模块文件。
	executeMainFileAsync: function(filename: string): boolean

	-- 从 Wa-lang 项目异步构建一个 WASM 模块文件 (例如 init.wasm)。
	-- 构建完成后会触发一个全局的事件 'WaLang'，事件类型为 'Build'。
	-- @param fullPath (string) Wa-lang 项目的完整路径。
	-- @return (boolean) 是否成功构建 WASM 模块文件。
	-- @usage
	-- local node = Node()
	-- node:gslot("WaLang", function(event: string, message: string)
	-- 	if event == "Build" then
	-- 		if message == "" then
	-- 			print("Built")
	-- 		else
	-- 			print("Build failed due to error: " .. message)
	-- 		end
	-- 	end
	-- end)
	-- thread(function()
	-- 	local success = Wasm:buildWaAsync("/path/to/wa-lang/project/")
	-- 	if success then
	-- 		print("Build started")
	-- 	else
	-- 		print("Build failed to start")
	-- 	end
	-- end)
	buildWaAsync: function(fullPath: string): boolean

	-- 异步格式化一个 Wa-lang 代码文件。
	-- 格式化完成后会触发一个全局的事件 'WaLang'，事件类型为 'Format'。
	-- @param fullPath (string) Wa-lang 代码文件的完整路径。
	-- @return (boolean) 是否成功格式化 Wa-lang 代码文件。
	-- @usage
	-- local node = Node()
	-- node:gslot("WaLang", function(event: string, message: string)
	-- 	if event == "Format" then
	-- 		if message == "" then
	-- 			print("Failted to format")
	-- 		else
	-- 			print("Formatted:" .. message)
	-- 		end
	-- 	end
	-- end)
	-- thread(function()
	-- 	local success = Wasm:formatWaAsync("/path/to/wa-lang/code/file.wa")
	-- 	if success then
	-- 		print("Formatting started")
	-- 	else
	-- 		print("Formatting failed to start")
	-- 	end
	-- end)
	formatWaAsync: function(fullPath: string): boolean

	-- 清除正在运行的 WASM 模块并停止相关 WASM 运行时。
	clear: function()
end

local wasm: Wasm
return wasm
