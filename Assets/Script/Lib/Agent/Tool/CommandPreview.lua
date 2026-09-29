-- [ts]: CommandPreview.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local Director = ____Dora.Director -- 2
local DoraObject = ____Dora.Object -- 2
local Path = ____Dora.Path -- 2
local sleep = ____Dora.sleep -- 2
local Config = require("Agent.Config") -- 3
local ____EntryLease = require("Agent.Tool.EntryLease") -- 4
local acquireEntryLease = ____EntryLease.acquireEntryLease -- 4
local recordEntryLeaseRun = ____EntryLease.recordEntryLeaseRun -- 4
local ownsEntryLease = ____EntryLease.ownsEntryLease -- 4
local releaseEntryLease = ____EntryLease.releaseEntryLease -- 4
local ____Operation = require("Agent.Tool.Operation") -- 5
local createOperationId = ____Operation.createOperationId -- 5
local ____Workspace = require("Agent.Tool.Workspace") -- 6
local isValidWorkspacePath = ____Workspace.isValidWorkspacePath -- 6
local ensureDirPath = ____Workspace.ensureDirPath -- 6
local ____ToolBudgets = require("Agent.Tool.ToolBudgets") -- 7
local PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS = ____ToolBudgets.PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS -- 7
local PREVIEW_GAME_TIMEOUT_SECONDS = ____ToolBudgets.PREVIEW_GAME_TIMEOUT_SECONDS -- 7
local ____Utils = require("Agent.Utils") -- 8
local safeJsonDecode = ____Utils.safeJsonDecode -- 8
local safeJsonEncode = ____Utils.safeJsonEncode -- 8
____exports.COMMAND_VISION_DIR = ".agent/vision" -- 27
local PREVIEW_ENTRY_EXTENSIONS = { -- 29
	"", -- 29
	"lua", -- 29
	"ts", -- 29
	"tsx", -- 29
	"yue", -- 29
	"tl", -- 29
	"xml" -- 29
} -- 29
--- Captures kept per project; oldest files roll out first.
____exports.COMMAND_VISION_MAX_FILES = 60 -- 38
--- Keep only the newest COMMAND_VISION_MAX_FILES capture files. Only files
-- named like <timestamp>-<random>.png (this feature's own output) are ever
-- removed; user-placed images in the same directory are untouched. Delete
-- failures are ignored: pruning must never break a capture.
function ____exports.pruneVisionCaptures(dir, keep) -- 46
	if keep == nil then -- 46
		keep = ____exports.COMMAND_VISION_MAX_FILES -- 46
	end -- 46
	if not Content:exist(dir) then -- 46
		return -- 47
	end -- 47
	local names = {} -- 48
	for ____, file in ipairs(Content:getFiles(dir)) do -- 49
		if (string.match(file, "^%d+%-%d+%.png$")) ~= nil then -- 49
			names[#names + 1] = file -- 50
		end -- 50
	end -- 50
	if #names <= keep then -- 50
		return -- 52
	end -- 52
	__TS__ArraySort( -- 54
		names, -- 54
		function(____, a, b) return a < b and 1 or (a > b and -1 or 0) end -- 54
	) -- 54
	do -- 54
		local i = keep -- 55
		while i < #names do -- 55
			Content:remove(Path(dir, names[i + 1])) -- 56
			i = i + 1 -- 55
		end -- 55
	end -- 55
end -- 46
--- The previewGame function injected into execute_command's Lua sandbox.
-- It owns the game exclusively, captures 1-3 frames at the requested
-- seconds after startup, saves them under .agent/vision in the project
-- and returns the project-relative paths. Runs synchronously on the
-- command coroutine; frame callbacks are awaited with sleep() polling.
function ____exports.createPreviewGameInjection(req, entry) -- 67
	return function(opts) -- 76
		local o = type(opts) == "table" and opts or ({}) -- 77
		local file = type(o.entry) == "string" and __TS__StringTrim(o.entry) ~= "" and __TS__StringTrim(o.entry) or "init.lua" -- 78
		local function complete(result) -- 79
			local encoded = safeJsonEncode(result) -- 80
			if encoded then -- 80
				req.print(encoded) -- 81
			end -- 81
			local ____opt_0 = req.onResult -- 81
			if ____opt_0 ~= nil then -- 81
				____opt_0(result) -- 82
			end -- 82
			return result -- 83
		end -- 79
		local requestedTimes = o.captureAtSeconds -- 85
		if requestedTimes ~= nil and not __TS__ArrayIsArray(requestedTimes) then -- 85
			return complete({success = false, message = "captureAtSeconds needs 1-3 increasing times between 0 and 10"}) -- 87
		end -- 87
		local rawTimes = requestedTimes or ({0.5}) -- 89
		local times = {} -- 90
		for ____, value in ipairs(rawTimes) do -- 91
			if type(value) ~= "number" or not __TS__NumberIsFinite(value) then -- 91
				return complete({success = false, message = "captureAtSeconds needs 1-3 increasing times between 0 and 10"}) -- 93
			end -- 93
			times[#times + 1] = value -- 95
		end -- 95
		local sourceExt = string.lower(Path:getExt(file)) -- 97
		if not isValidWorkspacePath(file) or __TS__ArrayIndexOf(PREVIEW_ENTRY_EXTENSIONS, sourceExt) < 0 then -- 97
			return complete({success = false, message = "previewGame entry must be a built project-relative Lua, TypeScript, YueScript, Teal, or XML entry"}) -- 99
		end -- 99
		if #times < 1 or #times > 3 or __TS__ArraySome( -- 99
			times, -- 101
			function(____, t, i) return t < 0 or t > 10 or i > 0 and t <= times[i] end -- 101
		) then -- 101
			return complete({success = false, message = "captureAtSeconds needs 1-3 increasing times between 0 and 10"}) -- 102
		end -- 102
		local full = Path:replaceExt( -- 104
			Path(req.workDir, file), -- 104
			"lua" -- 104
		) -- 104
		if not Content:exist(full) then -- 104
			return complete({success = false, message = "Build the entry before previewGame; generated Lua was not found at " .. full}) -- 106
		end -- 106
		if type(_studio_agent_tool_begin) == "function" then -- 106
			local reserveCapture = req.reserveCapture -- 109
			local reservation = reserveCapture and reserveCapture(#times) or nil -- 110
			if reservation and not reservation.success then -- 110
				return complete({success = false, message = reservation.message or "Vision capture budget exhausted", visionBudget = reservation.budget}) -- 111
			end -- 111
			local requestId -- 112
			local active = false -- 112
			local function cancel() -- 113
				if active and requestId then -- 113
					active = false -- 113
					if _studio_agent_tool_cancel ~= nil then -- 113
						_studio_agent_tool_cancel(requestId) -- 113
					end -- 113
				end -- 113
			end -- 113
			local ____opt_4 = req.registerCleanup -- 113
			if ____opt_4 ~= nil then -- 113
				____opt_4(cancel) -- 114
			end -- 114
			local result = {success = false, message = "Studio Agent Player preview did not complete", visionBudget = reservation and reservation.budget} -- 115
			do -- 115
				local function ____catch(____error) -- 115
					cancel() -- 138
					result = { -- 138
						success = false, -- 138
						message = tostring(____error), -- 138
						visionBudget = reservation and reservation.budget -- 138
					} -- 138
				end -- 138
				local ____try, ____hasReturned = pcall(function() -- 138
					local options = safeJsonEncode({entry = file, captureAtSeconds = times}) -- 117
					if not options then -- 117
						error("failed to encode Studio Agent preview options") -- 118
					end -- 118
					requestId = _studio_agent_tool_begin("preview-game", full, options, req.workDir) -- 119
					active = true -- 120
					local deadline = App.runningTime + PREVIEW_GAME_TIMEOUT_SECONDS -- 121
					local answer -- 122
					while not answer do -- 122
						local ____opt_8 = req.isCancelled -- 122
						if (____opt_8 and ____opt_8()) == true then -- 122
							error("previewGame cancelled") -- 124
						end -- 124
						if App.runningTime >= deadline then -- 124
							error("previewGame timed out") -- 125
						end -- 125
						answer = _studio_agent_tool_poll and _studio_agent_tool_poll(requestId) -- 126
						if not answer then -- 126
							sleep() -- 127
						end -- 127
					end -- 127
					active = false -- 129
					if not answer.success then -- 129
						error(answer.message or "Studio Agent Player preview failed") -- 130
					end -- 130
					local decoded = safeJsonDecode(answer.resultJSON or "") -- 131
					local value = decoded -- 132
					if not value or value.success ~= true or not __TS__ArrayIsArray(value.files) or not __TS__ArrayIsArray(value.frames) or #value.files ~= #times or #value.frames ~= #times or __TS__ArraySome( -- 132
						value.files, -- 135
						function(____, path) return type(path) ~= "string" or not __TS__StringStartsWith(path, ____exports.COMMAND_VISION_DIR .. "/") end -- 135
					) then -- 135
						error("Invalid Studio Agent Player preview result") -- 135
					end -- 135
					result = {success = true, files = value.files, frames = value.frames, visionBudget = reservation and reservation.budget} -- 136
					____exports.pruneVisionCaptures(Path(req.workDir, ".agent", "vision")) -- 137
				end) -- 137
				if not ____try then -- 137
					____catch(____hasReturned) -- 137
				end -- 137
				do -- 137
					local ____opt_16 = req.registerCleanup -- 137
					if ____opt_16 ~= nil then -- 137
						____opt_16(nil) -- 139
					end -- 139
				end -- 139
			end -- 139
			return complete(result) -- 140
		end -- 140
		if Director.beginGameCapture == nil or Director.captureGameAsync == nil or Director.endGameCapture == nil then -- 140
			return complete({success = false, message = "This engine build does not support game capture; update Dora SSR"}) -- 143
		end -- 143
		local visionDir = Path(req.workDir, ".agent", "vision") -- 145
		if not ensureDirPath(visionDir) then -- 145
			return complete({success = false, message = "failed to create the .agent/vision directory"}) -- 147
		end -- 147
		local reserveCapture = req.reserveCapture -- 151
		local reservation = reserveCapture and reserveCapture(#times) or nil -- 152
		if reservation and not reservation.success then -- 152
			return complete({success = false, message = reservation.message or "Vision capture budget exhausted", visionBudget = reservation.budget}) -- 154
		end -- 154
		local function cancelled() -- 156
			local ____opt_18 = req.isCancelled -- 156
			return (____opt_18 and ____opt_18()) == true -- 156
		end -- 156
		local start = App.runningTime -- 157
		local scope = false -- 158
		local leased = false -- 159
		local interruptedUserRun = false -- 160
		local ____opt_20 = req.registerCleanup -- 160
		if ____opt_20 ~= nil then -- 160
			____opt_20(function() -- 161
				if scope then -- 161
					scope = false -- 162
					Director:endGameCapture() -- 162
				end -- 162
				if leased then -- 162
					leased = false -- 164
					local message = releaseEntryLease(req.operationId, entry) -- 165
					if message ~= nil then -- 165
						error(message) -- 166
					end -- 166
				end -- 166
			end) -- 161
		end -- 161
		local files = {} -- 169
		local frames = {} -- 170
		local result = {success = false, message = "previewGame did not complete"} -- 171
		local function check() -- 172
			if cancelled() then -- 172
				error("previewGame cancelled") -- 173
			end -- 173
			if not ownsEntryLease(req.operationId, entry) then -- 173
				error("previewGame lost ownership of the running game") -- 174
			end -- 174
			if App.runningTime - start > PREVIEW_GAME_TIMEOUT_SECONDS then -- 174
				error("previewGame timed out") -- 175
			end -- 175
		end -- 172
		do -- 172
			local function ____catch(e) -- 172
				result = { -- 246
					success = false, -- 246
					files = files, -- 246
					message = tostring(e), -- 246
					interruptedUserRun = interruptedUserRun, -- 246
					visionBudget = reservation and reservation.budget -- 246
				} -- 246
			end -- 246
			local ____try, ____hasReturned = pcall(function() -- 246
				interruptedUserRun = acquireEntryLease(req.operationId, entry) -- 178
				leased = true -- 179
				entry.allClear() -- 180
				scope = Director:beginGameCapture() -- 181
				if not scope then -- 181
					error("Game capture is unavailable or busy") -- 182
				end -- 182
				local objects = DoraObject.count -- 183
				local refs = DoraObject.luaRefCount -- 184
				recordEntryLeaseRun(req.operationId, entry) -- 185
				local previousHook, previousMask, previousCount = debug.gethook() -- 186
				do -- 186
					local ____try, ____error = pcall(function() -- 186
						debug.sethook( -- 188
							function() -- 188
								if cancelled() then -- 188
									error("previewGame cancelled during startup") -- 189
								end -- 189
								if App.elapsedTime >= Config.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 189
									error("previewGame startup exceeded the game frame time budget") -- 190
								end -- 190
								if App.runningTime - start > PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS then -- 190
									error("previewGame startup exceeded the startup time budget") -- 191
								end -- 191
								if DoraObject.count - objects > Config.AGENT_LIMITS.executeCommandMaxObjectGrowth or DoraObject.luaRefCount - refs > Config.AGENT_LIMITS.executeCommandMaxLuaRefGrowth then -- 191
									error("previewGame startup exceeded the game object budget") -- 192
								end -- 192
							end, -- 188
							"", -- 193
							Config.AGENT_LIMITS.executeCommandHookInstructionCount -- 193
						) -- 193
						local ok, message = entry.enterEntryAsync({ -- 194
							entryName = Path:getName(full), -- 195
							fileName = Path:replaceExt(full, ""), -- 196
							workDir = req.workDir, -- 197
							projectRoot = req.workDir, -- 198
							runKind = "agent_test" -- 199
						}) -- 199
						if not ok then -- 199
							error(message or "Game entry failed") -- 201
						end -- 201
					end) -- 201
					do -- 201
						if previousHook ~= nil and previousMask ~= nil and previousCount ~= nil then -- 201
							debug.sethook(previousHook, previousMask, previousCount) -- 204
						else -- 204
							debug.sethook() -- 206
						end -- 206
					end -- 206
					if not ____try then -- 206
						error(____error, 0) -- 206
					end -- 206
				end -- 206
				local started = App.runningTime -- 209
				for ____, time in ipairs(times) do -- 210
					while App.runningTime - started < time do -- 210
						check() -- 212
						sleep() -- 213
					end -- 213
					check() -- 215
					local assetId = createOperationId() -- 216
					local absPath = Path(visionDir, assetId .. ".png") -- 217
					local done = false -- 218
					local saved = false -- 219
					local capturedAt = 0 -- 220
					local width = 0 -- 221
					local height = 0 -- 222
					if not Director:captureGameAsync( -- 222
						absPath, -- 223
						function(success, frameTime, sourceSize) -- 223
							saved = success -- 224
							capturedAt = frameTime -- 225
							width = sourceSize.width -- 226
							height = sourceSize.height -- 227
							done = true -- 228
						end -- 223
					) then -- 223
						error("Capture request was rejected") -- 229
					end -- 229
					while not done do -- 229
						check() -- 231
						sleep() -- 232
					end -- 232
					check() -- 234
					if not saved then -- 234
						error("Game capture could not be saved") -- 235
					end -- 235
					local relative = ((____exports.COMMAND_VISION_DIR .. "/") .. assetId) .. ".png" -- 236
					files[#files + 1] = relative -- 237
					frames[#frames + 1] = {path = relative, width = width, height = height, elapsedSeconds = capturedAt - started} -- 238
				end -- 238
				____exports.pruneVisionCaptures(visionDir) -- 240
				local cleanupError = releaseEntryLease(req.operationId, entry) -- 241
				leased = false -- 242
				if cleanupError then -- 242
					error(cleanupError) -- 243
				end -- 243
				result = { -- 244
					success = true, -- 244
					files = files, -- 244
					frames = frames, -- 244
					interruptedUserRun = interruptedUserRun, -- 244
					visionBudget = reservation and reservation.budget -- 244
				} -- 244
			end) -- 244
			if not ____try then -- 244
				____catch(____hasReturned) -- 244
			end -- 244
			do -- 244
				if scope then -- 244
					Director:endGameCapture() -- 248
				end -- 248
				if leased then -- 248
					local cleanupError = releaseEntryLease(req.operationId, entry) -- 250
					if cleanupError ~= nil then -- 250
						result = result.success and ({success = false, files = files, message = cleanupError, interruptedUserRun = interruptedUserRun}) or ({success = false, files = files, message = ((result.message or "previewGame failed") .. "; ") .. cleanupError, interruptedUserRun = interruptedUserRun}) -- 252
					end -- 252
				end -- 252
			end -- 252
		end -- 252
		local ____opt_26 = req.registerCleanup -- 252
		if ____opt_26 ~= nil then -- 252
			____opt_26(nil) -- 258
		end -- 258
		return complete(result) -- 259
	end -- 76
end -- 67
return ____exports -- 67