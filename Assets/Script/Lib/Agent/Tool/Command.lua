-- [ts]: Command.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
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
	local usesPreviewGame = (string.match(req.code, "%f[%a_]previewGame%f[^%w_]%s*%(")) ~= nil -- 50
	if type(_studio_agent_tool_begin) ~= "function" or usesPreviewGame then -- 50
		return nil -- 51
	end -- 51
	local onProgress = req.onProgress -- 52
	local isCancelled = req.isCancelled -- 53
	return __TS__New( -- 54
		__TS__Promise, -- 54
		function(____, resolve) -- 54
			local requestId -- 55
			local settled = false -- 56
			local function finish(result) -- 57
				if settled then -- 57
					return -- 58
				end -- 58
				settled = true -- 59
				resolve(nil, result) -- 60
			end -- 57
			if onProgress ~= nil then -- 57
				onProgress(nil, { -- 62
					state = "pending", -- 62
					mode = "lua", -- 62
					operationId = req.operationId, -- 62
					stage = "player", -- 62
					message = "Lua command pending in isolated game Player" -- 62
				}) -- 62
			end -- 62
			local routine = once(function() -- 63
				do -- 63
					local function ____catch(e) -- 63
						if requestId then -- 63
							if _studio_agent_tool_cancel ~= nil then -- 63
								_studio_agent_tool_cancel(requestId) -- 87
							end -- 87
							requestId = nil -- 87
						end -- 87
						local message = truncateCommandError(toStr(e)) -- 88
						local ____message_9 = message -- 89
						local ____temp_10 = (string.find(message, "timed out", nil, true) or 0) - 1 >= 0 and "timeout" or "execute" -- 89
						local ____temp_8 -- 89
						if (string.find(message, "canceled", nil, true) or 0) - 1 >= 0 then -- 89
							____temp_8 = true -- 89
						else -- 89
							____temp_8 = nil -- 89
						end -- 89
						finish({ -- 89
							success = false, -- 89
							mode = "lua", -- 89
							output = "", -- 89
							message = ____message_9, -- 89
							phase = ____temp_10, -- 89
							interrupted = ____temp_8 -- 89
						}) -- 89
					end -- 89
					local ____try, ____hasReturned = pcall(function() -- 89
						local options = safeJsonEncode({code = req.code, timeoutSeconds = req.timeoutSeconds}) -- 65
						if not options then -- 65
							error("failed to encode Studio Agent Lua command") -- 66
						end -- 66
						requestId = _studio_agent_tool_begin( -- 67
							"execute-lua", -- 67
							Path(req.workDir, ".agent", "command.lua"), -- 67
							options, -- 67
							req.workDir -- 67
						) -- 67
						if onProgress ~= nil then -- 67
							onProgress(nil, { -- 68
								state = "running", -- 68
								mode = "lua", -- 68
								operationId = req.operationId, -- 68
								stage = "player", -- 68
								message = "Lua command running in isolated game Player" -- 68
							}) -- 68
						end -- 68
						local deadline = App.runningTime + req.timeoutSeconds -- 69
						local answer -- 70
						while not answer do -- 70
							if isCancelled and isCancelled(nil) then -- 70
								error("Lua command canceled") -- 72
							end -- 72
							if App.runningTime >= deadline then -- 72
								error(("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds") -- 73
							end -- 73
							answer = _studio_agent_tool_poll and _studio_agent_tool_poll(requestId) -- 74
							if not answer then -- 74
								sleep() -- 75
							end -- 75
						end -- 75
						requestId = nil -- 77
						if not answer.success then -- 77
							error(answer.message or "Studio Agent Lua Player failed") -- 78
						end -- 78
						local decoded = safeJsonDecode(answer.resultJSON or "") -- 79
						local value = decoded -- 80
						if not value or type(value.success) ~= "boolean" or type(value.output) ~= "string" or value.message ~= nil and type(value.message) ~= "string" or value.phase ~= nil and value.phase ~= "compile" and value.phase ~= "execute" and value.phase ~= "timeout" and value.phase ~= "validate" then -- 80
							error("Invalid Studio Agent Lua Player result") -- 83
						end -- 83
						if value.success then -- 83
							finish({ -- 84
								success = true, -- 84
								mode = "lua", -- 84
								output = truncateCommandOutput(value.output) -- 84
							}) -- 84
						else -- 84
							finish({ -- 85
								success = false, -- 85
								mode = "lua", -- 85
								output = truncateCommandOutput(value.output), -- 85
								message = truncateCommandError(value.message or "Lua command failed"), -- 85
								phase = value.phase or "execute" -- 85
							}) -- 85
						end -- 85
					end) -- 85
					if not ____try then -- 85
						____catch(____hasReturned) -- 85
					end -- 85
				end -- 85
			end) -- 63
			Director.systemScheduler:schedule(function() -- 92
				if settled then -- 92
					return true -- 93
				end -- 93
				local ok, result = coroutine.resume(routine) -- 94
				if not ok then -- 94
					finish({ -- 95
						success = false, -- 95
						mode = "lua", -- 95
						output = "", -- 95
						message = truncateCommandError(toStr(result)), -- 95
						phase = "execute" -- 95
					}) -- 95
					return true -- 95
				end -- 95
				return settled or result == true -- 96
			end) -- 92
		end -- 54
	) -- 54
end -- 38
local function executeLuaCommand(req) -- 102
	local code = __TS__StringTrim(req.code or "") -- 111
	if code == "" then -- 111
		return __TS__Promise.resolve({ -- 113
			success = false, -- 113
			mode = "lua", -- 113
			output = "", -- 113
			message = "missing code", -- 113
			phase = "validate" -- 113
		}) -- 113
	end -- 113
	local studioResult = executeStudioLuaCommand(__TS__ObjectAssign({}, req, {code = code})) -- 115
	if studioResult then -- 115
		return studioResult -- 116
	end -- 116
	local output = {} -- 117
	local entry = require("Script.Dev.Entry") -- 118
	local ownsEntryRuntime = false -- 119
	local contentAccessed = false -- 120
	local refreshTreeCalled = false -- 121
	local entryObjectBaseline = 0 -- 122
	local entryLuaRefBaseline = 0 -- 123
	local persistedVisionUsage -- 124
	local capturedBatches = 0 -- 125
	local capturedFrames = 0 -- 126
	local lastPreviewResult -- 127
	local previewCleanup -- 128
	local restorePrint -- 129
	local function currentVisionUsage() -- 130
		if persistedVisionUsage == nil then -- 130
			persistedVisionUsage = getVisionTaskUsage(req.taskId) -- 131
		end -- 131
		return __TS__ObjectAssign({}, persistedVisionUsage, {captureBatchCount = persistedVisionUsage.captureBatchCount + capturedBatches, captureFrameCount = persistedVisionUsage.captureFrameCount + capturedFrames}) -- 132
	end -- 130
	local function reserveCapture(frameCount) -- 138
		local current = currentVisionUsage() -- 139
		if current.captureBatchCount >= VISION_MAX_CAPTURE_BATCHES or current.captureFrameCount + frameCount > VISION_MAX_CAPTURE_FRAMES then -- 139
			return { -- 141
				success = false, -- 142
				message = ((("Vision capture budget exhausted: " .. tostring(current.captureBatchCount)) .. " batches and ") .. tostring(current.captureFrameCount)) .. " frames already reserved", -- 143
				budget = getVisionBudgetState(current) -- 144
			} -- 144
		end -- 144
		capturedBatches = capturedBatches + 1 -- 147
		capturedFrames = capturedFrames + frameCount -- 148
		return { -- 149
			success = true, -- 149
			budget = getVisionBudgetState(currentVisionUsage()) -- 149
		} -- 149
	end -- 138
	local function acquireEntryRuntime() -- 151
		acquireEntryLease(req.operationId, entry) -- 152
		ownsEntryRuntime = true -- 153
	end -- 151
	local function stopOwnedEntry() -- 155
		if not ownsEntryRuntime then -- 155
			return nil -- 156
		end -- 156
		ownsEntryRuntime = false -- 157
		return releaseEntryLease(req.operationId, entry) -- 158
	end -- 155
	local function startEntryWatchdog() -- 160
		entryObjectBaseline = Dora.Object.count -- 161
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 162
	end -- 160
	local function checkEntryWatchdog() -- 164
		if not ownsEntryRuntime then -- 164
			return nil -- 165
		end -- 165
		local objectCount = Dora.Object.count -- 166
		local luaRefCount = Dora.Object.luaRefCount -- 167
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 168
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 169
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 170
		if not exceededTotal then -- 170
			return nil -- 173
		end -- 173
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 174
	end -- 164
	local function normalizeEntryFile(value) -- 178
		if not value or type(value) ~= "table" then -- 178
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 180
		end -- 180
		local descriptor = value -- 182
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 183
		if relativeFile == "" then -- 183
			relativeFile = "init" -- 184
		end -- 184
		if not isValidWorkspacePath(relativeFile) then -- 184
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 186
		end -- 186
		local fileName = Path(req.workDir, relativeFile) -- 188
		local ext = Path:getExt(fileName) -- 189
		if ext ~= "" then -- 189
			fileName = Path:replaceExt(fileName, "") -- 190
		end -- 190
		local luaFile = Path:replaceExt(fileName, "lua") -- 191
		if not Content:exist(luaFile) then -- 191
			error("Agent test entry was not built: " .. luaFile) -- 193
		end -- 193
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 195
		return { -- 196
			fileName = fileName, -- 197
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 198
		} -- 198
	end -- 178
	local function capturePrint(...) -- 201
		local values = {...} -- 201
		local parts = {} -- 202
		do -- 202
			local i = 0 -- 203
			while i < #values do -- 203
				parts[#parts + 1] = tostring(values[i + 1]) -- 204
				i = i + 1 -- 203
			end -- 203
		end -- 203
		output[#output + 1] = table.concat(parts, "\t") -- 206
	end -- 201
	local function refreshTree(path) -- 208
		refreshTreeCalled = true -- 209
		if path == nil then -- 209
			return refreshWorkspaceTree(req.workDir) -- 211
		end -- 211
		if type(path) ~= "string" then -- 211
			error("refreshTree expects a project-relative file path string or no argument") -- 214
		end -- 214
		return refreshWorkspaceTree(req.workDir, path) -- 216
	end -- 208
	local function resolveLuaContentPath(first, second) -- 218
		local value = type(second) == "string" and second or first -- 219
		if type(value) ~= "string" then -- 219
			error("Content path must be a project-relative string") -- 221
		end -- 221
		local fullPath = resolveWorkspaceFilePath(req.workDir, value) -- 223
		if not fullPath then -- 223
			error("Content path must stay inside projectDir") -- 225
		end -- 225
		return fullPath -- 227
	end -- 218
	local scopedContent = { -- 229
		exist = function(first, second) return Content:exist(resolveLuaContentPath(first, second)) end, -- 230
		isdir = function(first, second) return Content:isdir(resolveLuaContentPath(first, second)) end, -- 231
		getAttr = function(first, second) return Content:getAttr(resolveLuaContentPath(first, second)) end, -- 232
		load = function(first, second) -- 233
			local fullPath = resolveLuaContentPath(first, second) -- 234
			local inspected = inspectReadableFile(fullPath) -- 235
			if not inspected.success then -- 235
				error(inspected.message or "file is not readable") -- 236
			end -- 236
			return Content:load(fullPath) -- 237
		end -- 233
	} -- 233
	local blockedDoraGlobals = {Content = true, DB = true, HttpClient = true, HttpServer = true} -- 240
	local env = setmetatable( -- 246
		{ -- 246
			projectDir = req.workDir, -- 247
			previewGame = createPreviewGameInjection( -- 248
				{ -- 248
					workDir = req.workDir, -- 249
					operationId = req.operationId, -- 250
					isCancelled = req.isCancelled, -- 251
					print = function(line) return capturePrint(line) end, -- 252
					reserveCapture = reserveCapture, -- 253
					registerCleanup = function(cleanup) -- 254
						previewCleanup = cleanup -- 254
					end, -- 254
					onResult = function(result) -- 255
						lastPreviewResult = result -- 256
					end -- 255
				}, -- 255
				entry -- 258
			), -- 258
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 259
				if type(moduleNameValue) ~= "string" then -- 259
					error("requireProjectModule expects a project module name string") -- 261
				end -- 261
				local moduleName = __TS__StringTrim(moduleNameValue) -- 263
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 263
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 265
				end -- 265
				local reloadModules = {moduleName} -- 267
				if reloadModulesValue ~= nil then -- 267
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 267
						error("requireProjectModule reloadModules must be an array of module names") -- 270
					end -- 270
					local items = reloadModulesValue -- 272
					do -- 272
						local i = 0 -- 273
						while i < #items do -- 273
							local item = items[i + 1] -- 274
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 274
								error("requireProjectModule reloadModules contains an invalid module name") -- 276
							end -- 276
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 276
								reloadModules[#reloadModules + 1] = item -- 278
							end -- 278
							i = i + 1 -- 273
						end -- 273
					end -- 273
				end -- 273
				local luaPackage = _G.package -- 281
				local previousPath = luaPackage.path -- 285
				local previousSearchPaths = Content.searchPaths -- 286
				local scopedSearchPaths = {req.workDir} -- 287
				do -- 287
					local i = 0 -- 288
					while i < #previousSearchPaths do -- 288
						local searchPath = previousSearchPaths[i + 1] -- 289
						if searchPath ~= req.workDir then -- 289
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 290
						end -- 290
						i = i + 1 -- 288
					end -- 288
				end -- 288
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 292
				Content.searchPaths = scopedSearchPaths -- 293
				do -- 293
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 293
						do -- 293
							local i = 0 -- 295
							while i < #reloadModules do -- 295
								local reloadName = reloadModules[i + 1] -- 296
								luaPackage.loaded[reloadName] = nil -- 297
								luaPackage.loaded[table.concat( -- 298
									__TS__StringSplit(reloadName, "/"), -- 298
									"." -- 298
								)] = nil -- 298
								luaPackage.loaded[table.concat( -- 299
									__TS__StringSplit(reloadName, "."), -- 299
									"/" -- 299
								)] = nil -- 299
								i = i + 1 -- 295
							end -- 295
						end -- 295
						return true, require(table.concat( -- 301
							__TS__StringSplit(moduleName, "/"), -- 301
							"." -- 301
						)) -- 301
					end) -- 301
					do -- 301
						Content.searchPaths = previousSearchPaths -- 303
						luaPackage.path = previousPath -- 304
					end -- 304
					if not ____try then -- 304
						error(____hasReturned, 0) -- 304
					end -- 304
					if ____try and ____hasReturned then -- 304
						return ____returnValue -- 294
					end -- 294
				end -- 294
			end, -- 259
			print = capturePrint, -- 307
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 308
			enterEntryAsync = function(value) -- 309
				local normalized = normalizeEntryFile(value) -- 310
				acquireEntryRuntime() -- 311
				entry.allClear() -- 312
				startEntryWatchdog() -- 313
				recordEntryLeaseRun(req.operationId, entry) -- 314
				local success, message = entry.enterEntryAsync({ -- 315
					entryName = normalized.entryName, -- 316
					fileName = normalized.fileName, -- 317
					workDir = req.workDir, -- 318
					projectRoot = req.workDir, -- 319
					runKind = "agent_test" -- 320
				}) -- 320
				return success, message -- 322
			end, -- 309
			stopEntry = function() -- 324
				if not ownsEntryRuntime or not ownsEntryLease(req.operationId, entry) then -- 324
					return false -- 325
				end -- 325
				return entry.stop() -- 326
			end, -- 324
			reportProgress = function(value, callbackValue) -- 328
				local ____callbackValue_11 = callbackValue -- 329
				if ____callbackValue_11 == nil then -- 329
					____callbackValue_11 = value -- 329
				end -- 329
				local actualValue = ____callbackValue_11 -- 329
				if not req.onProgress or not actualValue or type(actualValue) ~= "table" then -- 329
					return -- 330
				end -- 330
				local progress = actualValue -- 331
				local amount = type(progress.progress) == "number" and math.min( -- 332
					1, -- 333
					math.max(0, progress.progress) -- 333
				) or nil -- 333
				req:onProgress({ -- 335
					state = "running", -- 336
					mode = "lua", -- 337
					operationId = req.operationId, -- 338
					progress = amount, -- 339
					stage = type(progress.stage) == "string" and progress.stage or "lua", -- 340
					message = type(progress.message) == "string" and progress.message or "Lua command running" -- 341
				}) -- 341
			end -- 328
		}, -- 328
		{__index = function(_table, key) -- 344
			if key == "Content" then -- 344
				contentAccessed = true -- 347
				return scopedContent -- 348
			end -- 348
			if key == "refreshTree" then -- 348
				return refreshTree -- 351
			end -- 351
			local name = tostring(key) -- 353
			if blockedDoraGlobals[name] then -- 353
				return nil -- 354
			end -- 354
			return Dora[name] -- 355
		end} -- 345
	) -- 345
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 358
	if not fn then -- 358
		return __TS__Promise.resolve({ -- 360
			success = false, -- 361
			mode = "lua", -- 362
			output = truncateCommandOutput(table.concat(output, "\n")), -- 363
			message = truncateCommandError(toStr(compileErr)), -- 364
			phase = "compile" -- 365
		}) -- 365
	end -- 365
	return __TS__New( -- 368
		__TS__Promise, -- 368
		function(____, resolve) -- 368
			local settled = false -- 369
			local commandRoutine -- 370
			local startedAt = App.runningTime -- 371
			local onProgress = req.onProgress -- 372
			local isCancelled = req.isCancelled -- 373
			local function finish(result) -- 374
				if settled then -- 374
					return -- 375
				end -- 375
				settled = true -- 376
				local cleanupError -- 377
				local cleanup = previewCleanup -- 378
				previewCleanup = nil -- 379
				do -- 379
					local function ____catch(e) -- 379
						cleanupError = "failed to release Agent preview: " .. tostring(e) -- 381
					end -- 381
					local ____try, ____hasReturned = pcall(function() -- 381
						if cleanup ~= nil then -- 381
							cleanup() -- 380
						end -- 380
					end) -- 380
					if not ____try then -- 380
						____catch(____hasReturned) -- 380
					end -- 380
				end -- 380
				if restorePrint ~= nil then -- 380
					restorePrint() -- 382
				end -- 382
				restorePrint = nil -- 383
				if not result.success and (result.interrupted == true or result.phase == "timeout") and (not entry.getCurrentEntryStatus().running or ownsEntryLease(req.operationId, entry)) then -- 383
					do -- 383
						local function ____catch(e) -- 383
							cleanupError = "failed to clear interrupted Lua command runtime: " .. tostring(e) -- 389
						end -- 389
						local ____try, ____hasReturned = pcall(function() -- 389
							entry.allClear() -- 387
						end) -- 387
						if not ____try then -- 387
							____catch(____hasReturned) -- 387
						end -- 387
					end -- 387
				end -- 387
				local entryCleanupError = stopOwnedEntry() -- 392
				if cleanupError == nil then -- 392
					cleanupError = entryCleanupError -- 393
				end -- 393
				if contentAccessed and not refreshTreeCalled and not refreshWorkspaceTree(req.workDir) then -- 393
					Log("Warn", "[execute_command] failed to refresh Web IDE tree after Lua command workDir=" .. req.workDir) -- 395
				end -- 395
				local ____lastPreviewResult_21 -- 397
				if lastPreviewResult then -- 397
					local ____lastPreviewResult_success_18 = lastPreviewResult.success -- 398
					local ____lastPreviewResult_message_19 = lastPreviewResult.message -- 399
					local ____lastPreviewResult_files_20 = lastPreviewResult.files -- 400
					local ____opt_16 = lastPreviewResult.frames -- 400
					____lastPreviewResult_21 = {success = ____lastPreviewResult_success_18, message = ____lastPreviewResult_message_19, files = ____lastPreviewResult_files_20, frameCount = ____opt_16 and #____opt_16} -- 397
				else -- 397
					____lastPreviewResult_21 = nil -- 402
				end -- 402
				local previewGame = ____lastPreviewResult_21 -- 397
				local visionFields = __TS__ObjectAssign( -- 403
					{}, -- 403
					previewGame and ({previewGame = previewGame}) or ({}), -- 404
					capturedBatches > 0 and ({ -- 405
						visionCapture = {batchCount = capturedBatches, frameCount = capturedFrames}, -- 406
						visionBudget = getVisionBudgetState(currentVisionUsage()) -- 407
					}) or ({}) -- 407
				) -- 407
				if not result.success and cleanupError ~= nil then -- 407
					result.cleanupError = cleanupError -- 411
				elseif result.success and cleanupError ~= nil then -- 411
					resolve( -- 413
						nil, -- 413
						__TS__ObjectAssign({ -- 413
							success = false, -- 414
							mode = "lua", -- 415
							output = result.output, -- 416
							message = cleanupError, -- 417
							phase = "execute", -- 418
							cleanupError = cleanupError -- 419
						}, visionFields) -- 419
					) -- 419
					return -- 422
				end -- 422
				if result.success and lastPreviewResult and not lastPreviewResult.success then -- 422
					resolve( -- 425
						nil, -- 425
						__TS__ObjectAssign({ -- 425
							success = false, -- 426
							mode = "lua", -- 427
							output = result.output, -- 428
							message = "previewGame failed: " .. (lastPreviewResult.message or "unknown error"), -- 429
							phase = "execute" -- 430
						}, visionFields) -- 430
					) -- 430
					return -- 433
				end -- 433
				resolve( -- 435
					nil, -- 435
					__TS__ObjectAssign({}, result, visionFields) -- 435
				) -- 435
			end -- 374
			if onProgress then -- 374
				onProgress(nil, { -- 441
					state = "pending", -- 442
					mode = "lua", -- 443
					operationId = req.operationId, -- 444
					stage = "lua", -- 445
					message = "Lua command pending" -- 446
				}) -- 446
			end -- 446
			commandRoutine = once(function() -- 449
				if settled then -- 449
					return -- 450
				end -- 450
				if onProgress then -- 450
					onProgress(nil, { -- 452
						state = "running", -- 453
						mode = "lua", -- 454
						operationId = req.operationId, -- 455
						stage = "lua", -- 456
						message = "Lua command running" -- 457
					}) -- 457
				end -- 457
				local previousGlobalPrint = _G.print -- 460
				restorePrint = function() -- 461
					if _G.print == capturePrint then -- 461
						_G.print = previousGlobalPrint -- 461
					end -- 461
				end -- 461
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 462
				local frameTimedOut = false -- 463
				local watchdogMessage -- 463
				_G.print = capturePrint -- 464
				debug.sethook( -- 465
					function() -- 465
						if watchdogMessage == nil then -- 465
							watchdogMessage = checkEntryWatchdog() -- 466
						end -- 466
						if watchdogMessage ~= nil then -- 466
							error(watchdogMessage) -- 467
						end -- 467
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 467
							frameTimedOut = true -- 469
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 470
						end -- 470
					end, -- 465
					"", -- 472
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 472
				) -- 472
				local ok, runtimeErr = pcall(fn) -- 473
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 473
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 475
				else -- 475
					debug.sethook() -- 481
				end -- 481
				_G.print = previousGlobalPrint -- 483
				if not ok then -- 483
					local ____truncateCommandOutput_result_23 = truncateCommandOutput(table.concat(output, "\n")) -- 488
					local ____temp_24 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 489
					local ____temp_25 = frameTimedOut and "timeout" or "execute" -- 490
					local ____temp_22 -- 491
					if watchdogMessage ~= nil or frameTimedOut then -- 491
						____temp_22 = true -- 491
					else -- 491
						____temp_22 = nil -- 491
					end -- 491
					finish({ -- 485
						success = false, -- 486
						mode = "lua", -- 487
						output = ____truncateCommandOutput_result_23, -- 488
						message = ____temp_24, -- 489
						phase = ____temp_25, -- 490
						interrupted = ____temp_22 -- 491
					}) -- 491
					return -- 493
				end -- 493
				finish({ -- 495
					success = true, -- 495
					mode = "lua", -- 495
					output = truncateCommandOutput(table.concat(output, "\n")) -- 495
				}) -- 495
			end) -- 449
			Director.systemScheduler:schedule(function() -- 497
				if settled then -- 497
					return true -- 498
				end -- 498
				local watchdogMessage = checkEntryWatchdog() -- 499
				if watchdogMessage ~= nil then -- 499
					finish({ -- 501
						success = false, -- 502
						mode = "lua", -- 503
						output = truncateCommandOutput(table.concat(output, "\n")), -- 504
						message = watchdogMessage, -- 505
						phase = "execute", -- 506
						interrupted = true -- 507
					}) -- 507
					return true -- 509
				end -- 509
				if isCancelled and isCancelled(nil) then -- 509
					finish({ -- 512
						success = false, -- 513
						mode = "lua", -- 514
						output = truncateCommandOutput(table.concat(output, "\n")), -- 515
						message = "Lua command canceled", -- 516
						phase = "execute", -- 517
						interrupted = true -- 518
					}) -- 518
					return true -- 520
				end -- 520
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 520
					finish({ -- 523
						success = false, -- 524
						mode = "lua", -- 525
						output = truncateCommandOutput(table.concat(output, "\n")), -- 526
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 527
						phase = "timeout" -- 528
					}) -- 528
					return true -- 530
				end -- 530
				if commandRoutine == nil then -- 530
					finish({ -- 533
						success = false, -- 534
						mode = "lua", -- 535
						output = truncateCommandOutput(table.concat(output, "\n")), -- 536
						message = "Lua command coroutine is unavailable", -- 537
						phase = "execute" -- 538
					}) -- 538
					return true -- 540
				end -- 540
				local resumeSuccess, resumeResult = coroutine.resume(commandRoutine) -- 542
				if not resumeSuccess then -- 542
					finish({ -- 544
						success = false, -- 545
						mode = "lua", -- 546
						output = truncateCommandOutput(table.concat(output, "\n")), -- 547
						message = truncateCommandError(toStr(resumeResult)), -- 548
						phase = "execute" -- 549
					}) -- 549
					return true -- 551
				end -- 551
				return settled or resumeResult == true -- 553
			end) -- 497
		end -- 368
	) -- 368
end -- 102
function ____exports.executeCommand(req) -- 558
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 558
		local mode = req.mode -- 569
		if mode ~= "lua" and mode ~= "git" then -- 569
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 569
		end -- 569
		if mode == "lua" then -- 569
			return ____awaiter_resolve( -- 569
				nil, -- 569
				executeLuaCommand({ -- 574
					workDir = req.workDir, -- 575
					code = req.code or "", -- 576
					timeoutSeconds = math.max( -- 577
						1, -- 577
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 577
					), -- 577
					operationId = createOperationId(), -- 578
					taskId = req.taskId or 0, -- 579
					onProgress = req.onProgress, -- 580
					isCancelled = req.isCancelled -- 581
				}) -- 581
			) -- 581
		end -- 581
		local operationId = createOperationId() -- 584
		return ____awaiter_resolve( -- 584
			nil, -- 584
			executeGitCommand({ -- 585
				workDir = req.workDir, -- 586
				command = req.command or "", -- 587
				cwd = req.cwd, -- 588
				timeoutSeconds = math.max( -- 589
					1, -- 589
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 589
				), -- 589
				operationId = operationId, -- 590
				onProgress = req.onProgress, -- 591
				isCancelled = req.isCancelled -- 592
			}) -- 592
		) -- 592
	end) -- 592
end -- 558
return ____exports -- 558