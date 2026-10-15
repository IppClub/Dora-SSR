-- [ts]: ProjectCreate.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local ____exports = {} -- 1
local defaultStorage -- 1
local ____Dora = require("Dora") -- 1
local Content = ____Dora.Content -- 1
local Path = ____Dora.Path -- 1
function ____exports.createMobileProject(name, language, storage) -- 45
	if language == nil then -- 45
		language = "typescript" -- 45
	end -- 45
	if storage == nil then -- 45
		storage = defaultStorage() -- 45
	end -- 45
	local normalized = ____exports.normalizeMobileProjectName(name) -- 46
	if not normalized then -- 46
		return {success = false, error = "invalid-name"} -- 47
	end -- 47
	local targetName = string.lower(normalized) -- 49
	local ____array_0 = __TS__SparseArrayNew(table.unpack(storage.getDirs(storage.workspace))) -- 49
	__TS__SparseArrayPush( -- 49
		____array_0, -- 49
		table.unpack(storage.getFiles(storage.workspace)) -- 50
	) -- 50
	local collision = __TS__ArraySome( -- 50
		{__TS__SparseArraySpread(____array_0)}, -- 50
		function(____, item) return string.lower(item) == targetName end -- 51
	) -- 51
	local workDir = Path(storage.workspace, normalized) -- 52
	if collision or storage.exist(workDir) then -- 52
		return {success = false, error = "target-existed"} -- 53
	end -- 53
	if not storage.mkdir(workDir) then -- 53
		return {success = false, error = "create-folder-failed"} -- 54
	end -- 54
	local entryFile = Path(workDir, language == "lua" and "init.lua" or "init.ts") -- 56
	if not storage.save(entryFile, language == "lua" and ____exports.mobileLuaProjectTemplate or ____exports.mobileTypeScriptProjectTemplate) then -- 56
		storage.remove(workDir) -- 58
		return {success = false, error = "create-entry-failed"} -- 59
	end -- 59
	if language == "typescript" and not storage.save( -- 59
		Path(workDir, "init.lua"), -- 61
		____exports.mobileTypeScriptProjectLuaTemplate -- 61
	) then -- 61
		storage.remove(workDir) -- 62
		return {success = false, error = "create-entry-failed"} -- 63
	end -- 63
	return { -- 65
		success = true, -- 65
		name = normalized, -- 65
		workDir = workDir, -- 65
		fileName = Path(workDir, "init") -- 65
	} -- 65
end -- 45
____exports.mobileTypeScriptProjectTemplate = "// @preview-file on clear\nimport {} from 'Dora';\n\n" -- 3
____exports.mobileTypeScriptProjectLuaTemplate = "-- [ts]: init.ts\nlocal ____exports = {}\nreturn ____exports\n"
____exports.mobileLuaProjectTemplate = "-- @preview-file on clear\nlocal Dora = require(\"Dora\")\n\n"
defaultStorage = function() return { -- 24
	workspace = Content.writablePath, -- 25
	getDirs = function(path) return Content:getDirs(path) end, -- 26
	getFiles = function(path) return Content:getFiles(path) end, -- 27
	exist = function(path) return Content:exist(path) end, -- 28
	mkdir = function(path) return Content:mkdir(path) end, -- 29
	save = function(path, content) return Content:save(path, content) end, -- 30
	remove = function(path) return Content:remove(path) end -- 31
} end -- 31
____exports.normalizeMobileProjectName = function(name) -- 34
	local normalized = __TS__StringTrim(name) -- 35
	if normalized == "" or normalized == "." or normalized == ".." then -- 35
		return nil -- 36
	end -- 36
	if (string.find(normalized, "/", nil, true) or 0) - 1 >= 0 or (string.find(normalized, "\\", nil, true) or 0) - 1 >= 0 then -- 36
		return nil -- 37
	end -- 37
	return normalized -- 38
end -- 34
function ____exports.createMobileTypeScriptProject(name, storage) -- 41
	if storage == nil then -- 41
		storage = defaultStorage() -- 41
	end -- 41
	return ____exports.createMobileProject(name, "typescript", storage) -- 42
end -- 41
return ____exports -- 41