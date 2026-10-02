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
local isValidWorkspacePath = ____Workspace.isValidWorkspacePath -- 12
local ____CommandContent = require("Agent.Tool.CommandContent") -- 13
local createCommandContent = ____CommandContent.createCommandContent -- 13
local ____EntryLease = require("Agent.Tool.EntryLease") -- 15
local acquireEntryLease = ____EntryLease.acquireEntryLease -- 15
local recordEntryLeaseRun = ____EntryLease.recordEntryLeaseRun -- 15
local ownsEntryLease = ____EntryLease.ownsEntryLease -- 15
local releaseEntryLease = ____EntryLease.releaseEntryLease -- 15
local ____CommandPreview = require("Agent.Tool.CommandPreview") -- 16
local createPreviewGameInjection = ____CommandPreview.createPreviewGameInjection -- 16
local ____VisionBudget = require("Agent.Tool.VisionBudget") -- 17
local getVisionBudgetState = ____VisionBudget.getVisionBudgetState -- 18
local getVisionTaskUsage = ____VisionBudget.getVisionTaskUsage -- 19
local VISION_MAX_CAPTURE_BATCHES = ____VisionBudget.VISION_MAX_CAPTURE_BATCHES -- 21
local VISION_MAX_CAPTURE_FRAMES = ____VisionBudget.VISION_MAX_CAPTURE_FRAMES -- 22
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 26
local function executeStudioLuaCommand(req) -- 35
	local usesPreviewGame = (string.match(req.code, "%f[%a_]previewGame%f[^%w_]%s*%(")) ~= nil -- 47
	if type(_studio_agent_tool_begin) ~= "function" or usesPreviewGame then -- 47
		return nil -- 48
	end -- 48
	local onProgress = req.onProgress -- 49
	local isCancelled = req.isCancelled -- 50
	return __TS__New( -- 51
		__TS__Promise, -- 51
		function(____, resolve) -- 51
			local requestId -- 52
			local settled = false -- 53
			local function finish(result) -- 54
				if settled then -- 54
					return -- 55
				end -- 55
				settled = true -- 56
				resolve(nil, result) -- 57
			end -- 54
			if onProgress ~= nil then -- 54
				onProgress(nil, { -- 59
					state = "pending", -- 59
					mode = "lua", -- 59
					operationId = req.operationId, -- 59
					stage = "player", -- 59
					message = "Lua command pending in isolated game Player" -- 59
				}) -- 59
			end -- 59
			local routine = once(function() -- 60
				do -- 60
					local function ____catch(e) -- 60
						if requestId then -- 60
							if _studio_agent_tool_cancel ~= nil then -- 60
								_studio_agent_tool_cancel(requestId) -- 84
							end -- 84
							requestId = nil -- 84
						end -- 84
						local message = truncateCommandError(toStr(e)) -- 85
						local ____message_9 = message -- 86
						local ____temp_10 = (string.find(message, "timed out", nil, true) or 0) - 1 >= 0 and "timeout" or "execute" -- 86
						local ____temp_8 -- 86
						if (string.find(message, "canceled", nil, true) or 0) - 1 >= 0 then -- 86
							____temp_8 = true -- 86
						else -- 86
							____temp_8 = nil -- 86
						end -- 86
						finish({ -- 86
							success = false, -- 86
							mode = "lua", -- 86
							output = "", -- 86
							message = ____message_9, -- 86
							phase = ____temp_10, -- 86
							interrupted = ____temp_8 -- 86
						}) -- 86
					end -- 86
					local ____try, ____hasReturned = pcall(function() -- 86
						local options = safeJsonEncode({code = req.code, timeoutSeconds = req.timeoutSeconds}) -- 62
						if not options then -- 62
							error("failed to encode Studio Agent Lua command") -- 63
						end -- 63
						requestId = _studio_agent_tool_begin( -- 64
							"execute-lua", -- 64
							Path(req.workDir, ".agent", "command.lua"), -- 64
							options, -- 64
							req.workDir -- 64
						) -- 64
						if onProgress ~= nil then -- 64
							onProgress(nil, { -- 65
								state = "running", -- 65
								mode = "lua", -- 65
								operationId = req.operationId, -- 65
								stage = "player", -- 65
								message = "Lua command running in isolated game Player" -- 65
							}) -- 65
						end -- 65
						local deadline = App.runningTime + req.timeoutSeconds -- 66
						local answer -- 67
						while not answer do -- 67
							if isCancelled and isCancelled(nil) then -- 67
								error("Lua command canceled") -- 69
							end -- 69
							if App.runningTime >= deadline then -- 69
								error(("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds") -- 70
							end -- 70
							answer = _studio_agent_tool_poll and _studio_agent_tool_poll(requestId) -- 71
							if not answer then -- 71
								sleep() -- 72
							end -- 72
						end -- 72
						requestId = nil -- 74
						if not answer.success then -- 74
							error(answer.message or "Studio Agent Lua Player failed") -- 75
						end -- 75
						local decoded = safeJsonDecode(answer.resultJSON or "") -- 76
						local value = decoded -- 77
						if not value or type(value.success) ~= "boolean" or type(value.output) ~= "string" or value.message ~= nil and type(value.message) ~= "string" or value.phase ~= nil and value.phase ~= "compile" and value.phase ~= "execute" and value.phase ~= "timeout" and value.phase ~= "validate" then -- 77
							error("Invalid Studio Agent Lua Player result") -- 80
						end -- 80
						if value.success then -- 80
							finish({ -- 81
								success = true, -- 81
								mode = "lua", -- 81
								output = truncateCommandOutput(value.output) -- 81
							}) -- 81
						else -- 81
							finish({ -- 82
								success = false, -- 82
								mode = "lua", -- 82
								output = truncateCommandOutput(value.output), -- 82
								message = truncateCommandError(value.message or "Lua command failed"), -- 82
								phase = value.phase or "execute" -- 82
							}) -- 82
						end -- 82
					end) -- 82
					if not ____try then -- 82
						____catch(____hasReturned) -- 82
					end -- 82
				end -- 82
			end) -- 60
			Director.systemScheduler:schedule(function() -- 89
				if settled then -- 89
					return true -- 90
				end -- 90
				local ok, result = coroutine.resume(routine) -- 91
				if not ok then -- 91
					finish({ -- 92
						success = false, -- 92
						mode = "lua", -- 92
						output = "", -- 92
						message = truncateCommandError(toStr(result)), -- 92
						phase = "execute" -- 92
					}) -- 92
					return true -- 92
				end -- 92
				return settled or result == true -- 93
			end) -- 89
		end -- 51
	) -- 51
end -- 35
local function executeLuaCommand(req) -- 99
	local code = __TS__StringTrim(req.code or "") -- 109
	if code == "" then -- 109
		return __TS__Promise.resolve({ -- 111
			success = false, -- 111
			mode = "lua", -- 111
			output = "", -- 111
			message = "missing code", -- 111
			phase = "validate" -- 111
		}) -- 111
	end -- 111
	local studioResult = executeStudioLuaCommand(__TS__ObjectAssign({}, req, {code = code})) -- 113
	if studioResult then -- 113
		return studioResult -- 114
	end -- 114
	local output = {} -- 115
	local entry = require("Script.Dev.Entry") -- 116
	local ownsEntryRuntime = false -- 117
	local contentAccessed = false -- 118
	local refreshTreeCalled = false -- 119
	local entryObjectBaseline = 0 -- 120
	local entryLuaRefBaseline = 0 -- 121
	local persistedVisionUsage -- 122
	local capturedBatches = 0 -- 123
	local capturedFrames = 0 -- 124
	local lastPreviewResult -- 125
	local previewCleanup -- 126
	local restorePrint -- 127
	local function currentVisionUsage() -- 128
		if persistedVisionUsage == nil then -- 128
			persistedVisionUsage = getVisionTaskUsage(req.taskId) -- 129
		end -- 129
		return __TS__ObjectAssign({}, persistedVisionUsage, {captureBatchCount = persistedVisionUsage.captureBatchCount + capturedBatches, captureFrameCount = persistedVisionUsage.captureFrameCount + capturedFrames}) -- 130
	end -- 128
	local function reserveCapture(frameCount) -- 136
		local current = currentVisionUsage() -- 137
		if current.captureBatchCount >= VISION_MAX_CAPTURE_BATCHES or current.captureFrameCount + frameCount > VISION_MAX_CAPTURE_FRAMES then -- 137
			return { -- 139
				success = false, -- 140
				message = ((("Vision capture budget exhausted: " .. tostring(current.captureBatchCount)) .. " batches and ") .. tostring(current.captureFrameCount)) .. " frames already reserved", -- 141
				budget = getVisionBudgetState(current) -- 142
			} -- 142
		end -- 142
		capturedBatches = capturedBatches + 1 -- 145
		capturedFrames = capturedFrames + frameCount -- 146
		return { -- 147
			success = true, -- 147
			budget = getVisionBudgetState(currentVisionUsage()) -- 147
		} -- 147
	end -- 136
	local function acquireEntryRuntime() -- 149
		acquireEntryLease(req.operationId, entry) -- 150
		ownsEntryRuntime = true -- 151
	end -- 149
	local function stopOwnedEntry() -- 153
		if not ownsEntryRuntime then -- 153
			return nil -- 154
		end -- 154
		ownsEntryRuntime = false -- 155
		return releaseEntryLease(req.operationId, entry) -- 156
	end -- 153
	local function startEntryWatchdog() -- 158
		entryObjectBaseline = Dora.Object.count -- 159
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 160
	end -- 158
	local function checkEntryWatchdog() -- 162
		if not ownsEntryRuntime then -- 162
			return nil -- 163
		end -- 163
		local objectCount = Dora.Object.count -- 164
		local luaRefCount = Dora.Object.luaRefCount -- 165
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 166
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 167
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 168
		if not exceededTotal then -- 168
			return nil -- 171
		end -- 171
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 172
	end -- 162
	local function normalizeEntryFile(value) -- 176
		if not value or type(value) ~= "table" then -- 176
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 178
		end -- 178
		local descriptor = value -- 180
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 181
		if relativeFile == "" then -- 181
			relativeFile = "init" -- 182
		end -- 182
		if not isValidWorkspacePath(relativeFile) then -- 182
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 184
		end -- 184
		local fileName = Path(req.workDir, relativeFile) -- 186
		local ext = Path:getExt(fileName) -- 187
		if ext ~= "" then -- 187
			fileName = Path:replaceExt(fileName, "") -- 188
		end -- 188
		local luaFile = Path:replaceExt(fileName, "lua") -- 189
		if not Content:exist(luaFile) then -- 189
			error("Agent test entry was not built: " .. luaFile) -- 191
		end -- 191
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 193
		return { -- 194
			fileName = fileName, -- 195
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 196
		} -- 196
	end -- 176
	local function capturePrint(...) -- 199
		local values = {...} -- 199
		local parts = {} -- 200
		do -- 200
			local i = 0 -- 201
			while i < #values do -- 201
				parts[#parts + 1] = tostring(values[i + 1]) -- 202
				i = i + 1 -- 201
			end -- 201
		end -- 201
		output[#output + 1] = table.concat(parts, "\t") -- 204
	end -- 199
	local function refreshTree(path) -- 206
		refreshTreeCalled = true -- 207
		if path == nil then -- 207
			return refreshWorkspaceTree(req.workDir) -- 209
		end -- 209
		if type(path) ~= "string" then -- 209
			error("refreshTree expects a project-relative file path string or no argument") -- 212
		end -- 212
		return refreshWorkspaceTree(req.workDir, path) -- 214
	end -- 206
	local blockedDoraGlobals = {DB = true, HttpClient = true, HttpServer = true} -- 216
	local scopedContent = createCommandContent(req.workDir, req.docLanguage) -- 221
	local env = setmetatable( -- 222
		{ -- 222
			projectDir = req.workDir, -- 223
			previewGame = createPreviewGameInjection( -- 224
				{ -- 224
					workDir = req.workDir, -- 225
					operationId = req.operationId, -- 226
					isCancelled = req.isCancelled, -- 227
					print = function(line) return capturePrint(line) end, -- 228
					reserveCapture = reserveCapture, -- 229
					registerCleanup = function(cleanup) -- 230
						previewCleanup = cleanup -- 230
					end, -- 230
					onResult = function(result) -- 231
						lastPreviewResult = result -- 232
					end -- 231
				}, -- 231
				entry -- 234
			), -- 234
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 235
				if type(moduleNameValue) ~= "string" then -- 235
					error("requireProjectModule expects a project module name string") -- 237
				end -- 237
				local moduleName = __TS__StringTrim(moduleNameValue) -- 239
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 239
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 241
				end -- 241
				local reloadModules = {moduleName} -- 243
				if reloadModulesValue ~= nil then -- 243
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 243
						error("requireProjectModule reloadModules must be an array of module names") -- 246
					end -- 246
					local items = reloadModulesValue -- 248
					do -- 248
						local i = 0 -- 249
						while i < #items do -- 249
							local item = items[i + 1] -- 250
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 250
								error("requireProjectModule reloadModules contains an invalid module name") -- 252
							end -- 252
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 252
								reloadModules[#reloadModules + 1] = item -- 254
							end -- 254
							i = i + 1 -- 249
						end -- 249
					end -- 249
				end -- 249
				local luaPackage = _G.package -- 257
				local previousPath = luaPackage.path -- 261
				local previousSearchPaths = Content.searchPaths -- 262
				local scopedSearchPaths = {req.workDir} -- 263
				do -- 263
					local i = 0 -- 264
					while i < #previousSearchPaths do -- 264
						local searchPath = previousSearchPaths[i + 1] -- 265
						if searchPath ~= req.workDir then -- 265
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 266
						end -- 266
						i = i + 1 -- 264
					end -- 264
				end -- 264
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 268
				Content.searchPaths = scopedSearchPaths -- 269
				do -- 269
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 269
						do -- 269
							local i = 0 -- 271
							while i < #reloadModules do -- 271
								local reloadName = reloadModules[i + 1] -- 272
								luaPackage.loaded[reloadName] = nil -- 273
								luaPackage.loaded[table.concat( -- 274
									__TS__StringSplit(reloadName, "/"), -- 274
									"." -- 274
								)] = nil -- 274
								luaPackage.loaded[table.concat( -- 275
									__TS__StringSplit(reloadName, "."), -- 275
									"/" -- 275
								)] = nil -- 275
								i = i + 1 -- 271
							end -- 271
						end -- 271
						return true, require(table.concat( -- 277
							__TS__StringSplit(moduleName, "/"), -- 277
							"." -- 277
						)) -- 277
					end) -- 277
					do -- 277
						Content.searchPaths = previousSearchPaths -- 279
						luaPackage.path = previousPath -- 280
					end -- 280
					if not ____try then -- 280
						error(____hasReturned, 0) -- 280
					end -- 280
					if ____try and ____hasReturned then -- 280
						return ____returnValue -- 270
					end -- 270
				end -- 270
			end, -- 235
			print = capturePrint, -- 283
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 284
			enterEntryAsync = function(value) -- 285
				local normalized = normalizeEntryFile(value) -- 286
				acquireEntryRuntime() -- 287
				entry.allClear() -- 288
				startEntryWatchdog() -- 289
				recordEntryLeaseRun(req.operationId, entry) -- 290
				local success, message = entry.enterEntryAsync({ -- 291
					entryName = normalized.entryName, -- 292
					fileName = normalized.fileName, -- 293
					workDir = req.workDir, -- 294
					projectRoot = req.workDir, -- 295
					runKind = "agent_test" -- 296
				}) -- 296
				return success, message -- 298
			end, -- 285
			stopEntry = function() -- 300
				if not ownsEntryRuntime or not ownsEntryLease(req.operationId, entry) then -- 300
					return false -- 301
				end -- 301
				return entry.stop() -- 302
			end, -- 300
			reportProgress = function(value, callbackValue) -- 304
				local ____callbackValue_11 = callbackValue -- 305
				if ____callbackValue_11 == nil then -- 305
					____callbackValue_11 = value -- 305
				end -- 305
				local actualValue = ____callbackValue_11 -- 305
				if not req.onProgress or not actualValue or type(actualValue) ~= "table" then -- 305
					return -- 306
				end -- 306
				local progress = actualValue -- 307
				local amount = type(progress.progress) == "number" and math.min( -- 308
					1, -- 309
					math.max(0, progress.progress) -- 309
				) or nil -- 309
				req:onProgress({ -- 311
					state = "running", -- 312
					mode = "lua", -- 313
					operationId = req.operationId, -- 314
					progress = amount, -- 315
					stage = type(progress.stage) == "string" and progress.stage or "lua", -- 316
					message = type(progress.message) == "string" and progress.message or "Lua command running" -- 317
				}) -- 317
			end -- 304
		}, -- 304
		{__index = function(_table, key) -- 320
			if key == "Content" then -- 320
				contentAccessed = true -- 323
				return scopedContent -- 324
			end -- 324
			if key == "refreshTree" then -- 324
				return refreshTree -- 327
			end -- 327
			local name = tostring(key) -- 329
			if blockedDoraGlobals[name] then -- 329
				return nil -- 330
			end -- 330
			return Dora[name] -- 331
		end} -- 321
	) -- 321
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 334
	if not fn then -- 334
		return __TS__Promise.resolve({ -- 336
			success = false, -- 337
			mode = "lua", -- 338
			output = truncateCommandOutput(table.concat(output, "\n")), -- 339
			message = truncateCommandError(toStr(compileErr)), -- 340
			phase = "compile" -- 341
		}) -- 341
	end -- 341
	return __TS__New( -- 344
		__TS__Promise, -- 344
		function(____, resolve) -- 344
			local settled = false -- 345
			local commandRoutine -- 346
			local startedAt = App.runningTime -- 347
			local onProgress = req.onProgress -- 348
			local isCancelled = req.isCancelled -- 349
			local function finish(result) -- 350
				if settled then -- 350
					return -- 351
				end -- 351
				settled = true -- 352
				local cleanupError -- 353
				local cleanup = previewCleanup -- 354
				previewCleanup = nil -- 355
				do -- 355
					local function ____catch(e) -- 355
						cleanupError = "failed to release Agent preview: " .. tostring(e) -- 357
					end -- 357
					local ____try, ____hasReturned = pcall(function() -- 357
						if cleanup ~= nil then -- 357
							cleanup() -- 356
						end -- 356
					end) -- 356
					if not ____try then -- 356
						____catch(____hasReturned) -- 356
					end -- 356
				end -- 356
				if restorePrint ~= nil then -- 356
					restorePrint() -- 358
				end -- 358
				restorePrint = nil -- 359
				if not result.success and (result.interrupted == true or result.phase == "timeout") and (not entry.getCurrentEntryStatus().running or ownsEntryLease(req.operationId, entry)) then -- 359
					do -- 359
						local function ____catch(e) -- 359
							cleanupError = "failed to clear interrupted Lua command runtime: " .. tostring(e) -- 365
						end -- 365
						local ____try, ____hasReturned = pcall(function() -- 365
							entry.allClear() -- 363
						end) -- 363
						if not ____try then -- 363
							____catch(____hasReturned) -- 363
						end -- 363
					end -- 363
				end -- 363
				local entryCleanupError = stopOwnedEntry() -- 368
				if cleanupError == nil then -- 368
					cleanupError = entryCleanupError -- 369
				end -- 369
				if contentAccessed and not refreshTreeCalled and not refreshWorkspaceTree(req.workDir) then -- 369
					Log("Warn", "[execute_command] failed to refresh Web IDE tree after Lua command workDir=" .. req.workDir) -- 371
				end -- 371
				local ____lastPreviewResult_21 -- 373
				if lastPreviewResult then -- 373
					local ____lastPreviewResult_success_18 = lastPreviewResult.success -- 374
					local ____lastPreviewResult_message_19 = lastPreviewResult.message -- 375
					local ____lastPreviewResult_files_20 = lastPreviewResult.files -- 376
					local ____opt_16 = lastPreviewResult.frames -- 376
					____lastPreviewResult_21 = {success = ____lastPreviewResult_success_18, message = ____lastPreviewResult_message_19, files = ____lastPreviewResult_files_20, frameCount = ____opt_16 and #____opt_16} -- 373
				else -- 373
					____lastPreviewResult_21 = nil -- 378
				end -- 378
				local previewGame = ____lastPreviewResult_21 -- 373
				local visionFields = __TS__ObjectAssign( -- 379
					{}, -- 379
					previewGame and ({previewGame = previewGame}) or ({}), -- 380
					capturedBatches > 0 and ({ -- 381
						visionCapture = {batchCount = capturedBatches, frameCount = capturedFrames}, -- 382
						visionBudget = getVisionBudgetState(currentVisionUsage()) -- 383
					}) or ({}) -- 383
				) -- 383
				if not result.success and cleanupError ~= nil then -- 383
					result.cleanupError = cleanupError -- 387
				elseif result.success and cleanupError ~= nil then -- 387
					resolve( -- 389
						nil, -- 389
						__TS__ObjectAssign({ -- 389
							success = false, -- 390
							mode = "lua", -- 391
							output = result.output, -- 392
							message = cleanupError, -- 393
							phase = "execute", -- 394
							cleanupError = cleanupError -- 395
						}, visionFields) -- 395
					) -- 395
					return -- 398
				end -- 398
				if result.success and lastPreviewResult and not lastPreviewResult.success then -- 398
					resolve( -- 401
						nil, -- 401
						__TS__ObjectAssign({ -- 401
							success = false, -- 402
							mode = "lua", -- 403
							output = result.output, -- 404
							message = "previewGame failed: " .. (lastPreviewResult.message or "unknown error"), -- 405
							phase = "execute" -- 406
						}, visionFields) -- 406
					) -- 406
					return -- 409
				end -- 409
				resolve( -- 411
					nil, -- 411
					__TS__ObjectAssign({}, result, visionFields) -- 411
				) -- 411
			end -- 350
			if onProgress then -- 350
				onProgress(nil, { -- 417
					state = "pending", -- 418
					mode = "lua", -- 419
					operationId = req.operationId, -- 420
					stage = "lua", -- 421
					message = "Lua command pending" -- 422
				}) -- 422
			end -- 422
			commandRoutine = once(function() -- 425
				if settled then -- 425
					return -- 426
				end -- 426
				if onProgress then -- 426
					onProgress(nil, { -- 428
						state = "running", -- 429
						mode = "lua", -- 430
						operationId = req.operationId, -- 431
						stage = "lua", -- 432
						message = "Lua command running" -- 433
					}) -- 433
				end -- 433
				local previousGlobalPrint = _G.print -- 436
				restorePrint = function() -- 437
					if _G.print == capturePrint then -- 437
						_G.print = previousGlobalPrint -- 437
					end -- 437
				end -- 437
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 438
				local frameTimedOut = false -- 439
				local watchdogMessage -- 439
				_G.print = capturePrint -- 440
				debug.sethook( -- 441
					function() -- 441
						if watchdogMessage == nil then -- 441
							watchdogMessage = checkEntryWatchdog() -- 442
						end -- 442
						if watchdogMessage ~= nil then -- 442
							error(watchdogMessage) -- 443
						end -- 443
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 443
							frameTimedOut = true -- 445
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 446
						end -- 446
					end, -- 441
					"", -- 448
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 448
				) -- 448
				local ok, runtimeErr = pcall(fn) -- 449
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 449
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 451
				else -- 451
					debug.sethook() -- 457
				end -- 457
				_G.print = previousGlobalPrint -- 459
				if not ok then -- 459
					local ____truncateCommandOutput_result_23 = truncateCommandOutput(table.concat(output, "\n")) -- 464
					local ____temp_24 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 465
					local ____temp_25 = frameTimedOut and "timeout" or "execute" -- 466
					local ____temp_22 -- 467
					if watchdogMessage ~= nil or frameTimedOut then -- 467
						____temp_22 = true -- 467
					else -- 467
						____temp_22 = nil -- 467
					end -- 467
					finish({ -- 461
						success = false, -- 462
						mode = "lua", -- 463
						output = ____truncateCommandOutput_result_23, -- 464
						message = ____temp_24, -- 465
						phase = ____temp_25, -- 466
						interrupted = ____temp_22 -- 467
					}) -- 467
					return -- 469
				end -- 469
				finish({ -- 471
					success = true, -- 471
					mode = "lua", -- 471
					output = truncateCommandOutput(table.concat(output, "\n")) -- 471
				}) -- 471
			end) -- 425
			Director.systemScheduler:schedule(function() -- 473
				if settled then -- 473
					return true -- 474
				end -- 474
				local watchdogMessage = checkEntryWatchdog() -- 475
				if watchdogMessage ~= nil then -- 475
					finish({ -- 477
						success = false, -- 478
						mode = "lua", -- 479
						output = truncateCommandOutput(table.concat(output, "\n")), -- 480
						message = watchdogMessage, -- 481
						phase = "execute", -- 482
						interrupted = true -- 483
					}) -- 483
					return true -- 485
				end -- 485
				if isCancelled and isCancelled(nil) then -- 485
					finish({ -- 488
						success = false, -- 489
						mode = "lua", -- 490
						output = truncateCommandOutput(table.concat(output, "\n")), -- 491
						message = "Lua command canceled", -- 492
						phase = "execute", -- 493
						interrupted = true -- 494
					}) -- 494
					return true -- 496
				end -- 496
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 496
					finish({ -- 499
						success = false, -- 500
						mode = "lua", -- 501
						output = truncateCommandOutput(table.concat(output, "\n")), -- 502
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 503
						phase = "timeout" -- 504
					}) -- 504
					return true -- 506
				end -- 506
				if commandRoutine == nil then -- 506
					finish({ -- 509
						success = false, -- 510
						mode = "lua", -- 511
						output = truncateCommandOutput(table.concat(output, "\n")), -- 512
						message = "Lua command coroutine is unavailable", -- 513
						phase = "execute" -- 514
					}) -- 514
					return true -- 516
				end -- 516
				local resumeSuccess, resumeResult = coroutine.resume(commandRoutine) -- 518
				if not resumeSuccess then -- 518
					finish({ -- 520
						success = false, -- 521
						mode = "lua", -- 522
						output = truncateCommandOutput(table.concat(output, "\n")), -- 523
						message = truncateCommandError(toStr(resumeResult)), -- 524
						phase = "execute" -- 525
					}) -- 525
					return true -- 527
				end -- 527
				return settled or resumeResult == true -- 529
			end) -- 473
		end -- 344
	) -- 344
end -- 99
function ____exports.executeCommand(req) -- 534
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 534
		local mode = req.mode -- 546
		if mode ~= "lua" and mode ~= "git" then -- 546
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 546
		end -- 546
		if mode == "lua" then -- 546
			return ____awaiter_resolve( -- 546
				nil, -- 546
				executeLuaCommand({ -- 551
					workDir = req.workDir, -- 552
					docLanguage = req.docLanguage, -- 553
					code = req.code or "", -- 554
					timeoutSeconds = math.max( -- 555
						1, -- 555
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 555
					), -- 555
					operationId = createOperationId(), -- 556
					taskId = req.taskId or 0, -- 557
					onProgress = req.onProgress, -- 558
					isCancelled = req.isCancelled -- 559
				}) -- 559
			) -- 559
		end -- 559
		local operationId = createOperationId() -- 562
		return ____awaiter_resolve( -- 562
			nil, -- 562
			executeGitCommand({ -- 563
				workDir = req.workDir, -- 564
				command = req.command or "", -- 565
				cwd = req.cwd, -- 566
				timeoutSeconds = math.max( -- 567
					1, -- 567
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 567
				), -- 567
				operationId = operationId, -- 568
				onProgress = req.onProgress, -- 569
				isCancelled = req.isCancelled -- 570
			}) -- 570
		) -- 570
	end) -- 570
end -- 534
return ____exports -- 534