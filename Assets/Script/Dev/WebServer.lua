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
		if isProjectRootDir(target) then -- 130
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
					return invalidArguments -- 1490
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
	return invalidArguments -- 1484
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
					return invalidArguments -- 1527
				end -- 1527
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
				if active then -- 1535
					active = 1 -- 1535
				else -- 1535
					active = 0 -- 1535
				end -- 1535
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, active = ?, updated_at = ?\n			where id = ?", { -- 1540
					tostring(name), -- 1540
					tostring(url), -- 1541
					tostring(model), -- 1542
					tostring(key), -- 1543
					contextWindow, -- 1544
					temperature, -- 1545
					maxTokens, -- 1546
					reasoningEffort, -- 1547
					customOptions, -- 1548
					supportsFunctionCalling, -- 1549
					active, -- 1550
					now, -- 1551
					id -- 1552
				}) -- 1536
				return { -- 1554
					success = affected >= 0 -- 1554
				} -- 1554
			end -- 1523
		end -- 1523
	end -- 1523
	return invalidArguments -- 1521
end) -- 1521
HttpServer:post("/llm/delete", function(req) -- 1556
	ensureLLMConfigTable() -- 1557
	do -- 1558
		local _type_0 = type(req) -- 1558
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1558
		if _tab_0 then -- 1558
			local id -- 1558
			do -- 1558
				local _obj_0 = req.body -- 1558
				local _type_1 = type(_obj_0) -- 1558
				if "table" == _type_1 or "userdata" == _type_1 then -- 1558
					id = _obj_0.id -- 1558
				end -- 1558
			end -- 1558
			if id ~= nil then -- 1558
				id = tonumber(id) -- 1559
				if id == nil then -- 1560
					return invalidArguments -- 1560
				end -- 1560
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1561
					id -- 1561
				}) -- 1561
				return { -- 1562
					success = affected >= 0 -- 1562
				} -- 1562
			end -- 1558
		end -- 1558
	end -- 1558
	return invalidArguments -- 1556
end) -- 1556
HttpServer:post("/stat", function(req) -- 1564
	do -- 1565
		local _type_0 = type(req) -- 1565
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1565
		if _tab_0 then -- 1565
			local path -- 1565
			do -- 1565
				local _obj_0 = req.body -- 1565
				local _type_1 = type(_obj_0) -- 1565
				if "table" == _type_1 or "userdata" == _type_1 then -- 1565
					path = _obj_0.path -- 1565
				end -- 1565
			end -- 1565
			if path ~= nil then -- 1565
				if not Content:exist(path) then -- 1566
					return { -- 1567
						success = false, -- 1567
						message = "target not existed" -- 1567
					} -- 1567
				end -- 1566
				if Content:isdir(path) then -- 1568
					return { -- 1569
						success = false, -- 1569
						message = "failed to stat a directory" -- 1569
					} -- 1569
				end -- 1568
				local size, isBinary = Content:getAttr(path) -- 1570
				if size then -- 1570
					return { -- 1571
						success = true, -- 1571
						size = size, -- 1571
						isBinary = isBinary -- 1571
					} -- 1571
				end -- 1570
			end -- 1565
		end -- 1565
	end -- 1565
	return { -- 1564
		success = false, -- 1564
		message = "failed to stat" -- 1564
	} -- 1564
end) -- 1564
HttpServer:post("/new", function(req) -- 1573
	do -- 1574
		local _type_0 = type(req) -- 1574
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1574
		if _tab_0 then -- 1574
			local path -- 1574
			do -- 1574
				local _obj_0 = req.body -- 1574
				local _type_1 = type(_obj_0) -- 1574
				if "table" == _type_1 or "userdata" == _type_1 then -- 1574
					path = _obj_0.path -- 1574
				end -- 1574
			end -- 1574
			local content -- 1574
			do -- 1574
				local _obj_0 = req.body -- 1574
				local _type_1 = type(_obj_0) -- 1574
				if "table" == _type_1 or "userdata" == _type_1 then -- 1574
					content = _obj_0.content -- 1574
				end -- 1574
			end -- 1574
			local folder -- 1574
			do -- 1574
				local _obj_0 = req.body -- 1574
				local _type_1 = type(_obj_0) -- 1574
				if "table" == _type_1 or "userdata" == _type_1 then -- 1574
					folder = _obj_0.folder -- 1574
				end -- 1574
			end -- 1574
			if path ~= nil and content ~= nil and folder ~= nil then -- 1574
				if Content:exist(path) then -- 1575
					return { -- 1576
						success = false, -- 1576
						message = "TargetExisted" -- 1576
					} -- 1576
				end -- 1575
				local parent = Path:getPath(path) -- 1577
				local files = Content:getFiles(parent) -- 1578
				if folder then -- 1579
					local name = Path:getFilename(path):lower() -- 1580
					for _index_0 = 1, #files do -- 1581
						local file = files[_index_0] -- 1581
						if name == Path:getFilename(file):lower() then -- 1582
							return { -- 1583
								success = false, -- 1583
								message = "TargetExisted" -- 1583
							} -- 1583
						end -- 1582
					end -- 1581
					if Content:mkdir(path) then -- 1584
						return { -- 1585
							success = true -- 1585
						} -- 1585
					end -- 1584
				else -- 1587
					local name = Path:getName(path):lower() -- 1587
					for _index_0 = 1, #files do -- 1588
						local file = files[_index_0] -- 1588
						if name == Path:getName(file):lower() then -- 1589
							local ext = Path:getExt(file) -- 1590
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1591
								goto _continue_0 -- 1592
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1593
								goto _continue_0 -- 1594
							end -- 1591
							return { -- 1595
								success = false, -- 1595
								message = "SourceExisted" -- 1595
							} -- 1595
						end -- 1589
						::_continue_0:: -- 1589
					end -- 1588
					if Content:save(path, content) then -- 1596
						return { -- 1597
							success = true -- 1597
						} -- 1597
					end -- 1596
				end -- 1579
			end -- 1574
		end -- 1574
	end -- 1574
	return { -- 1573
		success = false, -- 1573
		message = "Failed" -- 1573
	} -- 1573
end) -- 1573
HttpServer:post("/delete", function(req) -- 1599
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
			if path ~= nil then -- 1600
				if Content:exist(path) then -- 1601
					local projectRoot -- 1602
					if Content:isdir(path) and isProjectRootDir(path) then -- 1602
						projectRoot = path -- 1602
					else -- 1602
						projectRoot = nil -- 1602
					end -- 1602
					local parent = Path:getPath(path) -- 1603
					local files = Content:getFiles(parent) -- 1604
					local name = Path:getName(path):lower() -- 1605
					local ext = Path:getExt(path) -- 1606
					for _index_0 = 1, #files do -- 1607
						local file = files[_index_0] -- 1607
						if name == Path:getName(file):lower() then -- 1608
							local _exp_0 = Path:getExt(file) -- 1609
							if "tl" == _exp_0 then -- 1609
								if ("vs" == ext) then -- 1609
									Content:remove(Path(parent, file)) -- 1610
								end -- 1609
							elseif "lua" == _exp_0 then -- 1611
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1611
									Content:remove(Path(parent, file)) -- 1612
								end -- 1611
							end -- 1609
						end -- 1608
					end -- 1607
					if Content:remove(path) then -- 1613
						if projectRoot then -- 1614
							AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1615
						end -- 1614
						return { -- 1616
							success = true -- 1616
						} -- 1616
					end -- 1613
				end -- 1601
			end -- 1600
		end -- 1600
	end -- 1600
	return { -- 1599
		success = false -- 1599
	} -- 1599
end) -- 1599
HttpServer:post("/rename", function(req) -- 1618
	do -- 1619
		local _type_0 = type(req) -- 1619
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1619
		if _tab_0 then -- 1619
			local old -- 1619
			do -- 1619
				local _obj_0 = req.body -- 1619
				local _type_1 = type(_obj_0) -- 1619
				if "table" == _type_1 or "userdata" == _type_1 then -- 1619
					old = _obj_0.old -- 1619
				end -- 1619
			end -- 1619
			local new -- 1619
			do -- 1619
				local _obj_0 = req.body -- 1619
				local _type_1 = type(_obj_0) -- 1619
				if "table" == _type_1 or "userdata" == _type_1 then -- 1619
					new = _obj_0.new -- 1619
				end -- 1619
			end -- 1619
			if old ~= nil and new ~= nil then -- 1619
				if Content:exist(old) and not Content:exist(new) then -- 1620
					local renamedDir = Content:isdir(old) -- 1621
					local parent = Path:getPath(new) -- 1622
					local files = Content:getFiles(parent) -- 1623
					if renamedDir then -- 1624
						local name = Path:getFilename(new):lower() -- 1625
						for _index_0 = 1, #files do -- 1626
							local file = files[_index_0] -- 1626
							if name == Path:getFilename(file):lower() then -- 1627
								return { -- 1628
									success = false -- 1628
								} -- 1628
							end -- 1627
						end -- 1626
					else -- 1630
						local name = Path:getName(new):lower() -- 1630
						local ext = Path:getExt(new) -- 1631
						for _index_0 = 1, #files do -- 1632
							local file = files[_index_0] -- 1632
							if name == Path:getName(file):lower() then -- 1633
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1634
									goto _continue_0 -- 1635
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1636
									goto _continue_0 -- 1637
								end -- 1634
								return { -- 1638
									success = false -- 1638
								} -- 1638
							end -- 1633
							::_continue_0:: -- 1633
						end -- 1632
					end -- 1624
					if Content:move(old, new) then -- 1639
						if renamedDir then -- 1640
							AgentSession.renameSessionsByProjectRoot(old, new) -- 1641
						end -- 1640
						local newParent = Path:getPath(new) -- 1642
						parent = Path:getPath(old) -- 1643
						files = Content:getFiles(parent) -- 1644
						local newName = Path:getName(new) -- 1645
						local oldName = Path:getName(old) -- 1646
						local name = oldName:lower() -- 1647
						local ext = Path:getExt(old) -- 1648
						for _index_0 = 1, #files do -- 1649
							local file = files[_index_0] -- 1649
							if name == Path:getName(file):lower() then -- 1650
								local _exp_0 = Path:getExt(file) -- 1651
								if "tl" == _exp_0 then -- 1651
									if ("vs" == ext) then -- 1651
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1652
									end -- 1651
								elseif "lua" == _exp_0 then -- 1653
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1653
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1654
									end -- 1653
								end -- 1651
							end -- 1650
						end -- 1649
						return { -- 1655
							success = true -- 1655
						} -- 1655
					end -- 1639
				end -- 1620
			end -- 1619
		end -- 1619
	end -- 1619
	return { -- 1618
		success = false -- 1618
	} -- 1618
end) -- 1618
local withProjectSearchPaths -- 1657
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1657
	local fallbackPaths = { } -- 1658
	local addFallback -- 1659
	addFallback = function(dir) -- 1659
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1659
			fallbackPaths[#fallbackPaths + 1] = dir -- 1659
		end -- 1659
	end -- 1659
	if projectRoot and projectRoot ~= "" then -- 1660
		addFallback(Path(projectRoot, "Script")) -- 1661
		addFallback(projectRoot) -- 1662
	end -- 1660
	if projFile then -- 1663
		local projDir = getProjectDirFromFile(projFile) -- 1664
		if projDir then -- 1664
			addFallback(Path(projDir, "Script")) -- 1665
			addFallback(projDir) -- 1666
		else -- 1668
			addFallback(Path:getPath(projFile)) -- 1668
		end -- 1664
	end -- 1663
	if not (#fallbackPaths > 0) then -- 1669
		return fn() -- 1669
	end -- 1669
	local searchPaths = Content.searchPaths -- 1670
	for _index_0 = 1, #fallbackPaths do -- 1671
		local dir = fallbackPaths[_index_0] -- 1671
		Content:addSearchPath(dir) -- 1671
	end -- 1671
	local _ <close> = setmetatable({ }, { -- 1672
		__close = function() -- 1672
			Content.searchPaths = searchPaths -- 1672
		end -- 1672
	}) -- 1672
	return fn() -- 1673
end -- 1657
HttpServer:post("/exist", function(req) -- 1674
	do -- 1675
		local _type_0 = type(req) -- 1675
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1675
		if _tab_0 then -- 1675
			local file -- 1675
			do -- 1675
				local _obj_0 = req.body -- 1675
				local _type_1 = type(_obj_0) -- 1675
				if "table" == _type_1 or "userdata" == _type_1 then -- 1675
					file = _obj_0.file -- 1675
				end -- 1675
			end -- 1675
			if file ~= nil then -- 1675
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1676
					return { -- 1677
						success = Content:exist(file) -- 1677
					} -- 1677
				end) -- 1676
			end -- 1675
		end -- 1675
	end -- 1675
	return { -- 1674
		success = false -- 1674
	} -- 1674
end) -- 1674
HttpServer:postSchedule("/read", function(req) -- 1678
	do -- 1679
		local _type_0 = type(req) -- 1679
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1679
		if _tab_0 then -- 1679
			local path -- 1679
			do -- 1679
				local _obj_0 = req.body -- 1679
				local _type_1 = type(_obj_0) -- 1679
				if "table" == _type_1 or "userdata" == _type_1 then -- 1679
					path = _obj_0.path -- 1679
				end -- 1679
			end -- 1679
			if path ~= nil then -- 1679
				local readFile -- 1680
				readFile = function() -- 1680
					if Content:exist(path) then -- 1681
						local content = Content:loadAsync(path) -- 1682
						if content then -- 1682
							return { -- 1683
								content = content, -- 1683
								success = true, -- 1683
								fullPath = Content:getFullPath(path) -- 1683
							} -- 1683
						end -- 1682
					end -- 1681
					return nil -- 1680
				end -- 1680
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1684
				if result then -- 1684
					return result -- 1684
				end -- 1684
			end -- 1679
		end -- 1679
	end -- 1679
	return { -- 1678
		success = false -- 1678
	} -- 1678
end) -- 1678
local agentDocLanguage -- 1686
agentDocLanguage = function(language) -- 1686
	if language == "zh-Hans" then -- 1687
		return "zh" -- 1687
	else -- 1687
		return "en" -- 1687
	end -- 1687
end -- 1686
HttpServer:postSchedule("/doc/search", function(req) -- 1689
	local body = req.body or { } -- 1690
	local language = body.docLanguage -- 1691
	if not (("en" == language or "zh-Hans" == language)) then -- 1692
		return { -- 1692
			success = false, -- 1692
			message = "unsupported doc language" -- 1692
		} -- 1692
	end -- 1692
	local source = body.docSource -- 1693
	if not (("api" == source or "tutorial" == source)) then -- 1694
		return { -- 1694
			success = false, -- 1694
			message = "unsupported doc source" -- 1694
		} -- 1694
	end -- 1694
	local codeLanguage = body.programmingLanguage -- 1695
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1696
		return { -- 1696
			success = false, -- 1696
			message = "unsupported programming language" -- 1696
		} -- 1696
	end -- 1696
	if not body.pattern then -- 1697
		return { -- 1697
			success = false, -- 1697
			message = "missing pattern" -- 1697
		} -- 1697
	end -- 1697
	local result = nil -- 1698
	AgentTools.searchDoraAPIHttp({ -- 1700
		pattern = body.pattern, -- 1700
		docLanguage = agentDocLanguage(language), -- 1701
		docSource = source, -- 1702
		programmingLanguage = codeLanguage, -- 1703
		limit = body.limit, -- 1704
		useRegex = body.useRegex, -- 1705
		caseSensitive = body.caseSensitive, -- 1706
		includeContent = body.includeContent, -- 1707
		contentWindow = body.contentWindow -- 1708
	}, function(res) -- 1709
		result = res -- 1710
	end) -- 1699
	wait(function() -- 1711
		return result ~= nil -- 1711
	end) -- 1711
	if result and result.success then -- 1712
		result.docLanguage = language -- 1713
	end -- 1712
	if result then -- 1714
		return result -- 1715
	else -- 1717
		return { -- 1717
			success = false, -- 1717
			message = "doc search failed" -- 1717
		} -- 1717
	end -- 1714
	return { -- 1689
		success = false, -- 1689
		message = "invalid call" -- 1689
	} -- 1689
end) -- 1689
HttpServer:postSchedule("/doc/read", function(req) -- 1719
	local body = req.body or { } -- 1720
	local language = body.docLanguage -- 1721
	if not (("en" == language or "zh-Hans" == language)) then -- 1722
		return { -- 1722
			success = false, -- 1722
			message = "unsupported doc language" -- 1722
		} -- 1722
	end -- 1722
	if not body.file then -- 1723
		return { -- 1723
			success = false, -- 1723
			message = "missing file" -- 1723
		} -- 1723
	end -- 1723
	local result = AgentTools.readDoraDoc({ -- 1725
		docLanguage = agentDocLanguage(language), -- 1725
		file = body.file, -- 1726
		startLine = body.startLine, -- 1727
		endLine = body.endLine -- 1728
	}) -- 1724
	if result and result.success then -- 1729
		result.docLanguage = language -- 1730
	end -- 1729
	return result -- 1731
end) -- 1719
HttpServer:get("/read-sync", function(req) -- 1733
	do -- 1734
		local _type_0 = type(req) -- 1734
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1734
		if _tab_0 then -- 1734
			local params = req.params -- 1734
			if params ~= nil then -- 1734
				local path = params.path -- 1735
				local exts -- 1736
				if params.exts then -- 1736
					local _accum_0 = { } -- 1737
					local _len_0 = 1 -- 1737
					for ext in params.exts:gmatch("[^|]*") do -- 1737
						_accum_0[_len_0] = ext -- 1737
						_len_0 = _len_0 + 1 -- 1737
					end -- 1737
					exts = _accum_0 -- 1737
				else -- 1738
					exts = { -- 1738
						"" -- 1738
					} -- 1738
				end -- 1736
				local readFileAt -- 1739
				readFileAt = function(targetPath) -- 1739
					if Content:exist(targetPath) then -- 1740
						local content = Content:load(targetPath) -- 1741
						if content then -- 1741
							return { -- 1742
								content = content, -- 1742
								success = true, -- 1742
								fullPath = Content:getFullPath(targetPath) -- 1742
							} -- 1742
						end -- 1741
					end -- 1740
					return nil -- 1739
				end -- 1739
				local readFile -- 1743
				readFile = function(fallbackPaths) -- 1743
					for _index_0 = 1, #exts do -- 1744
						local ext = exts[_index_0] -- 1744
						local targetPath = path .. ext -- 1745
						if not Content:isAbsolutePath(targetPath) then -- 1746
							for _index_1 = 1, #fallbackPaths do -- 1747
								local fallback = fallbackPaths[_index_1] -- 1747
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1748
								if fallbackResult then -- 1748
									return fallbackResult -- 1749
								end -- 1748
							end -- 1747
						end -- 1746
						local fileResult = readFileAt(targetPath) -- 1750
						if fileResult then -- 1750
							return fileResult -- 1751
						end -- 1750
					end -- 1744
					return nil -- 1743
				end -- 1743
				local fallbackPaths = { } -- 1752
				local fallbackCandidates = { } -- 1753
				do -- 1754
					local projectRoot = req.params.projectRoot -- 1754
					if projectRoot then -- 1754
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1755
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1756
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1757
						end -- 1755
					end -- 1754
				end -- 1754
				do -- 1758
					local projFile = req.params.projFile -- 1758
					if projFile then -- 1758
						local projDir = getProjectDirFromFile(projFile) -- 1759
						if projDir then -- 1759
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1760
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1761
						else -- 1763
							projDir = Path:getPath(projFile) -- 1763
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1764
						end -- 1759
					end -- 1758
				end -- 1758
				for _index_0 = 1, #fallbackCandidates do -- 1765
					local dir = fallbackCandidates[_index_0] -- 1765
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1766
						local exists = false -- 1767
						for _index_1 = 1, #fallbackPaths do -- 1768
							local fallback = fallbackPaths[_index_1] -- 1768
							if fallback == dir then -- 1769
								exists = true -- 1770
								break -- 1771
							end -- 1769
						end -- 1768
						if not exists then -- 1772
							fallbackPaths[#fallbackPaths + 1] = dir -- 1772
						end -- 1772
					end -- 1766
				end -- 1765
				local readResult = readFile(fallbackPaths) -- 1773
				if readResult then -- 1773
					return readResult -- 1774
				end -- 1773
			end -- 1734
		end -- 1734
	end -- 1734
	return { -- 1733
		success = false -- 1733
	} -- 1733
end) -- 1733
local compileFileAsync -- 1776
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1776
	if projectRoot == nil then -- 1776
		projectRoot = nil -- 1776
	end -- 1776
	local file = inputFile -- 1777
	local searchPath -- 1778
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1778
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1779
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1783
	elseif not Content:isAbsolutePath(inputFile) then -- 1784
		searchPath = "" -- 1785
	else -- 1786
		local dir = getProjectDirFromFile(inputFile) -- 1786
		if dir then -- 1786
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1787
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1791
		else -- 1793
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1793
			searchPath = "" -- 1796
		end -- 1786
	end -- 1778
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1797
	local yueext = yue.options.extension -- 1798
	local resultCodes = nil -- 1799
	local resultError = nil -- 1800
	do -- 1801
		local _exp_0 = Path:getExt(inputFile) -- 1801
		if yueext == _exp_0 then -- 1801
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1802
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1803
				if not codes then -- 1804
					resultError = err -- 1805
					return -- 1806
				end -- 1804
				local extraGlobal -- 1807
				if isTIC80 then -- 1807
					extraGlobal = tic80APIs -- 1807
				else -- 1807
					extraGlobal = nil -- 1807
				end -- 1807
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1808
				if not success then -- 1809
					resultError = message -- 1810
					return -- 1811
				end -- 1809
				if codes == "" then -- 1812
					resultCodes = "" -- 1813
					return nil -- 1814
				end -- 1812
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1815
				return resultCodes -- 1816
			end, function(success) -- 1803
				if not success then -- 1817
					Content:remove(outputFile) -- 1818
					if resultCodes == nil then -- 1819
						resultCodes = false -- 1820
					end -- 1819
				end -- 1817
			end) -- 1803
		elseif "tl" == _exp_0 then -- 1821
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1822
			if isTIC80 then -- 1823
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1824
			end -- 1823
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1825
			if codes then -- 1825
				if isTIC80 then -- 1826
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1827
				end -- 1826
				resultCodes = codes -- 1828
				Content:saveAsync(outputFile, codes) -- 1829
			else -- 1831
				Content:remove(outputFile) -- 1831
				resultCodes = false -- 1832
				resultError = err -- 1833
			end -- 1825
		elseif "xml" == _exp_0 then -- 1834
			local codes, err = xml.tolua(sourceCodes) -- 1835
			if codes then -- 1835
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1836
				Content:saveAsync(outputFile, resultCodes) -- 1837
			else -- 1839
				Content:remove(outputFile) -- 1839
				resultCodes = false -- 1840
				resultError = err -- 1841
			end -- 1835
		end -- 1801
	end -- 1801
	wait(function() -- 1842
		return resultCodes ~= nil -- 1842
	end) -- 1842
	if resultCodes then -- 1843
		return resultCodes -- 1844
	else -- 1846
		return nil, resultError -- 1846
	end -- 1843
	return nil -- 1776
end -- 1776
HttpServer:postSchedule("/write", function(req) -- 1848
	do -- 1849
		local _type_0 = type(req) -- 1849
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1849
		if _tab_0 then -- 1849
			local path -- 1849
			do -- 1849
				local _obj_0 = req.body -- 1849
				local _type_1 = type(_obj_0) -- 1849
				if "table" == _type_1 or "userdata" == _type_1 then -- 1849
					path = _obj_0.path -- 1849
				end -- 1849
			end -- 1849
			local content -- 1849
			do -- 1849
				local _obj_0 = req.body -- 1849
				local _type_1 = type(_obj_0) -- 1849
				if "table" == _type_1 or "userdata" == _type_1 then -- 1849
					content = _obj_0.content -- 1849
				end -- 1849
			end -- 1849
			if path ~= nil and content ~= nil then -- 1849
				if Content:saveAsync(path, content) then -- 1850
					do -- 1851
						local _exp_0 = Path:getExt(path) -- 1851
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1851
							if '' == Path:getExt(Path:getName(path)) then -- 1852
								local resultCodes = compileFileAsync(path, content) -- 1853
								return { -- 1854
									success = true, -- 1854
									resultCodes = resultCodes -- 1854
								} -- 1854
							end -- 1852
						end -- 1851
					end -- 1851
					return { -- 1855
						success = true -- 1855
					} -- 1855
				end -- 1850
			end -- 1849
		end -- 1849
	end -- 1849
	return { -- 1848
		success = false -- 1848
	} -- 1848
end) -- 1848
local getWaProjectDirFromFile = nil -- 1857
HttpServer:postSchedule("/build", function(req) -- 1859
	do -- 1860
		local _type_0 = type(req) -- 1860
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1860
		if _tab_0 then -- 1860
			local path -- 1860
			do -- 1860
				local _obj_0 = req.body -- 1860
				local _type_1 = type(_obj_0) -- 1860
				if "table" == _type_1 or "userdata" == _type_1 then -- 1860
					path = _obj_0.path -- 1860
				end -- 1860
			end -- 1860
			if path ~= nil then -- 1860
				local projectRoot = req.body.projectRoot -- 1861
				if Content:isdir(path) then -- 1862
					local projDir = getWaProjectDirFromFile(path) -- 1863
					if projDir then -- 1863
						local message = Wasm:buildWaAsync(projDir) -- 1864
						if message == "" then -- 1865
							return { -- 1866
								success = true -- 1866
							} -- 1866
						else -- 1868
							return { -- 1868
								success = false, -- 1868
								message = message -- 1868
							} -- 1868
						end -- 1865
					end -- 1863
				end -- 1862
				local _exp_0 = Path:getExt(path) -- 1869
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1870
					if '' == Path:getExt(Path:getName(path)) then -- 1871
						local content = Content:loadAsync(path) -- 1872
						if content then -- 1872
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 1873
							if resultCodes then -- 1873
								return { -- 1874
									success = true, -- 1874
									resultCodes = resultCodes -- 1874
								} -- 1874
							end -- 1873
						end -- 1872
					end -- 1871
				elseif "wa" == _exp_0 then -- 1875
					local projDir = getWaProjectDirFromFile(path) -- 1876
					if projDir then -- 1876
						local message = Wasm:buildWaAsync(projDir) -- 1877
						if message == "" then -- 1878
							return { -- 1879
								success = true -- 1879
							} -- 1879
						else -- 1881
							return { -- 1881
								success = false, -- 1881
								message = message -- 1881
							} -- 1881
						end -- 1878
					else -- 1883
						return { -- 1883
							success = false, -- 1883
							message = 'Wa file needs a project' -- 1883
						} -- 1883
					end -- 1876
				end -- 1869
			end -- 1860
		end -- 1860
	end -- 1860
	return { -- 1859
		success = false -- 1859
	} -- 1859
end) -- 1859
local extentionLevels = { -- 1886
	vs = 2, -- 1886
	bl = 2, -- 1887
	ts = 1, -- 1888
	tsx = 1, -- 1889
	tl = 1, -- 1890
	yue = 1, -- 1891
	xml = 1, -- 1892
	lua = 0 -- 1893
} -- 1885
HttpServer:post("/assets", function() -- 1895
	local Entry = require("Script.Dev.Entry") -- 1898
	local engineDev = Entry.getEngineDev() -- 1899
	local visitAssets -- 1900
	visitAssets = function(path, tag) -- 1900
		local isWorkspace = tag == "Workspace" -- 1901
		local builtin -- 1902
		if tag == "Builtin" then -- 1902
			builtin = true -- 1902
		else -- 1902
			builtin = nil -- 1902
		end -- 1902
		local children = nil -- 1903
		local dirs = Content:getDirs(path) -- 1904
		for _index_0 = 1, #dirs do -- 1905
			local dir = dirs[_index_0] -- 1905
			if isWorkspace then -- 1906
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1907
					goto _continue_0 -- 1908
				end -- 1907
			elseif dir == ".git" then -- 1909
				goto _continue_0 -- 1910
			end -- 1906
			if not children then -- 1911
				children = { } -- 1911
			end -- 1911
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1912
			::_continue_0:: -- 1906
		end -- 1905
		local files = Content:getFiles(path) -- 1913
		local names = { } -- 1914
		for _index_0 = 1, #files do -- 1915
			local file = files[_index_0] -- 1915
			if (".DS_Store" == file) then -- 1916
				goto _continue_1 -- 1917
			end -- 1916
			local name = Path:getName(file) -- 1918
			local ext = names[name] -- 1919
			if ext then -- 1919
				local lv1 -- 1920
				do -- 1920
					local _exp_0 = extentionLevels[ext] -- 1920
					if _exp_0 ~= nil then -- 1920
						lv1 = _exp_0 -- 1920
					else -- 1920
						lv1 = -1 -- 1920
					end -- 1920
				end -- 1920
				ext = Path:getExt(file) -- 1921
				local lv2 -- 1922
				do -- 1922
					local _exp_0 = extentionLevels[ext] -- 1922
					if _exp_0 ~= nil then -- 1922
						lv2 = _exp_0 -- 1922
					else -- 1922
						lv2 = -1 -- 1922
					end -- 1922
				end -- 1922
				if lv2 > lv1 then -- 1923
					names[name] = ext -- 1924
				elseif lv2 == lv1 then -- 1925
					names[name .. '.' .. ext] = "" -- 1926
				end -- 1923
			else -- 1928
				ext = Path:getExt(file) -- 1928
				if not extentionLevels[ext] then -- 1929
					names[file] = "" -- 1930
				else -- 1932
					names[name] = ext -- 1932
				end -- 1929
			end -- 1919
			::_continue_1:: -- 1916
		end -- 1915
		do -- 1933
			local _accum_0 = { } -- 1933
			local _len_0 = 1 -- 1933
			for name, ext in pairs(names) do -- 1933
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1933
				_len_0 = _len_0 + 1 -- 1933
			end -- 1933
			files = _accum_0 -- 1933
		end -- 1933
		for _index_0 = 1, #files do -- 1934
			local file = files[_index_0] -- 1934
			if not children then -- 1935
				children = { } -- 1935
			end -- 1935
			children[#children + 1] = { -- 1937
				key = Path(path, file), -- 1937
				dir = false, -- 1938
				title = file, -- 1939
				builtin = builtin -- 1940
			} -- 1936
		end -- 1934
		if children then -- 1942
			table.sort(children, function(a, b) -- 1943
				if a.dir == b.dir then -- 1944
					return a.title < b.title -- 1945
				else -- 1947
					return a.dir -- 1947
				end -- 1944
			end) -- 1943
		end -- 1942
		if isWorkspace and children then -- 1948
			return children -- 1949
		else -- 1951
			return { -- 1952
				key = path, -- 1952
				dir = true, -- 1953
				title = Path:getFilename(path), -- 1954
				builtin = builtin, -- 1955
				children = children -- 1956
			} -- 1951
		end -- 1948
	end -- 1900
	local zh = (App.locale:match("^zh") ~= nil) -- 1958
	return { -- 1960
		key = Content.writablePath, -- 1960
		dir = true, -- 1961
		root = true, -- 1962
		title = "Assets", -- 1963
		children = (function() -- 1965
			local _tab_0 = { -- 1965
				{ -- 1966
					key = Path(Content.assetPath), -- 1966
					dir = true, -- 1967
					builtin = true, -- 1968
					title = zh and "内置资源" or "Built-in", -- 1969
					children = { -- 1971
						(function() -- 1971
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1971
							_with_0.title = zh and "说明文档" or "Readme" -- 1972
							return _with_0 -- 1971
						end)(), -- 1971
						(function() -- 1973
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1973
							_with_0.title = zh and "接口文档" or "API Doc" -- 1974
							return _with_0 -- 1973
						end)(), -- 1973
						(function() -- 1975
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1975
							_with_0.title = zh and "开发工具" or "Tools" -- 1976
							return _with_0 -- 1975
						end)(), -- 1975
						(function() -- 1977
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1977
							_with_0.title = zh and "字体" or "Font" -- 1978
							return _with_0 -- 1977
						end)(), -- 1977
						(function() -- 1979
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1979
							_with_0.title = zh and "程序库" or "Lib" -- 1980
							if engineDev then -- 1981
								local _list_0 = _with_0.children -- 1982
								for _index_0 = 1, #_list_0 do -- 1982
									local child = _list_0[_index_0] -- 1982
									if not (child.title == "Dora") then -- 1983
										goto _continue_0 -- 1983
									end -- 1983
									local title = zh and "zh-Hans" or "en" -- 1984
									do -- 1985
										local _accum_0 = { } -- 1985
										local _len_0 = 1 -- 1985
										local _list_1 = child.children -- 1985
										for _index_1 = 1, #_list_1 do -- 1985
											local c = _list_1[_index_1] -- 1985
											if c.title ~= title then -- 1985
												_accum_0[_len_0] = c -- 1985
												_len_0 = _len_0 + 1 -- 1985
											end -- 1985
										end -- 1985
										child.children = _accum_0 -- 1985
									end -- 1985
									break -- 1986
									::_continue_0:: -- 1983
								end -- 1982
							else -- 1988
								local _accum_0 = { } -- 1988
								local _len_0 = 1 -- 1988
								local _list_0 = _with_0.children -- 1988
								for _index_0 = 1, #_list_0 do -- 1988
									local child = _list_0[_index_0] -- 1988
									if child.title ~= "Dora" then -- 1988
										_accum_0[_len_0] = child -- 1988
										_len_0 = _len_0 + 1 -- 1988
									end -- 1988
								end -- 1988
								_with_0.children = _accum_0 -- 1988
							end -- 1981
							return _with_0 -- 1979
						end)(), -- 1979
						(function() -- 1989
							if engineDev then -- 1989
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1990
								local _obj_0 = _with_0.children -- 1991
								_obj_0[#_obj_0 + 1] = { -- 1992
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1992
									dir = false, -- 1993
									builtin = true, -- 1994
									title = "init.yue" -- 1995
								} -- 1991
								return _with_0 -- 1990
							end -- 1989
						end)() -- 1989
					} -- 1970
				} -- 1965
			} -- 1999
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1999
			local _idx_0 = #_tab_0 + 1 -- 1999
			for _index_0 = 1, #_obj_0 do -- 1999
				local _value_0 = _obj_0[_index_0] -- 1999
				_tab_0[_idx_0] = _value_0 -- 1999
				_idx_0 = _idx_0 + 1 -- 1999
			end -- 1999
			return _tab_0 -- 1965
		end)() -- 1964
	} -- 1959
end) -- 1895
HttpServer:post("/entry/list", function() -- 2003
	local Entry = require("Script.Dev.Entry") -- 2004
	local res = Entry.getLaunchEntries() -- 2005
	res.success = true -- 2006
	return res -- 2007
end) -- 2003
HttpServer:post("/run/status", function() -- 2009
	local Entry = require("Script.Dev.Entry") -- 2010
	return Entry.getCurrentEntryStatus() -- 2011
end) -- 2009
HttpServer:postSchedule("/run", function(req) -- 2013
	do -- 2014
		local _type_0 = type(req) -- 2014
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2014
		if _tab_0 then -- 2014
			local file -- 2014
			do -- 2014
				local _obj_0 = req.body -- 2014
				local _type_1 = type(_obj_0) -- 2014
				if "table" == _type_1 or "userdata" == _type_1 then -- 2014
					file = _obj_0.file -- 2014
				end -- 2014
			end -- 2014
			local asProj -- 2014
			do -- 2014
				local _obj_0 = req.body -- 2014
				local _type_1 = type(_obj_0) -- 2014
				if "table" == _type_1 or "userdata" == _type_1 then -- 2014
					asProj = _obj_0.asProj -- 2014
				end -- 2014
			end -- 2014
			if file ~= nil and asProj ~= nil then -- 2014
				if not Content:isAbsolutePath(file) then -- 2015
					local devFile = Path(Content.writablePath, file) -- 2016
					if Content:exist(devFile) then -- 2017
						file = devFile -- 2017
					end -- 2017
				end -- 2015
				local Entry = require("Script.Dev.Entry") -- 2018
				local workDir -- 2019
				if asProj then -- 2020
					local projectRoot = req.body.projectRoot -- 2021
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2022
						workDir = projectRoot -- 2023
					else -- 2025
						workDir = getProjectDirFromFile(file) -- 2025
					end -- 2022
					if workDir then -- 2026
						Entry.allClear() -- 2027
						local target = Path(workDir, "init") -- 2028
						local success, err = Entry.enterEntryAsync({ -- 2029
							entryName = "Project", -- 2029
							fileName = target, -- 2029
							workDir = workDir, -- 2029
							projectRoot = workDir, -- 2029
							runKind = "project" -- 2029
						}) -- 2029
						target = Path:getName(Path:getPath(target)) -- 2030
						return { -- 2031
							success = success, -- 2031
							target = target, -- 2031
							err = err -- 2031
						} -- 2031
					end -- 2026
				else -- 2033
					workDir = getProjectDirFromFile(file) -- 2033
					if not workDir and Path:getExt(file) == "wasm" then -- 2034
						local parent = Path:getPath(file) -- 2035
						if Content:exist(Path(parent, "wa.mod")) then -- 2036
							workDir = parent -- 2037
						end -- 2036
					end -- 2034
				end -- 2020
				Entry.allClear() -- 2038
				file = Path:replaceExt(file, "") -- 2039
				local entry = { -- 2041
					entryName = Path:getName(file), -- 2041
					fileName = file, -- 2042
					runKind = "file" -- 2043
				} -- 2040
				if workDir then -- 2044
					entry.workDir = workDir -- 2045
					entry.projectRoot = workDir -- 2046
				end -- 2044
				local success, err = Entry.enterEntryAsync(entry) -- 2047
				return { -- 2048
					success = success, -- 2048
					err = err -- 2048
				} -- 2048
			end -- 2014
		end -- 2014
	end -- 2014
	return { -- 2013
		success = false -- 2013
	} -- 2013
end) -- 2013
HttpServer:postSchedule("/stop", function() -- 2050
	local Entry = require("Script.Dev.Entry") -- 2051
	return { -- 2052
		success = Entry.stop() -- 2052
	} -- 2052
end) -- 2050
local minifyAsync -- 2054
minifyAsync = function(sourcePath, minifyPath) -- 2054
	if not Content:exist(sourcePath) then -- 2055
		return -- 2055
	end -- 2055
	local Entry = require("Script.Dev.Entry") -- 2056
	local errors = { } -- 2057
	local files = Entry.getAllFiles(sourcePath, { -- 2058
		"lua" -- 2058
	}, true) -- 2058
	do -- 2059
		local _accum_0 = { } -- 2059
		local _len_0 = 1 -- 2059
		for _index_0 = 1, #files do -- 2059
			local file = files[_index_0] -- 2059
			if file:sub(1, 1) ~= '.' then -- 2059
				_accum_0[_len_0] = file -- 2059
				_len_0 = _len_0 + 1 -- 2059
			end -- 2059
		end -- 2059
		files = _accum_0 -- 2059
	end -- 2059
	local paths -- 2060
	do -- 2060
		local _tbl_0 = { } -- 2060
		for _index_0 = 1, #files do -- 2060
			local file = files[_index_0] -- 2060
			_tbl_0[Path:getPath(file)] = true -- 2060
		end -- 2060
		paths = _tbl_0 -- 2060
	end -- 2060
	for path in pairs(paths) do -- 2061
		Content:mkdir(Path(minifyPath, path)) -- 2061
	end -- 2061
	local _ <close> = setmetatable({ }, { -- 2062
		__close = function() -- 2062
			package.loaded["luaminify.FormatMini"] = nil -- 2063
			package.loaded["luaminify.ParseLua"] = nil -- 2064
			package.loaded["luaminify.Scope"] = nil -- 2065
			package.loaded["luaminify.Util"] = nil -- 2066
		end -- 2062
	}) -- 2062
	local FormatMini -- 2067
	do -- 2067
		local _obj_0 = require("luaminify") -- 2067
		FormatMini = _obj_0.FormatMini -- 2067
	end -- 2067
	local fileCount = #files -- 2068
	local count = 0 -- 2069
	for _index_0 = 1, #files do -- 2070
		local file = files[_index_0] -- 2070
		thread(function() -- 2071
			local _ <close> = setmetatable({ }, { -- 2072
				__close = function() -- 2072
					count = count + 1 -- 2072
				end -- 2072
			}) -- 2072
			local input = Path(sourcePath, file) -- 2073
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2074
			if Content:exist(input) then -- 2075
				local sourceCodes = Content:loadAsync(input) -- 2076
				local res, err = FormatMini(sourceCodes) -- 2077
				if res then -- 2078
					Content:saveAsync(output, res) -- 2079
					return print("Minify " .. tostring(file)) -- 2080
				else -- 2082
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2082
				end -- 2078
			else -- 2084
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2084
			end -- 2075
		end) -- 2071
		sleep() -- 2085
	end -- 2070
	wait(function() -- 2086
		return count == fileCount -- 2086
	end) -- 2086
	if #errors > 0 then -- 2087
		print(table.concat(errors, '\n')) -- 2088
	end -- 2087
	print("Obfuscation done.") -- 2089
	return files -- 2090
end -- 2054
local zipping = false -- 2092
HttpServer:postSchedule("/zip", function(req) -- 2094
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
			local zipFile -- 2095
			do -- 2095
				local _obj_0 = req.body -- 2095
				local _type_1 = type(_obj_0) -- 2095
				if "table" == _type_1 or "userdata" == _type_1 then -- 2095
					zipFile = _obj_0.zipFile -- 2095
				end -- 2095
			end -- 2095
			local obfuscated -- 2095
			do -- 2095
				local _obj_0 = req.body -- 2095
				local _type_1 = type(_obj_0) -- 2095
				if "table" == _type_1 or "userdata" == _type_1 then -- 2095
					obfuscated = _obj_0.obfuscated -- 2095
				end -- 2095
			end -- 2095
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2095
				if zipping then -- 2096
					goto failed -- 2096
				end -- 2096
				zipping = true -- 2097
				local _ <close> = setmetatable({ }, { -- 2098
					__close = function() -- 2098
						zipping = false -- 2098
					end -- 2098
				}) -- 2098
				if not Content:exist(path) then -- 2099
					goto failed -- 2099
				end -- 2099
				Content:mkdir(Path:getPath(zipFile)) -- 2100
				if obfuscated then -- 2101
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2102
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2103
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2104
					Content:remove(scriptPath) -- 2105
					Content:remove(obfuscatedPath) -- 2106
					Content:remove(tempPath) -- 2107
					Content:mkdir(scriptPath) -- 2108
					Content:mkdir(obfuscatedPath) -- 2109
					Content:mkdir(tempPath) -- 2110
					if not Content:copyAsync(path, tempPath) then -- 2111
						goto failed -- 2111
					end -- 2111
					local Entry = require("Script.Dev.Entry") -- 2112
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2113
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2114
						"tl", -- 2114
						"yue", -- 2114
						"lua", -- 2114
						"ts", -- 2114
						"tsx", -- 2114
						"vs", -- 2114
						"bl", -- 2114
						"xml", -- 2114
						"wa", -- 2114
						"mod" -- 2114
					}, true) -- 2114
					for _index_0 = 1, #scriptFiles do -- 2115
						local file = scriptFiles[_index_0] -- 2115
						Content:remove(Path(tempPath, file)) -- 2116
					end -- 2115
					for _index_0 = 1, #luaFiles do -- 2117
						local file = luaFiles[_index_0] -- 2117
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2118
					end -- 2117
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2119
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2120
					end) then -- 2119
						goto failed -- 2119
					end -- 2119
					return { -- 2121
						success = true -- 2121
					} -- 2121
				else -- 2123
					return { -- 2123
						success = Content:zipAsync(path, zipFile, function(file) -- 2123
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2124
						end) -- 2123
					} -- 2123
				end -- 2101
			end -- 2095
		end -- 2095
	end -- 2095
	::failed:: -- 2125
	return { -- 2094
		success = false -- 2094
	} -- 2094
end) -- 2094
HttpServer:postSchedule("/unzip", function(req) -- 2127
	do -- 2128
		local _type_0 = type(req) -- 2128
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2128
		if _tab_0 then -- 2128
			local zipFile -- 2128
			do -- 2128
				local _obj_0 = req.body -- 2128
				local _type_1 = type(_obj_0) -- 2128
				if "table" == _type_1 or "userdata" == _type_1 then -- 2128
					zipFile = _obj_0.zipFile -- 2128
				end -- 2128
			end -- 2128
			local path -- 2128
			do -- 2128
				local _obj_0 = req.body -- 2128
				local _type_1 = type(_obj_0) -- 2128
				if "table" == _type_1 or "userdata" == _type_1 then -- 2128
					path = _obj_0.path -- 2128
				end -- 2128
			end -- 2128
			if zipFile ~= nil and path ~= nil then -- 2128
				return { -- 2129
					success = Content:unzipAsync(zipFile, path, function(file) -- 2129
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2130
					end) -- 2129
				} -- 2129
			end -- 2128
		end -- 2128
	end -- 2128
	return { -- 2127
		success = false -- 2127
	} -- 2127
end) -- 2127
HttpServer:post("/editing-info", function(req) -- 2132
	local Entry = require("Script.Dev.Entry") -- 2133
	local config = Entry.getConfig() -- 2134
	local _type_0 = type(req) -- 2135
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2135
	local _match_0 = false -- 2135
	if _tab_0 then -- 2135
		local editingInfo -- 2135
		do -- 2135
			local _obj_0 = req.body -- 2135
			local _type_1 = type(_obj_0) -- 2135
			if "table" == _type_1 or "userdata" == _type_1 then -- 2135
				editingInfo = _obj_0.editingInfo -- 2135
			end -- 2135
		end -- 2135
		if editingInfo ~= nil then -- 2135
			_match_0 = true -- 2135
			config.editingInfo = editingInfo -- 2136
			return { -- 2137
				success = true -- 2137
			} -- 2137
		end -- 2135
	end -- 2135
	if not _match_0 then -- 2135
		if not (config.editingInfo ~= nil) then -- 2139
			local folder -- 2140
			if App.locale:match('^zh') then -- 2140
				folder = 'zh-Hans' -- 2140
			else -- 2140
				folder = 'en' -- 2140
			end -- 2140
			config.editingInfo = json.encode({ -- 2142
				index = 0, -- 2142
				files = { -- 2144
					{ -- 2145
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2145
						title = "welcome.md" -- 2146
					} -- 2144
				} -- 2143
			}) -- 2141
		end -- 2139
		return { -- 2150
			success = true, -- 2150
			editingInfo = config.editingInfo -- 2150
		} -- 2150
	end -- 2135
end) -- 2132
HttpServer:post("/command", function(req) -- 2152
	do -- 2153
		local _type_0 = type(req) -- 2153
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2153
		if _tab_0 then -- 2153
			local code -- 2153
			do -- 2153
				local _obj_0 = req.body -- 2153
				local _type_1 = type(_obj_0) -- 2153
				if "table" == _type_1 or "userdata" == _type_1 then -- 2153
					code = _obj_0.code -- 2153
				end -- 2153
			end -- 2153
			local log -- 2153
			do -- 2153
				local _obj_0 = req.body -- 2153
				local _type_1 = type(_obj_0) -- 2153
				if "table" == _type_1 or "userdata" == _type_1 then -- 2153
					log = _obj_0.log -- 2153
				end -- 2153
			end -- 2153
			if code ~= nil and log ~= nil then -- 2153
				emit("AppCommand", code, log) -- 2154
				return { -- 2155
					success = true -- 2155
				} -- 2155
			end -- 2153
		end -- 2153
	end -- 2153
	return { -- 2152
		success = false -- 2152
	} -- 2152
end) -- 2152
HttpServer:post("/log/save", function() -- 2157
	local folder = ".download" -- 2158
	local fullLogFile = "dora_full_logs.txt" -- 2159
	local fullFolder = Path(Content.writablePath, folder) -- 2160
	Content:mkdir(fullFolder) -- 2161
	local logPath = Path(fullFolder, fullLogFile) -- 2162
	if App:saveLog(logPath) then -- 2163
		return { -- 2164
			success = true, -- 2164
			path = Path(folder, fullLogFile) -- 2164
		} -- 2164
	end -- 2163
	return { -- 2157
		success = false -- 2157
	} -- 2157
end) -- 2157
local tailLines -- 2166
tailLines = function(text, count) -- 2166
	local lines = { } -- 2167
	text = text:gsub("\r\n", "\n") -- 2168
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2169
		lines[#lines + 1] = line -- 2170
	end -- 2169
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2171
		table.remove(lines) -- 2172
	end -- 2171
	local start = math.max(1, #lines - count + 1) -- 2173
	local out = { } -- 2174
	for i = start, #lines do -- 2175
		out[#out + 1] = lines[i] -- 2176
	end -- 2175
	return table.concat(out, "\n") -- 2177
end -- 2166
HttpServer:post("/log", function(req) -- 2179
	local count = 100 -- 2180
	if req and req.body and req.body.count ~= nil then -- 2181
		count = req.body.count -- 2182
	end -- 2181
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2183
		return { -- 2184
			success = false, -- 2184
			message = "count must be a positive integer" -- 2184
		} -- 2184
	end -- 2183
	local folder = ".download" -- 2185
	local fullLogFile = "dora_full_logs.txt" -- 2186
	local fullFolder = Path(Content.writablePath, folder) -- 2187
	Content:mkdir(fullFolder) -- 2188
	local logPath = Path(fullFolder, fullLogFile) -- 2189
	if App:saveLog(logPath) then -- 2190
		local text = Content:load(logPath) -- 2191
		if text then -- 2192
			return { -- 2193
				success = true, -- 2193
				log = tailLines(text, count) -- 2193
			} -- 2193
		else -- 2195
			return { -- 2195
				success = false, -- 2195
				message = "failed to read log" -- 2195
			} -- 2195
		end -- 2192
	else -- 2197
		return { -- 2197
			success = false, -- 2197
			message = "failed to save log" -- 2197
		} -- 2197
	end -- 2190
	return { -- 2179
		success = false -- 2179
	} -- 2179
end) -- 2179
HttpServer:post("/yarn/check", function(req) -- 2199
	local yarncompile = require("yarncompile") -- 2200
	do -- 2201
		local _type_0 = type(req) -- 2201
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2201
		if _tab_0 then -- 2201
			local code -- 2201
			do -- 2201
				local _obj_0 = req.body -- 2201
				local _type_1 = type(_obj_0) -- 2201
				if "table" == _type_1 or "userdata" == _type_1 then -- 2201
					code = _obj_0.code -- 2201
				end -- 2201
			end -- 2201
			if code ~= nil then -- 2201
				local jsonObject = json.decode(code) -- 2202
				if jsonObject then -- 2202
					local errors = { } -- 2203
					local _list_0 = jsonObject.nodes -- 2204
					for _index_0 = 1, #_list_0 do -- 2204
						local node = _list_0[_index_0] -- 2204
						local title, body = node.title, node.body -- 2205
						local luaCode, err = yarncompile(body) -- 2206
						if not luaCode then -- 2206
							errors[#errors + 1] = title .. ":" .. err -- 2207
						end -- 2206
					end -- 2204
					return { -- 2208
						success = true, -- 2208
						syntaxError = table.concat(errors, "\n\n") -- 2208
					} -- 2208
				end -- 2202
			end -- 2201
		end -- 2201
	end -- 2201
	return { -- 2199
		success = false -- 2199
	} -- 2199
end) -- 2199
HttpServer:post("/yarn/check-file", function(req) -- 2210
	local yarncompile = require("yarncompile") -- 2211
	do -- 2212
		local _type_0 = type(req) -- 2212
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2212
		if _tab_0 then -- 2212
			local code -- 2212
			do -- 2212
				local _obj_0 = req.body -- 2212
				local _type_1 = type(_obj_0) -- 2212
				if "table" == _type_1 or "userdata" == _type_1 then -- 2212
					code = _obj_0.code -- 2212
				end -- 2212
			end -- 2212
			if code ~= nil then -- 2212
				local res, _, err = yarncompile(code, true) -- 2213
				if not res then -- 2213
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2214
					return { -- 2215
						success = false, -- 2215
						message = message, -- 2215
						line = line, -- 2215
						column = column, -- 2215
						node = node -- 2215
					} -- 2215
				end -- 2213
			end -- 2212
		end -- 2212
	end -- 2212
	return { -- 2210
		success = true -- 2210
	} -- 2210
end) -- 2210
getWaProjectDirFromFile = function(file) -- 2217
	local current -- 2218
	if Content:isdir(file) then -- 2218
		current = file -- 2218
	else -- 2218
		current = Path:getPath(file) -- 2218
	end -- 2218
	if current == "" then -- 2219
		return nil -- 2219
	end -- 2219
	repeat -- 2220
		local modPath = Path(current, "wa.mod") -- 2221
		if Content:exist(modPath) then -- 2222
			return current, modPath -- 2223
		end -- 2222
		local parent = Path:getPath(current) -- 2224
		if parent == "" or parent == current then -- 2225
			break -- 2225
		end -- 2225
		current = parent -- 2226
	until false -- 2220
	return nil -- 2228
end -- 2217
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2230
	do -- 2231
		local _type_0 = type(req) -- 2231
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2231
		if _tab_0 then -- 2231
			local path -- 2231
			do -- 2231
				local _obj_0 = req.body -- 2231
				local _type_1 = type(_obj_0) -- 2231
				if "table" == _type_1 or "userdata" == _type_1 then -- 2231
					path = _obj_0.path -- 2231
				end -- 2231
			end -- 2231
			if path ~= nil then -- 2231
				local projDir = getWaProjectDirFromFile(path) -- 2232
				if projDir then -- 2232
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2233
					if not Content:exist(sourceDoraPath) then -- 2234
						return { -- 2235
							success = false, -- 2235
							message = "missing dora template" -- 2235
						} -- 2235
					end -- 2234
					local targetVendorPath = Path(projDir, "vendor") -- 2236
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2237
					if not Content:exist(targetVendorPath) then -- 2238
						if not Content:mkdir(targetVendorPath) then -- 2239
							return { -- 2240
								success = false, -- 2240
								message = "failed to create vendor folder" -- 2240
							} -- 2240
						end -- 2239
					elseif not Content:isdir(targetVendorPath) then -- 2241
						return { -- 2242
							success = false, -- 2242
							message = "vendor path is not a folder" -- 2242
						} -- 2242
					end -- 2238
					if Content:exist(targetDoraPath) then -- 2243
						if not Content:remove(targetDoraPath) then -- 2244
							return { -- 2245
								success = false, -- 2245
								message = "failed to remove old dora" -- 2245
							} -- 2245
						end -- 2244
					end -- 2243
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2246
						return { -- 2247
							success = false, -- 2247
							message = "failed to copy dora" -- 2247
						} -- 2247
					end -- 2246
					return { -- 2248
						success = true -- 2248
					} -- 2248
				else -- 2250
					return { -- 2250
						success = false, -- 2250
						message = 'Wa file needs a project' -- 2250
					} -- 2250
				end -- 2232
			end -- 2231
		end -- 2231
	end -- 2231
	return { -- 2230
		success = false, -- 2230
		message = "invalid call" -- 2230
	} -- 2230
end) -- 2230
HttpServer:postSchedule("/wa/build", function(req) -- 2252
	do -- 2253
		local _type_0 = type(req) -- 2253
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2253
		if _tab_0 then -- 2253
			local path -- 2253
			do -- 2253
				local _obj_0 = req.body -- 2253
				local _type_1 = type(_obj_0) -- 2253
				if "table" == _type_1 or "userdata" == _type_1 then -- 2253
					path = _obj_0.path -- 2253
				end -- 2253
			end -- 2253
			if path ~= nil then -- 2253
				local projDir = getWaProjectDirFromFile(path) -- 2254
				if projDir then -- 2254
					local message = Wasm:buildWaAsync(projDir) -- 2255
					if message == "" then -- 2256
						return { -- 2257
							success = true -- 2257
						} -- 2257
					else -- 2259
						return { -- 2259
							success = false, -- 2259
							message = message -- 2259
						} -- 2259
					end -- 2256
				else -- 2261
					return { -- 2261
						success = false, -- 2261
						message = 'Wa file needs a project' -- 2261
					} -- 2261
				end -- 2254
			end -- 2253
		end -- 2253
	end -- 2253
	return { -- 2262
		success = false, -- 2262
		message = 'failed to build' -- 2262
	} -- 2262
end) -- 2252
HttpServer:postSchedule("/wa/format", function(req) -- 2264
	do -- 2265
		local _type_0 = type(req) -- 2265
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2265
		if _tab_0 then -- 2265
			local file -- 2265
			do -- 2265
				local _obj_0 = req.body -- 2265
				local _type_1 = type(_obj_0) -- 2265
				if "table" == _type_1 or "userdata" == _type_1 then -- 2265
					file = _obj_0.file -- 2265
				end -- 2265
			end -- 2265
			if file ~= nil then -- 2265
				local code = Wasm:formatWaAsync(file) -- 2266
				if code == "" then -- 2267
					return { -- 2268
						success = false -- 2268
					} -- 2268
				else -- 2270
					return { -- 2270
						success = true, -- 2270
						code = code -- 2270
					} -- 2270
				end -- 2267
			end -- 2265
		end -- 2265
	end -- 2265
	return { -- 2271
		success = false -- 2271
	} -- 2271
end) -- 2264
HttpServer:postSchedule("/wa/create", function(req) -- 2273
	do -- 2274
		local _type_0 = type(req) -- 2274
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2274
		if _tab_0 then -- 2274
			local path -- 2274
			do -- 2274
				local _obj_0 = req.body -- 2274
				local _type_1 = type(_obj_0) -- 2274
				if "table" == _type_1 or "userdata" == _type_1 then -- 2274
					path = _obj_0.path -- 2274
				end -- 2274
			end -- 2274
			if path ~= nil then -- 2274
				if not Content:exist(Path:getPath(path)) then -- 2275
					return { -- 2276
						success = false, -- 2276
						message = "target path not existed" -- 2276
					} -- 2276
				end -- 2275
				if Content:exist(path) then -- 2277
					return { -- 2278
						success = false, -- 2278
						message = "target project folder existed" -- 2278
					} -- 2278
				end -- 2277
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2279
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2280
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2281
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2282
					return { -- 2285
						success = false, -- 2285
						message = "missing template project" -- 2285
					} -- 2285
				end -- 2282
				if not Content:mkdir(path) then -- 2286
					return { -- 2287
						success = false, -- 2287
						message = "failed to create project folder" -- 2287
					} -- 2287
				end -- 2286
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2288
					Content:remove(path) -- 2289
					return { -- 2290
						success = false, -- 2290
						message = "failed to copy template" -- 2290
					} -- 2290
				end -- 2288
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2291
					Content:remove(path) -- 2292
					return { -- 2293
						success = false, -- 2293
						message = "failed to copy template" -- 2293
					} -- 2293
				end -- 2291
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2294
					Content:remove(path) -- 2295
					return { -- 2296
						success = false, -- 2296
						message = "failed to copy template" -- 2296
					} -- 2296
				end -- 2294
				return { -- 2297
					success = true -- 2297
				} -- 2297
			end -- 2274
		end -- 2274
	end -- 2274
	return { -- 2273
		success = false, -- 2273
		message = "invalid call" -- 2273
	} -- 2273
end) -- 2273
local tsBuildGlobs = { -- 2300
	"**/*.ts", -- 2300
	"**/*.tsx", -- 2301
	"!**/.*/**", -- 2302
	"!**/node_modules/**" -- 2303
} -- 2299
local transpileTSFile -- 2305
do -- 2305
	local tsBuildTimeout <const> = 30 -- 2306
	local tsBuildRequestId = 0 -- 2307
	transpileTSFile = function(file, content, sourceRoot) -- 2308
		tsBuildRequestId = tsBuildRequestId + 1 -- 2309
		local requestId = tsBuildRequestId -- 2310
		local done = false -- 2311
		local result = nil -- 2312
		local listener = Node() -- 2313
		listener:gslot("AppWS", function(event) -- 2314
			if event.type == "Receive" then -- 2315
				local res = json.decode(event.msg) -- 2316
				if res then -- 2316
					if res.name == "TranspileTS" and res.id == requestId then -- 2317
						listener:removeFromParent() -- 2318
						if res.success then -- 2319
							local luaFile = Path:replaceExt(file, "lua") -- 2320
							Content:save(luaFile, res.luaCode) -- 2321
							result = { -- 2322
								success = true, -- 2322
								file = file -- 2322
							} -- 2322
						else -- 2324
							result = { -- 2324
								success = false, -- 2324
								file = file, -- 2324
								message = res.message -- 2324
							} -- 2324
						end -- 2319
						done = true -- 2325
					end -- 2317
				end -- 2316
			end -- 2315
		end) -- 2314
		emit("AppWS", "Send", json.encode({ -- 2326
			name = "TranspileTS", -- 2326
			id = requestId, -- 2326
			file = file, -- 2326
			content = content, -- 2326
			projectRoot = sourceRoot -- 2326
		})) -- 2326
		local deadline = App.runningTime + tsBuildTimeout -- 2327
		wait(function() -- 2328
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline -- 2328
		end) -- 2328
		if not done then -- 2329
			listener:removeFromParent() -- 2330
			if HttpServer.wsConnectionCount == 0 then -- 2331
				return { -- 2332
					success = false, -- 2332
					file = file, -- 2332
					message = "Web IDE disconnected" -- 2332
				} -- 2332
			end -- 2331
			return { -- 2333
				success = false, -- 2333
				file = file, -- 2333
				message = "TypeScript transpile timed out" -- 2333
			} -- 2333
		end -- 2329
		return result -- 2334
	end -- 2308
end -- 2305
local _anon_func_6 = function(path) -- 2345
	local _val_0 = Path:getExt(path) -- 2345
	return "ts" == _val_0 or "tsx" == _val_0 -- 2345
end -- 2345
HttpServer:postSchedule("/ts/build", function(req) -- 2336
	do -- 2337
		local _type_0 = type(req) -- 2337
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2337
		if _tab_0 then -- 2337
			local path -- 2337
			do -- 2337
				local _obj_0 = req.body -- 2337
				local _type_1 = type(_obj_0) -- 2337
				if "table" == _type_1 or "userdata" == _type_1 then -- 2337
					path = _obj_0.path -- 2337
				end -- 2337
			end -- 2337
			if path ~= nil then -- 2337
				if HttpServer.wsConnectionCount == 0 then -- 2338
					return { -- 2339
						success = false, -- 2339
						message = "Web IDE not connected" -- 2339
					} -- 2339
				end -- 2338
				local projectRoot = req.body.projectRoot -- 2340
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2341
				if not Content:exist(path) then -- 2342
					return { -- 2343
						success = false, -- 2343
						message = "path not existed" -- 2343
					} -- 2343
				end -- 2342
				if not Content:isdir(path) then -- 2344
					if not (_anon_func_6(path)) then -- 2345
						return { -- 2346
							success = false, -- 2346
							message = "expecting a TypeScript file" -- 2346
						} -- 2346
					end -- 2345
					local messages = { } -- 2347
					local content = Content:load(path) -- 2348
					if not content then -- 2349
						return { -- 2350
							success = false, -- 2350
							message = "failed to read file" -- 2350
						} -- 2350
					end -- 2349
					emit("AppWS", "Send", json.encode({ -- 2351
						name = "UpdateFile", -- 2351
						file = path, -- 2351
						exists = true, -- 2351
						content = content, -- 2351
						projectRoot = sourceRoot -- 2351
					})) -- 2351
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2352
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot) -- 2353
					end -- 2352
					return { -- 2354
						success = true, -- 2354
						messages = messages -- 2354
					} -- 2354
				else -- 2356
					local fileData = { } -- 2356
					local messages = { } -- 2357
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2358
					for _index_0 = 1, #_list_0 do -- 2358
						local subFile = _list_0[_index_0] -- 2358
						local file = Path(path, subFile) -- 2359
						local content = Content:load(file) -- 2360
						if content then -- 2360
							fileData[file] = content -- 2361
							emit("AppWS", "Send", json.encode({ -- 2362
								name = "UpdateFile", -- 2362
								file = file, -- 2362
								exists = true, -- 2362
								content = content, -- 2362
								projectRoot = sourceRoot -- 2362
							})) -- 2362
						else -- 2364
							messages[#messages + 1] = { -- 2364
								success = false, -- 2364
								file = file, -- 2364
								message = "failed to read file" -- 2364
							} -- 2364
						end -- 2360
					end -- 2358
					for file, content in pairs(fileData) do -- 2365
						if "d" == Path:getExt(Path:getName(file)) then -- 2366
							goto _continue_0 -- 2366
						end -- 2366
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot) -- 2367
						::_continue_0:: -- 2366
					end -- 2365
					return { -- 2368
						success = true, -- 2368
						messages = messages -- 2368
					} -- 2368
				end -- 2344
			end -- 2337
		end -- 2337
	end -- 2337
	return { -- 2336
		success = false -- 2336
	} -- 2336
end) -- 2336
HttpServer:post("/download", function(req) -- 2370
	do -- 2371
		local _type_0 = type(req) -- 2371
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2371
		if _tab_0 then -- 2371
			local url -- 2371
			do -- 2371
				local _obj_0 = req.body -- 2371
				local _type_1 = type(_obj_0) -- 2371
				if "table" == _type_1 or "userdata" == _type_1 then -- 2371
					url = _obj_0.url -- 2371
				end -- 2371
			end -- 2371
			local target -- 2371
			do -- 2371
				local _obj_0 = req.body -- 2371
				local _type_1 = type(_obj_0) -- 2371
				if "table" == _type_1 or "userdata" == _type_1 then -- 2371
					target = _obj_0.target -- 2371
				end -- 2371
			end -- 2371
			if url ~= nil and target ~= nil then -- 2371
				local Entry = require("Script.Dev.Entry") -- 2372
				Entry.downloadFile(url, target) -- 2373
				return { -- 2374
					success = true -- 2374
				} -- 2374
			end -- 2371
		end -- 2371
	end -- 2371
	return { -- 2370
		success = false -- 2370
	} -- 2370
end) -- 2370
local isDesktopPlatform -- 2376
isDesktopPlatform = function() -- 2376
	local _val_0 = App.platform -- 2377
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2377
end -- 2376
local getServerStatus -- 2379
getServerStatus = function() -- 2379
	local Entry = require("Script.Dev.Entry") -- 2380
	local running = Entry.getCurrentEntryStatus() -- 2381
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2382
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2383
	return { -- 2385
		success = true, -- 2385
		platform = App.platform, -- 2386
		locale = App.locale, -- 2387
		version = App.version, -- 2388
		url = "http://localhost:8866", -- 2389
		wsConnectionCount = wsConnectionCount, -- 2390
		webIDEConnected = wsConnectionCount > 0, -- 2391
		assetPath = Content.assetPath, -- 2392
		writablePath = Content.writablePath, -- 2393
		appPath = Content.appPath, -- 2394
		waTemplateReady = waTemplateReady, -- 2395
		running = running -- 2396
	} -- 2384
end -- 2379
HttpServer:post("/status", function() -- 2399
	return getServerStatus() -- 2400
end) -- 2399
HttpServer:postSchedule("/doctor/fix", function(req) -- 2402
	do -- 2403
		local _type_0 = type(req) -- 2403
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2403
		if _tab_0 then -- 2403
			local openWebIDE -- 2403
			do -- 2403
				local _obj_0 = req.body -- 2403
				local _type_1 = type(_obj_0) -- 2403
				if "table" == _type_1 or "userdata" == _type_1 then -- 2403
					openWebIDE = _obj_0.openWebIDE -- 2403
				end -- 2403
			end -- 2403
			if openWebIDE ~= nil then -- 2403
				if not openWebIDE then -- 2404
					return { -- 2405
						success = false, -- 2405
						message = "nothing to fix" -- 2405
					} -- 2405
				end -- 2404
				local status = getServerStatus() -- 2406
				if status.webIDEConnected then -- 2407
					return { -- 2408
						success = true, -- 2408
						fixed = false, -- 2408
						message = "Web IDE already connected.", -- 2408
						status = status -- 2408
					} -- 2408
				end -- 2407
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2409
				if waitSeconds > 0 then -- 2410
					local deadline = os.time() + waitSeconds -- 2411
					repeat -- 2412
						sleep(0.2) -- 2413
						status = getServerStatus() -- 2414
						if status.webIDEConnected then -- 2415
							return { -- 2416
								success = true, -- 2416
								fixed = false, -- 2416
								reconnected = true, -- 2416
								message = "Web IDE reconnected.", -- 2416
								status = status -- 2416
							} -- 2416
						end -- 2415
					until os.time() >= deadline -- 2412
				end -- 2410
				if not isDesktopPlatform() then -- 2418
					return { -- 2419
						success = false, -- 2419
						message = "opening Web IDE is only supported on desktop platforms", -- 2419
						status = status -- 2419
					} -- 2419
				end -- 2418
				local url = "http://localhost:8866" -- 2420
				App:openURL(url) -- 2421
				status.openedURL = url -- 2422
				return { -- 2423
					success = true, -- 2423
					fixed = true, -- 2423
					message = "Opened Web IDE in the local browser.", -- 2423
					url = url, -- 2423
					status = status -- 2423
				} -- 2423
			end -- 2403
		end -- 2403
	end -- 2403
	return { -- 2402
		success = false, -- 2402
		message = "invalid call" -- 2402
	} -- 2402
end) -- 2402
local status = { } -- 2425
_module_0 = status -- 2426
status.buildAsync = function(path) -- 2428
	if not Content:exist(path) then -- 2429
		return { -- 2430
			success = false, -- 2430
			file = path, -- 2430
			message = "file not existed" -- 2430
		} -- 2430
	end -- 2429
	do -- 2431
		local _exp_0 = Path:getExt(path) -- 2431
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2431
			if '' == Path:getExt(Path:getName(path)) then -- 2432
				local content = Content:loadAsync(path) -- 2433
				if content then -- 2433
					local resultCodes, err = compileFileAsync(path, content) -- 2434
					if resultCodes then -- 2434
						return { -- 2435
							success = true, -- 2435
							file = path -- 2435
						} -- 2435
					else -- 2437
						return { -- 2437
							success = false, -- 2437
							file = path, -- 2437
							message = err -- 2437
						} -- 2437
					end -- 2434
				end -- 2433
			end -- 2432
		elseif "lua" == _exp_0 then -- 2438
			local content = Content:loadAsync(path) -- 2439
			if content then -- 2439
				do -- 2440
					local isTIC80 = CheckTIC80Code(content) -- 2440
					if isTIC80 then -- 2440
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2441
					end -- 2440
				end -- 2440
				local success, info -- 2442
				do -- 2442
					local _obj_0 = luaCheck(path, content) -- 2442
					success, info = _obj_0.success, _obj_0.info -- 2442
				end -- 2442
				if success then -- 2443
					return { -- 2444
						success = true, -- 2444
						file = path -- 2444
					} -- 2444
				elseif info and #info > 0 then -- 2445
					local messages = { } -- 2446
					for _index_0 = 1, #info do -- 2447
						local _des_0 = info[_index_0] -- 2447
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2447
						local lineText = "" -- 2448
						if line then -- 2449
							local currentLine = 1 -- 2450
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2451
								if currentLine == line then -- 2452
									lineText = text -- 2453
									break -- 2454
								end -- 2452
								currentLine = currentLine + 1 -- 2455
							end -- 2451
						end -- 2449
						if line then -- 2456
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2457
						else -- 2459
							messages[#messages + 1] = message -- 2459
						end -- 2456
					end -- 2447
					return { -- 2460
						success = false, -- 2460
						file = path, -- 2460
						message = table.concat(messages, "\n") -- 2460
					} -- 2460
				else -- 2462
					return { -- 2462
						success = false, -- 2462
						file = path, -- 2462
						message = "lua check failed" -- 2462
					} -- 2462
				end -- 2443
			end -- 2439
		elseif "yarn" == _exp_0 then -- 2463
			local content = Content:loadAsync(path) -- 2464
			if content then -- 2464
				local res, _, err = yarncompile(content, true) -- 2465
				if res then -- 2465
					return { -- 2466
						success = true, -- 2466
						file = path -- 2466
					} -- 2466
				else -- 2468
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2468
					local lineText = "" -- 2469
					if line then -- 2470
						local currentLine = 1 -- 2471
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2472
							if currentLine == line then -- 2473
								lineText = text -- 2474
								break -- 2475
							end -- 2473
							currentLine = currentLine + 1 -- 2476
						end -- 2472
					end -- 2470
					if node ~= "" then -- 2477
						node = "node: " .. tostring(node) .. ", " -- 2478
					else -- 2479
						node = "" -- 2479
					end -- 2477
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2480
					return { -- 2481
						success = false, -- 2481
						file = path, -- 2481
						message = message -- 2481
					} -- 2481
				end -- 2465
			end -- 2464
		end -- 2431
	end -- 2431
	return { -- 2482
		success = false, -- 2482
		file = path, -- 2482
		message = "invalid file to build" -- 2482
	} -- 2482
end -- 2428
thread(function() -- 2484
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 2485
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 2486
	if Content:exist(doraWeb) then -- 2487
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) -- 2488
		local needReload -- 2489
		if Content:exist(doraReady) then -- 2489
			needReload = readyContent ~= Content:load(doraReady) -- 2490
		else -- 2491
			needReload = true -- 2491
		end -- 2489
		if needReload then -- 2492
			Content:remove(Path(Content.appPath, ".www")) -- 2493
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 2494
			Content:save(doraReady, readyContent) -- 2498
			print("Dora Dora is ready!") -- 2499
		end -- 2492
	end -- 2487
	if HttpServer:start(8866) then -- 2500
		local localIP = HttpServer.localIP -- 2501
		if localIP == "" then -- 2502
			localIP = "localhost" -- 2502
		end -- 2502
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 2503
		return HttpServer:startWS(8868) -- 2504
	else -- 2506
		status.url = nil -- 2506
		return print("8866 Port not available!") -- 2507
	end -- 2500
end) -- 2484
return _module_0 -- 1
