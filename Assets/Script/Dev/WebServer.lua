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
					local success = false -- 987
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
local _anon_func_3 = function(doc) -- 1117
	local _accum_0 = { } -- 1117
	local _len_0 = 1 -- 1117
	local _list_0 = doc.params -- 1117
	for _index_0 = 1, #_list_0 do -- 1117
		local param = _list_0[_index_0] -- 1117
		_accum_0[_len_0] = param.name -- 1117
		_len_0 = _len_0 + 1 -- 1117
	end -- 1117
	return _accum_0 -- 1117
end -- 1117
local getParamDocs -- 1068
getParamDocs = function(signatures) -- 1068
	do -- 1069
		local codes = Content:loadAsync(signatures[1].file) -- 1069
		if codes then -- 1069
			local comments = { } -- 1070
			local params = { } -- 1071
			local line = 0 -- 1072
			local docs = { } -- 1073
			local returnType = nil -- 1074
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1075
				line = line + 1 -- 1076
				local needBreak = true -- 1077
				for i, _des_0 in ipairs(signatures) do -- 1078
					local row = _des_0.row -- 1078
					if line >= row and not (docs[i] ~= nil) then -- 1079
						if #comments > 0 or #params > 0 or returnType then -- 1080
							docs[i] = { -- 1082
								doc = table.concat(comments, "  \n"), -- 1082
								returnType = returnType -- 1083
							} -- 1081
							if #params > 0 then -- 1085
								docs[i].params = params -- 1085
							end -- 1085
						else -- 1087
							docs[i] = false -- 1087
						end -- 1080
					end -- 1079
					if not docs[i] then -- 1088
						needBreak = false -- 1088
					end -- 1088
				end -- 1078
				if needBreak then -- 1089
					break -- 1089
				end -- 1089
				local result = lineCode:match("%s*%-%- (.+)") -- 1090
				if result then -- 1090
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1091
					if not name then -- 1092
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1093
					end -- 1092
					if name then -- 1094
						local pname = name -- 1095
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1096
							pname = pname .. "?" -- 1096
						end -- 1096
						params[#params + 1] = { -- 1098
							name = tostring(pname) .. ": " .. tostring(typ), -- 1098
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1099
						} -- 1097
					else -- 1102
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1102
						if typ then -- 1102
							if returnType then -- 1103
								returnType = returnType .. ", " .. typ -- 1104
							else -- 1106
								returnType = typ -- 1106
							end -- 1103
							result = result:gsub("@return", "**return:**") -- 1107
						end -- 1102
						comments[#comments + 1] = result -- 1108
					end -- 1094
				elseif #comments > 0 then -- 1109
					comments = { } -- 1110
					params = { } -- 1111
					returnType = nil -- 1112
				end -- 1090
			end -- 1075
			local results = { } -- 1113
			for _index_0 = 1, #docs do -- 1114
				local doc = docs[_index_0] -- 1114
				if not doc then -- 1115
					goto _continue_0 -- 1115
				end -- 1115
				if doc.params then -- 1116
					doc.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1117
				else -- 1119
					doc.desc = "function()" -- 1119
				end -- 1116
				if doc.returnType then -- 1120
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 1121
					doc.returnType = nil -- 1122
				end -- 1120
				results[#results + 1] = doc -- 1123
				::_continue_0:: -- 1115
			end -- 1114
			if #results > 0 then -- 1124
				return results -- 1124
			else -- 1124
				return nil -- 1124
			end -- 1124
		end -- 1069
	end -- 1069
	return nil -- 1068
end -- 1068
HttpServer:postSchedule("/signature", function(req) -- 1126
	do -- 1127
		local _type_0 = type(req) -- 1127
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1127
		if _tab_0 then -- 1127
			local lang -- 1127
			do -- 1127
				local _obj_0 = req.body -- 1127
				local _type_1 = type(_obj_0) -- 1127
				if "table" == _type_1 or "userdata" == _type_1 then -- 1127
					lang = _obj_0.lang -- 1127
				end -- 1127
			end -- 1127
			local file -- 1127
			do -- 1127
				local _obj_0 = req.body -- 1127
				local _type_1 = type(_obj_0) -- 1127
				if "table" == _type_1 or "userdata" == _type_1 then -- 1127
					file = _obj_0.file -- 1127
				end -- 1127
			end -- 1127
			local content -- 1127
			do -- 1127
				local _obj_0 = req.body -- 1127
				local _type_1 = type(_obj_0) -- 1127
				if "table" == _type_1 or "userdata" == _type_1 then -- 1127
					content = _obj_0.content -- 1127
				end -- 1127
			end -- 1127
			local line -- 1127
			do -- 1127
				local _obj_0 = req.body -- 1127
				local _type_1 = type(_obj_0) -- 1127
				if "table" == _type_1 or "userdata" == _type_1 then -- 1127
					line = _obj_0.line -- 1127
				end -- 1127
			end -- 1127
			local row -- 1127
			do -- 1127
				local _obj_0 = req.body -- 1127
				local _type_1 = type(_obj_0) -- 1127
				if "table" == _type_1 or "userdata" == _type_1 then -- 1127
					row = _obj_0.row -- 1127
				end -- 1127
			end -- 1127
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1127
				local searchPath = getSearchPath(file) -- 1128
				if "tl" == lang or "lua" == lang then -- 1129
					if CheckTIC80Code(content) then -- 1130
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1131
					end -- 1130
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1132
					if signatures then -- 1132
						signatures = getParamDocs(signatures) -- 1133
						if signatures then -- 1133
							return { -- 1134
								success = true, -- 1134
								signatures = signatures -- 1134
							} -- 1134
						end -- 1133
					end -- 1132
				elseif "yue" == lang then -- 1135
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1136
					if not luaCodes then -- 1137
						return { -- 1137
							success = false -- 1137
						} -- 1137
					end -- 1137
					do -- 1138
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1138
						if chainOp then -- 1138
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1139
							if withVar then -- 1139
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1140
							end -- 1139
						end -- 1138
					end -- 1138
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1141
					if signatures then -- 1141
						signatures = getParamDocs(signatures) -- 1142
						if signatures then -- 1142
							return { -- 1143
								success = true, -- 1143
								signatures = signatures -- 1143
							} -- 1143
						end -- 1142
					else -- 1144
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1144
						if signatures then -- 1144
							signatures = getParamDocs(signatures) -- 1145
							if signatures then -- 1145
								return { -- 1146
									success = true, -- 1146
									signatures = signatures -- 1146
								} -- 1146
							end -- 1145
						end -- 1144
					end -- 1141
				end -- 1129
			end -- 1127
		end -- 1127
	end -- 1127
	return { -- 1126
		success = false -- 1126
	} -- 1126
end) -- 1126
local luaKeywords = { -- 1149
	'and', -- 1149
	'break', -- 1150
	'do', -- 1151
	'else', -- 1152
	'elseif', -- 1153
	'end', -- 1154
	'false', -- 1155
	'for', -- 1156
	'function', -- 1157
	'goto', -- 1158
	'if', -- 1159
	'in', -- 1160
	'local', -- 1161
	'nil', -- 1162
	'not', -- 1163
	'or', -- 1164
	'repeat', -- 1165
	'return', -- 1166
	'then', -- 1167
	'true', -- 1168
	'until', -- 1169
	'while' -- 1170
} -- 1148
local tealKeywords = { -- 1174
	'record', -- 1174
	'as', -- 1175
	'is', -- 1176
	'type', -- 1177
	'embed', -- 1178
	'enum', -- 1179
	'global', -- 1180
	'any', -- 1181
	'boolean', -- 1182
	'integer', -- 1183
	'number', -- 1184
	'string', -- 1185
	'thread' -- 1186
} -- 1173
local yueKeywords = { -- 1190
	"and", -- 1190
	"break", -- 1191
	"do", -- 1192
	"else", -- 1193
	"elseif", -- 1194
	"false", -- 1195
	"for", -- 1196
	"goto", -- 1197
	"if", -- 1198
	"in", -- 1199
	"local", -- 1200
	"nil", -- 1201
	"not", -- 1202
	"or", -- 1203
	"repeat", -- 1204
	"return", -- 1205
	"then", -- 1206
	"true", -- 1207
	"until", -- 1208
	"while", -- 1209
	"as", -- 1210
	"class", -- 1211
	"continue", -- 1212
	"export", -- 1213
	"extends", -- 1214
	"from", -- 1215
	"global", -- 1216
	"import", -- 1217
	"macro", -- 1218
	"switch", -- 1219
	"try", -- 1220
	"unless", -- 1221
	"using", -- 1222
	"when", -- 1223
	"with" -- 1224
} -- 1189
local _anon_func_4 = function(f) -- 1260
	local _val_0 = Path:getExt(f) -- 1260
	return "ttf" == _val_0 or "otf" == _val_0 -- 1260
end -- 1260
local _anon_func_5 = function(suggestions) -- 1286
	local _tbl_0 = { } -- 1286
	for _index_0 = 1, #suggestions do -- 1286
		local item = suggestions[_index_0] -- 1286
		_tbl_0[item[1] .. item[2]] = item -- 1286
	end -- 1286
	return _tbl_0 -- 1286
end -- 1286
HttpServer:postSchedule("/complete", function(req) -- 1227
	do -- 1228
		local _type_0 = type(req) -- 1228
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1228
		if _tab_0 then -- 1228
			local lang -- 1228
			do -- 1228
				local _obj_0 = req.body -- 1228
				local _type_1 = type(_obj_0) -- 1228
				if "table" == _type_1 or "userdata" == _type_1 then -- 1228
					lang = _obj_0.lang -- 1228
				end -- 1228
			end -- 1228
			local file -- 1228
			do -- 1228
				local _obj_0 = req.body -- 1228
				local _type_1 = type(_obj_0) -- 1228
				if "table" == _type_1 or "userdata" == _type_1 then -- 1228
					file = _obj_0.file -- 1228
				end -- 1228
			end -- 1228
			local content -- 1228
			do -- 1228
				local _obj_0 = req.body -- 1228
				local _type_1 = type(_obj_0) -- 1228
				if "table" == _type_1 or "userdata" == _type_1 then -- 1228
					content = _obj_0.content -- 1228
				end -- 1228
			end -- 1228
			local line -- 1228
			do -- 1228
				local _obj_0 = req.body -- 1228
				local _type_1 = type(_obj_0) -- 1228
				if "table" == _type_1 or "userdata" == _type_1 then -- 1228
					line = _obj_0.line -- 1228
				end -- 1228
			end -- 1228
			local row -- 1228
			do -- 1228
				local _obj_0 = req.body -- 1228
				local _type_1 = type(_obj_0) -- 1228
				if "table" == _type_1 or "userdata" == _type_1 then -- 1228
					row = _obj_0.row -- 1228
				end -- 1228
			end -- 1228
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1228
				local searchPath = getSearchPath(file) -- 1229
				repeat -- 1230
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1231
					if lang == "yue" then -- 1232
						if not item then -- 1233
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1233
						end -- 1233
						if not item then -- 1234
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1234
						end -- 1234
					end -- 1232
					local searchType = nil -- 1235
					if not item then -- 1236
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1237
						if lang == "yue" then -- 1238
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1239
						end -- 1238
						if (item ~= nil) then -- 1240
							searchType = "Image" -- 1240
						end -- 1240
					end -- 1236
					if not item then -- 1241
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1242
						if lang == "yue" then -- 1243
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1244
						end -- 1243
						if (item ~= nil) then -- 1245
							searchType = "Font" -- 1245
						end -- 1245
					end -- 1241
					if not item then -- 1246
						break -- 1246
					end -- 1246
					local searchPaths = Content.searchPaths -- 1247
					local _list_0 = getSearchFolders(file) -- 1248
					for _index_0 = 1, #_list_0 do -- 1248
						local folder = _list_0[_index_0] -- 1248
						searchPaths[#searchPaths + 1] = folder -- 1249
					end -- 1248
					if searchType then -- 1250
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1250
					end -- 1250
					local tokens -- 1251
					do -- 1251
						local _accum_0 = { } -- 1251
						local _len_0 = 1 -- 1251
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1251
							_accum_0[_len_0] = mod -- 1251
							_len_0 = _len_0 + 1 -- 1251
						end -- 1251
						tokens = _accum_0 -- 1251
					end -- 1251
					local suggestions = { } -- 1252
					for _index_0 = 1, #searchPaths do -- 1253
						local path = searchPaths[_index_0] -- 1253
						local sPath = Path(path, table.unpack(tokens)) -- 1254
						if not Content:exist(sPath) then -- 1255
							goto _continue_0 -- 1255
						end -- 1255
						if searchType == "Font" then -- 1256
							local fontPath = Path(sPath, "Font") -- 1257
							if Content:exist(fontPath) then -- 1258
								local _list_1 = Content:getFiles(fontPath) -- 1259
								for _index_1 = 1, #_list_1 do -- 1259
									local f = _list_1[_index_1] -- 1259
									if _anon_func_4(f) then -- 1260
										if "." == f:sub(1, 1) then -- 1261
											goto _continue_1 -- 1261
										end -- 1261
										suggestions[#suggestions + 1] = { -- 1262
											Path:getName(f), -- 1262
											"font", -- 1262
											"field" -- 1262
										} -- 1262
									end -- 1260
									::_continue_1:: -- 1260
								end -- 1259
							end -- 1258
						end -- 1256
						local _list_1 = Content:getFiles(sPath) -- 1263
						for _index_1 = 1, #_list_1 do -- 1263
							local f = _list_1[_index_1] -- 1263
							if "Image" == searchType then -- 1264
								do -- 1265
									local _exp_0 = Path:getExt(f) -- 1265
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1265
										if "." == f:sub(1, 1) then -- 1266
											goto _continue_2 -- 1266
										end -- 1266
										suggestions[#suggestions + 1] = { -- 1267
											f, -- 1267
											"image", -- 1267
											"field" -- 1267
										} -- 1267
									end -- 1265
								end -- 1265
								goto _continue_2 -- 1268
							elseif "Font" == searchType then -- 1269
								do -- 1270
									local _exp_0 = Path:getExt(f) -- 1270
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1270
										if "." == f:sub(1, 1) then -- 1271
											goto _continue_2 -- 1271
										end -- 1271
										suggestions[#suggestions + 1] = { -- 1272
											f, -- 1272
											"font", -- 1272
											"field" -- 1272
										} -- 1272
									end -- 1270
								end -- 1270
								goto _continue_2 -- 1273
							end -- 1264
							local _exp_0 = Path:getExt(f) -- 1274
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1274
								local name = Path:getName(f) -- 1275
								if "d" == Path:getExt(name) then -- 1276
									goto _continue_2 -- 1276
								end -- 1276
								if "." == name:sub(1, 1) then -- 1277
									goto _continue_2 -- 1277
								end -- 1277
								suggestions[#suggestions + 1] = { -- 1278
									name, -- 1278
									"module", -- 1278
									"field" -- 1278
								} -- 1278
							end -- 1274
							::_continue_2:: -- 1264
						end -- 1263
						local _list_2 = Content:getDirs(sPath) -- 1279
						for _index_1 = 1, #_list_2 do -- 1279
							local dir = _list_2[_index_1] -- 1279
							if "." == dir:sub(1, 1) then -- 1280
								goto _continue_3 -- 1280
							end -- 1280
							suggestions[#suggestions + 1] = { -- 1281
								dir, -- 1281
								"folder", -- 1281
								"variable" -- 1281
							} -- 1281
							::_continue_3:: -- 1280
						end -- 1279
						::_continue_0:: -- 1254
					end -- 1253
					if item == "" and not searchType then -- 1282
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1283
						for _index_0 = 1, #_list_1 do -- 1283
							local _des_0 = _list_1[_index_0] -- 1283
							local name = _des_0[1] -- 1283
							suggestions[#suggestions + 1] = { -- 1284
								name, -- 1284
								"dora module", -- 1284
								"function" -- 1284
							} -- 1284
						end -- 1283
					end -- 1282
					if #suggestions > 0 then -- 1285
						do -- 1286
							local _accum_0 = { } -- 1286
							local _len_0 = 1 -- 1286
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1286
								_accum_0[_len_0] = v -- 1286
								_len_0 = _len_0 + 1 -- 1286
							end -- 1286
							suggestions = _accum_0 -- 1286
						end -- 1286
						return { -- 1287
							success = true, -- 1287
							suggestions = suggestions -- 1287
						} -- 1287
					else -- 1289
						return { -- 1289
							success = false -- 1289
						} -- 1289
					end -- 1285
				until true -- 1230
				if "tl" == lang or "lua" == lang then -- 1291
					do -- 1292
						local isTIC80 = CheckTIC80Code(content) -- 1292
						if isTIC80 then -- 1292
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1293
						end -- 1292
					end -- 1292
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1294
					if not line:match("[%.:]$") then -- 1295
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
						for _index_0 = 1, #luaKeywords do -- 1299
							local word = luaKeywords[_index_0] -- 1299
							suggestions[#suggestions + 1] = { -- 1300
								word, -- 1300
								"keyword", -- 1300
								"keyword" -- 1300
							} -- 1300
						end -- 1299
						if lang == "tl" then -- 1301
							for _index_0 = 1, #tealKeywords do -- 1302
								local word = tealKeywords[_index_0] -- 1302
								suggestions[#suggestions + 1] = { -- 1303
									word, -- 1303
									"keyword", -- 1303
									"keyword" -- 1303
								} -- 1303
							end -- 1302
						end -- 1301
					end -- 1295
					if #suggestions > 0 then -- 1304
						return { -- 1305
							success = true, -- 1305
							suggestions = suggestions -- 1305
						} -- 1305
					end -- 1304
				elseif "yue" == lang then -- 1306
					local suggestions = { } -- 1307
					local gotGlobals = false -- 1308
					do -- 1309
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1309
						if luaCodes then -- 1309
							gotGlobals = true -- 1310
							do -- 1311
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1311
								if chainOp then -- 1311
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1312
									if not withVar then -- 1313
										return { -- 1313
											success = false -- 1313
										} -- 1313
									end -- 1313
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1314
								elseif line:match("^([%.\\])$") then -- 1315
									return { -- 1316
										success = false -- 1316
									} -- 1316
								end -- 1311
							end -- 1311
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1317
							for _index_0 = 1, #_list_0 do -- 1317
								local item = _list_0[_index_0] -- 1317
								suggestions[#suggestions + 1] = item -- 1317
							end -- 1317
							if #suggestions == 0 then -- 1318
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1319
								for _index_0 = 1, #_list_1 do -- 1319
									local item = _list_1[_index_0] -- 1319
									suggestions[#suggestions + 1] = item -- 1319
								end -- 1319
							end -- 1318
						end -- 1309
					end -- 1309
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1320
						local checkSet -- 1321
						do -- 1321
							local _tbl_0 = { } -- 1321
							for _index_0 = 1, #suggestions do -- 1321
								local _des_0 = suggestions[_index_0] -- 1321
								local name = _des_0[1] -- 1321
								_tbl_0[name] = true -- 1321
							end -- 1321
							checkSet = _tbl_0 -- 1321
						end -- 1321
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1322
						for _index_0 = 1, #_list_0 do -- 1322
							local item = _list_0[_index_0] -- 1322
							if not checkSet[item[1]] then -- 1323
								suggestions[#suggestions + 1] = item -- 1323
							end -- 1323
						end -- 1322
						if not gotGlobals then -- 1324
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1325
							for _index_0 = 1, #_list_1 do -- 1325
								local item = _list_1[_index_0] -- 1325
								if not checkSet[item[1]] then -- 1326
									suggestions[#suggestions + 1] = item -- 1326
								end -- 1326
							end -- 1325
						end -- 1324
						for _index_0 = 1, #yueKeywords do -- 1327
							local word = yueKeywords[_index_0] -- 1327
							if not checkSet[word] then -- 1328
								suggestions[#suggestions + 1] = { -- 1329
									word, -- 1329
									"keyword", -- 1329
									"keyword" -- 1329
								} -- 1329
							end -- 1328
						end -- 1327
					end -- 1320
					if #suggestions > 0 then -- 1330
						return { -- 1331
							success = true, -- 1331
							suggestions = suggestions -- 1331
						} -- 1331
					end -- 1330
				elseif "xml" == lang then -- 1332
					local items = xml.complete(content) -- 1333
					if #items > 0 then -- 1334
						local suggestions -- 1335
						do -- 1335
							local _accum_0 = { } -- 1335
							local _len_0 = 1 -- 1335
							for _index_0 = 1, #items do -- 1335
								local _des_0 = items[_index_0] -- 1335
								local label, insertText = _des_0[1], _des_0[2] -- 1335
								_accum_0[_len_0] = { -- 1336
									label, -- 1336
									insertText, -- 1336
									"field" -- 1336
								} -- 1336
								_len_0 = _len_0 + 1 -- 1336
							end -- 1335
							suggestions = _accum_0 -- 1335
						end -- 1335
						return { -- 1337
							success = true, -- 1337
							suggestions = suggestions -- 1337
						} -- 1337
					end -- 1334
				end -- 1291
			end -- 1228
		end -- 1228
	end -- 1228
	return { -- 1227
		success = false -- 1227
	} -- 1227
end) -- 1227
HttpServer:upload("/upload", function(req, filename) -- 1341
	do -- 1342
		local _type_0 = type(req) -- 1342
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1342
		if _tab_0 then -- 1342
			local path -- 1342
			do -- 1342
				local _obj_0 = req.params -- 1342
				local _type_1 = type(_obj_0) -- 1342
				if "table" == _type_1 or "userdata" == _type_1 then -- 1342
					path = _obj_0.path -- 1342
				end -- 1342
			end -- 1342
			if path ~= nil then -- 1342
				local uploadPath = Path(Content.writablePath, ".upload") -- 1343
				if not Content:exist(uploadPath) then -- 1344
					Content:mkdir(uploadPath) -- 1345
				end -- 1344
				local targetPath = Path(uploadPath, filename) -- 1346
				Content:mkdir(Path:getPath(targetPath)) -- 1347
				return targetPath -- 1348
			end -- 1342
		end -- 1342
	end -- 1342
	return nil -- 1341
end, function(req, file) -- 1349
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
				path = Path(Content.writablePath, path) -- 1351
				if Content:exist(path) then -- 1352
					local uploadPath = Path(Content.writablePath, ".upload") -- 1353
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1354
					Content:mkdir(Path:getPath(targetPath)) -- 1355
					if Content:move(file, targetPath) then -- 1356
						return true -- 1357
					end -- 1356
				end -- 1352
			end -- 1350
		end -- 1350
	end -- 1350
	return false -- 1349
end) -- 1339
HttpServer:post("/list", function(req) -- 1360
	do -- 1361
		local _type_0 = type(req) -- 1361
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1361
		if _tab_0 then -- 1361
			local path -- 1361
			do -- 1361
				local _obj_0 = req.body -- 1361
				local _type_1 = type(_obj_0) -- 1361
				if "table" == _type_1 or "userdata" == _type_1 then -- 1361
					path = _obj_0.path -- 1361
				end -- 1361
			end -- 1361
			if path ~= nil then -- 1361
				if Content:exist(path) then -- 1362
					local files = { } -- 1363
					local visitAssets -- 1364
					visitAssets = function(path, folder) -- 1364
						local dirs = Content:getDirs(path) -- 1365
						for _index_0 = 1, #dirs do -- 1366
							local dir = dirs[_index_0] -- 1366
							if dir:match("^%.") or dir == "node_modules" then -- 1367
								goto _continue_0 -- 1367
							end -- 1367
							local current -- 1368
							if folder == "" then -- 1368
								current = dir -- 1369
							else -- 1371
								current = Path(folder, dir) -- 1371
							end -- 1368
							files[#files + 1] = current -- 1372
							visitAssets(Path(path, dir), current) -- 1373
							::_continue_0:: -- 1367
						end -- 1366
						local fs = Content:getFiles(path) -- 1374
						for _index_0 = 1, #fs do -- 1375
							local f = fs[_index_0] -- 1375
							if (".DS_Store" == f) then -- 1376
								goto _continue_1 -- 1377
							end -- 1376
							if folder == "" then -- 1378
								files[#files + 1] = f -- 1379
							else -- 1381
								files[#files + 1] = Path(folder, f) -- 1381
							end -- 1378
							::_continue_1:: -- 1376
						end -- 1375
					end -- 1364
					visitAssets(path, "") -- 1382
					if #files == 0 then -- 1383
						files = nil -- 1383
					end -- 1383
					return { -- 1384
						success = true, -- 1384
						files = files -- 1384
					} -- 1384
				end -- 1362
			end -- 1361
		end -- 1361
	end -- 1361
	return { -- 1360
		success = false -- 1360
	} -- 1360
end) -- 1360
HttpServer:post("/info", function(req) -- 1386
	local Entry = require("Script.Dev.Entry") -- 1387
	local config = Entry.getConfig() -- 1388
	do -- 1389
		local _type_0 = type(req) -- 1389
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1389
		if _tab_0 then -- 1389
			local webIDETourCompleted -- 1389
			do -- 1389
				local _obj_0 = req.body -- 1389
				local _type_1 = type(_obj_0) -- 1389
				if "table" == _type_1 or "userdata" == _type_1 then -- 1389
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1389
				end -- 1389
			end -- 1389
			if webIDETourCompleted ~= nil then -- 1389
				config.webIDETourCompleted = webIDETourCompleted == true -- 1390
			end -- 1389
		end -- 1389
	end -- 1389
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1391
	local engineDev = Entry.getEngineDev() -- 1392
	Entry.connectWebIDE() -- 1393
	return { -- 1395
		platform = App.platform, -- 1395
		locale = App.locale, -- 1396
		version = App.version, -- 1397
		engineDev = engineDev, -- 1398
		webProfiler = webProfiler, -- 1399
		drawerWidth = drawerWidth, -- 1400
		webIDETourCompleted = webIDETourCompleted == true -- 1401
	} -- 1394
end) -- 1386
local ensureLLMConfigTable -- 1403
ensureLLMConfigTable = function() -- 1403
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1404
	if columns and #columns > 0 then -- 1405
		local expected = { -- 1407
			id = true, -- 1407
			name = true, -- 1408
			url = true, -- 1409
			model = true, -- 1410
			api_key = true, -- 1411
			context_window = true, -- 1412
			temperature = true, -- 1413
			max_tokens = true, -- 1414
			reasoning_effort = true, -- 1415
			custom_options = true, -- 1416
			supports_function_calling = true, -- 1417
			active = true, -- 1418
			created_at = true, -- 1419
			updated_at = true -- 1420
		} -- 1406
		local existing = { } -- 1422
		local valid = true -- 1423
		for _index_0 = 1, #columns do -- 1424
			local row = columns[_index_0] -- 1424
			local columnName = tostring(row[2]) -- 1425
			existing[columnName] = true -- 1426
			if not expected[columnName] then -- 1427
				valid = false -- 1428
				break -- 1429
			end -- 1427
		end -- 1424
		if valid then -- 1430
			if not existing.context_window then -- 1431
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1432
			end -- 1431
			if not existing.temperature then -- 1433
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1434
			end -- 1433
			if not existing.max_tokens then -- 1435
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 1436
			end -- 1435
			if not existing.reasoning_effort then -- 1437
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1438
			end -- 1437
			if not existing.custom_options then -- 1439
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1440
			end -- 1439
			if not existing.supports_function_calling then -- 1441
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1442
			end -- 1441
		else -- 1444
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1444
		end -- 1430
	end -- 1405
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
	]]) -- 1445
end -- 1403
local normalizeContextWindow -- 1464
normalizeContextWindow = function(value) -- 1464
	local contextWindow = tonumber(value) -- 1465
	if contextWindow == nil or contextWindow < 64000 then -- 1466
		return 64000 -- 1467
	end -- 1466
	return math.max(64000, math.floor(contextWindow)) -- 1468
end -- 1464
local normalizeTemperature -- 1470
normalizeTemperature = function(value) -- 1470
	local temperature = tonumber(value) -- 1471
	if temperature == nil then -- 1472
		return 0.1 -- 1473
	end -- 1472
	return math.max(0, math.min(2, temperature)) -- 1474
end -- 1470
local normalizeMaxTokens -- 1476
normalizeMaxTokens = function(value) -- 1476
	local maxTokens = tonumber(value) -- 1477
	if maxTokens == nil or maxTokens < 1 then -- 1478
		return 8192 -- 1479
	end -- 1478
	return math.max(1, math.floor(maxTokens)) -- 1480
end -- 1476
local normalizeReasoningEffort -- 1482
normalizeReasoningEffort = function(value) -- 1482
	if value == nil then -- 1483
		return "" -- 1484
	end -- 1483
	local effort = tostring(value) -- 1485
	return effort:match("^%s*(.-)%s*$") or "" -- 1486
end -- 1482
local normalizeCustomOptions -- 1488
normalizeCustomOptions = function(value) -- 1488
	if value == nil then -- 1489
		return "" -- 1490
	end -- 1489
	local options = tostring(value) -- 1491
	options = options:match("^%s*(.-)%s*$") or "" -- 1492
	return options -- 1493
end -- 1488
local validateCustomOptions -- 1495
validateCustomOptions = function(value) -- 1495
	local options = normalizeCustomOptions(value) -- 1496
	if options == "" then -- 1497
		return true -- 1497
	end -- 1497
	if not options:match("^%s*{") then -- 1498
		return false -- 1498
	end -- 1498
	local decoded = json.decode(options) -- 1499
	return type(decoded) == "table" -- 1500
end -- 1495
HttpServer:post("/llm/list", function() -- 1502
	ensureLLMConfigTable() -- 1503
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1504
	local items -- 1508
	if rows and #rows > 0 then -- 1508
		local _accum_0 = { } -- 1509
		local _len_0 = 1 -- 1509
		for _index_0 = 1, #rows do -- 1509
			local _des_0 = rows[_index_0] -- 1509
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1509
			_accum_0[_len_0] = { -- 1510
				id = id, -- 1510
				name = name, -- 1510
				url = url, -- 1510
				model = model, -- 1510
				key = key, -- 1510
				contextWindow = normalizeContextWindow(contextWindow), -- 1510
				temperature = normalizeTemperature(temperature), -- 1510
				maxTokens = normalizeMaxTokens(maxTokens), -- 1510
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1510
				customOptions = normalizeCustomOptions(customOptions), -- 1510
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1510
			} -- 1510
			_len_0 = _len_0 + 1 -- 1510
		end -- 1509
		items = _accum_0 -- 1508
	end -- 1508
	return { -- 1511
		success = true, -- 1511
		items = items -- 1511
	} -- 1511
end) -- 1502
HttpServer:post("/llm/create", function(req) -- 1513
	ensureLLMConfigTable() -- 1514
	do -- 1515
		local _type_0 = type(req) -- 1515
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1515
		if _tab_0 then -- 1515
			local body = req.body -- 1515
			if body ~= nil then -- 1515
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1516
				local now = os.time() -- 1517
				if name == nil or url == nil or model == nil or key == nil then -- 1518
					return invalidArguments -- 1519
				end -- 1518
				contextWindow = normalizeContextWindow(contextWindow) -- 1520
				temperature = normalizeTemperature(temperature) -- 1521
				maxTokens = normalizeMaxTokens(maxTokens) -- 1522
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1523
				customOptions = normalizeCustomOptions(customOptions) -- 1524
				if not validateCustomOptions(customOptions) then -- 1525
					return { -- 1525
						success = false, -- 1525
						message = "customOptions must be a JSON object" -- 1525
					} -- 1525
				end -- 1525
				if supportsFunctionCalling == false then -- 1526
					supportsFunctionCalling = 0 -- 1526
				else -- 1526
					supportsFunctionCalling = 1 -- 1526
				end -- 1526
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1533
					tostring(name), -- 1533
					tostring(url), -- 1534
					tostring(model), -- 1535
					tostring(key), -- 1536
					contextWindow, -- 1537
					temperature, -- 1538
					maxTokens, -- 1539
					reasoningEffort, -- 1540
					customOptions, -- 1541
					supportsFunctionCalling, -- 1542
					1, -- 1543
					now, -- 1544
					now -- 1545
				}) -- 1527
				return { -- 1547
					success = affected >= 0 -- 1547
				} -- 1547
			end -- 1515
		end -- 1515
	end -- 1515
	return invalidArguments -- 1513
end) -- 1513
HttpServer:post("/llm/update", function(req) -- 1549
	ensureLLMConfigTable() -- 1550
	do -- 1551
		local _type_0 = type(req) -- 1551
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1551
		if _tab_0 then -- 1551
			local body = req.body -- 1551
			if body ~= nil then -- 1551
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1552
				local now = os.time() -- 1553
				id = tonumber(id) -- 1554
				if id == nil then -- 1555
					return invalidArguments -- 1555
				end -- 1555
				contextWindow = normalizeContextWindow(contextWindow) -- 1556
				temperature = normalizeTemperature(temperature) -- 1557
				maxTokens = normalizeMaxTokens(maxTokens) -- 1558
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1559
				customOptions = normalizeCustomOptions(customOptions) -- 1560
				if not validateCustomOptions(customOptions) then -- 1561
					return { -- 1561
						success = false, -- 1561
						message = "customOptions must be a JSON object" -- 1561
					} -- 1561
				end -- 1561
				if supportsFunctionCalling == false then -- 1562
					supportsFunctionCalling = 0 -- 1562
				else -- 1562
					supportsFunctionCalling = 1 -- 1562
				end -- 1562
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1567
					tostring(name), -- 1567
					tostring(url), -- 1568
					tostring(model), -- 1569
					tostring(key), -- 1570
					contextWindow, -- 1571
					temperature, -- 1572
					maxTokens, -- 1573
					reasoningEffort, -- 1574
					customOptions, -- 1575
					supportsFunctionCalling, -- 1576
					now, -- 1577
					id -- 1578
				}) -- 1563
				return { -- 1580
					success = affected >= 0 -- 1580
				} -- 1580
			end -- 1551
		end -- 1551
	end -- 1551
	return invalidArguments -- 1549
end) -- 1549
HttpServer:post("/llm/delete", function(req) -- 1582
	ensureLLMConfigTable() -- 1583
	do -- 1584
		local _type_0 = type(req) -- 1584
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1584
		if _tab_0 then -- 1584
			local id -- 1584
			do -- 1584
				local _obj_0 = req.body -- 1584
				local _type_1 = type(_obj_0) -- 1584
				if "table" == _type_1 or "userdata" == _type_1 then -- 1584
					id = _obj_0.id -- 1584
				end -- 1584
			end -- 1584
			if id ~= nil then -- 1584
				id = tonumber(id) -- 1585
				if id == nil then -- 1586
					return invalidArguments -- 1586
				end -- 1586
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1587
					id -- 1587
				}) -- 1587
				return { -- 1588
					success = affected >= 0 -- 1588
				} -- 1588
			end -- 1584
		end -- 1584
	end -- 1584
	return invalidArguments -- 1582
end) -- 1582
HttpServer:post("/stat", function(req) -- 1590
	do -- 1591
		local _type_0 = type(req) -- 1591
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1591
		if _tab_0 then -- 1591
			local path -- 1591
			do -- 1591
				local _obj_0 = req.body -- 1591
				local _type_1 = type(_obj_0) -- 1591
				if "table" == _type_1 or "userdata" == _type_1 then -- 1591
					path = _obj_0.path -- 1591
				end -- 1591
			end -- 1591
			if path ~= nil then -- 1591
				if not Content:exist(path) then -- 1592
					return { -- 1593
						success = false, -- 1593
						message = "target not existed" -- 1593
					} -- 1593
				end -- 1592
				if Content:isdir(path) then -- 1594
					return { -- 1595
						success = false, -- 1595
						message = "failed to stat a directory" -- 1595
					} -- 1595
				end -- 1594
				local size, isBinary = Content:getAttr(path) -- 1596
				if size then -- 1596
					return { -- 1597
						success = true, -- 1597
						size = size, -- 1597
						isBinary = isBinary -- 1597
					} -- 1597
				end -- 1596
			end -- 1591
		end -- 1591
	end -- 1591
	return { -- 1590
		success = false, -- 1590
		message = "failed to stat" -- 1590
	} -- 1590
end) -- 1590
HttpServer:post("/new", function(req) -- 1599
	do -- 1600
		local _type_0 = type(req) -- 1600
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1600
		if _tab_0 then -- 1600
			local path -- 1600
			do -- 1600
				local _obj_0 = req.body -- 1600
				local _type_1 = type(_obj_0) -- 1600
				if "table" == _type_1 or "userdata" == _type_1 then -- 1600
					path = _obj_0.path -- 1600
				end -- 1600
			end -- 1600
			local content -- 1600
			do -- 1600
				local _obj_0 = req.body -- 1600
				local _type_1 = type(_obj_0) -- 1600
				if "table" == _type_1 or "userdata" == _type_1 then -- 1600
					content = _obj_0.content -- 1600
				end -- 1600
			end -- 1600
			local folder -- 1600
			do -- 1600
				local _obj_0 = req.body -- 1600
				local _type_1 = type(_obj_0) -- 1600
				if "table" == _type_1 or "userdata" == _type_1 then -- 1600
					folder = _obj_0.folder -- 1600
				end -- 1600
			end -- 1600
			if path ~= nil and content ~= nil and folder ~= nil then -- 1600
				if Content:exist(path) then -- 1601
					return { -- 1602
						success = false, -- 1602
						message = "TargetExisted" -- 1602
					} -- 1602
				end -- 1601
				local parent = Path:getPath(path) -- 1603
				local files = Content:getFiles(parent) -- 1604
				if folder then -- 1605
					local name = Path:getFilename(path):lower() -- 1606
					for _index_0 = 1, #files do -- 1607
						local file = files[_index_0] -- 1607
						if name == Path:getFilename(file):lower() then -- 1608
							return { -- 1609
								success = false, -- 1609
								message = "TargetExisted" -- 1609
							} -- 1609
						end -- 1608
					end -- 1607
					if Content:mkdir(path) then -- 1610
						return { -- 1611
							success = true -- 1611
						} -- 1611
					end -- 1610
				else -- 1613
					local name = Path:getName(path):lower() -- 1613
					for _index_0 = 1, #files do -- 1614
						local file = files[_index_0] -- 1614
						if name == Path:getName(file):lower() then -- 1615
							local ext = Path:getExt(file) -- 1616
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1617
								goto _continue_0 -- 1618
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1619
								goto _continue_0 -- 1620
							end -- 1617
							return { -- 1621
								success = false, -- 1621
								message = "SourceExisted" -- 1621
							} -- 1621
						end -- 1615
						::_continue_0:: -- 1615
					end -- 1614
					if Content:save(path, content) then -- 1622
						return { -- 1623
							success = true -- 1623
						} -- 1623
					end -- 1622
				end -- 1605
			end -- 1600
		end -- 1600
	end -- 1600
	return { -- 1599
		success = false, -- 1599
		message = "Failed" -- 1599
	} -- 1599
end) -- 1599
local deleteAsset -- 1625
deleteAsset = function(path) -- 1625
	if not Content:exist(path) then -- 1626
		return false -- 1626
	end -- 1626
	local projectRoot -- 1627
	if Content:isdir(path) and isProjectRootDir(path) then -- 1627
		projectRoot = path -- 1627
	else -- 1627
		projectRoot = nil -- 1627
	end -- 1627
	local parent = Path:getPath(path) -- 1628
	local files = Content:getFiles(parent) -- 1629
	local name = Path:getName(path):lower() -- 1630
	local ext = Path:getExt(path) -- 1631
	for _index_0 = 1, #files do -- 1632
		local file = files[_index_0] -- 1632
		if name == Path:getName(file):lower() then -- 1633
			local _exp_0 = Path:getExt(file) -- 1634
			if "tl" == _exp_0 then -- 1634
				if ("vs" == ext) then -- 1634
					Content:remove(Path(parent, file)) -- 1635
				end -- 1634
			elseif "lua" == _exp_0 then -- 1636
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1636
					Content:remove(Path(parent, file)) -- 1637
				end -- 1636
			end -- 1634
		end -- 1633
	end -- 1632
	if Content:remove(path) then -- 1638
		if projectRoot then -- 1639
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1640
		end -- 1639
		return true -- 1641
	end -- 1638
	return false -- 1642
end -- 1625
local moveAsset -- 1644
moveAsset = function(old, new) -- 1644
	if not (Content:exist(old) and not Content:exist(new)) then -- 1645
		return false -- 1645
	end -- 1645
	local renamedDir = Content:isdir(old) -- 1646
	local parent = Path:getPath(new) -- 1647
	local files = Content:getFiles(parent) -- 1648
	if renamedDir then -- 1649
		local name = Path:getFilename(new):lower() -- 1650
		for _index_0 = 1, #files do -- 1651
			local file = files[_index_0] -- 1651
			if name == Path:getFilename(file):lower() then -- 1652
				return false -- 1653
			end -- 1652
		end -- 1651
	else -- 1655
		local name = Path:getName(new):lower() -- 1655
		local ext = Path:getExt(new) -- 1656
		for _index_0 = 1, #files do -- 1657
			local file = files[_index_0] -- 1657
			if name == Path:getName(file):lower() then -- 1658
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1659
					goto _continue_0 -- 1660
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1661
					goto _continue_0 -- 1662
				end -- 1659
				return false -- 1663
			end -- 1658
			::_continue_0:: -- 1658
		end -- 1657
	end -- 1649
	if not Content:move(old, new) then -- 1664
		return false -- 1664
	end -- 1664
	if renamedDir then -- 1665
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1666
	end -- 1665
	local newParent = Path:getPath(new) -- 1667
	parent = Path:getPath(old) -- 1668
	files = Content:getFiles(parent) -- 1669
	local newName = Path:getName(new) -- 1670
	local oldName = Path:getName(old) -- 1671
	local name = oldName:lower() -- 1672
	local ext = Path:getExt(old) -- 1673
	for _index_0 = 1, #files do -- 1674
		local file = files[_index_0] -- 1674
		if name == Path:getName(file):lower() then -- 1675
			local _exp_0 = Path:getExt(file) -- 1676
			if "tl" == _exp_0 then -- 1676
				if ("vs" == ext) then -- 1676
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1677
				end -- 1676
			elseif "lua" == _exp_0 then -- 1678
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1678
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1679
				end -- 1678
			end -- 1676
		end -- 1675
	end -- 1674
	return true -- 1680
end -- 1644
HttpServer:post("/delete", function(req) -- 1682
	do -- 1683
		local _type_0 = type(req) -- 1683
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1683
		if _tab_0 then -- 1683
			local path -- 1683
			do -- 1683
				local _obj_0 = req.body -- 1683
				local _type_1 = type(_obj_0) -- 1683
				if "table" == _type_1 or "userdata" == _type_1 then -- 1683
					path = _obj_0.path -- 1683
				end -- 1683
			end -- 1683
			if path ~= nil then -- 1683
				if deleteAsset(path) then -- 1684
					return { -- 1684
						success = true -- 1684
					} -- 1684
				end -- 1684
			end -- 1683
		end -- 1683
	end -- 1683
	return { -- 1682
		success = false -- 1682
	} -- 1682
end) -- 1682
HttpServer:post("/rename", function(req) -- 1686
	do -- 1687
		local _type_0 = type(req) -- 1687
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1687
		if _tab_0 then -- 1687
			local old -- 1687
			do -- 1687
				local _obj_0 = req.body -- 1687
				local _type_1 = type(_obj_0) -- 1687
				if "table" == _type_1 or "userdata" == _type_1 then -- 1687
					old = _obj_0.old -- 1687
				end -- 1687
			end -- 1687
			local new -- 1687
			do -- 1687
				local _obj_0 = req.body -- 1687
				local _type_1 = type(_obj_0) -- 1687
				if "table" == _type_1 or "userdata" == _type_1 then -- 1687
					new = _obj_0.new -- 1687
				end -- 1687
			end -- 1687
			if old ~= nil and new ~= nil then -- 1687
				if moveAsset(old, new) then -- 1688
					return { -- 1688
						success = true -- 1688
					} -- 1688
				end -- 1688
			end -- 1687
		end -- 1687
	end -- 1687
	return { -- 1686
		success = false -- 1686
	} -- 1686
end) -- 1686
local normalizeAssetPaths -- 1690
normalizeAssetPaths = function(paths) -- 1690
	if not (type(paths) == "table") then -- 1691
		return nil -- 1691
	end -- 1691
	local unique = { } -- 1692
	local candidates = { } -- 1693
	for _index_0 = 1, #paths do -- 1694
		local path = paths[_index_0] -- 1694
		if not (type(path) == "string") then -- 1695
			return nil -- 1695
		end -- 1695
		local relative = relativeToRoot(path, Content.writablePath) -- 1696
		if relative == nil or relative == "" or not Content:exist(path) then -- 1697
			return nil -- 1697
		end -- 1697
		if not unique[path] then -- 1698
			unique[path] = true -- 1699
			candidates[#candidates + 1] = path -- 1700
		end -- 1698
	end -- 1694
	table.sort(candidates, function(a, b) -- 1701
		return #a < #b -- 1701
	end) -- 1701
	local result = { } -- 1702
	for _index_0 = 1, #candidates do -- 1703
		local path = candidates[_index_0] -- 1703
		local contained = false -- 1704
		for _index_1 = 1, #result do -- 1705
			local parent = result[_index_1] -- 1705
			if relativeToRoot(path, parent) ~= nil then -- 1706
				contained = true -- 1707
				break -- 1708
			end -- 1706
		end -- 1705
		if not contained then -- 1709
			result[#result + 1] = path -- 1709
		end -- 1709
	end -- 1703
	return result -- 1710
end -- 1690
HttpServer:postSchedule("/assets/batch", function(req) -- 1712
	do -- 1713
		local _type_0 = type(req) -- 1713
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1713
		if _tab_0 then -- 1713
			local operation -- 1713
			do -- 1713
				local _obj_0 = req.body -- 1713
				local _type_1 = type(_obj_0) -- 1713
				if "table" == _type_1 or "userdata" == _type_1 then -- 1713
					operation = _obj_0.operation -- 1713
				end -- 1713
			end -- 1713
			local sources -- 1713
			do -- 1713
				local _obj_0 = req.body -- 1713
				local _type_1 = type(_obj_0) -- 1713
				if "table" == _type_1 or "userdata" == _type_1 then -- 1713
					sources = _obj_0.sources -- 1713
				end -- 1713
			end -- 1713
			if operation ~= nil and sources ~= nil then -- 1713
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1714
					return { -- 1714
						success = false, -- 1714
						message = "invalid operation" -- 1714
					} -- 1714
				end -- 1714
				sources = normalizeAssetPaths(sources) -- 1715
				if not (sources and #sources > 0) then -- 1716
					return { -- 1716
						success = false, -- 1716
						message = "invalid sources" -- 1716
					} -- 1716
				end -- 1716
				local target = req.body.target -- 1717
				local destinations = { } -- 1718
				if operation ~= "delete" then -- 1719
					if not (type(target) == "string") then -- 1720
						return { -- 1720
							success = false, -- 1720
							message = "invalid target" -- 1720
						} -- 1720
					end -- 1720
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1721
					if targetRelative == nil then -- 1722
						return { -- 1722
							success = false, -- 1722
							message = "invalid target" -- 1722
						} -- 1722
					end -- 1722
					if not (Content:exist(target) and Content:isdir(target)) then -- 1723
						return { -- 1723
							success = false, -- 1723
							message = "invalid target" -- 1723
						} -- 1723
					end -- 1723
					for _index_0 = 1, #sources do -- 1724
						local source = sources[_index_0] -- 1724
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1725
							return { -- 1726
								success = false, -- 1726
								message = "target inside source" -- 1726
							} -- 1726
						end -- 1725
						local destination = Path(target, Path:getFilename(source)) -- 1727
						if Content:exist(destination) then -- 1728
							return { -- 1728
								success = false, -- 1728
								message = "target existed" -- 1728
							} -- 1728
						end -- 1728
						if destinations[destination] then -- 1729
							return { -- 1729
								success = false, -- 1729
								message = "duplicate target" -- 1729
							} -- 1729
						end -- 1729
						destinations[destination] = true -- 1730
					end -- 1724
				end -- 1719
				local changes = { } -- 1731
				local affectedSet = { } -- 1732
				local affectedDirectories = { } -- 1733
				local addAffected -- 1734
				addAffected = function(dir) -- 1734
					if affectedSet[dir] then -- 1735
						return -- 1735
					end -- 1735
					affectedSet[dir] = true -- 1736
					affectedDirectories[#affectedDirectories + 1] = dir -- 1737
				end -- 1734
				if operation ~= "delete" then -- 1738
					addAffected(target) -- 1738
				end -- 1738
				for _index_0 = 1, #sources do -- 1739
					local source = sources[_index_0] -- 1739
					addAffected(Path:getPath(source)) -- 1740
					if operation == "delete" then -- 1741
						if not deleteAsset(source) then -- 1742
							return { -- 1742
								success = false, -- 1742
								message = "delete failed", -- 1742
								changes = changes, -- 1742
								affectedDirectories = affectedDirectories -- 1742
							} -- 1742
						end -- 1742
						changes[#changes + 1] = { -- 1743
							old = source -- 1743
						} -- 1743
					else -- 1745
						local destination = Path(target, Path:getFilename(source)) -- 1745
						local ok -- 1746
						if operation == "copy" then -- 1746
							ok = Content:copyAsync(source, destination) -- 1747
						else -- 1749
							ok = moveAsset(source, destination) -- 1749
						end -- 1746
						if not ok then -- 1750
							return { -- 1750
								success = false, -- 1750
								message = operation .. " failed", -- 1750
								changes = changes, -- 1750
								affectedDirectories = affectedDirectories -- 1750
							} -- 1750
						end -- 1750
						changes[#changes + 1] = { -- 1751
							old = source, -- 1751
							new = destination -- 1751
						} -- 1751
					end -- 1741
				end -- 1739
				return { -- 1752
					success = true, -- 1752
					changes = changes, -- 1752
					affectedDirectories = affectedDirectories -- 1752
				} -- 1752
			end -- 1713
		end -- 1713
	end -- 1713
	return { -- 1712
		success = false, -- 1712
		message = "invalid request" -- 1712
	} -- 1712
end) -- 1712
local withProjectSearchPaths -- 1754
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1754
	local fallbackPaths = { } -- 1755
	local addFallback -- 1756
	addFallback = function(dir) -- 1756
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1756
			fallbackPaths[#fallbackPaths + 1] = dir -- 1756
		end -- 1756
	end -- 1756
	if projectRoot and projectRoot ~= "" then -- 1757
		addFallback(Path(projectRoot, "Script")) -- 1758
		addFallback(projectRoot) -- 1759
	end -- 1757
	if projFile then -- 1760
		local projDir = getProjectDirFromFile(projFile) -- 1761
		if projDir then -- 1761
			addFallback(Path(projDir, "Script")) -- 1762
			addFallback(projDir) -- 1763
		else -- 1765
			addFallback(Path:getPath(projFile)) -- 1765
		end -- 1761
	end -- 1760
	if not (#fallbackPaths > 0) then -- 1766
		return fn() -- 1766
	end -- 1766
	local searchPaths = Content.searchPaths -- 1767
	for _index_0 = 1, #fallbackPaths do -- 1768
		local dir = fallbackPaths[_index_0] -- 1768
		Content:addSearchPath(dir) -- 1768
	end -- 1768
	local _ <close> = setmetatable({ }, { -- 1769
		__close = function() -- 1769
			Content.searchPaths = searchPaths -- 1769
		end -- 1769
	}) -- 1769
	return fn() -- 1770
end -- 1754
HttpServer:post("/exist", function(req) -- 1771
	do -- 1772
		local _type_0 = type(req) -- 1772
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1772
		if _tab_0 then -- 1772
			local file -- 1772
			do -- 1772
				local _obj_0 = req.body -- 1772
				local _type_1 = type(_obj_0) -- 1772
				if "table" == _type_1 or "userdata" == _type_1 then -- 1772
					file = _obj_0.file -- 1772
				end -- 1772
			end -- 1772
			if file ~= nil then -- 1772
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1773
					return { -- 1774
						success = Content:exist(file) -- 1774
					} -- 1774
				end) -- 1773
			end -- 1772
		end -- 1772
	end -- 1772
	return { -- 1771
		success = false -- 1771
	} -- 1771
end) -- 1771
HttpServer:postSchedule("/read", function(req) -- 1775
	do -- 1776
		local _type_0 = type(req) -- 1776
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1776
		if _tab_0 then -- 1776
			local path -- 1776
			do -- 1776
				local _obj_0 = req.body -- 1776
				local _type_1 = type(_obj_0) -- 1776
				if "table" == _type_1 or "userdata" == _type_1 then -- 1776
					path = _obj_0.path -- 1776
				end -- 1776
			end -- 1776
			if path ~= nil then -- 1776
				local readFile -- 1777
				readFile = function() -- 1777
					if Content:exist(path) then -- 1778
						local content = Content:loadAsync(path) -- 1779
						if content then -- 1779
							return { -- 1780
								content = content, -- 1780
								success = true, -- 1780
								fullPath = Content:getFullPath(path) -- 1780
							} -- 1780
						end -- 1779
					end -- 1778
					return nil -- 1777
				end -- 1777
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1781
				if result then -- 1781
					return result -- 1781
				end -- 1781
			end -- 1776
		end -- 1776
	end -- 1776
	return { -- 1775
		success = false -- 1775
	} -- 1775
end) -- 1775
local agentDocLanguage -- 1783
agentDocLanguage = function(language) -- 1783
	if language == "zh-Hans" then -- 1784
		return "zh" -- 1784
	else -- 1784
		return "en" -- 1784
	end -- 1784
end -- 1783
HttpServer:postSchedule("/doc/search", function(req) -- 1786
	local body = req.body or { } -- 1787
	local language = body.docLanguage -- 1788
	if not (("en" == language or "zh-Hans" == language)) then -- 1789
		return { -- 1789
			success = false, -- 1789
			message = "unsupported doc language" -- 1789
		} -- 1789
	end -- 1789
	local source = body.docSource -- 1790
	if not (("api" == source or "tutorial" == source)) then -- 1791
		return { -- 1791
			success = false, -- 1791
			message = "unsupported doc source" -- 1791
		} -- 1791
	end -- 1791
	local codeLanguage = body.programmingLanguage -- 1792
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1793
		return { -- 1793
			success = false, -- 1793
			message = "unsupported programming language" -- 1793
		} -- 1793
	end -- 1793
	if not body.pattern then -- 1794
		return { -- 1794
			success = false, -- 1794
			message = "missing pattern" -- 1794
		} -- 1794
	end -- 1794
	local result = nil -- 1795
	AgentTools.searchDoraAPIHttp({ -- 1797
		pattern = body.pattern, -- 1797
		docLanguage = agentDocLanguage(language), -- 1798
		docSource = source, -- 1799
		programmingLanguage = codeLanguage, -- 1800
		limit = body.limit, -- 1801
		useRegex = body.useRegex, -- 1802
		caseSensitive = body.caseSensitive, -- 1803
		includeContent = body.includeContent, -- 1804
		contentWindow = body.contentWindow -- 1805
	}, function(res) -- 1806
		result = res -- 1807
	end) -- 1796
	wait(function() -- 1808
		return result ~= nil -- 1808
	end) -- 1808
	if result and result.success then -- 1809
		result.docLanguage = language -- 1810
	end -- 1809
	if result then -- 1811
		return result -- 1812
	else -- 1814
		return { -- 1814
			success = false, -- 1814
			message = "doc search failed" -- 1814
		} -- 1814
	end -- 1811
	return { -- 1786
		success = false, -- 1786
		message = "invalid call" -- 1786
	} -- 1786
end) -- 1786
HttpServer:postSchedule("/doc/read", function(req) -- 1816
	local body = req.body or { } -- 1817
	local language = body.docLanguage -- 1818
	if not (("en" == language or "zh-Hans" == language)) then -- 1819
		return { -- 1819
			success = false, -- 1819
			message = "unsupported doc language" -- 1819
		} -- 1819
	end -- 1819
	if not body.file then -- 1820
		return { -- 1820
			success = false, -- 1820
			message = "missing file" -- 1820
		} -- 1820
	end -- 1820
	local result = AgentTools.readDoraDoc({ -- 1822
		docLanguage = agentDocLanguage(language), -- 1822
		file = body.file, -- 1823
		startLine = body.startLine, -- 1824
		endLine = body.endLine -- 1825
	}) -- 1821
	if result and result.success then -- 1826
		result.docLanguage = language -- 1827
	end -- 1826
	return result -- 1828
end) -- 1816
HttpServer:get("/read-sync", function(req) -- 1830
	do -- 1831
		local _type_0 = type(req) -- 1831
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1831
		if _tab_0 then -- 1831
			local params = req.params -- 1831
			if params ~= nil then -- 1831
				local path = params.path -- 1832
				local exts -- 1833
				if params.exts then -- 1833
					local _accum_0 = { } -- 1834
					local _len_0 = 1 -- 1834
					for ext in params.exts:gmatch("[^|]*") do -- 1834
						_accum_0[_len_0] = ext -- 1834
						_len_0 = _len_0 + 1 -- 1834
					end -- 1834
					exts = _accum_0 -- 1834
				else -- 1835
					exts = { -- 1835
						"" -- 1835
					} -- 1835
				end -- 1833
				local readFileAt -- 1836
				readFileAt = function(targetPath) -- 1836
					if Content:exist(targetPath) then -- 1837
						local content = Content:load(targetPath) -- 1838
						if content then -- 1838
							return { -- 1839
								content = content, -- 1839
								success = true, -- 1839
								fullPath = Content:getFullPath(targetPath) -- 1839
							} -- 1839
						end -- 1838
					end -- 1837
					return nil -- 1836
				end -- 1836
				local readFile -- 1840
				readFile = function(fallbackPaths) -- 1840
					for _index_0 = 1, #exts do -- 1841
						local ext = exts[_index_0] -- 1841
						local targetPath = path .. ext -- 1842
						if not Content:isAbsolutePath(targetPath) then -- 1843
							for _index_1 = 1, #fallbackPaths do -- 1844
								local fallback = fallbackPaths[_index_1] -- 1844
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1845
								if fallbackResult then -- 1845
									return fallbackResult -- 1846
								end -- 1845
							end -- 1844
						end -- 1843
						local fileResult = readFileAt(targetPath) -- 1847
						if fileResult then -- 1847
							return fileResult -- 1848
						end -- 1847
					end -- 1841
					return nil -- 1840
				end -- 1840
				local fallbackPaths = { } -- 1849
				local fallbackCandidates = { } -- 1850
				do -- 1851
					local projectRoot = req.params.projectRoot -- 1851
					if projectRoot then -- 1851
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1852
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1853
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1854
						end -- 1852
					end -- 1851
				end -- 1851
				do -- 1855
					local projFile = req.params.projFile -- 1855
					if projFile then -- 1855
						local projDir = getProjectDirFromFile(projFile) -- 1856
						if projDir then -- 1856
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1857
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1858
						else -- 1860
							projDir = Path:getPath(projFile) -- 1860
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1861
						end -- 1856
					end -- 1855
				end -- 1855
				for _index_0 = 1, #fallbackCandidates do -- 1862
					local dir = fallbackCandidates[_index_0] -- 1862
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1863
						local exists = false -- 1864
						for _index_1 = 1, #fallbackPaths do -- 1865
							local fallback = fallbackPaths[_index_1] -- 1865
							if fallback == dir then -- 1866
								exists = true -- 1867
								break -- 1868
							end -- 1866
						end -- 1865
						if not exists then -- 1869
							fallbackPaths[#fallbackPaths + 1] = dir -- 1869
						end -- 1869
					end -- 1863
				end -- 1862
				local readResult = readFile(fallbackPaths) -- 1870
				if readResult then -- 1870
					return readResult -- 1871
				end -- 1870
			end -- 1831
		end -- 1831
	end -- 1831
	return { -- 1830
		success = false -- 1830
	} -- 1830
end) -- 1830
local compileFileAsync -- 1873
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1873
	if projectRoot == nil then -- 1873
		projectRoot = nil -- 1873
	end -- 1873
	local file = inputFile -- 1874
	local searchPath -- 1875
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1875
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1876
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1880
	elseif not Content:isAbsolutePath(inputFile) then -- 1881
		searchPath = "" -- 1882
	else -- 1883
		local dir = getProjectDirFromFile(inputFile) -- 1883
		if dir then -- 1883
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1884
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1888
		else -- 1890
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1890
			searchPath = "" -- 1893
		end -- 1883
	end -- 1875
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1894
	local yueext = yue.options.extension -- 1895
	local resultCodes = nil -- 1896
	local resultError = nil -- 1897
	do -- 1898
		local _exp_0 = Path:getExt(inputFile) -- 1898
		if yueext == _exp_0 then -- 1898
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1899
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1900
				if not codes then -- 1901
					resultError = err -- 1902
					return -- 1903
				end -- 1901
				local extraGlobal -- 1904
				if isTIC80 then -- 1904
					extraGlobal = tic80APIs -- 1904
				else -- 1904
					extraGlobal = nil -- 1904
				end -- 1904
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1905
				if not success then -- 1906
					resultError = message -- 1907
					return -- 1908
				end -- 1906
				if codes == "" then -- 1909
					resultCodes = "" -- 1910
					return nil -- 1911
				end -- 1909
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1912
				return resultCodes -- 1913
			end, function(success) -- 1900
				if not success then -- 1914
					Content:remove(outputFile) -- 1915
					if resultCodes == nil then -- 1916
						resultCodes = false -- 1917
					end -- 1916
				end -- 1914
			end) -- 1900
		elseif "tl" == _exp_0 then -- 1918
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1919
			if isTIC80 then -- 1920
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1921
			end -- 1920
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1922
			if codes then -- 1922
				if isTIC80 then -- 1923
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1924
				end -- 1923
				resultCodes = codes -- 1925
				Content:saveAsync(outputFile, codes) -- 1926
			else -- 1928
				Content:remove(outputFile) -- 1928
				resultCodes = false -- 1929
				resultError = err -- 1930
			end -- 1922
		elseif "xml" == _exp_0 then -- 1931
			local codes, err = xml.tolua(sourceCodes) -- 1932
			if codes then -- 1932
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1933
				Content:saveAsync(outputFile, resultCodes) -- 1934
			else -- 1936
				Content:remove(outputFile) -- 1936
				resultCodes = false -- 1937
				resultError = err -- 1938
			end -- 1932
		end -- 1898
	end -- 1898
	wait(function() -- 1939
		return resultCodes ~= nil -- 1939
	end) -- 1939
	if resultCodes then -- 1940
		return resultCodes -- 1941
	else -- 1943
		return nil, resultError -- 1943
	end -- 1940
	return nil -- 1873
end -- 1873
HttpServer:postSchedule("/write", function(req) -- 1945
	do -- 1946
		local _type_0 = type(req) -- 1946
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1946
		if _tab_0 then -- 1946
			local path -- 1946
			do -- 1946
				local _obj_0 = req.body -- 1946
				local _type_1 = type(_obj_0) -- 1946
				if "table" == _type_1 or "userdata" == _type_1 then -- 1946
					path = _obj_0.path -- 1946
				end -- 1946
			end -- 1946
			local content -- 1946
			do -- 1946
				local _obj_0 = req.body -- 1946
				local _type_1 = type(_obj_0) -- 1946
				if "table" == _type_1 or "userdata" == _type_1 then -- 1946
					content = _obj_0.content -- 1946
				end -- 1946
			end -- 1946
			if path ~= nil and content ~= nil then -- 1946
				if Content:saveAsync(path, content) then -- 1947
					do -- 1948
						local _exp_0 = Path:getExt(path) -- 1948
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1948
							if '' == Path:getExt(Path:getName(path)) then -- 1949
								local resultCodes = compileFileAsync(path, content) -- 1950
								return { -- 1951
									success = true, -- 1951
									resultCodes = resultCodes -- 1951
								} -- 1951
							end -- 1949
						end -- 1948
					end -- 1948
					return { -- 1952
						success = true -- 1952
					} -- 1952
				end -- 1947
			end -- 1946
		end -- 1946
	end -- 1946
	return { -- 1945
		success = false -- 1945
	} -- 1945
end) -- 1945
local getWaProjectDirFromFile = nil -- 1954
HttpServer:postSchedule("/build", function(req) -- 1956
	do -- 1957
		local _type_0 = type(req) -- 1957
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1957
		if _tab_0 then -- 1957
			local path -- 1957
			do -- 1957
				local _obj_0 = req.body -- 1957
				local _type_1 = type(_obj_0) -- 1957
				if "table" == _type_1 or "userdata" == _type_1 then -- 1957
					path = _obj_0.path -- 1957
				end -- 1957
			end -- 1957
			if path ~= nil then -- 1957
				local projectRoot = req.body.projectRoot -- 1958
				if Content:isdir(path) then -- 1959
					local projDir = getWaProjectDirFromFile(path) -- 1960
					if projDir then -- 1960
						local message = Wasm:buildWaAsync(projDir) -- 1961
						if message == "" then -- 1962
							return { -- 1963
								success = true -- 1963
							} -- 1963
						else -- 1965
							return { -- 1965
								success = false, -- 1965
								message = message -- 1965
							} -- 1965
						end -- 1962
					end -- 1960
				end -- 1959
				local _exp_0 = Path:getExt(path) -- 1966
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1967
					if '' == Path:getExt(Path:getName(path)) then -- 1968
						local content = Content:loadAsync(path) -- 1969
						if content then -- 1969
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 1970
							if resultCodes then -- 1970
								return { -- 1971
									success = true, -- 1971
									resultCodes = resultCodes -- 1971
								} -- 1971
							end -- 1970
						end -- 1969
					end -- 1968
				elseif "wa" == _exp_0 then -- 1972
					local projDir = getWaProjectDirFromFile(path) -- 1973
					if projDir then -- 1973
						local message = Wasm:buildWaAsync(projDir) -- 1974
						if message == "" then -- 1975
							return { -- 1976
								success = true -- 1976
							} -- 1976
						else -- 1978
							return { -- 1978
								success = false, -- 1978
								message = message -- 1978
							} -- 1978
						end -- 1975
					else -- 1980
						return { -- 1980
							success = false, -- 1980
							message = 'Wa file needs a project' -- 1980
						} -- 1980
					end -- 1973
				end -- 1966
			end -- 1957
		end -- 1957
	end -- 1957
	return { -- 1956
		success = false -- 1956
	} -- 1956
end) -- 1956
local extentionLevels = { -- 1983
	vs = 2, -- 1983
	bl = 2, -- 1984
	ts = 1, -- 1985
	tsx = 1, -- 1986
	tl = 1, -- 1987
	yue = 1, -- 1988
	xml = 1, -- 1989
	lua = 0 -- 1990
} -- 1982
local visitAssets -- 1992
visitAssets = function(path, workspace, builtin, recursive) -- 1992
	if recursive == nil then -- 1992
		recursive = true -- 1992
	end -- 1992
	local children = nil -- 1993
	local dirs = Content:getDirs(path) -- 1994
	for _index_0 = 1, #dirs do -- 1995
		local dir = dirs[_index_0] -- 1995
		if workspace then -- 1996
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 1997
				goto _continue_0 -- 1998
			end -- 1997
		elseif dir == ".git" then -- 1999
			goto _continue_0 -- 2000
		end -- 1996
		if not children then -- 2001
			children = { } -- 2001
		end -- 2001
		local dirPath = Path(path, dir) -- 2002
		if recursive then -- 2003
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2004
		else -- 2006
			children[#children + 1] = { -- 2007
				key = dirPath, -- 2007
				dir = true, -- 2008
				title = dir, -- 2009
				builtin = builtin, -- 2010
				isLeaf = false -- 2011
			} -- 2006
		end -- 2003
		::_continue_0:: -- 1996
	end -- 1995
	local files = Content:getFiles(path) -- 2013
	local names = { } -- 2014
	for _index_0 = 1, #files do -- 2015
		local file = files[_index_0] -- 2015
		if (".DS_Store" == file) then -- 2016
			goto _continue_1 -- 2017
		end -- 2016
		local name = Path:getName(file) -- 2018
		local ext = names[name] -- 2019
		if ext then -- 2019
			local lv1 -- 2020
			do -- 2020
				local _exp_0 = extentionLevels[ext] -- 2020
				if _exp_0 ~= nil then -- 2020
					lv1 = _exp_0 -- 2020
				else -- 2020
					lv1 = -1 -- 2020
				end -- 2020
			end -- 2020
			ext = Path:getExt(file) -- 2021
			local lv2 -- 2022
			do -- 2022
				local _exp_0 = extentionLevels[ext] -- 2022
				if _exp_0 ~= nil then -- 2022
					lv2 = _exp_0 -- 2022
				else -- 2022
					lv2 = -1 -- 2022
				end -- 2022
			end -- 2022
			if lv2 > lv1 then -- 2023
				names[name] = ext -- 2024
			elseif lv2 == lv1 then -- 2025
				names[name .. '.' .. ext] = "" -- 2026
			end -- 2023
		else -- 2028
			ext = Path:getExt(file) -- 2028
			if not extentionLevels[ext] then -- 2029
				names[file] = "" -- 2030
			else -- 2032
				names[name] = ext -- 2032
			end -- 2029
		end -- 2019
		::_continue_1:: -- 2016
	end -- 2015
	do -- 2033
		local _accum_0 = { } -- 2033
		local _len_0 = 1 -- 2033
		for name, ext in pairs(names) do -- 2033
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2033
			_len_0 = _len_0 + 1 -- 2033
		end -- 2033
		files = _accum_0 -- 2033
	end -- 2033
	for _index_0 = 1, #files do -- 2034
		local file = files[_index_0] -- 2034
		if not children then -- 2035
			children = { } -- 2035
		end -- 2035
		children[#children + 1] = { -- 2037
			key = Path(path, file), -- 2037
			dir = false, -- 2038
			title = file, -- 2039
			builtin = builtin -- 2040
		} -- 2036
	end -- 2034
	if children then -- 2042
		table.sort(children, function(a, b) -- 2043
			if a.dir == b.dir then -- 2044
				return a.title < b.title -- 2045
			else -- 2047
				return a.dir -- 2047
			end -- 2044
		end) -- 2043
	end -- 2042
	return { -- 2049
		key = path, -- 2049
		dir = true, -- 2050
		title = Path:getFilename(path), -- 2051
		builtin = builtin, -- 2052
		isLeaf = not children, -- 2053
		children = children -- 2054
	} -- 2048
end -- 1992
HttpServer:post("/assets/children", function(req) -- 2057
	do -- 2058
		local _type_0 = type(req) -- 2058
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2058
		if _tab_0 then -- 2058
			local path -- 2058
			do -- 2058
				local _obj_0 = req.body -- 2058
				local _type_1 = type(_obj_0) -- 2058
				if "table" == _type_1 or "userdata" == _type_1 then -- 2058
					path = _obj_0.path -- 2058
				end -- 2058
			end -- 2058
			if path ~= nil then -- 2058
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2059
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2060
					return { -- 2060
						success = false -- 2060
					} -- 2060
				end -- 2060
				local node = visitAssets(path, workspace, builtin, false) -- 2061
				return { -- 2062
					success = true, -- 2062
					children = node.children or { } -- 2062
				} -- 2062
			end -- 2058
		end -- 2058
	end -- 2058
	return { -- 2057
		success = false -- 2057
	} -- 2057
end) -- 2057
HttpServer:post("/assets/files", function(req) -- 2064
	do -- 2065
		local _type_0 = type(req) -- 2065
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2065
		if _tab_0 then -- 2065
			local path -- 2065
			do -- 2065
				local _obj_0 = req.body -- 2065
				local _type_1 = type(_obj_0) -- 2065
				if "table" == _type_1 or "userdata" == _type_1 then -- 2065
					path = _obj_0.path -- 2065
				end -- 2065
			end -- 2065
			if path ~= nil then -- 2065
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2066
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2067
				if not (workspace or builtin) then -- 2068
					return { -- 2068
						success = false -- 2068
					} -- 2068
				end -- 2068
				if not (Content:exist(path) and Content:isdir(path)) then -- 2069
					return { -- 2069
						success = false -- 2069
					} -- 2069
				end -- 2069
				local globs = { -- 2070
					"**", -- 2070
					"!**/.DS_Store" -- 2070
				} -- 2070
				if workspace then -- 2071
					globs = { -- 2073
						"**", -- 2073
						"!**/.DS_Store", -- 2073
						"!**/.upload/**", -- 2074
						"!**/.download/**", -- 2074
						"!**/.www/**", -- 2075
						"!**/.build/**", -- 2075
						"!**/.git/**", -- 2076
						"!**/.cache/**", -- 2076
						"!**/node_modules/**" -- 2077
					} -- 2072
				end -- 2071
				local files -- 2079
				do -- 2079
					local _accum_0 = { } -- 2079
					local _len_0 = 1 -- 2079
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2079
					for _index_0 = 1, #_list_0 do -- 2079
						local file = _list_0[_index_0] -- 2079
						_accum_0[_len_0] = Path(path, file) -- 2079
						_len_0 = _len_0 + 1 -- 2079
					end -- 2079
					files = _accum_0 -- 2079
				end -- 2079
				return { -- 2080
					success = true, -- 2080
					files = files -- 2080
				} -- 2080
			end -- 2065
		end -- 2065
	end -- 2065
	return { -- 2064
		success = false -- 2064
	} -- 2064
end) -- 2064
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2121
	local _tab_0 = { -- 2121
		{ -- 2122
			key = Path(Content.assetPath), -- 2122
			dir = true, -- 2123
			builtin = true, -- 2124
			title = zh and "内置资源" or "Built-in", -- 2125
			children = builtinChildren -- 2126
		} -- 2121
	} -- 2128
	local _obj_0 = workspace.children or { } -- 2128
	local _idx_0 = #_tab_0 + 1 -- 2128
	for _index_0 = 1, #_obj_0 do -- 2128
		local _value_0 = _obj_0[_index_0] -- 2128
		_tab_0[_idx_0] = _value_0 -- 2128
		_idx_0 = _idx_0 + 1 -- 2128
	end -- 2128
	return _tab_0 -- 2121
end -- 2121
HttpServer:post("/assets", function() -- 2082
	local Entry = require("Script.Dev.Entry") -- 2083
	local engineDev = Entry.getEngineDev() -- 2084
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2085
	local zh = (App.locale:match("^zh") ~= nil) -- 2086
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2087
	readme.title = zh and "说明文档" or "Readme" -- 2088
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2089
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2090
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2091
	tools.title = zh and "开发工具" or "Tools" -- 2092
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2093
	font.title = zh and "字体" or "Font" -- 2094
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2095
	lib.title = zh and "程序库" or "Lib" -- 2096
	if engineDev then -- 2097
		local _list_0 = lib.children -- 2098
		for _index_0 = 1, #_list_0 do -- 2098
			local child = _list_0[_index_0] -- 2098
			if not (child.title == "Dora") then -- 2099
				goto _continue_0 -- 2099
			end -- 2099
			local title = zh and "zh-Hans" or "en" -- 2100
			do -- 2101
				local _accum_0 = { } -- 2101
				local _len_0 = 1 -- 2101
				local _list_1 = child.children -- 2101
				for _index_1 = 1, #_list_1 do -- 2101
					local c = _list_1[_index_1] -- 2101
					if c.title ~= title then -- 2101
						_accum_0[_len_0] = c -- 2101
						_len_0 = _len_0 + 1 -- 2101
					end -- 2101
				end -- 2101
				child.children = _accum_0 -- 2101
			end -- 2101
			break -- 2102
			::_continue_0:: -- 2099
		end -- 2098
	else -- 2104
		local _accum_0 = { } -- 2104
		local _len_0 = 1 -- 2104
		local _list_0 = lib.children -- 2104
		for _index_0 = 1, #_list_0 do -- 2104
			local child = _list_0[_index_0] -- 2104
			if child.title ~= "Dora" then -- 2104
				_accum_0[_len_0] = child -- 2104
				_len_0 = _len_0 + 1 -- 2104
			end -- 2104
		end -- 2104
		lib.children = _accum_0 -- 2104
	end -- 2097
	local builtinChildren = { -- 2105
		readme, -- 2105
		apiDoc, -- 2105
		tools, -- 2105
		font, -- 2105
		lib -- 2105
	} -- 2105
	if engineDev then -- 2106
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2107
		do -- 2108
			local _obj_0 = dev.children -- 2108
			_obj_0[#_obj_0 + 1] = { -- 2109
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2109
				dir = false, -- 2110
				builtin = true, -- 2111
				title = "init.yue" -- 2112
			} -- 2108
		end -- 2108
		builtinChildren[#builtinChildren + 1] = dev -- 2114
	end -- 2106
	return { -- 2116
		key = Content.writablePath, -- 2116
		dir = true, -- 2117
		root = true, -- 2118
		title = "Assets", -- 2119
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2120
	} -- 2115
end) -- 2082
HttpServer:post("/entry/list", function(req) -- 2132
	local Entry = require("Script.Dev.Entry") -- 2133
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2134
	res.success = true -- 2135
	return res -- 2136
end) -- 2132
HttpServer:post("/run/status", function() -- 2138
	local Entry = require("Script.Dev.Entry") -- 2139
	return Entry.getCurrentEntryStatus() -- 2140
end) -- 2138
HttpServer:postSchedule("/run", function(req) -- 2142
	do -- 2143
		local _type_0 = type(req) -- 2143
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2143
		if _tab_0 then -- 2143
			local file -- 2143
			do -- 2143
				local _obj_0 = req.body -- 2143
				local _type_1 = type(_obj_0) -- 2143
				if "table" == _type_1 or "userdata" == _type_1 then -- 2143
					file = _obj_0.file -- 2143
				end -- 2143
			end -- 2143
			local asProj -- 2143
			do -- 2143
				local _obj_0 = req.body -- 2143
				local _type_1 = type(_obj_0) -- 2143
				if "table" == _type_1 or "userdata" == _type_1 then -- 2143
					asProj = _obj_0.asProj -- 2143
				end -- 2143
			end -- 2143
			if file ~= nil and asProj ~= nil then -- 2143
				if not Content:isAbsolutePath(file) then -- 2144
					local devFile = Path(Content.writablePath, file) -- 2145
					if Content:exist(devFile) then -- 2146
						file = devFile -- 2146
					end -- 2146
				end -- 2144
				local Entry = require("Script.Dev.Entry") -- 2147
				local workDir -- 2148
				if asProj then -- 2149
					local projectRoot = req.body.projectRoot -- 2150
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2151
						workDir = projectRoot -- 2152
					else -- 2154
						workDir = getProjectDirFromFile(file) -- 2154
					end -- 2151
					if workDir then -- 2155
						Entry.allClear() -- 2156
						local target = Path(workDir, "init") -- 2157
						local success, err = Entry.enterEntryAsync({ -- 2158
							entryName = "Project", -- 2158
							fileName = target, -- 2158
							workDir = workDir, -- 2158
							projectRoot = workDir, -- 2158
							runKind = "project" -- 2158
						}) -- 2158
						target = Path:getName(Path:getPath(target)) -- 2159
						return { -- 2160
							success = success, -- 2160
							target = target, -- 2160
							err = err -- 2160
						} -- 2160
					end -- 2155
				else -- 2162
					workDir = getProjectDirFromFile(file) -- 2162
					if not workDir and Path:getExt(file) == "wasm" then -- 2163
						local parent = Path:getPath(file) -- 2164
						if Content:exist(Path(parent, "wa.mod")) then -- 2165
							workDir = parent -- 2166
						end -- 2165
					end -- 2163
				end -- 2149
				Entry.allClear() -- 2167
				file = Path:replaceExt(file, "") -- 2168
				local entry = { -- 2170
					entryName = Path:getName(file), -- 2170
					fileName = file, -- 2171
					runKind = "file" -- 2172
				} -- 2169
				if workDir then -- 2173
					entry.workDir = workDir -- 2174
					entry.projectRoot = workDir -- 2175
				end -- 2173
				local success, err = Entry.enterEntryAsync(entry) -- 2176
				return { -- 2177
					success = success, -- 2177
					err = err -- 2177
				} -- 2177
			end -- 2143
		end -- 2143
	end -- 2143
	return { -- 2142
		success = false -- 2142
	} -- 2142
end) -- 2142
HttpServer:postSchedule("/stop", function() -- 2179
	local Entry = require("Script.Dev.Entry") -- 2180
	return { -- 2181
		success = Entry.stop() -- 2181
	} -- 2181
end) -- 2179
local minifyAsync -- 2183
minifyAsync = function(sourcePath, minifyPath) -- 2183
	if not Content:exist(sourcePath) then -- 2184
		return -- 2184
	end -- 2184
	local Entry = require("Script.Dev.Entry") -- 2185
	local errors = { } -- 2186
	local files = Entry.getAllFiles(sourcePath, { -- 2187
		"lua" -- 2187
	}, true) -- 2187
	do -- 2188
		local _accum_0 = { } -- 2188
		local _len_0 = 1 -- 2188
		for _index_0 = 1, #files do -- 2188
			local file = files[_index_0] -- 2188
			if file:sub(1, 1) ~= '.' then -- 2188
				_accum_0[_len_0] = file -- 2188
				_len_0 = _len_0 + 1 -- 2188
			end -- 2188
		end -- 2188
		files = _accum_0 -- 2188
	end -- 2188
	local paths -- 2189
	do -- 2189
		local _tbl_0 = { } -- 2189
		for _index_0 = 1, #files do -- 2189
			local file = files[_index_0] -- 2189
			_tbl_0[Path:getPath(file)] = true -- 2189
		end -- 2189
		paths = _tbl_0 -- 2189
	end -- 2189
	for path in pairs(paths) do -- 2190
		Content:mkdir(Path(minifyPath, path)) -- 2190
	end -- 2190
	local _ <close> = setmetatable({ }, { -- 2191
		__close = function() -- 2191
			package.loaded["luaminify.FormatMini"] = nil -- 2192
			package.loaded["luaminify.ParseLua"] = nil -- 2193
			package.loaded["luaminify.Scope"] = nil -- 2194
			package.loaded["luaminify.Util"] = nil -- 2195
		end -- 2191
	}) -- 2191
	local FormatMini -- 2196
	do -- 2196
		local _obj_0 = require("luaminify") -- 2196
		FormatMini = _obj_0.FormatMini -- 2196
	end -- 2196
	local fileCount = #files -- 2197
	local count = 0 -- 2198
	for _index_0 = 1, #files do -- 2199
		local file = files[_index_0] -- 2199
		thread(function() -- 2200
			local _ <close> = setmetatable({ }, { -- 2201
				__close = function() -- 2201
					count = count + 1 -- 2201
				end -- 2201
			}) -- 2201
			local input = Path(sourcePath, file) -- 2202
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2203
			if Content:exist(input) then -- 2204
				local sourceCodes = Content:loadAsync(input) -- 2205
				local res, err = FormatMini(sourceCodes) -- 2206
				if res then -- 2207
					Content:saveAsync(output, res) -- 2208
					return print("Minify " .. tostring(file)) -- 2209
				else -- 2211
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2211
				end -- 2207
			else -- 2213
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2213
			end -- 2204
		end) -- 2200
		sleep() -- 2214
	end -- 2199
	wait(function() -- 2215
		return count == fileCount -- 2215
	end) -- 2215
	if #errors > 0 then -- 2216
		print(table.concat(errors, '\n')) -- 2217
	end -- 2216
	print("Obfuscation done.") -- 2218
	return files -- 2219
end -- 2183
local zipping = false -- 2221
HttpServer:postSchedule("/zip", function(req) -- 2223
	do -- 2224
		local _type_0 = type(req) -- 2224
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2224
		if _tab_0 then -- 2224
			local path -- 2224
			do -- 2224
				local _obj_0 = req.body -- 2224
				local _type_1 = type(_obj_0) -- 2224
				if "table" == _type_1 or "userdata" == _type_1 then -- 2224
					path = _obj_0.path -- 2224
				end -- 2224
			end -- 2224
			local zipFile -- 2224
			do -- 2224
				local _obj_0 = req.body -- 2224
				local _type_1 = type(_obj_0) -- 2224
				if "table" == _type_1 or "userdata" == _type_1 then -- 2224
					zipFile = _obj_0.zipFile -- 2224
				end -- 2224
			end -- 2224
			local obfuscated -- 2224
			do -- 2224
				local _obj_0 = req.body -- 2224
				local _type_1 = type(_obj_0) -- 2224
				if "table" == _type_1 or "userdata" == _type_1 then -- 2224
					obfuscated = _obj_0.obfuscated -- 2224
				end -- 2224
			end -- 2224
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2224
				if zipping then -- 2225
					goto failed -- 2225
				end -- 2225
				zipping = true -- 2226
				local _ <close> = setmetatable({ }, { -- 2227
					__close = function() -- 2227
						zipping = false -- 2227
					end -- 2227
				}) -- 2227
				if not Content:exist(path) then -- 2228
					goto failed -- 2228
				end -- 2228
				Content:mkdir(Path:getPath(zipFile)) -- 2229
				if obfuscated then -- 2230
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2231
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2232
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2233
					Content:remove(scriptPath) -- 2234
					Content:remove(obfuscatedPath) -- 2235
					Content:remove(tempPath) -- 2236
					Content:mkdir(scriptPath) -- 2237
					Content:mkdir(obfuscatedPath) -- 2238
					Content:mkdir(tempPath) -- 2239
					if not Content:copyAsync(path, tempPath) then -- 2240
						goto failed -- 2240
					end -- 2240
					local Entry = require("Script.Dev.Entry") -- 2241
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2242
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2243
						"tl", -- 2243
						"yue", -- 2243
						"lua", -- 2243
						"ts", -- 2243
						"tsx", -- 2243
						"vs", -- 2243
						"bl", -- 2243
						"xml", -- 2243
						"wa", -- 2243
						"mod" -- 2243
					}, true) -- 2243
					for _index_0 = 1, #scriptFiles do -- 2244
						local file = scriptFiles[_index_0] -- 2244
						Content:remove(Path(tempPath, file)) -- 2245
					end -- 2244
					for _index_0 = 1, #luaFiles do -- 2246
						local file = luaFiles[_index_0] -- 2246
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2247
					end -- 2246
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2248
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2249
					end) then -- 2248
						goto failed -- 2248
					end -- 2248
					return { -- 2250
						success = true -- 2250
					} -- 2250
				else -- 2252
					return { -- 2252
						success = Content:zipAsync(path, zipFile, function(file) -- 2252
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2253
						end) -- 2252
					} -- 2252
				end -- 2230
			end -- 2224
		end -- 2224
	end -- 2224
	::failed:: -- 2254
	return { -- 2223
		success = false -- 2223
	} -- 2223
end) -- 2223
HttpServer:postSchedule("/unzip", function(req) -- 2256
	do -- 2257
		local _type_0 = type(req) -- 2257
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2257
		if _tab_0 then -- 2257
			local zipFile -- 2257
			do -- 2257
				local _obj_0 = req.body -- 2257
				local _type_1 = type(_obj_0) -- 2257
				if "table" == _type_1 or "userdata" == _type_1 then -- 2257
					zipFile = _obj_0.zipFile -- 2257
				end -- 2257
			end -- 2257
			local path -- 2257
			do -- 2257
				local _obj_0 = req.body -- 2257
				local _type_1 = type(_obj_0) -- 2257
				if "table" == _type_1 or "userdata" == _type_1 then -- 2257
					path = _obj_0.path -- 2257
				end -- 2257
			end -- 2257
			if zipFile ~= nil and path ~= nil then -- 2257
				return { -- 2258
					success = Content:unzipAsync(zipFile, path, function(file) -- 2258
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2259
					end) -- 2258
				} -- 2258
			end -- 2257
		end -- 2257
	end -- 2257
	return { -- 2256
		success = false -- 2256
	} -- 2256
end) -- 2256
HttpServer:post("/editing-info", function(req) -- 2261
	local Entry = require("Script.Dev.Entry") -- 2262
	local config = Entry.getConfig() -- 2263
	local _type_0 = type(req) -- 2264
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2264
	local _match_0 = false -- 2264
	if _tab_0 then -- 2264
		local editingInfo -- 2264
		do -- 2264
			local _obj_0 = req.body -- 2264
			local _type_1 = type(_obj_0) -- 2264
			if "table" == _type_1 or "userdata" == _type_1 then -- 2264
				editingInfo = _obj_0.editingInfo -- 2264
			end -- 2264
		end -- 2264
		if editingInfo ~= nil then -- 2264
			_match_0 = true -- 2264
			config.editingInfo = editingInfo -- 2265
			return { -- 2266
				success = true -- 2266
			} -- 2266
		end -- 2264
	end -- 2264
	if not _match_0 then -- 2264
		if not (config.editingInfo ~= nil) then -- 2268
			local folder -- 2269
			if App.locale:match('^zh') then -- 2269
				folder = 'zh-Hans' -- 2269
			else -- 2269
				folder = 'en' -- 2269
			end -- 2269
			config.editingInfo = json.encode({ -- 2271
				index = 0, -- 2271
				files = { -- 2273
					{ -- 2274
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2274
						title = "welcome.md" -- 2275
					} -- 2273
				} -- 2272
			}) -- 2270
		end -- 2268
		return { -- 2279
			success = true, -- 2279
			editingInfo = config.editingInfo -- 2279
		} -- 2279
	end -- 2264
end) -- 2261
HttpServer:post("/command", function(req) -- 2281
	do -- 2282
		local _type_0 = type(req) -- 2282
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2282
		if _tab_0 then -- 2282
			local code -- 2282
			do -- 2282
				local _obj_0 = req.body -- 2282
				local _type_1 = type(_obj_0) -- 2282
				if "table" == _type_1 or "userdata" == _type_1 then -- 2282
					code = _obj_0.code -- 2282
				end -- 2282
			end -- 2282
			local log -- 2282
			do -- 2282
				local _obj_0 = req.body -- 2282
				local _type_1 = type(_obj_0) -- 2282
				if "table" == _type_1 or "userdata" == _type_1 then -- 2282
					log = _obj_0.log -- 2282
				end -- 2282
			end -- 2282
			if code ~= nil and log ~= nil then -- 2282
				emit("AppCommand", code, log) -- 2283
				return { -- 2284
					success = true -- 2284
				} -- 2284
			end -- 2282
		end -- 2282
	end -- 2282
	return { -- 2281
		success = false -- 2281
	} -- 2281
end) -- 2281
HttpServer:post("/log/save", function() -- 2286
	local folder = ".download" -- 2287
	local fullLogFile = "dora_full_logs.txt" -- 2288
	local fullFolder = Path(Content.writablePath, folder) -- 2289
	Content:mkdir(fullFolder) -- 2290
	local logPath = Path(fullFolder, fullLogFile) -- 2291
	if App:saveLog(logPath) then -- 2292
		return { -- 2293
			success = true, -- 2293
			path = Path(folder, fullLogFile) -- 2293
		} -- 2293
	end -- 2292
	return { -- 2286
		success = false -- 2286
	} -- 2286
end) -- 2286
local tailLines -- 2295
tailLines = function(text, count) -- 2295
	local lines = { } -- 2296
	text = text:gsub("\r\n", "\n") -- 2297
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2298
		lines[#lines + 1] = line -- 2299
	end -- 2298
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2300
		table.remove(lines) -- 2301
	end -- 2300
	local start = math.max(1, #lines - count + 1) -- 2302
	local out = { } -- 2303
	for i = start, #lines do -- 2304
		out[#out + 1] = lines[i] -- 2305
	end -- 2304
	return table.concat(out, "\n") -- 2306
end -- 2295
HttpServer:post("/log", function(req) -- 2308
	local count = 100 -- 2309
	if req and req.body and req.body.count ~= nil then -- 2310
		count = req.body.count -- 2311
	end -- 2310
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2312
		return { -- 2313
			success = false, -- 2313
			message = "count must be a positive integer" -- 2313
		} -- 2313
	end -- 2312
	local folder = ".download" -- 2314
	local fullLogFile = "dora_full_logs.txt" -- 2315
	local fullFolder = Path(Content.writablePath, folder) -- 2316
	Content:mkdir(fullFolder) -- 2317
	local logPath = Path(fullFolder, fullLogFile) -- 2318
	if App:saveLog(logPath) then -- 2319
		local text = Content:load(logPath) -- 2320
		if text then -- 2321
			return { -- 2322
				success = true, -- 2322
				log = tailLines(text, count) -- 2322
			} -- 2322
		else -- 2324
			return { -- 2324
				success = false, -- 2324
				message = "failed to read log" -- 2324
			} -- 2324
		end -- 2321
	else -- 2326
		return { -- 2326
			success = false, -- 2326
			message = "failed to save log" -- 2326
		} -- 2326
	end -- 2319
	return { -- 2308
		success = false -- 2308
	} -- 2308
end) -- 2308
HttpServer:post("/yarn/check", function(req) -- 2328
	local yarncompile = require("yarncompile") -- 2329
	do -- 2330
		local _type_0 = type(req) -- 2330
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2330
		if _tab_0 then -- 2330
			local code -- 2330
			do -- 2330
				local _obj_0 = req.body -- 2330
				local _type_1 = type(_obj_0) -- 2330
				if "table" == _type_1 or "userdata" == _type_1 then -- 2330
					code = _obj_0.code -- 2330
				end -- 2330
			end -- 2330
			if code ~= nil then -- 2330
				local jsonObject = json.decode(code) -- 2331
				if jsonObject then -- 2331
					local errors = { } -- 2332
					local _list_0 = jsonObject.nodes -- 2333
					for _index_0 = 1, #_list_0 do -- 2333
						local node = _list_0[_index_0] -- 2333
						local title, body = node.title, node.body -- 2334
						local luaCode, err = yarncompile(body) -- 2335
						if not luaCode then -- 2335
							errors[#errors + 1] = title .. ":" .. err -- 2336
						end -- 2335
					end -- 2333
					return { -- 2337
						success = true, -- 2337
						syntaxError = table.concat(errors, "\n\n") -- 2337
					} -- 2337
				end -- 2331
			end -- 2330
		end -- 2330
	end -- 2330
	return { -- 2328
		success = false -- 2328
	} -- 2328
end) -- 2328
HttpServer:post("/yarn/check-file", function(req) -- 2339
	local yarncompile = require("yarncompile") -- 2340
	do -- 2341
		local _type_0 = type(req) -- 2341
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2341
		if _tab_0 then -- 2341
			local code -- 2341
			do -- 2341
				local _obj_0 = req.body -- 2341
				local _type_1 = type(_obj_0) -- 2341
				if "table" == _type_1 or "userdata" == _type_1 then -- 2341
					code = _obj_0.code -- 2341
				end -- 2341
			end -- 2341
			if code ~= nil then -- 2341
				local res, _, err = yarncompile(code, true) -- 2342
				if not res then -- 2342
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2343
					return { -- 2344
						success = false, -- 2344
						message = message, -- 2344
						line = line, -- 2344
						column = column, -- 2344
						node = node -- 2344
					} -- 2344
				end -- 2342
			end -- 2341
		end -- 2341
	end -- 2341
	return { -- 2339
		success = true -- 2339
	} -- 2339
end) -- 2339
getWaProjectDirFromFile = function(file) -- 2346
	local current -- 2347
	if Content:isdir(file) then -- 2347
		current = file -- 2347
	else -- 2347
		current = Path:getPath(file) -- 2347
	end -- 2347
	if current == "" then -- 2348
		return nil -- 2348
	end -- 2348
	repeat -- 2349
		local modPath = Path(current, "wa.mod") -- 2350
		if Content:exist(modPath) then -- 2351
			return current, modPath -- 2352
		end -- 2351
		local parent = Path:getPath(current) -- 2353
		if parent == "" or parent == current then -- 2354
			break -- 2354
		end -- 2354
		current = parent -- 2355
	until false -- 2349
	return nil -- 2357
end -- 2346
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2359
	do -- 2360
		local _type_0 = type(req) -- 2360
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2360
		if _tab_0 then -- 2360
			local path -- 2360
			do -- 2360
				local _obj_0 = req.body -- 2360
				local _type_1 = type(_obj_0) -- 2360
				if "table" == _type_1 or "userdata" == _type_1 then -- 2360
					path = _obj_0.path -- 2360
				end -- 2360
			end -- 2360
			if path ~= nil then -- 2360
				local projDir = getWaProjectDirFromFile(path) -- 2361
				if projDir then -- 2361
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2362
					if not Content:exist(sourceDoraPath) then -- 2363
						return { -- 2364
							success = false, -- 2364
							message = "missing dora template" -- 2364
						} -- 2364
					end -- 2363
					local targetVendorPath = Path(projDir, "vendor") -- 2365
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2366
					if not Content:exist(targetVendorPath) then -- 2367
						if not Content:mkdir(targetVendorPath) then -- 2368
							return { -- 2369
								success = false, -- 2369
								message = "failed to create vendor folder" -- 2369
							} -- 2369
						end -- 2368
					elseif not Content:isdir(targetVendorPath) then -- 2370
						return { -- 2371
							success = false, -- 2371
							message = "vendor path is not a folder" -- 2371
						} -- 2371
					end -- 2367
					if Content:exist(targetDoraPath) then -- 2372
						if not Content:remove(targetDoraPath) then -- 2373
							return { -- 2374
								success = false, -- 2374
								message = "failed to remove old dora" -- 2374
							} -- 2374
						end -- 2373
					end -- 2372
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2375
						return { -- 2376
							success = false, -- 2376
							message = "failed to copy dora" -- 2376
						} -- 2376
					end -- 2375
					return { -- 2377
						success = true -- 2377
					} -- 2377
				else -- 2379
					return { -- 2379
						success = false, -- 2379
						message = 'Wa file needs a project' -- 2379
					} -- 2379
				end -- 2361
			end -- 2360
		end -- 2360
	end -- 2360
	return { -- 2359
		success = false, -- 2359
		message = "invalid call" -- 2359
	} -- 2359
end) -- 2359
HttpServer:postSchedule("/wa/build", function(req) -- 2381
	do -- 2382
		local _type_0 = type(req) -- 2382
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2382
		if _tab_0 then -- 2382
			local path -- 2382
			do -- 2382
				local _obj_0 = req.body -- 2382
				local _type_1 = type(_obj_0) -- 2382
				if "table" == _type_1 or "userdata" == _type_1 then -- 2382
					path = _obj_0.path -- 2382
				end -- 2382
			end -- 2382
			if path ~= nil then -- 2382
				local projDir = getWaProjectDirFromFile(path) -- 2383
				if projDir then -- 2383
					local message = Wasm:buildWaAsync(projDir) -- 2384
					if message == "" then -- 2385
						return { -- 2386
							success = true -- 2386
						} -- 2386
					else -- 2388
						return { -- 2388
							success = false, -- 2388
							message = message -- 2388
						} -- 2388
					end -- 2385
				else -- 2390
					return { -- 2390
						success = false, -- 2390
						message = 'Wa file needs a project' -- 2390
					} -- 2390
				end -- 2383
			end -- 2382
		end -- 2382
	end -- 2382
	return { -- 2391
		success = false, -- 2391
		message = 'failed to build' -- 2391
	} -- 2391
end) -- 2381
HttpServer:postSchedule("/wa/format", function(req) -- 2393
	do -- 2394
		local _type_0 = type(req) -- 2394
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2394
		if _tab_0 then -- 2394
			local file -- 2394
			do -- 2394
				local _obj_0 = req.body -- 2394
				local _type_1 = type(_obj_0) -- 2394
				if "table" == _type_1 or "userdata" == _type_1 then -- 2394
					file = _obj_0.file -- 2394
				end -- 2394
			end -- 2394
			if file ~= nil then -- 2394
				local code = Wasm:formatWaAsync(file) -- 2395
				if code == "" then -- 2396
					return { -- 2397
						success = false -- 2397
					} -- 2397
				else -- 2399
					return { -- 2399
						success = true, -- 2399
						code = code -- 2399
					} -- 2399
				end -- 2396
			end -- 2394
		end -- 2394
	end -- 2394
	return { -- 2400
		success = false -- 2400
	} -- 2400
end) -- 2393
HttpServer:postSchedule("/wa/create", function(req) -- 2402
	do -- 2403
		local _type_0 = type(req) -- 2403
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2403
		if _tab_0 then -- 2403
			local path -- 2403
			do -- 2403
				local _obj_0 = req.body -- 2403
				local _type_1 = type(_obj_0) -- 2403
				if "table" == _type_1 or "userdata" == _type_1 then -- 2403
					path = _obj_0.path -- 2403
				end -- 2403
			end -- 2403
			if path ~= nil then -- 2403
				if not Content:exist(Path:getPath(path)) then -- 2404
					return { -- 2405
						success = false, -- 2405
						message = "target path not existed" -- 2405
					} -- 2405
				end -- 2404
				if Content:exist(path) then -- 2406
					return { -- 2407
						success = false, -- 2407
						message = "target project folder existed" -- 2407
					} -- 2407
				end -- 2406
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2408
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2409
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2410
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2411
					return { -- 2414
						success = false, -- 2414
						message = "missing template project" -- 2414
					} -- 2414
				end -- 2411
				if not Content:mkdir(path) then -- 2415
					return { -- 2416
						success = false, -- 2416
						message = "failed to create project folder" -- 2416
					} -- 2416
				end -- 2415
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2417
					Content:remove(path) -- 2418
					return { -- 2419
						success = false, -- 2419
						message = "failed to copy template" -- 2419
					} -- 2419
				end -- 2417
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2420
					Content:remove(path) -- 2421
					return { -- 2422
						success = false, -- 2422
						message = "failed to copy template" -- 2422
					} -- 2422
				end -- 2420
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2423
					Content:remove(path) -- 2424
					return { -- 2425
						success = false, -- 2425
						message = "failed to copy template" -- 2425
					} -- 2425
				end -- 2423
				return { -- 2426
					success = true -- 2426
				} -- 2426
			end -- 2403
		end -- 2403
	end -- 2403
	return { -- 2402
		success = false, -- 2402
		message = "invalid call" -- 2402
	} -- 2402
end) -- 2402
local tsBuildGlobs = { -- 2429
	"**/*.ts", -- 2429
	"**/*.tsx", -- 2430
	"!**/.*/**", -- 2431
	"!**/node_modules/**" -- 2432
} -- 2428
local transpileTSFile -- 2434
do -- 2434
	local tsBuildTimeout <const> = 30 -- 2435
	local tsBuildRequestId = 0 -- 2436
	transpileTSFile = function(file, content, sourceRoot) -- 2437
		tsBuildRequestId = tsBuildRequestId + 1 -- 2438
		local requestId = tsBuildRequestId -- 2439
		local done = false -- 2440
		local result = nil -- 2441
		local listener = Node() -- 2442
		listener:gslot("AppWS", function(event) -- 2443
			if event.type == "Receive" then -- 2444
				local res = json.decode(event.msg) -- 2445
				if res then -- 2445
					if res.name == "TranspileTS" and res.id == requestId then -- 2446
						listener:removeFromParent() -- 2447
						if res.success then -- 2448
							local luaFile = Path:replaceExt(file, "lua") -- 2449
							Content:save(luaFile, res.luaCode) -- 2450
							result = { -- 2451
								success = true, -- 2451
								file = file -- 2451
							} -- 2451
						else -- 2453
							result = { -- 2453
								success = false, -- 2453
								file = file, -- 2453
								message = res.message -- 2453
							} -- 2453
						end -- 2448
						done = true -- 2454
					end -- 2446
				end -- 2445
			end -- 2444
		end) -- 2443
		emit("AppWS", "Send", json.encode({ -- 2455
			name = "TranspileTS", -- 2455
			id = requestId, -- 2455
			file = file, -- 2455
			content = content, -- 2455
			projectRoot = sourceRoot -- 2455
		})) -- 2455
		local deadline = App.runningTime + tsBuildTimeout -- 2456
		wait(function() -- 2457
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline -- 2457
		end) -- 2457
		if not done then -- 2458
			listener:removeFromParent() -- 2459
			if HttpServer.wsConnectionCount == 0 then -- 2460
				return { -- 2461
					success = false, -- 2461
					file = file, -- 2461
					message = "Web IDE disconnected" -- 2461
				} -- 2461
			end -- 2460
			return { -- 2462
				success = false, -- 2462
				file = file, -- 2462
				message = "TypeScript transpile timed out" -- 2462
			} -- 2462
		end -- 2458
		return result -- 2463
	end -- 2437
end -- 2434
local _anon_func_7 = function(path) -- 2474
	local _val_0 = Path:getExt(path) -- 2474
	return "ts" == _val_0 or "tsx" == _val_0 -- 2474
end -- 2474
HttpServer:postSchedule("/ts/build", function(req) -- 2465
	do -- 2466
		local _type_0 = type(req) -- 2466
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2466
		if _tab_0 then -- 2466
			local path -- 2466
			do -- 2466
				local _obj_0 = req.body -- 2466
				local _type_1 = type(_obj_0) -- 2466
				if "table" == _type_1 or "userdata" == _type_1 then -- 2466
					path = _obj_0.path -- 2466
				end -- 2466
			end -- 2466
			if path ~= nil then -- 2466
				if HttpServer.wsConnectionCount == 0 then -- 2467
					return { -- 2468
						success = false, -- 2468
						message = "Web IDE not connected" -- 2468
					} -- 2468
				end -- 2467
				local projectRoot = req.body.projectRoot -- 2469
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2470
				if not Content:exist(path) then -- 2471
					return { -- 2472
						success = false, -- 2472
						message = "path not existed" -- 2472
					} -- 2472
				end -- 2471
				if not Content:isdir(path) then -- 2473
					if not (_anon_func_7(path)) then -- 2474
						return { -- 2475
							success = false, -- 2475
							message = "expecting a TypeScript file" -- 2475
						} -- 2475
					end -- 2474
					local messages = { } -- 2476
					local content = Content:load(path) -- 2477
					if not content then -- 2478
						return { -- 2479
							success = false, -- 2479
							message = "failed to read file" -- 2479
						} -- 2479
					end -- 2478
					emit("AppWS", "Send", json.encode({ -- 2480
						name = "UpdateFile", -- 2480
						file = path, -- 2480
						exists = true, -- 2480
						content = content, -- 2480
						projectRoot = sourceRoot -- 2480
					})) -- 2480
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2481
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot) -- 2482
					end -- 2481
					return { -- 2483
						success = true, -- 2483
						messages = messages -- 2483
					} -- 2483
				else -- 2485
					local fileData = { } -- 2485
					local messages = { } -- 2486
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2487
					for _index_0 = 1, #_list_0 do -- 2487
						local subFile = _list_0[_index_0] -- 2487
						local file = Path(path, subFile) -- 2488
						local content = Content:load(file) -- 2489
						if content then -- 2489
							fileData[file] = content -- 2490
							emit("AppWS", "Send", json.encode({ -- 2491
								name = "UpdateFile", -- 2491
								file = file, -- 2491
								exists = true, -- 2491
								content = content, -- 2491
								projectRoot = sourceRoot -- 2491
							})) -- 2491
						else -- 2493
							messages[#messages + 1] = { -- 2493
								success = false, -- 2493
								file = file, -- 2493
								message = "failed to read file" -- 2493
							} -- 2493
						end -- 2489
					end -- 2487
					for file, content in pairs(fileData) do -- 2494
						if "d" == Path:getExt(Path:getName(file)) then -- 2495
							goto _continue_0 -- 2495
						end -- 2495
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot) -- 2496
						::_continue_0:: -- 2495
					end -- 2494
					return { -- 2497
						success = true, -- 2497
						messages = messages -- 2497
					} -- 2497
				end -- 2473
			end -- 2466
		end -- 2466
	end -- 2466
	return { -- 2465
		success = false -- 2465
	} -- 2465
end) -- 2465
HttpServer:post("/download", function(req) -- 2499
	do -- 2500
		local _type_0 = type(req) -- 2500
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2500
		if _tab_0 then -- 2500
			local url -- 2500
			do -- 2500
				local _obj_0 = req.body -- 2500
				local _type_1 = type(_obj_0) -- 2500
				if "table" == _type_1 or "userdata" == _type_1 then -- 2500
					url = _obj_0.url -- 2500
				end -- 2500
			end -- 2500
			local target -- 2500
			do -- 2500
				local _obj_0 = req.body -- 2500
				local _type_1 = type(_obj_0) -- 2500
				if "table" == _type_1 or "userdata" == _type_1 then -- 2500
					target = _obj_0.target -- 2500
				end -- 2500
			end -- 2500
			if url ~= nil and target ~= nil then -- 2500
				local Entry = require("Script.Dev.Entry") -- 2501
				Entry.downloadFile(url, target) -- 2502
				return { -- 2503
					success = true -- 2503
				} -- 2503
			end -- 2500
		end -- 2500
	end -- 2500
	return { -- 2499
		success = false -- 2499
	} -- 2499
end) -- 2499
local isDesktopPlatform -- 2505
isDesktopPlatform = function() -- 2505
	local _val_0 = App.platform -- 2506
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2506
end -- 2505
local getServerStatus -- 2508
getServerStatus = function() -- 2508
	local Entry = require("Script.Dev.Entry") -- 2509
	local running = Entry.getCurrentEntryStatus() -- 2510
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2511
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2512
	return { -- 2514
		success = true, -- 2514
		platform = App.platform, -- 2515
		locale = App.locale, -- 2516
		version = App.version, -- 2517
		url = "http://localhost:8866", -- 2518
		wsConnectionCount = wsConnectionCount, -- 2519
		webIDEConnected = wsConnectionCount > 0, -- 2520
		assetPath = Content.assetPath, -- 2521
		writablePath = Content.writablePath, -- 2522
		appPath = Content.appPath, -- 2523
		waTemplateReady = waTemplateReady, -- 2524
		running = running -- 2525
	} -- 2513
end -- 2508
HttpServer:post("/status", function() -- 2528
	return getServerStatus() -- 2529
end) -- 2528
HttpServer:postSchedule("/doctor/fix", function(req) -- 2531
	do -- 2532
		local _type_0 = type(req) -- 2532
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2532
		if _tab_0 then -- 2532
			local openWebIDE -- 2532
			do -- 2532
				local _obj_0 = req.body -- 2532
				local _type_1 = type(_obj_0) -- 2532
				if "table" == _type_1 or "userdata" == _type_1 then -- 2532
					openWebIDE = _obj_0.openWebIDE -- 2532
				end -- 2532
			end -- 2532
			if openWebIDE ~= nil then -- 2532
				if not openWebIDE then -- 2533
					return { -- 2534
						success = false, -- 2534
						message = "nothing to fix" -- 2534
					} -- 2534
				end -- 2533
				local status = getServerStatus() -- 2535
				if status.webIDEConnected then -- 2536
					return { -- 2537
						success = true, -- 2537
						fixed = false, -- 2537
						message = "Web IDE already connected.", -- 2537
						status = status -- 2537
					} -- 2537
				end -- 2536
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2538
				if waitSeconds > 0 then -- 2539
					local deadline = os.time() + waitSeconds -- 2540
					repeat -- 2541
						sleep(0.2) -- 2542
						status = getServerStatus() -- 2543
						if status.webIDEConnected then -- 2544
							return { -- 2545
								success = true, -- 2545
								fixed = false, -- 2545
								reconnected = true, -- 2545
								message = "Web IDE reconnected.", -- 2545
								status = status -- 2545
							} -- 2545
						end -- 2544
					until os.time() >= deadline -- 2541
				end -- 2539
				if not isDesktopPlatform() then -- 2547
					return { -- 2548
						success = false, -- 2548
						message = "opening Web IDE is only supported on desktop platforms", -- 2548
						status = status -- 2548
					} -- 2548
				end -- 2547
				local url = "http://localhost:8866" -- 2549
				App:openURL(url) -- 2550
				status.openedURL = url -- 2551
				return { -- 2552
					success = true, -- 2552
					fixed = true, -- 2552
					message = "Opened Web IDE in the local browser.", -- 2552
					url = url, -- 2552
					status = status -- 2552
				} -- 2552
			end -- 2532
		end -- 2532
	end -- 2532
	return { -- 2531
		success = false, -- 2531
		message = "invalid call" -- 2531
	} -- 2531
end) -- 2531
local status = { } -- 2554
_module_0 = status -- 2555
status.buildAsync = function(path) -- 2557
	if not Content:exist(path) then -- 2558
		return { -- 2559
			success = false, -- 2559
			file = path, -- 2559
			message = "file not existed" -- 2559
		} -- 2559
	end -- 2558
	do -- 2560
		local _exp_0 = Path:getExt(path) -- 2560
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2560
			if '' == Path:getExt(Path:getName(path)) then -- 2561
				local content = Content:loadAsync(path) -- 2562
				if content then -- 2562
					local resultCodes, err = compileFileAsync(path, content) -- 2563
					if resultCodes then -- 2563
						return { -- 2564
							success = true, -- 2564
							file = path -- 2564
						} -- 2564
					else -- 2566
						return { -- 2566
							success = false, -- 2566
							file = path, -- 2566
							message = err -- 2566
						} -- 2566
					end -- 2563
				end -- 2562
			end -- 2561
		elseif "lua" == _exp_0 then -- 2567
			local content = Content:loadAsync(path) -- 2568
			if content then -- 2568
				do -- 2569
					local isTIC80 = CheckTIC80Code(content) -- 2569
					if isTIC80 then -- 2569
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2570
					end -- 2569
				end -- 2569
				local success, info -- 2571
				do -- 2571
					local _obj_0 = luaCheck(path, content) -- 2571
					success, info = _obj_0.success, _obj_0.info -- 2571
				end -- 2571
				if success then -- 2572
					return { -- 2573
						success = true, -- 2573
						file = path -- 2573
					} -- 2573
				elseif info and #info > 0 then -- 2574
					local messages = { } -- 2575
					for _index_0 = 1, #info do -- 2576
						local _des_0 = info[_index_0] -- 2576
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2576
						local lineText = "" -- 2577
						if line then -- 2578
							local currentLine = 1 -- 2579
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2580
								if currentLine == line then -- 2581
									lineText = text -- 2582
									break -- 2583
								end -- 2581
								currentLine = currentLine + 1 -- 2584
							end -- 2580
						end -- 2578
						if line then -- 2585
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2586
						else -- 2588
							messages[#messages + 1] = message -- 2588
						end -- 2585
					end -- 2576
					return { -- 2589
						success = false, -- 2589
						file = path, -- 2589
						message = table.concat(messages, "\n") -- 2589
					} -- 2589
				else -- 2591
					return { -- 2591
						success = false, -- 2591
						file = path, -- 2591
						message = "lua check failed" -- 2591
					} -- 2591
				end -- 2572
			end -- 2568
		elseif "yarn" == _exp_0 then -- 2592
			local content = Content:loadAsync(path) -- 2593
			if content then -- 2593
				local res, _, err = yarncompile(content, true) -- 2594
				if res then -- 2594
					return { -- 2595
						success = true, -- 2595
						file = path -- 2595
					} -- 2595
				else -- 2597
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2597
					local lineText = "" -- 2598
					if line then -- 2599
						local currentLine = 1 -- 2600
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2601
							if currentLine == line then -- 2602
								lineText = text -- 2603
								break -- 2604
							end -- 2602
							currentLine = currentLine + 1 -- 2605
						end -- 2601
					end -- 2599
					if node ~= "" then -- 2606
						node = "node: " .. tostring(node) .. ", " -- 2607
					else -- 2608
						node = "" -- 2608
					end -- 2606
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2609
					return { -- 2610
						success = false, -- 2610
						file = path, -- 2610
						message = message -- 2610
					} -- 2610
				end -- 2594
			end -- 2593
		end -- 2560
	end -- 2560
	return { -- 2611
		success = false, -- 2611
		file = path, -- 2611
		message = "invalid file to build" -- 2611
	} -- 2611
end -- 2557
HttpServer:postSchedule("/git/commit-files", function(req) -- 2613
	do -- 2614
		local _type_0 = type(req) -- 2614
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2614
		if _tab_0 then -- 2614
			local body = req.body -- 2614
			if body ~= nil then -- 2614
				local repoPath, commit = body.repoPath, body.commit -- 2615
				if gitInvalidRepoPath(repoPath) then -- 2616
					return { -- 2616
						success = false, -- 2616
						message = "invalid repoPath" -- 2616
					} -- 2616
				end -- 2616
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 2617
					return { -- 2617
						success = false, -- 2617
						message = "invalid commit" -- 2617
					} -- 2617
				end -- 2617
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 2618
				if not res.success then -- 2619
					return res -- 2619
				end -- 2619
				return { -- 2620
					success = true, -- 2620
					status = res.status, -- 2620
					data = res.status and res.status.data -- 2620
				} -- 2620
			end -- 2614
		end -- 2614
	end -- 2614
	return invalidArguments -- 2613
end) -- 2613
thread(function() -- 2622
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 2623
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 2624
	if Content:exist(doraWeb) then -- 2625
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) -- 2626
		local needReload -- 2627
		if Content:exist(doraReady) then -- 2627
			needReload = readyContent ~= Content:load(doraReady) -- 2628
		else -- 2629
			needReload = true -- 2629
		end -- 2627
		if needReload then -- 2630
			Content:remove(Path(Content.appPath, ".www")) -- 2631
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 2632
			Content:save(doraReady, readyContent) -- 2636
			print("Dora Dora is ready!") -- 2637
		end -- 2630
	end -- 2625
	HttpServer:clearStaticCacheControls() -- 2638
	HttpServer:setStaticCacheControl("no-cache") -- 2639
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 2640
	if HttpServer:start(8866) then -- 2644
		local localIP = HttpServer.localIP -- 2645
		if localIP == "" then -- 2646
			localIP = "localhost" -- 2646
		end -- 2646
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 2647
		return HttpServer:startWS(8868) -- 2648
	else -- 2650
		status.url = nil -- 2650
		return print("8866 Port not available!") -- 2651
	end -- 2644
end) -- 2622
return _module_0 -- 1
