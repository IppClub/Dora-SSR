-- [ts]: RemixVoice.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local ____Utils = require("Agent.Utils") -- 2
local safeJsonDecode = ____Utils.safeJsonDecode -- 2
local sampleRate = 16000 -- 15
local frameSeconds = 0.02 -- 16
local frameSamples = sampleRate * frameSeconds -- 17
local frameBytes = frameSamples * 2 -- 18
local highPass = math.exp(-2 * math.pi * 85 / sampleRate) -- 19
local preRoll = 15 -- 20
local tail = 12 -- 21
local maxFrames = 60 / frameSeconds -- 22
local available, native = pcall(function() return require("dora.remix_voice") end) -- 23
local recorder = available and type(native.start) == "function" and native or nil -- 24
function ____exports.remixVoiceKey(config) -- 26
	if not recorder or config.studioGateway then -- 26
		return nil -- 27
	end -- 27
	local url = (string.gsub( -- 28
		__TS__StringTrim(config.url), -- 28
		"/+$", -- 28
		"" -- 28
	)) -- 28
	if url ~= "https://api.deepseek.com/chat/completions" and url ~= "https://api.deepseek.com/v1/chat/completions" then -- 28
		return nil -- 29
	end -- 29
	local key = __TS__StringTrim(config.apiKey) -- 30
	return key ~= "" and key or nil -- 31
end -- 26
function ____exports.createRemixVoice(onPhase, onText, onIssue) -- 34
	local phase = "idle" -- 39
	local level = 0 -- 40
	local session -- 41
	local function changePhase(next) -- 56
		if phase == next then -- 56
			return -- 57
		end -- 57
		phase = next -- 58
		if next == "idle" or next == "transcribing" then -- 58
			level = 0 -- 59
		end -- 59
		onPhase(next) -- 60
	end -- 56
	local function cancel() -- 62
		if session then -- 62
			if recorder ~= nil then -- 62
				recorder.cancel(session.handle) -- 63
			end -- 63
		end -- 63
		session = nil -- 64
		changePhase("idle") -- 65
	end -- 62
	local function fail(issue) -- 67
		cancel() -- 68
		onIssue(issue) -- 69
	end -- 67
	local function finish() -- 71
		local current = session -- 72
		if not current or not recorder or phase ~= "waiting" and phase ~= "recording" then -- 72
			return -- 73
		end -- 73
		if current.firstVoice < 0 then -- 73
			fail("silence") -- 74
			return -- 74
		end -- 74
		local pcm = table.concat( -- 75
			current.frames, -- 75
			"", -- 75
			current.firstVoice + 1, -- 75
			math.min(current.nextFrame, current.lastVoice + 1 + tail) -- 75
		) -- 75
		local header = string.pack( -- 76
			"<c4I4c8I4I2I2I4I4I2I2c4I4", -- 76
			"RIFF", -- 77
			36 + #pcm, -- 77
			"WAVEfmt ", -- 77
			16, -- 77
			1, -- 77
			1, -- 77
			sampleRate, -- 77
			sampleRate * 2, -- 77
			2, -- 77
			16, -- 77
			"data", -- 77
			#pcm -- 77
		) -- 77
		recorder.transcribe(current.handle, current.key, header .. pcm) -- 78
		changePhase("transcribing") -- 79
	end -- 71
	return { -- 81
		start = function(key) -- 82
			if not recorder or session then -- 82
				return -- 83
			end -- 83
			local now = App.runningTime -- 84
			session = { -- 85
				handle = recorder.start(), -- 85
				key = key, -- 85
				startedAt = now, -- 85
				lastAudioAt = now, -- 85
				carry = "", -- 85
				frames = {}, -- 85
				nextFrame = 0, -- 86
				firstVoice = -1, -- 86
				lastVoice = 0, -- 86
				voicedRun = 0, -- 86
				noise = 0.002, -- 86
				previousSample = 0, -- 86
				filteredSample = 0 -- 86
			} -- 86
			changePhase("opening") -- 87
		end, -- 82
		cancel = cancel, -- 89
		finish = finish, -- 90
		phase = function() return phase end, -- 91
		level = function() return level end, -- 92
		tick = function() -- 93
			local current = session -- 94
			if not current or not recorder then -- 94
				return -- 95
			end -- 95
			local state, data = recorder.poll(current.handle) -- 96
			if state == "error" then -- 96
				fail(phase == "transcribing" and "transcription" or "capture") -- 97
				return -- 97
			end -- 97
			if state == "complete" then -- 97
				local value = data and (safeJsonDecode(data)) -- 99
				if not value or type(value) ~= "table" or type(value.text) ~= "string" then -- 99
					fail("transcription") -- 100
					return -- 100
				end -- 100
				local text = __TS__StringTrim(value.text) -- 101
				if text == "" then -- 101
					fail("silence") -- 102
					return -- 102
				end -- 102
				cancel() -- 103
				onText(text) -- 104
				return -- 105
			end -- 105
			if state ~= "recording" then -- 105
				return -- 107
			end -- 107
			local now = App.runningTime -- 108
			if phase == "opening" then -- 108
				current.startedAt = now -- 110
				current.lastAudioAt = now -- 111
				changePhase("waiting") -- 112
			end -- 112
			if data then -- 112
				current.lastAudioAt = now -- 115
				local audio = current.carry .. data -- 116
				local peak = 0 -- 117
				local offset = 1 -- 118
				while offset + frameBytes - 1 <= #audio do -- 118
					local ____current_2, ____nextFrame_3 = current, "nextFrame" -- 118
					local ____current_nextFrame_4 = ____current_2[____nextFrame_3] -- 118
					____current_2[____nextFrame_3] = ____current_nextFrame_4 + 1 -- 120
					local index = ____current_nextFrame_4 -- 120
					local frame = string.sub(audio, offset, offset + frameBytes - 1) -- 121
					local ____current_frames_5 = current.frames -- 121
					____current_frames_5[#____current_frames_5 + 1] = frame -- 122
					local energy = 0 -- 123
					do -- 123
						local at = 1 -- 124
						while at <= frameBytes do -- 124
							local sample = (string.unpack("<i2", frame, at)) / 32768 -- 125
							current.filteredSample = highPass * (current.filteredSample + sample - current.previousSample) -- 126
							current.previousSample = sample -- 127
							energy = energy + current.filteredSample * current.filteredSample -- 128
							at = at + 2 -- 124
						end -- 124
					end -- 124
					local rms = math.sqrt(energy / frameSamples) -- 130
					peak = math.max(peak, rms) -- 131
					local waiting = current.firstVoice < 0 -- 132
					local voiced = rms > math.max(waiting and 0.008 or 0.005, current.noise * (waiting and 3 or 1.8)) -- 133
					if not voiced then -- 133
						current.noise = current.noise * 0.97 + rms * 0.03 -- 134
					end -- 134
					current.voicedRun = voiced and current.voicedRun + 1 or 0 -- 135
					if waiting and current.voicedRun >= 6 then -- 135
						current.firstVoice = math.max(0, index - current.voicedRun + 1 - preRoll) -- 137
						current.lastVoice = index -- 138
						changePhase("recording") -- 139
					end -- 139
					if current.firstVoice >= 0 and current.voicedRun >= 2 then -- 139
						current.lastVoice = index -- 141
					end -- 141
					if index + 1 >= maxFrames or current.firstVoice >= 0 and index - current.lastVoice >= 70 then -- 141
						finish() -- 142
						return -- 142
					end -- 142
					offset = offset + frameBytes -- 143
				end -- 143
				current.carry = string.sub(audio, offset) -- 145
				level = math.min(1, peak * 12) -- 146
			end -- 146
			if now - current.lastAudioAt >= 3 then -- 146
				fail("capture") -- 148
			elseif current.firstVoice < 0 and now - current.startedAt >= 10 then -- 148
				fail("silence") -- 149
			elseif now - current.startedAt >= 60 then -- 149
				finish() -- 150
			end -- 150
		end -- 93
	} -- 93
end -- 34
return ____exports -- 34