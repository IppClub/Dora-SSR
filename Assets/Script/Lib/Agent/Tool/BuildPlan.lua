-- [ts]: BuildPlan.ts
local ____lualib = require("lualib_bundle") -- 1
local Set = ____lualib.Set -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local Map = ____lualib.Map -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__Spread = ____lualib.__TS__Spread -- 1
local __TS__StringTrimEnd = ____lualib.__TS__StringTrimEnd -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__ArrayUnshift = ____lualib.__TS__ArrayUnshift -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local xml = require("Dora").xml -- 4
local function isBuildSource(file) -- 6
	if Path:getExt(file) ~= "xml" or not (xml and xml.isDoraTag) then -- 6
		return true -- 7
	end -- 7
	local content = Content:load(file) -- 8
	if content == nil then -- 8
		return true -- 9
	end -- 9
	local withoutBom = string.gsub(content, "^﻿", "") -- 10
	local source = withoutBom -- 11
	while true do -- 11
		local rest = string.match(source, "^%s*<!%-%-.-%-%->(.*)$") -- 13
		local afterInstruction = string.match(source, "^%s*<%?.-%?>(.*)$") -- 14
		local remaining = rest or afterInstruction -- 15
		if remaining == nil then -- 15
			break -- 16
		end -- 16
		source = remaining -- 17
	end -- 17
	local tag = string.match(source, "^%s*<([%w_:%.%-]+)") -- 19
	return tag == nil or xml.isDoraTag(tag) -- 20
end -- 6
--- Index directories in one traversal, then assign each source to its nearest project.
function ____exports.createDirectoryBuildPlanner(Content, Path, isBuildSource) -- 33
	if isBuildSource == nil then -- 33
		isBuildSource = function() return true end -- 36
	end -- 36
	local luaSourceExtensions = __TS__New(Set, { -- 38
		"ts", -- 38
		"tsx", -- 38
		"tl", -- 38
		"yue", -- 38
		"xml" -- 38
	}) -- 38
	return function(directory, enclosingProject, exclusions, extensionLevels) -- 39
		if exclusions == nil then -- 39
			exclusions = {} -- 42
		end -- 42
		directory = Path:getPath(Path(directory, "_")) -- 46
		local entries = __TS__ArrayMap( -- 47
			Content:glob( -- 47
				directory, -- 47
				{ -- 47
					"**", -- 48
					"!**/.agent/**", -- 48
					"!**/.git/**", -- 48
					"!**/.godot/**", -- 48
					"!**/.cache/**", -- 48
					"!**/.build/**", -- 49
					"!**/.www/**", -- 49
					"!**/.upload/**", -- 49
					"!**/.download/**", -- 49
					"!**/.native-export/**", -- 50
					"!**/node_modules/**", -- 50
					"!**/CMakeFiles/**", -- 51
					table.unpack(exclusions) -- 52
				}, -- 52
				extensionLevels, -- 53
				false -- 53
			), -- 53
			function(____, file) return Path(directory, file) end -- 53
		) -- 53
		local excluded = __TS__New(Set) -- 54
		for ____, file in ipairs(entries) do -- 55
			do -- 55
				if Path:getFilename(file) ~= ".dora-no-build" then -- 55
					goto __continue10 -- 56
				end -- 56
				local folder = Path:getPath(file) -- 57
				local hasTargets = false -- 58
				for ____, line in ipairs(__TS__StringSplit( -- 59
					table.concat( -- 59
						__TS__StringSplit( -- 59
							Content:load(file) or "", -- 59
							"\r" -- 59
						), -- 59
						"\n" -- 59
					), -- 59
					"\n" -- 59
				)) do -- 59
					do -- 59
						local target = __TS__StringTrim(line) -- 60
						if target == "" or __TS__StringStartsWith(target, "#") then -- 60
							goto __continue12 -- 61
						end -- 61
						hasTargets = true -- 62
						if Content:isAbsolutePath(target) then -- 62
							goto __continue12 -- 63
						end -- 63
						local relative = Path:getRelative( -- 64
							Path(folder, target), -- 64
							folder -- 64
						) -- 64
						if relative == "." or relative == ".." or __TS__StringStartsWith(relative, "../") or __TS__StringStartsWith(relative, "..\\") then -- 64
							goto __continue12 -- 65
						end -- 65
						excluded:add(Path(folder, relative)) -- 66
					end -- 66
					::__continue12:: -- 66
				end -- 66
				if not hasTargets then -- 66
					excluded:add(folder) -- 68
				end -- 68
			end -- 68
			::__continue10:: -- 68
		end -- 68
		local included = __TS__New(Map) -- 70
		local function isIncluded(dir) -- 71
			local cached = included:get(dir) -- 72
			if cached ~= nil then -- 72
				return cached -- 73
			end -- 73
			local parent = Path:getPath(dir) -- 74
			local result = not excluded:has(dir) and (dir == directory or parent ~= "" and parent ~= dir and isIncluded(parent)) -- 75
			included:set(dir, result) -- 76
			return result -- 77
		end -- 71
		local files = __TS__ArrayFilter( -- 79
			entries, -- 79
			function(____, file) return not excluded:has(file) and isIncluded(Path:getPath(file)) and isBuildSource(file) end -- 79
		) -- 79
		__TS__ArraySort(files) -- 80
		local sourceFiles = __TS__New(Set, files) -- 81
		local luaOutputs = __TS__New(Set) -- 82
		for ____, file in ipairs(files) do -- 83
			if luaSourceExtensions:has(Path:getExt(file)) and Path:getExt(Path:getName(file)) ~= "d" then -- 83
				luaOutputs:add(Path:replaceExt(file, "lua")) -- 85
			end -- 85
		end -- 85
		local projects = __TS__New(Map) -- 88
		local explicitRoots = __TS__New(Set) -- 89
		for ____, file in ipairs(files) do -- 90
			do -- 90
				local dir = Path:getPath(file) -- 91
				local name = Path:getFilename(file) -- 92
				if string.lower(Path:getName(file)) ~= "init" and name ~= "wa.mod" and name ~= "project.godot" then -- 92
					goto __continue25 -- 93
				end -- 93
				local project = projects:get(dir) -- 94
				if not project then -- 94
					project = {projectRoot = dir, files = {}} -- 96
					projects:set(dir, project) -- 97
				end -- 97
				if name == "wa.mod" or name == "project.godot" then -- 97
					explicitRoots:add(dir) -- 99
				end -- 99
				if name == "project.godot" then -- 99
					project.godot = dir -- 100
				end -- 100
			end -- 100
			::__continue25:: -- 100
		end -- 100
		local roots = __TS__ArraySort( -- 104
			{__TS__Spread(projects:keys())}, -- 104
			function(____, a, b) return #a - #b end -- 104
		) -- 104
		for ____, dir in ipairs(roots) do -- 105
			do -- 105
				if explicitRoots:has(dir) or dir == directory then -- 105
					goto __continue32 -- 106
				end -- 106
				local parent = Path:getPath(dir) -- 107
				while parent ~= "" and parent ~= dir and not projects:has(parent) and parent ~= enclosingProject do -- 107
					local next = Path:getPath(parent) -- 109
					if next == parent then -- 109
						break -- 110
					end -- 110
					parent = next -- 111
				end -- 111
				local moduleRoot = (projects:has(parent) or parent == enclosingProject) and __TS__StringSplit( -- 113
					table.concat( -- 114
						__TS__StringSplit( -- 114
							Path:getRelative(dir, parent), -- 114
							"\\" -- 114
						), -- 114
						"/" -- 114
					), -- 114
					"/" -- 114
				)[1] or nil -- 114
				if moduleRoot == "Script" or moduleRoot == "Lib" or Content:exist(dir .. ".d.ts") then -- 114
					projects:delete(dir) -- 117
				end -- 117
			end -- 117
			::__continue32:: -- 117
		end -- 117
		local remainder = {projectRoot = enclosingProject, files = {}} -- 120
		local ownerByDirectory = __TS__New(Map) -- 121
		local function owner(dir) -- 122
			local existing = projects:get(dir) or ownerByDirectory:get(dir) -- 123
			if existing then -- 123
				return existing -- 124
			end -- 124
			local parent = Path:getPath(dir) -- 125
			local project = (dir == directory or parent == dir or parent == "") and remainder or owner(parent) -- 126
			ownerByDirectory:set(dir, project) -- 127
			return project -- 128
		end -- 122
		for ____, file in ipairs(files) do -- 130
			do -- 130
				if luaOutputs:has(file) then -- 130
					local lines = __TS__StringSplit( -- 132
						Content:read(file, 0, 256) or "", -- 132
						"\n", -- 132
						2 -- 132
					) -- 132
					local header = __TS__StringTrimEnd(lines[1]) == "-- tic80" and (lines[2] or "") or lines[1]
					local sourceExt = __TS__StringStartsWith(header, "-- [") and __TS__StringIncludes(header, "]:") and string.sub(
						__TS__StringSplit(header, "]:", 2)[1], -- 134
						5 -- 134
					) or "" -- 134
					if luaSourceExtensions:has(sourceExt) and sourceFiles:has(Path:replaceExt(file, sourceExt)) then -- 134
						goto __continue40 -- 136
					end -- 136
				end -- 136
				local ____owner_result_files_2 = owner(Path:getPath(file)).files -- 136
				____owner_result_files_2[#____owner_result_files_2 + 1] = file -- 138
			end -- 138
			::__continue40:: -- 138
		end -- 138
		local units = {__TS__Spread(projects:values())} -- 140
		if #remainder.files > 0 then -- 140
			__TS__ArrayUnshift(units, remainder) -- 141
		end -- 141
		return units -- 142
	end -- 39
end -- 33
____exports.planDirectoryBuild = ____exports.createDirectoryBuildPlanner(Content, Path, isBuildSource) -- 146
return ____exports -- 146