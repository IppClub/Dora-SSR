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
local ____GodotScene = require("Agent.Tool.GodotScene") -- 13
local createGodotSceneInjection = ____GodotScene.createGodotSceneInjection -- 13
local ____GodotImport = require("Agent.Tool.GodotImport") -- 14
local createGodotImportInjection = ____GodotImport.createGodotImportInjection -- 14
local ____CommandContent = require("Agent.Tool.CommandContent") -- 15
local createCommandContent = ____CommandContent.createCommandContent -- 15
local ____EntryLease = require("Agent.Tool.EntryLease") -- 17
local acquireEntryLease = ____EntryLease.acquireEntryLease -- 17
local recordEntryLeaseRun = ____EntryLease.recordEntryLeaseRun -- 17
local ownsEntryLease = ____EntryLease.ownsEntryLease -- 17
local releaseEntryLease = ____EntryLease.releaseEntryLease -- 17
local ____CommandPreview = require("Agent.Tool.CommandPreview") -- 18
local createPreviewGameInjection = ____CommandPreview.createPreviewGameInjection -- 18
local ____VisionBudget = require("Agent.Tool.VisionBudget") -- 19
local getVisionBudgetState = ____VisionBudget.getVisionBudgetState -- 20
local getVisionTaskUsage = ____VisionBudget.getVisionTaskUsage -- 21
local VISION_MAX_CAPTURE_BATCHES = ____VisionBudget.VISION_MAX_CAPTURE_BATCHES -- 23
local VISION_MAX_CAPTURE_FRAMES = ____VisionBudget.VISION_MAX_CAPTURE_FRAMES -- 24
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 28
local function executeStudioLuaCommand(req) -- 37
	local usesPreviewGame = (string.match(req.code, "%f[%a_]previewGame%f[^%w_]%s*%(")) ~= nil -- 49
	local usesGodotImport = (string.match(req.code, "%f[%a_]importGodotAssets%f[^%w_]")) ~= nil -- 50
	if type(_studio_agent_tool_begin) ~= "function" or usesPreviewGame or usesGodotImport or (string.match(req.code, "%f[%a_]inspectGodotScene%f[^%w_]")) ~= nil then -- 50
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
end -- 37
local function executeLuaCommand(req) -- 102
	local code = __TS__StringTrim(req.code or "") -- 112
	if code == "" then -- 112
		return __TS__Promise.resolve({ -- 114
			success = false, -- 114
			mode = "lua", -- 114
			output = "", -- 114
			message = "missing code", -- 114
			phase = "validate" -- 114
		}) -- 114
	end -- 114
	local studioResult = executeStudioLuaCommand(__TS__ObjectAssign({}, req, {code = code})) -- 116
	if studioResult then -- 116
		return studioResult -- 117
	end -- 117
	local output = {} -- 118
	local entry = require("Script.Dev.Entry") -- 119
	local ownsEntryRuntime = false -- 120
	local contentAccessed = false -- 121
	local refreshTreeCalled = false -- 122
	local entryObjectBaseline = 0 -- 123
	local entryLuaRefBaseline = 0 -- 124
	local persistedVisionUsage -- 125
	local capturedBatches = 0 -- 126
	local capturedFrames = 0 -- 127
	local commandClosed = false -- 128
	local godotSceneResults = {} -- 129
	local godotImportResults = {} -- 130
	local lastPreviewResult -- 131
	local previewCleanup -- 132
	local restorePrint -- 133
	local function currentVisionUsage() -- 134
		if persistedVisionUsage == nil then -- 134
			persistedVisionUsage = getVisionTaskUsage(req.taskId) -- 135
		end -- 135
		return __TS__ObjectAssign({}, persistedVisionUsage, {captureBatchCount = persistedVisionUsage.captureBatchCount + capturedBatches, captureFrameCount = persistedVisionUsage.captureFrameCount + capturedFrames}) -- 136
	end -- 134
	local function reserveCapture(frameCount) -- 142
		local current = currentVisionUsage() -- 143
		if current.captureBatchCount >= VISION_MAX_CAPTURE_BATCHES or current.captureFrameCount + frameCount > VISION_MAX_CAPTURE_FRAMES then -- 143
			return { -- 145
				success = false, -- 146
				message = ((("Vision capture budget exhausted: " .. tostring(current.captureBatchCount)) .. " batches and ") .. tostring(current.captureFrameCount)) .. " frames already reserved", -- 147
				budget = getVisionBudgetState(current) -- 148
			} -- 148
		end -- 148
		capturedBatches = capturedBatches + 1 -- 151
		capturedFrames = capturedFrames + frameCount -- 152
		return { -- 153
			success = true, -- 153
			budget = getVisionBudgetState(currentVisionUsage()) -- 153
		} -- 153
	end -- 142
	local function acquireEntryRuntime() -- 155
		acquireEntryLease(req.operationId, entry) -- 156
		ownsEntryRuntime = true -- 157
	end -- 155
	local function stopOwnedEntry() -- 159
		if not ownsEntryRuntime then -- 159
			return nil -- 160
		end -- 160
		ownsEntryRuntime = false -- 161
		return releaseEntryLease(req.operationId, entry) -- 162
	end -- 159
	local function startEntryWatchdog() -- 164
		entryObjectBaseline = Dora.Object.count -- 165
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 166
	end -- 164
	local function checkEntryWatchdog() -- 168
		if not ownsEntryRuntime then -- 168
			return nil -- 169
		end -- 169
		local objectCount = Dora.Object.count -- 170
		local luaRefCount = Dora.Object.luaRefCount -- 171
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 172
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 173
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 174
		if not exceededTotal then -- 174
			return nil -- 177
		end -- 177
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 178
	end -- 168
	local function normalizeEntryFile(value) -- 182
		if not value or type(value) ~= "table" then -- 182
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 184
		end -- 184
		local descriptor = value -- 186
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 187
		if relativeFile == "" then -- 187
			relativeFile = "init" -- 188
		end -- 188
		if not isValidWorkspacePath(relativeFile) then -- 188
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 190
		end -- 190
		local fileName = Path(req.workDir, relativeFile) -- 192
		local ext = Path:getExt(fileName) -- 193
		if ext ~= "" then -- 193
			fileName = Path:replaceExt(fileName, "") -- 194
		end -- 194
		local luaFile = Path:replaceExt(fileName, "lua") -- 195
		if not Content:exist(luaFile) then -- 195
			error("Agent test entry was not built: " .. luaFile) -- 197
		end -- 197
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 199
		return { -- 200
			fileName = fileName, -- 201
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 202
		} -- 202
	end -- 182
	local function capturePrint(...) -- 205
		local values = {...} -- 205
		local parts = {} -- 206
		do -- 206
			local i = 0 -- 207
			while i < #values do -- 207
				parts[#parts + 1] = tostring(values[i + 1]) -- 208
				i = i + 1 -- 207
			end -- 207
		end -- 207
		output[#output + 1] = table.concat(parts, "\t") -- 210
	end -- 205
	local function refreshTree(path) -- 212
		refreshTreeCalled = true -- 213
		if path == nil then -- 213
			return refreshWorkspaceTree(req.workDir) -- 215
		end -- 215
		if type(path) ~= "string" then -- 215
			error("refreshTree expects a project-relative file path string or no argument") -- 218
		end -- 218
		return refreshWorkspaceTree(req.workDir, path) -- 220
	end -- 212
	local blockedDoraGlobals = {DB = true, HttpClient = true, HttpServer = true} -- 222
	local scopedContent = createCommandContent(req.workDir, req.docLanguage) -- 227
	local env = setmetatable( -- 228
		{ -- 228
			projectDir = req.workDir, -- 229
			inspectGodotScene = createGodotSceneInjection({ -- 230
				workDir = req.workDir, -- 231
				isCancelled = function() -- 232
					local ____commandClosed_13 = commandClosed -- 232
					if not ____commandClosed_13 then -- 232
						local ____this_12 -- 232
						____this_12 = req -- 232
						local ____opt_11 = ____this_12.isCancelled -- 232
						____commandClosed_13 = (____opt_11 and ____opt_11(____this_12)) == true -- 232
					end -- 232
					return ____commandClosed_13 -- 232
				end, -- 232
				print = capturePrint, -- 233
				onResult = function(result) -- 234
					godotSceneResults[#godotSceneResults + 1] = result -- 234
				end -- 234
			}), -- 234
			importGodotAssets = createGodotImportInjection({ -- 236
				workDir = req.workDir, -- 237
				isCancelled = function() -- 238
					local ____commandClosed_16 = commandClosed -- 238
					if not ____commandClosed_16 then -- 238
						local ____this_15 -- 238
						____this_15 = req -- 238
						local ____opt_14 = ____this_15.isCancelled -- 238
						____commandClosed_16 = (____opt_14 and ____opt_14(____this_15)) == true -- 238
					end -- 238
					return ____commandClosed_16 -- 238
				end, -- 238
				print = capturePrint, -- 239
				onResult = function(result) -- 240
					godotImportResults[#godotImportResults + 1] = result -- 241
					if result.importedCount > 0 then -- 241
						contentAccessed = true -- 242
					end -- 242
				end -- 240
			}), -- 240
			previewGame = createPreviewGameInjection( -- 246
				{ -- 246
					workDir = req.workDir, -- 247
					operationId = req.operationId, -- 248
					isCancelled = req.isCancelled, -- 249
					print = function(line) return capturePrint(line) end, -- 250
					reserveCapture = reserveCapture, -- 251
					registerCleanup = function(cleanup) -- 252
						previewCleanup = cleanup -- 252
					end, -- 252
					onResult = function(result) -- 253
						lastPreviewResult = result -- 254
					end -- 253
				}, -- 253
				entry -- 256
			), -- 256
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 257
				if type(moduleNameValue) ~= "string" then -- 257
					error("requireProjectModule expects a project module name string") -- 259
				end -- 259
				local moduleName = __TS__StringTrim(moduleNameValue) -- 261
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 261
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 263
				end -- 263
				local reloadModules = {moduleName} -- 265
				if reloadModulesValue ~= nil then -- 265
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 265
						error("requireProjectModule reloadModules must be an array of module names") -- 268
					end -- 268
					local items = reloadModulesValue -- 270
					do -- 270
						local i = 0 -- 271
						while i < #items do -- 271
							local item = items[i + 1] -- 272
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 272
								error("requireProjectModule reloadModules contains an invalid module name") -- 274
							end -- 274
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 274
								reloadModules[#reloadModules + 1] = item -- 276
							end -- 276
							i = i + 1 -- 271
						end -- 271
					end -- 271
				end -- 271
				local luaPackage = _G.package -- 279
				local previousPath = luaPackage.path -- 283
				local previousSearchPaths = Content.searchPaths -- 284
				local scopedSearchPaths = {req.workDir} -- 285
				do -- 285
					local i = 0 -- 286
					while i < #previousSearchPaths do -- 286
						local searchPath = previousSearchPaths[i + 1] -- 287
						if searchPath ~= req.workDir then -- 287
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 288
						end -- 288
						i = i + 1 -- 286
					end -- 286
				end -- 286
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 290
				Content.searchPaths = scopedSearchPaths -- 291
				do -- 291
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 291
						do -- 291
							local i = 0 -- 293
							while i < #reloadModules do -- 293
								local reloadName = reloadModules[i + 1] -- 294
								luaPackage.loaded[reloadName] = nil -- 295
								luaPackage.loaded[table.concat( -- 296
									__TS__StringSplit(reloadName, "/"), -- 296
									"." -- 296
								)] = nil -- 296
								luaPackage.loaded[table.concat( -- 297
									__TS__StringSplit(reloadName, "."), -- 297
									"/" -- 297
								)] = nil -- 297
								i = i + 1 -- 293
							end -- 293
						end -- 293
						return true, require(table.concat( -- 299
							__TS__StringSplit(moduleName, "/"), -- 299
							"." -- 299
						)) -- 299
					end) -- 299
					do -- 299
						Content.searchPaths = previousSearchPaths -- 301
						luaPackage.path = previousPath -- 302
					end -- 302
					if not ____try then -- 302
						error(____hasReturned, 0) -- 302
					end -- 302
					if ____try and ____hasReturned then -- 302
						return ____returnValue -- 292
					end -- 292
				end -- 292
			end, -- 257
			print = capturePrint, -- 305
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 306
			enterEntryAsync = function(value) -- 307
				local normalized = normalizeEntryFile(value) -- 308
				acquireEntryRuntime() -- 309
				entry.allClear() -- 310
				startEntryWatchdog() -- 311
				recordEntryLeaseRun(req.operationId, entry) -- 312
				local success, message = entry.enterEntryAsync({ -- 313
					entryName = normalized.entryName, -- 314
					fileName = normalized.fileName, -- 315
					workDir = req.workDir, -- 316
					projectRoot = req.workDir, -- 317
					runKind = "agent_test" -- 318
				}) -- 318
				return success, message -- 320
			end, -- 307
			stopEntry = function() -- 322
				if not ownsEntryRuntime or not ownsEntryLease(req.operationId, entry) then -- 322
					return false -- 323
				end -- 323
				return entry.stop() -- 324
			end, -- 322
			reportProgress = function(value, callbackValue) -- 326
				local ____callbackValue_17 = callbackValue -- 327
				if ____callbackValue_17 == nil then -- 327
					____callbackValue_17 = value -- 327
				end -- 327
				local actualValue = ____callbackValue_17 -- 327
				if not req.onProgress or not actualValue or type(actualValue) ~= "table" then -- 327
					return -- 328
				end -- 328
				local progress = actualValue -- 329
				local amount = type(progress.progress) == "number" and math.min( -- 330
					1, -- 331
					math.max(0, progress.progress) -- 331
				) or nil -- 331
				req:onProgress({ -- 333
					state = "running", -- 334
					mode = "lua", -- 335
					operationId = req.operationId, -- 336
					progress = amount, -- 337
					stage = type(progress.stage) == "string" and progress.stage or "lua", -- 338
					message = type(progress.message) == "string" and progress.message or "Lua command running" -- 339
				}) -- 339
			end -- 326
		}, -- 326
		{__index = function(_table, key) -- 342
			if key == "Content" then -- 342
				contentAccessed = true -- 345
				return scopedContent -- 346
			end -- 346
			if key == "refreshTree" then -- 346
				return refreshTree -- 349
			end -- 349
			local name = tostring(key) -- 351
			if blockedDoraGlobals[name] then -- 351
				return nil -- 352
			end -- 352
			return Dora[name] -- 353
		end} -- 343
	) -- 343
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 356
	if not fn then -- 356
		return __TS__Promise.resolve({ -- 358
			success = false, -- 359
			mode = "lua", -- 360
			output = truncateCommandOutput(table.concat(output, "\n")), -- 361
			message = truncateCommandError(toStr(compileErr)), -- 362
			phase = "compile" -- 363
		}) -- 363
	end -- 363
	return __TS__New( -- 366
		__TS__Promise, -- 366
		function(____, resolve) -- 366
			local settled = false -- 367
			local commandRoutine -- 368
			local startedAt = App.runningTime -- 369
			local onProgress = req.onProgress -- 370
			local isCancelled = req.isCancelled -- 371
			local function finish(result) -- 372
				if settled then -- 372
					return -- 373
				end -- 373
				settled = true -- 374
				commandClosed = true -- 375
				local cleanupError -- 376
				local cleanup = previewCleanup -- 377
				previewCleanup = nil -- 378
				do -- 378
					local function ____catch(e) -- 378
						cleanupError = "failed to release Agent preview: " .. tostring(e) -- 380
					end -- 380
					local ____try, ____hasReturned = pcall(function() -- 380
						if cleanup ~= nil then -- 380
							cleanup() -- 379
						end -- 379
					end) -- 379
					if not ____try then -- 379
						____catch(____hasReturned) -- 379
					end -- 379
				end -- 379
				if restorePrint ~= nil then -- 379
					restorePrint() -- 381
				end -- 381
				restorePrint = nil -- 382
				if not result.success and (result.interrupted == true or result.phase == "timeout") and (not entry.getCurrentEntryStatus().running or ownsEntryLease(req.operationId, entry)) then -- 382
					do -- 382
						local function ____catch(e) -- 382
							cleanupError = "failed to clear interrupted Lua command runtime: " .. tostring(e) -- 388
						end -- 388
						local ____try, ____hasReturned = pcall(function() -- 388
							entry.allClear() -- 386
						end) -- 386
						if not ____try then -- 386
							____catch(____hasReturned) -- 386
						end -- 386
					end -- 386
				end -- 386
				local entryCleanupError = stopOwnedEntry() -- 391
				if cleanupError == nil then -- 391
					cleanupError = entryCleanupError -- 392
				end -- 392
				if contentAccessed and not refreshTreeCalled and not refreshWorkspaceTree(req.workDir) then -- 392
					Log("Warn", "[execute_command] failed to refresh Web IDE tree after Lua command workDir=" .. req.workDir) -- 394
				end -- 394
				local ____lastPreviewResult_27 -- 396
				if lastPreviewResult then -- 396
					local ____lastPreviewResult_success_24 = lastPreviewResult.success -- 397
					local ____lastPreviewResult_message_25 = lastPreviewResult.message -- 398
					local ____lastPreviewResult_files_26 = lastPreviewResult.files -- 399
					local ____opt_22 = lastPreviewResult.frames -- 399
					____lastPreviewResult_27 = {success = ____lastPreviewResult_success_24, message = ____lastPreviewResult_message_25, files = ____lastPreviewResult_files_26, frameCount = ____opt_22 and #____opt_22} -- 396
				else -- 396
					____lastPreviewResult_27 = nil -- 401
				end -- 401
				local previewGame = ____lastPreviewResult_27 -- 396
				local visionFields = __TS__ObjectAssign( -- 402
					{}, -- 402
					#godotSceneResults > 0 and ({godotScenes = godotSceneResults}) or ({}), -- 403
					#godotImportResults > 0 and ({godotImports = godotImportResults}) or ({}), -- 404
					previewGame and ({previewGame = previewGame}) or ({}), -- 405
					capturedBatches > 0 and ({ -- 406
						visionCapture = {batchCount = capturedBatches, frameCount = capturedFrames}, -- 407
						visionBudget = getVisionBudgetState(currentVisionUsage()) -- 408
					}) or ({}) -- 408
				) -- 408
				if not result.success and cleanupError ~= nil then -- 408
					result.cleanupError = cleanupError -- 412
				elseif result.success and cleanupError ~= nil then -- 412
					resolve( -- 414
						nil, -- 414
						__TS__ObjectAssign({ -- 414
							success = false, -- 415
							mode = "lua", -- 416
							output = result.output, -- 417
							message = cleanupError, -- 418
							phase = "execute", -- 419
							cleanupError = cleanupError -- 420
						}, visionFields) -- 420
					) -- 420
					return -- 423
				end -- 423
				if result.success and __TS__ArraySome( -- 423
					godotSceneResults, -- 425
					function(____, scene) return not scene.success end -- 425
				) then -- 425
					resolve( -- 426
						nil, -- 426
						__TS__ObjectAssign({ -- 426
							success = false, -- 426
							mode = "lua", -- 426
							output = result.output, -- 426
							message = "inspectGodotScene failed; inspect godotScenes for diagnostics", -- 427
							phase = "execute" -- 427
						}, visionFields) -- 427
					) -- 427
					return -- 428
				end -- 428
				if result.success and __TS__ArraySome( -- 428
					godotImportResults, -- 430
					function(____, batch) return not batch.success end -- 430
				) then -- 430
					resolve( -- 431
						nil, -- 431
						__TS__ObjectAssign({ -- 431
							success = false, -- 431
							mode = "lua", -- 431
							output = result.output, -- 431
							message = "importGodotAssets failed; inspect godotImports for per-file results", -- 432
							phase = "execute" -- 432
						}, visionFields) -- 432
					) -- 432
					return -- 433
				end -- 433
				if result.success and lastPreviewResult and not lastPreviewResult.success then -- 433
					resolve( -- 436
						nil, -- 436
						__TS__ObjectAssign({ -- 436
							success = false, -- 437
							mode = "lua", -- 438
							output = result.output, -- 439
							message = "previewGame failed: " .. (lastPreviewResult.message or "unknown error"), -- 440
							phase = "execute" -- 441
						}, visionFields) -- 441
					) -- 441
					return -- 444
				end -- 444
				resolve( -- 446
					nil, -- 446
					__TS__ObjectAssign({}, result, visionFields) -- 446
				) -- 446
			end -- 372
			if onProgress then -- 372
				onProgress(nil, { -- 452
					state = "pending", -- 453
					mode = "lua", -- 454
					operationId = req.operationId, -- 455
					stage = "lua", -- 456
					message = "Lua command pending" -- 457
				}) -- 457
			end -- 457
			commandRoutine = once(function() -- 460
				if settled then -- 460
					return -- 461
				end -- 461
				if onProgress then -- 461
					onProgress(nil, { -- 463
						state = "running", -- 464
						mode = "lua", -- 465
						operationId = req.operationId, -- 466
						stage = "lua", -- 467
						message = "Lua command running" -- 468
					}) -- 468
				end -- 468
				local previousGlobalPrint = _G.print -- 471
				restorePrint = function() -- 472
					if _G.print == capturePrint then -- 472
						_G.print = previousGlobalPrint -- 472
					end -- 472
				end -- 472
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 473
				local frameTimedOut = false -- 474
				local watchdogMessage -- 474
				_G.print = capturePrint -- 475
				debug.sethook( -- 476
					function() -- 476
						if watchdogMessage == nil then -- 476
							watchdogMessage = checkEntryWatchdog() -- 477
						end -- 477
						if watchdogMessage ~= nil then -- 477
							error(watchdogMessage) -- 478
						end -- 478
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 478
							frameTimedOut = true -- 480
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 481
						end -- 481
					end, -- 476
					"", -- 483
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 483
				) -- 483
				local ok, runtimeErr = pcall(fn) -- 484
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 484
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 486
				else -- 486
					debug.sethook() -- 492
				end -- 492
				_G.print = previousGlobalPrint -- 494
				if not ok then -- 494
					local ____truncateCommandOutput_result_29 = truncateCommandOutput(table.concat(output, "\n")) -- 499
					local ____temp_30 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 500
					local ____temp_31 = frameTimedOut and "timeout" or "execute" -- 501
					local ____temp_28 -- 502
					if watchdogMessage ~= nil or frameTimedOut then -- 502
						____temp_28 = true -- 502
					else -- 502
						____temp_28 = nil -- 502
					end -- 502
					finish({ -- 496
						success = false, -- 497
						mode = "lua", -- 498
						output = ____truncateCommandOutput_result_29, -- 499
						message = ____temp_30, -- 500
						phase = ____temp_31, -- 501
						interrupted = ____temp_28 -- 502
					}) -- 502
					return -- 504
				end -- 504
				finish({ -- 506
					success = true, -- 506
					mode = "lua", -- 506
					output = truncateCommandOutput(table.concat(output, "\n")) -- 506
				}) -- 506
			end) -- 460
			Director.systemScheduler:schedule(function() -- 508
				if settled then -- 508
					return true -- 509
				end -- 509
				local watchdogMessage = checkEntryWatchdog() -- 510
				if watchdogMessage ~= nil then -- 510
					finish({ -- 512
						success = false, -- 513
						mode = "lua", -- 514
						output = truncateCommandOutput(table.concat(output, "\n")), -- 515
						message = watchdogMessage, -- 516
						phase = "execute", -- 517
						interrupted = true -- 518
					}) -- 518
					return true -- 520
				end -- 520
				if isCancelled and isCancelled(nil) then -- 520
					finish({ -- 523
						success = false, -- 524
						mode = "lua", -- 525
						output = truncateCommandOutput(table.concat(output, "\n")), -- 526
						message = "Lua command canceled", -- 527
						phase = "execute", -- 528
						interrupted = true -- 529
					}) -- 529
					return true -- 531
				end -- 531
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 531
					finish({ -- 534
						success = false, -- 535
						mode = "lua", -- 536
						output = truncateCommandOutput(table.concat(output, "\n")), -- 537
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 538
						phase = "timeout" -- 539
					}) -- 539
					return true -- 541
				end -- 541
				if commandRoutine == nil then -- 541
					finish({ -- 544
						success = false, -- 545
						mode = "lua", -- 546
						output = truncateCommandOutput(table.concat(output, "\n")), -- 547
						message = "Lua command coroutine is unavailable", -- 548
						phase = "execute" -- 549
					}) -- 549
					return true -- 551
				end -- 551
				local resumeSuccess, resumeResult = coroutine.resume(commandRoutine) -- 553
				if not resumeSuccess then -- 553
					finish({ -- 555
						success = false, -- 556
						mode = "lua", -- 557
						output = truncateCommandOutput(table.concat(output, "\n")), -- 558
						message = truncateCommandError(toStr(resumeResult)), -- 559
						phase = "execute" -- 560
					}) -- 560
					return true -- 562
				end -- 562
				return settled or resumeResult == true -- 564
			end) -- 508
		end -- 366
	) -- 366
end -- 102
function ____exports.executeCommand(req) -- 569
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 569
		local mode = req.mode -- 581
		if mode ~= "lua" and mode ~= "git" then -- 581
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 581
		end -- 581
		if mode == "lua" then -- 581
			return ____awaiter_resolve( -- 581
				nil, -- 581
				executeLuaCommand({ -- 586
					workDir = req.workDir, -- 587
					docLanguage = req.docLanguage, -- 588
					code = req.code or "", -- 589
					timeoutSeconds = math.max( -- 590
						1, -- 590
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 590
					), -- 590
					operationId = createOperationId(), -- 591
					taskId = req.taskId or 0, -- 592
					onProgress = req.onProgress, -- 593
					isCancelled = req.isCancelled -- 594
				}) -- 594
			) -- 594
		end -- 594
		local operationId = createOperationId() -- 597
		return ____awaiter_resolve( -- 597
			nil, -- 597
			executeGitCommand({ -- 598
				workDir = req.workDir, -- 599
				command = req.command or "", -- 600
				cwd = req.cwd, -- 601
				timeoutSeconds = math.max( -- 602
					1, -- 602
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 602
				), -- 602
				operationId = operationId, -- 603
				onProgress = req.onProgress, -- 604
				isCancelled = req.isCancelled -- 605
			}) -- 605
		) -- 605
	end) -- 605
end -- 569
return ____exports -- 569