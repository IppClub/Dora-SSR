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
	local scriptDir = Path(projectRoot, "Script") -- 118
	if Content:exist(scriptDir) and Content:isdir(scriptDir) then -- 119
		return scriptDir -- 120
	else -- 122
		return projectRoot -- 122
	end -- 119
end -- 116
local isProjectRootDir -- 124
isProjectRootDir = function(dir) -- 124
	if not (dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir)) then -- 125
		return false -- 125
	end -- 125
	local _list_0 = Content:getFiles(dir) -- 126
	for _index_0 = 1, #_list_0 do -- 126
		local f = _list_0[_index_0] -- 126
		if Path:getName(f):lower() == "init" then -- 127
			return true -- 128
		end -- 127
	end -- 126
	return false -- 129
end -- 124
local getProjectRootFromPath -- 131
getProjectRootFromPath = function(target, isDir) -- 131
	if isDir == nil then -- 131
		isDir = false -- 131
	end -- 131
	if not (target and target ~= "" and Content:isAbsolutePath(target)) then -- 132
		return nil, "invalid path" -- 132
	end -- 132
	if isDir then -- 133
		if isProjectRootDir(target) then -- 134
			return target -- 134
		end -- 134
		return getProjectDirFromFile(Path(target, "__dora_project_root_search__.lua"), "current directory does not belong to any project") -- 135
	end -- 133
	return getProjectDirFromFile(target, "current file does not belong to any project") -- 136
end -- 131
local invalidArguments = { -- 138
	success = false, -- 138
	message = "invalid arguments" -- 138
} -- 138
HttpServer:post("/agent/project-root", function(req) -- 140
	do -- 141
		local _type_0 = type(req) -- 141
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 141
		if _tab_0 then -- 141
			local path -- 141
			do -- 141
				local _obj_0 = req.body -- 141
				local _type_1 = type(_obj_0) -- 141
				if "table" == _type_1 or "userdata" == _type_1 then -- 141
					path = _obj_0.path -- 141
				end -- 141
			end -- 141
			local isDir -- 141
			do -- 141
				local _obj_0 = req.body -- 141
				local _type_1 = type(_obj_0) -- 141
				if "table" == _type_1 or "userdata" == _type_1 then -- 141
					isDir = _obj_0.isDir -- 141
				end -- 141
			end -- 141
			if path ~= nil and isDir ~= nil then -- 141
				local projectRoot, err = getProjectRootFromPath(path, isDir) -- 142
				if projectRoot then -- 142
					return { -- 143
						success = true, -- 143
						found = true, -- 143
						projectRoot = projectRoot, -- 143
						title = Path:getFilename(projectRoot) -- 143
					} -- 143
				else -- 145
					return { -- 145
						success = true, -- 145
						found = false, -- 145
						message = err -- 145
					} -- 145
				end -- 142
			end -- 141
		end -- 141
	end -- 141
	return invalidArguments -- 140
end) -- 140
local AgentTools = require("Agent.Tools") -- 147
local AgentSession = require("Agent.AgentSession") -- 148
local GitJobs = { } -- 150
local gitTerminalState -- 152
gitTerminalState = function(status) -- 152
	if not (status and status.state) then -- 153
		return false -- 153
	end -- 153
	local _val_0 = status.state -- 154
	return "done" == _val_0 or "error" == _val_0 or "canceled" == _val_0 -- 154
end -- 152
local gitInvalidRepoPath -- 156
gitInvalidRepoPath = function(repoPath) -- 156
	return not repoPath or repoPath == "" or not Content:isAbsolutePath(repoPath) -- 157
end -- 156
local gitShellSplit -- 159
gitShellSplit = function(command) -- 159
	local args = { } -- 160
	local current = { } -- 161
	local quote = nil -- 162
	local escape = false -- 163
	for i = 1, #command do -- 164
		local ch = command:sub(i, i) -- 165
		if escape then -- 166
			current[#current + 1] = ch -- 167
			escape = false -- 168
		elseif ch == "\\" then -- 169
			escape = true -- 170
		elseif quote then -- 171
			if ch == quote then -- 172
				quote = nil -- 173
			else -- 175
				current[#current + 1] = ch -- 175
			end -- 172
		elseif ch == "'" or ch == '"' then -- 176
			quote = ch -- 177
		elseif ch:match("%s") then -- 178
			if #current > 0 then -- 179
				args[#args + 1] = table.concat(current) -- 180
				current = { } -- 181
			end -- 179
		else -- 183
			current[#current + 1] = ch -- 183
		end -- 166
	end -- 164
	if #current > 0 then -- 184
		args[#args + 1] = table.concat(current) -- 185
	end -- 184
	if args[1] == "git" then -- 186
		table.remove(args, 1) -- 187
	end -- 186
	return args -- 188
end -- 159
local gitQuote -- 190
gitQuote = function(value) -- 190
	local text = tostring(value) -- 191
	if text:match("^[%w%._%-%/]+$") then -- 192
		return text -- 193
	end -- 192
	return "\"" .. text:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"" -- 194
end -- 190
local gitDirNonEmpty -- 196
gitDirNonEmpty = function(targetPath) -- 196
	if not Content:exist(targetPath) then -- 197
		return false -- 197
	end -- 197
	if not Content:isdir(targetPath) then -- 198
		return false -- 198
	end -- 198
	return #Content:getFiles(targetPath) > 0 or #Content:getDirs(targetPath) > 0 -- 199
end -- 196
local gitSafeChildPath -- 201
gitSafeChildPath = function(parentPath, childPath) -- 201
	if not (parentPath and childPath and childPath ~= "") then -- 202
		return nil -- 202
	end -- 202
	if childPath:sub(1, 1) == "/" or childPath:match("^%a:[/\\]") then -- 203
		return nil -- 203
	end -- 203
	if childPath == "." or childPath:match("^%.%.[/\\]?" or childPath:match("[/\\]%.%.[/\\]")) then -- 204
		return nil -- 204
	end -- 204
	local targetPath = Path(parentPath, childPath) -- 205
	local relative = Path:getRelative(targetPath, parentPath) -- 206
	if relative == ".." or relative:sub(1, 3) == "../" or relative:sub(1, 3) == "..\\" then -- 207
		return nil -- 207
	end -- 207
	return targetPath -- 208
end -- 201
local gitCloneDirFromURL -- 210
gitCloneDirFromURL = function(url) -- 210
	if not (url and url ~= "") then -- 211
		return nil -- 211
	end -- 211
	local text = tostring(url):match("^%s*(.-)%s*$") -- 212
	if text == "" then -- 213
		return nil -- 213
	end -- 213
	text = text:gsub("[/\\]+$", "") -- 214
	local name = text:match("([^/:]+)$") -- 215
	if not (name and name ~= "") then -- 216
		return nil -- 216
	end -- 216
	name = name:gsub("%.git$", "") -- 217
	if name == "" or name == "." or name == ".." then -- 218
		return nil -- 218
	end -- 218
	return name -- 219
end -- 210
local gitCloneTargetPath -- 221
gitCloneTargetPath = function(repoPath, command) -- 221
	local args = gitShellSplit(command) -- 222
	if not (args[1] == "clone") then -- 223
		return nil -- 223
	end -- 223
	local url = args[2] -- 224
	local index = 3 -- 225
	while index <= #args do -- 226
		local arg = args[index] -- 227
		if ("-b" == arg or "--branch" == arg or "--depth" == arg) then -- 228
			index = index + 2 -- 229
		elseif arg:sub(1, 1) == "-" then -- 230
			index = index + 1 -- 231
		else -- 233
			return gitSafeChildPath(repoPath, arg) -- 233
		end -- 228
	end -- 226
	do -- 234
		local dirName = gitCloneDirFromURL(url) -- 234
		if dirName then -- 234
			return gitSafeChildPath(repoPath, dirName) -- 235
		end -- 234
	end -- 234
	return nil -- 236
end -- 221
local gitPathInsideRepo -- 238
gitPathInsideRepo = function(repoPath, relPath) -- 238
	if not (repoPath and relPath and relPath ~= "") then -- 239
		return false -- 239
	end -- 239
	if relPath:sub(1, 1) == "/" or relPath:match("^%a:[/\\]") then -- 240
		return false -- 240
	end -- 240
	if relPath == "." or relPath:match("^%.%.[/\\]?" or relPath:match("[/\\]%.%.[/\\]")) then -- 241
		return false -- 241
	end -- 241
	local targetPath = Path(repoPath, relPath) -- 242
	local relative = Path:getRelative(targetPath, repoPath) -- 243
	return relative ~= ".." and relative:sub(1, 3) ~= "../" and relative:sub(1, 3) ~= "..\\" -- 244
end -- 238
local gitHostFromURL -- 246
gitHostFromURL = function(url) -- 246
	if not (url and url ~= "") then -- 247
		return nil -- 247
	end -- 247
	local text = tostring(url):match("^%s*(.-)%s*$") -- 248
	if text == "" then -- 249
		return nil -- 249
	end -- 249
	local host = text:match("^[%w_%-]+://([^/:]+)") -- 250
	if not host then -- 251
		host = text:match("@([^:/]+)[:/]") -- 251
	end -- 251
	if not host then -- 252
		host = text:match("^([^:/]+):[^/]") -- 252
	end -- 252
	if not (host and host ~= "") then -- 253
		return nil -- 253
	end -- 253
	return string.lower(host) -- 254
end -- 246
local ensureGitTables -- 256
ensureGitTables = function() -- 256
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
	]]) -- 257
	DB:exec("CREATE INDEX IF NOT EXISTS idx_git_credential_host ON GitCredential(host);") -- 270
	return DB:exec([[		CREATE TABLE IF NOT EXISTS GitProfile(
			id INTEGER PRIMARY KEY CHECK(id = 1),
			name TEXT NOT NULL DEFAULT '',
			email TEXT NOT NULL DEFAULT '',
			updated_at INTEGER
		);
	]]) -- 271
end -- 256
local gitCredentialToPublic -- 280
gitCredentialToPublic = function(row) -- 280
	local id, host, label, typeName, username, createdAt, updatedAt, lastUsedAt = row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8] -- 281
	return { -- 282
		id = id, -- 282
		host = host, -- 282
		label = label, -- 282
		type = typeName, -- 282
		username = username, -- 282
		createdAt = createdAt, -- 282
		updatedAt = updatedAt, -- 282
		lastUsedAt = lastUsedAt -- 282
	} -- 282
end -- 280
local gitLoadCredential -- 284
gitLoadCredential = function(id) -- 284
	ensureGitTables() -- 285
	local credentialId = tonumber(id) or 0 -- 286
	local rows = DB:query("select id, host, label, type, username, secret from GitCredential where id = ? limit 1", { -- 287
		credentialId -- 287
	}) -- 287
	if not (rows and rows[1]) then -- 288
		return nil -- 288
	end -- 288
	local row = rows[1] -- 289
	return { -- 290
		id = row[1], -- 290
		host = row[2], -- 290
		label = row[3], -- 290
		type = row[4], -- 290
		username = row[5], -- 290
		secret = row[6] -- 290
	} -- 290
end -- 284
local gitAuthOptionsJSON -- 292
gitAuthOptionsJSON = function(credential) -- 292
	if not credential then -- 293
		return nil -- 293
	end -- 293
	local auth -- 294
	if credential.type == "token" then -- 294
		auth = { -- 296
			type = "token", -- 296
			token = credential.secret, -- 297
			username = credential.username ~= "" and credential.username or "token" -- 298
		} -- 295
	else -- 301
		auth = { -- 302
			type = "basic", -- 302
			username = credential.username, -- 303
			password = credential.secret -- 304
		} -- 301
	end -- 294
	return json.encode({ -- 306
		auth = auth -- 306
	}) -- 306
end -- 292
local gitLoadProfile -- 308
gitLoadProfile = function() -- 308
	ensureGitTables() -- 309
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 310
	if not (rows and rows[1]) then -- 311
		return nil -- 311
	end -- 311
	local name = tostring(rows[1][1] or "") -- 312
	local email = tostring(rows[1][2] or "") -- 313
	if name == "" and email == "" then -- 314
		return nil -- 314
	end -- 314
	return { -- 315
		name = name, -- 315
		email = email -- 315
	} -- 315
end -- 308
local _anon_func_2 = function(args, gitQuote) -- 334
	local _accum_0 = { } -- 334
	local _len_0 = 1 -- 334
	for _index_0 = 1, #args do -- 334
		local arg = args[_index_0] -- 334
		_accum_0[_len_0] = gitQuote(arg) -- 334
		_len_0 = _len_0 + 1 -- 334
	end -- 334
	return _accum_0 -- 334
end -- 334
local gitApplyProfileToCommit -- 317
gitApplyProfileToCommit = function(command) -- 317
	local args = gitShellSplit(command) -- 318
	if not (args[1] == "commit") then -- 319
		return command -- 319
	end -- 319
	local hasName = false -- 320
	local hasEmail = false -- 321
	for _index_0 = 1, #args do -- 322
		local arg = args[_index_0] -- 322
		if arg == "--author-name" then -- 323
			hasName = true -- 323
		end -- 323
		if arg == "--author-email" then -- 324
			hasEmail = true -- 324
		end -- 324
	end -- 322
	if hasName and hasEmail then -- 325
		return command -- 325
	end -- 325
	local profile = gitLoadProfile() -- 326
	if not profile then -- 327
		return command -- 327
	end -- 327
	if not hasName and profile.name ~= "" then -- 328
		args[#args + 1] = "--author-name" -- 329
		args[#args + 1] = profile.name -- 330
	end -- 328
	if not hasEmail and profile.email ~= "" then -- 331
		args[#args + 1] = "--author-email" -- 332
		args[#args + 1] = profile.email -- 333
	end -- 331
	return table.concat(_anon_func_2(args, gitQuote), " ") -- 334
end -- 317
local gitStartJob -- 336
gitStartJob = function(repoPath, command, optionsJSON) -- 336
	if optionsJSON == nil then -- 336
		optionsJSON = nil -- 336
	end -- 336
	if gitInvalidRepoPath(repoPath) then -- 337
		return nil, "invalid repoPath" -- 337
	end -- 337
	if not (command and command ~= "") then -- 338
		return nil, "invalid command" -- 338
	end -- 338
	if not optionsJSON then -- 339
		optionsJSON = "" -- 339
	end -- 339
	command = gitApplyProfileToCommit(command) -- 340
	do -- 341
		local targetPath = gitCloneTargetPath(repoPath, command) -- 341
		if targetPath then -- 341
			if gitDirNonEmpty(targetPath) then -- 342
				return nil, "clone target directory is not empty" -- 343
			end -- 342
		elseif (gitShellSplit(command))[1] == "clone" then -- 344
			return nil, "invalid clone target" -- 345
		end -- 341
	end -- 341
	local statusRef = nil -- 346
	local startGit -- 347
	startGit = function() -- 347
		return Git:run(repoPath, command, (function(status) -- 348
			statusRef = status -- 349
			GitJobs[status.id] = { -- 351
				command = command, -- 351
				status = status, -- 352
				updatedAt = os.time() -- 353
			} -- 350
		end), optionsJSON) -- 348
	end -- 347
	local success, jobId = pcall(startGit) -- 355
	if not success then -- 356
		return nil, tostring(jobId) -- 356
	end -- 356
	if not jobId then -- 357
		return nil, "Git.run did not return a job id" -- 357
	end -- 357
	GitJobs[jobId] = { -- 359
		command = command, -- 359
		status = statusRef or { -- 361
			id = jobId, -- 361
			state = "queued", -- 362
			kind = gitShellSplit(command)[1] or "status", -- 363
			repoPath = repoPath, -- 364
			progress = 0, -- 365
			message = "queued" -- 366
		}, -- 360
		updatedAt = os.time() -- 368
	} -- 358
	return jobId -- 369
end -- 336
local gitRunSync -- 371
gitRunSync = function(repoPath, command, optionsJSON, timeout) -- 371
	if optionsJSON == nil then -- 371
		optionsJSON = nil -- 371
	end -- 371
	if timeout == nil then -- 371
		timeout = 20 -- 371
	end -- 371
	local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 372
	if not jobId then -- 373
		return { -- 373
			success = false, -- 373
			message = err -- 373
		} -- 373
	end -- 373
	local startedAt = os.time() -- 374
	wait(function() -- 375
		local job = GitJobs[jobId] -- 376
		local status = job and job.status -- 377
		return gitTerminalState(status) or os.time() - startedAt >= timeout -- 378
	end) -- 375
	local status = GitJobs[jobId] and GitJobs[jobId].status -- 379
	if not gitTerminalState(status) then -- 380
		Git:cancel(jobId) -- 381
		return { -- 382
			success = false, -- 382
			message = "git command timed out", -- 382
			jobId = jobId, -- 382
			status = status -- 382
		} -- 382
	end -- 380
	return { -- 383
		success = status.state == "done", -- 383
		jobId = jobId, -- 383
		status = status, -- 383
		message = status.error or status.message -- 383
	} -- 383
end -- 371
local gitCredentialsForHost -- 385
gitCredentialsForHost = function(host) -- 385
	if not (host and host ~= "") then -- 386
		return { } -- 386
	end -- 386
	ensureGitTables() -- 387
	local rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by last_used_at desc, label asc, id asc", { -- 388
		host -- 388
	}) -- 388
	if rows then -- 389
		local _accum_0 = { } -- 390
		local _len_0 = 1 -- 390
		for _index_0 = 1, #rows do -- 390
			local row = rows[_index_0] -- 390
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 390
			_len_0 = _len_0 + 1 -- 390
		end -- 390
		return _accum_0 -- 390
	else -- 391
		return { } -- 391
	end -- 389
end -- 385
local gitFirstRemoteURL -- 393
gitFirstRemoteURL = function(repoPath, remoteName) -- 393
	if remoteName == nil then -- 393
		remoteName = nil -- 393
	end -- 393
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 10) -- 394
	local data = remoteRes.status and remoteRes.status.data -- 395
	if not (data and data.remotes) then -- 396
		return nil -- 396
	end -- 396
	local _list_0 = data.remotes -- 397
	for _index_0 = 1, #_list_0 do -- 397
		local remote = _list_0[_index_0] -- 397
		if (not remoteName or remote.name == remoteName) and remote.urls and remote.urls[1] then -- 398
			return remote.urls[1] -- 399
		end -- 398
	end -- 397
	return nil -- 400
end -- 393
local gitConfigRemoteURL -- 402
gitConfigRemoteURL = function(repoPath, remoteName) -- 402
	if remoteName == nil then -- 402
		remoteName = nil -- 402
	end -- 402
	if gitInvalidRepoPath(repoPath) then -- 403
		return nil -- 403
	end -- 403
	local configPath = Path(repoPath, ".git/config") -- 404
	if not Content:exist(configPath) then -- 405
		return nil -- 405
	end -- 405
	local content = Content:load(configPath) -- 406
	if not (content and content ~= "") then -- 407
		return nil -- 407
	end -- 407
	local currentRemote = nil -- 408
	for line in content:gmatch("[^\r\n]+") do -- 409
		local sectionRemote = line:match('^%s*%[remote%s+"([^"]+)"%]%s*$') -- 410
		if sectionRemote then -- 411
			currentRemote = sectionRemote -- 412
		elseif currentRemote and (not remoteName or currentRemote == remoteName) then -- 413
			local url = line:match("^%s*url%s*=%s*(.-)%s*$") -- 414
			if url and url ~= "" then -- 415
				return url -- 415
			end -- 415
		end -- 411
	end -- 409
	return nil -- 416
end -- 402
local gitCommandRemoteArg -- 418
gitCommandRemoteArg = function(args, startIndex) -- 418
	if startIndex == nil then -- 418
		startIndex = 2 -- 418
	end -- 418
	local index = startIndex -- 419
	while index <= #args do -- 420
		local arg = args[index] -- 421
		if ("-u" == arg or "--set-upstream" == arg or "-f" == arg or "--force" == arg or "--all" == arg or "--prune" == arg) then -- 422
			index = index + 1 -- 423
		elseif ("--depth" == arg or "-b" == arg or "--branch" == arg) then -- 424
			index = index + 2 -- 425
		elseif arg and arg:sub(1, 1) == "-" then -- 426
			index = index + 1 -- 427
		else -- 429
			return arg -- 429
		end -- 422
	end -- 420
	return nil -- 430
end -- 418
local gitCommandHost -- 432
gitCommandHost = function(repoPath, command) -- 432
	local args = gitShellSplit(command) -- 433
	if not args[1] then -- 434
		return nil -- 434
	end -- 434
	do -- 435
		local _exp_0 = args[1] -- 435
		if "clone" == _exp_0 or "ls-remote" == _exp_0 then -- 436
			return gitHostFromURL(args[2]) -- 437
		elseif "fetch" == _exp_0 or "pull" == _exp_0 or "push" == _exp_0 then -- 438
			local remoteArg = gitCommandRemoteArg(args, 2) -- 439
			if not remoteArg then -- 440
				return nil -- 440
			end -- 440
			local url = gitHostFromURL(remoteArg) -- 441
			if url then -- 442
				return url -- 442
			end -- 442
			return gitHostFromURL(gitConfigRemoteURL(repoPath, remoteArg)) -- 443
		end -- 435
	end -- 435
	return nil -- 444
end -- 432
local gitAuthSelectionForCommand -- 446
gitAuthSelectionForCommand = function(repoPath, command) -- 446
	local host = gitCommandHost(repoPath, command) -- 447
	if not host then -- 448
		return nil -- 448
	end -- 448
	local items = gitCredentialsForHost(host) -- 449
	if #items == 0 then -- 450
		return nil -- 450
	end -- 450
	return { -- 451
		host = host, -- 451
		items = items -- 451
	} -- 451
end -- 446
local gitDefaultRemote -- 453
gitDefaultRemote = function(remoteStatus) -- 453
	local data = remoteStatus and remoteStatus.data -- 454
	if not (data and data.remotes and data.remotes[1]) then -- 455
		return nil -- 455
	end -- 455
	return data.remotes[1] -- 456
end -- 453
local gitCurrentBranch -- 458
gitCurrentBranch = function(branchStatus) -- 458
	local data = branchStatus and branchStatus.data -- 459
	if data and data.current and data.current ~= "" then -- 460
		return data.current -- 461
	end -- 460
	if data and data.branches then -- 462
		local _list_0 = data.branches -- 463
		for _index_0 = 1, #_list_0 do -- 463
			local branch = _list_0[_index_0] -- 463
			if branch.current then -- 464
				return branch.name -- 464
			end -- 464
		end -- 463
	end -- 462
	return nil -- 465
end -- 458
local gitHeadBranch -- 467
gitHeadBranch = function(repoPath) -- 467
	if gitInvalidRepoPath(repoPath) then -- 468
		return nil -- 468
	end -- 468
	local headPath = Path(repoPath, ".git", "HEAD") -- 469
	if not Content:exist(headPath) then -- 470
		return nil -- 470
	end -- 470
	local head = Content:load(headPath) -- 471
	if not head then -- 472
		return nil -- 472
	end -- 472
	local branch = head:match("^ref:%s*refs/heads/(.-)%s*$") -- 473
	if branch and branch ~= "" then -- 474
		return branch -- 474
	end -- 474
	return nil -- 475
end -- 467
local gitBranchesWithHead -- 477
gitBranchesWithHead = function(branchStatus, currentBranch) -- 477
	local branches = branchStatus and branchStatus.data and branchStatus.data.branches or { } -- 478
	if not (currentBranch and currentBranch ~= "") then -- 479
		return branches -- 479
	end -- 479
	for _index_0 = 1, #branches do -- 480
		local branch = branches[_index_0] -- 480
		if branch.name == currentBranch then -- 481
			return branches -- 481
		end -- 481
	end -- 480
	local withHead -- 482
	do -- 482
		local _accum_0 = { } -- 482
		local _len_0 = 1 -- 482
		for _index_0 = 1, #branches do -- 482
			local branch = branches[_index_0] -- 482
			_accum_0[_len_0] = branch -- 482
			_len_0 = _len_0 + 1 -- 482
		end -- 482
		withHead = _accum_0 -- 482
	end -- 482
	withHead[#withHead + 1] = { -- 483
		name = currentBranch, -- 483
		current = true, -- 483
		unborn = true -- 483
	} -- 483
	return withHead -- 484
end -- 477
local gitStatusMeansNotRepo -- 486
gitStatusMeansNotRepo = function(statusRes) -- 486
	local message = statusRes and (statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message)) or "" -- 487
	message = tostring(message):lower() -- 488
	return message:find("repository does not exist", 1, true) or message:find("not a git repository", 1, true) -- 489
end -- 486
local gitSummary -- 491
gitSummary = function(repoPath) -- 491
	local statusRes = gitRunSync(repoPath, "status", nil, 120) -- 492
	if not statusRes.success then -- 493
		if gitStatusMeansNotRepo(statusRes) then -- 494
			return { -- 495
				success = true, -- 495
				isRepo = false, -- 495
				message = statusRes.message, -- 495
				status = statusRes.status -- 495
			} -- 495
		end -- 494
		return { -- 496
			success = false, -- 496
			message = statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message) or "failed to check Git repository", -- 496
			status = statusRes.status -- 496
		} -- 496
	end -- 493
	local branchRes = gitRunSync(repoPath, "branch", nil, 120) -- 497
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 120) -- 498
	local status = statusRes.status -- 499
	local branchStatus = branchRes.status -- 500
	local remoteStatus = remoteRes.status -- 501
	local currentBranch = gitCurrentBranch(branchStatus) or gitHeadBranch(repoPath) -- 502
	local branches = gitBranchesWithHead(branchStatus, currentBranch) -- 503
	local logRes = gitRunSync(repoPath, "log -n 100", nil, 120) -- 504
	local logStatus -- 505
	if logRes.success then -- 505
		logStatus = logRes.status -- 506
	else -- 508
		logStatus = { -- 509
			state = "done", -- 509
			kind = "log", -- 510
			repoPath = repoPath, -- 511
			progress = 1, -- 512
			message = "git log completed", -- 513
			data = { -- 514
				commits = { } -- 514
			} -- 514
		} -- 508
	end -- 505
	local hasCommit = logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] ~= nil -- 516
	local tagStatus -- 517
	if hasCommit then -- 517
		tagStatus = (gitRunSync(repoPath, "tag", nil, 120)).status -- 518
	else -- 520
		tagStatus = { -- 521
			state = "done", -- 521
			kind = "tag", -- 522
			repoPath = repoPath, -- 523
			progress = 1, -- 524
			message = "git tag completed", -- 525
			data = { -- 526
				tags = { } -- 526
			} -- 526
		} -- 520
	end -- 517
	local defaultRemote = gitDefaultRemote(remoteStatus) -- 528
	local lastCommit = nil -- 529
	if logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] then -- 530
		lastCommit = logStatus.data.commits[1] -- 531
	end -- 530
	return { -- 533
		success = true, -- 533
		isRepo = true, -- 534
		clean = status.data and status.data.clean or false, -- 535
		currentBranch = currentBranch, -- 536
		defaultRemote = defaultRemote, -- 537
		remotes = remoteStatus and remoteStatus.data and remoteStatus.data.remotes or { }, -- 538
		branches = branches, -- 539
		lastCommit = lastCommit, -- 540
		status = status, -- 541
		branchStatus = branchStatus, -- 542
		remoteStatus = remoteStatus, -- 543
		historyStatus = logStatus, -- 544
		tagStatus = tagStatus -- 545
	} -- 532
end -- 491
HttpServer:post("/git/run", function(req) -- 547
	do -- 548
		local _type_0 = type(req) -- 548
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 548
		if _tab_0 then -- 548
			local body = req.body -- 548
			if body ~= nil then -- 548
				local repoPath, command, authId, optionsJSON = body.repoPath, body.command, body.authId, body.optionsJSON -- 549
				if authId and not optionsJSON then -- 550
					local credential = gitLoadCredential(authId) -- 551
					if credential then -- 551
						optionsJSON = gitAuthOptionsJSON(credential) -- 552
						DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 553
							os.time(), -- 553
							credential.id -- 553
						}) -- 553
					end -- 551
				elseif not optionsJSON then -- 554
					local authOk, authSelection = pcall(gitAuthSelectionForCommand, repoPath, command) -- 555
					if not authOk then -- 556
						authSelection = nil -- 556
					end -- 556
					if authSelection then -- 557
						if #authSelection.items == 1 then -- 558
							local credential = gitLoadCredential(authSelection.items[1].id) -- 559
							optionsJSON = gitAuthOptionsJSON(credential) -- 560
							DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 561
								os.time(), -- 561
								credential.id -- 561
							}) -- 561
						else -- 563
							return { -- 563
								success = false, -- 563
								message = "select a Git credential", -- 563
								needsCredentialSelection = true, -- 563
								host = authSelection.host, -- 563
								credentials = authSelection.items -- 563
							} -- 563
						end -- 558
					end -- 557
				end -- 550
				local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 564
				if not jobId then -- 565
					return { -- 565
						success = false, -- 565
						message = err -- 565
					} -- 565
				end -- 565
				return { -- 566
					success = true, -- 566
					jobId = jobId -- 566
				} -- 566
			end -- 548
		end -- 548
	end -- 548
	return invalidArguments -- 547
end) -- 547
HttpServer:post("/git/status", function(req) -- 568
	do -- 569
		local _type_0 = type(req) -- 569
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 569
		if _tab_0 then -- 569
			local jobId -- 569
			do -- 569
				local _obj_0 = req.body -- 569
				local _type_1 = type(_obj_0) -- 569
				if "table" == _type_1 or "userdata" == _type_1 then -- 569
					jobId = _obj_0.jobId -- 569
				end -- 569
			end -- 569
			if jobId ~= nil then -- 569
				local job = GitJobs[tonumber(jobId) or 0] -- 570
				if not job then -- 571
					return { -- 571
						success = false, -- 571
						message = "git job not found" -- 571
					} -- 571
				end -- 571
				return { -- 572
					success = true, -- 572
					status = job.status, -- 572
					command = job.command -- 572
				} -- 572
			end -- 569
		end -- 569
	end -- 569
	return invalidArguments -- 568
end) -- 568
HttpServer:post("/git/cancel", function(req) -- 574
	do -- 575
		local _type_0 = type(req) -- 575
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 575
		if _tab_0 then -- 575
			local jobId -- 575
			do -- 575
				local _obj_0 = req.body -- 575
				local _type_1 = type(_obj_0) -- 575
				if "table" == _type_1 or "userdata" == _type_1 then -- 575
					jobId = _obj_0.jobId -- 575
				end -- 575
			end -- 575
			if jobId ~= nil then -- 575
				local id = tonumber(jobId) -- 576
				if not id then -- 577
					return { -- 577
						success = false, -- 577
						message = "invalid jobId" -- 577
					} -- 577
				end -- 577
				return { -- 578
					success = Git:cancel(id) -- 578
				} -- 578
			end -- 575
		end -- 575
	end -- 575
	return invalidArguments -- 574
end) -- 574
HttpServer:postSchedule("/git/summary", function(req) -- 580
	do -- 581
		local _type_0 = type(req) -- 581
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 581
		if _tab_0 then -- 581
			local repoPath -- 581
			do -- 581
				local _obj_0 = req.body -- 581
				local _type_1 = type(_obj_0) -- 581
				if "table" == _type_1 or "userdata" == _type_1 then -- 581
					repoPath = _obj_0.repoPath -- 581
				end -- 581
			end -- 581
			if repoPath ~= nil then -- 581
				if gitInvalidRepoPath(repoPath) then -- 582
					return { -- 582
						success = false, -- 582
						message = "invalid repoPath" -- 582
					} -- 582
				end -- 582
				return gitSummary(repoPath) -- 583
			end -- 581
		end -- 581
	end -- 581
	return invalidArguments -- 580
end) -- 580
HttpServer:postSchedule("/git/status-files", function(req) -- 585
	do -- 586
		local _type_0 = type(req) -- 586
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 586
		if _tab_0 then -- 586
			local repoPath -- 586
			do -- 586
				local _obj_0 = req.body -- 586
				local _type_1 = type(_obj_0) -- 586
				if "table" == _type_1 or "userdata" == _type_1 then -- 586
					repoPath = _obj_0.repoPath -- 586
				end -- 586
			end -- 586
			if repoPath ~= nil then -- 586
				return gitRunSync(repoPath, "status", nil, 10) -- 587
			end -- 586
		end -- 586
	end -- 586
	return invalidArguments -- 585
end) -- 585
HttpServer:postSchedule("/git/discard-untracked", function(req) -- 589
	do -- 590
		local _type_0 = type(req) -- 590
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 590
		if _tab_0 then -- 590
			local body = req.body -- 590
			if body ~= nil then -- 590
				local repoPath, paths = body.repoPath, body.paths -- 591
				if gitInvalidRepoPath(repoPath) then -- 592
					return { -- 592
						success = false, -- 592
						message = "invalid repoPath" -- 592
					} -- 592
				end -- 592
				if not (type(paths) == "table") then -- 593
					return { -- 593
						success = false, -- 593
						message = "invalid paths" -- 593
					} -- 593
				end -- 593
				local statusRes = gitRunSync(repoPath, "status", nil, 10) -- 594
				if not statusRes.success then -- 595
					return statusRes -- 595
				end -- 595
				local untracked = { } -- 596
				local _list_0 = (statusRes.status.data and statusRes.status.data.files or { }) -- 597
				for _index_0 = 1, #_list_0 do -- 597
					local file = _list_0[_index_0] -- 597
					if file.staging == "?" or file.worktree == "?" then -- 598
						untracked[file.path] = true -- 599
					end -- 598
				end -- 597
				local removed = { } -- 600
				for _index_0 = 1, #paths do -- 601
					local relPath = paths[_index_0] -- 601
					relPath = tostring(relPath) -- 602
					if not gitPathInsideRepo(repoPath, relPath) then -- 603
						return { -- 603
							success = false, -- 603
							message = "unsafe path: " .. tostring(relPath) -- 603
						} -- 603
					end -- 603
					if not untracked[relPath] then -- 604
						return { -- 604
							success = false, -- 604
							message = "path is not untracked: " .. tostring(relPath) -- 604
						} -- 604
					end -- 604
				end -- 601
				for _index_0 = 1, #paths do -- 605
					local relPath = paths[_index_0] -- 605
					local targetPath = Path(repoPath, tostring(relPath)) -- 606
					if Content:exist(targetPath) then -- 607
						Content:remove(targetPath) -- 608
						removed[#removed + 1] = tostring(relPath) -- 609
					end -- 607
				end -- 605
				return { -- 610
					success = true, -- 610
					removed = removed -- 610
				} -- 610
			end -- 590
		end -- 590
	end -- 590
	return invalidArguments -- 589
end) -- 589
HttpServer:postSchedule("/git/file-diff", function(req) -- 612
	do -- 613
		local _type_0 = type(req) -- 613
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 613
		if _tab_0 then -- 613
			local body = req.body -- 613
			if body ~= nil then -- 613
				local repoPath, path, staged = body.repoPath, body.path, body.staged -- 614
				if gitInvalidRepoPath(repoPath) then -- 615
					return { -- 615
						success = false, -- 615
						message = "invalid repoPath" -- 615
					} -- 615
				end -- 615
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 616
					return { -- 616
						success = false, -- 616
						message = "unsafe path" -- 616
					} -- 616
				end -- 616
				local command -- 617
				if staged == true then -- 617
					command = "diff --staged -- " .. tostring(gitQuote(path)) -- 618
				else -- 620
					command = "diff -- " .. tostring(gitQuote(path)) -- 620
				end -- 617
				local res = gitRunSync(repoPath, command, nil, 10) -- 621
				if not res.success then -- 622
					return res -- 622
				end -- 622
				return { -- 623
					success = true, -- 623
					status = res.status, -- 623
					data = res.status and res.status.data -- 623
				} -- 623
			end -- 613
		end -- 613
	end -- 613
	return invalidArguments -- 612
end) -- 612
HttpServer:postSchedule("/git/commit-file-diff", function(req) -- 625
	do -- 626
		local _type_0 = type(req) -- 626
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 626
		if _tab_0 then -- 626
			local body = req.body -- 626
			if body ~= nil then -- 626
				local repoPath, commit, path = body.repoPath, body.commit, body.path -- 627
				if gitInvalidRepoPath(repoPath) then -- 628
					return { -- 628
						success = false, -- 628
						message = "invalid repoPath" -- 628
					} -- 628
				end -- 628
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 629
					return { -- 629
						success = false, -- 629
						message = "invalid commit" -- 629
					} -- 629
				end -- 629
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 630
					return { -- 630
						success = false, -- 630
						message = "unsafe path" -- 630
					} -- 630
				end -- 630
				local res = gitRunSync(repoPath, "diff " .. tostring(gitQuote(commit)) .. " -- " .. tostring(gitQuote(path)), nil, 10) -- 631
				if not res.success then -- 632
					return res -- 632
				end -- 632
				return { -- 633
					success = true, -- 633
					status = res.status, -- 633
					data = res.status and res.status.data -- 633
				} -- 633
			end -- 626
		end -- 626
	end -- 626
	return invalidArguments -- 625
end) -- 625
HttpServer:postSchedule("/git/history", function(req) -- 635
	do -- 636
		local _type_0 = type(req) -- 636
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 636
		if _tab_0 then -- 636
			local body = req.body -- 636
			if body ~= nil then -- 636
				local repoPath, limit = body.repoPath, body.limit -- 637
				limit = math.max(1, math.min(100, tonumber(limit) or 20)) -- 638
				return gitRunSync(repoPath, "log -n " .. tostring(limit), nil, 10) -- 639
			end -- 636
		end -- 636
	end -- 636
	return invalidArguments -- 635
end) -- 635
HttpServer:postSchedule("/git/remotes", function(req) -- 641
	do -- 642
		local _type_0 = type(req) -- 642
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 642
		if _tab_0 then -- 642
			local body = req.body -- 642
			if body ~= nil then -- 642
				local repoPath, command = body.repoPath, body.command -- 643
				command = command or "remote -v" -- 644
				return gitRunSync(repoPath, command, nil, 10) -- 645
			end -- 642
		end -- 642
	end -- 642
	return invalidArguments -- 641
end) -- 641
HttpServer:postSchedule("/git/branches", function(req) -- 647
	do -- 648
		local _type_0 = type(req) -- 648
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 648
		if _tab_0 then -- 648
			local body = req.body -- 648
			if body ~= nil then -- 648
				local repoPath, command = body.repoPath, body.command -- 649
				command = command or "branch" -- 650
				return gitRunSync(repoPath, command, nil, 10) -- 651
			end -- 648
		end -- 648
	end -- 648
	return invalidArguments -- 647
end) -- 647
HttpServer:postSchedule("/git/tags", function(req) -- 653
	do -- 654
		local _type_0 = type(req) -- 654
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 654
		if _tab_0 then -- 654
			local body = req.body -- 654
			if body ~= nil then -- 654
				local repoPath, command = body.repoPath, body.command -- 655
				command = command or "tag" -- 656
				return gitRunSync(repoPath, command, nil, 10) -- 657
			end -- 654
		end -- 654
	end -- 654
	return invalidArguments -- 653
end) -- 653
HttpServer:post("/git/profile/get", function() -- 659
	ensureGitTables() -- 660
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 661
	local profile -- 662
	if rows and rows[1] then -- 662
		profile = { -- 663
			name = rows[1][1], -- 663
			email = rows[1][2] -- 663
		} -- 663
	else -- 665
		profile = { -- 665
			name = "", -- 665
			email = "" -- 665
		} -- 665
	end -- 662
	return { -- 666
		success = true, -- 666
		profile = profile -- 666
	} -- 666
end) -- 659
HttpServer:post("/git/profile/save", function(req) -- 668
	do -- 669
		local _type_0 = type(req) -- 669
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 669
		if _tab_0 then -- 669
			local name -- 669
			do -- 669
				local _obj_0 = req.body -- 669
				local _type_1 = type(_obj_0) -- 669
				if "table" == _type_1 or "userdata" == _type_1 then -- 669
					name = _obj_0.name -- 669
				end -- 669
			end -- 669
			local email -- 669
			do -- 669
				local _obj_0 = req.body -- 669
				local _type_1 = type(_obj_0) -- 669
				if "table" == _type_1 or "userdata" == _type_1 then -- 669
					email = _obj_0.email -- 669
				end -- 669
			end -- 669
			if name ~= nil and email ~= nil then -- 669
				ensureGitTables() -- 670
				DB:exec("insert into GitProfile(id, name, email, updated_at) values(1, ?, ?, ?) on conflict(id) do update set name = excluded.name, email = excluded.email, updated_at = excluded.updated_at", { -- 672
					tostring(name or ""), -- 672
					tostring(email or ""), -- 673
					os.time() -- 674
				}) -- 671
				return { -- 676
					success = true -- 676
				} -- 676
			end -- 669
		end -- 669
	end -- 669
	return invalidArguments -- 668
end) -- 668
HttpServer:post("/git/auth/list", function(req) -- 678
	ensureGitTables() -- 679
	local host = nil -- 680
	do -- 681
		local _type_0 = type(req) -- 681
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 681
		if _tab_0 then -- 681
			local body = req.body -- 681
			if body ~= nil then -- 681
				host = body.host -- 682
			end -- 681
		end -- 681
	end -- 681
	local rows -- 683
	if host and host ~= "" then -- 683
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by host asc, label asc, id asc", { -- 684
			tostring(host):lower() -- 684
		}) -- 684
	else -- 686
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential order by host asc, label asc, id asc") -- 686
	end -- 683
	local items -- 687
	if rows then -- 687
		local _accum_0 = { } -- 688
		local _len_0 = 1 -- 688
		for _index_0 = 1, #rows do -- 688
			local row = rows[_index_0] -- 688
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 688
			_len_0 = _len_0 + 1 -- 688
		end -- 688
		items = _accum_0 -- 688
	else -- 689
		items = { } -- 689
	end -- 687
	return { -- 690
		success = true, -- 690
		items = items -- 690
	} -- 690
end) -- 678
HttpServer:postSchedule("/git/auth/match", function(req) -- 692
	do -- 693
		local _type_0 = type(req) -- 693
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 693
		local _match_0 = false -- 693
		if _tab_0 then -- 693
			local body = req.body -- 693
			if body ~= nil then -- 693
				_match_0 = true -- 693
				local repoPath, command, url = body.repoPath, body.command, body.url -- 694
				local host -- 695
				if url and url ~= "" then -- 695
					host = gitHostFromURL(url) -- 695
				else -- 695
					host = gitCommandHost(repoPath, command) -- 695
				end -- 695
				if not host then -- 696
					return { -- 696
						success = false, -- 696
						message = "git host is required" -- 696
					} -- 696
				end -- 696
				local items = gitCredentialsForHost(host) -- 697
				return { -- 698
					success = true, -- 698
					host = host, -- 698
					items = items, -- 698
					needsSelection = #items > 1, -- 698
					authId = (#items == 1 and items[1].id or nil) -- 698
				} -- 698
			end -- 693
		end -- 693
		if not _match_0 then -- 693
			return { -- 700
				success = false, -- 700
				message = "invalid arguments" -- 700
			} -- 700
		end -- 693
	end -- 693
	return invalidArguments -- 692
end) -- 692
HttpServer:post("/git/auth/save", function(req) -- 702
	do -- 703
		local _type_0 = type(req) -- 703
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 703
		if _tab_0 then -- 703
			local body = req.body -- 703
			if body ~= nil then -- 703
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token -- 704
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$") -- 705
				label = tostring(label or ""):match("^%s*(.-)%s*$") -- 706
				local credentialType = tostring(body.type or "token") -- 707
				username = tostring(username or "") -- 708
				local secret -- 709
				if credentialType == "basic" then -- 709
					secret = tostring(password or "") -- 709
				else -- 709
					secret = tostring(token or password or "") -- 709
				end -- 709
				if host == "" then -- 710
					return { -- 710
						success = false, -- 710
						message = "host is required" -- 710
					} -- 710
				end -- 710
				if label == "" then -- 711
					return { -- 711
						success = false, -- 711
						message = "label is required" -- 711
					} -- 711
				end -- 711
				if secret == "" then -- 712
					return { -- 712
						success = false, -- 712
						message = "secret is required" -- 712
					} -- 712
				end -- 712
				if not (("basic" == credentialType or "token" == credentialType)) then -- 713
					return { -- 713
						success = false, -- 713
						message = "invalid type" -- 713
					} -- 713
				end -- 713
				ensureGitTables() -- 714
				local now = os.time() -- 715
				if id then -- 716
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", { -- 718
						host, -- 718
						label, -- 718
						credentialType, -- 718
						username, -- 718
						secret, -- 718
						now, -- 718
						(tonumber(id) or 0) -- 718
					}) -- 717
					return { -- 720
						success = true, -- 720
						id = tonumber(id) -- 720
					} -- 720
				else -- 722
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", { -- 723
						host, -- 723
						label, -- 723
						credentialType, -- 723
						username, -- 723
						secret, -- 723
						now, -- 723
						now -- 723
					}) -- 722
					local rows = DB:query("select last_insert_rowid()") -- 725
					return { -- 726
						success = true, -- 726
						id = rows and rows[1] and rows[1][1] -- 726
					} -- 726
				end -- 716
			end -- 703
		end -- 703
	end -- 703
	return invalidArguments -- 702
end) -- 702
HttpServer:post("/git/auth/delete", function(req) -- 728
	do -- 729
		local _type_0 = type(req) -- 729
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 729
		if _tab_0 then -- 729
			local id -- 729
			do -- 729
				local _obj_0 = req.body -- 729
				local _type_1 = type(_obj_0) -- 729
				if "table" == _type_1 or "userdata" == _type_1 then -- 729
					id = _obj_0.id -- 729
				end -- 729
			end -- 729
			if id ~= nil then -- 729
				ensureGitTables() -- 730
				local credentialId = tonumber(id) or 0 -- 731
				DB:exec("delete from GitCredential where id = ?", { -- 732
					credentialId -- 732
				}) -- 732
				return { -- 733
					success = true -- 733
				} -- 733
			end -- 729
		end -- 729
	end -- 729
	return invalidArguments -- 728
end) -- 728
HttpServer:postSchedule("/git/auth/test", function(req) -- 735
	do -- 736
		local _type_0 = type(req) -- 736
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 736
		if _tab_0 then -- 736
			local body = req.body -- 736
			if body ~= nil then -- 736
				local repoPath, url, authId = body.repoPath, body.url, body.authId -- 737
				local credential = gitLoadCredential(authId) -- 738
				local optionsJSON = gitAuthOptionsJSON(credential) -- 739
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20) -- 740
			end -- 736
		end -- 736
	end -- 736
	return invalidArguments -- 735
end) -- 735
HttpServer:post("/agent/session/create", function(req) -- 742
	do -- 743
		local _type_0 = type(req) -- 743
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 743
		if _tab_0 then -- 743
			local projectRoot -- 743
			do -- 743
				local _obj_0 = req.body -- 743
				local _type_1 = type(_obj_0) -- 743
				if "table" == _type_1 or "userdata" == _type_1 then -- 743
					projectRoot = _obj_0.projectRoot -- 743
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
			if projectRoot ~= nil and title ~= nil then -- 743
				return AgentSession.createSession(projectRoot, title) -- 744
			end -- 743
		end -- 743
	end -- 743
	return invalidArguments -- 742
end) -- 742
HttpServer:post("/agent/session/create-sub", function(req) -- 746
	do -- 747
		local _type_0 = type(req) -- 747
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 747
		if _tab_0 then -- 747
			local parentSessionId -- 747
			do -- 747
				local _obj_0 = req.body -- 747
				local _type_1 = type(_obj_0) -- 747
				if "table" == _type_1 or "userdata" == _type_1 then -- 747
					parentSessionId = _obj_0.parentSessionId -- 747
				end -- 747
			end -- 747
			local title -- 747
			do -- 747
				local _obj_0 = req.body -- 747
				local _type_1 = type(_obj_0) -- 747
				if "table" == _type_1 or "userdata" == _type_1 then -- 747
					title = _obj_0.title -- 747
				end -- 747
			end -- 747
			if parentSessionId ~= nil and title ~= nil then -- 747
				return AgentSession.createSubSession(parentSessionId, title) -- 748
			end -- 747
		end -- 747
	end -- 747
	return invalidArguments -- 746
end) -- 746
HttpServer:post("/agent/session/get", function(req) -- 750
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
			if sessionId ~= nil then -- 751
				return AgentSession.getSession(sessionId) -- 752
			end -- 751
		end -- 751
	end -- 751
	return invalidArguments -- 750
end) -- 750
HttpServer:post("/agent/session/send", function(req) -- 754
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
			local prompt -- 755
			do -- 755
				local _obj_0 = req.body -- 755
				local _type_1 = type(_obj_0) -- 755
				if "table" == _type_1 or "userdata" == _type_1 then -- 755
					prompt = _obj_0.prompt -- 755
				end -- 755
			end -- 755
			if sessionId ~= nil and prompt ~= nil then -- 755
				return AgentSession.sendPrompt(sessionId, prompt, false, req.body.disabledAgentTools) -- 756
			end -- 755
		end -- 755
	end -- 755
	return invalidArguments -- 754
end) -- 754
HttpServer:post("/agent/session/resend", function(req) -- 758
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
			local messageId -- 759
			do -- 759
				local _obj_0 = req.body -- 759
				local _type_1 = type(_obj_0) -- 759
				if "table" == _type_1 or "userdata" == _type_1 then -- 759
					messageId = _obj_0.messageId -- 759
				end -- 759
			end -- 759
			local prompt -- 759
			do -- 759
				local _obj_0 = req.body -- 759
				local _type_1 = type(_obj_0) -- 759
				if "table" == _type_1 or "userdata" == _type_1 then -- 759
					prompt = _obj_0.prompt -- 759
				end -- 759
			end -- 759
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 759
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools) -- 760
			end -- 759
		end -- 759
	end -- 759
	return invalidArguments -- 758
end) -- 758
HttpServer:post("/agent/task/status", function(req) -- 762
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
			if sessionId ~= nil then -- 763
				local res = AgentSession.getSession(sessionId) -- 764
				if not res.success then -- 765
					return res -- 765
				end -- 765
				local taskId = res.session.currentTaskId -- 766
				local checkpoints -- 767
				if taskId then -- 767
					checkpoints = AgentTools.listCheckpoints(taskId) -- 767
				else -- 767
					checkpoints = { } -- 767
				end -- 767
				return { -- 769
					success = true, -- 769
					session = res.session, -- 770
					relatedSessions = res.relatedSessions, -- 771
					spawnInfo = res.spawnInfo, -- 772
					messages = res.messages, -- 773
					steps = res.steps, -- 774
					checkpoints = checkpoints -- 775
				} -- 768
			end -- 763
		end -- 763
	end -- 763
	return invalidArguments -- 762
end) -- 762
HttpServer:post("/agent/task/running", function() -- 777
	local res = AgentSession.listRunningSessions() -- 778
	if res.success and #res.sessions == 0 then -- 779
		res.sessions = nil -- 780
	end -- 779
	return res -- 781
end) -- 777
HttpServer:post("/agent/task/stop", function(req) -- 783
	do -- 784
		local _type_0 = type(req) -- 784
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 784
		if _tab_0 then -- 784
			local sessionId -- 784
			do -- 784
				local _obj_0 = req.body -- 784
				local _type_1 = type(_obj_0) -- 784
				if "table" == _type_1 or "userdata" == _type_1 then -- 784
					sessionId = _obj_0.sessionId -- 784
				end -- 784
			end -- 784
			if sessionId ~= nil then -- 784
				return AgentSession.stopSessionTask(sessionId) -- 785
			end -- 784
		end -- 784
	end -- 784
	return invalidArguments -- 783
end) -- 783
HttpServer:post("/agent/checkpoint/list", function(req) -- 787
	do -- 788
		local _type_0 = type(req) -- 788
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 788
		if _tab_0 then -- 788
			local taskId -- 788
			do -- 788
				local _obj_0 = req.body -- 788
				local _type_1 = type(_obj_0) -- 788
				if "table" == _type_1 or "userdata" == _type_1 then -- 788
					taskId = _obj_0.taskId -- 788
				end -- 788
			end -- 788
			local sessionId -- 788
			do -- 788
				local _obj_0 = req.body -- 788
				local _type_1 = type(_obj_0) -- 788
				if "table" == _type_1 or "userdata" == _type_1 then -- 788
					sessionId = _obj_0.sessionId -- 788
				end -- 788
			end -- 788
			if sessionId ~= nil then -- 788
				if not taskId and sessionId then -- 789
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 790
				end -- 789
				if not taskId then -- 791
					return { -- 791
						success = false, -- 791
						message = "task not found" -- 791
					} -- 791
				end -- 791
				return { -- 793
					success = true, -- 793
					taskId = taskId, -- 794
					checkpoints = AgentTools.listCheckpoints(taskId) -- 795
				} -- 792
			end -- 788
		end -- 788
	end -- 788
	return invalidArguments -- 787
end) -- 787
HttpServer:post("/agent/checkpoint/diff", function(req) -- 797
	do -- 798
		local _type_0 = type(req) -- 798
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 798
		if _tab_0 then -- 798
			local checkpointId -- 798
			do -- 798
				local _obj_0 = req.body -- 798
				local _type_1 = type(_obj_0) -- 798
				if "table" == _type_1 or "userdata" == _type_1 then -- 798
					checkpointId = _obj_0.checkpointId -- 798
				end -- 798
			end -- 798
			if checkpointId ~= nil then -- 798
				if not (checkpointId > 0) then -- 799
					return { -- 799
						success = false, -- 799
						message = "invalid checkpointId" -- 799
					} -- 799
				end -- 799
				return AgentTools.getCheckpointDiff(checkpointId) -- 800
			end -- 798
		end -- 798
	end -- 798
	return invalidArguments -- 797
end) -- 797
HttpServer:post("/agent/task/diff", function(req) -- 802
	do -- 803
		local _type_0 = type(req) -- 803
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 803
		if _tab_0 then -- 803
			local taskId -- 803
			do -- 803
				local _obj_0 = req.body -- 803
				local _type_1 = type(_obj_0) -- 803
				if "table" == _type_1 or "userdata" == _type_1 then -- 803
					taskId = _obj_0.taskId -- 803
				end -- 803
			end -- 803
			if taskId ~= nil then -- 803
				if not (taskId > 0) then -- 804
					return { -- 804
						success = false, -- 804
						message = "invalid taskId" -- 804
					} -- 804
				end -- 804
				return AgentTools.getTaskChangeSetDiff(taskId) -- 805
			end -- 803
		end -- 803
	end -- 803
	return invalidArguments -- 802
end) -- 802
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 807
	do -- 808
		local _type_0 = type(req) -- 808
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 808
		if _tab_0 then -- 808
			local sessionId -- 808
			do -- 808
				local _obj_0 = req.body -- 808
				local _type_1 = type(_obj_0) -- 808
				if "table" == _type_1 or "userdata" == _type_1 then -- 808
					sessionId = _obj_0.sessionId -- 808
				end -- 808
			end -- 808
			local checkpointId -- 808
			do -- 808
				local _obj_0 = req.body -- 808
				local _type_1 = type(_obj_0) -- 808
				if "table" == _type_1 or "userdata" == _type_1 then -- 808
					checkpointId = _obj_0.checkpointId -- 808
				end -- 808
			end -- 808
			if sessionId ~= nil and checkpointId ~= nil then -- 808
				if not (checkpointId > 0) then -- 809
					return { -- 809
						success = false, -- 809
						message = "invalid checkpointId" -- 809
					} -- 809
				end -- 809
				local res = AgentSession.getSession(sessionId) -- 810
				if not res.success then -- 811
					return res -- 811
				end -- 811
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, res.session.projectRoot) -- 812
				if not rollbackRes.success then -- 813
					return rollbackRes -- 813
				end -- 813
				return { -- 815
					success = true, -- 815
					checkpointId = rollbackRes.checkpointId -- 816
				} -- 814
			end -- 808
		end -- 808
	end -- 808
	return invalidArguments -- 807
end) -- 807
HttpServer:post("/agent/task/rollback", function(req) -- 818
	do -- 819
		local _type_0 = type(req) -- 819
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 819
		if _tab_0 then -- 819
			local sessionId -- 819
			do -- 819
				local _obj_0 = req.body -- 819
				local _type_1 = type(_obj_0) -- 819
				if "table" == _type_1 or "userdata" == _type_1 then -- 819
					sessionId = _obj_0.sessionId -- 819
				end -- 819
			end -- 819
			local taskId -- 819
			do -- 819
				local _obj_0 = req.body -- 819
				local _type_1 = type(_obj_0) -- 819
				if "table" == _type_1 or "userdata" == _type_1 then -- 819
					taskId = _obj_0.taskId -- 819
				end -- 819
			end -- 819
			if sessionId ~= nil and taskId ~= nil then -- 819
				if not (taskId > 0) then -- 820
					return { -- 820
						success = false, -- 820
						message = "invalid taskId" -- 820
					} -- 820
				end -- 820
				local res = AgentSession.getSession(sessionId) -- 821
				if not res.success then -- 822
					return res -- 822
				end -- 822
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, res.session.projectRoot) -- 823
				if not rollbackRes.success then -- 824
					return rollbackRes -- 824
				end -- 824
				return { -- 826
					success = true, -- 826
					taskId = rollbackRes.taskId, -- 827
					checkpointId = rollbackRes.checkpointId, -- 828
					checkpointCount = rollbackRes.checkpointCount -- 829
				} -- 825
			end -- 819
		end -- 819
	end -- 819
	return invalidArguments -- 818
end) -- 818
local getSearchPath -- 831
getSearchPath = function(file) -- 831
	do -- 832
		local dir = getProjectDirFromFile(file) -- 832
		if dir then -- 832
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 833
		end -- 832
	end -- 832
	return "" -- 831
end -- 831
local getSearchFolders -- 835
getSearchFolders = function(file) -- 835
	do -- 836
		local dir = getProjectDirFromFile(file) -- 836
		if dir then -- 836
			return { -- 838
				Path(dir, "Script"), -- 838
				dir -- 839
			} -- 837
		end -- 836
	end -- 836
	return { } -- 835
end -- 835
local disabledCheckForLua = { -- 842
	"incompatible number of returns", -- 842
	"unknown", -- 843
	"cannot index", -- 844
	"module not found", -- 845
	"don't know how to resolve", -- 846
	"ContainerItem", -- 847
	"cannot resolve a type", -- 848
	"invalid key", -- 849
	"inconsistent index type", -- 850
	"cannot use operator", -- 851
	"attempting ipairs loop", -- 852
	"expects record or nominal", -- 853
	"variable is not being assigned", -- 854
	"<invalid type>", -- 855
	"<any type>", -- 856
	"using the '#' operator", -- 857
	"can't match a record", -- 858
	"redeclaration of variable", -- 859
	"cannot apply pairs", -- 860
	"not a function", -- 861
	"to%-be%-closed" -- 862
} -- 841
local yueCheck -- 864
yueCheck = function(file, content, lax) -- 864
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 865
	if isTIC80 then -- 866
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 867
	end -- 866
	local searchPath = getSearchPath(file) -- 868
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 869
	local info = { } -- 870
	local globals = { } -- 871
	for _index_0 = 1, #checkResult do -- 872
		local _des_0 = checkResult[_index_0] -- 872
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 872
		if "error" == t then -- 873
			info[#info + 1] = { -- 874
				"syntax", -- 874
				file, -- 874
				line, -- 874
				col, -- 874
				msg -- 874
			} -- 874
		elseif "global" == t then -- 875
			globals[#globals + 1] = { -- 876
				msg, -- 876
				line, -- 876
				col -- 876
			} -- 876
		end -- 873
	end -- 872
	if luaCodes then -- 877
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 878
		if success then -- 879
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 880
			if not (lintResult == "") then -- 881
				lintResult = lintResult .. "\n" -- 881
			end -- 881
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 882
		else -- 883
			for _index_0 = 1, #lintResult do -- 883
				local _des_0 = lintResult[_index_0] -- 883
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 883
				if isTIC80 and tic80APIs[name] then -- 884
					goto _continue_0 -- 884
				end -- 884
				info[#info + 1] = { -- 885
					"syntax", -- 885
					file, -- 885
					line, -- 885
					col, -- 885
					"invalid global variable" -- 885
				} -- 885
				::_continue_0:: -- 884
			end -- 883
		end -- 879
	end -- 877
	return luaCodes, info -- 886
end -- 864
local luaCheck -- 888
luaCheck = function(file, content) -- 888
	local res, err = load(content, "check") -- 889
	if not res then -- 890
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 891
		return { -- 892
			success = false, -- 892
			info = { -- 892
				{ -- 892
					"syntax", -- 892
					file, -- 892
					tonumber(line), -- 892
					0, -- 892
					msg -- 892
				} -- 892
			} -- 892
		} -- 892
	end -- 890
	local success, info = teal.checkAsync(content, file, true, "") -- 893
	if info then -- 894
		do -- 895
			local _accum_0 = { } -- 895
			local _len_0 = 1 -- 895
			for _index_0 = 1, #info do -- 895
				local item = info[_index_0] -- 895
				local useCheck = true -- 896
				if not item[5]:match("unused") then -- 897
					for _index_1 = 1, #disabledCheckForLua do -- 898
						local check = disabledCheckForLua[_index_1] -- 898
						if item[5]:match(check) then -- 899
							useCheck = false -- 900
						end -- 899
					end -- 898
				end -- 897
				if not useCheck then -- 901
					goto _continue_0 -- 901
				end -- 901
				do -- 902
					local _exp_0 = item[1] -- 902
					if "type" == _exp_0 then -- 903
						item[1] = "warning" -- 904
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 905
						goto _continue_0 -- 906
					end -- 902
				end -- 902
				_accum_0[_len_0] = item -- 907
				_len_0 = _len_0 + 1 -- 896
				::_continue_0:: -- 896
			end -- 895
			info = _accum_0 -- 895
		end -- 895
		if #info == 0 then -- 908
			info = nil -- 909
			success = true -- 910
		end -- 908
	end -- 894
	return { -- 911
		success = success, -- 911
		info = info -- 911
	} -- 911
end -- 888
local luaCheckWithLineInfo -- 913
luaCheckWithLineInfo = function(file, luaCodes) -- 913
	local res = luaCheck(file, luaCodes) -- 914
	local info = { } -- 915
	if not res.success then -- 916
		local current = 1 -- 917
		local lastLine = 1 -- 918
		local lineMap = { } -- 919
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 920
			local num = lineCode:match("--%s*(%d+)%s*$") -- 921
			if num then -- 922
				lastLine = tonumber(num) -- 923
			end -- 922
			lineMap[current] = lastLine -- 924
			current = current + 1 -- 925
		end -- 920
		local _list_0 = res.info -- 926
		for _index_0 = 1, #_list_0 do -- 926
			local item = _list_0[_index_0] -- 926
			item[3] = lineMap[item[3]] or 0 -- 927
			item[4] = 0 -- 928
			info[#info + 1] = item -- 929
		end -- 926
		return false, info -- 930
	end -- 916
	return true, info -- 931
end -- 913
local getCompiledYueLine -- 933
getCompiledYueLine = function(content, line, row, file, lax) -- 933
	local luaCodes = yueCheck(file, content, lax) -- 934
	if not luaCodes then -- 935
		return nil -- 935
	end -- 935
	local current = 1 -- 936
	local lastLine = 1 -- 937
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 938
	local targetRow = nil -- 939
	local lineMap = { } -- 940
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 941
		local num = lineCode:match("--%s*(%d+)%s*$") -- 942
		if num then -- 943
			lastLine = tonumber(num) -- 943
		end -- 943
		lineMap[current] = lastLine -- 944
		if row <= lastLine and not targetRow then -- 945
			targetRow = current -- 946
			break -- 947
		end -- 945
		current = current + 1 -- 948
	end -- 941
	targetRow = current -- 949
	if targetLine and targetRow then -- 950
		return luaCodes, targetLine, targetRow, lineMap -- 951
	else -- 953
		return nil -- 953
	end -- 950
end -- 933
HttpServer:postSchedule("/check", function(req) -- 955
	do -- 956
		local _type_0 = type(req) -- 956
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 956
		if _tab_0 then -- 956
			local file -- 956
			do -- 956
				local _obj_0 = req.body -- 956
				local _type_1 = type(_obj_0) -- 956
				if "table" == _type_1 or "userdata" == _type_1 then -- 956
					file = _obj_0.file -- 956
				end -- 956
			end -- 956
			local content -- 956
			do -- 956
				local _obj_0 = req.body -- 956
				local _type_1 = type(_obj_0) -- 956
				if "table" == _type_1 or "userdata" == _type_1 then -- 956
					content = _obj_0.content -- 956
				end -- 956
			end -- 956
			if file ~= nil and content ~= nil then -- 956
				local ext = Path:getExt(file) -- 957
				if "tl" == ext then -- 958
					local searchPath = getSearchPath(file) -- 959
					do -- 960
						local isTIC80 = CheckTIC80Code(content) -- 960
						if isTIC80 then -- 960
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 961
						end -- 960
					end -- 960
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 962
					return { -- 963
						success = success, -- 963
						info = info -- 963
					} -- 963
				elseif "lua" == ext then -- 964
					do -- 965
						local isTIC80 = CheckTIC80Code(content) -- 965
						if isTIC80 then -- 965
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 966
						end -- 965
					end -- 965
					return luaCheck(file, content) -- 967
				elseif "yue" == ext then -- 968
					local luaCodes, info = yueCheck(file, content, false) -- 969
					local success = false -- 970
					if luaCodes then -- 971
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 972
						do -- 973
							local _tab_1 = { } -- 973
							local _idx_0 = #_tab_1 + 1 -- 973
							for _index_0 = 1, #info do -- 973
								local _value_0 = info[_index_0] -- 973
								_tab_1[_idx_0] = _value_0 -- 973
								_idx_0 = _idx_0 + 1 -- 973
							end -- 973
							local _idx_1 = #_tab_1 + 1 -- 973
							for _index_0 = 1, #luaInfo do -- 973
								local _value_0 = luaInfo[_index_0] -- 973
								_tab_1[_idx_1] = _value_0 -- 973
								_idx_1 = _idx_1 + 1 -- 973
							end -- 973
							info = _tab_1 -- 973
						end -- 973
						success = success and luaSuccess -- 974
					end -- 971
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
				elseif "xml" == ext then -- 979
					local success, result = xml.check(content) -- 980
					if success then -- 981
						local info -- 982
						success, info = luaCheckWithLineInfo(file, result) -- 982
						if #info > 0 then -- 983
							return { -- 984
								success = success, -- 984
								info = info -- 984
							} -- 984
						else -- 986
							return { -- 986
								success = success -- 986
							} -- 986
						end -- 983
					else -- 988
						local info -- 988
						do -- 988
							local _accum_0 = { } -- 988
							local _len_0 = 1 -- 988
							for _index_0 = 1, #result do -- 988
								local _des_0 = result[_index_0] -- 988
								local row, err = _des_0[1], _des_0[2] -- 988
								_accum_0[_len_0] = { -- 989
									"syntax", -- 989
									file, -- 989
									row, -- 989
									0, -- 989
									err -- 989
								} -- 989
								_len_0 = _len_0 + 1 -- 989
							end -- 988
							info = _accum_0 -- 988
						end -- 988
						return { -- 990
							success = false, -- 990
							info = info -- 990
						} -- 990
					end -- 981
				end -- 958
			end -- 956
		end -- 956
	end -- 956
	return { -- 955
		success = true -- 955
	} -- 955
end) -- 955
HttpServer:post("/body/parse", function(req) -- 992
	do -- 993
		local _type_0 = type(req) -- 993
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 993
		if _tab_0 then -- 993
			local file -- 993
			do -- 993
				local _obj_0 = req.body -- 993
				local _type_1 = type(_obj_0) -- 993
				if "table" == _type_1 or "userdata" == _type_1 then -- 993
					file = _obj_0.file -- 993
				end -- 993
			end -- 993
			local content -- 993
			do -- 993
				local _obj_0 = req.body -- 993
				local _type_1 = type(_obj_0) -- 993
				if "table" == _type_1 or "userdata" == _type_1 then -- 993
					content = _obj_0.content -- 993
				end -- 993
			end -- 993
			if file ~= nil and content ~= nil then -- 993
				if not (file:sub(-6) == ".b.lua") then -- 994
					return { -- 995
						success = false, -- 995
						phase = "request", -- 995
						message = "only .b.lua files can be converted" -- 995
					} -- 995
				end -- 994
				local loader, err = load("_ENV = {}\n" .. content) -- 996
				if not loader then -- 997
					return { -- 998
						success = false, -- 998
						phase = "parse", -- 998
						message = tostring(err) -- 998
					} -- 998
				end -- 997
				local ok, data = pcall(loader) -- 999
				if not ok then -- 1000
					return { -- 1001
						success = false, -- 1001
						phase = "execute", -- 1001
						message = tostring(data) -- 1001
					} -- 1001
				end -- 1000
				if not ("table" == type(data) and data[1] == "Array") then -- 1002
					return { -- 1003
						success = false, -- 1003
						phase = "validate", -- 1003
						message = "body lua root must be {\"Array\", ...}" -- 1003
					} -- 1003
				end -- 1002
				local text, jsonErr = json.encode(data, false, true) -- 1004
				if not text then -- 1005
					return { -- 1006
						success = false, -- 1006
						phase = "encode", -- 1006
						message = tostring(jsonErr) -- 1006
					} -- 1006
				end -- 1005
				return { -- 1007
					success = true, -- 1007
					json = text -- 1007
				} -- 1007
			end -- 993
		end -- 993
	end -- 993
	return { -- 992
		success = false, -- 992
		phase = "request", -- 992
		message = "invalid request" -- 992
	} -- 992
end) -- 992
local updateInferedDesc -- 1009
updateInferedDesc = function(infered) -- 1009
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1010
		return -- 1010
	end -- 1010
	local key, row = infered.key, infered.row -- 1011
	local codes = Content:loadAsync(key) -- 1012
	if codes then -- 1012
		local comments = { } -- 1013
		local line = 0 -- 1014
		local skipping = false -- 1015
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1016
			line = line + 1 -- 1017
			if line >= row then -- 1018
				break -- 1018
			end -- 1018
			if lineCode:match("^%s*%-%- @") then -- 1019
				skipping = true -- 1020
				goto _continue_0 -- 1021
			end -- 1019
			local result = lineCode:match("^%s*%-%- (.+)") -- 1022
			if result then -- 1022
				if not skipping then -- 1023
					comments[#comments + 1] = result -- 1023
				end -- 1023
			elseif #comments > 0 then -- 1024
				comments = { } -- 1025
				skipping = false -- 1026
			end -- 1022
			::_continue_0:: -- 1017
		end -- 1016
		infered.doc = table.concat(comments, "\n") -- 1027
	end -- 1012
end -- 1009
HttpServer:postSchedule("/infer", function(req) -- 1029
	do -- 1030
		local _type_0 = type(req) -- 1030
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1030
		if _tab_0 then -- 1030
			local lang -- 1030
			do -- 1030
				local _obj_0 = req.body -- 1030
				local _type_1 = type(_obj_0) -- 1030
				if "table" == _type_1 or "userdata" == _type_1 then -- 1030
					lang = _obj_0.lang -- 1030
				end -- 1030
			end -- 1030
			local file -- 1030
			do -- 1030
				local _obj_0 = req.body -- 1030
				local _type_1 = type(_obj_0) -- 1030
				if "table" == _type_1 or "userdata" == _type_1 then -- 1030
					file = _obj_0.file -- 1030
				end -- 1030
			end -- 1030
			local content -- 1030
			do -- 1030
				local _obj_0 = req.body -- 1030
				local _type_1 = type(_obj_0) -- 1030
				if "table" == _type_1 or "userdata" == _type_1 then -- 1030
					content = _obj_0.content -- 1030
				end -- 1030
			end -- 1030
			local line -- 1030
			do -- 1030
				local _obj_0 = req.body -- 1030
				local _type_1 = type(_obj_0) -- 1030
				if "table" == _type_1 or "userdata" == _type_1 then -- 1030
					line = _obj_0.line -- 1030
				end -- 1030
			end -- 1030
			local row -- 1030
			do -- 1030
				local _obj_0 = req.body -- 1030
				local _type_1 = type(_obj_0) -- 1030
				if "table" == _type_1 or "userdata" == _type_1 then -- 1030
					row = _obj_0.row -- 1030
				end -- 1030
			end -- 1030
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1030
				local searchPath = getSearchPath(file) -- 1031
				if "tl" == lang or "lua" == lang then -- 1032
					if CheckTIC80Code(content) then -- 1033
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1034
					end -- 1033
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1035
					if (infered ~= nil) then -- 1036
						updateInferedDesc(infered) -- 1037
						return { -- 1038
							success = true, -- 1038
							infered = infered -- 1038
						} -- 1038
					end -- 1036
				elseif "yue" == lang then -- 1039
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1040
					if not luaCodes then -- 1041
						return { -- 1041
							success = false -- 1041
						} -- 1041
					end -- 1041
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1042
					if (infered ~= nil) then -- 1043
						local col -- 1044
						file, row, col = infered.file, infered.row, infered.col -- 1044
						if file == "" and row > 0 and col > 0 then -- 1045
							infered.row = lineMap[row] or 0 -- 1046
							infered.col = 0 -- 1047
						end -- 1045
						updateInferedDesc(infered) -- 1048
						return { -- 1049
							success = true, -- 1049
							infered = infered -- 1049
						} -- 1049
					end -- 1043
				end -- 1032
			end -- 1030
		end -- 1030
	end -- 1030
	return { -- 1029
		success = false -- 1029
	} -- 1029
end) -- 1029
local _anon_func_3 = function(doc) -- 1100
	local _accum_0 = { } -- 1100
	local _len_0 = 1 -- 1100
	local _list_0 = doc.params -- 1100
	for _index_0 = 1, #_list_0 do -- 1100
		local param = _list_0[_index_0] -- 1100
		_accum_0[_len_0] = param.name -- 1100
		_len_0 = _len_0 + 1 -- 1100
	end -- 1100
	return _accum_0 -- 1100
end -- 1100
local getParamDocs -- 1051
getParamDocs = function(signatures) -- 1051
	do -- 1052
		local codes = Content:loadAsync(signatures[1].file) -- 1052
		if codes then -- 1052
			local comments = { } -- 1053
			local params = { } -- 1054
			local line = 0 -- 1055
			local docs = { } -- 1056
			local returnType = nil -- 1057
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1058
				line = line + 1 -- 1059
				local needBreak = true -- 1060
				for i, _des_0 in ipairs(signatures) do -- 1061
					local row = _des_0.row -- 1061
					if line >= row and not (docs[i] ~= nil) then -- 1062
						if #comments > 0 or #params > 0 or returnType then -- 1063
							docs[i] = { -- 1065
								doc = table.concat(comments, "  \n"), -- 1065
								returnType = returnType -- 1066
							} -- 1064
							if #params > 0 then -- 1068
								docs[i].params = params -- 1068
							end -- 1068
						else -- 1070
							docs[i] = false -- 1070
						end -- 1063
					end -- 1062
					if not docs[i] then -- 1071
						needBreak = false -- 1071
					end -- 1071
				end -- 1061
				if needBreak then -- 1072
					break -- 1072
				end -- 1072
				local result = lineCode:match("%s*%-%- (.+)") -- 1073
				if result then -- 1073
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1074
					if not name then -- 1075
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1076
					end -- 1075
					if name then -- 1077
						local pname = name -- 1078
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1079
							pname = pname .. "?" -- 1079
						end -- 1079
						params[#params + 1] = { -- 1081
							name = tostring(pname) .. ": " .. tostring(typ), -- 1081
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1082
						} -- 1080
					else -- 1085
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1085
						if typ then -- 1085
							if returnType then -- 1086
								returnType = returnType .. ", " .. typ -- 1087
							else -- 1089
								returnType = typ -- 1089
							end -- 1086
							result = result:gsub("@return", "**return:**") -- 1090
						end -- 1085
						comments[#comments + 1] = result -- 1091
					end -- 1077
				elseif #comments > 0 then -- 1092
					comments = { } -- 1093
					params = { } -- 1094
					returnType = nil -- 1095
				end -- 1073
			end -- 1058
			local results = { } -- 1096
			for _index_0 = 1, #docs do -- 1097
				local doc = docs[_index_0] -- 1097
				if not doc then -- 1098
					goto _continue_0 -- 1098
				end -- 1098
				if doc.params then -- 1099
					doc.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1100
				else -- 1102
					doc.desc = "function()" -- 1102
				end -- 1099
				if doc.returnType then -- 1103
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 1104
					doc.returnType = nil -- 1105
				end -- 1103
				results[#results + 1] = doc -- 1106
				::_continue_0:: -- 1098
			end -- 1097
			if #results > 0 then -- 1107
				return results -- 1107
			else -- 1107
				return nil -- 1107
			end -- 1107
		end -- 1052
	end -- 1052
	return nil -- 1051
end -- 1051
HttpServer:postSchedule("/signature", function(req) -- 1109
	do -- 1110
		local _type_0 = type(req) -- 1110
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1110
		if _tab_0 then -- 1110
			local lang -- 1110
			do -- 1110
				local _obj_0 = req.body -- 1110
				local _type_1 = type(_obj_0) -- 1110
				if "table" == _type_1 or "userdata" == _type_1 then -- 1110
					lang = _obj_0.lang -- 1110
				end -- 1110
			end -- 1110
			local file -- 1110
			do -- 1110
				local _obj_0 = req.body -- 1110
				local _type_1 = type(_obj_0) -- 1110
				if "table" == _type_1 or "userdata" == _type_1 then -- 1110
					file = _obj_0.file -- 1110
				end -- 1110
			end -- 1110
			local content -- 1110
			do -- 1110
				local _obj_0 = req.body -- 1110
				local _type_1 = type(_obj_0) -- 1110
				if "table" == _type_1 or "userdata" == _type_1 then -- 1110
					content = _obj_0.content -- 1110
				end -- 1110
			end -- 1110
			local line -- 1110
			do -- 1110
				local _obj_0 = req.body -- 1110
				local _type_1 = type(_obj_0) -- 1110
				if "table" == _type_1 or "userdata" == _type_1 then -- 1110
					line = _obj_0.line -- 1110
				end -- 1110
			end -- 1110
			local row -- 1110
			do -- 1110
				local _obj_0 = req.body -- 1110
				local _type_1 = type(_obj_0) -- 1110
				if "table" == _type_1 or "userdata" == _type_1 then -- 1110
					row = _obj_0.row -- 1110
				end -- 1110
			end -- 1110
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1110
				local searchPath = getSearchPath(file) -- 1111
				if "tl" == lang or "lua" == lang then -- 1112
					if CheckTIC80Code(content) then -- 1113
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1114
					end -- 1113
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1115
					if signatures then -- 1115
						signatures = getParamDocs(signatures) -- 1116
						if signatures then -- 1116
							return { -- 1117
								success = true, -- 1117
								signatures = signatures -- 1117
							} -- 1117
						end -- 1116
					end -- 1115
				elseif "yue" == lang then -- 1118
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1119
					if not luaCodes then -- 1120
						return { -- 1120
							success = false -- 1120
						} -- 1120
					end -- 1120
					do -- 1121
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1121
						if chainOp then -- 1121
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1122
							if withVar then -- 1122
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1123
							end -- 1122
						end -- 1121
					end -- 1121
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1124
					if signatures then -- 1124
						signatures = getParamDocs(signatures) -- 1125
						if signatures then -- 1125
							return { -- 1126
								success = true, -- 1126
								signatures = signatures -- 1126
							} -- 1126
						end -- 1125
					else -- 1127
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1127
						if signatures then -- 1127
							signatures = getParamDocs(signatures) -- 1128
							if signatures then -- 1128
								return { -- 1129
									success = true, -- 1129
									signatures = signatures -- 1129
								} -- 1129
							end -- 1128
						end -- 1127
					end -- 1124
				end -- 1112
			end -- 1110
		end -- 1110
	end -- 1110
	return { -- 1109
		success = false -- 1109
	} -- 1109
end) -- 1109
local luaKeywords = { -- 1132
	'and', -- 1132
	'break', -- 1133
	'do', -- 1134
	'else', -- 1135
	'elseif', -- 1136
	'end', -- 1137
	'false', -- 1138
	'for', -- 1139
	'function', -- 1140
	'goto', -- 1141
	'if', -- 1142
	'in', -- 1143
	'local', -- 1144
	'nil', -- 1145
	'not', -- 1146
	'or', -- 1147
	'repeat', -- 1148
	'return', -- 1149
	'then', -- 1150
	'true', -- 1151
	'until', -- 1152
	'while' -- 1153
} -- 1131
local tealKeywords = { -- 1157
	'record', -- 1157
	'as', -- 1158
	'is', -- 1159
	'type', -- 1160
	'embed', -- 1161
	'enum', -- 1162
	'global', -- 1163
	'any', -- 1164
	'boolean', -- 1165
	'integer', -- 1166
	'number', -- 1167
	'string', -- 1168
	'thread' -- 1169
} -- 1156
local yueKeywords = { -- 1173
	"and", -- 1173
	"break", -- 1174
	"do", -- 1175
	"else", -- 1176
	"elseif", -- 1177
	"false", -- 1178
	"for", -- 1179
	"goto", -- 1180
	"if", -- 1181
	"in", -- 1182
	"local", -- 1183
	"nil", -- 1184
	"not", -- 1185
	"or", -- 1186
	"repeat", -- 1187
	"return", -- 1188
	"then", -- 1189
	"true", -- 1190
	"until", -- 1191
	"while", -- 1192
	"as", -- 1193
	"class", -- 1194
	"continue", -- 1195
	"export", -- 1196
	"extends", -- 1197
	"from", -- 1198
	"global", -- 1199
	"import", -- 1200
	"macro", -- 1201
	"switch", -- 1202
	"try", -- 1203
	"unless", -- 1204
	"using", -- 1205
	"when", -- 1206
	"with" -- 1207
} -- 1172
local _anon_func_4 = function(f) -- 1243
	local _val_0 = Path:getExt(f) -- 1243
	return "ttf" == _val_0 or "otf" == _val_0 -- 1243
end -- 1243
local _anon_func_5 = function(suggestions) -- 1269
	local _tbl_0 = { } -- 1269
	for _index_0 = 1, #suggestions do -- 1269
		local item = suggestions[_index_0] -- 1269
		_tbl_0[item[1] .. item[2]] = item -- 1269
	end -- 1269
	return _tbl_0 -- 1269
end -- 1269
HttpServer:postSchedule("/complete", function(req) -- 1210
	do -- 1211
		local _type_0 = type(req) -- 1211
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1211
		if _tab_0 then -- 1211
			local lang -- 1211
			do -- 1211
				local _obj_0 = req.body -- 1211
				local _type_1 = type(_obj_0) -- 1211
				if "table" == _type_1 or "userdata" == _type_1 then -- 1211
					lang = _obj_0.lang -- 1211
				end -- 1211
			end -- 1211
			local file -- 1211
			do -- 1211
				local _obj_0 = req.body -- 1211
				local _type_1 = type(_obj_0) -- 1211
				if "table" == _type_1 or "userdata" == _type_1 then -- 1211
					file = _obj_0.file -- 1211
				end -- 1211
			end -- 1211
			local content -- 1211
			do -- 1211
				local _obj_0 = req.body -- 1211
				local _type_1 = type(_obj_0) -- 1211
				if "table" == _type_1 or "userdata" == _type_1 then -- 1211
					content = _obj_0.content -- 1211
				end -- 1211
			end -- 1211
			local line -- 1211
			do -- 1211
				local _obj_0 = req.body -- 1211
				local _type_1 = type(_obj_0) -- 1211
				if "table" == _type_1 or "userdata" == _type_1 then -- 1211
					line = _obj_0.line -- 1211
				end -- 1211
			end -- 1211
			local row -- 1211
			do -- 1211
				local _obj_0 = req.body -- 1211
				local _type_1 = type(_obj_0) -- 1211
				if "table" == _type_1 or "userdata" == _type_1 then -- 1211
					row = _obj_0.row -- 1211
				end -- 1211
			end -- 1211
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1211
				local searchPath = getSearchPath(file) -- 1212
				repeat -- 1213
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1214
					if lang == "yue" then -- 1215
						if not item then -- 1216
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1216
						end -- 1216
						if not item then -- 1217
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1217
						end -- 1217
					end -- 1215
					local searchType = nil -- 1218
					if not item then -- 1219
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1220
						if lang == "yue" then -- 1221
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1222
						end -- 1221
						if (item ~= nil) then -- 1223
							searchType = "Image" -- 1223
						end -- 1223
					end -- 1219
					if not item then -- 1224
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1225
						if lang == "yue" then -- 1226
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1227
						end -- 1226
						if (item ~= nil) then -- 1228
							searchType = "Font" -- 1228
						end -- 1228
					end -- 1224
					if not item then -- 1229
						break -- 1229
					end -- 1229
					local searchPaths = Content.searchPaths -- 1230
					local _list_0 = getSearchFolders(file) -- 1231
					for _index_0 = 1, #_list_0 do -- 1231
						local folder = _list_0[_index_0] -- 1231
						searchPaths[#searchPaths + 1] = folder -- 1232
					end -- 1231
					if searchType then -- 1233
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1233
					end -- 1233
					local tokens -- 1234
					do -- 1234
						local _accum_0 = { } -- 1234
						local _len_0 = 1 -- 1234
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1234
							_accum_0[_len_0] = mod -- 1234
							_len_0 = _len_0 + 1 -- 1234
						end -- 1234
						tokens = _accum_0 -- 1234
					end -- 1234
					local suggestions = { } -- 1235
					for _index_0 = 1, #searchPaths do -- 1236
						local path = searchPaths[_index_0] -- 1236
						local sPath = Path(path, table.unpack(tokens)) -- 1237
						if not Content:exist(sPath) then -- 1238
							goto _continue_0 -- 1238
						end -- 1238
						if searchType == "Font" then -- 1239
							local fontPath = Path(sPath, "Font") -- 1240
							if Content:exist(fontPath) then -- 1241
								local _list_1 = Content:getFiles(fontPath) -- 1242
								for _index_1 = 1, #_list_1 do -- 1242
									local f = _list_1[_index_1] -- 1242
									if _anon_func_4(f) then -- 1243
										if "." == f:sub(1, 1) then -- 1244
											goto _continue_1 -- 1244
										end -- 1244
										suggestions[#suggestions + 1] = { -- 1245
											Path:getName(f), -- 1245
											"font", -- 1245
											"field" -- 1245
										} -- 1245
									end -- 1243
									::_continue_1:: -- 1243
								end -- 1242
							end -- 1241
						end -- 1239
						local _list_1 = Content:getFiles(sPath) -- 1246
						for _index_1 = 1, #_list_1 do -- 1246
							local f = _list_1[_index_1] -- 1246
							if "Image" == searchType then -- 1247
								do -- 1248
									local _exp_0 = Path:getExt(f) -- 1248
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1248
										if "." == f:sub(1, 1) then -- 1249
											goto _continue_2 -- 1249
										end -- 1249
										suggestions[#suggestions + 1] = { -- 1250
											f, -- 1250
											"image", -- 1250
											"field" -- 1250
										} -- 1250
									end -- 1248
								end -- 1248
								goto _continue_2 -- 1251
							elseif "Font" == searchType then -- 1252
								do -- 1253
									local _exp_0 = Path:getExt(f) -- 1253
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1253
										if "." == f:sub(1, 1) then -- 1254
											goto _continue_2 -- 1254
										end -- 1254
										suggestions[#suggestions + 1] = { -- 1255
											f, -- 1255
											"font", -- 1255
											"field" -- 1255
										} -- 1255
									end -- 1253
								end -- 1253
								goto _continue_2 -- 1256
							end -- 1247
							local _exp_0 = Path:getExt(f) -- 1257
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1257
								local name = Path:getName(f) -- 1258
								if "d" == Path:getExt(name) then -- 1259
									goto _continue_2 -- 1259
								end -- 1259
								if "." == name:sub(1, 1) then -- 1260
									goto _continue_2 -- 1260
								end -- 1260
								suggestions[#suggestions + 1] = { -- 1261
									name, -- 1261
									"module", -- 1261
									"field" -- 1261
								} -- 1261
							end -- 1257
							::_continue_2:: -- 1247
						end -- 1246
						local _list_2 = Content:getDirs(sPath) -- 1262
						for _index_1 = 1, #_list_2 do -- 1262
							local dir = _list_2[_index_1] -- 1262
							if "." == dir:sub(1, 1) then -- 1263
								goto _continue_3 -- 1263
							end -- 1263
							suggestions[#suggestions + 1] = { -- 1264
								dir, -- 1264
								"folder", -- 1264
								"variable" -- 1264
							} -- 1264
							::_continue_3:: -- 1263
						end -- 1262
						::_continue_0:: -- 1237
					end -- 1236
					if item == "" and not searchType then -- 1265
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1266
						for _index_0 = 1, #_list_1 do -- 1266
							local _des_0 = _list_1[_index_0] -- 1266
							local name = _des_0[1] -- 1266
							suggestions[#suggestions + 1] = { -- 1267
								name, -- 1267
								"dora module", -- 1267
								"function" -- 1267
							} -- 1267
						end -- 1266
					end -- 1265
					if #suggestions > 0 then -- 1268
						do -- 1269
							local _accum_0 = { } -- 1269
							local _len_0 = 1 -- 1269
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1269
								_accum_0[_len_0] = v -- 1269
								_len_0 = _len_0 + 1 -- 1269
							end -- 1269
							suggestions = _accum_0 -- 1269
						end -- 1269
						return { -- 1270
							success = true, -- 1270
							suggestions = suggestions -- 1270
						} -- 1270
					else -- 1272
						return { -- 1272
							success = false -- 1272
						} -- 1272
					end -- 1268
				until true -- 1213
				if "tl" == lang or "lua" == lang then -- 1274
					do -- 1275
						local isTIC80 = CheckTIC80Code(content) -- 1275
						if isTIC80 then -- 1275
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1276
						end -- 1275
					end -- 1275
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1277
					if not line:match("[%.:]$") then -- 1278
						local checkSet -- 1279
						do -- 1279
							local _tbl_0 = { } -- 1279
							for _index_0 = 1, #suggestions do -- 1279
								local _des_0 = suggestions[_index_0] -- 1279
								local name = _des_0[1] -- 1279
								_tbl_0[name] = true -- 1279
							end -- 1279
							checkSet = _tbl_0 -- 1279
						end -- 1279
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1280
						for _index_0 = 1, #_list_0 do -- 1280
							local item = _list_0[_index_0] -- 1280
							if not checkSet[item[1]] then -- 1281
								suggestions[#suggestions + 1] = item -- 1281
							end -- 1281
						end -- 1280
						for _index_0 = 1, #luaKeywords do -- 1282
							local word = luaKeywords[_index_0] -- 1282
							suggestions[#suggestions + 1] = { -- 1283
								word, -- 1283
								"keyword", -- 1283
								"keyword" -- 1283
							} -- 1283
						end -- 1282
						if lang == "tl" then -- 1284
							for _index_0 = 1, #tealKeywords do -- 1285
								local word = tealKeywords[_index_0] -- 1285
								suggestions[#suggestions + 1] = { -- 1286
									word, -- 1286
									"keyword", -- 1286
									"keyword" -- 1286
								} -- 1286
							end -- 1285
						end -- 1284
					end -- 1278
					if #suggestions > 0 then -- 1287
						return { -- 1288
							success = true, -- 1288
							suggestions = suggestions -- 1288
						} -- 1288
					end -- 1287
				elseif "yue" == lang then -- 1289
					local suggestions = { } -- 1290
					local gotGlobals = false -- 1291
					do -- 1292
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1292
						if luaCodes then -- 1292
							gotGlobals = true -- 1293
							do -- 1294
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1294
								if chainOp then -- 1294
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1295
									if not withVar then -- 1296
										return { -- 1296
											success = false -- 1296
										} -- 1296
									end -- 1296
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1297
								elseif line:match("^([%.\\])$") then -- 1298
									return { -- 1299
										success = false -- 1299
									} -- 1299
								end -- 1294
							end -- 1294
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1300
							for _index_0 = 1, #_list_0 do -- 1300
								local item = _list_0[_index_0] -- 1300
								suggestions[#suggestions + 1] = item -- 1300
							end -- 1300
							if #suggestions == 0 then -- 1301
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1302
								for _index_0 = 1, #_list_1 do -- 1302
									local item = _list_1[_index_0] -- 1302
									suggestions[#suggestions + 1] = item -- 1302
								end -- 1302
							end -- 1301
						end -- 1292
					end -- 1292
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1303
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
						if not gotGlobals then -- 1307
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1308
							for _index_0 = 1, #_list_1 do -- 1308
								local item = _list_1[_index_0] -- 1308
								if not checkSet[item[1]] then -- 1309
									suggestions[#suggestions + 1] = item -- 1309
								end -- 1309
							end -- 1308
						end -- 1307
						for _index_0 = 1, #yueKeywords do -- 1310
							local word = yueKeywords[_index_0] -- 1310
							if not checkSet[word] then -- 1311
								suggestions[#suggestions + 1] = { -- 1312
									word, -- 1312
									"keyword", -- 1312
									"keyword" -- 1312
								} -- 1312
							end -- 1311
						end -- 1310
					end -- 1303
					if #suggestions > 0 then -- 1313
						return { -- 1314
							success = true, -- 1314
							suggestions = suggestions -- 1314
						} -- 1314
					end -- 1313
				elseif "xml" == lang then -- 1315
					local items = xml.complete(content) -- 1316
					if #items > 0 then -- 1317
						local suggestions -- 1318
						do -- 1318
							local _accum_0 = { } -- 1318
							local _len_0 = 1 -- 1318
							for _index_0 = 1, #items do -- 1318
								local _des_0 = items[_index_0] -- 1318
								local label, insertText = _des_0[1], _des_0[2] -- 1318
								_accum_0[_len_0] = { -- 1319
									label, -- 1319
									insertText, -- 1319
									"field" -- 1319
								} -- 1319
								_len_0 = _len_0 + 1 -- 1319
							end -- 1318
							suggestions = _accum_0 -- 1318
						end -- 1318
						return { -- 1320
							success = true, -- 1320
							suggestions = suggestions -- 1320
						} -- 1320
					end -- 1317
				end -- 1274
			end -- 1211
		end -- 1211
	end -- 1211
	return { -- 1210
		success = false -- 1210
	} -- 1210
end) -- 1210
HttpServer:upload("/upload", function(req, filename) -- 1324
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
				local uploadPath = Path(Content.writablePath, ".upload") -- 1326
				if not Content:exist(uploadPath) then -- 1327
					Content:mkdir(uploadPath) -- 1328
				end -- 1327
				local targetPath = Path(uploadPath, filename) -- 1329
				Content:mkdir(Path:getPath(targetPath)) -- 1330
				return targetPath -- 1331
			end -- 1325
		end -- 1325
	end -- 1325
	return nil -- 1324
end, function(req, file) -- 1332
	do -- 1333
		local _type_0 = type(req) -- 1333
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1333
		if _tab_0 then -- 1333
			local path -- 1333
			do -- 1333
				local _obj_0 = req.params -- 1333
				local _type_1 = type(_obj_0) -- 1333
				if "table" == _type_1 or "userdata" == _type_1 then -- 1333
					path = _obj_0.path -- 1333
				end -- 1333
			end -- 1333
			if path ~= nil then -- 1333
				path = Path(Content.writablePath, path) -- 1334
				if Content:exist(path) then -- 1335
					local uploadPath = Path(Content.writablePath, ".upload") -- 1336
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1337
					Content:mkdir(Path:getPath(targetPath)) -- 1338
					if Content:move(file, targetPath) then -- 1339
						return true -- 1340
					end -- 1339
				end -- 1335
			end -- 1333
		end -- 1333
	end -- 1333
	return false -- 1332
end) -- 1322
HttpServer:post("/list", function(req) -- 1343
	do -- 1344
		local _type_0 = type(req) -- 1344
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1344
		if _tab_0 then -- 1344
			local path -- 1344
			do -- 1344
				local _obj_0 = req.body -- 1344
				local _type_1 = type(_obj_0) -- 1344
				if "table" == _type_1 or "userdata" == _type_1 then -- 1344
					path = _obj_0.path -- 1344
				end -- 1344
			end -- 1344
			if path ~= nil then -- 1344
				if Content:exist(path) then -- 1345
					local files = { } -- 1346
					local visitAssets -- 1347
					visitAssets = function(path, folder) -- 1347
						local dirs = Content:getDirs(path) -- 1348
						for _index_0 = 1, #dirs do -- 1349
							local dir = dirs[_index_0] -- 1349
							if dir:match("^%.") then -- 1350
								goto _continue_0 -- 1350
							end -- 1350
							local current -- 1351
							if folder == "" then -- 1351
								current = dir -- 1352
							else -- 1354
								current = Path(folder, dir) -- 1354
							end -- 1351
							files[#files + 1] = current -- 1355
							visitAssets(Path(path, dir), current) -- 1356
							::_continue_0:: -- 1350
						end -- 1349
						local fs = Content:getFiles(path) -- 1357
						for _index_0 = 1, #fs do -- 1358
							local f = fs[_index_0] -- 1358
							if (".DS_Store" == f) then -- 1359
								goto _continue_1 -- 1360
							end -- 1359
							if folder == "" then -- 1361
								files[#files + 1] = f -- 1362
							else -- 1364
								files[#files + 1] = Path(folder, f) -- 1364
							end -- 1361
							::_continue_1:: -- 1359
						end -- 1358
					end -- 1347
					visitAssets(path, "") -- 1365
					if #files == 0 then -- 1366
						files = nil -- 1366
					end -- 1366
					return { -- 1367
						success = true, -- 1367
						files = files -- 1367
					} -- 1367
				end -- 1345
			end -- 1344
		end -- 1344
	end -- 1344
	return { -- 1343
		success = false -- 1343
	} -- 1343
end) -- 1343
HttpServer:post("/info", function() -- 1369
	local Entry = require("Script.Dev.Entry") -- 1370
	local webProfiler, drawerWidth -- 1371
	do -- 1371
		local _obj_0 = Entry.getConfig() -- 1371
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 1371
	end -- 1371
	local engineDev = Entry.getEngineDev() -- 1372
	Entry.connectWebIDE() -- 1373
	return { -- 1375
		platform = App.platform, -- 1375
		locale = App.locale, -- 1376
		version = App.version, -- 1377
		engineDev = engineDev, -- 1378
		webProfiler = webProfiler, -- 1379
		drawerWidth = drawerWidth -- 1380
	} -- 1374
end) -- 1369
local ensureLLMConfigTable -- 1382
ensureLLMConfigTable = function() -- 1382
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1383
	if columns and #columns > 0 then -- 1384
		local expected = { -- 1386
			id = true, -- 1386
			name = true, -- 1387
			url = true, -- 1388
			model = true, -- 1389
			api_key = true, -- 1390
			context_window = true, -- 1391
			temperature = true, -- 1392
			max_tokens = true, -- 1393
			reasoning_effort = true, -- 1394
			custom_options = true, -- 1395
			supports_function_calling = true, -- 1396
			active = true, -- 1397
			created_at = true, -- 1398
			updated_at = true -- 1399
		} -- 1385
		local existing = { } -- 1401
		local valid = true -- 1402
		for _index_0 = 1, #columns do -- 1403
			local row = columns[_index_0] -- 1403
			local columnName = tostring(row[2]) -- 1404
			existing[columnName] = true -- 1405
			if not expected[columnName] then -- 1406
				valid = false -- 1407
				break -- 1408
			end -- 1406
		end -- 1403
		if valid then -- 1409
			if not existing.context_window then -- 1410
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1411
			end -- 1410
			if not existing.temperature then -- 1412
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1413
			end -- 1412
			if not existing.max_tokens then -- 1414
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 1415
			end -- 1414
			if not existing.reasoning_effort then -- 1416
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1417
			end -- 1416
			if not existing.custom_options then -- 1418
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1419
			end -- 1418
			if not existing.supports_function_calling then -- 1420
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1421
			end -- 1420
		else -- 1423
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1423
		end -- 1409
	end -- 1384
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
	]]) -- 1424
end -- 1382
local normalizeContextWindow -- 1443
normalizeContextWindow = function(value) -- 1443
	local contextWindow = tonumber(value) -- 1444
	if contextWindow == nil or contextWindow < 64000 then -- 1445
		return 64000 -- 1446
	end -- 1445
	return math.max(64000, math.floor(contextWindow)) -- 1447
end -- 1443
local normalizeTemperature -- 1449
normalizeTemperature = function(value) -- 1449
	local temperature = tonumber(value) -- 1450
	if temperature == nil then -- 1451
		return 0.1 -- 1452
	end -- 1451
	return math.max(0, math.min(2, temperature)) -- 1453
end -- 1449
local normalizeMaxTokens -- 1455
normalizeMaxTokens = function(value) -- 1455
	local maxTokens = tonumber(value) -- 1456
	if maxTokens == nil or maxTokens < 1 then -- 1457
		return 8192 -- 1458
	end -- 1457
	return math.max(1, math.floor(maxTokens)) -- 1459
end -- 1455
local normalizeReasoningEffort -- 1461
normalizeReasoningEffort = function(value) -- 1461
	if value == nil then -- 1462
		return "" -- 1463
	end -- 1462
	local effort = tostring(value) -- 1464
	return effort:match("^%s*(.-)%s*$") or "" -- 1465
end -- 1461
local normalizeCustomOptions -- 1467
normalizeCustomOptions = function(value) -- 1467
	if value == nil then -- 1468
		return "" -- 1469
	end -- 1468
	local options = tostring(value) -- 1470
	options = options:match("^%s*(.-)%s*$") or "" -- 1471
	return options -- 1472
end -- 1467
local validateCustomOptions -- 1474
validateCustomOptions = function(value) -- 1474
	local options = normalizeCustomOptions(value) -- 1475
	if options == "" then -- 1476
		return true -- 1476
	end -- 1476
	if not options:match("^%s*{") then -- 1477
		return false -- 1477
	end -- 1477
	local decoded = json.decode(options) -- 1478
	return type(decoded) == "table" -- 1479
end -- 1474
HttpServer:post("/llm/list", function() -- 1481
	ensureLLMConfigTable() -- 1482
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active\n		from LLMConfig\n		order by id asc") -- 1483
	local items -- 1487
	if rows and #rows > 0 then -- 1487
		local _accum_0 = { } -- 1488
		local _len_0 = 1 -- 1488
		for _index_0 = 1, #rows do -- 1488
			local _des_0 = rows[_index_0] -- 1488
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11], _des_0[12] -- 1488
			_accum_0[_len_0] = { -- 1489
				id = id, -- 1489
				name = name, -- 1489
				url = url, -- 1489
				model = model, -- 1489
				key = key, -- 1489
				contextWindow = normalizeContextWindow(contextWindow), -- 1489
				temperature = normalizeTemperature(temperature), -- 1489
				maxTokens = normalizeMaxTokens(maxTokens), -- 1489
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1489
				customOptions = normalizeCustomOptions(customOptions), -- 1489
				supportsFunctionCalling = supportsFunctionCalling ~= 0, -- 1489
				active = active ~= 0 -- 1489
			} -- 1489
			_len_0 = _len_0 + 1 -- 1489
		end -- 1488
		items = _accum_0 -- 1487
	end -- 1487
	return { -- 1490
		success = true, -- 1490
		items = items -- 1490
	} -- 1490
end) -- 1481
HttpServer:post("/llm/create", function(req) -- 1492
	ensureLLMConfigTable() -- 1493
	do -- 1494
		local _type_0 = type(req) -- 1494
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1494
		if _tab_0 then -- 1494
			local body = req.body -- 1494
			if body ~= nil then -- 1494
				local name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1495
				local now = os.time() -- 1496
				if name == nil or url == nil or model == nil or key == nil then -- 1497
					return { -- 1498
						success = false, -- 1498
						message = "invalid" -- 1498
					} -- 1498
				end -- 1497
				contextWindow = normalizeContextWindow(contextWindow) -- 1499
				temperature = normalizeTemperature(temperature) -- 1500
				maxTokens = normalizeMaxTokens(maxTokens) -- 1501
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1502
				customOptions = normalizeCustomOptions(customOptions) -- 1503
				if not validateCustomOptions(customOptions) then -- 1504
					return { -- 1504
						success = false, -- 1504
						message = "customOptions must be a JSON object" -- 1504
					} -- 1504
				end -- 1504
				if supportsFunctionCalling == false then -- 1505
					supportsFunctionCalling = 0 -- 1505
				else -- 1505
					supportsFunctionCalling = 1 -- 1505
				end -- 1505
				if active then -- 1506
					active = 1 -- 1506
				else -- 1506
					active = 0 -- 1506
				end -- 1506
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1513
					tostring(name), -- 1513
					tostring(url), -- 1514
					tostring(model), -- 1515
					tostring(key), -- 1516
					contextWindow, -- 1517
					temperature, -- 1518
					maxTokens, -- 1519
					reasoningEffort, -- 1520
					customOptions, -- 1521
					supportsFunctionCalling, -- 1522
					active, -- 1523
					now, -- 1524
					now -- 1525
				}) -- 1507
				return { -- 1527
					success = affected >= 0 -- 1527
				} -- 1527
			end -- 1494
		end -- 1494
	end -- 1494
	return { -- 1492
		success = false, -- 1492
		message = "invalid" -- 1492
	} -- 1492
end) -- 1492
HttpServer:post("/llm/update", function(req) -- 1529
	ensureLLMConfigTable() -- 1530
	do -- 1531
		local _type_0 = type(req) -- 1531
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1531
		if _tab_0 then -- 1531
			local body = req.body -- 1531
			if body ~= nil then -- 1531
				local id, name, url, model, key, active, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1532
				local now = os.time() -- 1533
				id = tonumber(id) -- 1534
				if id == nil then -- 1535
					return { -- 1536
						success = false, -- 1536
						message = "invalid" -- 1536
					} -- 1536
				end -- 1535
				contextWindow = normalizeContextWindow(contextWindow) -- 1537
				temperature = normalizeTemperature(temperature) -- 1538
				maxTokens = normalizeMaxTokens(maxTokens) -- 1539
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1540
				customOptions = normalizeCustomOptions(customOptions) -- 1541
				if not validateCustomOptions(customOptions) then -- 1542
					return { -- 1542
						success = false, -- 1542
						message = "customOptions must be a JSON object" -- 1542
					} -- 1542
				end -- 1542
				if supportsFunctionCalling == false then -- 1543
					supportsFunctionCalling = 0 -- 1543
				else -- 1543
					supportsFunctionCalling = 1 -- 1543
				end -- 1543
				if active then -- 1544
					active = 1 -- 1544
				else -- 1544
					active = 0 -- 1544
				end -- 1544
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, active = ?, updated_at = ?\n			where id = ?", { -- 1549
					tostring(name), -- 1549
					tostring(url), -- 1550
					tostring(model), -- 1551
					tostring(key), -- 1552
					contextWindow, -- 1553
					temperature, -- 1554
					maxTokens, -- 1555
					reasoningEffort, -- 1556
					customOptions, -- 1557
					supportsFunctionCalling, -- 1558
					active, -- 1559
					now, -- 1560
					id -- 1561
				}) -- 1545
				return { -- 1563
					success = affected >= 0 -- 1563
				} -- 1563
			end -- 1531
		end -- 1531
	end -- 1531
	return { -- 1529
		success = false, -- 1529
		message = "invalid" -- 1529
	} -- 1529
end) -- 1529
HttpServer:post("/llm/delete", function(req) -- 1565
	ensureLLMConfigTable() -- 1566
	do -- 1567
		local _type_0 = type(req) -- 1567
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1567
		if _tab_0 then -- 1567
			local id -- 1567
			do -- 1567
				local _obj_0 = req.body -- 1567
				local _type_1 = type(_obj_0) -- 1567
				if "table" == _type_1 or "userdata" == _type_1 then -- 1567
					id = _obj_0.id -- 1567
				end -- 1567
			end -- 1567
			if id ~= nil then -- 1567
				id = tonumber(id) -- 1568
				if id == nil then -- 1569
					return { -- 1570
						success = false, -- 1570
						message = "invalid" -- 1570
					} -- 1570
				end -- 1569
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1571
					id -- 1571
				}) -- 1571
				return { -- 1572
					success = affected >= 0 -- 1572
				} -- 1572
			end -- 1567
		end -- 1567
	end -- 1567
	return { -- 1565
		success = false, -- 1565
		message = "invalid" -- 1565
	} -- 1565
end) -- 1565
HttpServer:post("/stat", function(req) -- 1574
	do -- 1575
		local _type_0 = type(req) -- 1575
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1575
		if _tab_0 then -- 1575
			local path -- 1575
			do -- 1575
				local _obj_0 = req.body -- 1575
				local _type_1 = type(_obj_0) -- 1575
				if "table" == _type_1 or "userdata" == _type_1 then -- 1575
					path = _obj_0.path -- 1575
				end -- 1575
			end -- 1575
			if path ~= nil then -- 1575
				if not Content:exist(path) then -- 1576
					return { -- 1577
						success = false, -- 1577
						message = "target not existed" -- 1577
					} -- 1577
				end -- 1576
				if Content:isdir(path) then -- 1578
					return { -- 1579
						success = false, -- 1579
						message = "failed to stat a directory" -- 1579
					} -- 1579
				end -- 1578
				local size, isBinary = Content:getAttr(path) -- 1580
				if size then -- 1580
					return { -- 1581
						success = true, -- 1581
						size = size, -- 1581
						isBinary = isBinary -- 1581
					} -- 1581
				end -- 1580
			end -- 1575
		end -- 1575
	end -- 1575
	return { -- 1574
		success = false, -- 1574
		message = "failed to stat" -- 1574
	} -- 1574
end) -- 1574
HttpServer:post("/new", function(req) -- 1583
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
			local content -- 1584
			do -- 1584
				local _obj_0 = req.body -- 1584
				local _type_1 = type(_obj_0) -- 1584
				if "table" == _type_1 or "userdata" == _type_1 then -- 1584
					content = _obj_0.content -- 1584
				end -- 1584
			end -- 1584
			local folder -- 1584
			do -- 1584
				local _obj_0 = req.body -- 1584
				local _type_1 = type(_obj_0) -- 1584
				if "table" == _type_1 or "userdata" == _type_1 then -- 1584
					folder = _obj_0.folder -- 1584
				end -- 1584
			end -- 1584
			if path ~= nil and content ~= nil and folder ~= nil then -- 1584
				if Content:exist(path) then -- 1585
					return { -- 1586
						success = false, -- 1586
						message = "TargetExisted" -- 1586
					} -- 1586
				end -- 1585
				local parent = Path:getPath(path) -- 1587
				local files = Content:getFiles(parent) -- 1588
				if folder then -- 1589
					local name = Path:getFilename(path):lower() -- 1590
					for _index_0 = 1, #files do -- 1591
						local file = files[_index_0] -- 1591
						if name == Path:getFilename(file):lower() then -- 1592
							return { -- 1593
								success = false, -- 1593
								message = "TargetExisted" -- 1593
							} -- 1593
						end -- 1592
					end -- 1591
					if Content:mkdir(path) then -- 1594
						return { -- 1595
							success = true -- 1595
						} -- 1595
					end -- 1594
				else -- 1597
					local name = Path:getName(path):lower() -- 1597
					for _index_0 = 1, #files do -- 1598
						local file = files[_index_0] -- 1598
						if name == Path:getName(file):lower() then -- 1599
							local ext = Path:getExt(file) -- 1600
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1601
								goto _continue_0 -- 1602
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1603
								goto _continue_0 -- 1604
							end -- 1601
							return { -- 1605
								success = false, -- 1605
								message = "SourceExisted" -- 1605
							} -- 1605
						end -- 1599
						::_continue_0:: -- 1599
					end -- 1598
					if Content:save(path, content) then -- 1606
						return { -- 1607
							success = true -- 1607
						} -- 1607
					end -- 1606
				end -- 1589
			end -- 1584
		end -- 1584
	end -- 1584
	return { -- 1583
		success = false, -- 1583
		message = "Failed" -- 1583
	} -- 1583
end) -- 1583
HttpServer:post("/delete", function(req) -- 1609
	do -- 1610
		local _type_0 = type(req) -- 1610
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1610
		if _tab_0 then -- 1610
			local path -- 1610
			do -- 1610
				local _obj_0 = req.body -- 1610
				local _type_1 = type(_obj_0) -- 1610
				if "table" == _type_1 or "userdata" == _type_1 then -- 1610
					path = _obj_0.path -- 1610
				end -- 1610
			end -- 1610
			if path ~= nil then -- 1610
				if Content:exist(path) then -- 1611
					local projectRoot -- 1612
					if Content:isdir(path) and isProjectRootDir(path) then -- 1612
						projectRoot = path -- 1612
					else -- 1612
						projectRoot = nil -- 1612
					end -- 1612
					local parent = Path:getPath(path) -- 1613
					local files = Content:getFiles(parent) -- 1614
					local name = Path:getName(path):lower() -- 1615
					local ext = Path:getExt(path) -- 1616
					for _index_0 = 1, #files do -- 1617
						local file = files[_index_0] -- 1617
						if name == Path:getName(file):lower() then -- 1618
							local _exp_0 = Path:getExt(file) -- 1619
							if "tl" == _exp_0 then -- 1619
								if ("vs" == ext) then -- 1619
									Content:remove(Path(parent, file)) -- 1620
								end -- 1619
							elseif "lua" == _exp_0 then -- 1621
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1621
									Content:remove(Path(parent, file)) -- 1622
								end -- 1621
							end -- 1619
						end -- 1618
					end -- 1617
					if Content:remove(path) then -- 1623
						if projectRoot then -- 1624
							AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1625
						end -- 1624
						return { -- 1626
							success = true -- 1626
						} -- 1626
					end -- 1623
				end -- 1611
			end -- 1610
		end -- 1610
	end -- 1610
	return { -- 1609
		success = false -- 1609
	} -- 1609
end) -- 1609
HttpServer:post("/rename", function(req) -- 1628
	do -- 1629
		local _type_0 = type(req) -- 1629
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1629
		if _tab_0 then -- 1629
			local old -- 1629
			do -- 1629
				local _obj_0 = req.body -- 1629
				local _type_1 = type(_obj_0) -- 1629
				if "table" == _type_1 or "userdata" == _type_1 then -- 1629
					old = _obj_0.old -- 1629
				end -- 1629
			end -- 1629
			local new -- 1629
			do -- 1629
				local _obj_0 = req.body -- 1629
				local _type_1 = type(_obj_0) -- 1629
				if "table" == _type_1 or "userdata" == _type_1 then -- 1629
					new = _obj_0.new -- 1629
				end -- 1629
			end -- 1629
			if old ~= nil and new ~= nil then -- 1629
				if Content:exist(old) and not Content:exist(new) then -- 1630
					local renamedDir = Content:isdir(old) -- 1631
					local parent = Path:getPath(new) -- 1632
					local files = Content:getFiles(parent) -- 1633
					if renamedDir then -- 1634
						local name = Path:getFilename(new):lower() -- 1635
						for _index_0 = 1, #files do -- 1636
							local file = files[_index_0] -- 1636
							if name == Path:getFilename(file):lower() then -- 1637
								return { -- 1638
									success = false -- 1638
								} -- 1638
							end -- 1637
						end -- 1636
					else -- 1640
						local name = Path:getName(new):lower() -- 1640
						local ext = Path:getExt(new) -- 1641
						for _index_0 = 1, #files do -- 1642
							local file = files[_index_0] -- 1642
							if name == Path:getName(file):lower() then -- 1643
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1644
									goto _continue_0 -- 1645
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1646
									goto _continue_0 -- 1647
								end -- 1644
								return { -- 1648
									success = false -- 1648
								} -- 1648
							end -- 1643
							::_continue_0:: -- 1643
						end -- 1642
					end -- 1634
					if Content:move(old, new) then -- 1649
						if renamedDir then -- 1650
							AgentSession.renameSessionsByProjectRoot(old, new) -- 1651
						end -- 1650
						local newParent = Path:getPath(new) -- 1652
						parent = Path:getPath(old) -- 1653
						files = Content:getFiles(parent) -- 1654
						local newName = Path:getName(new) -- 1655
						local oldName = Path:getName(old) -- 1656
						local name = oldName:lower() -- 1657
						local ext = Path:getExt(old) -- 1658
						for _index_0 = 1, #files do -- 1659
							local file = files[_index_0] -- 1659
							if name == Path:getName(file):lower() then -- 1660
								local _exp_0 = Path:getExt(file) -- 1661
								if "tl" == _exp_0 then -- 1661
									if ("vs" == ext) then -- 1661
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1662
									end -- 1661
								elseif "lua" == _exp_0 then -- 1663
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1663
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1664
									end -- 1663
								end -- 1661
							end -- 1660
						end -- 1659
						return { -- 1665
							success = true -- 1665
						} -- 1665
					end -- 1649
				end -- 1630
			end -- 1629
		end -- 1629
	end -- 1629
	return { -- 1628
		success = false -- 1628
	} -- 1628
end) -- 1628
HttpServer:post("/exist", function(req) -- 1667
	do -- 1668
		local _type_0 = type(req) -- 1668
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1668
		if _tab_0 then -- 1668
			local file -- 1668
			do -- 1668
				local _obj_0 = req.body -- 1668
				local _type_1 = type(_obj_0) -- 1668
				if "table" == _type_1 or "userdata" == _type_1 then -- 1668
					file = _obj_0.file -- 1668
				end -- 1668
			end -- 1668
			if file ~= nil then -- 1668
				do -- 1669
					local projFile = req.body.projFile -- 1669
					if projFile then -- 1669
						local projDir = getProjectDirFromFile(projFile) -- 1670
						if projDir then -- 1670
							local scriptDir = Path(projDir, "Script") -- 1671
							local searchPaths = Content.searchPaths -- 1672
							if Content:exist(scriptDir) then -- 1673
								Content:addSearchPath(scriptDir) -- 1673
							end -- 1673
							if Content:exist(projDir) then -- 1674
								Content:addSearchPath(projDir) -- 1674
							end -- 1674
							local _ <close> = setmetatable({ }, { -- 1675
								__close = function() -- 1675
									Content.searchPaths = searchPaths -- 1675
								end -- 1675
							}) -- 1675
							return { -- 1676
								success = Content:exist(file) -- 1676
							} -- 1676
						end -- 1670
					end -- 1669
				end -- 1669
				return { -- 1677
					success = Content:exist(file) -- 1677
				} -- 1677
			end -- 1668
		end -- 1668
	end -- 1668
	return { -- 1667
		success = false -- 1667
	} -- 1667
end) -- 1667
HttpServer:postSchedule("/read", function(req) -- 1679
	do -- 1680
		local _type_0 = type(req) -- 1680
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1680
		if _tab_0 then -- 1680
			local path -- 1680
			do -- 1680
				local _obj_0 = req.body -- 1680
				local _type_1 = type(_obj_0) -- 1680
				if "table" == _type_1 or "userdata" == _type_1 then -- 1680
					path = _obj_0.path -- 1680
				end -- 1680
			end -- 1680
			if path ~= nil then -- 1680
				local readFile -- 1681
				readFile = function() -- 1681
					if Content:exist(path) then -- 1682
						local content = Content:loadAsync(path) -- 1683
						if content then -- 1683
							return { -- 1684
								content = content, -- 1684
								success = true, -- 1684
								fullPath = Content:getFullPath(path) -- 1684
							} -- 1684
						end -- 1683
					end -- 1682
					return nil -- 1681
				end -- 1681
				do -- 1685
					local projFile = req.body.projFile -- 1685
					if projFile then -- 1685
						local projDir = getProjectDirFromFile(projFile) -- 1686
						if projDir then -- 1686
							local scriptDir = Path(projDir, "Script") -- 1687
							local searchPaths = Content.searchPaths -- 1688
							if Content:exist(scriptDir) then -- 1689
								Content:addSearchPath(scriptDir) -- 1689
							end -- 1689
							if Content:exist(projDir) then -- 1690
								Content:addSearchPath(projDir) -- 1690
							end -- 1690
							local _ <close> = setmetatable({ }, { -- 1691
								__close = function() -- 1691
									Content.searchPaths = searchPaths -- 1691
								end -- 1691
							}) -- 1691
							local result = readFile() -- 1692
							if result then -- 1692
								return result -- 1692
							end -- 1692
						end -- 1686
					end -- 1685
				end -- 1685
				local result = readFile() -- 1693
				if result then -- 1693
					return result -- 1693
				end -- 1693
			end -- 1680
		end -- 1680
	end -- 1680
	return { -- 1679
		success = false -- 1679
	} -- 1679
end) -- 1679
HttpServer:get("/read-sync", function(req) -- 1695
	do -- 1696
		local _type_0 = type(req) -- 1696
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1696
		if _tab_0 then -- 1696
			local params = req.params -- 1696
			if params ~= nil then -- 1696
				local path = params.path -- 1697
				local exts -- 1698
				if params.exts then -- 1698
					local _accum_0 = { } -- 1699
					local _len_0 = 1 -- 1699
					for ext in params.exts:gmatch("[^|]*") do -- 1699
						_accum_0[_len_0] = ext -- 1699
						_len_0 = _len_0 + 1 -- 1699
					end -- 1699
					exts = _accum_0 -- 1699
				else -- 1700
					exts = { -- 1700
						"" -- 1700
					} -- 1700
				end -- 1698
				local readFileAt -- 1701
				readFileAt = function(targetPath) -- 1701
					if Content:exist(targetPath) then -- 1702
						local content = Content:load(targetPath) -- 1703
						if content then -- 1703
							return { -- 1704
								content = content, -- 1704
								success = true, -- 1704
								fullPath = Content:getFullPath(targetPath) -- 1704
							} -- 1704
						end -- 1703
					end -- 1702
					return nil -- 1701
				end -- 1701
				local readFile -- 1705
				readFile = function(fallbackPaths) -- 1705
					for _index_0 = 1, #exts do -- 1706
						local ext = exts[_index_0] -- 1706
						local targetPath = path .. ext -- 1707
						if not Content:isAbsolutePath(targetPath) then -- 1708
							for _index_1 = 1, #fallbackPaths do -- 1709
								local fallback = fallbackPaths[_index_1] -- 1709
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1710
								if fallbackResult then -- 1710
									return fallbackResult -- 1711
								end -- 1710
							end -- 1709
						end -- 1708
						local fileResult = readFileAt(targetPath) -- 1712
						if fileResult then -- 1712
							return fileResult -- 1713
						end -- 1712
					end -- 1706
					return nil -- 1705
				end -- 1705
				local fallbackPaths = { } -- 1714
				local fallbackCandidates = { } -- 1715
				do -- 1716
					local projectRoot = req.params.projectRoot -- 1716
					if projectRoot then -- 1716
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1717
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1718
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1719
						end -- 1717
					end -- 1716
				end -- 1716
				do -- 1720
					local projFile = req.params.projFile -- 1720
					if projFile then -- 1720
						local projDir = getProjectDirFromFile(projFile) -- 1721
						if projDir then -- 1721
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1722
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1723
						else -- 1725
							projDir = Path:getPath(projFile) -- 1725
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1726
						end -- 1721
					end -- 1720
				end -- 1720
				for _index_0 = 1, #fallbackCandidates do -- 1727
					local dir = fallbackCandidates[_index_0] -- 1727
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1728
						local exists = false -- 1729
						for _index_1 = 1, #fallbackPaths do -- 1730
							local fallback = fallbackPaths[_index_1] -- 1730
							if fallback == dir then -- 1731
								exists = true -- 1732
								break -- 1733
							end -- 1731
						end -- 1730
						if not exists then -- 1734
							fallbackPaths[#fallbackPaths + 1] = dir -- 1734
						end -- 1734
					end -- 1728
				end -- 1727
				local readResult = readFile(fallbackPaths) -- 1735
				if readResult then -- 1735
					return readResult -- 1736
				end -- 1735
			end -- 1696
		end -- 1696
	end -- 1696
	return { -- 1695
		success = false -- 1695
	} -- 1695
end) -- 1695
local compileFileAsync -- 1738
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1738
	if projectRoot == nil then -- 1738
		projectRoot = nil -- 1738
	end -- 1738
	local file = inputFile -- 1739
	local searchPath -- 1740
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1740
		file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1741
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1745
	elseif not Content:isAbsolutePath(inputFile) then -- 1746
		searchPath = "" -- 1747
	else -- 1748
		local dir = getProjectDirFromFile(inputFile) -- 1748
		if dir then -- 1748
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, dir) or inputFile -- 1749
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1753
		else -- 1755
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1755
			searchPath = "" -- 1758
		end -- 1748
	end -- 1740
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1759
	local yueext = yue.options.extension -- 1760
	local resultCodes = nil -- 1761
	local resultError = nil -- 1762
	do -- 1763
		local _exp_0 = Path:getExt(inputFile) -- 1763
		if yueext == _exp_0 then -- 1763
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1764
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1765
				if not codes then -- 1766
					resultError = err -- 1767
					return -- 1768
				end -- 1766
				local extraGlobal -- 1769
				if isTIC80 then -- 1769
					extraGlobal = tic80APIs -- 1769
				else -- 1769
					extraGlobal = nil -- 1769
				end -- 1769
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1770
				if not success then -- 1771
					resultError = message -- 1772
					return -- 1773
				end -- 1771
				if codes == "" then -- 1774
					resultCodes = "" -- 1775
					return nil -- 1776
				end -- 1774
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1777
				return resultCodes -- 1778
			end, function(success) -- 1765
				if not success then -- 1779
					Content:remove(outputFile) -- 1780
					if resultCodes == nil then -- 1781
						resultCodes = false -- 1782
					end -- 1781
				end -- 1779
			end) -- 1765
		elseif "tl" == _exp_0 then -- 1783
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1784
			if isTIC80 then -- 1785
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1786
			end -- 1785
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1787
			if codes then -- 1787
				if isTIC80 then -- 1788
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1789
				end -- 1788
				resultCodes = codes -- 1790
				Content:saveAsync(outputFile, codes) -- 1791
			else -- 1793
				Content:remove(outputFile) -- 1793
				resultCodes = false -- 1794
				resultError = err -- 1795
			end -- 1787
		elseif "xml" == _exp_0 then -- 1796
			local codes, err = xml.tolua(sourceCodes) -- 1797
			if codes then -- 1797
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1798
				Content:saveAsync(outputFile, resultCodes) -- 1799
			else -- 1801
				Content:remove(outputFile) -- 1801
				resultCodes = false -- 1802
				resultError = err -- 1803
			end -- 1797
		end -- 1763
	end -- 1763
	wait(function() -- 1804
		return resultCodes ~= nil -- 1804
	end) -- 1804
	if resultCodes then -- 1805
		return resultCodes -- 1806
	else -- 1808
		return nil, resultError -- 1808
	end -- 1805
	return nil -- 1738
end -- 1738
HttpServer:postSchedule("/write", function(req) -- 1810
	do -- 1811
		local _type_0 = type(req) -- 1811
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1811
		if _tab_0 then -- 1811
			local path -- 1811
			do -- 1811
				local _obj_0 = req.body -- 1811
				local _type_1 = type(_obj_0) -- 1811
				if "table" == _type_1 or "userdata" == _type_1 then -- 1811
					path = _obj_0.path -- 1811
				end -- 1811
			end -- 1811
			local content -- 1811
			do -- 1811
				local _obj_0 = req.body -- 1811
				local _type_1 = type(_obj_0) -- 1811
				if "table" == _type_1 or "userdata" == _type_1 then -- 1811
					content = _obj_0.content -- 1811
				end -- 1811
			end -- 1811
			if path ~= nil and content ~= nil then -- 1811
				if Content:saveAsync(path, content) then -- 1812
					do -- 1813
						local _exp_0 = Path:getExt(path) -- 1813
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1813
							if '' == Path:getExt(Path:getName(path)) then -- 1814
								local resultCodes = compileFileAsync(path, content) -- 1815
								return { -- 1816
									success = true, -- 1816
									resultCodes = resultCodes -- 1816
								} -- 1816
							end -- 1814
						end -- 1813
					end -- 1813
					return { -- 1817
						success = true -- 1817
					} -- 1817
				end -- 1812
			end -- 1811
		end -- 1811
	end -- 1811
	return { -- 1810
		success = false -- 1810
	} -- 1810
end) -- 1810
local getWaProjectDirFromFile = nil -- 1819
HttpServer:postSchedule("/build", function(req) -- 1821
	do -- 1822
		local _type_0 = type(req) -- 1822
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1822
		if _tab_0 then -- 1822
			local path -- 1822
			do -- 1822
				local _obj_0 = req.body -- 1822
				local _type_1 = type(_obj_0) -- 1822
				if "table" == _type_1 or "userdata" == _type_1 then -- 1822
					path = _obj_0.path -- 1822
				end -- 1822
			end -- 1822
			if path ~= nil then -- 1822
				local projectRoot = req.body.projectRoot -- 1823
				if Content:isdir(path) then -- 1824
					local projDir = getWaProjectDirFromFile(path) -- 1825
					if projDir then -- 1825
						local message = Wasm:buildWaAsync(projDir) -- 1826
						if message == "" then -- 1827
							return { -- 1828
								success = true -- 1828
							} -- 1828
						else -- 1830
							return { -- 1830
								success = false, -- 1830
								message = message -- 1830
							} -- 1830
						end -- 1827
					end -- 1825
				end -- 1824
				local _exp_0 = Path:getExt(path) -- 1831
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1832
					if '' == Path:getExt(Path:getName(path)) then -- 1833
						local content = Content:loadAsync(path) -- 1834
						if content then -- 1834
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 1835
							if resultCodes then -- 1835
								return { -- 1836
									success = true, -- 1836
									resultCodes = resultCodes -- 1836
								} -- 1836
							end -- 1835
						end -- 1834
					end -- 1833
				elseif "wa" == _exp_0 then -- 1837
					local projDir = getWaProjectDirFromFile(path) -- 1838
					if projDir then -- 1838
						local message = Wasm:buildWaAsync(projDir) -- 1839
						if message == "" then -- 1840
							return { -- 1841
								success = true -- 1841
							} -- 1841
						else -- 1843
							return { -- 1843
								success = false, -- 1843
								message = message -- 1843
							} -- 1843
						end -- 1840
					else -- 1845
						return { -- 1845
							success = false, -- 1845
							message = 'Wa file needs a project' -- 1845
						} -- 1845
					end -- 1838
				end -- 1831
			end -- 1822
		end -- 1822
	end -- 1822
	return { -- 1821
		success = false -- 1821
	} -- 1821
end) -- 1821
local extentionLevels = { -- 1848
	vs = 2, -- 1848
	bl = 2, -- 1849
	ts = 1, -- 1850
	tsx = 1, -- 1851
	tl = 1, -- 1852
	yue = 1, -- 1853
	xml = 1, -- 1854
	lua = 0 -- 1855
} -- 1847
HttpServer:post("/assets", function() -- 1857
	local Entry = require("Script.Dev.Entry") -- 1860
	local engineDev = Entry.getEngineDev() -- 1861
	local visitAssets -- 1862
	visitAssets = function(path, tag) -- 1862
		local isWorkspace = tag == "Workspace" -- 1863
		local builtin -- 1864
		if tag == "Builtin" then -- 1864
			builtin = true -- 1864
		else -- 1864
			builtin = nil -- 1864
		end -- 1864
		local children = nil -- 1865
		local dirs = Content:getDirs(path) -- 1866
		for _index_0 = 1, #dirs do -- 1867
			local dir = dirs[_index_0] -- 1867
			if isWorkspace then -- 1868
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1869
					goto _continue_0 -- 1870
				end -- 1869
			elseif dir == ".git" then -- 1871
				goto _continue_0 -- 1872
			end -- 1868
			if not children then -- 1873
				children = { } -- 1873
			end -- 1873
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1874
			::_continue_0:: -- 1868
		end -- 1867
		local files = Content:getFiles(path) -- 1875
		local names = { } -- 1876
		for _index_0 = 1, #files do -- 1877
			local file = files[_index_0] -- 1877
			if (".DS_Store" == file) then -- 1878
				goto _continue_1 -- 1879
			end -- 1878
			local name = Path:getName(file) -- 1880
			local ext = names[name] -- 1881
			if ext then -- 1881
				local lv1 -- 1882
				do -- 1882
					local _exp_0 = extentionLevels[ext] -- 1882
					if _exp_0 ~= nil then -- 1882
						lv1 = _exp_0 -- 1882
					else -- 1882
						lv1 = -1 -- 1882
					end -- 1882
				end -- 1882
				ext = Path:getExt(file) -- 1883
				local lv2 -- 1884
				do -- 1884
					local _exp_0 = extentionLevels[ext] -- 1884
					if _exp_0 ~= nil then -- 1884
						lv2 = _exp_0 -- 1884
					else -- 1884
						lv2 = -1 -- 1884
					end -- 1884
				end -- 1884
				if lv2 > lv1 then -- 1885
					names[name] = ext -- 1886
				elseif lv2 == lv1 then -- 1887
					names[name .. '.' .. ext] = "" -- 1888
				end -- 1885
			else -- 1890
				ext = Path:getExt(file) -- 1890
				if not extentionLevels[ext] then -- 1891
					names[file] = "" -- 1892
				else -- 1894
					names[name] = ext -- 1894
				end -- 1891
			end -- 1881
			::_continue_1:: -- 1878
		end -- 1877
		do -- 1895
			local _accum_0 = { } -- 1895
			local _len_0 = 1 -- 1895
			for name, ext in pairs(names) do -- 1895
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1895
				_len_0 = _len_0 + 1 -- 1895
			end -- 1895
			files = _accum_0 -- 1895
		end -- 1895
		for _index_0 = 1, #files do -- 1896
			local file = files[_index_0] -- 1896
			if not children then -- 1897
				children = { } -- 1897
			end -- 1897
			children[#children + 1] = { -- 1899
				key = Path(path, file), -- 1899
				dir = false, -- 1900
				title = file, -- 1901
				builtin = builtin -- 1902
			} -- 1898
		end -- 1896
		if children then -- 1904
			table.sort(children, function(a, b) -- 1905
				if a.dir == b.dir then -- 1906
					return a.title < b.title -- 1907
				else -- 1909
					return a.dir -- 1909
				end -- 1906
			end) -- 1905
		end -- 1904
		if isWorkspace and children then -- 1910
			return children -- 1911
		else -- 1913
			return { -- 1914
				key = path, -- 1914
				dir = true, -- 1915
				title = Path:getFilename(path), -- 1916
				builtin = builtin, -- 1917
				children = children -- 1918
			} -- 1913
		end -- 1910
	end -- 1862
	local zh = (App.locale:match("^zh") ~= nil) -- 1920
	return { -- 1922
		key = Content.writablePath, -- 1922
		dir = true, -- 1923
		root = true, -- 1924
		title = "Assets", -- 1925
		children = (function() -- 1927
			local _tab_0 = { -- 1927
				{ -- 1928
					key = Path(Content.assetPath), -- 1928
					dir = true, -- 1929
					builtin = true, -- 1930
					title = zh and "内置资源" or "Built-in", -- 1931
					children = { -- 1933
						(function() -- 1933
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1933
							_with_0.title = zh and "说明文档" or "Readme" -- 1934
							return _with_0 -- 1933
						end)(), -- 1933
						(function() -- 1935
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1935
							_with_0.title = zh and "接口文档" or "API Doc" -- 1936
							return _with_0 -- 1935
						end)(), -- 1935
						(function() -- 1937
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1937
							_with_0.title = zh and "开发工具" or "Tools" -- 1938
							return _with_0 -- 1937
						end)(), -- 1937
						(function() -- 1939
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1939
							_with_0.title = zh and "字体" or "Font" -- 1940
							return _with_0 -- 1939
						end)(), -- 1939
						(function() -- 1941
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1941
							_with_0.title = zh and "程序库" or "Lib" -- 1942
							if engineDev then -- 1943
								local _list_0 = _with_0.children -- 1944
								for _index_0 = 1, #_list_0 do -- 1944
									local child = _list_0[_index_0] -- 1944
									if not (child.title == "Dora") then -- 1945
										goto _continue_0 -- 1945
									end -- 1945
									local title = zh and "zh-Hans" or "en" -- 1946
									do -- 1947
										local _accum_0 = { } -- 1947
										local _len_0 = 1 -- 1947
										local _list_1 = child.children -- 1947
										for _index_1 = 1, #_list_1 do -- 1947
											local c = _list_1[_index_1] -- 1947
											if c.title ~= title then -- 1947
												_accum_0[_len_0] = c -- 1947
												_len_0 = _len_0 + 1 -- 1947
											end -- 1947
										end -- 1947
										child.children = _accum_0 -- 1947
									end -- 1947
									break -- 1948
									::_continue_0:: -- 1945
								end -- 1944
							else -- 1950
								local _accum_0 = { } -- 1950
								local _len_0 = 1 -- 1950
								local _list_0 = _with_0.children -- 1950
								for _index_0 = 1, #_list_0 do -- 1950
									local child = _list_0[_index_0] -- 1950
									if child.title ~= "Dora" then -- 1950
										_accum_0[_len_0] = child -- 1950
										_len_0 = _len_0 + 1 -- 1950
									end -- 1950
								end -- 1950
								_with_0.children = _accum_0 -- 1950
							end -- 1943
							return _with_0 -- 1941
						end)(), -- 1941
						(function() -- 1951
							if engineDev then -- 1951
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1952
								local _obj_0 = _with_0.children -- 1953
								_obj_0[#_obj_0 + 1] = { -- 1954
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1954
									dir = false, -- 1955
									builtin = true, -- 1956
									title = "init.yue" -- 1957
								} -- 1953
								return _with_0 -- 1952
							end -- 1951
						end)() -- 1951
					} -- 1932
				} -- 1927
			} -- 1961
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1961
			local _idx_0 = #_tab_0 + 1 -- 1961
			for _index_0 = 1, #_obj_0 do -- 1961
				local _value_0 = _obj_0[_index_0] -- 1961
				_tab_0[_idx_0] = _value_0 -- 1961
				_idx_0 = _idx_0 + 1 -- 1961
			end -- 1961
			return _tab_0 -- 1927
		end)() -- 1926
	} -- 1921
end) -- 1857
HttpServer:post("/entry/list", function() -- 1965
	local Entry = require("Script.Dev.Entry") -- 1966
	local res = Entry.getLaunchEntries() -- 1967
	res.success = true -- 1968
	return res -- 1969
end) -- 1965
HttpServer:post("/run/status", function() -- 1971
	local Entry = require("Script.Dev.Entry") -- 1972
	return Entry.getCurrentEntryStatus() -- 1973
end) -- 1971
HttpServer:postSchedule("/run", function(req) -- 1975
	do -- 1976
		local _type_0 = type(req) -- 1976
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1976
		if _tab_0 then -- 1976
			local file -- 1976
			do -- 1976
				local _obj_0 = req.body -- 1976
				local _type_1 = type(_obj_0) -- 1976
				if "table" == _type_1 or "userdata" == _type_1 then -- 1976
					file = _obj_0.file -- 1976
				end -- 1976
			end -- 1976
			local asProj -- 1976
			do -- 1976
				local _obj_0 = req.body -- 1976
				local _type_1 = type(_obj_0) -- 1976
				if "table" == _type_1 or "userdata" == _type_1 then -- 1976
					asProj = _obj_0.asProj -- 1976
				end -- 1976
			end -- 1976
			if file ~= nil and asProj ~= nil then -- 1976
				if not Content:isAbsolutePath(file) then -- 1977
					local devFile = Path(Content.writablePath, file) -- 1978
					if Content:exist(devFile) then -- 1979
						file = devFile -- 1979
					end -- 1979
				end -- 1977
				local Entry = require("Script.Dev.Entry") -- 1980
				local workDir -- 1981
				if asProj then -- 1982
					local projectRoot = req.body.projectRoot -- 1983
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1984
						workDir = projectRoot -- 1985
					else -- 1987
						workDir = getProjectDirFromFile(file) -- 1987
					end -- 1984
					if workDir then -- 1988
						Entry.allClear() -- 1989
						local target = Path(workDir, "init") -- 1990
						local success, err = Entry.enterEntryAsync({ -- 1991
							entryName = "Project", -- 1991
							fileName = target, -- 1991
							workDir = workDir, -- 1991
							projectRoot = workDir, -- 1991
							runKind = "project" -- 1991
						}) -- 1991
						target = Path:getName(Path:getPath(target)) -- 1992
						return { -- 1993
							success = success, -- 1993
							target = target, -- 1993
							err = err -- 1993
						} -- 1993
					end -- 1988
				else -- 1995
					workDir = getProjectDirFromFile(file) -- 1995
					if not workDir and Path:getExt(file) == "wasm" then -- 1996
						local parent = Path:getPath(file) -- 1997
						if Content:exist(Path(parent, "wa.mod")) then -- 1998
							workDir = parent -- 1999
						end -- 1998
					end -- 1996
				end -- 1982
				Entry.allClear() -- 2000
				file = Path:replaceExt(file, "") -- 2001
				local entry = { -- 2003
					entryName = Path:getName(file), -- 2003
					fileName = file, -- 2004
					runKind = "file" -- 2005
				} -- 2002
				if workDir then -- 2006
					entry.workDir = workDir -- 2007
					entry.projectRoot = workDir -- 2008
				end -- 2006
				local success, err = Entry.enterEntryAsync(entry) -- 2009
				return { -- 2010
					success = success, -- 2010
					err = err -- 2010
				} -- 2010
			end -- 1976
		end -- 1976
	end -- 1976
	return { -- 1975
		success = false -- 1975
	} -- 1975
end) -- 1975
HttpServer:postSchedule("/stop", function() -- 2012
	local Entry = require("Script.Dev.Entry") -- 2013
	return { -- 2014
		success = Entry.stop() -- 2014
	} -- 2014
end) -- 2012
local minifyAsync -- 2016
minifyAsync = function(sourcePath, minifyPath) -- 2016
	if not Content:exist(sourcePath) then -- 2017
		return -- 2017
	end -- 2017
	local Entry = require("Script.Dev.Entry") -- 2018
	local errors = { } -- 2019
	local files = Entry.getAllFiles(sourcePath, { -- 2020
		"lua" -- 2020
	}, true) -- 2020
	do -- 2021
		local _accum_0 = { } -- 2021
		local _len_0 = 1 -- 2021
		for _index_0 = 1, #files do -- 2021
			local file = files[_index_0] -- 2021
			if file:sub(1, 1) ~= '.' then -- 2021
				_accum_0[_len_0] = file -- 2021
				_len_0 = _len_0 + 1 -- 2021
			end -- 2021
		end -- 2021
		files = _accum_0 -- 2021
	end -- 2021
	local paths -- 2022
	do -- 2022
		local _tbl_0 = { } -- 2022
		for _index_0 = 1, #files do -- 2022
			local file = files[_index_0] -- 2022
			_tbl_0[Path:getPath(file)] = true -- 2022
		end -- 2022
		paths = _tbl_0 -- 2022
	end -- 2022
	for path in pairs(paths) do -- 2023
		Content:mkdir(Path(minifyPath, path)) -- 2023
	end -- 2023
	local _ <close> = setmetatable({ }, { -- 2024
		__close = function() -- 2024
			package.loaded["luaminify.FormatMini"] = nil -- 2025
			package.loaded["luaminify.ParseLua"] = nil -- 2026
			package.loaded["luaminify.Scope"] = nil -- 2027
			package.loaded["luaminify.Util"] = nil -- 2028
		end -- 2024
	}) -- 2024
	local FormatMini -- 2029
	do -- 2029
		local _obj_0 = require("luaminify") -- 2029
		FormatMini = _obj_0.FormatMini -- 2029
	end -- 2029
	local fileCount = #files -- 2030
	local count = 0 -- 2031
	for _index_0 = 1, #files do -- 2032
		local file = files[_index_0] -- 2032
		thread(function() -- 2033
			local _ <close> = setmetatable({ }, { -- 2034
				__close = function() -- 2034
					count = count + 1 -- 2034
				end -- 2034
			}) -- 2034
			local input = Path(sourcePath, file) -- 2035
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2036
			if Content:exist(input) then -- 2037
				local sourceCodes = Content:loadAsync(input) -- 2038
				local res, err = FormatMini(sourceCodes) -- 2039
				if res then -- 2040
					Content:saveAsync(output, res) -- 2041
					return print("Minify " .. tostring(file)) -- 2042
				else -- 2044
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2044
				end -- 2040
			else -- 2046
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2046
			end -- 2037
		end) -- 2033
		sleep() -- 2047
	end -- 2032
	wait(function() -- 2048
		return count == fileCount -- 2048
	end) -- 2048
	if #errors > 0 then -- 2049
		print(table.concat(errors, '\n')) -- 2050
	end -- 2049
	print("Obfuscation done.") -- 2051
	return files -- 2052
end -- 2016
local zipping = false -- 2054
HttpServer:postSchedule("/zip", function(req) -- 2056
	do -- 2057
		local _type_0 = type(req) -- 2057
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2057
		if _tab_0 then -- 2057
			local path -- 2057
			do -- 2057
				local _obj_0 = req.body -- 2057
				local _type_1 = type(_obj_0) -- 2057
				if "table" == _type_1 or "userdata" == _type_1 then -- 2057
					path = _obj_0.path -- 2057
				end -- 2057
			end -- 2057
			local zipFile -- 2057
			do -- 2057
				local _obj_0 = req.body -- 2057
				local _type_1 = type(_obj_0) -- 2057
				if "table" == _type_1 or "userdata" == _type_1 then -- 2057
					zipFile = _obj_0.zipFile -- 2057
				end -- 2057
			end -- 2057
			local obfuscated -- 2057
			do -- 2057
				local _obj_0 = req.body -- 2057
				local _type_1 = type(_obj_0) -- 2057
				if "table" == _type_1 or "userdata" == _type_1 then -- 2057
					obfuscated = _obj_0.obfuscated -- 2057
				end -- 2057
			end -- 2057
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2057
				if zipping then -- 2058
					goto failed -- 2058
				end -- 2058
				zipping = true -- 2059
				local _ <close> = setmetatable({ }, { -- 2060
					__close = function() -- 2060
						zipping = false -- 2060
					end -- 2060
				}) -- 2060
				if not Content:exist(path) then -- 2061
					goto failed -- 2061
				end -- 2061
				Content:mkdir(Path:getPath(zipFile)) -- 2062
				if obfuscated then -- 2063
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2064
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2065
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2066
					Content:remove(scriptPath) -- 2067
					Content:remove(obfuscatedPath) -- 2068
					Content:remove(tempPath) -- 2069
					Content:mkdir(scriptPath) -- 2070
					Content:mkdir(obfuscatedPath) -- 2071
					Content:mkdir(tempPath) -- 2072
					if not Content:copyAsync(path, tempPath) then -- 2073
						goto failed -- 2073
					end -- 2073
					local Entry = require("Script.Dev.Entry") -- 2074
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2075
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2076
						"tl", -- 2076
						"yue", -- 2076
						"lua", -- 2076
						"ts", -- 2076
						"tsx", -- 2076
						"vs", -- 2076
						"bl", -- 2076
						"xml", -- 2076
						"wa", -- 2076
						"mod" -- 2076
					}, true) -- 2076
					for _index_0 = 1, #scriptFiles do -- 2077
						local file = scriptFiles[_index_0] -- 2077
						Content:remove(Path(tempPath, file)) -- 2078
					end -- 2077
					for _index_0 = 1, #luaFiles do -- 2079
						local file = luaFiles[_index_0] -- 2079
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2080
					end -- 2079
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2081
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2082
					end) then -- 2081
						goto failed -- 2081
					end -- 2081
					return { -- 2083
						success = true -- 2083
					} -- 2083
				else -- 2085
					return { -- 2085
						success = Content:zipAsync(path, zipFile, function(file) -- 2085
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2086
						end) -- 2085
					} -- 2085
				end -- 2063
			end -- 2057
		end -- 2057
	end -- 2057
	::failed:: -- 2087
	return { -- 2056
		success = false -- 2056
	} -- 2056
end) -- 2056
HttpServer:postSchedule("/unzip", function(req) -- 2089
	do -- 2090
		local _type_0 = type(req) -- 2090
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2090
		if _tab_0 then -- 2090
			local zipFile -- 2090
			do -- 2090
				local _obj_0 = req.body -- 2090
				local _type_1 = type(_obj_0) -- 2090
				if "table" == _type_1 or "userdata" == _type_1 then -- 2090
					zipFile = _obj_0.zipFile -- 2090
				end -- 2090
			end -- 2090
			local path -- 2090
			do -- 2090
				local _obj_0 = req.body -- 2090
				local _type_1 = type(_obj_0) -- 2090
				if "table" == _type_1 or "userdata" == _type_1 then -- 2090
					path = _obj_0.path -- 2090
				end -- 2090
			end -- 2090
			if zipFile ~= nil and path ~= nil then -- 2090
				return { -- 2091
					success = Content:unzipAsync(zipFile, path, function(file) -- 2091
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2092
					end) -- 2091
				} -- 2091
			end -- 2090
		end -- 2090
	end -- 2090
	return { -- 2089
		success = false -- 2089
	} -- 2089
end) -- 2089
HttpServer:post("/editing-info", function(req) -- 2094
	local Entry = require("Script.Dev.Entry") -- 2095
	local config = Entry.getConfig() -- 2096
	local _type_0 = type(req) -- 2097
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2097
	local _match_0 = false -- 2097
	if _tab_0 then -- 2097
		local editingInfo -- 2097
		do -- 2097
			local _obj_0 = req.body -- 2097
			local _type_1 = type(_obj_0) -- 2097
			if "table" == _type_1 or "userdata" == _type_1 then -- 2097
				editingInfo = _obj_0.editingInfo -- 2097
			end -- 2097
		end -- 2097
		if editingInfo ~= nil then -- 2097
			_match_0 = true -- 2097
			config.editingInfo = editingInfo -- 2098
			return { -- 2099
				success = true -- 2099
			} -- 2099
		end -- 2097
	end -- 2097
	if not _match_0 then -- 2097
		if not (config.editingInfo ~= nil) then -- 2101
			local folder -- 2102
			if App.locale:match('^zh') then -- 2102
				folder = 'zh-Hans' -- 2102
			else -- 2102
				folder = 'en' -- 2102
			end -- 2102
			config.editingInfo = json.encode({ -- 2104
				index = 0, -- 2104
				files = { -- 2106
					{ -- 2107
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2107
						title = "welcome.md" -- 2108
					} -- 2106
				} -- 2105
			}) -- 2103
		end -- 2101
		return { -- 2112
			success = true, -- 2112
			editingInfo = config.editingInfo -- 2112
		} -- 2112
	end -- 2097
end) -- 2094
HttpServer:post("/command", function(req) -- 2114
	do -- 2115
		local _type_0 = type(req) -- 2115
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2115
		if _tab_0 then -- 2115
			local code -- 2115
			do -- 2115
				local _obj_0 = req.body -- 2115
				local _type_1 = type(_obj_0) -- 2115
				if "table" == _type_1 or "userdata" == _type_1 then -- 2115
					code = _obj_0.code -- 2115
				end -- 2115
			end -- 2115
			local log -- 2115
			do -- 2115
				local _obj_0 = req.body -- 2115
				local _type_1 = type(_obj_0) -- 2115
				if "table" == _type_1 or "userdata" == _type_1 then -- 2115
					log = _obj_0.log -- 2115
				end -- 2115
			end -- 2115
			if code ~= nil and log ~= nil then -- 2115
				emit("AppCommand", code, log) -- 2116
				return { -- 2117
					success = true -- 2117
				} -- 2117
			end -- 2115
		end -- 2115
	end -- 2115
	return { -- 2114
		success = false -- 2114
	} -- 2114
end) -- 2114
HttpServer:post("/log/save", function() -- 2119
	local folder = ".download" -- 2120
	local fullLogFile = "dora_full_logs.txt" -- 2121
	local fullFolder = Path(Content.writablePath, folder) -- 2122
	Content:mkdir(fullFolder) -- 2123
	local logPath = Path(fullFolder, fullLogFile) -- 2124
	if App:saveLog(logPath) then -- 2125
		return { -- 2126
			success = true, -- 2126
			path = Path(folder, fullLogFile) -- 2126
		} -- 2126
	end -- 2125
	return { -- 2119
		success = false -- 2119
	} -- 2119
end) -- 2119
local tailLines -- 2128
tailLines = function(text, count) -- 2128
	local lines = { } -- 2129
	text = text:gsub("\r\n", "\n") -- 2130
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2131
		lines[#lines + 1] = line -- 2132
	end -- 2131
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2133
		table.remove(lines) -- 2134
	end -- 2133
	local start = math.max(1, #lines - count + 1) -- 2135
	local out = { } -- 2136
	for i = start, #lines do -- 2137
		out[#out + 1] = lines[i] -- 2138
	end -- 2137
	return table.concat(out, "\n") -- 2139
end -- 2128
HttpServer:post("/log", function(req) -- 2141
	local count = 100 -- 2142
	if req and req.body and req.body.count ~= nil then -- 2143
		count = req.body.count -- 2144
	end -- 2143
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2145
		return { -- 2146
			success = false, -- 2146
			message = "count must be a positive integer" -- 2146
		} -- 2146
	end -- 2145
	local folder = ".download" -- 2147
	local fullLogFile = "dora_full_logs.txt" -- 2148
	local fullFolder = Path(Content.writablePath, folder) -- 2149
	Content:mkdir(fullFolder) -- 2150
	local logPath = Path(fullFolder, fullLogFile) -- 2151
	if App:saveLog(logPath) then -- 2152
		local text = Content:load(logPath) -- 2153
		if text then -- 2154
			return { -- 2155
				success = true, -- 2155
				log = tailLines(text, count) -- 2155
			} -- 2155
		else -- 2157
			return { -- 2157
				success = false, -- 2157
				message = "failed to read log" -- 2157
			} -- 2157
		end -- 2154
	else -- 2159
		return { -- 2159
			success = false, -- 2159
			message = "failed to save log" -- 2159
		} -- 2159
	end -- 2152
	return { -- 2141
		success = false -- 2141
	} -- 2141
end) -- 2141
HttpServer:post("/yarn/check", function(req) -- 2161
	local yarncompile = require("yarncompile") -- 2162
	do -- 2163
		local _type_0 = type(req) -- 2163
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2163
		if _tab_0 then -- 2163
			local code -- 2163
			do -- 2163
				local _obj_0 = req.body -- 2163
				local _type_1 = type(_obj_0) -- 2163
				if "table" == _type_1 or "userdata" == _type_1 then -- 2163
					code = _obj_0.code -- 2163
				end -- 2163
			end -- 2163
			if code ~= nil then -- 2163
				local jsonObject = json.decode(code) -- 2164
				if jsonObject then -- 2164
					local errors = { } -- 2165
					local _list_0 = jsonObject.nodes -- 2166
					for _index_0 = 1, #_list_0 do -- 2166
						local node = _list_0[_index_0] -- 2166
						local title, body = node.title, node.body -- 2167
						local luaCode, err = yarncompile(body) -- 2168
						if not luaCode then -- 2168
							errors[#errors + 1] = title .. ":" .. err -- 2169
						end -- 2168
					end -- 2166
					return { -- 2170
						success = true, -- 2170
						syntaxError = table.concat(errors, "\n\n") -- 2170
					} -- 2170
				end -- 2164
			end -- 2163
		end -- 2163
	end -- 2163
	return { -- 2161
		success = false -- 2161
	} -- 2161
end) -- 2161
HttpServer:post("/yarn/check-file", function(req) -- 2172
	local yarncompile = require("yarncompile") -- 2173
	do -- 2174
		local _type_0 = type(req) -- 2174
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2174
		if _tab_0 then -- 2174
			local code -- 2174
			do -- 2174
				local _obj_0 = req.body -- 2174
				local _type_1 = type(_obj_0) -- 2174
				if "table" == _type_1 or "userdata" == _type_1 then -- 2174
					code = _obj_0.code -- 2174
				end -- 2174
			end -- 2174
			if code ~= nil then -- 2174
				local res, _, err = yarncompile(code, true) -- 2175
				if not res then -- 2175
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2176
					return { -- 2177
						success = false, -- 2177
						message = message, -- 2177
						line = line, -- 2177
						column = column, -- 2177
						node = node -- 2177
					} -- 2177
				end -- 2175
			end -- 2174
		end -- 2174
	end -- 2174
	return { -- 2172
		success = true -- 2172
	} -- 2172
end) -- 2172
getWaProjectDirFromFile = function(file) -- 2179
	local current -- 2180
	if Content:isdir(file) then -- 2180
		current = file -- 2180
	else -- 2180
		current = Path:getPath(file) -- 2180
	end -- 2180
	if current == "" then -- 2181
		return nil -- 2181
	end -- 2181
	repeat -- 2182
		local modPath = Path(current, "wa.mod") -- 2183
		if Content:exist(modPath) then -- 2184
			return current, modPath -- 2185
		end -- 2184
		local parent = Path:getPath(current) -- 2186
		if parent == "" or parent == current then -- 2187
			break -- 2187
		end -- 2187
		current = parent -- 2188
	until false -- 2182
	return nil -- 2190
end -- 2179
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2192
	do -- 2193
		local _type_0 = type(req) -- 2193
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2193
		if _tab_0 then -- 2193
			local path -- 2193
			do -- 2193
				local _obj_0 = req.body -- 2193
				local _type_1 = type(_obj_0) -- 2193
				if "table" == _type_1 or "userdata" == _type_1 then -- 2193
					path = _obj_0.path -- 2193
				end -- 2193
			end -- 2193
			if path ~= nil then -- 2193
				local projDir = getWaProjectDirFromFile(path) -- 2194
				if projDir then -- 2194
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2195
					if not Content:exist(sourceDoraPath) then -- 2196
						return { -- 2197
							success = false, -- 2197
							message = "missing dora template" -- 2197
						} -- 2197
					end -- 2196
					local targetVendorPath = Path(projDir, "vendor") -- 2198
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2199
					if not Content:exist(targetVendorPath) then -- 2200
						if not Content:mkdir(targetVendorPath) then -- 2201
							return { -- 2202
								success = false, -- 2202
								message = "failed to create vendor folder" -- 2202
							} -- 2202
						end -- 2201
					elseif not Content:isdir(targetVendorPath) then -- 2203
						return { -- 2204
							success = false, -- 2204
							message = "vendor path is not a folder" -- 2204
						} -- 2204
					end -- 2200
					if Content:exist(targetDoraPath) then -- 2205
						if not Content:remove(targetDoraPath) then -- 2206
							return { -- 2207
								success = false, -- 2207
								message = "failed to remove old dora" -- 2207
							} -- 2207
						end -- 2206
					end -- 2205
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2208
						return { -- 2209
							success = false, -- 2209
							message = "failed to copy dora" -- 2209
						} -- 2209
					end -- 2208
					return { -- 2210
						success = true -- 2210
					} -- 2210
				else -- 2212
					return { -- 2212
						success = false, -- 2212
						message = 'Wa file needs a project' -- 2212
					} -- 2212
				end -- 2194
			end -- 2193
		end -- 2193
	end -- 2193
	return { -- 2192
		success = false, -- 2192
		message = "invalid call" -- 2192
	} -- 2192
end) -- 2192
HttpServer:postSchedule("/wa/build", function(req) -- 2214
	do -- 2215
		local _type_0 = type(req) -- 2215
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2215
		if _tab_0 then -- 2215
			local path -- 2215
			do -- 2215
				local _obj_0 = req.body -- 2215
				local _type_1 = type(_obj_0) -- 2215
				if "table" == _type_1 or "userdata" == _type_1 then -- 2215
					path = _obj_0.path -- 2215
				end -- 2215
			end -- 2215
			if path ~= nil then -- 2215
				local projDir = getWaProjectDirFromFile(path) -- 2216
				if projDir then -- 2216
					local message = Wasm:buildWaAsync(projDir) -- 2217
					if message == "" then -- 2218
						return { -- 2219
							success = true -- 2219
						} -- 2219
					else -- 2221
						return { -- 2221
							success = false, -- 2221
							message = message -- 2221
						} -- 2221
					end -- 2218
				else -- 2223
					return { -- 2223
						success = false, -- 2223
						message = 'Wa file needs a project' -- 2223
					} -- 2223
				end -- 2216
			end -- 2215
		end -- 2215
	end -- 2215
	return { -- 2224
		success = false, -- 2224
		message = 'failed to build' -- 2224
	} -- 2224
end) -- 2214
HttpServer:postSchedule("/wa/format", function(req) -- 2226
	do -- 2227
		local _type_0 = type(req) -- 2227
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2227
		if _tab_0 then -- 2227
			local file -- 2227
			do -- 2227
				local _obj_0 = req.body -- 2227
				local _type_1 = type(_obj_0) -- 2227
				if "table" == _type_1 or "userdata" == _type_1 then -- 2227
					file = _obj_0.file -- 2227
				end -- 2227
			end -- 2227
			if file ~= nil then -- 2227
				local code = Wasm:formatWaAsync(file) -- 2228
				if code == "" then -- 2229
					return { -- 2230
						success = false -- 2230
					} -- 2230
				else -- 2232
					return { -- 2232
						success = true, -- 2232
						code = code -- 2232
					} -- 2232
				end -- 2229
			end -- 2227
		end -- 2227
	end -- 2227
	return { -- 2233
		success = false -- 2233
	} -- 2233
end) -- 2226
HttpServer:postSchedule("/wa/create", function(req) -- 2235
	do -- 2236
		local _type_0 = type(req) -- 2236
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2236
		if _tab_0 then -- 2236
			local path -- 2236
			do -- 2236
				local _obj_0 = req.body -- 2236
				local _type_1 = type(_obj_0) -- 2236
				if "table" == _type_1 or "userdata" == _type_1 then -- 2236
					path = _obj_0.path -- 2236
				end -- 2236
			end -- 2236
			if path ~= nil then -- 2236
				if not Content:exist(Path:getPath(path)) then -- 2237
					return { -- 2238
						success = false, -- 2238
						message = "target path not existed" -- 2238
					} -- 2238
				end -- 2237
				if Content:exist(path) then -- 2239
					return { -- 2240
						success = false, -- 2240
						message = "target project folder existed" -- 2240
					} -- 2240
				end -- 2239
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2241
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2242
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2243
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2244
					return { -- 2247
						success = false, -- 2247
						message = "missing template project" -- 2247
					} -- 2247
				end -- 2244
				if not Content:mkdir(path) then -- 2248
					return { -- 2249
						success = false, -- 2249
						message = "failed to create project folder" -- 2249
					} -- 2249
				end -- 2248
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2250
					Content:remove(path) -- 2251
					return { -- 2252
						success = false, -- 2252
						message = "failed to copy template" -- 2252
					} -- 2252
				end -- 2250
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2253
					Content:remove(path) -- 2254
					return { -- 2255
						success = false, -- 2255
						message = "failed to copy template" -- 2255
					} -- 2255
				end -- 2253
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2256
					Content:remove(path) -- 2257
					return { -- 2258
						success = false, -- 2258
						message = "failed to copy template" -- 2258
					} -- 2258
				end -- 2256
				return { -- 2259
					success = true -- 2259
				} -- 2259
			end -- 2236
		end -- 2236
	end -- 2236
	return { -- 2235
		success = false, -- 2235
		message = "invalid call" -- 2235
	} -- 2235
end) -- 2235
local tsBuildGlobs = { -- 2262
	"**/*.ts", -- 2262
	"**/*.tsx", -- 2263
	"!**/.*/**", -- 2264
	"!**/node_modules/**" -- 2265
} -- 2261
local _anon_func_6 = function(path) -- 2276
	local _val_0 = Path:getExt(path) -- 2276
	return "ts" == _val_0 or "tsx" == _val_0 -- 2276
end -- 2276
HttpServer:postSchedule("/ts/build", function(req) -- 2267
	do -- 2268
		local _type_0 = type(req) -- 2268
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2268
		if _tab_0 then -- 2268
			local path -- 2268
			do -- 2268
				local _obj_0 = req.body -- 2268
				local _type_1 = type(_obj_0) -- 2268
				if "table" == _type_1 or "userdata" == _type_1 then -- 2268
					path = _obj_0.path -- 2268
				end -- 2268
			end -- 2268
			if path ~= nil then -- 2268
				if HttpServer.wsConnectionCount == 0 then -- 2269
					return { -- 2270
						success = false, -- 2270
						message = "Web IDE not connected" -- 2270
					} -- 2270
				end -- 2269
				local projectRoot = req.body.projectRoot -- 2271
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2272
				if not Content:exist(path) then -- 2273
					return { -- 2274
						success = false, -- 2274
						message = "path not existed" -- 2274
					} -- 2274
				end -- 2273
				if not Content:isdir(path) then -- 2275
					if not (_anon_func_6(path)) then -- 2276
						return { -- 2277
							success = false, -- 2277
							message = "expecting a TypeScript file" -- 2277
						} -- 2277
					end -- 2276
					local messages = { } -- 2278
					local content = Content:load(path) -- 2279
					if not content then -- 2280
						return { -- 2281
							success = false, -- 2281
							message = "failed to read file" -- 2281
						} -- 2281
					end -- 2280
					emit("AppWS", "Send", json.encode({ -- 2282
						name = "UpdateFile", -- 2282
						file = path, -- 2282
						exists = true, -- 2282
						content = content, -- 2282
						projectRoot = sourceRoot -- 2282
					})) -- 2282
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2283
						local done = false -- 2284
						do -- 2285
							local _with_0 = Node() -- 2285
							_with_0:gslot("AppWS", function(event) -- 2286
								if event.type == "Receive" then -- 2287
									local res = json.decode(event.msg) -- 2288
									if res then -- 2288
										if res.name == "TranspileTS" and res.file == path then -- 2289
											_with_0:removeFromParent() -- 2290
											if res.success then -- 2291
												local luaFile = Path:replaceExt(path, "lua") -- 2292
												Content:save(luaFile, res.luaCode) -- 2293
												messages[#messages + 1] = { -- 2294
													success = true, -- 2294
													file = path -- 2294
												} -- 2294
											else -- 2296
												messages[#messages + 1] = { -- 2296
													success = false, -- 2296
													file = path, -- 2296
													message = res.message -- 2296
												} -- 2296
											end -- 2291
											done = true -- 2297
										end -- 2289
									end -- 2288
								end -- 2287
							end) -- 2286
						end -- 2285
						emit("AppWS", "Send", json.encode({ -- 2298
							name = "TranspileTS", -- 2298
							file = path, -- 2298
							content = content, -- 2298
							projectRoot = sourceRoot -- 2298
						})) -- 2298
						wait(function() -- 2299
							return done -- 2299
						end) -- 2299
					end -- 2283
					return { -- 2300
						success = true, -- 2300
						messages = messages -- 2300
					} -- 2300
				else -- 2302
					local fileData = { } -- 2302
					local messages = { } -- 2303
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2304
					for _index_0 = 1, #_list_0 do -- 2304
						local subFile = _list_0[_index_0] -- 2304
						local file = Path(path, subFile) -- 2305
						local content = Content:load(file) -- 2306
						if content then -- 2306
							fileData[file] = content -- 2307
							emit("AppWS", "Send", json.encode({ -- 2308
								name = "UpdateFile", -- 2308
								file = file, -- 2308
								exists = true, -- 2308
								content = content, -- 2308
								projectRoot = sourceRoot -- 2308
							})) -- 2308
						else -- 2310
							messages[#messages + 1] = { -- 2310
								success = false, -- 2310
								file = file, -- 2310
								message = "failed to read file" -- 2310
							} -- 2310
						end -- 2306
					end -- 2304
					for file, content in pairs(fileData) do -- 2311
						if "d" == Path:getExt(Path:getName(file)) then -- 2312
							goto _continue_0 -- 2312
						end -- 2312
						local done = false -- 2313
						do -- 2314
							local _with_0 = Node() -- 2314
							_with_0:gslot("AppWS", function(event) -- 2315
								if event.type == "Receive" then -- 2316
									local res = json.decode(event.msg) -- 2317
									if res then -- 2317
										if res.name == "TranspileTS" and res.file == file then -- 2318
											_with_0:removeFromParent() -- 2319
											if res.success then -- 2320
												local luaFile = Path:replaceExt(file, "lua") -- 2321
												Content:save(luaFile, res.luaCode) -- 2322
												messages[#messages + 1] = { -- 2323
													success = true, -- 2323
													file = file -- 2323
												} -- 2323
											else -- 2325
												messages[#messages + 1] = { -- 2325
													success = false, -- 2325
													file = file, -- 2325
													message = res.message -- 2325
												} -- 2325
											end -- 2320
											done = true -- 2326
										end -- 2318
									end -- 2317
								end -- 2316
							end) -- 2315
						end -- 2314
						emit("AppWS", "Send", json.encode({ -- 2327
							name = "TranspileTS", -- 2327
							file = file, -- 2327
							content = content, -- 2327
							projectRoot = sourceRoot -- 2327
						})) -- 2327
						wait(function() -- 2328
							return done -- 2328
						end) -- 2328
						::_continue_0:: -- 2312
					end -- 2311
					return { -- 2329
						success = true, -- 2329
						messages = messages -- 2329
					} -- 2329
				end -- 2275
			end -- 2268
		end -- 2268
	end -- 2268
	return { -- 2267
		success = false -- 2267
	} -- 2267
end) -- 2267
HttpServer:post("/download", function(req) -- 2331
	do -- 2332
		local _type_0 = type(req) -- 2332
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2332
		if _tab_0 then -- 2332
			local url -- 2332
			do -- 2332
				local _obj_0 = req.body -- 2332
				local _type_1 = type(_obj_0) -- 2332
				if "table" == _type_1 or "userdata" == _type_1 then -- 2332
					url = _obj_0.url -- 2332
				end -- 2332
			end -- 2332
			local target -- 2332
			do -- 2332
				local _obj_0 = req.body -- 2332
				local _type_1 = type(_obj_0) -- 2332
				if "table" == _type_1 or "userdata" == _type_1 then -- 2332
					target = _obj_0.target -- 2332
				end -- 2332
			end -- 2332
			if url ~= nil and target ~= nil then -- 2332
				local Entry = require("Script.Dev.Entry") -- 2333
				Entry.downloadFile(url, target) -- 2334
				return { -- 2335
					success = true -- 2335
				} -- 2335
			end -- 2332
		end -- 2332
	end -- 2332
	return { -- 2331
		success = false -- 2331
	} -- 2331
end) -- 2331
local isDesktopPlatform -- 2337
isDesktopPlatform = function() -- 2337
	local _val_0 = App.platform -- 2338
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2338
end -- 2337
local getServerStatus -- 2340
getServerStatus = function() -- 2340
	local Entry = require("Script.Dev.Entry") -- 2341
	local running = Entry.getCurrentEntryStatus() -- 2342
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2343
	return { -- 2345
		success = true, -- 2345
		platform = App.platform, -- 2346
		locale = App.locale, -- 2347
		version = App.version, -- 2348
		url = "http://localhost:8866", -- 2349
		wsConnectionCount = HttpServer.wsConnectionCount, -- 2350
		webIDEConnected = HttpServer.wsConnectionCount > 0, -- 2351
		assetPath = Content.assetPath, -- 2352
		writablePath = Content.writablePath, -- 2353
		waTemplateReady = waTemplateReady, -- 2354
		running = running -- 2355
	} -- 2344
end -- 2340
HttpServer:post("/status", function() -- 2358
	return getServerStatus() -- 2359
end) -- 2358
HttpServer:postSchedule("/doctor/fix", function(req) -- 2361
	do -- 2362
		local _type_0 = type(req) -- 2362
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2362
		if _tab_0 then -- 2362
			local openWebIDE -- 2362
			do -- 2362
				local _obj_0 = req.body -- 2362
				local _type_1 = type(_obj_0) -- 2362
				if "table" == _type_1 or "userdata" == _type_1 then -- 2362
					openWebIDE = _obj_0.openWebIDE -- 2362
				end -- 2362
			end -- 2362
			if openWebIDE ~= nil then -- 2362
				if not openWebIDE then -- 2363
					return { -- 2364
						success = false, -- 2364
						message = "nothing to fix" -- 2364
					} -- 2364
				end -- 2363
				local status = getServerStatus() -- 2365
				if status.webIDEConnected then -- 2366
					return { -- 2367
						success = true, -- 2367
						fixed = false, -- 2367
						message = "Web IDE already connected.", -- 2367
						status = status -- 2367
					} -- 2367
				end -- 2366
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2368
				if waitSeconds > 0 then -- 2369
					local deadline = os.time() + waitSeconds -- 2370
					repeat -- 2371
						sleep(0.2) -- 2372
						status = getServerStatus() -- 2373
						if status.webIDEConnected then -- 2374
							return { -- 2375
								success = true, -- 2375
								fixed = false, -- 2375
								reconnected = true, -- 2375
								message = "Web IDE reconnected.", -- 2375
								status = status -- 2375
							} -- 2375
						end -- 2374
					until os.time() >= deadline -- 2371
				end -- 2369
				if not isDesktopPlatform() then -- 2377
					return { -- 2378
						success = false, -- 2378
						message = "opening Web IDE is only supported on desktop platforms", -- 2378
						status = status -- 2378
					} -- 2378
				end -- 2377
				local url = "http://localhost:8866" -- 2379
				App:openURL(url) -- 2380
				status.openedURL = url -- 2381
				return { -- 2382
					success = true, -- 2382
					fixed = true, -- 2382
					message = "Opened Web IDE in the local browser.", -- 2382
					url = url, -- 2382
					status = status -- 2382
				} -- 2382
			end -- 2362
		end -- 2362
	end -- 2362
	return { -- 2361
		success = false, -- 2361
		message = "invalid call" -- 2361
	} -- 2361
end) -- 2361
local status = { } -- 2384
_module_0 = status -- 2385
status.buildAsync = function(path) -- 2387
	if not Content:exist(path) then -- 2388
		return { -- 2389
			success = false, -- 2389
			file = path, -- 2389
			message = "file not existed" -- 2389
		} -- 2389
	end -- 2388
	do -- 2390
		local _exp_0 = Path:getExt(path) -- 2390
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2390
			if '' == Path:getExt(Path:getName(path)) then -- 2391
				local content = Content:loadAsync(path) -- 2392
				if content then -- 2392
					local resultCodes, err = compileFileAsync(path, content) -- 2393
					if resultCodes then -- 2393
						return { -- 2394
							success = true, -- 2394
							file = path -- 2394
						} -- 2394
					else -- 2396
						return { -- 2396
							success = false, -- 2396
							file = path, -- 2396
							message = err -- 2396
						} -- 2396
					end -- 2393
				end -- 2392
			end -- 2391
		elseif "lua" == _exp_0 then -- 2397
			local content = Content:loadAsync(path) -- 2398
			if content then -- 2398
				do -- 2399
					local isTIC80 = CheckTIC80Code(content) -- 2399
					if isTIC80 then -- 2399
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2400
					end -- 2399
				end -- 2399
				local success, info -- 2401
				do -- 2401
					local _obj_0 = luaCheck(path, content) -- 2401
					success, info = _obj_0.success, _obj_0.info -- 2401
				end -- 2401
				if success then -- 2402
					return { -- 2403
						success = true, -- 2403
						file = path -- 2403
					} -- 2403
				elseif info and #info > 0 then -- 2404
					local messages = { } -- 2405
					for _index_0 = 1, #info do -- 2406
						local _des_0 = info[_index_0] -- 2406
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2406
						local lineText = "" -- 2407
						if line then -- 2408
							local currentLine = 1 -- 2409
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2410
								if currentLine == line then -- 2411
									lineText = text -- 2412
									break -- 2413
								end -- 2411
								currentLine = currentLine + 1 -- 2414
							end -- 2410
						end -- 2408
						if line then -- 2415
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2416
						else -- 2418
							messages[#messages + 1] = message -- 2418
						end -- 2415
					end -- 2406
					return { -- 2419
						success = false, -- 2419
						file = path, -- 2419
						message = table.concat(messages, "\n") -- 2419
					} -- 2419
				else -- 2421
					return { -- 2421
						success = false, -- 2421
						file = path, -- 2421
						message = "lua check failed" -- 2421
					} -- 2421
				end -- 2402
			end -- 2398
		elseif "yarn" == _exp_0 then -- 2422
			local content = Content:loadAsync(path) -- 2423
			if content then -- 2423
				local res, _, err = yarncompile(content, true) -- 2424
				if res then -- 2424
					return { -- 2425
						success = true, -- 2425
						file = path -- 2425
					} -- 2425
				else -- 2427
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2427
					local lineText = "" -- 2428
					if line then -- 2429
						local currentLine = 1 -- 2430
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2431
							if currentLine == line then -- 2432
								lineText = text -- 2433
								break -- 2434
							end -- 2432
							currentLine = currentLine + 1 -- 2435
						end -- 2431
					end -- 2429
					if node ~= "" then -- 2436
						node = "node: " .. tostring(node) .. ", " -- 2437
					else -- 2438
						node = "" -- 2438
					end -- 2436
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2439
					return { -- 2440
						success = false, -- 2440
						file = path, -- 2440
						message = message -- 2440
					} -- 2440
				end -- 2424
			end -- 2423
		end -- 2390
	end -- 2390
	return { -- 2441
		success = false, -- 2441
		file = path, -- 2441
		message = "invalid file to build" -- 2441
	} -- 2441
end -- 2387
thread(function() -- 2443
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 2444
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 2445
	if Content:exist(doraWeb) then -- 2446
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) -- 2447
		local needReload -- 2448
		if Content:exist(doraReady) then -- 2448
			needReload = readyContent ~= Content:load(doraReady) -- 2449
		else -- 2450
			needReload = true -- 2450
		end -- 2448
		if needReload then -- 2451
			Content:remove(Path(Content.appPath, ".www")) -- 2452
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 2453
			Content:save(doraReady, readyContent) -- 2457
			print("Dora Dora is ready!") -- 2458
		end -- 2451
	end -- 2446
	if HttpServer:start(8866) then -- 2459
		local localIP = HttpServer.localIP -- 2460
		if localIP == "" then -- 2461
			localIP = "localhost" -- 2461
		end -- 2461
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 2462
		return HttpServer:startWS(8868) -- 2463
	else -- 2465
		status.url = nil -- 2465
		return print("8866 Port not available!") -- 2466
	end -- 2459
end) -- 2443
return _module_0 -- 1
