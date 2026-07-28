-- [ts]: Manifest.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local json = ____Dora.json -- 2
local Path = ____Dora.Path -- 2
local versionPattern = "^v%d+%.%d+%.%d+$" -- 29
local function matches(value, pattern) -- 30
	return (string.match(value, pattern)) ~= nil -- 30
end -- 30
local function isLowerHex(value, length) -- 31
	return #value == length and matches(value, "^[0-9a-f]+$") -- 31
end -- 31
local function hasOnlyKeys(value, allowed) -- 32
	for key in pairs(value) do -- 33
		local found = false -- 34
		for ____, allowedKey in ipairs(allowed) do -- 35
			if key == allowedKey then -- 35
				found = true -- 37
				break -- 38
			end -- 38
		end -- 38
		if not found then -- 38
			return false -- 41
		end -- 41
	end -- 41
	return true -- 43
end -- 32
local function parsePackage(value, platform, version, revision) -- 51
	if type(value) ~= "table" or value == nil then -- 51
		return {message = platform .. " package is missing"} -- 58
	end -- 58
	if not hasOnlyKeys(value, { -- 58
		"ref", -- 60
		"commit", -- 60
		"file", -- 60
		"size", -- 60
		"sha256", -- 60
		"github" -- 60
	}) then -- 60
		return {message = platform .. " package contains unsupported fields"} -- 61
	end -- 61
	local item = value -- 63
	if type(item.ref) ~= "string" or item.ref ~= (((("refs/tags/" .. version) .. "-") .. tostring(revision)) .. "-") .. platform then -- 63
		return {message = platform .. " package ref is invalid"} -- 66
	end -- 66
	if type(item.commit) ~= "string" or not isLowerHex(item.commit, 40) then -- 66
		return {message = platform .. " package commit is invalid"} -- 69
	end -- 69
	if type(item.file) ~= "string" or item.file ~= ((("dora-ssr-" .. version) .. "-") .. platform) .. ".zip" or Path:getFilename(item.file) ~= item.file then -- 69
		return {message = platform .. " package file is invalid"} -- 74
	end -- 74
	if type(item.size) ~= "number" or item.size < 1 or item.size > 2 * 1024 * 1024 * 1024 then -- 74
		return {message = platform .. " package size is invalid"} -- 77
	end -- 77
	if type(item.sha256) ~= "string" or not isLowerHex(item.sha256, 64) then -- 77
		return {message = platform .. " package SHA-256 is invalid"} -- 80
	end -- 80
	local github = (("https://github.com/IppClub/Dora-SSR/releases/download/" .. version) .. "/") .. item.file -- 82
	if type(item.github) ~= "string" or item.github ~= github then -- 82
		return {message = platform .. " GitHub URL is invalid"} -- 84
	end -- 84
	return {item = item} -- 86
end -- 51
____exports.parseUpdateManifest = function(text) -- 89
	if #text > 128 * 1024 then -- 89
		return {message = "update manifest is too large"} -- 90
	end -- 90
	local decoded, err = json.decode(text) -- 91
	if err ~= nil or type(decoded) ~= "table" or decoded == nil then -- 91
		return {message = "update manifest is not valid JSON"} -- 93
	end -- 93
	if not hasOnlyKeys(decoded, { -- 93
		"$schema", -- 95
		"schemaVersion", -- 95
		"channel", -- 95
		"version", -- 95
		"revision", -- 95
		"publishedAt", -- 95
		"packages" -- 95
	}) then -- 95
		return {message = "update manifest contains unsupported fields"} -- 96
	end -- 96
	if decoded["$schema"] ~= "./schema/stable-v1.schema.json" then -- 96
		return {message = "update manifest schema reference is invalid"} -- 99
	end -- 99
	local value = decoded -- 101
	if value.schemaVersion ~= 1 or value.channel ~= "stable" then -- 101
		return {message = "unsupported update manifest schema"} -- 103
	end -- 103
	if type(value.version) ~= "string" or not matches(value.version, versionPattern) then -- 103
		return {message = "update manifest version is invalid"} -- 106
	end -- 106
	if type(value.revision) ~= "number" or value.revision < 0 or math.floor(value.revision) ~= value.revision then -- 106
		return {message = "update manifest revision is invalid"} -- 109
	end -- 109
	if type(value.publishedAt) ~= "string" or #value.publishedAt > 64 then -- 109
		return {message = "update manifest publication time is invalid"} -- 112
	end -- 112
	if type(value.packages) ~= "table" or value.packages == nil then -- 112
		return {message = "update manifest packages are missing"} -- 115
	end -- 115
	if not hasOnlyKeys(value.packages, {"android", "windows-x86", "macos-universal"}) then -- 115
		return {message = "update manifest contains unsupported platforms"} -- 118
	end -- 118
	local packages = {} -- 120
	for ____, platform in ipairs({"android", "windows-x86", "macos-universal"}) do -- 121
		local packageResult = parsePackage(value.packages[platform], platform, value.version, value.revision) -- 122
		if not packageResult.item then -- 122
			return {message = packageResult.message} -- 128
		end -- 128
		packages[platform] = packageResult.item -- 129
	end -- 129
	return {manifest = { -- 131
		schemaVersion = 1, -- 133
		channel = "stable", -- 134
		version = value.version, -- 135
		revision = value.revision, -- 136
		publishedAt = value.publishedAt, -- 137
		packages = packages -- 138
	}} -- 138
end -- 89
____exports.loadUpdateManifest = function(repoPath) -- 143
	local file = Path(repoPath, "stable.json") -- 144
	if not Content:exist(file) then -- 144
		return {message = "stable.json is missing"} -- 145
	end -- 145
	return ____exports.parseUpdateManifest(Content:load(file)) -- 146
end -- 143
____exports.updatePlatformForApp = function() -- 149
	repeat -- 149
		local ____switch37 = App.platform -- 149
		local ____cond37 = ____switch37 == "Android" -- 149
		if ____cond37 then -- 149
			return "android" -- 152
		end -- 152
		____cond37 = ____cond37 or ____switch37 == "Windows" -- 152
		if ____cond37 then -- 152
			return "windows-x86" -- 154
		end -- 154
		____cond37 = ____cond37 or ____switch37 == "macOS" -- 154
		if ____cond37 then -- 154
			return "macos-universal" -- 156
		end -- 156
		do -- 156
			return nil -- 158
		end -- 158
	until true -- 158
end -- 149
____exports.compareVersions = function(left, right) -- 162
	local function parse(value) -- 163
		local major, minor, patch = string.match(value, "^v(%d+)%.(%d+)%.(%d+)$") -- 164
		return { -- 165
			tonumber(major) or 0, -- 165
			tonumber(minor) or 0, -- 165
			tonumber(patch) or 0 -- 165
		} -- 165
	end -- 163
	local leftParts = parse(left) -- 167
	local rightParts = parse(right) -- 168
	do -- 168
		local i = 0 -- 169
		while i < 3 do -- 169
			if leftParts[i + 1] ~= rightParts[i + 1] then -- 169
				return leftParts[i + 1] < rightParts[i + 1] and -1 or 1 -- 170
			end -- 170
			i = i + 1 -- 169
		end -- 169
	end -- 169
	return 0 -- 172
end -- 162
return ____exports -- 162