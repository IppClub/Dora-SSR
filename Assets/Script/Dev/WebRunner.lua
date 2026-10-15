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

local function findEntry(root)
	if type(root) ~= "string" or root == "" then
		return nil, "Web project root is empty"
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
		return nil, "Web project entry was not found: " .. root
	end
	return {
		entryName = Path:getName(root),
		fileName = entryFile,
		workDir = root,
		projectRoot = root,
		runKind = "webProject"
	}, nil
end

local function startEntry(entry, entryPath)
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

function M.runProject(root)
	local entry, err = findEntry(root)
	if not entry then
		Log("Error", err)
		return false
	end
	return startEntry(entry, Path(root, "init.lua"))
end

function M.runPackage(packagePath, projectId)
	if type(packagePath) ~= "string" or packagePath == "" then
		Log("Error", "Web .dora package path is empty")
		return false
	end
	if Path:getExt(packagePath) ~= "dora" then
		Log("Error", "Web package is not a .dora file: " .. packagePath)
		return false
	end
	local id = tostring(projectId or Path:getName(Path:replaceExt(packagePath, "")))
	local root = Path("/idbfs/dora/projects", id)
	if Content:exist(root) then
		Content:remove(root)
	end
	Entry.allClear()
	thread(function()
		Log("Info", "Extracting .dora package: " .. packagePath .. " -> " .. root)
		local success = Content:unzipAsync(packagePath, root, function(file)
			return not (file:match("^%.") or file:match("[\\/]%.") or file:match("__MACOSX"))
		end)
		if not success then
			Log("Error", "Failed to extract .dora package: " .. packagePath)
			return false
		end
		Log("Info", "Extracted .dora package: " .. root)
		local entry, err = findEntry(root)
		if not entry then
			Log("Error", err)
			return false
		end
		Log("Info", "Starting web project entry from .dora: " .. root)
		return Entry.enterEntryAsync(entry)
	end)
	return true
end

return M
