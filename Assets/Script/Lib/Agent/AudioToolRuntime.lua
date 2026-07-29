-- [ts]: AudioToolRuntime.ts
local ____lualib = require("lualib_bundle") -- 1
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
local function optionalBooleanParam(params, name) -- 48
	local ____temp_0 -- 49
	if type(params[name]) == "boolean" then -- 49
		____temp_0 = params[name] -- 49
	else -- 49
		____temp_0 = nil -- 49
	end -- 49
	return ____temp_0 -- 49
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
					style = optionalStringParam(params, "style"), -- 71
					intensity = optionalNumberParam(params, "intensity"), -- 72
					variation = optionalNumberParam(params, "variation"), -- 73
					isCancelled = req.isCancelled, -- 74
					onProgress = req.onProgress -- 75
				}) -- 75
			) -- 75
		end -- 75
		return ____awaiter_resolve( -- 75
			nil, -- 75
			AudioGenerator.generateMusic({ -- 78
				workDir = req.workDir, -- 79
				path = stringParam(params, "path"), -- 80
				style = stringParam(params, "style"), -- 81
				seed = optionalNumberParam(params, "seed"), -- 82
				duration = optionalNumberParam(params, "duration"), -- 83
				bpm = optionalNumberParam(params, "bpm"), -- 84
				volume = optionalNumberParam(params, "volume"), -- 85
				intensity = optionalNumberParam(params, "intensity"), -- 86
				key = optionalStringParam(params, "key"), -- 87
				mode = optionalStringParam(params, "mode"), -- 88
				progression = optionalStringParam(params, "progression"), -- 89
				structure = optionalStringParam(params, "structure"), -- 90
				barsPerSection = optionalNumberParam(params, "bars_per_section"), -- 91
				melodyComplexity = optionalNumberParam(params, "melody_complexity"), -- 92
				rhythmComplexity = optionalNumberParam(params, "rhythm_complexity"), -- 93
				variation = optionalNumberParam(params, "variation"), -- 94
				leadInstrument = optionalStringParam(params, "lead_instrument"), -- 95
				bassInstrument = optionalStringParam(params, "bass_instrument"), -- 96
				harmonyInstrument = optionalStringParam(params, "harmony_instrument"), -- 97
				stereo = optionalBooleanParam(params, "stereo"), -- 98
				reverb = optionalNumberParam(params, "reverb"), -- 99
				delay = optionalNumberParam(params, "delay"), -- 100
				chorus = optionalNumberParam(params, "chorus"), -- 101
				distortion = optionalNumberParam(params, "distortion"), -- 102
				bitCrush = optionalNumberParam(params, "bit_crush"), -- 103
				lowPass = optionalNumberParam(params, "low_pass"), -- 104
				stems = optionalBooleanParam(params, "stems"), -- 105
				introBars = optionalNumberParam(params, "intro_bars"), -- 106
				outroBars = optionalNumberParam(params, "outro_bars"), -- 107
				stinger = optionalStringParam(params, "stinger"), -- 108
				exportMidi = optionalBooleanParam(params, "export_midi"), -- 109
				isCancelled = req.isCancelled, -- 110
				onProgress = req.onProgress -- 111
			}) -- 111
		) -- 111
	end) -- 111
end -- 52
return ____exports -- 52