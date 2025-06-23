-- A record that provides WASM related functions.
local record Wasm
	-- Executes the main WASM file (e.g. init.wasm).
	-- @param filename (string) The name of the main WASM file.
	executeMainFile: function(filename: string)

	-- Executes the main WASM file (e.g. init.wasm) asynchronously.
	-- @param filename (string) The name of the main WASM file.
	-- @return (boolean) Whether the main WASM file was executed successfully.
	executeMainFileAsync: function(filename: string): boolean

	-- Builds the WASM file (e.g. init.wasm) from a Wa-lang project asynchronously.
	-- Will trigger a global event 'WaLang' with event type 'Build' when the build is finished.
	-- @param fullPath (string) The full path of the Wa-lang project.
	-- @return (boolean) Whether the WASM file was built successfully.
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

	-- Formats a Wa-lang code file asynchronously.
	-- Will trigger a global event 'WaLang' with event type 'Format' when the format is finished.
	-- @param fullPath (string) The full path of the Wa-lang code file.
	-- @return (boolean) Whether the Wa-lang code file was formatted successfully.
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

	-- Clears the running WASM module and stops the runtime.
	clear: function()
end

local wasm: Wasm
return wasm
