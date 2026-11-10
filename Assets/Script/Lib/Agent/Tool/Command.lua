-- [ts]: Command.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
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
local AgentConfig = require("Agent.Config.Defaults") -- 4
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
local ____GodotImport = require("Agent.Tool.GodotImport") -- 13
local createGodotImportInjection = ____GodotImport.createGodotImportInjection -- 13
local ____CommandContent = require("Agent.Tool.CommandContent") -- 14
local createCommandContent = ____CommandContent.createCommandContent -- 14
local ____EntryLease = require("Agent.Tool.EntryLease") -- 16
local acquireEntryLease = ____EntryLease.acquireEntryLease -- 16
local recordEntryLeaseRun = ____EntryLease.recordEntryLeaseRun -- 16
local ownsEntryLease = ____EntryLease.ownsEntryLease -- 16
local releaseEntryLease = ____EntryLease.releaseEntryLease -- 16
local ____CommandPreview = require("Agent.Tool.CommandPreview") -- 17
local createPreviewGameInjection = ____CommandPreview.createPreviewGameInjection -- 17
local ____VisionBudget = require("Agent.Tool.VisionBudget") -- 18
local getVisionBudgetState = ____VisionBudget.getVisionBudgetState -- 19
local getVisionTaskUsage = ____VisionBudget.getVisionTaskUsage -- 20
local VISION_MAX_CAPTURE_BATCHES = ____VisionBudget.VISION_MAX_CAPTURE_BATCHES -- 22
local VISION_MAX_CAPTURE_FRAMES = ____VisionBudget.VISION_MAX_CAPTURE_FRAMES -- 23
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 27
local function executeStudioLuaCommand(req) -- 36
	local usesPreviewGame = (string.match(req.code, "%f[%a_]previewGame%f[^%w_]%s*%(")) ~= nil -- 48
	local usesGodotImport = (string.match(req.code, "%f[%a_]importGodotAssets%f[^%w_]")) ~= nil -- 49
	if type(_studio_agent_tool_begin) ~= "function" or usesPreviewGame or usesGodotImport then -- 49
		return nil -- 50
	end -- 50
	local onProgress = req.onProgress -- 51
	local isCancelled = req.isCancelled -- 52
	return __TS__New( -- 53
		__TS__Promise, -- 53
		function(____, resolve) -- 53
			local requestId -- 54
			local settled = false -- 55
			local function finish(result) -- 56
				if settled then -- 56
					return -- 57
				end -- 57
				settled = true -- 58
				resolve(nil, result) -- 59
			end -- 56
			if onProgress ~= nil then -- 56
				onProgress(nil, { -- 61
					state = "pending", -- 61
					mode = "lua", -- 61
					operationId = req.operationId, -- 61
					stage = "player", -- 61
					message = "Lua command pending in isolated game Player" -- 61
				}) -- 61
			end -- 61
			local routine = once(function() -- 62
				do -- 62
					local function ____catch(e) -- 62
						if requestId then -- 62
							if _studio_agent_tool_cancel ~= nil then -- 62
								_studio_agent_tool_cancel(requestId) -- 86
							end -- 86
							requestId = nil -- 86
						end -- 86
						local message = truncateCommandError(toStr(e)) -- 87
						local ____message_9 = message -- 88
						local ____temp_10 = (string.find(message, "timed out", nil, true) or 0) - 1 >= 0 and "timeout" or "execute" -- 88
						local ____temp_8 -- 88
						if (string.find(message, "canceled", nil, true) or 0) - 1 >= 0 then -- 88
							____temp_8 = true -- 88
						else -- 88
							____temp_8 = nil -- 88
						end -- 88
						finish({ -- 88
							success = false, -- 88
							mode = "lua", -- 88
							output = "", -- 88
							message = ____message_9, -- 88
							phase = ____temp_10, -- 88
							interrupted = ____temp_8 -- 88
						}) -- 88
					end -- 88
					local ____try, ____hasReturned = pcall(function() -- 88
						local options = safeJsonEncode({code = req.code, timeoutSeconds = req.timeoutSeconds}) -- 64
						if not options then -- 64
							error("failed to encode Studio Agent Lua command") -- 65
						end -- 65
						requestId = _studio_agent_tool_begin( -- 66
							"execute-lua", -- 66
							Path(req.workDir, ".agent", "command.lua"), -- 66
							options, -- 66
							req.workDir -- 66
						) -- 66
						if onProgress ~= nil then -- 66
							onProgress(nil, { -- 67
								state = "running", -- 67
								mode = "lua", -- 67
								operationId = req.operationId, -- 67
								stage = "player", -- 67
								message = "Lua command running in isolated game Player" -- 67
							}) -- 67
						end -- 67
						local deadline = App.runningTime + req.timeoutSeconds -- 68
						local answer -- 69
						while not answer do -- 69
							if isCancelled and isCancelled(nil) then -- 69
								error("Lua command canceled") -- 71
							end -- 71
							if App.runningTime >= deadline then -- 71
								error(("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds") -- 72
							end -- 72
							answer = _studio_agent_tool_poll and _studio_agent_tool_poll(requestId) -- 73
							if not answer then -- 73
								sleep() -- 74
							end -- 74
						end -- 74
						requestId = nil -- 76
						if not answer.success then -- 76
							error(answer.message or "Studio Agent Lua Player failed") -- 77
						end -- 77
						local decoded = safeJsonDecode(answer.resultJSON or "") -- 78
						local value = decoded -- 79
						if not value or type(value.success) ~= "boolean" or type(value.output) ~= "string" or value.message ~= nil and type(value.message) ~= "string" or value.phase ~= nil and value.phase ~= "compile" and value.phase ~= "execute" and value.phase ~= "timeout" and value.phase ~= "validate" then -- 79
							error("Invalid Studio Agent Lua Player result") -- 82
						end -- 82
						if value.success then -- 82
							finish({ -- 83
								success = true, -- 83
								mode = "lua", -- 83
								output = truncateCommandOutput(value.output) -- 83
							}) -- 83
						else -- 83
							finish({ -- 84
								success = false, -- 84
								mode = "lua", -- 84
								output = truncateCommandOutput(value.output), -- 84
								message = truncateCommandError(value.message or "Lua command failed"), -- 84
								phase = value.phase or "execute" -- 84
							}) -- 84
						end -- 84
					end) -- 84
					if not ____try then -- 84
						____catch(____hasReturned) -- 84
					end -- 84
				end -- 84
			end) -- 62
			Director.systemScheduler:schedule(function() -- 91
				if settled then -- 91
					return true -- 92
				end -- 92
				local ok, result = coroutine.resume(routine) -- 93
				if not ok then -- 93
					finish({ -- 94
						success = false, -- 94
						mode = "lua", -- 94
						output = "", -- 94
						message = truncateCommandError(toStr(result)), -- 94
						phase = "execute" -- 94
					}) -- 94
					return true -- 94
				end -- 94
				return settled or result == true -- 95
			end) -- 91
		end -- 53
	) -- 53
end -- 36
local function executeLuaCommand(req) -- 101
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
	local commandClosed = false -- 127
	local godotImportResults = {} -- 128
	local lastPreviewResult -- 129
	local previewCleanup -- 130
	local restorePrint -- 131
	local function currentVisionUsage() -- 132
		if persistedVisionUsage == nil then -- 132
			persistedVisionUsage = getVisionTaskUsage(req.taskId) -- 133
		end -- 133
		return __TS__ObjectAssign({}, persistedVisionUsage, {captureBatchCount = persistedVisionUsage.captureBatchCount + capturedBatches, captureFrameCount = persistedVisionUsage.captureFrameCount + capturedFrames}) -- 134
	end -- 132
	local function reserveCapture(frameCount) -- 140
		local current = currentVisionUsage() -- 141
		if current.captureBatchCount >= VISION_MAX_CAPTURE_BATCHES or current.captureFrameCount + frameCount > VISION_MAX_CAPTURE_FRAMES then -- 141
			return { -- 143
				success = false, -- 144
				message = ((("Vision capture budget exhausted: " .. tostring(current.captureBatchCount)) .. " batches and ") .. tostring(current.captureFrameCount)) .. " frames already reserved", -- 145
				budget = getVisionBudgetState(current) -- 146
			} -- 146
		end -- 146
		capturedBatches = capturedBatches + 1 -- 149
		capturedFrames = capturedFrames + frameCount -- 150
		return { -- 151
			success = true, -- 151
			budget = getVisionBudgetState(currentVisionUsage()) -- 151
		} -- 151
	end -- 140
	local function acquireEntryRuntime() -- 153
		acquireEntryLease(req.operationId, entry) -- 154
		ownsEntryRuntime = true -- 155
	end -- 153
	local function stopOwnedEntry() -- 157
		if not ownsEntryRuntime then -- 157
			return nil -- 158
		end -- 158
		ownsEntryRuntime = false -- 159
		return releaseEntryLease(req.operationId, entry) -- 160
	end -- 157
	local function startEntryWatchdog() -- 162
		entryObjectBaseline = Dora.Object.count -- 163
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 164
	end -- 162
	local function checkEntryWatchdog() -- 166
		if not ownsEntryRuntime then -- 166
			return nil -- 167
		end -- 167
		local objectCount = Dora.Object.count -- 168
		local luaRefCount = Dora.Object.luaRefCount -- 169
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 170
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 171
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 172
		if not exceededTotal then -- 172
			return nil -- 175
		end -- 175
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 176
	end -- 166
	local function normalizeEntryFile(value) -- 180
		if not value or type(value) ~= "table" then -- 180
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 182
		end -- 182
		local descriptor = value -- 184
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 185
		if relativeFile == "" then -- 185
			relativeFile = "init" -- 186
		end -- 186
		if not isValidWorkspacePath(relativeFile) then -- 186
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 188
		end -- 188
		local fileName = Path(req.workDir, relativeFile) -- 190
		local ext = Path:getExt(fileName) -- 191
		if ext ~= "" then -- 191
			fileName = Path:replaceExt(fileName, "") -- 192
		end -- 192
		local luaFile = Path:replaceExt(fileName, "lua") -- 193
		if not Content:exist(luaFile) then -- 193
			error("Agent test entry was not built: " .. luaFile) -- 195
		end -- 195
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 197
		return { -- 198
			fileName = fileName, -- 199
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 200
		} -- 200
	end -- 180
	local function capturePrint(...) -- 203
		local values = {...} -- 203
		local parts = {} -- 204
		do -- 204
			local i = 0 -- 205
			while i < #values do -- 205
				parts[#parts + 1] = tostring(values[i + 1]) -- 206
				i = i + 1 -- 205
			end -- 205
		end -- 205
		output[#output + 1] = table.concat(parts, "\t") -- 208
	end -- 203
	local function refreshTree(path) -- 210
		refreshTreeCalled = true -- 211
		if path == nil then -- 211
			return refreshWorkspaceTree(req.workDir) -- 213
		end -- 213
		if type(path) ~= "string" then -- 213
			error("refreshTree expects a project-relative file path string or no argument") -- 216
		end -- 216
		return refreshWorkspaceTree(req.workDir, path) -- 218
	end -- 210
	local blockedDoraGlobals = {DB = true, HttpClient = true, HttpServer = true} -- 220
	local scopedContent = createCommandContent(req.workDir, req.docLanguage) -- 225
	local env = setmetatable( -- 226
		{ -- 226
			projectDir = req.workDir, -- 227
			importGodotAssets = createGodotImportInjection({ -- 228
				workDir = req.workDir, -- 229
				isCancelled = function() -- 230
					local ____commandClosed_13 = commandClosed -- 230
					if not ____commandClosed_13 then -- 230
						local ____this_12 -- 230
						____this_12 = req -- 230
						local ____opt_11 = ____this_12.isCancelled -- 230
						____commandClosed_13 = (____opt_11 and ____opt_11(____this_12)) == true -- 230
					end -- 230
					return ____commandClosed_13 -- 230
				end, -- 230
				print = capturePrint, -- 231
				onResult = function(result) -- 232
					godotImportResults[#godotImportResults + 1] = result -- 233
					if result.importedCount > 0 then -- 233
						contentAccessed = true -- 234
					end -- 234
				end -- 232
			}), -- 232
			previewGame = createPreviewGameInjection( -- 238
				{ -- 238
					workDir = req.workDir, -- 239
					operationId = req.operationId, -- 240
					isCancelled = req.isCancelled, -- 241
					print = function(line) return capturePrint(line) end, -- 242
					reserveCapture = reserveCapture, -- 243
					registerCleanup = function(cleanup) -- 244
						previewCleanup = cleanup -- 244
					end, -- 244
					onResult = function(result) -- 245
						lastPreviewResult = result -- 246
					end -- 245
				}, -- 245
				entry -- 248
			), -- 248
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 249
				if type(moduleNameValue) ~= "string" then -- 249
					error("requireProjectModule expects a project module name string") -- 251
				end -- 251
				local moduleName = __TS__StringTrim(moduleNameValue) -- 253
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 253
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 255
				end -- 255
				local reloadModules = {moduleName} -- 257
				if reloadModulesValue ~= nil then -- 257
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 257
						error("requireProjectModule reloadModules must be an array of module names") -- 260
					end -- 260
					local items = reloadModulesValue -- 262
					do -- 262
						local i = 0 -- 263
						while i < #items do -- 263
							local item = items[i + 1] -- 264
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 264
								error("requireProjectModule reloadModules contains an invalid module name") -- 266
							end -- 266
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 266
								reloadModules[#reloadModules + 1] = item -- 268
							end -- 268
							i = i + 1 -- 263
						end -- 263
					end -- 263
				end -- 263
				local luaPackage = _G.package -- 271
				local previousPath = luaPackage.path -- 275
				local previousSearchPaths = Content.searchPaths -- 276
				local scopedSearchPaths = {req.workDir} -- 277
				do -- 277
					local i = 0 -- 278
					while i < #previousSearchPaths do -- 278
						local searchPath = previousSearchPaths[i + 1] -- 279
						if searchPath ~= req.workDir then -- 279
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 280
						end -- 280
						i = i + 1 -- 278
					end -- 278
				end -- 278
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 282
				Content.searchPaths = scopedSearchPaths -- 283
				do -- 283
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 283
						do -- 283
							local i = 0 -- 285
							while i < #reloadModules do -- 285
								local reloadName = reloadModules[i + 1] -- 286
								luaPackage.loaded[reloadName] = nil -- 287
								luaPackage.loaded[table.concat( -- 288
									__TS__StringSplit(reloadName, "/"), -- 288
									"." -- 288
								)] = nil -- 288
								luaPackage.loaded[table.concat( -- 289
									__TS__StringSplit(reloadName, "."), -- 289
									"/" -- 289
								)] = nil -- 289
								i = i + 1 -- 285
							end -- 285
						end -- 285
						return true, require(table.concat( -- 291
							__TS__StringSplit(moduleName, "/"), -- 291
							"." -- 291
						)) -- 291
					end) -- 291
					do -- 291
						Content.searchPaths = previousSearchPaths -- 293
						luaPackage.path = previousPath -- 294
					end -- 294
					if not ____try then -- 294
						error(____hasReturned, 0) -- 294
					end -- 294
					if ____try and ____hasReturned then -- 294
						return ____returnValue -- 284
					end -- 284
				end -- 284
			end, -- 249
			print = capturePrint, -- 297
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 298
			enterEntryAsync = function(value) -- 299
				local normalized = normalizeEntryFile(value) -- 300
				acquireEntryRuntime() -- 301
				entry.allClear() -- 302
				startEntryWatchdog() -- 303
				recordEntryLeaseRun(req.operationId, entry) -- 304
				local success, message = entry.enterEntryAsync({ -- 305
					entryName = normalized.entryName, -- 306
					fileName = normalized.fileName, -- 307
					workDir = req.workDir, -- 308
					projectRoot = req.workDir, -- 309
					runKind = "agent_test" -- 310
				}) -- 310
				return success, message -- 312
			end, -- 299
			stopEntry = function() -- 314
				if not ownsEntryRuntime or not ownsEntryLease(req.operationId, entry) then -- 314
					return false -- 315
				end -- 315
				return entry.stop() -- 316
			end, -- 314
			reportProgress = function(value, callbackValue) -- 318
				local ____callbackValue_14 = callbackValue -- 319
				if ____callbackValue_14 == nil then -- 319
					____callbackValue_14 = value -- 319
				end -- 319
				local actualValue = ____callbackValue_14 -- 319
				if not req.onProgress or not actualValue or type(actualValue) ~= "table" then -- 319
					return -- 320
				end -- 320
				local progress = actualValue -- 321
				local amount = type(progress.progress) == "number" and math.min( -- 322
					1, -- 323
					math.max(0, progress.progress) -- 323
				) or nil -- 323
				req:onProgress({ -- 325
					state = "running", -- 326
					mode = "lua", -- 327
					operationId = req.operationId, -- 328
					progress = amount, -- 329
					stage = type(progress.stage) == "string" and progress.stage or "lua", -- 330
					message = type(progress.message) == "string" and progress.message or "Lua command running" -- 331
				}) -- 331
			end -- 318
		}, -- 318
		{__index = function(_table, key) -- 334
			if key == "Content" then -- 334
				contentAccessed = true -- 337
				return scopedContent -- 338
			end -- 338
			if key == "refreshTree" then -- 338
				return refreshTree -- 341
			end -- 341
			local name = tostring(key) -- 343
			if blockedDoraGlobals[name] then -- 343
				return nil -- 344
			end -- 344
			return Dora[name] -- 345
		end} -- 335
	) -- 335
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 348
	if not fn then -- 348
		return __TS__Promise.resolve({ -- 350
			success = false, -- 351
			mode = "lua", -- 352
			output = truncateCommandOutput(table.concat(output, "\n")), -- 353
			message = truncateCommandError(toStr(compileErr)), -- 354
			phase = "compile" -- 355
		}) -- 355
	end -- 355
	return __TS__New( -- 358
		__TS__Promise, -- 358
		function(____, resolve) -- 358
			local settled = false -- 359
			local commandRoutine -- 360
			local startedAt = App.runningTime -- 361
			local onProgress = req.onProgress -- 362
			local isCancelled = req.isCancelled -- 363
			local function finish(result) -- 364
				if settled then -- 364
					return -- 365
				end -- 365
				settled = true -- 366
				commandClosed = true -- 367
				local cleanupError -- 368
				local cleanup = previewCleanup -- 369
				previewCleanup = nil -- 370
				do -- 370
					local function ____catch(e) -- 370
						cleanupError = "failed to release Agent preview: " .. tostring(e) -- 372
					end -- 372
					local ____try, ____hasReturned = pcall(function() -- 372
						if cleanup ~= nil then -- 372
							cleanup() -- 371
						end -- 371
					end) -- 371
					if not ____try then -- 371
						____catch(____hasReturned) -- 371
					end -- 371
				end -- 371
				if restorePrint ~= nil then -- 371
					restorePrint() -- 373
				end -- 373
				restorePrint = nil -- 374
				if not result.success and (result.interrupted == true or result.phase == "timeout") and (not entry.getCurrentEntryStatus().running or ownsEntryLease(req.operationId, entry)) then -- 374
					do -- 374
						local function ____catch(e) -- 374
							cleanupError = "failed to clear interrupted Lua command runtime: " .. tostring(e) -- 380
						end -- 380
						local ____try, ____hasReturned = pcall(function() -- 380
							entry.allClear() -- 378
						end) -- 378
						if not ____try then -- 378
							____catch(____hasReturned) -- 378
						end -- 378
					end -- 378
				end -- 378
				local entryCleanupError = stopOwnedEntry() -- 383
				if cleanupError == nil then -- 383
					cleanupError = entryCleanupError -- 384
				end -- 384
				if contentAccessed and not refreshTreeCalled and not refreshWorkspaceTree(req.workDir) then -- 384
					Log("Warn", "[execute_command] failed to refresh Web IDE tree after Lua command workDir=" .. req.workDir) -- 386
				end -- 386
				local ____lastPreviewResult_24 -- 388
				if lastPreviewResult then -- 388
					local ____lastPreviewResult_success_21 = lastPreviewResult.success -- 389
					local ____lastPreviewResult_message_22 = lastPreviewResult.message -- 390
					local ____lastPreviewResult_files_23 = lastPreviewResult.files -- 391
					local ____opt_19 = lastPreviewResult.frames -- 391
					____lastPreviewResult_24 = {success = ____lastPreviewResult_success_21, message = ____lastPreviewResult_message_22, files = ____lastPreviewResult_files_23, frameCount = ____opt_19 and #____opt_19} -- 388
				else -- 388
					____lastPreviewResult_24 = nil -- 393
				end -- 393
				local previewGame = ____lastPreviewResult_24 -- 388
				local visionFields = __TS__ObjectAssign( -- 394
					{}, -- 394
					#godotImportResults > 0 and ({godotImports = godotImportResults}) or ({}), -- 395
					previewGame and ({previewGame = previewGame}) or ({}), -- 396
					capturedBatches > 0 and ({ -- 397
						visionCapture = {batchCount = capturedBatches, frameCount = capturedFrames}, -- 398
						visionBudget = getVisionBudgetState(currentVisionUsage()) -- 399
					}) or ({}) -- 399
				) -- 399
				if not result.success and cleanupError ~= nil then -- 399
					result.cleanupError = cleanupError -- 403
				elseif result.success and cleanupError ~= nil then -- 403
					resolve( -- 405
						nil, -- 405
						__TS__ObjectAssign({ -- 405
							success = false, -- 406
							mode = "lua", -- 407
							output = result.output, -- 408
							message = cleanupError, -- 409
							phase = "execute", -- 410
							cleanupError = cleanupError -- 411
						}, visionFields) -- 411
					) -- 411
					return -- 414
				end -- 414
				if result.success and __TS__ArraySome( -- 414
					godotImportResults, -- 416
					function(____, batch) return not batch.success end -- 416
				) then -- 416
					resolve( -- 417
						nil, -- 417
						__TS__ObjectAssign({ -- 417
							success = false, -- 417
							mode = "lua", -- 417
							output = result.output, -- 417
							message = "importGodotAssets failed; inspect godotImports for per-file results", -- 418
							phase = "execute" -- 418
						}, visionFields) -- 418
					) -- 418
					return -- 419
				end -- 419
				if result.success and lastPreviewResult and not lastPreviewResult.success then -- 419
					resolve( -- 422
						nil, -- 422
						__TS__ObjectAssign({ -- 422
							success = false, -- 423
							mode = "lua", -- 424
							output = result.output, -- 425
							message = "previewGame failed: " .. (lastPreviewResult.message or "unknown error"), -- 426
							phase = "execute" -- 427
						}, visionFields) -- 427
					) -- 427
					return -- 430
				end -- 430
				resolve( -- 432
					nil, -- 432
					__TS__ObjectAssign({}, result, visionFields) -- 432
				) -- 432
			end -- 364
			if onProgress then -- 364
				onProgress(nil, { -- 438
					state = "pending", -- 439
					mode = "lua", -- 440
					operationId = req.operationId, -- 441
					stage = "lua", -- 442
					message = "Lua command pending" -- 443
				}) -- 443
			end -- 443
			commandRoutine = once(function() -- 446
				if settled then -- 446
					return -- 447
				end -- 447
				if onProgress then -- 447
					onProgress(nil, { -- 449
						state = "running", -- 450
						mode = "lua", -- 451
						operationId = req.operationId, -- 452
						stage = "lua", -- 453
						message = "Lua command running" -- 454
					}) -- 454
				end -- 454
				local previousGlobalPrint = _G.print -- 457
				restorePrint = function() -- 458
					if _G.print == capturePrint then -- 458
						_G.print = previousGlobalPrint -- 458
					end -- 458
				end -- 458
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 459
				local frameTimedOut = false -- 460
				local watchdogMessage -- 460
				_G.print = capturePrint -- 461
				debug.sethook( -- 462
					function() -- 462
						if watchdogMessage == nil then -- 462
							watchdogMessage = checkEntryWatchdog() -- 463
						end -- 463
						if watchdogMessage ~= nil then -- 463
							error(watchdogMessage) -- 464
						end -- 464
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 464
							frameTimedOut = true -- 466
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 467
						end -- 467
					end, -- 462
					"", -- 469
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 469
				) -- 469
				local ok, runtimeErr = pcall(fn) -- 470
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 470
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 472
				else -- 472
					debug.sethook() -- 478
				end -- 478
				_G.print = previousGlobalPrint -- 480
				if not ok then -- 480
					local ____truncateCommandOutput_result_26 = truncateCommandOutput(table.concat(output, "\n")) -- 485
					local ____temp_27 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 486
					local ____temp_28 = frameTimedOut and "timeout" or "execute" -- 487
					local ____temp_25 -- 488
					if watchdogMessage ~= nil or frameTimedOut then -- 488
						____temp_25 = true -- 488
					else -- 488
						____temp_25 = nil -- 488
					end -- 488
					finish({ -- 482
						success = false, -- 483
						mode = "lua", -- 484
						output = ____truncateCommandOutput_result_26, -- 485
						message = ____temp_27, -- 486
						phase = ____temp_28, -- 487
						interrupted = ____temp_25 -- 488
					}) -- 488
					return -- 490
				end -- 490
				finish({ -- 492
					success = true, -- 492
					mode = "lua", -- 492
					output = truncateCommandOutput(table.concat(output, "\n")) -- 492
				}) -- 492
			end) -- 446
			Director.systemScheduler:schedule(function() -- 494
				if settled then -- 494
					return true -- 495
				end -- 495
				local watchdogMessage = checkEntryWatchdog() -- 496
				if watchdogMessage ~= nil then -- 496
					finish({ -- 498
						success = false, -- 499
						mode = "lua", -- 500
						output = truncateCommandOutput(table.concat(output, "\n")), -- 501
						message = watchdogMessage, -- 502
						phase = "execute", -- 503
						interrupted = true -- 504
					}) -- 504
					return true -- 506
				end -- 506
				if isCancelled and isCancelled(nil) then -- 506
					finish({ -- 509
						success = false, -- 510
						mode = "lua", -- 511
						output = truncateCommandOutput(table.concat(output, "\n")), -- 512
						message = "Lua command canceled", -- 513
						phase = "execute", -- 514
						interrupted = true -- 515
					}) -- 515
					return true -- 517
				end -- 517
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 517
					finish({ -- 520
						success = false, -- 521
						mode = "lua", -- 522
						output = truncateCommandOutput(table.concat(output, "\n")), -- 523
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 524
						phase = "timeout" -- 525
					}) -- 525
					return true -- 527
				end -- 527
				if commandRoutine == nil then -- 527
					finish({ -- 530
						success = false, -- 531
						mode = "lua", -- 532
						output = truncateCommandOutput(table.concat(output, "\n")), -- 533
						message = "Lua command coroutine is unavailable", -- 534
						phase = "execute" -- 535
					}) -- 535
					return true -- 537
				end -- 537
				local resumeSuccess, resumeResult = coroutine.resume(commandRoutine) -- 539
				if not resumeSuccess then -- 539
					finish({ -- 541
						success = false, -- 542
						mode = "lua", -- 543
						output = truncateCommandOutput(table.concat(output, "\n")), -- 544
						message = truncateCommandError(toStr(resumeResult)), -- 545
						phase = "execute" -- 546
					}) -- 546
					return true -- 548
				end -- 548
				return settled or resumeResult == true -- 550
			end) -- 494
		end -- 358
	) -- 358
end -- 101
function ____exports.executeCommand(req) -- 555
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 555
		local mode = req.mode -- 567
		if mode ~= "lua" and mode ~= "git" then -- 567
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 567
		end -- 567
		if mode == "lua" then -- 567
			return ____awaiter_resolve( -- 567
				nil, -- 567
				executeLuaCommand({ -- 572
					workDir = req.workDir, -- 573
					docLanguage = req.docLanguage, -- 574
					code = req.code or "", -- 575
					timeoutSeconds = math.max( -- 576
						1, -- 576
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 576
					), -- 576
					operationId = createOperationId(), -- 577
					taskId = req.taskId or 0, -- 578
					onProgress = req.onProgress, -- 579
					isCancelled = req.isCancelled -- 580
				}) -- 580
			) -- 580
		end -- 580
		local operationId = createOperationId() -- 583
		return ____awaiter_resolve( -- 583
			nil, -- 583
			executeGitCommand({ -- 584
				workDir = req.workDir, -- 585
				command = req.command or "", -- 586
				cwd = req.cwd, -- 587
				timeoutSeconds = math.max( -- 588
					1, -- 588
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 588
				), -- 588
				operationId = operationId, -- 589
				onProgress = req.onProgress, -- 590
				isCancelled = req.isCancelled -- 591
			}) -- 591
		) -- 591
	end) -- 591
end -- 555
return ____exports -- 555