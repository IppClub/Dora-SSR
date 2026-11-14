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
	local refreshedProjectModules = {} -- 132
	local godotSceneResults = {} -- 133
	local godotRuntimeSceneResults = {} -- 134
	local godotImportResults = {} -- 135
	local lastPreviewResult -- 136
	local previewCleanup -- 137
	local restorePrint -- 138
	local function currentVisionUsage() -- 139
		if persistedVisionUsage == nil then -- 139
			persistedVisionUsage = getVisionTaskUsage(req.taskId) -- 140
		end -- 140
		return __TS__ObjectAssign({}, persistedVisionUsage, {captureBatchCount = persistedVisionUsage.captureBatchCount + capturedBatches, captureFrameCount = persistedVisionUsage.captureFrameCount + capturedFrames}) -- 141
	end -- 139
	local function reserveCapture(frameCount) -- 147
		local current = currentVisionUsage() -- 148
		if current.captureBatchCount >= VISION_MAX_CAPTURE_BATCHES or current.captureFrameCount + frameCount > VISION_MAX_CAPTURE_FRAMES then -- 148
			return { -- 150
				success = false, -- 151
				message = ((("Vision capture budget exhausted: " .. tostring(current.captureBatchCount)) .. " batches and ") .. tostring(current.captureFrameCount)) .. " frames already reserved", -- 152
				budget = getVisionBudgetState(current) -- 153
			} -- 153
		end -- 153
		capturedBatches = capturedBatches + 1 -- 156
		capturedFrames = capturedFrames + frameCount -- 157
		return { -- 158
			success = true, -- 158
			budget = getVisionBudgetState(currentVisionUsage()) -- 158
		} -- 158
	end -- 147
	local function acquireEntryRuntime() -- 160
		acquireEntryLease(req.operationId, entry) -- 161
		ownsEntryRuntime = true -- 162
	end -- 160
	local function stopOwnedEntry() -- 164
		if not ownsEntryRuntime then -- 164
			return nil -- 165
		end -- 165
		ownsEntryRuntime = false -- 166
		return releaseEntryLease(req.operationId, entry) -- 167
	end -- 164
	local function startEntryWatchdog() -- 169
		entryObjectBaseline = Dora.Object.count -- 170
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 171
	end -- 169
	local function checkEntryWatchdog() -- 173
		if not ownsEntryRuntime then -- 173
			return nil -- 174
		end -- 174
		local objectCount = Dora.Object.count -- 175
		local luaRefCount = Dora.Object.luaRefCount -- 176
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 177
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 178
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 179
		if not exceededTotal then -- 179
			return nil -- 182
		end -- 182
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 183
	end -- 173
	local function normalizeEntryFile(value) -- 187
		if not value or type(value) ~= "table" then -- 187
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 189
		end -- 189
		local descriptor = value -- 191
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 192
		if relativeFile == "" then -- 192
			relativeFile = "init" -- 193
		end -- 193
		if not isValidWorkspacePath(relativeFile) then -- 193
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 195
		end -- 195
		local fileName = Path(req.workDir, relativeFile) -- 197
		local ext = Path:getExt(fileName) -- 198
		if ext ~= "" then -- 198
			fileName = Path:replaceExt(fileName, "") -- 199
		end -- 199
		local luaFile = Path:replaceExt(fileName, "lua") -- 200
		if not Content:exist(luaFile) then -- 200
			error("Agent test entry was not built: " .. luaFile) -- 202
		end -- 202
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 204
		return { -- 205
			fileName = fileName, -- 206
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 207
		} -- 207
	end -- 187
	local function capturePrint(...) -- 210
		local values = {...} -- 210
		local parts = {} -- 211
		do -- 211
			local i = 0 -- 212
			while i < #values do -- 212
				parts[#parts + 1] = tostring(values[i + 1]) -- 213
				i = i + 1 -- 212
			end -- 212
		end -- 212
		output[#output + 1] = table.concat(parts, "\t") -- 215
	end -- 210
	local function refreshTree(path) -- 217
		refreshTreeCalled = true -- 218
		if path == nil then -- 218
			return refreshWorkspaceTree(req.workDir) -- 220
		end -- 220
		if type(path) ~= "string" then -- 220
			error("refreshTree expects a project-relative file path string or no argument") -- 223
		end -- 223
		return refreshWorkspaceTree(req.workDir, path) -- 225
	end -- 217
	local blockedDoraGlobals = {DB = true, HttpClient = true, HttpServer = true} -- 227
	local scopedContent = createCommandContent(req.workDir, req.docLanguage) -- 232
	local env = setmetatable( -- 233
		{ -- 233
			projectDir = req.workDir, -- 234
			inspectGodotRuntimeScene = createGodotRuntimeSceneInjection({ -- 235
				workDir = req.workDir, -- 236
				isCancelled = function() -- 237
					local ____commandClosed_13 = commandClosed -- 237
					if not ____commandClosed_13 then -- 237
						local ____this_12 -- 237
						____this_12 = req -- 237
						local ____opt_11 = ____this_12.isCancelled -- 237
						____commandClosed_13 = (____opt_11 and ____opt_11(____this_12)) == true -- 237
					end -- 237
					return ____commandClosed_13 -- 237
				end, -- 237
				print = capturePrint, -- 238
				onResult = function(result) -- 239
					godotRuntimeSceneResults[#godotRuntimeSceneResults + 1] = result -- 239
				end -- 239
			}), -- 239
			inspectGodotScene = createGodotSceneInjection({ -- 241
				workDir = req.workDir, -- 242
				isCancelled = function() -- 243
					local ____commandClosed_16 = commandClosed -- 243
					if not ____commandClosed_16 then -- 243
						local ____this_15 -- 243
						____this_15 = req -- 243
						local ____opt_14 = ____this_15.isCancelled -- 243
						____commandClosed_16 = (____opt_14 and ____opt_14(____this_15)) == true -- 243
					end -- 243
					return ____commandClosed_16 -- 243
				end, -- 243
				print = capturePrint, -- 244
				onResult = function(result) -- 245
					godotSceneResults[#godotSceneResults + 1] = result -- 245
				end -- 245
			}), -- 245
			importGodotAssets = createGodotImportInjection({ -- 247
				workDir = req.workDir, -- 248
				isCancelled = function() -- 249
					local ____commandClosed_19 = commandClosed -- 249
					if not ____commandClosed_19 then -- 249
						local ____this_18 -- 249
						____this_18 = req -- 249
						local ____opt_17 = ____this_18.isCancelled -- 249
						____commandClosed_19 = (____opt_17 and ____opt_17(____this_18)) == true -- 249
					end -- 249
					return ____commandClosed_19 -- 249
				end, -- 249
				print = capturePrint, -- 250
				onResult = function(result) -- 251
					godotImportResults[#godotImportResults + 1] = result -- 252
					if result.importedCount > 0 then -- 252
						contentAccessed = true -- 253
					end -- 253
				end -- 251
			}), -- 251
			previewGame = createPreviewGameInjection( -- 257
				{ -- 257
					workDir = req.workDir, -- 258
					operationId = req.operationId, -- 259
					isCancelled = req.isCancelled, -- 260
					print = function(line) return capturePrint(line) end, -- 261
					reserveCapture = reserveCapture, -- 262
					registerCleanup = function(cleanup) -- 263
						previewCleanup = cleanup -- 263
					end, -- 263
					onResult = function(result) -- 264
						lastPreviewResult = result -- 265
					end -- 264
				}, -- 264
				entry -- 267
			), -- 267
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 268
				if type(moduleNameValue) ~= "string" then -- 268
					error("requireProjectModule expects a project module name string") -- 270
				end -- 270
				local moduleName = __TS__StringTrim(moduleNameValue) -- 272
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 272
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 274
				end -- 274
				local reloadModules = {moduleName} -- 276
				if reloadModulesValue ~= nil then -- 276
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 276
						error("requireProjectModule reloadModules must be an array of module names") -- 279
					end -- 279
					local items = reloadModulesValue -- 281
					do -- 281
						local i = 0 -- 282
						while i < #items do -- 282
							local item = items[i + 1] -- 283
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 283
								error("requireProjectModule reloadModules contains an invalid module name") -- 285
							end -- 285
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 285
								reloadModules[#reloadModules + 1] = item -- 287
							end -- 287
							i = i + 1 -- 282
						end -- 282
					end -- 282
				end -- 282
				local luaPackage = _G.package -- 290
				local previousPath = luaPackage.path -- 294
				local previousSearchPaths = Content.searchPaths -- 295
				local scopedSearchPaths = {req.workDir} -- 296
				do -- 296
					local i = 0 -- 297
					while i < #previousSearchPaths do -- 297
						local searchPath = previousSearchPaths[i + 1] -- 298
						if searchPath ~= req.workDir then -- 298
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 299
						end -- 299
						i = i + 1 -- 297
					end -- 297
				end -- 297
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 301
				Content.searchPaths = scopedSearchPaths -- 302
				do -- 302
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 302
						local refreshDependency -- 304
						refreshDependency = function(name) -- 304
							local canonical = table.concat( -- 305
								__TS__StringSplit(name, "/"), -- 305
								"." -- 305
							) -- 305
							if refreshedProjectModules[canonical] or (string.find(canonical, "..", nil, true) or 0) - 1 >= 0 or (string.find(name, "/", nil, true) or 0) - 1 == 0 then -- 305
								return -- 306
							end -- 306
							local relative = table.concat( -- 307
								__TS__StringSplit(canonical, "."), -- 307
								"/" -- 307
							) -- 307
							local file = Path(req.workDir, relative .. ".lua") -- 308
							if not Content:exist(file) then -- 308
								file = Path(req.workDir, relative, "init.lua") -- 309
							end -- 309
							if not Content:exist(file) then -- 309
								return -- 310
							end -- 310
							refreshedProjectModules[canonical] = true -- 311
							luaPackage.loaded[canonical] = nil -- 312
							luaPackage.loaded[relative] = nil -- 313
							local source = Content:load(file) -- 314
							for dependency in string.gmatch(source, "require%s*%(%s*[\"']([^\"']+)[\"']%s*%)") do -- 315
								refreshDependency(dependency) -- 315
							end -- 315
						end -- 304
						for ____, name in ipairs(reloadModules) do -- 317
							refreshDependency(name) -- 317
						end -- 317
						do -- 317
							local i = 0 -- 318
							while i < #reloadModules do -- 318
								local reloadName = reloadModules[i + 1] -- 319
								luaPackage.loaded[reloadName] = nil -- 320
								luaPackage.loaded[table.concat( -- 321
									__TS__StringSplit(reloadName, "/"), -- 321
									"." -- 321
								)] = nil -- 321
								luaPackage.loaded[table.concat( -- 322
									__TS__StringSplit(reloadName, "."), -- 322
									"/" -- 322
								)] = nil -- 322
								i = i + 1 -- 318
							end -- 318
						end -- 318
						return true, require(table.concat( -- 324
							__TS__StringSplit(moduleName, "/"), -- 324
							"." -- 324
						)) -- 324
					end) -- 324
					do -- 324
						Content.searchPaths = previousSearchPaths -- 326
						luaPackage.path = previousPath -- 327
					end -- 327
					if not ____try then -- 327
						error(____hasReturned, 0) -- 327
					end -- 327
					if ____try and ____hasReturned then -- 327
						return ____returnValue -- 303
					end -- 303
				end -- 303
			end, -- 268
			print = capturePrint, -- 330
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 331
			enterEntryAsync = function(value) -- 332
				local normalized = normalizeEntryFile(value) -- 333
				acquireEntryRuntime() -- 334
				entry.allClear() -- 335
				startEntryWatchdog() -- 336
				recordEntryLeaseRun(req.operationId, entry) -- 337
				local success, message = entry.enterEntryAsync({ -- 338
					entryName = normalized.entryName, -- 339
					fileName = normalized.fileName, -- 340
					workDir = req.workDir, -- 341
					projectRoot = req.workDir, -- 342
					runKind = "agent_test" -- 343
				}) -- 343
				return success, message -- 345
			end, -- 332
			stopEntry = function() -- 347
				if not ownsEntryRuntime or not ownsEntryLease(req.operationId, entry) then -- 347
					return false -- 348
				end -- 348
				return entry.stop() -- 349
			end, -- 347
			reportProgress = function(value, callbackValue) -- 351
				local ____callbackValue_20 = callbackValue -- 352
				if ____callbackValue_20 == nil then -- 352
					____callbackValue_20 = value -- 352
				end -- 352
				local actualValue = ____callbackValue_20 -- 352
				if not req.onProgress or not actualValue or type(actualValue) ~= "table" then -- 352
					return -- 353
				end -- 353
				local progress = actualValue -- 354
				local amount = type(progress.progress) == "number" and math.min( -- 355
					1, -- 356
					math.max(0, progress.progress) -- 356
				) or nil -- 356
				req:onProgress({ -- 358
					state = "running", -- 359
					mode = "lua", -- 360
					operationId = req.operationId, -- 361
					progress = amount, -- 362
					stage = type(progress.stage) == "string" and progress.stage or "lua", -- 363
					message = type(progress.message) == "string" and progress.message or "Lua command running" -- 364
				}) -- 364
			end -- 351
		}, -- 351
		{__index = function(_table, key) -- 367
			if key == "Content" then -- 367
				contentAccessed = true -- 370
				return scopedContent -- 371
			end -- 371
			if key == "refreshTree" then -- 371
				return refreshTree -- 374
			end -- 374
			local name = tostring(key) -- 376
			if blockedDoraGlobals[name] then -- 376
				return nil -- 377
			end -- 377
			return Dora[name] -- 378
		end} -- 368
	) -- 368
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 381
	if not fn then -- 381
		return __TS__Promise.resolve({ -- 383
			success = false, -- 384
			mode = "lua", -- 385
			output = truncateCommandOutput(table.concat(output, "\n")), -- 386
			message = truncateCommandError(toStr(compileErr)), -- 387
			phase = "compile" -- 388
		}) -- 388
	end -- 388
	return __TS__New( -- 391
		__TS__Promise, -- 391
		function(____, resolve) -- 391
			local settled = false -- 392
			local commandRoutine -- 393
			local startedAt = App.runningTime -- 394
			local onProgress = req.onProgress -- 395
			local isCancelled = req.isCancelled -- 396
			local function finish(result) -- 397
				if settled then -- 397
					return -- 398
				end -- 398
				settled = true -- 399
				commandClosed = true -- 400
				local cleanupError -- 401
				local cleanup = previewCleanup -- 402
				previewCleanup = nil -- 403
				do -- 403
					local function ____catch(e) -- 403
						cleanupError = "failed to release Agent preview: " .. tostring(e) -- 405
					end -- 405
					local ____try, ____hasReturned = pcall(function() -- 405
						if cleanup ~= nil then -- 405
							cleanup() -- 404
						end -- 404
					end) -- 404
					if not ____try then -- 404
						____catch(____hasReturned) -- 404
					end -- 404
				end -- 404
				if restorePrint ~= nil then -- 404
					restorePrint() -- 406
				end -- 406
				restorePrint = nil -- 407
				if not result.success and (result.interrupted == true or result.phase == "timeout") and (not entry.getCurrentEntryStatus().running or ownsEntryLease(req.operationId, entry)) then -- 407
					do -- 407
						local function ____catch(e) -- 407
							cleanupError = "failed to clear interrupted Lua command runtime: " .. tostring(e) -- 413
						end -- 413
						local ____try, ____hasReturned = pcall(function() -- 413
							entry.allClear() -- 411
						end) -- 411
						if not ____try then -- 411
							____catch(____hasReturned) -- 411
						end -- 411
					end -- 411
				end -- 411
				local entryCleanupError = stopOwnedEntry() -- 416
				if cleanupError == nil then -- 416
					cleanupError = entryCleanupError -- 417
				end -- 417
				if contentAccessed and not refreshTreeCalled and not refreshWorkspaceTree(req.workDir) then -- 417
					Log("Warn", "[execute_command] failed to refresh Web IDE tree after Lua command workDir=" .. req.workDir) -- 419
				end -- 419
				local ____lastPreviewResult_30 -- 421
				if lastPreviewResult then -- 421
					local ____lastPreviewResult_success_27 = lastPreviewResult.success -- 422
					local ____lastPreviewResult_message_28 = lastPreviewResult.message -- 423
					local ____lastPreviewResult_files_29 = lastPreviewResult.files -- 424
					local ____opt_25 = lastPreviewResult.frames -- 424
					____lastPreviewResult_30 = {success = ____lastPreviewResult_success_27, message = ____lastPreviewResult_message_28, files = ____lastPreviewResult_files_29, frameCount = ____opt_25 and #____opt_25} -- 421
				else -- 421
					____lastPreviewResult_30 = nil -- 426
				end -- 426
				local previewGame = ____lastPreviewResult_30 -- 421
				local visionFields = __TS__ObjectAssign( -- 427
					{}, -- 427
					#godotRuntimeSceneResults > 0 and ({godotRuntimeScenes = godotRuntimeSceneResults}) or ({}), -- 428
					#godotSceneResults > 0 and ({godotScenes = godotSceneResults}) or ({}), -- 429
					#godotImportResults > 0 and ({godotImports = godotImportResults}) or ({}), -- 430
					previewGame and ({previewGame = previewGame}) or ({}), -- 431
					capturedBatches > 0 and ({ -- 432
						visionCapture = {batchCount = capturedBatches, frameCount = capturedFrames}, -- 433
						visionBudget = getVisionBudgetState(currentVisionUsage()) -- 434
					}) or ({}) -- 434
				) -- 434
				if not result.success and cleanupError ~= nil then -- 434
					result.cleanupError = cleanupError -- 438
				elseif result.success and cleanupError ~= nil then -- 438
					resolve( -- 440
						nil, -- 440
						__TS__ObjectAssign({ -- 440
							success = false, -- 441
							mode = "lua", -- 442
							output = result.output, -- 443
							message = cleanupError, -- 444
							phase = "execute", -- 445
							cleanupError = cleanupError -- 446
						}, visionFields) -- 446
					) -- 446
					return -- 449
				end -- 449
				if result.success and __TS__ArraySome( -- 449
					godotRuntimeSceneResults, -- 451
					function(____, scene) return not scene.success end -- 451
				) then -- 451
					resolve( -- 452
						nil, -- 452
						__TS__ObjectAssign({ -- 452
							success = false, -- 452
							mode = "lua", -- 452
							output = result.output, -- 452
							message = "inspectGodotRuntimeScene failed; inspect godotRuntimeScenes for diagnostics", -- 453
							phase = "execute" -- 453
						}, visionFields) -- 453
					) -- 453
					return -- 454
				end -- 454
				if result.success and __TS__ArraySome( -- 454
					godotSceneResults, -- 456
					function(____, scene) return not scene.success end -- 456
				) then -- 456
					resolve( -- 457
						nil, -- 457
						__TS__ObjectAssign({ -- 457
							success = false, -- 457
							mode = "lua", -- 457
							output = result.output, -- 457
							message = "inspectGodotScene failed; inspect godotScenes for diagnostics", -- 458
							phase = "execute" -- 458
						}, visionFields) -- 458
					) -- 458
					return -- 459
				end -- 459
				if result.success and __TS__ArraySome( -- 459
					godotImportResults, -- 461
					function(____, batch) return not batch.success end -- 461
				) then -- 461
					resolve( -- 462
						nil, -- 462
						__TS__ObjectAssign({ -- 462
							success = false, -- 462
							mode = "lua", -- 462
							output = result.output, -- 462
							message = "importGodotAssets failed; inspect godotImports for per-file results", -- 463
							phase = "execute" -- 463
						}, visionFields) -- 463
					) -- 463
					return -- 464
				end -- 464
				if result.success and lastPreviewResult and not lastPreviewResult.success then -- 464
					resolve( -- 467
						nil, -- 467
						__TS__ObjectAssign({ -- 467
							success = false, -- 468
							mode = "lua", -- 469
							output = result.output, -- 470
							message = "previewGame failed: " .. (lastPreviewResult.message or "unknown error"), -- 471
							phase = "execute" -- 472
						}, visionFields) -- 472
					) -- 472
					return -- 475
				end -- 475
				resolve( -- 477
					nil, -- 477
					__TS__ObjectAssign({}, result, visionFields) -- 477
				) -- 477
			end -- 397
			if onProgress then -- 397
				onProgress(nil, { -- 483
					state = "pending", -- 484
					mode = "lua", -- 485
					operationId = req.operationId, -- 486
					stage = "lua", -- 487
					message = "Lua command pending" -- 488
				}) -- 488
			end -- 488
			commandRoutine = once(function() -- 491
				if settled then -- 491
					return -- 492
				end -- 492
				if onProgress then -- 492
					onProgress(nil, { -- 494
						state = "running", -- 495
						mode = "lua", -- 496
						operationId = req.operationId, -- 497
						stage = "lua", -- 498
						message = "Lua command running" -- 499
					}) -- 499
				end -- 499
				local previousGlobalPrint = _G.print -- 502
				restorePrint = function() -- 503
					if _G.print == capturePrint then -- 503
						_G.print = previousGlobalPrint -- 503
					end -- 503
				end -- 503
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 504
				local frameTimedOut = false -- 505
				local watchdogMessage -- 505
				_G.print = capturePrint -- 506
				debug.sethook( -- 507
					function() -- 507
						if watchdogMessage == nil then -- 507
							watchdogMessage = checkEntryWatchdog() -- 508
						end -- 508
						if watchdogMessage ~= nil then -- 508
							error(watchdogMessage) -- 509
						end -- 509
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 509
							frameTimedOut = true -- 511
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 512
						end -- 512
					end, -- 507
					"", -- 514
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 514
				) -- 514
				local ok, runtimeErr = pcall(fn) -- 515
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 515
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 517
				else -- 517
					debug.sethook() -- 523
				end -- 523
				_G.print = previousGlobalPrint -- 525
				if not ok then -- 525
					local ____truncateCommandOutput_result_32 = truncateCommandOutput(table.concat(output, "\n")) -- 530
					local ____temp_33 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 531
					local ____temp_34 = frameTimedOut and "timeout" or "execute" -- 532
					local ____temp_31 -- 533
					if watchdogMessage ~= nil or frameTimedOut then -- 533
						____temp_31 = true -- 533
					else -- 533
						____temp_31 = nil -- 533
					end -- 533
					finish({ -- 527
						success = false, -- 528
						mode = "lua", -- 529
						output = ____truncateCommandOutput_result_32, -- 530
						message = ____temp_33, -- 531
						phase = ____temp_34, -- 532
						interrupted = ____temp_31 -- 533
					}) -- 533
					return -- 535
				end -- 535
				finish({ -- 537
					success = true, -- 537
					mode = "lua", -- 537
					output = truncateCommandOutput(table.concat(output, "\n")) -- 537
				}) -- 537
			end) -- 491
			Director.systemScheduler:schedule(function() -- 539
				if settled then -- 539
					return true -- 540
				end -- 540
				local watchdogMessage = checkEntryWatchdog() -- 541
				if watchdogMessage ~= nil then -- 541
					finish({ -- 543
						success = false, -- 544
						mode = "lua", -- 545
						output = truncateCommandOutput(table.concat(output, "\n")), -- 546
						message = watchdogMessage, -- 547
						phase = "execute", -- 548
						interrupted = true -- 549
					}) -- 549
					return true -- 551
				end -- 551
				if isCancelled and isCancelled(nil) then -- 551
					finish({ -- 554
						success = false, -- 555
						mode = "lua", -- 556
						output = truncateCommandOutput(table.concat(output, "\n")), -- 557
						message = "Lua command canceled", -- 558
						phase = "execute", -- 559
						interrupted = true -- 560
					}) -- 560
					return true -- 562
				end -- 562
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 562
					finish({ -- 565
						success = false, -- 566
						mode = "lua", -- 567
						output = truncateCommandOutput(table.concat(output, "\n")), -- 568
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 569
						phase = "timeout" -- 570
					}) -- 570
					return true -- 572
				end -- 572
				if commandRoutine == nil then -- 572
					finish({ -- 575
						success = false, -- 576
						mode = "lua", -- 577
						output = truncateCommandOutput(table.concat(output, "\n")), -- 578
						message = "Lua command coroutine is unavailable", -- 579
						phase = "execute" -- 580
					}) -- 580
					return true -- 582
				end -- 582
				local resumeSuccess, resumeResult = coroutine.resume(commandRoutine) -- 584
				if not resumeSuccess then -- 584
					finish({ -- 586
						success = false, -- 587
						mode = "lua", -- 588
						output = truncateCommandOutput(table.concat(output, "\n")), -- 589
						message = truncateCommandError(toStr(resumeResult)), -- 590
						phase = "execute" -- 591
					}) -- 591
					return true -- 593
				end -- 593
				return settled or resumeResult == true -- 595
			end) -- 539
		end -- 391
	) -- 391
end -- 103
function ____exports.executeCommand(req) -- 600
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 600
		local mode = req.mode -- 612
		if mode ~= "lua" and mode ~= "git" then -- 612
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 612
		end -- 612
		if mode == "lua" then -- 612
			return ____awaiter_resolve( -- 612
				nil, -- 612
				executeLuaCommand({ -- 617
					workDir = req.workDir, -- 618
					docLanguage = req.docLanguage, -- 619
					code = req.code or "", -- 620
					timeoutSeconds = math.max( -- 621
						1, -- 621
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 621
					), -- 621
					operationId = createOperationId(), -- 622
					taskId = req.taskId or 0, -- 623
					onProgress = req.onProgress, -- 624
					isCancelled = req.isCancelled -- 625
				}) -- 625
			) -- 625
		end -- 625
		local operationId = createOperationId() -- 628
		return ____awaiter_resolve( -- 628
			nil, -- 628
			executeGitCommand({ -- 629
				workDir = req.workDir, -- 630
				command = req.command or "", -- 631
				cwd = req.cwd, -- 632
				timeoutSeconds = math.max( -- 633
					1, -- 633
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 633
				), -- 633
				operationId = operationId, -- 634
				onProgress = req.onProgress, -- 635
				isCancelled = req.isCancelled -- 636
			}) -- 636
		) -- 636
	end) -- 636
end -- 600
return ____exports -- 600