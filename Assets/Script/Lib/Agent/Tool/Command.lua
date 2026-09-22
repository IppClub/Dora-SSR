-- [ts]: Command.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
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
local sleep = ____Dora.sleep -- 3
local AgentConfig = require("Agent.Config") -- 4
local ____Utils = require("Agent.Utils") -- 5
local Log = ____Utils.Log -- 5
local safeJsonDecode = ____Utils.safeJsonDecode -- 5
local safeJsonEncode = ____Utils.safeJsonEncode -- 5
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
local function executeStudioLuaCommand(req) -- 38
	local usesPreviewGame = (string.match( -- 50
		req.code, -- 50
		"%f[%a_]previewGame%f[^%w_]%s*%(" -- 50
	)) ~= nil -- 50
	if type(_studio_agent_tool_begin) ~= "function" or usesPreviewGame then -- 50
		return nil -- 51
	end -- 51
	local onProgress = req.onProgress -- 48
	local isCancelled = req.isCancelled -- 49
	return __TS__New( -- 50
		__TS__Promise, -- 50
		function(____, resolve) -- 50
			local requestId -- 51
			local settled = false -- 52
			local function finish(result) -- 53
				if settled then -- 53
					return -- 54
				end -- 54
				settled = true -- 55
				resolve(nil, result) -- 56
			end -- 53
			if onProgress ~= nil then -- 53
				onProgress(nil, { -- 58
					state = "pending", -- 58
					mode = "lua", -- 58
					operationId = req.operationId, -- 58
					stage = "player", -- 58
					message = "Lua command pending in isolated game Player" -- 58
				}) -- 58
			end -- 58
			local routine = once(function() -- 59
				do -- 59
					local function ____catch(e) -- 59
						if requestId then -- 59
							if _studio_agent_tool_cancel ~= nil then -- 59
								_studio_agent_tool_cancel(requestId) -- 83
							end -- 83
							requestId = nil -- 83
						end -- 83
						local message = truncateCommandError(toStr(e)) -- 84
						local ____message_9 = message -- 85
						local ____temp_10 = (string.find(message, "timed out", nil, true) or 0) - 1 >= 0 and "timeout" or "execute" -- 85
						local ____temp_8 -- 85
						if (string.find(message, "canceled", nil, true) or 0) - 1 >= 0 then -- 85
							____temp_8 = true -- 85
						else -- 85
							____temp_8 = nil -- 85
						end -- 85
						finish({ -- 85
							success = false, -- 85
							mode = "lua", -- 85
							output = "", -- 85
							message = ____message_9, -- 85
							phase = ____temp_10, -- 85
							interrupted = ____temp_8 -- 85
						}) -- 85
					end -- 85
					local ____try, ____hasReturned = pcall(function() -- 85
						local options = safeJsonEncode({code = req.code, timeoutSeconds = req.timeoutSeconds}) -- 61
						if not options then -- 61
							error("failed to encode Studio Agent Lua command") -- 62
						end -- 62
						requestId = _studio_agent_tool_begin( -- 63
							"execute-lua", -- 63
							Path(req.workDir, ".agent", "command.lua"), -- 63
							options, -- 63
							req.workDir -- 63
						) -- 63
						if onProgress ~= nil then -- 63
							onProgress(nil, { -- 64
								state = "running", -- 64
								mode = "lua", -- 64
								operationId = req.operationId, -- 64
								stage = "player", -- 64
								message = "Lua command running in isolated game Player" -- 64
							}) -- 64
						end -- 64
						local deadline = App.runningTime + req.timeoutSeconds -- 65
						local answer -- 66
						while not answer do -- 66
							if isCancelled and isCancelled(nil) then -- 66
								error("Lua command canceled") -- 68
							end -- 68
							if App.runningTime >= deadline then -- 68
								error(("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds") -- 69
							end -- 69
							answer = _studio_agent_tool_poll and _studio_agent_tool_poll(requestId) -- 70
							if not answer then -- 70
								sleep() -- 71
							end -- 71
						end -- 71
						requestId = nil -- 73
						if not answer.success then -- 73
							error(answer.message or "Studio Agent Lua Player failed") -- 74
						end -- 74
						local decoded = safeJsonDecode(answer.resultJSON or "") -- 75
						local value = decoded -- 76
						if not value or type(value.success) ~= "boolean" or type(value.output) ~= "string" or value.message ~= nil and type(value.message) ~= "string" or value.phase ~= nil and value.phase ~= "compile" and value.phase ~= "execute" and value.phase ~= "timeout" and value.phase ~= "validate" then -- 76
							error("Invalid Studio Agent Lua Player result") -- 79
						end -- 79
						if value.success then -- 79
							finish({ -- 80
								success = true, -- 80
								mode = "lua", -- 80
								output = truncateCommandOutput(value.output) -- 80
							}) -- 80
						else -- 80
							finish({ -- 81
								success = false, -- 81
								mode = "lua", -- 81
								output = truncateCommandOutput(value.output), -- 81
								message = truncateCommandError(value.message or "Lua command failed"), -- 81
								phase = value.phase or "execute" -- 81
							}) -- 81
						end -- 81
					end) -- 81
					if not ____try then -- 81
						____catch(____hasReturned) -- 81
					end -- 81
				end -- 81
			end) -- 59
			Director.systemScheduler:schedule(function() -- 88
				if settled then -- 88
					return true -- 89
				end -- 89
				local ok, result = coroutine.resume(routine) -- 90
				if not ok then -- 90
					finish({ -- 91
						success = false, -- 91
						mode = "lua", -- 91
						output = "", -- 91
						message = truncateCommandError(toStr(result)), -- 91
						phase = "execute" -- 91
					}) -- 91
					return true -- 91
				end -- 91
				return settled or result == true -- 92
			end) -- 88
		end -- 50
	) -- 50
end -- 38
local function executeLuaCommand(req) -- 98
	local code = __TS__StringTrim(req.code or "") -- 107
	if code == "" then -- 107
		return __TS__Promise.resolve({ -- 109
			success = false, -- 109
			mode = "lua", -- 109
			output = "", -- 109
			message = "missing code", -- 109
			phase = "validate" -- 109
		}) -- 109
	end -- 109
	local studioResult = executeStudioLuaCommand(__TS__ObjectAssign({}, req, {code = code})) -- 111
	if studioResult then -- 111
		return studioResult -- 112
	end -- 112
	local output = {} -- 113
	local entry = require("Script.Dev.Entry") -- 114
	local ownsEntryRuntime = false -- 115
	local contentAccessed = false -- 116
	local refreshTreeCalled = false -- 117
	local entryObjectBaseline = 0 -- 118
	local entryLuaRefBaseline = 0 -- 119
	local persistedVisionUsage -- 120
	local capturedBatches = 0 -- 121
	local capturedFrames = 0 -- 122
	local lastPreviewResult -- 123
	local previewCleanup -- 124
	local restorePrint -- 125
	local function currentVisionUsage() -- 126
		if persistedVisionUsage == nil then -- 126
			persistedVisionUsage = getVisionTaskUsage(req.taskId) -- 127
		end -- 127
		return __TS__ObjectAssign({}, persistedVisionUsage, {captureBatchCount = persistedVisionUsage.captureBatchCount + capturedBatches, captureFrameCount = persistedVisionUsage.captureFrameCount + capturedFrames}) -- 128
	end -- 126
	local function reserveCapture(frameCount) -- 134
		local current = currentVisionUsage() -- 135
		if current.captureBatchCount >= VISION_MAX_CAPTURE_BATCHES or current.captureFrameCount + frameCount > VISION_MAX_CAPTURE_FRAMES then -- 135
			return { -- 137
				success = false, -- 138
				message = ((("Vision capture budget exhausted: " .. tostring(current.captureBatchCount)) .. " batches and ") .. tostring(current.captureFrameCount)) .. " frames already reserved", -- 139
				budget = getVisionBudgetState(current) -- 140
			} -- 140
		end -- 140
		capturedBatches = capturedBatches + 1 -- 143
		capturedFrames = capturedFrames + frameCount -- 144
		return { -- 145
			success = true, -- 145
			budget = getVisionBudgetState(currentVisionUsage()) -- 145
		} -- 145
	end -- 134
	local function acquireEntryRuntime() -- 147
		acquireEntryLease(req.operationId, entry) -- 148
		ownsEntryRuntime = true -- 149
	end -- 147
	local function stopOwnedEntry() -- 151
		if not ownsEntryRuntime then -- 151
			return nil -- 152
		end -- 152
		ownsEntryRuntime = false -- 153
		return releaseEntryLease(req.operationId, entry) -- 154
	end -- 151
	local function startEntryWatchdog() -- 156
		entryObjectBaseline = Dora.Object.count -- 157
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 158
	end -- 156
	local function checkEntryWatchdog() -- 160
		if not ownsEntryRuntime then -- 160
			return nil -- 161
		end -- 161
		local objectCount = Dora.Object.count -- 162
		local luaRefCount = Dora.Object.luaRefCount -- 163
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 164
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 165
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 166
		if not exceededTotal then -- 166
			return nil -- 169
		end -- 169
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 170
	end -- 160
	local function normalizeEntryFile(value) -- 174
		if not value or type(value) ~= "table" then -- 174
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 176
		end -- 176
		local descriptor = value -- 178
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 179
		if relativeFile == "" then -- 179
			relativeFile = "init" -- 180
		end -- 180
		if not isValidWorkspacePath(relativeFile) then -- 180
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 182
		end -- 182
		local fileName = Path(req.workDir, relativeFile) -- 184
		local ext = Path:getExt(fileName) -- 185
		if ext ~= "" then -- 185
			fileName = Path:replaceExt(fileName, "") -- 186
		end -- 186
		local luaFile = Path:replaceExt(fileName, "lua") -- 187
		if not Content:exist(luaFile) then -- 187
			error("Agent test entry was not built: " .. luaFile) -- 189
		end -- 189
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 191
		return { -- 192
			fileName = fileName, -- 193
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 194
		} -- 194
	end -- 174
	local function capturePrint(...) -- 197
		local values = {...} -- 197
		local parts = {} -- 198
		do -- 198
			local i = 0 -- 199
			while i < #values do -- 199
				parts[#parts + 1] = tostring(values[i + 1]) -- 200
				i = i + 1 -- 199
			end -- 199
		end -- 199
		output[#output + 1] = table.concat(parts, "\t") -- 202
	end -- 197
	local function refreshTree(path) -- 204
		refreshTreeCalled = true -- 205
		if path == nil then -- 205
			return refreshWorkspaceTree(req.workDir) -- 207
		end -- 207
		if type(path) ~= "string" then -- 207
			error("refreshTree expects a project-relative file path string or no argument") -- 210
		end -- 210
		return refreshWorkspaceTree(req.workDir, path) -- 212
	end -- 204
	local function resolveLuaContentPath(first, second) -- 214
		local value = type(second) == "string" and second or first -- 215
		if type(value) ~= "string" then -- 215
			error("Content path must be a project-relative string") -- 217
		end -- 217
		local fullPath = resolveWorkspaceFilePath(req.workDir, value) -- 219
		if not fullPath then -- 219
			error("Content path must stay inside projectDir") -- 221
		end -- 221
		return fullPath -- 223
	end -- 214
	local scopedContent = { -- 225
		exist = function(first, second) return Content:exist(resolveLuaContentPath(first, second)) end, -- 226
		isdir = function(first, second) return Content:isdir(resolveLuaContentPath(first, second)) end, -- 227
		getAttr = function(first, second) return Content:getAttr(resolveLuaContentPath(first, second)) end, -- 228
		load = function(first, second) -- 229
			local fullPath = resolveLuaContentPath(first, second) -- 230
			local inspected = inspectReadableFile(fullPath) -- 231
			if not inspected.success then -- 231
				error(inspected.message or "file is not readable") -- 232
			end -- 232
			return Content:load(fullPath) -- 233
		end -- 229
	} -- 229
	local blockedDoraGlobals = {Content = true, DB = true, HttpClient = true, HttpServer = true} -- 236
	local env = setmetatable( -- 242
		{ -- 242
			projectDir = req.workDir, -- 243
			previewGame = createPreviewGameInjection( -- 244
				{ -- 244
					workDir = req.workDir, -- 245
					operationId = req.operationId, -- 246
					isCancelled = req.isCancelled, -- 247
					print = function(line) return capturePrint(line) end, -- 248
					reserveCapture = reserveCapture, -- 249
					registerCleanup = function(cleanup) -- 250
						previewCleanup = cleanup -- 250
					end, -- 250
					onResult = function(result) -- 251
						lastPreviewResult = result -- 252
					end -- 251
				}, -- 251
				entry -- 254
			), -- 254
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 255
				if type(moduleNameValue) ~= "string" then -- 255
					error("requireProjectModule expects a project module name string") -- 257
				end -- 257
				local moduleName = __TS__StringTrim(moduleNameValue) -- 259
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 259
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 261
				end -- 261
				local reloadModules = {moduleName} -- 263
				if reloadModulesValue ~= nil then -- 263
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 263
						error("requireProjectModule reloadModules must be an array of module names") -- 266
					end -- 266
					local items = reloadModulesValue -- 268
					do -- 268
						local i = 0 -- 269
						while i < #items do -- 269
							local item = items[i + 1] -- 270
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 270
								error("requireProjectModule reloadModules contains an invalid module name") -- 272
							end -- 272
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 272
								reloadModules[#reloadModules + 1] = item -- 274
							end -- 274
							i = i + 1 -- 269
						end -- 269
					end -- 269
				end -- 269
				local luaPackage = _G.package -- 277
				local previousPath = luaPackage.path -- 281
				local previousSearchPaths = Content.searchPaths -- 282
				local scopedSearchPaths = {req.workDir} -- 283
				do -- 283
					local i = 0 -- 284
					while i < #previousSearchPaths do -- 284
						local searchPath = previousSearchPaths[i + 1] -- 285
						if searchPath ~= req.workDir then -- 285
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 286
						end -- 286
						i = i + 1 -- 284
					end -- 284
				end -- 284
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 288
				Content.searchPaths = scopedSearchPaths -- 289
				do -- 289
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 289
						do -- 289
							local i = 0 -- 291
							while i < #reloadModules do -- 291
								local reloadName = reloadModules[i + 1] -- 292
								luaPackage.loaded[reloadName] = nil -- 293
								luaPackage.loaded[table.concat( -- 294
									__TS__StringSplit(reloadName, "/"), -- 294
									"." -- 294
								)] = nil -- 294
								luaPackage.loaded[table.concat( -- 295
									__TS__StringSplit(reloadName, "."), -- 295
									"/" -- 295
								)] = nil -- 295
								i = i + 1 -- 291
							end -- 291
						end -- 291
						return true, require(table.concat( -- 297
							__TS__StringSplit(moduleName, "/"), -- 297
							"." -- 297
						)) -- 297
					end) -- 297
					do -- 297
						Content.searchPaths = previousSearchPaths -- 299
						luaPackage.path = previousPath -- 300
					end -- 300
					if not ____try then -- 300
						error(____hasReturned, 0) -- 300
					end -- 300
					if ____try and ____hasReturned then -- 300
						return ____returnValue -- 290
					end -- 290
				end -- 290
			end, -- 255
			print = capturePrint, -- 303
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 304
			enterEntryAsync = function(value) -- 305
				local normalized = normalizeEntryFile(value) -- 306
				acquireEntryRuntime() -- 307
				entry.allClear() -- 308
				startEntryWatchdog() -- 309
				recordEntryLeaseRun(req.operationId, entry) -- 310
				local success, message = entry.enterEntryAsync({ -- 311
					entryName = normalized.entryName, -- 312
					fileName = normalized.fileName, -- 313
					workDir = req.workDir, -- 314
					projectRoot = req.workDir, -- 315
					runKind = "agent_test" -- 316
				}) -- 316
				return success, message -- 318
			end, -- 305
			stopEntry = function() -- 320
				if not ownsEntryRuntime or not ownsEntryLease(req.operationId, entry) then -- 320
					return false -- 321
				end -- 321
				return entry.stop() -- 322
			end, -- 320
			reportProgress = function(value, callbackValue) -- 324
				local ____callbackValue_11 = callbackValue -- 325
				if ____callbackValue_11 == nil then -- 325
					____callbackValue_11 = value -- 325
				end -- 325
				local actualValue = ____callbackValue_11 -- 325
				if not req.onProgress or not actualValue or type(actualValue) ~= "table" then -- 325
					return -- 326
				end -- 326
				local progress = actualValue -- 327
				local amount = type(progress.progress) == "number" and math.min( -- 328
					1, -- 329
					math.max(0, progress.progress) -- 329
				) or nil -- 329
				req:onProgress({ -- 331
					state = "running", -- 332
					mode = "lua", -- 333
					operationId = req.operationId, -- 334
					progress = amount, -- 335
					stage = type(progress.stage) == "string" and progress.stage or "lua", -- 336
					message = type(progress.message) == "string" and progress.message or "Lua command running" -- 337
				}) -- 337
			end -- 324
		}, -- 324
		{__index = function(_table, key) -- 340
			if key == "Content" then -- 340
				contentAccessed = true -- 343
				return scopedContent -- 344
			end -- 344
			if key == "refreshTree" then -- 344
				return refreshTree -- 347
			end -- 347
			local name = tostring(key) -- 349
			if blockedDoraGlobals[name] then -- 349
				return nil -- 350
			end -- 350
			return Dora[name] -- 351
		end} -- 341
	) -- 341
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 354
	if not fn then -- 354
		return __TS__Promise.resolve({ -- 356
			success = false, -- 357
			mode = "lua", -- 358
			output = truncateCommandOutput(table.concat(output, "\n")), -- 359
			message = truncateCommandError(toStr(compileErr)), -- 360
			phase = "compile" -- 361
		}) -- 361
	end -- 361
	return __TS__New( -- 364
		__TS__Promise, -- 364
		function(____, resolve) -- 364
			local settled = false -- 365
			local commandRoutine -- 366
			local startedAt = App.runningTime -- 367
			local onProgress = req.onProgress -- 368
			local isCancelled = req.isCancelled -- 369
			local function finish(result) -- 370
				if settled then -- 370
					return -- 371
				end -- 371
				settled = true -- 372
				local cleanupError -- 373
				local cleanup = previewCleanup -- 374
				previewCleanup = nil -- 375
				do -- 375
					local function ____catch(e) -- 375
						cleanupError = "failed to release Agent preview: " .. tostring(e) -- 377
					end -- 377
					local ____try, ____hasReturned = pcall(function() -- 377
						if cleanup ~= nil then -- 377
							cleanup() -- 376
						end -- 376
					end) -- 376
					if not ____try then -- 376
						____catch(____hasReturned) -- 376
					end -- 376
				end -- 376
				if restorePrint ~= nil then -- 376
					restorePrint() -- 378
				end -- 378
				restorePrint = nil -- 379
				if not result.success and (result.interrupted == true or result.phase == "timeout") and (not entry.getCurrentEntryStatus().running or ownsEntryLease(req.operationId, entry)) then -- 379
					do -- 379
						local function ____catch(e) -- 379
							cleanupError = "failed to clear interrupted Lua command runtime: " .. tostring(e) -- 385
						end -- 385
						local ____try, ____hasReturned = pcall(function() -- 385
							entry.allClear() -- 383
						end) -- 383
						if not ____try then -- 383
							____catch(____hasReturned) -- 383
						end -- 383
					end -- 383
				end -- 383
				local entryCleanupError = stopOwnedEntry() -- 388
				if cleanupError == nil then -- 388
					cleanupError = entryCleanupError -- 389
				end -- 389
				if contentAccessed and not refreshTreeCalled and not refreshWorkspaceTree(req.workDir) then -- 389
					Log("Warn", "[execute_command] failed to refresh Web IDE tree after Lua command workDir=" .. req.workDir) -- 391
				end -- 391
				local ____lastPreviewResult_21 -- 393
				if lastPreviewResult then -- 393
					local ____lastPreviewResult_success_18 = lastPreviewResult.success -- 394
					local ____lastPreviewResult_message_19 = lastPreviewResult.message -- 395
					local ____lastPreviewResult_files_20 = lastPreviewResult.files -- 396
					local ____opt_16 = lastPreviewResult.frames -- 396
					____lastPreviewResult_21 = {success = ____lastPreviewResult_success_18, message = ____lastPreviewResult_message_19, files = ____lastPreviewResult_files_20, frameCount = ____opt_16 and #____opt_16} -- 393
				else -- 393
					____lastPreviewResult_21 = nil -- 398
				end -- 398
				local previewGame = ____lastPreviewResult_21 -- 393
				local visionFields = __TS__ObjectAssign( -- 399
					{}, -- 399
					previewGame and ({previewGame = previewGame}) or ({}), -- 400
					capturedBatches > 0 and ({ -- 401
						visionCapture = {batchCount = capturedBatches, frameCount = capturedFrames}, -- 402
						visionBudget = getVisionBudgetState(currentVisionUsage()) -- 403
					}) or ({}) -- 403
				) -- 403
				if not result.success and cleanupError ~= nil then -- 403
					result.cleanupError = cleanupError -- 407
				elseif result.success and cleanupError ~= nil then -- 407
					resolve( -- 409
						nil, -- 409
						__TS__ObjectAssign({ -- 409
							success = false, -- 410
							mode = "lua", -- 411
							output = result.output, -- 412
							message = cleanupError, -- 413
							phase = "execute", -- 414
							cleanupError = cleanupError -- 415
						}, visionFields) -- 415
					) -- 415
					return -- 418
				end -- 418
				if result.success and lastPreviewResult and not lastPreviewResult.success then -- 418
					resolve( -- 421
						nil, -- 421
						__TS__ObjectAssign({ -- 421
							success = false, -- 422
							mode = "lua", -- 423
							output = result.output, -- 424
							message = "previewGame failed: " .. (lastPreviewResult.message or "unknown error"), -- 425
							phase = "execute" -- 426
						}, visionFields) -- 426
					) -- 426
					return -- 429
				end -- 429
				resolve( -- 431
					nil, -- 431
					__TS__ObjectAssign({}, result, visionFields) -- 431
				) -- 431
			end -- 370
			if onProgress then -- 370
				onProgress(nil, { -- 437
					state = "pending", -- 438
					mode = "lua", -- 439
					operationId = req.operationId, -- 440
					stage = "lua", -- 441
					message = "Lua command pending" -- 442
				}) -- 442
			end -- 442
			commandRoutine = once(function() -- 445
				if settled then -- 445
					return -- 446
				end -- 446
				if onProgress then -- 446
					onProgress(nil, { -- 448
						state = "running", -- 449
						mode = "lua", -- 450
						operationId = req.operationId, -- 451
						stage = "lua", -- 452
						message = "Lua command running" -- 453
					}) -- 453
				end -- 453
				local previousGlobalPrint = _G.print -- 456
				restorePrint = function() -- 457
					if _G.print == capturePrint then -- 457
						_G.print = previousGlobalPrint -- 457
					end -- 457
				end -- 457
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 458
				local frameTimedOut = false -- 459
				local watchdogMessage -- 459
				_G.print = capturePrint -- 460
				debug.sethook( -- 461
					function() -- 461
						if watchdogMessage == nil then -- 461
							watchdogMessage = checkEntryWatchdog() -- 462
						end -- 462
						if watchdogMessage ~= nil then -- 462
							error(watchdogMessage) -- 463
						end -- 463
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 463
							frameTimedOut = true -- 465
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 466
						end -- 466
					end, -- 461
					"", -- 468
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 468
				) -- 468
				local ok, runtimeErr = pcall(fn) -- 469
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 469
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 471
				else -- 471
					debug.sethook() -- 477
				end -- 477
				_G.print = previousGlobalPrint -- 479
				if not ok then -- 479
					local ____truncateCommandOutput_result_23 = truncateCommandOutput(table.concat(output, "\n")) -- 484
					local ____temp_24 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 485
					local ____temp_25 = frameTimedOut and "timeout" or "execute" -- 486
					local ____temp_22 -- 487
					if watchdogMessage ~= nil or frameTimedOut then -- 487
						____temp_22 = true -- 487
					else -- 487
						____temp_22 = nil -- 487
					end -- 487
					finish({ -- 481
						success = false, -- 482
						mode = "lua", -- 483
						output = ____truncateCommandOutput_result_23, -- 484
						message = ____temp_24, -- 485
						phase = ____temp_25, -- 486
						interrupted = ____temp_22 -- 487
					}) -- 487
					return -- 489
				end -- 489
				finish({ -- 491
					success = true, -- 491
					mode = "lua", -- 491
					output = truncateCommandOutput(table.concat(output, "\n")) -- 491
				}) -- 491
			end) -- 445
			Director.systemScheduler:schedule(function() -- 493
				if settled then -- 493
					return true -- 494
				end -- 494
				local watchdogMessage = checkEntryWatchdog() -- 495
				if watchdogMessage ~= nil then -- 495
					finish({ -- 497
						success = false, -- 498
						mode = "lua", -- 499
						output = truncateCommandOutput(table.concat(output, "\n")), -- 500
						message = watchdogMessage, -- 501
						phase = "execute", -- 502
						interrupted = true -- 503
					}) -- 503
					return true -- 505
				end -- 505
				if isCancelled and isCancelled(nil) then -- 505
					finish({ -- 508
						success = false, -- 509
						mode = "lua", -- 510
						output = truncateCommandOutput(table.concat(output, "\n")), -- 511
						message = "Lua command canceled", -- 512
						phase = "execute", -- 513
						interrupted = true -- 514
					}) -- 514
					return true -- 516
				end -- 516
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 516
					finish({ -- 519
						success = false, -- 520
						mode = "lua", -- 521
						output = truncateCommandOutput(table.concat(output, "\n")), -- 522
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 523
						phase = "timeout" -- 524
					}) -- 524
					return true -- 526
				end -- 526
				if commandRoutine == nil then -- 526
					finish({ -- 529
						success = false, -- 530
						mode = "lua", -- 531
						output = truncateCommandOutput(table.concat(output, "\n")), -- 532
						message = "Lua command coroutine is unavailable", -- 533
						phase = "execute" -- 534
					}) -- 534
					return true -- 536
				end -- 536
				local resumeSuccess, resumeResult = coroutine.resume(commandRoutine) -- 538
				if not resumeSuccess then -- 538
					finish({ -- 540
						success = false, -- 541
						mode = "lua", -- 542
						output = truncateCommandOutput(table.concat(output, "\n")), -- 543
						message = truncateCommandError(toStr(resumeResult)), -- 544
						phase = "execute" -- 545
					}) -- 545
					return true -- 547
				end -- 547
				return settled or resumeResult == true -- 549
			end) -- 493
		end -- 364
	) -- 364
end -- 98
function ____exports.executeCommand(req) -- 554
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 554
		local mode = req.mode -- 565
		if mode ~= "lua" and mode ~= "git" then -- 565
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 565
		end -- 565
		if mode == "lua" then -- 565
			return ____awaiter_resolve( -- 565
				nil, -- 565
				executeLuaCommand({ -- 570
					workDir = req.workDir, -- 571
					code = req.code or "", -- 572
					timeoutSeconds = math.max( -- 573
						1, -- 573
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 573
					), -- 573
					operationId = createOperationId(), -- 574
					taskId = req.taskId or 0, -- 575
					onProgress = req.onProgress, -- 576
					isCancelled = req.isCancelled -- 577
				}) -- 577
			) -- 577
		end -- 577
		local operationId = createOperationId() -- 580
		return ____awaiter_resolve( -- 580
			nil, -- 580
			executeGitCommand({ -- 581
				workDir = req.workDir, -- 582
				command = req.command or "", -- 583
				cwd = req.cwd, -- 584
				timeoutSeconds = math.max( -- 585
					1, -- 585
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 585
				), -- 585
				operationId = operationId, -- 586
				onProgress = req.onProgress, -- 587
				isCancelled = req.isCancelled -- 588
			}) -- 588
		) -- 588
	end) -- 588
end -- 554
return ____exports -- 554
