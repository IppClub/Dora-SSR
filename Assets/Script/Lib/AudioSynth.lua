-- AudioSynth: procedural sound effect synthesis primitives.
-- Pure Lua, no engine dependency except Content for save().
-- A "sound" is a plain array of samples in [-1, 1], mono, at AudioSynth.rate Hz.
-- Compose effects by chaining: tone -> env/lowpass -> mix/echo -> save.

local Content = require("Dora").Content

local AudioSynth = {}
AudioSynth.rate = 44100

local function packU16(n)
	return string.char(n % 256, math.floor(n / 256) % 256)
end

local function packU32(n)
	return string.char(
		n % 256,
		math.floor(n / 256) % 256,
		math.floor(n / 65536) % 256,
		math.floor(n / 16777216) % 256
	)
end

local function clamp(v)
	if v > 1 then return 1 end
	if v < -1 then return -1 end
	return v
end

local TAU = math.pi * 2

-- Seed the RNG for reproducible noise-based sounds.
function AudioSynth.seed(n)
	math.randomseed(n)
end

-- Generators ------------------------------------------------------------
-- Waveform oscillator with optional pitch sweep from f0 to f1.
-- type: "sine" | "square" | "saw" | "tri" | "noise" | "pink"
-- opts: { duty = 0.5 (square), curve = "exp"|"lin" (default exp), gain = 1 }
function AudioSynth.tone(type, f0, f1, dur, opts)
	opts = opts or {}
	local rate = AudioSynth.rate
	local n = math.max(1, math.floor(dur * rate))
	local snd = {}
	local phase = 0
	local curve = opts.curve or "exp"
	local gain = opts.gain or 1
	-- pink noise state (Paul Kellet approximation)
	local b0, b1, b2, b3, b4, b5, b6 = 0, 0, 0, 0, 0, 0, 0
	for i = 1, n do
		local t = (i - 1) / (n - 1 + (n == 1 and 1 or 0))
		local f
		if f1 == nil or f1 == f0 then
			f = f0
		elseif curve == "lin" then
			f = f0 + (f1 - f0) * t
		else
			f = f0 * (f1 / f0) ^ t
		end
		phase = phase + f / rate
		local v
		if type == "sine" then
			v = math.sin(phase * TAU)
		elseif type == "square" then
			v = (phase % 1 < (opts.duty or 0.5)) and 1 or -1
		elseif type == "saw" then
			v = (phase % 1) * 2 - 1
		elseif type == "tri" then
			local p = phase % 1
			v = p < 0.5 and (p * 4 - 1) or (3 - p * 4)
		elseif type == "pink" then
			local w = math.random() * 2 - 1
			b0 = 0.99886 * b0 + w * 0.0555179
			b1 = 0.99332 * b1 + w * 0.0750759
			b2 = 0.96900 * b2 + w * 0.1538520
			b3 = 0.86650 * b3 + w * 0.3104856
			b4 = 0.55000 * b4 + w * 0.5329522
			b5 = -0.7616 * b5 - w * 0.0168980
			v = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + w * 0.5362) * 0.11
			b6 = w * 0.115926
		else -- "noise"
			v = math.random() * 2 - 1
		end
		snd[i] = v * gain
	end
	return snd
end

function AudioSynth.silence(dur)
	local n = math.max(0, math.floor(dur * AudioSynth.rate))
	local snd = {}
	for i = 1, n do
		snd[i] = 0
	end
	return snd
end

-- Shaping ---------------------------------------------------------------
-- ADSR envelope in seconds; level = sustain level 0..1.
function AudioSynth.env(snd, a, d, s, r, level)
	local rate = AudioSynth.rate
	local len = #snd
	local total = a + d + s + r
	if total <= 0 then
		return snd
	end
	local na = math.floor(a * rate)
	local nd = math.floor(d * rate)
	local ns = math.floor(s * rate)
	local nr = math.floor(r * rate)
	level = level == nil and 1 or level
	local peak = 1
	for i = 1, len do
		local e
		if i <= na then
			e = peak * i / math.max(1, na)
		elseif i <= na + nd then
			local p = (i - na) / math.max(1, nd)
			e = peak + (level - peak) * p
		elseif i <= na + nd + ns then
			e = level
		else
			local p = (i - na - nd - ns) / math.max(1, nr)
			e = level * (1 - p)
		end
		snd[i] = snd[i] * math.max(0, e)
	end
	return snd
end

-- Simple exponential decay: fastest at start (rate ~ 4 = very fast).
function AudioSynth.decay(snd, rate)
	local len = #snd
	for i = 1, len do
		snd[i] = snd[i] * math.exp(-(rate or 4) * (i - 1) / len)
	end
	return snd
end

function AudioSynth.fade(snd, inSec, outSec)
	local rate = AudioSynth.rate
	local len = #snd
	local ni = math.floor((inSec or 0) * rate)
	local no = math.floor((outSec or 0) * rate)
	for i = 1, len do
		local g = 1
		if i <= ni then
			g = i / math.max(1, ni)
		end
		local fromEnd = len - i + 1
		if fromEnd <= no then
			g = math.min(g, fromEnd / math.max(1, no))
		end
		snd[i] = snd[i] * g
	end
	return snd
end

function AudioSynth.gain(snd, g)
	for i = 1, #snd do
		snd[i] = snd[i] * g
	end
	return snd
end

-- Scale peak to 0.9.
function AudioSynth.normalize(snd)
	local peak = 0
	for i = 1, #snd do
		local a = math.abs(snd[i])
		if a > peak then
			peak = a
		end
	end
	if peak > 0 then
		local g = 0.9 / peak
		for i = 1, #snd do
			snd[i] = snd[i] * g
		end
	end
	return snd
end

-- Processing ------------------------------------------------------------
-- Sample-wise sum; result length = longest input.
function AudioSynth.mix(...)
	local args = { ... }
	local n = select("#", ...)
	local len = 0
	for i = 1, n do
		if #args[i] > len then
			len = #args[i]
		end
	end
	local out = {}
	for i = 1, len do
		local v = 0
		for j = 1, n do
			local s = args[j][i]
			if s ~= nil then
				v = v + s
			end
		end
		out[i] = v
	end
	return out
end

-- Sequential join.
function AudioSynth.concat(...)
	local args = { ... }
	local n = select("#", ...)
	local out = {}
	local idx = 1
	for i = 1, n do
		local snd = args[i]
		for j = 1, #snd do
			out[idx] = snd[j]
			idx = idx + 1
		end
	end
	return out
end

function AudioSynth.reverse(snd)
	local len = #snd
	local out = {}
	for i = 1, len do
		out[i] = snd[len - i + 1]
	end
	return out
end

-- Resample: factor > 1 = shorter & higher pitch, < 1 = longer & lower.
function AudioSynth.speed(snd, factor)
	assert(type(factor) == "number" and factor > 0 and factor < math.huge,
		"speed factor must be a finite positive number")
	local len = #snd
	local n = math.max(1, math.floor(len / factor))
	local out = {}
	for i = 1, n do
		local pos = (i - 1) * factor + 1
		local i0 = math.floor(pos)
		local i1 = math.min(len, i0 + 1)
		local frac = pos - i0
		local s0 = snd[i0] or 0
		local s1 = snd[i1] or s0
		out[i] = s0 + (s1 - s0) * frac
	end
	return out
end

-- One-pole lowpass filter, cutoff in Hz.
function AudioSynth.lowpass(snd, cutoff)
	local rate = AudioSynth.rate
	local alpha = 1 - math.exp(-TAU * cutoff / rate)
	local out = {}
	local y = 0
	for i = 1, #snd do
		y = y + alpha * (snd[i] - y)
		out[i] = y
	end
	return out
end

-- One-pole highpass filter, cutoff in Hz.
function AudioSynth.highpass(snd, cutoff)
	local lp = AudioSynth.lowpass(snd, cutoff)
	local out = {}
	for i = 1, #snd do
		out[i] = snd[i] - lp[i]
	end
	return out
end

-- Prepend silence: shift sound later in time.
function AudioSynth.shift(snd, sec)
	return AudioSynth.concat(AudioSynth.silence(sec), snd)
end

-- Echo: delaySec gap, feedback 0..1, count repeats.
function AudioSynth.echo(snd, delaySec, feedback, count)
	local out = snd
	local g = 1
	for _ = 1, (count or 1) do
		g = g * (feedback or 0.5)
		out = AudioSynth.mix(out, AudioSynth.gain(AudioSynth.shift(snd, delaySec * _), g))
	end
	return out
end

function AudioSynth.duration(snd)
	return #snd / AudioSynth.rate
end

-- Export ----------------------------------------------------------------
-- Returns WAV file bytes: PCM16, mono, AudioSynth.rate Hz.
function AudioSynth.toWav(snd)
	local len = #snd
	local data = table.create and table.create(len) or {}
	for i = 1, len do
		local v = math.floor(clamp(snd[i]) * 32767 + (snd[i] >= 0 and 0.5 or -0.5))
		if v < 0 then
			v = v + 65536
		end
		data[i] = string.char(v % 256, math.floor(v / 256) % 256)
	end
	local dataStr = table.concat(data)
	local byteRate = AudioSynth.rate * 2
	return table.concat({
		"RIFF",
		packU32(36 + #dataStr),
		"WAVE",
		"fmt ",
		packU32(16),
		packU16(1), -- PCM
		packU16(1), -- mono
		packU32(AudioSynth.rate),
		packU32(byteRate),
		packU16(2), -- block align
		packU16(16), -- bits
		"data",
		packU32(#dataStr),
		dataStr,
	})
end

-- Synthesize to disk. path is project-relative, e.g. "Audio/jump.wav".
function AudioSynth.save(path, snd)
	return Content:save(path, AudioSynth.toWav(snd))
end

return AudioSynth
