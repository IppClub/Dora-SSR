-- [ts]: AudioGenerator.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local HttpServer = ____Dora.HttpServer -- 2
local emit = ____Dora.emit -- 2
local ____Utils = require("Agent.Utils") -- 3
local Log = ____Utils.Log -- 3
local safeJsonDecode = ____Utils.safeJsonDecode -- 3
local safeJsonEncode = ____Utils.safeJsonEncode -- 3
local function isValidWorkspacePath(path) -- 5
	if not path or #path == 0 then -- 5
		return false -- 6
	end -- 6
	if Content:isAbsolutePath(path) then -- 6
		return false -- 7
	end -- 7
	if __TS__StringIncludes(path, "..") then -- 7
		return false -- 8
	end -- 8
	return true -- 9
end -- 5
local function isValidWorkDir(workDir) -- 12
	if not workDir or #workDir == 0 then -- 12
		return false -- 13
	end -- 13
	if not Content:isAbsolutePath(workDir) then -- 13
		return false -- 14
	end -- 14
	if not Content:exist(workDir) or not Content:isdir(workDir) then -- 14
		return false -- 15
	end -- 15
	return true -- 16
end -- 12
local function resolveWorkspaceFilePath(workDir, path) -- 19
	if not isValidWorkDir(workDir) then -- 19
		return nil -- 20
	end -- 20
	if not isValidWorkspacePath(path) then -- 20
		return nil -- 21
	end -- 21
	return Path(workDir, path) -- 22
end -- 19
local function ensureDirPath(dir) -- 25
	if not dir or dir == "." or dir == "" then -- 25
		return true -- 26
	end -- 26
	if Content:exist(dir) then -- 26
		return Content:isdir(dir) -- 27
	end -- 27
	local parent = Path:getPath(dir) -- 28
	if parent ~= dir and parent ~= "." and parent ~= "" then -- 28
		if not ensureDirPath(parent) then -- 28
			return false -- 30
		end -- 30
	end -- 30
	return Content:mkdir(dir) -- 32
end -- 25
local function ensureDirForFile(path) -- 35
	return ensureDirPath(Path:getPath(path)) -- 36
end -- 35
local operationIdStep = 0 -- 39
local function createOperationId() -- 41
	operationIdStep = operationIdStep + 1 -- 42
	local raw = (((tostring(os.time()) .. "-") .. tostring(operationIdStep)) .. "-") .. tostring(math.floor(math.random() * 1000000000)) -- 43
	local safe = string.gsub(raw, "[^%w%-_]", "-") -- 44
	return safe -- 45
end -- 41
local function sendWebIDEFileUpdate(file, exists, content) -- 48
	if HttpServer.wsConnectionCount == 0 then -- 48
		return true -- 49
	end -- 49
	local payload = safeJsonEncode({name = "UpdateFile", file = file, exists = exists, content = content}) -- 50
	if not payload then -- 50
		return false -- 51
	end -- 51
	emit("AppWS", "Send", payload) -- 52
	return true -- 53
end -- 48
local function syncGeneratedFileToWebIDE(file) -- 56
	local content = "" -- 57
	do -- 57
		local function ____catch(e) -- 57
			Log( -- 65
				"Warn", -- 65
				(("[Agent.AudioGenerator] failed to inspect generated file for Web IDE update file=" .. file) .. ": ") .. tostring(e) -- 65
			) -- 65
		end -- 65
		local ____try, ____hasReturned = pcall(function() -- 65
			local ____, isBinary = Content:getAttr(file) -- 59
			if not isBinary then -- 59
				local loaded = Content:load(file) -- 61
				content = type(loaded) == "string" and loaded or "" -- 62
			end -- 62
		end) -- 62
		if not ____try then -- 62
			____catch(____hasReturned) -- 62
		end -- 62
	end -- 62
	return sendWebIDEFileUpdate(file, true, content) -- 67
end -- 56
local SFX_SAMPLE_RATE = 44100 -- 103
local SFX_MAX_SAMPLES = SFX_SAMPLE_RATE * 3 -- 104
local SFX_OVERSAMPLING = 8 -- 105
local SFX_NOISE_SIZE = 32 -- 106
local SFX_PHASER_SIZE = 1024 -- 107
local SFX_WAV_PACK_CHUNK = 1024 -- 108
--- Park-Miller LCG. Math.random is not acceptable here: the same seed must
-- always reproduce the same sound, and ordinary double arithmetic keeps the
-- multiplication exact (state * 16807 stays below 2^53).
local function createSfxRng(seed) -- 119
	local state = math.floor(math.abs(seed)) % 2147483647 -- 120
	if state <= 0 then -- 120
		state = 1 -- 121
	end -- 121
	return {next = function() -- 122
		state = state * 16807 % 2147483647 -- 124
		return (state - 1) / 2147483646 -- 125
	end} -- 123
end -- 119
local function resetSfxrParams() -- 156
	return { -- 157
		waveType = 0, -- 158
		startFreq = 0.3, -- 159
		minFreq = 0, -- 160
		slide = 0, -- 161
		deltaSlide = 0, -- 162
		duty = 0, -- 163
		dutySweep = 0, -- 164
		vibDepth = 0, -- 165
		vibSpeed = 0, -- 166
		attack = 0, -- 167
		sustain = 0.3, -- 168
		decay = 0.4, -- 169
		punch = 0, -- 170
		changeAmount = 0, -- 171
		changeSpeed = 0, -- 172
		phaserOffset = 0, -- 173
		phaserSweep = 0, -- 174
		lpCutoff = 1, -- 175
		lpCutoffSweep = 0, -- 176
		lpResonance = 0, -- 177
		hpCutoff = 0, -- 178
		hpCutoffSweep = 0, -- 179
		repeatSpeed = 0 -- 180
	} -- 180
end -- 156
--- Preset generators ported from the classic sfxr/as3sfxr randomizers.
-- Parameter names map: changeAmount = arp_mod, changeSpeed = arp_speed.
local function generateSfxrPreset(kind, rng) -- 188
	local function rnd() -- 189
		return rng:next() -- 189
	end -- 189
	local function frnd(range) -- 190
		return rnd() * range -- 190
	end -- 190
	local p = resetSfxrParams() -- 191
	repeat -- 191
		local ____switch34 = kind -- 191
		local ____cond34 = ____switch34 == "pickup" -- 191
		if ____cond34 then -- 191
			do -- 191
				p.waveType = math.floor(rnd() * 3) -- 194
				p.startFreq = 0.4 + frnd(0.5) -- 195
				p.attack = 0 -- 196
				p.sustain = frnd(0.1) -- 197
				p.decay = 0.1 + frnd(0.4) -- 198
				p.punch = 0.3 + frnd(0.3) -- 199
				if rnd() < 0.5 then -- 199
					p.changeSpeed = 0.5 + frnd(0.2) -- 201
					p.changeAmount = 0.2 + frnd(0.4) -- 202
				end -- 202
				break -- 204
			end -- 204
		end -- 204
		____cond34 = ____cond34 or ____switch34 == "laser" -- 204
		if ____cond34 then -- 204
			do -- 204
				p.waveType = math.floor(rnd() * 3) -- 207
				if p.waveType == 2 and rnd() < 0.5 then -- 207
					p.waveType = math.floor(rnd() * 2) -- 208
				end -- 208
				p.startFreq = 0.5 + frnd(0.5) -- 209
				p.minFreq = p.startFreq - 0.2 - frnd(0.6) -- 210
				if p.minFreq < 0.2 then -- 210
					p.minFreq = 0.2 -- 211
				end -- 211
				p.slide = -0.15 - frnd(0.2) -- 212
				if rnd() < 0.33 then -- 212
					p.startFreq = 0.3 + frnd(0.6) -- 214
					p.minFreq = frnd(0.1) -- 215
					p.slide = -0.35 - frnd(0.3) -- 216
				end -- 216
				if rnd() < 0.5 then -- 216
					p.duty = frnd(0.5) -- 219
					p.dutySweep = frnd(0.2) -- 220
				else -- 220
					p.duty = 0.4 + frnd(0.5) -- 222
					p.dutySweep = -frnd(0.7) -- 223
				end -- 223
				p.attack = 0 -- 225
				p.sustain = 0.1 + frnd(0.2) -- 226
				p.decay = frnd(0.4) -- 227
				if rnd() < 0.5 then -- 227
					p.punch = frnd(0.3) -- 228
				end -- 228
				if rnd() < 0.33 then -- 228
					p.phaserOffset = frnd(0.2) -- 230
					p.phaserSweep = -frnd(0.2) -- 231
				end -- 231
				if rnd() < 0.5 then -- 231
					p.hpCutoff = frnd(0.3) -- 233
				end -- 233
				break -- 234
			end -- 234
		end -- 234
		____cond34 = ____cond34 or ____switch34 == "explosion" -- 234
		if ____cond34 then -- 234
			do -- 234
				p.waveType = 3 -- 237
				p.startFreq = 0.1 + frnd(0.4) -- 238
				p.slide = -0.1 + frnd(0.4) -- 239
				p.attack = 0 -- 240
				p.sustain = 0.1 + frnd(0.2) -- 241
				p.decay = frnd(0.5) -- 242
				if rnd() < 0.5 then -- 242
					p.phaserOffset = -0.3 + frnd(0.9) -- 244
					p.phaserSweep = -frnd(0.3) -- 245
				end -- 245
				if rnd() < 0.33 then -- 245
					p.startFreq = 0.2 + frnd(0.7) -- 248
					p.slide = -0.2 - frnd(0.2) -- 249
				end -- 249
				if rnd() < 0.5 then -- 249
					p.punch = 0.2 + frnd(0.6) -- 251
				end -- 251
				break -- 252
			end -- 252
		end -- 252
		____cond34 = ____cond34 or ____switch34 == "powerup" -- 252
		if ____cond34 then -- 252
			do -- 252
				p.waveType = rnd() < 0.5 and 0 or 1 -- 255
				p.startFreq = 0.2 + frnd(0.3) -- 256
				p.slide = 0.1 + frnd(0.2) -- 257
				p.changeAmount = 0.2 + frnd(0.4) -- 258
				p.changeSpeed = 0.6 + frnd(0.3) -- 259
				p.attack = 0 -- 260
				p.sustain = 0.2 + frnd(0.3) -- 261
				p.decay = frnd(0.2) -- 262
				p.punch = 0.2 + frnd(0.4) -- 263
				break -- 264
			end -- 264
		end -- 264
		____cond34 = ____cond34 or ____switch34 == "hit" -- 264
		if ____cond34 then -- 264
			do -- 264
				p.waveType = math.floor(rnd() * 3) -- 267
				if p.waveType == 2 then -- 267
					p.waveType = 3 -- 268
				end -- 268
				p.startFreq = 0.2 + frnd(0.6) -- 269
				p.slide = -0.3 - frnd(0.4) -- 270
				p.attack = 0 -- 271
				p.sustain = frnd(0.1) -- 272
				p.decay = 0.1 + frnd(0.2) -- 273
				if rnd() < 0.5 then -- 273
					p.hpCutoff = frnd(0.3) -- 274
				end -- 274
				break -- 275
			end -- 275
		end -- 275
		____cond34 = ____cond34 or ____switch34 == "jump" -- 275
		if ____cond34 then -- 275
			do -- 275
				p.waveType = 0 -- 278
				p.startFreq = 0.3 + frnd(0.3) -- 279
				p.slide = 0.1 + frnd(0.2) -- 280
				p.attack = 0 -- 281
				p.sustain = 0.1 + frnd(0.3) -- 282
				p.decay = 0.1 + frnd(0.2) -- 283
				if rnd() < 0.5 then -- 283
					p.duty = frnd(0.6) -- 285
					p.dutySweep = frnd(0.2) -- 286
				end -- 286
				break -- 288
			end -- 288
		end -- 288
		____cond34 = ____cond34 or ____switch34 == "click" -- 288
		if ____cond34 then -- 288
			do -- 288
				p.waveType = math.floor(rnd() * 2) -- 291
				p.startFreq = 0.2 + frnd(0.4) -- 292
				p.attack = 0 -- 293
				p.sustain = 0.05 + frnd(0.05) -- 294
				p.decay = 0.05 + frnd(0.15) -- 295
				p.hpCutoff = 0.1 -- 296
				break -- 297
			end -- 297
		end -- 297
		do -- 297
			do -- 297
				local families = { -- 300
					"jump", -- 300
					"explosion", -- 300
					"hit", -- 300
					"pickup", -- 300
					"laser", -- 300
					"powerup", -- 300
					"click" -- 300
				} -- 300
				return generateSfxrPreset( -- 301
					families[math.floor(rnd() * #families) + 1], -- 301
					rng -- 301
				) -- 301
			end -- 301
		end -- 301
	until true -- 301
	return p -- 304
end -- 188
--- Synthesize float samples in [-1, 1] from sfxr parameters. Port of the
-- classic sfxr sample generator: frequency slide, arpeggio, vibrato, square
-- duty sweep, ADSR envelope with punch, one-pole low/high pass filters, and a
-- phaser tap. Length is bounded by the envelope plus SFX_MAX_SAMPLES.
local function synthSfxr(p, masterVolume, rng) -- 313
	local samples = {} -- 314
	local startPeriod = 100 / (p.startFreq * p.startFreq + 0.001) -- 315
	local fperiod = startPeriod -- 316
	local period = math.floor(fperiod) -- 317
	local fmaxperiod = 100 / (p.minFreq * p.minFreq + 0.001) -- 318
	local startSlide = 1 - p.slide ^ 3 * 0.01 -- 319
	local fslide = startSlide -- 320
	local fdslide = -p.deltaSlide ^ 3 * 0.000001 -- 321
	local squareDuty = 0.5 - p.duty * 0.5 -- 322
	local squareSlide = -p.dutySweep * 0.00005 -- 323
	local arpMod = p.changeAmount >= 0 and 1 - p.changeAmount ^ 2 * 0.9 or 1 + p.changeAmount ^ 2 * 10 -- 324
	local arpTime = 0 -- 327
	local arpLimit = math.floor((1 - p.changeSpeed) ^ 2 * 20000) + 32 -- 328
	if p.changeSpeed >= 1 then -- 328
		arpLimit = 0 -- 329
	end -- 329
	local envStage = 0 -- 330
	local envTime = 0 -- 331
	local envLength = { -- 332
		math.max( -- 333
			1, -- 333
			math.floor(p.attack * p.attack * 100000) -- 333
		), -- 333
		math.max( -- 334
			1, -- 334
			math.floor(p.sustain * p.sustain * 100000) -- 334
		), -- 334
		math.max( -- 335
			1, -- 335
			math.floor(p.decay * p.decay * 100000) -- 335
		) -- 335
	} -- 335
	local phaserBuffer = {} -- 337
	do -- 337
		local i = 0 -- 338
		while i < SFX_PHASER_SIZE do -- 338
			phaserBuffer[#phaserBuffer + 1] = 0 -- 338
			i = i + 1 -- 338
		end -- 338
	end -- 338
	local fphase = p.phaserOffset ^ 2 * 1020 -- 339
	if p.phaserOffset < 0 then -- 339
		fphase = -fphase -- 340
	end -- 340
	local fdsweep = p.phaserSweep ^ 2 * (p.phaserSweep < 0 and -1 or 1) -- 341
	local iphase = math.floor(math.abs(fphase)) -- 342
	if iphase > SFX_PHASER_SIZE - 1 then -- 342
		iphase = SFX_PHASER_SIZE - 1 -- 343
	end -- 343
	local ipp = 0 -- 344
	local phaserOn = p.phaserOffset ~= 0 or p.phaserSweep ~= 0 -- 345
	local noiseBuffer = {} -- 346
	do -- 346
		local i = 0 -- 347
		while i < SFX_NOISE_SIZE do -- 347
			noiseBuffer[#noiseBuffer + 1] = rng:next() * 2 - 1 -- 347
			i = i + 1 -- 347
		end -- 347
	end -- 347
	local fltp = 0 -- 348
	local fltdp = 0 -- 349
	local fltw = p.lpCutoff ^ 3 * 0.1 -- 350
	local fltwD = 1 + p.lpCutoffSweep * 0.0001 -- 351
	local fltdmp = 5 / (1 + p.lpResonance ^ 2 * 20) * (0.01 + fltw) -- 352
	local fltphp = 0 -- 353
	local flthp = p.hpCutoff ^ 2 * 0.1 -- 354
	local flthpD = 1 + p.hpCutoffSweep * 0.0003 -- 355
	local vibPhase = 0 -- 356
	local vibSpeed = p.vibSpeed ^ 2 * 0.01 -- 357
	local vibAmp = p.vibDepth * 0.5 -- 358
	local repeatTime = 0 -- 359
	local repeatLimit = p.repeatSpeed > 0 and math.floor((1 - p.repeatSpeed) ^ 2 * 20000) + 32 or 0 -- 360
	local phase = 0 -- 363
	local finished = false -- 364
	while not finished and #samples < SFX_MAX_SAMPLES do -- 364
		repeatTime = repeatTime + 1 -- 366
		if repeatLimit > 0 and repeatTime >= repeatLimit then -- 366
			repeatTime = 0 -- 368
			fperiod = startPeriod -- 369
			fslide = startSlide -- 370
		end -- 370
		arpTime = arpTime + 1 -- 372
		if arpLimit > 0 and arpTime >= arpLimit then -- 372
			arpLimit = 0 -- 374
			fperiod = fperiod * arpMod -- 375
		end -- 375
		fslide = fslide + fdslide -- 377
		fperiod = fperiod * fslide -- 378
		if fperiod > fmaxperiod then -- 378
			fperiod = fmaxperiod -- 380
			if p.minFreq > 0 then -- 380
				finished = true -- 381
			end -- 381
		end -- 381
		local rfperiod = fperiod -- 383
		if vibAmp > 0 then -- 383
			vibPhase = vibPhase + vibSpeed -- 385
			rfperiod = fperiod * (1 + math.sin(vibPhase) * vibAmp) -- 386
		end -- 386
		period = math.floor(rfperiod) -- 388
		if period < SFX_OVERSAMPLING then -- 388
			period = SFX_OVERSAMPLING -- 389
		end -- 389
		squareDuty = squareDuty + squareSlide -- 390
		if squareDuty < 0 then -- 390
			squareDuty = 0 -- 391
		end -- 391
		if squareDuty > 0.5 then -- 391
			squareDuty = 0.5 -- 392
		end -- 392
		envTime = envTime + 1 -- 393
		if envStage == 0 and envTime >= envLength[1] then -- 393
			envStage = 1 -- 395
			envTime = 0 -- 396
		elseif envStage == 1 and envTime >= envLength[2] then -- 396
			envStage = 2 -- 398
			envTime = 0 -- 399
		elseif envStage == 2 and envTime >= envLength[3] then -- 399
			finished = true -- 401
		end -- 401
		local envVol = 0 -- 403
		if envStage == 0 then -- 403
			envVol = envTime / envLength[1] -- 404
		elseif envStage == 1 then -- 404
			envVol = 1 + (1 - envTime / envLength[2]) * 2 * p.punch -- 405
		else -- 405
			envVol = 1 - envTime / envLength[3] -- 406
		end -- 406
		fphase = fphase + fdsweep -- 407
		iphase = math.floor(math.abs(fphase)) -- 408
		if iphase > SFX_PHASER_SIZE - 1 then -- 408
			iphase = SFX_PHASER_SIZE - 1 -- 409
		end -- 409
		flthp = flthp * flthpD -- 410
		if flthp < 0 then -- 410
			flthp = 0 -- 411
		end -- 411
		if flthp > 0.1 then -- 411
			flthp = 0.1 -- 412
		end -- 412
		local sample = 0 -- 413
		do -- 413
			local subSampleIndex = 0 -- 414
			while subSampleIndex < SFX_OVERSAMPLING do -- 414
				phase = phase + 1 -- 415
				if phase >= period then -- 415
					phase = phase % period -- 417
					if p.waveType == 3 then -- 417
						do -- 417
							local i = 0 -- 419
							while i < SFX_NOISE_SIZE do -- 419
								noiseBuffer[i + 1] = rng:next() * 2 - 1 -- 419
								i = i + 1 -- 419
							end -- 419
						end -- 419
					end -- 419
				end -- 419
				local cyclePos = phase / period -- 422
				local subSample = 0 -- 423
				if p.waveType == 0 then -- 423
					subSample = cyclePos < squareDuty and 0.5 or -0.5 -- 424
				elseif p.waveType == 1 then -- 424
					subSample = 1 - cyclePos * 2 -- 425
				elseif p.waveType == 2 then -- 425
					subSample = math.sin(cyclePos * 2 * math.pi) -- 426
				else -- 426
					subSample = noiseBuffer[math.floor(cyclePos * SFX_NOISE_SIZE) + 1] -- 427
				end -- 427
				local prevFltp = fltp -- 428
				fltw = fltw * fltwD -- 429
				if fltw < 0 then -- 429
					fltw = 0 -- 430
				end -- 430
				if fltw > 0.1 then -- 430
					fltw = 0.1 -- 431
				end -- 431
				if p.lpCutoff >= 1 then -- 431
					fltp = subSample -- 433
					fltdp = 0 -- 434
				else -- 434
					fltdp = fltdp + (subSample - fltp) * fltw -- 436
					fltdp = fltdp - fltdp * fltdmp -- 437
					fltp = fltp + fltdp -- 438
				end -- 438
				fltphp = fltphp + (fltp - prevFltp) -- 440
				fltphp = fltphp - fltphp * flthp -- 441
				subSample = fltphp -- 442
				if phaserOn then -- 442
					phaserBuffer[ipp + 1] = subSample -- 444
					subSample = subSample + phaserBuffer[(ipp - iphase + SFX_PHASER_SIZE) % SFX_PHASER_SIZE + 1] -- 445
					ipp = (ipp + 1) % SFX_PHASER_SIZE -- 446
				end -- 446
				sample = sample + subSample * envVol -- 448
				subSampleIndex = subSampleIndex + 1 -- 414
			end -- 414
		end -- 414
		sample = sample / SFX_OVERSAMPLING -- 450
		if sample > 1 then -- 450
			sample = 1 -- 451
		end -- 451
		if sample < -1 then -- 451
			sample = -1 -- 452
		end -- 452
		samples[#samples + 1] = sample * masterVolume -- 453
	end -- 453
	return samples -- 455
end -- 313
local function encodePcmWav(samples, sampleRate, rightSamples) -- 458
	local channels = rightSamples and 2 or 1 -- 459
	local dataSize = #samples * channels * 2 -- 460
	local parts = {} -- 461
	parts[#parts + 1] = string.pack("<c4I4c4", "RIFF", 36 + dataSize, "WAVE") -- 462
	parts[#parts + 1] = string.pack( -- 463
		"<c4I4I2I2I4I4I2I2", -- 463
		"fmt ", -- 463
		16, -- 463
		1, -- 463
		channels, -- 463
		sampleRate, -- 463
		sampleRate * channels * 2, -- 463
		channels * 2, -- 463
		16 -- 463
	) -- 463
	parts[#parts + 1] = string.pack("<c4I4", "data", dataSize) -- 464
	do -- 464
		local start = 0 -- 465
		while start < #samples do -- 465
			local ____end = math.min(start + SFX_WAV_PACK_CHUNK, #samples) -- 466
			local fmt = "<" -- 467
			local values = {} -- 468
			do -- 468
				local i = start -- 469
				while i < ____end do -- 469
					fmt = fmt .. "i2" -- 470
					local left = samples[i + 1] -- 471
					local leftRaw = left >= 0 and math.floor(left * 32767 + 0.5) or math.ceil(left * 32768 - 0.5) -- 472
					values[#values + 1] = math.max( -- 473
						-32768, -- 473
						math.min(32767, leftRaw) -- 473
					) -- 473
					if rightSamples then -- 473
						fmt = fmt .. "i2" -- 475
						local right = rightSamples[i + 1] -- 476
						local rightRaw = right >= 0 and math.floor(right * 32767 + 0.5) or math.ceil(right * 32768 - 0.5) -- 477
						values[#values + 1] = math.max( -- 478
							-32768, -- 478
							math.min(32767, rightRaw) -- 478
						) -- 478
					end -- 478
					i = i + 1 -- 469
				end -- 469
			end -- 469
			parts[#parts + 1] = string.pack( -- 481
				fmt, -- 481
				table.unpack(values) -- 481
			) -- 481
			start = start + SFX_WAV_PACK_CHUNK -- 465
		end -- 465
	end -- 465
	return table.concat(parts, "") -- 483
end -- 458
local sfxAutoSeedStep = 0 -- 486
function ____exports.generateSfx(req) -- 488
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 488
		local relPath = __TS__StringTrim(req.path or "") -- 497
		if relPath == "" then -- 497
			return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 497
		end -- 497
		if not __TS__StringEndsWith( -- 497
			string.lower(relPath), -- 501
			".wav" -- 501
		) then -- 501
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "generate_sfx writes WAV files; path must end in .wav"}) -- 501
		end -- 501
		local kind = string.lower(__TS__StringTrim(req.type or "")) -- 504
		local validKinds = { -- 505
			"jump", -- 505
			"explosion", -- 505
			"hit", -- 505
			"pickup", -- 505
			"laser", -- 505
			"powerup", -- 505
			"click", -- 505
			"random" -- 505
		} -- 505
		if __TS__ArrayIndexOf(validKinds, kind) < 0 then -- 505
			return ____awaiter_resolve( -- 505
				nil, -- 505
				{ -- 507
					success = false, -- 507
					path = relPath, -- 507
					message = (("unknown type '" .. req.type) .. "'; expected one of: ") .. table.concat(validKinds, ", ") -- 507
				} -- 507
			) -- 507
		end -- 507
		local target = resolveWorkspaceFilePath(req.workDir, relPath) -- 509
		if not target then -- 509
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "invalid path"}) -- 509
		end -- 509
		if Content:exist(target) and Content:isdir(target) then -- 509
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "target path is a directory"}) -- 509
		end -- 509
		local ____this_1 -- 509
		____this_1 = req -- 516
		local ____opt_0 = ____this_1.isCancelled -- 516
		if (____opt_0 and ____opt_0(____this_1)) == true then -- 516
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "canceled", interrupted = true}) -- 516
		end -- 516
		sfxAutoSeedStep = sfxAutoSeedStep + 1 -- 519
		local seed = 0 -- 520
		if type(req.seed) == "number" and req.seed == req.seed and math.abs(req.seed) < 2147483647 then -- 520
			seed = math.floor(req.seed) -- 522
		else -- 522
			seed = os.time() % 1000000000 + sfxAutoSeedStep * 7919 -- 524
		end -- 524
		local volume = 0.8 -- 526
		if type(req.volume) == "number" and req.volume == req.volume then -- 526
			volume = math.min( -- 528
				1, -- 528
				math.max(0, req.volume) -- 528
			) -- 528
		end -- 528
		local operationId = createOperationId() -- 530
		local rng = createSfxRng(seed) -- 531
		local presetKind = kind -- 532
		if presetKind == "random" then -- 532
			local families = { -- 534
				"jump", -- 534
				"explosion", -- 534
				"hit", -- 534
				"pickup", -- 534
				"laser", -- 534
				"powerup", -- 534
				"click" -- 534
			} -- 534
			presetKind = families[math.floor(rng:next() * #families) + 1] -- 535
		end -- 535
		local ____this_3 -- 535
		____this_3 = req -- 537
		local ____opt_2 = ____this_3.onProgress -- 537
		if ____opt_2 ~= nil then -- 537
			____opt_2(____this_3, { -- 537
				state = "running", -- 538
				operationId = operationId, -- 539
				path = relPath, -- 540
				stage = "synth", -- 541
				message = "synthesizing " .. presetKind -- 542
			}) -- 542
		end -- 542
		local params = generateSfxrPreset(presetKind, rng) -- 544
		local samples = synthSfxr(params, volume, rng) -- 545
		if #samples == 0 then -- 545
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "synthesis produced no samples"}) -- 545
		end -- 545
		local ____this_5 -- 545
		____this_5 = req -- 549
		local ____opt_4 = ____this_5.isCancelled -- 549
		if (____opt_4 and ____opt_4(____this_5)) == true then -- 549
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "canceled", interrupted = true}) -- 549
		end -- 549
		local ____this_7 -- 549
		____this_7 = req -- 552
		local ____opt_6 = ____this_7.onProgress -- 552
		if ____opt_6 ~= nil then -- 552
			____opt_6(____this_7, { -- 552
				state = "running", -- 553
				operationId = operationId, -- 554
				path = relPath, -- 555
				stage = "write", -- 556
				message = "writing WAV" -- 557
			}) -- 557
		end -- 557
		local wav = encodePcmWav(samples, SFX_SAMPLE_RATE) -- 559
		if not ensureDirForFile(target) then -- 559
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "failed to create target directory"}) -- 559
		end -- 559
		if not Content:save(target, wav) then -- 559
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "failed to write WAV file"}) -- 559
		end -- 559
		if not syncGeneratedFileToWebIDE(target) then -- 559
			Log("Warn", "[generate_sfx] failed to sync file update target=" .. target) -- 567
		end -- 567
		local durationSeconds = math.floor(#samples / SFX_SAMPLE_RATE * 100 + 0.5) / 100 -- 569
		Log( -- 570
			"Info", -- 570
			(((((((("[generate_sfx] type=" .. presetKind) .. " seed=") .. tostring(seed)) .. " path=") .. relPath) .. " bytes=") .. tostring(#wav)) .. " samples=") .. tostring(#samples) -- 570
		) -- 570
		return ____awaiter_resolve( -- 570
			nil, -- 570
			{ -- 571
				success = true, -- 572
				path = relPath, -- 573
				bytesWritten = #wav, -- 574
				durationSeconds = durationSeconds, -- 575
				sampleRate = SFX_SAMPLE_RATE, -- 576
				seed = seed, -- 577
				description = ((((((((((((("Saved a " .. presetKind) .. " sound effect to ") .. relPath) .. " (") .. tostring(#wav)) .. " bytes, ") .. tostring(durationSeconds)) .. "s, mono 16-bit ") .. tostring(SFX_SAMPLE_RATE)) .. " Hz, seed ") .. tostring(seed)) .. "). Play it with Audio.play(\"") .. relPath) .. "\") or an audio-source node; regenerate with a new seed or reproduce it with the same seed." -- 578
			} -- 578
		) -- 578
	end) -- 578
end -- 488
local MUSIC_SAMPLE_RATE = 44100 -- 702
local MUSIC_STEPS_PER_BAR = 16 -- 703
local MUSIC_MIN_SECONDS = 4 -- 704
local MUSIC_MAX_SECONDS = 32 -- 705
local MUSIC_NOISE_SIZE = 2048 -- 706
local MUSIC_RENDER_CHUNK = 8192 -- 707
local MUSIC_KEY_NAMES = { -- 708
	"C", -- 708
	"C#", -- 708
	"D", -- 708
	"D#", -- 708
	"E", -- 708
	"F", -- 708
	"F#", -- 708
	"G", -- 708
	"G#", -- 708
	"A", -- 708
	"A#", -- 708
	"B" -- 708
} -- 708
local MUSIC_VALID_MODES = { -- 709
	"major", -- 709
	"minor", -- 709
	"pentatonic", -- 709
	"harmonic_minor", -- 709
	"dorian", -- 709
	"phrygian", -- 709
	"chromatic" -- 709
} -- 709
local MUSIC_VALID_INSTRUMENTS = { -- 710
	"square", -- 710
	"pulse", -- 710
	"saw", -- 710
	"triangle", -- 710
	"sine", -- 710
	"organ", -- 710
	"bell", -- 710
	"pluck", -- 710
	"fm", -- 710
	"pad", -- 710
	"sub", -- 710
	"guitar", -- 710
	"strings" -- 710
} -- 710
local function clamp01(value) -- 712
	return math.min( -- 713
		1, -- 713
		math.max(0, value) -- 713
	) -- 713
end -- 712
local function getMusicStyleConfig(style) -- 716
	repeat -- 716
		local ____switch125 = style -- 716
		local ____cond125 = ____switch125 == "adventure" -- 716
		if ____cond125 then -- 716
			return { -- 718
				bpm = 124, -- 719
				mode = "major", -- 719
				progression = {0, 3, 4, 0}, -- 719
				melodyStepSpan = 2, -- 719
				melodyDensity = 0.82, -- 720
				leadInstrument = "strings", -- 720
				bassInstrument = "triangle", -- 720
				harmonyInstrument = "organ", -- 720
				melodyMix = 0.28, -- 721
				bassMix = 0.24, -- 721
				harmonyMix = 0.15, -- 721
				drumMix = 0.22, -- 721
				hatStride = 2, -- 721
				reverb = 0.16, -- 722
				delay = 0.1, -- 722
				chorus = 0.18, -- 722
				distortion = 0.04 -- 722
			} -- 722
		end -- 722
		____cond125 = ____cond125 or ____switch125 == "calm" -- 722
		if ____cond125 then -- 722
			return { -- 724
				bpm = 84, -- 725
				mode = "pentatonic", -- 725
				progression = {0, 4, 3, 4}, -- 725
				melodyStepSpan = 4, -- 725
				melodyDensity = 0.72, -- 726
				leadInstrument = "bell", -- 726
				bassInstrument = "sub", -- 726
				harmonyInstrument = "pad", -- 726
				melodyMix = 0.3, -- 727
				bassMix = 0.2, -- 727
				harmonyMix = 0.18, -- 727
				drumMix = 0.1, -- 727
				hatStride = 4, -- 727
				reverb = 0.34, -- 728
				delay = 0.16, -- 728
				chorus = 0.28, -- 728
				distortion = 0 -- 728
			} -- 728
		end -- 728
		____cond125 = ____cond125 or ____switch125 == "tense" -- 728
		if ____cond125 then -- 728
			return { -- 730
				bpm = 152, -- 731
				mode = "minor", -- 731
				progression = {0, 5, 6, 4}, -- 731
				melodyStepSpan = 2, -- 731
				melodyDensity = 0.88, -- 732
				leadInstrument = "saw", -- 732
				bassInstrument = "saw", -- 732
				harmonyInstrument = "pulse", -- 732
				melodyMix = 0.24, -- 733
				bassMix = 0.29, -- 733
				harmonyMix = 0.15, -- 733
				drumMix = 0.26, -- 733
				hatStride = 1, -- 733
				reverb = 0.1, -- 734
				delay = 0.08, -- 734
				chorus = 0.1, -- 734
				distortion = 0.2 -- 734
			} -- 734
		end -- 734
		____cond125 = ____cond125 or ____switch125 == "victory" -- 734
		if ____cond125 then -- 734
			return { -- 736
				bpm = 148, -- 737
				mode = "major", -- 737
				progression = {0, 3, 4, 0}, -- 737
				melodyStepSpan = 2, -- 737
				melodyDensity = 0.92, -- 738
				leadInstrument = "square", -- 738
				bassInstrument = "triangle", -- 738
				harmonyInstrument = "organ", -- 738
				melodyMix = 0.31, -- 739
				bassMix = 0.22, -- 739
				harmonyMix = 0.18, -- 739
				drumMix = 0.24, -- 739
				hatStride = 2, -- 739
				reverb = 0.22, -- 740
				delay = 0.12, -- 740
				chorus = 0.16, -- 740
				distortion = 0.04 -- 740
			} -- 740
		end -- 740
		do -- 740
			return { -- 742
				bpm = 138, -- 743
				mode = "major", -- 743
				progression = {0, 4, 5, 3}, -- 743
				melodyStepSpan = 2, -- 743
				melodyDensity = 0.86, -- 744
				leadInstrument = "square", -- 744
				bassInstrument = "saw", -- 744
				harmonyInstrument = "pulse", -- 744
				melodyMix = 0.28, -- 745
				bassMix = 0.25, -- 745
				harmonyMix = 0.16, -- 745
				drumMix = 0.22, -- 745
				hatStride = 2, -- 745
				reverb = 0.1, -- 746
				delay = 0.08, -- 746
				chorus = 0.12, -- 746
				distortion = 0.06 -- 746
			} -- 746
		end -- 746
	until true -- 746
end -- 716
local function musicScale(mode) -- 751
	if mode == "minor" then -- 751
		return { -- 752
			0, -- 752
			2, -- 752
			3, -- 752
			5, -- 752
			7, -- 752
			8, -- 752
			10 -- 752
		} -- 752
	end -- 752
	if mode == "pentatonic" then -- 752
		return { -- 753
			0, -- 753
			2, -- 753
			4, -- 753
			7, -- 753
			9 -- 753
		} -- 753
	end -- 753
	if mode == "harmonic_minor" then -- 753
		return { -- 754
			0, -- 754
			2, -- 754
			3, -- 754
			5, -- 754
			7, -- 754
			8, -- 754
			11 -- 754
		} -- 754
	end -- 754
	if mode == "dorian" then -- 754
		return { -- 755
			0, -- 755
			2, -- 755
			3, -- 755
			5, -- 755
			7, -- 755
			9, -- 755
			10 -- 755
		} -- 755
	end -- 755
	if mode == "phrygian" then -- 755
		return { -- 756
			0, -- 756
			1, -- 756
			3, -- 756
			5, -- 756
			7, -- 756
			8, -- 756
			10 -- 756
		} -- 756
	end -- 756
	if mode == "chromatic" then -- 756
		return { -- 757
			0, -- 757
			1, -- 757
			2, -- 757
			3, -- 757
			4, -- 757
			5, -- 757
			6, -- 757
			7, -- 757
			8, -- 757
			9, -- 757
			10, -- 757
			11 -- 757
		} -- 757
	end -- 757
	return { -- 758
		0, -- 758
		2, -- 758
		4, -- 758
		5, -- 758
		7, -- 758
		9, -- 758
		11 -- 758
	} -- 758
end -- 751
local function musicScaleNote(root, scale, degree) -- 761
	local octave = math.floor(degree / #scale) -- 762
	local index = degree % #scale -- 763
	return root + octave * 12 + scale[index + 1] -- 764
end -- 761
local function parseRomanDegree(token) -- 767
	local normalized = __TS__StringTrim(token) -- 768
	while __TS__StringStartsWith(normalized, "b") or __TS__StringStartsWith(normalized, "#") do -- 768
		normalized = string.sub(normalized, 2) -- 769
	end -- 769
	normalized = string.upper(normalized) -- 770
	if normalized == "I" then -- 770
		return 0 -- 771
	end -- 771
	if normalized == "II" then -- 771
		return 1 -- 772
	end -- 772
	if normalized == "III" then -- 772
		return 2 -- 773
	end -- 773
	if normalized == "IV" then -- 773
		return 3 -- 774
	end -- 774
	if normalized == "V" then -- 774
		return 4 -- 775
	end -- 775
	if normalized == "VI" then -- 775
		return 5 -- 776
	end -- 776
	if normalized == "VII" then -- 776
		return 6 -- 777
	end -- 777
	return nil -- 778
end -- 767
local function parseMusicProgression(text, fallback) -- 781
	local normalized = __TS__StringTrim(text or "") -- 782
	if normalized == "" then -- 782
		return { -- 783
			degrees = __TS__ArraySlice(fallback), -- 783
			text = table.concat( -- 783
				__TS__ArrayMap( -- 783
					fallback, -- 783
					function(____, value) return tostring(value) end -- 783
				), -- 783
				"," -- 783
			) -- 783
		} -- 783
	end -- 783
	local tokens = __TS__StringSplit(normalized, ",") -- 784
	local degrees = {} -- 785
	do -- 785
		local i = 0 -- 786
		while i < #tokens do -- 786
			local degree = parseRomanDegree(tokens[i + 1]) -- 787
			if degree == nil then -- 787
				return { -- 788
					degrees = __TS__ArraySlice(fallback), -- 788
					text = table.concat( -- 788
						__TS__ArrayMap( -- 788
							fallback, -- 788
							function(____, value) return tostring(value) end -- 788
						), -- 788
						"," -- 788
					) -- 788
				} -- 788
			end -- 788
			degrees[#degrees + 1] = degree -- 789
			i = i + 1 -- 786
		end -- 786
	end -- 786
	return #degrees > 0 and ({degrees = degrees, text = normalized}) or ({ -- 791
		degrees = __TS__ArraySlice(fallback), -- 791
		text = table.concat( -- 791
			__TS__ArrayMap( -- 791
				fallback, -- 791
				function(____, value) return tostring(value) end -- 791
			), -- 791
			"," -- 791
		) -- 791
	}) -- 791
end -- 781
local function parseMusicStructure(text) -- 794
	local tokens = __TS__StringSplit(text or "A,A,B,A", ",") -- 795
	local result = {} -- 796
	do -- 796
		local i = 0 -- 797
		while i < #tokens and #result < 8 do -- 797
			local label = string.upper(__TS__StringTrim(tokens[i + 1])) -- 798
			if label ~= "" then -- 798
				result[#result + 1] = string.sub(label, 1, 8) -- 799
			end -- 799
			i = i + 1 -- 797
		end -- 797
	end -- 797
	return #result > 0 and result or ({"A"}) -- 801
end -- 794
local function resolveMusicInstrument(value, fallback) -- 804
	local normalized = string.lower(__TS__StringTrim(value or "auto")) -- 805
	return __TS__ArrayIndexOf(MUSIC_VALID_INSTRUMENTS, normalized) >= 0 and normalized or fallback -- 806
end -- 804
local function fillMusicNote(notes, ages, start, span, note) -- 809
	local ____end = math.min(start + span, #notes) -- 810
	do -- 810
		local i = start -- 811
		while i < ____end do -- 811
			notes[i + 1] = note -- 812
			ages[i + 1] = i - start -- 813
			i = i + 1 -- 811
		end -- 811
	end -- 811
end -- 809
local function sectionSeed(seed, label, barInSection, variation) -- 817
	local hash = 0 -- 818
	do -- 818
		local i = 0 -- 819
		while i < #label do -- 819
			hash = (hash * 31 + __TS__StringCharCodeAt(label, i)) % 2147483647 -- 819
			i = i + 1 -- 819
		end -- 819
	end -- 819
	return seed + hash * 131 + barInSection * 104729 + math.floor(variation * 10000) * 8191 -- 820
end -- 817
local function createMusicArrangement(options, bars, seedOffset) -- 823
	if seedOffset == nil then -- 823
		seedOffset = 0 -- 823
	end -- 823
	local totalSteps = bars * MUSIC_STEPS_PER_BAR -- 824
	local melodyNotes = {} -- 825
	local melodyAges = {} -- 826
	local bassNotes = {} -- 827
	local bassAges = {} -- 828
	local arpNotes = {} -- 829
	local chordRoots = {} -- 830
	local rootNote = 48 + options.rootPitchClass -- 831
	do -- 831
		local i = 0 -- 832
		while i < totalSteps do -- 832
			melodyNotes[#melodyNotes + 1] = -1 -- 833
			melodyAges[#melodyAges + 1] = 0 -- 833
			bassNotes[#bassNotes + 1] = -1 -- 833
			bassAges[#bassAges + 1] = 0 -- 833
			arpNotes[#arpNotes + 1] = -1 -- 834
			chordRoots[#chordRoots + 1] = rootNote -- 834
			i = i + 1 -- 832
		end -- 832
	end -- 832
	local scale = musicScale(options.mode) -- 836
	local styleConfig = getMusicStyleConfig(options.style) -- 837
	local chordToneChoices = {0, 2, 4, 7} -- 838
	local melodySpan = options.rhythmComplexity > 0.72 and 1 or styleConfig.melodyStepSpan -- 839
	local density = clamp01(styleConfig.melodyDensity * (0.55 + options.melodyComplexity * 0.65)) -- 840
	do -- 840
		local bar = 0 -- 841
		while bar < bars do -- 841
			local sectionIndex = math.floor(bar / options.barsPerSection) % #options.structure -- 842
			local sectionLabel = options.structure[sectionIndex + 1] -- 843
			local barInSection = bar % options.barsPerSection -- 844
			local localRng = createSfxRng(sectionSeed(options.seed + seedOffset, sectionLabel, barInSection, options.variation)) -- 845
			local sectionOffset = math.max( -- 846
				0, -- 846
				(string.byte(sectionLabel, 1) or 0 / 0) - 65 -- 846
			) -- 846
			local progressionIndex = (barInSection + sectionOffset) % #options.progression -- 847
			local chordDegree = options.progression[progressionIndex + 1] -- 848
			local chordRoot = musicScaleNote(rootNote, scale, chordDegree) -- 849
			local barStart = bar * MUSIC_STEPS_PER_BAR -- 850
			do -- 850
				local localStep = 0 -- 851
				while localStep < MUSIC_STEPS_PER_BAR do -- 851
					local step = barStart + localStep -- 852
					chordRoots[step + 1] = chordRoot -- 853
					if options.intensity > 0.25 or localStep % 2 == 0 then -- 853
						local arpTone = ({0, 2, 4, 2})[localStep % 4 + 1] -- 855
						arpNotes[step + 1] = musicScaleNote(rootNote + 12, scale, chordDegree + arpTone) -- 856
					end -- 856
					localStep = localStep + 1 -- 851
				end -- 851
			end -- 851
			do -- 851
				local localStep = 0 -- 859
				while localStep < MUSIC_STEPS_PER_BAR do -- 859
					local step = barStart + localStep -- 860
					local movingBass = options.intensity > 0.58 and localStep == 12 -- 861
					local bassDegree = chordDegree + (movingBass and 4 or 0) -- 862
					fillMusicNote( -- 863
						bassNotes, -- 863
						bassAges, -- 863
						step, -- 863
						4, -- 863
						musicScaleNote(rootNote - 12, scale, bassDegree) -- 863
					) -- 863
					localStep = localStep + 4 -- 859
				end -- 859
			end -- 859
			do -- 859
				local localStep = 0 -- 865
				while localStep < MUSIC_STEPS_PER_BAR do -- 865
					do -- 865
						if localRng:next() > density then -- 865
							goto __continue173 -- 866
						end -- 866
						local step = barStart + localStep -- 867
						local choice = chordToneChoices[math.floor(localRng:next() * #chordToneChoices) + 1] -- 868
						if options.melodyComplexity > 0.65 and localRng:next() < options.melodyComplexity * 0.35 then -- 868
							choice = choice + 1 -- 869
						end -- 869
						local note = musicScaleNote(rootNote + 12, scale, chordDegree + choice) -- 870
						if localRng:next() < options.melodyComplexity * 0.3 then -- 870
							note = note + 12 -- 871
						end -- 871
						if options.variation > 0 and sectionLabel ~= "A" and localRng:next() < options.variation * 0.5 then -- 871
							note = note + scale[2] -- 872
						end -- 872
						fillMusicNote( -- 873
							melodyNotes, -- 873
							melodyAges, -- 873
							step, -- 873
							melodySpan, -- 873
							note -- 873
						) -- 873
					end -- 873
					::__continue173:: -- 873
					localStep = localStep + melodySpan -- 865
				end -- 865
			end -- 865
			bar = bar + 1 -- 841
		end -- 841
	end -- 841
	return { -- 876
		melodyNotes = melodyNotes, -- 876
		melodyAges = melodyAges, -- 876
		bassNotes = bassNotes, -- 876
		bassAges = bassAges, -- 876
		arpNotes = arpNotes, -- 876
		chordRoots = chordRoots -- 876
	} -- 876
end -- 823
local function musicFrequency(note) -- 879
	return 440 * 2 ^ ((note - 69) / 12) -- 880
end -- 879
local function musicWave(phase, instrument) -- 883
	if instrument == "square" then -- 883
		return phase < 0.5 and 0.7 or -0.7 -- 884
	end -- 884
	if instrument == "pulse" then -- 884
		return phase < 0.25 and 0.75 or -0.45 -- 885
	end -- 885
	if instrument == "saw" then -- 885
		return 1 - phase * 2 -- 886
	end -- 886
	if instrument == "triangle" or instrument == "pluck" then -- 886
		return phase < 0.5 and phase * 4 - 1 or 3 - phase * 4 -- 887
	end -- 887
	if instrument == "organ" then -- 887
		return math.sin(phase * 2 * math.pi) * 0.72 + math.sin(phase * 6 * math.pi) * 0.28 -- 888
	end -- 888
	if instrument == "bell" then -- 888
		return math.sin(phase * 2 * math.pi) * 0.68 + math.sin(phase * 8 * math.pi) * 0.32 -- 889
	end -- 889
	if instrument == "fm" then -- 889
		return math.sin(phase * 2 * math.pi + math.sin(phase * 6 * math.pi) * 2.2) -- 890
	end -- 890
	if instrument == "pad" then -- 890
		return math.sin(phase * 2 * math.pi) * 0.65 + (phase < 0.5 and phase * 4 - 1 or 3 - phase * 4) * 0.35 -- 891
	end -- 891
	if instrument == "sub" then -- 891
		return math.sin(phase * 2 * math.pi) * 0.85 + math.sin(phase * 4 * math.pi) * 0.15 -- 892
	end -- 892
	if instrument == "guitar" then -- 892
		return (phase < 0.5 and phase * 4 - 1 or 3 - phase * 4) * 0.72 + math.sin(phase * 6 * math.pi) * 0.28 -- 893
	end -- 893
	if instrument == "strings" then -- 893
		return (1 - phase * 2) * 0.55 + math.sin(phase * 2 * math.pi) * 0.45 -- 894
	end -- 894
	return math.sin(phase * 2 * math.pi) -- 895
end -- 883
local function musicEnvelope(time, length, attack, release, instrument) -- 898
	if time < 0 or time >= length then -- 898
		return 0 -- 899
	end -- 899
	local value = 1 -- 900
	if time < attack then -- 900
		value = time / attack -- 901
	end -- 901
	local remaining = length - time -- 902
	if remaining < release then -- 902
		value = value * (remaining / release) -- 903
	end -- 903
	if instrument == "pluck" or instrument == "bell" or instrument == "guitar" then -- 903
		value = value * (1 / (1 + time * (instrument == "bell" and 3.5 or 8))) -- 904
	end -- 904
	return clamp01(value) -- 905
end -- 898
local function createStereoSamples(stereo) -- 908
	return stereo and ({left = {}, right = {}}) or ({left = {}}) -- 909
end -- 908
local function pushStereo(samples, left, right) -- 912
	if samples.right then -- 912
		local ____samples_left_8 = samples.left -- 912
		____samples_left_8[#____samples_left_8 + 1] = left -- 914
		local ____samples_right_9 = samples.right -- 914
		____samples_right_9[#____samples_right_9 + 1] = right -- 915
	else -- 915
		local ____samples_left_10 = samples.left -- 915
		____samples_left_10[#____samples_left_10 + 1] = (left + right) * 0.5 -- 917
	end -- 917
end -- 912
local function yieldMusicFrame() -- 921
	return __TS__New( -- 922
		__TS__Promise, -- 922
		function(____, resolve) -- 922
			Director.systemScheduler:schedule(once(function() return resolve(nil) end)) -- 923
		end -- 922
	) -- 922
end -- 921
local function synthMusic(options, arrangement, bars, renderKind, captureStems, onProgress, isCancelled) -- 927
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 927
		local stepSeconds = 60 / options.bpm / 4 -- 936
		local durationSeconds = bars * MUSIC_STEPS_PER_BAR * stepSeconds -- 937
		local totalSamples = math.floor(durationSeconds * MUSIC_SAMPLE_RATE) -- 938
		local mix = createStereoSamples(options.stereo) -- 939
		local stems = captureStems and ({ -- 940
			melody = createStereoSamples(options.stereo), -- 941
			bass = createStereoSamples(options.stereo), -- 941
			harmony = createStereoSamples(options.stereo), -- 942
			drums = createStereoSamples(options.stereo) -- 942
		}) or nil -- 942
		local noiseRng = createSfxRng(options.seed + bars * 65537 + (renderKind == "loop" and 1 or 17)) -- 944
		local noise = {} -- 945
		do -- 945
			local i = 0 -- 946
			while i < MUSIC_NOISE_SIZE do -- 946
				noise[#noise + 1] = noiseRng:next() * 2 - 1 -- 946
				i = i + 1 -- 946
			end -- 946
		end -- 946
		local melodyPhase = 0 -- 947
		local bassPhase = 0 -- 947
		local arpPhase = 0 -- 947
		local padPhase = 0 -- 947
		local filteredLeft = 0 -- 948
		local filteredRight = 0 -- 948
		local peak = 0 -- 949
		local clippingSamples = 0 -- 949
		local fadeSamples = math.max( -- 950
			1, -- 950
			math.floor(MUSIC_SAMPLE_RATE * 0.008) -- 950
		) -- 950
		local delayFrames = math.max( -- 951
			1, -- 951
			math.floor(MUSIC_SAMPLE_RATE * 60 / options.bpm * 0.5) -- 951
		) -- 951
		local reverbFrames = math.max( -- 952
			1, -- 952
			math.floor(MUSIC_SAMPLE_RATE * 0.073) -- 952
		) -- 952
		local delayLeft = {} -- 953
		local delayRight = {} -- 953
		local reverbLeft = {} -- 953
		local reverbRight = {} -- 953
		do -- 953
			local i = 0 -- 954
			while i < delayFrames do -- 954
				delayLeft[#delayLeft + 1] = 0 -- 954
				delayRight[#delayRight + 1] = 0 -- 954
				i = i + 1 -- 954
			end -- 954
		end -- 954
		do -- 954
			local i = 0 -- 955
			while i < reverbFrames do -- 955
				reverbLeft[#reverbLeft + 1] = 0 -- 955
				reverbRight[#reverbRight + 1] = 0 -- 955
				i = i + 1 -- 955
			end -- 955
		end -- 955
		do -- 955
			local sampleIndex = 0 -- 956
			while sampleIndex < totalSamples do -- 956
				if sampleIndex % MUSIC_RENDER_CHUNK == 0 then -- 956
					if (isCancelled and isCancelled()) == true then -- 956
						return ____awaiter_resolve(nil, nil) -- 956
					end -- 956
					if onProgress ~= nil then -- 956
						onProgress(math.floor(sampleIndex / totalSamples * 100)) -- 959
					end -- 959
					if sampleIndex > 0 then -- 959
						__TS__Await(yieldMusicFrame()) -- 960
					end -- 960
				end -- 960
				local time = sampleIndex / MUSIC_SAMPLE_RATE -- 962
				local stepFloat = time / stepSeconds -- 963
				local stepIndex = math.min( -- 964
					#arrangement.melodyNotes - 1, -- 964
					math.floor(stepFloat) -- 964
				) -- 964
				local stepTime = (stepFloat - stepIndex) * stepSeconds -- 965
				local melody = 0 -- 966
				local bass = 0 -- 966
				local harmony = 0 -- 966
				local drums = 0 -- 966
				local melodyNote = arrangement.melodyNotes[stepIndex + 1] -- 967
				if melodyNote >= 0 then -- 967
					melodyPhase = (melodyPhase + musicFrequency(melodyNote) / MUSIC_SAMPLE_RATE) % 1 -- 969
					local noteTime = arrangement.melodyAges[stepIndex + 1] * stepSeconds + stepTime -- 970
					local span = options.rhythmComplexity > 0.72 and 1 or getMusicStyleConfig(options.style).melodyStepSpan -- 971
					local noteLength = span * stepSeconds * (0.72 + options.rhythmComplexity * 0.22) -- 972
					local env = musicEnvelope( -- 973
						noteTime, -- 973
						noteLength, -- 973
						0.004, -- 973
						math.min(0.05, noteLength * 0.3), -- 973
						options.leadInstrument -- 973
					) -- 973
					melody = musicWave(melodyPhase, options.leadInstrument) * env * getMusicStyleConfig(options.style).melodyMix -- 974
				end -- 974
				local bassNote = arrangement.bassNotes[stepIndex + 1] -- 976
				if bassNote >= 0 then -- 976
					bassPhase = (bassPhase + musicFrequency(bassNote) / MUSIC_SAMPLE_RATE) % 1 -- 978
					local noteTime = arrangement.bassAges[stepIndex + 1] * stepSeconds + stepTime -- 979
					local env = musicEnvelope( -- 980
						noteTime, -- 980
						stepSeconds * 3.75, -- 980
						0.008, -- 980
						0.08, -- 980
						options.bassInstrument -- 980
					) -- 980
					bass = musicWave(bassPhase, options.bassInstrument) * env * getMusicStyleConfig(options.style).bassMix -- 981
				end -- 981
				local arpNote = arrangement.arpNotes[stepIndex + 1] -- 983
				if arpNote >= 0 then -- 983
					arpPhase = (arpPhase + musicFrequency(arpNote) / MUSIC_SAMPLE_RATE) % 1 -- 985
					local arpEnv = musicEnvelope( -- 986
						stepTime, -- 986
						stepSeconds * 0.72, -- 986
						0.003, -- 986
						math.min(0.035, stepSeconds * 0.25), -- 986
						options.harmonyInstrument -- 986
					) -- 986
					harmony = harmony + musicWave(arpPhase, options.harmonyInstrument) * arpEnv * getMusicStyleConfig(options.style).harmonyMix -- 987
				end -- 987
				local padNote = arrangement.chordRoots[stepIndex + 1] + 12 -- 989
				padPhase = (padPhase + musicFrequency(padNote) / MUSIC_SAMPLE_RATE) % 1 -- 990
				harmony = harmony + musicWave(padPhase, options.harmonyInstrument) * (options.style == "calm" and 0.1 or 0.035) -- 991
				local localStep = stepIndex % MUSIC_STEPS_PER_BAR -- 992
				local noiseSample = noise[sampleIndex % MUSIC_NOISE_SIZE + 1] -- 993
				local previousNoise = noise[(sampleIndex + MUSIC_NOISE_SIZE - 1) % MUSIC_NOISE_SIZE + 1] -- 994
				local drumConfig = getMusicStyleConfig(options.style) -- 995
				local ____temp_15 -- 996
				if options.intensity > 0.78 then -- 996
					____temp_15 = localStep % 4 == 0 -- 996
				else -- 996
					____temp_15 = localStep == 0 or localStep == 8 -- 996
				end -- 996
				local kickOn = ____temp_15 -- 996
				local kickDecay = 0 -- 997
				if kickOn then -- 997
					local kickLength = math.min(stepSeconds, 0.16) -- 999
					if stepTime < kickLength then -- 999
						kickDecay = 1 - stepTime / kickLength -- 1001
						drums = drums + math.sin(2 * math.pi * (58 + 82 * kickDecay) * stepTime) * kickDecay * kickDecay * drumConfig.drumMix -- 1002
					end -- 1002
				end -- 1002
				if localStep == 4 or localStep == 12 then -- 1002
					local snareLength = math.min(stepSeconds, 0.13) -- 1006
					if stepTime < snareLength then -- 1006
						local decay = 1 - stepTime / snareLength -- 1008
						drums = drums + (noiseSample * 0.78 + math.sin(2 * math.pi * 180 * stepTime) * 0.22) * decay * drumConfig.drumMix * 0.68 -- 1009
						if options.intensity > 0.62 then -- 1009
							local clapPhase = stepTime * 38 % 1 -- 1011
							drums = drums + noiseSample * (clapPhase < 0.22 and 1 or 0) * decay * drumConfig.drumMix * 0.24 -- 1012
						end -- 1012
					end -- 1012
				end -- 1012
				local hatStride = options.rhythmComplexity > 0.7 and 1 or drumConfig.hatStride -- 1016
				if localStep % hatStride == 0 then -- 1016
					local hatLength = math.min(stepSeconds, 0.045) -- 1018
					if stepTime < hatLength then -- 1018
						drums = drums + (noiseSample - previousNoise) * (1 - stepTime / hatLength) * drumConfig.drumMix * 0.18 -- 1019
					end -- 1019
				end -- 1019
				if localStep == 14 and options.intensity > 0.48 then -- 1019
					local openHatLength = math.min(stepSeconds, 0.12) -- 1022
					if stepTime < openHatLength then -- 1022
						drums = drums + (noiseSample - previousNoise) * (1 - stepTime / openHatLength) * drumConfig.drumMix * 0.15 -- 1023
					end -- 1023
				end -- 1023
				if localStep % 4 == 2 and options.intensity > 0.82 then -- 1023
					local rideLength = math.min(stepSeconds, 0.08) -- 1026
					if stepTime < rideLength then -- 1026
						drums = drums + math.sin(2 * math.pi * 1800 * stepTime) * (1 - stepTime / rideLength) * drumConfig.drumMix * 0.09 -- 1027
					end -- 1027
				end -- 1027
				if localStep >= 13 and options.rhythmComplexity > 0.68 then -- 1027
					local tomLength = math.min(stepSeconds, 0.1) -- 1030
					if stepTime < tomLength then -- 1030
						local tomDecay = 1 - stepTime / tomLength -- 1032
						local tomFrequency = 150 - (localStep - 13) * 24 -- 1033
						drums = drums + math.sin(2 * math.pi * tomFrequency * stepTime) * tomDecay * drumConfig.drumMix * 0.26 -- 1034
					end -- 1034
				end -- 1034
				local sectionStep = stepIndex % (options.barsPerSection * MUSIC_STEPS_PER_BAR) -- 1037
				local sectionTime = sectionStep * stepSeconds + stepTime -- 1038
				if sectionTime < 0.32 and options.intensity > 0.72 then -- 1038
					drums = drums + (noiseSample - previousNoise * 0.5) * (1 - sectionTime / 0.32) * drumConfig.drumMix * 0.16 -- 1040
				end -- 1040
				local duck = 1 - kickDecay * options.intensity * 0.24 -- 1042
				melody = melody * (duck * (0.72 + options.intensity * 0.42)) -- 1043
				bass = bass * (0.65 + options.intensity * 0.55) -- 1044
				harmony = harmony * (duck * (0.5 + options.intensity * 0.62)) -- 1045
				drums = drums * (0.32 + options.intensity * 0.85) -- 1046
				local chorusPan = math.sin(time * 2 * math.pi * 0.35) * options.chorus * 0.18 -- 1047
				local melodyLeft = melody * (0.82 - chorusPan) -- 1048
				local melodyRight = melody * (1.18 + chorusPan) -- 1048
				local bassLeft = bass -- 1049
				local bassRight = bass -- 1049
				local harmonyLeft = harmony * (1.18 + chorusPan) -- 1050
				local harmonyRight = harmony * (0.82 - chorusPan) -- 1050
				local drumsLeft = drums * 1.02 -- 1051
				local drumsRight = drums * 0.98 -- 1051
				local left = melodyLeft + bassLeft + harmonyLeft + drumsLeft -- 1052
				local right = melodyRight + bassRight + harmonyRight + drumsRight -- 1053
				local delayPos = sampleIndex % delayFrames -- 1054
				local reverbPos = sampleIndex % reverbFrames -- 1055
				local delayedL = delayLeft[delayPos + 1] -- 1056
				local delayedR = delayRight[delayPos + 1] -- 1056
				local reverbedL = reverbLeft[reverbPos + 1] -- 1057
				local reverbedR = reverbRight[reverbPos + 1] -- 1057
				delayLeft[delayPos + 1] = left + delayedR * 0.34 -- 1058
				delayRight[delayPos + 1] = right + delayedL * 0.34 -- 1059
				reverbLeft[reverbPos + 1] = left + reverbedR * 0.42 -- 1060
				reverbRight[reverbPos + 1] = right + reverbedL * 0.42 -- 1061
				left = left + (delayedL * options.delay + reverbedL * options.reverb * 0.45) -- 1062
				right = right + (delayedR * options.delay + reverbedR * options.reverb * 0.45) -- 1063
				if options.lowPass > 0 then -- 1063
					local filterRate = 1 - options.lowPass * 0.94 -- 1065
					filteredLeft = filteredLeft + (left - filteredLeft) * filterRate -- 1066
					filteredRight = filteredRight + (right - filteredRight) * filterRate -- 1067
					left = filteredLeft -- 1068
					right = filteredRight -- 1069
				else -- 1069
					filteredLeft = left -- 1071
					filteredRight = right -- 1072
				end -- 1072
				local drive = 1 + options.distortion * 5 -- 1074
				left = left * drive / (1 + math.abs(left) * drive * 0.58) -- 1075
				right = right * drive / (1 + math.abs(right) * drive * 0.58) -- 1076
				if options.bitCrush > 0 then -- 1076
					local bits = math.max( -- 1078
						4, -- 1078
						16 - math.floor(options.bitCrush * 12) -- 1078
					) -- 1078
					local levels = 2 ^ (bits - 1) -- 1079
					left = math.floor(left * levels + 0.5) / levels -- 1080
					right = math.floor(right * levels + 0.5) / levels -- 1081
				end -- 1081
				local edgeFade = 1 -- 1083
				if sampleIndex < fadeSamples then -- 1083
					edgeFade = sampleIndex / fadeSamples -- 1084
				end -- 1084
				if sampleIndex >= totalSamples - fadeSamples then -- 1084
					edgeFade = (totalSamples - 1 - sampleIndex) / fadeSamples -- 1085
				end -- 1085
				left = left * (options.volume * edgeFade * 0.72) -- 1086
				right = right * (options.volume * edgeFade * 0.72) -- 1087
				peak = math.max( -- 1088
					peak, -- 1088
					math.abs(left), -- 1088
					math.abs(right) -- 1088
				) -- 1088
				if math.abs(left) > 1 or math.abs(right) > 1 then -- 1088
					clippingSamples = clippingSamples + 1 -- 1089
				end -- 1089
				left = math.max( -- 1090
					-1, -- 1090
					math.min(1, left) -- 1090
				) -- 1090
				right = math.max( -- 1091
					-1, -- 1091
					math.min(1, right) -- 1091
				) -- 1091
				pushStereo(mix, left, right) -- 1092
				if stems then -- 1092
					local stemGain = options.volume * edgeFade * 0.72 -- 1094
					pushStereo(stems.melody, melodyLeft * stemGain, melodyRight * stemGain) -- 1095
					pushStereo(stems.bass, bassLeft * stemGain, bassRight * stemGain) -- 1096
					pushStereo(stems.harmony, harmonyLeft * stemGain, harmonyRight * stemGain) -- 1097
					pushStereo(stems.drums, drumsLeft * stemGain, drumsRight * stemGain) -- 1098
				end -- 1098
				sampleIndex = sampleIndex + 1 -- 956
			end -- 956
		end -- 956
		if onProgress ~= nil then -- 956
			onProgress(100) -- 1101
		end -- 1101
		return ____awaiter_resolve(nil, {mix = mix, peak = peak, clippingSamples = clippingSamples, stems = stems}) -- 1101
	end) -- 1101
end -- 927
local function encodeMusicMidi(arrangement, options) -- 1105
	local events = {} -- 1107
	local stepTicks = 120 -- 1108
	local function addNote(tick, duration, channel, note, velocity) -- 1109
		events[#events + 1] = { -- 1110
			tick = tick, -- 1110
			order = 1, -- 1110
			data = string.char(144 + channel, note, velocity) -- 1110
		} -- 1110
		events[#events + 1] = { -- 1111
			tick = tick + duration, -- 1111
			order = 0, -- 1111
			data = string.char(128 + channel, note, 0) -- 1111
		} -- 1111
	end -- 1109
	local function addSustainedVoice(notes, ages, channel, velocity) -- 1113
		do -- 1113
			local step = 0 -- 1114
			while step < #notes do -- 1114
				do -- 1114
					if notes[step + 1] < 0 or ages[step + 1] ~= 0 then -- 1114
						goto __continue243 -- 1115
					end -- 1115
					local span = 1 -- 1116
					while step + span < #notes and notes[step + span + 1] == notes[step + 1] and ages[step + span + 1] == span do -- 1116
						span = span + 1 -- 1117
					end -- 1117
					addNote( -- 1118
						step * stepTicks, -- 1118
						span * stepTicks, -- 1118
						channel, -- 1118
						notes[step + 1], -- 1118
						velocity -- 1118
					) -- 1118
				end -- 1118
				::__continue243:: -- 1118
				step = step + 1 -- 1114
			end -- 1114
		end -- 1114
	end -- 1113
	addSustainedVoice(arrangement.melodyNotes, arrangement.melodyAges, 0, 92) -- 1121
	addSustainedVoice(arrangement.bassNotes, arrangement.bassAges, 1, 84) -- 1122
	do -- 1122
		local step = 0 -- 1123
		while step < #arrangement.arpNotes do -- 1123
			if arrangement.arpNotes[step + 1] >= 0 then -- 1123
				addNote( -- 1124
					step * stepTicks, -- 1124
					math.floor(stepTicks * 0.72), -- 1124
					2, -- 1124
					arrangement.arpNotes[step + 1], -- 1124
					66 -- 1124
				) -- 1124
			end -- 1124
			local localStep = step % MUSIC_STEPS_PER_BAR -- 1125
			if localStep == 0 or localStep == 8 then -- 1125
				addNote( -- 1126
					step * stepTicks, -- 1126
					60, -- 1126
					9, -- 1126
					36, -- 1126
					100 -- 1126
				) -- 1126
			end -- 1126
			if localStep == 4 or localStep == 12 then -- 1126
				addNote( -- 1128
					step * stepTicks, -- 1128
					60, -- 1128
					9, -- 1128
					38, -- 1128
					86 -- 1128
				) -- 1128
				if options.intensity > 0.62 then -- 1128
					addNote( -- 1129
						step * stepTicks, -- 1129
						45, -- 1129
						9, -- 1129
						39, -- 1129
						62 -- 1129
					) -- 1129
				end -- 1129
			end -- 1129
			if localStep % 2 == 0 then -- 1129
				addNote( -- 1131
					step * stepTicks, -- 1131
					30, -- 1131
					9, -- 1131
					42, -- 1131
					54 -- 1131
				) -- 1131
			end -- 1131
			if localStep == 14 and options.intensity > 0.48 then -- 1131
				addNote( -- 1132
					step * stepTicks, -- 1132
					90, -- 1132
					9, -- 1132
					46, -- 1132
					60 -- 1132
				) -- 1132
			end -- 1132
			if localStep % 4 == 2 and options.intensity > 0.82 then -- 1132
				addNote( -- 1133
					step * stepTicks, -- 1133
					60, -- 1133
					9, -- 1133
					51, -- 1133
					48 -- 1133
				) -- 1133
			end -- 1133
			if localStep >= 13 and options.rhythmComplexity > 0.68 then -- 1133
				addNote( -- 1134
					step * stepTicks, -- 1134
					70, -- 1134
					9, -- 1134
					45 - (localStep - 13) * 2, -- 1134
					70 -- 1134
				) -- 1134
			end -- 1134
			if step % (options.barsPerSection * MUSIC_STEPS_PER_BAR) == 0 and options.intensity > 0.72 then -- 1134
				addNote( -- 1135
					step * stepTicks, -- 1135
					120, -- 1135
					9, -- 1135
					49, -- 1135
					72 -- 1135
				) -- 1135
			end -- 1135
			step = step + 1 -- 1123
		end -- 1123
	end -- 1123
	__TS__ArraySort( -- 1137
		events, -- 1137
		function(____, a, b) return a.tick == b.tick and a.order - b.order or a.tick - b.tick end -- 1137
	) -- 1137
	local function variableLength(value) -- 1138
		local bytes = {value % 128} -- 1139
		local rest = math.floor(value / 128) -- 1140
		while rest > 0 do -- 1140
			bytes[#bytes + 1] = rest % 128 + 128 -- 1142
			rest = math.floor(rest / 128) -- 1143
		end -- 1143
		local result = "" -- 1145
		do -- 1145
			local i = #bytes - 1 -- 1146
			while i >= 0 do -- 1146
				result = result .. string.char(bytes[i + 1]) -- 1146
				i = i - 1 -- 1146
			end -- 1146
		end -- 1146
		return result -- 1147
	end -- 1138
	local tempo = math.floor(60000000 / options.bpm) -- 1149
	local parts = {string.char( -- 1150
		0, -- 1150
		255, -- 1150
		81, -- 1150
		3, -- 1150
		math.floor(tempo / 65536) % 256, -- 1150
		math.floor(tempo / 256) % 256, -- 1150
		tempo % 256 -- 1150
	)} -- 1150
	parts[#parts + 1] = string.char( -- 1151
		0, -- 1151
		255, -- 1151
		88, -- 1151
		4, -- 1151
		4, -- 1151
		2, -- 1151
		24, -- 1151
		8 -- 1151
	) -- 1151
	local lastTick = 0 -- 1152
	do -- 1152
		local i = 0 -- 1153
		while i < #events do -- 1153
			parts[#parts + 1] = variableLength(events[i + 1].tick - lastTick) .. events[i + 1].data -- 1154
			lastTick = events[i + 1].tick -- 1155
			i = i + 1 -- 1153
		end -- 1153
	end -- 1153
	parts[#parts + 1] = string.char(0, 255, 47, 0) -- 1157
	local track = table.concat(parts, "") -- 1158
	return (string.pack( -- 1159
		">c4I4I2I2I2", -- 1159
		"MThd", -- 1159
		6, -- 1159
		0, -- 1159
		1, -- 1159
		480 -- 1159
	) .. string.pack(">c4I4", "MTrk", #track)) .. track -- 1159
end -- 1105
local function musicSiblingPath(path, suffix, extension) -- 1162
	if extension == nil then -- 1162
		extension = ".wav" -- 1162
	end -- 1162
	return (__TS__StringSlice(path, 0, #path - 4) .. suffix) .. extension -- 1163
end -- 1162
local function saveGeneratedAsset(target, data, operationId) -- 1166
	if not ensureDirForFile(target) then -- 1166
		return false -- 1167
	end -- 1167
	local temp = ((target .. ".") .. operationId) .. ".tmp" -- 1168
	local backup = ((target .. ".") .. operationId) .. ".bak" -- 1169
	Content:remove(temp) -- 1170
	Content:remove(backup) -- 1171
	if not Content:save(temp, data) then -- 1171
		return false -- 1172
	end -- 1172
	local hadTarget = Content:exist(target) -- 1173
	if hadTarget and not Content:move(target, backup) then -- 1173
		Content:remove(temp) -- 1175
		return false -- 1176
	end -- 1176
	if not Content:move(temp, target) then -- 1176
		Content:remove(temp) -- 1179
		if hadTarget then -- 1179
			Content:move(backup, target) -- 1180
		end -- 1180
		return false -- 1181
	end -- 1181
	Content:remove(backup) -- 1183
	return true -- 1184
end -- 1166
local function musicFingerprint(options) -- 1187
	local raw = table.concat( -- 1188
		{ -- 1188
			options.style, -- 1189
			tostring(options.seed), -- 1189
			tostring(options.bpm), -- 1189
			tostring(options.bars), -- 1189
			tostring(options.volume), -- 1189
			tostring(options.intensity), -- 1190
			options.key, -- 1190
			options.mode, -- 1190
			options.progressionText, -- 1190
			table.concat(options.structure, ","), -- 1190
			tostring(options.barsPerSection), -- 1191
			tostring(options.melodyComplexity), -- 1191
			tostring(options.rhythmComplexity), -- 1191
			tostring(options.variation), -- 1191
			options.leadInstrument, -- 1192
			options.bassInstrument, -- 1192
			options.harmonyInstrument, -- 1192
			tostring(options.stereo), -- 1192
			tostring(options.reverb), -- 1193
			tostring(options.delay), -- 1193
			tostring(options.chorus), -- 1193
			tostring(options.distortion), -- 1193
			tostring(options.bitCrush), -- 1193
			tostring(options.lowPass), -- 1194
			tostring(options.stems), -- 1194
			tostring(options.introBars), -- 1194
			tostring(options.outroBars), -- 1194
			options.stinger, -- 1194
			tostring(options.exportMidi) -- 1194
		}, -- 1194
		"|" -- 1195
	) -- 1195
	local hash = 2166136261 -- 1196
	do -- 1196
		local i = 0 -- 1197
		while i < #raw do -- 1197
			hash = (hash * 16777619 + __TS__StringCharCodeAt(raw, i)) % 2147483647 -- 1197
			i = i + 1 -- 1197
		end -- 1197
	end -- 1197
	return "music-v1-" .. tostring(math.floor(hash)) -- 1198
end -- 1187
local function musicProjectObject(path, options, files, bytesWritten, durationSeconds, peak, clippingSamples, sourceProject) -- 1201
	return { -- 1211
		version = 1, -- 1212
		generator = "Dora.CodingAgent.generate_music", -- 1212
		fingerprint = musicFingerprint(options), -- 1212
		path = path, -- 1213
		files = files, -- 1213
		bytesWritten = bytesWritten, -- 1213
		durationSeconds = durationSeconds, -- 1213
		peak = peak, -- 1213
		clippingSamples = clippingSamples, -- 1213
		sourceProject = sourceProject, -- 1213
		params = { -- 1214
			style = options.style, -- 1215
			seed = options.seed, -- 1215
			duration = options.duration, -- 1215
			bpm = options.bpm, -- 1215
			volume = options.volume, -- 1215
			intensity = options.intensity, -- 1216
			key = options.key, -- 1216
			mode = options.mode, -- 1216
			progression = options.progressionText, -- 1216
			structure = table.concat(options.structure, ","), -- 1217
			barsPerSection = options.barsPerSection, -- 1217
			melodyComplexity = options.melodyComplexity, -- 1218
			rhythmComplexity = options.rhythmComplexity, -- 1218
			variation = options.variation, -- 1218
			leadInstrument = options.leadInstrument, -- 1219
			bassInstrument = options.bassInstrument, -- 1219
			harmonyInstrument = options.harmonyInstrument, -- 1219
			stereo = options.stereo, -- 1220
			reverb = options.reverb, -- 1220
			delay = options.delay, -- 1220
			chorus = options.chorus, -- 1220
			distortion = options.distortion, -- 1221
			bitCrush = options.bitCrush, -- 1221
			lowPass = options.lowPass, -- 1221
			stems = options.stems, -- 1221
			introBars = options.introBars, -- 1222
			outroBars = options.outroBars, -- 1222
			stinger = options.stinger, -- 1222
			exportMidi = options.exportMidi -- 1222
		} -- 1222
	} -- 1222
end -- 1201
local function readCachedMusicResult(workDir, path, options) -- 1227
	local projectPath = musicSiblingPath(path, "", ".music.json") -- 1228
	local target = resolveWorkspaceFilePath(workDir, path) -- 1229
	local projectFull = resolveWorkspaceFilePath(workDir, projectPath) -- 1230
	if not target or not projectFull or not Content:exist(target) or not Content:exist(projectFull) then -- 1230
		return nil -- 1231
	end -- 1231
	local projectText = Content:load(projectFull) -- 1232
	if type(projectText) ~= "string" then -- 1232
		return nil -- 1233
	end -- 1233
	local decoded = safeJsonDecode(projectText) -- 1234
	if not decoded or type(decoded) ~= "table" then -- 1234
		return nil -- 1235
	end -- 1235
	local record = decoded -- 1236
	if record.fingerprint ~= musicFingerprint(options) or not __TS__ArrayIsArray(record.files) then -- 1236
		return nil -- 1237
	end -- 1237
	local files = {} -- 1238
	do -- 1238
		local i = 0 -- 1239
		while i < #record.files do -- 1239
			if type(record.files[i + 1]) ~= "string" then -- 1239
				return nil -- 1240
			end -- 1240
			local relative = record.files[i + 1] -- 1241
			local full = resolveWorkspaceFilePath(workDir, relative) -- 1242
			if not full or not Content:exist(full) then -- 1242
				return nil -- 1243
			end -- 1243
			files[#files + 1] = relative -- 1244
			i = i + 1 -- 1239
		end -- 1239
	end -- 1239
	if __TS__ArrayIndexOf(files, projectPath) < 0 then -- 1239
		files[#files + 1] = projectPath -- 1246
	end -- 1246
	local durationSeconds = type(record.durationSeconds) == "number" and record.durationSeconds or options.duration -- 1247
	local bytesWritten = type(record.bytesWritten) == "number" and record.bytesWritten or 0 -- 1248
	local midiPath = options.exportMidi and musicSiblingPath(path, "", ".mid") or nil -- 1249
	return { -- 1250
		success = true, -- 1251
		path = path, -- 1251
		files = files, -- 1251
		projectPath = projectPath, -- 1251
		midiPath = midiPath, -- 1251
		bytesWritten = bytesWritten, -- 1251
		durationSeconds = durationSeconds, -- 1251
		sampleRate = MUSIC_SAMPLE_RATE, -- 1252
		channels = options.stereo and 2 or 1, -- 1252
		seed = options.seed, -- 1252
		style = options.style, -- 1253
		bpm = options.bpm, -- 1253
		bars = options.bars, -- 1253
		key = options.key, -- 1253
		mode = options.mode, -- 1253
		description = ((("Reused cached deterministic music assets for " .. path) .. " (") .. musicFingerprint(options)) .. ")." -- 1254
	} -- 1254
end -- 1227
local musicAutoSeedStep = 0 -- 1258
function ____exports.generateMusic(req) -- 1260
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1260
		local relPath = __TS__StringTrim(req.path or "") -- 1269
		if relPath == "" then -- 1269
			return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 1269
		end -- 1269
		if not __TS__StringEndsWith( -- 1269
			string.lower(relPath), -- 1271
			".wav" -- 1271
		) then -- 1271
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "generate_music writes WAV files; path must end in .wav"}) -- 1271
		end -- 1271
		local requestedStyle = string.lower(__TS__StringTrim(req.style or "")) -- 1272
		local validStyles = { -- 1273
			"chiptune", -- 1273
			"adventure", -- 1273
			"calm", -- 1273
			"tense", -- 1273
			"victory", -- 1273
			"random" -- 1273
		} -- 1273
		if __TS__ArrayIndexOf(validStyles, requestedStyle) < 0 then -- 1273
			return ____awaiter_resolve( -- 1273
				nil, -- 1273
				{ -- 1274
					success = false, -- 1274
					path = relPath, -- 1274
					message = (("unknown style '" .. req.style) .. "'; expected one of: ") .. table.concat(validStyles, ", ") -- 1274
				} -- 1274
			) -- 1274
		end -- 1274
		local target = resolveWorkspaceFilePath(req.workDir, relPath) -- 1275
		if not target then -- 1275
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "invalid path"}) -- 1275
		end -- 1275
		if Content:exist(target) and Content:isdir(target) then -- 1275
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "target path is a directory"}) -- 1275
		end -- 1275
		local ____this_19 -- 1275
		____this_19 = req -- 1278
		local ____opt_18 = ____this_19.isCancelled -- 1278
		if (____opt_18 and ____opt_18(____this_19)) == true then -- 1278
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "canceled", interrupted = true}) -- 1278
		end -- 1278
		musicAutoSeedStep = musicAutoSeedStep + 1 -- 1279
		local seed = type(req.seed) == "number" and req.seed == req.seed and math.abs(req.seed) < 2147483647 and math.floor(req.seed) or os.time() % 1000000000 + musicAutoSeedStep * 104729 -- 1280
		local styleRng = createSfxRng(seed) -- 1282
		local style = requestedStyle -- 1283
		if style == "random" then -- 1283
			local styles = { -- 1285
				"chiptune", -- 1285
				"adventure", -- 1285
				"calm", -- 1285
				"tense", -- 1285
				"victory" -- 1285
			} -- 1285
			style = styles[math.floor(styleRng:next() * #styles) + 1] -- 1286
		end -- 1286
		local styleConfig = getMusicStyleConfig(style) -- 1288
		local bpm = type(req.bpm) == "number" and req.bpm == req.bpm and math.floor(math.min( -- 1289
			200, -- 1289
			math.max(60, req.bpm) -- 1289
		)) or styleConfig.bpm -- 1289
		local requestedDuration = type(req.duration) == "number" and req.duration == req.duration and req.duration or 16 -- 1290
		requestedDuration = math.min( -- 1291
			MUSIC_MAX_SECONDS, -- 1291
			math.max(MUSIC_MIN_SECONDS, requestedDuration) -- 1291
		) -- 1291
		local barSeconds = 240 / bpm -- 1292
		local minBars = math.max( -- 1293
			1, -- 1293
			math.ceil(MUSIC_MIN_SECONDS / barSeconds) -- 1293
		) -- 1293
		local maxBars = math.max( -- 1294
			minBars, -- 1294
			math.floor(MUSIC_MAX_SECONDS / barSeconds) -- 1294
		) -- 1294
		local bars = math.min( -- 1295
			maxBars, -- 1295
			math.max( -- 1295
				minBars, -- 1295
				math.floor(requestedDuration / barSeconds + 0.5) -- 1295
			) -- 1295
		) -- 1295
		local duration = bars * barSeconds -- 1296
		local requestedKey = string.upper(__TS__StringTrim(req.key or "random")) -- 1297
		local rootPitchClass = __TS__ArrayIndexOf(MUSIC_KEY_NAMES, requestedKey) -- 1298
		if rootPitchClass < 0 then -- 1298
			rootPitchClass = math.floor(styleRng:next() * #MUSIC_KEY_NAMES) -- 1299
		end -- 1299
		local requestedMode = string.lower(__TS__StringTrim(req.mode or "auto")) -- 1300
		local mode = __TS__ArrayIndexOf(MUSIC_VALID_MODES, requestedMode) >= 0 and requestedMode or styleConfig.mode -- 1301
		local parsedProgression = parseMusicProgression(req.progression, styleConfig.progression) -- 1302
		local options = { -- 1303
			style = style, -- 1304
			seed = seed, -- 1304
			bpm = bpm, -- 1304
			bars = bars, -- 1304
			duration = duration, -- 1304
			volume = type(req.volume) == "number" and req.volume == req.volume and clamp01(req.volume) or 0.65, -- 1305
			intensity = type(req.intensity) == "number" and req.intensity == req.intensity and clamp01(req.intensity) or 0.6, -- 1306
			rootPitchClass = rootPitchClass, -- 1307
			key = MUSIC_KEY_NAMES[rootPitchClass + 1], -- 1307
			mode = mode, -- 1307
			progression = parsedProgression.degrees, -- 1308
			progressionText = parsedProgression.text, -- 1308
			structure = parseMusicStructure(req.structure), -- 1309
			barsPerSection = type(req.barsPerSection) == "number" and math.floor(math.min( -- 1310
				8, -- 1310
				math.max(1, req.barsPerSection) -- 1310
			)) or 2, -- 1310
			melodyComplexity = type(req.melodyComplexity) == "number" and clamp01(req.melodyComplexity) or 0.55, -- 1311
			rhythmComplexity = type(req.rhythmComplexity) == "number" and clamp01(req.rhythmComplexity) or 0.45, -- 1312
			variation = type(req.variation) == "number" and clamp01(req.variation) or 0.25, -- 1313
			leadInstrument = resolveMusicInstrument(req.leadInstrument, styleConfig.leadInstrument), -- 1314
			bassInstrument = resolveMusicInstrument(req.bassInstrument, styleConfig.bassInstrument), -- 1315
			harmonyInstrument = resolveMusicInstrument(req.harmonyInstrument, styleConfig.harmonyInstrument), -- 1316
			stereo = req.stereo ~= false, -- 1317
			reverb = type(req.reverb) == "number" and clamp01(req.reverb) or styleConfig.reverb, -- 1318
			delay = type(req.delay) == "number" and clamp01(req.delay) or styleConfig.delay, -- 1319
			chorus = type(req.chorus) == "number" and clamp01(req.chorus) or styleConfig.chorus, -- 1320
			distortion = type(req.distortion) == "number" and clamp01(req.distortion) or styleConfig.distortion, -- 1321
			bitCrush = type(req.bitCrush) == "number" and clamp01(req.bitCrush) or 0, -- 1322
			lowPass = type(req.lowPass) == "number" and clamp01(req.lowPass) or 0, -- 1323
			stems = req.stems == true, -- 1324
			introBars = type(req.introBars) == "number" and math.floor(math.min( -- 1325
				8, -- 1325
				math.max(0, req.introBars) -- 1325
			)) or 0, -- 1325
			outroBars = type(req.outroBars) == "number" and math.floor(math.min( -- 1326
				8, -- 1326
				math.max(0, req.outroBars) -- 1326
			)) or 0, -- 1326
			stinger = __TS__ArrayIndexOf( -- 1327
				{"victory", "failure", "both"}, -- 1327
				string.lower(req.stinger or "none") -- 1327
			) >= 0 and string.lower(req.stinger or "none") or "none", -- 1327
			exportMidi = req.exportMidi == true -- 1328
		} -- 1328
		local cached = readCachedMusicResult(req.workDir, relPath, options) -- 1330
		if cached then -- 1330
			local ____this_21 -- 1330
			____this_21 = req -- 1332
			local ____opt_20 = ____this_21.onProgress -- 1332
			if ____opt_20 ~= nil then -- 1332
				____opt_20(____this_21, { -- 1332
					state = "running", -- 1332
					operationId = "cache", -- 1332
					path = relPath, -- 1332
					stage = "cache", -- 1332
					percent = 100, -- 1332
					message = "reusing matching deterministic music assets" -- 1332
				}) -- 1332
			end -- 1332
			return ____awaiter_resolve(nil, cached) -- 1332
		end -- 1332
		local operationId = createOperationId() -- 1335
		local files = {} -- 1336
		local bytesWritten = 0 -- 1337
		local function saveAudio(relative, render) -- 1338
			local full = resolveWorkspaceFilePath(req.workDir, relative) -- 1339
			if not full then -- 1339
				return false -- 1340
			end -- 1340
			local wav = encodePcmWav(render.mix.left, MUSIC_SAMPLE_RATE, render.mix.right) -- 1341
			if not saveGeneratedAsset(full, wav, operationId) then -- 1341
				return false -- 1342
			end -- 1342
			files[#files + 1] = relative -- 1343
			bytesWritten = bytesWritten + #wav -- 1343
			syncGeneratedFileToWebIDE(full) -- 1343
			return true -- 1344
		end -- 1338
		local ____this_23 -- 1338
		____this_23 = req -- 1346
		local ____opt_22 = ____this_23.onProgress -- 1346
		if ____opt_22 ~= nil then -- 1346
			____opt_22( -- 1346
				____this_23, -- 1346
				{ -- 1346
					state = "running", -- 1346
					operationId = operationId, -- 1346
					path = relPath, -- 1346
					stage = "compose", -- 1346
					percent = 0, -- 1346
					message = ((((((("composing " .. style) .. " in ") .. options.key) .. " ") .. mode) .. " at ") .. tostring(bpm)) .. " BPM" -- 1346
				} -- 1346
			) -- 1346
		end -- 1346
		local arrangement = createMusicArrangement(options, bars) -- 1347
		local render = __TS__Await(synthMusic( -- 1348
			options, -- 1348
			arrangement, -- 1348
			bars, -- 1348
			"loop", -- 1348
			options.stems, -- 1348
			function(percent) -- 1348
				local ____this_25 -- 1348
				____this_25 = req -- 1348
				local ____opt_24 = ____this_25.onProgress -- 1348
				return ____opt_24 and ____opt_24( -- 1348
					____this_25, -- 1348
					{ -- 1348
						state = "running", -- 1349
						operationId = operationId, -- 1349
						path = relPath, -- 1349
						stage = "synth", -- 1349
						percent = percent, -- 1349
						message = ("synthesizing loop (" .. tostring(percent)) .. "%)" -- 1349
					} -- 1349
				) -- 1349
			end, -- 1348
			req.isCancelled -- 1350
		)) -- 1350
		if not render then -- 1350
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "canceled", interrupted = true}) -- 1350
		end -- 1350
		local ____this_27 -- 1350
		____this_27 = req -- 1352
		local ____opt_26 = ____this_27.onProgress -- 1352
		if ____opt_26 ~= nil then -- 1352
			____opt_26(____this_27, { -- 1352
				state = "running", -- 1352
				operationId = operationId, -- 1352
				path = relPath, -- 1352
				stage = "write", -- 1352
				percent = 100, -- 1352
				message = "writing music assets" -- 1352
			}) -- 1352
		end -- 1352
		if not saveAudio(relPath, render) then -- 1352
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "failed to write music WAV"}) -- 1352
		end -- 1352
		if render.stems then -- 1352
			local stemNames = {"melody", "bass", "harmony", "drums"} -- 1355
			do -- 1355
				local i = 0 -- 1356
				while i < #stemNames do -- 1356
					local name = stemNames[i + 1] -- 1357
					local relative = musicSiblingPath(relPath, "_" .. name) -- 1358
					local full = resolveWorkspaceFilePath(req.workDir, relative) -- 1359
					if not full then -- 1359
						return ____awaiter_resolve(nil, {success = false, path = relPath, message = "invalid stem path: " .. relative}) -- 1359
					end -- 1359
					local wav = encodePcmWav(render.stems[name].left, MUSIC_SAMPLE_RATE, render.stems[name].right) -- 1361
					if not saveGeneratedAsset(full, wav, operationId) then -- 1361
						return ____awaiter_resolve(nil, {success = false, path = relPath, message = ("failed to write " .. name) .. " stem"}) -- 1361
					end -- 1361
					files[#files + 1] = relative -- 1363
					bytesWritten = bytesWritten + #wav -- 1363
					syncGeneratedFileToWebIDE(full) -- 1363
					__TS__Await(yieldMusicFrame()) -- 1364
					i = i + 1 -- 1356
				end -- 1356
			end -- 1356
		end -- 1356
		local segmentSpecs = {} -- 1367
		if options.introBars > 0 then -- 1367
			segmentSpecs[#segmentSpecs + 1] = {suffix = "_intro", bars = options.introBars, kind = "intro", seedOffset = 3001} -- 1368
		end -- 1368
		if options.outroBars > 0 then -- 1368
			segmentSpecs[#segmentSpecs + 1] = {suffix = "_outro", bars = options.outroBars, kind = "outro", seedOffset = 6007} -- 1369
		end -- 1369
		if options.stinger == "victory" or options.stinger == "both" then -- 1369
			segmentSpecs[#segmentSpecs + 1] = { -- 1370
				suffix = "_victory", -- 1370
				bars = 1, -- 1370
				kind = "stinger", -- 1370
				style = "victory", -- 1370
				seedOffset = 9001 -- 1370
			} -- 1370
		end -- 1370
		if options.stinger == "failure" or options.stinger == "both" then -- 1370
			segmentSpecs[#segmentSpecs + 1] = { -- 1371
				suffix = "_failure", -- 1371
				bars = 1, -- 1371
				kind = "stinger", -- 1371
				style = "tense", -- 1371
				seedOffset = 12007 -- 1371
			} -- 1371
		end -- 1371
		do -- 1371
			local i = 0 -- 1372
			while i < #segmentSpecs do -- 1372
				local spec = segmentSpecs[i + 1] -- 1373
				local segmentStyle = spec.style or options.style -- 1374
				local segmentConfig = getMusicStyleConfig(segmentStyle) -- 1375
				local segmentOptions = __TS__ObjectAssign({}, options, { -- 1376
					style = segmentStyle, -- 1378
					seed = options.seed + spec.seedOffset, -- 1379
					mode = spec.style and segmentConfig.mode or options.mode, -- 1380
					progression = spec.style and segmentConfig.progression or options.progression, -- 1381
					leadInstrument = spec.style and segmentConfig.leadInstrument or options.leadInstrument, -- 1382
					bassInstrument = spec.style and segmentConfig.bassInstrument or options.bassInstrument, -- 1383
					harmonyInstrument = spec.style and segmentConfig.harmonyInstrument or options.harmonyInstrument, -- 1384
					intensity = spec.style and 0.9 or options.intensity, -- 1385
					stems = false -- 1386
				}) -- 1386
				local segmentArrangement = createMusicArrangement(segmentOptions, spec.bars, spec.seedOffset) -- 1388
				local segment = __TS__Await(synthMusic( -- 1389
					segmentOptions, -- 1389
					segmentArrangement, -- 1389
					spec.bars, -- 1389
					spec.kind, -- 1389
					false, -- 1389
					nil, -- 1389
					req.isCancelled -- 1389
				)) -- 1389
				if not segment then -- 1389
					return ____awaiter_resolve(nil, {success = false, path = relPath, message = "canceled", interrupted = true}) -- 1389
				end -- 1389
				if not saveAudio( -- 1389
					musicSiblingPath(relPath, spec.suffix), -- 1391
					segment -- 1391
				) then -- 1391
					return ____awaiter_resolve(nil, {success = false, path = relPath, message = ("failed to write " .. spec.suffix) .. " segment"}) -- 1391
				end -- 1391
				i = i + 1 -- 1372
			end -- 1372
		end -- 1372
		local midiPath -- 1393
		if options.exportMidi then -- 1393
			midiPath = musicSiblingPath(relPath, "", ".mid") -- 1395
			local midiFull = resolveWorkspaceFilePath(req.workDir, midiPath) -- 1396
			local midi = encodeMusicMidi(arrangement, options) -- 1397
			if not midiFull or not saveGeneratedAsset(midiFull, midi, operationId) then -- 1397
				return ____awaiter_resolve(nil, {success = false, path = relPath, message = "failed to write MIDI file"}) -- 1397
			end -- 1397
			files[#files + 1] = midiPath -- 1399
			bytesWritten = bytesWritten + #midi -- 1399
			syncGeneratedFileToWebIDE(midiFull) -- 1399
		end -- 1399
		local actualDuration = math.floor(#render.mix.left / MUSIC_SAMPLE_RATE * 100 + 0.5) / 100 -- 1401
		local projectPath = musicSiblingPath(relPath, "", ".music.json") -- 1402
		local projectFull = resolveWorkspaceFilePath(req.workDir, projectPath) -- 1403
		local projectText = safeJsonEncode( -- 1404
			musicProjectObject( -- 1404
				relPath, -- 1405
				options, -- 1405
				__TS__ArraySlice(files), -- 1405
				bytesWritten, -- 1405
				actualDuration, -- 1405
				render.peak, -- 1405
				render.clippingSamples, -- 1405
				req.sourceProject -- 1405
			), -- 1405
			true, -- 1406
			false -- 1406
		) -- 1406
		if not projectFull or not projectText or not saveGeneratedAsset(projectFull, projectText, operationId) then -- 1406
			return ____awaiter_resolve(nil, {success = false, path = relPath, message = "failed to write music project file"}) -- 1406
		end -- 1406
		files[#files + 1] = projectPath -- 1408
		bytesWritten = bytesWritten + #projectText -- 1408
		syncGeneratedFileToWebIDE(projectFull) -- 1408
		if render.clippingSamples > 0 then -- 1408
			Log( -- 1409
				"Warn", -- 1409
				(("[generate_music] limiter caught " .. tostring(render.clippingSamples)) .. " clipping sample(s), pre-limit peak=") .. tostring(render.peak) -- 1409
			) -- 1409
		end -- 1409
		Log( -- 1410
			"Info", -- 1410
			(((((((((((((("[generate_music] style=" .. style) .. " seed=") .. tostring(seed)) .. " bpm=") .. tostring(bpm)) .. " bars=") .. tostring(bars)) .. " key=") .. options.key) .. " ") .. mode) .. " files=") .. tostring(#files)) .. " bytes=") .. tostring(bytesWritten) -- 1410
		) -- 1410
		return ____awaiter_resolve( -- 1410
			nil, -- 1410
			{ -- 1411
				success = true, -- 1412
				path = relPath, -- 1412
				files = files, -- 1412
				projectPath = projectPath, -- 1412
				midiPath = midiPath, -- 1412
				bytesWritten = bytesWritten, -- 1412
				durationSeconds = actualDuration, -- 1412
				sampleRate = MUSIC_SAMPLE_RATE, -- 1413
				channels = options.stereo and 2 or 1, -- 1413
				seed = seed, -- 1413
				style = style, -- 1413
				bpm = bpm, -- 1413
				bars = bars, -- 1413
				key = options.key, -- 1414
				mode = mode, -- 1414
				description = ((((((((((((((((("Saved " .. tostring(bars)) .. " bars of ") .. style) .. " background music in ") .. options.key) .. " ") .. mode) .. " at ") .. tostring(bpm)) .. " BPM to ") .. relPath) .. ", plus ") .. tostring(#files - 1)) .. " companion asset(s). Stream the loop with Audio.playStream(\"") .. relPath) .. "\", true); use ") .. projectPath) .. " to create compatible variations." -- 1415
			} -- 1415
		) -- 1415
	end) -- 1415
end -- 1260
function ____exports.generateMusicVariation(req) -- 1419
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1419
		local projectRel = __TS__StringTrim(req.project or "") -- 1423
		if not __TS__StringEndsWith( -- 1423
			string.lower(projectRel), -- 1424
			".music.json" -- 1424
		) then -- 1424
			return ____awaiter_resolve(nil, {success = false, path = req.path, message = "project must end in .music.json"}) -- 1424
		end -- 1424
		local projectFull = resolveWorkspaceFilePath(req.workDir, projectRel) -- 1425
		if not projectFull or not Content:exist(projectFull) or Content:isdir(projectFull) then -- 1425
			return ____awaiter_resolve(nil, {success = false, path = req.path, message = "music project file not found"}) -- 1425
		end -- 1425
		local text = Content:load(projectFull) -- 1427
		if type(text) ~= "string" then -- 1427
			return ____awaiter_resolve(nil, {success = false, path = req.path, message = "failed to read music project file"}) -- 1427
		end -- 1427
		local decoded, decodeError = safeJsonDecode(text) -- 1429
		if not decoded or type(decoded) ~= "table" then -- 1429
			return ____awaiter_resolve( -- 1429
				nil, -- 1429
				{ -- 1430
					success = false, -- 1430
					path = req.path, -- 1430
					message = "invalid music project: " .. tostring(decodeError) -- 1430
				} -- 1430
			) -- 1430
		end -- 1430
		local params = decoded.params -- 1431
		if not params or type(params) ~= "table" then -- 1431
			return ____awaiter_resolve(nil, {success = false, path = req.path, message = "music project is missing params"}) -- 1431
		end -- 1431
		local p = params -- 1433
		local function numberValue(name) -- 1434
			return type(p[name]) == "number" and p[name] or nil -- 1434
		end -- 1434
		local function stringValue(name) -- 1435
			return type(p[name]) == "string" and p[name] or nil -- 1435
		end -- 1435
		local function boolValue(name) -- 1436
			local ____temp_28 -- 1436
			if type(p[name]) == "boolean" then -- 1436
				____temp_28 = p[name] -- 1436
			else -- 1436
				____temp_28 = nil -- 1436
			end -- 1436
			return ____temp_28 -- 1436
		end -- 1436
		local oldSeed = numberValue("seed") or 1 -- 1437
		return ____awaiter_resolve( -- 1437
			nil, -- 1437
			____exports.generateMusic({ -- 1438
				workDir = req.workDir, -- 1439
				path = req.path, -- 1439
				style = req.style or stringValue("style") or "chiptune", -- 1439
				seed = req.seed or oldSeed + 7919, -- 1440
				duration = numberValue("duration"), -- 1440
				bpm = numberValue("bpm"), -- 1440
				volume = numberValue("volume"), -- 1440
				intensity = req.intensity or numberValue("intensity"), -- 1441
				key = stringValue("key"), -- 1441
				mode = stringValue("mode"), -- 1441
				progression = stringValue("progression"), -- 1442
				structure = stringValue("structure"), -- 1442
				barsPerSection = numberValue("barsPerSection"), -- 1442
				melodyComplexity = numberValue("melodyComplexity"), -- 1443
				rhythmComplexity = numberValue("rhythmComplexity"), -- 1443
				variation = req.variation or numberValue("variation"), -- 1444
				leadInstrument = stringValue("leadInstrument"), -- 1444
				bassInstrument = stringValue("bassInstrument"), -- 1445
				harmonyInstrument = stringValue("harmonyInstrument"), -- 1445
				stereo = boolValue("stereo"), -- 1445
				reverb = numberValue("reverb"), -- 1446
				delay = numberValue("delay"), -- 1446
				chorus = numberValue("chorus"), -- 1446
				distortion = numberValue("distortion"), -- 1446
				bitCrush = numberValue("bitCrush"), -- 1447
				lowPass = numberValue("lowPass"), -- 1447
				stems = boolValue("stems"), -- 1447
				introBars = numberValue("introBars"), -- 1447
				outroBars = numberValue("outroBars"), -- 1447
				stinger = stringValue("stinger"), -- 1448
				exportMidi = boolValue("exportMidi"), -- 1448
				sourceProject = projectRel, -- 1448
				onProgress = req.onProgress, -- 1449
				isCancelled = req.isCancelled -- 1449
			}) -- 1449
		) -- 1449
	end) -- 1449
end -- 1419
return ____exports -- 1419