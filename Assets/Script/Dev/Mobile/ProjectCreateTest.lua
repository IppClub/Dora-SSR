-- [ts]: ProjectCreateTest.ts
local ____lualib = require("lualib_bundle") -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Content = ____Dora.Content -- 1
local Path = ____Dora.Path -- 1
local ____ProjectCreate = require("Dev.Mobile.ProjectCreate") -- 2
local createMobileTypeScriptProject = ____ProjectCreate.createMobileTypeScriptProject -- 2
local mobileTypeScriptProjectLuaTemplate = ____ProjectCreate.mobileTypeScriptProjectLuaTemplate -- 2
local mobileTypeScriptProjectTemplate = ____ProjectCreate.mobileTypeScriptProjectTemplate -- 2
local resultPath = Path(Content.writablePath, "dora-mobile-project-create.result") -- 4
Content:save(resultPath, "running\n") -- 5
local function expect(condition, message) -- 7
	if condition then -- 7
		return -- 8
	end -- 8
	Content:save(resultPath, ("failed " .. message) .. "\n") -- 9
	error( -- 10
		__TS__New(Error, message), -- 10
		0 -- 10
	) -- 10
end -- 7
local function storage(options) -- 13
	local dirs = {table.unpack(options and options.dirs or ({}))} -- 14
	local files = {table.unpack(options and options.files or ({}))} -- 15
	local saved = {} -- 16
	local removed = {} -- 17
	local saveCount = 0 -- 18
	local value = { -- 19
		workspace = "/workspace", -- 20
		getDirs = function() return dirs end, -- 21
		getFiles = function() return files end, -- 22
		exist = function(path) return __TS__ArraySome( -- 23
			dirs, -- 23
			function(____, item) return Path("/workspace", item) == path end -- 23
		) or __TS__ArraySome( -- 23
			files, -- 23
			function(____, item) return Path("/workspace", item) == path end -- 23
		) end, -- 23
		mkdir = function(path) -- 24
			if (options and options.mkdir) == false then -- 24
				return false -- 25
			end -- 25
			dirs[#dirs + 1] = Path:getFilename(path) -- 26
			return true -- 27
		end, -- 24
		save = function(path, content) -- 29
			saveCount = saveCount + 1 -- 30
			if (options and options.save) == false or (options and options.failSaveAt) == saveCount then -- 30
				return false -- 31
			end -- 31
			saved[path] = content -- 32
			return true -- 33
		end, -- 29
		remove = function(path) -- 35
			removed[#removed + 1] = path -- 36
			local name = Path:getFilename(path) -- 37
			local index = __TS__ArrayIndexOf(dirs, name) -- 38
			if index >= 0 then -- 38
				__TS__ArraySplice(dirs, index, 1) -- 39
			end -- 39
			return true -- 40
		end -- 35
	} -- 35
	return {value = value, dirs = dirs, saved = saved, removed = removed} -- 43
end -- 13
__TS__ArrayForEach( -- 46
	{ -- 46
		"", -- 46
		"   ", -- 46
		".", -- 46
		"..", -- 46
		"a/b", -- 46
		"a\\b" -- 46
	}, -- 46
	function(____, name) -- 46
		local fake = storage() -- 47
		local result = createMobileTypeScriptProject(name, fake.value) -- 48
		expect(not result.success and result.error == "invalid-name", "invalid name accepted: " .. name) -- 49
		expect(#fake.dirs == 0, "invalid name created a folder: " .. name) -- 50
	end -- 46
) -- 46
for ____, fake in ipairs({ -- 53
	storage({dirs = {"Existing"}}), -- 53
	storage({files = {"Existing"}}) -- 53
}) do -- 53
	local result = createMobileTypeScriptProject("existing", fake.value) -- 54
	expect(not result.success and result.error == "target-existed", "case-insensitive collision was not rejected") -- 55
end -- 55
do -- 55
	local fake = storage({mkdir = false}) -- 59
	local result = createMobileTypeScriptProject("Game", fake.value) -- 60
	expect(not result.success and result.error == "create-folder-failed", "folder failure mismatch") -- 61
	expect(#fake.removed == 0, "folder failure removed an existing path") -- 62
end -- 62
do -- 62
	local fake = storage({save = false}) -- 66
	local result = createMobileTypeScriptProject("Game", fake.value) -- 67
	expect(not result.success and result.error == "create-entry-failed", "entry failure mismatch") -- 68
	expect(#fake.removed == 1 and fake.removed[1] == "/workspace/Game", "entry failure did not roll back only the new folder") -- 69
end -- 69
do -- 69
	local fake = storage({failSaveAt = 2}) -- 73
	local result = createMobileTypeScriptProject("Game", fake.value) -- 74
	expect(not result.success and result.error == "create-entry-failed", "runnable entry failure mismatch") -- 75
	expect(#fake.removed == 1 and fake.removed[1] == "/workspace/Game", "runnable entry failure did not roll back only the new folder") -- 76
end -- 76
do -- 76
	local fake = storage() -- 80
	local result = createMobileTypeScriptProject("  Star Garden  ", fake.value) -- 81
	expect(result.success, "valid project was not created") -- 82
	if result.success then -- 82
		expect(result.name == "Star Garden" and result.workDir == "/workspace/Star Garden", "project normalization mismatch") -- 84
		expect(result.fileName == "/workspace/Star Garden/init", "entry path mismatch") -- 85
		expect(fake.saved["/workspace/Star Garden/init.ts"] == mobileTypeScriptProjectTemplate, "TypeScript template mismatch") -- 86
		expect(fake.saved["/workspace/Star Garden/init.lua"] == mobileTypeScriptProjectLuaTemplate, "runnable Lua template mismatch") -- 87
		expect(#fake.removed == 0, "successful project was rolled back") -- 88
	end -- 88
end -- 88
Content:save(resultPath, "passed invalid=6 collision=2 folderFailure=1 rollback=2 success=1\n") -- 92
return ____exports -- 92
