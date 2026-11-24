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
-- seconds after runtime readiness, saves them under .agent/vision in the project
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
		local function cancelled() -- 152
			local ____opt_18 = req.isCancelled -- 152
			return (____opt_18 and ____opt_18()) == true -- 152
		end -- 152
		local start = 0 -- 153
		local scope = false -- 154
		local leased = false -- 155
		local reservation -- 156
		local ____opt_20 = req.registerCleanup -- 156
		if ____opt_20 ~= nil then -- 156
			____opt_20(function() -- 157
				if scope then -- 157
					scope = false -- 158
					Director:endGameCapture() -- 158
				end -- 158
				if leased then -- 158
					leased = false -- 160
					local message = releaseEntryLease(req.operationId, entry) -- 161
					if message ~= nil then -- 161
						error(message) -- 162
					end -- 162
				end -- 162
			end) -- 157
		end -- 157
		local files = {} -- 165
		local frames = {} -- 166
		local monitor -- 167
		local result = {success = false, message = "previewGame did not complete"} -- 168
		local function check() -- 169
			if cancelled() then -- 169
				error("previewGame cancelled") -- 170
			end -- 170
			if not ownsEntryLease(req.operationId, entry) then -- 170
				error("The preview entry was stopped or replaced before capture completed") -- 171
			end -- 171
			if App.runningTime - start > PREVIEW_GAME_TIMEOUT_SECONDS then -- 171
				error("previewGame timed out") -- 172
			end -- 172
			if monitor ~= nil then -- 172
				local ok, message = monitor() -- 174
				if not ok then -- 174
					error(message or "Game failed during preview") -- 175
				end -- 175
			end -- 175
		end -- 169
		do -- 169
			local function ____catch(e) -- 169
				result = { -- 263
					success = false, -- 263
					files = files, -- 263
					frames = frames, -- 263
					message = tostring(e), -- 263
					visionBudget = reservation and reservation.budget -- 263
				} -- 263
			end -- 263
			local ____try, ____hasReturned = pcall(function() -- 263
				acquireEntryLease(req.operationId, entry, cancelled) -- 179
				leased = true -- 180
				reservation = reserveCapture and reserveCapture(#times) -- 181
				if reservation and not reservation.success then -- 181
					error(reservation.message or "Vision capture budget exhausted") -- 182
				end -- 182
				start = App.runningTime -- 183
				entry.allClear() -- 184
				scope = Director:beginGameCapture() -- 185
				if not scope then -- 185
					error("Game capture is unavailable or busy") -- 186
				end -- 186
				local objects = DoraObject.count -- 187
				local refs = DoraObject.luaRefCount -- 188
				recordEntryLeaseRun(req.operationId, entry) -- 189
				local previousHook, previousMask, previousCount = debug.gethook() -- 190
				do -- 190
					local ____try, ____error = pcall(function() -- 190
						debug.sethook( -- 192
							function() -- 192
								if cancelled() then -- 192
									error("previewGame cancelled during startup") -- 193
								end -- 193
								if App.elapsedTime >= Config.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 193
									error("previewGame startup exceeded the game frame time budget") -- 194
								end -- 194
								if App.runningTime - start > PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS then -- 194
									error("previewGame startup exceeded the startup time budget") -- 195
								end -- 195
								if DoraObject.count - objects > Config.AGENT_LIMITS.executeCommandMaxObjectGrowth or DoraObject.luaRefCount - refs > Config.AGENT_LIMITS.executeCommandMaxLuaRefGrowth then -- 195
									error("previewGame startup exceeded the game object budget") -- 196
								end -- 196
							end, -- 192
							"", -- 197
							Config.AGENT_LIMITS.executeCommandHookInstructionCount -- 197
						) -- 197
						local ok, message = entry.enterEntryAsync({ -- 198
							entryName = Path:getName(full), -- 199
							fileName = Path:replaceExt(full, ""), -- 200
							workDir = req.workDir, -- 201
							projectRoot = req.workDir, -- 202
							runKind = "agent_test" -- 203
						}) -- 203
						if not ok then -- 203
							error(message or "Game entry failed") -- 205
						end -- 205
					end) -- 205
					do -- 205
						if previousHook ~= nil and previousMask ~= nil and previousCount ~= nil then -- 205
							debug.sethook(previousHook, previousMask, previousCount) -- 208
						else -- 208
							debug.sethook() -- 210
						end -- 210
					end -- 210
					if not ____try then -- 210
						error(____error, 0) -- 210
					end -- 210
				end -- 210
				local transition = require("Script.Dev.RunTransition") -- 213
				local runId = entry.getCurrentEntryStatus().runId -- 217
				if runId == nil then -- 217
					error("previewGame entry has no run identity") -- 218
				end -- 218
				local ready, startupError, checkRun = transition.waitForFrameAsync( -- 219
					entry, -- 219
					runId, -- 219
					findGodotProject(req.workDir, full) ~= nil, -- 220
					function() -- 220
						check() -- 221
						if App.runningTime - start > PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS then -- 221
							error("previewGame startup exceeded the startup time budget") -- 222
						end -- 222
					end -- 220
				) -- 220
				if not ready then -- 220
					error(startupError or "Game did not produce its first frame") -- 224
				end -- 224
				monitor = checkRun -- 225
				local started = App.runningTime -- 226
				for ____, time in ipairs(times) do -- 227
					while App.runningTime - started < time do -- 227
						check() -- 229
						sleep() -- 230
					end -- 230
					check() -- 232
					local assetId = createOperationId() -- 233
					local absPath = Path(visionDir, assetId .. ".png") -- 234
					local done = false -- 235
					local saved = false -- 236
					local capturedAt = 0 -- 237
					local width = 0 -- 238
					local height = 0 -- 239
					if not Director:captureGameAsync( -- 239
						absPath, -- 240
						function(success, frameTime, sourceSize) -- 240
							saved = success -- 241
							capturedAt = frameTime -- 242
							width = sourceSize.width -- 243
							height = sourceSize.height -- 244
							done = true -- 245
						end -- 240
					) then -- 240
						error("Capture request was rejected") -- 246
					end -- 246
					while not done do -- 246
						check() -- 248
						sleep() -- 249
					end -- 249
					check() -- 251
					if not saved then -- 251
						error("Game capture could not be saved") -- 252
					end -- 252
					local relative = ((____exports.COMMAND_VISION_DIR .. "/") .. assetId) .. ".png" -- 253
					files[#files + 1] = relative -- 254
					frames[#frames + 1] = {path = relative, width = width, height = height, elapsedSeconds = capturedAt - started} -- 255
				end -- 255
				____exports.pruneVisionCaptures(visionDir) -- 257
				local cleanupError = releaseEntryLease(req.operationId, entry) -- 258
				leased = false -- 259
				if cleanupError then -- 259
					error(cleanupError) -- 260
				end -- 260
				result = {success = true, files = files, frames = frames, visionBudget = reservation and reservation.budget} -- 261
			end) -- 261
			if not ____try then -- 261
				____catch(____hasReturned) -- 261
			end -- 261
			do -- 261
				if scope then -- 261
					Director:endGameCapture() -- 265
				end -- 265
				if leased then -- 265
					local cleanupError = releaseEntryLease(req.operationId, entry) -- 267
					if cleanupError ~= nil then -- 267
						result = __TS__ObjectAssign({}, result, {success = false, files = files, frames = frames, message = result.success and cleanupError or ((result.message or "previewGame failed") .. "; ") .. cleanupError}) -- 269
					end -- 269
				end -- 269
			end -- 269
		end -- 269
		local ____opt_28 = req.registerCleanup -- 269
		if ____opt_28 ~= nil then -- 269
			____opt_28(nil) -- 274
		end -- 274
		return complete(result) -- 275
	end -- 76
end -- 67
return ____exports -- 67