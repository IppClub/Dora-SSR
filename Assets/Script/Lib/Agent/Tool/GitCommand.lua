-- [ts]: GitCommand.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringCharAt = ____lualib.__TS__StringCharAt -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Path = ____Dora.Path -- 2
local Director = ____Dora.Director -- 2
local Git = ____Dora.Git -- 2
local ____Utils = require("Agent.Utils") -- 3
local Log = ____Utils.Log -- 3
local safeJsonEncode = ____Utils.safeJsonEncode -- 3
local ____CommandShared = require("Agent.Tool.CommandShared") -- 5
local toStr = ____CommandShared.toCommandString -- 5
local truncateCommandOutput = ____CommandShared.truncateCommandOutput -- 5
local ____NetworkSafety = require("Agent.Tool.NetworkSafety") -- 6
local isHttpUrl = ____NetworkSafety.isHttpUrl -- 6
local isSafePublicHttpUrl = ____NetworkSafety.isSafePublicHttpUrl -- 6
local ____Operation = require("Agent.Tool.Operation") -- 7
local getAgentDownloadTempRoot = ____Operation.getAgentDownloadTempRoot -- 7
local cleanupPath = ____Operation.cleanupPath -- 7
local ____WebIDESync = require("Agent.Tool.WebIDESync") -- 8
local refreshWorkspaceTree = ____WebIDESync.refreshWorkspaceTree -- 8
local ____Workspace = require("Agent.Tool.Workspace") -- 9
local resolveWorkspaceFilePath = ____Workspace.resolveWorkspaceFilePath -- 10
local resolveWorkspaceDirectoryPath = ____Workspace.resolveWorkspaceDirectoryPath -- 11
local ensureDirPath = ____Workspace.ensureDirPath -- 12
local function quoteGitArg(value) -- 15
	local plain = string.match(value, "^[%w%._%-%/]+$") -- 16
	if plain ~= nil then -- 16
		return value -- 18
	end -- 18
	local escaped = string.gsub(value, "\\", "\\\\") -- 20
	escaped = string.gsub(escaped, "\"", "\\\"") -- 21
	return ("\"" .. escaped) .. "\"" -- 22
end -- 15
local function shellSplit(command) -- 25
	local args = {} -- 26
	local current = "" -- 27
	local quote = "" -- 28
	local escaped = false -- 29
	do -- 29
		local i = 0 -- 30
		while i < #command do -- 30
			do -- 30
				local ch = __TS__StringCharAt(command, i) -- 31
				if escaped then -- 31
					current = current .. ch -- 33
					escaped = false -- 34
					goto __continue6 -- 35
				end -- 35
				if ch == "\\" then -- 35
					escaped = true -- 38
					goto __continue6 -- 39
				end -- 39
				if quote ~= "" then -- 39
					if ch == quote then -- 39
						quote = "" -- 43
					else -- 43
						current = current .. ch -- 45
					end -- 45
					goto __continue6 -- 47
				end -- 47
				if ch == "'" or ch == "\"" then -- 47
					quote = ch -- 50
					goto __continue6 -- 51
				end -- 51
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 51
					if current ~= "" then -- 51
						args[#args + 1] = current -- 55
						current = "" -- 56
					end -- 56
					goto __continue6 -- 58
				end -- 58
				current = current .. ch -- 60
			end -- 60
			::__continue6:: -- 60
			i = i + 1 -- 30
		end -- 30
	end -- 30
	if escaped then -- 30
		current = current .. "\\" -- 63
	end -- 63
	if current ~= "" then -- 63
		args[#args + 1] = current -- 66
	end -- 66
	return args -- 68
end -- 25
local function normalizeGitCommand(command) -- 71
	local trimmed = __TS__StringTrim(command) -- 72
	return string.lower(string.sub(trimmed, 1, 4)) == "git " and __TS__StringTrim(string.sub(trimmed, 5)) or trimmed -- 73
end -- 71
local function gitDefaultTargetFromUrl(url) -- 78
	local target = url -- 79
	local hashIndex = (string.find(target, "#", nil, true) or 0) - 1 -- 80
	if hashIndex >= 0 then -- 80
		target = __TS__StringSlice(target, 0, hashIndex) -- 81
	end -- 81
	local queryIndex = (string.find(target, "?", nil, true) or 0) - 1 -- 82
	if queryIndex >= 0 then -- 82
		target = __TS__StringSlice(target, 0, queryIndex) -- 83
	end -- 83
	target = string.gsub(target, "/+$", "") -- 84
	local name = string.match(target, "([^/]+)$") -- 85
	if name ~= nil and name ~= "" then -- 85
		target = name -- 86
	end -- 86
	if __TS__StringEndsWith( -- 86
		string.lower(target), -- 87
		".git" -- 87
	) then -- 87
		target = __TS__StringSlice(target, 0, #target - 4) -- 88
	end -- 88
	return target ~= "" and target or "repo" -- 90
end -- 78
local function parseGitCloneCommand(command) -- 93
	local args = shellSplit(normalizeGitCommand(command)) -- 103
	if #args == 0 or args[1] ~= "clone" then -- 103
		return nil -- 104
	end -- 104
	local url = "" -- 105
	local target = "" -- 106
	local ref -- 107
	local depth -- 108
	do -- 108
		local i = 1 -- 109
		while i < #args do -- 109
			do -- 109
				local arg = args[i + 1] -- 110
				if arg == "-b" or arg == "--branch" then
					i = i + 1 -- 112
					if i >= #args then -- 112
						return {success = false, message = arg .. " requires a value"} -- 113
					end -- 113
					ref = args[i + 1] -- 114
					goto __continue26 -- 115
				end -- 115
				if arg == "--depth" then
					i = i + 1 -- 118
					if i >= #args then -- 118
						return {success = false, message = "--depth requires a value"}
					end -- 119
					depth = args[i + 1] -- 120
					goto __continue26 -- 121
				end -- 121
				if __TS__StringStartsWith(arg, "--depth=") then
					depth = __TS__StringSlice(arg, #"--depth=")
					goto __continue26 -- 125
				end -- 125
				if __TS__StringStartsWith(arg, "-") then -- 125
					return {success = false, message = "unsupported clone option: " .. arg} -- 128
				end -- 128
				if url == "" then -- 128
					url = arg -- 131
					goto __continue26 -- 132
				end -- 132
				if target == "" then -- 132
					target = arg -- 135
					goto __continue26 -- 136
				end -- 136
				return {success = false, message = "unexpected clone argument: " .. arg} -- 138
			end -- 138
			::__continue26:: -- 138
			i = i + 1 -- 109
		end -- 109
	end -- 109
	if url == "" then -- 109
		return {success = false, message = "git clone requires a URL"} -- 140
	end -- 140
	if not isHttpUrl(url) then -- 140
		return {success = false, message = "git clone only supports http:// and https:// URLs"} -- 141
	end -- 141
	if not isSafePublicHttpUrl(url) then -- 141
		return {success = false, message = "git clone rejects local, private, metadata, and literal-IP destinations"} -- 142
	end -- 142
	if target == "" then -- 142
		target = gitDefaultTargetFromUrl(url) -- 143
	end -- 143
	return { -- 144
		success = true, -- 145
		url = url, -- 146
		target = target, -- 147
		ref = ref, -- 148
		depth = depth ~= nil and depth ~= "" and depth or "1" -- 149
	} -- 149
end -- 93
local function getGitHeadCommit(repoPath) -- 153
	local headPath = Path(repoPath, ".git", "HEAD") -- 154
	if not Content:exist(headPath) then -- 154
		return nil -- 155
	end -- 155
	local head = __TS__StringTrim(toStr(Content:load(headPath))) -- 156
	local ref = string.match(head, "^ref:%s*(.-)%s*$") -- 157
	if ref ~= nil and ref ~= "" then -- 157
		local refPath = Path(repoPath, ".git", ref) -- 159
		if Content:exist(refPath) then -- 159
			local commit = __TS__StringTrim(toStr(Content:load(refPath))) -- 161
			return commit ~= "" and commit or nil -- 162
		end -- 162
		return nil -- 164
	end -- 164
	return head ~= "" and head or nil -- 166
end -- 153
local function runGitAndWait(repoPath, command, onStatus, isCancelled, timeout) -- 169
	if timeout == nil then -- 169
		timeout = 600 -- 174
	end -- 174
	return __TS__New( -- 176
		__TS__Promise, -- 176
		function(____, resolve) -- 176
			local status -- 177
			local jobId = 0 -- 178
			local settled = false -- 179
			local canceled = false -- 180
			local function finish(result) -- 181
				if settled then -- 181
					return -- 182
				end -- 182
				settled = true -- 183
				resolve(nil, result) -- 184
			end -- 181
			local function finishFromStatus() -- 186
				local state = toStr(status and status.state) -- 187
				if state == "done" then -- 187
					finish({success = true, status = status}) -- 189
					return true -- 190
				end -- 190
				if state == "error" or state == "canceled" then -- 190
					local errorMessage = toStr(status and status.error) -- 193
					local statusMessage = toStr(status and status.message) -- 194
					finish({success = false, message = errorMessage ~= "" and errorMessage or (statusMessage ~= "" and statusMessage or (state == "canceled" and "git command canceled" or "git command failed")), status = status, interrupted = state == "canceled"}) -- 195
					return true -- 201
				end -- 201
				return false -- 203
			end -- 186
			jobId = Git:run( -- 205
				repoPath, -- 205
				command, -- 205
				function(nextStatus) -- 205
					status = nextStatus -- 206
					if onStatus then -- 206
						onStatus(status) -- 207
					end -- 207
					return finishFromStatus() -- 208
				end, -- 205
				"" -- 209
			) -- 209
			if jobId == nil or jobId <= 0 then -- 209
				finish({success = false, message = "failed to start git command"}) -- 211
				return -- 212
			end -- 212
			if not status then -- 212
				local kind = string.match(command, "^(%S+)") -- 215
				status = { -- 216
					id = jobId, -- 217
					state = "queued", -- 218
					kind = toStr(kind), -- 219
					repoPath = repoPath, -- 220
					progress = 0, -- 221
					message = "queued" -- 222
				} -- 222
			end -- 222
			if onStatus then -- 222
				onStatus(status) -- 225
			end -- 225
			local startedAt = os.time() -- 226
			local lastEmitAt = startedAt -- 227
			Director.systemScheduler:schedule(function() -- 228
				if settled then -- 228
					return true -- 229
				end -- 229
				if not canceled and isCancelled and isCancelled() then -- 229
					canceled = true -- 231
					Git:cancel(jobId) -- 232
					finish({success = false, message = "git command canceled", status = status, interrupted = true}) -- 233
					return true -- 234
				end -- 234
				if finishFromStatus() then -- 234
					return true -- 236
				end -- 236
				local nowTime = os.time() -- 237
				if nowTime - startedAt >= timeout then -- 237
					Git:cancel(jobId) -- 239
					finish({success = false, message = "git command timed out", status = status}) -- 240
					return true -- 241
				end -- 241
				if onStatus and status and nowTime > lastEmitAt then -- 241
					lastEmitAt = nowTime -- 244
					onStatus(status) -- 245
				end -- 245
				return false -- 247
			end) -- 228
		end -- 176
	) -- 176
end -- 169
local function encodeJSON(obj) -- 252
	local text = safeJsonEncode(obj) -- 253
	return text -- 254
end -- 252
local function formatGitStatusOutput(status) -- 257
	if not status then -- 257
		return "" -- 258
	end -- 258
	local lines = {} -- 259
	local state = toStr(status.state) -- 260
	local kind = toStr(status.kind) -- 261
	local message = toStr(status.message) -- 262
	local errorMessage = toStr(status.error) -- 263
	if kind ~= "" or state ~= "" then -- 263
		lines[#lines + 1] = table.concat( -- 265
			__TS__ArrayFilter( -- 265
				{kind, state}, -- 265
				function(____, item) return item ~= "" end -- 265
			), -- 265
			": " -- 265
		) -- 265
	end -- 265
	if message ~= "" then -- 265
		lines[#lines + 1] = message -- 267
	end -- 267
	if errorMessage ~= "" then -- 267
		lines[#lines + 1] = errorMessage -- 268
	end -- 268
	local data = status.data -- 269
	if data ~= nil then -- 269
		local dataText = encodeJSON(data) -- 271
		lines[#lines + 1] = dataText ~= nil and dataText or tostring(data) -- 272
	end -- 272
	return truncateCommandOutput(table.concat(lines, "\n")) -- 274
end -- 257
local function emitGitProgress(mode, operationId, onProgress, status) -- 277
	if not onProgress then -- 277
		return -- 283
	end -- 283
	local progress = type(status.progress) == "number" and status.progress or nil -- 284
	local kind = toStr(status.kind) -- 285
	local message = toStr(status.message) -- 286
	local state = toStr(status.state) -- 287
	local jobId = type(status.id) == "number" and status.id or nil -- 288
	onProgress({ -- 289
		state = "running", -- 290
		mode = mode, -- 291
		operationId = operationId, -- 292
		stage = kind ~= "" and kind or "git", -- 293
		message = message ~= "" and message or (state ~= "" and state or "running"), -- 294
		progress = progress, -- 295
		jobId = jobId, -- 296
		gitState = state ~= "" and state or nil, -- 297
		gitKind = kind ~= "" and kind or nil -- 298
	}) -- 298
end -- 277
local function cloneGitToTarget(req) -- 302
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 302
		local parsed = parseGitCloneCommand(req.command) -- 310
		if parsed == nil then -- 310
			return ____awaiter_resolve(nil, nil) -- 310
		end -- 310
		if not parsed.success then -- 310
			return ____awaiter_resolve(nil, { -- 310
				success = false, -- 313
				mode = "git", -- 313
				output = "", -- 313
				message = parsed.message, -- 313
				phase = "validate" -- 313
			}) -- 313
		end -- 313
		local target = resolveWorkspaceFilePath(req.workDir, parsed.target) -- 315
		if not target then -- 315
			return ____awaiter_resolve(nil, { -- 315
				success = false, -- 317
				mode = "git", -- 317
				output = "", -- 317
				message = "invalid clone target path", -- 317
				phase = "validate" -- 317
			}) -- 317
		end -- 317
		if Content:exist(target) then -- 317
			return ____awaiter_resolve(nil, { -- 317
				success = false, -- 320
				mode = "git", -- 320
				output = "", -- 320
				message = "target already exists", -- 320
				phase = "validate" -- 320
			}) -- 320
		end -- 320
		local targetParent = Path:getPath(target) -- 322
		if not ensureDirPath(targetParent) then -- 322
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create target parent directory"}) -- 322
		end -- 322
		local tempRoot = getAgentDownloadTempRoot() -- 326
		if not ensureDirPath(tempRoot) then -- 326
			return ____awaiter_resolve(nil, {success = false, mode = "git", output = "", message = "failed to create agent download temp directory"}) -- 326
		end -- 326
		local tempPath = Path(tempRoot, req.operationId .. ".repo") -- 330
		Content:remove(tempPath) -- 331
		local depth = parsed.depth or "1" -- 332
		local ____array_6 = __TS__SparseArrayNew( -- 332
			"clone", -- 334
			quoteGitArg(parsed.url), -- 335
			quoteGitArg(Path:getFilename(tempPath)), -- 336
			table.unpack(parsed.ref ~= nil and parsed.ref ~= "" and ({ -- 337
				"-b", -- 337
				quoteGitArg(parsed.ref) -- 337
			}) or ({})) -- 337
		) -- 337
		__TS__SparseArrayPush( -- 337
			____array_6, -- 337
			table.unpack(depth ~= "" and ({ -- 338
				"--depth",
				quoteGitArg(depth) -- 338
			}) or ({})) -- 338
		) -- 338
		local command = table.concat( -- 333
			{__TS__SparseArraySpread(____array_6)}, -- 333
			" " -- 339
		) -- 339
		local ____this_8 -- 339
		____this_8 = req -- 340
		local ____opt_7 = ____this_8.onProgress -- 340
		if ____opt_7 ~= nil then -- 340
			____opt_7(____this_8, { -- 340
				state = "pending", -- 341
				mode = "git", -- 342
				operationId = req.operationId, -- 343
				stage = "clone", -- 344
				message = "clone pending", -- 345
				progress = 0 -- 346
			}) -- 346
		end -- 346
		local gitRes = __TS__Await(runGitAndWait( -- 348
			tempRoot, -- 349
			command, -- 350
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 351
			req.isCancelled, -- 352
			req.timeoutSeconds -- 353
		)) -- 353
		if not gitRes.success then -- 353
			local cleanupError = cleanupPath(tempPath) -- 356
			local ____formatGitStatusOutput_result_12 = formatGitStatusOutput(gitRes.status) -- 360
			local ____temp_13 = gitRes.message or "git clone failed" -- 361
			local ____gitRes_interrupted_11 = gitRes.interrupted -- 362
			if not ____gitRes_interrupted_11 then -- 362
				local ____this_10 -- 362
				____this_10 = req -- 362
				local ____opt_9 = ____this_10.isCancelled -- 362
				____gitRes_interrupted_11 = (____opt_9 and ____opt_9(____this_10)) == true -- 362
			end -- 362
			return ____awaiter_resolve(nil, { -- 362
				success = false, -- 358
				mode = "git", -- 359
				output = ____formatGitStatusOutput_result_12, -- 360
				message = ____temp_13, -- 361
				interrupted = ____gitRes_interrupted_11, -- 362
				cleanupError = cleanupError -- 363
			}) -- 363
		end -- 363
		if not Content:move(tempPath, target) then -- 363
			local cleanupError = cleanupPath(tempPath) -- 367
			return ____awaiter_resolve( -- 367
				nil, -- 367
				{ -- 368
					success = false, -- 368
					mode = "git", -- 368
					output = formatGitStatusOutput(gitRes.status), -- 368
					message = "failed to move cloned repository into target path", -- 368
					cleanupError = cleanupError -- 368
				} -- 368
			) -- 368
		end -- 368
		if not refreshWorkspaceTree(req.workDir) then -- 368
			Log("Warn", "[execute_command] failed to refresh Web IDE tree after clone target=" .. target) -- 371
		end -- 371
		local commit = getGitHeadCommit(target) -- 373
		local output = table.concat( -- 374
			__TS__ArrayFilter( -- 374
				{ -- 374
					formatGitStatusOutput(gitRes.status), -- 375
					(("cloned " .. parsed.url) .. " to ") .. parsed.target, -- 375
					commit ~= nil and "commit " .. commit or "" -- 377
				}, -- 377
				function(____, item) return item ~= "" end -- 378
			), -- 378
			"\n" -- 378
		) -- 378
		return ____awaiter_resolve( -- 378
			nil, -- 378
			{ -- 379
				success = true, -- 379
				mode = "git", -- 379
				output = truncateCommandOutput(output) -- 379
			} -- 379
		) -- 379
	end) -- 379
end -- 302
local function loadGitProfile() -- 382
	local rows -- 383
	do -- 383
		local function ____catch() -- 383
			return true, nil -- 387
		end -- 387
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 387
			rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 385
		end) -- 385
		if not ____try then -- 385
			____hasReturned, ____returnValue = ____catch() -- 385
		end -- 385
		if ____hasReturned then -- 385
			return ____returnValue -- 384
		end -- 384
	end -- 384
	if not rows or not rows[1] then -- 384
		return nil -- 389
	end -- 389
	local name = toStr(rows[1][1]) -- 390
	local email = toStr(rows[1][2]) -- 391
	if name == "" and email == "" then -- 391
		return nil -- 392
	end -- 392
	return {name = name, email = email} -- 393
end -- 382
local function applyGitProfileToCommit(command) -- 396
	local args = shellSplit(command) -- 397
	if args[1] ~= "commit" then -- 397
		return command -- 398
	end -- 398
	local hasName = false -- 399
	local hasEmail = false -- 400
	for ____, arg in ipairs(args) do -- 401
		if arg == "--author-name" then
			hasName = true -- 402
		end -- 402
		if arg == "--author-email" then
			hasEmail = true -- 403
		end -- 403
	end -- 403
	if hasName and hasEmail then -- 403
		return command -- 405
	end -- 405
	local profile = loadGitProfile() -- 406
	if not profile then -- 406
		return command -- 407
	end -- 407
	local additions = {} -- 408
	if not hasName and profile.name ~= "" then -- 408
		__TS__ArrayPush( -- 410
			additions, -- 410
			"--author-name",
			quoteGitArg(profile.name) -- 410
		) -- 410
	end -- 410
	if not hasEmail and profile.email ~= "" then -- 410
		__TS__ArrayPush( -- 413
			additions, -- 413
			"--author-email",
			quoteGitArg(profile.email) -- 413
		) -- 413
	end -- 413
	if #additions == 0 then -- 413
		return command -- 415
	end -- 415
	return (command .. " ") .. table.concat(additions, " ") -- 416
end -- 396
function ____exports.executeGitCommand(req) -- 419
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 419
		local command = normalizeGitCommand(req.command or "") -- 428
		if command == "" then -- 428
			return ____awaiter_resolve(nil, { -- 428
				success = false, -- 430
				mode = "git", -- 430
				output = "", -- 430
				message = "missing command", -- 430
				phase = "validate" -- 430
			}) -- 430
		end -- 430
		local commandArgs = shellSplit(command) -- 432
		if #commandArgs == 0 or __TS__StringStartsWith(commandArgs[1], "-") then -- 432
			return ____awaiter_resolve(nil, { -- 432
				success = false, -- 435
				mode = "git", -- 436
				output = "", -- 437
				message = "top-level Git options such as -C, --git-dir, and --work-tree are not supported; use the project-relative cwd parameter",
				phase = "validate" -- 439
			}) -- 439
		end -- 439
		local cloneResult = __TS__Await(cloneGitToTarget({ -- 442
			workDir = req.workDir, -- 443
			command = command, -- 444
			operationId = req.operationId, -- 445
			timeoutSeconds = req.timeoutSeconds, -- 446
			onProgress = req.onProgress, -- 447
			isCancelled = req.isCancelled -- 448
		})) -- 448
		if cloneResult ~= nil then -- 448
			return ____awaiter_resolve(nil, cloneResult) -- 448
		end -- 448
		local cwd = resolveWorkspaceDirectoryPath(req.workDir, req.cwd) -- 451
		if not cwd.success then -- 451
			return ____awaiter_resolve(nil, { -- 451
				success = false, -- 453
				mode = "git", -- 453
				output = "", -- 453
				cwd = req.cwd, -- 453
				message = cwd.message, -- 453
				phase = "validate" -- 453
			}) -- 453
		end -- 453
		command = applyGitProfileToCommit(command) -- 455
		local ____this_15 -- 455
		____this_15 = req -- 456
		local ____opt_14 = ____this_15.onProgress -- 456
		if ____opt_14 ~= nil then -- 456
			____opt_14(____this_15, { -- 456
				state = "pending", -- 457
				mode = "git", -- 458
				operationId = req.operationId, -- 459
				stage = "git", -- 460
				message = "git command pending", -- 461
				progress = 0 -- 462
			}) -- 462
		end -- 462
		local gitRes = __TS__Await(runGitAndWait( -- 464
			cwd.path, -- 465
			command, -- 466
			function(status) return emitGitProgress("git", req.operationId, req.onProgress, status) end, -- 467
			function() -- 468
				local ____this_17 -- 468
				____this_17 = req -- 468
				local ____opt_16 = ____this_17.isCancelled -- 468
				return (____opt_16 and ____opt_16(____this_17)) == true -- 468
			end, -- 468
			req.timeoutSeconds -- 469
		)) -- 469
		local output = formatGitStatusOutput(gitRes.status) -- 471
		if not gitRes.success then -- 471
			local ____output_21 = output -- 476
			local ____cwd_relative_22 = cwd.relative -- 477
			local ____temp_23 = gitRes.message or "git command failed" -- 478
			local ____gitRes_interrupted_20 = gitRes.interrupted -- 479
			if not ____gitRes_interrupted_20 then -- 479
				local ____this_19 -- 479
				____this_19 = req -- 479
				local ____opt_18 = ____this_19.isCancelled -- 479
				____gitRes_interrupted_20 = (____opt_18 and ____opt_18(____this_19)) == true -- 479
			end -- 479
			return ____awaiter_resolve(nil, { -- 479
				success = false, -- 474
				mode = "git", -- 475
				output = ____output_21, -- 476
				cwd = ____cwd_relative_22, -- 477
				message = ____temp_23, -- 478
				interrupted = ____gitRes_interrupted_20 -- 479
			}) -- 479
		end -- 479
		if not refreshWorkspaceTree(req.workDir) then -- 479
			Log("Warn", (("[execute_command] failed to refresh Web IDE tree after Git command workDir=" .. req.workDir) .. " cwd=") .. cwd.relative) -- 483
		end -- 483
		return ____awaiter_resolve(nil, {success = true, mode = "git", cwd = cwd.relative, output = output}) -- 483
	end) -- 483
end -- 419
return ____exports -- 419