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
	local relative = Path:getRelative(file, root) -- 108
	if relative == "" or relative == ".." or relative:sub(1, 3) == "../" or relative:sub(1, 3) == "..\\" then -- 109
		return nil -- 109
	end -- 109
	if relative == "." then -- 110
		return "" -- 110
	end -- 110
	return relative -- 111
end -- 106
local getProjectSourceRoot -- 113
getProjectSourceRoot = function(projectRoot) -- 113
	if not (projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot)) then -- 114
		return nil -- 114
	end -- 114
	return projectRoot -- 115
end -- 113
local isProjectRootDir -- 117
isProjectRootDir = function(dir) -- 117
	if not (dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir)) then -- 118
		return false -- 118
	end -- 118
	local _list_0 = Content:getFiles(dir) -- 119
	for _index_0 = 1, #_list_0 do -- 119
		local f = _list_0[_index_0] -- 119
		if Path:getName(f):lower() == "init" then -- 120
			return true -- 121
		end -- 120
	end -- 119
	return false -- 122
end -- 117
local getProjectRootFromPath -- 124
getProjectRootFromPath = function(target, isDir) -- 124
	if isDir == nil then -- 124
		isDir = false -- 124
	end -- 124
	if not (target and target ~= "" and Content:isAbsolutePath(target)) then -- 125
		return nil, "invalid path" -- 125
	end -- 125
	if isDir then -- 126
		if target == Content.writablePath or isProjectRootDir(target) then -- 127
			return target -- 127
		end -- 127
		return getProjectDirFromFile(Path(target, "__dora_project_root_search__.lua"), "current directory does not belong to any project") -- 128
	end -- 126
	return getProjectDirFromFile(target, "current file does not belong to any project") -- 129
end -- 124
local invalidArguments = { -- 131
	success = false, -- 131
	message = "invalid arguments" -- 131
} -- 131
HttpServer:post("/agent/project-root", function(req) -- 133
	do -- 134
		local _type_0 = type(req) -- 134
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 134
		if _tab_0 then -- 134
			local path -- 134
			do -- 134
				local _obj_0 = req.body -- 134
				local _type_1 = type(_obj_0) -- 134
				if "table" == _type_1 or "userdata" == _type_1 then -- 134
					path = _obj_0.path -- 134
				end -- 134
			end -- 134
			local isDir -- 134
			do -- 134
				local _obj_0 = req.body -- 134
				local _type_1 = type(_obj_0) -- 134
				if "table" == _type_1 or "userdata" == _type_1 then -- 134
					isDir = _obj_0.isDir -- 134
				end -- 134
			end -- 134
			if path ~= nil and isDir ~= nil then -- 134
				local projectRoot, err = getProjectRootFromPath(path, isDir) -- 135
				if projectRoot then -- 135
					return { -- 136
						success = true, -- 136
						found = true, -- 136
						projectRoot = projectRoot, -- 136
						title = Path:getFilename(projectRoot) -- 136
					} -- 136
				else -- 138
					return { -- 138
						success = true, -- 138
						found = false, -- 138
						message = err -- 138
					} -- 138
				end -- 135
			end -- 134
		end -- 134
	end -- 134
	return invalidArguments -- 133
end) -- 133
local AgentTools = require("Agent.Tools") -- 140
local AgentSession = require("Agent.AgentSession") -- 141
local GitJobs = { } -- 143
local gitTerminalState -- 145
gitTerminalState = function(status) -- 145
	if not (status and status.state) then -- 146
		return false -- 146
	end -- 146
	local _val_0 = status.state -- 147
	return "done" == _val_0 or "error" == _val_0 or "canceled" == _val_0 -- 147
end -- 145
local gitInvalidRepoPath -- 149
gitInvalidRepoPath = function(repoPath) -- 149
	return not repoPath or repoPath == "" or not Content:isAbsolutePath(repoPath) -- 150
end -- 149
local gitShellSplit -- 152
gitShellSplit = function(command) -- 152
	local args = { } -- 153
	local current = { } -- 154
	local quote = nil -- 155
	local escape = false -- 156
	for i = 1, #command do -- 157
		local ch = command:sub(i, i) -- 158
		if escape then -- 159
			current[#current + 1] = ch -- 160
			escape = false -- 161
		elseif ch == "\\" then -- 162
			escape = true -- 163
		elseif quote then -- 164
			if ch == quote then -- 165
				quote = nil -- 166
			else -- 168
				current[#current + 1] = ch -- 168
			end -- 165
		elseif ch == "'" or ch == '"' then -- 169
			quote = ch -- 170
		elseif ch:match("%s") then -- 171
			if #current > 0 then -- 172
				args[#args + 1] = table.concat(current) -- 173
				current = { } -- 174
			end -- 172
		else -- 176
			current[#current + 1] = ch -- 176
		end -- 159
	end -- 157
	if #current > 0 then -- 177
		args[#args + 1] = table.concat(current) -- 178
	end -- 177
	if args[1] == "git" then -- 179
		table.remove(args, 1) -- 180
	end -- 179
	return args -- 181
end -- 152
local gitQuote -- 183
gitQuote = function(value) -- 183
	local text = tostring(value) -- 184
	if text:match("^[%w%._%-%/]+$") then -- 185
		return text -- 186
	end -- 185
	return "\"" .. text:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"" -- 187
end -- 183
local gitDirNonEmpty -- 189
gitDirNonEmpty = function(targetPath) -- 189
	if not Content:exist(targetPath) then -- 190
		return false -- 190
	end -- 190
	if not Content:isdir(targetPath) then -- 191
		return false -- 191
	end -- 191
	return #Content:getFiles(targetPath) > 0 or #Content:getDirs(targetPath) > 0 -- 192
end -- 189
local gitSafeChildPath -- 194
gitSafeChildPath = function(parentPath, childPath) -- 194
	if not (parentPath and childPath and childPath ~= "") then -- 195
		return nil -- 195
	end -- 195
	if childPath:sub(1, 1) == "/" or childPath:match("^%a:[/\\]") then -- 196
		return nil -- 196
	end -- 196
	if childPath == "." or childPath:match("^%.%.[/\\]?" or childPath:match("[/\\]%.%.[/\\]")) then -- 197
		return nil -- 197
	end -- 197
	local targetPath = Path(parentPath, childPath) -- 198
	local relative = Path:getRelative(targetPath, parentPath) -- 199
	if relative == ".." or relative:sub(1, 3) == "../" or relative:sub(1, 3) == "..\\" then -- 200
		return nil -- 200
	end -- 200
	return targetPath -- 201
end -- 194
local gitCloneDirFromURL -- 203
gitCloneDirFromURL = function(url) -- 203
	if not (url and url ~= "") then -- 204
		return nil -- 204
	end -- 204
	local text = tostring(url):match("^%s*(.-)%s*$") -- 205
	if text == "" then -- 206
		return nil -- 206
	end -- 206
	text = text:gsub("[/\\]+$", "") -- 207
	local name = text:match("([^/:]+)$") -- 208
	if not (name and name ~= "") then -- 209
		return nil -- 209
	end -- 209
	name = name:gsub("%.git$", "") -- 210
	if name == "" or name == "." or name == ".." then -- 211
		return nil -- 211
	end -- 211
	return name -- 212
end -- 203
local gitCloneTargetPath -- 214
gitCloneTargetPath = function(repoPath, command) -- 214
	local args = gitShellSplit(command) -- 215
	if not (args[1] == "clone") then -- 216
		return nil -- 216
	end -- 216
	local url = args[2] -- 217
	local index = 3 -- 218
	while index <= #args do -- 219
		local arg = args[index] -- 220
		if ("-b" == arg or "--branch" == arg or "--depth" == arg) then -- 221
			index = index + 2 -- 222
		elseif arg:sub(1, 1) == "-" then -- 223
			index = index + 1 -- 224
		else -- 226
			return gitSafeChildPath(repoPath, arg) -- 226
		end -- 221
	end -- 219
	do -- 227
		local dirName = gitCloneDirFromURL(url) -- 227
		if dirName then -- 227
			return gitSafeChildPath(repoPath, dirName) -- 228
		end -- 227
	end -- 227
	return nil -- 229
end -- 214
local gitPathInsideRepo -- 231
gitPathInsideRepo = function(repoPath, relPath) -- 231
	if not (repoPath and relPath and relPath ~= "") then -- 232
		return false -- 232
	end -- 232
	if relPath:sub(1, 1) == "/" or relPath:match("^%a:[/\\]") then -- 233
		return false -- 233
	end -- 233
	if relPath == "." or relPath:match("^%.%.[/\\]?" or relPath:match("[/\\]%.%.[/\\]")) then -- 234
		return false -- 234
	end -- 234
	local targetPath = Path(repoPath, relPath) -- 235
	local relative = Path:getRelative(targetPath, repoPath) -- 236
	return relative ~= ".." and relative:sub(1, 3) ~= "../" and relative:sub(1, 3) ~= "..\\" -- 237
end -- 231
local gitHostFromURL -- 239
gitHostFromURL = function(url) -- 239
	if not (url and url ~= "") then -- 240
		return nil -- 240
	end -- 240
	local text = tostring(url):match("^%s*(.-)%s*$") -- 241
	if text == "" then -- 242
		return nil -- 242
	end -- 242
	local host = text:match("^[%w_%-]+://([^/:]+)") -- 243
	if not host then -- 244
		host = text:match("@([^:/]+)[:/]") -- 244
	end -- 244
	if not host then -- 245
		host = text:match("^([^:/]+):[^/]") -- 245
	end -- 245
	if not (host and host ~= "") then -- 246
		return nil -- 246
	end -- 246
	return string.lower(host) -- 247
end -- 239
local ensureGitTables -- 249
ensureGitTables = function() -- 249
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
	]]) -- 250
	DB:exec("CREATE INDEX IF NOT EXISTS idx_git_credential_host ON GitCredential(host);") -- 263
	return DB:exec([[		CREATE TABLE IF NOT EXISTS GitProfile(
			id INTEGER PRIMARY KEY CHECK(id = 1),
			name TEXT NOT NULL DEFAULT '',
			email TEXT NOT NULL DEFAULT '',
			updated_at INTEGER
		);
	]]) -- 264
end -- 249
local gitCredentialToPublic -- 273
gitCredentialToPublic = function(row) -- 273
	local id, host, label, typeName, username, createdAt, updatedAt, lastUsedAt = row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8] -- 274
	return { -- 275
		id = id, -- 275
		host = host, -- 275
		label = label, -- 275
		type = typeName, -- 275
		username = username, -- 275
		createdAt = createdAt, -- 275
		updatedAt = updatedAt, -- 275
		lastUsedAt = lastUsedAt -- 275
	} -- 275
end -- 273
local gitLoadCredential -- 277
gitLoadCredential = function(id) -- 277
	ensureGitTables() -- 278
	local credentialId = tonumber(id) or 0 -- 279
	local rows = DB:query("select id, host, label, type, username, secret from GitCredential where id = ? limit 1", { -- 280
		credentialId -- 280
	}) -- 280
	if not (rows and rows[1]) then -- 281
		return nil -- 281
	end -- 281
	local row = rows[1] -- 282
	return { -- 283
		id = row[1], -- 283
		host = row[2], -- 283
		label = row[3], -- 283
		type = row[4], -- 283
		username = row[5], -- 283
		secret = row[6] -- 283
	} -- 283
end -- 277
local gitAuthOptionsJSON -- 285
gitAuthOptionsJSON = function(credential) -- 285
	if not credential then -- 286
		return nil -- 286
	end -- 286
	local auth -- 287
	if credential.type == "token" then -- 287
		auth = { -- 289
			type = "token", -- 289
			token = credential.secret, -- 290
			username = credential.username ~= "" and credential.username or "token" -- 291
		} -- 288
	else -- 294
		auth = { -- 295
			type = "basic", -- 295
			username = credential.username, -- 296
			password = credential.secret -- 297
		} -- 294
	end -- 287
	return json.encode({ -- 299
		auth = auth -- 299
	}) -- 299
end -- 285
local gitLoadProfile -- 301
gitLoadProfile = function() -- 301
	ensureGitTables() -- 302
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 303
	if not (rows and rows[1]) then -- 304
		return nil -- 304
	end -- 304
	local name = tostring(rows[1][1] or "") -- 305
	local email = tostring(rows[1][2] or "") -- 306
	if name == "" and email == "" then -- 307
		return nil -- 307
	end -- 307
	return { -- 308
		name = name, -- 308
		email = email -- 308
	} -- 308
end -- 301
local _anon_func_2 = function(args, gitQuote) -- 327
	local _accum_0 = { } -- 327
	local _len_0 = 1 -- 327
	for _index_0 = 1, #args do -- 327
		local arg = args[_index_0] -- 327
		_accum_0[_len_0] = gitQuote(arg) -- 327
		_len_0 = _len_0 + 1 -- 327
	end -- 327
	return _accum_0 -- 327
end -- 327
local gitApplyProfileToCommit -- 310
gitApplyProfileToCommit = function(command) -- 310
	local args = gitShellSplit(command) -- 311
	if not (args[1] == "commit") then -- 312
		return command -- 312
	end -- 312
	local hasName = false -- 313
	local hasEmail = false -- 314
	for _index_0 = 1, #args do -- 315
		local arg = args[_index_0] -- 315
		if arg == "--author-name" then -- 316
			hasName = true -- 316
		end -- 316
		if arg == "--author-email" then -- 317
			hasEmail = true -- 317
		end -- 317
	end -- 315
	if hasName and hasEmail then -- 318
		return command -- 318
	end -- 318
	local profile = gitLoadProfile() -- 319
	if not profile then -- 320
		return command -- 320
	end -- 320
	if not hasName and profile.name ~= "" then -- 321
		args[#args + 1] = "--author-name" -- 322
		args[#args + 1] = profile.name -- 323
	end -- 321
	if not hasEmail and profile.email ~= "" then -- 324
		args[#args + 1] = "--author-email" -- 325
		args[#args + 1] = profile.email -- 326
	end -- 324
	return table.concat(_anon_func_2(args, gitQuote), " ") -- 327
end -- 310
local gitStartJob -- 329
gitStartJob = function(repoPath, command, optionsJSON) -- 329
	if optionsJSON == nil then -- 329
		optionsJSON = nil -- 329
	end -- 329
	if gitInvalidRepoPath(repoPath) then -- 330
		return nil, "invalid repoPath" -- 330
	end -- 330
	if not (command and command ~= "") then -- 331
		return nil, "invalid command" -- 331
	end -- 331
	if not optionsJSON then -- 332
		optionsJSON = "" -- 332
	end -- 332
	command = gitApplyProfileToCommit(command) -- 333
	do -- 334
		local targetPath = gitCloneTargetPath(repoPath, command) -- 334
		if targetPath then -- 334
			if gitDirNonEmpty(targetPath) then -- 335
				return nil, "clone target directory is not empty" -- 336
			end -- 335
		elseif (gitShellSplit(command))[1] == "clone" then -- 337
			return nil, "invalid clone target" -- 338
		end -- 334
	end -- 334
	local statusRef = nil -- 339
	local startGit -- 340
	startGit = function() -- 340
		return Git:run(repoPath, command, (function(status) -- 341
			statusRef = status -- 342
			GitJobs[status.id] = { -- 344
				command = command, -- 344
				status = status, -- 345
				updatedAt = os.time() -- 346
			} -- 343
		end), optionsJSON) -- 341
	end -- 340
	local success, jobId = pcall(startGit) -- 348
	if not success then -- 349
		return nil, tostring(jobId) -- 349
	end -- 349
	if not jobId then -- 350
		return nil, "Git.run did not return a job id" -- 350
	end -- 350
	GitJobs[jobId] = { -- 352
		command = command, -- 352
		status = statusRef or { -- 354
			id = jobId, -- 354
			state = "queued", -- 355
			kind = gitShellSplit(command)[1] or "status", -- 356
			repoPath = repoPath, -- 357
			progress = 0, -- 358
			message = "queued" -- 359
		}, -- 353
		updatedAt = os.time() -- 361
	} -- 351
	return jobId -- 362
end -- 329
local gitRunSync -- 364
gitRunSync = function(repoPath, command, optionsJSON, timeout) -- 364
	if optionsJSON == nil then -- 364
		optionsJSON = nil -- 364
	end -- 364
	if timeout == nil then -- 364
		timeout = 20 -- 364
	end -- 364
	local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 365
	if not jobId then -- 366
		return { -- 366
			success = false, -- 366
			message = err -- 366
		} -- 366
	end -- 366
	local startedAt = os.time() -- 367
	wait(function() -- 368
		local job = GitJobs[jobId] -- 369
		local status = job and job.status -- 370
		return gitTerminalState(status) or os.time() - startedAt >= timeout -- 371
	end) -- 368
	local status = GitJobs[jobId] and GitJobs[jobId].status -- 372
	if not gitTerminalState(status) then -- 373
		Git:cancel(jobId) -- 374
		return { -- 375
			success = false, -- 375
			message = "git command timed out", -- 375
			jobId = jobId, -- 375
			status = status -- 375
		} -- 375
	end -- 373
	return { -- 376
		success = status.state == "done", -- 376
		jobId = jobId, -- 376
		status = status, -- 376
		message = status.error or status.message -- 376
	} -- 376
end -- 364
local gitCredentialsForHost -- 378
gitCredentialsForHost = function(host) -- 378
	if not (host and host ~= "") then -- 379
		return { } -- 379
	end -- 379
	ensureGitTables() -- 380
	local rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by last_used_at desc, label asc, id asc", { -- 381
		host -- 381
	}) -- 381
	if rows then -- 382
		local _accum_0 = { } -- 383
		local _len_0 = 1 -- 383
		for _index_0 = 1, #rows do -- 383
			local row = rows[_index_0] -- 383
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 383
			_len_0 = _len_0 + 1 -- 383
		end -- 383
		return _accum_0 -- 383
	else -- 384
		return { } -- 384
	end -- 382
end -- 378
local gitFirstRemoteURL -- 386
gitFirstRemoteURL = function(repoPath, remoteName) -- 386
	if remoteName == nil then -- 386
		remoteName = nil -- 386
	end -- 386
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 10) -- 387
	local data = remoteRes.status and remoteRes.status.data -- 388
	if not (data and data.remotes) then -- 389
		return nil -- 389
	end -- 389
	local _list_0 = data.remotes -- 390
	for _index_0 = 1, #_list_0 do -- 390
		local remote = _list_0[_index_0] -- 390
		if (not remoteName or remote.name == remoteName) and remote.urls and remote.urls[1] then -- 391
			return remote.urls[1] -- 392
		end -- 391
	end -- 390
	return nil -- 393
end -- 386
local gitConfigRemoteURL -- 395
gitConfigRemoteURL = function(repoPath, remoteName) -- 395
	if remoteName == nil then -- 395
		remoteName = nil -- 395
	end -- 395
	if gitInvalidRepoPath(repoPath) then -- 396
		return nil -- 396
	end -- 396
	local configPath = Path(repoPath, ".git/config") -- 397
	if not Content:exist(configPath) then -- 398
		return nil -- 398
	end -- 398
	local content = Content:load(configPath) -- 399
	if not (content and content ~= "") then -- 400
		return nil -- 400
	end -- 400
	local currentRemote = nil -- 401
	for line in content:gmatch("[^\r\n]+") do -- 402
		local sectionRemote = line:match('^%s*%[remote%s+"([^"]+)"%]%s*$') -- 403
		if sectionRemote then -- 404
			currentRemote = sectionRemote -- 405
		elseif currentRemote and (not remoteName or currentRemote == remoteName) then -- 406
			local url = line:match("^%s*url%s*=%s*(.-)%s*$") -- 407
			if url and url ~= "" then -- 408
				return url -- 408
			end -- 408
		end -- 404
	end -- 402
	return nil -- 409
end -- 395
local gitCommandRemoteArg -- 411
gitCommandRemoteArg = function(args, startIndex) -- 411
	if startIndex == nil then -- 411
		startIndex = 2 -- 411
	end -- 411
	local index = startIndex -- 412
	while index <= #args do -- 413
		local arg = args[index] -- 414
		if ("-u" == arg or "--set-upstream" == arg or "-f" == arg or "--force" == arg or "--all" == arg or "--prune" == arg) then -- 415
			index = index + 1 -- 416
		elseif ("--depth" == arg or "-b" == arg or "--branch" == arg) then -- 417
			index = index + 2 -- 418
		elseif arg and arg:sub(1, 1) == "-" then -- 419
			index = index + 1 -- 420
		else -- 422
			return arg -- 422
		end -- 415
	end -- 413
	return nil -- 423
end -- 411
local gitCommandHost -- 425
gitCommandHost = function(repoPath, command) -- 425
	local args = gitShellSplit(command) -- 426
	if not args[1] then -- 427
		return nil -- 427
	end -- 427
	do -- 428
		local _exp_0 = args[1] -- 428
		if "clone" == _exp_0 or "ls-remote" == _exp_0 then -- 429
			return gitHostFromURL(args[2]) -- 430
		elseif "fetch" == _exp_0 or "pull" == _exp_0 or "push" == _exp_0 then -- 431
			local remoteArg = gitCommandRemoteArg(args, 2) -- 432
			if not remoteArg then -- 433
				return nil -- 433
			end -- 433
			local url = gitHostFromURL(remoteArg) -- 434
			if url then -- 435
				return url -- 435
			end -- 435
			return gitHostFromURL(gitConfigRemoteURL(repoPath, remoteArg)) -- 436
		end -- 428
	end -- 428
	return nil -- 437
end -- 425
local gitAuthSelectionForCommand -- 439
gitAuthSelectionForCommand = function(repoPath, command) -- 439
	local host = gitCommandHost(repoPath, command) -- 440
	if not host then -- 441
		return nil -- 441
	end -- 441
	local items = gitCredentialsForHost(host) -- 442
	if #items == 0 then -- 443
		return nil -- 443
	end -- 443
	return { -- 444
		host = host, -- 444
		items = items -- 444
	} -- 444
end -- 439
local gitDefaultRemote -- 446
gitDefaultRemote = function(remoteStatus) -- 446
	local data = remoteStatus and remoteStatus.data -- 447
	if not (data and data.remotes and data.remotes[1]) then -- 448
		return nil -- 448
	end -- 448
	return data.remotes[1] -- 449
end -- 446
local gitCurrentBranch -- 451
gitCurrentBranch = function(branchStatus) -- 451
	local data = branchStatus and branchStatus.data -- 452
	if data and data.current and data.current ~= "" then -- 453
		return data.current -- 454
	end -- 453
	if data and data.branches then -- 455
		local _list_0 = data.branches -- 456
		for _index_0 = 1, #_list_0 do -- 456
			local branch = _list_0[_index_0] -- 456
			if branch.current then -- 457
				return branch.name -- 457
			end -- 457
		end -- 456
	end -- 455
	return nil -- 458
end -- 451
local gitHeadBranch -- 460
gitHeadBranch = function(repoPath) -- 460
	if gitInvalidRepoPath(repoPath) then -- 461
		return nil -- 461
	end -- 461
	local headPath = Path(repoPath, ".git", "HEAD") -- 462
	if not Content:exist(headPath) then -- 463
		return nil -- 463
	end -- 463
	local head = Content:load(headPath) -- 464
	if not head then -- 465
		return nil -- 465
	end -- 465
	local branch = head:match("^ref:%s*refs/heads/(.-)%s*$") -- 466
	if branch and branch ~= "" then -- 467
		return branch -- 467
	end -- 467
	return nil -- 468
end -- 460
local gitBranchesWithHead -- 470
gitBranchesWithHead = function(branchStatus, currentBranch) -- 470
	local branches = branchStatus and branchStatus.data and branchStatus.data.branches or { } -- 471
	if not (currentBranch and currentBranch ~= "") then -- 472
		return branches -- 472
	end -- 472
	for _index_0 = 1, #branches do -- 473
		local branch = branches[_index_0] -- 473
		if branch.name == currentBranch then -- 474
			return branches -- 474
		end -- 474
	end -- 473
	local withHead -- 475
	do -- 475
		local _accum_0 = { } -- 475
		local _len_0 = 1 -- 475
		for _index_0 = 1, #branches do -- 475
			local branch = branches[_index_0] -- 475
			_accum_0[_len_0] = branch -- 475
			_len_0 = _len_0 + 1 -- 475
		end -- 475
		withHead = _accum_0 -- 475
	end -- 475
	withHead[#withHead + 1] = { -- 476
		name = currentBranch, -- 476
		current = true, -- 476
		unborn = true -- 476
	} -- 476
	return withHead -- 477
end -- 470
local gitStatusMeansNotRepo -- 479
gitStatusMeansNotRepo = function(statusRes) -- 479
	local message = statusRes and (statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message)) or "" -- 480
	message = tostring(message):lower() -- 481
	return message:find("repository does not exist", 1, true) or message:find("not a git repository", 1, true) -- 482
end -- 479
local gitSummary -- 484
gitSummary = function(repoPath) -- 484
	local statusRes = gitRunSync(repoPath, "status", nil, 120) -- 485
	if not statusRes.success then -- 486
		if gitStatusMeansNotRepo(statusRes) then -- 487
			return { -- 488
				success = true, -- 488
				isRepo = false, -- 488
				message = statusRes.message, -- 488
				status = statusRes.status -- 488
			} -- 488
		end -- 487
		return { -- 489
			success = false, -- 489
			message = statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message) or "failed to check Git repository", -- 489
			status = statusRes.status -- 489
		} -- 489
	end -- 486
	local branchRes = gitRunSync(repoPath, "branch", nil, 120) -- 490
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 120) -- 491
	local status = statusRes.status -- 492
	local branchStatus = branchRes.status -- 493
	local remoteStatus = remoteRes.status -- 494
	local currentBranch = gitCurrentBranch(branchStatus) or gitHeadBranch(repoPath) -- 495
	local branches = gitBranchesWithHead(branchStatus, currentBranch) -- 496
	local logRes = gitRunSync(repoPath, "log --metadata-only -n 100", nil, 120) -- 497
	local logStatus -- 498
	if logRes.success then -- 498
		logStatus = logRes.status -- 499
	else -- 501
		logStatus = { -- 502
			state = "done", -- 502
			kind = "log", -- 503
			repoPath = repoPath, -- 504
			progress = 1, -- 505
			message = "git log completed", -- 506
			data = { -- 507
				commits = { } -- 507
			} -- 507
		} -- 501
	end -- 498
	local hasCommit = logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] ~= nil -- 509
	local tagStatus -- 510
	if hasCommit then -- 510
		tagStatus = (gitRunSync(repoPath, "tag", nil, 120)).status -- 511
	else -- 513
		tagStatus = { -- 514
			state = "done", -- 514
			kind = "tag", -- 515
			repoPath = repoPath, -- 516
			progress = 1, -- 517
			message = "git tag completed", -- 518
			data = { -- 519
				tags = { } -- 519
			} -- 519
		} -- 513
	end -- 510
	local defaultRemote = gitDefaultRemote(remoteStatus) -- 521
	local lastCommit = nil -- 522
	if logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] then -- 523
		lastCommit = logStatus.data.commits[1] -- 524
	end -- 523
	return { -- 526
		success = true, -- 526
		isRepo = true, -- 527
		clean = status.data and status.data.clean or false, -- 528
		currentBranch = currentBranch, -- 529
		defaultRemote = defaultRemote, -- 530
		remotes = remoteStatus and remoteStatus.data and remoteStatus.data.remotes or { }, -- 531
		branches = branches, -- 532
		lastCommit = lastCommit, -- 533
		status = status, -- 534
		branchStatus = branchStatus, -- 535
		remoteStatus = remoteStatus, -- 536
		historyStatus = logStatus, -- 537
		tagStatus = tagStatus -- 538
	} -- 525
end -- 484
HttpServer:post("/git/run", function(req) -- 540
	do -- 541
		local _type_0 = type(req) -- 541
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 541
		if _tab_0 then -- 541
			local body = req.body -- 541
			if body ~= nil then -- 541
				local repoPath, command, authId, optionsJSON = body.repoPath, body.command, body.authId, body.optionsJSON -- 542
				if authId and not optionsJSON then -- 543
					local credential = gitLoadCredential(authId) -- 544
					if credential then -- 544
						optionsJSON = gitAuthOptionsJSON(credential) -- 545
						DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 546
							os.time(), -- 546
							credential.id -- 546
						}) -- 546
					end -- 544
				elseif not optionsJSON then -- 547
					local authOk, authSelection = pcall(gitAuthSelectionForCommand, repoPath, command) -- 548
					if not authOk then -- 549
						authSelection = nil -- 549
					end -- 549
					if authSelection then -- 550
						if #authSelection.items == 1 then -- 551
							local credential = gitLoadCredential(authSelection.items[1].id) -- 552
							optionsJSON = gitAuthOptionsJSON(credential) -- 553
							DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 554
								os.time(), -- 554
								credential.id -- 554
							}) -- 554
						else -- 556
							return { -- 556
								success = false, -- 556
								message = "select a Git credential", -- 556
								needsCredentialSelection = true, -- 556
								host = authSelection.host, -- 556
								credentials = authSelection.items -- 556
							} -- 556
						end -- 551
					end -- 550
				end -- 543
				local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 557
				if not jobId then -- 558
					return { -- 558
						success = false, -- 558
						message = err -- 558
					} -- 558
				end -- 558
				return { -- 559
					success = true, -- 559
					jobId = jobId -- 559
				} -- 559
			end -- 541
		end -- 541
	end -- 541
	return invalidArguments -- 540
end) -- 540
HttpServer:post("/git/status", function(req) -- 561
	do -- 562
		local _type_0 = type(req) -- 562
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 562
		if _tab_0 then -- 562
			local jobId -- 562
			do -- 562
				local _obj_0 = req.body -- 562
				local _type_1 = type(_obj_0) -- 562
				if "table" == _type_1 or "userdata" == _type_1 then -- 562
					jobId = _obj_0.jobId -- 562
				end -- 562
			end -- 562
			if jobId ~= nil then -- 562
				local job = GitJobs[tonumber(jobId) or 0] -- 563
				if not job then -- 564
					return { -- 564
						success = false, -- 564
						message = "git job not found" -- 564
					} -- 564
				end -- 564
				return { -- 565
					success = true, -- 565
					status = job.status, -- 565
					command = job.command -- 565
				} -- 565
			end -- 562
		end -- 562
	end -- 562
	return invalidArguments -- 561
end) -- 561
HttpServer:post("/git/cancel", function(req) -- 567
	do -- 568
		local _type_0 = type(req) -- 568
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 568
		if _tab_0 then -- 568
			local jobId -- 568
			do -- 568
				local _obj_0 = req.body -- 568
				local _type_1 = type(_obj_0) -- 568
				if "table" == _type_1 or "userdata" == _type_1 then -- 568
					jobId = _obj_0.jobId -- 568
				end -- 568
			end -- 568
			if jobId ~= nil then -- 568
				local id = tonumber(jobId) -- 569
				if not id then -- 570
					return { -- 570
						success = false, -- 570
						message = "invalid jobId" -- 570
					} -- 570
				end -- 570
				return { -- 571
					success = Git:cancel(id) -- 571
				} -- 571
			end -- 568
		end -- 568
	end -- 568
	return invalidArguments -- 567
end) -- 567
HttpServer:postSchedule("/git/summary", function(req) -- 573
	do -- 574
		local _type_0 = type(req) -- 574
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 574
		if _tab_0 then -- 574
			local repoPath -- 574
			do -- 574
				local _obj_0 = req.body -- 574
				local _type_1 = type(_obj_0) -- 574
				if "table" == _type_1 or "userdata" == _type_1 then -- 574
					repoPath = _obj_0.repoPath -- 574
				end -- 574
			end -- 574
			if repoPath ~= nil then -- 574
				if gitInvalidRepoPath(repoPath) then -- 575
					return { -- 575
						success = false, -- 575
						message = "invalid repoPath" -- 575
					} -- 575
				end -- 575
				return gitSummary(repoPath) -- 576
			end -- 574
		end -- 574
	end -- 574
	return invalidArguments -- 573
end) -- 573
HttpServer:postSchedule("/git/status-files", function(req) -- 578
	do -- 579
		local _type_0 = type(req) -- 579
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 579
		if _tab_0 then -- 579
			local repoPath -- 579
			do -- 579
				local _obj_0 = req.body -- 579
				local _type_1 = type(_obj_0) -- 579
				if "table" == _type_1 or "userdata" == _type_1 then -- 579
					repoPath = _obj_0.repoPath -- 579
				end -- 579
			end -- 579
			if repoPath ~= nil then -- 579
				return gitRunSync(repoPath, "status", nil, 120) -- 580
			end -- 579
		end -- 579
	end -- 579
	return invalidArguments -- 578
end) -- 578
HttpServer:postSchedule("/git/discard-untracked", function(req) -- 582
	do -- 583
		local _type_0 = type(req) -- 583
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 583
		if _tab_0 then -- 583
			local body = req.body -- 583
			if body ~= nil then -- 583
				local repoPath, paths = body.repoPath, body.paths -- 584
				if gitInvalidRepoPath(repoPath) then -- 585
					return { -- 585
						success = false, -- 585
						message = "invalid repoPath" -- 585
					} -- 585
				end -- 585
				if not (type(paths) == "table") then -- 586
					return { -- 586
						success = false, -- 586
						message = "invalid paths" -- 586
					} -- 586
				end -- 586
				local statusRes = gitRunSync(repoPath, "status", nil, 10) -- 587
				if not statusRes.success then -- 588
					return statusRes -- 588
				end -- 588
				local untracked = { } -- 589
				local _list_0 = (statusRes.status.data and statusRes.status.data.files or { }) -- 590
				for _index_0 = 1, #_list_0 do -- 590
					local file = _list_0[_index_0] -- 590
					if file.staging == "?" or file.worktree == "?" then -- 591
						untracked[file.path] = true -- 592
					end -- 591
				end -- 590
				local removed = { } -- 593
				for _index_0 = 1, #paths do -- 594
					local relPath = paths[_index_0] -- 594
					relPath = tostring(relPath) -- 595
					if not gitPathInsideRepo(repoPath, relPath) then -- 596
						return { -- 596
							success = false, -- 596
							message = "unsafe path: " .. tostring(relPath) -- 596
						} -- 596
					end -- 596
					if not untracked[relPath] then -- 597
						return { -- 597
							success = false, -- 597
							message = "path is not untracked: " .. tostring(relPath) -- 597
						} -- 597
					end -- 597
				end -- 594
				for _index_0 = 1, #paths do -- 598
					local relPath = paths[_index_0] -- 598
					local targetPath = Path(repoPath, tostring(relPath)) -- 599
					if Content:exist(targetPath) then -- 600
						Content:remove(targetPath) -- 601
						removed[#removed + 1] = tostring(relPath) -- 602
					end -- 600
				end -- 598
				return { -- 603
					success = true, -- 603
					removed = removed -- 603
				} -- 603
			end -- 583
		end -- 583
	end -- 583
	return invalidArguments -- 582
end) -- 582
HttpServer:postSchedule("/git/file-diff", function(req) -- 605
	do -- 606
		local _type_0 = type(req) -- 606
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 606
		if _tab_0 then -- 606
			local body = req.body -- 606
			if body ~= nil then -- 606
				local repoPath, path, staged = body.repoPath, body.path, body.staged -- 607
				if gitInvalidRepoPath(repoPath) then -- 608
					return { -- 608
						success = false, -- 608
						message = "invalid repoPath" -- 608
					} -- 608
				end -- 608
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 609
					return { -- 609
						success = false, -- 609
						message = "unsafe path" -- 609
					} -- 609
				end -- 609
				local command -- 610
				if staged == true then -- 610
					command = "diff --staged -- " .. tostring(gitQuote(path)) -- 611
				else -- 613
					command = "diff -- " .. tostring(gitQuote(path)) -- 613
				end -- 610
				local res = gitRunSync(repoPath, command, nil, 10) -- 614
				if not res.success then -- 615
					return res -- 615
				end -- 615
				return { -- 616
					success = true, -- 616
					status = res.status, -- 616
					data = res.status and res.status.data -- 616
				} -- 616
			end -- 606
		end -- 606
	end -- 606
	return invalidArguments -- 605
end) -- 605
HttpServer:postSchedule("/git/commit-file-diff", function(req) -- 618
	do -- 619
		local _type_0 = type(req) -- 619
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 619
		if _tab_0 then -- 619
			local body = req.body -- 619
			if body ~= nil then -- 619
				local repoPath, commit, path = body.repoPath, body.commit, body.path -- 620
				if gitInvalidRepoPath(repoPath) then -- 621
					return { -- 621
						success = false, -- 621
						message = "invalid repoPath" -- 621
					} -- 621
				end -- 621
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 622
					return { -- 622
						success = false, -- 622
						message = "invalid commit" -- 622
					} -- 622
				end -- 622
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 623
					return { -- 623
						success = false, -- 623
						message = "unsafe path" -- 623
					} -- 623
				end -- 623
				local res = gitRunSync(repoPath, "diff " .. tostring(gitQuote(commit)) .. " -- " .. tostring(gitQuote(path)), nil, 10) -- 624
				if not res.success then -- 625
					return res -- 625
				end -- 625
				return { -- 626
					success = true, -- 626
					status = res.status, -- 626
					data = res.status and res.status.data -- 626
				} -- 626
			end -- 619
		end -- 619
	end -- 619
	return invalidArguments -- 618
end) -- 618
HttpServer:postSchedule("/git/history", function(req) -- 628
	do -- 629
		local _type_0 = type(req) -- 629
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 629
		if _tab_0 then -- 629
			local body = req.body -- 629
			if body ~= nil then -- 629
				local repoPath, limit = body.repoPath, body.limit -- 630
				limit = math.max(1, math.min(100, tonumber(limit) or 20)) -- 631
				return gitRunSync(repoPath, "log --metadata-only -n " .. tostring(limit), nil, 10) -- 632
			end -- 629
		end -- 629
	end -- 629
	return invalidArguments -- 628
end) -- 628
HttpServer:postSchedule("/git/remotes", function(req) -- 634
	do -- 635
		local _type_0 = type(req) -- 635
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 635
		if _tab_0 then -- 635
			local body = req.body -- 635
			if body ~= nil then -- 635
				local repoPath, command = body.repoPath, body.command -- 636
				command = command or "remote -v" -- 637
				return gitRunSync(repoPath, command, nil, 10) -- 638
			end -- 635
		end -- 635
	end -- 635
	return invalidArguments -- 634
end) -- 634
HttpServer:postSchedule("/git/branches", function(req) -- 640
	do -- 641
		local _type_0 = type(req) -- 641
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 641
		if _tab_0 then -- 641
			local body = req.body -- 641
			if body ~= nil then -- 641
				local repoPath, command = body.repoPath, body.command -- 642
				command = command or "branch" -- 643
				return gitRunSync(repoPath, command, nil, 10) -- 644
			end -- 641
		end -- 641
	end -- 641
	return invalidArguments -- 640
end) -- 640
HttpServer:postSchedule("/git/tags", function(req) -- 646
	do -- 647
		local _type_0 = type(req) -- 647
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 647
		if _tab_0 then -- 647
			local body = req.body -- 647
			if body ~= nil then -- 647
				local repoPath, command = body.repoPath, body.command -- 648
				command = command or "tag" -- 649
				return gitRunSync(repoPath, command, nil, 10) -- 650
			end -- 647
		end -- 647
	end -- 647
	return invalidArguments -- 646
end) -- 646
HttpServer:post("/git/profile/get", function() -- 652
	ensureGitTables() -- 653
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 654
	local profile -- 655
	if rows and rows[1] then -- 655
		profile = { -- 656
			name = rows[1][1], -- 656
			email = rows[1][2] -- 656
		} -- 656
	else -- 658
		profile = { -- 658
			name = "", -- 658
			email = "" -- 658
		} -- 658
	end -- 655
	return { -- 659
		success = true, -- 659
		profile = profile -- 659
	} -- 659
end) -- 652
HttpServer:post("/git/profile/save", function(req) -- 661
	do -- 662
		local _type_0 = type(req) -- 662
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 662
		if _tab_0 then -- 662
			local name -- 662
			do -- 662
				local _obj_0 = req.body -- 662
				local _type_1 = type(_obj_0) -- 662
				if "table" == _type_1 or "userdata" == _type_1 then -- 662
					name = _obj_0.name -- 662
				end -- 662
			end -- 662
			local email -- 662
			do -- 662
				local _obj_0 = req.body -- 662
				local _type_1 = type(_obj_0) -- 662
				if "table" == _type_1 or "userdata" == _type_1 then -- 662
					email = _obj_0.email -- 662
				end -- 662
			end -- 662
			if name ~= nil and email ~= nil then -- 662
				ensureGitTables() -- 663
				DB:exec("insert into GitProfile(id, name, email, updated_at) values(1, ?, ?, ?) on conflict(id) do update set name = excluded.name, email = excluded.email, updated_at = excluded.updated_at", { -- 665
					tostring(name or ""), -- 665
					tostring(email or ""), -- 666
					os.time() -- 667
				}) -- 664
				return { -- 669
					success = true -- 669
				} -- 669
			end -- 662
		end -- 662
	end -- 662
	return invalidArguments -- 661
end) -- 661
HttpServer:post("/git/auth/list", function(req) -- 671
	ensureGitTables() -- 672
	local host = nil -- 673
	do -- 674
		local _type_0 = type(req) -- 674
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 674
		if _tab_0 then -- 674
			local body = req.body -- 674
			if body ~= nil then -- 674
				host = body.host -- 675
			end -- 674
		end -- 674
	end -- 674
	local rows -- 676
	if host and host ~= "" then -- 676
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by host asc, label asc, id asc", { -- 677
			tostring(host):lower() -- 677
		}) -- 677
	else -- 679
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential order by host asc, label asc, id asc") -- 679
	end -- 676
	local items -- 680
	if rows then -- 680
		local _accum_0 = { } -- 680
		local _len_0 = 1 -- 680
		for _index_0 = 1, #rows do -- 680
			local row = rows[_index_0] -- 680
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 680
			_len_0 = _len_0 + 1 -- 680
		end -- 680
		items = _accum_0 -- 680
	else -- 680
		items = { } -- 680
	end -- 680
	return { -- 681
		success = true, -- 681
		items = items -- 681
	} -- 681
end) -- 671
HttpServer:postSchedule("/git/auth/match", function(req) -- 683
	do -- 684
		local _type_0 = type(req) -- 684
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 684
		if _tab_0 then -- 684
			local body = req.body -- 684
			if body ~= nil then -- 684
				local repoPath, command, url = body.repoPath, body.command, body.url -- 685
				local host -- 686
				if url and url ~= "" then -- 686
					host = gitHostFromURL(url) -- 686
				else -- 686
					host = gitCommandHost(repoPath, command) -- 686
				end -- 686
				if not host then -- 687
					return { -- 687
						success = false, -- 687
						message = "git host is required" -- 687
					} -- 687
				end -- 687
				local items = gitCredentialsForHost(host) -- 688
				return { -- 689
					success = true, -- 689
					host = host, -- 689
					items = items, -- 689
					needsSelection = #items > 1, -- 689
					authId = (#items == 1 and items[1].id or nil) -- 689
				} -- 689
			end -- 684
		end -- 684
	end -- 684
	return invalidArguments -- 683
end) -- 683
HttpServer:post("/git/auth/save", function(req) -- 691
	do -- 692
		local _type_0 = type(req) -- 692
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 692
		if _tab_0 then -- 692
			local body = req.body -- 692
			if body ~= nil then -- 692
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token -- 693
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$") -- 694
				label = tostring(label or ""):match("^%s*(.-)%s*$") -- 695
				local credentialType = tostring(body.type or "token") -- 696
				username = tostring(username or "") -- 697
				local secret -- 698
				if credentialType == "basic" then -- 698
					secret = tostring(password or "") -- 698
				else -- 698
					secret = tostring(token or password or "") -- 698
				end -- 698
				if host == "" then -- 699
					return { -- 699
						success = false, -- 699
						message = "host is required" -- 699
					} -- 699
				end -- 699
				if label == "" then -- 700
					return { -- 700
						success = false, -- 700
						message = "label is required" -- 700
					} -- 700
				end -- 700
				if secret == "" then -- 701
					return { -- 701
						success = false, -- 701
						message = "secret is required" -- 701
					} -- 701
				end -- 701
				if not (("basic" == credentialType or "token" == credentialType)) then -- 702
					return { -- 702
						success = false, -- 702
						message = "invalid type" -- 702
					} -- 702
				end -- 702
				ensureGitTables() -- 703
				local now = os.time() -- 704
				if id then -- 705
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", { -- 707
						host, -- 707
						label, -- 707
						credentialType, -- 707
						username, -- 707
						secret, -- 707
						now, -- 707
						(tonumber(id) or 0) -- 707
					}) -- 706
					return { -- 709
						success = true, -- 709
						id = tonumber(id) -- 709
					} -- 709
				else -- 711
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", { -- 712
						host, -- 712
						label, -- 712
						credentialType, -- 712
						username, -- 712
						secret, -- 712
						now, -- 712
						now -- 712
					}) -- 711
					local rows = DB:query("select last_insert_rowid()") -- 714
					return { -- 715
						success = true, -- 715
						id = rows and rows[1] and rows[1][1] -- 715
					} -- 715
				end -- 705
			end -- 692
		end -- 692
	end -- 692
	return invalidArguments -- 691
end) -- 691
HttpServer:post("/git/auth/delete", function(req) -- 717
	do -- 718
		local _type_0 = type(req) -- 718
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 718
		if _tab_0 then -- 718
			local id -- 718
			do -- 718
				local _obj_0 = req.body -- 718
				local _type_1 = type(_obj_0) -- 718
				if "table" == _type_1 or "userdata" == _type_1 then -- 718
					id = _obj_0.id -- 718
				end -- 718
			end -- 718
			if id ~= nil then -- 718
				ensureGitTables() -- 719
				local credentialId = tonumber(id) or 0 -- 720
				DB:exec("delete from GitCredential where id = ?", { -- 721
					credentialId -- 721
				}) -- 721
				return { -- 722
					success = true -- 722
				} -- 722
			end -- 718
		end -- 718
	end -- 718
	return invalidArguments -- 717
end) -- 717
HttpServer:postSchedule("/git/auth/test", function(req) -- 724
	do -- 725
		local _type_0 = type(req) -- 725
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 725
		if _tab_0 then -- 725
			local body = req.body -- 725
			if body ~= nil then -- 725
				local repoPath, url, authId = body.repoPath, body.url, body.authId -- 726
				local credential = gitLoadCredential(authId) -- 727
				local optionsJSON = gitAuthOptionsJSON(credential) -- 728
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20) -- 729
			end -- 725
		end -- 725
	end -- 725
	return invalidArguments -- 724
end) -- 724
HttpServer:post("/agent/session/create", function(req) -- 731
	do -- 732
		local _type_0 = type(req) -- 732
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 732
		if _tab_0 then -- 732
			local projectRoot -- 732
			do -- 732
				local _obj_0 = req.body -- 732
				local _type_1 = type(_obj_0) -- 732
				if "table" == _type_1 or "userdata" == _type_1 then -- 732
					projectRoot = _obj_0.projectRoot -- 732
				end -- 732
			end -- 732
			local title -- 732
			do -- 732
				local _obj_0 = req.body -- 732
				local _type_1 = type(_obj_0) -- 732
				if "table" == _type_1 or "userdata" == _type_1 then -- 732
					title = _obj_0.title -- 732
				end -- 732
			end -- 732
			if projectRoot ~= nil and title ~= nil then -- 732
				return AgentSession.createSession(projectRoot, title) -- 733
			end -- 732
		end -- 732
	end -- 732
	return invalidArguments -- 731
end) -- 731
HttpServer:post("/agent/session/create-sub", function(req) -- 735
	do -- 736
		local _type_0 = type(req) -- 736
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 736
		if _tab_0 then -- 736
			local parentSessionId -- 736
			do -- 736
				local _obj_0 = req.body -- 736
				local _type_1 = type(_obj_0) -- 736
				if "table" == _type_1 or "userdata" == _type_1 then -- 736
					parentSessionId = _obj_0.parentSessionId -- 736
				end -- 736
			end -- 736
			local title -- 736
			do -- 736
				local _obj_0 = req.body -- 736
				local _type_1 = type(_obj_0) -- 736
				if "table" == _type_1 or "userdata" == _type_1 then -- 736
					title = _obj_0.title -- 736
				end -- 736
			end -- 736
			if parentSessionId ~= nil and title ~= nil then -- 736
				return AgentSession.createSubSession(parentSessionId, title) -- 737
			end -- 736
		end -- 736
	end -- 736
	return invalidArguments -- 735
end) -- 735
HttpServer:post("/agent/session/get", function(req) -- 739
	do -- 740
		local _type_0 = type(req) -- 740
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 740
		if _tab_0 then -- 740
			local sessionId -- 740
			do -- 740
				local _obj_0 = req.body -- 740
				local _type_1 = type(_obj_0) -- 740
				if "table" == _type_1 or "userdata" == _type_1 then -- 740
					sessionId = _obj_0.sessionId -- 740
				end -- 740
			end -- 740
			if sessionId ~= nil then -- 740
				return AgentSession.getSession(sessionId) -- 741
			end -- 740
		end -- 740
	end -- 740
	return invalidArguments -- 739
end) -- 739
HttpServer:post("/agent/session/mode", function(req) -- 743
	do -- 744
		local _type_0 = type(req) -- 744
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 744
		if _tab_0 then -- 744
			local sessionId -- 744
			do -- 744
				local _obj_0 = req.body -- 744
				local _type_1 = type(_obj_0) -- 744
				if "table" == _type_1 or "userdata" == _type_1 then -- 744
					sessionId = _obj_0.sessionId -- 744
				end -- 744
			end -- 744
			local workMode -- 744
			do -- 744
				local _obj_0 = req.body -- 744
				local _type_1 = type(_obj_0) -- 744
				if "table" == _type_1 or "userdata" == _type_1 then -- 744
					workMode = _obj_0.workMode -- 744
				end -- 744
			end -- 744
			if sessionId ~= nil and workMode ~= nil then -- 744
				return AgentSession.setWorkMode(sessionId, workMode) -- 745
			end -- 744
		end -- 744
	end -- 744
	return invalidArguments -- 743
end) -- 743
HttpServer:post("/agent/session/send", function(req) -- 747
	do -- 748
		local _type_0 = type(req) -- 748
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 748
		if _tab_0 then -- 748
			local sessionId -- 748
			do -- 748
				local _obj_0 = req.body -- 748
				local _type_1 = type(_obj_0) -- 748
				if "table" == _type_1 or "userdata" == _type_1 then -- 748
					sessionId = _obj_0.sessionId -- 748
				end -- 748
			end -- 748
			local prompt -- 748
			do -- 748
				local _obj_0 = req.body -- 748
				local _type_1 = type(_obj_0) -- 748
				if "table" == _type_1 or "userdata" == _type_1 then -- 748
					prompt = _obj_0.prompt -- 748
				end -- 748
			end -- 748
			if sessionId ~= nil and prompt ~= nil then -- 748
				return AgentSession.sendPrompt(sessionId, prompt, false, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 749
			end -- 748
		end -- 748
	end -- 748
	return invalidArguments -- 747
end) -- 747
HttpServer:post("/agent/session/continue", function(req) -- 751
	do -- 752
		local _type_0 = type(req) -- 752
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 752
		if _tab_0 then -- 752
			local sessionId -- 752
			do -- 752
				local _obj_0 = req.body -- 752
				local _type_1 = type(_obj_0) -- 752
				if "table" == _type_1 or "userdata" == _type_1 then -- 752
					sessionId = _obj_0.sessionId -- 752
				end -- 752
			end -- 752
			if sessionId ~= nil then -- 752
				return AgentSession.continuePrompt(sessionId, req.body.disabledAgentTools, req.body.llmConfigId) -- 753
			end -- 752
		end -- 752
	end -- 752
	return invalidArguments -- 751
end) -- 751
HttpServer:post("/agent/session/finish-handoff", function(req) -- 755
	do -- 756
		local _type_0 = type(req) -- 756
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 756
		if _tab_0 then -- 756
			local sessionId -- 756
			do -- 756
				local _obj_0 = req.body -- 756
				local _type_1 = type(_obj_0) -- 756
				if "table" == _type_1 or "userdata" == _type_1 then -- 756
					sessionId = _obj_0.sessionId -- 756
				end -- 756
			end -- 756
			if sessionId ~= nil then -- 756
				return AgentSession.finishSubSessionHandoff(sessionId, req.body.llmConfigId) -- 757
			end -- 756
		end -- 756
	end -- 756
	return invalidArguments -- 755
end) -- 755
HttpServer:post("/agent/session/resend", function(req) -- 759
	do -- 760
		local _type_0 = type(req) -- 760
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 760
		if _tab_0 then -- 760
			local sessionId -- 760
			do -- 760
				local _obj_0 = req.body -- 760
				local _type_1 = type(_obj_0) -- 760
				if "table" == _type_1 or "userdata" == _type_1 then -- 760
					sessionId = _obj_0.sessionId -- 760
				end -- 760
			end -- 760
			local messageId -- 760
			do -- 760
				local _obj_0 = req.body -- 760
				local _type_1 = type(_obj_0) -- 760
				if "table" == _type_1 or "userdata" == _type_1 then -- 760
					messageId = _obj_0.messageId -- 760
				end -- 760
			end -- 760
			local prompt -- 760
			do -- 760
				local _obj_0 = req.body -- 760
				local _type_1 = type(_obj_0) -- 760
				if "table" == _type_1 or "userdata" == _type_1 then -- 760
					prompt = _obj_0.prompt -- 760
				end -- 760
			end -- 760
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 760
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 761
			end -- 760
		end -- 760
	end -- 760
	return invalidArguments -- 759
end) -- 759
HttpServer:post("/agent/session/questionnaire/respond", function(req) -- 763
	do -- 764
		local _type_0 = type(req) -- 764
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 764
		if _tab_0 then -- 764
			local sessionId -- 764
			do -- 764
				local _obj_0 = req.body -- 764
				local _type_1 = type(_obj_0) -- 764
				if "table" == _type_1 or "userdata" == _type_1 then -- 764
					sessionId = _obj_0.sessionId -- 764
				end -- 764
			end -- 764
			local questionnaireId -- 764
			do -- 764
				local _obj_0 = req.body -- 764
				local _type_1 = type(_obj_0) -- 764
				if "table" == _type_1 or "userdata" == _type_1 then -- 764
					questionnaireId = _obj_0.questionnaireId -- 764
				end -- 764
			end -- 764
			local answers -- 764
			do -- 764
				local _obj_0 = req.body -- 764
				local _type_1 = type(_obj_0) -- 764
				if "table" == _type_1 or "userdata" == _type_1 then -- 764
					answers = _obj_0.answers -- 764
				end -- 764
			end -- 764
			if sessionId ~= nil and questionnaireId ~= nil and answers ~= nil then -- 764
				return AgentSession.respondQuestionnaire(sessionId, questionnaireId, answers, req.body.llmConfigId) -- 765
			end -- 764
		end -- 764
	end -- 764
	return invalidArguments -- 763
end) -- 763
HttpServer:post("/agent/session/questionnaire/cancel", function(req) -- 767
	do -- 768
		local _type_0 = type(req) -- 768
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 768
		if _tab_0 then -- 768
			local sessionId -- 768
			do -- 768
				local _obj_0 = req.body -- 768
				local _type_1 = type(_obj_0) -- 768
				if "table" == _type_1 or "userdata" == _type_1 then -- 768
					sessionId = _obj_0.sessionId -- 768
				end -- 768
			end -- 768
			local questionnaireId -- 768
			do -- 768
				local _obj_0 = req.body -- 768
				local _type_1 = type(_obj_0) -- 768
				if "table" == _type_1 or "userdata" == _type_1 then -- 768
					questionnaireId = _obj_0.questionnaireId -- 768
				end -- 768
			end -- 768
			if sessionId ~= nil and questionnaireId ~= nil then -- 768
				return AgentSession.cancelQuestionnaire(sessionId, questionnaireId, req.body.llmConfigId) -- 769
			end -- 768
		end -- 768
	end -- 768
	return invalidArguments -- 767
end) -- 767
HttpServer:post("/agent/task/status", function(req) -- 771
	do -- 772
		local _type_0 = type(req) -- 772
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 772
		if _tab_0 then -- 772
			local sessionId -- 772
			do -- 772
				local _obj_0 = req.body -- 772
				local _type_1 = type(_obj_0) -- 772
				if "table" == _type_1 or "userdata" == _type_1 then -- 772
					sessionId = _obj_0.sessionId -- 772
				end -- 772
			end -- 772
			if sessionId ~= nil then -- 772
				local res = AgentSession.getSession(sessionId) -- 773
				if not res.success then -- 774
					return res -- 774
				end -- 774
				local taskId = res.session.currentTaskId -- 775
				local checkpoints -- 776
				if taskId then -- 776
					checkpoints = AgentTools.listCheckpoints(taskId) -- 776
				else -- 776
					checkpoints = { } -- 776
				end -- 776
				return { -- 778
					success = true, -- 778
					session = res.session, -- 779
					relatedSessions = res.relatedSessions, -- 780
					spawnInfo = res.spawnInfo, -- 781
					messages = res.messages, -- 782
					steps = res.steps, -- 783
					checkpoints = checkpoints, -- 784
					pendingQuestionnaire = res.pendingQuestionnaire, -- 785
					hasActivePlan = res.hasActivePlan -- 786
				} -- 777
			end -- 772
		end -- 772
	end -- 772
	return invalidArguments -- 771
end) -- 771
HttpServer:post("/agent/task/running", function() -- 788
	local res = AgentSession.listRunningSessions() -- 789
	if res.success and #res.sessions == 0 then -- 790
		res.sessions = nil -- 791
	end -- 790
	return res -- 792
end) -- 788
HttpServer:post("/agent/task/stop", function(req) -- 794
	do -- 795
		local _type_0 = type(req) -- 795
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 795
		if _tab_0 then -- 795
			local sessionId -- 795
			do -- 795
				local _obj_0 = req.body -- 795
				local _type_1 = type(_obj_0) -- 795
				if "table" == _type_1 or "userdata" == _type_1 then -- 795
					sessionId = _obj_0.sessionId -- 795
				end -- 795
			end -- 795
			if sessionId ~= nil then -- 795
				return AgentSession.stopSessionTask(sessionId) -- 796
			end -- 795
		end -- 795
	end -- 795
	return invalidArguments -- 794
end) -- 794
HttpServer:post("/agent/checkpoint/list", function(req) -- 798
	do -- 799
		local _type_0 = type(req) -- 799
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 799
		if _tab_0 then -- 799
			local taskId -- 799
			do -- 799
				local _obj_0 = req.body -- 799
				local _type_1 = type(_obj_0) -- 799
				if "table" == _type_1 or "userdata" == _type_1 then -- 799
					taskId = _obj_0.taskId -- 799
				end -- 799
			end -- 799
			local sessionId -- 799
			do -- 799
				local _obj_0 = req.body -- 799
				local _type_1 = type(_obj_0) -- 799
				if "table" == _type_1 or "userdata" == _type_1 then -- 799
					sessionId = _obj_0.sessionId -- 799
				end -- 799
			end -- 799
			if sessionId ~= nil then -- 799
				if not taskId and sessionId then -- 800
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 801
				end -- 800
				if not taskId then -- 802
					return { -- 802
						success = false, -- 802
						message = "task not found" -- 802
					} -- 802
				end -- 802
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 803
				if not access.success then -- 804
					return access -- 804
				end -- 804
				return { -- 806
					success = true, -- 806
					taskId = taskId, -- 807
					checkpoints = AgentTools.listCheckpoints(taskId) -- 808
				} -- 805
			end -- 799
		end -- 799
	end -- 799
	return invalidArguments -- 798
end) -- 798
HttpServer:post("/agent/checkpoint/diff", function(req) -- 810
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
			local checkpointId -- 811
			do -- 811
				local _obj_0 = req.body -- 811
				local _type_1 = type(_obj_0) -- 811
				if "table" == _type_1 or "userdata" == _type_1 then -- 811
					checkpointId = _obj_0.checkpointId -- 811
				end -- 811
			end -- 811
			if sessionId ~= nil and checkpointId ~= nil then -- 811
				if not (checkpointId > 0) then -- 812
					return { -- 812
						success = false, -- 812
						message = "invalid checkpointId" -- 812
					} -- 812
				end -- 812
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 813
				if not access.success then -- 814
					return access -- 814
				end -- 814
				return AgentTools.getCheckpointDiff(checkpointId) -- 815
			end -- 811
		end -- 811
	end -- 811
	return invalidArguments -- 810
end) -- 810
HttpServer:post("/agent/task/diff", function(req) -- 817
	do -- 818
		local _type_0 = type(req) -- 818
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 818
		if _tab_0 then -- 818
			local sessionId -- 818
			do -- 818
				local _obj_0 = req.body -- 818
				local _type_1 = type(_obj_0) -- 818
				if "table" == _type_1 or "userdata" == _type_1 then -- 818
					sessionId = _obj_0.sessionId -- 818
				end -- 818
			end -- 818
			local taskId -- 818
			do -- 818
				local _obj_0 = req.body -- 818
				local _type_1 = type(_obj_0) -- 818
				if "table" == _type_1 or "userdata" == _type_1 then -- 818
					taskId = _obj_0.taskId -- 818
				end -- 818
			end -- 818
			if sessionId ~= nil and taskId ~= nil then -- 818
				if not (taskId > 0) then -- 819
					return { -- 819
						success = false, -- 819
						message = "invalid taskId" -- 819
					} -- 819
				end -- 819
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 820
				if not access.success then -- 821
					return access -- 821
				end -- 821
				return AgentTools.getTaskChangeSetDiff(taskId) -- 822
			end -- 818
		end -- 818
	end -- 818
	return invalidArguments -- 817
end) -- 817
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 824
	do -- 825
		local _type_0 = type(req) -- 825
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 825
		if _tab_0 then -- 825
			local sessionId -- 825
			do -- 825
				local _obj_0 = req.body -- 825
				local _type_1 = type(_obj_0) -- 825
				if "table" == _type_1 or "userdata" == _type_1 then -- 825
					sessionId = _obj_0.sessionId -- 825
				end -- 825
			end -- 825
			local checkpointId -- 825
			do -- 825
				local _obj_0 = req.body -- 825
				local _type_1 = type(_obj_0) -- 825
				if "table" == _type_1 or "userdata" == _type_1 then -- 825
					checkpointId = _obj_0.checkpointId -- 825
				end -- 825
			end -- 825
			if sessionId ~= nil and checkpointId ~= nil then -- 825
				if not (checkpointId > 0) then -- 826
					return { -- 826
						success = false, -- 826
						message = "invalid checkpointId" -- 826
					} -- 826
				end -- 826
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 827
				if not access.success then -- 828
					return access -- 828
				end -- 828
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, access.session.projectRoot) -- 829
				if not rollbackRes.success then -- 830
					return rollbackRes -- 830
				end -- 830
				return { -- 832
					success = true, -- 832
					checkpointId = rollbackRes.checkpointId -- 833
				} -- 831
			end -- 825
		end -- 825
	end -- 825
	return invalidArguments -- 824
end) -- 824
HttpServer:post("/agent/task/rollback", function(req) -- 835
	do -- 836
		local _type_0 = type(req) -- 836
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 836
		if _tab_0 then -- 836
			local sessionId -- 836
			do -- 836
				local _obj_0 = req.body -- 836
				local _type_1 = type(_obj_0) -- 836
				if "table" == _type_1 or "userdata" == _type_1 then -- 836
					sessionId = _obj_0.sessionId -- 836
				end -- 836
			end -- 836
			local taskId -- 836
			do -- 836
				local _obj_0 = req.body -- 836
				local _type_1 = type(_obj_0) -- 836
				if "table" == _type_1 or "userdata" == _type_1 then -- 836
					taskId = _obj_0.taskId -- 836
				end -- 836
			end -- 836
			if sessionId ~= nil and taskId ~= nil then -- 836
				if not (taskId > 0) then -- 837
					return { -- 837
						success = false, -- 837
						message = "invalid taskId" -- 837
					} -- 837
				end -- 837
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 838
				if not access.success then -- 839
					return access -- 839
				end -- 839
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, access.session.projectRoot) -- 840
				if not rollbackRes.success then -- 841
					return rollbackRes -- 841
				end -- 841
				return { -- 843
					success = true, -- 843
					taskId = rollbackRes.taskId, -- 844
					checkpointId = rollbackRes.checkpointId, -- 845
					checkpointCount = rollbackRes.checkpointCount -- 846
				} -- 842
			end -- 836
		end -- 836
	end -- 836
	return invalidArguments -- 835
end) -- 835
local getSearchPath -- 848
getSearchPath = function(file) -- 848
	do -- 849
		local dir = getProjectDirFromFile(file) -- 849
		if dir then -- 849
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 850
		end -- 849
	end -- 849
	return "" -- 848
end -- 848
local getSearchFolders -- 852
getSearchFolders = function(file) -- 852
	do -- 853
		local dir = getProjectDirFromFile(file) -- 853
		if dir then -- 853
			return { -- 855
				Path(dir, "Script"), -- 855
				dir -- 856
			} -- 854
		end -- 853
	end -- 853
	return { } -- 852
end -- 852
local disabledCheckForLua = { -- 859
	"incompatible number of returns", -- 859
	"unknown", -- 860
	"cannot index", -- 861
	"module not found", -- 862
	"don't know how to resolve", -- 863
	"ContainerItem", -- 864
	"cannot resolve a type", -- 865
	"invalid key", -- 866
	"inconsistent index type", -- 867
	"cannot use operator", -- 868
	"attempting ipairs loop", -- 869
	"expects record or nominal", -- 870
	"variable is not being assigned", -- 871
	"<invalid type>", -- 872
	"<any type>", -- 873
	"using the '#' operator", -- 874
	"can't match a record", -- 875
	"redeclaration of variable", -- 876
	"cannot apply pairs", -- 877
	"not a function", -- 878
	"to%-be%-closed" -- 879
} -- 858
local yueCheck -- 881
yueCheck = function(file, content, lax) -- 881
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 882
	if isTIC80 then -- 883
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 884
	end -- 883
	local searchPath = getSearchPath(file) -- 885
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 886
	local info = { } -- 887
	local globals = { } -- 888
	for _index_0 = 1, #checkResult do -- 889
		local _des_0 = checkResult[_index_0] -- 889
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 889
		if "error" == t then -- 890
			info[#info + 1] = { -- 891
				"syntax", -- 891
				file, -- 891
				line, -- 891
				col, -- 891
				msg -- 891
			} -- 891
		elseif "global" == t then -- 892
			globals[#globals + 1] = { -- 893
				msg, -- 893
				line, -- 893
				col -- 893
			} -- 893
		end -- 890
	end -- 889
	if luaCodes then -- 894
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 895
		if success then -- 896
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 897
			if not (lintResult == "") then -- 898
				lintResult = lintResult .. "\n" -- 898
			end -- 898
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 899
		else -- 900
			for _index_0 = 1, #lintResult do -- 900
				local _des_0 = lintResult[_index_0] -- 900
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 900
				if isTIC80 and tic80APIs[name] then -- 901
					goto _continue_0 -- 901
				end -- 901
				info[#info + 1] = { -- 902
					"syntax", -- 902
					file, -- 902
					line, -- 902
					col, -- 902
					"invalid global variable" -- 902
				} -- 902
				::_continue_0:: -- 901
			end -- 900
		end -- 896
	end -- 894
	return luaCodes, info -- 903
end -- 881
local luaCheck -- 905
luaCheck = function(file, content) -- 905
	local res, err = load(content, "check") -- 906
	if not res then -- 907
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 908
		return { -- 909
			success = false, -- 909
			info = { -- 909
				{ -- 909
					"syntax", -- 909
					file, -- 909
					tonumber(line), -- 909
					0, -- 909
					msg -- 909
				} -- 909
			} -- 909
		} -- 909
	end -- 907
	local success, info = teal.checkAsync(content, file, true, "") -- 910
	if info then -- 911
		do -- 912
			local _accum_0 = { } -- 912
			local _len_0 = 1 -- 912
			for _index_0 = 1, #info do -- 912
				local item = info[_index_0] -- 912
				local useCheck = true -- 913
				if not item[5]:match("unused") then -- 914
					for _index_1 = 1, #disabledCheckForLua do -- 915
						local check = disabledCheckForLua[_index_1] -- 915
						if item[5]:match(check) then -- 916
							useCheck = false -- 917
						end -- 916
					end -- 915
				end -- 914
				if not useCheck then -- 918
					goto _continue_0 -- 918
				end -- 918
				do -- 919
					local _exp_0 = item[1] -- 919
					if "type" == _exp_0 then -- 920
						item[1] = "warning" -- 921
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 922
						goto _continue_0 -- 923
					end -- 919
				end -- 919
				_accum_0[_len_0] = item -- 924
				_len_0 = _len_0 + 1 -- 913
				::_continue_0:: -- 913
			end -- 912
			info = _accum_0 -- 912
		end -- 912
		if #info == 0 then -- 925
			info = nil -- 926
			success = true -- 927
		end -- 925
	end -- 911
	return { -- 928
		success = success, -- 928
		info = info -- 928
	} -- 928
end -- 905
local luaCheckWithLineInfo -- 930
luaCheckWithLineInfo = function(file, luaCodes) -- 930
	local res = luaCheck(file, luaCodes) -- 931
	local info = { } -- 932
	if not res.success then -- 933
		local current = 1 -- 934
		local lastLine = 1 -- 935
		local lineMap = { } -- 936
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 937
			local num = lineCode:match("--%s*(%d+)%s*$") -- 938
			if num then -- 939
				lastLine = tonumber(num) -- 940
			end -- 939
			lineMap[current] = lastLine -- 941
			current = current + 1 -- 942
		end -- 937
		local _list_0 = res.info -- 943
		for _index_0 = 1, #_list_0 do -- 943
			local item = _list_0[_index_0] -- 943
			item[3] = lineMap[item[3]] or 0 -- 944
			item[4] = 0 -- 945
			info[#info + 1] = item -- 946
		end -- 943
		return false, info -- 947
	end -- 933
	return true, info -- 948
end -- 930
local getCompiledYueLine -- 950
getCompiledYueLine = function(content, line, row, file, lax) -- 950
	local luaCodes = yueCheck(file, content, lax) -- 951
	if not luaCodes then -- 952
		return nil -- 952
	end -- 952
	local current = 1 -- 953
	local lastLine = 1 -- 954
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 955
	local targetRow = nil -- 956
	local lineMap = { } -- 957
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 958
		local num = lineCode:match("--%s*(%d+)%s*$") -- 959
		if num then -- 960
			lastLine = tonumber(num) -- 960
		end -- 960
		lineMap[current] = lastLine -- 961
		if row <= lastLine and not targetRow then -- 962
			targetRow = current -- 963
			break -- 964
		end -- 962
		current = current + 1 -- 965
	end -- 958
	targetRow = current -- 966
	if targetLine and targetRow then -- 967
		return luaCodes, targetLine, targetRow, lineMap -- 968
	else -- 970
		return nil -- 970
	end -- 967
end -- 950
HttpServer:postSchedule("/check", function(req) -- 972
	do -- 973
		local _type_0 = type(req) -- 973
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 973
		if _tab_0 then -- 973
			local file -- 973
			do -- 973
				local _obj_0 = req.body -- 973
				local _type_1 = type(_obj_0) -- 973
				if "table" == _type_1 or "userdata" == _type_1 then -- 973
					file = _obj_0.file -- 973
				end -- 973
			end -- 973
			local content -- 973
			do -- 973
				local _obj_0 = req.body -- 973
				local _type_1 = type(_obj_0) -- 973
				if "table" == _type_1 or "userdata" == _type_1 then -- 973
					content = _obj_0.content -- 973
				end -- 973
			end -- 973
			if file ~= nil and content ~= nil then -- 973
				local ext = Path:getExt(file) -- 974
				if "tl" == ext then -- 975
					local searchPath = getSearchPath(file) -- 976
					do -- 977
						local isTIC80 = CheckTIC80Code(content) -- 977
						if isTIC80 then -- 977
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 978
						end -- 977
					end -- 977
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 979
					return { -- 980
						success = success, -- 980
						info = info -- 980
					} -- 980
				elseif "lua" == ext then -- 981
					do -- 982
						local isTIC80 = CheckTIC80Code(content) -- 982
						if isTIC80 then -- 982
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 983
						end -- 982
					end -- 982
					return luaCheck(file, content) -- 984
				elseif "yue" == ext then -- 985
					local luaCodes, info = yueCheck(file, content, false) -- 986
					local success = luaCodes ~= nil -- 987
					if luaCodes then -- 988
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 989
						do -- 990
							local _tab_1 = { } -- 990
							local _idx_0 = #_tab_1 + 1 -- 990
							for _index_0 = 1, #info do -- 990
								local _value_0 = info[_index_0] -- 990
								_tab_1[_idx_0] = _value_0 -- 990
								_idx_0 = _idx_0 + 1 -- 990
							end -- 990
							local _idx_1 = #_tab_1 + 1 -- 990
							for _index_0 = 1, #luaInfo do -- 990
								local _value_0 = luaInfo[_index_0] -- 990
								_tab_1[_idx_1] = _value_0 -- 990
								_idx_1 = _idx_1 + 1 -- 990
							end -- 990
							info = _tab_1 -- 990
						end -- 990
						success = success and luaSuccess -- 991
					end -- 988
					if #info > 0 then -- 992
						return { -- 993
							success = success, -- 993
							info = info -- 993
						} -- 993
					else -- 995
						return { -- 995
							success = success -- 995
						} -- 995
					end -- 992
				elseif "xml" == ext then -- 996
					local success, result = xml.check(content) -- 997
					if success then -- 998
						local info -- 999
						success, info = luaCheckWithLineInfo(file, result) -- 999
						if #info > 0 then -- 1000
							return { -- 1001
								success = success, -- 1001
								info = info -- 1001
							} -- 1001
						else -- 1003
							return { -- 1003
								success = success -- 1003
							} -- 1003
						end -- 1000
					else -- 1005
						local info -- 1005
						do -- 1005
							local _accum_0 = { } -- 1005
							local _len_0 = 1 -- 1005
							for _index_0 = 1, #result do -- 1005
								local _des_0 = result[_index_0] -- 1005
								local row, err = _des_0[1], _des_0[2] -- 1005
								_accum_0[_len_0] = { -- 1006
									"syntax", -- 1006
									file, -- 1006
									row, -- 1006
									0, -- 1006
									err -- 1006
								} -- 1006
								_len_0 = _len_0 + 1 -- 1006
							end -- 1005
							info = _accum_0 -- 1005
						end -- 1005
						return { -- 1007
							success = false, -- 1007
							info = info -- 1007
						} -- 1007
					end -- 998
				end -- 975
			end -- 973
		end -- 973
	end -- 973
	return { -- 972
		success = true -- 972
	} -- 972
end) -- 972
HttpServer:post("/body/parse", function(req) -- 1009
	do -- 1010
		local _type_0 = type(req) -- 1010
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1010
		if _tab_0 then -- 1010
			local file -- 1010
			do -- 1010
				local _obj_0 = req.body -- 1010
				local _type_1 = type(_obj_0) -- 1010
				if "table" == _type_1 or "userdata" == _type_1 then -- 1010
					file = _obj_0.file -- 1010
				end -- 1010
			end -- 1010
			local content -- 1010
			do -- 1010
				local _obj_0 = req.body -- 1010
				local _type_1 = type(_obj_0) -- 1010
				if "table" == _type_1 or "userdata" == _type_1 then -- 1010
					content = _obj_0.content -- 1010
				end -- 1010
			end -- 1010
			if file ~= nil and content ~= nil then -- 1010
				if not (file:sub(-6) == ".b.lua") then -- 1011
					return { -- 1012
						success = false, -- 1012
						phase = "request", -- 1012
						message = "only .b.lua files can be converted" -- 1012
					} -- 1012
				end -- 1011
				local loader, err = load("_ENV = {}\n" .. content) -- 1013
				if not loader then -- 1014
					return { -- 1015
						success = false, -- 1015
						phase = "parse", -- 1015
						message = tostring(err) -- 1015
					} -- 1015
				end -- 1014
				local ok, data = pcall(loader) -- 1016
				if not ok then -- 1017
					return { -- 1018
						success = false, -- 1018
						phase = "execute", -- 1018
						message = tostring(data) -- 1018
					} -- 1018
				end -- 1017
				if not ("table" == type(data) and data[1] == "Array") then -- 1019
					return { -- 1020
						success = false, -- 1020
						phase = "validate", -- 1020
						message = "body lua root must be {\"Array\", ...}" -- 1020
					} -- 1020
				end -- 1019
				local text, jsonErr = json.encode(data, false, true) -- 1021
				if not text then -- 1022
					return { -- 1023
						success = false, -- 1023
						phase = "encode", -- 1023
						message = tostring(jsonErr) -- 1023
					} -- 1023
				end -- 1022
				return { -- 1024
					success = true, -- 1024
					json = text -- 1024
				} -- 1024
			end -- 1010
		end -- 1010
	end -- 1010
	return { -- 1009
		success = false, -- 1009
		phase = "request", -- 1009
		message = "invalid request" -- 1009
	} -- 1009
end) -- 1009
local updateInferedDesc -- 1026
updateInferedDesc = function(infered) -- 1026
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1027
		return -- 1027
	end -- 1027
	local key, row = infered.key, infered.row -- 1028
	local codes = Content:loadAsync(key) -- 1029
	if codes then -- 1029
		local comments = { } -- 1030
		local line = 0 -- 1031
		local skipping = false -- 1032
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1033
			line = line + 1 -- 1034
			if line >= row then -- 1035
				break -- 1035
			end -- 1035
			if lineCode:match("^%s*%-%- @") then -- 1036
				skipping = true -- 1037
				goto _continue_0 -- 1038
			end -- 1036
			local result = lineCode:match("^%s*%-%- (.+)") -- 1039
			if result then -- 1039
				if not skipping then -- 1040
					comments[#comments + 1] = result -- 1040
				end -- 1040
			elseif #comments > 0 then -- 1041
				comments = { } -- 1042
				skipping = false -- 1043
			end -- 1039
			::_continue_0:: -- 1034
		end -- 1033
		infered.doc = table.concat(comments, "\n") -- 1044
	end -- 1029
end -- 1026
HttpServer:postSchedule("/infer", function(req) -- 1046
	do -- 1047
		local _type_0 = type(req) -- 1047
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1047
		if _tab_0 then -- 1047
			local lang -- 1047
			do -- 1047
				local _obj_0 = req.body -- 1047
				local _type_1 = type(_obj_0) -- 1047
				if "table" == _type_1 or "userdata" == _type_1 then -- 1047
					lang = _obj_0.lang -- 1047
				end -- 1047
			end -- 1047
			local file -- 1047
			do -- 1047
				local _obj_0 = req.body -- 1047
				local _type_1 = type(_obj_0) -- 1047
				if "table" == _type_1 or "userdata" == _type_1 then -- 1047
					file = _obj_0.file -- 1047
				end -- 1047
			end -- 1047
			local content -- 1047
			do -- 1047
				local _obj_0 = req.body -- 1047
				local _type_1 = type(_obj_0) -- 1047
				if "table" == _type_1 or "userdata" == _type_1 then -- 1047
					content = _obj_0.content -- 1047
				end -- 1047
			end -- 1047
			local line -- 1047
			do -- 1047
				local _obj_0 = req.body -- 1047
				local _type_1 = type(_obj_0) -- 1047
				if "table" == _type_1 or "userdata" == _type_1 then -- 1047
					line = _obj_0.line -- 1047
				end -- 1047
			end -- 1047
			local row -- 1047
			do -- 1047
				local _obj_0 = req.body -- 1047
				local _type_1 = type(_obj_0) -- 1047
				if "table" == _type_1 or "userdata" == _type_1 then -- 1047
					row = _obj_0.row -- 1047
				end -- 1047
			end -- 1047
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1047
				local searchPath = getSearchPath(file) -- 1048
				if "tl" == lang or "lua" == lang then -- 1049
					if CheckTIC80Code(content) then -- 1050
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1051
					end -- 1050
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1052
					if (infered ~= nil) then -- 1053
						updateInferedDesc(infered) -- 1054
						return { -- 1055
							success = true, -- 1055
							infered = infered -- 1055
						} -- 1055
					end -- 1053
				elseif "yue" == lang then -- 1056
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1057
					if not luaCodes then -- 1058
						return { -- 1058
							success = false -- 1058
						} -- 1058
					end -- 1058
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1059
					if (infered ~= nil) then -- 1060
						local col -- 1061
						file, row, col = infered.file, infered.row, infered.col -- 1061
						if file == "" and row > 0 and col > 0 then -- 1062
							infered.row = lineMap[row] or 0 -- 1063
							infered.col = 0 -- 1064
						end -- 1062
						updateInferedDesc(infered) -- 1065
						return { -- 1066
							success = true, -- 1066
							infered = infered -- 1066
						} -- 1066
					end -- 1060
				end -- 1049
			end -- 1047
		end -- 1047
	end -- 1047
	return { -- 1046
		success = false -- 1046
	} -- 1046
end) -- 1046
local _anon_func_3 = function(doc) -- 1127
	local _accum_0 = { } -- 1127
	local _len_0 = 1 -- 1127
	local _list_0 = doc.params -- 1127
	for _index_0 = 1, #_list_0 do -- 1127
		local param = _list_0[_index_0] -- 1127
		_accum_0[_len_0] = param.name -- 1127
		_len_0 = _len_0 + 1 -- 1127
	end -- 1127
	return _accum_0 -- 1127
end -- 1127
local getParamDocs -- 1068
getParamDocs = function(signatures) -- 1068
	if not (signatures and #signatures > 0) then -- 1069
		return nil -- 1069
	end -- 1069
	local docs = { } -- 1070
	do -- 1071
		local codes = Content:loadAsync(signatures[1].file) -- 1071
		if codes then -- 1071
			local comments = { } -- 1072
			local params = { } -- 1073
			local line = 0 -- 1074
			local returnType = nil -- 1075
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1076
				line = line + 1 -- 1077
				local needBreak = true -- 1078
				for i, _des_0 in ipairs(signatures) do -- 1079
					local row = _des_0.row -- 1079
					if line >= row and not (docs[i] ~= nil) then -- 1080
						if #comments > 0 or #params > 0 or returnType then -- 1081
							docs[i] = { -- 1083
								doc = table.concat(comments, "  \n"), -- 1083
								returnType = returnType -- 1084
							} -- 1082
							if #params > 0 then -- 1086
								docs[i].params = params -- 1086
							end -- 1086
						else -- 1088
							docs[i] = false -- 1088
						end -- 1081
					end -- 1080
					if not docs[i] then -- 1089
						needBreak = false -- 1089
					end -- 1089
				end -- 1079
				if needBreak then -- 1090
					break -- 1090
				end -- 1090
				local result = lineCode:match("%s*%-%- (.+)") -- 1091
				if result then -- 1091
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1092
					if not name then -- 1093
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1094
					end -- 1093
					if name then -- 1095
						local pname = name -- 1096
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1097
							pname = pname .. "?" -- 1097
						end -- 1097
						params[#params + 1] = { -- 1099
							name = tostring(pname) .. ": " .. tostring(typ), -- 1099
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1100
						} -- 1098
					else -- 1103
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1103
						if typ then -- 1103
							if returnType then -- 1104
								returnType = returnType .. ", " .. typ -- 1105
							else -- 1107
								returnType = typ -- 1107
							end -- 1104
							result = result:gsub("@return", "**return:**") -- 1108
						end -- 1103
						comments[#comments + 1] = result -- 1109
					end -- 1095
				elseif #comments > 0 then -- 1110
					comments = { } -- 1111
					params = { } -- 1112
					returnType = nil -- 1113
				end -- 1091
			end -- 1076
		end -- 1071
	end -- 1071
	local results = { } -- 1114
	for i, signature in ipairs(signatures) do -- 1115
		local item = { -- 1117
			desc = signature.desc, -- 1117
			doc = "", -- 1118
			file = signature.file, -- 1119
			row = signature.row, -- 1120
			col = signature.col -- 1121
		} -- 1116
		do -- 1123
			local doc = docs[i] -- 1123
			if doc then -- 1123
				item.doc = doc.doc -- 1124
				if doc.params then -- 1125
					item.params = doc.params -- 1126
					item.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1127
				elseif doc.returnType then -- 1128
					item.desc = "function()" -- 1129
				end -- 1125
				if doc.returnType then -- 1130
					item.desc = item.desc .. ": " .. tostring(doc.returnType) -- 1130
				end -- 1130
			end -- 1123
		end -- 1123
		results[#results + 1] = item -- 1131
	end -- 1115
	return results -- 1132
end -- 1068
HttpServer:postSchedule("/signature", function(req) -- 1134
	do -- 1135
		local _type_0 = type(req) -- 1135
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1135
		if _tab_0 then -- 1135
			local lang -- 1135
			do -- 1135
				local _obj_0 = req.body -- 1135
				local _type_1 = type(_obj_0) -- 1135
				if "table" == _type_1 or "userdata" == _type_1 then -- 1135
					lang = _obj_0.lang -- 1135
				end -- 1135
			end -- 1135
			local file -- 1135
			do -- 1135
				local _obj_0 = req.body -- 1135
				local _type_1 = type(_obj_0) -- 1135
				if "table" == _type_1 or "userdata" == _type_1 then -- 1135
					file = _obj_0.file -- 1135
				end -- 1135
			end -- 1135
			local content -- 1135
			do -- 1135
				local _obj_0 = req.body -- 1135
				local _type_1 = type(_obj_0) -- 1135
				if "table" == _type_1 or "userdata" == _type_1 then -- 1135
					content = _obj_0.content -- 1135
				end -- 1135
			end -- 1135
			local line -- 1135
			do -- 1135
				local _obj_0 = req.body -- 1135
				local _type_1 = type(_obj_0) -- 1135
				if "table" == _type_1 or "userdata" == _type_1 then -- 1135
					line = _obj_0.line -- 1135
				end -- 1135
			end -- 1135
			local row -- 1135
			do -- 1135
				local _obj_0 = req.body -- 1135
				local _type_1 = type(_obj_0) -- 1135
				if "table" == _type_1 or "userdata" == _type_1 then -- 1135
					row = _obj_0.row -- 1135
				end -- 1135
			end -- 1135
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1135
				local searchPath = getSearchPath(file) -- 1136
				if "tl" == lang or "lua" == lang then -- 1137
					if CheckTIC80Code(content) then -- 1138
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1139
					end -- 1138
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1140
					if signatures then -- 1140
						signatures = getParamDocs(signatures) -- 1141
						if signatures then -- 1141
							return { -- 1142
								success = true, -- 1142
								signatures = signatures -- 1142
							} -- 1142
						end -- 1141
					end -- 1140
				elseif "yue" == lang then -- 1143
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1144
					if not luaCodes then -- 1145
						return { -- 1145
							success = false -- 1145
						} -- 1145
					end -- 1145
					do -- 1146
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1146
						if chainOp then -- 1146
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1147
							if withVar then -- 1147
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1148
							end -- 1147
						end -- 1146
					end -- 1146
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1149
					if signatures then -- 1149
						signatures = getParamDocs(signatures) -- 1150
						if signatures then -- 1150
							return { -- 1151
								success = true, -- 1151
								signatures = signatures -- 1151
							} -- 1151
						end -- 1150
					else -- 1152
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1152
						if signatures then -- 1152
							signatures = getParamDocs(signatures) -- 1153
							if signatures then -- 1153
								return { -- 1154
									success = true, -- 1154
									signatures = signatures -- 1154
								} -- 1154
							end -- 1153
						end -- 1152
					end -- 1149
				end -- 1137
			end -- 1135
		end -- 1135
	end -- 1135
	return { -- 1134
		success = false -- 1134
	} -- 1134
end) -- 1134
local luaKeywords = { -- 1157
	'and', -- 1157
	'break', -- 1158
	'do', -- 1159
	'else', -- 1160
	'elseif', -- 1161
	'end', -- 1162
	'false', -- 1163
	'for', -- 1164
	'function', -- 1165
	'goto', -- 1166
	'if', -- 1167
	'in', -- 1168
	'local', -- 1169
	'nil', -- 1170
	'not', -- 1171
	'or', -- 1172
	'repeat', -- 1173
	'return', -- 1174
	'then', -- 1175
	'true', -- 1176
	'until', -- 1177
	'while' -- 1178
} -- 1156
local tealKeywords = { -- 1182
	'record', -- 1182
	'as', -- 1183
	'is', -- 1184
	'type', -- 1185
	'embed', -- 1186
	'enum', -- 1187
	'global', -- 1188
	'any', -- 1189
	'boolean', -- 1190
	'integer', -- 1191
	'number', -- 1192
	'string', -- 1193
	'thread' -- 1194
} -- 1181
local yueKeywords = { -- 1198
	"and", -- 1198
	"break", -- 1199
	"do", -- 1200
	"else", -- 1201
	"elseif", -- 1202
	"false", -- 1203
	"for", -- 1204
	"goto", -- 1205
	"if", -- 1206
	"in", -- 1207
	"local", -- 1208
	"nil", -- 1209
	"not", -- 1210
	"or", -- 1211
	"repeat", -- 1212
	"return", -- 1213
	"then", -- 1214
	"true", -- 1215
	"until", -- 1216
	"while", -- 1217
	"as", -- 1218
	"class", -- 1219
	"continue", -- 1220
	"export", -- 1221
	"extends", -- 1222
	"from", -- 1223
	"global", -- 1224
	"import", -- 1225
	"macro", -- 1226
	"switch", -- 1227
	"try", -- 1228
	"unless", -- 1229
	"using", -- 1230
	"when", -- 1231
	"with" -- 1232
} -- 1197
local _anon_func_4 = function(f) -- 1268
	local _val_0 = Path:getExt(f) -- 1268
	return "ttf" == _val_0 or "otf" == _val_0 -- 1268
end -- 1268
local _anon_func_5 = function(suggestions) -- 1294
	local _tbl_0 = { } -- 1294
	for _index_0 = 1, #suggestions do -- 1294
		local item = suggestions[_index_0] -- 1294
		_tbl_0[item[1] .. item[2]] = item -- 1294
	end -- 1294
	return _tbl_0 -- 1294
end -- 1294
HttpServer:postSchedule("/complete", function(req) -- 1235
	do -- 1236
		local _type_0 = type(req) -- 1236
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1236
		if _tab_0 then -- 1236
			local lang -- 1236
			do -- 1236
				local _obj_0 = req.body -- 1236
				local _type_1 = type(_obj_0) -- 1236
				if "table" == _type_1 or "userdata" == _type_1 then -- 1236
					lang = _obj_0.lang -- 1236
				end -- 1236
			end -- 1236
			local file -- 1236
			do -- 1236
				local _obj_0 = req.body -- 1236
				local _type_1 = type(_obj_0) -- 1236
				if "table" == _type_1 or "userdata" == _type_1 then -- 1236
					file = _obj_0.file -- 1236
				end -- 1236
			end -- 1236
			local content -- 1236
			do -- 1236
				local _obj_0 = req.body -- 1236
				local _type_1 = type(_obj_0) -- 1236
				if "table" == _type_1 or "userdata" == _type_1 then -- 1236
					content = _obj_0.content -- 1236
				end -- 1236
			end -- 1236
			local line -- 1236
			do -- 1236
				local _obj_0 = req.body -- 1236
				local _type_1 = type(_obj_0) -- 1236
				if "table" == _type_1 or "userdata" == _type_1 then -- 1236
					line = _obj_0.line -- 1236
				end -- 1236
			end -- 1236
			local row -- 1236
			do -- 1236
				local _obj_0 = req.body -- 1236
				local _type_1 = type(_obj_0) -- 1236
				if "table" == _type_1 or "userdata" == _type_1 then -- 1236
					row = _obj_0.row -- 1236
				end -- 1236
			end -- 1236
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1236
				local searchPath = getSearchPath(file) -- 1237
				repeat -- 1238
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1239
					if lang == "yue" then -- 1240
						if not item then -- 1241
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1241
						end -- 1241
						if not item then -- 1242
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1242
						end -- 1242
					end -- 1240
					local searchType = nil -- 1243
					if not item then -- 1244
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1245
						if lang == "yue" then -- 1246
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1247
						end -- 1246
						if (item ~= nil) then -- 1248
							searchType = "Image" -- 1248
						end -- 1248
					end -- 1244
					if not item then -- 1249
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1250
						if lang == "yue" then -- 1251
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1252
						end -- 1251
						if (item ~= nil) then -- 1253
							searchType = "Font" -- 1253
						end -- 1253
					end -- 1249
					if not item then -- 1254
						break -- 1254
					end -- 1254
					local searchPaths = Content.searchPaths -- 1255
					local _list_0 = getSearchFolders(file) -- 1256
					for _index_0 = 1, #_list_0 do -- 1256
						local folder = _list_0[_index_0] -- 1256
						searchPaths[#searchPaths + 1] = folder -- 1257
					end -- 1256
					if searchType then -- 1258
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1258
					end -- 1258
					local tokens -- 1259
					do -- 1259
						local _accum_0 = { } -- 1259
						local _len_0 = 1 -- 1259
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1259
							_accum_0[_len_0] = mod -- 1259
							_len_0 = _len_0 + 1 -- 1259
						end -- 1259
						tokens = _accum_0 -- 1259
					end -- 1259
					local suggestions = { } -- 1260
					for _index_0 = 1, #searchPaths do -- 1261
						local path = searchPaths[_index_0] -- 1261
						local sPath = Path(path, table.unpack(tokens)) -- 1262
						if not Content:exist(sPath) then -- 1263
							goto _continue_0 -- 1263
						end -- 1263
						if searchType == "Font" then -- 1264
							local fontPath = Path(sPath, "Font") -- 1265
							if Content:exist(fontPath) then -- 1266
								local _list_1 = Content:getFiles(fontPath) -- 1267
								for _index_1 = 1, #_list_1 do -- 1267
									local f = _list_1[_index_1] -- 1267
									if _anon_func_4(f) then -- 1268
										if "." == f:sub(1, 1) then -- 1269
											goto _continue_1 -- 1269
										end -- 1269
										suggestions[#suggestions + 1] = { -- 1270
											Path:getName(f), -- 1270
											"font", -- 1270
											"field" -- 1270
										} -- 1270
									end -- 1268
									::_continue_1:: -- 1268
								end -- 1267
							end -- 1266
						end -- 1264
						local _list_1 = Content:getFiles(sPath) -- 1271
						for _index_1 = 1, #_list_1 do -- 1271
							local f = _list_1[_index_1] -- 1271
							if "Image" == searchType then -- 1272
								do -- 1273
									local _exp_0 = Path:getExt(f) -- 1273
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1273
										if "." == f:sub(1, 1) then -- 1274
											goto _continue_2 -- 1274
										end -- 1274
										suggestions[#suggestions + 1] = { -- 1275
											f, -- 1275
											"image", -- 1275
											"field" -- 1275
										} -- 1275
									end -- 1273
								end -- 1273
								goto _continue_2 -- 1276
							elseif "Font" == searchType then -- 1277
								do -- 1278
									local _exp_0 = Path:getExt(f) -- 1278
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1278
										if "." == f:sub(1, 1) then -- 1279
											goto _continue_2 -- 1279
										end -- 1279
										suggestions[#suggestions + 1] = { -- 1280
											f, -- 1280
											"font", -- 1280
											"field" -- 1280
										} -- 1280
									end -- 1278
								end -- 1278
								goto _continue_2 -- 1281
							end -- 1272
							local _exp_0 = Path:getExt(f) -- 1282
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1282
								local name = Path:getName(f) -- 1283
								if "d" == Path:getExt(name) then -- 1284
									goto _continue_2 -- 1284
								end -- 1284
								if "." == name:sub(1, 1) then -- 1285
									goto _continue_2 -- 1285
								end -- 1285
								suggestions[#suggestions + 1] = { -- 1286
									name, -- 1286
									"module", -- 1286
									"field" -- 1286
								} -- 1286
							end -- 1282
							::_continue_2:: -- 1272
						end -- 1271
						local _list_2 = Content:getDirs(sPath) -- 1287
						for _index_1 = 1, #_list_2 do -- 1287
							local dir = _list_2[_index_1] -- 1287
							if "." == dir:sub(1, 1) then -- 1288
								goto _continue_3 -- 1288
							end -- 1288
							suggestions[#suggestions + 1] = { -- 1289
								dir, -- 1289
								"folder", -- 1289
								"variable" -- 1289
							} -- 1289
							::_continue_3:: -- 1288
						end -- 1287
						::_continue_0:: -- 1262
					end -- 1261
					if item == "" and not searchType then -- 1290
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1291
						for _index_0 = 1, #_list_1 do -- 1291
							local _des_0 = _list_1[_index_0] -- 1291
							local name = _des_0[1] -- 1291
							suggestions[#suggestions + 1] = { -- 1292
								name, -- 1292
								"dora module", -- 1292
								"function" -- 1292
							} -- 1292
						end -- 1291
					end -- 1290
					if #suggestions > 0 then -- 1293
						do -- 1294
							local _accum_0 = { } -- 1294
							local _len_0 = 1 -- 1294
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1294
								_accum_0[_len_0] = v -- 1294
								_len_0 = _len_0 + 1 -- 1294
							end -- 1294
							suggestions = _accum_0 -- 1294
						end -- 1294
						return { -- 1295
							success = true, -- 1295
							suggestions = suggestions -- 1295
						} -- 1295
					else -- 1297
						return { -- 1297
							success = false -- 1297
						} -- 1297
					end -- 1293
				until true -- 1238
				if "tl" == lang or "lua" == lang then -- 1299
					do -- 1300
						local isTIC80 = CheckTIC80Code(content) -- 1300
						if isTIC80 then -- 1300
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1301
						end -- 1300
					end -- 1300
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1302
					if not line:match("[%.:]$") then -- 1303
						local checkSet -- 1304
						do -- 1304
							local _tbl_0 = { } -- 1304
							for _index_0 = 1, #suggestions do -- 1304
								local _des_0 = suggestions[_index_0] -- 1304
								local name = _des_0[1] -- 1304
								_tbl_0[name] = true -- 1304
							end -- 1304
							checkSet = _tbl_0 -- 1304
						end -- 1304
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1305
						for _index_0 = 1, #_list_0 do -- 1305
							local item = _list_0[_index_0] -- 1305
							if not checkSet[item[1]] then -- 1306
								suggestions[#suggestions + 1] = item -- 1306
							end -- 1306
						end -- 1305
						for _index_0 = 1, #luaKeywords do -- 1307
							local word = luaKeywords[_index_0] -- 1307
							suggestions[#suggestions + 1] = { -- 1308
								word, -- 1308
								"keyword", -- 1308
								"keyword" -- 1308
							} -- 1308
						end -- 1307
						if lang == "tl" then -- 1309
							for _index_0 = 1, #tealKeywords do -- 1310
								local word = tealKeywords[_index_0] -- 1310
								suggestions[#suggestions + 1] = { -- 1311
									word, -- 1311
									"keyword", -- 1311
									"keyword" -- 1311
								} -- 1311
							end -- 1310
						end -- 1309
					end -- 1303
					if #suggestions > 0 then -- 1312
						return { -- 1313
							success = true, -- 1313
							suggestions = suggestions -- 1313
						} -- 1313
					end -- 1312
				elseif "yue" == lang then -- 1314
					local suggestions = { } -- 1315
					local gotGlobals = false -- 1316
					do -- 1317
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1317
						if luaCodes then -- 1317
							gotGlobals = true -- 1318
							do -- 1319
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1319
								if chainOp then -- 1319
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1320
									if not withVar then -- 1321
										return { -- 1321
											success = false -- 1321
										} -- 1321
									end -- 1321
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1322
								elseif line:match("^([%.\\])$") then -- 1323
									return { -- 1324
										success = false -- 1324
									} -- 1324
								end -- 1319
							end -- 1319
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1325
							for _index_0 = 1, #_list_0 do -- 1325
								local item = _list_0[_index_0] -- 1325
								suggestions[#suggestions + 1] = item -- 1325
							end -- 1325
							if #suggestions == 0 then -- 1326
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1327
								for _index_0 = 1, #_list_1 do -- 1327
									local item = _list_1[_index_0] -- 1327
									suggestions[#suggestions + 1] = item -- 1327
								end -- 1327
							end -- 1326
						end -- 1317
					end -- 1317
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1328
						local checkSet -- 1329
						do -- 1329
							local _tbl_0 = { } -- 1329
							for _index_0 = 1, #suggestions do -- 1329
								local _des_0 = suggestions[_index_0] -- 1329
								local name = _des_0[1] -- 1329
								_tbl_0[name] = true -- 1329
							end -- 1329
							checkSet = _tbl_0 -- 1329
						end -- 1329
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1330
						for _index_0 = 1, #_list_0 do -- 1330
							local item = _list_0[_index_0] -- 1330
							if not checkSet[item[1]] then -- 1331
								suggestions[#suggestions + 1] = item -- 1331
							end -- 1331
						end -- 1330
						if not gotGlobals then -- 1332
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1333
							for _index_0 = 1, #_list_1 do -- 1333
								local item = _list_1[_index_0] -- 1333
								if not checkSet[item[1]] then -- 1334
									suggestions[#suggestions + 1] = item -- 1334
								end -- 1334
							end -- 1333
						end -- 1332
						for _index_0 = 1, #yueKeywords do -- 1335
							local word = yueKeywords[_index_0] -- 1335
							if not checkSet[word] then -- 1336
								suggestions[#suggestions + 1] = { -- 1337
									word, -- 1337
									"keyword", -- 1337
									"keyword" -- 1337
								} -- 1337
							end -- 1336
						end -- 1335
					end -- 1328
					if #suggestions > 0 then -- 1338
						return { -- 1339
							success = true, -- 1339
							suggestions = suggestions -- 1339
						} -- 1339
					end -- 1338
				elseif "xml" == lang then -- 1340
					local items = xml.complete(content) -- 1341
					if #items > 0 then -- 1342
						local suggestions -- 1343
						do -- 1343
							local _accum_0 = { } -- 1343
							local _len_0 = 1 -- 1343
							for _index_0 = 1, #items do -- 1343
								local _des_0 = items[_index_0] -- 1343
								local label, insertText = _des_0[1], _des_0[2] -- 1343
								_accum_0[_len_0] = { -- 1344
									label, -- 1344
									insertText, -- 1344
									"field" -- 1344
								} -- 1344
								_len_0 = _len_0 + 1 -- 1344
							end -- 1343
							suggestions = _accum_0 -- 1343
						end -- 1343
						return { -- 1345
							success = true, -- 1345
							suggestions = suggestions -- 1345
						} -- 1345
					end -- 1342
				end -- 1299
			end -- 1236
		end -- 1236
	end -- 1236
	return { -- 1235
		success = false -- 1235
	} -- 1235
end) -- 1235
HttpServer:upload("/upload", function(req, filename) -- 1349
	do -- 1350
		local _type_0 = type(req) -- 1350
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1350
		if _tab_0 then -- 1350
			local path -- 1350
			do -- 1350
				local _obj_0 = req.params -- 1350
				local _type_1 = type(_obj_0) -- 1350
				if "table" == _type_1 or "userdata" == _type_1 then -- 1350
					path = _obj_0.path -- 1350
				end -- 1350
			end -- 1350
			if path ~= nil then -- 1350
				local uploadPath = Path(Content.writablePath, ".upload") -- 1351
				if not Content:exist(uploadPath) then -- 1352
					Content:mkdir(uploadPath) -- 1353
				end -- 1352
				local targetPath = Path(uploadPath, filename) -- 1354
				Content:mkdir(Path:getPath(targetPath)) -- 1355
				return targetPath -- 1356
			end -- 1350
		end -- 1350
	end -- 1350
	return nil -- 1349
end, function(req, file) -- 1357
	do -- 1358
		local _type_0 = type(req) -- 1358
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1358
		if _tab_0 then -- 1358
			local path -- 1358
			do -- 1358
				local _obj_0 = req.params -- 1358
				local _type_1 = type(_obj_0) -- 1358
				if "table" == _type_1 or "userdata" == _type_1 then -- 1358
					path = _obj_0.path -- 1358
				end -- 1358
			end -- 1358
			if path ~= nil then -- 1358
				path = Path(Content.writablePath, path) -- 1359
				if Content:exist(path) then -- 1360
					local uploadPath = Path(Content.writablePath, ".upload") -- 1361
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1362
					Content:mkdir(Path:getPath(targetPath)) -- 1363
					if Content:move(file, targetPath) then -- 1364
						return true -- 1365
					end -- 1364
				end -- 1360
			end -- 1358
		end -- 1358
	end -- 1358
	return false -- 1357
end) -- 1347
HttpServer:post("/list", function(req) -- 1368
	do -- 1369
		local _type_0 = type(req) -- 1369
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1369
		if _tab_0 then -- 1369
			local path -- 1369
			do -- 1369
				local _obj_0 = req.body -- 1369
				local _type_1 = type(_obj_0) -- 1369
				if "table" == _type_1 or "userdata" == _type_1 then -- 1369
					path = _obj_0.path -- 1369
				end -- 1369
			end -- 1369
			if path ~= nil then -- 1369
				if Content:exist(path) then -- 1370
					local files = { } -- 1371
					local visitAssets -- 1372
					visitAssets = function(path, folder) -- 1372
						local dirs = Content:getDirs(path) -- 1373
						for _index_0 = 1, #dirs do -- 1374
							local dir = dirs[_index_0] -- 1374
							if dir:match("^%.") or dir == "node_modules" then -- 1375
								goto _continue_0 -- 1375
							end -- 1375
							local current -- 1376
							if folder == "" then -- 1376
								current = dir -- 1377
							else -- 1379
								current = Path(folder, dir) -- 1379
							end -- 1376
							files[#files + 1] = current -- 1380
							visitAssets(Path(path, dir), current) -- 1381
							::_continue_0:: -- 1375
						end -- 1374
						local fs = Content:getFiles(path) -- 1382
						for _index_0 = 1, #fs do -- 1383
							local f = fs[_index_0] -- 1383
							if (".DS_Store" == f) then -- 1384
								goto _continue_1 -- 1385
							end -- 1384
							if folder == "" then -- 1386
								files[#files + 1] = f -- 1387
							else -- 1389
								files[#files + 1] = Path(folder, f) -- 1389
							end -- 1386
							::_continue_1:: -- 1384
						end -- 1383
					end -- 1372
					visitAssets(path, "") -- 1390
					if #files == 0 then -- 1391
						files = nil -- 1391
					end -- 1391
					return { -- 1392
						success = true, -- 1392
						files = files -- 1392
					} -- 1392
				end -- 1370
			end -- 1369
		end -- 1369
	end -- 1369
	return { -- 1368
		success = false -- 1368
	} -- 1368
end) -- 1368
HttpServer:post("/info", function(req) -- 1394
	local Entry = require("Script.Dev.Entry") -- 1395
	local config = Entry.getConfig() -- 1396
	do -- 1397
		local _type_0 = type(req) -- 1397
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1397
		if _tab_0 then -- 1397
			local webIDETourCompleted -- 1397
			do -- 1397
				local _obj_0 = req.body -- 1397
				local _type_1 = type(_obj_0) -- 1397
				if "table" == _type_1 or "userdata" == _type_1 then -- 1397
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1397
				end -- 1397
			end -- 1397
			if webIDETourCompleted ~= nil then -- 1397
				config.webIDETourCompleted = webIDETourCompleted == true -- 1398
			end -- 1397
		end -- 1397
	end -- 1397
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1399
	local engineDev = Entry.getEngineDev() -- 1400
	Entry.connectWebIDE() -- 1401
	return { -- 1403
		platform = App.platform, -- 1403
		locale = App.locale, -- 1404
		version = App.version, -- 1405
		engineDev = engineDev, -- 1406
		webProfiler = webProfiler, -- 1407
		drawerWidth = drawerWidth, -- 1408
		webIDETourCompleted = webIDETourCompleted == true -- 1409
	} -- 1402
end) -- 1394
local ensureLLMConfigTable -- 1411
ensureLLMConfigTable = function() -- 1411
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1412
	if columns and #columns > 0 then -- 1413
		local expected = { -- 1415
			id = true, -- 1415
			name = true, -- 1416
			url = true, -- 1417
			model = true, -- 1418
			api_key = true, -- 1419
			context_window = true, -- 1420
			temperature = true, -- 1421
			max_tokens = true, -- 1422
			reasoning_effort = true, -- 1423
			custom_options = true, -- 1424
			supports_function_calling = true, -- 1425
			active = true, -- 1426
			created_at = true, -- 1427
			updated_at = true -- 1428
		} -- 1414
		local existing = { } -- 1430
		local valid = true -- 1431
		for _index_0 = 1, #columns do -- 1432
			local row = columns[_index_0] -- 1432
			local columnName = tostring(row[2]) -- 1433
			existing[columnName] = true -- 1434
			if not expected[columnName] then -- 1435
				valid = false -- 1436
				break -- 1437
			end -- 1435
		end -- 1432
		if valid then -- 1438
			if not existing.context_window then -- 1439
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1440
			end -- 1439
			if not existing.temperature then -- 1441
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1442
			end -- 1441
			if not existing.max_tokens then -- 1443
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 1444
			end -- 1443
			if not existing.reasoning_effort then -- 1445
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1446
			end -- 1445
			if not existing.custom_options then -- 1447
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1448
			end -- 1447
			if not existing.supports_function_calling then -- 1449
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1450
			end -- 1449
		else -- 1452
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1452
		end -- 1438
	end -- 1413
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
	]]) -- 1453
end -- 1411
local normalizeContextWindow -- 1472
normalizeContextWindow = function(value) -- 1472
	local contextWindow = tonumber(value) -- 1473
	if contextWindow == nil or contextWindow < 64000 then -- 1474
		return 64000 -- 1475
	end -- 1474
	return math.max(64000, math.floor(contextWindow)) -- 1476
end -- 1472
local normalizeTemperature -- 1478
normalizeTemperature = function(value) -- 1478
	local temperature = tonumber(value) -- 1479
	if temperature == nil then -- 1480
		return 0.1 -- 1481
	end -- 1480
	return math.max(0, math.min(2, temperature)) -- 1482
end -- 1478
local normalizeMaxTokens -- 1484
normalizeMaxTokens = function(value) -- 1484
	local maxTokens = tonumber(value) -- 1485
	if maxTokens == nil or maxTokens < 1 then -- 1486
		return 8192 -- 1487
	end -- 1486
	return math.max(1, math.floor(maxTokens)) -- 1488
end -- 1484
local normalizeReasoningEffort -- 1490
normalizeReasoningEffort = function(value) -- 1490
	if value == nil then -- 1491
		return "" -- 1492
	end -- 1491
	local effort = tostring(value) -- 1493
	return effort:match("^%s*(.-)%s*$") or "" -- 1494
end -- 1490
local normalizeCustomOptions -- 1496
normalizeCustomOptions = function(value) -- 1496
	if value == nil then -- 1497
		return "" -- 1498
	end -- 1497
	local options = tostring(value) -- 1499
	options = options:match("^%s*(.-)%s*$") or "" -- 1500
	return options -- 1501
end -- 1496
local validateCustomOptions -- 1503
validateCustomOptions = function(value) -- 1503
	local options = normalizeCustomOptions(value) -- 1504
	if options == "" then -- 1505
		return true -- 1505
	end -- 1505
	if not options:match("^%s*{") then -- 1506
		return false -- 1506
	end -- 1506
	local decoded = json.decode(options) -- 1507
	return type(decoded) == "table" -- 1508
end -- 1503
HttpServer:post("/llm/list", function() -- 1510
	ensureLLMConfigTable() -- 1511
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1512
	local items -- 1516
	if rows and #rows > 0 then -- 1516
		local _accum_0 = { } -- 1517
		local _len_0 = 1 -- 1517
		for _index_0 = 1, #rows do -- 1517
			local _des_0 = rows[_index_0] -- 1517
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1517
			_accum_0[_len_0] = { -- 1518
				id = id, -- 1518
				name = name, -- 1518
				url = url, -- 1518
				model = model, -- 1518
				key = key, -- 1518
				contextWindow = normalizeContextWindow(contextWindow), -- 1518
				temperature = normalizeTemperature(temperature), -- 1518
				maxTokens = normalizeMaxTokens(maxTokens), -- 1518
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1518
				customOptions = normalizeCustomOptions(customOptions), -- 1518
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1518
			} -- 1518
			_len_0 = _len_0 + 1 -- 1518
		end -- 1517
		items = _accum_0 -- 1516
	end -- 1516
	return { -- 1519
		success = true, -- 1519
		items = items -- 1519
	} -- 1519
end) -- 1510
HttpServer:post("/llm/create", function(req) -- 1521
	ensureLLMConfigTable() -- 1522
	do -- 1523
		local _type_0 = type(req) -- 1523
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1523
		if _tab_0 then -- 1523
			local body = req.body -- 1523
			if body ~= nil then -- 1523
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1524
				local now = os.time() -- 1525
				if name == nil or url == nil or model == nil or key == nil then -- 1526
					return invalidArguments -- 1527
				end -- 1526
				contextWindow = normalizeContextWindow(contextWindow) -- 1528
				temperature = normalizeTemperature(temperature) -- 1529
				maxTokens = normalizeMaxTokens(maxTokens) -- 1530
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1531
				customOptions = normalizeCustomOptions(customOptions) -- 1532
				if not validateCustomOptions(customOptions) then -- 1533
					return { -- 1533
						success = false, -- 1533
						message = "customOptions must be a JSON object" -- 1533
					} -- 1533
				end -- 1533
				if supportsFunctionCalling == false then -- 1534
					supportsFunctionCalling = 0 -- 1534
				else -- 1534
					supportsFunctionCalling = 1 -- 1534
				end -- 1534
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1541
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
					1, -- 1551
					now, -- 1552
					now -- 1553
				}) -- 1535
				return { -- 1555
					success = affected >= 0 -- 1555
				} -- 1555
			end -- 1523
		end -- 1523
	end -- 1523
	return invalidArguments -- 1521
end) -- 1521
HttpServer:post("/llm/update", function(req) -- 1557
	ensureLLMConfigTable() -- 1558
	do -- 1559
		local _type_0 = type(req) -- 1559
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1559
		if _tab_0 then -- 1559
			local body = req.body -- 1559
			if body ~= nil then -- 1559
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1560
				local now = os.time() -- 1561
				id = tonumber(id) -- 1562
				if id == nil then -- 1563
					return invalidArguments -- 1563
				end -- 1563
				contextWindow = normalizeContextWindow(contextWindow) -- 1564
				temperature = normalizeTemperature(temperature) -- 1565
				maxTokens = normalizeMaxTokens(maxTokens) -- 1566
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1567
				customOptions = normalizeCustomOptions(customOptions) -- 1568
				if not validateCustomOptions(customOptions) then -- 1569
					return { -- 1569
						success = false, -- 1569
						message = "customOptions must be a JSON object" -- 1569
					} -- 1569
				end -- 1569
				if supportsFunctionCalling == false then -- 1570
					supportsFunctionCalling = 0 -- 1570
				else -- 1570
					supportsFunctionCalling = 1 -- 1570
				end -- 1570
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1575
					tostring(name), -- 1575
					tostring(url), -- 1576
					tostring(model), -- 1577
					tostring(key), -- 1578
					contextWindow, -- 1579
					temperature, -- 1580
					maxTokens, -- 1581
					reasoningEffort, -- 1582
					customOptions, -- 1583
					supportsFunctionCalling, -- 1584
					now, -- 1585
					id -- 1586
				}) -- 1571
				return { -- 1588
					success = affected >= 0 -- 1588
				} -- 1588
			end -- 1559
		end -- 1559
	end -- 1559
	return invalidArguments -- 1557
end) -- 1557
HttpServer:post("/llm/delete", function(req) -- 1590
	ensureLLMConfigTable() -- 1591
	do -- 1592
		local _type_0 = type(req) -- 1592
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1592
		if _tab_0 then -- 1592
			local id -- 1592
			do -- 1592
				local _obj_0 = req.body -- 1592
				local _type_1 = type(_obj_0) -- 1592
				if "table" == _type_1 or "userdata" == _type_1 then -- 1592
					id = _obj_0.id -- 1592
				end -- 1592
			end -- 1592
			if id ~= nil then -- 1592
				id = tonumber(id) -- 1593
				if id == nil then -- 1594
					return invalidArguments -- 1594
				end -- 1594
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1595
					id -- 1595
				}) -- 1595
				return { -- 1596
					success = affected >= 0 -- 1596
				} -- 1596
			end -- 1592
		end -- 1592
	end -- 1592
	return invalidArguments -- 1590
end) -- 1590
HttpServer:post("/stat", function(req) -- 1598
	do -- 1599
		local _type_0 = type(req) -- 1599
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1599
		if _tab_0 then -- 1599
			local path -- 1599
			do -- 1599
				local _obj_0 = req.body -- 1599
				local _type_1 = type(_obj_0) -- 1599
				if "table" == _type_1 or "userdata" == _type_1 then -- 1599
					path = _obj_0.path -- 1599
				end -- 1599
			end -- 1599
			if path ~= nil then -- 1599
				if not Content:exist(path) then -- 1600
					return { -- 1601
						success = false, -- 1601
						message = "target not existed" -- 1601
					} -- 1601
				end -- 1600
				if Content:isdir(path) then -- 1602
					return { -- 1603
						success = false, -- 1603
						message = "failed to stat a directory" -- 1603
					} -- 1603
				end -- 1602
				local size, isBinary = Content:getAttr(path) -- 1604
				if size then -- 1604
					return { -- 1605
						success = true, -- 1605
						size = size, -- 1605
						isBinary = isBinary -- 1605
					} -- 1605
				end -- 1604
			end -- 1599
		end -- 1599
	end -- 1599
	return { -- 1598
		success = false, -- 1598
		message = "failed to stat" -- 1598
	} -- 1598
end) -- 1598
HttpServer:post("/new", function(req) -- 1607
	do -- 1608
		local _type_0 = type(req) -- 1608
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1608
		if _tab_0 then -- 1608
			local path -- 1608
			do -- 1608
				local _obj_0 = req.body -- 1608
				local _type_1 = type(_obj_0) -- 1608
				if "table" == _type_1 or "userdata" == _type_1 then -- 1608
					path = _obj_0.path -- 1608
				end -- 1608
			end -- 1608
			local content -- 1608
			do -- 1608
				local _obj_0 = req.body -- 1608
				local _type_1 = type(_obj_0) -- 1608
				if "table" == _type_1 or "userdata" == _type_1 then -- 1608
					content = _obj_0.content -- 1608
				end -- 1608
			end -- 1608
			local folder -- 1608
			do -- 1608
				local _obj_0 = req.body -- 1608
				local _type_1 = type(_obj_0) -- 1608
				if "table" == _type_1 or "userdata" == _type_1 then -- 1608
					folder = _obj_0.folder -- 1608
				end -- 1608
			end -- 1608
			if path ~= nil and content ~= nil and folder ~= nil then -- 1608
				if Content:exist(path) then -- 1609
					return { -- 1610
						success = false, -- 1610
						message = "TargetExisted" -- 1610
					} -- 1610
				end -- 1609
				local parent = Path:getPath(path) -- 1611
				local files = Content:getFiles(parent) -- 1612
				if folder then -- 1613
					local name = Path:getFilename(path):lower() -- 1614
					for _index_0 = 1, #files do -- 1615
						local file = files[_index_0] -- 1615
						if name == Path:getFilename(file):lower() then -- 1616
							return { -- 1617
								success = false, -- 1617
								message = "TargetExisted" -- 1617
							} -- 1617
						end -- 1616
					end -- 1615
					if Content:mkdir(path) then -- 1618
						return { -- 1619
							success = true -- 1619
						} -- 1619
					end -- 1618
				else -- 1621
					local name = Path:getName(path):lower() -- 1621
					for _index_0 = 1, #files do -- 1622
						local file = files[_index_0] -- 1622
						if name == Path:getName(file):lower() then -- 1623
							local ext = Path:getExt(file) -- 1624
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1625
								goto _continue_0 -- 1626
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1627
								goto _continue_0 -- 1628
							end -- 1625
							return { -- 1629
								success = false, -- 1629
								message = "SourceExisted" -- 1629
							} -- 1629
						end -- 1623
						::_continue_0:: -- 1623
					end -- 1622
					if Content:save(path, content) then -- 1630
						return { -- 1631
							success = true -- 1631
						} -- 1631
					end -- 1630
				end -- 1613
			end -- 1608
		end -- 1608
	end -- 1608
	return { -- 1607
		success = false, -- 1607
		message = "Failed" -- 1607
	} -- 1607
end) -- 1607
local deleteAsset -- 1633
deleteAsset = function(path) -- 1633
	if not Content:exist(path) then -- 1634
		return false -- 1634
	end -- 1634
	local projectRoot -- 1635
	if Content:isdir(path) and isProjectRootDir(path) then -- 1635
		projectRoot = path -- 1635
	else -- 1635
		projectRoot = nil -- 1635
	end -- 1635
	local parent = Path:getPath(path) -- 1636
	local files = Content:getFiles(parent) -- 1637
	local name = Path:getName(path):lower() -- 1638
	local ext = Path:getExt(path) -- 1639
	for _index_0 = 1, #files do -- 1640
		local file = files[_index_0] -- 1640
		if name == Path:getName(file):lower() then -- 1641
			local _exp_0 = Path:getExt(file) -- 1642
			if "tl" == _exp_0 then -- 1642
				if ("vs" == ext) then -- 1642
					Content:remove(Path(parent, file)) -- 1643
				end -- 1642
			elseif "lua" == _exp_0 then -- 1644
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1644
					Content:remove(Path(parent, file)) -- 1645
				end -- 1644
			end -- 1642
		end -- 1641
	end -- 1640
	if Content:remove(path) then -- 1646
		if projectRoot then -- 1647
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1648
		end -- 1647
		return true -- 1649
	end -- 1646
	return false -- 1650
end -- 1633
local moveAsset -- 1652
moveAsset = function(old, new) -- 1652
	if not (Content:exist(old) and not Content:exist(new)) then -- 1653
		return false -- 1653
	end -- 1653
	local renamedDir = Content:isdir(old) -- 1654
	local parent = Path:getPath(new) -- 1655
	local files = Content:getFiles(parent) -- 1656
	if renamedDir then -- 1657
		local name = Path:getFilename(new):lower() -- 1658
		for _index_0 = 1, #files do -- 1659
			local file = files[_index_0] -- 1659
			if name == Path:getFilename(file):lower() then -- 1660
				return false -- 1661
			end -- 1660
		end -- 1659
	else -- 1663
		local name = Path:getName(new):lower() -- 1663
		local ext = Path:getExt(new) -- 1664
		for _index_0 = 1, #files do -- 1665
			local file = files[_index_0] -- 1665
			if name == Path:getName(file):lower() then -- 1666
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1667
					goto _continue_0 -- 1668
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1669
					goto _continue_0 -- 1670
				end -- 1667
				return false -- 1671
			end -- 1666
			::_continue_0:: -- 1666
		end -- 1665
	end -- 1657
	if not Content:move(old, new) then -- 1672
		return false -- 1672
	end -- 1672
	if renamedDir then -- 1673
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1674
	end -- 1673
	local newParent = Path:getPath(new) -- 1675
	parent = Path:getPath(old) -- 1676
	files = Content:getFiles(parent) -- 1677
	local newName = Path:getName(new) -- 1678
	local oldName = Path:getName(old) -- 1679
	local name = oldName:lower() -- 1680
	local ext = Path:getExt(old) -- 1681
	for _index_0 = 1, #files do -- 1682
		local file = files[_index_0] -- 1682
		if name == Path:getName(file):lower() then -- 1683
			local _exp_0 = Path:getExt(file) -- 1684
			if "tl" == _exp_0 then -- 1684
				if ("vs" == ext) then -- 1684
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1685
				end -- 1684
			elseif "lua" == _exp_0 then -- 1686
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1686
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1687
				end -- 1686
			end -- 1684
		end -- 1683
	end -- 1682
	return true -- 1688
end -- 1652
HttpServer:post("/delete", function(req) -- 1690
	do -- 1691
		local _type_0 = type(req) -- 1691
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1691
		if _tab_0 then -- 1691
			local path -- 1691
			do -- 1691
				local _obj_0 = req.body -- 1691
				local _type_1 = type(_obj_0) -- 1691
				if "table" == _type_1 or "userdata" == _type_1 then -- 1691
					path = _obj_0.path -- 1691
				end -- 1691
			end -- 1691
			if path ~= nil then -- 1691
				if deleteAsset(path) then -- 1692
					return { -- 1692
						success = true -- 1692
					} -- 1692
				end -- 1692
			end -- 1691
		end -- 1691
	end -- 1691
	return { -- 1690
		success = false -- 1690
	} -- 1690
end) -- 1690
HttpServer:post("/rename", function(req) -- 1694
	do -- 1695
		local _type_0 = type(req) -- 1695
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1695
		if _tab_0 then -- 1695
			local old -- 1695
			do -- 1695
				local _obj_0 = req.body -- 1695
				local _type_1 = type(_obj_0) -- 1695
				if "table" == _type_1 or "userdata" == _type_1 then -- 1695
					old = _obj_0.old -- 1695
				end -- 1695
			end -- 1695
			local new -- 1695
			do -- 1695
				local _obj_0 = req.body -- 1695
				local _type_1 = type(_obj_0) -- 1695
				if "table" == _type_1 or "userdata" == _type_1 then -- 1695
					new = _obj_0.new -- 1695
				end -- 1695
			end -- 1695
			if old ~= nil and new ~= nil then -- 1695
				if moveAsset(old, new) then -- 1696
					return { -- 1696
						success = true -- 1696
					} -- 1696
				end -- 1696
			end -- 1695
		end -- 1695
	end -- 1695
	return { -- 1694
		success = false -- 1694
	} -- 1694
end) -- 1694
local normalizeAssetPaths -- 1698
normalizeAssetPaths = function(paths) -- 1698
	if not (type(paths) == "table") then -- 1699
		return nil -- 1699
	end -- 1699
	local unique = { } -- 1700
	local candidates = { } -- 1701
	for _index_0 = 1, #paths do -- 1702
		local path = paths[_index_0] -- 1702
		if not (type(path) == "string") then -- 1703
			return nil -- 1703
		end -- 1703
		local relative = relativeToRoot(path, Content.writablePath) -- 1704
		if relative == nil or relative == "" or not Content:exist(path) then -- 1705
			return nil -- 1705
		end -- 1705
		if not unique[path] then -- 1706
			unique[path] = true -- 1707
			candidates[#candidates + 1] = path -- 1708
		end -- 1706
	end -- 1702
	table.sort(candidates, function(a, b) -- 1709
		return #a < #b -- 1709
	end) -- 1709
	local result = { } -- 1710
	for _index_0 = 1, #candidates do -- 1711
		local path = candidates[_index_0] -- 1711
		local contained = false -- 1712
		for _index_1 = 1, #result do -- 1713
			local parent = result[_index_1] -- 1713
			if relativeToRoot(path, parent) ~= nil then -- 1714
				contained = true -- 1715
				break -- 1716
			end -- 1714
		end -- 1713
		if not contained then -- 1717
			result[#result + 1] = path -- 1717
		end -- 1717
	end -- 1711
	return result -- 1718
end -- 1698
HttpServer:postSchedule("/assets/batch", function(req) -- 1720
	do -- 1721
		local _type_0 = type(req) -- 1721
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1721
		if _tab_0 then -- 1721
			local operation -- 1721
			do -- 1721
				local _obj_0 = req.body -- 1721
				local _type_1 = type(_obj_0) -- 1721
				if "table" == _type_1 or "userdata" == _type_1 then -- 1721
					operation = _obj_0.operation -- 1721
				end -- 1721
			end -- 1721
			local sources -- 1721
			do -- 1721
				local _obj_0 = req.body -- 1721
				local _type_1 = type(_obj_0) -- 1721
				if "table" == _type_1 or "userdata" == _type_1 then -- 1721
					sources = _obj_0.sources -- 1721
				end -- 1721
			end -- 1721
			if operation ~= nil and sources ~= nil then -- 1721
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1722
					return { -- 1722
						success = false, -- 1722
						message = "invalid operation" -- 1722
					} -- 1722
				end -- 1722
				sources = normalizeAssetPaths(sources) -- 1723
				if not (sources and #sources > 0) then -- 1724
					return { -- 1724
						success = false, -- 1724
						message = "invalid sources" -- 1724
					} -- 1724
				end -- 1724
				local target = req.body.target -- 1725
				local destinations = { } -- 1726
				if operation ~= "delete" then -- 1727
					if not (type(target) == "string") then -- 1728
						return { -- 1728
							success = false, -- 1728
							message = "invalid target" -- 1728
						} -- 1728
					end -- 1728
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1729
					if targetRelative == nil then -- 1730
						return { -- 1730
							success = false, -- 1730
							message = "invalid target" -- 1730
						} -- 1730
					end -- 1730
					if not (Content:exist(target) and Content:isdir(target)) then -- 1731
						return { -- 1731
							success = false, -- 1731
							message = "invalid target" -- 1731
						} -- 1731
					end -- 1731
					for _index_0 = 1, #sources do -- 1732
						local source = sources[_index_0] -- 1732
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1733
							return { -- 1734
								success = false, -- 1734
								message = "target inside source" -- 1734
							} -- 1734
						end -- 1733
						local destination = Path(target, Path:getFilename(source)) -- 1735
						if Content:exist(destination) then -- 1736
							return { -- 1736
								success = false, -- 1736
								message = "target existed" -- 1736
							} -- 1736
						end -- 1736
						if destinations[destination] then -- 1737
							return { -- 1737
								success = false, -- 1737
								message = "duplicate target" -- 1737
							} -- 1737
						end -- 1737
						destinations[destination] = true -- 1738
					end -- 1732
				end -- 1727
				local changes = { } -- 1739
				local affectedSet = { } -- 1740
				local affectedDirectories = { } -- 1741
				local addAffected -- 1742
				addAffected = function(dir) -- 1742
					if affectedSet[dir] then -- 1743
						return -- 1743
					end -- 1743
					affectedSet[dir] = true -- 1744
					affectedDirectories[#affectedDirectories + 1] = dir -- 1745
				end -- 1742
				if operation ~= "delete" then -- 1746
					addAffected(target) -- 1746
				end -- 1746
				for _index_0 = 1, #sources do -- 1747
					local source = sources[_index_0] -- 1747
					addAffected(Path:getPath(source)) -- 1748
					if operation == "delete" then -- 1749
						if not deleteAsset(source) then -- 1750
							return { -- 1750
								success = false, -- 1750
								message = "delete failed", -- 1750
								changes = changes, -- 1750
								affectedDirectories = affectedDirectories -- 1750
							} -- 1750
						end -- 1750
						changes[#changes + 1] = { -- 1751
							old = source -- 1751
						} -- 1751
					else -- 1753
						local destination = Path(target, Path:getFilename(source)) -- 1753
						local ok -- 1754
						if operation == "copy" then -- 1754
							ok = Content:copyAsync(source, destination) -- 1755
						else -- 1757
							ok = moveAsset(source, destination) -- 1757
						end -- 1754
						if not ok then -- 1758
							return { -- 1758
								success = false, -- 1758
								message = operation .. " failed", -- 1758
								changes = changes, -- 1758
								affectedDirectories = affectedDirectories -- 1758
							} -- 1758
						end -- 1758
						changes[#changes + 1] = { -- 1759
							old = source, -- 1759
							new = destination -- 1759
						} -- 1759
					end -- 1749
				end -- 1747
				return { -- 1760
					success = true, -- 1760
					changes = changes, -- 1760
					affectedDirectories = affectedDirectories -- 1760
				} -- 1760
			end -- 1721
		end -- 1721
	end -- 1721
	return { -- 1720
		success = false, -- 1720
		message = "invalid request" -- 1720
	} -- 1720
end) -- 1720
local withProjectSearchPaths -- 1762
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1762
	local fallbackPaths = { } -- 1763
	local addFallback -- 1764
	addFallback = function(dir) -- 1764
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1764
			fallbackPaths[#fallbackPaths + 1] = dir -- 1764
		end -- 1764
	end -- 1764
	if projectRoot and projectRoot ~= "" then -- 1765
		addFallback(Path(projectRoot, "Script")) -- 1766
		addFallback(projectRoot) -- 1767
	end -- 1765
	if projFile then -- 1768
		local projDir = getProjectDirFromFile(projFile) -- 1769
		if projDir then -- 1769
			addFallback(Path(projDir, "Script")) -- 1770
			addFallback(projDir) -- 1771
		else -- 1773
			addFallback(Path:getPath(projFile)) -- 1773
		end -- 1769
	end -- 1768
	if not (#fallbackPaths > 0) then -- 1774
		return fn() -- 1774
	end -- 1774
	local searchPaths = Content.searchPaths -- 1775
	for _index_0 = 1, #fallbackPaths do -- 1776
		local dir = fallbackPaths[_index_0] -- 1776
		Content:addSearchPath(dir) -- 1776
	end -- 1776
	local _ <close> = setmetatable({ }, { -- 1777
		__close = function() -- 1777
			Content.searchPaths = searchPaths -- 1777
		end -- 1777
	}) -- 1777
	return fn() -- 1778
end -- 1762
HttpServer:post("/exist", function(req) -- 1779
	do -- 1780
		local _type_0 = type(req) -- 1780
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1780
		if _tab_0 then -- 1780
			local file -- 1780
			do -- 1780
				local _obj_0 = req.body -- 1780
				local _type_1 = type(_obj_0) -- 1780
				if "table" == _type_1 or "userdata" == _type_1 then -- 1780
					file = _obj_0.file -- 1780
				end -- 1780
			end -- 1780
			if file ~= nil then -- 1780
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1781
					return { -- 1782
						success = Content:exist(file) -- 1782
					} -- 1782
				end) -- 1781
			end -- 1780
		end -- 1780
	end -- 1780
	return { -- 1779
		success = false -- 1779
	} -- 1779
end) -- 1779
HttpServer:postSchedule("/read", function(req) -- 1783
	do -- 1784
		local _type_0 = type(req) -- 1784
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1784
		if _tab_0 then -- 1784
			local path -- 1784
			do -- 1784
				local _obj_0 = req.body -- 1784
				local _type_1 = type(_obj_0) -- 1784
				if "table" == _type_1 or "userdata" == _type_1 then -- 1784
					path = _obj_0.path -- 1784
				end -- 1784
			end -- 1784
			if path ~= nil then -- 1784
				local readFile -- 1785
				readFile = function() -- 1785
					if Content:exist(path) then -- 1786
						local content = Content:loadAsync(path) -- 1787
						if content then -- 1787
							return { -- 1788
								content = content, -- 1788
								success = true, -- 1788
								fullPath = Content:getFullPath(path) -- 1788
							} -- 1788
						end -- 1787
					end -- 1786
					return nil -- 1785
				end -- 1785
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1789
				if result then -- 1789
					return result -- 1789
				end -- 1789
			end -- 1784
		end -- 1784
	end -- 1784
	return { -- 1783
		success = false -- 1783
	} -- 1783
end) -- 1783
local agentDocLanguage -- 1791
agentDocLanguage = function(language) -- 1791
	if language == "zh-Hans" then -- 1792
		return "zh" -- 1792
	else -- 1792
		return "en" -- 1792
	end -- 1792
end -- 1791
HttpServer:postSchedule("/doc/search", function(req) -- 1794
	local body = req.body or { } -- 1795
	local language = body.docLanguage -- 1796
	if not (("en" == language or "zh-Hans" == language)) then -- 1797
		return { -- 1797
			success = false, -- 1797
			message = "unsupported doc language" -- 1797
		} -- 1797
	end -- 1797
	local docType = body.docType -- 1798
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1799
		return { -- 1799
			success = false, -- 1799
			message = "unsupported doc type" -- 1799
		} -- 1799
	end -- 1799
	local codeLanguage = body.programmingLanguage -- 1800
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1801
		return { -- 1801
			success = false, -- 1801
			message = "unsupported programming language" -- 1801
		} -- 1801
	end -- 1801
	if not body.pattern then -- 1802
		return { -- 1802
			success = false, -- 1802
			message = "missing pattern" -- 1802
		} -- 1802
	end -- 1802
	local result = nil -- 1803
	AgentTools.searchDoraDocHttp({ -- 1805
		pattern = body.pattern, -- 1805
		docLanguage = agentDocLanguage(language), -- 1806
		docType = docType, -- 1807
		programmingLanguage = codeLanguage, -- 1808
		limit = body.limit, -- 1809
		useRegex = body.useRegex, -- 1810
		caseSensitive = body.caseSensitive, -- 1811
		includeContent = body.includeContent, -- 1812
		contentWindow = body.contentWindow -- 1813
	}, function(res) -- 1814
		result = res -- 1815
	end) -- 1804
	wait(function() -- 1816
		return result ~= nil -- 1816
	end) -- 1816
	if result and result.success then -- 1817
		result.docLanguage = language -- 1818
	end -- 1817
	if result then -- 1819
		return result -- 1820
	else -- 1822
		return { -- 1822
			success = false, -- 1822
			message = "doc search failed" -- 1822
		} -- 1822
	end -- 1819
	return { -- 1794
		success = false, -- 1794
		message = "invalid call" -- 1794
	} -- 1794
end) -- 1794
HttpServer:postSchedule("/doc/read", function(req) -- 1824
	local body = req.body or { } -- 1825
	local language = body.docLanguage -- 1826
	if not (("en" == language or "zh-Hans" == language)) then -- 1827
		return { -- 1827
			success = false, -- 1827
			message = "unsupported doc language" -- 1827
		} -- 1827
	end -- 1827
	if not body.file then -- 1828
		return { -- 1828
			success = false, -- 1828
			message = "missing file" -- 1828
		} -- 1828
	end -- 1828
	local result = AgentTools.readDoraDoc({ -- 1830
		docLanguage = agentDocLanguage(language), -- 1830
		file = body.file, -- 1831
		startLine = body.startLine, -- 1832
		endLine = body.endLine -- 1833
	}) -- 1829
	if result and result.success then -- 1834
		result.docLanguage = language -- 1835
	end -- 1834
	return result -- 1836
end) -- 1824
HttpServer:get("/read-sync", function(req) -- 1838
	do -- 1839
		local _type_0 = type(req) -- 1839
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1839
		if _tab_0 then -- 1839
			local params = req.params -- 1839
			if params ~= nil then -- 1839
				local path = params.path -- 1840
				local exts -- 1841
				if params.exts then -- 1841
					local _accum_0 = { } -- 1842
					local _len_0 = 1 -- 1842
					for ext in params.exts:gmatch("[^|]*") do -- 1842
						_accum_0[_len_0] = ext -- 1842
						_len_0 = _len_0 + 1 -- 1842
					end -- 1842
					exts = _accum_0 -- 1842
				else -- 1843
					exts = { -- 1843
						"" -- 1843
					} -- 1843
				end -- 1841
				local readFileAt -- 1844
				readFileAt = function(targetPath) -- 1844
					if Content:exist(targetPath) then -- 1845
						local content = Content:load(targetPath) -- 1846
						if content then -- 1846
							return { -- 1847
								content = content, -- 1847
								success = true, -- 1847
								fullPath = Content:getFullPath(targetPath) -- 1847
							} -- 1847
						end -- 1846
					end -- 1845
					return nil -- 1844
				end -- 1844
				local readFile -- 1848
				readFile = function(fallbackPaths) -- 1848
					for _index_0 = 1, #exts do -- 1849
						local ext = exts[_index_0] -- 1849
						local targetPath = path .. ext -- 1850
						if not Content:isAbsolutePath(targetPath) then -- 1851
							for _index_1 = 1, #fallbackPaths do -- 1852
								local fallback = fallbackPaths[_index_1] -- 1852
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1853
								if fallbackResult then -- 1853
									return fallbackResult -- 1854
								end -- 1853
							end -- 1852
						end -- 1851
						local fileResult = readFileAt(targetPath) -- 1855
						if fileResult then -- 1855
							return fileResult -- 1856
						end -- 1855
					end -- 1849
					return nil -- 1848
				end -- 1848
				local fallbackPaths = { } -- 1857
				local fallbackCandidates = { } -- 1858
				do -- 1859
					local projectRoot = req.params.projectRoot -- 1859
					if projectRoot then -- 1859
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1860
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1861
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1862
						end -- 1860
					end -- 1859
				end -- 1859
				do -- 1863
					local projFile = req.params.projFile -- 1863
					if projFile then -- 1863
						local projDir = getProjectDirFromFile(projFile) -- 1864
						if projDir then -- 1864
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1865
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1866
						else -- 1868
							projDir = Path:getPath(projFile) -- 1868
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1869
						end -- 1864
					end -- 1863
				end -- 1863
				for _index_0 = 1, #fallbackCandidates do -- 1870
					local dir = fallbackCandidates[_index_0] -- 1870
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1871
						local exists = false -- 1872
						for _index_1 = 1, #fallbackPaths do -- 1873
							local fallback = fallbackPaths[_index_1] -- 1873
							if fallback == dir then -- 1874
								exists = true -- 1875
								break -- 1876
							end -- 1874
						end -- 1873
						if not exists then -- 1877
							fallbackPaths[#fallbackPaths + 1] = dir -- 1877
						end -- 1877
					end -- 1871
				end -- 1870
				local readResult = readFile(fallbackPaths) -- 1878
				if readResult then -- 1878
					return readResult -- 1879
				end -- 1878
			end -- 1839
		end -- 1839
	end -- 1839
	return { -- 1838
		success = false -- 1838
	} -- 1838
end) -- 1838
local addGeneratedSourceHeader -- 1881
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 1881
	if preserveTIC80 == nil then -- 1881
		preserveTIC80 = false -- 1881
	end -- 1881
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 1882
	if preserveTIC80 then -- 1883
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 1884
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 1885
		end -- 1884
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 1886
	end -- 1883
	return tostring(header) .. "\n" .. tostring(codes) -- 1887
end -- 1881
local compileFileAsync -- 1889
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1889
	if projectRoot == nil then -- 1889
		projectRoot = nil -- 1889
	end -- 1889
	local file = inputFile -- 1890
	local searchPath -- 1891
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1891
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1892
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1896
	elseif not Content:isAbsolutePath(inputFile) then -- 1897
		searchPath = "" -- 1898
	else -- 1899
		local dir = getProjectDirFromFile(inputFile) -- 1899
		if dir then -- 1899
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1900
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1904
		else -- 1906
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1906
			searchPath = "" -- 1909
		end -- 1899
	end -- 1891
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1910
	local yueext = yue.options.extension -- 1911
	local resultCodes = nil -- 1912
	local resultError = nil -- 1913
	do -- 1914
		local _exp_0 = Path:getExt(inputFile) -- 1914
		if yueext == _exp_0 then -- 1914
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1915
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1916
				if not codes then -- 1917
					resultError = err -- 1918
					return -- 1919
				end -- 1917
				local extraGlobal -- 1920
				if isTIC80 then -- 1920
					extraGlobal = tic80APIs -- 1920
				else -- 1920
					extraGlobal = nil -- 1920
				end -- 1920
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1921
				if not success then -- 1922
					resultError = message -- 1923
					return -- 1924
				end -- 1922
				if codes == "" then -- 1925
					resultCodes = "" -- 1926
					return nil -- 1927
				end -- 1925
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 1928
				return resultCodes -- 1929
			end, function(success) -- 1916
				if not success then -- 1930
					Content:remove(outputFile) -- 1931
					if resultCodes == nil then -- 1932
						resultCodes = false -- 1933
					end -- 1932
				end -- 1930
			end) -- 1916
		elseif "tl" == _exp_0 then -- 1934
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1935
			if isTIC80 then -- 1936
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1937
			end -- 1936
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1938
			if codes then -- 1938
				if isTIC80 then -- 1939
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1940
				end -- 1939
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 1941
				Content:saveAsync(outputFile, resultCodes) -- 1942
			else -- 1944
				Content:remove(outputFile) -- 1944
				resultCodes = false -- 1945
				resultError = err -- 1946
			end -- 1938
		elseif "xml" == _exp_0 then -- 1947
			local codes, err = xml.tolua(sourceCodes) -- 1948
			if codes then -- 1948
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1949
				Content:saveAsync(outputFile, resultCodes) -- 1950
			else -- 1952
				Content:remove(outputFile) -- 1952
				resultCodes = false -- 1953
				resultError = err -- 1954
			end -- 1948
		end -- 1914
	end -- 1914
	wait(function() -- 1955
		return resultCodes ~= nil -- 1955
	end) -- 1955
	if resultCodes then -- 1956
		return resultCodes -- 1957
	else -- 1959
		return nil, resultError -- 1959
	end -- 1956
	return nil -- 1889
end -- 1889
HttpServer:postSchedule("/write", function(req) -- 1961
	do -- 1962
		local _type_0 = type(req) -- 1962
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1962
		if _tab_0 then -- 1962
			local path -- 1962
			do -- 1962
				local _obj_0 = req.body -- 1962
				local _type_1 = type(_obj_0) -- 1962
				if "table" == _type_1 or "userdata" == _type_1 then -- 1962
					path = _obj_0.path -- 1962
				end -- 1962
			end -- 1962
			local content -- 1962
			do -- 1962
				local _obj_0 = req.body -- 1962
				local _type_1 = type(_obj_0) -- 1962
				if "table" == _type_1 or "userdata" == _type_1 then -- 1962
					content = _obj_0.content -- 1962
				end -- 1962
			end -- 1962
			if path ~= nil and content ~= nil then -- 1962
				if Content:saveAsync(path, content) then -- 1963
					do -- 1964
						local _exp_0 = Path:getExt(path) -- 1964
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1964
							if '' == Path:getExt(Path:getName(path)) then -- 1965
								local resultCodes = compileFileAsync(path, content) -- 1966
								return { -- 1967
									success = true, -- 1967
									resultCodes = resultCodes -- 1967
								} -- 1967
							end -- 1965
						end -- 1964
					end -- 1964
					return { -- 1968
						success = true -- 1968
					} -- 1968
				end -- 1963
			end -- 1962
		end -- 1962
	end -- 1962
	return { -- 1961
		success = false -- 1961
	} -- 1961
end) -- 1961
local getWaProjectDirFromFile = nil -- 1970
HttpServer:postSchedule("/build", function(req) -- 1972
	do -- 1973
		local _type_0 = type(req) -- 1973
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1973
		if _tab_0 then -- 1973
			local path -- 1973
			do -- 1973
				local _obj_0 = req.body -- 1973
				local _type_1 = type(_obj_0) -- 1973
				if "table" == _type_1 or "userdata" == _type_1 then -- 1973
					path = _obj_0.path -- 1973
				end -- 1973
			end -- 1973
			if path ~= nil then -- 1973
				local projectRoot = req.body.projectRoot -- 1974
				if Content:isdir(path) then -- 1975
					local projDir = getWaProjectDirFromFile(path) -- 1976
					if projDir then -- 1976
						local message = Wasm:buildWaAsync(projDir) -- 1977
						if message == "" then -- 1978
							return { -- 1979
								success = true -- 1979
							} -- 1979
						else -- 1981
							return { -- 1981
								success = false, -- 1981
								message = message -- 1981
							} -- 1981
						end -- 1978
					end -- 1976
				end -- 1975
				local _exp_0 = Path:getExt(path) -- 1982
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1983
					if '' == Path:getExt(Path:getName(path)) then -- 1984
						local content = Content:loadAsync(path) -- 1985
						if content then -- 1985
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 1986
							if resultCodes then -- 1986
								return { -- 1987
									success = true, -- 1987
									resultCodes = resultCodes -- 1987
								} -- 1987
							end -- 1986
						end -- 1985
					end -- 1984
				elseif "wa" == _exp_0 then -- 1988
					local projDir = getWaProjectDirFromFile(path) -- 1989
					if projDir then -- 1989
						local message = Wasm:buildWaAsync(projDir) -- 1990
						if message == "" then -- 1991
							return { -- 1992
								success = true -- 1992
							} -- 1992
						else -- 1994
							return { -- 1994
								success = false, -- 1994
								message = message -- 1994
							} -- 1994
						end -- 1991
					else -- 1996
						return { -- 1996
							success = false, -- 1996
							message = 'Wa file needs a project' -- 1996
						} -- 1996
					end -- 1989
				end -- 1982
			end -- 1973
		end -- 1973
	end -- 1973
	return { -- 1972
		success = false -- 1972
	} -- 1972
end) -- 1972
local extentionLevels = { -- 1999
	vs = 2, -- 1999
	bl = 2, -- 2000
	ts = 1, -- 2001
	tsx = 1, -- 2002
	tl = 1, -- 2003
	yue = 1, -- 2004
	xml = 1, -- 2005
	lua = 0 -- 2006
} -- 1998
local visitAssets -- 2008
visitAssets = function(path, workspace, builtin, recursive) -- 2008
	if recursive == nil then -- 2008
		recursive = true -- 2008
	end -- 2008
	local children = nil -- 2009
	local dirs = Content:getDirs(path) -- 2010
	for _index_0 = 1, #dirs do -- 2011
		local dir = dirs[_index_0] -- 2011
		if workspace then -- 2012
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 2013
				goto _continue_0 -- 2014
			end -- 2013
		elseif dir == ".git" then -- 2015
			goto _continue_0 -- 2016
		end -- 2012
		if not children then -- 2017
			children = { } -- 2017
		end -- 2017
		local dirPath = Path(path, dir) -- 2018
		if recursive then -- 2019
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2020
		else -- 2022
			children[#children + 1] = { -- 2023
				key = dirPath, -- 2023
				dir = true, -- 2024
				title = dir, -- 2025
				builtin = builtin, -- 2026
				isLeaf = false -- 2027
			} -- 2022
		end -- 2019
		::_continue_0:: -- 2012
	end -- 2011
	local files = Content:getFiles(path) -- 2029
	local names = { } -- 2030
	for _index_0 = 1, #files do -- 2031
		local file = files[_index_0] -- 2031
		if (".DS_Store" == file) then -- 2032
			goto _continue_1 -- 2033
		end -- 2032
		local name = Path:getName(file) -- 2034
		local ext = names[name] -- 2035
		if ext then -- 2035
			local lv1 -- 2036
			do -- 2036
				local _exp_0 = extentionLevels[ext] -- 2036
				if _exp_0 ~= nil then -- 2036
					lv1 = _exp_0 -- 2036
				else -- 2036
					lv1 = -1 -- 2036
				end -- 2036
			end -- 2036
			ext = Path:getExt(file) -- 2037
			local lv2 -- 2038
			do -- 2038
				local _exp_0 = extentionLevels[ext] -- 2038
				if _exp_0 ~= nil then -- 2038
					lv2 = _exp_0 -- 2038
				else -- 2038
					lv2 = -1 -- 2038
				end -- 2038
			end -- 2038
			if lv2 > lv1 then -- 2039
				names[name] = ext -- 2040
			elseif lv2 == lv1 then -- 2041
				names[name .. '.' .. ext] = "" -- 2042
			end -- 2039
		else -- 2044
			ext = Path:getExt(file) -- 2044
			if not extentionLevels[ext] then -- 2045
				names[file] = "" -- 2046
			else -- 2048
				names[name] = ext -- 2048
			end -- 2045
		end -- 2035
		::_continue_1:: -- 2032
	end -- 2031
	do -- 2049
		local _accum_0 = { } -- 2049
		local _len_0 = 1 -- 2049
		for name, ext in pairs(names) do -- 2049
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2049
			_len_0 = _len_0 + 1 -- 2049
		end -- 2049
		files = _accum_0 -- 2049
	end -- 2049
	for _index_0 = 1, #files do -- 2050
		local file = files[_index_0] -- 2050
		if not children then -- 2051
			children = { } -- 2051
		end -- 2051
		children[#children + 1] = { -- 2053
			key = Path(path, file), -- 2053
			dir = false, -- 2054
			title = file, -- 2055
			builtin = builtin -- 2056
		} -- 2052
	end -- 2050
	if children then -- 2058
		table.sort(children, function(a, b) -- 2059
			if a.dir == b.dir then -- 2060
				return a.title < b.title -- 2061
			else -- 2063
				return a.dir -- 2063
			end -- 2060
		end) -- 2059
	end -- 2058
	return { -- 2065
		key = path, -- 2065
		dir = true, -- 2066
		title = Path:getFilename(path), -- 2067
		builtin = builtin, -- 2068
		isLeaf = not children, -- 2069
		children = children -- 2070
	} -- 2064
end -- 2008
HttpServer:post("/assets/children", function(req) -- 2073
	do -- 2074
		local _type_0 = type(req) -- 2074
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2074
		if _tab_0 then -- 2074
			local path -- 2074
			do -- 2074
				local _obj_0 = req.body -- 2074
				local _type_1 = type(_obj_0) -- 2074
				if "table" == _type_1 or "userdata" == _type_1 then -- 2074
					path = _obj_0.path -- 2074
				end -- 2074
			end -- 2074
			if path ~= nil then -- 2074
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2075
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2076
					return { -- 2076
						success = false -- 2076
					} -- 2076
				end -- 2076
				local node = visitAssets(path, workspace, builtin, false) -- 2077
				return { -- 2078
					success = true, -- 2078
					children = node.children or { } -- 2078
				} -- 2078
			end -- 2074
		end -- 2074
	end -- 2074
	return { -- 2073
		success = false -- 2073
	} -- 2073
end) -- 2073
HttpServer:post("/assets/files", function(req) -- 2080
	do -- 2081
		local _type_0 = type(req) -- 2081
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2081
		if _tab_0 then -- 2081
			local path -- 2081
			do -- 2081
				local _obj_0 = req.body -- 2081
				local _type_1 = type(_obj_0) -- 2081
				if "table" == _type_1 or "userdata" == _type_1 then -- 2081
					path = _obj_0.path -- 2081
				end -- 2081
			end -- 2081
			if path ~= nil then -- 2081
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2082
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2083
				if not (workspace or builtin) then -- 2084
					return { -- 2084
						success = false -- 2084
					} -- 2084
				end -- 2084
				if not (Content:exist(path) and Content:isdir(path)) then -- 2085
					return { -- 2085
						success = false -- 2085
					} -- 2085
				end -- 2085
				local globs = { -- 2086
					"**", -- 2086
					"!**/.DS_Store" -- 2086
				} -- 2086
				if workspace then -- 2087
					globs = { -- 2089
						"**", -- 2089
						"!**/.DS_Store", -- 2089
						"!**/.upload/**", -- 2090
						"!**/.download/**", -- 2090
						"!**/.www/**", -- 2091
						"!**/.build/**", -- 2091
						"!**/.git/**", -- 2092
						"!**/.cache/**", -- 2092
						"!**/node_modules/**" -- 2093
					} -- 2088
				end -- 2087
				local files -- 2095
				do -- 2095
					local _accum_0 = { } -- 2095
					local _len_0 = 1 -- 2095
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2095
					for _index_0 = 1, #_list_0 do -- 2095
						local file = _list_0[_index_0] -- 2095
						_accum_0[_len_0] = Path(path, file) -- 2095
						_len_0 = _len_0 + 1 -- 2095
					end -- 2095
					files = _accum_0 -- 2095
				end -- 2095
				return { -- 2096
					success = true, -- 2096
					files = files -- 2096
				} -- 2096
			end -- 2081
		end -- 2081
	end -- 2081
	return { -- 2080
		success = false -- 2080
	} -- 2080
end) -- 2080
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2137
	local _tab_0 = { -- 2137
		{ -- 2138
			key = Path(Content.assetPath), -- 2138
			dir = true, -- 2139
			builtin = true, -- 2140
			title = zh and "内置资源" or "Built-in", -- 2141
			children = builtinChildren -- 2142
		} -- 2137
	} -- 2144
	local _obj_0 = workspace.children or { } -- 2144
	local _idx_0 = #_tab_0 + 1 -- 2144
	for _index_0 = 1, #_obj_0 do -- 2144
		local _value_0 = _obj_0[_index_0] -- 2144
		_tab_0[_idx_0] = _value_0 -- 2144
		_idx_0 = _idx_0 + 1 -- 2144
	end -- 2144
	return _tab_0 -- 2137
end -- 2137
HttpServer:post("/assets", function() -- 2098
	local Entry = require("Script.Dev.Entry") -- 2099
	local engineDev = Entry.getEngineDev() -- 2100
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2101
	local zh = (App.locale:match("^zh") ~= nil) -- 2102
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2103
	readme.title = zh and "说明文档" or "Readme" -- 2104
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2105
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2106
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2107
	tools.title = zh and "开发工具" or "Tools" -- 2108
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2109
	font.title = zh and "字体" or "Font" -- 2110
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2111
	lib.title = zh and "程序库" or "Lib" -- 2112
	if engineDev then -- 2113
		local _list_0 = lib.children -- 2114
		for _index_0 = 1, #_list_0 do -- 2114
			local child = _list_0[_index_0] -- 2114
			if not (child.title == "Dora") then -- 2115
				goto _continue_0 -- 2115
			end -- 2115
			local title = zh and "zh-Hans" or "en" -- 2116
			do -- 2117
				local _accum_0 = { } -- 2117
				local _len_0 = 1 -- 2117
				local _list_1 = child.children -- 2117
				for _index_1 = 1, #_list_1 do -- 2117
					local c = _list_1[_index_1] -- 2117
					if c.title ~= title then -- 2117
						_accum_0[_len_0] = c -- 2117
						_len_0 = _len_0 + 1 -- 2117
					end -- 2117
				end -- 2117
				child.children = _accum_0 -- 2117
			end -- 2117
			break -- 2118
			::_continue_0:: -- 2115
		end -- 2114
	else -- 2120
		local _accum_0 = { } -- 2120
		local _len_0 = 1 -- 2120
		local _list_0 = lib.children -- 2120
		for _index_0 = 1, #_list_0 do -- 2120
			local child = _list_0[_index_0] -- 2120
			if child.title ~= "Dora" then -- 2120
				_accum_0[_len_0] = child -- 2120
				_len_0 = _len_0 + 1 -- 2120
			end -- 2120
		end -- 2120
		lib.children = _accum_0 -- 2120
	end -- 2113
	local builtinChildren = { -- 2121
		readme, -- 2121
		apiDoc, -- 2121
		tools, -- 2121
		font, -- 2121
		lib -- 2121
	} -- 2121
	if engineDev then -- 2122
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2123
		do -- 2124
			local _obj_0 = dev.children -- 2124
			_obj_0[#_obj_0 + 1] = { -- 2125
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2125
				dir = false, -- 2126
				builtin = true, -- 2127
				title = "init.yue" -- 2128
			} -- 2124
		end -- 2124
		builtinChildren[#builtinChildren + 1] = dev -- 2130
	end -- 2122
	return { -- 2132
		key = Content.writablePath, -- 2132
		dir = true, -- 2133
		root = true, -- 2134
		title = "Assets", -- 2135
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2136
	} -- 2131
end) -- 2098
HttpServer:post("/entry/list", function(req) -- 2148
	local Entry = require("Script.Dev.Entry") -- 2149
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2150
	res.success = true -- 2151
	return res -- 2152
end) -- 2148
HttpServer:post("/run/status", function() -- 2154
	local Entry = require("Script.Dev.Entry") -- 2155
	return Entry.getCurrentEntryStatus() -- 2156
end) -- 2154
HttpServer:postSchedule("/run", function(req) -- 2158
	do -- 2159
		local _type_0 = type(req) -- 2159
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2159
		if _tab_0 then -- 2159
			local file -- 2159
			do -- 2159
				local _obj_0 = req.body -- 2159
				local _type_1 = type(_obj_0) -- 2159
				if "table" == _type_1 or "userdata" == _type_1 then -- 2159
					file = _obj_0.file -- 2159
				end -- 2159
			end -- 2159
			local asProj -- 2159
			do -- 2159
				local _obj_0 = req.body -- 2159
				local _type_1 = type(_obj_0) -- 2159
				if "table" == _type_1 or "userdata" == _type_1 then -- 2159
					asProj = _obj_0.asProj -- 2159
				end -- 2159
			end -- 2159
			if file ~= nil and asProj ~= nil then -- 2159
				if not Content:isAbsolutePath(file) then -- 2160
					local devFile = Path(Content.writablePath, file) -- 2161
					if Content:exist(devFile) then -- 2162
						file = devFile -- 2162
					end -- 2162
				end -- 2160
				local Entry = require("Script.Dev.Entry") -- 2163
				local workDir -- 2164
				if asProj then -- 2165
					local projectRoot = req.body.projectRoot -- 2166
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2167
						workDir = projectRoot -- 2168
					else -- 2170
						workDir = getProjectDirFromFile(file) -- 2170
					end -- 2167
					if workDir then -- 2171
						Entry.allClear() -- 2172
						local target = Path(workDir, "init") -- 2173
						local success, err = Entry.enterEntryAsync({ -- 2174
							entryName = "Project", -- 2174
							fileName = target, -- 2174
							workDir = workDir, -- 2174
							projectRoot = workDir, -- 2174
							runKind = "project" -- 2174
						}) -- 2174
						target = Path:getName(Path:getPath(target)) -- 2175
						return { -- 2176
							success = success, -- 2176
							target = target, -- 2176
							err = err -- 2176
						} -- 2176
					end -- 2171
				else -- 2178
					workDir = getProjectDirFromFile(file) -- 2178
					if not workDir and Path:getExt(file) == "wasm" then -- 2179
						local parent = Path:getPath(file) -- 2180
						if Content:exist(Path(parent, "wa.mod")) then -- 2181
							workDir = parent -- 2182
						end -- 2181
					end -- 2179
				end -- 2165
				Entry.allClear() -- 2183
				file = Path:replaceExt(file, "") -- 2184
				local entry = { -- 2186
					entryName = Path:getName(file), -- 2186
					fileName = file, -- 2187
					runKind = "file" -- 2188
				} -- 2185
				if workDir then -- 2189
					entry.workDir = workDir -- 2190
					entry.projectRoot = workDir -- 2191
				end -- 2189
				local success, err = Entry.enterEntryAsync(entry) -- 2192
				return { -- 2193
					success = success, -- 2193
					err = err -- 2193
				} -- 2193
			end -- 2159
		end -- 2159
	end -- 2159
	return { -- 2158
		success = false -- 2158
	} -- 2158
end) -- 2158
HttpServer:postSchedule("/stop", function() -- 2195
	local Entry = require("Script.Dev.Entry") -- 2196
	return { -- 2197
		success = Entry.stop() -- 2197
	} -- 2197
end) -- 2195
local minifyAsync -- 2199
minifyAsync = function(sourcePath, minifyPath) -- 2199
	if not Content:exist(sourcePath) then -- 2200
		return -- 2200
	end -- 2200
	local Entry = require("Script.Dev.Entry") -- 2201
	local errors = { } -- 2202
	local files = Entry.getAllFiles(sourcePath, { -- 2203
		"lua" -- 2203
	}, true) -- 2203
	do -- 2204
		local _accum_0 = { } -- 2204
		local _len_0 = 1 -- 2204
		for _index_0 = 1, #files do -- 2204
			local file = files[_index_0] -- 2204
			if file:sub(1, 1) ~= '.' then -- 2204
				_accum_0[_len_0] = file -- 2204
				_len_0 = _len_0 + 1 -- 2204
			end -- 2204
		end -- 2204
		files = _accum_0 -- 2204
	end -- 2204
	local paths -- 2205
	do -- 2205
		local _tbl_0 = { } -- 2205
		for _index_0 = 1, #files do -- 2205
			local file = files[_index_0] -- 2205
			_tbl_0[Path:getPath(file)] = true -- 2205
		end -- 2205
		paths = _tbl_0 -- 2205
	end -- 2205
	for path in pairs(paths) do -- 2206
		Content:mkdir(Path(minifyPath, path)) -- 2206
	end -- 2206
	local _ <close> = setmetatable({ }, { -- 2207
		__close = function() -- 2207
			package.loaded["luaminify.FormatMini"] = nil -- 2208
			package.loaded["luaminify.ParseLua"] = nil -- 2209
			package.loaded["luaminify.Scope"] = nil -- 2210
			package.loaded["luaminify.Util"] = nil -- 2211
		end -- 2207
	}) -- 2207
	local FormatMini -- 2212
	do -- 2212
		local _obj_0 = require("luaminify") -- 2212
		FormatMini = _obj_0.FormatMini -- 2212
	end -- 2212
	local fileCount = #files -- 2213
	local count = 0 -- 2214
	for _index_0 = 1, #files do -- 2215
		local file = files[_index_0] -- 2215
		thread(function() -- 2216
			local _ <close> = setmetatable({ }, { -- 2217
				__close = function() -- 2217
					count = count + 1 -- 2217
				end -- 2217
			}) -- 2217
			local input = Path(sourcePath, file) -- 2218
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2219
			if Content:exist(input) then -- 2220
				local sourceCodes = Content:loadAsync(input) -- 2221
				local res, err = FormatMini(sourceCodes) -- 2222
				if res then -- 2223
					Content:saveAsync(output, res) -- 2224
					return print("Minify " .. tostring(file)) -- 2225
				else -- 2227
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2227
				end -- 2223
			else -- 2229
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2229
			end -- 2220
		end) -- 2216
		sleep() -- 2230
	end -- 2215
	wait(function() -- 2231
		return count == fileCount -- 2231
	end) -- 2231
	if #errors > 0 then -- 2232
		print(table.concat(errors, '\n')) -- 2233
	end -- 2232
	print("Obfuscation done.") -- 2234
	return files -- 2235
end -- 2199
local zipping = false -- 2237
HttpServer:postSchedule("/zip", function(req) -- 2239
	do -- 2240
		local _type_0 = type(req) -- 2240
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2240
		if _tab_0 then -- 2240
			local path -- 2240
			do -- 2240
				local _obj_0 = req.body -- 2240
				local _type_1 = type(_obj_0) -- 2240
				if "table" == _type_1 or "userdata" == _type_1 then -- 2240
					path = _obj_0.path -- 2240
				end -- 2240
			end -- 2240
			local zipFile -- 2240
			do -- 2240
				local _obj_0 = req.body -- 2240
				local _type_1 = type(_obj_0) -- 2240
				if "table" == _type_1 or "userdata" == _type_1 then -- 2240
					zipFile = _obj_0.zipFile -- 2240
				end -- 2240
			end -- 2240
			local obfuscated -- 2240
			do -- 2240
				local _obj_0 = req.body -- 2240
				local _type_1 = type(_obj_0) -- 2240
				if "table" == _type_1 or "userdata" == _type_1 then -- 2240
					obfuscated = _obj_0.obfuscated -- 2240
				end -- 2240
			end -- 2240
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2240
				if zipping then -- 2241
					goto failed -- 2241
				end -- 2241
				zipping = true -- 2242
				local _ <close> = setmetatable({ }, { -- 2243
					__close = function() -- 2243
						zipping = false -- 2243
					end -- 2243
				}) -- 2243
				if not Content:exist(path) then -- 2244
					goto failed -- 2244
				end -- 2244
				Content:mkdir(Path:getPath(zipFile)) -- 2245
				if obfuscated then -- 2246
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2247
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2248
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2249
					Content:remove(scriptPath) -- 2250
					Content:remove(obfuscatedPath) -- 2251
					Content:remove(tempPath) -- 2252
					Content:mkdir(scriptPath) -- 2253
					Content:mkdir(obfuscatedPath) -- 2254
					Content:mkdir(tempPath) -- 2255
					if not Content:copyAsync(path, tempPath) then -- 2256
						goto failed -- 2256
					end -- 2256
					local Entry = require("Script.Dev.Entry") -- 2257
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2258
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2259
						"tl", -- 2259
						"yue", -- 2259
						"lua", -- 2259
						"ts", -- 2259
						"tsx", -- 2259
						"vs", -- 2259
						"bl", -- 2259
						"xml", -- 2259
						"wa", -- 2259
						"mod" -- 2259
					}, true) -- 2259
					for _index_0 = 1, #scriptFiles do -- 2260
						local file = scriptFiles[_index_0] -- 2260
						Content:remove(Path(tempPath, file)) -- 2261
					end -- 2260
					for _index_0 = 1, #luaFiles do -- 2262
						local file = luaFiles[_index_0] -- 2262
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2263
					end -- 2262
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2264
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2265
					end) then -- 2264
						goto failed -- 2264
					end -- 2264
					return { -- 2266
						success = true -- 2266
					} -- 2266
				else -- 2268
					return { -- 2268
						success = Content:zipAsync(path, zipFile, function(file) -- 2268
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2269
						end) -- 2268
					} -- 2268
				end -- 2246
			end -- 2240
		end -- 2240
	end -- 2240
	::failed:: -- 2270
	return { -- 2239
		success = false -- 2239
	} -- 2239
end) -- 2239
HttpServer:postSchedule("/unzip", function(req) -- 2272
	do -- 2273
		local _type_0 = type(req) -- 2273
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2273
		if _tab_0 then -- 2273
			local zipFile -- 2273
			do -- 2273
				local _obj_0 = req.body -- 2273
				local _type_1 = type(_obj_0) -- 2273
				if "table" == _type_1 or "userdata" == _type_1 then -- 2273
					zipFile = _obj_0.zipFile -- 2273
				end -- 2273
			end -- 2273
			local path -- 2273
			do -- 2273
				local _obj_0 = req.body -- 2273
				local _type_1 = type(_obj_0) -- 2273
				if "table" == _type_1 or "userdata" == _type_1 then -- 2273
					path = _obj_0.path -- 2273
				end -- 2273
			end -- 2273
			if zipFile ~= nil and path ~= nil then -- 2273
				return { -- 2274
					success = Content:unzipAsync(zipFile, path, function(file) -- 2274
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2275
					end) -- 2274
				} -- 2274
			end -- 2273
		end -- 2273
	end -- 2273
	return { -- 2272
		success = false -- 2272
	} -- 2272
end) -- 2272
HttpServer:post("/editing-info", function(req) -- 2277
	local Entry = require("Script.Dev.Entry") -- 2278
	local config = Entry.getConfig() -- 2279
	local _type_0 = type(req) -- 2280
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2280
	local _match_0 = false -- 2280
	if _tab_0 then -- 2280
		local editingInfo -- 2280
		do -- 2280
			local _obj_0 = req.body -- 2280
			local _type_1 = type(_obj_0) -- 2280
			if "table" == _type_1 or "userdata" == _type_1 then -- 2280
				editingInfo = _obj_0.editingInfo -- 2280
			end -- 2280
		end -- 2280
		if editingInfo ~= nil then -- 2280
			_match_0 = true -- 2280
			config.editingInfo = editingInfo -- 2281
			return { -- 2282
				success = true -- 2282
			} -- 2282
		end -- 2280
	end -- 2280
	if not _match_0 then -- 2280
		if not (config.editingInfo ~= nil) then -- 2284
			local folder -- 2285
			if App.locale:match('^zh') then -- 2285
				folder = 'zh-Hans' -- 2285
			else -- 2285
				folder = 'en' -- 2285
			end -- 2285
			config.editingInfo = json.encode({ -- 2287
				index = 0, -- 2287
				files = { -- 2289
					{ -- 2290
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2290
						title = "welcome.md" -- 2291
					} -- 2289
				} -- 2288
			}) -- 2286
		end -- 2284
		return { -- 2295
			success = true, -- 2295
			editingInfo = config.editingInfo -- 2295
		} -- 2295
	end -- 2280
end) -- 2277
HttpServer:post("/command", function(req) -- 2297
	do -- 2298
		local _type_0 = type(req) -- 2298
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2298
		if _tab_0 then -- 2298
			local code -- 2298
			do -- 2298
				local _obj_0 = req.body -- 2298
				local _type_1 = type(_obj_0) -- 2298
				if "table" == _type_1 or "userdata" == _type_1 then -- 2298
					code = _obj_0.code -- 2298
				end -- 2298
			end -- 2298
			local log -- 2298
			do -- 2298
				local _obj_0 = req.body -- 2298
				local _type_1 = type(_obj_0) -- 2298
				if "table" == _type_1 or "userdata" == _type_1 then -- 2298
					log = _obj_0.log -- 2298
				end -- 2298
			end -- 2298
			if code ~= nil and log ~= nil then -- 2298
				emit("AppCommand", code, log) -- 2299
				return { -- 2300
					success = true -- 2300
				} -- 2300
			end -- 2298
		end -- 2298
	end -- 2298
	return { -- 2297
		success = false -- 2297
	} -- 2297
end) -- 2297
HttpServer:post("/log/save", function() -- 2302
	local folder = ".download" -- 2303
	local fullLogFile = "dora_full_logs.txt" -- 2304
	local fullFolder = Path(Content.writablePath, folder) -- 2305
	Content:mkdir(fullFolder) -- 2306
	local logPath = Path(fullFolder, fullLogFile) -- 2307
	if App:saveLog(logPath) then -- 2308
		return { -- 2309
			success = true, -- 2309
			path = Path(folder, fullLogFile) -- 2309
		} -- 2309
	end -- 2308
	return { -- 2302
		success = false -- 2302
	} -- 2302
end) -- 2302
local tailLines -- 2311
tailLines = function(text, count) -- 2311
	local lines = { } -- 2312
	text = text:gsub("\r\n", "\n") -- 2313
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2314
		lines[#lines + 1] = line -- 2315
	end -- 2314
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2316
		table.remove(lines) -- 2317
	end -- 2316
	local start = math.max(1, #lines - count + 1) -- 2318
	local out = { } -- 2319
	for i = start, #lines do -- 2320
		out[#out + 1] = lines[i] -- 2321
	end -- 2320
	return table.concat(out, "\n") -- 2322
end -- 2311
HttpServer:post("/log", function(req) -- 2324
	local count = 100 -- 2325
	if req and req.body and req.body.count ~= nil then -- 2326
		count = req.body.count -- 2327
	end -- 2326
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2328
		return { -- 2329
			success = false, -- 2329
			message = "count must be a positive integer" -- 2329
		} -- 2329
	end -- 2328
	local folder = ".download" -- 2330
	local fullLogFile = "dora_full_logs.txt" -- 2331
	local fullFolder = Path(Content.writablePath, folder) -- 2332
	Content:mkdir(fullFolder) -- 2333
	local logPath = Path(fullFolder, fullLogFile) -- 2334
	if App:saveLog(logPath) then -- 2335
		local text = Content:load(logPath) -- 2336
		if text then -- 2337
			return { -- 2338
				success = true, -- 2338
				log = tailLines(text, count) -- 2338
			} -- 2338
		else -- 2340
			return { -- 2340
				success = false, -- 2340
				message = "failed to read log" -- 2340
			} -- 2340
		end -- 2337
	else -- 2342
		return { -- 2342
			success = false, -- 2342
			message = "failed to save log" -- 2342
		} -- 2342
	end -- 2335
	return { -- 2324
		success = false -- 2324
	} -- 2324
end) -- 2324
HttpServer:post("/yarn/check", function(req) -- 2344
	local yarncompile = require("yarncompile") -- 2345
	do -- 2346
		local _type_0 = type(req) -- 2346
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2346
		if _tab_0 then -- 2346
			local code -- 2346
			do -- 2346
				local _obj_0 = req.body -- 2346
				local _type_1 = type(_obj_0) -- 2346
				if "table" == _type_1 or "userdata" == _type_1 then -- 2346
					code = _obj_0.code -- 2346
				end -- 2346
			end -- 2346
			if code ~= nil then -- 2346
				local jsonObject = json.decode(code) -- 2347
				if jsonObject then -- 2347
					local errors = { } -- 2348
					local _list_0 = jsonObject.nodes -- 2349
					for _index_0 = 1, #_list_0 do -- 2349
						local node = _list_0[_index_0] -- 2349
						local title, body = node.title, node.body -- 2350
						local luaCode, err = yarncompile(body) -- 2351
						if not luaCode then -- 2351
							errors[#errors + 1] = title .. ":" .. err -- 2352
						end -- 2351
					end -- 2349
					return { -- 2353
						success = true, -- 2353
						syntaxError = table.concat(errors, "\n\n") -- 2353
					} -- 2353
				end -- 2347
			end -- 2346
		end -- 2346
	end -- 2346
	return { -- 2344
		success = false -- 2344
	} -- 2344
end) -- 2344
HttpServer:post("/yarn/check-file", function(req) -- 2355
	local yarncompile = require("yarncompile") -- 2356
	do -- 2357
		local _type_0 = type(req) -- 2357
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2357
		if _tab_0 then -- 2357
			local code -- 2357
			do -- 2357
				local _obj_0 = req.body -- 2357
				local _type_1 = type(_obj_0) -- 2357
				if "table" == _type_1 or "userdata" == _type_1 then -- 2357
					code = _obj_0.code -- 2357
				end -- 2357
			end -- 2357
			if code ~= nil then -- 2357
				local res, _, err = yarncompile(code, true) -- 2358
				if not res then -- 2358
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2359
					return { -- 2360
						success = false, -- 2360
						message = message, -- 2360
						line = line, -- 2360
						column = column, -- 2360
						node = node -- 2360
					} -- 2360
				end -- 2358
			end -- 2357
		end -- 2357
	end -- 2357
	return { -- 2355
		success = true -- 2355
	} -- 2355
end) -- 2355
getWaProjectDirFromFile = function(file) -- 2362
	local current -- 2363
	if Content:isdir(file) then -- 2363
		current = file -- 2363
	else -- 2363
		current = Path:getPath(file) -- 2363
	end -- 2363
	if current == "" then -- 2364
		return nil -- 2364
	end -- 2364
	repeat -- 2365
		local modPath = Path(current, "wa.mod") -- 2366
		if Content:exist(modPath) then -- 2367
			return current, modPath -- 2368
		end -- 2367
		local parent = Path:getPath(current) -- 2369
		if parent == "" or parent == current then -- 2370
			break -- 2370
		end -- 2370
		current = parent -- 2371
	until false -- 2365
	return nil -- 2373
end -- 2362
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2375
	do -- 2376
		local _type_0 = type(req) -- 2376
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2376
		if _tab_0 then -- 2376
			local path -- 2376
			do -- 2376
				local _obj_0 = req.body -- 2376
				local _type_1 = type(_obj_0) -- 2376
				if "table" == _type_1 or "userdata" == _type_1 then -- 2376
					path = _obj_0.path -- 2376
				end -- 2376
			end -- 2376
			if path ~= nil then -- 2376
				local projDir = getWaProjectDirFromFile(path) -- 2377
				if projDir then -- 2377
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2378
					if not Content:exist(sourceDoraPath) then -- 2379
						return { -- 2380
							success = false, -- 2380
							message = "missing dora template" -- 2380
						} -- 2380
					end -- 2379
					local targetVendorPath = Path(projDir, "vendor") -- 2381
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2382
					if not Content:exist(targetVendorPath) then -- 2383
						if not Content:mkdir(targetVendorPath) then -- 2384
							return { -- 2385
								success = false, -- 2385
								message = "failed to create vendor folder" -- 2385
							} -- 2385
						end -- 2384
					elseif not Content:isdir(targetVendorPath) then -- 2386
						return { -- 2387
							success = false, -- 2387
							message = "vendor path is not a folder" -- 2387
						} -- 2387
					end -- 2383
					if Content:exist(targetDoraPath) then -- 2388
						if not Content:remove(targetDoraPath) then -- 2389
							return { -- 2390
								success = false, -- 2390
								message = "failed to remove old dora" -- 2390
							} -- 2390
						end -- 2389
					end -- 2388
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2391
						return { -- 2392
							success = false, -- 2392
							message = "failed to copy dora" -- 2392
						} -- 2392
					end -- 2391
					return { -- 2393
						success = true -- 2393
					} -- 2393
				else -- 2395
					return { -- 2395
						success = false, -- 2395
						message = 'Wa file needs a project' -- 2395
					} -- 2395
				end -- 2377
			end -- 2376
		end -- 2376
	end -- 2376
	return { -- 2375
		success = false, -- 2375
		message = "invalid call" -- 2375
	} -- 2375
end) -- 2375
HttpServer:postSchedule("/wa/build", function(req) -- 2397
	do -- 2398
		local _type_0 = type(req) -- 2398
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2398
		if _tab_0 then -- 2398
			local path -- 2398
			do -- 2398
				local _obj_0 = req.body -- 2398
				local _type_1 = type(_obj_0) -- 2398
				if "table" == _type_1 or "userdata" == _type_1 then -- 2398
					path = _obj_0.path -- 2398
				end -- 2398
			end -- 2398
			if path ~= nil then -- 2398
				local projDir = getWaProjectDirFromFile(path) -- 2399
				if projDir then -- 2399
					local message = Wasm:buildWaAsync(projDir) -- 2400
					if message == "" then -- 2401
						return { -- 2402
							success = true -- 2402
						} -- 2402
					else -- 2404
						return { -- 2404
							success = false, -- 2404
							message = message -- 2404
						} -- 2404
					end -- 2401
				else -- 2406
					return { -- 2406
						success = false, -- 2406
						message = 'Wa file needs a project' -- 2406
					} -- 2406
				end -- 2399
			end -- 2398
		end -- 2398
	end -- 2398
	return { -- 2407
		success = false, -- 2407
		message = 'failed to build' -- 2407
	} -- 2407
end) -- 2397
HttpServer:postSchedule("/wa/format", function(req) -- 2409
	do -- 2410
		local _type_0 = type(req) -- 2410
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2410
		if _tab_0 then -- 2410
			local file -- 2410
			do -- 2410
				local _obj_0 = req.body -- 2410
				local _type_1 = type(_obj_0) -- 2410
				if "table" == _type_1 or "userdata" == _type_1 then -- 2410
					file = _obj_0.file -- 2410
				end -- 2410
			end -- 2410
			if file ~= nil then -- 2410
				local code = Wasm:formatWaAsync(file) -- 2411
				if code == "" then -- 2412
					return { -- 2413
						success = false -- 2413
					} -- 2413
				else -- 2415
					return { -- 2415
						success = true, -- 2415
						code = code -- 2415
					} -- 2415
				end -- 2412
			end -- 2410
		end -- 2410
	end -- 2410
	return { -- 2416
		success = false -- 2416
	} -- 2416
end) -- 2409
HttpServer:postSchedule("/wa/create", function(req) -- 2418
	do -- 2419
		local _type_0 = type(req) -- 2419
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2419
		if _tab_0 then -- 2419
			local path -- 2419
			do -- 2419
				local _obj_0 = req.body -- 2419
				local _type_1 = type(_obj_0) -- 2419
				if "table" == _type_1 or "userdata" == _type_1 then -- 2419
					path = _obj_0.path -- 2419
				end -- 2419
			end -- 2419
			if path ~= nil then -- 2419
				if not Content:exist(Path:getPath(path)) then -- 2420
					return { -- 2421
						success = false, -- 2421
						message = "target path not existed" -- 2421
					} -- 2421
				end -- 2420
				if Content:exist(path) then -- 2422
					return { -- 2423
						success = false, -- 2423
						message = "target project folder existed" -- 2423
					} -- 2423
				end -- 2422
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2424
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2425
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2426
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2427
					return { -- 2430
						success = false, -- 2430
						message = "missing template project" -- 2430
					} -- 2430
				end -- 2427
				if not Content:mkdir(path) then -- 2431
					return { -- 2432
						success = false, -- 2432
						message = "failed to create project folder" -- 2432
					} -- 2432
				end -- 2431
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2433
					Content:remove(path) -- 2434
					return { -- 2435
						success = false, -- 2435
						message = "failed to copy template" -- 2435
					} -- 2435
				end -- 2433
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2436
					Content:remove(path) -- 2437
					return { -- 2438
						success = false, -- 2438
						message = "failed to copy template" -- 2438
					} -- 2438
				end -- 2436
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2439
					Content:remove(path) -- 2440
					return { -- 2441
						success = false, -- 2441
						message = "failed to copy template" -- 2441
					} -- 2441
				end -- 2439
				return { -- 2442
					success = true -- 2442
				} -- 2442
			end -- 2419
		end -- 2419
	end -- 2419
	return { -- 2418
		success = false, -- 2418
		message = "invalid call" -- 2418
	} -- 2418
end) -- 2418
local tsBuildGlobs = { -- 2445
	"**/*.ts", -- 2445
	"**/*.tsx", -- 2446
	"!**/.*/**", -- 2447
	"!**/node_modules/**" -- 2448
} -- 2444
local tsSnapshotGlobs = { -- 2451
	"**/*.ts", -- 2451
	"**/*.tsx", -- 2452
	"**/*.lua", -- 2453
	"!**/.*/**", -- 2454
	"!**/node_modules/**" -- 2455
} -- 2450
local collectTSVirtualFiles -- 2457
collectTSVirtualFiles = function(sourceRoot) -- 2457
	local files = { } -- 2458
	local seen = { } -- 2459
	local addFile -- 2460
	addFile = function(file, moduleName, virtualFile) -- 2460
		if moduleName == nil then -- 2460
			moduleName = nil -- 2460
		end -- 2460
		if virtualFile == nil then -- 2460
			virtualFile = nil -- 2460
		end -- 2460
		local targetFile = virtualFile or file -- 2461
		do -- 2462
			local entry = seen[targetFile] -- 2462
			if entry then -- 2462
				if moduleName and moduleName ~= "" then -- 2463
					entry.moduleName = moduleName -- 2463
				end -- 2463
				return -- 2464
			end -- 2462
		end -- 2462
		local content = Content:load(file) -- 2465
		if content then -- 2465
			local entry = { -- 2466
				file = targetFile, -- 2466
				content = content -- 2466
			} -- 2466
			if moduleName and moduleName ~= "" then -- 2467
				entry.moduleName = moduleName -- 2467
			end -- 2467
			seen[targetFile] = entry -- 2468
			files[#files + 1] = entry -- 2469
		end -- 2465
	end -- 2460
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2470
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2471
		for _index_0 = 1, #_list_0 do -- 2471
			local subFile = _list_0[_index_0] -- 2471
			addFile(Path(sourceRoot, subFile)) -- 2472
		end -- 2471
		local libraryRoots = { -- 2474
			Path(sourceRoot, "Script", "Lib"), -- 2474
			Path(sourceRoot, "Lib"), -- 2475
			Path(Content.assetPath, "Script", "Lib") -- 2476
		} -- 2473
		for _index_0 = 1, #libraryRoots do -- 2477
			local libraryRoot = libraryRoots[_index_0] -- 2477
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2478
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2479
				for _index_1 = 1, #_list_1 do -- 2479
					local subFile = _list_1[_index_1] -- 2479
					local file = Path(libraryRoot, subFile) -- 2480
					local virtualFile = Path(sourceRoot, subFile) -- 2481
					addFile(file, nil, virtualFile) -- 2482
				end -- 2479
			end -- 2478
		end -- 2477
	end -- 2470
	local locale -- 2483
	if App.locale:match('^zh') then -- 2483
		locale = 'zh-Hans' -- 2483
	else -- 2483
		locale = 'en' -- 2483
	end -- 2483
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2484
	local _list_0 = Content:getFiles(declarationRoot) -- 2485
	for _index_0 = 1, #_list_0 do -- 2485
		local file = _list_0[_index_0] -- 2485
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2486
			local fullPath = Path(declarationRoot, file) -- 2487
			local moduleName = Path:getName(Path:getName(file)) -- 2488
			addFile(fullPath, moduleName) -- 2489
		end -- 2486
	end -- 2485
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2490
	do -- 2491
		local content = Content:load(lualibBundle) -- 2491
		if content then -- 2491
			files[#files + 1] = { -- 2492
				file = "lualib_bundle.lua", -- 2492
				content = content -- 2492
			} -- 2492
		end -- 2491
	end -- 2491
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2493
	local _list_1 = Content:getFiles(lualibRoot) -- 2494
	for _index_0 = 1, #_list_1 do -- 2494
		local file = _list_1[_index_0] -- 2494
		if Path:getExt(file) == "lua" then -- 2495
			local content = Content:load(Path(lualibRoot, file)) -- 2496
			if content then -- 2496
				files[#files + 1] = { -- 2497
					file = Path("lualib", file), -- 2497
					content = content -- 2497
				} -- 2497
			end -- 2496
		end -- 2495
	end -- 2494
	return files -- 2498
end -- 2457
local transpileTSFile -- 2500
do -- 2500
	local tsReadyTimeout <const> = 5 -- 2501
	local tsBuildTimeout <const> = 30 -- 2502
	local tsBuildRequestId = 0 -- 2503
	transpileTSFile = function(file, content, sourceRoot, files) -- 2504
		tsBuildRequestId = tsBuildRequestId + 1 -- 2505
		local requestId = tsBuildRequestId -- 2506
		local done = false -- 2507
		local ready = false -- 2508
		local result = nil -- 2509
		local listener = Node() -- 2510
		listener:gslot("AppWS", function(event) -- 2511
			if event.type == "Receive" then -- 2512
				local res = json.decode(event.msg) -- 2513
				if res then -- 2513
					if res.name == "TranspileTSProbe" and res.id == requestId then -- 2514
						ready = true -- 2515
					elseif res.name == "TranspileTS" and res.id == requestId then -- 2516
						listener:removeFromParent() -- 2517
						if res.success then -- 2518
							local luaFile = Path:replaceExt(file, "lua") -- 2519
							Content:save(luaFile, res.luaCode) -- 2520
							result = { -- 2521
								success = true, -- 2521
								file = file -- 2521
							} -- 2521
						else -- 2523
							result = { -- 2523
								success = false, -- 2523
								file = file, -- 2523
								message = res.message -- 2523
							} -- 2523
						end -- 2518
						done = true -- 2524
					end -- 2514
				end -- 2513
			end -- 2512
		end) -- 2511
		emit("AppWS", "Send", json.encode({ -- 2525
			name = "TranspileTSProbe", -- 2525
			id = requestId -- 2525
		})) -- 2525
		local readyDeadline = App.runningTime + tsReadyTimeout -- 2526
		wait(function() -- 2527
			return ready or HttpServer.wsConnectionCount == 0 or App.runningTime >= readyDeadline -- 2527
		end) -- 2527
		if not ready then -- 2528
			listener:removeFromParent() -- 2529
			if HttpServer.wsConnectionCount == 0 then -- 2530
				return { -- 2531
					success = false, -- 2531
					file = file, -- 2531
					message = "Web IDE disconnected" -- 2531
				} -- 2531
			end -- 2530
			return { -- 2532
				success = false, -- 2532
				file = file, -- 2532
				message = "TypeScript transpiler is not ready" -- 2532
			} -- 2532
		end -- 2528
		emit("AppWS", "Send", json.encode({ -- 2533
			name = "TranspileTS", -- 2533
			id = requestId, -- 2533
			file = file, -- 2533
			content = content, -- 2533
			projectRoot = sourceRoot, -- 2533
			files = files -- 2533
		})) -- 2533
		local deadline = App.runningTime + tsBuildTimeout -- 2534
		wait(function() -- 2535
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline -- 2535
		end) -- 2535
		if not done then -- 2536
			listener:removeFromParent() -- 2537
			if HttpServer.wsConnectionCount == 0 then -- 2538
				return { -- 2539
					success = false, -- 2539
					file = file, -- 2539
					message = "Web IDE disconnected" -- 2539
				} -- 2539
			end -- 2538
			return { -- 2540
				success = false, -- 2540
				file = file, -- 2540
				message = "TypeScript transpile timed out" -- 2540
			} -- 2540
		end -- 2536
		return result -- 2541
	end -- 2504
end -- 2500
local _anon_func_7 = function(path) -- 2552
	local _val_0 = Path:getExt(path) -- 2552
	return "ts" == _val_0 or "tsx" == _val_0 -- 2552
end -- 2552
HttpServer:postSchedule("/ts/build", function(req) -- 2543
	do -- 2544
		local _type_0 = type(req) -- 2544
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2544
		if _tab_0 then -- 2544
			local path -- 2544
			do -- 2544
				local _obj_0 = req.body -- 2544
				local _type_1 = type(_obj_0) -- 2544
				if "table" == _type_1 or "userdata" == _type_1 then -- 2544
					path = _obj_0.path -- 2544
				end -- 2544
			end -- 2544
			if path ~= nil then -- 2544
				if HttpServer.wsConnectionCount == 0 then -- 2545
					return { -- 2546
						success = false, -- 2546
						message = "Web IDE not connected" -- 2546
					} -- 2546
				end -- 2545
				local projectRoot = req.body.projectRoot -- 2547
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2548
				if not Content:exist(path) then -- 2549
					return { -- 2550
						success = false, -- 2550
						message = "path not existed" -- 2550
					} -- 2550
				end -- 2549
				if not Content:isdir(path) then -- 2551
					if not (_anon_func_7(path)) then -- 2552
						return { -- 2553
							success = false, -- 2553
							message = "expecting a TypeScript file" -- 2553
						} -- 2553
					end -- 2552
					local messages = { } -- 2554
					local content = Content:load(path) -- 2555
					if not content then -- 2556
						return { -- 2557
							success = false, -- 2557
							message = "failed to read file" -- 2557
						} -- 2557
					end -- 2556
					emit("AppWS", "Send", json.encode({ -- 2558
						name = "UpdateFile", -- 2558
						file = path, -- 2558
						exists = true, -- 2558
						content = content, -- 2558
						projectRoot = sourceRoot -- 2558
					})) -- 2558
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2559
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2560
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2561
					end -- 2559
					return { -- 2562
						success = true, -- 2562
						messages = messages -- 2562
					} -- 2562
				else -- 2564
					local fileData = { } -- 2564
					local messages = { } -- 2565
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2566
					for _index_0 = 1, #_list_0 do -- 2566
						local subFile = _list_0[_index_0] -- 2566
						local file = Path(path, subFile) -- 2567
						local content = Content:load(file) -- 2568
						if content then -- 2568
							fileData[file] = content -- 2569
							emit("AppWS", "Send", json.encode({ -- 2570
								name = "UpdateFile", -- 2570
								file = file, -- 2570
								exists = true, -- 2570
								content = content, -- 2570
								projectRoot = sourceRoot -- 2570
							})) -- 2570
						else -- 2572
							messages[#messages + 1] = { -- 2572
								success = false, -- 2572
								file = file, -- 2572
								message = "failed to read file" -- 2572
							} -- 2572
						end -- 2568
					end -- 2566
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2573
					for file, content in pairs(fileData) do -- 2574
						if "d" == Path:getExt(Path:getName(file)) then -- 2575
							goto _continue_0 -- 2575
						end -- 2575
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2576
						::_continue_0:: -- 2575
					end -- 2574
					return { -- 2577
						success = true, -- 2577
						messages = messages -- 2577
					} -- 2577
				end -- 2551
			end -- 2544
		end -- 2544
	end -- 2544
	return { -- 2543
		success = false -- 2543
	} -- 2543
end) -- 2543
HttpServer:post("/download", function(req) -- 2579
	do -- 2580
		local _type_0 = type(req) -- 2580
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2580
		if _tab_0 then -- 2580
			local url -- 2580
			do -- 2580
				local _obj_0 = req.body -- 2580
				local _type_1 = type(_obj_0) -- 2580
				if "table" == _type_1 or "userdata" == _type_1 then -- 2580
					url = _obj_0.url -- 2580
				end -- 2580
			end -- 2580
			local target -- 2580
			do -- 2580
				local _obj_0 = req.body -- 2580
				local _type_1 = type(_obj_0) -- 2580
				if "table" == _type_1 or "userdata" == _type_1 then -- 2580
					target = _obj_0.target -- 2580
				end -- 2580
			end -- 2580
			if url ~= nil and target ~= nil then -- 2580
				local Entry = require("Script.Dev.Entry") -- 2581
				Entry.downloadFile(url, target) -- 2582
				return { -- 2583
					success = true -- 2583
				} -- 2583
			end -- 2580
		end -- 2580
	end -- 2580
	return { -- 2579
		success = false -- 2579
	} -- 2579
end) -- 2579
local isDesktopPlatform -- 2585
isDesktopPlatform = function() -- 2585
	local _val_0 = App.platform -- 2586
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2586
end -- 2585
local getServerStatus -- 2588
getServerStatus = function() -- 2588
	local Entry = require("Script.Dev.Entry") -- 2589
	local running = Entry.getCurrentEntryStatus() -- 2590
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2591
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2592
	return { -- 2594
		success = true, -- 2594
		platform = App.platform, -- 2595
		locale = App.locale, -- 2596
		version = App.version, -- 2597
		url = "http://localhost:8866", -- 2598
		wsConnectionCount = wsConnectionCount, -- 2599
		webIDEConnected = wsConnectionCount > 0, -- 2600
		assetPath = Content.assetPath, -- 2601
		writablePath = Content.writablePath, -- 2602
		appPath = Content.appPath, -- 2603
		waTemplateReady = waTemplateReady, -- 2604
		running = running -- 2605
	} -- 2593
end -- 2588
HttpServer:post("/status", function() -- 2608
	return getServerStatus() -- 2609
end) -- 2608
HttpServer:postSchedule("/doctor/fix", function(req) -- 2611
	do -- 2612
		local _type_0 = type(req) -- 2612
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2612
		if _tab_0 then -- 2612
			local openWebIDE -- 2612
			do -- 2612
				local _obj_0 = req.body -- 2612
				local _type_1 = type(_obj_0) -- 2612
				if "table" == _type_1 or "userdata" == _type_1 then -- 2612
					openWebIDE = _obj_0.openWebIDE -- 2612
				end -- 2612
			end -- 2612
			if openWebIDE ~= nil then -- 2612
				if not openWebIDE then -- 2613
					return { -- 2614
						success = false, -- 2614
						message = "nothing to fix" -- 2614
					} -- 2614
				end -- 2613
				local status = getServerStatus() -- 2615
				if status.webIDEConnected then -- 2616
					return { -- 2617
						success = true, -- 2617
						fixed = false, -- 2617
						message = "Web IDE already connected.", -- 2617
						status = status -- 2617
					} -- 2617
				end -- 2616
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2618
				if waitSeconds > 0 then -- 2619
					local deadline = os.time() + waitSeconds -- 2620
					repeat -- 2621
						sleep(0.2) -- 2622
						status = getServerStatus() -- 2623
						if status.webIDEConnected then -- 2624
							return { -- 2625
								success = true, -- 2625
								fixed = false, -- 2625
								reconnected = true, -- 2625
								message = "Web IDE reconnected.", -- 2625
								status = status -- 2625
							} -- 2625
						end -- 2624
					until os.time() >= deadline -- 2621
				end -- 2619
				if not isDesktopPlatform() then -- 2627
					return { -- 2628
						success = false, -- 2628
						message = "opening Web IDE is only supported on desktop platforms", -- 2628
						status = status -- 2628
					} -- 2628
				end -- 2627
				local url = "http://localhost:8866" -- 2629
				App:openURL(url) -- 2630
				status.openedURL = url -- 2631
				return { -- 2632
					success = true, -- 2632
					fixed = true, -- 2632
					message = "Opened Web IDE in the local browser.", -- 2632
					url = url, -- 2632
					status = status -- 2632
				} -- 2632
			end -- 2612
		end -- 2612
	end -- 2612
	return { -- 2611
		success = false, -- 2611
		message = "invalid call" -- 2611
	} -- 2611
end) -- 2611
local status = { } -- 2634
_module_0 = status -- 2635
status.buildAsync = function(path) -- 2637
	if not Content:exist(path) then -- 2638
		return { -- 2639
			success = false, -- 2639
			file = path, -- 2639
			message = "file not existed" -- 2639
		} -- 2639
	end -- 2638
	do -- 2640
		local _exp_0 = Path:getExt(path) -- 2640
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2640
			if '' == Path:getExt(Path:getName(path)) then -- 2641
				local content = Content:loadAsync(path) -- 2642
				if content then -- 2642
					local resultCodes, err = compileFileAsync(path, content) -- 2643
					if resultCodes then -- 2643
						return { -- 2644
							success = true, -- 2644
							file = path -- 2644
						} -- 2644
					else -- 2646
						return { -- 2646
							success = false, -- 2646
							file = path, -- 2646
							message = err -- 2646
						} -- 2646
					end -- 2643
				end -- 2642
			end -- 2641
		elseif "lua" == _exp_0 then -- 2647
			local content = Content:loadAsync(path) -- 2648
			if content then -- 2648
				do -- 2649
					local isTIC80 = CheckTIC80Code(content) -- 2649
					if isTIC80 then -- 2649
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2650
					end -- 2649
				end -- 2649
				local success, info -- 2651
				do -- 2651
					local _obj_0 = luaCheck(path, content) -- 2651
					success, info = _obj_0.success, _obj_0.info -- 2651
				end -- 2651
				if success then -- 2652
					return { -- 2653
						success = true, -- 2653
						file = path -- 2653
					} -- 2653
				elseif info and #info > 0 then -- 2654
					local messages = { } -- 2655
					for _index_0 = 1, #info do -- 2656
						local _des_0 = info[_index_0] -- 2656
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2656
						local lineText = "" -- 2657
						if line then -- 2658
							local currentLine = 1 -- 2659
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2660
								if currentLine == line then -- 2661
									lineText = text -- 2662
									break -- 2663
								end -- 2661
								currentLine = currentLine + 1 -- 2664
							end -- 2660
						end -- 2658
						if line then -- 2665
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2666
						else -- 2668
							messages[#messages + 1] = message -- 2668
						end -- 2665
					end -- 2656
					return { -- 2669
						success = false, -- 2669
						file = path, -- 2669
						message = table.concat(messages, "\n") -- 2669
					} -- 2669
				else -- 2671
					return { -- 2671
						success = false, -- 2671
						file = path, -- 2671
						message = "lua check failed" -- 2671
					} -- 2671
				end -- 2652
			end -- 2648
		elseif "yarn" == _exp_0 then -- 2672
			local content = Content:loadAsync(path) -- 2673
			if content then -- 2673
				local res, _, err = yarncompile(content, true) -- 2674
				if res then -- 2674
					return { -- 2675
						success = true, -- 2675
						file = path -- 2675
					} -- 2675
				else -- 2677
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2677
					local lineText = "" -- 2678
					if line then -- 2679
						local currentLine = 1 -- 2680
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2681
							if currentLine == line then -- 2682
								lineText = text -- 2683
								break -- 2684
							end -- 2682
							currentLine = currentLine + 1 -- 2685
						end -- 2681
					end -- 2679
					if node ~= "" then -- 2686
						node = "node: " .. tostring(node) .. ", " -- 2687
					else -- 2688
						node = "" -- 2688
					end -- 2686
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2689
					return { -- 2690
						success = false, -- 2690
						file = path, -- 2690
						message = message -- 2690
					} -- 2690
				end -- 2674
			end -- 2673
		end -- 2640
	end -- 2640
	return { -- 2691
		success = false, -- 2691
		file = path, -- 2691
		message = "invalid file to build" -- 2691
	} -- 2691
end -- 2637
HttpServer:postSchedule("/git/commit-files", function(req) -- 2693
	do -- 2694
		local _type_0 = type(req) -- 2694
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2694
		if _tab_0 then -- 2694
			local body = req.body -- 2694
			if body ~= nil then -- 2694
				local repoPath, commit = body.repoPath, body.commit -- 2695
				if gitInvalidRepoPath(repoPath) then -- 2696
					return { -- 2696
						success = false, -- 2696
						message = "invalid repoPath" -- 2696
					} -- 2696
				end -- 2696
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 2697
					return { -- 2697
						success = false, -- 2697
						message = "invalid commit" -- 2697
					} -- 2697
				end -- 2697
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 2698
				if not res.success then -- 2699
					return res -- 2699
				end -- 2699
				return { -- 2700
					success = true, -- 2700
					status = res.status, -- 2700
					data = res.status and res.status.data -- 2700
				} -- 2700
			end -- 2694
		end -- 2694
	end -- 2694
	return invalidArguments -- 2693
end) -- 2693
thread(function() -- 2702
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 2703
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 2704
	if Content:exist(doraWeb) then -- 2705
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 2706
		local heavyAssetsContent -- 2707
		if Content:exist(heavyAssets) then -- 2707
			heavyAssetsContent = Content:load(heavyAssets) -- 2707
		else -- 2707
			heavyAssetsContent = "" -- 2707
		end -- 2707
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) .. "\n" .. heavyAssetsContent -- 2708
		local needReload -- 2709
		if Content:exist(doraReady) then -- 2709
			needReload = readyContent ~= Content:load(doraReady) -- 2710
		else -- 2711
			needReload = true -- 2711
		end -- 2709
		if needReload then -- 2712
			Content:remove(Path(Content.appPath, ".www")) -- 2713
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 2714
			Content:save(doraReady, readyContent) -- 2718
			print("Dora Dora is ready!") -- 2719
		end -- 2712
	end -- 2705
	HttpServer:clearStaticCacheControls() -- 2720
	HttpServer:setStaticCacheControl("no-cache") -- 2721
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 2722
	if HttpServer:start(8866) then -- 2726
		local localIP = HttpServer.localIP -- 2727
		if localIP == "" then -- 2728
			localIP = "localhost" -- 2728
		end -- 2728
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 2729
		return HttpServer:startWS(8868) -- 2730
	else -- 2732
		status.url = nil -- 2732
		return print("8866 Port not available!") -- 2733
	end -- 2726
end) -- 2702
return _module_0 -- 1
