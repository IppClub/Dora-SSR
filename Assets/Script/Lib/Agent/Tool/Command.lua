-- [ts]: Command.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
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
local LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS = 30 -- 45
local agentEntryRuntimeOwner = "" -- 46
local function executeLuaCommand(req) -- 48
	local code = __TS__StringTrim(req.code or "") -- 56
	if code == "" then -- 56
		return __TS__Promise.resolve({ -- 58
			success = false, -- 58
			mode = "lua", -- 58
			output = "", -- 58
			message = "missing code", -- 58
			phase = "validate" -- 58
		}) -- 58
	end -- 58
	local output = {} -- 60
	local entry = require("Script.Dev.Entry") -- 61
	local ownsEntryRuntime = false -- 62
	local contentAccessed = false -- 63
	local refreshTreeCalled = false -- 64
	local entryObjectBaseline = 0 -- 65
	local entryLuaRefBaseline = 0 -- 66
	local function acquireEntryRuntime() -- 67
		if agentEntryRuntimeOwner ~= "" and agentEntryRuntimeOwner ~= req.operationId then -- 67
			error("Dora entry runtime is busy with another Agent command") -- 69
		end -- 69
		agentEntryRuntimeOwner = req.operationId -- 71
		ownsEntryRuntime = true -- 72
	end -- 67
	local function stopOwnedEntry() -- 74
		if not ownsEntryRuntime then -- 74
			return nil -- 75
		end -- 75
		local cleanupError -- 76
		do -- 76
			local function ____catch(e) -- 76
				cleanupError = "failed to stop Agent test entry: " .. tostring(e) -- 80
			end -- 80
			local ____try, ____hasReturned = pcall(function() -- 80
				entry.stop() -- 78
			end) -- 78
			if not ____try then -- 78
				____catch(____hasReturned) -- 78
			end -- 78
		end -- 78
		ownsEntryRuntime = false -- 82
		if agentEntryRuntimeOwner == req.operationId then -- 82
			agentEntryRuntimeOwner = "" -- 84
		end -- 84
		return cleanupError -- 86
	end -- 74
	local function startEntryWatchdog() -- 88
		entryObjectBaseline = Dora.Object.count -- 89
		entryLuaRefBaseline = Dora.Object.luaRefCount -- 90
	end -- 88
	local function checkEntryWatchdog() -- 92
		if not ownsEntryRuntime then -- 92
			return nil -- 93
		end -- 93
		local objectCount = Dora.Object.count -- 94
		local luaRefCount = Dora.Object.luaRefCount -- 95
		local objectGrowth = math.max(0, objectCount - entryObjectBaseline) -- 96
		local luaRefGrowth = math.max(0, luaRefCount - entryLuaRefBaseline) -- 97
		local exceededTotal = objectGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxObjectGrowth or luaRefGrowth >= AgentConfig.AGENT_LIMITS.executeCommandMaxLuaRefGrowth -- 98
		if not exceededTotal then -- 98
			return nil -- 101
		end -- 101
		return ("Entry watchdog stopped the test and cleaned up after abnormal object growth: " .. ((("live objects +" .. tostring(objectGrowth)) .. ", Lua references +") .. tostring(luaRefGrowth)) .. ". ") .. "Use a bounded test with a strict entity limit and only a few fixed simulation steps." -- 102
	end -- 92
	local function normalizeEntryFile(value) -- 106
		if not value or type(value) ~= "table" then -- 106
			error("enterEntryAsync expects a table with an optional project-relative fileName") -- 108
		end -- 108
		local descriptor = value -- 110
		local relativeFile = type(descriptor.fileName) == "string" and __TS__StringTrim(descriptor.fileName) or "" -- 111
		if relativeFile == "" then -- 111
			relativeFile = "init" -- 112
		end -- 112
		if not isValidWorkspacePath(relativeFile) then -- 112
			error("enterEntryAsync fileName must be a project-relative path without '..'") -- 114
		end -- 114
		local fileName = Path(req.workDir, relativeFile) -- 116
		local ext = Path:getExt(fileName) -- 117
		if ext ~= "" then -- 117
			fileName = Path:replaceExt(fileName, "") -- 118
		end -- 118
		local luaFile = Path:replaceExt(fileName, "lua") -- 119
		if not Content:exist(luaFile) then -- 119
			error("Agent test entry was not built: " .. luaFile) -- 121
		end -- 121
		local requestedName = type(descriptor.entryName) == "string" and __TS__StringTrim(descriptor.entryName) or "" -- 123
		return { -- 124
			fileName = fileName, -- 125
			entryName = requestedName ~= "" and requestedName or Path:getName(fileName) -- 126
		} -- 126
	end -- 106
	local function capturePrint(...) -- 129
		local values = {...} -- 129
		local parts = {} -- 130
		do -- 130
			local i = 0 -- 131
			while i < #values do -- 131
				parts[#parts + 1] = tostring(values[i + 1]) -- 132
				i = i + 1 -- 131
			end -- 131
		end -- 131
		output[#output + 1] = table.concat(parts, "\t") -- 134
	end -- 129
	local function refreshTree(path) -- 136
		refreshTreeCalled = true -- 137
		if path == nil then -- 137
			return refreshWorkspaceTree(req.workDir) -- 139
		end -- 139
		if type(path) ~= "string" then -- 139
			error("refreshTree expects a project-relative file path string or no argument") -- 142
		end -- 142
		return refreshWorkspaceTree(req.workDir, path) -- 144
	end -- 136
	local function resolveLuaContentPath(first, second) -- 146
		local value = type(second) == "string" and second or first -- 147
		if type(value) ~= "string" then -- 147
			error("Content path must be a project-relative string") -- 149
		end -- 149
		local fullPath = resolveWorkspaceFilePath(req.workDir, value) -- 151
		if not fullPath then -- 151
			error("Content path must stay inside projectDir") -- 153
		end -- 153
		return fullPath -- 155
	end -- 146
	local scopedContent = { -- 157
		exist = function(first, second) return Content:exist(resolveLuaContentPath(first, second)) end, -- 158
		isdir = function(first, second) return Content:isdir(resolveLuaContentPath(first, second)) end, -- 159
		getAttr = function(first, second) return Content:getAttr(resolveLuaContentPath(first, second)) end, -- 160
		load = function(first, second) -- 161
			local fullPath = resolveLuaContentPath(first, second) -- 162
			local inspected = inspectReadableFile(fullPath) -- 163
			if not inspected.success then -- 163
				error(inspected.message or "file is not readable") -- 164
			end -- 164
			return Content:load(fullPath) -- 165
		end -- 161
	} -- 161
	local blockedDoraGlobals = {Content = true, DB = true, HttpClient = true, HttpServer = true} -- 168
	local env = setmetatable( -- 174
		{ -- 174
			projectDir = req.workDir, -- 175
			requireProjectModule = function(moduleNameValue, reloadModulesValue) -- 176
				if type(moduleNameValue) ~= "string" then -- 176
					error("requireProjectModule expects a project module name string") -- 178
				end -- 178
				local moduleName = __TS__StringTrim(moduleNameValue) -- 180
				if moduleName == "" or (string.find(moduleName, "..", nil, true) or 0) - 1 >= 0 or (string.find(moduleName, "/", nil, true) or 0) - 1 == 0 then -- 180
					error("requireProjectModule expects a non-empty project module name without '..' or an absolute path") -- 182
				end -- 182
				local reloadModules = {moduleName} -- 184
				if reloadModulesValue ~= nil then -- 184
					if not __TS__ArrayIsArray(reloadModulesValue) then -- 184
						error("requireProjectModule reloadModules must be an array of module names") -- 187
					end -- 187
					local items = reloadModulesValue -- 189
					do -- 189
						local i = 0 -- 190
						while i < #items do -- 190
							local item = items[i + 1] -- 191
							if type(item) ~= "string" or __TS__StringTrim(item) == "" or (string.find(item, "..", nil, true) or 0) - 1 >= 0 then -- 191
								error("requireProjectModule reloadModules contains an invalid module name") -- 193
							end -- 193
							if __TS__ArrayIndexOf(reloadModules, item) < 0 then -- 193
								reloadModules[#reloadModules + 1] = item -- 195
							end -- 195
							i = i + 1 -- 190
						end -- 190
					end -- 190
				end -- 190
				local luaPackage = _G.package -- 198
				local previousPath = luaPackage.path -- 202
				local previousSearchPaths = Content.searchPaths -- 203
				local scopedSearchPaths = {req.workDir} -- 204
				do -- 204
					local i = 0 -- 205
					while i < #previousSearchPaths do -- 205
						local searchPath = previousSearchPaths[i + 1] -- 206
						if searchPath ~= req.workDir then -- 206
							scopedSearchPaths[#scopedSearchPaths + 1] = searchPath -- 207
						end -- 207
						i = i + 1 -- 205
					end -- 205
				end -- 205
				luaPackage.path = (((Path(req.workDir, "?.lua") .. ";") .. Path(req.workDir, "?", "init.lua")) .. ";") .. previousPath -- 209
				Content.searchPaths = scopedSearchPaths -- 210
				do -- 210
					local ____try, ____hasReturned, ____returnValue = pcall(function() -- 210
						do -- 210
							local i = 0 -- 212
							while i < #reloadModules do -- 212
								local reloadName = reloadModules[i + 1] -- 213
								luaPackage.loaded[reloadName] = nil -- 214
								luaPackage.loaded[table.concat( -- 215
									__TS__StringSplit(reloadName, "/"), -- 215
									"." -- 215
								)] = nil -- 215
								luaPackage.loaded[table.concat( -- 216
									__TS__StringSplit(reloadName, "."), -- 216
									"/" -- 216
								)] = nil -- 216
								i = i + 1 -- 212
							end -- 212
						end -- 212
						return true, require(table.concat( -- 218
							__TS__StringSplit(moduleName, "/"), -- 218
							"." -- 218
						)) -- 218
					end) -- 218
					do -- 218
						Content.searchPaths = previousSearchPaths -- 220
						luaPackage.path = previousPath -- 221
					end -- 221
					if not ____try then -- 221
						error(____hasReturned, 0) -- 221
					end -- 221
					if ____try and ____hasReturned then -- 221
						return ____returnValue -- 211
					end -- 211
				end -- 211
			end, -- 176
			print = capturePrint, -- 224
			getEntryStatus = function() return entry.getCurrentEntryStatus() end, -- 225
			enterEntryAsync = function(value) -- 226
				local normalized = normalizeEntryFile(value) -- 227
				acquireEntryRuntime() -- 228
				entry.allClear() -- 229
				startEntryWatchdog() -- 230
				local success, message = entry.enterEntryAsync({ -- 231
					entryName = normalized.entryName, -- 232
					fileName = normalized.fileName, -- 233
					workDir = req.workDir, -- 234
					projectRoot = req.workDir, -- 235
					runKind = "agent_test" -- 236
				}) -- 236
				return success, message -- 238
			end, -- 226
			stopEntry = function() -- 240
				if not ownsEntryRuntime then -- 240
					return false -- 241
				end -- 241
				return entry.stop() -- 242
			end, -- 240
			reportProgress = function(value, callbackValue) -- 244
				local ____callbackValue_0 = callbackValue -- 245
				if ____callbackValue_0 == nil then -- 245
					____callbackValue_0 = value -- 245
				end -- 245
				local actualValue = ____callbackValue_0 -- 245
				if not req.onProgress or not actualValue or type(actualValue) ~= "table" then -- 245
					return -- 246
				end -- 246
				local progress = actualValue -- 247
				local amount = type(progress.progress) == "number" and math.min( -- 248
					1, -- 249
					math.max(0, progress.progress) -- 249
				) or nil -- 249
				req:onProgress({ -- 251
					state = "running", -- 252
					mode = "lua", -- 253
					operationId = req.operationId, -- 254
					progress = amount, -- 255
					stage = type(progress.stage) == "string" and progress.stage or "lua", -- 256
					message = type(progress.message) == "string" and progress.message or "Lua command running" -- 257
				}) -- 257
			end -- 244
		}, -- 244
		{__index = function(_table, key) -- 260
			if key == "Content" then -- 260
				contentAccessed = true -- 263
				return scopedContent -- 264
			end -- 264
			if key == "refreshTree" then -- 264
				return refreshTree -- 267
			end -- 267
			local name = tostring(key) -- 269
			if blockedDoraGlobals[name] then -- 269
				return nil -- 270
			end -- 270
			return Dora[name] -- 271
		end} -- 261
	) -- 261
	local fn, compileErr = load(code, "=(agent_command)", "t", env) -- 274
	if not fn then -- 274
		return __TS__Promise.resolve({ -- 276
			success = false, -- 277
			mode = "lua", -- 278
			output = truncateCommandOutput(table.concat(output, "\n")), -- 279
			message = truncateCommandError(toStr(compileErr)), -- 280
			phase = "compile" -- 281
		}) -- 281
	end -- 281
	return __TS__New( -- 284
		__TS__Promise, -- 284
		function(____, resolve) -- 284
			local settled = false -- 285
			local commandRoutine -- 286
			local startedAt = App.runningTime -- 287
			local onProgress = req.onProgress -- 288
			local isCancelled = req.isCancelled -- 289
			local function finish(result) -- 290
				if settled then -- 290
					return -- 291
				end -- 291
				settled = true -- 292
				local cleanupError -- 293
				if not result.success and (result.interrupted == true or result.phase == "timeout") then -- 293
					do -- 293
						local function ____catch(e) -- 293
							cleanupError = "failed to clear interrupted Lua command runtime: " .. tostring(e) -- 298
						end -- 298
						local ____try, ____hasReturned = pcall(function() -- 298
							entry.allClear() -- 296
						end) -- 296
						if not ____try then -- 296
							____catch(____hasReturned) -- 296
						end -- 296
					end -- 296
				end -- 296
				local entryCleanupError = stopOwnedEntry() -- 301
				if cleanupError == nil then -- 301
					cleanupError = entryCleanupError -- 302
				end -- 302
				if contentAccessed and not refreshTreeCalled and not refreshWorkspaceTree(req.workDir) then -- 302
					Log("Warn", "[execute_command] failed to refresh Web IDE tree after Lua command workDir=" .. req.workDir) -- 304
				end -- 304
				if not result.success and cleanupError ~= nil then -- 304
					result.cleanupError = cleanupError -- 307
				elseif result.success and cleanupError ~= nil then -- 307
					resolve(nil, { -- 309
						success = false, -- 310
						mode = "lua", -- 311
						output = result.output, -- 312
						message = cleanupError, -- 313
						phase = "execute", -- 314
						cleanupError = cleanupError -- 315
					}) -- 315
					return -- 317
				end -- 317
				resolve(nil, result) -- 319
			end -- 290
			if onProgress then -- 290
				onProgress(nil, { -- 322
					state = "pending", -- 323
					mode = "lua", -- 324
					operationId = req.operationId, -- 325
					stage = "lua", -- 326
					message = "Lua command pending" -- 327
				}) -- 327
			end -- 327
			commandRoutine = once(function() -- 330
				if settled then -- 330
					return -- 331
				end -- 331
				if onProgress then -- 331
					onProgress(nil, { -- 333
						state = "running", -- 334
						mode = "lua", -- 335
						operationId = req.operationId, -- 336
						stage = "lua", -- 337
						message = "Lua command running" -- 338
					}) -- 338
				end -- 338
				local previousGlobalPrint = _G.print -- 341
				local previousHook, previousHookMask, previousHookCount = debug.gethook() -- 342
				local frameTimedOut = false -- 343
				local watchdogMessage -- 343
				_G.print = capturePrint -- 344
				debug.sethook( -- 345
					function() -- 345
						if watchdogMessage == nil then -- 345
							watchdogMessage = checkEntryWatchdog() -- 346
						end -- 346
						if watchdogMessage ~= nil then -- 346
							error(watchdogMessage) -- 347
						end -- 347
						if App.elapsedTime >= AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 347
							frameTimedOut = true -- 349
							error(("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame") -- 350
						end -- 350
					end, -- 345
					"", -- 352
					AgentConfig.AGENT_LIMITS.executeCommandHookInstructionCount -- 352
				) -- 352
				local ok, runtimeErr = pcall(fn) -- 353
				if previousHook ~= nil and previousHookMask ~= nil and previousHookCount ~= nil then -- 353
					debug.sethook(previousHook, previousHookMask, previousHookCount) -- 355
				else -- 355
					debug.sethook() -- 361
				end -- 361
				_G.print = previousGlobalPrint -- 363
				if not ok then -- 363
					local ____truncateCommandOutput_result_2 = truncateCommandOutput(table.concat(output, "\n")) -- 368
					local ____temp_3 = watchdogMessage or (frameTimedOut and ("Lua command exceeded " .. tostring(AgentConfig.AGENT_LIMITS.executeCommandFrameTimeoutSeconds)) .. " seconds in one game frame" or truncateCommandError(toStr(runtimeErr))) -- 369
					local ____temp_4 = frameTimedOut and "timeout" or "execute" -- 370
					local ____temp_1 -- 371
					if watchdogMessage ~= nil or frameTimedOut then -- 371
						____temp_1 = true -- 371
					else -- 371
						____temp_1 = nil -- 371
					end -- 371
					finish({ -- 365
						success = false, -- 366
						mode = "lua", -- 367
						output = ____truncateCommandOutput_result_2, -- 368
						message = ____temp_3, -- 369
						phase = ____temp_4, -- 370
						interrupted = ____temp_1 -- 371
					}) -- 371
					return -- 373
				end -- 373
				finish({ -- 375
					success = true, -- 375
					mode = "lua", -- 375
					output = truncateCommandOutput(table.concat(output, "\n")) -- 375
				}) -- 375
			end) -- 330
			Director.systemScheduler:schedule(function() -- 377
				if settled then -- 377
					return true -- 378
				end -- 378
				local watchdogMessage = checkEntryWatchdog() -- 379
				if watchdogMessage ~= nil then -- 379
					finish({ -- 381
						success = false, -- 382
						mode = "lua", -- 383
						output = truncateCommandOutput(table.concat(output, "\n")), -- 384
						message = watchdogMessage, -- 385
						phase = "execute", -- 386
						interrupted = true -- 387
					}) -- 387
					return true -- 389
				end -- 389
				if isCancelled and isCancelled(nil) then -- 389
					finish({ -- 392
						success = false, -- 393
						mode = "lua", -- 394
						output = truncateCommandOutput(table.concat(output, "\n")), -- 395
						message = "Lua command canceled", -- 396
						phase = "execute", -- 397
						interrupted = true -- 398
					}) -- 398
					return true -- 400
				end -- 400
				if App.runningTime - startedAt >= req.timeoutSeconds then -- 400
					finish({ -- 403
						success = false, -- 404
						mode = "lua", -- 405
						output = truncateCommandOutput(table.concat(output, "\n")), -- 406
						message = ("Lua command timed out after " .. tostring(req.timeoutSeconds)) .. " seconds", -- 407
						phase = "timeout" -- 408
					}) -- 408
					return true -- 410
				end -- 410
				if commandRoutine == nil then -- 410
					finish({ -- 413
						success = false, -- 414
						mode = "lua", -- 415
						output = truncateCommandOutput(table.concat(output, "\n")), -- 416
						message = "Lua command coroutine is unavailable", -- 417
						phase = "execute" -- 418
					}) -- 418
					return true -- 420
				end -- 420
				local resumeSuccess, resumeResult = coroutine.resume(commandRoutine) -- 422
				if not resumeSuccess then -- 422
					finish({ -- 424
						success = false, -- 425
						mode = "lua", -- 426
						output = truncateCommandOutput(table.concat(output, "\n")), -- 427
						message = truncateCommandError(toStr(resumeResult)), -- 428
						phase = "execute" -- 429
					}) -- 429
					return true -- 431
				end -- 431
				return settled or resumeResult == true -- 433
			end) -- 377
		end -- 284
	) -- 284
end -- 48
function ____exports.executeCommand(req) -- 438
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 438
		local mode = req.mode -- 448
		if mode ~= "lua" and mode ~= "git" then -- 448
			return ____awaiter_resolve(nil, {success = false, message = "mode must be lua or git", phase = "validate"}) -- 448
		end -- 448
		if mode == "lua" then -- 448
			return ____awaiter_resolve( -- 448
				nil, -- 448
				executeLuaCommand({ -- 453
					workDir = req.workDir, -- 454
					code = req.code or "", -- 455
					timeoutSeconds = math.max( -- 456
						1, -- 456
						math.floor(__TS__Number(req.timeoutSeconds or LUA_COMMAND_DEFAULT_TIMEOUT_SECONDS)) -- 456
					), -- 456
					operationId = createOperationId(), -- 457
					onProgress = req.onProgress, -- 458
					isCancelled = req.isCancelled -- 459
				}) -- 459
			) -- 459
		end -- 459
		local operationId = createOperationId() -- 462
		return ____awaiter_resolve( -- 462
			nil, -- 462
			executeGitCommand({ -- 463
				workDir = req.workDir, -- 464
				command = req.command or "", -- 465
				cwd = req.cwd, -- 466
				timeoutSeconds = math.max( -- 467
					1, -- 467
					math.floor(__TS__Number(req.timeoutSeconds or 600)) -- 467
				), -- 467
				operationId = operationId, -- 468
				onProgress = req.onProgress, -- 469
				isCancelled = req.isCancelled -- 470
			}) -- 470
		) -- 470
	end) -- 470
end -- 438
return ____exports -- 438