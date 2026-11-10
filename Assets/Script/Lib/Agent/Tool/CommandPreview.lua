-- [ts]: CommandPreview.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local Director = ____Dora.Director -- 2
local DoraObject = ____Dora.Object -- 2
local Path = ____Dora.Path -- 2
local sleep = ____Dora.sleep -- 2
local Config = require("Agent.Config.Defaults") -- 3
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
local ____GodotBuild = require("Agent.Tool.GodotBuild") -- 10
local findGodotProject = ____GodotBuild.findGodotProject -- 10
____exports.COMMAND_VISION_DIR = ".agent/vision" -- 28
local PREVIEW_ENTRY_EXTENSIONS = { -- 30
	"", -- 30
	"lua", -- 30
	"ts", -- 30
	"tsx", -- 30
	"yue", -- 30
	"tl", -- 30
	"xml" -- 30
} -- 30
--- Captures kept per project; oldest files roll out first.
____exports.COMMAND_VISION_MAX_FILES = 60 -- 39
--- Keep only the newest COMMAND_VISION_MAX_FILES capture files. Only files
-- named like <timestamp>-<random>.png (this feature's own output) are ever
-- removed; user-placed images in the same directory are untouched. Delete
-- failures are ignored: pruning must never break a capture.
function ____exports.pruneVisionCaptures(dir, keep) -- 47
	if keep == nil then -- 47
		keep = ____exports.COMMAND_VISION_MAX_FILES -- 47
	end -- 47
	if not Content:exist(dir) then -- 47
		return -- 48
	end -- 48
	local names = {} -- 49
	for ____, file in ipairs(Content:getFiles(dir)) do -- 50
		if (string.match(file, "^%d+%-%d+%.png$")) ~= nil then -- 50
			names[#names + 1] = file -- 51
		end -- 51
	end -- 51
	if #names <= keep then -- 51
		return -- 53
	end -- 53
	__TS__ArraySort( -- 55
		names, -- 55
		function(____, a, b) return a < b and 1 or (a > b and -1 or 0) end -- 55
	) -- 55
	do -- 55
		local i = keep -- 56
		while i < #names do -- 56
			Content:remove(Path(dir, names[i + 1])) -- 57
			i = i + 1 -- 56
		end -- 56
	end -- 56
end -- 47
--- The previewGame function injected into execute_command's Lua sandbox.
-- It owns the game exclusively, captures 1-3 frames at the requested
-- seconds after runtime readiness, saves them under .agent/vision in the project
-- and returns the project-relative paths. Runs synchronously on the
-- command coroutine; frame callbacks are awaited with sleep() polling.
function ____exports.createPreviewGameInjection(req, entry) -- 68
	return function(opts) -- 77
		local o = type(opts) == "table" and opts or ({}) -- 78
		local file = type(o.entry) == "string" and __TS__StringTrim(o.entry) ~= "" and __TS__StringTrim(o.entry) or "init.lua" -- 79
		local function complete(result) -- 80
			local encoded = safeJsonEncode(result) -- 81
			if encoded then -- 81
				req.print(encoded) -- 82
			end -- 82
			local ____opt_0 = req.onResult -- 82
			if ____opt_0 ~= nil then -- 82
				____opt_0(result) -- 83
			end -- 83
			return result -- 84
		end -- 80
		local requestedTimes = o.captureAtSeconds -- 86
		if requestedTimes ~= nil and not __TS__ArrayIsArray(requestedTimes) then -- 86
			return complete({success = false, message = "captureAtSeconds needs 1-3 increasing times between 0 and 10"}) -- 88
		end -- 88
		local rawTimes = requestedTimes or ({0.5}) -- 90
		local times = {} -- 91
		for ____, value in ipairs(rawTimes) do -- 92
			if type(value) ~= "number" or not __TS__NumberIsFinite(value) then -- 92
				return complete({success = false, message = "captureAtSeconds needs 1-3 increasing times between 0 and 10"}) -- 94
			end -- 94
			times[#times + 1] = value -- 96
		end -- 96
		local sourceExt = string.lower(Path:getExt(file)) -- 98
		if not isValidWorkspacePath(file) or __TS__ArrayIndexOf(PREVIEW_ENTRY_EXTENSIONS, sourceExt) < 0 then -- 98
			return complete({success = false, message = "previewGame entry must be a built project-relative Lua, TypeScript, YueScript, Teal, or XML entry"}) -- 100
		end -- 100
		if #times < 1 or #times > 3 or __TS__ArraySome( -- 100
			times, -- 102
			function(____, t, i) return t < 0 or t > 10 or i > 0 and t <= times[i] end -- 102
		) then -- 102
			return complete({success = false, message = "captureAtSeconds needs 1-3 increasing times between 0 and 10"}) -- 103
		end -- 103
		local full = Path:replaceExt( -- 105
			Path(req.workDir, file), -- 105
			"lua" -- 105
		) -- 105
		if not Content:exist(full) then -- 105
			return complete({success = false, message = "Build the entry before previewGame; generated Lua was not found at " .. full}) -- 107
		end -- 107
		if type(_studio_agent_tool_begin) == "function" then -- 107
			local reserveCapture = req.reserveCapture -- 110
			local reservation = reserveCapture and reserveCapture(#times) or nil -- 111
			if reservation and not reservation.success then -- 111
				return complete({success = false, message = reservation.message or "Vision capture budget exhausted", visionBudget = reservation.budget}) -- 112
			end -- 112
			local requestId -- 113
			local active = false -- 113
			local function cancel() -- 114
				if active and requestId then -- 114
					active = false -- 114
					if _studio_agent_tool_cancel ~= nil then -- 114
						_studio_agent_tool_cancel(requestId) -- 114
					end -- 114
				end -- 114
			end -- 114
			local ____opt_4 = req.registerCleanup -- 114
			if ____opt_4 ~= nil then -- 114
				____opt_4(cancel) -- 115
			end -- 115
			local result = {success = false, message = "Studio Agent Player preview did not complete", visionBudget = reservation and reservation.budget} -- 116
			do -- 116
				local function ____catch(____error) -- 116
					cancel() -- 139
					result = { -- 139
						success = false, -- 139
						message = tostring(____error), -- 139
						visionBudget = reservation and reservation.budget -- 139
					} -- 139
				end -- 139
				local ____try, ____hasReturned = pcall(function() -- 139
					local options = safeJsonEncode({entry = file, captureAtSeconds = times}) -- 118
					if not options then -- 118
						error("failed to encode Studio Agent preview options") -- 119
					end -- 119
					requestId = _studio_agent_tool_begin("preview-game", full, options, req.workDir) -- 120
					active = true -- 121
					local deadline = App.runningTime + PREVIEW_GAME_TIMEOUT_SECONDS -- 122
					local answer -- 123
					while not answer do -- 123
						local ____opt_8 = req.isCancelled -- 123
						if (____opt_8 and ____opt_8()) == true then -- 123
							error("previewGame cancelled") -- 125
						end -- 125
						if App.runningTime >= deadline then -- 125
							error("previewGame timed out") -- 126
						end -- 126
						answer = _studio_agent_tool_poll and _studio_agent_tool_poll(requestId) -- 127
						if not answer then -- 127
							sleep() -- 128
						end -- 128
					end -- 128
					active = false -- 130
					if not answer.success then -- 130
						error(answer.message or "Studio Agent Player preview failed") -- 131
					end -- 131
					local decoded = safeJsonDecode(answer.resultJSON or "") -- 132
					local value = decoded -- 133
					if not value or value.success ~= true or not __TS__ArrayIsArray(value.files) or not __TS__ArrayIsArray(value.frames) or #value.files ~= #times or #value.frames ~= #times or __TS__ArraySome( -- 133
						value.files, -- 136
						function(____, path) return type(path) ~= "string" or not __TS__StringStartsWith(path, ____exports.COMMAND_VISION_DIR .. "/") end -- 136
					) then -- 136
						error("Invalid Studio Agent Player preview result") -- 136
					end -- 136
					result = {success = true, files = value.files, frames = value.frames, visionBudget = reservation and reservation.budget} -- 137
					____exports.pruneVisionCaptures(Path(req.workDir, ".agent", "vision")) -- 138
				end) -- 138
				if not ____try then -- 138
					____catch(____hasReturned) -- 138
				end -- 138
				do -- 138
					local ____opt_16 = req.registerCleanup -- 138
					if ____opt_16 ~= nil then -- 138
						____opt_16(nil) -- 140
					end -- 140
				end -- 140
			end -- 140
			return complete(result) -- 141
		end -- 141
		if Director.beginGameCapture == nil or Director.captureGameAsync == nil or Director.endGameCapture == nil then -- 141
			return complete({success = false, message = "This engine build does not support game capture; update Dora SSR"}) -- 144
		end -- 144
		local visionDir = Path(req.workDir, ".agent", "vision") -- 146
		if not ensureDirPath(visionDir) then -- 146
			return complete({success = false, message = "failed to create the .agent/vision directory"}) -- 148
		end -- 148
		local reserveCapture = req.reserveCapture -- 152
		local reservation = reserveCapture and reserveCapture(#times) or nil -- 153
		if reservation and not reservation.success then -- 153
			return complete({success = false, message = reservation.message or "Vision capture budget exhausted", visionBudget = reservation.budget}) -- 155
		end -- 155
		local function cancelled() -- 157
			local ____opt_18 = req.isCancelled -- 157
			return (____opt_18 and ____opt_18()) == true -- 157
		end -- 157
		local start = App.runningTime -- 158
		local scope = false -- 159
		local leased = false -- 160
		local interruptedUserRun = false -- 161
		local ____opt_20 = req.registerCleanup -- 161
		if ____opt_20 ~= nil then -- 161
			____opt_20(function() -- 162
				if scope then -- 162
					scope = false -- 163
					Director:endGameCapture() -- 163
				end -- 163
				if leased then -- 163
					leased = false -- 165
					local message = releaseEntryLease(req.operationId, entry) -- 166
					if message ~= nil then -- 166
						error(message) -- 167
					end -- 167
				end -- 167
			end) -- 162
		end -- 162
		local files = {} -- 170
		local frames = {} -- 171
		local monitor -- 172
		local result = {success = false, message = "previewGame did not complete"} -- 173
		local function check() -- 174
			if cancelled() then -- 174
				error("previewGame cancelled") -- 175
			end -- 175
			if not ownsEntryLease(req.operationId, entry) then -- 175
				error("previewGame lost ownership of the running game") -- 176
			end -- 176
			if App.runningTime - start > PREVIEW_GAME_TIMEOUT_SECONDS then -- 176
				error("previewGame timed out") -- 177
			end -- 177
			if monitor ~= nil then -- 177
				local ok, message = monitor() -- 179
				if not ok then -- 179
					error(message or "Game failed during preview") -- 180
				end -- 180
			end -- 180
		end -- 174
		do -- 174
			local function ____catch(e) -- 174
				result = { -- 265
					success = false, -- 265
					files = files, -- 265
					frames = frames, -- 265
					message = tostring(e), -- 265
					interruptedUserRun = interruptedUserRun, -- 265
					visionBudget = reservation and reservation.budget -- 265
				} -- 265
			end -- 265
			local ____try, ____hasReturned = pcall(function() -- 265
				interruptedUserRun = acquireEntryLease(req.operationId, entry) -- 184
				leased = true -- 185
				entry.allClear() -- 186
				scope = Director:beginGameCapture() -- 187
				if not scope then -- 187
					error("Game capture is unavailable or busy") -- 188
				end -- 188
				local objects = DoraObject.count -- 189
				local refs = DoraObject.luaRefCount -- 190
				recordEntryLeaseRun(req.operationId, entry) -- 191
				local previousHook, previousMask, previousCount = debug.gethook() -- 192
				do -- 192
					local ____try, ____error = pcall(function() -- 192
						debug.sethook( -- 194
							function() -- 194
								if cancelled() then -- 194
									error("previewGame cancelled during startup") -- 195
								end -- 195
								if App.elapsedTime >= Config.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 195
									error("previewGame startup exceeded the game frame time budget") -- 196
								end -- 196
								if App.runningTime - start > PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS then -- 196
									error("previewGame startup exceeded the startup time budget") -- 197
								end -- 197
								if DoraObject.count - objects > Config.AGENT_LIMITS.executeCommandMaxObjectGrowth or DoraObject.luaRefCount - refs > Config.AGENT_LIMITS.executeCommandMaxLuaRefGrowth then -- 197
									error("previewGame startup exceeded the game object budget") -- 198
								end -- 198
							end, -- 194
							"", -- 199
							Config.AGENT_LIMITS.executeCommandHookInstructionCount -- 199
						) -- 199
						local ok, message = entry.enterEntryAsync({ -- 200
							entryName = Path:getName(full), -- 201
							fileName = Path:replaceExt(full, ""), -- 202
							workDir = req.workDir, -- 203
							projectRoot = req.workDir, -- 204
							runKind = "agent_test" -- 205
						}) -- 205
						if not ok then -- 205
							error(message or "Game entry failed") -- 207
						end -- 207
					end) -- 207
					do -- 207
						if previousHook ~= nil and previousMask ~= nil and previousCount ~= nil then -- 207
							debug.sethook(previousHook, previousMask, previousCount) -- 210
						else -- 210
							debug.sethook() -- 212
						end -- 212
					end -- 212
					if not ____try then -- 212
						error(____error, 0) -- 212
					end -- 212
				end -- 212
				local transition = require("Script.Dev.RunTransition") -- 215
				local runId = entry.getCurrentEntryStatus().runId -- 219
				if runId == nil then -- 219
					error("previewGame entry has no run identity") -- 220
				end -- 220
				local ready, startupError, checkRun = transition.waitForFrameAsync( -- 221
					entry, -- 221
					runId, -- 221
					findGodotProject(req.workDir, full) ~= nil, -- 222
					function() -- 222
						check() -- 223
						if App.runningTime - start > PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS then -- 223
							error("previewGame startup exceeded the startup time budget") -- 224
						end -- 224
					end -- 222
				) -- 222
				if not ready then -- 222
					error(startupError or "Game did not produce its first frame") -- 226
				end -- 226
				monitor = checkRun -- 227
				local started = App.runningTime -- 228
				for ____, time in ipairs(times) do -- 229
					while App.runningTime - started < time do -- 229
						check() -- 231
						sleep() -- 232
					end -- 232
					check() -- 234
					local assetId = createOperationId() -- 235
					local absPath = Path(visionDir, assetId .. ".png") -- 236
					local done = false -- 237
					local saved = false -- 238
					local capturedAt = 0 -- 239
					local width = 0 -- 240
					local height = 0 -- 241
					if not Director:captureGameAsync( -- 241
						absPath, -- 242
						function(success, frameTime, sourceSize) -- 242
							saved = success -- 243
							capturedAt = frameTime -- 244
							width = sourceSize.width -- 245
							height = sourceSize.height -- 246
							done = true -- 247
						end -- 242
					) then -- 242
						error("Capture request was rejected") -- 248
					end -- 248
					while not done do -- 248
						check() -- 250
						sleep() -- 251
					end -- 251
					check() -- 253
					if not saved then -- 253
						error("Game capture could not be saved") -- 254
					end -- 254
					local relative = ((____exports.COMMAND_VISION_DIR .. "/") .. assetId) .. ".png" -- 255
					files[#files + 1] = relative -- 256
					frames[#frames + 1] = {path = relative, width = width, height = height, elapsedSeconds = capturedAt - started} -- 257
				end -- 257
				____exports.pruneVisionCaptures(visionDir) -- 259
				local cleanupError = releaseEntryLease(req.operationId, entry) -- 260
				leased = false -- 261
				if cleanupError then -- 261
					error(cleanupError) -- 262
				end -- 262
				result = { -- 263
					success = true, -- 263
					files = files, -- 263
					frames = frames, -- 263
					interruptedUserRun = interruptedUserRun, -- 263
					visionBudget = reservation and reservation.budget -- 263
				} -- 263
			end) -- 263
			if not ____try then -- 263
				____catch(____hasReturned) -- 263
			end -- 263
			do -- 263
				if scope then -- 263
					Director:endGameCapture() -- 267
				end -- 267
				if leased then -- 267
					local cleanupError = releaseEntryLease(req.operationId, entry) -- 269
					if cleanupError ~= nil then -- 269
						result = __TS__ObjectAssign({}, result, {success = false, files = files, frames = frames, message = result.success and cleanupError or ((result.message or "previewGame failed") .. "; ") .. cleanupError}) -- 271
					end -- 271
				end -- 271
			end -- 271
		end -- 271
		local ____opt_26 = req.registerCleanup -- 271
		if ____opt_26 ~= nil then -- 271
			____opt_26(nil) -- 276
		end -- 276
		return complete(result) -- 277
	end -- 77
end -- 68
return ____exports -- 68