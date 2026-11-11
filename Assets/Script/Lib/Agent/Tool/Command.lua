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
local ____GodotRuntimeScene = require("Agent.Tool.GodotRuntimeScene") -- 13
local createGodotRuntimeSceneInjection = ____GodotRuntimeScene.createGodotRuntimeSceneInjection -- 13
local ____GodotScene = require("Agent.Tool.GodotScene") -- 14
local createGodotSceneInjection = ____GodotScene.createGodotSceneInjection -- 14
local ____GodotImport = require("Agent.Tool.GodotImport") -- 15
local createGodotImportInjection = ____GodotImport.createGodotImportInjection -- 15
local ____CommandContent = require("Agent.Tool.CommandContent") -- 16
local createCommandContent = ____CommandContent.createCommandContent -- 16
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
	local usesGodotImport = (string.match(req.code, "%f[%a_]importGodotAssets%f[^%w_]")) ~= nil -- 51
	if type(_studio_agent_tool_begin) ~= "function" or usesPreviewGame or usesGodotImport or ((string.match(req.code, "%f[%a_]inspectGodotScene%f[^%w_]")) ~= nil or (string.match(req.code, "%f[%a_]inspectGodotRuntimeScene%f[^%w_]")) ~= nil) then -- 51
		return nil -- 52
	end -- 52
	local onProgress = req.onProgress -- 53
	local isCancelled = req.isCancelled -- 54
	return __TS__New( -- 55
		__TS__Promise, -- 55
		function(____, resolve) -- 55
			local requestId -- 56
			local settled = false -- 57
			local function finish(result) -- 58
				if settled then -- 58
					return -- 59
				end -- 59
				settled = true -- 60
				resolve(nil, result) -- 61
			end -- 58
			if onProgress ~= nil then -- 58
				onProgress(nil, { -- 63
					state = "pending", -- 63
					mode = "lua", -- 63
					operationId = req.operationId, -- 63
					stage = "player", -- 63
					message = "Lua command pending in isolated game Player" -- 63
				}) -- 63
			end -- 63
			local routine = once(function() -- 64
				do -- 64
					local function ____catch(e) -- 64
						if requestId then -- 64
							if _studio_agent_tool_cancel ~= nil then -- 64
								_studio_agent_tool_cancel(requestId) -- 88
							end -- 88
							requestId = nil -- 88
						end -- 88
						local message = truncateCommandError(toStr(e)) -- 89
						local ____message_9 = message -- 90
						local ____temp_10 = (string.find(message, "timed out", nil, true) or 0) - 1 >= 0 and "timeout" or "execute" -- 90
						local ____temp_8 -- 90
						if (string.find(message, "canceled", nil, true) or 0) - 1 >= 0 then -- 90
							____temp_8 = true -- 90
						else -- 90
							____temp_8 = nil -- 90
						end -- 90
						finish({ -- 90
							success = false, -- 90
							mode = "lua", -- 90
							output = "", -- 90
							message = ____message_9, -- 90
							phase = ____temp_10, -- 90
							interrupted = ____temp_8 -- 90
						}) -- 90
					end -- 90
					local ____try, ____hasReturned = pcall(function() -- 90
						local options = safeJsonEncode({code = req.code, timeoutSeconds = req.timeoutSeconds}) -- 66
						if not options then -- 66
							error("failed to encode Studio Agent Lua command") -- 67
						end -- 67
						requestId = _studio_agent_tool_begin( -- 68
							"execute-lua", -- 68
							Path(req.workDir, ".agent", "command.lua"), -- 68
							options, -- 68
							req.workDir -- 68
						) -- 68
						if onProgress ~= nil then -- 68
							onProgress(nil, { -- 69
								state = "running", -- 69
								mode = "lua", -- 69
								operationId = req.operationId, -- 69
								stage = "player", -- 69
								message = "Lua command running in isolated game Player" -- 69
							}) -- 69
						end -- 69
						local deadline = App.runningTime + req.timeoutSeconds -- 70
						local answer -- 71
						while not answer do -- 71
							if isCancelled and isCancelled(nil) then -- 71
								error("Lua command canceled") -- 73
							end -- 73
							if App.runningTime >= deadline then -- 73
								error(("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds") -- 74
							end -- 74
							answer = _studio_agent_tool_poll and _studio_agent_tool_poll(requestId) -- 75
							if not answer then -- 75
								sleep() -- 76
							end -- 76
						end -- 76
						requestId = nil -- 78
						if not answer.success then -- 78
							error(answer.message or "Studio Agent Lua Player failed") -- 79
						end -- 79
						local decoded = safeJsonDecode(answer.resultJSON or "") -- 80
						local value = decoded -- 81
						if not value or type(value.success) ~= "boolean" or type(value.output) ~= "string" or value.message ~= nil and type(value.message) ~= "string" or value.phase ~= nil and value.phase ~= "compile" and value.phase ~= "execute" and value.phase ~= "timeout" and value.phase ~= "validate" then -- 81
							error("Invalid Studio Agent Lua Player result") -- 84
						end -- 84
						if value.success then -- 84
							finish({ -- 85
								success = true, -- 85
								mode = "lua", -- 85
								output = truncateCommandOutput(value.output) -- 85
							}) -- 85
						else -- 85
							finish({ -- 86
								success = false, -- 86
								mode = "lua", -- 86
								output = truncateCommandOutput(value.output), -- 86
								message = truncateCommandError(value.message or "Lua command failed"), -- 86
								phase = value.phase or "execute" -- 86
							}) -- 86
						end -- 86
					end) -- 86
					if not ____try then -- 86
						____catch(____hasReturned) -- 86
					end -- 86
				end -- 86
			end) -- 64
			Director.systemScheduler:schedule(function() -- 93
				if settled then -- 93
					return true -- 94
				end -- 94
				local ok, result = coroutine.resume(routine) -- 95
				if not ok then -- 95
					finish({ -- 96
						success = false, -- 96
						mode = "lua", -- 96
						output = "", -- 96
						message = truncateCommandError(toStr(result)), -- 96
						phase = "execute" -- 96
					}) -- 96
					return true -- 96
				end -- 96
				return settled or result == true -- 97
			end) -- 93
		end -- 55
	) -- 55
end -- 38
local function executeLuaCommand(req) -- 103
	local code = __TS__StringTrim(req.code or "") -- 113
	if code == "" then -- 113
		return __TS__Promise.resolve({ -- 115
			success = false, -- 115
			mode = "lua", -- 115
			output = "", -- 115
			message = "missing code", -- 115
			phase = "validate" -- 115
		}) -- 115
	end -- 115
	local studioResult = executeStudioLuaCommand(__TS__ObjectAssign({}, req, {code = code})) -- 117
	if studioResult then -- 117
		return studioResult -- 118
	end -- 118
	local output = {} -- 119
	local entry = require("Script.Dev.Entry") -- 120
	local ownsEntryRuntime = false -- 121
	local contentAccessed = false -- 122
	local refreshTreeCalled = false -- 123
	local entryObjectBaseline = 0 -- 124
	local entryLuaRefBaseline = 0 -- 125
	local persistedVisionUsage -- 126
	local capturedBatches = 0 -- 127
	local capturedFrames = 0 -- 128
	local commandClosed = false -- 129
	local godotSceneResults = {} -- 130
	local godotRuntimeSceneResults = {} -- 131
	local godotImportResults = {} -- 132
	local lastPreviewResult -- 133
	local previewCleanup -- 134
	local restorePrint -- 135
	local function currentVisionUsage() -- 136
		if persistedVisionUsage == nil then -- 136
			persistedVisionUsage = getVisionTaskUsage(req.taskId) -- 137
		end -- 137
		return __TS__ObjectAssign({}, persistedVisionUsage, {captureBatchCount = persistedVisionUsage.captureBatchCount + capturedBatches, captureFrameCount = persistedVisionUsage.captureFrameCount + capturedFrames}) -- 138
	end -- 136
	local function reserveCapture(frameCount) -- 144
		local current = currentVisionUsage() -- 145
		if current.captureBatchCount >= VISION_MAX_CAPTURE_BATCHES or current.captureFrameCount + frameCount > VISION_MAX_CAPTURE_FRAMES then -- 145
			return { -- 147
				success = false, -- 148
				message = ((("Vision capture budget exhausted: " .. tostring(current.captureBatchCount)) .. " batches and ") .. tostring(current.captureFrameCount)) .. " frames already reserved", -- 149
				budget = getVisionBudgetState(current) -- 150
			} -- 150
		end -- 150
		capturedBatches = capturedBatches + 1 -- 153
		capturedFrames = capturedFrames + frameCount -- 154
		return { -- 155
			success = true, -- 155
			budget = getVisionBudgetState(currentVisionUsage()) -- 155
		} -- 155
	end -- 144
	local function acquireEntryRuntime() -- 157
		acquireEntryLease(req.operationId, entry) -- 158
		ownsEntryRuntime = true -- 159
	end -- 157
	local function stopOwnedEntry() -- 161
		if not ownsEntryRuntime then -- 161
			return nil -- 162
		end -- 162
		ownsEntryRuntime = false -- 163
		return releaseEntryLease(req.operationId, entry) -- 164
	end -- 161
	local function startEntryWatchdog() -- 166
		entryObjectBaseline = Dora.Object.count -- 167
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 168
	end -- 166
	local function checkEntryWatchdog() -- 170
		if not ownsEntryRuntime then -- 170
			return nil -- 171
		end -- 171
		local objectCount = Dora.Object.count -- 172
		local luaRefCount = Dora.Object.luaRefCount -- 173
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 174
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 175
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 176
		if not exceededTotal then -- 176
			return nil -- 179
		end -- 179
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 180
	end -- 170
	local function normalizeEntryFile(value) -- 184
		if not value or type(value) ~= "table" then -- 184
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 186
		end -- 186
		local descriptor = value -- 188
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 189
		if relativeFile == "" then -- 189
			relativeFile = "init" -- 190
		end -- 190
		if not isValidWorkspacePath(relativeFile) then -- 190
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 192
		end -- 192
		local fileName = Path(req.workDir, relativeFile) -- 194
		local ext = Path:getExt(fileName) -- 195
		if ext ~= "" then -- 195
			fileName = Path:replaceExt(fileName, "") -- 196
		end -- 196
		local luaFile = Path:replaceExt(fileName, "lua") -- 197
		if not Content:exist(luaFile) then -- 197
			error("Agent test entry was not built: " .. luaFile) -- 199
		end -- 199
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 201
		return { -- 202
			fileName = fileName, -- 203
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 204
		} -- 204
	end -- 184
	local function capturePrint(...) -- 207
		local values = {...} -- 207
		local parts = {} -- 208
		do -- 208
			local i = 0 -- 209
			while i < #values do -- 209
				parts[#parts + 1] = tostring(values[i + 1]) -- 210
				i = i + 1 -- 209
			end -- 209
		end -- 209
		output[#output + 1] = table.concat(parts, "\t") -- 212
	end -- 207
	local function refreshTree(path) -- 214
		refreshTreeCalled = true -- 215
		if path == nil then -- 215
			return refreshWorkspaceTree(req.workDir) -- 217
		end -- 217
		if type(path) ~= "string" then -- 217
			error("refreshTree expects a project-relative file path string or no argument") -- 220
		end -- 220
		return refreshWorkspaceTree(req.workDir, path) -- 222
	end -- 214
	local blockedDoraGlobals = {DB = true, HttpClient = true, HttpServer = true} -- 224
	local scopedContent = createCommandContent(req.workDir, req.docLanguage) -- 229
	local env = setmetatable( -- 230
		{ -- 230
			projectDir = req.workDir, -- 231
			inspectGodotRuntimeScene = createGodotRuntimeSceneInjection({ -- 232
				workDir = req.workDir, -- 233
				isCancelled = function() -- 234
					local ____commandClosed_13 = commandClosed -- 234
					if not ____commandClosed_13 then -- 234
						local ____this_12 -- 234
						____this_12 = req -- 234
						local ____opt_11 = ____this_12.isCancelled -- 234
						____commandClosed_13 = (____opt_11 and ____opt_11(____this_12)) == true -- 234
					end -- 234
					return ____commandClosed_13 -- 234
				end, -- 234
				print = capturePrint, -- 235
				onResult = function(result) -- 236
					godotRuntimeSceneResults[#godotRuntimeSceneResults + 1] = result -- 236
				end -- 236
			}), -- 236
			inspectGodotScene = createGodotSceneInjection({ -- 238
				workDir = req.workDir, -- 239
				isCancelled = function() -- 240
					local ____commandClosed_16 = commandClosed -- 240
					if not ____commandClosed_16 then -- 240
						local ____this_15 -- 240
						____this_15 = req -- 240
						local ____opt_14 = ____this_15.isCancelled -- 240
						____commandClosed_16 = (____opt_14 and ____opt_14(____this_15)) == true -- 240
					end -- 240
					return ____commandClosed_16 -- 240
				end, -- 240
				print = capturePrint, -- 241
				onResult = function(result) -- 242
					godotSceneResults[#godotSceneResults + 1] = result -- 242
				end -- 242
			}), -- 242
			importGodotAssets = createGodotImportInjection({ -- 244
				workDir = req.workDir, -- 245
				isCancelled = function() -- 246
					local ____commandClosed_19 = commandClosed -- 246
					if not ____commandClosed_19 then -- 246
						local ____this_18 -- 246
						____this_18 = req -- 246
						local ____opt_17 = ____this_18.isCancelled -- 246
						____commandClosed_19 = (____opt_17 and ____opt_17(____this_18)) == true -- 246
					end -- 246
					return ____commandClosed_19 -- 246
				end, -- 246
				print = capturePrint, -- 247
				onResult = function(result) -- 248
					godotImportResults[#godotImportResults + 1] = result -- 249
					if result.importedCount > 0 then -- 249
						contentAccessed = true -- 250
					end -- 250
				end -- 248
			}), -- 248
			previewGame = createPreviewGameInjection( -- 254
				{ -- 254
					workDir = req.workDir, -- 255
					operationId = req.operationId, -- 256
					isCancelled = req.isCancelled, -- 257
					print = function(line) return capturePrint(line) end, -- 258
					reserveCapture = reserveCapture, -- 259
					registerCleanup = function(cleanup) -- 260
						previewCleanup = cleanup -- 260
					end, -- 260
					onResult = function(result) -- 261
						lastPreviewResult = result -- 262
					end -- 261
				}, -- 261
				entry -- 264
			), -- 264
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 265
				if type(moduleNameValue) ~= "string" then -- 265
					error("requireProjectModule expects a project module name string") -- 267
				end -- 267
				local moduleName = __TS__StringTrim(moduleNameValue) -- 269
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 269
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 271
				end -- 271
				local reloadModules = {moduleName} -- 273
				if reloadModulesValue ~= nil then -- 273
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 273
						error("requireProjectModule reloadModules must be an array of module names") -- 276
					end -- 276
					local items = reloadModulesValue -- 278
					do -- 278
						local i = 0 -- 279
						while i < #items do -- 279
							local item = items[i + 1] -- 280
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 280
								error("requireProjectModule reloadModules contains an invalid module name") -- 282
							end -- 282
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 282
								reloadModules[#reloadModules + 1] = item -- 284
							end -- 284
							i = i + 1 -- 279
						end -- 279
					end -- 279
				end -- 279
				local luaPackage = _G.package -- 287
				local previousPath = luaPackage.path -- 291
				local previousSearchPaths = Content.searchPaths -- 292
				local scopedSearchPaths = {req.workDir} -- 293
				do -- 293
					local i = 0 -- 294
					while i < #previousSearchPaths do -- 294
						local searchPath = previousSearchPaths[i + 1] -- 295
						if searchPath ~= req.workDir then -- 295
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 296
						end -- 296
						i = i + 1 -- 294
					end -- 294
				end -- 294
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 298
				Content.searchPaths = scopedSearchPaths -- 299
				do -- 299
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 299
						do -- 299
							local i = 0 -- 301
							while i < #reloadModules do -- 301
								local reloadName = reloadModules[i + 1] -- 302
								luaPackage.loaded[reloadName] = nil -- 303
								luaPackage.loaded[table.concat( -- 304
									__TS__StringSplit(reloadName, "/"), -- 304
									"." -- 304
								)] = nil -- 304
								luaPackage.loaded[table.concat( -- 305
									__TS__StringSplit(reloadName, "."), -- 305
									"/" -- 305
								)] = nil -- 305
								i = i + 1 -- 301
							end -- 301
						end -- 301
						return true, require(table.concat( -- 307
							__TS__StringSplit(moduleName, "/"), -- 307
							"." -- 307
						)) -- 307
					end) -- 307
					do -- 307
						Content.searchPaths = previousSearchPaths -- 309
						luaPackage.path = previousPath -- 310
					end -- 310
					if not ____try then -- 310
						error(____hasReturned, 0) -- 310
					end -- 310
					if ____try and ____hasReturned then -- 310
						return ____returnValue -- 300
					end -- 300
				end -- 300
			end, -- 265
			print = capturePrint, -- 313
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 314
			enterEntryAsync = function(value) -- 315
				local normalized = normalizeEntryFile(value) -- 316
				acquireEntryRuntime() -- 317
				entry.allClear() -- 318
				startEntryWatchdog() -- 319
				recordEntryLeaseRun(req.operationId, entry) -- 320
				local success, message = entry.enterEntryAsync({ -- 321
					entryName = normalized.entryName, -- 322
					fileName = normalized.fileName, -- 323
					workDir = req.workDir, -- 324
					projectRoot = req.workDir, -- 325
					runKind = "agent_test" -- 326
				}) -- 326
				return success, message -- 328
			end, -- 315
			stopEntry = function() -- 330
				if not ownsEntryRuntime or not ownsEntryLease(req.operationId, entry) then -- 330
					return false -- 331
				end -- 331
				return entry.stop() -- 332
			end, -- 330
			reportProgress = function(value, callbackValue) -- 334
				local ____callbackValue_20 = callbackValue -- 335
				if ____callbackValue_20 == nil then -- 335
					____callbackValue_20 = value -- 335
				end -- 335
				local actualValue = ____callbackValue_20 -- 335
				if not req.onProgress or not actualValue or type(actualValue) ~= "table" then -- 335
					return -- 336
				end -- 336
				local progress = actualValue -- 337
				local amount = type(progress.progress) == "number" and math.min( -- 338
					1, -- 339
					math.max(0, progress.progress) -- 339
				) or nil -- 339
				req:onProgress({ -- 341
					state = "running", -- 342
					mode = "lua", -- 343
					operationId = req.operationId, -- 344
					progress = amount, -- 345
					stage = type(progress.stage) == "string" and progress.stage or "lua", -- 346
					message = type(progress.message) == "string" and progress.message or "Lua command running" -- 347
				}) -- 347
			end -- 334
		}, -- 334
		{__index = function(_table, key) -- 350
			if key == "Content" then -- 350
				contentAccessed = true -- 353
				return scopedContent -- 354
			end -- 354
			if key == "refreshTree" then -- 354
				return refreshTree -- 357
			end -- 357
			local name = tostring(key) -- 359
			if blockedDoraGlobals[name] then -- 359
				return nil -- 360
			end -- 360
			return Dora[name] -- 361
		end} -- 351
	) -- 351
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 364
	if not fn then -- 364
		return __TS__Promise.resolve({ -- 366
			success = false, -- 367
			mode = "lua", -- 368
			output = truncateCommandOutput(table.concat(output, "\n")), -- 369
			message = truncateCommandError(toStr(compileErr)), -- 370
			phase = "compile" -- 371
		}) -- 371
	end -- 371
	return __TS__New( -- 374
		__TS__Promise, -- 374
		function(____, resolve) -- 374
			local settled = false -- 375
			local commandRoutine -- 376
			local startedAt = App.runningTime -- 377
			local onProgress = req.onProgress -- 378
			local isCancelled = req.isCancelled -- 379
			local function finish(result) -- 380
				if settled then -- 380
					return -- 381
				end -- 381
				settled = true -- 382
				commandClosed = true -- 383
				local cleanupError -- 384
				local cleanup = previewCleanup -- 385
				previewCleanup = nil -- 386
				do -- 386
					local function ____catch(e) -- 386
						cleanupError = "failed to release Agent preview: " .. tostring(e) -- 388
					end -- 388
					local ____try, ____hasReturned = pcall(function() -- 388
						if cleanup ~= nil then -- 388
							cleanup() -- 387
						end -- 387
					end) -- 387
					if not ____try then -- 387
						____catch(____hasReturned) -- 387
					end -- 387
				end -- 387
				if restorePrint ~= nil then -- 387
					restorePrint() -- 389
				end -- 389
				restorePrint = nil -- 390
				if not result.success and (result.interrupted == true or result.phase == "timeout") and (not entry.getCurrentEntryStatus().running or ownsEntryLease(req.operationId, entry)) then -- 390
					do -- 390
						local function ____catch(e) -- 390
							cleanupError = "failed to clear interrupted Lua command runtime: " .. tostring(e) -- 396
						end -- 396
						local ____try, ____hasReturned = pcall(function() -- 396
							entry.allClear() -- 394
						end) -- 394
						if not ____try then -- 394
							____catch(____hasReturned) -- 394
						end -- 394
					end -- 394
				end -- 394
				local entryCleanupError = stopOwnedEntry() -- 399
				if cleanupError == nil then -- 399
					cleanupError = entryCleanupError -- 400
				end -- 400
				if contentAccessed and not refreshTreeCalled and not refreshWorkspaceTree(req.workDir) then -- 400
					Log("Warn", "[execute_command] failed to refresh Web IDE tree after Lua command workDir=" .. req.workDir) -- 402
				end -- 402
				local ____lastPreviewResult_30 -- 404
				if lastPreviewResult then -- 404
					local ____lastPreviewResult_success_27 = lastPreviewResult.success -- 405
					local ____lastPreviewResult_message_28 = lastPreviewResult.message -- 406
					local ____lastPreviewResult_files_29 = lastPreviewResult.files -- 407
					local ____opt_25 = lastPreviewResult.frames -- 407
					____lastPreviewResult_30 = {success = ____lastPreviewResult_success_27, message = ____lastPreviewResult_message_28, files = ____lastPreviewResult_files_29, frameCount = ____opt_25 and #____opt_25} -- 404
				else -- 404
					____lastPreviewResult_30 = nil -- 409
				end -- 409
				local previewGame = ____lastPreviewResult_30 -- 404
				local visionFields = __TS__ObjectAssign( -- 410
					{}, -- 410
					#godotRuntimeSceneResults > 0 and ({godotRuntimeScenes = godotRuntimeSceneResults}) or ({}), -- 411
					#godotSceneResults > 0 and ({godotScenes = godotSceneResults}) or ({}), -- 412
					#godotImportResults > 0 and ({godotImports = godotImportResults}) or ({}), -- 413
					previewGame and ({previewGame = previewGame}) or ({}), -- 414
					capturedBatches > 0 and ({ -- 415
						visionCapture = {batchCount = capturedBatches, frameCount = capturedFrames}, -- 416
						visionBudget = getVisionBudgetState(currentVisionUsage()) -- 417
					}) or ({}) -- 417
				) -- 417
				if not result.success and cleanupError ~= nil then -- 417
					result.cleanupError = cleanupError -- 421
				elseif result.success and cleanupError ~= nil then -- 421
					resolve( -- 423
						nil, -- 423
						__TS__ObjectAssign({ -- 423
							success = false, -- 424
							mode = "lua", -- 425
							output = result.output, -- 426
							message = cleanupError, -- 427
							phase = "execute", -- 428
							cleanupError = cleanupError -- 429
						}, visionFields) -- 429
					) -- 429
					return -- 432
				end -- 432
				if result.success and __TS__ArraySome( -- 432
					godotRuntimeSceneResults, -- 434
					function(____, scene) return not scene.success end -- 434
				) then -- 434
					resolve( -- 435
						nil, -- 435
						__TS__ObjectAssign({ -- 435
							success = false, -- 435
							mode = "lua", -- 435
							output = result.output, -- 435
							message = "inspectGodotRuntimeScene failed; inspect godotRuntimeScenes for diagnostics", -- 436
							phase = "execute" -- 436
						}, visionFields) -- 436
					) -- 436
					return -- 437
				end -- 437
				if result.success and __TS__ArraySome( -- 437
					godotSceneResults, -- 439
					function(____, scene) return not scene.success end -- 439
				) then -- 439
					resolve( -- 440
						nil, -- 440
						__TS__ObjectAssign({ -- 440
							success = false, -- 440
							mode = "lua", -- 440
							output = result.output, -- 440
							message = "inspectGodotScene failed; inspect godotScenes for diagnostics", -- 441
							phase = "execute" -- 441
						}, visionFields) -- 441
					) -- 441
					return -- 442
				end -- 442
				if result.success and __TS__ArraySome( -- 442
					godotImportResults, -- 444
					function(____, batch) return not batch.success end -- 444
				) then -- 444
					resolve( -- 445
						nil, -- 445
						__TS__ObjectAssign({ -- 445
							success = false, -- 445
							mode = "lua", -- 445
							output = result.output, -- 445
							message = "importGodotAssets failed; inspect godotImports for per-file results", -- 446
							phase = "execute" -- 446
						}, visionFields) -- 446
					) -- 446
					return -- 447
				end -- 447
				if result.success and lastPreviewResult and not lastPreviewResult.success then -- 447
					resolve( -- 450
						nil, -- 450
						__TS__ObjectAssign({ -- 450
							success = false, -- 451
							mode = "lua", -- 452
							output = result.output, -- 453
							message = "previewGame failed: " .. (lastPreviewResult.message or "unknown error"), -- 454
							phase = "execute" -- 455
						}, visionFields) -- 455
					) -- 455
					return -- 458
				end -- 458
				resolve( -- 460
					nil, -- 460
					__TS__ObjectAssign({}, result, visionFields) -- 460
				) -- 460
			end -- 380
			if onProgress then -- 380
				onProgress(nil, { -- 466
					state = "pending", -- 467
					mode = "lua", -- 468
					operationId = req.operationId, -- 469
					stage = "lua", -- 470
					message = "Lua command pending" -- 471
				}) -- 471
			end -- 471
			commandRoutine = once(function() -- 474
				if settled then -- 474
					return -- 475
				end -- 475
				if onProgress then -- 475
					onProgress(nil, { -- 477
						state = "running", -- 478
						mode = "lua", -- 479
						operationId = req.operationId, -- 480
						stage = "lua", -- 481
						message = "Lua command running" -- 482
					}) -- 482
				end -- 482
				local previousGlobalPrint = _G.print -- 485
				restorePrint = function() -- 486
					if _G.print == capturePrint then -- 486
						_G.print = previousGlobalPrint -- 486
					end -- 486
				end -- 486
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 487
				local frameTimedOut = false -- 488
				local watchdogMessage -- 488
				_G.print = capturePrint -- 489
				debug.sethook( -- 490
					function() -- 490
						if watchdogMessage == nil then -- 490
							watchdogMessage = checkEntryWatchdog() -- 491
						end -- 491
						if watchdogMessage ~= nil then -- 491
							error(watchdogMessage) -- 492
						end -- 492
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 492
							frameTimedOut = true -- 494
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 495
						end -- 495
					end, -- 490
					"", -- 497
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 497
				) -- 497
				local ok, runtimeErr = pcall(fn) -- 498
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 498
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 500
				else -- 500
					debug.sethook() -- 506
				end -- 506
				_G.print = previousGlobalPrint -- 508
				if not ok then -- 508
					local ____truncateCommandOutput_result_32 = truncateCommandOutput(table.concat(output, "\n")) -- 513
					local ____temp_33 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 514
					local ____temp_34 = frameTimedOut and "timeout" or "execute" -- 515
					local ____temp_31 -- 516
					if watchdogMessage ~= nil or frameTimedOut then -- 516
						____temp_31 = true -- 516
					else -- 516
						____temp_31 = nil -- 516
					end -- 516
					finish({ -- 510
						success = false, -- 511
						mode = "lua", -- 512
						output = ____truncateCommandOutput_result_32, -- 513
						message = ____temp_33, -- 514
						phase = ____temp_34, -- 515
						interrupted = ____temp_31 -- 516
					}) -- 516
					return -- 518
				end -- 518
				finish({ -- 520
					success = true, -- 520
					mode = "lua", -- 520
					output = truncateCommandOutput(table.concat(output, "\n")) -- 520
				}) -- 520
			end) -- 474
			Director.systemScheduler:schedule(function() -- 522
				if settled then -- 522
					return true -- 523
				end -- 523
				local watchdogMessage = checkEntryWatchdog() -- 524
				if watchdogMessage ~= nil then -- 524
					finish({ -- 526
						success = false, -- 527
						mode = "lua", -- 528
						output = truncateCommandOutput(table.concat(output, "\n")), -- 529
						message = watchdogMessage, -- 530
						phase = "execute", -- 531
						interrupted = true -- 532
					}) -- 532
					return true -- 534
				end -- 534
				if isCancelled and isCancelled(nil) then -- 534
					finish({ -- 537
						success = false, -- 538
						mode = "lua", -- 539
						output = truncateCommandOutput(table.concat(output, "\n")), -- 540
						message = "Lua command canceled", -- 541
						phase = "execute", -- 542
						interrupted = true -- 543
					}) -- 543
					return true -- 545
				end -- 545
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 545
					finish({ -- 548
						success = false, -- 549
						mode = "lua", -- 550
						output = truncateCommandOutput(table.concat(output, "\n")), -- 551
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 552
						phase = "timeout" -- 553
					}) -- 553
					return true -- 555
				end -- 555
				if commandRoutine == nil then -- 555
					finish({ -- 558
						success = false, -- 559
						mode = "lua", -- 560
						output = truncateCommandOutput(table.concat(output, "\n")), -- 561
						message = "Lua command coroutine is unavailable", -- 562
						phase = "execute" -- 563
					}) -- 563
					return true -- 565
				end -- 565
				local resumeSuccess, resumeResult = coroutine.resume(commandRoutine) -- 567
				if not resumeSuccess then -- 567
					finish({ -- 569
						success = false, -- 570
						mode = "lua", -- 571
						output = truncateCommandOutput(table.concat(output, "\n")), -- 572
						message = truncateCommandError(toStr(resumeResult)), -- 573
						phase = "execute" -- 574
					}) -- 574
					return true -- 576
				end -- 576
				return settled or resumeResult == true -- 578
			end) -- 522
		end -- 374
	) -- 374
end -- 103
function ____exports.executeCommand(req) -- 583
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 583
		local mode = req.mode -- 595
		if mode ~= "lua" and mode ~= "git" then -- 595
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 595
		end -- 595
		if mode == "lua" then -- 595
			return ____awaiter_resolve( -- 595
				nil, -- 595
				executeLuaCommand({ -- 600
					workDir = req.workDir, -- 601
					docLanguage = req.docLanguage, -- 602
					code = req.code or "", -- 603
					timeoutSeconds = math.max( -- 604
						1, -- 604
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 604
					), -- 604
					operationId = createOperationId(), -- 605
					taskId = req.taskId or 0, -- 606
					onProgress = req.onProgress, -- 607
					isCancelled = req.isCancelled -- 608
				}) -- 608
			) -- 608
		end -- 608
		local operationId = createOperationId() -- 611
		return ____awaiter_resolve( -- 611
			nil, -- 611
			executeGitCommand({ -- 612
				workDir = req.workDir, -- 613
				command = req.command or "", -- 614
				cwd = req.cwd, -- 615
				timeoutSeconds = math.max( -- 616
					1, -- 616
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 616
				), -- 616
				operationId = operationId, -- 617
				onProgress = req.onProgress, -- 618
				isCancelled = req.isCancelled -- 619
			}) -- 619
		) -- 619
	end) -- 619
end -- 583
return ____exports -- 583