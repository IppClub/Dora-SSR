-- [ts]: Command.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local Dora = require("Dora") -- 2
local ____Dora = require("Dora") -- 3
local Content = ____Dora.Content -- 3
local Path = ____Dora.Path -- 3
local Director = ____Dora.Director -- 3
local once = ____Dora.once -- 3
local App = ____Dora.App -- 3
local AgentConfig = require("Agent.Config") -- 4
local ____Utils = require("Agent.Utils") -- 5
local Log = ____Utils.Log -- 5
local ____CommandShared = require("Agent.Tool.CommandShared") -- 8
local toStr = ____CommandShared.toCommandString -- 8
local truncateCommandOutput = ____CommandShared.truncateCommandOutput -- 8
local truncateCommandError = ____CommandShared.truncateCommandError -- 8
local ____GitCommand = require("Agent.Tool.GitCommand") -- 9
local executeGitCommand = ____GitCommand.executeGitCommand -- 9
local ____Operation = require("Agent.Tool.Operation") -- 10
local createOperationId = ____Operation.createOperationId -- 10
local ____WebIDESync = require("Agent.Tool.WebIDESync") -- 11
local refreshWorkspaceTree = ____WebIDESync.refreshWorkspaceTree -- 11
local ____Workspace = require("Agent.Tool.Workspace") -- 12
local isValidWorkspacePath = ____Workspace.isValidWorkspacePath -- 13
local resolveWorkspaceFilePath = ____Workspace.resolveWorkspaceFilePath -- 14
local inspectReadableFile = ____Workspace.inspectReadableFile -- 15
local ____EntryLease = require("Agent.Tool.EntryLease") -- 18
local acquireEntryLease = ____EntryLease.acquireEntryLease -- 18
local recordEntryLeaseRun = ____EntryLease.recordEntryLeaseRun -- 18
local ownsEntryLease = ____EntryLease.ownsEntryLease -- 18
local releaseEntryLease = ____EntryLease.releaseEntryLease -- 18
local ____CommandPreview = require("Agent.Tool.CommandPreview") -- 19
local createPreviewGameInjection = ____CommandPreview.createPreviewGameInjection -- 19
local ____VisionBudget = require("Agent.Tool.VisionBudget") -- 20
local getVisionBudgetState = ____VisionBudget.getVisionBudgetState -- 21
local getVisionTaskUsage = ____VisionBudget.getVisionTaskUsage -- 22
local VISION_MAX_CAPTURE_BATCHES = ____VisionBudget.VISION_MAX_CAPTURE_BATCHES -- 24
local VISION_MAX_CAPTURE_FRAMES = ____VisionBudget.VISION_MAX_CAPTURE_FRAMES -- 25
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 29
local function executeLuaCommand(req) -- 32
	local code = __TS__StringTrim(req.code or "") -- 41
	if code == "" then -- 41
		return __TS__Promise.resolve({ -- 43
			success = false, -- 43
			mode = "lua", -- 43
			output = "", -- 43
			message = "missing code", -- 43
			phase = "validate" -- 43
		}) -- 43
	end -- 43
	local output = {} -- 45
	local entry = require("Script.Dev.Entry") -- 46
	local ownsEntryRuntime = false -- 47
	local contentAccessed = false -- 48
	local refreshTreeCalled = false -- 49
	local entryObjectBaseline = 0 -- 50
	local entryLuaRefBaseline = 0 -- 51
	local persistedVisionUsage -- 52
	local capturedBatches = 0 -- 53
	local capturedFrames = 0 -- 54
	local lastPreviewResult -- 55
	local function currentVisionUsage() -- 56
		if persistedVisionUsage == nil then -- 56
			persistedVisionUsage = getVisionTaskUsage(req.taskId) -- 57
		end -- 57
		return __TS__ObjectAssign({}, persistedVisionUsage, {captureBatchCount = persistedVisionUsage.captureBatchCount + capturedBatches, captureFrameCount = persistedVisionUsage.captureFrameCount + capturedFrames}) -- 58
	end -- 56
	local function reserveCapture(frameCount) -- 64
		local current = currentVisionUsage() -- 65
		if current.captureBatchCount >= VISION_MAX_CAPTURE_BATCHES or current.captureFrameCount + frameCount > VISION_MAX_CAPTURE_FRAMES then -- 65
			return { -- 67
				success = false, -- 68
				message = ((("Vision capture budget exhausted: " .. tostring(current.captureBatchCount)) .. " batches and ") .. tostring(current.captureFrameCount)) .. " frames already reserved", -- 69
				budget = getVisionBudgetState(current) -- 70
			} -- 70
		end -- 70
		capturedBatches = capturedBatches + 1 -- 73
		capturedFrames = capturedFrames + frameCount -- 74
		return { -- 75
			success = true, -- 75
			budget = getVisionBudgetState(currentVisionUsage()) -- 75
		} -- 75
	end -- 64
	local function acquireEntryRuntime() -- 77
		acquireEntryLease(req.operationId, entry) -- 78
		ownsEntryRuntime = true -- 79
	end -- 77
	local function stopOwnedEntry() -- 81
		if not ownsEntryRuntime then -- 81
			return nil -- 82
		end -- 82
		ownsEntryRuntime = false -- 83
		return releaseEntryLease(req.operationId, entry) -- 84
	end -- 81
	local function startEntryWatchdog() -- 86
		entryObjectBaseline = Dora.Object.count -- 87
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 88
	end -- 86
	local function checkEntryWatchdog() -- 90
		if not ownsEntryRuntime then -- 90
			return nil -- 91
		end -- 91
		local objectCount = Dora.Object.count -- 92
		local luaRefCount = Dora.Object.luaRefCount -- 93
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 94
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 95
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 96
		if not exceededTotal then -- 96
			return nil -- 99
		end -- 99
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 100
	end -- 90
	local function normalizeEntryFile(value) -- 104
		if not value or type(value) ~= "table" then -- 104
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 106
		end -- 106
		local descriptor = value -- 108
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 109
		if relativeFile == "" then -- 109
			relativeFile = "init" -- 110
		end -- 110
		if not isValidWorkspacePath(relativeFile) then -- 110
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 112
		end -- 112
		local fileName = Path(req.workDir, relativeFile) -- 114
		local ext = Path:getExt(fileName) -- 115
		if ext ~= "" then -- 115
			fileName = Path:replaceExt(fileName, "") -- 116
		end -- 116
		local luaFile = Path:replaceExt(fileName, "lua") -- 117
		if not Content:exist(luaFile) then -- 117
			error("Agent test entry was not built: " .. luaFile) -- 119
		end -- 119
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 121
		return { -- 122
			fileName = fileName, -- 123
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 124
		} -- 124
	end -- 104
	local function capturePrint(...) -- 127
		local values = {...} -- 127
		local parts = {} -- 128
		do -- 128
			local i = 0 -- 129
			while i < #values do -- 129
				parts[#parts + 1] = tostring(values[i + 1]) -- 130
				i = i + 1 -- 129
			end -- 129
		end -- 129
		output[#output + 1] = table.concat(parts, "\t") -- 132
	end -- 127
	local function refreshTree(path) -- 134
		refreshTreeCalled = true -- 135
		if path == nil then -- 135
			return refreshWorkspaceTree(req.workDir) -- 137
		end -- 137
		if type(path) ~= "string" then -- 137
			error("refreshTree expects a project-relative file path string or no argument") -- 140
		end -- 140
		return refreshWorkspaceTree(req.workDir, path) -- 142
	end -- 134
	local function resolveLuaContentPath(first, second) -- 144
		local value = type(second) == "string" and second or first -- 145
		if type(value) ~= "string" then -- 145
			error("Content path must be a project-relative string") -- 147
		end -- 147
		local fullPath = resolveWorkspaceFilePath(req.workDir, value) -- 149
		if not fullPath then -- 149
			error("Content path must stay inside projectDir") -- 151
		end -- 151
		return fullPath -- 153
	end -- 144
	local scopedContent = { -- 155
		exist = function(first, second) return Content:exist(resolveLuaContentPath(first, second)) end, -- 156
		isdir = function(first, second) return Content:isdir(resolveLuaContentPath(first, second)) end, -- 157
		getAttr = function(first, second) return Content:getAttr(resolveLuaContentPath(first, second)) end, -- 158
		load = function(first, second) -- 159
			local fullPath = resolveLuaContentPath(first, second) -- 160
			local inspected = inspectReadableFile(fullPath) -- 161
			if not inspected.success then -- 161
				error(inspected.message or "file is not readable") -- 162
			end -- 162
			return Content:load(fullPath) -- 163
		end -- 159
	} -- 159
	local blockedDoraGlobals = {Content = true, DB = true, HttpClient = true, HttpServer = true} -- 166
	local env = setmetatable( -- 172
		{ -- 172
			projectDir = req.workDir, -- 173
			previewGame = createPreviewGameInjection( -- 174
				{ -- 174
					workDir = req.workDir, -- 175
					operationId = req.operationId, -- 176
					isCancelled = req.isCancelled, -- 177
					print = function(line) return capturePrint(line) end, -- 178
					reserveCapture = reserveCapture, -- 179
					onResult = function(result) -- 180
						lastPreviewResult = result -- 181
					end -- 180
				}, -- 180
				entry -- 183
			), -- 183
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 184
				if type(moduleNameValue) ~= "string" then -- 184
					error("requireProjectModule expects a project module name string") -- 186
				end -- 186
				local moduleName = __TS__StringTrim(moduleNameValue) -- 188
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 188
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 190
				end -- 190
				local reloadModules = {moduleName} -- 192
				if reloadModulesValue ~= nil then -- 192
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 192
						error("requireProjectModule reloadModules must be an array of module names") -- 195
					end -- 195
					local items = reloadModulesValue -- 197
					do -- 197
						local i = 0 -- 198
						while i < #items do -- 198
							local item = items[i + 1] -- 199
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 199
								error("requireProjectModule reloadModules contains an invalid module name") -- 201
							end -- 201
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 201
								reloadModules[#reloadModules + 1] = item -- 203
							end -- 203
							i = i + 1 -- 198
						end -- 198
					end -- 198
				end -- 198
				local luaPackage = _G.package -- 206
				local previousPath = luaPackage.path -- 210
				local previousSearchPaths = Content.searchPaths -- 211
				local scopedSearchPaths = {req.workDir} -- 212
				do -- 212
					local i = 0 -- 213
					while i < #previousSearchPaths do -- 213
						local searchPath = previousSearchPaths[i + 1] -- 214
						if searchPath ~= req.workDir then -- 214
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 215
						end -- 215
						i = i + 1 -- 213
					end -- 213
				end -- 213
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 217
				Content.searchPaths = scopedSearchPaths -- 218
				do -- 218
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 218
						do -- 218
							local i = 0 -- 220
							while i < #reloadModules do -- 220
								local reloadName = reloadModules[i + 1] -- 221
								luaPackage.loaded[reloadName] = nil -- 222
								luaPackage.loaded[table.concat( -- 223
									__TS__StringSplit(reloadName, "/"), -- 223
									"." -- 223
								)] = nil -- 223
								luaPackage.loaded[table.concat( -- 224
									__TS__StringSplit(reloadName, "."), -- 224
									"/" -- 224
								)] = nil -- 224
								i = i + 1 -- 220
							end -- 220
						end -- 220
						return true, require(table.concat( -- 226
							__TS__StringSplit(moduleName, "/"), -- 226
							"." -- 226
						)) -- 226
					end) -- 226
					do -- 226
						Content.searchPaths = previousSearchPaths -- 228
						luaPackage.path = previousPath -- 229
					end -- 229
					if not ____try then -- 229
						error(____hasReturned, 0) -- 229
					end -- 229
					if ____try and ____hasReturned then -- 229
						return ____returnValue -- 219
					end -- 219
				end -- 219
			end, -- 184
			print = capturePrint, -- 232
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 233
			enterEntryAsync = function(value) -- 234
				local normalized = normalizeEntryFile(value) -- 235
				acquireEntryRuntime() -- 236
				entry.allClear() -- 237
				startEntryWatchdog() -- 238
				recordEntryLeaseRun(req.operationId, entry) -- 239
				local success, message = entry.enterEntryAsync({ -- 240
					entryName = normalized.entryName, -- 241
					fileName = normalized.fileName, -- 242
					workDir = req.workDir, -- 243
					projectRoot = req.workDir, -- 244
					runKind = "agent_test" -- 245
				}) -- 245
				return success, message -- 247
			end, -- 234
			stopEntry = function() -- 249
				if not ownsEntryRuntime or not ownsEntryLease(req.operationId, entry) then -- 249
					return false -- 250
				end -- 250
				return entry.stop() -- 251
			end, -- 249
			reportProgress = function(value, callbackValue) -- 253
				local ____callbackValue_0 = callbackValue -- 254
				if ____callbackValue_0 == nil then -- 254
					____callbackValue_0 = value -- 254
				end -- 254
				local actualValue = ____callbackValue_0 -- 254
				if not req.onProgress or not actualValue or type(actualValue) ~= "table" then -- 254
					return -- 255
				end -- 255
				local progress = actualValue -- 256
				local amount = type(progress.progress) == "number" and math.min( -- 257
					1, -- 258
					math.max(0, progress.progress) -- 258
				) or nil -- 258
				req:onProgress({ -- 260
					state = "running", -- 261
					mode = "lua", -- 262
					operationId = req.operationId, -- 263
					progress = amount, -- 264
					stage = type(progress.stage) == "string" and progress.stage or "lua", -- 265
					message = type(progress.message) == "string" and progress.message or "Lua command running" -- 266
				}) -- 266
			end -- 253
		}, -- 253
		{__index = function(_table, key) -- 269
			if key == "Content" then -- 269
				contentAccessed = true -- 272
				return scopedContent -- 273
			end -- 273
			if key == "refreshTree" then -- 273
				return refreshTree -- 276
			end -- 276
			local name = tostring(key) -- 278
			if blockedDoraGlobals[name] then -- 278
				return nil -- 279
			end -- 279
			return Dora[name] -- 280
		end} -- 270
	) -- 270
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 283
	if not fn then -- 283
		return __TS__Promise.resolve({ -- 285
			success = false, -- 286
			mode = "lua", -- 287
			output = truncateCommandOutput(table.concat(output, "\n")), -- 288
			message = truncateCommandError(toStr(compileErr)), -- 289
			phase = "compile" -- 290
		}) -- 290
	end -- 290
	return __TS__New( -- 293
		__TS__Promise, -- 293
		function(____, resolve) -- 293
			local settled = false -- 294
			local commandRoutine -- 295
			local startedAt = App.runningTime -- 296
			local onProgress = req.onProgress -- 297
			local isCancelled = req.isCancelled -- 298
			local function finish(result) -- 299
				if settled then -- 299
					return -- 300
				end -- 300
				settled = true -- 301
				local cleanupError -- 302
				if not result.success and (result.interrupted == true or result.phase == "timeout") then -- 302
					do -- 302
						local function ____catch(e) -- 302
							cleanupError = "failed to clear interrupted Lua command runtime: " .. tostring(e) -- 307
						end -- 307
						local ____try, ____hasReturned = pcall(function() -- 307
							entry.allClear() -- 305
						end) -- 305
						if not ____try then -- 305
							____catch(____hasReturned) -- 305
						end -- 305
					end -- 305
				end -- 305
				local entryCleanupError = stopOwnedEntry() -- 310
				if cleanupError == nil then -- 310
					cleanupError = entryCleanupError -- 311
				end -- 311
				if contentAccessed and not refreshTreeCalled and not refreshWorkspaceTree(req.workDir) then -- 311
					Log("Warn", "[execute_command] failed to refresh Web IDE tree after Lua command workDir=" .. req.workDir) -- 313
				end -- 313
				local ____lastPreviewResult_6 -- 315
				if lastPreviewResult then -- 315
					local ____lastPreviewResult_success_3 = lastPreviewResult.success -- 316
					local ____lastPreviewResult_message_4 = lastPreviewResult.message -- 317
					local ____lastPreviewResult_files_5 = lastPreviewResult.files -- 318
					local ____opt_1 = lastPreviewResult.frames -- 318
					____lastPreviewResult_6 = {success = ____lastPreviewResult_success_3, message = ____lastPreviewResult_message_4, files = ____lastPreviewResult_files_5, frameCount = ____opt_1 and #____opt_1} -- 315
				else -- 315
					____lastPreviewResult_6 = nil -- 320
				end -- 320
				local previewGame = ____lastPreviewResult_6 -- 315
				local visionFields = __TS__ObjectAssign( -- 321
					{}, -- 321
					previewGame and ({previewGame = previewGame}) or ({}), -- 322
					capturedBatches > 0 and ({ -- 323
						visionCapture = {batchCount = capturedBatches, frameCount = capturedFrames}, -- 324
						visionBudget = getVisionBudgetState(currentVisionUsage()) -- 325
					}) or ({}) -- 325
				) -- 325
				if not result.success and cleanupError ~= nil then -- 325
					result.cleanupError = cleanupError -- 329
				elseif result.success and cleanupError ~= nil then -- 329
					resolve( -- 331
						nil, -- 331
						__TS__ObjectAssign({ -- 331
							success = false, -- 332
							mode = "lua", -- 333
							output = result.output, -- 334
							message = cleanupError, -- 335
							phase = "execute", -- 336
							cleanupError = cleanupError -- 337
						}, visionFields) -- 337
					) -- 337
					return -- 340
				end -- 340
				if result.success and lastPreviewResult and not lastPreviewResult.success then -- 340
					resolve( -- 343
						nil, -- 343
						__TS__ObjectAssign({ -- 343
							success = false, -- 344
							mode = "lua", -- 345
							output = result.output, -- 346
							message = "previewGame failed: " .. (lastPreviewResult.message or "unknown error"), -- 347
							phase = "execute" -- 348
						}, visionFields) -- 348
					) -- 348
					return -- 351
				end -- 351
				resolve( -- 353
					nil, -- 353
					__TS__ObjectAssign({}, result, visionFields) -- 353
				) -- 353
			end -- 299
			if onProgress then -- 299
				onProgress(nil, { -- 359
					state = "pending", -- 360
					mode = "lua", -- 361
					operationId = req.operationId, -- 362
					stage = "lua", -- 363
					message = "Lua command pending" -- 364
				}) -- 364
			end -- 364
			commandRoutine = once(function() -- 367
				if settled then -- 367
					return -- 368
				end -- 368
				if onProgress then -- 368
					onProgress(nil, { -- 370
						state = "running", -- 371
						mode = "lua", -- 372
						operationId = req.operationId, -- 373
						stage = "lua", -- 374
						message = "Lua command running" -- 375
					}) -- 375
				end -- 375
				local previousGlobalPrint = _G.print -- 378
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 379
				local frameTimedOut = false -- 380
				local watchdogMessage -- 380
				_G.print = capturePrint -- 381
				debug.sethook( -- 382
					function() -- 382
						if watchdogMessage == nil then -- 382
							watchdogMessage = checkEntryWatchdog() -- 383
						end -- 383
						if watchdogMessage ~= nil then -- 383
							error(watchdogMessage) -- 384
						end -- 384
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 384
							frameTimedOut = true -- 386
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 387
						end -- 387
					end, -- 382
					"", -- 389
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 389
				) -- 389
				local ok, runtimeErr = pcall(fn) -- 390
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 390
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 392
				else -- 392
					debug.sethook() -- 398
				end -- 398
				_G.print = previousGlobalPrint -- 400
				if not ok then -- 400
					local ____truncateCommandOutput_result_8 = truncateCommandOutput(table.concat(output, "\n")) -- 405
					local ____temp_9 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 406
					local ____temp_10 = frameTimedOut and "timeout" or "execute" -- 407
					local ____temp_7 -- 408
					if watchdogMessage ~= nil or frameTimedOut then -- 408
						____temp_7 = true -- 408
					else -- 408
						____temp_7 = nil -- 408
					end -- 408
					finish({ -- 402
						success = false, -- 403
						mode = "lua", -- 404
						output = ____truncateCommandOutput_result_8, -- 405
						message = ____temp_9, -- 406
						phase = ____temp_10, -- 407
						interrupted = ____temp_7 -- 408
					}) -- 408
					return -- 410
				end -- 410
				finish({ -- 412
					success = true, -- 412
					mode = "lua", -- 412
					output = truncateCommandOutput(table.concat(output, "\n")) -- 412
				}) -- 412
			end) -- 367
			Director.systemScheduler:schedule(function() -- 414
				if settled then -- 414
					return true -- 415
				end -- 415
				local watchdogMessage = checkEntryWatchdog() -- 416
				if watchdogMessage ~= nil then -- 416
					finish({ -- 418
						success = false, -- 419
						mode = "lua", -- 420
						output = truncateCommandOutput(table.concat(output, "\n")), -- 421
						message = watchdogMessage, -- 422
						phase = "execute", -- 423
						interrupted = true -- 424
					}) -- 424
					return true -- 426
				end -- 426
				if isCancelled and isCancelled(nil) then -- 426
					finish({ -- 429
						success = false, -- 430
						mode = "lua", -- 431
						output = truncateCommandOutput(table.concat(output, "\n")), -- 432
						message = "Lua command canceled", -- 433
						phase = "execute", -- 434
						interrupted = true -- 435
					}) -- 435
					return true -- 437
				end -- 437
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 437
					finish({ -- 440
						success = false, -- 441
						mode = "lua", -- 442
						output = truncateCommandOutput(table.concat(output, "\n")), -- 443
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 444
						phase = "timeout" -- 445
					}) -- 445
					return true -- 447
				end -- 447
				if commandRoutine == nil then -- 447
					finish({ -- 450
						success = false, -- 451
						mode = "lua", -- 452
						output = truncateCommandOutput(table.concat(output, "\n")), -- 453
						message = "Lua command coroutine is unavailable", -- 454
						phase = "execute" -- 455
					}) -- 455
					return true -- 457
				end -- 457
				local resumeSuccess, resumeResult = coroutine.resume(commandRoutine) -- 459
				if not resumeSuccess then -- 459
					finish({ -- 461
						success = false, -- 462
						mode = "lua", -- 463
						output = truncateCommandOutput(table.concat(output, "\n")), -- 464
						message = truncateCommandError(toStr(resumeResult)), -- 465
						phase = "execute" -- 466
					}) -- 466
					return true -- 468
				end -- 468
				return settled or resumeResult == true -- 470
			end) -- 414
		end -- 293
	) -- 293
end -- 32
function ____exports.executeCommand(req) -- 475
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 475
		local mode = req.mode -- 486
		if mode ~= "lua" and mode ~= "git" then -- 486
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 486
		end -- 486
		if mode == "lua" then -- 486
			return ____awaiter_resolve( -- 486
				nil, -- 486
				executeLuaCommand({ -- 491
					workDir = req.workDir, -- 492
					code = req.code or "", -- 493
					timeoutSeconds = math.max( -- 494
						1, -- 494
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 494
					), -- 494
					operationId = createOperationId(), -- 495
					taskId = req.taskId or 0, -- 496
					onProgress = req.onProgress, -- 497
					isCancelled = req.isCancelled -- 498
				}) -- 498
			) -- 498
		end -- 498
		local operationId = createOperationId() -- 501
		return ____awaiter_resolve( -- 501
			nil, -- 501
			executeGitCommand({ -- 502
				workDir = req.workDir, -- 503
				command = req.command or "", -- 504
				cwd = req.cwd, -- 505
				timeoutSeconds = math.max( -- 506
					1, -- 506
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 506
				), -- 506
				operationId = operationId, -- 507
				onProgress = req.onProgress, -- 508
				isCancelled = req.isCancelled -- 509
			}) -- 509
		) -- 509
	end) -- 509
end -- 475
return ____exports -- 475