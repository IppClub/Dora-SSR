-- [ts]: Command.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArraySplice = ____lualib.__TS__ArraySplice -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
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
local ____Fetch = require("Agent.Tool.Fetch") -- 16
local fetchUrl = ____Fetch.fetchUrl -- 16
local ____DeepSeekWeb = require("Agent.Tool.DeepSeekWeb") -- 17
local WEB_REQUEST_TIMEOUT_SECONDS = ____DeepSeekWeb.WEB_REQUEST_TIMEOUT_SECONDS -- 17
local readWebPage = ____DeepSeekWeb.readWebPage -- 17
local searchWeb = ____DeepSeekWeb.searchWeb -- 17
local ____CommandContent = require("Agent.Tool.CommandContent") -- 18
local createCommandContent = ____CommandContent.createCommandContent -- 18
local ____EntryLease = require("Agent.Tool.EntryLease") -- 20
local acquireEntryLease = ____EntryLease.acquireEntryLease -- 20
local canClearEntryAfterCommand = ____EntryLease.canClearEntryAfterCommand -- 20
local recordEntryLeaseRun = ____EntryLease.recordEntryLeaseRun -- 20
local ownsEntryLease = ____EntryLease.ownsEntryLease -- 20
local releaseEntryLease = ____EntryLease.releaseEntryLease -- 20
local ____CommandPreview = require("Agent.Tool.CommandPreview") -- 21
local createPreviewGameInjection = ____CommandPreview.createPreviewGameInjection -- 21
local ____VisionBudget = require("Agent.Tool.VisionBudget") -- 22
local getVisionBudgetState = ____VisionBudget.getVisionBudgetState -- 23
local getVisionTaskUsage = ____VisionBudget.getVisionTaskUsage -- 24
local VISION_MAX_CAPTURE_BATCHES = ____VisionBudget.VISION_MAX_CAPTURE_BATCHES -- 26
local VISION_MAX_CAPTURE_FRAMES = ____VisionBudget.VISION_MAX_CAPTURE_FRAMES -- 27
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 31
local function executeStudioLuaCommand(req) -- 40
	local usesPreviewGame = (string.match(req.code, "%f[%a_]previewGame%f[^%w_]%s*%(")) ~= nil -- 52
	local usesGodotImport = (string.match(req.code, "%f[%a_]importGodotAssets%f[^%w_]")) ~= nil -- 53
	local usesNetworkCommand = __TS__ArraySome( -- 54
		{"fetch", "web_search", "read_url"}, -- 54
		function(____, name) return (string.match(req.code, ("%f[%a_]" .. name) .. "%f[^%w_]")) ~= nil end -- 54
	) -- 54
	if type(_studio_agent_tool_begin) ~= "function" or usesNetworkCommand or usesPreviewGame or usesGodotImport or ((string.match(req.code, "%f[%a_]inspectGodotScene%f[^%w_]")) ~= nil or (string.match(req.code, "%f[%a_]inspectGodotRuntimeScene%f[^%w_]")) ~= nil) then -- 54
		return nil -- 57
	end -- 57
	local onProgress = req.onProgress -- 58
	local isCancelled = req.isCancelled -- 59
	return __TS__New( -- 60
		__TS__Promise, -- 60
		function(____, resolve) -- 60
			local requestId -- 61
			local settled = false -- 62
			local function finish(result) -- 63
				if settled then -- 63
					return -- 64
				end -- 64
				settled = true -- 65
				resolve(nil, result) -- 66
			end -- 63
			if onProgress ~= nil then -- 63
				onProgress(nil, { -- 68
					state = "pending", -- 68
					mode = "lua", -- 68
					operationId = req.operationId, -- 68
					stage = "player", -- 68
					message = "Lua command pending in isolated game Player" -- 68
				}) -- 68
			end -- 68
			local routine = once(function() -- 69
				do -- 69
					local function ____catch(e) -- 69
						if requestId then -- 69
							if _studio_agent_tool_cancel ~= nil then -- 69
								_studio_agent_tool_cancel(requestId) -- 93
							end -- 93
							requestId = nil -- 93
						end -- 93
						local message = truncateCommandError(toStr(e)) -- 94
						local ____message_9 = message -- 95
						local ____temp_10 = (string.find(message, "timed out", nil, true) or 0) - 1 >= 0 and "timeout" or "execute" -- 95
						local ____temp_8 -- 95
						if (string.find(message, "canceled", nil, true) or 0) - 1 >= 0 then -- 95
							____temp_8 = true -- 95
						else -- 95
							____temp_8 = nil -- 95
						end -- 95
						finish({ -- 95
							success = false, -- 95
							mode = "lua", -- 95
							output = "", -- 95
							message = ____message_9, -- 95
							phase = ____temp_10, -- 95
							interrupted = ____temp_8 -- 95
						}) -- 95
					end -- 95
					local ____try, ____hasReturned = pcall(function() -- 95
						local options = safeJsonEncode({code = req.code, timeoutSeconds = req.timeoutSeconds}) -- 71
						if not options then -- 71
							error("failed to encode Studio Agent Lua command") -- 72
						end -- 72
						requestId = _studio_agent_tool_begin( -- 73
							"execute-lua", -- 73
							Path(req.workDir, ".agent", "command.lua"), -- 73
							options, -- 73
							req.workDir -- 73
						) -- 73
						if onProgress ~= nil then -- 73
							onProgress(nil, { -- 74
								state = "running", -- 74
								mode = "lua", -- 74
								operationId = req.operationId, -- 74
								stage = "player", -- 74
								message = "Lua command running in isolated game Player" -- 74
							}) -- 74
						end -- 74
						local deadline = App.runningTime + req.timeoutSeconds -- 75
						local answer -- 76
						while not answer do -- 76
							if isCancelled and isCancelled(nil) then -- 76
								error("Lua command canceled") -- 78
							end -- 78
							if App.runningTime >= deadline then -- 78
								error(("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds") -- 79
							end -- 79
							answer = _studio_agent_tool_poll and _studio_agent_tool_poll(requestId) -- 80
							if not answer then -- 80
								sleep() -- 81
							end -- 81
						end -- 81
						requestId = nil -- 83
						if not answer.success then -- 83
							error(answer.message or "Studio Agent Lua Player failed") -- 84
						end -- 84
						local decoded = safeJsonDecode(answer.resultJSON or "") -- 85
						local value = decoded -- 86
						if not value or type(value.success) ~= "boolean" or type(value.output) ~= "string" or value.message ~= nil and type(value.message) ~= "string" or value.phase ~= nil and value.phase ~= "compile" and value.phase ~= "execute" and value.phase ~= "timeout" and value.phase ~= "validate" then -- 86
							error("Invalid Studio Agent Lua Player result") -- 89
						end -- 89
						if value.success then -- 89
							finish({ -- 90
								success = true, -- 90
								mode = "lua", -- 90
								output = truncateCommandOutput(value.output) -- 90
							}) -- 90
						else -- 90
							finish({ -- 91
								success = false, -- 91
								mode = "lua", -- 91
								output = truncateCommandOutput(value.output), -- 91
								message = truncateCommandError(value.message or "Lua command failed"), -- 91
								phase = value.phase or "execute" -- 91
							}) -- 91
						end -- 91
					end) -- 91
					if not ____try then -- 91
						____catch(____hasReturned) -- 91
					end -- 91
				end -- 91
			end) -- 69
			Director.systemScheduler:schedule(function() -- 98
				if settled then -- 98
					return true -- 99
				end -- 99
				local ok, result = coroutine.resume(routine) -- 100
				if not ok then -- 100
					finish({ -- 101
						success = false, -- 101
						mode = "lua", -- 101
						output = "", -- 101
						message = truncateCommandError(toStr(result)), -- 101
						phase = "execute" -- 101
					}) -- 101
					return true -- 101
				end -- 101
				return settled or result == true -- 102
			end) -- 98
		end -- 60
	) -- 60
end -- 40
local entryPrintSinks = {} -- 110
local currentCommandPrint -- 111
local defaultPrint -- 112
local function routeCommandPrint(...) -- 113
	local ____currentCommandPrint_13 = currentCommandPrint -- 114
	if ____currentCommandPrint_13 == nil then -- 114
		local ____opt_11 = __TS__ArrayFind( -- 114
			entryPrintSinks, -- 114
			function(____, item) return item:ownsRun() end -- 114
		) -- 114
		____currentCommandPrint_13 = ____opt_11 and ____opt_11.print -- 114
	end -- 114
	local sink = ____currentCommandPrint_13 or defaultPrint -- 114
	if sink ~= nil then -- 114
		sink(...) -- 115
	end -- 115
end -- 113
local function captureRuntimePrint(____print, ownsRun) -- 118
	if #entryPrintSinks == 0 then -- 118
		defaultPrint = _G.print -- 120
		_G.print = routeCommandPrint -- 121
	end -- 121
	local sink = {print = ____print, ownsRun = ownsRun} -- 123
	entryPrintSinks[#entryPrintSinks + 1] = sink -- 124
	return function() -- 125
		local index = __TS__ArrayIndexOf(entryPrintSinks, sink) -- 126
		if index >= 0 then -- 126
			__TS__ArraySplice(entryPrintSinks, index, 1) -- 127
		end -- 127
		if #entryPrintSinks == 0 and _G.print == routeCommandPrint and defaultPrint ~= nil then -- 127
			_G.print = defaultPrint -- 128
		end -- 128
	end -- 125
end -- 118
local function executeLuaCommand(req) -- 132
	local code = __TS__StringTrim(req.code or "") -- 142
	if code == "" then -- 142
		return __TS__Promise.resolve({ -- 144
			success = false, -- 144
			mode = "lua", -- 144
			output = "", -- 144
			message = "missing code", -- 144
			phase = "validate" -- 144
		}) -- 144
	end -- 144
	local studioResult = executeStudioLuaCommand(__TS__ObjectAssign({}, req, {code = code})) -- 146
	if studioResult then -- 146
		return studioResult -- 147
	end -- 147
	local output = {} -- 148
	local entry = require("Script.Dev.Entry") -- 149
	local ownsEntryRuntime = false -- 150
	local contentAccessed = false -- 151
	local refreshTreeCalled = false -- 152
	local entryObjectBaseline = 0 -- 153
	local entryLuaRefBaseline = 0 -- 154
	local persistedVisionUsage -- 155
	local capturedBatches = 0 -- 156
	local capturedFrames = 0 -- 157
	local commandClosed = false -- 158
	local startedAt = App.runningTime -- 159
	local deadline = startedAt + req.timeoutSeconds -- 160
	local waitingForDownload = false -- 161
	local downloadWaitSeconds = 0 -- 162
	local function isNetworkCancelled() -- 163
		local ____commandClosed_18 = commandClosed -- 163
		if not ____commandClosed_18 then -- 163
			local ____this_17 -- 163
			____this_17 = req -- 163
			local ____opt_16 = ____this_17.isCancelled -- 163
			____commandClosed_18 = (____opt_16 and ____opt_16(____this_17)) == true -- 163
		end -- 163
		return ____commandClosed_18 -- 163
	end -- 163
	local function waitForNetwork(operation, timeout) -- 164
		local waitingSince = App.runningTime -- 165
		waitingForDownload = timeout == nil -- 166
		if timeout ~= nil then -- 166
			deadline = math.max(deadline, waitingSince + timeout + 5) -- 168
		end -- 168
		local result -- 170
		local failed = false -- 171
		operation["then"]( -- 172
			operation, -- 172
			function(____, value) -- 172
				result = {value = value} -- 172
			end, -- 172
			function() -- 172
				failed = true -- 172
			end -- 172
		) -- 172
		while result == nil and not failed and not isNetworkCancelled() do -- 172
			sleep() -- 173
		end -- 173
		if waitingForDownload then -- 173
			waitingForDownload = false -- 176
			local waited = App.runningTime - waitingSince -- 177
			downloadWaitSeconds = downloadWaitSeconds + waited -- 178
			deadline = deadline + waited -- 179
		end -- 179
		if result == nil then -- 179
			error("Network command failed or was cancelled") -- 181
		end -- 181
		return result.value -- 182
	end -- 164
	local refreshedProjectModules = {} -- 186
	local godotSceneResults = {} -- 187
	local godotRuntimeSceneResults = {} -- 188
	local godotImportResults = {} -- 189
	local lastPreviewResult -- 190
	local previewCleanup -- 191
	local restorePrint -- 192
	local function currentVisionUsage() -- 193
		if persistedVisionUsage == nil then -- 193
			persistedVisionUsage = getVisionTaskUsage(req.taskId) -- 194
		end -- 194
		return __TS__ObjectAssign({}, persistedVisionUsage, {captureBatchCount = persistedVisionUsage.captureBatchCount + capturedBatches, captureFrameCount = persistedVisionUsage.captureFrameCount + capturedFrames}) -- 195
	end -- 193
	local function reserveCapture(frameCount) -- 201
		local current = currentVisionUsage() -- 202
		if current.captureBatchCount >= VISION_MAX_CAPTURE_BATCHES or current.captureFrameCount + frameCount > VISION_MAX_CAPTURE_FRAMES then -- 202
			return { -- 204
				success = false, -- 205
				message = ((("Vision capture budget exhausted: " .. tostring(current.captureBatchCount)) .. " batches and ") .. tostring(current.captureFrameCount)) .. " frames already reserved", -- 206
				budget = getVisionBudgetState(current) -- 207
			} -- 207
		end -- 207
		capturedBatches = capturedBatches + 1 -- 210
		capturedFrames = capturedFrames + frameCount -- 211
		return { -- 212
			success = true, -- 212
			budget = getVisionBudgetState(currentVisionUsage()) -- 212
		} -- 212
	end -- 201
	local function acquireEntryRuntime() -- 214
		acquireEntryLease(req.operationId, entry, isNetworkCancelled) -- 215
		ownsEntryRuntime = true -- 216
	end -- 214
	local function stopOwnedEntry() -- 218
		if not ownsEntryRuntime then -- 218
			return nil -- 219
		end -- 219
		ownsEntryRuntime = false -- 220
		return releaseEntryLease(req.operationId, entry) -- 221
	end -- 218
	local function startEntryWatchdog() -- 223
		entryObjectBaseline = Dora.Object.count -- 224
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 225
	end -- 223
	local function checkEntryWatchdog() -- 227
		if not ownsEntryRuntime then -- 227
			return nil -- 228
		end -- 228
		local objectCount = Dora.Object.count -- 229
		local luaRefCount = Dora.Object.luaRefCount -- 230
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 231
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 232
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 233
		if not exceededTotal then -- 233
			return nil -- 236
		end -- 236
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 237
	end -- 227
	local function normalizeEntryFile(value) -- 241
		if not value or type(value) ~= "table" then -- 241
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 243
		end -- 243
		local descriptor = value -- 245
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 246
		if relativeFile == "" then -- 246
			relativeFile = "init" -- 247
		end -- 247
		if not isValidWorkspacePath(relativeFile) then -- 247
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 249
		end -- 249
		local fileName = Path(req.workDir, relativeFile) -- 251
		local ext = Path:getExt(fileName) -- 252
		if ext ~= "" then -- 252
			fileName = Path:replaceExt(fileName, "") -- 253
		end -- 253
		local luaFile = Path:replaceExt(fileName, "lua") -- 254
		if not Content:exist(luaFile) then -- 254
			error("Agent test entry was not built: " .. luaFile) -- 256
		end -- 256
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 258
		return { -- 259
			fileName = fileName, -- 260
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 261
		} -- 261
	end -- 241
	local function capturePrint(...) -- 264
		local values = {...} -- 264
		local parts = {} -- 265
		do -- 265
			local i = 0 -- 266
			while i < #values do -- 266
				parts[#parts + 1] = tostring(values[i + 1]) -- 267
				i = i + 1 -- 266
			end -- 266
		end -- 266
		output[#output + 1] = table.concat(parts, "\t") -- 269
	end -- 264
	local function refreshTree(path) -- 271
		refreshTreeCalled = true -- 272
		if path == nil then -- 272
			return refreshWorkspaceTree(req.workDir) -- 274
		end -- 274
		if type(path) ~= "string" then -- 274
			error("refreshTree expects a project-relative file path string or no argument") -- 277
		end -- 277
		return refreshWorkspaceTree(req.workDir, path) -- 279
	end -- 271
	local blockedDoraGlobals = {DB = true, HttpClient = true, HttpServer = true} -- 281
	local scopedContent = createCommandContent(req.workDir, req.docLanguage) -- 286
	local env = setmetatable( -- 287
		{ -- 287
			projectDir = req.workDir, -- 288
			fetch = function(url, target) return waitForNetwork(fetchUrl({ -- 289
				workDir = req.workDir, -- 290
				url = type(url) == "string" and url or "", -- 291
				target = type(target) == "string" and target or "", -- 292
				isCancelled = isNetworkCancelled, -- 293
				onProgress = function(____, progress) -- 294
					local ____this_20 -- 294
					____this_20 = req -- 294
					local ____opt_19 = ____this_20.onProgress -- 294
					return ____opt_19 and ____opt_19( -- 294
						____this_20, -- 294
						__TS__ObjectAssign({}, progress, {mode = "lua", operationId = req.operationId, stage = "download"}) -- 294
					) -- 294
				end -- 294
			})) end, -- 294
			web_search = function(query, count) return waitForNetwork( -- 296
				searchWeb(query, count, isNetworkCancelled), -- 296
				WEB_REQUEST_TIMEOUT_SECONDS -- 296
			) end, -- 296
			read_url = function(url) return waitForNetwork( -- 297
				readWebPage(url, isNetworkCancelled), -- 297
				WEB_REQUEST_TIMEOUT_SECONDS -- 297
			) end, -- 297
			inspectGodotRuntimeScene = createGodotRuntimeSceneInjection({ -- 298
				workDir = req.workDir, -- 299
				isCancelled = function() -- 300
					local ____commandClosed_23 = commandClosed -- 300
					if not ____commandClosed_23 then -- 300
						local ____this_22 -- 300
						____this_22 = req -- 300
						local ____opt_21 = ____this_22.isCancelled -- 300
						____commandClosed_23 = (____opt_21 and ____opt_21(____this_22)) == true -- 300
					end -- 300
					return ____commandClosed_23 -- 300
				end, -- 300
				print = capturePrint, -- 301
				onResult = function(result) -- 302
					godotRuntimeSceneResults[#godotRuntimeSceneResults + 1] = result -- 302
				end -- 302
			}), -- 302
			inspectGodotScene = createGodotSceneInjection({ -- 304
				workDir = req.workDir, -- 305
				isCancelled = function() -- 306
					local ____commandClosed_26 = commandClosed -- 306
					if not ____commandClosed_26 then -- 306
						local ____this_25 -- 306
						____this_25 = req -- 306
						local ____opt_24 = ____this_25.isCancelled -- 306
						____commandClosed_26 = (____opt_24 and ____opt_24(____this_25)) == true -- 306
					end -- 306
					return ____commandClosed_26 -- 306
				end, -- 306
				print = capturePrint, -- 307
				onResult = function(result) -- 308
					godotSceneResults[#godotSceneResults + 1] = result -- 308
				end -- 308
			}), -- 308
			importGodotAssets = createGodotImportInjection({ -- 310
				workDir = req.workDir, -- 311
				isCancelled = function() -- 312
					local ____commandClosed_29 = commandClosed -- 312
					if not ____commandClosed_29 then -- 312
						local ____this_28 -- 312
						____this_28 = req -- 312
						local ____opt_27 = ____this_28.isCancelled -- 312
						____commandClosed_29 = (____opt_27 and ____opt_27(____this_28)) == true -- 312
					end -- 312
					return ____commandClosed_29 -- 312
				end, -- 312
				print = capturePrint, -- 313
				onResult = function(result) -- 314
					godotImportResults[#godotImportResults + 1] = result -- 315
					if result.importedCount > 0 then -- 315
						contentAccessed = true -- 316
					end -- 316
				end -- 314
			}), -- 314
			previewGame = createPreviewGameInjection( -- 320
				{ -- 320
					workDir = req.workDir, -- 321
					operationId = req.operationId, -- 322
					isCancelled = isNetworkCancelled, -- 323
					print = function(line) return capturePrint(line) end, -- 324
					reserveCapture = reserveCapture, -- 325
					registerCleanup = function(cleanup) -- 326
						previewCleanup = cleanup -- 326
					end, -- 326
					onResult = function(result) -- 327
						lastPreviewResult = result -- 328
					end -- 327
				}, -- 327
				entry -- 330
			), -- 330
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 331
				if type(moduleNameValue) ~= "string" then -- 331
					error("requireProjectModule expects a project module name string") -- 333
				end -- 333
				local moduleName = __TS__StringTrim(moduleNameValue) -- 335
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 335
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 337
				end -- 337
				local reloadModules = {moduleName} -- 339
				if reloadModulesValue ~= nil then -- 339
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 339
						error("requireProjectModule reloadModules must be an array of module names") -- 342
					end -- 342
					local items = reloadModulesValue -- 344
					do -- 344
						local i = 0 -- 345
						while i < #items do -- 345
							local item = items[i + 1] -- 346
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 346
								error("requireProjectModule reloadModules contains an invalid module name") -- 348
							end -- 348
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 348
								reloadModules[#reloadModules + 1] = item -- 350
							end -- 350
							i = i + 1 -- 345
						end -- 345
					end -- 345
				end -- 345
				local luaPackage = _G.package -- 353
				local previousPath = luaPackage.path -- 357
				local previousSearchPaths = Content.searchPaths -- 358
				local scopedSearchPaths = {req.workDir} -- 359
				do -- 359
					local i = 0 -- 360
					while i < #previousSearchPaths do -- 360
						local searchPath = previousSearchPaths[i + 1] -- 361
						if searchPath ~= req.workDir then -- 361
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 362
						end -- 362
						i = i + 1 -- 360
					end -- 360
				end -- 360
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 364
				Content.searchPaths = scopedSearchPaths -- 365
				do -- 365
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 365
						local refreshDependency -- 367
						refreshDependency = function(name) -- 367
							local canonical = table.concat( -- 368
								__TS__StringSplit(name, "/"), -- 368
								"." -- 368
							) -- 368
							if refreshedProjectModules[canonical] or (string.find(canonical, "..", nil, true) or 0) - 1 >= 0 or (string.find(name, "/", nil, true) or 0) - 1 == 0 then -- 368
								return -- 369
							end -- 369
							local relative = table.concat( -- 370
								__TS__StringSplit(canonical, "."), -- 370
								"/" -- 370
							) -- 370
							local file = Path(req.workDir, relative .. ".lua") -- 371
							if not Content:exist(file) then -- 371
								file = Path(req.workDir, relative, "init.lua") -- 372
							end -- 372
							if not Content:exist(file) then -- 372
								return -- 373
							end -- 373
							refreshedProjectModules[canonical] = true -- 374
							luaPackage.loaded[canonical] = nil -- 375
							luaPackage.loaded[relative] = nil -- 376
							local source = Content:load(file) -- 377
							for dependency in string.gmatch(source, "require%s*%(%s*[\"']([^\"']+)[\"']%s*%)") do -- 378
								refreshDependency(dependency) -- 378
							end -- 378
						end -- 367
						for ____, name in ipairs(reloadModules) do -- 380
							refreshDependency(name) -- 380
						end -- 380
						do -- 380
							local i = 0 -- 381
							while i < #reloadModules do -- 381
								local reloadName = reloadModules[i + 1] -- 382
								luaPackage.loaded[reloadName] = nil -- 383
								luaPackage.loaded[table.concat( -- 384
									__TS__StringSplit(reloadName, "/"), -- 384
									"." -- 384
								)] = nil -- 384
								luaPackage.loaded[table.concat( -- 385
									__TS__StringSplit(reloadName, "."), -- 385
									"/" -- 385
								)] = nil -- 385
								i = i + 1 -- 381
							end -- 381
						end -- 381
						return true, require(table.concat( -- 387
							__TS__StringSplit(moduleName, "/"), -- 387
							"." -- 387
						)) -- 387
					end) -- 387
					do -- 387
						Content.searchPaths = previousSearchPaths -- 389
						luaPackage.path = previousPath -- 390
					end -- 390
					if not ____try then -- 390
						error(____hasReturned, 0) -- 390
					end -- 390
					if ____try and ____hasReturned then -- 390
						return ____returnValue -- 366
					end -- 366
				end -- 366
			end, -- 331
			print = capturePrint, -- 393
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 394
			enterEntryAsync = function(value) -- 395
				local normalized = normalizeEntryFile(value) -- 396
				acquireEntryRuntime() -- 397
				entry.allClear() -- 398
				startEntryWatchdog() -- 399
				recordEntryLeaseRun(req.operationId, entry) -- 400
				local success, message = entry.enterEntryAsync({ -- 401
					entryName = normalized.entryName, -- 402
					fileName = normalized.fileName, -- 403
					workDir = req.workDir, -- 404
					projectRoot = req.workDir, -- 405
					runKind = "agent_test" -- 406
				}) -- 406
				return success, message -- 408
			end, -- 395
			stopEntry = function() -- 410
				if not ownsEntryRuntime or not ownsEntryLease(req.operationId, entry) then -- 410
					return false -- 411
				end -- 411
				return entry.stop() -- 412
			end, -- 410
			reportProgress = function(value, callbackValue) -- 414
				local ____callbackValue_30 = callbackValue -- 415
				if ____callbackValue_30 == nil then -- 415
					____callbackValue_30 = value -- 415
				end -- 415
				local actualValue = ____callbackValue_30 -- 415
				if not req.onProgress or not actualValue or type(actualValue) ~= "table" then -- 415
					return -- 416
				end -- 416
				local progress = actualValue -- 417
				local amount = type(progress.progress) == "number" and math.min( -- 418
					1, -- 419
					math.max(0, progress.progress) -- 419
				) or nil -- 419
				req:onProgress({ -- 421
					state = "running", -- 422
					mode = "lua", -- 423
					operationId = req.operationId, -- 424
					progress = amount, -- 425
					stage = type(progress.stage) == "string" and progress.stage or "lua", -- 426
					message = type(progress.message) == "string" and progress.message or "Lua command running" -- 427
				}) -- 427
			end -- 414
		}, -- 414
		{__index = function(_table, key) -- 430
			if key == "Content" then -- 430
				contentAccessed = true -- 433
				return scopedContent -- 434
			end -- 434
			if key == "refreshTree" then -- 434
				return refreshTree -- 437
			end -- 437
			local name = tostring(key) -- 439
			if blockedDoraGlobals[name] then -- 439
				return nil -- 440
			end -- 440
			return Dora[name] -- 441
		end} -- 431
	) -- 431
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 444
	if not fn then -- 444
		return __TS__Promise.resolve({ -- 446
			success = false, -- 447
			mode = "lua", -- 448
			output = truncateCommandOutput(table.concat(output, "\n")), -- 449
			message = truncateCommandError(toStr(compileErr)), -- 450
			phase = "compile" -- 451
		}) -- 451
	end -- 451
	return __TS__New( -- 454
		__TS__Promise, -- 454
		function(____, resolve) -- 454
			local settled = false -- 455
			local commandRoutine -- 456
			local onProgress = req.onProgress -- 457
			local isCancelled = req.isCancelled -- 458
			local function finish(result) -- 459
				if settled then -- 459
					return -- 460
				end -- 460
				settled = true -- 461
				commandClosed = true -- 462
				local cleanupError -- 463
				local cleanup = previewCleanup -- 464
				previewCleanup = nil -- 465
				do -- 465
					local function ____catch(e) -- 465
						cleanupError = "failed to release Agent preview: " .. tostring(e) -- 467
					end -- 467
					local ____try, ____hasReturned = pcall(function() -- 467
						if cleanup ~= nil then -- 467
							cleanup() -- 466
						end -- 466
					end) -- 466
					if not ____try then -- 466
						____catch(____hasReturned) -- 466
					end -- 466
				end -- 466
				if restorePrint ~= nil then -- 466
					restorePrint() -- 468
				end -- 468
				restorePrint = nil -- 469
				if not result.success and (result.interrupted == true or result.phase == "timeout") and canClearEntryAfterCommand(req.operationId, entry) then -- 469
					do -- 469
						local function ____catch(e) -- 469
							cleanupError = "failed to clear interrupted Lua command runtime: " .. tostring(e) -- 475
						end -- 475
						local ____try, ____hasReturned = pcall(function() -- 475
							entry.allClear() -- 473
						end) -- 473
						if not ____try then -- 473
							____catch(____hasReturned) -- 473
						end -- 473
					end -- 473
				end -- 473
				local entryCleanupError = stopOwnedEntry() -- 478
				if cleanupError == nil then -- 478
					cleanupError = entryCleanupError -- 479
				end -- 479
				if contentAccessed and not refreshTreeCalled and not refreshWorkspaceTree(req.workDir) then -- 479
					Log("Warn", "[execute_command] failed to refresh Web IDE tree after Lua command workDir=" .. req.workDir) -- 481
				end -- 481
				local ____lastPreviewResult_40 -- 483
				if lastPreviewResult then -- 483
					local ____lastPreviewResult_success_37 = lastPreviewResult.success -- 484
					local ____lastPreviewResult_message_38 = lastPreviewResult.message -- 485
					local ____lastPreviewResult_files_39 = lastPreviewResult.files -- 486
					local ____opt_35 = lastPreviewResult.frames -- 486
					____lastPreviewResult_40 = {success = ____lastPreviewResult_success_37, message = ____lastPreviewResult_message_38, files = ____lastPreviewResult_files_39, frameCount = ____opt_35 and #____opt_35} -- 483
				else -- 483
					____lastPreviewResult_40 = nil -- 488
				end -- 488
				local previewGame = ____lastPreviewResult_40 -- 483
				local visionFields = __TS__ObjectAssign( -- 489
					{}, -- 489
					#godotRuntimeSceneResults > 0 and ({godotRuntimeScenes = godotRuntimeSceneResults}) or ({}), -- 490
					#godotSceneResults > 0 and ({godotScenes = godotSceneResults}) or ({}), -- 491
					#godotImportResults > 0 and ({godotImports = godotImportResults}) or ({}), -- 492
					previewGame and ({previewGame = previewGame}) or ({}), -- 493
					capturedBatches > 0 and ({ -- 494
						visionCapture = {batchCount = capturedBatches, frameCount = capturedFrames}, -- 495
						visionBudget = getVisionBudgetState(currentVisionUsage()) -- 496
					}) or ({}) -- 496
				) -- 496
				if not result.success and cleanupError ~= nil then -- 496
					result.cleanupError = cleanupError -- 500
				elseif result.success and cleanupError ~= nil then -- 500
					resolve( -- 502
						nil, -- 502
						__TS__ObjectAssign({ -- 502
							success = false, -- 503
							mode = "lua", -- 504
							output = result.output, -- 505
							message = cleanupError, -- 506
							phase = "execute", -- 507
							cleanupError = cleanupError -- 508
						}, visionFields) -- 508
					) -- 508
					return -- 511
				end -- 511
				if result.success and __TS__ArraySome( -- 511
					godotRuntimeSceneResults, -- 513
					function(____, scene) return not scene.success end -- 513
				) then -- 513
					resolve( -- 514
						nil, -- 514
						__TS__ObjectAssign({ -- 514
							success = false, -- 514
							mode = "lua", -- 514
							output = result.output, -- 514
							message = "inspectGodotRuntimeScene failed; inspect godotRuntimeScenes for diagnostics", -- 515
							phase = "execute" -- 515
						}, visionFields) -- 515
					) -- 515
					return -- 516
				end -- 516
				if result.success and __TS__ArraySome( -- 516
					godotSceneResults, -- 518
					function(____, scene) return not scene.success end -- 518
				) then -- 518
					resolve( -- 519
						nil, -- 519
						__TS__ObjectAssign({ -- 519
							success = false, -- 519
							mode = "lua", -- 519
							output = result.output, -- 519
							message = "inspectGodotScene failed; inspect godotScenes for diagnostics", -- 520
							phase = "execute" -- 520
						}, visionFields) -- 520
					) -- 520
					return -- 521
				end -- 521
				if result.success and __TS__ArraySome( -- 521
					godotImportResults, -- 523
					function(____, batch) return not batch.success end -- 523
				) then -- 523
					resolve( -- 524
						nil, -- 524
						__TS__ObjectAssign({ -- 524
							success = false, -- 524
							mode = "lua", -- 524
							output = result.output, -- 524
							message = "importGodotAssets failed; inspect godotImports for per-file results", -- 525
							phase = "execute" -- 525
						}, visionFields) -- 525
					) -- 525
					return -- 526
				end -- 526
				if result.success and lastPreviewResult and not lastPreviewResult.success then -- 526
					resolve( -- 529
						nil, -- 529
						__TS__ObjectAssign({ -- 529
							success = false, -- 530
							mode = "lua", -- 531
							output = result.output, -- 532
							message = "previewGame failed: " .. (lastPreviewResult.message or "unknown error"), -- 533
							phase = "execute" -- 534
						}, visionFields) -- 534
					) -- 534
					return -- 537
				end -- 537
				resolve( -- 539
					nil, -- 539
					__TS__ObjectAssign({}, result, visionFields) -- 539
				) -- 539
			end -- 459
			if onProgress then -- 459
				onProgress(nil, { -- 545
					state = "pending", -- 546
					mode = "lua", -- 547
					operationId = req.operationId, -- 548
					stage = "lua", -- 549
					message = "Lua command pending" -- 550
				}) -- 550
			end -- 550
			commandRoutine = once(function() -- 553
				if settled then -- 553
					return -- 554
				end -- 554
				if onProgress then -- 554
					onProgress(nil, { -- 556
						state = "running", -- 557
						mode = "lua", -- 558
						operationId = req.operationId, -- 559
						stage = "lua", -- 560
						message = "Lua command running" -- 561
					}) -- 561
				end -- 561
				restorePrint = captureRuntimePrint( -- 564
					capturePrint, -- 564
					function() return ownsEntryLease(req.operationId, entry) end -- 564
				) -- 564
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 565
				local frameTimedOut = false -- 566
				local watchdogMessage -- 566
				debug.sethook( -- 567
					function() -- 567
						if watchdogMessage == nil then -- 567
							watchdogMessage = checkEntryWatchdog() -- 568
						end -- 568
						if watchdogMessage ~= nil then -- 568
							error(watchdogMessage) -- 569
						end -- 569
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 569
							frameTimedOut = true -- 571
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 572
						end -- 572
					end, -- 567
					"", -- 574
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 574
				) -- 574
				local ok, runtimeErr = pcall(fn) -- 575
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 575
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 577
				else -- 577
					debug.sethook() -- 583
				end -- 583
				if not ok then -- 583
					local ____truncateCommandOutput_result_42 = truncateCommandOutput(table.concat(output, "\n")) -- 589
					local ____temp_43 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 590
					local ____temp_44 = frameTimedOut and "timeout" or "execute" -- 591
					local ____temp_41 -- 592
					if watchdogMessage ~= nil or frameTimedOut then -- 592
						____temp_41 = true -- 592
					else -- 592
						____temp_41 = nil -- 592
					end -- 592
					finish({ -- 586
						success = false, -- 587
						mode = "lua", -- 588
						output = ____truncateCommandOutput_result_42, -- 589
						message = ____temp_43, -- 590
						phase = ____temp_44, -- 591
						interrupted = ____temp_41 -- 592
					}) -- 592
					return -- 594
				end -- 594
				finish({ -- 596
					success = true, -- 596
					mode = "lua", -- 596
					output = truncateCommandOutput(table.concat(output, "\n")) -- 596
				}) -- 596
			end) -- 553
			Director.systemScheduler:schedule(function() -- 598
				if settled then -- 598
					return true -- 599
				end -- 599
				local watchdogMessage = checkEntryWatchdog() -- 600
				if watchdogMessage ~= nil then -- 600
					finish({ -- 602
						success = false, -- 603
						mode = "lua", -- 604
						output = truncateCommandOutput(table.concat(output, "\n")), -- 605
						message = watchdogMessage, -- 606
						phase = "execute", -- 607
						interrupted = true -- 608
					}) -- 608
					return true -- 610
				end -- 610
				if isCancelled and isCancelled(nil) then -- 610
					finish({ -- 613
						success = false, -- 614
						mode = "lua", -- 615
						output = truncateCommandOutput(table.concat(output, "\n")), -- 616
						message = "Lua command canceled", -- 617
						phase = "execute", -- 618
						interrupted = true -- 619
					}) -- 619
					return true -- 621
				end -- 621
				if not waitingForDownload and App.runningTime >= deadline then -- 621
					finish({ -- 624
						success = false, -- 625
						mode = "lua", -- 626
						output = truncateCommandOutput(table.concat(output, "\n")), -- 627
						message = ("Lua command timed out after " .. tostring(math.max( -- 628
							1, -- 628
							math.floor(deadline - startedAt - downloadWaitSeconds + 0.5) -- 628
						))) .. " seconds", -- 628
						phase = "timeout" -- 629
					}) -- 629
					return true -- 631
				end -- 631
				if commandRoutine == nil then -- 631
					finish({ -- 634
						success = false, -- 635
						mode = "lua", -- 636
						output = truncateCommandOutput(table.concat(output, "\n")), -- 637
						message = "Lua command coroutine is unavailable", -- 638
						phase = "execute" -- 639
					}) -- 639
					return true -- 641
				end -- 641
				local previousCommandPrint = currentCommandPrint -- 643
				currentCommandPrint = capturePrint -- 644
				local resumeSuccess, resumeResult = coroutine.resume(commandRoutine) -- 645
				currentCommandPrint = previousCommandPrint -- 646
				if not resumeSuccess then -- 646
					finish({ -- 648
						success = false, -- 649
						mode = "lua", -- 650
						output = truncateCommandOutput(table.concat(output, "\n")), -- 651
						message = truncateCommandError(toStr(resumeResult)), -- 652
						phase = "execute" -- 653
					}) -- 653
					return true -- 655
				end -- 655
				return settled or resumeResult == true -- 657
			end) -- 598
		end -- 454
	) -- 454
end -- 132
function ____exports.executeCommand(req) -- 662
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 662
		local mode = req.mode -- 674
		if mode ~= "lua" and mode ~= "git" then -- 674
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 674
		end -- 674
		if mode == "lua" then -- 674
			return ____awaiter_resolve( -- 674
				nil, -- 674
				executeLuaCommand({ -- 679
					workDir = req.workDir, -- 680
					docLanguage = req.docLanguage, -- 681
					code = req.code or "", -- 682
					timeoutSeconds = math.max( -- 683
						1, -- 683
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 683
					), -- 683
					operationId = createOperationId(), -- 684
					taskId = req.taskId or 0, -- 685
					onProgress = req.onProgress, -- 686
					isCancelled = req.isCancelled -- 687
				}) -- 687
			) -- 687
		end -- 687
		local operationId = createOperationId() -- 690
		return ____awaiter_resolve( -- 690
			nil, -- 690
			executeGitCommand({ -- 691
				workDir = req.workDir, -- 692
				command = req.command or "", -- 693
				cwd = req.cwd, -- 694
				timeoutSeconds = math.max( -- 695
					1, -- 695
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 695
				), -- 695
				operationId = operationId, -- 696
				onProgress = req.onProgress, -- 697
				isCancelled = req.isCancelled -- 698
			}) -- 698
		) -- 698
	end) -- 698
end -- 662
return ____exports -- 662