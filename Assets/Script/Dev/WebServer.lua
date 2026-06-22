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
local relativeToRoot -- 106
relativeToRoot = function(file, root) -- 106
	if not (file and file ~= "" and root and root ~= "") then -- 107
		return nil -- 107
	end -- 107
	if file == root then -- 108
		return "" -- 108
	end -- 108
	local prefix = root -- 109
	if not (prefix:sub(-1) == "/") then -- 110
		prefix = prefix .. "/" -- 110
	end -- 110
	if file:sub(1, #prefix) == prefix then -- 111
		return file:sub(#prefix + 1) -- 112
	else -- 114
		return nil -- 114
	end -- 111
end -- 106
local isProjectRootDir -- 116
isProjectRootDir = function(dir) -- 116
	if not (dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir)) then -- 117
		return false -- 117
	end -- 117
	local _list_0 = Content:getFiles(dir) -- 118
	for _index_0 = 1, #_list_0 do -- 118
		local f = _list_0[_index_0] -- 118
		if Path:getName(f):lower() == "init" then -- 119
			return true -- 120
		end -- 119
	end -- 118
	return false -- 121
end -- 116
local getProjectRootFromPath -- 123
getProjectRootFromPath = function(target, isDir) -- 123
	if isDir == nil then -- 123
		isDir = false -- 123
	end -- 123
	if not (target and target ~= "" and Content:isAbsolutePath(target)) then -- 124
		return nil, "invalid path" -- 124
	end -- 124
	if isDir then -- 125
		if isProjectRootDir(target) then -- 126
			return target -- 126
		end -- 126
		return getProjectDirFromFile(Path(target, "__dora_project_root_search__.lua"), "current directory does not belong to any project") -- 127
	end -- 125
	return getProjectDirFromFile(target, "current file does not belong to any project") -- 128
end -- 123
local invalidArguments = { -- 130
	success = false, -- 130
	message = "invalid arguments" -- 130
} -- 130
HttpServer:post("/agent/project-root", function(req) -- 132
	do -- 133
		local _type_0 = type(req) -- 133
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 133
		if _tab_0 then -- 133
			local path -- 133
			do -- 133
				local _obj_0 = req.body -- 133
				local _type_1 = type(_obj_0) -- 133
				if "table" == _type_1 or "userdata" == _type_1 then -- 133
					path = _obj_0.path -- 133
				end -- 133
			end -- 133
			local isDir -- 133
			do -- 133
				local _obj_0 = req.body -- 133
				local _type_1 = type(_obj_0) -- 133
				if "table" == _type_1 or "userdata" == _type_1 then -- 133
					isDir = _obj_0.isDir -- 133
				end -- 133
			end -- 133
			if path ~= nil and isDir ~= nil then -- 133
				local projectRoot, err = getProjectRootFromPath(path, isDir) -- 134
				if projectRoot then -- 134
					return { -- 135
						success = true, -- 135
						found = true, -- 135
						projectRoot = projectRoot, -- 135
						title = Path:getFilename(projectRoot) -- 135
					} -- 135
				else -- 137
					return { -- 137
						success = true, -- 137
						found = false, -- 137
						message = err -- 137
					} -- 137
				end -- 134
			end -- 133
		end -- 133
	end -- 133
	return invalidArguments -- 132
end) -- 132
local AgentTools = require("Agent.Tools") -- 139
local AgentSession = require("Agent.AgentSession") -- 140
local GitJobs = { } -- 142
local gitTerminalState -- 144
gitTerminalState = function(status) -- 144
	if not (status and status.state) then -- 145
		return false -- 145
	end -- 145
	local _val_0 = status.state -- 146
	return "done" == _val_0 or "error" == _val_0 or "canceled" == _val_0 -- 146
end -- 144
local gitInvalidRepoPath -- 148
gitInvalidRepoPath = function(repoPath) -- 148
	return not repoPath or repoPath == "" or not Content:isAbsolutePath(repoPath) -- 149
end -- 148
local gitShellSplit -- 151
gitShellSplit = function(command) -- 151
	local args = { } -- 152
	local current = { } -- 153
	local quote = nil -- 154
	local escape = false -- 155
	for i = 1, #command do -- 156
		local ch = command:sub(i, i) -- 157
		if escape then -- 158
			current[#current + 1] = ch -- 159
			escape = false -- 160
		elseif ch == "\\" then -- 161
			escape = true -- 162
		elseif quote then -- 163
			if ch == quote then -- 164
				quote = nil -- 165
			else -- 167
				current[#current + 1] = ch -- 167
			end -- 164
		elseif ch == "'" or ch == '"' then -- 168
			quote = ch -- 169
		elseif ch:match("%s") then -- 170
			if #current > 0 then -- 171
				args[#args + 1] = table.concat(current) -- 172
				current = { } -- 173
			end -- 171
		else -- 175
			current[#current + 1] = ch -- 175
		end -- 158
	end -- 156
	if #current > 0 then -- 176
		args[#args + 1] = table.concat(current) -- 177
	end -- 176
	if args[1] == "git" then -- 178
		table.remove(args, 1) -- 179
	end -- 178
	return args -- 180
end -- 151
local gitQuote -- 182
gitQuote = function(value) -- 182
	local text = tostring(value) -- 183
	if text:match("^[%w%._%-%/]+$") then -- 184
		return text -- 185
	end -- 184
	return "\"" .. text:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"" -- 186
end -- 182
local gitDirNonEmpty -- 188
gitDirNonEmpty = function(targetPath) -- 188
	if not Content:exist(targetPath) then -- 189
		return false -- 189
	end -- 189
	if not Content:isdir(targetPath) then -- 190
		return false -- 190
	end -- 190
	return #Content:getFiles(targetPath) > 0 or #Content:getDirs(targetPath) > 0 -- 191
end -- 188
local gitSafeChildPath -- 193
gitSafeChildPath = function(parentPath, childPath) -- 193
	if not (parentPath and childPath and childPath ~= "") then -- 194
		return nil -- 194
	end -- 194
	if childPath:sub(1, 1) == "/" or childPath:match("^%a:[/\\]") then -- 195
		return nil -- 195
	end -- 195
	if childPath == "." or childPath:match("^%.%.[/\\]?" or childPath:match("[/\\]%.%.[/\\]")) then -- 196
		return nil -- 196
	end -- 196
	local targetPath = Path(parentPath, childPath) -- 197
	local relative = Path:getRelative(targetPath, parentPath) -- 198
	if relative == ".." or relative:sub(1, 3) == "../" or relative:sub(1, 3) == "..\\" then -- 199
		return nil -- 199
	end -- 199
	return targetPath -- 200
end -- 193
local gitCloneDirFromURL -- 202
gitCloneDirFromURL = function(url) -- 202
	if not (url and url ~= "") then -- 203
		return nil -- 203
	end -- 203
	local text = tostring(url):match("^%s*(.-)%s*$") -- 204
	if text == "" then -- 205
		return nil -- 205
	end -- 205
	text = text:gsub("[/\\]+$", "") -- 206
	local name = text:match("([^/:]+)$") -- 207
	if not (name and name ~= "") then -- 208
		return nil -- 208
	end -- 208
	name = name:gsub("%.git$", "") -- 209
	if name == "" or name == "." or name == ".." then -- 210
		return nil -- 210
	end -- 210
	return name -- 211
end -- 202
local gitCloneTargetPath -- 213
gitCloneTargetPath = function(repoPath, command) -- 213
	local args = gitShellSplit(command) -- 214
	if not (args[1] == "clone") then -- 215
		return nil -- 215
	end -- 215
	local url = args[2] -- 216
	local index = 3 -- 217
	while index <= #args do -- 218
		local arg = args[index] -- 219
		if ("-b" == arg or "--branch" == arg or "--depth" == arg) then -- 220
			index = index + 2 -- 221
		elseif arg:sub(1, 1) == "-" then -- 222
			index = index + 1 -- 223
		else -- 225
			return gitSafeChildPath(repoPath, arg) -- 225
		end -- 220
	end -- 218
	do -- 226
		local dirName = gitCloneDirFromURL(url) -- 226
		if dirName then -- 226
			return gitSafeChildPath(repoPath, dirName) -- 227
		end -- 226
	end -- 226
	return nil -- 228
end -- 213
local gitPathInsideRepo -- 230
gitPathInsideRepo = function(repoPath, relPath) -- 230
	if not (repoPath and relPath and relPath ~= "") then -- 231
		return false -- 231
	end -- 231
	if relPath:sub(1, 1) == "/" or relPath:match("^%a:[/\\]") then -- 232
		return false -- 232
	end -- 232
	if relPath == "." or relPath:match("^%.%.[/\\]?" or relPath:match("[/\\]%.%.[/\\]")) then -- 233
		return false -- 233
	end -- 233
	local targetPath = Path(repoPath, relPath) -- 234
	local relative = Path:getRelative(targetPath, repoPath) -- 235
	return relative ~= ".." and relative:sub(1, 3) ~= "../" and relative:sub(1, 3) ~= "..\\" -- 236
end -- 230
local gitHostFromURL -- 238
gitHostFromURL = function(url) -- 238
	if not (url and url ~= "") then -- 239
		return nil -- 239
	end -- 239
	local text = tostring(url):match("^%s*(.-)%s*$") -- 240
	if text == "" then -- 241
		return nil -- 241
	end -- 241
	local host = text:match("^[%w_%-]+://([^/:]+)") -- 242
	if not host then -- 243
		host = text:match("@([^:/]+)[:/]") -- 243
	end -- 243
	if not host then -- 244
		host = text:match("^([^:/]+):[^/]") -- 244
	end -- 244
	if not (host and host ~= "") then -- 245
		return nil -- 245
	end -- 245
	return string.lower(host) -- 246
end -- 238
local ensureGitTables -- 248
ensureGitTables = function() -- 248
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
	]]) -- 249
	DB:exec("CREATE INDEX IF NOT EXISTS idx_git_credential_host ON GitCredential(host);") -- 262
	return DB:exec([[		CREATE TABLE IF NOT EXISTS GitProfile(
			id INTEGER PRIMARY KEY CHECK(id = 1),
			name TEXT NOT NULL DEFAULT '',
			email TEXT NOT NULL DEFAULT '',
			updated_at INTEGER
		);
	]]) -- 263
end -- 248
local gitCredentialToPublic -- 272
gitCredentialToPublic = function(row) -- 272
	local id, host, label, typeName, username, createdAt, updatedAt, lastUsedAt = row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8] -- 273
	return { -- 274
		id = id, -- 274
		host = host, -- 274
		label = label, -- 274
		type = typeName, -- 274
		username = username, -- 274
		createdAt = createdAt, -- 274
		updatedAt = updatedAt, -- 274
		lastUsedAt = lastUsedAt -- 274
	} -- 274
end -- 272
local gitLoadCredential -- 276
gitLoadCredential = function(id) -- 276
	ensureGitTables() -- 277
	local credentialId = tonumber(id) or 0 -- 278
	local rows = DB:query("select id, host, label, type, username, secret from GitCredential where id = ? limit 1", { -- 279
		credentialId -- 279
	}) -- 279
	if not (rows and rows[1]) then -- 280
		return nil -- 280
	end -- 280
	local row = rows[1] -- 281
	return { -- 282
		id = row[1], -- 282
		host = row[2], -- 282
		label = row[3], -- 282
		type = row[4], -- 282
		username = row[5], -- 282
		secret = row[6] -- 282
	} -- 282
end -- 276
local gitAuthOptionsJSON -- 284
gitAuthOptionsJSON = function(credential) -- 284
	if not credential then -- 285
		return nil -- 285
	end -- 285
	local auth -- 286
	if credential.type == "token" then -- 286
		auth = { -- 288
			type = "token", -- 288
			token = credential.secret, -- 289
			username = credential.username ~= "" and credential.username or "token" -- 290
		} -- 287
	else -- 293
		auth = { -- 294
			type = "basic", -- 294
			username = credential.username, -- 295
			password = credential.secret -- 296
		} -- 293
	end -- 286
	return json.encode({ -- 298
		auth = auth -- 298
	}) -- 298
end -- 284
local gitLoadProfile -- 300
gitLoadProfile = function() -- 300
	ensureGitTables() -- 301
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 302
	if not (rows and rows[1]) then -- 303
		return nil -- 303
	end -- 303
	local name = tostring(rows[1][1] or "") -- 304
	local email = tostring(rows[1][2] or "") -- 305
	if name == "" and email == "" then -- 306
		return nil -- 306
	end -- 306
	return { -- 307
		name = name, -- 307
		email = email -- 307
	} -- 307
end -- 300
local _anon_func_2 = function(args, gitQuote) -- 326
	local _accum_0 = { } -- 326
	local _len_0 = 1 -- 326
	for _index_0 = 1, #args do -- 326
		local arg = args[_index_0] -- 326
		_accum_0[_len_0] = gitQuote(arg) -- 326
		_len_0 = _len_0 + 1 -- 326
	end -- 326
	return _accum_0 -- 326
end -- 326
local gitApplyProfileToCommit -- 309
gitApplyProfileToCommit = function(command) -- 309
	local args = gitShellSplit(command) -- 310
	if not (args[1] == "commit") then -- 311
		return command -- 311
	end -- 311
	local hasName = false -- 312
	local hasEmail = false -- 313
	for _index_0 = 1, #args do -- 314
		local arg = args[_index_0] -- 314
		if arg == "--author-name" then -- 315
			hasName = true -- 315
		end -- 315
		if arg == "--author-email" then -- 316
			hasEmail = true -- 316
		end -- 316
	end -- 314
	if hasName and hasEmail then -- 317
		return command -- 317
	end -- 317
	local profile = gitLoadProfile() -- 318
	if not profile then -- 319
		return command -- 319
	end -- 319
	if not hasName and profile.name ~= "" then -- 320
		args[#args + 1] = "--author-name" -- 321
		args[#args + 1] = profile.name -- 322
	end -- 320
	if not hasEmail and profile.email ~= "" then -- 323
		args[#args + 1] = "--author-email" -- 324
		args[#args + 1] = profile.email -- 325
	end -- 323
	return table.concat(_anon_func_2(args, gitQuote), " ") -- 326
end -- 309
local gitStartJob -- 328
gitStartJob = function(repoPath, command, optionsJSON) -- 328
	if optionsJSON == nil then -- 328
		optionsJSON = nil -- 328
	end -- 328
	if gitInvalidRepoPath(repoPath) then -- 329
		return nil, "invalid repoPath" -- 329
	end -- 329
	if not (command and command ~= "") then -- 330
		return nil, "invalid command" -- 330
	end -- 330
	if not optionsJSON then -- 331
		optionsJSON = "" -- 331
	end -- 331
	command = gitApplyProfileToCommit(command) -- 332
	do -- 333
		local targetPath = gitCloneTargetPath(repoPath, command) -- 333
		if targetPath then -- 333
			if gitDirNonEmpty(targetPath) then -- 334
				return nil, "clone target directory is not empty" -- 335
			end -- 334
		elseif (gitShellSplit(command))[1] == "clone" then -- 336
			return nil, "invalid clone target" -- 337
		end -- 333
	end -- 333
	local statusRef = nil -- 338
	local startGit -- 339
	startGit = function() -- 339
		return Git:run(repoPath, command, (function(status) -- 340
			statusRef = status -- 341
			GitJobs[status.id] = { -- 343
				command = command, -- 343
				status = status, -- 344
				updatedAt = os.time() -- 345
			} -- 342
		end), optionsJSON) -- 340
	end -- 339
	local success, jobId = pcall(startGit) -- 347
	if not success then -- 348
		return nil, tostring(jobId) -- 348
	end -- 348
	if not jobId then -- 349
		return nil, "Git.run did not return a job id" -- 349
	end -- 349
	GitJobs[jobId] = { -- 351
		command = command, -- 351
		status = statusRef or { -- 353
			id = jobId, -- 353
			state = "queued", -- 354
			kind = gitShellSplit(command)[1] or "status", -- 355
			repoPath = repoPath, -- 356
			progress = 0, -- 357
			message = "queued" -- 358
		}, -- 352
		updatedAt = os.time() -- 360
	} -- 350
	return jobId -- 361
end -- 328
local gitRunSync -- 363
gitRunSync = function(repoPath, command, optionsJSON, timeout) -- 363
	if optionsJSON == nil then -- 363
		optionsJSON = nil -- 363
	end -- 363
	if timeout == nil then -- 363
		timeout = 20 -- 363
	end -- 363
	local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 364
	if not jobId then -- 365
		return { -- 365
			success = false, -- 365
			message = err -- 365
		} -- 365
	end -- 365
	local startedAt = os.time() -- 366
	wait(function() -- 367
		local job = GitJobs[jobId] -- 368
		local status = job and job.status -- 369
		return gitTerminalState(status) or os.time() - startedAt >= timeout -- 370
	end) -- 367
	local status = GitJobs[jobId] and GitJobs[jobId].status -- 371
	if not gitTerminalState(status) then -- 372
		Git:cancel(jobId) -- 373
		return { -- 374
			success = false, -- 374
			message = "git command timed out", -- 374
			jobId = jobId, -- 374
			status = status -- 374
		} -- 374
	end -- 372
	return { -- 375
		success = status.state == "done", -- 375
		jobId = jobId, -- 375
		status = status, -- 375
		message = status.error or status.message -- 375
	} -- 375
end -- 363
local gitCredentialsForHost -- 377
gitCredentialsForHost = function(host) -- 377
	if not (host and host ~= "") then -- 378
		return { } -- 378
	end -- 378
	ensureGitTables() -- 379
	local rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by last_used_at desc, label asc, id asc", { -- 380
		host -- 380
	}) -- 380
	if rows then -- 381
		local _accum_0 = { } -- 382
		local _len_0 = 1 -- 382
		for _index_0 = 1, #rows do -- 382
			local row = rows[_index_0] -- 382
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 382
			_len_0 = _len_0 + 1 -- 382
		end -- 382
		return _accum_0 -- 382
	else -- 383
		return { } -- 383
	end -- 381
end -- 377
local gitFirstRemoteURL -- 385
gitFirstRemoteURL = function(repoPath, remoteName) -- 385
	if remoteName == nil then -- 385
		remoteName = nil -- 385
	end -- 385
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 10) -- 386
	local data = remoteRes.status and remoteRes.status.data -- 387
	if not (data and data.remotes) then -- 388
		return nil -- 388
	end -- 388
	local _list_0 = data.remotes -- 389
	for _index_0 = 1, #_list_0 do -- 389
		local remote = _list_0[_index_0] -- 389
		if (not remoteName or remote.name == remoteName) and remote.urls and remote.urls[1] then -- 390
			return remote.urls[1] -- 391
		end -- 390
	end -- 389
	return nil -- 392
end -- 385
local gitConfigRemoteURL -- 394
gitConfigRemoteURL = function(repoPath, remoteName) -- 394
	if remoteName == nil then -- 394
		remoteName = nil -- 394
	end -- 394
	if gitInvalidRepoPath(repoPath) then -- 395
		return nil -- 395
	end -- 395
	local configPath = Path(repoPath, ".git/config") -- 396
	if not Content:exist(configPath) then -- 397
		return nil -- 397
	end -- 397
	local content = Content:load(configPath) -- 398
	if not (content and content ~= "") then -- 399
		return nil -- 399
	end -- 399
	local currentRemote = nil -- 400
	for line in content:gmatch("[^\r\n]+") do -- 401
		local sectionRemote = line:match('^%s*%[remote%s+"([^"]+)"%]%s*$') -- 402
		if sectionRemote then -- 403
			currentRemote = sectionRemote -- 404
		elseif currentRemote and (not remoteName or currentRemote == remoteName) then -- 405
			local url = line:match("^%s*url%s*=%s*(.-)%s*$") -- 406
			if url and url ~= "" then -- 407
				return url -- 407
			end -- 407
		end -- 403
	end -- 401
	return nil -- 408
end -- 394
local gitCommandRemoteArg -- 410
gitCommandRemoteArg = function(args, startIndex) -- 410
	if startIndex == nil then -- 410
		startIndex = 2 -- 410
	end -- 410
	local index = startIndex -- 411
	while index <= #args do -- 412
		local arg = args[index] -- 413
		if ("-u" == arg or "--set-upstream" == arg or "-f" == arg or "--force" == arg or "--all" == arg or "--prune" == arg) then -- 414
			index = index + 1 -- 415
		elseif ("--depth" == arg or "-b" == arg or "--branch" == arg) then -- 416
			index = index + 2 -- 417
		elseif arg and arg:sub(1, 1) == "-" then -- 418
			index = index + 1 -- 419
		else -- 421
			return arg -- 421
		end -- 414
	end -- 412
	return nil -- 422
end -- 410
local gitCommandHost -- 424
gitCommandHost = function(repoPath, command) -- 424
	local args = gitShellSplit(command) -- 425
	if not args[1] then -- 426
		return nil -- 426
	end -- 426
	do -- 427
		local _exp_0 = args[1] -- 427
		if "clone" == _exp_0 or "ls-remote" == _exp_0 then -- 428
			return gitHostFromURL(args[2]) -- 429
		elseif "fetch" == _exp_0 or "pull" == _exp_0 or "push" == _exp_0 then -- 430
			local remoteArg = gitCommandRemoteArg(args, 2) -- 431
			if not remoteArg then -- 432
				return nil -- 432
			end -- 432
			local url = gitHostFromURL(remoteArg) -- 433
			if url then -- 434
				return url -- 434
			end -- 434
			return gitHostFromURL(gitConfigRemoteURL(repoPath, remoteArg)) -- 435
		end -- 427
	end -- 427
	return nil -- 436
end -- 424
local gitAuthSelectionForCommand -- 438
gitAuthSelectionForCommand = function(repoPath, command) -- 438
	local host = gitCommandHost(repoPath, command) -- 439
	if not host then -- 440
		return nil -- 440
	end -- 440
	local items = gitCredentialsForHost(host) -- 441
	if #items == 0 then -- 442
		return nil -- 442
	end -- 442
	return { -- 443
		host = host, -- 443
		items = items -- 443
	} -- 443
end -- 438
local gitDefaultRemote -- 445
gitDefaultRemote = function(remoteStatus) -- 445
	local data = remoteStatus and remoteStatus.data -- 446
	if not (data and data.remotes and data.remotes[1]) then -- 447
		return nil -- 447
	end -- 447
	return data.remotes[1] -- 448
end -- 445
local gitCurrentBranch -- 450
gitCurrentBranch = function(branchStatus) -- 450
	local data = branchStatus and branchStatus.data -- 451
	if data and data.current and data.current ~= "" then -- 452
		return data.current -- 453
	end -- 452
	if data and data.branches then -- 454
		local _list_0 = data.branches -- 455
		for _index_0 = 1, #_list_0 do -- 455
			local branch = _list_0[_index_0] -- 455
			if branch.current then -- 456
				return branch.name -- 456
			end -- 456
		end -- 455
	end -- 454
	return nil -- 457
end -- 450
local gitHeadBranch -- 459
gitHeadBranch = function(repoPath) -- 459
	if gitInvalidRepoPath(repoPath) then -- 460
		return nil -- 460
	end -- 460
	local headPath = Path(repoPath, ".git", "HEAD") -- 461
	if not Content:exist(headPath) then -- 462
		return nil -- 462
	end -- 462
	local head = Content:load(headPath) -- 463
	if not head then -- 464
		return nil -- 464
	end -- 464
	local branch = head:match("^ref:%s*refs/heads/(.-)%s*$") -- 465
	if branch and branch ~= "" then -- 466
		return branch -- 466
	end -- 466
	return nil -- 467
end -- 459
local gitBranchesWithHead -- 469
gitBranchesWithHead = function(branchStatus, currentBranch) -- 469
	local branches = branchStatus and branchStatus.data and branchStatus.data.branches or { } -- 470
	if not (currentBranch and currentBranch ~= "") then -- 471
		return branches -- 471
	end -- 471
	for _index_0 = 1, #branches do -- 472
		local branch = branches[_index_0] -- 472
		if branch.name == currentBranch then -- 473
			return branches -- 473
		end -- 473
	end -- 472
	local withHead -- 474
	do -- 474
		local _accum_0 = { } -- 474
		local _len_0 = 1 -- 474
		for _index_0 = 1, #branches do -- 474
			local branch = branches[_index_0] -- 474
			_accum_0[_len_0] = branch -- 474
			_len_0 = _len_0 + 1 -- 474
		end -- 474
		withHead = _accum_0 -- 474
	end -- 474
	withHead[#withHead + 1] = { -- 475
		name = currentBranch, -- 475
		current = true, -- 475
		unborn = true -- 475
	} -- 475
	return withHead -- 476
end -- 469
local gitStatusMeansNotRepo -- 478
gitStatusMeansNotRepo = function(statusRes) -- 478
	local message = statusRes and (statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message)) or "" -- 479
	message = tostring(message):lower() -- 480
	return message:find("repository does not exist", 1, true) or message:find("not a git repository", 1, true) -- 481
end -- 478
local gitSummary -- 483
gitSummary = function(repoPath) -- 483
	local statusRes = gitRunSync(repoPath, "status", nil, 120) -- 484
	if not statusRes.success then -- 485
		if gitStatusMeansNotRepo(statusRes) then -- 486
			return { -- 487
				success = true, -- 487
				isRepo = false, -- 487
				message = statusRes.message, -- 487
				status = statusRes.status -- 487
			} -- 487
		end -- 486
		return { -- 488
			success = false, -- 488
			message = statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message) or "failed to check Git repository", -- 488
			status = statusRes.status -- 488
		} -- 488
	end -- 485
	local branchRes = gitRunSync(repoPath, "branch", nil, 120) -- 489
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 120) -- 490
	local status = statusRes.status -- 491
	local branchStatus = branchRes.status -- 492
	local remoteStatus = remoteRes.status -- 493
	local currentBranch = gitCurrentBranch(branchStatus) or gitHeadBranch(repoPath) -- 494
	local branches = gitBranchesWithHead(branchStatus, currentBranch) -- 495
	local logRes = gitRunSync(repoPath, "log -n 100", nil, 120) -- 496
	local logStatus -- 497
	if logRes.success then -- 497
		logStatus = logRes.status -- 498
	else -- 500
		logStatus = { -- 501
			state = "done", -- 501
			kind = "log", -- 502
			repoPath = repoPath, -- 503
			progress = 1, -- 504
			message = "git log completed", -- 505
			data = { -- 506
				commits = { } -- 506
			} -- 506
		} -- 500
	end -- 497
	local hasCommit = logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] ~= nil -- 508
	local tagStatus -- 509
	if hasCommit then -- 509
		tagStatus = (gitRunSync(repoPath, "tag", nil, 120)).status -- 510
	else -- 512
		tagStatus = { -- 513
			state = "done", -- 513
			kind = "tag", -- 514
			repoPath = repoPath, -- 515
			progress = 1, -- 516
			message = "git tag completed", -- 517
			data = { -- 518
				tags = { } -- 518
			} -- 518
		} -- 512
	end -- 509
	local defaultRemote = gitDefaultRemote(remoteStatus) -- 520
	local lastCommit = nil -- 521
	if logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] then -- 522
		lastCommit = logStatus.data.commits[1] -- 523
	end -- 522
	return { -- 525
		success = true, -- 525
		isRepo = true, -- 526
		clean = status.data and status.data.clean or false, -- 527
		currentBranch = currentBranch, -- 528
		defaultRemote = defaultRemote, -- 529
		remotes = remoteStatus and remoteStatus.data and remoteStatus.data.remotes or { }, -- 530
		branches = branches, -- 531
		lastCommit = lastCommit, -- 532
		status = status, -- 533
		branchStatus = branchStatus, -- 534
		remoteStatus = remoteStatus, -- 535
		historyStatus = logStatus, -- 536
		tagStatus = tagStatus -- 537
	} -- 524
end -- 483
HttpServer:post("/git/run", function(req) -- 539
	do -- 540
		local _type_0 = type(req) -- 540
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 540
		if _tab_0 then -- 540
			local body = req.body -- 540
			if body ~= nil then -- 540
				local repoPath, command, authId, optionsJSON = body.repoPath, body.command, body.authId, body.optionsJSON -- 541
				if authId and not optionsJSON then -- 542
					local credential = gitLoadCredential(authId) -- 543
					if credential then -- 543
						optionsJSON = gitAuthOptionsJSON(credential) -- 544
						DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 545
							os.time(), -- 545
							credential.id -- 545
						}) -- 545
					end -- 543
				elseif not optionsJSON then -- 546
					local authOk, authSelection = pcall(gitAuthSelectionForCommand, repoPath, command) -- 547
					if not authOk then -- 548
						authSelection = nil -- 548
					end -- 548
					if authSelection then -- 549
						if #authSelection.items == 1 then -- 550
							local credential = gitLoadCredential(authSelection.items[1].id) -- 551
							optionsJSON = gitAuthOptionsJSON(credential) -- 552
							DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 553
								os.time(), -- 553
								credential.id -- 553
							}) -- 553
						else -- 555
							return { -- 555
								success = false, -- 555
								message = "select a Git credential", -- 555
								needsCredentialSelection = true, -- 555
								host = authSelection.host, -- 555
								credentials = authSelection.items -- 555
							} -- 555
						end -- 550
					end -- 549
				end -- 542
				local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 556
				if not jobId then -- 557
					return { -- 557
						success = false, -- 557
						message = err -- 557
					} -- 557
				end -- 557
				return { -- 558
					success = true, -- 558
					jobId = jobId -- 558
				} -- 558
			end -- 540
		end -- 540
	end -- 540
	return invalidArguments -- 539
end) -- 539
HttpServer:post("/git/status", function(req) -- 560
	do -- 561
		local _type_0 = type(req) -- 561
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 561
		if _tab_0 then -- 561
			local jobId -- 561
			do -- 561
				local _obj_0 = req.body -- 561
				local _type_1 = type(_obj_0) -- 561
				if "table" == _type_1 or "userdata" == _type_1 then -- 561
					jobId = _obj_0.jobId -- 561
				end -- 561
			end -- 561
			if jobId ~= nil then -- 561
				local job = GitJobs[tonumber(jobId) or 0] -- 562
				if not job then -- 563
					return { -- 563
						success = false, -- 563
						message = "git job not found" -- 563
					} -- 563
				end -- 563
				return { -- 564
					success = true, -- 564
					status = job.status, -- 564
					command = job.command -- 564
				} -- 564
			end -- 561
		end -- 561
	end -- 561
	return invalidArguments -- 560
end) -- 560
HttpServer:post("/git/cancel", function(req) -- 566
	do -- 567
		local _type_0 = type(req) -- 567
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 567
		if _tab_0 then -- 567
			local jobId -- 567
			do -- 567
				local _obj_0 = req.body -- 567
				local _type_1 = type(_obj_0) -- 567
				if "table" == _type_1 or "userdata" == _type_1 then -- 567
					jobId = _obj_0.jobId -- 567
				end -- 567
			end -- 567
			if jobId ~= nil then -- 567
				local id = tonumber(jobId) -- 568
				if not id then -- 569
					return { -- 569
						success = false, -- 569
						message = "invalid jobId" -- 569
					} -- 569
				end -- 569
				return { -- 570
					success = Git:cancel(id) -- 570
				} -- 570
			end -- 567
		end -- 567
	end -- 567
	return invalidArguments -- 566
end) -- 566
HttpServer:postSchedule("/git/summary", function(req) -- 572
	do -- 573
		local _type_0 = type(req) -- 573
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 573
		if _tab_0 then -- 573
			local repoPath -- 573
			do -- 573
				local _obj_0 = req.body -- 573
				local _type_1 = type(_obj_0) -- 573
				if "table" == _type_1 or "userdata" == _type_1 then -- 573
					repoPath = _obj_0.repoPath -- 573
				end -- 573
			end -- 573
			if repoPath ~= nil then -- 573
				if gitInvalidRepoPath(repoPath) then -- 574
					return { -- 574
						success = false, -- 574
						message = "invalid repoPath" -- 574
					} -- 574
				end -- 574
				return gitSummary(repoPath) -- 575
			end -- 573
		end -- 573
	end -- 573
	return invalidArguments -- 572
end) -- 572
HttpServer:postSchedule("/git/status-files", function(req) -- 577
	do -- 578
		local _type_0 = type(req) -- 578
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 578
		if _tab_0 then -- 578
			local repoPath -- 578
			do -- 578
				local _obj_0 = req.body -- 578
				local _type_1 = type(_obj_0) -- 578
				if "table" == _type_1 or "userdata" == _type_1 then -- 578
					repoPath = _obj_0.repoPath -- 578
				end -- 578
			end -- 578
			if repoPath ~= nil then -- 578
				return gitRunSync(repoPath, "status", nil, 10) -- 579
			end -- 578
		end -- 578
	end -- 578
	return invalidArguments -- 577
end) -- 577
HttpServer:postSchedule("/git/discard-untracked", function(req) -- 581
	do -- 582
		local _type_0 = type(req) -- 582
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 582
		if _tab_0 then -- 582
			local body = req.body -- 582
			if body ~= nil then -- 582
				local repoPath, paths = body.repoPath, body.paths -- 583
				if gitInvalidRepoPath(repoPath) then -- 584
					return { -- 584
						success = false, -- 584
						message = "invalid repoPath" -- 584
					} -- 584
				end -- 584
				if not (type(paths) == "table") then -- 585
					return { -- 585
						success = false, -- 585
						message = "invalid paths" -- 585
					} -- 585
				end -- 585
				local statusRes = gitRunSync(repoPath, "status", nil, 10) -- 586
				if not statusRes.success then -- 587
					return statusRes -- 587
				end -- 587
				local untracked = { } -- 588
				local _list_0 = (statusRes.status.data and statusRes.status.data.files or { }) -- 589
				for _index_0 = 1, #_list_0 do -- 589
					local file = _list_0[_index_0] -- 589
					if file.staging == "?" or file.worktree == "?" then -- 590
						untracked[file.path] = true -- 591
					end -- 590
				end -- 589
				local removed = { } -- 592
				for _index_0 = 1, #paths do -- 593
					local relPath = paths[_index_0] -- 593
					relPath = tostring(relPath) -- 594
					if not gitPathInsideRepo(repoPath, relPath) then -- 595
						return { -- 595
							success = false, -- 595
							message = "unsafe path: " .. tostring(relPath) -- 595
						} -- 595
					end -- 595
					if not untracked[relPath] then -- 596
						return { -- 596
							success = false, -- 596
							message = "path is not untracked: " .. tostring(relPath) -- 596
						} -- 596
					end -- 596
				end -- 593
				for _index_0 = 1, #paths do -- 597
					local relPath = paths[_index_0] -- 597
					local targetPath = Path(repoPath, tostring(relPath)) -- 598
					if Content:exist(targetPath) then -- 599
						Content:remove(targetPath) -- 600
						removed[#removed + 1] = tostring(relPath) -- 601
					end -- 599
				end -- 597
				return { -- 602
					success = true, -- 602
					removed = removed -- 602
				} -- 602
			end -- 582
		end -- 582
	end -- 582
	return invalidArguments -- 581
end) -- 581
HttpServer:postSchedule("/git/file-diff", function(req) -- 604
	do -- 605
		local _type_0 = type(req) -- 605
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 605
		if _tab_0 then -- 605
			local body = req.body -- 605
			if body ~= nil then -- 605
				local repoPath, path, staged = body.repoPath, body.path, body.staged -- 606
				if gitInvalidRepoPath(repoPath) then -- 607
					return { -- 607
						success = false, -- 607
						message = "invalid repoPath" -- 607
					} -- 607
				end -- 607
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 608
					return { -- 608
						success = false, -- 608
						message = "unsafe path" -- 608
					} -- 608
				end -- 608
				local command -- 609
				if staged == true then -- 609
					command = "diff --staged -- " .. tostring(gitQuote(path)) -- 610
				else -- 612
					command = "diff -- " .. tostring(gitQuote(path)) -- 612
				end -- 609
				local res = gitRunSync(repoPath, command, nil, 10) -- 613
				if not res.success then -- 614
					return res -- 614
				end -- 614
				return { -- 615
					success = true, -- 615
					status = res.status, -- 615
					data = res.status and res.status.data -- 615
				} -- 615
			end -- 605
		end -- 605
	end -- 605
	return invalidArguments -- 604
end) -- 604
HttpServer:postSchedule("/git/commit-file-diff", function(req) -- 617
	do -- 618
		local _type_0 = type(req) -- 618
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 618
		if _tab_0 then -- 618
			local body = req.body -- 618
			if body ~= nil then -- 618
				local repoPath, commit, path = body.repoPath, body.commit, body.path -- 619
				if gitInvalidRepoPath(repoPath) then -- 620
					return { -- 620
						success = false, -- 620
						message = "invalid repoPath" -- 620
					} -- 620
				end -- 620
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 621
					return { -- 621
						success = false, -- 621
						message = "invalid commit" -- 621
					} -- 621
				end -- 621
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 622
					return { -- 622
						success = false, -- 622
						message = "unsafe path" -- 622
					} -- 622
				end -- 622
				local res = gitRunSync(repoPath, "diff " .. tostring(gitQuote(commit)) .. " -- " .. tostring(gitQuote(path)), nil, 10) -- 623
				if not res.success then -- 624
					return res -- 624
				end -- 624
				return { -- 625
					success = true, -- 625
					status = res.status, -- 625
					data = res.status and res.status.data -- 625
				} -- 625
			end -- 618
		end -- 618
	end -- 618
	return invalidArguments -- 617
end) -- 617
HttpServer:postSchedule("/git/history", function(req) -- 627
	do -- 628
		local _type_0 = type(req) -- 628
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 628
		if _tab_0 then -- 628
			local body = req.body -- 628
			if body ~= nil then -- 628
				local repoPath, limit = body.repoPath, body.limit -- 629
				limit = math.max(1, math.min(100, tonumber(limit) or 20)) -- 630
				return gitRunSync(repoPath, "log -n " .. tostring(limit), nil, 10) -- 631
			end -- 628
		end -- 628
	end -- 628
	return invalidArguments -- 627
end) -- 627
HttpServer:postSchedule("/git/remotes", function(req) -- 633
	do -- 634
		local _type_0 = type(req) -- 634
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 634
		if _tab_0 then -- 634
			local body = req.body -- 634
			if body ~= nil then -- 634
				local repoPath, command = body.repoPath, body.command -- 635
				command = command or "remote -v" -- 636
				return gitRunSync(repoPath, command, nil, 10) -- 637
			end -- 634
		end -- 634
	end -- 634
	return invalidArguments -- 633
end) -- 633
HttpServer:postSchedule("/git/branches", function(req) -- 639
	do -- 640
		local _type_0 = type(req) -- 640
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 640
		if _tab_0 then -- 640
			local body = req.body -- 640
			if body ~= nil then -- 640
				local repoPath, command = body.repoPath, body.command -- 641
				command = command or "branch" -- 642
				return gitRunSync(repoPath, command, nil, 10) -- 643
			end -- 640
		end -- 640
	end -- 640
	return invalidArguments -- 639
end) -- 639
HttpServer:postSchedule("/git/tags", function(req) -- 645
	do -- 646
		local _type_0 = type(req) -- 646
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 646
		if _tab_0 then -- 646
			local body = req.body -- 646
			if body ~= nil then -- 646
				local repoPath, command = body.repoPath, body.command -- 647
				command = command or "tag" -- 648
				return gitRunSync(repoPath, command, nil, 10) -- 649
			end -- 646
		end -- 646
	end -- 646
	return invalidArguments -- 645
end) -- 645
HttpServer:post("/git/profile/get", function() -- 651
	ensureGitTables() -- 652
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 653
	local profile -- 654
	if rows and rows[1] then -- 654
		profile = { -- 655
			name = rows[1][1], -- 655
			email = rows[1][2] -- 655
		} -- 655
	else -- 657
		profile = { -- 657
			name = "", -- 657
			email = "" -- 657
		} -- 657
	end -- 654
	return { -- 658
		success = true, -- 658
		profile = profile -- 658
	} -- 658
end) -- 651
HttpServer:post("/git/profile/save", function(req) -- 660
	do -- 661
		local _type_0 = type(req) -- 661
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 661
		if _tab_0 then -- 661
			local name -- 661
			do -- 661
				local _obj_0 = req.body -- 661
				local _type_1 = type(_obj_0) -- 661
				if "table" == _type_1 or "userdata" == _type_1 then -- 661
					name = _obj_0.name -- 661
				end -- 661
			end -- 661
			local email -- 661
			do -- 661
				local _obj_0 = req.body -- 661
				local _type_1 = type(_obj_0) -- 661
				if "table" == _type_1 or "userdata" == _type_1 then -- 661
					email = _obj_0.email -- 661
				end -- 661
			end -- 661
			if name ~= nil and email ~= nil then -- 661
				ensureGitTables() -- 662
				DB:exec("insert into GitProfile(id, name, email, updated_at) values(1, ?, ?, ?) on conflict(id) do update set name = excluded.name, email = excluded.email, updated_at = excluded.updated_at", { -- 664
					tostring(name or ""), -- 664
					tostring(email or ""), -- 665
					os.time() -- 666
				}) -- 663
				return { -- 668
					success = true -- 668
				} -- 668
			end -- 661
		end -- 661
	end -- 661
	return invalidArguments -- 660
end) -- 660
HttpServer:post("/git/auth/list", function(req) -- 670
	ensureGitTables() -- 671
	local host = nil -- 672
	do -- 673
		local _type_0 = type(req) -- 673
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 673
		if _tab_0 then -- 673
			local body = req.body -- 673
			if body ~= nil then -- 673
				host = body.host -- 674
			end -- 673
		end -- 673
	end -- 673
	local rows -- 675
	if host and host ~= "" then -- 675
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by host asc, label asc, id asc", { -- 676
			tostring(host):lower() -- 676
		}) -- 676
	else -- 678
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential order by host asc, label asc, id asc") -- 678
	end -- 675
	local items -- 679
	if rows then -- 679
		local _accum_0 = { } -- 680
		local _len_0 = 1 -- 680
		for _index_0 = 1, #rows do -- 680
			local row = rows[_index_0] -- 680
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 680
			_len_0 = _len_0 + 1 -- 680
		end -- 680
		items = _accum_0 -- 680
	else -- 681
		items = { } -- 681
	end -- 679
	return { -- 682
		success = true, -- 682
		items = items -- 682
	} -- 682
end) -- 670
HttpServer:postSchedule("/git/auth/match", function(req) -- 684
	do -- 685
		local _type_0 = type(req) -- 685
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 685
		local _match_0 = false -- 685
		if _tab_0 then -- 685
			local body = req.body -- 685
			if body ~= nil then -- 685
				_match_0 = true -- 685
				local repoPath, command, url = body.repoPath, body.command, body.url -- 686
				local host -- 687
				if url and url ~= "" then -- 687
					host = gitHostFromURL(url) -- 687
				else -- 687
					host = gitCommandHost(repoPath, command) -- 687
				end -- 687
				if not host then -- 688
					return { -- 688
						success = false, -- 688
						message = "git host is required" -- 688
					} -- 688
				end -- 688
				local items = gitCredentialsForHost(host) -- 689
				return { -- 690
					success = true, -- 690
					host = host, -- 690
					items = items, -- 690
					needsSelection = #items > 1, -- 690
					authId = (#items == 1 and items[1].id or nil) -- 690
				} -- 690
			end -- 685
		end -- 685
		if not _match_0 then -- 685
			return { -- 692
				success = false, -- 692
				message = "invalid arguments" -- 692
			} -- 692
		end -- 685
	end -- 685
	return invalidArguments -- 684
end) -- 684
HttpServer:post("/git/auth/save", function(req) -- 694
	do -- 695
		local _type_0 = type(req) -- 695
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 695
		if _tab_0 then -- 695
			local body = req.body -- 695
			if body ~= nil then -- 695
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token -- 696
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$") -- 697
				label = tostring(label or ""):match("^%s*(.-)%s*$") -- 698
				local credentialType = tostring(body.type or "token") -- 699
				username = tostring(username or "") -- 700
				local secret -- 701
				if credentialType == "basic" then -- 701
					secret = tostring(password or "") -- 701
				else -- 701
					secret = tostring(token or password or "") -- 701
				end -- 701
				if host == "" then -- 702
					return { -- 702
						success = false, -- 702
						message = "host is required" -- 702
					} -- 702
				end -- 702
				if label == "" then -- 703
					return { -- 703
						success = false, -- 703
						message = "label is required" -- 703
					} -- 703
				end -- 703
				if secret == "" then -- 704
					return { -- 704
						success = false, -- 704
						message = "secret is required" -- 704
					} -- 704
				end -- 704
				if not (("basic" == credentialType or "token" == credentialType)) then -- 705
					return { -- 705
						success = false, -- 705
						message = "invalid type" -- 705
					} -- 705
				end -- 705
				ensureGitTables() -- 706
				local now = os.time() -- 707
				if id then -- 708
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", { -- 710
						host, -- 710
						label, -- 710
						credentialType, -- 710
						username, -- 710
						secret, -- 710
						now, -- 710
						(tonumber(id) or 0) -- 710
					}) -- 709
					return { -- 712
						success = true, -- 712
						id = tonumber(id) -- 712
					} -- 712
				else -- 714
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", { -- 715
						host, -- 715
						label, -- 715
						credentialType, -- 715
						username, -- 715
						secret, -- 715
						now, -- 715
						now -- 715
					}) -- 714
					local rows = DB:query("select last_insert_rowid()") -- 717
					return { -- 718
						success = true, -- 718
						id = rows and rows[1] and rows[1][1] -- 718
					} -- 718
				end -- 708
			end -- 695
		end -- 695
	end -- 695
	return invalidArguments -- 694
end) -- 694
HttpServer:post("/git/auth/delete", function(req) -- 720
	do -- 721
		local _type_0 = type(req) -- 721
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 721
		if _tab_0 then -- 721
			local id -- 721
			do -- 721
				local _obj_0 = req.body -- 721
				local _type_1 = type(_obj_0) -- 721
				if "table" == _type_1 or "userdata" == _type_1 then -- 721
					id = _obj_0.id -- 721
				end -- 721
			end -- 721
			if id ~= nil then -- 721
				ensureGitTables() -- 722
				local credentialId = tonumber(id) or 0 -- 723
				DB:exec("delete from GitCredential where id = ?", { -- 724
					credentialId -- 724
				}) -- 724
				return { -- 725
					success = true -- 725
				} -- 725
			end -- 721
		end -- 721
	end -- 721
	return invalidArguments -- 720
end) -- 720
HttpServer:postSchedule("/git/auth/test", function(req) -- 727
	do -- 728
		local _type_0 = type(req) -- 728
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 728
		if _tab_0 then -- 728
			local body = req.body -- 728
			if body ~= nil then -- 728
				local repoPath, url, authId = body.repoPath, body.url, body.authId -- 729
				local credential = gitLoadCredential(authId) -- 730
				local optionsJSON = gitAuthOptionsJSON(credential) -- 731
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20) -- 732
			end -- 728
		end -- 728
	end -- 728
	return invalidArguments -- 727
end) -- 727
HttpServer:post("/agent/session/create", function(req) -- 734
	do -- 735
		local _type_0 = type(req) -- 735
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 735
		if _tab_0 then -- 735
			local projectRoot -- 735
			do -- 735
				local _obj_0 = req.body -- 735
				local _type_1 = type(_obj_0) -- 735
				if "table" == _type_1 or "userdata" == _type_1 then -- 735
					projectRoot = _obj_0.projectRoot -- 735
				end -- 735
			end -- 735
			local title -- 735
			do -- 735
				local _obj_0 = req.body -- 735
				local _type_1 = type(_obj_0) -- 735
				if "table" == _type_1 or "userdata" == _type_1 then -- 735
					title = _obj_0.title -- 735
				end -- 735
			end -- 735
			if projectRoot ~= nil and title ~= nil then -- 735
				return AgentSession.createSession(projectRoot, title) -- 736
			end -- 735
		end -- 735
	end -- 735
	return invalidArguments -- 734
end) -- 734
HttpServer:post("/agent/session/create-sub", function(req) -- 738
	do -- 739
		local _type_0 = type(req) -- 739
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 739
		if _tab_0 then -- 739
			local parentSessionId -- 739
			do -- 739
				local _obj_0 = req.body -- 739
				local _type_1 = type(_obj_0) -- 739
				if "table" == _type_1 or "userdata" == _type_1 then -- 739
					parentSessionId = _obj_0.parentSessionId -- 739
				end -- 739
			end -- 739
			local title -- 739
			do -- 739
				local _obj_0 = req.body -- 739
				local _type_1 = type(_obj_0) -- 739
				if "table" == _type_1 or "userdata" == _type_1 then -- 739
					title = _obj_0.title -- 739
				end -- 739
			end -- 739
			if parentSessionId ~= nil and title ~= nil then -- 739
				return AgentSession.createSubSession(parentSessionId, title) -- 740
			end -- 739
		end -- 739
	end -- 739
	return invalidArguments -- 738
end) -- 738
HttpServer:post("/agent/session/get", function(req) -- 742
	do -- 743
		local _type_0 = type(req) -- 743
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 743
		if _tab_0 then -- 743
			local sessionId -- 743
			do -- 743
				local _obj_0 = req.body -- 743
				local _type_1 = type(_obj_0) -- 743
				if "table" == _type_1 or "userdata" == _type_1 then -- 743
					sessionId = _obj_0.sessionId -- 743
				end -- 743
			end -- 743
			if sessionId ~= nil then -- 743
				return AgentSession.getSession(sessionId) -- 744
			end -- 743
		end -- 743
	end -- 743
	return invalidArguments -- 742
end) -- 742
HttpServer:post("/agent/session/send", function(req) -- 746
	do -- 747
		local _type_0 = type(req) -- 747
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 747
		if _tab_0 then -- 747
			local sessionId -- 747
			do -- 747
				local _obj_0 = req.body -- 747
				local _type_1 = type(_obj_0) -- 747
				if "table" == _type_1 or "userdata" == _type_1 then -- 747
					sessionId = _obj_0.sessionId -- 747
				end -- 747
			end -- 747
			local prompt -- 747
			do -- 747
				local _obj_0 = req.body -- 747
				local _type_1 = type(_obj_0) -- 747
				if "table" == _type_1 or "userdata" == _type_1 then -- 747
					prompt = _obj_0.prompt -- 747
				end -- 747
			end -- 747
			if sessionId ~= nil and prompt ~= nil then -- 747
				return AgentSession.sendPrompt(sessionId, prompt, false, req.body.disabledAgentTools) -- 748
			end -- 747
		end -- 747
	end -- 747
	return invalidArguments -- 746
end) -- 746
HttpServer:post("/agent/session/resend", function(req) -- 750
	do -- 751
		local _type_0 = type(req) -- 751
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 751
		if _tab_0 then -- 751
			local sessionId -- 751
			do -- 751
				local _obj_0 = req.body -- 751
				local _type_1 = type(_obj_0) -- 751
				if "table" == _type_1 or "userdata" == _type_1 then -- 751
					sessionId = _obj_0.sessionId -- 751
				end -- 751
			end -- 751
			local messageId -- 751
			do -- 751
				local _obj_0 = req.body -- 751
				local _type_1 = type(_obj_0) -- 751
				if "table" == _type_1 or "userdata" == _type_1 then -- 751
					messageId = _obj_0.messageId -- 751
				end -- 751
			end -- 751
			local prompt -- 751
			do -- 751
				local _obj_0 = req.body -- 751
				local _type_1 = type(_obj_0) -- 751
				if "table" == _type_1 or "userdata" == _type_1 then -- 751
					prompt = _obj_0.prompt -- 751
				end -- 751
			end -- 751
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 751
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools) -- 752
			end -- 751
		end -- 751
	end -- 751
	return invalidArguments -- 750
end) -- 750
HttpServer:post("/agent/task/status", function(req) -- 754
	do -- 755
		local _type_0 = type(req) -- 755
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 755
		if _tab_0 then -- 755
			local sessionId -- 755
			do -- 755
				local _obj_0 = req.body -- 755
				local _type_1 = type(_obj_0) -- 755
				if "table" == _type_1 or "userdata" == _type_1 then -- 755
					sessionId = _obj_0.sessionId -- 755
				end -- 755
			end -- 755
			if sessionId ~= nil then -- 755
				local res = AgentSession.getSession(sessionId) -- 756
				if not res.success then -- 757
					return res -- 757
				end -- 757
				local taskId = res.session.currentTaskId -- 758
				local checkpoints -- 759
				if taskId then -- 759
					checkpoints = AgentTools.listCheckpoints(taskId) -- 759
				else -- 759
					checkpoints = { } -- 759
				end -- 759
				return { -- 761
					success = true, -- 761
					session = res.session, -- 762
					relatedSessions = res.relatedSessions, -- 763
					spawnInfo = res.spawnInfo, -- 764
					messages = res.messages, -- 765
					steps = res.steps, -- 766
					checkpoints = checkpoints -- 767
				} -- 760
			end -- 755
		end -- 755
	end -- 755
	return invalidArguments -- 754
end) -- 754
HttpServer:post("/agent/task/running", function() -- 769
	local res = AgentSession.listRunningSessions() -- 770
	if res.success and #res.sessions == 0 then -- 771
		res.sessions = nil -- 772
	end -- 771
	return res -- 773
end) -- 769
HttpServer:post("/agent/task/stop", function(req) -- 775
	do -- 776
		local _type_0 = type(req) -- 776
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 776
		if _tab_0 then -- 776
			local sessionId -- 776
			do -- 776
				local _obj_0 = req.body -- 776
				local _type_1 = type(_obj_0) -- 776
				if "table" == _type_1 or "userdata" == _type_1 then -- 776
					sessionId = _obj_0.sessionId -- 776
				end -- 776
			end -- 776
			if sessionId ~= nil then -- 776
				return AgentSession.stopSessionTask(sessionId) -- 777
			end -- 776
		end -- 776
	end -- 776
	return invalidArguments -- 775
end) -- 775
HttpServer:post("/agent/checkpoint/list", function(req) -- 779
	do -- 780
		local _type_0 = type(req) -- 780
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 780
		if _tab_0 then -- 780
			local taskId -- 780
			do -- 780
				local _obj_0 = req.body -- 780
				local _type_1 = type(_obj_0) -- 780
				if "table" == _type_1 or "userdata" == _type_1 then -- 780
					taskId = _obj_0.taskId -- 780
				end -- 780
			end -- 780
			local sessionId -- 780
			do -- 780
				local _obj_0 = req.body -- 780
				local _type_1 = type(_obj_0) -- 780
				if "table" == _type_1 or "userdata" == _type_1 then -- 780
					sessionId = _obj_0.sessionId -- 780
				end -- 780
			end -- 780
			if sessionId ~= nil then -- 780
				if not taskId and sessionId then -- 781
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 782
				end -- 781
				if not taskId then -- 783
					return { -- 783
						success = false, -- 783
						message = "task not found" -- 783
					} -- 783
				end -- 783
				return { -- 785
					success = true, -- 785
					taskId = taskId, -- 786
					checkpoints = AgentTools.listCheckpoints(taskId) -- 787
				} -- 784
			end -- 780
		end -- 780
	end -- 780
	return invalidArguments -- 779
end) -- 779
HttpServer:post("/agent/checkpoint/diff", function(req) -- 789
	do -- 790
		local _type_0 = type(req) -- 790
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 790
		if _tab_0 then -- 790
			local checkpointId -- 790
			do -- 790
				local _obj_0 = req.body -- 790
				local _type_1 = type(_obj_0) -- 790
				if "table" == _type_1 or "userdata" == _type_1 then -- 790
					checkpointId = _obj_0.checkpointId -- 790
				end -- 790
			end -- 790
			if checkpointId ~= nil then -- 790
				if not (checkpointId > 0) then -- 791
					return { -- 791
						success = false, -- 791
						message = "invalid checkpointId" -- 791
					} -- 791
				end -- 791
				return AgentTools.getCheckpointDiff(checkpointId) -- 792
			end -- 790
		end -- 790
	end -- 790
	return invalidArguments -- 789
end) -- 789
HttpServer:post("/agent/task/diff", function(req) -- 794
	do -- 795
		local _type_0 = type(req) -- 795
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 795
		if _tab_0 then -- 795
			local taskId -- 795
			do -- 795
				local _obj_0 = req.body -- 795
				local _type_1 = type(_obj_0) -- 795
				if "table" == _type_1 or "userdata" == _type_1 then -- 795
					taskId = _obj_0.taskId -- 795
				end -- 795
			end -- 795
			if taskId ~= nil then -- 795
				if not (taskId > 0) then -- 796
					return { -- 796
						success = false, -- 796
						message = "invalid taskId" -- 796
					} -- 796
				end -- 796
				return AgentTools.getTaskChangeSetDiff(taskId) -- 797
			end -- 795
		end -- 795
	end -- 795
	return invalidArguments -- 794
end) -- 794
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 799
	do -- 800
		local _type_0 = type(req) -- 800
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 800
		if _tab_0 then -- 800
			local sessionId -- 800
			do -- 800
				local _obj_0 = req.body -- 800
				local _type_1 = type(_obj_0) -- 800
				if "table" == _type_1 or "userdata" == _type_1 then -- 800
					sessionId = _obj_0.sessionId -- 800
				end -- 800
			end -- 800
			local checkpointId -- 800
			do -- 800
				local _obj_0 = req.body -- 800
				local _type_1 = type(_obj_0) -- 800
				if "table" == _type_1 or "userdata" == _type_1 then -- 800
					checkpointId = _obj_0.checkpointId -- 800
				end -- 800
			end -- 800
			if sessionId ~= nil and checkpointId ~= nil then -- 800
				if not (checkpointId > 0) then -- 801
					return { -- 801
						success = false, -- 801
						message = "invalid checkpointId" -- 801
					} -- 801
				end -- 801
				local res = AgentSession.getSession(sessionId) -- 802
				if not res.success then -- 803
					return res -- 803
				end -- 803
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, res.session.projectRoot) -- 804
				if not rollbackRes.success then -- 805
					return rollbackRes -- 805
				end -- 805
				return { -- 807
					success = true, -- 807
					checkpointId = rollbackRes.checkpointId -- 808
				} -- 806
			end -- 800
		end -- 800
	end -- 800
	return invalidArguments -- 799
end) -- 799
HttpServer:post("/agent/task/rollback", function(req) -- 810
	do -- 811
		local _type_0 = type(req) -- 811
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 811
		if _tab_0 then -- 811
			local sessionId -- 811
			do -- 811
				local _obj_0 = req.body -- 811
				local _type_1 = type(_obj_0) -- 811
				if "table" == _type_1 or "userdata" == _type_1 then -- 811
					sessionId = _obj_0.sessionId -- 811
				end -- 811
			end -- 811
			local taskId -- 811
			do -- 811
				local _obj_0 = req.body -- 811
				local _type_1 = type(_obj_0) -- 811
				if "table" == _type_1 or "userdata" == _type_1 then -- 811
					taskId = _obj_0.taskId -- 811
				end -- 811
			end -- 811
			if sessionId ~= nil and taskId ~= nil then -- 811
				if not (taskId > 0) then -- 812
					return { -- 812
						success = false, -- 812
						message = "invalid taskId" -- 812
					} -- 812
				end -- 812
				local res = AgentSession.getSession(sessionId) -- 813
				if not res.success then -- 814
					return res -- 814
				end -- 814
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, res.session.projectRoot) -- 815
				if not rollbackRes.success then -- 816
					return rollbackRes -- 816
				end -- 816
				return { -- 818
					success = true, -- 818
					taskId = rollbackRes.taskId, -- 819
					checkpointId = rollbackRes.checkpointId, -- 820
					checkpointCount = rollbackRes.checkpointCount -- 821
				} -- 817
			end -- 811
		end -- 811
	end -- 811
	return invalidArguments -- 810
end) -- 810
local getSearchPath -- 823
getSearchPath = function(file) -- 823
	do -- 824
		local dir = getProjectDirFromFile(file) -- 824
		if dir then -- 824
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 825
		end -- 824
	end -- 824
	return "" -- 823
end -- 823
local getSearchFolders -- 827
getSearchFolders = function(file) -- 827
	do -- 828
		local dir = getProjectDirFromFile(file) -- 828
		if dir then -- 828
			return { -- 830
				Path(dir, "Script"), -- 830
				dir -- 831
			} -- 829
		end -- 828
	end -- 828
	return { } -- 827
end -- 827
local disabledCheckForLua = { -- 834
	"incompatible number of returns", -- 834
	"unknown", -- 835
	"cannot index", -- 836
	"module not found", -- 837
	"don't know how to resolve", -- 838
	"ContainerItem", -- 839
	"cannot resolve a type", -- 840
	"invalid key", -- 841
	"inconsistent index type", -- 842
	"cannot use operator", -- 843
	"attempting ipairs loop", -- 844
	"expects record or nominal", -- 845
	"variable is not being assigned", -- 846
	"<invalid type>", -- 847
	"<any type>", -- 848
	"using the '#' operator", -- 849
	"can't match a record", -- 850
	"redeclaration of variable", -- 851
	"cannot apply pairs", -- 852
	"not a function", -- 853
	"to%-be%-closed" -- 854
} -- 833
local yueCheck -- 856
yueCheck = function(file, content, lax) -- 856
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 857
	if isTIC80 then -- 858
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 859
	end -- 858
	local searchPath = getSearchPath(file) -- 860
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 861
	local info = { } -- 862
	local globals = { } -- 863
	for _index_0 = 1, #checkResult do -- 864
		local _des_0 = checkResult[_index_0] -- 864
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 864
		if "error" == t then -- 865
			info[#info + 1] = { -- 866
				"syntax", -- 866
				file, -- 866
				line, -- 866
				col, -- 866
				msg -- 866
			} -- 866
		elseif "global" == t then -- 867
			globals[#globals + 1] = { -- 868
				msg, -- 868
				line, -- 868
				col -- 868
			} -- 868
		end -- 865
	end -- 864
	if luaCodes then -- 869
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 870
		if success then -- 871
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 872
			if not (lintResult == "") then -- 873
				lintResult = lintResult .. "\n" -- 873
			end -- 873
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 874
		else -- 875
			for _index_0 = 1, #lintResult do -- 875
				local _des_0 = lintResult[_index_0] -- 875
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 875
				if isTIC80 and tic80APIs[name] then -- 876
					goto _continue_0 -- 876
				end -- 876
				info[#info + 1] = { -- 877
					"syntax", -- 877
					file, -- 877
					line, -- 877
					col, -- 877
					"invalid global variable" -- 877
				} -- 877
				::_continue_0:: -- 876
			end -- 875
		end -- 871
	end -- 869
	return luaCodes, info -- 878
end -- 856
local luaCheck -- 880
luaCheck = function(file, content) -- 880
	local res, err = load(content, "check") -- 881
	if not res then -- 882
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 883
		return { -- 884
			success = false, -- 884
			info = { -- 884
				{ -- 884
					"syntax", -- 884
					file, -- 884
					tonumber(line), -- 884
					0, -- 884
					msg -- 884
				} -- 884
			} -- 884
		} -- 884
	end -- 882
	local success, info = teal.checkAsync(content, file, true, "") -- 885
	if info then -- 886
		do -- 887
			local _accum_0 = { } -- 887
			local _len_0 = 1 -- 887
			for _index_0 = 1, #info do -- 887
				local item = info[_index_0] -- 887
				local useCheck = true -- 888
				if not item[5]:match("unused") then -- 889
					for _index_1 = 1, #disabledCheckForLua do -- 890
						local check = disabledCheckForLua[_index_1] -- 890
						if item[5]:match(check) then -- 891
							useCheck = false -- 892
						end -- 891
					end -- 890
				end -- 889
				if not useCheck then -- 893
					goto _continue_0 -- 893
				end -- 893
				do -- 894
					local _exp_0 = item[1] -- 894
					if "type" == _exp_0 then -- 895
						item[1] = "warning" -- 896
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 897
						goto _continue_0 -- 898
					end -- 894
				end -- 894
				_accum_0[_len_0] = item -- 899
				_len_0 = _len_0 + 1 -- 888
				::_continue_0:: -- 888
			end -- 887
			info = _accum_0 -- 887
		end -- 887
		if #info == 0 then -- 900
			info = nil -- 901
			success = true -- 902
		end -- 900
	end -- 886
	return { -- 903
		success = success, -- 903
		info = info -- 903
	} -- 903
end -- 880
local luaCheckWithLineInfo -- 905
luaCheckWithLineInfo = function(file, luaCodes) -- 905
	local res = luaCheck(file, luaCodes) -- 906
	local info = { } -- 907
	if not res.success then -- 908
		local current = 1 -- 909
		local lastLine = 1 -- 910
		local lineMap = { } -- 911
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 912
			local num = lineCode:match("--%s*(%d+)%s*$") -- 913
			if num then -- 914
				lastLine = tonumber(num) -- 915
			end -- 914
			lineMap[current] = lastLine -- 916
			current = current + 1 -- 917
		end -- 912
		local _list_0 = res.info -- 918
		for _index_0 = 1, #_list_0 do -- 918
			local item = _list_0[_index_0] -- 918
			item[3] = lineMap[item[3]] or 0 -- 919
			item[4] = 0 -- 920
			info[#info + 1] = item -- 921
		end -- 918
		return false, info -- 922
	end -- 908
	return true, info -- 923
end -- 905
local getCompiledYueLine -- 925
getCompiledYueLine = function(content, line, row, file, lax) -- 925
	local luaCodes = yueCheck(file, content, lax) -- 926
	if not luaCodes then -- 927
		return nil -- 927
	end -- 927
	local current = 1 -- 928
	local lastLine = 1 -- 929
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 930
	local targetRow = nil -- 931
	local lineMap = { } -- 932
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 933
		local num = lineCode:match("--%s*(%d+)%s*$") -- 934
		if num then -- 935
			lastLine = tonumber(num) -- 935
		end -- 935
		lineMap[current] = lastLine -- 936
		if row <= lastLine and not targetRow then -- 937
			targetRow = current -- 938
			break -- 939
		end -- 937
		current = current + 1 -- 940
	end -- 933
	targetRow = current -- 941
	if targetLine and targetRow then -- 942
		return luaCodes, targetLine, targetRow, lineMap -- 943
	else -- 945
		return nil -- 945
	end -- 942
end -- 925
HttpServer:postSchedule("/check", function(req) -- 947
	do -- 948
		local _type_0 = type(req) -- 948
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 948
		if _tab_0 then -- 948
			local file -- 948
			do -- 948
				local _obj_0 = req.body -- 948
				local _type_1 = type(_obj_0) -- 948
				if "table" == _type_1 or "userdata" == _type_1 then -- 948
					file = _obj_0.file -- 948
				end -- 948
			end -- 948
			local content -- 948
			do -- 948
				local _obj_0 = req.body -- 948
				local _type_1 = type(_obj_0) -- 948
				if "table" == _type_1 or "userdata" == _type_1 then -- 948
					content = _obj_0.content -- 948
				end -- 948
			end -- 948
			if file ~= nil and content ~= nil then -- 948
				local ext = Path:getExt(file) -- 949
				if "tl" == ext then -- 950
					local searchPath = getSearchPath(file) -- 951
					do -- 952
						local isTIC80 = CheckTIC80Code(content) -- 952
						if isTIC80 then -- 952
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 953
						end -- 952
					end -- 952
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 954
					return { -- 955
						success = success, -- 955
						info = info -- 955
					} -- 955
				elseif "lua" == ext then -- 956
					do -- 957
						local isTIC80 = CheckTIC80Code(content) -- 957
						if isTIC80 then -- 957
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 958
						end -- 957
					end -- 957
					return luaCheck(file, content) -- 959
				elseif "yue" == ext then -- 960
					local luaCodes, info = yueCheck(file, content, false) -- 961
					local success = false -- 962
					if luaCodes then -- 963
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 964
						do -- 965
							local _tab_1 = { } -- 965
							local _idx_0 = #_tab_1 + 1 -- 965
							for _index_0 = 1, #info do -- 965
								local _value_0 = info[_index_0] -- 965
								_tab_1[_idx_0] = _value_0 -- 965
								_idx_0 = _idx_0 + 1 -- 965
							end -- 965
							local _idx_1 = #_tab_1 + 1 -- 965
							for _index_0 = 1, #luaInfo do -- 965
								local _value_0 = luaInfo[_index_0] -- 965
								_tab_1[_idx_1] = _value_0 -- 965
								_idx_1 = _idx_1 + 1 -- 965
							end -- 965
							info = _tab_1 -- 965
						end -- 965
						success = success and luaSuccess -- 966
					end -- 963
					if #info > 0 then -- 967
						return { -- 968
							success = success, -- 968
							info = info -- 968
						} -- 968
					else -- 970
						return { -- 970
							success = success -- 970
						} -- 970
					end -- 967
				elseif "xml" == ext then -- 971
					local success, result = xml.check(content) -- 972
					if success then -- 973
						local info -- 974
						success, info = luaCheckWithLineInfo(file, result) -- 974
						if #info > 0 then -- 975
							return { -- 976
								success = success, -- 976
								info = info -- 976
							} -- 976
						else -- 978
							return { -- 978
								success = success -- 978
							} -- 978
						end -- 975
					else -- 980
						local info -- 980
						do -- 980
							local _accum_0 = { } -- 980
							local _len_0 = 1 -- 980
							for _index_0 = 1, #result do -- 980
								local _des_0 = result[_index_0] -- 980
								local row, err = _des_0[1], _des_0[2] -- 980
								_accum_0[_len_0] = { -- 981
									"syntax", -- 981
									file, -- 981
									row, -- 981
									0, -- 981
									err -- 981
								} -- 981
								_len_0 = _len_0 + 1 -- 981
							end -- 980
							info = _accum_0 -- 980
						end -- 980
						return { -- 982
							success = false, -- 982
							info = info -- 982
						} -- 982
					end -- 973
				end -- 950
			end -- 948
		end -- 948
	end -- 948
	return { -- 947
		success = true -- 947
	} -- 947
end) -- 947
HttpServer:post("/body/parse", function(req) -- 984
	do -- 985
		local _type_0 = type(req) -- 985
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 985
		if _tab_0 then -- 985
			local file -- 985
			do -- 985
				local _obj_0 = req.body -- 985
				local _type_1 = type(_obj_0) -- 985
				if "table" == _type_1 or "userdata" == _type_1 then -- 985
					file = _obj_0.file -- 985
				end -- 985
			end -- 985
			local content -- 985
			do -- 985
				local _obj_0 = req.body -- 985
				local _type_1 = type(_obj_0) -- 985
				if "table" == _type_1 or "userdata" == _type_1 then -- 985
					content = _obj_0.content -- 985
				end -- 985
			end -- 985
			if file ~= nil and content ~= nil then -- 985
				if not (file:sub(-6) == ".b.lua") then -- 986
					return { -- 987
						success = false, -- 987
						phase = "request", -- 987
						message = "only .b.lua files can be converted" -- 987
					} -- 987
				end -- 986
				local loader, err = load("_ENV = {}\n" .. content) -- 988
				if not loader then -- 989
					return { -- 990
						success = false, -- 990
						phase = "parse", -- 990
						message = tostring(err) -- 990
					} -- 990
				end -- 989
				local ok, data = pcall(loader) -- 991
				if not ok then -- 992
					return { -- 993
						success = false, -- 993
						phase = "execute", -- 993
						message = tostring(data) -- 993
					} -- 993
				end -- 992
				if not ("table" == type(data) and data[1] == "Array") then -- 994
					return { -- 995
						success = false, -- 995
						phase = "validate", -- 995
						message = "body lua root must be {\"Array\", ...}" -- 995
					} -- 995
				end -- 994
				local text, jsonErr = json.encode(data, false, true) -- 996
				if not text then -- 997
					return { -- 998
						success = false, -- 998
						phase = "encode", -- 998
						message = tostring(jsonErr) -- 998
					} -- 998
				end -- 997
				return { -- 999
					success = true, -- 999
					json = text -- 999
				} -- 999
			end -- 985
		end -- 985
	end -- 985
	return { -- 984
		success = false, -- 984
		phase = "request", -- 984
		message = "invalid request" -- 984
	} -- 984
end) -- 984
local updateInferedDesc -- 1001
updateInferedDesc = function(infered) -- 1001
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1002
		return -- 1002
	end -- 1002
	local key, row = infered.key, infered.row -- 1003
	local codes = Content:loadAsync(key) -- 1004
	if codes then -- 1004
		local comments = { } -- 1005
		local line = 0 -- 1006
		local skipping = false -- 1007
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1008
			line = line + 1 -- 1009
			if line >= row then -- 1010
				break -- 1010
			end -- 1010
			if lineCode:match("^%s*%-%- @") then -- 1011
				skipping = true -- 1012
				goto _continue_0 -- 1013
			end -- 1011
			local result = lineCode:match("^%s*%-%- (.+)") -- 1014
			if result then -- 1014
				if not skipping then -- 1015
					comments[#comments + 1] = result -- 1015
				end -- 1015
			elseif #comments > 0 then -- 1016
				comments = { } -- 1017
				skipping = false -- 1018
			end -- 1014
			::_continue_0:: -- 1009
		end -- 1008
		infered.doc = table.concat(comments, "\n") -- 1019
	end -- 1004
end -- 1001
HttpServer:postSchedule("/infer", function(req) -- 1021
	do -- 1022
		local _type_0 = type(req) -- 1022
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1022
		if _tab_0 then -- 1022
			local lang -- 1022
			do -- 1022
				local _obj_0 = req.body -- 1022
				local _type_1 = type(_obj_0) -- 1022
				if "table" == _type_1 or "userdata" == _type_1 then -- 1022
					lang = _obj_0.lang -- 1022
				end -- 1022
			end -- 1022
			local file -- 1022
			do -- 1022
				local _obj_0 = req.body -- 1022
				local _type_1 = type(_obj_0) -- 1022
				if "table" == _type_1 or "userdata" == _type_1 then -- 1022
					file = _obj_0.file -- 1022
				end -- 1022
			end -- 1022
			local content -- 1022
			do -- 1022
				local _obj_0 = req.body -- 1022
				local _type_1 = type(_obj_0) -- 1022
				if "table" == _type_1 or "userdata" == _type_1 then -- 1022
					content = _obj_0.content -- 1022
				end -- 1022
			end -- 1022
			local line -- 1022
			do -- 1022
				local _obj_0 = req.body -- 1022
				local _type_1 = type(_obj_0) -- 1022
				if "table" == _type_1 or "userdata" == _type_1 then -- 1022
					line = _obj_0.line -- 1022
				end -- 1022
			end -- 1022
			local row -- 1022
			do -- 1022
				local _obj_0 = req.body -- 1022
				local _type_1 = type(_obj_0) -- 1022
				if "table" == _type_1 or "userdata" == _type_1 then -- 1022
					row = _obj_0.row -- 1022
				end -- 1022
			end -- 1022
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1022
				local searchPath = getSearchPath(file) -- 1023
				if "tl" == lang or "lua" == lang then -- 1024
					if CheckTIC80Code(content) then -- 1025
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1026
					end -- 1025
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1027
					if (infered ~= nil) then -- 1028
						updateInferedDesc(infered) -- 1029
						return { -- 1030
							success = true, -- 1030
							infered = infered -- 1030
						} -- 1030
					end -- 1028
				elseif "yue" == lang then -- 1031
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1032
					if not luaCodes then -- 1033
						return { -- 1033
							success = false -- 1033
						} -- 1033
					end -- 1033
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1034
					if (infered ~= nil) then -- 1035
						local col -- 1036
						file, row, col = infered.file, infered.row, infered.col -- 1036
						if file == "" and row > 0 and col > 0 then -- 1037
							infered.row = lineMap[row] or 0 -- 1038
							infered.col = 0 -- 1039
						end -- 1037
						updateInferedDesc(infered) -- 1040
						return { -- 1041
							success = true, -- 1041
							infered = infered -- 1041
						} -- 1041
					end -- 1035
				end -- 1024
			end -- 1022
		end -- 1022
	end -- 1022
	return { -- 1021
		success = false -- 1021
	} -- 1021
end) -- 1021
local _anon_func_3 = function(doc) -- 1092
	local _accum_0 = { } -- 1092
	local _len_0 = 1 -- 1092
	local _list_0 = doc.params -- 1092
	for _index_0 = 1, #_list_0 do -- 1092
		local param = _list_0[_index_0] -- 1092
		_accum_0[_len_0] = param.name -- 1092
		_len_0 = _len_0 + 1 -- 1092
	end -- 1092
	return _accum_0 -- 1092
end -- 1092
local getParamDocs -- 1043
getParamDocs = function(signatures) -- 1043
	do -- 1044
		local codes = Content:loadAsync(signatures[1].file) -- 1044
		if codes then -- 1044
			local comments = { } -- 1045
			local params = { } -- 1046
			local line = 0 -- 1047
			local docs = { } -- 1048
			local returnType = nil -- 1049
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1050
				line = line + 1 -- 1051
				local needBreak = true -- 1052
				for i, _des_0 in ipairs(signatures) do -- 1053
					local row = _des_0.row -- 1053
					if line >= row and not (docs[i] ~= nil) then -- 1054
						if #comments > 0 or #params > 0 or returnType then -- 1055
							docs[i] = { -- 1057
								doc = table.concat(comments, "  \n"), -- 1057
								returnType = returnType -- 1058
							} -- 1056
							if #params > 0 then -- 1060
								docs[i].params = params -- 1060
							end -- 1060
						else -- 1062
							docs[i] = false -- 1062
						end -- 1055
					end -- 1054
					if not docs[i] then -- 1063
						needBreak = false -- 1063
					end -- 1063
				end -- 1053
				if needBreak then -- 1064
					break -- 1064
				end -- 1064
				local result = lineCode:match("%s*%-%- (.+)") -- 1065
				if result then -- 1065
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1066
					if not name then -- 1067
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1068
					end -- 1067
					if name then -- 1069
						local pname = name -- 1070
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1071
							pname = pname .. "?" -- 1071
						end -- 1071
						params[#params + 1] = { -- 1073
							name = tostring(pname) .. ": " .. tostring(typ), -- 1073
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1074
						} -- 1072
					else -- 1077
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1077
						if typ then -- 1077
							if returnType then -- 1078
								returnType = returnType .. ", " .. typ -- 1079
							else -- 1081
								returnType = typ -- 1081
							end -- 1078
							result = result:gsub("@return", "**return:**") -- 1082
						end -- 1077
						comments[#comments + 1] = result -- 1083
					end -- 1069
				elseif #comments > 0 then -- 1084
					comments = { } -- 1085
					params = { } -- 1086
					returnType = nil -- 1087
				end -- 1065
			end -- 1050
			local results = { } -- 1088
			for _index_0 = 1, #docs do -- 1089
				local doc = docs[_index_0] -- 1089
				if not doc then -- 1090
					goto _continue_0 -- 1090
				end -- 1090
				if doc.params then -- 1091
					doc.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1092
				else -- 1094
					doc.desc = "function()" -- 1094
				end -- 1091
				if doc.returnType then -- 1095
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 1096
					doc.returnType = nil -- 1097
				end -- 1095
				results[#results + 1] = doc -- 1098
				::_continue_0:: -- 1090
			end -- 1089
			if #results > 0 then -- 1099
				return results -- 1099
			else -- 1099
				return nil -- 1099
			end -- 1099
		end -- 1044
	end -- 1044
	return nil -- 1043
end -- 1043
HttpServer:postSchedule("/signature", function(req) -- 1101
	do -- 1102
		local _type_0 = type(req) -- 1102
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1102
		if _tab_0 then -- 1102
			local lang -- 1102
			do -- 1102
				local _obj_0 = req.body -- 1102
				local _type_1 = type(_obj_0) -- 1102
				if "table" == _type_1 or "userdata" == _type_1 then -- 1102
					lang = _obj_0.lang -- 1102
				end -- 1102
			end -- 1102
			local file -- 1102
			do -- 1102
				local _obj_0 = req.body -- 1102
				local _type_1 = type(_obj_0) -- 1102
				if "table" == _type_1 or "userdata" == _type_1 then -- 1102
					file = _obj_0.file -- 1102
				end -- 1102
			end -- 1102
			local content -- 1102
			do -- 1102
				local _obj_0 = req.body -- 1102
				local _type_1 = type(_obj_0) -- 1102
				if "table" == _type_1 or "userdata" == _type_1 then -- 1102
					content = _obj_0.content -- 1102
				end -- 1102
			end -- 1102
			local line -- 1102
			do -- 1102
				local _obj_0 = req.body -- 1102
				local _type_1 = type(_obj_0) -- 1102
				if "table" == _type_1 or "userdata" == _type_1 then -- 1102
					line = _obj_0.line -- 1102
				end -- 1102
			end -- 1102
			local row -- 1102
			do -- 1102
				local _obj_0 = req.body -- 1102
				local _type_1 = type(_obj_0) -- 1102
				if "table" == _type_1 or "userdata" == _type_1 then -- 1102
					row = _obj_0.row -- 1102
				end -- 1102
			end -- 1102
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1102
				local searchPath = getSearchPath(file) -- 1103
				if "tl" == lang or "lua" == lang then -- 1104
					if CheckTIC80Code(content) then -- 1105
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1106
					end -- 1105
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1107
					if signatures then -- 1107
						signatures = getParamDocs(signatures) -- 1108
						if signatures then -- 1108
							return { -- 1109
								success = true, -- 1109
								signatures = signatures -- 1109
							} -- 1109
						end -- 1108
					end -- 1107
				elseif "yue" == lang then -- 1110
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1111
					if not luaCodes then -- 1112
						return { -- 1112
							success = false -- 1112
						} -- 1112
					end -- 1112
					do -- 1113
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1113
						if chainOp then -- 1113
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1114
							if withVar then -- 1114
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1115
							end -- 1114
						end -- 1113
					end -- 1113
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1116
					if signatures then -- 1116
						signatures = getParamDocs(signatures) -- 1117
						if signatures then -- 1117
							return { -- 1118
								success = true, -- 1118
								signatures = signatures -- 1118
							} -- 1118
						end -- 1117
					else -- 1119
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1119
						if signatures then -- 1119
							signatures = getParamDocs(signatures) -- 1120
							if signatures then -- 1120
								return { -- 1121
									success = true, -- 1121
									signatures = signatures -- 1121
								} -- 1121
							end -- 1120
						end -- 1119
					end -- 1116
				end -- 1104
			end -- 1102
		end -- 1102
	end -- 1102
	return { -- 1101
		success = false -- 1101
	} -- 1101
end) -- 1101
local luaKeywords = { -- 1124
	'and', -- 1124
	'break', -- 1125
	'do', -- 1126
	'else', -- 1127
	'elseif', -- 1128
	'end', -- 1129
	'false', -- 1130
	'for', -- 1131
	'function', -- 1132
	'goto', -- 1133
	'if', -- 1134
	'in', -- 1135
	'local', -- 1136
	'nil', -- 1137
	'not', -- 1138
	'or', -- 1139
	'repeat', -- 1140
	'return', -- 1141
	'then', -- 1142
	'true', -- 1143
	'until', -- 1144
	'while' -- 1145
} -- 1123
local tealKeywords = { -- 1149
	'record', -- 1149
	'as', -- 1150
	'is', -- 1151
	'type', -- 1152
	'embed', -- 1153
	'enum', -- 1154
	'global', -- 1155
	'any', -- 1156
	'boolean', -- 1157
	'integer', -- 1158
	'number', -- 1159
	'string', -- 1160
	'thread' -- 1161
} -- 1148
local yueKeywords = { -- 1165
	"and", -- 1165
	"break", -- 1166
	"do", -- 1167
	"else", -- 1168
	"elseif", -- 1169
	"false", -- 1170
	"for", -- 1171
	"goto", -- 1172
	"if", -- 1173
	"in", -- 1174
	"local", -- 1175
	"nil", -- 1176
	"not", -- 1177
	"or", -- 1178
	"repeat", -- 1179
	"return", -- 1180
	"then", -- 1181
	"true", -- 1182
	"until", -- 1183
	"while", -- 1184
	"as", -- 1185
	"class", -- 1186
	"continue", -- 1187
	"export", -- 1188
	"extends", -- 1189
	"from", -- 1190
	"global", -- 1191
	"import", -- 1192
	"macro", -- 1193
	"switch", -- 1194
	"try", -- 1195
	"unless", -- 1196
	"using", -- 1197
	"when", -- 1198
	"with" -- 1199
} -- 1164
local _anon_func_4 = function(f) -- 1235
	local _val_0 = Path:getExt(f) -- 1235
	return "ttf" == _val_0 or "otf" == _val_0 -- 1235
end -- 1235
local _anon_func_5 = function(suggestions) -- 1261
	local _tbl_0 = { } -- 1261
	for _index_0 = 1, #suggestions do -- 1261
		local item = suggestions[_index_0] -- 1261
		_tbl_0[item[1] .. item[2]] = item -- 1261
	end -- 1261
	return _tbl_0 -- 1261
end -- 1261
HttpServer:postSchedule("/complete", function(req) -- 1202
	do -- 1203
		local _type_0 = type(req) -- 1203
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1203
		if _tab_0 then -- 1203
			local lang -- 1203
			do -- 1203
				local _obj_0 = req.body -- 1203
				local _type_1 = type(_obj_0) -- 1203
				if "table" == _type_1 or "userdata" == _type_1 then -- 1203
					lang = _obj_0.lang -- 1203
				end -- 1203
			end -- 1203
			local file -- 1203
			do -- 1203
				local _obj_0 = req.body -- 1203
				local _type_1 = type(_obj_0) -- 1203
				if "table" == _type_1 or "userdata" == _type_1 then -- 1203
					file = _obj_0.file -- 1203
				end -- 1203
			end -- 1203
			local content -- 1203
			do -- 1203
				local _obj_0 = req.body -- 1203
				local _type_1 = type(_obj_0) -- 1203
				if "table" == _type_1 or "userdata" == _type_1 then -- 1203
					content = _obj_0.content -- 1203
				end -- 1203
			end -- 1203
			local line -- 1203
			do -- 1203
				local _obj_0 = req.body -- 1203
				local _type_1 = type(_obj_0) -- 1203
				if "table" == _type_1 or "userdata" == _type_1 then -- 1203
					line = _obj_0.line -- 1203
				end -- 1203
			end -- 1203
			local row -- 1203
			do -- 1203
				local _obj_0 = req.body -- 1203
				local _type_1 = type(_obj_0) -- 1203
				if "table" == _type_1 or "userdata" == _type_1 then -- 1203
					row = _obj_0.row -- 1203
				end -- 1203
			end -- 1203
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1203
				local searchPath = getSearchPath(file) -- 1204
				repeat -- 1205
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1206
					if lang == "yue" then -- 1207
						if not item then -- 1208
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1208
						end -- 1208
						if not item then -- 1209
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1209
						end -- 1209
					end -- 1207
					local searchType = nil -- 1210
					if not item then -- 1211
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1212
						if lang == "yue" then -- 1213
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1214
						end -- 1213
						if (item ~= nil) then -- 1215
							searchType = "Image" -- 1215
						end -- 1215
					end -- 1211
					if not item then -- 1216
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1217
						if lang == "yue" then -- 1218
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1219
						end -- 1218
						if (item ~= nil) then -- 1220
							searchType = "Font" -- 1220
						end -- 1220
					end -- 1216
					if not item then -- 1221
						break -- 1221
					end -- 1221
					local searchPaths = Content.searchPaths -- 1222
					local _list_0 = getSearchFolders(file) -- 1223
					for _index_0 = 1, #_list_0 do -- 1223
						local folder = _list_0[_index_0] -- 1223
						searchPaths[#searchPaths + 1] = folder -- 1224
					end -- 1223
					if searchType then -- 1225
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1225
					end -- 1225
					local tokens -- 1226
					do -- 1226
						local _accum_0 = { } -- 1226
						local _len_0 = 1 -- 1226
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1226
							_accum_0[_len_0] = mod -- 1226
							_len_0 = _len_0 + 1 -- 1226
						end -- 1226
						tokens = _accum_0 -- 1226
					end -- 1226
					local suggestions = { } -- 1227
					for _index_0 = 1, #searchPaths do -- 1228
						local path = searchPaths[_index_0] -- 1228
						local sPath = Path(path, table.unpack(tokens)) -- 1229
						if not Content:exist(sPath) then -- 1230
							goto _continue_0 -- 1230
						end -- 1230
						if searchType == "Font" then -- 1231
							local fontPath = Path(sPath, "Font") -- 1232
							if Content:exist(fontPath) then -- 1233
								local _list_1 = Content:getFiles(fontPath) -- 1234
								for _index_1 = 1, #_list_1 do -- 1234
									local f = _list_1[_index_1] -- 1234
									if _anon_func_4(f) then -- 1235
										if "." == f:sub(1, 1) then -- 1236
											goto _continue_1 -- 1236
										end -- 1236
										suggestions[#suggestions + 1] = { -- 1237
											Path:getName(f), -- 1237
											"font", -- 1237
											"field" -- 1237
										} -- 1237
									end -- 1235
									::_continue_1:: -- 1235
								end -- 1234
							end -- 1233
						end -- 1231
						local _list_1 = Content:getFiles(sPath) -- 1238
						for _index_1 = 1, #_list_1 do -- 1238
							local f = _list_1[_index_1] -- 1238
							if "Image" == searchType then -- 1239
								do -- 1240
									local _exp_0 = Path:getExt(f) -- 1240
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1240
										if "." == f:sub(1, 1) then -- 1241
											goto _continue_2 -- 1241
										end -- 1241
										suggestions[#suggestions + 1] = { -- 1242
											f, -- 1242
											"image", -- 1242
											"field" -- 1242
										} -- 1242
									end -- 1240
								end -- 1240
								goto _continue_2 -- 1243
							elseif "Font" == searchType then -- 1244
								do -- 1245
									local _exp_0 = Path:getExt(f) -- 1245
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1245
										if "." == f:sub(1, 1) then -- 1246
											goto _continue_2 -- 1246
										end -- 1246
										suggestions[#suggestions + 1] = { -- 1247
											f, -- 1247
											"font", -- 1247
											"field" -- 1247
										} -- 1247
									end -- 1245
								end -- 1245
								goto _continue_2 -- 1248
							end -- 1239
							local _exp_0 = Path:getExt(f) -- 1249
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1249
								local name = Path:getName(f) -- 1250
								if "d" == Path:getExt(name) then -- 1251
									goto _continue_2 -- 1251
								end -- 1251
								if "." == name:sub(1, 1) then -- 1252
									goto _continue_2 -- 1252
								end -- 1252
								suggestions[#suggestions + 1] = { -- 1253
									name, -- 1253
									"module", -- 1253
									"field" -- 1253
								} -- 1253
							end -- 1249
							::_continue_2:: -- 1239
						end -- 1238
						local _list_2 = Content:getDirs(sPath) -- 1254
						for _index_1 = 1, #_list_2 do -- 1254
							local dir = _list_2[_index_1] -- 1254
							if "." == dir:sub(1, 1) then -- 1255
								goto _continue_3 -- 1255
							end -- 1255
							suggestions[#suggestions + 1] = { -- 1256
								dir, -- 1256
								"folder", -- 1256
								"variable" -- 1256
							} -- 1256
							::_continue_3:: -- 1255
						end -- 1254
						::_continue_0:: -- 1229
					end -- 1228
					if item == "" and not searchType then -- 1257
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1258
						for _index_0 = 1, #_list_1 do -- 1258
							local _des_0 = _list_1[_index_0] -- 1258
							local name = _des_0[1] -- 1258
							suggestions[#suggestions + 1] = { -- 1259
								name, -- 1259
								"dora module", -- 1259
								"function" -- 1259
							} -- 1259
						end -- 1258
					end -- 1257
					if #suggestions > 0 then -- 1260
						do -- 1261
							local _accum_0 = { } -- 1261
							local _len_0 = 1 -- 1261
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1261
								_accum_0[_len_0] = v -- 1261
								_len_0 = _len_0 + 1 -- 1261
							end -- 1261
							suggestions = _accum_0 -- 1261
						end -- 1261
						return { -- 1262
							success = true, -- 1262
							suggestions = suggestions -- 1262
						} -- 1262
					else -- 1264
						return { -- 1264
							success = false -- 1264
						} -- 1264
					end -- 1260
				until true -- 1205
				if "tl" == lang or "lua" == lang then -- 1266
					do -- 1267
						local isTIC80 = CheckTIC80Code(content) -- 1267
						if isTIC80 then -- 1267
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1268
						end -- 1267
					end -- 1267
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1269
					if not line:match("[%.:]$") then -- 1270
						local checkSet -- 1271
						do -- 1271
							local _tbl_0 = { } -- 1271
							for _index_0 = 1, #suggestions do -- 1271
								local _des_0 = suggestions[_index_0] -- 1271
								local name = _des_0[1] -- 1271
								_tbl_0[name] = true -- 1271
							end -- 1271
							checkSet = _tbl_0 -- 1271
						end -- 1271
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1272
						for _index_0 = 1, #_list_0 do -- 1272
							local item = _list_0[_index_0] -- 1272
							if not checkSet[item[1]] then -- 1273
								suggestions[#suggestions + 1] = item -- 1273
							end -- 1273
						end -- 1272
						for _index_0 = 1, #luaKeywords do -- 1274
							local word = luaKeywords[_index_0] -- 1274
							suggestions[#suggestions + 1] = { -- 1275
								word, -- 1275
								"keyword", -- 1275
								"keyword" -- 1275
							} -- 1275
						end -- 1274
						if lang == "tl" then -- 1276
							for _index_0 = 1, #tealKeywords do -- 1277
								local word = tealKeywords[_index_0] -- 1277
								suggestions[#suggestions + 1] = { -- 1278
									word, -- 1278
									"keyword", -- 1278
									"keyword" -- 1278
								} -- 1278
							end -- 1277
						end -- 1276
					end -- 1270
					if #suggestions > 0 then -- 1279
						return { -- 1280
							success = true, -- 1280
							suggestions = suggestions -- 1280
						} -- 1280
					end -- 1279
				elseif "yue" == lang then -- 1281
					local suggestions = { } -- 1282
					local gotGlobals = false -- 1283
					do -- 1284
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1284
						if luaCodes then -- 1284
							gotGlobals = true -- 1285
							do -- 1286
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1286
								if chainOp then -- 1286
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1287
									if not withVar then -- 1288
										return { -- 1288
											success = false -- 1288
										} -- 1288
									end -- 1288
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1289
								elseif line:match("^([%.\\])$") then -- 1290
									return { -- 1291
										success = false -- 1291
									} -- 1291
								end -- 1286
							end -- 1286
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1292
							for _index_0 = 1, #_list_0 do -- 1292
								local item = _list_0[_index_0] -- 1292
								suggestions[#suggestions + 1] = item -- 1292
							end -- 1292
							if #suggestions == 0 then -- 1293
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1294
								for _index_0 = 1, #_list_1 do -- 1294
									local item = _list_1[_index_0] -- 1294
									suggestions[#suggestions + 1] = item -- 1294
								end -- 1294
							end -- 1293
						end -- 1284
					end -- 1284
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1295
						local checkSet -- 1296
						do -- 1296
							local _tbl_0 = { } -- 1296
							for _index_0 = 1, #suggestions do -- 1296
								local _des_0 = suggestions[_index_0] -- 1296
								local name = _des_0[1] -- 1296
								_tbl_0[name] = true -- 1296
							end -- 1296
							checkSet = _tbl_0 -- 1296
						end -- 1296
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1297
						for _index_0 = 1, #_list_0 do -- 1297
							local item = _list_0[_index_0] -- 1297
							if not checkSet[item[1]] then -- 1298
								suggestions[#suggestions + 1] = item -- 1298
							end -- 1298
						end -- 1297
						if not gotGlobals then -- 1299
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1300
							for _index_0 = 1, #_list_1 do -- 1300
								local item = _list_1[_index_0] -- 1300
								if not checkSet[item[1]] then -- 1301
									suggestions[#suggestions + 1] = item -- 1301
								end -- 1301
							end -- 1300
						end -- 1299
						for _index_0 = 1, #yueKeywords do -- 1302
							local word = yueKeywords[_index_0] -- 1302
							if not checkSet[word] then -- 1303
								suggestions[#suggestions + 1] = { -- 1304
									word, -- 1304
									"keyword", -- 1304
									"keyword" -- 1304
								} -- 1304
							end -- 1303
						end -- 1302
					end -- 1295
					if #suggestions > 0 then -- 1305
						return { -- 1306
							success = true, -- 1306
							suggestions = suggestions -- 1306
						} -- 1306
					end -- 1305
				elseif "xml" == lang then -- 1307
					local items = xml.complete(content) -- 1308
					if #items > 0 then -- 1309
						local suggestions -- 1310
						do -- 1310
							local _accum_0 = { } -- 1310
							local _len_0 = 1 -- 1310
							for _index_0 = 1, #items do -- 1310
								local _des_0 = items[_index_0] -- 1310
								local label, insertText = _des_0[1], _des_0[2] -- 1310
								_accum_0[_len_0] = { -- 1311
									label, -- 1311
									insertText, -- 1311
									"field" -- 1311
								} -- 1311
								_len_0 = _len_0 + 1 -- 1311
							end -- 1310
							suggestions = _accum_0 -- 1310
						end -- 1310
						return { -- 1312
							success = true, -- 1312
							suggestions = suggestions -- 1312
						} -- 1312
					end -- 1309
				end -- 1266
			end -- 1203
		end -- 1203
	end -- 1203
	return { -- 1202
		success = false -- 1202
	} -- 1202
end) -- 1202
HttpServer:upload("/upload", function(req, filename) -- 1316
	do -- 1317
		local _type_0 = type(req) -- 1317
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1317
		if _tab_0 then -- 1317
			local path -- 1317
			do -- 1317
				local _obj_0 = req.params -- 1317
				local _type_1 = type(_obj_0) -- 1317
				if "table" == _type_1 or "userdata" == _type_1 then -- 1317
					path = _obj_0.path -- 1317
				end -- 1317
			end -- 1317
			if path ~= nil then -- 1317
				local uploadPath = Path(Content.writablePath, ".upload") -- 1318
				if not Content:exist(uploadPath) then -- 1319
					Content:mkdir(uploadPath) -- 1320
				end -- 1319
				local targetPath = Path(uploadPath, filename) -- 1321
				Content:mkdir(Path:getPath(targetPath)) -- 1322
				return targetPath -- 1323
			end -- 1317
		end -- 1317
	end -- 1317
	return nil -- 1316
end, function(req, file) -- 1324
	do -- 1325
		local _type_0 = type(req) -- 1325
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1325
		if _tab_0 then -- 1325
			local path -- 1325
			do -- 1325
				local _obj_0 = req.params -- 1325
				local _type_1 = type(_obj_0) -- 1325
				if "table" == _type_1 or "userdata" == _type_1 then -- 1325
					path = _obj_0.path -- 1325
				end -- 1325
			end -- 1325
			if path ~= nil then -- 1325
				path = Path(Content.writablePath, path) -- 1326
				if Content:exist(path) then -- 1327
					local uploadPath = Path(Content.writablePath, ".upload") -- 1328
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1329
					Content:mkdir(Path:getPath(targetPath)) -- 1330
					if Content:move(file, targetPath) then -- 1331
						return true -- 1332
					end -- 1331
				end -- 1327
			end -- 1325
		end -- 1325
	end -- 1325
	return false -- 1324
end) -- 1314
HttpServer:post("/list", function(req) -- 1335
	do -- 1336
		local _type_0 = type(req) -- 1336
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1336
		if _tab_0 then -- 1336
			local path -- 1336
			do -- 1336
				local _obj_0 = req.body -- 1336
				local _type_1 = type(_obj_0) -- 1336
				if "table" == _type_1 or "userdata" == _type_1 then -- 1336
					path = _obj_0.path -- 1336
				end -- 1336
			end -- 1336
			if path ~= nil then -- 1336
				if Content:exist(path) then -- 1337
					local files = { } -- 1338
					local visitAssets -- 1339
					visitAssets = function(path, folder) -- 1339
						local dirs = Content:getDirs(path) -- 1340
						for _index_0 = 1, #dirs do -- 1341
							local dir = dirs[_index_0] -- 1341
							if dir:match("^%.") then -- 1342
								goto _continue_0 -- 1342
							end -- 1342
							local current -- 1343
							if folder == "" then -- 1343
								current = dir -- 1344
							else -- 1346
								current = Path(folder, dir) -- 1346
							end -- 1343
							files[#files + 1] = current -- 1347
							visitAssets(Path(path, dir), current) -- 1348
							::_continue_0:: -- 1342
						end -- 1341
						local fs = Content:getFiles(path) -- 1349
						for _index_0 = 1, #fs do -- 1350
							local f = fs[_index_0] -- 1350
							if (".DS_Store" == f) then -- 1351
								goto _continue_1 -- 1352
							end -- 1351
							if folder == "" then -- 1353
								files[#files + 1] = f -- 1354
							else -- 1356
								files[#files + 1] = Path(folder, f) -- 1356
							end -- 1353
							::_continue_1:: -- 1351
						end -- 1350
					end -- 1339
					visitAssets(path, "") -- 1357
					if #files == 0 then -- 1358
						files = nil -- 1358
					end -- 1358
					return { -- 1359
						success = true, -- 1359
						files = files -- 1359
					} -- 1359
				end -- 1337
			end -- 1336
		end -- 1336
	end -- 1336
	return { -- 1335
		success = false -- 1335
	} -- 1335
end) -- 1335
HttpServer:post("/info", function() -- 1361
	local Entry = require("Script.Dev.Entry") -- 1362
	local webProfiler, drawerWidth -- 1363
	do -- 1363
		local _obj_0 = Entry.getConfig() -- 1363
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 1363
	end -- 1363
	local engineDev = Entry.getEngineDev() -- 1364
	Entry.connectWebIDE() -- 1365
	return { -- 1367
		platform = App.platform, -- 1367
		locale = App.locale, -- 1368
		version = App.version, -- 1369
		engineDev = engineDev, -- 1370
		webProfiler = webProfiler, -- 1371
		drawerWidth = drawerWidth -- 1372
	} -- 1366
end) -- 1361
local ensureLLMConfigTable -- 1374
ensureLLMConfigTable = function() -- 1374
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1375
	if columns and #columns > 0 then -- 1376
		local expected = { -- 1378
			id = true, -- 1378
			name = true, -- 1379
			url = true, -- 1380
			model = true, -- 1381
			api_key = true, -- 1382
			context_window = true, -- 1383
			temperature = true, -- 1384
			max_tokens = true, -- 1385
			reasoning_effort = true, -- 1386
			custom_options = true, -- 1387
			supports_function_calling = true, -- 1388
			active = true, -- 1389
			created_at = true, -- 1390
			updated_at = true -- 1391
		} -- 1377
		local existing = { } -- 1393
		local valid = true -- 1394
		for _index_0 = 1, #columns do -- 1395
			local row = columns[_index_0] -- 1395
			local columnName = tostring(row[2]) -- 1396
			existing[columnName] = true -- 1397
			if not expected[columnName] then -- 1398
				valid = false -- 1399
				break -- 1400
			end -- 1398
		end -- 1395
		if valid then -- 1401
			if not existing.context_window then -- 1402
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1403
			end -- 1402
			if not existing.temperature then -- 1404
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1405
			end -- 1404
			if not existing.max_tokens then -- 1406
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 1407
			end -- 1406
			if not existing.reasoning_effort then -- 1408
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1409
			end -- 1408
			if not existing.custom_options then -- 1410
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1411
			end -- 1410
			if not existing.supports_function_calling then -- 1412
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1413
			end -- 1412
		else -- 1415
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1415
		end -- 1401
	end -- 1376
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
	]]) -- 1416
end -- 1374
local normalizeContextWindow -- 1435
normalizeContextWindow = function(value) -- 1435
	local contextWindow = tonumber(value) -- 1436
	if contextWindow == nil or contextWindow < 64000 then -- 1437
		return 64000 -- 1438
	end -- 1437
	return math.max(64000, math.floor(contextWindow)) -- 1439
end -- 1435
local normalizeTemperature -- 1441
normalizeTemperature = function(value) -- 1441
	local temperature = tonumber(value) -- 1442
	if temperature == nil then -- 1443
		return 0.1 -- 1444
	end -- 1443
	return math.max(0, math.min(2, temperature)) -- 1445
end -- 1441
local normalizeMaxTokens -- 1447
normalizeMaxTokens = function(value) -- 1447
	local maxTokens = tonumber(value) -- 1448
	if maxTokens == nil or maxTokens < 1 then -- 1449
		return 8192 -- 1450
	end -- 1449
	return math.max(1, math.floor(maxTokens)) -- 1451
end -- 1447
local normalizeReasoningEffort -- 1453
normalizeReasoningEffort = function(value) -- 1453
	if value == nil then -- 1454
		return "" -- 1455
	end -- 1454
	local effort = tostring(value) -- 1456
	return effort:match("^%s*(.-)%s*$") or "" -- 1457
end -- 1453
local normalizeCustomOptions -- 1459
normalizeCustomOptions = function(value) -- 1459
	if value == nil then -- 1460
		return "" -- 1461
	end -- 1460
	local options = tostring(value) -- 1462
	options = options:match("^%s*(.-)%s*$") or "" -- 1463
	return options -- 1464
end -- 1459
local validateCustomOptions -- 1466
validateCustomOptions = function(value) -- 1466
	local options = normalizeCustomOptions(value) -- 1467
	if options == "" then -- 1468
		return true -- 1468
	end -- 1468
	if not options:match("^%s*{") then -- 1469
		return false -- 1469
	end -- 1469
	local decoded = json.decode(options) -- 1470
	return type(decoded) == "table" -- 1471
end -- 1466
HttpServer:post("/llm/list", function() -- 1473
	ensureLLMConfigTable() -- 1474
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active\n		from LLMConfig\n		order by id asc") -- 1475
	local items -- 1479
	if rows and #rows > 0 then -- 1479
		local _accum_0 = { } -- 1480
		local _len_0 = 1 -- 1480
		for _index_0 = 1, #rows do -- 1480
			local _des_0 = rows[_index_0] -- 1480
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11], _des_0[12] -- 1480
			_accum_0[_len_0] = { -- 1481
				id = id, -- 1481
				name = name, -- 1481
				url = url, -- 1481
				model = model, -- 1481
				key = key, -- 1481
				contextWindow = normalizeContextWindow(contextWindow), -- 1481
				temperature = normalizeTemperature(temperature), -- 1481
				maxTokens = normalizeMaxTokens(maxTokens), -- 1481
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1481
				customOptions = normalizeCustomOptions(customOptions), -- 1481
				supportsFunctionCalling = supportsFunctionCalling ~= 0, -- 1481
				active = active ~= 0 -- 1481
			} -- 1481
			_len_0 = _len_0 + 1 -- 1481
		end -- 1480
		items = _accum_0 -- 1479
	end -- 1479
	return { -- 1482
		success = true, -- 1482
		items = items -- 1482
	} -- 1482
end) -- 1473
HttpServer:post("/llm/create", function(req) -- 1484
	ensureLLMConfigTable() -- 1485
	do -- 1486
		local _type_0 = type(req) -- 1486
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1486
		if _tab_0 then -- 1486
			local body = req.body -- 1486
			if body ~= nil then -- 1486
				local name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1487
				local now = os.time() -- 1488
				if name == nil or url == nil or model == nil or key == nil then -- 1489
					return { -- 1490
						success = false, -- 1490
						message = "invalid" -- 1490
					} -- 1490
				end -- 1489
				contextWindow = normalizeContextWindow(contextWindow) -- 1491
				temperature = normalizeTemperature(temperature) -- 1492
				maxTokens = normalizeMaxTokens(maxTokens) -- 1493
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1494
				customOptions = normalizeCustomOptions(customOptions) -- 1495
				if not validateCustomOptions(customOptions) then -- 1496
					return { -- 1496
						success = false, -- 1496
						message = "customOptions must be a JSON object" -- 1496
					} -- 1496
				end -- 1496
				if supportsFunctionCalling == false then -- 1497
					supportsFunctionCalling = 0 -- 1497
				else -- 1497
					supportsFunctionCalling = 1 -- 1497
				end -- 1497
				if active then -- 1498
					active = 1 -- 1498
				else -- 1498
					active = 0 -- 1498
				end -- 1498
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1505
					tostring(name), -- 1505
					tostring(url), -- 1506
					tostring(model), -- 1507
					tostring(key), -- 1508
					contextWindow, -- 1509
					temperature, -- 1510
					maxTokens, -- 1511
					reasoningEffort, -- 1512
					customOptions, -- 1513
					supportsFunctionCalling, -- 1514
					active, -- 1515
					now, -- 1516
					now -- 1517
				}) -- 1499
				return { -- 1519
					success = affected >= 0 -- 1519
				} -- 1519
			end -- 1486
		end -- 1486
	end -- 1486
	return { -- 1484
		success = false, -- 1484
		message = "invalid" -- 1484
	} -- 1484
end) -- 1484
HttpServer:post("/llm/update", function(req) -- 1521
	ensureLLMConfigTable() -- 1522
	do -- 1523
		local _type_0 = type(req) -- 1523
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1523
		if _tab_0 then -- 1523
			local body = req.body -- 1523
			if body ~= nil then -- 1523
				local id, name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1524
				local now = os.time() -- 1525
				id = tonumber(id) -- 1526
				if id == nil then -- 1527
					return { -- 1528
						success = false, -- 1528
						message = "invalid" -- 1528
					} -- 1528
				end -- 1527
				contextWindow = normalizeContextWindow(contextWindow) -- 1529
				temperature = normalizeTemperature(temperature) -- 1530
				maxTokens = normalizeMaxTokens(maxTokens) -- 1531
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1532
				customOptions = normalizeCustomOptions(customOptions) -- 1533
				if not validateCustomOptions(customOptions) then -- 1534
					return { -- 1534
						success = false, -- 1534
						message = "customOptions must be a JSON object" -- 1534
					} -- 1534
				end -- 1534
				if supportsFunctionCalling == false then -- 1535
					supportsFunctionCalling = 0 -- 1535
				else -- 1535
					supportsFunctionCalling = 1 -- 1535
				end -- 1535
				if active then -- 1536
					active = 1 -- 1536
				else -- 1536
					active = 0 -- 1536
				end -- 1536
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, active = ?, updated_at = ?\n			where id = ?", { -- 1541
					tostring(name), -- 1541
					tostring(url), -- 1542
					tostring(model), -- 1543
					tostring(key), -- 1544
					contextWindow, -- 1545
					temperature, -- 1546
					maxTokens, -- 1547
					reasoningEffort, -- 1548
					customOptions, -- 1549
					supportsFunctionCalling, -- 1550
					active, -- 1551
					now, -- 1552
					id -- 1553
				}) -- 1537
				return { -- 1555
					success = affected >= 0 -- 1555
				} -- 1555
			end -- 1523
		end -- 1523
	end -- 1523
	return { -- 1521
		success = false, -- 1521
		message = "invalid" -- 1521
	} -- 1521
end) -- 1521
HttpServer:post("/llm/delete", function(req) -- 1557
	ensureLLMConfigTable() -- 1558
	do -- 1559
		local _type_0 = type(req) -- 1559
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1559
		if _tab_0 then -- 1559
			local id -- 1559
			do -- 1559
				local _obj_0 = req.body -- 1559
				local _type_1 = type(_obj_0) -- 1559
				if "table" == _type_1 or "userdata" == _type_1 then -- 1559
					id = _obj_0.id -- 1559
				end -- 1559
			end -- 1559
			if id ~= nil then -- 1559
				id = tonumber(id) -- 1560
				if id == nil then -- 1561
					return { -- 1562
						success = false, -- 1562
						message = "invalid" -- 1562
					} -- 1562
				end -- 1561
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1563
					id -- 1563
				}) -- 1563
				return { -- 1564
					success = affected >= 0 -- 1564
				} -- 1564
			end -- 1559
		end -- 1559
	end -- 1559
	return { -- 1557
		success = false, -- 1557
		message = "invalid" -- 1557
	} -- 1557
end) -- 1557
HttpServer:post("/stat", function(req) -- 1566
	do -- 1567
		local _type_0 = type(req) -- 1567
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1567
		if _tab_0 then -- 1567
			local path -- 1567
			do -- 1567
				local _obj_0 = req.body -- 1567
				local _type_1 = type(_obj_0) -- 1567
				if "table" == _type_1 or "userdata" == _type_1 then -- 1567
					path = _obj_0.path -- 1567
				end -- 1567
			end -- 1567
			if path ~= nil then -- 1567
				if not Content:exist(path) then -- 1568
					return { -- 1569
						success = false, -- 1569
						message = "target not existed" -- 1569
					} -- 1569
				end -- 1568
				if Content:isdir(path) then -- 1570
					return { -- 1571
						success = false, -- 1571
						message = "failed to stat a directory" -- 1571
					} -- 1571
				end -- 1570
				local size, isBinary = Content:getAttr(path) -- 1572
				if size then -- 1572
					return { -- 1573
						success = true, -- 1573
						size = size, -- 1573
						isBinary = isBinary -- 1573
					} -- 1573
				end -- 1572
			end -- 1567
		end -- 1567
	end -- 1567
	return { -- 1566
		success = false, -- 1566
		message = "failed to stat" -- 1566
	} -- 1566
end) -- 1566
HttpServer:post("/new", function(req) -- 1575
	do -- 1576
		local _type_0 = type(req) -- 1576
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1576
		if _tab_0 then -- 1576
			local path -- 1576
			do -- 1576
				local _obj_0 = req.body -- 1576
				local _type_1 = type(_obj_0) -- 1576
				if "table" == _type_1 or "userdata" == _type_1 then -- 1576
					path = _obj_0.path -- 1576
				end -- 1576
			end -- 1576
			local content -- 1576
			do -- 1576
				local _obj_0 = req.body -- 1576
				local _type_1 = type(_obj_0) -- 1576
				if "table" == _type_1 or "userdata" == _type_1 then -- 1576
					content = _obj_0.content -- 1576
				end -- 1576
			end -- 1576
			local folder -- 1576
			do -- 1576
				local _obj_0 = req.body -- 1576
				local _type_1 = type(_obj_0) -- 1576
				if "table" == _type_1 or "userdata" == _type_1 then -- 1576
					folder = _obj_0.folder -- 1576
				end -- 1576
			end -- 1576
			if path ~= nil and content ~= nil and folder ~= nil then -- 1576
				if Content:exist(path) then -- 1577
					return { -- 1578
						success = false, -- 1578
						message = "TargetExisted" -- 1578
					} -- 1578
				end -- 1577
				local parent = Path:getPath(path) -- 1579
				local files = Content:getFiles(parent) -- 1580
				if folder then -- 1581
					local name = Path:getFilename(path):lower() -- 1582
					for _index_0 = 1, #files do -- 1583
						local file = files[_index_0] -- 1583
						if name == Path:getFilename(file):lower() then -- 1584
							return { -- 1585
								success = false, -- 1585
								message = "TargetExisted" -- 1585
							} -- 1585
						end -- 1584
					end -- 1583
					if Content:mkdir(path) then -- 1586
						return { -- 1587
							success = true -- 1587
						} -- 1587
					end -- 1586
				else -- 1589
					local name = Path:getName(path):lower() -- 1589
					for _index_0 = 1, #files do -- 1590
						local file = files[_index_0] -- 1590
						if name == Path:getName(file):lower() then -- 1591
							local ext = Path:getExt(file) -- 1592
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1593
								goto _continue_0 -- 1594
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1595
								goto _continue_0 -- 1596
							end -- 1593
							return { -- 1597
								success = false, -- 1597
								message = "SourceExisted" -- 1597
							} -- 1597
						end -- 1591
						::_continue_0:: -- 1591
					end -- 1590
					if Content:save(path, content) then -- 1598
						return { -- 1599
							success = true -- 1599
						} -- 1599
					end -- 1598
				end -- 1581
			end -- 1576
		end -- 1576
	end -- 1576
	return { -- 1575
		success = false, -- 1575
		message = "Failed" -- 1575
	} -- 1575
end) -- 1575
HttpServer:post("/delete", function(req) -- 1601
	do -- 1602
		local _type_0 = type(req) -- 1602
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1602
		if _tab_0 then -- 1602
			local path -- 1602
			do -- 1602
				local _obj_0 = req.body -- 1602
				local _type_1 = type(_obj_0) -- 1602
				if "table" == _type_1 or "userdata" == _type_1 then -- 1602
					path = _obj_0.path -- 1602
				end -- 1602
			end -- 1602
			if path ~= nil then -- 1602
				if Content:exist(path) then -- 1603
					local projectRoot -- 1604
					if Content:isdir(path) and isProjectRootDir(path) then -- 1604
						projectRoot = path -- 1604
					else -- 1604
						projectRoot = nil -- 1604
					end -- 1604
					local parent = Path:getPath(path) -- 1605
					local files = Content:getFiles(parent) -- 1606
					local name = Path:getName(path):lower() -- 1607
					local ext = Path:getExt(path) -- 1608
					for _index_0 = 1, #files do -- 1609
						local file = files[_index_0] -- 1609
						if name == Path:getName(file):lower() then -- 1610
							local _exp_0 = Path:getExt(file) -- 1611
							if "tl" == _exp_0 then -- 1611
								if ("vs" == ext) then -- 1611
									Content:remove(Path(parent, file)) -- 1612
								end -- 1611
							elseif "lua" == _exp_0 then -- 1613
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1613
									Content:remove(Path(parent, file)) -- 1614
								end -- 1613
							end -- 1611
						end -- 1610
					end -- 1609
					if Content:remove(path) then -- 1615
						if projectRoot then -- 1616
							AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1617
						end -- 1616
						return { -- 1618
							success = true -- 1618
						} -- 1618
					end -- 1615
				end -- 1603
			end -- 1602
		end -- 1602
	end -- 1602
	return { -- 1601
		success = false -- 1601
	} -- 1601
end) -- 1601
HttpServer:post("/rename", function(req) -- 1620
	do -- 1621
		local _type_0 = type(req) -- 1621
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1621
		if _tab_0 then -- 1621
			local old -- 1621
			do -- 1621
				local _obj_0 = req.body -- 1621
				local _type_1 = type(_obj_0) -- 1621
				if "table" == _type_1 or "userdata" == _type_1 then -- 1621
					old = _obj_0.old -- 1621
				end -- 1621
			end -- 1621
			local new -- 1621
			do -- 1621
				local _obj_0 = req.body -- 1621
				local _type_1 = type(_obj_0) -- 1621
				if "table" == _type_1 or "userdata" == _type_1 then -- 1621
					new = _obj_0.new -- 1621
				end -- 1621
			end -- 1621
			if old ~= nil and new ~= nil then -- 1621
				if Content:exist(old) and not Content:exist(new) then -- 1622
					local renamedDir = Content:isdir(old) -- 1623
					local parent = Path:getPath(new) -- 1624
					local files = Content:getFiles(parent) -- 1625
					if renamedDir then -- 1626
						local name = Path:getFilename(new):lower() -- 1627
						for _index_0 = 1, #files do -- 1628
							local file = files[_index_0] -- 1628
							if name == Path:getFilename(file):lower() then -- 1629
								return { -- 1630
									success = false -- 1630
								} -- 1630
							end -- 1629
						end -- 1628
					else -- 1632
						local name = Path:getName(new):lower() -- 1632
						local ext = Path:getExt(new) -- 1633
						for _index_0 = 1, #files do -- 1634
							local file = files[_index_0] -- 1634
							if name == Path:getName(file):lower() then -- 1635
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1636
									goto _continue_0 -- 1637
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1638
									goto _continue_0 -- 1639
								end -- 1636
								return { -- 1640
									success = false -- 1640
								} -- 1640
							end -- 1635
							::_continue_0:: -- 1635
						end -- 1634
					end -- 1626
					if Content:move(old, new) then -- 1641
						if renamedDir then -- 1642
							AgentSession.renameSessionsByProjectRoot(old, new) -- 1643
						end -- 1642
						local newParent = Path:getPath(new) -- 1644
						parent = Path:getPath(old) -- 1645
						files = Content:getFiles(parent) -- 1646
						local newName = Path:getName(new) -- 1647
						local oldName = Path:getName(old) -- 1648
						local name = oldName:lower() -- 1649
						local ext = Path:getExt(old) -- 1650
						for _index_0 = 1, #files do -- 1651
							local file = files[_index_0] -- 1651
							if name == Path:getName(file):lower() then -- 1652
								local _exp_0 = Path:getExt(file) -- 1653
								if "tl" == _exp_0 then -- 1653
									if ("vs" == ext) then -- 1653
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1654
									end -- 1653
								elseif "lua" == _exp_0 then -- 1655
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1655
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1656
									end -- 1655
								end -- 1653
							end -- 1652
						end -- 1651
						return { -- 1657
							success = true -- 1657
						} -- 1657
					end -- 1641
				end -- 1622
			end -- 1621
		end -- 1621
	end -- 1621
	return { -- 1620
		success = false -- 1620
	} -- 1620
end) -- 1620
HttpServer:post("/exist", function(req) -- 1659
	do -- 1660
		local _type_0 = type(req) -- 1660
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1660
		if _tab_0 then -- 1660
			local file -- 1660
			do -- 1660
				local _obj_0 = req.body -- 1660
				local _type_1 = type(_obj_0) -- 1660
				if "table" == _type_1 or "userdata" == _type_1 then -- 1660
					file = _obj_0.file -- 1660
				end -- 1660
			end -- 1660
			if file ~= nil then -- 1660
				do -- 1661
					local projFile = req.body.projFile -- 1661
					if projFile then -- 1661
						local projDir = getProjectDirFromFile(projFile) -- 1662
						if projDir then -- 1662
							local scriptDir = Path(projDir, "Script") -- 1663
							local searchPaths = Content.searchPaths -- 1664
							if Content:exist(scriptDir) then -- 1665
								Content:addSearchPath(scriptDir) -- 1665
							end -- 1665
							if Content:exist(projDir) then -- 1666
								Content:addSearchPath(projDir) -- 1666
							end -- 1666
							local _ <close> = setmetatable({ }, { -- 1667
								__close = function() -- 1667
									Content.searchPaths = searchPaths -- 1667
								end -- 1667
							}) -- 1667
							return { -- 1668
								success = Content:exist(file) -- 1668
							} -- 1668
						end -- 1662
					end -- 1661
				end -- 1661
				return { -- 1669
					success = Content:exist(file) -- 1669
				} -- 1669
			end -- 1660
		end -- 1660
	end -- 1660
	return { -- 1659
		success = false -- 1659
	} -- 1659
end) -- 1659
HttpServer:postSchedule("/read", function(req) -- 1671
	do -- 1672
		local _type_0 = type(req) -- 1672
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1672
		if _tab_0 then -- 1672
			local path -- 1672
			do -- 1672
				local _obj_0 = req.body -- 1672
				local _type_1 = type(_obj_0) -- 1672
				if "table" == _type_1 or "userdata" == _type_1 then -- 1672
					path = _obj_0.path -- 1672
				end -- 1672
			end -- 1672
			if path ~= nil then -- 1672
				local readFile -- 1673
				readFile = function() -- 1673
					if Content:exist(path) then -- 1674
						local content = Content:loadAsync(path) -- 1675
						if content then -- 1675
							return { -- 1676
								content = content, -- 1676
								success = true, -- 1676
								fullPath = Content:getFullPath(path) -- 1676
							} -- 1676
						end -- 1675
					end -- 1674
					return nil -- 1673
				end -- 1673
				do -- 1677
					local projFile = req.body.projFile -- 1677
					if projFile then -- 1677
						local projDir = getProjectDirFromFile(projFile) -- 1678
						if projDir then -- 1678
							local scriptDir = Path(projDir, "Script") -- 1679
							local searchPaths = Content.searchPaths -- 1680
							if Content:exist(scriptDir) then -- 1681
								Content:addSearchPath(scriptDir) -- 1681
							end -- 1681
							if Content:exist(projDir) then -- 1682
								Content:addSearchPath(projDir) -- 1682
							end -- 1682
							local _ <close> = setmetatable({ }, { -- 1683
								__close = function() -- 1683
									Content.searchPaths = searchPaths -- 1683
								end -- 1683
							}) -- 1683
							local result = readFile() -- 1684
							if result then -- 1684
								return result -- 1684
							end -- 1684
						end -- 1678
					end -- 1677
				end -- 1677
				local result = readFile() -- 1685
				if result then -- 1685
					return result -- 1685
				end -- 1685
			end -- 1672
		end -- 1672
	end -- 1672
	return { -- 1671
		success = false -- 1671
	} -- 1671
end) -- 1671
HttpServer:get("/read-sync", function(req) -- 1687
	do -- 1688
		local _type_0 = type(req) -- 1688
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1688
		if _tab_0 then -- 1688
			local params = req.params -- 1688
			if params ~= nil then -- 1688
				local path = params.path -- 1689
				local exts -- 1690
				if params.exts then -- 1690
					local _accum_0 = { } -- 1691
					local _len_0 = 1 -- 1691
					for ext in params.exts:gmatch("[^|]*") do -- 1691
						_accum_0[_len_0] = ext -- 1692
						_len_0 = _len_0 + 1 -- 1692
					end -- 1691
					exts = _accum_0 -- 1690
				else -- 1693
					exts = { -- 1693
						"" -- 1693
					} -- 1693
				end -- 1690
				local readFile -- 1694
				readFile = function() -- 1694
					for _index_0 = 1, #exts do -- 1695
						local ext = exts[_index_0] -- 1695
						local targetPath = path .. ext -- 1696
						if Content:exist(targetPath) then -- 1697
							local content = Content:load(targetPath) -- 1698
							if content then -- 1698
								return { -- 1699
									content = content, -- 1699
									success = true, -- 1699
									fullPath = Content:getFullPath(targetPath) -- 1699
								} -- 1699
							end -- 1698
						end -- 1697
					end -- 1695
					return nil -- 1694
				end -- 1694
				local searchPaths = Content.searchPaths -- 1700
				local _ <close> = setmetatable({ }, { -- 1701
					__close = function() -- 1701
						Content.searchPaths = searchPaths -- 1701
					end -- 1701
				}) -- 1701
				do -- 1702
					local projFile = req.params.projFile -- 1702
					if projFile then -- 1702
						local projDir = getProjectDirFromFile(projFile) -- 1703
						if projDir then -- 1703
							local scriptDir = Path(projDir, "Script") -- 1704
							if Content:exist(scriptDir) then -- 1705
								Content:addSearchPath(scriptDir) -- 1705
							end -- 1705
							if Content:exist(projDir) then -- 1706
								Content:addSearchPath(projDir) -- 1706
							end -- 1706
						else -- 1708
							projDir = Path:getPath(projFile) -- 1708
							if Content:exist(projDir) then -- 1709
								Content:addSearchPath(projDir) -- 1709
							end -- 1709
						end -- 1703
					end -- 1702
				end -- 1702
				local result = readFile() -- 1710
				if result then -- 1710
					return result -- 1710
				end -- 1710
			end -- 1688
		end -- 1688
	end -- 1688
	return { -- 1687
		success = false -- 1687
	} -- 1687
end) -- 1687
local compileFileAsync -- 1712
compileFileAsync = function(inputFile, sourceCodes) -- 1712
	local file = inputFile -- 1713
	local searchPath -- 1714
	if not Content:isAbsolutePath(inputFile) then -- 1714
		searchPath = "" -- 1715
	else -- 1716
		local dir = getProjectDirFromFile(inputFile) -- 1716
		if dir then -- 1716
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, dir) or inputFile -- 1717
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1721
		else -- 1723
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1723
			searchPath = "" -- 1726
		end -- 1716
	end -- 1714
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1727
	local yueext = yue.options.extension -- 1728
	local resultCodes = nil -- 1729
	local resultError = nil -- 1730
	do -- 1731
		local _exp_0 = Path:getExt(inputFile) -- 1731
		if yueext == _exp_0 then -- 1731
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1732
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1733
				if not codes then -- 1734
					resultError = err -- 1735
					return -- 1736
				end -- 1734
				local extraGlobal -- 1737
				if isTIC80 then -- 1737
					extraGlobal = tic80APIs -- 1737
				else -- 1737
					extraGlobal = nil -- 1737
				end -- 1737
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1738
				if not success then -- 1739
					resultError = message -- 1740
					return -- 1741
				end -- 1739
				if codes == "" then -- 1742
					resultCodes = "" -- 1743
					return nil -- 1744
				end -- 1742
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1745
				return resultCodes -- 1746
			end, function(success) -- 1733
				if not success then -- 1747
					Content:remove(outputFile) -- 1748
					if resultCodes == nil then -- 1749
						resultCodes = false -- 1750
					end -- 1749
				end -- 1747
			end) -- 1733
		elseif "tl" == _exp_0 then -- 1751
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1752
			if isTIC80 then -- 1753
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1754
			end -- 1753
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1755
			if codes then -- 1755
				if isTIC80 then -- 1756
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1757
				end -- 1756
				resultCodes = codes -- 1758
				Content:saveAsync(outputFile, codes) -- 1759
			else -- 1761
				Content:remove(outputFile) -- 1761
				resultCodes = false -- 1762
				resultError = err -- 1763
			end -- 1755
		elseif "xml" == _exp_0 then -- 1764
			local codes, err = xml.tolua(sourceCodes) -- 1765
			if codes then -- 1765
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1766
				Content:saveAsync(outputFile, resultCodes) -- 1767
			else -- 1769
				Content:remove(outputFile) -- 1769
				resultCodes = false -- 1770
				resultError = err -- 1771
			end -- 1765
		end -- 1731
	end -- 1731
	wait(function() -- 1772
		return resultCodes ~= nil -- 1772
	end) -- 1772
	if resultCodes then -- 1773
		return resultCodes -- 1774
	else -- 1776
		return nil, resultError -- 1776
	end -- 1773
	return nil -- 1712
end -- 1712
HttpServer:postSchedule("/write", function(req) -- 1778
	do -- 1779
		local _type_0 = type(req) -- 1779
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1779
		if _tab_0 then -- 1779
			local path -- 1779
			do -- 1779
				local _obj_0 = req.body -- 1779
				local _type_1 = type(_obj_0) -- 1779
				if "table" == _type_1 or "userdata" == _type_1 then -- 1779
					path = _obj_0.path -- 1779
				end -- 1779
			end -- 1779
			local content -- 1779
			do -- 1779
				local _obj_0 = req.body -- 1779
				local _type_1 = type(_obj_0) -- 1779
				if "table" == _type_1 or "userdata" == _type_1 then -- 1779
					content = _obj_0.content -- 1779
				end -- 1779
			end -- 1779
			if path ~= nil and content ~= nil then -- 1779
				if Content:saveAsync(path, content) then -- 1780
					do -- 1781
						local _exp_0 = Path:getExt(path) -- 1781
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1781
							if '' == Path:getExt(Path:getName(path)) then -- 1782
								local resultCodes = compileFileAsync(path, content) -- 1783
								return { -- 1784
									success = true, -- 1784
									resultCodes = resultCodes -- 1784
								} -- 1784
							end -- 1782
						end -- 1781
					end -- 1781
					return { -- 1785
						success = true -- 1785
					} -- 1785
				end -- 1780
			end -- 1779
		end -- 1779
	end -- 1779
	return { -- 1778
		success = false -- 1778
	} -- 1778
end) -- 1778
local getWaProjectDirFromFile = nil -- 1787
HttpServer:postSchedule("/build", function(req) -- 1789
	do -- 1790
		local _type_0 = type(req) -- 1790
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1790
		if _tab_0 then -- 1790
			local path -- 1790
			do -- 1790
				local _obj_0 = req.body -- 1790
				local _type_1 = type(_obj_0) -- 1790
				if "table" == _type_1 or "userdata" == _type_1 then -- 1790
					path = _obj_0.path -- 1790
				end -- 1790
			end -- 1790
			if path ~= nil then -- 1790
				if Content:isdir(path) then -- 1791
					local projDir = getWaProjectDirFromFile(path) -- 1792
					if projDir then -- 1792
						local message = Wasm:buildWaAsync(projDir) -- 1793
						if message == "" then -- 1794
							return { -- 1795
								success = true -- 1795
							} -- 1795
						else -- 1797
							return { -- 1797
								success = false, -- 1797
								message = message -- 1797
							} -- 1797
						end -- 1794
					end -- 1792
				end -- 1791
				local _exp_0 = Path:getExt(path) -- 1798
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1799
					if '' == Path:getExt(Path:getName(path)) then -- 1800
						local content = Content:loadAsync(path) -- 1801
						if content then -- 1801
							local resultCodes = compileFileAsync(path, content) -- 1802
							if resultCodes then -- 1802
								return { -- 1803
									success = true, -- 1803
									resultCodes = resultCodes -- 1803
								} -- 1803
							end -- 1802
						end -- 1801
					end -- 1800
				elseif "wa" == _exp_0 then -- 1804
					local projDir = getWaProjectDirFromFile(path) -- 1805
					if projDir then -- 1805
						local message = Wasm:buildWaAsync(projDir) -- 1806
						if message == "" then -- 1807
							return { -- 1808
								success = true -- 1808
							} -- 1808
						else -- 1810
							return { -- 1810
								success = false, -- 1810
								message = message -- 1810
							} -- 1810
						end -- 1807
					else -- 1812
						return { -- 1812
							success = false, -- 1812
							message = 'Wa file needs a project' -- 1812
						} -- 1812
					end -- 1805
				end -- 1798
			end -- 1790
		end -- 1790
	end -- 1790
	return { -- 1789
		success = false -- 1789
	} -- 1789
end) -- 1789
local extentionLevels = { -- 1815
	vs = 2, -- 1815
	bl = 2, -- 1816
	ts = 1, -- 1817
	tsx = 1, -- 1818
	tl = 1, -- 1819
	yue = 1, -- 1820
	xml = 1, -- 1821
	lua = 0 -- 1822
} -- 1814
HttpServer:post("/assets", function() -- 1824
	local Entry = require("Script.Dev.Entry") -- 1827
	local engineDev = Entry.getEngineDev() -- 1828
	local visitAssets -- 1829
	visitAssets = function(path, tag) -- 1829
		local isWorkspace = tag == "Workspace" -- 1830
		local builtin -- 1831
		if tag == "Builtin" then -- 1831
			builtin = true -- 1831
		else -- 1831
			builtin = nil -- 1831
		end -- 1831
		local children = nil -- 1832
		local dirs = Content:getDirs(path) -- 1833
		for _index_0 = 1, #dirs do -- 1834
			local dir = dirs[_index_0] -- 1834
			if isWorkspace then -- 1835
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1836
					goto _continue_0 -- 1837
				end -- 1836
			elseif dir == ".git" then -- 1838
				goto _continue_0 -- 1839
			end -- 1835
			if not children then -- 1840
				children = { } -- 1840
			end -- 1840
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1841
			::_continue_0:: -- 1835
		end -- 1834
		local files = Content:getFiles(path) -- 1842
		local names = { } -- 1843
		for _index_0 = 1, #files do -- 1844
			local file = files[_index_0] -- 1844
			if (".DS_Store" == file) then -- 1845
				goto _continue_1 -- 1846
			end -- 1845
			local name = Path:getName(file) -- 1847
			local ext = names[name] -- 1848
			if ext then -- 1848
				local lv1 -- 1849
				do -- 1849
					local _exp_0 = extentionLevels[ext] -- 1849
					if _exp_0 ~= nil then -- 1849
						lv1 = _exp_0 -- 1849
					else -- 1849
						lv1 = -1 -- 1849
					end -- 1849
				end -- 1849
				ext = Path:getExt(file) -- 1850
				local lv2 -- 1851
				do -- 1851
					local _exp_0 = extentionLevels[ext] -- 1851
					if _exp_0 ~= nil then -- 1851
						lv2 = _exp_0 -- 1851
					else -- 1851
						lv2 = -1 -- 1851
					end -- 1851
				end -- 1851
				if lv2 > lv1 then -- 1852
					names[name] = ext -- 1853
				elseif lv2 == lv1 then -- 1854
					names[name .. '.' .. ext] = "" -- 1855
				end -- 1852
			else -- 1857
				ext = Path:getExt(file) -- 1857
				if not extentionLevels[ext] then -- 1858
					names[file] = "" -- 1859
				else -- 1861
					names[name] = ext -- 1861
				end -- 1858
			end -- 1848
			::_continue_1:: -- 1845
		end -- 1844
		do -- 1862
			local _accum_0 = { } -- 1862
			local _len_0 = 1 -- 1862
			for name, ext in pairs(names) do -- 1862
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1862
				_len_0 = _len_0 + 1 -- 1862
			end -- 1862
			files = _accum_0 -- 1862
		end -- 1862
		for _index_0 = 1, #files do -- 1863
			local file = files[_index_0] -- 1863
			if not children then -- 1864
				children = { } -- 1864
			end -- 1864
			children[#children + 1] = { -- 1866
				key = Path(path, file), -- 1866
				dir = false, -- 1867
				title = file, -- 1868
				builtin = builtin -- 1869
			} -- 1865
		end -- 1863
		if children then -- 1871
			table.sort(children, function(a, b) -- 1872
				if a.dir == b.dir then -- 1873
					return a.title < b.title -- 1874
				else -- 1876
					return a.dir -- 1876
				end -- 1873
			end) -- 1872
		end -- 1871
		if isWorkspace and children then -- 1877
			return children -- 1878
		else -- 1880
			return { -- 1881
				key = path, -- 1881
				dir = true, -- 1882
				title = Path:getFilename(path), -- 1883
				builtin = builtin, -- 1884
				children = children -- 1885
			} -- 1880
		end -- 1877
	end -- 1829
	local zh = (App.locale:match("^zh") ~= nil) -- 1887
	return { -- 1889
		key = Content.writablePath, -- 1889
		dir = true, -- 1890
		root = true, -- 1891
		title = "Assets", -- 1892
		children = (function() -- 1894
			local _tab_0 = { -- 1894
				{ -- 1895
					key = Path(Content.assetPath), -- 1895
					dir = true, -- 1896
					builtin = true, -- 1897
					title = zh and "内置资源" or "Built-in", -- 1898
					children = { -- 1900
						(function() -- 1900
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1900
							_with_0.title = zh and "说明文档" or "Readme" -- 1901
							return _with_0 -- 1900
						end)(), -- 1900
						(function() -- 1902
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1902
							_with_0.title = zh and "接口文档" or "API Doc" -- 1903
							return _with_0 -- 1902
						end)(), -- 1902
						(function() -- 1904
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1904
							_with_0.title = zh and "开发工具" or "Tools" -- 1905
							return _with_0 -- 1904
						end)(), -- 1904
						(function() -- 1906
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1906
							_with_0.title = zh and "字体" or "Font" -- 1907
							return _with_0 -- 1906
						end)(), -- 1906
						(function() -- 1908
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1908
							_with_0.title = zh and "程序库" or "Lib" -- 1909
							if engineDev then -- 1910
								local _list_0 = _with_0.children -- 1911
								for _index_0 = 1, #_list_0 do -- 1911
									local child = _list_0[_index_0] -- 1911
									if not (child.title == "Dora") then -- 1912
										goto _continue_0 -- 1912
									end -- 1912
									local title = zh and "zh-Hans" or "en" -- 1913
									do -- 1914
										local _accum_0 = { } -- 1914
										local _len_0 = 1 -- 1914
										local _list_1 = child.children -- 1914
										for _index_1 = 1, #_list_1 do -- 1914
											local c = _list_1[_index_1] -- 1914
											if c.title ~= title then -- 1914
												_accum_0[_len_0] = c -- 1914
												_len_0 = _len_0 + 1 -- 1914
											end -- 1914
										end -- 1914
										child.children = _accum_0 -- 1914
									end -- 1914
									break -- 1915
									::_continue_0:: -- 1912
								end -- 1911
							else -- 1917
								local _accum_0 = { } -- 1917
								local _len_0 = 1 -- 1917
								local _list_0 = _with_0.children -- 1917
								for _index_0 = 1, #_list_0 do -- 1917
									local child = _list_0[_index_0] -- 1917
									if child.title ~= "Dora" then -- 1917
										_accum_0[_len_0] = child -- 1917
										_len_0 = _len_0 + 1 -- 1917
									end -- 1917
								end -- 1917
								_with_0.children = _accum_0 -- 1917
							end -- 1910
							return _with_0 -- 1908
						end)(), -- 1908
						(function() -- 1918
							if engineDev then -- 1918
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1919
								local _obj_0 = _with_0.children -- 1920
								_obj_0[#_obj_0 + 1] = { -- 1921
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1921
									dir = false, -- 1922
									builtin = true, -- 1923
									title = "init.yue" -- 1924
								} -- 1920
								return _with_0 -- 1919
							end -- 1918
						end)() -- 1918
					} -- 1899
				} -- 1894
			} -- 1928
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1928
			local _idx_0 = #_tab_0 + 1 -- 1928
			for _index_0 = 1, #_obj_0 do -- 1928
				local _value_0 = _obj_0[_index_0] -- 1928
				_tab_0[_idx_0] = _value_0 -- 1928
				_idx_0 = _idx_0 + 1 -- 1928
			end -- 1928
			return _tab_0 -- 1894
		end)() -- 1893
	} -- 1888
end) -- 1824
HttpServer:post("/entry/list", function() -- 1932
	local Entry = require("Script.Dev.Entry") -- 1933
	local res = Entry.getLaunchEntries() -- 1934
	res.success = true -- 1935
	return res -- 1936
end) -- 1932
HttpServer:post("/run/status", function() -- 1938
	local Entry = require("Script.Dev.Entry") -- 1939
	return Entry.getCurrentEntryStatus() -- 1940
end) -- 1938
HttpServer:postSchedule("/run", function(req) -- 1942
	do -- 1943
		local _type_0 = type(req) -- 1943
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1943
		if _tab_0 then -- 1943
			local file -- 1943
			do -- 1943
				local _obj_0 = req.body -- 1943
				local _type_1 = type(_obj_0) -- 1943
				if "table" == _type_1 or "userdata" == _type_1 then -- 1943
					file = _obj_0.file -- 1943
				end -- 1943
			end -- 1943
			local asProj -- 1943
			do -- 1943
				local _obj_0 = req.body -- 1943
				local _type_1 = type(_obj_0) -- 1943
				if "table" == _type_1 or "userdata" == _type_1 then -- 1943
					asProj = _obj_0.asProj -- 1943
				end -- 1943
			end -- 1943
			if file ~= nil and asProj ~= nil then -- 1943
				if not Content:isAbsolutePath(file) then -- 1944
					local devFile = Path(Content.writablePath, file) -- 1945
					if Content:exist(devFile) then -- 1946
						file = devFile -- 1946
					end -- 1946
				end -- 1944
				local Entry = require("Script.Dev.Entry") -- 1947
				local workDir -- 1948
				if asProj then -- 1949
					workDir = getProjectDirFromFile(file) -- 1950
					if workDir then -- 1950
						Entry.allClear() -- 1951
						local target = Path(workDir, "init") -- 1952
						local success, err = Entry.enterEntryAsync({ -- 1953
							entryName = "Project", -- 1953
							fileName = target, -- 1953
							workDir = workDir, -- 1953
							projectRoot = workDir, -- 1953
							runKind = "project" -- 1953
						}) -- 1953
						target = Path:getName(Path:getPath(target)) -- 1954
						return { -- 1955
							success = success, -- 1955
							target = target, -- 1955
							err = err -- 1955
						} -- 1955
					end -- 1950
				else -- 1957
					workDir = getProjectDirFromFile(file) -- 1957
					if not workDir and Path:getExt(file) == "wasm" then -- 1958
						local parent = Path:getPath(file) -- 1959
						if Content:exist(Path(parent, "wa.mod")) then -- 1960
							workDir = parent -- 1961
						end -- 1960
					end -- 1958
				end -- 1949
				Entry.allClear() -- 1962
				file = Path:replaceExt(file, "") -- 1963
				local entry = { -- 1965
					entryName = Path:getName(file), -- 1965
					fileName = file, -- 1966
					runKind = "file" -- 1967
				} -- 1964
				if workDir then -- 1968
					entry.workDir = workDir -- 1969
					entry.projectRoot = workDir -- 1970
				end -- 1968
				local success, err = Entry.enterEntryAsync(entry) -- 1971
				return { -- 1972
					success = success, -- 1972
					err = err -- 1972
				} -- 1972
			end -- 1943
		end -- 1943
	end -- 1943
	return { -- 1942
		success = false -- 1942
	} -- 1942
end) -- 1942
HttpServer:postSchedule("/stop", function() -- 1974
	local Entry = require("Script.Dev.Entry") -- 1975
	return { -- 1976
		success = Entry.stop() -- 1976
	} -- 1976
end) -- 1974
local minifyAsync -- 1978
minifyAsync = function(sourcePath, minifyPath) -- 1978
	if not Content:exist(sourcePath) then -- 1979
		return -- 1979
	end -- 1979
	local Entry = require("Script.Dev.Entry") -- 1980
	local errors = { } -- 1981
	local files = Entry.getAllFiles(sourcePath, { -- 1982
		"lua" -- 1982
	}, true) -- 1982
	do -- 1983
		local _accum_0 = { } -- 1983
		local _len_0 = 1 -- 1983
		for _index_0 = 1, #files do -- 1983
			local file = files[_index_0] -- 1983
			if file:sub(1, 1) ~= '.' then -- 1983
				_accum_0[_len_0] = file -- 1983
				_len_0 = _len_0 + 1 -- 1983
			end -- 1983
		end -- 1983
		files = _accum_0 -- 1983
	end -- 1983
	local paths -- 1984
	do -- 1984
		local _tbl_0 = { } -- 1984
		for _index_0 = 1, #files do -- 1984
			local file = files[_index_0] -- 1984
			_tbl_0[Path:getPath(file)] = true -- 1984
		end -- 1984
		paths = _tbl_0 -- 1984
	end -- 1984
	for path in pairs(paths) do -- 1985
		Content:mkdir(Path(minifyPath, path)) -- 1985
	end -- 1985
	local _ <close> = setmetatable({ }, { -- 1986
		__close = function() -- 1986
			package.loaded["luaminify.FormatMini"] = nil -- 1987
			package.loaded["luaminify.ParseLua"] = nil -- 1988
			package.loaded["luaminify.Scope"] = nil -- 1989
			package.loaded["luaminify.Util"] = nil -- 1990
		end -- 1986
	}) -- 1986
	local FormatMini -- 1991
	do -- 1991
		local _obj_0 = require("luaminify") -- 1991
		FormatMini = _obj_0.FormatMini -- 1991
	end -- 1991
	local fileCount = #files -- 1992
	local count = 0 -- 1993
	for _index_0 = 1, #files do -- 1994
		local file = files[_index_0] -- 1994
		thread(function() -- 1995
			local _ <close> = setmetatable({ }, { -- 1996
				__close = function() -- 1996
					count = count + 1 -- 1996
				end -- 1996
			}) -- 1996
			local input = Path(sourcePath, file) -- 1997
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1998
			if Content:exist(input) then -- 1999
				local sourceCodes = Content:loadAsync(input) -- 2000
				local res, err = FormatMini(sourceCodes) -- 2001
				if res then -- 2002
					Content:saveAsync(output, res) -- 2003
					return print("Minify " .. tostring(file)) -- 2004
				else -- 2006
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2006
				end -- 2002
			else -- 2008
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2008
			end -- 1999
		end) -- 1995
		sleep() -- 2009
	end -- 1994
	wait(function() -- 2010
		return count == fileCount -- 2010
	end) -- 2010
	if #errors > 0 then -- 2011
		print(table.concat(errors, '\n')) -- 2012
	end -- 2011
	print("Obfuscation done.") -- 2013
	return files -- 2014
end -- 1978
local zipping = false -- 2016
HttpServer:postSchedule("/zip", function(req) -- 2018
	do -- 2019
		local _type_0 = type(req) -- 2019
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2019
		if _tab_0 then -- 2019
			local path -- 2019
			do -- 2019
				local _obj_0 = req.body -- 2019
				local _type_1 = type(_obj_0) -- 2019
				if "table" == _type_1 or "userdata" == _type_1 then -- 2019
					path = _obj_0.path -- 2019
				end -- 2019
			end -- 2019
			local zipFile -- 2019
			do -- 2019
				local _obj_0 = req.body -- 2019
				local _type_1 = type(_obj_0) -- 2019
				if "table" == _type_1 or "userdata" == _type_1 then -- 2019
					zipFile = _obj_0.zipFile -- 2019
				end -- 2019
			end -- 2019
			local obfuscated -- 2019
			do -- 2019
				local _obj_0 = req.body -- 2019
				local _type_1 = type(_obj_0) -- 2019
				if "table" == _type_1 or "userdata" == _type_1 then -- 2019
					obfuscated = _obj_0.obfuscated -- 2019
				end -- 2019
			end -- 2019
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2019
				if zipping then -- 2020
					goto failed -- 2020
				end -- 2020
				zipping = true -- 2021
				local _ <close> = setmetatable({ }, { -- 2022
					__close = function() -- 2022
						zipping = false -- 2022
					end -- 2022
				}) -- 2022
				if not Content:exist(path) then -- 2023
					goto failed -- 2023
				end -- 2023
				Content:mkdir(Path:getPath(zipFile)) -- 2024
				if obfuscated then -- 2025
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2026
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2027
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2028
					Content:remove(scriptPath) -- 2029
					Content:remove(obfuscatedPath) -- 2030
					Content:remove(tempPath) -- 2031
					Content:mkdir(scriptPath) -- 2032
					Content:mkdir(obfuscatedPath) -- 2033
					Content:mkdir(tempPath) -- 2034
					if not Content:copyAsync(path, tempPath) then -- 2035
						goto failed -- 2035
					end -- 2035
					local Entry = require("Script.Dev.Entry") -- 2036
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2037
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2038
						"tl", -- 2038
						"yue", -- 2038
						"lua", -- 2038
						"ts", -- 2038
						"tsx", -- 2038
						"vs", -- 2038
						"bl", -- 2038
						"xml", -- 2038
						"wa", -- 2038
						"mod" -- 2038
					}, true) -- 2038
					for _index_0 = 1, #scriptFiles do -- 2039
						local file = scriptFiles[_index_0] -- 2039
						Content:remove(Path(tempPath, file)) -- 2040
					end -- 2039
					for _index_0 = 1, #luaFiles do -- 2041
						local file = luaFiles[_index_0] -- 2041
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2042
					end -- 2041
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2043
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2044
					end) then -- 2043
						goto failed -- 2043
					end -- 2043
					return { -- 2045
						success = true -- 2045
					} -- 2045
				else -- 2047
					return { -- 2047
						success = Content:zipAsync(path, zipFile, function(file) -- 2047
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2048
						end) -- 2047
					} -- 2047
				end -- 2025
			end -- 2019
		end -- 2019
	end -- 2019
	::failed:: -- 2049
	return { -- 2018
		success = false -- 2018
	} -- 2018
end) -- 2018
HttpServer:postSchedule("/unzip", function(req) -- 2051
	do -- 2052
		local _type_0 = type(req) -- 2052
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2052
		if _tab_0 then -- 2052
			local zipFile -- 2052
			do -- 2052
				local _obj_0 = req.body -- 2052
				local _type_1 = type(_obj_0) -- 2052
				if "table" == _type_1 or "userdata" == _type_1 then -- 2052
					zipFile = _obj_0.zipFile -- 2052
				end -- 2052
			end -- 2052
			local path -- 2052
			do -- 2052
				local _obj_0 = req.body -- 2052
				local _type_1 = type(_obj_0) -- 2052
				if "table" == _type_1 or "userdata" == _type_1 then -- 2052
					path = _obj_0.path -- 2052
				end -- 2052
			end -- 2052
			if zipFile ~= nil and path ~= nil then -- 2052
				return { -- 2053
					success = Content:unzipAsync(zipFile, path, function(file) -- 2053
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2054
					end) -- 2053
				} -- 2053
			end -- 2052
		end -- 2052
	end -- 2052
	return { -- 2051
		success = false -- 2051
	} -- 2051
end) -- 2051
HttpServer:post("/editing-info", function(req) -- 2056
	local Entry = require("Script.Dev.Entry") -- 2057
	local config = Entry.getConfig() -- 2058
	local _type_0 = type(req) -- 2059
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2059
	local _match_0 = false -- 2059
	if _tab_0 then -- 2059
		local editingInfo -- 2059
		do -- 2059
			local _obj_0 = req.body -- 2059
			local _type_1 = type(_obj_0) -- 2059
			if "table" == _type_1 or "userdata" == _type_1 then -- 2059
				editingInfo = _obj_0.editingInfo -- 2059
			end -- 2059
		end -- 2059
		if editingInfo ~= nil then -- 2059
			_match_0 = true -- 2059
			config.editingInfo = editingInfo -- 2060
			return { -- 2061
				success = true -- 2061
			} -- 2061
		end -- 2059
	end -- 2059
	if not _match_0 then -- 2059
		if not (config.editingInfo ~= nil) then -- 2063
			local folder -- 2064
			if App.locale:match('^zh') then -- 2064
				folder = 'zh-Hans' -- 2064
			else -- 2064
				folder = 'en' -- 2064
			end -- 2064
			config.editingInfo = json.encode({ -- 2066
				index = 0, -- 2066
				files = { -- 2068
					{ -- 2069
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2069
						title = "welcome.md" -- 2070
					} -- 2068
				} -- 2067
			}) -- 2065
		end -- 2063
		return { -- 2074
			success = true, -- 2074
			editingInfo = config.editingInfo -- 2074
		} -- 2074
	end -- 2059
end) -- 2056
HttpServer:post("/command", function(req) -- 2076
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
			local log -- 2077
			do -- 2077
				local _obj_0 = req.body -- 2077
				local _type_1 = type(_obj_0) -- 2077
				if "table" == _type_1 or "userdata" == _type_1 then -- 2077
					log = _obj_0.log -- 2077
				end -- 2077
			end -- 2077
			if code ~= nil and log ~= nil then -- 2077
				emit("AppCommand", code, log) -- 2078
				return { -- 2079
					success = true -- 2079
				} -- 2079
			end -- 2077
		end -- 2077
	end -- 2077
	return { -- 2076
		success = false -- 2076
	} -- 2076
end) -- 2076
HttpServer:post("/log/save", function() -- 2081
	local folder = ".download" -- 2082
	local fullLogFile = "dora_full_logs.txt" -- 2083
	local fullFolder = Path(Content.writablePath, folder) -- 2084
	Content:mkdir(fullFolder) -- 2085
	local logPath = Path(fullFolder, fullLogFile) -- 2086
	if App:saveLog(logPath) then -- 2087
		return { -- 2088
			success = true, -- 2088
			path = Path(folder, fullLogFile) -- 2088
		} -- 2088
	end -- 2087
	return { -- 2081
		success = false -- 2081
	} -- 2081
end) -- 2081
HttpServer:post("/yarn/check", function(req) -- 2090
	local yarncompile = require("yarncompile") -- 2091
	do -- 2092
		local _type_0 = type(req) -- 2092
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2092
		if _tab_0 then -- 2092
			local code -- 2092
			do -- 2092
				local _obj_0 = req.body -- 2092
				local _type_1 = type(_obj_0) -- 2092
				if "table" == _type_1 or "userdata" == _type_1 then -- 2092
					code = _obj_0.code -- 2092
				end -- 2092
			end -- 2092
			if code ~= nil then -- 2092
				local jsonObject = json.decode(code) -- 2093
				if jsonObject then -- 2093
					local errors = { } -- 2094
					local _list_0 = jsonObject.nodes -- 2095
					for _index_0 = 1, #_list_0 do -- 2095
						local node = _list_0[_index_0] -- 2095
						local title, body = node.title, node.body -- 2096
						local luaCode, err = yarncompile(body) -- 2097
						if not luaCode then -- 2097
							errors[#errors + 1] = title .. ":" .. err -- 2098
						end -- 2097
					end -- 2095
					return { -- 2099
						success = true, -- 2099
						syntaxError = table.concat(errors, "\n\n") -- 2099
					} -- 2099
				end -- 2093
			end -- 2092
		end -- 2092
	end -- 2092
	return { -- 2090
		success = false -- 2090
	} -- 2090
end) -- 2090
HttpServer:post("/yarn/check-file", function(req) -- 2101
	local yarncompile = require("yarncompile") -- 2102
	do -- 2103
		local _type_0 = type(req) -- 2103
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2103
		if _tab_0 then -- 2103
			local code -- 2103
			do -- 2103
				local _obj_0 = req.body -- 2103
				local _type_1 = type(_obj_0) -- 2103
				if "table" == _type_1 or "userdata" == _type_1 then -- 2103
					code = _obj_0.code -- 2103
				end -- 2103
			end -- 2103
			if code ~= nil then -- 2103
				local res, _, err = yarncompile(code, true) -- 2104
				if not res then -- 2104
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2105
					return { -- 2106
						success = false, -- 2106
						message = message, -- 2106
						line = line, -- 2106
						column = column, -- 2106
						node = node -- 2106
					} -- 2106
				end -- 2104
			end -- 2103
		end -- 2103
	end -- 2103
	return { -- 2101
		success = true -- 2101
	} -- 2101
end) -- 2101
getWaProjectDirFromFile = function(file) -- 2108
	local current -- 2109
	if Content:isdir(file) then -- 2109
		current = file -- 2109
	else -- 2109
		current = Path:getPath(file) -- 2109
	end -- 2109
	if current == "" then -- 2110
		return nil -- 2110
	end -- 2110
	repeat -- 2111
		local modPath = Path(current, "wa.mod") -- 2112
		if Content:exist(modPath) then -- 2113
			return current, modPath -- 2114
		end -- 2113
		local parent = Path:getPath(current) -- 2115
		if parent == "" or parent == current then -- 2116
			break -- 2116
		end -- 2116
		current = parent -- 2117
	until false -- 2111
	return nil -- 2119
end -- 2108
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2121
	do -- 2122
		local _type_0 = type(req) -- 2122
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2122
		if _tab_0 then -- 2122
			local path -- 2122
			do -- 2122
				local _obj_0 = req.body -- 2122
				local _type_1 = type(_obj_0) -- 2122
				if "table" == _type_1 or "userdata" == _type_1 then -- 2122
					path = _obj_0.path -- 2122
				end -- 2122
			end -- 2122
			if path ~= nil then -- 2122
				local projDir = getWaProjectDirFromFile(path) -- 2123
				if projDir then -- 2123
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2124
					if not Content:exist(sourceDoraPath) then -- 2125
						return { -- 2126
							success = false, -- 2126
							message = "missing dora template" -- 2126
						} -- 2126
					end -- 2125
					local targetVendorPath = Path(projDir, "vendor") -- 2127
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2128
					if not Content:exist(targetVendorPath) then -- 2129
						if not Content:mkdir(targetVendorPath) then -- 2130
							return { -- 2131
								success = false, -- 2131
								message = "failed to create vendor folder" -- 2131
							} -- 2131
						end -- 2130
					elseif not Content:isdir(targetVendorPath) then -- 2132
						return { -- 2133
							success = false, -- 2133
							message = "vendor path is not a folder" -- 2133
						} -- 2133
					end -- 2129
					if Content:exist(targetDoraPath) then -- 2134
						if not Content:remove(targetDoraPath) then -- 2135
							return { -- 2136
								success = false, -- 2136
								message = "failed to remove old dora" -- 2136
							} -- 2136
						end -- 2135
					end -- 2134
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2137
						return { -- 2138
							success = false, -- 2138
							message = "failed to copy dora" -- 2138
						} -- 2138
					end -- 2137
					return { -- 2139
						success = true -- 2139
					} -- 2139
				else -- 2141
					return { -- 2141
						success = false, -- 2141
						message = 'Wa file needs a project' -- 2141
					} -- 2141
				end -- 2123
			end -- 2122
		end -- 2122
	end -- 2122
	return { -- 2121
		success = false, -- 2121
		message = "invalid call" -- 2121
	} -- 2121
end) -- 2121
HttpServer:postSchedule("/wa/build", function(req) -- 2143
	do -- 2144
		local _type_0 = type(req) -- 2144
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2144
		if _tab_0 then -- 2144
			local path -- 2144
			do -- 2144
				local _obj_0 = req.body -- 2144
				local _type_1 = type(_obj_0) -- 2144
				if "table" == _type_1 or "userdata" == _type_1 then -- 2144
					path = _obj_0.path -- 2144
				end -- 2144
			end -- 2144
			if path ~= nil then -- 2144
				local projDir = getWaProjectDirFromFile(path) -- 2145
				if projDir then -- 2145
					local message = Wasm:buildWaAsync(projDir) -- 2146
					if message == "" then -- 2147
						return { -- 2148
							success = true -- 2148
						} -- 2148
					else -- 2150
						return { -- 2150
							success = false, -- 2150
							message = message -- 2150
						} -- 2150
					end -- 2147
				else -- 2152
					return { -- 2152
						success = false, -- 2152
						message = 'Wa file needs a project' -- 2152
					} -- 2152
				end -- 2145
			end -- 2144
		end -- 2144
	end -- 2144
	return { -- 2153
		success = false, -- 2153
		message = 'failed to build' -- 2153
	} -- 2153
end) -- 2143
HttpServer:postSchedule("/wa/format", function(req) -- 2155
	do -- 2156
		local _type_0 = type(req) -- 2156
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2156
		if _tab_0 then -- 2156
			local file -- 2156
			do -- 2156
				local _obj_0 = req.body -- 2156
				local _type_1 = type(_obj_0) -- 2156
				if "table" == _type_1 or "userdata" == _type_1 then -- 2156
					file = _obj_0.file -- 2156
				end -- 2156
			end -- 2156
			if file ~= nil then -- 2156
				local code = Wasm:formatWaAsync(file) -- 2157
				if code == "" then -- 2158
					return { -- 2159
						success = false -- 2159
					} -- 2159
				else -- 2161
					return { -- 2161
						success = true, -- 2161
						code = code -- 2161
					} -- 2161
				end -- 2158
			end -- 2156
		end -- 2156
	end -- 2156
	return { -- 2162
		success = false -- 2162
	} -- 2162
end) -- 2155
HttpServer:postSchedule("/wa/create", function(req) -- 2164
	do -- 2165
		local _type_0 = type(req) -- 2165
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2165
		if _tab_0 then -- 2165
			local path -- 2165
			do -- 2165
				local _obj_0 = req.body -- 2165
				local _type_1 = type(_obj_0) -- 2165
				if "table" == _type_1 or "userdata" == _type_1 then -- 2165
					path = _obj_0.path -- 2165
				end -- 2165
			end -- 2165
			if path ~= nil then -- 2165
				if not Content:exist(Path:getPath(path)) then -- 2166
					return { -- 2167
						success = false, -- 2167
						message = "target path not existed" -- 2167
					} -- 2167
				end -- 2166
				if Content:exist(path) then -- 2168
					return { -- 2169
						success = false, -- 2169
						message = "target project folder existed" -- 2169
					} -- 2169
				end -- 2168
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2170
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2171
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2172
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2173
					return { -- 2176
						success = false, -- 2176
						message = "missing template project" -- 2176
					} -- 2176
				end -- 2173
				if not Content:mkdir(path) then -- 2177
					return { -- 2178
						success = false, -- 2178
						message = "failed to create project folder" -- 2178
					} -- 2178
				end -- 2177
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2179
					Content:remove(path) -- 2180
					return { -- 2181
						success = false, -- 2181
						message = "failed to copy template" -- 2181
					} -- 2181
				end -- 2179
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2182
					Content:remove(path) -- 2183
					return { -- 2184
						success = false, -- 2184
						message = "failed to copy template" -- 2184
					} -- 2184
				end -- 2182
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2185
					Content:remove(path) -- 2186
					return { -- 2187
						success = false, -- 2187
						message = "failed to copy template" -- 2187
					} -- 2187
				end -- 2185
				return { -- 2188
					success = true -- 2188
				} -- 2188
			end -- 2165
		end -- 2165
	end -- 2165
	return { -- 2164
		success = false, -- 2164
		message = "invalid call" -- 2164
	} -- 2164
end) -- 2164
local tsBuildGlobs = { -- 2191
	"**/*.ts", -- 2191
	"**/*.tsx", -- 2192
	"!**/.*/**", -- 2193
	"!**/node_modules/**" -- 2194
} -- 2190
local _anon_func_6 = function(path) -- 2203
	local _val_0 = Path:getExt(path) -- 2203
	return "ts" == _val_0 or "tsx" == _val_0 -- 2203
end -- 2203
HttpServer:postSchedule("/ts/build", function(req) -- 2196
	do -- 2197
		local _type_0 = type(req) -- 2197
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2197
		if _tab_0 then -- 2197
			local path -- 2197
			do -- 2197
				local _obj_0 = req.body -- 2197
				local _type_1 = type(_obj_0) -- 2197
				if "table" == _type_1 or "userdata" == _type_1 then -- 2197
					path = _obj_0.path -- 2197
				end -- 2197
			end -- 2197
			if path ~= nil then -- 2197
				if HttpServer.wsConnectionCount == 0 then -- 2198
					return { -- 2199
						success = false, -- 2199
						message = "Web IDE not connected" -- 2199
					} -- 2199
				end -- 2198
				if not Content:exist(path) then -- 2200
					return { -- 2201
						success = false, -- 2201
						message = "path not existed" -- 2201
					} -- 2201
				end -- 2200
				if not Content:isdir(path) then -- 2202
					if not (_anon_func_6(path)) then -- 2203
						return { -- 2204
							success = false, -- 2204
							message = "expecting a TypeScript file" -- 2204
						} -- 2204
					end -- 2203
					local messages = { } -- 2205
					local content = Content:load(path) -- 2206
					if not content then -- 2207
						return { -- 2208
							success = false, -- 2208
							message = "failed to read file" -- 2208
						} -- 2208
					end -- 2207
					emit("AppWS", "Send", json.encode({ -- 2209
						name = "UpdateFile", -- 2209
						file = path, -- 2209
						exists = true, -- 2209
						content = content -- 2209
					})) -- 2209
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2210
						local done = false -- 2211
						do -- 2212
							local _with_0 = Node() -- 2212
							_with_0:gslot("AppWS", function(event) -- 2213
								if event.type == "Receive" then -- 2214
									local res = json.decode(event.msg) -- 2215
									if res then -- 2215
										if res.name == "TranspileTS" and res.file == path then -- 2216
											_with_0:removeFromParent() -- 2217
											if res.success then -- 2218
												local luaFile = Path:replaceExt(path, "lua") -- 2219
												Content:save(luaFile, res.luaCode) -- 2220
												messages[#messages + 1] = { -- 2221
													success = true, -- 2221
													file = path -- 2221
												} -- 2221
											else -- 2223
												messages[#messages + 1] = { -- 2223
													success = false, -- 2223
													file = path, -- 2223
													message = res.message -- 2223
												} -- 2223
											end -- 2218
											done = true -- 2224
										end -- 2216
									end -- 2215
								end -- 2214
							end) -- 2213
						end -- 2212
						emit("AppWS", "Send", json.encode({ -- 2225
							name = "TranspileTS", -- 2225
							file = path, -- 2225
							content = content -- 2225
						})) -- 2225
						wait(function() -- 2226
							return done -- 2226
						end) -- 2226
					end -- 2210
					return { -- 2227
						success = true, -- 2227
						messages = messages -- 2227
					} -- 2227
				else -- 2229
					local fileData = { } -- 2229
					local messages = { } -- 2230
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2231
					for _index_0 = 1, #_list_0 do -- 2231
						local subFile = _list_0[_index_0] -- 2231
						local file = Path(path, subFile) -- 2232
						local content = Content:load(file) -- 2233
						if content then -- 2233
							fileData[file] = content -- 2234
							emit("AppWS", "Send", json.encode({ -- 2235
								name = "UpdateFile", -- 2235
								file = file, -- 2235
								exists = true, -- 2235
								content = content -- 2235
							})) -- 2235
						else -- 2237
							messages[#messages + 1] = { -- 2237
								success = false, -- 2237
								file = file, -- 2237
								message = "failed to read file" -- 2237
							} -- 2237
						end -- 2233
					end -- 2231
					for file, content in pairs(fileData) do -- 2238
						if "d" == Path:getExt(Path:getName(file)) then -- 2239
							goto _continue_0 -- 2239
						end -- 2239
						local done = false -- 2240
						do -- 2241
							local _with_0 = Node() -- 2241
							_with_0:gslot("AppWS", function(event) -- 2242
								if event.type == "Receive" then -- 2243
									local res = json.decode(event.msg) -- 2244
									if res then -- 2244
										if res.name == "TranspileTS" and res.file == file then -- 2245
											_with_0:removeFromParent() -- 2246
											if res.success then -- 2247
												local luaFile = Path:replaceExt(file, "lua") -- 2248
												Content:save(luaFile, res.luaCode) -- 2249
												messages[#messages + 1] = { -- 2250
													success = true, -- 2250
													file = file -- 2250
												} -- 2250
											else -- 2252
												messages[#messages + 1] = { -- 2252
													success = false, -- 2252
													file = file, -- 2252
													message = res.message -- 2252
												} -- 2252
											end -- 2247
											done = true -- 2253
										end -- 2245
									end -- 2244
								end -- 2243
							end) -- 2242
						end -- 2241
						emit("AppWS", "Send", json.encode({ -- 2254
							name = "TranspileTS", -- 2254
							file = file, -- 2254
							content = content -- 2254
						})) -- 2254
						wait(function() -- 2255
							return done -- 2255
						end) -- 2255
						::_continue_0:: -- 2239
					end -- 2238
					return { -- 2256
						success = true, -- 2256
						messages = messages -- 2256
					} -- 2256
				end -- 2202
			end -- 2197
		end -- 2197
	end -- 2197
	return { -- 2196
		success = false -- 2196
	} -- 2196
end) -- 2196
HttpServer:post("/download", function(req) -- 2258
	do -- 2259
		local _type_0 = type(req) -- 2259
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2259
		if _tab_0 then -- 2259
			local url -- 2259
			do -- 2259
				local _obj_0 = req.body -- 2259
				local _type_1 = type(_obj_0) -- 2259
				if "table" == _type_1 or "userdata" == _type_1 then -- 2259
					url = _obj_0.url -- 2259
				end -- 2259
			end -- 2259
			local target -- 2259
			do -- 2259
				local _obj_0 = req.body -- 2259
				local _type_1 = type(_obj_0) -- 2259
				if "table" == _type_1 or "userdata" == _type_1 then -- 2259
					target = _obj_0.target -- 2259
				end -- 2259
			end -- 2259
			if url ~= nil and target ~= nil then -- 2259
				local Entry = require("Script.Dev.Entry") -- 2260
				Entry.downloadFile(url, target) -- 2261
				return { -- 2262
					success = true -- 2262
				} -- 2262
			end -- 2259
		end -- 2259
	end -- 2259
	return { -- 2258
		success = false -- 2258
	} -- 2258
end) -- 2258
local isDesktopPlatform -- 2264
isDesktopPlatform = function() -- 2264
	local _val_0 = App.platform -- 2265
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2265
end -- 2264
local getServerStatus -- 2267
getServerStatus = function() -- 2267
	local Entry = require("Script.Dev.Entry") -- 2268
	local running = Entry.getCurrentEntryStatus() -- 2269
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2270
	return { -- 2272
		success = true, -- 2272
		platform = App.platform, -- 2273
		locale = App.locale, -- 2274
		version = App.version, -- 2275
		url = "http://localhost:8866", -- 2276
		wsConnectionCount = HttpServer.wsConnectionCount, -- 2277
		webIDEConnected = HttpServer.wsConnectionCount > 0, -- 2278
		assetPath = Content.assetPath, -- 2279
		writablePath = Content.writablePath, -- 2280
		waTemplateReady = waTemplateReady, -- 2281
		running = running -- 2282
	} -- 2271
end -- 2267
HttpServer:post("/status", function() -- 2285
	return getServerStatus() -- 2286
end) -- 2285
HttpServer:postSchedule("/doctor/fix", function(req) -- 2288
	do -- 2289
		local _type_0 = type(req) -- 2289
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2289
		if _tab_0 then -- 2289
			local openWebIDE -- 2289
			do -- 2289
				local _obj_0 = req.body -- 2289
				local _type_1 = type(_obj_0) -- 2289
				if "table" == _type_1 or "userdata" == _type_1 then -- 2289
					openWebIDE = _obj_0.openWebIDE -- 2289
				end -- 2289
			end -- 2289
			if openWebIDE ~= nil then -- 2289
				if not openWebIDE then -- 2290
					return { -- 2291
						success = false, -- 2291
						message = "nothing to fix" -- 2291
					} -- 2291
				end -- 2290
				local status = getServerStatus() -- 2292
				if status.webIDEConnected then -- 2293
					return { -- 2294
						success = true, -- 2294
						fixed = false, -- 2294
						message = "Web IDE already connected.", -- 2294
						status = status -- 2294
					} -- 2294
				end -- 2293
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2295
				if waitSeconds > 0 then -- 2296
					local deadline = os.time() + waitSeconds -- 2297
					repeat -- 2298
						sleep(0.2) -- 2299
						status = getServerStatus() -- 2300
						if status.webIDEConnected then -- 2301
							return { -- 2302
								success = true, -- 2302
								fixed = false, -- 2302
								reconnected = true, -- 2302
								message = "Web IDE reconnected.", -- 2302
								status = status -- 2302
							} -- 2302
						end -- 2301
					until os.time() >= deadline -- 2298
				end -- 2296
				if not isDesktopPlatform() then -- 2304
					return { -- 2305
						success = false, -- 2305
						message = "opening Web IDE is only supported on desktop platforms", -- 2305
						status = status -- 2305
					} -- 2305
				end -- 2304
				local url = "http://localhost:8866" -- 2306
				App:openURL(url) -- 2307
				status.openedURL = url -- 2308
				return { -- 2309
					success = true, -- 2309
					fixed = true, -- 2309
					message = "Opened Web IDE in the local browser.", -- 2309
					url = url, -- 2309
					status = status -- 2309
				} -- 2309
			end -- 2289
		end -- 2289
	end -- 2289
	return { -- 2288
		success = false, -- 2288
		message = "invalid call" -- 2288
	} -- 2288
end) -- 2288
local status = { } -- 2311
_module_0 = status -- 2312
status.buildAsync = function(path) -- 2314
	if not Content:exist(path) then -- 2315
		return { -- 2316
			success = false, -- 2316
			file = path, -- 2316
			message = "file not existed" -- 2316
		} -- 2316
	end -- 2315
	do -- 2317
		local _exp_0 = Path:getExt(path) -- 2317
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2317
			if '' == Path:getExt(Path:getName(path)) then -- 2318
				local content = Content:loadAsync(path) -- 2319
				if content then -- 2319
					local resultCodes, err = compileFileAsync(path, content) -- 2320
					if resultCodes then -- 2320
						return { -- 2321
							success = true, -- 2321
							file = path -- 2321
						} -- 2321
					else -- 2323
						return { -- 2323
							success = false, -- 2323
							file = path, -- 2323
							message = err -- 2323
						} -- 2323
					end -- 2320
				end -- 2319
			end -- 2318
		elseif "lua" == _exp_0 then -- 2324
			local content = Content:loadAsync(path) -- 2325
			if content then -- 2325
				do -- 2326
					local isTIC80 = CheckTIC80Code(content) -- 2326
					if isTIC80 then -- 2326
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2327
					end -- 2326
				end -- 2326
				local success, info -- 2328
				do -- 2328
					local _obj_0 = luaCheck(path, content) -- 2328
					success, info = _obj_0.success, _obj_0.info -- 2328
				end -- 2328
				if success then -- 2329
					return { -- 2330
						success = true, -- 2330
						file = path -- 2330
					} -- 2330
				elseif info and #info > 0 then -- 2331
					local messages = { } -- 2332
					for _index_0 = 1, #info do -- 2333
						local _des_0 = info[_index_0] -- 2333
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2333
						local lineText = "" -- 2334
						if line then -- 2335
							local currentLine = 1 -- 2336
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2337
								if currentLine == line then -- 2338
									lineText = text -- 2339
									break -- 2340
								end -- 2338
								currentLine = currentLine + 1 -- 2341
							end -- 2337
						end -- 2335
						if line then -- 2342
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2343
						else -- 2345
							messages[#messages + 1] = message -- 2345
						end -- 2342
					end -- 2333
					return { -- 2346
						success = false, -- 2346
						file = path, -- 2346
						message = table.concat(messages, "\n") -- 2346
					} -- 2346
				else -- 2348
					return { -- 2348
						success = false, -- 2348
						file = path, -- 2348
						message = "lua check failed" -- 2348
					} -- 2348
				end -- 2329
			end -- 2325
		elseif "yarn" == _exp_0 then -- 2349
			local content = Content:loadAsync(path) -- 2350
			if content then -- 2350
				local res, _, err = yarncompile(content, true) -- 2351
				if res then -- 2351
					return { -- 2352
						success = true, -- 2352
						file = path -- 2352
					} -- 2352
				else -- 2354
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2354
					local lineText = "" -- 2355
					if line then -- 2356
						local currentLine = 1 -- 2357
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2358
							if currentLine == line then -- 2359
								lineText = text -- 2360
								break -- 2361
							end -- 2359
							currentLine = currentLine + 1 -- 2362
						end -- 2358
					end -- 2356
					if node ~= "" then -- 2363
						node = "node: " .. tostring(node) .. ", " -- 2364
					else -- 2365
						node = "" -- 2365
					end -- 2363
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2366
					return { -- 2367
						success = false, -- 2367
						file = path, -- 2367
						message = message -- 2367
					} -- 2367
				end -- 2351
			end -- 2350
		end -- 2317
	end -- 2317
	return { -- 2368
		success = false, -- 2368
		file = path, -- 2368
		message = "invalid file to build" -- 2368
	} -- 2368
end -- 2314
thread(function() -- 2370
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 2371
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 2372
	if Content:exist(doraWeb) then -- 2373
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) -- 2374
		local needReload -- 2375
		if Content:exist(doraReady) then -- 2375
			needReload = readyContent ~= Content:load(doraReady) -- 2376
		else -- 2377
			needReload = true -- 2377
		end -- 2375
		if needReload then -- 2378
			Content:remove(Path(Content.appPath, ".www")) -- 2379
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 2380
			Content:save(doraReady, readyContent) -- 2384
			print("Dora Dora is ready!") -- 2385
		end -- 2378
	end -- 2373
	if HttpServer:start(8866) then -- 2386
		local localIP = HttpServer.localIP -- 2387
		if localIP == "" then -- 2388
			localIP = "localhost" -- 2388
		end -- 2388
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 2389
		return HttpServer:startWS(8868) -- 2390
	else -- 2392
		status.url = nil -- 2392
		return print("8866 Port not available!") -- 2393
	end -- 2386
end) -- 2370
return _module_0 -- 1
