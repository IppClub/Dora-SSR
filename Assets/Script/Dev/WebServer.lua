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
local Wasm <const> = Wasm -- 10
local package <const> = package -- 10
local thread <const> = thread -- 10
local print <const> = print -- 10
local sleep <const> = sleep -- 10
local emit <const> = emit -- 10
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
local gitStatusMeansNotRepo -- 468
gitStatusMeansNotRepo = function(statusRes) -- 468
	local message = statusRes and (statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message)) or "" -- 469
	message = tostring(message):lower() -- 470
	return message:find("repository does not exist", 1, true) or message:find("not a git repository", 1, true) -- 471
end -- 468
local gitSummary -- 473
gitSummary = function(repoPath) -- 473
	local statusRes = gitRunSync(repoPath, "status", nil, 120) -- 474
	if not statusRes.success then -- 475
		if gitStatusMeansNotRepo(statusRes) then -- 476
			return { -- 477
				success = true, -- 477
				isRepo = false, -- 477
				message = statusRes.message, -- 477
				status = statusRes.status -- 477
			} -- 477
		end -- 476
		return { -- 478
			success = false, -- 478
			message = statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message) or "failed to check Git repository", -- 478
			status = statusRes.status -- 478
		} -- 478
	end -- 475
	local branchRes = gitRunSync(repoPath, "branch", nil, 120) -- 479
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 120) -- 480
	local status = statusRes.status -- 481
	local branchStatus = branchRes.status -- 482
	local remoteStatus = remoteRes.status -- 483
	local currentBranch = gitCurrentBranch(branchStatus) or gitHeadBranch(repoPath) -- 484
	local branches = gitBranchesWithHead(branchStatus, currentBranch) -- 485
	local logRes = gitRunSync(repoPath, "log -n 100", nil, 120) -- 486
	local logStatus -- 487
	if logRes.success then -- 487
		logStatus = logRes.status -- 488
	else -- 490
		logStatus = { -- 491
			state = "done", -- 491
			kind = "log", -- 492
			repoPath = repoPath, -- 493
			progress = 1, -- 494
			message = "git log completed", -- 495
			data = { -- 496
				commits = { } -- 496
			} -- 496
		} -- 490
	end -- 487
	local hasCommit = logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] ~= nil -- 498
	local tagStatus -- 499
	if hasCommit then -- 499
		tagStatus = (gitRunSync(repoPath, "tag", nil, 120)).status -- 500
	else -- 502
		tagStatus = { -- 503
			state = "done", -- 503
			kind = "tag", -- 504
			repoPath = repoPath, -- 505
			progress = 1, -- 506
			message = "git tag completed", -- 507
			data = { -- 508
				tags = { } -- 508
			} -- 508
		} -- 502
	end -- 499
	local defaultRemote = gitDefaultRemote(remoteStatus) -- 510
	local lastCommit = nil -- 511
	if logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] then -- 512
		lastCommit = logStatus.data.commits[1] -- 513
	end -- 512
	return { -- 515
		success = true, -- 515
		isRepo = true, -- 516
		clean = status.data and status.data.clean or false, -- 517
		currentBranch = currentBranch, -- 518
		defaultRemote = defaultRemote, -- 519
		remotes = remoteStatus and remoteStatus.data and remoteStatus.data.remotes or { }, -- 520
		branches = branches, -- 521
		lastCommit = lastCommit, -- 522
		status = status, -- 523
		branchStatus = branchStatus, -- 524
		remoteStatus = remoteStatus, -- 525
		historyStatus = logStatus, -- 526
		tagStatus = tagStatus -- 527
	} -- 514
end -- 473
HttpServer:post("/git/run", function(req) -- 529
	do -- 530
		local _type_0 = type(req) -- 530
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 530
		if _tab_0 then -- 530
			local body = req.body -- 530
			if body ~= nil then -- 530
				local repoPath, command, authId, optionsJSON = body.repoPath, body.command, body.authId, body.optionsJSON -- 531
				if authId and not optionsJSON then -- 532
					local credential = gitLoadCredential(authId) -- 533
					if credential then -- 533
						optionsJSON = gitAuthOptionsJSON(credential) -- 534
						DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 535
							os.time(), -- 535
							credential.id -- 535
						}) -- 535
					end -- 533
				elseif not optionsJSON then -- 536
					local authOk, authSelection = pcall(gitAuthSelectionForCommand, repoPath, command) -- 537
					if not authOk then -- 538
						authSelection = nil -- 538
					end -- 538
					if authSelection then -- 539
						if #authSelection.items == 1 then -- 540
							local credential = gitLoadCredential(authSelection.items[1].id) -- 541
							optionsJSON = gitAuthOptionsJSON(credential) -- 542
							DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 543
								os.time(), -- 543
								credential.id -- 543
							}) -- 543
						else -- 545
							return { -- 545
								success = false, -- 545
								message = "select a Git credential", -- 545
								needsCredentialSelection = true, -- 545
								host = authSelection.host, -- 545
								credentials = authSelection.items -- 545
							} -- 545
						end -- 540
					end -- 539
				end -- 532
				local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 546
				if not jobId then -- 547
					return { -- 547
						success = false, -- 547
						message = err -- 547
					} -- 547
				end -- 547
				return { -- 548
					success = true, -- 548
					jobId = jobId -- 548
				} -- 548
			end -- 530
		end -- 530
	end -- 530
	return invalidArguments -- 529
end) -- 529
HttpServer:post("/git/status", function(req) -- 550
	do -- 551
		local _type_0 = type(req) -- 551
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 551
		if _tab_0 then -- 551
			local jobId -- 551
			do -- 551
				local _obj_0 = req.body -- 551
				local _type_1 = type(_obj_0) -- 551
				if "table" == _type_1 or "userdata" == _type_1 then -- 551
					jobId = _obj_0.jobId -- 551
				end -- 551
			end -- 551
			if jobId ~= nil then -- 551
				local job = GitJobs[tonumber(jobId) or 0] -- 552
				if not job then -- 553
					return { -- 553
						success = false, -- 553
						message = "git job not found" -- 553
					} -- 553
				end -- 553
				return { -- 554
					success = true, -- 554
					status = job.status, -- 554
					command = job.command -- 554
				} -- 554
			end -- 551
		end -- 551
	end -- 551
	return invalidArguments -- 550
end) -- 550
HttpServer:post("/git/cancel", function(req) -- 556
	do -- 557
		local _type_0 = type(req) -- 557
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 557
		if _tab_0 then -- 557
			local jobId -- 557
			do -- 557
				local _obj_0 = req.body -- 557
				local _type_1 = type(_obj_0) -- 557
				if "table" == _type_1 or "userdata" == _type_1 then -- 557
					jobId = _obj_0.jobId -- 557
				end -- 557
			end -- 557
			if jobId ~= nil then -- 557
				local id = tonumber(jobId) -- 558
				if not id then -- 559
					return { -- 559
						success = false, -- 559
						message = "invalid jobId" -- 559
					} -- 559
				end -- 559
				return { -- 560
					success = Git:cancel(id) -- 560
				} -- 560
			end -- 557
		end -- 557
	end -- 557
	return invalidArguments -- 556
end) -- 556
HttpServer:postSchedule("/git/summary", function(req) -- 562
	do -- 563
		local _type_0 = type(req) -- 563
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 563
		if _tab_0 then -- 563
			local repoPath -- 563
			do -- 563
				local _obj_0 = req.body -- 563
				local _type_1 = type(_obj_0) -- 563
				if "table" == _type_1 or "userdata" == _type_1 then -- 563
					repoPath = _obj_0.repoPath -- 563
				end -- 563
			end -- 563
			if repoPath ~= nil then -- 563
				if gitInvalidRepoPath(repoPath) then -- 564
					return { -- 564
						success = false, -- 564
						message = "invalid repoPath" -- 564
					} -- 564
				end -- 564
				return gitSummary(repoPath) -- 565
			end -- 563
		end -- 563
	end -- 563
	return invalidArguments -- 562
end) -- 562
HttpServer:postSchedule("/git/status-files", function(req) -- 567
	do -- 568
		local _type_0 = type(req) -- 568
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 568
		if _tab_0 then -- 568
			local repoPath -- 568
			do -- 568
				local _obj_0 = req.body -- 568
				local _type_1 = type(_obj_0) -- 568
				if "table" == _type_1 or "userdata" == _type_1 then -- 568
					repoPath = _obj_0.repoPath -- 568
				end -- 568
			end -- 568
			if repoPath ~= nil then -- 568
				return gitRunSync(repoPath, "status", nil, 10) -- 569
			end -- 568
		end -- 568
	end -- 568
	return invalidArguments -- 567
end) -- 567
HttpServer:postSchedule("/git/discard-untracked", function(req) -- 571
	do -- 572
		local _type_0 = type(req) -- 572
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 572
		if _tab_0 then -- 572
			local body = req.body -- 572
			if body ~= nil then -- 572
				local repoPath, paths = body.repoPath, body.paths -- 573
				if gitInvalidRepoPath(repoPath) then -- 574
					return { -- 574
						success = false, -- 574
						message = "invalid repoPath" -- 574
					} -- 574
				end -- 574
				if not (type(paths) == "table") then -- 575
					return { -- 575
						success = false, -- 575
						message = "invalid paths" -- 575
					} -- 575
				end -- 575
				local statusRes = gitRunSync(repoPath, "status", nil, 10) -- 576
				if not statusRes.success then -- 577
					return statusRes -- 577
				end -- 577
				local untracked = { } -- 578
				local _list_0 = (statusRes.status.data and statusRes.status.data.files or { }) -- 579
				for _index_0 = 1, #_list_0 do -- 579
					local file = _list_0[_index_0] -- 579
					if file.staging == "?" or file.worktree == "?" then -- 580
						untracked[file.path] = true -- 581
					end -- 580
				end -- 579
				local removed = { } -- 582
				for _index_0 = 1, #paths do -- 583
					local relPath = paths[_index_0] -- 583
					relPath = tostring(relPath) -- 584
					if not gitPathInsideRepo(repoPath, relPath) then -- 585
						return { -- 585
							success = false, -- 585
							message = "unsafe path: " .. tostring(relPath) -- 585
						} -- 585
					end -- 585
					if not untracked[relPath] then -- 586
						return { -- 586
							success = false, -- 586
							message = "path is not untracked: " .. tostring(relPath) -- 586
						} -- 586
					end -- 586
				end -- 583
				for _index_0 = 1, #paths do -- 587
					local relPath = paths[_index_0] -- 587
					local targetPath = Path(repoPath, tostring(relPath)) -- 588
					if Content:exist(targetPath) then -- 589
						Content:remove(targetPath) -- 590
						removed[#removed + 1] = tostring(relPath) -- 591
					end -- 589
				end -- 587
				return { -- 592
					success = true, -- 592
					removed = removed -- 592
				} -- 592
			end -- 572
		end -- 572
	end -- 572
	return invalidArguments -- 571
end) -- 571
HttpServer:postSchedule("/git/file-diff", function(req) -- 594
	do -- 595
		local _type_0 = type(req) -- 595
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 595
		if _tab_0 then -- 595
			local body = req.body -- 595
			if body ~= nil then -- 595
				local repoPath, path, staged = body.repoPath, body.path, body.staged -- 596
				if gitInvalidRepoPath(repoPath) then -- 597
					return { -- 597
						success = false, -- 597
						message = "invalid repoPath" -- 597
					} -- 597
				end -- 597
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 598
					return { -- 598
						success = false, -- 598
						message = "unsafe path" -- 598
					} -- 598
				end -- 598
				local command -- 599
				if staged == true then -- 599
					command = "diff --staged -- " .. tostring(gitQuote(path)) -- 600
				else -- 602
					command = "diff -- " .. tostring(gitQuote(path)) -- 602
				end -- 599
				local res = gitRunSync(repoPath, command, nil, 10) -- 603
				if not res.success then -- 604
					return res -- 604
				end -- 604
				return { -- 605
					success = true, -- 605
					status = res.status, -- 605
					data = res.status and res.status.data -- 605
				} -- 605
			end -- 595
		end -- 595
	end -- 595
	return invalidArguments -- 594
end) -- 594
HttpServer:postSchedule("/git/commit-file-diff", function(req) -- 607
	do -- 608
		local _type_0 = type(req) -- 608
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 608
		if _tab_0 then -- 608
			local body = req.body -- 608
			if body ~= nil then -- 608
				local repoPath, commit, path = body.repoPath, body.commit, body.path -- 609
				if gitInvalidRepoPath(repoPath) then -- 610
					return { -- 610
						success = false, -- 610
						message = "invalid repoPath" -- 610
					} -- 610
				end -- 610
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 611
					return { -- 611
						success = false, -- 611
						message = "invalid commit" -- 611
					} -- 611
				end -- 611
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 612
					return { -- 612
						success = false, -- 612
						message = "unsafe path" -- 612
					} -- 612
				end -- 612
				local res = gitRunSync(repoPath, "diff " .. tostring(gitQuote(commit)) .. " -- " .. tostring(gitQuote(path)), nil, 10) -- 613
				if not res.success then -- 614
					return res -- 614
				end -- 614
				return { -- 615
					success = true, -- 615
					status = res.status, -- 615
					data = res.status and res.status.data -- 615
				} -- 615
			end -- 608
		end -- 608
	end -- 608
	return invalidArguments -- 607
end) -- 607
HttpServer:postSchedule("/git/history", function(req) -- 617
	do -- 618
		local _type_0 = type(req) -- 618
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 618
		if _tab_0 then -- 618
			local body = req.body -- 618
			if body ~= nil then -- 618
				local repoPath, limit = body.repoPath, body.limit -- 619
				limit = math.max(1, math.min(100, tonumber(limit) or 20)) -- 620
				return gitRunSync(repoPath, "log -n " .. tostring(limit), nil, 10) -- 621
			end -- 618
		end -- 618
	end -- 618
	return invalidArguments -- 617
end) -- 617
HttpServer:postSchedule("/git/remotes", function(req) -- 623
	do -- 624
		local _type_0 = type(req) -- 624
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 624
		if _tab_0 then -- 624
			local body = req.body -- 624
			if body ~= nil then -- 624
				local repoPath, command = body.repoPath, body.command -- 625
				command = command or "remote -v" -- 626
				return gitRunSync(repoPath, command, nil, 10) -- 627
			end -- 624
		end -- 624
	end -- 624
	return invalidArguments -- 623
end) -- 623
HttpServer:postSchedule("/git/branches", function(req) -- 629
	do -- 630
		local _type_0 = type(req) -- 630
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 630
		if _tab_0 then -- 630
			local body = req.body -- 630
			if body ~= nil then -- 630
				local repoPath, command = body.repoPath, body.command -- 631
				command = command or "branch" -- 632
				return gitRunSync(repoPath, command, nil, 10) -- 633
			end -- 630
		end -- 630
	end -- 630
	return invalidArguments -- 629
end) -- 629
HttpServer:postSchedule("/git/tags", function(req) -- 635
	do -- 636
		local _type_0 = type(req) -- 636
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 636
		if _tab_0 then -- 636
			local body = req.body -- 636
			if body ~= nil then -- 636
				local repoPath, command = body.repoPath, body.command -- 637
				command = command or "tag" -- 638
				return gitRunSync(repoPath, command, nil, 10) -- 639
			end -- 636
		end -- 636
	end -- 636
	return invalidArguments -- 635
end) -- 635
HttpServer:post("/git/profile/get", function() -- 641
	ensureGitTables() -- 642
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 643
	local profile -- 644
	if rows and rows[1] then -- 644
		profile = { -- 645
			name = rows[1][1], -- 645
			email = rows[1][2] -- 645
		} -- 645
	else -- 647
		profile = { -- 647
			name = "", -- 647
			email = "" -- 647
		} -- 647
	end -- 644
	return { -- 648
		success = true, -- 648
		profile = profile -- 648
	} -- 648
end) -- 641
HttpServer:post("/git/profile/save", function(req) -- 650
	do -- 651
		local _type_0 = type(req) -- 651
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 651
		if _tab_0 then -- 651
			local name -- 651
			do -- 651
				local _obj_0 = req.body -- 651
				local _type_1 = type(_obj_0) -- 651
				if "table" == _type_1 or "userdata" == _type_1 then -- 651
					name = _obj_0.name -- 651
				end -- 651
			end -- 651
			local email -- 651
			do -- 651
				local _obj_0 = req.body -- 651
				local _type_1 = type(_obj_0) -- 651
				if "table" == _type_1 or "userdata" == _type_1 then -- 651
					email = _obj_0.email -- 651
				end -- 651
			end -- 651
			if name ~= nil and email ~= nil then -- 651
				ensureGitTables() -- 652
				DB:exec("insert into GitProfile(id, name, email, updated_at) values(1, ?, ?, ?) on conflict(id) do update set name = excluded.name, email = excluded.email, updated_at = excluded.updated_at", { -- 654
					tostring(name or ""), -- 654
					tostring(email or ""), -- 655
					os.time() -- 656
				}) -- 653
				return { -- 658
					success = true -- 658
				} -- 658
			end -- 651
		end -- 651
	end -- 651
	return invalidArguments -- 650
end) -- 650
HttpServer:post("/git/auth/list", function(req) -- 660
	ensureGitTables() -- 661
	local host = nil -- 662
	do -- 663
		local _type_0 = type(req) -- 663
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 663
		if _tab_0 then -- 663
			local body = req.body -- 663
			if body ~= nil then -- 663
				host = body.host -- 664
			end -- 663
		end -- 663
	end -- 663
	local rows -- 665
	if host and host ~= "" then -- 665
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by host asc, label asc, id asc", { -- 666
			tostring(host):lower() -- 666
		}) -- 666
	else -- 668
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential order by host asc, label asc, id asc") -- 668
	end -- 665
	local items -- 669
	if rows then -- 669
		local _accum_0 = { } -- 670
		local _len_0 = 1 -- 670
		for _index_0 = 1, #rows do -- 670
			local row = rows[_index_0] -- 670
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 670
			_len_0 = _len_0 + 1 -- 670
		end -- 670
		items = _accum_0 -- 670
	else -- 671
		items = { } -- 671
	end -- 669
	return { -- 672
		success = true, -- 672
		items = items -- 672
	} -- 672
end) -- 660
HttpServer:postSchedule("/git/auth/match", function(req) -- 674
	do -- 675
		local _type_0 = type(req) -- 675
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 675
		local _match_0 = false -- 675
		if _tab_0 then -- 675
			local body = req.body -- 675
			if body ~= nil then -- 675
				_match_0 = true -- 675
				local repoPath, command, url = body.repoPath, body.command, body.url -- 676
				local host -- 677
				if url and url ~= "" then -- 677
					host = gitHostFromURL(url) -- 677
				else -- 677
					host = gitCommandHost(repoPath, command) -- 677
				end -- 677
				if not host then -- 678
					return { -- 678
						success = false, -- 678
						message = "git host is required" -- 678
					} -- 678
				end -- 678
				local items = gitCredentialsForHost(host) -- 679
				return { -- 680
					success = true, -- 680
					host = host, -- 680
					items = items, -- 680
					needsSelection = #items > 1, -- 680
					authId = (#items == 1 and items[1].id or nil) -- 680
				} -- 680
			end -- 675
		end -- 675
		if not _match_0 then -- 675
			return { -- 682
				success = false, -- 682
				message = "invalid arguments" -- 682
			} -- 682
		end -- 675
	end -- 675
	return invalidArguments -- 674
end) -- 674
HttpServer:post("/git/auth/save", function(req) -- 684
	do -- 685
		local _type_0 = type(req) -- 685
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 685
		if _tab_0 then -- 685
			local body = req.body -- 685
			if body ~= nil then -- 685
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token -- 686
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$") -- 687
				label = tostring(label or ""):match("^%s*(.-)%s*$") -- 688
				local credentialType = tostring(body.type or "token") -- 689
				username = tostring(username or "") -- 690
				local secret -- 691
				if credentialType == "basic" then -- 691
					secret = tostring(password or "") -- 691
				else -- 691
					secret = tostring(token or password or "") -- 691
				end -- 691
				if host == "" then -- 692
					return { -- 692
						success = false, -- 692
						message = "host is required" -- 692
					} -- 692
				end -- 692
				if label == "" then -- 693
					return { -- 693
						success = false, -- 693
						message = "label is required" -- 693
					} -- 693
				end -- 693
				if secret == "" then -- 694
					return { -- 694
						success = false, -- 694
						message = "secret is required" -- 694
					} -- 694
				end -- 694
				if not (("basic" == credentialType or "token" == credentialType)) then -- 695
					return { -- 695
						success = false, -- 695
						message = "invalid type" -- 695
					} -- 695
				end -- 695
				ensureGitTables() -- 696
				local now = os.time() -- 697
				if id then -- 698
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", { -- 700
						host, -- 700
						label, -- 700
						credentialType, -- 700
						username, -- 700
						secret, -- 700
						now, -- 700
						(tonumber(id) or 0) -- 700
					}) -- 699
					return { -- 702
						success = true, -- 702
						id = tonumber(id) -- 702
					} -- 702
				else -- 704
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", { -- 705
						host, -- 705
						label, -- 705
						credentialType, -- 705
						username, -- 705
						secret, -- 705
						now, -- 705
						now -- 705
					}) -- 704
					local rows = DB:query("select last_insert_rowid()") -- 707
					return { -- 708
						success = true, -- 708
						id = rows and rows[1] and rows[1][1] -- 708
					} -- 708
				end -- 698
			end -- 685
		end -- 685
	end -- 685
	return invalidArguments -- 684
end) -- 684
HttpServer:post("/git/auth/delete", function(req) -- 710
	do -- 711
		local _type_0 = type(req) -- 711
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 711
		if _tab_0 then -- 711
			local id -- 711
			do -- 711
				local _obj_0 = req.body -- 711
				local _type_1 = type(_obj_0) -- 711
				if "table" == _type_1 or "userdata" == _type_1 then -- 711
					id = _obj_0.id -- 711
				end -- 711
			end -- 711
			if id ~= nil then -- 711
				ensureGitTables() -- 712
				local credentialId = tonumber(id) or 0 -- 713
				DB:exec("delete from GitCredential where id = ?", { -- 714
					credentialId -- 714
				}) -- 714
				return { -- 715
					success = true -- 715
				} -- 715
			end -- 711
		end -- 711
	end -- 711
	return invalidArguments -- 710
end) -- 710
HttpServer:postSchedule("/git/auth/test", function(req) -- 717
	do -- 718
		local _type_0 = type(req) -- 718
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 718
		if _tab_0 then -- 718
			local body = req.body -- 718
			if body ~= nil then -- 718
				local repoPath, url, authId = body.repoPath, body.url, body.authId -- 719
				local credential = gitLoadCredential(authId) -- 720
				local optionsJSON = gitAuthOptionsJSON(credential) -- 721
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20) -- 722
			end -- 718
		end -- 718
	end -- 718
	return invalidArguments -- 717
end) -- 717
HttpServer:post("/agent/session/create", function(req) -- 724
	do -- 725
		local _type_0 = type(req) -- 725
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 725
		if _tab_0 then -- 725
			local projectRoot -- 725
			do -- 725
				local _obj_0 = req.body -- 725
				local _type_1 = type(_obj_0) -- 725
				if "table" == _type_1 or "userdata" == _type_1 then -- 725
					projectRoot = _obj_0.projectRoot -- 725
				end -- 725
			end -- 725
			local title -- 725
			do -- 725
				local _obj_0 = req.body -- 725
				local _type_1 = type(_obj_0) -- 725
				if "table" == _type_1 or "userdata" == _type_1 then -- 725
					title = _obj_0.title -- 725
				end -- 725
			end -- 725
			if projectRoot ~= nil and title ~= nil then -- 725
				return AgentSession.createSession(projectRoot, title) -- 726
			end -- 725
		end -- 725
	end -- 725
	return invalidArguments -- 724
end) -- 724
HttpServer:post("/agent/session/create-sub", function(req) -- 728
	do -- 729
		local _type_0 = type(req) -- 729
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 729
		if _tab_0 then -- 729
			local parentSessionId -- 729
			do -- 729
				local _obj_0 = req.body -- 729
				local _type_1 = type(_obj_0) -- 729
				if "table" == _type_1 or "userdata" == _type_1 then -- 729
					parentSessionId = _obj_0.parentSessionId -- 729
				end -- 729
			end -- 729
			local title -- 729
			do -- 729
				local _obj_0 = req.body -- 729
				local _type_1 = type(_obj_0) -- 729
				if "table" == _type_1 or "userdata" == _type_1 then -- 729
					title = _obj_0.title -- 729
				end -- 729
			end -- 729
			if parentSessionId ~= nil and title ~= nil then -- 729
				return AgentSession.createSubSession(parentSessionId, title) -- 730
			end -- 729
		end -- 729
	end -- 729
	return invalidArguments -- 728
end) -- 728
HttpServer:post("/agent/session/get", function(req) -- 732
	do -- 733
		local _type_0 = type(req) -- 733
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 733
		if _tab_0 then -- 733
			local sessionId -- 733
			do -- 733
				local _obj_0 = req.body -- 733
				local _type_1 = type(_obj_0) -- 733
				if "table" == _type_1 or "userdata" == _type_1 then -- 733
					sessionId = _obj_0.sessionId -- 733
				end -- 733
			end -- 733
			if sessionId ~= nil then -- 733
				return AgentSession.getSession(sessionId) -- 734
			end -- 733
		end -- 733
	end -- 733
	return invalidArguments -- 732
end) -- 732
HttpServer:post("/agent/session/send", function(req) -- 736
	do -- 737
		local _type_0 = type(req) -- 737
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 737
		if _tab_0 then -- 737
			local sessionId -- 737
			do -- 737
				local _obj_0 = req.body -- 737
				local _type_1 = type(_obj_0) -- 737
				if "table" == _type_1 or "userdata" == _type_1 then -- 737
					sessionId = _obj_0.sessionId -- 737
				end -- 737
			end -- 737
			local prompt -- 737
			do -- 737
				local _obj_0 = req.body -- 737
				local _type_1 = type(_obj_0) -- 737
				if "table" == _type_1 or "userdata" == _type_1 then -- 737
					prompt = _obj_0.prompt -- 737
				end -- 737
			end -- 737
			if sessionId ~= nil and prompt ~= nil then -- 737
				return AgentSession.sendPrompt(sessionId, prompt, false, req.body.disabledAgentTools) -- 738
			end -- 737
		end -- 737
	end -- 737
	return invalidArguments -- 736
end) -- 736
HttpServer:post("/agent/session/resend", function(req) -- 740
	do -- 741
		local _type_0 = type(req) -- 741
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 741
		if _tab_0 then -- 741
			local sessionId -- 741
			do -- 741
				local _obj_0 = req.body -- 741
				local _type_1 = type(_obj_0) -- 741
				if "table" == _type_1 or "userdata" == _type_1 then -- 741
					sessionId = _obj_0.sessionId -- 741
				end -- 741
			end -- 741
			local messageId -- 741
			do -- 741
				local _obj_0 = req.body -- 741
				local _type_1 = type(_obj_0) -- 741
				if "table" == _type_1 or "userdata" == _type_1 then -- 741
					messageId = _obj_0.messageId -- 741
				end -- 741
			end -- 741
			local prompt -- 741
			do -- 741
				local _obj_0 = req.body -- 741
				local _type_1 = type(_obj_0) -- 741
				if "table" == _type_1 or "userdata" == _type_1 then -- 741
					prompt = _obj_0.prompt -- 741
				end -- 741
			end -- 741
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 741
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools) -- 742
			end -- 741
		end -- 741
	end -- 741
	return invalidArguments -- 740
end) -- 740
HttpServer:post("/agent/task/status", function(req) -- 744
	do -- 745
		local _type_0 = type(req) -- 745
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 745
		if _tab_0 then -- 745
			local sessionId -- 745
			do -- 745
				local _obj_0 = req.body -- 745
				local _type_1 = type(_obj_0) -- 745
				if "table" == _type_1 or "userdata" == _type_1 then -- 745
					sessionId = _obj_0.sessionId -- 745
				end -- 745
			end -- 745
			if sessionId ~= nil then -- 745
				local res = AgentSession.getSession(sessionId) -- 746
				if not res.success then -- 747
					return res -- 747
				end -- 747
				local taskId = res.session.currentTaskId -- 748
				local checkpoints -- 749
				if taskId then -- 749
					checkpoints = AgentTools.listCheckpoints(taskId) -- 749
				else -- 749
					checkpoints = { } -- 749
				end -- 749
				return { -- 751
					success = true, -- 751
					session = res.session, -- 752
					relatedSessions = res.relatedSessions, -- 753
					spawnInfo = res.spawnInfo, -- 754
					messages = res.messages, -- 755
					steps = res.steps, -- 756
					checkpoints = checkpoints -- 757
				} -- 750
			end -- 745
		end -- 745
	end -- 745
	return invalidArguments -- 744
end) -- 744
HttpServer:post("/agent/task/running", function() -- 759
	local res = AgentSession.listRunningSessions() -- 760
	if res.success and #res.sessions == 0 then -- 761
		res.sessions = nil -- 762
	end -- 761
	return res -- 763
end) -- 759
HttpServer:post("/agent/task/stop", function(req) -- 765
	do -- 766
		local _type_0 = type(req) -- 766
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 766
		if _tab_0 then -- 766
			local sessionId -- 766
			do -- 766
				local _obj_0 = req.body -- 766
				local _type_1 = type(_obj_0) -- 766
				if "table" == _type_1 or "userdata" == _type_1 then -- 766
					sessionId = _obj_0.sessionId -- 766
				end -- 766
			end -- 766
			if sessionId ~= nil then -- 766
				return AgentSession.stopSessionTask(sessionId) -- 767
			end -- 766
		end -- 766
	end -- 766
	return invalidArguments -- 765
end) -- 765
HttpServer:post("/agent/checkpoint/list", function(req) -- 769
	do -- 770
		local _type_0 = type(req) -- 770
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 770
		if _tab_0 then -- 770
			local taskId -- 770
			do -- 770
				local _obj_0 = req.body -- 770
				local _type_1 = type(_obj_0) -- 770
				if "table" == _type_1 or "userdata" == _type_1 then -- 770
					taskId = _obj_0.taskId -- 770
				end -- 770
			end -- 770
			local sessionId -- 770
			do -- 770
				local _obj_0 = req.body -- 770
				local _type_1 = type(_obj_0) -- 770
				if "table" == _type_1 or "userdata" == _type_1 then -- 770
					sessionId = _obj_0.sessionId -- 770
				end -- 770
			end -- 770
			if sessionId ~= nil then -- 770
				if not taskId and sessionId then -- 771
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 772
				end -- 771
				if not taskId then -- 773
					return { -- 773
						success = false, -- 773
						message = "task not found" -- 773
					} -- 773
				end -- 773
				return { -- 775
					success = true, -- 775
					taskId = taskId, -- 776
					checkpoints = AgentTools.listCheckpoints(taskId) -- 777
				} -- 774
			end -- 770
		end -- 770
	end -- 770
	return invalidArguments -- 769
end) -- 769
HttpServer:post("/agent/checkpoint/diff", function(req) -- 779
	do -- 780
		local _type_0 = type(req) -- 780
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 780
		if _tab_0 then -- 780
			local checkpointId -- 780
			do -- 780
				local _obj_0 = req.body -- 780
				local _type_1 = type(_obj_0) -- 780
				if "table" == _type_1 or "userdata" == _type_1 then -- 780
					checkpointId = _obj_0.checkpointId -- 780
				end -- 780
			end -- 780
			if checkpointId ~= nil then -- 780
				if not (checkpointId > 0) then -- 781
					return { -- 781
						success = false, -- 781
						message = "invalid checkpointId" -- 781
					} -- 781
				end -- 781
				return AgentTools.getCheckpointDiff(checkpointId) -- 782
			end -- 780
		end -- 780
	end -- 780
	return invalidArguments -- 779
end) -- 779
HttpServer:post("/agent/task/diff", function(req) -- 784
	do -- 785
		local _type_0 = type(req) -- 785
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 785
		if _tab_0 then -- 785
			local taskId -- 785
			do -- 785
				local _obj_0 = req.body -- 785
				local _type_1 = type(_obj_0) -- 785
				if "table" == _type_1 or "userdata" == _type_1 then -- 785
					taskId = _obj_0.taskId -- 785
				end -- 785
			end -- 785
			if taskId ~= nil then -- 785
				if not (taskId > 0) then -- 786
					return { -- 786
						success = false, -- 786
						message = "invalid taskId" -- 786
					} -- 786
				end -- 786
				return AgentTools.getTaskChangeSetDiff(taskId) -- 787
			end -- 785
		end -- 785
	end -- 785
	return invalidArguments -- 784
end) -- 784
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 789
	do -- 790
		local _type_0 = type(req) -- 790
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 790
		if _tab_0 then -- 790
			local sessionId -- 790
			do -- 790
				local _obj_0 = req.body -- 790
				local _type_1 = type(_obj_0) -- 790
				if "table" == _type_1 or "userdata" == _type_1 then -- 790
					sessionId = _obj_0.sessionId -- 790
				end -- 790
			end -- 790
			local checkpointId -- 790
			do -- 790
				local _obj_0 = req.body -- 790
				local _type_1 = type(_obj_0) -- 790
				if "table" == _type_1 or "userdata" == _type_1 then -- 790
					checkpointId = _obj_0.checkpointId -- 790
				end -- 790
			end -- 790
			if sessionId ~= nil and checkpointId ~= nil then -- 790
				if not (checkpointId > 0) then -- 791
					return { -- 791
						success = false, -- 791
						message = "invalid checkpointId" -- 791
					} -- 791
				end -- 791
				local res = AgentSession.getSession(sessionId) -- 792
				if not res.success then -- 793
					return res -- 793
				end -- 793
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, res.session.projectRoot) -- 794
				if not rollbackRes.success then -- 795
					return rollbackRes -- 795
				end -- 795
				return { -- 797
					success = true, -- 797
					checkpointId = rollbackRes.checkpointId -- 798
				} -- 796
			end -- 790
		end -- 790
	end -- 790
	return invalidArguments -- 789
end) -- 789
HttpServer:post("/agent/task/rollback", function(req) -- 800
	do -- 801
		local _type_0 = type(req) -- 801
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 801
		if _tab_0 then -- 801
			local sessionId -- 801
			do -- 801
				local _obj_0 = req.body -- 801
				local _type_1 = type(_obj_0) -- 801
				if "table" == _type_1 or "userdata" == _type_1 then -- 801
					sessionId = _obj_0.sessionId -- 801
				end -- 801
			end -- 801
			local taskId -- 801
			do -- 801
				local _obj_0 = req.body -- 801
				local _type_1 = type(_obj_0) -- 801
				if "table" == _type_1 or "userdata" == _type_1 then -- 801
					taskId = _obj_0.taskId -- 801
				end -- 801
			end -- 801
			if sessionId ~= nil and taskId ~= nil then -- 801
				if not (taskId > 0) then -- 802
					return { -- 802
						success = false, -- 802
						message = "invalid taskId" -- 802
					} -- 802
				end -- 802
				local res = AgentSession.getSession(sessionId) -- 803
				if not res.success then -- 804
					return res -- 804
				end -- 804
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, res.session.projectRoot) -- 805
				if not rollbackRes.success then -- 806
					return rollbackRes -- 806
				end -- 806
				return { -- 808
					success = true, -- 808
					taskId = rollbackRes.taskId, -- 809
					checkpointId = rollbackRes.checkpointId, -- 810
					checkpointCount = rollbackRes.checkpointCount -- 811
				} -- 807
			end -- 801
		end -- 801
	end -- 801
	return invalidArguments -- 800
end) -- 800
local getSearchPath -- 813
getSearchPath = function(file) -- 813
	do -- 814
		local dir = getProjectDirFromFile(file) -- 814
		if dir then -- 814
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 815
		end -- 814
	end -- 814
	return "" -- 813
end -- 813
local getSearchFolders -- 817
getSearchFolders = function(file) -- 817
	do -- 818
		local dir = getProjectDirFromFile(file) -- 818
		if dir then -- 818
			return { -- 820
				Path(dir, "Script"), -- 820
				dir -- 821
			} -- 819
		end -- 818
	end -- 818
	return { } -- 817
end -- 817
local disabledCheckForLua = { -- 824
	"incompatible number of returns", -- 824
	"unknown", -- 825
	"cannot index", -- 826
	"module not found", -- 827
	"don't know how to resolve", -- 828
	"ContainerItem", -- 829
	"cannot resolve a type", -- 830
	"invalid key", -- 831
	"inconsistent index type", -- 832
	"cannot use operator", -- 833
	"attempting ipairs loop", -- 834
	"expects record or nominal", -- 835
	"variable is not being assigned", -- 836
	"<invalid type>", -- 837
	"<any type>", -- 838
	"using the '#' operator", -- 839
	"can't match a record", -- 840
	"redeclaration of variable", -- 841
	"cannot apply pairs", -- 842
	"not a function", -- 843
	"to%-be%-closed" -- 844
} -- 823
local yueCheck -- 846
yueCheck = function(file, content, lax) -- 846
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 847
	if isTIC80 then -- 848
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 849
	end -- 848
	local searchPath = getSearchPath(file) -- 850
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 851
	local info = { } -- 852
	local globals = { } -- 853
	for _index_0 = 1, #checkResult do -- 854
		local _des_0 = checkResult[_index_0] -- 854
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 854
		if "error" == t then -- 855
			info[#info + 1] = { -- 856
				"syntax", -- 856
				file, -- 856
				line, -- 856
				col, -- 856
				msg -- 856
			} -- 856
		elseif "global" == t then -- 857
			globals[#globals + 1] = { -- 858
				msg, -- 858
				line, -- 858
				col -- 858
			} -- 858
		end -- 855
	end -- 854
	if luaCodes then -- 859
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 860
		if success then -- 861
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 862
			if not (lintResult == "") then -- 863
				lintResult = lintResult .. "\n" -- 863
			end -- 863
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 864
		else -- 865
			for _index_0 = 1, #lintResult do -- 865
				local _des_0 = lintResult[_index_0] -- 865
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 865
				if isTIC80 and tic80APIs[name] then -- 866
					goto _continue_0 -- 866
				end -- 866
				info[#info + 1] = { -- 867
					"syntax", -- 867
					file, -- 867
					line, -- 867
					col, -- 867
					"invalid global variable" -- 867
				} -- 867
				::_continue_0:: -- 866
			end -- 865
		end -- 861
	end -- 859
	return luaCodes, info -- 868
end -- 846
local luaCheck -- 870
luaCheck = function(file, content) -- 870
	local res, err = load(content, "check") -- 871
	if not res then -- 872
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 873
		return { -- 874
			success = false, -- 874
			info = { -- 874
				{ -- 874
					"syntax", -- 874
					file, -- 874
					tonumber(line), -- 874
					0, -- 874
					msg -- 874
				} -- 874
			} -- 874
		} -- 874
	end -- 872
	local success, info = teal.checkAsync(content, file, true, "") -- 875
	if info then -- 876
		do -- 877
			local _accum_0 = { } -- 877
			local _len_0 = 1 -- 877
			for _index_0 = 1, #info do -- 877
				local item = info[_index_0] -- 877
				local useCheck = true -- 878
				if not item[5]:match("unused") then -- 879
					for _index_1 = 1, #disabledCheckForLua do -- 880
						local check = disabledCheckForLua[_index_1] -- 880
						if item[5]:match(check) then -- 881
							useCheck = false -- 882
						end -- 881
					end -- 880
				end -- 879
				if not useCheck then -- 883
					goto _continue_0 -- 883
				end -- 883
				do -- 884
					local _exp_0 = item[1] -- 884
					if "type" == _exp_0 then -- 885
						item[1] = "warning" -- 886
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 887
						goto _continue_0 -- 888
					end -- 884
				end -- 884
				_accum_0[_len_0] = item -- 889
				_len_0 = _len_0 + 1 -- 878
				::_continue_0:: -- 878
			end -- 877
			info = _accum_0 -- 877
		end -- 877
		if #info == 0 then -- 890
			info = nil -- 891
			success = true -- 892
		end -- 890
	end -- 876
	return { -- 893
		success = success, -- 893
		info = info -- 893
	} -- 893
end -- 870
local luaCheckWithLineInfo -- 895
luaCheckWithLineInfo = function(file, luaCodes) -- 895
	local res = luaCheck(file, luaCodes) -- 896
	local info = { } -- 897
	if not res.success then -- 898
		local current = 1 -- 899
		local lastLine = 1 -- 900
		local lineMap = { } -- 901
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 902
			local num = lineCode:match("--%s*(%d+)%s*$") -- 903
			if num then -- 904
				lastLine = tonumber(num) -- 905
			end -- 904
			lineMap[current] = lastLine -- 906
			current = current + 1 -- 907
		end -- 902
		local _list_0 = res.info -- 908
		for _index_0 = 1, #_list_0 do -- 908
			local item = _list_0[_index_0] -- 908
			item[3] = lineMap[item[3]] or 0 -- 909
			item[4] = 0 -- 910
			info[#info + 1] = item -- 911
		end -- 908
		return false, info -- 912
	end -- 898
	return true, info -- 913
end -- 895
local getCompiledYueLine -- 915
getCompiledYueLine = function(content, line, row, file, lax) -- 915
	local luaCodes = yueCheck(file, content, lax) -- 916
	if not luaCodes then -- 917
		return nil -- 917
	end -- 917
	local current = 1 -- 918
	local lastLine = 1 -- 919
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 920
	local targetRow = nil -- 921
	local lineMap = { } -- 922
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 923
		local num = lineCode:match("--%s*(%d+)%s*$") -- 924
		if num then -- 925
			lastLine = tonumber(num) -- 925
		end -- 925
		lineMap[current] = lastLine -- 926
		if row <= lastLine and not targetRow then -- 927
			targetRow = current -- 928
			break -- 929
		end -- 927
		current = current + 1 -- 930
	end -- 923
	targetRow = current -- 931
	if targetLine and targetRow then -- 932
		return luaCodes, targetLine, targetRow, lineMap -- 933
	else -- 935
		return nil -- 935
	end -- 932
end -- 915
HttpServer:postSchedule("/check", function(req) -- 937
	do -- 938
		local _type_0 = type(req) -- 938
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 938
		if _tab_0 then -- 938
			local file -- 938
			do -- 938
				local _obj_0 = req.body -- 938
				local _type_1 = type(_obj_0) -- 938
				if "table" == _type_1 or "userdata" == _type_1 then -- 938
					file = _obj_0.file -- 938
				end -- 938
			end -- 938
			local content -- 938
			do -- 938
				local _obj_0 = req.body -- 938
				local _type_1 = type(_obj_0) -- 938
				if "table" == _type_1 or "userdata" == _type_1 then -- 938
					content = _obj_0.content -- 938
				end -- 938
			end -- 938
			if file ~= nil and content ~= nil then -- 938
				local ext = Path:getExt(file) -- 939
				if "tl" == ext then -- 940
					local searchPath = getSearchPath(file) -- 941
					do -- 942
						local isTIC80 = CheckTIC80Code(content) -- 942
						if isTIC80 then -- 942
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 943
						end -- 942
					end -- 942
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 944
					return { -- 945
						success = success, -- 945
						info = info -- 945
					} -- 945
				elseif "lua" == ext then -- 946
					do -- 947
						local isTIC80 = CheckTIC80Code(content) -- 947
						if isTIC80 then -- 947
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 948
						end -- 947
					end -- 947
					return luaCheck(file, content) -- 949
				elseif "yue" == ext then -- 950
					local luaCodes, info = yueCheck(file, content, false) -- 951
					local success = false -- 952
					if luaCodes then -- 953
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 954
						do -- 955
							local _tab_1 = { } -- 955
							local _idx_0 = #_tab_1 + 1 -- 955
							for _index_0 = 1, #info do -- 955
								local _value_0 = info[_index_0] -- 955
								_tab_1[_idx_0] = _value_0 -- 955
								_idx_0 = _idx_0 + 1 -- 955
							end -- 955
							local _idx_1 = #_tab_1 + 1 -- 955
							for _index_0 = 1, #luaInfo do -- 955
								local _value_0 = luaInfo[_index_0] -- 955
								_tab_1[_idx_1] = _value_0 -- 955
								_idx_1 = _idx_1 + 1 -- 955
							end -- 955
							info = _tab_1 -- 955
						end -- 955
						success = success and luaSuccess -- 956
					end -- 953
					if #info > 0 then -- 957
						return { -- 958
							success = success, -- 958
							info = info -- 958
						} -- 958
					else -- 960
						return { -- 960
							success = success -- 960
						} -- 960
					end -- 957
				elseif "xml" == ext then -- 961
					local success, result = xml.check(content) -- 962
					if success then -- 963
						local info -- 964
						success, info = luaCheckWithLineInfo(file, result) -- 964
						if #info > 0 then -- 965
							return { -- 966
								success = success, -- 966
								info = info -- 966
							} -- 966
						else -- 968
							return { -- 968
								success = success -- 968
							} -- 968
						end -- 965
					else -- 970
						local info -- 970
						do -- 970
							local _accum_0 = { } -- 970
							local _len_0 = 1 -- 970
							for _index_0 = 1, #result do -- 970
								local _des_0 = result[_index_0] -- 970
								local row, err = _des_0[1], _des_0[2] -- 970
								_accum_0[_len_0] = { -- 971
									"syntax", -- 971
									file, -- 971
									row, -- 971
									0, -- 971
									err -- 971
								} -- 971
								_len_0 = _len_0 + 1 -- 971
							end -- 970
							info = _accum_0 -- 970
						end -- 970
						return { -- 972
							success = false, -- 972
							info = info -- 972
						} -- 972
					end -- 963
				end -- 940
			end -- 938
		end -- 938
	end -- 938
	return { -- 937
		success = true -- 937
	} -- 937
end) -- 937
HttpServer:post("/body/parse", function(req) -- 974
	do -- 975
		local _type_0 = type(req) -- 975
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 975
		if _tab_0 then -- 975
			local file -- 975
			do -- 975
				local _obj_0 = req.body -- 975
				local _type_1 = type(_obj_0) -- 975
				if "table" == _type_1 or "userdata" == _type_1 then -- 975
					file = _obj_0.file -- 975
				end -- 975
			end -- 975
			local content -- 975
			do -- 975
				local _obj_0 = req.body -- 975
				local _type_1 = type(_obj_0) -- 975
				if "table" == _type_1 or "userdata" == _type_1 then -- 975
					content = _obj_0.content -- 975
				end -- 975
			end -- 975
			if file ~= nil and content ~= nil then -- 975
				if not (file:sub(-6) == ".b.lua") then -- 976
					return { -- 977
						success = false, -- 977
						phase = "request", -- 977
						message = "only .b.lua files can be converted" -- 977
					} -- 977
				end -- 976
				local loader, err = load("_ENV = {}\n" .. content) -- 978
				if not loader then -- 979
					return { -- 980
						success = false, -- 980
						phase = "parse", -- 980
						message = tostring(err) -- 980
					} -- 980
				end -- 979
				local ok, data = pcall(loader) -- 981
				if not ok then -- 982
					return { -- 983
						success = false, -- 983
						phase = "execute", -- 983
						message = tostring(data) -- 983
					} -- 983
				end -- 982
				if not ("table" == type(data) and data[1] == "Array") then -- 984
					return { -- 985
						success = false, -- 985
						phase = "validate", -- 985
						message = "body lua root must be {\"Array\", ...}" -- 985
					} -- 985
				end -- 984
				local text, jsonErr = json.encode(data, false, true) -- 986
				if not text then -- 987
					return { -- 988
						success = false, -- 988
						phase = "encode", -- 988
						message = tostring(jsonErr) -- 988
					} -- 988
				end -- 987
				return { -- 989
					success = true, -- 989
					json = text -- 989
				} -- 989
			end -- 975
		end -- 975
	end -- 975
	return { -- 974
		success = false, -- 974
		phase = "request", -- 974
		message = "invalid request" -- 974
	} -- 974
end) -- 974
local updateInferedDesc -- 991
updateInferedDesc = function(infered) -- 991
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 992
		return -- 992
	end -- 992
	local key, row = infered.key, infered.row -- 993
	local codes = Content:loadAsync(key) -- 994
	if codes then -- 994
		local comments = { } -- 995
		local line = 0 -- 996
		local skipping = false -- 997
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 998
			line = line + 1 -- 999
			if line >= row then -- 1000
				break -- 1000
			end -- 1000
			if lineCode:match("^%s*%-%- @") then -- 1001
				skipping = true -- 1002
				goto _continue_0 -- 1003
			end -- 1001
			local result = lineCode:match("^%s*%-%- (.+)") -- 1004
			if result then -- 1004
				if not skipping then -- 1005
					comments[#comments + 1] = result -- 1005
				end -- 1005
			elseif #comments > 0 then -- 1006
				comments = { } -- 1007
				skipping = false -- 1008
			end -- 1004
			::_continue_0:: -- 999
		end -- 998
		infered.doc = table.concat(comments, "\n") -- 1009
	end -- 994
end -- 991
HttpServer:postSchedule("/infer", function(req) -- 1011
	do -- 1012
		local _type_0 = type(req) -- 1012
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1012
		if _tab_0 then -- 1012
			local lang -- 1012
			do -- 1012
				local _obj_0 = req.body -- 1012
				local _type_1 = type(_obj_0) -- 1012
				if "table" == _type_1 or "userdata" == _type_1 then -- 1012
					lang = _obj_0.lang -- 1012
				end -- 1012
			end -- 1012
			local file -- 1012
			do -- 1012
				local _obj_0 = req.body -- 1012
				local _type_1 = type(_obj_0) -- 1012
				if "table" == _type_1 or "userdata" == _type_1 then -- 1012
					file = _obj_0.file -- 1012
				end -- 1012
			end -- 1012
			local content -- 1012
			do -- 1012
				local _obj_0 = req.body -- 1012
				local _type_1 = type(_obj_0) -- 1012
				if "table" == _type_1 or "userdata" == _type_1 then -- 1012
					content = _obj_0.content -- 1012
				end -- 1012
			end -- 1012
			local line -- 1012
			do -- 1012
				local _obj_0 = req.body -- 1012
				local _type_1 = type(_obj_0) -- 1012
				if "table" == _type_1 or "userdata" == _type_1 then -- 1012
					line = _obj_0.line -- 1012
				end -- 1012
			end -- 1012
			local row -- 1012
			do -- 1012
				local _obj_0 = req.body -- 1012
				local _type_1 = type(_obj_0) -- 1012
				if "table" == _type_1 or "userdata" == _type_1 then -- 1012
					row = _obj_0.row -- 1012
				end -- 1012
			end -- 1012
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1012
				local searchPath = getSearchPath(file) -- 1013
				if "tl" == lang or "lua" == lang then -- 1014
					if CheckTIC80Code(content) then -- 1015
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1016
					end -- 1015
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1017
					if (infered ~= nil) then -- 1018
						updateInferedDesc(infered) -- 1019
						return { -- 1020
							success = true, -- 1020
							infered = infered -- 1020
						} -- 1020
					end -- 1018
				elseif "yue" == lang then -- 1021
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1022
					if not luaCodes then -- 1023
						return { -- 1023
							success = false -- 1023
						} -- 1023
					end -- 1023
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1024
					if (infered ~= nil) then -- 1025
						local col -- 1026
						file, row, col = infered.file, infered.row, infered.col -- 1026
						if file == "" and row > 0 and col > 0 then -- 1027
							infered.row = lineMap[row] or 0 -- 1028
							infered.col = 0 -- 1029
						end -- 1027
						updateInferedDesc(infered) -- 1030
						return { -- 1031
							success = true, -- 1031
							infered = infered -- 1031
						} -- 1031
					end -- 1025
				end -- 1014
			end -- 1012
		end -- 1012
	end -- 1012
	return { -- 1011
		success = false -- 1011
	} -- 1011
end) -- 1011
local _anon_func_3 = function(doc) -- 1082
	local _accum_0 = { } -- 1082
	local _len_0 = 1 -- 1082
	local _list_0 = doc.params -- 1082
	for _index_0 = 1, #_list_0 do -- 1082
		local param = _list_0[_index_0] -- 1082
		_accum_0[_len_0] = param.name -- 1082
		_len_0 = _len_0 + 1 -- 1082
	end -- 1082
	return _accum_0 -- 1082
end -- 1082
local getParamDocs -- 1033
getParamDocs = function(signatures) -- 1033
	do -- 1034
		local codes = Content:loadAsync(signatures[1].file) -- 1034
		if codes then -- 1034
			local comments = { } -- 1035
			local params = { } -- 1036
			local line = 0 -- 1037
			local docs = { } -- 1038
			local returnType = nil -- 1039
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1040
				line = line + 1 -- 1041
				local needBreak = true -- 1042
				for i, _des_0 in ipairs(signatures) do -- 1043
					local row = _des_0.row -- 1043
					if line >= row and not (docs[i] ~= nil) then -- 1044
						if #comments > 0 or #params > 0 or returnType then -- 1045
							docs[i] = { -- 1047
								doc = table.concat(comments, "  \n"), -- 1047
								returnType = returnType -- 1048
							} -- 1046
							if #params > 0 then -- 1050
								docs[i].params = params -- 1050
							end -- 1050
						else -- 1052
							docs[i] = false -- 1052
						end -- 1045
					end -- 1044
					if not docs[i] then -- 1053
						needBreak = false -- 1053
					end -- 1053
				end -- 1043
				if needBreak then -- 1054
					break -- 1054
				end -- 1054
				local result = lineCode:match("%s*%-%- (.+)") -- 1055
				if result then -- 1055
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1056
					if not name then -- 1057
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1058
					end -- 1057
					if name then -- 1059
						local pname = name -- 1060
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1061
							pname = pname .. "?" -- 1061
						end -- 1061
						params[#params + 1] = { -- 1063
							name = tostring(pname) .. ": " .. tostring(typ), -- 1063
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1064
						} -- 1062
					else -- 1067
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1067
						if typ then -- 1067
							if returnType then -- 1068
								returnType = returnType .. ", " .. typ -- 1069
							else -- 1071
								returnType = typ -- 1071
							end -- 1068
							result = result:gsub("@return", "**return:**") -- 1072
						end -- 1067
						comments[#comments + 1] = result -- 1073
					end -- 1059
				elseif #comments > 0 then -- 1074
					comments = { } -- 1075
					params = { } -- 1076
					returnType = nil -- 1077
				end -- 1055
			end -- 1040
			local results = { } -- 1078
			for _index_0 = 1, #docs do -- 1079
				local doc = docs[_index_0] -- 1079
				if not doc then -- 1080
					goto _continue_0 -- 1080
				end -- 1080
				if doc.params then -- 1081
					doc.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1082
				else -- 1084
					doc.desc = "function()" -- 1084
				end -- 1081
				if doc.returnType then -- 1085
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 1086
					doc.returnType = nil -- 1087
				end -- 1085
				results[#results + 1] = doc -- 1088
				::_continue_0:: -- 1080
			end -- 1079
			if #results > 0 then -- 1089
				return results -- 1089
			else -- 1089
				return nil -- 1089
			end -- 1089
		end -- 1034
	end -- 1034
	return nil -- 1033
end -- 1033
HttpServer:postSchedule("/signature", function(req) -- 1091
	do -- 1092
		local _type_0 = type(req) -- 1092
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1092
		if _tab_0 then -- 1092
			local lang -- 1092
			do -- 1092
				local _obj_0 = req.body -- 1092
				local _type_1 = type(_obj_0) -- 1092
				if "table" == _type_1 or "userdata" == _type_1 then -- 1092
					lang = _obj_0.lang -- 1092
				end -- 1092
			end -- 1092
			local file -- 1092
			do -- 1092
				local _obj_0 = req.body -- 1092
				local _type_1 = type(_obj_0) -- 1092
				if "table" == _type_1 or "userdata" == _type_1 then -- 1092
					file = _obj_0.file -- 1092
				end -- 1092
			end -- 1092
			local content -- 1092
			do -- 1092
				local _obj_0 = req.body -- 1092
				local _type_1 = type(_obj_0) -- 1092
				if "table" == _type_1 or "userdata" == _type_1 then -- 1092
					content = _obj_0.content -- 1092
				end -- 1092
			end -- 1092
			local line -- 1092
			do -- 1092
				local _obj_0 = req.body -- 1092
				local _type_1 = type(_obj_0) -- 1092
				if "table" == _type_1 or "userdata" == _type_1 then -- 1092
					line = _obj_0.line -- 1092
				end -- 1092
			end -- 1092
			local row -- 1092
			do -- 1092
				local _obj_0 = req.body -- 1092
				local _type_1 = type(_obj_0) -- 1092
				if "table" == _type_1 or "userdata" == _type_1 then -- 1092
					row = _obj_0.row -- 1092
				end -- 1092
			end -- 1092
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1092
				local searchPath = getSearchPath(file) -- 1093
				if "tl" == lang or "lua" == lang then -- 1094
					if CheckTIC80Code(content) then -- 1095
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1096
					end -- 1095
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1097
					if signatures then -- 1097
						signatures = getParamDocs(signatures) -- 1098
						if signatures then -- 1098
							return { -- 1099
								success = true, -- 1099
								signatures = signatures -- 1099
							} -- 1099
						end -- 1098
					end -- 1097
				elseif "yue" == lang then -- 1100
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1101
					if not luaCodes then -- 1102
						return { -- 1102
							success = false -- 1102
						} -- 1102
					end -- 1102
					do -- 1103
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1103
						if chainOp then -- 1103
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1104
							if withVar then -- 1104
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1105
							end -- 1104
						end -- 1103
					end -- 1103
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1106
					if signatures then -- 1106
						signatures = getParamDocs(signatures) -- 1107
						if signatures then -- 1107
							return { -- 1108
								success = true, -- 1108
								signatures = signatures -- 1108
							} -- 1108
						end -- 1107
					else -- 1109
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1109
						if signatures then -- 1109
							signatures = getParamDocs(signatures) -- 1110
							if signatures then -- 1110
								return { -- 1111
									success = true, -- 1111
									signatures = signatures -- 1111
								} -- 1111
							end -- 1110
						end -- 1109
					end -- 1106
				end -- 1094
			end -- 1092
		end -- 1092
	end -- 1092
	return { -- 1091
		success = false -- 1091
	} -- 1091
end) -- 1091
local luaKeywords = { -- 1114
	'and', -- 1114
	'break', -- 1115
	'do', -- 1116
	'else', -- 1117
	'elseif', -- 1118
	'end', -- 1119
	'false', -- 1120
	'for', -- 1121
	'function', -- 1122
	'goto', -- 1123
	'if', -- 1124
	'in', -- 1125
	'local', -- 1126
	'nil', -- 1127
	'not', -- 1128
	'or', -- 1129
	'repeat', -- 1130
	'return', -- 1131
	'then', -- 1132
	'true', -- 1133
	'until', -- 1134
	'while' -- 1135
} -- 1113
local tealKeywords = { -- 1139
	'record', -- 1139
	'as', -- 1140
	'is', -- 1141
	'type', -- 1142
	'embed', -- 1143
	'enum', -- 1144
	'global', -- 1145
	'any', -- 1146
	'boolean', -- 1147
	'integer', -- 1148
	'number', -- 1149
	'string', -- 1150
	'thread' -- 1151
} -- 1138
local yueKeywords = { -- 1155
	"and", -- 1155
	"break", -- 1156
	"do", -- 1157
	"else", -- 1158
	"elseif", -- 1159
	"false", -- 1160
	"for", -- 1161
	"goto", -- 1162
	"if", -- 1163
	"in", -- 1164
	"local", -- 1165
	"nil", -- 1166
	"not", -- 1167
	"or", -- 1168
	"repeat", -- 1169
	"return", -- 1170
	"then", -- 1171
	"true", -- 1172
	"until", -- 1173
	"while", -- 1174
	"as", -- 1175
	"class", -- 1176
	"continue", -- 1177
	"export", -- 1178
	"extends", -- 1179
	"from", -- 1180
	"global", -- 1181
	"import", -- 1182
	"macro", -- 1183
	"switch", -- 1184
	"try", -- 1185
	"unless", -- 1186
	"using", -- 1187
	"when", -- 1188
	"with" -- 1189
} -- 1154
local _anon_func_4 = function(f) -- 1225
	local _val_0 = Path:getExt(f) -- 1225
	return "ttf" == _val_0 or "otf" == _val_0 -- 1225
end -- 1225
local _anon_func_5 = function(suggestions) -- 1251
	local _tbl_0 = { } -- 1251
	for _index_0 = 1, #suggestions do -- 1251
		local item = suggestions[_index_0] -- 1251
		_tbl_0[item[1] .. item[2]] = item -- 1251
	end -- 1251
	return _tbl_0 -- 1251
end -- 1251
HttpServer:postSchedule("/complete", function(req) -- 1192
	do -- 1193
		local _type_0 = type(req) -- 1193
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1193
		if _tab_0 then -- 1193
			local lang -- 1193
			do -- 1193
				local _obj_0 = req.body -- 1193
				local _type_1 = type(_obj_0) -- 1193
				if "table" == _type_1 or "userdata" == _type_1 then -- 1193
					lang = _obj_0.lang -- 1193
				end -- 1193
			end -- 1193
			local file -- 1193
			do -- 1193
				local _obj_0 = req.body -- 1193
				local _type_1 = type(_obj_0) -- 1193
				if "table" == _type_1 or "userdata" == _type_1 then -- 1193
					file = _obj_0.file -- 1193
				end -- 1193
			end -- 1193
			local content -- 1193
			do -- 1193
				local _obj_0 = req.body -- 1193
				local _type_1 = type(_obj_0) -- 1193
				if "table" == _type_1 or "userdata" == _type_1 then -- 1193
					content = _obj_0.content -- 1193
				end -- 1193
			end -- 1193
			local line -- 1193
			do -- 1193
				local _obj_0 = req.body -- 1193
				local _type_1 = type(_obj_0) -- 1193
				if "table" == _type_1 or "userdata" == _type_1 then -- 1193
					line = _obj_0.line -- 1193
				end -- 1193
			end -- 1193
			local row -- 1193
			do -- 1193
				local _obj_0 = req.body -- 1193
				local _type_1 = type(_obj_0) -- 1193
				if "table" == _type_1 or "userdata" == _type_1 then -- 1193
					row = _obj_0.row -- 1193
				end -- 1193
			end -- 1193
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1193
				local searchPath = getSearchPath(file) -- 1194
				repeat -- 1195
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1196
					if lang == "yue" then -- 1197
						if not item then -- 1198
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1198
						end -- 1198
						if not item then -- 1199
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1199
						end -- 1199
					end -- 1197
					local searchType = nil -- 1200
					if not item then -- 1201
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1202
						if lang == "yue" then -- 1203
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1204
						end -- 1203
						if (item ~= nil) then -- 1205
							searchType = "Image" -- 1205
						end -- 1205
					end -- 1201
					if not item then -- 1206
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1207
						if lang == "yue" then -- 1208
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1209
						end -- 1208
						if (item ~= nil) then -- 1210
							searchType = "Font" -- 1210
						end -- 1210
					end -- 1206
					if not item then -- 1211
						break -- 1211
					end -- 1211
					local searchPaths = Content.searchPaths -- 1212
					local _list_0 = getSearchFolders(file) -- 1213
					for _index_0 = 1, #_list_0 do -- 1213
						local folder = _list_0[_index_0] -- 1213
						searchPaths[#searchPaths + 1] = folder -- 1214
					end -- 1213
					if searchType then -- 1215
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1215
					end -- 1215
					local tokens -- 1216
					do -- 1216
						local _accum_0 = { } -- 1216
						local _len_0 = 1 -- 1216
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1216
							_accum_0[_len_0] = mod -- 1216
							_len_0 = _len_0 + 1 -- 1216
						end -- 1216
						tokens = _accum_0 -- 1216
					end -- 1216
					local suggestions = { } -- 1217
					for _index_0 = 1, #searchPaths do -- 1218
						local path = searchPaths[_index_0] -- 1218
						local sPath = Path(path, table.unpack(tokens)) -- 1219
						if not Content:exist(sPath) then -- 1220
							goto _continue_0 -- 1220
						end -- 1220
						if searchType == "Font" then -- 1221
							local fontPath = Path(sPath, "Font") -- 1222
							if Content:exist(fontPath) then -- 1223
								local _list_1 = Content:getFiles(fontPath) -- 1224
								for _index_1 = 1, #_list_1 do -- 1224
									local f = _list_1[_index_1] -- 1224
									if _anon_func_4(f) then -- 1225
										if "." == f:sub(1, 1) then -- 1226
											goto _continue_1 -- 1226
										end -- 1226
										suggestions[#suggestions + 1] = { -- 1227
											Path:getName(f), -- 1227
											"font", -- 1227
											"field" -- 1227
										} -- 1227
									end -- 1225
									::_continue_1:: -- 1225
								end -- 1224
							end -- 1223
						end -- 1221
						local _list_1 = Content:getFiles(sPath) -- 1228
						for _index_1 = 1, #_list_1 do -- 1228
							local f = _list_1[_index_1] -- 1228
							if "Image" == searchType then -- 1229
								do -- 1230
									local _exp_0 = Path:getExt(f) -- 1230
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1230
										if "." == f:sub(1, 1) then -- 1231
											goto _continue_2 -- 1231
										end -- 1231
										suggestions[#suggestions + 1] = { -- 1232
											f, -- 1232
											"image", -- 1232
											"field" -- 1232
										} -- 1232
									end -- 1230
								end -- 1230
								goto _continue_2 -- 1233
							elseif "Font" == searchType then -- 1234
								do -- 1235
									local _exp_0 = Path:getExt(f) -- 1235
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1235
										if "." == f:sub(1, 1) then -- 1236
											goto _continue_2 -- 1236
										end -- 1236
										suggestions[#suggestions + 1] = { -- 1237
											f, -- 1237
											"font", -- 1237
											"field" -- 1237
										} -- 1237
									end -- 1235
								end -- 1235
								goto _continue_2 -- 1238
							end -- 1229
							local _exp_0 = Path:getExt(f) -- 1239
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1239
								local name = Path:getName(f) -- 1240
								if "d" == Path:getExt(name) then -- 1241
									goto _continue_2 -- 1241
								end -- 1241
								if "." == name:sub(1, 1) then -- 1242
									goto _continue_2 -- 1242
								end -- 1242
								suggestions[#suggestions + 1] = { -- 1243
									name, -- 1243
									"module", -- 1243
									"field" -- 1243
								} -- 1243
							end -- 1239
							::_continue_2:: -- 1229
						end -- 1228
						local _list_2 = Content:getDirs(sPath) -- 1244
						for _index_1 = 1, #_list_2 do -- 1244
							local dir = _list_2[_index_1] -- 1244
							if "." == dir:sub(1, 1) then -- 1245
								goto _continue_3 -- 1245
							end -- 1245
							suggestions[#suggestions + 1] = { -- 1246
								dir, -- 1246
								"folder", -- 1246
								"variable" -- 1246
							} -- 1246
							::_continue_3:: -- 1245
						end -- 1244
						::_continue_0:: -- 1219
					end -- 1218
					if item == "" and not searchType then -- 1247
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1248
						for _index_0 = 1, #_list_1 do -- 1248
							local _des_0 = _list_1[_index_0] -- 1248
							local name = _des_0[1] -- 1248
							suggestions[#suggestions + 1] = { -- 1249
								name, -- 1249
								"dora module", -- 1249
								"function" -- 1249
							} -- 1249
						end -- 1248
					end -- 1247
					if #suggestions > 0 then -- 1250
						do -- 1251
							local _accum_0 = { } -- 1251
							local _len_0 = 1 -- 1251
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1251
								_accum_0[_len_0] = v -- 1251
								_len_0 = _len_0 + 1 -- 1251
							end -- 1251
							suggestions = _accum_0 -- 1251
						end -- 1251
						return { -- 1252
							success = true, -- 1252
							suggestions = suggestions -- 1252
						} -- 1252
					else -- 1254
						return { -- 1254
							success = false -- 1254
						} -- 1254
					end -- 1250
				until true -- 1195
				if "tl" == lang or "lua" == lang then -- 1256
					do -- 1257
						local isTIC80 = CheckTIC80Code(content) -- 1257
						if isTIC80 then -- 1257
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1258
						end -- 1257
					end -- 1257
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1259
					if not line:match("[%.:]$") then -- 1260
						local checkSet -- 1261
						do -- 1261
							local _tbl_0 = { } -- 1261
							for _index_0 = 1, #suggestions do -- 1261
								local _des_0 = suggestions[_index_0] -- 1261
								local name = _des_0[1] -- 1261
								_tbl_0[name] = true -- 1261
							end -- 1261
							checkSet = _tbl_0 -- 1261
						end -- 1261
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1262
						for _index_0 = 1, #_list_0 do -- 1262
							local item = _list_0[_index_0] -- 1262
							if not checkSet[item[1]] then -- 1263
								suggestions[#suggestions + 1] = item -- 1263
							end -- 1263
						end -- 1262
						for _index_0 = 1, #luaKeywords do -- 1264
							local word = luaKeywords[_index_0] -- 1264
							suggestions[#suggestions + 1] = { -- 1265
								word, -- 1265
								"keyword", -- 1265
								"keyword" -- 1265
							} -- 1265
						end -- 1264
						if lang == "tl" then -- 1266
							for _index_0 = 1, #tealKeywords do -- 1267
								local word = tealKeywords[_index_0] -- 1267
								suggestions[#suggestions + 1] = { -- 1268
									word, -- 1268
									"keyword", -- 1268
									"keyword" -- 1268
								} -- 1268
							end -- 1267
						end -- 1266
					end -- 1260
					if #suggestions > 0 then -- 1269
						return { -- 1270
							success = true, -- 1270
							suggestions = suggestions -- 1270
						} -- 1270
					end -- 1269
				elseif "yue" == lang then -- 1271
					local suggestions = { } -- 1272
					local gotGlobals = false -- 1273
					do -- 1274
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1274
						if luaCodes then -- 1274
							gotGlobals = true -- 1275
							do -- 1276
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1276
								if chainOp then -- 1276
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1277
									if not withVar then -- 1278
										return { -- 1278
											success = false -- 1278
										} -- 1278
									end -- 1278
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1279
								elseif line:match("^([%.\\])$") then -- 1280
									return { -- 1281
										success = false -- 1281
									} -- 1281
								end -- 1276
							end -- 1276
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1282
							for _index_0 = 1, #_list_0 do -- 1282
								local item = _list_0[_index_0] -- 1282
								suggestions[#suggestions + 1] = item -- 1282
							end -- 1282
							if #suggestions == 0 then -- 1283
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1284
								for _index_0 = 1, #_list_1 do -- 1284
									local item = _list_1[_index_0] -- 1284
									suggestions[#suggestions + 1] = item -- 1284
								end -- 1284
							end -- 1283
						end -- 1274
					end -- 1274
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1285
						local checkSet -- 1286
						do -- 1286
							local _tbl_0 = { } -- 1286
							for _index_0 = 1, #suggestions do -- 1286
								local _des_0 = suggestions[_index_0] -- 1286
								local name = _des_0[1] -- 1286
								_tbl_0[name] = true -- 1286
							end -- 1286
							checkSet = _tbl_0 -- 1286
						end -- 1286
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1287
						for _index_0 = 1, #_list_0 do -- 1287
							local item = _list_0[_index_0] -- 1287
							if not checkSet[item[1]] then -- 1288
								suggestions[#suggestions + 1] = item -- 1288
							end -- 1288
						end -- 1287
						if not gotGlobals then -- 1289
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1290
							for _index_0 = 1, #_list_1 do -- 1290
								local item = _list_1[_index_0] -- 1290
								if not checkSet[item[1]] then -- 1291
									suggestions[#suggestions + 1] = item -- 1291
								end -- 1291
							end -- 1290
						end -- 1289
						for _index_0 = 1, #yueKeywords do -- 1292
							local word = yueKeywords[_index_0] -- 1292
							if not checkSet[word] then -- 1293
								suggestions[#suggestions + 1] = { -- 1294
									word, -- 1294
									"keyword", -- 1294
									"keyword" -- 1294
								} -- 1294
							end -- 1293
						end -- 1292
					end -- 1285
					if #suggestions > 0 then -- 1295
						return { -- 1296
							success = true, -- 1296
							suggestions = suggestions -- 1296
						} -- 1296
					end -- 1295
				elseif "xml" == lang then -- 1297
					local items = xml.complete(content) -- 1298
					if #items > 0 then -- 1299
						local suggestions -- 1300
						do -- 1300
							local _accum_0 = { } -- 1300
							local _len_0 = 1 -- 1300
							for _index_0 = 1, #items do -- 1300
								local _des_0 = items[_index_0] -- 1300
								local label, insertText = _des_0[1], _des_0[2] -- 1300
								_accum_0[_len_0] = { -- 1301
									label, -- 1301
									insertText, -- 1301
									"field" -- 1301
								} -- 1301
								_len_0 = _len_0 + 1 -- 1301
							end -- 1300
							suggestions = _accum_0 -- 1300
						end -- 1300
						return { -- 1302
							success = true, -- 1302
							suggestions = suggestions -- 1302
						} -- 1302
					end -- 1299
				end -- 1256
			end -- 1193
		end -- 1193
	end -- 1193
	return { -- 1192
		success = false -- 1192
	} -- 1192
end) -- 1192
HttpServer:upload("/upload", function(req, filename) -- 1306
	do -- 1307
		local _type_0 = type(req) -- 1307
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1307
		if _tab_0 then -- 1307
			local path -- 1307
			do -- 1307
				local _obj_0 = req.params -- 1307
				local _type_1 = type(_obj_0) -- 1307
				if "table" == _type_1 or "userdata" == _type_1 then -- 1307
					path = _obj_0.path -- 1307
				end -- 1307
			end -- 1307
			if path ~= nil then -- 1307
				local uploadPath = Path(Content.writablePath, ".upload") -- 1308
				if not Content:exist(uploadPath) then -- 1309
					Content:mkdir(uploadPath) -- 1310
				end -- 1309
				local targetPath = Path(uploadPath, filename) -- 1311
				Content:mkdir(Path:getPath(targetPath)) -- 1312
				return targetPath -- 1313
			end -- 1307
		end -- 1307
	end -- 1307
	return nil -- 1306
end, function(req, file) -- 1314
	do -- 1315
		local _type_0 = type(req) -- 1315
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1315
		if _tab_0 then -- 1315
			local path -- 1315
			do -- 1315
				local _obj_0 = req.params -- 1315
				local _type_1 = type(_obj_0) -- 1315
				if "table" == _type_1 or "userdata" == _type_1 then -- 1315
					path = _obj_0.path -- 1315
				end -- 1315
			end -- 1315
			if path ~= nil then -- 1315
				path = Path(Content.writablePath, path) -- 1316
				if Content:exist(path) then -- 1317
					local uploadPath = Path(Content.writablePath, ".upload") -- 1318
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1319
					Content:mkdir(Path:getPath(targetPath)) -- 1320
					if Content:move(file, targetPath) then -- 1321
						return true -- 1322
					end -- 1321
				end -- 1317
			end -- 1315
		end -- 1315
	end -- 1315
	return false -- 1314
end) -- 1304
HttpServer:post("/list", function(req) -- 1325
	do -- 1326
		local _type_0 = type(req) -- 1326
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1326
		if _tab_0 then -- 1326
			local path -- 1326
			do -- 1326
				local _obj_0 = req.body -- 1326
				local _type_1 = type(_obj_0) -- 1326
				if "table" == _type_1 or "userdata" == _type_1 then -- 1326
					path = _obj_0.path -- 1326
				end -- 1326
			end -- 1326
			if path ~= nil then -- 1326
				if Content:exist(path) then -- 1327
					local files = { } -- 1328
					local visitAssets -- 1329
					visitAssets = function(path, folder) -- 1329
						local dirs = Content:getDirs(path) -- 1330
						for _index_0 = 1, #dirs do -- 1331
							local dir = dirs[_index_0] -- 1331
							if dir:match("^%.") then -- 1332
								goto _continue_0 -- 1332
							end -- 1332
							local current -- 1333
							if folder == "" then -- 1333
								current = dir -- 1334
							else -- 1336
								current = Path(folder, dir) -- 1336
							end -- 1333
							files[#files + 1] = current -- 1337
							visitAssets(Path(path, dir), current) -- 1338
							::_continue_0:: -- 1332
						end -- 1331
						local fs = Content:getFiles(path) -- 1339
						for _index_0 = 1, #fs do -- 1340
							local f = fs[_index_0] -- 1340
							if (".DS_Store" == f) then -- 1341
								goto _continue_1 -- 1342
							end -- 1341
							if folder == "" then -- 1343
								files[#files + 1] = f -- 1344
							else -- 1346
								files[#files + 1] = Path(folder, f) -- 1346
							end -- 1343
							::_continue_1:: -- 1341
						end -- 1340
					end -- 1329
					visitAssets(path, "") -- 1347
					if #files == 0 then -- 1348
						files = nil -- 1348
					end -- 1348
					return { -- 1349
						success = true, -- 1349
						files = files -- 1349
					} -- 1349
				end -- 1327
			end -- 1326
		end -- 1326
	end -- 1326
	return { -- 1325
		success = false -- 1325
	} -- 1325
end) -- 1325
HttpServer:post("/info", function() -- 1351
	local Entry = require("Script.Dev.Entry") -- 1352
	local webProfiler, drawerWidth -- 1353
	do -- 1353
		local _obj_0 = Entry.getConfig() -- 1353
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 1353
	end -- 1353
	local engineDev = Entry.getEngineDev() -- 1354
	Entry.connectWebIDE() -- 1355
	return { -- 1357
		platform = App.platform, -- 1357
		locale = App.locale, -- 1358
		version = App.version, -- 1359
		engineDev = engineDev, -- 1360
		webProfiler = webProfiler, -- 1361
		drawerWidth = drawerWidth -- 1362
	} -- 1356
end) -- 1351
local ensureLLMConfigTable -- 1364
ensureLLMConfigTable = function() -- 1364
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1365
	if columns and #columns > 0 then -- 1366
		local expected = { -- 1368
			id = true, -- 1368
			name = true, -- 1369
			url = true, -- 1370
			model = true, -- 1371
			api_key = true, -- 1372
			context_window = true, -- 1373
			temperature = true, -- 1374
			max_tokens = true, -- 1375
			reasoning_effort = true, -- 1376
			custom_options = true, -- 1377
			supports_function_calling = true, -- 1378
			active = true, -- 1379
			created_at = true, -- 1380
			updated_at = true -- 1381
		} -- 1367
		local existing = { } -- 1383
		local valid = true -- 1384
		for _index_0 = 1, #columns do -- 1385
			local row = columns[_index_0] -- 1385
			local columnName = tostring(row[2]) -- 1386
			existing[columnName] = true -- 1387
			if not expected[columnName] then -- 1388
				valid = false -- 1389
				break -- 1390
			end -- 1388
		end -- 1385
		if valid then -- 1391
			if not existing.context_window then -- 1392
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1393
			end -- 1392
			if not existing.temperature then -- 1394
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1395
			end -- 1394
			if not existing.max_tokens then -- 1396
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 1397
			end -- 1396
			if not existing.reasoning_effort then -- 1398
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1399
			end -- 1398
			if not existing.custom_options then -- 1400
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1401
			end -- 1400
			if not existing.supports_function_calling then -- 1402
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1403
			end -- 1402
		else -- 1405
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1405
		end -- 1391
	end -- 1366
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
	]]) -- 1406
end -- 1364
local normalizeContextWindow -- 1425
normalizeContextWindow = function(value) -- 1425
	local contextWindow = tonumber(value) -- 1426
	if contextWindow == nil or contextWindow < 64000 then -- 1427
		return 64000 -- 1428
	end -- 1427
	return math.max(64000, math.floor(contextWindow)) -- 1429
end -- 1425
local normalizeTemperature -- 1431
normalizeTemperature = function(value) -- 1431
	local temperature = tonumber(value) -- 1432
	if temperature == nil then -- 1433
		return 0.1 -- 1434
	end -- 1433
	return math.max(0, math.min(2, temperature)) -- 1435
end -- 1431
local normalizeMaxTokens -- 1437
normalizeMaxTokens = function(value) -- 1437
	local maxTokens = tonumber(value) -- 1438
	if maxTokens == nil or maxTokens < 1 then -- 1439
		return 8192 -- 1440
	end -- 1439
	return math.max(1, math.floor(maxTokens)) -- 1441
end -- 1437
local normalizeReasoningEffort -- 1443
normalizeReasoningEffort = function(value) -- 1443
	if value == nil then -- 1444
		return "" -- 1445
	end -- 1444
	local effort = tostring(value) -- 1446
	return effort:match("^%s*(.-)%s*$") or "" -- 1447
end -- 1443
local normalizeCustomOptions -- 1449
normalizeCustomOptions = function(value) -- 1449
	if value == nil then -- 1450
		return "" -- 1451
	end -- 1450
	local options = tostring(value) -- 1452
	options = options:match("^%s*(.-)%s*$") or "" -- 1453
	return options -- 1454
end -- 1449
local validateCustomOptions -- 1456
validateCustomOptions = function(value) -- 1456
	local options = normalizeCustomOptions(value) -- 1457
	if options == "" then -- 1458
		return true -- 1458
	end -- 1458
	if not options:match("^%s*{") then -- 1459
		return false -- 1459
	end -- 1459
	local decoded = json.decode(options) -- 1460
	return type(decoded) == "table" -- 1461
end -- 1456
HttpServer:post("/llm/list", function() -- 1463
	ensureLLMConfigTable() -- 1464
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active\n		from LLMConfig\n		order by id asc") -- 1465
	local items -- 1469
	if rows and #rows > 0 then -- 1469
		local _accum_0 = { } -- 1470
		local _len_0 = 1 -- 1470
		for _index_0 = 1, #rows do -- 1470
			local _des_0 = rows[_index_0] -- 1470
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11], _des_0[12] -- 1470
			_accum_0[_len_0] = { -- 1471
				id = id, -- 1471
				name = name, -- 1471
				url = url, -- 1471
				model = model, -- 1471
				key = key, -- 1471
				contextWindow = normalizeContextWindow(contextWindow), -- 1471
				temperature = normalizeTemperature(temperature), -- 1471
				maxTokens = normalizeMaxTokens(maxTokens), -- 1471
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1471
				customOptions = normalizeCustomOptions(customOptions), -- 1471
				supportsFunctionCalling = supportsFunctionCalling ~= 0, -- 1471
				active = active ~= 0 -- 1471
			} -- 1471
			_len_0 = _len_0 + 1 -- 1471
		end -- 1470
		items = _accum_0 -- 1469
	end -- 1469
	return { -- 1472
		success = true, -- 1472
		items = items -- 1472
	} -- 1472
end) -- 1463
HttpServer:post("/llm/create", function(req) -- 1474
	ensureLLMConfigTable() -- 1475
	do -- 1476
		local _type_0 = type(req) -- 1476
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1476
		if _tab_0 then -- 1476
			local body = req.body -- 1476
			if body ~= nil then -- 1476
				local name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1477
				local now = os.time() -- 1478
				if name == nil or url == nil or model == nil or key == nil then -- 1479
					return { -- 1480
						success = false, -- 1480
						message = "invalid" -- 1480
					} -- 1480
				end -- 1479
				contextWindow = normalizeContextWindow(contextWindow) -- 1481
				temperature = normalizeTemperature(temperature) -- 1482
				maxTokens = normalizeMaxTokens(maxTokens) -- 1483
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1484
				customOptions = normalizeCustomOptions(customOptions) -- 1485
				if not validateCustomOptions(customOptions) then -- 1486
					return { -- 1486
						success = false, -- 1486
						message = "customOptions must be a JSON object" -- 1486
					} -- 1486
				end -- 1486
				if supportsFunctionCalling == false then -- 1487
					supportsFunctionCalling = 0 -- 1487
				else -- 1487
					supportsFunctionCalling = 1 -- 1487
				end -- 1487
				if active then -- 1488
					active = 1 -- 1488
				else -- 1488
					active = 0 -- 1488
				end -- 1488
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1495
					tostring(name), -- 1495
					tostring(url), -- 1496
					tostring(model), -- 1497
					tostring(key), -- 1498
					contextWindow, -- 1499
					temperature, -- 1500
					maxTokens, -- 1501
					reasoningEffort, -- 1502
					customOptions, -- 1503
					supportsFunctionCalling, -- 1504
					active, -- 1505
					now, -- 1506
					now -- 1507
				}) -- 1489
				return { -- 1509
					success = affected >= 0 -- 1509
				} -- 1509
			end -- 1476
		end -- 1476
	end -- 1476
	return { -- 1474
		success = false, -- 1474
		message = "invalid" -- 1474
	} -- 1474
end) -- 1474
HttpServer:post("/llm/update", function(req) -- 1511
	ensureLLMConfigTable() -- 1512
	do -- 1513
		local _type_0 = type(req) -- 1513
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1513
		if _tab_0 then -- 1513
			local body = req.body -- 1513
			if body ~= nil then -- 1513
				local id, name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1514
				local now = os.time() -- 1515
				id = tonumber(id) -- 1516
				if id == nil then -- 1517
					return { -- 1518
						success = false, -- 1518
						message = "invalid" -- 1518
					} -- 1518
				end -- 1517
				contextWindow = normalizeContextWindow(contextWindow) -- 1519
				temperature = normalizeTemperature(temperature) -- 1520
				maxTokens = normalizeMaxTokens(maxTokens) -- 1521
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1522
				customOptions = normalizeCustomOptions(customOptions) -- 1523
				if not validateCustomOptions(customOptions) then -- 1524
					return { -- 1524
						success = false, -- 1524
						message = "customOptions must be a JSON object" -- 1524
					} -- 1524
				end -- 1524
				if supportsFunctionCalling == false then -- 1525
					supportsFunctionCalling = 0 -- 1525
				else -- 1525
					supportsFunctionCalling = 1 -- 1525
				end -- 1525
				if active then -- 1526
					active = 1 -- 1526
				else -- 1526
					active = 0 -- 1526
				end -- 1526
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, active = ?, updated_at = ?\n			where id = ?", { -- 1531
					tostring(name), -- 1531
					tostring(url), -- 1532
					tostring(model), -- 1533
					tostring(key), -- 1534
					contextWindow, -- 1535
					temperature, -- 1536
					maxTokens, -- 1537
					reasoningEffort, -- 1538
					customOptions, -- 1539
					supportsFunctionCalling, -- 1540
					active, -- 1541
					now, -- 1542
					id -- 1543
				}) -- 1527
				return { -- 1545
					success = affected >= 0 -- 1545
				} -- 1545
			end -- 1513
		end -- 1513
	end -- 1513
	return { -- 1511
		success = false, -- 1511
		message = "invalid" -- 1511
	} -- 1511
end) -- 1511
HttpServer:post("/llm/delete", function(req) -- 1547
	ensureLLMConfigTable() -- 1548
	do -- 1549
		local _type_0 = type(req) -- 1549
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1549
		if _tab_0 then -- 1549
			local id -- 1549
			do -- 1549
				local _obj_0 = req.body -- 1549
				local _type_1 = type(_obj_0) -- 1549
				if "table" == _type_1 or "userdata" == _type_1 then -- 1549
					id = _obj_0.id -- 1549
				end -- 1549
			end -- 1549
			if id ~= nil then -- 1549
				id = tonumber(id) -- 1550
				if id == nil then -- 1551
					return { -- 1552
						success = false, -- 1552
						message = "invalid" -- 1552
					} -- 1552
				end -- 1551
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1553
					id -- 1553
				}) -- 1553
				return { -- 1554
					success = affected >= 0 -- 1554
				} -- 1554
			end -- 1549
		end -- 1549
	end -- 1549
	return { -- 1547
		success = false, -- 1547
		message = "invalid" -- 1547
	} -- 1547
end) -- 1547
HttpServer:post("/stat", function(req) -- 1556
	do -- 1557
		local _type_0 = type(req) -- 1557
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1557
		if _tab_0 then -- 1557
			local path -- 1557
			do -- 1557
				local _obj_0 = req.body -- 1557
				local _type_1 = type(_obj_0) -- 1557
				if "table" == _type_1 or "userdata" == _type_1 then -- 1557
					path = _obj_0.path -- 1557
				end -- 1557
			end -- 1557
			if path ~= nil then -- 1557
				if not Content:exist(path) then -- 1558
					return { -- 1559
						success = false, -- 1559
						message = "target not existed" -- 1559
					} -- 1559
				end -- 1558
				if Content:isdir(path) then -- 1560
					return { -- 1561
						success = false, -- 1561
						message = "failed to stat a directory" -- 1561
					} -- 1561
				end -- 1560
				local size, isBinary = Content:getAttr(path) -- 1562
				if size then -- 1562
					return { -- 1563
						success = true, -- 1563
						size = size, -- 1563
						isBinary = isBinary -- 1563
					} -- 1563
				end -- 1562
			end -- 1557
		end -- 1557
	end -- 1557
	return { -- 1556
		success = false, -- 1556
		message = "failed to stat" -- 1556
	} -- 1556
end) -- 1556
HttpServer:post("/new", function(req) -- 1565
	do -- 1566
		local _type_0 = type(req) -- 1566
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1566
		if _tab_0 then -- 1566
			local path -- 1566
			do -- 1566
				local _obj_0 = req.body -- 1566
				local _type_1 = type(_obj_0) -- 1566
				if "table" == _type_1 or "userdata" == _type_1 then -- 1566
					path = _obj_0.path -- 1566
				end -- 1566
			end -- 1566
			local content -- 1566
			do -- 1566
				local _obj_0 = req.body -- 1566
				local _type_1 = type(_obj_0) -- 1566
				if "table" == _type_1 or "userdata" == _type_1 then -- 1566
					content = _obj_0.content -- 1566
				end -- 1566
			end -- 1566
			local folder -- 1566
			do -- 1566
				local _obj_0 = req.body -- 1566
				local _type_1 = type(_obj_0) -- 1566
				if "table" == _type_1 or "userdata" == _type_1 then -- 1566
					folder = _obj_0.folder -- 1566
				end -- 1566
			end -- 1566
			if path ~= nil and content ~= nil and folder ~= nil then -- 1566
				if Content:exist(path) then -- 1567
					return { -- 1568
						success = false, -- 1568
						message = "TargetExisted" -- 1568
					} -- 1568
				end -- 1567
				local parent = Path:getPath(path) -- 1569
				local files = Content:getFiles(parent) -- 1570
				if folder then -- 1571
					local name = Path:getFilename(path):lower() -- 1572
					for _index_0 = 1, #files do -- 1573
						local file = files[_index_0] -- 1573
						if name == Path:getFilename(file):lower() then -- 1574
							return { -- 1575
								success = false, -- 1575
								message = "TargetExisted" -- 1575
							} -- 1575
						end -- 1574
					end -- 1573
					if Content:mkdir(path) then -- 1576
						return { -- 1577
							success = true -- 1577
						} -- 1577
					end -- 1576
				else -- 1579
					local name = Path:getName(path):lower() -- 1579
					for _index_0 = 1, #files do -- 1580
						local file = files[_index_0] -- 1580
						if name == Path:getName(file):lower() then -- 1581
							local ext = Path:getExt(file) -- 1582
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1583
								goto _continue_0 -- 1584
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1585
								goto _continue_0 -- 1586
							end -- 1583
							return { -- 1587
								success = false, -- 1587
								message = "SourceExisted" -- 1587
							} -- 1587
						end -- 1581
						::_continue_0:: -- 1581
					end -- 1580
					if Content:save(path, content) then -- 1588
						return { -- 1589
							success = true -- 1589
						} -- 1589
					end -- 1588
				end -- 1571
			end -- 1566
		end -- 1566
	end -- 1566
	return { -- 1565
		success = false, -- 1565
		message = "Failed" -- 1565
	} -- 1565
end) -- 1565
HttpServer:post("/delete", function(req) -- 1591
	do -- 1592
		local _type_0 = type(req) -- 1592
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1592
		if _tab_0 then -- 1592
			local path -- 1592
			do -- 1592
				local _obj_0 = req.body -- 1592
				local _type_1 = type(_obj_0) -- 1592
				if "table" == _type_1 or "userdata" == _type_1 then -- 1592
					path = _obj_0.path -- 1592
				end -- 1592
			end -- 1592
			if path ~= nil then -- 1592
				if Content:exist(path) then -- 1593
					local projectRoot -- 1594
					if Content:isdir(path) and isProjectRootDir(path) then -- 1594
						projectRoot = path -- 1594
					else -- 1594
						projectRoot = nil -- 1594
					end -- 1594
					local parent = Path:getPath(path) -- 1595
					local files = Content:getFiles(parent) -- 1596
					local name = Path:getName(path):lower() -- 1597
					local ext = Path:getExt(path) -- 1598
					for _index_0 = 1, #files do -- 1599
						local file = files[_index_0] -- 1599
						if name == Path:getName(file):lower() then -- 1600
							local _exp_0 = Path:getExt(file) -- 1601
							if "tl" == _exp_0 then -- 1601
								if ("vs" == ext) then -- 1601
									Content:remove(Path(parent, file)) -- 1602
								end -- 1601
							elseif "lua" == _exp_0 then -- 1603
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1603
									Content:remove(Path(parent, file)) -- 1604
								end -- 1603
							end -- 1601
						end -- 1600
					end -- 1599
					if Content:remove(path) then -- 1605
						if projectRoot then -- 1606
							AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1607
						end -- 1606
						return { -- 1608
							success = true -- 1608
						} -- 1608
					end -- 1605
				end -- 1593
			end -- 1592
		end -- 1592
	end -- 1592
	return { -- 1591
		success = false -- 1591
	} -- 1591
end) -- 1591
HttpServer:post("/rename", function(req) -- 1610
	do -- 1611
		local _type_0 = type(req) -- 1611
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1611
		if _tab_0 then -- 1611
			local old -- 1611
			do -- 1611
				local _obj_0 = req.body -- 1611
				local _type_1 = type(_obj_0) -- 1611
				if "table" == _type_1 or "userdata" == _type_1 then -- 1611
					old = _obj_0.old -- 1611
				end -- 1611
			end -- 1611
			local new -- 1611
			do -- 1611
				local _obj_0 = req.body -- 1611
				local _type_1 = type(_obj_0) -- 1611
				if "table" == _type_1 or "userdata" == _type_1 then -- 1611
					new = _obj_0.new -- 1611
				end -- 1611
			end -- 1611
			if old ~= nil and new ~= nil then -- 1611
				if Content:exist(old) and not Content:exist(new) then -- 1612
					local renamedDir = Content:isdir(old) -- 1613
					local parent = Path:getPath(new) -- 1614
					local files = Content:getFiles(parent) -- 1615
					if renamedDir then -- 1616
						local name = Path:getFilename(new):lower() -- 1617
						for _index_0 = 1, #files do -- 1618
							local file = files[_index_0] -- 1618
							if name == Path:getFilename(file):lower() then -- 1619
								return { -- 1620
									success = false -- 1620
								} -- 1620
							end -- 1619
						end -- 1618
					else -- 1622
						local name = Path:getName(new):lower() -- 1622
						local ext = Path:getExt(new) -- 1623
						for _index_0 = 1, #files do -- 1624
							local file = files[_index_0] -- 1624
							if name == Path:getName(file):lower() then -- 1625
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1626
									goto _continue_0 -- 1627
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1628
									goto _continue_0 -- 1629
								end -- 1626
								return { -- 1630
									success = false -- 1630
								} -- 1630
							end -- 1625
							::_continue_0:: -- 1625
						end -- 1624
					end -- 1616
					if Content:move(old, new) then -- 1631
						if renamedDir then -- 1632
							AgentSession.renameSessionsByProjectRoot(old, new) -- 1633
						end -- 1632
						local newParent = Path:getPath(new) -- 1634
						parent = Path:getPath(old) -- 1635
						files = Content:getFiles(parent) -- 1636
						local newName = Path:getName(new) -- 1637
						local oldName = Path:getName(old) -- 1638
						local name = oldName:lower() -- 1639
						local ext = Path:getExt(old) -- 1640
						for _index_0 = 1, #files do -- 1641
							local file = files[_index_0] -- 1641
							if name == Path:getName(file):lower() then -- 1642
								local _exp_0 = Path:getExt(file) -- 1643
								if "tl" == _exp_0 then -- 1643
									if ("vs" == ext) then -- 1643
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1644
									end -- 1643
								elseif "lua" == _exp_0 then -- 1645
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1645
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1646
									end -- 1645
								end -- 1643
							end -- 1642
						end -- 1641
						return { -- 1647
							success = true -- 1647
						} -- 1647
					end -- 1631
				end -- 1612
			end -- 1611
		end -- 1611
	end -- 1611
	return { -- 1610
		success = false -- 1610
	} -- 1610
end) -- 1610
HttpServer:post("/exist", function(req) -- 1649
	do -- 1650
		local _type_0 = type(req) -- 1650
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1650
		if _tab_0 then -- 1650
			local file -- 1650
			do -- 1650
				local _obj_0 = req.body -- 1650
				local _type_1 = type(_obj_0) -- 1650
				if "table" == _type_1 or "userdata" == _type_1 then -- 1650
					file = _obj_0.file -- 1650
				end -- 1650
			end -- 1650
			if file ~= nil then -- 1650
				do -- 1651
					local projFile = req.body.projFile -- 1651
					if projFile then -- 1651
						local projDir = getProjectDirFromFile(projFile) -- 1652
						if projDir then -- 1652
							local scriptDir = Path(projDir, "Script") -- 1653
							local searchPaths = Content.searchPaths -- 1654
							if Content:exist(scriptDir) then -- 1655
								Content:addSearchPath(scriptDir) -- 1655
							end -- 1655
							if Content:exist(projDir) then -- 1656
								Content:addSearchPath(projDir) -- 1656
							end -- 1656
							local _ <close> = setmetatable({ }, { -- 1657
								__close = function() -- 1657
									Content.searchPaths = searchPaths -- 1657
								end -- 1657
							}) -- 1657
							return { -- 1658
								success = Content:exist(file) -- 1658
							} -- 1658
						end -- 1652
					end -- 1651
				end -- 1651
				return { -- 1659
					success = Content:exist(file) -- 1659
				} -- 1659
			end -- 1650
		end -- 1650
	end -- 1650
	return { -- 1649
		success = false -- 1649
	} -- 1649
end) -- 1649
HttpServer:postSchedule("/read", function(req) -- 1661
	do -- 1662
		local _type_0 = type(req) -- 1662
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1662
		if _tab_0 then -- 1662
			local path -- 1662
			do -- 1662
				local _obj_0 = req.body -- 1662
				local _type_1 = type(_obj_0) -- 1662
				if "table" == _type_1 or "userdata" == _type_1 then -- 1662
					path = _obj_0.path -- 1662
				end -- 1662
			end -- 1662
			if path ~= nil then -- 1662
				local readFile -- 1663
				readFile = function() -- 1663
					if Content:exist(path) then -- 1664
						local content = Content:loadAsync(path) -- 1665
						if content then -- 1665
							return { -- 1666
								content = content, -- 1666
								success = true, -- 1666
								fullPath = Content:getFullPath(path) -- 1666
							} -- 1666
						end -- 1665
					end -- 1664
					return nil -- 1663
				end -- 1663
				do -- 1667
					local projFile = req.body.projFile -- 1667
					if projFile then -- 1667
						local projDir = getProjectDirFromFile(projFile) -- 1668
						if projDir then -- 1668
							local scriptDir = Path(projDir, "Script") -- 1669
							local searchPaths = Content.searchPaths -- 1670
							if Content:exist(scriptDir) then -- 1671
								Content:addSearchPath(scriptDir) -- 1671
							end -- 1671
							if Content:exist(projDir) then -- 1672
								Content:addSearchPath(projDir) -- 1672
							end -- 1672
							local _ <close> = setmetatable({ }, { -- 1673
								__close = function() -- 1673
									Content.searchPaths = searchPaths -- 1673
								end -- 1673
							}) -- 1673
							local result = readFile() -- 1674
							if result then -- 1674
								return result -- 1674
							end -- 1674
						end -- 1668
					end -- 1667
				end -- 1667
				local result = readFile() -- 1675
				if result then -- 1675
					return result -- 1675
				end -- 1675
			end -- 1662
		end -- 1662
	end -- 1662
	return { -- 1661
		success = false -- 1661
	} -- 1661
end) -- 1661
HttpServer:get("/read-sync", function(req) -- 1677
	do -- 1678
		local _type_0 = type(req) -- 1678
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1678
		if _tab_0 then -- 1678
			local params = req.params -- 1678
			if params ~= nil then -- 1678
				local path = params.path -- 1679
				local exts -- 1680
				if params.exts then -- 1680
					local _accum_0 = { } -- 1681
					local _len_0 = 1 -- 1681
					for ext in params.exts:gmatch("[^|]*") do -- 1681
						_accum_0[_len_0] = ext -- 1682
						_len_0 = _len_0 + 1 -- 1682
					end -- 1681
					exts = _accum_0 -- 1680
				else -- 1683
					exts = { -- 1683
						"" -- 1683
					} -- 1683
				end -- 1680
				local readFile -- 1684
				readFile = function() -- 1684
					for _index_0 = 1, #exts do -- 1685
						local ext = exts[_index_0] -- 1685
						local targetPath = path .. ext -- 1686
						if Content:exist(targetPath) then -- 1687
							local content = Content:load(targetPath) -- 1688
							if content then -- 1688
								return { -- 1689
									content = content, -- 1689
									success = true, -- 1689
									fullPath = Content:getFullPath(targetPath) -- 1689
								} -- 1689
							end -- 1688
						end -- 1687
					end -- 1685
					return nil -- 1684
				end -- 1684
				local searchPaths = Content.searchPaths -- 1690
				local _ <close> = setmetatable({ }, { -- 1691
					__close = function() -- 1691
						Content.searchPaths = searchPaths -- 1691
					end -- 1691
				}) -- 1691
				do -- 1692
					local projFile = req.params.projFile -- 1692
					if projFile then -- 1692
						local projDir = getProjectDirFromFile(projFile) -- 1693
						if projDir then -- 1693
							local scriptDir = Path(projDir, "Script") -- 1694
							if Content:exist(scriptDir) then -- 1695
								Content:addSearchPath(scriptDir) -- 1695
							end -- 1695
							if Content:exist(projDir) then -- 1696
								Content:addSearchPath(projDir) -- 1696
							end -- 1696
						else -- 1698
							projDir = Path:getPath(projFile) -- 1698
							if Content:exist(projDir) then -- 1699
								Content:addSearchPath(projDir) -- 1699
							end -- 1699
						end -- 1693
					end -- 1692
				end -- 1692
				local result = readFile() -- 1700
				if result then -- 1700
					return result -- 1700
				end -- 1700
			end -- 1678
		end -- 1678
	end -- 1678
	return { -- 1677
		success = false -- 1677
	} -- 1677
end) -- 1677
local compileFileAsync -- 1702
compileFileAsync = function(inputFile, sourceCodes) -- 1702
	local file = inputFile -- 1703
	local searchPath -- 1704
	do -- 1704
		local dir = getProjectDirFromFile(inputFile) -- 1704
		if dir then -- 1704
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 1705
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1706
		else -- 1708
			file = Path:getRelative(inputFile, Content.writablePath) -- 1708
			if file:sub(1, 2) == ".." then -- 1709
				file = Path:getRelative(inputFile, Content.assetPath) -- 1710
			end -- 1709
			searchPath = "" -- 1711
		end -- 1704
	end -- 1704
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1712
	local yueext = yue.options.extension -- 1713
	local resultCodes = nil -- 1714
	local resultError = nil -- 1715
	do -- 1716
		local _exp_0 = Path:getExt(inputFile) -- 1716
		if yueext == _exp_0 then -- 1716
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1717
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1718
				if not codes then -- 1719
					resultError = err -- 1720
					return -- 1721
				end -- 1719
				local extraGlobal -- 1722
				if isTIC80 then -- 1722
					extraGlobal = tic80APIs -- 1722
				else -- 1722
					extraGlobal = nil -- 1722
				end -- 1722
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1723
				if not success then -- 1724
					resultError = message -- 1725
					return -- 1726
				end -- 1724
				if codes == "" then -- 1727
					resultCodes = "" -- 1728
					return nil -- 1729
				end -- 1727
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1730
				return resultCodes -- 1731
			end, function(success) -- 1718
				if not success then -- 1732
					Content:remove(outputFile) -- 1733
					if resultCodes == nil then -- 1734
						resultCodes = false -- 1735
					end -- 1734
				end -- 1732
			end) -- 1718
		elseif "tl" == _exp_0 then -- 1736
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1737
			if isTIC80 then -- 1738
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1739
			end -- 1738
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1740
			if codes then -- 1740
				if isTIC80 then -- 1741
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1742
				end -- 1741
				resultCodes = codes -- 1743
				Content:saveAsync(outputFile, codes) -- 1744
			else -- 1746
				Content:remove(outputFile) -- 1746
				resultCodes = false -- 1747
				resultError = err -- 1748
			end -- 1740
		elseif "xml" == _exp_0 then -- 1749
			local codes, err = xml.tolua(sourceCodes) -- 1750
			if codes then -- 1750
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1751
				Content:saveAsync(outputFile, resultCodes) -- 1752
			else -- 1754
				Content:remove(outputFile) -- 1754
				resultCodes = false -- 1755
				resultError = err -- 1756
			end -- 1750
		end -- 1716
	end -- 1716
	wait(function() -- 1757
		return resultCodes ~= nil -- 1757
	end) -- 1757
	if resultCodes then -- 1758
		return resultCodes -- 1759
	else -- 1761
		return nil, resultError -- 1761
	end -- 1758
	return nil -- 1702
end -- 1702
HttpServer:postSchedule("/write", function(req) -- 1763
	do -- 1764
		local _type_0 = type(req) -- 1764
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1764
		if _tab_0 then -- 1764
			local path -- 1764
			do -- 1764
				local _obj_0 = req.body -- 1764
				local _type_1 = type(_obj_0) -- 1764
				if "table" == _type_1 or "userdata" == _type_1 then -- 1764
					path = _obj_0.path -- 1764
				end -- 1764
			end -- 1764
			local content -- 1764
			do -- 1764
				local _obj_0 = req.body -- 1764
				local _type_1 = type(_obj_0) -- 1764
				if "table" == _type_1 or "userdata" == _type_1 then -- 1764
					content = _obj_0.content -- 1764
				end -- 1764
			end -- 1764
			if path ~= nil and content ~= nil then -- 1764
				if Content:saveAsync(path, content) then -- 1765
					do -- 1766
						local _exp_0 = Path:getExt(path) -- 1766
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1766
							if '' == Path:getExt(Path:getName(path)) then -- 1767
								local resultCodes = compileFileAsync(path, content) -- 1768
								return { -- 1769
									success = true, -- 1769
									resultCodes = resultCodes -- 1769
								} -- 1769
							end -- 1767
						end -- 1766
					end -- 1766
					return { -- 1770
						success = true -- 1770
					} -- 1770
				end -- 1765
			end -- 1764
		end -- 1764
	end -- 1764
	return { -- 1763
		success = false -- 1763
	} -- 1763
end) -- 1763
local getWaProjectDirFromFile = nil -- 1772
HttpServer:postSchedule("/build", function(req) -- 1774
	do -- 1775
		local _type_0 = type(req) -- 1775
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1775
		if _tab_0 then -- 1775
			local path -- 1775
			do -- 1775
				local _obj_0 = req.body -- 1775
				local _type_1 = type(_obj_0) -- 1775
				if "table" == _type_1 or "userdata" == _type_1 then -- 1775
					path = _obj_0.path -- 1775
				end -- 1775
			end -- 1775
			if path ~= nil then -- 1775
				if Content:isdir(path) then -- 1776
					local projDir = getWaProjectDirFromFile(path) -- 1777
					if projDir then -- 1777
						local message = Wasm:buildWaAsync(projDir) -- 1778
						if message == "" then -- 1779
							return { -- 1780
								success = true -- 1780
							} -- 1780
						else -- 1782
							return { -- 1782
								success = false, -- 1782
								message = message -- 1782
							} -- 1782
						end -- 1779
					end -- 1777
				end -- 1776
				local _exp_0 = Path:getExt(path) -- 1783
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1784
					if '' == Path:getExt(Path:getName(path)) then -- 1785
						local content = Content:loadAsync(path) -- 1786
						if content then -- 1786
							local resultCodes = compileFileAsync(path, content) -- 1787
							if resultCodes then -- 1787
								return { -- 1788
									success = true, -- 1788
									resultCodes = resultCodes -- 1788
								} -- 1788
							end -- 1787
						end -- 1786
					end -- 1785
				elseif "wa" == _exp_0 then -- 1789
					local projDir = getWaProjectDirFromFile(path) -- 1790
					if projDir then -- 1790
						local message = Wasm:buildWaAsync(projDir) -- 1791
						if message == "" then -- 1792
							return { -- 1793
								success = true -- 1793
							} -- 1793
						else -- 1795
							return { -- 1795
								success = false, -- 1795
								message = message -- 1795
							} -- 1795
						end -- 1792
					else -- 1797
						return { -- 1797
							success = false, -- 1797
							message = 'Wa file needs a project' -- 1797
						} -- 1797
					end -- 1790
				end -- 1783
			end -- 1775
		end -- 1775
	end -- 1775
	return { -- 1774
		success = false -- 1774
	} -- 1774
end) -- 1774
local extentionLevels = { -- 1800
	vs = 2, -- 1800
	bl = 2, -- 1801
	ts = 1, -- 1802
	tsx = 1, -- 1803
	tl = 1, -- 1804
	yue = 1, -- 1805
	xml = 1, -- 1806
	lua = 0 -- 1807
} -- 1799
HttpServer:post("/assets", function() -- 1809
	local Entry = require("Script.Dev.Entry") -- 1812
	local engineDev = Entry.getEngineDev() -- 1813
	local visitAssets -- 1814
	visitAssets = function(path, tag) -- 1814
		local isWorkspace = tag == "Workspace" -- 1815
		local builtin -- 1816
		if tag == "Builtin" then -- 1816
			builtin = true -- 1816
		else -- 1816
			builtin = nil -- 1816
		end -- 1816
		local children = nil -- 1817
		local dirs = Content:getDirs(path) -- 1818
		for _index_0 = 1, #dirs do -- 1819
			local dir = dirs[_index_0] -- 1819
			if isWorkspace then -- 1820
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1821
					goto _continue_0 -- 1822
				end -- 1821
			elseif dir == ".git" then -- 1823
				goto _continue_0 -- 1824
			end -- 1820
			if not children then -- 1825
				children = { } -- 1825
			end -- 1825
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1826
			::_continue_0:: -- 1820
		end -- 1819
		local files = Content:getFiles(path) -- 1827
		local names = { } -- 1828
		for _index_0 = 1, #files do -- 1829
			local file = files[_index_0] -- 1829
			if (".DS_Store" == file) then -- 1830
				goto _continue_1 -- 1831
			end -- 1830
			local name = Path:getName(file) -- 1832
			local ext = names[name] -- 1833
			if ext then -- 1833
				local lv1 -- 1834
				do -- 1834
					local _exp_0 = extentionLevels[ext] -- 1834
					if _exp_0 ~= nil then -- 1834
						lv1 = _exp_0 -- 1834
					else -- 1834
						lv1 = -1 -- 1834
					end -- 1834
				end -- 1834
				ext = Path:getExt(file) -- 1835
				local lv2 -- 1836
				do -- 1836
					local _exp_0 = extentionLevels[ext] -- 1836
					if _exp_0 ~= nil then -- 1836
						lv2 = _exp_0 -- 1836
					else -- 1836
						lv2 = -1 -- 1836
					end -- 1836
				end -- 1836
				if lv2 > lv1 then -- 1837
					names[name] = ext -- 1838
				elseif lv2 == lv1 then -- 1839
					names[name .. '.' .. ext] = "" -- 1840
				end -- 1837
			else -- 1842
				ext = Path:getExt(file) -- 1842
				if not extentionLevels[ext] then -- 1843
					names[file] = "" -- 1844
				else -- 1846
					names[name] = ext -- 1846
				end -- 1843
			end -- 1833
			::_continue_1:: -- 1830
		end -- 1829
		do -- 1847
			local _accum_0 = { } -- 1847
			local _len_0 = 1 -- 1847
			for name, ext in pairs(names) do -- 1847
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1847
				_len_0 = _len_0 + 1 -- 1847
			end -- 1847
			files = _accum_0 -- 1847
		end -- 1847
		for _index_0 = 1, #files do -- 1848
			local file = files[_index_0] -- 1848
			if not children then -- 1849
				children = { } -- 1849
			end -- 1849
			children[#children + 1] = { -- 1851
				key = Path(path, file), -- 1851
				dir = false, -- 1852
				title = file, -- 1853
				builtin = builtin -- 1854
			} -- 1850
		end -- 1848
		if children then -- 1856
			table.sort(children, function(a, b) -- 1857
				if a.dir == b.dir then -- 1858
					return a.title < b.title -- 1859
				else -- 1861
					return a.dir -- 1861
				end -- 1858
			end) -- 1857
		end -- 1856
		if isWorkspace and children then -- 1862
			return children -- 1863
		else -- 1865
			return { -- 1866
				key = path, -- 1866
				dir = true, -- 1867
				title = Path:getFilename(path), -- 1868
				builtin = builtin, -- 1869
				children = children -- 1870
			} -- 1865
		end -- 1862
	end -- 1814
	local zh = (App.locale:match("^zh") ~= nil) -- 1872
	return { -- 1874
		key = Content.writablePath, -- 1874
		dir = true, -- 1875
		root = true, -- 1876
		title = "Assets", -- 1877
		children = (function() -- 1879
			local _tab_0 = { -- 1879
				{ -- 1880
					key = Path(Content.assetPath), -- 1880
					dir = true, -- 1881
					builtin = true, -- 1882
					title = zh and "内置资源" or "Built-in", -- 1883
					children = { -- 1885
						(function() -- 1885
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1885
							_with_0.title = zh and "说明文档" or "Readme" -- 1886
							return _with_0 -- 1885
						end)(), -- 1885
						(function() -- 1887
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1887
							_with_0.title = zh and "接口文档" or "API Doc" -- 1888
							return _with_0 -- 1887
						end)(), -- 1887
						(function() -- 1889
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1889
							_with_0.title = zh and "开发工具" or "Tools" -- 1890
							return _with_0 -- 1889
						end)(), -- 1889
						(function() -- 1891
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1891
							_with_0.title = zh and "字体" or "Font" -- 1892
							return _with_0 -- 1891
						end)(), -- 1891
						(function() -- 1893
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1893
							_with_0.title = zh and "程序库" or "Lib" -- 1894
							if engineDev then -- 1895
								local _list_0 = _with_0.children -- 1896
								for _index_0 = 1, #_list_0 do -- 1896
									local child = _list_0[_index_0] -- 1896
									if not (child.title == "Dora") then -- 1897
										goto _continue_0 -- 1897
									end -- 1897
									local title = zh and "zh-Hans" or "en" -- 1898
									do -- 1899
										local _accum_0 = { } -- 1899
										local _len_0 = 1 -- 1899
										local _list_1 = child.children -- 1899
										for _index_1 = 1, #_list_1 do -- 1899
											local c = _list_1[_index_1] -- 1899
											if c.title ~= title then -- 1899
												_accum_0[_len_0] = c -- 1899
												_len_0 = _len_0 + 1 -- 1899
											end -- 1899
										end -- 1899
										child.children = _accum_0 -- 1899
									end -- 1899
									break -- 1900
									::_continue_0:: -- 1897
								end -- 1896
							else -- 1902
								local _accum_0 = { } -- 1902
								local _len_0 = 1 -- 1902
								local _list_0 = _with_0.children -- 1902
								for _index_0 = 1, #_list_0 do -- 1902
									local child = _list_0[_index_0] -- 1902
									if child.title ~= "Dora" then -- 1902
										_accum_0[_len_0] = child -- 1902
										_len_0 = _len_0 + 1 -- 1902
									end -- 1902
								end -- 1902
								_with_0.children = _accum_0 -- 1902
							end -- 1895
							return _with_0 -- 1893
						end)(), -- 1893
						(function() -- 1903
							if engineDev then -- 1903
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1904
								local _obj_0 = _with_0.children -- 1905
								_obj_0[#_obj_0 + 1] = { -- 1906
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1906
									dir = false, -- 1907
									builtin = true, -- 1908
									title = "init.yue" -- 1909
								} -- 1905
								return _with_0 -- 1904
							end -- 1903
						end)() -- 1903
					} -- 1884
				} -- 1879
			} -- 1913
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1913
			local _idx_0 = #_tab_0 + 1 -- 1913
			for _index_0 = 1, #_obj_0 do -- 1913
				local _value_0 = _obj_0[_index_0] -- 1913
				_tab_0[_idx_0] = _value_0 -- 1913
				_idx_0 = _idx_0 + 1 -- 1913
			end -- 1913
			return _tab_0 -- 1879
		end)() -- 1878
	} -- 1873
end) -- 1809
HttpServer:post("/entry/list", function() -- 1917
	local Entry = require("Script.Dev.Entry") -- 1918
	local res = Entry.getLaunchEntries() -- 1919
	res.success = true -- 1920
	return res -- 1921
end) -- 1917
HttpServer:post("/run/status", function() -- 1923
	local Entry = require("Script.Dev.Entry") -- 1924
	return Entry.getCurrentEntryStatus() -- 1925
end) -- 1923
HttpServer:postSchedule("/run", function(req) -- 1927
	do -- 1928
		local _type_0 = type(req) -- 1928
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1928
		if _tab_0 then -- 1928
			local file -- 1928
			do -- 1928
				local _obj_0 = req.body -- 1928
				local _type_1 = type(_obj_0) -- 1928
				if "table" == _type_1 or "userdata" == _type_1 then -- 1928
					file = _obj_0.file -- 1928
				end -- 1928
			end -- 1928
			local asProj -- 1928
			do -- 1928
				local _obj_0 = req.body -- 1928
				local _type_1 = type(_obj_0) -- 1928
				if "table" == _type_1 or "userdata" == _type_1 then -- 1928
					asProj = _obj_0.asProj -- 1928
				end -- 1928
			end -- 1928
			if file ~= nil and asProj ~= nil then -- 1928
				if not Content:isAbsolutePath(file) then -- 1929
					local devFile = Path(Content.writablePath, file) -- 1930
					if Content:exist(devFile) then -- 1931
						file = devFile -- 1931
					end -- 1931
				end -- 1929
				local Entry = require("Script.Dev.Entry") -- 1932
				local workDir -- 1933
				if asProj then -- 1934
					workDir = getProjectDirFromFile(file) -- 1935
					if workDir then -- 1935
						Entry.allClear() -- 1936
						local target = Path(workDir, "init") -- 1937
						local success, err = Entry.enterEntryAsync({ -- 1938
							entryName = "Project", -- 1938
							fileName = target, -- 1938
							workDir = workDir, -- 1938
							projectRoot = workDir, -- 1938
							runKind = "project" -- 1938
						}) -- 1938
						target = Path:getName(Path:getPath(target)) -- 1939
						return { -- 1940
							success = success, -- 1940
							target = target, -- 1940
							err = err -- 1940
						} -- 1940
					end -- 1935
				else -- 1942
					workDir = getProjectDirFromFile(file) -- 1942
					if not workDir and Path:getExt(file) == "wasm" then -- 1943
						local parent = Path:getPath(file) -- 1944
						if Content:exist(Path(parent, "wa.mod")) then -- 1945
							workDir = parent -- 1946
						end -- 1945
					end -- 1943
				end -- 1934
				Entry.allClear() -- 1947
				file = Path:replaceExt(file, "") -- 1948
				local entry = { -- 1950
					entryName = Path:getName(file), -- 1950
					fileName = file, -- 1951
					runKind = "file" -- 1952
				} -- 1949
				if workDir then -- 1953
					entry.workDir = workDir -- 1954
					entry.projectRoot = workDir -- 1955
				end -- 1953
				local success, err = Entry.enterEntryAsync(entry) -- 1956
				return { -- 1957
					success = success, -- 1957
					err = err -- 1957
				} -- 1957
			end -- 1928
		end -- 1928
	end -- 1928
	return { -- 1927
		success = false -- 1927
	} -- 1927
end) -- 1927
HttpServer:postSchedule("/stop", function() -- 1959
	local Entry = require("Script.Dev.Entry") -- 1960
	return { -- 1961
		success = Entry.stop() -- 1961
	} -- 1961
end) -- 1959
local minifyAsync -- 1963
minifyAsync = function(sourcePath, minifyPath) -- 1963
	if not Content:exist(sourcePath) then -- 1964
		return -- 1964
	end -- 1964
	local Entry = require("Script.Dev.Entry") -- 1965
	local errors = { } -- 1966
	local files = Entry.getAllFiles(sourcePath, { -- 1967
		"lua" -- 1967
	}, true) -- 1967
	do -- 1968
		local _accum_0 = { } -- 1968
		local _len_0 = 1 -- 1968
		for _index_0 = 1, #files do -- 1968
			local file = files[_index_0] -- 1968
			if file:sub(1, 1) ~= '.' then -- 1968
				_accum_0[_len_0] = file -- 1968
				_len_0 = _len_0 + 1 -- 1968
			end -- 1968
		end -- 1968
		files = _accum_0 -- 1968
	end -- 1968
	local paths -- 1969
	do -- 1969
		local _tbl_0 = { } -- 1969
		for _index_0 = 1, #files do -- 1969
			local file = files[_index_0] -- 1969
			_tbl_0[Path:getPath(file)] = true -- 1969
		end -- 1969
		paths = _tbl_0 -- 1969
	end -- 1969
	for path in pairs(paths) do -- 1970
		Content:mkdir(Path(minifyPath, path)) -- 1970
	end -- 1970
	local _ <close> = setmetatable({ }, { -- 1971
		__close = function() -- 1971
			package.loaded["luaminify.FormatMini"] = nil -- 1972
			package.loaded["luaminify.ParseLua"] = nil -- 1973
			package.loaded["luaminify.Scope"] = nil -- 1974
			package.loaded["luaminify.Util"] = nil -- 1975
		end -- 1971
	}) -- 1971
	local FormatMini -- 1976
	do -- 1976
		local _obj_0 = require("luaminify") -- 1976
		FormatMini = _obj_0.FormatMini -- 1976
	end -- 1976
	local fileCount = #files -- 1977
	local count = 0 -- 1978
	for _index_0 = 1, #files do -- 1979
		local file = files[_index_0] -- 1979
		thread(function() -- 1980
			local _ <close> = setmetatable({ }, { -- 1981
				__close = function() -- 1981
					count = count + 1 -- 1981
				end -- 1981
			}) -- 1981
			local input = Path(sourcePath, file) -- 1982
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1983
			if Content:exist(input) then -- 1984
				local sourceCodes = Content:loadAsync(input) -- 1985
				local res, err = FormatMini(sourceCodes) -- 1986
				if res then -- 1987
					Content:saveAsync(output, res) -- 1988
					return print("Minify " .. tostring(file)) -- 1989
				else -- 1991
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1991
				end -- 1987
			else -- 1993
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1993
			end -- 1984
		end) -- 1980
		sleep() -- 1994
	end -- 1979
	wait(function() -- 1995
		return count == fileCount -- 1995
	end) -- 1995
	if #errors > 0 then -- 1996
		print(table.concat(errors, '\n')) -- 1997
	end -- 1996
	print("Obfuscation done.") -- 1998
	return files -- 1999
end -- 1963
local zipping = false -- 2001
HttpServer:postSchedule("/zip", function(req) -- 2003
	do -- 2004
		local _type_0 = type(req) -- 2004
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2004
		if _tab_0 then -- 2004
			local path -- 2004
			do -- 2004
				local _obj_0 = req.body -- 2004
				local _type_1 = type(_obj_0) -- 2004
				if "table" == _type_1 or "userdata" == _type_1 then -- 2004
					path = _obj_0.path -- 2004
				end -- 2004
			end -- 2004
			local zipFile -- 2004
			do -- 2004
				local _obj_0 = req.body -- 2004
				local _type_1 = type(_obj_0) -- 2004
				if "table" == _type_1 or "userdata" == _type_1 then -- 2004
					zipFile = _obj_0.zipFile -- 2004
				end -- 2004
			end -- 2004
			local obfuscated -- 2004
			do -- 2004
				local _obj_0 = req.body -- 2004
				local _type_1 = type(_obj_0) -- 2004
				if "table" == _type_1 or "userdata" == _type_1 then -- 2004
					obfuscated = _obj_0.obfuscated -- 2004
				end -- 2004
			end -- 2004
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2004
				if zipping then -- 2005
					goto failed -- 2005
				end -- 2005
				zipping = true -- 2006
				local _ <close> = setmetatable({ }, { -- 2007
					__close = function() -- 2007
						zipping = false -- 2007
					end -- 2007
				}) -- 2007
				if not Content:exist(path) then -- 2008
					goto failed -- 2008
				end -- 2008
				Content:mkdir(Path:getPath(zipFile)) -- 2009
				if obfuscated then -- 2010
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2011
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2012
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2013
					Content:remove(scriptPath) -- 2014
					Content:remove(obfuscatedPath) -- 2015
					Content:remove(tempPath) -- 2016
					Content:mkdir(scriptPath) -- 2017
					Content:mkdir(obfuscatedPath) -- 2018
					Content:mkdir(tempPath) -- 2019
					if not Content:copyAsync(path, tempPath) then -- 2020
						goto failed -- 2020
					end -- 2020
					local Entry = require("Script.Dev.Entry") -- 2021
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2022
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2023
						"tl", -- 2023
						"yue", -- 2023
						"lua", -- 2023
						"ts", -- 2023
						"tsx", -- 2023
						"vs", -- 2023
						"bl", -- 2023
						"xml", -- 2023
						"wa", -- 2023
						"mod" -- 2023
					}, true) -- 2023
					for _index_0 = 1, #scriptFiles do -- 2024
						local file = scriptFiles[_index_0] -- 2024
						Content:remove(Path(tempPath, file)) -- 2025
					end -- 2024
					for _index_0 = 1, #luaFiles do -- 2026
						local file = luaFiles[_index_0] -- 2026
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2027
					end -- 2026
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2028
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2029
					end) then -- 2028
						goto failed -- 2028
					end -- 2028
					return { -- 2030
						success = true -- 2030
					} -- 2030
				else -- 2032
					return { -- 2032
						success = Content:zipAsync(path, zipFile, function(file) -- 2032
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2033
						end) -- 2032
					} -- 2032
				end -- 2010
			end -- 2004
		end -- 2004
	end -- 2004
	::failed:: -- 2034
	return { -- 2003
		success = false -- 2003
	} -- 2003
end) -- 2003
HttpServer:postSchedule("/unzip", function(req) -- 2036
	do -- 2037
		local _type_0 = type(req) -- 2037
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2037
		if _tab_0 then -- 2037
			local zipFile -- 2037
			do -- 2037
				local _obj_0 = req.body -- 2037
				local _type_1 = type(_obj_0) -- 2037
				if "table" == _type_1 or "userdata" == _type_1 then -- 2037
					zipFile = _obj_0.zipFile -- 2037
				end -- 2037
			end -- 2037
			local path -- 2037
			do -- 2037
				local _obj_0 = req.body -- 2037
				local _type_1 = type(_obj_0) -- 2037
				if "table" == _type_1 or "userdata" == _type_1 then -- 2037
					path = _obj_0.path -- 2037
				end -- 2037
			end -- 2037
			if zipFile ~= nil and path ~= nil then -- 2037
				return { -- 2038
					success = Content:unzipAsync(zipFile, path, function(file) -- 2038
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2039
					end) -- 2038
				} -- 2038
			end -- 2037
		end -- 2037
	end -- 2037
	return { -- 2036
		success = false -- 2036
	} -- 2036
end) -- 2036
HttpServer:post("/editing-info", function(req) -- 2041
	local Entry = require("Script.Dev.Entry") -- 2042
	local config = Entry.getConfig() -- 2043
	local _type_0 = type(req) -- 2044
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2044
	local _match_0 = false -- 2044
	if _tab_0 then -- 2044
		local editingInfo -- 2044
		do -- 2044
			local _obj_0 = req.body -- 2044
			local _type_1 = type(_obj_0) -- 2044
			if "table" == _type_1 or "userdata" == _type_1 then -- 2044
				editingInfo = _obj_0.editingInfo -- 2044
			end -- 2044
		end -- 2044
		if editingInfo ~= nil then -- 2044
			_match_0 = true -- 2044
			config.editingInfo = editingInfo -- 2045
			return { -- 2046
				success = true -- 2046
			} -- 2046
		end -- 2044
	end -- 2044
	if not _match_0 then -- 2044
		if not (config.editingInfo ~= nil) then -- 2048
			local folder -- 2049
			if App.locale:match('^zh') then -- 2049
				folder = 'zh-Hans' -- 2049
			else -- 2049
				folder = 'en' -- 2049
			end -- 2049
			config.editingInfo = json.encode({ -- 2051
				index = 0, -- 2051
				files = { -- 2053
					{ -- 2054
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2054
						title = "welcome.md" -- 2055
					} -- 2053
				} -- 2052
			}) -- 2050
		end -- 2048
		return { -- 2059
			success = true, -- 2059
			editingInfo = config.editingInfo -- 2059
		} -- 2059
	end -- 2044
end) -- 2041
HttpServer:post("/command", function(req) -- 2061
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
			local log -- 2062
			do -- 2062
				local _obj_0 = req.body -- 2062
				local _type_1 = type(_obj_0) -- 2062
				if "table" == _type_1 or "userdata" == _type_1 then -- 2062
					log = _obj_0.log -- 2062
				end -- 2062
			end -- 2062
			if code ~= nil and log ~= nil then -- 2062
				emit("AppCommand", code, log) -- 2063
				return { -- 2064
					success = true -- 2064
				} -- 2064
			end -- 2062
		end -- 2062
	end -- 2062
	return { -- 2061
		success = false -- 2061
	} -- 2061
end) -- 2061
HttpServer:post("/log/save", function() -- 2066
	local folder = ".download" -- 2067
	local fullLogFile = "dora_full_logs.txt" -- 2068
	local fullFolder = Path(Content.writablePath, folder) -- 2069
	Content:mkdir(fullFolder) -- 2070
	local logPath = Path(fullFolder, fullLogFile) -- 2071
	if App:saveLog(logPath) then -- 2072
		return { -- 2073
			success = true, -- 2073
			path = Path(folder, fullLogFile) -- 2073
		} -- 2073
	end -- 2072
	return { -- 2066
		success = false -- 2066
	} -- 2066
end) -- 2066
HttpServer:post("/yarn/check", function(req) -- 2075
	local yarncompile = require("yarncompile") -- 2076
	do -- 2077
		local _type_0 = type(req) -- 2077
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2077
		if _tab_0 then -- 2077
			local code -- 2077
			do -- 2077
				local _obj_0 = req.body -- 2077
				local _type_1 = type(_obj_0) -- 2077
				if "table" == _type_1 or "userdata" == _type_1 then -- 2077
					code = _obj_0.code -- 2077
				end -- 2077
			end -- 2077
			if code ~= nil then -- 2077
				local jsonObject = json.decode(code) -- 2078
				if jsonObject then -- 2078
					local errors = { } -- 2079
					local _list_0 = jsonObject.nodes -- 2080
					for _index_0 = 1, #_list_0 do -- 2080
						local node = _list_0[_index_0] -- 2080
						local title, body = node.title, node.body -- 2081
						local luaCode, err = yarncompile(body) -- 2082
						if not luaCode then -- 2082
							errors[#errors + 1] = title .. ":" .. err -- 2083
						end -- 2082
					end -- 2080
					return { -- 2084
						success = true, -- 2084
						syntaxError = table.concat(errors, "\n\n") -- 2084
					} -- 2084
				end -- 2078
			end -- 2077
		end -- 2077
	end -- 2077
	return { -- 2075
		success = false -- 2075
	} -- 2075
end) -- 2075
HttpServer:post("/yarn/check-file", function(req) -- 2086
	local yarncompile = require("yarncompile") -- 2087
	do -- 2088
		local _type_0 = type(req) -- 2088
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2088
		if _tab_0 then -- 2088
			local code -- 2088
			do -- 2088
				local _obj_0 = req.body -- 2088
				local _type_1 = type(_obj_0) -- 2088
				if "table" == _type_1 or "userdata" == _type_1 then -- 2088
					code = _obj_0.code -- 2088
				end -- 2088
			end -- 2088
			if code ~= nil then -- 2088
				local res, _, err = yarncompile(code, true) -- 2089
				if not res then -- 2089
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2090
					return { -- 2091
						success = false, -- 2091
						message = message, -- 2091
						line = line, -- 2091
						column = column, -- 2091
						node = node -- 2091
					} -- 2091
				end -- 2089
			end -- 2088
		end -- 2088
	end -- 2088
	return { -- 2086
		success = true -- 2086
	} -- 2086
end) -- 2086
getWaProjectDirFromFile = function(file) -- 2093
	local current -- 2094
	if Content:isdir(file) then -- 2094
		current = file -- 2094
	else -- 2094
		current = Path:getPath(file) -- 2094
	end -- 2094
	if current == "" then -- 2095
		return nil -- 2095
	end -- 2095
	repeat -- 2096
		local modPath = Path(current, "wa.mod") -- 2097
		if Content:exist(modPath) then -- 2098
			return current, modPath -- 2099
		end -- 2098
		local parent = Path:getPath(current) -- 2100
		if parent == "" or parent == current then -- 2101
			break -- 2101
		end -- 2101
		current = parent -- 2102
	until false -- 2096
	return nil -- 2104
end -- 2093
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2106
	do -- 2107
		local _type_0 = type(req) -- 2107
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2107
		if _tab_0 then -- 2107
			local path -- 2107
			do -- 2107
				local _obj_0 = req.body -- 2107
				local _type_1 = type(_obj_0) -- 2107
				if "table" == _type_1 or "userdata" == _type_1 then -- 2107
					path = _obj_0.path -- 2107
				end -- 2107
			end -- 2107
			if path ~= nil then -- 2107
				local projDir = getWaProjectDirFromFile(path) -- 2108
				if projDir then -- 2108
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2109
					if not Content:exist(sourceDoraPath) then -- 2110
						return { -- 2111
							success = false, -- 2111
							message = "missing dora template" -- 2111
						} -- 2111
					end -- 2110
					local targetVendorPath = Path(projDir, "vendor") -- 2112
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2113
					if not Content:exist(targetVendorPath) then -- 2114
						if not Content:mkdir(targetVendorPath) then -- 2115
							return { -- 2116
								success = false, -- 2116
								message = "failed to create vendor folder" -- 2116
							} -- 2116
						end -- 2115
					elseif not Content:isdir(targetVendorPath) then -- 2117
						return { -- 2118
							success = false, -- 2118
							message = "vendor path is not a folder" -- 2118
						} -- 2118
					end -- 2114
					if Content:exist(targetDoraPath) then -- 2119
						if not Content:remove(targetDoraPath) then -- 2120
							return { -- 2121
								success = false, -- 2121
								message = "failed to remove old dora" -- 2121
							} -- 2121
						end -- 2120
					end -- 2119
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2122
						return { -- 2123
							success = false, -- 2123
							message = "failed to copy dora" -- 2123
						} -- 2123
					end -- 2122
					return { -- 2124
						success = true -- 2124
					} -- 2124
				else -- 2126
					return { -- 2126
						success = false, -- 2126
						message = 'Wa file needs a project' -- 2126
					} -- 2126
				end -- 2108
			end -- 2107
		end -- 2107
	end -- 2107
	return { -- 2106
		success = false, -- 2106
		message = "invalid call" -- 2106
	} -- 2106
end) -- 2106
HttpServer:postSchedule("/wa/build", function(req) -- 2128
	do -- 2129
		local _type_0 = type(req) -- 2129
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2129
		if _tab_0 then -- 2129
			local path -- 2129
			do -- 2129
				local _obj_0 = req.body -- 2129
				local _type_1 = type(_obj_0) -- 2129
				if "table" == _type_1 or "userdata" == _type_1 then -- 2129
					path = _obj_0.path -- 2129
				end -- 2129
			end -- 2129
			if path ~= nil then -- 2129
				local projDir = getWaProjectDirFromFile(path) -- 2130
				if projDir then -- 2130
					local message = Wasm:buildWaAsync(projDir) -- 2131
					if message == "" then -- 2132
						return { -- 2133
							success = true -- 2133
						} -- 2133
					else -- 2135
						return { -- 2135
							success = false, -- 2135
							message = message -- 2135
						} -- 2135
					end -- 2132
				else -- 2137
					return { -- 2137
						success = false, -- 2137
						message = 'Wa file needs a project' -- 2137
					} -- 2137
				end -- 2130
			end -- 2129
		end -- 2129
	end -- 2129
	return { -- 2138
		success = false, -- 2138
		message = 'failed to build' -- 2138
	} -- 2138
end) -- 2128
HttpServer:postSchedule("/wa/format", function(req) -- 2140
	do -- 2141
		local _type_0 = type(req) -- 2141
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2141
		if _tab_0 then -- 2141
			local file -- 2141
			do -- 2141
				local _obj_0 = req.body -- 2141
				local _type_1 = type(_obj_0) -- 2141
				if "table" == _type_1 or "userdata" == _type_1 then -- 2141
					file = _obj_0.file -- 2141
				end -- 2141
			end -- 2141
			if file ~= nil then -- 2141
				local code = Wasm:formatWaAsync(file) -- 2142
				if code == "" then -- 2143
					return { -- 2144
						success = false -- 2144
					} -- 2144
				else -- 2146
					return { -- 2146
						success = true, -- 2146
						code = code -- 2146
					} -- 2146
				end -- 2143
			end -- 2141
		end -- 2141
	end -- 2141
	return { -- 2147
		success = false -- 2147
	} -- 2147
end) -- 2140
HttpServer:postSchedule("/wa/create", function(req) -- 2149
	do -- 2150
		local _type_0 = type(req) -- 2150
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2150
		if _tab_0 then -- 2150
			local path -- 2150
			do -- 2150
				local _obj_0 = req.body -- 2150
				local _type_1 = type(_obj_0) -- 2150
				if "table" == _type_1 or "userdata" == _type_1 then -- 2150
					path = _obj_0.path -- 2150
				end -- 2150
			end -- 2150
			if path ~= nil then -- 2150
				if not Content:exist(Path:getPath(path)) then -- 2151
					return { -- 2152
						success = false, -- 2152
						message = "target path not existed" -- 2152
					} -- 2152
				end -- 2151
				if Content:exist(path) then -- 2153
					return { -- 2154
						success = false, -- 2154
						message = "target project folder existed" -- 2154
					} -- 2154
				end -- 2153
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2155
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2156
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2157
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2158
					return { -- 2161
						success = false, -- 2161
						message = "missing template project" -- 2161
					} -- 2161
				end -- 2158
				if not Content:mkdir(path) then -- 2162
					return { -- 2163
						success = false, -- 2163
						message = "failed to create project folder" -- 2163
					} -- 2163
				end -- 2162
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2164
					Content:remove(path) -- 2165
					return { -- 2166
						success = false, -- 2166
						message = "failed to copy template" -- 2166
					} -- 2166
				end -- 2164
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2167
					Content:remove(path) -- 2168
					return { -- 2169
						success = false, -- 2169
						message = "failed to copy template" -- 2169
					} -- 2169
				end -- 2167
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2170
					Content:remove(path) -- 2171
					return { -- 2172
						success = false, -- 2172
						message = "failed to copy template" -- 2172
					} -- 2172
				end -- 2170
				return { -- 2173
					success = true -- 2173
				} -- 2173
			end -- 2150
		end -- 2150
	end -- 2150
	return { -- 2149
		success = false, -- 2149
		message = "invalid call" -- 2149
	} -- 2149
end) -- 2149
local tsBuildGlobs = { -- 2176
	"**/*.ts", -- 2176
	"**/*.tsx", -- 2177
	"!**/.*/**", -- 2178
	"!**/node_modules/**" -- 2179
} -- 2175
local _anon_func_6 = function(path) -- 2188
	local _val_0 = Path:getExt(path) -- 2188
	return "ts" == _val_0 or "tsx" == _val_0 -- 2188
end -- 2188
HttpServer:postSchedule("/ts/build", function(req) -- 2181
	do -- 2182
		local _type_0 = type(req) -- 2182
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2182
		if _tab_0 then -- 2182
			local path -- 2182
			do -- 2182
				local _obj_0 = req.body -- 2182
				local _type_1 = type(_obj_0) -- 2182
				if "table" == _type_1 or "userdata" == _type_1 then -- 2182
					path = _obj_0.path -- 2182
				end -- 2182
			end -- 2182
			if path ~= nil then -- 2182
				if HttpServer.wsConnectionCount == 0 then -- 2183
					return { -- 2184
						success = false, -- 2184
						message = "Web IDE not connected" -- 2184
					} -- 2184
				end -- 2183
				if not Content:exist(path) then -- 2185
					return { -- 2186
						success = false, -- 2186
						message = "path not existed" -- 2186
					} -- 2186
				end -- 2185
				if not Content:isdir(path) then -- 2187
					if not (_anon_func_6(path)) then -- 2188
						return { -- 2189
							success = false, -- 2189
							message = "expecting a TypeScript file" -- 2189
						} -- 2189
					end -- 2188
					local messages = { } -- 2190
					local content = Content:load(path) -- 2191
					if not content then -- 2192
						return { -- 2193
							success = false, -- 2193
							message = "failed to read file" -- 2193
						} -- 2193
					end -- 2192
					emit("AppWS", "Send", json.encode({ -- 2194
						name = "UpdateFile", -- 2194
						file = path, -- 2194
						exists = true, -- 2194
						content = content -- 2194
					})) -- 2194
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2195
						local done = false -- 2196
						do -- 2197
							local _with_0 = Node() -- 2197
							_with_0:gslot("AppWS", function(event) -- 2198
								if event.type == "Receive" then -- 2199
									local res = json.decode(event.msg) -- 2200
									if res then -- 2200
										if res.name == "TranspileTS" and res.file == path then -- 2201
											_with_0:removeFromParent() -- 2202
											if res.success then -- 2203
												local luaFile = Path:replaceExt(path, "lua") -- 2204
												Content:save(luaFile, res.luaCode) -- 2205
												messages[#messages + 1] = { -- 2206
													success = true, -- 2206
													file = path -- 2206
												} -- 2206
											else -- 2208
												messages[#messages + 1] = { -- 2208
													success = false, -- 2208
													file = path, -- 2208
													message = res.message -- 2208
												} -- 2208
											end -- 2203
											done = true -- 2209
										end -- 2201
									end -- 2200
								end -- 2199
							end) -- 2198
						end -- 2197
						emit("AppWS", "Send", json.encode({ -- 2210
							name = "TranspileTS", -- 2210
							file = path, -- 2210
							content = content -- 2210
						})) -- 2210
						wait(function() -- 2211
							return done -- 2211
						end) -- 2211
					end -- 2195
					return { -- 2212
						success = true, -- 2212
						messages = messages -- 2212
					} -- 2212
				else -- 2214
					local fileData = { } -- 2214
					local messages = { } -- 2215
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2216
					for _index_0 = 1, #_list_0 do -- 2216
						local subFile = _list_0[_index_0] -- 2216
						local file = Path(path, subFile) -- 2217
						local content = Content:load(file) -- 2218
						if content then -- 2218
							fileData[file] = content -- 2219
							emit("AppWS", "Send", json.encode({ -- 2220
								name = "UpdateFile", -- 2220
								file = file, -- 2220
								exists = true, -- 2220
								content = content -- 2220
							})) -- 2220
						else -- 2222
							messages[#messages + 1] = { -- 2222
								success = false, -- 2222
								file = file, -- 2222
								message = "failed to read file" -- 2222
							} -- 2222
						end -- 2218
					end -- 2216
					for file, content in pairs(fileData) do -- 2223
						if "d" == Path:getExt(Path:getName(file)) then -- 2224
							goto _continue_0 -- 2224
						end -- 2224
						local done = false -- 2225
						do -- 2226
							local _with_0 = Node() -- 2226
							_with_0:gslot("AppWS", function(event) -- 2227
								if event.type == "Receive" then -- 2228
									local res = json.decode(event.msg) -- 2229
									if res then -- 2229
										if res.name == "TranspileTS" and res.file == file then -- 2230
											_with_0:removeFromParent() -- 2231
											if res.success then -- 2232
												local luaFile = Path:replaceExt(file, "lua") -- 2233
												Content:save(luaFile, res.luaCode) -- 2234
												messages[#messages + 1] = { -- 2235
													success = true, -- 2235
													file = file -- 2235
												} -- 2235
											else -- 2237
												messages[#messages + 1] = { -- 2237
													success = false, -- 2237
													file = file, -- 2237
													message = res.message -- 2237
												} -- 2237
											end -- 2232
											done = true -- 2238
										end -- 2230
									end -- 2229
								end -- 2228
							end) -- 2227
						end -- 2226
						emit("AppWS", "Send", json.encode({ -- 2239
							name = "TranspileTS", -- 2239
							file = file, -- 2239
							content = content -- 2239
						})) -- 2239
						wait(function() -- 2240
							return done -- 2240
						end) -- 2240
						::_continue_0:: -- 2224
					end -- 2223
					return { -- 2241
						success = true, -- 2241
						messages = messages -- 2241
					} -- 2241
				end -- 2187
			end -- 2182
		end -- 2182
	end -- 2182
	return { -- 2181
		success = false -- 2181
	} -- 2181
end) -- 2181
HttpServer:post("/download", function(req) -- 2243
	do -- 2244
		local _type_0 = type(req) -- 2244
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2244
		if _tab_0 then -- 2244
			local url -- 2244
			do -- 2244
				local _obj_0 = req.body -- 2244
				local _type_1 = type(_obj_0) -- 2244
				if "table" == _type_1 or "userdata" == _type_1 then -- 2244
					url = _obj_0.url -- 2244
				end -- 2244
			end -- 2244
			local target -- 2244
			do -- 2244
				local _obj_0 = req.body -- 2244
				local _type_1 = type(_obj_0) -- 2244
				if "table" == _type_1 or "userdata" == _type_1 then -- 2244
					target = _obj_0.target -- 2244
				end -- 2244
			end -- 2244
			if url ~= nil and target ~= nil then -- 2244
				local Entry = require("Script.Dev.Entry") -- 2245
				Entry.downloadFile(url, target) -- 2246
				return { -- 2247
					success = true -- 2247
				} -- 2247
			end -- 2244
		end -- 2244
	end -- 2244
	return { -- 2243
		success = false -- 2243
	} -- 2243
end) -- 2243
local isDesktopPlatform -- 2249
isDesktopPlatform = function() -- 2249
	local _val_0 = App.platform -- 2250
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2250
end -- 2249
local getServerStatus -- 2252
getServerStatus = function() -- 2252
	local Entry = require("Script.Dev.Entry") -- 2253
	local running = Entry.getCurrentEntryStatus() -- 2254
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2255
	return { -- 2257
		success = true, -- 2257
		platform = App.platform, -- 2258
		locale = App.locale, -- 2259
		version = App.version, -- 2260
		url = "http://localhost:8866", -- 2261
		wsConnectionCount = HttpServer.wsConnectionCount, -- 2262
		webIDEConnected = HttpServer.wsConnectionCount > 0, -- 2263
		assetPath = Content.assetPath, -- 2264
		writablePath = Content.writablePath, -- 2265
		waTemplateReady = waTemplateReady, -- 2266
		running = running -- 2267
	} -- 2256
end -- 2252
HttpServer:post("/status", function() -- 2270
	return getServerStatus() -- 2271
end) -- 2270
HttpServer:post("/doctor/fix", function(req) -- 2273
	do -- 2274
		local _type_0 = type(req) -- 2274
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2274
		if _tab_0 then -- 2274
			local openWebIDE -- 2274
			do -- 2274
				local _obj_0 = req.body -- 2274
				local _type_1 = type(_obj_0) -- 2274
				if "table" == _type_1 or "userdata" == _type_1 then -- 2274
					openWebIDE = _obj_0.openWebIDE -- 2274
				end -- 2274
			end -- 2274
			if openWebIDE ~= nil then -- 2274
				if not openWebIDE then -- 2275
					return { -- 2276
						success = false, -- 2276
						message = "nothing to fix" -- 2276
					} -- 2276
				end -- 2275
				local status = getServerStatus() -- 2277
				if status.webIDEConnected then -- 2278
					return { -- 2279
						success = true, -- 2279
						fixed = false, -- 2279
						message = "Web IDE already connected.", -- 2279
						status = status -- 2279
					} -- 2279
				end -- 2278
				if not isDesktopPlatform() then -- 2280
					return { -- 2281
						success = false, -- 2281
						message = "opening Web IDE is only supported on desktop platforms", -- 2281
						status = status -- 2281
					} -- 2281
				end -- 2280
				local url = "http://localhost:8866" -- 2282
				App:openURL(url) -- 2283
				status.openedURL = url -- 2284
				return { -- 2285
					success = true, -- 2285
					fixed = true, -- 2285
					message = "Opened Web IDE in the local browser.", -- 2285
					url = url, -- 2285
					status = status -- 2285
				} -- 2285
			end -- 2274
		end -- 2274
	end -- 2274
	return { -- 2273
		success = false, -- 2273
		message = "invalid call" -- 2273
	} -- 2273
end) -- 2273
local status = { } -- 2287
_module_0 = status -- 2288
status.buildAsync = function(path) -- 2290
	if not Content:exist(path) then -- 2291
		return { -- 2292
			success = false, -- 2292
			file = path, -- 2292
			message = "file not existed" -- 2292
		} -- 2292
	end -- 2291
	do -- 2293
		local _exp_0 = Path:getExt(path) -- 2293
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2293
			if '' == Path:getExt(Path:getName(path)) then -- 2294
				local content = Content:loadAsync(path) -- 2295
				if content then -- 2295
					local resultCodes, err = compileFileAsync(path, content) -- 2296
					if resultCodes then -- 2296
						return { -- 2297
							success = true, -- 2297
							file = path -- 2297
						} -- 2297
					else -- 2299
						return { -- 2299
							success = false, -- 2299
							file = path, -- 2299
							message = err -- 2299
						} -- 2299
					end -- 2296
				end -- 2295
			end -- 2294
		elseif "lua" == _exp_0 then -- 2300
			local content = Content:loadAsync(path) -- 2301
			if content then -- 2301
				do -- 2302
					local isTIC80 = CheckTIC80Code(content) -- 2302
					if isTIC80 then -- 2302
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2303
					end -- 2302
				end -- 2302
				local success, info -- 2304
				do -- 2304
					local _obj_0 = luaCheck(path, content) -- 2304
					success, info = _obj_0.success, _obj_0.info -- 2304
				end -- 2304
				if success then -- 2305
					return { -- 2306
						success = true, -- 2306
						file = path -- 2306
					} -- 2306
				elseif info and #info > 0 then -- 2307
					local messages = { } -- 2308
					for _index_0 = 1, #info do -- 2309
						local _des_0 = info[_index_0] -- 2309
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2309
						local lineText = "" -- 2310
						if line then -- 2311
							local currentLine = 1 -- 2312
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2313
								if currentLine == line then -- 2314
									lineText = text -- 2315
									break -- 2316
								end -- 2314
								currentLine = currentLine + 1 -- 2317
							end -- 2313
						end -- 2311
						if line then -- 2318
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2319
						else -- 2321
							messages[#messages + 1] = message -- 2321
						end -- 2318
					end -- 2309
					return { -- 2322
						success = false, -- 2322
						file = path, -- 2322
						message = table.concat(messages, "\n") -- 2322
					} -- 2322
				else -- 2324
					return { -- 2324
						success = false, -- 2324
						file = path, -- 2324
						message = "lua check failed" -- 2324
					} -- 2324
				end -- 2305
			end -- 2301
		elseif "yarn" == _exp_0 then -- 2325
			local content = Content:loadAsync(path) -- 2326
			if content then -- 2326
				local res, _, err = yarncompile(content, true) -- 2327
				if res then -- 2327
					return { -- 2328
						success = true, -- 2328
						file = path -- 2328
					} -- 2328
				else -- 2330
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2330
					local lineText = "" -- 2331
					if line then -- 2332
						local currentLine = 1 -- 2333
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2334
							if currentLine == line then -- 2335
								lineText = text -- 2336
								break -- 2337
							end -- 2335
							currentLine = currentLine + 1 -- 2338
						end -- 2334
					end -- 2332
					if node ~= "" then -- 2339
						node = "node: " .. tostring(node) .. ", " -- 2340
					else -- 2341
						node = "" -- 2341
					end -- 2339
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2342
					return { -- 2343
						success = false, -- 2343
						file = path, -- 2343
						message = message -- 2343
					} -- 2343
				end -- 2327
			end -- 2326
		end -- 2293
	end -- 2293
	return { -- 2344
		success = false, -- 2344
		file = path, -- 2344
		message = "invalid file to build" -- 2344
	} -- 2344
end -- 2290
thread(function() -- 2346
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 2347
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 2348
	if Content:exist(doraWeb) then -- 2349
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) -- 2350
		local needReload -- 2351
		if Content:exist(doraReady) then -- 2351
			needReload = readyContent ~= Content:load(doraReady) -- 2352
		else -- 2353
			needReload = true -- 2353
		end -- 2351
		if needReload then -- 2354
			Content:remove(Path(Content.appPath, ".www")) -- 2355
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 2356
			Content:save(doraReady, readyContent) -- 2360
			print("Dora Dora is ready!") -- 2361
		end -- 2354
	end -- 2349
	if HttpServer:start(8866) then -- 2362
		local localIP = HttpServer.localIP -- 2363
		if localIP == "" then -- 2364
			localIP = "localhost" -- 2364
		end -- 2364
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 2365
		return HttpServer:startWS(8868) -- 2366
	else -- 2368
		status.url = nil -- 2368
		return print("8866 Port not available!") -- 2369
	end -- 2362
end) -- 2346
return _module_0 -- 1
