-- [ts]: CommandPreview.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
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
local safeJsonEncode = ____Utils.safeJsonEncode -- 8
____exports.COMMAND_VISION_DIR = ".agent/vision" -- 26
local PREVIEW_ENTRY_EXTENSIONS = { -- 28
	"", -- 28
	"lua", -- 28
	"ts", -- 28
	"tsx", -- 28
	"yue", -- 28
	"tl", -- 28
	"xml" -- 28
} -- 28
--- Captures kept per project; oldest files roll out first.
____exports.COMMAND_VISION_MAX_FILES = 60 -- 31
--- Keep only the newest COMMAND_VISION_MAX_FILES capture files. Only files
-- named like <timestamp>-<random>.png (this feature's own output) are ever
-- removed; user-placed images in the same directory are untouched. Delete
-- failures are ignored: pruning must never break a capture.
function ____exports.pruneVisionCaptures(dir, keep) -- 39
	if keep == nil then -- 39
		keep = ____exports.COMMAND_VISION_MAX_FILES -- 39
	end -- 39
	if not Content:exist(dir) then -- 39
		return -- 40
	end -- 40
	local names = {} -- 41
	for ____, file in ipairs(Content:getFiles(dir)) do -- 42
		if (string.match(file, "^%d+%-%d+%.png$")) ~= nil then -- 42
			names[#names + 1] = file -- 43
		end -- 43
	end -- 43
	if #names <= keep then -- 43
		return -- 45
	end -- 45
	__TS__ArraySort( -- 47
		names, -- 47
		function(____, a, b) return a < b and 1 or (a > b and -1 or 0) end -- 47
	) -- 47
	do -- 47
		local i = keep -- 48
		while i < #names do -- 48
			Content:remove(Path(dir, names[i + 1])) -- 49
			i = i + 1 -- 48
		end -- 48
	end -- 48
end -- 39
--- The previewGame function injected into execute_command's Lua sandbox.
-- It owns the game exclusively, captures 1-3 frames at the requested
-- seconds after startup, saves them under .agent/vision in the project
-- and returns the project-relative paths. Runs synchronously on the
-- command coroutine; frame callbacks are awaited with sleep() polling.
function ____exports.createPreviewGameInjection(req, entry) -- 60
	return function(opts) -- 68
		local o = type(opts) == "table" and opts or ({}) -- 69
		local file = type(o.entry) == "string" and __TS__StringTrim(o.entry) ~= "" and __TS__StringTrim(o.entry) or "init.lua" -- 70
		local function complete(result) -- 71
			local encoded = safeJsonEncode(result) -- 72
			if encoded then -- 72
				req.print(encoded) -- 73
			end -- 73
			local ____opt_0 = req.onResult -- 73
			if ____opt_0 ~= nil then -- 73
				____opt_0(result) -- 74
			end -- 74
			return result -- 75
		end -- 71
		local requestedTimes = o.captureAtSeconds -- 77
		if requestedTimes ~= nil and not __TS__ArrayIsArray(requestedTimes) then -- 77
			return complete({success = false, message = "captureAtSeconds needs 1-3 increasing times between 0 and 10"}) -- 79
		end -- 79
		local rawTimes = requestedTimes or ({0.5}) -- 81
		local times = {} -- 82
		for ____, value in ipairs(rawTimes) do -- 83
			if type(value) ~= "number" or not __TS__NumberIsFinite(value) then -- 83
				return complete({success = false, message = "captureAtSeconds needs 1-3 increasing times between 0 and 10"}) -- 85
			end -- 85
			times[#times + 1] = value -- 87
		end -- 87
		local sourceExt = string.lower(Path:getExt(file)) -- 89
		if not isValidWorkspacePath(file) or __TS__ArrayIndexOf(PREVIEW_ENTRY_EXTENSIONS, sourceExt) < 0 then -- 89
			return complete({success = false, message = "previewGame entry must be a built project-relative Lua, TypeScript, YueScript, Teal, or XML entry"}) -- 91
		end -- 91
		if #times < 1 or #times > 3 or __TS__ArraySome( -- 91
			times, -- 93
			function(____, t, i) return t < 0 or t > 10 or i > 0 and t <= times[i] end -- 93
		) then -- 93
			return complete({success = false, message = "captureAtSeconds needs 1-3 increasing times between 0 and 10"}) -- 94
		end -- 94
		local full = Path:replaceExt( -- 96
			Path(req.workDir, file), -- 96
			"lua" -- 96
		) -- 96
		if not Content:exist(full) then -- 96
			return complete({success = false, message = "Build the entry before previewGame; generated Lua was not found at " .. full}) -- 98
		end -- 98
		if Director.beginGameCapture == nil or Director.captureGameAsync == nil or Director.endGameCapture == nil then -- 98
			return complete({success = false, message = "This engine build does not support game capture; update Dora SSR"}) -- 101
		end -- 101
		local visionDir = Path(req.workDir, ".agent", "vision") -- 103
		if not ensureDirPath(visionDir) then -- 103
			return complete({success = false, message = "failed to create the .agent/vision directory"}) -- 105
		end -- 105
		local reserveCapture = req.reserveCapture -- 109
		local reservation = reserveCapture and reserveCapture(#times) or nil -- 110
		if reservation and not reservation.success then -- 110
			return complete({success = false, message = reservation.message or "Vision capture budget exhausted", visionBudget = reservation.budget}) -- 112
		end -- 112
		local function cancelled() -- 114
			local ____opt_2 = req.isCancelled -- 114
			return (____opt_2 and ____opt_2()) == true -- 114
		end -- 114
		local start = App.runningTime -- 115
		local scope = false -- 116
		local leased = false -- 117
		local files = {} -- 118
		local frames = {} -- 119
		local result = {success = false, message = "previewGame did not complete"} -- 120
		local function check() -- 121
			if cancelled() then -- 121
				error("previewGame cancelled") -- 122
			end -- 122
			if not ownsEntryLease(req.operationId, entry) then -- 122
				error("previewGame lost ownership of the running game") -- 123
			end -- 123
			if App.runningTime - start > PREVIEW_GAME_TIMEOUT_SECONDS then -- 123
				error("previewGame timed out") -- 124
			end -- 124
		end -- 121
		do -- 121
			local function ____catch(e) -- 121
				result = { -- 195
					success = false, -- 195
					files = files, -- 195
					message = tostring(e), -- 195
					visionBudget = reservation and reservation.budget -- 195
				} -- 195
			end -- 195
			local ____try, ____hasReturned = pcall(function() -- 195
				acquireEntryLease(req.operationId, entry) -- 127
				leased = true -- 128
				entry.allClear() -- 129
				scope = Director:beginGameCapture() -- 130
				if not scope then -- 130
					error("Game capture is unavailable or busy") -- 131
				end -- 131
				local objects = DoraObject.count -- 132
				local refs = DoraObject.luaRefCount -- 133
				recordEntryLeaseRun(req.operationId, entry) -- 134
				local previousHook, previousMask, previousCount = debug.gethook() -- 135
				do -- 135
					local ____try, ____error = pcall(function() -- 135
						debug.sethook( -- 137
							function() -- 137
								if cancelled() then -- 137
									error("previewGame cancelled during startup") -- 138
								end -- 138
								if App.elapsedTime >= Config.AGENT_LIMITS.executeCommandFrameTimeoutSeconds then -- 138
									error("previewGame startup exceeded the game frame time budget") -- 139
								end -- 139
								if App.runningTime - start > PREVIEW_GAME_STARTUP_TIMEOUT_SECONDS then -- 139
									error("previewGame startup exceeded the startup time budget") -- 140
								end -- 140
								if DoraObject.count - objects > Config.AGENT_LIMITS.executeCommandMaxObjectGrowth or DoraObject.luaRefCount - refs > Config.AGENT_LIMITS.executeCommandMaxLuaRefGrowth then -- 140
									error("previewGame startup exceeded the game object budget") -- 141
								end -- 141
							end, -- 137
							"", -- 142
							Config.AGENT_LIMITS.executeCommandHookInstructionCount -- 142
						) -- 142
						local ok, message = entry.enterEntryAsync({ -- 143
							entryName = Path:getName(full), -- 144
							fileName = Path:replaceExt(full, ""), -- 145
							workDir = req.workDir, -- 146
							projectRoot = req.workDir, -- 147
							runKind = "agent_test" -- 148
						}) -- 148
						if not ok then -- 148
							error(message or "Game entry failed") -- 150
						end -- 150
					end) -- 150
					do -- 150
						if previousHook ~= nil and previousMask ~= nil and previousCount ~= nil then -- 150
							debug.sethook(previousHook, previousMask, previousCount) -- 153
						else -- 153
							debug.sethook() -- 155
						end -- 155
					end -- 155
					if not ____try then -- 155
						error(____error, 0) -- 155
					end -- 155
				end -- 155
				local started = App.runningTime -- 158
				for ____, time in ipairs(times) do -- 159
					while App.runningTime - started < time do -- 159
						check() -- 161
						sleep() -- 162
					end -- 162
					check() -- 164
					local assetId = createOperationId() -- 165
					local absPath = Path(visionDir, assetId .. ".png") -- 166
					local done = false -- 167
					local saved = false -- 168
					local capturedAt = 0 -- 169
					local width = 0 -- 170
					local height = 0 -- 171
					if not Director:captureGameAsync( -- 171
						absPath, -- 172
						function(success, frameTime, sourceSize) -- 172
							saved = success -- 173
							capturedAt = frameTime -- 174
							width = sourceSize.width -- 175
							height = sourceSize.height -- 176
							done = true -- 177
						end -- 172
					) then -- 172
						error("Capture request was rejected") -- 178
					end -- 178
					while not done do -- 178
						check() -- 180
						sleep() -- 181
					end -- 181
					check() -- 183
					if not saved then -- 183
						error("Game capture could not be saved") -- 184
					end -- 184
					local relative = ((____exports.COMMAND_VISION_DIR .. "/") .. assetId) .. ".png" -- 185
					files[#files + 1] = relative -- 186
					frames[#frames + 1] = {path = relative, width = width, height = height, elapsedSeconds = capturedAt - started} -- 187
				end -- 187
				____exports.pruneVisionCaptures(visionDir) -- 189
				local cleanupError = releaseEntryLease(req.operationId, entry) -- 190
				leased = false -- 191
				if cleanupError then -- 191
					error(cleanupError) -- 192
				end -- 192
				result = {success = true, files = files, frames = frames, visionBudget = reservation and reservation.budget} -- 193
			end) -- 193
			if not ____try then -- 193
				____catch(____hasReturned) -- 193
			end -- 193
			do -- 193
				if scope then -- 193
					Director:endGameCapture() -- 197
				end -- 197
				if leased then -- 197
					local cleanupError = releaseEntryLease(req.operationId, entry) -- 199
					if cleanupError ~= nil then -- 199
						result = result.success and ({success = false, files = files, message = cleanupError}) or ({success = false, files = files, message = ((result.message or "previewGame failed") .. "; ") .. cleanupError}) -- 201
					end -- 201
				end -- 201
			end -- 201
		end -- 201
		return complete(result) -- 207
	end -- 68
end -- 60
return ____exports -- 60