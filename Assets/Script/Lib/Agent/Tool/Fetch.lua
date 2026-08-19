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
local function downloadFile(req) -- 47
	return __TS__New( -- 54
		__TS__Promise, -- 54
		function(____, resolve) -- 54
			local requestId = 0 -- 55
			local settled = false -- 56
			local bytesWritten = 0 -- 57
			local function finish(result) -- 58
				if settled then -- 58
					return -- 59
				end -- 59
				settled = true -- 60
				requestId = 0 -- 61
				resolve(nil, result) -- 62
			end -- 58
			Director.systemScheduler:schedule(function() -- 64
				if settled then -- 64
					return true -- 65
				end -- 65
				local ____this_1 -- 65
				____this_1 = req -- 66
				local ____opt_0 = ____this_1.isCancelled -- 66
				if (____opt_0 and ____opt_0(____this_1)) == true and requestId ~= 0 then -- 66
					HttpClient:cancel(requestId) -- 67
					finish({success = false, interrupted = true, message = "download canceled"}) -- 68
					return true -- 69
				end -- 69
				if requestId ~= 0 and not HttpClient:isRequestActive(requestId) then -- 69
					finish({success = false, message = "download request ended without a completion callback"}) -- 72
					return true -- 73
				end -- 73
				return false -- 75
			end) -- 64
			Director.systemScheduler:schedule(once(function() -- 77
				requestId = HttpClient:download( -- 78
					req.url, -- 78
					req.tempPath, -- 78
					req.timeout, -- 78
					function(interrupted, current, total) -- 78
						if type(current) == "number" and current > bytesWritten then -- 78
							bytesWritten = current -- 80
						end -- 80
						if interrupted then -- 80
							finish({success = false, interrupted = true, message = "download failed"}) -- 83
							return true -- 84
						end -- 84
						local ____this_3 -- 84
						____this_3 = req -- 86
						local ____opt_2 = ____this_3.isCancelled -- 86
						if (____opt_2 and ____opt_2(____this_3)) == true then -- 86
							finish({success = false, interrupted = true, message = "download canceled"}) -- 87
							return true -- 88
						end -- 88
						if current == total then -- 88
							finish({success = true, bytesWritten = bytesWritten}) -- 91
							return false -- 92
						end -- 92
						req:onProgress(current, total) -- 94
						return false -- 95
					end -- 78
				) -- 78
				if requestId == 0 then -- 78
					finish({success = false, message = "failed to schedule download request"}) -- 98
				else -- 98
					local ____this_5 -- 98
					____this_5 = req -- 99
					local ____opt_4 = ____this_5.isCancelled -- 99
					if (____opt_4 and ____opt_4(____this_5)) == true then -- 99
						HttpClient:cancel(requestId) -- 100
						finish({success = false, interrupted = true, message = "download canceled"}) -- 101
					end -- 101
				end -- 101
			end)) -- 77
		end -- 54
	) -- 54
end -- 47
function ____exports.fetchUrl(req) -- 107
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 107
		local mode = "download" -- 114
		local url = __TS__StringTrim(req.url or "") -- 115
		local targetRel = __TS__StringTrim(req.target or "") -- 116
		if not isHttpUrl(url) then -- 116
			return ____awaiter_resolve(nil, { -- 116
				success = false, -- 118
				state = "failed", -- 118
				mode = mode, -- 118
				target = targetRel, -- 118
				message = "fetch_url only supports http:// and https:// URLs" -- 118
			}) -- 118
		end -- 118
		if not isSafePublicHttpUrl(url) then -- 118
			return ____awaiter_resolve(nil, { -- 118
				success = false, -- 121
				state = "failed", -- 121
				mode = mode, -- 121
				target = targetRel, -- 121
				message = "fetch_url rejects local, private, metadata, and literal-IP destinations" -- 121
			}) -- 121
		end -- 121
		if targetRel == "" then -- 121
			return ____awaiter_resolve(nil, {success = false, state = "failed", mode = mode, message = "missing target"}) -- 121
		end -- 121
		local target = resolveWorkspaceFilePath(req.workDir, targetRel) -- 126
		if not target then -- 126
			return ____awaiter_resolve(nil, { -- 126
				success = false, -- 128
				state = "failed", -- 128
				mode = mode, -- 128
				target = targetRel, -- 128
				message = "invalid target path" -- 128
			}) -- 128
		end -- 128
		if Content:exist(target) then -- 128
			return ____awaiter_resolve(nil, { -- 128
				success = false, -- 131
				state = "failed", -- 131
				mode = mode, -- 131
				target = targetRel, -- 131
				message = "target already exists" -- 131
			}) -- 131
		end -- 131
		local operationId = createOperationId() -- 133
		local tempRoot = getAgentDownloadTempRoot() -- 134
		if not ensureDirPath(tempRoot) then -- 134
			return ____awaiter_resolve(nil, { -- 134
				success = false, -- 136
				state = "failed", -- 136
				mode = mode, -- 136
				target = targetRel, -- 136
				message = "failed to create agent download temp directory" -- 136
			}) -- 136
		end -- 136
		local tempPath = Path(tempRoot, operationId .. ".download") -- 138
		Content:remove(tempPath) -- 139
		local function emitProgress(progress) -- 140
			if not req.onProgress then -- 140
				return -- 141
			end -- 141
			req:onProgress(__TS__ObjectAssign({ -- 142
				state = "running", -- 143
				mode = mode, -- 144
				operationId = operationId, -- 145
				target = targetRel, -- 146
				tempPath = tempPath -- 147
			}, progress)) -- 147
		end -- 140
		emitProgress({state = "pending", message = "download pending", stage = "download"}) -- 151
		local function interrupted() -- 156
			local ____this_7 -- 156
			____this_7 = req -- 156
			local ____opt_6 = ____this_7.isCancelled -- 156
			return (____opt_6 and ____opt_6(____this_7)) == true -- 156
		end -- 156
		if not ensureDirForFile(tempPath) then -- 156
			return ____awaiter_resolve(nil, { -- 156
				success = false, -- 158
				state = "failed", -- 158
				mode = mode, -- 158
				target = targetRel, -- 158
				message = "failed to create temporary file directory" -- 158
			}) -- 158
		end -- 158
		local downloadRes = __TS__Await(downloadFile({ -- 160
			url = url, -- 161
			tempPath = tempPath, -- 162
			timeout = 600, -- 163
			isCancelled = interrupted, -- 164
			onProgress = function(____, current, total) -- 165
				local totalNumber = type(total) == "number" and total or 0 -- 166
				emitProgress({ -- 167
					stage = "download", -- 168
					message = "downloading", -- 169
					current = current, -- 170
					total = total, -- 171
					progress = totalNumber > 0 and current / totalNumber or nil -- 172
				}) -- 172
			end -- 165
		})) -- 165
		if not downloadRes.success then -- 165
			local cleanupError = cleanupPath(tempPath) -- 177
			return ____awaiter_resolve( -- 177
				nil, -- 177
				{ -- 178
					success = false, -- 179
					state = "failed", -- 180
					mode = mode, -- 181
					target = targetRel, -- 182
					message = interrupted() and "download canceled" or (downloadRes.message or "download failed"), -- 183
					interrupted = downloadRes.interrupted or interrupted(), -- 184
					cleanupError = cleanupError -- 185
				} -- 185
			) -- 185
		end -- 185
		if not ensureDirForFile(target) then -- 185
			local cleanupError = cleanupPath(tempPath) -- 189
			return ____awaiter_resolve(nil, { -- 189
				success = false, -- 190
				state = "failed", -- 190
				mode = mode, -- 190
				target = targetRel, -- 190
				message = "failed to create target directory", -- 190
				cleanupError = cleanupError -- 190
			}) -- 190
		end -- 190
		if not Content:move(tempPath, target) then -- 190
			local cleanupError = cleanupPath(tempPath) -- 193
			return ____awaiter_resolve(nil, { -- 193
				success = false, -- 194
				state = "failed", -- 194
				mode = mode, -- 194
				target = targetRel, -- 194
				message = "failed to move downloaded file into target path", -- 194
				cleanupError = cleanupError -- 194
			}) -- 194
		end -- 194
		local bytesWritten = downloadRes.bytesWritten -- 196
		local ____try = __TS__AsyncAwaiter(function() -- 196
			local size = Content:getAttr(target) -- 198
			if bytesWritten == nil or bytesWritten <= 0 then -- 198
				bytesWritten = type(size) == "number" and size or nil -- 200
			end -- 200
		end) -- 200
		____try = ____try.catch( -- 200
			____try, -- 200
			function(____, _) -- 200
				return __TS__AsyncAwaiter(function() -- 200
				end) -- 200
			end -- 200
		) -- 200
		__TS__Await(____try) -- 197
		if bytesWritten == nil or bytesWritten <= 0 then -- 197
			local ____try = __TS__AsyncAwaiter(function() -- 197
				local loaded = Content:load(target) -- 207
				if type(loaded) == "string" then -- 207
					bytesWritten = #loaded -- 209
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
		end -- 206
		if not syncWebIDEFile(target, "fetch_url") then -- 206
			Log("Warn", "[fetch_url] failed to sync downloaded file update target=" .. target) -- 216
		end -- 216
		return ____awaiter_resolve(nil, { -- 216
			success = true, -- 218
			state = "done", -- 218
			mode = mode, -- 218
			target = targetRel, -- 218
			bytesWritten = bytesWritten -- 218
		}) -- 218
	end) -- 218
end -- 107
return ____exports -- 107