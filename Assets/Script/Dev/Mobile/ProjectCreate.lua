-- [ts]: ProjectCreate.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Content = ____Dora.Content -- 1
local Path = ____Dora.Path -- 1
____exports.mobileTypeScriptProjectTemplate = "// @preview-file on clear\nimport {} from 'Dora';\n\n" -- 3
____exports.mobileTypeScriptProjectLuaTemplate = "-- [ts]: init.ts\nlocal ____exports = {}\nreturn ____exports\n"
local function defaultStorage() -- 22
	return { -- 22
		workspace = Content.writablePath, -- 23
		getDirs = function(path) return Content:getDirs(path) end, -- 24
		getFiles = function(path) return Content:getFiles(path) end, -- 25
		exist = function(path) return Content:exist(path) end, -- 26
		mkdir = function(path) return Content:mkdir(path) end, -- 27
		save = function(path, content) return Content:save(path, content) end, -- 28
		remove = function(path) return Content:remove(path) end -- 29
	} -- 29
end -- 22
____exports.normalizeMobileProjectName = function(name) -- 32
	local normalized = __TS__StringTrim(name) -- 33
	if normalized == "" or normalized == "." or normalized == ".." then -- 33
		return nil -- 34
	end -- 34
	if (string.find(normalized, "/", nil, true) or 0) - 1 >= 0 or (string.find(normalized, "\\", nil, true) or 0) - 1 >= 0 then -- 34
		return nil -- 35
	end -- 35
	return normalized -- 36
end -- 32
function ____exports.createMobileTypeScriptProject(name, storage) -- 39
	if storage == nil then -- 39
		storage = defaultStorage() -- 39
	end -- 39
	local normalized = ____exports.normalizeMobileProjectName(name) -- 40
	if not normalized then -- 40
		return {success = false, error = "invalid-name"} -- 41
	end -- 41
	local targetName = string.lower(normalized) -- 43
	local ____array_0 = __TS__SparseArrayNew(table.unpack(storage.getDirs(storage.workspace))) -- 43
	__TS__SparseArrayPush( -- 43
		____array_0, -- 43
		table.unpack(storage.getFiles(storage.workspace)) -- 44
	) -- 44
	local collision = __TS__ArraySome( -- 44
		{__TS__SparseArraySpread(____array_0)}, -- 44
		function(____, item) return string.lower(item) == targetName end -- 45
	) -- 45
	local workDir = Path(storage.workspace, normalized) -- 46
	if collision or storage.exist(workDir) then -- 46
		return {success = false, error = "target-existed"} -- 47
	end -- 47
	if not storage.mkdir(workDir) then -- 47
		return {success = false, error = "create-folder-failed"} -- 48
	end -- 48
	local entryFile = Path(workDir, "init.ts") -- 50
	if not storage.save(entryFile, ____exports.mobileTypeScriptProjectTemplate) then -- 50
		storage.remove(workDir) -- 52
		return {success = false, error = "create-entry-failed"} -- 53
	end -- 53
	if not storage.save( -- 53
		Path(workDir, "init.lua"), -- 55
		____exports.mobileTypeScriptProjectLuaTemplate -- 55
	) then -- 55
		storage.remove(workDir) -- 56
		return {success = false, error = "create-entry-failed"} -- 57
	end -- 57
	return { -- 59
		success = true, -- 59
		name = normalized, -- 59
		workDir = workDir, -- 59
		fileName = Path(workDir, "init") -- 59
	} -- 59
end -- 39
return ____exports -- 39
