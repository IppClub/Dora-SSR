-- A record that provides WASM related functions.
local record Wasm
	-- Executes the main WASM file (e.g. init.wasm).
	-- @param filename (string) The name of the main WASM file.
	executeMainFile: function(self: Wasm, filename: string)

	-- Executes the main WASM file (e.g. init.wasm) asynchronously.
	-- @param filename (string) The name of the main WASM file.
	-- @return (boolean) Whether the main WASM file was executed successfully.
	executeMainFileAsync: function(self: Wasm, filename: string): boolean

	-- Builds the WASM file (e.g. init.wasm) from a Wa-lang project asynchronously.
	-- @param fullPath (string) The full path of the Wa-lang project.
	-- @return (string) The WASM file building result.
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

	-- Formats a Wa-lang code file asynchronously.
	-- @param fullPath (string) The full path of the Wa-lang code file.
	-- @return (string) The Wa-lang code file formatting result.
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

	-- Clears the running WASM module and stops the runtime.
	clear: function(self: Wasm)
end

local wasm: Wasm
return wasm
