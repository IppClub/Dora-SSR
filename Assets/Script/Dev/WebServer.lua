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
							if f:match("^%.") then -- 1338
								goto _continue_1 -- 1338
							end -- 1338
							if folder == "" then -- 1339
								files[#files + 1] = f -- 1340
							else -- 1342
								files[#files + 1] = Path(folder, f) -- 1342
							end -- 1339
							::_continue_1:: -- 1338
						end -- 1337
					end -- 1326
					visitAssets(path, "") -- 1343
					if #files == 0 then -- 1344
						files = nil -- 1344
					end -- 1344
					return { -- 1345
						success = true, -- 1345
						files = files -- 1345
					} -- 1345
				end -- 1324
			end -- 1323
		end -- 1323
	end -- 1323
	return { -- 1322
		success = false -- 1322
	} -- 1322
end) -- 1322
HttpServer:post("/info", function() -- 1347
	local Entry = require("Script.Dev.Entry") -- 1348
	local webProfiler, drawerWidth -- 1349
	do -- 1349
		local _obj_0 = Entry.getConfig() -- 1349
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 1349
	end -- 1349
	local engineDev = Entry.getEngineDev() -- 1350
	Entry.connectWebIDE() -- 1351
	return { -- 1353
		platform = App.platform, -- 1353
		locale = App.locale, -- 1354
		version = App.version, -- 1355
		engineDev = engineDev, -- 1356
		webProfiler = webProfiler, -- 1357
		drawerWidth = drawerWidth -- 1358
	} -- 1352
end) -- 1347
local ensureLLMConfigTable -- 1360
ensureLLMConfigTable = function() -- 1360
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1361
	if columns and #columns > 0 then -- 1362
		local expected = { -- 1364
			id = true, -- 1364
			name = true, -- 1365
			url = true, -- 1366
			model = true, -- 1367
			api_key = true, -- 1368
			context_window = true, -- 1369
			temperature = true, -- 1370
			max_tokens = true, -- 1371
			reasoning_effort = true, -- 1372
			custom_options = true, -- 1373
			supports_function_calling = true, -- 1374
			active = true, -- 1375
			created_at = true, -- 1376
			updated_at = true -- 1377
		} -- 1363
		local existing = { } -- 1379
		local valid = true -- 1380
		for _index_0 = 1, #columns do -- 1381
			local row = columns[_index_0] -- 1381
			local columnName = tostring(row[2]) -- 1382
			existing[columnName] = true -- 1383
			if not expected[columnName] then -- 1384
				valid = false -- 1385
				break -- 1386
			end -- 1384
		end -- 1381
		if valid then -- 1387
			if not existing.context_window then -- 1388
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1389
			end -- 1388
			if not existing.temperature then -- 1390
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1391
			end -- 1390
			if not existing.max_tokens then -- 1392
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 1393
			end -- 1392
			if not existing.reasoning_effort then -- 1394
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1395
			end -- 1394
			if not existing.custom_options then -- 1396
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1397
			end -- 1396
			if not existing.supports_function_calling then -- 1398
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1399
			end -- 1398
		else -- 1401
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1401
		end -- 1387
	end -- 1362
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
	]]) -- 1402
end -- 1360
local normalizeContextWindow -- 1421
normalizeContextWindow = function(value) -- 1421
	local contextWindow = tonumber(value) -- 1422
	if contextWindow == nil or contextWindow < 64000 then -- 1423
		return 64000 -- 1424
	end -- 1423
	return math.max(64000, math.floor(contextWindow)) -- 1425
end -- 1421
local normalizeTemperature -- 1427
normalizeTemperature = function(value) -- 1427
	local temperature = tonumber(value) -- 1428
	if temperature == nil then -- 1429
		return 0.1 -- 1430
	end -- 1429
	return math.max(0, math.min(2, temperature)) -- 1431
end -- 1427
local normalizeMaxTokens -- 1433
normalizeMaxTokens = function(value) -- 1433
	local maxTokens = tonumber(value) -- 1434
	if maxTokens == nil or maxTokens < 1 then -- 1435
		return 8192 -- 1436
	end -- 1435
	return math.max(1, math.floor(maxTokens)) -- 1437
end -- 1433
local normalizeReasoningEffort -- 1439
normalizeReasoningEffort = function(value) -- 1439
	if value == nil then -- 1440
		return "" -- 1441
	end -- 1440
	local effort = tostring(value) -- 1442
	return effort:match("^%s*(.-)%s*$") or "" -- 1443
end -- 1439
local normalizeCustomOptions -- 1445
normalizeCustomOptions = function(value) -- 1445
	if value == nil then -- 1446
		return "" -- 1447
	end -- 1446
	local options = tostring(value) -- 1448
	options = options:match("^%s*(.-)%s*$") or "" -- 1449
	return options -- 1450
end -- 1445
local validateCustomOptions -- 1452
validateCustomOptions = function(value) -- 1452
	local options = normalizeCustomOptions(value) -- 1453
	if options == "" then -- 1454
		return true -- 1454
	end -- 1454
	if not options:match("^%s*{") then -- 1455
		return false -- 1455
	end -- 1455
	local decoded = json.decode(options) -- 1456
	return type(decoded) == "table" -- 1457
end -- 1452
HttpServer:post("/llm/list", function() -- 1459
	ensureLLMConfigTable() -- 1460
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active\n		from LLMConfig\n		order by id asc") -- 1461
	local items -- 1465
	if rows and #rows > 0 then -- 1465
		local _accum_0 = { } -- 1466
		local _len_0 = 1 -- 1466
		for _index_0 = 1, #rows do -- 1466
			local _des_0 = rows[_index_0] -- 1466
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11], _des_0[12] -- 1466
			_accum_0[_len_0] = { -- 1467
				id = id, -- 1467
				name = name, -- 1467
				url = url, -- 1467
				model = model, -- 1467
				key = key, -- 1467
				contextWindow = normalizeContextWindow(contextWindow), -- 1467
				temperature = normalizeTemperature(temperature), -- 1467
				maxTokens = normalizeMaxTokens(maxTokens), -- 1467
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1467
				customOptions = normalizeCustomOptions(customOptions), -- 1467
				supportsFunctionCalling = supportsFunctionCalling ~= 0, -- 1467
				active = active ~= 0 -- 1467
			} -- 1467
			_len_0 = _len_0 + 1 -- 1467
		end -- 1466
		items = _accum_0 -- 1465
	end -- 1465
	return { -- 1468
		success = true, -- 1468
		items = items -- 1468
	} -- 1468
end) -- 1459
HttpServer:post("/llm/create", function(req) -- 1470
	ensureLLMConfigTable() -- 1471
	do -- 1472
		local _type_0 = type(req) -- 1472
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1472
		if _tab_0 then -- 1472
			local body = req.body -- 1472
			if body ~= nil then -- 1472
				local name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1473
				local now = os.time() -- 1474
				if name == nil or url == nil or model == nil or key == nil then -- 1475
					return { -- 1476
						success = false, -- 1476
						message = "invalid" -- 1476
					} -- 1476
				end -- 1475
				contextWindow = normalizeContextWindow(contextWindow) -- 1477
				temperature = normalizeTemperature(temperature) -- 1478
				maxTokens = normalizeMaxTokens(maxTokens) -- 1479
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1480
				customOptions = normalizeCustomOptions(customOptions) -- 1481
				if not validateCustomOptions(customOptions) then -- 1482
					return { -- 1482
						success = false, -- 1482
						message = "customOptions must be a JSON object" -- 1482
					} -- 1482
				end -- 1482
				if supportsFunctionCalling == false then -- 1483
					supportsFunctionCalling = 0 -- 1483
				else -- 1483
					supportsFunctionCalling = 1 -- 1483
				end -- 1483
				if active then -- 1484
					active = 1 -- 1484
				else -- 1484
					active = 0 -- 1484
				end -- 1484
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1491
					tostring(name), -- 1491
					tostring(url), -- 1492
					tostring(model), -- 1493
					tostring(key), -- 1494
					contextWindow, -- 1495
					temperature, -- 1496
					maxTokens, -- 1497
					reasoningEffort, -- 1498
					customOptions, -- 1499
					supportsFunctionCalling, -- 1500
					active, -- 1501
					now, -- 1502
					now -- 1503
				}) -- 1485
				return { -- 1505
					success = affected >= 0 -- 1505
				} -- 1505
			end -- 1472
		end -- 1472
	end -- 1472
	return { -- 1470
		success = false, -- 1470
		message = "invalid" -- 1470
	} -- 1470
end) -- 1470
HttpServer:post("/llm/update", function(req) -- 1507
	ensureLLMConfigTable() -- 1508
	do -- 1509
		local _type_0 = type(req) -- 1509
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1509
		if _tab_0 then -- 1509
			local body = req.body -- 1509
			if body ~= nil then -- 1509
				local id, name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1510
				local now = os.time() -- 1511
				id = tonumber(id) -- 1512
				if id == nil then -- 1513
					return { -- 1514
						success = false, -- 1514
						message = "invalid" -- 1514
					} -- 1514
				end -- 1513
				contextWindow = normalizeContextWindow(contextWindow) -- 1515
				temperature = normalizeTemperature(temperature) -- 1516
				maxTokens = normalizeMaxTokens(maxTokens) -- 1517
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1518
				customOptions = normalizeCustomOptions(customOptions) -- 1519
				if not validateCustomOptions(customOptions) then -- 1520
					return { -- 1520
						success = false, -- 1520
						message = "customOptions must be a JSON object" -- 1520
					} -- 1520
				end -- 1520
				if supportsFunctionCalling == false then -- 1521
					supportsFunctionCalling = 0 -- 1521
				else -- 1521
					supportsFunctionCalling = 1 -- 1521
				end -- 1521
				if active then -- 1522
					active = 1 -- 1522
				else -- 1522
					active = 0 -- 1522
				end -- 1522
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, active = ?, updated_at = ?\n			where id = ?", { -- 1527
					tostring(name), -- 1527
					tostring(url), -- 1528
					tostring(model), -- 1529
					tostring(key), -- 1530
					contextWindow, -- 1531
					temperature, -- 1532
					maxTokens, -- 1533
					reasoningEffort, -- 1534
					customOptions, -- 1535
					supportsFunctionCalling, -- 1536
					active, -- 1537
					now, -- 1538
					id -- 1539
				}) -- 1523
				return { -- 1541
					success = affected >= 0 -- 1541
				} -- 1541
			end -- 1509
		end -- 1509
	end -- 1509
	return { -- 1507
		success = false, -- 1507
		message = "invalid" -- 1507
	} -- 1507
end) -- 1507
HttpServer:post("/llm/delete", function(req) -- 1543
	ensureLLMConfigTable() -- 1544
	do -- 1545
		local _type_0 = type(req) -- 1545
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1545
		if _tab_0 then -- 1545
			local id -- 1545
			do -- 1545
				local _obj_0 = req.body -- 1545
				local _type_1 = type(_obj_0) -- 1545
				if "table" == _type_1 or "userdata" == _type_1 then -- 1545
					id = _obj_0.id -- 1545
				end -- 1545
			end -- 1545
			if id ~= nil then -- 1545
				id = tonumber(id) -- 1546
				if id == nil then -- 1547
					return { -- 1548
						success = false, -- 1548
						message = "invalid" -- 1548
					} -- 1548
				end -- 1547
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1549
					id -- 1549
				}) -- 1549
				return { -- 1550
					success = affected >= 0 -- 1550
				} -- 1550
			end -- 1545
		end -- 1545
	end -- 1545
	return { -- 1543
		success = false, -- 1543
		message = "invalid" -- 1543
	} -- 1543
end) -- 1543
HttpServer:post("/new", function(req) -- 1552
	do -- 1553
		local _type_0 = type(req) -- 1553
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1553
		if _tab_0 then -- 1553
			local path -- 1553
			do -- 1553
				local _obj_0 = req.body -- 1553
				local _type_1 = type(_obj_0) -- 1553
				if "table" == _type_1 or "userdata" == _type_1 then -- 1553
					path = _obj_0.path -- 1553
				end -- 1553
			end -- 1553
			local content -- 1553
			do -- 1553
				local _obj_0 = req.body -- 1553
				local _type_1 = type(_obj_0) -- 1553
				if "table" == _type_1 or "userdata" == _type_1 then -- 1553
					content = _obj_0.content -- 1553
				end -- 1553
			end -- 1553
			local folder -- 1553
			do -- 1553
				local _obj_0 = req.body -- 1553
				local _type_1 = type(_obj_0) -- 1553
				if "table" == _type_1 or "userdata" == _type_1 then -- 1553
					folder = _obj_0.folder -- 1553
				end -- 1553
			end -- 1553
			if path ~= nil and content ~= nil and folder ~= nil then -- 1553
				if Content:exist(path) then -- 1554
					return { -- 1555
						success = false, -- 1555
						message = "TargetExisted" -- 1555
					} -- 1555
				end -- 1554
				local parent = Path:getPath(path) -- 1556
				local files = Content:getFiles(parent) -- 1557
				if folder then -- 1558
					local name = Path:getFilename(path):lower() -- 1559
					for _index_0 = 1, #files do -- 1560
						local file = files[_index_0] -- 1560
						if name == Path:getFilename(file):lower() then -- 1561
							return { -- 1562
								success = false, -- 1562
								message = "TargetExisted" -- 1562
							} -- 1562
						end -- 1561
					end -- 1560
					if Content:mkdir(path) then -- 1563
						return { -- 1564
							success = true -- 1564
						} -- 1564
					end -- 1563
				else -- 1566
					local name = Path:getName(path):lower() -- 1566
					for _index_0 = 1, #files do -- 1567
						local file = files[_index_0] -- 1567
						if name == Path:getName(file):lower() then -- 1568
							local ext = Path:getExt(file) -- 1569
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1570
								goto _continue_0 -- 1571
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1572
								goto _continue_0 -- 1573
							end -- 1570
							return { -- 1574
								success = false, -- 1574
								message = "SourceExisted" -- 1574
							} -- 1574
						end -- 1568
						::_continue_0:: -- 1568
					end -- 1567
					if Content:save(path, content) then -- 1575
						return { -- 1576
							success = true -- 1576
						} -- 1576
					end -- 1575
				end -- 1558
			end -- 1553
		end -- 1553
	end -- 1553
	return { -- 1552
		success = false, -- 1552
		message = "Failed" -- 1552
	} -- 1552
end) -- 1552
HttpServer:post("/delete", function(req) -- 1578
	do -- 1579
		local _type_0 = type(req) -- 1579
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1579
		if _tab_0 then -- 1579
			local path -- 1579
			do -- 1579
				local _obj_0 = req.body -- 1579
				local _type_1 = type(_obj_0) -- 1579
				if "table" == _type_1 or "userdata" == _type_1 then -- 1579
					path = _obj_0.path -- 1579
				end -- 1579
			end -- 1579
			if path ~= nil then -- 1579
				if Content:exist(path) then -- 1580
					local projectRoot -- 1581
					if Content:isdir(path) and isProjectRootDir(path) then -- 1581
						projectRoot = path -- 1581
					else -- 1581
						projectRoot = nil -- 1581
					end -- 1581
					local parent = Path:getPath(path) -- 1582
					local files = Content:getFiles(parent) -- 1583
					local name = Path:getName(path):lower() -- 1584
					local ext = Path:getExt(path) -- 1585
					for _index_0 = 1, #files do -- 1586
						local file = files[_index_0] -- 1586
						if name == Path:getName(file):lower() then -- 1587
							local _exp_0 = Path:getExt(file) -- 1588
							if "tl" == _exp_0 then -- 1588
								if ("vs" == ext) then -- 1588
									Content:remove(Path(parent, file)) -- 1589
								end -- 1588
							elseif "lua" == _exp_0 then -- 1590
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1590
									Content:remove(Path(parent, file)) -- 1591
								end -- 1590
							end -- 1588
						end -- 1587
					end -- 1586
					if Content:remove(path) then -- 1592
						if projectRoot then -- 1593
							AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1594
						end -- 1593
						return { -- 1595
							success = true -- 1595
						} -- 1595
					end -- 1592
				end -- 1580
			end -- 1579
		end -- 1579
	end -- 1579
	return { -- 1578
		success = false -- 1578
	} -- 1578
end) -- 1578
HttpServer:post("/rename", function(req) -- 1597
	do -- 1598
		local _type_0 = type(req) -- 1598
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1598
		if _tab_0 then -- 1598
			local old -- 1598
			do -- 1598
				local _obj_0 = req.body -- 1598
				local _type_1 = type(_obj_0) -- 1598
				if "table" == _type_1 or "userdata" == _type_1 then -- 1598
					old = _obj_0.old -- 1598
				end -- 1598
			end -- 1598
			local new -- 1598
			do -- 1598
				local _obj_0 = req.body -- 1598
				local _type_1 = type(_obj_0) -- 1598
				if "table" == _type_1 or "userdata" == _type_1 then -- 1598
					new = _obj_0.new -- 1598
				end -- 1598
			end -- 1598
			if old ~= nil and new ~= nil then -- 1598
				if Content:exist(old) and not Content:exist(new) then -- 1599
					local renamedDir = Content:isdir(old) -- 1600
					local parent = Path:getPath(new) -- 1601
					local files = Content:getFiles(parent) -- 1602
					if renamedDir then -- 1603
						local name = Path:getFilename(new):lower() -- 1604
						for _index_0 = 1, #files do -- 1605
							local file = files[_index_0] -- 1605
							if name == Path:getFilename(file):lower() then -- 1606
								return { -- 1607
									success = false -- 1607
								} -- 1607
							end -- 1606
						end -- 1605
					else -- 1609
						local name = Path:getName(new):lower() -- 1609
						local ext = Path:getExt(new) -- 1610
						for _index_0 = 1, #files do -- 1611
							local file = files[_index_0] -- 1611
							if name == Path:getName(file):lower() then -- 1612
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1613
									goto _continue_0 -- 1614
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1615
									goto _continue_0 -- 1616
								end -- 1613
								return { -- 1617
									success = false -- 1617
								} -- 1617
							end -- 1612
							::_continue_0:: -- 1612
						end -- 1611
					end -- 1603
					if Content:move(old, new) then -- 1618
						if renamedDir then -- 1619
							AgentSession.renameSessionsByProjectRoot(old, new) -- 1620
						end -- 1619
						local newParent = Path:getPath(new) -- 1621
						parent = Path:getPath(old) -- 1622
						files = Content:getFiles(parent) -- 1623
						local newName = Path:getName(new) -- 1624
						local oldName = Path:getName(old) -- 1625
						local name = oldName:lower() -- 1626
						local ext = Path:getExt(old) -- 1627
						for _index_0 = 1, #files do -- 1628
							local file = files[_index_0] -- 1628
							if name == Path:getName(file):lower() then -- 1629
								local _exp_0 = Path:getExt(file) -- 1630
								if "tl" == _exp_0 then -- 1630
									if ("vs" == ext) then -- 1630
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1631
									end -- 1630
								elseif "lua" == _exp_0 then -- 1632
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1632
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1633
									end -- 1632
								end -- 1630
							end -- 1629
						end -- 1628
						return { -- 1634
							success = true -- 1634
						} -- 1634
					end -- 1618
				end -- 1599
			end -- 1598
		end -- 1598
	end -- 1598
	return { -- 1597
		success = false -- 1597
	} -- 1597
end) -- 1597
HttpServer:post("/exist", function(req) -- 1636
	do -- 1637
		local _type_0 = type(req) -- 1637
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1637
		if _tab_0 then -- 1637
			local file -- 1637
			do -- 1637
				local _obj_0 = req.body -- 1637
				local _type_1 = type(_obj_0) -- 1637
				if "table" == _type_1 or "userdata" == _type_1 then -- 1637
					file = _obj_0.file -- 1637
				end -- 1637
			end -- 1637
			if file ~= nil then -- 1637
				do -- 1638
					local projFile = req.body.projFile -- 1638
					if projFile then -- 1638
						local projDir = getProjectDirFromFile(projFile) -- 1639
						if projDir then -- 1639
							local scriptDir = Path(projDir, "Script") -- 1640
							local searchPaths = Content.searchPaths -- 1641
							if Content:exist(scriptDir) then -- 1642
								Content:addSearchPath(scriptDir) -- 1642
							end -- 1642
							if Content:exist(projDir) then -- 1643
								Content:addSearchPath(projDir) -- 1643
							end -- 1643
							local _ <close> = setmetatable({ }, { -- 1644
								__close = function() -- 1644
									Content.searchPaths = searchPaths -- 1644
								end -- 1644
							}) -- 1644
							return { -- 1645
								success = Content:exist(file) -- 1645
							} -- 1645
						end -- 1639
					end -- 1638
				end -- 1638
				return { -- 1646
					success = Content:exist(file) -- 1646
				} -- 1646
			end -- 1637
		end -- 1637
	end -- 1637
	return { -- 1636
		success = false -- 1636
	} -- 1636
end) -- 1636
HttpServer:postSchedule("/read", function(req) -- 1648
	do -- 1649
		local _type_0 = type(req) -- 1649
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1649
		if _tab_0 then -- 1649
			local path -- 1649
			do -- 1649
				local _obj_0 = req.body -- 1649
				local _type_1 = type(_obj_0) -- 1649
				if "table" == _type_1 or "userdata" == _type_1 then -- 1649
					path = _obj_0.path -- 1649
				end -- 1649
			end -- 1649
			if path ~= nil then -- 1649
				local readFile -- 1650
				readFile = function() -- 1650
					if Content:exist(path) then -- 1651
						local content = Content:loadAsync(path) -- 1652
						if content then -- 1652
							return { -- 1653
								content = content, -- 1653
								success = true, -- 1653
								fullPath = Content:getFullPath(path) -- 1653
							} -- 1653
						end -- 1652
					end -- 1651
					return nil -- 1650
				end -- 1650
				do -- 1654
					local projFile = req.body.projFile -- 1654
					if projFile then -- 1654
						local projDir = getProjectDirFromFile(projFile) -- 1655
						if projDir then -- 1655
							local scriptDir = Path(projDir, "Script") -- 1656
							local searchPaths = Content.searchPaths -- 1657
							if Content:exist(scriptDir) then -- 1658
								Content:addSearchPath(scriptDir) -- 1658
							end -- 1658
							if Content:exist(projDir) then -- 1659
								Content:addSearchPath(projDir) -- 1659
							end -- 1659
							local _ <close> = setmetatable({ }, { -- 1660
								__close = function() -- 1660
									Content.searchPaths = searchPaths -- 1660
								end -- 1660
							}) -- 1660
							local result = readFile() -- 1661
							if result then -- 1661
								return result -- 1661
							end -- 1661
						end -- 1655
					end -- 1654
				end -- 1654
				local result = readFile() -- 1662
				if result then -- 1662
					return result -- 1662
				end -- 1662
			end -- 1649
		end -- 1649
	end -- 1649
	return { -- 1648
		success = false -- 1648
	} -- 1648
end) -- 1648
HttpServer:get("/read-sync", function(req) -- 1664
	do -- 1665
		local _type_0 = type(req) -- 1665
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1665
		if _tab_0 then -- 1665
			local params = req.params -- 1665
			if params ~= nil then -- 1665
				local path = params.path -- 1666
				local exts -- 1667
				if params.exts then -- 1667
					local _accum_0 = { } -- 1668
					local _len_0 = 1 -- 1668
					for ext in params.exts:gmatch("[^|]*") do -- 1668
						_accum_0[_len_0] = ext -- 1669
						_len_0 = _len_0 + 1 -- 1669
					end -- 1668
					exts = _accum_0 -- 1667
				else -- 1670
					exts = { -- 1670
						"" -- 1670
					} -- 1670
				end -- 1667
				local readFile -- 1671
				readFile = function() -- 1671
					for _index_0 = 1, #exts do -- 1672
						local ext = exts[_index_0] -- 1672
						local targetPath = path .. ext -- 1673
						if Content:exist(targetPath) then -- 1674
							local content = Content:load(targetPath) -- 1675
							if content then -- 1675
								return { -- 1676
									content = content, -- 1676
									success = true, -- 1676
									fullPath = Content:getFullPath(targetPath) -- 1676
								} -- 1676
							end -- 1675
						end -- 1674
					end -- 1672
					return nil -- 1671
				end -- 1671
				local searchPaths = Content.searchPaths -- 1677
				local _ <close> = setmetatable({ }, { -- 1678
					__close = function() -- 1678
						Content.searchPaths = searchPaths -- 1678
					end -- 1678
				}) -- 1678
				do -- 1679
					local projFile = req.params.projFile -- 1679
					if projFile then -- 1679
						local projDir = getProjectDirFromFile(projFile) -- 1680
						if projDir then -- 1680
							local scriptDir = Path(projDir, "Script") -- 1681
							if Content:exist(scriptDir) then -- 1682
								Content:addSearchPath(scriptDir) -- 1682
							end -- 1682
							if Content:exist(projDir) then -- 1683
								Content:addSearchPath(projDir) -- 1683
							end -- 1683
						else -- 1685
							projDir = Path:getPath(projFile) -- 1685
							if Content:exist(projDir) then -- 1686
								Content:addSearchPath(projDir) -- 1686
							end -- 1686
						end -- 1680
					end -- 1679
				end -- 1679
				local result = readFile() -- 1687
				if result then -- 1687
					return result -- 1687
				end -- 1687
			end -- 1665
		end -- 1665
	end -- 1665
	return { -- 1664
		success = false -- 1664
	} -- 1664
end) -- 1664
local compileFileAsync -- 1689
compileFileAsync = function(inputFile, sourceCodes) -- 1689
	local file = inputFile -- 1690
	local searchPath -- 1691
	do -- 1691
		local dir = getProjectDirFromFile(inputFile) -- 1691
		if dir then -- 1691
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 1692
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1693
		else -- 1695
			file = Path:getRelative(inputFile, Content.writablePath) -- 1695
			if file:sub(1, 2) == ".." then -- 1696
				file = Path:getRelative(inputFile, Content.assetPath) -- 1697
			end -- 1696
			searchPath = "" -- 1698
		end -- 1691
	end -- 1691
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1699
	local yueext = yue.options.extension -- 1700
	local resultCodes = nil -- 1701
	local resultError = nil -- 1702
	do -- 1703
		local _exp_0 = Path:getExt(inputFile) -- 1703
		if yueext == _exp_0 then -- 1703
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1704
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1705
				if not codes then -- 1706
					resultError = err -- 1707
					return -- 1708
				end -- 1706
				local extraGlobal -- 1709
				if isTIC80 then -- 1709
					extraGlobal = tic80APIs -- 1709
				else -- 1709
					extraGlobal = nil -- 1709
				end -- 1709
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1710
				if not success then -- 1711
					resultError = message -- 1712
					return -- 1713
				end -- 1711
				if codes == "" then -- 1714
					resultCodes = "" -- 1715
					return nil -- 1716
				end -- 1714
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1717
				return resultCodes -- 1718
			end, function(success) -- 1705
				if not success then -- 1719
					Content:remove(outputFile) -- 1720
					if resultCodes == nil then -- 1721
						resultCodes = false -- 1722
					end -- 1721
				end -- 1719
			end) -- 1705
		elseif "tl" == _exp_0 then -- 1723
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1724
			if isTIC80 then -- 1725
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1726
			end -- 1725
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1727
			if codes then -- 1727
				if isTIC80 then -- 1728
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1729
				end -- 1728
				resultCodes = codes -- 1730
				Content:saveAsync(outputFile, codes) -- 1731
			else -- 1733
				Content:remove(outputFile) -- 1733
				resultCodes = false -- 1734
				resultError = err -- 1735
			end -- 1727
		elseif "xml" == _exp_0 then -- 1736
			local codes, err = xml.tolua(sourceCodes) -- 1737
			if codes then -- 1737
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1738
				Content:saveAsync(outputFile, resultCodes) -- 1739
			else -- 1741
				Content:remove(outputFile) -- 1741
				resultCodes = false -- 1742
				resultError = err -- 1743
			end -- 1737
		end -- 1703
	end -- 1703
	wait(function() -- 1744
		return resultCodes ~= nil -- 1744
	end) -- 1744
	if resultCodes then -- 1745
		return resultCodes -- 1746
	else -- 1748
		return nil, resultError -- 1748
	end -- 1745
	return nil -- 1689
end -- 1689
HttpServer:postSchedule("/write", function(req) -- 1750
	do -- 1751
		local _type_0 = type(req) -- 1751
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1751
		if _tab_0 then -- 1751
			local path -- 1751
			do -- 1751
				local _obj_0 = req.body -- 1751
				local _type_1 = type(_obj_0) -- 1751
				if "table" == _type_1 or "userdata" == _type_1 then -- 1751
					path = _obj_0.path -- 1751
				end -- 1751
			end -- 1751
			local content -- 1751
			do -- 1751
				local _obj_0 = req.body -- 1751
				local _type_1 = type(_obj_0) -- 1751
				if "table" == _type_1 or "userdata" == _type_1 then -- 1751
					content = _obj_0.content -- 1751
				end -- 1751
			end -- 1751
			if path ~= nil and content ~= nil then -- 1751
				if Content:saveAsync(path, content) then -- 1752
					do -- 1753
						local _exp_0 = Path:getExt(path) -- 1753
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1753
							if '' == Path:getExt(Path:getName(path)) then -- 1754
								local resultCodes = compileFileAsync(path, content) -- 1755
								return { -- 1756
									success = true, -- 1756
									resultCodes = resultCodes -- 1756
								} -- 1756
							end -- 1754
						end -- 1753
					end -- 1753
					return { -- 1757
						success = true -- 1757
					} -- 1757
				end -- 1752
			end -- 1751
		end -- 1751
	end -- 1751
	return { -- 1750
		success = false -- 1750
	} -- 1750
end) -- 1750
HttpServer:postSchedule("/build", function(req) -- 1759
	do -- 1760
		local _type_0 = type(req) -- 1760
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1760
		if _tab_0 then -- 1760
			local path -- 1760
			do -- 1760
				local _obj_0 = req.body -- 1760
				local _type_1 = type(_obj_0) -- 1760
				if "table" == _type_1 or "userdata" == _type_1 then -- 1760
					path = _obj_0.path -- 1760
				end -- 1760
			end -- 1760
			if path ~= nil then -- 1760
				local _exp_0 = Path:getExt(path) -- 1761
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1761
					if '' == Path:getExt(Path:getName(path)) then -- 1762
						local content = Content:loadAsync(path) -- 1763
						if content then -- 1763
							local resultCodes = compileFileAsync(path, content) -- 1764
							if resultCodes then -- 1764
								return { -- 1765
									success = true, -- 1765
									resultCodes = resultCodes -- 1765
								} -- 1765
							end -- 1764
						end -- 1763
					end -- 1762
				end -- 1761
			end -- 1760
		end -- 1760
	end -- 1760
	return { -- 1759
		success = false -- 1759
	} -- 1759
end) -- 1759
local extentionLevels = { -- 1768
	vs = 2, -- 1768
	bl = 2, -- 1769
	ts = 1, -- 1770
	tsx = 1, -- 1771
	tl = 1, -- 1772
	yue = 1, -- 1773
	xml = 1, -- 1774
	lua = 0 -- 1775
} -- 1767
HttpServer:post("/assets", function() -- 1777
	local Entry = require("Script.Dev.Entry") -- 1780
	local engineDev = Entry.getEngineDev() -- 1781
	local visitAssets -- 1782
	visitAssets = function(path, tag) -- 1782
		local isWorkspace = tag == "Workspace" -- 1783
		local builtin -- 1784
		if tag == "Builtin" then -- 1784
			builtin = true -- 1784
		else -- 1784
			builtin = nil -- 1784
		end -- 1784
		local children = nil -- 1785
		local dirs = Content:getDirs(path) -- 1786
		for _index_0 = 1, #dirs do -- 1787
			local dir = dirs[_index_0] -- 1787
			if isWorkspace then -- 1788
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1789
					goto _continue_0 -- 1790
				end -- 1789
			elseif dir == ".git" then -- 1791
				goto _continue_0 -- 1792
			end -- 1788
			if not children then -- 1793
				children = { } -- 1793
			end -- 1793
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1794
			::_continue_0:: -- 1788
		end -- 1787
		local files = Content:getFiles(path) -- 1795
		local names = { } -- 1796
		for _index_0 = 1, #files do -- 1797
			local file = files[_index_0] -- 1797
			if file:match("^%.") then -- 1798
				goto _continue_1 -- 1798
			end -- 1798
			local name = Path:getName(file) -- 1799
			local ext = names[name] -- 1800
			if ext then -- 1800
				local lv1 -- 1801
				do -- 1801
					local _exp_0 = extentionLevels[ext] -- 1801
					if _exp_0 ~= nil then -- 1801
						lv1 = _exp_0 -- 1801
					else -- 1801
						lv1 = -1 -- 1801
					end -- 1801
				end -- 1801
				ext = Path:getExt(file) -- 1802
				local lv2 -- 1803
				do -- 1803
					local _exp_0 = extentionLevels[ext] -- 1803
					if _exp_0 ~= nil then -- 1803
						lv2 = _exp_0 -- 1803
					else -- 1803
						lv2 = -1 -- 1803
					end -- 1803
				end -- 1803
				if lv2 > lv1 then -- 1804
					names[name] = ext -- 1805
				elseif lv2 == lv1 then -- 1806
					names[name .. '.' .. ext] = "" -- 1807
				end -- 1804
			else -- 1809
				ext = Path:getExt(file) -- 1809
				if not extentionLevels[ext] then -- 1810
					names[file] = "" -- 1811
				else -- 1813
					names[name] = ext -- 1813
				end -- 1810
			end -- 1800
			::_continue_1:: -- 1798
		end -- 1797
		do -- 1814
			local _accum_0 = { } -- 1814
			local _len_0 = 1 -- 1814
			for name, ext in pairs(names) do -- 1814
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1814
				_len_0 = _len_0 + 1 -- 1814
			end -- 1814
			files = _accum_0 -- 1814
		end -- 1814
		for _index_0 = 1, #files do -- 1815
			local file = files[_index_0] -- 1815
			if not children then -- 1816
				children = { } -- 1816
			end -- 1816
			children[#children + 1] = { -- 1818
				key = Path(path, file), -- 1818
				dir = false, -- 1819
				title = file, -- 1820
				builtin = builtin -- 1821
			} -- 1817
		end -- 1815
		if children then -- 1823
			table.sort(children, function(a, b) -- 1824
				if a.dir == b.dir then -- 1825
					return a.title < b.title -- 1826
				else -- 1828
					return a.dir -- 1828
				end -- 1825
			end) -- 1824
		end -- 1823
		if isWorkspace and children then -- 1829
			return children -- 1830
		else -- 1832
			return { -- 1833
				key = path, -- 1833
				dir = true, -- 1834
				title = Path:getFilename(path), -- 1835
				builtin = builtin, -- 1836
				children = children -- 1837
			} -- 1832
		end -- 1829
	end -- 1782
	local zh = (App.locale:match("^zh") ~= nil) -- 1839
	return { -- 1841
		key = Content.writablePath, -- 1841
		dir = true, -- 1842
		root = true, -- 1843
		title = "Assets", -- 1844
		children = (function() -- 1846
			local _tab_0 = { -- 1846
				{ -- 1847
					key = Path(Content.assetPath), -- 1847
					dir = true, -- 1848
					builtin = true, -- 1849
					title = zh and "内置资源" or "Built-in", -- 1850
					children = { -- 1852
						(function() -- 1852
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1852
							_with_0.title = zh and "说明文档" or "Readme" -- 1853
							return _with_0 -- 1852
						end)(), -- 1852
						(function() -- 1854
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1854
							_with_0.title = zh and "接口文档" or "API Doc" -- 1855
							return _with_0 -- 1854
						end)(), -- 1854
						(function() -- 1856
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1856
							_with_0.title = zh and "开发工具" or "Tools" -- 1857
							return _with_0 -- 1856
						end)(), -- 1856
						(function() -- 1858
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1858
							_with_0.title = zh and "字体" or "Font" -- 1859
							return _with_0 -- 1858
						end)(), -- 1858
						(function() -- 1860
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1860
							_with_0.title = zh and "程序库" or "Lib" -- 1861
							if engineDev then -- 1862
								local _list_0 = _with_0.children -- 1863
								for _index_0 = 1, #_list_0 do -- 1863
									local child = _list_0[_index_0] -- 1863
									if not (child.title == "Dora") then -- 1864
										goto _continue_0 -- 1864
									end -- 1864
									local title = zh and "zh-Hans" or "en" -- 1865
									do -- 1866
										local _accum_0 = { } -- 1866
										local _len_0 = 1 -- 1866
										local _list_1 = child.children -- 1866
										for _index_1 = 1, #_list_1 do -- 1866
											local c = _list_1[_index_1] -- 1866
											if c.title ~= title then -- 1866
												_accum_0[_len_0] = c -- 1866
												_len_0 = _len_0 + 1 -- 1866
											end -- 1866
										end -- 1866
										child.children = _accum_0 -- 1866
									end -- 1866
									break -- 1867
									::_continue_0:: -- 1864
								end -- 1863
							else -- 1869
								local _accum_0 = { } -- 1869
								local _len_0 = 1 -- 1869
								local _list_0 = _with_0.children -- 1869
								for _index_0 = 1, #_list_0 do -- 1869
									local child = _list_0[_index_0] -- 1869
									if child.title ~= "Dora" then -- 1869
										_accum_0[_len_0] = child -- 1869
										_len_0 = _len_0 + 1 -- 1869
									end -- 1869
								end -- 1869
								_with_0.children = _accum_0 -- 1869
							end -- 1862
							return _with_0 -- 1860
						end)(), -- 1860
						(function() -- 1870
							if engineDev then -- 1870
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1871
								local _obj_0 = _with_0.children -- 1872
								_obj_0[#_obj_0 + 1] = { -- 1873
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1873
									dir = false, -- 1874
									builtin = true, -- 1875
									title = "init.yue" -- 1876
								} -- 1872
								return _with_0 -- 1871
							end -- 1870
						end)() -- 1870
					} -- 1851
				} -- 1846
			} -- 1880
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1880
			local _idx_0 = #_tab_0 + 1 -- 1880
			for _index_0 = 1, #_obj_0 do -- 1880
				local _value_0 = _obj_0[_index_0] -- 1880
				_tab_0[_idx_0] = _value_0 -- 1880
				_idx_0 = _idx_0 + 1 -- 1880
			end -- 1880
			return _tab_0 -- 1846
		end)() -- 1845
	} -- 1840
end) -- 1777
HttpServer:post("/entry/list", function() -- 1884
	local Entry = require("Script.Dev.Entry") -- 1885
	local res = Entry.getLaunchEntries() -- 1886
	res.success = true -- 1887
	return res -- 1888
end) -- 1884
HttpServer:post("/run/status", function() -- 1890
	local Entry = require("Script.Dev.Entry") -- 1891
	return Entry.getCurrentEntryStatus() -- 1892
end) -- 1890
HttpServer:postSchedule("/run", function(req) -- 1894
	do -- 1895
		local _type_0 = type(req) -- 1895
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1895
		if _tab_0 then -- 1895
			local file -- 1895
			do -- 1895
				local _obj_0 = req.body -- 1895
				local _type_1 = type(_obj_0) -- 1895
				if "table" == _type_1 or "userdata" == _type_1 then -- 1895
					file = _obj_0.file -- 1895
				end -- 1895
			end -- 1895
			local asProj -- 1895
			do -- 1895
				local _obj_0 = req.body -- 1895
				local _type_1 = type(_obj_0) -- 1895
				if "table" == _type_1 or "userdata" == _type_1 then -- 1895
					asProj = _obj_0.asProj -- 1895
				end -- 1895
			end -- 1895
			if file ~= nil and asProj ~= nil then -- 1895
				if not Content:isAbsolutePath(file) then -- 1896
					local devFile = Path(Content.writablePath, file) -- 1897
					if Content:exist(devFile) then -- 1898
						file = devFile -- 1898
					end -- 1898
				end -- 1896
				local Entry = require("Script.Dev.Entry") -- 1899
				local workDir -- 1900
				if asProj then -- 1901
					workDir = getProjectDirFromFile(file) -- 1902
					if workDir then -- 1902
						Entry.allClear() -- 1903
						local target = Path(workDir, "init") -- 1904
						local success, err = Entry.enterEntryAsync({ -- 1905
							entryName = "Project", -- 1905
							fileName = target, -- 1905
							workDir = workDir, -- 1905
							projectRoot = workDir, -- 1905
							runKind = "project" -- 1905
						}) -- 1905
						target = Path:getName(Path:getPath(target)) -- 1906
						return { -- 1907
							success = success, -- 1907
							target = target, -- 1907
							err = err -- 1907
						} -- 1907
					end -- 1902
				else -- 1909
					workDir = getProjectDirFromFile(file) -- 1909
				end -- 1901
				Entry.allClear() -- 1910
				file = Path:replaceExt(file, "") -- 1911
				local entry = { -- 1913
					entryName = Path:getName(file), -- 1913
					fileName = file, -- 1914
					runKind = "file" -- 1915
				} -- 1912
				if workDir then -- 1916
					entry.workDir = workDir -- 1917
					entry.projectRoot = workDir -- 1918
				end -- 1916
				local success, err = Entry.enterEntryAsync(entry) -- 1919
				return { -- 1920
					success = success, -- 1920
					err = err -- 1920
				} -- 1920
			end -- 1895
		end -- 1895
	end -- 1895
	return { -- 1894
		success = false -- 1894
	} -- 1894
end) -- 1894
HttpServer:postSchedule("/stop", function() -- 1922
	local Entry = require("Script.Dev.Entry") -- 1923
	return { -- 1924
		success = Entry.stop() -- 1924
	} -- 1924
end) -- 1922
local minifyAsync -- 1926
minifyAsync = function(sourcePath, minifyPath) -- 1926
	if not Content:exist(sourcePath) then -- 1927
		return -- 1927
	end -- 1927
	local Entry = require("Script.Dev.Entry") -- 1928
	local errors = { } -- 1929
	local files = Entry.getAllFiles(sourcePath, { -- 1930
		"lua" -- 1930
	}, true) -- 1930
	do -- 1931
		local _accum_0 = { } -- 1931
		local _len_0 = 1 -- 1931
		for _index_0 = 1, #files do -- 1931
			local file = files[_index_0] -- 1931
			if file:sub(1, 1) ~= '.' then -- 1931
				_accum_0[_len_0] = file -- 1931
				_len_0 = _len_0 + 1 -- 1931
			end -- 1931
		end -- 1931
		files = _accum_0 -- 1931
	end -- 1931
	local paths -- 1932
	do -- 1932
		local _tbl_0 = { } -- 1932
		for _index_0 = 1, #files do -- 1932
			local file = files[_index_0] -- 1932
			_tbl_0[Path:getPath(file)] = true -- 1932
		end -- 1932
		paths = _tbl_0 -- 1932
	end -- 1932
	for path in pairs(paths) do -- 1933
		Content:mkdir(Path(minifyPath, path)) -- 1933
	end -- 1933
	local _ <close> = setmetatable({ }, { -- 1934
		__close = function() -- 1934
			package.loaded["luaminify.FormatMini"] = nil -- 1935
			package.loaded["luaminify.ParseLua"] = nil -- 1936
			package.loaded["luaminify.Scope"] = nil -- 1937
			package.loaded["luaminify.Util"] = nil -- 1938
		end -- 1934
	}) -- 1934
	local FormatMini -- 1939
	do -- 1939
		local _obj_0 = require("luaminify") -- 1939
		FormatMini = _obj_0.FormatMini -- 1939
	end -- 1939
	local fileCount = #files -- 1940
	local count = 0 -- 1941
	for _index_0 = 1, #files do -- 1942
		local file = files[_index_0] -- 1942
		thread(function() -- 1943
			local _ <close> = setmetatable({ }, { -- 1944
				__close = function() -- 1944
					count = count + 1 -- 1944
				end -- 1944
			}) -- 1944
			local input = Path(sourcePath, file) -- 1945
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1946
			if Content:exist(input) then -- 1947
				local sourceCodes = Content:loadAsync(input) -- 1948
				local res, err = FormatMini(sourceCodes) -- 1949
				if res then -- 1950
					Content:saveAsync(output, res) -- 1951
					return print("Minify " .. tostring(file)) -- 1952
				else -- 1954
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1954
				end -- 1950
			else -- 1956
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1956
			end -- 1947
		end) -- 1943
		sleep() -- 1957
	end -- 1942
	wait(function() -- 1958
		return count == fileCount -- 1958
	end) -- 1958
	if #errors > 0 then -- 1959
		print(table.concat(errors, '\n')) -- 1960
	end -- 1959
	print("Obfuscation done.") -- 1961
	return files -- 1962
end -- 1926
local zipping = false -- 1964
HttpServer:postSchedule("/zip", function(req) -- 1966
	do -- 1967
		local _type_0 = type(req) -- 1967
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1967
		if _tab_0 then -- 1967
			local path -- 1967
			do -- 1967
				local _obj_0 = req.body -- 1967
				local _type_1 = type(_obj_0) -- 1967
				if "table" == _type_1 or "userdata" == _type_1 then -- 1967
					path = _obj_0.path -- 1967
				end -- 1967
			end -- 1967
			local zipFile -- 1967
			do -- 1967
				local _obj_0 = req.body -- 1967
				local _type_1 = type(_obj_0) -- 1967
				if "table" == _type_1 or "userdata" == _type_1 then -- 1967
					zipFile = _obj_0.zipFile -- 1967
				end -- 1967
			end -- 1967
			local obfuscated -- 1967
			do -- 1967
				local _obj_0 = req.body -- 1967
				local _type_1 = type(_obj_0) -- 1967
				if "table" == _type_1 or "userdata" == _type_1 then -- 1967
					obfuscated = _obj_0.obfuscated -- 1967
				end -- 1967
			end -- 1967
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1967
				if zipping then -- 1968
					goto failed -- 1968
				end -- 1968
				zipping = true -- 1969
				local _ <close> = setmetatable({ }, { -- 1970
					__close = function() -- 1970
						zipping = false -- 1970
					end -- 1970
				}) -- 1970
				if not Content:exist(path) then -- 1971
					goto failed -- 1971
				end -- 1971
				Content:mkdir(Path:getPath(zipFile)) -- 1972
				if obfuscated then -- 1973
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1974
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1975
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1976
					Content:remove(scriptPath) -- 1977
					Content:remove(obfuscatedPath) -- 1978
					Content:remove(tempPath) -- 1979
					Content:mkdir(scriptPath) -- 1980
					Content:mkdir(obfuscatedPath) -- 1981
					Content:mkdir(tempPath) -- 1982
					if not Content:copyAsync(path, tempPath) then -- 1983
						goto failed -- 1983
					end -- 1983
					local Entry = require("Script.Dev.Entry") -- 1984
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1985
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1986
						"tl", -- 1986
						"yue", -- 1986
						"lua", -- 1986
						"ts", -- 1986
						"tsx", -- 1986
						"vs", -- 1986
						"bl", -- 1986
						"xml", -- 1986
						"wa", -- 1986
						"mod" -- 1986
					}, true) -- 1986
					for _index_0 = 1, #scriptFiles do -- 1987
						local file = scriptFiles[_index_0] -- 1987
						Content:remove(Path(tempPath, file)) -- 1988
					end -- 1987
					for _index_0 = 1, #luaFiles do -- 1989
						local file = luaFiles[_index_0] -- 1989
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1990
					end -- 1989
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1991
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1992
					end) then -- 1991
						goto failed -- 1991
					end -- 1991
					return { -- 1993
						success = true -- 1993
					} -- 1993
				else -- 1995
					return { -- 1995
						success = Content:zipAsync(path, zipFile, function(file) -- 1995
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1996
						end) -- 1995
					} -- 1995
				end -- 1973
			end -- 1967
		end -- 1967
	end -- 1967
	::failed:: -- 1997
	return { -- 1966
		success = false -- 1966
	} -- 1966
end) -- 1966
HttpServer:postSchedule("/unzip", function(req) -- 1999
	do -- 2000
		local _type_0 = type(req) -- 2000
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2000
		if _tab_0 then -- 2000
			local zipFile -- 2000
			do -- 2000
				local _obj_0 = req.body -- 2000
				local _type_1 = type(_obj_0) -- 2000
				if "table" == _type_1 or "userdata" == _type_1 then -- 2000
					zipFile = _obj_0.zipFile -- 2000
				end -- 2000
			end -- 2000
			local path -- 2000
			do -- 2000
				local _obj_0 = req.body -- 2000
				local _type_1 = type(_obj_0) -- 2000
				if "table" == _type_1 or "userdata" == _type_1 then -- 2000
					path = _obj_0.path -- 2000
				end -- 2000
			end -- 2000
			if zipFile ~= nil and path ~= nil then -- 2000
				return { -- 2001
					success = Content:unzipAsync(zipFile, path, function(file) -- 2001
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2002
					end) -- 2001
				} -- 2001
			end -- 2000
		end -- 2000
	end -- 2000
	return { -- 1999
		success = false -- 1999
	} -- 1999
end) -- 1999
HttpServer:post("/editing-info", function(req) -- 2004
	local Entry = require("Script.Dev.Entry") -- 2005
	local config = Entry.getConfig() -- 2006
	local _type_0 = type(req) -- 2007
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2007
	local _match_0 = false -- 2007
	if _tab_0 then -- 2007
		local editingInfo -- 2007
		do -- 2007
			local _obj_0 = req.body -- 2007
			local _type_1 = type(_obj_0) -- 2007
			if "table" == _type_1 or "userdata" == _type_1 then -- 2007
				editingInfo = _obj_0.editingInfo -- 2007
			end -- 2007
		end -- 2007
		if editingInfo ~= nil then -- 2007
			_match_0 = true -- 2007
			config.editingInfo = editingInfo -- 2008
			return { -- 2009
				success = true -- 2009
			} -- 2009
		end -- 2007
	end -- 2007
	if not _match_0 then -- 2007
		if not (config.editingInfo ~= nil) then -- 2011
			local folder -- 2012
			if App.locale:match('^zh') then -- 2012
				folder = 'zh-Hans' -- 2012
			else -- 2012
				folder = 'en' -- 2012
			end -- 2012
			config.editingInfo = json.encode({ -- 2014
				index = 0, -- 2014
				files = { -- 2016
					{ -- 2017
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2017
						title = "welcome.md" -- 2018
					} -- 2016
				} -- 2015
			}) -- 2013
		end -- 2011
		return { -- 2022
			success = true, -- 2022
			editingInfo = config.editingInfo -- 2022
		} -- 2022
	end -- 2007
end) -- 2004
HttpServer:post("/command", function(req) -- 2024
	do -- 2025
		local _type_0 = type(req) -- 2025
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2025
		if _tab_0 then -- 2025
			local code -- 2025
			do -- 2025
				local _obj_0 = req.body -- 2025
				local _type_1 = type(_obj_0) -- 2025
				if "table" == _type_1 or "userdata" == _type_1 then -- 2025
					code = _obj_0.code -- 2025
				end -- 2025
			end -- 2025
			local log -- 2025
			do -- 2025
				local _obj_0 = req.body -- 2025
				local _type_1 = type(_obj_0) -- 2025
				if "table" == _type_1 or "userdata" == _type_1 then -- 2025
					log = _obj_0.log -- 2025
				end -- 2025
			end -- 2025
			if code ~= nil and log ~= nil then -- 2025
				emit("AppCommand", code, log) -- 2026
				return { -- 2027
					success = true -- 2027
				} -- 2027
			end -- 2025
		end -- 2025
	end -- 2025
	return { -- 2024
		success = false -- 2024
	} -- 2024
end) -- 2024
HttpServer:post("/log/save", function() -- 2029
	local folder = ".download" -- 2030
	local fullLogFile = "dora_full_logs.txt" -- 2031
	local fullFolder = Path(Content.writablePath, folder) -- 2032
	Content:mkdir(fullFolder) -- 2033
	local logPath = Path(fullFolder, fullLogFile) -- 2034
	if App:saveLog(logPath) then -- 2035
		return { -- 2036
			success = true, -- 2036
			path = Path(folder, fullLogFile) -- 2036
		} -- 2036
	end -- 2035
	return { -- 2029
		success = false -- 2029
	} -- 2029
end) -- 2029
HttpServer:post("/yarn/check", function(req) -- 2038
	local yarncompile = require("yarncompile") -- 2039
	do -- 2040
		local _type_0 = type(req) -- 2040
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2040
		if _tab_0 then -- 2040
			local code -- 2040
			do -- 2040
				local _obj_0 = req.body -- 2040
				local _type_1 = type(_obj_0) -- 2040
				if "table" == _type_1 or "userdata" == _type_1 then -- 2040
					code = _obj_0.code -- 2040
				end -- 2040
			end -- 2040
			if code ~= nil then -- 2040
				local jsonObject = json.decode(code) -- 2041
				if jsonObject then -- 2041
					local errors = { } -- 2042
					local _list_0 = jsonObject.nodes -- 2043
					for _index_0 = 1, #_list_0 do -- 2043
						local node = _list_0[_index_0] -- 2043
						local title, body = node.title, node.body -- 2044
						local luaCode, err = yarncompile(body) -- 2045
						if not luaCode then -- 2045
							errors[#errors + 1] = title .. ":" .. err -- 2046
						end -- 2045
					end -- 2043
					return { -- 2047
						success = true, -- 2047
						syntaxError = table.concat(errors, "\n\n") -- 2047
					} -- 2047
				end -- 2041
			end -- 2040
		end -- 2040
	end -- 2040
	return { -- 2038
		success = false -- 2038
	} -- 2038
end) -- 2038
HttpServer:post("/yarn/check-file", function(req) -- 2049
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
				local res, _, err = yarncompile(code, true) -- 2052
				if not res then -- 2052
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2053
					return { -- 2054
						success = false, -- 2054
						message = message, -- 2054
						line = line, -- 2054
						column = column, -- 2054
						node = node -- 2054
					} -- 2054
				end -- 2052
			end -- 2051
		end -- 2051
	end -- 2051
	return { -- 2049
		success = true -- 2049
	} -- 2049
end) -- 2049
local getWaProjectDirFromFile -- 2056
getWaProjectDirFromFile = function(file) -- 2056
	local writablePath = Content.writablePath -- 2057
	local parent, current -- 2058
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 2058
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 2059
	else -- 2061
		parent, current = nil, nil -- 2061
	end -- 2058
	if not current then -- 2062
		return nil -- 2062
	end -- 2062
	repeat -- 2063
		current = Path:getPath(current) -- 2064
		if current == "" then -- 2065
			break -- 2065
		end -- 2065
		local _list_0 = Content:getFiles(Path(parent, current)) -- 2066
		for _index_0 = 1, #_list_0 do -- 2066
			local f = _list_0[_index_0] -- 2066
			if Path:getFilename(f):lower() == "wa.mod" then -- 2067
				return Path(parent, current, Path:getPath(f)) -- 2068
			end -- 2067
		end -- 2066
	until false -- 2063
	return nil -- 2070
end -- 2056
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2072
	do -- 2073
		local _type_0 = type(req) -- 2073
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2073
		if _tab_0 then -- 2073
			local path -- 2073
			do -- 2073
				local _obj_0 = req.body -- 2073
				local _type_1 = type(_obj_0) -- 2073
				if "table" == _type_1 or "userdata" == _type_1 then -- 2073
					path = _obj_0.path -- 2073
				end -- 2073
			end -- 2073
			if path ~= nil then -- 2073
				local projDir = getWaProjectDirFromFile(path) -- 2074
				if projDir then -- 2074
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2075
					if not Content:exist(sourceDoraPath) then -- 2076
						return { -- 2077
							success = false, -- 2077
							message = "missing dora template" -- 2077
						} -- 2077
					end -- 2076
					local targetVendorPath = Path(projDir, "vendor") -- 2078
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2079
					if not Content:exist(targetVendorPath) then -- 2080
						if not Content:mkdir(targetVendorPath) then -- 2081
							return { -- 2082
								success = false, -- 2082
								message = "failed to create vendor folder" -- 2082
							} -- 2082
						end -- 2081
					elseif not Content:isdir(targetVendorPath) then -- 2083
						return { -- 2084
							success = false, -- 2084
							message = "vendor path is not a folder" -- 2084
						} -- 2084
					end -- 2080
					if Content:exist(targetDoraPath) then -- 2085
						if not Content:remove(targetDoraPath) then -- 2086
							return { -- 2087
								success = false, -- 2087
								message = "failed to remove old dora" -- 2087
							} -- 2087
						end -- 2086
					end -- 2085
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2088
						return { -- 2089
							success = false, -- 2089
							message = "failed to copy dora" -- 2089
						} -- 2089
					end -- 2088
					return { -- 2090
						success = true -- 2090
					} -- 2090
				else -- 2092
					return { -- 2092
						success = false, -- 2092
						message = 'Wa file needs a project' -- 2092
					} -- 2092
				end -- 2074
			end -- 2073
		end -- 2073
	end -- 2073
	return { -- 2072
		success = false, -- 2072
		message = "invalid call" -- 2072
	} -- 2072
end) -- 2072
HttpServer:postSchedule("/wa/build", function(req) -- 2094
	do -- 2095
		local _type_0 = type(req) -- 2095
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2095
		if _tab_0 then -- 2095
			local path -- 2095
			do -- 2095
				local _obj_0 = req.body -- 2095
				local _type_1 = type(_obj_0) -- 2095
				if "table" == _type_1 or "userdata" == _type_1 then -- 2095
					path = _obj_0.path -- 2095
				end -- 2095
			end -- 2095
			if path ~= nil then -- 2095
				local projDir = getWaProjectDirFromFile(path) -- 2096
				if projDir then -- 2096
					local message = Wasm:buildWaAsync(projDir) -- 2097
					if message == "" then -- 2098
						return { -- 2099
							success = true -- 2099
						} -- 2099
					else -- 2101
						return { -- 2101
							success = false, -- 2101
							message = message -- 2101
						} -- 2101
					end -- 2098
				else -- 2103
					return { -- 2103
						success = false, -- 2103
						message = 'Wa file needs a project' -- 2103
					} -- 2103
				end -- 2096
			end -- 2095
		end -- 2095
	end -- 2095
	return { -- 2104
		success = false, -- 2104
		message = 'failed to build' -- 2104
	} -- 2104
end) -- 2094
HttpServer:postSchedule("/wa/format", function(req) -- 2106
	do -- 2107
		local _type_0 = type(req) -- 2107
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2107
		if _tab_0 then -- 2107
			local file -- 2107
			do -- 2107
				local _obj_0 = req.body -- 2107
				local _type_1 = type(_obj_0) -- 2107
				if "table" == _type_1 or "userdata" == _type_1 then -- 2107
					file = _obj_0.file -- 2107
				end -- 2107
			end -- 2107
			if file ~= nil then -- 2107
				local code = Wasm:formatWaAsync(file) -- 2108
				if code == "" then -- 2109
					return { -- 2110
						success = false -- 2110
					} -- 2110
				else -- 2112
					return { -- 2112
						success = true, -- 2112
						code = code -- 2112
					} -- 2112
				end -- 2109
			end -- 2107
		end -- 2107
	end -- 2107
	return { -- 2113
		success = false -- 2113
	} -- 2113
end) -- 2106
HttpServer:postSchedule("/wa/create", function(req) -- 2115
	do -- 2116
		local _type_0 = type(req) -- 2116
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2116
		if _tab_0 then -- 2116
			local path -- 2116
			do -- 2116
				local _obj_0 = req.body -- 2116
				local _type_1 = type(_obj_0) -- 2116
				if "table" == _type_1 or "userdata" == _type_1 then -- 2116
					path = _obj_0.path -- 2116
				end -- 2116
			end -- 2116
			if path ~= nil then -- 2116
				if not Content:exist(Path:getPath(path)) then -- 2117
					return { -- 2118
						success = false, -- 2118
						message = "target path not existed" -- 2118
					} -- 2118
				end -- 2117
				if Content:exist(path) then -- 2119
					return { -- 2120
						success = false, -- 2120
						message = "target project folder existed" -- 2120
					} -- 2120
				end -- 2119
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2121
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2122
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2123
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2124
					return { -- 2127
						success = false, -- 2127
						message = "missing template project" -- 2127
					} -- 2127
				end -- 2124
				if not Content:mkdir(path) then -- 2128
					return { -- 2129
						success = false, -- 2129
						message = "failed to create project folder" -- 2129
					} -- 2129
				end -- 2128
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2130
					Content:remove(path) -- 2131
					return { -- 2132
						success = false, -- 2132
						message = "failed to copy template" -- 2132
					} -- 2132
				end -- 2130
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2133
					Content:remove(path) -- 2134
					return { -- 2135
						success = false, -- 2135
						message = "failed to copy template" -- 2135
					} -- 2135
				end -- 2133
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2136
					Content:remove(path) -- 2137
					return { -- 2138
						success = false, -- 2138
						message = "failed to copy template" -- 2138
					} -- 2138
				end -- 2136
				return { -- 2139
					success = true -- 2139
				} -- 2139
			end -- 2116
		end -- 2116
	end -- 2116
	return { -- 2115
		success = false, -- 2115
		message = "invalid call" -- 2115
	} -- 2115
end) -- 2115
local tsBuildGlobs = { -- 2142
	"**/*.ts", -- 2142
	"**/*.tsx", -- 2143
	"!**/.*/**", -- 2144
	"!**/node_modules/**" -- 2145
} -- 2141
local _anon_func_6 = function(path) -- 2154
	local _val_0 = Path:getExt(path) -- 2154
	return "ts" == _val_0 or "tsx" == _val_0 -- 2154
end -- 2154
HttpServer:postSchedule("/ts/build", function(req) -- 2147
	do -- 2148
		local _type_0 = type(req) -- 2148
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2148
		if _tab_0 then -- 2148
			local path -- 2148
			do -- 2148
				local _obj_0 = req.body -- 2148
				local _type_1 = type(_obj_0) -- 2148
				if "table" == _type_1 or "userdata" == _type_1 then -- 2148
					path = _obj_0.path -- 2148
				end -- 2148
			end -- 2148
			if path ~= nil then -- 2148
				if HttpServer.wsConnectionCount == 0 then -- 2149
					return { -- 2150
						success = false, -- 2150
						message = "Web IDE not connected" -- 2150
					} -- 2150
				end -- 2149
				if not Content:exist(path) then -- 2151
					return { -- 2152
						success = false, -- 2152
						message = "path not existed" -- 2152
					} -- 2152
				end -- 2151
				if not Content:isdir(path) then -- 2153
					if not (_anon_func_6(path)) then -- 2154
						return { -- 2155
							success = false, -- 2155
							message = "expecting a TypeScript file" -- 2155
						} -- 2155
					end -- 2154
					local messages = { } -- 2156
					local content = Content:load(path) -- 2157
					if not content then -- 2158
						return { -- 2159
							success = false, -- 2159
							message = "failed to read file" -- 2159
						} -- 2159
					end -- 2158
					emit("AppWS", "Send", json.encode({ -- 2160
						name = "UpdateFile", -- 2160
						file = path, -- 2160
						exists = true, -- 2160
						content = content -- 2160
					})) -- 2160
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2161
						local done = false -- 2162
						do -- 2163
							local _with_0 = Node() -- 2163
							_with_0:gslot("AppWS", function(event) -- 2164
								if event.type == "Receive" then -- 2165
									local res = json.decode(event.msg) -- 2166
									if res then -- 2166
										if res.name == "TranspileTS" and res.file == path then -- 2167
											_with_0:removeFromParent() -- 2168
											if res.success then -- 2169
												local luaFile = Path:replaceExt(path, "lua") -- 2170
												Content:save(luaFile, res.luaCode) -- 2171
												messages[#messages + 1] = { -- 2172
													success = true, -- 2172
													file = path -- 2172
												} -- 2172
											else -- 2174
												messages[#messages + 1] = { -- 2174
													success = false, -- 2174
													file = path, -- 2174
													message = res.message -- 2174
												} -- 2174
											end -- 2169
											done = true -- 2175
										end -- 2167
									end -- 2166
								end -- 2165
							end) -- 2164
						end -- 2163
						emit("AppWS", "Send", json.encode({ -- 2176
							name = "TranspileTS", -- 2176
							file = path, -- 2176
							content = content -- 2176
						})) -- 2176
						wait(function() -- 2177
							return done -- 2177
						end) -- 2177
					end -- 2161
					return { -- 2178
						success = true, -- 2178
						messages = messages -- 2178
					} -- 2178
				else -- 2180
					local fileData = { } -- 2180
					local messages = { } -- 2181
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2182
					for _index_0 = 1, #_list_0 do -- 2182
						local subFile = _list_0[_index_0] -- 2182
						local file = Path(path, subFile) -- 2183
						local content = Content:load(file) -- 2184
						if content then -- 2184
							fileData[file] = content -- 2185
							emit("AppWS", "Send", json.encode({ -- 2186
								name = "UpdateFile", -- 2186
								file = file, -- 2186
								exists = true, -- 2186
								content = content -- 2186
							})) -- 2186
						else -- 2188
							messages[#messages + 1] = { -- 2188
								success = false, -- 2188
								file = file, -- 2188
								message = "failed to read file" -- 2188
							} -- 2188
						end -- 2184
					end -- 2182
					for file, content in pairs(fileData) do -- 2189
						if "d" == Path:getExt(Path:getName(file)) then -- 2190
							goto _continue_0 -- 2190
						end -- 2190
						local done = false -- 2191
						do -- 2192
							local _with_0 = Node() -- 2192
							_with_0:gslot("AppWS", function(event) -- 2193
								if event.type == "Receive" then -- 2194
									local res = json.decode(event.msg) -- 2195
									if res then -- 2195
										if res.name == "TranspileTS" and res.file == file then -- 2196
											_with_0:removeFromParent() -- 2197
											if res.success then -- 2198
												local luaFile = Path:replaceExt(file, "lua") -- 2199
												Content:save(luaFile, res.luaCode) -- 2200
												messages[#messages + 1] = { -- 2201
													success = true, -- 2201
													file = file -- 2201
												} -- 2201
											else -- 2203
												messages[#messages + 1] = { -- 2203
													success = false, -- 2203
													file = file, -- 2203
													message = res.message -- 2203
												} -- 2203
											end -- 2198
											done = true -- 2204
										end -- 2196
									end -- 2195
								end -- 2194
							end) -- 2193
						end -- 2192
						emit("AppWS", "Send", json.encode({ -- 2205
							name = "TranspileTS", -- 2205
							file = file, -- 2205
							content = content -- 2205
						})) -- 2205
						wait(function() -- 2206
							return done -- 2206
						end) -- 2206
						::_continue_0:: -- 2190
					end -- 2189
					return { -- 2207
						success = true, -- 2207
						messages = messages -- 2207
					} -- 2207
				end -- 2153
			end -- 2148
		end -- 2148
	end -- 2148
	return { -- 2147
		success = false -- 2147
	} -- 2147
end) -- 2147
HttpServer:post("/download", function(req) -- 2209
	do -- 2210
		local _type_0 = type(req) -- 2210
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2210
		if _tab_0 then -- 2210
			local url -- 2210
			do -- 2210
				local _obj_0 = req.body -- 2210
				local _type_1 = type(_obj_0) -- 2210
				if "table" == _type_1 or "userdata" == _type_1 then -- 2210
					url = _obj_0.url -- 2210
				end -- 2210
			end -- 2210
			local target -- 2210
			do -- 2210
				local _obj_0 = req.body -- 2210
				local _type_1 = type(_obj_0) -- 2210
				if "table" == _type_1 or "userdata" == _type_1 then -- 2210
					target = _obj_0.target -- 2210
				end -- 2210
			end -- 2210
			if url ~= nil and target ~= nil then -- 2210
				local Entry = require("Script.Dev.Entry") -- 2211
				Entry.downloadFile(url, target) -- 2212
				return { -- 2213
					success = true -- 2213
				} -- 2213
			end -- 2210
		end -- 2210
	end -- 2210
	return { -- 2209
		success = false -- 2209
	} -- 2209
end) -- 2209
local status = { } -- 2215
_module_0 = status -- 2216
status.buildAsync = function(path) -- 2218
	if not Content:exist(path) then -- 2219
		return { -- 2220
			success = false, -- 2220
			file = path, -- 2220
			message = "file not existed" -- 2220
		} -- 2220
	end -- 2219
	do -- 2221
		local _exp_0 = Path:getExt(path) -- 2221
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2221
			if '' == Path:getExt(Path:getName(path)) then -- 2222
				local content = Content:loadAsync(path) -- 2223
				if content then -- 2223
					local resultCodes, err = compileFileAsync(path, content) -- 2224
					if resultCodes then -- 2224
						return { -- 2225
							success = true, -- 2225
							file = path -- 2225
						} -- 2225
					else -- 2227
						return { -- 2227
							success = false, -- 2227
							file = path, -- 2227
							message = err -- 2227
						} -- 2227
					end -- 2224
				end -- 2223
			end -- 2222
		elseif "lua" == _exp_0 then -- 2228
			local content = Content:loadAsync(path) -- 2229
			if content then -- 2229
				do -- 2230
					local isTIC80 = CheckTIC80Code(content) -- 2230
					if isTIC80 then -- 2230
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2231
					end -- 2230
				end -- 2230
				local success, info -- 2232
				do -- 2232
					local _obj_0 = luaCheck(path, content) -- 2232
					success, info = _obj_0.success, _obj_0.info -- 2232
				end -- 2232
				if success then -- 2233
					return { -- 2234
						success = true, -- 2234
						file = path -- 2234
					} -- 2234
				elseif info and #info > 0 then -- 2235
					local messages = { } -- 2236
					for _index_0 = 1, #info do -- 2237
						local _des_0 = info[_index_0] -- 2237
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2237
						local lineText = "" -- 2238
						if line then -- 2239
							local currentLine = 1 -- 2240
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2241
								if currentLine == line then -- 2242
									lineText = text -- 2243
									break -- 2244
								end -- 2242
								currentLine = currentLine + 1 -- 2245
							end -- 2241
						end -- 2239
						if line then -- 2246
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2247
						else -- 2249
							messages[#messages + 1] = message -- 2249
						end -- 2246
					end -- 2237
					return { -- 2250
						success = false, -- 2250
						file = path, -- 2250
						message = table.concat(messages, "\n") -- 2250
					} -- 2250
				else -- 2252
					return { -- 2252
						success = false, -- 2252
						file = path, -- 2252
						message = "lua check failed" -- 2252
					} -- 2252
				end -- 2233
			end -- 2229
		elseif "yarn" == _exp_0 then -- 2253
			local content = Content:loadAsync(path) -- 2254
			if content then -- 2254
				local res, _, err = yarncompile(content, true) -- 2255
				if res then -- 2255
					return { -- 2256
						success = true, -- 2256
						file = path -- 2256
					} -- 2256
				else -- 2258
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2258
					local lineText = "" -- 2259
					if line then -- 2260
						local currentLine = 1 -- 2261
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2262
							if currentLine == line then -- 2263
								lineText = text -- 2264
								break -- 2265
							end -- 2263
							currentLine = currentLine + 1 -- 2266
						end -- 2262
					end -- 2260
					if node ~= "" then -- 2267
						node = "node: " .. tostring(node) .. ", " -- 2268
					else -- 2269
						node = "" -- 2269
					end -- 2267
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2270
					return { -- 2271
						success = false, -- 2271
						file = path, -- 2271
						message = message -- 2271
					} -- 2271
				end -- 2255
			end -- 2254
		end -- 2221
	end -- 2221
	return { -- 2272
		success = false, -- 2272
		file = path, -- 2272
		message = "invalid file to build" -- 2272
	} -- 2272
end -- 2218
thread(function() -- 2274
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 2275
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 2276
	if Content:exist(doraWeb) then -- 2277
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) -- 2278
		local needReload -- 2279
		if Content:exist(doraReady) then -- 2279
			needReload = readyContent ~= Content:load(doraReady) -- 2280
		else -- 2281
			needReload = true -- 2281
		end -- 2279
		if needReload then -- 2282
			Content:remove(Path(Content.appPath, ".www")) -- 2283
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 2284
			Content:save(doraReady, readyContent) -- 2288
			print("Dora Dora is ready!") -- 2289
		end -- 2282
	end -- 2277
	if HttpServer:start(8866) then -- 2290
		local localIP = HttpServer.localIP -- 2291
		if localIP == "" then -- 2292
			localIP = "localhost" -- 2292
		end -- 2292
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 2293
		return HttpServer:startWS(8868) -- 2294
	else -- 2296
		status.url = nil -- 2296
		return print("8866 Port not available!") -- 2297
	end -- 2290
end) -- 2274
return _module_0 -- 1
