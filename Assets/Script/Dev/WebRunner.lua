local Dora = Dora
local Path = Dora.Path
local Content = Dora.Content
local Log = Dora.Log
local thread = Dora.thread

local Entry = package.loaded["Script.Dev.Entry"]
if not Entry then
	-- A failed or interrupted Dev.Entry load can leave Utils' Struct
	-- definitions alive while Config itself is no longer cached. Reset both
	-- modules before retrying so Struct.Config is defined exactly once.
	local Utils = package.loaded["Utils"]
	if Utils and Utils.Struct then
		Utils.Struct:clear()
	end
	package.loaded["Config"] = nil
	package.loaded["Utils"] = nil
	Entry = require("Script.Dev.Entry")
end

local M = {}

function M.runProject(root)
	if type(root) ~= "string" or root == "" then
		Log("Error", "Web project root is empty")
		return false
	end
	local entryFile = Path(root, "init")
	local entryPath = Path(root, "init.lua")
	if not Content:exist(entryPath) then
		for _, ext in ipairs({"yue", "tl", "wasm"}) do
			local candidate = Path(root, "init." .. ext)
			if Content:exist(candidate) then
				entryPath = candidate
				break
			end
		end
	end
	if not Content:exist(entryPath) then
		Log("Error", "Web project entry was not found: " .. root)
		return false
	end
	local entry = {
		entryName = Path:getName(root),
		fileName = entryFile,
		workDir = root,
		projectRoot = root,
		runKind = "webProject"
	}
	Log("Info", "Starting web project entry: " .. entryPath)
	-- allClear removes ordinary routines. Run it before creating the entry
	-- coroutine, otherwise the cleanup pass removes this runner itself before
	-- enterEntryAsync can resume after its initial sleep.
	Entry.allClear()
	thread(function()
		return Entry.enterEntryAsync(entry)
	end)
	return true
end

return M
