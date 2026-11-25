-- [ts]: BuildPlan.ts
local ____lualib = require("lualib_bundle") -- 1
local Set = ____lualib.Set -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local Map = ____lualib.Map -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__Spread = ____lualib.__TS__Spread -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArrayUnshift = ____lualib.__TS__ArrayUnshift -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local xml = require("Dora").xml -- 4
local luaSourceExtensions = __TS__New(Set, { -- 5
	"ts", -- 5
	"tsx", -- 5
	"tl", -- 5
	"yue", -- 5
	"xml" -- 5
}) -- 5
local function isBuildSource(file) -- 7
	if Path:getExt(file) ~= "xml" or not (xml and xml.isDoraTag) then -- 7
		return true -- 8
	end -- 8
	local content = Content:load(file) -- 9
	if content == nil then -- 9
		return true -- 10
	end -- 10
	local withoutBom = string.gsub(content, "^﻿", "") -- 11
	local source = withoutBom -- 12
	while true do -- 12
		local rest = string.match(source, "^%s*<!%-%-.-%-%->(.*)$") -- 14
		local afterInstruction = string.match(source, "^%s*<%?.-%?>(.*)$") -- 15
		local remaining = rest or afterInstruction -- 16
		if remaining == nil then -- 16
			break -- 17
		end -- 17
		source = remaining -- 18
	end -- 18
	local tag = string.match(source, "^%s*<([%w_:%.%-]+)") -- 20
	return tag == nil or xml.isDoraTag(tag) -- 21
end -- 7
--- Index directories in one traversal, then assign each source to its nearest project.
function ____exports.planDirectoryBuild(directory, enclosingProject, exclusions, extensionLevels) -- 31
	if exclusions == nil then -- 31
		exclusions = {} -- 34
	end -- 34
	directory = Path:getPath(Path(directory, "_")) -- 38
	local entries = __TS__ArrayMap( -- 39
		Content:glob( -- 39
			directory, -- 39
			{ -- 39
				"**", -- 40
				"!**/.agent/**", -- 40
				"!**/.git/**", -- 40
				"!**/.godot/**", -- 40
				"!**/.cache/**", -- 40
				"!**/.build/**", -- 41
				"!**/.www/**", -- 41
				"!**/.upload/**", -- 41
				"!**/.download/**", -- 41
				"!**/.native-export/**", -- 42
				"!**/node_modules/**", -- 42
				"!**/CMakeFiles/**", -- 43
				table.unpack(exclusions) -- 44
			}, -- 44
			extensionLevels, -- 45
			false -- 45
		), -- 45
		function(____, file) return Path(directory, file) end -- 45
	) -- 45
	local excluded = __TS__New(Set) -- 46
	for ____, file in ipairs(entries) do -- 47
		do -- 47
			if Path:getFilename(file) ~= ".dora-no-build" then -- 47
				goto __continue9 -- 48
			end -- 48
			local folder = Path:getPath(file) -- 49
			local hasTargets = false -- 50
			for line in string.gmatch( -- 51
				Content:load(file) or "", -- 51
				"([^\r\n]+)" -- 51
			) do -- 51
				do -- 51
					local target = __TS__StringTrim(line) -- 52
					if target == "" or __TS__StringStartsWith(target, "#") then -- 52
						goto __continue11 -- 53
					end -- 53
					hasTargets = true -- 54
					if Content:isAbsolutePath(target) then -- 54
						goto __continue11 -- 55
					end -- 55
					local relative = Path:getRelative( -- 56
						Path(folder, target), -- 56
						folder -- 56
					) -- 56
					if relative == "." or relative == ".." or __TS__StringStartsWith(relative, "../") or __TS__StringStartsWith(relative, "..\\") then -- 56
						goto __continue11 -- 57
					end -- 57
					excluded:add(Path(folder, relative)) -- 58
				end -- 58
				::__continue11:: -- 58
			end -- 58
			if not hasTargets then -- 58
				excluded:add(folder) -- 60
			end -- 60
		end -- 60
		::__continue9:: -- 60
	end -- 60
	local included = __TS__New(Map) -- 62
	local function isIncluded(dir) -- 63
		local cached = included:get(dir) -- 64
		if cached ~= nil then -- 64
			return cached -- 65
		end -- 65
		local parent = Path:getPath(dir) -- 66
		local result = not excluded:has(dir) and (dir == directory or parent ~= "" and parent ~= dir and isIncluded(parent)) -- 67
		included:set(dir, result) -- 68
		return result -- 69
	end -- 63
	local files = __TS__ArrayFilter( -- 71
		entries, -- 71
		function(____, file) return not excluded:has(file) and isIncluded(Path:getPath(file)) and isBuildSource(file) end -- 71
	) -- 71
	__TS__ArraySort(files) -- 72
	local sourceFiles = __TS__New(Set, files) -- 73
	local luaOutputs = __TS__New(Set) -- 74
	for ____, file in ipairs(files) do -- 75
		if luaSourceExtensions:has(Path:getExt(file)) and Path:getExt(Path:getName(file)) ~= "d" then -- 75
			luaOutputs:add(Path:replaceExt(file, "lua")) -- 77
		end -- 77
	end -- 77
	local projects = __TS__New(Map) -- 80
	local explicitRoots = __TS__New(Set) -- 81
	for ____, file in ipairs(files) do -- 82
		do -- 82
			local dir = Path:getPath(file) -- 83
			local name = Path:getFilename(file) -- 84
			if string.lower(Path:getName(file)) ~= "init" and name ~= "wa.mod" and name ~= "project.godot" then -- 84
				goto __continue23 -- 85
			end -- 85
			local project = projects:get(dir) -- 86
			if not project then -- 86
				project = {projectRoot = dir, files = {}} -- 88
				projects:set(dir, project) -- 89
			end -- 89
			if name == "wa.mod" or name == "project.godot" then -- 89
				explicitRoots:add(dir) -- 91
			end -- 91
			if name == "project.godot" then -- 91
				project.godot = dir -- 92
			end -- 92
		end -- 92
		::__continue23:: -- 92
	end -- 92
	local roots = __TS__ArraySort( -- 96
		{__TS__Spread(projects:keys())}, -- 96
		function(____, a, b) return #a - #b end -- 96
	) -- 96
	for ____, dir in ipairs(roots) do -- 97
		do -- 97
			if explicitRoots:has(dir) or dir == directory then -- 97
				goto __continue30 -- 98
			end -- 98
			local parent = Path:getPath(dir) -- 99
			while parent ~= "" and parent ~= dir and not projects:has(parent) and parent ~= enclosingProject do -- 99
				local next = Path:getPath(parent) -- 101
				if next == parent then -- 101
					break -- 102
				end -- 102
				parent = next -- 103
			end -- 103
			local moduleRoot = (projects:has(parent) or parent == enclosingProject) and __TS__StringSplit( -- 105
				table.concat( -- 106
					__TS__StringSplit( -- 106
						Path:getRelative(dir, parent), -- 106
						"\\" -- 106
					), -- 106
					"/" -- 106
				), -- 106
				"/" -- 106
			)[1] or nil -- 106
			if moduleRoot == "Script" or moduleRoot == "Lib" or Content:exist(dir .. ".d.ts") then -- 106
				projects:delete(dir) -- 109
			end -- 109
		end -- 109
		::__continue30:: -- 109
	end -- 109
	local remainder = {projectRoot = enclosingProject, files = {}} -- 112
	local ownerByDirectory = __TS__New(Map) -- 113
	local function owner(dir) -- 114
		local existing = projects:get(dir) or ownerByDirectory:get(dir) -- 115
		if existing then -- 115
			return existing -- 116
		end -- 116
		local parent = Path:getPath(dir) -- 117
		local project = (dir == directory or parent == dir or parent == "") and remainder or owner(parent) -- 118
		ownerByDirectory:set(dir, project) -- 119
		return project -- 120
	end -- 114
	for ____, file in ipairs(files) do -- 122
		do -- 122
			if luaOutputs:has(file) then -- 122
				local header = string.gsub( -- 124
					Content:read(file, 0, 256) or "", -- 124
					"^%-%- tic80\r?\n", -- 124
					"" -- 124
				) -- 124
				local sourceExt = string.match(header, "^%-%- %[(%a+)%]:") -- 125
				if sourceExt ~= nil and luaSourceExtensions:has(sourceExt) and sourceFiles:has(Path:replaceExt(file, sourceExt)) then -- 125
					goto __continue38 -- 127
				end -- 127
			end -- 127
			local ____owner_result_files_2 = owner(Path:getPath(file)).files -- 127
			____owner_result_files_2[#____owner_result_files_2 + 1] = file -- 129
		end -- 129
		::__continue38:: -- 129
	end -- 129
	local units = {__TS__Spread(projects:values())} -- 131
	if #remainder.files > 0 then -- 131
		__TS__ArrayUnshift(units, remainder) -- 132
	end -- 132
	return units -- 133
end -- 31
return ____exports -- 31