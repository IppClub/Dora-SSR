-- [ts]: Manifest.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local json = ____Dora.json -- 2
local Path = ____Dora.Path -- 2
____exports.updatePlatformsForVersion = function(version) return ____exports.compareVersions(version, "v1.10.0") >= 0 and ({"android", "windows-x64", "macos-arm64"}) or ({"android", "windows-x86", "macos-universal"}) end -- 6
local versionPattern = "^v%d+%.%d+%.%d+$" -- 33
local function matches(value, pattern) -- 34
	return (string.match(value, pattern)) ~= nil -- 34
end -- 34
local function isLowerHex(value, length) -- 35
	return #value == length and matches(value, "^[0-9a-f]+$") -- 35
end -- 35
local function hasOnlyKeys(value, allowed) -- 36
	for key in pairs(value) do -- 37
		local found = false -- 38
		for ____, allowedKey in ipairs(allowed) do -- 39
			if key == allowedKey then -- 39
				found = true -- 41
				break -- 42
			end -- 42
		end -- 42
		if not found then -- 42
			return false -- 45
		end -- 45
	end -- 45
	return true -- 47
end -- 36
local function parsePackage(value, platform, version, revision) -- 55
	if type(value) ~= "table" or value == nil then -- 55
		return {message = platform .. " package is missing"} -- 62
	end -- 62
	if not hasOnlyKeys(value, { -- 62
		"ref", -- 64
		"commit", -- 64
		"file", -- 64
		"size", -- 64
		"sha256", -- 64
		"github" -- 64
	}) then -- 64
		return {message = platform .. " package contains unsupported fields"} -- 65
	end -- 65
	local item = value -- 67
	if type(item.ref) ~= "string" or item.ref ~= (((("refs/tags/" .. version) .. "-") .. tostring(revision)) .. "-") .. platform then -- 67
		return {message = platform .. " package ref is invalid"} -- 70
	end -- 70
	if type(item.commit) ~= "string" or not isLowerHex(item.commit, 40) then -- 70
		return {message = platform .. " package commit is invalid"} -- 73
	end -- 73
	if type(item.file) ~= "string" or item.file ~= ((("dora-ssr-" .. version) .. "-") .. platform) .. ".zip" or Path:getFilename(item.file) ~= item.file then -- 73
		return {message = platform .. " package file is invalid"} -- 78
	end -- 78
	if type(item.size) ~= "number" or item.size < 1 or item.size > 2 * 1024 * 1024 * 1024 then -- 78
		return {message = platform .. " package size is invalid"} -- 81
	end -- 81
	if type(item.sha256) ~= "string" or not isLowerHex(item.sha256, 64) then -- 81
		return {message = platform .. " package SHA-256 is invalid"} -- 84
	end -- 84
	local github = (("https://github.com/IppClub/Dora-SSR/releases/download/" .. version) .. "/") .. item.file -- 86
	if type(item.github) ~= "string" or item.github ~= github then -- 86
		return {message = platform .. " GitHub URL is invalid"} -- 88
	end -- 88
	return {item = item} -- 90
end -- 55
____exports.parseUpdateManifest = function(text) -- 93
	if #text > 128 * 1024 then -- 93
		return {message = "update manifest is too large"} -- 94
	end -- 94
	local decoded, err = json.decode(text) -- 95
	if err ~= nil or type(decoded) ~= "table" or decoded == nil then -- 95
		return {message = "update manifest is not valid JSON"} -- 97
	end -- 97
	if not hasOnlyKeys(decoded, { -- 97
		"$schema", -- 99
		"schemaVersion", -- 99
		"channel", -- 99
		"version", -- 99
		"revision", -- 99
		"publishedAt", -- 99
		"packages" -- 99
	}) then -- 99
		return {message = "update manifest contains unsupported fields"} -- 100
	end -- 100
	if decoded["$schema"] ~= "./schema/stable-v1.schema.json" then -- 100
		return {message = "update manifest schema reference is invalid"} -- 103
	end -- 103
	local value = decoded -- 105
	if value.schemaVersion ~= 1 or value.channel ~= "stable" then -- 105
		return {message = "unsupported update manifest schema"} -- 107
	end -- 107
	if type(value.version) ~= "string" or not matches(value.version, versionPattern) then -- 107
		return {message = "update manifest version is invalid"} -- 110
	end -- 110
	if type(value.revision) ~= "number" or value.revision < 0 or math.floor(value.revision) ~= value.revision then -- 110
		return {message = "update manifest revision is invalid"} -- 113
	end -- 113
	if type(value.publishedAt) ~= "string" or #value.publishedAt > 64 then -- 113
		return {message = "update manifest publication time is invalid"} -- 116
	end -- 116
	if type(value.packages) ~= "table" or value.packages == nil then -- 116
		return {message = "update manifest packages are missing"} -- 119
	end -- 119
	local platforms = ____exports.updatePlatformsForVersion(value.version) -- 121
	if not hasOnlyKeys(value.packages, platforms) then -- 121
		return {message = "update manifest contains unsupported platforms"} -- 123
	end -- 123
	local packages = {} -- 125
	for ____, platform in ipairs(platforms) do -- 126
		local packageResult = parsePackage(value.packages[platform], platform, value.version, value.revision) -- 127
		if not packageResult.item then -- 127
			return {message = packageResult.message} -- 133
		end -- 133
		packages[platform] = packageResult.item -- 134
	end -- 134
	return {manifest = { -- 136
		schemaVersion = 1, -- 138
		channel = "stable", -- 139
		version = value.version, -- 140
		revision = value.revision, -- 141
		publishedAt = value.publishedAt, -- 142
		packages = packages -- 143
	}} -- 143
end -- 93
____exports.loadUpdateManifest = function(repoPath) -- 148
	local file = Path(repoPath, "stable.json") -- 149
	if not Content:exist(file) then -- 149
		return {message = "stable.json is missing"} -- 150
	end -- 150
	return ____exports.parseUpdateManifest(Content:load(file)) -- 151
end -- 148
local installedPlatformChecked = false -- 154
local installedPlatform -- 155
____exports.updatePlatformForApp = function() -- 156
	if installedPlatformChecked then -- 156
		return installedPlatform -- 157
	end -- 157
	installedPlatformChecked = true -- 158
	repeat -- 158
		local ____switch39 = App.platform -- 158
		local ____cond39 = ____switch39 == "Android" -- 158
		if ____cond39 then -- 158
			installedPlatform = "android" -- 161
			return installedPlatform -- 162
		end -- 162
		____cond39 = ____cond39 or (____switch39 == "Windows" or ____switch39 == "macOS") -- 162
		if ____cond39 then -- 162
			break -- 165
		end -- 165
		do -- 165
			return nil -- 167
		end -- 167
	until true -- 167
	local file = "GodotRuntimeNotices/manifest.json" -- 171
	if not Content:exist(file) then -- 171
		return nil -- 172
	end -- 172
	local metadata, ____error = json.decode(Content:load(file)) -- 173
	if ____error ~= nil or type(metadata) ~= "table" or metadata == nil then -- 173
		return nil -- 174
	end -- 174
	local architectures = metadata.architectures -- 175
	if not __TS__ArrayIsArray(architectures) then -- 175
		return nil -- 176
	end -- 176
	if App.platform == "Windows" and (__TS__ArrayIncludes(architectures, "x86_64") or __TS__ArrayIncludes(architectures, "x64")) then -- 176
		installedPlatform = "windows-x64" -- 177
	end -- 177
	if App.platform == "macOS" and __TS__ArrayIncludes(architectures, "arm64") then -- 177
		installedPlatform = "macos-arm64" -- 178
	end -- 178
	return installedPlatform -- 179
end -- 156
____exports.compareVersions = function(left, right) -- 182
	local function parse(value) -- 183
		local major, minor, patch = string.match(value, "^v(%d+)%.(%d+)%.(%d+)$") -- 184
		return { -- 185
			tonumber(major) or 0, -- 185
			tonumber(minor) or 0, -- 185
			tonumber(patch) or 0 -- 185
		} -- 185
	end -- 183
	local leftParts = parse(left) -- 187
	local rightParts = parse(right) -- 188
	do -- 188
		local i = 0 -- 189
		while i < 3 do -- 189
			if leftParts[i + 1] ~= rightParts[i + 1] then -- 189
				return leftParts[i + 1] < rightParts[i + 1] and -1 or 1 -- 190
			end -- 190
			i = i + 1 -- 189
		end -- 189
	end -- 189
	return 0 -- 192
end -- 182
return ____exports -- 182