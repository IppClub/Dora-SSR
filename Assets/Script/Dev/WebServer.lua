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
local getProjectSourceRoot -- 116
getProjectSourceRoot = function(projectRoot) -- 116
	if not (projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot)) then -- 117
		return nil -- 117
	end -- 117
	return projectRoot -- 118
end -- 116
local isProjectRootDir -- 120
isProjectRootDir = function(dir) -- 120
	if not (dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir)) then -- 121
		return false -- 121
	end -- 121
	local _list_0 = Content:getFiles(dir) -- 122
	for _index_0 = 1, #_list_0 do -- 122
		local f = _list_0[_index_0] -- 122
		if Path:getName(f):lower() == "init" then -- 123
			return true -- 124
		end -- 123
	end -- 122
	return false -- 125
end -- 120
local getProjectRootFromPath -- 127
getProjectRootFromPath = function(target, isDir) -- 127
	if isDir == nil then -- 127
		isDir = false -- 127
	end -- 127
	if not (target and target ~= "" and Content:isAbsolutePath(target)) then -- 128
		return nil, "invalid path" -- 128
	end -- 128
	if isDir then -- 129
		if target == Content.writablePath or isProjectRootDir(target) then -- 130
			return target -- 130
		end -- 130
		return getProjectDirFromFile(Path(target, "__dora_project_root_search__.lua"), "current directory does not belong to any project") -- 131
	end -- 129
	return getProjectDirFromFile(target, "current file does not belong to any project") -- 132
end -- 127
local invalidArguments = { -- 134
	success = false, -- 134
	message = "invalid arguments" -- 134
} -- 134
HttpServer:post("/agent/project-root", function(req) -- 136
	do -- 137
		local _type_0 = type(req) -- 137
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 137
		if _tab_0 then -- 137
			local path -- 137
			do -- 137
				local _obj_0 = req.body -- 137
				local _type_1 = type(_obj_0) -- 137
				if "table" == _type_1 or "userdata" == _type_1 then -- 137
					path = _obj_0.path -- 137
				end -- 137
			end -- 137
			local isDir -- 137
			do -- 137
				local _obj_0 = req.body -- 137
				local _type_1 = type(_obj_0) -- 137
				if "table" == _type_1 or "userdata" == _type_1 then -- 137
					isDir = _obj_0.isDir -- 137
				end -- 137
			end -- 137
			if path ~= nil and isDir ~= nil then -- 137
				local projectRoot, err = getProjectRootFromPath(path, isDir) -- 138
				if projectRoot then -- 138
					return { -- 139
						success = true, -- 139
						found = true, -- 139
						projectRoot = projectRoot, -- 139
						title = Path:getFilename(projectRoot) -- 139
					} -- 139
				else -- 141
					return { -- 141
						success = true, -- 141
						found = false, -- 141
						message = err -- 141
					} -- 141
				end -- 138
			end -- 137
		end -- 137
	end -- 137
	return invalidArguments -- 136
end) -- 136
local AgentTools = require("Agent.Tools") -- 143
local AgentSession = require("Agent.AgentSession") -- 144
local GitJobs = { } -- 146
local gitTerminalState -- 148
gitTerminalState = function(status) -- 148
	if not (status and status.state) then -- 149
		return false -- 149
	end -- 149
	local _val_0 = status.state -- 150
	return "done" == _val_0 or "error" == _val_0 or "canceled" == _val_0 -- 150
end -- 148
local gitInvalidRepoPath -- 152
gitInvalidRepoPath = function(repoPath) -- 152
	return not repoPath or repoPath == "" or not Content:isAbsolutePath(repoPath) -- 153
end -- 152
local gitShellSplit -- 155
gitShellSplit = function(command) -- 155
	local args = { } -- 156
	local current = { } -- 157
	local quote = nil -- 158
	local escape = false -- 159
	for i = 1, #command do -- 160
		local ch = command:sub(i, i) -- 161
		if escape then -- 162
			current[#current + 1] = ch -- 163
			escape = false -- 164
		elseif ch == "\\" then -- 165
			escape = true -- 166
		elseif quote then -- 167
			if ch == quote then -- 168
				quote = nil -- 169
			else -- 171
				current[#current + 1] = ch -- 171
			end -- 168
		elseif ch == "'" or ch == '"' then -- 172
			quote = ch -- 173
		elseif ch:match("%s") then -- 174
			if #current > 0 then -- 175
				args[#args + 1] = table.concat(current) -- 176
				current = { } -- 177
			end -- 175
		else -- 179
			current[#current + 1] = ch -- 179
		end -- 162
	end -- 160
	if #current > 0 then -- 180
		args[#args + 1] = table.concat(current) -- 181
	end -- 180
	if args[1] == "git" then -- 182
		table.remove(args, 1) -- 183
	end -- 182
	return args -- 184
end -- 155
local gitQuote -- 186
gitQuote = function(value) -- 186
	local text = tostring(value) -- 187
	if text:match("^[%w%._%-%/]+$") then -- 188
		return text -- 189
	end -- 188
	return "\"" .. text:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"" -- 190
end -- 186
local gitDirNonEmpty -- 192
gitDirNonEmpty = function(targetPath) -- 192
	if not Content:exist(targetPath) then -- 193
		return false -- 193
	end -- 193
	if not Content:isdir(targetPath) then -- 194
		return false -- 194
	end -- 194
	return #Content:getFiles(targetPath) > 0 or #Content:getDirs(targetPath) > 0 -- 195
end -- 192
local gitSafeChildPath -- 197
gitSafeChildPath = function(parentPath, childPath) -- 197
	if not (parentPath and childPath and childPath ~= "") then -- 198
		return nil -- 198
	end -- 198
	if childPath:sub(1, 1) == "/" or childPath:match("^%a:[/\\]") then -- 199
		return nil -- 199
	end -- 199
	if childPath == "." or childPath:match("^%.%.[/\\]?" or childPath:match("[/\\]%.%.[/\\]")) then -- 200
		return nil -- 200
	end -- 200
	local targetPath = Path(parentPath, childPath) -- 201
	local relative = Path:getRelative(targetPath, parentPath) -- 202
	if relative == ".." or relative:sub(1, 3) == "../" or relative:sub(1, 3) == "..\\" then -- 203
		return nil -- 203
	end -- 203
	return targetPath -- 204
end -- 197
local gitCloneDirFromURL -- 206
gitCloneDirFromURL = function(url) -- 206
	if not (url and url ~= "") then -- 207
		return nil -- 207
	end -- 207
	local text = tostring(url):match("^%s*(.-)%s*$") -- 208
	if text == "" then -- 209
		return nil -- 209
	end -- 209
	text = text:gsub("[/\\]+$", "") -- 210
	local name = text:match("([^/:]+)$") -- 211
	if not (name and name ~= "") then -- 212
		return nil -- 212
	end -- 212
	name = name:gsub("%.git$", "") -- 213
	if name == "" or name == "." or name == ".." then -- 214
		return nil -- 214
	end -- 214
	return name -- 215
end -- 206
local gitCloneTargetPath -- 217
gitCloneTargetPath = function(repoPath, command) -- 217
	local args = gitShellSplit(command) -- 218
	if not (args[1] == "clone") then -- 219
		return nil -- 219
	end -- 219
	local url = args[2] -- 220
	local index = 3 -- 221
	while index <= #args do -- 222
		local arg = args[index] -- 223
		if ("-b" == arg or "--branch" == arg or "--depth" == arg) then -- 224
			index = index + 2 -- 225
		elseif arg:sub(1, 1) == "-" then -- 226
			index = index + 1 -- 227
		else -- 229
			return gitSafeChildPath(repoPath, arg) -- 229
		end -- 224
	end -- 222
	do -- 230
		local dirName = gitCloneDirFromURL(url) -- 230
		if dirName then -- 230
			return gitSafeChildPath(repoPath, dirName) -- 231
		end -- 230
	end -- 230
	return nil -- 232
end -- 217
local gitPathInsideRepo -- 234
gitPathInsideRepo = function(repoPath, relPath) -- 234
	if not (repoPath and relPath and relPath ~= "") then -- 235
		return false -- 235
	end -- 235
	if relPath:sub(1, 1) == "/" or relPath:match("^%a:[/\\]") then -- 236
		return false -- 236
	end -- 236
	if relPath == "." or relPath:match("^%.%.[/\\]?" or relPath:match("[/\\]%.%.[/\\]")) then -- 237
		return false -- 237
	end -- 237
	local targetPath = Path(repoPath, relPath) -- 238
	local relative = Path:getRelative(targetPath, repoPath) -- 239
	return relative ~= ".." and relative:sub(1, 3) ~= "../" and relative:sub(1, 3) ~= "..\\" -- 240
end -- 234
local gitHostFromURL -- 242
gitHostFromURL = function(url) -- 242
	if not (url and url ~= "") then -- 243
		return nil -- 243
	end -- 243
	local text = tostring(url):match("^%s*(.-)%s*$") -- 244
	if text == "" then -- 245
		return nil -- 245
	end -- 245
	local host = text:match("^[%w_%-]+://([^/:]+)") -- 246
	if not host then -- 247
		host = text:match("@([^:/]+)[:/]") -- 247
	end -- 247
	if not host then -- 248
		host = text:match("^([^:/]+):[^/]") -- 248
	end -- 248
	if not (host and host ~= "") then -- 249
		return nil -- 249
	end -- 249
	return string.lower(host) -- 250
end -- 242
local ensureGitTables -- 252
ensureGitTables = function() -- 252
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
	]]) -- 253
	DB:exec("CREATE INDEX IF NOT EXISTS idx_git_credential_host ON GitCredential(host);") -- 266
	return DB:exec([[		CREATE TABLE IF NOT EXISTS GitProfile(
			id INTEGER PRIMARY KEY CHECK(id = 1),
			name TEXT NOT NULL DEFAULT '',
			email TEXT NOT NULL DEFAULT '',
			updated_at INTEGER
		);
	]]) -- 267
end -- 252
local gitCredentialToPublic -- 276
gitCredentialToPublic = function(row) -- 276
	local id, host, label, typeName, username, createdAt, updatedAt, lastUsedAt = row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8] -- 277
	return { -- 278
		id = id, -- 278
		host = host, -- 278
		label = label, -- 278
		type = typeName, -- 278
		username = username, -- 278
		createdAt = createdAt, -- 278
		updatedAt = updatedAt, -- 278
		lastUsedAt = lastUsedAt -- 278
	} -- 278
end -- 276
local gitLoadCredential -- 280
gitLoadCredential = function(id) -- 280
	ensureGitTables() -- 281
	local credentialId = tonumber(id) or 0 -- 282
	local rows = DB:query("select id, host, label, type, username, secret from GitCredential where id = ? limit 1", { -- 283
		credentialId -- 283
	}) -- 283
	if not (rows and rows[1]) then -- 284
		return nil -- 284
	end -- 284
	local row = rows[1] -- 285
	return { -- 286
		id = row[1], -- 286
		host = row[2], -- 286
		label = row[3], -- 286
		type = row[4], -- 286
		username = row[5], -- 286
		secret = row[6] -- 286
	} -- 286
end -- 280
local gitAuthOptionsJSON -- 288
gitAuthOptionsJSON = function(credential) -- 288
	if not credential then -- 289
		return nil -- 289
	end -- 289
	local auth -- 290
	if credential.type == "token" then -- 290
		auth = { -- 292
			type = "token", -- 292
			token = credential.secret, -- 293
			username = credential.username ~= "" and credential.username or "token" -- 294
		} -- 291
	else -- 297
		auth = { -- 298
			type = "basic", -- 298
			username = credential.username, -- 299
			password = credential.secret -- 300
		} -- 297
	end -- 290
	return json.encode({ -- 302
		auth = auth -- 302
	}) -- 302
end -- 288
local gitLoadProfile -- 304
gitLoadProfile = function() -- 304
	ensureGitTables() -- 305
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 306
	if not (rows and rows[1]) then -- 307
		return nil -- 307
	end -- 307
	local name = tostring(rows[1][1] or "") -- 308
	local email = tostring(rows[1][2] or "") -- 309
	if name == "" and email == "" then -- 310
		return nil -- 310
	end -- 310
	return { -- 311
		name = name, -- 311
		email = email -- 311
	} -- 311
end -- 304
local _anon_func_2 = function(args, gitQuote) -- 330
	local _accum_0 = { } -- 330
	local _len_0 = 1 -- 330
	for _index_0 = 1, #args do -- 330
		local arg = args[_index_0] -- 330
		_accum_0[_len_0] = gitQuote(arg) -- 330
		_len_0 = _len_0 + 1 -- 330
	end -- 330
	return _accum_0 -- 330
end -- 330
local gitApplyProfileToCommit -- 313
gitApplyProfileToCommit = function(command) -- 313
	local args = gitShellSplit(command) -- 314
	if not (args[1] == "commit") then -- 315
		return command -- 315
	end -- 315
	local hasName = false -- 316
	local hasEmail = false -- 317
	for _index_0 = 1, #args do -- 318
		local arg = args[_index_0] -- 318
		if arg == "--author-name" then -- 319
			hasName = true -- 319
		end -- 319
		if arg == "--author-email" then -- 320
			hasEmail = true -- 320
		end -- 320
	end -- 318
	if hasName and hasEmail then -- 321
		return command -- 321
	end -- 321
	local profile = gitLoadProfile() -- 322
	if not profile then -- 323
		return command -- 323
	end -- 323
	if not hasName and profile.name ~= "" then -- 324
		args[#args + 1] = "--author-name" -- 325
		args[#args + 1] = profile.name -- 326
	end -- 324
	if not hasEmail and profile.email ~= "" then -- 327
		args[#args + 1] = "--author-email" -- 328
		args[#args + 1] = profile.email -- 329
	end -- 327
	return table.concat(_anon_func_2(args, gitQuote), " ") -- 330
end -- 313
local gitStartJob -- 332
gitStartJob = function(repoPath, command, optionsJSON) -- 332
	if optionsJSON == nil then -- 332
		optionsJSON = nil -- 332
	end -- 332
	if gitInvalidRepoPath(repoPath) then -- 333
		return nil, "invalid repoPath" -- 333
	end -- 333
	if not (command and command ~= "") then -- 334
		return nil, "invalid command" -- 334
	end -- 334
	if not optionsJSON then -- 335
		optionsJSON = "" -- 335
	end -- 335
	command = gitApplyProfileToCommit(command) -- 336
	do -- 337
		local targetPath = gitCloneTargetPath(repoPath, command) -- 337
		if targetPath then -- 337
			if gitDirNonEmpty(targetPath) then -- 338
				return nil, "clone target directory is not empty" -- 339
			end -- 338
		elseif (gitShellSplit(command))[1] == "clone" then -- 340
			return nil, "invalid clone target" -- 341
		end -- 337
	end -- 337
	local statusRef = nil -- 342
	local startGit -- 343
	startGit = function() -- 343
		return Git:run(repoPath, command, (function(status) -- 344
			statusRef = status -- 345
			GitJobs[status.id] = { -- 347
				command = command, -- 347
				status = status, -- 348
				updatedAt = os.time() -- 349
			} -- 346
		end), optionsJSON) -- 344
	end -- 343
	local success, jobId = pcall(startGit) -- 351
	if not success then -- 352
		return nil, tostring(jobId) -- 352
	end -- 352
	if not jobId then -- 353
		return nil, "Git.run did not return a job id" -- 353
	end -- 353
	GitJobs[jobId] = { -- 355
		command = command, -- 355
		status = statusRef or { -- 357
			id = jobId, -- 357
			state = "queued", -- 358
			kind = gitShellSplit(command)[1] or "status", -- 359
			repoPath = repoPath, -- 360
			progress = 0, -- 361
			message = "queued" -- 362
		}, -- 356
		updatedAt = os.time() -- 364
	} -- 354
	return jobId -- 365
end -- 332
local gitRunSync -- 367
gitRunSync = function(repoPath, command, optionsJSON, timeout) -- 367
	if optionsJSON == nil then -- 367
		optionsJSON = nil -- 367
	end -- 367
	if timeout == nil then -- 367
		timeout = 20 -- 367
	end -- 367
	local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 368
	if not jobId then -- 369
		return { -- 369
			success = false, -- 369
			message = err -- 369
		} -- 369
	end -- 369
	local startedAt = os.time() -- 370
	wait(function() -- 371
		local job = GitJobs[jobId] -- 372
		local status = job and job.status -- 373
		return gitTerminalState(status) or os.time() - startedAt >= timeout -- 374
	end) -- 371
	local status = GitJobs[jobId] and GitJobs[jobId].status -- 375
	if not gitTerminalState(status) then -- 376
		Git:cancel(jobId) -- 377
		return { -- 378
			success = false, -- 378
			message = "git command timed out", -- 378
			jobId = jobId, -- 378
			status = status -- 378
		} -- 378
	end -- 376
	return { -- 379
		success = status.state == "done", -- 379
		jobId = jobId, -- 379
		status = status, -- 379
		message = status.error or status.message -- 379
	} -- 379
end -- 367
local gitCredentialsForHost -- 381
gitCredentialsForHost = function(host) -- 381
	if not (host and host ~= "") then -- 382
		return { } -- 382
	end -- 382
	ensureGitTables() -- 383
	local rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by last_used_at desc, label asc, id asc", { -- 384
		host -- 384
	}) -- 384
	if rows then -- 385
		local _accum_0 = { } -- 386
		local _len_0 = 1 -- 386
		for _index_0 = 1, #rows do -- 386
			local row = rows[_index_0] -- 386
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 386
			_len_0 = _len_0 + 1 -- 386
		end -- 386
		return _accum_0 -- 386
	else -- 387
		return { } -- 387
	end -- 385
end -- 381
local gitFirstRemoteURL -- 389
gitFirstRemoteURL = function(repoPath, remoteName) -- 389
	if remoteName == nil then -- 389
		remoteName = nil -- 389
	end -- 389
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 10) -- 390
	local data = remoteRes.status and remoteRes.status.data -- 391
	if not (data and data.remotes) then -- 392
		return nil -- 392
	end -- 392
	local _list_0 = data.remotes -- 393
	for _index_0 = 1, #_list_0 do -- 393
		local remote = _list_0[_index_0] -- 393
		if (not remoteName or remote.name == remoteName) and remote.urls and remote.urls[1] then -- 394
			return remote.urls[1] -- 395
		end -- 394
	end -- 393
	return nil -- 396
end -- 389
local gitConfigRemoteURL -- 398
gitConfigRemoteURL = function(repoPath, remoteName) -- 398
	if remoteName == nil then -- 398
		remoteName = nil -- 398
	end -- 398
	if gitInvalidRepoPath(repoPath) then -- 399
		return nil -- 399
	end -- 399
	local configPath = Path(repoPath, ".git/config") -- 400
	if not Content:exist(configPath) then -- 401
		return nil -- 401
	end -- 401
	local content = Content:load(configPath) -- 402
	if not (content and content ~= "") then -- 403
		return nil -- 403
	end -- 403
	local currentRemote = nil -- 404
	for line in content:gmatch("[^\r\n]+") do -- 405
		local sectionRemote = line:match('^%s*%[remote%s+"([^"]+)"%]%s*$') -- 406
		if sectionRemote then -- 407
			currentRemote = sectionRemote -- 408
		elseif currentRemote and (not remoteName or currentRemote == remoteName) then -- 409
			local url = line:match("^%s*url%s*=%s*(.-)%s*$") -- 410
			if url and url ~= "" then -- 411
				return url -- 411
			end -- 411
		end -- 407
	end -- 405
	return nil -- 412
end -- 398
local gitCommandRemoteArg -- 414
gitCommandRemoteArg = function(args, startIndex) -- 414
	if startIndex == nil then -- 414
		startIndex = 2 -- 414
	end -- 414
	local index = startIndex -- 415
	while index <= #args do -- 416
		local arg = args[index] -- 417
		if ("-u" == arg or "--set-upstream" == arg or "-f" == arg or "--force" == arg or "--all" == arg or "--prune" == arg) then -- 418
			index = index + 1 -- 419
		elseif ("--depth" == arg or "-b" == arg or "--branch" == arg) then -- 420
			index = index + 2 -- 421
		elseif arg and arg:sub(1, 1) == "-" then -- 422
			index = index + 1 -- 423
		else -- 425
			return arg -- 425
		end -- 418
	end -- 416
	return nil -- 426
end -- 414
local gitCommandHost -- 428
gitCommandHost = function(repoPath, command) -- 428
	local args = gitShellSplit(command) -- 429
	if not args[1] then -- 430
		return nil -- 430
	end -- 430
	do -- 431
		local _exp_0 = args[1] -- 431
		if "clone" == _exp_0 or "ls-remote" == _exp_0 then -- 432
			return gitHostFromURL(args[2]) -- 433
		elseif "fetch" == _exp_0 or "pull" == _exp_0 or "push" == _exp_0 then -- 434
			local remoteArg = gitCommandRemoteArg(args, 2) -- 435
			if not remoteArg then -- 436
				return nil -- 436
			end -- 436
			local url = gitHostFromURL(remoteArg) -- 437
			if url then -- 438
				return url -- 438
			end -- 438
			return gitHostFromURL(gitConfigRemoteURL(repoPath, remoteArg)) -- 439
		end -- 431
	end -- 431
	return nil -- 440
end -- 428
local gitAuthSelectionForCommand -- 442
gitAuthSelectionForCommand = function(repoPath, command) -- 442
	local host = gitCommandHost(repoPath, command) -- 443
	if not host then -- 444
		return nil -- 444
	end -- 444
	local items = gitCredentialsForHost(host) -- 445
	if #items == 0 then -- 446
		return nil -- 446
	end -- 446
	return { -- 447
		host = host, -- 447
		items = items -- 447
	} -- 447
end -- 442
local gitDefaultRemote -- 449
gitDefaultRemote = function(remoteStatus) -- 449
	local data = remoteStatus and remoteStatus.data -- 450
	if not (data and data.remotes and data.remotes[1]) then -- 451
		return nil -- 451
	end -- 451
	return data.remotes[1] -- 452
end -- 449
local gitCurrentBranch -- 454
gitCurrentBranch = function(branchStatus) -- 454
	local data = branchStatus and branchStatus.data -- 455
	if data and data.current and data.current ~= "" then -- 456
		return data.current -- 457
	end -- 456
	if data and data.branches then -- 458
		local _list_0 = data.branches -- 459
		for _index_0 = 1, #_list_0 do -- 459
			local branch = _list_0[_index_0] -- 459
			if branch.current then -- 460
				return branch.name -- 460
			end -- 460
		end -- 459
	end -- 458
	return nil -- 461
end -- 454
local gitHeadBranch -- 463
gitHeadBranch = function(repoPath) -- 463
	if gitInvalidRepoPath(repoPath) then -- 464
		return nil -- 464
	end -- 464
	local headPath = Path(repoPath, ".git", "HEAD") -- 465
	if not Content:exist(headPath) then -- 466
		return nil -- 466
	end -- 466
	local head = Content:load(headPath) -- 467
	if not head then -- 468
		return nil -- 468
	end -- 468
	local branch = head:match("^ref:%s*refs/heads/(.-)%s*$") -- 469
	if branch and branch ~= "" then -- 470
		return branch -- 470
	end -- 470
	return nil -- 471
end -- 463
local gitBranchesWithHead -- 473
gitBranchesWithHead = function(branchStatus, currentBranch) -- 473
	local branches = branchStatus and branchStatus.data and branchStatus.data.branches or { } -- 474
	if not (currentBranch and currentBranch ~= "") then -- 475
		return branches -- 475
	end -- 475
	for _index_0 = 1, #branches do -- 476
		local branch = branches[_index_0] -- 476
		if branch.name == currentBranch then -- 477
			return branches -- 477
		end -- 477
	end -- 476
	local withHead -- 478
	do -- 478
		local _accum_0 = { } -- 478
		local _len_0 = 1 -- 478
		for _index_0 = 1, #branches do -- 478
			local branch = branches[_index_0] -- 478
			_accum_0[_len_0] = branch -- 478
			_len_0 = _len_0 + 1 -- 478
		end -- 478
		withHead = _accum_0 -- 478
	end -- 478
	withHead[#withHead + 1] = { -- 479
		name = currentBranch, -- 479
		current = true, -- 479
		unborn = true -- 479
	} -- 479
	return withHead -- 480
end -- 473
local gitStatusMeansNotRepo -- 482
gitStatusMeansNotRepo = function(statusRes) -- 482
	local message = statusRes and (statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message)) or "" -- 483
	message = tostring(message):lower() -- 484
	return message:find("repository does not exist", 1, true) or message:find("not a git repository", 1, true) -- 485
end -- 482
local gitSummary -- 487
gitSummary = function(repoPath) -- 487
	local statusRes = gitRunSync(repoPath, "status", nil, 120) -- 488
	if not statusRes.success then -- 489
		if gitStatusMeansNotRepo(statusRes) then -- 490
			return { -- 491
				success = true, -- 491
				isRepo = false, -- 491
				message = statusRes.message, -- 491
				status = statusRes.status -- 491
			} -- 491
		end -- 490
		return { -- 492
			success = false, -- 492
			message = statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message) or "failed to check Git repository", -- 492
			status = statusRes.status -- 492
		} -- 492
	end -- 489
	local branchRes = gitRunSync(repoPath, "branch", nil, 120) -- 493
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 120) -- 494
	local status = statusRes.status -- 495
	local branchStatus = branchRes.status -- 496
	local remoteStatus = remoteRes.status -- 497
	local currentBranch = gitCurrentBranch(branchStatus) or gitHeadBranch(repoPath) -- 498
	local branches = gitBranchesWithHead(branchStatus, currentBranch) -- 499
	local logRes = gitRunSync(repoPath, "log --metadata-only -n 100", nil, 120) -- 500
	local logStatus -- 501
	if logRes.success then -- 501
		logStatus = logRes.status -- 502
	else -- 504
		logStatus = { -- 505
			state = "done", -- 505
			kind = "log", -- 506
			repoPath = repoPath, -- 507
			progress = 1, -- 508
			message = "git log completed", -- 509
			data = { -- 510
				commits = { } -- 510
			} -- 510
		} -- 504
	end -- 501
	local hasCommit = logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] ~= nil -- 512
	local tagStatus -- 513
	if hasCommit then -- 513
		tagStatus = (gitRunSync(repoPath, "tag", nil, 120)).status -- 514
	else -- 516
		tagStatus = { -- 517
			state = "done", -- 517
			kind = "tag", -- 518
			repoPath = repoPath, -- 519
			progress = 1, -- 520
			message = "git tag completed", -- 521
			data = { -- 522
				tags = { } -- 522
			} -- 522
		} -- 516
	end -- 513
	local defaultRemote = gitDefaultRemote(remoteStatus) -- 524
	local lastCommit = nil -- 525
	if logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] then -- 526
		lastCommit = logStatus.data.commits[1] -- 527
	end -- 526
	return { -- 529
		success = true, -- 529
		isRepo = true, -- 530
		clean = status.data and status.data.clean or false, -- 531
		currentBranch = currentBranch, -- 532
		defaultRemote = defaultRemote, -- 533
		remotes = remoteStatus and remoteStatus.data and remoteStatus.data.remotes or { }, -- 534
		branches = branches, -- 535
		lastCommit = lastCommit, -- 536
		status = status, -- 537
		branchStatus = branchStatus, -- 538
		remoteStatus = remoteStatus, -- 539
		historyStatus = logStatus, -- 540
		tagStatus = tagStatus -- 541
	} -- 528
end -- 487
HttpServer:post("/git/run", function(req) -- 543
	do -- 544
		local _type_0 = type(req) -- 544
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 544
		if _tab_0 then -- 544
			local body = req.body -- 544
			if body ~= nil then -- 544
				local repoPath, command, authId, optionsJSON = body.repoPath, body.command, body.authId, body.optionsJSON -- 545
				if authId and not optionsJSON then -- 546
					local credential = gitLoadCredential(authId) -- 547
					if credential then -- 547
						optionsJSON = gitAuthOptionsJSON(credential) -- 548
						DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 549
							os.time(), -- 549
							credential.id -- 549
						}) -- 549
					end -- 547
				elseif not optionsJSON then -- 550
					local authOk, authSelection = pcall(gitAuthSelectionForCommand, repoPath, command) -- 551
					if not authOk then -- 552
						authSelection = nil -- 552
					end -- 552
					if authSelection then -- 553
						if #authSelection.items == 1 then -- 554
							local credential = gitLoadCredential(authSelection.items[1].id) -- 555
							optionsJSON = gitAuthOptionsJSON(credential) -- 556
							DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 557
								os.time(), -- 557
								credential.id -- 557
							}) -- 557
						else -- 559
							return { -- 559
								success = false, -- 559
								message = "select a Git credential", -- 559
								needsCredentialSelection = true, -- 559
								host = authSelection.host, -- 559
								credentials = authSelection.items -- 559
							} -- 559
						end -- 554
					end -- 553
				end -- 546
				local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 560
				if not jobId then -- 561
					return { -- 561
						success = false, -- 561
						message = err -- 561
					} -- 561
				end -- 561
				return { -- 562
					success = true, -- 562
					jobId = jobId -- 562
				} -- 562
			end -- 544
		end -- 544
	end -- 544
	return invalidArguments -- 543
end) -- 543
HttpServer:post("/git/status", function(req) -- 564
	do -- 565
		local _type_0 = type(req) -- 565
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 565
		if _tab_0 then -- 565
			local jobId -- 565
			do -- 565
				local _obj_0 = req.body -- 565
				local _type_1 = type(_obj_0) -- 565
				if "table" == _type_1 or "userdata" == _type_1 then -- 565
					jobId = _obj_0.jobId -- 565
				end -- 565
			end -- 565
			if jobId ~= nil then -- 565
				local job = GitJobs[tonumber(jobId) or 0] -- 566
				if not job then -- 567
					return { -- 567
						success = false, -- 567
						message = "git job not found" -- 567
					} -- 567
				end -- 567
				return { -- 568
					success = true, -- 568
					status = job.status, -- 568
					command = job.command -- 568
				} -- 568
			end -- 565
		end -- 565
	end -- 565
	return invalidArguments -- 564
end) -- 564
HttpServer:post("/git/cancel", function(req) -- 570
	do -- 571
		local _type_0 = type(req) -- 571
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 571
		if _tab_0 then -- 571
			local jobId -- 571
			do -- 571
				local _obj_0 = req.body -- 571
				local _type_1 = type(_obj_0) -- 571
				if "table" == _type_1 or "userdata" == _type_1 then -- 571
					jobId = _obj_0.jobId -- 571
				end -- 571
			end -- 571
			if jobId ~= nil then -- 571
				local id = tonumber(jobId) -- 572
				if not id then -- 573
					return { -- 573
						success = false, -- 573
						message = "invalid jobId" -- 573
					} -- 573
				end -- 573
				return { -- 574
					success = Git:cancel(id) -- 574
				} -- 574
			end -- 571
		end -- 571
	end -- 571
	return invalidArguments -- 570
end) -- 570
HttpServer:postSchedule("/git/summary", function(req) -- 576
	do -- 577
		local _type_0 = type(req) -- 577
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 577
		if _tab_0 then -- 577
			local repoPath -- 577
			do -- 577
				local _obj_0 = req.body -- 577
				local _type_1 = type(_obj_0) -- 577
				if "table" == _type_1 or "userdata" == _type_1 then -- 577
					repoPath = _obj_0.repoPath -- 577
				end -- 577
			end -- 577
			if repoPath ~= nil then -- 577
				if gitInvalidRepoPath(repoPath) then -- 578
					return { -- 578
						success = false, -- 578
						message = "invalid repoPath" -- 578
					} -- 578
				end -- 578
				return gitSummary(repoPath) -- 579
			end -- 577
		end -- 577
	end -- 577
	return invalidArguments -- 576
end) -- 576
HttpServer:postSchedule("/git/status-files", function(req) -- 581
	do -- 582
		local _type_0 = type(req) -- 582
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 582
		if _tab_0 then -- 582
			local repoPath -- 582
			do -- 582
				local _obj_0 = req.body -- 582
				local _type_1 = type(_obj_0) -- 582
				if "table" == _type_1 or "userdata" == _type_1 then -- 582
					repoPath = _obj_0.repoPath -- 582
				end -- 582
			end -- 582
			if repoPath ~= nil then -- 582
				return gitRunSync(repoPath, "status", nil, 120) -- 583
			end -- 582
		end -- 582
	end -- 582
	return invalidArguments -- 581
end) -- 581
HttpServer:postSchedule("/git/discard-untracked", function(req) -- 585
	do -- 586
		local _type_0 = type(req) -- 586
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 586
		if _tab_0 then -- 586
			local body = req.body -- 586
			if body ~= nil then -- 586
				local repoPath, paths = body.repoPath, body.paths -- 587
				if gitInvalidRepoPath(repoPath) then -- 588
					return { -- 588
						success = false, -- 588
						message = "invalid repoPath" -- 588
					} -- 588
				end -- 588
				if not (type(paths) == "table") then -- 589
					return { -- 589
						success = false, -- 589
						message = "invalid paths" -- 589
					} -- 589
				end -- 589
				local statusRes = gitRunSync(repoPath, "status", nil, 10) -- 590
				if not statusRes.success then -- 591
					return statusRes -- 591
				end -- 591
				local untracked = { } -- 592
				local _list_0 = (statusRes.status.data and statusRes.status.data.files or { }) -- 593
				for _index_0 = 1, #_list_0 do -- 593
					local file = _list_0[_index_0] -- 593
					if file.staging == "?" or file.worktree == "?" then -- 594
						untracked[file.path] = true -- 595
					end -- 594
				end -- 593
				local removed = { } -- 596
				for _index_0 = 1, #paths do -- 597
					local relPath = paths[_index_0] -- 597
					relPath = tostring(relPath) -- 598
					if not gitPathInsideRepo(repoPath, relPath) then -- 599
						return { -- 599
							success = false, -- 599
							message = "unsafe path: " .. tostring(relPath) -- 599
						} -- 599
					end -- 599
					if not untracked[relPath] then -- 600
						return { -- 600
							success = false, -- 600
							message = "path is not untracked: " .. tostring(relPath) -- 600
						} -- 600
					end -- 600
				end -- 597
				for _index_0 = 1, #paths do -- 601
					local relPath = paths[_index_0] -- 601
					local targetPath = Path(repoPath, tostring(relPath)) -- 602
					if Content:exist(targetPath) then -- 603
						Content:remove(targetPath) -- 604
						removed[#removed + 1] = tostring(relPath) -- 605
					end -- 603
				end -- 601
				return { -- 606
					success = true, -- 606
					removed = removed -- 606
				} -- 606
			end -- 586
		end -- 586
	end -- 586
	return invalidArguments -- 585
end) -- 585
HttpServer:postSchedule("/git/file-diff", function(req) -- 608
	do -- 609
		local _type_0 = type(req) -- 609
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 609
		if _tab_0 then -- 609
			local body = req.body -- 609
			if body ~= nil then -- 609
				local repoPath, path, staged = body.repoPath, body.path, body.staged -- 610
				if gitInvalidRepoPath(repoPath) then -- 611
					return { -- 611
						success = false, -- 611
						message = "invalid repoPath" -- 611
					} -- 611
				end -- 611
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 612
					return { -- 612
						success = false, -- 612
						message = "unsafe path" -- 612
					} -- 612
				end -- 612
				local command -- 613
				if staged == true then -- 613
					command = "diff --staged -- " .. tostring(gitQuote(path)) -- 614
				else -- 616
					command = "diff -- " .. tostring(gitQuote(path)) -- 616
				end -- 613
				local res = gitRunSync(repoPath, command, nil, 10) -- 617
				if not res.success then -- 618
					return res -- 618
				end -- 618
				return { -- 619
					success = true, -- 619
					status = res.status, -- 619
					data = res.status and res.status.data -- 619
				} -- 619
			end -- 609
		end -- 609
	end -- 609
	return invalidArguments -- 608
end) -- 608
HttpServer:postSchedule("/git/commit-file-diff", function(req) -- 621
	do -- 622
		local _type_0 = type(req) -- 622
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 622
		if _tab_0 then -- 622
			local body = req.body -- 622
			if body ~= nil then -- 622
				local repoPath, commit, path = body.repoPath, body.commit, body.path -- 623
				if gitInvalidRepoPath(repoPath) then -- 624
					return { -- 624
						success = false, -- 624
						message = "invalid repoPath" -- 624
					} -- 624
				end -- 624
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 625
					return { -- 625
						success = false, -- 625
						message = "invalid commit" -- 625
					} -- 625
				end -- 625
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 626
					return { -- 626
						success = false, -- 626
						message = "unsafe path" -- 626
					} -- 626
				end -- 626
				local res = gitRunSync(repoPath, "diff " .. tostring(gitQuote(commit)) .. " -- " .. tostring(gitQuote(path)), nil, 10) -- 627
				if not res.success then -- 628
					return res -- 628
				end -- 628
				return { -- 629
					success = true, -- 629
					status = res.status, -- 629
					data = res.status and res.status.data -- 629
				} -- 629
			end -- 622
		end -- 622
	end -- 622
	return invalidArguments -- 621
end) -- 621
HttpServer:postSchedule("/git/history", function(req) -- 631
	do -- 632
		local _type_0 = type(req) -- 632
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 632
		if _tab_0 then -- 632
			local body = req.body -- 632
			if body ~= nil then -- 632
				local repoPath, limit = body.repoPath, body.limit -- 633
				limit = math.max(1, math.min(100, tonumber(limit) or 20)) -- 634
				return gitRunSync(repoPath, "log --metadata-only -n " .. tostring(limit), nil, 10) -- 635
			end -- 632
		end -- 632
	end -- 632
	return invalidArguments -- 631
end) -- 631
HttpServer:postSchedule("/git/remotes", function(req) -- 637
	do -- 638
		local _type_0 = type(req) -- 638
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 638
		if _tab_0 then -- 638
			local body = req.body -- 638
			if body ~= nil then -- 638
				local repoPath, command = body.repoPath, body.command -- 639
				command = command or "remote -v" -- 640
				return gitRunSync(repoPath, command, nil, 10) -- 641
			end -- 638
		end -- 638
	end -- 638
	return invalidArguments -- 637
end) -- 637
HttpServer:postSchedule("/git/branches", function(req) -- 643
	do -- 644
		local _type_0 = type(req) -- 644
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 644
		if _tab_0 then -- 644
			local body = req.body -- 644
			if body ~= nil then -- 644
				local repoPath, command = body.repoPath, body.command -- 645
				command = command or "branch" -- 646
				return gitRunSync(repoPath, command, nil, 10) -- 647
			end -- 644
		end -- 644
	end -- 644
	return invalidArguments -- 643
end) -- 643
HttpServer:postSchedule("/git/tags", function(req) -- 649
	do -- 650
		local _type_0 = type(req) -- 650
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 650
		if _tab_0 then -- 650
			local body = req.body -- 650
			if body ~= nil then -- 650
				local repoPath, command = body.repoPath, body.command -- 651
				command = command or "tag" -- 652
				return gitRunSync(repoPath, command, nil, 10) -- 653
			end -- 650
		end -- 650
	end -- 650
	return invalidArguments -- 649
end) -- 649
HttpServer:post("/git/profile/get", function() -- 655
	ensureGitTables() -- 656
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 657
	local profile -- 658
	if rows and rows[1] then -- 658
		profile = { -- 659
			name = rows[1][1], -- 659
			email = rows[1][2] -- 659
		} -- 659
	else -- 661
		profile = { -- 661
			name = "", -- 661
			email = "" -- 661
		} -- 661
	end -- 658
	return { -- 662
		success = true, -- 662
		profile = profile -- 662
	} -- 662
end) -- 655
HttpServer:post("/git/profile/save", function(req) -- 664
	do -- 665
		local _type_0 = type(req) -- 665
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 665
		if _tab_0 then -- 665
			local name -- 665
			do -- 665
				local _obj_0 = req.body -- 665
				local _type_1 = type(_obj_0) -- 665
				if "table" == _type_1 or "userdata" == _type_1 then -- 665
					name = _obj_0.name -- 665
				end -- 665
			end -- 665
			local email -- 665
			do -- 665
				local _obj_0 = req.body -- 665
				local _type_1 = type(_obj_0) -- 665
				if "table" == _type_1 or "userdata" == _type_1 then -- 665
					email = _obj_0.email -- 665
				end -- 665
			end -- 665
			if name ~= nil and email ~= nil then -- 665
				ensureGitTables() -- 666
				DB:exec("insert into GitProfile(id, name, email, updated_at) values(1, ?, ?, ?) on conflict(id) do update set name = excluded.name, email = excluded.email, updated_at = excluded.updated_at", { -- 668
					tostring(name or ""), -- 668
					tostring(email or ""), -- 669
					os.time() -- 670
				}) -- 667
				return { -- 672
					success = true -- 672
				} -- 672
			end -- 665
		end -- 665
	end -- 665
	return invalidArguments -- 664
end) -- 664
HttpServer:post("/git/auth/list", function(req) -- 674
	ensureGitTables() -- 675
	local host = nil -- 676
	do -- 677
		local _type_0 = type(req) -- 677
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 677
		if _tab_0 then -- 677
			local body = req.body -- 677
			if body ~= nil then -- 677
				host = body.host -- 678
			end -- 677
		end -- 677
	end -- 677
	local rows -- 679
	if host and host ~= "" then -- 679
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by host asc, label asc, id asc", { -- 680
			tostring(host):lower() -- 680
		}) -- 680
	else -- 682
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential order by host asc, label asc, id asc") -- 682
	end -- 679
	local items -- 683
	if rows then -- 683
		local _accum_0 = { } -- 683
		local _len_0 = 1 -- 683
		for _index_0 = 1, #rows do -- 683
			local row = rows[_index_0] -- 683
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 683
			_len_0 = _len_0 + 1 -- 683
		end -- 683
		items = _accum_0 -- 683
	else -- 683
		items = { } -- 683
	end -- 683
	return { -- 684
		success = true, -- 684
		items = items -- 684
	} -- 684
end) -- 674
HttpServer:postSchedule("/git/auth/match", function(req) -- 686
	do -- 687
		local _type_0 = type(req) -- 687
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 687
		if _tab_0 then -- 687
			local body = req.body -- 687
			if body ~= nil then -- 687
				local repoPath, command, url = body.repoPath, body.command, body.url -- 688
				local host -- 689
				if url and url ~= "" then -- 689
					host = gitHostFromURL(url) -- 689
				else -- 689
					host = gitCommandHost(repoPath, command) -- 689
				end -- 689
				if not host then -- 690
					return { -- 690
						success = false, -- 690
						message = "git host is required" -- 690
					} -- 690
				end -- 690
				local items = gitCredentialsForHost(host) -- 691
				return { -- 692
					success = true, -- 692
					host = host, -- 692
					items = items, -- 692
					needsSelection = #items > 1, -- 692
					authId = (#items == 1 and items[1].id or nil) -- 692
				} -- 692
			end -- 687
		end -- 687
	end -- 687
	return invalidArguments -- 686
end) -- 686
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
HttpServer:post("/agent/session/mode", function(req) -- 746
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
			local workMode -- 747
			do -- 747
				local _obj_0 = req.body -- 747
				local _type_1 = type(_obj_0) -- 747
				if "table" == _type_1 or "userdata" == _type_1 then -- 747
					workMode = _obj_0.workMode -- 747
				end -- 747
			end -- 747
			if sessionId ~= nil and workMode ~= nil then -- 747
				return AgentSession.setWorkMode(sessionId, workMode) -- 748
			end -- 747
		end -- 747
	end -- 747
	return invalidArguments -- 746
end) -- 746
HttpServer:post("/agent/session/send", function(req) -- 750
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
			local prompt -- 751
			do -- 751
				local _obj_0 = req.body -- 751
				local _type_1 = type(_obj_0) -- 751
				if "table" == _type_1 or "userdata" == _type_1 then -- 751
					prompt = _obj_0.prompt -- 751
				end -- 751
			end -- 751
			if sessionId ~= nil and prompt ~= nil then -- 751
				return AgentSession.sendPrompt(sessionId, prompt, false, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 752
			end -- 751
		end -- 751
	end -- 751
	return invalidArguments -- 750
end) -- 750
HttpServer:post("/agent/session/continue", function(req) -- 754
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
				return AgentSession.continuePrompt(sessionId, req.body.disabledAgentTools, req.body.llmConfigId) -- 756
			end -- 755
		end -- 755
	end -- 755
	return invalidArguments -- 754
end) -- 754
HttpServer:post("/agent/session/finish-handoff", function(req) -- 758
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
				return AgentSession.finishSubSessionHandoff(sessionId, req.body.llmConfigId) -- 760
			end -- 759
		end -- 759
	end -- 759
	return invalidArguments -- 758
end) -- 758
HttpServer:post("/agent/session/resend", function(req) -- 762
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
			local messageId -- 763
			do -- 763
				local _obj_0 = req.body -- 763
				local _type_1 = type(_obj_0) -- 763
				if "table" == _type_1 or "userdata" == _type_1 then -- 763
					messageId = _obj_0.messageId -- 763
				end -- 763
			end -- 763
			local prompt -- 763
			do -- 763
				local _obj_0 = req.body -- 763
				local _type_1 = type(_obj_0) -- 763
				if "table" == _type_1 or "userdata" == _type_1 then -- 763
					prompt = _obj_0.prompt -- 763
				end -- 763
			end -- 763
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 763
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 764
			end -- 763
		end -- 763
	end -- 763
	return invalidArguments -- 762
end) -- 762
HttpServer:post("/agent/session/questionnaire/respond", function(req) -- 766
	do -- 767
		local _type_0 = type(req) -- 767
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 767
		if _tab_0 then -- 767
			local sessionId -- 767
			do -- 767
				local _obj_0 = req.body -- 767
				local _type_1 = type(_obj_0) -- 767
				if "table" == _type_1 or "userdata" == _type_1 then -- 767
					sessionId = _obj_0.sessionId -- 767
				end -- 767
			end -- 767
			local questionnaireId -- 767
			do -- 767
				local _obj_0 = req.body -- 767
				local _type_1 = type(_obj_0) -- 767
				if "table" == _type_1 or "userdata" == _type_1 then -- 767
					questionnaireId = _obj_0.questionnaireId -- 767
				end -- 767
			end -- 767
			local answers -- 767
			do -- 767
				local _obj_0 = req.body -- 767
				local _type_1 = type(_obj_0) -- 767
				if "table" == _type_1 or "userdata" == _type_1 then -- 767
					answers = _obj_0.answers -- 767
				end -- 767
			end -- 767
			if sessionId ~= nil and questionnaireId ~= nil and answers ~= nil then -- 767
				return AgentSession.respondQuestionnaire(sessionId, questionnaireId, answers, req.body.llmConfigId) -- 768
			end -- 767
		end -- 767
	end -- 767
	return invalidArguments -- 766
end) -- 766
HttpServer:post("/agent/session/questionnaire/cancel", function(req) -- 770
	do -- 771
		local _type_0 = type(req) -- 771
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 771
		if _tab_0 then -- 771
			local sessionId -- 771
			do -- 771
				local _obj_0 = req.body -- 771
				local _type_1 = type(_obj_0) -- 771
				if "table" == _type_1 or "userdata" == _type_1 then -- 771
					sessionId = _obj_0.sessionId -- 771
				end -- 771
			end -- 771
			local questionnaireId -- 771
			do -- 771
				local _obj_0 = req.body -- 771
				local _type_1 = type(_obj_0) -- 771
				if "table" == _type_1 or "userdata" == _type_1 then -- 771
					questionnaireId = _obj_0.questionnaireId -- 771
				end -- 771
			end -- 771
			if sessionId ~= nil and questionnaireId ~= nil then -- 771
				return AgentSession.cancelQuestionnaire(sessionId, questionnaireId, req.body.llmConfigId) -- 772
			end -- 771
		end -- 771
	end -- 771
	return invalidArguments -- 770
end) -- 770
HttpServer:post("/agent/task/status", function(req) -- 774
	do -- 775
		local _type_0 = type(req) -- 775
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 775
		if _tab_0 then -- 775
			local sessionId -- 775
			do -- 775
				local _obj_0 = req.body -- 775
				local _type_1 = type(_obj_0) -- 775
				if "table" == _type_1 or "userdata" == _type_1 then -- 775
					sessionId = _obj_0.sessionId -- 775
				end -- 775
			end -- 775
			if sessionId ~= nil then -- 775
				local res = AgentSession.getSession(sessionId) -- 776
				if not res.success then -- 777
					return res -- 777
				end -- 777
				local taskId = res.session.currentTaskId -- 778
				local checkpoints -- 779
				if taskId then -- 779
					checkpoints = AgentTools.listCheckpoints(taskId) -- 779
				else -- 779
					checkpoints = { } -- 779
				end -- 779
				return { -- 781
					success = true, -- 781
					session = res.session, -- 782
					relatedSessions = res.relatedSessions, -- 783
					spawnInfo = res.spawnInfo, -- 784
					messages = res.messages, -- 785
					steps = res.steps, -- 786
					checkpoints = checkpoints, -- 787
					pendingQuestionnaire = res.pendingQuestionnaire, -- 788
					hasActivePlan = res.hasActivePlan -- 789
				} -- 780
			end -- 775
		end -- 775
	end -- 775
	return invalidArguments -- 774
end) -- 774
HttpServer:post("/agent/task/running", function() -- 791
	local res = AgentSession.listRunningSessions() -- 792
	if res.success and #res.sessions == 0 then -- 793
		res.sessions = nil -- 794
	end -- 793
	return res -- 795
end) -- 791
HttpServer:post("/agent/task/stop", function(req) -- 797
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
			if sessionId ~= nil then -- 798
				return AgentSession.stopSessionTask(sessionId) -- 799
			end -- 798
		end -- 798
	end -- 798
	return invalidArguments -- 797
end) -- 797
HttpServer:post("/agent/checkpoint/list", function(req) -- 801
	do -- 802
		local _type_0 = type(req) -- 802
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 802
		if _tab_0 then -- 802
			local taskId -- 802
			do -- 802
				local _obj_0 = req.body -- 802
				local _type_1 = type(_obj_0) -- 802
				if "table" == _type_1 or "userdata" == _type_1 then -- 802
					taskId = _obj_0.taskId -- 802
				end -- 802
			end -- 802
			local sessionId -- 802
			do -- 802
				local _obj_0 = req.body -- 802
				local _type_1 = type(_obj_0) -- 802
				if "table" == _type_1 or "userdata" == _type_1 then -- 802
					sessionId = _obj_0.sessionId -- 802
				end -- 802
			end -- 802
			if sessionId ~= nil then -- 802
				if not taskId and sessionId then -- 803
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 804
				end -- 803
				if not taskId then -- 805
					return { -- 805
						success = false, -- 805
						message = "task not found" -- 805
					} -- 805
				end -- 805
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 806
				if not access.success then -- 807
					return access -- 807
				end -- 807
				return { -- 809
					success = true, -- 809
					taskId = taskId, -- 810
					checkpoints = AgentTools.listCheckpoints(taskId) -- 811
				} -- 808
			end -- 802
		end -- 802
	end -- 802
	return invalidArguments -- 801
end) -- 801
HttpServer:post("/agent/checkpoint/diff", function(req) -- 813
	do -- 814
		local _type_0 = type(req) -- 814
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 814
		if _tab_0 then -- 814
			local sessionId -- 814
			do -- 814
				local _obj_0 = req.body -- 814
				local _type_1 = type(_obj_0) -- 814
				if "table" == _type_1 or "userdata" == _type_1 then -- 814
					sessionId = _obj_0.sessionId -- 814
				end -- 814
			end -- 814
			local checkpointId -- 814
			do -- 814
				local _obj_0 = req.body -- 814
				local _type_1 = type(_obj_0) -- 814
				if "table" == _type_1 or "userdata" == _type_1 then -- 814
					checkpointId = _obj_0.checkpointId -- 814
				end -- 814
			end -- 814
			if sessionId ~= nil and checkpointId ~= nil then -- 814
				if not (checkpointId > 0) then -- 815
					return { -- 815
						success = false, -- 815
						message = "invalid checkpointId" -- 815
					} -- 815
				end -- 815
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 816
				if not access.success then -- 817
					return access -- 817
				end -- 817
				return AgentTools.getCheckpointDiff(checkpointId) -- 818
			end -- 814
		end -- 814
	end -- 814
	return invalidArguments -- 813
end) -- 813
HttpServer:post("/agent/task/diff", function(req) -- 820
	do -- 821
		local _type_0 = type(req) -- 821
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 821
		if _tab_0 then -- 821
			local sessionId -- 821
			do -- 821
				local _obj_0 = req.body -- 821
				local _type_1 = type(_obj_0) -- 821
				if "table" == _type_1 or "userdata" == _type_1 then -- 821
					sessionId = _obj_0.sessionId -- 821
				end -- 821
			end -- 821
			local taskId -- 821
			do -- 821
				local _obj_0 = req.body -- 821
				local _type_1 = type(_obj_0) -- 821
				if "table" == _type_1 or "userdata" == _type_1 then -- 821
					taskId = _obj_0.taskId -- 821
				end -- 821
			end -- 821
			if sessionId ~= nil and taskId ~= nil then -- 821
				if not (taskId > 0) then -- 822
					return { -- 822
						success = false, -- 822
						message = "invalid taskId" -- 822
					} -- 822
				end -- 822
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 823
				if not access.success then -- 824
					return access -- 824
				end -- 824
				return AgentTools.getTaskChangeSetDiff(taskId) -- 825
			end -- 821
		end -- 821
	end -- 821
	return invalidArguments -- 820
end) -- 820
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 827
	do -- 828
		local _type_0 = type(req) -- 828
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 828
		if _tab_0 then -- 828
			local sessionId -- 828
			do -- 828
				local _obj_0 = req.body -- 828
				local _type_1 = type(_obj_0) -- 828
				if "table" == _type_1 or "userdata" == _type_1 then -- 828
					sessionId = _obj_0.sessionId -- 828
				end -- 828
			end -- 828
			local checkpointId -- 828
			do -- 828
				local _obj_0 = req.body -- 828
				local _type_1 = type(_obj_0) -- 828
				if "table" == _type_1 or "userdata" == _type_1 then -- 828
					checkpointId = _obj_0.checkpointId -- 828
				end -- 828
			end -- 828
			if sessionId ~= nil and checkpointId ~= nil then -- 828
				if not (checkpointId > 0) then -- 829
					return { -- 829
						success = false, -- 829
						message = "invalid checkpointId" -- 829
					} -- 829
				end -- 829
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 830
				if not access.success then -- 831
					return access -- 831
				end -- 831
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, access.session.projectRoot) -- 832
				if not rollbackRes.success then -- 833
					return rollbackRes -- 833
				end -- 833
				return { -- 835
					success = true, -- 835
					checkpointId = rollbackRes.checkpointId -- 836
				} -- 834
			end -- 828
		end -- 828
	end -- 828
	return invalidArguments -- 827
end) -- 827
HttpServer:post("/agent/task/rollback", function(req) -- 838
	do -- 839
		local _type_0 = type(req) -- 839
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 839
		if _tab_0 then -- 839
			local sessionId -- 839
			do -- 839
				local _obj_0 = req.body -- 839
				local _type_1 = type(_obj_0) -- 839
				if "table" == _type_1 or "userdata" == _type_1 then -- 839
					sessionId = _obj_0.sessionId -- 839
				end -- 839
			end -- 839
			local taskId -- 839
			do -- 839
				local _obj_0 = req.body -- 839
				local _type_1 = type(_obj_0) -- 839
				if "table" == _type_1 or "userdata" == _type_1 then -- 839
					taskId = _obj_0.taskId -- 839
				end -- 839
			end -- 839
			if sessionId ~= nil and taskId ~= nil then -- 839
				if not (taskId > 0) then -- 840
					return { -- 840
						success = false, -- 840
						message = "invalid taskId" -- 840
					} -- 840
				end -- 840
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 841
				if not access.success then -- 842
					return access -- 842
				end -- 842
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, access.session.projectRoot) -- 843
				if not rollbackRes.success then -- 844
					return rollbackRes -- 844
				end -- 844
				return { -- 846
					success = true, -- 846
					taskId = rollbackRes.taskId, -- 847
					checkpointId = rollbackRes.checkpointId, -- 848
					checkpointCount = rollbackRes.checkpointCount -- 849
				} -- 845
			end -- 839
		end -- 839
	end -- 839
	return invalidArguments -- 838
end) -- 838
local getSearchPath -- 851
getSearchPath = function(file) -- 851
	do -- 852
		local dir = getProjectDirFromFile(file) -- 852
		if dir then -- 852
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 853
		end -- 852
	end -- 852
	return "" -- 851
end -- 851
local getSearchFolders -- 855
getSearchFolders = function(file) -- 855
	do -- 856
		local dir = getProjectDirFromFile(file) -- 856
		if dir then -- 856
			return { -- 858
				Path(dir, "Script"), -- 858
				dir -- 859
			} -- 857
		end -- 856
	end -- 856
	return { } -- 855
end -- 855
local disabledCheckForLua = { -- 862
	"incompatible number of returns", -- 862
	"unknown", -- 863
	"cannot index", -- 864
	"module not found", -- 865
	"don't know how to resolve", -- 866
	"ContainerItem", -- 867
	"cannot resolve a type", -- 868
	"invalid key", -- 869
	"inconsistent index type", -- 870
	"cannot use operator", -- 871
	"attempting ipairs loop", -- 872
	"expects record or nominal", -- 873
	"variable is not being assigned", -- 874
	"<invalid type>", -- 875
	"<any type>", -- 876
	"using the '#' operator", -- 877
	"can't match a record", -- 878
	"redeclaration of variable", -- 879
	"cannot apply pairs", -- 880
	"not a function", -- 881
	"to%-be%-closed" -- 882
} -- 861
local yueCheck -- 884
yueCheck = function(file, content, lax) -- 884
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 885
	if isTIC80 then -- 886
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 887
	end -- 886
	local searchPath = getSearchPath(file) -- 888
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 889
	local info = { } -- 890
	local globals = { } -- 891
	for _index_0 = 1, #checkResult do -- 892
		local _des_0 = checkResult[_index_0] -- 892
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 892
		if "error" == t then -- 893
			info[#info + 1] = { -- 894
				"syntax", -- 894
				file, -- 894
				line, -- 894
				col, -- 894
				msg -- 894
			} -- 894
		elseif "global" == t then -- 895
			globals[#globals + 1] = { -- 896
				msg, -- 896
				line, -- 896
				col -- 896
			} -- 896
		end -- 893
	end -- 892
	if luaCodes then -- 897
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 898
		if success then -- 899
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 900
			if not (lintResult == "") then -- 901
				lintResult = lintResult .. "\n" -- 901
			end -- 901
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 902
		else -- 903
			for _index_0 = 1, #lintResult do -- 903
				local _des_0 = lintResult[_index_0] -- 903
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 903
				if isTIC80 and tic80APIs[name] then -- 904
					goto _continue_0 -- 904
				end -- 904
				info[#info + 1] = { -- 905
					"syntax", -- 905
					file, -- 905
					line, -- 905
					col, -- 905
					"invalid global variable" -- 905
				} -- 905
				::_continue_0:: -- 904
			end -- 903
		end -- 899
	end -- 897
	return luaCodes, info -- 906
end -- 884
local luaCheck -- 908
luaCheck = function(file, content) -- 908
	local res, err = load(content, "check") -- 909
	if not res then -- 910
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 911
		return { -- 912
			success = false, -- 912
			info = { -- 912
				{ -- 912
					"syntax", -- 912
					file, -- 912
					tonumber(line), -- 912
					0, -- 912
					msg -- 912
				} -- 912
			} -- 912
		} -- 912
	end -- 910
	local success, info = teal.checkAsync(content, file, true, "") -- 913
	if info then -- 914
		do -- 915
			local _accum_0 = { } -- 915
			local _len_0 = 1 -- 915
			for _index_0 = 1, #info do -- 915
				local item = info[_index_0] -- 915
				local useCheck = true -- 916
				if not item[5]:match("unused") then -- 917
					for _index_1 = 1, #disabledCheckForLua do -- 918
						local check = disabledCheckForLua[_index_1] -- 918
						if item[5]:match(check) then -- 919
							useCheck = false -- 920
						end -- 919
					end -- 918
				end -- 917
				if not useCheck then -- 921
					goto _continue_0 -- 921
				end -- 921
				do -- 922
					local _exp_0 = item[1] -- 922
					if "type" == _exp_0 then -- 923
						item[1] = "warning" -- 924
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 925
						goto _continue_0 -- 926
					end -- 922
				end -- 922
				_accum_0[_len_0] = item -- 927
				_len_0 = _len_0 + 1 -- 916
				::_continue_0:: -- 916
			end -- 915
			info = _accum_0 -- 915
		end -- 915
		if #info == 0 then -- 928
			info = nil -- 929
			success = true -- 930
		end -- 928
	end -- 914
	return { -- 931
		success = success, -- 931
		info = info -- 931
	} -- 931
end -- 908
local luaCheckWithLineInfo -- 933
luaCheckWithLineInfo = function(file, luaCodes) -- 933
	local res = luaCheck(file, luaCodes) -- 934
	local info = { } -- 935
	if not res.success then -- 936
		local current = 1 -- 937
		local lastLine = 1 -- 938
		local lineMap = { } -- 939
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 940
			local num = lineCode:match("--%s*(%d+)%s*$") -- 941
			if num then -- 942
				lastLine = tonumber(num) -- 943
			end -- 942
			lineMap[current] = lastLine -- 944
			current = current + 1 -- 945
		end -- 940
		local _list_0 = res.info -- 946
		for _index_0 = 1, #_list_0 do -- 946
			local item = _list_0[_index_0] -- 946
			item[3] = lineMap[item[3]] or 0 -- 947
			item[4] = 0 -- 948
			info[#info + 1] = item -- 949
		end -- 946
		return false, info -- 950
	end -- 936
	return true, info -- 951
end -- 933
local getCompiledYueLine -- 953
getCompiledYueLine = function(content, line, row, file, lax) -- 953
	local luaCodes = yueCheck(file, content, lax) -- 954
	if not luaCodes then -- 955
		return nil -- 955
	end -- 955
	local current = 1 -- 956
	local lastLine = 1 -- 957
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 958
	local targetRow = nil -- 959
	local lineMap = { } -- 960
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 961
		local num = lineCode:match("--%s*(%d+)%s*$") -- 962
		if num then -- 963
			lastLine = tonumber(num) -- 963
		end -- 963
		lineMap[current] = lastLine -- 964
		if row <= lastLine and not targetRow then -- 965
			targetRow = current -- 966
			break -- 967
		end -- 965
		current = current + 1 -- 968
	end -- 961
	targetRow = current -- 969
	if targetLine and targetRow then -- 970
		return luaCodes, targetLine, targetRow, lineMap -- 971
	else -- 973
		return nil -- 973
	end -- 970
end -- 953
HttpServer:postSchedule("/check", function(req) -- 975
	do -- 976
		local _type_0 = type(req) -- 976
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 976
		if _tab_0 then -- 976
			local file -- 976
			do -- 976
				local _obj_0 = req.body -- 976
				local _type_1 = type(_obj_0) -- 976
				if "table" == _type_1 or "userdata" == _type_1 then -- 976
					file = _obj_0.file -- 976
				end -- 976
			end -- 976
			local content -- 976
			do -- 976
				local _obj_0 = req.body -- 976
				local _type_1 = type(_obj_0) -- 976
				if "table" == _type_1 or "userdata" == _type_1 then -- 976
					content = _obj_0.content -- 976
				end -- 976
			end -- 976
			if file ~= nil and content ~= nil then -- 976
				local ext = Path:getExt(file) -- 977
				if "tl" == ext then -- 978
					local searchPath = getSearchPath(file) -- 979
					do -- 980
						local isTIC80 = CheckTIC80Code(content) -- 980
						if isTIC80 then -- 980
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 981
						end -- 980
					end -- 980
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 982
					return { -- 983
						success = success, -- 983
						info = info -- 983
					} -- 983
				elseif "lua" == ext then -- 984
					do -- 985
						local isTIC80 = CheckTIC80Code(content) -- 985
						if isTIC80 then -- 985
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 986
						end -- 985
					end -- 985
					return luaCheck(file, content) -- 987
				elseif "yue" == ext then -- 988
					local luaCodes, info = yueCheck(file, content, false) -- 989
					local success = false -- 990
					if luaCodes then -- 991
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 992
						do -- 993
							local _tab_1 = { } -- 993
							local _idx_0 = #_tab_1 + 1 -- 993
							for _index_0 = 1, #info do -- 993
								local _value_0 = info[_index_0] -- 993
								_tab_1[_idx_0] = _value_0 -- 993
								_idx_0 = _idx_0 + 1 -- 993
							end -- 993
							local _idx_1 = #_tab_1 + 1 -- 993
							for _index_0 = 1, #luaInfo do -- 993
								local _value_0 = luaInfo[_index_0] -- 993
								_tab_1[_idx_1] = _value_0 -- 993
								_idx_1 = _idx_1 + 1 -- 993
							end -- 993
							info = _tab_1 -- 993
						end -- 993
						success = success and luaSuccess -- 994
					end -- 991
					if #info > 0 then -- 995
						return { -- 996
							success = success, -- 996
							info = info -- 996
						} -- 996
					else -- 998
						return { -- 998
							success = success -- 998
						} -- 998
					end -- 995
				elseif "xml" == ext then -- 999
					local success, result = xml.check(content) -- 1000
					if success then -- 1001
						local info -- 1002
						success, info = luaCheckWithLineInfo(file, result) -- 1002
						if #info > 0 then -- 1003
							return { -- 1004
								success = success, -- 1004
								info = info -- 1004
							} -- 1004
						else -- 1006
							return { -- 1006
								success = success -- 1006
							} -- 1006
						end -- 1003
					else -- 1008
						local info -- 1008
						do -- 1008
							local _accum_0 = { } -- 1008
							local _len_0 = 1 -- 1008
							for _index_0 = 1, #result do -- 1008
								local _des_0 = result[_index_0] -- 1008
								local row, err = _des_0[1], _des_0[2] -- 1008
								_accum_0[_len_0] = { -- 1009
									"syntax", -- 1009
									file, -- 1009
									row, -- 1009
									0, -- 1009
									err -- 1009
								} -- 1009
								_len_0 = _len_0 + 1 -- 1009
							end -- 1008
							info = _accum_0 -- 1008
						end -- 1008
						return { -- 1010
							success = false, -- 1010
							info = info -- 1010
						} -- 1010
					end -- 1001
				end -- 978
			end -- 976
		end -- 976
	end -- 976
	return { -- 975
		success = true -- 975
	} -- 975
end) -- 975
HttpServer:post("/body/parse", function(req) -- 1012
	do -- 1013
		local _type_0 = type(req) -- 1013
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1013
		if _tab_0 then -- 1013
			local file -- 1013
			do -- 1013
				local _obj_0 = req.body -- 1013
				local _type_1 = type(_obj_0) -- 1013
				if "table" == _type_1 or "userdata" == _type_1 then -- 1013
					file = _obj_0.file -- 1013
				end -- 1013
			end -- 1013
			local content -- 1013
			do -- 1013
				local _obj_0 = req.body -- 1013
				local _type_1 = type(_obj_0) -- 1013
				if "table" == _type_1 or "userdata" == _type_1 then -- 1013
					content = _obj_0.content -- 1013
				end -- 1013
			end -- 1013
			if file ~= nil and content ~= nil then -- 1013
				if not (file:sub(-6) == ".b.lua") then -- 1014
					return { -- 1015
						success = false, -- 1015
						phase = "request", -- 1015
						message = "only .b.lua files can be converted" -- 1015
					} -- 1015
				end -- 1014
				local loader, err = load("_ENV = {}\n" .. content) -- 1016
				if not loader then -- 1017
					return { -- 1018
						success = false, -- 1018
						phase = "parse", -- 1018
						message = tostring(err) -- 1018
					} -- 1018
				end -- 1017
				local ok, data = pcall(loader) -- 1019
				if not ok then -- 1020
					return { -- 1021
						success = false, -- 1021
						phase = "execute", -- 1021
						message = tostring(data) -- 1021
					} -- 1021
				end -- 1020
				if not ("table" == type(data) and data[1] == "Array") then -- 1022
					return { -- 1023
						success = false, -- 1023
						phase = "validate", -- 1023
						message = "body lua root must be {\"Array\", ...}" -- 1023
					} -- 1023
				end -- 1022
				local text, jsonErr = json.encode(data, false, true) -- 1024
				if not text then -- 1025
					return { -- 1026
						success = false, -- 1026
						phase = "encode", -- 1026
						message = tostring(jsonErr) -- 1026
					} -- 1026
				end -- 1025
				return { -- 1027
					success = true, -- 1027
					json = text -- 1027
				} -- 1027
			end -- 1013
		end -- 1013
	end -- 1013
	return { -- 1012
		success = false, -- 1012
		phase = "request", -- 1012
		message = "invalid request" -- 1012
	} -- 1012
end) -- 1012
local updateInferedDesc -- 1029
updateInferedDesc = function(infered) -- 1029
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1030
		return -- 1030
	end -- 1030
	local key, row = infered.key, infered.row -- 1031
	local codes = Content:loadAsync(key) -- 1032
	if codes then -- 1032
		local comments = { } -- 1033
		local line = 0 -- 1034
		local skipping = false -- 1035
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1036
			line = line + 1 -- 1037
			if line >= row then -- 1038
				break -- 1038
			end -- 1038
			if lineCode:match("^%s*%-%- @") then -- 1039
				skipping = true -- 1040
				goto _continue_0 -- 1041
			end -- 1039
			local result = lineCode:match("^%s*%-%- (.+)") -- 1042
			if result then -- 1042
				if not skipping then -- 1043
					comments[#comments + 1] = result -- 1043
				end -- 1043
			elseif #comments > 0 then -- 1044
				comments = { } -- 1045
				skipping = false -- 1046
			end -- 1042
			::_continue_0:: -- 1037
		end -- 1036
		infered.doc = table.concat(comments, "\n") -- 1047
	end -- 1032
end -- 1029
HttpServer:postSchedule("/infer", function(req) -- 1049
	do -- 1050
		local _type_0 = type(req) -- 1050
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1050
		if _tab_0 then -- 1050
			local lang -- 1050
			do -- 1050
				local _obj_0 = req.body -- 1050
				local _type_1 = type(_obj_0) -- 1050
				if "table" == _type_1 or "userdata" == _type_1 then -- 1050
					lang = _obj_0.lang -- 1050
				end -- 1050
			end -- 1050
			local file -- 1050
			do -- 1050
				local _obj_0 = req.body -- 1050
				local _type_1 = type(_obj_0) -- 1050
				if "table" == _type_1 or "userdata" == _type_1 then -- 1050
					file = _obj_0.file -- 1050
				end -- 1050
			end -- 1050
			local content -- 1050
			do -- 1050
				local _obj_0 = req.body -- 1050
				local _type_1 = type(_obj_0) -- 1050
				if "table" == _type_1 or "userdata" == _type_1 then -- 1050
					content = _obj_0.content -- 1050
				end -- 1050
			end -- 1050
			local line -- 1050
			do -- 1050
				local _obj_0 = req.body -- 1050
				local _type_1 = type(_obj_0) -- 1050
				if "table" == _type_1 or "userdata" == _type_1 then -- 1050
					line = _obj_0.line -- 1050
				end -- 1050
			end -- 1050
			local row -- 1050
			do -- 1050
				local _obj_0 = req.body -- 1050
				local _type_1 = type(_obj_0) -- 1050
				if "table" == _type_1 or "userdata" == _type_1 then -- 1050
					row = _obj_0.row -- 1050
				end -- 1050
			end -- 1050
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1050
				local searchPath = getSearchPath(file) -- 1051
				if "tl" == lang or "lua" == lang then -- 1052
					if CheckTIC80Code(content) then -- 1053
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1054
					end -- 1053
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1055
					if (infered ~= nil) then -- 1056
						updateInferedDesc(infered) -- 1057
						return { -- 1058
							success = true, -- 1058
							infered = infered -- 1058
						} -- 1058
					end -- 1056
				elseif "yue" == lang then -- 1059
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1060
					if not luaCodes then -- 1061
						return { -- 1061
							success = false -- 1061
						} -- 1061
					end -- 1061
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1062
					if (infered ~= nil) then -- 1063
						local col -- 1064
						file, row, col = infered.file, infered.row, infered.col -- 1064
						if file == "" and row > 0 and col > 0 then -- 1065
							infered.row = lineMap[row] or 0 -- 1066
							infered.col = 0 -- 1067
						end -- 1065
						updateInferedDesc(infered) -- 1068
						return { -- 1069
							success = true, -- 1069
							infered = infered -- 1069
						} -- 1069
					end -- 1063
				end -- 1052
			end -- 1050
		end -- 1050
	end -- 1050
	return { -- 1049
		success = false -- 1049
	} -- 1049
end) -- 1049
local _anon_func_3 = function(doc) -- 1120
	local _accum_0 = { } -- 1120
	local _len_0 = 1 -- 1120
	local _list_0 = doc.params -- 1120
	for _index_0 = 1, #_list_0 do -- 1120
		local param = _list_0[_index_0] -- 1120
		_accum_0[_len_0] = param.name -- 1120
		_len_0 = _len_0 + 1 -- 1120
	end -- 1120
	return _accum_0 -- 1120
end -- 1120
local getParamDocs -- 1071
getParamDocs = function(signatures) -- 1071
	do -- 1072
		local codes = Content:loadAsync(signatures[1].file) -- 1072
		if codes then -- 1072
			local comments = { } -- 1073
			local params = { } -- 1074
			local line = 0 -- 1075
			local docs = { } -- 1076
			local returnType = nil -- 1077
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1078
				line = line + 1 -- 1079
				local needBreak = true -- 1080
				for i, _des_0 in ipairs(signatures) do -- 1081
					local row = _des_0.row -- 1081
					if line >= row and not (docs[i] ~= nil) then -- 1082
						if #comments > 0 or #params > 0 or returnType then -- 1083
							docs[i] = { -- 1085
								doc = table.concat(comments, "  \n"), -- 1085
								returnType = returnType -- 1086
							} -- 1084
							if #params > 0 then -- 1088
								docs[i].params = params -- 1088
							end -- 1088
						else -- 1090
							docs[i] = false -- 1090
						end -- 1083
					end -- 1082
					if not docs[i] then -- 1091
						needBreak = false -- 1091
					end -- 1091
				end -- 1081
				if needBreak then -- 1092
					break -- 1092
				end -- 1092
				local result = lineCode:match("%s*%-%- (.+)") -- 1093
				if result then -- 1093
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1094
					if not name then -- 1095
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1096
					end -- 1095
					if name then -- 1097
						local pname = name -- 1098
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1099
							pname = pname .. "?" -- 1099
						end -- 1099
						params[#params + 1] = { -- 1101
							name = tostring(pname) .. ": " .. tostring(typ), -- 1101
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1102
						} -- 1100
					else -- 1105
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1105
						if typ then -- 1105
							if returnType then -- 1106
								returnType = returnType .. ", " .. typ -- 1107
							else -- 1109
								returnType = typ -- 1109
							end -- 1106
							result = result:gsub("@return", "**return:**") -- 1110
						end -- 1105
						comments[#comments + 1] = result -- 1111
					end -- 1097
				elseif #comments > 0 then -- 1112
					comments = { } -- 1113
					params = { } -- 1114
					returnType = nil -- 1115
				end -- 1093
			end -- 1078
			local results = { } -- 1116
			for _index_0 = 1, #docs do -- 1117
				local doc = docs[_index_0] -- 1117
				if not doc then -- 1118
					goto _continue_0 -- 1118
				end -- 1118
				if doc.params then -- 1119
					doc.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1120
				else -- 1122
					doc.desc = "function()" -- 1122
				end -- 1119
				if doc.returnType then -- 1123
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 1124
					doc.returnType = nil -- 1125
				end -- 1123
				results[#results + 1] = doc -- 1126
				::_continue_0:: -- 1118
			end -- 1117
			if #results > 0 then -- 1127
				return results -- 1127
			else -- 1127
				return nil -- 1127
			end -- 1127
		end -- 1072
	end -- 1072
	return nil -- 1071
end -- 1071
HttpServer:postSchedule("/signature", function(req) -- 1129
	do -- 1130
		local _type_0 = type(req) -- 1130
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1130
		if _tab_0 then -- 1130
			local lang -- 1130
			do -- 1130
				local _obj_0 = req.body -- 1130
				local _type_1 = type(_obj_0) -- 1130
				if "table" == _type_1 or "userdata" == _type_1 then -- 1130
					lang = _obj_0.lang -- 1130
				end -- 1130
			end -- 1130
			local file -- 1130
			do -- 1130
				local _obj_0 = req.body -- 1130
				local _type_1 = type(_obj_0) -- 1130
				if "table" == _type_1 or "userdata" == _type_1 then -- 1130
					file = _obj_0.file -- 1130
				end -- 1130
			end -- 1130
			local content -- 1130
			do -- 1130
				local _obj_0 = req.body -- 1130
				local _type_1 = type(_obj_0) -- 1130
				if "table" == _type_1 or "userdata" == _type_1 then -- 1130
					content = _obj_0.content -- 1130
				end -- 1130
			end -- 1130
			local line -- 1130
			do -- 1130
				local _obj_0 = req.body -- 1130
				local _type_1 = type(_obj_0) -- 1130
				if "table" == _type_1 or "userdata" == _type_1 then -- 1130
					line = _obj_0.line -- 1130
				end -- 1130
			end -- 1130
			local row -- 1130
			do -- 1130
				local _obj_0 = req.body -- 1130
				local _type_1 = type(_obj_0) -- 1130
				if "table" == _type_1 or "userdata" == _type_1 then -- 1130
					row = _obj_0.row -- 1130
				end -- 1130
			end -- 1130
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1130
				local searchPath = getSearchPath(file) -- 1131
				if "tl" == lang or "lua" == lang then -- 1132
					if CheckTIC80Code(content) then -- 1133
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1134
					end -- 1133
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1135
					if signatures then -- 1135
						signatures = getParamDocs(signatures) -- 1136
						if signatures then -- 1136
							return { -- 1137
								success = true, -- 1137
								signatures = signatures -- 1137
							} -- 1137
						end -- 1136
					end -- 1135
				elseif "yue" == lang then -- 1138
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1139
					if not luaCodes then -- 1140
						return { -- 1140
							success = false -- 1140
						} -- 1140
					end -- 1140
					do -- 1141
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1141
						if chainOp then -- 1141
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1142
							if withVar then -- 1142
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1143
							end -- 1142
						end -- 1141
					end -- 1141
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1144
					if signatures then -- 1144
						signatures = getParamDocs(signatures) -- 1145
						if signatures then -- 1145
							return { -- 1146
								success = true, -- 1146
								signatures = signatures -- 1146
							} -- 1146
						end -- 1145
					else -- 1147
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1147
						if signatures then -- 1147
							signatures = getParamDocs(signatures) -- 1148
							if signatures then -- 1148
								return { -- 1149
									success = true, -- 1149
									signatures = signatures -- 1149
								} -- 1149
							end -- 1148
						end -- 1147
					end -- 1144
				end -- 1132
			end -- 1130
		end -- 1130
	end -- 1130
	return { -- 1129
		success = false -- 1129
	} -- 1129
end) -- 1129
local luaKeywords = { -- 1152
	'and', -- 1152
	'break', -- 1153
	'do', -- 1154
	'else', -- 1155
	'elseif', -- 1156
	'end', -- 1157
	'false', -- 1158
	'for', -- 1159
	'function', -- 1160
	'goto', -- 1161
	'if', -- 1162
	'in', -- 1163
	'local', -- 1164
	'nil', -- 1165
	'not', -- 1166
	'or', -- 1167
	'repeat', -- 1168
	'return', -- 1169
	'then', -- 1170
	'true', -- 1171
	'until', -- 1172
	'while' -- 1173
} -- 1151
local tealKeywords = { -- 1177
	'record', -- 1177
	'as', -- 1178
	'is', -- 1179
	'type', -- 1180
	'embed', -- 1181
	'enum', -- 1182
	'global', -- 1183
	'any', -- 1184
	'boolean', -- 1185
	'integer', -- 1186
	'number', -- 1187
	'string', -- 1188
	'thread' -- 1189
} -- 1176
local yueKeywords = { -- 1193
	"and", -- 1193
	"break", -- 1194
	"do", -- 1195
	"else", -- 1196
	"elseif", -- 1197
	"false", -- 1198
	"for", -- 1199
	"goto", -- 1200
	"if", -- 1201
	"in", -- 1202
	"local", -- 1203
	"nil", -- 1204
	"not", -- 1205
	"or", -- 1206
	"repeat", -- 1207
	"return", -- 1208
	"then", -- 1209
	"true", -- 1210
	"until", -- 1211
	"while", -- 1212
	"as", -- 1213
	"class", -- 1214
	"continue", -- 1215
	"export", -- 1216
	"extends", -- 1217
	"from", -- 1218
	"global", -- 1219
	"import", -- 1220
	"macro", -- 1221
	"switch", -- 1222
	"try", -- 1223
	"unless", -- 1224
	"using", -- 1225
	"when", -- 1226
	"with" -- 1227
} -- 1192
local _anon_func_4 = function(f) -- 1263
	local _val_0 = Path:getExt(f) -- 1263
	return "ttf" == _val_0 or "otf" == _val_0 -- 1263
end -- 1263
local _anon_func_5 = function(suggestions) -- 1289
	local _tbl_0 = { } -- 1289
	for _index_0 = 1, #suggestions do -- 1289
		local item = suggestions[_index_0] -- 1289
		_tbl_0[item[1] .. item[2]] = item -- 1289
	end -- 1289
	return _tbl_0 -- 1289
end -- 1289
HttpServer:postSchedule("/complete", function(req) -- 1230
	do -- 1231
		local _type_0 = type(req) -- 1231
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1231
		if _tab_0 then -- 1231
			local lang -- 1231
			do -- 1231
				local _obj_0 = req.body -- 1231
				local _type_1 = type(_obj_0) -- 1231
				if "table" == _type_1 or "userdata" == _type_1 then -- 1231
					lang = _obj_0.lang -- 1231
				end -- 1231
			end -- 1231
			local file -- 1231
			do -- 1231
				local _obj_0 = req.body -- 1231
				local _type_1 = type(_obj_0) -- 1231
				if "table" == _type_1 or "userdata" == _type_1 then -- 1231
					file = _obj_0.file -- 1231
				end -- 1231
			end -- 1231
			local content -- 1231
			do -- 1231
				local _obj_0 = req.body -- 1231
				local _type_1 = type(_obj_0) -- 1231
				if "table" == _type_1 or "userdata" == _type_1 then -- 1231
					content = _obj_0.content -- 1231
				end -- 1231
			end -- 1231
			local line -- 1231
			do -- 1231
				local _obj_0 = req.body -- 1231
				local _type_1 = type(_obj_0) -- 1231
				if "table" == _type_1 or "userdata" == _type_1 then -- 1231
					line = _obj_0.line -- 1231
				end -- 1231
			end -- 1231
			local row -- 1231
			do -- 1231
				local _obj_0 = req.body -- 1231
				local _type_1 = type(_obj_0) -- 1231
				if "table" == _type_1 or "userdata" == _type_1 then -- 1231
					row = _obj_0.row -- 1231
				end -- 1231
			end -- 1231
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1231
				local searchPath = getSearchPath(file) -- 1232
				repeat -- 1233
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1234
					if lang == "yue" then -- 1235
						if not item then -- 1236
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1236
						end -- 1236
						if not item then -- 1237
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1237
						end -- 1237
					end -- 1235
					local searchType = nil -- 1238
					if not item then -- 1239
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1240
						if lang == "yue" then -- 1241
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1242
						end -- 1241
						if (item ~= nil) then -- 1243
							searchType = "Image" -- 1243
						end -- 1243
					end -- 1239
					if not item then -- 1244
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1245
						if lang == "yue" then -- 1246
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1247
						end -- 1246
						if (item ~= nil) then -- 1248
							searchType = "Font" -- 1248
						end -- 1248
					end -- 1244
					if not item then -- 1249
						break -- 1249
					end -- 1249
					local searchPaths = Content.searchPaths -- 1250
					local _list_0 = getSearchFolders(file) -- 1251
					for _index_0 = 1, #_list_0 do -- 1251
						local folder = _list_0[_index_0] -- 1251
						searchPaths[#searchPaths + 1] = folder -- 1252
					end -- 1251
					if searchType then -- 1253
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1253
					end -- 1253
					local tokens -- 1254
					do -- 1254
						local _accum_0 = { } -- 1254
						local _len_0 = 1 -- 1254
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1254
							_accum_0[_len_0] = mod -- 1254
							_len_0 = _len_0 + 1 -- 1254
						end -- 1254
						tokens = _accum_0 -- 1254
					end -- 1254
					local suggestions = { } -- 1255
					for _index_0 = 1, #searchPaths do -- 1256
						local path = searchPaths[_index_0] -- 1256
						local sPath = Path(path, table.unpack(tokens)) -- 1257
						if not Content:exist(sPath) then -- 1258
							goto _continue_0 -- 1258
						end -- 1258
						if searchType == "Font" then -- 1259
							local fontPath = Path(sPath, "Font") -- 1260
							if Content:exist(fontPath) then -- 1261
								local _list_1 = Content:getFiles(fontPath) -- 1262
								for _index_1 = 1, #_list_1 do -- 1262
									local f = _list_1[_index_1] -- 1262
									if _anon_func_4(f) then -- 1263
										if "." == f:sub(1, 1) then -- 1264
											goto _continue_1 -- 1264
										end -- 1264
										suggestions[#suggestions + 1] = { -- 1265
											Path:getName(f), -- 1265
											"font", -- 1265
											"field" -- 1265
										} -- 1265
									end -- 1263
									::_continue_1:: -- 1263
								end -- 1262
							end -- 1261
						end -- 1259
						local _list_1 = Content:getFiles(sPath) -- 1266
						for _index_1 = 1, #_list_1 do -- 1266
							local f = _list_1[_index_1] -- 1266
							if "Image" == searchType then -- 1267
								do -- 1268
									local _exp_0 = Path:getExt(f) -- 1268
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1268
										if "." == f:sub(1, 1) then -- 1269
											goto _continue_2 -- 1269
										end -- 1269
										suggestions[#suggestions + 1] = { -- 1270
											f, -- 1270
											"image", -- 1270
											"field" -- 1270
										} -- 1270
									end -- 1268
								end -- 1268
								goto _continue_2 -- 1271
							elseif "Font" == searchType then -- 1272
								do -- 1273
									local _exp_0 = Path:getExt(f) -- 1273
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1273
										if "." == f:sub(1, 1) then -- 1274
											goto _continue_2 -- 1274
										end -- 1274
										suggestions[#suggestions + 1] = { -- 1275
											f, -- 1275
											"font", -- 1275
											"field" -- 1275
										} -- 1275
									end -- 1273
								end -- 1273
								goto _continue_2 -- 1276
							end -- 1267
							local _exp_0 = Path:getExt(f) -- 1277
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1277
								local name = Path:getName(f) -- 1278
								if "d" == Path:getExt(name) then -- 1279
									goto _continue_2 -- 1279
								end -- 1279
								if "." == name:sub(1, 1) then -- 1280
									goto _continue_2 -- 1280
								end -- 1280
								suggestions[#suggestions + 1] = { -- 1281
									name, -- 1281
									"module", -- 1281
									"field" -- 1281
								} -- 1281
							end -- 1277
							::_continue_2:: -- 1267
						end -- 1266
						local _list_2 = Content:getDirs(sPath) -- 1282
						for _index_1 = 1, #_list_2 do -- 1282
							local dir = _list_2[_index_1] -- 1282
							if "." == dir:sub(1, 1) then -- 1283
								goto _continue_3 -- 1283
							end -- 1283
							suggestions[#suggestions + 1] = { -- 1284
								dir, -- 1284
								"folder", -- 1284
								"variable" -- 1284
							} -- 1284
							::_continue_3:: -- 1283
						end -- 1282
						::_continue_0:: -- 1257
					end -- 1256
					if item == "" and not searchType then -- 1285
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1286
						for _index_0 = 1, #_list_1 do -- 1286
							local _des_0 = _list_1[_index_0] -- 1286
							local name = _des_0[1] -- 1286
							suggestions[#suggestions + 1] = { -- 1287
								name, -- 1287
								"dora module", -- 1287
								"function" -- 1287
							} -- 1287
						end -- 1286
					end -- 1285
					if #suggestions > 0 then -- 1288
						do -- 1289
							local _accum_0 = { } -- 1289
							local _len_0 = 1 -- 1289
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1289
								_accum_0[_len_0] = v -- 1289
								_len_0 = _len_0 + 1 -- 1289
							end -- 1289
							suggestions = _accum_0 -- 1289
						end -- 1289
						return { -- 1290
							success = true, -- 1290
							suggestions = suggestions -- 1290
						} -- 1290
					else -- 1292
						return { -- 1292
							success = false -- 1292
						} -- 1292
					end -- 1288
				until true -- 1233
				if "tl" == lang or "lua" == lang then -- 1294
					do -- 1295
						local isTIC80 = CheckTIC80Code(content) -- 1295
						if isTIC80 then -- 1295
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1296
						end -- 1295
					end -- 1295
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1297
					if not line:match("[%.:]$") then -- 1298
						local checkSet -- 1299
						do -- 1299
							local _tbl_0 = { } -- 1299
							for _index_0 = 1, #suggestions do -- 1299
								local _des_0 = suggestions[_index_0] -- 1299
								local name = _des_0[1] -- 1299
								_tbl_0[name] = true -- 1299
							end -- 1299
							checkSet = _tbl_0 -- 1299
						end -- 1299
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1300
						for _index_0 = 1, #_list_0 do -- 1300
							local item = _list_0[_index_0] -- 1300
							if not checkSet[item[1]] then -- 1301
								suggestions[#suggestions + 1] = item -- 1301
							end -- 1301
						end -- 1300
						for _index_0 = 1, #luaKeywords do -- 1302
							local word = luaKeywords[_index_0] -- 1302
							suggestions[#suggestions + 1] = { -- 1303
								word, -- 1303
								"keyword", -- 1303
								"keyword" -- 1303
							} -- 1303
						end -- 1302
						if lang == "tl" then -- 1304
							for _index_0 = 1, #tealKeywords do -- 1305
								local word = tealKeywords[_index_0] -- 1305
								suggestions[#suggestions + 1] = { -- 1306
									word, -- 1306
									"keyword", -- 1306
									"keyword" -- 1306
								} -- 1306
							end -- 1305
						end -- 1304
					end -- 1298
					if #suggestions > 0 then -- 1307
						return { -- 1308
							success = true, -- 1308
							suggestions = suggestions -- 1308
						} -- 1308
					end -- 1307
				elseif "yue" == lang then -- 1309
					local suggestions = { } -- 1310
					local gotGlobals = false -- 1311
					do -- 1312
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1312
						if luaCodes then -- 1312
							gotGlobals = true -- 1313
							do -- 1314
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1314
								if chainOp then -- 1314
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1315
									if not withVar then -- 1316
										return { -- 1316
											success = false -- 1316
										} -- 1316
									end -- 1316
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1317
								elseif line:match("^([%.\\])$") then -- 1318
									return { -- 1319
										success = false -- 1319
									} -- 1319
								end -- 1314
							end -- 1314
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1320
							for _index_0 = 1, #_list_0 do -- 1320
								local item = _list_0[_index_0] -- 1320
								suggestions[#suggestions + 1] = item -- 1320
							end -- 1320
							if #suggestions == 0 then -- 1321
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1322
								for _index_0 = 1, #_list_1 do -- 1322
									local item = _list_1[_index_0] -- 1322
									suggestions[#suggestions + 1] = item -- 1322
								end -- 1322
							end -- 1321
						end -- 1312
					end -- 1312
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1323
						local checkSet -- 1324
						do -- 1324
							local _tbl_0 = { } -- 1324
							for _index_0 = 1, #suggestions do -- 1324
								local _des_0 = suggestions[_index_0] -- 1324
								local name = _des_0[1] -- 1324
								_tbl_0[name] = true -- 1324
							end -- 1324
							checkSet = _tbl_0 -- 1324
						end -- 1324
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1325
						for _index_0 = 1, #_list_0 do -- 1325
							local item = _list_0[_index_0] -- 1325
							if not checkSet[item[1]] then -- 1326
								suggestions[#suggestions + 1] = item -- 1326
							end -- 1326
						end -- 1325
						if not gotGlobals then -- 1327
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1328
							for _index_0 = 1, #_list_1 do -- 1328
								local item = _list_1[_index_0] -- 1328
								if not checkSet[item[1]] then -- 1329
									suggestions[#suggestions + 1] = item -- 1329
								end -- 1329
							end -- 1328
						end -- 1327
						for _index_0 = 1, #yueKeywords do -- 1330
							local word = yueKeywords[_index_0] -- 1330
							if not checkSet[word] then -- 1331
								suggestions[#suggestions + 1] = { -- 1332
									word, -- 1332
									"keyword", -- 1332
									"keyword" -- 1332
								} -- 1332
							end -- 1331
						end -- 1330
					end -- 1323
					if #suggestions > 0 then -- 1333
						return { -- 1334
							success = true, -- 1334
							suggestions = suggestions -- 1334
						} -- 1334
					end -- 1333
				elseif "xml" == lang then -- 1335
					local items = xml.complete(content) -- 1336
					if #items > 0 then -- 1337
						local suggestions -- 1338
						do -- 1338
							local _accum_0 = { } -- 1338
							local _len_0 = 1 -- 1338
							for _index_0 = 1, #items do -- 1338
								local _des_0 = items[_index_0] -- 1338
								local label, insertText = _des_0[1], _des_0[2] -- 1338
								_accum_0[_len_0] = { -- 1339
									label, -- 1339
									insertText, -- 1339
									"field" -- 1339
								} -- 1339
								_len_0 = _len_0 + 1 -- 1339
							end -- 1338
							suggestions = _accum_0 -- 1338
						end -- 1338
						return { -- 1340
							success = true, -- 1340
							suggestions = suggestions -- 1340
						} -- 1340
					end -- 1337
				end -- 1294
			end -- 1231
		end -- 1231
	end -- 1231
	return { -- 1230
		success = false -- 1230
	} -- 1230
end) -- 1230
HttpServer:upload("/upload", function(req, filename) -- 1344
	do -- 1345
		local _type_0 = type(req) -- 1345
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1345
		if _tab_0 then -- 1345
			local path -- 1345
			do -- 1345
				local _obj_0 = req.params -- 1345
				local _type_1 = type(_obj_0) -- 1345
				if "table" == _type_1 or "userdata" == _type_1 then -- 1345
					path = _obj_0.path -- 1345
				end -- 1345
			end -- 1345
			if path ~= nil then -- 1345
				local uploadPath = Path(Content.writablePath, ".upload") -- 1346
				if not Content:exist(uploadPath) then -- 1347
					Content:mkdir(uploadPath) -- 1348
				end -- 1347
				local targetPath = Path(uploadPath, filename) -- 1349
				Content:mkdir(Path:getPath(targetPath)) -- 1350
				return targetPath -- 1351
			end -- 1345
		end -- 1345
	end -- 1345
	return nil -- 1344
end, function(req, file) -- 1352
	do -- 1353
		local _type_0 = type(req) -- 1353
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1353
		if _tab_0 then -- 1353
			local path -- 1353
			do -- 1353
				local _obj_0 = req.params -- 1353
				local _type_1 = type(_obj_0) -- 1353
				if "table" == _type_1 or "userdata" == _type_1 then -- 1353
					path = _obj_0.path -- 1353
				end -- 1353
			end -- 1353
			if path ~= nil then -- 1353
				path = Path(Content.writablePath, path) -- 1354
				if Content:exist(path) then -- 1355
					local uploadPath = Path(Content.writablePath, ".upload") -- 1356
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1357
					Content:mkdir(Path:getPath(targetPath)) -- 1358
					if Content:move(file, targetPath) then -- 1359
						return true -- 1360
					end -- 1359
				end -- 1355
			end -- 1353
		end -- 1353
	end -- 1353
	return false -- 1352
end) -- 1342
HttpServer:post("/list", function(req) -- 1363
	do -- 1364
		local _type_0 = type(req) -- 1364
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1364
		if _tab_0 then -- 1364
			local path -- 1364
			do -- 1364
				local _obj_0 = req.body -- 1364
				local _type_1 = type(_obj_0) -- 1364
				if "table" == _type_1 or "userdata" == _type_1 then -- 1364
					path = _obj_0.path -- 1364
				end -- 1364
			end -- 1364
			if path ~= nil then -- 1364
				if Content:exist(path) then -- 1365
					local files = { } -- 1366
					local visitAssets -- 1367
					visitAssets = function(path, folder) -- 1367
						local dirs = Content:getDirs(path) -- 1368
						for _index_0 = 1, #dirs do -- 1369
							local dir = dirs[_index_0] -- 1369
							if dir:match("^%.") or dir == "node_modules" then -- 1370
								goto _continue_0 -- 1370
							end -- 1370
							local current -- 1371
							if folder == "" then -- 1371
								current = dir -- 1372
							else -- 1374
								current = Path(folder, dir) -- 1374
							end -- 1371
							files[#files + 1] = current -- 1375
							visitAssets(Path(path, dir), current) -- 1376
							::_continue_0:: -- 1370
						end -- 1369
						local fs = Content:getFiles(path) -- 1377
						for _index_0 = 1, #fs do -- 1378
							local f = fs[_index_0] -- 1378
							if (".DS_Store" == f) then -- 1379
								goto _continue_1 -- 1380
							end -- 1379
							if folder == "" then -- 1381
								files[#files + 1] = f -- 1382
							else -- 1384
								files[#files + 1] = Path(folder, f) -- 1384
							end -- 1381
							::_continue_1:: -- 1379
						end -- 1378
					end -- 1367
					visitAssets(path, "") -- 1385
					if #files == 0 then -- 1386
						files = nil -- 1386
					end -- 1386
					return { -- 1387
						success = true, -- 1387
						files = files -- 1387
					} -- 1387
				end -- 1365
			end -- 1364
		end -- 1364
	end -- 1364
	return { -- 1363
		success = false -- 1363
	} -- 1363
end) -- 1363
HttpServer:post("/info", function(req) -- 1389
	local Entry = require("Script.Dev.Entry") -- 1390
	local config = Entry.getConfig() -- 1391
	do -- 1392
		local _type_0 = type(req) -- 1392
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1392
		if _tab_0 then -- 1392
			local webIDETourCompleted -- 1392
			do -- 1392
				local _obj_0 = req.body -- 1392
				local _type_1 = type(_obj_0) -- 1392
				if "table" == _type_1 or "userdata" == _type_1 then -- 1392
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1392
				end -- 1392
			end -- 1392
			if webIDETourCompleted ~= nil then -- 1392
				config.webIDETourCompleted = webIDETourCompleted == true -- 1393
			end -- 1392
		end -- 1392
	end -- 1392
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1394
	local engineDev = Entry.getEngineDev() -- 1395
	Entry.connectWebIDE() -- 1396
	return { -- 1398
		platform = App.platform, -- 1398
		locale = App.locale, -- 1399
		version = App.version, -- 1400
		engineDev = engineDev, -- 1401
		webProfiler = webProfiler, -- 1402
		drawerWidth = drawerWidth, -- 1403
		webIDETourCompleted = webIDETourCompleted == true -- 1404
	} -- 1397
end) -- 1389
local ensureLLMConfigTable -- 1406
ensureLLMConfigTable = function() -- 1406
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1407
	if columns and #columns > 0 then -- 1408
		local expected = { -- 1410
			id = true, -- 1410
			name = true, -- 1411
			url = true, -- 1412
			model = true, -- 1413
			api_key = true, -- 1414
			context_window = true, -- 1415
			temperature = true, -- 1416
			max_tokens = true, -- 1417
			reasoning_effort = true, -- 1418
			custom_options = true, -- 1419
			supports_function_calling = true, -- 1420
			active = true, -- 1421
			created_at = true, -- 1422
			updated_at = true -- 1423
		} -- 1409
		local existing = { } -- 1425
		local valid = true -- 1426
		for _index_0 = 1, #columns do -- 1427
			local row = columns[_index_0] -- 1427
			local columnName = tostring(row[2]) -- 1428
			existing[columnName] = true -- 1429
			if not expected[columnName] then -- 1430
				valid = false -- 1431
				break -- 1432
			end -- 1430
		end -- 1427
		if valid then -- 1433
			if not existing.context_window then -- 1434
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1435
			end -- 1434
			if not existing.temperature then -- 1436
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1437
			end -- 1436
			if not existing.max_tokens then -- 1438
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 1439
			end -- 1438
			if not existing.reasoning_effort then -- 1440
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1441
			end -- 1440
			if not existing.custom_options then -- 1442
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1443
			end -- 1442
			if not existing.supports_function_calling then -- 1444
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1445
			end -- 1444
		else -- 1447
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1447
		end -- 1433
	end -- 1408
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
	]]) -- 1448
end -- 1406
local normalizeContextWindow -- 1467
normalizeContextWindow = function(value) -- 1467
	local contextWindow = tonumber(value) -- 1468
	if contextWindow == nil or contextWindow < 64000 then -- 1469
		return 64000 -- 1470
	end -- 1469
	return math.max(64000, math.floor(contextWindow)) -- 1471
end -- 1467
local normalizeTemperature -- 1473
normalizeTemperature = function(value) -- 1473
	local temperature = tonumber(value) -- 1474
	if temperature == nil then -- 1475
		return 0.1 -- 1476
	end -- 1475
	return math.max(0, math.min(2, temperature)) -- 1477
end -- 1473
local normalizeMaxTokens -- 1479
normalizeMaxTokens = function(value) -- 1479
	local maxTokens = tonumber(value) -- 1480
	if maxTokens == nil or maxTokens < 1 then -- 1481
		return 8192 -- 1482
	end -- 1481
	return math.max(1, math.floor(maxTokens)) -- 1483
end -- 1479
local normalizeReasoningEffort -- 1485
normalizeReasoningEffort = function(value) -- 1485
	if value == nil then -- 1486
		return "" -- 1487
	end -- 1486
	local effort = tostring(value) -- 1488
	return effort:match("^%s*(.-)%s*$") or "" -- 1489
end -- 1485
local normalizeCustomOptions -- 1491
normalizeCustomOptions = function(value) -- 1491
	if value == nil then -- 1492
		return "" -- 1493
	end -- 1492
	local options = tostring(value) -- 1494
	options = options:match("^%s*(.-)%s*$") or "" -- 1495
	return options -- 1496
end -- 1491
local validateCustomOptions -- 1498
validateCustomOptions = function(value) -- 1498
	local options = normalizeCustomOptions(value) -- 1499
	if options == "" then -- 1500
		return true -- 1500
	end -- 1500
	if not options:match("^%s*{") then -- 1501
		return false -- 1501
	end -- 1501
	local decoded = json.decode(options) -- 1502
	return type(decoded) == "table" -- 1503
end -- 1498
HttpServer:post("/llm/list", function() -- 1505
	ensureLLMConfigTable() -- 1506
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1507
	local items -- 1511
	if rows and #rows > 0 then -- 1511
		local _accum_0 = { } -- 1512
		local _len_0 = 1 -- 1512
		for _index_0 = 1, #rows do -- 1512
			local _des_0 = rows[_index_0] -- 1512
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1512
			_accum_0[_len_0] = { -- 1513
				id = id, -- 1513
				name = name, -- 1513
				url = url, -- 1513
				model = model, -- 1513
				key = key, -- 1513
				contextWindow = normalizeContextWindow(contextWindow), -- 1513
				temperature = normalizeTemperature(temperature), -- 1513
				maxTokens = normalizeMaxTokens(maxTokens), -- 1513
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1513
				customOptions = normalizeCustomOptions(customOptions), -- 1513
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1513
			} -- 1513
			_len_0 = _len_0 + 1 -- 1513
		end -- 1512
		items = _accum_0 -- 1511
	end -- 1511
	return { -- 1514
		success = true, -- 1514
		items = items -- 1514
	} -- 1514
end) -- 1505
HttpServer:post("/llm/create", function(req) -- 1516
	ensureLLMConfigTable() -- 1517
	do -- 1518
		local _type_0 = type(req) -- 1518
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1518
		if _tab_0 then -- 1518
			local body = req.body -- 1518
			if body ~= nil then -- 1518
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1519
				local now = os.time() -- 1520
				if name == nil or url == nil or model == nil or key == nil then -- 1521
					return invalidArguments -- 1522
				end -- 1521
				contextWindow = normalizeContextWindow(contextWindow) -- 1523
				temperature = normalizeTemperature(temperature) -- 1524
				maxTokens = normalizeMaxTokens(maxTokens) -- 1525
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1526
				customOptions = normalizeCustomOptions(customOptions) -- 1527
				if not validateCustomOptions(customOptions) then -- 1528
					return { -- 1528
						success = false, -- 1528
						message = "customOptions must be a JSON object" -- 1528
					} -- 1528
				end -- 1528
				if supportsFunctionCalling == false then -- 1529
					supportsFunctionCalling = 0 -- 1529
				else -- 1529
					supportsFunctionCalling = 1 -- 1529
				end -- 1529
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1536
					tostring(name), -- 1536
					tostring(url), -- 1537
					tostring(model), -- 1538
					tostring(key), -- 1539
					contextWindow, -- 1540
					temperature, -- 1541
					maxTokens, -- 1542
					reasoningEffort, -- 1543
					customOptions, -- 1544
					supportsFunctionCalling, -- 1545
					1, -- 1546
					now, -- 1547
					now -- 1548
				}) -- 1530
				return { -- 1550
					success = affected >= 0 -- 1550
				} -- 1550
			end -- 1518
		end -- 1518
	end -- 1518
	return invalidArguments -- 1516
end) -- 1516
HttpServer:post("/llm/update", function(req) -- 1552
	ensureLLMConfigTable() -- 1553
	do -- 1554
		local _type_0 = type(req) -- 1554
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1554
		if _tab_0 then -- 1554
			local body = req.body -- 1554
			if body ~= nil then -- 1554
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1555
				local now = os.time() -- 1556
				id = tonumber(id) -- 1557
				if id == nil then -- 1558
					return invalidArguments -- 1558
				end -- 1558
				contextWindow = normalizeContextWindow(contextWindow) -- 1559
				temperature = normalizeTemperature(temperature) -- 1560
				maxTokens = normalizeMaxTokens(maxTokens) -- 1561
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1562
				customOptions = normalizeCustomOptions(customOptions) -- 1563
				if not validateCustomOptions(customOptions) then -- 1564
					return { -- 1564
						success = false, -- 1564
						message = "customOptions must be a JSON object" -- 1564
					} -- 1564
				end -- 1564
				if supportsFunctionCalling == false then -- 1565
					supportsFunctionCalling = 0 -- 1565
				else -- 1565
					supportsFunctionCalling = 1 -- 1565
				end -- 1565
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1570
					tostring(name), -- 1570
					tostring(url), -- 1571
					tostring(model), -- 1572
					tostring(key), -- 1573
					contextWindow, -- 1574
					temperature, -- 1575
					maxTokens, -- 1576
					reasoningEffort, -- 1577
					customOptions, -- 1578
					supportsFunctionCalling, -- 1579
					now, -- 1580
					id -- 1581
				}) -- 1566
				return { -- 1583
					success = affected >= 0 -- 1583
				} -- 1583
			end -- 1554
		end -- 1554
	end -- 1554
	return invalidArguments -- 1552
end) -- 1552
HttpServer:post("/llm/delete", function(req) -- 1585
	ensureLLMConfigTable() -- 1586
	do -- 1587
		local _type_0 = type(req) -- 1587
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1587
		if _tab_0 then -- 1587
			local id -- 1587
			do -- 1587
				local _obj_0 = req.body -- 1587
				local _type_1 = type(_obj_0) -- 1587
				if "table" == _type_1 or "userdata" == _type_1 then -- 1587
					id = _obj_0.id -- 1587
				end -- 1587
			end -- 1587
			if id ~= nil then -- 1587
				id = tonumber(id) -- 1588
				if id == nil then -- 1589
					return invalidArguments -- 1589
				end -- 1589
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1590
					id -- 1590
				}) -- 1590
				return { -- 1591
					success = affected >= 0 -- 1591
				} -- 1591
			end -- 1587
		end -- 1587
	end -- 1587
	return invalidArguments -- 1585
end) -- 1585
HttpServer:post("/stat", function(req) -- 1593
	do -- 1594
		local _type_0 = type(req) -- 1594
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1594
		if _tab_0 then -- 1594
			local path -- 1594
			do -- 1594
				local _obj_0 = req.body -- 1594
				local _type_1 = type(_obj_0) -- 1594
				if "table" == _type_1 or "userdata" == _type_1 then -- 1594
					path = _obj_0.path -- 1594
				end -- 1594
			end -- 1594
			if path ~= nil then -- 1594
				if not Content:exist(path) then -- 1595
					return { -- 1596
						success = false, -- 1596
						message = "target not existed" -- 1596
					} -- 1596
				end -- 1595
				if Content:isdir(path) then -- 1597
					return { -- 1598
						success = false, -- 1598
						message = "failed to stat a directory" -- 1598
					} -- 1598
				end -- 1597
				local size, isBinary = Content:getAttr(path) -- 1599
				if size then -- 1599
					return { -- 1600
						success = true, -- 1600
						size = size, -- 1600
						isBinary = isBinary -- 1600
					} -- 1600
				end -- 1599
			end -- 1594
		end -- 1594
	end -- 1594
	return { -- 1593
		success = false, -- 1593
		message = "failed to stat" -- 1593
	} -- 1593
end) -- 1593
HttpServer:post("/new", function(req) -- 1602
	do -- 1603
		local _type_0 = type(req) -- 1603
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1603
		if _tab_0 then -- 1603
			local path -- 1603
			do -- 1603
				local _obj_0 = req.body -- 1603
				local _type_1 = type(_obj_0) -- 1603
				if "table" == _type_1 or "userdata" == _type_1 then -- 1603
					path = _obj_0.path -- 1603
				end -- 1603
			end -- 1603
			local content -- 1603
			do -- 1603
				local _obj_0 = req.body -- 1603
				local _type_1 = type(_obj_0) -- 1603
				if "table" == _type_1 or "userdata" == _type_1 then -- 1603
					content = _obj_0.content -- 1603
				end -- 1603
			end -- 1603
			local folder -- 1603
			do -- 1603
				local _obj_0 = req.body -- 1603
				local _type_1 = type(_obj_0) -- 1603
				if "table" == _type_1 or "userdata" == _type_1 then -- 1603
					folder = _obj_0.folder -- 1603
				end -- 1603
			end -- 1603
			if path ~= nil and content ~= nil and folder ~= nil then -- 1603
				if Content:exist(path) then -- 1604
					return { -- 1605
						success = false, -- 1605
						message = "TargetExisted" -- 1605
					} -- 1605
				end -- 1604
				local parent = Path:getPath(path) -- 1606
				local files = Content:getFiles(parent) -- 1607
				if folder then -- 1608
					local name = Path:getFilename(path):lower() -- 1609
					for _index_0 = 1, #files do -- 1610
						local file = files[_index_0] -- 1610
						if name == Path:getFilename(file):lower() then -- 1611
							return { -- 1612
								success = false, -- 1612
								message = "TargetExisted" -- 1612
							} -- 1612
						end -- 1611
					end -- 1610
					if Content:mkdir(path) then -- 1613
						return { -- 1614
							success = true -- 1614
						} -- 1614
					end -- 1613
				else -- 1616
					local name = Path:getName(path):lower() -- 1616
					for _index_0 = 1, #files do -- 1617
						local file = files[_index_0] -- 1617
						if name == Path:getName(file):lower() then -- 1618
							local ext = Path:getExt(file) -- 1619
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1620
								goto _continue_0 -- 1621
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1622
								goto _continue_0 -- 1623
							end -- 1620
							return { -- 1624
								success = false, -- 1624
								message = "SourceExisted" -- 1624
							} -- 1624
						end -- 1618
						::_continue_0:: -- 1618
					end -- 1617
					if Content:save(path, content) then -- 1625
						return { -- 1626
							success = true -- 1626
						} -- 1626
					end -- 1625
				end -- 1608
			end -- 1603
		end -- 1603
	end -- 1603
	return { -- 1602
		success = false, -- 1602
		message = "Failed" -- 1602
	} -- 1602
end) -- 1602
local deleteAsset -- 1628
deleteAsset = function(path) -- 1628
	if not Content:exist(path) then -- 1629
		return false -- 1629
	end -- 1629
	local projectRoot -- 1630
	if Content:isdir(path) and isProjectRootDir(path) then -- 1630
		projectRoot = path -- 1630
	else -- 1630
		projectRoot = nil -- 1630
	end -- 1630
	local parent = Path:getPath(path) -- 1631
	local files = Content:getFiles(parent) -- 1632
	local name = Path:getName(path):lower() -- 1633
	local ext = Path:getExt(path) -- 1634
	for _index_0 = 1, #files do -- 1635
		local file = files[_index_0] -- 1635
		if name == Path:getName(file):lower() then -- 1636
			local _exp_0 = Path:getExt(file) -- 1637
			if "tl" == _exp_0 then -- 1637
				if ("vs" == ext) then -- 1637
					Content:remove(Path(parent, file)) -- 1638
				end -- 1637
			elseif "lua" == _exp_0 then -- 1639
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1639
					Content:remove(Path(parent, file)) -- 1640
				end -- 1639
			end -- 1637
		end -- 1636
	end -- 1635
	if Content:remove(path) then -- 1641
		if projectRoot then -- 1642
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1643
		end -- 1642
		return true -- 1644
	end -- 1641
	return false -- 1645
end -- 1628
local moveAsset -- 1647
moveAsset = function(old, new) -- 1647
	if not (Content:exist(old) and not Content:exist(new)) then -- 1648
		return false -- 1648
	end -- 1648
	local renamedDir = Content:isdir(old) -- 1649
	local parent = Path:getPath(new) -- 1650
	local files = Content:getFiles(parent) -- 1651
	if renamedDir then -- 1652
		local name = Path:getFilename(new):lower() -- 1653
		for _index_0 = 1, #files do -- 1654
			local file = files[_index_0] -- 1654
			if name == Path:getFilename(file):lower() then -- 1655
				return false -- 1656
			end -- 1655
		end -- 1654
	else -- 1658
		local name = Path:getName(new):lower() -- 1658
		local ext = Path:getExt(new) -- 1659
		for _index_0 = 1, #files do -- 1660
			local file = files[_index_0] -- 1660
			if name == Path:getName(file):lower() then -- 1661
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1662
					goto _continue_0 -- 1663
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1664
					goto _continue_0 -- 1665
				end -- 1662
				return false -- 1666
			end -- 1661
			::_continue_0:: -- 1661
		end -- 1660
	end -- 1652
	if not Content:move(old, new) then -- 1667
		return false -- 1667
	end -- 1667
	if renamedDir then -- 1668
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1669
	end -- 1668
	local newParent = Path:getPath(new) -- 1670
	parent = Path:getPath(old) -- 1671
	files = Content:getFiles(parent) -- 1672
	local newName = Path:getName(new) -- 1673
	local oldName = Path:getName(old) -- 1674
	local name = oldName:lower() -- 1675
	local ext = Path:getExt(old) -- 1676
	for _index_0 = 1, #files do -- 1677
		local file = files[_index_0] -- 1677
		if name == Path:getName(file):lower() then -- 1678
			local _exp_0 = Path:getExt(file) -- 1679
			if "tl" == _exp_0 then -- 1679
				if ("vs" == ext) then -- 1679
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1680
				end -- 1679
			elseif "lua" == _exp_0 then -- 1681
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1681
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1682
				end -- 1681
			end -- 1679
		end -- 1678
	end -- 1677
	return true -- 1683
end -- 1647
HttpServer:post("/delete", function(req) -- 1685
	do -- 1686
		local _type_0 = type(req) -- 1686
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1686
		if _tab_0 then -- 1686
			local path -- 1686
			do -- 1686
				local _obj_0 = req.body -- 1686
				local _type_1 = type(_obj_0) -- 1686
				if "table" == _type_1 or "userdata" == _type_1 then -- 1686
					path = _obj_0.path -- 1686
				end -- 1686
			end -- 1686
			if path ~= nil then -- 1686
				if deleteAsset(path) then -- 1687
					return { -- 1687
						success = true -- 1687
					} -- 1687
				end -- 1687
			end -- 1686
		end -- 1686
	end -- 1686
	return { -- 1685
		success = false -- 1685
	} -- 1685
end) -- 1685
HttpServer:post("/rename", function(req) -- 1689
	do -- 1690
		local _type_0 = type(req) -- 1690
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1690
		if _tab_0 then -- 1690
			local old -- 1690
			do -- 1690
				local _obj_0 = req.body -- 1690
				local _type_1 = type(_obj_0) -- 1690
				if "table" == _type_1 or "userdata" == _type_1 then -- 1690
					old = _obj_0.old -- 1690
				end -- 1690
			end -- 1690
			local new -- 1690
			do -- 1690
				local _obj_0 = req.body -- 1690
				local _type_1 = type(_obj_0) -- 1690
				if "table" == _type_1 or "userdata" == _type_1 then -- 1690
					new = _obj_0.new -- 1690
				end -- 1690
			end -- 1690
			if old ~= nil and new ~= nil then -- 1690
				if moveAsset(old, new) then -- 1691
					return { -- 1691
						success = true -- 1691
					} -- 1691
				end -- 1691
			end -- 1690
		end -- 1690
	end -- 1690
	return { -- 1689
		success = false -- 1689
	} -- 1689
end) -- 1689
local normalizeAssetPaths -- 1693
normalizeAssetPaths = function(paths) -- 1693
	if not (type(paths) == "table") then -- 1694
		return nil -- 1694
	end -- 1694
	local unique = { } -- 1695
	local candidates = { } -- 1696
	for _index_0 = 1, #paths do -- 1697
		local path = paths[_index_0] -- 1697
		if not (type(path) == "string") then -- 1698
			return nil -- 1698
		end -- 1698
		local relative = relativeToRoot(path, Content.writablePath) -- 1699
		if relative == nil or relative == "" or not Content:exist(path) then -- 1700
			return nil -- 1700
		end -- 1700
		for part in relative:gmatch("[^/]+") do -- 1701
			if part == ".." then -- 1702
				return nil -- 1702
			end -- 1702
		end -- 1701
		if not unique[path] then -- 1703
			unique[path] = true -- 1704
			candidates[#candidates + 1] = path -- 1705
		end -- 1703
	end -- 1697
	table.sort(candidates, function(a, b) -- 1706
		return #a < #b -- 1706
	end) -- 1706
	local result = { } -- 1707
	for _index_0 = 1, #candidates do -- 1708
		local path = candidates[_index_0] -- 1708
		local contained = false -- 1709
		for _index_1 = 1, #result do -- 1710
			local parent = result[_index_1] -- 1710
			if relativeToRoot(path, parent) ~= nil then -- 1711
				contained = true -- 1712
				break -- 1713
			end -- 1711
		end -- 1710
		if not contained then -- 1714
			result[#result + 1] = path -- 1714
		end -- 1714
	end -- 1708
	return result -- 1715
end -- 1693
HttpServer:postSchedule("/assets/batch", function(req) -- 1717
	do -- 1718
		local _type_0 = type(req) -- 1718
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1718
		if _tab_0 then -- 1718
			local operation -- 1718
			do -- 1718
				local _obj_0 = req.body -- 1718
				local _type_1 = type(_obj_0) -- 1718
				if "table" == _type_1 or "userdata" == _type_1 then -- 1718
					operation = _obj_0.operation -- 1718
				end -- 1718
			end -- 1718
			local sources -- 1718
			do -- 1718
				local _obj_0 = req.body -- 1718
				local _type_1 = type(_obj_0) -- 1718
				if "table" == _type_1 or "userdata" == _type_1 then -- 1718
					sources = _obj_0.sources -- 1718
				end -- 1718
			end -- 1718
			if operation ~= nil and sources ~= nil then -- 1718
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1719
					return { -- 1719
						success = false, -- 1719
						message = "invalid operation" -- 1719
					} -- 1719
				end -- 1719
				sources = normalizeAssetPaths(sources) -- 1720
				if not (sources and #sources > 0) then -- 1721
					return { -- 1721
						success = false, -- 1721
						message = "invalid sources" -- 1721
					} -- 1721
				end -- 1721
				local target = req.body.target -- 1722
				local destinations = { } -- 1723
				if operation ~= "delete" then -- 1724
					if not (type(target) == "string") then -- 1725
						return { -- 1725
							success = false, -- 1725
							message = "invalid target" -- 1725
						} -- 1725
					end -- 1725
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1726
					if targetRelative == nil then -- 1727
						return { -- 1727
							success = false, -- 1727
							message = "invalid target" -- 1727
						} -- 1727
					end -- 1727
					if not (Content:exist(target) and Content:isdir(target)) then -- 1728
						return { -- 1728
							success = false, -- 1728
							message = "invalid target" -- 1728
						} -- 1728
					end -- 1728
					for _index_0 = 1, #sources do -- 1729
						local source = sources[_index_0] -- 1729
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1730
							return { -- 1731
								success = false, -- 1731
								message = "target inside source" -- 1731
							} -- 1731
						end -- 1730
						local destination = Path(target, Path:getFilename(source)) -- 1732
						if Content:exist(destination) then -- 1733
							return { -- 1733
								success = false, -- 1733
								message = "target existed" -- 1733
							} -- 1733
						end -- 1733
						if destinations[destination] then -- 1734
							return { -- 1734
								success = false, -- 1734
								message = "duplicate target" -- 1734
							} -- 1734
						end -- 1734
						destinations[destination] = true -- 1735
					end -- 1729
				end -- 1724
				local changes = { } -- 1736
				local affectedSet = { } -- 1737
				local affectedDirectories = { } -- 1738
				local addAffected -- 1739
				addAffected = function(dir) -- 1739
					if affectedSet[dir] then -- 1740
						return -- 1740
					end -- 1740
					affectedSet[dir] = true -- 1741
					affectedDirectories[#affectedDirectories + 1] = dir -- 1742
				end -- 1739
				if operation ~= "delete" then -- 1743
					addAffected(target) -- 1743
				end -- 1743
				for _index_0 = 1, #sources do -- 1744
					local source = sources[_index_0] -- 1744
					addAffected(Path:getPath(source)) -- 1745
					if operation == "delete" then -- 1746
						if not deleteAsset(source) then -- 1747
							return { -- 1747
								success = false, -- 1747
								message = "delete failed", -- 1747
								changes = changes, -- 1747
								affectedDirectories = affectedDirectories -- 1747
							} -- 1747
						end -- 1747
						changes[#changes + 1] = { -- 1748
							old = source -- 1748
						} -- 1748
					else -- 1750
						local destination = Path(target, Path:getFilename(source)) -- 1750
						local ok -- 1751
						if operation == "copy" then -- 1751
							ok = Content:copyAsync(source, destination) -- 1752
						else -- 1754
							ok = moveAsset(source, destination) -- 1754
						end -- 1751
						if not ok then -- 1755
							return { -- 1755
								success = false, -- 1755
								message = operation .. " failed", -- 1755
								changes = changes, -- 1755
								affectedDirectories = affectedDirectories -- 1755
							} -- 1755
						end -- 1755
						changes[#changes + 1] = { -- 1756
							old = source, -- 1756
							new = destination -- 1756
						} -- 1756
					end -- 1746
				end -- 1744
				return { -- 1757
					success = true, -- 1757
					changes = changes, -- 1757
					affectedDirectories = affectedDirectories -- 1757
				} -- 1757
			end -- 1718
		end -- 1718
	end -- 1718
	return { -- 1717
		success = false, -- 1717
		message = "invalid request" -- 1717
	} -- 1717
end) -- 1717
local withProjectSearchPaths -- 1759
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1759
	local fallbackPaths = { } -- 1760
	local addFallback -- 1761
	addFallback = function(dir) -- 1761
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1761
			fallbackPaths[#fallbackPaths + 1] = dir -- 1761
		end -- 1761
	end -- 1761
	if projectRoot and projectRoot ~= "" then -- 1762
		addFallback(Path(projectRoot, "Script")) -- 1763
		addFallback(projectRoot) -- 1764
	end -- 1762
	if projFile then -- 1765
		local projDir = getProjectDirFromFile(projFile) -- 1766
		if projDir then -- 1766
			addFallback(Path(projDir, "Script")) -- 1767
			addFallback(projDir) -- 1768
		else -- 1770
			addFallback(Path:getPath(projFile)) -- 1770
		end -- 1766
	end -- 1765
	if not (#fallbackPaths > 0) then -- 1771
		return fn() -- 1771
	end -- 1771
	local searchPaths = Content.searchPaths -- 1772
	for _index_0 = 1, #fallbackPaths do -- 1773
		local dir = fallbackPaths[_index_0] -- 1773
		Content:addSearchPath(dir) -- 1773
	end -- 1773
	local _ <close> = setmetatable({ }, { -- 1774
		__close = function() -- 1774
			Content.searchPaths = searchPaths -- 1774
		end -- 1774
	}) -- 1774
	return fn() -- 1775
end -- 1759
HttpServer:post("/exist", function(req) -- 1776
	do -- 1777
		local _type_0 = type(req) -- 1777
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1777
		if _tab_0 then -- 1777
			local file -- 1777
			do -- 1777
				local _obj_0 = req.body -- 1777
				local _type_1 = type(_obj_0) -- 1777
				if "table" == _type_1 or "userdata" == _type_1 then -- 1777
					file = _obj_0.file -- 1777
				end -- 1777
			end -- 1777
			if file ~= nil then -- 1777
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1778
					return { -- 1779
						success = Content:exist(file) -- 1779
					} -- 1779
				end) -- 1778
			end -- 1777
		end -- 1777
	end -- 1777
	return { -- 1776
		success = false -- 1776
	} -- 1776
end) -- 1776
HttpServer:postSchedule("/read", function(req) -- 1780
	do -- 1781
		local _type_0 = type(req) -- 1781
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1781
		if _tab_0 then -- 1781
			local path -- 1781
			do -- 1781
				local _obj_0 = req.body -- 1781
				local _type_1 = type(_obj_0) -- 1781
				if "table" == _type_1 or "userdata" == _type_1 then -- 1781
					path = _obj_0.path -- 1781
				end -- 1781
			end -- 1781
			if path ~= nil then -- 1781
				local readFile -- 1782
				readFile = function() -- 1782
					if Content:exist(path) then -- 1783
						local content = Content:loadAsync(path) -- 1784
						if content then -- 1784
							return { -- 1785
								content = content, -- 1785
								success = true, -- 1785
								fullPath = Content:getFullPath(path) -- 1785
							} -- 1785
						end -- 1784
					end -- 1783
					return nil -- 1782
				end -- 1782
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1786
				if result then -- 1786
					return result -- 1786
				end -- 1786
			end -- 1781
		end -- 1781
	end -- 1781
	return { -- 1780
		success = false -- 1780
	} -- 1780
end) -- 1780
local agentDocLanguage -- 1788
agentDocLanguage = function(language) -- 1788
	if language == "zh-Hans" then -- 1789
		return "zh" -- 1789
	else -- 1789
		return "en" -- 1789
	end -- 1789
end -- 1788
HttpServer:postSchedule("/doc/search", function(req) -- 1791
	local body = req.body or { } -- 1792
	local language = body.docLanguage -- 1793
	if not (("en" == language or "zh-Hans" == language)) then -- 1794
		return { -- 1794
			success = false, -- 1794
			message = "unsupported doc language" -- 1794
		} -- 1794
	end -- 1794
	local source = body.docSource -- 1795
	if not (("api" == source or "tutorial" == source)) then -- 1796
		return { -- 1796
			success = false, -- 1796
			message = "unsupported doc source" -- 1796
		} -- 1796
	end -- 1796
	local codeLanguage = body.programmingLanguage -- 1797
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1798
		return { -- 1798
			success = false, -- 1798
			message = "unsupported programming language" -- 1798
		} -- 1798
	end -- 1798
	if not body.pattern then -- 1799
		return { -- 1799
			success = false, -- 1799
			message = "missing pattern" -- 1799
		} -- 1799
	end -- 1799
	local result = nil -- 1800
	AgentTools.searchDoraAPIHttp({ -- 1802
		pattern = body.pattern, -- 1802
		docLanguage = agentDocLanguage(language), -- 1803
		docSource = source, -- 1804
		programmingLanguage = codeLanguage, -- 1805
		limit = body.limit, -- 1806
		useRegex = body.useRegex, -- 1807
		caseSensitive = body.caseSensitive, -- 1808
		includeContent = body.includeContent, -- 1809
		contentWindow = body.contentWindow -- 1810
	}, function(res) -- 1811
		result = res -- 1812
	end) -- 1801
	wait(function() -- 1813
		return result ~= nil -- 1813
	end) -- 1813
	if result and result.success then -- 1814
		result.docLanguage = language -- 1815
	end -- 1814
	if result then -- 1816
		return result -- 1817
	else -- 1819
		return { -- 1819
			success = false, -- 1819
			message = "doc search failed" -- 1819
		} -- 1819
	end -- 1816
	return { -- 1791
		success = false, -- 1791
		message = "invalid call" -- 1791
	} -- 1791
end) -- 1791
HttpServer:postSchedule("/doc/read", function(req) -- 1821
	local body = req.body or { } -- 1822
	local language = body.docLanguage -- 1823
	if not (("en" == language or "zh-Hans" == language)) then -- 1824
		return { -- 1824
			success = false, -- 1824
			message = "unsupported doc language" -- 1824
		} -- 1824
	end -- 1824
	if not body.file then -- 1825
		return { -- 1825
			success = false, -- 1825
			message = "missing file" -- 1825
		} -- 1825
	end -- 1825
	local result = AgentTools.readDoraDoc({ -- 1827
		docLanguage = agentDocLanguage(language), -- 1827
		file = body.file, -- 1828
		startLine = body.startLine, -- 1829
		endLine = body.endLine -- 1830
	}) -- 1826
	if result and result.success then -- 1831
		result.docLanguage = language -- 1832
	end -- 1831
	return result -- 1833
end) -- 1821
HttpServer:get("/read-sync", function(req) -- 1835
	do -- 1836
		local _type_0 = type(req) -- 1836
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1836
		if _tab_0 then -- 1836
			local params = req.params -- 1836
			if params ~= nil then -- 1836
				local path = params.path -- 1837
				local exts -- 1838
				if params.exts then -- 1838
					local _accum_0 = { } -- 1839
					local _len_0 = 1 -- 1839
					for ext in params.exts:gmatch("[^|]*") do -- 1839
						_accum_0[_len_0] = ext -- 1839
						_len_0 = _len_0 + 1 -- 1839
					end -- 1839
					exts = _accum_0 -- 1839
				else -- 1840
					exts = { -- 1840
						"" -- 1840
					} -- 1840
				end -- 1838
				local readFileAt -- 1841
				readFileAt = function(targetPath) -- 1841
					if Content:exist(targetPath) then -- 1842
						local content = Content:load(targetPath) -- 1843
						if content then -- 1843
							return { -- 1844
								content = content, -- 1844
								success = true, -- 1844
								fullPath = Content:getFullPath(targetPath) -- 1844
							} -- 1844
						end -- 1843
					end -- 1842
					return nil -- 1841
				end -- 1841
				local readFile -- 1845
				readFile = function(fallbackPaths) -- 1845
					for _index_0 = 1, #exts do -- 1846
						local ext = exts[_index_0] -- 1846
						local targetPath = path .. ext -- 1847
						if not Content:isAbsolutePath(targetPath) then -- 1848
							for _index_1 = 1, #fallbackPaths do -- 1849
								local fallback = fallbackPaths[_index_1] -- 1849
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1850
								if fallbackResult then -- 1850
									return fallbackResult -- 1851
								end -- 1850
							end -- 1849
						end -- 1848
						local fileResult = readFileAt(targetPath) -- 1852
						if fileResult then -- 1852
							return fileResult -- 1853
						end -- 1852
					end -- 1846
					return nil -- 1845
				end -- 1845
				local fallbackPaths = { } -- 1854
				local fallbackCandidates = { } -- 1855
				do -- 1856
					local projectRoot = req.params.projectRoot -- 1856
					if projectRoot then -- 1856
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1857
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1858
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1859
						end -- 1857
					end -- 1856
				end -- 1856
				do -- 1860
					local projFile = req.params.projFile -- 1860
					if projFile then -- 1860
						local projDir = getProjectDirFromFile(projFile) -- 1861
						if projDir then -- 1861
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1862
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1863
						else -- 1865
							projDir = Path:getPath(projFile) -- 1865
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1866
						end -- 1861
					end -- 1860
				end -- 1860
				for _index_0 = 1, #fallbackCandidates do -- 1867
					local dir = fallbackCandidates[_index_0] -- 1867
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1868
						local exists = false -- 1869
						for _index_1 = 1, #fallbackPaths do -- 1870
							local fallback = fallbackPaths[_index_1] -- 1870
							if fallback == dir then -- 1871
								exists = true -- 1872
								break -- 1873
							end -- 1871
						end -- 1870
						if not exists then -- 1874
							fallbackPaths[#fallbackPaths + 1] = dir -- 1874
						end -- 1874
					end -- 1868
				end -- 1867
				local readResult = readFile(fallbackPaths) -- 1875
				if readResult then -- 1875
					return readResult -- 1876
				end -- 1875
			end -- 1836
		end -- 1836
	end -- 1836
	return { -- 1835
		success = false -- 1835
	} -- 1835
end) -- 1835
local compileFileAsync -- 1878
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1878
	if projectRoot == nil then -- 1878
		projectRoot = nil -- 1878
	end -- 1878
	local file = inputFile -- 1879
	local searchPath -- 1880
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1880
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1881
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1885
	elseif not Content:isAbsolutePath(inputFile) then -- 1886
		searchPath = "" -- 1887
	else -- 1888
		local dir = getProjectDirFromFile(inputFile) -- 1888
		if dir then -- 1888
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1889
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1893
		else -- 1895
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1895
			searchPath = "" -- 1898
		end -- 1888
	end -- 1880
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1899
	local yueext = yue.options.extension -- 1900
	local resultCodes = nil -- 1901
	local resultError = nil -- 1902
	do -- 1903
		local _exp_0 = Path:getExt(inputFile) -- 1903
		if yueext == _exp_0 then -- 1903
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1904
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1905
				if not codes then -- 1906
					resultError = err -- 1907
					return -- 1908
				end -- 1906
				local extraGlobal -- 1909
				if isTIC80 then -- 1909
					extraGlobal = tic80APIs -- 1909
				else -- 1909
					extraGlobal = nil -- 1909
				end -- 1909
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1910
				if not success then -- 1911
					resultError = message -- 1912
					return -- 1913
				end -- 1911
				if codes == "" then -- 1914
					resultCodes = "" -- 1915
					return nil -- 1916
				end -- 1914
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1917
				return resultCodes -- 1918
			end, function(success) -- 1905
				if not success then -- 1919
					Content:remove(outputFile) -- 1920
					if resultCodes == nil then -- 1921
						resultCodes = false -- 1922
					end -- 1921
				end -- 1919
			end) -- 1905
		elseif "tl" == _exp_0 then -- 1923
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1924
			if isTIC80 then -- 1925
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1926
			end -- 1925
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1927
			if codes then -- 1927
				if isTIC80 then -- 1928
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1929
				end -- 1928
				resultCodes = codes -- 1930
				Content:saveAsync(outputFile, codes) -- 1931
			else -- 1933
				Content:remove(outputFile) -- 1933
				resultCodes = false -- 1934
				resultError = err -- 1935
			end -- 1927
		elseif "xml" == _exp_0 then -- 1936
			local codes, err = xml.tolua(sourceCodes) -- 1937
			if codes then -- 1937
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1938
				Content:saveAsync(outputFile, resultCodes) -- 1939
			else -- 1941
				Content:remove(outputFile) -- 1941
				resultCodes = false -- 1942
				resultError = err -- 1943
			end -- 1937
		end -- 1903
	end -- 1903
	wait(function() -- 1944
		return resultCodes ~= nil -- 1944
	end) -- 1944
	if resultCodes then -- 1945
		return resultCodes -- 1946
	else -- 1948
		return nil, resultError -- 1948
	end -- 1945
	return nil -- 1878
end -- 1878
HttpServer:postSchedule("/write", function(req) -- 1950
	do -- 1951
		local _type_0 = type(req) -- 1951
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1951
		if _tab_0 then -- 1951
			local path -- 1951
			do -- 1951
				local _obj_0 = req.body -- 1951
				local _type_1 = type(_obj_0) -- 1951
				if "table" == _type_1 or "userdata" == _type_1 then -- 1951
					path = _obj_0.path -- 1951
				end -- 1951
			end -- 1951
			local content -- 1951
			do -- 1951
				local _obj_0 = req.body -- 1951
				local _type_1 = type(_obj_0) -- 1951
				if "table" == _type_1 or "userdata" == _type_1 then -- 1951
					content = _obj_0.content -- 1951
				end -- 1951
			end -- 1951
			if path ~= nil and content ~= nil then -- 1951
				if Content:saveAsync(path, content) then -- 1952
					do -- 1953
						local _exp_0 = Path:getExt(path) -- 1953
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1953
							if '' == Path:getExt(Path:getName(path)) then -- 1954
								local resultCodes = compileFileAsync(path, content) -- 1955
								return { -- 1956
									success = true, -- 1956
									resultCodes = resultCodes -- 1956
								} -- 1956
							end -- 1954
						end -- 1953
					end -- 1953
					return { -- 1957
						success = true -- 1957
					} -- 1957
				end -- 1952
			end -- 1951
		end -- 1951
	end -- 1951
	return { -- 1950
		success = false -- 1950
	} -- 1950
end) -- 1950
local getWaProjectDirFromFile = nil -- 1959
HttpServer:postSchedule("/build", function(req) -- 1961
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
			if path ~= nil then -- 1962
				local projectRoot = req.body.projectRoot -- 1963
				if Content:isdir(path) then -- 1964
					local projDir = getWaProjectDirFromFile(path) -- 1965
					if projDir then -- 1965
						local message = Wasm:buildWaAsync(projDir) -- 1966
						if message == "" then -- 1967
							return { -- 1968
								success = true -- 1968
							} -- 1968
						else -- 1970
							return { -- 1970
								success = false, -- 1970
								message = message -- 1970
							} -- 1970
						end -- 1967
					end -- 1965
				end -- 1964
				local _exp_0 = Path:getExt(path) -- 1971
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1972
					if '' == Path:getExt(Path:getName(path)) then -- 1973
						local content = Content:loadAsync(path) -- 1974
						if content then -- 1974
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 1975
							if resultCodes then -- 1975
								return { -- 1976
									success = true, -- 1976
									resultCodes = resultCodes -- 1976
								} -- 1976
							end -- 1975
						end -- 1974
					end -- 1973
				elseif "wa" == _exp_0 then -- 1977
					local projDir = getWaProjectDirFromFile(path) -- 1978
					if projDir then -- 1978
						local message = Wasm:buildWaAsync(projDir) -- 1979
						if message == "" then -- 1980
							return { -- 1981
								success = true -- 1981
							} -- 1981
						else -- 1983
							return { -- 1983
								success = false, -- 1983
								message = message -- 1983
							} -- 1983
						end -- 1980
					else -- 1985
						return { -- 1985
							success = false, -- 1985
							message = 'Wa file needs a project' -- 1985
						} -- 1985
					end -- 1978
				end -- 1971
			end -- 1962
		end -- 1962
	end -- 1962
	return { -- 1961
		success = false -- 1961
	} -- 1961
end) -- 1961
local extentionLevels = { -- 1988
	vs = 2, -- 1988
	bl = 2, -- 1989
	ts = 1, -- 1990
	tsx = 1, -- 1991
	tl = 1, -- 1992
	yue = 1, -- 1993
	xml = 1, -- 1994
	lua = 0 -- 1995
} -- 1987
local visitAssets -- 1997
visitAssets = function(path, workspace, builtin, recursive) -- 1997
	if recursive == nil then -- 1997
		recursive = true -- 1997
	end -- 1997
	local children = nil -- 1998
	local dirs = Content:getDirs(path) -- 1999
	for _index_0 = 1, #dirs do -- 2000
		local dir = dirs[_index_0] -- 2000
		if workspace then -- 2001
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 2002
				goto _continue_0 -- 2003
			end -- 2002
		elseif dir == ".git" then -- 2004
			goto _continue_0 -- 2005
		end -- 2001
		if not children then -- 2006
			children = { } -- 2006
		end -- 2006
		local dirPath = Path(path, dir) -- 2007
		if recursive then -- 2008
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2009
		else -- 2011
			children[#children + 1] = { -- 2012
				key = dirPath, -- 2012
				dir = true, -- 2013
				title = dir, -- 2014
				builtin = builtin, -- 2015
				isLeaf = false -- 2016
			} -- 2011
		end -- 2008
		::_continue_0:: -- 2001
	end -- 2000
	local files = Content:getFiles(path) -- 2018
	local names = { } -- 2019
	for _index_0 = 1, #files do -- 2020
		local file = files[_index_0] -- 2020
		if (".DS_Store" == file) then -- 2021
			goto _continue_1 -- 2022
		end -- 2021
		local name = Path:getName(file) -- 2023
		local ext = names[name] -- 2024
		if ext then -- 2024
			local lv1 -- 2025
			do -- 2025
				local _exp_0 = extentionLevels[ext] -- 2025
				if _exp_0 ~= nil then -- 2025
					lv1 = _exp_0 -- 2025
				else -- 2025
					lv1 = -1 -- 2025
				end -- 2025
			end -- 2025
			ext = Path:getExt(file) -- 2026
			local lv2 -- 2027
			do -- 2027
				local _exp_0 = extentionLevels[ext] -- 2027
				if _exp_0 ~= nil then -- 2027
					lv2 = _exp_0 -- 2027
				else -- 2027
					lv2 = -1 -- 2027
				end -- 2027
			end -- 2027
			if lv2 > lv1 then -- 2028
				names[name] = ext -- 2029
			elseif lv2 == lv1 then -- 2030
				names[name .. '.' .. ext] = "" -- 2031
			end -- 2028
		else -- 2033
			ext = Path:getExt(file) -- 2033
			if not extentionLevels[ext] then -- 2034
				names[file] = "" -- 2035
			else -- 2037
				names[name] = ext -- 2037
			end -- 2034
		end -- 2024
		::_continue_1:: -- 2021
	end -- 2020
	do -- 2038
		local _accum_0 = { } -- 2038
		local _len_0 = 1 -- 2038
		for name, ext in pairs(names) do -- 2038
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2038
			_len_0 = _len_0 + 1 -- 2038
		end -- 2038
		files = _accum_0 -- 2038
	end -- 2038
	for _index_0 = 1, #files do -- 2039
		local file = files[_index_0] -- 2039
		if not children then -- 2040
			children = { } -- 2040
		end -- 2040
		children[#children + 1] = { -- 2042
			key = Path(path, file), -- 2042
			dir = false, -- 2043
			title = file, -- 2044
			builtin = builtin -- 2045
		} -- 2041
	end -- 2039
	if children then -- 2047
		table.sort(children, function(a, b) -- 2048
			if a.dir == b.dir then -- 2049
				return a.title < b.title -- 2050
			else -- 2052
				return a.dir -- 2052
			end -- 2049
		end) -- 2048
	end -- 2047
	return { -- 2054
		key = path, -- 2054
		dir = true, -- 2055
		title = Path:getFilename(path), -- 2056
		builtin = builtin, -- 2057
		isLeaf = not children, -- 2058
		children = children -- 2059
	} -- 2053
end -- 1997
HttpServer:post("/assets/children", function(req) -- 2062
	do -- 2063
		local _type_0 = type(req) -- 2063
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2063
		if _tab_0 then -- 2063
			local path -- 2063
			do -- 2063
				local _obj_0 = req.body -- 2063
				local _type_1 = type(_obj_0) -- 2063
				if "table" == _type_1 or "userdata" == _type_1 then -- 2063
					path = _obj_0.path -- 2063
				end -- 2063
			end -- 2063
			if path ~= nil then -- 2063
				if not (relativeToRoot(path, Content.writablePath) ~= nil) then -- 2064
					return { -- 2064
						success = false -- 2064
					} -- 2064
				end -- 2064
				if not (Content:exist(path) and Content:isdir(path)) then -- 2065
					return { -- 2065
						success = false -- 2065
					} -- 2065
				end -- 2065
				local node = visitAssets(path, true, nil, false) -- 2066
				return { -- 2067
					success = true, -- 2067
					children = node.children or { } -- 2067
				} -- 2067
			end -- 2063
		end -- 2063
	end -- 2063
	return { -- 2062
		success = false -- 2062
	} -- 2062
end) -- 2062
HttpServer:post("/assets/files", function(req) -- 2069
	do -- 2070
		local _type_0 = type(req) -- 2070
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2070
		if _tab_0 then -- 2070
			local path -- 2070
			do -- 2070
				local _obj_0 = req.body -- 2070
				local _type_1 = type(_obj_0) -- 2070
				if "table" == _type_1 or "userdata" == _type_1 then -- 2070
					path = _obj_0.path -- 2070
				end -- 2070
			end -- 2070
			if path ~= nil then -- 2070
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2071
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2072
				if not (workspace or builtin) then -- 2073
					return { -- 2073
						success = false -- 2073
					} -- 2073
				end -- 2073
				if not (Content:exist(path) and Content:isdir(path)) then -- 2074
					return { -- 2074
						success = false -- 2074
					} -- 2074
				end -- 2074
				local globs = { -- 2075
					"**", -- 2075
					"!**/.DS_Store" -- 2075
				} -- 2075
				if workspace then -- 2076
					globs = { -- 2078
						"**", -- 2078
						"!**/.DS_Store", -- 2078
						"!**/.upload/**", -- 2079
						"!**/.download/**", -- 2079
						"!**/.www/**", -- 2080
						"!**/.build/**", -- 2080
						"!**/.git/**", -- 2081
						"!**/.cache/**", -- 2081
						"!**/node_modules/**" -- 2082
					} -- 2077
				end -- 2076
				local files -- 2084
				do -- 2084
					local _accum_0 = { } -- 2084
					local _len_0 = 1 -- 2084
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2084
					for _index_0 = 1, #_list_0 do -- 2084
						local file = _list_0[_index_0] -- 2084
						_accum_0[_len_0] = Path(path, file) -- 2084
						_len_0 = _len_0 + 1 -- 2084
					end -- 2084
					files = _accum_0 -- 2084
				end -- 2084
				return { -- 2085
					success = true, -- 2085
					files = files -- 2085
				} -- 2085
			end -- 2070
		end -- 2070
	end -- 2070
	return { -- 2069
		success = false -- 2069
	} -- 2069
end) -- 2069
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2126
	local _tab_0 = { -- 2126
		{ -- 2127
			key = Path(Content.assetPath), -- 2127
			dir = true, -- 2128
			builtin = true, -- 2129
			title = zh and "内置资源" or "Built-in", -- 2130
			children = builtinChildren -- 2131
		} -- 2126
	} -- 2133
	local _obj_0 = workspace.children or { } -- 2133
	local _idx_0 = #_tab_0 + 1 -- 2133
	for _index_0 = 1, #_obj_0 do -- 2133
		local _value_0 = _obj_0[_index_0] -- 2133
		_tab_0[_idx_0] = _value_0 -- 2133
		_idx_0 = _idx_0 + 1 -- 2133
	end -- 2133
	return _tab_0 -- 2126
end -- 2126
HttpServer:post("/assets", function() -- 2087
	local Entry = require("Script.Dev.Entry") -- 2088
	local engineDev = Entry.getEngineDev() -- 2089
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2090
	local zh = (App.locale:match("^zh") ~= nil) -- 2091
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2092
	readme.title = zh and "说明文档" or "Readme" -- 2093
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2094
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2095
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2096
	tools.title = zh and "开发工具" or "Tools" -- 2097
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2098
	font.title = zh and "字体" or "Font" -- 2099
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2100
	lib.title = zh and "程序库" or "Lib" -- 2101
	if engineDev then -- 2102
		local _list_0 = lib.children -- 2103
		for _index_0 = 1, #_list_0 do -- 2103
			local child = _list_0[_index_0] -- 2103
			if not (child.title == "Dora") then -- 2104
				goto _continue_0 -- 2104
			end -- 2104
			local title = zh and "zh-Hans" or "en" -- 2105
			do -- 2106
				local _accum_0 = { } -- 2106
				local _len_0 = 1 -- 2106
				local _list_1 = child.children -- 2106
				for _index_1 = 1, #_list_1 do -- 2106
					local c = _list_1[_index_1] -- 2106
					if c.title ~= title then -- 2106
						_accum_0[_len_0] = c -- 2106
						_len_0 = _len_0 + 1 -- 2106
					end -- 2106
				end -- 2106
				child.children = _accum_0 -- 2106
			end -- 2106
			break -- 2107
			::_continue_0:: -- 2104
		end -- 2103
	else -- 2109
		local _accum_0 = { } -- 2109
		local _len_0 = 1 -- 2109
		local _list_0 = lib.children -- 2109
		for _index_0 = 1, #_list_0 do -- 2109
			local child = _list_0[_index_0] -- 2109
			if child.title ~= "Dora" then -- 2109
				_accum_0[_len_0] = child -- 2109
				_len_0 = _len_0 + 1 -- 2109
			end -- 2109
		end -- 2109
		lib.children = _accum_0 -- 2109
	end -- 2102
	local builtinChildren = { -- 2110
		readme, -- 2110
		apiDoc, -- 2110
		tools, -- 2110
		font, -- 2110
		lib -- 2110
	} -- 2110
	if engineDev then -- 2111
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2112
		do -- 2113
			local _obj_0 = dev.children -- 2113
			_obj_0[#_obj_0 + 1] = { -- 2114
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2114
				dir = false, -- 2115
				builtin = true, -- 2116
				title = "init.yue" -- 2117
			} -- 2113
		end -- 2113
		builtinChildren[#builtinChildren + 1] = dev -- 2119
	end -- 2111
	return { -- 2121
		key = Content.writablePath, -- 2121
		dir = true, -- 2122
		root = true, -- 2123
		title = "Assets", -- 2124
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2125
	} -- 2120
end) -- 2087
HttpServer:post("/entry/list", function() -- 2137
	local Entry = require("Script.Dev.Entry") -- 2138
	local res = Entry.getLaunchEntries() -- 2139
	res.success = true -- 2140
	return res -- 2141
end) -- 2137
HttpServer:post("/run/status", function() -- 2143
	local Entry = require("Script.Dev.Entry") -- 2144
	return Entry.getCurrentEntryStatus() -- 2145
end) -- 2143
HttpServer:postSchedule("/run", function(req) -- 2147
	do -- 2148
		local _type_0 = type(req) -- 2148
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2148
		if _tab_0 then -- 2148
			local file -- 2148
			do -- 2148
				local _obj_0 = req.body -- 2148
				local _type_1 = type(_obj_0) -- 2148
				if "table" == _type_1 or "userdata" == _type_1 then -- 2148
					file = _obj_0.file -- 2148
				end -- 2148
			end -- 2148
			local asProj -- 2148
			do -- 2148
				local _obj_0 = req.body -- 2148
				local _type_1 = type(_obj_0) -- 2148
				if "table" == _type_1 or "userdata" == _type_1 then -- 2148
					asProj = _obj_0.asProj -- 2148
				end -- 2148
			end -- 2148
			if file ~= nil and asProj ~= nil then -- 2148
				if not Content:isAbsolutePath(file) then -- 2149
					local devFile = Path(Content.writablePath, file) -- 2150
					if Content:exist(devFile) then -- 2151
						file = devFile -- 2151
					end -- 2151
				end -- 2149
				local Entry = require("Script.Dev.Entry") -- 2152
				local workDir -- 2153
				if asProj then -- 2154
					local projectRoot = req.body.projectRoot -- 2155
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2156
						workDir = projectRoot -- 2157
					else -- 2159
						workDir = getProjectDirFromFile(file) -- 2159
					end -- 2156
					if workDir then -- 2160
						Entry.allClear() -- 2161
						local target = Path(workDir, "init") -- 2162
						local success, err = Entry.enterEntryAsync({ -- 2163
							entryName = "Project", -- 2163
							fileName = target, -- 2163
							workDir = workDir, -- 2163
							projectRoot = workDir, -- 2163
							runKind = "project" -- 2163
						}) -- 2163
						target = Path:getName(Path:getPath(target)) -- 2164
						return { -- 2165
							success = success, -- 2165
							target = target, -- 2165
							err = err -- 2165
						} -- 2165
					end -- 2160
				else -- 2167
					workDir = getProjectDirFromFile(file) -- 2167
					if not workDir and Path:getExt(file) == "wasm" then -- 2168
						local parent = Path:getPath(file) -- 2169
						if Content:exist(Path(parent, "wa.mod")) then -- 2170
							workDir = parent -- 2171
						end -- 2170
					end -- 2168
				end -- 2154
				Entry.allClear() -- 2172
				file = Path:replaceExt(file, "") -- 2173
				local entry = { -- 2175
					entryName = Path:getName(file), -- 2175
					fileName = file, -- 2176
					runKind = "file" -- 2177
				} -- 2174
				if workDir then -- 2178
					entry.workDir = workDir -- 2179
					entry.projectRoot = workDir -- 2180
				end -- 2178
				local success, err = Entry.enterEntryAsync(entry) -- 2181
				return { -- 2182
					success = success, -- 2182
					err = err -- 2182
				} -- 2182
			end -- 2148
		end -- 2148
	end -- 2148
	return { -- 2147
		success = false -- 2147
	} -- 2147
end) -- 2147
HttpServer:postSchedule("/stop", function() -- 2184
	local Entry = require("Script.Dev.Entry") -- 2185
	return { -- 2186
		success = Entry.stop() -- 2186
	} -- 2186
end) -- 2184
local minifyAsync -- 2188
minifyAsync = function(sourcePath, minifyPath) -- 2188
	if not Content:exist(sourcePath) then -- 2189
		return -- 2189
	end -- 2189
	local Entry = require("Script.Dev.Entry") -- 2190
	local errors = { } -- 2191
	local files = Entry.getAllFiles(sourcePath, { -- 2192
		"lua" -- 2192
	}, true) -- 2192
	do -- 2193
		local _accum_0 = { } -- 2193
		local _len_0 = 1 -- 2193
		for _index_0 = 1, #files do -- 2193
			local file = files[_index_0] -- 2193
			if file:sub(1, 1) ~= '.' then -- 2193
				_accum_0[_len_0] = file -- 2193
				_len_0 = _len_0 + 1 -- 2193
			end -- 2193
		end -- 2193
		files = _accum_0 -- 2193
	end -- 2193
	local paths -- 2194
	do -- 2194
		local _tbl_0 = { } -- 2194
		for _index_0 = 1, #files do -- 2194
			local file = files[_index_0] -- 2194
			_tbl_0[Path:getPath(file)] = true -- 2194
		end -- 2194
		paths = _tbl_0 -- 2194
	end -- 2194
	for path in pairs(paths) do -- 2195
		Content:mkdir(Path(minifyPath, path)) -- 2195
	end -- 2195
	local _ <close> = setmetatable({ }, { -- 2196
		__close = function() -- 2196
			package.loaded["luaminify.FormatMini"] = nil -- 2197
			package.loaded["luaminify.ParseLua"] = nil -- 2198
			package.loaded["luaminify.Scope"] = nil -- 2199
			package.loaded["luaminify.Util"] = nil -- 2200
		end -- 2196
	}) -- 2196
	local FormatMini -- 2201
	do -- 2201
		local _obj_0 = require("luaminify") -- 2201
		FormatMini = _obj_0.FormatMini -- 2201
	end -- 2201
	local fileCount = #files -- 2202
	local count = 0 -- 2203
	for _index_0 = 1, #files do -- 2204
		local file = files[_index_0] -- 2204
		thread(function() -- 2205
			local _ <close> = setmetatable({ }, { -- 2206
				__close = function() -- 2206
					count = count + 1 -- 2206
				end -- 2206
			}) -- 2206
			local input = Path(sourcePath, file) -- 2207
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2208
			if Content:exist(input) then -- 2209
				local sourceCodes = Content:loadAsync(input) -- 2210
				local res, err = FormatMini(sourceCodes) -- 2211
				if res then -- 2212
					Content:saveAsync(output, res) -- 2213
					return print("Minify " .. tostring(file)) -- 2214
				else -- 2216
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2216
				end -- 2212
			else -- 2218
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2218
			end -- 2209
		end) -- 2205
		sleep() -- 2219
	end -- 2204
	wait(function() -- 2220
		return count == fileCount -- 2220
	end) -- 2220
	if #errors > 0 then -- 2221
		print(table.concat(errors, '\n')) -- 2222
	end -- 2221
	print("Obfuscation done.") -- 2223
	return files -- 2224
end -- 2188
local zipping = false -- 2226
HttpServer:postSchedule("/zip", function(req) -- 2228
	do -- 2229
		local _type_0 = type(req) -- 2229
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2229
		if _tab_0 then -- 2229
			local path -- 2229
			do -- 2229
				local _obj_0 = req.body -- 2229
				local _type_1 = type(_obj_0) -- 2229
				if "table" == _type_1 or "userdata" == _type_1 then -- 2229
					path = _obj_0.path -- 2229
				end -- 2229
			end -- 2229
			local zipFile -- 2229
			do -- 2229
				local _obj_0 = req.body -- 2229
				local _type_1 = type(_obj_0) -- 2229
				if "table" == _type_1 or "userdata" == _type_1 then -- 2229
					zipFile = _obj_0.zipFile -- 2229
				end -- 2229
			end -- 2229
			local obfuscated -- 2229
			do -- 2229
				local _obj_0 = req.body -- 2229
				local _type_1 = type(_obj_0) -- 2229
				if "table" == _type_1 or "userdata" == _type_1 then -- 2229
					obfuscated = _obj_0.obfuscated -- 2229
				end -- 2229
			end -- 2229
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2229
				if zipping then -- 2230
					goto failed -- 2230
				end -- 2230
				zipping = true -- 2231
				local _ <close> = setmetatable({ }, { -- 2232
					__close = function() -- 2232
						zipping = false -- 2232
					end -- 2232
				}) -- 2232
				if not Content:exist(path) then -- 2233
					goto failed -- 2233
				end -- 2233
				Content:mkdir(Path:getPath(zipFile)) -- 2234
				if obfuscated then -- 2235
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2236
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2237
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2238
					Content:remove(scriptPath) -- 2239
					Content:remove(obfuscatedPath) -- 2240
					Content:remove(tempPath) -- 2241
					Content:mkdir(scriptPath) -- 2242
					Content:mkdir(obfuscatedPath) -- 2243
					Content:mkdir(tempPath) -- 2244
					if not Content:copyAsync(path, tempPath) then -- 2245
						goto failed -- 2245
					end -- 2245
					local Entry = require("Script.Dev.Entry") -- 2246
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2247
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2248
						"tl", -- 2248
						"yue", -- 2248
						"lua", -- 2248
						"ts", -- 2248
						"tsx", -- 2248
						"vs", -- 2248
						"bl", -- 2248
						"xml", -- 2248
						"wa", -- 2248
						"mod" -- 2248
					}, true) -- 2248
					for _index_0 = 1, #scriptFiles do -- 2249
						local file = scriptFiles[_index_0] -- 2249
						Content:remove(Path(tempPath, file)) -- 2250
					end -- 2249
					for _index_0 = 1, #luaFiles do -- 2251
						local file = luaFiles[_index_0] -- 2251
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2252
					end -- 2251
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2253
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2254
					end) then -- 2253
						goto failed -- 2253
					end -- 2253
					return { -- 2255
						success = true -- 2255
					} -- 2255
				else -- 2257
					return { -- 2257
						success = Content:zipAsync(path, zipFile, function(file) -- 2257
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2258
						end) -- 2257
					} -- 2257
				end -- 2235
			end -- 2229
		end -- 2229
	end -- 2229
	::failed:: -- 2259
	return { -- 2228
		success = false -- 2228
	} -- 2228
end) -- 2228
HttpServer:postSchedule("/unzip", function(req) -- 2261
	do -- 2262
		local _type_0 = type(req) -- 2262
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2262
		if _tab_0 then -- 2262
			local zipFile -- 2262
			do -- 2262
				local _obj_0 = req.body -- 2262
				local _type_1 = type(_obj_0) -- 2262
				if "table" == _type_1 or "userdata" == _type_1 then -- 2262
					zipFile = _obj_0.zipFile -- 2262
				end -- 2262
			end -- 2262
			local path -- 2262
			do -- 2262
				local _obj_0 = req.body -- 2262
				local _type_1 = type(_obj_0) -- 2262
				if "table" == _type_1 or "userdata" == _type_1 then -- 2262
					path = _obj_0.path -- 2262
				end -- 2262
			end -- 2262
			if zipFile ~= nil and path ~= nil then -- 2262
				return { -- 2263
					success = Content:unzipAsync(zipFile, path, function(file) -- 2263
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2264
					end) -- 2263
				} -- 2263
			end -- 2262
		end -- 2262
	end -- 2262
	return { -- 2261
		success = false -- 2261
	} -- 2261
end) -- 2261
HttpServer:post("/editing-info", function(req) -- 2266
	local Entry = require("Script.Dev.Entry") -- 2267
	local config = Entry.getConfig() -- 2268
	local _type_0 = type(req) -- 2269
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2269
	local _match_0 = false -- 2269
	if _tab_0 then -- 2269
		local editingInfo -- 2269
		do -- 2269
			local _obj_0 = req.body -- 2269
			local _type_1 = type(_obj_0) -- 2269
			if "table" == _type_1 or "userdata" == _type_1 then -- 2269
				editingInfo = _obj_0.editingInfo -- 2269
			end -- 2269
		end -- 2269
		if editingInfo ~= nil then -- 2269
			_match_0 = true -- 2269
			config.editingInfo = editingInfo -- 2270
			return { -- 2271
				success = true -- 2271
			} -- 2271
		end -- 2269
	end -- 2269
	if not _match_0 then -- 2269
		if not (config.editingInfo ~= nil) then -- 2273
			local folder -- 2274
			if App.locale:match('^zh') then -- 2274
				folder = 'zh-Hans' -- 2274
			else -- 2274
				folder = 'en' -- 2274
			end -- 2274
			config.editingInfo = json.encode({ -- 2276
				index = 0, -- 2276
				files = { -- 2278
					{ -- 2279
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2279
						title = "welcome.md" -- 2280
					} -- 2278
				} -- 2277
			}) -- 2275
		end -- 2273
		return { -- 2284
			success = true, -- 2284
			editingInfo = config.editingInfo -- 2284
		} -- 2284
	end -- 2269
end) -- 2266
HttpServer:post("/command", function(req) -- 2286
	do -- 2287
		local _type_0 = type(req) -- 2287
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2287
		if _tab_0 then -- 2287
			local code -- 2287
			do -- 2287
				local _obj_0 = req.body -- 2287
				local _type_1 = type(_obj_0) -- 2287
				if "table" == _type_1 or "userdata" == _type_1 then -- 2287
					code = _obj_0.code -- 2287
				end -- 2287
			end -- 2287
			local log -- 2287
			do -- 2287
				local _obj_0 = req.body -- 2287
				local _type_1 = type(_obj_0) -- 2287
				if "table" == _type_1 or "userdata" == _type_1 then -- 2287
					log = _obj_0.log -- 2287
				end -- 2287
			end -- 2287
			if code ~= nil and log ~= nil then -- 2287
				emit("AppCommand", code, log) -- 2288
				return { -- 2289
					success = true -- 2289
				} -- 2289
			end -- 2287
		end -- 2287
	end -- 2287
	return { -- 2286
		success = false -- 2286
	} -- 2286
end) -- 2286
HttpServer:post("/log/save", function() -- 2291
	local folder = ".download" -- 2292
	local fullLogFile = "dora_full_logs.txt" -- 2293
	local fullFolder = Path(Content.writablePath, folder) -- 2294
	Content:mkdir(fullFolder) -- 2295
	local logPath = Path(fullFolder, fullLogFile) -- 2296
	if App:saveLog(logPath) then -- 2297
		return { -- 2298
			success = true, -- 2298
			path = Path(folder, fullLogFile) -- 2298
		} -- 2298
	end -- 2297
	return { -- 2291
		success = false -- 2291
	} -- 2291
end) -- 2291
local tailLines -- 2300
tailLines = function(text, count) -- 2300
	local lines = { } -- 2301
	text = text:gsub("\r\n", "\n") -- 2302
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2303
		lines[#lines + 1] = line -- 2304
	end -- 2303
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2305
		table.remove(lines) -- 2306
	end -- 2305
	local start = math.max(1, #lines - count + 1) -- 2307
	local out = { } -- 2308
	for i = start, #lines do -- 2309
		out[#out + 1] = lines[i] -- 2310
	end -- 2309
	return table.concat(out, "\n") -- 2311
end -- 2300
HttpServer:post("/log", function(req) -- 2313
	local count = 100 -- 2314
	if req and req.body and req.body.count ~= nil then -- 2315
		count = req.body.count -- 2316
	end -- 2315
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2317
		return { -- 2318
			success = false, -- 2318
			message = "count must be a positive integer" -- 2318
		} -- 2318
	end -- 2317
	local folder = ".download" -- 2319
	local fullLogFile = "dora_full_logs.txt" -- 2320
	local fullFolder = Path(Content.writablePath, folder) -- 2321
	Content:mkdir(fullFolder) -- 2322
	local logPath = Path(fullFolder, fullLogFile) -- 2323
	if App:saveLog(logPath) then -- 2324
		local text = Content:load(logPath) -- 2325
		if text then -- 2326
			return { -- 2327
				success = true, -- 2327
				log = tailLines(text, count) -- 2327
			} -- 2327
		else -- 2329
			return { -- 2329
				success = false, -- 2329
				message = "failed to read log" -- 2329
			} -- 2329
		end -- 2326
	else -- 2331
		return { -- 2331
			success = false, -- 2331
			message = "failed to save log" -- 2331
		} -- 2331
	end -- 2324
	return { -- 2313
		success = false -- 2313
	} -- 2313
end) -- 2313
HttpServer:post("/yarn/check", function(req) -- 2333
	local yarncompile = require("yarncompile") -- 2334
	do -- 2335
		local _type_0 = type(req) -- 2335
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2335
		if _tab_0 then -- 2335
			local code -- 2335
			do -- 2335
				local _obj_0 = req.body -- 2335
				local _type_1 = type(_obj_0) -- 2335
				if "table" == _type_1 or "userdata" == _type_1 then -- 2335
					code = _obj_0.code -- 2335
				end -- 2335
			end -- 2335
			if code ~= nil then -- 2335
				local jsonObject = json.decode(code) -- 2336
				if jsonObject then -- 2336
					local errors = { } -- 2337
					local _list_0 = jsonObject.nodes -- 2338
					for _index_0 = 1, #_list_0 do -- 2338
						local node = _list_0[_index_0] -- 2338
						local title, body = node.title, node.body -- 2339
						local luaCode, err = yarncompile(body) -- 2340
						if not luaCode then -- 2340
							errors[#errors + 1] = title .. ":" .. err -- 2341
						end -- 2340
					end -- 2338
					return { -- 2342
						success = true, -- 2342
						syntaxError = table.concat(errors, "\n\n") -- 2342
					} -- 2342
				end -- 2336
			end -- 2335
		end -- 2335
	end -- 2335
	return { -- 2333
		success = false -- 2333
	} -- 2333
end) -- 2333
HttpServer:post("/yarn/check-file", function(req) -- 2344
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
				local res, _, err = yarncompile(code, true) -- 2347
				if not res then -- 2347
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2348
					return { -- 2349
						success = false, -- 2349
						message = message, -- 2349
						line = line, -- 2349
						column = column, -- 2349
						node = node -- 2349
					} -- 2349
				end -- 2347
			end -- 2346
		end -- 2346
	end -- 2346
	return { -- 2344
		success = true -- 2344
	} -- 2344
end) -- 2344
getWaProjectDirFromFile = function(file) -- 2351
	local current -- 2352
	if Content:isdir(file) then -- 2352
		current = file -- 2352
	else -- 2352
		current = Path:getPath(file) -- 2352
	end -- 2352
	if current == "" then -- 2353
		return nil -- 2353
	end -- 2353
	repeat -- 2354
		local modPath = Path(current, "wa.mod") -- 2355
		if Content:exist(modPath) then -- 2356
			return current, modPath -- 2357
		end -- 2356
		local parent = Path:getPath(current) -- 2358
		if parent == "" or parent == current then -- 2359
			break -- 2359
		end -- 2359
		current = parent -- 2360
	until false -- 2354
	return nil -- 2362
end -- 2351
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2364
	do -- 2365
		local _type_0 = type(req) -- 2365
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2365
		if _tab_0 then -- 2365
			local path -- 2365
			do -- 2365
				local _obj_0 = req.body -- 2365
				local _type_1 = type(_obj_0) -- 2365
				if "table" == _type_1 or "userdata" == _type_1 then -- 2365
					path = _obj_0.path -- 2365
				end -- 2365
			end -- 2365
			if path ~= nil then -- 2365
				local projDir = getWaProjectDirFromFile(path) -- 2366
				if projDir then -- 2366
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2367
					if not Content:exist(sourceDoraPath) then -- 2368
						return { -- 2369
							success = false, -- 2369
							message = "missing dora template" -- 2369
						} -- 2369
					end -- 2368
					local targetVendorPath = Path(projDir, "vendor") -- 2370
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2371
					if not Content:exist(targetVendorPath) then -- 2372
						if not Content:mkdir(targetVendorPath) then -- 2373
							return { -- 2374
								success = false, -- 2374
								message = "failed to create vendor folder" -- 2374
							} -- 2374
						end -- 2373
					elseif not Content:isdir(targetVendorPath) then -- 2375
						return { -- 2376
							success = false, -- 2376
							message = "vendor path is not a folder" -- 2376
						} -- 2376
					end -- 2372
					if Content:exist(targetDoraPath) then -- 2377
						if not Content:remove(targetDoraPath) then -- 2378
							return { -- 2379
								success = false, -- 2379
								message = "failed to remove old dora" -- 2379
							} -- 2379
						end -- 2378
					end -- 2377
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2380
						return { -- 2381
							success = false, -- 2381
							message = "failed to copy dora" -- 2381
						} -- 2381
					end -- 2380
					return { -- 2382
						success = true -- 2382
					} -- 2382
				else -- 2384
					return { -- 2384
						success = false, -- 2384
						message = 'Wa file needs a project' -- 2384
					} -- 2384
				end -- 2366
			end -- 2365
		end -- 2365
	end -- 2365
	return { -- 2364
		success = false, -- 2364
		message = "invalid call" -- 2364
	} -- 2364
end) -- 2364
HttpServer:postSchedule("/wa/build", function(req) -- 2386
	do -- 2387
		local _type_0 = type(req) -- 2387
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2387
		if _tab_0 then -- 2387
			local path -- 2387
			do -- 2387
				local _obj_0 = req.body -- 2387
				local _type_1 = type(_obj_0) -- 2387
				if "table" == _type_1 or "userdata" == _type_1 then -- 2387
					path = _obj_0.path -- 2387
				end -- 2387
			end -- 2387
			if path ~= nil then -- 2387
				local projDir = getWaProjectDirFromFile(path) -- 2388
				if projDir then -- 2388
					local message = Wasm:buildWaAsync(projDir) -- 2389
					if message == "" then -- 2390
						return { -- 2391
							success = true -- 2391
						} -- 2391
					else -- 2393
						return { -- 2393
							success = false, -- 2393
							message = message -- 2393
						} -- 2393
					end -- 2390
				else -- 2395
					return { -- 2395
						success = false, -- 2395
						message = 'Wa file needs a project' -- 2395
					} -- 2395
				end -- 2388
			end -- 2387
		end -- 2387
	end -- 2387
	return { -- 2396
		success = false, -- 2396
		message = 'failed to build' -- 2396
	} -- 2396
end) -- 2386
HttpServer:postSchedule("/wa/format", function(req) -- 2398
	do -- 2399
		local _type_0 = type(req) -- 2399
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2399
		if _tab_0 then -- 2399
			local file -- 2399
			do -- 2399
				local _obj_0 = req.body -- 2399
				local _type_1 = type(_obj_0) -- 2399
				if "table" == _type_1 or "userdata" == _type_1 then -- 2399
					file = _obj_0.file -- 2399
				end -- 2399
			end -- 2399
			if file ~= nil then -- 2399
				local code = Wasm:formatWaAsync(file) -- 2400
				if code == "" then -- 2401
					return { -- 2402
						success = false -- 2402
					} -- 2402
				else -- 2404
					return { -- 2404
						success = true, -- 2404
						code = code -- 2404
					} -- 2404
				end -- 2401
			end -- 2399
		end -- 2399
	end -- 2399
	return { -- 2405
		success = false -- 2405
	} -- 2405
end) -- 2398
HttpServer:postSchedule("/wa/create", function(req) -- 2407
	do -- 2408
		local _type_0 = type(req) -- 2408
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2408
		if _tab_0 then -- 2408
			local path -- 2408
			do -- 2408
				local _obj_0 = req.body -- 2408
				local _type_1 = type(_obj_0) -- 2408
				if "table" == _type_1 or "userdata" == _type_1 then -- 2408
					path = _obj_0.path -- 2408
				end -- 2408
			end -- 2408
			if path ~= nil then -- 2408
				if not Content:exist(Path:getPath(path)) then -- 2409
					return { -- 2410
						success = false, -- 2410
						message = "target path not existed" -- 2410
					} -- 2410
				end -- 2409
				if Content:exist(path) then -- 2411
					return { -- 2412
						success = false, -- 2412
						message = "target project folder existed" -- 2412
					} -- 2412
				end -- 2411
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2413
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2414
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2415
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2416
					return { -- 2419
						success = false, -- 2419
						message = "missing template project" -- 2419
					} -- 2419
				end -- 2416
				if not Content:mkdir(path) then -- 2420
					return { -- 2421
						success = false, -- 2421
						message = "failed to create project folder" -- 2421
					} -- 2421
				end -- 2420
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2422
					Content:remove(path) -- 2423
					return { -- 2424
						success = false, -- 2424
						message = "failed to copy template" -- 2424
					} -- 2424
				end -- 2422
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2425
					Content:remove(path) -- 2426
					return { -- 2427
						success = false, -- 2427
						message = "failed to copy template" -- 2427
					} -- 2427
				end -- 2425
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2428
					Content:remove(path) -- 2429
					return { -- 2430
						success = false, -- 2430
						message = "failed to copy template" -- 2430
					} -- 2430
				end -- 2428
				return { -- 2431
					success = true -- 2431
				} -- 2431
			end -- 2408
		end -- 2408
	end -- 2408
	return { -- 2407
		success = false, -- 2407
		message = "invalid call" -- 2407
	} -- 2407
end) -- 2407
local tsBuildGlobs = { -- 2434
	"**/*.ts", -- 2434
	"**/*.tsx", -- 2435
	"!**/.*/**", -- 2436
	"!**/node_modules/**" -- 2437
} -- 2433
local transpileTSFile -- 2439
do -- 2439
	local tsBuildTimeout <const> = 30 -- 2440
	local tsBuildRequestId = 0 -- 2441
	transpileTSFile = function(file, content, sourceRoot) -- 2442
		tsBuildRequestId = tsBuildRequestId + 1 -- 2443
		local requestId = tsBuildRequestId -- 2444
		local done = false -- 2445
		local result = nil -- 2446
		local listener = Node() -- 2447
		listener:gslot("AppWS", function(event) -- 2448
			if event.type == "Receive" then -- 2449
				local res = json.decode(event.msg) -- 2450
				if res then -- 2450
					if res.name == "TranspileTS" and res.id == requestId then -- 2451
						listener:removeFromParent() -- 2452
						if res.success then -- 2453
							local luaFile = Path:replaceExt(file, "lua") -- 2454
							Content:save(luaFile, res.luaCode) -- 2455
							result = { -- 2456
								success = true, -- 2456
								file = file -- 2456
							} -- 2456
						else -- 2458
							result = { -- 2458
								success = false, -- 2458
								file = file, -- 2458
								message = res.message -- 2458
							} -- 2458
						end -- 2453
						done = true -- 2459
					end -- 2451
				end -- 2450
			end -- 2449
		end) -- 2448
		emit("AppWS", "Send", json.encode({ -- 2460
			name = "TranspileTS", -- 2460
			id = requestId, -- 2460
			file = file, -- 2460
			content = content, -- 2460
			projectRoot = sourceRoot -- 2460
		})) -- 2460
		local deadline = App.runningTime + tsBuildTimeout -- 2461
		wait(function() -- 2462
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline -- 2462
		end) -- 2462
		if not done then -- 2463
			listener:removeFromParent() -- 2464
			if HttpServer.wsConnectionCount == 0 then -- 2465
				return { -- 2466
					success = false, -- 2466
					file = file, -- 2466
					message = "Web IDE disconnected" -- 2466
				} -- 2466
			end -- 2465
			return { -- 2467
				success = false, -- 2467
				file = file, -- 2467
				message = "TypeScript transpile timed out" -- 2467
			} -- 2467
		end -- 2463
		return result -- 2468
	end -- 2442
end -- 2439
local _anon_func_7 = function(path) -- 2479
	local _val_0 = Path:getExt(path) -- 2479
	return "ts" == _val_0 or "tsx" == _val_0 -- 2479
end -- 2479
HttpServer:postSchedule("/ts/build", function(req) -- 2470
	do -- 2471
		local _type_0 = type(req) -- 2471
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2471
		if _tab_0 then -- 2471
			local path -- 2471
			do -- 2471
				local _obj_0 = req.body -- 2471
				local _type_1 = type(_obj_0) -- 2471
				if "table" == _type_1 or "userdata" == _type_1 then -- 2471
					path = _obj_0.path -- 2471
				end -- 2471
			end -- 2471
			if path ~= nil then -- 2471
				if HttpServer.wsConnectionCount == 0 then -- 2472
					return { -- 2473
						success = false, -- 2473
						message = "Web IDE not connected" -- 2473
					} -- 2473
				end -- 2472
				local projectRoot = req.body.projectRoot -- 2474
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2475
				if not Content:exist(path) then -- 2476
					return { -- 2477
						success = false, -- 2477
						message = "path not existed" -- 2477
					} -- 2477
				end -- 2476
				if not Content:isdir(path) then -- 2478
					if not (_anon_func_7(path)) then -- 2479
						return { -- 2480
							success = false, -- 2480
							message = "expecting a TypeScript file" -- 2480
						} -- 2480
					end -- 2479
					local messages = { } -- 2481
					local content = Content:load(path) -- 2482
					if not content then -- 2483
						return { -- 2484
							success = false, -- 2484
							message = "failed to read file" -- 2484
						} -- 2484
					end -- 2483
					emit("AppWS", "Send", json.encode({ -- 2485
						name = "UpdateFile", -- 2485
						file = path, -- 2485
						exists = true, -- 2485
						content = content, -- 2485
						projectRoot = sourceRoot -- 2485
					})) -- 2485
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2486
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot) -- 2487
					end -- 2486
					return { -- 2488
						success = true, -- 2488
						messages = messages -- 2488
					} -- 2488
				else -- 2490
					local fileData = { } -- 2490
					local messages = { } -- 2491
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2492
					for _index_0 = 1, #_list_0 do -- 2492
						local subFile = _list_0[_index_0] -- 2492
						local file = Path(path, subFile) -- 2493
						local content = Content:load(file) -- 2494
						if content then -- 2494
							fileData[file] = content -- 2495
							emit("AppWS", "Send", json.encode({ -- 2496
								name = "UpdateFile", -- 2496
								file = file, -- 2496
								exists = true, -- 2496
								content = content, -- 2496
								projectRoot = sourceRoot -- 2496
							})) -- 2496
						else -- 2498
							messages[#messages + 1] = { -- 2498
								success = false, -- 2498
								file = file, -- 2498
								message = "failed to read file" -- 2498
							} -- 2498
						end -- 2494
					end -- 2492
					for file, content in pairs(fileData) do -- 2499
						if "d" == Path:getExt(Path:getName(file)) then -- 2500
							goto _continue_0 -- 2500
						end -- 2500
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot) -- 2501
						::_continue_0:: -- 2500
					end -- 2499
					return { -- 2502
						success = true, -- 2502
						messages = messages -- 2502
					} -- 2502
				end -- 2478
			end -- 2471
		end -- 2471
	end -- 2471
	return { -- 2470
		success = false -- 2470
	} -- 2470
end) -- 2470
HttpServer:post("/download", function(req) -- 2504
	do -- 2505
		local _type_0 = type(req) -- 2505
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2505
		if _tab_0 then -- 2505
			local url -- 2505
			do -- 2505
				local _obj_0 = req.body -- 2505
				local _type_1 = type(_obj_0) -- 2505
				if "table" == _type_1 or "userdata" == _type_1 then -- 2505
					url = _obj_0.url -- 2505
				end -- 2505
			end -- 2505
			local target -- 2505
			do -- 2505
				local _obj_0 = req.body -- 2505
				local _type_1 = type(_obj_0) -- 2505
				if "table" == _type_1 or "userdata" == _type_1 then -- 2505
					target = _obj_0.target -- 2505
				end -- 2505
			end -- 2505
			if url ~= nil and target ~= nil then -- 2505
				local Entry = require("Script.Dev.Entry") -- 2506
				Entry.downloadFile(url, target) -- 2507
				return { -- 2508
					success = true -- 2508
				} -- 2508
			end -- 2505
		end -- 2505
	end -- 2505
	return { -- 2504
		success = false -- 2504
	} -- 2504
end) -- 2504
local isDesktopPlatform -- 2510
isDesktopPlatform = function() -- 2510
	local _val_0 = App.platform -- 2511
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2511
end -- 2510
local getServerStatus -- 2513
getServerStatus = function() -- 2513
	local Entry = require("Script.Dev.Entry") -- 2514
	local running = Entry.getCurrentEntryStatus() -- 2515
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2516
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2517
	return { -- 2519
		success = true, -- 2519
		platform = App.platform, -- 2520
		locale = App.locale, -- 2521
		version = App.version, -- 2522
		url = "http://localhost:8866", -- 2523
		wsConnectionCount = wsConnectionCount, -- 2524
		webIDEConnected = wsConnectionCount > 0, -- 2525
		assetPath = Content.assetPath, -- 2526
		writablePath = Content.writablePath, -- 2527
		appPath = Content.appPath, -- 2528
		waTemplateReady = waTemplateReady, -- 2529
		running = running -- 2530
	} -- 2518
end -- 2513
HttpServer:post("/status", function() -- 2533
	return getServerStatus() -- 2534
end) -- 2533
HttpServer:postSchedule("/doctor/fix", function(req) -- 2536
	do -- 2537
		local _type_0 = type(req) -- 2537
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2537
		if _tab_0 then -- 2537
			local openWebIDE -- 2537
			do -- 2537
				local _obj_0 = req.body -- 2537
				local _type_1 = type(_obj_0) -- 2537
				if "table" == _type_1 or "userdata" == _type_1 then -- 2537
					openWebIDE = _obj_0.openWebIDE -- 2537
				end -- 2537
			end -- 2537
			if openWebIDE ~= nil then -- 2537
				if not openWebIDE then -- 2538
					return { -- 2539
						success = false, -- 2539
						message = "nothing to fix" -- 2539
					} -- 2539
				end -- 2538
				local status = getServerStatus() -- 2540
				if status.webIDEConnected then -- 2541
					return { -- 2542
						success = true, -- 2542
						fixed = false, -- 2542
						message = "Web IDE already connected.", -- 2542
						status = status -- 2542
					} -- 2542
				end -- 2541
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2543
				if waitSeconds > 0 then -- 2544
					local deadline = os.time() + waitSeconds -- 2545
					repeat -- 2546
						sleep(0.2) -- 2547
						status = getServerStatus() -- 2548
						if status.webIDEConnected then -- 2549
							return { -- 2550
								success = true, -- 2550
								fixed = false, -- 2550
								reconnected = true, -- 2550
								message = "Web IDE reconnected.", -- 2550
								status = status -- 2550
							} -- 2550
						end -- 2549
					until os.time() >= deadline -- 2546
				end -- 2544
				if not isDesktopPlatform() then -- 2552
					return { -- 2553
						success = false, -- 2553
						message = "opening Web IDE is only supported on desktop platforms", -- 2553
						status = status -- 2553
					} -- 2553
				end -- 2552
				local url = "http://localhost:8866" -- 2554
				App:openURL(url) -- 2555
				status.openedURL = url -- 2556
				return { -- 2557
					success = true, -- 2557
					fixed = true, -- 2557
					message = "Opened Web IDE in the local browser.", -- 2557
					url = url, -- 2557
					status = status -- 2557
				} -- 2557
			end -- 2537
		end -- 2537
	end -- 2537
	return { -- 2536
		success = false, -- 2536
		message = "invalid call" -- 2536
	} -- 2536
end) -- 2536
local status = { } -- 2559
_module_0 = status -- 2560
status.buildAsync = function(path) -- 2562
	if not Content:exist(path) then -- 2563
		return { -- 2564
			success = false, -- 2564
			file = path, -- 2564
			message = "file not existed" -- 2564
		} -- 2564
	end -- 2563
	do -- 2565
		local _exp_0 = Path:getExt(path) -- 2565
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2565
			if '' == Path:getExt(Path:getName(path)) then -- 2566
				local content = Content:loadAsync(path) -- 2567
				if content then -- 2567
					local resultCodes, err = compileFileAsync(path, content) -- 2568
					if resultCodes then -- 2568
						return { -- 2569
							success = true, -- 2569
							file = path -- 2569
						} -- 2569
					else -- 2571
						return { -- 2571
							success = false, -- 2571
							file = path, -- 2571
							message = err -- 2571
						} -- 2571
					end -- 2568
				end -- 2567
			end -- 2566
		elseif "lua" == _exp_0 then -- 2572
			local content = Content:loadAsync(path) -- 2573
			if content then -- 2573
				do -- 2574
					local isTIC80 = CheckTIC80Code(content) -- 2574
					if isTIC80 then -- 2574
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2575
					end -- 2574
				end -- 2574
				local success, info -- 2576
				do -- 2576
					local _obj_0 = luaCheck(path, content) -- 2576
					success, info = _obj_0.success, _obj_0.info -- 2576
				end -- 2576
				if success then -- 2577
					return { -- 2578
						success = true, -- 2578
						file = path -- 2578
					} -- 2578
				elseif info and #info > 0 then -- 2579
					local messages = { } -- 2580
					for _index_0 = 1, #info do -- 2581
						local _des_0 = info[_index_0] -- 2581
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2581
						local lineText = "" -- 2582
						if line then -- 2583
							local currentLine = 1 -- 2584
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2585
								if currentLine == line then -- 2586
									lineText = text -- 2587
									break -- 2588
								end -- 2586
								currentLine = currentLine + 1 -- 2589
							end -- 2585
						end -- 2583
						if line then -- 2590
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2591
						else -- 2593
							messages[#messages + 1] = message -- 2593
						end -- 2590
					end -- 2581
					return { -- 2594
						success = false, -- 2594
						file = path, -- 2594
						message = table.concat(messages, "\n") -- 2594
					} -- 2594
				else -- 2596
					return { -- 2596
						success = false, -- 2596
						file = path, -- 2596
						message = "lua check failed" -- 2596
					} -- 2596
				end -- 2577
			end -- 2573
		elseif "yarn" == _exp_0 then -- 2597
			local content = Content:loadAsync(path) -- 2598
			if content then -- 2598
				local res, _, err = yarncompile(content, true) -- 2599
				if res then -- 2599
					return { -- 2600
						success = true, -- 2600
						file = path -- 2600
					} -- 2600
				else -- 2602
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2602
					local lineText = "" -- 2603
					if line then -- 2604
						local currentLine = 1 -- 2605
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2606
							if currentLine == line then -- 2607
								lineText = text -- 2608
								break -- 2609
							end -- 2607
							currentLine = currentLine + 1 -- 2610
						end -- 2606
					end -- 2604
					if node ~= "" then -- 2611
						node = "node: " .. tostring(node) .. ", " -- 2612
					else -- 2613
						node = "" -- 2613
					end -- 2611
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2614
					return { -- 2615
						success = false, -- 2615
						file = path, -- 2615
						message = message -- 2615
					} -- 2615
				end -- 2599
			end -- 2598
		end -- 2565
	end -- 2565
	return { -- 2616
		success = false, -- 2616
		file = path, -- 2616
		message = "invalid file to build" -- 2616
	} -- 2616
end -- 2562
HttpServer:postSchedule("/git/commit-files", function(req) -- 2618
	do -- 2619
		local _type_0 = type(req) -- 2619
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2619
		if _tab_0 then -- 2619
			local body = req.body -- 2619
			if body ~= nil then -- 2619
				local repoPath, commit = body.repoPath, body.commit -- 2620
				if gitInvalidRepoPath(repoPath) then -- 2621
					return { -- 2621
						success = false, -- 2621
						message = "invalid repoPath" -- 2621
					} -- 2621
				end -- 2621
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 2622
					return { -- 2622
						success = false, -- 2622
						message = "invalid commit" -- 2622
					} -- 2622
				end -- 2622
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 2623
				if not res.success then -- 2624
					return res -- 2624
				end -- 2624
				return { -- 2625
					success = true, -- 2625
					status = res.status, -- 2625
					data = res.status and res.status.data -- 2625
				} -- 2625
			end -- 2619
		end -- 2619
	end -- 2619
	return invalidArguments -- 2618
end) -- 2618
thread(function() -- 2627
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 2628
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 2629
	if Content:exist(doraWeb) then -- 2630
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) -- 2631
		local needReload -- 2632
		if Content:exist(doraReady) then -- 2632
			needReload = readyContent ~= Content:load(doraReady) -- 2633
		else -- 2634
			needReload = true -- 2634
		end -- 2632
		if needReload then -- 2635
			Content:remove(Path(Content.appPath, ".www")) -- 2636
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 2637
			Content:save(doraReady, readyContent) -- 2641
			print("Dora Dora is ready!") -- 2642
		end -- 2635
	end -- 2630
	HttpServer:clearStaticCacheControls() -- 2643
	HttpServer:setStaticCacheControl("no-cache") -- 2644
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 2645
	if HttpServer:start(8866) then -- 2649
		local localIP = HttpServer.localIP -- 2650
		if localIP == "" then -- 2651
			localIP = "localhost" -- 2651
		end -- 2651
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 2652
		return HttpServer:startWS(8868) -- 2653
	else -- 2655
		status.url = nil -- 2655
		return print("8866 Port not available!") -- 2656
	end -- 2649
end) -- 2627
return _module_0 -- 1
