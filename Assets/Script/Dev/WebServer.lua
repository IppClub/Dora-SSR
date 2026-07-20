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
				return AgentSession.sendPrompt(sessionId, prompt, false, req.body.disabledAgentTools, req.body.workMode) -- 752
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
				return AgentSession.continuePrompt(sessionId, req.body.disabledAgentTools) -- 756
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
				return AgentSession.finishSubSessionHandoff(sessionId) -- 760
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
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools, req.body.workMode) -- 764
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
				return AgentSession.respondQuestionnaire(sessionId, questionnaireId, answers) -- 768
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
				return AgentSession.cancelQuestionnaire(sessionId, questionnaireId) -- 772
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
				return { -- 807
					success = true, -- 807
					taskId = taskId, -- 808
					checkpoints = AgentTools.listCheckpoints(taskId) -- 809
				} -- 806
			end -- 802
		end -- 802
	end -- 802
	return invalidArguments -- 801
end) -- 801
HttpServer:post("/agent/checkpoint/diff", function(req) -- 811
	do -- 812
		local _type_0 = type(req) -- 812
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 812
		if _tab_0 then -- 812
			local checkpointId -- 812
			do -- 812
				local _obj_0 = req.body -- 812
				local _type_1 = type(_obj_0) -- 812
				if "table" == _type_1 or "userdata" == _type_1 then -- 812
					checkpointId = _obj_0.checkpointId -- 812
				end -- 812
			end -- 812
			if checkpointId ~= nil then -- 812
				if not (checkpointId > 0) then -- 813
					return { -- 813
						success = false, -- 813
						message = "invalid checkpointId" -- 813
					} -- 813
				end -- 813
				return AgentTools.getCheckpointDiff(checkpointId) -- 814
			end -- 812
		end -- 812
	end -- 812
	return invalidArguments -- 811
end) -- 811
HttpServer:post("/agent/task/diff", function(req) -- 816
	do -- 817
		local _type_0 = type(req) -- 817
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 817
		if _tab_0 then -- 817
			local taskId -- 817
			do -- 817
				local _obj_0 = req.body -- 817
				local _type_1 = type(_obj_0) -- 817
				if "table" == _type_1 or "userdata" == _type_1 then -- 817
					taskId = _obj_0.taskId -- 817
				end -- 817
			end -- 817
			if taskId ~= nil then -- 817
				if not (taskId > 0) then -- 818
					return { -- 818
						success = false, -- 818
						message = "invalid taskId" -- 818
					} -- 818
				end -- 818
				return AgentTools.getTaskChangeSetDiff(taskId) -- 819
			end -- 817
		end -- 817
	end -- 817
	return invalidArguments -- 816
end) -- 816
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 821
	do -- 822
		local _type_0 = type(req) -- 822
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 822
		if _tab_0 then -- 822
			local sessionId -- 822
			do -- 822
				local _obj_0 = req.body -- 822
				local _type_1 = type(_obj_0) -- 822
				if "table" == _type_1 or "userdata" == _type_1 then -- 822
					sessionId = _obj_0.sessionId -- 822
				end -- 822
			end -- 822
			local checkpointId -- 822
			do -- 822
				local _obj_0 = req.body -- 822
				local _type_1 = type(_obj_0) -- 822
				if "table" == _type_1 or "userdata" == _type_1 then -- 822
					checkpointId = _obj_0.checkpointId -- 822
				end -- 822
			end -- 822
			if sessionId ~= nil and checkpointId ~= nil then -- 822
				if not (checkpointId > 0) then -- 823
					return { -- 823
						success = false, -- 823
						message = "invalid checkpointId" -- 823
					} -- 823
				end -- 823
				local res = AgentSession.getSession(sessionId) -- 824
				if not res.success then -- 825
					return res -- 825
				end -- 825
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, res.session.projectRoot) -- 826
				if not rollbackRes.success then -- 827
					return rollbackRes -- 827
				end -- 827
				return { -- 829
					success = true, -- 829
					checkpointId = rollbackRes.checkpointId -- 830
				} -- 828
			end -- 822
		end -- 822
	end -- 822
	return invalidArguments -- 821
end) -- 821
HttpServer:post("/agent/task/rollback", function(req) -- 832
	do -- 833
		local _type_0 = type(req) -- 833
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 833
		if _tab_0 then -- 833
			local sessionId -- 833
			do -- 833
				local _obj_0 = req.body -- 833
				local _type_1 = type(_obj_0) -- 833
				if "table" == _type_1 or "userdata" == _type_1 then -- 833
					sessionId = _obj_0.sessionId -- 833
				end -- 833
			end -- 833
			local taskId -- 833
			do -- 833
				local _obj_0 = req.body -- 833
				local _type_1 = type(_obj_0) -- 833
				if "table" == _type_1 or "userdata" == _type_1 then -- 833
					taskId = _obj_0.taskId -- 833
				end -- 833
			end -- 833
			if sessionId ~= nil and taskId ~= nil then -- 833
				if not (taskId > 0) then -- 834
					return { -- 834
						success = false, -- 834
						message = "invalid taskId" -- 834
					} -- 834
				end -- 834
				local res = AgentSession.getSession(sessionId) -- 835
				if not res.success then -- 836
					return res -- 836
				end -- 836
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, res.session.projectRoot) -- 837
				if not rollbackRes.success then -- 838
					return rollbackRes -- 838
				end -- 838
				return { -- 840
					success = true, -- 840
					taskId = rollbackRes.taskId, -- 841
					checkpointId = rollbackRes.checkpointId, -- 842
					checkpointCount = rollbackRes.checkpointCount -- 843
				} -- 839
			end -- 833
		end -- 833
	end -- 833
	return invalidArguments -- 832
end) -- 832
local getSearchPath -- 845
getSearchPath = function(file) -- 845
	do -- 846
		local dir = getProjectDirFromFile(file) -- 846
		if dir then -- 846
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 847
		end -- 846
	end -- 846
	return "" -- 845
end -- 845
local getSearchFolders -- 849
getSearchFolders = function(file) -- 849
	do -- 850
		local dir = getProjectDirFromFile(file) -- 850
		if dir then -- 850
			return { -- 852
				Path(dir, "Script"), -- 852
				dir -- 853
			} -- 851
		end -- 850
	end -- 850
	return { } -- 849
end -- 849
local disabledCheckForLua = { -- 856
	"incompatible number of returns", -- 856
	"unknown", -- 857
	"cannot index", -- 858
	"module not found", -- 859
	"don't know how to resolve", -- 860
	"ContainerItem", -- 861
	"cannot resolve a type", -- 862
	"invalid key", -- 863
	"inconsistent index type", -- 864
	"cannot use operator", -- 865
	"attempting ipairs loop", -- 866
	"expects record or nominal", -- 867
	"variable is not being assigned", -- 868
	"<invalid type>", -- 869
	"<any type>", -- 870
	"using the '#' operator", -- 871
	"can't match a record", -- 872
	"redeclaration of variable", -- 873
	"cannot apply pairs", -- 874
	"not a function", -- 875
	"to%-be%-closed" -- 876
} -- 855
local yueCheck -- 878
yueCheck = function(file, content, lax) -- 878
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 879
	if isTIC80 then -- 880
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 881
	end -- 880
	local searchPath = getSearchPath(file) -- 882
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 883
	local info = { } -- 884
	local globals = { } -- 885
	for _index_0 = 1, #checkResult do -- 886
		local _des_0 = checkResult[_index_0] -- 886
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 886
		if "error" == t then -- 887
			info[#info + 1] = { -- 888
				"syntax", -- 888
				file, -- 888
				line, -- 888
				col, -- 888
				msg -- 888
			} -- 888
		elseif "global" == t then -- 889
			globals[#globals + 1] = { -- 890
				msg, -- 890
				line, -- 890
				col -- 890
			} -- 890
		end -- 887
	end -- 886
	if luaCodes then -- 891
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 892
		if success then -- 893
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 894
			if not (lintResult == "") then -- 895
				lintResult = lintResult .. "\n" -- 895
			end -- 895
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 896
		else -- 897
			for _index_0 = 1, #lintResult do -- 897
				local _des_0 = lintResult[_index_0] -- 897
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 897
				if isTIC80 and tic80APIs[name] then -- 898
					goto _continue_0 -- 898
				end -- 898
				info[#info + 1] = { -- 899
					"syntax", -- 899
					file, -- 899
					line, -- 899
					col, -- 899
					"invalid global variable" -- 899
				} -- 899
				::_continue_0:: -- 898
			end -- 897
		end -- 893
	end -- 891
	return luaCodes, info -- 900
end -- 878
local luaCheck -- 902
luaCheck = function(file, content) -- 902
	local res, err = load(content, "check") -- 903
	if not res then -- 904
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 905
		return { -- 906
			success = false, -- 906
			info = { -- 906
				{ -- 906
					"syntax", -- 906
					file, -- 906
					tonumber(line), -- 906
					0, -- 906
					msg -- 906
				} -- 906
			} -- 906
		} -- 906
	end -- 904
	local success, info = teal.checkAsync(content, file, true, "") -- 907
	if info then -- 908
		do -- 909
			local _accum_0 = { } -- 909
			local _len_0 = 1 -- 909
			for _index_0 = 1, #info do -- 909
				local item = info[_index_0] -- 909
				local useCheck = true -- 910
				if not item[5]:match("unused") then -- 911
					for _index_1 = 1, #disabledCheckForLua do -- 912
						local check = disabledCheckForLua[_index_1] -- 912
						if item[5]:match(check) then -- 913
							useCheck = false -- 914
						end -- 913
					end -- 912
				end -- 911
				if not useCheck then -- 915
					goto _continue_0 -- 915
				end -- 915
				do -- 916
					local _exp_0 = item[1] -- 916
					if "type" == _exp_0 then -- 917
						item[1] = "warning" -- 918
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 919
						goto _continue_0 -- 920
					end -- 916
				end -- 916
				_accum_0[_len_0] = item -- 921
				_len_0 = _len_0 + 1 -- 910
				::_continue_0:: -- 910
			end -- 909
			info = _accum_0 -- 909
		end -- 909
		if #info == 0 then -- 922
			info = nil -- 923
			success = true -- 924
		end -- 922
	end -- 908
	return { -- 925
		success = success, -- 925
		info = info -- 925
	} -- 925
end -- 902
local luaCheckWithLineInfo -- 927
luaCheckWithLineInfo = function(file, luaCodes) -- 927
	local res = luaCheck(file, luaCodes) -- 928
	local info = { } -- 929
	if not res.success then -- 930
		local current = 1 -- 931
		local lastLine = 1 -- 932
		local lineMap = { } -- 933
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 934
			local num = lineCode:match("--%s*(%d+)%s*$") -- 935
			if num then -- 936
				lastLine = tonumber(num) -- 937
			end -- 936
			lineMap[current] = lastLine -- 938
			current = current + 1 -- 939
		end -- 934
		local _list_0 = res.info -- 940
		for _index_0 = 1, #_list_0 do -- 940
			local item = _list_0[_index_0] -- 940
			item[3] = lineMap[item[3]] or 0 -- 941
			item[4] = 0 -- 942
			info[#info + 1] = item -- 943
		end -- 940
		return false, info -- 944
	end -- 930
	return true, info -- 945
end -- 927
local getCompiledYueLine -- 947
getCompiledYueLine = function(content, line, row, file, lax) -- 947
	local luaCodes = yueCheck(file, content, lax) -- 948
	if not luaCodes then -- 949
		return nil -- 949
	end -- 949
	local current = 1 -- 950
	local lastLine = 1 -- 951
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 952
	local targetRow = nil -- 953
	local lineMap = { } -- 954
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 955
		local num = lineCode:match("--%s*(%d+)%s*$") -- 956
		if num then -- 957
			lastLine = tonumber(num) -- 957
		end -- 957
		lineMap[current] = lastLine -- 958
		if row <= lastLine and not targetRow then -- 959
			targetRow = current -- 960
			break -- 961
		end -- 959
		current = current + 1 -- 962
	end -- 955
	targetRow = current -- 963
	if targetLine and targetRow then -- 964
		return luaCodes, targetLine, targetRow, lineMap -- 965
	else -- 967
		return nil -- 967
	end -- 964
end -- 947
HttpServer:postSchedule("/check", function(req) -- 969
	do -- 970
		local _type_0 = type(req) -- 970
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 970
		if _tab_0 then -- 970
			local file -- 970
			do -- 970
				local _obj_0 = req.body -- 970
				local _type_1 = type(_obj_0) -- 970
				if "table" == _type_1 or "userdata" == _type_1 then -- 970
					file = _obj_0.file -- 970
				end -- 970
			end -- 970
			local content -- 970
			do -- 970
				local _obj_0 = req.body -- 970
				local _type_1 = type(_obj_0) -- 970
				if "table" == _type_1 or "userdata" == _type_1 then -- 970
					content = _obj_0.content -- 970
				end -- 970
			end -- 970
			if file ~= nil and content ~= nil then -- 970
				local ext = Path:getExt(file) -- 971
				if "tl" == ext then -- 972
					local searchPath = getSearchPath(file) -- 973
					do -- 974
						local isTIC80 = CheckTIC80Code(content) -- 974
						if isTIC80 then -- 974
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 975
						end -- 974
					end -- 974
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 976
					return { -- 977
						success = success, -- 977
						info = info -- 977
					} -- 977
				elseif "lua" == ext then -- 978
					do -- 979
						local isTIC80 = CheckTIC80Code(content) -- 979
						if isTIC80 then -- 979
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 980
						end -- 979
					end -- 979
					return luaCheck(file, content) -- 981
				elseif "yue" == ext then -- 982
					local luaCodes, info = yueCheck(file, content, false) -- 983
					local success = false -- 984
					if luaCodes then -- 985
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 986
						do -- 987
							local _tab_1 = { } -- 987
							local _idx_0 = #_tab_1 + 1 -- 987
							for _index_0 = 1, #info do -- 987
								local _value_0 = info[_index_0] -- 987
								_tab_1[_idx_0] = _value_0 -- 987
								_idx_0 = _idx_0 + 1 -- 987
							end -- 987
							local _idx_1 = #_tab_1 + 1 -- 987
							for _index_0 = 1, #luaInfo do -- 987
								local _value_0 = luaInfo[_index_0] -- 987
								_tab_1[_idx_1] = _value_0 -- 987
								_idx_1 = _idx_1 + 1 -- 987
							end -- 987
							info = _tab_1 -- 987
						end -- 987
						success = success and luaSuccess -- 988
					end -- 985
					if #info > 0 then -- 989
						return { -- 990
							success = success, -- 990
							info = info -- 990
						} -- 990
					else -- 992
						return { -- 992
							success = success -- 992
						} -- 992
					end -- 989
				elseif "xml" == ext then -- 993
					local success, result = xml.check(content) -- 994
					if success then -- 995
						local info -- 996
						success, info = luaCheckWithLineInfo(file, result) -- 996
						if #info > 0 then -- 997
							return { -- 998
								success = success, -- 998
								info = info -- 998
							} -- 998
						else -- 1000
							return { -- 1000
								success = success -- 1000
							} -- 1000
						end -- 997
					else -- 1002
						local info -- 1002
						do -- 1002
							local _accum_0 = { } -- 1002
							local _len_0 = 1 -- 1002
							for _index_0 = 1, #result do -- 1002
								local _des_0 = result[_index_0] -- 1002
								local row, err = _des_0[1], _des_0[2] -- 1002
								_accum_0[_len_0] = { -- 1003
									"syntax", -- 1003
									file, -- 1003
									row, -- 1003
									0, -- 1003
									err -- 1003
								} -- 1003
								_len_0 = _len_0 + 1 -- 1003
							end -- 1002
							info = _accum_0 -- 1002
						end -- 1002
						return { -- 1004
							success = false, -- 1004
							info = info -- 1004
						} -- 1004
					end -- 995
				end -- 972
			end -- 970
		end -- 970
	end -- 970
	return { -- 969
		success = true -- 969
	} -- 969
end) -- 969
HttpServer:post("/body/parse", function(req) -- 1006
	do -- 1007
		local _type_0 = type(req) -- 1007
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1007
		if _tab_0 then -- 1007
			local file -- 1007
			do -- 1007
				local _obj_0 = req.body -- 1007
				local _type_1 = type(_obj_0) -- 1007
				if "table" == _type_1 or "userdata" == _type_1 then -- 1007
					file = _obj_0.file -- 1007
				end -- 1007
			end -- 1007
			local content -- 1007
			do -- 1007
				local _obj_0 = req.body -- 1007
				local _type_1 = type(_obj_0) -- 1007
				if "table" == _type_1 or "userdata" == _type_1 then -- 1007
					content = _obj_0.content -- 1007
				end -- 1007
			end -- 1007
			if file ~= nil and content ~= nil then -- 1007
				if not (file:sub(-6) == ".b.lua") then -- 1008
					return { -- 1009
						success = false, -- 1009
						phase = "request", -- 1009
						message = "only .b.lua files can be converted" -- 1009
					} -- 1009
				end -- 1008
				local loader, err = load("_ENV = {}\n" .. content) -- 1010
				if not loader then -- 1011
					return { -- 1012
						success = false, -- 1012
						phase = "parse", -- 1012
						message = tostring(err) -- 1012
					} -- 1012
				end -- 1011
				local ok, data = pcall(loader) -- 1013
				if not ok then -- 1014
					return { -- 1015
						success = false, -- 1015
						phase = "execute", -- 1015
						message = tostring(data) -- 1015
					} -- 1015
				end -- 1014
				if not ("table" == type(data) and data[1] == "Array") then -- 1016
					return { -- 1017
						success = false, -- 1017
						phase = "validate", -- 1017
						message = "body lua root must be {\"Array\", ...}" -- 1017
					} -- 1017
				end -- 1016
				local text, jsonErr = json.encode(data, false, true) -- 1018
				if not text then -- 1019
					return { -- 1020
						success = false, -- 1020
						phase = "encode", -- 1020
						message = tostring(jsonErr) -- 1020
					} -- 1020
				end -- 1019
				return { -- 1021
					success = true, -- 1021
					json = text -- 1021
				} -- 1021
			end -- 1007
		end -- 1007
	end -- 1007
	return { -- 1006
		success = false, -- 1006
		phase = "request", -- 1006
		message = "invalid request" -- 1006
	} -- 1006
end) -- 1006
local updateInferedDesc -- 1023
updateInferedDesc = function(infered) -- 1023
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1024
		return -- 1024
	end -- 1024
	local key, row = infered.key, infered.row -- 1025
	local codes = Content:loadAsync(key) -- 1026
	if codes then -- 1026
		local comments = { } -- 1027
		local line = 0 -- 1028
		local skipping = false -- 1029
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1030
			line = line + 1 -- 1031
			if line >= row then -- 1032
				break -- 1032
			end -- 1032
			if lineCode:match("^%s*%-%- @") then -- 1033
				skipping = true -- 1034
				goto _continue_0 -- 1035
			end -- 1033
			local result = lineCode:match("^%s*%-%- (.+)") -- 1036
			if result then -- 1036
				if not skipping then -- 1037
					comments[#comments + 1] = result -- 1037
				end -- 1037
			elseif #comments > 0 then -- 1038
				comments = { } -- 1039
				skipping = false -- 1040
			end -- 1036
			::_continue_0:: -- 1031
		end -- 1030
		infered.doc = table.concat(comments, "\n") -- 1041
	end -- 1026
end -- 1023
HttpServer:postSchedule("/infer", function(req) -- 1043
	do -- 1044
		local _type_0 = type(req) -- 1044
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1044
		if _tab_0 then -- 1044
			local lang -- 1044
			do -- 1044
				local _obj_0 = req.body -- 1044
				local _type_1 = type(_obj_0) -- 1044
				if "table" == _type_1 or "userdata" == _type_1 then -- 1044
					lang = _obj_0.lang -- 1044
				end -- 1044
			end -- 1044
			local file -- 1044
			do -- 1044
				local _obj_0 = req.body -- 1044
				local _type_1 = type(_obj_0) -- 1044
				if "table" == _type_1 or "userdata" == _type_1 then -- 1044
					file = _obj_0.file -- 1044
				end -- 1044
			end -- 1044
			local content -- 1044
			do -- 1044
				local _obj_0 = req.body -- 1044
				local _type_1 = type(_obj_0) -- 1044
				if "table" == _type_1 or "userdata" == _type_1 then -- 1044
					content = _obj_0.content -- 1044
				end -- 1044
			end -- 1044
			local line -- 1044
			do -- 1044
				local _obj_0 = req.body -- 1044
				local _type_1 = type(_obj_0) -- 1044
				if "table" == _type_1 or "userdata" == _type_1 then -- 1044
					line = _obj_0.line -- 1044
				end -- 1044
			end -- 1044
			local row -- 1044
			do -- 1044
				local _obj_0 = req.body -- 1044
				local _type_1 = type(_obj_0) -- 1044
				if "table" == _type_1 or "userdata" == _type_1 then -- 1044
					row = _obj_0.row -- 1044
				end -- 1044
			end -- 1044
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1044
				local searchPath = getSearchPath(file) -- 1045
				if "tl" == lang or "lua" == lang then -- 1046
					if CheckTIC80Code(content) then -- 1047
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1048
					end -- 1047
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1049
					if (infered ~= nil) then -- 1050
						updateInferedDesc(infered) -- 1051
						return { -- 1052
							success = true, -- 1052
							infered = infered -- 1052
						} -- 1052
					end -- 1050
				elseif "yue" == lang then -- 1053
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1054
					if not luaCodes then -- 1055
						return { -- 1055
							success = false -- 1055
						} -- 1055
					end -- 1055
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1056
					if (infered ~= nil) then -- 1057
						local col -- 1058
						file, row, col = infered.file, infered.row, infered.col -- 1058
						if file == "" and row > 0 and col > 0 then -- 1059
							infered.row = lineMap[row] or 0 -- 1060
							infered.col = 0 -- 1061
						end -- 1059
						updateInferedDesc(infered) -- 1062
						return { -- 1063
							success = true, -- 1063
							infered = infered -- 1063
						} -- 1063
					end -- 1057
				end -- 1046
			end -- 1044
		end -- 1044
	end -- 1044
	return { -- 1043
		success = false -- 1043
	} -- 1043
end) -- 1043
local _anon_func_3 = function(doc) -- 1114
	local _accum_0 = { } -- 1114
	local _len_0 = 1 -- 1114
	local _list_0 = doc.params -- 1114
	for _index_0 = 1, #_list_0 do -- 1114
		local param = _list_0[_index_0] -- 1114
		_accum_0[_len_0] = param.name -- 1114
		_len_0 = _len_0 + 1 -- 1114
	end -- 1114
	return _accum_0 -- 1114
end -- 1114
local getParamDocs -- 1065
getParamDocs = function(signatures) -- 1065
	do -- 1066
		local codes = Content:loadAsync(signatures[1].file) -- 1066
		if codes then -- 1066
			local comments = { } -- 1067
			local params = { } -- 1068
			local line = 0 -- 1069
			local docs = { } -- 1070
			local returnType = nil -- 1071
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1072
				line = line + 1 -- 1073
				local needBreak = true -- 1074
				for i, _des_0 in ipairs(signatures) do -- 1075
					local row = _des_0.row -- 1075
					if line >= row and not (docs[i] ~= nil) then -- 1076
						if #comments > 0 or #params > 0 or returnType then -- 1077
							docs[i] = { -- 1079
								doc = table.concat(comments, "  \n"), -- 1079
								returnType = returnType -- 1080
							} -- 1078
							if #params > 0 then -- 1082
								docs[i].params = params -- 1082
							end -- 1082
						else -- 1084
							docs[i] = false -- 1084
						end -- 1077
					end -- 1076
					if not docs[i] then -- 1085
						needBreak = false -- 1085
					end -- 1085
				end -- 1075
				if needBreak then -- 1086
					break -- 1086
				end -- 1086
				local result = lineCode:match("%s*%-%- (.+)") -- 1087
				if result then -- 1087
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1088
					if not name then -- 1089
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1090
					end -- 1089
					if name then -- 1091
						local pname = name -- 1092
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1093
							pname = pname .. "?" -- 1093
						end -- 1093
						params[#params + 1] = { -- 1095
							name = tostring(pname) .. ": " .. tostring(typ), -- 1095
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1096
						} -- 1094
					else -- 1099
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1099
						if typ then -- 1099
							if returnType then -- 1100
								returnType = returnType .. ", " .. typ -- 1101
							else -- 1103
								returnType = typ -- 1103
							end -- 1100
							result = result:gsub("@return", "**return:**") -- 1104
						end -- 1099
						comments[#comments + 1] = result -- 1105
					end -- 1091
				elseif #comments > 0 then -- 1106
					comments = { } -- 1107
					params = { } -- 1108
					returnType = nil -- 1109
				end -- 1087
			end -- 1072
			local results = { } -- 1110
			for _index_0 = 1, #docs do -- 1111
				local doc = docs[_index_0] -- 1111
				if not doc then -- 1112
					goto _continue_0 -- 1112
				end -- 1112
				if doc.params then -- 1113
					doc.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1114
				else -- 1116
					doc.desc = "function()" -- 1116
				end -- 1113
				if doc.returnType then -- 1117
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 1118
					doc.returnType = nil -- 1119
				end -- 1117
				results[#results + 1] = doc -- 1120
				::_continue_0:: -- 1112
			end -- 1111
			if #results > 0 then -- 1121
				return results -- 1121
			else -- 1121
				return nil -- 1121
			end -- 1121
		end -- 1066
	end -- 1066
	return nil -- 1065
end -- 1065
HttpServer:postSchedule("/signature", function(req) -- 1123
	do -- 1124
		local _type_0 = type(req) -- 1124
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1124
		if _tab_0 then -- 1124
			local lang -- 1124
			do -- 1124
				local _obj_0 = req.body -- 1124
				local _type_1 = type(_obj_0) -- 1124
				if "table" == _type_1 or "userdata" == _type_1 then -- 1124
					lang = _obj_0.lang -- 1124
				end -- 1124
			end -- 1124
			local file -- 1124
			do -- 1124
				local _obj_0 = req.body -- 1124
				local _type_1 = type(_obj_0) -- 1124
				if "table" == _type_1 or "userdata" == _type_1 then -- 1124
					file = _obj_0.file -- 1124
				end -- 1124
			end -- 1124
			local content -- 1124
			do -- 1124
				local _obj_0 = req.body -- 1124
				local _type_1 = type(_obj_0) -- 1124
				if "table" == _type_1 or "userdata" == _type_1 then -- 1124
					content = _obj_0.content -- 1124
				end -- 1124
			end -- 1124
			local line -- 1124
			do -- 1124
				local _obj_0 = req.body -- 1124
				local _type_1 = type(_obj_0) -- 1124
				if "table" == _type_1 or "userdata" == _type_1 then -- 1124
					line = _obj_0.line -- 1124
				end -- 1124
			end -- 1124
			local row -- 1124
			do -- 1124
				local _obj_0 = req.body -- 1124
				local _type_1 = type(_obj_0) -- 1124
				if "table" == _type_1 or "userdata" == _type_1 then -- 1124
					row = _obj_0.row -- 1124
				end -- 1124
			end -- 1124
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1124
				local searchPath = getSearchPath(file) -- 1125
				if "tl" == lang or "lua" == lang then -- 1126
					if CheckTIC80Code(content) then -- 1127
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1128
					end -- 1127
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1129
					if signatures then -- 1129
						signatures = getParamDocs(signatures) -- 1130
						if signatures then -- 1130
							return { -- 1131
								success = true, -- 1131
								signatures = signatures -- 1131
							} -- 1131
						end -- 1130
					end -- 1129
				elseif "yue" == lang then -- 1132
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1133
					if not luaCodes then -- 1134
						return { -- 1134
							success = false -- 1134
						} -- 1134
					end -- 1134
					do -- 1135
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1135
						if chainOp then -- 1135
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1136
							if withVar then -- 1136
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1137
							end -- 1136
						end -- 1135
					end -- 1135
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1138
					if signatures then -- 1138
						signatures = getParamDocs(signatures) -- 1139
						if signatures then -- 1139
							return { -- 1140
								success = true, -- 1140
								signatures = signatures -- 1140
							} -- 1140
						end -- 1139
					else -- 1141
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1141
						if signatures then -- 1141
							signatures = getParamDocs(signatures) -- 1142
							if signatures then -- 1142
								return { -- 1143
									success = true, -- 1143
									signatures = signatures -- 1143
								} -- 1143
							end -- 1142
						end -- 1141
					end -- 1138
				end -- 1126
			end -- 1124
		end -- 1124
	end -- 1124
	return { -- 1123
		success = false -- 1123
	} -- 1123
end) -- 1123
local luaKeywords = { -- 1146
	'and', -- 1146
	'break', -- 1147
	'do', -- 1148
	'else', -- 1149
	'elseif', -- 1150
	'end', -- 1151
	'false', -- 1152
	'for', -- 1153
	'function', -- 1154
	'goto', -- 1155
	'if', -- 1156
	'in', -- 1157
	'local', -- 1158
	'nil', -- 1159
	'not', -- 1160
	'or', -- 1161
	'repeat', -- 1162
	'return', -- 1163
	'then', -- 1164
	'true', -- 1165
	'until', -- 1166
	'while' -- 1167
} -- 1145
local tealKeywords = { -- 1171
	'record', -- 1171
	'as', -- 1172
	'is', -- 1173
	'type', -- 1174
	'embed', -- 1175
	'enum', -- 1176
	'global', -- 1177
	'any', -- 1178
	'boolean', -- 1179
	'integer', -- 1180
	'number', -- 1181
	'string', -- 1182
	'thread' -- 1183
} -- 1170
local yueKeywords = { -- 1187
	"and", -- 1187
	"break", -- 1188
	"do", -- 1189
	"else", -- 1190
	"elseif", -- 1191
	"false", -- 1192
	"for", -- 1193
	"goto", -- 1194
	"if", -- 1195
	"in", -- 1196
	"local", -- 1197
	"nil", -- 1198
	"not", -- 1199
	"or", -- 1200
	"repeat", -- 1201
	"return", -- 1202
	"then", -- 1203
	"true", -- 1204
	"until", -- 1205
	"while", -- 1206
	"as", -- 1207
	"class", -- 1208
	"continue", -- 1209
	"export", -- 1210
	"extends", -- 1211
	"from", -- 1212
	"global", -- 1213
	"import", -- 1214
	"macro", -- 1215
	"switch", -- 1216
	"try", -- 1217
	"unless", -- 1218
	"using", -- 1219
	"when", -- 1220
	"with" -- 1221
} -- 1186
local _anon_func_4 = function(f) -- 1257
	local _val_0 = Path:getExt(f) -- 1257
	return "ttf" == _val_0 or "otf" == _val_0 -- 1257
end -- 1257
local _anon_func_5 = function(suggestions) -- 1283
	local _tbl_0 = { } -- 1283
	for _index_0 = 1, #suggestions do -- 1283
		local item = suggestions[_index_0] -- 1283
		_tbl_0[item[1] .. item[2]] = item -- 1283
	end -- 1283
	return _tbl_0 -- 1283
end -- 1283
HttpServer:postSchedule("/complete", function(req) -- 1224
	do -- 1225
		local _type_0 = type(req) -- 1225
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1225
		if _tab_0 then -- 1225
			local lang -- 1225
			do -- 1225
				local _obj_0 = req.body -- 1225
				local _type_1 = type(_obj_0) -- 1225
				if "table" == _type_1 or "userdata" == _type_1 then -- 1225
					lang = _obj_0.lang -- 1225
				end -- 1225
			end -- 1225
			local file -- 1225
			do -- 1225
				local _obj_0 = req.body -- 1225
				local _type_1 = type(_obj_0) -- 1225
				if "table" == _type_1 or "userdata" == _type_1 then -- 1225
					file = _obj_0.file -- 1225
				end -- 1225
			end -- 1225
			local content -- 1225
			do -- 1225
				local _obj_0 = req.body -- 1225
				local _type_1 = type(_obj_0) -- 1225
				if "table" == _type_1 or "userdata" == _type_1 then -- 1225
					content = _obj_0.content -- 1225
				end -- 1225
			end -- 1225
			local line -- 1225
			do -- 1225
				local _obj_0 = req.body -- 1225
				local _type_1 = type(_obj_0) -- 1225
				if "table" == _type_1 or "userdata" == _type_1 then -- 1225
					line = _obj_0.line -- 1225
				end -- 1225
			end -- 1225
			local row -- 1225
			do -- 1225
				local _obj_0 = req.body -- 1225
				local _type_1 = type(_obj_0) -- 1225
				if "table" == _type_1 or "userdata" == _type_1 then -- 1225
					row = _obj_0.row -- 1225
				end -- 1225
			end -- 1225
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1225
				local searchPath = getSearchPath(file) -- 1226
				repeat -- 1227
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1228
					if lang == "yue" then -- 1229
						if not item then -- 1230
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1230
						end -- 1230
						if not item then -- 1231
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1231
						end -- 1231
					end -- 1229
					local searchType = nil -- 1232
					if not item then -- 1233
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1234
						if lang == "yue" then -- 1235
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1236
						end -- 1235
						if (item ~= nil) then -- 1237
							searchType = "Image" -- 1237
						end -- 1237
					end -- 1233
					if not item then -- 1238
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1239
						if lang == "yue" then -- 1240
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1241
						end -- 1240
						if (item ~= nil) then -- 1242
							searchType = "Font" -- 1242
						end -- 1242
					end -- 1238
					if not item then -- 1243
						break -- 1243
					end -- 1243
					local searchPaths = Content.searchPaths -- 1244
					local _list_0 = getSearchFolders(file) -- 1245
					for _index_0 = 1, #_list_0 do -- 1245
						local folder = _list_0[_index_0] -- 1245
						searchPaths[#searchPaths + 1] = folder -- 1246
					end -- 1245
					if searchType then -- 1247
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1247
					end -- 1247
					local tokens -- 1248
					do -- 1248
						local _accum_0 = { } -- 1248
						local _len_0 = 1 -- 1248
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1248
							_accum_0[_len_0] = mod -- 1248
							_len_0 = _len_0 + 1 -- 1248
						end -- 1248
						tokens = _accum_0 -- 1248
					end -- 1248
					local suggestions = { } -- 1249
					for _index_0 = 1, #searchPaths do -- 1250
						local path = searchPaths[_index_0] -- 1250
						local sPath = Path(path, table.unpack(tokens)) -- 1251
						if not Content:exist(sPath) then -- 1252
							goto _continue_0 -- 1252
						end -- 1252
						if searchType == "Font" then -- 1253
							local fontPath = Path(sPath, "Font") -- 1254
							if Content:exist(fontPath) then -- 1255
								local _list_1 = Content:getFiles(fontPath) -- 1256
								for _index_1 = 1, #_list_1 do -- 1256
									local f = _list_1[_index_1] -- 1256
									if _anon_func_4(f) then -- 1257
										if "." == f:sub(1, 1) then -- 1258
											goto _continue_1 -- 1258
										end -- 1258
										suggestions[#suggestions + 1] = { -- 1259
											Path:getName(f), -- 1259
											"font", -- 1259
											"field" -- 1259
										} -- 1259
									end -- 1257
									::_continue_1:: -- 1257
								end -- 1256
							end -- 1255
						end -- 1253
						local _list_1 = Content:getFiles(sPath) -- 1260
						for _index_1 = 1, #_list_1 do -- 1260
							local f = _list_1[_index_1] -- 1260
							if "Image" == searchType then -- 1261
								do -- 1262
									local _exp_0 = Path:getExt(f) -- 1262
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1262
										if "." == f:sub(1, 1) then -- 1263
											goto _continue_2 -- 1263
										end -- 1263
										suggestions[#suggestions + 1] = { -- 1264
											f, -- 1264
											"image", -- 1264
											"field" -- 1264
										} -- 1264
									end -- 1262
								end -- 1262
								goto _continue_2 -- 1265
							elseif "Font" == searchType then -- 1266
								do -- 1267
									local _exp_0 = Path:getExt(f) -- 1267
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1267
										if "." == f:sub(1, 1) then -- 1268
											goto _continue_2 -- 1268
										end -- 1268
										suggestions[#suggestions + 1] = { -- 1269
											f, -- 1269
											"font", -- 1269
											"field" -- 1269
										} -- 1269
									end -- 1267
								end -- 1267
								goto _continue_2 -- 1270
							end -- 1261
							local _exp_0 = Path:getExt(f) -- 1271
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1271
								local name = Path:getName(f) -- 1272
								if "d" == Path:getExt(name) then -- 1273
									goto _continue_2 -- 1273
								end -- 1273
								if "." == name:sub(1, 1) then -- 1274
									goto _continue_2 -- 1274
								end -- 1274
								suggestions[#suggestions + 1] = { -- 1275
									name, -- 1275
									"module", -- 1275
									"field" -- 1275
								} -- 1275
							end -- 1271
							::_continue_2:: -- 1261
						end -- 1260
						local _list_2 = Content:getDirs(sPath) -- 1276
						for _index_1 = 1, #_list_2 do -- 1276
							local dir = _list_2[_index_1] -- 1276
							if "." == dir:sub(1, 1) then -- 1277
								goto _continue_3 -- 1277
							end -- 1277
							suggestions[#suggestions + 1] = { -- 1278
								dir, -- 1278
								"folder", -- 1278
								"variable" -- 1278
							} -- 1278
							::_continue_3:: -- 1277
						end -- 1276
						::_continue_0:: -- 1251
					end -- 1250
					if item == "" and not searchType then -- 1279
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1280
						for _index_0 = 1, #_list_1 do -- 1280
							local _des_0 = _list_1[_index_0] -- 1280
							local name = _des_0[1] -- 1280
							suggestions[#suggestions + 1] = { -- 1281
								name, -- 1281
								"dora module", -- 1281
								"function" -- 1281
							} -- 1281
						end -- 1280
					end -- 1279
					if #suggestions > 0 then -- 1282
						do -- 1283
							local _accum_0 = { } -- 1283
							local _len_0 = 1 -- 1283
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1283
								_accum_0[_len_0] = v -- 1283
								_len_0 = _len_0 + 1 -- 1283
							end -- 1283
							suggestions = _accum_0 -- 1283
						end -- 1283
						return { -- 1284
							success = true, -- 1284
							suggestions = suggestions -- 1284
						} -- 1284
					else -- 1286
						return { -- 1286
							success = false -- 1286
						} -- 1286
					end -- 1282
				until true -- 1227
				if "tl" == lang or "lua" == lang then -- 1288
					do -- 1289
						local isTIC80 = CheckTIC80Code(content) -- 1289
						if isTIC80 then -- 1289
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1290
						end -- 1289
					end -- 1289
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1291
					if not line:match("[%.:]$") then -- 1292
						local checkSet -- 1293
						do -- 1293
							local _tbl_0 = { } -- 1293
							for _index_0 = 1, #suggestions do -- 1293
								local _des_0 = suggestions[_index_0] -- 1293
								local name = _des_0[1] -- 1293
								_tbl_0[name] = true -- 1293
							end -- 1293
							checkSet = _tbl_0 -- 1293
						end -- 1293
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1294
						for _index_0 = 1, #_list_0 do -- 1294
							local item = _list_0[_index_0] -- 1294
							if not checkSet[item[1]] then -- 1295
								suggestions[#suggestions + 1] = item -- 1295
							end -- 1295
						end -- 1294
						for _index_0 = 1, #luaKeywords do -- 1296
							local word = luaKeywords[_index_0] -- 1296
							suggestions[#suggestions + 1] = { -- 1297
								word, -- 1297
								"keyword", -- 1297
								"keyword" -- 1297
							} -- 1297
						end -- 1296
						if lang == "tl" then -- 1298
							for _index_0 = 1, #tealKeywords do -- 1299
								local word = tealKeywords[_index_0] -- 1299
								suggestions[#suggestions + 1] = { -- 1300
									word, -- 1300
									"keyword", -- 1300
									"keyword" -- 1300
								} -- 1300
							end -- 1299
						end -- 1298
					end -- 1292
					if #suggestions > 0 then -- 1301
						return { -- 1302
							success = true, -- 1302
							suggestions = suggestions -- 1302
						} -- 1302
					end -- 1301
				elseif "yue" == lang then -- 1303
					local suggestions = { } -- 1304
					local gotGlobals = false -- 1305
					do -- 1306
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1306
						if luaCodes then -- 1306
							gotGlobals = true -- 1307
							do -- 1308
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1308
								if chainOp then -- 1308
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1309
									if not withVar then -- 1310
										return { -- 1310
											success = false -- 1310
										} -- 1310
									end -- 1310
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1311
								elseif line:match("^([%.\\])$") then -- 1312
									return { -- 1313
										success = false -- 1313
									} -- 1313
								end -- 1308
							end -- 1308
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1314
							for _index_0 = 1, #_list_0 do -- 1314
								local item = _list_0[_index_0] -- 1314
								suggestions[#suggestions + 1] = item -- 1314
							end -- 1314
							if #suggestions == 0 then -- 1315
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1316
								for _index_0 = 1, #_list_1 do -- 1316
									local item = _list_1[_index_0] -- 1316
									suggestions[#suggestions + 1] = item -- 1316
								end -- 1316
							end -- 1315
						end -- 1306
					end -- 1306
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1317
						local checkSet -- 1318
						do -- 1318
							local _tbl_0 = { } -- 1318
							for _index_0 = 1, #suggestions do -- 1318
								local _des_0 = suggestions[_index_0] -- 1318
								local name = _des_0[1] -- 1318
								_tbl_0[name] = true -- 1318
							end -- 1318
							checkSet = _tbl_0 -- 1318
						end -- 1318
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1319
						for _index_0 = 1, #_list_0 do -- 1319
							local item = _list_0[_index_0] -- 1319
							if not checkSet[item[1]] then -- 1320
								suggestions[#suggestions + 1] = item -- 1320
							end -- 1320
						end -- 1319
						if not gotGlobals then -- 1321
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1322
							for _index_0 = 1, #_list_1 do -- 1322
								local item = _list_1[_index_0] -- 1322
								if not checkSet[item[1]] then -- 1323
									suggestions[#suggestions + 1] = item -- 1323
								end -- 1323
							end -- 1322
						end -- 1321
						for _index_0 = 1, #yueKeywords do -- 1324
							local word = yueKeywords[_index_0] -- 1324
							if not checkSet[word] then -- 1325
								suggestions[#suggestions + 1] = { -- 1326
									word, -- 1326
									"keyword", -- 1326
									"keyword" -- 1326
								} -- 1326
							end -- 1325
						end -- 1324
					end -- 1317
					if #suggestions > 0 then -- 1327
						return { -- 1328
							success = true, -- 1328
							suggestions = suggestions -- 1328
						} -- 1328
					end -- 1327
				elseif "xml" == lang then -- 1329
					local items = xml.complete(content) -- 1330
					if #items > 0 then -- 1331
						local suggestions -- 1332
						do -- 1332
							local _accum_0 = { } -- 1332
							local _len_0 = 1 -- 1332
							for _index_0 = 1, #items do -- 1332
								local _des_0 = items[_index_0] -- 1332
								local label, insertText = _des_0[1], _des_0[2] -- 1332
								_accum_0[_len_0] = { -- 1333
									label, -- 1333
									insertText, -- 1333
									"field" -- 1333
								} -- 1333
								_len_0 = _len_0 + 1 -- 1333
							end -- 1332
							suggestions = _accum_0 -- 1332
						end -- 1332
						return { -- 1334
							success = true, -- 1334
							suggestions = suggestions -- 1334
						} -- 1334
					end -- 1331
				end -- 1288
			end -- 1225
		end -- 1225
	end -- 1225
	return { -- 1224
		success = false -- 1224
	} -- 1224
end) -- 1224
HttpServer:upload("/upload", function(req, filename) -- 1338
	do -- 1339
		local _type_0 = type(req) -- 1339
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1339
		if _tab_0 then -- 1339
			local path -- 1339
			do -- 1339
				local _obj_0 = req.params -- 1339
				local _type_1 = type(_obj_0) -- 1339
				if "table" == _type_1 or "userdata" == _type_1 then -- 1339
					path = _obj_0.path -- 1339
				end -- 1339
			end -- 1339
			if path ~= nil then -- 1339
				local uploadPath = Path(Content.writablePath, ".upload") -- 1340
				if not Content:exist(uploadPath) then -- 1341
					Content:mkdir(uploadPath) -- 1342
				end -- 1341
				local targetPath = Path(uploadPath, filename) -- 1343
				Content:mkdir(Path:getPath(targetPath)) -- 1344
				return targetPath -- 1345
			end -- 1339
		end -- 1339
	end -- 1339
	return nil -- 1338
end, function(req, file) -- 1346
	do -- 1347
		local _type_0 = type(req) -- 1347
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1347
		if _tab_0 then -- 1347
			local path -- 1347
			do -- 1347
				local _obj_0 = req.params -- 1347
				local _type_1 = type(_obj_0) -- 1347
				if "table" == _type_1 or "userdata" == _type_1 then -- 1347
					path = _obj_0.path -- 1347
				end -- 1347
			end -- 1347
			if path ~= nil then -- 1347
				path = Path(Content.writablePath, path) -- 1348
				if Content:exist(path) then -- 1349
					local uploadPath = Path(Content.writablePath, ".upload") -- 1350
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1351
					Content:mkdir(Path:getPath(targetPath)) -- 1352
					if Content:move(file, targetPath) then -- 1353
						return true -- 1354
					end -- 1353
				end -- 1349
			end -- 1347
		end -- 1347
	end -- 1347
	return false -- 1346
end) -- 1336
HttpServer:post("/list", function(req) -- 1357
	do -- 1358
		local _type_0 = type(req) -- 1358
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1358
		if _tab_0 then -- 1358
			local path -- 1358
			do -- 1358
				local _obj_0 = req.body -- 1358
				local _type_1 = type(_obj_0) -- 1358
				if "table" == _type_1 or "userdata" == _type_1 then -- 1358
					path = _obj_0.path -- 1358
				end -- 1358
			end -- 1358
			if path ~= nil then -- 1358
				if Content:exist(path) then -- 1359
					local files = { } -- 1360
					local visitAssets -- 1361
					visitAssets = function(path, folder) -- 1361
						local dirs = Content:getDirs(path) -- 1362
						for _index_0 = 1, #dirs do -- 1363
							local dir = dirs[_index_0] -- 1363
							if dir:match("^%.") then -- 1364
								goto _continue_0 -- 1364
							end -- 1364
							local current -- 1365
							if folder == "" then -- 1365
								current = dir -- 1366
							else -- 1368
								current = Path(folder, dir) -- 1368
							end -- 1365
							files[#files + 1] = current -- 1369
							visitAssets(Path(path, dir), current) -- 1370
							::_continue_0:: -- 1364
						end -- 1363
						local fs = Content:getFiles(path) -- 1371
						for _index_0 = 1, #fs do -- 1372
							local f = fs[_index_0] -- 1372
							if (".DS_Store" == f) then -- 1373
								goto _continue_1 -- 1374
							end -- 1373
							if folder == "" then -- 1375
								files[#files + 1] = f -- 1376
							else -- 1378
								files[#files + 1] = Path(folder, f) -- 1378
							end -- 1375
							::_continue_1:: -- 1373
						end -- 1372
					end -- 1361
					visitAssets(path, "") -- 1379
					if #files == 0 then -- 1380
						files = nil -- 1380
					end -- 1380
					return { -- 1381
						success = true, -- 1381
						files = files -- 1381
					} -- 1381
				end -- 1359
			end -- 1358
		end -- 1358
	end -- 1358
	return { -- 1357
		success = false -- 1357
	} -- 1357
end) -- 1357
HttpServer:post("/info", function() -- 1383
	local Entry = require("Script.Dev.Entry") -- 1384
	local webProfiler, drawerWidth -- 1385
	do -- 1385
		local _obj_0 = Entry.getConfig() -- 1385
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 1385
	end -- 1385
	local engineDev = Entry.getEngineDev() -- 1386
	Entry.connectWebIDE() -- 1387
	return { -- 1389
		platform = App.platform, -- 1389
		locale = App.locale, -- 1390
		version = App.version, -- 1391
		engineDev = engineDev, -- 1392
		webProfiler = webProfiler, -- 1393
		drawerWidth = drawerWidth -- 1394
	} -- 1388
end) -- 1383
local ensureLLMConfigTable -- 1396
ensureLLMConfigTable = function() -- 1396
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1397
	if columns and #columns > 0 then -- 1398
		local expected = { -- 1400
			id = true, -- 1400
			name = true, -- 1401
			url = true, -- 1402
			model = true, -- 1403
			api_key = true, -- 1404
			context_window = true, -- 1405
			temperature = true, -- 1406
			max_tokens = true, -- 1407
			reasoning_effort = true, -- 1408
			custom_options = true, -- 1409
			supports_function_calling = true, -- 1410
			active = true, -- 1411
			created_at = true, -- 1412
			updated_at = true -- 1413
		} -- 1399
		local existing = { } -- 1415
		local valid = true -- 1416
		for _index_0 = 1, #columns do -- 1417
			local row = columns[_index_0] -- 1417
			local columnName = tostring(row[2]) -- 1418
			existing[columnName] = true -- 1419
			if not expected[columnName] then -- 1420
				valid = false -- 1421
				break -- 1422
			end -- 1420
		end -- 1417
		if valid then -- 1423
			if not existing.context_window then -- 1424
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1425
			end -- 1424
			if not existing.temperature then -- 1426
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1427
			end -- 1426
			if not existing.max_tokens then -- 1428
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 1429
			end -- 1428
			if not existing.reasoning_effort then -- 1430
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1431
			end -- 1430
			if not existing.custom_options then -- 1432
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1433
			end -- 1432
			if not existing.supports_function_calling then -- 1434
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1435
			end -- 1434
		else -- 1437
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1437
		end -- 1423
	end -- 1398
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
	]]) -- 1438
end -- 1396
local normalizeContextWindow -- 1457
normalizeContextWindow = function(value) -- 1457
	local contextWindow = tonumber(value) -- 1458
	if contextWindow == nil or contextWindow < 64000 then -- 1459
		return 64000 -- 1460
	end -- 1459
	return math.max(64000, math.floor(contextWindow)) -- 1461
end -- 1457
local normalizeTemperature -- 1463
normalizeTemperature = function(value) -- 1463
	local temperature = tonumber(value) -- 1464
	if temperature == nil then -- 1465
		return 0.1 -- 1466
	end -- 1465
	return math.max(0, math.min(2, temperature)) -- 1467
end -- 1463
local normalizeMaxTokens -- 1469
normalizeMaxTokens = function(value) -- 1469
	local maxTokens = tonumber(value) -- 1470
	if maxTokens == nil or maxTokens < 1 then -- 1471
		return 8192 -- 1472
	end -- 1471
	return math.max(1, math.floor(maxTokens)) -- 1473
end -- 1469
local normalizeReasoningEffort -- 1475
normalizeReasoningEffort = function(value) -- 1475
	if value == nil then -- 1476
		return "" -- 1477
	end -- 1476
	local effort = tostring(value) -- 1478
	return effort:match("^%s*(.-)%s*$") or "" -- 1479
end -- 1475
local normalizeCustomOptions -- 1481
normalizeCustomOptions = function(value) -- 1481
	if value == nil then -- 1482
		return "" -- 1483
	end -- 1482
	local options = tostring(value) -- 1484
	options = options:match("^%s*(.-)%s*$") or "" -- 1485
	return options -- 1486
end -- 1481
local validateCustomOptions -- 1488
validateCustomOptions = function(value) -- 1488
	local options = normalizeCustomOptions(value) -- 1489
	if options == "" then -- 1490
		return true -- 1490
	end -- 1490
	if not options:match("^%s*{") then -- 1491
		return false -- 1491
	end -- 1491
	local decoded = json.decode(options) -- 1492
	return type(decoded) == "table" -- 1493
end -- 1488
HttpServer:post("/llm/list", function() -- 1495
	ensureLLMConfigTable() -- 1496
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active\n		from LLMConfig\n		order by id asc") -- 1497
	local items -- 1501
	if rows and #rows > 0 then -- 1501
		local _accum_0 = { } -- 1502
		local _len_0 = 1 -- 1502
		for _index_0 = 1, #rows do -- 1502
			local _des_0 = rows[_index_0] -- 1502
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11], _des_0[12] -- 1502
			_accum_0[_len_0] = { -- 1503
				id = id, -- 1503
				name = name, -- 1503
				url = url, -- 1503
				model = model, -- 1503
				key = key, -- 1503
				contextWindow = normalizeContextWindow(contextWindow), -- 1503
				temperature = normalizeTemperature(temperature), -- 1503
				maxTokens = normalizeMaxTokens(maxTokens), -- 1503
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1503
				customOptions = normalizeCustomOptions(customOptions), -- 1503
				supportsFunctionCalling = supportsFunctionCalling ~= 0, -- 1503
				active = active ~= 0 -- 1503
			} -- 1503
			_len_0 = _len_0 + 1 -- 1503
		end -- 1502
		items = _accum_0 -- 1501
	end -- 1501
	return { -- 1504
		success = true, -- 1504
		items = items -- 1504
	} -- 1504
end) -- 1495
HttpServer:post("/llm/create", function(req) -- 1506
	ensureLLMConfigTable() -- 1507
	do -- 1508
		local _type_0 = type(req) -- 1508
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1508
		if _tab_0 then -- 1508
			local body = req.body -- 1508
			if body ~= nil then -- 1508
				local name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1509
				local now = os.time() -- 1510
				if name == nil or url == nil or model == nil or key == nil then -- 1511
					return invalidArguments -- 1512
				end -- 1511
				contextWindow = normalizeContextWindow(contextWindow) -- 1513
				temperature = normalizeTemperature(temperature) -- 1514
				maxTokens = normalizeMaxTokens(maxTokens) -- 1515
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1516
				customOptions = normalizeCustomOptions(customOptions) -- 1517
				if not validateCustomOptions(customOptions) then -- 1518
					return { -- 1518
						success = false, -- 1518
						message = "customOptions must be a JSON object" -- 1518
					} -- 1518
				end -- 1518
				if supportsFunctionCalling == false then -- 1519
					supportsFunctionCalling = 0 -- 1519
				else -- 1519
					supportsFunctionCalling = 1 -- 1519
				end -- 1519
				if active then -- 1520
					active = 1 -- 1520
				else -- 1520
					active = 0 -- 1520
				end -- 1520
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1527
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
					now -- 1539
				}) -- 1521
				return { -- 1541
					success = affected >= 0 -- 1541
				} -- 1541
			end -- 1508
		end -- 1508
	end -- 1508
	return invalidArguments -- 1506
end) -- 1506
HttpServer:post("/llm/update", function(req) -- 1543
	ensureLLMConfigTable() -- 1544
	do -- 1545
		local _type_0 = type(req) -- 1545
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1545
		if _tab_0 then -- 1545
			local body = req.body -- 1545
			if body ~= nil then -- 1545
				local id, name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1546
				local now = os.time() -- 1547
				id = tonumber(id) -- 1548
				if id == nil then -- 1549
					return invalidArguments -- 1549
				end -- 1549
				contextWindow = normalizeContextWindow(contextWindow) -- 1550
				temperature = normalizeTemperature(temperature) -- 1551
				maxTokens = normalizeMaxTokens(maxTokens) -- 1552
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1553
				customOptions = normalizeCustomOptions(customOptions) -- 1554
				if not validateCustomOptions(customOptions) then -- 1555
					return { -- 1555
						success = false, -- 1555
						message = "customOptions must be a JSON object" -- 1555
					} -- 1555
				end -- 1555
				if supportsFunctionCalling == false then -- 1556
					supportsFunctionCalling = 0 -- 1556
				else -- 1556
					supportsFunctionCalling = 1 -- 1556
				end -- 1556
				if active then -- 1557
					active = 1 -- 1557
				else -- 1557
					active = 0 -- 1557
				end -- 1557
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, active = ?, updated_at = ?\n			where id = ?", { -- 1562
					tostring(name), -- 1562
					tostring(url), -- 1563
					tostring(model), -- 1564
					tostring(key), -- 1565
					contextWindow, -- 1566
					temperature, -- 1567
					maxTokens, -- 1568
					reasoningEffort, -- 1569
					customOptions, -- 1570
					supportsFunctionCalling, -- 1571
					active, -- 1572
					now, -- 1573
					id -- 1574
				}) -- 1558
				return { -- 1576
					success = affected >= 0 -- 1576
				} -- 1576
			end -- 1545
		end -- 1545
	end -- 1545
	return invalidArguments -- 1543
end) -- 1543
HttpServer:post("/llm/delete", function(req) -- 1578
	ensureLLMConfigTable() -- 1579
	do -- 1580
		local _type_0 = type(req) -- 1580
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1580
		if _tab_0 then -- 1580
			local id -- 1580
			do -- 1580
				local _obj_0 = req.body -- 1580
				local _type_1 = type(_obj_0) -- 1580
				if "table" == _type_1 or "userdata" == _type_1 then -- 1580
					id = _obj_0.id -- 1580
				end -- 1580
			end -- 1580
			if id ~= nil then -- 1580
				id = tonumber(id) -- 1581
				if id == nil then -- 1582
					return invalidArguments -- 1582
				end -- 1582
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1583
					id -- 1583
				}) -- 1583
				return { -- 1584
					success = affected >= 0 -- 1584
				} -- 1584
			end -- 1580
		end -- 1580
	end -- 1580
	return invalidArguments -- 1578
end) -- 1578
HttpServer:post("/stat", function(req) -- 1586
	do -- 1587
		local _type_0 = type(req) -- 1587
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1587
		if _tab_0 then -- 1587
			local path -- 1587
			do -- 1587
				local _obj_0 = req.body -- 1587
				local _type_1 = type(_obj_0) -- 1587
				if "table" == _type_1 or "userdata" == _type_1 then -- 1587
					path = _obj_0.path -- 1587
				end -- 1587
			end -- 1587
			if path ~= nil then -- 1587
				if not Content:exist(path) then -- 1588
					return { -- 1589
						success = false, -- 1589
						message = "target not existed" -- 1589
					} -- 1589
				end -- 1588
				if Content:isdir(path) then -- 1590
					return { -- 1591
						success = false, -- 1591
						message = "failed to stat a directory" -- 1591
					} -- 1591
				end -- 1590
				local size, isBinary = Content:getAttr(path) -- 1592
				if size then -- 1592
					return { -- 1593
						success = true, -- 1593
						size = size, -- 1593
						isBinary = isBinary -- 1593
					} -- 1593
				end -- 1592
			end -- 1587
		end -- 1587
	end -- 1587
	return { -- 1586
		success = false, -- 1586
		message = "failed to stat" -- 1586
	} -- 1586
end) -- 1586
HttpServer:post("/new", function(req) -- 1595
	do -- 1596
		local _type_0 = type(req) -- 1596
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1596
		if _tab_0 then -- 1596
			local path -- 1596
			do -- 1596
				local _obj_0 = req.body -- 1596
				local _type_1 = type(_obj_0) -- 1596
				if "table" == _type_1 or "userdata" == _type_1 then -- 1596
					path = _obj_0.path -- 1596
				end -- 1596
			end -- 1596
			local content -- 1596
			do -- 1596
				local _obj_0 = req.body -- 1596
				local _type_1 = type(_obj_0) -- 1596
				if "table" == _type_1 or "userdata" == _type_1 then -- 1596
					content = _obj_0.content -- 1596
				end -- 1596
			end -- 1596
			local folder -- 1596
			do -- 1596
				local _obj_0 = req.body -- 1596
				local _type_1 = type(_obj_0) -- 1596
				if "table" == _type_1 or "userdata" == _type_1 then -- 1596
					folder = _obj_0.folder -- 1596
				end -- 1596
			end -- 1596
			if path ~= nil and content ~= nil and folder ~= nil then -- 1596
				if Content:exist(path) then -- 1597
					return { -- 1598
						success = false, -- 1598
						message = "TargetExisted" -- 1598
					} -- 1598
				end -- 1597
				local parent = Path:getPath(path) -- 1599
				local files = Content:getFiles(parent) -- 1600
				if folder then -- 1601
					local name = Path:getFilename(path):lower() -- 1602
					for _index_0 = 1, #files do -- 1603
						local file = files[_index_0] -- 1603
						if name == Path:getFilename(file):lower() then -- 1604
							return { -- 1605
								success = false, -- 1605
								message = "TargetExisted" -- 1605
							} -- 1605
						end -- 1604
					end -- 1603
					if Content:mkdir(path) then -- 1606
						return { -- 1607
							success = true -- 1607
						} -- 1607
					end -- 1606
				else -- 1609
					local name = Path:getName(path):lower() -- 1609
					for _index_0 = 1, #files do -- 1610
						local file = files[_index_0] -- 1610
						if name == Path:getName(file):lower() then -- 1611
							local ext = Path:getExt(file) -- 1612
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1613
								goto _continue_0 -- 1614
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1615
								goto _continue_0 -- 1616
							end -- 1613
							return { -- 1617
								success = false, -- 1617
								message = "SourceExisted" -- 1617
							} -- 1617
						end -- 1611
						::_continue_0:: -- 1611
					end -- 1610
					if Content:save(path, content) then -- 1618
						return { -- 1619
							success = true -- 1619
						} -- 1619
					end -- 1618
				end -- 1601
			end -- 1596
		end -- 1596
	end -- 1596
	return { -- 1595
		success = false, -- 1595
		message = "Failed" -- 1595
	} -- 1595
end) -- 1595
HttpServer:post("/delete", function(req) -- 1621
	do -- 1622
		local _type_0 = type(req) -- 1622
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1622
		if _tab_0 then -- 1622
			local path -- 1622
			do -- 1622
				local _obj_0 = req.body -- 1622
				local _type_1 = type(_obj_0) -- 1622
				if "table" == _type_1 or "userdata" == _type_1 then -- 1622
					path = _obj_0.path -- 1622
				end -- 1622
			end -- 1622
			if path ~= nil then -- 1622
				if Content:exist(path) then -- 1623
					local projectRoot -- 1624
					if Content:isdir(path) and isProjectRootDir(path) then -- 1624
						projectRoot = path -- 1624
					else -- 1624
						projectRoot = nil -- 1624
					end -- 1624
					local parent = Path:getPath(path) -- 1625
					local files = Content:getFiles(parent) -- 1626
					local name = Path:getName(path):lower() -- 1627
					local ext = Path:getExt(path) -- 1628
					for _index_0 = 1, #files do -- 1629
						local file = files[_index_0] -- 1629
						if name == Path:getName(file):lower() then -- 1630
							local _exp_0 = Path:getExt(file) -- 1631
							if "tl" == _exp_0 then -- 1631
								if ("vs" == ext) then -- 1631
									Content:remove(Path(parent, file)) -- 1632
								end -- 1631
							elseif "lua" == _exp_0 then -- 1633
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1633
									Content:remove(Path(parent, file)) -- 1634
								end -- 1633
							end -- 1631
						end -- 1630
					end -- 1629
					if Content:remove(path) then -- 1635
						if projectRoot then -- 1636
							AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1637
						end -- 1636
						return { -- 1638
							success = true -- 1638
						} -- 1638
					end -- 1635
				end -- 1623
			end -- 1622
		end -- 1622
	end -- 1622
	return { -- 1621
		success = false -- 1621
	} -- 1621
end) -- 1621
HttpServer:post("/rename", function(req) -- 1640
	do -- 1641
		local _type_0 = type(req) -- 1641
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1641
		if _tab_0 then -- 1641
			local old -- 1641
			do -- 1641
				local _obj_0 = req.body -- 1641
				local _type_1 = type(_obj_0) -- 1641
				if "table" == _type_1 or "userdata" == _type_1 then -- 1641
					old = _obj_0.old -- 1641
				end -- 1641
			end -- 1641
			local new -- 1641
			do -- 1641
				local _obj_0 = req.body -- 1641
				local _type_1 = type(_obj_0) -- 1641
				if "table" == _type_1 or "userdata" == _type_1 then -- 1641
					new = _obj_0.new -- 1641
				end -- 1641
			end -- 1641
			if old ~= nil and new ~= nil then -- 1641
				if Content:exist(old) and not Content:exist(new) then -- 1642
					local renamedDir = Content:isdir(old) -- 1643
					local parent = Path:getPath(new) -- 1644
					local files = Content:getFiles(parent) -- 1645
					if renamedDir then -- 1646
						local name = Path:getFilename(new):lower() -- 1647
						for _index_0 = 1, #files do -- 1648
							local file = files[_index_0] -- 1648
							if name == Path:getFilename(file):lower() then -- 1649
								return { -- 1650
									success = false -- 1650
								} -- 1650
							end -- 1649
						end -- 1648
					else -- 1652
						local name = Path:getName(new):lower() -- 1652
						local ext = Path:getExt(new) -- 1653
						for _index_0 = 1, #files do -- 1654
							local file = files[_index_0] -- 1654
							if name == Path:getName(file):lower() then -- 1655
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1656
									goto _continue_0 -- 1657
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1658
									goto _continue_0 -- 1659
								end -- 1656
								return { -- 1660
									success = false -- 1660
								} -- 1660
							end -- 1655
							::_continue_0:: -- 1655
						end -- 1654
					end -- 1646
					if Content:move(old, new) then -- 1661
						if renamedDir then -- 1662
							AgentSession.renameSessionsByProjectRoot(old, new) -- 1663
						end -- 1662
						local newParent = Path:getPath(new) -- 1664
						parent = Path:getPath(old) -- 1665
						files = Content:getFiles(parent) -- 1666
						local newName = Path:getName(new) -- 1667
						local oldName = Path:getName(old) -- 1668
						local name = oldName:lower() -- 1669
						local ext = Path:getExt(old) -- 1670
						for _index_0 = 1, #files do -- 1671
							local file = files[_index_0] -- 1671
							if name == Path:getName(file):lower() then -- 1672
								local _exp_0 = Path:getExt(file) -- 1673
								if "tl" == _exp_0 then -- 1673
									if ("vs" == ext) then -- 1673
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1674
									end -- 1673
								elseif "lua" == _exp_0 then -- 1675
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1675
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1676
									end -- 1675
								end -- 1673
							end -- 1672
						end -- 1671
						return { -- 1677
							success = true -- 1677
						} -- 1677
					end -- 1661
				end -- 1642
			end -- 1641
		end -- 1641
	end -- 1641
	return { -- 1640
		success = false -- 1640
	} -- 1640
end) -- 1640
local withProjectSearchPaths -- 1679
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1679
	local fallbackPaths = { } -- 1680
	local addFallback -- 1681
	addFallback = function(dir) -- 1681
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1681
			fallbackPaths[#fallbackPaths + 1] = dir -- 1681
		end -- 1681
	end -- 1681
	if projectRoot and projectRoot ~= "" then -- 1682
		addFallback(Path(projectRoot, "Script")) -- 1683
		addFallback(projectRoot) -- 1684
	end -- 1682
	if projFile then -- 1685
		local projDir = getProjectDirFromFile(projFile) -- 1686
		if projDir then -- 1686
			addFallback(Path(projDir, "Script")) -- 1687
			addFallback(projDir) -- 1688
		else -- 1690
			addFallback(Path:getPath(projFile)) -- 1690
		end -- 1686
	end -- 1685
	if not (#fallbackPaths > 0) then -- 1691
		return fn() -- 1691
	end -- 1691
	local searchPaths = Content.searchPaths -- 1692
	for _index_0 = 1, #fallbackPaths do -- 1693
		local dir = fallbackPaths[_index_0] -- 1693
		Content:addSearchPath(dir) -- 1693
	end -- 1693
	local _ <close> = setmetatable({ }, { -- 1694
		__close = function() -- 1694
			Content.searchPaths = searchPaths -- 1694
		end -- 1694
	}) -- 1694
	return fn() -- 1695
end -- 1679
HttpServer:post("/exist", function(req) -- 1696
	do -- 1697
		local _type_0 = type(req) -- 1697
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1697
		if _tab_0 then -- 1697
			local file -- 1697
			do -- 1697
				local _obj_0 = req.body -- 1697
				local _type_1 = type(_obj_0) -- 1697
				if "table" == _type_1 or "userdata" == _type_1 then -- 1697
					file = _obj_0.file -- 1697
				end -- 1697
			end -- 1697
			if file ~= nil then -- 1697
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1698
					return { -- 1699
						success = Content:exist(file) -- 1699
					} -- 1699
				end) -- 1698
			end -- 1697
		end -- 1697
	end -- 1697
	return { -- 1696
		success = false -- 1696
	} -- 1696
end) -- 1696
HttpServer:postSchedule("/read", function(req) -- 1700
	do -- 1701
		local _type_0 = type(req) -- 1701
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1701
		if _tab_0 then -- 1701
			local path -- 1701
			do -- 1701
				local _obj_0 = req.body -- 1701
				local _type_1 = type(_obj_0) -- 1701
				if "table" == _type_1 or "userdata" == _type_1 then -- 1701
					path = _obj_0.path -- 1701
				end -- 1701
			end -- 1701
			if path ~= nil then -- 1701
				local readFile -- 1702
				readFile = function() -- 1702
					if Content:exist(path) then -- 1703
						local content = Content:loadAsync(path) -- 1704
						if content then -- 1704
							return { -- 1705
								content = content, -- 1705
								success = true, -- 1705
								fullPath = Content:getFullPath(path) -- 1705
							} -- 1705
						end -- 1704
					end -- 1703
					return nil -- 1702
				end -- 1702
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1706
				if result then -- 1706
					return result -- 1706
				end -- 1706
			end -- 1701
		end -- 1701
	end -- 1701
	return { -- 1700
		success = false -- 1700
	} -- 1700
end) -- 1700
local agentDocLanguage -- 1708
agentDocLanguage = function(language) -- 1708
	if language == "zh-Hans" then -- 1709
		return "zh" -- 1709
	else -- 1709
		return "en" -- 1709
	end -- 1709
end -- 1708
HttpServer:postSchedule("/doc/search", function(req) -- 1711
	local body = req.body or { } -- 1712
	local language = body.docLanguage -- 1713
	if not (("en" == language or "zh-Hans" == language)) then -- 1714
		return { -- 1714
			success = false, -- 1714
			message = "unsupported doc language" -- 1714
		} -- 1714
	end -- 1714
	local source = body.docSource -- 1715
	if not (("api" == source or "tutorial" == source)) then -- 1716
		return { -- 1716
			success = false, -- 1716
			message = "unsupported doc source" -- 1716
		} -- 1716
	end -- 1716
	local codeLanguage = body.programmingLanguage -- 1717
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1718
		return { -- 1718
			success = false, -- 1718
			message = "unsupported programming language" -- 1718
		} -- 1718
	end -- 1718
	if not body.pattern then -- 1719
		return { -- 1719
			success = false, -- 1719
			message = "missing pattern" -- 1719
		} -- 1719
	end -- 1719
	local result = nil -- 1720
	AgentTools.searchDoraAPIHttp({ -- 1722
		pattern = body.pattern, -- 1722
		docLanguage = agentDocLanguage(language), -- 1723
		docSource = source, -- 1724
		programmingLanguage = codeLanguage, -- 1725
		limit = body.limit, -- 1726
		useRegex = body.useRegex, -- 1727
		caseSensitive = body.caseSensitive, -- 1728
		includeContent = body.includeContent, -- 1729
		contentWindow = body.contentWindow -- 1730
	}, function(res) -- 1731
		result = res -- 1732
	end) -- 1721
	wait(function() -- 1733
		return result ~= nil -- 1733
	end) -- 1733
	if result and result.success then -- 1734
		result.docLanguage = language -- 1735
	end -- 1734
	if result then -- 1736
		return result -- 1737
	else -- 1739
		return { -- 1739
			success = false, -- 1739
			message = "doc search failed" -- 1739
		} -- 1739
	end -- 1736
	return { -- 1711
		success = false, -- 1711
		message = "invalid call" -- 1711
	} -- 1711
end) -- 1711
HttpServer:postSchedule("/doc/read", function(req) -- 1741
	local body = req.body or { } -- 1742
	local language = body.docLanguage -- 1743
	if not (("en" == language or "zh-Hans" == language)) then -- 1744
		return { -- 1744
			success = false, -- 1744
			message = "unsupported doc language" -- 1744
		} -- 1744
	end -- 1744
	if not body.file then -- 1745
		return { -- 1745
			success = false, -- 1745
			message = "missing file" -- 1745
		} -- 1745
	end -- 1745
	local result = AgentTools.readDoraDoc({ -- 1747
		docLanguage = agentDocLanguage(language), -- 1747
		file = body.file, -- 1748
		startLine = body.startLine, -- 1749
		endLine = body.endLine -- 1750
	}) -- 1746
	if result and result.success then -- 1751
		result.docLanguage = language -- 1752
	end -- 1751
	return result -- 1753
end) -- 1741
HttpServer:get("/read-sync", function(req) -- 1755
	do -- 1756
		local _type_0 = type(req) -- 1756
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1756
		if _tab_0 then -- 1756
			local params = req.params -- 1756
			if params ~= nil then -- 1756
				local path = params.path -- 1757
				local exts -- 1758
				if params.exts then -- 1758
					local _accum_0 = { } -- 1759
					local _len_0 = 1 -- 1759
					for ext in params.exts:gmatch("[^|]*") do -- 1759
						_accum_0[_len_0] = ext -- 1759
						_len_0 = _len_0 + 1 -- 1759
					end -- 1759
					exts = _accum_0 -- 1759
				else -- 1760
					exts = { -- 1760
						"" -- 1760
					} -- 1760
				end -- 1758
				local readFileAt -- 1761
				readFileAt = function(targetPath) -- 1761
					if Content:exist(targetPath) then -- 1762
						local content = Content:load(targetPath) -- 1763
						if content then -- 1763
							return { -- 1764
								content = content, -- 1764
								success = true, -- 1764
								fullPath = Content:getFullPath(targetPath) -- 1764
							} -- 1764
						end -- 1763
					end -- 1762
					return nil -- 1761
				end -- 1761
				local readFile -- 1765
				readFile = function(fallbackPaths) -- 1765
					for _index_0 = 1, #exts do -- 1766
						local ext = exts[_index_0] -- 1766
						local targetPath = path .. ext -- 1767
						if not Content:isAbsolutePath(targetPath) then -- 1768
							for _index_1 = 1, #fallbackPaths do -- 1769
								local fallback = fallbackPaths[_index_1] -- 1769
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1770
								if fallbackResult then -- 1770
									return fallbackResult -- 1771
								end -- 1770
							end -- 1769
						end -- 1768
						local fileResult = readFileAt(targetPath) -- 1772
						if fileResult then -- 1772
							return fileResult -- 1773
						end -- 1772
					end -- 1766
					return nil -- 1765
				end -- 1765
				local fallbackPaths = { } -- 1774
				local fallbackCandidates = { } -- 1775
				do -- 1776
					local projectRoot = req.params.projectRoot -- 1776
					if projectRoot then -- 1776
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1777
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1778
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1779
						end -- 1777
					end -- 1776
				end -- 1776
				do -- 1780
					local projFile = req.params.projFile -- 1780
					if projFile then -- 1780
						local projDir = getProjectDirFromFile(projFile) -- 1781
						if projDir then -- 1781
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1782
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1783
						else -- 1785
							projDir = Path:getPath(projFile) -- 1785
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1786
						end -- 1781
					end -- 1780
				end -- 1780
				for _index_0 = 1, #fallbackCandidates do -- 1787
					local dir = fallbackCandidates[_index_0] -- 1787
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1788
						local exists = false -- 1789
						for _index_1 = 1, #fallbackPaths do -- 1790
							local fallback = fallbackPaths[_index_1] -- 1790
							if fallback == dir then -- 1791
								exists = true -- 1792
								break -- 1793
							end -- 1791
						end -- 1790
						if not exists then -- 1794
							fallbackPaths[#fallbackPaths + 1] = dir -- 1794
						end -- 1794
					end -- 1788
				end -- 1787
				local readResult = readFile(fallbackPaths) -- 1795
				if readResult then -- 1795
					return readResult -- 1796
				end -- 1795
			end -- 1756
		end -- 1756
	end -- 1756
	return { -- 1755
		success = false -- 1755
	} -- 1755
end) -- 1755
local compileFileAsync -- 1798
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1798
	if projectRoot == nil then -- 1798
		projectRoot = nil -- 1798
	end -- 1798
	local file = inputFile -- 1799
	local searchPath -- 1800
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1800
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1801
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1805
	elseif not Content:isAbsolutePath(inputFile) then -- 1806
		searchPath = "" -- 1807
	else -- 1808
		local dir = getProjectDirFromFile(inputFile) -- 1808
		if dir then -- 1808
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1809
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1813
		else -- 1815
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1815
			searchPath = "" -- 1818
		end -- 1808
	end -- 1800
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1819
	local yueext = yue.options.extension -- 1820
	local resultCodes = nil -- 1821
	local resultError = nil -- 1822
	do -- 1823
		local _exp_0 = Path:getExt(inputFile) -- 1823
		if yueext == _exp_0 then -- 1823
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1824
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1825
				if not codes then -- 1826
					resultError = err -- 1827
					return -- 1828
				end -- 1826
				local extraGlobal -- 1829
				if isTIC80 then -- 1829
					extraGlobal = tic80APIs -- 1829
				else -- 1829
					extraGlobal = nil -- 1829
				end -- 1829
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1830
				if not success then -- 1831
					resultError = message -- 1832
					return -- 1833
				end -- 1831
				if codes == "" then -- 1834
					resultCodes = "" -- 1835
					return nil -- 1836
				end -- 1834
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1837
				return resultCodes -- 1838
			end, function(success) -- 1825
				if not success then -- 1839
					Content:remove(outputFile) -- 1840
					if resultCodes == nil then -- 1841
						resultCodes = false -- 1842
					end -- 1841
				end -- 1839
			end) -- 1825
		elseif "tl" == _exp_0 then -- 1843
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1844
			if isTIC80 then -- 1845
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1846
			end -- 1845
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1847
			if codes then -- 1847
				if isTIC80 then -- 1848
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1849
				end -- 1848
				resultCodes = codes -- 1850
				Content:saveAsync(outputFile, codes) -- 1851
			else -- 1853
				Content:remove(outputFile) -- 1853
				resultCodes = false -- 1854
				resultError = err -- 1855
			end -- 1847
		elseif "xml" == _exp_0 then -- 1856
			local codes, err = xml.tolua(sourceCodes) -- 1857
			if codes then -- 1857
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1858
				Content:saveAsync(outputFile, resultCodes) -- 1859
			else -- 1861
				Content:remove(outputFile) -- 1861
				resultCodes = false -- 1862
				resultError = err -- 1863
			end -- 1857
		end -- 1823
	end -- 1823
	wait(function() -- 1864
		return resultCodes ~= nil -- 1864
	end) -- 1864
	if resultCodes then -- 1865
		return resultCodes -- 1866
	else -- 1868
		return nil, resultError -- 1868
	end -- 1865
	return nil -- 1798
end -- 1798
HttpServer:postSchedule("/write", function(req) -- 1870
	do -- 1871
		local _type_0 = type(req) -- 1871
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1871
		if _tab_0 then -- 1871
			local path -- 1871
			do -- 1871
				local _obj_0 = req.body -- 1871
				local _type_1 = type(_obj_0) -- 1871
				if "table" == _type_1 or "userdata" == _type_1 then -- 1871
					path = _obj_0.path -- 1871
				end -- 1871
			end -- 1871
			local content -- 1871
			do -- 1871
				local _obj_0 = req.body -- 1871
				local _type_1 = type(_obj_0) -- 1871
				if "table" == _type_1 or "userdata" == _type_1 then -- 1871
					content = _obj_0.content -- 1871
				end -- 1871
			end -- 1871
			if path ~= nil and content ~= nil then -- 1871
				if Content:saveAsync(path, content) then -- 1872
					do -- 1873
						local _exp_0 = Path:getExt(path) -- 1873
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1873
							if '' == Path:getExt(Path:getName(path)) then -- 1874
								local resultCodes = compileFileAsync(path, content) -- 1875
								return { -- 1876
									success = true, -- 1876
									resultCodes = resultCodes -- 1876
								} -- 1876
							end -- 1874
						end -- 1873
					end -- 1873
					return { -- 1877
						success = true -- 1877
					} -- 1877
				end -- 1872
			end -- 1871
		end -- 1871
	end -- 1871
	return { -- 1870
		success = false -- 1870
	} -- 1870
end) -- 1870
local getWaProjectDirFromFile = nil -- 1879
HttpServer:postSchedule("/build", function(req) -- 1881
	do -- 1882
		local _type_0 = type(req) -- 1882
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1882
		if _tab_0 then -- 1882
			local path -- 1882
			do -- 1882
				local _obj_0 = req.body -- 1882
				local _type_1 = type(_obj_0) -- 1882
				if "table" == _type_1 or "userdata" == _type_1 then -- 1882
					path = _obj_0.path -- 1882
				end -- 1882
			end -- 1882
			if path ~= nil then -- 1882
				local projectRoot = req.body.projectRoot -- 1883
				if Content:isdir(path) then -- 1884
					local projDir = getWaProjectDirFromFile(path) -- 1885
					if projDir then -- 1885
						local message = Wasm:buildWaAsync(projDir) -- 1886
						if message == "" then -- 1887
							return { -- 1888
								success = true -- 1888
							} -- 1888
						else -- 1890
							return { -- 1890
								success = false, -- 1890
								message = message -- 1890
							} -- 1890
						end -- 1887
					end -- 1885
				end -- 1884
				local _exp_0 = Path:getExt(path) -- 1891
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1892
					if '' == Path:getExt(Path:getName(path)) then -- 1893
						local content = Content:loadAsync(path) -- 1894
						if content then -- 1894
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 1895
							if resultCodes then -- 1895
								return { -- 1896
									success = true, -- 1896
									resultCodes = resultCodes -- 1896
								} -- 1896
							end -- 1895
						end -- 1894
					end -- 1893
				elseif "wa" == _exp_0 then -- 1897
					local projDir = getWaProjectDirFromFile(path) -- 1898
					if projDir then -- 1898
						local message = Wasm:buildWaAsync(projDir) -- 1899
						if message == "" then -- 1900
							return { -- 1901
								success = true -- 1901
							} -- 1901
						else -- 1903
							return { -- 1903
								success = false, -- 1903
								message = message -- 1903
							} -- 1903
						end -- 1900
					else -- 1905
						return { -- 1905
							success = false, -- 1905
							message = 'Wa file needs a project' -- 1905
						} -- 1905
					end -- 1898
				end -- 1891
			end -- 1882
		end -- 1882
	end -- 1882
	return { -- 1881
		success = false -- 1881
	} -- 1881
end) -- 1881
local extentionLevels = { -- 1908
	vs = 2, -- 1908
	bl = 2, -- 1909
	ts = 1, -- 1910
	tsx = 1, -- 1911
	tl = 1, -- 1912
	yue = 1, -- 1913
	xml = 1, -- 1914
	lua = 0 -- 1915
} -- 1907
HttpServer:post("/assets", function() -- 1917
	local Entry = require("Script.Dev.Entry") -- 1920
	local engineDev = Entry.getEngineDev() -- 1921
	local visitAssets -- 1922
	visitAssets = function(path, tag) -- 1922
		local isWorkspace = tag == "Workspace" -- 1923
		local builtin -- 1924
		if tag == "Builtin" then -- 1924
			builtin = true -- 1924
		else -- 1924
			builtin = nil -- 1924
		end -- 1924
		local children = nil -- 1925
		local dirs = Content:getDirs(path) -- 1926
		for _index_0 = 1, #dirs do -- 1927
			local dir = dirs[_index_0] -- 1927
			if isWorkspace then -- 1928
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1929
					goto _continue_0 -- 1930
				end -- 1929
			elseif dir == ".git" then -- 1931
				goto _continue_0 -- 1932
			end -- 1928
			if not children then -- 1933
				children = { } -- 1933
			end -- 1933
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1934
			::_continue_0:: -- 1928
		end -- 1927
		local files = Content:getFiles(path) -- 1935
		local names = { } -- 1936
		for _index_0 = 1, #files do -- 1937
			local file = files[_index_0] -- 1937
			if (".DS_Store" == file) then -- 1938
				goto _continue_1 -- 1939
			end -- 1938
			local name = Path:getName(file) -- 1940
			local ext = names[name] -- 1941
			if ext then -- 1941
				local lv1 -- 1942
				do -- 1942
					local _exp_0 = extentionLevels[ext] -- 1942
					if _exp_0 ~= nil then -- 1942
						lv1 = _exp_0 -- 1942
					else -- 1942
						lv1 = -1 -- 1942
					end -- 1942
				end -- 1942
				ext = Path:getExt(file) -- 1943
				local lv2 -- 1944
				do -- 1944
					local _exp_0 = extentionLevels[ext] -- 1944
					if _exp_0 ~= nil then -- 1944
						lv2 = _exp_0 -- 1944
					else -- 1944
						lv2 = -1 -- 1944
					end -- 1944
				end -- 1944
				if lv2 > lv1 then -- 1945
					names[name] = ext -- 1946
				elseif lv2 == lv1 then -- 1947
					names[name .. '.' .. ext] = "" -- 1948
				end -- 1945
			else -- 1950
				ext = Path:getExt(file) -- 1950
				if not extentionLevels[ext] then -- 1951
					names[file] = "" -- 1952
				else -- 1954
					names[name] = ext -- 1954
				end -- 1951
			end -- 1941
			::_continue_1:: -- 1938
		end -- 1937
		do -- 1955
			local _accum_0 = { } -- 1955
			local _len_0 = 1 -- 1955
			for name, ext in pairs(names) do -- 1955
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1955
				_len_0 = _len_0 + 1 -- 1955
			end -- 1955
			files = _accum_0 -- 1955
		end -- 1955
		for _index_0 = 1, #files do -- 1956
			local file = files[_index_0] -- 1956
			if not children then -- 1957
				children = { } -- 1957
			end -- 1957
			children[#children + 1] = { -- 1959
				key = Path(path, file), -- 1959
				dir = false, -- 1960
				title = file, -- 1961
				builtin = builtin -- 1962
			} -- 1958
		end -- 1956
		if children then -- 1964
			table.sort(children, function(a, b) -- 1965
				if a.dir == b.dir then -- 1966
					return a.title < b.title -- 1967
				else -- 1969
					return a.dir -- 1969
				end -- 1966
			end) -- 1965
		end -- 1964
		if isWorkspace and children then -- 1970
			return children -- 1971
		else -- 1973
			return { -- 1974
				key = path, -- 1974
				dir = true, -- 1975
				title = Path:getFilename(path), -- 1976
				builtin = builtin, -- 1977
				children = children -- 1978
			} -- 1973
		end -- 1970
	end -- 1922
	local zh = (App.locale:match("^zh") ~= nil) -- 1980
	return { -- 1982
		key = Content.writablePath, -- 1982
		dir = true, -- 1983
		root = true, -- 1984
		title = "Assets", -- 1985
		children = (function() -- 1987
			local _tab_0 = { -- 1987
				{ -- 1988
					key = Path(Content.assetPath), -- 1988
					dir = true, -- 1989
					builtin = true, -- 1990
					title = zh and "内置资源" or "Built-in", -- 1991
					children = { -- 1993
						(function() -- 1993
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1993
							_with_0.title = zh and "说明文档" or "Readme" -- 1994
							return _with_0 -- 1993
						end)(), -- 1993
						(function() -- 1995
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1995
							_with_0.title = zh and "接口文档" or "API Doc" -- 1996
							return _with_0 -- 1995
						end)(), -- 1995
						(function() -- 1997
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1997
							_with_0.title = zh and "开发工具" or "Tools" -- 1998
							return _with_0 -- 1997
						end)(), -- 1997
						(function() -- 1999
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1999
							_with_0.title = zh and "字体" or "Font" -- 2000
							return _with_0 -- 1999
						end)(), -- 1999
						(function() -- 2001
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 2001
							_with_0.title = zh and "程序库" or "Lib" -- 2002
							if engineDev then -- 2003
								local _list_0 = _with_0.children -- 2004
								for _index_0 = 1, #_list_0 do -- 2004
									local child = _list_0[_index_0] -- 2004
									if not (child.title == "Dora") then -- 2005
										goto _continue_0 -- 2005
									end -- 2005
									local title = zh and "zh-Hans" or "en" -- 2006
									do -- 2007
										local _accum_0 = { } -- 2007
										local _len_0 = 1 -- 2007
										local _list_1 = child.children -- 2007
										for _index_1 = 1, #_list_1 do -- 2007
											local c = _list_1[_index_1] -- 2007
											if c.title ~= title then -- 2007
												_accum_0[_len_0] = c -- 2007
												_len_0 = _len_0 + 1 -- 2007
											end -- 2007
										end -- 2007
										child.children = _accum_0 -- 2007
									end -- 2007
									break -- 2008
									::_continue_0:: -- 2005
								end -- 2004
							else -- 2010
								local _accum_0 = { } -- 2010
								local _len_0 = 1 -- 2010
								local _list_0 = _with_0.children -- 2010
								for _index_0 = 1, #_list_0 do -- 2010
									local child = _list_0[_index_0] -- 2010
									if child.title ~= "Dora" then -- 2010
										_accum_0[_len_0] = child -- 2010
										_len_0 = _len_0 + 1 -- 2010
									end -- 2010
								end -- 2010
								_with_0.children = _accum_0 -- 2010
							end -- 2003
							return _with_0 -- 2001
						end)(), -- 2001
						(function() -- 2011
							if engineDev then -- 2011
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 2012
								local _obj_0 = _with_0.children -- 2013
								_obj_0[#_obj_0 + 1] = { -- 2014
									key = Path(Content.assetPath, "Script", "init.yue"), -- 2014
									dir = false, -- 2015
									builtin = true, -- 2016
									title = "init.yue" -- 2017
								} -- 2013
								return _with_0 -- 2012
							end -- 2011
						end)() -- 2011
					} -- 1992
				} -- 1987
			} -- 2021
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 2021
			local _idx_0 = #_tab_0 + 1 -- 2021
			for _index_0 = 1, #_obj_0 do -- 2021
				local _value_0 = _obj_0[_index_0] -- 2021
				_tab_0[_idx_0] = _value_0 -- 2021
				_idx_0 = _idx_0 + 1 -- 2021
			end -- 2021
			return _tab_0 -- 1987
		end)() -- 1986
	} -- 1981
end) -- 1917
HttpServer:post("/entry/list", function() -- 2025
	local Entry = require("Script.Dev.Entry") -- 2026
	local res = Entry.getLaunchEntries() -- 2027
	res.success = true -- 2028
	return res -- 2029
end) -- 2025
HttpServer:post("/run/status", function() -- 2031
	local Entry = require("Script.Dev.Entry") -- 2032
	return Entry.getCurrentEntryStatus() -- 2033
end) -- 2031
HttpServer:postSchedule("/run", function(req) -- 2035
	do -- 2036
		local _type_0 = type(req) -- 2036
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2036
		if _tab_0 then -- 2036
			local file -- 2036
			do -- 2036
				local _obj_0 = req.body -- 2036
				local _type_1 = type(_obj_0) -- 2036
				if "table" == _type_1 or "userdata" == _type_1 then -- 2036
					file = _obj_0.file -- 2036
				end -- 2036
			end -- 2036
			local asProj -- 2036
			do -- 2036
				local _obj_0 = req.body -- 2036
				local _type_1 = type(_obj_0) -- 2036
				if "table" == _type_1 or "userdata" == _type_1 then -- 2036
					asProj = _obj_0.asProj -- 2036
				end -- 2036
			end -- 2036
			if file ~= nil and asProj ~= nil then -- 2036
				if not Content:isAbsolutePath(file) then -- 2037
					local devFile = Path(Content.writablePath, file) -- 2038
					if Content:exist(devFile) then -- 2039
						file = devFile -- 2039
					end -- 2039
				end -- 2037
				local Entry = require("Script.Dev.Entry") -- 2040
				local workDir -- 2041
				if asProj then -- 2042
					local projectRoot = req.body.projectRoot -- 2043
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2044
						workDir = projectRoot -- 2045
					else -- 2047
						workDir = getProjectDirFromFile(file) -- 2047
					end -- 2044
					if workDir then -- 2048
						Entry.allClear() -- 2049
						local target = Path(workDir, "init") -- 2050
						local success, err = Entry.enterEntryAsync({ -- 2051
							entryName = "Project", -- 2051
							fileName = target, -- 2051
							workDir = workDir, -- 2051
							projectRoot = workDir, -- 2051
							runKind = "project" -- 2051
						}) -- 2051
						target = Path:getName(Path:getPath(target)) -- 2052
						return { -- 2053
							success = success, -- 2053
							target = target, -- 2053
							err = err -- 2053
						} -- 2053
					end -- 2048
				else -- 2055
					workDir = getProjectDirFromFile(file) -- 2055
					if not workDir and Path:getExt(file) == "wasm" then -- 2056
						local parent = Path:getPath(file) -- 2057
						if Content:exist(Path(parent, "wa.mod")) then -- 2058
							workDir = parent -- 2059
						end -- 2058
					end -- 2056
				end -- 2042
				Entry.allClear() -- 2060
				file = Path:replaceExt(file, "") -- 2061
				local entry = { -- 2063
					entryName = Path:getName(file), -- 2063
					fileName = file, -- 2064
					runKind = "file" -- 2065
				} -- 2062
				if workDir then -- 2066
					entry.workDir = workDir -- 2067
					entry.projectRoot = workDir -- 2068
				end -- 2066
				local success, err = Entry.enterEntryAsync(entry) -- 2069
				return { -- 2070
					success = success, -- 2070
					err = err -- 2070
				} -- 2070
			end -- 2036
		end -- 2036
	end -- 2036
	return { -- 2035
		success = false -- 2035
	} -- 2035
end) -- 2035
HttpServer:postSchedule("/stop", function() -- 2072
	local Entry = require("Script.Dev.Entry") -- 2073
	return { -- 2074
		success = Entry.stop() -- 2074
	} -- 2074
end) -- 2072
local minifyAsync -- 2076
minifyAsync = function(sourcePath, minifyPath) -- 2076
	if not Content:exist(sourcePath) then -- 2077
		return -- 2077
	end -- 2077
	local Entry = require("Script.Dev.Entry") -- 2078
	local errors = { } -- 2079
	local files = Entry.getAllFiles(sourcePath, { -- 2080
		"lua" -- 2080
	}, true) -- 2080
	do -- 2081
		local _accum_0 = { } -- 2081
		local _len_0 = 1 -- 2081
		for _index_0 = 1, #files do -- 2081
			local file = files[_index_0] -- 2081
			if file:sub(1, 1) ~= '.' then -- 2081
				_accum_0[_len_0] = file -- 2081
				_len_0 = _len_0 + 1 -- 2081
			end -- 2081
		end -- 2081
		files = _accum_0 -- 2081
	end -- 2081
	local paths -- 2082
	do -- 2082
		local _tbl_0 = { } -- 2082
		for _index_0 = 1, #files do -- 2082
			local file = files[_index_0] -- 2082
			_tbl_0[Path:getPath(file)] = true -- 2082
		end -- 2082
		paths = _tbl_0 -- 2082
	end -- 2082
	for path in pairs(paths) do -- 2083
		Content:mkdir(Path(minifyPath, path)) -- 2083
	end -- 2083
	local _ <close> = setmetatable({ }, { -- 2084
		__close = function() -- 2084
			package.loaded["luaminify.FormatMini"] = nil -- 2085
			package.loaded["luaminify.ParseLua"] = nil -- 2086
			package.loaded["luaminify.Scope"] = nil -- 2087
			package.loaded["luaminify.Util"] = nil -- 2088
		end -- 2084
	}) -- 2084
	local FormatMini -- 2089
	do -- 2089
		local _obj_0 = require("luaminify") -- 2089
		FormatMini = _obj_0.FormatMini -- 2089
	end -- 2089
	local fileCount = #files -- 2090
	local count = 0 -- 2091
	for _index_0 = 1, #files do -- 2092
		local file = files[_index_0] -- 2092
		thread(function() -- 2093
			local _ <close> = setmetatable({ }, { -- 2094
				__close = function() -- 2094
					count = count + 1 -- 2094
				end -- 2094
			}) -- 2094
			local input = Path(sourcePath, file) -- 2095
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2096
			if Content:exist(input) then -- 2097
				local sourceCodes = Content:loadAsync(input) -- 2098
				local res, err = FormatMini(sourceCodes) -- 2099
				if res then -- 2100
					Content:saveAsync(output, res) -- 2101
					return print("Minify " .. tostring(file)) -- 2102
				else -- 2104
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2104
				end -- 2100
			else -- 2106
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2106
			end -- 2097
		end) -- 2093
		sleep() -- 2107
	end -- 2092
	wait(function() -- 2108
		return count == fileCount -- 2108
	end) -- 2108
	if #errors > 0 then -- 2109
		print(table.concat(errors, '\n')) -- 2110
	end -- 2109
	print("Obfuscation done.") -- 2111
	return files -- 2112
end -- 2076
local zipping = false -- 2114
HttpServer:postSchedule("/zip", function(req) -- 2116
	do -- 2117
		local _type_0 = type(req) -- 2117
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2117
		if _tab_0 then -- 2117
			local path -- 2117
			do -- 2117
				local _obj_0 = req.body -- 2117
				local _type_1 = type(_obj_0) -- 2117
				if "table" == _type_1 or "userdata" == _type_1 then -- 2117
					path = _obj_0.path -- 2117
				end -- 2117
			end -- 2117
			local zipFile -- 2117
			do -- 2117
				local _obj_0 = req.body -- 2117
				local _type_1 = type(_obj_0) -- 2117
				if "table" == _type_1 or "userdata" == _type_1 then -- 2117
					zipFile = _obj_0.zipFile -- 2117
				end -- 2117
			end -- 2117
			local obfuscated -- 2117
			do -- 2117
				local _obj_0 = req.body -- 2117
				local _type_1 = type(_obj_0) -- 2117
				if "table" == _type_1 or "userdata" == _type_1 then -- 2117
					obfuscated = _obj_0.obfuscated -- 2117
				end -- 2117
			end -- 2117
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2117
				if zipping then -- 2118
					goto failed -- 2118
				end -- 2118
				zipping = true -- 2119
				local _ <close> = setmetatable({ }, { -- 2120
					__close = function() -- 2120
						zipping = false -- 2120
					end -- 2120
				}) -- 2120
				if not Content:exist(path) then -- 2121
					goto failed -- 2121
				end -- 2121
				Content:mkdir(Path:getPath(zipFile)) -- 2122
				if obfuscated then -- 2123
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2124
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2125
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2126
					Content:remove(scriptPath) -- 2127
					Content:remove(obfuscatedPath) -- 2128
					Content:remove(tempPath) -- 2129
					Content:mkdir(scriptPath) -- 2130
					Content:mkdir(obfuscatedPath) -- 2131
					Content:mkdir(tempPath) -- 2132
					if not Content:copyAsync(path, tempPath) then -- 2133
						goto failed -- 2133
					end -- 2133
					local Entry = require("Script.Dev.Entry") -- 2134
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2135
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2136
						"tl", -- 2136
						"yue", -- 2136
						"lua", -- 2136
						"ts", -- 2136
						"tsx", -- 2136
						"vs", -- 2136
						"bl", -- 2136
						"xml", -- 2136
						"wa", -- 2136
						"mod" -- 2136
					}, true) -- 2136
					for _index_0 = 1, #scriptFiles do -- 2137
						local file = scriptFiles[_index_0] -- 2137
						Content:remove(Path(tempPath, file)) -- 2138
					end -- 2137
					for _index_0 = 1, #luaFiles do -- 2139
						local file = luaFiles[_index_0] -- 2139
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2140
					end -- 2139
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2141
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2142
					end) then -- 2141
						goto failed -- 2141
					end -- 2141
					return { -- 2143
						success = true -- 2143
					} -- 2143
				else -- 2145
					return { -- 2145
						success = Content:zipAsync(path, zipFile, function(file) -- 2145
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2146
						end) -- 2145
					} -- 2145
				end -- 2123
			end -- 2117
		end -- 2117
	end -- 2117
	::failed:: -- 2147
	return { -- 2116
		success = false -- 2116
	} -- 2116
end) -- 2116
HttpServer:postSchedule("/unzip", function(req) -- 2149
	do -- 2150
		local _type_0 = type(req) -- 2150
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2150
		if _tab_0 then -- 2150
			local zipFile -- 2150
			do -- 2150
				local _obj_0 = req.body -- 2150
				local _type_1 = type(_obj_0) -- 2150
				if "table" == _type_1 or "userdata" == _type_1 then -- 2150
					zipFile = _obj_0.zipFile -- 2150
				end -- 2150
			end -- 2150
			local path -- 2150
			do -- 2150
				local _obj_0 = req.body -- 2150
				local _type_1 = type(_obj_0) -- 2150
				if "table" == _type_1 or "userdata" == _type_1 then -- 2150
					path = _obj_0.path -- 2150
				end -- 2150
			end -- 2150
			if zipFile ~= nil and path ~= nil then -- 2150
				return { -- 2151
					success = Content:unzipAsync(zipFile, path, function(file) -- 2151
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2152
					end) -- 2151
				} -- 2151
			end -- 2150
		end -- 2150
	end -- 2150
	return { -- 2149
		success = false -- 2149
	} -- 2149
end) -- 2149
HttpServer:post("/editing-info", function(req) -- 2154
	local Entry = require("Script.Dev.Entry") -- 2155
	local config = Entry.getConfig() -- 2156
	local _type_0 = type(req) -- 2157
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2157
	local _match_0 = false -- 2157
	if _tab_0 then -- 2157
		local editingInfo -- 2157
		do -- 2157
			local _obj_0 = req.body -- 2157
			local _type_1 = type(_obj_0) -- 2157
			if "table" == _type_1 or "userdata" == _type_1 then -- 2157
				editingInfo = _obj_0.editingInfo -- 2157
			end -- 2157
		end -- 2157
		if editingInfo ~= nil then -- 2157
			_match_0 = true -- 2157
			config.editingInfo = editingInfo -- 2158
			return { -- 2159
				success = true -- 2159
			} -- 2159
		end -- 2157
	end -- 2157
	if not _match_0 then -- 2157
		if not (config.editingInfo ~= nil) then -- 2161
			local folder -- 2162
			if App.locale:match('^zh') then -- 2162
				folder = 'zh-Hans' -- 2162
			else -- 2162
				folder = 'en' -- 2162
			end -- 2162
			config.editingInfo = json.encode({ -- 2164
				index = 0, -- 2164
				files = { -- 2166
					{ -- 2167
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2167
						title = "welcome.md" -- 2168
					} -- 2166
				} -- 2165
			}) -- 2163
		end -- 2161
		return { -- 2172
			success = true, -- 2172
			editingInfo = config.editingInfo -- 2172
		} -- 2172
	end -- 2157
end) -- 2154
HttpServer:post("/command", function(req) -- 2174
	do -- 2175
		local _type_0 = type(req) -- 2175
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2175
		if _tab_0 then -- 2175
			local code -- 2175
			do -- 2175
				local _obj_0 = req.body -- 2175
				local _type_1 = type(_obj_0) -- 2175
				if "table" == _type_1 or "userdata" == _type_1 then -- 2175
					code = _obj_0.code -- 2175
				end -- 2175
			end -- 2175
			local log -- 2175
			do -- 2175
				local _obj_0 = req.body -- 2175
				local _type_1 = type(_obj_0) -- 2175
				if "table" == _type_1 or "userdata" == _type_1 then -- 2175
					log = _obj_0.log -- 2175
				end -- 2175
			end -- 2175
			if code ~= nil and log ~= nil then -- 2175
				emit("AppCommand", code, log) -- 2176
				return { -- 2177
					success = true -- 2177
				} -- 2177
			end -- 2175
		end -- 2175
	end -- 2175
	return { -- 2174
		success = false -- 2174
	} -- 2174
end) -- 2174
HttpServer:post("/log/save", function() -- 2179
	local folder = ".download" -- 2180
	local fullLogFile = "dora_full_logs.txt" -- 2181
	local fullFolder = Path(Content.writablePath, folder) -- 2182
	Content:mkdir(fullFolder) -- 2183
	local logPath = Path(fullFolder, fullLogFile) -- 2184
	if App:saveLog(logPath) then -- 2185
		return { -- 2186
			success = true, -- 2186
			path = Path(folder, fullLogFile) -- 2186
		} -- 2186
	end -- 2185
	return { -- 2179
		success = false -- 2179
	} -- 2179
end) -- 2179
local tailLines -- 2188
tailLines = function(text, count) -- 2188
	local lines = { } -- 2189
	text = text:gsub("\r\n", "\n") -- 2190
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2191
		lines[#lines + 1] = line -- 2192
	end -- 2191
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2193
		table.remove(lines) -- 2194
	end -- 2193
	local start = math.max(1, #lines - count + 1) -- 2195
	local out = { } -- 2196
	for i = start, #lines do -- 2197
		out[#out + 1] = lines[i] -- 2198
	end -- 2197
	return table.concat(out, "\n") -- 2199
end -- 2188
HttpServer:post("/log", function(req) -- 2201
	local count = 100 -- 2202
	if req and req.body and req.body.count ~= nil then -- 2203
		count = req.body.count -- 2204
	end -- 2203
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2205
		return { -- 2206
			success = false, -- 2206
			message = "count must be a positive integer" -- 2206
		} -- 2206
	end -- 2205
	local folder = ".download" -- 2207
	local fullLogFile = "dora_full_logs.txt" -- 2208
	local fullFolder = Path(Content.writablePath, folder) -- 2209
	Content:mkdir(fullFolder) -- 2210
	local logPath = Path(fullFolder, fullLogFile) -- 2211
	if App:saveLog(logPath) then -- 2212
		local text = Content:load(logPath) -- 2213
		if text then -- 2214
			return { -- 2215
				success = true, -- 2215
				log = tailLines(text, count) -- 2215
			} -- 2215
		else -- 2217
			return { -- 2217
				success = false, -- 2217
				message = "failed to read log" -- 2217
			} -- 2217
		end -- 2214
	else -- 2219
		return { -- 2219
			success = false, -- 2219
			message = "failed to save log" -- 2219
		} -- 2219
	end -- 2212
	return { -- 2201
		success = false -- 2201
	} -- 2201
end) -- 2201
HttpServer:post("/yarn/check", function(req) -- 2221
	local yarncompile = require("yarncompile") -- 2222
	do -- 2223
		local _type_0 = type(req) -- 2223
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2223
		if _tab_0 then -- 2223
			local code -- 2223
			do -- 2223
				local _obj_0 = req.body -- 2223
				local _type_1 = type(_obj_0) -- 2223
				if "table" == _type_1 or "userdata" == _type_1 then -- 2223
					code = _obj_0.code -- 2223
				end -- 2223
			end -- 2223
			if code ~= nil then -- 2223
				local jsonObject = json.decode(code) -- 2224
				if jsonObject then -- 2224
					local errors = { } -- 2225
					local _list_0 = jsonObject.nodes -- 2226
					for _index_0 = 1, #_list_0 do -- 2226
						local node = _list_0[_index_0] -- 2226
						local title, body = node.title, node.body -- 2227
						local luaCode, err = yarncompile(body) -- 2228
						if not luaCode then -- 2228
							errors[#errors + 1] = title .. ":" .. err -- 2229
						end -- 2228
					end -- 2226
					return { -- 2230
						success = true, -- 2230
						syntaxError = table.concat(errors, "\n\n") -- 2230
					} -- 2230
				end -- 2224
			end -- 2223
		end -- 2223
	end -- 2223
	return { -- 2221
		success = false -- 2221
	} -- 2221
end) -- 2221
HttpServer:post("/yarn/check-file", function(req) -- 2232
	local yarncompile = require("yarncompile") -- 2233
	do -- 2234
		local _type_0 = type(req) -- 2234
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2234
		if _tab_0 then -- 2234
			local code -- 2234
			do -- 2234
				local _obj_0 = req.body -- 2234
				local _type_1 = type(_obj_0) -- 2234
				if "table" == _type_1 or "userdata" == _type_1 then -- 2234
					code = _obj_0.code -- 2234
				end -- 2234
			end -- 2234
			if code ~= nil then -- 2234
				local res, _, err = yarncompile(code, true) -- 2235
				if not res then -- 2235
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2236
					return { -- 2237
						success = false, -- 2237
						message = message, -- 2237
						line = line, -- 2237
						column = column, -- 2237
						node = node -- 2237
					} -- 2237
				end -- 2235
			end -- 2234
		end -- 2234
	end -- 2234
	return { -- 2232
		success = true -- 2232
	} -- 2232
end) -- 2232
getWaProjectDirFromFile = function(file) -- 2239
	local current -- 2240
	if Content:isdir(file) then -- 2240
		current = file -- 2240
	else -- 2240
		current = Path:getPath(file) -- 2240
	end -- 2240
	if current == "" then -- 2241
		return nil -- 2241
	end -- 2241
	repeat -- 2242
		local modPath = Path(current, "wa.mod") -- 2243
		if Content:exist(modPath) then -- 2244
			return current, modPath -- 2245
		end -- 2244
		local parent = Path:getPath(current) -- 2246
		if parent == "" or parent == current then -- 2247
			break -- 2247
		end -- 2247
		current = parent -- 2248
	until false -- 2242
	return nil -- 2250
end -- 2239
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2252
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
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2255
					if not Content:exist(sourceDoraPath) then -- 2256
						return { -- 2257
							success = false, -- 2257
							message = "missing dora template" -- 2257
						} -- 2257
					end -- 2256
					local targetVendorPath = Path(projDir, "vendor") -- 2258
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2259
					if not Content:exist(targetVendorPath) then -- 2260
						if not Content:mkdir(targetVendorPath) then -- 2261
							return { -- 2262
								success = false, -- 2262
								message = "failed to create vendor folder" -- 2262
							} -- 2262
						end -- 2261
					elseif not Content:isdir(targetVendorPath) then -- 2263
						return { -- 2264
							success = false, -- 2264
							message = "vendor path is not a folder" -- 2264
						} -- 2264
					end -- 2260
					if Content:exist(targetDoraPath) then -- 2265
						if not Content:remove(targetDoraPath) then -- 2266
							return { -- 2267
								success = false, -- 2267
								message = "failed to remove old dora" -- 2267
							} -- 2267
						end -- 2266
					end -- 2265
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2268
						return { -- 2269
							success = false, -- 2269
							message = "failed to copy dora" -- 2269
						} -- 2269
					end -- 2268
					return { -- 2270
						success = true -- 2270
					} -- 2270
				else -- 2272
					return { -- 2272
						success = false, -- 2272
						message = 'Wa file needs a project' -- 2272
					} -- 2272
				end -- 2254
			end -- 2253
		end -- 2253
	end -- 2253
	return { -- 2252
		success = false, -- 2252
		message = "invalid call" -- 2252
	} -- 2252
end) -- 2252
HttpServer:postSchedule("/wa/build", function(req) -- 2274
	do -- 2275
		local _type_0 = type(req) -- 2275
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2275
		if _tab_0 then -- 2275
			local path -- 2275
			do -- 2275
				local _obj_0 = req.body -- 2275
				local _type_1 = type(_obj_0) -- 2275
				if "table" == _type_1 or "userdata" == _type_1 then -- 2275
					path = _obj_0.path -- 2275
				end -- 2275
			end -- 2275
			if path ~= nil then -- 2275
				local projDir = getWaProjectDirFromFile(path) -- 2276
				if projDir then -- 2276
					local message = Wasm:buildWaAsync(projDir) -- 2277
					if message == "" then -- 2278
						return { -- 2279
							success = true -- 2279
						} -- 2279
					else -- 2281
						return { -- 2281
							success = false, -- 2281
							message = message -- 2281
						} -- 2281
					end -- 2278
				else -- 2283
					return { -- 2283
						success = false, -- 2283
						message = 'Wa file needs a project' -- 2283
					} -- 2283
				end -- 2276
			end -- 2275
		end -- 2275
	end -- 2275
	return { -- 2284
		success = false, -- 2284
		message = 'failed to build' -- 2284
	} -- 2284
end) -- 2274
HttpServer:postSchedule("/wa/format", function(req) -- 2286
	do -- 2287
		local _type_0 = type(req) -- 2287
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2287
		if _tab_0 then -- 2287
			local file -- 2287
			do -- 2287
				local _obj_0 = req.body -- 2287
				local _type_1 = type(_obj_0) -- 2287
				if "table" == _type_1 or "userdata" == _type_1 then -- 2287
					file = _obj_0.file -- 2287
				end -- 2287
			end -- 2287
			if file ~= nil then -- 2287
				local code = Wasm:formatWaAsync(file) -- 2288
				if code == "" then -- 2289
					return { -- 2290
						success = false -- 2290
					} -- 2290
				else -- 2292
					return { -- 2292
						success = true, -- 2292
						code = code -- 2292
					} -- 2292
				end -- 2289
			end -- 2287
		end -- 2287
	end -- 2287
	return { -- 2293
		success = false -- 2293
	} -- 2293
end) -- 2286
HttpServer:postSchedule("/wa/create", function(req) -- 2295
	do -- 2296
		local _type_0 = type(req) -- 2296
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2296
		if _tab_0 then -- 2296
			local path -- 2296
			do -- 2296
				local _obj_0 = req.body -- 2296
				local _type_1 = type(_obj_0) -- 2296
				if "table" == _type_1 or "userdata" == _type_1 then -- 2296
					path = _obj_0.path -- 2296
				end -- 2296
			end -- 2296
			if path ~= nil then -- 2296
				if not Content:exist(Path:getPath(path)) then -- 2297
					return { -- 2298
						success = false, -- 2298
						message = "target path not existed" -- 2298
					} -- 2298
				end -- 2297
				if Content:exist(path) then -- 2299
					return { -- 2300
						success = false, -- 2300
						message = "target project folder existed" -- 2300
					} -- 2300
				end -- 2299
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2301
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2302
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2303
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2304
					return { -- 2307
						success = false, -- 2307
						message = "missing template project" -- 2307
					} -- 2307
				end -- 2304
				if not Content:mkdir(path) then -- 2308
					return { -- 2309
						success = false, -- 2309
						message = "failed to create project folder" -- 2309
					} -- 2309
				end -- 2308
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2310
					Content:remove(path) -- 2311
					return { -- 2312
						success = false, -- 2312
						message = "failed to copy template" -- 2312
					} -- 2312
				end -- 2310
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2313
					Content:remove(path) -- 2314
					return { -- 2315
						success = false, -- 2315
						message = "failed to copy template" -- 2315
					} -- 2315
				end -- 2313
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2316
					Content:remove(path) -- 2317
					return { -- 2318
						success = false, -- 2318
						message = "failed to copy template" -- 2318
					} -- 2318
				end -- 2316
				return { -- 2319
					success = true -- 2319
				} -- 2319
			end -- 2296
		end -- 2296
	end -- 2296
	return { -- 2295
		success = false, -- 2295
		message = "invalid call" -- 2295
	} -- 2295
end) -- 2295
local tsBuildGlobs = { -- 2322
	"**/*.ts", -- 2322
	"**/*.tsx", -- 2323
	"!**/.*/**", -- 2324
	"!**/node_modules/**" -- 2325
} -- 2321
local transpileTSFile -- 2327
do -- 2327
	local tsBuildTimeout <const> = 30 -- 2328
	local tsBuildRequestId = 0 -- 2329
	transpileTSFile = function(file, content, sourceRoot) -- 2330
		tsBuildRequestId = tsBuildRequestId + 1 -- 2331
		local requestId = tsBuildRequestId -- 2332
		local done = false -- 2333
		local result = nil -- 2334
		local listener = Node() -- 2335
		listener:gslot("AppWS", function(event) -- 2336
			if event.type == "Receive" then -- 2337
				local res = json.decode(event.msg) -- 2338
				if res then -- 2338
					if res.name == "TranspileTS" and res.id == requestId then -- 2339
						listener:removeFromParent() -- 2340
						if res.success then -- 2341
							local luaFile = Path:replaceExt(file, "lua") -- 2342
							Content:save(luaFile, res.luaCode) -- 2343
							result = { -- 2344
								success = true, -- 2344
								file = file -- 2344
							} -- 2344
						else -- 2346
							result = { -- 2346
								success = false, -- 2346
								file = file, -- 2346
								message = res.message -- 2346
							} -- 2346
						end -- 2341
						done = true -- 2347
					end -- 2339
				end -- 2338
			end -- 2337
		end) -- 2336
		emit("AppWS", "Send", json.encode({ -- 2348
			name = "TranspileTS", -- 2348
			id = requestId, -- 2348
			file = file, -- 2348
			content = content, -- 2348
			projectRoot = sourceRoot -- 2348
		})) -- 2348
		local deadline = App.runningTime + tsBuildTimeout -- 2349
		wait(function() -- 2350
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline -- 2350
		end) -- 2350
		if not done then -- 2351
			listener:removeFromParent() -- 2352
			if HttpServer.wsConnectionCount == 0 then -- 2353
				return { -- 2354
					success = false, -- 2354
					file = file, -- 2354
					message = "Web IDE disconnected" -- 2354
				} -- 2354
			end -- 2353
			return { -- 2355
				success = false, -- 2355
				file = file, -- 2355
				message = "TypeScript transpile timed out" -- 2355
			} -- 2355
		end -- 2351
		return result -- 2356
	end -- 2330
end -- 2327
local _anon_func_6 = function(path) -- 2367
	local _val_0 = Path:getExt(path) -- 2367
	return "ts" == _val_0 or "tsx" == _val_0 -- 2367
end -- 2367
HttpServer:postSchedule("/ts/build", function(req) -- 2358
	do -- 2359
		local _type_0 = type(req) -- 2359
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2359
		if _tab_0 then -- 2359
			local path -- 2359
			do -- 2359
				local _obj_0 = req.body -- 2359
				local _type_1 = type(_obj_0) -- 2359
				if "table" == _type_1 or "userdata" == _type_1 then -- 2359
					path = _obj_0.path -- 2359
				end -- 2359
			end -- 2359
			if path ~= nil then -- 2359
				if HttpServer.wsConnectionCount == 0 then -- 2360
					return { -- 2361
						success = false, -- 2361
						message = "Web IDE not connected" -- 2361
					} -- 2361
				end -- 2360
				local projectRoot = req.body.projectRoot -- 2362
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2363
				if not Content:exist(path) then -- 2364
					return { -- 2365
						success = false, -- 2365
						message = "path not existed" -- 2365
					} -- 2365
				end -- 2364
				if not Content:isdir(path) then -- 2366
					if not (_anon_func_6(path)) then -- 2367
						return { -- 2368
							success = false, -- 2368
							message = "expecting a TypeScript file" -- 2368
						} -- 2368
					end -- 2367
					local messages = { } -- 2369
					local content = Content:load(path) -- 2370
					if not content then -- 2371
						return { -- 2372
							success = false, -- 2372
							message = "failed to read file" -- 2372
						} -- 2372
					end -- 2371
					emit("AppWS", "Send", json.encode({ -- 2373
						name = "UpdateFile", -- 2373
						file = path, -- 2373
						exists = true, -- 2373
						content = content, -- 2373
						projectRoot = sourceRoot -- 2373
					})) -- 2373
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2374
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot) -- 2375
					end -- 2374
					return { -- 2376
						success = true, -- 2376
						messages = messages -- 2376
					} -- 2376
				else -- 2378
					local fileData = { } -- 2378
					local messages = { } -- 2379
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2380
					for _index_0 = 1, #_list_0 do -- 2380
						local subFile = _list_0[_index_0] -- 2380
						local file = Path(path, subFile) -- 2381
						local content = Content:load(file) -- 2382
						if content then -- 2382
							fileData[file] = content -- 2383
							emit("AppWS", "Send", json.encode({ -- 2384
								name = "UpdateFile", -- 2384
								file = file, -- 2384
								exists = true, -- 2384
								content = content, -- 2384
								projectRoot = sourceRoot -- 2384
							})) -- 2384
						else -- 2386
							messages[#messages + 1] = { -- 2386
								success = false, -- 2386
								file = file, -- 2386
								message = "failed to read file" -- 2386
							} -- 2386
						end -- 2382
					end -- 2380
					for file, content in pairs(fileData) do -- 2387
						if "d" == Path:getExt(Path:getName(file)) then -- 2388
							goto _continue_0 -- 2388
						end -- 2388
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot) -- 2389
						::_continue_0:: -- 2388
					end -- 2387
					return { -- 2390
						success = true, -- 2390
						messages = messages -- 2390
					} -- 2390
				end -- 2366
			end -- 2359
		end -- 2359
	end -- 2359
	return { -- 2358
		success = false -- 2358
	} -- 2358
end) -- 2358
HttpServer:post("/download", function(req) -- 2392
	do -- 2393
		local _type_0 = type(req) -- 2393
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2393
		if _tab_0 then -- 2393
			local url -- 2393
			do -- 2393
				local _obj_0 = req.body -- 2393
				local _type_1 = type(_obj_0) -- 2393
				if "table" == _type_1 or "userdata" == _type_1 then -- 2393
					url = _obj_0.url -- 2393
				end -- 2393
			end -- 2393
			local target -- 2393
			do -- 2393
				local _obj_0 = req.body -- 2393
				local _type_1 = type(_obj_0) -- 2393
				if "table" == _type_1 or "userdata" == _type_1 then -- 2393
					target = _obj_0.target -- 2393
				end -- 2393
			end -- 2393
			if url ~= nil and target ~= nil then -- 2393
				local Entry = require("Script.Dev.Entry") -- 2394
				Entry.downloadFile(url, target) -- 2395
				return { -- 2396
					success = true -- 2396
				} -- 2396
			end -- 2393
		end -- 2393
	end -- 2393
	return { -- 2392
		success = false -- 2392
	} -- 2392
end) -- 2392
local isDesktopPlatform -- 2398
isDesktopPlatform = function() -- 2398
	local _val_0 = App.platform -- 2399
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2399
end -- 2398
local getServerStatus -- 2401
getServerStatus = function() -- 2401
	local Entry = require("Script.Dev.Entry") -- 2402
	local running = Entry.getCurrentEntryStatus() -- 2403
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2404
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2405
	return { -- 2407
		success = true, -- 2407
		platform = App.platform, -- 2408
		locale = App.locale, -- 2409
		version = App.version, -- 2410
		url = "http://localhost:8866", -- 2411
		wsConnectionCount = wsConnectionCount, -- 2412
		webIDEConnected = wsConnectionCount > 0, -- 2413
		assetPath = Content.assetPath, -- 2414
		writablePath = Content.writablePath, -- 2415
		appPath = Content.appPath, -- 2416
		waTemplateReady = waTemplateReady, -- 2417
		running = running -- 2418
	} -- 2406
end -- 2401
HttpServer:post("/status", function() -- 2421
	return getServerStatus() -- 2422
end) -- 2421
HttpServer:postSchedule("/doctor/fix", function(req) -- 2424
	do -- 2425
		local _type_0 = type(req) -- 2425
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2425
		if _tab_0 then -- 2425
			local openWebIDE -- 2425
			do -- 2425
				local _obj_0 = req.body -- 2425
				local _type_1 = type(_obj_0) -- 2425
				if "table" == _type_1 or "userdata" == _type_1 then -- 2425
					openWebIDE = _obj_0.openWebIDE -- 2425
				end -- 2425
			end -- 2425
			if openWebIDE ~= nil then -- 2425
				if not openWebIDE then -- 2426
					return { -- 2427
						success = false, -- 2427
						message = "nothing to fix" -- 2427
					} -- 2427
				end -- 2426
				local status = getServerStatus() -- 2428
				if status.webIDEConnected then -- 2429
					return { -- 2430
						success = true, -- 2430
						fixed = false, -- 2430
						message = "Web IDE already connected.", -- 2430
						status = status -- 2430
					} -- 2430
				end -- 2429
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2431
				if waitSeconds > 0 then -- 2432
					local deadline = os.time() + waitSeconds -- 2433
					repeat -- 2434
						sleep(0.2) -- 2435
						status = getServerStatus() -- 2436
						if status.webIDEConnected then -- 2437
							return { -- 2438
								success = true, -- 2438
								fixed = false, -- 2438
								reconnected = true, -- 2438
								message = "Web IDE reconnected.", -- 2438
								status = status -- 2438
							} -- 2438
						end -- 2437
					until os.time() >= deadline -- 2434
				end -- 2432
				if not isDesktopPlatform() then -- 2440
					return { -- 2441
						success = false, -- 2441
						message = "opening Web IDE is only supported on desktop platforms", -- 2441
						status = status -- 2441
					} -- 2441
				end -- 2440
				local url = "http://localhost:8866" -- 2442
				App:openURL(url) -- 2443
				status.openedURL = url -- 2444
				return { -- 2445
					success = true, -- 2445
					fixed = true, -- 2445
					message = "Opened Web IDE in the local browser.", -- 2445
					url = url, -- 2445
					status = status -- 2445
				} -- 2445
			end -- 2425
		end -- 2425
	end -- 2425
	return { -- 2424
		success = false, -- 2424
		message = "invalid call" -- 2424
	} -- 2424
end) -- 2424
local status = { } -- 2447
_module_0 = status -- 2448
status.buildAsync = function(path) -- 2450
	if not Content:exist(path) then -- 2451
		return { -- 2452
			success = false, -- 2452
			file = path, -- 2452
			message = "file not existed" -- 2452
		} -- 2452
	end -- 2451
	do -- 2453
		local _exp_0 = Path:getExt(path) -- 2453
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2453
			if '' == Path:getExt(Path:getName(path)) then -- 2454
				local content = Content:loadAsync(path) -- 2455
				if content then -- 2455
					local resultCodes, err = compileFileAsync(path, content) -- 2456
					if resultCodes then -- 2456
						return { -- 2457
							success = true, -- 2457
							file = path -- 2457
						} -- 2457
					else -- 2459
						return { -- 2459
							success = false, -- 2459
							file = path, -- 2459
							message = err -- 2459
						} -- 2459
					end -- 2456
				end -- 2455
			end -- 2454
		elseif "lua" == _exp_0 then -- 2460
			local content = Content:loadAsync(path) -- 2461
			if content then -- 2461
				do -- 2462
					local isTIC80 = CheckTIC80Code(content) -- 2462
					if isTIC80 then -- 2462
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2463
					end -- 2462
				end -- 2462
				local success, info -- 2464
				do -- 2464
					local _obj_0 = luaCheck(path, content) -- 2464
					success, info = _obj_0.success, _obj_0.info -- 2464
				end -- 2464
				if success then -- 2465
					return { -- 2466
						success = true, -- 2466
						file = path -- 2466
					} -- 2466
				elseif info and #info > 0 then -- 2467
					local messages = { } -- 2468
					for _index_0 = 1, #info do -- 2469
						local _des_0 = info[_index_0] -- 2469
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2469
						local lineText = "" -- 2470
						if line then -- 2471
							local currentLine = 1 -- 2472
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2473
								if currentLine == line then -- 2474
									lineText = text -- 2475
									break -- 2476
								end -- 2474
								currentLine = currentLine + 1 -- 2477
							end -- 2473
						end -- 2471
						if line then -- 2478
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2479
						else -- 2481
							messages[#messages + 1] = message -- 2481
						end -- 2478
					end -- 2469
					return { -- 2482
						success = false, -- 2482
						file = path, -- 2482
						message = table.concat(messages, "\n") -- 2482
					} -- 2482
				else -- 2484
					return { -- 2484
						success = false, -- 2484
						file = path, -- 2484
						message = "lua check failed" -- 2484
					} -- 2484
				end -- 2465
			end -- 2461
		elseif "yarn" == _exp_0 then -- 2485
			local content = Content:loadAsync(path) -- 2486
			if content then -- 2486
				local res, _, err = yarncompile(content, true) -- 2487
				if res then -- 2487
					return { -- 2488
						success = true, -- 2488
						file = path -- 2488
					} -- 2488
				else -- 2490
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2490
					local lineText = "" -- 2491
					if line then -- 2492
						local currentLine = 1 -- 2493
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2494
							if currentLine == line then -- 2495
								lineText = text -- 2496
								break -- 2497
							end -- 2495
							currentLine = currentLine + 1 -- 2498
						end -- 2494
					end -- 2492
					if node ~= "" then -- 2499
						node = "node: " .. tostring(node) .. ", " -- 2500
					else -- 2501
						node = "" -- 2501
					end -- 2499
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2502
					return { -- 2503
						success = false, -- 2503
						file = path, -- 2503
						message = message -- 2503
					} -- 2503
				end -- 2487
			end -- 2486
		end -- 2453
	end -- 2453
	return { -- 2504
		success = false, -- 2504
		file = path, -- 2504
		message = "invalid file to build" -- 2504
	} -- 2504
end -- 2450
thread(function() -- 2506
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 2507
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 2508
	if Content:exist(doraWeb) then -- 2509
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) -- 2510
		local needReload -- 2511
		if Content:exist(doraReady) then -- 2511
			needReload = readyContent ~= Content:load(doraReady) -- 2512
		else -- 2513
			needReload = true -- 2513
		end -- 2511
		if needReload then -- 2514
			Content:remove(Path(Content.appPath, ".www")) -- 2515
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 2516
			Content:save(doraReady, readyContent) -- 2520
			print("Dora Dora is ready!") -- 2521
		end -- 2514
	end -- 2509
	if HttpServer:start(8866) then -- 2522
		local localIP = HttpServer.localIP -- 2523
		if localIP == "" then -- 2524
			localIP = "localhost" -- 2524
		end -- 2524
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 2525
		return HttpServer:startWS(8868) -- 2526
	else -- 2528
		status.url = nil -- 2528
		return print("8866 Port not available!") -- 2529
	end -- 2522
end) -- 2506
return _module_0 -- 1
