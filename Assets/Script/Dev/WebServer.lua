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
local pairs <const> = pairs -- 10
local Git <const> = Git -- 10
local DB <const> = DB -- 10
local tonumber <const> = tonumber -- 10
local json <const> = json -- 10
local pcall <const> = pcall -- 10
local wait <const> = wait -- 10
local yue <const> = yue -- 10
local load <const> = load -- 10
local teal <const> = teal -- 10
local xml <const> = xml -- 10
local ipairs <const> = ipairs -- 10
local App <const> = App -- 10
local setmetatable <const> = setmetatable -- 10
local Wasm <const> = Wasm -- 10
local sleep <const> = sleep -- 10
local package <const> = package -- 10
local thread <const> = thread -- 10
local print <const> = print -- 10
local emit <const> = emit -- 10
local Node <const> = Node -- 10
local Director <const> = Director -- 10
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
local AgentHost = require("Script.Dev.AgentHost") -- 140
local AgentTools = AgentHost.proxy("Agent.Tools") -- 141
local AgentSession = AgentHost.proxy("Agent.Session") -- 142
local AgentLocalAgent = AgentHost.proxy("Agent.LocalAgent") -- 143
local AgentVisionAssets = AgentHost.proxy("Agent.Tool.VisionAssets") -- 144
HttpServer:post("/agent/runtime/status", function() -- 146
	return AgentHost.status() -- 146
end) -- 146
HttpServer:post("/agent/runtime/reload", function() -- 147
	return AgentHost.reload() -- 147
end) -- 147
HttpServer:post("/agent/runtime/automatic", function(req) -- 148
	do -- 149
		local _type_0 = type(req) -- 149
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 149
		if _tab_0 then -- 149
			local enabled -- 149
			do -- 149
				local _obj_0 = req.body -- 149
				local _type_1 = type(_obj_0) -- 149
				if "table" == _type_1 or "userdata" == _type_1 then -- 149
					enabled = _obj_0.enabled -- 149
				end -- 149
			end -- 149
			if enabled ~= nil then -- 149
				if type(enabled) == "boolean" then -- 150
					return AgentHost.setAutomatic(enabled) -- 150
				end -- 150
			end -- 149
		end -- 149
	end -- 149
	return invalidArguments -- 148
end) -- 148
local GitJobs = { } -- 152
local gitTerminalState -- 154
gitTerminalState = function(status) -- 154
	if not (status and status.state) then -- 155
		return false -- 155
	end -- 155
	local _val_0 = status.state -- 156
	return "done" == _val_0 or "error" == _val_0 or "canceled" == _val_0 -- 156
end -- 154
local GIT_JOB_TTL = 600 -- 158
local gitPruneJobs -- 160
gitPruneJobs = function() -- 160
	local time = os.time() -- 161
	for id, job in pairs(GitJobs) do -- 162
		if gitTerminalState(job.status) and time - (job.updatedAt or time) > GIT_JOB_TTL then -- 163
			GitJobs[id] = nil -- 164
		end -- 163
	end -- 162
end -- 160
local gitInvalidRepoPath -- 166
gitInvalidRepoPath = function(repoPath) -- 166
	if not (type(repoPath) == "string" and repoPath ~= "") then -- 167
		return true -- 167
	end -- 167
	return not Git:isRepoPathAllowed(repoPath) -- 168
end -- 166
local gitShellSplit -- 170
gitShellSplit = function(command) -- 170
	local args = { } -- 171
	local current = { } -- 172
	local quote = nil -- 173
	local escape = false -- 174
	for i = 1, #command do -- 175
		local ch = command:sub(i, i) -- 176
		if escape then -- 177
			current[#current + 1] = ch -- 178
			escape = false -- 179
		elseif ch == "\\" then -- 180
			escape = true -- 181
		elseif quote then -- 182
			if ch == quote then -- 183
				quote = nil -- 184
			else -- 186
				current[#current + 1] = ch -- 186
			end -- 183
		elseif ch == "'" or ch == '"' then -- 187
			quote = ch -- 188
		elseif ch:match("%s") then -- 189
			if #current > 0 then -- 190
				args[#args + 1] = table.concat(current) -- 191
				current = { } -- 192
			end -- 190
		else -- 194
			current[#current + 1] = ch -- 194
		end -- 177
	end -- 175
	if #current > 0 then -- 195
		args[#args + 1] = table.concat(current) -- 196
	end -- 195
	if args[1] == "git" then -- 197
		table.remove(args, 1) -- 198
	end -- 197
	return args -- 199
end -- 170
local gitQuote -- 201
gitQuote = function(value) -- 201
	local text = tostring(value) -- 202
	if text:match("^[%w%._%-%/]+$") then -- 203
		return text -- 204
	end -- 203
	return "\"" .. text:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"" -- 205
end -- 201
local gitDirNonEmpty -- 207
gitDirNonEmpty = function(targetPath) -- 207
	if not Content:exist(targetPath) then -- 208
		return false -- 208
	end -- 208
	if not Content:isdir(targetPath) then -- 209
		return false -- 209
	end -- 209
	return #Content:getFiles(targetPath) > 0 or #Content:getDirs(targetPath) > 0 -- 210
end -- 207
local gitSafeChildPath -- 212
gitSafeChildPath = function(parentPath, childPath) -- 212
	if not (parentPath and childPath and childPath ~= "") then -- 213
		return nil -- 213
	end -- 213
	if childPath:sub(1, 1) == "/" or childPath:match("^%a:[/\\]") then -- 214
		return nil -- 214
	end -- 214
	if childPath == "." or childPath:match("^%.%.[/\\]?" or childPath:match("[/\\]%.%.[/\\]")) then -- 215
		return nil -- 215
	end -- 215
	local targetPath = Path(parentPath, childPath) -- 216
	local relative = Path:getRelative(targetPath, parentPath) -- 217
	if relative == ".." or relative:sub(1, 3) == "../" or relative:sub(1, 3) == "..\\" then -- 218
		return nil -- 218
	end -- 218
	return targetPath -- 219
end -- 212
local gitCloneDirFromURL -- 221
gitCloneDirFromURL = function(url) -- 221
	if not (url and url ~= "") then -- 222
		return nil -- 222
	end -- 222
	local text = tostring(url):match("^%s*(.-)%s*$") -- 223
	if text == "" then -- 224
		return nil -- 224
	end -- 224
	text = text:gsub("[/\\]+$", "") -- 225
	local name = text:match("([^/:]+)$") -- 226
	if not (name and name ~= "") then -- 227
		return nil -- 227
	end -- 227
	name = name:gsub("%.git$", "") -- 228
	if name == "" or name == "." or name == ".." then -- 229
		return nil -- 229
	end -- 229
	return name -- 230
end -- 221
local gitCloneTargetPath -- 232
gitCloneTargetPath = function(repoPath, command) -- 232
	local args = gitShellSplit(command) -- 233
	if not (args[1] == "clone") then -- 234
		return nil -- 234
	end -- 234
	local url = args[2] -- 235
	local index = 3 -- 236
	while index <= #args do -- 237
		local arg = args[index] -- 238
		if ("-b" == arg or "--branch" == arg or "--depth" == arg) then -- 239
			index = index + 2 -- 240
		elseif arg:sub(1, 1) == "-" then -- 241
			index = index + 1 -- 242
		else -- 244
			return gitSafeChildPath(repoPath, arg) -- 244
		end -- 239
	end -- 237
	do -- 245
		local dirName = gitCloneDirFromURL(url) -- 245
		if dirName then -- 245
			return gitSafeChildPath(repoPath, dirName) -- 246
		end -- 245
	end -- 245
	return nil -- 247
end -- 232
local gitPathInsideRepo -- 249
gitPathInsideRepo = function(repoPath, relPath) -- 249
	if not (repoPath and relPath and relPath ~= "") then -- 250
		return false -- 250
	end -- 250
	if relPath:sub(1, 1) == "/" or relPath:match("^%a:[/\\]") then -- 251
		return false -- 251
	end -- 251
	if relPath == "." or relPath:match("^%.%.[/\\]?" or relPath:match("[/\\]%.%.[/\\]")) then -- 252
		return false -- 252
	end -- 252
	local targetPath = Path(repoPath, relPath) -- 253
	local relative = Path:getRelative(targetPath, repoPath) -- 254
	return relative ~= ".." and relative:sub(1, 3) ~= "../" and relative:sub(1, 3) ~= "..\\" -- 255
end -- 249
local gitHostFromURL -- 257
gitHostFromURL = function(url) -- 257
	if not (url and url ~= "") then -- 258
		return nil -- 258
	end -- 258
	local text = tostring(url):match("^%s*(.-)%s*$") -- 259
	if text == "" then -- 260
		return nil -- 260
	end -- 260
	local host = text:match("^[%w_%-]+://([^/:]+)") -- 261
	if not host then -- 262
		host = text:match("@([^:/]+)[:/]") -- 262
	end -- 262
	if not host then -- 263
		host = text:match("^([^:/]+):[^/]") -- 263
	end -- 263
	if not (host and host ~= "") then -- 264
		return nil -- 264
	end -- 264
	return string.lower(host) -- 265
end -- 257
local ensureGitTables -- 267
ensureGitTables = function() -- 267
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
	]]) -- 268
	DB:exec("CREATE INDEX IF NOT EXISTS idx_git_credential_host ON GitCredential(host);") -- 281
	return DB:exec([[		CREATE TABLE IF NOT EXISTS GitProfile(
			id INTEGER PRIMARY KEY CHECK(id = 1),
			name TEXT NOT NULL DEFAULT '',
			email TEXT NOT NULL DEFAULT '',
			updated_at INTEGER
		);
	]]) -- 282
end -- 267
local gitCredentialToPublic -- 291
gitCredentialToPublic = function(row) -- 291
	local id, host, label, typeName, username, createdAt, updatedAt, lastUsedAt = row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8] -- 292
	return { -- 293
		id = id, -- 293
		host = host, -- 293
		label = label, -- 293
		type = typeName, -- 293
		username = username, -- 293
		createdAt = createdAt, -- 293
		updatedAt = updatedAt, -- 293
		lastUsedAt = lastUsedAt -- 293
	} -- 293
end -- 291
local gitLoadCredential -- 295
gitLoadCredential = function(id) -- 295
	ensureGitTables() -- 296
	local credentialId = tonumber(id) or 0 -- 297
	local rows = DB:query("select id, host, label, type, username, secret from GitCredential where id = ? limit 1", { -- 298
		credentialId -- 298
	}) -- 298
	if not (rows and rows[1]) then -- 299
		return nil -- 299
	end -- 299
	local row = rows[1] -- 300
	return { -- 301
		id = row[1], -- 301
		host = row[2], -- 301
		label = row[3], -- 301
		type = row[4], -- 301
		username = row[5], -- 301
		secret = row[6] -- 301
	} -- 301
end -- 295
local gitAuthOptionsJSON -- 303
gitAuthOptionsJSON = function(credential) -- 303
	if not credential then -- 304
		return nil -- 304
	end -- 304
	local auth -- 305
	if credential.type == "token" then -- 305
		auth = { -- 307
			type = "token", -- 307
			token = credential.secret, -- 308
			username = credential.username ~= "" and credential.username or "token" -- 309
		} -- 306
	else -- 312
		auth = { -- 313
			type = "basic", -- 313
			username = credential.username, -- 314
			password = credential.secret -- 315
		} -- 312
	end -- 305
	return json.encode({ -- 317
		auth = auth -- 317
	}) -- 317
end -- 303
local gitLoadProfile -- 319
gitLoadProfile = function() -- 319
	ensureGitTables() -- 320
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 321
	if not (rows and rows[1]) then -- 322
		return nil -- 322
	end -- 322
	local name = tostring(rows[1][1] or "") -- 323
	local email = tostring(rows[1][2] or "") -- 324
	if name == "" and email == "" then -- 325
		return nil -- 325
	end -- 325
	return { -- 326
		name = name, -- 326
		email = email -- 326
	} -- 326
end -- 319
local _anon_func_2 = function(args, gitQuote) -- 345
	local _accum_0 = { } -- 345
	local _len_0 = 1 -- 345
	for _index_0 = 1, #args do -- 345
		local arg = args[_index_0] -- 345
		_accum_0[_len_0] = gitQuote(arg) -- 345
		_len_0 = _len_0 + 1 -- 345
	end -- 345
	return _accum_0 -- 345
end -- 345
local gitApplyProfileToCommit -- 328
gitApplyProfileToCommit = function(command) -- 328
	local args = gitShellSplit(command) -- 329
	if not (args[1] == "commit") then -- 330
		return command -- 330
	end -- 330
	local hasName = false -- 331
	local hasEmail = false -- 332
	for _index_0 = 1, #args do -- 333
		local arg = args[_index_0] -- 333
		if arg == "--author-name" then -- 334
			hasName = true -- 334
		end -- 334
		if arg == "--author-email" then -- 335
			hasEmail = true -- 335
		end -- 335
	end -- 333
	if hasName and hasEmail then -- 336
		return command -- 336
	end -- 336
	local profile = gitLoadProfile() -- 337
	if not profile then -- 338
		return command -- 338
	end -- 338
	if not hasName and profile.name ~= "" then -- 339
		args[#args + 1] = "--author-name" -- 340
		args[#args + 1] = profile.name -- 341
	end -- 339
	if not hasEmail and profile.email ~= "" then -- 342
		args[#args + 1] = "--author-email" -- 343
		args[#args + 1] = profile.email -- 344
	end -- 342
	return table.concat(_anon_func_2(args, gitQuote), " ") -- 345
end -- 328
local gitStartJob -- 347
gitStartJob = function(repoPath, command, optionsJSON) -- 347
	if optionsJSON == nil then -- 347
		optionsJSON = nil -- 347
	end -- 347
	gitPruneJobs() -- 348
	if gitInvalidRepoPath(repoPath) then -- 349
		return nil, "invalid repoPath" -- 349
	end -- 349
	if not (command and command ~= "") then -- 350
		return nil, "invalid command" -- 350
	end -- 350
	if not optionsJSON then -- 351
		optionsJSON = "" -- 351
	end -- 351
	command = gitApplyProfileToCommit(command) -- 352
	do -- 353
		local targetPath = gitCloneTargetPath(repoPath, command) -- 353
		if targetPath then -- 353
			if gitInvalidRepoPath(targetPath) then -- 354
				return nil, "invalid clone target" -- 354
			end -- 354
			if gitDirNonEmpty(targetPath) then -- 355
				return nil, "clone target directory is not empty" -- 356
			end -- 355
		elseif (gitShellSplit(command))[1] == "clone" then -- 357
			return nil, "invalid clone target" -- 358
		end -- 353
	end -- 353
	local statusRef = nil -- 359
	local startGit -- 360
	startGit = function() -- 360
		return Git:run(repoPath, command, (function(status) -- 361
			statusRef = status -- 362
			GitJobs[status.id] = { -- 364
				command = command, -- 364
				status = status, -- 365
				updatedAt = os.time() -- 366
			} -- 363
		end), optionsJSON) -- 361
	end -- 360
	local success, jobId = pcall(startGit) -- 368
	if not success then -- 369
		return nil, tostring(jobId) -- 369
	end -- 369
	if not jobId then -- 370
		return nil, "Git.run did not return a job id" -- 370
	end -- 370
	GitJobs[jobId] = { -- 372
		command = command, -- 372
		status = statusRef or { -- 374
			id = jobId, -- 374
			state = "queued", -- 375
			kind = gitShellSplit(command)[1] or "status", -- 376
			repoPath = repoPath, -- 377
			progress = 0, -- 378
			message = "queued" -- 379
		}, -- 373
		updatedAt = os.time() -- 381
	} -- 371
	return jobId -- 382
end -- 347
local gitRunSync -- 384
gitRunSync = function(repoPath, command, optionsJSON, timeout) -- 384
	if optionsJSON == nil then -- 384
		optionsJSON = nil -- 384
	end -- 384
	if timeout == nil then -- 384
		timeout = 20 -- 384
	end -- 384
	local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 385
	if not jobId then -- 386
		return { -- 386
			success = false, -- 386
			message = err -- 386
		} -- 386
	end -- 386
	local startedAt = os.time() -- 387
	wait(function() -- 388
		local job = GitJobs[jobId] -- 389
		local status = job and job.status -- 390
		return gitTerminalState(status) or os.time() - startedAt >= timeout -- 391
	end) -- 388
	local status = GitJobs[jobId] and GitJobs[jobId].status -- 392
	if not gitTerminalState(status) then -- 393
		Git:cancel(jobId) -- 394
		return { -- 395
			success = false, -- 395
			message = "git command timed out", -- 395
			jobId = jobId, -- 395
			status = status -- 395
		} -- 395
	end -- 393
	return { -- 396
		success = status.state == "done", -- 396
		jobId = jobId, -- 396
		status = status, -- 396
		message = status.error or status.message -- 396
	} -- 396
end -- 384
local gitCredentialsForHost -- 398
gitCredentialsForHost = function(host) -- 398
	if not (host and host ~= "") then -- 399
		return { } -- 399
	end -- 399
	ensureGitTables() -- 400
	local rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by last_used_at desc, label asc, id asc", { -- 401
		host -- 401
	}) -- 401
	if rows then -- 402
		local _accum_0 = { } -- 403
		local _len_0 = 1 -- 403
		for _index_0 = 1, #rows do -- 403
			local row = rows[_index_0] -- 403
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 403
			_len_0 = _len_0 + 1 -- 403
		end -- 403
		return _accum_0 -- 403
	else -- 404
		return { } -- 404
	end -- 402
end -- 398
local gitFirstRemoteURL -- 406
gitFirstRemoteURL = function(repoPath, remoteName) -- 406
	if remoteName == nil then -- 406
		remoteName = nil -- 406
	end -- 406
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 10) -- 407
	local data = remoteRes.status and remoteRes.status.data -- 408
	if not (data and data.remotes) then -- 409
		return nil -- 409
	end -- 409
	local _list_0 = data.remotes -- 410
	for _index_0 = 1, #_list_0 do -- 410
		local remote = _list_0[_index_0] -- 410
		if (not remoteName or remote.name == remoteName) and remote.urls and remote.urls[1] then -- 411
			return remote.urls[1] -- 412
		end -- 411
	end -- 410
	return nil -- 413
end -- 406
local gitConfigRemoteURL -- 415
gitConfigRemoteURL = function(repoPath, remoteName) -- 415
	if remoteName == nil then -- 415
		remoteName = nil -- 415
	end -- 415
	if gitInvalidRepoPath(repoPath) then -- 416
		return nil -- 416
	end -- 416
	local configPath = Path(repoPath, ".git/config") -- 417
	if not Content:exist(configPath) then -- 418
		return nil -- 418
	end -- 418
	local content = Content:load(configPath) -- 419
	if not (content and content ~= "") then -- 420
		return nil -- 420
	end -- 420
	local currentRemote = nil -- 421
	for line in content:gmatch("[^\r\n]+") do -- 422
		local sectionRemote = line:match('^%s*%[remote%s+"([^"]+)"%]%s*$') -- 423
		if sectionRemote then -- 424
			currentRemote = sectionRemote -- 425
		elseif currentRemote and (not remoteName or currentRemote == remoteName) then -- 426
			local url = line:match("^%s*url%s*=%s*(.-)%s*$") -- 427
			if url and url ~= "" then -- 428
				return url -- 428
			end -- 428
		end -- 424
	end -- 422
	return nil -- 429
end -- 415
local gitCommandRemoteArg -- 431
gitCommandRemoteArg = function(args, startIndex) -- 431
	if startIndex == nil then -- 431
		startIndex = 2 -- 431
	end -- 431
	local index = startIndex -- 432
	while index <= #args do -- 433
		local arg = args[index] -- 434
		if ("-u" == arg or "--set-upstream" == arg or "-f" == arg or "--force" == arg or "--all" == arg or "--prune" == arg) then -- 435
			index = index + 1 -- 436
		elseif ("--depth" == arg or "-b" == arg or "--branch" == arg) then -- 437
			index = index + 2 -- 438
		elseif arg and arg:sub(1, 1) == "-" then -- 439
			index = index + 1 -- 440
		else -- 442
			return arg -- 442
		end -- 435
	end -- 433
	return nil -- 443
end -- 431
local gitCommandHost -- 445
gitCommandHost = function(repoPath, command) -- 445
	local args = gitShellSplit(command) -- 446
	if not args[1] then -- 447
		return nil -- 447
	end -- 447
	do -- 448
		local _exp_0 = args[1] -- 448
		if "clone" == _exp_0 or "ls-remote" == _exp_0 then -- 449
			return gitHostFromURL(args[2]) -- 450
		elseif "fetch" == _exp_0 or "pull" == _exp_0 or "push" == _exp_0 then -- 451
			local remoteArg = gitCommandRemoteArg(args, 2) -- 452
			if not remoteArg then -- 453
				return nil -- 453
			end -- 453
			local url = gitHostFromURL(remoteArg) -- 454
			if url then -- 455
				return url -- 455
			end -- 455
			return gitHostFromURL(gitConfigRemoteURL(repoPath, remoteArg)) -- 456
		end -- 448
	end -- 448
	return nil -- 457
end -- 445
local gitAuthSelectionForCommand -- 459
gitAuthSelectionForCommand = function(repoPath, command) -- 459
	local host = gitCommandHost(repoPath, command) -- 460
	if not host then -- 461
		return nil -- 461
	end -- 461
	local items = gitCredentialsForHost(host) -- 462
	if #items == 0 then -- 463
		return nil -- 463
	end -- 463
	return { -- 464
		host = host, -- 464
		items = items -- 464
	} -- 464
end -- 459
local gitDefaultRemote -- 466
gitDefaultRemote = function(remoteStatus) -- 466
	local data = remoteStatus and remoteStatus.data -- 467
	if not (data and data.remotes and data.remotes[1]) then -- 468
		return nil -- 468
	end -- 468
	return data.remotes[1] -- 469
end -- 466
local gitCurrentBranch -- 471
gitCurrentBranch = function(branchStatus) -- 471
	local data = branchStatus and branchStatus.data -- 472
	if data and data.current and data.current ~= "" then -- 473
		return data.current -- 474
	end -- 473
	if data and data.branches then -- 475
		local _list_0 = data.branches -- 476
		for _index_0 = 1, #_list_0 do -- 476
			local branch = _list_0[_index_0] -- 476
			if branch.current then -- 477
				return branch.name -- 477
			end -- 477
		end -- 476
	end -- 475
	return nil -- 478
end -- 471
local gitHeadBranch -- 480
gitHeadBranch = function(repoPath) -- 480
	if gitInvalidRepoPath(repoPath) then -- 481
		return nil -- 481
	end -- 481
	local headPath = Path(repoPath, ".git", "HEAD") -- 482
	if not Content:exist(headPath) then -- 483
		return nil -- 483
	end -- 483
	local head = Content:load(headPath) -- 484
	if not head then -- 485
		return nil -- 485
	end -- 485
	local branch = head:match("^ref:%s*refs/heads/(.-)%s*$") -- 486
	if branch and branch ~= "" then -- 487
		return branch -- 487
	end -- 487
	return nil -- 488
end -- 480
local gitBranchesWithHead -- 490
gitBranchesWithHead = function(branchStatus, currentBranch) -- 490
	local branches = branchStatus and branchStatus.data and branchStatus.data.branches or { } -- 491
	if not (currentBranch and currentBranch ~= "") then -- 492
		return branches -- 492
	end -- 492
	for _index_0 = 1, #branches do -- 493
		local branch = branches[_index_0] -- 493
		if branch.name == currentBranch then -- 494
			return branches -- 494
		end -- 494
	end -- 493
	local withHead -- 495
	do -- 495
		local _accum_0 = { } -- 495
		local _len_0 = 1 -- 495
		for _index_0 = 1, #branches do -- 495
			local branch = branches[_index_0] -- 495
			_accum_0[_len_0] = branch -- 495
			_len_0 = _len_0 + 1 -- 495
		end -- 495
		withHead = _accum_0 -- 495
	end -- 495
	withHead[#withHead + 1] = { -- 496
		name = currentBranch, -- 496
		current = true, -- 496
		unborn = true -- 496
	} -- 496
	return withHead -- 497
end -- 490
local gitStatusMeansNotRepo -- 499
gitStatusMeansNotRepo = function(statusRes) -- 499
	local message = statusRes and (statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message)) or "" -- 500
	message = tostring(message):lower() -- 501
	return message:find("repository does not exist", 1, true) or message:find("not a git repository", 1, true) -- 502
end -- 499
local gitSummary -- 504
gitSummary = function(repoPath) -- 504
	local statusRes = gitRunSync(repoPath, "status", nil, 120) -- 505
	if not statusRes.success then -- 506
		if gitStatusMeansNotRepo(statusRes) then -- 507
			return { -- 508
				success = true, -- 508
				isRepo = false, -- 508
				message = statusRes.message, -- 508
				status = statusRes.status -- 508
			} -- 508
		end -- 507
		return { -- 509
			success = false, -- 509
			message = statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message) or "failed to check Git repository", -- 509
			status = statusRes.status -- 509
		} -- 509
	end -- 506
	local branchRes = gitRunSync(repoPath, "branch", nil, 120) -- 510
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 120) -- 511
	local status = statusRes.status -- 512
	local branchStatus = branchRes.status -- 513
	local remoteStatus = remoteRes.status -- 514
	local currentBranch = gitCurrentBranch(branchStatus) or gitHeadBranch(repoPath) -- 515
	local branches = gitBranchesWithHead(branchStatus, currentBranch) -- 516
	local logRes = gitRunSync(repoPath, "log --metadata-only -n 100", nil, 120) -- 517
	local logStatus -- 518
	if logRes.success then -- 518
		logStatus = logRes.status -- 519
	else -- 521
		logStatus = { -- 522
			state = "done", -- 522
			kind = "log", -- 523
			repoPath = repoPath, -- 524
			progress = 1, -- 525
			message = "git log completed", -- 526
			data = { -- 527
				commits = { } -- 527
			} -- 527
		} -- 521
	end -- 518
	local hasCommit = logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] ~= nil -- 529
	local tagStatus -- 530
	if hasCommit then -- 530
		tagStatus = (gitRunSync(repoPath, "tag", nil, 120)).status -- 531
	else -- 533
		tagStatus = { -- 534
			state = "done", -- 534
			kind = "tag", -- 535
			repoPath = repoPath, -- 536
			progress = 1, -- 537
			message = "git tag completed", -- 538
			data = { -- 539
				tags = { } -- 539
			} -- 539
		} -- 533
	end -- 530
	local defaultRemote = gitDefaultRemote(remoteStatus) -- 541
	local lastCommit = nil -- 542
	if logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] then -- 543
		lastCommit = logStatus.data.commits[1] -- 544
	end -- 543
	return { -- 546
		success = true, -- 546
		isRepo = true, -- 547
		clean = status.data and status.data.clean or false, -- 548
		currentBranch = currentBranch, -- 549
		defaultRemote = defaultRemote, -- 550
		remotes = remoteStatus and remoteStatus.data and remoteStatus.data.remotes or { }, -- 551
		branches = branches, -- 552
		lastCommit = lastCommit, -- 553
		status = status, -- 554
		branchStatus = branchStatus, -- 555
		remoteStatus = remoteStatus, -- 556
		historyStatus = logStatus, -- 557
		tagStatus = tagStatus -- 558
	} -- 545
end -- 504
HttpServer:post("/git/run", function(req) -- 560
	do -- 561
		local _type_0 = type(req) -- 561
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 561
		if _tab_0 then -- 561
			local body = req.body -- 561
			if body ~= nil then -- 561
				local repoPath, command, authId, optionsJSON = body.repoPath, body.command, body.authId, body.optionsJSON -- 562
				if authId and not optionsJSON then -- 563
					local credential = gitLoadCredential(authId) -- 564
					if credential then -- 564
						optionsJSON = gitAuthOptionsJSON(credential) -- 565
						DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 566
							os.time(), -- 566
							credential.id -- 566
						}) -- 566
					end -- 564
				elseif not optionsJSON then -- 567
					local authOk, authSelection = pcall(gitAuthSelectionForCommand, repoPath, command) -- 568
					if not authOk then -- 569
						authSelection = nil -- 569
					end -- 569
					if authSelection then -- 570
						if #authSelection.items == 1 then -- 571
							local credential = gitLoadCredential(authSelection.items[1].id) -- 572
							optionsJSON = gitAuthOptionsJSON(credential) -- 573
							DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 574
								os.time(), -- 574
								credential.id -- 574
							}) -- 574
						else -- 576
							return { -- 576
								success = false, -- 576
								message = "select a Git credential", -- 576
								needsCredentialSelection = true, -- 576
								host = authSelection.host, -- 576
								credentials = authSelection.items -- 576
							} -- 576
						end -- 571
					end -- 570
				end -- 563
				local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 577
				if not jobId then -- 578
					return { -- 578
						success = false, -- 578
						message = err -- 578
					} -- 578
				end -- 578
				return { -- 579
					success = true, -- 579
					jobId = jobId -- 579
				} -- 579
			end -- 561
		end -- 561
	end -- 561
	return invalidArguments -- 560
end) -- 560
HttpServer:post("/git/status", function(req) -- 581
	do -- 582
		local _type_0 = type(req) -- 582
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 582
		if _tab_0 then -- 582
			local jobId -- 582
			do -- 582
				local _obj_0 = req.body -- 582
				local _type_1 = type(_obj_0) -- 582
				if "table" == _type_1 or "userdata" == _type_1 then -- 582
					jobId = _obj_0.jobId -- 582
				end -- 582
			end -- 582
			if jobId ~= nil then -- 582
				local job = GitJobs[tonumber(jobId) or 0] -- 583
				if not job then -- 584
					return { -- 584
						success = false, -- 584
						message = "git job not found" -- 584
					} -- 584
				end -- 584
				return { -- 585
					success = true, -- 585
					status = job.status, -- 585
					command = job.command -- 585
				} -- 585
			end -- 582
		end -- 582
	end -- 582
	return invalidArguments -- 581
end) -- 581
HttpServer:post("/git/cancel", function(req) -- 587
	do -- 588
		local _type_0 = type(req) -- 588
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 588
		if _tab_0 then -- 588
			local jobId -- 588
			do -- 588
				local _obj_0 = req.body -- 588
				local _type_1 = type(_obj_0) -- 588
				if "table" == _type_1 or "userdata" == _type_1 then -- 588
					jobId = _obj_0.jobId -- 588
				end -- 588
			end -- 588
			if jobId ~= nil then -- 588
				local id = tonumber(jobId) -- 589
				if not id then -- 590
					return { -- 590
						success = false, -- 590
						message = "invalid jobId" -- 590
					} -- 590
				end -- 590
				return { -- 591
					success = Git:cancel(id) -- 591
				} -- 591
			end -- 588
		end -- 588
	end -- 588
	return invalidArguments -- 587
end) -- 587
HttpServer:postSchedule("/git/summary", function(req) -- 593
	do -- 594
		local _type_0 = type(req) -- 594
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 594
		if _tab_0 then -- 594
			local repoPath -- 594
			do -- 594
				local _obj_0 = req.body -- 594
				local _type_1 = type(_obj_0) -- 594
				if "table" == _type_1 or "userdata" == _type_1 then -- 594
					repoPath = _obj_0.repoPath -- 594
				end -- 594
			end -- 594
			if repoPath ~= nil then -- 594
				if gitInvalidRepoPath(repoPath) then -- 595
					return { -- 595
						success = false, -- 595
						message = "invalid repoPath" -- 595
					} -- 595
				end -- 595
				return gitSummary(repoPath) -- 596
			end -- 594
		end -- 594
	end -- 594
	return invalidArguments -- 593
end) -- 593
HttpServer:postSchedule("/git/status-files", function(req) -- 598
	do -- 599
		local _type_0 = type(req) -- 599
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 599
		if _tab_0 then -- 599
			local repoPath -- 599
			do -- 599
				local _obj_0 = req.body -- 599
				local _type_1 = type(_obj_0) -- 599
				if "table" == _type_1 or "userdata" == _type_1 then -- 599
					repoPath = _obj_0.repoPath -- 599
				end -- 599
			end -- 599
			if repoPath ~= nil then -- 599
				return gitRunSync(repoPath, "status", nil, 120) -- 600
			end -- 599
		end -- 599
	end -- 599
	return invalidArguments -- 598
end) -- 598
HttpServer:postSchedule("/git/discard-untracked", function(req) -- 602
	do -- 603
		local _type_0 = type(req) -- 603
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 603
		if _tab_0 then -- 603
			local body = req.body -- 603
			if body ~= nil then -- 603
				local repoPath, paths = body.repoPath, body.paths -- 604
				if gitInvalidRepoPath(repoPath) then -- 605
					return { -- 605
						success = false, -- 605
						message = "invalid repoPath" -- 605
					} -- 605
				end -- 605
				if not (type(paths) == "table") then -- 606
					return { -- 606
						success = false, -- 606
						message = "invalid paths" -- 606
					} -- 606
				end -- 606
				local statusRes = gitRunSync(repoPath, "status", nil, 10) -- 607
				if not statusRes.success then -- 608
					return statusRes -- 608
				end -- 608
				local untracked = { } -- 609
				local _list_0 = (statusRes.status.data and statusRes.status.data.files or { }) -- 610
				for _index_0 = 1, #_list_0 do -- 610
					local file = _list_0[_index_0] -- 610
					if file.staging == "?" or file.worktree == "?" then -- 611
						untracked[file.path] = true -- 612
					end -- 611
				end -- 610
				local removed = { } -- 613
				for _index_0 = 1, #paths do -- 614
					local relPath = paths[_index_0] -- 614
					relPath = tostring(relPath) -- 615
					if not gitPathInsideRepo(repoPath, relPath) then -- 616
						return { -- 616
							success = false, -- 616
							message = "unsafe path: " .. tostring(relPath) -- 616
						} -- 616
					end -- 616
					if not untracked[relPath] then -- 617
						return { -- 617
							success = false, -- 617
							message = "path is not untracked: " .. tostring(relPath) -- 617
						} -- 617
					end -- 617
				end -- 614
				for _index_0 = 1, #paths do -- 618
					local relPath = paths[_index_0] -- 618
					local targetPath = Path(repoPath, tostring(relPath)) -- 619
					if Content:exist(targetPath) then -- 620
						Content:remove(targetPath) -- 621
						removed[#removed + 1] = tostring(relPath) -- 622
					end -- 620
				end -- 618
				return { -- 623
					success = true, -- 623
					removed = removed -- 623
				} -- 623
			end -- 603
		end -- 603
	end -- 603
	return invalidArguments -- 602
end) -- 602
HttpServer:postSchedule("/git/file-diff", function(req) -- 625
	do -- 626
		local _type_0 = type(req) -- 626
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 626
		if _tab_0 then -- 626
			local body = req.body -- 626
			if body ~= nil then -- 626
				local repoPath, path, staged = body.repoPath, body.path, body.staged -- 627
				if gitInvalidRepoPath(repoPath) then -- 628
					return { -- 628
						success = false, -- 628
						message = "invalid repoPath" -- 628
					} -- 628
				end -- 628
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 629
					return { -- 629
						success = false, -- 629
						message = "unsafe path" -- 629
					} -- 629
				end -- 629
				local command -- 630
				if staged == true then -- 630
					command = "diff --staged -- " .. tostring(gitQuote(path)) -- 631
				else -- 633
					command = "diff -- " .. tostring(gitQuote(path)) -- 633
				end -- 630
				local res = gitRunSync(repoPath, command, nil, 10) -- 634
				if not res.success then -- 635
					return res -- 635
				end -- 635
				return { -- 636
					success = true, -- 636
					status = res.status, -- 636
					data = res.status and res.status.data -- 636
				} -- 636
			end -- 626
		end -- 626
	end -- 626
	return invalidArguments -- 625
end) -- 625
HttpServer:postSchedule("/git/commit-file-diff", function(req) -- 638
	do -- 639
		local _type_0 = type(req) -- 639
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 639
		if _tab_0 then -- 639
			local body = req.body -- 639
			if body ~= nil then -- 639
				local repoPath, commit, path = body.repoPath, body.commit, body.path -- 640
				if gitInvalidRepoPath(repoPath) then -- 641
					return { -- 641
						success = false, -- 641
						message = "invalid repoPath" -- 641
					} -- 641
				end -- 641
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 642
					return { -- 642
						success = false, -- 642
						message = "invalid commit" -- 642
					} -- 642
				end -- 642
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 643
					return { -- 643
						success = false, -- 643
						message = "unsafe path" -- 643
					} -- 643
				end -- 643
				local res = gitRunSync(repoPath, "diff " .. tostring(gitQuote(commit)) .. " -- " .. tostring(gitQuote(path)), nil, 10) -- 644
				if not res.success then -- 645
					return res -- 645
				end -- 645
				return { -- 646
					success = true, -- 646
					status = res.status, -- 646
					data = res.status and res.status.data -- 646
				} -- 646
			end -- 639
		end -- 639
	end -- 639
	return invalidArguments -- 638
end) -- 638
HttpServer:postSchedule("/git/history", function(req) -- 648
	do -- 649
		local _type_0 = type(req) -- 649
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 649
		if _tab_0 then -- 649
			local body = req.body -- 649
			if body ~= nil then -- 649
				local repoPath, limit = body.repoPath, body.limit -- 650
				limit = math.max(1, math.min(100, tonumber(limit) or 20)) -- 651
				return gitRunSync(repoPath, "log --metadata-only -n " .. tostring(limit), nil, 10) -- 652
			end -- 649
		end -- 649
	end -- 649
	return invalidArguments -- 648
end) -- 648
HttpServer:postSchedule("/git/remotes", function(req) -- 654
	do -- 655
		local _type_0 = type(req) -- 655
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 655
		if _tab_0 then -- 655
			local body = req.body -- 655
			if body ~= nil then -- 655
				local repoPath, command = body.repoPath, body.command -- 656
				command = command or "remote -v" -- 657
				return gitRunSync(repoPath, command, nil, 10) -- 658
			end -- 655
		end -- 655
	end -- 655
	return invalidArguments -- 654
end) -- 654
HttpServer:postSchedule("/git/branches", function(req) -- 660
	do -- 661
		local _type_0 = type(req) -- 661
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 661
		if _tab_0 then -- 661
			local body = req.body -- 661
			if body ~= nil then -- 661
				local repoPath, command = body.repoPath, body.command -- 662
				command = command or "branch" -- 663
				return gitRunSync(repoPath, command, nil, 10) -- 664
			end -- 661
		end -- 661
	end -- 661
	return invalidArguments -- 660
end) -- 660
HttpServer:postSchedule("/git/tags", function(req) -- 666
	do -- 667
		local _type_0 = type(req) -- 667
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 667
		if _tab_0 then -- 667
			local body = req.body -- 667
			if body ~= nil then -- 667
				local repoPath, command = body.repoPath, body.command -- 668
				command = command or "tag" -- 669
				return gitRunSync(repoPath, command, nil, 10) -- 670
			end -- 667
		end -- 667
	end -- 667
	return invalidArguments -- 666
end) -- 666
HttpServer:post("/git/profile/get", function() -- 672
	ensureGitTables() -- 673
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 674
	local profile -- 675
	if rows and rows[1] then -- 675
		profile = { -- 676
			name = rows[1][1], -- 676
			email = rows[1][2] -- 676
		} -- 676
	else -- 678
		profile = { -- 678
			name = "", -- 678
			email = "" -- 678
		} -- 678
	end -- 675
	return { -- 679
		success = true, -- 679
		profile = profile -- 679
	} -- 679
end) -- 672
HttpServer:post("/git/profile/save", function(req) -- 681
	do -- 682
		local _type_0 = type(req) -- 682
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 682
		if _tab_0 then -- 682
			local name -- 682
			do -- 682
				local _obj_0 = req.body -- 682
				local _type_1 = type(_obj_0) -- 682
				if "table" == _type_1 or "userdata" == _type_1 then -- 682
					name = _obj_0.name -- 682
				end -- 682
			end -- 682
			local email -- 682
			do -- 682
				local _obj_0 = req.body -- 682
				local _type_1 = type(_obj_0) -- 682
				if "table" == _type_1 or "userdata" == _type_1 then -- 682
					email = _obj_0.email -- 682
				end -- 682
			end -- 682
			if name ~= nil and email ~= nil then -- 682
				ensureGitTables() -- 683
				DB:exec("insert into GitProfile(id, name, email, updated_at) values(1, ?, ?, ?) on conflict(id) do update set name = excluded.name, email = excluded.email, updated_at = excluded.updated_at", { -- 685
					tostring(name or ""), -- 685
					tostring(email or ""), -- 686
					os.time() -- 687
				}) -- 684
				return { -- 689
					success = true -- 689
				} -- 689
			end -- 682
		end -- 682
	end -- 682
	return invalidArguments -- 681
end) -- 681
HttpServer:post("/git/auth/list", function(req) -- 691
	ensureGitTables() -- 692
	local host = nil -- 693
	do -- 694
		local _type_0 = type(req) -- 694
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 694
		if _tab_0 then -- 694
			local body = req.body -- 694
			if body ~= nil then -- 694
				host = body.host -- 695
			end -- 694
		end -- 694
	end -- 694
	local rows -- 696
	if host and host ~= "" then -- 696
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by host asc, label asc, id asc", { -- 697
			tostring(host):lower() -- 697
		}) -- 697
	else -- 699
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential order by host asc, label asc, id asc") -- 699
	end -- 696
	local items -- 700
	if rows then -- 700
		local _accum_0 = { } -- 700
		local _len_0 = 1 -- 700
		for _index_0 = 1, #rows do -- 700
			local row = rows[_index_0] -- 700
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 700
			_len_0 = _len_0 + 1 -- 700
		end -- 700
		items = _accum_0 -- 700
	else -- 700
		items = { } -- 700
	end -- 700
	return { -- 701
		success = true, -- 701
		items = items -- 701
	} -- 701
end) -- 691
HttpServer:postSchedule("/git/auth/match", function(req) -- 703
	do -- 704
		local _type_0 = type(req) -- 704
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 704
		if _tab_0 then -- 704
			local body = req.body -- 704
			if body ~= nil then -- 704
				if not (type(body) == "table") then -- 705
					return invalidArguments -- 705
				end -- 705
				local repoPath, command, url = body.repoPath, body.command, body.url -- 706
				if url ~= nil and type(url) ~= "string" then -- 707
					return invalidArguments -- 707
				end -- 707
				if not (type(url) == "string" and url ~= "") then -- 708
					if not (type(repoPath) == "string" and type(command) == "string") then -- 709
						return invalidArguments -- 709
					end -- 709
				end -- 708
				local host -- 710
				if url and url ~= "" then -- 710
					host = gitHostFromURL(url) -- 710
				else -- 710
					host = gitCommandHost(repoPath, command) -- 710
				end -- 710
				if not host then -- 711
					return { -- 711
						success = false, -- 711
						message = "git host is required" -- 711
					} -- 711
				end -- 711
				local items = gitCredentialsForHost(host) -- 712
				return { -- 713
					success = true, -- 713
					host = host, -- 713
					items = items, -- 713
					needsSelection = #items > 1, -- 713
					authId = (#items == 1 and items[1].id or nil) -- 713
				} -- 713
			end -- 704
		end -- 704
	end -- 704
	return invalidArguments -- 703
end) -- 703
HttpServer:post("/git/auth/save", function(req) -- 715
	do -- 716
		local _type_0 = type(req) -- 716
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 716
		if _tab_0 then -- 716
			local body = req.body -- 716
			if body ~= nil then -- 716
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token -- 717
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$") -- 718
				label = tostring(label or ""):match("^%s*(.-)%s*$") -- 719
				local credentialType = tostring(body.type or "token") -- 720
				username = tostring(username or "") -- 721
				local secret -- 722
				if credentialType == "basic" then -- 722
					secret = tostring(password or "") -- 722
				else -- 722
					secret = tostring(token or password or "") -- 722
				end -- 722
				if host == "" then -- 723
					return { -- 723
						success = false, -- 723
						message = "host is required" -- 723
					} -- 723
				end -- 723
				if label == "" then -- 724
					return { -- 724
						success = false, -- 724
						message = "label is required" -- 724
					} -- 724
				end -- 724
				if secret == "" then -- 725
					return { -- 725
						success = false, -- 725
						message = "secret is required" -- 725
					} -- 725
				end -- 725
				if not (("basic" == credentialType or "token" == credentialType)) then -- 726
					return { -- 726
						success = false, -- 726
						message = "invalid type" -- 726
					} -- 726
				end -- 726
				ensureGitTables() -- 727
				local now = os.time() -- 728
				if id then -- 729
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", { -- 731
						host, -- 731
						label, -- 731
						credentialType, -- 731
						username, -- 731
						secret, -- 731
						now, -- 731
						(tonumber(id) or 0) -- 731
					}) -- 730
					return { -- 733
						success = true, -- 733
						id = tonumber(id) -- 733
					} -- 733
				else -- 735
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", { -- 736
						host, -- 736
						label, -- 736
						credentialType, -- 736
						username, -- 736
						secret, -- 736
						now, -- 736
						now -- 736
					}) -- 735
					local rows = DB:query("select last_insert_rowid()") -- 738
					return { -- 739
						success = true, -- 739
						id = rows and rows[1] and rows[1][1] -- 739
					} -- 739
				end -- 729
			end -- 716
		end -- 716
	end -- 716
	return invalidArguments -- 715
end) -- 715
HttpServer:post("/git/auth/delete", function(req) -- 741
	do -- 742
		local _type_0 = type(req) -- 742
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 742
		if _tab_0 then -- 742
			local id -- 742
			do -- 742
				local _obj_0 = req.body -- 742
				local _type_1 = type(_obj_0) -- 742
				if "table" == _type_1 or "userdata" == _type_1 then -- 742
					id = _obj_0.id -- 742
				end -- 742
			end -- 742
			if id ~= nil then -- 742
				ensureGitTables() -- 743
				local credentialId = tonumber(id) or 0 -- 744
				DB:exec("delete from GitCredential where id = ?", { -- 745
					credentialId -- 745
				}) -- 745
				return { -- 746
					success = true -- 746
				} -- 746
			end -- 742
		end -- 742
	end -- 742
	return invalidArguments -- 741
end) -- 741
HttpServer:postSchedule("/git/auth/test", function(req) -- 748
	do -- 749
		local _type_0 = type(req) -- 749
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 749
		if _tab_0 then -- 749
			local body = req.body -- 749
			if body ~= nil then -- 749
				local repoPath, url, authId = body.repoPath, body.url, body.authId -- 750
				local credential = gitLoadCredential(authId) -- 751
				local optionsJSON = gitAuthOptionsJSON(credential) -- 752
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20) -- 753
			end -- 749
		end -- 749
	end -- 749
	return invalidArguments -- 748
end) -- 748
HttpServer:post("/agent/session/create", function(req) -- 755
	do -- 756
		local _type_0 = type(req) -- 756
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 756
		if _tab_0 then -- 756
			local projectRoot -- 756
			do -- 756
				local _obj_0 = req.body -- 756
				local _type_1 = type(_obj_0) -- 756
				if "table" == _type_1 or "userdata" == _type_1 then -- 756
					projectRoot = _obj_0.projectRoot -- 756
				end -- 756
			end -- 756
			local title -- 756
			do -- 756
				local _obj_0 = req.body -- 756
				local _type_1 = type(_obj_0) -- 756
				if "table" == _type_1 or "userdata" == _type_1 then -- 756
					title = _obj_0.title -- 756
				end -- 756
			end -- 756
			if projectRoot ~= nil and title ~= nil then -- 756
				return AgentSession.createSession(projectRoot, title) -- 757
			end -- 756
		end -- 756
	end -- 756
	return invalidArguments -- 755
end) -- 755
HttpServer:post("/agent/session/create-sub", function(req) -- 759
	do -- 760
		local _type_0 = type(req) -- 760
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 760
		if _tab_0 then -- 760
			local parentSessionId -- 760
			do -- 760
				local _obj_0 = req.body -- 760
				local _type_1 = type(_obj_0) -- 760
				if "table" == _type_1 or "userdata" == _type_1 then -- 760
					parentSessionId = _obj_0.parentSessionId -- 760
				end -- 760
			end -- 760
			local title -- 760
			do -- 760
				local _obj_0 = req.body -- 760
				local _type_1 = type(_obj_0) -- 760
				if "table" == _type_1 or "userdata" == _type_1 then -- 760
					title = _obj_0.title -- 760
				end -- 760
			end -- 760
			if parentSessionId ~= nil and title ~= nil then -- 760
				return AgentSession.createSubSession(parentSessionId, title) -- 761
			end -- 760
		end -- 760
	end -- 760
	return invalidArguments -- 759
end) -- 759
HttpServer:post("/agent/session/get", function(req) -- 763
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
			if sessionId ~= nil then -- 764
				return AgentSession.getSession(sessionId) -- 765
			end -- 764
		end -- 764
	end -- 764
	return invalidArguments -- 763
end) -- 763
HttpServer:post("/agent/vision/asset", function(req) -- 767
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
			local path -- 768
			do -- 768
				local _obj_0 = req.body -- 768
				local _type_1 = type(_obj_0) -- 768
				if "table" == _type_1 or "userdata" == _type_1 then -- 768
					path = _obj_0.path -- 768
				end -- 768
			end -- 768
			if sessionId ~= nil and path ~= nil then -- 768
				return AgentVisionAssets.getSessionVisionImageFromPath(sessionId, path) -- 769
			end -- 768
		end -- 768
	end -- 768
	return invalidArguments -- 767
end) -- 767
HttpServer:post("/agent/session/mode", function(req) -- 771
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
			local workMode -- 772
			do -- 772
				local _obj_0 = req.body -- 772
				local _type_1 = type(_obj_0) -- 772
				if "table" == _type_1 or "userdata" == _type_1 then -- 772
					workMode = _obj_0.workMode -- 772
				end -- 772
			end -- 772
			if sessionId ~= nil and workMode ~= nil then -- 772
				return AgentSession.setWorkMode(sessionId, workMode) -- 773
			end -- 772
		end -- 772
	end -- 772
	return invalidArguments -- 771
end) -- 771
HttpServer:post("/agent/session/send", function(req) -- 775
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
			local prompt -- 776
			do -- 776
				local _obj_0 = req.body -- 776
				local _type_1 = type(_obj_0) -- 776
				if "table" == _type_1 or "userdata" == _type_1 then -- 776
					prompt = _obj_0.prompt -- 776
				end -- 776
			end -- 776
			if sessionId ~= nil and prompt ~= nil then -- 776
				return AgentSession.sendPrompt(sessionId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 777
			end -- 776
		end -- 776
	end -- 776
	return invalidArguments -- 775
end) -- 775
HttpServer:post("/agent/session/send-local", function(req) -- 779
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
			local prompt -- 780
			do -- 780
				local _obj_0 = req.body -- 780
				local _type_1 = type(_obj_0) -- 780
				if "table" == _type_1 or "userdata" == _type_1 then -- 780
					prompt = _obj_0.prompt -- 780
				end -- 780
			end -- 780
			local localAgentConfigId -- 780
			do -- 780
				local _obj_0 = req.body -- 780
				local _type_1 = type(_obj_0) -- 780
				if "table" == _type_1 or "userdata" == _type_1 then -- 780
					localAgentConfigId = _obj_0.localAgentConfigId -- 780
				end -- 780
			end -- 780
			if sessionId ~= nil and prompt ~= nil and localAgentConfigId ~= nil then -- 780
				return AgentSession.sendLocalPrompt(sessionId, prompt, localAgentConfigId) -- 781
			end -- 780
		end -- 780
	end -- 780
	return invalidArguments -- 779
end) -- 779
HttpServer:post("/agent/session/local/new", function(req) -- 783
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
				return AgentLocalAgent.abandonSession(sessionId) -- 785
			end -- 784
		end -- 784
	end -- 784
	return invalidArguments -- 783
end) -- 783
HttpServer:post("/agent/session/local/info", function(req) -- 787
	do -- 788
		local _type_0 = type(req) -- 788
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 788
		if _tab_0 then -- 788
			local sessionId -- 788
			do -- 788
				local _obj_0 = req.body -- 788
				local _type_1 = type(_obj_0) -- 788
				if "table" == _type_1 or "userdata" == _type_1 then -- 788
					sessionId = _obj_0.sessionId -- 788
				end -- 788
			end -- 788
			if sessionId ~= nil then -- 788
				local info = AgentLocalAgent.getSessionInfo(sessionId) -- 789
				return { -- 790
					success = true, -- 790
					info = info -- 790
				} -- 790
			end -- 788
		end -- 788
	end -- 788
	return invalidArguments -- 787
end) -- 787
HttpServer:post("/agent/session/continue", function(req) -- 792
	do -- 793
		local _type_0 = type(req) -- 793
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 793
		if _tab_0 then -- 793
			local sessionId -- 793
			do -- 793
				local _obj_0 = req.body -- 793
				local _type_1 = type(_obj_0) -- 793
				if "table" == _type_1 or "userdata" == _type_1 then -- 793
					sessionId = _obj_0.sessionId -- 793
				end -- 793
			end -- 793
			if sessionId ~= nil then -- 793
				return AgentSession.continuePrompt(sessionId, req.body.disabledAgentTools, req.body.llmConfigId) -- 794
			end -- 793
		end -- 793
	end -- 793
	return invalidArguments -- 792
end) -- 792
HttpServer:post("/agent/session/finish-handoff", function(req) -- 796
	do -- 797
		local _type_0 = type(req) -- 797
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 797
		if _tab_0 then -- 797
			local sessionId -- 797
			do -- 797
				local _obj_0 = req.body -- 797
				local _type_1 = type(_obj_0) -- 797
				if "table" == _type_1 or "userdata" == _type_1 then -- 797
					sessionId = _obj_0.sessionId -- 797
				end -- 797
			end -- 797
			if sessionId ~= nil then -- 797
				return AgentSession.finishSubSessionHandoff(sessionId, req.body.llmConfigId) -- 798
			end -- 797
		end -- 797
	end -- 797
	return invalidArguments -- 796
end) -- 796
HttpServer:post("/agent/session/resend", function(req) -- 800
	do -- 801
		local _type_0 = type(req) -- 801
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 801
		if _tab_0 then -- 801
			local sessionId -- 801
			do -- 801
				local _obj_0 = req.body -- 801
				local _type_1 = type(_obj_0) -- 801
				if "table" == _type_1 or "userdata" == _type_1 then -- 801
					sessionId = _obj_0.sessionId -- 801
				end -- 801
			end -- 801
			local messageId -- 801
			do -- 801
				local _obj_0 = req.body -- 801
				local _type_1 = type(_obj_0) -- 801
				if "table" == _type_1 or "userdata" == _type_1 then -- 801
					messageId = _obj_0.messageId -- 801
				end -- 801
			end -- 801
			local prompt -- 801
			do -- 801
				local _obj_0 = req.body -- 801
				local _type_1 = type(_obj_0) -- 801
				if "table" == _type_1 or "userdata" == _type_1 then -- 801
					prompt = _obj_0.prompt -- 801
				end -- 801
			end -- 801
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 801
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 802
			end -- 801
		end -- 801
	end -- 801
	return invalidArguments -- 800
end) -- 800
HttpServer:post("/agent/session/questionnaire/respond", function(req) -- 804
	do -- 805
		local _type_0 = type(req) -- 805
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 805
		if _tab_0 then -- 805
			local sessionId -- 805
			do -- 805
				local _obj_0 = req.body -- 805
				local _type_1 = type(_obj_0) -- 805
				if "table" == _type_1 or "userdata" == _type_1 then -- 805
					sessionId = _obj_0.sessionId -- 805
				end -- 805
			end -- 805
			local questionnaireId -- 805
			do -- 805
				local _obj_0 = req.body -- 805
				local _type_1 = type(_obj_0) -- 805
				if "table" == _type_1 or "userdata" == _type_1 then -- 805
					questionnaireId = _obj_0.questionnaireId -- 805
				end -- 805
			end -- 805
			local answers -- 805
			do -- 805
				local _obj_0 = req.body -- 805
				local _type_1 = type(_obj_0) -- 805
				if "table" == _type_1 or "userdata" == _type_1 then -- 805
					answers = _obj_0.answers -- 805
				end -- 805
			end -- 805
			if sessionId ~= nil and questionnaireId ~= nil and answers ~= nil then -- 805
				return AgentSession.respondQuestionnaire(sessionId, questionnaireId, answers, req.body.llmConfigId) -- 806
			end -- 805
		end -- 805
	end -- 805
	return invalidArguments -- 804
end) -- 804
HttpServer:post("/agent/session/questionnaire/cancel", function(req) -- 808
	do -- 809
		local _type_0 = type(req) -- 809
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 809
		if _tab_0 then -- 809
			local sessionId -- 809
			do -- 809
				local _obj_0 = req.body -- 809
				local _type_1 = type(_obj_0) -- 809
				if "table" == _type_1 or "userdata" == _type_1 then -- 809
					sessionId = _obj_0.sessionId -- 809
				end -- 809
			end -- 809
			local questionnaireId -- 809
			do -- 809
				local _obj_0 = req.body -- 809
				local _type_1 = type(_obj_0) -- 809
				if "table" == _type_1 or "userdata" == _type_1 then -- 809
					questionnaireId = _obj_0.questionnaireId -- 809
				end -- 809
			end -- 809
			if sessionId ~= nil and questionnaireId ~= nil then -- 809
				return AgentSession.cancelQuestionnaire(sessionId, questionnaireId, req.body.llmConfigId) -- 810
			end -- 809
		end -- 809
	end -- 809
	return invalidArguments -- 808
end) -- 808
HttpServer:post("/agent/task/status", function(req) -- 812
	do -- 813
		local _type_0 = type(req) -- 813
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 813
		if _tab_0 then -- 813
			local sessionId -- 813
			do -- 813
				local _obj_0 = req.body -- 813
				local _type_1 = type(_obj_0) -- 813
				if "table" == _type_1 or "userdata" == _type_1 then -- 813
					sessionId = _obj_0.sessionId -- 813
				end -- 813
			end -- 813
			if sessionId ~= nil then -- 813
				local res = AgentSession.getSession(sessionId) -- 814
				if not res.success then -- 815
					return res -- 815
				end -- 815
				local taskId = res.session.currentTaskId -- 816
				local checkpoints -- 817
				if taskId then -- 817
					checkpoints = AgentTools.listCheckpoints(taskId) -- 817
				else -- 817
					checkpoints = { } -- 817
				end -- 817
				return { -- 819
					success = true, -- 819
					session = res.session, -- 820
					relatedSessions = res.relatedSessions, -- 821
					spawnInfo = res.spawnInfo, -- 822
					messages = res.messages, -- 823
					steps = res.steps, -- 824
					checkpoints = checkpoints, -- 825
					pendingQuestionnaire = res.pendingQuestionnaire, -- 826
					hasActivePlan = res.hasActivePlan -- 827
				} -- 818
			end -- 813
		end -- 813
	end -- 813
	return invalidArguments -- 812
end) -- 812
HttpServer:post("/agent/task/running", function() -- 829
	local res = AgentSession.listRunningSessions() -- 830
	if res.success and #res.sessions == 0 then -- 831
		res.sessions = nil -- 832
	end -- 831
	return res -- 833
end) -- 829
HttpServer:post("/agent/task/stop", function(req) -- 835
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
			if sessionId ~= nil then -- 836
				return AgentSession.stopSessionTask(sessionId) -- 837
			end -- 836
		end -- 836
	end -- 836
	return invalidArguments -- 835
end) -- 835
HttpServer:post("/agent/checkpoint/list", function(req) -- 839
	do -- 840
		local _type_0 = type(req) -- 840
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 840
		if _tab_0 then -- 840
			local taskId -- 840
			do -- 840
				local _obj_0 = req.body -- 840
				local _type_1 = type(_obj_0) -- 840
				if "table" == _type_1 or "userdata" == _type_1 then -- 840
					taskId = _obj_0.taskId -- 840
				end -- 840
			end -- 840
			local sessionId -- 840
			do -- 840
				local _obj_0 = req.body -- 840
				local _type_1 = type(_obj_0) -- 840
				if "table" == _type_1 or "userdata" == _type_1 then -- 840
					sessionId = _obj_0.sessionId -- 840
				end -- 840
			end -- 840
			if sessionId ~= nil then -- 840
				if not taskId and sessionId then -- 841
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 842
				end -- 841
				if not taskId then -- 843
					return { -- 843
						success = false, -- 843
						message = "task not found" -- 843
					} -- 843
				end -- 843
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 844
				if not access.success then -- 845
					return access -- 845
				end -- 845
				return { -- 847
					success = true, -- 847
					taskId = taskId, -- 848
					checkpoints = AgentTools.listCheckpoints(taskId) -- 849
				} -- 846
			end -- 840
		end -- 840
	end -- 840
	return invalidArguments -- 839
end) -- 839
HttpServer:post("/agent/checkpoint/diff", function(req) -- 851
	do -- 852
		local _type_0 = type(req) -- 852
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 852
		if _tab_0 then -- 852
			local sessionId -- 852
			do -- 852
				local _obj_0 = req.body -- 852
				local _type_1 = type(_obj_0) -- 852
				if "table" == _type_1 or "userdata" == _type_1 then -- 852
					sessionId = _obj_0.sessionId -- 852
				end -- 852
			end -- 852
			local checkpointId -- 852
			do -- 852
				local _obj_0 = req.body -- 852
				local _type_1 = type(_obj_0) -- 852
				if "table" == _type_1 or "userdata" == _type_1 then -- 852
					checkpointId = _obj_0.checkpointId -- 852
				end -- 852
			end -- 852
			if sessionId ~= nil and checkpointId ~= nil then -- 852
				if not (checkpointId > 0) then -- 853
					return { -- 853
						success = false, -- 853
						message = "invalid checkpointId" -- 853
					} -- 853
				end -- 853
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 854
				if not access.success then -- 855
					return access -- 855
				end -- 855
				return AgentTools.getCheckpointDiff(checkpointId) -- 856
			end -- 852
		end -- 852
	end -- 852
	return invalidArguments -- 851
end) -- 851
HttpServer:post("/agent/task/diff", function(req) -- 858
	do -- 859
		local _type_0 = type(req) -- 859
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 859
		if _tab_0 then -- 859
			local sessionId -- 859
			do -- 859
				local _obj_0 = req.body -- 859
				local _type_1 = type(_obj_0) -- 859
				if "table" == _type_1 or "userdata" == _type_1 then -- 859
					sessionId = _obj_0.sessionId -- 859
				end -- 859
			end -- 859
			local taskId -- 859
			do -- 859
				local _obj_0 = req.body -- 859
				local _type_1 = type(_obj_0) -- 859
				if "table" == _type_1 or "userdata" == _type_1 then -- 859
					taskId = _obj_0.taskId -- 859
				end -- 859
			end -- 859
			if sessionId ~= nil and taskId ~= nil then -- 859
				if not (taskId > 0) then -- 860
					return { -- 860
						success = false, -- 860
						message = "invalid taskId" -- 860
					} -- 860
				end -- 860
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 861
				if not access.success then -- 862
					return access -- 862
				end -- 862
				return AgentTools.getTaskChangeSetDiff(taskId) -- 863
			end -- 859
		end -- 859
	end -- 859
	return invalidArguments -- 858
end) -- 858
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 865
	do -- 866
		local _type_0 = type(req) -- 866
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 866
		if _tab_0 then -- 866
			local sessionId -- 866
			do -- 866
				local _obj_0 = req.body -- 866
				local _type_1 = type(_obj_0) -- 866
				if "table" == _type_1 or "userdata" == _type_1 then -- 866
					sessionId = _obj_0.sessionId -- 866
				end -- 866
			end -- 866
			local checkpointId -- 866
			do -- 866
				local _obj_0 = req.body -- 866
				local _type_1 = type(_obj_0) -- 866
				if "table" == _type_1 or "userdata" == _type_1 then -- 866
					checkpointId = _obj_0.checkpointId -- 866
				end -- 866
			end -- 866
			if sessionId ~= nil and checkpointId ~= nil then -- 866
				if not (checkpointId > 0) then -- 867
					return { -- 867
						success = false, -- 867
						message = "invalid checkpointId" -- 867
					} -- 867
				end -- 867
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 868
				if not access.success then -- 869
					return access -- 869
				end -- 869
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, access.session.projectRoot) -- 870
				if not rollbackRes.success then -- 871
					return rollbackRes -- 871
				end -- 871
				return { -- 873
					success = true, -- 873
					checkpointId = rollbackRes.checkpointId -- 874
				} -- 872
			end -- 866
		end -- 866
	end -- 866
	return invalidArguments -- 865
end) -- 865
HttpServer:post("/agent/task/rollback", function(req) -- 876
	do -- 877
		local _type_0 = type(req) -- 877
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 877
		if _tab_0 then -- 877
			local sessionId -- 877
			do -- 877
				local _obj_0 = req.body -- 877
				local _type_1 = type(_obj_0) -- 877
				if "table" == _type_1 or "userdata" == _type_1 then -- 877
					sessionId = _obj_0.sessionId -- 877
				end -- 877
			end -- 877
			local taskId -- 877
			do -- 877
				local _obj_0 = req.body -- 877
				local _type_1 = type(_obj_0) -- 877
				if "table" == _type_1 or "userdata" == _type_1 then -- 877
					taskId = _obj_0.taskId -- 877
				end -- 877
			end -- 877
			if sessionId ~= nil and taskId ~= nil then -- 877
				if not (taskId > 0) then -- 878
					return { -- 878
						success = false, -- 878
						message = "invalid taskId" -- 878
					} -- 878
				end -- 878
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 879
				if not access.success then -- 880
					return access -- 880
				end -- 880
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, access.session.projectRoot) -- 881
				if not rollbackRes.success then -- 882
					return rollbackRes -- 882
				end -- 882
				return { -- 884
					success = true, -- 884
					taskId = rollbackRes.taskId, -- 885
					checkpointId = rollbackRes.checkpointId, -- 886
					checkpointCount = rollbackRes.checkpointCount -- 887
				} -- 883
			end -- 877
		end -- 877
	end -- 877
	return invalidArguments -- 876
end) -- 876
local getSearchPath -- 889
getSearchPath = function(file) -- 889
	do -- 890
		local dir = getProjectDirFromFile(file) -- 890
		if dir then -- 890
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 891
		end -- 890
	end -- 890
	return "" -- 889
end -- 889
local getSearchFolders -- 893
getSearchFolders = function(file) -- 893
	do -- 894
		local dir = getProjectDirFromFile(file) -- 894
		if dir then -- 894
			return { -- 896
				Path(dir, "Script"), -- 896
				dir -- 897
			} -- 895
		end -- 894
	end -- 894
	return { } -- 893
end -- 893
local disabledCheckForLua = { -- 900
	"incompatible number of returns", -- 900
	"unknown", -- 901
	"cannot index", -- 902
	"module not found", -- 903
	"don't know how to resolve", -- 904
	"ContainerItem", -- 905
	"cannot resolve a type", -- 906
	"invalid key", -- 907
	"inconsistent index type", -- 908
	"cannot use operator", -- 909
	"attempting ipairs loop", -- 910
	"expects record or nominal", -- 911
	"variable is not being assigned", -- 912
	"<invalid type>", -- 913
	"<any type>", -- 914
	"using the '#' operator", -- 915
	"can't match a record", -- 916
	"redeclaration of variable", -- 917
	"cannot apply pairs", -- 918
	"not a function", -- 919
	"to%-be%-closed" -- 920
} -- 899
local yueCheck -- 922
yueCheck = function(file, content, lax) -- 922
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 923
	if isTIC80 then -- 924
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 925
	end -- 924
	local searchPath = getSearchPath(file) -- 926
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 927
	local info = { } -- 928
	local globals = { } -- 929
	for _index_0 = 1, #checkResult do -- 930
		local _des_0 = checkResult[_index_0] -- 930
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 930
		if "error" == t then -- 931
			info[#info + 1] = { -- 932
				"syntax", -- 932
				file, -- 932
				line, -- 932
				col, -- 932
				msg -- 932
			} -- 932
		elseif "global" == t then -- 933
			globals[#globals + 1] = { -- 934
				msg, -- 934
				line, -- 934
				col -- 934
			} -- 934
		end -- 931
	end -- 930
	if luaCodes then -- 935
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 936
		if success then -- 937
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 938
			if not (lintResult == "") then -- 939
				lintResult = lintResult .. "\n" -- 939
			end -- 939
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 940
		else -- 941
			for _index_0 = 1, #lintResult do -- 941
				local _des_0 = lintResult[_index_0] -- 941
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 941
				if isTIC80 and tic80APIs[name] then -- 942
					goto _continue_0 -- 942
				end -- 942
				info[#info + 1] = { -- 943
					"syntax", -- 943
					file, -- 943
					line, -- 943
					col, -- 943
					"invalid global variable" -- 943
				} -- 943
				::_continue_0:: -- 942
			end -- 941
		end -- 937
	end -- 935
	return luaCodes, info -- 944
end -- 922
local luaCheck -- 946
luaCheck = function(file, content) -- 946
	local res, err = load(content, "check") -- 947
	if not res then -- 948
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 949
		return { -- 950
			success = false, -- 950
			info = { -- 950
				{ -- 950
					"syntax", -- 950
					file, -- 950
					tonumber(line), -- 950
					0, -- 950
					msg -- 950
				} -- 950
			} -- 950
		} -- 950
	end -- 948
	local success, info = teal.checkAsync(content, file, true, "") -- 951
	if info then -- 952
		do -- 953
			local _accum_0 = { } -- 953
			local _len_0 = 1 -- 953
			for _index_0 = 1, #info do -- 953
				local item = info[_index_0] -- 953
				local useCheck = true -- 954
				if not item[5]:match("unused") then -- 955
					for _index_1 = 1, #disabledCheckForLua do -- 956
						local check = disabledCheckForLua[_index_1] -- 956
						if item[5]:match(check) then -- 957
							useCheck = false -- 958
						end -- 957
					end -- 956
				end -- 955
				if not useCheck then -- 959
					goto _continue_0 -- 959
				end -- 959
				do -- 960
					local _exp_0 = item[1] -- 960
					if "type" == _exp_0 then -- 961
						item[1] = "warning" -- 962
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 963
						goto _continue_0 -- 964
					end -- 960
				end -- 960
				_accum_0[_len_0] = item -- 965
				_len_0 = _len_0 + 1 -- 954
				::_continue_0:: -- 954
			end -- 953
			info = _accum_0 -- 953
		end -- 953
		if #info == 0 then -- 966
			info = nil -- 967
			success = true -- 968
		end -- 966
	end -- 952
	return { -- 969
		success = success, -- 969
		info = info -- 969
	} -- 969
end -- 946
local luaCheckWithLineInfo -- 971
luaCheckWithLineInfo = function(file, luaCodes) -- 971
	local res = luaCheck(file, luaCodes) -- 972
	local info = { } -- 973
	if not res.success then -- 974
		local current = 1 -- 975
		local lastLine = 1 -- 976
		local lineMap = { } -- 977
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 978
			local num = lineCode:match("--%s*(%d+)%s*$") -- 979
			if num then -- 980
				lastLine = tonumber(num) -- 981
			end -- 980
			lineMap[current] = lastLine -- 982
			current = current + 1 -- 983
		end -- 978
		local _list_0 = res.info -- 984
		for _index_0 = 1, #_list_0 do -- 984
			local item = _list_0[_index_0] -- 984
			item[3] = lineMap[item[3]] or 0 -- 985
			item[4] = 0 -- 986
			info[#info + 1] = item -- 987
		end -- 984
		return false, info -- 988
	end -- 974
	return true, info -- 989
end -- 971
local getCompiledYueLine -- 991
getCompiledYueLine = function(content, line, row, file, lax) -- 991
	local luaCodes = yueCheck(file, content, lax) -- 992
	if not luaCodes then -- 993
		return nil -- 993
	end -- 993
	local current = 1 -- 994
	local lastLine = 1 -- 995
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 996
	local targetRow = nil -- 997
	local lineMap = { } -- 998
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 999
		local num = lineCode:match("--%s*(%d+)%s*$") -- 1000
		if num then -- 1001
			lastLine = tonumber(num) -- 1001
		end -- 1001
		lineMap[current] = lastLine -- 1002
		if row <= lastLine and not targetRow then -- 1003
			targetRow = current -- 1004
			break -- 1005
		end -- 1003
		current = current + 1 -- 1006
	end -- 999
	targetRow = current -- 1007
	if targetLine and targetRow then -- 1008
		return luaCodes, targetLine, targetRow, lineMap -- 1009
	else -- 1011
		return nil -- 1011
	end -- 1008
end -- 991
HttpServer:postSchedule("/check", function(req) -- 1013
	do -- 1014
		local _type_0 = type(req) -- 1014
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1014
		if _tab_0 then -- 1014
			local file -- 1014
			do -- 1014
				local _obj_0 = req.body -- 1014
				local _type_1 = type(_obj_0) -- 1014
				if "table" == _type_1 or "userdata" == _type_1 then -- 1014
					file = _obj_0.file -- 1014
				end -- 1014
			end -- 1014
			local content -- 1014
			do -- 1014
				local _obj_0 = req.body -- 1014
				local _type_1 = type(_obj_0) -- 1014
				if "table" == _type_1 or "userdata" == _type_1 then -- 1014
					content = _obj_0.content -- 1014
				end -- 1014
			end -- 1014
			if file ~= nil and content ~= nil then -- 1014
				local ext = Path:getExt(file) -- 1015
				if "tl" == ext then -- 1016
					local searchPath = getSearchPath(file) -- 1017
					do -- 1018
						local isTIC80 = CheckTIC80Code(content) -- 1018
						if isTIC80 then -- 1018
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1019
						end -- 1018
					end -- 1018
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 1020
					return { -- 1021
						success = success, -- 1021
						info = info -- 1021
					} -- 1021
				elseif "lua" == ext then -- 1022
					do -- 1023
						local isTIC80 = CheckTIC80Code(content) -- 1023
						if isTIC80 then -- 1023
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1024
						end -- 1023
					end -- 1023
					return luaCheck(file, content) -- 1025
				elseif "yue" == ext then -- 1026
					local luaCodes, info = yueCheck(file, content, false) -- 1027
					local success = luaCodes ~= nil -- 1028
					if luaCodes then -- 1029
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 1030
						do -- 1031
							local _tab_1 = { } -- 1031
							local _idx_0 = #_tab_1 + 1 -- 1031
							for _index_0 = 1, #info do -- 1031
								local _value_0 = info[_index_0] -- 1031
								_tab_1[_idx_0] = _value_0 -- 1031
								_idx_0 = _idx_0 + 1 -- 1031
							end -- 1031
							local _idx_1 = #_tab_1 + 1 -- 1031
							for _index_0 = 1, #luaInfo do -- 1031
								local _value_0 = luaInfo[_index_0] -- 1031
								_tab_1[_idx_1] = _value_0 -- 1031
								_idx_1 = _idx_1 + 1 -- 1031
							end -- 1031
							info = _tab_1 -- 1031
						end -- 1031
						success = success and luaSuccess -- 1032
					end -- 1029
					if #info > 0 then -- 1033
						return { -- 1034
							success = success, -- 1034
							info = info -- 1034
						} -- 1034
					else -- 1036
						return { -- 1036
							success = success -- 1036
						} -- 1036
					end -- 1033
				elseif "xml" == ext then -- 1037
					local success, result = xml.check(content) -- 1038
					if success then -- 1039
						local info -- 1040
						success, info = luaCheckWithLineInfo(file, result) -- 1040
						if #info > 0 then -- 1041
							return { -- 1042
								success = success, -- 1042
								info = info -- 1042
							} -- 1042
						else -- 1044
							return { -- 1044
								success = success -- 1044
							} -- 1044
						end -- 1041
					else -- 1046
						local info -- 1046
						do -- 1046
							local _accum_0 = { } -- 1046
							local _len_0 = 1 -- 1046
							for _index_0 = 1, #result do -- 1046
								local _des_0 = result[_index_0] -- 1046
								local row, err = _des_0[1], _des_0[2] -- 1046
								_accum_0[_len_0] = { -- 1047
									"syntax", -- 1047
									file, -- 1047
									row, -- 1047
									0, -- 1047
									err -- 1047
								} -- 1047
								_len_0 = _len_0 + 1 -- 1047
							end -- 1046
							info = _accum_0 -- 1046
						end -- 1046
						return { -- 1048
							success = false, -- 1048
							info = info -- 1048
						} -- 1048
					end -- 1039
				end -- 1016
			end -- 1014
		end -- 1014
	end -- 1014
	return { -- 1013
		success = true -- 1013
	} -- 1013
end) -- 1013
HttpServer:post("/body/parse", function(req) -- 1050
	do -- 1051
		local _type_0 = type(req) -- 1051
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1051
		if _tab_0 then -- 1051
			local file -- 1051
			do -- 1051
				local _obj_0 = req.body -- 1051
				local _type_1 = type(_obj_0) -- 1051
				if "table" == _type_1 or "userdata" == _type_1 then -- 1051
					file = _obj_0.file -- 1051
				end -- 1051
			end -- 1051
			local content -- 1051
			do -- 1051
				local _obj_0 = req.body -- 1051
				local _type_1 = type(_obj_0) -- 1051
				if "table" == _type_1 or "userdata" == _type_1 then -- 1051
					content = _obj_0.content -- 1051
				end -- 1051
			end -- 1051
			if file ~= nil and content ~= nil then -- 1051
				if not (file:sub(-6) == ".b.lua") then -- 1052
					return { -- 1053
						success = false, -- 1053
						phase = "request", -- 1053
						message = "only .b.lua files can be converted" -- 1053
					} -- 1053
				end -- 1052
				local loader, err = load("_ENV = {}\n" .. content) -- 1054
				if not loader then -- 1055
					return { -- 1056
						success = false, -- 1056
						phase = "parse", -- 1056
						message = tostring(err) -- 1056
					} -- 1056
				end -- 1055
				local ok, data = pcall(loader) -- 1057
				if not ok then -- 1058
					return { -- 1059
						success = false, -- 1059
						phase = "execute", -- 1059
						message = tostring(data) -- 1059
					} -- 1059
				end -- 1058
				if not ("table" == type(data) and data[1] == "Array") then -- 1060
					return { -- 1061
						success = false, -- 1061
						phase = "validate", -- 1061
						message = "body lua root must be {\"Array\", ...}" -- 1061
					} -- 1061
				end -- 1060
				local text, jsonErr = json.encode(data, false, true) -- 1062
				if not text then -- 1063
					return { -- 1064
						success = false, -- 1064
						phase = "encode", -- 1064
						message = tostring(jsonErr) -- 1064
					} -- 1064
				end -- 1063
				return { -- 1065
					success = true, -- 1065
					json = text -- 1065
				} -- 1065
			end -- 1051
		end -- 1051
	end -- 1051
	return { -- 1050
		success = false, -- 1050
		phase = "request", -- 1050
		message = "invalid request" -- 1050
	} -- 1050
end) -- 1050
local updateInferedDesc -- 1067
updateInferedDesc = function(infered) -- 1067
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1068
		return -- 1068
	end -- 1068
	local key, row = infered.key, infered.row -- 1069
	local codes = Content:loadAsync(key) -- 1070
	if codes then -- 1070
		local comments = { } -- 1071
		local line = 0 -- 1072
		local skipping = false -- 1073
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1074
			line = line + 1 -- 1075
			if line >= row then -- 1076
				break -- 1076
			end -- 1076
			if lineCode:match("^%s*%-%- @") then -- 1077
				skipping = true -- 1078
				goto _continue_0 -- 1079
			end -- 1077
			local result = lineCode:match("^%s*%-%- (.+)") -- 1080
			if result then -- 1080
				if not skipping then -- 1081
					comments[#comments + 1] = result -- 1081
				end -- 1081
			elseif #comments > 0 then -- 1082
				comments = { } -- 1083
				skipping = false -- 1084
			end -- 1080
			::_continue_0:: -- 1075
		end -- 1074
		infered.doc = table.concat(comments, "\n") -- 1085
	end -- 1070
end -- 1067
HttpServer:postSchedule("/infer", function(req) -- 1087
	do -- 1088
		local _type_0 = type(req) -- 1088
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1088
		if _tab_0 then -- 1088
			local lang -- 1088
			do -- 1088
				local _obj_0 = req.body -- 1088
				local _type_1 = type(_obj_0) -- 1088
				if "table" == _type_1 or "userdata" == _type_1 then -- 1088
					lang = _obj_0.lang -- 1088
				end -- 1088
			end -- 1088
			local file -- 1088
			do -- 1088
				local _obj_0 = req.body -- 1088
				local _type_1 = type(_obj_0) -- 1088
				if "table" == _type_1 or "userdata" == _type_1 then -- 1088
					file = _obj_0.file -- 1088
				end -- 1088
			end -- 1088
			local content -- 1088
			do -- 1088
				local _obj_0 = req.body -- 1088
				local _type_1 = type(_obj_0) -- 1088
				if "table" == _type_1 or "userdata" == _type_1 then -- 1088
					content = _obj_0.content -- 1088
				end -- 1088
			end -- 1088
			local line -- 1088
			do -- 1088
				local _obj_0 = req.body -- 1088
				local _type_1 = type(_obj_0) -- 1088
				if "table" == _type_1 or "userdata" == _type_1 then -- 1088
					line = _obj_0.line -- 1088
				end -- 1088
			end -- 1088
			local row -- 1088
			do -- 1088
				local _obj_0 = req.body -- 1088
				local _type_1 = type(_obj_0) -- 1088
				if "table" == _type_1 or "userdata" == _type_1 then -- 1088
					row = _obj_0.row -- 1088
				end -- 1088
			end -- 1088
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1088
				local searchPath = getSearchPath(file) -- 1089
				if "tl" == lang or "lua" == lang then -- 1090
					if CheckTIC80Code(content) then -- 1091
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1092
					end -- 1091
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1093
					if (infered ~= nil) then -- 1094
						updateInferedDesc(infered) -- 1095
						return { -- 1096
							success = true, -- 1096
							infered = infered -- 1096
						} -- 1096
					end -- 1094
				elseif "yue" == lang then -- 1097
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1098
					if not luaCodes then -- 1099
						return { -- 1099
							success = false -- 1099
						} -- 1099
					end -- 1099
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1100
					if (infered ~= nil) then -- 1101
						local col -- 1102
						file, row, col = infered.file, infered.row, infered.col -- 1102
						if file == "" and row > 0 and col > 0 then -- 1103
							infered.row = lineMap[row] or 0 -- 1104
							infered.col = 0 -- 1105
						end -- 1103
						updateInferedDesc(infered) -- 1106
						return { -- 1107
							success = true, -- 1107
							infered = infered -- 1107
						} -- 1107
					end -- 1101
				end -- 1090
			end -- 1088
		end -- 1088
	end -- 1088
	return { -- 1087
		success = false -- 1087
	} -- 1087
end) -- 1087
local _anon_func_3 = function(doc) -- 1168
	local _accum_0 = { } -- 1168
	local _len_0 = 1 -- 1168
	local _list_0 = doc.params -- 1168
	for _index_0 = 1, #_list_0 do -- 1168
		local param = _list_0[_index_0] -- 1168
		_accum_0[_len_0] = param.name -- 1168
		_len_0 = _len_0 + 1 -- 1168
	end -- 1168
	return _accum_0 -- 1168
end -- 1168
local getParamDocs -- 1109
getParamDocs = function(signatures) -- 1109
	if not (signatures and #signatures > 0) then -- 1110
		return nil -- 1110
	end -- 1110
	local docs = { } -- 1111
	do -- 1112
		local codes = Content:loadAsync(signatures[1].file) -- 1112
		if codes then -- 1112
			local comments = { } -- 1113
			local params = { } -- 1114
			local line = 0 -- 1115
			local returnType = nil -- 1116
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1117
				line = line + 1 -- 1118
				local needBreak = true -- 1119
				for i, _des_0 in ipairs(signatures) do -- 1120
					local row = _des_0.row -- 1120
					if line >= row and not (docs[i] ~= nil) then -- 1121
						if #comments > 0 or #params > 0 or returnType then -- 1122
							docs[i] = { -- 1124
								doc = table.concat(comments, "  \n"), -- 1124
								returnType = returnType -- 1125
							} -- 1123
							if #params > 0 then -- 1127
								docs[i].params = params -- 1127
							end -- 1127
						else -- 1129
							docs[i] = false -- 1129
						end -- 1122
					end -- 1121
					if not docs[i] then -- 1130
						needBreak = false -- 1130
					end -- 1130
				end -- 1120
				if needBreak then -- 1131
					break -- 1131
				end -- 1131
				local result = lineCode:match("%s*%-%- (.+)") -- 1132
				if result then -- 1132
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1133
					if not name then -- 1134
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1135
					end -- 1134
					if name then -- 1136
						local pname = name -- 1137
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1138
							pname = pname .. "?" -- 1138
						end -- 1138
						params[#params + 1] = { -- 1140
							name = tostring(pname) .. ": " .. tostring(typ), -- 1140
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1141
						} -- 1139
					else -- 1144
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1144
						if typ then -- 1144
							if returnType then -- 1145
								returnType = returnType .. ", " .. typ -- 1146
							else -- 1148
								returnType = typ -- 1148
							end -- 1145
							result = result:gsub("@return", "**return:**") -- 1149
						end -- 1144
						comments[#comments + 1] = result -- 1150
					end -- 1136
				elseif #comments > 0 then -- 1151
					comments = { } -- 1152
					params = { } -- 1153
					returnType = nil -- 1154
				end -- 1132
			end -- 1117
		end -- 1112
	end -- 1112
	local results = { } -- 1155
	for i, signature in ipairs(signatures) do -- 1156
		local item = { -- 1158
			desc = signature.desc, -- 1158
			doc = "", -- 1159
			file = signature.file, -- 1160
			row = signature.row, -- 1161
			col = signature.col -- 1162
		} -- 1157
		do -- 1164
			local doc = docs[i] -- 1164
			if doc then -- 1164
				item.doc = doc.doc -- 1165
				if doc.params then -- 1166
					item.params = doc.params -- 1167
					item.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1168
				elseif doc.returnType then -- 1169
					item.desc = "function()" -- 1170
				end -- 1166
				if doc.returnType then -- 1171
					item.desc = item.desc .. ": " .. tostring(doc.returnType) -- 1171
				end -- 1171
			end -- 1164
		end -- 1164
		results[#results + 1] = item -- 1172
	end -- 1156
	return results -- 1173
end -- 1109
HttpServer:postSchedule("/signature", function(req) -- 1175
	do -- 1176
		local _type_0 = type(req) -- 1176
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1176
		if _tab_0 then -- 1176
			local lang -- 1176
			do -- 1176
				local _obj_0 = req.body -- 1176
				local _type_1 = type(_obj_0) -- 1176
				if "table" == _type_1 or "userdata" == _type_1 then -- 1176
					lang = _obj_0.lang -- 1176
				end -- 1176
			end -- 1176
			local file -- 1176
			do -- 1176
				local _obj_0 = req.body -- 1176
				local _type_1 = type(_obj_0) -- 1176
				if "table" == _type_1 or "userdata" == _type_1 then -- 1176
					file = _obj_0.file -- 1176
				end -- 1176
			end -- 1176
			local content -- 1176
			do -- 1176
				local _obj_0 = req.body -- 1176
				local _type_1 = type(_obj_0) -- 1176
				if "table" == _type_1 or "userdata" == _type_1 then -- 1176
					content = _obj_0.content -- 1176
				end -- 1176
			end -- 1176
			local line -- 1176
			do -- 1176
				local _obj_0 = req.body -- 1176
				local _type_1 = type(_obj_0) -- 1176
				if "table" == _type_1 or "userdata" == _type_1 then -- 1176
					line = _obj_0.line -- 1176
				end -- 1176
			end -- 1176
			local row -- 1176
			do -- 1176
				local _obj_0 = req.body -- 1176
				local _type_1 = type(_obj_0) -- 1176
				if "table" == _type_1 or "userdata" == _type_1 then -- 1176
					row = _obj_0.row -- 1176
				end -- 1176
			end -- 1176
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1176
				local searchPath = getSearchPath(file) -- 1177
				if "tl" == lang or "lua" == lang then -- 1178
					if CheckTIC80Code(content) then -- 1179
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1180
					end -- 1179
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1181
					if signatures then -- 1181
						signatures = getParamDocs(signatures) -- 1182
						if signatures then -- 1182
							return { -- 1183
								success = true, -- 1183
								signatures = signatures -- 1183
							} -- 1183
						end -- 1182
					end -- 1181
				elseif "yue" == lang then -- 1184
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1185
					if not luaCodes then -- 1186
						return { -- 1186
							success = false -- 1186
						} -- 1186
					end -- 1186
					do -- 1187
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1187
						if chainOp then -- 1187
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1188
							if withVar then -- 1188
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1189
							end -- 1188
						end -- 1187
					end -- 1187
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1190
					if signatures then -- 1190
						signatures = getParamDocs(signatures) -- 1191
						if signatures then -- 1191
							return { -- 1192
								success = true, -- 1192
								signatures = signatures -- 1192
							} -- 1192
						end -- 1191
					else -- 1193
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1193
						if signatures then -- 1193
							signatures = getParamDocs(signatures) -- 1194
							if signatures then -- 1194
								return { -- 1195
									success = true, -- 1195
									signatures = signatures -- 1195
								} -- 1195
							end -- 1194
						end -- 1193
					end -- 1190
				end -- 1178
			end -- 1176
		end -- 1176
	end -- 1176
	return { -- 1175
		success = false -- 1175
	} -- 1175
end) -- 1175
local luaKeywords = { -- 1198
	'and', -- 1198
	'break', -- 1199
	'do', -- 1200
	'else', -- 1201
	'elseif', -- 1202
	'end', -- 1203
	'false', -- 1204
	'for', -- 1205
	'function', -- 1206
	'goto', -- 1207
	'if', -- 1208
	'in', -- 1209
	'local', -- 1210
	'nil', -- 1211
	'not', -- 1212
	'or', -- 1213
	'repeat', -- 1214
	'return', -- 1215
	'then', -- 1216
	'true', -- 1217
	'until', -- 1218
	'while' -- 1219
} -- 1197
local tealKeywords = { -- 1223
	'record', -- 1223
	'as', -- 1224
	'is', -- 1225
	'type', -- 1226
	'embed', -- 1227
	'enum', -- 1228
	'global', -- 1229
	'any', -- 1230
	'boolean', -- 1231
	'integer', -- 1232
	'number', -- 1233
	'string', -- 1234
	'thread' -- 1235
} -- 1222
local yueKeywords = { -- 1239
	"and", -- 1239
	"break", -- 1240
	"do", -- 1241
	"else", -- 1242
	"elseif", -- 1243
	"false", -- 1244
	"for", -- 1245
	"goto", -- 1246
	"if", -- 1247
	"in", -- 1248
	"local", -- 1249
	"nil", -- 1250
	"not", -- 1251
	"or", -- 1252
	"repeat", -- 1253
	"return", -- 1254
	"then", -- 1255
	"true", -- 1256
	"until", -- 1257
	"while", -- 1258
	"as", -- 1259
	"class", -- 1260
	"continue", -- 1261
	"export", -- 1262
	"extends", -- 1263
	"from", -- 1264
	"global", -- 1265
	"import", -- 1266
	"macro", -- 1267
	"switch", -- 1268
	"try", -- 1269
	"unless", -- 1270
	"using", -- 1271
	"when", -- 1272
	"with" -- 1273
} -- 1238
local _anon_func_4 = function(f) -- 1309
	local _val_0 = Path:getExt(f) -- 1309
	return "ttf" == _val_0 or "otf" == _val_0 -- 1309
end -- 1309
local _anon_func_5 = function(suggestions) -- 1335
	local _tbl_0 = { } -- 1335
	for _index_0 = 1, #suggestions do -- 1335
		local item = suggestions[_index_0] -- 1335
		_tbl_0[item[1] .. item[2]] = item -- 1335
	end -- 1335
	return _tbl_0 -- 1335
end -- 1335
HttpServer:postSchedule("/complete", function(req) -- 1276
	do -- 1277
		local _type_0 = type(req) -- 1277
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1277
		if _tab_0 then -- 1277
			local lang -- 1277
			do -- 1277
				local _obj_0 = req.body -- 1277
				local _type_1 = type(_obj_0) -- 1277
				if "table" == _type_1 or "userdata" == _type_1 then -- 1277
					lang = _obj_0.lang -- 1277
				end -- 1277
			end -- 1277
			local file -- 1277
			do -- 1277
				local _obj_0 = req.body -- 1277
				local _type_1 = type(_obj_0) -- 1277
				if "table" == _type_1 or "userdata" == _type_1 then -- 1277
					file = _obj_0.file -- 1277
				end -- 1277
			end -- 1277
			local content -- 1277
			do -- 1277
				local _obj_0 = req.body -- 1277
				local _type_1 = type(_obj_0) -- 1277
				if "table" == _type_1 or "userdata" == _type_1 then -- 1277
					content = _obj_0.content -- 1277
				end -- 1277
			end -- 1277
			local line -- 1277
			do -- 1277
				local _obj_0 = req.body -- 1277
				local _type_1 = type(_obj_0) -- 1277
				if "table" == _type_1 or "userdata" == _type_1 then -- 1277
					line = _obj_0.line -- 1277
				end -- 1277
			end -- 1277
			local row -- 1277
			do -- 1277
				local _obj_0 = req.body -- 1277
				local _type_1 = type(_obj_0) -- 1277
				if "table" == _type_1 or "userdata" == _type_1 then -- 1277
					row = _obj_0.row -- 1277
				end -- 1277
			end -- 1277
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1277
				local searchPath = getSearchPath(file) -- 1278
				repeat -- 1279
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1280
					if lang == "yue" then -- 1281
						if not item then -- 1282
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1282
						end -- 1282
						if not item then -- 1283
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1283
						end -- 1283
					end -- 1281
					local searchType = nil -- 1284
					if not item then -- 1285
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1286
						if lang == "yue" then -- 1287
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1288
						end -- 1287
						if (item ~= nil) then -- 1289
							searchType = "Image" -- 1289
						end -- 1289
					end -- 1285
					if not item then -- 1290
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1291
						if lang == "yue" then -- 1292
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1293
						end -- 1292
						if (item ~= nil) then -- 1294
							searchType = "Font" -- 1294
						end -- 1294
					end -- 1290
					if not item then -- 1295
						break -- 1295
					end -- 1295
					local searchPaths = Content.searchPaths -- 1296
					local _list_0 = getSearchFolders(file) -- 1297
					for _index_0 = 1, #_list_0 do -- 1297
						local folder = _list_0[_index_0] -- 1297
						searchPaths[#searchPaths + 1] = folder -- 1298
					end -- 1297
					if searchType then -- 1299
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1299
					end -- 1299
					local tokens -- 1300
					do -- 1300
						local _accum_0 = { } -- 1300
						local _len_0 = 1 -- 1300
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1300
							_accum_0[_len_0] = mod -- 1300
							_len_0 = _len_0 + 1 -- 1300
						end -- 1300
						tokens = _accum_0 -- 1300
					end -- 1300
					local suggestions = { } -- 1301
					for _index_0 = 1, #searchPaths do -- 1302
						local path = searchPaths[_index_0] -- 1302
						local sPath = Path(path, table.unpack(tokens)) -- 1303
						if not Content:exist(sPath) then -- 1304
							goto _continue_0 -- 1304
						end -- 1304
						if searchType == "Font" then -- 1305
							local fontPath = Path(sPath, "Font") -- 1306
							if Content:exist(fontPath) then -- 1307
								local _list_1 = Content:getFiles(fontPath) -- 1308
								for _index_1 = 1, #_list_1 do -- 1308
									local f = _list_1[_index_1] -- 1308
									if _anon_func_4(f) then -- 1309
										if "." == f:sub(1, 1) then -- 1310
											goto _continue_1 -- 1310
										end -- 1310
										suggestions[#suggestions + 1] = { -- 1311
											Path:getName(f), -- 1311
											"font", -- 1311
											"field" -- 1311
										} -- 1311
									end -- 1309
									::_continue_1:: -- 1309
								end -- 1308
							end -- 1307
						end -- 1305
						local _list_1 = Content:getFiles(sPath) -- 1312
						for _index_1 = 1, #_list_1 do -- 1312
							local f = _list_1[_index_1] -- 1312
							if "Image" == searchType then -- 1313
								do -- 1314
									local _exp_0 = Path:getExt(f) -- 1314
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1314
										if "." == f:sub(1, 1) then -- 1315
											goto _continue_2 -- 1315
										end -- 1315
										suggestions[#suggestions + 1] = { -- 1316
											f, -- 1316
											"image", -- 1316
											"field" -- 1316
										} -- 1316
									end -- 1314
								end -- 1314
								goto _continue_2 -- 1317
							elseif "Font" == searchType then -- 1318
								do -- 1319
									local _exp_0 = Path:getExt(f) -- 1319
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1319
										if "." == f:sub(1, 1) then -- 1320
											goto _continue_2 -- 1320
										end -- 1320
										suggestions[#suggestions + 1] = { -- 1321
											f, -- 1321
											"font", -- 1321
											"field" -- 1321
										} -- 1321
									end -- 1319
								end -- 1319
								goto _continue_2 -- 1322
							end -- 1313
							local _exp_0 = Path:getExt(f) -- 1323
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1323
								local name = Path:getName(f) -- 1324
								if "d" == Path:getExt(name) then -- 1325
									goto _continue_2 -- 1325
								end -- 1325
								if "." == name:sub(1, 1) then -- 1326
									goto _continue_2 -- 1326
								end -- 1326
								suggestions[#suggestions + 1] = { -- 1327
									name, -- 1327
									"module", -- 1327
									"field" -- 1327
								} -- 1327
							end -- 1323
							::_continue_2:: -- 1313
						end -- 1312
						local _list_2 = Content:getDirs(sPath) -- 1328
						for _index_1 = 1, #_list_2 do -- 1328
							local dir = _list_2[_index_1] -- 1328
							if "." == dir:sub(1, 1) then -- 1329
								goto _continue_3 -- 1329
							end -- 1329
							suggestions[#suggestions + 1] = { -- 1330
								dir, -- 1330
								"folder", -- 1330
								"variable" -- 1330
							} -- 1330
							::_continue_3:: -- 1329
						end -- 1328
						::_continue_0:: -- 1303
					end -- 1302
					if item == "" and not searchType then -- 1331
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1332
						for _index_0 = 1, #_list_1 do -- 1332
							local _des_0 = _list_1[_index_0] -- 1332
							local name = _des_0[1] -- 1332
							suggestions[#suggestions + 1] = { -- 1333
								name, -- 1333
								"dora module", -- 1333
								"function" -- 1333
							} -- 1333
						end -- 1332
					end -- 1331
					if #suggestions > 0 then -- 1334
						do -- 1335
							local _accum_0 = { } -- 1335
							local _len_0 = 1 -- 1335
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1335
								_accum_0[_len_0] = v -- 1335
								_len_0 = _len_0 + 1 -- 1335
							end -- 1335
							suggestions = _accum_0 -- 1335
						end -- 1335
						return { -- 1336
							success = true, -- 1336
							suggestions = suggestions -- 1336
						} -- 1336
					else -- 1338
						return { -- 1338
							success = false -- 1338
						} -- 1338
					end -- 1334
				until true -- 1279
				if "tl" == lang or "lua" == lang then -- 1340
					do -- 1341
						local isTIC80 = CheckTIC80Code(content) -- 1341
						if isTIC80 then -- 1341
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1342
						end -- 1341
					end -- 1341
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1343
					if not line:match("[%.:]$") then -- 1344
						local checkSet -- 1345
						do -- 1345
							local _tbl_0 = { } -- 1345
							for _index_0 = 1, #suggestions do -- 1345
								local _des_0 = suggestions[_index_0] -- 1345
								local name = _des_0[1] -- 1345
								_tbl_0[name] = true -- 1345
							end -- 1345
							checkSet = _tbl_0 -- 1345
						end -- 1345
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1346
						for _index_0 = 1, #_list_0 do -- 1346
							local item = _list_0[_index_0] -- 1346
							if not checkSet[item[1]] then -- 1347
								suggestions[#suggestions + 1] = item -- 1347
							end -- 1347
						end -- 1346
						for _index_0 = 1, #luaKeywords do -- 1348
							local word = luaKeywords[_index_0] -- 1348
							suggestions[#suggestions + 1] = { -- 1349
								word, -- 1349
								"keyword", -- 1349
								"keyword" -- 1349
							} -- 1349
						end -- 1348
						if lang == "tl" then -- 1350
							for _index_0 = 1, #tealKeywords do -- 1351
								local word = tealKeywords[_index_0] -- 1351
								suggestions[#suggestions + 1] = { -- 1352
									word, -- 1352
									"keyword", -- 1352
									"keyword" -- 1352
								} -- 1352
							end -- 1351
						end -- 1350
					end -- 1344
					if #suggestions > 0 then -- 1353
						return { -- 1354
							success = true, -- 1354
							suggestions = suggestions -- 1354
						} -- 1354
					end -- 1353
				elseif "yue" == lang then -- 1355
					local suggestions = { } -- 1356
					local gotGlobals = false -- 1357
					do -- 1358
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1358
						if luaCodes then -- 1358
							gotGlobals = true -- 1359
							do -- 1360
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1360
								if chainOp then -- 1360
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1361
									if not withVar then -- 1362
										return { -- 1362
											success = false -- 1362
										} -- 1362
									end -- 1362
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1363
								elseif line:match("^([%.\\])$") then -- 1364
									return { -- 1365
										success = false -- 1365
									} -- 1365
								end -- 1360
							end -- 1360
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1366
							for _index_0 = 1, #_list_0 do -- 1366
								local item = _list_0[_index_0] -- 1366
								suggestions[#suggestions + 1] = item -- 1366
							end -- 1366
							if #suggestions == 0 then -- 1367
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1368
								for _index_0 = 1, #_list_1 do -- 1368
									local item = _list_1[_index_0] -- 1368
									suggestions[#suggestions + 1] = item -- 1368
								end -- 1368
							end -- 1367
						end -- 1358
					end -- 1358
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1369
						local checkSet -- 1370
						do -- 1370
							local _tbl_0 = { } -- 1370
							for _index_0 = 1, #suggestions do -- 1370
								local _des_0 = suggestions[_index_0] -- 1370
								local name = _des_0[1] -- 1370
								_tbl_0[name] = true -- 1370
							end -- 1370
							checkSet = _tbl_0 -- 1370
						end -- 1370
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1371
						for _index_0 = 1, #_list_0 do -- 1371
							local item = _list_0[_index_0] -- 1371
							if not checkSet[item[1]] then -- 1372
								suggestions[#suggestions + 1] = item -- 1372
							end -- 1372
						end -- 1371
						if not gotGlobals then -- 1373
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1374
							for _index_0 = 1, #_list_1 do -- 1374
								local item = _list_1[_index_0] -- 1374
								if not checkSet[item[1]] then -- 1375
									suggestions[#suggestions + 1] = item -- 1375
								end -- 1375
							end -- 1374
						end -- 1373
						for _index_0 = 1, #yueKeywords do -- 1376
							local word = yueKeywords[_index_0] -- 1376
							if not checkSet[word] then -- 1377
								suggestions[#suggestions + 1] = { -- 1378
									word, -- 1378
									"keyword", -- 1378
									"keyword" -- 1378
								} -- 1378
							end -- 1377
						end -- 1376
					end -- 1369
					if #suggestions > 0 then -- 1379
						return { -- 1380
							success = true, -- 1380
							suggestions = suggestions -- 1380
						} -- 1380
					end -- 1379
				elseif "xml" == lang then -- 1381
					local items = xml.complete(content) -- 1382
					if #items > 0 then -- 1383
						local suggestions -- 1384
						do -- 1384
							local _accum_0 = { } -- 1384
							local _len_0 = 1 -- 1384
							for _index_0 = 1, #items do -- 1384
								local _des_0 = items[_index_0] -- 1384
								local label, insertText = _des_0[1], _des_0[2] -- 1384
								_accum_0[_len_0] = { -- 1385
									label, -- 1385
									insertText, -- 1385
									"field" -- 1385
								} -- 1385
								_len_0 = _len_0 + 1 -- 1385
							end -- 1384
							suggestions = _accum_0 -- 1384
						end -- 1384
						return { -- 1386
							success = true, -- 1386
							suggestions = suggestions -- 1386
						} -- 1386
					end -- 1383
				end -- 1340
			end -- 1277
		end -- 1277
	end -- 1277
	return { -- 1276
		success = false -- 1276
	} -- 1276
end) -- 1276
local getUploadFilename -- 1388
getUploadFilename = function(req, multipartFilename) -- 1388
	local filename = req.params.name -- 1389
	if not (type(filename) == "string" and filename ~= "") then -- 1390
		filename = multipartFilename -- 1390
	end -- 1390
	if not (type(filename) == "string" and filename ~= "") then -- 1391
		return -- 1391
	end -- 1391
	if filename:sub(1, 1) == "/" or filename:sub(-1) == "/" or filename:find("//", 1, true) or filename:find("\\", 1, true) or filename:find(":", 1, true) or filename:find("\0", 1, true) then -- 1394
		return -- 1394
	end -- 1394
	local parts -- 1395
	do -- 1395
		local _accum_0 = { } -- 1395
		local _len_0 = 1 -- 1395
		for part in filename:gmatch("[^/]+") do -- 1395
			_accum_0[_len_0] = part -- 1395
			_len_0 = _len_0 + 1 -- 1395
		end -- 1395
		parts = _accum_0 -- 1395
	end -- 1395
	if #parts == 0 then -- 1396
		return -- 1396
	end -- 1396
	for _index_0 = 1, #parts do -- 1397
		local part = parts[_index_0] -- 1397
		if part == "." or part == ".." or part == "" then -- 1398
			return -- 1398
		end -- 1398
	end -- 1397
	return filename -- 1399
end -- 1388
HttpServer:upload("/upload", function(req, multipartFilename) -- 1403
	do -- 1404
		local _type_0 = type(req) -- 1404
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1404
		if _tab_0 then -- 1404
			local path -- 1404
			do -- 1404
				local _obj_0 = req.params -- 1404
				local _type_1 = type(_obj_0) -- 1404
				if "table" == _type_1 or "userdata" == _type_1 then -- 1404
					path = _obj_0.path -- 1404
				end -- 1404
			end -- 1404
			if path ~= nil then -- 1404
				local filename = getUploadFilename(req, multipartFilename) -- 1405
				if filename then -- 1405
					local uploadPath = Path(Content.writablePath, ".upload") -- 1406
					if not Content:exist(uploadPath) then -- 1407
						Content:mkdir(uploadPath) -- 1408
					end -- 1407
					local targetPath = Path(uploadPath, filename) -- 1409
					Content:mkdir(Path:getPath(targetPath)) -- 1410
					return targetPath -- 1411
				end -- 1405
			end -- 1404
		end -- 1404
	end -- 1404
	return nil -- 1403
end, function(req, file) -- 1412
	do -- 1413
		local _type_0 = type(req) -- 1413
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1413
		if _tab_0 then -- 1413
			local path -- 1413
			do -- 1413
				local _obj_0 = req.params -- 1413
				local _type_1 = type(_obj_0) -- 1413
				if "table" == _type_1 or "userdata" == _type_1 then -- 1413
					path = _obj_0.path -- 1413
				end -- 1413
			end -- 1413
			if path ~= nil then -- 1413
				path = Path(Content.writablePath, path) -- 1414
				if Content:exist(path) then -- 1415
					local uploadPath = Path(Content.writablePath, ".upload") -- 1416
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1417
					Content:mkdir(Path:getPath(targetPath)) -- 1418
					if Content:move(file, targetPath) then -- 1419
						return true -- 1420
					end -- 1419
				end -- 1415
			end -- 1413
		end -- 1413
	end -- 1413
	return false -- 1412
end) -- 1401
HttpServer:post("/list", function(req) -- 1423
	do -- 1424
		local _type_0 = type(req) -- 1424
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1424
		if _tab_0 then -- 1424
			local path -- 1424
			do -- 1424
				local _obj_0 = req.body -- 1424
				local _type_1 = type(_obj_0) -- 1424
				if "table" == _type_1 or "userdata" == _type_1 then -- 1424
					path = _obj_0.path -- 1424
				end -- 1424
			end -- 1424
			if path ~= nil then -- 1424
				if Content:exist(path) then -- 1425
					local files = { } -- 1426
					local visitAssets -- 1427
					visitAssets = function(path, folder) -- 1427
						local dirs = Content:getDirs(path) -- 1428
						for _index_0 = 1, #dirs do -- 1429
							local dir = dirs[_index_0] -- 1429
							if dir:match("^%.") or dir == "node_modules" then -- 1430
								goto _continue_0 -- 1430
							end -- 1430
							local current -- 1431
							if folder == "" then -- 1431
								current = dir -- 1432
							else -- 1434
								current = Path(folder, dir) -- 1434
							end -- 1431
							files[#files + 1] = current -- 1435
							visitAssets(Path(path, dir), current) -- 1436
							::_continue_0:: -- 1430
						end -- 1429
						local fs = Content:getFiles(path) -- 1437
						for _index_0 = 1, #fs do -- 1438
							local f = fs[_index_0] -- 1438
							if (".DS_Store" == f) then -- 1439
								goto _continue_1 -- 1440
							end -- 1439
							if folder == "" then -- 1441
								files[#files + 1] = f -- 1442
							else -- 1444
								files[#files + 1] = Path(folder, f) -- 1444
							end -- 1441
							::_continue_1:: -- 1439
						end -- 1438
					end -- 1427
					visitAssets(path, "") -- 1445
					if #files == 0 then -- 1446
						files = nil -- 1446
					end -- 1446
					return { -- 1447
						success = true, -- 1447
						files = files -- 1447
					} -- 1447
				end -- 1425
			end -- 1424
		end -- 1424
	end -- 1424
	return { -- 1423
		success = false -- 1423
	} -- 1423
end) -- 1423
HttpServer:post("/info", function(req) -- 1449
	local Entry = require("Script.Dev.Entry") -- 1450
	local config = Entry.getConfig() -- 1451
	do -- 1452
		local _type_0 = type(req) -- 1452
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1452
		if _tab_0 then -- 1452
			local webIDETourCompleted -- 1452
			do -- 1452
				local _obj_0 = req.body -- 1452
				local _type_1 = type(_obj_0) -- 1452
				if "table" == _type_1 or "userdata" == _type_1 then -- 1452
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1452
				end -- 1452
			end -- 1452
			if webIDETourCompleted ~= nil then -- 1452
				config.webIDETourCompleted = webIDETourCompleted == true -- 1453
			end -- 1452
		end -- 1452
	end -- 1452
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1454
	local engineDev = Entry.getEngineDev() -- 1455
	Entry.connectWebIDE() -- 1456
	return { -- 1458
		platform = App.platform, -- 1458
		locale = App.locale, -- 1459
		version = App.version, -- 1460
		engineDev = engineDev, -- 1461
		webProfiler = webProfiler, -- 1462
		drawerWidth = drawerWidth, -- 1463
		webIDETourCompleted = webIDETourCompleted == true -- 1464
	} -- 1457
end) -- 1449
local ensureLLMConfigTable -- 1466
ensureLLMConfigTable = function() -- 1466
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1467
	if columns and #columns > 0 then -- 1468
		local expected = { -- 1470
			id = true, -- 1470
			name = true, -- 1471
			url = true, -- 1472
			model = true, -- 1473
			api_key = true, -- 1474
			context_window = true, -- 1475
			temperature = true, -- 1476
			max_tokens = true, -- 1477
			reasoning_effort = true, -- 1478
			custom_options = true, -- 1479
			supports_function_calling = true, -- 1480
			active = true, -- 1481
			created_at = true, -- 1482
			updated_at = true -- 1483
		} -- 1469
		local existing = { } -- 1485
		local valid = true -- 1486
		for _index_0 = 1, #columns do -- 1487
			local row = columns[_index_0] -- 1487
			local columnName = tostring(row[2]) -- 1488
			existing[columnName] = true -- 1489
			if not expected[columnName] then -- 1490
				valid = false -- 1491
				break -- 1492
			end -- 1490
		end -- 1487
		if valid then -- 1493
			if not existing.context_window then -- 1494
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1495
			end -- 1494
			if not existing.temperature then -- 1496
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1497
			end -- 1496
			if not existing.max_tokens then -- 1498
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 64000") -- 1499
			end -- 1498
			if not existing.reasoning_effort then -- 1500
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1501
			end -- 1500
			if not existing.custom_options then -- 1502
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1503
			end -- 1502
			if not existing.supports_function_calling then -- 1504
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1505
			end -- 1504
		else -- 1507
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1507
		end -- 1493
	end -- 1468
	DB:exec([[		CREATE TABLE IF NOT EXISTS LLMConfig(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT NOT NULL,
			url TEXT NOT NULL,
			model TEXT NOT NULL,
			api_key TEXT NOT NULL,
			context_window INTEGER NOT NULL DEFAULT 64000,
			temperature REAL NOT NULL DEFAULT 0.1,
			max_tokens INTEGER NOT NULL DEFAULT 64000,
			reasoning_effort TEXT NOT NULL DEFAULT '',
			custom_options TEXT NOT NULL DEFAULT '',
			supports_function_calling INTEGER NOT NULL DEFAULT 1,
			active INTEGER NOT NULL DEFAULT 1,
			created_at INTEGER,
			updated_at INTEGER
		);
	]]) -- 1508
	return require("Agent.LLMConfigMigration").upgradeLLMConfig() -- 1527
end -- 1466
local normalizeContextWindow -- 1529
normalizeContextWindow = function(value) -- 1529
	local contextWindow = tonumber(value) -- 1530
	if contextWindow == nil or contextWindow < 64000 then -- 1531
		return 64000 -- 1532
	end -- 1531
	return math.max(64000, math.floor(contextWindow)) -- 1533
end -- 1529
local normalizeTemperature -- 1535
normalizeTemperature = function(value) -- 1535
	local temperature = tonumber(value) -- 1536
	if temperature == nil then -- 1537
		return 0.1 -- 1538
	end -- 1537
	return math.max(0, math.min(2, temperature)) -- 1539
end -- 1535
local normalizeMaxTokens -- 1541
normalizeMaxTokens = function(value) -- 1541
	local maxTokens = tonumber(value) -- 1542
	if maxTokens == nil or maxTokens < 1 then -- 1543
		return 64000 -- 1544
	end -- 1543
	return math.max(1, math.floor(maxTokens)) -- 1545
end -- 1541
local normalizeReasoningEffort -- 1547
normalizeReasoningEffort = function(value) -- 1547
	if value == nil then -- 1548
		return "" -- 1549
	end -- 1548
	local effort = tostring(value) -- 1550
	return effort:match("^%s*(.-)%s*$") or "" -- 1551
end -- 1547
local normalizeCustomOptions -- 1553
normalizeCustomOptions = function(value) -- 1553
	if value == nil then -- 1554
		return "" -- 1555
	end -- 1554
	local options = tostring(value) -- 1556
	options = options:match("^%s*(.-)%s*$") or "" -- 1557
	return options -- 1558
end -- 1553
local validateCustomOptions -- 1560
validateCustomOptions = function(value) -- 1560
	local options = normalizeCustomOptions(value) -- 1561
	if options == "" then -- 1562
		return true -- 1562
	end -- 1562
	if not options:match("^%s*{") then -- 1563
		return false -- 1563
	end -- 1563
	local decoded = json.decode(options) -- 1564
	return type(decoded) == "table" -- 1565
end -- 1560
HttpServer:post("/llm/list", function() -- 1567
	ensureLLMConfigTable() -- 1568
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1569
	local items -- 1573
	if rows and #rows > 0 then -- 1573
		local _accum_0 = { } -- 1574
		local _len_0 = 1 -- 1574
		for _index_0 = 1, #rows do -- 1574
			local _des_0 = rows[_index_0] -- 1574
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1574
			_accum_0[_len_0] = { -- 1575
				id = id, -- 1575
				name = name, -- 1575
				url = url, -- 1575
				model = model, -- 1575
				key = key, -- 1575
				contextWindow = normalizeContextWindow(contextWindow), -- 1575
				temperature = normalizeTemperature(temperature), -- 1575
				maxTokens = normalizeMaxTokens(maxTokens), -- 1575
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1575
				customOptions = normalizeCustomOptions(customOptions), -- 1575
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1575
			} -- 1575
			_len_0 = _len_0 + 1 -- 1575
		end -- 1574
		items = _accum_0 -- 1573
	end -- 1573
	return { -- 1576
		success = true, -- 1576
		items = items -- 1576
	} -- 1576
end) -- 1567
HttpServer:post("/llm/create", function(req) -- 1578
	ensureLLMConfigTable() -- 1579
	do -- 1580
		local _type_0 = type(req) -- 1580
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1580
		if _tab_0 then -- 1580
			local body = req.body -- 1580
			if body ~= nil then -- 1580
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1581
				local now = os.time() -- 1582
				if name == nil or url == nil or model == nil or key == nil then -- 1583
					return invalidArguments -- 1584
				end -- 1583
				contextWindow = normalizeContextWindow(contextWindow) -- 1585
				temperature = normalizeTemperature(temperature) -- 1586
				maxTokens = normalizeMaxTokens(maxTokens) -- 1587
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1588
				customOptions = normalizeCustomOptions(customOptions) -- 1589
				if not validateCustomOptions(customOptions) then -- 1590
					return { -- 1590
						success = false, -- 1590
						message = "customOptions must be a JSON object" -- 1590
					} -- 1590
				end -- 1590
				if supportsFunctionCalling == false then -- 1591
					supportsFunctionCalling = 0 -- 1591
				else -- 1591
					supportsFunctionCalling = 1 -- 1591
				end -- 1591
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1598
					tostring(name), -- 1598
					tostring(url), -- 1599
					tostring(model), -- 1600
					tostring(key), -- 1601
					contextWindow, -- 1602
					temperature, -- 1603
					maxTokens, -- 1604
					reasoningEffort, -- 1605
					customOptions, -- 1606
					supportsFunctionCalling, -- 1607
					1, -- 1608
					now, -- 1609
					now -- 1610
				}) -- 1592
				return { -- 1612
					success = affected >= 0 -- 1612
				} -- 1612
			end -- 1580
		end -- 1580
	end -- 1580
	return invalidArguments -- 1578
end) -- 1578
HttpServer:post("/llm/update", function(req) -- 1614
	ensureLLMConfigTable() -- 1615
	do -- 1616
		local _type_0 = type(req) -- 1616
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1616
		if _tab_0 then -- 1616
			local body = req.body -- 1616
			if body ~= nil then -- 1616
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1617
				local now = os.time() -- 1618
				id = tonumber(id) -- 1619
				if id == nil then -- 1620
					return invalidArguments -- 1620
				end -- 1620
				contextWindow = normalizeContextWindow(contextWindow) -- 1621
				temperature = normalizeTemperature(temperature) -- 1622
				maxTokens = normalizeMaxTokens(maxTokens) -- 1623
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1624
				customOptions = normalizeCustomOptions(customOptions) -- 1625
				if not validateCustomOptions(customOptions) then -- 1626
					return { -- 1626
						success = false, -- 1626
						message = "customOptions must be a JSON object" -- 1626
					} -- 1626
				end -- 1626
				if supportsFunctionCalling == false then -- 1627
					supportsFunctionCalling = 0 -- 1627
				else -- 1627
					supportsFunctionCalling = 1 -- 1627
				end -- 1627
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1632
					tostring(name), -- 1632
					tostring(url), -- 1633
					tostring(model), -- 1634
					tostring(key), -- 1635
					contextWindow, -- 1636
					temperature, -- 1637
					maxTokens, -- 1638
					reasoningEffort, -- 1639
					customOptions, -- 1640
					supportsFunctionCalling, -- 1641
					now, -- 1642
					id -- 1643
				}) -- 1628
				return { -- 1645
					success = affected >= 0 -- 1645
				} -- 1645
			end -- 1616
		end -- 1616
	end -- 1616
	return invalidArguments -- 1614
end) -- 1614
HttpServer:post("/llm/delete", function(req) -- 1647
	ensureLLMConfigTable() -- 1648
	do -- 1649
		local _type_0 = type(req) -- 1649
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1649
		if _tab_0 then -- 1649
			local id -- 1649
			do -- 1649
				local _obj_0 = req.body -- 1649
				local _type_1 = type(_obj_0) -- 1649
				if "table" == _type_1 or "userdata" == _type_1 then -- 1649
					id = _obj_0.id -- 1649
				end -- 1649
			end -- 1649
			if id ~= nil then -- 1649
				id = tonumber(id) -- 1650
				if id == nil then -- 1651
					return invalidArguments -- 1651
				end -- 1651
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1652
					id -- 1652
				}) -- 1652
				return { -- 1653
					success = affected >= 0 -- 1653
				} -- 1653
			end -- 1649
		end -- 1649
	end -- 1649
	return invalidArguments -- 1647
end) -- 1647
HttpServer:post("/local-agent/list", function() -- 1655
	return { -- 1656
		success = true, -- 1656
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1656
		items = AgentLocalAgent.listConfigs() -- 1656
	} -- 1656
end) -- 1655
HttpServer:post("/local-agent/save", function(req) -- 1658
	do -- 1659
		local _type_0 = type(req) -- 1659
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1659
		if _tab_0 then -- 1659
			local body = req.body -- 1659
			if body ~= nil then -- 1659
				return AgentLocalAgent.saveConfig(body) -- 1660
			end -- 1659
		end -- 1659
	end -- 1659
	return invalidArguments -- 1658
end) -- 1658
HttpServer:post("/local-agent/delete", function(req) -- 1662
	do -- 1663
		local _type_0 = type(req) -- 1663
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1663
		if _tab_0 then -- 1663
			local id -- 1663
			do -- 1663
				local _obj_0 = req.body -- 1663
				local _type_1 = type(_obj_0) -- 1663
				if "table" == _type_1 or "userdata" == _type_1 then -- 1663
					id = _obj_0.id -- 1663
				end -- 1663
			end -- 1663
			if id ~= nil then -- 1663
				return AgentLocalAgent.deleteConfig(id) -- 1664
			end -- 1663
		end -- 1663
	end -- 1663
	return invalidArguments -- 1662
end) -- 1662
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1666
	do -- 1667
		local _type_0 = type(req) -- 1667
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1667
		if _tab_0 then -- 1667
			local id -- 1667
			do -- 1667
				local _obj_0 = req.body -- 1667
				local _type_1 = type(_obj_0) -- 1667
				if "table" == _type_1 or "userdata" == _type_1 then -- 1667
					id = _obj_0.id -- 1667
				end -- 1667
			end -- 1667
			if id ~= nil then -- 1667
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1668
			end -- 1667
		end -- 1667
	end -- 1667
	return invalidArguments -- 1666
end) -- 1666
HttpServer:post("/stat", function(req) -- 1670
	do -- 1671
		local _type_0 = type(req) -- 1671
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1671
		if _tab_0 then -- 1671
			local path -- 1671
			do -- 1671
				local _obj_0 = req.body -- 1671
				local _type_1 = type(_obj_0) -- 1671
				if "table" == _type_1 or "userdata" == _type_1 then -- 1671
					path = _obj_0.path -- 1671
				end -- 1671
			end -- 1671
			if path ~= nil then -- 1671
				if not Content:exist(path) then -- 1672
					return { -- 1673
						success = false, -- 1673
						message = "target not existed" -- 1673
					} -- 1673
				end -- 1672
				if Content:isdir(path) then -- 1674
					return { -- 1675
						success = false, -- 1675
						message = "failed to stat a directory" -- 1675
					} -- 1675
				end -- 1674
				local size, isBinary = Content:getAttr(path) -- 1676
				if size then -- 1676
					return { -- 1677
						success = true, -- 1677
						size = size, -- 1677
						isBinary = isBinary -- 1677
					} -- 1677
				end -- 1676
			end -- 1671
		end -- 1671
	end -- 1671
	return { -- 1670
		success = false, -- 1670
		message = "failed to stat" -- 1670
	} -- 1670
end) -- 1670
HttpServer:post("/new", function(req) -- 1679
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
			local content -- 1680
			do -- 1680
				local _obj_0 = req.body -- 1680
				local _type_1 = type(_obj_0) -- 1680
				if "table" == _type_1 or "userdata" == _type_1 then -- 1680
					content = _obj_0.content -- 1680
				end -- 1680
			end -- 1680
			local folder -- 1680
			do -- 1680
				local _obj_0 = req.body -- 1680
				local _type_1 = type(_obj_0) -- 1680
				if "table" == _type_1 or "userdata" == _type_1 then -- 1680
					folder = _obj_0.folder -- 1680
				end -- 1680
			end -- 1680
			if path ~= nil and content ~= nil and folder ~= nil then -- 1680
				if Content:exist(path) then -- 1681
					return { -- 1682
						success = false, -- 1682
						message = "TargetExisted" -- 1682
					} -- 1682
				end -- 1681
				local parent = Path:getPath(path) -- 1683
				local files = Content:getFiles(parent) -- 1684
				if folder then -- 1685
					local name = Path:getFilename(path):lower() -- 1686
					for _index_0 = 1, #files do -- 1687
						local file = files[_index_0] -- 1687
						if name == Path:getFilename(file):lower() then -- 1688
							return { -- 1689
								success = false, -- 1689
								message = "TargetExisted" -- 1689
							} -- 1689
						end -- 1688
					end -- 1687
					if Content:mkdir(path) then -- 1690
						return { -- 1691
							success = true -- 1691
						} -- 1691
					end -- 1690
				else -- 1693
					local name = Path:getName(path):lower() -- 1693
					for _index_0 = 1, #files do -- 1694
						local file = files[_index_0] -- 1694
						if name == Path:getName(file):lower() then -- 1695
							local ext = Path:getExt(file) -- 1696
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1697
								goto _continue_0 -- 1698
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1699
								goto _continue_0 -- 1700
							end -- 1697
							return { -- 1701
								success = false, -- 1701
								message = "SourceExisted" -- 1701
							} -- 1701
						end -- 1695
						::_continue_0:: -- 1695
					end -- 1694
					if Content:save(path, content) then -- 1702
						return { -- 1703
							success = true -- 1703
						} -- 1703
					end -- 1702
				end -- 1685
			end -- 1680
		end -- 1680
	end -- 1680
	return { -- 1679
		success = false, -- 1679
		message = "Failed" -- 1679
	} -- 1679
end) -- 1679
local deleteAsset -- 1705
deleteAsset = function(path) -- 1705
	if not Content:exist(path) then -- 1706
		return false -- 1706
	end -- 1706
	local projectRoot -- 1707
	if Content:isdir(path) and isProjectRootDir(path) then -- 1707
		projectRoot = path -- 1707
	else -- 1707
		projectRoot = nil -- 1707
	end -- 1707
	local parent = Path:getPath(path) -- 1708
	local files = Content:getFiles(parent) -- 1709
	local name = Path:getName(path):lower() -- 1710
	local ext = Path:getExt(path) -- 1711
	for _index_0 = 1, #files do -- 1712
		local file = files[_index_0] -- 1712
		if name == Path:getName(file):lower() then -- 1713
			local _exp_0 = Path:getExt(file) -- 1714
			if "tl" == _exp_0 then -- 1714
				if ("vs" == ext) then -- 1714
					Content:remove(Path(parent, file)) -- 1715
				end -- 1714
			elseif "lua" == _exp_0 then -- 1716
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1716
					Content:remove(Path(parent, file)) -- 1717
				end -- 1716
			end -- 1714
		end -- 1713
	end -- 1712
	if Content:remove(path) then -- 1718
		if projectRoot then -- 1719
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1720
		end -- 1719
		return true -- 1721
	end -- 1718
	return false -- 1722
end -- 1705
local moveAsset -- 1724
moveAsset = function(old, new) -- 1724
	if not (Content:exist(old) and not Content:exist(new)) then -- 1725
		return false -- 1725
	end -- 1725
	local renamedDir = Content:isdir(old) -- 1726
	local parent = Path:getPath(new) -- 1727
	local files = Content:getFiles(parent) -- 1728
	if renamedDir then -- 1729
		local name = Path:getFilename(new):lower() -- 1730
		for _index_0 = 1, #files do -- 1731
			local file = files[_index_0] -- 1731
			if name == Path:getFilename(file):lower() then -- 1732
				return false -- 1733
			end -- 1732
		end -- 1731
	else -- 1735
		local name = Path:getName(new):lower() -- 1735
		local ext = Path:getExt(new) -- 1736
		for _index_0 = 1, #files do -- 1737
			local file = files[_index_0] -- 1737
			if name == Path:getName(file):lower() then -- 1738
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1739
					goto _continue_0 -- 1740
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1741
					goto _continue_0 -- 1742
				end -- 1739
				return false -- 1743
			end -- 1738
			::_continue_0:: -- 1738
		end -- 1737
	end -- 1729
	if not Content:move(old, new) then -- 1744
		return false -- 1744
	end -- 1744
	if renamedDir then -- 1745
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1746
	end -- 1745
	local newParent = Path:getPath(new) -- 1747
	parent = Path:getPath(old) -- 1748
	files = Content:getFiles(parent) -- 1749
	local newName = Path:getName(new) -- 1750
	local oldName = Path:getName(old) -- 1751
	local name = oldName:lower() -- 1752
	local ext = Path:getExt(old) -- 1753
	for _index_0 = 1, #files do -- 1754
		local file = files[_index_0] -- 1754
		if name == Path:getName(file):lower() then -- 1755
			local _exp_0 = Path:getExt(file) -- 1756
			if "tl" == _exp_0 then -- 1756
				if ("vs" == ext) then -- 1756
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1757
				end -- 1756
			elseif "lua" == _exp_0 then -- 1758
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1758
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1759
				end -- 1758
			end -- 1756
		end -- 1755
	end -- 1754
	return true -- 1760
end -- 1724
HttpServer:post("/delete", function(req) -- 1762
	do -- 1763
		local _type_0 = type(req) -- 1763
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1763
		if _tab_0 then -- 1763
			local path -- 1763
			do -- 1763
				local _obj_0 = req.body -- 1763
				local _type_1 = type(_obj_0) -- 1763
				if "table" == _type_1 or "userdata" == _type_1 then -- 1763
					path = _obj_0.path -- 1763
				end -- 1763
			end -- 1763
			if path ~= nil then -- 1763
				if deleteAsset(path) then -- 1764
					return { -- 1764
						success = true -- 1764
					} -- 1764
				end -- 1764
			end -- 1763
		end -- 1763
	end -- 1763
	return { -- 1762
		success = false -- 1762
	} -- 1762
end) -- 1762
HttpServer:post("/rename", function(req) -- 1766
	do -- 1767
		local _type_0 = type(req) -- 1767
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1767
		if _tab_0 then -- 1767
			local old -- 1767
			do -- 1767
				local _obj_0 = req.body -- 1767
				local _type_1 = type(_obj_0) -- 1767
				if "table" == _type_1 or "userdata" == _type_1 then -- 1767
					old = _obj_0.old -- 1767
				end -- 1767
			end -- 1767
			local new -- 1767
			do -- 1767
				local _obj_0 = req.body -- 1767
				local _type_1 = type(_obj_0) -- 1767
				if "table" == _type_1 or "userdata" == _type_1 then -- 1767
					new = _obj_0.new -- 1767
				end -- 1767
			end -- 1767
			if old ~= nil and new ~= nil then -- 1767
				if moveAsset(old, new) then -- 1768
					return { -- 1768
						success = true -- 1768
					} -- 1768
				end -- 1768
			end -- 1767
		end -- 1767
	end -- 1767
	return { -- 1766
		success = false -- 1766
	} -- 1766
end) -- 1766
local normalizeAssetPaths -- 1770
normalizeAssetPaths = function(paths) -- 1770
	if not (type(paths) == "table") then -- 1771
		return nil -- 1771
	end -- 1771
	local unique = { } -- 1772
	local candidates = { } -- 1773
	for _index_0 = 1, #paths do -- 1774
		local path = paths[_index_0] -- 1774
		if not (type(path) == "string") then -- 1775
			return nil -- 1775
		end -- 1775
		local relative = relativeToRoot(path, Content.writablePath) -- 1776
		if relative == nil or relative == "" or not Content:exist(path) then -- 1777
			return nil -- 1777
		end -- 1777
		if not unique[path] then -- 1778
			unique[path] = true -- 1779
			candidates[#candidates + 1] = path -- 1780
		end -- 1778
	end -- 1774
	table.sort(candidates, function(a, b) -- 1781
		return #a < #b -- 1781
	end) -- 1781
	local result = { } -- 1782
	for _index_0 = 1, #candidates do -- 1783
		local path = candidates[_index_0] -- 1783
		local contained = false -- 1784
		for _index_1 = 1, #result do -- 1785
			local parent = result[_index_1] -- 1785
			if relativeToRoot(path, parent) ~= nil then -- 1786
				contained = true -- 1787
				break -- 1788
			end -- 1786
		end -- 1785
		if not contained then -- 1789
			result[#result + 1] = path -- 1789
		end -- 1789
	end -- 1783
	return result -- 1790
end -- 1770
HttpServer:postSchedule("/assets/batch", function(req) -- 1792
	do -- 1793
		local _type_0 = type(req) -- 1793
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1793
		if _tab_0 then -- 1793
			local operation -- 1793
			do -- 1793
				local _obj_0 = req.body -- 1793
				local _type_1 = type(_obj_0) -- 1793
				if "table" == _type_1 or "userdata" == _type_1 then -- 1793
					operation = _obj_0.operation -- 1793
				end -- 1793
			end -- 1793
			local sources -- 1793
			do -- 1793
				local _obj_0 = req.body -- 1793
				local _type_1 = type(_obj_0) -- 1793
				if "table" == _type_1 or "userdata" == _type_1 then -- 1793
					sources = _obj_0.sources -- 1793
				end -- 1793
			end -- 1793
			if operation ~= nil and sources ~= nil then -- 1793
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1794
					return { -- 1794
						success = false, -- 1794
						message = "invalid operation" -- 1794
					} -- 1794
				end -- 1794
				sources = normalizeAssetPaths(sources) -- 1795
				if not (sources and #sources > 0) then -- 1796
					return { -- 1796
						success = false, -- 1796
						message = "invalid sources" -- 1796
					} -- 1796
				end -- 1796
				local target = req.body.target -- 1797
				local destinations = { } -- 1798
				if operation ~= "delete" then -- 1799
					if not (type(target) == "string") then -- 1800
						return { -- 1800
							success = false, -- 1800
							message = "invalid target" -- 1800
						} -- 1800
					end -- 1800
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1801
					if targetRelative == nil then -- 1802
						return { -- 1802
							success = false, -- 1802
							message = "invalid target" -- 1802
						} -- 1802
					end -- 1802
					if not (Content:exist(target) and Content:isdir(target)) then -- 1803
						return { -- 1803
							success = false, -- 1803
							message = "invalid target" -- 1803
						} -- 1803
					end -- 1803
					for _index_0 = 1, #sources do -- 1804
						local source = sources[_index_0] -- 1804
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1805
							return { -- 1806
								success = false, -- 1806
								message = "target inside source" -- 1806
							} -- 1806
						end -- 1805
						local destination = Path(target, Path:getFilename(source)) -- 1807
						if Content:exist(destination) then -- 1808
							return { -- 1808
								success = false, -- 1808
								message = "target existed" -- 1808
							} -- 1808
						end -- 1808
						if destinations[destination] then -- 1809
							return { -- 1809
								success = false, -- 1809
								message = "duplicate target" -- 1809
							} -- 1809
						end -- 1809
						destinations[destination] = true -- 1810
					end -- 1804
				end -- 1799
				local changes = { } -- 1811
				local affectedSet = { } -- 1812
				local affectedDirectories = { } -- 1813
				local addAffected -- 1814
				addAffected = function(dir) -- 1814
					if affectedSet[dir] then -- 1815
						return -- 1815
					end -- 1815
					affectedSet[dir] = true -- 1816
					affectedDirectories[#affectedDirectories + 1] = dir -- 1817
				end -- 1814
				if operation ~= "delete" then -- 1818
					addAffected(target) -- 1818
				end -- 1818
				for _index_0 = 1, #sources do -- 1819
					local source = sources[_index_0] -- 1819
					addAffected(Path:getPath(source)) -- 1820
					if operation == "delete" then -- 1821
						if not deleteAsset(source) then -- 1822
							return { -- 1822
								success = false, -- 1822
								message = "delete failed", -- 1822
								changes = changes, -- 1822
								affectedDirectories = affectedDirectories -- 1822
							} -- 1822
						end -- 1822
						changes[#changes + 1] = { -- 1823
							old = source -- 1823
						} -- 1823
					else -- 1825
						local destination = Path(target, Path:getFilename(source)) -- 1825
						local ok -- 1826
						if operation == "copy" then -- 1826
							ok = Content:copyAsync(source, destination) -- 1827
						else -- 1829
							ok = moveAsset(source, destination) -- 1829
						end -- 1826
						if not ok then -- 1830
							return { -- 1830
								success = false, -- 1830
								message = operation .. " failed", -- 1830
								changes = changes, -- 1830
								affectedDirectories = affectedDirectories -- 1830
							} -- 1830
						end -- 1830
						changes[#changes + 1] = { -- 1831
							old = source, -- 1831
							new = destination -- 1831
						} -- 1831
					end -- 1821
				end -- 1819
				return { -- 1832
					success = true, -- 1832
					changes = changes, -- 1832
					affectedDirectories = affectedDirectories -- 1832
				} -- 1832
			end -- 1793
		end -- 1793
	end -- 1793
	return { -- 1792
		success = false, -- 1792
		message = "invalid request" -- 1792
	} -- 1792
end) -- 1792
local withProjectSearchPaths -- 1834
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1834
	local fallbackPaths = { } -- 1835
	local addFallback -- 1836
	addFallback = function(dir) -- 1836
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1836
			fallbackPaths[#fallbackPaths + 1] = dir -- 1836
		end -- 1836
	end -- 1836
	if projectRoot and projectRoot ~= "" then -- 1837
		addFallback(Path(projectRoot, "Script")) -- 1838
		addFallback(projectRoot) -- 1839
	end -- 1837
	if projFile then -- 1840
		local projDir = getProjectDirFromFile(projFile) -- 1841
		if projDir then -- 1841
			addFallback(Path(projDir, "Script")) -- 1842
			addFallback(projDir) -- 1843
		else -- 1845
			addFallback(Path:getPath(projFile)) -- 1845
		end -- 1841
	end -- 1840
	if not (#fallbackPaths > 0) then -- 1846
		return fn() -- 1846
	end -- 1846
	local searchPaths = Content.searchPaths -- 1847
	for _index_0 = 1, #fallbackPaths do -- 1848
		local dir = fallbackPaths[_index_0] -- 1848
		Content:addSearchPath(dir) -- 1848
	end -- 1848
	local _ <close> = setmetatable({ }, { -- 1849
		__close = function() -- 1849
			Content.searchPaths = searchPaths -- 1849
		end -- 1849
	}) -- 1849
	return fn() -- 1850
end -- 1834
HttpServer:post("/exist", function(req) -- 1851
	do -- 1852
		local _type_0 = type(req) -- 1852
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1852
		if _tab_0 then -- 1852
			local file -- 1852
			do -- 1852
				local _obj_0 = req.body -- 1852
				local _type_1 = type(_obj_0) -- 1852
				if "table" == _type_1 or "userdata" == _type_1 then -- 1852
					file = _obj_0.file -- 1852
				end -- 1852
			end -- 1852
			if file ~= nil then -- 1852
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1853
					return { -- 1854
						success = Content:exist(file) -- 1854
					} -- 1854
				end) -- 1853
			end -- 1852
		end -- 1852
	end -- 1852
	return { -- 1851
		success = false -- 1851
	} -- 1851
end) -- 1851
HttpServer:postSchedule("/read", function(req) -- 1855
	do -- 1856
		local _type_0 = type(req) -- 1856
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1856
		if _tab_0 then -- 1856
			local path -- 1856
			do -- 1856
				local _obj_0 = req.body -- 1856
				local _type_1 = type(_obj_0) -- 1856
				if "table" == _type_1 or "userdata" == _type_1 then -- 1856
					path = _obj_0.path -- 1856
				end -- 1856
			end -- 1856
			if path ~= nil then -- 1856
				local readFile -- 1857
				readFile = function() -- 1857
					if Content:exist(path) and not Content:isdir(path) then -- 1858
						local content = Content:loadAsync(path) -- 1859
						if content then -- 1859
							return { -- 1860
								content = content, -- 1860
								success = true, -- 1860
								fullPath = Content:getFullPath(path) -- 1860
							} -- 1860
						end -- 1859
					end -- 1858
					return nil -- 1857
				end -- 1857
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1861
				if result then -- 1861
					return result -- 1861
				end -- 1861
			end -- 1856
		end -- 1856
	end -- 1856
	return { -- 1855
		success = false -- 1855
	} -- 1855
end) -- 1855
local agentDocLanguage -- 1863
agentDocLanguage = function(language) -- 1863
	if language == "zh-Hans" then -- 1864
		return "zh" -- 1864
	else -- 1864
		return "en" -- 1864
	end -- 1864
end -- 1863
HttpServer:postSchedule("/doc/search", function(req) -- 1866
	local body = req.body or { } -- 1867
	local language = body.docLanguage -- 1868
	if not (("en" == language or "zh-Hans" == language)) then -- 1869
		return { -- 1869
			success = false, -- 1869
			message = "unsupported doc language" -- 1869
		} -- 1869
	end -- 1869
	local docType = body.docType -- 1870
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1871
		return { -- 1871
			success = false, -- 1871
			message = "unsupported doc type" -- 1871
		} -- 1871
	end -- 1871
	local codeLanguage = body.programmingLanguage -- 1872
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1873
		return { -- 1873
			success = false, -- 1873
			message = "unsupported programming language" -- 1873
		} -- 1873
	end -- 1873
	if not body.pattern then -- 1874
		return { -- 1874
			success = false, -- 1874
			message = "missing pattern" -- 1874
		} -- 1874
	end -- 1874
	local result = nil -- 1875
	AgentTools.searchDoraDocHttp({ -- 1877
		pattern = body.pattern, -- 1877
		docLanguage = agentDocLanguage(language), -- 1878
		docType = docType, -- 1879
		programmingLanguage = codeLanguage, -- 1880
		limit = body.limit, -- 1881
		useRegex = body.useRegex, -- 1882
		caseSensitive = body.caseSensitive, -- 1883
		includeContent = body.includeContent, -- 1884
		contentWindow = body.contentWindow -- 1885
	}, function(res) -- 1886
		result = res -- 1887
	end) -- 1876
	wait(function() -- 1888
		return result ~= nil -- 1888
	end) -- 1888
	if result and result.success then -- 1889
		result.docLanguage = language -- 1890
	end -- 1889
	if result then -- 1891
		return result -- 1892
	else -- 1894
		return { -- 1894
			success = false, -- 1894
			message = "doc search failed" -- 1894
		} -- 1894
	end -- 1891
	return { -- 1866
		success = false, -- 1866
		message = "invalid call" -- 1866
	} -- 1866
end) -- 1866
HttpServer:postSchedule("/doc/read", function(req) -- 1896
	local body = req.body or { } -- 1897
	local language = body.docLanguage -- 1898
	if not (("en" == language or "zh-Hans" == language)) then -- 1899
		return { -- 1899
			success = false, -- 1899
			message = "unsupported doc language" -- 1899
		} -- 1899
	end -- 1899
	if not body.file then -- 1900
		return { -- 1900
			success = false, -- 1900
			message = "missing file" -- 1900
		} -- 1900
	end -- 1900
	local result = AgentTools.readDoraDoc({ -- 1902
		docLanguage = agentDocLanguage(language), -- 1902
		file = body.file, -- 1903
		startLine = body.startLine, -- 1904
		endLine = body.endLine -- 1905
	}) -- 1901
	if result and result.success then -- 1906
		result.docLanguage = language -- 1907
	end -- 1906
	return result -- 1908
end) -- 1896
HttpServer:get("/read-sync", function(req) -- 1910
	do -- 1911
		local _type_0 = type(req) -- 1911
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1911
		if _tab_0 then -- 1911
			local params = req.params -- 1911
			if params ~= nil then -- 1911
				local path = params.path -- 1912
				if not (type(path) == "string" and path ~= "") then -- 1913
					return { -- 1913
						success = false, -- 1913
						message = "invalid path" -- 1913
					} -- 1913
				end -- 1913
				local exts -- 1914
				if params.exts then -- 1914
					local _accum_0 = { } -- 1915
					local _len_0 = 1 -- 1915
					for ext in params.exts:gmatch("[^|]*") do -- 1915
						_accum_0[_len_0] = ext -- 1915
						_len_0 = _len_0 + 1 -- 1915
					end -- 1915
					exts = _accum_0 -- 1915
				else -- 1916
					exts = { -- 1916
						"" -- 1916
					} -- 1916
				end -- 1914
				local readFileAt -- 1917
				readFileAt = function(targetPath) -- 1917
					if Content:exist(targetPath) then -- 1918
						local content = Content:load(targetPath) -- 1919
						if content then -- 1919
							return { -- 1920
								content = content, -- 1920
								success = true, -- 1920
								fullPath = Content:getFullPath(targetPath) -- 1920
							} -- 1920
						end -- 1919
					end -- 1918
					return nil -- 1917
				end -- 1917
				local readFile -- 1921
				readFile = function(fallbackPaths) -- 1921
					for _index_0 = 1, #exts do -- 1922
						local ext = exts[_index_0] -- 1922
						local targetPath = path .. ext -- 1923
						if not Content:isAbsolutePath(targetPath) then -- 1924
							for _index_1 = 1, #fallbackPaths do -- 1925
								local fallback = fallbackPaths[_index_1] -- 1925
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1926
								if fallbackResult then -- 1926
									return fallbackResult -- 1927
								end -- 1926
							end -- 1925
						end -- 1924
						local fileResult = readFileAt(targetPath) -- 1928
						if fileResult then -- 1928
							return fileResult -- 1929
						end -- 1928
					end -- 1922
					return nil -- 1921
				end -- 1921
				local fallbackPaths = { } -- 1930
				local fallbackCandidates = { } -- 1931
				do -- 1932
					local projectRoot = req.params.projectRoot -- 1932
					if projectRoot then -- 1932
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1933
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1934
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1935
						end -- 1933
					end -- 1932
				end -- 1932
				do -- 1936
					local projFile = req.params.projFile -- 1936
					if projFile then -- 1936
						local projDir = getProjectDirFromFile(projFile) -- 1937
						if projDir then -- 1937
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1938
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1939
						else -- 1941
							projDir = Path:getPath(projFile) -- 1941
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1942
						end -- 1937
					end -- 1936
				end -- 1936
				for _index_0 = 1, #fallbackCandidates do -- 1943
					local dir = fallbackCandidates[_index_0] -- 1943
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1944
						local exists = false -- 1945
						for _index_1 = 1, #fallbackPaths do -- 1946
							local fallback = fallbackPaths[_index_1] -- 1946
							if fallback == dir then -- 1947
								exists = true -- 1948
								break -- 1949
							end -- 1947
						end -- 1946
						if not exists then -- 1950
							fallbackPaths[#fallbackPaths + 1] = dir -- 1950
						end -- 1950
					end -- 1944
				end -- 1943
				local readResult = readFile(fallbackPaths) -- 1951
				if readResult then -- 1951
					return readResult -- 1952
				end -- 1951
			end -- 1911
		end -- 1911
	end -- 1911
	return { -- 1910
		success = false -- 1910
	} -- 1910
end) -- 1910
local addGeneratedSourceHeader -- 1954
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 1954
	if preserveTIC80 == nil then -- 1954
		preserveTIC80 = false -- 1954
	end -- 1954
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 1955
	if preserveTIC80 then -- 1956
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 1957
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 1958
		end -- 1957
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 1959
	end -- 1956
	return tostring(header) .. "\n" .. tostring(codes) -- 1960
end -- 1954
local compileFileAsync -- 1962
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1962
	if projectRoot == nil then -- 1962
		projectRoot = nil -- 1962
	end -- 1962
	local file = inputFile -- 1963
	local searchPath -- 1964
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1964
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1965
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1969
	elseif not Content:isAbsolutePath(inputFile) then -- 1970
		searchPath = "" -- 1971
	else -- 1972
		local dir = getProjectDirFromFile(inputFile) -- 1972
		if dir then -- 1972
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1973
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1977
		else -- 1979
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1979
			searchPath = "" -- 1982
		end -- 1972
	end -- 1964
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1983
	local yueext = yue.options.extension -- 1984
	local resultCodes = nil -- 1985
	local resultError = nil -- 1986
	do -- 1987
		local _exp_0 = Path:getExt(inputFile) -- 1987
		if yueext == _exp_0 then -- 1987
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1988
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1989
				if not codes then -- 1990
					resultError = err -- 1991
					return -- 1992
				end -- 1990
				local extraGlobal -- 1993
				if isTIC80 then -- 1993
					extraGlobal = tic80APIs -- 1993
				else -- 1993
					extraGlobal = nil -- 1993
				end -- 1993
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1994
				if not success then -- 1995
					resultError = message -- 1996
					return -- 1997
				end -- 1995
				if codes == "" then -- 1998
					resultCodes = "" -- 1999
					return nil -- 2000
				end -- 1998
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 2001
				return resultCodes -- 2002
			end, function(success) -- 1989
				if not success then -- 2003
					Content:remove(outputFile) -- 2004
					if resultCodes == nil then -- 2005
						resultCodes = false -- 2006
					end -- 2005
				end -- 2003
			end) -- 1989
		elseif "tl" == _exp_0 then -- 2007
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 2008
			if isTIC80 then -- 2009
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2010
			end -- 2009
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2011
			if codes then -- 2011
				if isTIC80 then -- 2012
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2013
				end -- 2012
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2014
				Content:saveAsync(outputFile, resultCodes) -- 2015
			else -- 2017
				Content:remove(outputFile) -- 2017
				resultCodes = false -- 2018
				resultError = err -- 2019
			end -- 2011
		elseif "xml" == _exp_0 then -- 2020
			local codes, err = xml.tolua(sourceCodes) -- 2021
			if codes then -- 2021
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2022
				Content:saveAsync(outputFile, resultCodes) -- 2023
			else -- 2025
				Content:remove(outputFile) -- 2025
				resultCodes = false -- 2026
				resultError = err -- 2027
			end -- 2021
		end -- 1987
	end -- 1987
	wait(function() -- 2028
		return resultCodes ~= nil -- 2028
	end) -- 2028
	if resultCodes then -- 2029
		return resultCodes -- 2030
	else -- 2032
		return nil, resultError -- 2032
	end -- 2029
	return nil -- 1962
end -- 1962
HttpServer:postSchedule("/write", function(req) -- 2034
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2035
	local buildSucceeded = false -- 2036
	local _ <close> = setmetatable({ }, { -- 2037
		__close = function() -- 2037
			return finishUpdate(buildSucceeded) -- 2037
		end -- 2037
	}) -- 2037
	do -- 2038
		local _type_0 = type(req) -- 2038
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2038
		if _tab_0 then -- 2038
			local path -- 2038
			do -- 2038
				local _obj_0 = req.body -- 2038
				local _type_1 = type(_obj_0) -- 2038
				if "table" == _type_1 or "userdata" == _type_1 then -- 2038
					path = _obj_0.path -- 2038
				end -- 2038
			end -- 2038
			local content -- 2038
			do -- 2038
				local _obj_0 = req.body -- 2038
				local _type_1 = type(_obj_0) -- 2038
				if "table" == _type_1 or "userdata" == _type_1 then -- 2038
					content = _obj_0.content -- 2038
				end -- 2038
			end -- 2038
			if path ~= nil and content ~= nil then -- 2038
				if Content:saveAsync(path, content) then -- 2039
					do -- 2040
						local _exp_0 = Path:getExt(path) -- 2040
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2040
							if '' == Path:getExt(Path:getName(path)) then -- 2041
								local resultCodes = compileFileAsync(path, content) -- 2042
								buildSucceeded = resultCodes ~= nil -- 2043
								return { -- 2044
									success = true, -- 2044
									resultCodes = resultCodes -- 2044
								} -- 2044
							end -- 2041
						end -- 2040
					end -- 2040
					buildSucceeded = true -- 2045
					return { -- 2046
						success = true -- 2046
					} -- 2046
				end -- 2039
			end -- 2038
		end -- 2038
	end -- 2038
	return { -- 2034
		success = false -- 2034
	} -- 2034
end) -- 2034
local getWaProjectDirFromFile = nil -- 2048
HttpServer:postSchedule("/build", function(req) -- 2050
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2051
	local buildSucceeded = false -- 2052
	local _ <close> = setmetatable({ }, { -- 2053
		__close = function() -- 2053
			return finishUpdate(buildSucceeded) -- 2053
		end -- 2053
	}) -- 2053
	do -- 2054
		local _type_0 = type(req) -- 2054
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2054
		if _tab_0 then -- 2054
			local path -- 2054
			do -- 2054
				local _obj_0 = req.body -- 2054
				local _type_1 = type(_obj_0) -- 2054
				if "table" == _type_1 or "userdata" == _type_1 then -- 2054
					path = _obj_0.path -- 2054
				end -- 2054
			end -- 2054
			if path ~= nil then -- 2054
				local projectRoot = req.body.projectRoot -- 2055
				if Content:isdir(path) then -- 2056
					local projDir = getWaProjectDirFromFile(path) -- 2057
					if projDir then -- 2057
						local message = Wasm:buildWaAsync(projDir) -- 2058
						if message == "" then -- 2059
							return { -- 2060
								success = true -- 2060
							} -- 2060
						else -- 2062
							return { -- 2062
								success = false, -- 2062
								message = message -- 2062
							} -- 2062
						end -- 2059
					end -- 2057
				end -- 2056
				local _exp_0 = Path:getExt(path) -- 2063
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2064
					if '' == Path:getExt(Path:getName(path)) then -- 2065
						local content = Content:loadAsync(path) -- 2066
						if content then -- 2066
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2067
							if resultCodes then -- 2067
								buildSucceeded = true -- 2068
								return { -- 2069
									success = true, -- 2069
									resultCodes = resultCodes -- 2069
								} -- 2069
							end -- 2067
						end -- 2066
					end -- 2065
				elseif "wa" == _exp_0 then -- 2070
					local projDir = getWaProjectDirFromFile(path) -- 2071
					if projDir then -- 2071
						local message = Wasm:buildWaAsync(projDir) -- 2072
						if message == "" then -- 2073
							return { -- 2074
								success = true -- 2074
							} -- 2074
						else -- 2076
							return { -- 2076
								success = false, -- 2076
								message = message -- 2076
							} -- 2076
						end -- 2073
					else -- 2078
						return { -- 2078
							success = false, -- 2078
							message = 'Wa file needs a project' -- 2078
						} -- 2078
					end -- 2071
				end -- 2063
			end -- 2054
		end -- 2054
	end -- 2054
	return { -- 2050
		success = false -- 2050
	} -- 2050
end) -- 2050
local extentionLevels = { -- 2081
	vs = 2, -- 2081
	bl = 2, -- 2082
	ts = 1, -- 2083
	tsx = 1, -- 2084
	tl = 1, -- 2085
	yue = 1, -- 2086
	xml = 1, -- 2087
	lua = 0 -- 2088
} -- 2080
local visitAssets -- 2090
visitAssets = function(path, workspace, builtin, recursive) -- 2090
	if recursive == nil then -- 2090
		recursive = true -- 2090
	end -- 2090
	local children = nil -- 2091
	local dirs = Content:getDirs(path) -- 2092
	for _index_0 = 1, #dirs do -- 2093
		local dir = dirs[_index_0] -- 2093
		if workspace then -- 2094
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 2095
				goto _continue_0 -- 2096
			end -- 2095
		elseif dir == ".git" then -- 2097
			goto _continue_0 -- 2098
		end -- 2094
		if not children then -- 2099
			children = { } -- 2099
		end -- 2099
		local dirPath = Path(path, dir) -- 2100
		if recursive then -- 2101
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2102
		else -- 2104
			children[#children + 1] = { -- 2105
				key = dirPath, -- 2105
				dir = true, -- 2106
				title = dir, -- 2107
				builtin = builtin, -- 2108
				isLeaf = false -- 2109
			} -- 2104
		end -- 2101
		::_continue_0:: -- 2094
	end -- 2093
	local files = Content:getFiles(path) -- 2111
	local names = { } -- 2112
	for _index_0 = 1, #files do -- 2113
		local file = files[_index_0] -- 2113
		if (".DS_Store" == file) then -- 2114
			goto _continue_1 -- 2115
		end -- 2114
		local name = Path:getName(file) -- 2116
		local ext = names[name] -- 2117
		if ext then -- 2117
			local lv1 -- 2118
			do -- 2118
				local _exp_0 = extentionLevels[ext] -- 2118
				if _exp_0 ~= nil then -- 2118
					lv1 = _exp_0 -- 2118
				else -- 2118
					lv1 = -1 -- 2118
				end -- 2118
			end -- 2118
			ext = Path:getExt(file) -- 2119
			local lv2 -- 2120
			do -- 2120
				local _exp_0 = extentionLevels[ext] -- 2120
				if _exp_0 ~= nil then -- 2120
					lv2 = _exp_0 -- 2120
				else -- 2120
					lv2 = -1 -- 2120
				end -- 2120
			end -- 2120
			if lv2 > lv1 then -- 2121
				names[name] = ext -- 2122
			elseif lv2 == lv1 then -- 2123
				names[name .. '.' .. ext] = "" -- 2124
			end -- 2121
		else -- 2126
			ext = Path:getExt(file) -- 2126
			if not extentionLevels[ext] then -- 2127
				names[file] = "" -- 2128
			else -- 2130
				names[name] = ext -- 2130
			end -- 2127
		end -- 2117
		::_continue_1:: -- 2114
	end -- 2113
	do -- 2131
		local _accum_0 = { } -- 2131
		local _len_0 = 1 -- 2131
		for name, ext in pairs(names) do -- 2131
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2131
			_len_0 = _len_0 + 1 -- 2131
		end -- 2131
		files = _accum_0 -- 2131
	end -- 2131
	for _index_0 = 1, #files do -- 2132
		local file = files[_index_0] -- 2132
		if not children then -- 2133
			children = { } -- 2133
		end -- 2133
		children[#children + 1] = { -- 2135
			key = Path(path, file), -- 2135
			dir = false, -- 2136
			title = file, -- 2137
			builtin = builtin -- 2138
		} -- 2134
	end -- 2132
	if children then -- 2140
		table.sort(children, function(a, b) -- 2141
			if a.dir == b.dir then -- 2142
				return a.title < b.title -- 2143
			else -- 2145
				return a.dir -- 2145
			end -- 2142
		end) -- 2141
	end -- 2140
	return { -- 2147
		key = path, -- 2147
		dir = true, -- 2148
		title = Path:getFilename(path), -- 2149
		builtin = builtin, -- 2150
		isLeaf = not children, -- 2151
		children = children -- 2152
	} -- 2146
end -- 2090
HttpServer:post("/assets/children", function(req) -- 2155
	do -- 2156
		local _type_0 = type(req) -- 2156
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2156
		if _tab_0 then -- 2156
			local path -- 2156
			do -- 2156
				local _obj_0 = req.body -- 2156
				local _type_1 = type(_obj_0) -- 2156
				if "table" == _type_1 or "userdata" == _type_1 then -- 2156
					path = _obj_0.path -- 2156
				end -- 2156
			end -- 2156
			if path ~= nil then -- 2156
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2157
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2158
					return { -- 2158
						success = false -- 2158
					} -- 2158
				end -- 2158
				local node = visitAssets(path, workspace, builtin, false) -- 2159
				return { -- 2160
					success = true, -- 2160
					children = node.children or { } -- 2160
				} -- 2160
			end -- 2156
		end -- 2156
	end -- 2156
	return { -- 2155
		success = false -- 2155
	} -- 2155
end) -- 2155
HttpServer:post("/assets/files", function(req) -- 2162
	do -- 2163
		local _type_0 = type(req) -- 2163
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2163
		if _tab_0 then -- 2163
			local path -- 2163
			do -- 2163
				local _obj_0 = req.body -- 2163
				local _type_1 = type(_obj_0) -- 2163
				if "table" == _type_1 or "userdata" == _type_1 then -- 2163
					path = _obj_0.path -- 2163
				end -- 2163
			end -- 2163
			if path ~= nil then -- 2163
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2164
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2165
				if not (workspace or builtin) then -- 2166
					return { -- 2166
						success = false -- 2166
					} -- 2166
				end -- 2166
				if not (Content:exist(path) and Content:isdir(path)) then -- 2167
					return { -- 2167
						success = false -- 2167
					} -- 2167
				end -- 2167
				local globs = { -- 2168
					"**", -- 2168
					"!**/.DS_Store" -- 2168
				} -- 2168
				if workspace then -- 2169
					globs = { -- 2171
						"**", -- 2171
						"!**/.DS_Store", -- 2171
						"!**/.upload/**", -- 2172
						"!**/.download/**", -- 2172
						"!**/.www/**", -- 2173
						"!**/.build/**", -- 2173
						"!**/.git/**", -- 2174
						"!**/.cache/**", -- 2174
						"!**/node_modules/**" -- 2175
					} -- 2170
				end -- 2169
				local files -- 2177
				do -- 2177
					local _accum_0 = { } -- 2177
					local _len_0 = 1 -- 2177
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2177
					for _index_0 = 1, #_list_0 do -- 2177
						local file = _list_0[_index_0] -- 2177
						_accum_0[_len_0] = Path(path, file) -- 2177
						_len_0 = _len_0 + 1 -- 2177
					end -- 2177
					files = _accum_0 -- 2177
				end -- 2177
				return { -- 2178
					success = true, -- 2178
					files = files -- 2178
				} -- 2178
			end -- 2163
		end -- 2163
	end -- 2163
	return { -- 2162
		success = false -- 2162
	} -- 2162
end) -- 2162
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2219
	local _tab_0 = { -- 2219
		{ -- 2220
			key = Path(Content.assetPath), -- 2220
			dir = true, -- 2221
			builtin = true, -- 2222
			title = zh and "内置资源" or "Built-in", -- 2223
			children = builtinChildren -- 2224
		} -- 2219
	} -- 2226
	local _obj_0 = workspace.children or { } -- 2226
	local _idx_0 = #_tab_0 + 1 -- 2226
	for _index_0 = 1, #_obj_0 do -- 2226
		local _value_0 = _obj_0[_index_0] -- 2226
		_tab_0[_idx_0] = _value_0 -- 2226
		_idx_0 = _idx_0 + 1 -- 2226
	end -- 2226
	return _tab_0 -- 2219
end -- 2219
HttpServer:post("/assets", function() -- 2180
	local Entry = require("Script.Dev.Entry") -- 2181
	local engineDev = Entry.getEngineDev() -- 2182
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2183
	local zh = (App.locale:match("^zh") ~= nil) -- 2184
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2185
	readme.title = zh and "说明文档" or "Readme" -- 2186
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2187
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2188
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2189
	tools.title = zh and "开发工具" or "Tools" -- 2190
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2191
	font.title = zh and "字体" or "Font" -- 2192
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2193
	lib.title = zh and "程序库" or "Lib" -- 2194
	if engineDev then -- 2195
		local _list_0 = lib.children -- 2196
		for _index_0 = 1, #_list_0 do -- 2196
			local child = _list_0[_index_0] -- 2196
			if not (child.title == "Dora") then -- 2197
				goto _continue_0 -- 2197
			end -- 2197
			local title = zh and "zh-Hans" or "en" -- 2198
			do -- 2199
				local _accum_0 = { } -- 2199
				local _len_0 = 1 -- 2199
				local _list_1 = child.children -- 2199
				for _index_1 = 1, #_list_1 do -- 2199
					local c = _list_1[_index_1] -- 2199
					if c.title ~= title then -- 2199
						_accum_0[_len_0] = c -- 2199
						_len_0 = _len_0 + 1 -- 2199
					end -- 2199
				end -- 2199
				child.children = _accum_0 -- 2199
			end -- 2199
			break -- 2200
			::_continue_0:: -- 2197
		end -- 2196
	else -- 2202
		local _accum_0 = { } -- 2202
		local _len_0 = 1 -- 2202
		local _list_0 = lib.children -- 2202
		for _index_0 = 1, #_list_0 do -- 2202
			local child = _list_0[_index_0] -- 2202
			if child.title ~= "Dora" then -- 2202
				_accum_0[_len_0] = child -- 2202
				_len_0 = _len_0 + 1 -- 2202
			end -- 2202
		end -- 2202
		lib.children = _accum_0 -- 2202
	end -- 2195
	local builtinChildren = { -- 2203
		readme, -- 2203
		apiDoc, -- 2203
		tools, -- 2203
		font, -- 2203
		lib -- 2203
	} -- 2203
	if engineDev then -- 2204
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2205
		do -- 2206
			local _obj_0 = dev.children -- 2206
			_obj_0[#_obj_0 + 1] = { -- 2207
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2207
				dir = false, -- 2208
				builtin = true, -- 2209
				title = "init.yue" -- 2210
			} -- 2206
		end -- 2206
		builtinChildren[#builtinChildren + 1] = dev -- 2212
	end -- 2204
	return { -- 2214
		key = Content.writablePath, -- 2214
		dir = true, -- 2215
		root = true, -- 2216
		title = "Assets", -- 2217
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2218
	} -- 2213
end) -- 2180
HttpServer:post("/entry/list", function(req) -- 2230
	local Entry = require("Script.Dev.Entry") -- 2231
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2232
	res.success = true -- 2233
	return res -- 2234
end) -- 2230
HttpServer:post("/run/status", function() -- 2236
	local Entry = require("Script.Dev.Entry") -- 2237
	return Entry.getCurrentEntryStatus() -- 2238
end) -- 2236
HttpServer:postSchedule("/run", function(req) -- 2240
	do -- 2241
		local _type_0 = type(req) -- 2241
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2241
		if _tab_0 then -- 2241
			local file -- 2241
			do -- 2241
				local _obj_0 = req.body -- 2241
				local _type_1 = type(_obj_0) -- 2241
				if "table" == _type_1 or "userdata" == _type_1 then -- 2241
					file = _obj_0.file -- 2241
				end -- 2241
			end -- 2241
			local asProj -- 2241
			do -- 2241
				local _obj_0 = req.body -- 2241
				local _type_1 = type(_obj_0) -- 2241
				if "table" == _type_1 or "userdata" == _type_1 then -- 2241
					asProj = _obj_0.asProj -- 2241
				end -- 2241
			end -- 2241
			if file ~= nil and asProj ~= nil then -- 2241
				if not Content:isAbsolutePath(file) then -- 2242
					local devFile = Path(Content.writablePath, file) -- 2243
					if Content:exist(devFile) then -- 2244
						file = devFile -- 2244
					end -- 2244
				end -- 2242
				local Entry = require("Script.Dev.Entry") -- 2245
				local workDir -- 2246
				if asProj then -- 2247
					local projectRoot = req.body.projectRoot -- 2248
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2249
						workDir = projectRoot -- 2250
					else -- 2252
						workDir = getProjectDirFromFile(file) -- 2252
					end -- 2249
					if workDir then -- 2253
						Entry.allClear() -- 2254
						local target = Path(workDir, "init") -- 2255
						local success, err = Entry.enterEntryAsync({ -- 2256
							entryName = "Project", -- 2256
							fileName = target, -- 2256
							workDir = workDir, -- 2256
							projectRoot = workDir, -- 2256
							runKind = "project" -- 2256
						}) -- 2256
						target = Path:getName(Path:getPath(target)) -- 2257
						return { -- 2258
							success = success, -- 2258
							target = target, -- 2258
							err = err -- 2258
						} -- 2258
					end -- 2253
				else -- 2260
					workDir = getProjectDirFromFile(file) -- 2260
					if not workDir and Path:getExt(file) == "wasm" then -- 2261
						local parent = Path:getPath(file) -- 2262
						if Content:exist(Path(parent, "wa.mod")) then -- 2263
							workDir = parent -- 2264
						end -- 2263
					end -- 2261
				end -- 2247
				Entry.allClear() -- 2265
				file = Path:replaceExt(file, "") -- 2266
				local entry = { -- 2268
					entryName = Path:getName(file), -- 2268
					fileName = file, -- 2269
					runKind = "file" -- 2270
				} -- 2267
				if workDir then -- 2271
					entry.workDir = workDir -- 2272
					entry.projectRoot = workDir -- 2273
				end -- 2271
				local success, err = Entry.enterEntryAsync(entry) -- 2274
				return { -- 2275
					success = success, -- 2275
					err = err -- 2275
				} -- 2275
			end -- 2241
		end -- 2241
	end -- 2241
	return { -- 2240
		success = false -- 2240
	} -- 2240
end) -- 2240
local _anon_func_7 = function(result) -- 2317
	if result.success then -- 2317
		return nil -- 2317
	else -- 2317
		return "PREVIEW_FAILED" -- 2317
	end -- 2317
end -- 2317
HttpServer:postSchedule("/agent/preview", function(req) -- 2277
	local releaseAgent = AgentHost.acquire() -- 2278
	local _ <close> = setmetatable({ }, { -- 2279
		__close = function() -- 2279
			return releaseAgent() -- 2279
		end -- 2279
	}) -- 2279
	do -- 2280
		local _type_0 = type(req) -- 2280
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2280
		if _tab_0 then -- 2280
			local projectRoot -- 2280
			do -- 2280
				local _obj_0 = req.body -- 2280
				local _type_1 = type(_obj_0) -- 2280
				if "table" == _type_1 or "userdata" == _type_1 then -- 2280
					projectRoot = _obj_0.projectRoot -- 2280
				end -- 2280
			end -- 2280
			if projectRoot ~= nil then -- 2280
				if not getProjectSourceRoot(projectRoot) then -- 2281
					return { -- 2281
						success = false, -- 2281
						code = "INVALID_PROJECT", -- 2281
						message = "projectRoot must be an existing absolute directory" -- 2281
					} -- 2281
				end -- 2281
				local entryFile = req.body.entry or "init.lua" -- 2282
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2283
					return { -- 2283
						success = false, -- 2283
						code = "INVALID_ENTRY", -- 2283
						message = "entry must be a non-empty project-relative path" -- 2283
					} -- 2283
				end -- 2283
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2284
					0.5 -- 2284
				} -- 2284
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2285
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2286
					return { -- 2286
						success = false, -- 2286
						code = "INVALID_QUEUE_TIMEOUT", -- 2286
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2286
					} -- 2286
				end -- 2286
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2287
				local AgentOperation = require("Agent.Tool.Operation") -- 2288
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2289
				local requestId = AgentOperation.createOperationId() -- 2290
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2291
				if not enqueued.success then -- 2292
					return { -- 2292
						success = false, -- 2292
						code = "ENTRY_QUEUE_REJECTED", -- 2292
						message = enqueued.message -- 2292
					} -- 2292
				end -- 2292
				local queuedAt = App.runningTime -- 2293
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2294
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2295
						local state = agentEntryRunQueue:get(requestId) -- 2296
						agentEntryRunQueue:cancel(requestId) -- 2297
						return { -- 2299
							success = false, -- 2299
							code = "ENTRY_QUEUE_TIMEOUT", -- 2300
							message = "timed out waiting for the Dora entry runtime", -- 2301
							requestId = requestId, -- 2302
							queuePosition = state.position -- 2303
						} -- 2298
					end -- 2295
					sleep() -- 2304
				end -- 2294
				local queueWaitSeconds = App.runningTime - queuedAt -- 2305
				local _ <close> = setmetatable({ }, { -- 2306
					__close = function() -- 2306
						return agentEntryRunQueue:release(requestId) -- 2306
					end -- 2306
				}) -- 2306
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2307
				local Entry = require("Script.Dev.Entry") -- 2308
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2310
					workDir = projectRoot, -- 2310
					operationId = requestId, -- 2311
					print = function() end -- 2312
				}, Entry) -- 2309
				local result = preview({ -- 2314
					entry = entryFile, -- 2314
					captureAtSeconds = captureAtSeconds -- 2314
				}) -- 2314
				return { -- 2316
					success = result.success, -- 2316
					code = _anon_func_7(result), -- 2317
					message = result.message, -- 2318
					requestId = requestId, -- 2319
					queueWaitSeconds = queueWaitSeconds, -- 2320
					interruptedUserRun = result.interruptedUserRun, -- 2321
					files = result.files, -- 2322
					frames = result.frames -- 2323
				} -- 2315
			end -- 2280
		end -- 2280
	end -- 2280
	return { -- 2277
		success = false, -- 2277
		message = "invalid call" -- 2277
	} -- 2277
end) -- 2277
HttpServer:postSchedule("/agent/command", function(req) -- 2325
	local releaseAgent = AgentHost.acquire() -- 2326
	local _ <close> = setmetatable({ }, { -- 2327
		__close = function() -- 2327
			return releaseAgent() -- 2327
		end -- 2327
	}) -- 2327
	do -- 2328
		local _type_0 = type(req) -- 2328
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2328
		if _tab_0 then -- 2328
			local body = req.body -- 2328
			if body ~= nil then -- 2328
				local projectRoot = body.projectRoot -- 2329
				if not getProjectSourceRoot(projectRoot) then -- 2330
					return { -- 2330
						success = false, -- 2330
						code = "INVALID_PROJECT", -- 2330
						message = "projectRoot must be an existing absolute directory" -- 2330
					} -- 2330
				end -- 2330
				local AgentValidation = require("Agent.Tool.Validation") -- 2331
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2332
				if not validated.success then -- 2333
					return { -- 2333
						success = false, -- 2333
						code = "INVALID_COMMAND", -- 2333
						message = validated.message -- 2333
					} -- 2333
				end -- 2333
				local input = validated.value -- 2334
				local AgentCommand = require("Agent.Tool.Command") -- 2335
				local result = nil -- 2336
				local failure = nil -- 2337
				local promise = AgentCommand.executeCommand({ -- 2339
					workDir = projectRoot, -- 2339
					mode = input.mode, -- 2340
					code = input.code, -- 2341
					command = input.command, -- 2342
					cwd = input.cwd, -- 2343
					timeoutSeconds = input.timeoutSeconds -- 2344
				}) -- 2338
				promise:addCallbacks((function(_, value) -- 2345
					result = value -- 2345
				end), (function(_, err) -- 2345
					failure = tostring(err) -- 2345
				end)) -- 2345
				wait(function() -- 2346
					return result ~= nil or failure ~= nil -- 2346
				end) -- 2346
				if failure then -- 2347
					return { -- 2347
						success = false, -- 2347
						code = "COMMAND_BRIDGE_FAILED", -- 2347
						message = failure -- 2347
					} -- 2347
				end -- 2347
				if not result.success then -- 2348
					result.code = "COMMAND_FAILED" -- 2349
				end -- 2348
				return result -- 2350
			end -- 2328
		end -- 2328
	end -- 2328
	return { -- 2325
		success = false, -- 2325
		code = "INVALID_COMMAND", -- 2325
		message = "invalid call" -- 2325
	} -- 2325
end) -- 2325
HttpServer:postSchedule("/stop", function() -- 2352
	local Entry = require("Script.Dev.Entry") -- 2353
	return { -- 2354
		success = Entry.stop() -- 2354
	} -- 2354
end) -- 2352
local minifyAsync -- 2356
minifyAsync = function(sourcePath, minifyPath) -- 2356
	if not Content:exist(sourcePath) then -- 2357
		return -- 2357
	end -- 2357
	local Entry = require("Script.Dev.Entry") -- 2358
	local errors = { } -- 2359
	local files = Entry.getAllFiles(sourcePath, { -- 2360
		"lua" -- 2360
	}, true) -- 2360
	do -- 2361
		local _accum_0 = { } -- 2361
		local _len_0 = 1 -- 2361
		for _index_0 = 1, #files do -- 2361
			local file = files[_index_0] -- 2361
			if file:sub(1, 1) ~= '.' then -- 2361
				_accum_0[_len_0] = file -- 2361
				_len_0 = _len_0 + 1 -- 2361
			end -- 2361
		end -- 2361
		files = _accum_0 -- 2361
	end -- 2361
	local paths -- 2362
	do -- 2362
		local _tbl_0 = { } -- 2362
		for _index_0 = 1, #files do -- 2362
			local file = files[_index_0] -- 2362
			_tbl_0[Path:getPath(file)] = true -- 2362
		end -- 2362
		paths = _tbl_0 -- 2362
	end -- 2362
	for path in pairs(paths) do -- 2363
		Content:mkdir(Path(minifyPath, path)) -- 2363
	end -- 2363
	local _ <close> = setmetatable({ }, { -- 2364
		__close = function() -- 2364
			package.loaded["luaminify.FormatMini"] = nil -- 2365
			package.loaded["luaminify.ParseLua"] = nil -- 2366
			package.loaded["luaminify.Scope"] = nil -- 2367
			package.loaded["luaminify.Util"] = nil -- 2368
		end -- 2364
	}) -- 2364
	local FormatMini -- 2369
	do -- 2369
		local _obj_0 = require("luaminify") -- 2369
		FormatMini = _obj_0.FormatMini -- 2369
	end -- 2369
	local fileCount = #files -- 2370
	local count = 0 -- 2371
	for _index_0 = 1, #files do -- 2372
		local file = files[_index_0] -- 2372
		thread(function() -- 2373
			local _ <close> = setmetatable({ }, { -- 2374
				__close = function() -- 2374
					count = count + 1 -- 2374
				end -- 2374
			}) -- 2374
			local input = Path(sourcePath, file) -- 2375
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2376
			if Content:exist(input) then -- 2377
				local sourceCodes = Content:loadAsync(input) -- 2378
				local res, err = FormatMini(sourceCodes) -- 2379
				if res then -- 2380
					Content:saveAsync(output, res) -- 2381
					return print("Minify " .. tostring(file)) -- 2382
				else -- 2384
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2384
				end -- 2380
			else -- 2386
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2386
			end -- 2377
		end) -- 2373
		sleep() -- 2387
	end -- 2372
	wait(function() -- 2388
		return count == fileCount -- 2388
	end) -- 2388
	if #errors > 0 then -- 2389
		print(table.concat(errors, '\n')) -- 2390
	end -- 2389
	print("Obfuscation done.") -- 2391
	return files -- 2392
end -- 2356
local zipping = false -- 2394
HttpServer:postSchedule("/zip", function(req) -- 2396
	do -- 2397
		local _type_0 = type(req) -- 2397
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2397
		if _tab_0 then -- 2397
			local path -- 2397
			do -- 2397
				local _obj_0 = req.body -- 2397
				local _type_1 = type(_obj_0) -- 2397
				if "table" == _type_1 or "userdata" == _type_1 then -- 2397
					path = _obj_0.path -- 2397
				end -- 2397
			end -- 2397
			local zipFile -- 2397
			do -- 2397
				local _obj_0 = req.body -- 2397
				local _type_1 = type(_obj_0) -- 2397
				if "table" == _type_1 or "userdata" == _type_1 then -- 2397
					zipFile = _obj_0.zipFile -- 2397
				end -- 2397
			end -- 2397
			local obfuscated -- 2397
			do -- 2397
				local _obj_0 = req.body -- 2397
				local _type_1 = type(_obj_0) -- 2397
				if "table" == _type_1 or "userdata" == _type_1 then -- 2397
					obfuscated = _obj_0.obfuscated -- 2397
				end -- 2397
			end -- 2397
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2397
				if zipping then -- 2398
					goto failed -- 2398
				end -- 2398
				zipping = true -- 2399
				local _ <close> = setmetatable({ }, { -- 2400
					__close = function() -- 2400
						zipping = false -- 2400
					end -- 2400
				}) -- 2400
				if not Content:exist(path) then -- 2401
					goto failed -- 2401
				end -- 2401
				Content:mkdir(Path:getPath(zipFile)) -- 2402
				if obfuscated then -- 2403
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2404
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2405
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2406
					Content:remove(scriptPath) -- 2407
					Content:remove(obfuscatedPath) -- 2408
					Content:remove(tempPath) -- 2409
					Content:mkdir(scriptPath) -- 2410
					Content:mkdir(obfuscatedPath) -- 2411
					Content:mkdir(tempPath) -- 2412
					if not Content:copyAsync(path, tempPath) then -- 2413
						goto failed -- 2413
					end -- 2413
					local Entry = require("Script.Dev.Entry") -- 2414
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2415
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2416
						"tl", -- 2416
						"yue", -- 2416
						"lua", -- 2416
						"ts", -- 2416
						"tsx", -- 2416
						"vs", -- 2416
						"bl", -- 2416
						"xml", -- 2416
						"wa", -- 2416
						"mod" -- 2416
					}, true) -- 2416
					for _index_0 = 1, #scriptFiles do -- 2417
						local file = scriptFiles[_index_0] -- 2417
						Content:remove(Path(tempPath, file)) -- 2418
					end -- 2417
					for _index_0 = 1, #luaFiles do -- 2419
						local file = luaFiles[_index_0] -- 2419
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2420
					end -- 2419
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2421
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2422
					end) then -- 2421
						goto failed -- 2421
					end -- 2421
					return { -- 2423
						success = true -- 2423
					} -- 2423
				else -- 2425
					return { -- 2425
						success = Content:zipAsync(path, zipFile, function(file) -- 2425
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2426
						end) -- 2425
					} -- 2425
				end -- 2403
			end -- 2397
		end -- 2397
	end -- 2397
	::failed:: -- 2427
	return { -- 2396
		success = false -- 2396
	} -- 2396
end) -- 2396
HttpServer:postSchedule("/unzip", function(req) -- 2429
	do -- 2430
		local _type_0 = type(req) -- 2430
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2430
		if _tab_0 then -- 2430
			local zipFile -- 2430
			do -- 2430
				local _obj_0 = req.body -- 2430
				local _type_1 = type(_obj_0) -- 2430
				if "table" == _type_1 or "userdata" == _type_1 then -- 2430
					zipFile = _obj_0.zipFile -- 2430
				end -- 2430
			end -- 2430
			local path -- 2430
			do -- 2430
				local _obj_0 = req.body -- 2430
				local _type_1 = type(_obj_0) -- 2430
				if "table" == _type_1 or "userdata" == _type_1 then -- 2430
					path = _obj_0.path -- 2430
				end -- 2430
			end -- 2430
			if zipFile ~= nil and path ~= nil then -- 2430
				return { -- 2431
					success = Content:unzipAsync(zipFile, path, function(file) -- 2431
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2432
					end) -- 2431
				} -- 2431
			end -- 2430
		end -- 2430
	end -- 2430
	return { -- 2429
		success = false -- 2429
	} -- 2429
end) -- 2429
HttpServer:post("/editing-info", function(req) -- 2434
	local Entry = require("Script.Dev.Entry") -- 2435
	local config = Entry.getConfig() -- 2436
	local _type_0 = type(req) -- 2437
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2437
	local _match_0 = false -- 2437
	if _tab_0 then -- 2437
		local editingInfo -- 2437
		do -- 2437
			local _obj_0 = req.body -- 2437
			local _type_1 = type(_obj_0) -- 2437
			if "table" == _type_1 or "userdata" == _type_1 then -- 2437
				editingInfo = _obj_0.editingInfo -- 2437
			end -- 2437
		end -- 2437
		if editingInfo ~= nil then -- 2437
			_match_0 = true -- 2437
			config.editingInfo = editingInfo -- 2438
			return { -- 2439
				success = true -- 2439
			} -- 2439
		end -- 2437
	end -- 2437
	if not _match_0 then -- 2437
		if not (config.editingInfo ~= nil) then -- 2441
			local folder -- 2442
			if App.locale:match('^zh') then -- 2442
				folder = 'zh-Hans' -- 2442
			else -- 2442
				folder = 'en' -- 2442
			end -- 2442
			config.editingInfo = json.encode({ -- 2444
				index = 0, -- 2444
				files = { -- 2446
					{ -- 2447
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2447
						title = "welcome.md" -- 2448
					} -- 2446
				} -- 2445
			}) -- 2443
		end -- 2441
		return { -- 2452
			success = true, -- 2452
			editingInfo = config.editingInfo -- 2452
		} -- 2452
	end -- 2437
end) -- 2434
HttpServer:post("/command", function(req) -- 2454
	do -- 2455
		local _type_0 = type(req) -- 2455
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2455
		if _tab_0 then -- 2455
			local code -- 2455
			do -- 2455
				local _obj_0 = req.body -- 2455
				local _type_1 = type(_obj_0) -- 2455
				if "table" == _type_1 or "userdata" == _type_1 then -- 2455
					code = _obj_0.code -- 2455
				end -- 2455
			end -- 2455
			local log -- 2455
			do -- 2455
				local _obj_0 = req.body -- 2455
				local _type_1 = type(_obj_0) -- 2455
				if "table" == _type_1 or "userdata" == _type_1 then -- 2455
					log = _obj_0.log -- 2455
				end -- 2455
			end -- 2455
			if code ~= nil and log ~= nil then -- 2455
				emit("AppCommand", code, log) -- 2456
				return { -- 2457
					success = true -- 2457
				} -- 2457
			end -- 2455
		end -- 2455
	end -- 2455
	return { -- 2454
		success = false -- 2454
	} -- 2454
end) -- 2454
HttpServer:post("/log/save", function() -- 2459
	local folder = ".download" -- 2460
	local fullLogFile = "dora_full_logs.txt" -- 2461
	local fullFolder = Path(Content.writablePath, folder) -- 2462
	Content:mkdir(fullFolder) -- 2463
	local logPath = Path(fullFolder, fullLogFile) -- 2464
	if App:saveLog(logPath) then -- 2465
		return { -- 2466
			success = true, -- 2466
			path = Path(folder, fullLogFile) -- 2466
		} -- 2466
	end -- 2465
	return { -- 2459
		success = false -- 2459
	} -- 2459
end) -- 2459
local tailLines -- 2468
tailLines = function(text, count) -- 2468
	local lines = { } -- 2469
	text = text:gsub("\r\n", "\n") -- 2470
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2471
		lines[#lines + 1] = line -- 2472
	end -- 2471
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2473
		table.remove(lines) -- 2474
	end -- 2473
	local start = math.max(1, #lines - count + 1) -- 2475
	local out = { } -- 2476
	for i = start, #lines do -- 2477
		out[#out + 1] = lines[i] -- 2478
	end -- 2477
	return table.concat(out, "\n") -- 2479
end -- 2468
HttpServer:post("/log", function(req) -- 2481
	local count = 100 -- 2482
	if req and req.body and req.body.count ~= nil then -- 2483
		count = req.body.count -- 2484
	end -- 2483
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2485
		return { -- 2486
			success = false, -- 2486
			message = "count must be a positive integer" -- 2486
		} -- 2486
	end -- 2485
	local folder = ".download" -- 2487
	local fullLogFile = "dora_full_logs.txt" -- 2488
	local fullFolder = Path(Content.writablePath, folder) -- 2489
	Content:mkdir(fullFolder) -- 2490
	local logPath = Path(fullFolder, fullLogFile) -- 2491
	if App:saveLog(logPath) then -- 2492
		local text = Content:load(logPath) -- 2493
		if text then -- 2494
			return { -- 2495
				success = true, -- 2495
				log = tailLines(text, count) -- 2495
			} -- 2495
		else -- 2497
			return { -- 2497
				success = false, -- 2497
				message = "failed to read log" -- 2497
			} -- 2497
		end -- 2494
	else -- 2499
		return { -- 2499
			success = false, -- 2499
			message = "failed to save log" -- 2499
		} -- 2499
	end -- 2492
	return { -- 2481
		success = false -- 2481
	} -- 2481
end) -- 2481
HttpServer:post("/yarn/check", function(req) -- 2501
	local yarncompile = require("yarncompile") -- 2502
	do -- 2503
		local _type_0 = type(req) -- 2503
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2503
		if _tab_0 then -- 2503
			local code -- 2503
			do -- 2503
				local _obj_0 = req.body -- 2503
				local _type_1 = type(_obj_0) -- 2503
				if "table" == _type_1 or "userdata" == _type_1 then -- 2503
					code = _obj_0.code -- 2503
				end -- 2503
			end -- 2503
			if code ~= nil then -- 2503
				local jsonObject = json.decode(code) -- 2504
				if jsonObject then -- 2504
					local errors = { } -- 2505
					local _list_0 = jsonObject.nodes -- 2506
					for _index_0 = 1, #_list_0 do -- 2506
						local node = _list_0[_index_0] -- 2506
						local title, body = node.title, node.body -- 2507
						local luaCode, err = yarncompile(body) -- 2508
						if not luaCode then -- 2508
							errors[#errors + 1] = title .. ":" .. err -- 2509
						end -- 2508
					end -- 2506
					return { -- 2510
						success = true, -- 2510
						syntaxError = table.concat(errors, "\n\n") -- 2510
					} -- 2510
				end -- 2504
			end -- 2503
		end -- 2503
	end -- 2503
	return { -- 2501
		success = false -- 2501
	} -- 2501
end) -- 2501
HttpServer:post("/yarn/check-file", function(req) -- 2512
	local yarncompile = require("yarncompile") -- 2513
	do -- 2514
		local _type_0 = type(req) -- 2514
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2514
		if _tab_0 then -- 2514
			local code -- 2514
			do -- 2514
				local _obj_0 = req.body -- 2514
				local _type_1 = type(_obj_0) -- 2514
				if "table" == _type_1 or "userdata" == _type_1 then -- 2514
					code = _obj_0.code -- 2514
				end -- 2514
			end -- 2514
			if code ~= nil then -- 2514
				local res, _, err = yarncompile(code, true) -- 2515
				if not res then -- 2515
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2516
					return { -- 2517
						success = false, -- 2517
						message = message, -- 2517
						line = line, -- 2517
						column = column, -- 2517
						node = node -- 2517
					} -- 2517
				end -- 2515
			end -- 2514
		end -- 2514
	end -- 2514
	return { -- 2512
		success = true -- 2512
	} -- 2512
end) -- 2512
getWaProjectDirFromFile = function(file) -- 2519
	local current -- 2520
	if Content:isdir(file) then -- 2520
		current = file -- 2520
	else -- 2520
		current = Path:getPath(file) -- 2520
	end -- 2520
	if current == "" then -- 2521
		return nil -- 2521
	end -- 2521
	repeat -- 2522
		local modPath = Path(current, "wa.mod") -- 2523
		if Content:exist(modPath) then -- 2524
			return current, modPath -- 2525
		end -- 2524
		local parent = Path:getPath(current) -- 2526
		if parent == "" or parent == current then -- 2527
			break -- 2527
		end -- 2527
		current = parent -- 2528
	until false -- 2522
	return nil -- 2530
end -- 2519
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2532
	do -- 2533
		local _type_0 = type(req) -- 2533
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2533
		if _tab_0 then -- 2533
			local path -- 2533
			do -- 2533
				local _obj_0 = req.body -- 2533
				local _type_1 = type(_obj_0) -- 2533
				if "table" == _type_1 or "userdata" == _type_1 then -- 2533
					path = _obj_0.path -- 2533
				end -- 2533
			end -- 2533
			if path ~= nil then -- 2533
				local projDir = getWaProjectDirFromFile(path) -- 2534
				if projDir then -- 2534
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2535
					if not Content:exist(sourceDoraPath) then -- 2536
						return { -- 2537
							success = false, -- 2537
							message = "missing dora template" -- 2537
						} -- 2537
					end -- 2536
					local targetVendorPath = Path(projDir, "vendor") -- 2538
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2539
					if not Content:exist(targetVendorPath) then -- 2540
						if not Content:mkdir(targetVendorPath) then -- 2541
							return { -- 2542
								success = false, -- 2542
								message = "failed to create vendor folder" -- 2542
							} -- 2542
						end -- 2541
					elseif not Content:isdir(targetVendorPath) then -- 2543
						return { -- 2544
							success = false, -- 2544
							message = "vendor path is not a folder" -- 2544
						} -- 2544
					end -- 2540
					if Content:exist(targetDoraPath) then -- 2545
						if not Content:remove(targetDoraPath) then -- 2546
							return { -- 2547
								success = false, -- 2547
								message = "failed to remove old dora" -- 2547
							} -- 2547
						end -- 2546
					end -- 2545
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2548
						return { -- 2549
							success = false, -- 2549
							message = "failed to copy dora" -- 2549
						} -- 2549
					end -- 2548
					return { -- 2550
						success = true -- 2550
					} -- 2550
				else -- 2552
					return { -- 2552
						success = false, -- 2552
						message = 'Wa file needs a project' -- 2552
					} -- 2552
				end -- 2534
			end -- 2533
		end -- 2533
	end -- 2533
	return { -- 2532
		success = false, -- 2532
		message = "invalid call" -- 2532
	} -- 2532
end) -- 2532
HttpServer:postSchedule("/wa/build", function(req) -- 2554
	do -- 2555
		local _type_0 = type(req) -- 2555
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2555
		if _tab_0 then -- 2555
			local path -- 2555
			do -- 2555
				local _obj_0 = req.body -- 2555
				local _type_1 = type(_obj_0) -- 2555
				if "table" == _type_1 or "userdata" == _type_1 then -- 2555
					path = _obj_0.path -- 2555
				end -- 2555
			end -- 2555
			if path ~= nil then -- 2555
				local projDir = getWaProjectDirFromFile(path) -- 2556
				if projDir then -- 2556
					local message = Wasm:buildWaAsync(projDir) -- 2557
					if message == "" then -- 2558
						return { -- 2559
							success = true -- 2559
						} -- 2559
					else -- 2561
						return { -- 2561
							success = false, -- 2561
							message = message -- 2561
						} -- 2561
					end -- 2558
				else -- 2563
					return { -- 2563
						success = false, -- 2563
						message = 'Wa file needs a project' -- 2563
					} -- 2563
				end -- 2556
			end -- 2555
		end -- 2555
	end -- 2555
	return { -- 2564
		success = false, -- 2564
		message = 'failed to build' -- 2564
	} -- 2564
end) -- 2554
HttpServer:postSchedule("/wa/format", function(req) -- 2566
	do -- 2567
		local _type_0 = type(req) -- 2567
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2567
		if _tab_0 then -- 2567
			local file -- 2567
			do -- 2567
				local _obj_0 = req.body -- 2567
				local _type_1 = type(_obj_0) -- 2567
				if "table" == _type_1 or "userdata" == _type_1 then -- 2567
					file = _obj_0.file -- 2567
				end -- 2567
			end -- 2567
			if file ~= nil then -- 2567
				local code = Wasm:formatWaAsync(file) -- 2568
				if code == "" then -- 2569
					return { -- 2570
						success = false -- 2570
					} -- 2570
				else -- 2572
					return { -- 2572
						success = true, -- 2572
						code = code -- 2572
					} -- 2572
				end -- 2569
			end -- 2567
		end -- 2567
	end -- 2567
	return { -- 2573
		success = false -- 2573
	} -- 2573
end) -- 2566
HttpServer:postSchedule("/wa/create", function(req) -- 2575
	do -- 2576
		local _type_0 = type(req) -- 2576
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2576
		if _tab_0 then -- 2576
			local path -- 2576
			do -- 2576
				local _obj_0 = req.body -- 2576
				local _type_1 = type(_obj_0) -- 2576
				if "table" == _type_1 or "userdata" == _type_1 then -- 2576
					path = _obj_0.path -- 2576
				end -- 2576
			end -- 2576
			if path ~= nil then -- 2576
				if not Content:exist(Path:getPath(path)) then -- 2577
					return { -- 2578
						success = false, -- 2578
						message = "target path not existed" -- 2578
					} -- 2578
				end -- 2577
				if Content:exist(path) then -- 2579
					return { -- 2580
						success = false, -- 2580
						message = "target project folder existed" -- 2580
					} -- 2580
				end -- 2579
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2581
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2582
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2583
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2584
					return { -- 2587
						success = false, -- 2587
						message = "missing template project" -- 2587
					} -- 2587
				end -- 2584
				if not Content:mkdir(path) then -- 2588
					return { -- 2589
						success = false, -- 2589
						message = "failed to create project folder" -- 2589
					} -- 2589
				end -- 2588
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2590
					Content:remove(path) -- 2591
					return { -- 2592
						success = false, -- 2592
						message = "failed to copy template" -- 2592
					} -- 2592
				end -- 2590
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2593
					Content:remove(path) -- 2594
					return { -- 2595
						success = false, -- 2595
						message = "failed to copy template" -- 2595
					} -- 2595
				end -- 2593
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2596
					Content:remove(path) -- 2597
					return { -- 2598
						success = false, -- 2598
						message = "failed to copy template" -- 2598
					} -- 2598
				end -- 2596
				return { -- 2599
					success = true -- 2599
				} -- 2599
			end -- 2576
		end -- 2576
	end -- 2576
	return { -- 2575
		success = false, -- 2575
		message = "invalid call" -- 2575
	} -- 2575
end) -- 2575
local tsBuildGlobs = { -- 2602
	"**/*.ts", -- 2602
	"**/*.tsx", -- 2603
	"!**/.*/**", -- 2604
	"!**/node_modules/**" -- 2605
} -- 2601
local tsSnapshotGlobs = { -- 2608
	"**/*.ts", -- 2608
	"**/*.tsx", -- 2609
	"**/*.lua", -- 2610
	"!**/.*/**", -- 2611
	"!**/node_modules/**" -- 2612
} -- 2607
local collectTSVirtualFiles -- 2614
collectTSVirtualFiles = function(sourceRoot) -- 2614
	local files = { } -- 2615
	local seen = { } -- 2616
	local addFile -- 2617
	addFile = function(file, moduleName, virtualFile) -- 2617
		if moduleName == nil then -- 2617
			moduleName = nil -- 2617
		end -- 2617
		if virtualFile == nil then -- 2617
			virtualFile = nil -- 2617
		end -- 2617
		local targetFile = virtualFile or file -- 2618
		do -- 2619
			local entry = seen[targetFile] -- 2619
			if entry then -- 2619
				if moduleName and moduleName ~= "" then -- 2620
					entry.moduleName = moduleName -- 2620
				end -- 2620
				return -- 2621
			end -- 2619
		end -- 2619
		local content = Content:load(file) -- 2622
		if content then -- 2622
			local entry = { -- 2623
				file = targetFile, -- 2623
				content = content -- 2623
			} -- 2623
			if moduleName and moduleName ~= "" then -- 2624
				entry.moduleName = moduleName -- 2624
			end -- 2624
			seen[targetFile] = entry -- 2625
			files[#files + 1] = entry -- 2626
		end -- 2622
	end -- 2617
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2627
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2628
		for _index_0 = 1, #_list_0 do -- 2628
			local subFile = _list_0[_index_0] -- 2628
			addFile(Path(sourceRoot, subFile)) -- 2629
		end -- 2628
		local libraryRoots = { -- 2631
			Path(sourceRoot, "Script", "Lib"), -- 2631
			Path(sourceRoot, "Lib"), -- 2632
			Path(Content.assetPath, "Script", "Lib") -- 2633
		} -- 2630
		for _index_0 = 1, #libraryRoots do -- 2634
			local libraryRoot = libraryRoots[_index_0] -- 2634
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2635
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2636
				for _index_1 = 1, #_list_1 do -- 2636
					local subFile = _list_1[_index_1] -- 2636
					local file = Path(libraryRoot, subFile) -- 2637
					local virtualFile = Path(sourceRoot, subFile) -- 2638
					addFile(file, nil, virtualFile) -- 2639
				end -- 2636
			end -- 2635
		end -- 2634
	end -- 2627
	local locale -- 2640
	if App.locale:match('^zh') then -- 2640
		locale = 'zh-Hans' -- 2640
	else -- 2640
		locale = 'en' -- 2640
	end -- 2640
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2641
	local _list_0 = Content:getFiles(declarationRoot) -- 2642
	for _index_0 = 1, #_list_0 do -- 2642
		local file = _list_0[_index_0] -- 2642
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2643
			local fullPath = Path(declarationRoot, file) -- 2644
			local moduleName = Path:getName(Path:getName(file)) -- 2645
			addFile(fullPath, moduleName) -- 2646
		end -- 2643
	end -- 2642
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2647
	local lualibBundleTarget -- 2648
	if sourceRoot then -- 2648
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2648
	else -- 2648
		lualibBundleTarget = "lualib_bundle.lua" -- 2648
	end -- 2648
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2649
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2650
	local _list_1 = Content:getFiles(lualibRoot) -- 2651
	for _index_0 = 1, #_list_1 do -- 2651
		local file = _list_1[_index_0] -- 2651
		if Path:getExt(file) == "lua" then -- 2652
			local virtualFile -- 2653
			if sourceRoot then -- 2653
				virtualFile = Path(sourceRoot, "lualib", file) -- 2653
			else -- 2653
				virtualFile = Path("lualib", file) -- 2653
			end -- 2653
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2654
		end -- 2652
	end -- 2651
	return files -- 2655
end -- 2614
local supportsCompilerWebView -- 2657
supportsCompilerWebView = function() -- 2657
	local _val_0 = App.platform -- 2657
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2657
end -- 2657
local webIDECompilerReady = false -- 2658
local webIDEConnectionGeneration = 0 -- 2659
local tsProbeId = 0 -- 2660
local probeWebIDECompiler -- 2662
probeWebIDECompiler = function(isCancelled) -- 2662
	if HttpServer.wsConnectionCount == 0 then -- 2663
		return false -- 2663
	end -- 2663
	tsProbeId = tsProbeId + 1 -- 2664
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2665
	local generation = webIDEConnectionGeneration -- 2666
	local done, ready = false, false -- 2667
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2668
	local listener = Node() -- 2669
	listener:gslot("AppWS", function(event) -- 2670
		if event.type == "Receive" then -- 2671
			local res = json.decode(event.msg) -- 2672
			if res then -- 2672
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2673
					responses = responses + 1 -- 2674
					ready = ready or res.success == true -- 2675
					done = ready or responses >= expectedResponses -- 2676
				end -- 2673
			end -- 2672
		end -- 2671
	end) -- 2670
	emit("AppWS", "Send", json.encode({ -- 2677
		name = "TranspileTSProbe", -- 2677
		id = requestId -- 2677
	})) -- 2677
	local deadline = App.runningTime + 5 -- 2678
	wait(function() -- 2679
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2679
	end) -- 2679
	listener:removeFromParent() -- 2680
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2681
	if generation == webIDEConnectionGeneration then -- 2682
		webIDECompilerReady = ready -- 2682
	end -- 2682
	return ready -- 2683
end -- 2662
local compilerConnectionListener = Node() -- 2685
compilerConnectionListener:addTo(Director.systemUI) -- 2687
local _anon_func_8 = function(event) -- 2689
	local _val_0 = event.type -- 2689
	return "Open" == _val_0 or "Close" == _val_0 -- 2689
end -- 2689
compilerConnectionListener:gslot("AppWS", function(event) -- 2688
	if _anon_func_8(event) then -- 2689
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2690
		webIDECompilerReady = false -- 2691
		if HttpServer.wsConnectionCount > 0 then -- 2692
			return thread(function() -- 2693
				return probeWebIDECompiler() -- 2693
			end) -- 2693
		end -- 2692
	end -- 2689
end) -- 2688
local _anon_func_9 = function(res) -- 2718
	if res.success then -- 2718
		return "tool" -- 2718
	else -- 2718
		return res.failureKind -- 2718
	end -- 2718
end -- 2718
local transpileTSFileWithWebIDE -- 2695
do -- 2695
	local tsBuildRequestId = 0 -- 2696
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2697
		if not probeWebIDECompiler(isCancelled) then -- 2698
			if isCancelled and isCancelled() then -- 2699
				return { -- 2700
					success = false, -- 2700
					file = file, -- 2700
					message = "build canceled", -- 2700
					interrupted = true -- 2700
				} -- 2700
			end -- 2699
			return { -- 2701
				success = false, -- 2701
				file = file, -- 2701
				message = "TypeScript transpiler is not ready", -- 2701
				failureKind = "tool" -- 2701
			} -- 2701
		end -- 2698
		tsBuildRequestId = tsBuildRequestId + 1 -- 2702
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2703
		local done = false -- 2704
		local result = nil -- 2705
		local listener = Node() -- 2706
		listener:gslot("AppWS", function(event) -- 2707
			if event.type == "Receive" then -- 2708
				local res = json.decode(event.msg) -- 2709
				if res then -- 2709
					if res.name == "TranspileTS" and res.id == requestId then -- 2710
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2711
							local luaFile = Path:replaceExt(file, "lua") -- 2712
							if Content:save(luaFile, res.luaCode) then -- 2713
								result = { -- 2714
									success = true, -- 2714
									file = file -- 2714
								} -- 2714
							else -- 2716
								result = { -- 2716
									success = false, -- 2716
									file = file, -- 2716
									message = "failed to save " .. tostring(luaFile) -- 2716
								} -- 2716
							end -- 2713
						else -- 2718
							result = { -- 2718
								success = false, -- 2718
								file = file, -- 2718
								message = res.message or "Compiler returned no Lua output", -- 2718
								failureKind = _anon_func_9(res) -- 2718
							} -- 2718
						end -- 2711
						done = true -- 2719
					end -- 2710
				end -- 2709
			end -- 2708
		end) -- 2707
		emit("AppWS", "Send", json.encode({ -- 2720
			name = "TranspileTS", -- 2720
			id = requestId, -- 2720
			file = file, -- 2720
			content = content, -- 2720
			projectRoot = sourceRoot, -- 2720
			files = files -- 2720
		})) -- 2720
		local deadline = App.runningTime + 30 -- 2721
		wait(function() -- 2722
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2722
		end) -- 2722
		listener:removeFromParent() -- 2723
		if not done then -- 2724
			webIDECompilerReady = false -- 2725
			if isCancelled and isCancelled() then -- 2726
				return { -- 2727
					success = false, -- 2727
					file = file, -- 2727
					message = "build canceled", -- 2727
					interrupted = true -- 2727
				} -- 2727
			end -- 2726
			return { -- 2728
				success = false, -- 2728
				file = file, -- 2728
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2728
				failureKind = "tool" -- 2728
			} -- 2728
		end -- 2724
		return result -- 2729
	end -- 2697
end -- 2695
local compilerReadyTimeout <const> = 15 -- 2731
local compilerBuildTimeout <const> = 30 -- 2732
local compilerIdleCloseSeconds <const> = 8 -- 2733
local compilerReady = false -- 2734
local compilerRequested = false -- 2735
local compilerFailure = nil -- 2736
local compilerUsers = 0 -- 2737
local compilerCloseGeneration = 0 -- 2738
local compilerJobId = 0 -- 2739
local compilerJobs = { } -- 2740
local compilerResults = { } -- 2741
local compilerInFlight = { } -- 2742
HttpServer:post("/compiler/ready", function() -- 2744
	if not compilerRequested then -- 2745
		return { -- 2745
			success = false -- 2745
		} -- 2745
	end -- 2745
	compilerReady = true -- 2746
	return { -- 2747
		success = true -- 2747
	} -- 2747
end) -- 2744
HttpServer:post("/compiler/failure", function(req) -- 2749
	if not compilerRequested then -- 2750
		return { -- 2750
			success = false -- 2750
		} -- 2750
	end -- 2750
	do -- 2751
		local _type_0 = type(req) -- 2751
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2751
		if _tab_0 then -- 2751
			local message -- 2751
			do -- 2751
				local _obj_0 = req.body -- 2751
				local _type_1 = type(_obj_0) -- 2751
				if "table" == _type_1 or "userdata" == _type_1 then -- 2751
					message = _obj_0.message -- 2751
				end -- 2751
			end -- 2751
			if message ~= nil then -- 2751
				if type(message) == "string" then -- 2752
					compilerFailure = message -- 2753
					compilerReady = false -- 2754
					return { -- 2755
						success = true -- 2755
					} -- 2755
				end -- 2752
			end -- 2751
		end -- 2751
	end -- 2751
	return { -- 2749
		success = false -- 2749
	} -- 2749
end) -- 2749
HttpServer:postSchedule("/compiler/poll", function() -- 2757
	if not compilerRequested then -- 2758
		return { -- 2758
			success = false -- 2758
		} -- 2758
	end -- 2758
	compilerReady = true -- 2759
	local deadline = App.runningTime + 5 -- 2760
	wait(function() -- 2761
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2761
	end) -- 2761
	if not (compilerRequested and not compilerFailure) then -- 2762
		return { -- 2762
			success = false -- 2762
		} -- 2762
	end -- 2762
	local job = table.remove(compilerJobs, 1) -- 2763
	if job then -- 2764
		compilerInFlight[job.id] = true -- 2765
	end -- 2764
	return { -- 2766
		success = true, -- 2766
		job = job -- 2766
	} -- 2766
end) -- 2757
HttpServer:post("/compiler/result", function(req) -- 2768
	do -- 2769
		local _type_0 = type(req) -- 2769
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2769
		if _tab_0 then -- 2769
			local body = req.body -- 2769
			if body ~= nil then -- 2769
				local id = body.id -- 2770
				if not (id and compilerInFlight[id]) then -- 2771
					return { -- 2771
						success = false, -- 2771
						message = "invalid compiler job" -- 2771
					} -- 2771
				end -- 2771
				compilerInFlight[id] = nil -- 2772
				compilerResults[id] = body -- 2773
				return { -- 2774
					success = true -- 2774
				} -- 2774
			end -- 2769
		end -- 2769
	end -- 2769
	return { -- 2768
		success = false -- 2768
	} -- 2768
end) -- 2768
local acquireCompiler -- 2776
acquireCompiler = function() -- 2776
	compilerUsers = compilerUsers + 1 -- 2777
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2778
	if not compilerRequested then -- 2779
		compilerRequested = true -- 2780
		compilerReady = false -- 2781
		compilerFailure = nil -- 2782
		return emit("AppWebView", "/compiler.html", true) -- 2783
	end -- 2779
end -- 2776
local releaseCompiler -- 2785
releaseCompiler = function() -- 2785
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2786
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2787
	if not (compilerUsers == 0) then -- 2788
		return -- 2788
	end -- 2788
	local closeGeneration = compilerCloseGeneration -- 2789
	return thread(function() -- 2790
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2791
		wait(function() -- 2792
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2793
		end) -- 2792
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2798
			compilerRequested = false -- 2799
			compilerReady = false -- 2800
			return emit("AppWebView", "/compiler.html", false) -- 2801
		end -- 2798
	end) -- 2790
end -- 2785
local removeCompilerJob -- 2803
removeCompilerJob = function(id) -- 2803
	for index = #compilerJobs, 1, -1 do -- 2804
		if compilerJobs[index].id == id then -- 2805
			table.remove(compilerJobs, index) -- 2806
		end -- 2805
	end -- 2804
	compilerInFlight[id] = nil -- 2807
	compilerResults[id] = nil -- 2808
end -- 2803
local transpileTSFileWithCompiler -- 2810
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2810
	acquireCompiler() -- 2811
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2812
	wait(function() -- 2813
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2813
	end) -- 2813
	if not compilerReady then -- 2814
		releaseCompiler() -- 2815
		if isCancelled and isCancelled() then -- 2816
			return { -- 2817
				success = false, -- 2817
				file = file, -- 2817
				message = "build canceled", -- 2817
				interrupted = true -- 2817
			} -- 2817
		end -- 2816
		return { -- 2818
			success = false, -- 2818
			file = file, -- 2818
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2818
			failureKind = "tool" -- 2818
		} -- 2818
	end -- 2814
	compilerJobId = compilerJobId + 1 -- 2819
	local jobId = compilerJobId -- 2820
	compilerJobs[#compilerJobs + 1] = { -- 2822
		id = jobId, -- 2822
		file = file, -- 2823
		content = content, -- 2824
		projectRoot = sourceRoot, -- 2825
		files = files -- 2826
	} -- 2821
	local deadline = App.runningTime + compilerBuildTimeout -- 2827
	wait(function() -- 2828
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2828
	end) -- 2828
	local response = compilerResults[jobId] -- 2829
	removeCompilerJob(jobId) -- 2830
	releaseCompiler() -- 2831
	if not response then -- 2832
		if isCancelled and isCancelled() then -- 2833
			return { -- 2834
				success = false, -- 2834
				file = file, -- 2834
				message = "build canceled", -- 2834
				interrupted = true -- 2834
			} -- 2834
		end -- 2833
		return { -- 2835
			success = false, -- 2835
			file = file, -- 2835
			message = compilerFailure or "TypeScript transpile timed out", -- 2835
			failureKind = "tool" -- 2835
		} -- 2835
	end -- 2832
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2836
		local luaFile = Path:replaceExt(file, "lua") -- 2837
		if Content:save(luaFile, response.luaCode) then -- 2838
			return { -- 2839
				success = true, -- 2839
				file = file -- 2839
			} -- 2839
		end -- 2838
		return { -- 2840
			success = false, -- 2840
			file = file, -- 2840
			message = "failed to save " .. tostring(luaFile) -- 2840
		} -- 2840
	end -- 2836
	return { -- 2841
		success = false, -- 2841
		file = file, -- 2841
		message = response.message or "TypeScript transpile failed" -- 2841
	} -- 2841
end -- 2810
local compilerFailureListener = Node() -- 2843
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2844
	compilerFailure = message -- 2845
	compilerReady = false -- 2846
end) -- 2844
local transpileTSFile -- 2848
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2848
	if supportsCompilerWebView() and not files then -- 2849
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2850
	end -- 2849
	if HttpServer.wsConnectionCount > 0 then -- 2851
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2852
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2853
			return result -- 2853
		end -- 2853
		webIDECompilerReady = false -- 2854
	end -- 2851
	if supportsCompilerWebView() then -- 2855
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2856
	end -- 2855
	return { -- 2857
		success = false, -- 2857
		file = file, -- 2857
		message = "Web IDE compiler not connected", -- 2857
		failureKind = "tool" -- 2857
	} -- 2857
end -- 2848
local _anon_func_10 = function(path) -- 2872
	local _val_0 = Path:getExt(path) -- 2872
	return "ts" == _val_0 or "tsx" == _val_0 -- 2872
end -- 2872
HttpServer:postSchedule("/ts/build", function(req) -- 2859
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2860
	local buildSucceeded = false -- 2861
	local _ <close> = setmetatable({ }, { -- 2862
		__close = function() -- 2862
			return finishUpdate(buildSucceeded) -- 2862
		end -- 2862
	}) -- 2862
	do -- 2863
		local _type_0 = type(req) -- 2863
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2863
		if _tab_0 then -- 2863
			local path -- 2863
			do -- 2863
				local _obj_0 = req.body -- 2863
				local _type_1 = type(_obj_0) -- 2863
				if "table" == _type_1 or "userdata" == _type_1 then -- 2863
					path = _obj_0.path -- 2863
				end -- 2863
			end -- 2863
			if path ~= nil then -- 2863
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2864
					return { -- 2865
						success = false, -- 2865
						message = "Web IDE not connected" -- 2865
					} -- 2865
				end -- 2864
				local projectRoot = req.body.projectRoot -- 2866
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2867
				if not Content:exist(path) then -- 2868
					return { -- 2869
						success = false, -- 2869
						message = "path not existed" -- 2869
					} -- 2869
				end -- 2868
				local messages = { } -- 2870
				if not Content:isdir(path) then -- 2871
					if not (_anon_func_10(path)) then -- 2872
						return { -- 2873
							success = false, -- 2873
							message = "expecting a TypeScript file" -- 2873
						} -- 2873
					end -- 2872
					local content = Content:load(path) -- 2874
					if not content then -- 2875
						return { -- 2876
							success = false, -- 2876
							message = "failed to read file" -- 2876
						} -- 2876
					end -- 2875
					emit("AppWS", "Send", json.encode({ -- 2877
						name = "UpdateFile", -- 2877
						file = path, -- 2877
						exists = true, -- 2877
						content = content, -- 2877
						projectRoot = sourceRoot -- 2877
					})) -- 2877
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2878
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2879
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2880
					end -- 2878
				else -- 2882
					local fileData = { } -- 2882
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2883
					for _index_0 = 1, #_list_0 do -- 2883
						local subFile = _list_0[_index_0] -- 2883
						local file = Path(path, subFile) -- 2884
						local content = Content:load(file) -- 2885
						if content then -- 2885
							fileData[file] = content -- 2886
							emit("AppWS", "Send", json.encode({ -- 2887
								name = "UpdateFile", -- 2887
								file = file, -- 2887
								exists = true, -- 2887
								content = content, -- 2887
								projectRoot = sourceRoot -- 2887
							})) -- 2887
						else -- 2889
							messages[#messages + 1] = { -- 2889
								success = false, -- 2889
								file = file, -- 2889
								message = "failed to read file" -- 2889
							} -- 2889
						end -- 2885
					end -- 2883
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2890
					for file, content in pairs(fileData) do -- 2891
						if "d" == Path:getExt(Path:getName(file)) then -- 2892
							goto _continue_0 -- 2892
						end -- 2892
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2893
						::_continue_0:: -- 2892
					end -- 2891
				end -- 2871
				local success = true -- 2894
				for _index_0 = 1, #messages do -- 2895
					local item = messages[_index_0] -- 2895
					if not item.success then -- 2896
						success = false -- 2896
					end -- 2896
				end -- 2895
				local message = nil -- 2897
				if not success then -- 2898
					message = "TypeScript compilation failed" -- 2898
				end -- 2898
				buildSucceeded = success -- 2899
				return { -- 2900
					success = success, -- 2900
					messages = messages, -- 2900
					message = message -- 2900
				} -- 2900
			end -- 2863
		end -- 2863
	end -- 2863
	return { -- 2859
		success = false -- 2859
	} -- 2859
end) -- 2859
HttpServer:post("/download", function(req) -- 2902
	do -- 2903
		local _type_0 = type(req) -- 2903
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2903
		if _tab_0 then -- 2903
			local url -- 2903
			do -- 2903
				local _obj_0 = req.body -- 2903
				local _type_1 = type(_obj_0) -- 2903
				if "table" == _type_1 or "userdata" == _type_1 then -- 2903
					url = _obj_0.url -- 2903
				end -- 2903
			end -- 2903
			local target -- 2903
			do -- 2903
				local _obj_0 = req.body -- 2903
				local _type_1 = type(_obj_0) -- 2903
				if "table" == _type_1 or "userdata" == _type_1 then -- 2903
					target = _obj_0.target -- 2903
				end -- 2903
			end -- 2903
			if url ~= nil and target ~= nil then -- 2903
				local Entry = require("Script.Dev.Entry") -- 2904
				Entry.downloadFile(url, target) -- 2905
				return { -- 2906
					success = true -- 2906
				} -- 2906
			end -- 2903
		end -- 2903
	end -- 2903
	return { -- 2902
		success = false -- 2902
	} -- 2902
end) -- 2902
local isDesktopPlatform -- 2908
isDesktopPlatform = function() -- 2908
	local _val_0 = App.platform -- 2909
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2909
end -- 2908
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 2911
local nativeIDEListener = Node() -- 2912
nativeIDEListener:addTo(Director.systemUI) -- 2913
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 2914
	nativeIDEState, nativeIDEMessage = state, message -- 2915
end) -- 2914
local _anon_func_11 = function() -- 2918
	local _val_0 = App.platform -- 2918
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2918
end -- 2918
HttpServer:post("/ide", function(req) -- 2917
	if not (_anon_func_11()) then -- 2918
		return { -- 2918
			success = false, -- 2918
			message = "Native IDE is unavailable" -- 2918
		} -- 2918
	end -- 2918
	if not App.webIDEEnabled then -- 2919
		return { -- 2919
			success = false, -- 2919
			message = "Embedded Web IDE is disabled" -- 2919
		} -- 2919
	end -- 2919
	do -- 2920
		local _type_0 = type(req) -- 2920
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2920
		if _tab_0 then -- 2920
			local action -- 2920
			do -- 2920
				local _obj_0 = req.body -- 2920
				local _type_1 = type(_obj_0) -- 2920
				if "table" == _type_1 or "userdata" == _type_1 then -- 2920
					action = _obj_0.action -- 2920
				end -- 2920
			end -- 2920
			if action ~= nil then -- 2920
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 2921
					emit("AppWebView", "/ide/" .. action, true) -- 2922
					return { -- 2923
						success = true -- 2923
					} -- 2923
				end -- 2921
			end -- 2920
		end -- 2920
	end -- 2920
	return { -- 2917
		success = false, -- 2917
		message = "invalid IDE action" -- 2917
	} -- 2917
end) -- 2917
local _anon_func_12 = function() -- 2939
	local _val_0 = App.platform -- 2939
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2939
end -- 2939
local getServerStatus -- 2925
getServerStatus = function() -- 2925
	local Entry = require("Script.Dev.Entry") -- 2926
	local running = Entry.getCurrentEntryStatus() -- 2927
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2928
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2929
	return { -- 2931
		success = true, -- 2931
		platform = App.platform, -- 2932
		locale = App.locale, -- 2933
		version = App.version, -- 2934
		url = "http://localhost:8866", -- 2935
		wsConnectionCount = wsConnectionCount, -- 2936
		webIDEConnected = wsConnectionCount > 0, -- 2937
		nativeIDE = { -- 2939
			supported = _anon_func_12(), -- 2939
			enabled = App.webIDEEnabled, -- 2940
			state = nativeIDEState, -- 2941
			message = nativeIDEMessage -- 2942
		}, -- 2938
		typescriptCompiler = { -- 2944
			webIDEReady = webIDECompilerReady, -- 2944
			webIDEGeneration = webIDEConnectionGeneration, -- 2945
			embeddedSupported = supportsCompilerWebView(), -- 2946
			embeddedRequested = compilerRequested, -- 2947
			embeddedReady = compilerReady, -- 2948
			users = compilerUsers, -- 2949
			queuedJobs = #compilerJobs, -- 2950
			failure = compilerFailure -- 2951
		}, -- 2943
		assetPath = Content.assetPath, -- 2952
		writablePath = Content.writablePath, -- 2953
		appPath = Content.appPath, -- 2954
		waTemplateReady = waTemplateReady, -- 2955
		running = running -- 2956
	} -- 2930
end -- 2925
HttpServer:post("/status", function() -- 2959
	return getServerStatus() -- 2960
end) -- 2959
HttpServer:postSchedule("/doctor/fix", function(req) -- 2962
	do -- 2963
		local _type_0 = type(req) -- 2963
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2963
		if _tab_0 then -- 2963
			local openWebIDE -- 2963
			do -- 2963
				local _obj_0 = req.body -- 2963
				local _type_1 = type(_obj_0) -- 2963
				if "table" == _type_1 or "userdata" == _type_1 then -- 2963
					openWebIDE = _obj_0.openWebIDE -- 2963
				end -- 2963
			end -- 2963
			if openWebIDE ~= nil then -- 2963
				if not openWebIDE then -- 2964
					return { -- 2965
						success = false, -- 2965
						message = "nothing to fix" -- 2965
					} -- 2965
				end -- 2964
				local status = getServerStatus() -- 2966
				if status.webIDEConnected then -- 2967
					return { -- 2968
						success = true, -- 2968
						fixed = false, -- 2968
						message = "Web IDE already connected.", -- 2968
						status = status -- 2968
					} -- 2968
				end -- 2967
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2969
				if waitSeconds > 0 then -- 2970
					local deadline = os.time() + waitSeconds -- 2971
					repeat -- 2972
						sleep(0.2) -- 2973
						status = getServerStatus() -- 2974
						if status.webIDEConnected then -- 2975
							return { -- 2976
								success = true, -- 2976
								fixed = false, -- 2976
								reconnected = true, -- 2976
								message = "Web IDE reconnected.", -- 2976
								status = status -- 2976
							} -- 2976
						end -- 2975
					until os.time() >= deadline -- 2972
				end -- 2970
				if not isDesktopPlatform() then -- 2978
					return { -- 2979
						success = false, -- 2979
						message = "opening Web IDE is only supported on desktop platforms", -- 2979
						status = status -- 2979
					} -- 2979
				end -- 2978
				local url = "http://localhost:8866" -- 2980
				App:openURL(url) -- 2981
				status.openedURL = url -- 2982
				return { -- 2983
					success = true, -- 2983
					fixed = true, -- 2983
					message = "Opened Web IDE in the local browser.", -- 2983
					url = url, -- 2983
					status = status -- 2983
				} -- 2983
			end -- 2963
		end -- 2963
	end -- 2963
	return { -- 2962
		success = false, -- 2962
		message = "invalid call" -- 2962
	} -- 2962
end) -- 2962
local status = { } -- 2985
_module_0 = status -- 2986
status.transpileTSFile = transpileTSFile -- 2988
status.buildAsync = function(path) -- 2990
	if not Content:exist(path) then -- 2991
		return { -- 2992
			success = false, -- 2992
			file = path, -- 2992
			message = "file not existed" -- 2992
		} -- 2992
	end -- 2991
	do -- 2993
		local _exp_0 = Path:getExt(path) -- 2993
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2993
			if '' == Path:getExt(Path:getName(path)) then -- 2994
				local content = Content:loadAsync(path) -- 2995
				if content then -- 2995
					local resultCodes, err = compileFileAsync(path, content) -- 2996
					if resultCodes then -- 2996
						return { -- 2997
							success = true, -- 2997
							file = path -- 2997
						} -- 2997
					else -- 2999
						return { -- 2999
							success = false, -- 2999
							file = path, -- 2999
							message = err -- 2999
						} -- 2999
					end -- 2996
				end -- 2995
			end -- 2994
		elseif "lua" == _exp_0 then -- 3000
			local content = Content:loadAsync(path) -- 3001
			if content then -- 3001
				do -- 3002
					local isTIC80 = CheckTIC80Code(content) -- 3002
					if isTIC80 then -- 3002
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 3003
					end -- 3002
				end -- 3002
				local success, info -- 3004
				do -- 3004
					local _obj_0 = luaCheck(path, content) -- 3004
					success, info = _obj_0.success, _obj_0.info -- 3004
				end -- 3004
				if success then -- 3005
					return { -- 3006
						success = true, -- 3006
						file = path -- 3006
					} -- 3006
				elseif info and #info > 0 then -- 3007
					local messages = { } -- 3008
					for _index_0 = 1, #info do -- 3009
						local _des_0 = info[_index_0] -- 3009
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3009
						local lineText = "" -- 3010
						if line then -- 3011
							local currentLine = 1 -- 3012
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3013
								if currentLine == line then -- 3014
									lineText = text -- 3015
									break -- 3016
								end -- 3014
								currentLine = currentLine + 1 -- 3017
							end -- 3013
						end -- 3011
						if line then -- 3018
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3019
						else -- 3021
							messages[#messages + 1] = message -- 3021
						end -- 3018
					end -- 3009
					return { -- 3022
						success = false, -- 3022
						file = path, -- 3022
						message = table.concat(messages, "\n") -- 3022
					} -- 3022
				else -- 3024
					return { -- 3024
						success = false, -- 3024
						file = path, -- 3024
						message = "lua check failed" -- 3024
					} -- 3024
				end -- 3005
			end -- 3001
		elseif "yarn" == _exp_0 then -- 3025
			local content = Content:loadAsync(path) -- 3026
			if content then -- 3026
				local res, _, err = yarncompile(content, true) -- 3027
				if res then -- 3027
					return { -- 3028
						success = true, -- 3028
						file = path -- 3028
					} -- 3028
				else -- 3030
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3030
					local lineText = "" -- 3031
					if line then -- 3032
						local currentLine = 1 -- 3033
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3034
							if currentLine == line then -- 3035
								lineText = text -- 3036
								break -- 3037
							end -- 3035
							currentLine = currentLine + 1 -- 3038
						end -- 3034
					end -- 3032
					if node ~= "" then -- 3039
						node = "node: " .. tostring(node) .. ", " -- 3040
					else -- 3041
						node = "" -- 3041
					end -- 3039
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3042
					return { -- 3043
						success = false, -- 3043
						file = path, -- 3043
						message = message -- 3043
					} -- 3043
				end -- 3027
			end -- 3026
		end -- 2993
	end -- 2993
	return { -- 3044
		success = false, -- 3044
		file = path, -- 3044
		message = "invalid file to build" -- 3044
	} -- 3044
end -- 2990
HttpServer:postSchedule("/git/commit-files", function(req) -- 3046
	do -- 3047
		local _type_0 = type(req) -- 3047
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3047
		if _tab_0 then -- 3047
			local body = req.body -- 3047
			if body ~= nil then -- 3047
				local repoPath, commit = body.repoPath, body.commit -- 3048
				if gitInvalidRepoPath(repoPath) then -- 3049
					return { -- 3049
						success = false, -- 3049
						message = "invalid repoPath" -- 3049
					} -- 3049
				end -- 3049
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3050
					return { -- 3050
						success = false, -- 3050
						message = "invalid commit" -- 3050
					} -- 3050
				end -- 3050
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3051
				if not res.success then -- 3052
					return res -- 3052
				end -- 3052
				return { -- 3053
					success = true, -- 3053
					status = res.status, -- 3053
					data = res.status and res.status.data -- 3053
				} -- 3053
			end -- 3047
		end -- 3047
	end -- 3047
	return invalidArguments -- 3046
end) -- 3046
thread(function() -- 3055
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3056
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3057
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3058
		local storedAsset -- 3061
		storedAsset = function(file) -- 3061
			if Content:exist(file) then -- 3062
				return Content:load(file) -- 3063
			elseif Content:exist(file .. ".gz") then -- 3064
				return Content:load(file .. ".gz") -- 3065
			else -- 3066
				return "" -- 3066
			end -- 3062
		end -- 3061
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3067
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3068
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3069
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3070
		local readyContent = table.concat({ -- 3072
			App.version, -- 3072
			storedAsset(doraWeb), -- 3073
			storedAsset(heavyAssets), -- 3074
			storedAsset(runtimeIndex), -- 3075
			storedAsset(compilerIndex), -- 3076
			storedAsset(manifest) -- 3077
		}, "\n") -- 3071
		local needReload -- 3079
		if Content:exist(doraReady) then -- 3079
			needReload = readyContent ~= Content:load(doraReady) -- 3080
		else -- 3081
			needReload = true -- 3081
		end -- 3079
		if needReload then -- 3082
			Content:remove(Path(Content.appPath, ".www")) -- 3083
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3084
			Content:save(doraReady, readyContent) -- 3088
			print("Dora Dora is ready!") -- 3089
		end -- 3082
	end -- 3058
	if App.platform == "Emscripten" then -- 3090
		status.url = nil -- 3091
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3092
	end -- 3090
	HttpServer:clearStaticCacheControls() -- 3093
	HttpServer:setStaticCacheControl("no-cache") -- 3094
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3095
	if HttpServer:start(8866) then -- 3099
		local localIP = HttpServer.localIP -- 3100
		if localIP == "" then -- 3101
			localIP = "localhost" -- 3101
		end -- 3101
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3102
		return HttpServer:startWS(8868) -- 3103
	else -- 3105
		status.url = nil -- 3105
		return print("8866 Port not available!") -- 3106
	end -- 3099
end) -- 3055
return _module_0 -- 1
