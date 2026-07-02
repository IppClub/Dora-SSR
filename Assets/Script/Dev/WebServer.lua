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
		local _accum_0 = { } -- 684
		local _len_0 = 1 -- 684
		for _index_0 = 1, #rows do -- 684
			local row = rows[_index_0] -- 684
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 684
			_len_0 = _len_0 + 1 -- 684
		end -- 684
		items = _accum_0 -- 684
	else -- 685
		items = { } -- 685
	end -- 683
	return { -- 686
		success = true, -- 686
		items = items -- 686
	} -- 686
end) -- 674
HttpServer:postSchedule("/git/auth/match", function(req) -- 688
	do -- 689
		local _type_0 = type(req) -- 689
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 689
		local _match_0 = false -- 689
		if _tab_0 then -- 689
			local body = req.body -- 689
			if body ~= nil then -- 689
				_match_0 = true -- 689
				local repoPath, command, url = body.repoPath, body.command, body.url -- 690
				local host -- 691
				if url and url ~= "" then -- 691
					host = gitHostFromURL(url) -- 691
				else -- 691
					host = gitCommandHost(repoPath, command) -- 691
				end -- 691
				if not host then -- 692
					return { -- 692
						success = false, -- 692
						message = "git host is required" -- 692
					} -- 692
				end -- 692
				local items = gitCredentialsForHost(host) -- 693
				return { -- 694
					success = true, -- 694
					host = host, -- 694
					items = items, -- 694
					needsSelection = #items > 1, -- 694
					authId = (#items == 1 and items[1].id or nil) -- 694
				} -- 694
			end -- 689
		end -- 689
		if not _match_0 then -- 689
			return { -- 696
				success = false, -- 696
				message = "invalid arguments" -- 696
			} -- 696
		end -- 689
	end -- 689
	return invalidArguments -- 688
end) -- 688
HttpServer:post("/git/auth/save", function(req) -- 698
	do -- 699
		local _type_0 = type(req) -- 699
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 699
		if _tab_0 then -- 699
			local body = req.body -- 699
			if body ~= nil then -- 699
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token -- 700
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$") -- 701
				label = tostring(label or ""):match("^%s*(.-)%s*$") -- 702
				local credentialType = tostring(body.type or "token") -- 703
				username = tostring(username or "") -- 704
				local secret -- 705
				if credentialType == "basic" then -- 705
					secret = tostring(password or "") -- 705
				else -- 705
					secret = tostring(token or password or "") -- 705
				end -- 705
				if host == "" then -- 706
					return { -- 706
						success = false, -- 706
						message = "host is required" -- 706
					} -- 706
				end -- 706
				if label == "" then -- 707
					return { -- 707
						success = false, -- 707
						message = "label is required" -- 707
					} -- 707
				end -- 707
				if secret == "" then -- 708
					return { -- 708
						success = false, -- 708
						message = "secret is required" -- 708
					} -- 708
				end -- 708
				if not (("basic" == credentialType or "token" == credentialType)) then -- 709
					return { -- 709
						success = false, -- 709
						message = "invalid type" -- 709
					} -- 709
				end -- 709
				ensureGitTables() -- 710
				local now = os.time() -- 711
				if id then -- 712
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", { -- 714
						host, -- 714
						label, -- 714
						credentialType, -- 714
						username, -- 714
						secret, -- 714
						now, -- 714
						(tonumber(id) or 0) -- 714
					}) -- 713
					return { -- 716
						success = true, -- 716
						id = tonumber(id) -- 716
					} -- 716
				else -- 718
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", { -- 719
						host, -- 719
						label, -- 719
						credentialType, -- 719
						username, -- 719
						secret, -- 719
						now, -- 719
						now -- 719
					}) -- 718
					local rows = DB:query("select last_insert_rowid()") -- 721
					return { -- 722
						success = true, -- 722
						id = rows and rows[1] and rows[1][1] -- 722
					} -- 722
				end -- 712
			end -- 699
		end -- 699
	end -- 699
	return invalidArguments -- 698
end) -- 698
HttpServer:post("/git/auth/delete", function(req) -- 724
	do -- 725
		local _type_0 = type(req) -- 725
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 725
		if _tab_0 then -- 725
			local id -- 725
			do -- 725
				local _obj_0 = req.body -- 725
				local _type_1 = type(_obj_0) -- 725
				if "table" == _type_1 or "userdata" == _type_1 then -- 725
					id = _obj_0.id -- 725
				end -- 725
			end -- 725
			if id ~= nil then -- 725
				ensureGitTables() -- 726
				local credentialId = tonumber(id) or 0 -- 727
				DB:exec("delete from GitCredential where id = ?", { -- 728
					credentialId -- 728
				}) -- 728
				return { -- 729
					success = true -- 729
				} -- 729
			end -- 725
		end -- 725
	end -- 725
	return invalidArguments -- 724
end) -- 724
HttpServer:postSchedule("/git/auth/test", function(req) -- 731
	do -- 732
		local _type_0 = type(req) -- 732
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 732
		if _tab_0 then -- 732
			local body = req.body -- 732
			if body ~= nil then -- 732
				local repoPath, url, authId = body.repoPath, body.url, body.authId -- 733
				local credential = gitLoadCredential(authId) -- 734
				local optionsJSON = gitAuthOptionsJSON(credential) -- 735
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20) -- 736
			end -- 732
		end -- 732
	end -- 732
	return invalidArguments -- 731
end) -- 731
HttpServer:post("/agent/session/create", function(req) -- 738
	do -- 739
		local _type_0 = type(req) -- 739
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 739
		if _tab_0 then -- 739
			local projectRoot -- 739
			do -- 739
				local _obj_0 = req.body -- 739
				local _type_1 = type(_obj_0) -- 739
				if "table" == _type_1 or "userdata" == _type_1 then -- 739
					projectRoot = _obj_0.projectRoot -- 739
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
			if projectRoot ~= nil and title ~= nil then -- 739
				return AgentSession.createSession(projectRoot, title) -- 740
			end -- 739
		end -- 739
	end -- 739
	return invalidArguments -- 738
end) -- 738
HttpServer:post("/agent/session/create-sub", function(req) -- 742
	do -- 743
		local _type_0 = type(req) -- 743
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 743
		if _tab_0 then -- 743
			local parentSessionId -- 743
			do -- 743
				local _obj_0 = req.body -- 743
				local _type_1 = type(_obj_0) -- 743
				if "table" == _type_1 or "userdata" == _type_1 then -- 743
					parentSessionId = _obj_0.parentSessionId -- 743
				end -- 743
			end -- 743
			local title -- 743
			do -- 743
				local _obj_0 = req.body -- 743
				local _type_1 = type(_obj_0) -- 743
				if "table" == _type_1 or "userdata" == _type_1 then -- 743
					title = _obj_0.title -- 743
				end -- 743
			end -- 743
			if parentSessionId ~= nil and title ~= nil then -- 743
				return AgentSession.createSubSession(parentSessionId, title) -- 744
			end -- 743
		end -- 743
	end -- 743
	return invalidArguments -- 742
end) -- 742
HttpServer:post("/agent/session/get", function(req) -- 746
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
			if sessionId ~= nil then -- 747
				return AgentSession.getSession(sessionId) -- 748
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
				return AgentSession.sendPrompt(sessionId, prompt, false, req.body.disabledAgentTools) -- 752
			end -- 751
		end -- 751
	end -- 751
	return invalidArguments -- 750
end) -- 750
HttpServer:post("/agent/session/resend", function(req) -- 754
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
			local messageId -- 755
			do -- 755
				local _obj_0 = req.body -- 755
				local _type_1 = type(_obj_0) -- 755
				if "table" == _type_1 or "userdata" == _type_1 then -- 755
					messageId = _obj_0.messageId -- 755
				end -- 755
			end -- 755
			local prompt -- 755
			do -- 755
				local _obj_0 = req.body -- 755
				local _type_1 = type(_obj_0) -- 755
				if "table" == _type_1 or "userdata" == _type_1 then -- 755
					prompt = _obj_0.prompt -- 755
				end -- 755
			end -- 755
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 755
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools) -- 756
			end -- 755
		end -- 755
	end -- 755
	return invalidArguments -- 754
end) -- 754
HttpServer:post("/agent/task/status", function(req) -- 758
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
				local res = AgentSession.getSession(sessionId) -- 760
				if not res.success then -- 761
					return res -- 761
				end -- 761
				local taskId = res.session.currentTaskId -- 762
				local checkpoints -- 763
				if taskId then -- 763
					checkpoints = AgentTools.listCheckpoints(taskId) -- 763
				else -- 763
					checkpoints = { } -- 763
				end -- 763
				return { -- 765
					success = true, -- 765
					session = res.session, -- 766
					relatedSessions = res.relatedSessions, -- 767
					spawnInfo = res.spawnInfo, -- 768
					messages = res.messages, -- 769
					steps = res.steps, -- 770
					checkpoints = checkpoints -- 771
				} -- 764
			end -- 759
		end -- 759
	end -- 759
	return invalidArguments -- 758
end) -- 758
HttpServer:post("/agent/task/running", function() -- 773
	local res = AgentSession.listRunningSessions() -- 774
	if res.success and #res.sessions == 0 then -- 775
		res.sessions = nil -- 776
	end -- 775
	return res -- 777
end) -- 773
HttpServer:post("/agent/task/stop", function(req) -- 779
	do -- 780
		local _type_0 = type(req) -- 780
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 780
		if _tab_0 then -- 780
			local sessionId -- 780
			do -- 780
				local _obj_0 = req.body -- 780
				local _type_1 = type(_obj_0) -- 780
				if "table" == _type_1 or "userdata" == _type_1 then -- 780
					sessionId = _obj_0.sessionId -- 780
				end -- 780
			end -- 780
			if sessionId ~= nil then -- 780
				return AgentSession.stopSessionTask(sessionId) -- 781
			end -- 780
		end -- 780
	end -- 780
	return invalidArguments -- 779
end) -- 779
HttpServer:post("/agent/checkpoint/list", function(req) -- 783
	do -- 784
		local _type_0 = type(req) -- 784
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 784
		if _tab_0 then -- 784
			local taskId -- 784
			do -- 784
				local _obj_0 = req.body -- 784
				local _type_1 = type(_obj_0) -- 784
				if "table" == _type_1 or "userdata" == _type_1 then -- 784
					taskId = _obj_0.taskId -- 784
				end -- 784
			end -- 784
			local sessionId -- 784
			do -- 784
				local _obj_0 = req.body -- 784
				local _type_1 = type(_obj_0) -- 784
				if "table" == _type_1 or "userdata" == _type_1 then -- 784
					sessionId = _obj_0.sessionId -- 784
				end -- 784
			end -- 784
			if sessionId ~= nil then -- 784
				if not taskId and sessionId then -- 785
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 786
				end -- 785
				if not taskId then -- 787
					return { -- 787
						success = false, -- 787
						message = "task not found" -- 787
					} -- 787
				end -- 787
				return { -- 789
					success = true, -- 789
					taskId = taskId, -- 790
					checkpoints = AgentTools.listCheckpoints(taskId) -- 791
				} -- 788
			end -- 784
		end -- 784
	end -- 784
	return invalidArguments -- 783
end) -- 783
HttpServer:post("/agent/checkpoint/diff", function(req) -- 793
	do -- 794
		local _type_0 = type(req) -- 794
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 794
		if _tab_0 then -- 794
			local checkpointId -- 794
			do -- 794
				local _obj_0 = req.body -- 794
				local _type_1 = type(_obj_0) -- 794
				if "table" == _type_1 or "userdata" == _type_1 then -- 794
					checkpointId = _obj_0.checkpointId -- 794
				end -- 794
			end -- 794
			if checkpointId ~= nil then -- 794
				if not (checkpointId > 0) then -- 795
					return { -- 795
						success = false, -- 795
						message = "invalid checkpointId" -- 795
					} -- 795
				end -- 795
				return AgentTools.getCheckpointDiff(checkpointId) -- 796
			end -- 794
		end -- 794
	end -- 794
	return invalidArguments -- 793
end) -- 793
HttpServer:post("/agent/task/diff", function(req) -- 798
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
			if taskId ~= nil then -- 799
				if not (taskId > 0) then -- 800
					return { -- 800
						success = false, -- 800
						message = "invalid taskId" -- 800
					} -- 800
				end -- 800
				return AgentTools.getTaskChangeSetDiff(taskId) -- 801
			end -- 799
		end -- 799
	end -- 799
	return invalidArguments -- 798
end) -- 798
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 803
	do -- 804
		local _type_0 = type(req) -- 804
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 804
		if _tab_0 then -- 804
			local sessionId -- 804
			do -- 804
				local _obj_0 = req.body -- 804
				local _type_1 = type(_obj_0) -- 804
				if "table" == _type_1 or "userdata" == _type_1 then -- 804
					sessionId = _obj_0.sessionId -- 804
				end -- 804
			end -- 804
			local checkpointId -- 804
			do -- 804
				local _obj_0 = req.body -- 804
				local _type_1 = type(_obj_0) -- 804
				if "table" == _type_1 or "userdata" == _type_1 then -- 804
					checkpointId = _obj_0.checkpointId -- 804
				end -- 804
			end -- 804
			if sessionId ~= nil and checkpointId ~= nil then -- 804
				if not (checkpointId > 0) then -- 805
					return { -- 805
						success = false, -- 805
						message = "invalid checkpointId" -- 805
					} -- 805
				end -- 805
				local res = AgentSession.getSession(sessionId) -- 806
				if not res.success then -- 807
					return res -- 807
				end -- 807
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, res.session.projectRoot) -- 808
				if not rollbackRes.success then -- 809
					return rollbackRes -- 809
				end -- 809
				return { -- 811
					success = true, -- 811
					checkpointId = rollbackRes.checkpointId -- 812
				} -- 810
			end -- 804
		end -- 804
	end -- 804
	return invalidArguments -- 803
end) -- 803
HttpServer:post("/agent/task/rollback", function(req) -- 814
	do -- 815
		local _type_0 = type(req) -- 815
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 815
		if _tab_0 then -- 815
			local sessionId -- 815
			do -- 815
				local _obj_0 = req.body -- 815
				local _type_1 = type(_obj_0) -- 815
				if "table" == _type_1 or "userdata" == _type_1 then -- 815
					sessionId = _obj_0.sessionId -- 815
				end -- 815
			end -- 815
			local taskId -- 815
			do -- 815
				local _obj_0 = req.body -- 815
				local _type_1 = type(_obj_0) -- 815
				if "table" == _type_1 or "userdata" == _type_1 then -- 815
					taskId = _obj_0.taskId -- 815
				end -- 815
			end -- 815
			if sessionId ~= nil and taskId ~= nil then -- 815
				if not (taskId > 0) then -- 816
					return { -- 816
						success = false, -- 816
						message = "invalid taskId" -- 816
					} -- 816
				end -- 816
				local res = AgentSession.getSession(sessionId) -- 817
				if not res.success then -- 818
					return res -- 818
				end -- 818
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, res.session.projectRoot) -- 819
				if not rollbackRes.success then -- 820
					return rollbackRes -- 820
				end -- 820
				return { -- 822
					success = true, -- 822
					taskId = rollbackRes.taskId, -- 823
					checkpointId = rollbackRes.checkpointId, -- 824
					checkpointCount = rollbackRes.checkpointCount -- 825
				} -- 821
			end -- 815
		end -- 815
	end -- 815
	return invalidArguments -- 814
end) -- 814
local getSearchPath -- 827
getSearchPath = function(file) -- 827
	do -- 828
		local dir = getProjectDirFromFile(file) -- 828
		if dir then -- 828
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 829
		end -- 828
	end -- 828
	return "" -- 827
end -- 827
local getSearchFolders -- 831
getSearchFolders = function(file) -- 831
	do -- 832
		local dir = getProjectDirFromFile(file) -- 832
		if dir then -- 832
			return { -- 834
				Path(dir, "Script"), -- 834
				dir -- 835
			} -- 833
		end -- 832
	end -- 832
	return { } -- 831
end -- 831
local disabledCheckForLua = { -- 838
	"incompatible number of returns", -- 838
	"unknown", -- 839
	"cannot index", -- 840
	"module not found", -- 841
	"don't know how to resolve", -- 842
	"ContainerItem", -- 843
	"cannot resolve a type", -- 844
	"invalid key", -- 845
	"inconsistent index type", -- 846
	"cannot use operator", -- 847
	"attempting ipairs loop", -- 848
	"expects record or nominal", -- 849
	"variable is not being assigned", -- 850
	"<invalid type>", -- 851
	"<any type>", -- 852
	"using the '#' operator", -- 853
	"can't match a record", -- 854
	"redeclaration of variable", -- 855
	"cannot apply pairs", -- 856
	"not a function", -- 857
	"to%-be%-closed" -- 858
} -- 837
local yueCheck -- 860
yueCheck = function(file, content, lax) -- 860
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 861
	if isTIC80 then -- 862
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 863
	end -- 862
	local searchPath = getSearchPath(file) -- 864
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 865
	local info = { } -- 866
	local globals = { } -- 867
	for _index_0 = 1, #checkResult do -- 868
		local _des_0 = checkResult[_index_0] -- 868
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 868
		if "error" == t then -- 869
			info[#info + 1] = { -- 870
				"syntax", -- 870
				file, -- 870
				line, -- 870
				col, -- 870
				msg -- 870
			} -- 870
		elseif "global" == t then -- 871
			globals[#globals + 1] = { -- 872
				msg, -- 872
				line, -- 872
				col -- 872
			} -- 872
		end -- 869
	end -- 868
	if luaCodes then -- 873
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 874
		if success then -- 875
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 876
			if not (lintResult == "") then -- 877
				lintResult = lintResult .. "\n" -- 877
			end -- 877
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 878
		else -- 879
			for _index_0 = 1, #lintResult do -- 879
				local _des_0 = lintResult[_index_0] -- 879
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 879
				if isTIC80 and tic80APIs[name] then -- 880
					goto _continue_0 -- 880
				end -- 880
				info[#info + 1] = { -- 881
					"syntax", -- 881
					file, -- 881
					line, -- 881
					col, -- 881
					"invalid global variable" -- 881
				} -- 881
				::_continue_0:: -- 880
			end -- 879
		end -- 875
	end -- 873
	return luaCodes, info -- 882
end -- 860
local luaCheck -- 884
luaCheck = function(file, content) -- 884
	local res, err = load(content, "check") -- 885
	if not res then -- 886
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 887
		return { -- 888
			success = false, -- 888
			info = { -- 888
				{ -- 888
					"syntax", -- 888
					file, -- 888
					tonumber(line), -- 888
					0, -- 888
					msg -- 888
				} -- 888
			} -- 888
		} -- 888
	end -- 886
	local success, info = teal.checkAsync(content, file, true, "") -- 889
	if info then -- 890
		do -- 891
			local _accum_0 = { } -- 891
			local _len_0 = 1 -- 891
			for _index_0 = 1, #info do -- 891
				local item = info[_index_0] -- 891
				local useCheck = true -- 892
				if not item[5]:match("unused") then -- 893
					for _index_1 = 1, #disabledCheckForLua do -- 894
						local check = disabledCheckForLua[_index_1] -- 894
						if item[5]:match(check) then -- 895
							useCheck = false -- 896
						end -- 895
					end -- 894
				end -- 893
				if not useCheck then -- 897
					goto _continue_0 -- 897
				end -- 897
				do -- 898
					local _exp_0 = item[1] -- 898
					if "type" == _exp_0 then -- 899
						item[1] = "warning" -- 900
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 901
						goto _continue_0 -- 902
					end -- 898
				end -- 898
				_accum_0[_len_0] = item -- 903
				_len_0 = _len_0 + 1 -- 892
				::_continue_0:: -- 892
			end -- 891
			info = _accum_0 -- 891
		end -- 891
		if #info == 0 then -- 904
			info = nil -- 905
			success = true -- 906
		end -- 904
	end -- 890
	return { -- 907
		success = success, -- 907
		info = info -- 907
	} -- 907
end -- 884
local luaCheckWithLineInfo -- 909
luaCheckWithLineInfo = function(file, luaCodes) -- 909
	local res = luaCheck(file, luaCodes) -- 910
	local info = { } -- 911
	if not res.success then -- 912
		local current = 1 -- 913
		local lastLine = 1 -- 914
		local lineMap = { } -- 915
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 916
			local num = lineCode:match("--%s*(%d+)%s*$") -- 917
			if num then -- 918
				lastLine = tonumber(num) -- 919
			end -- 918
			lineMap[current] = lastLine -- 920
			current = current + 1 -- 921
		end -- 916
		local _list_0 = res.info -- 922
		for _index_0 = 1, #_list_0 do -- 922
			local item = _list_0[_index_0] -- 922
			item[3] = lineMap[item[3]] or 0 -- 923
			item[4] = 0 -- 924
			info[#info + 1] = item -- 925
		end -- 922
		return false, info -- 926
	end -- 912
	return true, info -- 927
end -- 909
local getCompiledYueLine -- 929
getCompiledYueLine = function(content, line, row, file, lax) -- 929
	local luaCodes = yueCheck(file, content, lax) -- 930
	if not luaCodes then -- 931
		return nil -- 931
	end -- 931
	local current = 1 -- 932
	local lastLine = 1 -- 933
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 934
	local targetRow = nil -- 935
	local lineMap = { } -- 936
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 937
		local num = lineCode:match("--%s*(%d+)%s*$") -- 938
		if num then -- 939
			lastLine = tonumber(num) -- 939
		end -- 939
		lineMap[current] = lastLine -- 940
		if row <= lastLine and not targetRow then -- 941
			targetRow = current -- 942
			break -- 943
		end -- 941
		current = current + 1 -- 944
	end -- 937
	targetRow = current -- 945
	if targetLine and targetRow then -- 946
		return luaCodes, targetLine, targetRow, lineMap -- 947
	else -- 949
		return nil -- 949
	end -- 946
end -- 929
HttpServer:postSchedule("/check", function(req) -- 951
	do -- 952
		local _type_0 = type(req) -- 952
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 952
		if _tab_0 then -- 952
			local file -- 952
			do -- 952
				local _obj_0 = req.body -- 952
				local _type_1 = type(_obj_0) -- 952
				if "table" == _type_1 or "userdata" == _type_1 then -- 952
					file = _obj_0.file -- 952
				end -- 952
			end -- 952
			local content -- 952
			do -- 952
				local _obj_0 = req.body -- 952
				local _type_1 = type(_obj_0) -- 952
				if "table" == _type_1 or "userdata" == _type_1 then -- 952
					content = _obj_0.content -- 952
				end -- 952
			end -- 952
			if file ~= nil and content ~= nil then -- 952
				local ext = Path:getExt(file) -- 953
				if "tl" == ext then -- 954
					local searchPath = getSearchPath(file) -- 955
					do -- 956
						local isTIC80 = CheckTIC80Code(content) -- 956
						if isTIC80 then -- 956
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 957
						end -- 956
					end -- 956
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 958
					return { -- 959
						success = success, -- 959
						info = info -- 959
					} -- 959
				elseif "lua" == ext then -- 960
					do -- 961
						local isTIC80 = CheckTIC80Code(content) -- 961
						if isTIC80 then -- 961
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 962
						end -- 961
					end -- 961
					return luaCheck(file, content) -- 963
				elseif "yue" == ext then -- 964
					local luaCodes, info = yueCheck(file, content, false) -- 965
					local success = false -- 966
					if luaCodes then -- 967
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 968
						do -- 969
							local _tab_1 = { } -- 969
							local _idx_0 = #_tab_1 + 1 -- 969
							for _index_0 = 1, #info do -- 969
								local _value_0 = info[_index_0] -- 969
								_tab_1[_idx_0] = _value_0 -- 969
								_idx_0 = _idx_0 + 1 -- 969
							end -- 969
							local _idx_1 = #_tab_1 + 1 -- 969
							for _index_0 = 1, #luaInfo do -- 969
								local _value_0 = luaInfo[_index_0] -- 969
								_tab_1[_idx_1] = _value_0 -- 969
								_idx_1 = _idx_1 + 1 -- 969
							end -- 969
							info = _tab_1 -- 969
						end -- 969
						success = success and luaSuccess -- 970
					end -- 967
					if #info > 0 then -- 971
						return { -- 972
							success = success, -- 972
							info = info -- 972
						} -- 972
					else -- 974
						return { -- 974
							success = success -- 974
						} -- 974
					end -- 971
				elseif "xml" == ext then -- 975
					local success, result = xml.check(content) -- 976
					if success then -- 977
						local info -- 978
						success, info = luaCheckWithLineInfo(file, result) -- 978
						if #info > 0 then -- 979
							return { -- 980
								success = success, -- 980
								info = info -- 980
							} -- 980
						else -- 982
							return { -- 982
								success = success -- 982
							} -- 982
						end -- 979
					else -- 984
						local info -- 984
						do -- 984
							local _accum_0 = { } -- 984
							local _len_0 = 1 -- 984
							for _index_0 = 1, #result do -- 984
								local _des_0 = result[_index_0] -- 984
								local row, err = _des_0[1], _des_0[2] -- 984
								_accum_0[_len_0] = { -- 985
									"syntax", -- 985
									file, -- 985
									row, -- 985
									0, -- 985
									err -- 985
								} -- 985
								_len_0 = _len_0 + 1 -- 985
							end -- 984
							info = _accum_0 -- 984
						end -- 984
						return { -- 986
							success = false, -- 986
							info = info -- 986
						} -- 986
					end -- 977
				end -- 954
			end -- 952
		end -- 952
	end -- 952
	return { -- 951
		success = true -- 951
	} -- 951
end) -- 951
HttpServer:post("/body/parse", function(req) -- 988
	do -- 989
		local _type_0 = type(req) -- 989
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 989
		if _tab_0 then -- 989
			local file -- 989
			do -- 989
				local _obj_0 = req.body -- 989
				local _type_1 = type(_obj_0) -- 989
				if "table" == _type_1 or "userdata" == _type_1 then -- 989
					file = _obj_0.file -- 989
				end -- 989
			end -- 989
			local content -- 989
			do -- 989
				local _obj_0 = req.body -- 989
				local _type_1 = type(_obj_0) -- 989
				if "table" == _type_1 or "userdata" == _type_1 then -- 989
					content = _obj_0.content -- 989
				end -- 989
			end -- 989
			if file ~= nil and content ~= nil then -- 989
				if not (file:sub(-6) == ".b.lua") then -- 990
					return { -- 991
						success = false, -- 991
						phase = "request", -- 991
						message = "only .b.lua files can be converted" -- 991
					} -- 991
				end -- 990
				local loader, err = load("_ENV = {}\n" .. content) -- 992
				if not loader then -- 993
					return { -- 994
						success = false, -- 994
						phase = "parse", -- 994
						message = tostring(err) -- 994
					} -- 994
				end -- 993
				local ok, data = pcall(loader) -- 995
				if not ok then -- 996
					return { -- 997
						success = false, -- 997
						phase = "execute", -- 997
						message = tostring(data) -- 997
					} -- 997
				end -- 996
				if not ("table" == type(data) and data[1] == "Array") then -- 998
					return { -- 999
						success = false, -- 999
						phase = "validate", -- 999
						message = "body lua root must be {\"Array\", ...}" -- 999
					} -- 999
				end -- 998
				local text, jsonErr = json.encode(data, false, true) -- 1000
				if not text then -- 1001
					return { -- 1002
						success = false, -- 1002
						phase = "encode", -- 1002
						message = tostring(jsonErr) -- 1002
					} -- 1002
				end -- 1001
				return { -- 1003
					success = true, -- 1003
					json = text -- 1003
				} -- 1003
			end -- 989
		end -- 989
	end -- 989
	return { -- 988
		success = false, -- 988
		phase = "request", -- 988
		message = "invalid request" -- 988
	} -- 988
end) -- 988
local updateInferedDesc -- 1005
updateInferedDesc = function(infered) -- 1005
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1006
		return -- 1006
	end -- 1006
	local key, row = infered.key, infered.row -- 1007
	local codes = Content:loadAsync(key) -- 1008
	if codes then -- 1008
		local comments = { } -- 1009
		local line = 0 -- 1010
		local skipping = false -- 1011
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1012
			line = line + 1 -- 1013
			if line >= row then -- 1014
				break -- 1014
			end -- 1014
			if lineCode:match("^%s*%-%- @") then -- 1015
				skipping = true -- 1016
				goto _continue_0 -- 1017
			end -- 1015
			local result = lineCode:match("^%s*%-%- (.+)") -- 1018
			if result then -- 1018
				if not skipping then -- 1019
					comments[#comments + 1] = result -- 1019
				end -- 1019
			elseif #comments > 0 then -- 1020
				comments = { } -- 1021
				skipping = false -- 1022
			end -- 1018
			::_continue_0:: -- 1013
		end -- 1012
		infered.doc = table.concat(comments, "\n") -- 1023
	end -- 1008
end -- 1005
HttpServer:postSchedule("/infer", function(req) -- 1025
	do -- 1026
		local _type_0 = type(req) -- 1026
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1026
		if _tab_0 then -- 1026
			local lang -- 1026
			do -- 1026
				local _obj_0 = req.body -- 1026
				local _type_1 = type(_obj_0) -- 1026
				if "table" == _type_1 or "userdata" == _type_1 then -- 1026
					lang = _obj_0.lang -- 1026
				end -- 1026
			end -- 1026
			local file -- 1026
			do -- 1026
				local _obj_0 = req.body -- 1026
				local _type_1 = type(_obj_0) -- 1026
				if "table" == _type_1 or "userdata" == _type_1 then -- 1026
					file = _obj_0.file -- 1026
				end -- 1026
			end -- 1026
			local content -- 1026
			do -- 1026
				local _obj_0 = req.body -- 1026
				local _type_1 = type(_obj_0) -- 1026
				if "table" == _type_1 or "userdata" == _type_1 then -- 1026
					content = _obj_0.content -- 1026
				end -- 1026
			end -- 1026
			local line -- 1026
			do -- 1026
				local _obj_0 = req.body -- 1026
				local _type_1 = type(_obj_0) -- 1026
				if "table" == _type_1 or "userdata" == _type_1 then -- 1026
					line = _obj_0.line -- 1026
				end -- 1026
			end -- 1026
			local row -- 1026
			do -- 1026
				local _obj_0 = req.body -- 1026
				local _type_1 = type(_obj_0) -- 1026
				if "table" == _type_1 or "userdata" == _type_1 then -- 1026
					row = _obj_0.row -- 1026
				end -- 1026
			end -- 1026
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1026
				local searchPath = getSearchPath(file) -- 1027
				if "tl" == lang or "lua" == lang then -- 1028
					if CheckTIC80Code(content) then -- 1029
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1030
					end -- 1029
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1031
					if (infered ~= nil) then -- 1032
						updateInferedDesc(infered) -- 1033
						return { -- 1034
							success = true, -- 1034
							infered = infered -- 1034
						} -- 1034
					end -- 1032
				elseif "yue" == lang then -- 1035
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1036
					if not luaCodes then -- 1037
						return { -- 1037
							success = false -- 1037
						} -- 1037
					end -- 1037
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1038
					if (infered ~= nil) then -- 1039
						local col -- 1040
						file, row, col = infered.file, infered.row, infered.col -- 1040
						if file == "" and row > 0 and col > 0 then -- 1041
							infered.row = lineMap[row] or 0 -- 1042
							infered.col = 0 -- 1043
						end -- 1041
						updateInferedDesc(infered) -- 1044
						return { -- 1045
							success = true, -- 1045
							infered = infered -- 1045
						} -- 1045
					end -- 1039
				end -- 1028
			end -- 1026
		end -- 1026
	end -- 1026
	return { -- 1025
		success = false -- 1025
	} -- 1025
end) -- 1025
local _anon_func_3 = function(doc) -- 1096
	local _accum_0 = { } -- 1096
	local _len_0 = 1 -- 1096
	local _list_0 = doc.params -- 1096
	for _index_0 = 1, #_list_0 do -- 1096
		local param = _list_0[_index_0] -- 1096
		_accum_0[_len_0] = param.name -- 1096
		_len_0 = _len_0 + 1 -- 1096
	end -- 1096
	return _accum_0 -- 1096
end -- 1096
local getParamDocs -- 1047
getParamDocs = function(signatures) -- 1047
	do -- 1048
		local codes = Content:loadAsync(signatures[1].file) -- 1048
		if codes then -- 1048
			local comments = { } -- 1049
			local params = { } -- 1050
			local line = 0 -- 1051
			local docs = { } -- 1052
			local returnType = nil -- 1053
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1054
				line = line + 1 -- 1055
				local needBreak = true -- 1056
				for i, _des_0 in ipairs(signatures) do -- 1057
					local row = _des_0.row -- 1057
					if line >= row and not (docs[i] ~= nil) then -- 1058
						if #comments > 0 or #params > 0 or returnType then -- 1059
							docs[i] = { -- 1061
								doc = table.concat(comments, "  \n"), -- 1061
								returnType = returnType -- 1062
							} -- 1060
							if #params > 0 then -- 1064
								docs[i].params = params -- 1064
							end -- 1064
						else -- 1066
							docs[i] = false -- 1066
						end -- 1059
					end -- 1058
					if not docs[i] then -- 1067
						needBreak = false -- 1067
					end -- 1067
				end -- 1057
				if needBreak then -- 1068
					break -- 1068
				end -- 1068
				local result = lineCode:match("%s*%-%- (.+)") -- 1069
				if result then -- 1069
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1070
					if not name then -- 1071
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1072
					end -- 1071
					if name then -- 1073
						local pname = name -- 1074
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1075
							pname = pname .. "?" -- 1075
						end -- 1075
						params[#params + 1] = { -- 1077
							name = tostring(pname) .. ": " .. tostring(typ), -- 1077
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1078
						} -- 1076
					else -- 1081
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1081
						if typ then -- 1081
							if returnType then -- 1082
								returnType = returnType .. ", " .. typ -- 1083
							else -- 1085
								returnType = typ -- 1085
							end -- 1082
							result = result:gsub("@return", "**return:**") -- 1086
						end -- 1081
						comments[#comments + 1] = result -- 1087
					end -- 1073
				elseif #comments > 0 then -- 1088
					comments = { } -- 1089
					params = { } -- 1090
					returnType = nil -- 1091
				end -- 1069
			end -- 1054
			local results = { } -- 1092
			for _index_0 = 1, #docs do -- 1093
				local doc = docs[_index_0] -- 1093
				if not doc then -- 1094
					goto _continue_0 -- 1094
				end -- 1094
				if doc.params then -- 1095
					doc.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1096
				else -- 1098
					doc.desc = "function()" -- 1098
				end -- 1095
				if doc.returnType then -- 1099
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 1100
					doc.returnType = nil -- 1101
				end -- 1099
				results[#results + 1] = doc -- 1102
				::_continue_0:: -- 1094
			end -- 1093
			if #results > 0 then -- 1103
				return results -- 1103
			else -- 1103
				return nil -- 1103
			end -- 1103
		end -- 1048
	end -- 1048
	return nil -- 1047
end -- 1047
HttpServer:postSchedule("/signature", function(req) -- 1105
	do -- 1106
		local _type_0 = type(req) -- 1106
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1106
		if _tab_0 then -- 1106
			local lang -- 1106
			do -- 1106
				local _obj_0 = req.body -- 1106
				local _type_1 = type(_obj_0) -- 1106
				if "table" == _type_1 or "userdata" == _type_1 then -- 1106
					lang = _obj_0.lang -- 1106
				end -- 1106
			end -- 1106
			local file -- 1106
			do -- 1106
				local _obj_0 = req.body -- 1106
				local _type_1 = type(_obj_0) -- 1106
				if "table" == _type_1 or "userdata" == _type_1 then -- 1106
					file = _obj_0.file -- 1106
				end -- 1106
			end -- 1106
			local content -- 1106
			do -- 1106
				local _obj_0 = req.body -- 1106
				local _type_1 = type(_obj_0) -- 1106
				if "table" == _type_1 or "userdata" == _type_1 then -- 1106
					content = _obj_0.content -- 1106
				end -- 1106
			end -- 1106
			local line -- 1106
			do -- 1106
				local _obj_0 = req.body -- 1106
				local _type_1 = type(_obj_0) -- 1106
				if "table" == _type_1 or "userdata" == _type_1 then -- 1106
					line = _obj_0.line -- 1106
				end -- 1106
			end -- 1106
			local row -- 1106
			do -- 1106
				local _obj_0 = req.body -- 1106
				local _type_1 = type(_obj_0) -- 1106
				if "table" == _type_1 or "userdata" == _type_1 then -- 1106
					row = _obj_0.row -- 1106
				end -- 1106
			end -- 1106
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1106
				local searchPath = getSearchPath(file) -- 1107
				if "tl" == lang or "lua" == lang then -- 1108
					if CheckTIC80Code(content) then -- 1109
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1110
					end -- 1109
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1111
					if signatures then -- 1111
						signatures = getParamDocs(signatures) -- 1112
						if signatures then -- 1112
							return { -- 1113
								success = true, -- 1113
								signatures = signatures -- 1113
							} -- 1113
						end -- 1112
					end -- 1111
				elseif "yue" == lang then -- 1114
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1115
					if not luaCodes then -- 1116
						return { -- 1116
							success = false -- 1116
						} -- 1116
					end -- 1116
					do -- 1117
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1117
						if chainOp then -- 1117
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1118
							if withVar then -- 1118
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1119
							end -- 1118
						end -- 1117
					end -- 1117
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1120
					if signatures then -- 1120
						signatures = getParamDocs(signatures) -- 1121
						if signatures then -- 1121
							return { -- 1122
								success = true, -- 1122
								signatures = signatures -- 1122
							} -- 1122
						end -- 1121
					else -- 1123
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1123
						if signatures then -- 1123
							signatures = getParamDocs(signatures) -- 1124
							if signatures then -- 1124
								return { -- 1125
									success = true, -- 1125
									signatures = signatures -- 1125
								} -- 1125
							end -- 1124
						end -- 1123
					end -- 1120
				end -- 1108
			end -- 1106
		end -- 1106
	end -- 1106
	return { -- 1105
		success = false -- 1105
	} -- 1105
end) -- 1105
local luaKeywords = { -- 1128
	'and', -- 1128
	'break', -- 1129
	'do', -- 1130
	'else', -- 1131
	'elseif', -- 1132
	'end', -- 1133
	'false', -- 1134
	'for', -- 1135
	'function', -- 1136
	'goto', -- 1137
	'if', -- 1138
	'in', -- 1139
	'local', -- 1140
	'nil', -- 1141
	'not', -- 1142
	'or', -- 1143
	'repeat', -- 1144
	'return', -- 1145
	'then', -- 1146
	'true', -- 1147
	'until', -- 1148
	'while' -- 1149
} -- 1127
local tealKeywords = { -- 1153
	'record', -- 1153
	'as', -- 1154
	'is', -- 1155
	'type', -- 1156
	'embed', -- 1157
	'enum', -- 1158
	'global', -- 1159
	'any', -- 1160
	'boolean', -- 1161
	'integer', -- 1162
	'number', -- 1163
	'string', -- 1164
	'thread' -- 1165
} -- 1152
local yueKeywords = { -- 1169
	"and", -- 1169
	"break", -- 1170
	"do", -- 1171
	"else", -- 1172
	"elseif", -- 1173
	"false", -- 1174
	"for", -- 1175
	"goto", -- 1176
	"if", -- 1177
	"in", -- 1178
	"local", -- 1179
	"nil", -- 1180
	"not", -- 1181
	"or", -- 1182
	"repeat", -- 1183
	"return", -- 1184
	"then", -- 1185
	"true", -- 1186
	"until", -- 1187
	"while", -- 1188
	"as", -- 1189
	"class", -- 1190
	"continue", -- 1191
	"export", -- 1192
	"extends", -- 1193
	"from", -- 1194
	"global", -- 1195
	"import", -- 1196
	"macro", -- 1197
	"switch", -- 1198
	"try", -- 1199
	"unless", -- 1200
	"using", -- 1201
	"when", -- 1202
	"with" -- 1203
} -- 1168
local _anon_func_4 = function(f) -- 1239
	local _val_0 = Path:getExt(f) -- 1239
	return "ttf" == _val_0 or "otf" == _val_0 -- 1239
end -- 1239
local _anon_func_5 = function(suggestions) -- 1265
	local _tbl_0 = { } -- 1265
	for _index_0 = 1, #suggestions do -- 1265
		local item = suggestions[_index_0] -- 1265
		_tbl_0[item[1] .. item[2]] = item -- 1265
	end -- 1265
	return _tbl_0 -- 1265
end -- 1265
HttpServer:postSchedule("/complete", function(req) -- 1206
	do -- 1207
		local _type_0 = type(req) -- 1207
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1207
		if _tab_0 then -- 1207
			local lang -- 1207
			do -- 1207
				local _obj_0 = req.body -- 1207
				local _type_1 = type(_obj_0) -- 1207
				if "table" == _type_1 or "userdata" == _type_1 then -- 1207
					lang = _obj_0.lang -- 1207
				end -- 1207
			end -- 1207
			local file -- 1207
			do -- 1207
				local _obj_0 = req.body -- 1207
				local _type_1 = type(_obj_0) -- 1207
				if "table" == _type_1 or "userdata" == _type_1 then -- 1207
					file = _obj_0.file -- 1207
				end -- 1207
			end -- 1207
			local content -- 1207
			do -- 1207
				local _obj_0 = req.body -- 1207
				local _type_1 = type(_obj_0) -- 1207
				if "table" == _type_1 or "userdata" == _type_1 then -- 1207
					content = _obj_0.content -- 1207
				end -- 1207
			end -- 1207
			local line -- 1207
			do -- 1207
				local _obj_0 = req.body -- 1207
				local _type_1 = type(_obj_0) -- 1207
				if "table" == _type_1 or "userdata" == _type_1 then -- 1207
					line = _obj_0.line -- 1207
				end -- 1207
			end -- 1207
			local row -- 1207
			do -- 1207
				local _obj_0 = req.body -- 1207
				local _type_1 = type(_obj_0) -- 1207
				if "table" == _type_1 or "userdata" == _type_1 then -- 1207
					row = _obj_0.row -- 1207
				end -- 1207
			end -- 1207
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1207
				local searchPath = getSearchPath(file) -- 1208
				repeat -- 1209
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1210
					if lang == "yue" then -- 1211
						if not item then -- 1212
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1212
						end -- 1212
						if not item then -- 1213
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1213
						end -- 1213
					end -- 1211
					local searchType = nil -- 1214
					if not item then -- 1215
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1216
						if lang == "yue" then -- 1217
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1218
						end -- 1217
						if (item ~= nil) then -- 1219
							searchType = "Image" -- 1219
						end -- 1219
					end -- 1215
					if not item then -- 1220
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1221
						if lang == "yue" then -- 1222
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1223
						end -- 1222
						if (item ~= nil) then -- 1224
							searchType = "Font" -- 1224
						end -- 1224
					end -- 1220
					if not item then -- 1225
						break -- 1225
					end -- 1225
					local searchPaths = Content.searchPaths -- 1226
					local _list_0 = getSearchFolders(file) -- 1227
					for _index_0 = 1, #_list_0 do -- 1227
						local folder = _list_0[_index_0] -- 1227
						searchPaths[#searchPaths + 1] = folder -- 1228
					end -- 1227
					if searchType then -- 1229
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1229
					end -- 1229
					local tokens -- 1230
					do -- 1230
						local _accum_0 = { } -- 1230
						local _len_0 = 1 -- 1230
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1230
							_accum_0[_len_0] = mod -- 1230
							_len_0 = _len_0 + 1 -- 1230
						end -- 1230
						tokens = _accum_0 -- 1230
					end -- 1230
					local suggestions = { } -- 1231
					for _index_0 = 1, #searchPaths do -- 1232
						local path = searchPaths[_index_0] -- 1232
						local sPath = Path(path, table.unpack(tokens)) -- 1233
						if not Content:exist(sPath) then -- 1234
							goto _continue_0 -- 1234
						end -- 1234
						if searchType == "Font" then -- 1235
							local fontPath = Path(sPath, "Font") -- 1236
							if Content:exist(fontPath) then -- 1237
								local _list_1 = Content:getFiles(fontPath) -- 1238
								for _index_1 = 1, #_list_1 do -- 1238
									local f = _list_1[_index_1] -- 1238
									if _anon_func_4(f) then -- 1239
										if "." == f:sub(1, 1) then -- 1240
											goto _continue_1 -- 1240
										end -- 1240
										suggestions[#suggestions + 1] = { -- 1241
											Path:getName(f), -- 1241
											"font", -- 1241
											"field" -- 1241
										} -- 1241
									end -- 1239
									::_continue_1:: -- 1239
								end -- 1238
							end -- 1237
						end -- 1235
						local _list_1 = Content:getFiles(sPath) -- 1242
						for _index_1 = 1, #_list_1 do -- 1242
							local f = _list_1[_index_1] -- 1242
							if "Image" == searchType then -- 1243
								do -- 1244
									local _exp_0 = Path:getExt(f) -- 1244
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1244
										if "." == f:sub(1, 1) then -- 1245
											goto _continue_2 -- 1245
										end -- 1245
										suggestions[#suggestions + 1] = { -- 1246
											f, -- 1246
											"image", -- 1246
											"field" -- 1246
										} -- 1246
									end -- 1244
								end -- 1244
								goto _continue_2 -- 1247
							elseif "Font" == searchType then -- 1248
								do -- 1249
									local _exp_0 = Path:getExt(f) -- 1249
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1249
										if "." == f:sub(1, 1) then -- 1250
											goto _continue_2 -- 1250
										end -- 1250
										suggestions[#suggestions + 1] = { -- 1251
											f, -- 1251
											"font", -- 1251
											"field" -- 1251
										} -- 1251
									end -- 1249
								end -- 1249
								goto _continue_2 -- 1252
							end -- 1243
							local _exp_0 = Path:getExt(f) -- 1253
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1253
								local name = Path:getName(f) -- 1254
								if "d" == Path:getExt(name) then -- 1255
									goto _continue_2 -- 1255
								end -- 1255
								if "." == name:sub(1, 1) then -- 1256
									goto _continue_2 -- 1256
								end -- 1256
								suggestions[#suggestions + 1] = { -- 1257
									name, -- 1257
									"module", -- 1257
									"field" -- 1257
								} -- 1257
							end -- 1253
							::_continue_2:: -- 1243
						end -- 1242
						local _list_2 = Content:getDirs(sPath) -- 1258
						for _index_1 = 1, #_list_2 do -- 1258
							local dir = _list_2[_index_1] -- 1258
							if "." == dir:sub(1, 1) then -- 1259
								goto _continue_3 -- 1259
							end -- 1259
							suggestions[#suggestions + 1] = { -- 1260
								dir, -- 1260
								"folder", -- 1260
								"variable" -- 1260
							} -- 1260
							::_continue_3:: -- 1259
						end -- 1258
						::_continue_0:: -- 1233
					end -- 1232
					if item == "" and not searchType then -- 1261
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1262
						for _index_0 = 1, #_list_1 do -- 1262
							local _des_0 = _list_1[_index_0] -- 1262
							local name = _des_0[1] -- 1262
							suggestions[#suggestions + 1] = { -- 1263
								name, -- 1263
								"dora module", -- 1263
								"function" -- 1263
							} -- 1263
						end -- 1262
					end -- 1261
					if #suggestions > 0 then -- 1264
						do -- 1265
							local _accum_0 = { } -- 1265
							local _len_0 = 1 -- 1265
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1265
								_accum_0[_len_0] = v -- 1265
								_len_0 = _len_0 + 1 -- 1265
							end -- 1265
							suggestions = _accum_0 -- 1265
						end -- 1265
						return { -- 1266
							success = true, -- 1266
							suggestions = suggestions -- 1266
						} -- 1266
					else -- 1268
						return { -- 1268
							success = false -- 1268
						} -- 1268
					end -- 1264
				until true -- 1209
				if "tl" == lang or "lua" == lang then -- 1270
					do -- 1271
						local isTIC80 = CheckTIC80Code(content) -- 1271
						if isTIC80 then -- 1271
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1272
						end -- 1271
					end -- 1271
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1273
					if not line:match("[%.:]$") then -- 1274
						local checkSet -- 1275
						do -- 1275
							local _tbl_0 = { } -- 1275
							for _index_0 = 1, #suggestions do -- 1275
								local _des_0 = suggestions[_index_0] -- 1275
								local name = _des_0[1] -- 1275
								_tbl_0[name] = true -- 1275
							end -- 1275
							checkSet = _tbl_0 -- 1275
						end -- 1275
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1276
						for _index_0 = 1, #_list_0 do -- 1276
							local item = _list_0[_index_0] -- 1276
							if not checkSet[item[1]] then -- 1277
								suggestions[#suggestions + 1] = item -- 1277
							end -- 1277
						end -- 1276
						for _index_0 = 1, #luaKeywords do -- 1278
							local word = luaKeywords[_index_0] -- 1278
							suggestions[#suggestions + 1] = { -- 1279
								word, -- 1279
								"keyword", -- 1279
								"keyword" -- 1279
							} -- 1279
						end -- 1278
						if lang == "tl" then -- 1280
							for _index_0 = 1, #tealKeywords do -- 1281
								local word = tealKeywords[_index_0] -- 1281
								suggestions[#suggestions + 1] = { -- 1282
									word, -- 1282
									"keyword", -- 1282
									"keyword" -- 1282
								} -- 1282
							end -- 1281
						end -- 1280
					end -- 1274
					if #suggestions > 0 then -- 1283
						return { -- 1284
							success = true, -- 1284
							suggestions = suggestions -- 1284
						} -- 1284
					end -- 1283
				elseif "yue" == lang then -- 1285
					local suggestions = { } -- 1286
					local gotGlobals = false -- 1287
					do -- 1288
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1288
						if luaCodes then -- 1288
							gotGlobals = true -- 1289
							do -- 1290
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1290
								if chainOp then -- 1290
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1291
									if not withVar then -- 1292
										return { -- 1292
											success = false -- 1292
										} -- 1292
									end -- 1292
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1293
								elseif line:match("^([%.\\])$") then -- 1294
									return { -- 1295
										success = false -- 1295
									} -- 1295
								end -- 1290
							end -- 1290
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1296
							for _index_0 = 1, #_list_0 do -- 1296
								local item = _list_0[_index_0] -- 1296
								suggestions[#suggestions + 1] = item -- 1296
							end -- 1296
							if #suggestions == 0 then -- 1297
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1298
								for _index_0 = 1, #_list_1 do -- 1298
									local item = _list_1[_index_0] -- 1298
									suggestions[#suggestions + 1] = item -- 1298
								end -- 1298
							end -- 1297
						end -- 1288
					end -- 1288
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1299
						local checkSet -- 1300
						do -- 1300
							local _tbl_0 = { } -- 1300
							for _index_0 = 1, #suggestions do -- 1300
								local _des_0 = suggestions[_index_0] -- 1300
								local name = _des_0[1] -- 1300
								_tbl_0[name] = true -- 1300
							end -- 1300
							checkSet = _tbl_0 -- 1300
						end -- 1300
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1301
						for _index_0 = 1, #_list_0 do -- 1301
							local item = _list_0[_index_0] -- 1301
							if not checkSet[item[1]] then -- 1302
								suggestions[#suggestions + 1] = item -- 1302
							end -- 1302
						end -- 1301
						if not gotGlobals then -- 1303
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1304
							for _index_0 = 1, #_list_1 do -- 1304
								local item = _list_1[_index_0] -- 1304
								if not checkSet[item[1]] then -- 1305
									suggestions[#suggestions + 1] = item -- 1305
								end -- 1305
							end -- 1304
						end -- 1303
						for _index_0 = 1, #yueKeywords do -- 1306
							local word = yueKeywords[_index_0] -- 1306
							if not checkSet[word] then -- 1307
								suggestions[#suggestions + 1] = { -- 1308
									word, -- 1308
									"keyword", -- 1308
									"keyword" -- 1308
								} -- 1308
							end -- 1307
						end -- 1306
					end -- 1299
					if #suggestions > 0 then -- 1309
						return { -- 1310
							success = true, -- 1310
							suggestions = suggestions -- 1310
						} -- 1310
					end -- 1309
				elseif "xml" == lang then -- 1311
					local items = xml.complete(content) -- 1312
					if #items > 0 then -- 1313
						local suggestions -- 1314
						do -- 1314
							local _accum_0 = { } -- 1314
							local _len_0 = 1 -- 1314
							for _index_0 = 1, #items do -- 1314
								local _des_0 = items[_index_0] -- 1314
								local label, insertText = _des_0[1], _des_0[2] -- 1314
								_accum_0[_len_0] = { -- 1315
									label, -- 1315
									insertText, -- 1315
									"field" -- 1315
								} -- 1315
								_len_0 = _len_0 + 1 -- 1315
							end -- 1314
							suggestions = _accum_0 -- 1314
						end -- 1314
						return { -- 1316
							success = true, -- 1316
							suggestions = suggestions -- 1316
						} -- 1316
					end -- 1313
				end -- 1270
			end -- 1207
		end -- 1207
	end -- 1207
	return { -- 1206
		success = false -- 1206
	} -- 1206
end) -- 1206
HttpServer:upload("/upload", function(req, filename) -- 1320
	do -- 1321
		local _type_0 = type(req) -- 1321
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1321
		if _tab_0 then -- 1321
			local path -- 1321
			do -- 1321
				local _obj_0 = req.params -- 1321
				local _type_1 = type(_obj_0) -- 1321
				if "table" == _type_1 or "userdata" == _type_1 then -- 1321
					path = _obj_0.path -- 1321
				end -- 1321
			end -- 1321
			if path ~= nil then -- 1321
				local uploadPath = Path(Content.writablePath, ".upload") -- 1322
				if not Content:exist(uploadPath) then -- 1323
					Content:mkdir(uploadPath) -- 1324
				end -- 1323
				local targetPath = Path(uploadPath, filename) -- 1325
				Content:mkdir(Path:getPath(targetPath)) -- 1326
				return targetPath -- 1327
			end -- 1321
		end -- 1321
	end -- 1321
	return nil -- 1320
end, function(req, file) -- 1328
	do -- 1329
		local _type_0 = type(req) -- 1329
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1329
		if _tab_0 then -- 1329
			local path -- 1329
			do -- 1329
				local _obj_0 = req.params -- 1329
				local _type_1 = type(_obj_0) -- 1329
				if "table" == _type_1 or "userdata" == _type_1 then -- 1329
					path = _obj_0.path -- 1329
				end -- 1329
			end -- 1329
			if path ~= nil then -- 1329
				path = Path(Content.writablePath, path) -- 1330
				if Content:exist(path) then -- 1331
					local uploadPath = Path(Content.writablePath, ".upload") -- 1332
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1333
					Content:mkdir(Path:getPath(targetPath)) -- 1334
					if Content:move(file, targetPath) then -- 1335
						return true -- 1336
					end -- 1335
				end -- 1331
			end -- 1329
		end -- 1329
	end -- 1329
	return false -- 1328
end) -- 1318
HttpServer:post("/list", function(req) -- 1339
	do -- 1340
		local _type_0 = type(req) -- 1340
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1340
		if _tab_0 then -- 1340
			local path -- 1340
			do -- 1340
				local _obj_0 = req.body -- 1340
				local _type_1 = type(_obj_0) -- 1340
				if "table" == _type_1 or "userdata" == _type_1 then -- 1340
					path = _obj_0.path -- 1340
				end -- 1340
			end -- 1340
			if path ~= nil then -- 1340
				if Content:exist(path) then -- 1341
					local files = { } -- 1342
					local visitAssets -- 1343
					visitAssets = function(path, folder) -- 1343
						local dirs = Content:getDirs(path) -- 1344
						for _index_0 = 1, #dirs do -- 1345
							local dir = dirs[_index_0] -- 1345
							if dir:match("^%.") then -- 1346
								goto _continue_0 -- 1346
							end -- 1346
							local current -- 1347
							if folder == "" then -- 1347
								current = dir -- 1348
							else -- 1350
								current = Path(folder, dir) -- 1350
							end -- 1347
							files[#files + 1] = current -- 1351
							visitAssets(Path(path, dir), current) -- 1352
							::_continue_0:: -- 1346
						end -- 1345
						local fs = Content:getFiles(path) -- 1353
						for _index_0 = 1, #fs do -- 1354
							local f = fs[_index_0] -- 1354
							if (".DS_Store" == f) then -- 1355
								goto _continue_1 -- 1356
							end -- 1355
							if folder == "" then -- 1357
								files[#files + 1] = f -- 1358
							else -- 1360
								files[#files + 1] = Path(folder, f) -- 1360
							end -- 1357
							::_continue_1:: -- 1355
						end -- 1354
					end -- 1343
					visitAssets(path, "") -- 1361
					if #files == 0 then -- 1362
						files = nil -- 1362
					end -- 1362
					return { -- 1363
						success = true, -- 1363
						files = files -- 1363
					} -- 1363
				end -- 1341
			end -- 1340
		end -- 1340
	end -- 1340
	return { -- 1339
		success = false -- 1339
	} -- 1339
end) -- 1339
HttpServer:post("/info", function() -- 1365
	local Entry = require("Script.Dev.Entry") -- 1366
	local webProfiler, drawerWidth -- 1367
	do -- 1367
		local _obj_0 = Entry.getConfig() -- 1367
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 1367
	end -- 1367
	local engineDev = Entry.getEngineDev() -- 1368
	Entry.connectWebIDE() -- 1369
	return { -- 1371
		platform = App.platform, -- 1371
		locale = App.locale, -- 1372
		version = App.version, -- 1373
		engineDev = engineDev, -- 1374
		webProfiler = webProfiler, -- 1375
		drawerWidth = drawerWidth -- 1376
	} -- 1370
end) -- 1365
local ensureLLMConfigTable -- 1378
ensureLLMConfigTable = function() -- 1378
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1379
	if columns and #columns > 0 then -- 1380
		local expected = { -- 1382
			id = true, -- 1382
			name = true, -- 1383
			url = true, -- 1384
			model = true, -- 1385
			api_key = true, -- 1386
			context_window = true, -- 1387
			temperature = true, -- 1388
			max_tokens = true, -- 1389
			reasoning_effort = true, -- 1390
			custom_options = true, -- 1391
			supports_function_calling = true, -- 1392
			active = true, -- 1393
			created_at = true, -- 1394
			updated_at = true -- 1395
		} -- 1381
		local existing = { } -- 1397
		local valid = true -- 1398
		for _index_0 = 1, #columns do -- 1399
			local row = columns[_index_0] -- 1399
			local columnName = tostring(row[2]) -- 1400
			existing[columnName] = true -- 1401
			if not expected[columnName] then -- 1402
				valid = false -- 1403
				break -- 1404
			end -- 1402
		end -- 1399
		if valid then -- 1405
			if not existing.context_window then -- 1406
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1407
			end -- 1406
			if not existing.temperature then -- 1408
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1409
			end -- 1408
			if not existing.max_tokens then -- 1410
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 1411
			end -- 1410
			if not existing.reasoning_effort then -- 1412
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1413
			end -- 1412
			if not existing.custom_options then -- 1414
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1415
			end -- 1414
			if not existing.supports_function_calling then -- 1416
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1417
			end -- 1416
		else -- 1419
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1419
		end -- 1405
	end -- 1380
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
	]]) -- 1420
end -- 1378
local normalizeContextWindow -- 1439
normalizeContextWindow = function(value) -- 1439
	local contextWindow = tonumber(value) -- 1440
	if contextWindow == nil or contextWindow < 64000 then -- 1441
		return 64000 -- 1442
	end -- 1441
	return math.max(64000, math.floor(contextWindow)) -- 1443
end -- 1439
local normalizeTemperature -- 1445
normalizeTemperature = function(value) -- 1445
	local temperature = tonumber(value) -- 1446
	if temperature == nil then -- 1447
		return 0.1 -- 1448
	end -- 1447
	return math.max(0, math.min(2, temperature)) -- 1449
end -- 1445
local normalizeMaxTokens -- 1451
normalizeMaxTokens = function(value) -- 1451
	local maxTokens = tonumber(value) -- 1452
	if maxTokens == nil or maxTokens < 1 then -- 1453
		return 8192 -- 1454
	end -- 1453
	return math.max(1, math.floor(maxTokens)) -- 1455
end -- 1451
local normalizeReasoningEffort -- 1457
normalizeReasoningEffort = function(value) -- 1457
	if value == nil then -- 1458
		return "" -- 1459
	end -- 1458
	local effort = tostring(value) -- 1460
	return effort:match("^%s*(.-)%s*$") or "" -- 1461
end -- 1457
local normalizeCustomOptions -- 1463
normalizeCustomOptions = function(value) -- 1463
	if value == nil then -- 1464
		return "" -- 1465
	end -- 1464
	local options = tostring(value) -- 1466
	options = options:match("^%s*(.-)%s*$") or "" -- 1467
	return options -- 1468
end -- 1463
local validateCustomOptions -- 1470
validateCustomOptions = function(value) -- 1470
	local options = normalizeCustomOptions(value) -- 1471
	if options == "" then -- 1472
		return true -- 1472
	end -- 1472
	if not options:match("^%s*{") then -- 1473
		return false -- 1473
	end -- 1473
	local decoded = json.decode(options) -- 1474
	return type(decoded) == "table" -- 1475
end -- 1470
HttpServer:post("/llm/list", function() -- 1477
	ensureLLMConfigTable() -- 1478
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active\n		from LLMConfig\n		order by id asc") -- 1479
	local items -- 1483
	if rows and #rows > 0 then -- 1483
		local _accum_0 = { } -- 1484
		local _len_0 = 1 -- 1484
		for _index_0 = 1, #rows do -- 1484
			local _des_0 = rows[_index_0] -- 1484
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11], _des_0[12] -- 1484
			_accum_0[_len_0] = { -- 1485
				id = id, -- 1485
				name = name, -- 1485
				url = url, -- 1485
				model = model, -- 1485
				key = key, -- 1485
				contextWindow = normalizeContextWindow(contextWindow), -- 1485
				temperature = normalizeTemperature(temperature), -- 1485
				maxTokens = normalizeMaxTokens(maxTokens), -- 1485
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1485
				customOptions = normalizeCustomOptions(customOptions), -- 1485
				supportsFunctionCalling = supportsFunctionCalling ~= 0, -- 1485
				active = active ~= 0 -- 1485
			} -- 1485
			_len_0 = _len_0 + 1 -- 1485
		end -- 1484
		items = _accum_0 -- 1483
	end -- 1483
	return { -- 1486
		success = true, -- 1486
		items = items -- 1486
	} -- 1486
end) -- 1477
HttpServer:post("/llm/create", function(req) -- 1488
	ensureLLMConfigTable() -- 1489
	do -- 1490
		local _type_0 = type(req) -- 1490
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1490
		if _tab_0 then -- 1490
			local body = req.body -- 1490
			if body ~= nil then -- 1490
				local name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1491
				local now = os.time() -- 1492
				if name == nil or url == nil or model == nil or key == nil then -- 1493
					return { -- 1494
						success = false, -- 1494
						message = "invalid" -- 1494
					} -- 1494
				end -- 1493
				contextWindow = normalizeContextWindow(contextWindow) -- 1495
				temperature = normalizeTemperature(temperature) -- 1496
				maxTokens = normalizeMaxTokens(maxTokens) -- 1497
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1498
				customOptions = normalizeCustomOptions(customOptions) -- 1499
				if not validateCustomOptions(customOptions) then -- 1500
					return { -- 1500
						success = false, -- 1500
						message = "customOptions must be a JSON object" -- 1500
					} -- 1500
				end -- 1500
				if supportsFunctionCalling == false then -- 1501
					supportsFunctionCalling = 0 -- 1501
				else -- 1501
					supportsFunctionCalling = 1 -- 1501
				end -- 1501
				if active then -- 1502
					active = 1 -- 1502
				else -- 1502
					active = 0 -- 1502
				end -- 1502
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1509
					tostring(name), -- 1509
					tostring(url), -- 1510
					tostring(model), -- 1511
					tostring(key), -- 1512
					contextWindow, -- 1513
					temperature, -- 1514
					maxTokens, -- 1515
					reasoningEffort, -- 1516
					customOptions, -- 1517
					supportsFunctionCalling, -- 1518
					active, -- 1519
					now, -- 1520
					now -- 1521
				}) -- 1503
				return { -- 1523
					success = affected >= 0 -- 1523
				} -- 1523
			end -- 1490
		end -- 1490
	end -- 1490
	return { -- 1488
		success = false, -- 1488
		message = "invalid" -- 1488
	} -- 1488
end) -- 1488
HttpServer:post("/llm/update", function(req) -- 1525
	ensureLLMConfigTable() -- 1526
	do -- 1527
		local _type_0 = type(req) -- 1527
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1527
		if _tab_0 then -- 1527
			local body = req.body -- 1527
			if body ~= nil then -- 1527
				local id, name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1528
				local now = os.time() -- 1529
				id = tonumber(id) -- 1530
				if id == nil then -- 1531
					return { -- 1532
						success = false, -- 1532
						message = "invalid" -- 1532
					} -- 1532
				end -- 1531
				contextWindow = normalizeContextWindow(contextWindow) -- 1533
				temperature = normalizeTemperature(temperature) -- 1534
				maxTokens = normalizeMaxTokens(maxTokens) -- 1535
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1536
				customOptions = normalizeCustomOptions(customOptions) -- 1537
				if not validateCustomOptions(customOptions) then -- 1538
					return { -- 1538
						success = false, -- 1538
						message = "customOptions must be a JSON object" -- 1538
					} -- 1538
				end -- 1538
				if supportsFunctionCalling == false then -- 1539
					supportsFunctionCalling = 0 -- 1539
				else -- 1539
					supportsFunctionCalling = 1 -- 1539
				end -- 1539
				if active then -- 1540
					active = 1 -- 1540
				else -- 1540
					active = 0 -- 1540
				end -- 1540
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, active = ?, updated_at = ?\n			where id = ?", { -- 1545
					tostring(name), -- 1545
					tostring(url), -- 1546
					tostring(model), -- 1547
					tostring(key), -- 1548
					contextWindow, -- 1549
					temperature, -- 1550
					maxTokens, -- 1551
					reasoningEffort, -- 1552
					customOptions, -- 1553
					supportsFunctionCalling, -- 1554
					active, -- 1555
					now, -- 1556
					id -- 1557
				}) -- 1541
				return { -- 1559
					success = affected >= 0 -- 1559
				} -- 1559
			end -- 1527
		end -- 1527
	end -- 1527
	return { -- 1525
		success = false, -- 1525
		message = "invalid" -- 1525
	} -- 1525
end) -- 1525
HttpServer:post("/llm/delete", function(req) -- 1561
	ensureLLMConfigTable() -- 1562
	do -- 1563
		local _type_0 = type(req) -- 1563
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1563
		if _tab_0 then -- 1563
			local id -- 1563
			do -- 1563
				local _obj_0 = req.body -- 1563
				local _type_1 = type(_obj_0) -- 1563
				if "table" == _type_1 or "userdata" == _type_1 then -- 1563
					id = _obj_0.id -- 1563
				end -- 1563
			end -- 1563
			if id ~= nil then -- 1563
				id = tonumber(id) -- 1564
				if id == nil then -- 1565
					return { -- 1566
						success = false, -- 1566
						message = "invalid" -- 1566
					} -- 1566
				end -- 1565
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1567
					id -- 1567
				}) -- 1567
				return { -- 1568
					success = affected >= 0 -- 1568
				} -- 1568
			end -- 1563
		end -- 1563
	end -- 1563
	return { -- 1561
		success = false, -- 1561
		message = "invalid" -- 1561
	} -- 1561
end) -- 1561
HttpServer:post("/stat", function(req) -- 1570
	do -- 1571
		local _type_0 = type(req) -- 1571
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1571
		if _tab_0 then -- 1571
			local path -- 1571
			do -- 1571
				local _obj_0 = req.body -- 1571
				local _type_1 = type(_obj_0) -- 1571
				if "table" == _type_1 or "userdata" == _type_1 then -- 1571
					path = _obj_0.path -- 1571
				end -- 1571
			end -- 1571
			if path ~= nil then -- 1571
				if not Content:exist(path) then -- 1572
					return { -- 1573
						success = false, -- 1573
						message = "target not existed" -- 1573
					} -- 1573
				end -- 1572
				if Content:isdir(path) then -- 1574
					return { -- 1575
						success = false, -- 1575
						message = "failed to stat a directory" -- 1575
					} -- 1575
				end -- 1574
				local size, isBinary = Content:getAttr(path) -- 1576
				if size then -- 1576
					return { -- 1577
						success = true, -- 1577
						size = size, -- 1577
						isBinary = isBinary -- 1577
					} -- 1577
				end -- 1576
			end -- 1571
		end -- 1571
	end -- 1571
	return { -- 1570
		success = false, -- 1570
		message = "failed to stat" -- 1570
	} -- 1570
end) -- 1570
HttpServer:post("/new", function(req) -- 1579
	do -- 1580
		local _type_0 = type(req) -- 1580
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1580
		if _tab_0 then -- 1580
			local path -- 1580
			do -- 1580
				local _obj_0 = req.body -- 1580
				local _type_1 = type(_obj_0) -- 1580
				if "table" == _type_1 or "userdata" == _type_1 then -- 1580
					path = _obj_0.path -- 1580
				end -- 1580
			end -- 1580
			local content -- 1580
			do -- 1580
				local _obj_0 = req.body -- 1580
				local _type_1 = type(_obj_0) -- 1580
				if "table" == _type_1 or "userdata" == _type_1 then -- 1580
					content = _obj_0.content -- 1580
				end -- 1580
			end -- 1580
			local folder -- 1580
			do -- 1580
				local _obj_0 = req.body -- 1580
				local _type_1 = type(_obj_0) -- 1580
				if "table" == _type_1 or "userdata" == _type_1 then -- 1580
					folder = _obj_0.folder -- 1580
				end -- 1580
			end -- 1580
			if path ~= nil and content ~= nil and folder ~= nil then -- 1580
				if Content:exist(path) then -- 1581
					return { -- 1582
						success = false, -- 1582
						message = "TargetExisted" -- 1582
					} -- 1582
				end -- 1581
				local parent = Path:getPath(path) -- 1583
				local files = Content:getFiles(parent) -- 1584
				if folder then -- 1585
					local name = Path:getFilename(path):lower() -- 1586
					for _index_0 = 1, #files do -- 1587
						local file = files[_index_0] -- 1587
						if name == Path:getFilename(file):lower() then -- 1588
							return { -- 1589
								success = false, -- 1589
								message = "TargetExisted" -- 1589
							} -- 1589
						end -- 1588
					end -- 1587
					if Content:mkdir(path) then -- 1590
						return { -- 1591
							success = true -- 1591
						} -- 1591
					end -- 1590
				else -- 1593
					local name = Path:getName(path):lower() -- 1593
					for _index_0 = 1, #files do -- 1594
						local file = files[_index_0] -- 1594
						if name == Path:getName(file):lower() then -- 1595
							local ext = Path:getExt(file) -- 1596
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1597
								goto _continue_0 -- 1598
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1599
								goto _continue_0 -- 1600
							end -- 1597
							return { -- 1601
								success = false, -- 1601
								message = "SourceExisted" -- 1601
							} -- 1601
						end -- 1595
						::_continue_0:: -- 1595
					end -- 1594
					if Content:save(path, content) then -- 1602
						return { -- 1603
							success = true -- 1603
						} -- 1603
					end -- 1602
				end -- 1585
			end -- 1580
		end -- 1580
	end -- 1580
	return { -- 1579
		success = false, -- 1579
		message = "Failed" -- 1579
	} -- 1579
end) -- 1579
HttpServer:post("/delete", function(req) -- 1605
	do -- 1606
		local _type_0 = type(req) -- 1606
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1606
		if _tab_0 then -- 1606
			local path -- 1606
			do -- 1606
				local _obj_0 = req.body -- 1606
				local _type_1 = type(_obj_0) -- 1606
				if "table" == _type_1 or "userdata" == _type_1 then -- 1606
					path = _obj_0.path -- 1606
				end -- 1606
			end -- 1606
			if path ~= nil then -- 1606
				if Content:exist(path) then -- 1607
					local projectRoot -- 1608
					if Content:isdir(path) and isProjectRootDir(path) then -- 1608
						projectRoot = path -- 1608
					else -- 1608
						projectRoot = nil -- 1608
					end -- 1608
					local parent = Path:getPath(path) -- 1609
					local files = Content:getFiles(parent) -- 1610
					local name = Path:getName(path):lower() -- 1611
					local ext = Path:getExt(path) -- 1612
					for _index_0 = 1, #files do -- 1613
						local file = files[_index_0] -- 1613
						if name == Path:getName(file):lower() then -- 1614
							local _exp_0 = Path:getExt(file) -- 1615
							if "tl" == _exp_0 then -- 1615
								if ("vs" == ext) then -- 1615
									Content:remove(Path(parent, file)) -- 1616
								end -- 1615
							elseif "lua" == _exp_0 then -- 1617
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1617
									Content:remove(Path(parent, file)) -- 1618
								end -- 1617
							end -- 1615
						end -- 1614
					end -- 1613
					if Content:remove(path) then -- 1619
						if projectRoot then -- 1620
							AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1621
						end -- 1620
						return { -- 1622
							success = true -- 1622
						} -- 1622
					end -- 1619
				end -- 1607
			end -- 1606
		end -- 1606
	end -- 1606
	return { -- 1605
		success = false -- 1605
	} -- 1605
end) -- 1605
HttpServer:post("/rename", function(req) -- 1624
	do -- 1625
		local _type_0 = type(req) -- 1625
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1625
		if _tab_0 then -- 1625
			local old -- 1625
			do -- 1625
				local _obj_0 = req.body -- 1625
				local _type_1 = type(_obj_0) -- 1625
				if "table" == _type_1 or "userdata" == _type_1 then -- 1625
					old = _obj_0.old -- 1625
				end -- 1625
			end -- 1625
			local new -- 1625
			do -- 1625
				local _obj_0 = req.body -- 1625
				local _type_1 = type(_obj_0) -- 1625
				if "table" == _type_1 or "userdata" == _type_1 then -- 1625
					new = _obj_0.new -- 1625
				end -- 1625
			end -- 1625
			if old ~= nil and new ~= nil then -- 1625
				if Content:exist(old) and not Content:exist(new) then -- 1626
					local renamedDir = Content:isdir(old) -- 1627
					local parent = Path:getPath(new) -- 1628
					local files = Content:getFiles(parent) -- 1629
					if renamedDir then -- 1630
						local name = Path:getFilename(new):lower() -- 1631
						for _index_0 = 1, #files do -- 1632
							local file = files[_index_0] -- 1632
							if name == Path:getFilename(file):lower() then -- 1633
								return { -- 1634
									success = false -- 1634
								} -- 1634
							end -- 1633
						end -- 1632
					else -- 1636
						local name = Path:getName(new):lower() -- 1636
						local ext = Path:getExt(new) -- 1637
						for _index_0 = 1, #files do -- 1638
							local file = files[_index_0] -- 1638
							if name == Path:getName(file):lower() then -- 1639
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1640
									goto _continue_0 -- 1641
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1642
									goto _continue_0 -- 1643
								end -- 1640
								return { -- 1644
									success = false -- 1644
								} -- 1644
							end -- 1639
							::_continue_0:: -- 1639
						end -- 1638
					end -- 1630
					if Content:move(old, new) then -- 1645
						if renamedDir then -- 1646
							AgentSession.renameSessionsByProjectRoot(old, new) -- 1647
						end -- 1646
						local newParent = Path:getPath(new) -- 1648
						parent = Path:getPath(old) -- 1649
						files = Content:getFiles(parent) -- 1650
						local newName = Path:getName(new) -- 1651
						local oldName = Path:getName(old) -- 1652
						local name = oldName:lower() -- 1653
						local ext = Path:getExt(old) -- 1654
						for _index_0 = 1, #files do -- 1655
							local file = files[_index_0] -- 1655
							if name == Path:getName(file):lower() then -- 1656
								local _exp_0 = Path:getExt(file) -- 1657
								if "tl" == _exp_0 then -- 1657
									if ("vs" == ext) then -- 1657
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1658
									end -- 1657
								elseif "lua" == _exp_0 then -- 1659
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1659
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1660
									end -- 1659
								end -- 1657
							end -- 1656
						end -- 1655
						return { -- 1661
							success = true -- 1661
						} -- 1661
					end -- 1645
				end -- 1626
			end -- 1625
		end -- 1625
	end -- 1625
	return { -- 1624
		success = false -- 1624
	} -- 1624
end) -- 1624
local withProjectSearchPaths -- 1663
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1663
	local fallbackPaths = { } -- 1664
	local addFallback -- 1665
	addFallback = function(dir) -- 1665
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1665
			fallbackPaths[#fallbackPaths + 1] = dir -- 1665
		end -- 1665
	end -- 1665
	if projectRoot and projectRoot ~= "" then -- 1666
		addFallback(Path(projectRoot, "Script")) -- 1667
		addFallback(projectRoot) -- 1668
	end -- 1666
	if projFile then -- 1669
		local projDir = getProjectDirFromFile(projFile) -- 1670
		if projDir then -- 1670
			addFallback(Path(projDir, "Script")) -- 1671
			addFallback(projDir) -- 1672
		else -- 1674
			addFallback(Path:getPath(projFile)) -- 1674
		end -- 1670
	end -- 1669
	if not (#fallbackPaths > 0) then -- 1675
		return fn() -- 1675
	end -- 1675
	local searchPaths = Content.searchPaths -- 1676
	for _index_0 = 1, #fallbackPaths do -- 1677
		local dir = fallbackPaths[_index_0] -- 1677
		Content:addSearchPath(dir) -- 1677
	end -- 1677
	local _ <close> = setmetatable({ }, { -- 1678
		__close = function() -- 1678
			Content.searchPaths = searchPaths -- 1678
		end -- 1678
	}) -- 1678
	return fn() -- 1679
end -- 1663
HttpServer:post("/exist", function(req) -- 1680
	do -- 1681
		local _type_0 = type(req) -- 1681
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1681
		if _tab_0 then -- 1681
			local file -- 1681
			do -- 1681
				local _obj_0 = req.body -- 1681
				local _type_1 = type(_obj_0) -- 1681
				if "table" == _type_1 or "userdata" == _type_1 then -- 1681
					file = _obj_0.file -- 1681
				end -- 1681
			end -- 1681
			if file ~= nil then -- 1681
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1682
					return { -- 1683
						success = Content:exist(file) -- 1683
					} -- 1683
				end) -- 1682
			end -- 1681
		end -- 1681
	end -- 1681
	return { -- 1680
		success = false -- 1680
	} -- 1680
end) -- 1680
HttpServer:postSchedule("/read", function(req) -- 1684
	do -- 1685
		local _type_0 = type(req) -- 1685
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1685
		if _tab_0 then -- 1685
			local path -- 1685
			do -- 1685
				local _obj_0 = req.body -- 1685
				local _type_1 = type(_obj_0) -- 1685
				if "table" == _type_1 or "userdata" == _type_1 then -- 1685
					path = _obj_0.path -- 1685
				end -- 1685
			end -- 1685
			if path ~= nil then -- 1685
				local readFile -- 1686
				readFile = function() -- 1686
					if Content:exist(path) then -- 1687
						local content = Content:loadAsync(path) -- 1688
						if content then -- 1688
							return { -- 1689
								content = content, -- 1689
								success = true, -- 1689
								fullPath = Content:getFullPath(path) -- 1689
							} -- 1689
						end -- 1688
					end -- 1687
					return nil -- 1686
				end -- 1686
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1690
				if result then -- 1690
					return result -- 1690
				end -- 1690
			end -- 1685
		end -- 1685
	end -- 1685
	return { -- 1684
		success = false -- 1684
	} -- 1684
end) -- 1684
HttpServer:get("/read-sync", function(req) -- 1691
	do -- 1692
		local _type_0 = type(req) -- 1692
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1692
		if _tab_0 then -- 1692
			local params = req.params -- 1692
			if params ~= nil then -- 1692
				local path = params.path -- 1693
				local exts -- 1694
				if params.exts then -- 1694
					local _accum_0 = { } -- 1695
					local _len_0 = 1 -- 1695
					for ext in params.exts:gmatch("[^|]*") do -- 1695
						_accum_0[_len_0] = ext -- 1695
						_len_0 = _len_0 + 1 -- 1695
					end -- 1695
					exts = _accum_0 -- 1695
				else -- 1696
					exts = { -- 1696
						"" -- 1696
					} -- 1696
				end -- 1694
				local readFileAt -- 1697
				readFileAt = function(targetPath) -- 1697
					if Content:exist(targetPath) then -- 1698
						local content = Content:load(targetPath) -- 1699
						if content then -- 1699
							return { -- 1700
								content = content, -- 1700
								success = true, -- 1700
								fullPath = Content:getFullPath(targetPath) -- 1700
							} -- 1700
						end -- 1699
					end -- 1698
					return nil -- 1697
				end -- 1697
				local readFile -- 1701
				readFile = function(fallbackPaths) -- 1701
					for _index_0 = 1, #exts do -- 1702
						local ext = exts[_index_0] -- 1702
						local targetPath = path .. ext -- 1703
						if not Content:isAbsolutePath(targetPath) then -- 1704
							for _index_1 = 1, #fallbackPaths do -- 1705
								local fallback = fallbackPaths[_index_1] -- 1705
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1706
								if fallbackResult then -- 1706
									return fallbackResult -- 1707
								end -- 1706
							end -- 1705
						end -- 1704
						local fileResult = readFileAt(targetPath) -- 1708
						if fileResult then -- 1708
							return fileResult -- 1709
						end -- 1708
					end -- 1702
					return nil -- 1701
				end -- 1701
				local fallbackPaths = { } -- 1710
				local fallbackCandidates = { } -- 1711
				do -- 1712
					local projectRoot = req.params.projectRoot -- 1712
					if projectRoot then -- 1712
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1713
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1714
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1715
						end -- 1713
					end -- 1712
				end -- 1712
				do -- 1716
					local projFile = req.params.projFile -- 1716
					if projFile then -- 1716
						local projDir = getProjectDirFromFile(projFile) -- 1717
						if projDir then -- 1717
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1718
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1719
						else -- 1721
							projDir = Path:getPath(projFile) -- 1721
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1722
						end -- 1717
					end -- 1716
				end -- 1716
				for _index_0 = 1, #fallbackCandidates do -- 1723
					local dir = fallbackCandidates[_index_0] -- 1723
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1724
						local exists = false -- 1725
						for _index_1 = 1, #fallbackPaths do -- 1726
							local fallback = fallbackPaths[_index_1] -- 1726
							if fallback == dir then -- 1727
								exists = true -- 1728
								break -- 1729
							end -- 1727
						end -- 1726
						if not exists then -- 1730
							fallbackPaths[#fallbackPaths + 1] = dir -- 1730
						end -- 1730
					end -- 1724
				end -- 1723
				local readResult = readFile(fallbackPaths) -- 1731
				if readResult then -- 1731
					return readResult -- 1732
				end -- 1731
			end -- 1692
		end -- 1692
	end -- 1692
	return { -- 1691
		success = false -- 1691
	} -- 1691
end) -- 1691
local compileFileAsync -- 1734
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1734
	if projectRoot == nil then -- 1734
		projectRoot = nil -- 1734
	end -- 1734
	local file = inputFile -- 1735
	local searchPath -- 1736
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1736
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1737
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1741
	elseif not Content:isAbsolutePath(inputFile) then -- 1742
		searchPath = "" -- 1743
	else -- 1744
		local dir = getProjectDirFromFile(inputFile) -- 1744
		if dir then -- 1744
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1745
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1749
		else -- 1751
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1751
			searchPath = "" -- 1754
		end -- 1744
	end -- 1736
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1755
	local yueext = yue.options.extension -- 1756
	local resultCodes = nil -- 1757
	local resultError = nil -- 1758
	do -- 1759
		local _exp_0 = Path:getExt(inputFile) -- 1759
		if yueext == _exp_0 then -- 1759
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1760
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1761
				if not codes then -- 1762
					resultError = err -- 1763
					return -- 1764
				end -- 1762
				local extraGlobal -- 1765
				if isTIC80 then -- 1765
					extraGlobal = tic80APIs -- 1765
				else -- 1765
					extraGlobal = nil -- 1765
				end -- 1765
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1766
				if not success then -- 1767
					resultError = message -- 1768
					return -- 1769
				end -- 1767
				if codes == "" then -- 1770
					resultCodes = "" -- 1771
					return nil -- 1772
				end -- 1770
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1773
				return resultCodes -- 1774
			end, function(success) -- 1761
				if not success then -- 1775
					Content:remove(outputFile) -- 1776
					if resultCodes == nil then -- 1777
						resultCodes = false -- 1778
					end -- 1777
				end -- 1775
			end) -- 1761
		elseif "tl" == _exp_0 then -- 1779
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1780
			if isTIC80 then -- 1781
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1782
			end -- 1781
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1783
			if codes then -- 1783
				if isTIC80 then -- 1784
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1785
				end -- 1784
				resultCodes = codes -- 1786
				Content:saveAsync(outputFile, codes) -- 1787
			else -- 1789
				Content:remove(outputFile) -- 1789
				resultCodes = false -- 1790
				resultError = err -- 1791
			end -- 1783
		elseif "xml" == _exp_0 then -- 1792
			local codes, err = xml.tolua(sourceCodes) -- 1793
			if codes then -- 1793
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1794
				Content:saveAsync(outputFile, resultCodes) -- 1795
			else -- 1797
				Content:remove(outputFile) -- 1797
				resultCodes = false -- 1798
				resultError = err -- 1799
			end -- 1793
		end -- 1759
	end -- 1759
	wait(function() -- 1800
		return resultCodes ~= nil -- 1800
	end) -- 1800
	if resultCodes then -- 1801
		return resultCodes -- 1802
	else -- 1804
		return nil, resultError -- 1804
	end -- 1801
	return nil -- 1734
end -- 1734
HttpServer:postSchedule("/write", function(req) -- 1806
	do -- 1807
		local _type_0 = type(req) -- 1807
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1807
		if _tab_0 then -- 1807
			local path -- 1807
			do -- 1807
				local _obj_0 = req.body -- 1807
				local _type_1 = type(_obj_0) -- 1807
				if "table" == _type_1 or "userdata" == _type_1 then -- 1807
					path = _obj_0.path -- 1807
				end -- 1807
			end -- 1807
			local content -- 1807
			do -- 1807
				local _obj_0 = req.body -- 1807
				local _type_1 = type(_obj_0) -- 1807
				if "table" == _type_1 or "userdata" == _type_1 then -- 1807
					content = _obj_0.content -- 1807
				end -- 1807
			end -- 1807
			if path ~= nil and content ~= nil then -- 1807
				if Content:saveAsync(path, content) then -- 1808
					do -- 1809
						local _exp_0 = Path:getExt(path) -- 1809
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1809
							if '' == Path:getExt(Path:getName(path)) then -- 1810
								local resultCodes = compileFileAsync(path, content) -- 1811
								return { -- 1812
									success = true, -- 1812
									resultCodes = resultCodes -- 1812
								} -- 1812
							end -- 1810
						end -- 1809
					end -- 1809
					return { -- 1813
						success = true -- 1813
					} -- 1813
				end -- 1808
			end -- 1807
		end -- 1807
	end -- 1807
	return { -- 1806
		success = false -- 1806
	} -- 1806
end) -- 1806
local getWaProjectDirFromFile = nil -- 1815
HttpServer:postSchedule("/build", function(req) -- 1817
	do -- 1818
		local _type_0 = type(req) -- 1818
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1818
		if _tab_0 then -- 1818
			local path -- 1818
			do -- 1818
				local _obj_0 = req.body -- 1818
				local _type_1 = type(_obj_0) -- 1818
				if "table" == _type_1 or "userdata" == _type_1 then -- 1818
					path = _obj_0.path -- 1818
				end -- 1818
			end -- 1818
			if path ~= nil then -- 1818
				local projectRoot = req.body.projectRoot -- 1819
				if Content:isdir(path) then -- 1820
					local projDir = getWaProjectDirFromFile(path) -- 1821
					if projDir then -- 1821
						local message = Wasm:buildWaAsync(projDir) -- 1822
						if message == "" then -- 1823
							return { -- 1824
								success = true -- 1824
							} -- 1824
						else -- 1826
							return { -- 1826
								success = false, -- 1826
								message = message -- 1826
							} -- 1826
						end -- 1823
					end -- 1821
				end -- 1820
				local _exp_0 = Path:getExt(path) -- 1827
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1828
					if '' == Path:getExt(Path:getName(path)) then -- 1829
						local content = Content:loadAsync(path) -- 1830
						if content then -- 1830
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 1831
							if resultCodes then -- 1831
								return { -- 1832
									success = true, -- 1832
									resultCodes = resultCodes -- 1832
								} -- 1832
							end -- 1831
						end -- 1830
					end -- 1829
				elseif "wa" == _exp_0 then -- 1833
					local projDir = getWaProjectDirFromFile(path) -- 1834
					if projDir then -- 1834
						local message = Wasm:buildWaAsync(projDir) -- 1835
						if message == "" then -- 1836
							return { -- 1837
								success = true -- 1837
							} -- 1837
						else -- 1839
							return { -- 1839
								success = false, -- 1839
								message = message -- 1839
							} -- 1839
						end -- 1836
					else -- 1841
						return { -- 1841
							success = false, -- 1841
							message = 'Wa file needs a project' -- 1841
						} -- 1841
					end -- 1834
				end -- 1827
			end -- 1818
		end -- 1818
	end -- 1818
	return { -- 1817
		success = false -- 1817
	} -- 1817
end) -- 1817
local extentionLevels = { -- 1844
	vs = 2, -- 1844
	bl = 2, -- 1845
	ts = 1, -- 1846
	tsx = 1, -- 1847
	tl = 1, -- 1848
	yue = 1, -- 1849
	xml = 1, -- 1850
	lua = 0 -- 1851
} -- 1843
HttpServer:post("/assets", function() -- 1853
	local Entry = require("Script.Dev.Entry") -- 1856
	local engineDev = Entry.getEngineDev() -- 1857
	local visitAssets -- 1858
	visitAssets = function(path, tag) -- 1858
		local isWorkspace = tag == "Workspace" -- 1859
		local builtin -- 1860
		if tag == "Builtin" then -- 1860
			builtin = true -- 1860
		else -- 1860
			builtin = nil -- 1860
		end -- 1860
		local children = nil -- 1861
		local dirs = Content:getDirs(path) -- 1862
		for _index_0 = 1, #dirs do -- 1863
			local dir = dirs[_index_0] -- 1863
			if isWorkspace then -- 1864
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1865
					goto _continue_0 -- 1866
				end -- 1865
			elseif dir == ".git" then -- 1867
				goto _continue_0 -- 1868
			end -- 1864
			if not children then -- 1869
				children = { } -- 1869
			end -- 1869
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1870
			::_continue_0:: -- 1864
		end -- 1863
		local files = Content:getFiles(path) -- 1871
		local names = { } -- 1872
		for _index_0 = 1, #files do -- 1873
			local file = files[_index_0] -- 1873
			if (".DS_Store" == file) then -- 1874
				goto _continue_1 -- 1875
			end -- 1874
			local name = Path:getName(file) -- 1876
			local ext = names[name] -- 1877
			if ext then -- 1877
				local lv1 -- 1878
				do -- 1878
					local _exp_0 = extentionLevels[ext] -- 1878
					if _exp_0 ~= nil then -- 1878
						lv1 = _exp_0 -- 1878
					else -- 1878
						lv1 = -1 -- 1878
					end -- 1878
				end -- 1878
				ext = Path:getExt(file) -- 1879
				local lv2 -- 1880
				do -- 1880
					local _exp_0 = extentionLevels[ext] -- 1880
					if _exp_0 ~= nil then -- 1880
						lv2 = _exp_0 -- 1880
					else -- 1880
						lv2 = -1 -- 1880
					end -- 1880
				end -- 1880
				if lv2 > lv1 then -- 1881
					names[name] = ext -- 1882
				elseif lv2 == lv1 then -- 1883
					names[name .. '.' .. ext] = "" -- 1884
				end -- 1881
			else -- 1886
				ext = Path:getExt(file) -- 1886
				if not extentionLevels[ext] then -- 1887
					names[file] = "" -- 1888
				else -- 1890
					names[name] = ext -- 1890
				end -- 1887
			end -- 1877
			::_continue_1:: -- 1874
		end -- 1873
		do -- 1891
			local _accum_0 = { } -- 1891
			local _len_0 = 1 -- 1891
			for name, ext in pairs(names) do -- 1891
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1891
				_len_0 = _len_0 + 1 -- 1891
			end -- 1891
			files = _accum_0 -- 1891
		end -- 1891
		for _index_0 = 1, #files do -- 1892
			local file = files[_index_0] -- 1892
			if not children then -- 1893
				children = { } -- 1893
			end -- 1893
			children[#children + 1] = { -- 1895
				key = Path(path, file), -- 1895
				dir = false, -- 1896
				title = file, -- 1897
				builtin = builtin -- 1898
			} -- 1894
		end -- 1892
		if children then -- 1900
			table.sort(children, function(a, b) -- 1901
				if a.dir == b.dir then -- 1902
					return a.title < b.title -- 1903
				else -- 1905
					return a.dir -- 1905
				end -- 1902
			end) -- 1901
		end -- 1900
		if isWorkspace and children then -- 1906
			return children -- 1907
		else -- 1909
			return { -- 1910
				key = path, -- 1910
				dir = true, -- 1911
				title = Path:getFilename(path), -- 1912
				builtin = builtin, -- 1913
				children = children -- 1914
			} -- 1909
		end -- 1906
	end -- 1858
	local zh = (App.locale:match("^zh") ~= nil) -- 1916
	return { -- 1918
		key = Content.writablePath, -- 1918
		dir = true, -- 1919
		root = true, -- 1920
		title = "Assets", -- 1921
		children = (function() -- 1923
			local _tab_0 = { -- 1923
				{ -- 1924
					key = Path(Content.assetPath), -- 1924
					dir = true, -- 1925
					builtin = true, -- 1926
					title = zh and "内置资源" or "Built-in", -- 1927
					children = { -- 1929
						(function() -- 1929
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1929
							_with_0.title = zh and "说明文档" or "Readme" -- 1930
							return _with_0 -- 1929
						end)(), -- 1929
						(function() -- 1931
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1931
							_with_0.title = zh and "接口文档" or "API Doc" -- 1932
							return _with_0 -- 1931
						end)(), -- 1931
						(function() -- 1933
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1933
							_with_0.title = zh and "开发工具" or "Tools" -- 1934
							return _with_0 -- 1933
						end)(), -- 1933
						(function() -- 1935
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1935
							_with_0.title = zh and "字体" or "Font" -- 1936
							return _with_0 -- 1935
						end)(), -- 1935
						(function() -- 1937
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1937
							_with_0.title = zh and "程序库" or "Lib" -- 1938
							if engineDev then -- 1939
								local _list_0 = _with_0.children -- 1940
								for _index_0 = 1, #_list_0 do -- 1940
									local child = _list_0[_index_0] -- 1940
									if not (child.title == "Dora") then -- 1941
										goto _continue_0 -- 1941
									end -- 1941
									local title = zh and "zh-Hans" or "en" -- 1942
									do -- 1943
										local _accum_0 = { } -- 1943
										local _len_0 = 1 -- 1943
										local _list_1 = child.children -- 1943
										for _index_1 = 1, #_list_1 do -- 1943
											local c = _list_1[_index_1] -- 1943
											if c.title ~= title then -- 1943
												_accum_0[_len_0] = c -- 1943
												_len_0 = _len_0 + 1 -- 1943
											end -- 1943
										end -- 1943
										child.children = _accum_0 -- 1943
									end -- 1943
									break -- 1944
									::_continue_0:: -- 1941
								end -- 1940
							else -- 1946
								local _accum_0 = { } -- 1946
								local _len_0 = 1 -- 1946
								local _list_0 = _with_0.children -- 1946
								for _index_0 = 1, #_list_0 do -- 1946
									local child = _list_0[_index_0] -- 1946
									if child.title ~= "Dora" then -- 1946
										_accum_0[_len_0] = child -- 1946
										_len_0 = _len_0 + 1 -- 1946
									end -- 1946
								end -- 1946
								_with_0.children = _accum_0 -- 1946
							end -- 1939
							return _with_0 -- 1937
						end)(), -- 1937
						(function() -- 1947
							if engineDev then -- 1947
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1948
								local _obj_0 = _with_0.children -- 1949
								_obj_0[#_obj_0 + 1] = { -- 1950
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1950
									dir = false, -- 1951
									builtin = true, -- 1952
									title = "init.yue" -- 1953
								} -- 1949
								return _with_0 -- 1948
							end -- 1947
						end)() -- 1947
					} -- 1928
				} -- 1923
			} -- 1957
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1957
			local _idx_0 = #_tab_0 + 1 -- 1957
			for _index_0 = 1, #_obj_0 do -- 1957
				local _value_0 = _obj_0[_index_0] -- 1957
				_tab_0[_idx_0] = _value_0 -- 1957
				_idx_0 = _idx_0 + 1 -- 1957
			end -- 1957
			return _tab_0 -- 1923
		end)() -- 1922
	} -- 1917
end) -- 1853
HttpServer:post("/entry/list", function() -- 1961
	local Entry = require("Script.Dev.Entry") -- 1962
	local res = Entry.getLaunchEntries() -- 1963
	res.success = true -- 1964
	return res -- 1965
end) -- 1961
HttpServer:post("/run/status", function() -- 1967
	local Entry = require("Script.Dev.Entry") -- 1968
	return Entry.getCurrentEntryStatus() -- 1969
end) -- 1967
HttpServer:postSchedule("/run", function(req) -- 1971
	do -- 1972
		local _type_0 = type(req) -- 1972
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1972
		if _tab_0 then -- 1972
			local file -- 1972
			do -- 1972
				local _obj_0 = req.body -- 1972
				local _type_1 = type(_obj_0) -- 1972
				if "table" == _type_1 or "userdata" == _type_1 then -- 1972
					file = _obj_0.file -- 1972
				end -- 1972
			end -- 1972
			local asProj -- 1972
			do -- 1972
				local _obj_0 = req.body -- 1972
				local _type_1 = type(_obj_0) -- 1972
				if "table" == _type_1 or "userdata" == _type_1 then -- 1972
					asProj = _obj_0.asProj -- 1972
				end -- 1972
			end -- 1972
			if file ~= nil and asProj ~= nil then -- 1972
				if not Content:isAbsolutePath(file) then -- 1973
					local devFile = Path(Content.writablePath, file) -- 1974
					if Content:exist(devFile) then -- 1975
						file = devFile -- 1975
					end -- 1975
				end -- 1973
				local Entry = require("Script.Dev.Entry") -- 1976
				local workDir -- 1977
				if asProj then -- 1978
					local projectRoot = req.body.projectRoot -- 1979
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1980
						workDir = projectRoot -- 1981
					else -- 1983
						workDir = getProjectDirFromFile(file) -- 1983
					end -- 1980
					if workDir then -- 1984
						Entry.allClear() -- 1985
						local target = Path(workDir, "init") -- 1986
						local success, err = Entry.enterEntryAsync({ -- 1987
							entryName = "Project", -- 1987
							fileName = target, -- 1987
							workDir = workDir, -- 1987
							projectRoot = workDir, -- 1987
							runKind = "project" -- 1987
						}) -- 1987
						target = Path:getName(Path:getPath(target)) -- 1988
						return { -- 1989
							success = success, -- 1989
							target = target, -- 1989
							err = err -- 1989
						} -- 1989
					end -- 1984
				else -- 1991
					workDir = getProjectDirFromFile(file) -- 1991
					if not workDir and Path:getExt(file) == "wasm" then -- 1992
						local parent = Path:getPath(file) -- 1993
						if Content:exist(Path(parent, "wa.mod")) then -- 1994
							workDir = parent -- 1995
						end -- 1994
					end -- 1992
				end -- 1978
				Entry.allClear() -- 1996
				file = Path:replaceExt(file, "") -- 1997
				local entry = { -- 1999
					entryName = Path:getName(file), -- 1999
					fileName = file, -- 2000
					runKind = "file" -- 2001
				} -- 1998
				if workDir then -- 2002
					entry.workDir = workDir -- 2003
					entry.projectRoot = workDir -- 2004
				end -- 2002
				local success, err = Entry.enterEntryAsync(entry) -- 2005
				return { -- 2006
					success = success, -- 2006
					err = err -- 2006
				} -- 2006
			end -- 1972
		end -- 1972
	end -- 1972
	return { -- 1971
		success = false -- 1971
	} -- 1971
end) -- 1971
HttpServer:postSchedule("/stop", function() -- 2008
	local Entry = require("Script.Dev.Entry") -- 2009
	return { -- 2010
		success = Entry.stop() -- 2010
	} -- 2010
end) -- 2008
local minifyAsync -- 2012
minifyAsync = function(sourcePath, minifyPath) -- 2012
	if not Content:exist(sourcePath) then -- 2013
		return -- 2013
	end -- 2013
	local Entry = require("Script.Dev.Entry") -- 2014
	local errors = { } -- 2015
	local files = Entry.getAllFiles(sourcePath, { -- 2016
		"lua" -- 2016
	}, true) -- 2016
	do -- 2017
		local _accum_0 = { } -- 2017
		local _len_0 = 1 -- 2017
		for _index_0 = 1, #files do -- 2017
			local file = files[_index_0] -- 2017
			if file:sub(1, 1) ~= '.' then -- 2017
				_accum_0[_len_0] = file -- 2017
				_len_0 = _len_0 + 1 -- 2017
			end -- 2017
		end -- 2017
		files = _accum_0 -- 2017
	end -- 2017
	local paths -- 2018
	do -- 2018
		local _tbl_0 = { } -- 2018
		for _index_0 = 1, #files do -- 2018
			local file = files[_index_0] -- 2018
			_tbl_0[Path:getPath(file)] = true -- 2018
		end -- 2018
		paths = _tbl_0 -- 2018
	end -- 2018
	for path in pairs(paths) do -- 2019
		Content:mkdir(Path(minifyPath, path)) -- 2019
	end -- 2019
	local _ <close> = setmetatable({ }, { -- 2020
		__close = function() -- 2020
			package.loaded["luaminify.FormatMini"] = nil -- 2021
			package.loaded["luaminify.ParseLua"] = nil -- 2022
			package.loaded["luaminify.Scope"] = nil -- 2023
			package.loaded["luaminify.Util"] = nil -- 2024
		end -- 2020
	}) -- 2020
	local FormatMini -- 2025
	do -- 2025
		local _obj_0 = require("luaminify") -- 2025
		FormatMini = _obj_0.FormatMini -- 2025
	end -- 2025
	local fileCount = #files -- 2026
	local count = 0 -- 2027
	for _index_0 = 1, #files do -- 2028
		local file = files[_index_0] -- 2028
		thread(function() -- 2029
			local _ <close> = setmetatable({ }, { -- 2030
				__close = function() -- 2030
					count = count + 1 -- 2030
				end -- 2030
			}) -- 2030
			local input = Path(sourcePath, file) -- 2031
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2032
			if Content:exist(input) then -- 2033
				local sourceCodes = Content:loadAsync(input) -- 2034
				local res, err = FormatMini(sourceCodes) -- 2035
				if res then -- 2036
					Content:saveAsync(output, res) -- 2037
					return print("Minify " .. tostring(file)) -- 2038
				else -- 2040
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2040
				end -- 2036
			else -- 2042
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2042
			end -- 2033
		end) -- 2029
		sleep() -- 2043
	end -- 2028
	wait(function() -- 2044
		return count == fileCount -- 2044
	end) -- 2044
	if #errors > 0 then -- 2045
		print(table.concat(errors, '\n')) -- 2046
	end -- 2045
	print("Obfuscation done.") -- 2047
	return files -- 2048
end -- 2012
local zipping = false -- 2050
HttpServer:postSchedule("/zip", function(req) -- 2052
	do -- 2053
		local _type_0 = type(req) -- 2053
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2053
		if _tab_0 then -- 2053
			local path -- 2053
			do -- 2053
				local _obj_0 = req.body -- 2053
				local _type_1 = type(_obj_0) -- 2053
				if "table" == _type_1 or "userdata" == _type_1 then -- 2053
					path = _obj_0.path -- 2053
				end -- 2053
			end -- 2053
			local zipFile -- 2053
			do -- 2053
				local _obj_0 = req.body -- 2053
				local _type_1 = type(_obj_0) -- 2053
				if "table" == _type_1 or "userdata" == _type_1 then -- 2053
					zipFile = _obj_0.zipFile -- 2053
				end -- 2053
			end -- 2053
			local obfuscated -- 2053
			do -- 2053
				local _obj_0 = req.body -- 2053
				local _type_1 = type(_obj_0) -- 2053
				if "table" == _type_1 or "userdata" == _type_1 then -- 2053
					obfuscated = _obj_0.obfuscated -- 2053
				end -- 2053
			end -- 2053
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2053
				if zipping then -- 2054
					goto failed -- 2054
				end -- 2054
				zipping = true -- 2055
				local _ <close> = setmetatable({ }, { -- 2056
					__close = function() -- 2056
						zipping = false -- 2056
					end -- 2056
				}) -- 2056
				if not Content:exist(path) then -- 2057
					goto failed -- 2057
				end -- 2057
				Content:mkdir(Path:getPath(zipFile)) -- 2058
				if obfuscated then -- 2059
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2060
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2061
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2062
					Content:remove(scriptPath) -- 2063
					Content:remove(obfuscatedPath) -- 2064
					Content:remove(tempPath) -- 2065
					Content:mkdir(scriptPath) -- 2066
					Content:mkdir(obfuscatedPath) -- 2067
					Content:mkdir(tempPath) -- 2068
					if not Content:copyAsync(path, tempPath) then -- 2069
						goto failed -- 2069
					end -- 2069
					local Entry = require("Script.Dev.Entry") -- 2070
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2071
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2072
						"tl", -- 2072
						"yue", -- 2072
						"lua", -- 2072
						"ts", -- 2072
						"tsx", -- 2072
						"vs", -- 2072
						"bl", -- 2072
						"xml", -- 2072
						"wa", -- 2072
						"mod" -- 2072
					}, true) -- 2072
					for _index_0 = 1, #scriptFiles do -- 2073
						local file = scriptFiles[_index_0] -- 2073
						Content:remove(Path(tempPath, file)) -- 2074
					end -- 2073
					for _index_0 = 1, #luaFiles do -- 2075
						local file = luaFiles[_index_0] -- 2075
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2076
					end -- 2075
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2077
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2078
					end) then -- 2077
						goto failed -- 2077
					end -- 2077
					return { -- 2079
						success = true -- 2079
					} -- 2079
				else -- 2081
					return { -- 2081
						success = Content:zipAsync(path, zipFile, function(file) -- 2081
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2082
						end) -- 2081
					} -- 2081
				end -- 2059
			end -- 2053
		end -- 2053
	end -- 2053
	::failed:: -- 2083
	return { -- 2052
		success = false -- 2052
	} -- 2052
end) -- 2052
HttpServer:postSchedule("/unzip", function(req) -- 2085
	do -- 2086
		local _type_0 = type(req) -- 2086
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2086
		if _tab_0 then -- 2086
			local zipFile -- 2086
			do -- 2086
				local _obj_0 = req.body -- 2086
				local _type_1 = type(_obj_0) -- 2086
				if "table" == _type_1 or "userdata" == _type_1 then -- 2086
					zipFile = _obj_0.zipFile -- 2086
				end -- 2086
			end -- 2086
			local path -- 2086
			do -- 2086
				local _obj_0 = req.body -- 2086
				local _type_1 = type(_obj_0) -- 2086
				if "table" == _type_1 or "userdata" == _type_1 then -- 2086
					path = _obj_0.path -- 2086
				end -- 2086
			end -- 2086
			if zipFile ~= nil and path ~= nil then -- 2086
				return { -- 2087
					success = Content:unzipAsync(zipFile, path, function(file) -- 2087
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2088
					end) -- 2087
				} -- 2087
			end -- 2086
		end -- 2086
	end -- 2086
	return { -- 2085
		success = false -- 2085
	} -- 2085
end) -- 2085
HttpServer:post("/editing-info", function(req) -- 2090
	local Entry = require("Script.Dev.Entry") -- 2091
	local config = Entry.getConfig() -- 2092
	local _type_0 = type(req) -- 2093
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2093
	local _match_0 = false -- 2093
	if _tab_0 then -- 2093
		local editingInfo -- 2093
		do -- 2093
			local _obj_0 = req.body -- 2093
			local _type_1 = type(_obj_0) -- 2093
			if "table" == _type_1 or "userdata" == _type_1 then -- 2093
				editingInfo = _obj_0.editingInfo -- 2093
			end -- 2093
		end -- 2093
		if editingInfo ~= nil then -- 2093
			_match_0 = true -- 2093
			config.editingInfo = editingInfo -- 2094
			return { -- 2095
				success = true -- 2095
			} -- 2095
		end -- 2093
	end -- 2093
	if not _match_0 then -- 2093
		if not (config.editingInfo ~= nil) then -- 2097
			local folder -- 2098
			if App.locale:match('^zh') then -- 2098
				folder = 'zh-Hans' -- 2098
			else -- 2098
				folder = 'en' -- 2098
			end -- 2098
			config.editingInfo = json.encode({ -- 2100
				index = 0, -- 2100
				files = { -- 2102
					{ -- 2103
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2103
						title = "welcome.md" -- 2104
					} -- 2102
				} -- 2101
			}) -- 2099
		end -- 2097
		return { -- 2108
			success = true, -- 2108
			editingInfo = config.editingInfo -- 2108
		} -- 2108
	end -- 2093
end) -- 2090
HttpServer:post("/command", function(req) -- 2110
	do -- 2111
		local _type_0 = type(req) -- 2111
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2111
		if _tab_0 then -- 2111
			local code -- 2111
			do -- 2111
				local _obj_0 = req.body -- 2111
				local _type_1 = type(_obj_0) -- 2111
				if "table" == _type_1 or "userdata" == _type_1 then -- 2111
					code = _obj_0.code -- 2111
				end -- 2111
			end -- 2111
			local log -- 2111
			do -- 2111
				local _obj_0 = req.body -- 2111
				local _type_1 = type(_obj_0) -- 2111
				if "table" == _type_1 or "userdata" == _type_1 then -- 2111
					log = _obj_0.log -- 2111
				end -- 2111
			end -- 2111
			if code ~= nil and log ~= nil then -- 2111
				emit("AppCommand", code, log) -- 2112
				return { -- 2113
					success = true -- 2113
				} -- 2113
			end -- 2111
		end -- 2111
	end -- 2111
	return { -- 2110
		success = false -- 2110
	} -- 2110
end) -- 2110
HttpServer:post("/log/save", function() -- 2115
	local folder = ".download" -- 2116
	local fullLogFile = "dora_full_logs.txt" -- 2117
	local fullFolder = Path(Content.writablePath, folder) -- 2118
	Content:mkdir(fullFolder) -- 2119
	local logPath = Path(fullFolder, fullLogFile) -- 2120
	if App:saveLog(logPath) then -- 2121
		return { -- 2122
			success = true, -- 2122
			path = Path(folder, fullLogFile) -- 2122
		} -- 2122
	end -- 2121
	return { -- 2115
		success = false -- 2115
	} -- 2115
end) -- 2115
local tailLines -- 2124
tailLines = function(text, count) -- 2124
	local lines = { } -- 2125
	text = text:gsub("\r\n", "\n") -- 2126
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2127
		lines[#lines + 1] = line -- 2128
	end -- 2127
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2129
		table.remove(lines) -- 2130
	end -- 2129
	local start = math.max(1, #lines - count + 1) -- 2131
	local out = { } -- 2132
	for i = start, #lines do -- 2133
		out[#out + 1] = lines[i] -- 2134
	end -- 2133
	return table.concat(out, "\n") -- 2135
end -- 2124
HttpServer:post("/log", function(req) -- 2137
	local count = 100 -- 2138
	if req and req.body and req.body.count ~= nil then -- 2139
		count = req.body.count -- 2140
	end -- 2139
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2141
		return { -- 2142
			success = false, -- 2142
			message = "count must be a positive integer" -- 2142
		} -- 2142
	end -- 2141
	local folder = ".download" -- 2143
	local fullLogFile = "dora_full_logs.txt" -- 2144
	local fullFolder = Path(Content.writablePath, folder) -- 2145
	Content:mkdir(fullFolder) -- 2146
	local logPath = Path(fullFolder, fullLogFile) -- 2147
	if App:saveLog(logPath) then -- 2148
		local text = Content:load(logPath) -- 2149
		if text then -- 2150
			return { -- 2151
				success = true, -- 2151
				log = tailLines(text, count) -- 2151
			} -- 2151
		else -- 2153
			return { -- 2153
				success = false, -- 2153
				message = "failed to read log" -- 2153
			} -- 2153
		end -- 2150
	else -- 2155
		return { -- 2155
			success = false, -- 2155
			message = "failed to save log" -- 2155
		} -- 2155
	end -- 2148
	return { -- 2137
		success = false -- 2137
	} -- 2137
end) -- 2137
HttpServer:post("/yarn/check", function(req) -- 2157
	local yarncompile = require("yarncompile") -- 2158
	do -- 2159
		local _type_0 = type(req) -- 2159
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2159
		if _tab_0 then -- 2159
			local code -- 2159
			do -- 2159
				local _obj_0 = req.body -- 2159
				local _type_1 = type(_obj_0) -- 2159
				if "table" == _type_1 or "userdata" == _type_1 then -- 2159
					code = _obj_0.code -- 2159
				end -- 2159
			end -- 2159
			if code ~= nil then -- 2159
				local jsonObject = json.decode(code) -- 2160
				if jsonObject then -- 2160
					local errors = { } -- 2161
					local _list_0 = jsonObject.nodes -- 2162
					for _index_0 = 1, #_list_0 do -- 2162
						local node = _list_0[_index_0] -- 2162
						local title, body = node.title, node.body -- 2163
						local luaCode, err = yarncompile(body) -- 2164
						if not luaCode then -- 2164
							errors[#errors + 1] = title .. ":" .. err -- 2165
						end -- 2164
					end -- 2162
					return { -- 2166
						success = true, -- 2166
						syntaxError = table.concat(errors, "\n\n") -- 2166
					} -- 2166
				end -- 2160
			end -- 2159
		end -- 2159
	end -- 2159
	return { -- 2157
		success = false -- 2157
	} -- 2157
end) -- 2157
HttpServer:post("/yarn/check-file", function(req) -- 2168
	local yarncompile = require("yarncompile") -- 2169
	do -- 2170
		local _type_0 = type(req) -- 2170
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2170
		if _tab_0 then -- 2170
			local code -- 2170
			do -- 2170
				local _obj_0 = req.body -- 2170
				local _type_1 = type(_obj_0) -- 2170
				if "table" == _type_1 or "userdata" == _type_1 then -- 2170
					code = _obj_0.code -- 2170
				end -- 2170
			end -- 2170
			if code ~= nil then -- 2170
				local res, _, err = yarncompile(code, true) -- 2171
				if not res then -- 2171
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2172
					return { -- 2173
						success = false, -- 2173
						message = message, -- 2173
						line = line, -- 2173
						column = column, -- 2173
						node = node -- 2173
					} -- 2173
				end -- 2171
			end -- 2170
		end -- 2170
	end -- 2170
	return { -- 2168
		success = true -- 2168
	} -- 2168
end) -- 2168
getWaProjectDirFromFile = function(file) -- 2175
	local current -- 2176
	if Content:isdir(file) then -- 2176
		current = file -- 2176
	else -- 2176
		current = Path:getPath(file) -- 2176
	end -- 2176
	if current == "" then -- 2177
		return nil -- 2177
	end -- 2177
	repeat -- 2178
		local modPath = Path(current, "wa.mod") -- 2179
		if Content:exist(modPath) then -- 2180
			return current, modPath -- 2181
		end -- 2180
		local parent = Path:getPath(current) -- 2182
		if parent == "" or parent == current then -- 2183
			break -- 2183
		end -- 2183
		current = parent -- 2184
	until false -- 2178
	return nil -- 2186
end -- 2175
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2188
	do -- 2189
		local _type_0 = type(req) -- 2189
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2189
		if _tab_0 then -- 2189
			local path -- 2189
			do -- 2189
				local _obj_0 = req.body -- 2189
				local _type_1 = type(_obj_0) -- 2189
				if "table" == _type_1 or "userdata" == _type_1 then -- 2189
					path = _obj_0.path -- 2189
				end -- 2189
			end -- 2189
			if path ~= nil then -- 2189
				local projDir = getWaProjectDirFromFile(path) -- 2190
				if projDir then -- 2190
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2191
					if not Content:exist(sourceDoraPath) then -- 2192
						return { -- 2193
							success = false, -- 2193
							message = "missing dora template" -- 2193
						} -- 2193
					end -- 2192
					local targetVendorPath = Path(projDir, "vendor") -- 2194
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2195
					if not Content:exist(targetVendorPath) then -- 2196
						if not Content:mkdir(targetVendorPath) then -- 2197
							return { -- 2198
								success = false, -- 2198
								message = "failed to create vendor folder" -- 2198
							} -- 2198
						end -- 2197
					elseif not Content:isdir(targetVendorPath) then -- 2199
						return { -- 2200
							success = false, -- 2200
							message = "vendor path is not a folder" -- 2200
						} -- 2200
					end -- 2196
					if Content:exist(targetDoraPath) then -- 2201
						if not Content:remove(targetDoraPath) then -- 2202
							return { -- 2203
								success = false, -- 2203
								message = "failed to remove old dora" -- 2203
							} -- 2203
						end -- 2202
					end -- 2201
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2204
						return { -- 2205
							success = false, -- 2205
							message = "failed to copy dora" -- 2205
						} -- 2205
					end -- 2204
					return { -- 2206
						success = true -- 2206
					} -- 2206
				else -- 2208
					return { -- 2208
						success = false, -- 2208
						message = 'Wa file needs a project' -- 2208
					} -- 2208
				end -- 2190
			end -- 2189
		end -- 2189
	end -- 2189
	return { -- 2188
		success = false, -- 2188
		message = "invalid call" -- 2188
	} -- 2188
end) -- 2188
HttpServer:postSchedule("/wa/build", function(req) -- 2210
	do -- 2211
		local _type_0 = type(req) -- 2211
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2211
		if _tab_0 then -- 2211
			local path -- 2211
			do -- 2211
				local _obj_0 = req.body -- 2211
				local _type_1 = type(_obj_0) -- 2211
				if "table" == _type_1 or "userdata" == _type_1 then -- 2211
					path = _obj_0.path -- 2211
				end -- 2211
			end -- 2211
			if path ~= nil then -- 2211
				local projDir = getWaProjectDirFromFile(path) -- 2212
				if projDir then -- 2212
					local message = Wasm:buildWaAsync(projDir) -- 2213
					if message == "" then -- 2214
						return { -- 2215
							success = true -- 2215
						} -- 2215
					else -- 2217
						return { -- 2217
							success = false, -- 2217
							message = message -- 2217
						} -- 2217
					end -- 2214
				else -- 2219
					return { -- 2219
						success = false, -- 2219
						message = 'Wa file needs a project' -- 2219
					} -- 2219
				end -- 2212
			end -- 2211
		end -- 2211
	end -- 2211
	return { -- 2220
		success = false, -- 2220
		message = 'failed to build' -- 2220
	} -- 2220
end) -- 2210
HttpServer:postSchedule("/wa/format", function(req) -- 2222
	do -- 2223
		local _type_0 = type(req) -- 2223
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2223
		if _tab_0 then -- 2223
			local file -- 2223
			do -- 2223
				local _obj_0 = req.body -- 2223
				local _type_1 = type(_obj_0) -- 2223
				if "table" == _type_1 or "userdata" == _type_1 then -- 2223
					file = _obj_0.file -- 2223
				end -- 2223
			end -- 2223
			if file ~= nil then -- 2223
				local code = Wasm:formatWaAsync(file) -- 2224
				if code == "" then -- 2225
					return { -- 2226
						success = false -- 2226
					} -- 2226
				else -- 2228
					return { -- 2228
						success = true, -- 2228
						code = code -- 2228
					} -- 2228
				end -- 2225
			end -- 2223
		end -- 2223
	end -- 2223
	return { -- 2229
		success = false -- 2229
	} -- 2229
end) -- 2222
HttpServer:postSchedule("/wa/create", function(req) -- 2231
	do -- 2232
		local _type_0 = type(req) -- 2232
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2232
		if _tab_0 then -- 2232
			local path -- 2232
			do -- 2232
				local _obj_0 = req.body -- 2232
				local _type_1 = type(_obj_0) -- 2232
				if "table" == _type_1 or "userdata" == _type_1 then -- 2232
					path = _obj_0.path -- 2232
				end -- 2232
			end -- 2232
			if path ~= nil then -- 2232
				if not Content:exist(Path:getPath(path)) then -- 2233
					return { -- 2234
						success = false, -- 2234
						message = "target path not existed" -- 2234
					} -- 2234
				end -- 2233
				if Content:exist(path) then -- 2235
					return { -- 2236
						success = false, -- 2236
						message = "target project folder existed" -- 2236
					} -- 2236
				end -- 2235
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2237
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2238
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2239
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2240
					return { -- 2243
						success = false, -- 2243
						message = "missing template project" -- 2243
					} -- 2243
				end -- 2240
				if not Content:mkdir(path) then -- 2244
					return { -- 2245
						success = false, -- 2245
						message = "failed to create project folder" -- 2245
					} -- 2245
				end -- 2244
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2246
					Content:remove(path) -- 2247
					return { -- 2248
						success = false, -- 2248
						message = "failed to copy template" -- 2248
					} -- 2248
				end -- 2246
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2249
					Content:remove(path) -- 2250
					return { -- 2251
						success = false, -- 2251
						message = "failed to copy template" -- 2251
					} -- 2251
				end -- 2249
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2252
					Content:remove(path) -- 2253
					return { -- 2254
						success = false, -- 2254
						message = "failed to copy template" -- 2254
					} -- 2254
				end -- 2252
				return { -- 2255
					success = true -- 2255
				} -- 2255
			end -- 2232
		end -- 2232
	end -- 2232
	return { -- 2231
		success = false, -- 2231
		message = "invalid call" -- 2231
	} -- 2231
end) -- 2231
local tsBuildGlobs = { -- 2258
	"**/*.ts", -- 2258
	"**/*.tsx", -- 2259
	"!**/.*/**", -- 2260
	"!**/node_modules/**" -- 2261
} -- 2257
local transpileTSFile -- 2263
do -- 2263
	local tsBuildTimeout <const> = 30 -- 2264
	local tsBuildRequestId = 0 -- 2265
	transpileTSFile = function(file, content, sourceRoot) -- 2266
		tsBuildRequestId = tsBuildRequestId + 1 -- 2267
		local requestId = tsBuildRequestId -- 2268
		local done = false -- 2269
		local result = nil -- 2270
		local listener = Node() -- 2271
		listener:gslot("AppWS", function(event) -- 2272
			if event.type == "Receive" then -- 2273
				local res = json.decode(event.msg) -- 2274
				if res then -- 2274
					if res.name == "TranspileTS" and res.id == requestId then -- 2275
						listener:removeFromParent() -- 2276
						if res.success then -- 2277
							local luaFile = Path:replaceExt(file, "lua") -- 2278
							Content:save(luaFile, res.luaCode) -- 2279
							result = { -- 2280
								success = true, -- 2280
								file = file -- 2280
							} -- 2280
						else -- 2282
							result = { -- 2282
								success = false, -- 2282
								file = file, -- 2282
								message = res.message -- 2282
							} -- 2282
						end -- 2277
						done = true -- 2283
					end -- 2275
				end -- 2274
			end -- 2273
		end) -- 2272
		emit("AppWS", "Send", json.encode({ -- 2284
			name = "TranspileTS", -- 2284
			id = requestId, -- 2284
			file = file, -- 2284
			content = content, -- 2284
			projectRoot = sourceRoot -- 2284
		})) -- 2284
		local deadline = App.runningTime + tsBuildTimeout -- 2285
		wait(function() -- 2286
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline -- 2286
		end) -- 2286
		if not done then -- 2287
			listener:removeFromParent() -- 2288
			if HttpServer.wsConnectionCount == 0 then -- 2289
				return { -- 2290
					success = false, -- 2290
					file = file, -- 2290
					message = "Web IDE disconnected" -- 2290
				} -- 2290
			end -- 2289
			return { -- 2291
				success = false, -- 2291
				file = file, -- 2291
				message = "TypeScript transpile timed out" -- 2291
			} -- 2291
		end -- 2287
		return result -- 2292
	end -- 2266
end -- 2263
local _anon_func_6 = function(path) -- 2303
	local _val_0 = Path:getExt(path) -- 2303
	return "ts" == _val_0 or "tsx" == _val_0 -- 2303
end -- 2303
HttpServer:postSchedule("/ts/build", function(req) -- 2294
	do -- 2295
		local _type_0 = type(req) -- 2295
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2295
		if _tab_0 then -- 2295
			local path -- 2295
			do -- 2295
				local _obj_0 = req.body -- 2295
				local _type_1 = type(_obj_0) -- 2295
				if "table" == _type_1 or "userdata" == _type_1 then -- 2295
					path = _obj_0.path -- 2295
				end -- 2295
			end -- 2295
			if path ~= nil then -- 2295
				if HttpServer.wsConnectionCount == 0 then -- 2296
					return { -- 2297
						success = false, -- 2297
						message = "Web IDE not connected" -- 2297
					} -- 2297
				end -- 2296
				local projectRoot = req.body.projectRoot -- 2298
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2299
				if not Content:exist(path) then -- 2300
					return { -- 2301
						success = false, -- 2301
						message = "path not existed" -- 2301
					} -- 2301
				end -- 2300
				if not Content:isdir(path) then -- 2302
					if not (_anon_func_6(path)) then -- 2303
						return { -- 2304
							success = false, -- 2304
							message = "expecting a TypeScript file" -- 2304
						} -- 2304
					end -- 2303
					local messages = { } -- 2305
					local content = Content:load(path) -- 2306
					if not content then -- 2307
						return { -- 2308
							success = false, -- 2308
							message = "failed to read file" -- 2308
						} -- 2308
					end -- 2307
					emit("AppWS", "Send", json.encode({ -- 2309
						name = "UpdateFile", -- 2309
						file = path, -- 2309
						exists = true, -- 2309
						content = content, -- 2309
						projectRoot = sourceRoot -- 2309
					})) -- 2309
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2310
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot) -- 2311
					end -- 2310
					return { -- 2312
						success = true, -- 2312
						messages = messages -- 2312
					} -- 2312
				else -- 2314
					local fileData = { } -- 2314
					local messages = { } -- 2315
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2316
					for _index_0 = 1, #_list_0 do -- 2316
						local subFile = _list_0[_index_0] -- 2316
						local file = Path(path, subFile) -- 2317
						local content = Content:load(file) -- 2318
						if content then -- 2318
							fileData[file] = content -- 2319
							emit("AppWS", "Send", json.encode({ -- 2320
								name = "UpdateFile", -- 2320
								file = file, -- 2320
								exists = true, -- 2320
								content = content, -- 2320
								projectRoot = sourceRoot -- 2320
							})) -- 2320
						else -- 2322
							messages[#messages + 1] = { -- 2322
								success = false, -- 2322
								file = file, -- 2322
								message = "failed to read file" -- 2322
							} -- 2322
						end -- 2318
					end -- 2316
					for file, content in pairs(fileData) do -- 2323
						if "d" == Path:getExt(Path:getName(file)) then -- 2324
							goto _continue_0 -- 2324
						end -- 2324
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot) -- 2325
						::_continue_0:: -- 2324
					end -- 2323
					return { -- 2326
						success = true, -- 2326
						messages = messages -- 2326
					} -- 2326
				end -- 2302
			end -- 2295
		end -- 2295
	end -- 2295
	return { -- 2294
		success = false -- 2294
	} -- 2294
end) -- 2294
HttpServer:post("/download", function(req) -- 2328
	do -- 2329
		local _type_0 = type(req) -- 2329
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2329
		if _tab_0 then -- 2329
			local url -- 2329
			do -- 2329
				local _obj_0 = req.body -- 2329
				local _type_1 = type(_obj_0) -- 2329
				if "table" == _type_1 or "userdata" == _type_1 then -- 2329
					url = _obj_0.url -- 2329
				end -- 2329
			end -- 2329
			local target -- 2329
			do -- 2329
				local _obj_0 = req.body -- 2329
				local _type_1 = type(_obj_0) -- 2329
				if "table" == _type_1 or "userdata" == _type_1 then -- 2329
					target = _obj_0.target -- 2329
				end -- 2329
			end -- 2329
			if url ~= nil and target ~= nil then -- 2329
				local Entry = require("Script.Dev.Entry") -- 2330
				Entry.downloadFile(url, target) -- 2331
				return { -- 2332
					success = true -- 2332
				} -- 2332
			end -- 2329
		end -- 2329
	end -- 2329
	return { -- 2328
		success = false -- 2328
	} -- 2328
end) -- 2328
local isDesktopPlatform -- 2334
isDesktopPlatform = function() -- 2334
	local _val_0 = App.platform -- 2335
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2335
end -- 2334
local getServerStatus -- 2337
getServerStatus = function() -- 2337
	local Entry = require("Script.Dev.Entry") -- 2338
	local running = Entry.getCurrentEntryStatus() -- 2339
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2340
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2341
	return { -- 2343
		success = true, -- 2343
		platform = App.platform, -- 2344
		locale = App.locale, -- 2345
		version = App.version, -- 2346
		url = "http://localhost:8866", -- 2347
		wsConnectionCount = wsConnectionCount, -- 2348
		webIDEConnected = wsConnectionCount > 0, -- 2349
		assetPath = Content.assetPath, -- 2350
		writablePath = Content.writablePath, -- 2351
		appPath = Content.appPath, -- 2352
		waTemplateReady = waTemplateReady, -- 2353
		running = running -- 2354
	} -- 2342
end -- 2337
HttpServer:post("/status", function() -- 2357
	return getServerStatus() -- 2358
end) -- 2357
HttpServer:postSchedule("/doctor/fix", function(req) -- 2360
	do -- 2361
		local _type_0 = type(req) -- 2361
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2361
		if _tab_0 then -- 2361
			local openWebIDE -- 2361
			do -- 2361
				local _obj_0 = req.body -- 2361
				local _type_1 = type(_obj_0) -- 2361
				if "table" == _type_1 or "userdata" == _type_1 then -- 2361
					openWebIDE = _obj_0.openWebIDE -- 2361
				end -- 2361
			end -- 2361
			if openWebIDE ~= nil then -- 2361
				if not openWebIDE then -- 2362
					return { -- 2363
						success = false, -- 2363
						message = "nothing to fix" -- 2363
					} -- 2363
				end -- 2362
				local status = getServerStatus() -- 2364
				if status.webIDEConnected then -- 2365
					return { -- 2366
						success = true, -- 2366
						fixed = false, -- 2366
						message = "Web IDE already connected.", -- 2366
						status = status -- 2366
					} -- 2366
				end -- 2365
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2367
				if waitSeconds > 0 then -- 2368
					local deadline = os.time() + waitSeconds -- 2369
					repeat -- 2370
						sleep(0.2) -- 2371
						status = getServerStatus() -- 2372
						if status.webIDEConnected then -- 2373
							return { -- 2374
								success = true, -- 2374
								fixed = false, -- 2374
								reconnected = true, -- 2374
								message = "Web IDE reconnected.", -- 2374
								status = status -- 2374
							} -- 2374
						end -- 2373
					until os.time() >= deadline -- 2370
				end -- 2368
				if not isDesktopPlatform() then -- 2376
					return { -- 2377
						success = false, -- 2377
						message = "opening Web IDE is only supported on desktop platforms", -- 2377
						status = status -- 2377
					} -- 2377
				end -- 2376
				local url = "http://localhost:8866" -- 2378
				App:openURL(url) -- 2379
				status.openedURL = url -- 2380
				return { -- 2381
					success = true, -- 2381
					fixed = true, -- 2381
					message = "Opened Web IDE in the local browser.", -- 2381
					url = url, -- 2381
					status = status -- 2381
				} -- 2381
			end -- 2361
		end -- 2361
	end -- 2361
	return { -- 2360
		success = false, -- 2360
		message = "invalid call" -- 2360
	} -- 2360
end) -- 2360
local status = { } -- 2383
_module_0 = status -- 2384
status.buildAsync = function(path) -- 2386
	if not Content:exist(path) then -- 2387
		return { -- 2388
			success = false, -- 2388
			file = path, -- 2388
			message = "file not existed" -- 2388
		} -- 2388
	end -- 2387
	do -- 2389
		local _exp_0 = Path:getExt(path) -- 2389
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2389
			if '' == Path:getExt(Path:getName(path)) then -- 2390
				local content = Content:loadAsync(path) -- 2391
				if content then -- 2391
					local resultCodes, err = compileFileAsync(path, content) -- 2392
					if resultCodes then -- 2392
						return { -- 2393
							success = true, -- 2393
							file = path -- 2393
						} -- 2393
					else -- 2395
						return { -- 2395
							success = false, -- 2395
							file = path, -- 2395
							message = err -- 2395
						} -- 2395
					end -- 2392
				end -- 2391
			end -- 2390
		elseif "lua" == _exp_0 then -- 2396
			local content = Content:loadAsync(path) -- 2397
			if content then -- 2397
				do -- 2398
					local isTIC80 = CheckTIC80Code(content) -- 2398
					if isTIC80 then -- 2398
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2399
					end -- 2398
				end -- 2398
				local success, info -- 2400
				do -- 2400
					local _obj_0 = luaCheck(path, content) -- 2400
					success, info = _obj_0.success, _obj_0.info -- 2400
				end -- 2400
				if success then -- 2401
					return { -- 2402
						success = true, -- 2402
						file = path -- 2402
					} -- 2402
				elseif info and #info > 0 then -- 2403
					local messages = { } -- 2404
					for _index_0 = 1, #info do -- 2405
						local _des_0 = info[_index_0] -- 2405
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2405
						local lineText = "" -- 2406
						if line then -- 2407
							local currentLine = 1 -- 2408
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2409
								if currentLine == line then -- 2410
									lineText = text -- 2411
									break -- 2412
								end -- 2410
								currentLine = currentLine + 1 -- 2413
							end -- 2409
						end -- 2407
						if line then -- 2414
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2415
						else -- 2417
							messages[#messages + 1] = message -- 2417
						end -- 2414
					end -- 2405
					return { -- 2418
						success = false, -- 2418
						file = path, -- 2418
						message = table.concat(messages, "\n") -- 2418
					} -- 2418
				else -- 2420
					return { -- 2420
						success = false, -- 2420
						file = path, -- 2420
						message = "lua check failed" -- 2420
					} -- 2420
				end -- 2401
			end -- 2397
		elseif "yarn" == _exp_0 then -- 2421
			local content = Content:loadAsync(path) -- 2422
			if content then -- 2422
				local res, _, err = yarncompile(content, true) -- 2423
				if res then -- 2423
					return { -- 2424
						success = true, -- 2424
						file = path -- 2424
					} -- 2424
				else -- 2426
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2426
					local lineText = "" -- 2427
					if line then -- 2428
						local currentLine = 1 -- 2429
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2430
							if currentLine == line then -- 2431
								lineText = text -- 2432
								break -- 2433
							end -- 2431
							currentLine = currentLine + 1 -- 2434
						end -- 2430
					end -- 2428
					if node ~= "" then -- 2435
						node = "node: " .. tostring(node) .. ", " -- 2436
					else -- 2437
						node = "" -- 2437
					end -- 2435
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2438
					return { -- 2439
						success = false, -- 2439
						file = path, -- 2439
						message = message -- 2439
					} -- 2439
				end -- 2423
			end -- 2422
		end -- 2389
	end -- 2389
	return { -- 2440
		success = false, -- 2440
		file = path, -- 2440
		message = "invalid file to build" -- 2440
	} -- 2440
end -- 2386
thread(function() -- 2442
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 2443
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 2444
	if Content:exist(doraWeb) then -- 2445
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) -- 2446
		local needReload -- 2447
		if Content:exist(doraReady) then -- 2447
			needReload = readyContent ~= Content:load(doraReady) -- 2448
		else -- 2449
			needReload = true -- 2449
		end -- 2447
		if needReload then -- 2450
			Content:remove(Path(Content.appPath, ".www")) -- 2451
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 2452
			Content:save(doraReady, readyContent) -- 2456
			print("Dora Dora is ready!") -- 2457
		end -- 2450
	end -- 2445
	if HttpServer:start(8866) then -- 2458
		local localIP = HttpServer.localIP -- 2459
		if localIP == "" then -- 2460
			localIP = "localhost" -- 2460
		end -- 2460
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 2461
		return HttpServer:startWS(8868) -- 2462
	else -- 2464
		status.url = nil -- 2464
		return print("8866 Port not available!") -- 2465
	end -- 2458
end) -- 2442
return _module_0 -- 1
