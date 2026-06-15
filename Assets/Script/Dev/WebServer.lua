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
	local logRes = gitRunSync(repoPath, "log -n 100", nil, 10) -- 479
	local logStatus -- 480
	if logRes.success then -- 480
		logStatus = logRes.status -- 481
	else -- 483
		logStatus = { -- 484
			state = "done", -- 484
			kind = "log", -- 485
			repoPath = repoPath, -- 486
			progress = 1, -- 487
			message = "git log completed", -- 488
			data = { -- 489
				commits = { } -- 489
			} -- 489
		} -- 483
	end -- 480
	local hasCommit = logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] ~= nil -- 491
	local tagStatus -- 492
	if hasCommit then -- 492
		tagStatus = (gitRunSync(repoPath, "tag", nil, 10)).status -- 493
	else -- 495
		tagStatus = { -- 496
			state = "done", -- 496
			kind = "tag", -- 497
			repoPath = repoPath, -- 498
			progress = 1, -- 499
			message = "git tag completed", -- 500
			data = { -- 501
				tags = { } -- 501
			} -- 501
		} -- 495
	end -- 492
	local defaultRemote = gitDefaultRemote(remoteStatus) -- 503
	local lastCommit = nil -- 504
	if logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] then -- 505
		lastCommit = logStatus.data.commits[1] -- 506
	end -- 505
	return { -- 508
		success = true, -- 508
		isRepo = true, -- 509
		clean = status.data and status.data.clean or false, -- 510
		currentBranch = currentBranch, -- 511
		defaultRemote = defaultRemote, -- 512
		remotes = remoteStatus and remoteStatus.data and remoteStatus.data.remotes or { }, -- 513
		branches = branches, -- 514
		lastCommit = lastCommit, -- 515
		status = status, -- 516
		branchStatus = branchStatus, -- 517
		remoteStatus = remoteStatus, -- 518
		historyStatus = logStatus, -- 519
		tagStatus = tagStatus -- 520
	} -- 507
end -- 468
HttpServer:post("/git/run", function(req) -- 522
	do -- 523
		local _type_0 = type(req) -- 523
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 523
		if _tab_0 then -- 523
			local body = req.body -- 523
			if body ~= nil then -- 523
				local repoPath, command, authId, optionsJSON = body.repoPath, body.command, body.authId, body.optionsJSON -- 524
				if authId and not optionsJSON then -- 525
					local credential = gitLoadCredential(authId) -- 526
					if credential then -- 526
						optionsJSON = gitAuthOptionsJSON(credential) -- 527
						DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 528
							os.time(), -- 528
							credential.id -- 528
						}) -- 528
					end -- 526
				elseif not optionsJSON then -- 529
					local authOk, authSelection = pcall(gitAuthSelectionForCommand, repoPath, command) -- 530
					if not authOk then -- 531
						authSelection = nil -- 531
					end -- 531
					if authSelection then -- 532
						if #authSelection.items == 1 then -- 533
							local credential = gitLoadCredential(authSelection.items[1].id) -- 534
							optionsJSON = gitAuthOptionsJSON(credential) -- 535
							DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 536
								os.time(), -- 536
								credential.id -- 536
							}) -- 536
						else -- 538
							return { -- 538
								success = false, -- 538
								message = "select a Git credential", -- 538
								needsCredentialSelection = true, -- 538
								host = authSelection.host, -- 538
								credentials = authSelection.items -- 538
							} -- 538
						end -- 533
					end -- 532
				end -- 525
				local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 539
				if not jobId then -- 540
					return { -- 540
						success = false, -- 540
						message = err -- 540
					} -- 540
				end -- 540
				return { -- 541
					success = true, -- 541
					jobId = jobId -- 541
				} -- 541
			end -- 523
		end -- 523
	end -- 523
	return invalidArguments -- 522
end) -- 522
HttpServer:post("/git/status", function(req) -- 543
	do -- 544
		local _type_0 = type(req) -- 544
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 544
		if _tab_0 then -- 544
			local jobId -- 544
			do -- 544
				local _obj_0 = req.body -- 544
				local _type_1 = type(_obj_0) -- 544
				if "table" == _type_1 or "userdata" == _type_1 then -- 544
					jobId = _obj_0.jobId -- 544
				end -- 544
			end -- 544
			if jobId ~= nil then -- 544
				local job = GitJobs[tonumber(jobId) or 0] -- 545
				if not job then -- 546
					return { -- 546
						success = false, -- 546
						message = "git job not found" -- 546
					} -- 546
				end -- 546
				return { -- 547
					success = true, -- 547
					status = job.status, -- 547
					command = job.command -- 547
				} -- 547
			end -- 544
		end -- 544
	end -- 544
	return invalidArguments -- 543
end) -- 543
HttpServer:post("/git/cancel", function(req) -- 549
	do -- 550
		local _type_0 = type(req) -- 550
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 550
		if _tab_0 then -- 550
			local jobId -- 550
			do -- 550
				local _obj_0 = req.body -- 550
				local _type_1 = type(_obj_0) -- 550
				if "table" == _type_1 or "userdata" == _type_1 then -- 550
					jobId = _obj_0.jobId -- 550
				end -- 550
			end -- 550
			if jobId ~= nil then -- 550
				local id = tonumber(jobId) -- 551
				if not id then -- 552
					return { -- 552
						success = false, -- 552
						message = "invalid jobId" -- 552
					} -- 552
				end -- 552
				return { -- 553
					success = Git:cancel(id) -- 553
				} -- 553
			end -- 550
		end -- 550
	end -- 550
	return invalidArguments -- 549
end) -- 549
HttpServer:postSchedule("/git/summary", function(req) -- 555
	do -- 556
		local _type_0 = type(req) -- 556
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 556
		if _tab_0 then -- 556
			local repoPath -- 556
			do -- 556
				local _obj_0 = req.body -- 556
				local _type_1 = type(_obj_0) -- 556
				if "table" == _type_1 or "userdata" == _type_1 then -- 556
					repoPath = _obj_0.repoPath -- 556
				end -- 556
			end -- 556
			if repoPath ~= nil then -- 556
				if gitInvalidRepoPath(repoPath) then -- 557
					return { -- 557
						success = false, -- 557
						message = "invalid repoPath" -- 557
					} -- 557
				end -- 557
				return gitSummary(repoPath) -- 558
			end -- 556
		end -- 556
	end -- 556
	return invalidArguments -- 555
end) -- 555
HttpServer:postSchedule("/git/status-files", function(req) -- 560
	do -- 561
		local _type_0 = type(req) -- 561
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 561
		if _tab_0 then -- 561
			local repoPath -- 561
			do -- 561
				local _obj_0 = req.body -- 561
				local _type_1 = type(_obj_0) -- 561
				if "table" == _type_1 or "userdata" == _type_1 then -- 561
					repoPath = _obj_0.repoPath -- 561
				end -- 561
			end -- 561
			if repoPath ~= nil then -- 561
				return gitRunSync(repoPath, "status", nil, 10) -- 562
			end -- 561
		end -- 561
	end -- 561
	return invalidArguments -- 560
end) -- 560
HttpServer:postSchedule("/git/discard-untracked", function(req) -- 564
	do -- 565
		local _type_0 = type(req) -- 565
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 565
		if _tab_0 then -- 565
			local body = req.body -- 565
			if body ~= nil then -- 565
				local repoPath, paths = body.repoPath, body.paths -- 566
				if gitInvalidRepoPath(repoPath) then -- 567
					return { -- 567
						success = false, -- 567
						message = "invalid repoPath" -- 567
					} -- 567
				end -- 567
				if not (type(paths) == "table") then -- 568
					return { -- 568
						success = false, -- 568
						message = "invalid paths" -- 568
					} -- 568
				end -- 568
				local statusRes = gitRunSync(repoPath, "status", nil, 10) -- 569
				if not statusRes.success then -- 570
					return statusRes -- 570
				end -- 570
				local untracked = { } -- 571
				local _list_0 = (statusRes.status.data and statusRes.status.data.files or { }) -- 572
				for _index_0 = 1, #_list_0 do -- 572
					local file = _list_0[_index_0] -- 572
					if file.staging == "?" or file.worktree == "?" then -- 573
						untracked[file.path] = true -- 574
					end -- 573
				end -- 572
				local removed = { } -- 575
				for _index_0 = 1, #paths do -- 576
					local relPath = paths[_index_0] -- 576
					relPath = tostring(relPath) -- 577
					if not gitPathInsideRepo(repoPath, relPath) then -- 578
						return { -- 578
							success = false, -- 578
							message = "unsafe path: " .. tostring(relPath) -- 578
						} -- 578
					end -- 578
					if not untracked[relPath] then -- 579
						return { -- 579
							success = false, -- 579
							message = "path is not untracked: " .. tostring(relPath) -- 579
						} -- 579
					end -- 579
				end -- 576
				for _index_0 = 1, #paths do -- 580
					local relPath = paths[_index_0] -- 580
					local targetPath = Path(repoPath, tostring(relPath)) -- 581
					if Content:exist(targetPath) then -- 582
						Content:remove(targetPath) -- 583
						removed[#removed + 1] = tostring(relPath) -- 584
					end -- 582
				end -- 580
				return { -- 585
					success = true, -- 585
					removed = removed -- 585
				} -- 585
			end -- 565
		end -- 565
	end -- 565
	return invalidArguments -- 564
end) -- 564
HttpServer:postSchedule("/git/file-diff", function(req) -- 587
	do -- 588
		local _type_0 = type(req) -- 588
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 588
		if _tab_0 then -- 588
			local body = req.body -- 588
			if body ~= nil then -- 588
				local repoPath, path, staged = body.repoPath, body.path, body.staged -- 589
				if gitInvalidRepoPath(repoPath) then -- 590
					return { -- 590
						success = false, -- 590
						message = "invalid repoPath" -- 590
					} -- 590
				end -- 590
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 591
					return { -- 591
						success = false, -- 591
						message = "unsafe path" -- 591
					} -- 591
				end -- 591
				local command -- 592
				if staged == true then -- 592
					command = "diff --staged -- " .. tostring(gitQuote(path)) -- 593
				else -- 595
					command = "diff -- " .. tostring(gitQuote(path)) -- 595
				end -- 592
				local res = gitRunSync(repoPath, command, nil, 10) -- 596
				if not res.success then -- 597
					return res -- 597
				end -- 597
				return { -- 598
					success = true, -- 598
					status = res.status, -- 598
					data = res.status and res.status.data -- 598
				} -- 598
			end -- 588
		end -- 588
	end -- 588
	return invalidArguments -- 587
end) -- 587
HttpServer:postSchedule("/git/commit-file-diff", function(req) -- 600
	do -- 601
		local _type_0 = type(req) -- 601
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 601
		if _tab_0 then -- 601
			local body = req.body -- 601
			if body ~= nil then -- 601
				local repoPath, commit, path = body.repoPath, body.commit, body.path -- 602
				if gitInvalidRepoPath(repoPath) then -- 603
					return { -- 603
						success = false, -- 603
						message = "invalid repoPath" -- 603
					} -- 603
				end -- 603
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 604
					return { -- 604
						success = false, -- 604
						message = "invalid commit" -- 604
					} -- 604
				end -- 604
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 605
					return { -- 605
						success = false, -- 605
						message = "unsafe path" -- 605
					} -- 605
				end -- 605
				local res = gitRunSync(repoPath, "diff " .. tostring(gitQuote(commit)) .. " -- " .. tostring(gitQuote(path)), nil, 10) -- 606
				if not res.success then -- 607
					return res -- 607
				end -- 607
				return { -- 608
					success = true, -- 608
					status = res.status, -- 608
					data = res.status and res.status.data -- 608
				} -- 608
			end -- 601
		end -- 601
	end -- 601
	return invalidArguments -- 600
end) -- 600
HttpServer:postSchedule("/git/history", function(req) -- 610
	do -- 611
		local _type_0 = type(req) -- 611
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 611
		if _tab_0 then -- 611
			local body = req.body -- 611
			if body ~= nil then -- 611
				local repoPath, limit = body.repoPath, body.limit -- 612
				limit = math.max(1, math.min(100, tonumber(limit) or 20)) -- 613
				return gitRunSync(repoPath, "log -n " .. tostring(limit), nil, 10) -- 614
			end -- 611
		end -- 611
	end -- 611
	return invalidArguments -- 610
end) -- 610
HttpServer:postSchedule("/git/remotes", function(req) -- 616
	do -- 617
		local _type_0 = type(req) -- 617
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 617
		if _tab_0 then -- 617
			local body = req.body -- 617
			if body ~= nil then -- 617
				local repoPath, command = body.repoPath, body.command -- 618
				command = command or "remote -v" -- 619
				return gitRunSync(repoPath, command, nil, 10) -- 620
			end -- 617
		end -- 617
	end -- 617
	return invalidArguments -- 616
end) -- 616
HttpServer:postSchedule("/git/branches", function(req) -- 622
	do -- 623
		local _type_0 = type(req) -- 623
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 623
		if _tab_0 then -- 623
			local body = req.body -- 623
			if body ~= nil then -- 623
				local repoPath, command = body.repoPath, body.command -- 624
				command = command or "branch" -- 625
				return gitRunSync(repoPath, command, nil, 10) -- 626
			end -- 623
		end -- 623
	end -- 623
	return invalidArguments -- 622
end) -- 622
HttpServer:postSchedule("/git/tags", function(req) -- 628
	do -- 629
		local _type_0 = type(req) -- 629
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 629
		if _tab_0 then -- 629
			local body = req.body -- 629
			if body ~= nil then -- 629
				local repoPath, command = body.repoPath, body.command -- 630
				command = command or "tag" -- 631
				return gitRunSync(repoPath, command, nil, 10) -- 632
			end -- 629
		end -- 629
	end -- 629
	return invalidArguments -- 628
end) -- 628
HttpServer:post("/git/profile/get", function() -- 634
	ensureGitTables() -- 635
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 636
	local profile -- 637
	if rows and rows[1] then -- 637
		profile = { -- 638
			name = rows[1][1], -- 638
			email = rows[1][2] -- 638
		} -- 638
	else -- 640
		profile = { -- 640
			name = "", -- 640
			email = "" -- 640
		} -- 640
	end -- 637
	return { -- 641
		success = true, -- 641
		profile = profile -- 641
	} -- 641
end) -- 634
HttpServer:post("/git/profile/save", function(req) -- 643
	do -- 644
		local _type_0 = type(req) -- 644
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 644
		if _tab_0 then -- 644
			local name -- 644
			do -- 644
				local _obj_0 = req.body -- 644
				local _type_1 = type(_obj_0) -- 644
				if "table" == _type_1 or "userdata" == _type_1 then -- 644
					name = _obj_0.name -- 644
				end -- 644
			end -- 644
			local email -- 644
			do -- 644
				local _obj_0 = req.body -- 644
				local _type_1 = type(_obj_0) -- 644
				if "table" == _type_1 or "userdata" == _type_1 then -- 644
					email = _obj_0.email -- 644
				end -- 644
			end -- 644
			if name ~= nil and email ~= nil then -- 644
				ensureGitTables() -- 645
				DB:exec("insert into GitProfile(id, name, email, updated_at) values(1, ?, ?, ?) on conflict(id) do update set name = excluded.name, email = excluded.email, updated_at = excluded.updated_at", { -- 647
					tostring(name or ""), -- 647
					tostring(email or ""), -- 648
					os.time() -- 649
				}) -- 646
				return { -- 651
					success = true -- 651
				} -- 651
			end -- 644
		end -- 644
	end -- 644
	return invalidArguments -- 643
end) -- 643
HttpServer:post("/git/auth/list", function(req) -- 653
	ensureGitTables() -- 654
	local host = nil -- 655
	do -- 656
		local _type_0 = type(req) -- 656
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 656
		if _tab_0 then -- 656
			local body = req.body -- 656
			if body ~= nil then -- 656
				host = body.host -- 657
			end -- 656
		end -- 656
	end -- 656
	local rows -- 658
	if host and host ~= "" then -- 658
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by host asc, label asc, id asc", { -- 659
			tostring(host):lower() -- 659
		}) -- 659
	else -- 661
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential order by host asc, label asc, id asc") -- 661
	end -- 658
	local items -- 662
	if rows then -- 662
		local _accum_0 = { } -- 663
		local _len_0 = 1 -- 663
		for _index_0 = 1, #rows do -- 663
			local row = rows[_index_0] -- 663
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 663
			_len_0 = _len_0 + 1 -- 663
		end -- 663
		items = _accum_0 -- 663
	else -- 664
		items = { } -- 664
	end -- 662
	return { -- 665
		success = true, -- 665
		items = items -- 665
	} -- 665
end) -- 653
HttpServer:postSchedule("/git/auth/match", function(req) -- 667
	do -- 668
		local _type_0 = type(req) -- 668
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 668
		local _match_0 = false -- 668
		if _tab_0 then -- 668
			local body = req.body -- 668
			if body ~= nil then -- 668
				_match_0 = true -- 668
				local repoPath, command, url = body.repoPath, body.command, body.url -- 669
				local host -- 670
				if url and url ~= "" then -- 670
					host = gitHostFromURL(url) -- 670
				else -- 670
					host = gitCommandHost(repoPath, command) -- 670
				end -- 670
				if not host then -- 671
					return { -- 671
						success = false, -- 671
						message = "git host is required" -- 671
					} -- 671
				end -- 671
				local items = gitCredentialsForHost(host) -- 672
				return { -- 673
					success = true, -- 673
					host = host, -- 673
					items = items, -- 673
					needsSelection = #items > 1, -- 673
					authId = (#items == 1 and items[1].id or nil) -- 673
				} -- 673
			end -- 668
		end -- 668
		if not _match_0 then -- 668
			return { -- 675
				success = false, -- 675
				message = "invalid arguments" -- 675
			} -- 675
		end -- 668
	end -- 668
	return invalidArguments -- 667
end) -- 667
HttpServer:post("/git/auth/save", function(req) -- 677
	do -- 678
		local _type_0 = type(req) -- 678
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 678
		if _tab_0 then -- 678
			local body = req.body -- 678
			if body ~= nil then -- 678
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token -- 679
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$") -- 680
				label = tostring(label or ""):match("^%s*(.-)%s*$") -- 681
				local credentialType = tostring(body.type or "token") -- 682
				username = tostring(username or "") -- 683
				local secret -- 684
				if credentialType == "basic" then -- 684
					secret = tostring(password or "") -- 684
				else -- 684
					secret = tostring(token or password or "") -- 684
				end -- 684
				if host == "" then -- 685
					return { -- 685
						success = false, -- 685
						message = "host is required" -- 685
					} -- 685
				end -- 685
				if label == "" then -- 686
					return { -- 686
						success = false, -- 686
						message = "label is required" -- 686
					} -- 686
				end -- 686
				if secret == "" then -- 687
					return { -- 687
						success = false, -- 687
						message = "secret is required" -- 687
					} -- 687
				end -- 687
				if not (("basic" == credentialType or "token" == credentialType)) then -- 688
					return { -- 688
						success = false, -- 688
						message = "invalid type" -- 688
					} -- 688
				end -- 688
				ensureGitTables() -- 689
				local now = os.time() -- 690
				if id then -- 691
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", { -- 693
						host, -- 693
						label, -- 693
						credentialType, -- 693
						username, -- 693
						secret, -- 693
						now, -- 693
						(tonumber(id) or 0) -- 693
					}) -- 692
					return { -- 695
						success = true, -- 695
						id = tonumber(id) -- 695
					} -- 695
				else -- 697
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", { -- 698
						host, -- 698
						label, -- 698
						credentialType, -- 698
						username, -- 698
						secret, -- 698
						now, -- 698
						now -- 698
					}) -- 697
					local rows = DB:query("select last_insert_rowid()") -- 700
					return { -- 701
						success = true, -- 701
						id = rows and rows[1] and rows[1][1] -- 701
					} -- 701
				end -- 691
			end -- 678
		end -- 678
	end -- 678
	return invalidArguments -- 677
end) -- 677
HttpServer:post("/git/auth/delete", function(req) -- 703
	do -- 704
		local _type_0 = type(req) -- 704
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 704
		if _tab_0 then -- 704
			local id -- 704
			do -- 704
				local _obj_0 = req.body -- 704
				local _type_1 = type(_obj_0) -- 704
				if "table" == _type_1 or "userdata" == _type_1 then -- 704
					id = _obj_0.id -- 704
				end -- 704
			end -- 704
			if id ~= nil then -- 704
				ensureGitTables() -- 705
				local credentialId = tonumber(id) or 0 -- 706
				DB:exec("delete from GitCredential where id = ?", { -- 707
					credentialId -- 707
				}) -- 707
				return { -- 708
					success = true -- 708
				} -- 708
			end -- 704
		end -- 704
	end -- 704
	return invalidArguments -- 703
end) -- 703
HttpServer:postSchedule("/git/auth/test", function(req) -- 710
	do -- 711
		local _type_0 = type(req) -- 711
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 711
		if _tab_0 then -- 711
			local body = req.body -- 711
			if body ~= nil then -- 711
				local repoPath, url, authId = body.repoPath, body.url, body.authId -- 712
				local credential = gitLoadCredential(authId) -- 713
				local optionsJSON = gitAuthOptionsJSON(credential) -- 714
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20) -- 715
			end -- 711
		end -- 711
	end -- 711
	return invalidArguments -- 710
end) -- 710
HttpServer:post("/agent/session/create", function(req) -- 717
	do -- 718
		local _type_0 = type(req) -- 718
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 718
		if _tab_0 then -- 718
			local projectRoot -- 718
			do -- 718
				local _obj_0 = req.body -- 718
				local _type_1 = type(_obj_0) -- 718
				if "table" == _type_1 or "userdata" == _type_1 then -- 718
					projectRoot = _obj_0.projectRoot -- 718
				end -- 718
			end -- 718
			local title -- 718
			do -- 718
				local _obj_0 = req.body -- 718
				local _type_1 = type(_obj_0) -- 718
				if "table" == _type_1 or "userdata" == _type_1 then -- 718
					title = _obj_0.title -- 718
				end -- 718
			end -- 718
			if projectRoot ~= nil and title ~= nil then -- 718
				return AgentSession.createSession(projectRoot, title) -- 719
			end -- 718
		end -- 718
	end -- 718
	return invalidArguments -- 717
end) -- 717
HttpServer:post("/agent/session/create-sub", function(req) -- 721
	do -- 722
		local _type_0 = type(req) -- 722
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 722
		if _tab_0 then -- 722
			local parentSessionId -- 722
			do -- 722
				local _obj_0 = req.body -- 722
				local _type_1 = type(_obj_0) -- 722
				if "table" == _type_1 or "userdata" == _type_1 then -- 722
					parentSessionId = _obj_0.parentSessionId -- 722
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
			if parentSessionId ~= nil and title ~= nil then -- 722
				return AgentSession.createSubSession(parentSessionId, title) -- 723
			end -- 722
		end -- 722
	end -- 722
	return invalidArguments -- 721
end) -- 721
HttpServer:post("/agent/session/get", function(req) -- 725
	do -- 726
		local _type_0 = type(req) -- 726
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 726
		if _tab_0 then -- 726
			local sessionId -- 726
			do -- 726
				local _obj_0 = req.body -- 726
				local _type_1 = type(_obj_0) -- 726
				if "table" == _type_1 or "userdata" == _type_1 then -- 726
					sessionId = _obj_0.sessionId -- 726
				end -- 726
			end -- 726
			if sessionId ~= nil then -- 726
				return AgentSession.getSession(sessionId) -- 727
			end -- 726
		end -- 726
	end -- 726
	return invalidArguments -- 725
end) -- 725
HttpServer:post("/agent/session/send", function(req) -- 729
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
			local prompt -- 730
			do -- 730
				local _obj_0 = req.body -- 730
				local _type_1 = type(_obj_0) -- 730
				if "table" == _type_1 or "userdata" == _type_1 then -- 730
					prompt = _obj_0.prompt -- 730
				end -- 730
			end -- 730
			if sessionId ~= nil and prompt ~= nil then -- 730
				return AgentSession.sendPrompt(sessionId, prompt, false, req.body.disabledAgentTools) -- 731
			end -- 730
		end -- 730
	end -- 730
	return invalidArguments -- 729
end) -- 729
HttpServer:post("/agent/session/resend", function(req) -- 733
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
			local messageId -- 734
			do -- 734
				local _obj_0 = req.body -- 734
				local _type_1 = type(_obj_0) -- 734
				if "table" == _type_1 or "userdata" == _type_1 then -- 734
					messageId = _obj_0.messageId -- 734
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
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 734
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools) -- 735
			end -- 734
		end -- 734
	end -- 734
	return invalidArguments -- 733
end) -- 733
HttpServer:post("/agent/task/status", function(req) -- 737
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
			if sessionId ~= nil then -- 738
				local res = AgentSession.getSession(sessionId) -- 739
				if not res.success then -- 740
					return res -- 740
				end -- 740
				local taskId = res.session.currentTaskId -- 741
				local checkpoints -- 742
				if taskId then -- 742
					checkpoints = AgentTools.listCheckpoints(taskId) -- 742
				else -- 742
					checkpoints = { } -- 742
				end -- 742
				return { -- 744
					success = true, -- 744
					session = res.session, -- 745
					relatedSessions = res.relatedSessions, -- 746
					spawnInfo = res.spawnInfo, -- 747
					messages = res.messages, -- 748
					steps = res.steps, -- 749
					checkpoints = checkpoints -- 750
				} -- 743
			end -- 738
		end -- 738
	end -- 738
	return invalidArguments -- 737
end) -- 737
HttpServer:post("/agent/task/running", function() -- 752
	local res = AgentSession.listRunningSessions() -- 753
	if res.success and #res.sessions == 0 then -- 754
		res.sessions = nil -- 755
	end -- 754
	return res -- 756
end) -- 752
HttpServer:post("/agent/task/stop", function(req) -- 758
	do -- 759
		local _type_0 = type(req) -- 759
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 759
		if _tab_0 then -- 759
			local sessionId -- 759
			do -- 759
				local _obj_0 = req.body -- 759
				local _type_1 = type(_obj_0) -- 759
				if "table" == _type_1 or "userdata" == _type_1 then -- 759
					sessionId = _obj_0.sessionId -- 759
				end -- 759
			end -- 759
			if sessionId ~= nil then -- 759
				return AgentSession.stopSessionTask(sessionId) -- 760
			end -- 759
		end -- 759
	end -- 759
	return invalidArguments -- 758
end) -- 758
HttpServer:post("/agent/checkpoint/list", function(req) -- 762
	do -- 763
		local _type_0 = type(req) -- 763
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 763
		if _tab_0 then -- 763
			local taskId -- 763
			do -- 763
				local _obj_0 = req.body -- 763
				local _type_1 = type(_obj_0) -- 763
				if "table" == _type_1 or "userdata" == _type_1 then -- 763
					taskId = _obj_0.taskId -- 763
				end -- 763
			end -- 763
			local sessionId -- 763
			do -- 763
				local _obj_0 = req.body -- 763
				local _type_1 = type(_obj_0) -- 763
				if "table" == _type_1 or "userdata" == _type_1 then -- 763
					sessionId = _obj_0.sessionId -- 763
				end -- 763
			end -- 763
			if sessionId ~= nil then -- 763
				if not taskId and sessionId then -- 764
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 765
				end -- 764
				if not taskId then -- 766
					return { -- 766
						success = false, -- 766
						message = "task not found" -- 766
					} -- 766
				end -- 766
				return { -- 768
					success = true, -- 768
					taskId = taskId, -- 769
					checkpoints = AgentTools.listCheckpoints(taskId) -- 770
				} -- 767
			end -- 763
		end -- 763
	end -- 763
	return invalidArguments -- 762
end) -- 762
HttpServer:post("/agent/checkpoint/diff", function(req) -- 772
	do -- 773
		local _type_0 = type(req) -- 773
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 773
		if _tab_0 then -- 773
			local checkpointId -- 773
			do -- 773
				local _obj_0 = req.body -- 773
				local _type_1 = type(_obj_0) -- 773
				if "table" == _type_1 or "userdata" == _type_1 then -- 773
					checkpointId = _obj_0.checkpointId -- 773
				end -- 773
			end -- 773
			if checkpointId ~= nil then -- 773
				if not (checkpointId > 0) then -- 774
					return { -- 774
						success = false, -- 774
						message = "invalid checkpointId" -- 774
					} -- 774
				end -- 774
				return AgentTools.getCheckpointDiff(checkpointId) -- 775
			end -- 773
		end -- 773
	end -- 773
	return invalidArguments -- 772
end) -- 772
HttpServer:post("/agent/task/diff", function(req) -- 777
	do -- 778
		local _type_0 = type(req) -- 778
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 778
		if _tab_0 then -- 778
			local taskId -- 778
			do -- 778
				local _obj_0 = req.body -- 778
				local _type_1 = type(_obj_0) -- 778
				if "table" == _type_1 or "userdata" == _type_1 then -- 778
					taskId = _obj_0.taskId -- 778
				end -- 778
			end -- 778
			if taskId ~= nil then -- 778
				if not (taskId > 0) then -- 779
					return { -- 779
						success = false, -- 779
						message = "invalid taskId" -- 779
					} -- 779
				end -- 779
				return AgentTools.getTaskChangeSetDiff(taskId) -- 780
			end -- 778
		end -- 778
	end -- 778
	return invalidArguments -- 777
end) -- 777
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 782
	do -- 783
		local _type_0 = type(req) -- 783
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 783
		if _tab_0 then -- 783
			local sessionId -- 783
			do -- 783
				local _obj_0 = req.body -- 783
				local _type_1 = type(_obj_0) -- 783
				if "table" == _type_1 or "userdata" == _type_1 then -- 783
					sessionId = _obj_0.sessionId -- 783
				end -- 783
			end -- 783
			local checkpointId -- 783
			do -- 783
				local _obj_0 = req.body -- 783
				local _type_1 = type(_obj_0) -- 783
				if "table" == _type_1 or "userdata" == _type_1 then -- 783
					checkpointId = _obj_0.checkpointId -- 783
				end -- 783
			end -- 783
			if sessionId ~= nil and checkpointId ~= nil then -- 783
				if not (checkpointId > 0) then -- 784
					return { -- 784
						success = false, -- 784
						message = "invalid checkpointId" -- 784
					} -- 784
				end -- 784
				local res = AgentSession.getSession(sessionId) -- 785
				if not res.success then -- 786
					return res -- 786
				end -- 786
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, res.session.projectRoot) -- 787
				if not rollbackRes.success then -- 788
					return rollbackRes -- 788
				end -- 788
				return { -- 790
					success = true, -- 790
					checkpointId = rollbackRes.checkpointId -- 791
				} -- 789
			end -- 783
		end -- 783
	end -- 783
	return invalidArguments -- 782
end) -- 782
HttpServer:post("/agent/task/rollback", function(req) -- 793
	do -- 794
		local _type_0 = type(req) -- 794
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 794
		if _tab_0 then -- 794
			local sessionId -- 794
			do -- 794
				local _obj_0 = req.body -- 794
				local _type_1 = type(_obj_0) -- 794
				if "table" == _type_1 or "userdata" == _type_1 then -- 794
					sessionId = _obj_0.sessionId -- 794
				end -- 794
			end -- 794
			local taskId -- 794
			do -- 794
				local _obj_0 = req.body -- 794
				local _type_1 = type(_obj_0) -- 794
				if "table" == _type_1 or "userdata" == _type_1 then -- 794
					taskId = _obj_0.taskId -- 794
				end -- 794
			end -- 794
			if sessionId ~= nil and taskId ~= nil then -- 794
				if not (taskId > 0) then -- 795
					return { -- 795
						success = false, -- 795
						message = "invalid taskId" -- 795
					} -- 795
				end -- 795
				local res = AgentSession.getSession(sessionId) -- 796
				if not res.success then -- 797
					return res -- 797
				end -- 797
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, res.session.projectRoot) -- 798
				if not rollbackRes.success then -- 799
					return rollbackRes -- 799
				end -- 799
				return { -- 801
					success = true, -- 801
					taskId = rollbackRes.taskId, -- 802
					checkpointId = rollbackRes.checkpointId, -- 803
					checkpointCount = rollbackRes.checkpointCount -- 804
				} -- 800
			end -- 794
		end -- 794
	end -- 794
	return invalidArguments -- 793
end) -- 793
local getSearchPath -- 806
getSearchPath = function(file) -- 806
	do -- 807
		local dir = getProjectDirFromFile(file) -- 807
		if dir then -- 807
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 808
		end -- 807
	end -- 807
	return "" -- 806
end -- 806
local getSearchFolders -- 810
getSearchFolders = function(file) -- 810
	do -- 811
		local dir = getProjectDirFromFile(file) -- 811
		if dir then -- 811
			return { -- 813
				Path(dir, "Script"), -- 813
				dir -- 814
			} -- 812
		end -- 811
	end -- 811
	return { } -- 810
end -- 810
local disabledCheckForLua = { -- 817
	"incompatible number of returns", -- 817
	"unknown", -- 818
	"cannot index", -- 819
	"module not found", -- 820
	"don't know how to resolve", -- 821
	"ContainerItem", -- 822
	"cannot resolve a type", -- 823
	"invalid key", -- 824
	"inconsistent index type", -- 825
	"cannot use operator", -- 826
	"attempting ipairs loop", -- 827
	"expects record or nominal", -- 828
	"variable is not being assigned", -- 829
	"<invalid type>", -- 830
	"<any type>", -- 831
	"using the '#' operator", -- 832
	"can't match a record", -- 833
	"redeclaration of variable", -- 834
	"cannot apply pairs", -- 835
	"not a function", -- 836
	"to%-be%-closed" -- 837
} -- 816
local yueCheck -- 839
yueCheck = function(file, content, lax) -- 839
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 840
	if isTIC80 then -- 841
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 842
	end -- 841
	local searchPath = getSearchPath(file) -- 843
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 844
	local info = { } -- 845
	local globals = { } -- 846
	for _index_0 = 1, #checkResult do -- 847
		local _des_0 = checkResult[_index_0] -- 847
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 847
		if "error" == t then -- 848
			info[#info + 1] = { -- 849
				"syntax", -- 849
				file, -- 849
				line, -- 849
				col, -- 849
				msg -- 849
			} -- 849
		elseif "global" == t then -- 850
			globals[#globals + 1] = { -- 851
				msg, -- 851
				line, -- 851
				col -- 851
			} -- 851
		end -- 848
	end -- 847
	if luaCodes then -- 852
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 853
		if success then -- 854
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 855
			if not (lintResult == "") then -- 856
				lintResult = lintResult .. "\n" -- 856
			end -- 856
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 857
		else -- 858
			for _index_0 = 1, #lintResult do -- 858
				local _des_0 = lintResult[_index_0] -- 858
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 858
				if isTIC80 and tic80APIs[name] then -- 859
					goto _continue_0 -- 859
				end -- 859
				info[#info + 1] = { -- 860
					"syntax", -- 860
					file, -- 860
					line, -- 860
					col, -- 860
					"invalid global variable" -- 860
				} -- 860
				::_continue_0:: -- 859
			end -- 858
		end -- 854
	end -- 852
	return luaCodes, info -- 861
end -- 839
local luaCheck -- 863
luaCheck = function(file, content) -- 863
	local res, err = load(content, "check") -- 864
	if not res then -- 865
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 866
		return { -- 867
			success = false, -- 867
			info = { -- 867
				{ -- 867
					"syntax", -- 867
					file, -- 867
					tonumber(line), -- 867
					0, -- 867
					msg -- 867
				} -- 867
			} -- 867
		} -- 867
	end -- 865
	local success, info = teal.checkAsync(content, file, true, "") -- 868
	if info then -- 869
		do -- 870
			local _accum_0 = { } -- 870
			local _len_0 = 1 -- 870
			for _index_0 = 1, #info do -- 870
				local item = info[_index_0] -- 870
				local useCheck = true -- 871
				if not item[5]:match("unused") then -- 872
					for _index_1 = 1, #disabledCheckForLua do -- 873
						local check = disabledCheckForLua[_index_1] -- 873
						if item[5]:match(check) then -- 874
							useCheck = false -- 875
						end -- 874
					end -- 873
				end -- 872
				if not useCheck then -- 876
					goto _continue_0 -- 876
				end -- 876
				do -- 877
					local _exp_0 = item[1] -- 877
					if "type" == _exp_0 then -- 878
						item[1] = "warning" -- 879
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 880
						goto _continue_0 -- 881
					end -- 877
				end -- 877
				_accum_0[_len_0] = item -- 882
				_len_0 = _len_0 + 1 -- 871
				::_continue_0:: -- 871
			end -- 870
			info = _accum_0 -- 870
		end -- 870
		if #info == 0 then -- 883
			info = nil -- 884
			success = true -- 885
		end -- 883
	end -- 869
	return { -- 886
		success = success, -- 886
		info = info -- 886
	} -- 886
end -- 863
local luaCheckWithLineInfo -- 888
luaCheckWithLineInfo = function(file, luaCodes) -- 888
	local res = luaCheck(file, luaCodes) -- 889
	local info = { } -- 890
	if not res.success then -- 891
		local current = 1 -- 892
		local lastLine = 1 -- 893
		local lineMap = { } -- 894
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 895
			local num = lineCode:match("--%s*(%d+)%s*$") -- 896
			if num then -- 897
				lastLine = tonumber(num) -- 898
			end -- 897
			lineMap[current] = lastLine -- 899
			current = current + 1 -- 900
		end -- 895
		local _list_0 = res.info -- 901
		for _index_0 = 1, #_list_0 do -- 901
			local item = _list_0[_index_0] -- 901
			item[3] = lineMap[item[3]] or 0 -- 902
			item[4] = 0 -- 903
			info[#info + 1] = item -- 904
		end -- 901
		return false, info -- 905
	end -- 891
	return true, info -- 906
end -- 888
local getCompiledYueLine -- 908
getCompiledYueLine = function(content, line, row, file, lax) -- 908
	local luaCodes = yueCheck(file, content, lax) -- 909
	if not luaCodes then -- 910
		return nil -- 910
	end -- 910
	local current = 1 -- 911
	local lastLine = 1 -- 912
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 913
	local targetRow = nil -- 914
	local lineMap = { } -- 915
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 916
		local num = lineCode:match("--%s*(%d+)%s*$") -- 917
		if num then -- 918
			lastLine = tonumber(num) -- 918
		end -- 918
		lineMap[current] = lastLine -- 919
		if row <= lastLine and not targetRow then -- 920
			targetRow = current -- 921
			break -- 922
		end -- 920
		current = current + 1 -- 923
	end -- 916
	targetRow = current -- 924
	if targetLine and targetRow then -- 925
		return luaCodes, targetLine, targetRow, lineMap -- 926
	else -- 928
		return nil -- 928
	end -- 925
end -- 908
HttpServer:postSchedule("/check", function(req) -- 930
	do -- 931
		local _type_0 = type(req) -- 931
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 931
		if _tab_0 then -- 931
			local file -- 931
			do -- 931
				local _obj_0 = req.body -- 931
				local _type_1 = type(_obj_0) -- 931
				if "table" == _type_1 or "userdata" == _type_1 then -- 931
					file = _obj_0.file -- 931
				end -- 931
			end -- 931
			local content -- 931
			do -- 931
				local _obj_0 = req.body -- 931
				local _type_1 = type(_obj_0) -- 931
				if "table" == _type_1 or "userdata" == _type_1 then -- 931
					content = _obj_0.content -- 931
				end -- 931
			end -- 931
			if file ~= nil and content ~= nil then -- 931
				local ext = Path:getExt(file) -- 932
				if "tl" == ext then -- 933
					local searchPath = getSearchPath(file) -- 934
					do -- 935
						local isTIC80 = CheckTIC80Code(content) -- 935
						if isTIC80 then -- 935
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 936
						end -- 935
					end -- 935
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 937
					return { -- 938
						success = success, -- 938
						info = info -- 938
					} -- 938
				elseif "lua" == ext then -- 939
					do -- 940
						local isTIC80 = CheckTIC80Code(content) -- 940
						if isTIC80 then -- 940
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 941
						end -- 940
					end -- 940
					return luaCheck(file, content) -- 942
				elseif "yue" == ext then -- 943
					local luaCodes, info = yueCheck(file, content, false) -- 944
					local success = false -- 945
					if luaCodes then -- 946
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 947
						do -- 948
							local _tab_1 = { } -- 948
							local _idx_0 = #_tab_1 + 1 -- 948
							for _index_0 = 1, #info do -- 948
								local _value_0 = info[_index_0] -- 948
								_tab_1[_idx_0] = _value_0 -- 948
								_idx_0 = _idx_0 + 1 -- 948
							end -- 948
							local _idx_1 = #_tab_1 + 1 -- 948
							for _index_0 = 1, #luaInfo do -- 948
								local _value_0 = luaInfo[_index_0] -- 948
								_tab_1[_idx_1] = _value_0 -- 948
								_idx_1 = _idx_1 + 1 -- 948
							end -- 948
							info = _tab_1 -- 948
						end -- 948
						success = success and luaSuccess -- 949
					end -- 946
					if #info > 0 then -- 950
						return { -- 951
							success = success, -- 951
							info = info -- 951
						} -- 951
					else -- 953
						return { -- 953
							success = success -- 953
						} -- 953
					end -- 950
				elseif "xml" == ext then -- 954
					local success, result = xml.check(content) -- 955
					if success then -- 956
						local info -- 957
						success, info = luaCheckWithLineInfo(file, result) -- 957
						if #info > 0 then -- 958
							return { -- 959
								success = success, -- 959
								info = info -- 959
							} -- 959
						else -- 961
							return { -- 961
								success = success -- 961
							} -- 961
						end -- 958
					else -- 963
						local info -- 963
						do -- 963
							local _accum_0 = { } -- 963
							local _len_0 = 1 -- 963
							for _index_0 = 1, #result do -- 963
								local _des_0 = result[_index_0] -- 963
								local row, err = _des_0[1], _des_0[2] -- 963
								_accum_0[_len_0] = { -- 964
									"syntax", -- 964
									file, -- 964
									row, -- 964
									0, -- 964
									err -- 964
								} -- 964
								_len_0 = _len_0 + 1 -- 964
							end -- 963
							info = _accum_0 -- 963
						end -- 963
						return { -- 965
							success = false, -- 965
							info = info -- 965
						} -- 965
					end -- 956
				end -- 933
			end -- 931
		end -- 931
	end -- 931
	return { -- 930
		success = true -- 930
	} -- 930
end) -- 930
HttpServer:post("/body/parse", function(req) -- 967
	do -- 968
		local _type_0 = type(req) -- 968
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 968
		if _tab_0 then -- 968
			local file -- 968
			do -- 968
				local _obj_0 = req.body -- 968
				local _type_1 = type(_obj_0) -- 968
				if "table" == _type_1 or "userdata" == _type_1 then -- 968
					file = _obj_0.file -- 968
				end -- 968
			end -- 968
			local content -- 968
			do -- 968
				local _obj_0 = req.body -- 968
				local _type_1 = type(_obj_0) -- 968
				if "table" == _type_1 or "userdata" == _type_1 then -- 968
					content = _obj_0.content -- 968
				end -- 968
			end -- 968
			if file ~= nil and content ~= nil then -- 968
				if not (file:sub(-6) == ".b.lua") then -- 969
					return { -- 970
						success = false, -- 970
						phase = "request", -- 970
						message = "only .b.lua files can be converted" -- 970
					} -- 970
				end -- 969
				local loader, err = load("_ENV = {}\n" .. content) -- 971
				if not loader then -- 972
					return { -- 973
						success = false, -- 973
						phase = "parse", -- 973
						message = tostring(err) -- 973
					} -- 973
				end -- 972
				local ok, data = pcall(loader) -- 974
				if not ok then -- 975
					return { -- 976
						success = false, -- 976
						phase = "execute", -- 976
						message = tostring(data) -- 976
					} -- 976
				end -- 975
				if not ("table" == type(data) and data[1] == "Array") then -- 977
					return { -- 978
						success = false, -- 978
						phase = "validate", -- 978
						message = "body lua root must be {\"Array\", ...}" -- 978
					} -- 978
				end -- 977
				local text, jsonErr = json.encode(data, false, true) -- 979
				if not text then -- 980
					return { -- 981
						success = false, -- 981
						phase = "encode", -- 981
						message = tostring(jsonErr) -- 981
					} -- 981
				end -- 980
				return { -- 982
					success = true, -- 982
					json = text -- 982
				} -- 982
			end -- 968
		end -- 968
	end -- 968
	return { -- 967
		success = false, -- 967
		phase = "request", -- 967
		message = "invalid request" -- 967
	} -- 967
end) -- 967
local updateInferedDesc -- 984
updateInferedDesc = function(infered) -- 984
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 985
		return -- 985
	end -- 985
	local key, row = infered.key, infered.row -- 986
	local codes = Content:loadAsync(key) -- 987
	if codes then -- 987
		local comments = { } -- 988
		local line = 0 -- 989
		local skipping = false -- 990
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 991
			line = line + 1 -- 992
			if line >= row then -- 993
				break -- 993
			end -- 993
			if lineCode:match("^%s*%-%- @") then -- 994
				skipping = true -- 995
				goto _continue_0 -- 996
			end -- 994
			local result = lineCode:match("^%s*%-%- (.+)") -- 997
			if result then -- 997
				if not skipping then -- 998
					comments[#comments + 1] = result -- 998
				end -- 998
			elseif #comments > 0 then -- 999
				comments = { } -- 1000
				skipping = false -- 1001
			end -- 997
			::_continue_0:: -- 992
		end -- 991
		infered.doc = table.concat(comments, "\n") -- 1002
	end -- 987
end -- 984
HttpServer:postSchedule("/infer", function(req) -- 1004
	do -- 1005
		local _type_0 = type(req) -- 1005
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1005
		if _tab_0 then -- 1005
			local lang -- 1005
			do -- 1005
				local _obj_0 = req.body -- 1005
				local _type_1 = type(_obj_0) -- 1005
				if "table" == _type_1 or "userdata" == _type_1 then -- 1005
					lang = _obj_0.lang -- 1005
				end -- 1005
			end -- 1005
			local file -- 1005
			do -- 1005
				local _obj_0 = req.body -- 1005
				local _type_1 = type(_obj_0) -- 1005
				if "table" == _type_1 or "userdata" == _type_1 then -- 1005
					file = _obj_0.file -- 1005
				end -- 1005
			end -- 1005
			local content -- 1005
			do -- 1005
				local _obj_0 = req.body -- 1005
				local _type_1 = type(_obj_0) -- 1005
				if "table" == _type_1 or "userdata" == _type_1 then -- 1005
					content = _obj_0.content -- 1005
				end -- 1005
			end -- 1005
			local line -- 1005
			do -- 1005
				local _obj_0 = req.body -- 1005
				local _type_1 = type(_obj_0) -- 1005
				if "table" == _type_1 or "userdata" == _type_1 then -- 1005
					line = _obj_0.line -- 1005
				end -- 1005
			end -- 1005
			local row -- 1005
			do -- 1005
				local _obj_0 = req.body -- 1005
				local _type_1 = type(_obj_0) -- 1005
				if "table" == _type_1 or "userdata" == _type_1 then -- 1005
					row = _obj_0.row -- 1005
				end -- 1005
			end -- 1005
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1005
				local searchPath = getSearchPath(file) -- 1006
				if "tl" == lang or "lua" == lang then -- 1007
					if CheckTIC80Code(content) then -- 1008
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1009
					end -- 1008
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1010
					if (infered ~= nil) then -- 1011
						updateInferedDesc(infered) -- 1012
						return { -- 1013
							success = true, -- 1013
							infered = infered -- 1013
						} -- 1013
					end -- 1011
				elseif "yue" == lang then -- 1014
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1015
					if not luaCodes then -- 1016
						return { -- 1016
							success = false -- 1016
						} -- 1016
					end -- 1016
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1017
					if (infered ~= nil) then -- 1018
						local col -- 1019
						file, row, col = infered.file, infered.row, infered.col -- 1019
						if file == "" and row > 0 and col > 0 then -- 1020
							infered.row = lineMap[row] or 0 -- 1021
							infered.col = 0 -- 1022
						end -- 1020
						updateInferedDesc(infered) -- 1023
						return { -- 1024
							success = true, -- 1024
							infered = infered -- 1024
						} -- 1024
					end -- 1018
				end -- 1007
			end -- 1005
		end -- 1005
	end -- 1005
	return { -- 1004
		success = false -- 1004
	} -- 1004
end) -- 1004
local _anon_func_3 = function(doc) -- 1075
	local _accum_0 = { } -- 1075
	local _len_0 = 1 -- 1075
	local _list_0 = doc.params -- 1075
	for _index_0 = 1, #_list_0 do -- 1075
		local param = _list_0[_index_0] -- 1075
		_accum_0[_len_0] = param.name -- 1075
		_len_0 = _len_0 + 1 -- 1075
	end -- 1075
	return _accum_0 -- 1075
end -- 1075
local getParamDocs -- 1026
getParamDocs = function(signatures) -- 1026
	do -- 1027
		local codes = Content:loadAsync(signatures[1].file) -- 1027
		if codes then -- 1027
			local comments = { } -- 1028
			local params = { } -- 1029
			local line = 0 -- 1030
			local docs = { } -- 1031
			local returnType = nil -- 1032
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1033
				line = line + 1 -- 1034
				local needBreak = true -- 1035
				for i, _des_0 in ipairs(signatures) do -- 1036
					local row = _des_0.row -- 1036
					if line >= row and not (docs[i] ~= nil) then -- 1037
						if #comments > 0 or #params > 0 or returnType then -- 1038
							docs[i] = { -- 1040
								doc = table.concat(comments, "  \n"), -- 1040
								returnType = returnType -- 1041
							} -- 1039
							if #params > 0 then -- 1043
								docs[i].params = params -- 1043
							end -- 1043
						else -- 1045
							docs[i] = false -- 1045
						end -- 1038
					end -- 1037
					if not docs[i] then -- 1046
						needBreak = false -- 1046
					end -- 1046
				end -- 1036
				if needBreak then -- 1047
					break -- 1047
				end -- 1047
				local result = lineCode:match("%s*%-%- (.+)") -- 1048
				if result then -- 1048
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1049
					if not name then -- 1050
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1051
					end -- 1050
					if name then -- 1052
						local pname = name -- 1053
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1054
							pname = pname .. "?" -- 1054
						end -- 1054
						params[#params + 1] = { -- 1056
							name = tostring(pname) .. ": " .. tostring(typ), -- 1056
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1057
						} -- 1055
					else -- 1060
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1060
						if typ then -- 1060
							if returnType then -- 1061
								returnType = returnType .. ", " .. typ -- 1062
							else -- 1064
								returnType = typ -- 1064
							end -- 1061
							result = result:gsub("@return", "**return:**") -- 1065
						end -- 1060
						comments[#comments + 1] = result -- 1066
					end -- 1052
				elseif #comments > 0 then -- 1067
					comments = { } -- 1068
					params = { } -- 1069
					returnType = nil -- 1070
				end -- 1048
			end -- 1033
			local results = { } -- 1071
			for _index_0 = 1, #docs do -- 1072
				local doc = docs[_index_0] -- 1072
				if not doc then -- 1073
					goto _continue_0 -- 1073
				end -- 1073
				if doc.params then -- 1074
					doc.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1075
				else -- 1077
					doc.desc = "function()" -- 1077
				end -- 1074
				if doc.returnType then -- 1078
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 1079
					doc.returnType = nil -- 1080
				end -- 1078
				results[#results + 1] = doc -- 1081
				::_continue_0:: -- 1073
			end -- 1072
			if #results > 0 then -- 1082
				return results -- 1082
			else -- 1082
				return nil -- 1082
			end -- 1082
		end -- 1027
	end -- 1027
	return nil -- 1026
end -- 1026
HttpServer:postSchedule("/signature", function(req) -- 1084
	do -- 1085
		local _type_0 = type(req) -- 1085
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1085
		if _tab_0 then -- 1085
			local lang -- 1085
			do -- 1085
				local _obj_0 = req.body -- 1085
				local _type_1 = type(_obj_0) -- 1085
				if "table" == _type_1 or "userdata" == _type_1 then -- 1085
					lang = _obj_0.lang -- 1085
				end -- 1085
			end -- 1085
			local file -- 1085
			do -- 1085
				local _obj_0 = req.body -- 1085
				local _type_1 = type(_obj_0) -- 1085
				if "table" == _type_1 or "userdata" == _type_1 then -- 1085
					file = _obj_0.file -- 1085
				end -- 1085
			end -- 1085
			local content -- 1085
			do -- 1085
				local _obj_0 = req.body -- 1085
				local _type_1 = type(_obj_0) -- 1085
				if "table" == _type_1 or "userdata" == _type_1 then -- 1085
					content = _obj_0.content -- 1085
				end -- 1085
			end -- 1085
			local line -- 1085
			do -- 1085
				local _obj_0 = req.body -- 1085
				local _type_1 = type(_obj_0) -- 1085
				if "table" == _type_1 or "userdata" == _type_1 then -- 1085
					line = _obj_0.line -- 1085
				end -- 1085
			end -- 1085
			local row -- 1085
			do -- 1085
				local _obj_0 = req.body -- 1085
				local _type_1 = type(_obj_0) -- 1085
				if "table" == _type_1 or "userdata" == _type_1 then -- 1085
					row = _obj_0.row -- 1085
				end -- 1085
			end -- 1085
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1085
				local searchPath = getSearchPath(file) -- 1086
				if "tl" == lang or "lua" == lang then -- 1087
					if CheckTIC80Code(content) then -- 1088
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1089
					end -- 1088
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1090
					if signatures then -- 1090
						signatures = getParamDocs(signatures) -- 1091
						if signatures then -- 1091
							return { -- 1092
								success = true, -- 1092
								signatures = signatures -- 1092
							} -- 1092
						end -- 1091
					end -- 1090
				elseif "yue" == lang then -- 1093
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1094
					if not luaCodes then -- 1095
						return { -- 1095
							success = false -- 1095
						} -- 1095
					end -- 1095
					do -- 1096
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1096
						if chainOp then -- 1096
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1097
							if withVar then -- 1097
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1098
							end -- 1097
						end -- 1096
					end -- 1096
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1099
					if signatures then -- 1099
						signatures = getParamDocs(signatures) -- 1100
						if signatures then -- 1100
							return { -- 1101
								success = true, -- 1101
								signatures = signatures -- 1101
							} -- 1101
						end -- 1100
					else -- 1102
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1102
						if signatures then -- 1102
							signatures = getParamDocs(signatures) -- 1103
							if signatures then -- 1103
								return { -- 1104
									success = true, -- 1104
									signatures = signatures -- 1104
								} -- 1104
							end -- 1103
						end -- 1102
					end -- 1099
				end -- 1087
			end -- 1085
		end -- 1085
	end -- 1085
	return { -- 1084
		success = false -- 1084
	} -- 1084
end) -- 1084
local luaKeywords = { -- 1107
	'and', -- 1107
	'break', -- 1108
	'do', -- 1109
	'else', -- 1110
	'elseif', -- 1111
	'end', -- 1112
	'false', -- 1113
	'for', -- 1114
	'function', -- 1115
	'goto', -- 1116
	'if', -- 1117
	'in', -- 1118
	'local', -- 1119
	'nil', -- 1120
	'not', -- 1121
	'or', -- 1122
	'repeat', -- 1123
	'return', -- 1124
	'then', -- 1125
	'true', -- 1126
	'until', -- 1127
	'while' -- 1128
} -- 1106
local tealKeywords = { -- 1132
	'record', -- 1132
	'as', -- 1133
	'is', -- 1134
	'type', -- 1135
	'embed', -- 1136
	'enum', -- 1137
	'global', -- 1138
	'any', -- 1139
	'boolean', -- 1140
	'integer', -- 1141
	'number', -- 1142
	'string', -- 1143
	'thread' -- 1144
} -- 1131
local yueKeywords = { -- 1148
	"and", -- 1148
	"break", -- 1149
	"do", -- 1150
	"else", -- 1151
	"elseif", -- 1152
	"false", -- 1153
	"for", -- 1154
	"goto", -- 1155
	"if", -- 1156
	"in", -- 1157
	"local", -- 1158
	"nil", -- 1159
	"not", -- 1160
	"or", -- 1161
	"repeat", -- 1162
	"return", -- 1163
	"then", -- 1164
	"true", -- 1165
	"until", -- 1166
	"while", -- 1167
	"as", -- 1168
	"class", -- 1169
	"continue", -- 1170
	"export", -- 1171
	"extends", -- 1172
	"from", -- 1173
	"global", -- 1174
	"import", -- 1175
	"macro", -- 1176
	"switch", -- 1177
	"try", -- 1178
	"unless", -- 1179
	"using", -- 1180
	"when", -- 1181
	"with" -- 1182
} -- 1147
local _anon_func_4 = function(f) -- 1218
	local _val_0 = Path:getExt(f) -- 1218
	return "ttf" == _val_0 or "otf" == _val_0 -- 1218
end -- 1218
local _anon_func_5 = function(suggestions) -- 1244
	local _tbl_0 = { } -- 1244
	for _index_0 = 1, #suggestions do -- 1244
		local item = suggestions[_index_0] -- 1244
		_tbl_0[item[1] .. item[2]] = item -- 1244
	end -- 1244
	return _tbl_0 -- 1244
end -- 1244
HttpServer:postSchedule("/complete", function(req) -- 1185
	do -- 1186
		local _type_0 = type(req) -- 1186
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1186
		if _tab_0 then -- 1186
			local lang -- 1186
			do -- 1186
				local _obj_0 = req.body -- 1186
				local _type_1 = type(_obj_0) -- 1186
				if "table" == _type_1 or "userdata" == _type_1 then -- 1186
					lang = _obj_0.lang -- 1186
				end -- 1186
			end -- 1186
			local file -- 1186
			do -- 1186
				local _obj_0 = req.body -- 1186
				local _type_1 = type(_obj_0) -- 1186
				if "table" == _type_1 or "userdata" == _type_1 then -- 1186
					file = _obj_0.file -- 1186
				end -- 1186
			end -- 1186
			local content -- 1186
			do -- 1186
				local _obj_0 = req.body -- 1186
				local _type_1 = type(_obj_0) -- 1186
				if "table" == _type_1 or "userdata" == _type_1 then -- 1186
					content = _obj_0.content -- 1186
				end -- 1186
			end -- 1186
			local line -- 1186
			do -- 1186
				local _obj_0 = req.body -- 1186
				local _type_1 = type(_obj_0) -- 1186
				if "table" == _type_1 or "userdata" == _type_1 then -- 1186
					line = _obj_0.line -- 1186
				end -- 1186
			end -- 1186
			local row -- 1186
			do -- 1186
				local _obj_0 = req.body -- 1186
				local _type_1 = type(_obj_0) -- 1186
				if "table" == _type_1 or "userdata" == _type_1 then -- 1186
					row = _obj_0.row -- 1186
				end -- 1186
			end -- 1186
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1186
				local searchPath = getSearchPath(file) -- 1187
				repeat -- 1188
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1189
					if lang == "yue" then -- 1190
						if not item then -- 1191
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1191
						end -- 1191
						if not item then -- 1192
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1192
						end -- 1192
					end -- 1190
					local searchType = nil -- 1193
					if not item then -- 1194
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1195
						if lang == "yue" then -- 1196
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1197
						end -- 1196
						if (item ~= nil) then -- 1198
							searchType = "Image" -- 1198
						end -- 1198
					end -- 1194
					if not item then -- 1199
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1200
						if lang == "yue" then -- 1201
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1202
						end -- 1201
						if (item ~= nil) then -- 1203
							searchType = "Font" -- 1203
						end -- 1203
					end -- 1199
					if not item then -- 1204
						break -- 1204
					end -- 1204
					local searchPaths = Content.searchPaths -- 1205
					local _list_0 = getSearchFolders(file) -- 1206
					for _index_0 = 1, #_list_0 do -- 1206
						local folder = _list_0[_index_0] -- 1206
						searchPaths[#searchPaths + 1] = folder -- 1207
					end -- 1206
					if searchType then -- 1208
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1208
					end -- 1208
					local tokens -- 1209
					do -- 1209
						local _accum_0 = { } -- 1209
						local _len_0 = 1 -- 1209
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1209
							_accum_0[_len_0] = mod -- 1209
							_len_0 = _len_0 + 1 -- 1209
						end -- 1209
						tokens = _accum_0 -- 1209
					end -- 1209
					local suggestions = { } -- 1210
					for _index_0 = 1, #searchPaths do -- 1211
						local path = searchPaths[_index_0] -- 1211
						local sPath = Path(path, table.unpack(tokens)) -- 1212
						if not Content:exist(sPath) then -- 1213
							goto _continue_0 -- 1213
						end -- 1213
						if searchType == "Font" then -- 1214
							local fontPath = Path(sPath, "Font") -- 1215
							if Content:exist(fontPath) then -- 1216
								local _list_1 = Content:getFiles(fontPath) -- 1217
								for _index_1 = 1, #_list_1 do -- 1217
									local f = _list_1[_index_1] -- 1217
									if _anon_func_4(f) then -- 1218
										if "." == f:sub(1, 1) then -- 1219
											goto _continue_1 -- 1219
										end -- 1219
										suggestions[#suggestions + 1] = { -- 1220
											Path:getName(f), -- 1220
											"font", -- 1220
											"field" -- 1220
										} -- 1220
									end -- 1218
									::_continue_1:: -- 1218
								end -- 1217
							end -- 1216
						end -- 1214
						local _list_1 = Content:getFiles(sPath) -- 1221
						for _index_1 = 1, #_list_1 do -- 1221
							local f = _list_1[_index_1] -- 1221
							if "Image" == searchType then -- 1222
								do -- 1223
									local _exp_0 = Path:getExt(f) -- 1223
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1223
										if "." == f:sub(1, 1) then -- 1224
											goto _continue_2 -- 1224
										end -- 1224
										suggestions[#suggestions + 1] = { -- 1225
											f, -- 1225
											"image", -- 1225
											"field" -- 1225
										} -- 1225
									end -- 1223
								end -- 1223
								goto _continue_2 -- 1226
							elseif "Font" == searchType then -- 1227
								do -- 1228
									local _exp_0 = Path:getExt(f) -- 1228
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1228
										if "." == f:sub(1, 1) then -- 1229
											goto _continue_2 -- 1229
										end -- 1229
										suggestions[#suggestions + 1] = { -- 1230
											f, -- 1230
											"font", -- 1230
											"field" -- 1230
										} -- 1230
									end -- 1228
								end -- 1228
								goto _continue_2 -- 1231
							end -- 1222
							local _exp_0 = Path:getExt(f) -- 1232
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1232
								local name = Path:getName(f) -- 1233
								if "d" == Path:getExt(name) then -- 1234
									goto _continue_2 -- 1234
								end -- 1234
								if "." == name:sub(1, 1) then -- 1235
									goto _continue_2 -- 1235
								end -- 1235
								suggestions[#suggestions + 1] = { -- 1236
									name, -- 1236
									"module", -- 1236
									"field" -- 1236
								} -- 1236
							end -- 1232
							::_continue_2:: -- 1222
						end -- 1221
						local _list_2 = Content:getDirs(sPath) -- 1237
						for _index_1 = 1, #_list_2 do -- 1237
							local dir = _list_2[_index_1] -- 1237
							if "." == dir:sub(1, 1) then -- 1238
								goto _continue_3 -- 1238
							end -- 1238
							suggestions[#suggestions + 1] = { -- 1239
								dir, -- 1239
								"folder", -- 1239
								"variable" -- 1239
							} -- 1239
							::_continue_3:: -- 1238
						end -- 1237
						::_continue_0:: -- 1212
					end -- 1211
					if item == "" and not searchType then -- 1240
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1241
						for _index_0 = 1, #_list_1 do -- 1241
							local _des_0 = _list_1[_index_0] -- 1241
							local name = _des_0[1] -- 1241
							suggestions[#suggestions + 1] = { -- 1242
								name, -- 1242
								"dora module", -- 1242
								"function" -- 1242
							} -- 1242
						end -- 1241
					end -- 1240
					if #suggestions > 0 then -- 1243
						do -- 1244
							local _accum_0 = { } -- 1244
							local _len_0 = 1 -- 1244
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1244
								_accum_0[_len_0] = v -- 1244
								_len_0 = _len_0 + 1 -- 1244
							end -- 1244
							suggestions = _accum_0 -- 1244
						end -- 1244
						return { -- 1245
							success = true, -- 1245
							suggestions = suggestions -- 1245
						} -- 1245
					else -- 1247
						return { -- 1247
							success = false -- 1247
						} -- 1247
					end -- 1243
				until true -- 1188
				if "tl" == lang or "lua" == lang then -- 1249
					do -- 1250
						local isTIC80 = CheckTIC80Code(content) -- 1250
						if isTIC80 then -- 1250
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1251
						end -- 1250
					end -- 1250
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1252
					if not line:match("[%.:]$") then -- 1253
						local checkSet -- 1254
						do -- 1254
							local _tbl_0 = { } -- 1254
							for _index_0 = 1, #suggestions do -- 1254
								local _des_0 = suggestions[_index_0] -- 1254
								local name = _des_0[1] -- 1254
								_tbl_0[name] = true -- 1254
							end -- 1254
							checkSet = _tbl_0 -- 1254
						end -- 1254
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1255
						for _index_0 = 1, #_list_0 do -- 1255
							local item = _list_0[_index_0] -- 1255
							if not checkSet[item[1]] then -- 1256
								suggestions[#suggestions + 1] = item -- 1256
							end -- 1256
						end -- 1255
						for _index_0 = 1, #luaKeywords do -- 1257
							local word = luaKeywords[_index_0] -- 1257
							suggestions[#suggestions + 1] = { -- 1258
								word, -- 1258
								"keyword", -- 1258
								"keyword" -- 1258
							} -- 1258
						end -- 1257
						if lang == "tl" then -- 1259
							for _index_0 = 1, #tealKeywords do -- 1260
								local word = tealKeywords[_index_0] -- 1260
								suggestions[#suggestions + 1] = { -- 1261
									word, -- 1261
									"keyword", -- 1261
									"keyword" -- 1261
								} -- 1261
							end -- 1260
						end -- 1259
					end -- 1253
					if #suggestions > 0 then -- 1262
						return { -- 1263
							success = true, -- 1263
							suggestions = suggestions -- 1263
						} -- 1263
					end -- 1262
				elseif "yue" == lang then -- 1264
					local suggestions = { } -- 1265
					local gotGlobals = false -- 1266
					do -- 1267
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1267
						if luaCodes then -- 1267
							gotGlobals = true -- 1268
							do -- 1269
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1269
								if chainOp then -- 1269
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1270
									if not withVar then -- 1271
										return { -- 1271
											success = false -- 1271
										} -- 1271
									end -- 1271
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1272
								elseif line:match("^([%.\\])$") then -- 1273
									return { -- 1274
										success = false -- 1274
									} -- 1274
								end -- 1269
							end -- 1269
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1275
							for _index_0 = 1, #_list_0 do -- 1275
								local item = _list_0[_index_0] -- 1275
								suggestions[#suggestions + 1] = item -- 1275
							end -- 1275
							if #suggestions == 0 then -- 1276
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1277
								for _index_0 = 1, #_list_1 do -- 1277
									local item = _list_1[_index_0] -- 1277
									suggestions[#suggestions + 1] = item -- 1277
								end -- 1277
							end -- 1276
						end -- 1267
					end -- 1267
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1278
						local checkSet -- 1279
						do -- 1279
							local _tbl_0 = { } -- 1279
							for _index_0 = 1, #suggestions do -- 1279
								local _des_0 = suggestions[_index_0] -- 1279
								local name = _des_0[1] -- 1279
								_tbl_0[name] = true -- 1279
							end -- 1279
							checkSet = _tbl_0 -- 1279
						end -- 1279
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1280
						for _index_0 = 1, #_list_0 do -- 1280
							local item = _list_0[_index_0] -- 1280
							if not checkSet[item[1]] then -- 1281
								suggestions[#suggestions + 1] = item -- 1281
							end -- 1281
						end -- 1280
						if not gotGlobals then -- 1282
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1283
							for _index_0 = 1, #_list_1 do -- 1283
								local item = _list_1[_index_0] -- 1283
								if not checkSet[item[1]] then -- 1284
									suggestions[#suggestions + 1] = item -- 1284
								end -- 1284
							end -- 1283
						end -- 1282
						for _index_0 = 1, #yueKeywords do -- 1285
							local word = yueKeywords[_index_0] -- 1285
							if not checkSet[word] then -- 1286
								suggestions[#suggestions + 1] = { -- 1287
									word, -- 1287
									"keyword", -- 1287
									"keyword" -- 1287
								} -- 1287
							end -- 1286
						end -- 1285
					end -- 1278
					if #suggestions > 0 then -- 1288
						return { -- 1289
							success = true, -- 1289
							suggestions = suggestions -- 1289
						} -- 1289
					end -- 1288
				elseif "xml" == lang then -- 1290
					local items = xml.complete(content) -- 1291
					if #items > 0 then -- 1292
						local suggestions -- 1293
						do -- 1293
							local _accum_0 = { } -- 1293
							local _len_0 = 1 -- 1293
							for _index_0 = 1, #items do -- 1293
								local _des_0 = items[_index_0] -- 1293
								local label, insertText = _des_0[1], _des_0[2] -- 1293
								_accum_0[_len_0] = { -- 1294
									label, -- 1294
									insertText, -- 1294
									"field" -- 1294
								} -- 1294
								_len_0 = _len_0 + 1 -- 1294
							end -- 1293
							suggestions = _accum_0 -- 1293
						end -- 1293
						return { -- 1295
							success = true, -- 1295
							suggestions = suggestions -- 1295
						} -- 1295
					end -- 1292
				end -- 1249
			end -- 1186
		end -- 1186
	end -- 1186
	return { -- 1185
		success = false -- 1185
	} -- 1185
end) -- 1185
HttpServer:upload("/upload", function(req, filename) -- 1299
	do -- 1300
		local _type_0 = type(req) -- 1300
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1300
		if _tab_0 then -- 1300
			local path -- 1300
			do -- 1300
				local _obj_0 = req.params -- 1300
				local _type_1 = type(_obj_0) -- 1300
				if "table" == _type_1 or "userdata" == _type_1 then -- 1300
					path = _obj_0.path -- 1300
				end -- 1300
			end -- 1300
			if path ~= nil then -- 1300
				local uploadPath = Path(Content.writablePath, ".upload") -- 1301
				if not Content:exist(uploadPath) then -- 1302
					Content:mkdir(uploadPath) -- 1303
				end -- 1302
				local targetPath = Path(uploadPath, filename) -- 1304
				Content:mkdir(Path:getPath(targetPath)) -- 1305
				return targetPath -- 1306
			end -- 1300
		end -- 1300
	end -- 1300
	return nil -- 1299
end, function(req, file) -- 1307
	do -- 1308
		local _type_0 = type(req) -- 1308
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1308
		if _tab_0 then -- 1308
			local path -- 1308
			do -- 1308
				local _obj_0 = req.params -- 1308
				local _type_1 = type(_obj_0) -- 1308
				if "table" == _type_1 or "userdata" == _type_1 then -- 1308
					path = _obj_0.path -- 1308
				end -- 1308
			end -- 1308
			if path ~= nil then -- 1308
				path = Path(Content.writablePath, path) -- 1309
				if Content:exist(path) then -- 1310
					local uploadPath = Path(Content.writablePath, ".upload") -- 1311
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1312
					Content:mkdir(Path:getPath(targetPath)) -- 1313
					if Content:move(file, targetPath) then -- 1314
						return true -- 1315
					end -- 1314
				end -- 1310
			end -- 1308
		end -- 1308
	end -- 1308
	return false -- 1307
end) -- 1297
HttpServer:post("/list", function(req) -- 1318
	do -- 1319
		local _type_0 = type(req) -- 1319
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1319
		if _tab_0 then -- 1319
			local path -- 1319
			do -- 1319
				local _obj_0 = req.body -- 1319
				local _type_1 = type(_obj_0) -- 1319
				if "table" == _type_1 or "userdata" == _type_1 then -- 1319
					path = _obj_0.path -- 1319
				end -- 1319
			end -- 1319
			if path ~= nil then -- 1319
				if Content:exist(path) then -- 1320
					local files = { } -- 1321
					local visitAssets -- 1322
					visitAssets = function(path, folder) -- 1322
						local dirs = Content:getDirs(path) -- 1323
						for _index_0 = 1, #dirs do -- 1324
							local dir = dirs[_index_0] -- 1324
							if dir:match("^%.") then -- 1325
								goto _continue_0 -- 1325
							end -- 1325
							local current -- 1326
							if folder == "" then -- 1326
								current = dir -- 1327
							else -- 1329
								current = Path(folder, dir) -- 1329
							end -- 1326
							files[#files + 1] = current -- 1330
							visitAssets(Path(path, dir), current) -- 1331
							::_continue_0:: -- 1325
						end -- 1324
						local fs = Content:getFiles(path) -- 1332
						for _index_0 = 1, #fs do -- 1333
							local f = fs[_index_0] -- 1333
							if (".DS_Store" == f) then -- 1334
								goto _continue_1 -- 1335
							end -- 1334
							if folder == "" then -- 1336
								files[#files + 1] = f -- 1337
							else -- 1339
								files[#files + 1] = Path(folder, f) -- 1339
							end -- 1336
							::_continue_1:: -- 1334
						end -- 1333
					end -- 1322
					visitAssets(path, "") -- 1340
					if #files == 0 then -- 1341
						files = nil -- 1341
					end -- 1341
					return { -- 1342
						success = true, -- 1342
						files = files -- 1342
					} -- 1342
				end -- 1320
			end -- 1319
		end -- 1319
	end -- 1319
	return { -- 1318
		success = false -- 1318
	} -- 1318
end) -- 1318
HttpServer:post("/info", function() -- 1344
	local Entry = require("Script.Dev.Entry") -- 1345
	local webProfiler, drawerWidth -- 1346
	do -- 1346
		local _obj_0 = Entry.getConfig() -- 1346
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 1346
	end -- 1346
	local engineDev = Entry.getEngineDev() -- 1347
	Entry.connectWebIDE() -- 1348
	return { -- 1350
		platform = App.platform, -- 1350
		locale = App.locale, -- 1351
		version = App.version, -- 1352
		engineDev = engineDev, -- 1353
		webProfiler = webProfiler, -- 1354
		drawerWidth = drawerWidth -- 1355
	} -- 1349
end) -- 1344
local ensureLLMConfigTable -- 1357
ensureLLMConfigTable = function() -- 1357
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1358
	if columns and #columns > 0 then -- 1359
		local expected = { -- 1361
			id = true, -- 1361
			name = true, -- 1362
			url = true, -- 1363
			model = true, -- 1364
			api_key = true, -- 1365
			context_window = true, -- 1366
			temperature = true, -- 1367
			max_tokens = true, -- 1368
			reasoning_effort = true, -- 1369
			custom_options = true, -- 1370
			supports_function_calling = true, -- 1371
			active = true, -- 1372
			created_at = true, -- 1373
			updated_at = true -- 1374
		} -- 1360
		local existing = { } -- 1376
		local valid = true -- 1377
		for _index_0 = 1, #columns do -- 1378
			local row = columns[_index_0] -- 1378
			local columnName = tostring(row[2]) -- 1379
			existing[columnName] = true -- 1380
			if not expected[columnName] then -- 1381
				valid = false -- 1382
				break -- 1383
			end -- 1381
		end -- 1378
		if valid then -- 1384
			if not existing.context_window then -- 1385
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1386
			end -- 1385
			if not existing.temperature then -- 1387
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1388
			end -- 1387
			if not existing.max_tokens then -- 1389
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 1390
			end -- 1389
			if not existing.reasoning_effort then -- 1391
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1392
			end -- 1391
			if not existing.custom_options then -- 1393
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1394
			end -- 1393
			if not existing.supports_function_calling then -- 1395
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1396
			end -- 1395
		else -- 1398
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1398
		end -- 1384
	end -- 1359
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
	]]) -- 1399
end -- 1357
local normalizeContextWindow -- 1418
normalizeContextWindow = function(value) -- 1418
	local contextWindow = tonumber(value) -- 1419
	if contextWindow == nil or contextWindow < 64000 then -- 1420
		return 64000 -- 1421
	end -- 1420
	return math.max(64000, math.floor(contextWindow)) -- 1422
end -- 1418
local normalizeTemperature -- 1424
normalizeTemperature = function(value) -- 1424
	local temperature = tonumber(value) -- 1425
	if temperature == nil then -- 1426
		return 0.1 -- 1427
	end -- 1426
	return math.max(0, math.min(2, temperature)) -- 1428
end -- 1424
local normalizeMaxTokens -- 1430
normalizeMaxTokens = function(value) -- 1430
	local maxTokens = tonumber(value) -- 1431
	if maxTokens == nil or maxTokens < 1 then -- 1432
		return 8192 -- 1433
	end -- 1432
	return math.max(1, math.floor(maxTokens)) -- 1434
end -- 1430
local normalizeReasoningEffort -- 1436
normalizeReasoningEffort = function(value) -- 1436
	if value == nil then -- 1437
		return "" -- 1438
	end -- 1437
	local effort = tostring(value) -- 1439
	return effort:match("^%s*(.-)%s*$") or "" -- 1440
end -- 1436
local normalizeCustomOptions -- 1442
normalizeCustomOptions = function(value) -- 1442
	if value == nil then -- 1443
		return "" -- 1444
	end -- 1443
	local options = tostring(value) -- 1445
	options = options:match("^%s*(.-)%s*$") or "" -- 1446
	return options -- 1447
end -- 1442
local validateCustomOptions -- 1449
validateCustomOptions = function(value) -- 1449
	local options = normalizeCustomOptions(value) -- 1450
	if options == "" then -- 1451
		return true -- 1451
	end -- 1451
	if not options:match("^%s*{") then -- 1452
		return false -- 1452
	end -- 1452
	local decoded = json.decode(options) -- 1453
	return type(decoded) == "table" -- 1454
end -- 1449
HttpServer:post("/llm/list", function() -- 1456
	ensureLLMConfigTable() -- 1457
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active\n		from LLMConfig\n		order by id asc") -- 1458
	local items -- 1462
	if rows and #rows > 0 then -- 1462
		local _accum_0 = { } -- 1463
		local _len_0 = 1 -- 1463
		for _index_0 = 1, #rows do -- 1463
			local _des_0 = rows[_index_0] -- 1463
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11], _des_0[12] -- 1463
			_accum_0[_len_0] = { -- 1464
				id = id, -- 1464
				name = name, -- 1464
				url = url, -- 1464
				model = model, -- 1464
				key = key, -- 1464
				contextWindow = normalizeContextWindow(contextWindow), -- 1464
				temperature = normalizeTemperature(temperature), -- 1464
				maxTokens = normalizeMaxTokens(maxTokens), -- 1464
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1464
				customOptions = normalizeCustomOptions(customOptions), -- 1464
				supportsFunctionCalling = supportsFunctionCalling ~= 0, -- 1464
				active = active ~= 0 -- 1464
			} -- 1464
			_len_0 = _len_0 + 1 -- 1464
		end -- 1463
		items = _accum_0 -- 1462
	end -- 1462
	return { -- 1465
		success = true, -- 1465
		items = items -- 1465
	} -- 1465
end) -- 1456
HttpServer:post("/llm/create", function(req) -- 1467
	ensureLLMConfigTable() -- 1468
	do -- 1469
		local _type_0 = type(req) -- 1469
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1469
		if _tab_0 then -- 1469
			local body = req.body -- 1469
			if body ~= nil then -- 1469
				local name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1470
				local now = os.time() -- 1471
				if name == nil or url == nil or model == nil or key == nil then -- 1472
					return { -- 1473
						success = false, -- 1473
						message = "invalid" -- 1473
					} -- 1473
				end -- 1472
				contextWindow = normalizeContextWindow(contextWindow) -- 1474
				temperature = normalizeTemperature(temperature) -- 1475
				maxTokens = normalizeMaxTokens(maxTokens) -- 1476
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1477
				customOptions = normalizeCustomOptions(customOptions) -- 1478
				if not validateCustomOptions(customOptions) then -- 1479
					return { -- 1479
						success = false, -- 1479
						message = "customOptions must be a JSON object" -- 1479
					} -- 1479
				end -- 1479
				if supportsFunctionCalling == false then -- 1480
					supportsFunctionCalling = 0 -- 1480
				else -- 1480
					supportsFunctionCalling = 1 -- 1480
				end -- 1480
				if active then -- 1481
					active = 1 -- 1481
				else -- 1481
					active = 0 -- 1481
				end -- 1481
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1488
					tostring(name), -- 1488
					tostring(url), -- 1489
					tostring(model), -- 1490
					tostring(key), -- 1491
					contextWindow, -- 1492
					temperature, -- 1493
					maxTokens, -- 1494
					reasoningEffort, -- 1495
					customOptions, -- 1496
					supportsFunctionCalling, -- 1497
					active, -- 1498
					now, -- 1499
					now -- 1500
				}) -- 1482
				return { -- 1502
					success = affected >= 0 -- 1502
				} -- 1502
			end -- 1469
		end -- 1469
	end -- 1469
	return { -- 1467
		success = false, -- 1467
		message = "invalid" -- 1467
	} -- 1467
end) -- 1467
HttpServer:post("/llm/update", function(req) -- 1504
	ensureLLMConfigTable() -- 1505
	do -- 1506
		local _type_0 = type(req) -- 1506
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1506
		if _tab_0 then -- 1506
			local body = req.body -- 1506
			if body ~= nil then -- 1506
				local id, name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1507
				local now = os.time() -- 1508
				id = tonumber(id) -- 1509
				if id == nil then -- 1510
					return { -- 1511
						success = false, -- 1511
						message = "invalid" -- 1511
					} -- 1511
				end -- 1510
				contextWindow = normalizeContextWindow(contextWindow) -- 1512
				temperature = normalizeTemperature(temperature) -- 1513
				maxTokens = normalizeMaxTokens(maxTokens) -- 1514
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1515
				customOptions = normalizeCustomOptions(customOptions) -- 1516
				if not validateCustomOptions(customOptions) then -- 1517
					return { -- 1517
						success = false, -- 1517
						message = "customOptions must be a JSON object" -- 1517
					} -- 1517
				end -- 1517
				if supportsFunctionCalling == false then -- 1518
					supportsFunctionCalling = 0 -- 1518
				else -- 1518
					supportsFunctionCalling = 1 -- 1518
				end -- 1518
				if active then -- 1519
					active = 1 -- 1519
				else -- 1519
					active = 0 -- 1519
				end -- 1519
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, active = ?, updated_at = ?\n			where id = ?", { -- 1524
					tostring(name), -- 1524
					tostring(url), -- 1525
					tostring(model), -- 1526
					tostring(key), -- 1527
					contextWindow, -- 1528
					temperature, -- 1529
					maxTokens, -- 1530
					reasoningEffort, -- 1531
					customOptions, -- 1532
					supportsFunctionCalling, -- 1533
					active, -- 1534
					now, -- 1535
					id -- 1536
				}) -- 1520
				return { -- 1538
					success = affected >= 0 -- 1538
				} -- 1538
			end -- 1506
		end -- 1506
	end -- 1506
	return { -- 1504
		success = false, -- 1504
		message = "invalid" -- 1504
	} -- 1504
end) -- 1504
HttpServer:post("/llm/delete", function(req) -- 1540
	ensureLLMConfigTable() -- 1541
	do -- 1542
		local _type_0 = type(req) -- 1542
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1542
		if _tab_0 then -- 1542
			local id -- 1542
			do -- 1542
				local _obj_0 = req.body -- 1542
				local _type_1 = type(_obj_0) -- 1542
				if "table" == _type_1 or "userdata" == _type_1 then -- 1542
					id = _obj_0.id -- 1542
				end -- 1542
			end -- 1542
			if id ~= nil then -- 1542
				id = tonumber(id) -- 1543
				if id == nil then -- 1544
					return { -- 1545
						success = false, -- 1545
						message = "invalid" -- 1545
					} -- 1545
				end -- 1544
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1546
					id -- 1546
				}) -- 1546
				return { -- 1547
					success = affected >= 0 -- 1547
				} -- 1547
			end -- 1542
		end -- 1542
	end -- 1542
	return { -- 1540
		success = false, -- 1540
		message = "invalid" -- 1540
	} -- 1540
end) -- 1540
HttpServer:post("/stat", function(req) -- 1549
	do -- 1550
		local _type_0 = type(req) -- 1550
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1550
		if _tab_0 then -- 1550
			local path -- 1550
			do -- 1550
				local _obj_0 = req.body -- 1550
				local _type_1 = type(_obj_0) -- 1550
				if "table" == _type_1 or "userdata" == _type_1 then -- 1550
					path = _obj_0.path -- 1550
				end -- 1550
			end -- 1550
			if path ~= nil then -- 1550
				if not Content:exist(path) then -- 1551
					return { -- 1552
						success = false, -- 1552
						message = "target not existed" -- 1552
					} -- 1552
				end -- 1551
				if Content:isdir(path) then -- 1553
					return { -- 1554
						success = false, -- 1554
						message = "failed to stat a directory" -- 1554
					} -- 1554
				end -- 1553
				local size, isBinary = Content:getAttr(path) -- 1555
				if size then -- 1555
					return { -- 1556
						success = true, -- 1556
						size = size, -- 1556
						isBinary = isBinary -- 1556
					} -- 1556
				end -- 1555
			end -- 1550
		end -- 1550
	end -- 1550
	return { -- 1549
		success = false, -- 1549
		message = "failed to stat" -- 1549
	} -- 1549
end) -- 1549
HttpServer:post("/new", function(req) -- 1558
	do -- 1559
		local _type_0 = type(req) -- 1559
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1559
		if _tab_0 then -- 1559
			local path -- 1559
			do -- 1559
				local _obj_0 = req.body -- 1559
				local _type_1 = type(_obj_0) -- 1559
				if "table" == _type_1 or "userdata" == _type_1 then -- 1559
					path = _obj_0.path -- 1559
				end -- 1559
			end -- 1559
			local content -- 1559
			do -- 1559
				local _obj_0 = req.body -- 1559
				local _type_1 = type(_obj_0) -- 1559
				if "table" == _type_1 or "userdata" == _type_1 then -- 1559
					content = _obj_0.content -- 1559
				end -- 1559
			end -- 1559
			local folder -- 1559
			do -- 1559
				local _obj_0 = req.body -- 1559
				local _type_1 = type(_obj_0) -- 1559
				if "table" == _type_1 or "userdata" == _type_1 then -- 1559
					folder = _obj_0.folder -- 1559
				end -- 1559
			end -- 1559
			if path ~= nil and content ~= nil and folder ~= nil then -- 1559
				if Content:exist(path) then -- 1560
					return { -- 1561
						success = false, -- 1561
						message = "TargetExisted" -- 1561
					} -- 1561
				end -- 1560
				local parent = Path:getPath(path) -- 1562
				local files = Content:getFiles(parent) -- 1563
				if folder then -- 1564
					local name = Path:getFilename(path):lower() -- 1565
					for _index_0 = 1, #files do -- 1566
						local file = files[_index_0] -- 1566
						if name == Path:getFilename(file):lower() then -- 1567
							return { -- 1568
								success = false, -- 1568
								message = "TargetExisted" -- 1568
							} -- 1568
						end -- 1567
					end -- 1566
					if Content:mkdir(path) then -- 1569
						return { -- 1570
							success = true -- 1570
						} -- 1570
					end -- 1569
				else -- 1572
					local name = Path:getName(path):lower() -- 1572
					for _index_0 = 1, #files do -- 1573
						local file = files[_index_0] -- 1573
						if name == Path:getName(file):lower() then -- 1574
							local ext = Path:getExt(file) -- 1575
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1576
								goto _continue_0 -- 1577
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1578
								goto _continue_0 -- 1579
							end -- 1576
							return { -- 1580
								success = false, -- 1580
								message = "SourceExisted" -- 1580
							} -- 1580
						end -- 1574
						::_continue_0:: -- 1574
					end -- 1573
					if Content:save(path, content) then -- 1581
						return { -- 1582
							success = true -- 1582
						} -- 1582
					end -- 1581
				end -- 1564
			end -- 1559
		end -- 1559
	end -- 1559
	return { -- 1558
		success = false, -- 1558
		message = "Failed" -- 1558
	} -- 1558
end) -- 1558
HttpServer:post("/delete", function(req) -- 1584
	do -- 1585
		local _type_0 = type(req) -- 1585
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1585
		if _tab_0 then -- 1585
			local path -- 1585
			do -- 1585
				local _obj_0 = req.body -- 1585
				local _type_1 = type(_obj_0) -- 1585
				if "table" == _type_1 or "userdata" == _type_1 then -- 1585
					path = _obj_0.path -- 1585
				end -- 1585
			end -- 1585
			if path ~= nil then -- 1585
				if Content:exist(path) then -- 1586
					local projectRoot -- 1587
					if Content:isdir(path) and isProjectRootDir(path) then -- 1587
						projectRoot = path -- 1587
					else -- 1587
						projectRoot = nil -- 1587
					end -- 1587
					local parent = Path:getPath(path) -- 1588
					local files = Content:getFiles(parent) -- 1589
					local name = Path:getName(path):lower() -- 1590
					local ext = Path:getExt(path) -- 1591
					for _index_0 = 1, #files do -- 1592
						local file = files[_index_0] -- 1592
						if name == Path:getName(file):lower() then -- 1593
							local _exp_0 = Path:getExt(file) -- 1594
							if "tl" == _exp_0 then -- 1594
								if ("vs" == ext) then -- 1594
									Content:remove(Path(parent, file)) -- 1595
								end -- 1594
							elseif "lua" == _exp_0 then -- 1596
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1596
									Content:remove(Path(parent, file)) -- 1597
								end -- 1596
							end -- 1594
						end -- 1593
					end -- 1592
					if Content:remove(path) then -- 1598
						if projectRoot then -- 1599
							AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1600
						end -- 1599
						return { -- 1601
							success = true -- 1601
						} -- 1601
					end -- 1598
				end -- 1586
			end -- 1585
		end -- 1585
	end -- 1585
	return { -- 1584
		success = false -- 1584
	} -- 1584
end) -- 1584
HttpServer:post("/rename", function(req) -- 1603
	do -- 1604
		local _type_0 = type(req) -- 1604
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1604
		if _tab_0 then -- 1604
			local old -- 1604
			do -- 1604
				local _obj_0 = req.body -- 1604
				local _type_1 = type(_obj_0) -- 1604
				if "table" == _type_1 or "userdata" == _type_1 then -- 1604
					old = _obj_0.old -- 1604
				end -- 1604
			end -- 1604
			local new -- 1604
			do -- 1604
				local _obj_0 = req.body -- 1604
				local _type_1 = type(_obj_0) -- 1604
				if "table" == _type_1 or "userdata" == _type_1 then -- 1604
					new = _obj_0.new -- 1604
				end -- 1604
			end -- 1604
			if old ~= nil and new ~= nil then -- 1604
				if Content:exist(old) and not Content:exist(new) then -- 1605
					local renamedDir = Content:isdir(old) -- 1606
					local parent = Path:getPath(new) -- 1607
					local files = Content:getFiles(parent) -- 1608
					if renamedDir then -- 1609
						local name = Path:getFilename(new):lower() -- 1610
						for _index_0 = 1, #files do -- 1611
							local file = files[_index_0] -- 1611
							if name == Path:getFilename(file):lower() then -- 1612
								return { -- 1613
									success = false -- 1613
								} -- 1613
							end -- 1612
						end -- 1611
					else -- 1615
						local name = Path:getName(new):lower() -- 1615
						local ext = Path:getExt(new) -- 1616
						for _index_0 = 1, #files do -- 1617
							local file = files[_index_0] -- 1617
							if name == Path:getName(file):lower() then -- 1618
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1619
									goto _continue_0 -- 1620
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1621
									goto _continue_0 -- 1622
								end -- 1619
								return { -- 1623
									success = false -- 1623
								} -- 1623
							end -- 1618
							::_continue_0:: -- 1618
						end -- 1617
					end -- 1609
					if Content:move(old, new) then -- 1624
						if renamedDir then -- 1625
							AgentSession.renameSessionsByProjectRoot(old, new) -- 1626
						end -- 1625
						local newParent = Path:getPath(new) -- 1627
						parent = Path:getPath(old) -- 1628
						files = Content:getFiles(parent) -- 1629
						local newName = Path:getName(new) -- 1630
						local oldName = Path:getName(old) -- 1631
						local name = oldName:lower() -- 1632
						local ext = Path:getExt(old) -- 1633
						for _index_0 = 1, #files do -- 1634
							local file = files[_index_0] -- 1634
							if name == Path:getName(file):lower() then -- 1635
								local _exp_0 = Path:getExt(file) -- 1636
								if "tl" == _exp_0 then -- 1636
									if ("vs" == ext) then -- 1636
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1637
									end -- 1636
								elseif "lua" == _exp_0 then -- 1638
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1638
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1639
									end -- 1638
								end -- 1636
							end -- 1635
						end -- 1634
						return { -- 1640
							success = true -- 1640
						} -- 1640
					end -- 1624
				end -- 1605
			end -- 1604
		end -- 1604
	end -- 1604
	return { -- 1603
		success = false -- 1603
	} -- 1603
end) -- 1603
HttpServer:post("/exist", function(req) -- 1642
	do -- 1643
		local _type_0 = type(req) -- 1643
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1643
		if _tab_0 then -- 1643
			local file -- 1643
			do -- 1643
				local _obj_0 = req.body -- 1643
				local _type_1 = type(_obj_0) -- 1643
				if "table" == _type_1 or "userdata" == _type_1 then -- 1643
					file = _obj_0.file -- 1643
				end -- 1643
			end -- 1643
			if file ~= nil then -- 1643
				do -- 1644
					local projFile = req.body.projFile -- 1644
					if projFile then -- 1644
						local projDir = getProjectDirFromFile(projFile) -- 1645
						if projDir then -- 1645
							local scriptDir = Path(projDir, "Script") -- 1646
							local searchPaths = Content.searchPaths -- 1647
							if Content:exist(scriptDir) then -- 1648
								Content:addSearchPath(scriptDir) -- 1648
							end -- 1648
							if Content:exist(projDir) then -- 1649
								Content:addSearchPath(projDir) -- 1649
							end -- 1649
							local _ <close> = setmetatable({ }, { -- 1650
								__close = function() -- 1650
									Content.searchPaths = searchPaths -- 1650
								end -- 1650
							}) -- 1650
							return { -- 1651
								success = Content:exist(file) -- 1651
							} -- 1651
						end -- 1645
					end -- 1644
				end -- 1644
				return { -- 1652
					success = Content:exist(file) -- 1652
				} -- 1652
			end -- 1643
		end -- 1643
	end -- 1643
	return { -- 1642
		success = false -- 1642
	} -- 1642
end) -- 1642
HttpServer:postSchedule("/read", function(req) -- 1654
	do -- 1655
		local _type_0 = type(req) -- 1655
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1655
		if _tab_0 then -- 1655
			local path -- 1655
			do -- 1655
				local _obj_0 = req.body -- 1655
				local _type_1 = type(_obj_0) -- 1655
				if "table" == _type_1 or "userdata" == _type_1 then -- 1655
					path = _obj_0.path -- 1655
				end -- 1655
			end -- 1655
			if path ~= nil then -- 1655
				local readFile -- 1656
				readFile = function() -- 1656
					if Content:exist(path) then -- 1657
						local content = Content:loadAsync(path) -- 1658
						if content then -- 1658
							return { -- 1659
								content = content, -- 1659
								success = true, -- 1659
								fullPath = Content:getFullPath(path) -- 1659
							} -- 1659
						end -- 1658
					end -- 1657
					return nil -- 1656
				end -- 1656
				do -- 1660
					local projFile = req.body.projFile -- 1660
					if projFile then -- 1660
						local projDir = getProjectDirFromFile(projFile) -- 1661
						if projDir then -- 1661
							local scriptDir = Path(projDir, "Script") -- 1662
							local searchPaths = Content.searchPaths -- 1663
							if Content:exist(scriptDir) then -- 1664
								Content:addSearchPath(scriptDir) -- 1664
							end -- 1664
							if Content:exist(projDir) then -- 1665
								Content:addSearchPath(projDir) -- 1665
							end -- 1665
							local _ <close> = setmetatable({ }, { -- 1666
								__close = function() -- 1666
									Content.searchPaths = searchPaths -- 1666
								end -- 1666
							}) -- 1666
							local result = readFile() -- 1667
							if result then -- 1667
								return result -- 1667
							end -- 1667
						end -- 1661
					end -- 1660
				end -- 1660
				local result = readFile() -- 1668
				if result then -- 1668
					return result -- 1668
				end -- 1668
			end -- 1655
		end -- 1655
	end -- 1655
	return { -- 1654
		success = false -- 1654
	} -- 1654
end) -- 1654
HttpServer:get("/read-sync", function(req) -- 1670
	do -- 1671
		local _type_0 = type(req) -- 1671
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1671
		if _tab_0 then -- 1671
			local params = req.params -- 1671
			if params ~= nil then -- 1671
				local path = params.path -- 1672
				local exts -- 1673
				if params.exts then -- 1673
					local _accum_0 = { } -- 1674
					local _len_0 = 1 -- 1674
					for ext in params.exts:gmatch("[^|]*") do -- 1674
						_accum_0[_len_0] = ext -- 1675
						_len_0 = _len_0 + 1 -- 1675
					end -- 1674
					exts = _accum_0 -- 1673
				else -- 1676
					exts = { -- 1676
						"" -- 1676
					} -- 1676
				end -- 1673
				local readFile -- 1677
				readFile = function() -- 1677
					for _index_0 = 1, #exts do -- 1678
						local ext = exts[_index_0] -- 1678
						local targetPath = path .. ext -- 1679
						if Content:exist(targetPath) then -- 1680
							local content = Content:load(targetPath) -- 1681
							if content then -- 1681
								return { -- 1682
									content = content, -- 1682
									success = true, -- 1682
									fullPath = Content:getFullPath(targetPath) -- 1682
								} -- 1682
							end -- 1681
						end -- 1680
					end -- 1678
					return nil -- 1677
				end -- 1677
				local searchPaths = Content.searchPaths -- 1683
				local _ <close> = setmetatable({ }, { -- 1684
					__close = function() -- 1684
						Content.searchPaths = searchPaths -- 1684
					end -- 1684
				}) -- 1684
				do -- 1685
					local projFile = req.params.projFile -- 1685
					if projFile then -- 1685
						local projDir = getProjectDirFromFile(projFile) -- 1686
						if projDir then -- 1686
							local scriptDir = Path(projDir, "Script") -- 1687
							if Content:exist(scriptDir) then -- 1688
								Content:addSearchPath(scriptDir) -- 1688
							end -- 1688
							if Content:exist(projDir) then -- 1689
								Content:addSearchPath(projDir) -- 1689
							end -- 1689
						else -- 1691
							projDir = Path:getPath(projFile) -- 1691
							if Content:exist(projDir) then -- 1692
								Content:addSearchPath(projDir) -- 1692
							end -- 1692
						end -- 1686
					end -- 1685
				end -- 1685
				local result = readFile() -- 1693
				if result then -- 1693
					return result -- 1693
				end -- 1693
			end -- 1671
		end -- 1671
	end -- 1671
	return { -- 1670
		success = false -- 1670
	} -- 1670
end) -- 1670
local compileFileAsync -- 1695
compileFileAsync = function(inputFile, sourceCodes) -- 1695
	local file = inputFile -- 1696
	local searchPath -- 1697
	do -- 1697
		local dir = getProjectDirFromFile(inputFile) -- 1697
		if dir then -- 1697
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 1698
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1699
		else -- 1701
			file = Path:getRelative(inputFile, Content.writablePath) -- 1701
			if file:sub(1, 2) == ".." then -- 1702
				file = Path:getRelative(inputFile, Content.assetPath) -- 1703
			end -- 1702
			searchPath = "" -- 1704
		end -- 1697
	end -- 1697
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1705
	local yueext = yue.options.extension -- 1706
	local resultCodes = nil -- 1707
	local resultError = nil -- 1708
	do -- 1709
		local _exp_0 = Path:getExt(inputFile) -- 1709
		if yueext == _exp_0 then -- 1709
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1710
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1711
				if not codes then -- 1712
					resultError = err -- 1713
					return -- 1714
				end -- 1712
				local extraGlobal -- 1715
				if isTIC80 then -- 1715
					extraGlobal = tic80APIs -- 1715
				else -- 1715
					extraGlobal = nil -- 1715
				end -- 1715
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1716
				if not success then -- 1717
					resultError = message -- 1718
					return -- 1719
				end -- 1717
				if codes == "" then -- 1720
					resultCodes = "" -- 1721
					return nil -- 1722
				end -- 1720
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1723
				return resultCodes -- 1724
			end, function(success) -- 1711
				if not success then -- 1725
					Content:remove(outputFile) -- 1726
					if resultCodes == nil then -- 1727
						resultCodes = false -- 1728
					end -- 1727
				end -- 1725
			end) -- 1711
		elseif "tl" == _exp_0 then -- 1729
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1730
			if isTIC80 then -- 1731
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1732
			end -- 1731
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1733
			if codes then -- 1733
				if isTIC80 then -- 1734
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1735
				end -- 1734
				resultCodes = codes -- 1736
				Content:saveAsync(outputFile, codes) -- 1737
			else -- 1739
				Content:remove(outputFile) -- 1739
				resultCodes = false -- 1740
				resultError = err -- 1741
			end -- 1733
		elseif "xml" == _exp_0 then -- 1742
			local codes, err = xml.tolua(sourceCodes) -- 1743
			if codes then -- 1743
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1744
				Content:saveAsync(outputFile, resultCodes) -- 1745
			else -- 1747
				Content:remove(outputFile) -- 1747
				resultCodes = false -- 1748
				resultError = err -- 1749
			end -- 1743
		end -- 1709
	end -- 1709
	wait(function() -- 1750
		return resultCodes ~= nil -- 1750
	end) -- 1750
	if resultCodes then -- 1751
		return resultCodes -- 1752
	else -- 1754
		return nil, resultError -- 1754
	end -- 1751
	return nil -- 1695
end -- 1695
HttpServer:postSchedule("/write", function(req) -- 1756
	do -- 1757
		local _type_0 = type(req) -- 1757
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1757
		if _tab_0 then -- 1757
			local path -- 1757
			do -- 1757
				local _obj_0 = req.body -- 1757
				local _type_1 = type(_obj_0) -- 1757
				if "table" == _type_1 or "userdata" == _type_1 then -- 1757
					path = _obj_0.path -- 1757
				end -- 1757
			end -- 1757
			local content -- 1757
			do -- 1757
				local _obj_0 = req.body -- 1757
				local _type_1 = type(_obj_0) -- 1757
				if "table" == _type_1 or "userdata" == _type_1 then -- 1757
					content = _obj_0.content -- 1757
				end -- 1757
			end -- 1757
			if path ~= nil and content ~= nil then -- 1757
				if Content:saveAsync(path, content) then -- 1758
					do -- 1759
						local _exp_0 = Path:getExt(path) -- 1759
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1759
							if '' == Path:getExt(Path:getName(path)) then -- 1760
								local resultCodes = compileFileAsync(path, content) -- 1761
								return { -- 1762
									success = true, -- 1762
									resultCodes = resultCodes -- 1762
								} -- 1762
							end -- 1760
						end -- 1759
					end -- 1759
					return { -- 1763
						success = true -- 1763
					} -- 1763
				end -- 1758
			end -- 1757
		end -- 1757
	end -- 1757
	return { -- 1756
		success = false -- 1756
	} -- 1756
end) -- 1756
HttpServer:postSchedule("/build", function(req) -- 1765
	do -- 1766
		local _type_0 = type(req) -- 1766
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1766
		if _tab_0 then -- 1766
			local path -- 1766
			do -- 1766
				local _obj_0 = req.body -- 1766
				local _type_1 = type(_obj_0) -- 1766
				if "table" == _type_1 or "userdata" == _type_1 then -- 1766
					path = _obj_0.path -- 1766
				end -- 1766
			end -- 1766
			if path ~= nil then -- 1766
				local _exp_0 = Path:getExt(path) -- 1767
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1767
					if '' == Path:getExt(Path:getName(path)) then -- 1768
						local content = Content:loadAsync(path) -- 1769
						if content then -- 1769
							local resultCodes = compileFileAsync(path, content) -- 1770
							if resultCodes then -- 1770
								return { -- 1771
									success = true, -- 1771
									resultCodes = resultCodes -- 1771
								} -- 1771
							end -- 1770
						end -- 1769
					end -- 1768
				end -- 1767
			end -- 1766
		end -- 1766
	end -- 1766
	return { -- 1765
		success = false -- 1765
	} -- 1765
end) -- 1765
local extentionLevels = { -- 1774
	vs = 2, -- 1774
	bl = 2, -- 1775
	ts = 1, -- 1776
	tsx = 1, -- 1777
	tl = 1, -- 1778
	yue = 1, -- 1779
	xml = 1, -- 1780
	lua = 0 -- 1781
} -- 1773
HttpServer:post("/assets", function() -- 1783
	local Entry = require("Script.Dev.Entry") -- 1786
	local engineDev = Entry.getEngineDev() -- 1787
	local visitAssets -- 1788
	visitAssets = function(path, tag) -- 1788
		local isWorkspace = tag == "Workspace" -- 1789
		local builtin -- 1790
		if tag == "Builtin" then -- 1790
			builtin = true -- 1790
		else -- 1790
			builtin = nil -- 1790
		end -- 1790
		local children = nil -- 1791
		local dirs = Content:getDirs(path) -- 1792
		for _index_0 = 1, #dirs do -- 1793
			local dir = dirs[_index_0] -- 1793
			if isWorkspace then -- 1794
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1795
					goto _continue_0 -- 1796
				end -- 1795
			elseif dir == ".git" then -- 1797
				goto _continue_0 -- 1798
			end -- 1794
			if not children then -- 1799
				children = { } -- 1799
			end -- 1799
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1800
			::_continue_0:: -- 1794
		end -- 1793
		local files = Content:getFiles(path) -- 1801
		local names = { } -- 1802
		for _index_0 = 1, #files do -- 1803
			local file = files[_index_0] -- 1803
			if (".DS_Store" == file) then -- 1804
				goto _continue_1 -- 1805
			end -- 1804
			local name = Path:getName(file) -- 1806
			local ext = names[name] -- 1807
			if ext then -- 1807
				local lv1 -- 1808
				do -- 1808
					local _exp_0 = extentionLevels[ext] -- 1808
					if _exp_0 ~= nil then -- 1808
						lv1 = _exp_0 -- 1808
					else -- 1808
						lv1 = -1 -- 1808
					end -- 1808
				end -- 1808
				ext = Path:getExt(file) -- 1809
				local lv2 -- 1810
				do -- 1810
					local _exp_0 = extentionLevels[ext] -- 1810
					if _exp_0 ~= nil then -- 1810
						lv2 = _exp_0 -- 1810
					else -- 1810
						lv2 = -1 -- 1810
					end -- 1810
				end -- 1810
				if lv2 > lv1 then -- 1811
					names[name] = ext -- 1812
				elseif lv2 == lv1 then -- 1813
					names[name .. '.' .. ext] = "" -- 1814
				end -- 1811
			else -- 1816
				ext = Path:getExt(file) -- 1816
				if not extentionLevels[ext] then -- 1817
					names[file] = "" -- 1818
				else -- 1820
					names[name] = ext -- 1820
				end -- 1817
			end -- 1807
			::_continue_1:: -- 1804
		end -- 1803
		do -- 1821
			local _accum_0 = { } -- 1821
			local _len_0 = 1 -- 1821
			for name, ext in pairs(names) do -- 1821
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1821
				_len_0 = _len_0 + 1 -- 1821
			end -- 1821
			files = _accum_0 -- 1821
		end -- 1821
		for _index_0 = 1, #files do -- 1822
			local file = files[_index_0] -- 1822
			if not children then -- 1823
				children = { } -- 1823
			end -- 1823
			children[#children + 1] = { -- 1825
				key = Path(path, file), -- 1825
				dir = false, -- 1826
				title = file, -- 1827
				builtin = builtin -- 1828
			} -- 1824
		end -- 1822
		if children then -- 1830
			table.sort(children, function(a, b) -- 1831
				if a.dir == b.dir then -- 1832
					return a.title < b.title -- 1833
				else -- 1835
					return a.dir -- 1835
				end -- 1832
			end) -- 1831
		end -- 1830
		if isWorkspace and children then -- 1836
			return children -- 1837
		else -- 1839
			return { -- 1840
				key = path, -- 1840
				dir = true, -- 1841
				title = Path:getFilename(path), -- 1842
				builtin = builtin, -- 1843
				children = children -- 1844
			} -- 1839
		end -- 1836
	end -- 1788
	local zh = (App.locale:match("^zh") ~= nil) -- 1846
	return { -- 1848
		key = Content.writablePath, -- 1848
		dir = true, -- 1849
		root = true, -- 1850
		title = "Assets", -- 1851
		children = (function() -- 1853
			local _tab_0 = { -- 1853
				{ -- 1854
					key = Path(Content.assetPath), -- 1854
					dir = true, -- 1855
					builtin = true, -- 1856
					title = zh and "内置资源" or "Built-in", -- 1857
					children = { -- 1859
						(function() -- 1859
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1859
							_with_0.title = zh and "说明文档" or "Readme" -- 1860
							return _with_0 -- 1859
						end)(), -- 1859
						(function() -- 1861
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1861
							_with_0.title = zh and "接口文档" or "API Doc" -- 1862
							return _with_0 -- 1861
						end)(), -- 1861
						(function() -- 1863
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1863
							_with_0.title = zh and "开发工具" or "Tools" -- 1864
							return _with_0 -- 1863
						end)(), -- 1863
						(function() -- 1865
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1865
							_with_0.title = zh and "字体" or "Font" -- 1866
							return _with_0 -- 1865
						end)(), -- 1865
						(function() -- 1867
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1867
							_with_0.title = zh and "程序库" or "Lib" -- 1868
							if engineDev then -- 1869
								local _list_0 = _with_0.children -- 1870
								for _index_0 = 1, #_list_0 do -- 1870
									local child = _list_0[_index_0] -- 1870
									if not (child.title == "Dora") then -- 1871
										goto _continue_0 -- 1871
									end -- 1871
									local title = zh and "zh-Hans" or "en" -- 1872
									do -- 1873
										local _accum_0 = { } -- 1873
										local _len_0 = 1 -- 1873
										local _list_1 = child.children -- 1873
										for _index_1 = 1, #_list_1 do -- 1873
											local c = _list_1[_index_1] -- 1873
											if c.title ~= title then -- 1873
												_accum_0[_len_0] = c -- 1873
												_len_0 = _len_0 + 1 -- 1873
											end -- 1873
										end -- 1873
										child.children = _accum_0 -- 1873
									end -- 1873
									break -- 1874
									::_continue_0:: -- 1871
								end -- 1870
							else -- 1876
								local _accum_0 = { } -- 1876
								local _len_0 = 1 -- 1876
								local _list_0 = _with_0.children -- 1876
								for _index_0 = 1, #_list_0 do -- 1876
									local child = _list_0[_index_0] -- 1876
									if child.title ~= "Dora" then -- 1876
										_accum_0[_len_0] = child -- 1876
										_len_0 = _len_0 + 1 -- 1876
									end -- 1876
								end -- 1876
								_with_0.children = _accum_0 -- 1876
							end -- 1869
							return _with_0 -- 1867
						end)(), -- 1867
						(function() -- 1877
							if engineDev then -- 1877
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1878
								local _obj_0 = _with_0.children -- 1879
								_obj_0[#_obj_0 + 1] = { -- 1880
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1880
									dir = false, -- 1881
									builtin = true, -- 1882
									title = "init.yue" -- 1883
								} -- 1879
								return _with_0 -- 1878
							end -- 1877
						end)() -- 1877
					} -- 1858
				} -- 1853
			} -- 1887
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1887
			local _idx_0 = #_tab_0 + 1 -- 1887
			for _index_0 = 1, #_obj_0 do -- 1887
				local _value_0 = _obj_0[_index_0] -- 1887
				_tab_0[_idx_0] = _value_0 -- 1887
				_idx_0 = _idx_0 + 1 -- 1887
			end -- 1887
			return _tab_0 -- 1853
		end)() -- 1852
	} -- 1847
end) -- 1783
HttpServer:post("/entry/list", function() -- 1891
	local Entry = require("Script.Dev.Entry") -- 1892
	local res = Entry.getLaunchEntries() -- 1893
	res.success = true -- 1894
	return res -- 1895
end) -- 1891
HttpServer:post("/run/status", function() -- 1897
	local Entry = require("Script.Dev.Entry") -- 1898
	return Entry.getCurrentEntryStatus() -- 1899
end) -- 1897
HttpServer:postSchedule("/run", function(req) -- 1901
	do -- 1902
		local _type_0 = type(req) -- 1902
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1902
		if _tab_0 then -- 1902
			local file -- 1902
			do -- 1902
				local _obj_0 = req.body -- 1902
				local _type_1 = type(_obj_0) -- 1902
				if "table" == _type_1 or "userdata" == _type_1 then -- 1902
					file = _obj_0.file -- 1902
				end -- 1902
			end -- 1902
			local asProj -- 1902
			do -- 1902
				local _obj_0 = req.body -- 1902
				local _type_1 = type(_obj_0) -- 1902
				if "table" == _type_1 or "userdata" == _type_1 then -- 1902
					asProj = _obj_0.asProj -- 1902
				end -- 1902
			end -- 1902
			if file ~= nil and asProj ~= nil then -- 1902
				if not Content:isAbsolutePath(file) then -- 1903
					local devFile = Path(Content.writablePath, file) -- 1904
					if Content:exist(devFile) then -- 1905
						file = devFile -- 1905
					end -- 1905
				end -- 1903
				local Entry = require("Script.Dev.Entry") -- 1906
				local workDir -- 1907
				if asProj then -- 1908
					workDir = getProjectDirFromFile(file) -- 1909
					if workDir then -- 1909
						Entry.allClear() -- 1910
						local target = Path(workDir, "init") -- 1911
						local success, err = Entry.enterEntryAsync({ -- 1912
							entryName = "Project", -- 1912
							fileName = target, -- 1912
							workDir = workDir, -- 1912
							projectRoot = workDir, -- 1912
							runKind = "project" -- 1912
						}) -- 1912
						target = Path:getName(Path:getPath(target)) -- 1913
						return { -- 1914
							success = success, -- 1914
							target = target, -- 1914
							err = err -- 1914
						} -- 1914
					end -- 1909
				else -- 1916
					workDir = getProjectDirFromFile(file) -- 1916
				end -- 1908
				Entry.allClear() -- 1917
				file = Path:replaceExt(file, "") -- 1918
				local entry = { -- 1920
					entryName = Path:getName(file), -- 1920
					fileName = file, -- 1921
					runKind = "file" -- 1922
				} -- 1919
				if workDir then -- 1923
					entry.workDir = workDir -- 1924
					entry.projectRoot = workDir -- 1925
				end -- 1923
				local success, err = Entry.enterEntryAsync(entry) -- 1926
				return { -- 1927
					success = success, -- 1927
					err = err -- 1927
				} -- 1927
			end -- 1902
		end -- 1902
	end -- 1902
	return { -- 1901
		success = false -- 1901
	} -- 1901
end) -- 1901
HttpServer:postSchedule("/stop", function() -- 1929
	local Entry = require("Script.Dev.Entry") -- 1930
	return { -- 1931
		success = Entry.stop() -- 1931
	} -- 1931
end) -- 1929
local minifyAsync -- 1933
minifyAsync = function(sourcePath, minifyPath) -- 1933
	if not Content:exist(sourcePath) then -- 1934
		return -- 1934
	end -- 1934
	local Entry = require("Script.Dev.Entry") -- 1935
	local errors = { } -- 1936
	local files = Entry.getAllFiles(sourcePath, { -- 1937
		"lua" -- 1937
	}, true) -- 1937
	do -- 1938
		local _accum_0 = { } -- 1938
		local _len_0 = 1 -- 1938
		for _index_0 = 1, #files do -- 1938
			local file = files[_index_0] -- 1938
			if file:sub(1, 1) ~= '.' then -- 1938
				_accum_0[_len_0] = file -- 1938
				_len_0 = _len_0 + 1 -- 1938
			end -- 1938
		end -- 1938
		files = _accum_0 -- 1938
	end -- 1938
	local paths -- 1939
	do -- 1939
		local _tbl_0 = { } -- 1939
		for _index_0 = 1, #files do -- 1939
			local file = files[_index_0] -- 1939
			_tbl_0[Path:getPath(file)] = true -- 1939
		end -- 1939
		paths = _tbl_0 -- 1939
	end -- 1939
	for path in pairs(paths) do -- 1940
		Content:mkdir(Path(minifyPath, path)) -- 1940
	end -- 1940
	local _ <close> = setmetatable({ }, { -- 1941
		__close = function() -- 1941
			package.loaded["luaminify.FormatMini"] = nil -- 1942
			package.loaded["luaminify.ParseLua"] = nil -- 1943
			package.loaded["luaminify.Scope"] = nil -- 1944
			package.loaded["luaminify.Util"] = nil -- 1945
		end -- 1941
	}) -- 1941
	local FormatMini -- 1946
	do -- 1946
		local _obj_0 = require("luaminify") -- 1946
		FormatMini = _obj_0.FormatMini -- 1946
	end -- 1946
	local fileCount = #files -- 1947
	local count = 0 -- 1948
	for _index_0 = 1, #files do -- 1949
		local file = files[_index_0] -- 1949
		thread(function() -- 1950
			local _ <close> = setmetatable({ }, { -- 1951
				__close = function() -- 1951
					count = count + 1 -- 1951
				end -- 1951
			}) -- 1951
			local input = Path(sourcePath, file) -- 1952
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1953
			if Content:exist(input) then -- 1954
				local sourceCodes = Content:loadAsync(input) -- 1955
				local res, err = FormatMini(sourceCodes) -- 1956
				if res then -- 1957
					Content:saveAsync(output, res) -- 1958
					return print("Minify " .. tostring(file)) -- 1959
				else -- 1961
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1961
				end -- 1957
			else -- 1963
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1963
			end -- 1954
		end) -- 1950
		sleep() -- 1964
	end -- 1949
	wait(function() -- 1965
		return count == fileCount -- 1965
	end) -- 1965
	if #errors > 0 then -- 1966
		print(table.concat(errors, '\n')) -- 1967
	end -- 1966
	print("Obfuscation done.") -- 1968
	return files -- 1969
end -- 1933
local zipping = false -- 1971
HttpServer:postSchedule("/zip", function(req) -- 1973
	do -- 1974
		local _type_0 = type(req) -- 1974
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1974
		if _tab_0 then -- 1974
			local path -- 1974
			do -- 1974
				local _obj_0 = req.body -- 1974
				local _type_1 = type(_obj_0) -- 1974
				if "table" == _type_1 or "userdata" == _type_1 then -- 1974
					path = _obj_0.path -- 1974
				end -- 1974
			end -- 1974
			local zipFile -- 1974
			do -- 1974
				local _obj_0 = req.body -- 1974
				local _type_1 = type(_obj_0) -- 1974
				if "table" == _type_1 or "userdata" == _type_1 then -- 1974
					zipFile = _obj_0.zipFile -- 1974
				end -- 1974
			end -- 1974
			local obfuscated -- 1974
			do -- 1974
				local _obj_0 = req.body -- 1974
				local _type_1 = type(_obj_0) -- 1974
				if "table" == _type_1 or "userdata" == _type_1 then -- 1974
					obfuscated = _obj_0.obfuscated -- 1974
				end -- 1974
			end -- 1974
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1974
				if zipping then -- 1975
					goto failed -- 1975
				end -- 1975
				zipping = true -- 1976
				local _ <close> = setmetatable({ }, { -- 1977
					__close = function() -- 1977
						zipping = false -- 1977
					end -- 1977
				}) -- 1977
				if not Content:exist(path) then -- 1978
					goto failed -- 1978
				end -- 1978
				Content:mkdir(Path:getPath(zipFile)) -- 1979
				if obfuscated then -- 1980
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1981
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1982
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1983
					Content:remove(scriptPath) -- 1984
					Content:remove(obfuscatedPath) -- 1985
					Content:remove(tempPath) -- 1986
					Content:mkdir(scriptPath) -- 1987
					Content:mkdir(obfuscatedPath) -- 1988
					Content:mkdir(tempPath) -- 1989
					if not Content:copyAsync(path, tempPath) then -- 1990
						goto failed -- 1990
					end -- 1990
					local Entry = require("Script.Dev.Entry") -- 1991
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1992
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1993
						"tl", -- 1993
						"yue", -- 1993
						"lua", -- 1993
						"ts", -- 1993
						"tsx", -- 1993
						"vs", -- 1993
						"bl", -- 1993
						"xml", -- 1993
						"wa", -- 1993
						"mod" -- 1993
					}, true) -- 1993
					for _index_0 = 1, #scriptFiles do -- 1994
						local file = scriptFiles[_index_0] -- 1994
						Content:remove(Path(tempPath, file)) -- 1995
					end -- 1994
					for _index_0 = 1, #luaFiles do -- 1996
						local file = luaFiles[_index_0] -- 1996
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1997
					end -- 1996
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1998
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1999
					end) then -- 1998
						goto failed -- 1998
					end -- 1998
					return { -- 2000
						success = true -- 2000
					} -- 2000
				else -- 2002
					return { -- 2002
						success = Content:zipAsync(path, zipFile, function(file) -- 2002
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2003
						end) -- 2002
					} -- 2002
				end -- 1980
			end -- 1974
		end -- 1974
	end -- 1974
	::failed:: -- 2004
	return { -- 1973
		success = false -- 1973
	} -- 1973
end) -- 1973
HttpServer:postSchedule("/unzip", function(req) -- 2006
	do -- 2007
		local _type_0 = type(req) -- 2007
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2007
		if _tab_0 then -- 2007
			local zipFile -- 2007
			do -- 2007
				local _obj_0 = req.body -- 2007
				local _type_1 = type(_obj_0) -- 2007
				if "table" == _type_1 or "userdata" == _type_1 then -- 2007
					zipFile = _obj_0.zipFile -- 2007
				end -- 2007
			end -- 2007
			local path -- 2007
			do -- 2007
				local _obj_0 = req.body -- 2007
				local _type_1 = type(_obj_0) -- 2007
				if "table" == _type_1 or "userdata" == _type_1 then -- 2007
					path = _obj_0.path -- 2007
				end -- 2007
			end -- 2007
			if zipFile ~= nil and path ~= nil then -- 2007
				return { -- 2008
					success = Content:unzipAsync(zipFile, path, function(file) -- 2008
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2009
					end) -- 2008
				} -- 2008
			end -- 2007
		end -- 2007
	end -- 2007
	return { -- 2006
		success = false -- 2006
	} -- 2006
end) -- 2006
HttpServer:post("/editing-info", function(req) -- 2011
	local Entry = require("Script.Dev.Entry") -- 2012
	local config = Entry.getConfig() -- 2013
	local _type_0 = type(req) -- 2014
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2014
	local _match_0 = false -- 2014
	if _tab_0 then -- 2014
		local editingInfo -- 2014
		do -- 2014
			local _obj_0 = req.body -- 2014
			local _type_1 = type(_obj_0) -- 2014
			if "table" == _type_1 or "userdata" == _type_1 then -- 2014
				editingInfo = _obj_0.editingInfo -- 2014
			end -- 2014
		end -- 2014
		if editingInfo ~= nil then -- 2014
			_match_0 = true -- 2014
			config.editingInfo = editingInfo -- 2015
			return { -- 2016
				success = true -- 2016
			} -- 2016
		end -- 2014
	end -- 2014
	if not _match_0 then -- 2014
		if not (config.editingInfo ~= nil) then -- 2018
			local folder -- 2019
			if App.locale:match('^zh') then -- 2019
				folder = 'zh-Hans' -- 2019
			else -- 2019
				folder = 'en' -- 2019
			end -- 2019
			config.editingInfo = json.encode({ -- 2021
				index = 0, -- 2021
				files = { -- 2023
					{ -- 2024
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2024
						title = "welcome.md" -- 2025
					} -- 2023
				} -- 2022
			}) -- 2020
		end -- 2018
		return { -- 2029
			success = true, -- 2029
			editingInfo = config.editingInfo -- 2029
		} -- 2029
	end -- 2014
end) -- 2011
HttpServer:post("/command", function(req) -- 2031
	do -- 2032
		local _type_0 = type(req) -- 2032
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2032
		if _tab_0 then -- 2032
			local code -- 2032
			do -- 2032
				local _obj_0 = req.body -- 2032
				local _type_1 = type(_obj_0) -- 2032
				if "table" == _type_1 or "userdata" == _type_1 then -- 2032
					code = _obj_0.code -- 2032
				end -- 2032
			end -- 2032
			local log -- 2032
			do -- 2032
				local _obj_0 = req.body -- 2032
				local _type_1 = type(_obj_0) -- 2032
				if "table" == _type_1 or "userdata" == _type_1 then -- 2032
					log = _obj_0.log -- 2032
				end -- 2032
			end -- 2032
			if code ~= nil and log ~= nil then -- 2032
				emit("AppCommand", code, log) -- 2033
				return { -- 2034
					success = true -- 2034
				} -- 2034
			end -- 2032
		end -- 2032
	end -- 2032
	return { -- 2031
		success = false -- 2031
	} -- 2031
end) -- 2031
HttpServer:post("/log/save", function() -- 2036
	local folder = ".download" -- 2037
	local fullLogFile = "dora_full_logs.txt" -- 2038
	local fullFolder = Path(Content.writablePath, folder) -- 2039
	Content:mkdir(fullFolder) -- 2040
	local logPath = Path(fullFolder, fullLogFile) -- 2041
	if App:saveLog(logPath) then -- 2042
		return { -- 2043
			success = true, -- 2043
			path = Path(folder, fullLogFile) -- 2043
		} -- 2043
	end -- 2042
	return { -- 2036
		success = false -- 2036
	} -- 2036
end) -- 2036
HttpServer:post("/yarn/check", function(req) -- 2045
	local yarncompile = require("yarncompile") -- 2046
	do -- 2047
		local _type_0 = type(req) -- 2047
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2047
		if _tab_0 then -- 2047
			local code -- 2047
			do -- 2047
				local _obj_0 = req.body -- 2047
				local _type_1 = type(_obj_0) -- 2047
				if "table" == _type_1 or "userdata" == _type_1 then -- 2047
					code = _obj_0.code -- 2047
				end -- 2047
			end -- 2047
			if code ~= nil then -- 2047
				local jsonObject = json.decode(code) -- 2048
				if jsonObject then -- 2048
					local errors = { } -- 2049
					local _list_0 = jsonObject.nodes -- 2050
					for _index_0 = 1, #_list_0 do -- 2050
						local node = _list_0[_index_0] -- 2050
						local title, body = node.title, node.body -- 2051
						local luaCode, err = yarncompile(body) -- 2052
						if not luaCode then -- 2052
							errors[#errors + 1] = title .. ":" .. err -- 2053
						end -- 2052
					end -- 2050
					return { -- 2054
						success = true, -- 2054
						syntaxError = table.concat(errors, "\n\n") -- 2054
					} -- 2054
				end -- 2048
			end -- 2047
		end -- 2047
	end -- 2047
	return { -- 2045
		success = false -- 2045
	} -- 2045
end) -- 2045
HttpServer:post("/yarn/check-file", function(req) -- 2056
	local yarncompile = require("yarncompile") -- 2057
	do -- 2058
		local _type_0 = type(req) -- 2058
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2058
		if _tab_0 then -- 2058
			local code -- 2058
			do -- 2058
				local _obj_0 = req.body -- 2058
				local _type_1 = type(_obj_0) -- 2058
				if "table" == _type_1 or "userdata" == _type_1 then -- 2058
					code = _obj_0.code -- 2058
				end -- 2058
			end -- 2058
			if code ~= nil then -- 2058
				local res, _, err = yarncompile(code, true) -- 2059
				if not res then -- 2059
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2060
					return { -- 2061
						success = false, -- 2061
						message = message, -- 2061
						line = line, -- 2061
						column = column, -- 2061
						node = node -- 2061
					} -- 2061
				end -- 2059
			end -- 2058
		end -- 2058
	end -- 2058
	return { -- 2056
		success = true -- 2056
	} -- 2056
end) -- 2056
local getWaProjectDirFromFile -- 2063
getWaProjectDirFromFile = function(file) -- 2063
	local writablePath = Content.writablePath -- 2064
	local parent, current -- 2065
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 2065
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 2066
	else -- 2068
		parent, current = nil, nil -- 2068
	end -- 2065
	if not current then -- 2069
		return nil -- 2069
	end -- 2069
	repeat -- 2070
		current = Path:getPath(current) -- 2071
		if current == "" then -- 2072
			break -- 2072
		end -- 2072
		local _list_0 = Content:getFiles(Path(parent, current)) -- 2073
		for _index_0 = 1, #_list_0 do -- 2073
			local f = _list_0[_index_0] -- 2073
			if Path:getFilename(f):lower() == "wa.mod" then -- 2074
				return Path(parent, current, Path:getPath(f)) -- 2075
			end -- 2074
		end -- 2073
	until false -- 2070
	return nil -- 2077
end -- 2063
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2079
	do -- 2080
		local _type_0 = type(req) -- 2080
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2080
		if _tab_0 then -- 2080
			local path -- 2080
			do -- 2080
				local _obj_0 = req.body -- 2080
				local _type_1 = type(_obj_0) -- 2080
				if "table" == _type_1 or "userdata" == _type_1 then -- 2080
					path = _obj_0.path -- 2080
				end -- 2080
			end -- 2080
			if path ~= nil then -- 2080
				local projDir = getWaProjectDirFromFile(path) -- 2081
				if projDir then -- 2081
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2082
					if not Content:exist(sourceDoraPath) then -- 2083
						return { -- 2084
							success = false, -- 2084
							message = "missing dora template" -- 2084
						} -- 2084
					end -- 2083
					local targetVendorPath = Path(projDir, "vendor") -- 2085
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2086
					if not Content:exist(targetVendorPath) then -- 2087
						if not Content:mkdir(targetVendorPath) then -- 2088
							return { -- 2089
								success = false, -- 2089
								message = "failed to create vendor folder" -- 2089
							} -- 2089
						end -- 2088
					elseif not Content:isdir(targetVendorPath) then -- 2090
						return { -- 2091
							success = false, -- 2091
							message = "vendor path is not a folder" -- 2091
						} -- 2091
					end -- 2087
					if Content:exist(targetDoraPath) then -- 2092
						if not Content:remove(targetDoraPath) then -- 2093
							return { -- 2094
								success = false, -- 2094
								message = "failed to remove old dora" -- 2094
							} -- 2094
						end -- 2093
					end -- 2092
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2095
						return { -- 2096
							success = false, -- 2096
							message = "failed to copy dora" -- 2096
						} -- 2096
					end -- 2095
					return { -- 2097
						success = true -- 2097
					} -- 2097
				else -- 2099
					return { -- 2099
						success = false, -- 2099
						message = 'Wa file needs a project' -- 2099
					} -- 2099
				end -- 2081
			end -- 2080
		end -- 2080
	end -- 2080
	return { -- 2079
		success = false, -- 2079
		message = "invalid call" -- 2079
	} -- 2079
end) -- 2079
HttpServer:postSchedule("/wa/build", function(req) -- 2101
	do -- 2102
		local _type_0 = type(req) -- 2102
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2102
		if _tab_0 then -- 2102
			local path -- 2102
			do -- 2102
				local _obj_0 = req.body -- 2102
				local _type_1 = type(_obj_0) -- 2102
				if "table" == _type_1 or "userdata" == _type_1 then -- 2102
					path = _obj_0.path -- 2102
				end -- 2102
			end -- 2102
			if path ~= nil then -- 2102
				local projDir = getWaProjectDirFromFile(path) -- 2103
				if projDir then -- 2103
					local message = Wasm:buildWaAsync(projDir) -- 2104
					if message == "" then -- 2105
						return { -- 2106
							success = true -- 2106
						} -- 2106
					else -- 2108
						return { -- 2108
							success = false, -- 2108
							message = message -- 2108
						} -- 2108
					end -- 2105
				else -- 2110
					return { -- 2110
						success = false, -- 2110
						message = 'Wa file needs a project' -- 2110
					} -- 2110
				end -- 2103
			end -- 2102
		end -- 2102
	end -- 2102
	return { -- 2111
		success = false, -- 2111
		message = 'failed to build' -- 2111
	} -- 2111
end) -- 2101
HttpServer:postSchedule("/wa/format", function(req) -- 2113
	do -- 2114
		local _type_0 = type(req) -- 2114
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2114
		if _tab_0 then -- 2114
			local file -- 2114
			do -- 2114
				local _obj_0 = req.body -- 2114
				local _type_1 = type(_obj_0) -- 2114
				if "table" == _type_1 or "userdata" == _type_1 then -- 2114
					file = _obj_0.file -- 2114
				end -- 2114
			end -- 2114
			if file ~= nil then -- 2114
				local code = Wasm:formatWaAsync(file) -- 2115
				if code == "" then -- 2116
					return { -- 2117
						success = false -- 2117
					} -- 2117
				else -- 2119
					return { -- 2119
						success = true, -- 2119
						code = code -- 2119
					} -- 2119
				end -- 2116
			end -- 2114
		end -- 2114
	end -- 2114
	return { -- 2120
		success = false -- 2120
	} -- 2120
end) -- 2113
HttpServer:postSchedule("/wa/create", function(req) -- 2122
	do -- 2123
		local _type_0 = type(req) -- 2123
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2123
		if _tab_0 then -- 2123
			local path -- 2123
			do -- 2123
				local _obj_0 = req.body -- 2123
				local _type_1 = type(_obj_0) -- 2123
				if "table" == _type_1 or "userdata" == _type_1 then -- 2123
					path = _obj_0.path -- 2123
				end -- 2123
			end -- 2123
			if path ~= nil then -- 2123
				if not Content:exist(Path:getPath(path)) then -- 2124
					return { -- 2125
						success = false, -- 2125
						message = "target path not existed" -- 2125
					} -- 2125
				end -- 2124
				if Content:exist(path) then -- 2126
					return { -- 2127
						success = false, -- 2127
						message = "target project folder existed" -- 2127
					} -- 2127
				end -- 2126
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2128
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2129
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2130
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2131
					return { -- 2134
						success = false, -- 2134
						message = "missing template project" -- 2134
					} -- 2134
				end -- 2131
				if not Content:mkdir(path) then -- 2135
					return { -- 2136
						success = false, -- 2136
						message = "failed to create project folder" -- 2136
					} -- 2136
				end -- 2135
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2137
					Content:remove(path) -- 2138
					return { -- 2139
						success = false, -- 2139
						message = "failed to copy template" -- 2139
					} -- 2139
				end -- 2137
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2140
					Content:remove(path) -- 2141
					return { -- 2142
						success = false, -- 2142
						message = "failed to copy template" -- 2142
					} -- 2142
				end -- 2140
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2143
					Content:remove(path) -- 2144
					return { -- 2145
						success = false, -- 2145
						message = "failed to copy template" -- 2145
					} -- 2145
				end -- 2143
				return { -- 2146
					success = true -- 2146
				} -- 2146
			end -- 2123
		end -- 2123
	end -- 2123
	return { -- 2122
		success = false, -- 2122
		message = "invalid call" -- 2122
	} -- 2122
end) -- 2122
local tsBuildGlobs = { -- 2149
	"**/*.ts", -- 2149
	"**/*.tsx", -- 2150
	"!**/.*/**", -- 2151
	"!**/node_modules/**" -- 2152
} -- 2148
local _anon_func_6 = function(path) -- 2161
	local _val_0 = Path:getExt(path) -- 2161
	return "ts" == _val_0 or "tsx" == _val_0 -- 2161
end -- 2161
HttpServer:postSchedule("/ts/build", function(req) -- 2154
	do -- 2155
		local _type_0 = type(req) -- 2155
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2155
		if _tab_0 then -- 2155
			local path -- 2155
			do -- 2155
				local _obj_0 = req.body -- 2155
				local _type_1 = type(_obj_0) -- 2155
				if "table" == _type_1 or "userdata" == _type_1 then -- 2155
					path = _obj_0.path -- 2155
				end -- 2155
			end -- 2155
			if path ~= nil then -- 2155
				if HttpServer.wsConnectionCount == 0 then -- 2156
					return { -- 2157
						success = false, -- 2157
						message = "Web IDE not connected" -- 2157
					} -- 2157
				end -- 2156
				if not Content:exist(path) then -- 2158
					return { -- 2159
						success = false, -- 2159
						message = "path not existed" -- 2159
					} -- 2159
				end -- 2158
				if not Content:isdir(path) then -- 2160
					if not (_anon_func_6(path)) then -- 2161
						return { -- 2162
							success = false, -- 2162
							message = "expecting a TypeScript file" -- 2162
						} -- 2162
					end -- 2161
					local messages = { } -- 2163
					local content = Content:load(path) -- 2164
					if not content then -- 2165
						return { -- 2166
							success = false, -- 2166
							message = "failed to read file" -- 2166
						} -- 2166
					end -- 2165
					emit("AppWS", "Send", json.encode({ -- 2167
						name = "UpdateFile", -- 2167
						file = path, -- 2167
						exists = true, -- 2167
						content = content -- 2167
					})) -- 2167
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2168
						local done = false -- 2169
						do -- 2170
							local _with_0 = Node() -- 2170
							_with_0:gslot("AppWS", function(event) -- 2171
								if event.type == "Receive" then -- 2172
									local res = json.decode(event.msg) -- 2173
									if res then -- 2173
										if res.name == "TranspileTS" and res.file == path then -- 2174
											_with_0:removeFromParent() -- 2175
											if res.success then -- 2176
												local luaFile = Path:replaceExt(path, "lua") -- 2177
												Content:save(luaFile, res.luaCode) -- 2178
												messages[#messages + 1] = { -- 2179
													success = true, -- 2179
													file = path -- 2179
												} -- 2179
											else -- 2181
												messages[#messages + 1] = { -- 2181
													success = false, -- 2181
													file = path, -- 2181
													message = res.message -- 2181
												} -- 2181
											end -- 2176
											done = true -- 2182
										end -- 2174
									end -- 2173
								end -- 2172
							end) -- 2171
						end -- 2170
						emit("AppWS", "Send", json.encode({ -- 2183
							name = "TranspileTS", -- 2183
							file = path, -- 2183
							content = content -- 2183
						})) -- 2183
						wait(function() -- 2184
							return done -- 2184
						end) -- 2184
					end -- 2168
					return { -- 2185
						success = true, -- 2185
						messages = messages -- 2185
					} -- 2185
				else -- 2187
					local fileData = { } -- 2187
					local messages = { } -- 2188
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2189
					for _index_0 = 1, #_list_0 do -- 2189
						local subFile = _list_0[_index_0] -- 2189
						local file = Path(path, subFile) -- 2190
						local content = Content:load(file) -- 2191
						if content then -- 2191
							fileData[file] = content -- 2192
							emit("AppWS", "Send", json.encode({ -- 2193
								name = "UpdateFile", -- 2193
								file = file, -- 2193
								exists = true, -- 2193
								content = content -- 2193
							})) -- 2193
						else -- 2195
							messages[#messages + 1] = { -- 2195
								success = false, -- 2195
								file = file, -- 2195
								message = "failed to read file" -- 2195
							} -- 2195
						end -- 2191
					end -- 2189
					for file, content in pairs(fileData) do -- 2196
						if "d" == Path:getExt(Path:getName(file)) then -- 2197
							goto _continue_0 -- 2197
						end -- 2197
						local done = false -- 2198
						do -- 2199
							local _with_0 = Node() -- 2199
							_with_0:gslot("AppWS", function(event) -- 2200
								if event.type == "Receive" then -- 2201
									local res = json.decode(event.msg) -- 2202
									if res then -- 2202
										if res.name == "TranspileTS" and res.file == file then -- 2203
											_with_0:removeFromParent() -- 2204
											if res.success then -- 2205
												local luaFile = Path:replaceExt(file, "lua") -- 2206
												Content:save(luaFile, res.luaCode) -- 2207
												messages[#messages + 1] = { -- 2208
													success = true, -- 2208
													file = file -- 2208
												} -- 2208
											else -- 2210
												messages[#messages + 1] = { -- 2210
													success = false, -- 2210
													file = file, -- 2210
													message = res.message -- 2210
												} -- 2210
											end -- 2205
											done = true -- 2211
										end -- 2203
									end -- 2202
								end -- 2201
							end) -- 2200
						end -- 2199
						emit("AppWS", "Send", json.encode({ -- 2212
							name = "TranspileTS", -- 2212
							file = file, -- 2212
							content = content -- 2212
						})) -- 2212
						wait(function() -- 2213
							return done -- 2213
						end) -- 2213
						::_continue_0:: -- 2197
					end -- 2196
					return { -- 2214
						success = true, -- 2214
						messages = messages -- 2214
					} -- 2214
				end -- 2160
			end -- 2155
		end -- 2155
	end -- 2155
	return { -- 2154
		success = false -- 2154
	} -- 2154
end) -- 2154
HttpServer:post("/download", function(req) -- 2216
	do -- 2217
		local _type_0 = type(req) -- 2217
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2217
		if _tab_0 then -- 2217
			local url -- 2217
			do -- 2217
				local _obj_0 = req.body -- 2217
				local _type_1 = type(_obj_0) -- 2217
				if "table" == _type_1 or "userdata" == _type_1 then -- 2217
					url = _obj_0.url -- 2217
				end -- 2217
			end -- 2217
			local target -- 2217
			do -- 2217
				local _obj_0 = req.body -- 2217
				local _type_1 = type(_obj_0) -- 2217
				if "table" == _type_1 or "userdata" == _type_1 then -- 2217
					target = _obj_0.target -- 2217
				end -- 2217
			end -- 2217
			if url ~= nil and target ~= nil then -- 2217
				local Entry = require("Script.Dev.Entry") -- 2218
				Entry.downloadFile(url, target) -- 2219
				return { -- 2220
					success = true -- 2220
				} -- 2220
			end -- 2217
		end -- 2217
	end -- 2217
	return { -- 2216
		success = false -- 2216
	} -- 2216
end) -- 2216
local status = { } -- 2222
_module_0 = status -- 2223
status.buildAsync = function(path) -- 2225
	if not Content:exist(path) then -- 2226
		return { -- 2227
			success = false, -- 2227
			file = path, -- 2227
			message = "file not existed" -- 2227
		} -- 2227
	end -- 2226
	do -- 2228
		local _exp_0 = Path:getExt(path) -- 2228
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2228
			if '' == Path:getExt(Path:getName(path)) then -- 2229
				local content = Content:loadAsync(path) -- 2230
				if content then -- 2230
					local resultCodes, err = compileFileAsync(path, content) -- 2231
					if resultCodes then -- 2231
						return { -- 2232
							success = true, -- 2232
							file = path -- 2232
						} -- 2232
					else -- 2234
						return { -- 2234
							success = false, -- 2234
							file = path, -- 2234
							message = err -- 2234
						} -- 2234
					end -- 2231
				end -- 2230
			end -- 2229
		elseif "lua" == _exp_0 then -- 2235
			local content = Content:loadAsync(path) -- 2236
			if content then -- 2236
				do -- 2237
					local isTIC80 = CheckTIC80Code(content) -- 2237
					if isTIC80 then -- 2237
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2238
					end -- 2237
				end -- 2237
				local success, info -- 2239
				do -- 2239
					local _obj_0 = luaCheck(path, content) -- 2239
					success, info = _obj_0.success, _obj_0.info -- 2239
				end -- 2239
				if success then -- 2240
					return { -- 2241
						success = true, -- 2241
						file = path -- 2241
					} -- 2241
				elseif info and #info > 0 then -- 2242
					local messages = { } -- 2243
					for _index_0 = 1, #info do -- 2244
						local _des_0 = info[_index_0] -- 2244
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2244
						local lineText = "" -- 2245
						if line then -- 2246
							local currentLine = 1 -- 2247
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2248
								if currentLine == line then -- 2249
									lineText = text -- 2250
									break -- 2251
								end -- 2249
								currentLine = currentLine + 1 -- 2252
							end -- 2248
						end -- 2246
						if line then -- 2253
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2254
						else -- 2256
							messages[#messages + 1] = message -- 2256
						end -- 2253
					end -- 2244
					return { -- 2257
						success = false, -- 2257
						file = path, -- 2257
						message = table.concat(messages, "\n") -- 2257
					} -- 2257
				else -- 2259
					return { -- 2259
						success = false, -- 2259
						file = path, -- 2259
						message = "lua check failed" -- 2259
					} -- 2259
				end -- 2240
			end -- 2236
		elseif "yarn" == _exp_0 then -- 2260
			local content = Content:loadAsync(path) -- 2261
			if content then -- 2261
				local res, _, err = yarncompile(content, true) -- 2262
				if res then -- 2262
					return { -- 2263
						success = true, -- 2263
						file = path -- 2263
					} -- 2263
				else -- 2265
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2265
					local lineText = "" -- 2266
					if line then -- 2267
						local currentLine = 1 -- 2268
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2269
							if currentLine == line then -- 2270
								lineText = text -- 2271
								break -- 2272
							end -- 2270
							currentLine = currentLine + 1 -- 2273
						end -- 2269
					end -- 2267
					if node ~= "" then -- 2274
						node = "node: " .. tostring(node) .. ", " -- 2275
					else -- 2276
						node = "" -- 2276
					end -- 2274
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2277
					return { -- 2278
						success = false, -- 2278
						file = path, -- 2278
						message = message -- 2278
					} -- 2278
				end -- 2262
			end -- 2261
		end -- 2228
	end -- 2228
	return { -- 2279
		success = false, -- 2279
		file = path, -- 2279
		message = "invalid file to build" -- 2279
	} -- 2279
end -- 2225
thread(function() -- 2281
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 2282
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 2283
	if Content:exist(doraWeb) then -- 2284
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) -- 2285
		local needReload -- 2286
		if Content:exist(doraReady) then -- 2286
			needReload = readyContent ~= Content:load(doraReady) -- 2287
		else -- 2288
			needReload = true -- 2288
		end -- 2286
		if needReload then -- 2289
			Content:remove(Path(Content.appPath, ".www")) -- 2290
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 2291
			Content:save(doraReady, readyContent) -- 2295
			print("Dora Dora is ready!") -- 2296
		end -- 2289
	end -- 2284
	if HttpServer:start(8866) then -- 2297
		local localIP = HttpServer.localIP -- 2298
		if localIP == "" then -- 2299
			localIP = "localhost" -- 2299
		end -- 2299
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 2300
		return HttpServer:startWS(8868) -- 2301
	else -- 2303
		status.url = nil -- 2303
		return print("8866 Port not available!") -- 2304
	end -- 2297
end) -- 2281
return _module_0 -- 1
