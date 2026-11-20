-- [ts]: Command.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
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
local function executeLuaCommand(req) -- 108
	local code = __TS__StringTrim(req.code or "") -- 118
	if code == "" then -- 118
		return __TS__Promise.resolve({ -- 120
			success = false, -- 120
			mode = "lua", -- 120
			output = "", -- 120
			message = "missing code", -- 120
			phase = "validate" -- 120
		}) -- 120
	end -- 120
	local studioResult = executeStudioLuaCommand(__TS__ObjectAssign({}, req, {code = code})) -- 122
	if studioResult then -- 122
		return studioResult -- 123
	end -- 123
	local output = {} -- 124
	local entry = require("Script.Dev.Entry") -- 125
	local ownsEntryRuntime = false -- 126
	local contentAccessed = false -- 127
	local refreshTreeCalled = false -- 128
	local entryObjectBaseline = 0 -- 129
	local entryLuaRefBaseline = 0 -- 130
	local persistedVisionUsage -- 131
	local capturedBatches = 0 -- 132
	local capturedFrames = 0 -- 133
	local commandClosed = false -- 134
	local startedAt = App.runningTime -- 135
	local deadline = startedAt + req.timeoutSeconds -- 136
	local waitingForDownload = false -- 137
	local downloadWaitSeconds = 0 -- 138
	local function isNetworkCancelled() -- 139
		local ____commandClosed_13 = commandClosed -- 139
		if not ____commandClosed_13 then -- 139
			local ____this_12 -- 139
			____this_12 = req -- 139
			local ____opt_11 = ____this_12.isCancelled -- 139
			____commandClosed_13 = (____opt_11 and ____opt_11(____this_12)) == true -- 139
		end -- 139
		return ____commandClosed_13 -- 139
	end -- 139
	local function waitForNetwork(operation, timeout) -- 140
		local waitingSince = App.runningTime -- 141
		waitingForDownload = timeout == nil -- 142
		if timeout ~= nil then -- 142
			deadline = math.max(deadline, waitingSince + timeout + 5) -- 144
		end -- 144
		local result -- 146
		local failed = false -- 147
		operation["then"]( -- 148
			operation, -- 148
			function(____, value) -- 148
				result = {value = value} -- 148
			end, -- 148
			function() -- 148
				failed = true -- 148
			end -- 148
		) -- 148
		while result == nil and not failed and not isNetworkCancelled() do -- 148
			sleep() -- 149
		end -- 149
		if waitingForDownload then -- 149
			waitingForDownload = false -- 152
			local waited = App.runningTime - waitingSince -- 153
			downloadWaitSeconds = downloadWaitSeconds + waited -- 154
			deadline = deadline + waited -- 155
		end -- 155
		if result == nil then -- 155
			error("Network command failed or was cancelled") -- 157
		end -- 157
		return result.value -- 158
	end -- 140
	local refreshedProjectModules = {} -- 162
	local godotSceneResults = {} -- 163
	local godotRuntimeSceneResults = {} -- 164
	local godotImportResults = {} -- 165
	local lastPreviewResult -- 166
	local previewCleanup -- 167
	local restorePrint -- 168
	local function currentVisionUsage() -- 169
		if persistedVisionUsage == nil then -- 169
			persistedVisionUsage = getVisionTaskUsage(req.taskId) -- 170
		end -- 170
		return __TS__ObjectAssign({}, persistedVisionUsage, {captureBatchCount = persistedVisionUsage.captureBatchCount + capturedBatches, captureFrameCount = persistedVisionUsage.captureFrameCount + capturedFrames}) -- 171
	end -- 169
	local function reserveCapture(frameCount) -- 177
		local current = currentVisionUsage() -- 178
		if current.captureBatchCount >= VISION_MAX_CAPTURE_BATCHES or current.captureFrameCount + frameCount > VISION_MAX_CAPTURE_FRAMES then -- 178
			return { -- 180
				success = false, -- 181
				message = ((("Vision capture budget exhausted: " .. tostring(current.captureBatchCount)) .. " batches and ") .. tostring(current.captureFrameCount)) .. " frames already reserved", -- 182
				budget = getVisionBudgetState(current) -- 183
			} -- 183
		end -- 183
		capturedBatches = capturedBatches + 1 -- 186
		capturedFrames = capturedFrames + frameCount -- 187
		return { -- 188
			success = true, -- 188
			budget = getVisionBudgetState(currentVisionUsage()) -- 188
		} -- 188
	end -- 177
	local function acquireEntryRuntime() -- 190
		acquireEntryLease(req.operationId, entry) -- 191
		ownsEntryRuntime = true -- 192
	end -- 190
	local function stopOwnedEntry() -- 194
		if not ownsEntryRuntime then -- 194
			return nil -- 195
		end -- 195
		ownsEntryRuntime = false -- 196
		return releaseEntryLease(req.operationId, entry) -- 197
	end -- 194
	local function startEntryWatchdog() -- 199
		entryObjectBaseline = Dora.Object.count -- 200
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 201
	end -- 199
	local function checkEntryWatchdog() -- 203
		if not ownsEntryRuntime then -- 203
			return nil -- 204
		end -- 204
		local objectCount = Dora.Object.count -- 205
		local luaRefCount = Dora.Object.luaRefCount -- 206
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 207
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 208
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 209
		if not exceededTotal then -- 209
			return nil -- 212
		end -- 212
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 213
	end -- 203
	local function normalizeEntryFile(value) -- 217
		if not value or type(value) ~= "table" then -- 217
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 219
		end -- 219
		local descriptor = value -- 221
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 222
		if relativeFile == "" then -- 222
			relativeFile = "init" -- 223
		end -- 223
		if not isValidWorkspacePath(relativeFile) then -- 223
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 225
		end -- 225
		local fileName = Path(req.workDir, relativeFile) -- 227
		local ext = Path:getExt(fileName) -- 228
		if ext ~= "" then -- 228
			fileName = Path:replaceExt(fileName, "") -- 229
		end -- 229
		local luaFile = Path:replaceExt(fileName, "lua") -- 230
		if not Content:exist(luaFile) then -- 230
			error("Agent test entry was not built: " .. luaFile) -- 232
		end -- 232
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 234
		return { -- 235
			fileName = fileName, -- 236
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 237
		} -- 237
	end -- 217
	local function capturePrint(...) -- 240
		local values = {...} -- 240
		local parts = {} -- 241
		do -- 241
			local i = 0 -- 242
			while i < #values do -- 242
				parts[#parts + 1] = tostring(values[i + 1]) -- 243
				i = i + 1 -- 242
			end -- 242
		end -- 242
		output[#output + 1] = table.concat(parts, "\t") -- 245
	end -- 240
	local function refreshTree(path) -- 247
		refreshTreeCalled = true -- 248
		if path == nil then -- 248
			return refreshWorkspaceTree(req.workDir) -- 250
		end -- 250
		if type(path) ~= "string" then -- 250
			error("refreshTree expects a project-relative file path string or no argument") -- 253
		end -- 253
		return refreshWorkspaceTree(req.workDir, path) -- 255
	end -- 247
	local blockedDoraGlobals = {DB = true, HttpClient = true, HttpServer = true} -- 257
	local scopedContent = createCommandContent(req.workDir, req.docLanguage) -- 262
	local env = setmetatable( -- 263
		{ -- 263
			projectDir = req.workDir, -- 264
			fetch = function(url, target) return waitForNetwork(fetchUrl({ -- 265
				workDir = req.workDir, -- 266
				url = type(url) == "string" and url or "", -- 267
				target = type(target) == "string" and target or "", -- 268
				isCancelled = isNetworkCancelled, -- 269
				onProgress = function(____, progress) -- 270
					local ____this_15 -- 270
					____this_15 = req -- 270
					local ____opt_14 = ____this_15.onProgress -- 270
					return ____opt_14 and ____opt_14( -- 270
						____this_15, -- 270
						__TS__ObjectAssign({}, progress, {mode = "lua", operationId = req.operationId, stage = "download"}) -- 270
					) -- 270
				end -- 270
			})) end, -- 270
			web_search = function(query, count) return waitForNetwork( -- 272
				searchWeb(query, count, isNetworkCancelled), -- 272
				WEB_REQUEST_TIMEOUT_SECONDS -- 272
			) end, -- 272
			read_url = function(url) return waitForNetwork( -- 273
				readWebPage(url, isNetworkCancelled), -- 273
				WEB_REQUEST_TIMEOUT_SECONDS -- 273
			) end, -- 273
			inspectGodotRuntimeScene = createGodotRuntimeSceneInjection({ -- 274
				workDir = req.workDir, -- 275
				isCancelled = function() -- 276
					local ____commandClosed_18 = commandClosed -- 276
					if not ____commandClosed_18 then -- 276
						local ____this_17 -- 276
						____this_17 = req -- 276
						local ____opt_16 = ____this_17.isCancelled -- 276
						____commandClosed_18 = (____opt_16 and ____opt_16(____this_17)) == true -- 276
					end -- 276
					return ____commandClosed_18 -- 276
				end, -- 276
				print = capturePrint, -- 277
				onResult = function(result) -- 278
					godotRuntimeSceneResults[#godotRuntimeSceneResults + 1] = result -- 278
				end -- 278
			}), -- 278
			inspectGodotScene = createGodotSceneInjection({ -- 280
				workDir = req.workDir, -- 281
				isCancelled = function() -- 282
					local ____commandClosed_21 = commandClosed -- 282
					if not ____commandClosed_21 then -- 282
						local ____this_20 -- 282
						____this_20 = req -- 282
						local ____opt_19 = ____this_20.isCancelled -- 282
						____commandClosed_21 = (____opt_19 and ____opt_19(____this_20)) == true -- 282
					end -- 282
					return ____commandClosed_21 -- 282
				end, -- 282
				print = capturePrint, -- 283
				onResult = function(result) -- 284
					godotSceneResults[#godotSceneResults + 1] = result -- 284
				end -- 284
			}), -- 284
			importGodotAssets = createGodotImportInjection({ -- 286
				workDir = req.workDir, -- 287
				isCancelled = function() -- 288
					local ____commandClosed_24 = commandClosed -- 288
					if not ____commandClosed_24 then -- 288
						local ____this_23 -- 288
						____this_23 = req -- 288
						local ____opt_22 = ____this_23.isCancelled -- 288
						____commandClosed_24 = (____opt_22 and ____opt_22(____this_23)) == true -- 288
					end -- 288
					return ____commandClosed_24 -- 288
				end, -- 288
				print = capturePrint, -- 289
				onResult = function(result) -- 290
					godotImportResults[#godotImportResults + 1] = result -- 291
					if result.importedCount > 0 then -- 291
						contentAccessed = true -- 292
					end -- 292
				end -- 290
			}), -- 290
			previewGame = createPreviewGameInjection( -- 296
				{ -- 296
					workDir = req.workDir, -- 297
					operationId = req.operationId, -- 298
					isCancelled = req.isCancelled, -- 299
					print = function(line) return capturePrint(line) end, -- 300
					reserveCapture = reserveCapture, -- 301
					registerCleanup = function(cleanup) -- 302
						previewCleanup = cleanup -- 302
					end, -- 302
					onResult = function(result) -- 303
						lastPreviewResult = result -- 304
					end -- 303
				}, -- 303
				entry -- 306
			), -- 306
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 307
				if type(moduleNameValue) ~= "string" then -- 307
					error("requireProjectModule expects a project module name string") -- 309
				end -- 309
				local moduleName = __TS__StringTrim(moduleNameValue) -- 311
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 311
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 313
				end -- 313
				local reloadModules = {moduleName} -- 315
				if reloadModulesValue ~= nil then -- 315
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 315
						error("requireProjectModule reloadModules must be an array of module names") -- 318
					end -- 318
					local items = reloadModulesValue -- 320
					do -- 320
						local i = 0 -- 321
						while i < #items do -- 321
							local item = items[i + 1] -- 322
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 322
								error("requireProjectModule reloadModules contains an invalid module name") -- 324
							end -- 324
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 324
								reloadModules[#reloadModules + 1] = item -- 326
							end -- 326
							i = i + 1 -- 321
						end -- 321
					end -- 321
				end -- 321
				local luaPackage = _G.package -- 329
				local previousPath = luaPackage.path -- 333
				local previousSearchPaths = Content.searchPaths -- 334
				local scopedSearchPaths = {req.workDir} -- 335
				do -- 335
					local i = 0 -- 336
					while i < #previousSearchPaths do -- 336
						local searchPath = previousSearchPaths[i + 1] -- 337
						if searchPath ~= req.workDir then -- 337
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 338
						end -- 338
						i = i + 1 -- 336
					end -- 336
				end -- 336
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 340
				Content.searchPaths = scopedSearchPaths -- 341
				do -- 341
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 341
						local refreshDependency -- 343
						refreshDependency = function(name) -- 343
							local canonical = table.concat( -- 344
								__TS__StringSplit(name, "/"), -- 344
								"." -- 344
							) -- 344
							if refreshedProjectModules[canonical] or (string.find(canonical, "..", nil, true) or 0) - 1 >= 0 or (string.find(name, "/", nil, true) or 0) - 1 == 0 then -- 344
								return -- 345
							end -- 345
							local relative = table.concat( -- 346
								__TS__StringSplit(canonical, "."), -- 346
								"/" -- 346
							) -- 346
							local file = Path(req.workDir, relative .. ".lua") -- 347
							if not Content:exist(file) then -- 347
								file = Path(req.workDir, relative, "init.lua") -- 348
							end -- 348
							if not Content:exist(file) then -- 348
								return -- 349
							end -- 349
							refreshedProjectModules[canonical] = true -- 350
							luaPackage.loaded[canonical] = nil -- 351
							luaPackage.loaded[relative] = nil -- 352
							local source = Content:load(file) -- 353
							for dependency in string.gmatch(source, "require%s*%(%s*[\"']([^\"']+)[\"']%s*%)") do -- 354
								refreshDependency(dependency) -- 354
							end -- 354
						end -- 343
						for ____, name in ipairs(reloadModules) do -- 356
							refreshDependency(name) -- 356
						end -- 356
						do -- 356
							local i = 0 -- 357
							while i < #reloadModules do -- 357
								local reloadName = reloadModules[i + 1] -- 358
								luaPackage.loaded[reloadName] = nil -- 359
								luaPackage.loaded[table.concat( -- 360
									__TS__StringSplit(reloadName, "/"), -- 360
									"." -- 360
								)] = nil -- 360
								luaPackage.loaded[table.concat( -- 361
									__TS__StringSplit(reloadName, "."), -- 361
									"/" -- 361
								)] = nil -- 361
								i = i + 1 -- 357
							end -- 357
						end -- 357
						return true, require(table.concat( -- 363
							__TS__StringSplit(moduleName, "/"), -- 363
							"." -- 363
						)) -- 363
					end) -- 363
					do -- 363
						Content.searchPaths = previousSearchPaths -- 365
						luaPackage.path = previousPath -- 366
					end -- 366
					if not ____try then -- 366
						error(____hasReturned, 0) -- 366
					end -- 366
					if ____try and ____hasReturned then -- 366
						return ____returnValue -- 342
					end -- 342
				end -- 342
			end, -- 307
			print = capturePrint, -- 369
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 370
			enterEntryAsync = function(value) -- 371
				local normalized = normalizeEntryFile(value) -- 372
				acquireEntryRuntime() -- 373
				entry.allClear() -- 374
				startEntryWatchdog() -- 375
				recordEntryLeaseRun(req.operationId, entry) -- 376
				local success, message = entry.enterEntryAsync({ -- 377
					entryName = normalized.entryName, -- 378
					fileName = normalized.fileName, -- 379
					workDir = req.workDir, -- 380
					projectRoot = req.workDir, -- 381
					runKind = "agent_test" -- 382
				}) -- 382
				return success, message -- 384
			end, -- 371
			stopEntry = function() -- 386
				if not ownsEntryRuntime or not ownsEntryLease(req.operationId, entry) then -- 386
					return false -- 387
				end -- 387
				return entry.stop() -- 388
			end, -- 386
			reportProgress = function(value, callbackValue) -- 390
				local ____callbackValue_25 = callbackValue -- 391
				if ____callbackValue_25 == nil then -- 391
					____callbackValue_25 = value -- 391
				end -- 391
				local actualValue = ____callbackValue_25 -- 391
				if not req.onProgress or not actualValue or type(actualValue) ~= "table" then -- 391
					return -- 392
				end -- 392
				local progress = actualValue -- 393
				local amount = type(progress.progress) == "number" and math.min( -- 394
					1, -- 395
					math.max(0, progress.progress) -- 395
				) or nil -- 395
				req:onProgress({ -- 397
					state = "running", -- 398
					mode = "lua", -- 399
					operationId = req.operationId, -- 400
					progress = amount, -- 401
					stage = type(progress.stage) == "string" and progress.stage or "lua", -- 402
					message = type(progress.message) == "string" and progress.message or "Lua command running" -- 403
				}) -- 403
			end -- 390
		}, -- 390
		{__index = function(_table, key) -- 406
			if key == "Content" then -- 406
				contentAccessed = true -- 409
				return scopedContent -- 410
			end -- 410
			if key == "refreshTree" then -- 410
				return refreshTree -- 413
			end -- 413
			local name = tostring(key) -- 415
			if blockedDoraGlobals[name] then -- 415
				return nil -- 416
			end -- 416
			return Dora[name] -- 417
		end} -- 407
	) -- 407
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 420
	if not fn then -- 420
		return __TS__Promise.resolve({ -- 422
			success = false, -- 423
			mode = "lua", -- 424
			output = truncateCommandOutput(table.concat(output, "\n")), -- 425
			message = truncateCommandError(toStr(compileErr)), -- 426
			phase = "compile" -- 427
		}) -- 427
	end -- 427
	return __TS__New( -- 430
		__TS__Promise, -- 430
		function(____, resolve) -- 430
			local settled = false -- 431
			local commandRoutine -- 432
			local onProgress = req.onProgress -- 433
			local isCancelled = req.isCancelled -- 434
			local function finish(result) -- 435
				if settled then -- 435
					return -- 436
				end -- 436
				settled = true -- 437
				commandClosed = true -- 438
				local cleanupError -- 439
				local cleanup = previewCleanup -- 440
				previewCleanup = nil -- 441
				do -- 441
					local function ____catch(e) -- 441
						cleanupError = "failed to release Agent preview: " .. tostring(e) -- 443
					end -- 443
					local ____try, ____hasReturned = pcall(function() -- 443
						if cleanup ~= nil then -- 443
							cleanup() -- 442
						end -- 442
					end) -- 442
					if not ____try then -- 442
						____catch(____hasReturned) -- 442
					end -- 442
				end -- 442
				if restorePrint ~= nil then -- 442
					restorePrint() -- 444
				end -- 444
				restorePrint = nil -- 445
				if not result.success and (result.interrupted == true or result.phase == "timeout") and (not entry.getCurrentEntryStatus().running or ownsEntryLease(req.operationId, entry)) then -- 445
					do -- 445
						local function ____catch(e) -- 445
							cleanupError = "failed to clear interrupted Lua command runtime: " .. tostring(e) -- 451
						end -- 451
						local ____try, ____hasReturned = pcall(function() -- 451
							entry.allClear() -- 449
						end) -- 449
						if not ____try then -- 449
							____catch(____hasReturned) -- 449
						end -- 449
					end -- 449
				end -- 449
				local entryCleanupError = stopOwnedEntry() -- 454
				if cleanupError == nil then -- 454
					cleanupError = entryCleanupError -- 455
				end -- 455
				if contentAccessed and not refreshTreeCalled and not refreshWorkspaceTree(req.workDir) then -- 455
					Log("Warn", "[execute_command] failed to refresh Web IDE tree after Lua command workDir=" .. req.workDir) -- 457
				end -- 457
				local ____lastPreviewResult_35 -- 459
				if lastPreviewResult then -- 459
					local ____lastPreviewResult_success_32 = lastPreviewResult.success -- 460
					local ____lastPreviewResult_message_33 = lastPreviewResult.message -- 461
					local ____lastPreviewResult_files_34 = lastPreviewResult.files -- 462
					local ____opt_30 = lastPreviewResult.frames -- 462
					____lastPreviewResult_35 = {success = ____lastPreviewResult_success_32, message = ____lastPreviewResult_message_33, files = ____lastPreviewResult_files_34, frameCount = ____opt_30 and #____opt_30} -- 459
				else -- 459
					____lastPreviewResult_35 = nil -- 464
				end -- 464
				local previewGame = ____lastPreviewResult_35 -- 459
				local visionFields = __TS__ObjectAssign( -- 465
					{}, -- 465
					#godotRuntimeSceneResults > 0 and ({godotRuntimeScenes = godotRuntimeSceneResults}) or ({}), -- 466
					#godotSceneResults > 0 and ({godotScenes = godotSceneResults}) or ({}), -- 467
					#godotImportResults > 0 and ({godotImports = godotImportResults}) or ({}), -- 468
					previewGame and ({previewGame = previewGame}) or ({}), -- 469
					capturedBatches > 0 and ({ -- 470
						visionCapture = {batchCount = capturedBatches, frameCount = capturedFrames}, -- 471
						visionBudget = getVisionBudgetState(currentVisionUsage()) -- 472
					}) or ({}) -- 472
				) -- 472
				if not result.success and cleanupError ~= nil then -- 472
					result.cleanupError = cleanupError -- 476
				elseif result.success and cleanupError ~= nil then -- 476
					resolve( -- 478
						nil, -- 478
						__TS__ObjectAssign({ -- 478
							success = false, -- 479
							mode = "lua", -- 480
							output = result.output, -- 481
							message = cleanupError, -- 482
							phase = "execute", -- 483
							cleanupError = cleanupError -- 484
						}, visionFields) -- 484
					) -- 484
					return -- 487
				end -- 487
				if result.success and __TS__ArraySome( -- 487
					godotRuntimeSceneResults, -- 489
					function(____, scene) return not scene.success end -- 489
				) then -- 489
					resolve( -- 490
						nil, -- 490
						__TS__ObjectAssign({ -- 490
							success = false, -- 490
							mode = "lua", -- 490
							output = result.output, -- 490
							message = "inspectGodotRuntimeScene failed; inspect godotRuntimeScenes for diagnostics", -- 491
							phase = "execute" -- 491
						}, visionFields) -- 491
					) -- 491
					return -- 492
				end -- 492
				if result.success and __TS__ArraySome( -- 492
					godotSceneResults, -- 494
					function(____, scene) return not scene.success end -- 494
				) then -- 494
					resolve( -- 495
						nil, -- 495
						__TS__ObjectAssign({ -- 495
							success = false, -- 495
							mode = "lua", -- 495
							output = result.output, -- 495
							message = "inspectGodotScene failed; inspect godotScenes for diagnostics", -- 496
							phase = "execute" -- 496
						}, visionFields) -- 496
					) -- 496
					return -- 497
				end -- 497
				if result.success and __TS__ArraySome( -- 497
					godotImportResults, -- 499
					function(____, batch) return not batch.success end -- 499
				) then -- 499
					resolve( -- 500
						nil, -- 500
						__TS__ObjectAssign({ -- 500
							success = false, -- 500
							mode = "lua", -- 500
							output = result.output, -- 500
							message = "importGodotAssets failed; inspect godotImports for per-file results", -- 501
							phase = "execute" -- 501
						}, visionFields) -- 501
					) -- 501
					return -- 502
				end -- 502
				if result.success and lastPreviewResult and not lastPreviewResult.success then -- 502
					resolve( -- 505
						nil, -- 505
						__TS__ObjectAssign({ -- 505
							success = false, -- 506
							mode = "lua", -- 507
							output = result.output, -- 508
							message = "previewGame failed: " .. (lastPreviewResult.message or "unknown error"), -- 509
							phase = "execute" -- 510
						}, visionFields) -- 510
					) -- 510
					return -- 513
				end -- 513
				resolve( -- 515
					nil, -- 515
					__TS__ObjectAssign({}, result, visionFields) -- 515
				) -- 515
			end -- 435
			if onProgress then -- 435
				onProgress(nil, { -- 521
					state = "pending", -- 522
					mode = "lua", -- 523
					operationId = req.operationId, -- 524
					stage = "lua", -- 525
					message = "Lua command pending" -- 526
				}) -- 526
			end -- 526
			commandRoutine = once(function() -- 529
				if settled then -- 529
					return -- 530
				end -- 530
				if onProgress then -- 530
					onProgress(nil, { -- 532
						state = "running", -- 533
						mode = "lua", -- 534
						operationId = req.operationId, -- 535
						stage = "lua", -- 536
						message = "Lua command running" -- 537
					}) -- 537
				end -- 537
				local previousGlobalPrint = _G.print -- 540
				restorePrint = function() -- 541
					if _G.print == capturePrint then -- 541
						_G.print = previousGlobalPrint -- 541
					end -- 541
				end -- 541
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 542
				local frameTimedOut = false -- 543
				local watchdogMessage -- 543
				_G.print = capturePrint -- 544
				debug.sethook( -- 545
					function() -- 545
						if watchdogMessage == nil then -- 545
							watchdogMessage = checkEntryWatchdog() -- 546
						end -- 546
						if watchdogMessage ~= nil then -- 546
							error(watchdogMessage) -- 547
						end -- 547
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 547
							frameTimedOut = true -- 549
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 550
						end -- 550
					end, -- 545
					"", -- 552
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 552
				) -- 552
				local ok, runtimeErr = pcall(fn) -- 553
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 553
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 555
				else -- 555
					debug.sethook() -- 561
				end -- 561
				_G.print = previousGlobalPrint -- 563
				if not ok then -- 563
					local ____truncateCommandOutput_result_37 = truncateCommandOutput(table.concat(output, "\n")) -- 568
					local ____temp_38 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 569
					local ____temp_39 = frameTimedOut and "timeout" or "execute" -- 570
					local ____temp_36 -- 571
					if watchdogMessage ~= nil or frameTimedOut then -- 571
						____temp_36 = true -- 571
					else -- 571
						____temp_36 = nil -- 571
					end -- 571
					finish({ -- 565
						success = false, -- 566
						mode = "lua", -- 567
						output = ____truncateCommandOutput_result_37, -- 568
						message = ____temp_38, -- 569
						phase = ____temp_39, -- 570
						interrupted = ____temp_36 -- 571
					}) -- 571
					return -- 573
				end -- 573
				finish({ -- 575
					success = true, -- 575
					mode = "lua", -- 575
					output = truncateCommandOutput(table.concat(output, "\n")) -- 575
				}) -- 575
			end) -- 529
			Director.systemScheduler:schedule(function() -- 577
				if settled then -- 577
					return true -- 578
				end -- 578
				local watchdogMessage = checkEntryWatchdog() -- 579
				if watchdogMessage ~= nil then -- 579
					finish({ -- 581
						success = false, -- 582
						mode = "lua", -- 583
						output = truncateCommandOutput(table.concat(output, "\n")), -- 584
						message = watchdogMessage, -- 585
						phase = "execute", -- 586
						interrupted = true -- 587
					}) -- 587
					return true -- 589
				end -- 589
				if isCancelled and isCancelled(nil) then -- 589
					finish({ -- 592
						success = false, -- 593
						mode = "lua", -- 594
						output = truncateCommandOutput(table.concat(output, "\n")), -- 595
						message = "Lua command canceled", -- 596
						phase = "execute", -- 597
						interrupted = true -- 598
					}) -- 598
					return true -- 600
				end -- 600
				if not waitingForDownload and App.runningTime >= deadline then -- 600
					finish({ -- 603
						success = false, -- 604
						mode = "lua", -- 605
						output = truncateCommandOutput(table.concat(output, "\n")), -- 606
						message = ("Lua command timed out after " .. tostring(math.max( -- 607
							1, -- 607
							math.floor(deadline - startedAt - downloadWaitSeconds + 0.5) -- 607
						))) .. " seconds", -- 607
						phase = "timeout" -- 608
					}) -- 608
					return true -- 610
				end -- 610
				if commandRoutine == nil then -- 610
					finish({ -- 613
						success = false, -- 614
						mode = "lua", -- 615
						output = truncateCommandOutput(table.concat(output, "\n")), -- 616
						message = "Lua command coroutine is unavailable", -- 617
						phase = "execute" -- 618
					}) -- 618
					return true -- 620
				end -- 620
				local resumeSuccess, resumeResult = coroutine.resume(commandRoutine) -- 622
				if not resumeSuccess then -- 622
					finish({ -- 624
						success = false, -- 625
						mode = "lua", -- 626
						output = truncateCommandOutput(table.concat(output, "\n")), -- 627
						message = truncateCommandError(toStr(resumeResult)), -- 628
						phase = "execute" -- 629
					}) -- 629
					return true -- 631
				end -- 631
				return settled or resumeResult == true -- 633
			end) -- 577
		end -- 430
	) -- 430
end -- 108
function ____exports.executeCommand(req) -- 638
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 638
		local mode = req.mode -- 650
		if mode ~= "lua" and mode ~= "git" then -- 650
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 650
		end -- 650
		if mode == "lua" then -- 650
			return ____awaiter_resolve( -- 650
				nil, -- 650
				executeLuaCommand({ -- 655
					workDir = req.workDir, -- 656
					docLanguage = req.docLanguage, -- 657
					code = req.code or "", -- 658
					timeoutSeconds = math.max( -- 659
						1, -- 659
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 659
					), -- 659
					operationId = createOperationId(), -- 660
					taskId = req.taskId or 0, -- 661
					onProgress = req.onProgress, -- 662
					isCancelled = req.isCancelled -- 663
				}) -- 663
			) -- 663
		end -- 663
		local operationId = createOperationId() -- 666
		return ____awaiter_resolve( -- 666
			nil, -- 666
			executeGitCommand({ -- 667
				workDir = req.workDir, -- 668
				command = req.command or "", -- 669
				cwd = req.cwd, -- 670
				timeoutSeconds = math.max( -- 671
					1, -- 671
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 671
				), -- 671
				operationId = operationId, -- 672
				onProgress = req.onProgress, -- 673
				isCancelled = req.isCancelled -- 674
			}) -- 674
		) -- 674
	end) -- 674
end -- 638
return ____exports -- 638