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
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1497
	local items -- 1501
	if rows and #rows > 0 then -- 1501
		local _accum_0 = { } -- 1502
		local _len_0 = 1 -- 1502
		for _index_0 = 1, #rows do -- 1502
			local _des_0 = rows[_index_0] -- 1502
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1502
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
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1503
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
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1509
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
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1526
					tostring(name), -- 1526
					tostring(url), -- 1527
					tostring(model), -- 1528
					tostring(key), -- 1529
					contextWindow, -- 1530
					temperature, -- 1531
					maxTokens, -- 1532
					reasoningEffort, -- 1533
					customOptions, -- 1534
					supportsFunctionCalling, -- 1535
					1, -- 1536
					now, -- 1537
					now -- 1538
				}) -- 1520
				return { -- 1540
					success = affected >= 0 -- 1540
				} -- 1540
			end -- 1508
		end -- 1508
	end -- 1508
	return invalidArguments -- 1506
end) -- 1506
HttpServer:post("/llm/update", function(req) -- 1542
	ensureLLMConfigTable() -- 1543
	do -- 1544
		local _type_0 = type(req) -- 1544
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1544
		if _tab_0 then -- 1544
			local body = req.body -- 1544
			if body ~= nil then -- 1544
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1545
				local now = os.time() -- 1546
				id = tonumber(id) -- 1547
				if id == nil then -- 1548
					return invalidArguments -- 1548
				end -- 1548
				contextWindow = normalizeContextWindow(contextWindow) -- 1549
				temperature = normalizeTemperature(temperature) -- 1550
				maxTokens = normalizeMaxTokens(maxTokens) -- 1551
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1552
				customOptions = normalizeCustomOptions(customOptions) -- 1553
				if not validateCustomOptions(customOptions) then -- 1554
					return { -- 1554
						success = false, -- 1554
						message = "customOptions must be a JSON object" -- 1554
					} -- 1554
				end -- 1554
				if supportsFunctionCalling == false then -- 1555
					supportsFunctionCalling = 0 -- 1555
				else -- 1555
					supportsFunctionCalling = 1 -- 1555
				end -- 1555
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1560
					tostring(name), -- 1560
					tostring(url), -- 1561
					tostring(model), -- 1562
					tostring(key), -- 1563
					contextWindow, -- 1564
					temperature, -- 1565
					maxTokens, -- 1566
					reasoningEffort, -- 1567
					customOptions, -- 1568
					supportsFunctionCalling, -- 1569
					now, -- 1570
					id -- 1571
				}) -- 1556
				return { -- 1573
					success = affected >= 0 -- 1573
				} -- 1573
			end -- 1544
		end -- 1544
	end -- 1544
	return invalidArguments -- 1542
end) -- 1542
HttpServer:post("/llm/delete", function(req) -- 1575
	ensureLLMConfigTable() -- 1576
	do -- 1577
		local _type_0 = type(req) -- 1577
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1577
		if _tab_0 then -- 1577
			local id -- 1577
			do -- 1577
				local _obj_0 = req.body -- 1577
				local _type_1 = type(_obj_0) -- 1577
				if "table" == _type_1 or "userdata" == _type_1 then -- 1577
					id = _obj_0.id -- 1577
				end -- 1577
			end -- 1577
			if id ~= nil then -- 1577
				id = tonumber(id) -- 1578
				if id == nil then -- 1579
					return invalidArguments -- 1579
				end -- 1579
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1580
					id -- 1580
				}) -- 1580
				return { -- 1581
					success = affected >= 0 -- 1581
				} -- 1581
			end -- 1577
		end -- 1577
	end -- 1577
	return invalidArguments -- 1575
end) -- 1575
HttpServer:post("/stat", function(req) -- 1583
	do -- 1584
		local _type_0 = type(req) -- 1584
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1584
		if _tab_0 then -- 1584
			local path -- 1584
			do -- 1584
				local _obj_0 = req.body -- 1584
				local _type_1 = type(_obj_0) -- 1584
				if "table" == _type_1 or "userdata" == _type_1 then -- 1584
					path = _obj_0.path -- 1584
				end -- 1584
			end -- 1584
			if path ~= nil then -- 1584
				if not Content:exist(path) then -- 1585
					return { -- 1586
						success = false, -- 1586
						message = "target not existed" -- 1586
					} -- 1586
				end -- 1585
				if Content:isdir(path) then -- 1587
					return { -- 1588
						success = false, -- 1588
						message = "failed to stat a directory" -- 1588
					} -- 1588
				end -- 1587
				local size, isBinary = Content:getAttr(path) -- 1589
				if size then -- 1589
					return { -- 1590
						success = true, -- 1590
						size = size, -- 1590
						isBinary = isBinary -- 1590
					} -- 1590
				end -- 1589
			end -- 1584
		end -- 1584
	end -- 1584
	return { -- 1583
		success = false, -- 1583
		message = "failed to stat" -- 1583
	} -- 1583
end) -- 1583
HttpServer:post("/new", function(req) -- 1592
	do -- 1593
		local _type_0 = type(req) -- 1593
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1593
		if _tab_0 then -- 1593
			local path -- 1593
			do -- 1593
				local _obj_0 = req.body -- 1593
				local _type_1 = type(_obj_0) -- 1593
				if "table" == _type_1 or "userdata" == _type_1 then -- 1593
					path = _obj_0.path -- 1593
				end -- 1593
			end -- 1593
			local content -- 1593
			do -- 1593
				local _obj_0 = req.body -- 1593
				local _type_1 = type(_obj_0) -- 1593
				if "table" == _type_1 or "userdata" == _type_1 then -- 1593
					content = _obj_0.content -- 1593
				end -- 1593
			end -- 1593
			local folder -- 1593
			do -- 1593
				local _obj_0 = req.body -- 1593
				local _type_1 = type(_obj_0) -- 1593
				if "table" == _type_1 or "userdata" == _type_1 then -- 1593
					folder = _obj_0.folder -- 1593
				end -- 1593
			end -- 1593
			if path ~= nil and content ~= nil and folder ~= nil then -- 1593
				if Content:exist(path) then -- 1594
					return { -- 1595
						success = false, -- 1595
						message = "TargetExisted" -- 1595
					} -- 1595
				end -- 1594
				local parent = Path:getPath(path) -- 1596
				local files = Content:getFiles(parent) -- 1597
				if folder then -- 1598
					local name = Path:getFilename(path):lower() -- 1599
					for _index_0 = 1, #files do -- 1600
						local file = files[_index_0] -- 1600
						if name == Path:getFilename(file):lower() then -- 1601
							return { -- 1602
								success = false, -- 1602
								message = "TargetExisted" -- 1602
							} -- 1602
						end -- 1601
					end -- 1600
					if Content:mkdir(path) then -- 1603
						return { -- 1604
							success = true -- 1604
						} -- 1604
					end -- 1603
				else -- 1606
					local name = Path:getName(path):lower() -- 1606
					for _index_0 = 1, #files do -- 1607
						local file = files[_index_0] -- 1607
						if name == Path:getName(file):lower() then -- 1608
							local ext = Path:getExt(file) -- 1609
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1610
								goto _continue_0 -- 1611
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1612
								goto _continue_0 -- 1613
							end -- 1610
							return { -- 1614
								success = false, -- 1614
								message = "SourceExisted" -- 1614
							} -- 1614
						end -- 1608
						::_continue_0:: -- 1608
					end -- 1607
					if Content:save(path, content) then -- 1615
						return { -- 1616
							success = true -- 1616
						} -- 1616
					end -- 1615
				end -- 1598
			end -- 1593
		end -- 1593
	end -- 1593
	return { -- 1592
		success = false, -- 1592
		message = "Failed" -- 1592
	} -- 1592
end) -- 1592
HttpServer:post("/delete", function(req) -- 1618
	do -- 1619
		local _type_0 = type(req) -- 1619
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1619
		if _tab_0 then -- 1619
			local path -- 1619
			do -- 1619
				local _obj_0 = req.body -- 1619
				local _type_1 = type(_obj_0) -- 1619
				if "table" == _type_1 or "userdata" == _type_1 then -- 1619
					path = _obj_0.path -- 1619
				end -- 1619
			end -- 1619
			if path ~= nil then -- 1619
				if Content:exist(path) then -- 1620
					local projectRoot -- 1621
					if Content:isdir(path) and isProjectRootDir(path) then -- 1621
						projectRoot = path -- 1621
					else -- 1621
						projectRoot = nil -- 1621
					end -- 1621
					local parent = Path:getPath(path) -- 1622
					local files = Content:getFiles(parent) -- 1623
					local name = Path:getName(path):lower() -- 1624
					local ext = Path:getExt(path) -- 1625
					for _index_0 = 1, #files do -- 1626
						local file = files[_index_0] -- 1626
						if name == Path:getName(file):lower() then -- 1627
							local _exp_0 = Path:getExt(file) -- 1628
							if "tl" == _exp_0 then -- 1628
								if ("vs" == ext) then -- 1628
									Content:remove(Path(parent, file)) -- 1629
								end -- 1628
							elseif "lua" == _exp_0 then -- 1630
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1630
									Content:remove(Path(parent, file)) -- 1631
								end -- 1630
							end -- 1628
						end -- 1627
					end -- 1626
					if Content:remove(path) then -- 1632
						if projectRoot then -- 1633
							AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1634
						end -- 1633
						return { -- 1635
							success = true -- 1635
						} -- 1635
					end -- 1632
				end -- 1620
			end -- 1619
		end -- 1619
	end -- 1619
	return { -- 1618
		success = false -- 1618
	} -- 1618
end) -- 1618
HttpServer:post("/rename", function(req) -- 1637
	do -- 1638
		local _type_0 = type(req) -- 1638
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1638
		if _tab_0 then -- 1638
			local old -- 1638
			do -- 1638
				local _obj_0 = req.body -- 1638
				local _type_1 = type(_obj_0) -- 1638
				if "table" == _type_1 or "userdata" == _type_1 then -- 1638
					old = _obj_0.old -- 1638
				end -- 1638
			end -- 1638
			local new -- 1638
			do -- 1638
				local _obj_0 = req.body -- 1638
				local _type_1 = type(_obj_0) -- 1638
				if "table" == _type_1 or "userdata" == _type_1 then -- 1638
					new = _obj_0.new -- 1638
				end -- 1638
			end -- 1638
			if old ~= nil and new ~= nil then -- 1638
				if Content:exist(old) and not Content:exist(new) then -- 1639
					local renamedDir = Content:isdir(old) -- 1640
					local parent = Path:getPath(new) -- 1641
					local files = Content:getFiles(parent) -- 1642
					if renamedDir then -- 1643
						local name = Path:getFilename(new):lower() -- 1644
						for _index_0 = 1, #files do -- 1645
							local file = files[_index_0] -- 1645
							if name == Path:getFilename(file):lower() then -- 1646
								return { -- 1647
									success = false -- 1647
								} -- 1647
							end -- 1646
						end -- 1645
					else -- 1649
						local name = Path:getName(new):lower() -- 1649
						local ext = Path:getExt(new) -- 1650
						for _index_0 = 1, #files do -- 1651
							local file = files[_index_0] -- 1651
							if name == Path:getName(file):lower() then -- 1652
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1653
									goto _continue_0 -- 1654
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1655
									goto _continue_0 -- 1656
								end -- 1653
								return { -- 1657
									success = false -- 1657
								} -- 1657
							end -- 1652
							::_continue_0:: -- 1652
						end -- 1651
					end -- 1643
					if Content:move(old, new) then -- 1658
						if renamedDir then -- 1659
							AgentSession.renameSessionsByProjectRoot(old, new) -- 1660
						end -- 1659
						local newParent = Path:getPath(new) -- 1661
						parent = Path:getPath(old) -- 1662
						files = Content:getFiles(parent) -- 1663
						local newName = Path:getName(new) -- 1664
						local oldName = Path:getName(old) -- 1665
						local name = oldName:lower() -- 1666
						local ext = Path:getExt(old) -- 1667
						for _index_0 = 1, #files do -- 1668
							local file = files[_index_0] -- 1668
							if name == Path:getName(file):lower() then -- 1669
								local _exp_0 = Path:getExt(file) -- 1670
								if "tl" == _exp_0 then -- 1670
									if ("vs" == ext) then -- 1670
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1671
									end -- 1670
								elseif "lua" == _exp_0 then -- 1672
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1672
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1673
									end -- 1672
								end -- 1670
							end -- 1669
						end -- 1668
						return { -- 1674
							success = true -- 1674
						} -- 1674
					end -- 1658
				end -- 1639
			end -- 1638
		end -- 1638
	end -- 1638
	return { -- 1637
		success = false -- 1637
	} -- 1637
end) -- 1637
local withProjectSearchPaths -- 1676
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1676
	local fallbackPaths = { } -- 1677
	local addFallback -- 1678
	addFallback = function(dir) -- 1678
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1678
			fallbackPaths[#fallbackPaths + 1] = dir -- 1678
		end -- 1678
	end -- 1678
	if projectRoot and projectRoot ~= "" then -- 1679
		addFallback(Path(projectRoot, "Script")) -- 1680
		addFallback(projectRoot) -- 1681
	end -- 1679
	if projFile then -- 1682
		local projDir = getProjectDirFromFile(projFile) -- 1683
		if projDir then -- 1683
			addFallback(Path(projDir, "Script")) -- 1684
			addFallback(projDir) -- 1685
		else -- 1687
			addFallback(Path:getPath(projFile)) -- 1687
		end -- 1683
	end -- 1682
	if not (#fallbackPaths > 0) then -- 1688
		return fn() -- 1688
	end -- 1688
	local searchPaths = Content.searchPaths -- 1689
	for _index_0 = 1, #fallbackPaths do -- 1690
		local dir = fallbackPaths[_index_0] -- 1690
		Content:addSearchPath(dir) -- 1690
	end -- 1690
	local _ <close> = setmetatable({ }, { -- 1691
		__close = function() -- 1691
			Content.searchPaths = searchPaths -- 1691
		end -- 1691
	}) -- 1691
	return fn() -- 1692
end -- 1676
HttpServer:post("/exist", function(req) -- 1693
	do -- 1694
		local _type_0 = type(req) -- 1694
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1694
		if _tab_0 then -- 1694
			local file -- 1694
			do -- 1694
				local _obj_0 = req.body -- 1694
				local _type_1 = type(_obj_0) -- 1694
				if "table" == _type_1 or "userdata" == _type_1 then -- 1694
					file = _obj_0.file -- 1694
				end -- 1694
			end -- 1694
			if file ~= nil then -- 1694
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1695
					return { -- 1696
						success = Content:exist(file) -- 1696
					} -- 1696
				end) -- 1695
			end -- 1694
		end -- 1694
	end -- 1694
	return { -- 1693
		success = false -- 1693
	} -- 1693
end) -- 1693
HttpServer:postSchedule("/read", function(req) -- 1697
	do -- 1698
		local _type_0 = type(req) -- 1698
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1698
		if _tab_0 then -- 1698
			local path -- 1698
			do -- 1698
				local _obj_0 = req.body -- 1698
				local _type_1 = type(_obj_0) -- 1698
				if "table" == _type_1 or "userdata" == _type_1 then -- 1698
					path = _obj_0.path -- 1698
				end -- 1698
			end -- 1698
			if path ~= nil then -- 1698
				local readFile -- 1699
				readFile = function() -- 1699
					if Content:exist(path) then -- 1700
						local content = Content:loadAsync(path) -- 1701
						if content then -- 1701
							return { -- 1702
								content = content, -- 1702
								success = true, -- 1702
								fullPath = Content:getFullPath(path) -- 1702
							} -- 1702
						end -- 1701
					end -- 1700
					return nil -- 1699
				end -- 1699
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1703
				if result then -- 1703
					return result -- 1703
				end -- 1703
			end -- 1698
		end -- 1698
	end -- 1698
	return { -- 1697
		success = false -- 1697
	} -- 1697
end) -- 1697
local agentDocLanguage -- 1705
agentDocLanguage = function(language) -- 1705
	if language == "zh-Hans" then -- 1706
		return "zh" -- 1706
	else -- 1706
		return "en" -- 1706
	end -- 1706
end -- 1705
HttpServer:postSchedule("/doc/search", function(req) -- 1708
	local body = req.body or { } -- 1709
	local language = body.docLanguage -- 1710
	if not (("en" == language or "zh-Hans" == language)) then -- 1711
		return { -- 1711
			success = false, -- 1711
			message = "unsupported doc language" -- 1711
		} -- 1711
	end -- 1711
	local source = body.docSource -- 1712
	if not (("api" == source or "tutorial" == source)) then -- 1713
		return { -- 1713
			success = false, -- 1713
			message = "unsupported doc source" -- 1713
		} -- 1713
	end -- 1713
	local codeLanguage = body.programmingLanguage -- 1714
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1715
		return { -- 1715
			success = false, -- 1715
			message = "unsupported programming language" -- 1715
		} -- 1715
	end -- 1715
	if not body.pattern then -- 1716
		return { -- 1716
			success = false, -- 1716
			message = "missing pattern" -- 1716
		} -- 1716
	end -- 1716
	local result = nil -- 1717
	AgentTools.searchDoraAPIHttp({ -- 1719
		pattern = body.pattern, -- 1719
		docLanguage = agentDocLanguage(language), -- 1720
		docSource = source, -- 1721
		programmingLanguage = codeLanguage, -- 1722
		limit = body.limit, -- 1723
		useRegex = body.useRegex, -- 1724
		caseSensitive = body.caseSensitive, -- 1725
		includeContent = body.includeContent, -- 1726
		contentWindow = body.contentWindow -- 1727
	}, function(res) -- 1728
		result = res -- 1729
	end) -- 1718
	wait(function() -- 1730
		return result ~= nil -- 1730
	end) -- 1730
	if result and result.success then -- 1731
		result.docLanguage = language -- 1732
	end -- 1731
	if result then -- 1733
		return result -- 1734
	else -- 1736
		return { -- 1736
			success = false, -- 1736
			message = "doc search failed" -- 1736
		} -- 1736
	end -- 1733
	return { -- 1708
		success = false, -- 1708
		message = "invalid call" -- 1708
	} -- 1708
end) -- 1708
HttpServer:postSchedule("/doc/read", function(req) -- 1738
	local body = req.body or { } -- 1739
	local language = body.docLanguage -- 1740
	if not (("en" == language or "zh-Hans" == language)) then -- 1741
		return { -- 1741
			success = false, -- 1741
			message = "unsupported doc language" -- 1741
		} -- 1741
	end -- 1741
	if not body.file then -- 1742
		return { -- 1742
			success = false, -- 1742
			message = "missing file" -- 1742
		} -- 1742
	end -- 1742
	local result = AgentTools.readDoraDoc({ -- 1744
		docLanguage = agentDocLanguage(language), -- 1744
		file = body.file, -- 1745
		startLine = body.startLine, -- 1746
		endLine = body.endLine -- 1747
	}) -- 1743
	if result and result.success then -- 1748
		result.docLanguage = language -- 1749
	end -- 1748
	return result -- 1750
end) -- 1738
HttpServer:get("/read-sync", function(req) -- 1752
	do -- 1753
		local _type_0 = type(req) -- 1753
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1753
		if _tab_0 then -- 1753
			local params = req.params -- 1753
			if params ~= nil then -- 1753
				local path = params.path -- 1754
				local exts -- 1755
				if params.exts then -- 1755
					local _accum_0 = { } -- 1756
					local _len_0 = 1 -- 1756
					for ext in params.exts:gmatch("[^|]*") do -- 1756
						_accum_0[_len_0] = ext -- 1756
						_len_0 = _len_0 + 1 -- 1756
					end -- 1756
					exts = _accum_0 -- 1756
				else -- 1757
					exts = { -- 1757
						"" -- 1757
					} -- 1757
				end -- 1755
				local readFileAt -- 1758
				readFileAt = function(targetPath) -- 1758
					if Content:exist(targetPath) then -- 1759
						local content = Content:load(targetPath) -- 1760
						if content then -- 1760
							return { -- 1761
								content = content, -- 1761
								success = true, -- 1761
								fullPath = Content:getFullPath(targetPath) -- 1761
							} -- 1761
						end -- 1760
					end -- 1759
					return nil -- 1758
				end -- 1758
				local readFile -- 1762
				readFile = function(fallbackPaths) -- 1762
					for _index_0 = 1, #exts do -- 1763
						local ext = exts[_index_0] -- 1763
						local targetPath = path .. ext -- 1764
						if not Content:isAbsolutePath(targetPath) then -- 1765
							for _index_1 = 1, #fallbackPaths do -- 1766
								local fallback = fallbackPaths[_index_1] -- 1766
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1767
								if fallbackResult then -- 1767
									return fallbackResult -- 1768
								end -- 1767
							end -- 1766
						end -- 1765
						local fileResult = readFileAt(targetPath) -- 1769
						if fileResult then -- 1769
							return fileResult -- 1770
						end -- 1769
					end -- 1763
					return nil -- 1762
				end -- 1762
				local fallbackPaths = { } -- 1771
				local fallbackCandidates = { } -- 1772
				do -- 1773
					local projectRoot = req.params.projectRoot -- 1773
					if projectRoot then -- 1773
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1774
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1775
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1776
						end -- 1774
					end -- 1773
				end -- 1773
				do -- 1777
					local projFile = req.params.projFile -- 1777
					if projFile then -- 1777
						local projDir = getProjectDirFromFile(projFile) -- 1778
						if projDir then -- 1778
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1779
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1780
						else -- 1782
							projDir = Path:getPath(projFile) -- 1782
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1783
						end -- 1778
					end -- 1777
				end -- 1777
				for _index_0 = 1, #fallbackCandidates do -- 1784
					local dir = fallbackCandidates[_index_0] -- 1784
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1785
						local exists = false -- 1786
						for _index_1 = 1, #fallbackPaths do -- 1787
							local fallback = fallbackPaths[_index_1] -- 1787
							if fallback == dir then -- 1788
								exists = true -- 1789
								break -- 1790
							end -- 1788
						end -- 1787
						if not exists then -- 1791
							fallbackPaths[#fallbackPaths + 1] = dir -- 1791
						end -- 1791
					end -- 1785
				end -- 1784
				local readResult = readFile(fallbackPaths) -- 1792
				if readResult then -- 1792
					return readResult -- 1793
				end -- 1792
			end -- 1753
		end -- 1753
	end -- 1753
	return { -- 1752
		success = false -- 1752
	} -- 1752
end) -- 1752
local compileFileAsync -- 1795
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1795
	if projectRoot == nil then -- 1795
		projectRoot = nil -- 1795
	end -- 1795
	local file = inputFile -- 1796
	local searchPath -- 1797
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1797
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1798
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1802
	elseif not Content:isAbsolutePath(inputFile) then -- 1803
		searchPath = "" -- 1804
	else -- 1805
		local dir = getProjectDirFromFile(inputFile) -- 1805
		if dir then -- 1805
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1806
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1810
		else -- 1812
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1812
			searchPath = "" -- 1815
		end -- 1805
	end -- 1797
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1816
	local yueext = yue.options.extension -- 1817
	local resultCodes = nil -- 1818
	local resultError = nil -- 1819
	do -- 1820
		local _exp_0 = Path:getExt(inputFile) -- 1820
		if yueext == _exp_0 then -- 1820
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1821
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1822
				if not codes then -- 1823
					resultError = err -- 1824
					return -- 1825
				end -- 1823
				local extraGlobal -- 1826
				if isTIC80 then -- 1826
					extraGlobal = tic80APIs -- 1826
				else -- 1826
					extraGlobal = nil -- 1826
				end -- 1826
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1827
				if not success then -- 1828
					resultError = message -- 1829
					return -- 1830
				end -- 1828
				if codes == "" then -- 1831
					resultCodes = "" -- 1832
					return nil -- 1833
				end -- 1831
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1834
				return resultCodes -- 1835
			end, function(success) -- 1822
				if not success then -- 1836
					Content:remove(outputFile) -- 1837
					if resultCodes == nil then -- 1838
						resultCodes = false -- 1839
					end -- 1838
				end -- 1836
			end) -- 1822
		elseif "tl" == _exp_0 then -- 1840
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1841
			if isTIC80 then -- 1842
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1843
			end -- 1842
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1844
			if codes then -- 1844
				if isTIC80 then -- 1845
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1846
				end -- 1845
				resultCodes = codes -- 1847
				Content:saveAsync(outputFile, codes) -- 1848
			else -- 1850
				Content:remove(outputFile) -- 1850
				resultCodes = false -- 1851
				resultError = err -- 1852
			end -- 1844
		elseif "xml" == _exp_0 then -- 1853
			local codes, err = xml.tolua(sourceCodes) -- 1854
			if codes then -- 1854
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1855
				Content:saveAsync(outputFile, resultCodes) -- 1856
			else -- 1858
				Content:remove(outputFile) -- 1858
				resultCodes = false -- 1859
				resultError = err -- 1860
			end -- 1854
		end -- 1820
	end -- 1820
	wait(function() -- 1861
		return resultCodes ~= nil -- 1861
	end) -- 1861
	if resultCodes then -- 1862
		return resultCodes -- 1863
	else -- 1865
		return nil, resultError -- 1865
	end -- 1862
	return nil -- 1795
end -- 1795
HttpServer:postSchedule("/write", function(req) -- 1867
	do -- 1868
		local _type_0 = type(req) -- 1868
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1868
		if _tab_0 then -- 1868
			local path -- 1868
			do -- 1868
				local _obj_0 = req.body -- 1868
				local _type_1 = type(_obj_0) -- 1868
				if "table" == _type_1 or "userdata" == _type_1 then -- 1868
					path = _obj_0.path -- 1868
				end -- 1868
			end -- 1868
			local content -- 1868
			do -- 1868
				local _obj_0 = req.body -- 1868
				local _type_1 = type(_obj_0) -- 1868
				if "table" == _type_1 or "userdata" == _type_1 then -- 1868
					content = _obj_0.content -- 1868
				end -- 1868
			end -- 1868
			if path ~= nil and content ~= nil then -- 1868
				if Content:saveAsync(path, content) then -- 1869
					do -- 1870
						local _exp_0 = Path:getExt(path) -- 1870
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1870
							if '' == Path:getExt(Path:getName(path)) then -- 1871
								local resultCodes = compileFileAsync(path, content) -- 1872
								return { -- 1873
									success = true, -- 1873
									resultCodes = resultCodes -- 1873
								} -- 1873
							end -- 1871
						end -- 1870
					end -- 1870
					return { -- 1874
						success = true -- 1874
					} -- 1874
				end -- 1869
			end -- 1868
		end -- 1868
	end -- 1868
	return { -- 1867
		success = false -- 1867
	} -- 1867
end) -- 1867
local getWaProjectDirFromFile = nil -- 1876
HttpServer:postSchedule("/build", function(req) -- 1878
	do -- 1879
		local _type_0 = type(req) -- 1879
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1879
		if _tab_0 then -- 1879
			local path -- 1879
			do -- 1879
				local _obj_0 = req.body -- 1879
				local _type_1 = type(_obj_0) -- 1879
				if "table" == _type_1 or "userdata" == _type_1 then -- 1879
					path = _obj_0.path -- 1879
				end -- 1879
			end -- 1879
			if path ~= nil then -- 1879
				local projectRoot = req.body.projectRoot -- 1880
				if Content:isdir(path) then -- 1881
					local projDir = getWaProjectDirFromFile(path) -- 1882
					if projDir then -- 1882
						local message = Wasm:buildWaAsync(projDir) -- 1883
						if message == "" then -- 1884
							return { -- 1885
								success = true -- 1885
							} -- 1885
						else -- 1887
							return { -- 1887
								success = false, -- 1887
								message = message -- 1887
							} -- 1887
						end -- 1884
					end -- 1882
				end -- 1881
				local _exp_0 = Path:getExt(path) -- 1888
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1889
					if '' == Path:getExt(Path:getName(path)) then -- 1890
						local content = Content:loadAsync(path) -- 1891
						if content then -- 1891
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 1892
							if resultCodes then -- 1892
								return { -- 1893
									success = true, -- 1893
									resultCodes = resultCodes -- 1893
								} -- 1893
							end -- 1892
						end -- 1891
					end -- 1890
				elseif "wa" == _exp_0 then -- 1894
					local projDir = getWaProjectDirFromFile(path) -- 1895
					if projDir then -- 1895
						local message = Wasm:buildWaAsync(projDir) -- 1896
						if message == "" then -- 1897
							return { -- 1898
								success = true -- 1898
							} -- 1898
						else -- 1900
							return { -- 1900
								success = false, -- 1900
								message = message -- 1900
							} -- 1900
						end -- 1897
					else -- 1902
						return { -- 1902
							success = false, -- 1902
							message = 'Wa file needs a project' -- 1902
						} -- 1902
					end -- 1895
				end -- 1888
			end -- 1879
		end -- 1879
	end -- 1879
	return { -- 1878
		success = false -- 1878
	} -- 1878
end) -- 1878
local extentionLevels = { -- 1905
	vs = 2, -- 1905
	bl = 2, -- 1906
	ts = 1, -- 1907
	tsx = 1, -- 1908
	tl = 1, -- 1909
	yue = 1, -- 1910
	xml = 1, -- 1911
	lua = 0 -- 1912
} -- 1904
HttpServer:post("/assets", function() -- 1914
	local Entry = require("Script.Dev.Entry") -- 1917
	local engineDev = Entry.getEngineDev() -- 1918
	local visitAssets -- 1919
	visitAssets = function(path, tag) -- 1919
		local isWorkspace = tag == "Workspace" -- 1920
		local builtin -- 1921
		if tag == "Builtin" then -- 1921
			builtin = true -- 1921
		else -- 1921
			builtin = nil -- 1921
		end -- 1921
		local children = nil -- 1922
		local dirs = Content:getDirs(path) -- 1923
		for _index_0 = 1, #dirs do -- 1924
			local dir = dirs[_index_0] -- 1924
			if isWorkspace then -- 1925
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1926
					goto _continue_0 -- 1927
				end -- 1926
			elseif dir == ".git" then -- 1928
				goto _continue_0 -- 1929
			end -- 1925
			if not children then -- 1930
				children = { } -- 1930
			end -- 1930
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1931
			::_continue_0:: -- 1925
		end -- 1924
		local files = Content:getFiles(path) -- 1932
		local names = { } -- 1933
		for _index_0 = 1, #files do -- 1934
			local file = files[_index_0] -- 1934
			if (".DS_Store" == file) then -- 1935
				goto _continue_1 -- 1936
			end -- 1935
			local name = Path:getName(file) -- 1937
			local ext = names[name] -- 1938
			if ext then -- 1938
				local lv1 -- 1939
				do -- 1939
					local _exp_0 = extentionLevels[ext] -- 1939
					if _exp_0 ~= nil then -- 1939
						lv1 = _exp_0 -- 1939
					else -- 1939
						lv1 = -1 -- 1939
					end -- 1939
				end -- 1939
				ext = Path:getExt(file) -- 1940
				local lv2 -- 1941
				do -- 1941
					local _exp_0 = extentionLevels[ext] -- 1941
					if _exp_0 ~= nil then -- 1941
						lv2 = _exp_0 -- 1941
					else -- 1941
						lv2 = -1 -- 1941
					end -- 1941
				end -- 1941
				if lv2 > lv1 then -- 1942
					names[name] = ext -- 1943
				elseif lv2 == lv1 then -- 1944
					names[name .. '.' .. ext] = "" -- 1945
				end -- 1942
			else -- 1947
				ext = Path:getExt(file) -- 1947
				if not extentionLevels[ext] then -- 1948
					names[file] = "" -- 1949
				else -- 1951
					names[name] = ext -- 1951
				end -- 1948
			end -- 1938
			::_continue_1:: -- 1935
		end -- 1934
		do -- 1952
			local _accum_0 = { } -- 1952
			local _len_0 = 1 -- 1952
			for name, ext in pairs(names) do -- 1952
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1952
				_len_0 = _len_0 + 1 -- 1952
			end -- 1952
			files = _accum_0 -- 1952
		end -- 1952
		for _index_0 = 1, #files do -- 1953
			local file = files[_index_0] -- 1953
			if not children then -- 1954
				children = { } -- 1954
			end -- 1954
			children[#children + 1] = { -- 1956
				key = Path(path, file), -- 1956
				dir = false, -- 1957
				title = file, -- 1958
				builtin = builtin -- 1959
			} -- 1955
		end -- 1953
		if children then -- 1961
			table.sort(children, function(a, b) -- 1962
				if a.dir == b.dir then -- 1963
					return a.title < b.title -- 1964
				else -- 1966
					return a.dir -- 1966
				end -- 1963
			end) -- 1962
		end -- 1961
		if isWorkspace and children then -- 1967
			return children -- 1968
		else -- 1970
			return { -- 1971
				key = path, -- 1971
				dir = true, -- 1972
				title = Path:getFilename(path), -- 1973
				builtin = builtin, -- 1974
				children = children -- 1975
			} -- 1970
		end -- 1967
	end -- 1919
	local zh = (App.locale:match("^zh") ~= nil) -- 1977
	return { -- 1979
		key = Content.writablePath, -- 1979
		dir = true, -- 1980
		root = true, -- 1981
		title = "Assets", -- 1982
		children = (function() -- 1984
			local _tab_0 = { -- 1984
				{ -- 1985
					key = Path(Content.assetPath), -- 1985
					dir = true, -- 1986
					builtin = true, -- 1987
					title = zh and "内置资源" or "Built-in", -- 1988
					children = { -- 1990
						(function() -- 1990
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1990
							_with_0.title = zh and "说明文档" or "Readme" -- 1991
							return _with_0 -- 1990
						end)(), -- 1990
						(function() -- 1992
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1992
							_with_0.title = zh and "接口文档" or "API Doc" -- 1993
							return _with_0 -- 1992
						end)(), -- 1992
						(function() -- 1994
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1994
							_with_0.title = zh and "开发工具" or "Tools" -- 1995
							return _with_0 -- 1994
						end)(), -- 1994
						(function() -- 1996
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1996
							_with_0.title = zh and "字体" or "Font" -- 1997
							return _with_0 -- 1996
						end)(), -- 1996
						(function() -- 1998
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1998
							_with_0.title = zh and "程序库" or "Lib" -- 1999
							if engineDev then -- 2000
								local _list_0 = _with_0.children -- 2001
								for _index_0 = 1, #_list_0 do -- 2001
									local child = _list_0[_index_0] -- 2001
									if not (child.title == "Dora") then -- 2002
										goto _continue_0 -- 2002
									end -- 2002
									local title = zh and "zh-Hans" or "en" -- 2003
									do -- 2004
										local _accum_0 = { } -- 2004
										local _len_0 = 1 -- 2004
										local _list_1 = child.children -- 2004
										for _index_1 = 1, #_list_1 do -- 2004
											local c = _list_1[_index_1] -- 2004
											if c.title ~= title then -- 2004
												_accum_0[_len_0] = c -- 2004
												_len_0 = _len_0 + 1 -- 2004
											end -- 2004
										end -- 2004
										child.children = _accum_0 -- 2004
									end -- 2004
									break -- 2005
									::_continue_0:: -- 2002
								end -- 2001
							else -- 2007
								local _accum_0 = { } -- 2007
								local _len_0 = 1 -- 2007
								local _list_0 = _with_0.children -- 2007
								for _index_0 = 1, #_list_0 do -- 2007
									local child = _list_0[_index_0] -- 2007
									if child.title ~= "Dora" then -- 2007
										_accum_0[_len_0] = child -- 2007
										_len_0 = _len_0 + 1 -- 2007
									end -- 2007
								end -- 2007
								_with_0.children = _accum_0 -- 2007
							end -- 2000
							return _with_0 -- 1998
						end)(), -- 1998
						(function() -- 2008
							if engineDev then -- 2008
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 2009
								local _obj_0 = _with_0.children -- 2010
								_obj_0[#_obj_0 + 1] = { -- 2011
									key = Path(Content.assetPath, "Script", "init.yue"), -- 2011
									dir = false, -- 2012
									builtin = true, -- 2013
									title = "init.yue" -- 2014
								} -- 2010
								return _with_0 -- 2009
							end -- 2008
						end)() -- 2008
					} -- 1989
				} -- 1984
			} -- 2018
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 2018
			local _idx_0 = #_tab_0 + 1 -- 2018
			for _index_0 = 1, #_obj_0 do -- 2018
				local _value_0 = _obj_0[_index_0] -- 2018
				_tab_0[_idx_0] = _value_0 -- 2018
				_idx_0 = _idx_0 + 1 -- 2018
			end -- 2018
			return _tab_0 -- 1984
		end)() -- 1983
	} -- 1978
end) -- 1914
HttpServer:post("/entry/list", function() -- 2022
	local Entry = require("Script.Dev.Entry") -- 2023
	local res = Entry.getLaunchEntries() -- 2024
	res.success = true -- 2025
	return res -- 2026
end) -- 2022
HttpServer:post("/run/status", function() -- 2028
	local Entry = require("Script.Dev.Entry") -- 2029
	return Entry.getCurrentEntryStatus() -- 2030
end) -- 2028
HttpServer:postSchedule("/run", function(req) -- 2032
	do -- 2033
		local _type_0 = type(req) -- 2033
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2033
		if _tab_0 then -- 2033
			local file -- 2033
			do -- 2033
				local _obj_0 = req.body -- 2033
				local _type_1 = type(_obj_0) -- 2033
				if "table" == _type_1 or "userdata" == _type_1 then -- 2033
					file = _obj_0.file -- 2033
				end -- 2033
			end -- 2033
			local asProj -- 2033
			do -- 2033
				local _obj_0 = req.body -- 2033
				local _type_1 = type(_obj_0) -- 2033
				if "table" == _type_1 or "userdata" == _type_1 then -- 2033
					asProj = _obj_0.asProj -- 2033
				end -- 2033
			end -- 2033
			if file ~= nil and asProj ~= nil then -- 2033
				if not Content:isAbsolutePath(file) then -- 2034
					local devFile = Path(Content.writablePath, file) -- 2035
					if Content:exist(devFile) then -- 2036
						file = devFile -- 2036
					end -- 2036
				end -- 2034
				local Entry = require("Script.Dev.Entry") -- 2037
				local workDir -- 2038
				if asProj then -- 2039
					local projectRoot = req.body.projectRoot -- 2040
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2041
						workDir = projectRoot -- 2042
					else -- 2044
						workDir = getProjectDirFromFile(file) -- 2044
					end -- 2041
					if workDir then -- 2045
						Entry.allClear() -- 2046
						local target = Path(workDir, "init") -- 2047
						local success, err = Entry.enterEntryAsync({ -- 2048
							entryName = "Project", -- 2048
							fileName = target, -- 2048
							workDir = workDir, -- 2048
							projectRoot = workDir, -- 2048
							runKind = "project" -- 2048
						}) -- 2048
						target = Path:getName(Path:getPath(target)) -- 2049
						return { -- 2050
							success = success, -- 2050
							target = target, -- 2050
							err = err -- 2050
						} -- 2050
					end -- 2045
				else -- 2052
					workDir = getProjectDirFromFile(file) -- 2052
					if not workDir and Path:getExt(file) == "wasm" then -- 2053
						local parent = Path:getPath(file) -- 2054
						if Content:exist(Path(parent, "wa.mod")) then -- 2055
							workDir = parent -- 2056
						end -- 2055
					end -- 2053
				end -- 2039
				Entry.allClear() -- 2057
				file = Path:replaceExt(file, "") -- 2058
				local entry = { -- 2060
					entryName = Path:getName(file), -- 2060
					fileName = file, -- 2061
					runKind = "file" -- 2062
				} -- 2059
				if workDir then -- 2063
					entry.workDir = workDir -- 2064
					entry.projectRoot = workDir -- 2065
				end -- 2063
				local success, err = Entry.enterEntryAsync(entry) -- 2066
				return { -- 2067
					success = success, -- 2067
					err = err -- 2067
				} -- 2067
			end -- 2033
		end -- 2033
	end -- 2033
	return { -- 2032
		success = false -- 2032
	} -- 2032
end) -- 2032
HttpServer:postSchedule("/stop", function() -- 2069
	local Entry = require("Script.Dev.Entry") -- 2070
	return { -- 2071
		success = Entry.stop() -- 2071
	} -- 2071
end) -- 2069
local minifyAsync -- 2073
minifyAsync = function(sourcePath, minifyPath) -- 2073
	if not Content:exist(sourcePath) then -- 2074
		return -- 2074
	end -- 2074
	local Entry = require("Script.Dev.Entry") -- 2075
	local errors = { } -- 2076
	local files = Entry.getAllFiles(sourcePath, { -- 2077
		"lua" -- 2077
	}, true) -- 2077
	do -- 2078
		local _accum_0 = { } -- 2078
		local _len_0 = 1 -- 2078
		for _index_0 = 1, #files do -- 2078
			local file = files[_index_0] -- 2078
			if file:sub(1, 1) ~= '.' then -- 2078
				_accum_0[_len_0] = file -- 2078
				_len_0 = _len_0 + 1 -- 2078
			end -- 2078
		end -- 2078
		files = _accum_0 -- 2078
	end -- 2078
	local paths -- 2079
	do -- 2079
		local _tbl_0 = { } -- 2079
		for _index_0 = 1, #files do -- 2079
			local file = files[_index_0] -- 2079
			_tbl_0[Path:getPath(file)] = true -- 2079
		end -- 2079
		paths = _tbl_0 -- 2079
	end -- 2079
	for path in pairs(paths) do -- 2080
		Content:mkdir(Path(minifyPath, path)) -- 2080
	end -- 2080
	local _ <close> = setmetatable({ }, { -- 2081
		__close = function() -- 2081
			package.loaded["luaminify.FormatMini"] = nil -- 2082
			package.loaded["luaminify.ParseLua"] = nil -- 2083
			package.loaded["luaminify.Scope"] = nil -- 2084
			package.loaded["luaminify.Util"] = nil -- 2085
		end -- 2081
	}) -- 2081
	local FormatMini -- 2086
	do -- 2086
		local _obj_0 = require("luaminify") -- 2086
		FormatMini = _obj_0.FormatMini -- 2086
	end -- 2086
	local fileCount = #files -- 2087
	local count = 0 -- 2088
	for _index_0 = 1, #files do -- 2089
		local file = files[_index_0] -- 2089
		thread(function() -- 2090
			local _ <close> = setmetatable({ }, { -- 2091
				__close = function() -- 2091
					count = count + 1 -- 2091
				end -- 2091
			}) -- 2091
			local input = Path(sourcePath, file) -- 2092
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2093
			if Content:exist(input) then -- 2094
				local sourceCodes = Content:loadAsync(input) -- 2095
				local res, err = FormatMini(sourceCodes) -- 2096
				if res then -- 2097
					Content:saveAsync(output, res) -- 2098
					return print("Minify " .. tostring(file)) -- 2099
				else -- 2101
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2101
				end -- 2097
			else -- 2103
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2103
			end -- 2094
		end) -- 2090
		sleep() -- 2104
	end -- 2089
	wait(function() -- 2105
		return count == fileCount -- 2105
	end) -- 2105
	if #errors > 0 then -- 2106
		print(table.concat(errors, '\n')) -- 2107
	end -- 2106
	print("Obfuscation done.") -- 2108
	return files -- 2109
end -- 2073
local zipping = false -- 2111
HttpServer:postSchedule("/zip", function(req) -- 2113
	do -- 2114
		local _type_0 = type(req) -- 2114
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2114
		if _tab_0 then -- 2114
			local path -- 2114
			do -- 2114
				local _obj_0 = req.body -- 2114
				local _type_1 = type(_obj_0) -- 2114
				if "table" == _type_1 or "userdata" == _type_1 then -- 2114
					path = _obj_0.path -- 2114
				end -- 2114
			end -- 2114
			local zipFile -- 2114
			do -- 2114
				local _obj_0 = req.body -- 2114
				local _type_1 = type(_obj_0) -- 2114
				if "table" == _type_1 or "userdata" == _type_1 then -- 2114
					zipFile = _obj_0.zipFile -- 2114
				end -- 2114
			end -- 2114
			local obfuscated -- 2114
			do -- 2114
				local _obj_0 = req.body -- 2114
				local _type_1 = type(_obj_0) -- 2114
				if "table" == _type_1 or "userdata" == _type_1 then -- 2114
					obfuscated = _obj_0.obfuscated -- 2114
				end -- 2114
			end -- 2114
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2114
				if zipping then -- 2115
					goto failed -- 2115
				end -- 2115
				zipping = true -- 2116
				local _ <close> = setmetatable({ }, { -- 2117
					__close = function() -- 2117
						zipping = false -- 2117
					end -- 2117
				}) -- 2117
				if not Content:exist(path) then -- 2118
					goto failed -- 2118
				end -- 2118
				Content:mkdir(Path:getPath(zipFile)) -- 2119
				if obfuscated then -- 2120
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2121
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2122
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2123
					Content:remove(scriptPath) -- 2124
					Content:remove(obfuscatedPath) -- 2125
					Content:remove(tempPath) -- 2126
					Content:mkdir(scriptPath) -- 2127
					Content:mkdir(obfuscatedPath) -- 2128
					Content:mkdir(tempPath) -- 2129
					if not Content:copyAsync(path, tempPath) then -- 2130
						goto failed -- 2130
					end -- 2130
					local Entry = require("Script.Dev.Entry") -- 2131
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2132
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2133
						"tl", -- 2133
						"yue", -- 2133
						"lua", -- 2133
						"ts", -- 2133
						"tsx", -- 2133
						"vs", -- 2133
						"bl", -- 2133
						"xml", -- 2133
						"wa", -- 2133
						"mod" -- 2133
					}, true) -- 2133
					for _index_0 = 1, #scriptFiles do -- 2134
						local file = scriptFiles[_index_0] -- 2134
						Content:remove(Path(tempPath, file)) -- 2135
					end -- 2134
					for _index_0 = 1, #luaFiles do -- 2136
						local file = luaFiles[_index_0] -- 2136
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2137
					end -- 2136
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2138
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2139
					end) then -- 2138
						goto failed -- 2138
					end -- 2138
					return { -- 2140
						success = true -- 2140
					} -- 2140
				else -- 2142
					return { -- 2142
						success = Content:zipAsync(path, zipFile, function(file) -- 2142
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2143
						end) -- 2142
					} -- 2142
				end -- 2120
			end -- 2114
		end -- 2114
	end -- 2114
	::failed:: -- 2144
	return { -- 2113
		success = false -- 2113
	} -- 2113
end) -- 2113
HttpServer:postSchedule("/unzip", function(req) -- 2146
	do -- 2147
		local _type_0 = type(req) -- 2147
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2147
		if _tab_0 then -- 2147
			local zipFile -- 2147
			do -- 2147
				local _obj_0 = req.body -- 2147
				local _type_1 = type(_obj_0) -- 2147
				if "table" == _type_1 or "userdata" == _type_1 then -- 2147
					zipFile = _obj_0.zipFile -- 2147
				end -- 2147
			end -- 2147
			local path -- 2147
			do -- 2147
				local _obj_0 = req.body -- 2147
				local _type_1 = type(_obj_0) -- 2147
				if "table" == _type_1 or "userdata" == _type_1 then -- 2147
					path = _obj_0.path -- 2147
				end -- 2147
			end -- 2147
			if zipFile ~= nil and path ~= nil then -- 2147
				return { -- 2148
					success = Content:unzipAsync(zipFile, path, function(file) -- 2148
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2149
					end) -- 2148
				} -- 2148
			end -- 2147
		end -- 2147
	end -- 2147
	return { -- 2146
		success = false -- 2146
	} -- 2146
end) -- 2146
HttpServer:post("/editing-info", function(req) -- 2151
	local Entry = require("Script.Dev.Entry") -- 2152
	local config = Entry.getConfig() -- 2153
	local _type_0 = type(req) -- 2154
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2154
	local _match_0 = false -- 2154
	if _tab_0 then -- 2154
		local editingInfo -- 2154
		do -- 2154
			local _obj_0 = req.body -- 2154
			local _type_1 = type(_obj_0) -- 2154
			if "table" == _type_1 or "userdata" == _type_1 then -- 2154
				editingInfo = _obj_0.editingInfo -- 2154
			end -- 2154
		end -- 2154
		if editingInfo ~= nil then -- 2154
			_match_0 = true -- 2154
			config.editingInfo = editingInfo -- 2155
			return { -- 2156
				success = true -- 2156
			} -- 2156
		end -- 2154
	end -- 2154
	if not _match_0 then -- 2154
		if not (config.editingInfo ~= nil) then -- 2158
			local folder -- 2159
			if App.locale:match('^zh') then -- 2159
				folder = 'zh-Hans' -- 2159
			else -- 2159
				folder = 'en' -- 2159
			end -- 2159
			config.editingInfo = json.encode({ -- 2161
				index = 0, -- 2161
				files = { -- 2163
					{ -- 2164
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2164
						title = "welcome.md" -- 2165
					} -- 2163
				} -- 2162
			}) -- 2160
		end -- 2158
		return { -- 2169
			success = true, -- 2169
			editingInfo = config.editingInfo -- 2169
		} -- 2169
	end -- 2154
end) -- 2151
HttpServer:post("/command", function(req) -- 2171
	do -- 2172
		local _type_0 = type(req) -- 2172
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2172
		if _tab_0 then -- 2172
			local code -- 2172
			do -- 2172
				local _obj_0 = req.body -- 2172
				local _type_1 = type(_obj_0) -- 2172
				if "table" == _type_1 or "userdata" == _type_1 then -- 2172
					code = _obj_0.code -- 2172
				end -- 2172
			end -- 2172
			local log -- 2172
			do -- 2172
				local _obj_0 = req.body -- 2172
				local _type_1 = type(_obj_0) -- 2172
				if "table" == _type_1 or "userdata" == _type_1 then -- 2172
					log = _obj_0.log -- 2172
				end -- 2172
			end -- 2172
			if code ~= nil and log ~= nil then -- 2172
				emit("AppCommand", code, log) -- 2173
				return { -- 2174
					success = true -- 2174
				} -- 2174
			end -- 2172
		end -- 2172
	end -- 2172
	return { -- 2171
		success = false -- 2171
	} -- 2171
end) -- 2171
HttpServer:post("/log/save", function() -- 2176
	local folder = ".download" -- 2177
	local fullLogFile = "dora_full_logs.txt" -- 2178
	local fullFolder = Path(Content.writablePath, folder) -- 2179
	Content:mkdir(fullFolder) -- 2180
	local logPath = Path(fullFolder, fullLogFile) -- 2181
	if App:saveLog(logPath) then -- 2182
		return { -- 2183
			success = true, -- 2183
			path = Path(folder, fullLogFile) -- 2183
		} -- 2183
	end -- 2182
	return { -- 2176
		success = false -- 2176
	} -- 2176
end) -- 2176
local tailLines -- 2185
tailLines = function(text, count) -- 2185
	local lines = { } -- 2186
	text = text:gsub("\r\n", "\n") -- 2187
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2188
		lines[#lines + 1] = line -- 2189
	end -- 2188
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2190
		table.remove(lines) -- 2191
	end -- 2190
	local start = math.max(1, #lines - count + 1) -- 2192
	local out = { } -- 2193
	for i = start, #lines do -- 2194
		out[#out + 1] = lines[i] -- 2195
	end -- 2194
	return table.concat(out, "\n") -- 2196
end -- 2185
HttpServer:post("/log", function(req) -- 2198
	local count = 100 -- 2199
	if req and req.body and req.body.count ~= nil then -- 2200
		count = req.body.count -- 2201
	end -- 2200
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2202
		return { -- 2203
			success = false, -- 2203
			message = "count must be a positive integer" -- 2203
		} -- 2203
	end -- 2202
	local folder = ".download" -- 2204
	local fullLogFile = "dora_full_logs.txt" -- 2205
	local fullFolder = Path(Content.writablePath, folder) -- 2206
	Content:mkdir(fullFolder) -- 2207
	local logPath = Path(fullFolder, fullLogFile) -- 2208
	if App:saveLog(logPath) then -- 2209
		local text = Content:load(logPath) -- 2210
		if text then -- 2211
			return { -- 2212
				success = true, -- 2212
				log = tailLines(text, count) -- 2212
			} -- 2212
		else -- 2214
			return { -- 2214
				success = false, -- 2214
				message = "failed to read log" -- 2214
			} -- 2214
		end -- 2211
	else -- 2216
		return { -- 2216
			success = false, -- 2216
			message = "failed to save log" -- 2216
		} -- 2216
	end -- 2209
	return { -- 2198
		success = false -- 2198
	} -- 2198
end) -- 2198
HttpServer:post("/yarn/check", function(req) -- 2218
	local yarncompile = require("yarncompile") -- 2219
	do -- 2220
		local _type_0 = type(req) -- 2220
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2220
		if _tab_0 then -- 2220
			local code -- 2220
			do -- 2220
				local _obj_0 = req.body -- 2220
				local _type_1 = type(_obj_0) -- 2220
				if "table" == _type_1 or "userdata" == _type_1 then -- 2220
					code = _obj_0.code -- 2220
				end -- 2220
			end -- 2220
			if code ~= nil then -- 2220
				local jsonObject = json.decode(code) -- 2221
				if jsonObject then -- 2221
					local errors = { } -- 2222
					local _list_0 = jsonObject.nodes -- 2223
					for _index_0 = 1, #_list_0 do -- 2223
						local node = _list_0[_index_0] -- 2223
						local title, body = node.title, node.body -- 2224
						local luaCode, err = yarncompile(body) -- 2225
						if not luaCode then -- 2225
							errors[#errors + 1] = title .. ":" .. err -- 2226
						end -- 2225
					end -- 2223
					return { -- 2227
						success = true, -- 2227
						syntaxError = table.concat(errors, "\n\n") -- 2227
					} -- 2227
				end -- 2221
			end -- 2220
		end -- 2220
	end -- 2220
	return { -- 2218
		success = false -- 2218
	} -- 2218
end) -- 2218
HttpServer:post("/yarn/check-file", function(req) -- 2229
	local yarncompile = require("yarncompile") -- 2230
	do -- 2231
		local _type_0 = type(req) -- 2231
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2231
		if _tab_0 then -- 2231
			local code -- 2231
			do -- 2231
				local _obj_0 = req.body -- 2231
				local _type_1 = type(_obj_0) -- 2231
				if "table" == _type_1 or "userdata" == _type_1 then -- 2231
					code = _obj_0.code -- 2231
				end -- 2231
			end -- 2231
			if code ~= nil then -- 2231
				local res, _, err = yarncompile(code, true) -- 2232
				if not res then -- 2232
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2233
					return { -- 2234
						success = false, -- 2234
						message = message, -- 2234
						line = line, -- 2234
						column = column, -- 2234
						node = node -- 2234
					} -- 2234
				end -- 2232
			end -- 2231
		end -- 2231
	end -- 2231
	return { -- 2229
		success = true -- 2229
	} -- 2229
end) -- 2229
getWaProjectDirFromFile = function(file) -- 2236
	local current -- 2237
	if Content:isdir(file) then -- 2237
		current = file -- 2237
	else -- 2237
		current = Path:getPath(file) -- 2237
	end -- 2237
	if current == "" then -- 2238
		return nil -- 2238
	end -- 2238
	repeat -- 2239
		local modPath = Path(current, "wa.mod") -- 2240
		if Content:exist(modPath) then -- 2241
			return current, modPath -- 2242
		end -- 2241
		local parent = Path:getPath(current) -- 2243
		if parent == "" or parent == current then -- 2244
			break -- 2244
		end -- 2244
		current = parent -- 2245
	until false -- 2239
	return nil -- 2247
end -- 2236
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2249
	do -- 2250
		local _type_0 = type(req) -- 2250
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2250
		if _tab_0 then -- 2250
			local path -- 2250
			do -- 2250
				local _obj_0 = req.body -- 2250
				local _type_1 = type(_obj_0) -- 2250
				if "table" == _type_1 or "userdata" == _type_1 then -- 2250
					path = _obj_0.path -- 2250
				end -- 2250
			end -- 2250
			if path ~= nil then -- 2250
				local projDir = getWaProjectDirFromFile(path) -- 2251
				if projDir then -- 2251
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2252
					if not Content:exist(sourceDoraPath) then -- 2253
						return { -- 2254
							success = false, -- 2254
							message = "missing dora template" -- 2254
						} -- 2254
					end -- 2253
					local targetVendorPath = Path(projDir, "vendor") -- 2255
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2256
					if not Content:exist(targetVendorPath) then -- 2257
						if not Content:mkdir(targetVendorPath) then -- 2258
							return { -- 2259
								success = false, -- 2259
								message = "failed to create vendor folder" -- 2259
							} -- 2259
						end -- 2258
					elseif not Content:isdir(targetVendorPath) then -- 2260
						return { -- 2261
							success = false, -- 2261
							message = "vendor path is not a folder" -- 2261
						} -- 2261
					end -- 2257
					if Content:exist(targetDoraPath) then -- 2262
						if not Content:remove(targetDoraPath) then -- 2263
							return { -- 2264
								success = false, -- 2264
								message = "failed to remove old dora" -- 2264
							} -- 2264
						end -- 2263
					end -- 2262
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2265
						return { -- 2266
							success = false, -- 2266
							message = "failed to copy dora" -- 2266
						} -- 2266
					end -- 2265
					return { -- 2267
						success = true -- 2267
					} -- 2267
				else -- 2269
					return { -- 2269
						success = false, -- 2269
						message = 'Wa file needs a project' -- 2269
					} -- 2269
				end -- 2251
			end -- 2250
		end -- 2250
	end -- 2250
	return { -- 2249
		success = false, -- 2249
		message = "invalid call" -- 2249
	} -- 2249
end) -- 2249
HttpServer:postSchedule("/wa/build", function(req) -- 2271
	do -- 2272
		local _type_0 = type(req) -- 2272
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2272
		if _tab_0 then -- 2272
			local path -- 2272
			do -- 2272
				local _obj_0 = req.body -- 2272
				local _type_1 = type(_obj_0) -- 2272
				if "table" == _type_1 or "userdata" == _type_1 then -- 2272
					path = _obj_0.path -- 2272
				end -- 2272
			end -- 2272
			if path ~= nil then -- 2272
				local projDir = getWaProjectDirFromFile(path) -- 2273
				if projDir then -- 2273
					local message = Wasm:buildWaAsync(projDir) -- 2274
					if message == "" then -- 2275
						return { -- 2276
							success = true -- 2276
						} -- 2276
					else -- 2278
						return { -- 2278
							success = false, -- 2278
							message = message -- 2278
						} -- 2278
					end -- 2275
				else -- 2280
					return { -- 2280
						success = false, -- 2280
						message = 'Wa file needs a project' -- 2280
					} -- 2280
				end -- 2273
			end -- 2272
		end -- 2272
	end -- 2272
	return { -- 2281
		success = false, -- 2281
		message = 'failed to build' -- 2281
	} -- 2281
end) -- 2271
HttpServer:postSchedule("/wa/format", function(req) -- 2283
	do -- 2284
		local _type_0 = type(req) -- 2284
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2284
		if _tab_0 then -- 2284
			local file -- 2284
			do -- 2284
				local _obj_0 = req.body -- 2284
				local _type_1 = type(_obj_0) -- 2284
				if "table" == _type_1 or "userdata" == _type_1 then -- 2284
					file = _obj_0.file -- 2284
				end -- 2284
			end -- 2284
			if file ~= nil then -- 2284
				local code = Wasm:formatWaAsync(file) -- 2285
				if code == "" then -- 2286
					return { -- 2287
						success = false -- 2287
					} -- 2287
				else -- 2289
					return { -- 2289
						success = true, -- 2289
						code = code -- 2289
					} -- 2289
				end -- 2286
			end -- 2284
		end -- 2284
	end -- 2284
	return { -- 2290
		success = false -- 2290
	} -- 2290
end) -- 2283
HttpServer:postSchedule("/wa/create", function(req) -- 2292
	do -- 2293
		local _type_0 = type(req) -- 2293
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2293
		if _tab_0 then -- 2293
			local path -- 2293
			do -- 2293
				local _obj_0 = req.body -- 2293
				local _type_1 = type(_obj_0) -- 2293
				if "table" == _type_1 or "userdata" == _type_1 then -- 2293
					path = _obj_0.path -- 2293
				end -- 2293
			end -- 2293
			if path ~= nil then -- 2293
				if not Content:exist(Path:getPath(path)) then -- 2294
					return { -- 2295
						success = false, -- 2295
						message = "target path not existed" -- 2295
					} -- 2295
				end -- 2294
				if Content:exist(path) then -- 2296
					return { -- 2297
						success = false, -- 2297
						message = "target project folder existed" -- 2297
					} -- 2297
				end -- 2296
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2298
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2299
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2300
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2301
					return { -- 2304
						success = false, -- 2304
						message = "missing template project" -- 2304
					} -- 2304
				end -- 2301
				if not Content:mkdir(path) then -- 2305
					return { -- 2306
						success = false, -- 2306
						message = "failed to create project folder" -- 2306
					} -- 2306
				end -- 2305
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2307
					Content:remove(path) -- 2308
					return { -- 2309
						success = false, -- 2309
						message = "failed to copy template" -- 2309
					} -- 2309
				end -- 2307
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2310
					Content:remove(path) -- 2311
					return { -- 2312
						success = false, -- 2312
						message = "failed to copy template" -- 2312
					} -- 2312
				end -- 2310
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2313
					Content:remove(path) -- 2314
					return { -- 2315
						success = false, -- 2315
						message = "failed to copy template" -- 2315
					} -- 2315
				end -- 2313
				return { -- 2316
					success = true -- 2316
				} -- 2316
			end -- 2293
		end -- 2293
	end -- 2293
	return { -- 2292
		success = false, -- 2292
		message = "invalid call" -- 2292
	} -- 2292
end) -- 2292
local tsBuildGlobs = { -- 2319
	"**/*.ts", -- 2319
	"**/*.tsx", -- 2320
	"!**/.*/**", -- 2321
	"!**/node_modules/**" -- 2322
} -- 2318
local transpileTSFile -- 2324
do -- 2324
	local tsBuildTimeout <const> = 30 -- 2325
	local tsBuildRequestId = 0 -- 2326
	transpileTSFile = function(file, content, sourceRoot) -- 2327
		tsBuildRequestId = tsBuildRequestId + 1 -- 2328
		local requestId = tsBuildRequestId -- 2329
		local done = false -- 2330
		local result = nil -- 2331
		local listener = Node() -- 2332
		listener:gslot("AppWS", function(event) -- 2333
			if event.type == "Receive" then -- 2334
				local res = json.decode(event.msg) -- 2335
				if res then -- 2335
					if res.name == "TranspileTS" and res.id == requestId then -- 2336
						listener:removeFromParent() -- 2337
						if res.success then -- 2338
							local luaFile = Path:replaceExt(file, "lua") -- 2339
							Content:save(luaFile, res.luaCode) -- 2340
							result = { -- 2341
								success = true, -- 2341
								file = file -- 2341
							} -- 2341
						else -- 2343
							result = { -- 2343
								success = false, -- 2343
								file = file, -- 2343
								message = res.message -- 2343
							} -- 2343
						end -- 2338
						done = true -- 2344
					end -- 2336
				end -- 2335
			end -- 2334
		end) -- 2333
		emit("AppWS", "Send", json.encode({ -- 2345
			name = "TranspileTS", -- 2345
			id = requestId, -- 2345
			file = file, -- 2345
			content = content, -- 2345
			projectRoot = sourceRoot -- 2345
		})) -- 2345
		local deadline = App.runningTime + tsBuildTimeout -- 2346
		wait(function() -- 2347
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline -- 2347
		end) -- 2347
		if not done then -- 2348
			listener:removeFromParent() -- 2349
			if HttpServer.wsConnectionCount == 0 then -- 2350
				return { -- 2351
					success = false, -- 2351
					file = file, -- 2351
					message = "Web IDE disconnected" -- 2351
				} -- 2351
			end -- 2350
			return { -- 2352
				success = false, -- 2352
				file = file, -- 2352
				message = "TypeScript transpile timed out" -- 2352
			} -- 2352
		end -- 2348
		return result -- 2353
	end -- 2327
end -- 2324
local _anon_func_6 = function(path) -- 2364
	local _val_0 = Path:getExt(path) -- 2364
	return "ts" == _val_0 or "tsx" == _val_0 -- 2364
end -- 2364
HttpServer:postSchedule("/ts/build", function(req) -- 2355
	do -- 2356
		local _type_0 = type(req) -- 2356
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2356
		if _tab_0 then -- 2356
			local path -- 2356
			do -- 2356
				local _obj_0 = req.body -- 2356
				local _type_1 = type(_obj_0) -- 2356
				if "table" == _type_1 or "userdata" == _type_1 then -- 2356
					path = _obj_0.path -- 2356
				end -- 2356
			end -- 2356
			if path ~= nil then -- 2356
				if HttpServer.wsConnectionCount == 0 then -- 2357
					return { -- 2358
						success = false, -- 2358
						message = "Web IDE not connected" -- 2358
					} -- 2358
				end -- 2357
				local projectRoot = req.body.projectRoot -- 2359
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2360
				if not Content:exist(path) then -- 2361
					return { -- 2362
						success = false, -- 2362
						message = "path not existed" -- 2362
					} -- 2362
				end -- 2361
				if not Content:isdir(path) then -- 2363
					if not (_anon_func_6(path)) then -- 2364
						return { -- 2365
							success = false, -- 2365
							message = "expecting a TypeScript file" -- 2365
						} -- 2365
					end -- 2364
					local messages = { } -- 2366
					local content = Content:load(path) -- 2367
					if not content then -- 2368
						return { -- 2369
							success = false, -- 2369
							message = "failed to read file" -- 2369
						} -- 2369
					end -- 2368
					emit("AppWS", "Send", json.encode({ -- 2370
						name = "UpdateFile", -- 2370
						file = path, -- 2370
						exists = true, -- 2370
						content = content, -- 2370
						projectRoot = sourceRoot -- 2370
					})) -- 2370
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2371
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot) -- 2372
					end -- 2371
					return { -- 2373
						success = true, -- 2373
						messages = messages -- 2373
					} -- 2373
				else -- 2375
					local fileData = { } -- 2375
					local messages = { } -- 2376
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2377
					for _index_0 = 1, #_list_0 do -- 2377
						local subFile = _list_0[_index_0] -- 2377
						local file = Path(path, subFile) -- 2378
						local content = Content:load(file) -- 2379
						if content then -- 2379
							fileData[file] = content -- 2380
							emit("AppWS", "Send", json.encode({ -- 2381
								name = "UpdateFile", -- 2381
								file = file, -- 2381
								exists = true, -- 2381
								content = content, -- 2381
								projectRoot = sourceRoot -- 2381
							})) -- 2381
						else -- 2383
							messages[#messages + 1] = { -- 2383
								success = false, -- 2383
								file = file, -- 2383
								message = "failed to read file" -- 2383
							} -- 2383
						end -- 2379
					end -- 2377
					for file, content in pairs(fileData) do -- 2384
						if "d" == Path:getExt(Path:getName(file)) then -- 2385
							goto _continue_0 -- 2385
						end -- 2385
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot) -- 2386
						::_continue_0:: -- 2385
					end -- 2384
					return { -- 2387
						success = true, -- 2387
						messages = messages -- 2387
					} -- 2387
				end -- 2363
			end -- 2356
		end -- 2356
	end -- 2356
	return { -- 2355
		success = false -- 2355
	} -- 2355
end) -- 2355
HttpServer:post("/download", function(req) -- 2389
	do -- 2390
		local _type_0 = type(req) -- 2390
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2390
		if _tab_0 then -- 2390
			local url -- 2390
			do -- 2390
				local _obj_0 = req.body -- 2390
				local _type_1 = type(_obj_0) -- 2390
				if "table" == _type_1 or "userdata" == _type_1 then -- 2390
					url = _obj_0.url -- 2390
				end -- 2390
			end -- 2390
			local target -- 2390
			do -- 2390
				local _obj_0 = req.body -- 2390
				local _type_1 = type(_obj_0) -- 2390
				if "table" == _type_1 or "userdata" == _type_1 then -- 2390
					target = _obj_0.target -- 2390
				end -- 2390
			end -- 2390
			if url ~= nil and target ~= nil then -- 2390
				local Entry = require("Script.Dev.Entry") -- 2391
				Entry.downloadFile(url, target) -- 2392
				return { -- 2393
					success = true -- 2393
				} -- 2393
			end -- 2390
		end -- 2390
	end -- 2390
	return { -- 2389
		success = false -- 2389
	} -- 2389
end) -- 2389
local isDesktopPlatform -- 2395
isDesktopPlatform = function() -- 2395
	local _val_0 = App.platform -- 2396
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2396
end -- 2395
local getServerStatus -- 2398
getServerStatus = function() -- 2398
	local Entry = require("Script.Dev.Entry") -- 2399
	local running = Entry.getCurrentEntryStatus() -- 2400
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2401
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2402
	return { -- 2404
		success = true, -- 2404
		platform = App.platform, -- 2405
		locale = App.locale, -- 2406
		version = App.version, -- 2407
		url = "http://localhost:8866", -- 2408
		wsConnectionCount = wsConnectionCount, -- 2409
		webIDEConnected = wsConnectionCount > 0, -- 2410
		assetPath = Content.assetPath, -- 2411
		writablePath = Content.writablePath, -- 2412
		appPath = Content.appPath, -- 2413
		waTemplateReady = waTemplateReady, -- 2414
		running = running -- 2415
	} -- 2403
end -- 2398
HttpServer:post("/status", function() -- 2418
	return getServerStatus() -- 2419
end) -- 2418
HttpServer:postSchedule("/doctor/fix", function(req) -- 2421
	do -- 2422
		local _type_0 = type(req) -- 2422
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2422
		if _tab_0 then -- 2422
			local openWebIDE -- 2422
			do -- 2422
				local _obj_0 = req.body -- 2422
				local _type_1 = type(_obj_0) -- 2422
				if "table" == _type_1 or "userdata" == _type_1 then -- 2422
					openWebIDE = _obj_0.openWebIDE -- 2422
				end -- 2422
			end -- 2422
			if openWebIDE ~= nil then -- 2422
				if not openWebIDE then -- 2423
					return { -- 2424
						success = false, -- 2424
						message = "nothing to fix" -- 2424
					} -- 2424
				end -- 2423
				local status = getServerStatus() -- 2425
				if status.webIDEConnected then -- 2426
					return { -- 2427
						success = true, -- 2427
						fixed = false, -- 2427
						message = "Web IDE already connected.", -- 2427
						status = status -- 2427
					} -- 2427
				end -- 2426
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2428
				if waitSeconds > 0 then -- 2429
					local deadline = os.time() + waitSeconds -- 2430
					repeat -- 2431
						sleep(0.2) -- 2432
						status = getServerStatus() -- 2433
						if status.webIDEConnected then -- 2434
							return { -- 2435
								success = true, -- 2435
								fixed = false, -- 2435
								reconnected = true, -- 2435
								message = "Web IDE reconnected.", -- 2435
								status = status -- 2435
							} -- 2435
						end -- 2434
					until os.time() >= deadline -- 2431
				end -- 2429
				if not isDesktopPlatform() then -- 2437
					return { -- 2438
						success = false, -- 2438
						message = "opening Web IDE is only supported on desktop platforms", -- 2438
						status = status -- 2438
					} -- 2438
				end -- 2437
				local url = "http://localhost:8866" -- 2439
				App:openURL(url) -- 2440
				status.openedURL = url -- 2441
				return { -- 2442
					success = true, -- 2442
					fixed = true, -- 2442
					message = "Opened Web IDE in the local browser.", -- 2442
					url = url, -- 2442
					status = status -- 2442
				} -- 2442
			end -- 2422
		end -- 2422
	end -- 2422
	return { -- 2421
		success = false, -- 2421
		message = "invalid call" -- 2421
	} -- 2421
end) -- 2421
local status = { } -- 2444
_module_0 = status -- 2445
status.buildAsync = function(path) -- 2447
	if not Content:exist(path) then -- 2448
		return { -- 2449
			success = false, -- 2449
			file = path, -- 2449
			message = "file not existed" -- 2449
		} -- 2449
	end -- 2448
	do -- 2450
		local _exp_0 = Path:getExt(path) -- 2450
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2450
			if '' == Path:getExt(Path:getName(path)) then -- 2451
				local content = Content:loadAsync(path) -- 2452
				if content then -- 2452
					local resultCodes, err = compileFileAsync(path, content) -- 2453
					if resultCodes then -- 2453
						return { -- 2454
							success = true, -- 2454
							file = path -- 2454
						} -- 2454
					else -- 2456
						return { -- 2456
							success = false, -- 2456
							file = path, -- 2456
							message = err -- 2456
						} -- 2456
					end -- 2453
				end -- 2452
			end -- 2451
		elseif "lua" == _exp_0 then -- 2457
			local content = Content:loadAsync(path) -- 2458
			if content then -- 2458
				do -- 2459
					local isTIC80 = CheckTIC80Code(content) -- 2459
					if isTIC80 then -- 2459
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2460
					end -- 2459
				end -- 2459
				local success, info -- 2461
				do -- 2461
					local _obj_0 = luaCheck(path, content) -- 2461
					success, info = _obj_0.success, _obj_0.info -- 2461
				end -- 2461
				if success then -- 2462
					return { -- 2463
						success = true, -- 2463
						file = path -- 2463
					} -- 2463
				elseif info and #info > 0 then -- 2464
					local messages = { } -- 2465
					for _index_0 = 1, #info do -- 2466
						local _des_0 = info[_index_0] -- 2466
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2466
						local lineText = "" -- 2467
						if line then -- 2468
							local currentLine = 1 -- 2469
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2470
								if currentLine == line then -- 2471
									lineText = text -- 2472
									break -- 2473
								end -- 2471
								currentLine = currentLine + 1 -- 2474
							end -- 2470
						end -- 2468
						if line then -- 2475
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2476
						else -- 2478
							messages[#messages + 1] = message -- 2478
						end -- 2475
					end -- 2466
					return { -- 2479
						success = false, -- 2479
						file = path, -- 2479
						message = table.concat(messages, "\n") -- 2479
					} -- 2479
				else -- 2481
					return { -- 2481
						success = false, -- 2481
						file = path, -- 2481
						message = "lua check failed" -- 2481
					} -- 2481
				end -- 2462
			end -- 2458
		elseif "yarn" == _exp_0 then -- 2482
			local content = Content:loadAsync(path) -- 2483
			if content then -- 2483
				local res, _, err = yarncompile(content, true) -- 2484
				if res then -- 2484
					return { -- 2485
						success = true, -- 2485
						file = path -- 2485
					} -- 2485
				else -- 2487
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2487
					local lineText = "" -- 2488
					if line then -- 2489
						local currentLine = 1 -- 2490
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2491
							if currentLine == line then -- 2492
								lineText = text -- 2493
								break -- 2494
							end -- 2492
							currentLine = currentLine + 1 -- 2495
						end -- 2491
					end -- 2489
					if node ~= "" then -- 2496
						node = "node: " .. tostring(node) .. ", " -- 2497
					else -- 2498
						node = "" -- 2498
					end -- 2496
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2499
					return { -- 2500
						success = false, -- 2500
						file = path, -- 2500
						message = message -- 2500
					} -- 2500
				end -- 2484
			end -- 2483
		end -- 2450
	end -- 2450
	return { -- 2501
		success = false, -- 2501
		file = path, -- 2501
		message = "invalid file to build" -- 2501
	} -- 2501
end -- 2447
thread(function() -- 2503
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 2504
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 2505
	if Content:exist(doraWeb) then -- 2506
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) -- 2507
		local needReload -- 2508
		if Content:exist(doraReady) then -- 2508
			needReload = readyContent ~= Content:load(doraReady) -- 2509
		else -- 2510
			needReload = true -- 2510
		end -- 2508
		if needReload then -- 2511
			Content:remove(Path(Content.appPath, ".www")) -- 2512
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 2513
			Content:save(doraReady, readyContent) -- 2517
			print("Dora Dora is ready!") -- 2518
		end -- 2511
	end -- 2506
	if HttpServer:start(8866) then -- 2519
		local localIP = HttpServer.localIP -- 2520
		if localIP == "" then -- 2521
			localIP = "localhost" -- 2521
		end -- 2521
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 2522
		return HttpServer:startWS(8868) -- 2523
	else -- 2525
		status.url = nil -- 2525
		return print("8866 Port not available!") -- 2526
	end -- 2519
end) -- 2503
return _module_0 -- 1
