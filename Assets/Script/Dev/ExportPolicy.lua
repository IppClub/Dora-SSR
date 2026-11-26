-- [ts]: ExportPolicy.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local json = ____Dora.json -- 2
local decoded = json.decode(Content:load(Path(Content.assetPath, "Script", "Dev", "ExportPolicy.json"))) -- 4
local policy = decoded.projectFiles -- 5
function ____exports.projectFileAllowed(file, includeRemix) -- 9
	if includeRemix == nil then -- 9
		includeRemix = false -- 9
	end -- 9
	local name = string.gsub(file, "\\", "/") -- 10
	if (string.find(name, ":", nil, true) or 0) - 1 >= 0 or (string.find(name, "%c")) ~= nil then -- 10
		return false -- 11
	end -- 11
	local parts = __TS__StringSplit(name, "/") -- 12
	if __TS__ArraySome( -- 12
		parts, -- 13
		function(____, part) return part == "" or part == "." or part == ".." end -- 13
	) then -- 13
		return false -- 13
	end -- 13
	if includeRemix and __TS__ArrayIncludes(policy.remixFiles, name) then -- 13
		return true -- 14
	end -- 14
	local lower = string.lower(name) -- 15
	return not __TS__ArraySome( -- 16
		parts, -- 16
		function(____, part) return __TS__StringStartsWith(part, ".") or __TS__ArrayIncludes( -- 16
			policy.excludedNames, -- 16
			string.lower(part) -- 16
		) end -- 16
	) and not __TS__ArraySome( -- 16
		policy.excludedSuffixes, -- 17
		function(____, suffix) return __TS__StringEndsWith(lower, suffix) end -- 17
	) -- 17
end -- 9
return ____exports -- 9