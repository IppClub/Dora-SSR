-- [ts]: Fetch.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local Path = ____Dora.Path -- 2
local Director = ____Dora.Director -- 2
local once = ____Dora.once -- 2
local HttpClient = ____Dora.HttpClient -- 2
local ____Utils = require("Agent.Utils") -- 3
local Log = ____Utils.Log -- 3
local ____NetworkSafety = require("Agent.Tool.NetworkSafety") -- 4
local isHttpUrl = ____NetworkSafety.isHttpUrl -- 4
local isSafePublicHttpUrl = ____NetworkSafety.isSafePublicHttpUrl -- 4
local ____Operation = require("Agent.Tool.Operation") -- 5
local createOperationId = ____Operation.createOperationId -- 5
local getAgentDownloadTempRoot = ____Operation.getAgentDownloadTempRoot -- 5
local cleanupPath = ____Operation.cleanupPath -- 5
local ____WebIDESync = require("Agent.Tool.WebIDESync") -- 6
local syncWebIDEFile = ____WebIDESync.syncWebIDEFile -- 6
local ____Workspace = require("Agent.Tool.Workspace") -- 7
local resolveWorkspaceFilePath = ____Workspace.resolveWorkspaceFilePath -- 8
local ensureDirPath = ____Workspace.ensureDirPath -- 9
local ensureDirForFile = ____Workspace.ensureDirForFile -- 10
local DOWNLOAD_IDLE_TIMEOUT_SECONDS = 60 -- 13
local function downloadFile(req) -- 49
	return __TS__New( -- 55
		__TS__Promise, -- 55
		function(____, resolve) -- 55
			local requestId = 0 -- 56
			local settled = false -- 57
			local bytesWritten = 0 -- 58
			local lastProgressAt = App.runningTime -- 59
			local function finish(result) -- 60
				if settled then -- 60
					return -- 61
				end -- 61
				settled = true -- 62
				requestId = 0 -- 63
				resolve(nil, result) -- 64
			end -- 60
			Director.systemScheduler:schedule(function() -- 66
				if settled then -- 66
					return true -- 67
				end -- 67
				local ____this_1 -- 67
				____this_1 = req -- 68
				local ____opt_0 = ____this_1.isCancelled -- 68
				if (____opt_0 and ____opt_0(____this_1)) == true and requestId ~= 0 then -- 68
					HttpClient:cancel(requestId) -- 69
					finish({success = false, interrupted = true, message = "download canceled"}) -- 70
					return true -- 71
				end -- 71
				if requestId ~= 0 and App.runningTime - lastProgressAt >= DOWNLOAD_IDLE_TIMEOUT_SECONDS then -- 71
					HttpClient:cancel(requestId) -- 74
					finish({ -- 75
						success = false, -- 75
						interrupted = true, -- 75
						message = ("download timed out after " .. tostring(DOWNLOAD_IDLE_TIMEOUT_SECONDS)) .. " seconds without receiving data" -- 75
					}) -- 75
					return true -- 76
				end -- 76
				if requestId ~= 0 and not HttpClient:isRequestActive(requestId) then -- 76
					finish({success = false, message = "download request ended without a completion callback"}) -- 79
					return true -- 80
				end -- 80
				return false -- 82
			end) -- 66
			Director.systemScheduler:schedule(once(function() -- 84
				lastProgressAt = App.runningTime -- 85
				requestId = HttpClient:download( -- 87
					req.url, -- 87
					req.tempPath, -- 87
					0, -- 87
					function(interrupted, current, total) -- 87
						if type(current) == "number" and current > bytesWritten then -- 87
							bytesWritten = current -- 89
							lastProgressAt = App.runningTime -- 90
						end -- 90
						if interrupted then -- 90
							finish({success = false, interrupted = true, message = "download failed"}) -- 93
							return true -- 94
						end -- 94
						local ____this_3 -- 94
						____this_3 = req -- 96
						local ____opt_2 = ____this_3.isCancelled -- 96
						if (____opt_2 and ____opt_2(____this_3)) == true then -- 96
							finish({success = false, interrupted = true, message = "download canceled"}) -- 97
							return true -- 98
						end -- 98
						if current == total then -- 98
							finish({success = true, bytesWritten = bytesWritten}) -- 101
							return false -- 102
						end -- 102
						req:onProgress(current, total) -- 104
						return false -- 105
					end -- 87
				) -- 87
				if requestId == 0 then -- 87
					finish({success = false, message = "failed to schedule download request"}) -- 108
				else -- 108
					local ____this_5 -- 108
					____this_5 = req -- 109
					local ____opt_4 = ____this_5.isCancelled -- 109
					if (____opt_4 and ____opt_4(____this_5)) == true then -- 109
						HttpClient:cancel(requestId) -- 110
						finish({success = false, interrupted = true, message = "download canceled"}) -- 111
					end -- 111
				end -- 111
			end)) -- 84
		end -- 55
	) -- 55
end -- 49
function ____exports.fetchUrl(req) -- 117
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 117
		local mode = "download" -- 124
		local url = __TS__StringTrim(req.url or "") -- 125
		local targetRel = __TS__StringTrim(req.target or "") -- 126
		if not isHttpUrl(url) then -- 126
			return ____awaiter_resolve(nil, { -- 126
				success = false, -- 128
				state = "failed", -- 128
				mode = mode, -- 128
				target = targetRel, -- 128
				message = "fetch_url only supports http:// and https:// URLs" -- 128
			}) -- 128
		end -- 128
		if not isSafePublicHttpUrl(url) then -- 128
			return ____awaiter_resolve(nil, { -- 128
				success = false, -- 131
				state = "failed", -- 131
				mode = mode, -- 131
				target = targetRel, -- 131
				message = "fetch_url rejects local, private, metadata, and literal-IP destinations" -- 131
			}) -- 131
		end -- 131
		if targetRel == "" then -- 131
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 131
		end -- 131
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 136
		if not target then -- 136
			return ____awaiter_resolve(nil, { -- 136
				success = false, -- 138
				state = "failed", -- 138
				mode = mode, -- 138
				target = targetRel, -- 138
				message = "invalid target path" -- 138
			}) -- 138
		end -- 138
		if Content:exist(target) then -- 138
			return ____awaiter_resolve(nil, { -- 138
				success = false, -- 141
				state = "failed", -- 141
				mode = mode, -- 141
				target = targetRel, -- 141
				message = "target already exists" -- 141
			}) -- 141
		end -- 141
		local operationId = createOperationId() -- 143
		local tempRoot = getAgentDownloadTempRoot() -- 144
		if not ensureDirPath(tempRoot) then -- 144
			return ____awaiter_resolve(nil, { -- 144
				success = false, -- 146
				state = "failed", -- 146
				mode = mode, -- 146
				target = targetRel, -- 146
				message = "failed to create agent download temp directory" -- 146
			}) -- 146
		end -- 146
		local tempPath = Path(tempRoot, operationId .. ".download") -- 148
		Content:remove(tempPath) -- 149
		local function emitProgress(progress) -- 150
			if not req.onProgress then -- 150
				return -- 151
			end -- 151
			req:onProgress(__TS__ObjectAssign({ -- 152
				state = "running", -- 153
				mode = mode, -- 154
				operationId = operationId, -- 155
				target = targetRel, -- 156
				tempPath = tempPath -- 157
			}, progress)) -- 157
		end -- 150
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 161
		local function interrupted() -- 166
			local ____this_7 -- 166
			____this_7 = req -- 166
			local ____opt_6 = ____this_7.isCancelled -- 166
			return (____opt_6 and ____opt_6(____this_7)) == true -- 166
		end -- 166
		if not ensureDirForFile(tempPath) then -- 166
			return ____awaiter_resolve(nil, { -- 166
				success = false, -- 168
				state = "failed", -- 168
				mode = mode, -- 168
				target = targetRel, -- 168
				message = "failed to create temporary file directory" -- 168
			}) -- 168
		end -- 168
		local downloadRes = __TS__Await(downloadFile({ -- 170
			url = url, -- 171
			tempPath = tempPath, -- 172
			isCancelled = interrupted, -- 173
			onProgress = function(____, current, total) -- 174
				local totalNumber = type(total) == "number" and total or 0 -- 175
				emitProgress({ -- 176
					stage = "download", -- 177
					message = "downloading", -- 178
					current = current, -- 179
					total = total, -- 180
					progress = totalNumber > 0 and current / totalNumber or nil -- 181
				}) -- 181
			end -- 174
		})) -- 174
		if not downloadRes.success or interrupted() then -- 174
			local cleanupError = cleanupPath(tempPath) -- 186
			return ____awaiter_resolve( -- 186
				nil, -- 186
				{ -- 187
					success = false, -- 188
					state = "failed", -- 189
					mode = mode, -- 190
					target = targetRel, -- 191
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 192
					interrupted = downloadRes.interrupted or interrupted(), -- 193
					cleanupError = cleanupError -- 194
				} -- 194
			) -- 194
		end -- 194
		if not ensureDirForFile(target) then -- 194
			local cleanupError = cleanupPath(tempPath) -- 198
			return ____awaiter_resolve(nil, { -- 198
				success = false, -- 199
				state = "failed", -- 199
				mode = mode, -- 199
				target = targetRel, -- 199
				message = "failed to create target directory", -- 199
				cleanupError = cleanupError -- 199
			}) -- 199
		end -- 199
		if Content:exist(target) or not Content:move(tempPath, target) then -- 199
			local cleanupError = cleanupPath(tempPath) -- 202
			return ____awaiter_resolve(nil, { -- 202
				success = false, -- 203
				state = "failed", -- 203
				mode = mode, -- 203
				target = targetRel, -- 203
				message = "failed to move downloaded file into target path", -- 203
				cleanupError = cleanupError -- 203
			}) -- 203
		end -- 203
		local bytesWritten = downloadRes.bytesWritten -- 205
		local ____try = __TS__AsyncAwaiter(function() -- 205
			local size = Content:getAttr(target) -- 207
			if bytesWritten == nil or bytesWritten <= 0 then -- 207
				bytesWritten = type(size) == "number" and size or nil -- 209
			end -- 209
		end) -- 209
		____try = ____try.catch( -- 209
			____try, -- 209
			function(____, _) -- 209
				return __TS__AsyncAwaiter(function() -- 209
				end) -- 209
			end -- 209
		) -- 209
		__TS__Await(____try) -- 206
		if bytesWritten == nil or bytesWritten <= 0 then -- 206
			local ____try = __TS__AsyncAwaiter(function() -- 206
				local loaded = Content:load(target) -- 216
				if type(loaded) == "string" then -- 216
					bytesWritten = #loaded -- 218
				end -- 218
			end) -- 218
			____try = ____try.catch( -- 218
				____try, -- 218
				function(____, _) -- 218
					return __TS__AsyncAwaiter(function() -- 218
					end) -- 218
				end -- 218
			) -- 218
			__TS__Await(____try) -- 215
		end -- 215
		if not syncWebIDEFile(target, "fetch_url") then -- 215
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 225
		end -- 225
		return ____awaiter_resolve(nil, { -- 225
			success = true, -- 227
			state = "done", -- 227
			mode = mode, -- 227
			target = targetRel, -- 227
			bytesWritten = bytesWritten -- 227
		}) -- 227
	end) -- 227
end -- 117
return ____exports -- 117