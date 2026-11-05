-- [ts]: Manifest.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local json = ____Dora.json -- 2
local Path = ____Dora.Path -- 2
____exports.updatePlatformsForVersion = function(version) return ____exports.compareVersions(version, "v1.10.0") >= 0 and ({ -- 6
	"android", -- 7
	"windows-x64", -- 7
	"windows-x64-opengl", -- 7
	"windows-x64-msi", -- 7
	"windows-x64-opengl-msi", -- 7
	"macos-arm64" -- 7
}) or ({"android", "windows-x86", "macos-universal"}) end -- 7
____exports.updatePackageFilename = function(version, platform) return __TS__StringEndsWith(platform, "-msi") and ((("dora-ssr-" .. version) .. "-") .. string.sub(platform, 1, -5)) .. ".msi" or ((("dora-ssr-" .. version) .. "-") .. platform) .. ".zip" end -- 10
____exports.windowsUpdatePlatform = function(backend, msi) return ("windows-x64" .. (backend == "wgl" and "-opengl" or "")) .. (msi and "-msi" or "") end -- 15
____exports.isWindowsUpdatePlatform = function(platform) return __TS__StringStartsWith(platform, "windows-x64") end -- 18
local versionPattern = "^v%d+%.%d+%.%d+$" -- 43
local function matches(value, pattern) -- 44
	return (string.match(value, pattern)) ~= nil -- 44
end -- 44
local function isLowerHex(value, length) -- 45
	return #value == length and matches(value, "^[0-9a-f]+$") -- 45
end -- 45
local function hasOnlyKeys(value, allowed) -- 46
	for key in pairs(value) do -- 47
		local found = false -- 48
		for ____, allowedKey in ipairs(allowed) do -- 49
			if key == allowedKey then -- 49
				found = true -- 51
				break -- 52
			end -- 52
		end -- 52
		if not found then -- 52
			return false -- 55
		end -- 55
	end -- 55
	return true -- 57
end -- 46
local function parsePackage(value, platform, version, revision) -- 65
	if type(value) ~= "table" or value == nil then -- 65
		return {message = platform .. " package is missing"} -- 72
	end -- 72
	if not hasOnlyKeys(value, { -- 72
		"ref", -- 74
		"commit", -- 74
		"file", -- 74
		"size", -- 74
		"sha256", -- 74
		"github" -- 74
	}) then -- 74
		return {message = platform .. " package contains unsupported fields"} -- 75
	end -- 75
	local item = value -- 77
	if type(item.ref) ~= "string" or item.ref ~= (((("refs/tags/" .. version) .. "-") .. tostring(revision)) .. "-") .. platform then -- 77
		return {message = platform .. " package ref is invalid"} -- 80
	end -- 80
	if type(item.commit) ~= "string" or not isLowerHex(item.commit, 40) then -- 80
		return {message = platform .. " package commit is invalid"} -- 83
	end -- 83
	if type(item.file) ~= "string" or item.file ~= ____exports.updatePackageFilename(version, platform) or Path:getFilename(item.file) ~= item.file then -- 83
		return {message = platform .. " package file is invalid"} -- 88
	end -- 88
	if type(item.size) ~= "number" or item.size < 1 or item.size > 2 * 1024 * 1024 * 1024 then -- 88
		return {message = platform .. " package size is invalid"} -- 91
	end -- 91
	if type(item.sha256) ~= "string" or not isLowerHex(item.sha256, 64) then -- 91
		return {message = platform .. " package SHA-256 is invalid"} -- 94
	end -- 94
	local github = (("https://github.com/IppClub/Dora-SSR/releases/download/" .. version) .. "/") .. item.file -- 96
	if type(item.github) ~= "string" or item.github ~= github then -- 96
		return {message = platform .. " GitHub URL is invalid"} -- 98
	end -- 98
	return {item = item} -- 100
end -- 65
____exports.parseUpdateManifest = function(text) -- 103
	if #text > 128 * 1024 then -- 103
		return {message = "update manifest is too large"} -- 104
	end -- 104
	local decoded, err = json.decode(text) -- 105
	if err ~= nil or type(decoded) ~= "table" or decoded == nil then -- 105
		return {message = "update manifest is not valid JSON"} -- 107
	end -- 107
	if not hasOnlyKeys(decoded, { -- 107
		"$schema", -- 109
		"schemaVersion", -- 109
		"channel", -- 109
		"version", -- 109
		"revision", -- 109
		"publishedAt", -- 109
		"packages" -- 109
	}) then -- 109
		return {message = "update manifest contains unsupported fields"} -- 110
	end -- 110
	if decoded["$schema"] ~= "./schema/stable-v1.schema.json" then -- 110
		return {message = "update manifest schema reference is invalid"} -- 113
	end -- 113
	local value = decoded -- 115
	if value.schemaVersion ~= 1 or value.channel ~= "stable" then -- 115
		return {message = "unsupported update manifest schema"} -- 117
	end -- 117
	if type(value.version) ~= "string" or not matches(value.version, versionPattern) then -- 117
		return {message = "update manifest version is invalid"} -- 120
	end -- 120
	if type(value.revision) ~= "number" or value.revision < 0 or math.floor(value.revision) ~= value.revision then -- 120
		return {message = "update manifest revision is invalid"} -- 123
	end -- 123
	if type(value.publishedAt) ~= "string" or #value.publishedAt > 64 then -- 123
		return {message = "update manifest publication time is invalid"} -- 126
	end -- 126
	if type(value.packages) ~= "table" or value.packages == nil then -- 126
		return {message = "update manifest packages are missing"} -- 129
	end -- 129
	local platforms = ____exports.updatePlatformsForVersion(value.version) -- 131
	if not hasOnlyKeys(value.packages, platforms) then -- 131
		return {message = "update manifest contains unsupported platforms"} -- 133
	end -- 133
	local packages = {} -- 135
	for ____, platform in ipairs(platforms) do -- 136
		local packageResult = parsePackage(value.packages[platform], platform, value.version, value.revision) -- 137
		if not packageResult.item then -- 137
			return {message = packageResult.message} -- 143
		end -- 143
		packages[platform] = packageResult.item -- 144
	end -- 144
	return {manifest = { -- 146
		schemaVersion = 1, -- 148
		channel = "stable", -- 149
		version = value.version, -- 150
		revision = value.revision, -- 151
		publishedAt = value.publishedAt, -- 152
		packages = packages -- 153
	}} -- 153
end -- 103
____exports.loadUpdateManifest = function(repoPath) -- 158
	local file = Path(repoPath, "stable.json") -- 159
	if not Content:exist(file) then -- 159
		return {message = "stable.json is missing"} -- 160
	end -- 160
	return ____exports.parseUpdateManifest(Content:load(file)) -- 161
end -- 158
local installedPlatformChecked = false -- 164
local installedPlatform -- 165
____exports.updatePlatformForApp = function() -- 166
	if installedPlatformChecked then -- 166
		return installedPlatform -- 167
	end -- 167
	installedPlatformChecked = true -- 168
	repeat -- 168
		local ____switch42 = App.platform -- 168
		local ____cond42 = ____switch42 == "Android" -- 168
		if ____cond42 then -- 168
			installedPlatform = "android" -- 171
			return installedPlatform -- 172
		end -- 172
		____cond42 = ____cond42 or (____switch42 == "Windows" or ____switch42 == "macOS") -- 172
		if ____cond42 then -- 172
			break -- 175
		end -- 175
		do -- 175
			return nil -- 177
		end -- 177
	until true -- 177
	local file = "GodotRuntimeNotices/manifest.json" -- 181
	if not Content:exist(file) then -- 181
		return nil -- 182
	end -- 182
	local metadata, ____error = json.decode(Content:load(file)) -- 183
	if ____error ~= nil or type(metadata) ~= "table" or metadata == nil then -- 183
		return nil -- 184
	end -- 184
	local architectures = metadata.architectures -- 185
	local backend = metadata.graphics_backend -- 186
	if not __TS__ArrayIsArray(architectures) then -- 186
		return nil -- 187
	end -- 187
	if App.platform == "Windows" and (__TS__ArrayIncludes(architectures, "x86_64") or __TS__ArrayIncludes(architectures, "x64")) then -- 187
		if backend ~= "d3d12" and backend ~= "wgl" then -- 187
			return nil -- 189
		end -- 189
		local msi = false -- 190
		if Content:exist("DoraInstallation.json") then -- 190
			local installation, err = json.decode(Content:load("DoraInstallation.json")) -- 192
			if err ~= nil or type(installation) ~= "table" or installation == nil or installation.format ~= "msi" then -- 192
				return nil -- 194
			end -- 194
			msi = true -- 195
		end -- 195
		installedPlatform = ____exports.windowsUpdatePlatform(backend, msi) -- 197
	end -- 197
	if App.platform == "macOS" and __TS__ArrayIncludes(architectures, "arm64") then -- 197
		installedPlatform = "macos-arm64" -- 199
	end -- 199
	return installedPlatform -- 200
end -- 166
____exports.compareVersions = function(left, right) -- 203
	local function parse(value) -- 204
		local major, minor, patch = string.match(value, "^v(%d+)%.(%d+)%.(%d+)$") -- 205
		return { -- 206
			tonumber(major) or 0, -- 206
			tonumber(minor) or 0, -- 206
			tonumber(patch) or 0 -- 206
		} -- 206
	end -- 204
	local leftParts = parse(left) -- 208
	local rightParts = parse(right) -- 209
	do -- 209
		local i = 0 -- 210
		while i < 3 do -- 210
			if leftParts[i + 1] ~= rightParts[i + 1] then -- 210
				return leftParts[i + 1] < rightParts[i + 1] and -1 or 1 -- 211
			end -- 211
			i = i + 1 -- 210
		end -- 210
	end -- 210
	return 0 -- 213
end -- 203
return ____exports -- 203
