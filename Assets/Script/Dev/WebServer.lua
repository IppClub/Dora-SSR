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
							if dir:match("^%.") then -- 1370
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
HttpServer:post("/delete", function(req) -- 1624
	do -- 1625
		local _type_0 = type(req) -- 1625
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1625
		if _tab_0 then -- 1625
			local path -- 1625
			do -- 1625
				local _obj_0 = req.body -- 1625
				local _type_1 = type(_obj_0) -- 1625
				if "table" == _type_1 or "userdata" == _type_1 then -- 1625
					path = _obj_0.path -- 1625
				end -- 1625
			end -- 1625
			if path ~= nil then -- 1625
				if Content:exist(path) then -- 1626
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
						return { -- 1641
							success = true -- 1641
						} -- 1641
					end -- 1638
				end -- 1626
			end -- 1625
		end -- 1625
	end -- 1625
	return { -- 1624
		success = false -- 1624
	} -- 1624
end) -- 1624
HttpServer:post("/rename", function(req) -- 1643
	do -- 1644
		local _type_0 = type(req) -- 1644
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1644
		if _tab_0 then -- 1644
			local old -- 1644
			do -- 1644
				local _obj_0 = req.body -- 1644
				local _type_1 = type(_obj_0) -- 1644
				if "table" == _type_1 or "userdata" == _type_1 then -- 1644
					old = _obj_0.old -- 1644
				end -- 1644
			end -- 1644
			local new -- 1644
			do -- 1644
				local _obj_0 = req.body -- 1644
				local _type_1 = type(_obj_0) -- 1644
				if "table" == _type_1 or "userdata" == _type_1 then -- 1644
					new = _obj_0.new -- 1644
				end -- 1644
			end -- 1644
			if old ~= nil and new ~= nil then -- 1644
				if Content:exist(old) and not Content:exist(new) then -- 1645
					local renamedDir = Content:isdir(old) -- 1646
					local parent = Path:getPath(new) -- 1647
					local files = Content:getFiles(parent) -- 1648
					if renamedDir then -- 1649
						local name = Path:getFilename(new):lower() -- 1650
						for _index_0 = 1, #files do -- 1651
							local file = files[_index_0] -- 1651
							if name == Path:getFilename(file):lower() then -- 1652
								return { -- 1653
									success = false -- 1653
								} -- 1653
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
								return { -- 1663
									success = false -- 1663
								} -- 1663
							end -- 1658
							::_continue_0:: -- 1658
						end -- 1657
					end -- 1649
					if Content:move(old, new) then -- 1664
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
						return { -- 1680
							success = true -- 1680
						} -- 1680
					end -- 1664
				end -- 1645
			end -- 1644
		end -- 1644
	end -- 1644
	return { -- 1643
		success = false -- 1643
	} -- 1643
end) -- 1643
local withProjectSearchPaths -- 1682
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1682
	local fallbackPaths = { } -- 1683
	local addFallback -- 1684
	addFallback = function(dir) -- 1684
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1684
			fallbackPaths[#fallbackPaths + 1] = dir -- 1684
		end -- 1684
	end -- 1684
	if projectRoot and projectRoot ~= "" then -- 1685
		addFallback(Path(projectRoot, "Script")) -- 1686
		addFallback(projectRoot) -- 1687
	end -- 1685
	if projFile then -- 1688
		local projDir = getProjectDirFromFile(projFile) -- 1689
		if projDir then -- 1689
			addFallback(Path(projDir, "Script")) -- 1690
			addFallback(projDir) -- 1691
		else -- 1693
			addFallback(Path:getPath(projFile)) -- 1693
		end -- 1689
	end -- 1688
	if not (#fallbackPaths > 0) then -- 1694
		return fn() -- 1694
	end -- 1694
	local searchPaths = Content.searchPaths -- 1695
	for _index_0 = 1, #fallbackPaths do -- 1696
		local dir = fallbackPaths[_index_0] -- 1696
		Content:addSearchPath(dir) -- 1696
	end -- 1696
	local _ <close> = setmetatable({ }, { -- 1697
		__close = function() -- 1697
			Content.searchPaths = searchPaths -- 1697
		end -- 1697
	}) -- 1697
	return fn() -- 1698
end -- 1682
HttpServer:post("/exist", function(req) -- 1699
	do -- 1700
		local _type_0 = type(req) -- 1700
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1700
		if _tab_0 then -- 1700
			local file -- 1700
			do -- 1700
				local _obj_0 = req.body -- 1700
				local _type_1 = type(_obj_0) -- 1700
				if "table" == _type_1 or "userdata" == _type_1 then -- 1700
					file = _obj_0.file -- 1700
				end -- 1700
			end -- 1700
			if file ~= nil then -- 1700
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1701
					return { -- 1702
						success = Content:exist(file) -- 1702
					} -- 1702
				end) -- 1701
			end -- 1700
		end -- 1700
	end -- 1700
	return { -- 1699
		success = false -- 1699
	} -- 1699
end) -- 1699
HttpServer:postSchedule("/read", function(req) -- 1703
	do -- 1704
		local _type_0 = type(req) -- 1704
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1704
		if _tab_0 then -- 1704
			local path -- 1704
			do -- 1704
				local _obj_0 = req.body -- 1704
				local _type_1 = type(_obj_0) -- 1704
				if "table" == _type_1 or "userdata" == _type_1 then -- 1704
					path = _obj_0.path -- 1704
				end -- 1704
			end -- 1704
			if path ~= nil then -- 1704
				local readFile -- 1705
				readFile = function() -- 1705
					if Content:exist(path) then -- 1706
						local content = Content:loadAsync(path) -- 1707
						if content then -- 1707
							return { -- 1708
								content = content, -- 1708
								success = true, -- 1708
								fullPath = Content:getFullPath(path) -- 1708
							} -- 1708
						end -- 1707
					end -- 1706
					return nil -- 1705
				end -- 1705
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1709
				if result then -- 1709
					return result -- 1709
				end -- 1709
			end -- 1704
		end -- 1704
	end -- 1704
	return { -- 1703
		success = false -- 1703
	} -- 1703
end) -- 1703
local agentDocLanguage -- 1711
agentDocLanguage = function(language) -- 1711
	if language == "zh-Hans" then -- 1712
		return "zh" -- 1712
	else -- 1712
		return "en" -- 1712
	end -- 1712
end -- 1711
HttpServer:postSchedule("/doc/search", function(req) -- 1714
	local body = req.body or { } -- 1715
	local language = body.docLanguage -- 1716
	if not (("en" == language or "zh-Hans" == language)) then -- 1717
		return { -- 1717
			success = false, -- 1717
			message = "unsupported doc language" -- 1717
		} -- 1717
	end -- 1717
	local source = body.docSource -- 1718
	if not (("api" == source or "tutorial" == source)) then -- 1719
		return { -- 1719
			success = false, -- 1719
			message = "unsupported doc source" -- 1719
		} -- 1719
	end -- 1719
	local codeLanguage = body.programmingLanguage -- 1720
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1721
		return { -- 1721
			success = false, -- 1721
			message = "unsupported programming language" -- 1721
		} -- 1721
	end -- 1721
	if not body.pattern then -- 1722
		return { -- 1722
			success = false, -- 1722
			message = "missing pattern" -- 1722
		} -- 1722
	end -- 1722
	local result = nil -- 1723
	AgentTools.searchDoraAPIHttp({ -- 1725
		pattern = body.pattern, -- 1725
		docLanguage = agentDocLanguage(language), -- 1726
		docSource = source, -- 1727
		programmingLanguage = codeLanguage, -- 1728
		limit = body.limit, -- 1729
		useRegex = body.useRegex, -- 1730
		caseSensitive = body.caseSensitive, -- 1731
		includeContent = body.includeContent, -- 1732
		contentWindow = body.contentWindow -- 1733
	}, function(res) -- 1734
		result = res -- 1735
	end) -- 1724
	wait(function() -- 1736
		return result ~= nil -- 1736
	end) -- 1736
	if result and result.success then -- 1737
		result.docLanguage = language -- 1738
	end -- 1737
	if result then -- 1739
		return result -- 1740
	else -- 1742
		return { -- 1742
			success = false, -- 1742
			message = "doc search failed" -- 1742
		} -- 1742
	end -- 1739
	return { -- 1714
		success = false, -- 1714
		message = "invalid call" -- 1714
	} -- 1714
end) -- 1714
HttpServer:postSchedule("/doc/read", function(req) -- 1744
	local body = req.body or { } -- 1745
	local language = body.docLanguage -- 1746
	if not (("en" == language or "zh-Hans" == language)) then -- 1747
		return { -- 1747
			success = false, -- 1747
			message = "unsupported doc language" -- 1747
		} -- 1747
	end -- 1747
	if not body.file then -- 1748
		return { -- 1748
			success = false, -- 1748
			message = "missing file" -- 1748
		} -- 1748
	end -- 1748
	local result = AgentTools.readDoraDoc({ -- 1750
		docLanguage = agentDocLanguage(language), -- 1750
		file = body.file, -- 1751
		startLine = body.startLine, -- 1752
		endLine = body.endLine -- 1753
	}) -- 1749
	if result and result.success then -- 1754
		result.docLanguage = language -- 1755
	end -- 1754
	return result -- 1756
end) -- 1744
HttpServer:get("/read-sync", function(req) -- 1758
	do -- 1759
		local _type_0 = type(req) -- 1759
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1759
		if _tab_0 then -- 1759
			local params = req.params -- 1759
			if params ~= nil then -- 1759
				local path = params.path -- 1760
				local exts -- 1761
				if params.exts then -- 1761
					local _accum_0 = { } -- 1762
					local _len_0 = 1 -- 1762
					for ext in params.exts:gmatch("[^|]*") do -- 1762
						_accum_0[_len_0] = ext -- 1762
						_len_0 = _len_0 + 1 -- 1762
					end -- 1762
					exts = _accum_0 -- 1762
				else -- 1763
					exts = { -- 1763
						"" -- 1763
					} -- 1763
				end -- 1761
				local readFileAt -- 1764
				readFileAt = function(targetPath) -- 1764
					if Content:exist(targetPath) then -- 1765
						local content = Content:load(targetPath) -- 1766
						if content then -- 1766
							return { -- 1767
								content = content, -- 1767
								success = true, -- 1767
								fullPath = Content:getFullPath(targetPath) -- 1767
							} -- 1767
						end -- 1766
					end -- 1765
					return nil -- 1764
				end -- 1764
				local readFile -- 1768
				readFile = function(fallbackPaths) -- 1768
					for _index_0 = 1, #exts do -- 1769
						local ext = exts[_index_0] -- 1769
						local targetPath = path .. ext -- 1770
						if not Content:isAbsolutePath(targetPath) then -- 1771
							for _index_1 = 1, #fallbackPaths do -- 1772
								local fallback = fallbackPaths[_index_1] -- 1772
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1773
								if fallbackResult then -- 1773
									return fallbackResult -- 1774
								end -- 1773
							end -- 1772
						end -- 1771
						local fileResult = readFileAt(targetPath) -- 1775
						if fileResult then -- 1775
							return fileResult -- 1776
						end -- 1775
					end -- 1769
					return nil -- 1768
				end -- 1768
				local fallbackPaths = { } -- 1777
				local fallbackCandidates = { } -- 1778
				do -- 1779
					local projectRoot = req.params.projectRoot -- 1779
					if projectRoot then -- 1779
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1780
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1781
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1782
						end -- 1780
					end -- 1779
				end -- 1779
				do -- 1783
					local projFile = req.params.projFile -- 1783
					if projFile then -- 1783
						local projDir = getProjectDirFromFile(projFile) -- 1784
						if projDir then -- 1784
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1785
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1786
						else -- 1788
							projDir = Path:getPath(projFile) -- 1788
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1789
						end -- 1784
					end -- 1783
				end -- 1783
				for _index_0 = 1, #fallbackCandidates do -- 1790
					local dir = fallbackCandidates[_index_0] -- 1790
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1791
						local exists = false -- 1792
						for _index_1 = 1, #fallbackPaths do -- 1793
							local fallback = fallbackPaths[_index_1] -- 1793
							if fallback == dir then -- 1794
								exists = true -- 1795
								break -- 1796
							end -- 1794
						end -- 1793
						if not exists then -- 1797
							fallbackPaths[#fallbackPaths + 1] = dir -- 1797
						end -- 1797
					end -- 1791
				end -- 1790
				local readResult = readFile(fallbackPaths) -- 1798
				if readResult then -- 1798
					return readResult -- 1799
				end -- 1798
			end -- 1759
		end -- 1759
	end -- 1759
	return { -- 1758
		success = false -- 1758
	} -- 1758
end) -- 1758
local compileFileAsync -- 1801
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1801
	if projectRoot == nil then -- 1801
		projectRoot = nil -- 1801
	end -- 1801
	local file = inputFile -- 1802
	local searchPath -- 1803
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1803
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1804
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1808
	elseif not Content:isAbsolutePath(inputFile) then -- 1809
		searchPath = "" -- 1810
	else -- 1811
		local dir = getProjectDirFromFile(inputFile) -- 1811
		if dir then -- 1811
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1812
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1816
		else -- 1818
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1818
			searchPath = "" -- 1821
		end -- 1811
	end -- 1803
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1822
	local yueext = yue.options.extension -- 1823
	local resultCodes = nil -- 1824
	local resultError = nil -- 1825
	do -- 1826
		local _exp_0 = Path:getExt(inputFile) -- 1826
		if yueext == _exp_0 then -- 1826
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1827
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1828
				if not codes then -- 1829
					resultError = err -- 1830
					return -- 1831
				end -- 1829
				local extraGlobal -- 1832
				if isTIC80 then -- 1832
					extraGlobal = tic80APIs -- 1832
				else -- 1832
					extraGlobal = nil -- 1832
				end -- 1832
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1833
				if not success then -- 1834
					resultError = message -- 1835
					return -- 1836
				end -- 1834
				if codes == "" then -- 1837
					resultCodes = "" -- 1838
					return nil -- 1839
				end -- 1837
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1840
				return resultCodes -- 1841
			end, function(success) -- 1828
				if not success then -- 1842
					Content:remove(outputFile) -- 1843
					if resultCodes == nil then -- 1844
						resultCodes = false -- 1845
					end -- 1844
				end -- 1842
			end) -- 1828
		elseif "tl" == _exp_0 then -- 1846
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1847
			if isTIC80 then -- 1848
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1849
			end -- 1848
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1850
			if codes then -- 1850
				if isTIC80 then -- 1851
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1852
				end -- 1851
				resultCodes = codes -- 1853
				Content:saveAsync(outputFile, codes) -- 1854
			else -- 1856
				Content:remove(outputFile) -- 1856
				resultCodes = false -- 1857
				resultError = err -- 1858
			end -- 1850
		elseif "xml" == _exp_0 then -- 1859
			local codes, err = xml.tolua(sourceCodes) -- 1860
			if codes then -- 1860
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1861
				Content:saveAsync(outputFile, resultCodes) -- 1862
			else -- 1864
				Content:remove(outputFile) -- 1864
				resultCodes = false -- 1865
				resultError = err -- 1866
			end -- 1860
		end -- 1826
	end -- 1826
	wait(function() -- 1867
		return resultCodes ~= nil -- 1867
	end) -- 1867
	if resultCodes then -- 1868
		return resultCodes -- 1869
	else -- 1871
		return nil, resultError -- 1871
	end -- 1868
	return nil -- 1801
end -- 1801
HttpServer:postSchedule("/write", function(req) -- 1873
	do -- 1874
		local _type_0 = type(req) -- 1874
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1874
		if _tab_0 then -- 1874
			local path -- 1874
			do -- 1874
				local _obj_0 = req.body -- 1874
				local _type_1 = type(_obj_0) -- 1874
				if "table" == _type_1 or "userdata" == _type_1 then -- 1874
					path = _obj_0.path -- 1874
				end -- 1874
			end -- 1874
			local content -- 1874
			do -- 1874
				local _obj_0 = req.body -- 1874
				local _type_1 = type(_obj_0) -- 1874
				if "table" == _type_1 or "userdata" == _type_1 then -- 1874
					content = _obj_0.content -- 1874
				end -- 1874
			end -- 1874
			if path ~= nil and content ~= nil then -- 1874
				if Content:saveAsync(path, content) then -- 1875
					do -- 1876
						local _exp_0 = Path:getExt(path) -- 1876
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1876
							if '' == Path:getExt(Path:getName(path)) then -- 1877
								local resultCodes = compileFileAsync(path, content) -- 1878
								return { -- 1879
									success = true, -- 1879
									resultCodes = resultCodes -- 1879
								} -- 1879
							end -- 1877
						end -- 1876
					end -- 1876
					return { -- 1880
						success = true -- 1880
					} -- 1880
				end -- 1875
			end -- 1874
		end -- 1874
	end -- 1874
	return { -- 1873
		success = false -- 1873
	} -- 1873
end) -- 1873
local getWaProjectDirFromFile = nil -- 1882
HttpServer:postSchedule("/build", function(req) -- 1884
	do -- 1885
		local _type_0 = type(req) -- 1885
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1885
		if _tab_0 then -- 1885
			local path -- 1885
			do -- 1885
				local _obj_0 = req.body -- 1885
				local _type_1 = type(_obj_0) -- 1885
				if "table" == _type_1 or "userdata" == _type_1 then -- 1885
					path = _obj_0.path -- 1885
				end -- 1885
			end -- 1885
			if path ~= nil then -- 1885
				local projectRoot = req.body.projectRoot -- 1886
				if Content:isdir(path) then -- 1887
					local projDir = getWaProjectDirFromFile(path) -- 1888
					if projDir then -- 1888
						local message = Wasm:buildWaAsync(projDir) -- 1889
						if message == "" then -- 1890
							return { -- 1891
								success = true -- 1891
							} -- 1891
						else -- 1893
							return { -- 1893
								success = false, -- 1893
								message = message -- 1893
							} -- 1893
						end -- 1890
					end -- 1888
				end -- 1887
				local _exp_0 = Path:getExt(path) -- 1894
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1895
					if '' == Path:getExt(Path:getName(path)) then -- 1896
						local content = Content:loadAsync(path) -- 1897
						if content then -- 1897
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 1898
							if resultCodes then -- 1898
								return { -- 1899
									success = true, -- 1899
									resultCodes = resultCodes -- 1899
								} -- 1899
							end -- 1898
						end -- 1897
					end -- 1896
				elseif "wa" == _exp_0 then -- 1900
					local projDir = getWaProjectDirFromFile(path) -- 1901
					if projDir then -- 1901
						local message = Wasm:buildWaAsync(projDir) -- 1902
						if message == "" then -- 1903
							return { -- 1904
								success = true -- 1904
							} -- 1904
						else -- 1906
							return { -- 1906
								success = false, -- 1906
								message = message -- 1906
							} -- 1906
						end -- 1903
					else -- 1908
						return { -- 1908
							success = false, -- 1908
							message = 'Wa file needs a project' -- 1908
						} -- 1908
					end -- 1901
				end -- 1894
			end -- 1885
		end -- 1885
	end -- 1885
	return { -- 1884
		success = false -- 1884
	} -- 1884
end) -- 1884
local extentionLevels = { -- 1911
	vs = 2, -- 1911
	bl = 2, -- 1912
	ts = 1, -- 1913
	tsx = 1, -- 1914
	tl = 1, -- 1915
	yue = 1, -- 1916
	xml = 1, -- 1917
	lua = 0 -- 1918
} -- 1910
HttpServer:post("/assets", function() -- 1920
	local Entry = require("Script.Dev.Entry") -- 1923
	local engineDev = Entry.getEngineDev() -- 1924
	local visitAssets -- 1925
	visitAssets = function(path, tag) -- 1925
		local isWorkspace = tag == "Workspace" -- 1926
		local builtin -- 1927
		if tag == "Builtin" then -- 1927
			builtin = true -- 1927
		else -- 1927
			builtin = nil -- 1927
		end -- 1927
		local children = nil -- 1928
		local dirs = Content:getDirs(path) -- 1929
		for _index_0 = 1, #dirs do -- 1930
			local dir = dirs[_index_0] -- 1930
			if isWorkspace then -- 1931
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1932
					goto _continue_0 -- 1933
				end -- 1932
			elseif dir == ".git" then -- 1934
				goto _continue_0 -- 1935
			end -- 1931
			if not children then -- 1936
				children = { } -- 1936
			end -- 1936
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1937
			::_continue_0:: -- 1931
		end -- 1930
		local files = Content:getFiles(path) -- 1938
		local names = { } -- 1939
		for _index_0 = 1, #files do -- 1940
			local file = files[_index_0] -- 1940
			if (".DS_Store" == file) then -- 1941
				goto _continue_1 -- 1942
			end -- 1941
			local name = Path:getName(file) -- 1943
			local ext = names[name] -- 1944
			if ext then -- 1944
				local lv1 -- 1945
				do -- 1945
					local _exp_0 = extentionLevels[ext] -- 1945
					if _exp_0 ~= nil then -- 1945
						lv1 = _exp_0 -- 1945
					else -- 1945
						lv1 = -1 -- 1945
					end -- 1945
				end -- 1945
				ext = Path:getExt(file) -- 1946
				local lv2 -- 1947
				do -- 1947
					local _exp_0 = extentionLevels[ext] -- 1947
					if _exp_0 ~= nil then -- 1947
						lv2 = _exp_0 -- 1947
					else -- 1947
						lv2 = -1 -- 1947
					end -- 1947
				end -- 1947
				if lv2 > lv1 then -- 1948
					names[name] = ext -- 1949
				elseif lv2 == lv1 then -- 1950
					names[name .. '.' .. ext] = "" -- 1951
				end -- 1948
			else -- 1953
				ext = Path:getExt(file) -- 1953
				if not extentionLevels[ext] then -- 1954
					names[file] = "" -- 1955
				else -- 1957
					names[name] = ext -- 1957
				end -- 1954
			end -- 1944
			::_continue_1:: -- 1941
		end -- 1940
		do -- 1958
			local _accum_0 = { } -- 1958
			local _len_0 = 1 -- 1958
			for name, ext in pairs(names) do -- 1958
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1958
				_len_0 = _len_0 + 1 -- 1958
			end -- 1958
			files = _accum_0 -- 1958
		end -- 1958
		for _index_0 = 1, #files do -- 1959
			local file = files[_index_0] -- 1959
			if not children then -- 1960
				children = { } -- 1960
			end -- 1960
			children[#children + 1] = { -- 1962
				key = Path(path, file), -- 1962
				dir = false, -- 1963
				title = file, -- 1964
				builtin = builtin -- 1965
			} -- 1961
		end -- 1959
		if children then -- 1967
			table.sort(children, function(a, b) -- 1968
				if a.dir == b.dir then -- 1969
					return a.title < b.title -- 1970
				else -- 1972
					return a.dir -- 1972
				end -- 1969
			end) -- 1968
		end -- 1967
		if isWorkspace and children then -- 1973
			return children -- 1974
		else -- 1976
			return { -- 1977
				key = path, -- 1977
				dir = true, -- 1978
				title = Path:getFilename(path), -- 1979
				builtin = builtin, -- 1980
				children = children -- 1981
			} -- 1976
		end -- 1973
	end -- 1925
	local zh = (App.locale:match("^zh") ~= nil) -- 1983
	return { -- 1985
		key = Content.writablePath, -- 1985
		dir = true, -- 1986
		root = true, -- 1987
		title = "Assets", -- 1988
		children = (function() -- 1990
			local _tab_0 = { -- 1990
				{ -- 1991
					key = Path(Content.assetPath), -- 1991
					dir = true, -- 1992
					builtin = true, -- 1993
					title = zh and "内置资源" or "Built-in", -- 1994
					children = { -- 1996
						(function() -- 1996
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1996
							_with_0.title = zh and "说明文档" or "Readme" -- 1997
							return _with_0 -- 1996
						end)(), -- 1996
						(function() -- 1998
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1998
							_with_0.title = zh and "接口文档" or "API Doc" -- 1999
							return _with_0 -- 1998
						end)(), -- 1998
						(function() -- 2000
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 2000
							_with_0.title = zh and "开发工具" or "Tools" -- 2001
							return _with_0 -- 2000
						end)(), -- 2000
						(function() -- 2002
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 2002
							_with_0.title = zh and "字体" or "Font" -- 2003
							return _with_0 -- 2002
						end)(), -- 2002
						(function() -- 2004
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 2004
							_with_0.title = zh and "程序库" or "Lib" -- 2005
							if engineDev then -- 2006
								local _list_0 = _with_0.children -- 2007
								for _index_0 = 1, #_list_0 do -- 2007
									local child = _list_0[_index_0] -- 2007
									if not (child.title == "Dora") then -- 2008
										goto _continue_0 -- 2008
									end -- 2008
									local title = zh and "zh-Hans" or "en" -- 2009
									do -- 2010
										local _accum_0 = { } -- 2010
										local _len_0 = 1 -- 2010
										local _list_1 = child.children -- 2010
										for _index_1 = 1, #_list_1 do -- 2010
											local c = _list_1[_index_1] -- 2010
											if c.title ~= title then -- 2010
												_accum_0[_len_0] = c -- 2010
												_len_0 = _len_0 + 1 -- 2010
											end -- 2010
										end -- 2010
										child.children = _accum_0 -- 2010
									end -- 2010
									break -- 2011
									::_continue_0:: -- 2008
								end -- 2007
							else -- 2013
								local _accum_0 = { } -- 2013
								local _len_0 = 1 -- 2013
								local _list_0 = _with_0.children -- 2013
								for _index_0 = 1, #_list_0 do -- 2013
									local child = _list_0[_index_0] -- 2013
									if child.title ~= "Dora" then -- 2013
										_accum_0[_len_0] = child -- 2013
										_len_0 = _len_0 + 1 -- 2013
									end -- 2013
								end -- 2013
								_with_0.children = _accum_0 -- 2013
							end -- 2006
							return _with_0 -- 2004
						end)(), -- 2004
						(function() -- 2014
							if engineDev then -- 2014
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 2015
								local _obj_0 = _with_0.children -- 2016
								_obj_0[#_obj_0 + 1] = { -- 2017
									key = Path(Content.assetPath, "Script", "init.yue"), -- 2017
									dir = false, -- 2018
									builtin = true, -- 2019
									title = "init.yue" -- 2020
								} -- 2016
								return _with_0 -- 2015
							end -- 2014
						end)() -- 2014
					} -- 1995
				} -- 1990
			} -- 2024
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 2024
			local _idx_0 = #_tab_0 + 1 -- 2024
			for _index_0 = 1, #_obj_0 do -- 2024
				local _value_0 = _obj_0[_index_0] -- 2024
				_tab_0[_idx_0] = _value_0 -- 2024
				_idx_0 = _idx_0 + 1 -- 2024
			end -- 2024
			return _tab_0 -- 1990
		end)() -- 1989
	} -- 1984
end) -- 1920
HttpServer:post("/entry/list", function() -- 2028
	local Entry = require("Script.Dev.Entry") -- 2029
	local res = Entry.getLaunchEntries() -- 2030
	res.success = true -- 2031
	return res -- 2032
end) -- 2028
HttpServer:post("/run/status", function() -- 2034
	local Entry = require("Script.Dev.Entry") -- 2035
	return Entry.getCurrentEntryStatus() -- 2036
end) -- 2034
HttpServer:postSchedule("/run", function(req) -- 2038
	do -- 2039
		local _type_0 = type(req) -- 2039
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2039
		if _tab_0 then -- 2039
			local file -- 2039
			do -- 2039
				local _obj_0 = req.body -- 2039
				local _type_1 = type(_obj_0) -- 2039
				if "table" == _type_1 or "userdata" == _type_1 then -- 2039
					file = _obj_0.file -- 2039
				end -- 2039
			end -- 2039
			local asProj -- 2039
			do -- 2039
				local _obj_0 = req.body -- 2039
				local _type_1 = type(_obj_0) -- 2039
				if "table" == _type_1 or "userdata" == _type_1 then -- 2039
					asProj = _obj_0.asProj -- 2039
				end -- 2039
			end -- 2039
			if file ~= nil and asProj ~= nil then -- 2039
				if not Content:isAbsolutePath(file) then -- 2040
					local devFile = Path(Content.writablePath, file) -- 2041
					if Content:exist(devFile) then -- 2042
						file = devFile -- 2042
					end -- 2042
				end -- 2040
				local Entry = require("Script.Dev.Entry") -- 2043
				local workDir -- 2044
				if asProj then -- 2045
					local projectRoot = req.body.projectRoot -- 2046
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2047
						workDir = projectRoot -- 2048
					else -- 2050
						workDir = getProjectDirFromFile(file) -- 2050
					end -- 2047
					if workDir then -- 2051
						Entry.allClear() -- 2052
						local target = Path(workDir, "init") -- 2053
						local success, err = Entry.enterEntryAsync({ -- 2054
							entryName = "Project", -- 2054
							fileName = target, -- 2054
							workDir = workDir, -- 2054
							projectRoot = workDir, -- 2054
							runKind = "project" -- 2054
						}) -- 2054
						target = Path:getName(Path:getPath(target)) -- 2055
						return { -- 2056
							success = success, -- 2056
							target = target, -- 2056
							err = err -- 2056
						} -- 2056
					end -- 2051
				else -- 2058
					workDir = getProjectDirFromFile(file) -- 2058
					if not workDir and Path:getExt(file) == "wasm" then -- 2059
						local parent = Path:getPath(file) -- 2060
						if Content:exist(Path(parent, "wa.mod")) then -- 2061
							workDir = parent -- 2062
						end -- 2061
					end -- 2059
				end -- 2045
				Entry.allClear() -- 2063
				file = Path:replaceExt(file, "") -- 2064
				local entry = { -- 2066
					entryName = Path:getName(file), -- 2066
					fileName = file, -- 2067
					runKind = "file" -- 2068
				} -- 2065
				if workDir then -- 2069
					entry.workDir = workDir -- 2070
					entry.projectRoot = workDir -- 2071
				end -- 2069
				local success, err = Entry.enterEntryAsync(entry) -- 2072
				return { -- 2073
					success = success, -- 2073
					err = err -- 2073
				} -- 2073
			end -- 2039
		end -- 2039
	end -- 2039
	return { -- 2038
		success = false -- 2038
	} -- 2038
end) -- 2038
HttpServer:postSchedule("/stop", function() -- 2075
	local Entry = require("Script.Dev.Entry") -- 2076
	return { -- 2077
		success = Entry.stop() -- 2077
	} -- 2077
end) -- 2075
local minifyAsync -- 2079
minifyAsync = function(sourcePath, minifyPath) -- 2079
	if not Content:exist(sourcePath) then -- 2080
		return -- 2080
	end -- 2080
	local Entry = require("Script.Dev.Entry") -- 2081
	local errors = { } -- 2082
	local files = Entry.getAllFiles(sourcePath, { -- 2083
		"lua" -- 2083
	}, true) -- 2083
	do -- 2084
		local _accum_0 = { } -- 2084
		local _len_0 = 1 -- 2084
		for _index_0 = 1, #files do -- 2084
			local file = files[_index_0] -- 2084
			if file:sub(1, 1) ~= '.' then -- 2084
				_accum_0[_len_0] = file -- 2084
				_len_0 = _len_0 + 1 -- 2084
			end -- 2084
		end -- 2084
		files = _accum_0 -- 2084
	end -- 2084
	local paths -- 2085
	do -- 2085
		local _tbl_0 = { } -- 2085
		for _index_0 = 1, #files do -- 2085
			local file = files[_index_0] -- 2085
			_tbl_0[Path:getPath(file)] = true -- 2085
		end -- 2085
		paths = _tbl_0 -- 2085
	end -- 2085
	for path in pairs(paths) do -- 2086
		Content:mkdir(Path(minifyPath, path)) -- 2086
	end -- 2086
	local _ <close> = setmetatable({ }, { -- 2087
		__close = function() -- 2087
			package.loaded["luaminify.FormatMini"] = nil -- 2088
			package.loaded["luaminify.ParseLua"] = nil -- 2089
			package.loaded["luaminify.Scope"] = nil -- 2090
			package.loaded["luaminify.Util"] = nil -- 2091
		end -- 2087
	}) -- 2087
	local FormatMini -- 2092
	do -- 2092
		local _obj_0 = require("luaminify") -- 2092
		FormatMini = _obj_0.FormatMini -- 2092
	end -- 2092
	local fileCount = #files -- 2093
	local count = 0 -- 2094
	for _index_0 = 1, #files do -- 2095
		local file = files[_index_0] -- 2095
		thread(function() -- 2096
			local _ <close> = setmetatable({ }, { -- 2097
				__close = function() -- 2097
					count = count + 1 -- 2097
				end -- 2097
			}) -- 2097
			local input = Path(sourcePath, file) -- 2098
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2099
			if Content:exist(input) then -- 2100
				local sourceCodes = Content:loadAsync(input) -- 2101
				local res, err = FormatMini(sourceCodes) -- 2102
				if res then -- 2103
					Content:saveAsync(output, res) -- 2104
					return print("Minify " .. tostring(file)) -- 2105
				else -- 2107
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2107
				end -- 2103
			else -- 2109
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2109
			end -- 2100
		end) -- 2096
		sleep() -- 2110
	end -- 2095
	wait(function() -- 2111
		return count == fileCount -- 2111
	end) -- 2111
	if #errors > 0 then -- 2112
		print(table.concat(errors, '\n')) -- 2113
	end -- 2112
	print("Obfuscation done.") -- 2114
	return files -- 2115
end -- 2079
local zipping = false -- 2117
HttpServer:postSchedule("/zip", function(req) -- 2119
	do -- 2120
		local _type_0 = type(req) -- 2120
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2120
		if _tab_0 then -- 2120
			local path -- 2120
			do -- 2120
				local _obj_0 = req.body -- 2120
				local _type_1 = type(_obj_0) -- 2120
				if "table" == _type_1 or "userdata" == _type_1 then -- 2120
					path = _obj_0.path -- 2120
				end -- 2120
			end -- 2120
			local zipFile -- 2120
			do -- 2120
				local _obj_0 = req.body -- 2120
				local _type_1 = type(_obj_0) -- 2120
				if "table" == _type_1 or "userdata" == _type_1 then -- 2120
					zipFile = _obj_0.zipFile -- 2120
				end -- 2120
			end -- 2120
			local obfuscated -- 2120
			do -- 2120
				local _obj_0 = req.body -- 2120
				local _type_1 = type(_obj_0) -- 2120
				if "table" == _type_1 or "userdata" == _type_1 then -- 2120
					obfuscated = _obj_0.obfuscated -- 2120
				end -- 2120
			end -- 2120
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2120
				if zipping then -- 2121
					goto failed -- 2121
				end -- 2121
				zipping = true -- 2122
				local _ <close> = setmetatable({ }, { -- 2123
					__close = function() -- 2123
						zipping = false -- 2123
					end -- 2123
				}) -- 2123
				if not Content:exist(path) then -- 2124
					goto failed -- 2124
				end -- 2124
				Content:mkdir(Path:getPath(zipFile)) -- 2125
				if obfuscated then -- 2126
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2127
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2128
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2129
					Content:remove(scriptPath) -- 2130
					Content:remove(obfuscatedPath) -- 2131
					Content:remove(tempPath) -- 2132
					Content:mkdir(scriptPath) -- 2133
					Content:mkdir(obfuscatedPath) -- 2134
					Content:mkdir(tempPath) -- 2135
					if not Content:copyAsync(path, tempPath) then -- 2136
						goto failed -- 2136
					end -- 2136
					local Entry = require("Script.Dev.Entry") -- 2137
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2138
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2139
						"tl", -- 2139
						"yue", -- 2139
						"lua", -- 2139
						"ts", -- 2139
						"tsx", -- 2139
						"vs", -- 2139
						"bl", -- 2139
						"xml", -- 2139
						"wa", -- 2139
						"mod" -- 2139
					}, true) -- 2139
					for _index_0 = 1, #scriptFiles do -- 2140
						local file = scriptFiles[_index_0] -- 2140
						Content:remove(Path(tempPath, file)) -- 2141
					end -- 2140
					for _index_0 = 1, #luaFiles do -- 2142
						local file = luaFiles[_index_0] -- 2142
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2143
					end -- 2142
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2144
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2145
					end) then -- 2144
						goto failed -- 2144
					end -- 2144
					return { -- 2146
						success = true -- 2146
					} -- 2146
				else -- 2148
					return { -- 2148
						success = Content:zipAsync(path, zipFile, function(file) -- 2148
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2149
						end) -- 2148
					} -- 2148
				end -- 2126
			end -- 2120
		end -- 2120
	end -- 2120
	::failed:: -- 2150
	return { -- 2119
		success = false -- 2119
	} -- 2119
end) -- 2119
HttpServer:postSchedule("/unzip", function(req) -- 2152
	do -- 2153
		local _type_0 = type(req) -- 2153
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2153
		if _tab_0 then -- 2153
			local zipFile -- 2153
			do -- 2153
				local _obj_0 = req.body -- 2153
				local _type_1 = type(_obj_0) -- 2153
				if "table" == _type_1 or "userdata" == _type_1 then -- 2153
					zipFile = _obj_0.zipFile -- 2153
				end -- 2153
			end -- 2153
			local path -- 2153
			do -- 2153
				local _obj_0 = req.body -- 2153
				local _type_1 = type(_obj_0) -- 2153
				if "table" == _type_1 or "userdata" == _type_1 then -- 2153
					path = _obj_0.path -- 2153
				end -- 2153
			end -- 2153
			if zipFile ~= nil and path ~= nil then -- 2153
				return { -- 2154
					success = Content:unzipAsync(zipFile, path, function(file) -- 2154
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2155
					end) -- 2154
				} -- 2154
			end -- 2153
		end -- 2153
	end -- 2153
	return { -- 2152
		success = false -- 2152
	} -- 2152
end) -- 2152
HttpServer:post("/editing-info", function(req) -- 2157
	local Entry = require("Script.Dev.Entry") -- 2158
	local config = Entry.getConfig() -- 2159
	local _type_0 = type(req) -- 2160
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2160
	local _match_0 = false -- 2160
	if _tab_0 then -- 2160
		local editingInfo -- 2160
		do -- 2160
			local _obj_0 = req.body -- 2160
			local _type_1 = type(_obj_0) -- 2160
			if "table" == _type_1 or "userdata" == _type_1 then -- 2160
				editingInfo = _obj_0.editingInfo -- 2160
			end -- 2160
		end -- 2160
		if editingInfo ~= nil then -- 2160
			_match_0 = true -- 2160
			config.editingInfo = editingInfo -- 2161
			return { -- 2162
				success = true -- 2162
			} -- 2162
		end -- 2160
	end -- 2160
	if not _match_0 then -- 2160
		if not (config.editingInfo ~= nil) then -- 2164
			local folder -- 2165
			if App.locale:match('^zh') then -- 2165
				folder = 'zh-Hans' -- 2165
			else -- 2165
				folder = 'en' -- 2165
			end -- 2165
			config.editingInfo = json.encode({ -- 2167
				index = 0, -- 2167
				files = { -- 2169
					{ -- 2170
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2170
						title = "welcome.md" -- 2171
					} -- 2169
				} -- 2168
			}) -- 2166
		end -- 2164
		return { -- 2175
			success = true, -- 2175
			editingInfo = config.editingInfo -- 2175
		} -- 2175
	end -- 2160
end) -- 2157
HttpServer:post("/command", function(req) -- 2177
	do -- 2178
		local _type_0 = type(req) -- 2178
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2178
		if _tab_0 then -- 2178
			local code -- 2178
			do -- 2178
				local _obj_0 = req.body -- 2178
				local _type_1 = type(_obj_0) -- 2178
				if "table" == _type_1 or "userdata" == _type_1 then -- 2178
					code = _obj_0.code -- 2178
				end -- 2178
			end -- 2178
			local log -- 2178
			do -- 2178
				local _obj_0 = req.body -- 2178
				local _type_1 = type(_obj_0) -- 2178
				if "table" == _type_1 or "userdata" == _type_1 then -- 2178
					log = _obj_0.log -- 2178
				end -- 2178
			end -- 2178
			if code ~= nil and log ~= nil then -- 2178
				emit("AppCommand", code, log) -- 2179
				return { -- 2180
					success = true -- 2180
				} -- 2180
			end -- 2178
		end -- 2178
	end -- 2178
	return { -- 2177
		success = false -- 2177
	} -- 2177
end) -- 2177
HttpServer:post("/log/save", function() -- 2182
	local folder = ".download" -- 2183
	local fullLogFile = "dora_full_logs.txt" -- 2184
	local fullFolder = Path(Content.writablePath, folder) -- 2185
	Content:mkdir(fullFolder) -- 2186
	local logPath = Path(fullFolder, fullLogFile) -- 2187
	if App:saveLog(logPath) then -- 2188
		return { -- 2189
			success = true, -- 2189
			path = Path(folder, fullLogFile) -- 2189
		} -- 2189
	end -- 2188
	return { -- 2182
		success = false -- 2182
	} -- 2182
end) -- 2182
local tailLines -- 2191
tailLines = function(text, count) -- 2191
	local lines = { } -- 2192
	text = text:gsub("\r\n", "\n") -- 2193
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2194
		lines[#lines + 1] = line -- 2195
	end -- 2194
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2196
		table.remove(lines) -- 2197
	end -- 2196
	local start = math.max(1, #lines - count + 1) -- 2198
	local out = { } -- 2199
	for i = start, #lines do -- 2200
		out[#out + 1] = lines[i] -- 2201
	end -- 2200
	return table.concat(out, "\n") -- 2202
end -- 2191
HttpServer:post("/log", function(req) -- 2204
	local count = 100 -- 2205
	if req and req.body and req.body.count ~= nil then -- 2206
		count = req.body.count -- 2207
	end -- 2206
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2208
		return { -- 2209
			success = false, -- 2209
			message = "count must be a positive integer" -- 2209
		} -- 2209
	end -- 2208
	local folder = ".download" -- 2210
	local fullLogFile = "dora_full_logs.txt" -- 2211
	local fullFolder = Path(Content.writablePath, folder) -- 2212
	Content:mkdir(fullFolder) -- 2213
	local logPath = Path(fullFolder, fullLogFile) -- 2214
	if App:saveLog(logPath) then -- 2215
		local text = Content:load(logPath) -- 2216
		if text then -- 2217
			return { -- 2218
				success = true, -- 2218
				log = tailLines(text, count) -- 2218
			} -- 2218
		else -- 2220
			return { -- 2220
				success = false, -- 2220
				message = "failed to read log" -- 2220
			} -- 2220
		end -- 2217
	else -- 2222
		return { -- 2222
			success = false, -- 2222
			message = "failed to save log" -- 2222
		} -- 2222
	end -- 2215
	return { -- 2204
		success = false -- 2204
	} -- 2204
end) -- 2204
HttpServer:post("/yarn/check", function(req) -- 2224
	local yarncompile = require("yarncompile") -- 2225
	do -- 2226
		local _type_0 = type(req) -- 2226
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2226
		if _tab_0 then -- 2226
			local code -- 2226
			do -- 2226
				local _obj_0 = req.body -- 2226
				local _type_1 = type(_obj_0) -- 2226
				if "table" == _type_1 or "userdata" == _type_1 then -- 2226
					code = _obj_0.code -- 2226
				end -- 2226
			end -- 2226
			if code ~= nil then -- 2226
				local jsonObject = json.decode(code) -- 2227
				if jsonObject then -- 2227
					local errors = { } -- 2228
					local _list_0 = jsonObject.nodes -- 2229
					for _index_0 = 1, #_list_0 do -- 2229
						local node = _list_0[_index_0] -- 2229
						local title, body = node.title, node.body -- 2230
						local luaCode, err = yarncompile(body) -- 2231
						if not luaCode then -- 2231
							errors[#errors + 1] = title .. ":" .. err -- 2232
						end -- 2231
					end -- 2229
					return { -- 2233
						success = true, -- 2233
						syntaxError = table.concat(errors, "\n\n") -- 2233
					} -- 2233
				end -- 2227
			end -- 2226
		end -- 2226
	end -- 2226
	return { -- 2224
		success = false -- 2224
	} -- 2224
end) -- 2224
HttpServer:post("/yarn/check-file", function(req) -- 2235
	local yarncompile = require("yarncompile") -- 2236
	do -- 2237
		local _type_0 = type(req) -- 2237
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2237
		if _tab_0 then -- 2237
			local code -- 2237
			do -- 2237
				local _obj_0 = req.body -- 2237
				local _type_1 = type(_obj_0) -- 2237
				if "table" == _type_1 or "userdata" == _type_1 then -- 2237
					code = _obj_0.code -- 2237
				end -- 2237
			end -- 2237
			if code ~= nil then -- 2237
				local res, _, err = yarncompile(code, true) -- 2238
				if not res then -- 2238
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2239
					return { -- 2240
						success = false, -- 2240
						message = message, -- 2240
						line = line, -- 2240
						column = column, -- 2240
						node = node -- 2240
					} -- 2240
				end -- 2238
			end -- 2237
		end -- 2237
	end -- 2237
	return { -- 2235
		success = true -- 2235
	} -- 2235
end) -- 2235
getWaProjectDirFromFile = function(file) -- 2242
	local current -- 2243
	if Content:isdir(file) then -- 2243
		current = file -- 2243
	else -- 2243
		current = Path:getPath(file) -- 2243
	end -- 2243
	if current == "" then -- 2244
		return nil -- 2244
	end -- 2244
	repeat -- 2245
		local modPath = Path(current, "wa.mod") -- 2246
		if Content:exist(modPath) then -- 2247
			return current, modPath -- 2248
		end -- 2247
		local parent = Path:getPath(current) -- 2249
		if parent == "" or parent == current then -- 2250
			break -- 2250
		end -- 2250
		current = parent -- 2251
	until false -- 2245
	return nil -- 2253
end -- 2242
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2255
	do -- 2256
		local _type_0 = type(req) -- 2256
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2256
		if _tab_0 then -- 2256
			local path -- 2256
			do -- 2256
				local _obj_0 = req.body -- 2256
				local _type_1 = type(_obj_0) -- 2256
				if "table" == _type_1 or "userdata" == _type_1 then -- 2256
					path = _obj_0.path -- 2256
				end -- 2256
			end -- 2256
			if path ~= nil then -- 2256
				local projDir = getWaProjectDirFromFile(path) -- 2257
				if projDir then -- 2257
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2258
					if not Content:exist(sourceDoraPath) then -- 2259
						return { -- 2260
							success = false, -- 2260
							message = "missing dora template" -- 2260
						} -- 2260
					end -- 2259
					local targetVendorPath = Path(projDir, "vendor") -- 2261
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2262
					if not Content:exist(targetVendorPath) then -- 2263
						if not Content:mkdir(targetVendorPath) then -- 2264
							return { -- 2265
								success = false, -- 2265
								message = "failed to create vendor folder" -- 2265
							} -- 2265
						end -- 2264
					elseif not Content:isdir(targetVendorPath) then -- 2266
						return { -- 2267
							success = false, -- 2267
							message = "vendor path is not a folder" -- 2267
						} -- 2267
					end -- 2263
					if Content:exist(targetDoraPath) then -- 2268
						if not Content:remove(targetDoraPath) then -- 2269
							return { -- 2270
								success = false, -- 2270
								message = "failed to remove old dora" -- 2270
							} -- 2270
						end -- 2269
					end -- 2268
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2271
						return { -- 2272
							success = false, -- 2272
							message = "failed to copy dora" -- 2272
						} -- 2272
					end -- 2271
					return { -- 2273
						success = true -- 2273
					} -- 2273
				else -- 2275
					return { -- 2275
						success = false, -- 2275
						message = 'Wa file needs a project' -- 2275
					} -- 2275
				end -- 2257
			end -- 2256
		end -- 2256
	end -- 2256
	return { -- 2255
		success = false, -- 2255
		message = "invalid call" -- 2255
	} -- 2255
end) -- 2255
HttpServer:postSchedule("/wa/build", function(req) -- 2277
	do -- 2278
		local _type_0 = type(req) -- 2278
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2278
		if _tab_0 then -- 2278
			local path -- 2278
			do -- 2278
				local _obj_0 = req.body -- 2278
				local _type_1 = type(_obj_0) -- 2278
				if "table" == _type_1 or "userdata" == _type_1 then -- 2278
					path = _obj_0.path -- 2278
				end -- 2278
			end -- 2278
			if path ~= nil then -- 2278
				local projDir = getWaProjectDirFromFile(path) -- 2279
				if projDir then -- 2279
					local message = Wasm:buildWaAsync(projDir) -- 2280
					if message == "" then -- 2281
						return { -- 2282
							success = true -- 2282
						} -- 2282
					else -- 2284
						return { -- 2284
							success = false, -- 2284
							message = message -- 2284
						} -- 2284
					end -- 2281
				else -- 2286
					return { -- 2286
						success = false, -- 2286
						message = 'Wa file needs a project' -- 2286
					} -- 2286
				end -- 2279
			end -- 2278
		end -- 2278
	end -- 2278
	return { -- 2287
		success = false, -- 2287
		message = 'failed to build' -- 2287
	} -- 2287
end) -- 2277
HttpServer:postSchedule("/wa/format", function(req) -- 2289
	do -- 2290
		local _type_0 = type(req) -- 2290
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2290
		if _tab_0 then -- 2290
			local file -- 2290
			do -- 2290
				local _obj_0 = req.body -- 2290
				local _type_1 = type(_obj_0) -- 2290
				if "table" == _type_1 or "userdata" == _type_1 then -- 2290
					file = _obj_0.file -- 2290
				end -- 2290
			end -- 2290
			if file ~= nil then -- 2290
				local code = Wasm:formatWaAsync(file) -- 2291
				if code == "" then -- 2292
					return { -- 2293
						success = false -- 2293
					} -- 2293
				else -- 2295
					return { -- 2295
						success = true, -- 2295
						code = code -- 2295
					} -- 2295
				end -- 2292
			end -- 2290
		end -- 2290
	end -- 2290
	return { -- 2296
		success = false -- 2296
	} -- 2296
end) -- 2289
HttpServer:postSchedule("/wa/create", function(req) -- 2298
	do -- 2299
		local _type_0 = type(req) -- 2299
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2299
		if _tab_0 then -- 2299
			local path -- 2299
			do -- 2299
				local _obj_0 = req.body -- 2299
				local _type_1 = type(_obj_0) -- 2299
				if "table" == _type_1 or "userdata" == _type_1 then -- 2299
					path = _obj_0.path -- 2299
				end -- 2299
			end -- 2299
			if path ~= nil then -- 2299
				if not Content:exist(Path:getPath(path)) then -- 2300
					return { -- 2301
						success = false, -- 2301
						message = "target path not existed" -- 2301
					} -- 2301
				end -- 2300
				if Content:exist(path) then -- 2302
					return { -- 2303
						success = false, -- 2303
						message = "target project folder existed" -- 2303
					} -- 2303
				end -- 2302
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2304
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2305
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2306
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2307
					return { -- 2310
						success = false, -- 2310
						message = "missing template project" -- 2310
					} -- 2310
				end -- 2307
				if not Content:mkdir(path) then -- 2311
					return { -- 2312
						success = false, -- 2312
						message = "failed to create project folder" -- 2312
					} -- 2312
				end -- 2311
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2313
					Content:remove(path) -- 2314
					return { -- 2315
						success = false, -- 2315
						message = "failed to copy template" -- 2315
					} -- 2315
				end -- 2313
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2316
					Content:remove(path) -- 2317
					return { -- 2318
						success = false, -- 2318
						message = "failed to copy template" -- 2318
					} -- 2318
				end -- 2316
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2319
					Content:remove(path) -- 2320
					return { -- 2321
						success = false, -- 2321
						message = "failed to copy template" -- 2321
					} -- 2321
				end -- 2319
				return { -- 2322
					success = true -- 2322
				} -- 2322
			end -- 2299
		end -- 2299
	end -- 2299
	return { -- 2298
		success = false, -- 2298
		message = "invalid call" -- 2298
	} -- 2298
end) -- 2298
local tsBuildGlobs = { -- 2325
	"**/*.ts", -- 2325
	"**/*.tsx", -- 2326
	"!**/.*/**", -- 2327
	"!**/node_modules/**" -- 2328
} -- 2324
local transpileTSFile -- 2330
do -- 2330
	local tsBuildTimeout <const> = 30 -- 2331
	local tsBuildRequestId = 0 -- 2332
	transpileTSFile = function(file, content, sourceRoot) -- 2333
		tsBuildRequestId = tsBuildRequestId + 1 -- 2334
		local requestId = tsBuildRequestId -- 2335
		local done = false -- 2336
		local result = nil -- 2337
		local listener = Node() -- 2338
		listener:gslot("AppWS", function(event) -- 2339
			if event.type == "Receive" then -- 2340
				local res = json.decode(event.msg) -- 2341
				if res then -- 2341
					if res.name == "TranspileTS" and res.id == requestId then -- 2342
						listener:removeFromParent() -- 2343
						if res.success then -- 2344
							local luaFile = Path:replaceExt(file, "lua") -- 2345
							Content:save(luaFile, res.luaCode) -- 2346
							result = { -- 2347
								success = true, -- 2347
								file = file -- 2347
							} -- 2347
						else -- 2349
							result = { -- 2349
								success = false, -- 2349
								file = file, -- 2349
								message = res.message -- 2349
							} -- 2349
						end -- 2344
						done = true -- 2350
					end -- 2342
				end -- 2341
			end -- 2340
		end) -- 2339
		emit("AppWS", "Send", json.encode({ -- 2351
			name = "TranspileTS", -- 2351
			id = requestId, -- 2351
			file = file, -- 2351
			content = content, -- 2351
			projectRoot = sourceRoot -- 2351
		})) -- 2351
		local deadline = App.runningTime + tsBuildTimeout -- 2352
		wait(function() -- 2353
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline -- 2353
		end) -- 2353
		if not done then -- 2354
			listener:removeFromParent() -- 2355
			if HttpServer.wsConnectionCount == 0 then -- 2356
				return { -- 2357
					success = false, -- 2357
					file = file, -- 2357
					message = "Web IDE disconnected" -- 2357
				} -- 2357
			end -- 2356
			return { -- 2358
				success = false, -- 2358
				file = file, -- 2358
				message = "TypeScript transpile timed out" -- 2358
			} -- 2358
		end -- 2354
		return result -- 2359
	end -- 2333
end -- 2330
local _anon_func_6 = function(path) -- 2370
	local _val_0 = Path:getExt(path) -- 2370
	return "ts" == _val_0 or "tsx" == _val_0 -- 2370
end -- 2370
HttpServer:postSchedule("/ts/build", function(req) -- 2361
	do -- 2362
		local _type_0 = type(req) -- 2362
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2362
		if _tab_0 then -- 2362
			local path -- 2362
			do -- 2362
				local _obj_0 = req.body -- 2362
				local _type_1 = type(_obj_0) -- 2362
				if "table" == _type_1 or "userdata" == _type_1 then -- 2362
					path = _obj_0.path -- 2362
				end -- 2362
			end -- 2362
			if path ~= nil then -- 2362
				if HttpServer.wsConnectionCount == 0 then -- 2363
					return { -- 2364
						success = false, -- 2364
						message = "Web IDE not connected" -- 2364
					} -- 2364
				end -- 2363
				local projectRoot = req.body.projectRoot -- 2365
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2366
				if not Content:exist(path) then -- 2367
					return { -- 2368
						success = false, -- 2368
						message = "path not existed" -- 2368
					} -- 2368
				end -- 2367
				if not Content:isdir(path) then -- 2369
					if not (_anon_func_6(path)) then -- 2370
						return { -- 2371
							success = false, -- 2371
							message = "expecting a TypeScript file" -- 2371
						} -- 2371
					end -- 2370
					local messages = { } -- 2372
					local content = Content:load(path) -- 2373
					if not content then -- 2374
						return { -- 2375
							success = false, -- 2375
							message = "failed to read file" -- 2375
						} -- 2375
					end -- 2374
					emit("AppWS", "Send", json.encode({ -- 2376
						name = "UpdateFile", -- 2376
						file = path, -- 2376
						exists = true, -- 2376
						content = content, -- 2376
						projectRoot = sourceRoot -- 2376
					})) -- 2376
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2377
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot) -- 2378
					end -- 2377
					return { -- 2379
						success = true, -- 2379
						messages = messages -- 2379
					} -- 2379
				else -- 2381
					local fileData = { } -- 2381
					local messages = { } -- 2382
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2383
					for _index_0 = 1, #_list_0 do -- 2383
						local subFile = _list_0[_index_0] -- 2383
						local file = Path(path, subFile) -- 2384
						local content = Content:load(file) -- 2385
						if content then -- 2385
							fileData[file] = content -- 2386
							emit("AppWS", "Send", json.encode({ -- 2387
								name = "UpdateFile", -- 2387
								file = file, -- 2387
								exists = true, -- 2387
								content = content, -- 2387
								projectRoot = sourceRoot -- 2387
							})) -- 2387
						else -- 2389
							messages[#messages + 1] = { -- 2389
								success = false, -- 2389
								file = file, -- 2389
								message = "failed to read file" -- 2389
							} -- 2389
						end -- 2385
					end -- 2383
					for file, content in pairs(fileData) do -- 2390
						if "d" == Path:getExt(Path:getName(file)) then -- 2391
							goto _continue_0 -- 2391
						end -- 2391
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot) -- 2392
						::_continue_0:: -- 2391
					end -- 2390
					return { -- 2393
						success = true, -- 2393
						messages = messages -- 2393
					} -- 2393
				end -- 2369
			end -- 2362
		end -- 2362
	end -- 2362
	return { -- 2361
		success = false -- 2361
	} -- 2361
end) -- 2361
HttpServer:post("/download", function(req) -- 2395
	do -- 2396
		local _type_0 = type(req) -- 2396
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2396
		if _tab_0 then -- 2396
			local url -- 2396
			do -- 2396
				local _obj_0 = req.body -- 2396
				local _type_1 = type(_obj_0) -- 2396
				if "table" == _type_1 or "userdata" == _type_1 then -- 2396
					url = _obj_0.url -- 2396
				end -- 2396
			end -- 2396
			local target -- 2396
			do -- 2396
				local _obj_0 = req.body -- 2396
				local _type_1 = type(_obj_0) -- 2396
				if "table" == _type_1 or "userdata" == _type_1 then -- 2396
					target = _obj_0.target -- 2396
				end -- 2396
			end -- 2396
			if url ~= nil and target ~= nil then -- 2396
				local Entry = require("Script.Dev.Entry") -- 2397
				Entry.downloadFile(url, target) -- 2398
				return { -- 2399
					success = true -- 2399
				} -- 2399
			end -- 2396
		end -- 2396
	end -- 2396
	return { -- 2395
		success = false -- 2395
	} -- 2395
end) -- 2395
local isDesktopPlatform -- 2401
isDesktopPlatform = function() -- 2401
	local _val_0 = App.platform -- 2402
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2402
end -- 2401
local getServerStatus -- 2404
getServerStatus = function() -- 2404
	local Entry = require("Script.Dev.Entry") -- 2405
	local running = Entry.getCurrentEntryStatus() -- 2406
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2407
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2408
	return { -- 2410
		success = true, -- 2410
		platform = App.platform, -- 2411
		locale = App.locale, -- 2412
		version = App.version, -- 2413
		url = "http://localhost:8866", -- 2414
		wsConnectionCount = wsConnectionCount, -- 2415
		webIDEConnected = wsConnectionCount > 0, -- 2416
		assetPath = Content.assetPath, -- 2417
		writablePath = Content.writablePath, -- 2418
		appPath = Content.appPath, -- 2419
		waTemplateReady = waTemplateReady, -- 2420
		running = running -- 2421
	} -- 2409
end -- 2404
HttpServer:post("/status", function() -- 2424
	return getServerStatus() -- 2425
end) -- 2424
HttpServer:postSchedule("/doctor/fix", function(req) -- 2427
	do -- 2428
		local _type_0 = type(req) -- 2428
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2428
		if _tab_0 then -- 2428
			local openWebIDE -- 2428
			do -- 2428
				local _obj_0 = req.body -- 2428
				local _type_1 = type(_obj_0) -- 2428
				if "table" == _type_1 or "userdata" == _type_1 then -- 2428
					openWebIDE = _obj_0.openWebIDE -- 2428
				end -- 2428
			end -- 2428
			if openWebIDE ~= nil then -- 2428
				if not openWebIDE then -- 2429
					return { -- 2430
						success = false, -- 2430
						message = "nothing to fix" -- 2430
					} -- 2430
				end -- 2429
				local status = getServerStatus() -- 2431
				if status.webIDEConnected then -- 2432
					return { -- 2433
						success = true, -- 2433
						fixed = false, -- 2433
						message = "Web IDE already connected.", -- 2433
						status = status -- 2433
					} -- 2433
				end -- 2432
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2434
				if waitSeconds > 0 then -- 2435
					local deadline = os.time() + waitSeconds -- 2436
					repeat -- 2437
						sleep(0.2) -- 2438
						status = getServerStatus() -- 2439
						if status.webIDEConnected then -- 2440
							return { -- 2441
								success = true, -- 2441
								fixed = false, -- 2441
								reconnected = true, -- 2441
								message = "Web IDE reconnected.", -- 2441
								status = status -- 2441
							} -- 2441
						end -- 2440
					until os.time() >= deadline -- 2437
				end -- 2435
				if not isDesktopPlatform() then -- 2443
					return { -- 2444
						success = false, -- 2444
						message = "opening Web IDE is only supported on desktop platforms", -- 2444
						status = status -- 2444
					} -- 2444
				end -- 2443
				local url = "http://localhost:8866" -- 2445
				App:openURL(url) -- 2446
				status.openedURL = url -- 2447
				return { -- 2448
					success = true, -- 2448
					fixed = true, -- 2448
					message = "Opened Web IDE in the local browser.", -- 2448
					url = url, -- 2448
					status = status -- 2448
				} -- 2448
			end -- 2428
		end -- 2428
	end -- 2428
	return { -- 2427
		success = false, -- 2427
		message = "invalid call" -- 2427
	} -- 2427
end) -- 2427
local status = { } -- 2450
_module_0 = status -- 2451
status.buildAsync = function(path) -- 2453
	if not Content:exist(path) then -- 2454
		return { -- 2455
			success = false, -- 2455
			file = path, -- 2455
			message = "file not existed" -- 2455
		} -- 2455
	end -- 2454
	do -- 2456
		local _exp_0 = Path:getExt(path) -- 2456
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2456
			if '' == Path:getExt(Path:getName(path)) then -- 2457
				local content = Content:loadAsync(path) -- 2458
				if content then -- 2458
					local resultCodes, err = compileFileAsync(path, content) -- 2459
					if resultCodes then -- 2459
						return { -- 2460
							success = true, -- 2460
							file = path -- 2460
						} -- 2460
					else -- 2462
						return { -- 2462
							success = false, -- 2462
							file = path, -- 2462
							message = err -- 2462
						} -- 2462
					end -- 2459
				end -- 2458
			end -- 2457
		elseif "lua" == _exp_0 then -- 2463
			local content = Content:loadAsync(path) -- 2464
			if content then -- 2464
				do -- 2465
					local isTIC80 = CheckTIC80Code(content) -- 2465
					if isTIC80 then -- 2465
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2466
					end -- 2465
				end -- 2465
				local success, info -- 2467
				do -- 2467
					local _obj_0 = luaCheck(path, content) -- 2467
					success, info = _obj_0.success, _obj_0.info -- 2467
				end -- 2467
				if success then -- 2468
					return { -- 2469
						success = true, -- 2469
						file = path -- 2469
					} -- 2469
				elseif info and #info > 0 then -- 2470
					local messages = { } -- 2471
					for _index_0 = 1, #info do -- 2472
						local _des_0 = info[_index_0] -- 2472
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2472
						local lineText = "" -- 2473
						if line then -- 2474
							local currentLine = 1 -- 2475
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2476
								if currentLine == line then -- 2477
									lineText = text -- 2478
									break -- 2479
								end -- 2477
								currentLine = currentLine + 1 -- 2480
							end -- 2476
						end -- 2474
						if line then -- 2481
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2482
						else -- 2484
							messages[#messages + 1] = message -- 2484
						end -- 2481
					end -- 2472
					return { -- 2485
						success = false, -- 2485
						file = path, -- 2485
						message = table.concat(messages, "\n") -- 2485
					} -- 2485
				else -- 2487
					return { -- 2487
						success = false, -- 2487
						file = path, -- 2487
						message = "lua check failed" -- 2487
					} -- 2487
				end -- 2468
			end -- 2464
		elseif "yarn" == _exp_0 then -- 2488
			local content = Content:loadAsync(path) -- 2489
			if content then -- 2489
				local res, _, err = yarncompile(content, true) -- 2490
				if res then -- 2490
					return { -- 2491
						success = true, -- 2491
						file = path -- 2491
					} -- 2491
				else -- 2493
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2493
					local lineText = "" -- 2494
					if line then -- 2495
						local currentLine = 1 -- 2496
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2497
							if currentLine == line then -- 2498
								lineText = text -- 2499
								break -- 2500
							end -- 2498
							currentLine = currentLine + 1 -- 2501
						end -- 2497
					end -- 2495
					if node ~= "" then -- 2502
						node = "node: " .. tostring(node) .. ", " -- 2503
					else -- 2504
						node = "" -- 2504
					end -- 2502
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2505
					return { -- 2506
						success = false, -- 2506
						file = path, -- 2506
						message = message -- 2506
					} -- 2506
				end -- 2490
			end -- 2489
		end -- 2456
	end -- 2456
	return { -- 2507
		success = false, -- 2507
		file = path, -- 2507
		message = "invalid file to build" -- 2507
	} -- 2507
end -- 2453
thread(function() -- 2509
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 2510
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 2511
	if Content:exist(doraWeb) then -- 2512
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) -- 2513
		local needReload -- 2514
		if Content:exist(doraReady) then -- 2514
			needReload = readyContent ~= Content:load(doraReady) -- 2515
		else -- 2516
			needReload = true -- 2516
		end -- 2514
		if needReload then -- 2517
			Content:remove(Path(Content.appPath, ".www")) -- 2518
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 2519
			Content:save(doraReady, readyContent) -- 2523
			print("Dora Dora is ready!") -- 2524
		end -- 2517
	end -- 2512
	if HttpServer:start(8866) then -- 2525
		local localIP = HttpServer.localIP -- 2526
		if localIP == "" then -- 2527
			localIP = "localhost" -- 2527
		end -- 2527
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 2528
		return HttpServer:startWS(8868) -- 2529
	else -- 2531
		status.url = nil -- 2531
		return print("8866 Port not available!") -- 2532
	end -- 2525
end) -- 2509
return _module_0 -- 1
