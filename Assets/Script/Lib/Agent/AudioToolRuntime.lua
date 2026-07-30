-- [ts]: AudioToolRuntime.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local AudioGenerator = require("Agent.AudioGenerator") -- 2
function ____exports.isAudioAgentToolName(tool) -- 19
	return tool == "generate_sfx" or tool == "generate_music" or tool == "generate_music_variation" -- 20
end -- 19
local function hasParam(params, name) -- 25
	return params[name] ~= nil -- 26
end -- 25
function ____exports.inferAudioToolNameFromParams(params) -- 29
	if hasParam(params, "project") and hasParam(params, "path") then -- 29
		return "generate_music_variation" -- 30
	end -- 30
	if hasParam(params, "style") and hasParam(params, "path") then -- 30
		return "generate_music" -- 31
	end -- 31
	if hasParam(params, "type") and hasParam(params, "path") then -- 31
		return "generate_sfx" -- 32
	end -- 32
	return nil -- 33
end -- 29
local function stringParam(params, name) -- 36
	return type(params[name]) == "string" and params[name] or "" -- 37
end -- 36
local function optionalStringParam(params, name) -- 40
	return type(params[name]) == "string" and params[name] or nil -- 41
end -- 40
local function optionalNumberParam(params, name) -- 44
	return type(params[name]) == "number" and params[name] or nil -- 45
end -- 44
local function parseTonality(value) -- 48
	local text = __TS__StringTrim(value or "auto") -- 49
	if text == "" or string.lower(text) == "auto" then -- 49
		return {} -- 50
	end -- 49
	local parts = __TS__ArrayFilter( -- 51
		__TS__StringSplit(text, " "), -- 51
		function(____, part) return part ~= "" end -- 51
	) -- 51
	local ____opt_0 = parts[1] -- 51
	local key = ____opt_0 and string.upper(parts[1]) -- 52
	local mode = #parts > 1 and string.lower(table.concat( -- 53
		__TS__ArraySlice(parts, 1), -- 53
		"_" -- 53
	)) or nil -- 53
	local validKeys = { -- 54
		"C", -- 54
		"C#", -- 54
		"D", -- 54
		"D#", -- 54
		"E", -- 54
		"F", -- 54
		"F#", -- 54
		"G", -- 54
		"G#", -- 54
		"A", -- 54
		"A#", -- 54
		"B" -- 54
	} -- 54
	local validModes = { -- 55
		"major", -- 55
		"minor", -- 55
		"pentatonic", -- 55
		"harmonic_minor", -- 55
		"dorian", -- 55
		"phrygian", -- 55
		"chromatic" -- 55
	} -- 55
	if not key or __TS__ArrayIndexOf(validKeys, key) < 0 then -- 55
		return {error = ("invalid tonality '" .. text) .. "': expected a key such as D or F# dorian"} -- 56
	end -- 56
	if mode ~= nil and __TS__ArrayIndexOf(validModes, mode) < 0 then -- 56
		return {error = ((("invalid tonality '" .. text) .. "': unknown mode '") .. mode) .. "'"} -- 57
	end -- 57
	return {key = key, mode = mode} -- 58
end -- 48
function ____exports.executeAudioTool(req) -- 52
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 52
		local params = req.params -- 53
		if req.tool == "generate_sfx" then -- 53
			return ____awaiter_resolve( -- 53
				nil, -- 53
				AudioGenerator.generateSfx({ -- 55
					workDir = req.workDir, -- 56
					path = stringParam(params, "path"), -- 57
					type = stringParam(params, "type"), -- 58
					seed = optionalNumberParam(params, "seed"), -- 59
					volume = optionalNumberParam(params, "volume"), -- 60
					isCancelled = req.isCancelled, -- 61
					onProgress = req.onProgress -- 62
				}) -- 62
			) -- 62
		end -- 62
		if req.tool == "generate_music_variation" then -- 62
			return ____awaiter_resolve( -- 62
				nil, -- 62
				AudioGenerator.generateMusicVariation({ -- 66
					workDir = req.workDir, -- 67
					project = stringParam(params, "project"), -- 68
					path = stringParam(params, "path"), -- 69
					seed = optionalNumberParam(params, "seed"), -- 70
					intensity = optionalNumberParam(params, "intensity"), -- 72
					variation = optionalNumberParam(params, "variation"), -- 73
					isCancelled = req.isCancelled, -- 74
					onProgress = req.onProgress -- 75
				}) -- 75
			) -- 75
		end -- 75
		local tonality = parseTonality(optionalStringParam(params, "tonality")) -- 86
		local assetPack = optionalStringParam(params, "asset_pack") or "loop" -- 87
		if tonality.error then -- 87
			return ____awaiter_resolve( -- 87
				nil, -- 87
				{ -- 88
					success = false, -- 88
					path = stringParam(params, "path"), -- 88
					message = tonality.error -- 88
				} -- 88
			) -- 88
		end -- 88
		if __TS__ArrayIndexOf({"loop", "adaptive", "cinematic", "full"}, assetPack) < 0 then -- 88
			return ____awaiter_resolve( -- 88
				nil, -- 88
				{ -- 90
					success = false, -- 90
					path = stringParam(params, "path"), -- 90
					message = ("invalid asset_pack '" .. assetPack) .. "'" -- 90
				} -- 90
			) -- 90
		end -- 90
		local cinematic = assetPack == "cinematic" or assetPack == "full" -- 92
		local adaptive = assetPack == "adaptive" or assetPack == "full" -- 93
		return ____awaiter_resolve( -- 75
			nil, -- 75
			AudioGenerator.generateMusic({ -- 78
				workDir = req.workDir, -- 79
				path = stringParam(params, "path"), -- 80
				style = stringParam(params, "style"), -- 81
				seed = optionalNumberParam(params, "seed"), -- 82
				duration = optionalNumberParam(params, "duration"), -- 83
				bpm = optionalNumberParam(params, "bpm"), -- 84
				intensity = optionalNumberParam(params, "intensity"), -- 86
				key = tonality.key, -- 102
				mode = tonality.mode, -- 103
				stems = adaptive, -- 104
				introBars = cinematic and 1 or 0, -- 105
				outroBars = cinematic and 1 or 0, -- 106
				stinger = cinematic and "both" or "none", -- 107
				exportMidi = assetPack == "full", -- 108
				isCancelled = req.isCancelled, -- 110
				onProgress = req.onProgress -- 111
			}) -- 111
		) -- 111
	end) -- 111
end -- 52
return ____exports -- 52
