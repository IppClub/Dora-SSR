-- [ts]: AudioDSL.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__ArrayJoin = ____lualib.__TS__ArrayJoin -- 1
local ____exports = {} -- 1
local AudioGenerator = require("Agent.AudioGenerator") -- 2
local VALID_STYLES = { -- 56
	"chiptune", -- 56
	"adventure", -- 56
	"calm", -- 56
	"tense", -- 56
	"victory", -- 56
	"random" -- 56
} -- 56
local VALID_MODES = { -- 57
	"auto", -- 57
	"major", -- 57
	"minor", -- 57
	"pentatonic", -- 57
	"harmonic_minor", -- 57
	"dorian", -- 57
	"phrygian", -- 57
	"chromatic" -- 57
} -- 57
local VALID_INSTRUMENTS = { -- 58
	"auto", -- 58
	"square", -- 58
	"pulse", -- 58
	"saw", -- 58
	"triangle", -- 58
	"sine", -- 58
	"organ", -- 58
	"bell", -- 58
	"pluck", -- 58
	"fm", -- 58
	"pad", -- 58
	"sub", -- 58
	"guitar", -- 58
	"strings" -- 58
} -- 58
local VALID_STINGERS = {"none", "victory", "failure", "both"} -- 59
local VALID_KEYS = { -- 60
	"random", -- 60
	"C", -- 60
	"C#", -- 60
	"D", -- 60
	"D#", -- 60
	"E", -- 60
	"F", -- 60
	"F#", -- 60
	"G", -- 60
	"G#", -- 60
	"A", -- 60
	"A#", -- 60
	"B" -- 60
} -- 60
function ____exports.defineMusic(job) -- 62
	return job -- 63
end -- 62
local function invalid(job, message) -- 66
	return {success = false, path = job.output, message = "invalid audio job: " .. message} -- 67
end -- 66
local function validateRange(value, name, min, max) -- 70
	if value == nil then -- 70
		return nil -- 71
	end -- 71
	if value ~= value or value < min or value > max then -- 71
		return (((name .. " must be between ") .. tostring(min)) .. " and ") .. tostring(max) -- 72
	end -- 72
	return nil -- 73
end -- 70
local function validateStringList(values, name) -- 76
	if values == nil then -- 76
		return nil -- 77
	end -- 77
	if #values == 0 then -- 77
		return name .. " must not be empty" -- 78
	end -- 78
	do -- 78
		local i = 0 -- 79
		while i < #values do -- 79
			if type(values[i + 1]) ~= "string" or __TS__StringTrim(values[i + 1]) == "" then -- 79
				return ((name .. "[") .. tostring(i)) .. "] must be a non-empty string" -- 80
			end -- 80
			i = i + 1 -- 79
		end -- 79
	end -- 79
	return nil -- 82
end -- 76
local function validateJob(job) -- 85
	local output = __TS__StringTrim(job.output or "") -- 86
	if output == "" or not __TS__StringEndsWith( -- 86
		string.lower(output), -- 87
		".wav" -- 87
	) then -- 87
		return "output must be a workspace-relative .wav path" -- 87
	end -- 87
	if (string.find(output, "..", nil, true) or 0) - 1 >= 0 or (string.find(output, "/", nil, true) or 0) - 1 == 0 or (string.find(output, "\\", nil, true) or 0) - 1 == 0 then -- 87
		return "output must stay inside the project" -- 88
	end -- 88
	if not job.composition then -- 88
		return "composition is required" -- 89
	end -- 89
	if __TS__ArrayIndexOf(VALID_STYLES, job.composition.style) < 0 then -- 89
		return ("unknown style '" .. tostring(job.composition.style)) .. "'" -- 90
	end -- 90
	local durationError = validateRange(job.composition.duration, "composition.duration", 4, 32) -- 91
	if durationError then -- 91
		return durationError -- 92
	end -- 92
	local tempoError = validateRange(job.composition.tempo, "composition.tempo", 60, 200) -- 93
	if tempoError then -- 93
		return tempoError -- 94
	end -- 94
	if job.composition.key ~= nil and __TS__ArrayIndexOf(VALID_KEYS, job.composition.key) < 0 then -- 94
		return ("unknown key '" .. job.composition.key) .. "'" -- 95
	end -- 95
	if job.composition.mode ~= nil and __TS__ArrayIndexOf(VALID_MODES, job.composition.mode) < 0 then -- 95
		return ("unknown mode '" .. job.composition.mode) .. "'" -- 96
	end -- 96
	local progressionError = validateStringList(job.composition.progression, "composition.progression") -- 97
	if progressionError then -- 97
		return progressionError -- 98
	end -- 98
	local structureError = validateStringList(job.composition.structure, "composition.structure") -- 99
	if structureError then -- 99
		return structureError -- 100
	end -- 100
	local arrangement = job.arrangement -- 101
	if arrangement then -- 101
		local intensityError = validateRange(arrangement.intensity, "arrangement.intensity", 0, 1) -- 103
		if intensityError then -- 103
			return intensityError -- 104
		end -- 104
		local barsError = validateRange(arrangement.barsPerSection, "arrangement.barsPerSection", 1, 8) -- 105
		if barsError then -- 105
			return barsError -- 106
		end -- 106
		local melodyError = validateRange(arrangement.melodyComplexity, "arrangement.melodyComplexity", 0, 1) -- 107
		if melodyError then -- 107
			return melodyError -- 108
		end -- 108
		local rhythmError = validateRange(arrangement.rhythmComplexity, "arrangement.rhythmComplexity", 0, 1) -- 109
		if rhythmError then -- 109
			return rhythmError -- 110
		end -- 110
		local variationError = validateRange(arrangement.variation, "arrangement.variation", 0, 1) -- 111
		if variationError then -- 111
			return variationError -- 112
		end -- 112
	end -- 112
	local instruments = job.instruments -- 114
	if instruments then -- 114
		if instruments.lead ~= nil and __TS__ArrayIndexOf(VALID_INSTRUMENTS, instruments.lead) < 0 then -- 114
			return ("unknown lead instrument '" .. instruments.lead) .. "'" -- 116
		end -- 116
		if instruments.bass ~= nil and __TS__ArrayIndexOf(VALID_INSTRUMENTS, instruments.bass) < 0 then -- 116
			return ("unknown bass instrument '" .. instruments.bass) .. "'" -- 117
		end -- 117
		if instruments.harmony ~= nil and __TS__ArrayIndexOf(VALID_INSTRUMENTS, instruments.harmony) < 0 then -- 117
			return ("unknown harmony instrument '" .. instruments.harmony) .. "'" -- 118
		end -- 118
	end -- 118
	local effects = job.effects -- 120
	if effects then -- 120
		local volumeError = validateRange(effects.volume, "effects.volume", 0, 1) -- 122
		if volumeError then -- 122
			return volumeError -- 123
		end -- 123
		local reverbError = validateRange(effects.reverb, "effects.reverb", 0, 1) -- 124
		if reverbError then -- 124
			return reverbError -- 125
		end -- 125
		local delayError = validateRange(effects.delay, "effects.delay", 0, 1) -- 126
		if delayError then -- 126
			return delayError -- 127
		end -- 127
		local chorusError = validateRange(effects.chorus, "effects.chorus", 0, 1) -- 128
		if chorusError then -- 128
			return chorusError -- 129
		end -- 129
		local distortionError = validateRange(effects.distortion, "effects.distortion", 0, 1) -- 130
		if distortionError then -- 130
			return distortionError -- 131
		end -- 131
		local bitCrushError = validateRange(effects.bitCrush, "effects.bitCrush", 0, 1) -- 132
		if bitCrushError then -- 132
			return bitCrushError -- 133
		end -- 133
		local lowPassError = validateRange(effects.lowPass, "effects.lowPass", 0, 1) -- 134
		if lowPassError then -- 134
			return lowPassError -- 135
		end -- 135
	end -- 135
	local exports = job.exports -- 137
	if exports then -- 137
		local introError = validateRange(exports.introBars, "exports.introBars", 0, 8) -- 139
		if introError then -- 139
			return introError -- 140
		end -- 140
		local outroError = validateRange(exports.outroBars, "exports.outroBars", 0, 8) -- 141
		if outroError then -- 141
			return outroError -- 142
		end -- 142
		if exports.stinger ~= nil and __TS__ArrayIndexOf(VALID_STINGERS, exports.stinger) < 0 then -- 142
			return ("unknown stinger '" .. exports.stinger) .. "'" -- 143
		end -- 143
	end -- 143
	return nil -- 145
end -- 85
function ____exports.renderMusic(workDir, job, hooks) -- 148
	local validationError = validateJob(job) -- 149
	if validationError then -- 149
		return __TS__Promise.resolve(invalid(job, validationError)) -- 150
	end -- 150
	local ____AudioGenerator_generateMusic_80 = AudioGenerator.generateMusic -- 151
	local ____workDir_50 = workDir -- 152
	local ____job_output_51 = job.output -- 153
	local ____job_composition_style_52 = job.composition.style -- 154
	local ____job_composition_seed_53 = job.composition.seed -- 155
	local ____job_composition_duration_54 = job.composition.duration -- 156
	local ____job_composition_tempo_55 = job.composition.tempo -- 157
	local ____job_composition_key_56 = job.composition.key -- 158
	local ____job_composition_mode_57 = job.composition.mode -- 159
	local ____opt_0 = job.composition.progression -- 159
	local ____temp_58 = ____opt_0 and __TS__ArrayJoin(job.composition.progression, ",") -- 160
	local ____opt_2 = job.composition.structure -- 160
	local ____temp_59 = ____opt_2 and __TS__ArrayJoin(job.composition.structure, ",") -- 161
	local ____opt_4 = job.arrangement -- 161
	local ____temp_60 = ____opt_4 and ____opt_4.intensity -- 162
	local ____opt_6 = job.arrangement -- 162
	local ____temp_61 = ____opt_6 and ____opt_6.barsPerSection -- 163
	local ____opt_8 = job.arrangement -- 163
	local ____temp_62 = ____opt_8 and ____opt_8.melodyComplexity -- 164
	local ____opt_10 = job.arrangement -- 164
	local ____temp_63 = ____opt_10 and ____opt_10.rhythmComplexity -- 165
	local ____opt_12 = job.arrangement -- 165
	local ____temp_64 = ____opt_12 and ____opt_12.variation -- 166
	local ____opt_14 = job.instruments -- 166
	local ____temp_65 = ____opt_14 and ____opt_14.lead -- 167
	local ____opt_16 = job.instruments -- 167
	local ____temp_66 = ____opt_16 and ____opt_16.bass -- 168
	local ____opt_18 = job.instruments -- 168
	local ____temp_67 = ____opt_18 and ____opt_18.harmony -- 169
	local ____opt_20 = job.effects -- 169
	local ____temp_68 = ____opt_20 and ____opt_20.volume -- 170
	local ____opt_22 = job.effects -- 170
	local ____temp_69 = ____opt_22 and ____opt_22.stereo -- 171
	local ____opt_24 = job.effects -- 171
	local ____temp_70 = ____opt_24 and ____opt_24.reverb -- 172
	local ____opt_26 = job.effects -- 172
	local ____temp_71 = ____opt_26 and ____opt_26.delay -- 173
	local ____opt_28 = job.effects -- 173
	local ____temp_72 = ____opt_28 and ____opt_28.chorus -- 174
	local ____opt_30 = job.effects -- 174
	local ____temp_73 = ____opt_30 and ____opt_30.distortion -- 175
	local ____opt_32 = job.effects -- 175
	local ____temp_74 = ____opt_32 and ____opt_32.bitCrush -- 176
	local ____opt_34 = job.effects -- 176
	local ____temp_75 = ____opt_34 and ____opt_34.lowPass -- 177
	local ____opt_36 = job.exports -- 177
	local ____temp_76 = ____opt_36 and ____opt_36.stems -- 178
	local ____opt_38 = job.exports -- 178
	local ____temp_77 = ____opt_38 and ____opt_38.introBars -- 179
	local ____opt_40 = job.exports -- 179
	local ____temp_78 = ____opt_40 and ____opt_40.outroBars -- 180
	local ____opt_42 = job.exports -- 180
	local ____temp_79 = ____opt_42 and ____opt_42.stinger -- 181
	local ____opt_44 = job.exports -- 181
	return ____AudioGenerator_generateMusic_80({ -- 151
		workDir = ____workDir_50, -- 152
		path = ____job_output_51, -- 153
		style = ____job_composition_style_52, -- 154
		seed = ____job_composition_seed_53, -- 155
		duration = ____job_composition_duration_54, -- 156
		bpm = ____job_composition_tempo_55, -- 157
		key = ____job_composition_key_56, -- 158
		mode = ____job_composition_mode_57, -- 159
		progression = ____temp_58, -- 160
		structure = ____temp_59, -- 161
		intensity = ____temp_60, -- 162
		barsPerSection = ____temp_61, -- 163
		melodyComplexity = ____temp_62, -- 164
		rhythmComplexity = ____temp_63, -- 165
		variation = ____temp_64, -- 166
		leadInstrument = ____temp_65, -- 167
		bassInstrument = ____temp_66, -- 168
		harmonyInstrument = ____temp_67, -- 169
		volume = ____temp_68, -- 170
		stereo = ____temp_69, -- 171
		reverb = ____temp_70, -- 172
		delay = ____temp_71, -- 173
		chorus = ____temp_72, -- 174
		distortion = ____temp_73, -- 175
		bitCrush = ____temp_74, -- 176
		lowPass = ____temp_75, -- 177
		stems = ____temp_76, -- 178
		introBars = ____temp_77, -- 179
		outroBars = ____temp_78, -- 180
		stinger = ____temp_79, -- 181
		exportMidi = ____opt_44 and ____opt_44.midi, -- 182
		isCancelled = hooks and hooks.isCancelled, -- 183
		onProgress = hooks and hooks.onProgress -- 184
	}) -- 184
end -- 148
return ____exports -- 148