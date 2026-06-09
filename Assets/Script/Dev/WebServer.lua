-- [yue]: Script/Dev/WebServer.yue
local _module_0 = nil -- 1
local _ENV = Dora -- 9
local HttpServer <const> = HttpServer -- 10
local Path <const> = Path -- 10
local Content <const> = Content -- 10
local table <const> = table -- 10
local string <const> = string -- 10
local math <const> = math -- 10
local require <const> = require -- 10
local os <const> = os -- 10
local type <const> = type -- 10
local tostring <const> = tostring -- 10
local DB <const> = DB -- 10
local tonumber <const> = tonumber -- 10
local json <const> = json -- 10
local Git <const> = Git -- 10
local pcall <const> = pcall -- 10
local wait <const> = wait -- 10
local yue <const> = yue -- 10
local load <const> = load -- 10
local teal <const> = teal -- 10
local xml <const> = xml -- 10
local ipairs <const> = ipairs -- 10
local pairs <const> = pairs -- 10
local App <const> = App -- 10
local setmetatable <const> = setmetatable -- 10
local package <const> = package -- 10
local thread <const> = thread -- 10
local print <const> = print -- 10
local sleep <const> = sleep -- 10
local emit <const> = emit -- 10
local Wasm <const> = Wasm -- 10
local Node <const> = Node -- 10
local yarncompile <const> = yarncompile -- 10
HttpServer:stop() -- 12
HttpServer.wwwPath = Path(Content.appPath, ".www") -- 14
HttpServer.authToken = "" -- 16
local authFailedCount = 0 -- 18
local authLockedUntil = 0.0 -- 19
local PendingTTL = 60 -- 21
local _anon_func_0 = function() -- 23
	local _accum_0 = { } -- 23
	local _len_0 = 1 -- 23
	for _ = 1, 4 do -- 23
		_accum_0[_len_0] = string.format("%08x", math.random(0, 0x7fffffff)) -- 24
		_len_0 = _len_0 + 1 -- 24
	end -- 23
	return _accum_0 -- 23
end -- 23
local genAuthToken -- 23
genAuthToken = function() -- 23
	return table.concat(_anon_func_0()) -- 23
end -- 23
local _anon_func_1 = function() -- 26
	local _accum_0 = { } -- 26
	local _len_0 = 1 -- 26
	for _ = 1, 2 do -- 26
		_accum_0[_len_0] = string.format("%08x", math.random(0, 0x7fffffff)) -- 27
		_len_0 = _len_0 + 1 -- 27
	end -- 26
	return _accum_0 -- 26
end -- 26
local genSessionId -- 26
genSessionId = function() -- 26
	return table.concat(_anon_func_1()) -- 26
end -- 26
local genConfirmCode -- 29
genConfirmCode = function() -- 29
	return string.format("%04d", math.random(0, 9999)) -- 29
end -- 29
HttpServer:post("/auth", function(req) -- 31
	local Entry = require("Script.Dev.Entry") -- 32
	local AuthSession = Entry.AuthSession -- 33
	local authCode = Entry.getAuthCode() -- 34
	local now = os.time() -- 35
	if now < authLockedUntil then -- 36
		return { -- 37
			success = false, -- 37
			message = "locked", -- 37
			retryAfter = authLockedUntil - now -- 37
		} -- 37
	end -- 36
	local code = nil -- 38
	do -- 40
		local _type_0 = type(req) -- 40
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 40
		if _tab_0 then -- 40
			do -- 40
				local _obj_0 = req.body -- 40
				local _type_1 = type(_obj_0) -- 40
				if "table" == _type_1 or "userdata" == _type_1 then -- 40
					code = _obj_0.code -- 40
				end -- 40
			end -- 40
			if code ~= nil then -- 40
				code = code -- 41
			end -- 40
		end -- 39
	end -- 39
	if code and tostring(code) == authCode then -- 42
		authFailedCount = 0 -- 43
		Entry.invalidateAuthCode() -- 44
		do -- 45
			local pending = AuthSession.getPending() -- 45
			if pending then -- 45
				if now < pending.expiresAt and not pending.approved then -- 46
					return { -- 47
						success = true, -- 47
						pending = true, -- 47
						sessionId = pending.sessionId, -- 47
						confirmCode = pending.confirmCode, -- 47
						expiresIn = pending.expiresAt - now -- 47
					} -- 47
				end -- 46
			end -- 45
		end -- 45
		local sessionId = genSessionId() -- 48
		local confirmCode = genConfirmCode() -- 49
		AuthSession.beginPending(sessionId, confirmCode, now + PendingTTL, PendingTTL) -- 50
		return { -- 51
			success = true, -- 51
			pending = true, -- 51
			sessionId = sessionId, -- 51
			confirmCode = confirmCode, -- 51
			expiresIn = PendingTTL -- 51
		} -- 51
	else -- 53
		authFailedCount = authFailedCount + 1 -- 53
		if authFailedCount >= 3 then -- 54
			authFailedCount = 0 -- 55
			authLockedUntil = now + 30 -- 56
			return { -- 57
				success = false, -- 57
				message = "locked", -- 57
				retryAfter = 30 -- 57
			} -- 57
		end -- 54
		return { -- 58
			success = false, -- 58
			message = "invalid code" -- 58
		} -- 58
	end -- 42
end) -- 31
HttpServer:post("/auth/confirm", function(req) -- 60
	local now = os.time() -- 61
	local sessionId = nil -- 62
	do -- 64
		local _type_0 = type(req) -- 64
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 64
		if _tab_0 then -- 64
			do -- 64
				local _obj_0 = req.body -- 64
				local _type_1 = type(_obj_0) -- 64
				if "table" == _type_1 or "userdata" == _type_1 then -- 64
					sessionId = _obj_0.sessionId -- 64
				end -- 64
			end -- 64
			if sessionId ~= nil then -- 64
				sessionId = sessionId -- 65
			end -- 64
		end -- 63
	end -- 63
	if not sessionId then -- 66
		return { -- 67
			success = false, -- 67
			message = "invalid session" -- 67
		} -- 67
	end -- 66
	local Entry = require("Script.Dev.Entry") -- 68
	local AuthSession = Entry.AuthSession -- 69
	do -- 70
		local pending = AuthSession.getPending() -- 70
		if pending then -- 70
			if pending.sessionId ~= sessionId then -- 71
				return { -- 72
					success = false, -- 72
					message = "invalid session" -- 72
				} -- 72
			end -- 71
			if now >= pending.expiresAt then -- 73
				AuthSession.clearPending() -- 74
				return { -- 75
					success = false, -- 75
					message = "expired" -- 75
				} -- 75
			end -- 73
			if pending.approved then -- 76
				local secret = genAuthToken() -- 77
				HttpServer.authToken = tostring(sessionId) .. ":" .. tostring(secret) -- 78
				AuthSession.setSession(sessionId, secret) -- 79
				AuthSession.clearPending() -- 80
				return { -- 81
					success = true, -- 81
					sessionId = sessionId, -- 81
					sessionSecret = secret -- 81
				} -- 81
			end -- 76
			return { -- 82
				success = false, -- 82
				message = "pending", -- 82
				retryAfter = 2 -- 82
			} -- 82
		end -- 70
	end -- 70
	return { -- 83
		success = false, -- 83
		message = "invalid session" -- 83
	} -- 83
end) -- 60
local LintYueGlobals, CheckTIC80Code -- 85
do -- 85
	local _obj_0 = require("Utils") -- 85
	LintYueGlobals, CheckTIC80Code = _obj_0.LintYueGlobals, _obj_0.CheckTIC80Code -- 85
end -- 85
local getProjectDirFromFile -- 87
getProjectDirFromFile = function(file) -- 87
	local writablePath, assetPath = Content.writablePath, Content.assetPath -- 88
	local parent, current -- 89
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 89
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 90
	elseif (".." ~= Path:getRelative(file, assetPath):sub(1, 2)) and assetPath == file:sub(1, #assetPath) then -- 91
		local dir = Path(assetPath, "Script") -- 92
		parent, current = dir, Path:getRelative(file, dir) -- 93
	else -- 95
		parent, current = nil, nil -- 95
	end -- 89
	if not current then -- 96
		return nil -- 96
	end -- 96
	repeat -- 97
		current = Path:getPath(current) -- 98
		if current == "" then -- 99
			break -- 99
		end -- 99
		local _list_0 = Content:getFiles(Path(parent, current)) -- 100
		for _index_0 = 1, #_list_0 do -- 100
			local f = _list_0[_index_0] -- 100
			if Path:getName(f):lower() == "init" then -- 101
				return Path(parent, current, Path:getPath(f)) -- 102
			end -- 101
		end -- 100
	until false -- 97
	return nil -- 104
end -- 87
local isProjectRootDir -- 106
isProjectRootDir = function(dir) -- 106
	if not (dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir)) then -- 107
		return false -- 107
	end -- 107
	local _list_0 = Content:getFiles(dir) -- 108
	for _index_0 = 1, #_list_0 do -- 108
		local f = _list_0[_index_0] -- 108
		if Path:getName(f):lower() == "init" then -- 109
			return true -- 110
		end -- 109
	end -- 108
	return false -- 111
end -- 106
local getProjectRootFromPath -- 113
getProjectRootFromPath = function(target, isDir) -- 113
	if isDir == nil then -- 113
		isDir = false -- 113
	end -- 113
	if not (target and target ~= "" and Content:isAbsolutePath(target)) then -- 114
		return nil, "invalid path" -- 114
	end -- 114
	if isDir then -- 115
		if isProjectRootDir(target) then -- 116
			return target -- 116
		end -- 116
		return getProjectDirFromFile(Path(target, "__dora_project_root_search__.lua"), "current directory does not belong to any project") -- 117
	end -- 115
	return getProjectDirFromFile(target, "current file does not belong to any project") -- 118
end -- 113
local invalidArguments = { -- 120
	success = false, -- 120
	message = "invalid arguments" -- 120
} -- 120
HttpServer:post("/agent/project-root", function(req) -- 122
	do -- 123
		local _type_0 = type(req) -- 123
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 123
		if _tab_0 then -- 123
			local path -- 123
			do -- 123
				local _obj_0 = req.body -- 123
				local _type_1 = type(_obj_0) -- 123
				if "table" == _type_1 or "userdata" == _type_1 then -- 123
					path = _obj_0.path -- 123
				end -- 123
			end -- 123
			local isDir -- 123
			do -- 123
				local _obj_0 = req.body -- 123
				local _type_1 = type(_obj_0) -- 123
				if "table" == _type_1 or "userdata" == _type_1 then -- 123
					isDir = _obj_0.isDir -- 123
				end -- 123
			end -- 123
			if path ~= nil and isDir ~= nil then -- 123
				local projectRoot, err = getProjectRootFromPath(path, isDir) -- 124
				if projectRoot then -- 124
					return { -- 125
						success = true, -- 125
						found = true, -- 125
						projectRoot = projectRoot, -- 125
						title = Path:getFilename(projectRoot) -- 125
					} -- 125
				else -- 127
					return { -- 127
						success = true, -- 127
						found = false, -- 127
						message = err -- 127
					} -- 127
				end -- 124
			end -- 123
		end -- 123
	end -- 123
	return invalidArguments -- 122
end) -- 122
local AgentTools = require("Agent.Tools") -- 129
local AgentSession = require("Agent.AgentSession") -- 130
local GitJobs = { } -- 132
local gitTerminalState -- 134
gitTerminalState = function(status) -- 134
	if not (status and status.state) then -- 135
		return false -- 135
	end -- 135
	local _val_0 = status.state -- 136
	return "done" == _val_0 or "error" == _val_0 or "canceled" == _val_0 -- 136
end -- 134
local gitInvalidRepoPath -- 138
gitInvalidRepoPath = function(repoPath) -- 138
	return not repoPath or repoPath == "" or not Content:isAbsolutePath(repoPath) -- 139
end -- 138
local gitShellSplit -- 141
gitShellSplit = function(command) -- 141
	local args = { } -- 142
	local current = { } -- 143
	local quote = nil -- 144
	local escape = false -- 145
	for i = 1, #command do -- 146
		local ch = command:sub(i, i) -- 147
		if escape then -- 148
			current[#current + 1] = ch -- 149
			escape = false -- 150
		elseif ch == "\\" then -- 151
			escape = true -- 152
		elseif quote then -- 153
			if ch == quote then -- 154
				quote = nil -- 155
			else -- 157
				current[#current + 1] = ch -- 157
			end -- 154
		elseif ch == "'" or ch == '"' then -- 158
			quote = ch -- 159
		elseif ch:match("%s") then -- 160
			if #current > 0 then -- 161
				args[#args + 1] = table.concat(current) -- 162
				current = { } -- 163
			end -- 161
		else -- 165
			current[#current + 1] = ch -- 165
		end -- 148
	end -- 146
	if #current > 0 then -- 166
		args[#args + 1] = table.concat(current) -- 167
	end -- 166
	if args[1] == "git" then -- 168
		table.remove(args, 1) -- 169
	end -- 168
	return args -- 170
end -- 141
local gitQuote -- 172
gitQuote = function(value) -- 172
	local text = tostring(value) -- 173
	if text:match("^[%w%._%-%/]+$") then -- 174
		return text -- 175
	end -- 174
	return "\"" .. text:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"" -- 176
end -- 172
local gitDirNonEmpty -- 178
gitDirNonEmpty = function(targetPath) -- 178
	if not Content:exist(targetPath) then -- 179
		return false -- 179
	end -- 179
	if not Content:isdir(targetPath) then -- 180
		return false -- 180
	end -- 180
	return #Content:getFiles(targetPath) > 0 or #Content:getDirs(targetPath) > 0 -- 181
end -- 178
local gitSafeChildPath -- 183
gitSafeChildPath = function(parentPath, childPath) -- 183
	if not (parentPath and childPath and childPath ~= "") then -- 184
		return nil -- 184
	end -- 184
	if childPath:sub(1, 1) == "/" or childPath:match("^%a:[/\\]") then -- 185
		return nil -- 185
	end -- 185
	if childPath == "." or childPath:match("^%.%.[/\\]?" or childPath:match("[/\\]%.%.[/\\]")) then -- 186
		return nil -- 186
	end -- 186
	local targetPath = Path(parentPath, childPath) -- 187
	local relative = Path:getRelative(targetPath, parentPath) -- 188
	if relative == ".." or relative:sub(1, 3) == "../" or relative:sub(1, 3) == "..\\" then -- 189
		return nil -- 189
	end -- 189
	return targetPath -- 190
end -- 183
local gitCloneDirFromURL -- 192
gitCloneDirFromURL = function(url) -- 192
	if not (url and url ~= "") then -- 193
		return nil -- 193
	end -- 193
	local text = tostring(url):match("^%s*(.-)%s*$") -- 194
	if text == "" then -- 195
		return nil -- 195
	end -- 195
	text = text:gsub("[/\\]+$", "") -- 196
	local name = text:match("([^/:]+)$") -- 197
	if not (name and name ~= "") then -- 198
		return nil -- 198
	end -- 198
	name = name:gsub("%.git$", "") -- 199
	if name == "" or name == "." or name == ".." then -- 200
		return nil -- 200
	end -- 200
	return name -- 201
end -- 192
local gitCloneTargetPath -- 203
gitCloneTargetPath = function(repoPath, command) -- 203
	local args = gitShellSplit(command) -- 204
	if not (args[1] == "clone") then -- 205
		return nil -- 205
	end -- 205
	local url = args[2] -- 206
	local index = 3 -- 207
	while index <= #args do -- 208
		local arg = args[index] -- 209
		if ("-b" == arg or "--branch" == arg or "--depth" == arg) then -- 210
			index = index + 2 -- 211
		elseif arg:sub(1, 1) == "-" then -- 212
			index = index + 1 -- 213
		else -- 215
			return gitSafeChildPath(repoPath, arg) -- 215
		end -- 210
	end -- 208
	do -- 216
		local dirName = gitCloneDirFromURL(url) -- 216
		if dirName then -- 216
			return gitSafeChildPath(repoPath, dirName) -- 217
		end -- 216
	end -- 216
	return nil -- 218
end -- 203
local gitPathInsideRepo -- 220
gitPathInsideRepo = function(repoPath, relPath) -- 220
	if not (repoPath and relPath and relPath ~= "") then -- 221
		return false -- 221
	end -- 221
	if relPath:sub(1, 1) == "/" or relPath:match("^%a:[/\\]") then -- 222
		return false -- 222
	end -- 222
	if relPath == "." or relPath:match("^%.%.[/\\]?" or relPath:match("[/\\]%.%.[/\\]")) then -- 223
		return false -- 223
	end -- 223
	local targetPath = Path(repoPath, relPath) -- 224
	local relative = Path:getRelative(targetPath, repoPath) -- 225
	return relative ~= ".." and relative:sub(1, 3) ~= "../" and relative:sub(1, 3) ~= "..\\" -- 226
end -- 220
local gitHostFromURL -- 228
gitHostFromURL = function(url) -- 228
	if not (url and url ~= "") then -- 229
		return nil -- 229
	end -- 229
	local text = tostring(url):match("^%s*(.-)%s*$") -- 230
	if text == "" then -- 231
		return nil -- 231
	end -- 231
	local host = text:match("^[%w_%-]+://([^/:]+)") -- 232
	if not host then -- 233
		host = text:match("@([^:/]+)[:/]") -- 233
	end -- 233
	if not host then -- 234
		host = text:match("^([^:/]+):[^/]") -- 234
	end -- 234
	if not (host and host ~= "") then -- 235
		return nil -- 235
	end -- 235
	return string.lower(host) -- 236
end -- 228
local ensureGitTables -- 238
ensureGitTables = function() -- 238
	DB:exec([[		CREATE TABLE IF NOT EXISTS GitCredential(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			host TEXT NOT NULL,
			label TEXT NOT NULL,
			type TEXT NOT NULL,
			username TEXT NOT NULL DEFAULT '',
			secret TEXT NOT NULL DEFAULT '',
			created_at INTEGER,
			updated_at INTEGER,
			last_used_at INTEGER
		);
	]]) -- 239
	DB:exec("CREATE INDEX IF NOT EXISTS idx_git_credential_host ON GitCredential(host);") -- 252
	return DB:exec([[		CREATE TABLE IF NOT EXISTS GitProfile(
			id INTEGER PRIMARY KEY CHECK(id = 1),
			name TEXT NOT NULL DEFAULT '',
			email TEXT NOT NULL DEFAULT '',
			updated_at INTEGER
		);
	]]) -- 253
end -- 238
local gitCredentialToPublic -- 262
gitCredentialToPublic = function(row) -- 262
	local id, host, label, typeName, username, createdAt, updatedAt, lastUsedAt = row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8] -- 263
	return { -- 264
		id = id, -- 264
		host = host, -- 264
		label = label, -- 264
		type = typeName, -- 264
		username = username, -- 264
		createdAt = createdAt, -- 264
		updatedAt = updatedAt, -- 264
		lastUsedAt = lastUsedAt -- 264
	} -- 264
end -- 262
local gitLoadCredential -- 266
gitLoadCredential = function(id) -- 266
	ensureGitTables() -- 267
	local credentialId = tonumber(id) or 0 -- 268
	local rows = DB:query("select id, host, label, type, username, secret from GitCredential where id = ? limit 1", { -- 269
		credentialId -- 269
	}) -- 269
	if not (rows and rows[1]) then -- 270
		return nil -- 270
	end -- 270
	local row = rows[1] -- 271
	return { -- 272
		id = row[1], -- 272
		host = row[2], -- 272
		label = row[3], -- 272
		type = row[4], -- 272
		username = row[5], -- 272
		secret = row[6] -- 272
	} -- 272
end -- 266
local gitAuthOptionsJSON -- 274
gitAuthOptionsJSON = function(credential) -- 274
	if not credential then -- 275
		return nil -- 275
	end -- 275
	local auth -- 276
	if credential.type == "token" then -- 276
		auth = { -- 278
			type = "token", -- 278
			token = credential.secret, -- 279
			username = credential.username ~= "" and credential.username or "token" -- 280
		} -- 277
	else -- 283
		auth = { -- 284
			type = "basic", -- 284
			username = credential.username, -- 285
			password = credential.secret -- 286
		} -- 283
	end -- 276
	return json.encode({ -- 288
		auth = auth -- 288
	}) -- 288
end -- 274
local gitLoadProfile -- 290
gitLoadProfile = function() -- 290
	ensureGitTables() -- 291
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 292
	if not (rows and rows[1]) then -- 293
		return nil -- 293
	end -- 293
	local name = tostring(rows[1][1] or "") -- 294
	local email = tostring(rows[1][2] or "") -- 295
	if name == "" and email == "" then -- 296
		return nil -- 296
	end -- 296
	return { -- 297
		name = name, -- 297
		email = email -- 297
	} -- 297
end -- 290
local _anon_func_2 = function(args, gitQuote) -- 316
	local _accum_0 = { } -- 316
	local _len_0 = 1 -- 316
	for _index_0 = 1, #args do -- 316
		local arg = args[_index_0] -- 316
		_accum_0[_len_0] = gitQuote(arg) -- 316
		_len_0 = _len_0 + 1 -- 316
	end -- 316
	return _accum_0 -- 316
end -- 316
local gitApplyProfileToCommit -- 299
gitApplyProfileToCommit = function(command) -- 299
	local args = gitShellSplit(command) -- 300
	if not (args[1] == "commit") then -- 301
		return command -- 301
	end -- 301
	local hasName = false -- 302
	local hasEmail = false -- 303
	for _index_0 = 1, #args do -- 304
		local arg = args[_index_0] -- 304
		if arg == "--author-name" then -- 305
			hasName = true -- 305
		end -- 305
		if arg == "--author-email" then -- 306
			hasEmail = true -- 306
		end -- 306
	end -- 304
	if hasName and hasEmail then -- 307
		return command -- 307
	end -- 307
	local profile = gitLoadProfile() -- 308
	if not profile then -- 309
		return command -- 309
	end -- 309
	if not hasName and profile.name ~= "" then -- 310
		args[#args + 1] = "--author-name" -- 311
		args[#args + 1] = profile.name -- 312
	end -- 310
	if not hasEmail and profile.email ~= "" then -- 313
		args[#args + 1] = "--author-email" -- 314
		args[#args + 1] = profile.email -- 315
	end -- 313
	return table.concat(_anon_func_2(args, gitQuote), " ") -- 316
end -- 299
local gitStartJob -- 318
gitStartJob = function(repoPath, command, optionsJSON) -- 318
	if optionsJSON == nil then -- 318
		optionsJSON = nil -- 318
	end -- 318
	if gitInvalidRepoPath(repoPath) then -- 319
		return nil, "invalid repoPath" -- 319
	end -- 319
	if not (command and command ~= "") then -- 320
		return nil, "invalid command" -- 320
	end -- 320
	if not optionsJSON then -- 321
		optionsJSON = "" -- 321
	end -- 321
	command = gitApplyProfileToCommit(command) -- 322
	do -- 323
		local targetPath = gitCloneTargetPath(repoPath, command) -- 323
		if targetPath then -- 323
			if gitDirNonEmpty(targetPath) then -- 324
				return nil, "clone target directory is not empty" -- 325
			end -- 324
		elseif (gitShellSplit(command))[1] == "clone" then -- 326
			return nil, "invalid clone target" -- 327
		end -- 323
	end -- 323
	local statusRef = nil -- 328
	local startGit -- 329
	startGit = function() -- 329
		return Git:run(repoPath, command, (function(status) -- 330
			statusRef = status -- 331
			GitJobs[status.id] = { -- 333
				command = command, -- 333
				status = status, -- 334
				updatedAt = os.time() -- 335
			} -- 332
		end), optionsJSON) -- 330
	end -- 329
	local success, jobId = pcall(startGit) -- 337
	if not success then -- 338
		return nil, tostring(jobId) -- 338
	end -- 338
	if not jobId then -- 339
		return nil, "Git.run did not return a job id" -- 339
	end -- 339
	GitJobs[jobId] = { -- 341
		command = command, -- 341
		status = statusRef or { -- 343
			id = jobId, -- 343
			state = "queued", -- 344
			kind = gitShellSplit(command)[1] or "status", -- 345
			repoPath = repoPath, -- 346
			progress = 0, -- 347
			message = "queued" -- 348
		}, -- 342
		updatedAt = os.time() -- 350
	} -- 340
	return jobId -- 351
end -- 318
local gitRunSync -- 353
gitRunSync = function(repoPath, command, optionsJSON, timeout) -- 353
	if optionsJSON == nil then -- 353
		optionsJSON = nil -- 353
	end -- 353
	if timeout == nil then -- 353
		timeout = 20 -- 353
	end -- 353
	local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 354
	if not jobId then -- 355
		return { -- 355
			success = false, -- 355
			message = err -- 355
		} -- 355
	end -- 355
	local startedAt = os.time() -- 356
	wait(function() -- 357
		local job = GitJobs[jobId] -- 358
		local status = job and job.status -- 359
		return gitTerminalState(status) or os.time() - startedAt >= timeout -- 360
	end) -- 357
	local status = GitJobs[jobId] and GitJobs[jobId].status -- 361
	if not gitTerminalState(status) then -- 362
		Git:cancel(jobId) -- 363
		return { -- 364
			success = false, -- 364
			message = "git command timed out", -- 364
			jobId = jobId, -- 364
			status = status -- 364
		} -- 364
	end -- 362
	return { -- 365
		success = status.state == "done", -- 365
		jobId = jobId, -- 365
		status = status, -- 365
		message = status.error or status.message -- 365
	} -- 365
end -- 353
local gitCredentialsForHost -- 367
gitCredentialsForHost = function(host) -- 367
	if not (host and host ~= "") then -- 368
		return { } -- 368
	end -- 368
	ensureGitTables() -- 369
	local rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by last_used_at desc, label asc, id asc", { -- 370
		host -- 370
	}) -- 370
	if rows then -- 371
		local _accum_0 = { } -- 372
		local _len_0 = 1 -- 372
		for _index_0 = 1, #rows do -- 372
			local row = rows[_index_0] -- 372
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 372
			_len_0 = _len_0 + 1 -- 372
		end -- 372
		return _accum_0 -- 372
	else -- 373
		return { } -- 373
	end -- 371
end -- 367
local gitFirstRemoteURL -- 375
gitFirstRemoteURL = function(repoPath, remoteName) -- 375
	if remoteName == nil then -- 375
		remoteName = nil -- 375
	end -- 375
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 10) -- 376
	local data = remoteRes.status and remoteRes.status.data -- 377
	if not (data and data.remotes) then -- 378
		return nil -- 378
	end -- 378
	local _list_0 = data.remotes -- 379
	for _index_0 = 1, #_list_0 do -- 379
		local remote = _list_0[_index_0] -- 379
		if (not remoteName or remote.name == remoteName) and remote.urls and remote.urls[1] then -- 380
			return remote.urls[1] -- 381
		end -- 380
	end -- 379
	return nil -- 382
end -- 375
local gitConfigRemoteURL -- 384
gitConfigRemoteURL = function(repoPath, remoteName) -- 384
	if remoteName == nil then -- 384
		remoteName = nil -- 384
	end -- 384
	if gitInvalidRepoPath(repoPath) then -- 385
		return nil -- 385
	end -- 385
	local configPath = Path(repoPath, ".git/config") -- 386
	if not Content:exist(configPath) then -- 387
		return nil -- 387
	end -- 387
	local content = Content:load(configPath) -- 388
	if not (content and content ~= "") then -- 389
		return nil -- 389
	end -- 389
	local currentRemote = nil -- 390
	for line in content:gmatch("[^\r\n]+") do -- 391
		local sectionRemote = line:match('^%s*%[remote%s+"([^"]+)"%]%s*$') -- 392
		if sectionRemote then -- 393
			currentRemote = sectionRemote -- 394
		elseif currentRemote and (not remoteName or currentRemote == remoteName) then -- 395
			local url = line:match("^%s*url%s*=%s*(.-)%s*$") -- 396
			if url and url ~= "" then -- 397
				return url -- 397
			end -- 397
		end -- 393
	end -- 391
	return nil -- 398
end -- 384
local gitCommandRemoteArg -- 400
gitCommandRemoteArg = function(args, startIndex) -- 400
	if startIndex == nil then -- 400
		startIndex = 2 -- 400
	end -- 400
	local index = startIndex -- 401
	while index <= #args do -- 402
		local arg = args[index] -- 403
		if ("-u" == arg or "--set-upstream" == arg or "-f" == arg or "--force" == arg or "--all" == arg or "--prune" == arg) then -- 404
			index = index + 1 -- 405
		elseif ("--depth" == arg or "-b" == arg or "--branch" == arg) then -- 406
			index = index + 2 -- 407
		elseif arg and arg:sub(1, 1) == "-" then -- 408
			index = index + 1 -- 409
		else -- 411
			return arg -- 411
		end -- 404
	end -- 402
	return nil -- 412
end -- 400
local gitCommandHost -- 414
gitCommandHost = function(repoPath, command) -- 414
	local args = gitShellSplit(command) -- 415
	if not args[1] then -- 416
		return nil -- 416
	end -- 416
	do -- 417
		local _exp_0 = args[1] -- 417
		if "clone" == _exp_0 or "ls-remote" == _exp_0 then -- 418
			return gitHostFromURL(args[2]) -- 419
		elseif "fetch" == _exp_0 or "pull" == _exp_0 or "push" == _exp_0 then -- 420
			local remoteArg = gitCommandRemoteArg(args, 2) -- 421
			if not remoteArg then -- 422
				return nil -- 422
			end -- 422
			local url = gitHostFromURL(remoteArg) -- 423
			if url then -- 424
				return url -- 424
			end -- 424
			return gitHostFromURL(gitConfigRemoteURL(repoPath, remoteArg)) -- 425
		end -- 417
	end -- 417
	return nil -- 426
end -- 414
local gitAuthSelectionForCommand -- 428
gitAuthSelectionForCommand = function(repoPath, command) -- 428
	local host = gitCommandHost(repoPath, command) -- 429
	if not host then -- 430
		return nil -- 430
	end -- 430
	local items = gitCredentialsForHost(host) -- 431
	if #items == 0 then -- 432
		return nil -- 432
	end -- 432
	return { -- 433
		host = host, -- 433
		items = items -- 433
	} -- 433
end -- 428
local gitDefaultRemote -- 435
gitDefaultRemote = function(remoteStatus) -- 435
	local data = remoteStatus and remoteStatus.data -- 436
	if not (data and data.remotes and data.remotes[1]) then -- 437
		return nil -- 437
	end -- 437
	return data.remotes[1] -- 438
end -- 435
local gitCurrentBranch -- 440
gitCurrentBranch = function(branchStatus) -- 440
	local data = branchStatus and branchStatus.data -- 441
	if data and data.current and data.current ~= "" then -- 442
		return data.current -- 443
	end -- 442
	if data and data.branches then -- 444
		local _list_0 = data.branches -- 445
		for _index_0 = 1, #_list_0 do -- 445
			local branch = _list_0[_index_0] -- 445
			if branch.current then -- 446
				return branch.name -- 446
			end -- 446
		end -- 445
	end -- 444
	return nil -- 447
end -- 440
local gitHeadBranch -- 449
gitHeadBranch = function(repoPath) -- 449
	if gitInvalidRepoPath(repoPath) then -- 450
		return nil -- 450
	end -- 450
	local headPath = Path(repoPath, ".git", "HEAD") -- 451
	if not Content:exist(headPath) then -- 452
		return nil -- 452
	end -- 452
	local head = Content:load(headPath) -- 453
	if not head then -- 454
		return nil -- 454
	end -- 454
	local branch = head:match("^ref:%s*refs/heads/(.-)%s*$") -- 455
	if branch and branch ~= "" then -- 456
		return branch -- 456
	end -- 456
	return nil -- 457
end -- 449
local gitBranchesWithHead -- 459
gitBranchesWithHead = function(branchStatus, currentBranch) -- 459
	local branches = branchStatus and branchStatus.data and branchStatus.data.branches or { } -- 460
	if not (currentBranch and currentBranch ~= "") then -- 461
		return branches -- 461
	end -- 461
	for _index_0 = 1, #branches do -- 462
		local branch = branches[_index_0] -- 462
		if branch.name == currentBranch then -- 463
			return branches -- 463
		end -- 463
	end -- 462
	local withHead -- 464
	do -- 464
		local _accum_0 = { } -- 464
		local _len_0 = 1 -- 464
		for _index_0 = 1, #branches do -- 464
			local branch = branches[_index_0] -- 464
			_accum_0[_len_0] = branch -- 464
			_len_0 = _len_0 + 1 -- 464
		end -- 464
		withHead = _accum_0 -- 464
	end -- 464
	withHead[#withHead + 1] = { -- 465
		name = currentBranch, -- 465
		current = true, -- 465
		unborn = true -- 465
	} -- 465
	return withHead -- 466
end -- 459
local gitSummary -- 468
gitSummary = function(repoPath) -- 468
	local statusRes = gitRunSync(repoPath, "status", nil, 10) -- 469
	if not statusRes.success then -- 470
		return { -- 471
			success = true, -- 471
			isRepo = false, -- 471
			message = statusRes.message, -- 471
			status = statusRes.status -- 471
		} -- 471
	end -- 470
	local branchRes = gitRunSync(repoPath, "branch", nil, 10) -- 472
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 10) -- 473
	local status = statusRes.status -- 474
	local branchStatus = branchRes.status -- 475
	local remoteStatus = remoteRes.status -- 476
	local currentBranch = gitCurrentBranch(branchStatus) or gitHeadBranch(repoPath) -- 477
	local branches = gitBranchesWithHead(branchStatus, currentBranch) -- 478
	local hasCommit = false -- 479
	if branches and #branches > 0 then -- 480
		for _index_0 = 1, #branches do -- 481
			local branch = branches[_index_0] -- 481
			if branch.hash and branch.hash ~= "" then -- 482
				hasCommit = true -- 483
				break -- 484
			end -- 482
		end -- 481
	end -- 480
	local logStatus -- 485
	if hasCommit then -- 485
		logStatus = (gitRunSync(repoPath, "log -n 100", nil, 10)).status -- 486
	else -- 488
		logStatus = { -- 489
			state = "done", -- 489
			kind = "log", -- 490
			repoPath = repoPath, -- 491
			progress = 1, -- 492
			message = "git log completed", -- 493
			data = { -- 494
				commits = { } -- 494
			} -- 494
		} -- 488
	end -- 485
	local tagStatus -- 496
	if hasCommit then -- 496
		tagStatus = (gitRunSync(repoPath, "tag", nil, 10)).status -- 497
	else -- 499
		tagStatus = { -- 500
			state = "done", -- 500
			kind = "tag", -- 501
			repoPath = repoPath, -- 502
			progress = 1, -- 503
			message = "git tag completed", -- 504
			data = { -- 505
				tags = { } -- 505
			} -- 505
		} -- 499
	end -- 496
	local defaultRemote = gitDefaultRemote(remoteStatus) -- 507
	local lastCommit = nil -- 508
	if logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] then -- 509
		lastCommit = logStatus.data.commits[1] -- 510
	end -- 509
	return { -- 512
		success = true, -- 512
		isRepo = true, -- 513
		clean = status.data and status.data.clean or false, -- 514
		currentBranch = currentBranch, -- 515
		defaultRemote = defaultRemote, -- 516
		remotes = remoteStatus and remoteStatus.data and remoteStatus.data.remotes or { }, -- 517
		branches = branches, -- 518
		lastCommit = lastCommit, -- 519
		status = status, -- 520
		branchStatus = branchStatus, -- 521
		remoteStatus = remoteStatus, -- 522
		historyStatus = logStatus, -- 523
		tagStatus = tagStatus -- 524
	} -- 511
end -- 468
HttpServer:post("/git/run", function(req) -- 526
	do -- 527
		local _type_0 = type(req) -- 527
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 527
		if _tab_0 then -- 527
			local body = req.body -- 527
			if body ~= nil then -- 527
				local repoPath, command, authId, optionsJSON = body.repoPath, body.command, body.authId, body.optionsJSON -- 528
				if authId and not optionsJSON then -- 529
					local credential = gitLoadCredential(authId) -- 530
					if credential then -- 530
						optionsJSON = gitAuthOptionsJSON(credential) -- 531
						DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 532
							os.time(), -- 532
							credential.id -- 532
						}) -- 532
					end -- 530
				elseif not optionsJSON then -- 533
					local authOk, authSelection = pcall(gitAuthSelectionForCommand, repoPath, command) -- 534
					if not authOk then -- 535
						authSelection = nil -- 535
					end -- 535
					if authSelection then -- 536
						if #authSelection.items == 1 then -- 537
							local credential = gitLoadCredential(authSelection.items[1].id) -- 538
							optionsJSON = gitAuthOptionsJSON(credential) -- 539
							DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 540
								os.time(), -- 540
								credential.id -- 540
							}) -- 540
						else -- 542
							return { -- 542
								success = false, -- 542
								message = "select a Git credential", -- 542
								needsCredentialSelection = true, -- 542
								host = authSelection.host, -- 542
								credentials = authSelection.items -- 542
							} -- 542
						end -- 537
					end -- 536
				end -- 529
				local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 543
				if not jobId then -- 544
					return { -- 544
						success = false, -- 544
						message = err -- 544
					} -- 544
				end -- 544
				return { -- 545
					success = true, -- 545
					jobId = jobId -- 545
				} -- 545
			end -- 527
		end -- 527
	end -- 527
	return invalidArguments -- 526
end) -- 526
HttpServer:post("/git/status", function(req) -- 547
	do -- 548
		local _type_0 = type(req) -- 548
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 548
		if _tab_0 then -- 548
			local jobId -- 548
			do -- 548
				local _obj_0 = req.body -- 548
				local _type_1 = type(_obj_0) -- 548
				if "table" == _type_1 or "userdata" == _type_1 then -- 548
					jobId = _obj_0.jobId -- 548
				end -- 548
			end -- 548
			if jobId ~= nil then -- 548
				local job = GitJobs[tonumber(jobId) or 0] -- 549
				if not job then -- 550
					return { -- 550
						success = false, -- 550
						message = "git job not found" -- 550
					} -- 550
				end -- 550
				return { -- 551
					success = true, -- 551
					status = job.status, -- 551
					command = job.command -- 551
				} -- 551
			end -- 548
		end -- 548
	end -- 548
	return invalidArguments -- 547
end) -- 547
HttpServer:post("/git/cancel", function(req) -- 553
	do -- 554
		local _type_0 = type(req) -- 554
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 554
		if _tab_0 then -- 554
			local jobId -- 554
			do -- 554
				local _obj_0 = req.body -- 554
				local _type_1 = type(_obj_0) -- 554
				if "table" == _type_1 or "userdata" == _type_1 then -- 554
					jobId = _obj_0.jobId -- 554
				end -- 554
			end -- 554
			if jobId ~= nil then -- 554
				local id = tonumber(jobId) -- 555
				if not id then -- 556
					return { -- 556
						success = false, -- 556
						message = "invalid jobId" -- 556
					} -- 556
				end -- 556
				return { -- 557
					success = Git:cancel(id) -- 557
				} -- 557
			end -- 554
		end -- 554
	end -- 554
	return invalidArguments -- 553
end) -- 553
HttpServer:postSchedule("/git/summary", function(req) -- 559
	do -- 560
		local _type_0 = type(req) -- 560
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 560
		if _tab_0 then -- 560
			local repoPath -- 560
			do -- 560
				local _obj_0 = req.body -- 560
				local _type_1 = type(_obj_0) -- 560
				if "table" == _type_1 or "userdata" == _type_1 then -- 560
					repoPath = _obj_0.repoPath -- 560
				end -- 560
			end -- 560
			if repoPath ~= nil then -- 560
				if gitInvalidRepoPath(repoPath) then -- 561
					return { -- 561
						success = false, -- 561
						message = "invalid repoPath" -- 561
					} -- 561
				end -- 561
				return gitSummary(repoPath) -- 562
			end -- 560
		end -- 560
	end -- 560
	return invalidArguments -- 559
end) -- 559
HttpServer:postSchedule("/git/status-files", function(req) -- 564
	do -- 565
		local _type_0 = type(req) -- 565
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 565
		if _tab_0 then -- 565
			local repoPath -- 565
			do -- 565
				local _obj_0 = req.body -- 565
				local _type_1 = type(_obj_0) -- 565
				if "table" == _type_1 or "userdata" == _type_1 then -- 565
					repoPath = _obj_0.repoPath -- 565
				end -- 565
			end -- 565
			if repoPath ~= nil then -- 565
				return gitRunSync(repoPath, "status", nil, 10) -- 566
			end -- 565
		end -- 565
	end -- 565
	return invalidArguments -- 564
end) -- 564
HttpServer:postSchedule("/git/discard-untracked", function(req) -- 568
	do -- 569
		local _type_0 = type(req) -- 569
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 569
		if _tab_0 then -- 569
			local body = req.body -- 569
			if body ~= nil then -- 569
				local repoPath, paths = body.repoPath, body.paths -- 570
				if gitInvalidRepoPath(repoPath) then -- 571
					return { -- 571
						success = false, -- 571
						message = "invalid repoPath" -- 571
					} -- 571
				end -- 571
				if not (type(paths) == "table") then -- 572
					return { -- 572
						success = false, -- 572
						message = "invalid paths" -- 572
					} -- 572
				end -- 572
				local statusRes = gitRunSync(repoPath, "status", nil, 10) -- 573
				if not statusRes.success then -- 574
					return statusRes -- 574
				end -- 574
				local untracked = { } -- 575
				local _list_0 = (statusRes.status.data and statusRes.status.data.files or { }) -- 576
				for _index_0 = 1, #_list_0 do -- 576
					local file = _list_0[_index_0] -- 576
					if file.staging == "?" or file.worktree == "?" then -- 577
						untracked[file.path] = true -- 578
					end -- 577
				end -- 576
				local removed = { } -- 579
				for _index_0 = 1, #paths do -- 580
					local relPath = paths[_index_0] -- 580
					relPath = tostring(relPath) -- 581
					if not gitPathInsideRepo(repoPath, relPath) then -- 582
						return { -- 582
							success = false, -- 582
							message = "unsafe path: " .. tostring(relPath) -- 582
						} -- 582
					end -- 582
					if not untracked[relPath] then -- 583
						return { -- 583
							success = false, -- 583
							message = "path is not untracked: " .. tostring(relPath) -- 583
						} -- 583
					end -- 583
				end -- 580
				for _index_0 = 1, #paths do -- 584
					local relPath = paths[_index_0] -- 584
					local targetPath = Path(repoPath, tostring(relPath)) -- 585
					if Content:exist(targetPath) then -- 586
						Content:remove(targetPath) -- 587
						removed[#removed + 1] = tostring(relPath) -- 588
					end -- 586
				end -- 584
				return { -- 589
					success = true, -- 589
					removed = removed -- 589
				} -- 589
			end -- 569
		end -- 569
	end -- 569
	return invalidArguments -- 568
end) -- 568
HttpServer:postSchedule("/git/file-diff", function(req) -- 591
	do -- 592
		local _type_0 = type(req) -- 592
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 592
		if _tab_0 then -- 592
			local body = req.body -- 592
			if body ~= nil then -- 592
				local repoPath, path, staged = body.repoPath, body.path, body.staged -- 593
				if gitInvalidRepoPath(repoPath) then -- 594
					return { -- 594
						success = false, -- 594
						message = "invalid repoPath" -- 594
					} -- 594
				end -- 594
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 595
					return { -- 595
						success = false, -- 595
						message = "unsafe path" -- 595
					} -- 595
				end -- 595
				local command -- 596
				if staged == true then -- 596
					command = "diff --staged -- " .. tostring(gitQuote(path)) -- 597
				else -- 599
					command = "diff -- " .. tostring(gitQuote(path)) -- 599
				end -- 596
				local res = gitRunSync(repoPath, command, nil, 10) -- 600
				if not res.success then -- 601
					return res -- 601
				end -- 601
				return { -- 602
					success = true, -- 602
					status = res.status, -- 602
					data = res.status and res.status.data -- 602
				} -- 602
			end -- 592
		end -- 592
	end -- 592
	return invalidArguments -- 591
end) -- 591
HttpServer:postSchedule("/git/commit-file-diff", function(req) -- 604
	do -- 605
		local _type_0 = type(req) -- 605
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 605
		if _tab_0 then -- 605
			local body = req.body -- 605
			if body ~= nil then -- 605
				local repoPath, commit, path = body.repoPath, body.commit, body.path -- 606
				if gitInvalidRepoPath(repoPath) then -- 607
					return { -- 607
						success = false, -- 607
						message = "invalid repoPath" -- 607
					} -- 607
				end -- 607
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 608
					return { -- 608
						success = false, -- 608
						message = "invalid commit" -- 608
					} -- 608
				end -- 608
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 609
					return { -- 609
						success = false, -- 609
						message = "unsafe path" -- 609
					} -- 609
				end -- 609
				local res = gitRunSync(repoPath, "diff " .. tostring(gitQuote(commit)) .. " -- " .. tostring(gitQuote(path)), nil, 10) -- 610
				if not res.success then -- 611
					return res -- 611
				end -- 611
				return { -- 612
					success = true, -- 612
					status = res.status, -- 612
					data = res.status and res.status.data -- 612
				} -- 612
			end -- 605
		end -- 605
	end -- 605
	return invalidArguments -- 604
end) -- 604
HttpServer:postSchedule("/git/history", function(req) -- 614
	do -- 615
		local _type_0 = type(req) -- 615
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 615
		if _tab_0 then -- 615
			local body = req.body -- 615
			if body ~= nil then -- 615
				local repoPath, limit = body.repoPath, body.limit -- 616
				limit = math.max(1, math.min(100, tonumber(limit) or 20)) -- 617
				return gitRunSync(repoPath, "log -n " .. tostring(limit), nil, 10) -- 618
			end -- 615
		end -- 615
	end -- 615
	return invalidArguments -- 614
end) -- 614
HttpServer:postSchedule("/git/remotes", function(req) -- 620
	do -- 621
		local _type_0 = type(req) -- 621
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 621
		if _tab_0 then -- 621
			local body = req.body -- 621
			if body ~= nil then -- 621
				local repoPath, command = body.repoPath, body.command -- 622
				command = command or "remote -v" -- 623
				return gitRunSync(repoPath, command, nil, 10) -- 624
			end -- 621
		end -- 621
	end -- 621
	return invalidArguments -- 620
end) -- 620
HttpServer:postSchedule("/git/branches", function(req) -- 626
	do -- 627
		local _type_0 = type(req) -- 627
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 627
		if _tab_0 then -- 627
			local body = req.body -- 627
			if body ~= nil then -- 627
				local repoPath, command = body.repoPath, body.command -- 628
				command = command or "branch" -- 629
				return gitRunSync(repoPath, command, nil, 10) -- 630
			end -- 627
		end -- 627
	end -- 627
	return invalidArguments -- 626
end) -- 626
HttpServer:postSchedule("/git/tags", function(req) -- 632
	do -- 633
		local _type_0 = type(req) -- 633
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 633
		if _tab_0 then -- 633
			local body = req.body -- 633
			if body ~= nil then -- 633
				local repoPath, command = body.repoPath, body.command -- 634
				command = command or "tag" -- 635
				return gitRunSync(repoPath, command, nil, 10) -- 636
			end -- 633
		end -- 633
	end -- 633
	return invalidArguments -- 632
end) -- 632
HttpServer:post("/git/profile/get", function() -- 638
	ensureGitTables() -- 639
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 640
	local profile -- 641
	if rows and rows[1] then -- 641
		profile = { -- 642
			name = rows[1][1], -- 642
			email = rows[1][2] -- 642
		} -- 642
	else -- 644
		profile = { -- 644
			name = "", -- 644
			email = "" -- 644
		} -- 644
	end -- 641
	return { -- 645
		success = true, -- 645
		profile = profile -- 645
	} -- 645
end) -- 638
HttpServer:post("/git/profile/save", function(req) -- 647
	do -- 648
		local _type_0 = type(req) -- 648
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 648
		if _tab_0 then -- 648
			local name -- 648
			do -- 648
				local _obj_0 = req.body -- 648
				local _type_1 = type(_obj_0) -- 648
				if "table" == _type_1 or "userdata" == _type_1 then -- 648
					name = _obj_0.name -- 648
				end -- 648
			end -- 648
			local email -- 648
			do -- 648
				local _obj_0 = req.body -- 648
				local _type_1 = type(_obj_0) -- 648
				if "table" == _type_1 or "userdata" == _type_1 then -- 648
					email = _obj_0.email -- 648
				end -- 648
			end -- 648
			if name ~= nil and email ~= nil then -- 648
				ensureGitTables() -- 649
				DB:exec("insert into GitProfile(id, name, email, updated_at) values(1, ?, ?, ?) on conflict(id) do update set name = excluded.name, email = excluded.email, updated_at = excluded.updated_at", { -- 651
					tostring(name or ""), -- 651
					tostring(email or ""), -- 652
					os.time() -- 653
				}) -- 650
				return { -- 655
					success = true -- 655
				} -- 655
			end -- 648
		end -- 648
	end -- 648
	return invalidArguments -- 647
end) -- 647
HttpServer:post("/git/auth/list", function(req) -- 657
	ensureGitTables() -- 658
	local host = nil -- 659
	do -- 660
		local _type_0 = type(req) -- 660
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 660
		if _tab_0 then -- 660
			local body = req.body -- 660
			if body ~= nil then -- 660
				host = body.host -- 661
			end -- 660
		end -- 660
	end -- 660
	local rows -- 662
	if host and host ~= "" then -- 662
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by host asc, label asc, id asc", { -- 663
			tostring(host):lower() -- 663
		}) -- 663
	else -- 665
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential order by host asc, label asc, id asc") -- 665
	end -- 662
	local items -- 666
	if rows then -- 666
		local _accum_0 = { } -- 667
		local _len_0 = 1 -- 667
		for _index_0 = 1, #rows do -- 667
			local row = rows[_index_0] -- 667
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 667
			_len_0 = _len_0 + 1 -- 667
		end -- 667
		items = _accum_0 -- 667
	else -- 668
		items = { } -- 668
	end -- 666
	return { -- 669
		success = true, -- 669
		items = items -- 669
	} -- 669
end) -- 657
HttpServer:postSchedule("/git/auth/match", function(req) -- 671
	do -- 672
		local _type_0 = type(req) -- 672
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 672
		local _match_0 = false -- 672
		if _tab_0 then -- 672
			local body = req.body -- 672
			if body ~= nil then -- 672
				_match_0 = true -- 672
				local repoPath, command, url = body.repoPath, body.command, body.url -- 673
				local host -- 674
				if url and url ~= "" then -- 674
					host = gitHostFromURL(url) -- 674
				else -- 674
					host = gitCommandHost(repoPath, command) -- 674
				end -- 674
				if not host then -- 675
					return { -- 675
						success = false, -- 675
						message = "git host is required" -- 675
					} -- 675
				end -- 675
				local items = gitCredentialsForHost(host) -- 676
				return { -- 677
					success = true, -- 677
					host = host, -- 677
					items = items, -- 677
					needsSelection = #items > 1, -- 677
					authId = (#items == 1 and items[1].id or nil) -- 677
				} -- 677
			end -- 672
		end -- 672
		if not _match_0 then -- 672
			return { -- 679
				success = false, -- 679
				message = "invalid arguments" -- 679
			} -- 679
		end -- 672
	end -- 672
	return invalidArguments -- 671
end) -- 671
HttpServer:post("/git/auth/save", function(req) -- 681
	do -- 682
		local _type_0 = type(req) -- 682
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 682
		if _tab_0 then -- 682
			local body = req.body -- 682
			if body ~= nil then -- 682
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token -- 683
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$") -- 684
				label = tostring(label or ""):match("^%s*(.-)%s*$") -- 685
				local credentialType = tostring(body.type or "token") -- 686
				username = tostring(username or "") -- 687
				local secret -- 688
				if credentialType == "basic" then -- 688
					secret = tostring(password or "") -- 688
				else -- 688
					secret = tostring(token or password or "") -- 688
				end -- 688
				if host == "" then -- 689
					return { -- 689
						success = false, -- 689
						message = "host is required" -- 689
					} -- 689
				end -- 689
				if label == "" then -- 690
					return { -- 690
						success = false, -- 690
						message = "label is required" -- 690
					} -- 690
				end -- 690
				if secret == "" then -- 691
					return { -- 691
						success = false, -- 691
						message = "secret is required" -- 691
					} -- 691
				end -- 691
				if not (("basic" == credentialType or "token" == credentialType)) then -- 692
					return { -- 692
						success = false, -- 692
						message = "invalid type" -- 692
					} -- 692
				end -- 692
				ensureGitTables() -- 693
				local now = os.time() -- 694
				if id then -- 695
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", { -- 697
						host, -- 697
						label, -- 697
						credentialType, -- 697
						username, -- 697
						secret, -- 697
						now, -- 697
						(tonumber(id) or 0) -- 697
					}) -- 696
					return { -- 699
						success = true, -- 699
						id = tonumber(id) -- 699
					} -- 699
				else -- 701
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", { -- 702
						host, -- 702
						label, -- 702
						credentialType, -- 702
						username, -- 702
						secret, -- 702
						now, -- 702
						now -- 702
					}) -- 701
					local rows = DB:query("select last_insert_rowid()") -- 704
					return { -- 705
						success = true, -- 705
						id = rows and rows[1] and rows[1][1] -- 705
					} -- 705
				end -- 695
			end -- 682
		end -- 682
	end -- 682
	return invalidArguments -- 681
end) -- 681
HttpServer:post("/git/auth/delete", function(req) -- 707
	do -- 708
		local _type_0 = type(req) -- 708
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 708
		if _tab_0 then -- 708
			local id -- 708
			do -- 708
				local _obj_0 = req.body -- 708
				local _type_1 = type(_obj_0) -- 708
				if "table" == _type_1 or "userdata" == _type_1 then -- 708
					id = _obj_0.id -- 708
				end -- 708
			end -- 708
			if id ~= nil then -- 708
				ensureGitTables() -- 709
				local credentialId = tonumber(id) or 0 -- 710
				DB:exec("delete from GitCredential where id = ?", { -- 711
					credentialId -- 711
				}) -- 711
				return { -- 712
					success = true -- 712
				} -- 712
			end -- 708
		end -- 708
	end -- 708
	return invalidArguments -- 707
end) -- 707
HttpServer:postSchedule("/git/auth/test", function(req) -- 714
	do -- 715
		local _type_0 = type(req) -- 715
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 715
		if _tab_0 then -- 715
			local body = req.body -- 715
			if body ~= nil then -- 715
				local repoPath, url, authId = body.repoPath, body.url, body.authId -- 716
				local credential = gitLoadCredential(authId) -- 717
				local optionsJSON = gitAuthOptionsJSON(credential) -- 718
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20) -- 719
			end -- 715
		end -- 715
	end -- 715
	return invalidArguments -- 714
end) -- 714
HttpServer:post("/agent/session/create", function(req) -- 721
	do -- 722
		local _type_0 = type(req) -- 722
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 722
		if _tab_0 then -- 722
			local projectRoot -- 722
			do -- 722
				local _obj_0 = req.body -- 722
				local _type_1 = type(_obj_0) -- 722
				if "table" == _type_1 or "userdata" == _type_1 then -- 722
					projectRoot = _obj_0.projectRoot -- 722
				end -- 722
			end -- 722
			local title -- 722
			do -- 722
				local _obj_0 = req.body -- 722
				local _type_1 = type(_obj_0) -- 722
				if "table" == _type_1 or "userdata" == _type_1 then -- 722
					title = _obj_0.title -- 722
				end -- 722
			end -- 722
			if projectRoot ~= nil and title ~= nil then -- 722
				return AgentSession.createSession(projectRoot, title) -- 723
			end -- 722
		end -- 722
	end -- 722
	return invalidArguments -- 721
end) -- 721
HttpServer:post("/agent/session/create-sub", function(req) -- 725
	do -- 726
		local _type_0 = type(req) -- 726
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 726
		if _tab_0 then -- 726
			local parentSessionId -- 726
			do -- 726
				local _obj_0 = req.body -- 726
				local _type_1 = type(_obj_0) -- 726
				if "table" == _type_1 or "userdata" == _type_1 then -- 726
					parentSessionId = _obj_0.parentSessionId -- 726
				end -- 726
			end -- 726
			local title -- 726
			do -- 726
				local _obj_0 = req.body -- 726
				local _type_1 = type(_obj_0) -- 726
				if "table" == _type_1 or "userdata" == _type_1 then -- 726
					title = _obj_0.title -- 726
				end -- 726
			end -- 726
			if parentSessionId ~= nil and title ~= nil then -- 726
				return AgentSession.createSubSession(parentSessionId, title) -- 727
			end -- 726
		end -- 726
	end -- 726
	return invalidArguments -- 725
end) -- 725
HttpServer:post("/agent/session/get", function(req) -- 729
	do -- 730
		local _type_0 = type(req) -- 730
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 730
		if _tab_0 then -- 730
			local sessionId -- 730
			do -- 730
				local _obj_0 = req.body -- 730
				local _type_1 = type(_obj_0) -- 730
				if "table" == _type_1 or "userdata" == _type_1 then -- 730
					sessionId = _obj_0.sessionId -- 730
				end -- 730
			end -- 730
			if sessionId ~= nil then -- 730
				return AgentSession.getSession(sessionId) -- 731
			end -- 730
		end -- 730
	end -- 730
	return invalidArguments -- 729
end) -- 729
HttpServer:post("/agent/session/send", function(req) -- 733
	do -- 734
		local _type_0 = type(req) -- 734
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 734
		if _tab_0 then -- 734
			local sessionId -- 734
			do -- 734
				local _obj_0 = req.body -- 734
				local _type_1 = type(_obj_0) -- 734
				if "table" == _type_1 or "userdata" == _type_1 then -- 734
					sessionId = _obj_0.sessionId -- 734
				end -- 734
			end -- 734
			local prompt -- 734
			do -- 734
				local _obj_0 = req.body -- 734
				local _type_1 = type(_obj_0) -- 734
				if "table" == _type_1 or "userdata" == _type_1 then -- 734
					prompt = _obj_0.prompt -- 734
				end -- 734
			end -- 734
			if sessionId ~= nil and prompt ~= nil then -- 734
				return AgentSession.sendPrompt(sessionId, prompt) -- 735
			end -- 734
		end -- 734
	end -- 734
	return invalidArguments -- 733
end) -- 733
HttpServer:post("/agent/session/resend", function(req) -- 737
	do -- 738
		local _type_0 = type(req) -- 738
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 738
		if _tab_0 then -- 738
			local sessionId -- 738
			do -- 738
				local _obj_0 = req.body -- 738
				local _type_1 = type(_obj_0) -- 738
				if "table" == _type_1 or "userdata" == _type_1 then -- 738
					sessionId = _obj_0.sessionId -- 738
				end -- 738
			end -- 738
			local messageId -- 738
			do -- 738
				local _obj_0 = req.body -- 738
				local _type_1 = type(_obj_0) -- 738
				if "table" == _type_1 or "userdata" == _type_1 then -- 738
					messageId = _obj_0.messageId -- 738
				end -- 738
			end -- 738
			local prompt -- 738
			do -- 738
				local _obj_0 = req.body -- 738
				local _type_1 = type(_obj_0) -- 738
				if "table" == _type_1 or "userdata" == _type_1 then -- 738
					prompt = _obj_0.prompt -- 738
				end -- 738
			end -- 738
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 738
				return AgentSession.resendPrompt(sessionId, messageId, prompt) -- 739
			end -- 738
		end -- 738
	end -- 738
	return invalidArguments -- 737
end) -- 737
HttpServer:post("/agent/task/status", function(req) -- 741
	do -- 742
		local _type_0 = type(req) -- 742
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 742
		if _tab_0 then -- 742
			local sessionId -- 742
			do -- 742
				local _obj_0 = req.body -- 742
				local _type_1 = type(_obj_0) -- 742
				if "table" == _type_1 or "userdata" == _type_1 then -- 742
					sessionId = _obj_0.sessionId -- 742
				end -- 742
			end -- 742
			if sessionId ~= nil then -- 742
				local res = AgentSession.getSession(sessionId) -- 743
				if not res.success then -- 744
					return res -- 744
				end -- 744
				local taskId = res.session.currentTaskId -- 745
				local checkpoints -- 746
				if taskId then -- 746
					checkpoints = AgentTools.listCheckpoints(taskId) -- 746
				else -- 746
					checkpoints = { } -- 746
				end -- 746
				return { -- 748
					success = true, -- 748
					session = res.session, -- 749
					relatedSessions = res.relatedSessions, -- 750
					spawnInfo = res.spawnInfo, -- 751
					messages = res.messages, -- 752
					steps = res.steps, -- 753
					checkpoints = checkpoints -- 754
				} -- 747
			end -- 742
		end -- 742
	end -- 742
	return invalidArguments -- 741
end) -- 741
HttpServer:post("/agent/task/running", function() -- 756
	local res = AgentSession.listRunningSessions() -- 757
	if res.success and #res.sessions == 0 then -- 758
		res.sessions = nil -- 759
	end -- 758
	return res -- 760
end) -- 756
HttpServer:post("/agent/task/stop", function(req) -- 762
	do -- 763
		local _type_0 = type(req) -- 763
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 763
		if _tab_0 then -- 763
			local sessionId -- 763
			do -- 763
				local _obj_0 = req.body -- 763
				local _type_1 = type(_obj_0) -- 763
				if "table" == _type_1 or "userdata" == _type_1 then -- 763
					sessionId = _obj_0.sessionId -- 763
				end -- 763
			end -- 763
			if sessionId ~= nil then -- 763
				return AgentSession.stopSessionTask(sessionId) -- 764
			end -- 763
		end -- 763
	end -- 763
	return invalidArguments -- 762
end) -- 762
HttpServer:post("/agent/checkpoint/list", function(req) -- 766
	do -- 767
		local _type_0 = type(req) -- 767
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 767
		if _tab_0 then -- 767
			local taskId -- 767
			do -- 767
				local _obj_0 = req.body -- 767
				local _type_1 = type(_obj_0) -- 767
				if "table" == _type_1 or "userdata" == _type_1 then -- 767
					taskId = _obj_0.taskId -- 767
				end -- 767
			end -- 767
			local sessionId -- 767
			do -- 767
				local _obj_0 = req.body -- 767
				local _type_1 = type(_obj_0) -- 767
				if "table" == _type_1 or "userdata" == _type_1 then -- 767
					sessionId = _obj_0.sessionId -- 767
				end -- 767
			end -- 767
			if sessionId ~= nil then -- 767
				if not taskId and sessionId then -- 768
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 769
				end -- 768
				if not taskId then -- 770
					return { -- 770
						success = false, -- 770
						message = "task not found" -- 770
					} -- 770
				end -- 770
				return { -- 772
					success = true, -- 772
					taskId = taskId, -- 773
					checkpoints = AgentTools.listCheckpoints(taskId) -- 774
				} -- 771
			end -- 767
		end -- 767
	end -- 767
	return invalidArguments -- 766
end) -- 766
HttpServer:post("/agent/checkpoint/diff", function(req) -- 776
	do -- 777
		local _type_0 = type(req) -- 777
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 777
		if _tab_0 then -- 777
			local checkpointId -- 777
			do -- 777
				local _obj_0 = req.body -- 777
				local _type_1 = type(_obj_0) -- 777
				if "table" == _type_1 or "userdata" == _type_1 then -- 777
					checkpointId = _obj_0.checkpointId -- 777
				end -- 777
			end -- 777
			if checkpointId ~= nil then -- 777
				if not (checkpointId > 0) then -- 778
					return { -- 778
						success = false, -- 778
						message = "invalid checkpointId" -- 778
					} -- 778
				end -- 778
				return AgentTools.getCheckpointDiff(checkpointId) -- 779
			end -- 777
		end -- 777
	end -- 777
	return invalidArguments -- 776
end) -- 776
HttpServer:post("/agent/task/diff", function(req) -- 781
	do -- 782
		local _type_0 = type(req) -- 782
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 782
		if _tab_0 then -- 782
			local taskId -- 782
			do -- 782
				local _obj_0 = req.body -- 782
				local _type_1 = type(_obj_0) -- 782
				if "table" == _type_1 or "userdata" == _type_1 then -- 782
					taskId = _obj_0.taskId -- 782
				end -- 782
			end -- 782
			if taskId ~= nil then -- 782
				if not (taskId > 0) then -- 783
					return { -- 783
						success = false, -- 783
						message = "invalid taskId" -- 783
					} -- 783
				end -- 783
				return AgentTools.getTaskChangeSetDiff(taskId) -- 784
			end -- 782
		end -- 782
	end -- 782
	return invalidArguments -- 781
end) -- 781
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 786
	do -- 787
		local _type_0 = type(req) -- 787
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 787
		if _tab_0 then -- 787
			local sessionId -- 787
			do -- 787
				local _obj_0 = req.body -- 787
				local _type_1 = type(_obj_0) -- 787
				if "table" == _type_1 or "userdata" == _type_1 then -- 787
					sessionId = _obj_0.sessionId -- 787
				end -- 787
			end -- 787
			local checkpointId -- 787
			do -- 787
				local _obj_0 = req.body -- 787
				local _type_1 = type(_obj_0) -- 787
				if "table" == _type_1 or "userdata" == _type_1 then -- 787
					checkpointId = _obj_0.checkpointId -- 787
				end -- 787
			end -- 787
			if sessionId ~= nil and checkpointId ~= nil then -- 787
				if not (checkpointId > 0) then -- 788
					return { -- 788
						success = false, -- 788
						message = "invalid checkpointId" -- 788
					} -- 788
				end -- 788
				local res = AgentSession.getSession(sessionId) -- 789
				if not res.success then -- 790
					return res -- 790
				end -- 790
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, res.session.projectRoot) -- 791
				if not rollbackRes.success then -- 792
					return rollbackRes -- 792
				end -- 792
				return { -- 794
					success = true, -- 794
					checkpointId = rollbackRes.checkpointId -- 795
				} -- 793
			end -- 787
		end -- 787
	end -- 787
	return invalidArguments -- 786
end) -- 786
HttpServer:post("/agent/task/rollback", function(req) -- 797
	do -- 798
		local _type_0 = type(req) -- 798
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 798
		if _tab_0 then -- 798
			local sessionId -- 798
			do -- 798
				local _obj_0 = req.body -- 798
				local _type_1 = type(_obj_0) -- 798
				if "table" == _type_1 or "userdata" == _type_1 then -- 798
					sessionId = _obj_0.sessionId -- 798
				end -- 798
			end -- 798
			local taskId -- 798
			do -- 798
				local _obj_0 = req.body -- 798
				local _type_1 = type(_obj_0) -- 798
				if "table" == _type_1 or "userdata" == _type_1 then -- 798
					taskId = _obj_0.taskId -- 798
				end -- 798
			end -- 798
			if sessionId ~= nil and taskId ~= nil then -- 798
				if not (taskId > 0) then -- 799
					return { -- 799
						success = false, -- 799
						message = "invalid taskId" -- 799
					} -- 799
				end -- 799
				local res = AgentSession.getSession(sessionId) -- 800
				if not res.success then -- 801
					return res -- 801
				end -- 801
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, res.session.projectRoot) -- 802
				if not rollbackRes.success then -- 803
					return rollbackRes -- 803
				end -- 803
				return { -- 805
					success = true, -- 805
					taskId = rollbackRes.taskId, -- 806
					checkpointId = rollbackRes.checkpointId, -- 807
					checkpointCount = rollbackRes.checkpointCount -- 808
				} -- 804
			end -- 798
		end -- 798
	end -- 798
	return invalidArguments -- 797
end) -- 797
local getSearchPath -- 810
getSearchPath = function(file) -- 810
	do -- 811
		local dir = getProjectDirFromFile(file) -- 811
		if dir then -- 811
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 812
		end -- 811
	end -- 811
	return "" -- 810
end -- 810
local getSearchFolders -- 814
getSearchFolders = function(file) -- 814
	do -- 815
		local dir = getProjectDirFromFile(file) -- 815
		if dir then -- 815
			return { -- 817
				Path(dir, "Script"), -- 817
				dir -- 818
			} -- 816
		end -- 815
	end -- 815
	return { } -- 814
end -- 814
local disabledCheckForLua = { -- 821
	"incompatible number of returns", -- 821
	"unknown", -- 822
	"cannot index", -- 823
	"module not found", -- 824
	"don't know how to resolve", -- 825
	"ContainerItem", -- 826
	"cannot resolve a type", -- 827
	"invalid key", -- 828
	"inconsistent index type", -- 829
	"cannot use operator", -- 830
	"attempting ipairs loop", -- 831
	"expects record or nominal", -- 832
	"variable is not being assigned", -- 833
	"<invalid type>", -- 834
	"<any type>", -- 835
	"using the '#' operator", -- 836
	"can't match a record", -- 837
	"redeclaration of variable", -- 838
	"cannot apply pairs", -- 839
	"not a function", -- 840
	"to%-be%-closed" -- 841
} -- 820
local yueCheck -- 843
yueCheck = function(file, content, lax) -- 843
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 844
	if isTIC80 then -- 845
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 846
	end -- 845
	local searchPath = getSearchPath(file) -- 847
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 848
	local info = { } -- 849
	local globals = { } -- 850
	for _index_0 = 1, #checkResult do -- 851
		local _des_0 = checkResult[_index_0] -- 851
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 851
		if "error" == t then -- 852
			info[#info + 1] = { -- 853
				"syntax", -- 853
				file, -- 853
				line, -- 853
				col, -- 853
				msg -- 853
			} -- 853
		elseif "global" == t then -- 854
			globals[#globals + 1] = { -- 855
				msg, -- 855
				line, -- 855
				col -- 855
			} -- 855
		end -- 852
	end -- 851
	if luaCodes then -- 856
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 857
		if success then -- 858
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 859
			if not (lintResult == "") then -- 860
				lintResult = lintResult .. "\n" -- 860
			end -- 860
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 861
		else -- 862
			for _index_0 = 1, #lintResult do -- 862
				local _des_0 = lintResult[_index_0] -- 862
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 862
				if isTIC80 and tic80APIs[name] then -- 863
					goto _continue_0 -- 863
				end -- 863
				info[#info + 1] = { -- 864
					"syntax", -- 864
					file, -- 864
					line, -- 864
					col, -- 864
					"invalid global variable" -- 864
				} -- 864
				::_continue_0:: -- 863
			end -- 862
		end -- 858
	end -- 856
	return luaCodes, info -- 865
end -- 843
local luaCheck -- 867
luaCheck = function(file, content) -- 867
	local res, err = load(content, "check") -- 868
	if not res then -- 869
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 870
		return { -- 871
			success = false, -- 871
			info = { -- 871
				{ -- 871
					"syntax", -- 871
					file, -- 871
					tonumber(line), -- 871
					0, -- 871
					msg -- 871
				} -- 871
			} -- 871
		} -- 871
	end -- 869
	local success, info = teal.checkAsync(content, file, true, "") -- 872
	if info then -- 873
		do -- 874
			local _accum_0 = { } -- 874
			local _len_0 = 1 -- 874
			for _index_0 = 1, #info do -- 874
				local item = info[_index_0] -- 874
				local useCheck = true -- 875
				if not item[5]:match("unused") then -- 876
					for _index_1 = 1, #disabledCheckForLua do -- 877
						local check = disabledCheckForLua[_index_1] -- 877
						if item[5]:match(check) then -- 878
							useCheck = false -- 879
						end -- 878
					end -- 877
				end -- 876
				if not useCheck then -- 880
					goto _continue_0 -- 880
				end -- 880
				do -- 881
					local _exp_0 = item[1] -- 881
					if "type" == _exp_0 then -- 882
						item[1] = "warning" -- 883
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 884
						goto _continue_0 -- 885
					end -- 881
				end -- 881
				_accum_0[_len_0] = item -- 886
				_len_0 = _len_0 + 1 -- 875
				::_continue_0:: -- 875
			end -- 874
			info = _accum_0 -- 874
		end -- 874
		if #info == 0 then -- 887
			info = nil -- 888
			success = true -- 889
		end -- 887
	end -- 873
	return { -- 890
		success = success, -- 890
		info = info -- 890
	} -- 890
end -- 867
local luaCheckWithLineInfo -- 892
luaCheckWithLineInfo = function(file, luaCodes) -- 892
	local res = luaCheck(file, luaCodes) -- 893
	local info = { } -- 894
	if not res.success then -- 895
		local current = 1 -- 896
		local lastLine = 1 -- 897
		local lineMap = { } -- 898
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 899
			local num = lineCode:match("--%s*(%d+)%s*$") -- 900
			if num then -- 901
				lastLine = tonumber(num) -- 902
			end -- 901
			lineMap[current] = lastLine -- 903
			current = current + 1 -- 904
		end -- 899
		local _list_0 = res.info -- 905
		for _index_0 = 1, #_list_0 do -- 905
			local item = _list_0[_index_0] -- 905
			item[3] = lineMap[item[3]] or 0 -- 906
			item[4] = 0 -- 907
			info[#info + 1] = item -- 908
		end -- 905
		return false, info -- 909
	end -- 895
	return true, info -- 910
end -- 892
local getCompiledYueLine -- 912
getCompiledYueLine = function(content, line, row, file, lax) -- 912
	local luaCodes = yueCheck(file, content, lax) -- 913
	if not luaCodes then -- 914
		return nil -- 914
	end -- 914
	local current = 1 -- 915
	local lastLine = 1 -- 916
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 917
	local targetRow = nil -- 918
	local lineMap = { } -- 919
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 920
		local num = lineCode:match("--%s*(%d+)%s*$") -- 921
		if num then -- 922
			lastLine = tonumber(num) -- 922
		end -- 922
		lineMap[current] = lastLine -- 923
		if row <= lastLine and not targetRow then -- 924
			targetRow = current -- 925
			break -- 926
		end -- 924
		current = current + 1 -- 927
	end -- 920
	targetRow = current -- 928
	if targetLine and targetRow then -- 929
		return luaCodes, targetLine, targetRow, lineMap -- 930
	else -- 932
		return nil -- 932
	end -- 929
end -- 912
HttpServer:postSchedule("/check", function(req) -- 934
	do -- 935
		local _type_0 = type(req) -- 935
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 935
		if _tab_0 then -- 935
			local file -- 935
			do -- 935
				local _obj_0 = req.body -- 935
				local _type_1 = type(_obj_0) -- 935
				if "table" == _type_1 or "userdata" == _type_1 then -- 935
					file = _obj_0.file -- 935
				end -- 935
			end -- 935
			local content -- 935
			do -- 935
				local _obj_0 = req.body -- 935
				local _type_1 = type(_obj_0) -- 935
				if "table" == _type_1 or "userdata" == _type_1 then -- 935
					content = _obj_0.content -- 935
				end -- 935
			end -- 935
			if file ~= nil and content ~= nil then -- 935
				local ext = Path:getExt(file) -- 936
				if "tl" == ext then -- 937
					local searchPath = getSearchPath(file) -- 938
					do -- 939
						local isTIC80 = CheckTIC80Code(content) -- 939
						if isTIC80 then -- 939
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 940
						end -- 939
					end -- 939
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 941
					return { -- 942
						success = success, -- 942
						info = info -- 942
					} -- 942
				elseif "lua" == ext then -- 943
					do -- 944
						local isTIC80 = CheckTIC80Code(content) -- 944
						if isTIC80 then -- 944
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 945
						end -- 944
					end -- 944
					return luaCheck(file, content) -- 946
				elseif "yue" == ext then -- 947
					local luaCodes, info = yueCheck(file, content, false) -- 948
					local success = false -- 949
					if luaCodes then -- 950
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 951
						do -- 952
							local _tab_1 = { } -- 952
							local _idx_0 = #_tab_1 + 1 -- 952
							for _index_0 = 1, #info do -- 952
								local _value_0 = info[_index_0] -- 952
								_tab_1[_idx_0] = _value_0 -- 952
								_idx_0 = _idx_0 + 1 -- 952
							end -- 952
							local _idx_1 = #_tab_1 + 1 -- 952
							for _index_0 = 1, #luaInfo do -- 952
								local _value_0 = luaInfo[_index_0] -- 952
								_tab_1[_idx_1] = _value_0 -- 952
								_idx_1 = _idx_1 + 1 -- 952
							end -- 952
							info = _tab_1 -- 952
						end -- 952
						success = success and luaSuccess -- 953
					end -- 950
					if #info > 0 then -- 954
						return { -- 955
							success = success, -- 955
							info = info -- 955
						} -- 955
					else -- 957
						return { -- 957
							success = success -- 957
						} -- 957
					end -- 954
				elseif "xml" == ext then -- 958
					local success, result = xml.check(content) -- 959
					if success then -- 960
						local info -- 961
						success, info = luaCheckWithLineInfo(file, result) -- 961
						if #info > 0 then -- 962
							return { -- 963
								success = success, -- 963
								info = info -- 963
							} -- 963
						else -- 965
							return { -- 965
								success = success -- 965
							} -- 965
						end -- 962
					else -- 967
						local info -- 967
						do -- 967
							local _accum_0 = { } -- 967
							local _len_0 = 1 -- 967
							for _index_0 = 1, #result do -- 967
								local _des_0 = result[_index_0] -- 967
								local row, err = _des_0[1], _des_0[2] -- 967
								_accum_0[_len_0] = { -- 968
									"syntax", -- 968
									file, -- 968
									row, -- 968
									0, -- 968
									err -- 968
								} -- 968
								_len_0 = _len_0 + 1 -- 968
							end -- 967
							info = _accum_0 -- 967
						end -- 967
						return { -- 969
							success = false, -- 969
							info = info -- 969
						} -- 969
					end -- 960
				end -- 937
			end -- 935
		end -- 935
	end -- 935
	return { -- 934
		success = true -- 934
	} -- 934
end) -- 934
HttpServer:post("/body/parse", function(req) -- 971
	do -- 972
		local _type_0 = type(req) -- 972
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 972
		if _tab_0 then -- 972
			local file -- 972
			do -- 972
				local _obj_0 = req.body -- 972
				local _type_1 = type(_obj_0) -- 972
				if "table" == _type_1 or "userdata" == _type_1 then -- 972
					file = _obj_0.file -- 972
				end -- 972
			end -- 972
			local content -- 972
			do -- 972
				local _obj_0 = req.body -- 972
				local _type_1 = type(_obj_0) -- 972
				if "table" == _type_1 or "userdata" == _type_1 then -- 972
					content = _obj_0.content -- 972
				end -- 972
			end -- 972
			if file ~= nil and content ~= nil then -- 972
				if not (file:sub(-6) == ".b.lua") then -- 973
					return { -- 974
						success = false, -- 974
						phase = "request", -- 974
						message = "only .b.lua files can be converted" -- 974
					} -- 974
				end -- 973
				local loader, err = load("_ENV = {}\n" .. content) -- 975
				if not loader then -- 976
					return { -- 977
						success = false, -- 977
						phase = "parse", -- 977
						message = tostring(err) -- 977
					} -- 977
				end -- 976
				local ok, data = pcall(loader) -- 978
				if not ok then -- 979
					return { -- 980
						success = false, -- 980
						phase = "execute", -- 980
						message = tostring(data) -- 980
					} -- 980
				end -- 979
				if not ("table" == type(data) and data[1] == "Array") then -- 981
					return { -- 982
						success = false, -- 982
						phase = "validate", -- 982
						message = "body lua root must be {\"Array\", ...}" -- 982
					} -- 982
				end -- 981
				local text, jsonErr = json.encode(data, false, true) -- 983
				if not text then -- 984
					return { -- 985
						success = false, -- 985
						phase = "encode", -- 985
						message = tostring(jsonErr) -- 985
					} -- 985
				end -- 984
				return { -- 986
					success = true, -- 986
					json = text -- 986
				} -- 986
			end -- 972
		end -- 972
	end -- 972
	return { -- 971
		success = false, -- 971
		phase = "request", -- 971
		message = "invalid request" -- 971
	} -- 971
end) -- 971
local updateInferedDesc -- 988
updateInferedDesc = function(infered) -- 988
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 989
		return -- 989
	end -- 989
	local key, row = infered.key, infered.row -- 990
	local codes = Content:loadAsync(key) -- 991
	if codes then -- 991
		local comments = { } -- 992
		local line = 0 -- 993
		local skipping = false -- 994
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 995
			line = line + 1 -- 996
			if line >= row then -- 997
				break -- 997
			end -- 997
			if lineCode:match("^%s*%-%- @") then -- 998
				skipping = true -- 999
				goto _continue_0 -- 1000
			end -- 998
			local result = lineCode:match("^%s*%-%- (.+)") -- 1001
			if result then -- 1001
				if not skipping then -- 1002
					comments[#comments + 1] = result -- 1002
				end -- 1002
			elseif #comments > 0 then -- 1003
				comments = { } -- 1004
				skipping = false -- 1005
			end -- 1001
			::_continue_0:: -- 996
		end -- 995
		infered.doc = table.concat(comments, "\n") -- 1006
	end -- 991
end -- 988
HttpServer:postSchedule("/infer", function(req) -- 1008
	do -- 1009
		local _type_0 = type(req) -- 1009
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1009
		if _tab_0 then -- 1009
			local lang -- 1009
			do -- 1009
				local _obj_0 = req.body -- 1009
				local _type_1 = type(_obj_0) -- 1009
				if "table" == _type_1 or "userdata" == _type_1 then -- 1009
					lang = _obj_0.lang -- 1009
				end -- 1009
			end -- 1009
			local file -- 1009
			do -- 1009
				local _obj_0 = req.body -- 1009
				local _type_1 = type(_obj_0) -- 1009
				if "table" == _type_1 or "userdata" == _type_1 then -- 1009
					file = _obj_0.file -- 1009
				end -- 1009
			end -- 1009
			local content -- 1009
			do -- 1009
				local _obj_0 = req.body -- 1009
				local _type_1 = type(_obj_0) -- 1009
				if "table" == _type_1 or "userdata" == _type_1 then -- 1009
					content = _obj_0.content -- 1009
				end -- 1009
			end -- 1009
			local line -- 1009
			do -- 1009
				local _obj_0 = req.body -- 1009
				local _type_1 = type(_obj_0) -- 1009
				if "table" == _type_1 or "userdata" == _type_1 then -- 1009
					line = _obj_0.line -- 1009
				end -- 1009
			end -- 1009
			local row -- 1009
			do -- 1009
				local _obj_0 = req.body -- 1009
				local _type_1 = type(_obj_0) -- 1009
				if "table" == _type_1 or "userdata" == _type_1 then -- 1009
					row = _obj_0.row -- 1009
				end -- 1009
			end -- 1009
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1009
				local searchPath = getSearchPath(file) -- 1010
				if "tl" == lang or "lua" == lang then -- 1011
					if CheckTIC80Code(content) then -- 1012
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1013
					end -- 1012
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1014
					if (infered ~= nil) then -- 1015
						updateInferedDesc(infered) -- 1016
						return { -- 1017
							success = true, -- 1017
							infered = infered -- 1017
						} -- 1017
					end -- 1015
				elseif "yue" == lang then -- 1018
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1019
					if not luaCodes then -- 1020
						return { -- 1020
							success = false -- 1020
						} -- 1020
					end -- 1020
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1021
					if (infered ~= nil) then -- 1022
						local col -- 1023
						file, row, col = infered.file, infered.row, infered.col -- 1023
						if file == "" and row > 0 and col > 0 then -- 1024
							infered.row = lineMap[row] or 0 -- 1025
							infered.col = 0 -- 1026
						end -- 1024
						updateInferedDesc(infered) -- 1027
						return { -- 1028
							success = true, -- 1028
							infered = infered -- 1028
						} -- 1028
					end -- 1022
				end -- 1011
			end -- 1009
		end -- 1009
	end -- 1009
	return { -- 1008
		success = false -- 1008
	} -- 1008
end) -- 1008
local _anon_func_3 = function(doc) -- 1079
	local _accum_0 = { } -- 1079
	local _len_0 = 1 -- 1079
	local _list_0 = doc.params -- 1079
	for _index_0 = 1, #_list_0 do -- 1079
		local param = _list_0[_index_0] -- 1079
		_accum_0[_len_0] = param.name -- 1079
		_len_0 = _len_0 + 1 -- 1079
	end -- 1079
	return _accum_0 -- 1079
end -- 1079
local getParamDocs -- 1030
getParamDocs = function(signatures) -- 1030
	do -- 1031
		local codes = Content:loadAsync(signatures[1].file) -- 1031
		if codes then -- 1031
			local comments = { } -- 1032
			local params = { } -- 1033
			local line = 0 -- 1034
			local docs = { } -- 1035
			local returnType = nil -- 1036
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1037
				line = line + 1 -- 1038
				local needBreak = true -- 1039
				for i, _des_0 in ipairs(signatures) do -- 1040
					local row = _des_0.row -- 1040
					if line >= row and not (docs[i] ~= nil) then -- 1041
						if #comments > 0 or #params > 0 or returnType then -- 1042
							docs[i] = { -- 1044
								doc = table.concat(comments, "  \n"), -- 1044
								returnType = returnType -- 1045
							} -- 1043
							if #params > 0 then -- 1047
								docs[i].params = params -- 1047
							end -- 1047
						else -- 1049
							docs[i] = false -- 1049
						end -- 1042
					end -- 1041
					if not docs[i] then -- 1050
						needBreak = false -- 1050
					end -- 1050
				end -- 1040
				if needBreak then -- 1051
					break -- 1051
				end -- 1051
				local result = lineCode:match("%s*%-%- (.+)") -- 1052
				if result then -- 1052
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1053
					if not name then -- 1054
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1055
					end -- 1054
					if name then -- 1056
						local pname = name -- 1057
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1058
							pname = pname .. "?" -- 1058
						end -- 1058
						params[#params + 1] = { -- 1060
							name = tostring(pname) .. ": " .. tostring(typ), -- 1060
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1061
						} -- 1059
					else -- 1064
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1064
						if typ then -- 1064
							if returnType then -- 1065
								returnType = returnType .. ", " .. typ -- 1066
							else -- 1068
								returnType = typ -- 1068
							end -- 1065
							result = result:gsub("@return", "**return:**") -- 1069
						end -- 1064
						comments[#comments + 1] = result -- 1070
					end -- 1056
				elseif #comments > 0 then -- 1071
					comments = { } -- 1072
					params = { } -- 1073
					returnType = nil -- 1074
				end -- 1052
			end -- 1037
			local results = { } -- 1075
			for _index_0 = 1, #docs do -- 1076
				local doc = docs[_index_0] -- 1076
				if not doc then -- 1077
					goto _continue_0 -- 1077
				end -- 1077
				if doc.params then -- 1078
					doc.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1079
				else -- 1081
					doc.desc = "function()" -- 1081
				end -- 1078
				if doc.returnType then -- 1082
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 1083
					doc.returnType = nil -- 1084
				end -- 1082
				results[#results + 1] = doc -- 1085
				::_continue_0:: -- 1077
			end -- 1076
			if #results > 0 then -- 1086
				return results -- 1086
			else -- 1086
				return nil -- 1086
			end -- 1086
		end -- 1031
	end -- 1031
	return nil -- 1030
end -- 1030
HttpServer:postSchedule("/signature", function(req) -- 1088
	do -- 1089
		local _type_0 = type(req) -- 1089
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1089
		if _tab_0 then -- 1089
			local lang -- 1089
			do -- 1089
				local _obj_0 = req.body -- 1089
				local _type_1 = type(_obj_0) -- 1089
				if "table" == _type_1 or "userdata" == _type_1 then -- 1089
					lang = _obj_0.lang -- 1089
				end -- 1089
			end -- 1089
			local file -- 1089
			do -- 1089
				local _obj_0 = req.body -- 1089
				local _type_1 = type(_obj_0) -- 1089
				if "table" == _type_1 or "userdata" == _type_1 then -- 1089
					file = _obj_0.file -- 1089
				end -- 1089
			end -- 1089
			local content -- 1089
			do -- 1089
				local _obj_0 = req.body -- 1089
				local _type_1 = type(_obj_0) -- 1089
				if "table" == _type_1 or "userdata" == _type_1 then -- 1089
					content = _obj_0.content -- 1089
				end -- 1089
			end -- 1089
			local line -- 1089
			do -- 1089
				local _obj_0 = req.body -- 1089
				local _type_1 = type(_obj_0) -- 1089
				if "table" == _type_1 or "userdata" == _type_1 then -- 1089
					line = _obj_0.line -- 1089
				end -- 1089
			end -- 1089
			local row -- 1089
			do -- 1089
				local _obj_0 = req.body -- 1089
				local _type_1 = type(_obj_0) -- 1089
				if "table" == _type_1 or "userdata" == _type_1 then -- 1089
					row = _obj_0.row -- 1089
				end -- 1089
			end -- 1089
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1089
				local searchPath = getSearchPath(file) -- 1090
				if "tl" == lang or "lua" == lang then -- 1091
					if CheckTIC80Code(content) then -- 1092
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1093
					end -- 1092
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1094
					if signatures then -- 1094
						signatures = getParamDocs(signatures) -- 1095
						if signatures then -- 1095
							return { -- 1096
								success = true, -- 1096
								signatures = signatures -- 1096
							} -- 1096
						end -- 1095
					end -- 1094
				elseif "yue" == lang then -- 1097
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1098
					if not luaCodes then -- 1099
						return { -- 1099
							success = false -- 1099
						} -- 1099
					end -- 1099
					do -- 1100
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1100
						if chainOp then -- 1100
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1101
							if withVar then -- 1101
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1102
							end -- 1101
						end -- 1100
					end -- 1100
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1103
					if signatures then -- 1103
						signatures = getParamDocs(signatures) -- 1104
						if signatures then -- 1104
							return { -- 1105
								success = true, -- 1105
								signatures = signatures -- 1105
							} -- 1105
						end -- 1104
					else -- 1106
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1106
						if signatures then -- 1106
							signatures = getParamDocs(signatures) -- 1107
							if signatures then -- 1107
								return { -- 1108
									success = true, -- 1108
									signatures = signatures -- 1108
								} -- 1108
							end -- 1107
						end -- 1106
					end -- 1103
				end -- 1091
			end -- 1089
		end -- 1089
	end -- 1089
	return { -- 1088
		success = false -- 1088
	} -- 1088
end) -- 1088
local luaKeywords = { -- 1111
	'and', -- 1111
	'break', -- 1112
	'do', -- 1113
	'else', -- 1114
	'elseif', -- 1115
	'end', -- 1116
	'false', -- 1117
	'for', -- 1118
	'function', -- 1119
	'goto', -- 1120
	'if', -- 1121
	'in', -- 1122
	'local', -- 1123
	'nil', -- 1124
	'not', -- 1125
	'or', -- 1126
	'repeat', -- 1127
	'return', -- 1128
	'then', -- 1129
	'true', -- 1130
	'until', -- 1131
	'while' -- 1132
} -- 1110
local tealKeywords = { -- 1136
	'record', -- 1136
	'as', -- 1137
	'is', -- 1138
	'type', -- 1139
	'embed', -- 1140
	'enum', -- 1141
	'global', -- 1142
	'any', -- 1143
	'boolean', -- 1144
	'integer', -- 1145
	'number', -- 1146
	'string', -- 1147
	'thread' -- 1148
} -- 1135
local yueKeywords = { -- 1152
	"and", -- 1152
	"break", -- 1153
	"do", -- 1154
	"else", -- 1155
	"elseif", -- 1156
	"false", -- 1157
	"for", -- 1158
	"goto", -- 1159
	"if", -- 1160
	"in", -- 1161
	"local", -- 1162
	"nil", -- 1163
	"not", -- 1164
	"or", -- 1165
	"repeat", -- 1166
	"return", -- 1167
	"then", -- 1168
	"true", -- 1169
	"until", -- 1170
	"while", -- 1171
	"as", -- 1172
	"class", -- 1173
	"continue", -- 1174
	"export", -- 1175
	"extends", -- 1176
	"from", -- 1177
	"global", -- 1178
	"import", -- 1179
	"macro", -- 1180
	"switch", -- 1181
	"try", -- 1182
	"unless", -- 1183
	"using", -- 1184
	"when", -- 1185
	"with" -- 1186
} -- 1151
local _anon_func_4 = function(f) -- 1222
	local _val_0 = Path:getExt(f) -- 1222
	return "ttf" == _val_0 or "otf" == _val_0 -- 1222
end -- 1222
local _anon_func_5 = function(suggestions) -- 1248
	local _tbl_0 = { } -- 1248
	for _index_0 = 1, #suggestions do -- 1248
		local item = suggestions[_index_0] -- 1248
		_tbl_0[item[1] .. item[2]] = item -- 1248
	end -- 1248
	return _tbl_0 -- 1248
end -- 1248
HttpServer:postSchedule("/complete", function(req) -- 1189
	do -- 1190
		local _type_0 = type(req) -- 1190
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1190
		if _tab_0 then -- 1190
			local lang -- 1190
			do -- 1190
				local _obj_0 = req.body -- 1190
				local _type_1 = type(_obj_0) -- 1190
				if "table" == _type_1 or "userdata" == _type_1 then -- 1190
					lang = _obj_0.lang -- 1190
				end -- 1190
			end -- 1190
			local file -- 1190
			do -- 1190
				local _obj_0 = req.body -- 1190
				local _type_1 = type(_obj_0) -- 1190
				if "table" == _type_1 or "userdata" == _type_1 then -- 1190
					file = _obj_0.file -- 1190
				end -- 1190
			end -- 1190
			local content -- 1190
			do -- 1190
				local _obj_0 = req.body -- 1190
				local _type_1 = type(_obj_0) -- 1190
				if "table" == _type_1 or "userdata" == _type_1 then -- 1190
					content = _obj_0.content -- 1190
				end -- 1190
			end -- 1190
			local line -- 1190
			do -- 1190
				local _obj_0 = req.body -- 1190
				local _type_1 = type(_obj_0) -- 1190
				if "table" == _type_1 or "userdata" == _type_1 then -- 1190
					line = _obj_0.line -- 1190
				end -- 1190
			end -- 1190
			local row -- 1190
			do -- 1190
				local _obj_0 = req.body -- 1190
				local _type_1 = type(_obj_0) -- 1190
				if "table" == _type_1 or "userdata" == _type_1 then -- 1190
					row = _obj_0.row -- 1190
				end -- 1190
			end -- 1190
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1190
				local searchPath = getSearchPath(file) -- 1191
				repeat -- 1192
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1193
					if lang == "yue" then -- 1194
						if not item then -- 1195
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1195
						end -- 1195
						if not item then -- 1196
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1196
						end -- 1196
					end -- 1194
					local searchType = nil -- 1197
					if not item then -- 1198
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1199
						if lang == "yue" then -- 1200
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1201
						end -- 1200
						if (item ~= nil) then -- 1202
							searchType = "Image" -- 1202
						end -- 1202
					end -- 1198
					if not item then -- 1203
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1204
						if lang == "yue" then -- 1205
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1206
						end -- 1205
						if (item ~= nil) then -- 1207
							searchType = "Font" -- 1207
						end -- 1207
					end -- 1203
					if not item then -- 1208
						break -- 1208
					end -- 1208
					local searchPaths = Content.searchPaths -- 1209
					local _list_0 = getSearchFolders(file) -- 1210
					for _index_0 = 1, #_list_0 do -- 1210
						local folder = _list_0[_index_0] -- 1210
						searchPaths[#searchPaths + 1] = folder -- 1211
					end -- 1210
					if searchType then -- 1212
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1212
					end -- 1212
					local tokens -- 1213
					do -- 1213
						local _accum_0 = { } -- 1213
						local _len_0 = 1 -- 1213
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1213
							_accum_0[_len_0] = mod -- 1213
							_len_0 = _len_0 + 1 -- 1213
						end -- 1213
						tokens = _accum_0 -- 1213
					end -- 1213
					local suggestions = { } -- 1214
					for _index_0 = 1, #searchPaths do -- 1215
						local path = searchPaths[_index_0] -- 1215
						local sPath = Path(path, table.unpack(tokens)) -- 1216
						if not Content:exist(sPath) then -- 1217
							goto _continue_0 -- 1217
						end -- 1217
						if searchType == "Font" then -- 1218
							local fontPath = Path(sPath, "Font") -- 1219
							if Content:exist(fontPath) then -- 1220
								local _list_1 = Content:getFiles(fontPath) -- 1221
								for _index_1 = 1, #_list_1 do -- 1221
									local f = _list_1[_index_1] -- 1221
									if _anon_func_4(f) then -- 1222
										if "." == f:sub(1, 1) then -- 1223
											goto _continue_1 -- 1223
										end -- 1223
										suggestions[#suggestions + 1] = { -- 1224
											Path:getName(f), -- 1224
											"font", -- 1224
											"field" -- 1224
										} -- 1224
									end -- 1222
									::_continue_1:: -- 1222
								end -- 1221
							end -- 1220
						end -- 1218
						local _list_1 = Content:getFiles(sPath) -- 1225
						for _index_1 = 1, #_list_1 do -- 1225
							local f = _list_1[_index_1] -- 1225
							if "Image" == searchType then -- 1226
								do -- 1227
									local _exp_0 = Path:getExt(f) -- 1227
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1227
										if "." == f:sub(1, 1) then -- 1228
											goto _continue_2 -- 1228
										end -- 1228
										suggestions[#suggestions + 1] = { -- 1229
											f, -- 1229
											"image", -- 1229
											"field" -- 1229
										} -- 1229
									end -- 1227
								end -- 1227
								goto _continue_2 -- 1230
							elseif "Font" == searchType then -- 1231
								do -- 1232
									local _exp_0 = Path:getExt(f) -- 1232
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1232
										if "." == f:sub(1, 1) then -- 1233
											goto _continue_2 -- 1233
										end -- 1233
										suggestions[#suggestions + 1] = { -- 1234
											f, -- 1234
											"font", -- 1234
											"field" -- 1234
										} -- 1234
									end -- 1232
								end -- 1232
								goto _continue_2 -- 1235
							end -- 1226
							local _exp_0 = Path:getExt(f) -- 1236
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1236
								local name = Path:getName(f) -- 1237
								if "d" == Path:getExt(name) then -- 1238
									goto _continue_2 -- 1238
								end -- 1238
								if "." == name:sub(1, 1) then -- 1239
									goto _continue_2 -- 1239
								end -- 1239
								suggestions[#suggestions + 1] = { -- 1240
									name, -- 1240
									"module", -- 1240
									"field" -- 1240
								} -- 1240
							end -- 1236
							::_continue_2:: -- 1226
						end -- 1225
						local _list_2 = Content:getDirs(sPath) -- 1241
						for _index_1 = 1, #_list_2 do -- 1241
							local dir = _list_2[_index_1] -- 1241
							if "." == dir:sub(1, 1) then -- 1242
								goto _continue_3 -- 1242
							end -- 1242
							suggestions[#suggestions + 1] = { -- 1243
								dir, -- 1243
								"folder", -- 1243
								"variable" -- 1243
							} -- 1243
							::_continue_3:: -- 1242
						end -- 1241
						::_continue_0:: -- 1216
					end -- 1215
					if item == "" and not searchType then -- 1244
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1245
						for _index_0 = 1, #_list_1 do -- 1245
							local _des_0 = _list_1[_index_0] -- 1245
							local name = _des_0[1] -- 1245
							suggestions[#suggestions + 1] = { -- 1246
								name, -- 1246
								"dora module", -- 1246
								"function" -- 1246
							} -- 1246
						end -- 1245
					end -- 1244
					if #suggestions > 0 then -- 1247
						do -- 1248
							local _accum_0 = { } -- 1248
							local _len_0 = 1 -- 1248
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1248
								_accum_0[_len_0] = v -- 1248
								_len_0 = _len_0 + 1 -- 1248
							end -- 1248
							suggestions = _accum_0 -- 1248
						end -- 1248
						return { -- 1249
							success = true, -- 1249
							suggestions = suggestions -- 1249
						} -- 1249
					else -- 1251
						return { -- 1251
							success = false -- 1251
						} -- 1251
					end -- 1247
				until true -- 1192
				if "tl" == lang or "lua" == lang then -- 1253
					do -- 1254
						local isTIC80 = CheckTIC80Code(content) -- 1254
						if isTIC80 then -- 1254
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1255
						end -- 1254
					end -- 1254
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1256
					if not line:match("[%.:]$") then -- 1257
						local checkSet -- 1258
						do -- 1258
							local _tbl_0 = { } -- 1258
							for _index_0 = 1, #suggestions do -- 1258
								local _des_0 = suggestions[_index_0] -- 1258
								local name = _des_0[1] -- 1258
								_tbl_0[name] = true -- 1258
							end -- 1258
							checkSet = _tbl_0 -- 1258
						end -- 1258
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1259
						for _index_0 = 1, #_list_0 do -- 1259
							local item = _list_0[_index_0] -- 1259
							if not checkSet[item[1]] then -- 1260
								suggestions[#suggestions + 1] = item -- 1260
							end -- 1260
						end -- 1259
						for _index_0 = 1, #luaKeywords do -- 1261
							local word = luaKeywords[_index_0] -- 1261
							suggestions[#suggestions + 1] = { -- 1262
								word, -- 1262
								"keyword", -- 1262
								"keyword" -- 1262
							} -- 1262
						end -- 1261
						if lang == "tl" then -- 1263
							for _index_0 = 1, #tealKeywords do -- 1264
								local word = tealKeywords[_index_0] -- 1264
								suggestions[#suggestions + 1] = { -- 1265
									word, -- 1265
									"keyword", -- 1265
									"keyword" -- 1265
								} -- 1265
							end -- 1264
						end -- 1263
					end -- 1257
					if #suggestions > 0 then -- 1266
						return { -- 1267
							success = true, -- 1267
							suggestions = suggestions -- 1267
						} -- 1267
					end -- 1266
				elseif "yue" == lang then -- 1268
					local suggestions = { } -- 1269
					local gotGlobals = false -- 1270
					do -- 1271
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1271
						if luaCodes then -- 1271
							gotGlobals = true -- 1272
							do -- 1273
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1273
								if chainOp then -- 1273
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1274
									if not withVar then -- 1275
										return { -- 1275
											success = false -- 1275
										} -- 1275
									end -- 1275
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1276
								elseif line:match("^([%.\\])$") then -- 1277
									return { -- 1278
										success = false -- 1278
									} -- 1278
								end -- 1273
							end -- 1273
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1279
							for _index_0 = 1, #_list_0 do -- 1279
								local item = _list_0[_index_0] -- 1279
								suggestions[#suggestions + 1] = item -- 1279
							end -- 1279
							if #suggestions == 0 then -- 1280
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1281
								for _index_0 = 1, #_list_1 do -- 1281
									local item = _list_1[_index_0] -- 1281
									suggestions[#suggestions + 1] = item -- 1281
								end -- 1281
							end -- 1280
						end -- 1271
					end -- 1271
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1282
						local checkSet -- 1283
						do -- 1283
							local _tbl_0 = { } -- 1283
							for _index_0 = 1, #suggestions do -- 1283
								local _des_0 = suggestions[_index_0] -- 1283
								local name = _des_0[1] -- 1283
								_tbl_0[name] = true -- 1283
							end -- 1283
							checkSet = _tbl_0 -- 1283
						end -- 1283
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1284
						for _index_0 = 1, #_list_0 do -- 1284
							local item = _list_0[_index_0] -- 1284
							if not checkSet[item[1]] then -- 1285
								suggestions[#suggestions + 1] = item -- 1285
							end -- 1285
						end -- 1284
						if not gotGlobals then -- 1286
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1287
							for _index_0 = 1, #_list_1 do -- 1287
								local item = _list_1[_index_0] -- 1287
								if not checkSet[item[1]] then -- 1288
									suggestions[#suggestions + 1] = item -- 1288
								end -- 1288
							end -- 1287
						end -- 1286
						for _index_0 = 1, #yueKeywords do -- 1289
							local word = yueKeywords[_index_0] -- 1289
							if not checkSet[word] then -- 1290
								suggestions[#suggestions + 1] = { -- 1291
									word, -- 1291
									"keyword", -- 1291
									"keyword" -- 1291
								} -- 1291
							end -- 1290
						end -- 1289
					end -- 1282
					if #suggestions > 0 then -- 1292
						return { -- 1293
							success = true, -- 1293
							suggestions = suggestions -- 1293
						} -- 1293
					end -- 1292
				elseif "xml" == lang then -- 1294
					local items = xml.complete(content) -- 1295
					if #items > 0 then -- 1296
						local suggestions -- 1297
						do -- 1297
							local _accum_0 = { } -- 1297
							local _len_0 = 1 -- 1297
							for _index_0 = 1, #items do -- 1297
								local _des_0 = items[_index_0] -- 1297
								local label, insertText = _des_0[1], _des_0[2] -- 1297
								_accum_0[_len_0] = { -- 1298
									label, -- 1298
									insertText, -- 1298
									"field" -- 1298
								} -- 1298
								_len_0 = _len_0 + 1 -- 1298
							end -- 1297
							suggestions = _accum_0 -- 1297
						end -- 1297
						return { -- 1299
							success = true, -- 1299
							suggestions = suggestions -- 1299
						} -- 1299
					end -- 1296
				end -- 1253
			end -- 1190
		end -- 1190
	end -- 1190
	return { -- 1189
		success = false -- 1189
	} -- 1189
end) -- 1189
HttpServer:upload("/upload", function(req, filename) -- 1303
	do -- 1304
		local _type_0 = type(req) -- 1304
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1304
		if _tab_0 then -- 1304
			local path -- 1304
			do -- 1304
				local _obj_0 = req.params -- 1304
				local _type_1 = type(_obj_0) -- 1304
				if "table" == _type_1 or "userdata" == _type_1 then -- 1304
					path = _obj_0.path -- 1304
				end -- 1304
			end -- 1304
			if path ~= nil then -- 1304
				local uploadPath = Path(Content.writablePath, ".upload") -- 1305
				if not Content:exist(uploadPath) then -- 1306
					Content:mkdir(uploadPath) -- 1307
				end -- 1306
				local targetPath = Path(uploadPath, filename) -- 1308
				Content:mkdir(Path:getPath(targetPath)) -- 1309
				return targetPath -- 1310
			end -- 1304
		end -- 1304
	end -- 1304
	return nil -- 1303
end, function(req, file) -- 1311
	do -- 1312
		local _type_0 = type(req) -- 1312
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1312
		if _tab_0 then -- 1312
			local path -- 1312
			do -- 1312
				local _obj_0 = req.params -- 1312
				local _type_1 = type(_obj_0) -- 1312
				if "table" == _type_1 or "userdata" == _type_1 then -- 1312
					path = _obj_0.path -- 1312
				end -- 1312
			end -- 1312
			if path ~= nil then -- 1312
				path = Path(Content.writablePath, path) -- 1313
				if Content:exist(path) then -- 1314
					local uploadPath = Path(Content.writablePath, ".upload") -- 1315
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1316
					Content:mkdir(Path:getPath(targetPath)) -- 1317
					if Content:move(file, targetPath) then -- 1318
						return true -- 1319
					end -- 1318
				end -- 1314
			end -- 1312
		end -- 1312
	end -- 1312
	return false -- 1311
end) -- 1301
HttpServer:post("/list", function(req) -- 1322
	do -- 1323
		local _type_0 = type(req) -- 1323
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1323
		if _tab_0 then -- 1323
			local path -- 1323
			do -- 1323
				local _obj_0 = req.body -- 1323
				local _type_1 = type(_obj_0) -- 1323
				if "table" == _type_1 or "userdata" == _type_1 then -- 1323
					path = _obj_0.path -- 1323
				end -- 1323
			end -- 1323
			if path ~= nil then -- 1323
				if Content:exist(path) then -- 1324
					local files = { } -- 1325
					local visitAssets -- 1326
					visitAssets = function(path, folder) -- 1326
						local dirs = Content:getDirs(path) -- 1327
						for _index_0 = 1, #dirs do -- 1328
							local dir = dirs[_index_0] -- 1328
							if dir:match("^%.") then -- 1329
								goto _continue_0 -- 1329
							end -- 1329
							local current -- 1330
							if folder == "" then -- 1330
								current = dir -- 1331
							else -- 1333
								current = Path(folder, dir) -- 1333
							end -- 1330
							files[#files + 1] = current -- 1334
							visitAssets(Path(path, dir), current) -- 1335
							::_continue_0:: -- 1329
						end -- 1328
						local fs = Content:getFiles(path) -- 1336
						for _index_0 = 1, #fs do -- 1337
							local f = fs[_index_0] -- 1337
							if (".DS_Store" == f) then -- 1338
								goto _continue_1 -- 1339
							end -- 1338
							if folder == "" then -- 1340
								files[#files + 1] = f -- 1341
							else -- 1343
								files[#files + 1] = Path(folder, f) -- 1343
							end -- 1340
							::_continue_1:: -- 1338
						end -- 1337
					end -- 1326
					visitAssets(path, "") -- 1344
					if #files == 0 then -- 1345
						files = nil -- 1345
					end -- 1345
					return { -- 1346
						success = true, -- 1346
						files = files -- 1346
					} -- 1346
				end -- 1324
			end -- 1323
		end -- 1323
	end -- 1323
	return { -- 1322
		success = false -- 1322
	} -- 1322
end) -- 1322
HttpServer:post("/info", function() -- 1348
	local Entry = require("Script.Dev.Entry") -- 1349
	local webProfiler, drawerWidth -- 1350
	do -- 1350
		local _obj_0 = Entry.getConfig() -- 1350
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 1350
	end -- 1350
	local engineDev = Entry.getEngineDev() -- 1351
	Entry.connectWebIDE() -- 1352
	return { -- 1354
		platform = App.platform, -- 1354
		locale = App.locale, -- 1355
		version = App.version, -- 1356
		engineDev = engineDev, -- 1357
		webProfiler = webProfiler, -- 1358
		drawerWidth = drawerWidth -- 1359
	} -- 1353
end) -- 1348
local ensureLLMConfigTable -- 1361
ensureLLMConfigTable = function() -- 1361
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1362
	if columns and #columns > 0 then -- 1363
		local expected = { -- 1365
			id = true, -- 1365
			name = true, -- 1366
			url = true, -- 1367
			model = true, -- 1368
			api_key = true, -- 1369
			context_window = true, -- 1370
			temperature = true, -- 1371
			max_tokens = true, -- 1372
			reasoning_effort = true, -- 1373
			custom_options = true, -- 1374
			supports_function_calling = true, -- 1375
			active = true, -- 1376
			created_at = true, -- 1377
			updated_at = true -- 1378
		} -- 1364
		local existing = { } -- 1380
		local valid = true -- 1381
		for _index_0 = 1, #columns do -- 1382
			local row = columns[_index_0] -- 1382
			local columnName = tostring(row[2]) -- 1383
			existing[columnName] = true -- 1384
			if not expected[columnName] then -- 1385
				valid = false -- 1386
				break -- 1387
			end -- 1385
		end -- 1382
		if valid then -- 1388
			if not existing.context_window then -- 1389
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1390
			end -- 1389
			if not existing.temperature then -- 1391
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1392
			end -- 1391
			if not existing.max_tokens then -- 1393
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 1394
			end -- 1393
			if not existing.reasoning_effort then -- 1395
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1396
			end -- 1395
			if not existing.custom_options then -- 1397
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1398
			end -- 1397
			if not existing.supports_function_calling then -- 1399
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1400
			end -- 1399
		else -- 1402
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1402
		end -- 1388
	end -- 1363
	return DB:exec([[		CREATE TABLE IF NOT EXISTS LLMConfig(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT NOT NULL,
			url TEXT NOT NULL,
			model TEXT NOT NULL,
			api_key TEXT NOT NULL,
			context_window INTEGER NOT NULL DEFAULT 64000,
			temperature REAL NOT NULL DEFAULT 0.1,
			max_tokens INTEGER NOT NULL DEFAULT 8192,
			reasoning_effort TEXT NOT NULL DEFAULT '',
			custom_options TEXT NOT NULL DEFAULT '',
			supports_function_calling INTEGER NOT NULL DEFAULT 1,
			active INTEGER NOT NULL DEFAULT 1,
			created_at INTEGER,
			updated_at INTEGER
		);
	]]) -- 1403
end -- 1361
local normalizeContextWindow -- 1422
normalizeContextWindow = function(value) -- 1422
	local contextWindow = tonumber(value) -- 1423
	if contextWindow == nil or contextWindow < 64000 then -- 1424
		return 64000 -- 1425
	end -- 1424
	return math.max(64000, math.floor(contextWindow)) -- 1426
end -- 1422
local normalizeTemperature -- 1428
normalizeTemperature = function(value) -- 1428
	local temperature = tonumber(value) -- 1429
	if temperature == nil then -- 1430
		return 0.1 -- 1431
	end -- 1430
	return math.max(0, math.min(2, temperature)) -- 1432
end -- 1428
local normalizeMaxTokens -- 1434
normalizeMaxTokens = function(value) -- 1434
	local maxTokens = tonumber(value) -- 1435
	if maxTokens == nil or maxTokens < 1 then -- 1436
		return 8192 -- 1437
	end -- 1436
	return math.max(1, math.floor(maxTokens)) -- 1438
end -- 1434
local normalizeReasoningEffort -- 1440
normalizeReasoningEffort = function(value) -- 1440
	if value == nil then -- 1441
		return "" -- 1442
	end -- 1441
	local effort = tostring(value) -- 1443
	return effort:match("^%s*(.-)%s*$") or "" -- 1444
end -- 1440
local normalizeCustomOptions -- 1446
normalizeCustomOptions = function(value) -- 1446
	if value == nil then -- 1447
		return "" -- 1448
	end -- 1447
	local options = tostring(value) -- 1449
	options = options:match("^%s*(.-)%s*$") or "" -- 1450
	return options -- 1451
end -- 1446
local validateCustomOptions -- 1453
validateCustomOptions = function(value) -- 1453
	local options = normalizeCustomOptions(value) -- 1454
	if options == "" then -- 1455
		return true -- 1455
	end -- 1455
	if not options:match("^%s*{") then -- 1456
		return false -- 1456
	end -- 1456
	local decoded = json.decode(options) -- 1457
	return type(decoded) == "table" -- 1458
end -- 1453
HttpServer:post("/llm/list", function() -- 1460
	ensureLLMConfigTable() -- 1461
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active\n		from LLMConfig\n		order by id asc") -- 1462
	local items -- 1466
	if rows and #rows > 0 then -- 1466
		local _accum_0 = { } -- 1467
		local _len_0 = 1 -- 1467
		for _index_0 = 1, #rows do -- 1467
			local _des_0 = rows[_index_0] -- 1467
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11], _des_0[12] -- 1467
			_accum_0[_len_0] = { -- 1468
				id = id, -- 1468
				name = name, -- 1468
				url = url, -- 1468
				model = model, -- 1468
				key = key, -- 1468
				contextWindow = normalizeContextWindow(contextWindow), -- 1468
				temperature = normalizeTemperature(temperature), -- 1468
				maxTokens = normalizeMaxTokens(maxTokens), -- 1468
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1468
				customOptions = normalizeCustomOptions(customOptions), -- 1468
				supportsFunctionCalling = supportsFunctionCalling ~= 0, -- 1468
				active = active ~= 0 -- 1468
			} -- 1468
			_len_0 = _len_0 + 1 -- 1468
		end -- 1467
		items = _accum_0 -- 1466
	end -- 1466
	return { -- 1469
		success = true, -- 1469
		items = items -- 1469
	} -- 1469
end) -- 1460
HttpServer:post("/llm/create", function(req) -- 1471
	ensureLLMConfigTable() -- 1472
	do -- 1473
		local _type_0 = type(req) -- 1473
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1473
		if _tab_0 then -- 1473
			local body = req.body -- 1473
			if body ~= nil then -- 1473
				local name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1474
				local now = os.time() -- 1475
				if name == nil or url == nil or model == nil or key == nil then -- 1476
					return { -- 1477
						success = false, -- 1477
						message = "invalid" -- 1477
					} -- 1477
				end -- 1476
				contextWindow = normalizeContextWindow(contextWindow) -- 1478
				temperature = normalizeTemperature(temperature) -- 1479
				maxTokens = normalizeMaxTokens(maxTokens) -- 1480
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1481
				customOptions = normalizeCustomOptions(customOptions) -- 1482
				if not validateCustomOptions(customOptions) then -- 1483
					return { -- 1483
						success = false, -- 1483
						message = "customOptions must be a JSON object" -- 1483
					} -- 1483
				end -- 1483
				if supportsFunctionCalling == false then -- 1484
					supportsFunctionCalling = 0 -- 1484
				else -- 1484
					supportsFunctionCalling = 1 -- 1484
				end -- 1484
				if active then -- 1485
					active = 1 -- 1485
				else -- 1485
					active = 0 -- 1485
				end -- 1485
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1492
					tostring(name), -- 1492
					tostring(url), -- 1493
					tostring(model), -- 1494
					tostring(key), -- 1495
					contextWindow, -- 1496
					temperature, -- 1497
					maxTokens, -- 1498
					reasoningEffort, -- 1499
					customOptions, -- 1500
					supportsFunctionCalling, -- 1501
					active, -- 1502
					now, -- 1503
					now -- 1504
				}) -- 1486
				return { -- 1506
					success = affected >= 0 -- 1506
				} -- 1506
			end -- 1473
		end -- 1473
	end -- 1473
	return { -- 1471
		success = false, -- 1471
		message = "invalid" -- 1471
	} -- 1471
end) -- 1471
HttpServer:post("/llm/update", function(req) -- 1508
	ensureLLMConfigTable() -- 1509
	do -- 1510
		local _type_0 = type(req) -- 1510
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1510
		if _tab_0 then -- 1510
			local body = req.body -- 1510
			if body ~= nil then -- 1510
				local id, name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1511
				local now = os.time() -- 1512
				id = tonumber(id) -- 1513
				if id == nil then -- 1514
					return { -- 1515
						success = false, -- 1515
						message = "invalid" -- 1515
					} -- 1515
				end -- 1514
				contextWindow = normalizeContextWindow(contextWindow) -- 1516
				temperature = normalizeTemperature(temperature) -- 1517
				maxTokens = normalizeMaxTokens(maxTokens) -- 1518
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1519
				customOptions = normalizeCustomOptions(customOptions) -- 1520
				if not validateCustomOptions(customOptions) then -- 1521
					return { -- 1521
						success = false, -- 1521
						message = "customOptions must be a JSON object" -- 1521
					} -- 1521
				end -- 1521
				if supportsFunctionCalling == false then -- 1522
					supportsFunctionCalling = 0 -- 1522
				else -- 1522
					supportsFunctionCalling = 1 -- 1522
				end -- 1522
				if active then -- 1523
					active = 1 -- 1523
				else -- 1523
					active = 0 -- 1523
				end -- 1523
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, active = ?, updated_at = ?\n			where id = ?", { -- 1528
					tostring(name), -- 1528
					tostring(url), -- 1529
					tostring(model), -- 1530
					tostring(key), -- 1531
					contextWindow, -- 1532
					temperature, -- 1533
					maxTokens, -- 1534
					reasoningEffort, -- 1535
					customOptions, -- 1536
					supportsFunctionCalling, -- 1537
					active, -- 1538
					now, -- 1539
					id -- 1540
				}) -- 1524
				return { -- 1542
					success = affected >= 0 -- 1542
				} -- 1542
			end -- 1510
		end -- 1510
	end -- 1510
	return { -- 1508
		success = false, -- 1508
		message = "invalid" -- 1508
	} -- 1508
end) -- 1508
HttpServer:post("/llm/delete", function(req) -- 1544
	ensureLLMConfigTable() -- 1545
	do -- 1546
		local _type_0 = type(req) -- 1546
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1546
		if _tab_0 then -- 1546
			local id -- 1546
			do -- 1546
				local _obj_0 = req.body -- 1546
				local _type_1 = type(_obj_0) -- 1546
				if "table" == _type_1 or "userdata" == _type_1 then -- 1546
					id = _obj_0.id -- 1546
				end -- 1546
			end -- 1546
			if id ~= nil then -- 1546
				id = tonumber(id) -- 1547
				if id == nil then -- 1548
					return { -- 1549
						success = false, -- 1549
						message = "invalid" -- 1549
					} -- 1549
				end -- 1548
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1550
					id -- 1550
				}) -- 1550
				return { -- 1551
					success = affected >= 0 -- 1551
				} -- 1551
			end -- 1546
		end -- 1546
	end -- 1546
	return { -- 1544
		success = false, -- 1544
		message = "invalid" -- 1544
	} -- 1544
end) -- 1544
HttpServer:post("/stat", function(req) -- 1553
	do -- 1554
		local _type_0 = type(req) -- 1554
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1554
		if _tab_0 then -- 1554
			local path -- 1554
			do -- 1554
				local _obj_0 = req.body -- 1554
				local _type_1 = type(_obj_0) -- 1554
				if "table" == _type_1 or "userdata" == _type_1 then -- 1554
					path = _obj_0.path -- 1554
				end -- 1554
			end -- 1554
			if path ~= nil then -- 1554
				if not Content:exist(path) then -- 1555
					return { -- 1556
						success = false, -- 1556
						message = "target not existed" -- 1556
					} -- 1556
				end -- 1555
				if Content:isdir(path) then -- 1557
					return { -- 1558
						success = false, -- 1558
						message = "failed to stat a directory" -- 1558
					} -- 1558
				end -- 1557
				local size, isBinary = Content:getAttr(path) -- 1559
				if size then -- 1559
					return { -- 1560
						success = true, -- 1560
						size = size, -- 1560
						isBinary = isBinary -- 1560
					} -- 1560
				end -- 1559
			end -- 1554
		end -- 1554
	end -- 1554
	return { -- 1553
		success = false, -- 1553
		message = "failed to stat" -- 1553
	} -- 1553
end) -- 1553
HttpServer:post("/new", function(req) -- 1562
	do -- 1563
		local _type_0 = type(req) -- 1563
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1563
		if _tab_0 then -- 1563
			local path -- 1563
			do -- 1563
				local _obj_0 = req.body -- 1563
				local _type_1 = type(_obj_0) -- 1563
				if "table" == _type_1 or "userdata" == _type_1 then -- 1563
					path = _obj_0.path -- 1563
				end -- 1563
			end -- 1563
			local content -- 1563
			do -- 1563
				local _obj_0 = req.body -- 1563
				local _type_1 = type(_obj_0) -- 1563
				if "table" == _type_1 or "userdata" == _type_1 then -- 1563
					content = _obj_0.content -- 1563
				end -- 1563
			end -- 1563
			local folder -- 1563
			do -- 1563
				local _obj_0 = req.body -- 1563
				local _type_1 = type(_obj_0) -- 1563
				if "table" == _type_1 or "userdata" == _type_1 then -- 1563
					folder = _obj_0.folder -- 1563
				end -- 1563
			end -- 1563
			if path ~= nil and content ~= nil and folder ~= nil then -- 1563
				if Content:exist(path) then -- 1564
					return { -- 1565
						success = false, -- 1565
						message = "TargetExisted" -- 1565
					} -- 1565
				end -- 1564
				local parent = Path:getPath(path) -- 1566
				local files = Content:getFiles(parent) -- 1567
				if folder then -- 1568
					local name = Path:getFilename(path):lower() -- 1569
					for _index_0 = 1, #files do -- 1570
						local file = files[_index_0] -- 1570
						if name == Path:getFilename(file):lower() then -- 1571
							return { -- 1572
								success = false, -- 1572
								message = "TargetExisted" -- 1572
							} -- 1572
						end -- 1571
					end -- 1570
					if Content:mkdir(path) then -- 1573
						return { -- 1574
							success = true -- 1574
						} -- 1574
					end -- 1573
				else -- 1576
					local name = Path:getName(path):lower() -- 1576
					for _index_0 = 1, #files do -- 1577
						local file = files[_index_0] -- 1577
						if name == Path:getName(file):lower() then -- 1578
							local ext = Path:getExt(file) -- 1579
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1580
								goto _continue_0 -- 1581
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1582
								goto _continue_0 -- 1583
							end -- 1580
							return { -- 1584
								success = false, -- 1584
								message = "SourceExisted" -- 1584
							} -- 1584
						end -- 1578
						::_continue_0:: -- 1578
					end -- 1577
					if Content:save(path, content) then -- 1585
						return { -- 1586
							success = true -- 1586
						} -- 1586
					end -- 1585
				end -- 1568
			end -- 1563
		end -- 1563
	end -- 1563
	return { -- 1562
		success = false, -- 1562
		message = "Failed" -- 1562
	} -- 1562
end) -- 1562
HttpServer:post("/delete", function(req) -- 1588
	do -- 1589
		local _type_0 = type(req) -- 1589
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1589
		if _tab_0 then -- 1589
			local path -- 1589
			do -- 1589
				local _obj_0 = req.body -- 1589
				local _type_1 = type(_obj_0) -- 1589
				if "table" == _type_1 or "userdata" == _type_1 then -- 1589
					path = _obj_0.path -- 1589
				end -- 1589
			end -- 1589
			if path ~= nil then -- 1589
				if Content:exist(path) then -- 1590
					local projectRoot -- 1591
					if Content:isdir(path) and isProjectRootDir(path) then -- 1591
						projectRoot = path -- 1591
					else -- 1591
						projectRoot = nil -- 1591
					end -- 1591
					local parent = Path:getPath(path) -- 1592
					local files = Content:getFiles(parent) -- 1593
					local name = Path:getName(path):lower() -- 1594
					local ext = Path:getExt(path) -- 1595
					for _index_0 = 1, #files do -- 1596
						local file = files[_index_0] -- 1596
						if name == Path:getName(file):lower() then -- 1597
							local _exp_0 = Path:getExt(file) -- 1598
							if "tl" == _exp_0 then -- 1598
								if ("vs" == ext) then -- 1598
									Content:remove(Path(parent, file)) -- 1599
								end -- 1598
							elseif "lua" == _exp_0 then -- 1600
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1600
									Content:remove(Path(parent, file)) -- 1601
								end -- 1600
							end -- 1598
						end -- 1597
					end -- 1596
					if Content:remove(path) then -- 1602
						if projectRoot then -- 1603
							AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1604
						end -- 1603
						return { -- 1605
							success = true -- 1605
						} -- 1605
					end -- 1602
				end -- 1590
			end -- 1589
		end -- 1589
	end -- 1589
	return { -- 1588
		success = false -- 1588
	} -- 1588
end) -- 1588
HttpServer:post("/rename", function(req) -- 1607
	do -- 1608
		local _type_0 = type(req) -- 1608
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1608
		if _tab_0 then -- 1608
			local old -- 1608
			do -- 1608
				local _obj_0 = req.body -- 1608
				local _type_1 = type(_obj_0) -- 1608
				if "table" == _type_1 or "userdata" == _type_1 then -- 1608
					old = _obj_0.old -- 1608
				end -- 1608
			end -- 1608
			local new -- 1608
			do -- 1608
				local _obj_0 = req.body -- 1608
				local _type_1 = type(_obj_0) -- 1608
				if "table" == _type_1 or "userdata" == _type_1 then -- 1608
					new = _obj_0.new -- 1608
				end -- 1608
			end -- 1608
			if old ~= nil and new ~= nil then -- 1608
				if Content:exist(old) and not Content:exist(new) then -- 1609
					local renamedDir = Content:isdir(old) -- 1610
					local parent = Path:getPath(new) -- 1611
					local files = Content:getFiles(parent) -- 1612
					if renamedDir then -- 1613
						local name = Path:getFilename(new):lower() -- 1614
						for _index_0 = 1, #files do -- 1615
							local file = files[_index_0] -- 1615
							if name == Path:getFilename(file):lower() then -- 1616
								return { -- 1617
									success = false -- 1617
								} -- 1617
							end -- 1616
						end -- 1615
					else -- 1619
						local name = Path:getName(new):lower() -- 1619
						local ext = Path:getExt(new) -- 1620
						for _index_0 = 1, #files do -- 1621
							local file = files[_index_0] -- 1621
							if name == Path:getName(file):lower() then -- 1622
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1623
									goto _continue_0 -- 1624
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1625
									goto _continue_0 -- 1626
								end -- 1623
								return { -- 1627
									success = false -- 1627
								} -- 1627
							end -- 1622
							::_continue_0:: -- 1622
						end -- 1621
					end -- 1613
					if Content:move(old, new) then -- 1628
						if renamedDir then -- 1629
							AgentSession.renameSessionsByProjectRoot(old, new) -- 1630
						end -- 1629
						local newParent = Path:getPath(new) -- 1631
						parent = Path:getPath(old) -- 1632
						files = Content:getFiles(parent) -- 1633
						local newName = Path:getName(new) -- 1634
						local oldName = Path:getName(old) -- 1635
						local name = oldName:lower() -- 1636
						local ext = Path:getExt(old) -- 1637
						for _index_0 = 1, #files do -- 1638
							local file = files[_index_0] -- 1638
							if name == Path:getName(file):lower() then -- 1639
								local _exp_0 = Path:getExt(file) -- 1640
								if "tl" == _exp_0 then -- 1640
									if ("vs" == ext) then -- 1640
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1641
									end -- 1640
								elseif "lua" == _exp_0 then -- 1642
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1642
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1643
									end -- 1642
								end -- 1640
							end -- 1639
						end -- 1638
						return { -- 1644
							success = true -- 1644
						} -- 1644
					end -- 1628
				end -- 1609
			end -- 1608
		end -- 1608
	end -- 1608
	return { -- 1607
		success = false -- 1607
	} -- 1607
end) -- 1607
HttpServer:post("/exist", function(req) -- 1646
	do -- 1647
		local _type_0 = type(req) -- 1647
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1647
		if _tab_0 then -- 1647
			local file -- 1647
			do -- 1647
				local _obj_0 = req.body -- 1647
				local _type_1 = type(_obj_0) -- 1647
				if "table" == _type_1 or "userdata" == _type_1 then -- 1647
					file = _obj_0.file -- 1647
				end -- 1647
			end -- 1647
			if file ~= nil then -- 1647
				do -- 1648
					local projFile = req.body.projFile -- 1648
					if projFile then -- 1648
						local projDir = getProjectDirFromFile(projFile) -- 1649
						if projDir then -- 1649
							local scriptDir = Path(projDir, "Script") -- 1650
							local searchPaths = Content.searchPaths -- 1651
							if Content:exist(scriptDir) then -- 1652
								Content:addSearchPath(scriptDir) -- 1652
							end -- 1652
							if Content:exist(projDir) then -- 1653
								Content:addSearchPath(projDir) -- 1653
							end -- 1653
							local _ <close> = setmetatable({ }, { -- 1654
								__close = function() -- 1654
									Content.searchPaths = searchPaths -- 1654
								end -- 1654
							}) -- 1654
							return { -- 1655
								success = Content:exist(file) -- 1655
							} -- 1655
						end -- 1649
					end -- 1648
				end -- 1648
				return { -- 1656
					success = Content:exist(file) -- 1656
				} -- 1656
			end -- 1647
		end -- 1647
	end -- 1647
	return { -- 1646
		success = false -- 1646
	} -- 1646
end) -- 1646
HttpServer:postSchedule("/read", function(req) -- 1658
	do -- 1659
		local _type_0 = type(req) -- 1659
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1659
		if _tab_0 then -- 1659
			local path -- 1659
			do -- 1659
				local _obj_0 = req.body -- 1659
				local _type_1 = type(_obj_0) -- 1659
				if "table" == _type_1 or "userdata" == _type_1 then -- 1659
					path = _obj_0.path -- 1659
				end -- 1659
			end -- 1659
			if path ~= nil then -- 1659
				local readFile -- 1660
				readFile = function() -- 1660
					if Content:exist(path) then -- 1661
						local content = Content:loadAsync(path) -- 1662
						if content then -- 1662
							return { -- 1663
								content = content, -- 1663
								success = true, -- 1663
								fullPath = Content:getFullPath(path) -- 1663
							} -- 1663
						end -- 1662
					end -- 1661
					return nil -- 1660
				end -- 1660
				do -- 1664
					local projFile = req.body.projFile -- 1664
					if projFile then -- 1664
						local projDir = getProjectDirFromFile(projFile) -- 1665
						if projDir then -- 1665
							local scriptDir = Path(projDir, "Script") -- 1666
							local searchPaths = Content.searchPaths -- 1667
							if Content:exist(scriptDir) then -- 1668
								Content:addSearchPath(scriptDir) -- 1668
							end -- 1668
							if Content:exist(projDir) then -- 1669
								Content:addSearchPath(projDir) -- 1669
							end -- 1669
							local _ <close> = setmetatable({ }, { -- 1670
								__close = function() -- 1670
									Content.searchPaths = searchPaths -- 1670
								end -- 1670
							}) -- 1670
							local result = readFile() -- 1671
							if result then -- 1671
								return result -- 1671
							end -- 1671
						end -- 1665
					end -- 1664
				end -- 1664
				local result = readFile() -- 1672
				if result then -- 1672
					return result -- 1672
				end -- 1672
			end -- 1659
		end -- 1659
	end -- 1659
	return { -- 1658
		success = false -- 1658
	} -- 1658
end) -- 1658
HttpServer:get("/read-sync", function(req) -- 1674
	do -- 1675
		local _type_0 = type(req) -- 1675
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1675
		if _tab_0 then -- 1675
			local params = req.params -- 1675
			if params ~= nil then -- 1675
				local path = params.path -- 1676
				local exts -- 1677
				if params.exts then -- 1677
					local _accum_0 = { } -- 1678
					local _len_0 = 1 -- 1678
					for ext in params.exts:gmatch("[^|]*") do -- 1678
						_accum_0[_len_0] = ext -- 1679
						_len_0 = _len_0 + 1 -- 1679
					end -- 1678
					exts = _accum_0 -- 1677
				else -- 1680
					exts = { -- 1680
						"" -- 1680
					} -- 1680
				end -- 1677
				local readFile -- 1681
				readFile = function() -- 1681
					for _index_0 = 1, #exts do -- 1682
						local ext = exts[_index_0] -- 1682
						local targetPath = path .. ext -- 1683
						if Content:exist(targetPath) then -- 1684
							local content = Content:load(targetPath) -- 1685
							if content then -- 1685
								return { -- 1686
									content = content, -- 1686
									success = true, -- 1686
									fullPath = Content:getFullPath(targetPath) -- 1686
								} -- 1686
							end -- 1685
						end -- 1684
					end -- 1682
					return nil -- 1681
				end -- 1681
				local searchPaths = Content.searchPaths -- 1687
				local _ <close> = setmetatable({ }, { -- 1688
					__close = function() -- 1688
						Content.searchPaths = searchPaths -- 1688
					end -- 1688
				}) -- 1688
				do -- 1689
					local projFile = req.params.projFile -- 1689
					if projFile then -- 1689
						local projDir = getProjectDirFromFile(projFile) -- 1690
						if projDir then -- 1690
							local scriptDir = Path(projDir, "Script") -- 1691
							if Content:exist(scriptDir) then -- 1692
								Content:addSearchPath(scriptDir) -- 1692
							end -- 1692
							if Content:exist(projDir) then -- 1693
								Content:addSearchPath(projDir) -- 1693
							end -- 1693
						else -- 1695
							projDir = Path:getPath(projFile) -- 1695
							if Content:exist(projDir) then -- 1696
								Content:addSearchPath(projDir) -- 1696
							end -- 1696
						end -- 1690
					end -- 1689
				end -- 1689
				local result = readFile() -- 1697
				if result then -- 1697
					return result -- 1697
				end -- 1697
			end -- 1675
		end -- 1675
	end -- 1675
	return { -- 1674
		success = false -- 1674
	} -- 1674
end) -- 1674
local compileFileAsync -- 1699
compileFileAsync = function(inputFile, sourceCodes) -- 1699
	local file = inputFile -- 1700
	local searchPath -- 1701
	do -- 1701
		local dir = getProjectDirFromFile(inputFile) -- 1701
		if dir then -- 1701
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 1702
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1703
		else -- 1705
			file = Path:getRelative(inputFile, Content.writablePath) -- 1705
			if file:sub(1, 2) == ".." then -- 1706
				file = Path:getRelative(inputFile, Content.assetPath) -- 1707
			end -- 1706
			searchPath = "" -- 1708
		end -- 1701
	end -- 1701
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1709
	local yueext = yue.options.extension -- 1710
	local resultCodes = nil -- 1711
	local resultError = nil -- 1712
	do -- 1713
		local _exp_0 = Path:getExt(inputFile) -- 1713
		if yueext == _exp_0 then -- 1713
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1714
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1715
				if not codes then -- 1716
					resultError = err -- 1717
					return -- 1718
				end -- 1716
				local extraGlobal -- 1719
				if isTIC80 then -- 1719
					extraGlobal = tic80APIs -- 1719
				else -- 1719
					extraGlobal = nil -- 1719
				end -- 1719
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1720
				if not success then -- 1721
					resultError = message -- 1722
					return -- 1723
				end -- 1721
				if codes == "" then -- 1724
					resultCodes = "" -- 1725
					return nil -- 1726
				end -- 1724
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1727
				return resultCodes -- 1728
			end, function(success) -- 1715
				if not success then -- 1729
					Content:remove(outputFile) -- 1730
					if resultCodes == nil then -- 1731
						resultCodes = false -- 1732
					end -- 1731
				end -- 1729
			end) -- 1715
		elseif "tl" == _exp_0 then -- 1733
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1734
			if isTIC80 then -- 1735
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1736
			end -- 1735
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1737
			if codes then -- 1737
				if isTIC80 then -- 1738
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1739
				end -- 1738
				resultCodes = codes -- 1740
				Content:saveAsync(outputFile, codes) -- 1741
			else -- 1743
				Content:remove(outputFile) -- 1743
				resultCodes = false -- 1744
				resultError = err -- 1745
			end -- 1737
		elseif "xml" == _exp_0 then -- 1746
			local codes, err = xml.tolua(sourceCodes) -- 1747
			if codes then -- 1747
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1748
				Content:saveAsync(outputFile, resultCodes) -- 1749
			else -- 1751
				Content:remove(outputFile) -- 1751
				resultCodes = false -- 1752
				resultError = err -- 1753
			end -- 1747
		end -- 1713
	end -- 1713
	wait(function() -- 1754
		return resultCodes ~= nil -- 1754
	end) -- 1754
	if resultCodes then -- 1755
		return resultCodes -- 1756
	else -- 1758
		return nil, resultError -- 1758
	end -- 1755
	return nil -- 1699
end -- 1699
HttpServer:postSchedule("/write", function(req) -- 1760
	do -- 1761
		local _type_0 = type(req) -- 1761
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1761
		if _tab_0 then -- 1761
			local path -- 1761
			do -- 1761
				local _obj_0 = req.body -- 1761
				local _type_1 = type(_obj_0) -- 1761
				if "table" == _type_1 or "userdata" == _type_1 then -- 1761
					path = _obj_0.path -- 1761
				end -- 1761
			end -- 1761
			local content -- 1761
			do -- 1761
				local _obj_0 = req.body -- 1761
				local _type_1 = type(_obj_0) -- 1761
				if "table" == _type_1 or "userdata" == _type_1 then -- 1761
					content = _obj_0.content -- 1761
				end -- 1761
			end -- 1761
			if path ~= nil and content ~= nil then -- 1761
				if Content:saveAsync(path, content) then -- 1762
					do -- 1763
						local _exp_0 = Path:getExt(path) -- 1763
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1763
							if '' == Path:getExt(Path:getName(path)) then -- 1764
								local resultCodes = compileFileAsync(path, content) -- 1765
								return { -- 1766
									success = true, -- 1766
									resultCodes = resultCodes -- 1766
								} -- 1766
							end -- 1764
						end -- 1763
					end -- 1763
					return { -- 1767
						success = true -- 1767
					} -- 1767
				end -- 1762
			end -- 1761
		end -- 1761
	end -- 1761
	return { -- 1760
		success = false -- 1760
	} -- 1760
end) -- 1760
HttpServer:postSchedule("/build", function(req) -- 1769
	do -- 1770
		local _type_0 = type(req) -- 1770
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1770
		if _tab_0 then -- 1770
			local path -- 1770
			do -- 1770
				local _obj_0 = req.body -- 1770
				local _type_1 = type(_obj_0) -- 1770
				if "table" == _type_1 or "userdata" == _type_1 then -- 1770
					path = _obj_0.path -- 1770
				end -- 1770
			end -- 1770
			if path ~= nil then -- 1770
				local _exp_0 = Path:getExt(path) -- 1771
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1771
					if '' == Path:getExt(Path:getName(path)) then -- 1772
						local content = Content:loadAsync(path) -- 1773
						if content then -- 1773
							local resultCodes = compileFileAsync(path, content) -- 1774
							if resultCodes then -- 1774
								return { -- 1775
									success = true, -- 1775
									resultCodes = resultCodes -- 1775
								} -- 1775
							end -- 1774
						end -- 1773
					end -- 1772
				end -- 1771
			end -- 1770
		end -- 1770
	end -- 1770
	return { -- 1769
		success = false -- 1769
	} -- 1769
end) -- 1769
local extentionLevels = { -- 1778
	vs = 2, -- 1778
	bl = 2, -- 1779
	ts = 1, -- 1780
	tsx = 1, -- 1781
	tl = 1, -- 1782
	yue = 1, -- 1783
	xml = 1, -- 1784
	lua = 0 -- 1785
} -- 1777
HttpServer:post("/assets", function() -- 1787
	local Entry = require("Script.Dev.Entry") -- 1790
	local engineDev = Entry.getEngineDev() -- 1791
	local visitAssets -- 1792
	visitAssets = function(path, tag) -- 1792
		local isWorkspace = tag == "Workspace" -- 1793
		local builtin -- 1794
		if tag == "Builtin" then -- 1794
			builtin = true -- 1794
		else -- 1794
			builtin = nil -- 1794
		end -- 1794
		local children = nil -- 1795
		local dirs = Content:getDirs(path) -- 1796
		for _index_0 = 1, #dirs do -- 1797
			local dir = dirs[_index_0] -- 1797
			if isWorkspace then -- 1798
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1799
					goto _continue_0 -- 1800
				end -- 1799
			elseif dir == ".git" then -- 1801
				goto _continue_0 -- 1802
			end -- 1798
			if not children then -- 1803
				children = { } -- 1803
			end -- 1803
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1804
			::_continue_0:: -- 1798
		end -- 1797
		local files = Content:getFiles(path) -- 1805
		local names = { } -- 1806
		for _index_0 = 1, #files do -- 1807
			local file = files[_index_0] -- 1807
			if (".DS_Store" == file) then -- 1808
				goto _continue_1 -- 1809
			end -- 1808
			local name = Path:getName(file) -- 1810
			local ext = names[name] -- 1811
			if ext then -- 1811
				local lv1 -- 1812
				do -- 1812
					local _exp_0 = extentionLevels[ext] -- 1812
					if _exp_0 ~= nil then -- 1812
						lv1 = _exp_0 -- 1812
					else -- 1812
						lv1 = -1 -- 1812
					end -- 1812
				end -- 1812
				ext = Path:getExt(file) -- 1813
				local lv2 -- 1814
				do -- 1814
					local _exp_0 = extentionLevels[ext] -- 1814
					if _exp_0 ~= nil then -- 1814
						lv2 = _exp_0 -- 1814
					else -- 1814
						lv2 = -1 -- 1814
					end -- 1814
				end -- 1814
				if lv2 > lv1 then -- 1815
					names[name] = ext -- 1816
				elseif lv2 == lv1 then -- 1817
					names[name .. '.' .. ext] = "" -- 1818
				end -- 1815
			else -- 1820
				ext = Path:getExt(file) -- 1820
				if not extentionLevels[ext] then -- 1821
					names[file] = "" -- 1822
				else -- 1824
					names[name] = ext -- 1824
				end -- 1821
			end -- 1811
			::_continue_1:: -- 1808
		end -- 1807
		do -- 1825
			local _accum_0 = { } -- 1825
			local _len_0 = 1 -- 1825
			for name, ext in pairs(names) do -- 1825
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1825
				_len_0 = _len_0 + 1 -- 1825
			end -- 1825
			files = _accum_0 -- 1825
		end -- 1825
		for _index_0 = 1, #files do -- 1826
			local file = files[_index_0] -- 1826
			if not children then -- 1827
				children = { } -- 1827
			end -- 1827
			children[#children + 1] = { -- 1829
				key = Path(path, file), -- 1829
				dir = false, -- 1830
				title = file, -- 1831
				builtin = builtin -- 1832
			} -- 1828
		end -- 1826
		if children then -- 1834
			table.sort(children, function(a, b) -- 1835
				if a.dir == b.dir then -- 1836
					return a.title < b.title -- 1837
				else -- 1839
					return a.dir -- 1839
				end -- 1836
			end) -- 1835
		end -- 1834
		if isWorkspace and children then -- 1840
			return children -- 1841
		else -- 1843
			return { -- 1844
				key = path, -- 1844
				dir = true, -- 1845
				title = Path:getFilename(path), -- 1846
				builtin = builtin, -- 1847
				children = children -- 1848
			} -- 1843
		end -- 1840
	end -- 1792
	local zh = (App.locale:match("^zh") ~= nil) -- 1850
	return { -- 1852
		key = Content.writablePath, -- 1852
		dir = true, -- 1853
		root = true, -- 1854
		title = "Assets", -- 1855
		children = (function() -- 1857
			local _tab_0 = { -- 1857
				{ -- 1858
					key = Path(Content.assetPath), -- 1858
					dir = true, -- 1859
					builtin = true, -- 1860
					title = zh and "内置资源" or "Built-in", -- 1861
					children = { -- 1863
						(function() -- 1863
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1863
							_with_0.title = zh and "说明文档" or "Readme" -- 1864
							return _with_0 -- 1863
						end)(), -- 1863
						(function() -- 1865
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1865
							_with_0.title = zh and "接口文档" or "API Doc" -- 1866
							return _with_0 -- 1865
						end)(), -- 1865
						(function() -- 1867
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1867
							_with_0.title = zh and "开发工具" or "Tools" -- 1868
							return _with_0 -- 1867
						end)(), -- 1867
						(function() -- 1869
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1869
							_with_0.title = zh and "字体" or "Font" -- 1870
							return _with_0 -- 1869
						end)(), -- 1869
						(function() -- 1871
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1871
							_with_0.title = zh and "程序库" or "Lib" -- 1872
							if engineDev then -- 1873
								local _list_0 = _with_0.children -- 1874
								for _index_0 = 1, #_list_0 do -- 1874
									local child = _list_0[_index_0] -- 1874
									if not (child.title == "Dora") then -- 1875
										goto _continue_0 -- 1875
									end -- 1875
									local title = zh and "zh-Hans" or "en" -- 1876
									do -- 1877
										local _accum_0 = { } -- 1877
										local _len_0 = 1 -- 1877
										local _list_1 = child.children -- 1877
										for _index_1 = 1, #_list_1 do -- 1877
											local c = _list_1[_index_1] -- 1877
											if c.title ~= title then -- 1877
												_accum_0[_len_0] = c -- 1877
												_len_0 = _len_0 + 1 -- 1877
											end -- 1877
										end -- 1877
										child.children = _accum_0 -- 1877
									end -- 1877
									break -- 1878
									::_continue_0:: -- 1875
								end -- 1874
							else -- 1880
								local _accum_0 = { } -- 1880
								local _len_0 = 1 -- 1880
								local _list_0 = _with_0.children -- 1880
								for _index_0 = 1, #_list_0 do -- 1880
									local child = _list_0[_index_0] -- 1880
									if child.title ~= "Dora" then -- 1880
										_accum_0[_len_0] = child -- 1880
										_len_0 = _len_0 + 1 -- 1880
									end -- 1880
								end -- 1880
								_with_0.children = _accum_0 -- 1880
							end -- 1873
							return _with_0 -- 1871
						end)(), -- 1871
						(function() -- 1881
							if engineDev then -- 1881
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1882
								local _obj_0 = _with_0.children -- 1883
								_obj_0[#_obj_0 + 1] = { -- 1884
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1884
									dir = false, -- 1885
									builtin = true, -- 1886
									title = "init.yue" -- 1887
								} -- 1883
								return _with_0 -- 1882
							end -- 1881
						end)() -- 1881
					} -- 1862
				} -- 1857
			} -- 1891
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1891
			local _idx_0 = #_tab_0 + 1 -- 1891
			for _index_0 = 1, #_obj_0 do -- 1891
				local _value_0 = _obj_0[_index_0] -- 1891
				_tab_0[_idx_0] = _value_0 -- 1891
				_idx_0 = _idx_0 + 1 -- 1891
			end -- 1891
			return _tab_0 -- 1857
		end)() -- 1856
	} -- 1851
end) -- 1787
HttpServer:post("/entry/list", function() -- 1895
	local Entry = require("Script.Dev.Entry") -- 1896
	local res = Entry.getLaunchEntries() -- 1897
	res.success = true -- 1898
	return res -- 1899
end) -- 1895
HttpServer:post("/run/status", function() -- 1901
	local Entry = require("Script.Dev.Entry") -- 1902
	return Entry.getCurrentEntryStatus() -- 1903
end) -- 1901
HttpServer:postSchedule("/run", function(req) -- 1905
	do -- 1906
		local _type_0 = type(req) -- 1906
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1906
		if _tab_0 then -- 1906
			local file -- 1906
			do -- 1906
				local _obj_0 = req.body -- 1906
				local _type_1 = type(_obj_0) -- 1906
				if "table" == _type_1 or "userdata" == _type_1 then -- 1906
					file = _obj_0.file -- 1906
				end -- 1906
			end -- 1906
			local asProj -- 1906
			do -- 1906
				local _obj_0 = req.body -- 1906
				local _type_1 = type(_obj_0) -- 1906
				if "table" == _type_1 or "userdata" == _type_1 then -- 1906
					asProj = _obj_0.asProj -- 1906
				end -- 1906
			end -- 1906
			if file ~= nil and asProj ~= nil then -- 1906
				if not Content:isAbsolutePath(file) then -- 1907
					local devFile = Path(Content.writablePath, file) -- 1908
					if Content:exist(devFile) then -- 1909
						file = devFile -- 1909
					end -- 1909
				end -- 1907
				local Entry = require("Script.Dev.Entry") -- 1910
				local workDir -- 1911
				if asProj then -- 1912
					workDir = getProjectDirFromFile(file) -- 1913
					if workDir then -- 1913
						Entry.allClear() -- 1914
						local target = Path(workDir, "init") -- 1915
						local success, err = Entry.enterEntryAsync({ -- 1916
							entryName = "Project", -- 1916
							fileName = target, -- 1916
							workDir = workDir, -- 1916
							projectRoot = workDir, -- 1916
							runKind = "project" -- 1916
						}) -- 1916
						target = Path:getName(Path:getPath(target)) -- 1917
						return { -- 1918
							success = success, -- 1918
							target = target, -- 1918
							err = err -- 1918
						} -- 1918
					end -- 1913
				else -- 1920
					workDir = getProjectDirFromFile(file) -- 1920
				end -- 1912
				Entry.allClear() -- 1921
				file = Path:replaceExt(file, "") -- 1922
				local entry = { -- 1924
					entryName = Path:getName(file), -- 1924
					fileName = file, -- 1925
					runKind = "file" -- 1926
				} -- 1923
				if workDir then -- 1927
					entry.workDir = workDir -- 1928
					entry.projectRoot = workDir -- 1929
				end -- 1927
				local success, err = Entry.enterEntryAsync(entry) -- 1930
				return { -- 1931
					success = success, -- 1931
					err = err -- 1931
				} -- 1931
			end -- 1906
		end -- 1906
	end -- 1906
	return { -- 1905
		success = false -- 1905
	} -- 1905
end) -- 1905
HttpServer:postSchedule("/stop", function() -- 1933
	local Entry = require("Script.Dev.Entry") -- 1934
	return { -- 1935
		success = Entry.stop() -- 1935
	} -- 1935
end) -- 1933
local minifyAsync -- 1937
minifyAsync = function(sourcePath, minifyPath) -- 1937
	if not Content:exist(sourcePath) then -- 1938
		return -- 1938
	end -- 1938
	local Entry = require("Script.Dev.Entry") -- 1939
	local errors = { } -- 1940
	local files = Entry.getAllFiles(sourcePath, { -- 1941
		"lua" -- 1941
	}, true) -- 1941
	do -- 1942
		local _accum_0 = { } -- 1942
		local _len_0 = 1 -- 1942
		for _index_0 = 1, #files do -- 1942
			local file = files[_index_0] -- 1942
			if file:sub(1, 1) ~= '.' then -- 1942
				_accum_0[_len_0] = file -- 1942
				_len_0 = _len_0 + 1 -- 1942
			end -- 1942
		end -- 1942
		files = _accum_0 -- 1942
	end -- 1942
	local paths -- 1943
	do -- 1943
		local _tbl_0 = { } -- 1943
		for _index_0 = 1, #files do -- 1943
			local file = files[_index_0] -- 1943
			_tbl_0[Path:getPath(file)] = true -- 1943
		end -- 1943
		paths = _tbl_0 -- 1943
	end -- 1943
	for path in pairs(paths) do -- 1944
		Content:mkdir(Path(minifyPath, path)) -- 1944
	end -- 1944
	local _ <close> = setmetatable({ }, { -- 1945
		__close = function() -- 1945
			package.loaded["luaminify.FormatMini"] = nil -- 1946
			package.loaded["luaminify.ParseLua"] = nil -- 1947
			package.loaded["luaminify.Scope"] = nil -- 1948
			package.loaded["luaminify.Util"] = nil -- 1949
		end -- 1945
	}) -- 1945
	local FormatMini -- 1950
	do -- 1950
		local _obj_0 = require("luaminify") -- 1950
		FormatMini = _obj_0.FormatMini -- 1950
	end -- 1950
	local fileCount = #files -- 1951
	local count = 0 -- 1952
	for _index_0 = 1, #files do -- 1953
		local file = files[_index_0] -- 1953
		thread(function() -- 1954
			local _ <close> = setmetatable({ }, { -- 1955
				__close = function() -- 1955
					count = count + 1 -- 1955
				end -- 1955
			}) -- 1955
			local input = Path(sourcePath, file) -- 1956
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1957
			if Content:exist(input) then -- 1958
				local sourceCodes = Content:loadAsync(input) -- 1959
				local res, err = FormatMini(sourceCodes) -- 1960
				if res then -- 1961
					Content:saveAsync(output, res) -- 1962
					return print("Minify " .. tostring(file)) -- 1963
				else -- 1965
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1965
				end -- 1961
			else -- 1967
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1967
			end -- 1958
		end) -- 1954
		sleep() -- 1968
	end -- 1953
	wait(function() -- 1969
		return count == fileCount -- 1969
	end) -- 1969
	if #errors > 0 then -- 1970
		print(table.concat(errors, '\n')) -- 1971
	end -- 1970
	print("Obfuscation done.") -- 1972
	return files -- 1973
end -- 1937
local zipping = false -- 1975
HttpServer:postSchedule("/zip", function(req) -- 1977
	do -- 1978
		local _type_0 = type(req) -- 1978
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1978
		if _tab_0 then -- 1978
			local path -- 1978
			do -- 1978
				local _obj_0 = req.body -- 1978
				local _type_1 = type(_obj_0) -- 1978
				if "table" == _type_1 or "userdata" == _type_1 then -- 1978
					path = _obj_0.path -- 1978
				end -- 1978
			end -- 1978
			local zipFile -- 1978
			do -- 1978
				local _obj_0 = req.body -- 1978
				local _type_1 = type(_obj_0) -- 1978
				if "table" == _type_1 or "userdata" == _type_1 then -- 1978
					zipFile = _obj_0.zipFile -- 1978
				end -- 1978
			end -- 1978
			local obfuscated -- 1978
			do -- 1978
				local _obj_0 = req.body -- 1978
				local _type_1 = type(_obj_0) -- 1978
				if "table" == _type_1 or "userdata" == _type_1 then -- 1978
					obfuscated = _obj_0.obfuscated -- 1978
				end -- 1978
			end -- 1978
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1978
				if zipping then -- 1979
					goto failed -- 1979
				end -- 1979
				zipping = true -- 1980
				local _ <close> = setmetatable({ }, { -- 1981
					__close = function() -- 1981
						zipping = false -- 1981
					end -- 1981
				}) -- 1981
				if not Content:exist(path) then -- 1982
					goto failed -- 1982
				end -- 1982
				Content:mkdir(Path:getPath(zipFile)) -- 1983
				if obfuscated then -- 1984
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1985
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1986
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1987
					Content:remove(scriptPath) -- 1988
					Content:remove(obfuscatedPath) -- 1989
					Content:remove(tempPath) -- 1990
					Content:mkdir(scriptPath) -- 1991
					Content:mkdir(obfuscatedPath) -- 1992
					Content:mkdir(tempPath) -- 1993
					if not Content:copyAsync(path, tempPath) then -- 1994
						goto failed -- 1994
					end -- 1994
					local Entry = require("Script.Dev.Entry") -- 1995
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1996
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1997
						"tl", -- 1997
						"yue", -- 1997
						"lua", -- 1997
						"ts", -- 1997
						"tsx", -- 1997
						"vs", -- 1997
						"bl", -- 1997
						"xml", -- 1997
						"wa", -- 1997
						"mod" -- 1997
					}, true) -- 1997
					for _index_0 = 1, #scriptFiles do -- 1998
						local file = scriptFiles[_index_0] -- 1998
						Content:remove(Path(tempPath, file)) -- 1999
					end -- 1998
					for _index_0 = 1, #luaFiles do -- 2000
						local file = luaFiles[_index_0] -- 2000
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2001
					end -- 2000
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2002
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2003
					end) then -- 2002
						goto failed -- 2002
					end -- 2002
					return { -- 2004
						success = true -- 2004
					} -- 2004
				else -- 2006
					return { -- 2006
						success = Content:zipAsync(path, zipFile, function(file) -- 2006
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2007
						end) -- 2006
					} -- 2006
				end -- 1984
			end -- 1978
		end -- 1978
	end -- 1978
	::failed:: -- 2008
	return { -- 1977
		success = false -- 1977
	} -- 1977
end) -- 1977
HttpServer:postSchedule("/unzip", function(req) -- 2010
	do -- 2011
		local _type_0 = type(req) -- 2011
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2011
		if _tab_0 then -- 2011
			local zipFile -- 2011
			do -- 2011
				local _obj_0 = req.body -- 2011
				local _type_1 = type(_obj_0) -- 2011
				if "table" == _type_1 or "userdata" == _type_1 then -- 2011
					zipFile = _obj_0.zipFile -- 2011
				end -- 2011
			end -- 2011
			local path -- 2011
			do -- 2011
				local _obj_0 = req.body -- 2011
				local _type_1 = type(_obj_0) -- 2011
				if "table" == _type_1 or "userdata" == _type_1 then -- 2011
					path = _obj_0.path -- 2011
				end -- 2011
			end -- 2011
			if zipFile ~= nil and path ~= nil then -- 2011
				return { -- 2012
					success = Content:unzipAsync(zipFile, path, function(file) -- 2012
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2013
					end) -- 2012
				} -- 2012
			end -- 2011
		end -- 2011
	end -- 2011
	return { -- 2010
		success = false -- 2010
	} -- 2010
end) -- 2010
HttpServer:post("/editing-info", function(req) -- 2015
	local Entry = require("Script.Dev.Entry") -- 2016
	local config = Entry.getConfig() -- 2017
	local _type_0 = type(req) -- 2018
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2018
	local _match_0 = false -- 2018
	if _tab_0 then -- 2018
		local editingInfo -- 2018
		do -- 2018
			local _obj_0 = req.body -- 2018
			local _type_1 = type(_obj_0) -- 2018
			if "table" == _type_1 or "userdata" == _type_1 then -- 2018
				editingInfo = _obj_0.editingInfo -- 2018
			end -- 2018
		end -- 2018
		if editingInfo ~= nil then -- 2018
			_match_0 = true -- 2018
			config.editingInfo = editingInfo -- 2019
			return { -- 2020
				success = true -- 2020
			} -- 2020
		end -- 2018
	end -- 2018
	if not _match_0 then -- 2018
		if not (config.editingInfo ~= nil) then -- 2022
			local folder -- 2023
			if App.locale:match('^zh') then -- 2023
				folder = 'zh-Hans' -- 2023
			else -- 2023
				folder = 'en' -- 2023
			end -- 2023
			config.editingInfo = json.encode({ -- 2025
				index = 0, -- 2025
				files = { -- 2027
					{ -- 2028
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2028
						title = "welcome.md" -- 2029
					} -- 2027
				} -- 2026
			}) -- 2024
		end -- 2022
		return { -- 2033
			success = true, -- 2033
			editingInfo = config.editingInfo -- 2033
		} -- 2033
	end -- 2018
end) -- 2015
HttpServer:post("/command", function(req) -- 2035
	do -- 2036
		local _type_0 = type(req) -- 2036
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2036
		if _tab_0 then -- 2036
			local code -- 2036
			do -- 2036
				local _obj_0 = req.body -- 2036
				local _type_1 = type(_obj_0) -- 2036
				if "table" == _type_1 or "userdata" == _type_1 then -- 2036
					code = _obj_0.code -- 2036
				end -- 2036
			end -- 2036
			local log -- 2036
			do -- 2036
				local _obj_0 = req.body -- 2036
				local _type_1 = type(_obj_0) -- 2036
				if "table" == _type_1 or "userdata" == _type_1 then -- 2036
					log = _obj_0.log -- 2036
				end -- 2036
			end -- 2036
			if code ~= nil and log ~= nil then -- 2036
				emit("AppCommand", code, log) -- 2037
				return { -- 2038
					success = true -- 2038
				} -- 2038
			end -- 2036
		end -- 2036
	end -- 2036
	return { -- 2035
		success = false -- 2035
	} -- 2035
end) -- 2035
HttpServer:post("/log/save", function() -- 2040
	local folder = ".download" -- 2041
	local fullLogFile = "dora_full_logs.txt" -- 2042
	local fullFolder = Path(Content.writablePath, folder) -- 2043
	Content:mkdir(fullFolder) -- 2044
	local logPath = Path(fullFolder, fullLogFile) -- 2045
	if App:saveLog(logPath) then -- 2046
		return { -- 2047
			success = true, -- 2047
			path = Path(folder, fullLogFile) -- 2047
		} -- 2047
	end -- 2046
	return { -- 2040
		success = false -- 2040
	} -- 2040
end) -- 2040
HttpServer:post("/yarn/check", function(req) -- 2049
	local yarncompile = require("yarncompile") -- 2050
	do -- 2051
		local _type_0 = type(req) -- 2051
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2051
		if _tab_0 then -- 2051
			local code -- 2051
			do -- 2051
				local _obj_0 = req.body -- 2051
				local _type_1 = type(_obj_0) -- 2051
				if "table" == _type_1 or "userdata" == _type_1 then -- 2051
					code = _obj_0.code -- 2051
				end -- 2051
			end -- 2051
			if code ~= nil then -- 2051
				local jsonObject = json.decode(code) -- 2052
				if jsonObject then -- 2052
					local errors = { } -- 2053
					local _list_0 = jsonObject.nodes -- 2054
					for _index_0 = 1, #_list_0 do -- 2054
						local node = _list_0[_index_0] -- 2054
						local title, body = node.title, node.body -- 2055
						local luaCode, err = yarncompile(body) -- 2056
						if not luaCode then -- 2056
							errors[#errors + 1] = title .. ":" .. err -- 2057
						end -- 2056
					end -- 2054
					return { -- 2058
						success = true, -- 2058
						syntaxError = table.concat(errors, "\n\n") -- 2058
					} -- 2058
				end -- 2052
			end -- 2051
		end -- 2051
	end -- 2051
	return { -- 2049
		success = false -- 2049
	} -- 2049
end) -- 2049
HttpServer:post("/yarn/check-file", function(req) -- 2060
	local yarncompile = require("yarncompile") -- 2061
	do -- 2062
		local _type_0 = type(req) -- 2062
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2062
		if _tab_0 then -- 2062
			local code -- 2062
			do -- 2062
				local _obj_0 = req.body -- 2062
				local _type_1 = type(_obj_0) -- 2062
				if "table" == _type_1 or "userdata" == _type_1 then -- 2062
					code = _obj_0.code -- 2062
				end -- 2062
			end -- 2062
			if code ~= nil then -- 2062
				local res, _, err = yarncompile(code, true) -- 2063
				if not res then -- 2063
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2064
					return { -- 2065
						success = false, -- 2065
						message = message, -- 2065
						line = line, -- 2065
						column = column, -- 2065
						node = node -- 2065
					} -- 2065
				end -- 2063
			end -- 2062
		end -- 2062
	end -- 2062
	return { -- 2060
		success = true -- 2060
	} -- 2060
end) -- 2060
local getWaProjectDirFromFile -- 2067
getWaProjectDirFromFile = function(file) -- 2067
	local writablePath = Content.writablePath -- 2068
	local parent, current -- 2069
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 2069
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 2070
	else -- 2072
		parent, current = nil, nil -- 2072
	end -- 2069
	if not current then -- 2073
		return nil -- 2073
	end -- 2073
	repeat -- 2074
		current = Path:getPath(current) -- 2075
		if current == "" then -- 2076
			break -- 2076
		end -- 2076
		local _list_0 = Content:getFiles(Path(parent, current)) -- 2077
		for _index_0 = 1, #_list_0 do -- 2077
			local f = _list_0[_index_0] -- 2077
			if Path:getFilename(f):lower() == "wa.mod" then -- 2078
				return Path(parent, current, Path:getPath(f)) -- 2079
			end -- 2078
		end -- 2077
	until false -- 2074
	return nil -- 2081
end -- 2067
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2083
	do -- 2084
		local _type_0 = type(req) -- 2084
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2084
		if _tab_0 then -- 2084
			local path -- 2084
			do -- 2084
				local _obj_0 = req.body -- 2084
				local _type_1 = type(_obj_0) -- 2084
				if "table" == _type_1 or "userdata" == _type_1 then -- 2084
					path = _obj_0.path -- 2084
				end -- 2084
			end -- 2084
			if path ~= nil then -- 2084
				local projDir = getWaProjectDirFromFile(path) -- 2085
				if projDir then -- 2085
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2086
					if not Content:exist(sourceDoraPath) then -- 2087
						return { -- 2088
							success = false, -- 2088
							message = "missing dora template" -- 2088
						} -- 2088
					end -- 2087
					local targetVendorPath = Path(projDir, "vendor") -- 2089
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2090
					if not Content:exist(targetVendorPath) then -- 2091
						if not Content:mkdir(targetVendorPath) then -- 2092
							return { -- 2093
								success = false, -- 2093
								message = "failed to create vendor folder" -- 2093
							} -- 2093
						end -- 2092
					elseif not Content:isdir(targetVendorPath) then -- 2094
						return { -- 2095
							success = false, -- 2095
							message = "vendor path is not a folder" -- 2095
						} -- 2095
					end -- 2091
					if Content:exist(targetDoraPath) then -- 2096
						if not Content:remove(targetDoraPath) then -- 2097
							return { -- 2098
								success = false, -- 2098
								message = "failed to remove old dora" -- 2098
							} -- 2098
						end -- 2097
					end -- 2096
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2099
						return { -- 2100
							success = false, -- 2100
							message = "failed to copy dora" -- 2100
						} -- 2100
					end -- 2099
					return { -- 2101
						success = true -- 2101
					} -- 2101
				else -- 2103
					return { -- 2103
						success = false, -- 2103
						message = 'Wa file needs a project' -- 2103
					} -- 2103
				end -- 2085
			end -- 2084
		end -- 2084
	end -- 2084
	return { -- 2083
		success = false, -- 2083
		message = "invalid call" -- 2083
	} -- 2083
end) -- 2083
HttpServer:postSchedule("/wa/build", function(req) -- 2105
	do -- 2106
		local _type_0 = type(req) -- 2106
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2106
		if _tab_0 then -- 2106
			local path -- 2106
			do -- 2106
				local _obj_0 = req.body -- 2106
				local _type_1 = type(_obj_0) -- 2106
				if "table" == _type_1 or "userdata" == _type_1 then -- 2106
					path = _obj_0.path -- 2106
				end -- 2106
			end -- 2106
			if path ~= nil then -- 2106
				local projDir = getWaProjectDirFromFile(path) -- 2107
				if projDir then -- 2107
					local message = Wasm:buildWaAsync(projDir) -- 2108
					if message == "" then -- 2109
						return { -- 2110
							success = true -- 2110
						} -- 2110
					else -- 2112
						return { -- 2112
							success = false, -- 2112
							message = message -- 2112
						} -- 2112
					end -- 2109
				else -- 2114
					return { -- 2114
						success = false, -- 2114
						message = 'Wa file needs a project' -- 2114
					} -- 2114
				end -- 2107
			end -- 2106
		end -- 2106
	end -- 2106
	return { -- 2115
		success = false, -- 2115
		message = 'failed to build' -- 2115
	} -- 2115
end) -- 2105
HttpServer:postSchedule("/wa/format", function(req) -- 2117
	do -- 2118
		local _type_0 = type(req) -- 2118
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2118
		if _tab_0 then -- 2118
			local file -- 2118
			do -- 2118
				local _obj_0 = req.body -- 2118
				local _type_1 = type(_obj_0) -- 2118
				if "table" == _type_1 or "userdata" == _type_1 then -- 2118
					file = _obj_0.file -- 2118
				end -- 2118
			end -- 2118
			if file ~= nil then -- 2118
				local code = Wasm:formatWaAsync(file) -- 2119
				if code == "" then -- 2120
					return { -- 2121
						success = false -- 2121
					} -- 2121
				else -- 2123
					return { -- 2123
						success = true, -- 2123
						code = code -- 2123
					} -- 2123
				end -- 2120
			end -- 2118
		end -- 2118
	end -- 2118
	return { -- 2124
		success = false -- 2124
	} -- 2124
end) -- 2117
HttpServer:postSchedule("/wa/create", function(req) -- 2126
	do -- 2127
		local _type_0 = type(req) -- 2127
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2127
		if _tab_0 then -- 2127
			local path -- 2127
			do -- 2127
				local _obj_0 = req.body -- 2127
				local _type_1 = type(_obj_0) -- 2127
				if "table" == _type_1 or "userdata" == _type_1 then -- 2127
					path = _obj_0.path -- 2127
				end -- 2127
			end -- 2127
			if path ~= nil then -- 2127
				if not Content:exist(Path:getPath(path)) then -- 2128
					return { -- 2129
						success = false, -- 2129
						message = "target path not existed" -- 2129
					} -- 2129
				end -- 2128
				if Content:exist(path) then -- 2130
					return { -- 2131
						success = false, -- 2131
						message = "target project folder existed" -- 2131
					} -- 2131
				end -- 2130
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2132
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2133
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2134
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2135
					return { -- 2138
						success = false, -- 2138
						message = "missing template project" -- 2138
					} -- 2138
				end -- 2135
				if not Content:mkdir(path) then -- 2139
					return { -- 2140
						success = false, -- 2140
						message = "failed to create project folder" -- 2140
					} -- 2140
				end -- 2139
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2141
					Content:remove(path) -- 2142
					return { -- 2143
						success = false, -- 2143
						message = "failed to copy template" -- 2143
					} -- 2143
				end -- 2141
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2144
					Content:remove(path) -- 2145
					return { -- 2146
						success = false, -- 2146
						message = "failed to copy template" -- 2146
					} -- 2146
				end -- 2144
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2147
					Content:remove(path) -- 2148
					return { -- 2149
						success = false, -- 2149
						message = "failed to copy template" -- 2149
					} -- 2149
				end -- 2147
				return { -- 2150
					success = true -- 2150
				} -- 2150
			end -- 2127
		end -- 2127
	end -- 2127
	return { -- 2126
		success = false, -- 2126
		message = "invalid call" -- 2126
	} -- 2126
end) -- 2126
local tsBuildGlobs = { -- 2153
	"**/*.ts", -- 2153
	"**/*.tsx", -- 2154
	"!**/.*/**", -- 2155
	"!**/node_modules/**" -- 2156
} -- 2152
local _anon_func_6 = function(path) -- 2165
	local _val_0 = Path:getExt(path) -- 2165
	return "ts" == _val_0 or "tsx" == _val_0 -- 2165
end -- 2165
HttpServer:postSchedule("/ts/build", function(req) -- 2158
	do -- 2159
		local _type_0 = type(req) -- 2159
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2159
		if _tab_0 then -- 2159
			local path -- 2159
			do -- 2159
				local _obj_0 = req.body -- 2159
				local _type_1 = type(_obj_0) -- 2159
				if "table" == _type_1 or "userdata" == _type_1 then -- 2159
					path = _obj_0.path -- 2159
				end -- 2159
			end -- 2159
			if path ~= nil then -- 2159
				if HttpServer.wsConnectionCount == 0 then -- 2160
					return { -- 2161
						success = false, -- 2161
						message = "Web IDE not connected" -- 2161
					} -- 2161
				end -- 2160
				if not Content:exist(path) then -- 2162
					return { -- 2163
						success = false, -- 2163
						message = "path not existed" -- 2163
					} -- 2163
				end -- 2162
				if not Content:isdir(path) then -- 2164
					if not (_anon_func_6(path)) then -- 2165
						return { -- 2166
							success = false, -- 2166
							message = "expecting a TypeScript file" -- 2166
						} -- 2166
					end -- 2165
					local messages = { } -- 2167
					local content = Content:load(path) -- 2168
					if not content then -- 2169
						return { -- 2170
							success = false, -- 2170
							message = "failed to read file" -- 2170
						} -- 2170
					end -- 2169
					emit("AppWS", "Send", json.encode({ -- 2171
						name = "UpdateFile", -- 2171
						file = path, -- 2171
						exists = true, -- 2171
						content = content -- 2171
					})) -- 2171
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2172
						local done = false -- 2173
						do -- 2174
							local _with_0 = Node() -- 2174
							_with_0:gslot("AppWS", function(event) -- 2175
								if event.type == "Receive" then -- 2176
									local res = json.decode(event.msg) -- 2177
									if res then -- 2177
										if res.name == "TranspileTS" and res.file == path then -- 2178
											_with_0:removeFromParent() -- 2179
											if res.success then -- 2180
												local luaFile = Path:replaceExt(path, "lua") -- 2181
												Content:save(luaFile, res.luaCode) -- 2182
												messages[#messages + 1] = { -- 2183
													success = true, -- 2183
													file = path -- 2183
												} -- 2183
											else -- 2185
												messages[#messages + 1] = { -- 2185
													success = false, -- 2185
													file = path, -- 2185
													message = res.message -- 2185
												} -- 2185
											end -- 2180
											done = true -- 2186
										end -- 2178
									end -- 2177
								end -- 2176
							end) -- 2175
						end -- 2174
						emit("AppWS", "Send", json.encode({ -- 2187
							name = "TranspileTS", -- 2187
							file = path, -- 2187
							content = content -- 2187
						})) -- 2187
						wait(function() -- 2188
							return done -- 2188
						end) -- 2188
					end -- 2172
					return { -- 2189
						success = true, -- 2189
						messages = messages -- 2189
					} -- 2189
				else -- 2191
					local fileData = { } -- 2191
					local messages = { } -- 2192
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2193
					for _index_0 = 1, #_list_0 do -- 2193
						local subFile = _list_0[_index_0] -- 2193
						local file = Path(path, subFile) -- 2194
						local content = Content:load(file) -- 2195
						if content then -- 2195
							fileData[file] = content -- 2196
							emit("AppWS", "Send", json.encode({ -- 2197
								name = "UpdateFile", -- 2197
								file = file, -- 2197
								exists = true, -- 2197
								content = content -- 2197
							})) -- 2197
						else -- 2199
							messages[#messages + 1] = { -- 2199
								success = false, -- 2199
								file = file, -- 2199
								message = "failed to read file" -- 2199
							} -- 2199
						end -- 2195
					end -- 2193
					for file, content in pairs(fileData) do -- 2200
						if "d" == Path:getExt(Path:getName(file)) then -- 2201
							goto _continue_0 -- 2201
						end -- 2201
						local done = false -- 2202
						do -- 2203
							local _with_0 = Node() -- 2203
							_with_0:gslot("AppWS", function(event) -- 2204
								if event.type == "Receive" then -- 2205
									local res = json.decode(event.msg) -- 2206
									if res then -- 2206
										if res.name == "TranspileTS" and res.file == file then -- 2207
											_with_0:removeFromParent() -- 2208
											if res.success then -- 2209
												local luaFile = Path:replaceExt(file, "lua") -- 2210
												Content:save(luaFile, res.luaCode) -- 2211
												messages[#messages + 1] = { -- 2212
													success = true, -- 2212
													file = file -- 2212
												} -- 2212
											else -- 2214
												messages[#messages + 1] = { -- 2214
													success = false, -- 2214
													file = file, -- 2214
													message = res.message -- 2214
												} -- 2214
											end -- 2209
											done = true -- 2215
										end -- 2207
									end -- 2206
								end -- 2205
							end) -- 2204
						end -- 2203
						emit("AppWS", "Send", json.encode({ -- 2216
							name = "TranspileTS", -- 2216
							file = file, -- 2216
							content = content -- 2216
						})) -- 2216
						wait(function() -- 2217
							return done -- 2217
						end) -- 2217
						::_continue_0:: -- 2201
					end -- 2200
					return { -- 2218
						success = true, -- 2218
						messages = messages -- 2218
					} -- 2218
				end -- 2164
			end -- 2159
		end -- 2159
	end -- 2159
	return { -- 2158
		success = false -- 2158
	} -- 2158
end) -- 2158
HttpServer:post("/download", function(req) -- 2220
	do -- 2221
		local _type_0 = type(req) -- 2221
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2221
		if _tab_0 then -- 2221
			local url -- 2221
			do -- 2221
				local _obj_0 = req.body -- 2221
				local _type_1 = type(_obj_0) -- 2221
				if "table" == _type_1 or "userdata" == _type_1 then -- 2221
					url = _obj_0.url -- 2221
				end -- 2221
			end -- 2221
			local target -- 2221
			do -- 2221
				local _obj_0 = req.body -- 2221
				local _type_1 = type(_obj_0) -- 2221
				if "table" == _type_1 or "userdata" == _type_1 then -- 2221
					target = _obj_0.target -- 2221
				end -- 2221
			end -- 2221
			if url ~= nil and target ~= nil then -- 2221
				local Entry = require("Script.Dev.Entry") -- 2222
				Entry.downloadFile(url, target) -- 2223
				return { -- 2224
					success = true -- 2224
				} -- 2224
			end -- 2221
		end -- 2221
	end -- 2221
	return { -- 2220
		success = false -- 2220
	} -- 2220
end) -- 2220
local status = { } -- 2226
_module_0 = status -- 2227
status.buildAsync = function(path) -- 2229
	if not Content:exist(path) then -- 2230
		return { -- 2231
			success = false, -- 2231
			file = path, -- 2231
			message = "file not existed" -- 2231
		} -- 2231
	end -- 2230
	do -- 2232
		local _exp_0 = Path:getExt(path) -- 2232
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2232
			if '' == Path:getExt(Path:getName(path)) then -- 2233
				local content = Content:loadAsync(path) -- 2234
				if content then -- 2234
					local resultCodes, err = compileFileAsync(path, content) -- 2235
					if resultCodes then -- 2235
						return { -- 2236
							success = true, -- 2236
							file = path -- 2236
						} -- 2236
					else -- 2238
						return { -- 2238
							success = false, -- 2238
							file = path, -- 2238
							message = err -- 2238
						} -- 2238
					end -- 2235
				end -- 2234
			end -- 2233
		elseif "lua" == _exp_0 then -- 2239
			local content = Content:loadAsync(path) -- 2240
			if content then -- 2240
				do -- 2241
					local isTIC80 = CheckTIC80Code(content) -- 2241
					if isTIC80 then -- 2241
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2242
					end -- 2241
				end -- 2241
				local success, info -- 2243
				do -- 2243
					local _obj_0 = luaCheck(path, content) -- 2243
					success, info = _obj_0.success, _obj_0.info -- 2243
				end -- 2243
				if success then -- 2244
					return { -- 2245
						success = true, -- 2245
						file = path -- 2245
					} -- 2245
				elseif info and #info > 0 then -- 2246
					local messages = { } -- 2247
					for _index_0 = 1, #info do -- 2248
						local _des_0 = info[_index_0] -- 2248
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2248
						local lineText = "" -- 2249
						if line then -- 2250
							local currentLine = 1 -- 2251
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2252
								if currentLine == line then -- 2253
									lineText = text -- 2254
									break -- 2255
								end -- 2253
								currentLine = currentLine + 1 -- 2256
							end -- 2252
						end -- 2250
						if line then -- 2257
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2258
						else -- 2260
							messages[#messages + 1] = message -- 2260
						end -- 2257
					end -- 2248
					return { -- 2261
						success = false, -- 2261
						file = path, -- 2261
						message = table.concat(messages, "\n") -- 2261
					} -- 2261
				else -- 2263
					return { -- 2263
						success = false, -- 2263
						file = path, -- 2263
						message = "lua check failed" -- 2263
					} -- 2263
				end -- 2244
			end -- 2240
		elseif "yarn" == _exp_0 then -- 2264
			local content = Content:loadAsync(path) -- 2265
			if content then -- 2265
				local res, _, err = yarncompile(content, true) -- 2266
				if res then -- 2266
					return { -- 2267
						success = true, -- 2267
						file = path -- 2267
					} -- 2267
				else -- 2269
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2269
					local lineText = "" -- 2270
					if line then -- 2271
						local currentLine = 1 -- 2272
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2273
							if currentLine == line then -- 2274
								lineText = text -- 2275
								break -- 2276
							end -- 2274
							currentLine = currentLine + 1 -- 2277
						end -- 2273
					end -- 2271
					if node ~= "" then -- 2278
						node = "node: " .. tostring(node) .. ", " -- 2279
					else -- 2280
						node = "" -- 2280
					end -- 2278
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2281
					return { -- 2282
						success = false, -- 2282
						file = path, -- 2282
						message = message -- 2282
					} -- 2282
				end -- 2266
			end -- 2265
		end -- 2232
	end -- 2232
	return { -- 2283
		success = false, -- 2283
		file = path, -- 2283
		message = "invalid file to build" -- 2283
	} -- 2283
end -- 2229
thread(function() -- 2285
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 2286
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 2287
	if Content:exist(doraWeb) then -- 2288
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) -- 2289
		local needReload -- 2290
		if Content:exist(doraReady) then -- 2290
			needReload = readyContent ~= Content:load(doraReady) -- 2291
		else -- 2292
			needReload = true -- 2292
		end -- 2290
		if needReload then -- 2293
			Content:remove(Path(Content.appPath, ".www")) -- 2294
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 2295
			Content:save(doraReady, readyContent) -- 2299
			print("Dora Dora is ready!") -- 2300
		end -- 2293
	end -- 2288
	if HttpServer:start(8866) then -- 2301
		local localIP = HttpServer.localIP -- 2302
		if localIP == "" then -- 2303
			localIP = "localhost" -- 2303
		end -- 2303
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 2304
		return HttpServer:startWS(8868) -- 2305
	else -- 2307
		status.url = nil -- 2307
		return print("8866 Port not available!") -- 2308
	end -- 2301
end) -- 2285
return _module_0 -- 1
