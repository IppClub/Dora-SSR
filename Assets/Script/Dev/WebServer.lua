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
	local logRes = gitRunSync(repoPath, "log -n 100", nil, 120) -- 500
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
				return gitRunSync(repoPath, "status", nil, 10) -- 583
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
				return gitRunSync(repoPath, "log -n " .. tostring(limit), nil, 10) -- 635
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
HttpServer:post("/info", function() -- 1389
	local Entry = require("Script.Dev.Entry") -- 1390
	local webProfiler, drawerWidth -- 1391
	do -- 1391
		local _obj_0 = Entry.getConfig() -- 1391
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 1391
	end -- 1391
	local engineDev = Entry.getEngineDev() -- 1392
	Entry.connectWebIDE() -- 1393
	return { -- 1395
		platform = App.platform, -- 1395
		locale = App.locale, -- 1396
		version = App.version, -- 1397
		engineDev = engineDev, -- 1398
		webProfiler = webProfiler, -- 1399
		drawerWidth = drawerWidth -- 1400
	} -- 1394
end) -- 1389
local ensureLLMConfigTable -- 1402
ensureLLMConfigTable = function() -- 1402
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1403
	if columns and #columns > 0 then -- 1404
		local expected = { -- 1406
			id = true, -- 1406
			name = true, -- 1407
			url = true, -- 1408
			model = true, -- 1409
			api_key = true, -- 1410
			context_window = true, -- 1411
			temperature = true, -- 1412
			max_tokens = true, -- 1413
			reasoning_effort = true, -- 1414
			custom_options = true, -- 1415
			supports_function_calling = true, -- 1416
			active = true, -- 1417
			created_at = true, -- 1418
			updated_at = true -- 1419
		} -- 1405
		local existing = { } -- 1421
		local valid = true -- 1422
		for _index_0 = 1, #columns do -- 1423
			local row = columns[_index_0] -- 1423
			local columnName = tostring(row[2]) -- 1424
			existing[columnName] = true -- 1425
			if not expected[columnName] then -- 1426
				valid = false -- 1427
				break -- 1428
			end -- 1426
		end -- 1423
		if valid then -- 1429
			if not existing.context_window then -- 1430
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1431
			end -- 1430
			if not existing.temperature then -- 1432
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1433
			end -- 1432
			if not existing.max_tokens then -- 1434
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 1435
			end -- 1434
			if not existing.reasoning_effort then -- 1436
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1437
			end -- 1436
			if not existing.custom_options then -- 1438
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1439
			end -- 1438
			if not existing.supports_function_calling then -- 1440
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1441
			end -- 1440
		else -- 1443
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1443
		end -- 1429
	end -- 1404
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
	]]) -- 1444
end -- 1402
local normalizeContextWindow -- 1463
normalizeContextWindow = function(value) -- 1463
	local contextWindow = tonumber(value) -- 1464
	if contextWindow == nil or contextWindow < 64000 then -- 1465
		return 64000 -- 1466
	end -- 1465
	return math.max(64000, math.floor(contextWindow)) -- 1467
end -- 1463
local normalizeTemperature -- 1469
normalizeTemperature = function(value) -- 1469
	local temperature = tonumber(value) -- 1470
	if temperature == nil then -- 1471
		return 0.1 -- 1472
	end -- 1471
	return math.max(0, math.min(2, temperature)) -- 1473
end -- 1469
local normalizeMaxTokens -- 1475
normalizeMaxTokens = function(value) -- 1475
	local maxTokens = tonumber(value) -- 1476
	if maxTokens == nil or maxTokens < 1 then -- 1477
		return 8192 -- 1478
	end -- 1477
	return math.max(1, math.floor(maxTokens)) -- 1479
end -- 1475
local normalizeReasoningEffort -- 1481
normalizeReasoningEffort = function(value) -- 1481
	if value == nil then -- 1482
		return "" -- 1483
	end -- 1482
	local effort = tostring(value) -- 1484
	return effort:match("^%s*(.-)%s*$") or "" -- 1485
end -- 1481
local normalizeCustomOptions -- 1487
normalizeCustomOptions = function(value) -- 1487
	if value == nil then -- 1488
		return "" -- 1489
	end -- 1488
	local options = tostring(value) -- 1490
	options = options:match("^%s*(.-)%s*$") or "" -- 1491
	return options -- 1492
end -- 1487
local validateCustomOptions -- 1494
validateCustomOptions = function(value) -- 1494
	local options = normalizeCustomOptions(value) -- 1495
	if options == "" then -- 1496
		return true -- 1496
	end -- 1496
	if not options:match("^%s*{") then -- 1497
		return false -- 1497
	end -- 1497
	local decoded = json.decode(options) -- 1498
	return type(decoded) == "table" -- 1499
end -- 1494
HttpServer:post("/llm/list", function() -- 1501
	ensureLLMConfigTable() -- 1502
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1503
	local items -- 1507
	if rows and #rows > 0 then -- 1507
		local _accum_0 = { } -- 1508
		local _len_0 = 1 -- 1508
		for _index_0 = 1, #rows do -- 1508
			local _des_0 = rows[_index_0] -- 1508
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1508
			_accum_0[_len_0] = { -- 1509
				id = id, -- 1509
				name = name, -- 1509
				url = url, -- 1509
				model = model, -- 1509
				key = key, -- 1509
				contextWindow = normalizeContextWindow(contextWindow), -- 1509
				temperature = normalizeTemperature(temperature), -- 1509
				maxTokens = normalizeMaxTokens(maxTokens), -- 1509
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1509
				customOptions = normalizeCustomOptions(customOptions), -- 1509
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1509
			} -- 1509
			_len_0 = _len_0 + 1 -- 1509
		end -- 1508
		items = _accum_0 -- 1507
	end -- 1507
	return { -- 1510
		success = true, -- 1510
		items = items -- 1510
	} -- 1510
end) -- 1501
HttpServer:post("/llm/create", function(req) -- 1512
	ensureLLMConfigTable() -- 1513
	do -- 1514
		local _type_0 = type(req) -- 1514
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1514
		if _tab_0 then -- 1514
			local body = req.body -- 1514
			if body ~= nil then -- 1514
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1515
				local now = os.time() -- 1516
				if name == nil or url == nil or model == nil or key == nil then -- 1517
					return invalidArguments -- 1518
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
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1532
					tostring(name), -- 1532
					tostring(url), -- 1533
					tostring(model), -- 1534
					tostring(key), -- 1535
					contextWindow, -- 1536
					temperature, -- 1537
					maxTokens, -- 1538
					reasoningEffort, -- 1539
					customOptions, -- 1540
					supportsFunctionCalling, -- 1541
					1, -- 1542
					now, -- 1543
					now -- 1544
				}) -- 1526
				return { -- 1546
					success = affected >= 0 -- 1546
				} -- 1546
			end -- 1514
		end -- 1514
	end -- 1514
	return invalidArguments -- 1512
end) -- 1512
HttpServer:post("/llm/update", function(req) -- 1548
	ensureLLMConfigTable() -- 1549
	do -- 1550
		local _type_0 = type(req) -- 1550
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1550
		if _tab_0 then -- 1550
			local body = req.body -- 1550
			if body ~= nil then -- 1550
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1551
				local now = os.time() -- 1552
				id = tonumber(id) -- 1553
				if id == nil then -- 1554
					return invalidArguments -- 1554
				end -- 1554
				contextWindow = normalizeContextWindow(contextWindow) -- 1555
				temperature = normalizeTemperature(temperature) -- 1556
				maxTokens = normalizeMaxTokens(maxTokens) -- 1557
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1558
				customOptions = normalizeCustomOptions(customOptions) -- 1559
				if not validateCustomOptions(customOptions) then -- 1560
					return { -- 1560
						success = false, -- 1560
						message = "customOptions must be a JSON object" -- 1560
					} -- 1560
				end -- 1560
				if supportsFunctionCalling == false then -- 1561
					supportsFunctionCalling = 0 -- 1561
				else -- 1561
					supportsFunctionCalling = 1 -- 1561
				end -- 1561
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1566
					tostring(name), -- 1566
					tostring(url), -- 1567
					tostring(model), -- 1568
					tostring(key), -- 1569
					contextWindow, -- 1570
					temperature, -- 1571
					maxTokens, -- 1572
					reasoningEffort, -- 1573
					customOptions, -- 1574
					supportsFunctionCalling, -- 1575
					now, -- 1576
					id -- 1577
				}) -- 1562
				return { -- 1579
					success = affected >= 0 -- 1579
				} -- 1579
			end -- 1550
		end -- 1550
	end -- 1550
	return invalidArguments -- 1548
end) -- 1548
HttpServer:post("/llm/delete", function(req) -- 1581
	ensureLLMConfigTable() -- 1582
	do -- 1583
		local _type_0 = type(req) -- 1583
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1583
		if _tab_0 then -- 1583
			local id -- 1583
			do -- 1583
				local _obj_0 = req.body -- 1583
				local _type_1 = type(_obj_0) -- 1583
				if "table" == _type_1 or "userdata" == _type_1 then -- 1583
					id = _obj_0.id -- 1583
				end -- 1583
			end -- 1583
			if id ~= nil then -- 1583
				id = tonumber(id) -- 1584
				if id == nil then -- 1585
					return invalidArguments -- 1585
				end -- 1585
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1586
					id -- 1586
				}) -- 1586
				return { -- 1587
					success = affected >= 0 -- 1587
				} -- 1587
			end -- 1583
		end -- 1583
	end -- 1583
	return invalidArguments -- 1581
end) -- 1581
HttpServer:post("/stat", function(req) -- 1589
	do -- 1590
		local _type_0 = type(req) -- 1590
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1590
		if _tab_0 then -- 1590
			local path -- 1590
			do -- 1590
				local _obj_0 = req.body -- 1590
				local _type_1 = type(_obj_0) -- 1590
				if "table" == _type_1 or "userdata" == _type_1 then -- 1590
					path = _obj_0.path -- 1590
				end -- 1590
			end -- 1590
			if path ~= nil then -- 1590
				if not Content:exist(path) then -- 1591
					return { -- 1592
						success = false, -- 1592
						message = "target not existed" -- 1592
					} -- 1592
				end -- 1591
				if Content:isdir(path) then -- 1593
					return { -- 1594
						success = false, -- 1594
						message = "failed to stat a directory" -- 1594
					} -- 1594
				end -- 1593
				local size, isBinary = Content:getAttr(path) -- 1595
				if size then -- 1595
					return { -- 1596
						success = true, -- 1596
						size = size, -- 1596
						isBinary = isBinary -- 1596
					} -- 1596
				end -- 1595
			end -- 1590
		end -- 1590
	end -- 1590
	return { -- 1589
		success = false, -- 1589
		message = "failed to stat" -- 1589
	} -- 1589
end) -- 1589
HttpServer:post("/new", function(req) -- 1598
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
			local content -- 1599
			do -- 1599
				local _obj_0 = req.body -- 1599
				local _type_1 = type(_obj_0) -- 1599
				if "table" == _type_1 or "userdata" == _type_1 then -- 1599
					content = _obj_0.content -- 1599
				end -- 1599
			end -- 1599
			local folder -- 1599
			do -- 1599
				local _obj_0 = req.body -- 1599
				local _type_1 = type(_obj_0) -- 1599
				if "table" == _type_1 or "userdata" == _type_1 then -- 1599
					folder = _obj_0.folder -- 1599
				end -- 1599
			end -- 1599
			if path ~= nil and content ~= nil and folder ~= nil then -- 1599
				if Content:exist(path) then -- 1600
					return { -- 1601
						success = false, -- 1601
						message = "TargetExisted" -- 1601
					} -- 1601
				end -- 1600
				local parent = Path:getPath(path) -- 1602
				local files = Content:getFiles(parent) -- 1603
				if folder then -- 1604
					local name = Path:getFilename(path):lower() -- 1605
					for _index_0 = 1, #files do -- 1606
						local file = files[_index_0] -- 1606
						if name == Path:getFilename(file):lower() then -- 1607
							return { -- 1608
								success = false, -- 1608
								message = "TargetExisted" -- 1608
							} -- 1608
						end -- 1607
					end -- 1606
					if Content:mkdir(path) then -- 1609
						return { -- 1610
							success = true -- 1610
						} -- 1610
					end -- 1609
				else -- 1612
					local name = Path:getName(path):lower() -- 1612
					for _index_0 = 1, #files do -- 1613
						local file = files[_index_0] -- 1613
						if name == Path:getName(file):lower() then -- 1614
							local ext = Path:getExt(file) -- 1615
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1616
								goto _continue_0 -- 1617
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1618
								goto _continue_0 -- 1619
							end -- 1616
							return { -- 1620
								success = false, -- 1620
								message = "SourceExisted" -- 1620
							} -- 1620
						end -- 1614
						::_continue_0:: -- 1614
					end -- 1613
					if Content:save(path, content) then -- 1621
						return { -- 1622
							success = true -- 1622
						} -- 1622
					end -- 1621
				end -- 1604
			end -- 1599
		end -- 1599
	end -- 1599
	return { -- 1598
		success = false, -- 1598
		message = "Failed" -- 1598
	} -- 1598
end) -- 1598
local deleteAsset -- 1624
deleteAsset = function(path) -- 1624
	if not Content:exist(path) then -- 1625
		return false -- 1625
	end -- 1625
	local projectRoot -- 1626
	if Content:isdir(path) and isProjectRootDir(path) then -- 1626
		projectRoot = path -- 1626
	else -- 1626
		projectRoot = nil -- 1626
	end -- 1626
	local parent = Path:getPath(path) -- 1627
	local files = Content:getFiles(parent) -- 1628
	local name = Path:getName(path):lower() -- 1629
	local ext = Path:getExt(path) -- 1630
	for _index_0 = 1, #files do -- 1631
		local file = files[_index_0] -- 1631
		if name == Path:getName(file):lower() then -- 1632
			local _exp_0 = Path:getExt(file) -- 1633
			if "tl" == _exp_0 then -- 1633
				if ("vs" == ext) then -- 1633
					Content:remove(Path(parent, file)) -- 1634
				end -- 1633
			elseif "lua" == _exp_0 then -- 1635
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1635
					Content:remove(Path(parent, file)) -- 1636
				end -- 1635
			end -- 1633
		end -- 1632
	end -- 1631
	if Content:remove(path) then -- 1637
		if projectRoot then -- 1638
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1639
		end -- 1638
		return true -- 1640
	end -- 1637
	return false -- 1641
end -- 1624
local moveAsset -- 1643
moveAsset = function(old, new) -- 1643
	if not (Content:exist(old) and not Content:exist(new)) then -- 1644
		return false -- 1644
	end -- 1644
	local renamedDir = Content:isdir(old) -- 1645
	local parent = Path:getPath(new) -- 1646
	local files = Content:getFiles(parent) -- 1647
	if renamedDir then -- 1648
		local name = Path:getFilename(new):lower() -- 1649
		for _index_0 = 1, #files do -- 1650
			local file = files[_index_0] -- 1650
			if name == Path:getFilename(file):lower() then -- 1651
				return false -- 1652
			end -- 1651
		end -- 1650
	else -- 1654
		local name = Path:getName(new):lower() -- 1654
		local ext = Path:getExt(new) -- 1655
		for _index_0 = 1, #files do -- 1656
			local file = files[_index_0] -- 1656
			if name == Path:getName(file):lower() then -- 1657
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1658
					goto _continue_0 -- 1659
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1660
					goto _continue_0 -- 1661
				end -- 1658
				return false -- 1662
			end -- 1657
			::_continue_0:: -- 1657
		end -- 1656
	end -- 1648
	if not Content:move(old, new) then -- 1663
		return false -- 1663
	end -- 1663
	if renamedDir then -- 1664
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1665
	end -- 1664
	local newParent = Path:getPath(new) -- 1666
	parent = Path:getPath(old) -- 1667
	files = Content:getFiles(parent) -- 1668
	local newName = Path:getName(new) -- 1669
	local oldName = Path:getName(old) -- 1670
	local name = oldName:lower() -- 1671
	local ext = Path:getExt(old) -- 1672
	for _index_0 = 1, #files do -- 1673
		local file = files[_index_0] -- 1673
		if name == Path:getName(file):lower() then -- 1674
			local _exp_0 = Path:getExt(file) -- 1675
			if "tl" == _exp_0 then -- 1675
				if ("vs" == ext) then -- 1675
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1676
				end -- 1675
			elseif "lua" == _exp_0 then -- 1677
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1677
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1678
				end -- 1677
			end -- 1675
		end -- 1674
	end -- 1673
	return true -- 1679
end -- 1643
HttpServer:post("/delete", function(req) -- 1681
	do -- 1682
		local _type_0 = type(req) -- 1682
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1682
		if _tab_0 then -- 1682
			local path -- 1682
			do -- 1682
				local _obj_0 = req.body -- 1682
				local _type_1 = type(_obj_0) -- 1682
				if "table" == _type_1 or "userdata" == _type_1 then -- 1682
					path = _obj_0.path -- 1682
				end -- 1682
			end -- 1682
			if path ~= nil then -- 1682
				if deleteAsset(path) then -- 1683
					return { -- 1683
						success = true -- 1683
					} -- 1683
				end -- 1683
			end -- 1682
		end -- 1682
	end -- 1682
	return { -- 1681
		success = false -- 1681
	} -- 1681
end) -- 1681
HttpServer:post("/rename", function(req) -- 1685
	do -- 1686
		local _type_0 = type(req) -- 1686
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1686
		if _tab_0 then -- 1686
			local old -- 1686
			do -- 1686
				local _obj_0 = req.body -- 1686
				local _type_1 = type(_obj_0) -- 1686
				if "table" == _type_1 or "userdata" == _type_1 then -- 1686
					old = _obj_0.old -- 1686
				end -- 1686
			end -- 1686
			local new -- 1686
			do -- 1686
				local _obj_0 = req.body -- 1686
				local _type_1 = type(_obj_0) -- 1686
				if "table" == _type_1 or "userdata" == _type_1 then -- 1686
					new = _obj_0.new -- 1686
				end -- 1686
			end -- 1686
			if old ~= nil and new ~= nil then -- 1686
				if moveAsset(old, new) then -- 1687
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
local normalizeAssetPaths -- 1689
normalizeAssetPaths = function(paths) -- 1689
	if not (type(paths) == "table") then -- 1690
		return nil -- 1690
	end -- 1690
	local unique = { } -- 1691
	local candidates = { } -- 1692
	for _index_0 = 1, #paths do -- 1693
		local path = paths[_index_0] -- 1693
		if not (type(path) == "string") then -- 1694
			return nil -- 1694
		end -- 1694
		local relative = relativeToRoot(path, Content.writablePath) -- 1695
		if relative == nil or relative == "" or not Content:exist(path) then -- 1696
			return nil -- 1696
		end -- 1696
		for part in relative:gmatch("[^/]+") do -- 1697
			if part == ".." then -- 1698
				return nil -- 1698
			end -- 1698
		end -- 1697
		if not unique[path] then -- 1699
			unique[path] = true -- 1700
			candidates[#candidates + 1] = path -- 1701
		end -- 1699
	end -- 1693
	table.sort(candidates, function(a, b) -- 1702
		return #a < #b -- 1702
	end) -- 1702
	local result = { } -- 1703
	for _index_0 = 1, #candidates do -- 1704
		local path = candidates[_index_0] -- 1704
		local contained = false -- 1705
		for _index_1 = 1, #result do -- 1706
			local parent = result[_index_1] -- 1706
			if relativeToRoot(path, parent) ~= nil then -- 1707
				contained = true -- 1708
				break -- 1709
			end -- 1707
		end -- 1706
		if not contained then -- 1710
			result[#result + 1] = path -- 1710
		end -- 1710
	end -- 1704
	return result -- 1711
end -- 1689
HttpServer:postSchedule("/assets/batch", function(req) -- 1713
	do -- 1714
		local _type_0 = type(req) -- 1714
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1714
		if _tab_0 then -- 1714
			local operation -- 1714
			do -- 1714
				local _obj_0 = req.body -- 1714
				local _type_1 = type(_obj_0) -- 1714
				if "table" == _type_1 or "userdata" == _type_1 then -- 1714
					operation = _obj_0.operation -- 1714
				end -- 1714
			end -- 1714
			local sources -- 1714
			do -- 1714
				local _obj_0 = req.body -- 1714
				local _type_1 = type(_obj_0) -- 1714
				if "table" == _type_1 or "userdata" == _type_1 then -- 1714
					sources = _obj_0.sources -- 1714
				end -- 1714
			end -- 1714
			if operation ~= nil and sources ~= nil then -- 1714
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1715
					return { -- 1715
						success = false, -- 1715
						message = "invalid operation" -- 1715
					} -- 1715
				end -- 1715
				sources = normalizeAssetPaths(sources) -- 1716
				if not (sources and #sources > 0) then -- 1717
					return { -- 1717
						success = false, -- 1717
						message = "invalid sources" -- 1717
					} -- 1717
				end -- 1717
				local target = req.body.target -- 1718
				local destinations = { } -- 1719
				if operation ~= "delete" then -- 1720
					if not (type(target) == "string") then -- 1721
						return { -- 1721
							success = false, -- 1721
							message = "invalid target" -- 1721
						} -- 1721
					end -- 1721
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1722
					if targetRelative == nil then -- 1723
						return { -- 1723
							success = false, -- 1723
							message = "invalid target" -- 1723
						} -- 1723
					end -- 1723
					if not (Content:exist(target) and Content:isdir(target)) then -- 1724
						return { -- 1724
							success = false, -- 1724
							message = "invalid target" -- 1724
						} -- 1724
					end -- 1724
					for _index_0 = 1, #sources do -- 1725
						local source = sources[_index_0] -- 1725
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1726
							return { -- 1727
								success = false, -- 1727
								message = "target inside source" -- 1727
							} -- 1727
						end -- 1726
						local destination = Path(target, Path:getFilename(source)) -- 1728
						if Content:exist(destination) then -- 1729
							return { -- 1729
								success = false, -- 1729
								message = "target existed" -- 1729
							} -- 1729
						end -- 1729
						if destinations[destination] then -- 1730
							return { -- 1730
								success = false, -- 1730
								message = "duplicate target" -- 1730
							} -- 1730
						end -- 1730
						destinations[destination] = true -- 1731
					end -- 1725
				end -- 1720
				local changes = { } -- 1732
				local affectedSet = { } -- 1733
				local affectedDirectories = { } -- 1734
				local addAffected -- 1735
				addAffected = function(dir) -- 1735
					if affectedSet[dir] then -- 1736
						return -- 1736
					end -- 1736
					affectedSet[dir] = true -- 1737
					affectedDirectories[#affectedDirectories + 1] = dir -- 1738
				end -- 1735
				if operation ~= "delete" then -- 1739
					addAffected(target) -- 1739
				end -- 1739
				for _index_0 = 1, #sources do -- 1740
					local source = sources[_index_0] -- 1740
					addAffected(Path:getPath(source)) -- 1741
					if operation == "delete" then -- 1742
						if not deleteAsset(source) then -- 1743
							return { -- 1743
								success = false, -- 1743
								message = "delete failed", -- 1743
								changes = changes, -- 1743
								affectedDirectories = affectedDirectories -- 1743
							} -- 1743
						end -- 1743
						changes[#changes + 1] = { -- 1744
							old = source -- 1744
						} -- 1744
					else -- 1746
						local destination = Path(target, Path:getFilename(source)) -- 1746
						local ok -- 1747
						if operation == "copy" then -- 1747
							ok = Content:copyAsync(source, destination) -- 1748
						else -- 1750
							ok = moveAsset(source, destination) -- 1750
						end -- 1747
						if not ok then -- 1751
							return { -- 1751
								success = false, -- 1751
								message = operation .. " failed", -- 1751
								changes = changes, -- 1751
								affectedDirectories = affectedDirectories -- 1751
							} -- 1751
						end -- 1751
						changes[#changes + 1] = { -- 1752
							old = source, -- 1752
							new = destination -- 1752
						} -- 1752
					end -- 1742
				end -- 1740
				return { -- 1753
					success = true, -- 1753
					changes = changes, -- 1753
					affectedDirectories = affectedDirectories -- 1753
				} -- 1753
			end -- 1714
		end -- 1714
	end -- 1714
	return { -- 1713
		success = false, -- 1713
		message = "invalid request" -- 1713
	} -- 1713
end) -- 1713
local withProjectSearchPaths -- 1755
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1755
	local fallbackPaths = { } -- 1756
	local addFallback -- 1757
	addFallback = function(dir) -- 1757
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1757
			fallbackPaths[#fallbackPaths + 1] = dir -- 1757
		end -- 1757
	end -- 1757
	if projectRoot and projectRoot ~= "" then -- 1758
		addFallback(Path(projectRoot, "Script")) -- 1759
		addFallback(projectRoot) -- 1760
	end -- 1758
	if projFile then -- 1761
		local projDir = getProjectDirFromFile(projFile) -- 1762
		if projDir then -- 1762
			addFallback(Path(projDir, "Script")) -- 1763
			addFallback(projDir) -- 1764
		else -- 1766
			addFallback(Path:getPath(projFile)) -- 1766
		end -- 1762
	end -- 1761
	if not (#fallbackPaths > 0) then -- 1767
		return fn() -- 1767
	end -- 1767
	local searchPaths = Content.searchPaths -- 1768
	for _index_0 = 1, #fallbackPaths do -- 1769
		local dir = fallbackPaths[_index_0] -- 1769
		Content:addSearchPath(dir) -- 1769
	end -- 1769
	local _ <close> = setmetatable({ }, { -- 1770
		__close = function() -- 1770
			Content.searchPaths = searchPaths -- 1770
		end -- 1770
	}) -- 1770
	return fn() -- 1771
end -- 1755
HttpServer:post("/exist", function(req) -- 1772
	do -- 1773
		local _type_0 = type(req) -- 1773
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1773
		if _tab_0 then -- 1773
			local file -- 1773
			do -- 1773
				local _obj_0 = req.body -- 1773
				local _type_1 = type(_obj_0) -- 1773
				if "table" == _type_1 or "userdata" == _type_1 then -- 1773
					file = _obj_0.file -- 1773
				end -- 1773
			end -- 1773
			if file ~= nil then -- 1773
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1774
					return { -- 1775
						success = Content:exist(file) -- 1775
					} -- 1775
				end) -- 1774
			end -- 1773
		end -- 1773
	end -- 1773
	return { -- 1772
		success = false -- 1772
	} -- 1772
end) -- 1772
HttpServer:postSchedule("/read", function(req) -- 1776
	do -- 1777
		local _type_0 = type(req) -- 1777
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1777
		if _tab_0 then -- 1777
			local path -- 1777
			do -- 1777
				local _obj_0 = req.body -- 1777
				local _type_1 = type(_obj_0) -- 1777
				if "table" == _type_1 or "userdata" == _type_1 then -- 1777
					path = _obj_0.path -- 1777
				end -- 1777
			end -- 1777
			if path ~= nil then -- 1777
				local readFile -- 1778
				readFile = function() -- 1778
					if Content:exist(path) then -- 1779
						local content = Content:loadAsync(path) -- 1780
						if content then -- 1780
							return { -- 1781
								content = content, -- 1781
								success = true, -- 1781
								fullPath = Content:getFullPath(path) -- 1781
							} -- 1781
						end -- 1780
					end -- 1779
					return nil -- 1778
				end -- 1778
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1782
				if result then -- 1782
					return result -- 1782
				end -- 1782
			end -- 1777
		end -- 1777
	end -- 1777
	return { -- 1776
		success = false -- 1776
	} -- 1776
end) -- 1776
local agentDocLanguage -- 1784
agentDocLanguage = function(language) -- 1784
	if language == "zh-Hans" then -- 1785
		return "zh" -- 1785
	else -- 1785
		return "en" -- 1785
	end -- 1785
end -- 1784
HttpServer:postSchedule("/doc/search", function(req) -- 1787
	local body = req.body or { } -- 1788
	local language = body.docLanguage -- 1789
	if not (("en" == language or "zh-Hans" == language)) then -- 1790
		return { -- 1790
			success = false, -- 1790
			message = "unsupported doc language" -- 1790
		} -- 1790
	end -- 1790
	local source = body.docSource -- 1791
	if not (("api" == source or "tutorial" == source)) then -- 1792
		return { -- 1792
			success = false, -- 1792
			message = "unsupported doc source" -- 1792
		} -- 1792
	end -- 1792
	local codeLanguage = body.programmingLanguage -- 1793
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1794
		return { -- 1794
			success = false, -- 1794
			message = "unsupported programming language" -- 1794
		} -- 1794
	end -- 1794
	if not body.pattern then -- 1795
		return { -- 1795
			success = false, -- 1795
			message = "missing pattern" -- 1795
		} -- 1795
	end -- 1795
	local result = nil -- 1796
	AgentTools.searchDoraAPIHttp({ -- 1798
		pattern = body.pattern, -- 1798
		docLanguage = agentDocLanguage(language), -- 1799
		docSource = source, -- 1800
		programmingLanguage = codeLanguage, -- 1801
		limit = body.limit, -- 1802
		useRegex = body.useRegex, -- 1803
		caseSensitive = body.caseSensitive, -- 1804
		includeContent = body.includeContent, -- 1805
		contentWindow = body.contentWindow -- 1806
	}, function(res) -- 1807
		result = res -- 1808
	end) -- 1797
	wait(function() -- 1809
		return result ~= nil -- 1809
	end) -- 1809
	if result and result.success then -- 1810
		result.docLanguage = language -- 1811
	end -- 1810
	if result then -- 1812
		return result -- 1813
	else -- 1815
		return { -- 1815
			success = false, -- 1815
			message = "doc search failed" -- 1815
		} -- 1815
	end -- 1812
	return { -- 1787
		success = false, -- 1787
		message = "invalid call" -- 1787
	} -- 1787
end) -- 1787
HttpServer:postSchedule("/doc/read", function(req) -- 1817
	local body = req.body or { } -- 1818
	local language = body.docLanguage -- 1819
	if not (("en" == language or "zh-Hans" == language)) then -- 1820
		return { -- 1820
			success = false, -- 1820
			message = "unsupported doc language" -- 1820
		} -- 1820
	end -- 1820
	if not body.file then -- 1821
		return { -- 1821
			success = false, -- 1821
			message = "missing file" -- 1821
		} -- 1821
	end -- 1821
	local result = AgentTools.readDoraDoc({ -- 1823
		docLanguage = agentDocLanguage(language), -- 1823
		file = body.file, -- 1824
		startLine = body.startLine, -- 1825
		endLine = body.endLine -- 1826
	}) -- 1822
	if result and result.success then -- 1827
		result.docLanguage = language -- 1828
	end -- 1827
	return result -- 1829
end) -- 1817
HttpServer:get("/read-sync", function(req) -- 1831
	do -- 1832
		local _type_0 = type(req) -- 1832
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1832
		if _tab_0 then -- 1832
			local params = req.params -- 1832
			if params ~= nil then -- 1832
				local path = params.path -- 1833
				local exts -- 1834
				if params.exts then -- 1834
					local _accum_0 = { } -- 1835
					local _len_0 = 1 -- 1835
					for ext in params.exts:gmatch("[^|]*") do -- 1835
						_accum_0[_len_0] = ext -- 1835
						_len_0 = _len_0 + 1 -- 1835
					end -- 1835
					exts = _accum_0 -- 1835
				else -- 1836
					exts = { -- 1836
						"" -- 1836
					} -- 1836
				end -- 1834
				local readFileAt -- 1837
				readFileAt = function(targetPath) -- 1837
					if Content:exist(targetPath) then -- 1838
						local content = Content:load(targetPath) -- 1839
						if content then -- 1839
							return { -- 1840
								content = content, -- 1840
								success = true, -- 1840
								fullPath = Content:getFullPath(targetPath) -- 1840
							} -- 1840
						end -- 1839
					end -- 1838
					return nil -- 1837
				end -- 1837
				local readFile -- 1841
				readFile = function(fallbackPaths) -- 1841
					for _index_0 = 1, #exts do -- 1842
						local ext = exts[_index_0] -- 1842
						local targetPath = path .. ext -- 1843
						if not Content:isAbsolutePath(targetPath) then -- 1844
							for _index_1 = 1, #fallbackPaths do -- 1845
								local fallback = fallbackPaths[_index_1] -- 1845
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1846
								if fallbackResult then -- 1846
									return fallbackResult -- 1847
								end -- 1846
							end -- 1845
						end -- 1844
						local fileResult = readFileAt(targetPath) -- 1848
						if fileResult then -- 1848
							return fileResult -- 1849
						end -- 1848
					end -- 1842
					return nil -- 1841
				end -- 1841
				local fallbackPaths = { } -- 1850
				local fallbackCandidates = { } -- 1851
				do -- 1852
					local projectRoot = req.params.projectRoot -- 1852
					if projectRoot then -- 1852
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1853
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1854
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1855
						end -- 1853
					end -- 1852
				end -- 1852
				do -- 1856
					local projFile = req.params.projFile -- 1856
					if projFile then -- 1856
						local projDir = getProjectDirFromFile(projFile) -- 1857
						if projDir then -- 1857
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1858
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1859
						else -- 1861
							projDir = Path:getPath(projFile) -- 1861
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1862
						end -- 1857
					end -- 1856
				end -- 1856
				for _index_0 = 1, #fallbackCandidates do -- 1863
					local dir = fallbackCandidates[_index_0] -- 1863
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1864
						local exists = false -- 1865
						for _index_1 = 1, #fallbackPaths do -- 1866
							local fallback = fallbackPaths[_index_1] -- 1866
							if fallback == dir then -- 1867
								exists = true -- 1868
								break -- 1869
							end -- 1867
						end -- 1866
						if not exists then -- 1870
							fallbackPaths[#fallbackPaths + 1] = dir -- 1870
						end -- 1870
					end -- 1864
				end -- 1863
				local readResult = readFile(fallbackPaths) -- 1871
				if readResult then -- 1871
					return readResult -- 1872
				end -- 1871
			end -- 1832
		end -- 1832
	end -- 1832
	return { -- 1831
		success = false -- 1831
	} -- 1831
end) -- 1831
local compileFileAsync -- 1874
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1874
	if projectRoot == nil then -- 1874
		projectRoot = nil -- 1874
	end -- 1874
	local file = inputFile -- 1875
	local searchPath -- 1876
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1876
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1877
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1881
	elseif not Content:isAbsolutePath(inputFile) then -- 1882
		searchPath = "" -- 1883
	else -- 1884
		local dir = getProjectDirFromFile(inputFile) -- 1884
		if dir then -- 1884
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1885
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1889
		else -- 1891
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1891
			searchPath = "" -- 1894
		end -- 1884
	end -- 1876
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1895
	local yueext = yue.options.extension -- 1896
	local resultCodes = nil -- 1897
	local resultError = nil -- 1898
	do -- 1899
		local _exp_0 = Path:getExt(inputFile) -- 1899
		if yueext == _exp_0 then -- 1899
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1900
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1901
				if not codes then -- 1902
					resultError = err -- 1903
					return -- 1904
				end -- 1902
				local extraGlobal -- 1905
				if isTIC80 then -- 1905
					extraGlobal = tic80APIs -- 1905
				else -- 1905
					extraGlobal = nil -- 1905
				end -- 1905
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1906
				if not success then -- 1907
					resultError = message -- 1908
					return -- 1909
				end -- 1907
				if codes == "" then -- 1910
					resultCodes = "" -- 1911
					return nil -- 1912
				end -- 1910
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1913
				return resultCodes -- 1914
			end, function(success) -- 1901
				if not success then -- 1915
					Content:remove(outputFile) -- 1916
					if resultCodes == nil then -- 1917
						resultCodes = false -- 1918
					end -- 1917
				end -- 1915
			end) -- 1901
		elseif "tl" == _exp_0 then -- 1919
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1920
			if isTIC80 then -- 1921
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1922
			end -- 1921
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1923
			if codes then -- 1923
				if isTIC80 then -- 1924
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1925
				end -- 1924
				resultCodes = codes -- 1926
				Content:saveAsync(outputFile, codes) -- 1927
			else -- 1929
				Content:remove(outputFile) -- 1929
				resultCodes = false -- 1930
				resultError = err -- 1931
			end -- 1923
		elseif "xml" == _exp_0 then -- 1932
			local codes, err = xml.tolua(sourceCodes) -- 1933
			if codes then -- 1933
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1934
				Content:saveAsync(outputFile, resultCodes) -- 1935
			else -- 1937
				Content:remove(outputFile) -- 1937
				resultCodes = false -- 1938
				resultError = err -- 1939
			end -- 1933
		end -- 1899
	end -- 1899
	wait(function() -- 1940
		return resultCodes ~= nil -- 1940
	end) -- 1940
	if resultCodes then -- 1941
		return resultCodes -- 1942
	else -- 1944
		return nil, resultError -- 1944
	end -- 1941
	return nil -- 1874
end -- 1874
HttpServer:postSchedule("/write", function(req) -- 1946
	do -- 1947
		local _type_0 = type(req) -- 1947
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1947
		if _tab_0 then -- 1947
			local path -- 1947
			do -- 1947
				local _obj_0 = req.body -- 1947
				local _type_1 = type(_obj_0) -- 1947
				if "table" == _type_1 or "userdata" == _type_1 then -- 1947
					path = _obj_0.path -- 1947
				end -- 1947
			end -- 1947
			local content -- 1947
			do -- 1947
				local _obj_0 = req.body -- 1947
				local _type_1 = type(_obj_0) -- 1947
				if "table" == _type_1 or "userdata" == _type_1 then -- 1947
					content = _obj_0.content -- 1947
				end -- 1947
			end -- 1947
			if path ~= nil and content ~= nil then -- 1947
				if Content:saveAsync(path, content) then -- 1948
					do -- 1949
						local _exp_0 = Path:getExt(path) -- 1949
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1949
							if '' == Path:getExt(Path:getName(path)) then -- 1950
								local resultCodes = compileFileAsync(path, content) -- 1951
								return { -- 1952
									success = true, -- 1952
									resultCodes = resultCodes -- 1952
								} -- 1952
							end -- 1950
						end -- 1949
					end -- 1949
					return { -- 1953
						success = true -- 1953
					} -- 1953
				end -- 1948
			end -- 1947
		end -- 1947
	end -- 1947
	return { -- 1946
		success = false -- 1946
	} -- 1946
end) -- 1946
local getWaProjectDirFromFile = nil -- 1955
HttpServer:postSchedule("/build", function(req) -- 1957
	do -- 1958
		local _type_0 = type(req) -- 1958
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1958
		if _tab_0 then -- 1958
			local path -- 1958
			do -- 1958
				local _obj_0 = req.body -- 1958
				local _type_1 = type(_obj_0) -- 1958
				if "table" == _type_1 or "userdata" == _type_1 then -- 1958
					path = _obj_0.path -- 1958
				end -- 1958
			end -- 1958
			if path ~= nil then -- 1958
				local projectRoot = req.body.projectRoot -- 1959
				if Content:isdir(path) then -- 1960
					local projDir = getWaProjectDirFromFile(path) -- 1961
					if projDir then -- 1961
						local message = Wasm:buildWaAsync(projDir) -- 1962
						if message == "" then -- 1963
							return { -- 1964
								success = true -- 1964
							} -- 1964
						else -- 1966
							return { -- 1966
								success = false, -- 1966
								message = message -- 1966
							} -- 1966
						end -- 1963
					end -- 1961
				end -- 1960
				local _exp_0 = Path:getExt(path) -- 1967
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1968
					if '' == Path:getExt(Path:getName(path)) then -- 1969
						local content = Content:loadAsync(path) -- 1970
						if content then -- 1970
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 1971
							if resultCodes then -- 1971
								return { -- 1972
									success = true, -- 1972
									resultCodes = resultCodes -- 1972
								} -- 1972
							end -- 1971
						end -- 1970
					end -- 1969
				elseif "wa" == _exp_0 then -- 1973
					local projDir = getWaProjectDirFromFile(path) -- 1974
					if projDir then -- 1974
						local message = Wasm:buildWaAsync(projDir) -- 1975
						if message == "" then -- 1976
							return { -- 1977
								success = true -- 1977
							} -- 1977
						else -- 1979
							return { -- 1979
								success = false, -- 1979
								message = message -- 1979
							} -- 1979
						end -- 1976
					else -- 1981
						return { -- 1981
							success = false, -- 1981
							message = 'Wa file needs a project' -- 1981
						} -- 1981
					end -- 1974
				end -- 1967
			end -- 1958
		end -- 1958
	end -- 1958
	return { -- 1957
		success = false -- 1957
	} -- 1957
end) -- 1957
local extentionLevels = { -- 1984
	vs = 2, -- 1984
	bl = 2, -- 1985
	ts = 1, -- 1986
	tsx = 1, -- 1987
	tl = 1, -- 1988
	yue = 1, -- 1989
	xml = 1, -- 1990
	lua = 0 -- 1991
} -- 1983
local visitAssets -- 1993
visitAssets = function(path, workspace, builtin, recursive) -- 1993
	if recursive == nil then -- 1993
		recursive = true -- 1993
	end -- 1993
	local children = nil -- 1994
	local dirs = Content:getDirs(path) -- 1995
	for _index_0 = 1, #dirs do -- 1996
		local dir = dirs[_index_0] -- 1996
		if workspace then -- 1997
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 1998
				goto _continue_0 -- 1999
			end -- 1998
		elseif dir == ".git" then -- 2000
			goto _continue_0 -- 2001
		end -- 1997
		if not children then -- 2002
			children = { } -- 2002
		end -- 2002
		local dirPath = Path(path, dir) -- 2003
		if recursive then -- 2004
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2005
		else -- 2007
			children[#children + 1] = { -- 2008
				key = dirPath, -- 2008
				dir = true, -- 2009
				title = dir, -- 2010
				builtin = builtin, -- 2011
				isLeaf = false -- 2012
			} -- 2007
		end -- 2004
		::_continue_0:: -- 1997
	end -- 1996
	local files = Content:getFiles(path) -- 2014
	local names = { } -- 2015
	for _index_0 = 1, #files do -- 2016
		local file = files[_index_0] -- 2016
		if (".DS_Store" == file) then -- 2017
			goto _continue_1 -- 2018
		end -- 2017
		local name = Path:getName(file) -- 2019
		local ext = names[name] -- 2020
		if ext then -- 2020
			local lv1 -- 2021
			do -- 2021
				local _exp_0 = extentionLevels[ext] -- 2021
				if _exp_0 ~= nil then -- 2021
					lv1 = _exp_0 -- 2021
				else -- 2021
					lv1 = -1 -- 2021
				end -- 2021
			end -- 2021
			ext = Path:getExt(file) -- 2022
			local lv2 -- 2023
			do -- 2023
				local _exp_0 = extentionLevels[ext] -- 2023
				if _exp_0 ~= nil then -- 2023
					lv2 = _exp_0 -- 2023
				else -- 2023
					lv2 = -1 -- 2023
				end -- 2023
			end -- 2023
			if lv2 > lv1 then -- 2024
				names[name] = ext -- 2025
			elseif lv2 == lv1 then -- 2026
				names[name .. '.' .. ext] = "" -- 2027
			end -- 2024
		else -- 2029
			ext = Path:getExt(file) -- 2029
			if not extentionLevels[ext] then -- 2030
				names[file] = "" -- 2031
			else -- 2033
				names[name] = ext -- 2033
			end -- 2030
		end -- 2020
		::_continue_1:: -- 2017
	end -- 2016
	do -- 2034
		local _accum_0 = { } -- 2034
		local _len_0 = 1 -- 2034
		for name, ext in pairs(names) do -- 2034
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2034
			_len_0 = _len_0 + 1 -- 2034
		end -- 2034
		files = _accum_0 -- 2034
	end -- 2034
	for _index_0 = 1, #files do -- 2035
		local file = files[_index_0] -- 2035
		if not children then -- 2036
			children = { } -- 2036
		end -- 2036
		children[#children + 1] = { -- 2038
			key = Path(path, file), -- 2038
			dir = false, -- 2039
			title = file, -- 2040
			builtin = builtin -- 2041
		} -- 2037
	end -- 2035
	if children then -- 2043
		table.sort(children, function(a, b) -- 2044
			if a.dir == b.dir then -- 2045
				return a.title < b.title -- 2046
			else -- 2048
				return a.dir -- 2048
			end -- 2045
		end) -- 2044
	end -- 2043
	return { -- 2050
		key = path, -- 2050
		dir = true, -- 2051
		title = Path:getFilename(path), -- 2052
		builtin = builtin, -- 2053
		isLeaf = not children, -- 2054
		children = children -- 2055
	} -- 2049
end -- 1993
HttpServer:post("/assets/children", function(req) -- 2058
	do -- 2059
		local _type_0 = type(req) -- 2059
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2059
		if _tab_0 then -- 2059
			local path -- 2059
			do -- 2059
				local _obj_0 = req.body -- 2059
				local _type_1 = type(_obj_0) -- 2059
				if "table" == _type_1 or "userdata" == _type_1 then -- 2059
					path = _obj_0.path -- 2059
				end -- 2059
			end -- 2059
			if path ~= nil then -- 2059
				if not (relativeToRoot(path, Content.writablePath) ~= nil) then -- 2060
					return { -- 2060
						success = false -- 2060
					} -- 2060
				end -- 2060
				if not (Content:exist(path) and Content:isdir(path)) then -- 2061
					return { -- 2061
						success = false -- 2061
					} -- 2061
				end -- 2061
				local node = visitAssets(path, true, nil, false) -- 2062
				return { -- 2063
					success = true, -- 2063
					children = node.children or { } -- 2063
				} -- 2063
			end -- 2059
		end -- 2059
	end -- 2059
	return { -- 2058
		success = false -- 2058
	} -- 2058
end) -- 2058
HttpServer:post("/assets/files", function(req) -- 2065
	do -- 2066
		local _type_0 = type(req) -- 2066
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2066
		if _tab_0 then -- 2066
			local path -- 2066
			do -- 2066
				local _obj_0 = req.body -- 2066
				local _type_1 = type(_obj_0) -- 2066
				if "table" == _type_1 or "userdata" == _type_1 then -- 2066
					path = _obj_0.path -- 2066
				end -- 2066
			end -- 2066
			if path ~= nil then -- 2066
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2067
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2068
				if not (workspace or builtin) then -- 2069
					return { -- 2069
						success = false -- 2069
					} -- 2069
				end -- 2069
				if not (Content:exist(path) and Content:isdir(path)) then -- 2070
					return { -- 2070
						success = false -- 2070
					} -- 2070
				end -- 2070
				local node = visitAssets(path, workspace, builtin, true) -- 2071
				local files = { } -- 2072
				local visit -- 2073
				visit = function(item) -- 2073
					if item.dir then -- 2074
						if item.children then -- 2075
							local _list_0 = item.children -- 2076
							for _index_0 = 1, #_list_0 do -- 2076
								local child = _list_0[_index_0] -- 2076
								visit(child) -- 2077
							end -- 2076
						end -- 2075
					else -- 2079
						files[#files + 1] = item.key -- 2079
					end -- 2074
				end -- 2073
				visit(node) -- 2080
				return { -- 2081
					success = true, -- 2081
					files = files -- 2081
				} -- 2081
			end -- 2066
		end -- 2066
	end -- 2066
	return { -- 2065
		success = false -- 2065
	} -- 2065
end) -- 2065
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2122
	local _tab_0 = { -- 2122
		{ -- 2123
			key = Path(Content.assetPath), -- 2123
			dir = true, -- 2124
			builtin = true, -- 2125
			title = zh and "内置资源" or "Built-in", -- 2126
			children = builtinChildren -- 2127
		} -- 2122
	} -- 2129
	local _obj_0 = workspace.children or { } -- 2129
	local _idx_0 = #_tab_0 + 1 -- 2129
	for _index_0 = 1, #_obj_0 do -- 2129
		local _value_0 = _obj_0[_index_0] -- 2129
		_tab_0[_idx_0] = _value_0 -- 2129
		_idx_0 = _idx_0 + 1 -- 2129
	end -- 2129
	return _tab_0 -- 2122
end -- 2122
HttpServer:post("/assets", function() -- 2083
	local Entry = require("Script.Dev.Entry") -- 2084
	local engineDev = Entry.getEngineDev() -- 2085
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2086
	local zh = (App.locale:match("^zh") ~= nil) -- 2087
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2088
	readme.title = zh and "说明文档" or "Readme" -- 2089
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2090
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2091
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2092
	tools.title = zh and "开发工具" or "Tools" -- 2093
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2094
	font.title = zh and "字体" or "Font" -- 2095
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2096
	lib.title = zh and "程序库" or "Lib" -- 2097
	if engineDev then -- 2098
		local _list_0 = lib.children -- 2099
		for _index_0 = 1, #_list_0 do -- 2099
			local child = _list_0[_index_0] -- 2099
			if not (child.title == "Dora") then -- 2100
				goto _continue_0 -- 2100
			end -- 2100
			local title = zh and "zh-Hans" or "en" -- 2101
			do -- 2102
				local _accum_0 = { } -- 2102
				local _len_0 = 1 -- 2102
				local _list_1 = child.children -- 2102
				for _index_1 = 1, #_list_1 do -- 2102
					local c = _list_1[_index_1] -- 2102
					if c.title ~= title then -- 2102
						_accum_0[_len_0] = c -- 2102
						_len_0 = _len_0 + 1 -- 2102
					end -- 2102
				end -- 2102
				child.children = _accum_0 -- 2102
			end -- 2102
			break -- 2103
			::_continue_0:: -- 2100
		end -- 2099
	else -- 2105
		local _accum_0 = { } -- 2105
		local _len_0 = 1 -- 2105
		local _list_0 = lib.children -- 2105
		for _index_0 = 1, #_list_0 do -- 2105
			local child = _list_0[_index_0] -- 2105
			if child.title ~= "Dora" then -- 2105
				_accum_0[_len_0] = child -- 2105
				_len_0 = _len_0 + 1 -- 2105
			end -- 2105
		end -- 2105
		lib.children = _accum_0 -- 2105
	end -- 2098
	local builtinChildren = { -- 2106
		readme, -- 2106
		apiDoc, -- 2106
		tools, -- 2106
		font, -- 2106
		lib -- 2106
	} -- 2106
	if engineDev then -- 2107
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2108
		do -- 2109
			local _obj_0 = dev.children -- 2109
			_obj_0[#_obj_0 + 1] = { -- 2110
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2110
				dir = false, -- 2111
				builtin = true, -- 2112
				title = "init.yue" -- 2113
			} -- 2109
		end -- 2109
		builtinChildren[#builtinChildren + 1] = dev -- 2115
	end -- 2107
	return { -- 2117
		key = Content.writablePath, -- 2117
		dir = true, -- 2118
		root = true, -- 2119
		title = "Assets", -- 2120
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2121
	} -- 2116
end) -- 2083
HttpServer:post("/entry/list", function() -- 2133
	local Entry = require("Script.Dev.Entry") -- 2134
	local res = Entry.getLaunchEntries() -- 2135
	res.success = true -- 2136
	return res -- 2137
end) -- 2133
HttpServer:post("/run/status", function() -- 2139
	local Entry = require("Script.Dev.Entry") -- 2140
	return Entry.getCurrentEntryStatus() -- 2141
end) -- 2139
HttpServer:postSchedule("/run", function(req) -- 2143
	do -- 2144
		local _type_0 = type(req) -- 2144
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2144
		if _tab_0 then -- 2144
			local file -- 2144
			do -- 2144
				local _obj_0 = req.body -- 2144
				local _type_1 = type(_obj_0) -- 2144
				if "table" == _type_1 or "userdata" == _type_1 then -- 2144
					file = _obj_0.file -- 2144
				end -- 2144
			end -- 2144
			local asProj -- 2144
			do -- 2144
				local _obj_0 = req.body -- 2144
				local _type_1 = type(_obj_0) -- 2144
				if "table" == _type_1 or "userdata" == _type_1 then -- 2144
					asProj = _obj_0.asProj -- 2144
				end -- 2144
			end -- 2144
			if file ~= nil and asProj ~= nil then -- 2144
				if not Content:isAbsolutePath(file) then -- 2145
					local devFile = Path(Content.writablePath, file) -- 2146
					if Content:exist(devFile) then -- 2147
						file = devFile -- 2147
					end -- 2147
				end -- 2145
				local Entry = require("Script.Dev.Entry") -- 2148
				local workDir -- 2149
				if asProj then -- 2150
					local projectRoot = req.body.projectRoot -- 2151
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2152
						workDir = projectRoot -- 2153
					else -- 2155
						workDir = getProjectDirFromFile(file) -- 2155
					end -- 2152
					if workDir then -- 2156
						Entry.allClear() -- 2157
						local target = Path(workDir, "init") -- 2158
						local success, err = Entry.enterEntryAsync({ -- 2159
							entryName = "Project", -- 2159
							fileName = target, -- 2159
							workDir = workDir, -- 2159
							projectRoot = workDir, -- 2159
							runKind = "project" -- 2159
						}) -- 2159
						target = Path:getName(Path:getPath(target)) -- 2160
						return { -- 2161
							success = success, -- 2161
							target = target, -- 2161
							err = err -- 2161
						} -- 2161
					end -- 2156
				else -- 2163
					workDir = getProjectDirFromFile(file) -- 2163
					if not workDir and Path:getExt(file) == "wasm" then -- 2164
						local parent = Path:getPath(file) -- 2165
						if Content:exist(Path(parent, "wa.mod")) then -- 2166
							workDir = parent -- 2167
						end -- 2166
					end -- 2164
				end -- 2150
				Entry.allClear() -- 2168
				file = Path:replaceExt(file, "") -- 2169
				local entry = { -- 2171
					entryName = Path:getName(file), -- 2171
					fileName = file, -- 2172
					runKind = "file" -- 2173
				} -- 2170
				if workDir then -- 2174
					entry.workDir = workDir -- 2175
					entry.projectRoot = workDir -- 2176
				end -- 2174
				local success, err = Entry.enterEntryAsync(entry) -- 2177
				return { -- 2178
					success = success, -- 2178
					err = err -- 2178
				} -- 2178
			end -- 2144
		end -- 2144
	end -- 2144
	return { -- 2143
		success = false -- 2143
	} -- 2143
end) -- 2143
HttpServer:postSchedule("/stop", function() -- 2180
	local Entry = require("Script.Dev.Entry") -- 2181
	return { -- 2182
		success = Entry.stop() -- 2182
	} -- 2182
end) -- 2180
local minifyAsync -- 2184
minifyAsync = function(sourcePath, minifyPath) -- 2184
	if not Content:exist(sourcePath) then -- 2185
		return -- 2185
	end -- 2185
	local Entry = require("Script.Dev.Entry") -- 2186
	local errors = { } -- 2187
	local files = Entry.getAllFiles(sourcePath, { -- 2188
		"lua" -- 2188
	}, true) -- 2188
	do -- 2189
		local _accum_0 = { } -- 2189
		local _len_0 = 1 -- 2189
		for _index_0 = 1, #files do -- 2189
			local file = files[_index_0] -- 2189
			if file:sub(1, 1) ~= '.' then -- 2189
				_accum_0[_len_0] = file -- 2189
				_len_0 = _len_0 + 1 -- 2189
			end -- 2189
		end -- 2189
		files = _accum_0 -- 2189
	end -- 2189
	local paths -- 2190
	do -- 2190
		local _tbl_0 = { } -- 2190
		for _index_0 = 1, #files do -- 2190
			local file = files[_index_0] -- 2190
			_tbl_0[Path:getPath(file)] = true -- 2190
		end -- 2190
		paths = _tbl_0 -- 2190
	end -- 2190
	for path in pairs(paths) do -- 2191
		Content:mkdir(Path(minifyPath, path)) -- 2191
	end -- 2191
	local _ <close> = setmetatable({ }, { -- 2192
		__close = function() -- 2192
			package.loaded["luaminify.FormatMini"] = nil -- 2193
			package.loaded["luaminify.ParseLua"] = nil -- 2194
			package.loaded["luaminify.Scope"] = nil -- 2195
			package.loaded["luaminify.Util"] = nil -- 2196
		end -- 2192
	}) -- 2192
	local FormatMini -- 2197
	do -- 2197
		local _obj_0 = require("luaminify") -- 2197
		FormatMini = _obj_0.FormatMini -- 2197
	end -- 2197
	local fileCount = #files -- 2198
	local count = 0 -- 2199
	for _index_0 = 1, #files do -- 2200
		local file = files[_index_0] -- 2200
		thread(function() -- 2201
			local _ <close> = setmetatable({ }, { -- 2202
				__close = function() -- 2202
					count = count + 1 -- 2202
				end -- 2202
			}) -- 2202
			local input = Path(sourcePath, file) -- 2203
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2204
			if Content:exist(input) then -- 2205
				local sourceCodes = Content:loadAsync(input) -- 2206
				local res, err = FormatMini(sourceCodes) -- 2207
				if res then -- 2208
					Content:saveAsync(output, res) -- 2209
					return print("Minify " .. tostring(file)) -- 2210
				else -- 2212
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2212
				end -- 2208
			else -- 2214
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2214
			end -- 2205
		end) -- 2201
		sleep() -- 2215
	end -- 2200
	wait(function() -- 2216
		return count == fileCount -- 2216
	end) -- 2216
	if #errors > 0 then -- 2217
		print(table.concat(errors, '\n')) -- 2218
	end -- 2217
	print("Obfuscation done.") -- 2219
	return files -- 2220
end -- 2184
local zipping = false -- 2222
HttpServer:postSchedule("/zip", function(req) -- 2224
	do -- 2225
		local _type_0 = type(req) -- 2225
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2225
		if _tab_0 then -- 2225
			local path -- 2225
			do -- 2225
				local _obj_0 = req.body -- 2225
				local _type_1 = type(_obj_0) -- 2225
				if "table" == _type_1 or "userdata" == _type_1 then -- 2225
					path = _obj_0.path -- 2225
				end -- 2225
			end -- 2225
			local zipFile -- 2225
			do -- 2225
				local _obj_0 = req.body -- 2225
				local _type_1 = type(_obj_0) -- 2225
				if "table" == _type_1 or "userdata" == _type_1 then -- 2225
					zipFile = _obj_0.zipFile -- 2225
				end -- 2225
			end -- 2225
			local obfuscated -- 2225
			do -- 2225
				local _obj_0 = req.body -- 2225
				local _type_1 = type(_obj_0) -- 2225
				if "table" == _type_1 or "userdata" == _type_1 then -- 2225
					obfuscated = _obj_0.obfuscated -- 2225
				end -- 2225
			end -- 2225
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2225
				if zipping then -- 2226
					goto failed -- 2226
				end -- 2226
				zipping = true -- 2227
				local _ <close> = setmetatable({ }, { -- 2228
					__close = function() -- 2228
						zipping = false -- 2228
					end -- 2228
				}) -- 2228
				if not Content:exist(path) then -- 2229
					goto failed -- 2229
				end -- 2229
				Content:mkdir(Path:getPath(zipFile)) -- 2230
				if obfuscated then -- 2231
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2232
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2233
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2234
					Content:remove(scriptPath) -- 2235
					Content:remove(obfuscatedPath) -- 2236
					Content:remove(tempPath) -- 2237
					Content:mkdir(scriptPath) -- 2238
					Content:mkdir(obfuscatedPath) -- 2239
					Content:mkdir(tempPath) -- 2240
					if not Content:copyAsync(path, tempPath) then -- 2241
						goto failed -- 2241
					end -- 2241
					local Entry = require("Script.Dev.Entry") -- 2242
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2243
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2244
						"tl", -- 2244
						"yue", -- 2244
						"lua", -- 2244
						"ts", -- 2244
						"tsx", -- 2244
						"vs", -- 2244
						"bl", -- 2244
						"xml", -- 2244
						"wa", -- 2244
						"mod" -- 2244
					}, true) -- 2244
					for _index_0 = 1, #scriptFiles do -- 2245
						local file = scriptFiles[_index_0] -- 2245
						Content:remove(Path(tempPath, file)) -- 2246
					end -- 2245
					for _index_0 = 1, #luaFiles do -- 2247
						local file = luaFiles[_index_0] -- 2247
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2248
					end -- 2247
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2249
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2250
					end) then -- 2249
						goto failed -- 2249
					end -- 2249
					return { -- 2251
						success = true -- 2251
					} -- 2251
				else -- 2253
					return { -- 2253
						success = Content:zipAsync(path, zipFile, function(file) -- 2253
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2254
						end) -- 2253
					} -- 2253
				end -- 2231
			end -- 2225
		end -- 2225
	end -- 2225
	::failed:: -- 2255
	return { -- 2224
		success = false -- 2224
	} -- 2224
end) -- 2224
HttpServer:postSchedule("/unzip", function(req) -- 2257
	do -- 2258
		local _type_0 = type(req) -- 2258
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2258
		if _tab_0 then -- 2258
			local zipFile -- 2258
			do -- 2258
				local _obj_0 = req.body -- 2258
				local _type_1 = type(_obj_0) -- 2258
				if "table" == _type_1 or "userdata" == _type_1 then -- 2258
					zipFile = _obj_0.zipFile -- 2258
				end -- 2258
			end -- 2258
			local path -- 2258
			do -- 2258
				local _obj_0 = req.body -- 2258
				local _type_1 = type(_obj_0) -- 2258
				if "table" == _type_1 or "userdata" == _type_1 then -- 2258
					path = _obj_0.path -- 2258
				end -- 2258
			end -- 2258
			if zipFile ~= nil and path ~= nil then -- 2258
				return { -- 2259
					success = Content:unzipAsync(zipFile, path, function(file) -- 2259
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2260
					end) -- 2259
				} -- 2259
			end -- 2258
		end -- 2258
	end -- 2258
	return { -- 2257
		success = false -- 2257
	} -- 2257
end) -- 2257
HttpServer:post("/editing-info", function(req) -- 2262
	local Entry = require("Script.Dev.Entry") -- 2263
	local config = Entry.getConfig() -- 2264
	local _type_0 = type(req) -- 2265
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2265
	local _match_0 = false -- 2265
	if _tab_0 then -- 2265
		local editingInfo -- 2265
		do -- 2265
			local _obj_0 = req.body -- 2265
			local _type_1 = type(_obj_0) -- 2265
			if "table" == _type_1 or "userdata" == _type_1 then -- 2265
				editingInfo = _obj_0.editingInfo -- 2265
			end -- 2265
		end -- 2265
		if editingInfo ~= nil then -- 2265
			_match_0 = true -- 2265
			config.editingInfo = editingInfo -- 2266
			return { -- 2267
				success = true -- 2267
			} -- 2267
		end -- 2265
	end -- 2265
	if not _match_0 then -- 2265
		if not (config.editingInfo ~= nil) then -- 2269
			local folder -- 2270
			if App.locale:match('^zh') then -- 2270
				folder = 'zh-Hans' -- 2270
			else -- 2270
				folder = 'en' -- 2270
			end -- 2270
			config.editingInfo = json.encode({ -- 2272
				index = 0, -- 2272
				files = { -- 2274
					{ -- 2275
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2275
						title = "welcome.md" -- 2276
					} -- 2274
				} -- 2273
			}) -- 2271
		end -- 2269
		return { -- 2280
			success = true, -- 2280
			editingInfo = config.editingInfo -- 2280
		} -- 2280
	end -- 2265
end) -- 2262
HttpServer:post("/command", function(req) -- 2282
	do -- 2283
		local _type_0 = type(req) -- 2283
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2283
		if _tab_0 then -- 2283
			local code -- 2283
			do -- 2283
				local _obj_0 = req.body -- 2283
				local _type_1 = type(_obj_0) -- 2283
				if "table" == _type_1 or "userdata" == _type_1 then -- 2283
					code = _obj_0.code -- 2283
				end -- 2283
			end -- 2283
			local log -- 2283
			do -- 2283
				local _obj_0 = req.body -- 2283
				local _type_1 = type(_obj_0) -- 2283
				if "table" == _type_1 or "userdata" == _type_1 then -- 2283
					log = _obj_0.log -- 2283
				end -- 2283
			end -- 2283
			if code ~= nil and log ~= nil then -- 2283
				emit("AppCommand", code, log) -- 2284
				return { -- 2285
					success = true -- 2285
				} -- 2285
			end -- 2283
		end -- 2283
	end -- 2283
	return { -- 2282
		success = false -- 2282
	} -- 2282
end) -- 2282
HttpServer:post("/log/save", function() -- 2287
	local folder = ".download" -- 2288
	local fullLogFile = "dora_full_logs.txt" -- 2289
	local fullFolder = Path(Content.writablePath, folder) -- 2290
	Content:mkdir(fullFolder) -- 2291
	local logPath = Path(fullFolder, fullLogFile) -- 2292
	if App:saveLog(logPath) then -- 2293
		return { -- 2294
			success = true, -- 2294
			path = Path(folder, fullLogFile) -- 2294
		} -- 2294
	end -- 2293
	return { -- 2287
		success = false -- 2287
	} -- 2287
end) -- 2287
local tailLines -- 2296
tailLines = function(text, count) -- 2296
	local lines = { } -- 2297
	text = text:gsub("\r\n", "\n") -- 2298
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2299
		lines[#lines + 1] = line -- 2300
	end -- 2299
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2301
		table.remove(lines) -- 2302
	end -- 2301
	local start = math.max(1, #lines - count + 1) -- 2303
	local out = { } -- 2304
	for i = start, #lines do -- 2305
		out[#out + 1] = lines[i] -- 2306
	end -- 2305
	return table.concat(out, "\n") -- 2307
end -- 2296
HttpServer:post("/log", function(req) -- 2309
	local count = 100 -- 2310
	if req and req.body and req.body.count ~= nil then -- 2311
		count = req.body.count -- 2312
	end -- 2311
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2313
		return { -- 2314
			success = false, -- 2314
			message = "count must be a positive integer" -- 2314
		} -- 2314
	end -- 2313
	local folder = ".download" -- 2315
	local fullLogFile = "dora_full_logs.txt" -- 2316
	local fullFolder = Path(Content.writablePath, folder) -- 2317
	Content:mkdir(fullFolder) -- 2318
	local logPath = Path(fullFolder, fullLogFile) -- 2319
	if App:saveLog(logPath) then -- 2320
		local text = Content:load(logPath) -- 2321
		if text then -- 2322
			return { -- 2323
				success = true, -- 2323
				log = tailLines(text, count) -- 2323
			} -- 2323
		else -- 2325
			return { -- 2325
				success = false, -- 2325
				message = "failed to read log" -- 2325
			} -- 2325
		end -- 2322
	else -- 2327
		return { -- 2327
			success = false, -- 2327
			message = "failed to save log" -- 2327
		} -- 2327
	end -- 2320
	return { -- 2309
		success = false -- 2309
	} -- 2309
end) -- 2309
HttpServer:post("/yarn/check", function(req) -- 2329
	local yarncompile = require("yarncompile") -- 2330
	do -- 2331
		local _type_0 = type(req) -- 2331
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2331
		if _tab_0 then -- 2331
			local code -- 2331
			do -- 2331
				local _obj_0 = req.body -- 2331
				local _type_1 = type(_obj_0) -- 2331
				if "table" == _type_1 or "userdata" == _type_1 then -- 2331
					code = _obj_0.code -- 2331
				end -- 2331
			end -- 2331
			if code ~= nil then -- 2331
				local jsonObject = json.decode(code) -- 2332
				if jsonObject then -- 2332
					local errors = { } -- 2333
					local _list_0 = jsonObject.nodes -- 2334
					for _index_0 = 1, #_list_0 do -- 2334
						local node = _list_0[_index_0] -- 2334
						local title, body = node.title, node.body -- 2335
						local luaCode, err = yarncompile(body) -- 2336
						if not luaCode then -- 2336
							errors[#errors + 1] = title .. ":" .. err -- 2337
						end -- 2336
					end -- 2334
					return { -- 2338
						success = true, -- 2338
						syntaxError = table.concat(errors, "\n\n") -- 2338
					} -- 2338
				end -- 2332
			end -- 2331
		end -- 2331
	end -- 2331
	return { -- 2329
		success = false -- 2329
	} -- 2329
end) -- 2329
HttpServer:post("/yarn/check-file", function(req) -- 2340
	local yarncompile = require("yarncompile") -- 2341
	do -- 2342
		local _type_0 = type(req) -- 2342
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2342
		if _tab_0 then -- 2342
			local code -- 2342
			do -- 2342
				local _obj_0 = req.body -- 2342
				local _type_1 = type(_obj_0) -- 2342
				if "table" == _type_1 or "userdata" == _type_1 then -- 2342
					code = _obj_0.code -- 2342
				end -- 2342
			end -- 2342
			if code ~= nil then -- 2342
				local res, _, err = yarncompile(code, true) -- 2343
				if not res then -- 2343
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2344
					return { -- 2345
						success = false, -- 2345
						message = message, -- 2345
						line = line, -- 2345
						column = column, -- 2345
						node = node -- 2345
					} -- 2345
				end -- 2343
			end -- 2342
		end -- 2342
	end -- 2342
	return { -- 2340
		success = true -- 2340
	} -- 2340
end) -- 2340
getWaProjectDirFromFile = function(file) -- 2347
	local current -- 2348
	if Content:isdir(file) then -- 2348
		current = file -- 2348
	else -- 2348
		current = Path:getPath(file) -- 2348
	end -- 2348
	if current == "" then -- 2349
		return nil -- 2349
	end -- 2349
	repeat -- 2350
		local modPath = Path(current, "wa.mod") -- 2351
		if Content:exist(modPath) then -- 2352
			return current, modPath -- 2353
		end -- 2352
		local parent = Path:getPath(current) -- 2354
		if parent == "" or parent == current then -- 2355
			break -- 2355
		end -- 2355
		current = parent -- 2356
	until false -- 2350
	return nil -- 2358
end -- 2347
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2360
	do -- 2361
		local _type_0 = type(req) -- 2361
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2361
		if _tab_0 then -- 2361
			local path -- 2361
			do -- 2361
				local _obj_0 = req.body -- 2361
				local _type_1 = type(_obj_0) -- 2361
				if "table" == _type_1 or "userdata" == _type_1 then -- 2361
					path = _obj_0.path -- 2361
				end -- 2361
			end -- 2361
			if path ~= nil then -- 2361
				local projDir = getWaProjectDirFromFile(path) -- 2362
				if projDir then -- 2362
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2363
					if not Content:exist(sourceDoraPath) then -- 2364
						return { -- 2365
							success = false, -- 2365
							message = "missing dora template" -- 2365
						} -- 2365
					end -- 2364
					local targetVendorPath = Path(projDir, "vendor") -- 2366
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2367
					if not Content:exist(targetVendorPath) then -- 2368
						if not Content:mkdir(targetVendorPath) then -- 2369
							return { -- 2370
								success = false, -- 2370
								message = "failed to create vendor folder" -- 2370
							} -- 2370
						end -- 2369
					elseif not Content:isdir(targetVendorPath) then -- 2371
						return { -- 2372
							success = false, -- 2372
							message = "vendor path is not a folder" -- 2372
						} -- 2372
					end -- 2368
					if Content:exist(targetDoraPath) then -- 2373
						if not Content:remove(targetDoraPath) then -- 2374
							return { -- 2375
								success = false, -- 2375
								message = "failed to remove old dora" -- 2375
							} -- 2375
						end -- 2374
					end -- 2373
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2376
						return { -- 2377
							success = false, -- 2377
							message = "failed to copy dora" -- 2377
						} -- 2377
					end -- 2376
					return { -- 2378
						success = true -- 2378
					} -- 2378
				else -- 2380
					return { -- 2380
						success = false, -- 2380
						message = 'Wa file needs a project' -- 2380
					} -- 2380
				end -- 2362
			end -- 2361
		end -- 2361
	end -- 2361
	return { -- 2360
		success = false, -- 2360
		message = "invalid call" -- 2360
	} -- 2360
end) -- 2360
HttpServer:postSchedule("/wa/build", function(req) -- 2382
	do -- 2383
		local _type_0 = type(req) -- 2383
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2383
		if _tab_0 then -- 2383
			local path -- 2383
			do -- 2383
				local _obj_0 = req.body -- 2383
				local _type_1 = type(_obj_0) -- 2383
				if "table" == _type_1 or "userdata" == _type_1 then -- 2383
					path = _obj_0.path -- 2383
				end -- 2383
			end -- 2383
			if path ~= nil then -- 2383
				local projDir = getWaProjectDirFromFile(path) -- 2384
				if projDir then -- 2384
					local message = Wasm:buildWaAsync(projDir) -- 2385
					if message == "" then -- 2386
						return { -- 2387
							success = true -- 2387
						} -- 2387
					else -- 2389
						return { -- 2389
							success = false, -- 2389
							message = message -- 2389
						} -- 2389
					end -- 2386
				else -- 2391
					return { -- 2391
						success = false, -- 2391
						message = 'Wa file needs a project' -- 2391
					} -- 2391
				end -- 2384
			end -- 2383
		end -- 2383
	end -- 2383
	return { -- 2392
		success = false, -- 2392
		message = 'failed to build' -- 2392
	} -- 2392
end) -- 2382
HttpServer:postSchedule("/wa/format", function(req) -- 2394
	do -- 2395
		local _type_0 = type(req) -- 2395
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2395
		if _tab_0 then -- 2395
			local file -- 2395
			do -- 2395
				local _obj_0 = req.body -- 2395
				local _type_1 = type(_obj_0) -- 2395
				if "table" == _type_1 or "userdata" == _type_1 then -- 2395
					file = _obj_0.file -- 2395
				end -- 2395
			end -- 2395
			if file ~= nil then -- 2395
				local code = Wasm:formatWaAsync(file) -- 2396
				if code == "" then -- 2397
					return { -- 2398
						success = false -- 2398
					} -- 2398
				else -- 2400
					return { -- 2400
						success = true, -- 2400
						code = code -- 2400
					} -- 2400
				end -- 2397
			end -- 2395
		end -- 2395
	end -- 2395
	return { -- 2401
		success = false -- 2401
	} -- 2401
end) -- 2394
HttpServer:postSchedule("/wa/create", function(req) -- 2403
	do -- 2404
		local _type_0 = type(req) -- 2404
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2404
		if _tab_0 then -- 2404
			local path -- 2404
			do -- 2404
				local _obj_0 = req.body -- 2404
				local _type_1 = type(_obj_0) -- 2404
				if "table" == _type_1 or "userdata" == _type_1 then -- 2404
					path = _obj_0.path -- 2404
				end -- 2404
			end -- 2404
			if path ~= nil then -- 2404
				if not Content:exist(Path:getPath(path)) then -- 2405
					return { -- 2406
						success = false, -- 2406
						message = "target path not existed" -- 2406
					} -- 2406
				end -- 2405
				if Content:exist(path) then -- 2407
					return { -- 2408
						success = false, -- 2408
						message = "target project folder existed" -- 2408
					} -- 2408
				end -- 2407
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2409
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2410
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2411
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2412
					return { -- 2415
						success = false, -- 2415
						message = "missing template project" -- 2415
					} -- 2415
				end -- 2412
				if not Content:mkdir(path) then -- 2416
					return { -- 2417
						success = false, -- 2417
						message = "failed to create project folder" -- 2417
					} -- 2417
				end -- 2416
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2418
					Content:remove(path) -- 2419
					return { -- 2420
						success = false, -- 2420
						message = "failed to copy template" -- 2420
					} -- 2420
				end -- 2418
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2421
					Content:remove(path) -- 2422
					return { -- 2423
						success = false, -- 2423
						message = "failed to copy template" -- 2423
					} -- 2423
				end -- 2421
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2424
					Content:remove(path) -- 2425
					return { -- 2426
						success = false, -- 2426
						message = "failed to copy template" -- 2426
					} -- 2426
				end -- 2424
				return { -- 2427
					success = true -- 2427
				} -- 2427
			end -- 2404
		end -- 2404
	end -- 2404
	return { -- 2403
		success = false, -- 2403
		message = "invalid call" -- 2403
	} -- 2403
end) -- 2403
local tsBuildGlobs = { -- 2430
	"**/*.ts", -- 2430
	"**/*.tsx", -- 2431
	"!**/.*/**", -- 2432
	"!**/node_modules/**" -- 2433
} -- 2429
local transpileTSFile -- 2435
do -- 2435
	local tsBuildTimeout <const> = 30 -- 2436
	local tsBuildRequestId = 0 -- 2437
	transpileTSFile = function(file, content, sourceRoot) -- 2438
		tsBuildRequestId = tsBuildRequestId + 1 -- 2439
		local requestId = tsBuildRequestId -- 2440
		local done = false -- 2441
		local result = nil -- 2442
		local listener = Node() -- 2443
		listener:gslot("AppWS", function(event) -- 2444
			if event.type == "Receive" then -- 2445
				local res = json.decode(event.msg) -- 2446
				if res then -- 2446
					if res.name == "TranspileTS" and res.id == requestId then -- 2447
						listener:removeFromParent() -- 2448
						if res.success then -- 2449
							local luaFile = Path:replaceExt(file, "lua") -- 2450
							Content:save(luaFile, res.luaCode) -- 2451
							result = { -- 2452
								success = true, -- 2452
								file = file -- 2452
							} -- 2452
						else -- 2454
							result = { -- 2454
								success = false, -- 2454
								file = file, -- 2454
								message = res.message -- 2454
							} -- 2454
						end -- 2449
						done = true -- 2455
					end -- 2447
				end -- 2446
			end -- 2445
		end) -- 2444
		emit("AppWS", "Send", json.encode({ -- 2456
			name = "TranspileTS", -- 2456
			id = requestId, -- 2456
			file = file, -- 2456
			content = content, -- 2456
			projectRoot = sourceRoot -- 2456
		})) -- 2456
		local deadline = App.runningTime + tsBuildTimeout -- 2457
		wait(function() -- 2458
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline -- 2458
		end) -- 2458
		if not done then -- 2459
			listener:removeFromParent() -- 2460
			if HttpServer.wsConnectionCount == 0 then -- 2461
				return { -- 2462
					success = false, -- 2462
					file = file, -- 2462
					message = "Web IDE disconnected" -- 2462
				} -- 2462
			end -- 2461
			return { -- 2463
				success = false, -- 2463
				file = file, -- 2463
				message = "TypeScript transpile timed out" -- 2463
			} -- 2463
		end -- 2459
		return result -- 2464
	end -- 2438
end -- 2435
local _anon_func_7 = function(path) -- 2475
	local _val_0 = Path:getExt(path) -- 2475
	return "ts" == _val_0 or "tsx" == _val_0 -- 2475
end -- 2475
HttpServer:postSchedule("/ts/build", function(req) -- 2466
	do -- 2467
		local _type_0 = type(req) -- 2467
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2467
		if _tab_0 then -- 2467
			local path -- 2467
			do -- 2467
				local _obj_0 = req.body -- 2467
				local _type_1 = type(_obj_0) -- 2467
				if "table" == _type_1 or "userdata" == _type_1 then -- 2467
					path = _obj_0.path -- 2467
				end -- 2467
			end -- 2467
			if path ~= nil then -- 2467
				if HttpServer.wsConnectionCount == 0 then -- 2468
					return { -- 2469
						success = false, -- 2469
						message = "Web IDE not connected" -- 2469
					} -- 2469
				end -- 2468
				local projectRoot = req.body.projectRoot -- 2470
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2471
				if not Content:exist(path) then -- 2472
					return { -- 2473
						success = false, -- 2473
						message = "path not existed" -- 2473
					} -- 2473
				end -- 2472
				if not Content:isdir(path) then -- 2474
					if not (_anon_func_7(path)) then -- 2475
						return { -- 2476
							success = false, -- 2476
							message = "expecting a TypeScript file" -- 2476
						} -- 2476
					end -- 2475
					local messages = { } -- 2477
					local content = Content:load(path) -- 2478
					if not content then -- 2479
						return { -- 2480
							success = false, -- 2480
							message = "failed to read file" -- 2480
						} -- 2480
					end -- 2479
					emit("AppWS", "Send", json.encode({ -- 2481
						name = "UpdateFile", -- 2481
						file = path, -- 2481
						exists = true, -- 2481
						content = content, -- 2481
						projectRoot = sourceRoot -- 2481
					})) -- 2481
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2482
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot) -- 2483
					end -- 2482
					return { -- 2484
						success = true, -- 2484
						messages = messages -- 2484
					} -- 2484
				else -- 2486
					local fileData = { } -- 2486
					local messages = { } -- 2487
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2488
					for _index_0 = 1, #_list_0 do -- 2488
						local subFile = _list_0[_index_0] -- 2488
						local file = Path(path, subFile) -- 2489
						local content = Content:load(file) -- 2490
						if content then -- 2490
							fileData[file] = content -- 2491
							emit("AppWS", "Send", json.encode({ -- 2492
								name = "UpdateFile", -- 2492
								file = file, -- 2492
								exists = true, -- 2492
								content = content, -- 2492
								projectRoot = sourceRoot -- 2492
							})) -- 2492
						else -- 2494
							messages[#messages + 1] = { -- 2494
								success = false, -- 2494
								file = file, -- 2494
								message = "failed to read file" -- 2494
							} -- 2494
						end -- 2490
					end -- 2488
					for file, content in pairs(fileData) do -- 2495
						if "d" == Path:getExt(Path:getName(file)) then -- 2496
							goto _continue_0 -- 2496
						end -- 2496
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot) -- 2497
						::_continue_0:: -- 2496
					end -- 2495
					return { -- 2498
						success = true, -- 2498
						messages = messages -- 2498
					} -- 2498
				end -- 2474
			end -- 2467
		end -- 2467
	end -- 2467
	return { -- 2466
		success = false -- 2466
	} -- 2466
end) -- 2466
HttpServer:post("/download", function(req) -- 2500
	do -- 2501
		local _type_0 = type(req) -- 2501
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2501
		if _tab_0 then -- 2501
			local url -- 2501
			do -- 2501
				local _obj_0 = req.body -- 2501
				local _type_1 = type(_obj_0) -- 2501
				if "table" == _type_1 or "userdata" == _type_1 then -- 2501
					url = _obj_0.url -- 2501
				end -- 2501
			end -- 2501
			local target -- 2501
			do -- 2501
				local _obj_0 = req.body -- 2501
				local _type_1 = type(_obj_0) -- 2501
				if "table" == _type_1 or "userdata" == _type_1 then -- 2501
					target = _obj_0.target -- 2501
				end -- 2501
			end -- 2501
			if url ~= nil and target ~= nil then -- 2501
				local Entry = require("Script.Dev.Entry") -- 2502
				Entry.downloadFile(url, target) -- 2503
				return { -- 2504
					success = true -- 2504
				} -- 2504
			end -- 2501
		end -- 2501
	end -- 2501
	return { -- 2500
		success = false -- 2500
	} -- 2500
end) -- 2500
local isDesktopPlatform -- 2506
isDesktopPlatform = function() -- 2506
	local _val_0 = App.platform -- 2507
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2507
end -- 2506
local getServerStatus -- 2509
getServerStatus = function() -- 2509
	local Entry = require("Script.Dev.Entry") -- 2510
	local running = Entry.getCurrentEntryStatus() -- 2511
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2512
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2513
	return { -- 2515
		success = true, -- 2515
		platform = App.platform, -- 2516
		locale = App.locale, -- 2517
		version = App.version, -- 2518
		url = "http://localhost:8866", -- 2519
		wsConnectionCount = wsConnectionCount, -- 2520
		webIDEConnected = wsConnectionCount > 0, -- 2521
		assetPath = Content.assetPath, -- 2522
		writablePath = Content.writablePath, -- 2523
		appPath = Content.appPath, -- 2524
		waTemplateReady = waTemplateReady, -- 2525
		running = running -- 2526
	} -- 2514
end -- 2509
HttpServer:post("/status", function() -- 2529
	return getServerStatus() -- 2530
end) -- 2529
HttpServer:postSchedule("/doctor/fix", function(req) -- 2532
	do -- 2533
		local _type_0 = type(req) -- 2533
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2533
		if _tab_0 then -- 2533
			local openWebIDE -- 2533
			do -- 2533
				local _obj_0 = req.body -- 2533
				local _type_1 = type(_obj_0) -- 2533
				if "table" == _type_1 or "userdata" == _type_1 then -- 2533
					openWebIDE = _obj_0.openWebIDE -- 2533
				end -- 2533
			end -- 2533
			if openWebIDE ~= nil then -- 2533
				if not openWebIDE then -- 2534
					return { -- 2535
						success = false, -- 2535
						message = "nothing to fix" -- 2535
					} -- 2535
				end -- 2534
				local status = getServerStatus() -- 2536
				if status.webIDEConnected then -- 2537
					return { -- 2538
						success = true, -- 2538
						fixed = false, -- 2538
						message = "Web IDE already connected.", -- 2538
						status = status -- 2538
					} -- 2538
				end -- 2537
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2539
				if waitSeconds > 0 then -- 2540
					local deadline = os.time() + waitSeconds -- 2541
					repeat -- 2542
						sleep(0.2) -- 2543
						status = getServerStatus() -- 2544
						if status.webIDEConnected then -- 2545
							return { -- 2546
								success = true, -- 2546
								fixed = false, -- 2546
								reconnected = true, -- 2546
								message = "Web IDE reconnected.", -- 2546
								status = status -- 2546
							} -- 2546
						end -- 2545
					until os.time() >= deadline -- 2542
				end -- 2540
				if not isDesktopPlatform() then -- 2548
					return { -- 2549
						success = false, -- 2549
						message = "opening Web IDE is only supported on desktop platforms", -- 2549
						status = status -- 2549
					} -- 2549
				end -- 2548
				local url = "http://localhost:8866" -- 2550
				App:openURL(url) -- 2551
				status.openedURL = url -- 2552
				return { -- 2553
					success = true, -- 2553
					fixed = true, -- 2553
					message = "Opened Web IDE in the local browser.", -- 2553
					url = url, -- 2553
					status = status -- 2553
				} -- 2553
			end -- 2533
		end -- 2533
	end -- 2533
	return { -- 2532
		success = false, -- 2532
		message = "invalid call" -- 2532
	} -- 2532
end) -- 2532
local status = { } -- 2555
_module_0 = status -- 2556
status.buildAsync = function(path) -- 2558
	if not Content:exist(path) then -- 2559
		return { -- 2560
			success = false, -- 2560
			file = path, -- 2560
			message = "file not existed" -- 2560
		} -- 2560
	end -- 2559
	do -- 2561
		local _exp_0 = Path:getExt(path) -- 2561
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2561
			if '' == Path:getExt(Path:getName(path)) then -- 2562
				local content = Content:loadAsync(path) -- 2563
				if content then -- 2563
					local resultCodes, err = compileFileAsync(path, content) -- 2564
					if resultCodes then -- 2564
						return { -- 2565
							success = true, -- 2565
							file = path -- 2565
						} -- 2565
					else -- 2567
						return { -- 2567
							success = false, -- 2567
							file = path, -- 2567
							message = err -- 2567
						} -- 2567
					end -- 2564
				end -- 2563
			end -- 2562
		elseif "lua" == _exp_0 then -- 2568
			local content = Content:loadAsync(path) -- 2569
			if content then -- 2569
				do -- 2570
					local isTIC80 = CheckTIC80Code(content) -- 2570
					if isTIC80 then -- 2570
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2571
					end -- 2570
				end -- 2570
				local success, info -- 2572
				do -- 2572
					local _obj_0 = luaCheck(path, content) -- 2572
					success, info = _obj_0.success, _obj_0.info -- 2572
				end -- 2572
				if success then -- 2573
					return { -- 2574
						success = true, -- 2574
						file = path -- 2574
					} -- 2574
				elseif info and #info > 0 then -- 2575
					local messages = { } -- 2576
					for _index_0 = 1, #info do -- 2577
						local _des_0 = info[_index_0] -- 2577
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2577
						local lineText = "" -- 2578
						if line then -- 2579
							local currentLine = 1 -- 2580
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2581
								if currentLine == line then -- 2582
									lineText = text -- 2583
									break -- 2584
								end -- 2582
								currentLine = currentLine + 1 -- 2585
							end -- 2581
						end -- 2579
						if line then -- 2586
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2587
						else -- 2589
							messages[#messages + 1] = message -- 2589
						end -- 2586
					end -- 2577
					return { -- 2590
						success = false, -- 2590
						file = path, -- 2590
						message = table.concat(messages, "\n") -- 2590
					} -- 2590
				else -- 2592
					return { -- 2592
						success = false, -- 2592
						file = path, -- 2592
						message = "lua check failed" -- 2592
					} -- 2592
				end -- 2573
			end -- 2569
		elseif "yarn" == _exp_0 then -- 2593
			local content = Content:loadAsync(path) -- 2594
			if content then -- 2594
				local res, _, err = yarncompile(content, true) -- 2595
				if res then -- 2595
					return { -- 2596
						success = true, -- 2596
						file = path -- 2596
					} -- 2596
				else -- 2598
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2598
					local lineText = "" -- 2599
					if line then -- 2600
						local currentLine = 1 -- 2601
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2602
							if currentLine == line then -- 2603
								lineText = text -- 2604
								break -- 2605
							end -- 2603
							currentLine = currentLine + 1 -- 2606
						end -- 2602
					end -- 2600
					if node ~= "" then -- 2607
						node = "node: " .. tostring(node) .. ", " -- 2608
					else -- 2609
						node = "" -- 2609
					end -- 2607
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2610
					return { -- 2611
						success = false, -- 2611
						file = path, -- 2611
						message = message -- 2611
					} -- 2611
				end -- 2595
			end -- 2594
		end -- 2561
	end -- 2561
	return { -- 2612
		success = false, -- 2612
		file = path, -- 2612
		message = "invalid file to build" -- 2612
	} -- 2612
end -- 2558
thread(function() -- 2614
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 2615
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 2616
	if Content:exist(doraWeb) then -- 2617
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) -- 2618
		local needReload -- 2619
		if Content:exist(doraReady) then -- 2619
			needReload = readyContent ~= Content:load(doraReady) -- 2620
		else -- 2621
			needReload = true -- 2621
		end -- 2619
		if needReload then -- 2622
			Content:remove(Path(Content.appPath, ".www")) -- 2623
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 2624
			Content:save(doraReady, readyContent) -- 2628
			print("Dora Dora is ready!") -- 2629
		end -- 2622
	end -- 2617
	if HttpServer:start(8866) then -- 2630
		local localIP = HttpServer.localIP -- 2631
		if localIP == "" then -- 2632
			localIP = "localhost" -- 2632
		end -- 2632
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 2633
		return HttpServer:startWS(8868) -- 2634
	else -- 2636
		status.url = nil -- 2636
		return print("8866 Port not available!") -- 2637
	end -- 2630
end) -- 2614
return _module_0 -- 1
