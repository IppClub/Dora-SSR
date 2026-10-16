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
		elseif ch == "\\" and quote ~= "'" then -- 180
			escape = true -- 181
		elseif quote then -- 182
			if ch == quote then -- 183
				quote = nil -- 184
			else -- 186
				current[#current + 1] = ch -- 186
			end -- 183
		elseif ch == "'" or ch == '"' then -- 187
			quote = ch -- 188
		elseif ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 189
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
	local text = tostring(url):gsub("/+$", "") -- 224
	text = text:match(".*:([^/]+)$") or text -- 225
	local name = Path:getFilename(text):gsub("%.git$", "") -- 226
	if name == "" or name == "." or name == ".." then -- 227
		return nil -- 227
	end -- 227
	return name -- 228
end -- 221
local gitCloneTargetPath -- 230
gitCloneTargetPath = function(repoPath, command) -- 230
	local args = gitShellSplit(command) -- 231
	if not (args[1] == "clone") then -- 232
		return nil -- 232
	end -- 232
	local url, target = nil, nil -- 233
	local index = 2 -- 234
	while index <= #args do -- 235
		local arg = args[index] -- 236
		if ("-b" == arg or "--branch" == arg or "--depth" == arg) then -- 237
			if not args[index + 1] then -- 238
				return nil -- 238
			end -- 238
			index = index + 2 -- 239
		else -- 241
			if arg:sub(1, 1) == "-" then -- 241
				return nil -- 241
			end -- 241
			if not url then -- 242
				url = arg -- 243
			elseif not target then -- 244
				target = arg -- 245
			else -- 247
				return nil -- 247
			end -- 242
			index = index + 1 -- 248
		end -- 237
	end -- 235
	if not url then -- 249
		return nil -- 249
	end -- 249
	target = target or gitCloneDirFromURL(url) -- 250
	return gitSafeChildPath(repoPath, target) -- 251
end -- 230
local gitPathInsideRepo -- 253
gitPathInsideRepo = function(repoPath, relPath) -- 253
	if not (repoPath and relPath and relPath ~= "") then -- 254
		return false -- 254
	end -- 254
	if relPath:sub(1, 1) == "/" or relPath:match("^%a:[/\\]") then -- 255
		return false -- 255
	end -- 255
	if relPath == "." or relPath:match("^%.%.[/\\]?" or relPath:match("[/\\]%.%.[/\\]")) then -- 256
		return false -- 256
	end -- 256
	local targetPath = Path(repoPath, relPath) -- 257
	local relative = Path:getRelative(targetPath, repoPath) -- 258
	return relative ~= ".." and relative:sub(1, 3) ~= "../" and relative:sub(1, 3) ~= "..\\" -- 259
end -- 253
local gitHostFromURL -- 261
gitHostFromURL = function(url) -- 261
	if not (url and url ~= "") then -- 262
		return nil -- 262
	end -- 262
	local text = tostring(url):match("^%s*(.-)%s*$") -- 263
	if text == "" then -- 264
		return nil -- 264
	end -- 264
	local host = text:match("^[%w_%-]+://([^/:]+)") -- 265
	if not host then -- 266
		host = text:match("@([^:/]+)[:/]") -- 266
	end -- 266
	if not host then -- 267
		host = text:match("^([^:/]+):[^/]") -- 267
	end -- 267
	if not (host and host ~= "") then -- 268
		return nil -- 268
	end -- 268
	return string.lower(host) -- 269
end -- 261
local ensureGitTables -- 271
ensureGitTables = function() -- 271
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
	]]) -- 272
	DB:exec("CREATE INDEX IF NOT EXISTS idx_git_credential_host ON GitCredential(host);") -- 285
	return DB:exec([[		CREATE TABLE IF NOT EXISTS GitProfile(
			id INTEGER PRIMARY KEY CHECK(id = 1),
			name TEXT NOT NULL DEFAULT '',
			email TEXT NOT NULL DEFAULT '',
			updated_at INTEGER
		);
	]]) -- 286
end -- 271
local gitCredentialToPublic -- 295
gitCredentialToPublic = function(row) -- 295
	local id, host, label, typeName, username, createdAt, updatedAt, lastUsedAt = row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8] -- 296
	return { -- 297
		id = id, -- 297
		host = host, -- 297
		label = label, -- 297
		type = typeName, -- 297
		username = username, -- 297
		createdAt = createdAt, -- 297
		updatedAt = updatedAt, -- 297
		lastUsedAt = lastUsedAt -- 297
	} -- 297
end -- 295
local gitLoadCredential -- 299
gitLoadCredential = function(id) -- 299
	ensureGitTables() -- 300
	local credentialId = tonumber(id) or 0 -- 301
	local rows = DB:query("select id, host, label, type, username, secret from GitCredential where id = ? limit 1", { -- 302
		credentialId -- 302
	}) -- 302
	if not (rows and rows[1]) then -- 303
		return nil -- 303
	end -- 303
	local row = rows[1] -- 304
	return { -- 305
		id = row[1], -- 305
		host = row[2], -- 305
		label = row[3], -- 305
		type = row[4], -- 305
		username = row[5], -- 305
		secret = row[6] -- 305
	} -- 305
end -- 299
local gitAuthOptionsJSON -- 307
gitAuthOptionsJSON = function(credential) -- 307
	if not credential then -- 308
		return nil -- 308
	end -- 308
	local auth -- 309
	if credential.type == "token" then -- 309
		auth = { -- 311
			type = "token", -- 311
			token = credential.secret, -- 312
			username = credential.username ~= "" and credential.username or "token" -- 313
		} -- 310
	else -- 316
		auth = { -- 317
			type = "basic", -- 317
			username = credential.username, -- 318
			password = credential.secret -- 319
		} -- 316
	end -- 309
	return json.encode({ -- 321
		auth = auth -- 321
	}) -- 321
end -- 307
local gitLoadProfile -- 323
gitLoadProfile = function() -- 323
	ensureGitTables() -- 324
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 325
	if not (rows and rows[1]) then -- 326
		return nil -- 326
	end -- 326
	local name = tostring(rows[1][1] or "") -- 327
	local email = tostring(rows[1][2] or "") -- 328
	if name == "" and email == "" then -- 329
		return nil -- 329
	end -- 329
	return { -- 330
		name = name, -- 330
		email = email -- 330
	} -- 330
end -- 323
local _anon_func_2 = function(args, gitQuote) -- 349
	local _accum_0 = { } -- 349
	local _len_0 = 1 -- 349
	for _index_0 = 1, #args do -- 349
		local arg = args[_index_0] -- 349
		_accum_0[_len_0] = gitQuote(arg) -- 349
		_len_0 = _len_0 + 1 -- 349
	end -- 349
	return _accum_0 -- 349
end -- 349
local gitApplyProfileToCommit -- 332
gitApplyProfileToCommit = function(command) -- 332
	local args = gitShellSplit(command) -- 333
	if not (args[1] == "commit") then -- 334
		return command -- 334
	end -- 334
	local hasName = false -- 335
	local hasEmail = false -- 336
	for _index_0 = 1, #args do -- 337
		local arg = args[_index_0] -- 337
		if arg == "--author-name" then -- 338
			hasName = true -- 338
		end -- 338
		if arg == "--author-email" then -- 339
			hasEmail = true -- 339
		end -- 339
	end -- 337
	if hasName and hasEmail then -- 340
		return command -- 340
	end -- 340
	local profile = gitLoadProfile() -- 341
	if not profile then -- 342
		return command -- 342
	end -- 342
	if not hasName and profile.name ~= "" then -- 343
		args[#args + 1] = "--author-name" -- 344
		args[#args + 1] = profile.name -- 345
	end -- 343
	if not hasEmail and profile.email ~= "" then -- 346
		args[#args + 1] = "--author-email" -- 347
		args[#args + 1] = profile.email -- 348
	end -- 346
	return table.concat(_anon_func_2(args, gitQuote), " ") -- 349
end -- 332
local gitStartJob -- 351
gitStartJob = function(repoPath, command, optionsJSON) -- 351
	if optionsJSON == nil then -- 351
		optionsJSON = nil -- 351
	end -- 351
	gitPruneJobs() -- 352
	if gitInvalidRepoPath(repoPath) then -- 353
		return nil, "invalid repoPath" -- 353
	end -- 353
	if not (command and command ~= "") then -- 354
		return nil, "invalid command" -- 354
	end -- 354
	if not optionsJSON then -- 355
		optionsJSON = "" -- 355
	end -- 355
	command = gitApplyProfileToCommit(command) -- 356
	do -- 357
		local targetPath = gitCloneTargetPath(repoPath, command) -- 357
		if targetPath then -- 357
			if gitInvalidRepoPath(targetPath) then -- 358
				return nil, "invalid clone target" -- 358
			end -- 358
			if gitDirNonEmpty(targetPath) then -- 359
				return nil, "clone target directory is not empty" -- 360
			end -- 359
		elseif (gitShellSplit(command))[1] == "clone" then -- 361
			return nil, "invalid clone target" -- 362
		end -- 357
	end -- 357
	local statusRef = nil -- 363
	local startGit -- 364
	startGit = function() -- 364
		return Git:run(repoPath, command, (function(status) -- 365
			statusRef = status -- 366
			GitJobs[status.id] = { -- 368
				command = command, -- 368
				status = status, -- 369
				updatedAt = os.time() -- 370
			} -- 367
		end), optionsJSON) -- 365
	end -- 364
	local success, jobId = pcall(startGit) -- 372
	if not success then -- 373
		return nil, tostring(jobId) -- 373
	end -- 373
	if not jobId then -- 374
		return nil, "Git.run did not return a job id" -- 374
	end -- 374
	GitJobs[jobId] = { -- 376
		command = command, -- 376
		status = statusRef or { -- 378
			id = jobId, -- 378
			state = "queued", -- 379
			kind = gitShellSplit(command)[1] or "status", -- 380
			repoPath = repoPath, -- 381
			progress = 0, -- 382
			message = "queued" -- 383
		}, -- 377
		updatedAt = os.time() -- 385
	} -- 375
	return jobId -- 386
end -- 351
local gitRunSync -- 388
gitRunSync = function(repoPath, command, optionsJSON, timeout) -- 388
	if optionsJSON == nil then -- 388
		optionsJSON = nil -- 388
	end -- 388
	if timeout == nil then -- 388
		timeout = 20 -- 388
	end -- 388
	local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 389
	if not jobId then -- 390
		return { -- 390
			success = false, -- 390
			message = err -- 390
		} -- 390
	end -- 390
	local startedAt = os.time() -- 391
	wait(function() -- 392
		local job = GitJobs[jobId] -- 393
		local status = job and job.status -- 394
		return gitTerminalState(status) or os.time() - startedAt >= timeout -- 395
	end) -- 392
	local status = GitJobs[jobId] and GitJobs[jobId].status -- 396
	if not gitTerminalState(status) then -- 397
		Git:cancel(jobId) -- 398
		return { -- 399
			success = false, -- 399
			message = "git command timed out", -- 399
			jobId = jobId, -- 399
			status = status -- 399
		} -- 399
	end -- 397
	return { -- 400
		success = status.state == "done", -- 400
		jobId = jobId, -- 400
		status = status, -- 400
		message = status.error or status.message -- 400
	} -- 400
end -- 388
local gitCredentialsForHost -- 402
gitCredentialsForHost = function(host) -- 402
	if not (host and host ~= "") then -- 403
		return { } -- 403
	end -- 403
	ensureGitTables() -- 404
	local rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by last_used_at desc, label asc, id asc", { -- 405
		host -- 405
	}) -- 405
	if rows then -- 406
		local _accum_0 = { } -- 407
		local _len_0 = 1 -- 407
		for _index_0 = 1, #rows do -- 407
			local row = rows[_index_0] -- 407
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 407
			_len_0 = _len_0 + 1 -- 407
		end -- 407
		return _accum_0 -- 407
	else -- 408
		return { } -- 408
	end -- 406
end -- 402
local gitFirstRemoteURL -- 410
gitFirstRemoteURL = function(repoPath, remoteName) -- 410
	if remoteName == nil then -- 410
		remoteName = nil -- 410
	end -- 410
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 10) -- 411
	local data = remoteRes.status and remoteRes.status.data -- 412
	if not (data and data.remotes) then -- 413
		return nil -- 413
	end -- 413
	local _list_0 = data.remotes -- 414
	for _index_0 = 1, #_list_0 do -- 414
		local remote = _list_0[_index_0] -- 414
		if (not remoteName or remote.name == remoteName) and remote.urls and remote.urls[1] then -- 415
			return remote.urls[1] -- 416
		end -- 415
	end -- 414
	return nil -- 417
end -- 410
local gitConfigRemoteURL -- 419
gitConfigRemoteURL = function(repoPath, remoteName) -- 419
	if remoteName == nil then -- 419
		remoteName = nil -- 419
	end -- 419
	if gitInvalidRepoPath(repoPath) then -- 420
		return nil -- 420
	end -- 420
	local configPath = Path(repoPath, ".git/config") -- 421
	if not Content:exist(configPath) then -- 422
		return nil -- 422
	end -- 422
	local content = Content:load(configPath) -- 423
	if not (content and content ~= "") then -- 424
		return nil -- 424
	end -- 424
	local currentRemote = nil -- 425
	for line in content:gmatch("[^\r\n]+") do -- 426
		local sectionRemote = line:match('^%s*%[remote%s+"([^"]+)"%]%s*$') -- 427
		if sectionRemote then -- 428
			currentRemote = sectionRemote -- 429
		elseif currentRemote and (not remoteName or currentRemote == remoteName) then -- 430
			local url = line:match("^%s*url%s*=%s*(.-)%s*$") -- 431
			if url and url ~= "" then -- 432
				return url -- 432
			end -- 432
		end -- 428
	end -- 426
	return nil -- 433
end -- 419
local gitCommandRemoteArg -- 435
gitCommandRemoteArg = function(args, startIndex) -- 435
	if startIndex == nil then -- 435
		startIndex = 2 -- 435
	end -- 435
	local index = startIndex -- 436
	while index <= #args do -- 437
		local arg = args[index] -- 438
		if ("-u" == arg or "--set-upstream" == arg or "-f" == arg or "--force" == arg or "--all" == arg or "--prune" == arg) then -- 439
			index = index + 1 -- 440
		elseif ("--depth" == arg or "-b" == arg or "--branch" == arg) then -- 441
			index = index + 2 -- 442
		elseif arg and arg:sub(1, 1) == "-" then -- 443
			index = index + 1 -- 444
		else -- 446
			return arg -- 446
		end -- 439
	end -- 437
	return nil -- 447
end -- 435
local gitCommandHost -- 449
gitCommandHost = function(repoPath, command) -- 449
	local args = gitShellSplit(command) -- 450
	if not args[1] then -- 451
		return nil -- 451
	end -- 451
	do -- 452
		local _exp_0 = args[1] -- 452
		if "clone" == _exp_0 or "ls-remote" == _exp_0 then -- 453
			return gitHostFromURL(args[2]) -- 454
		elseif "fetch" == _exp_0 or "pull" == _exp_0 or "push" == _exp_0 then -- 455
			local remoteArg = gitCommandRemoteArg(args, 2) -- 456
			if not remoteArg then -- 457
				return nil -- 457
			end -- 457
			local url = gitHostFromURL(remoteArg) -- 458
			if url then -- 459
				return url -- 459
			end -- 459
			return gitHostFromURL(gitConfigRemoteURL(repoPath, remoteArg)) -- 460
		end -- 452
	end -- 452
	return nil -- 461
end -- 449
local gitAuthSelectionForCommand -- 463
gitAuthSelectionForCommand = function(repoPath, command) -- 463
	local host = gitCommandHost(repoPath, command) -- 464
	if not host then -- 465
		return nil -- 465
	end -- 465
	local items = gitCredentialsForHost(host) -- 466
	if #items == 0 then -- 467
		return nil -- 467
	end -- 467
	return { -- 468
		host = host, -- 468
		items = items -- 468
	} -- 468
end -- 463
local gitDefaultRemote -- 470
gitDefaultRemote = function(remoteStatus) -- 470
	local data = remoteStatus and remoteStatus.data -- 471
	if not (data and data.remotes and data.remotes[1]) then -- 472
		return nil -- 472
	end -- 472
	return data.remotes[1] -- 473
end -- 470
local gitCurrentBranch -- 475
gitCurrentBranch = function(branchStatus) -- 475
	local data = branchStatus and branchStatus.data -- 476
	if data and data.current and data.current ~= "" then -- 477
		return data.current -- 478
	end -- 477
	if data and data.branches then -- 479
		local _list_0 = data.branches -- 480
		for _index_0 = 1, #_list_0 do -- 480
			local branch = _list_0[_index_0] -- 480
			if branch.current then -- 481
				return branch.name -- 481
			end -- 481
		end -- 480
	end -- 479
	return nil -- 482
end -- 475
local gitHeadBranch -- 484
gitHeadBranch = function(repoPath) -- 484
	if gitInvalidRepoPath(repoPath) then -- 485
		return nil -- 485
	end -- 485
	local headPath = Path(repoPath, ".git", "HEAD") -- 486
	if not Content:exist(headPath) then -- 487
		return nil -- 487
	end -- 487
	local head = Content:load(headPath) -- 488
	if not head then -- 489
		return nil -- 489
	end -- 489
	local branch = head:match("^ref:%s*refs/heads/(.-)%s*$") -- 490
	if branch and branch ~= "" then -- 491
		return branch -- 491
	end -- 491
	return nil -- 492
end -- 484
local gitBranchesWithHead -- 494
gitBranchesWithHead = function(branchStatus, currentBranch) -- 494
	local branches = branchStatus and branchStatus.data and branchStatus.data.branches or { } -- 495
	if not (currentBranch and currentBranch ~= "") then -- 496
		return branches -- 496
	end -- 496
	for _index_0 = 1, #branches do -- 497
		local branch = branches[_index_0] -- 497
		if branch.name == currentBranch then -- 498
			return branches -- 498
		end -- 498
	end -- 497
	local withHead -- 499
	do -- 499
		local _accum_0 = { } -- 499
		local _len_0 = 1 -- 499
		for _index_0 = 1, #branches do -- 499
			local branch = branches[_index_0] -- 499
			_accum_0[_len_0] = branch -- 499
			_len_0 = _len_0 + 1 -- 499
		end -- 499
		withHead = _accum_0 -- 499
	end -- 499
	withHead[#withHead + 1] = { -- 500
		name = currentBranch, -- 500
		current = true, -- 500
		unborn = true -- 500
	} -- 500
	return withHead -- 501
end -- 494
local gitStatusMeansNotRepo -- 503
gitStatusMeansNotRepo = function(statusRes) -- 503
	local message = statusRes and (statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message)) or "" -- 504
	message = tostring(message):lower() -- 505
	return message:find("repository does not exist", 1, true) or message:find("not a git repository", 1, true) -- 506
end -- 503
local gitSummary -- 508
gitSummary = function(repoPath) -- 508
	local statusRes = gitRunSync(repoPath, "status", nil, 120) -- 509
	if not statusRes.success then -- 510
		if gitStatusMeansNotRepo(statusRes) then -- 511
			return { -- 512
				success = true, -- 512
				isRepo = false, -- 512
				message = statusRes.message, -- 512
				status = statusRes.status -- 512
			} -- 512
		end -- 511
		return { -- 513
			success = false, -- 513
			message = statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message) or "failed to check Git repository", -- 513
			status = statusRes.status -- 513
		} -- 513
	end -- 510
	local branchRes = gitRunSync(repoPath, "branch", nil, 120) -- 514
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 120) -- 515
	local status = statusRes.status -- 516
	local branchStatus = branchRes.status -- 517
	local remoteStatus = remoteRes.status -- 518
	local currentBranch = gitCurrentBranch(branchStatus) or gitHeadBranch(repoPath) -- 519
	local branches = gitBranchesWithHead(branchStatus, currentBranch) -- 520
	local logRes = gitRunSync(repoPath, "log --metadata-only -n 100", nil, 120) -- 521
	local logStatus -- 522
	if logRes.success then -- 522
		logStatus = logRes.status -- 523
	else -- 525
		logStatus = { -- 526
			state = "done", -- 526
			kind = "log", -- 527
			repoPath = repoPath, -- 528
			progress = 1, -- 529
			message = "git log completed", -- 530
			data = { -- 531
				commits = { } -- 531
			} -- 531
		} -- 525
	end -- 522
	local hasCommit = logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] ~= nil -- 533
	local tagStatus -- 534
	if hasCommit then -- 534
		tagStatus = (gitRunSync(repoPath, "tag", nil, 120)).status -- 535
	else -- 537
		tagStatus = { -- 538
			state = "done", -- 538
			kind = "tag", -- 539
			repoPath = repoPath, -- 540
			progress = 1, -- 541
			message = "git tag completed", -- 542
			data = { -- 543
				tags = { } -- 543
			} -- 543
		} -- 537
	end -- 534
	local defaultRemote = gitDefaultRemote(remoteStatus) -- 545
	local lastCommit = nil -- 546
	if logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] then -- 547
		lastCommit = logStatus.data.commits[1] -- 548
	end -- 547
	return { -- 550
		success = true, -- 550
		isRepo = true, -- 551
		clean = status.data and status.data.clean or false, -- 552
		currentBranch = currentBranch, -- 553
		defaultRemote = defaultRemote, -- 554
		remotes = remoteStatus and remoteStatus.data and remoteStatus.data.remotes or { }, -- 555
		branches = branches, -- 556
		lastCommit = lastCommit, -- 557
		status = status, -- 558
		branchStatus = branchStatus, -- 559
		remoteStatus = remoteStatus, -- 560
		historyStatus = logStatus, -- 561
		tagStatus = tagStatus -- 562
	} -- 549
end -- 508
HttpServer:post("/git/run", function(req) -- 564
	do -- 565
		local _type_0 = type(req) -- 565
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 565
		if _tab_0 then -- 565
			local body = req.body -- 565
			if body ~= nil then -- 565
				local repoPath, command, authId, optionsJSON = body.repoPath, body.command, body.authId, body.optionsJSON -- 566
				if authId and not optionsJSON then -- 567
					local credential = gitLoadCredential(authId) -- 568
					if credential then -- 568
						optionsJSON = gitAuthOptionsJSON(credential) -- 569
						DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 570
							os.time(), -- 570
							credential.id -- 570
						}) -- 570
					end -- 568
				elseif not optionsJSON then -- 571
					local authOk, authSelection = pcall(gitAuthSelectionForCommand, repoPath, command) -- 572
					if not authOk then -- 573
						authSelection = nil -- 573
					end -- 573
					if authSelection then -- 574
						if #authSelection.items == 1 then -- 575
							local credential = gitLoadCredential(authSelection.items[1].id) -- 576
							optionsJSON = gitAuthOptionsJSON(credential) -- 577
							DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 578
								os.time(), -- 578
								credential.id -- 578
							}) -- 578
						else -- 580
							return { -- 580
								success = false, -- 580
								message = "select a Git credential", -- 580
								needsCredentialSelection = true, -- 580
								host = authSelection.host, -- 580
								credentials = authSelection.items -- 580
							} -- 580
						end -- 575
					end -- 574
				end -- 567
				local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 581
				if not jobId then -- 582
					return { -- 582
						success = false, -- 582
						message = err -- 582
					} -- 582
				end -- 582
				return { -- 583
					success = true, -- 583
					jobId = jobId -- 583
				} -- 583
			end -- 565
		end -- 565
	end -- 565
	return invalidArguments -- 564
end) -- 564
HttpServer:post("/git/status", function(req) -- 585
	do -- 586
		local _type_0 = type(req) -- 586
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 586
		if _tab_0 then -- 586
			local jobId -- 586
			do -- 586
				local _obj_0 = req.body -- 586
				local _type_1 = type(_obj_0) -- 586
				if "table" == _type_1 or "userdata" == _type_1 then -- 586
					jobId = _obj_0.jobId -- 586
				end -- 586
			end -- 586
			if jobId ~= nil then -- 586
				local job = GitJobs[tonumber(jobId) or 0] -- 587
				if not job then -- 588
					return { -- 588
						success = false, -- 588
						message = "git job not found" -- 588
					} -- 588
				end -- 588
				return { -- 589
					success = true, -- 589
					status = job.status, -- 589
					command = job.command -- 589
				} -- 589
			end -- 586
		end -- 586
	end -- 586
	return invalidArguments -- 585
end) -- 585
HttpServer:post("/git/cancel", function(req) -- 591
	do -- 592
		local _type_0 = type(req) -- 592
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 592
		if _tab_0 then -- 592
			local jobId -- 592
			do -- 592
				local _obj_0 = req.body -- 592
				local _type_1 = type(_obj_0) -- 592
				if "table" == _type_1 or "userdata" == _type_1 then -- 592
					jobId = _obj_0.jobId -- 592
				end -- 592
			end -- 592
			if jobId ~= nil then -- 592
				local id = tonumber(jobId) -- 593
				if not id then -- 594
					return { -- 594
						success = false, -- 594
						message = "invalid jobId" -- 594
					} -- 594
				end -- 594
				return { -- 595
					success = Git:cancel(id) -- 595
				} -- 595
			end -- 592
		end -- 592
	end -- 592
	return invalidArguments -- 591
end) -- 591
HttpServer:postSchedule("/git/summary", function(req) -- 597
	do -- 598
		local _type_0 = type(req) -- 598
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 598
		if _tab_0 then -- 598
			local repoPath -- 598
			do -- 598
				local _obj_0 = req.body -- 598
				local _type_1 = type(_obj_0) -- 598
				if "table" == _type_1 or "userdata" == _type_1 then -- 598
					repoPath = _obj_0.repoPath -- 598
				end -- 598
			end -- 598
			if repoPath ~= nil then -- 598
				if gitInvalidRepoPath(repoPath) then -- 599
					return { -- 599
						success = false, -- 599
						message = "invalid repoPath" -- 599
					} -- 599
				end -- 599
				return gitSummary(repoPath) -- 600
			end -- 598
		end -- 598
	end -- 598
	return invalidArguments -- 597
end) -- 597
HttpServer:postSchedule("/git/status-files", function(req) -- 602
	do -- 603
		local _type_0 = type(req) -- 603
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 603
		if _tab_0 then -- 603
			local repoPath -- 603
			do -- 603
				local _obj_0 = req.body -- 603
				local _type_1 = type(_obj_0) -- 603
				if "table" == _type_1 or "userdata" == _type_1 then -- 603
					repoPath = _obj_0.repoPath -- 603
				end -- 603
			end -- 603
			if repoPath ~= nil then -- 603
				return gitRunSync(repoPath, "status", nil, 120) -- 604
			end -- 603
		end -- 603
	end -- 603
	return invalidArguments -- 602
end) -- 602
HttpServer:postSchedule("/git/discard-untracked", function(req) -- 606
	do -- 607
		local _type_0 = type(req) -- 607
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 607
		if _tab_0 then -- 607
			local body = req.body -- 607
			if body ~= nil then -- 607
				local repoPath, paths = body.repoPath, body.paths -- 608
				if gitInvalidRepoPath(repoPath) then -- 609
					return { -- 609
						success = false, -- 609
						message = "invalid repoPath" -- 609
					} -- 609
				end -- 609
				if not (type(paths) == "table") then -- 610
					return { -- 610
						success = false, -- 610
						message = "invalid paths" -- 610
					} -- 610
				end -- 610
				local statusRes = gitRunSync(repoPath, "status", nil, 10) -- 611
				if not statusRes.success then -- 612
					return statusRes -- 612
				end -- 612
				local untracked = { } -- 613
				local _list_0 = (statusRes.status.data and statusRes.status.data.files or { }) -- 614
				for _index_0 = 1, #_list_0 do -- 614
					local file = _list_0[_index_0] -- 614
					if file.staging == "?" or file.worktree == "?" then -- 615
						untracked[file.path] = true -- 616
					end -- 615
				end -- 614
				local removed = { } -- 617
				for _index_0 = 1, #paths do -- 618
					local relPath = paths[_index_0] -- 618
					relPath = tostring(relPath) -- 619
					if not gitPathInsideRepo(repoPath, relPath) then -- 620
						return { -- 620
							success = false, -- 620
							message = "unsafe path: " .. tostring(relPath) -- 620
						} -- 620
					end -- 620
					if not untracked[relPath] then -- 621
						return { -- 621
							success = false, -- 621
							message = "path is not untracked: " .. tostring(relPath) -- 621
						} -- 621
					end -- 621
				end -- 618
				for _index_0 = 1, #paths do -- 622
					local relPath = paths[_index_0] -- 622
					local targetPath = Path(repoPath, tostring(relPath)) -- 623
					if Content:exist(targetPath) then -- 624
						Content:remove(targetPath) -- 625
						removed[#removed + 1] = tostring(relPath) -- 626
					end -- 624
				end -- 622
				return { -- 627
					success = true, -- 627
					removed = removed -- 627
				} -- 627
			end -- 607
		end -- 607
	end -- 607
	return invalidArguments -- 606
end) -- 606
HttpServer:postSchedule("/git/file-diff", function(req) -- 629
	do -- 630
		local _type_0 = type(req) -- 630
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 630
		if _tab_0 then -- 630
			local body = req.body -- 630
			if body ~= nil then -- 630
				local repoPath, path, staged = body.repoPath, body.path, body.staged -- 631
				if gitInvalidRepoPath(repoPath) then -- 632
					return { -- 632
						success = false, -- 632
						message = "invalid repoPath" -- 632
					} -- 632
				end -- 632
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 633
					return { -- 633
						success = false, -- 633
						message = "unsafe path" -- 633
					} -- 633
				end -- 633
				local command -- 634
				if staged == true then -- 634
					command = "diff --staged -- " .. tostring(gitQuote(path)) -- 635
				else -- 637
					command = "diff -- " .. tostring(gitQuote(path)) -- 637
				end -- 634
				local res = gitRunSync(repoPath, command, nil, 10) -- 638
				if not res.success then -- 639
					return res -- 639
				end -- 639
				return { -- 640
					success = true, -- 640
					status = res.status, -- 640
					data = res.status and res.status.data -- 640
				} -- 640
			end -- 630
		end -- 630
	end -- 630
	return invalidArguments -- 629
end) -- 629
HttpServer:postSchedule("/git/commit-file-diff", function(req) -- 642
	do -- 643
		local _type_0 = type(req) -- 643
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 643
		if _tab_0 then -- 643
			local body = req.body -- 643
			if body ~= nil then -- 643
				local repoPath, commit, path = body.repoPath, body.commit, body.path -- 644
				if gitInvalidRepoPath(repoPath) then -- 645
					return { -- 645
						success = false, -- 645
						message = "invalid repoPath" -- 645
					} -- 645
				end -- 645
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 646
					return { -- 646
						success = false, -- 646
						message = "invalid commit" -- 646
					} -- 646
				end -- 646
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 647
					return { -- 647
						success = false, -- 647
						message = "unsafe path" -- 647
					} -- 647
				end -- 647
				local res = gitRunSync(repoPath, "diff " .. tostring(gitQuote(commit)) .. " -- " .. tostring(gitQuote(path)), nil, 10) -- 648
				if not res.success then -- 649
					return res -- 649
				end -- 649
				return { -- 650
					success = true, -- 650
					status = res.status, -- 650
					data = res.status and res.status.data -- 650
				} -- 650
			end -- 643
		end -- 643
	end -- 643
	return invalidArguments -- 642
end) -- 642
HttpServer:postSchedule("/git/history", function(req) -- 652
	do -- 653
		local _type_0 = type(req) -- 653
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 653
		if _tab_0 then -- 653
			local body = req.body -- 653
			if body ~= nil then -- 653
				local repoPath, limit = body.repoPath, body.limit -- 654
				limit = math.max(1, math.min(100, tonumber(limit) or 20)) -- 655
				return gitRunSync(repoPath, "log --metadata-only -n " .. tostring(limit), nil, 10) -- 656
			end -- 653
		end -- 653
	end -- 653
	return invalidArguments -- 652
end) -- 652
HttpServer:postSchedule("/git/remotes", function(req) -- 658
	do -- 659
		local _type_0 = type(req) -- 659
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 659
		if _tab_0 then -- 659
			local body = req.body -- 659
			if body ~= nil then -- 659
				local repoPath, command = body.repoPath, body.command -- 660
				command = command or "remote -v" -- 661
				return gitRunSync(repoPath, command, nil, 10) -- 662
			end -- 659
		end -- 659
	end -- 659
	return invalidArguments -- 658
end) -- 658
HttpServer:postSchedule("/git/branches", function(req) -- 664
	do -- 665
		local _type_0 = type(req) -- 665
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 665
		if _tab_0 then -- 665
			local body = req.body -- 665
			if body ~= nil then -- 665
				local repoPath, command = body.repoPath, body.command -- 666
				command = command or "branch" -- 667
				return gitRunSync(repoPath, command, nil, 10) -- 668
			end -- 665
		end -- 665
	end -- 665
	return invalidArguments -- 664
end) -- 664
HttpServer:postSchedule("/git/tags", function(req) -- 670
	do -- 671
		local _type_0 = type(req) -- 671
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 671
		if _tab_0 then -- 671
			local body = req.body -- 671
			if body ~= nil then -- 671
				local repoPath, command = body.repoPath, body.command -- 672
				command = command or "tag" -- 673
				return gitRunSync(repoPath, command, nil, 10) -- 674
			end -- 671
		end -- 671
	end -- 671
	return invalidArguments -- 670
end) -- 670
HttpServer:post("/git/profile/get", function() -- 676
	ensureGitTables() -- 677
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 678
	local profile -- 679
	if rows and rows[1] then -- 679
		profile = { -- 680
			name = rows[1][1], -- 680
			email = rows[1][2] -- 680
		} -- 680
	else -- 682
		profile = { -- 682
			name = "", -- 682
			email = "" -- 682
		} -- 682
	end -- 679
	return { -- 683
		success = true, -- 683
		profile = profile -- 683
	} -- 683
end) -- 676
HttpServer:post("/git/profile/save", function(req) -- 685
	do -- 686
		local _type_0 = type(req) -- 686
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 686
		if _tab_0 then -- 686
			local name -- 686
			do -- 686
				local _obj_0 = req.body -- 686
				local _type_1 = type(_obj_0) -- 686
				if "table" == _type_1 or "userdata" == _type_1 then -- 686
					name = _obj_0.name -- 686
				end -- 686
			end -- 686
			local email -- 686
			do -- 686
				local _obj_0 = req.body -- 686
				local _type_1 = type(_obj_0) -- 686
				if "table" == _type_1 or "userdata" == _type_1 then -- 686
					email = _obj_0.email -- 686
				end -- 686
			end -- 686
			if name ~= nil and email ~= nil then -- 686
				ensureGitTables() -- 687
				DB:exec("insert into GitProfile(id, name, email, updated_at) values(1, ?, ?, ?) on conflict(id) do update set name = excluded.name, email = excluded.email, updated_at = excluded.updated_at", { -- 689
					tostring(name or ""), -- 689
					tostring(email or ""), -- 690
					os.time() -- 691
				}) -- 688
				return { -- 693
					success = true -- 693
				} -- 693
			end -- 686
		end -- 686
	end -- 686
	return invalidArguments -- 685
end) -- 685
HttpServer:post("/git/auth/list", function(req) -- 695
	ensureGitTables() -- 696
	local host = nil -- 697
	do -- 698
		local _type_0 = type(req) -- 698
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 698
		if _tab_0 then -- 698
			local body = req.body -- 698
			if body ~= nil then -- 698
				host = body.host -- 699
			end -- 698
		end -- 698
	end -- 698
	local rows -- 700
	if host and host ~= "" then -- 700
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by host asc, label asc, id asc", { -- 701
			tostring(host):lower() -- 701
		}) -- 701
	else -- 703
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential order by host asc, label asc, id asc") -- 703
	end -- 700
	local items -- 704
	if rows then -- 704
		local _accum_0 = { } -- 704
		local _len_0 = 1 -- 704
		for _index_0 = 1, #rows do -- 704
			local row = rows[_index_0] -- 704
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 704
			_len_0 = _len_0 + 1 -- 704
		end -- 704
		items = _accum_0 -- 704
	else -- 704
		items = { } -- 704
	end -- 704
	return { -- 705
		success = true, -- 705
		items = items -- 705
	} -- 705
end) -- 695
HttpServer:postSchedule("/git/auth/match", function(req) -- 707
	do -- 708
		local _type_0 = type(req) -- 708
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 708
		if _tab_0 then -- 708
			local body = req.body -- 708
			if body ~= nil then -- 708
				if not (type(body) == "table") then -- 709
					return invalidArguments -- 709
				end -- 709
				local repoPath, command, url = body.repoPath, body.command, body.url -- 710
				if url ~= nil and type(url) ~= "string" then -- 711
					return invalidArguments -- 711
				end -- 711
				if not (type(url) == "string" and url ~= "") then -- 712
					if not (type(repoPath) == "string" and type(command) == "string") then -- 713
						return invalidArguments -- 713
					end -- 713
				end -- 712
				local host -- 714
				if url and url ~= "" then -- 714
					host = gitHostFromURL(url) -- 714
				else -- 714
					host = gitCommandHost(repoPath, command) -- 714
				end -- 714
				if not host then -- 715
					return { -- 715
						success = false, -- 715
						message = "git host is required" -- 715
					} -- 715
				end -- 715
				local items = gitCredentialsForHost(host) -- 716
				return { -- 717
					success = true, -- 717
					host = host, -- 717
					items = items, -- 717
					needsSelection = #items > 1, -- 717
					authId = (#items == 1 and items[1].id or nil) -- 717
				} -- 717
			end -- 708
		end -- 708
	end -- 708
	return invalidArguments -- 707
end) -- 707
HttpServer:post("/git/auth/save", function(req) -- 719
	do -- 720
		local _type_0 = type(req) -- 720
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 720
		if _tab_0 then -- 720
			local body = req.body -- 720
			if body ~= nil then -- 720
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token -- 721
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$") -- 722
				label = tostring(label or ""):match("^%s*(.-)%s*$") -- 723
				local credentialType = tostring(body.type or "token") -- 724
				username = tostring(username or "") -- 725
				local secret -- 726
				if credentialType == "basic" then -- 726
					secret = tostring(password or "") -- 726
				else -- 726
					secret = tostring(token or password or "") -- 726
				end -- 726
				if host == "" then -- 727
					return { -- 727
						success = false, -- 727
						message = "host is required" -- 727
					} -- 727
				end -- 727
				if label == "" then -- 728
					return { -- 728
						success = false, -- 728
						message = "label is required" -- 728
					} -- 728
				end -- 728
				if secret == "" then -- 729
					return { -- 729
						success = false, -- 729
						message = "secret is required" -- 729
					} -- 729
				end -- 729
				if not (("basic" == credentialType or "token" == credentialType)) then -- 730
					return { -- 730
						success = false, -- 730
						message = "invalid type" -- 730
					} -- 730
				end -- 730
				ensureGitTables() -- 731
				local now = os.time() -- 732
				if id then -- 733
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", { -- 735
						host, -- 735
						label, -- 735
						credentialType, -- 735
						username, -- 735
						secret, -- 735
						now, -- 735
						(tonumber(id) or 0) -- 735
					}) -- 734
					return { -- 737
						success = true, -- 737
						id = tonumber(id) -- 737
					} -- 737
				else -- 739
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", { -- 740
						host, -- 740
						label, -- 740
						credentialType, -- 740
						username, -- 740
						secret, -- 740
						now, -- 740
						now -- 740
					}) -- 739
					local rows = DB:query("select last_insert_rowid()") -- 742
					return { -- 743
						success = true, -- 743
						id = rows and rows[1] and rows[1][1] -- 743
					} -- 743
				end -- 733
			end -- 720
		end -- 720
	end -- 720
	return invalidArguments -- 719
end) -- 719
HttpServer:post("/git/auth/delete", function(req) -- 745
	do -- 746
		local _type_0 = type(req) -- 746
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 746
		if _tab_0 then -- 746
			local id -- 746
			do -- 746
				local _obj_0 = req.body -- 746
				local _type_1 = type(_obj_0) -- 746
				if "table" == _type_1 or "userdata" == _type_1 then -- 746
					id = _obj_0.id -- 746
				end -- 746
			end -- 746
			if id ~= nil then -- 746
				ensureGitTables() -- 747
				local credentialId = tonumber(id) or 0 -- 748
				DB:exec("delete from GitCredential where id = ?", { -- 749
					credentialId -- 749
				}) -- 749
				return { -- 750
					success = true -- 750
				} -- 750
			end -- 746
		end -- 746
	end -- 746
	return invalidArguments -- 745
end) -- 745
HttpServer:postSchedule("/git/auth/test", function(req) -- 752
	do -- 753
		local _type_0 = type(req) -- 753
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 753
		if _tab_0 then -- 753
			local body = req.body -- 753
			if body ~= nil then -- 753
				local repoPath, url, authId = body.repoPath, body.url, body.authId -- 754
				local credential = gitLoadCredential(authId) -- 755
				local optionsJSON = gitAuthOptionsJSON(credential) -- 756
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20) -- 757
			end -- 753
		end -- 753
	end -- 753
	return invalidArguments -- 752
end) -- 752
HttpServer:post("/agent/session/create", function(req) -- 759
	do -- 760
		local _type_0 = type(req) -- 760
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 760
		if _tab_0 then -- 760
			local projectRoot -- 760
			do -- 760
				local _obj_0 = req.body -- 760
				local _type_1 = type(_obj_0) -- 760
				if "table" == _type_1 or "userdata" == _type_1 then -- 760
					projectRoot = _obj_0.projectRoot -- 760
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
			if projectRoot ~= nil and title ~= nil then -- 760
				return AgentSession.createSession(projectRoot, title) -- 761
			end -- 760
		end -- 760
	end -- 760
	return invalidArguments -- 759
end) -- 759
HttpServer:post("/agent/session/create-sub", function(req) -- 763
	do -- 764
		local _type_0 = type(req) -- 764
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 764
		if _tab_0 then -- 764
			local parentSessionId -- 764
			do -- 764
				local _obj_0 = req.body -- 764
				local _type_1 = type(_obj_0) -- 764
				if "table" == _type_1 or "userdata" == _type_1 then -- 764
					parentSessionId = _obj_0.parentSessionId -- 764
				end -- 764
			end -- 764
			local title -- 764
			do -- 764
				local _obj_0 = req.body -- 764
				local _type_1 = type(_obj_0) -- 764
				if "table" == _type_1 or "userdata" == _type_1 then -- 764
					title = _obj_0.title -- 764
				end -- 764
			end -- 764
			if parentSessionId ~= nil and title ~= nil then -- 764
				return AgentSession.createSubSession(parentSessionId, title) -- 765
			end -- 764
		end -- 764
	end -- 764
	return invalidArguments -- 763
end) -- 763
HttpServer:post("/agent/session/get", function(req) -- 767
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
			if sessionId ~= nil then -- 768
				return AgentSession.getSession(sessionId) -- 769
			end -- 768
		end -- 768
	end -- 768
	return invalidArguments -- 767
end) -- 767
HttpServer:post("/agent/vision/asset", function(req) -- 771
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
			local path -- 772
			do -- 772
				local _obj_0 = req.body -- 772
				local _type_1 = type(_obj_0) -- 772
				if "table" == _type_1 or "userdata" == _type_1 then -- 772
					path = _obj_0.path -- 772
				end -- 772
			end -- 772
			if sessionId ~= nil and path ~= nil then -- 772
				return AgentVisionAssets.getSessionVisionImageFromPath(sessionId, path) -- 773
			end -- 772
		end -- 772
	end -- 772
	return invalidArguments -- 771
end) -- 771
HttpServer:post("/agent/session/mode", function(req) -- 775
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
			local workMode -- 776
			do -- 776
				local _obj_0 = req.body -- 776
				local _type_1 = type(_obj_0) -- 776
				if "table" == _type_1 or "userdata" == _type_1 then -- 776
					workMode = _obj_0.workMode -- 776
				end -- 776
			end -- 776
			if sessionId ~= nil and workMode ~= nil then -- 776
				return AgentSession.setWorkMode(sessionId, workMode) -- 777
			end -- 776
		end -- 776
	end -- 776
	return invalidArguments -- 775
end) -- 775
HttpServer:post("/agent/session/send", function(req) -- 779
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
			if sessionId ~= nil and prompt ~= nil then -- 780
				return AgentSession.sendPrompt(sessionId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 781
			end -- 780
		end -- 780
	end -- 780
	return invalidArguments -- 779
end) -- 779
HttpServer:post("/agent/session/send-local", function(req) -- 783
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
			local prompt -- 784
			do -- 784
				local _obj_0 = req.body -- 784
				local _type_1 = type(_obj_0) -- 784
				if "table" == _type_1 or "userdata" == _type_1 then -- 784
					prompt = _obj_0.prompt -- 784
				end -- 784
			end -- 784
			local localAgentConfigId -- 784
			do -- 784
				local _obj_0 = req.body -- 784
				local _type_1 = type(_obj_0) -- 784
				if "table" == _type_1 or "userdata" == _type_1 then -- 784
					localAgentConfigId = _obj_0.localAgentConfigId -- 784
				end -- 784
			end -- 784
			if sessionId ~= nil and prompt ~= nil and localAgentConfigId ~= nil then -- 784
				return AgentSession.sendLocalPrompt(sessionId, prompt, localAgentConfigId) -- 785
			end -- 784
		end -- 784
	end -- 784
	return invalidArguments -- 783
end) -- 783
HttpServer:post("/agent/session/local/new", function(req) -- 787
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
				return AgentLocalAgent.abandonSession(sessionId) -- 789
			end -- 788
		end -- 788
	end -- 788
	return invalidArguments -- 787
end) -- 787
HttpServer:post("/agent/session/local/info", function(req) -- 791
	do -- 792
		local _type_0 = type(req) -- 792
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 792
		if _tab_0 then -- 792
			local sessionId -- 792
			do -- 792
				local _obj_0 = req.body -- 792
				local _type_1 = type(_obj_0) -- 792
				if "table" == _type_1 or "userdata" == _type_1 then -- 792
					sessionId = _obj_0.sessionId -- 792
				end -- 792
			end -- 792
			if sessionId ~= nil then -- 792
				local info = AgentLocalAgent.getSessionInfo(sessionId) -- 793
				return { -- 794
					success = true, -- 794
					info = info -- 794
				} -- 794
			end -- 792
		end -- 792
	end -- 792
	return invalidArguments -- 791
end) -- 791
HttpServer:post("/agent/session/continue", function(req) -- 796
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
				return AgentSession.continuePrompt(sessionId, req.body.disabledAgentTools, req.body.llmConfigId) -- 798
			end -- 797
		end -- 797
	end -- 797
	return invalidArguments -- 796
end) -- 796
HttpServer:post("/agent/session/finish-handoff", function(req) -- 800
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
			if sessionId ~= nil then -- 801
				return AgentSession.finishSubSessionHandoff(sessionId, req.body.llmConfigId) -- 802
			end -- 801
		end -- 801
	end -- 801
	return invalidArguments -- 800
end) -- 800
HttpServer:post("/agent/session/resend", function(req) -- 804
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
			local messageId -- 805
			do -- 805
				local _obj_0 = req.body -- 805
				local _type_1 = type(_obj_0) -- 805
				if "table" == _type_1 or "userdata" == _type_1 then -- 805
					messageId = _obj_0.messageId -- 805
				end -- 805
			end -- 805
			local prompt -- 805
			do -- 805
				local _obj_0 = req.body -- 805
				local _type_1 = type(_obj_0) -- 805
				if "table" == _type_1 or "userdata" == _type_1 then -- 805
					prompt = _obj_0.prompt -- 805
				end -- 805
			end -- 805
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 805
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 806
			end -- 805
		end -- 805
	end -- 805
	return invalidArguments -- 804
end) -- 804
HttpServer:post("/agent/session/questionnaire/respond", function(req) -- 808
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
			local answers -- 809
			do -- 809
				local _obj_0 = req.body -- 809
				local _type_1 = type(_obj_0) -- 809
				if "table" == _type_1 or "userdata" == _type_1 then -- 809
					answers = _obj_0.answers -- 809
				end -- 809
			end -- 809
			if sessionId ~= nil and questionnaireId ~= nil and answers ~= nil then -- 809
				return AgentSession.respondQuestionnaire(sessionId, questionnaireId, answers, req.body.llmConfigId) -- 810
			end -- 809
		end -- 809
	end -- 809
	return invalidArguments -- 808
end) -- 808
HttpServer:post("/agent/session/questionnaire/cancel", function(req) -- 812
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
			local questionnaireId -- 813
			do -- 813
				local _obj_0 = req.body -- 813
				local _type_1 = type(_obj_0) -- 813
				if "table" == _type_1 or "userdata" == _type_1 then -- 813
					questionnaireId = _obj_0.questionnaireId -- 813
				end -- 813
			end -- 813
			if sessionId ~= nil and questionnaireId ~= nil then -- 813
				return AgentSession.cancelQuestionnaire(sessionId, questionnaireId, req.body.llmConfigId) -- 814
			end -- 813
		end -- 813
	end -- 813
	return invalidArguments -- 812
end) -- 812
HttpServer:post("/agent/task/status", function(req) -- 816
	do -- 817
		local _type_0 = type(req) -- 817
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 817
		if _tab_0 then -- 817
			local sessionId -- 817
			do -- 817
				local _obj_0 = req.body -- 817
				local _type_1 = type(_obj_0) -- 817
				if "table" == _type_1 or "userdata" == _type_1 then -- 817
					sessionId = _obj_0.sessionId -- 817
				end -- 817
			end -- 817
			if sessionId ~= nil then -- 817
				local res = AgentSession.getSession(sessionId) -- 818
				if not res.success then -- 819
					return res -- 819
				end -- 819
				local taskId = res.session.currentTaskId -- 820
				local checkpoints -- 821
				if taskId then -- 821
					checkpoints = AgentTools.listCheckpoints(taskId) -- 821
				else -- 821
					checkpoints = { } -- 821
				end -- 821
				return { -- 823
					success = true, -- 823
					session = res.session, -- 824
					relatedSessions = res.relatedSessions, -- 825
					spawnInfo = res.spawnInfo, -- 826
					messages = res.messages, -- 827
					steps = res.steps, -- 828
					checkpoints = checkpoints, -- 829
					pendingQuestionnaire = res.pendingQuestionnaire, -- 830
					hasActivePlan = res.hasActivePlan -- 831
				} -- 822
			end -- 817
		end -- 817
	end -- 817
	return invalidArguments -- 816
end) -- 816
HttpServer:post("/agent/task/running", function() -- 833
	local res = AgentSession.listRunningSessions() -- 834
	if res.success and #res.sessions == 0 then -- 835
		res.sessions = nil -- 836
	end -- 835
	return res -- 837
end) -- 833
HttpServer:post("/agent/task/stop", function(req) -- 839
	do -- 840
		local _type_0 = type(req) -- 840
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 840
		if _tab_0 then -- 840
			local sessionId -- 840
			do -- 840
				local _obj_0 = req.body -- 840
				local _type_1 = type(_obj_0) -- 840
				if "table" == _type_1 or "userdata" == _type_1 then -- 840
					sessionId = _obj_0.sessionId -- 840
				end -- 840
			end -- 840
			if sessionId ~= nil then -- 840
				return AgentSession.stopSessionTask(sessionId) -- 841
			end -- 840
		end -- 840
	end -- 840
	return invalidArguments -- 839
end) -- 839
HttpServer:post("/agent/checkpoint/list", function(req) -- 843
	do -- 844
		local _type_0 = type(req) -- 844
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 844
		if _tab_0 then -- 844
			local taskId -- 844
			do -- 844
				local _obj_0 = req.body -- 844
				local _type_1 = type(_obj_0) -- 844
				if "table" == _type_1 or "userdata" == _type_1 then -- 844
					taskId = _obj_0.taskId -- 844
				end -- 844
			end -- 844
			local sessionId -- 844
			do -- 844
				local _obj_0 = req.body -- 844
				local _type_1 = type(_obj_0) -- 844
				if "table" == _type_1 or "userdata" == _type_1 then -- 844
					sessionId = _obj_0.sessionId -- 844
				end -- 844
			end -- 844
			if sessionId ~= nil then -- 844
				if not taskId and sessionId then -- 845
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 846
				end -- 845
				if not taskId then -- 847
					return { -- 847
						success = false, -- 847
						message = "task not found" -- 847
					} -- 847
				end -- 847
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 848
				if not access.success then -- 849
					return access -- 849
				end -- 849
				return { -- 851
					success = true, -- 851
					taskId = taskId, -- 852
					checkpoints = AgentTools.listCheckpoints(taskId) -- 853
				} -- 850
			end -- 844
		end -- 844
	end -- 844
	return invalidArguments -- 843
end) -- 843
HttpServer:post("/agent/checkpoint/diff", function(req) -- 855
	do -- 856
		local _type_0 = type(req) -- 856
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 856
		if _tab_0 then -- 856
			local sessionId -- 856
			do -- 856
				local _obj_0 = req.body -- 856
				local _type_1 = type(_obj_0) -- 856
				if "table" == _type_1 or "userdata" == _type_1 then -- 856
					sessionId = _obj_0.sessionId -- 856
				end -- 856
			end -- 856
			local checkpointId -- 856
			do -- 856
				local _obj_0 = req.body -- 856
				local _type_1 = type(_obj_0) -- 856
				if "table" == _type_1 or "userdata" == _type_1 then -- 856
					checkpointId = _obj_0.checkpointId -- 856
				end -- 856
			end -- 856
			if sessionId ~= nil and checkpointId ~= nil then -- 856
				if not (checkpointId > 0) then -- 857
					return { -- 857
						success = false, -- 857
						message = "invalid checkpointId" -- 857
					} -- 857
				end -- 857
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 858
				if not access.success then -- 859
					return access -- 859
				end -- 859
				return AgentTools.getCheckpointDiff(checkpointId) -- 860
			end -- 856
		end -- 856
	end -- 856
	return invalidArguments -- 855
end) -- 855
HttpServer:post("/agent/task/diff", function(req) -- 862
	do -- 863
		local _type_0 = type(req) -- 863
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 863
		if _tab_0 then -- 863
			local sessionId -- 863
			do -- 863
				local _obj_0 = req.body -- 863
				local _type_1 = type(_obj_0) -- 863
				if "table" == _type_1 or "userdata" == _type_1 then -- 863
					sessionId = _obj_0.sessionId -- 863
				end -- 863
			end -- 863
			local taskId -- 863
			do -- 863
				local _obj_0 = req.body -- 863
				local _type_1 = type(_obj_0) -- 863
				if "table" == _type_1 or "userdata" == _type_1 then -- 863
					taskId = _obj_0.taskId -- 863
				end -- 863
			end -- 863
			if sessionId ~= nil and taskId ~= nil then -- 863
				if not (taskId > 0) then -- 864
					return { -- 864
						success = false, -- 864
						message = "invalid taskId" -- 864
					} -- 864
				end -- 864
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 865
				if not access.success then -- 866
					return access -- 866
				end -- 866
				return AgentTools.getTaskChangeSetDiff(taskId) -- 867
			end -- 863
		end -- 863
	end -- 863
	return invalidArguments -- 862
end) -- 862
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 869
	do -- 870
		local _type_0 = type(req) -- 870
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 870
		if _tab_0 then -- 870
			local sessionId -- 870
			do -- 870
				local _obj_0 = req.body -- 870
				local _type_1 = type(_obj_0) -- 870
				if "table" == _type_1 or "userdata" == _type_1 then -- 870
					sessionId = _obj_0.sessionId -- 870
				end -- 870
			end -- 870
			local checkpointId -- 870
			do -- 870
				local _obj_0 = req.body -- 870
				local _type_1 = type(_obj_0) -- 870
				if "table" == _type_1 or "userdata" == _type_1 then -- 870
					checkpointId = _obj_0.checkpointId -- 870
				end -- 870
			end -- 870
			if sessionId ~= nil and checkpointId ~= nil then -- 870
				if not (checkpointId > 0) then -- 871
					return { -- 871
						success = false, -- 871
						message = "invalid checkpointId" -- 871
					} -- 871
				end -- 871
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 872
				if not access.success then -- 873
					return access -- 873
				end -- 873
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, access.session.projectRoot) -- 874
				if not rollbackRes.success then -- 875
					return rollbackRes -- 875
				end -- 875
				return { -- 877
					success = true, -- 877
					checkpointId = rollbackRes.checkpointId -- 878
				} -- 876
			end -- 870
		end -- 870
	end -- 870
	return invalidArguments -- 869
end) -- 869
HttpServer:post("/agent/task/rollback", function(req) -- 880
	do -- 881
		local _type_0 = type(req) -- 881
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 881
		if _tab_0 then -- 881
			local sessionId -- 881
			do -- 881
				local _obj_0 = req.body -- 881
				local _type_1 = type(_obj_0) -- 881
				if "table" == _type_1 or "userdata" == _type_1 then -- 881
					sessionId = _obj_0.sessionId -- 881
				end -- 881
			end -- 881
			local taskId -- 881
			do -- 881
				local _obj_0 = req.body -- 881
				local _type_1 = type(_obj_0) -- 881
				if "table" == _type_1 or "userdata" == _type_1 then -- 881
					taskId = _obj_0.taskId -- 881
				end -- 881
			end -- 881
			if sessionId ~= nil and taskId ~= nil then -- 881
				if not (taskId > 0) then -- 882
					return { -- 882
						success = false, -- 882
						message = "invalid taskId" -- 882
					} -- 882
				end -- 882
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 883
				if not access.success then -- 884
					return access -- 884
				end -- 884
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, access.session.projectRoot) -- 885
				if not rollbackRes.success then -- 886
					return rollbackRes -- 886
				end -- 886
				return { -- 888
					success = true, -- 888
					taskId = rollbackRes.taskId, -- 889
					checkpointId = rollbackRes.checkpointId, -- 890
					checkpointCount = rollbackRes.checkpointCount -- 891
				} -- 887
			end -- 881
		end -- 881
	end -- 881
	return invalidArguments -- 880
end) -- 880
local getSearchPath -- 893
getSearchPath = function(file) -- 893
	do -- 894
		local dir = getProjectDirFromFile(file) -- 894
		if dir then -- 894
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 895
		end -- 894
	end -- 894
	return "" -- 893
end -- 893
local getSearchFolders -- 897
getSearchFolders = function(file) -- 897
	do -- 898
		local dir = getProjectDirFromFile(file) -- 898
		if dir then -- 898
			return { -- 900
				Path(dir, "Script"), -- 900
				dir -- 901
			} -- 899
		end -- 898
	end -- 898
	return { } -- 897
end -- 897
local disabledCheckForLua = { -- 904
	"incompatible number of returns", -- 904
	"unknown", -- 905
	"cannot index", -- 906
	"module not found", -- 907
	"don't know how to resolve", -- 908
	"ContainerItem", -- 909
	"cannot resolve a type", -- 910
	"invalid key", -- 911
	"inconsistent index type", -- 912
	"cannot use operator", -- 913
	"attempting ipairs loop", -- 914
	"expects record or nominal", -- 915
	"variable is not being assigned", -- 916
	"<invalid type>", -- 917
	"<any type>", -- 918
	"using the '#' operator", -- 919
	"can't match a record", -- 920
	"redeclaration of variable", -- 921
	"cannot apply pairs", -- 922
	"not a function", -- 923
	"to%-be%-closed" -- 924
} -- 903
local yueCheck -- 926
yueCheck = function(file, content, lax) -- 926
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 927
	if isTIC80 then -- 928
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 929
	end -- 928
	local searchPath = getSearchPath(file) -- 930
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 931
	local info = { } -- 932
	local globals = { } -- 933
	for _index_0 = 1, #checkResult do -- 934
		local _des_0 = checkResult[_index_0] -- 934
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 934
		if "error" == t then -- 935
			info[#info + 1] = { -- 936
				"syntax", -- 936
				file, -- 936
				line, -- 936
				col, -- 936
				msg -- 936
			} -- 936
		elseif "global" == t then -- 937
			globals[#globals + 1] = { -- 938
				msg, -- 938
				line, -- 938
				col -- 938
			} -- 938
		end -- 935
	end -- 934
	if luaCodes then -- 939
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 940
		if success then -- 941
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 942
			if not (lintResult == "") then -- 943
				lintResult = lintResult .. "\n" -- 943
			end -- 943
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 944
		else -- 945
			for _index_0 = 1, #lintResult do -- 945
				local _des_0 = lintResult[_index_0] -- 945
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 945
				if isTIC80 and tic80APIs[name] then -- 946
					goto _continue_0 -- 946
				end -- 946
				info[#info + 1] = { -- 947
					"syntax", -- 947
					file, -- 947
					line, -- 947
					col, -- 947
					"invalid global variable" -- 947
				} -- 947
				::_continue_0:: -- 946
			end -- 945
		end -- 941
	end -- 939
	return luaCodes, info -- 948
end -- 926
local luaCheck -- 950
luaCheck = function(file, content) -- 950
	local res, err = load(content, "check") -- 951
	if not res then -- 952
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 953
		return { -- 954
			success = false, -- 954
			info = { -- 954
				{ -- 954
					"syntax", -- 954
					file, -- 954
					tonumber(line), -- 954
					0, -- 954
					msg -- 954
				} -- 954
			} -- 954
		} -- 954
	end -- 952
	local success, info = teal.checkAsync(content, file, true, "") -- 955
	if info then -- 956
		do -- 957
			local _accum_0 = { } -- 957
			local _len_0 = 1 -- 957
			for _index_0 = 1, #info do -- 957
				local item = info[_index_0] -- 957
				local useCheck = true -- 958
				if not item[5]:match("unused") then -- 959
					for _index_1 = 1, #disabledCheckForLua do -- 960
						local check = disabledCheckForLua[_index_1] -- 960
						if item[5]:match(check) then -- 961
							useCheck = false -- 962
						end -- 961
					end -- 960
				end -- 959
				if not useCheck then -- 963
					goto _continue_0 -- 963
				end -- 963
				do -- 964
					local _exp_0 = item[1] -- 964
					if "type" == _exp_0 then -- 965
						item[1] = "warning" -- 966
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 967
						goto _continue_0 -- 968
					end -- 964
				end -- 964
				_accum_0[_len_0] = item -- 969
				_len_0 = _len_0 + 1 -- 958
				::_continue_0:: -- 958
			end -- 957
			info = _accum_0 -- 957
		end -- 957
		if #info == 0 then -- 970
			info = nil -- 971
			success = true -- 972
		end -- 970
	end -- 956
	return { -- 973
		success = success, -- 973
		info = info -- 973
	} -- 973
end -- 950
local luaCheckWithLineInfo -- 975
luaCheckWithLineInfo = function(file, luaCodes) -- 975
	local res = luaCheck(file, luaCodes) -- 976
	local info = { } -- 977
	if not res.success then -- 978
		local current = 1 -- 979
		local lastLine = 1 -- 980
		local lineMap = { } -- 981
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 982
			local num = lineCode:match("--%s*(%d+)%s*$") -- 983
			if num then -- 984
				lastLine = tonumber(num) -- 985
			end -- 984
			lineMap[current] = lastLine -- 986
			current = current + 1 -- 987
		end -- 982
		local _list_0 = res.info -- 988
		for _index_0 = 1, #_list_0 do -- 988
			local item = _list_0[_index_0] -- 988
			item[3] = lineMap[item[3]] or 0 -- 989
			item[4] = 0 -- 990
			info[#info + 1] = item -- 991
		end -- 988
		return false, info -- 992
	end -- 978
	return true, info -- 993
end -- 975
local getCompiledYueLine -- 995
getCompiledYueLine = function(content, line, row, file, lax) -- 995
	local luaCodes = yueCheck(file, content, lax) -- 996
	if not luaCodes then -- 997
		return nil -- 997
	end -- 997
	local current = 1 -- 998
	local lastLine = 1 -- 999
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 1000
	local targetRow = nil -- 1001
	local lineMap = { } -- 1002
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 1003
		local num = lineCode:match("--%s*(%d+)%s*$") -- 1004
		if num then -- 1005
			lastLine = tonumber(num) -- 1005
		end -- 1005
		lineMap[current] = lastLine -- 1006
		if row <= lastLine and not targetRow then -- 1007
			targetRow = current -- 1008
			break -- 1009
		end -- 1007
		current = current + 1 -- 1010
	end -- 1003
	targetRow = current -- 1011
	if targetLine and targetRow then -- 1012
		return luaCodes, targetLine, targetRow, lineMap -- 1013
	else -- 1015
		return nil -- 1015
	end -- 1012
end -- 995
HttpServer:postSchedule("/check", function(req) -- 1017
	do -- 1018
		local _type_0 = type(req) -- 1018
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1018
		if _tab_0 then -- 1018
			local file -- 1018
			do -- 1018
				local _obj_0 = req.body -- 1018
				local _type_1 = type(_obj_0) -- 1018
				if "table" == _type_1 or "userdata" == _type_1 then -- 1018
					file = _obj_0.file -- 1018
				end -- 1018
			end -- 1018
			local content -- 1018
			do -- 1018
				local _obj_0 = req.body -- 1018
				local _type_1 = type(_obj_0) -- 1018
				if "table" == _type_1 or "userdata" == _type_1 then -- 1018
					content = _obj_0.content -- 1018
				end -- 1018
			end -- 1018
			if file ~= nil and content ~= nil then -- 1018
				local ext = Path:getExt(file) -- 1019
				if "tl" == ext then -- 1020
					local searchPath = getSearchPath(file) -- 1021
					do -- 1022
						local isTIC80 = CheckTIC80Code(content) -- 1022
						if isTIC80 then -- 1022
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1023
						end -- 1022
					end -- 1022
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 1024
					return { -- 1025
						success = success, -- 1025
						info = info -- 1025
					} -- 1025
				elseif "lua" == ext then -- 1026
					do -- 1027
						local isTIC80 = CheckTIC80Code(content) -- 1027
						if isTIC80 then -- 1027
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1028
						end -- 1027
					end -- 1027
					return luaCheck(file, content) -- 1029
				elseif "yue" == ext then -- 1030
					local luaCodes, info = yueCheck(file, content, false) -- 1031
					local success = luaCodes ~= nil -- 1032
					if luaCodes then -- 1033
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 1034
						do -- 1035
							local _tab_1 = { } -- 1035
							local _idx_0 = #_tab_1 + 1 -- 1035
							for _index_0 = 1, #info do -- 1035
								local _value_0 = info[_index_0] -- 1035
								_tab_1[_idx_0] = _value_0 -- 1035
								_idx_0 = _idx_0 + 1 -- 1035
							end -- 1035
							local _idx_1 = #_tab_1 + 1 -- 1035
							for _index_0 = 1, #luaInfo do -- 1035
								local _value_0 = luaInfo[_index_0] -- 1035
								_tab_1[_idx_1] = _value_0 -- 1035
								_idx_1 = _idx_1 + 1 -- 1035
							end -- 1035
							info = _tab_1 -- 1035
						end -- 1035
						success = success and luaSuccess -- 1036
					end -- 1033
					if #info > 0 then -- 1037
						return { -- 1038
							success = success, -- 1038
							info = info -- 1038
						} -- 1038
					else -- 1040
						return { -- 1040
							success = success -- 1040
						} -- 1040
					end -- 1037
				elseif "xml" == ext then -- 1041
					local success, result = xml.check(content) -- 1042
					if success then -- 1043
						local info -- 1044
						success, info = luaCheckWithLineInfo(file, result) -- 1044
						if #info > 0 then -- 1045
							return { -- 1046
								success = success, -- 1046
								info = info -- 1046
							} -- 1046
						else -- 1048
							return { -- 1048
								success = success -- 1048
							} -- 1048
						end -- 1045
					else -- 1050
						local info -- 1050
						do -- 1050
							local _accum_0 = { } -- 1050
							local _len_0 = 1 -- 1050
							for _index_0 = 1, #result do -- 1050
								local _des_0 = result[_index_0] -- 1050
								local row, err = _des_0[1], _des_0[2] -- 1050
								_accum_0[_len_0] = { -- 1051
									"syntax", -- 1051
									file, -- 1051
									row, -- 1051
									0, -- 1051
									err -- 1051
								} -- 1051
								_len_0 = _len_0 + 1 -- 1051
							end -- 1050
							info = _accum_0 -- 1050
						end -- 1050
						return { -- 1052
							success = false, -- 1052
							info = info -- 1052
						} -- 1052
					end -- 1043
				end -- 1020
			end -- 1018
		end -- 1018
	end -- 1018
	return { -- 1017
		success = true -- 1017
	} -- 1017
end) -- 1017
HttpServer:post("/body/parse", function(req) -- 1054
	do -- 1055
		local _type_0 = type(req) -- 1055
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1055
		if _tab_0 then -- 1055
			local file -- 1055
			do -- 1055
				local _obj_0 = req.body -- 1055
				local _type_1 = type(_obj_0) -- 1055
				if "table" == _type_1 or "userdata" == _type_1 then -- 1055
					file = _obj_0.file -- 1055
				end -- 1055
			end -- 1055
			local content -- 1055
			do -- 1055
				local _obj_0 = req.body -- 1055
				local _type_1 = type(_obj_0) -- 1055
				if "table" == _type_1 or "userdata" == _type_1 then -- 1055
					content = _obj_0.content -- 1055
				end -- 1055
			end -- 1055
			if file ~= nil and content ~= nil then -- 1055
				if not (file:sub(-6) == ".b.lua") then -- 1056
					return { -- 1057
						success = false, -- 1057
						phase = "request", -- 1057
						message = "only .b.lua files can be converted" -- 1057
					} -- 1057
				end -- 1056
				local loader, err = load("_ENV = {}\n" .. content) -- 1058
				if not loader then -- 1059
					return { -- 1060
						success = false, -- 1060
						phase = "parse", -- 1060
						message = tostring(err) -- 1060
					} -- 1060
				end -- 1059
				local ok, data = pcall(loader) -- 1061
				if not ok then -- 1062
					return { -- 1063
						success = false, -- 1063
						phase = "execute", -- 1063
						message = tostring(data) -- 1063
					} -- 1063
				end -- 1062
				if not ("table" == type(data) and data[1] == "Array") then -- 1064
					return { -- 1065
						success = false, -- 1065
						phase = "validate", -- 1065
						message = "body lua root must be {\"Array\", ...}" -- 1065
					} -- 1065
				end -- 1064
				local text, jsonErr = json.encode(data, false, true) -- 1066
				if not text then -- 1067
					return { -- 1068
						success = false, -- 1068
						phase = "encode", -- 1068
						message = tostring(jsonErr) -- 1068
					} -- 1068
				end -- 1067
				return { -- 1069
					success = true, -- 1069
					json = text -- 1069
				} -- 1069
			end -- 1055
		end -- 1055
	end -- 1055
	return { -- 1054
		success = false, -- 1054
		phase = "request", -- 1054
		message = "invalid request" -- 1054
	} -- 1054
end) -- 1054
local updateInferedDesc -- 1071
updateInferedDesc = function(infered) -- 1071
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1072
		return -- 1072
	end -- 1072
	local key, row = infered.key, infered.row -- 1073
	local codes = Content:loadAsync(key) -- 1074
	if codes then -- 1074
		local comments = { } -- 1075
		local line = 0 -- 1076
		local skipping = false -- 1077
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1078
			line = line + 1 -- 1079
			if line >= row then -- 1080
				break -- 1080
			end -- 1080
			if lineCode:match("^%s*%-%- @") then -- 1081
				skipping = true -- 1082
				goto _continue_0 -- 1083
			end -- 1081
			local result = lineCode:match("^%s*%-%- (.+)") -- 1084
			if result then -- 1084
				if not skipping then -- 1085
					comments[#comments + 1] = result -- 1085
				end -- 1085
			elseif #comments > 0 then -- 1086
				comments = { } -- 1087
				skipping = false -- 1088
			end -- 1084
			::_continue_0:: -- 1079
		end -- 1078
		infered.doc = table.concat(comments, "\n") -- 1089
	end -- 1074
end -- 1071
HttpServer:postSchedule("/infer", function(req) -- 1091
	do -- 1092
		local _type_0 = type(req) -- 1092
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1092
		if _tab_0 then -- 1092
			local lang -- 1092
			do -- 1092
				local _obj_0 = req.body -- 1092
				local _type_1 = type(_obj_0) -- 1092
				if "table" == _type_1 or "userdata" == _type_1 then -- 1092
					lang = _obj_0.lang -- 1092
				end -- 1092
			end -- 1092
			local file -- 1092
			do -- 1092
				local _obj_0 = req.body -- 1092
				local _type_1 = type(_obj_0) -- 1092
				if "table" == _type_1 or "userdata" == _type_1 then -- 1092
					file = _obj_0.file -- 1092
				end -- 1092
			end -- 1092
			local content -- 1092
			do -- 1092
				local _obj_0 = req.body -- 1092
				local _type_1 = type(_obj_0) -- 1092
				if "table" == _type_1 or "userdata" == _type_1 then -- 1092
					content = _obj_0.content -- 1092
				end -- 1092
			end -- 1092
			local line -- 1092
			do -- 1092
				local _obj_0 = req.body -- 1092
				local _type_1 = type(_obj_0) -- 1092
				if "table" == _type_1 or "userdata" == _type_1 then -- 1092
					line = _obj_0.line -- 1092
				end -- 1092
			end -- 1092
			local row -- 1092
			do -- 1092
				local _obj_0 = req.body -- 1092
				local _type_1 = type(_obj_0) -- 1092
				if "table" == _type_1 or "userdata" == _type_1 then -- 1092
					row = _obj_0.row -- 1092
				end -- 1092
			end -- 1092
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1092
				local searchPath = getSearchPath(file) -- 1093
				if "tl" == lang or "lua" == lang then -- 1094
					if CheckTIC80Code(content) then -- 1095
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1096
					end -- 1095
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1097
					if (infered ~= nil) then -- 1098
						updateInferedDesc(infered) -- 1099
						return { -- 1100
							success = true, -- 1100
							infered = infered -- 1100
						} -- 1100
					end -- 1098
				elseif "yue" == lang then -- 1101
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1102
					if not luaCodes then -- 1103
						return { -- 1103
							success = false -- 1103
						} -- 1103
					end -- 1103
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1104
					if (infered ~= nil) then -- 1105
						local col -- 1106
						file, row, col = infered.file, infered.row, infered.col -- 1106
						if file == "" and row > 0 and col > 0 then -- 1107
							infered.row = lineMap[row] or 0 -- 1108
							infered.col = 0 -- 1109
						end -- 1107
						updateInferedDesc(infered) -- 1110
						return { -- 1111
							success = true, -- 1111
							infered = infered -- 1111
						} -- 1111
					end -- 1105
				end -- 1094
			end -- 1092
		end -- 1092
	end -- 1092
	return { -- 1091
		success = false -- 1091
	} -- 1091
end) -- 1091
local _anon_func_3 = function(doc) -- 1172
	local _accum_0 = { } -- 1172
	local _len_0 = 1 -- 1172
	local _list_0 = doc.params -- 1172
	for _index_0 = 1, #_list_0 do -- 1172
		local param = _list_0[_index_0] -- 1172
		_accum_0[_len_0] = param.name -- 1172
		_len_0 = _len_0 + 1 -- 1172
	end -- 1172
	return _accum_0 -- 1172
end -- 1172
local getParamDocs -- 1113
getParamDocs = function(signatures) -- 1113
	if not (signatures and #signatures > 0) then -- 1114
		return nil -- 1114
	end -- 1114
	local docs = { } -- 1115
	do -- 1116
		local codes = Content:loadAsync(signatures[1].file) -- 1116
		if codes then -- 1116
			local comments = { } -- 1117
			local params = { } -- 1118
			local line = 0 -- 1119
			local returnType = nil -- 1120
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1121
				line = line + 1 -- 1122
				local needBreak = true -- 1123
				for i, _des_0 in ipairs(signatures) do -- 1124
					local row = _des_0.row -- 1124
					if line >= row and not (docs[i] ~= nil) then -- 1125
						if #comments > 0 or #params > 0 or returnType then -- 1126
							docs[i] = { -- 1128
								doc = table.concat(comments, "  \n"), -- 1128
								returnType = returnType -- 1129
							} -- 1127
							if #params > 0 then -- 1131
								docs[i].params = params -- 1131
							end -- 1131
						else -- 1133
							docs[i] = false -- 1133
						end -- 1126
					end -- 1125
					if not docs[i] then -- 1134
						needBreak = false -- 1134
					end -- 1134
				end -- 1124
				if needBreak then -- 1135
					break -- 1135
				end -- 1135
				local result = lineCode:match("%s*%-%- (.+)") -- 1136
				if result then -- 1136
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1137
					if not name then -- 1138
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1139
					end -- 1138
					if name then -- 1140
						local pname = name -- 1141
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1142
							pname = pname .. "?" -- 1142
						end -- 1142
						params[#params + 1] = { -- 1144
							name = tostring(pname) .. ": " .. tostring(typ), -- 1144
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1145
						} -- 1143
					else -- 1148
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1148
						if typ then -- 1148
							if returnType then -- 1149
								returnType = returnType .. ", " .. typ -- 1150
							else -- 1152
								returnType = typ -- 1152
							end -- 1149
							result = result:gsub("@return", "**return:**") -- 1153
						end -- 1148
						comments[#comments + 1] = result -- 1154
					end -- 1140
				elseif #comments > 0 then -- 1155
					comments = { } -- 1156
					params = { } -- 1157
					returnType = nil -- 1158
				end -- 1136
			end -- 1121
		end -- 1116
	end -- 1116
	local results = { } -- 1159
	for i, signature in ipairs(signatures) do -- 1160
		local item = { -- 1162
			desc = signature.desc, -- 1162
			doc = "", -- 1163
			file = signature.file, -- 1164
			row = signature.row, -- 1165
			col = signature.col -- 1166
		} -- 1161
		do -- 1168
			local doc = docs[i] -- 1168
			if doc then -- 1168
				item.doc = doc.doc -- 1169
				if doc.params then -- 1170
					item.params = doc.params -- 1171
					item.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1172
				elseif doc.returnType then -- 1173
					item.desc = "function()" -- 1174
				end -- 1170
				if doc.returnType then -- 1175
					item.desc = item.desc .. ": " .. tostring(doc.returnType) -- 1175
				end -- 1175
			end -- 1168
		end -- 1168
		results[#results + 1] = item -- 1176
	end -- 1160
	return results -- 1177
end -- 1113
HttpServer:postSchedule("/signature", function(req) -- 1179
	do -- 1180
		local _type_0 = type(req) -- 1180
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1180
		if _tab_0 then -- 1180
			local lang -- 1180
			do -- 1180
				local _obj_0 = req.body -- 1180
				local _type_1 = type(_obj_0) -- 1180
				if "table" == _type_1 or "userdata" == _type_1 then -- 1180
					lang = _obj_0.lang -- 1180
				end -- 1180
			end -- 1180
			local file -- 1180
			do -- 1180
				local _obj_0 = req.body -- 1180
				local _type_1 = type(_obj_0) -- 1180
				if "table" == _type_1 or "userdata" == _type_1 then -- 1180
					file = _obj_0.file -- 1180
				end -- 1180
			end -- 1180
			local content -- 1180
			do -- 1180
				local _obj_0 = req.body -- 1180
				local _type_1 = type(_obj_0) -- 1180
				if "table" == _type_1 or "userdata" == _type_1 then -- 1180
					content = _obj_0.content -- 1180
				end -- 1180
			end -- 1180
			local line -- 1180
			do -- 1180
				local _obj_0 = req.body -- 1180
				local _type_1 = type(_obj_0) -- 1180
				if "table" == _type_1 or "userdata" == _type_1 then -- 1180
					line = _obj_0.line -- 1180
				end -- 1180
			end -- 1180
			local row -- 1180
			do -- 1180
				local _obj_0 = req.body -- 1180
				local _type_1 = type(_obj_0) -- 1180
				if "table" == _type_1 or "userdata" == _type_1 then -- 1180
					row = _obj_0.row -- 1180
				end -- 1180
			end -- 1180
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1180
				local searchPath = getSearchPath(file) -- 1181
				if "tl" == lang or "lua" == lang then -- 1182
					if CheckTIC80Code(content) then -- 1183
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1184
					end -- 1183
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1185
					if signatures then -- 1185
						signatures = getParamDocs(signatures) -- 1186
						if signatures then -- 1186
							return { -- 1187
								success = true, -- 1187
								signatures = signatures -- 1187
							} -- 1187
						end -- 1186
					end -- 1185
				elseif "yue" == lang then -- 1188
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1189
					if not luaCodes then -- 1190
						return { -- 1190
							success = false -- 1190
						} -- 1190
					end -- 1190
					do -- 1191
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1191
						if chainOp then -- 1191
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1192
							if withVar then -- 1192
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1193
							end -- 1192
						end -- 1191
					end -- 1191
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1194
					if signatures then -- 1194
						signatures = getParamDocs(signatures) -- 1195
						if signatures then -- 1195
							return { -- 1196
								success = true, -- 1196
								signatures = signatures -- 1196
							} -- 1196
						end -- 1195
					else -- 1197
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1197
						if signatures then -- 1197
							signatures = getParamDocs(signatures) -- 1198
							if signatures then -- 1198
								return { -- 1199
									success = true, -- 1199
									signatures = signatures -- 1199
								} -- 1199
							end -- 1198
						end -- 1197
					end -- 1194
				end -- 1182
			end -- 1180
		end -- 1180
	end -- 1180
	return { -- 1179
		success = false -- 1179
	} -- 1179
end) -- 1179
local luaKeywords = { -- 1202
	'and', -- 1202
	'break', -- 1203
	'do', -- 1204
	'else', -- 1205
	'elseif', -- 1206
	'end', -- 1207
	'false', -- 1208
	'for', -- 1209
	'function', -- 1210
	'goto', -- 1211
	'if', -- 1212
	'in', -- 1213
	'local', -- 1214
	'nil', -- 1215
	'not', -- 1216
	'or', -- 1217
	'repeat', -- 1218
	'return', -- 1219
	'then', -- 1220
	'true', -- 1221
	'until', -- 1222
	'while' -- 1223
} -- 1201
local tealKeywords = { -- 1227
	'record', -- 1227
	'as', -- 1228
	'is', -- 1229
	'type', -- 1230
	'embed', -- 1231
	'enum', -- 1232
	'global', -- 1233
	'any', -- 1234
	'boolean', -- 1235
	'integer', -- 1236
	'number', -- 1237
	'string', -- 1238
	'thread' -- 1239
} -- 1226
local yueKeywords = { -- 1243
	"and", -- 1243
	"break", -- 1244
	"do", -- 1245
	"else", -- 1246
	"elseif", -- 1247
	"false", -- 1248
	"for", -- 1249
	"goto", -- 1250
	"if", -- 1251
	"in", -- 1252
	"local", -- 1253
	"nil", -- 1254
	"not", -- 1255
	"or", -- 1256
	"repeat", -- 1257
	"return", -- 1258
	"then", -- 1259
	"true", -- 1260
	"until", -- 1261
	"while", -- 1262
	"as", -- 1263
	"class", -- 1264
	"continue", -- 1265
	"export", -- 1266
	"extends", -- 1267
	"from", -- 1268
	"global", -- 1269
	"import", -- 1270
	"macro", -- 1271
	"switch", -- 1272
	"try", -- 1273
	"unless", -- 1274
	"using", -- 1275
	"when", -- 1276
	"with" -- 1277
} -- 1242
local _anon_func_4 = function(f) -- 1313
	local _val_0 = Path:getExt(f) -- 1313
	return "ttf" == _val_0 or "otf" == _val_0 -- 1313
end -- 1313
local _anon_func_5 = function(suggestions) -- 1339
	local _tbl_0 = { } -- 1339
	for _index_0 = 1, #suggestions do -- 1339
		local item = suggestions[_index_0] -- 1339
		_tbl_0[item[1] .. item[2]] = item -- 1339
	end -- 1339
	return _tbl_0 -- 1339
end -- 1339
HttpServer:postSchedule("/complete", function(req) -- 1280
	do -- 1281
		local _type_0 = type(req) -- 1281
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1281
		if _tab_0 then -- 1281
			local lang -- 1281
			do -- 1281
				local _obj_0 = req.body -- 1281
				local _type_1 = type(_obj_0) -- 1281
				if "table" == _type_1 or "userdata" == _type_1 then -- 1281
					lang = _obj_0.lang -- 1281
				end -- 1281
			end -- 1281
			local file -- 1281
			do -- 1281
				local _obj_0 = req.body -- 1281
				local _type_1 = type(_obj_0) -- 1281
				if "table" == _type_1 or "userdata" == _type_1 then -- 1281
					file = _obj_0.file -- 1281
				end -- 1281
			end -- 1281
			local content -- 1281
			do -- 1281
				local _obj_0 = req.body -- 1281
				local _type_1 = type(_obj_0) -- 1281
				if "table" == _type_1 or "userdata" == _type_1 then -- 1281
					content = _obj_0.content -- 1281
				end -- 1281
			end -- 1281
			local line -- 1281
			do -- 1281
				local _obj_0 = req.body -- 1281
				local _type_1 = type(_obj_0) -- 1281
				if "table" == _type_1 or "userdata" == _type_1 then -- 1281
					line = _obj_0.line -- 1281
				end -- 1281
			end -- 1281
			local row -- 1281
			do -- 1281
				local _obj_0 = req.body -- 1281
				local _type_1 = type(_obj_0) -- 1281
				if "table" == _type_1 or "userdata" == _type_1 then -- 1281
					row = _obj_0.row -- 1281
				end -- 1281
			end -- 1281
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1281
				local searchPath = getSearchPath(file) -- 1282
				repeat -- 1283
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1284
					if lang == "yue" then -- 1285
						if not item then -- 1286
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1286
						end -- 1286
						if not item then -- 1287
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1287
						end -- 1287
					end -- 1285
					local searchType = nil -- 1288
					if not item then -- 1289
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1290
						if lang == "yue" then -- 1291
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1292
						end -- 1291
						if (item ~= nil) then -- 1293
							searchType = "Image" -- 1293
						end -- 1293
					end -- 1289
					if not item then -- 1294
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1295
						if lang == "yue" then -- 1296
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1297
						end -- 1296
						if (item ~= nil) then -- 1298
							searchType = "Font" -- 1298
						end -- 1298
					end -- 1294
					if not item then -- 1299
						break -- 1299
					end -- 1299
					local searchPaths = Content.searchPaths -- 1300
					local _list_0 = getSearchFolders(file) -- 1301
					for _index_0 = 1, #_list_0 do -- 1301
						local folder = _list_0[_index_0] -- 1301
						searchPaths[#searchPaths + 1] = folder -- 1302
					end -- 1301
					if searchType then -- 1303
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1303
					end -- 1303
					local tokens -- 1304
					do -- 1304
						local _accum_0 = { } -- 1304
						local _len_0 = 1 -- 1304
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1304
							_accum_0[_len_0] = mod -- 1304
							_len_0 = _len_0 + 1 -- 1304
						end -- 1304
						tokens = _accum_0 -- 1304
					end -- 1304
					local suggestions = { } -- 1305
					for _index_0 = 1, #searchPaths do -- 1306
						local path = searchPaths[_index_0] -- 1306
						local sPath = Path(path, table.unpack(tokens)) -- 1307
						if not Content:exist(sPath) then -- 1308
							goto _continue_0 -- 1308
						end -- 1308
						if searchType == "Font" then -- 1309
							local fontPath = Path(sPath, "Font") -- 1310
							if Content:exist(fontPath) then -- 1311
								local _list_1 = Content:getFiles(fontPath) -- 1312
								for _index_1 = 1, #_list_1 do -- 1312
									local f = _list_1[_index_1] -- 1312
									if _anon_func_4(f) then -- 1313
										if "." == f:sub(1, 1) then -- 1314
											goto _continue_1 -- 1314
										end -- 1314
										suggestions[#suggestions + 1] = { -- 1315
											Path:getName(f), -- 1315
											"font", -- 1315
											"field" -- 1315
										} -- 1315
									end -- 1313
									::_continue_1:: -- 1313
								end -- 1312
							end -- 1311
						end -- 1309
						local _list_1 = Content:getFiles(sPath) -- 1316
						for _index_1 = 1, #_list_1 do -- 1316
							local f = _list_1[_index_1] -- 1316
							if "Image" == searchType then -- 1317
								do -- 1318
									local _exp_0 = Path:getExt(f) -- 1318
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1318
										if "." == f:sub(1, 1) then -- 1319
											goto _continue_2 -- 1319
										end -- 1319
										suggestions[#suggestions + 1] = { -- 1320
											f, -- 1320
											"image", -- 1320
											"field" -- 1320
										} -- 1320
									end -- 1318
								end -- 1318
								goto _continue_2 -- 1321
							elseif "Font" == searchType then -- 1322
								do -- 1323
									local _exp_0 = Path:getExt(f) -- 1323
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1323
										if "." == f:sub(1, 1) then -- 1324
											goto _continue_2 -- 1324
										end -- 1324
										suggestions[#suggestions + 1] = { -- 1325
											f, -- 1325
											"font", -- 1325
											"field" -- 1325
										} -- 1325
									end -- 1323
								end -- 1323
								goto _continue_2 -- 1326
							end -- 1317
							local _exp_0 = Path:getExt(f) -- 1327
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1327
								local name = Path:getName(f) -- 1328
								if "d" == Path:getExt(name) then -- 1329
									goto _continue_2 -- 1329
								end -- 1329
								if "." == name:sub(1, 1) then -- 1330
									goto _continue_2 -- 1330
								end -- 1330
								suggestions[#suggestions + 1] = { -- 1331
									name, -- 1331
									"module", -- 1331
									"field" -- 1331
								} -- 1331
							end -- 1327
							::_continue_2:: -- 1317
						end -- 1316
						local _list_2 = Content:getDirs(sPath) -- 1332
						for _index_1 = 1, #_list_2 do -- 1332
							local dir = _list_2[_index_1] -- 1332
							if "." == dir:sub(1, 1) then -- 1333
								goto _continue_3 -- 1333
							end -- 1333
							suggestions[#suggestions + 1] = { -- 1334
								dir, -- 1334
								"folder", -- 1334
								"variable" -- 1334
							} -- 1334
							::_continue_3:: -- 1333
						end -- 1332
						::_continue_0:: -- 1307
					end -- 1306
					if item == "" and not searchType then -- 1335
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1336
						for _index_0 = 1, #_list_1 do -- 1336
							local _des_0 = _list_1[_index_0] -- 1336
							local name = _des_0[1] -- 1336
							suggestions[#suggestions + 1] = { -- 1337
								name, -- 1337
								"dora module", -- 1337
								"function" -- 1337
							} -- 1337
						end -- 1336
					end -- 1335
					if #suggestions > 0 then -- 1338
						do -- 1339
							local _accum_0 = { } -- 1339
							local _len_0 = 1 -- 1339
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1339
								_accum_0[_len_0] = v -- 1339
								_len_0 = _len_0 + 1 -- 1339
							end -- 1339
							suggestions = _accum_0 -- 1339
						end -- 1339
						return { -- 1340
							success = true, -- 1340
							suggestions = suggestions -- 1340
						} -- 1340
					else -- 1342
						return { -- 1342
							success = false -- 1342
						} -- 1342
					end -- 1338
				until true -- 1283
				if "tl" == lang or "lua" == lang then -- 1344
					do -- 1345
						local isTIC80 = CheckTIC80Code(content) -- 1345
						if isTIC80 then -- 1345
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1346
						end -- 1345
					end -- 1345
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1347
					if not line:match("[%.:]$") then -- 1348
						local checkSet -- 1349
						do -- 1349
							local _tbl_0 = { } -- 1349
							for _index_0 = 1, #suggestions do -- 1349
								local _des_0 = suggestions[_index_0] -- 1349
								local name = _des_0[1] -- 1349
								_tbl_0[name] = true -- 1349
							end -- 1349
							checkSet = _tbl_0 -- 1349
						end -- 1349
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1350
						for _index_0 = 1, #_list_0 do -- 1350
							local item = _list_0[_index_0] -- 1350
							if not checkSet[item[1]] then -- 1351
								suggestions[#suggestions + 1] = item -- 1351
							end -- 1351
						end -- 1350
						for _index_0 = 1, #luaKeywords do -- 1352
							local word = luaKeywords[_index_0] -- 1352
							suggestions[#suggestions + 1] = { -- 1353
								word, -- 1353
								"keyword", -- 1353
								"keyword" -- 1353
							} -- 1353
						end -- 1352
						if lang == "tl" then -- 1354
							for _index_0 = 1, #tealKeywords do -- 1355
								local word = tealKeywords[_index_0] -- 1355
								suggestions[#suggestions + 1] = { -- 1356
									word, -- 1356
									"keyword", -- 1356
									"keyword" -- 1356
								} -- 1356
							end -- 1355
						end -- 1354
					end -- 1348
					if #suggestions > 0 then -- 1357
						return { -- 1358
							success = true, -- 1358
							suggestions = suggestions -- 1358
						} -- 1358
					end -- 1357
				elseif "yue" == lang then -- 1359
					local suggestions = { } -- 1360
					local gotGlobals = false -- 1361
					do -- 1362
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1362
						if luaCodes then -- 1362
							gotGlobals = true -- 1363
							do -- 1364
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1364
								if chainOp then -- 1364
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1365
									if not withVar then -- 1366
										return { -- 1366
											success = false -- 1366
										} -- 1366
									end -- 1366
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1367
								elseif line:match("^([%.\\])$") then -- 1368
									return { -- 1369
										success = false -- 1369
									} -- 1369
								end -- 1364
							end -- 1364
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1370
							for _index_0 = 1, #_list_0 do -- 1370
								local item = _list_0[_index_0] -- 1370
								suggestions[#suggestions + 1] = item -- 1370
							end -- 1370
							if #suggestions == 0 then -- 1371
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1372
								for _index_0 = 1, #_list_1 do -- 1372
									local item = _list_1[_index_0] -- 1372
									suggestions[#suggestions + 1] = item -- 1372
								end -- 1372
							end -- 1371
						end -- 1362
					end -- 1362
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1373
						local checkSet -- 1374
						do -- 1374
							local _tbl_0 = { } -- 1374
							for _index_0 = 1, #suggestions do -- 1374
								local _des_0 = suggestions[_index_0] -- 1374
								local name = _des_0[1] -- 1374
								_tbl_0[name] = true -- 1374
							end -- 1374
							checkSet = _tbl_0 -- 1374
						end -- 1374
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1375
						for _index_0 = 1, #_list_0 do -- 1375
							local item = _list_0[_index_0] -- 1375
							if not checkSet[item[1]] then -- 1376
								suggestions[#suggestions + 1] = item -- 1376
							end -- 1376
						end -- 1375
						if not gotGlobals then -- 1377
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1378
							for _index_0 = 1, #_list_1 do -- 1378
								local item = _list_1[_index_0] -- 1378
								if not checkSet[item[1]] then -- 1379
									suggestions[#suggestions + 1] = item -- 1379
								end -- 1379
							end -- 1378
						end -- 1377
						for _index_0 = 1, #yueKeywords do -- 1380
							local word = yueKeywords[_index_0] -- 1380
							if not checkSet[word] then -- 1381
								suggestions[#suggestions + 1] = { -- 1382
									word, -- 1382
									"keyword", -- 1382
									"keyword" -- 1382
								} -- 1382
							end -- 1381
						end -- 1380
					end -- 1373
					if #suggestions > 0 then -- 1383
						return { -- 1384
							success = true, -- 1384
							suggestions = suggestions -- 1384
						} -- 1384
					end -- 1383
				elseif "xml" == lang then -- 1385
					local items = xml.complete(content) -- 1386
					if #items > 0 then -- 1387
						local suggestions -- 1388
						do -- 1388
							local _accum_0 = { } -- 1388
							local _len_0 = 1 -- 1388
							for _index_0 = 1, #items do -- 1388
								local _des_0 = items[_index_0] -- 1388
								local label, insertText = _des_0[1], _des_0[2] -- 1388
								_accum_0[_len_0] = { -- 1389
									label, -- 1389
									insertText, -- 1389
									"field" -- 1389
								} -- 1389
								_len_0 = _len_0 + 1 -- 1389
							end -- 1388
							suggestions = _accum_0 -- 1388
						end -- 1388
						return { -- 1390
							success = true, -- 1390
							suggestions = suggestions -- 1390
						} -- 1390
					end -- 1387
				end -- 1344
			end -- 1281
		end -- 1281
	end -- 1281
	return { -- 1280
		success = false -- 1280
	} -- 1280
end) -- 1280
local getUploadFilename -- 1392
getUploadFilename = function(req, multipartFilename) -- 1392
	local filename = req.params.name -- 1393
	if not (type(filename) == "string" and filename ~= "") then -- 1394
		filename = multipartFilename -- 1394
	end -- 1394
	if not (type(filename) == "string" and filename ~= "") then -- 1395
		return -- 1395
	end -- 1395
	if filename:sub(1, 1) == "/" or filename:sub(-1) == "/" or filename:find("//", 1, true) or filename:find("\\", 1, true) or filename:find(":", 1, true) or filename:find("\0", 1, true) then -- 1398
		return -- 1398
	end -- 1398
	local parts -- 1399
	do -- 1399
		local _accum_0 = { } -- 1399
		local _len_0 = 1 -- 1399
		for part in filename:gmatch("[^/]+") do -- 1399
			_accum_0[_len_0] = part -- 1399
			_len_0 = _len_0 + 1 -- 1399
		end -- 1399
		parts = _accum_0 -- 1399
	end -- 1399
	if #parts == 0 then -- 1400
		return -- 1400
	end -- 1400
	for _index_0 = 1, #parts do -- 1401
		local part = parts[_index_0] -- 1401
		if part == "." or part == ".." or part == "" then -- 1402
			return -- 1402
		end -- 1402
	end -- 1401
	return filename -- 1403
end -- 1392
HttpServer:upload("/upload", function(req, multipartFilename) -- 1407
	do -- 1408
		local _type_0 = type(req) -- 1408
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1408
		if _tab_0 then -- 1408
			local path -- 1408
			do -- 1408
				local _obj_0 = req.params -- 1408
				local _type_1 = type(_obj_0) -- 1408
				if "table" == _type_1 or "userdata" == _type_1 then -- 1408
					path = _obj_0.path -- 1408
				end -- 1408
			end -- 1408
			if path ~= nil then -- 1408
				local filename = getUploadFilename(req, multipartFilename) -- 1409
				if filename then -- 1409
					local uploadPath = Path(Content.writablePath, ".upload") -- 1410
					if not Content:exist(uploadPath) then -- 1411
						Content:mkdir(uploadPath) -- 1412
					end -- 1411
					local targetPath = Path(uploadPath, filename) -- 1413
					Content:mkdir(Path:getPath(targetPath)) -- 1414
					return targetPath -- 1415
				end -- 1409
			end -- 1408
		end -- 1408
	end -- 1408
	return nil -- 1407
end, function(req, file) -- 1416
	do -- 1417
		local _type_0 = type(req) -- 1417
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1417
		if _tab_0 then -- 1417
			local path -- 1417
			do -- 1417
				local _obj_0 = req.params -- 1417
				local _type_1 = type(_obj_0) -- 1417
				if "table" == _type_1 or "userdata" == _type_1 then -- 1417
					path = _obj_0.path -- 1417
				end -- 1417
			end -- 1417
			if path ~= nil then -- 1417
				path = Path(Content.writablePath, path) -- 1418
				if Content:exist(path) then -- 1419
					local uploadPath = Path(Content.writablePath, ".upload") -- 1420
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1421
					Content:mkdir(Path:getPath(targetPath)) -- 1422
					if Content:move(file, targetPath) then -- 1423
						return true -- 1424
					end -- 1423
				end -- 1419
			end -- 1417
		end -- 1417
	end -- 1417
	return false -- 1416
end) -- 1405
HttpServer:post("/list", function(req) -- 1427
	do -- 1428
		local _type_0 = type(req) -- 1428
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1428
		if _tab_0 then -- 1428
			local path -- 1428
			do -- 1428
				local _obj_0 = req.body -- 1428
				local _type_1 = type(_obj_0) -- 1428
				if "table" == _type_1 or "userdata" == _type_1 then -- 1428
					path = _obj_0.path -- 1428
				end -- 1428
			end -- 1428
			if path ~= nil then -- 1428
				if Content:exist(path) then -- 1429
					local files = { } -- 1430
					local visitAssets -- 1431
					visitAssets = function(path, folder) -- 1431
						local dirs = Content:getDirs(path) -- 1432
						for _index_0 = 1, #dirs do -- 1433
							local dir = dirs[_index_0] -- 1433
							if dir:match("^%.") or dir == "node_modules" then -- 1434
								goto _continue_0 -- 1434
							end -- 1434
							local current -- 1435
							if folder == "" then -- 1435
								current = dir -- 1436
							else -- 1438
								current = Path(folder, dir) -- 1438
							end -- 1435
							files[#files + 1] = current -- 1439
							visitAssets(Path(path, dir), current) -- 1440
							::_continue_0:: -- 1434
						end -- 1433
						local fs = Content:getFiles(path) -- 1441
						for _index_0 = 1, #fs do -- 1442
							local f = fs[_index_0] -- 1442
							if (".DS_Store" == f) then -- 1443
								goto _continue_1 -- 1444
							end -- 1443
							if folder == "" then -- 1445
								files[#files + 1] = f -- 1446
							else -- 1448
								files[#files + 1] = Path(folder, f) -- 1448
							end -- 1445
							::_continue_1:: -- 1443
						end -- 1442
					end -- 1431
					visitAssets(path, "") -- 1449
					if #files == 0 then -- 1450
						files = nil -- 1450
					end -- 1450
					return { -- 1451
						success = true, -- 1451
						files = files -- 1451
					} -- 1451
				end -- 1429
			end -- 1428
		end -- 1428
	end -- 1428
	return { -- 1427
		success = false -- 1427
	} -- 1427
end) -- 1427
HttpServer:post("/info", function(req) -- 1453
	local Entry = require("Script.Dev.Entry") -- 1454
	local config = Entry.getConfig() -- 1455
	do -- 1456
		local _type_0 = type(req) -- 1456
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1456
		if _tab_0 then -- 1456
			local webIDETourCompleted -- 1456
			do -- 1456
				local _obj_0 = req.body -- 1456
				local _type_1 = type(_obj_0) -- 1456
				if "table" == _type_1 or "userdata" == _type_1 then -- 1456
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1456
				end -- 1456
			end -- 1456
			if webIDETourCompleted ~= nil then -- 1456
				config.webIDETourCompleted = webIDETourCompleted == true -- 1457
			end -- 1456
		end -- 1456
	end -- 1456
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1458
	local engineDev = Entry.getEngineDev() -- 1459
	Entry.connectWebIDE() -- 1460
	return { -- 1462
		platform = App.platform, -- 1462
		locale = App.locale, -- 1463
		version = App.version, -- 1464
		engineDev = engineDev, -- 1465
		webProfiler = webProfiler, -- 1466
		drawerWidth = drawerWidth, -- 1467
		webIDETourCompleted = webIDETourCompleted == true -- 1468
	} -- 1461
end) -- 1453
local ensureLLMConfigTable -- 1470
ensureLLMConfigTable = function() -- 1470
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1471
	if columns and #columns > 0 then -- 1472
		local expected = { -- 1474
			id = true, -- 1474
			name = true, -- 1475
			url = true, -- 1476
			model = true, -- 1477
			api_key = true, -- 1478
			context_window = true, -- 1479
			temperature = true, -- 1480
			max_tokens = true, -- 1481
			reasoning_effort = true, -- 1482
			custom_options = true, -- 1483
			supports_function_calling = true, -- 1484
			active = true, -- 1485
			created_at = true, -- 1486
			updated_at = true -- 1487
		} -- 1473
		local existing = { } -- 1489
		local valid = true -- 1490
		for _index_0 = 1, #columns do -- 1491
			local row = columns[_index_0] -- 1491
			local columnName = tostring(row[2]) -- 1492
			existing[columnName] = true -- 1493
			if not expected[columnName] then -- 1494
				valid = false -- 1495
				break -- 1496
			end -- 1494
		end -- 1491
		if valid then -- 1497
			if not existing.context_window then -- 1498
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1499
			end -- 1498
			if not existing.temperature then -- 1500
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1501
			end -- 1500
			if not existing.max_tokens then -- 1502
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 64000") -- 1503
			end -- 1502
			if not existing.reasoning_effort then -- 1504
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1505
			end -- 1504
			if not existing.custom_options then -- 1506
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1507
			end -- 1506
			if not existing.supports_function_calling then -- 1508
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1509
			end -- 1508
		else -- 1511
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1511
		end -- 1497
	end -- 1472
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
	]]) -- 1512
	return require("Agent.LLMConfigMigration").upgradeLLMConfig() -- 1531
end -- 1470
local normalizeContextWindow -- 1533
normalizeContextWindow = function(value) -- 1533
	local contextWindow = tonumber(value) -- 1534
	if contextWindow == nil or contextWindow < 64000 then -- 1535
		return 64000 -- 1536
	end -- 1535
	return math.max(64000, math.floor(contextWindow)) -- 1537
end -- 1533
local normalizeTemperature -- 1539
normalizeTemperature = function(value) -- 1539
	local temperature = tonumber(value) -- 1540
	if temperature == nil then -- 1541
		return 0.1 -- 1542
	end -- 1541
	return math.max(0, math.min(2, temperature)) -- 1543
end -- 1539
local normalizeMaxTokens -- 1545
normalizeMaxTokens = function(value) -- 1545
	local maxTokens = tonumber(value) -- 1546
	if maxTokens == nil or maxTokens < 1 then -- 1547
		return 64000 -- 1548
	end -- 1547
	return math.max(1, math.floor(maxTokens)) -- 1549
end -- 1545
local normalizeReasoningEffort -- 1551
normalizeReasoningEffort = function(value) -- 1551
	if value == nil then -- 1552
		return "" -- 1553
	end -- 1552
	local effort = tostring(value) -- 1554
	return effort:match("^%s*(.-)%s*$") or "" -- 1555
end -- 1551
local normalizeCustomOptions -- 1557
normalizeCustomOptions = function(value) -- 1557
	if value == nil then -- 1558
		return "" -- 1559
	end -- 1558
	local options = tostring(value) -- 1560
	options = options:match("^%s*(.-)%s*$") or "" -- 1561
	return options -- 1562
end -- 1557
local validateCustomOptions -- 1564
validateCustomOptions = function(value) -- 1564
	local options = normalizeCustomOptions(value) -- 1565
	if options == "" then -- 1566
		return true -- 1566
	end -- 1566
	if not options:match("^%s*{") then -- 1567
		return false -- 1567
	end -- 1567
	local decoded = json.decode(options) -- 1568
	return type(decoded) == "table" -- 1569
end -- 1564
HttpServer:post("/llm/list", function() -- 1571
	ensureLLMConfigTable() -- 1572
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1573
	local items -- 1577
	if rows and #rows > 0 then -- 1577
		local _accum_0 = { } -- 1578
		local _len_0 = 1 -- 1578
		for _index_0 = 1, #rows do -- 1578
			local _des_0 = rows[_index_0] -- 1578
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1578
			_accum_0[_len_0] = { -- 1579
				id = id, -- 1579
				name = name, -- 1579
				url = url, -- 1579
				model = model, -- 1579
				key = key, -- 1579
				contextWindow = normalizeContextWindow(contextWindow), -- 1579
				temperature = normalizeTemperature(temperature), -- 1579
				maxTokens = normalizeMaxTokens(maxTokens), -- 1579
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1579
				customOptions = normalizeCustomOptions(customOptions), -- 1579
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1579
			} -- 1579
			_len_0 = _len_0 + 1 -- 1579
		end -- 1578
		items = _accum_0 -- 1577
	end -- 1577
	return { -- 1580
		success = true, -- 1580
		items = items -- 1580
	} -- 1580
end) -- 1571
HttpServer:post("/llm/create", function(req) -- 1582
	ensureLLMConfigTable() -- 1583
	do -- 1584
		local _type_0 = type(req) -- 1584
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1584
		if _tab_0 then -- 1584
			local body = req.body -- 1584
			if body ~= nil then -- 1584
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1585
				local now = os.time() -- 1586
				if name == nil or url == nil or model == nil or key == nil then -- 1587
					return invalidArguments -- 1588
				end -- 1587
				contextWindow = normalizeContextWindow(contextWindow) -- 1589
				temperature = normalizeTemperature(temperature) -- 1590
				maxTokens = normalizeMaxTokens(maxTokens) -- 1591
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1592
				customOptions = normalizeCustomOptions(customOptions) -- 1593
				if not validateCustomOptions(customOptions) then -- 1594
					return { -- 1594
						success = false, -- 1594
						message = "customOptions must be a JSON object" -- 1594
					} -- 1594
				end -- 1594
				if supportsFunctionCalling == false then -- 1595
					supportsFunctionCalling = 0 -- 1595
				else -- 1595
					supportsFunctionCalling = 1 -- 1595
				end -- 1595
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1602
					tostring(name), -- 1602
					tostring(url), -- 1603
					tostring(model), -- 1604
					tostring(key), -- 1605
					contextWindow, -- 1606
					temperature, -- 1607
					maxTokens, -- 1608
					reasoningEffort, -- 1609
					customOptions, -- 1610
					supportsFunctionCalling, -- 1611
					1, -- 1612
					now, -- 1613
					now -- 1614
				}) -- 1596
				return { -- 1616
					success = affected >= 0 -- 1616
				} -- 1616
			end -- 1584
		end -- 1584
	end -- 1584
	return invalidArguments -- 1582
end) -- 1582
HttpServer:post("/llm/update", function(req) -- 1618
	ensureLLMConfigTable() -- 1619
	do -- 1620
		local _type_0 = type(req) -- 1620
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1620
		if _tab_0 then -- 1620
			local body = req.body -- 1620
			if body ~= nil then -- 1620
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1621
				local now = os.time() -- 1622
				id = tonumber(id) -- 1623
				if id == nil then -- 1624
					return invalidArguments -- 1624
				end -- 1624
				contextWindow = normalizeContextWindow(contextWindow) -- 1625
				temperature = normalizeTemperature(temperature) -- 1626
				maxTokens = normalizeMaxTokens(maxTokens) -- 1627
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1628
				customOptions = normalizeCustomOptions(customOptions) -- 1629
				if not validateCustomOptions(customOptions) then -- 1630
					return { -- 1630
						success = false, -- 1630
						message = "customOptions must be a JSON object" -- 1630
					} -- 1630
				end -- 1630
				if supportsFunctionCalling == false then -- 1631
					supportsFunctionCalling = 0 -- 1631
				else -- 1631
					supportsFunctionCalling = 1 -- 1631
				end -- 1631
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1636
					tostring(name), -- 1636
					tostring(url), -- 1637
					tostring(model), -- 1638
					tostring(key), -- 1639
					contextWindow, -- 1640
					temperature, -- 1641
					maxTokens, -- 1642
					reasoningEffort, -- 1643
					customOptions, -- 1644
					supportsFunctionCalling, -- 1645
					now, -- 1646
					id -- 1647
				}) -- 1632
				return { -- 1649
					success = affected >= 0 -- 1649
				} -- 1649
			end -- 1620
		end -- 1620
	end -- 1620
	return invalidArguments -- 1618
end) -- 1618
HttpServer:post("/llm/delete", function(req) -- 1651
	ensureLLMConfigTable() -- 1652
	do -- 1653
		local _type_0 = type(req) -- 1653
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1653
		if _tab_0 then -- 1653
			local id -- 1653
			do -- 1653
				local _obj_0 = req.body -- 1653
				local _type_1 = type(_obj_0) -- 1653
				if "table" == _type_1 or "userdata" == _type_1 then -- 1653
					id = _obj_0.id -- 1653
				end -- 1653
			end -- 1653
			if id ~= nil then -- 1653
				id = tonumber(id) -- 1654
				if id == nil then -- 1655
					return invalidArguments -- 1655
				end -- 1655
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1656
					id -- 1656
				}) -- 1656
				return { -- 1657
					success = affected >= 0 -- 1657
				} -- 1657
			end -- 1653
		end -- 1653
	end -- 1653
	return invalidArguments -- 1651
end) -- 1651
HttpServer:post("/local-agent/list", function() -- 1659
	return { -- 1660
		success = true, -- 1660
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1660
		items = AgentLocalAgent.listConfigs() -- 1660
	} -- 1660
end) -- 1659
HttpServer:post("/local-agent/save", function(req) -- 1662
	do -- 1663
		local _type_0 = type(req) -- 1663
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1663
		if _tab_0 then -- 1663
			local body = req.body -- 1663
			if body ~= nil then -- 1663
				return AgentLocalAgent.saveConfig(body) -- 1664
			end -- 1663
		end -- 1663
	end -- 1663
	return invalidArguments -- 1662
end) -- 1662
HttpServer:post("/local-agent/delete", function(req) -- 1666
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
				return AgentLocalAgent.deleteConfig(id) -- 1668
			end -- 1667
		end -- 1667
	end -- 1667
	return invalidArguments -- 1666
end) -- 1666
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1670
	do -- 1671
		local _type_0 = type(req) -- 1671
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1671
		if _tab_0 then -- 1671
			local id -- 1671
			do -- 1671
				local _obj_0 = req.body -- 1671
				local _type_1 = type(_obj_0) -- 1671
				if "table" == _type_1 or "userdata" == _type_1 then -- 1671
					id = _obj_0.id -- 1671
				end -- 1671
			end -- 1671
			if id ~= nil then -- 1671
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1672
			end -- 1671
		end -- 1671
	end -- 1671
	return invalidArguments -- 1670
end) -- 1670
HttpServer:post("/stat", function(req) -- 1674
	do -- 1675
		local _type_0 = type(req) -- 1675
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1675
		if _tab_0 then -- 1675
			local path -- 1675
			do -- 1675
				local _obj_0 = req.body -- 1675
				local _type_1 = type(_obj_0) -- 1675
				if "table" == _type_1 or "userdata" == _type_1 then -- 1675
					path = _obj_0.path -- 1675
				end -- 1675
			end -- 1675
			if path ~= nil then -- 1675
				if not Content:exist(path) then -- 1676
					return { -- 1677
						success = false, -- 1677
						message = "target not existed" -- 1677
					} -- 1677
				end -- 1676
				if Content:isdir(path) then -- 1678
					return { -- 1679
						success = false, -- 1679
						message = "failed to stat a directory" -- 1679
					} -- 1679
				end -- 1678
				local size, isBinary = Content:getAttr(path) -- 1680
				if size then -- 1680
					return { -- 1681
						success = true, -- 1681
						size = size, -- 1681
						isBinary = isBinary -- 1681
					} -- 1681
				end -- 1680
			end -- 1675
		end -- 1675
	end -- 1675
	return { -- 1674
		success = false, -- 1674
		message = "failed to stat" -- 1674
	} -- 1674
end) -- 1674
HttpServer:post("/new", function(req) -- 1683
	do -- 1684
		local _type_0 = type(req) -- 1684
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1684
		if _tab_0 then -- 1684
			local path -- 1684
			do -- 1684
				local _obj_0 = req.body -- 1684
				local _type_1 = type(_obj_0) -- 1684
				if "table" == _type_1 or "userdata" == _type_1 then -- 1684
					path = _obj_0.path -- 1684
				end -- 1684
			end -- 1684
			local content -- 1684
			do -- 1684
				local _obj_0 = req.body -- 1684
				local _type_1 = type(_obj_0) -- 1684
				if "table" == _type_1 or "userdata" == _type_1 then -- 1684
					content = _obj_0.content -- 1684
				end -- 1684
			end -- 1684
			local folder -- 1684
			do -- 1684
				local _obj_0 = req.body -- 1684
				local _type_1 = type(_obj_0) -- 1684
				if "table" == _type_1 or "userdata" == _type_1 then -- 1684
					folder = _obj_0.folder -- 1684
				end -- 1684
			end -- 1684
			if path ~= nil and content ~= nil and folder ~= nil then -- 1684
				if Content:exist(path) then -- 1685
					return { -- 1686
						success = false, -- 1686
						message = "TargetExisted" -- 1686
					} -- 1686
				end -- 1685
				local parent = Path:getPath(path) -- 1687
				local files = Content:getFiles(parent) -- 1688
				if folder then -- 1689
					local name = Path:getFilename(path):lower() -- 1690
					for _index_0 = 1, #files do -- 1691
						local file = files[_index_0] -- 1691
						if name == Path:getFilename(file):lower() then -- 1692
							return { -- 1693
								success = false, -- 1693
								message = "TargetExisted" -- 1693
							} -- 1693
						end -- 1692
					end -- 1691
					if Content:mkdir(path) then -- 1694
						return { -- 1695
							success = true -- 1695
						} -- 1695
					end -- 1694
				else -- 1697
					local name = Path:getName(path):lower() -- 1697
					for _index_0 = 1, #files do -- 1698
						local file = files[_index_0] -- 1698
						if name == Path:getName(file):lower() then -- 1699
							local ext = Path:getExt(file) -- 1700
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1701
								goto _continue_0 -- 1702
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1703
								goto _continue_0 -- 1704
							end -- 1701
							return { -- 1705
								success = false, -- 1705
								message = "SourceExisted" -- 1705
							} -- 1705
						end -- 1699
						::_continue_0:: -- 1699
					end -- 1698
					if Content:save(path, content) then -- 1706
						return { -- 1707
							success = true -- 1707
						} -- 1707
					end -- 1706
				end -- 1689
			end -- 1684
		end -- 1684
	end -- 1684
	return { -- 1683
		success = false, -- 1683
		message = "Failed" -- 1683
	} -- 1683
end) -- 1683
local deleteAsset -- 1709
deleteAsset = function(path) -- 1709
	if not Content:exist(path) then -- 1710
		return false -- 1710
	end -- 1710
	local projectRoot -- 1711
	if Content:isdir(path) and isProjectRootDir(path) then -- 1711
		projectRoot = path -- 1711
	else -- 1711
		projectRoot = nil -- 1711
	end -- 1711
	local parent = Path:getPath(path) -- 1712
	local files = Content:getFiles(parent) -- 1713
	local name = Path:getName(path):lower() -- 1714
	local ext = Path:getExt(path) -- 1715
	for _index_0 = 1, #files do -- 1716
		local file = files[_index_0] -- 1716
		if name == Path:getName(file):lower() then -- 1717
			local _exp_0 = Path:getExt(file) -- 1718
			if "tl" == _exp_0 then -- 1718
				if ("vs" == ext) then -- 1718
					Content:remove(Path(parent, file)) -- 1719
				end -- 1718
			elseif "lua" == _exp_0 then -- 1720
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1720
					Content:remove(Path(parent, file)) -- 1721
				end -- 1720
			end -- 1718
		end -- 1717
	end -- 1716
	if Content:remove(path) then -- 1722
		if projectRoot then -- 1723
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1724
		end -- 1723
		return true -- 1725
	end -- 1722
	return false -- 1726
end -- 1709
local moveAsset -- 1728
moveAsset = function(old, new) -- 1728
	if not (Content:exist(old) and not Content:exist(new)) then -- 1729
		return false -- 1729
	end -- 1729
	local renamedDir = Content:isdir(old) -- 1730
	local parent = Path:getPath(new) -- 1731
	local files = Content:getFiles(parent) -- 1732
	if renamedDir then -- 1733
		local name = Path:getFilename(new):lower() -- 1734
		for _index_0 = 1, #files do -- 1735
			local file = files[_index_0] -- 1735
			if name == Path:getFilename(file):lower() then -- 1736
				return false -- 1737
			end -- 1736
		end -- 1735
	else -- 1739
		local name = Path:getName(new):lower() -- 1739
		local ext = Path:getExt(new) -- 1740
		for _index_0 = 1, #files do -- 1741
			local file = files[_index_0] -- 1741
			if name == Path:getName(file):lower() then -- 1742
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1743
					goto _continue_0 -- 1744
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1745
					goto _continue_0 -- 1746
				end -- 1743
				return false -- 1747
			end -- 1742
			::_continue_0:: -- 1742
		end -- 1741
	end -- 1733
	if not Content:move(old, new) then -- 1748
		return false -- 1748
	end -- 1748
	if renamedDir then -- 1749
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1750
	end -- 1749
	local newParent = Path:getPath(new) -- 1751
	parent = Path:getPath(old) -- 1752
	files = Content:getFiles(parent) -- 1753
	local newName = Path:getName(new) -- 1754
	local oldName = Path:getName(old) -- 1755
	local name = oldName:lower() -- 1756
	local ext = Path:getExt(old) -- 1757
	for _index_0 = 1, #files do -- 1758
		local file = files[_index_0] -- 1758
		if name == Path:getName(file):lower() then -- 1759
			local _exp_0 = Path:getExt(file) -- 1760
			if "tl" == _exp_0 then -- 1760
				if ("vs" == ext) then -- 1760
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1761
				end -- 1760
			elseif "lua" == _exp_0 then -- 1762
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1762
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1763
				end -- 1762
			end -- 1760
		end -- 1759
	end -- 1758
	return true -- 1764
end -- 1728
HttpServer:post("/delete", function(req) -- 1766
	do -- 1767
		local _type_0 = type(req) -- 1767
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1767
		if _tab_0 then -- 1767
			local path -- 1767
			do -- 1767
				local _obj_0 = req.body -- 1767
				local _type_1 = type(_obj_0) -- 1767
				if "table" == _type_1 or "userdata" == _type_1 then -- 1767
					path = _obj_0.path -- 1767
				end -- 1767
			end -- 1767
			if path ~= nil then -- 1767
				if deleteAsset(path) then -- 1768
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
HttpServer:post("/rename", function(req) -- 1770
	do -- 1771
		local _type_0 = type(req) -- 1771
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1771
		if _tab_0 then -- 1771
			local old -- 1771
			do -- 1771
				local _obj_0 = req.body -- 1771
				local _type_1 = type(_obj_0) -- 1771
				if "table" == _type_1 or "userdata" == _type_1 then -- 1771
					old = _obj_0.old -- 1771
				end -- 1771
			end -- 1771
			local new -- 1771
			do -- 1771
				local _obj_0 = req.body -- 1771
				local _type_1 = type(_obj_0) -- 1771
				if "table" == _type_1 or "userdata" == _type_1 then -- 1771
					new = _obj_0.new -- 1771
				end -- 1771
			end -- 1771
			if old ~= nil and new ~= nil then -- 1771
				if moveAsset(old, new) then -- 1772
					return { -- 1772
						success = true -- 1772
					} -- 1772
				end -- 1772
			end -- 1771
		end -- 1771
	end -- 1771
	return { -- 1770
		success = false -- 1770
	} -- 1770
end) -- 1770
local normalizeAssetPaths -- 1774
normalizeAssetPaths = function(paths) -- 1774
	if not (type(paths) == "table") then -- 1775
		return nil -- 1775
	end -- 1775
	local unique = { } -- 1776
	local candidates = { } -- 1777
	for _index_0 = 1, #paths do -- 1778
		local path = paths[_index_0] -- 1778
		if not (type(path) == "string") then -- 1779
			return nil -- 1779
		end -- 1779
		local relative = relativeToRoot(path, Content.writablePath) -- 1780
		if relative == nil or relative == "" or not Content:exist(path) then -- 1781
			return nil -- 1781
		end -- 1781
		if not unique[path] then -- 1782
			unique[path] = true -- 1783
			candidates[#candidates + 1] = path -- 1784
		end -- 1782
	end -- 1778
	table.sort(candidates, function(a, b) -- 1785
		return #a < #b -- 1785
	end) -- 1785
	local result = { } -- 1786
	for _index_0 = 1, #candidates do -- 1787
		local path = candidates[_index_0] -- 1787
		local contained = false -- 1788
		for _index_1 = 1, #result do -- 1789
			local parent = result[_index_1] -- 1789
			if relativeToRoot(path, parent) ~= nil then -- 1790
				contained = true -- 1791
				break -- 1792
			end -- 1790
		end -- 1789
		if not contained then -- 1793
			result[#result + 1] = path -- 1793
		end -- 1793
	end -- 1787
	return result -- 1794
end -- 1774
HttpServer:postSchedule("/assets/batch", function(req) -- 1796
	do -- 1797
		local _type_0 = type(req) -- 1797
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1797
		if _tab_0 then -- 1797
			local operation -- 1797
			do -- 1797
				local _obj_0 = req.body -- 1797
				local _type_1 = type(_obj_0) -- 1797
				if "table" == _type_1 or "userdata" == _type_1 then -- 1797
					operation = _obj_0.operation -- 1797
				end -- 1797
			end -- 1797
			local sources -- 1797
			do -- 1797
				local _obj_0 = req.body -- 1797
				local _type_1 = type(_obj_0) -- 1797
				if "table" == _type_1 or "userdata" == _type_1 then -- 1797
					sources = _obj_0.sources -- 1797
				end -- 1797
			end -- 1797
			if operation ~= nil and sources ~= nil then -- 1797
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1798
					return { -- 1798
						success = false, -- 1798
						message = "invalid operation" -- 1798
					} -- 1798
				end -- 1798
				sources = normalizeAssetPaths(sources) -- 1799
				if not (sources and #sources > 0) then -- 1800
					return { -- 1800
						success = false, -- 1800
						message = "invalid sources" -- 1800
					} -- 1800
				end -- 1800
				local target = req.body.target -- 1801
				local destinations = { } -- 1802
				if operation ~= "delete" then -- 1803
					if not (type(target) == "string") then -- 1804
						return { -- 1804
							success = false, -- 1804
							message = "invalid target" -- 1804
						} -- 1804
					end -- 1804
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1805
					if targetRelative == nil then -- 1806
						return { -- 1806
							success = false, -- 1806
							message = "invalid target" -- 1806
						} -- 1806
					end -- 1806
					if not (Content:exist(target) and Content:isdir(target)) then -- 1807
						return { -- 1807
							success = false, -- 1807
							message = "invalid target" -- 1807
						} -- 1807
					end -- 1807
					for _index_0 = 1, #sources do -- 1808
						local source = sources[_index_0] -- 1808
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1809
							return { -- 1810
								success = false, -- 1810
								message = "target inside source" -- 1810
							} -- 1810
						end -- 1809
						local destination = Path(target, Path:getFilename(source)) -- 1811
						if Content:exist(destination) then -- 1812
							return { -- 1812
								success = false, -- 1812
								message = "target existed" -- 1812
							} -- 1812
						end -- 1812
						if destinations[destination] then -- 1813
							return { -- 1813
								success = false, -- 1813
								message = "duplicate target" -- 1813
							} -- 1813
						end -- 1813
						destinations[destination] = true -- 1814
					end -- 1808
				end -- 1803
				local changes = { } -- 1815
				local affectedSet = { } -- 1816
				local affectedDirectories = { } -- 1817
				local addAffected -- 1818
				addAffected = function(dir) -- 1818
					if affectedSet[dir] then -- 1819
						return -- 1819
					end -- 1819
					affectedSet[dir] = true -- 1820
					affectedDirectories[#affectedDirectories + 1] = dir -- 1821
				end -- 1818
				if operation ~= "delete" then -- 1822
					addAffected(target) -- 1822
				end -- 1822
				for _index_0 = 1, #sources do -- 1823
					local source = sources[_index_0] -- 1823
					addAffected(Path:getPath(source)) -- 1824
					if operation == "delete" then -- 1825
						if not deleteAsset(source) then -- 1826
							return { -- 1826
								success = false, -- 1826
								message = "delete failed", -- 1826
								changes = changes, -- 1826
								affectedDirectories = affectedDirectories -- 1826
							} -- 1826
						end -- 1826
						changes[#changes + 1] = { -- 1827
							old = source -- 1827
						} -- 1827
					else -- 1829
						local destination = Path(target, Path:getFilename(source)) -- 1829
						local ok -- 1830
						if operation == "copy" then -- 1830
							ok = Content:copyAsync(source, destination) -- 1831
						else -- 1833
							ok = moveAsset(source, destination) -- 1833
						end -- 1830
						if not ok then -- 1834
							return { -- 1834
								success = false, -- 1834
								message = operation .. " failed", -- 1834
								changes = changes, -- 1834
								affectedDirectories = affectedDirectories -- 1834
							} -- 1834
						end -- 1834
						changes[#changes + 1] = { -- 1835
							old = source, -- 1835
							new = destination -- 1835
						} -- 1835
					end -- 1825
				end -- 1823
				return { -- 1836
					success = true, -- 1836
					changes = changes, -- 1836
					affectedDirectories = affectedDirectories -- 1836
				} -- 1836
			end -- 1797
		end -- 1797
	end -- 1797
	return { -- 1796
		success = false, -- 1796
		message = "invalid request" -- 1796
	} -- 1796
end) -- 1796
local withProjectSearchPaths -- 1838
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1838
	local fallbackPaths = { } -- 1839
	local addFallback -- 1840
	addFallback = function(dir) -- 1840
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1840
			fallbackPaths[#fallbackPaths + 1] = dir -- 1840
		end -- 1840
	end -- 1840
	if projectRoot and projectRoot ~= "" then -- 1841
		addFallback(Path(projectRoot, "Script")) -- 1842
		addFallback(projectRoot) -- 1843
	end -- 1841
	if projFile then -- 1844
		local projDir = getProjectDirFromFile(projFile) -- 1845
		if projDir then -- 1845
			addFallback(Path(projDir, "Script")) -- 1846
			addFallback(projDir) -- 1847
		else -- 1849
			addFallback(Path:getPath(projFile)) -- 1849
		end -- 1845
	end -- 1844
	if not (#fallbackPaths > 0) then -- 1850
		return fn() -- 1850
	end -- 1850
	local searchPaths = Content.searchPaths -- 1851
	for _index_0 = 1, #fallbackPaths do -- 1852
		local dir = fallbackPaths[_index_0] -- 1852
		Content:addSearchPath(dir) -- 1852
	end -- 1852
	local _ <close> = setmetatable({ }, { -- 1853
		__close = function() -- 1853
			Content.searchPaths = searchPaths -- 1853
		end -- 1853
	}) -- 1853
	return fn() -- 1854
end -- 1838
HttpServer:post("/exist", function(req) -- 1855
	do -- 1856
		local _type_0 = type(req) -- 1856
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1856
		if _tab_0 then -- 1856
			local file -- 1856
			do -- 1856
				local _obj_0 = req.body -- 1856
				local _type_1 = type(_obj_0) -- 1856
				if "table" == _type_1 or "userdata" == _type_1 then -- 1856
					file = _obj_0.file -- 1856
				end -- 1856
			end -- 1856
			if file ~= nil then -- 1856
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1857
					return { -- 1858
						success = Content:exist(file) -- 1858
					} -- 1858
				end) -- 1857
			end -- 1856
		end -- 1856
	end -- 1856
	return { -- 1855
		success = false -- 1855
	} -- 1855
end) -- 1855
HttpServer:postSchedule("/read", function(req) -- 1859
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
				local readFile -- 1861
				readFile = function() -- 1861
					if Content:exist(path) and not Content:isdir(path) then -- 1862
						local content = Content:loadAsync(path) -- 1863
						if content then -- 1863
							return { -- 1864
								content = content, -- 1864
								success = true, -- 1864
								fullPath = Content:getFullPath(path) -- 1864
							} -- 1864
						end -- 1863
					end -- 1862
					return nil -- 1861
				end -- 1861
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1865
				if result then -- 1865
					return result -- 1865
				end -- 1865
			end -- 1860
		end -- 1860
	end -- 1860
	return { -- 1859
		success = false -- 1859
	} -- 1859
end) -- 1859
local agentDocLanguage -- 1867
agentDocLanguage = function(language) -- 1867
	if language == "zh-Hans" then -- 1868
		return "zh" -- 1868
	else -- 1868
		return "en" -- 1868
	end -- 1868
end -- 1867
HttpServer:postSchedule("/doc/search", function(req) -- 1870
	local body = req.body or { } -- 1871
	local language = body.docLanguage -- 1872
	if not (("en" == language or "zh-Hans" == language)) then -- 1873
		return { -- 1873
			success = false, -- 1873
			message = "unsupported doc language" -- 1873
		} -- 1873
	end -- 1873
	local docType = body.docType -- 1874
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1875
		return { -- 1875
			success = false, -- 1875
			message = "unsupported doc type" -- 1875
		} -- 1875
	end -- 1875
	local codeLanguage = body.programmingLanguage -- 1876
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1877
		return { -- 1877
			success = false, -- 1877
			message = "unsupported programming language" -- 1877
		} -- 1877
	end -- 1877
	if not body.pattern then -- 1878
		return { -- 1878
			success = false, -- 1878
			message = "missing pattern" -- 1878
		} -- 1878
	end -- 1878
	local result = nil -- 1879
	AgentTools.searchDoraDocHttp({ -- 1881
		pattern = body.pattern, -- 1881
		docLanguage = agentDocLanguage(language), -- 1882
		docType = docType, -- 1883
		programmingLanguage = codeLanguage, -- 1884
		limit = body.limit, -- 1885
		useRegex = body.useRegex, -- 1886
		caseSensitive = body.caseSensitive, -- 1887
		includeContent = body.includeContent, -- 1888
		contentWindow = body.contentWindow -- 1889
	}, function(res) -- 1890
		result = res -- 1891
	end) -- 1880
	wait(function() -- 1892
		return result ~= nil -- 1892
	end) -- 1892
	if result and result.success then -- 1893
		result.docLanguage = language -- 1894
	end -- 1893
	if result then -- 1895
		return result -- 1896
	else -- 1898
		return { -- 1898
			success = false, -- 1898
			message = "doc search failed" -- 1898
		} -- 1898
	end -- 1895
	return { -- 1870
		success = false, -- 1870
		message = "invalid call" -- 1870
	} -- 1870
end) -- 1870
HttpServer:postSchedule("/doc/read", function(req) -- 1900
	local body = req.body or { } -- 1901
	local language = body.docLanguage -- 1902
	if not (("en" == language or "zh-Hans" == language)) then -- 1903
		return { -- 1903
			success = false, -- 1903
			message = "unsupported doc language" -- 1903
		} -- 1903
	end -- 1903
	if not body.file then -- 1904
		return { -- 1904
			success = false, -- 1904
			message = "missing file" -- 1904
		} -- 1904
	end -- 1904
	local result = AgentTools.readDoraDoc({ -- 1906
		docLanguage = agentDocLanguage(language), -- 1906
		file = body.file, -- 1907
		startLine = body.startLine, -- 1908
		endLine = body.endLine -- 1909
	}) -- 1905
	if result and result.success then -- 1910
		result.docLanguage = language -- 1911
	end -- 1910
	return result -- 1912
end) -- 1900
HttpServer:get("/read-sync", function(req) -- 1914
	do -- 1915
		local _type_0 = type(req) -- 1915
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1915
		if _tab_0 then -- 1915
			local params = req.params -- 1915
			if params ~= nil then -- 1915
				local path = params.path -- 1916
				if not (type(path) == "string" and path ~= "") then -- 1917
					return { -- 1917
						success = false, -- 1917
						message = "invalid path" -- 1917
					} -- 1917
				end -- 1917
				local exts -- 1918
				if params.exts then -- 1918
					local _accum_0 = { } -- 1919
					local _len_0 = 1 -- 1919
					for ext in params.exts:gmatch("[^|]*") do -- 1919
						_accum_0[_len_0] = ext -- 1919
						_len_0 = _len_0 + 1 -- 1919
					end -- 1919
					exts = _accum_0 -- 1919
				else -- 1920
					exts = { -- 1920
						"" -- 1920
					} -- 1920
				end -- 1918
				local readFileAt -- 1921
				readFileAt = function(targetPath) -- 1921
					if Content:exist(targetPath) then -- 1922
						local content = Content:load(targetPath) -- 1923
						if content then -- 1923
							return { -- 1924
								content = content, -- 1924
								success = true, -- 1924
								fullPath = Content:getFullPath(targetPath) -- 1924
							} -- 1924
						end -- 1923
					end -- 1922
					return nil -- 1921
				end -- 1921
				local readFile -- 1925
				readFile = function(fallbackPaths) -- 1925
					for _index_0 = 1, #exts do -- 1926
						local ext = exts[_index_0] -- 1926
						local targetPath = path .. ext -- 1927
						if not Content:isAbsolutePath(targetPath) then -- 1928
							for _index_1 = 1, #fallbackPaths do -- 1929
								local fallback = fallbackPaths[_index_1] -- 1929
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1930
								if fallbackResult then -- 1930
									return fallbackResult -- 1931
								end -- 1930
							end -- 1929
						end -- 1928
						local fileResult = readFileAt(targetPath) -- 1932
						if fileResult then -- 1932
							return fileResult -- 1933
						end -- 1932
					end -- 1926
					return nil -- 1925
				end -- 1925
				local fallbackPaths = { } -- 1934
				local fallbackCandidates = { } -- 1935
				do -- 1936
					local projectRoot = req.params.projectRoot -- 1936
					if projectRoot then -- 1936
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1937
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1938
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1939
						end -- 1937
					end -- 1936
				end -- 1936
				do -- 1940
					local projFile = req.params.projFile -- 1940
					if projFile then -- 1940
						local projDir = getProjectDirFromFile(projFile) -- 1941
						if projDir then -- 1941
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1942
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1943
						else -- 1945
							projDir = Path:getPath(projFile) -- 1945
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1946
						end -- 1941
					end -- 1940
				end -- 1940
				for _index_0 = 1, #fallbackCandidates do -- 1947
					local dir = fallbackCandidates[_index_0] -- 1947
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1948
						local exists = false -- 1949
						for _index_1 = 1, #fallbackPaths do -- 1950
							local fallback = fallbackPaths[_index_1] -- 1950
							if fallback == dir then -- 1951
								exists = true -- 1952
								break -- 1953
							end -- 1951
						end -- 1950
						if not exists then -- 1954
							fallbackPaths[#fallbackPaths + 1] = dir -- 1954
						end -- 1954
					end -- 1948
				end -- 1947
				local readResult = readFile(fallbackPaths) -- 1955
				if readResult then -- 1955
					return readResult -- 1956
				end -- 1955
			end -- 1915
		end -- 1915
	end -- 1915
	return { -- 1914
		success = false -- 1914
	} -- 1914
end) -- 1914
local addGeneratedSourceHeader -- 1958
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 1958
	if preserveTIC80 == nil then -- 1958
		preserveTIC80 = false -- 1958
	end -- 1958
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 1959
	if preserveTIC80 then -- 1960
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 1961
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 1962
		end -- 1961
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 1963
	end -- 1960
	return tostring(header) .. "\n" .. tostring(codes) -- 1964
end -- 1958
local compileFileAsync -- 1966
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1966
	if projectRoot == nil then -- 1966
		projectRoot = nil -- 1966
	end -- 1966
	local file = inputFile -- 1967
	local searchPath -- 1968
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1968
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1969
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1973
	elseif not Content:isAbsolutePath(inputFile) then -- 1974
		searchPath = "" -- 1975
	else -- 1976
		local dir = getProjectDirFromFile(inputFile) -- 1976
		if dir then -- 1976
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1977
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1981
		else -- 1983
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1983
			searchPath = "" -- 1986
		end -- 1976
	end -- 1968
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1987
	local yueext = yue.options.extension -- 1988
	local resultCodes = nil -- 1989
	local resultError = nil -- 1990
	do -- 1991
		local _exp_0 = Path:getExt(inputFile) -- 1991
		if yueext == _exp_0 then -- 1991
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1992
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1993
				if not codes then -- 1994
					resultError = err -- 1995
					return -- 1996
				end -- 1994
				local extraGlobal -- 1997
				if isTIC80 then -- 1997
					extraGlobal = tic80APIs -- 1997
				else -- 1997
					extraGlobal = nil -- 1997
				end -- 1997
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1998
				if not success then -- 1999
					resultError = message -- 2000
					return -- 2001
				end -- 1999
				if codes == "" then -- 2002
					resultCodes = "" -- 2003
					return nil -- 2004
				end -- 2002
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 2005
				return resultCodes -- 2006
			end, function(success) -- 1993
				if not success then -- 2007
					Content:remove(outputFile) -- 2008
					if resultCodes == nil then -- 2009
						resultCodes = false -- 2010
					end -- 2009
				end -- 2007
			end) -- 1993
		elseif "tl" == _exp_0 then -- 2011
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 2012
			if isTIC80 then -- 2013
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2014
			end -- 2013
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2015
			if codes then -- 2015
				if isTIC80 then -- 2016
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2017
				end -- 2016
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2018
				Content:saveAsync(outputFile, resultCodes) -- 2019
			else -- 2021
				Content:remove(outputFile) -- 2021
				resultCodes = false -- 2022
				resultError = err -- 2023
			end -- 2015
		elseif "xml" == _exp_0 then -- 2024
			local codes, err = xml.tolua(sourceCodes) -- 2025
			if codes then -- 2025
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2026
				Content:saveAsync(outputFile, resultCodes) -- 2027
			else -- 2029
				Content:remove(outputFile) -- 2029
				resultCodes = false -- 2030
				resultError = err -- 2031
			end -- 2025
		end -- 1991
	end -- 1991
	wait(function() -- 2032
		return resultCodes ~= nil -- 2032
	end) -- 2032
	if resultCodes then -- 2033
		return resultCodes -- 2034
	else -- 2036
		return nil, resultError -- 2036
	end -- 2033
	return nil -- 1966
end -- 1966
HttpServer:postSchedule("/write", function(req) -- 2038
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2039
	local buildSucceeded = false -- 2040
	local _ <close> = setmetatable({ }, { -- 2041
		__close = function() -- 2041
			return finishUpdate(buildSucceeded) -- 2041
		end -- 2041
	}) -- 2041
	do -- 2042
		local _type_0 = type(req) -- 2042
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2042
		if _tab_0 then -- 2042
			local path -- 2042
			do -- 2042
				local _obj_0 = req.body -- 2042
				local _type_1 = type(_obj_0) -- 2042
				if "table" == _type_1 or "userdata" == _type_1 then -- 2042
					path = _obj_0.path -- 2042
				end -- 2042
			end -- 2042
			local content -- 2042
			do -- 2042
				local _obj_0 = req.body -- 2042
				local _type_1 = type(_obj_0) -- 2042
				if "table" == _type_1 or "userdata" == _type_1 then -- 2042
					content = _obj_0.content -- 2042
				end -- 2042
			end -- 2042
			if path ~= nil and content ~= nil then -- 2042
				if Content:saveAsync(path, content) then -- 2043
					do -- 2044
						local _exp_0 = Path:getExt(path) -- 2044
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2044
							if '' == Path:getExt(Path:getName(path)) then -- 2045
								local resultCodes = compileFileAsync(path, content) -- 2046
								buildSucceeded = resultCodes ~= nil -- 2047
								return { -- 2048
									success = true, -- 2048
									resultCodes = resultCodes -- 2048
								} -- 2048
							end -- 2045
						end -- 2044
					end -- 2044
					buildSucceeded = true -- 2049
					return { -- 2050
						success = true -- 2050
					} -- 2050
				end -- 2043
			end -- 2042
		end -- 2042
	end -- 2042
	return { -- 2038
		success = false -- 2038
	} -- 2038
end) -- 2038
local getWaProjectDirFromFile = nil -- 2052
HttpServer:postSchedule("/build", function(req) -- 2054
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2055
	local buildSucceeded = false -- 2056
	local _ <close> = setmetatable({ }, { -- 2057
		__close = function() -- 2057
			return finishUpdate(buildSucceeded) -- 2057
		end -- 2057
	}) -- 2057
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
				local projectRoot = req.body.projectRoot -- 2059
				if Content:isdir(path) then -- 2060
					local projDir = getWaProjectDirFromFile(path) -- 2061
					if projDir then -- 2061
						local message = Wasm:buildWaAsync(projDir) -- 2062
						if message == "" then -- 2063
							return { -- 2064
								success = true -- 2064
							} -- 2064
						else -- 2066
							return { -- 2066
								success = false, -- 2066
								message = message -- 2066
							} -- 2066
						end -- 2063
					end -- 2061
				end -- 2060
				local _exp_0 = Path:getExt(path) -- 2067
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2068
					if '' == Path:getExt(Path:getName(path)) then -- 2069
						local content = Content:loadAsync(path) -- 2070
						if content then -- 2070
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2071
							if resultCodes then -- 2071
								buildSucceeded = true -- 2072
								return { -- 2073
									success = true, -- 2073
									resultCodes = resultCodes -- 2073
								} -- 2073
							end -- 2071
						end -- 2070
					end -- 2069
				elseif "wa" == _exp_0 then -- 2074
					local projDir = getWaProjectDirFromFile(path) -- 2075
					if projDir then -- 2075
						local message = Wasm:buildWaAsync(projDir) -- 2076
						if message == "" then -- 2077
							return { -- 2078
								success = true -- 2078
							} -- 2078
						else -- 2080
							return { -- 2080
								success = false, -- 2080
								message = message -- 2080
							} -- 2080
						end -- 2077
					else -- 2082
						return { -- 2082
							success = false, -- 2082
							message = 'Wa file needs a project' -- 2082
						} -- 2082
					end -- 2075
				end -- 2067
			end -- 2058
		end -- 2058
	end -- 2058
	return { -- 2054
		success = false -- 2054
	} -- 2054
end) -- 2054
local extentionLevels = { -- 2085
	vs = 2, -- 2085
	bl = 2, -- 2086
	ts = 1, -- 2087
	tsx = 1, -- 2088
	tl = 1, -- 2089
	yue = 1, -- 2090
	xml = 1, -- 2091
	lua = 0 -- 2092
} -- 2084
local visitAssets -- 2094
visitAssets = function(path, workspace, builtin, recursive) -- 2094
	if recursive == nil then -- 2094
		recursive = true -- 2094
	end -- 2094
	local children = nil -- 2095
	local dirs = Content:getDirs(path) -- 2096
	for _index_0 = 1, #dirs do -- 2097
		local dir = dirs[_index_0] -- 2097
		if workspace then -- 2098
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 2099
				goto _continue_0 -- 2100
			end -- 2099
		elseif dir == ".git" then -- 2101
			goto _continue_0 -- 2102
		end -- 2098
		if not children then -- 2103
			children = { } -- 2103
		end -- 2103
		local dirPath = Path(path, dir) -- 2104
		if recursive then -- 2105
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2106
		else -- 2108
			children[#children + 1] = { -- 2109
				key = dirPath, -- 2109
				dir = true, -- 2110
				title = dir, -- 2111
				builtin = builtin, -- 2112
				isLeaf = false -- 2113
			} -- 2108
		end -- 2105
		::_continue_0:: -- 2098
	end -- 2097
	local files = Content:getFiles(path) -- 2115
	local names = { } -- 2116
	for _index_0 = 1, #files do -- 2117
		local file = files[_index_0] -- 2117
		if (".DS_Store" == file) then -- 2118
			goto _continue_1 -- 2119
		end -- 2118
		local name = Path:getName(file) -- 2120
		local ext = names[name] -- 2121
		if ext then -- 2121
			local lv1 -- 2122
			do -- 2122
				local _exp_0 = extentionLevels[ext] -- 2122
				if _exp_0 ~= nil then -- 2122
					lv1 = _exp_0 -- 2122
				else -- 2122
					lv1 = -1 -- 2122
				end -- 2122
			end -- 2122
			ext = Path:getExt(file) -- 2123
			local lv2 -- 2124
			do -- 2124
				local _exp_0 = extentionLevels[ext] -- 2124
				if _exp_0 ~= nil then -- 2124
					lv2 = _exp_0 -- 2124
				else -- 2124
					lv2 = -1 -- 2124
				end -- 2124
			end -- 2124
			if lv2 > lv1 then -- 2125
				names[name] = ext -- 2126
			elseif lv2 == lv1 then -- 2127
				names[name .. '.' .. ext] = "" -- 2128
			end -- 2125
		else -- 2130
			ext = Path:getExt(file) -- 2130
			if not extentionLevels[ext] then -- 2131
				names[file] = "" -- 2132
			else -- 2134
				names[name] = ext -- 2134
			end -- 2131
		end -- 2121
		::_continue_1:: -- 2118
	end -- 2117
	do -- 2135
		local _accum_0 = { } -- 2135
		local _len_0 = 1 -- 2135
		for name, ext in pairs(names) do -- 2135
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2135
			_len_0 = _len_0 + 1 -- 2135
		end -- 2135
		files = _accum_0 -- 2135
	end -- 2135
	for _index_0 = 1, #files do -- 2136
		local file = files[_index_0] -- 2136
		if not children then -- 2137
			children = { } -- 2137
		end -- 2137
		children[#children + 1] = { -- 2139
			key = Path(path, file), -- 2139
			dir = false, -- 2140
			title = file, -- 2141
			builtin = builtin -- 2142
		} -- 2138
	end -- 2136
	if children then -- 2144
		table.sort(children, function(a, b) -- 2145
			if a.dir == b.dir then -- 2146
				return a.title < b.title -- 2147
			else -- 2149
				return a.dir -- 2149
			end -- 2146
		end) -- 2145
	end -- 2144
	return { -- 2151
		key = path, -- 2151
		dir = true, -- 2152
		title = Path:getFilename(path), -- 2153
		builtin = builtin, -- 2154
		isLeaf = not children, -- 2155
		children = children -- 2156
	} -- 2150
end -- 2094
HttpServer:post("/assets/children", function(req) -- 2159
	do -- 2160
		local _type_0 = type(req) -- 2160
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2160
		if _tab_0 then -- 2160
			local path -- 2160
			do -- 2160
				local _obj_0 = req.body -- 2160
				local _type_1 = type(_obj_0) -- 2160
				if "table" == _type_1 or "userdata" == _type_1 then -- 2160
					path = _obj_0.path -- 2160
				end -- 2160
			end -- 2160
			if path ~= nil then -- 2160
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2161
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2162
					return { -- 2162
						success = false -- 2162
					} -- 2162
				end -- 2162
				local node = visitAssets(path, workspace, builtin, false) -- 2163
				return { -- 2164
					success = true, -- 2164
					children = node.children or { } -- 2164
				} -- 2164
			end -- 2160
		end -- 2160
	end -- 2160
	return { -- 2159
		success = false -- 2159
	} -- 2159
end) -- 2159
HttpServer:post("/assets/files", function(req) -- 2166
	do -- 2167
		local _type_0 = type(req) -- 2167
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2167
		if _tab_0 then -- 2167
			local path -- 2167
			do -- 2167
				local _obj_0 = req.body -- 2167
				local _type_1 = type(_obj_0) -- 2167
				if "table" == _type_1 or "userdata" == _type_1 then -- 2167
					path = _obj_0.path -- 2167
				end -- 2167
			end -- 2167
			if path ~= nil then -- 2167
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2168
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2169
				if not (workspace or builtin) then -- 2170
					return { -- 2170
						success = false -- 2170
					} -- 2170
				end -- 2170
				if not (Content:exist(path) and Content:isdir(path)) then -- 2171
					return { -- 2171
						success = false -- 2171
					} -- 2171
				end -- 2171
				local globs = { -- 2172
					"**", -- 2172
					"!**/.DS_Store" -- 2172
				} -- 2172
				if workspace then -- 2173
					globs = { -- 2175
						"**", -- 2175
						"!**/.DS_Store", -- 2175
						"!**/.upload/**", -- 2176
						"!**/.download/**", -- 2176
						"!**/.www/**", -- 2177
						"!**/.build/**", -- 2177
						"!**/.git/**", -- 2178
						"!**/.cache/**", -- 2178
						"!**/node_modules/**" -- 2179
					} -- 2174
				end -- 2173
				local files -- 2181
				do -- 2181
					local _accum_0 = { } -- 2181
					local _len_0 = 1 -- 2181
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2181
					for _index_0 = 1, #_list_0 do -- 2181
						local file = _list_0[_index_0] -- 2181
						_accum_0[_len_0] = Path(path, file) -- 2181
						_len_0 = _len_0 + 1 -- 2181
					end -- 2181
					files = _accum_0 -- 2181
				end -- 2181
				return { -- 2182
					success = true, -- 2182
					files = files -- 2182
				} -- 2182
			end -- 2167
		end -- 2167
	end -- 2167
	return { -- 2166
		success = false -- 2166
	} -- 2166
end) -- 2166
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2223
	local _tab_0 = { -- 2223
		{ -- 2224
			key = Path(Content.assetPath), -- 2224
			dir = true, -- 2225
			builtin = true, -- 2226
			title = zh and "内置资源" or "Built-in", -- 2227
			children = builtinChildren -- 2228
		} -- 2223
	} -- 2230
	local _obj_0 = workspace.children or { } -- 2230
	local _idx_0 = #_tab_0 + 1 -- 2230
	for _index_0 = 1, #_obj_0 do -- 2230
		local _value_0 = _obj_0[_index_0] -- 2230
		_tab_0[_idx_0] = _value_0 -- 2230
		_idx_0 = _idx_0 + 1 -- 2230
	end -- 2230
	return _tab_0 -- 2223
end -- 2223
HttpServer:post("/assets", function() -- 2184
	local Entry = require("Script.Dev.Entry") -- 2185
	local engineDev = Entry.getEngineDev() -- 2186
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2187
	local zh = (App.locale:match("^zh") ~= nil) -- 2188
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2189
	readme.title = zh and "说明文档" or "Readme" -- 2190
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2191
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2192
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2193
	tools.title = zh and "开发工具" or "Tools" -- 2194
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2195
	font.title = zh and "字体" or "Font" -- 2196
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2197
	lib.title = zh and "程序库" or "Lib" -- 2198
	if engineDev then -- 2199
		local _list_0 = lib.children -- 2200
		for _index_0 = 1, #_list_0 do -- 2200
			local child = _list_0[_index_0] -- 2200
			if not (child.title == "Dora") then -- 2201
				goto _continue_0 -- 2201
			end -- 2201
			local title = zh and "zh-Hans" or "en" -- 2202
			do -- 2203
				local _accum_0 = { } -- 2203
				local _len_0 = 1 -- 2203
				local _list_1 = child.children -- 2203
				for _index_1 = 1, #_list_1 do -- 2203
					local c = _list_1[_index_1] -- 2203
					if c.title ~= title then -- 2203
						_accum_0[_len_0] = c -- 2203
						_len_0 = _len_0 + 1 -- 2203
					end -- 2203
				end -- 2203
				child.children = _accum_0 -- 2203
			end -- 2203
			break -- 2204
			::_continue_0:: -- 2201
		end -- 2200
	else -- 2206
		local _accum_0 = { } -- 2206
		local _len_0 = 1 -- 2206
		local _list_0 = lib.children -- 2206
		for _index_0 = 1, #_list_0 do -- 2206
			local child = _list_0[_index_0] -- 2206
			if child.title ~= "Dora" then -- 2206
				_accum_0[_len_0] = child -- 2206
				_len_0 = _len_0 + 1 -- 2206
			end -- 2206
		end -- 2206
		lib.children = _accum_0 -- 2206
	end -- 2199
	local builtinChildren = { -- 2207
		readme, -- 2207
		apiDoc, -- 2207
		tools, -- 2207
		font, -- 2207
		lib -- 2207
	} -- 2207
	if engineDev then -- 2208
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2209
		do -- 2210
			local _obj_0 = dev.children -- 2210
			_obj_0[#_obj_0 + 1] = { -- 2211
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2211
				dir = false, -- 2212
				builtin = true, -- 2213
				title = "init.yue" -- 2214
			} -- 2210
		end -- 2210
		builtinChildren[#builtinChildren + 1] = dev -- 2216
	end -- 2208
	return { -- 2218
		key = Content.writablePath, -- 2218
		dir = true, -- 2219
		root = true, -- 2220
		title = "Assets", -- 2221
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2222
	} -- 2217
end) -- 2184
HttpServer:post("/entry/list", function(req) -- 2234
	local Entry = require("Script.Dev.Entry") -- 2235
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2236
	res.success = true -- 2237
	return res -- 2238
end) -- 2234
HttpServer:post("/run/status", function() -- 2240
	local Entry = require("Script.Dev.Entry") -- 2241
	return Entry.getCurrentEntryStatus() -- 2242
end) -- 2240
HttpServer:postSchedule("/run", function(req) -- 2244
	do -- 2245
		local _type_0 = type(req) -- 2245
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2245
		if _tab_0 then -- 2245
			local file -- 2245
			do -- 2245
				local _obj_0 = req.body -- 2245
				local _type_1 = type(_obj_0) -- 2245
				if "table" == _type_1 or "userdata" == _type_1 then -- 2245
					file = _obj_0.file -- 2245
				end -- 2245
			end -- 2245
			local asProj -- 2245
			do -- 2245
				local _obj_0 = req.body -- 2245
				local _type_1 = type(_obj_0) -- 2245
				if "table" == _type_1 or "userdata" == _type_1 then -- 2245
					asProj = _obj_0.asProj -- 2245
				end -- 2245
			end -- 2245
			if file ~= nil and asProj ~= nil then -- 2245
				if not Content:isAbsolutePath(file) then -- 2246
					local devFile = Path(Content.writablePath, file) -- 2247
					if Content:exist(devFile) then -- 2248
						file = devFile -- 2248
					end -- 2248
				end -- 2246
				local Entry = require("Script.Dev.Entry") -- 2249
				local workDir -- 2250
				if asProj then -- 2251
					local projectRoot = req.body.projectRoot -- 2252
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2253
						workDir = projectRoot -- 2254
					else -- 2256
						workDir = getProjectDirFromFile(file) -- 2256
					end -- 2253
					if workDir then -- 2257
						Entry.allClear() -- 2258
						local target = Path(workDir, "init") -- 2259
						local success, err = Entry.enterEntryAsync({ -- 2260
							entryName = "Project", -- 2260
							fileName = target, -- 2260
							workDir = workDir, -- 2260
							projectRoot = workDir, -- 2260
							runKind = "project" -- 2260
						}) -- 2260
						target = Path:getName(Path:getPath(target)) -- 2261
						return { -- 2262
							success = success, -- 2262
							target = target, -- 2262
							err = err -- 2262
						} -- 2262
					end -- 2257
				else -- 2264
					workDir = getProjectDirFromFile(file) -- 2264
					if not workDir and Path:getExt(file) == "wasm" then -- 2265
						local parent = Path:getPath(file) -- 2266
						if Content:exist(Path(parent, "wa.mod")) then -- 2267
							workDir = parent -- 2268
						end -- 2267
					end -- 2265
				end -- 2251
				Entry.allClear() -- 2269
				file = Path:replaceExt(file, "") -- 2270
				local entry = { -- 2272
					entryName = Path:getName(file), -- 2272
					fileName = file, -- 2273
					runKind = "file" -- 2274
				} -- 2271
				if workDir then -- 2275
					entry.workDir = workDir -- 2276
					entry.projectRoot = workDir -- 2277
				end -- 2275
				local success, err = Entry.enterEntryAsync(entry) -- 2278
				return { -- 2279
					success = success, -- 2279
					err = err -- 2279
				} -- 2279
			end -- 2245
		end -- 2245
	end -- 2245
	return { -- 2244
		success = false -- 2244
	} -- 2244
end) -- 2244
local _anon_func_7 = function(result) -- 2321
	if result.success then -- 2321
		return nil -- 2321
	else -- 2321
		return "PREVIEW_FAILED" -- 2321
	end -- 2321
end -- 2321
HttpServer:postSchedule("/agent/preview", function(req) -- 2281
	local releaseAgent = AgentHost.acquire() -- 2282
	local _ <close> = setmetatable({ }, { -- 2283
		__close = function() -- 2283
			return releaseAgent() -- 2283
		end -- 2283
	}) -- 2283
	do -- 2284
		local _type_0 = type(req) -- 2284
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2284
		if _tab_0 then -- 2284
			local projectRoot -- 2284
			do -- 2284
				local _obj_0 = req.body -- 2284
				local _type_1 = type(_obj_0) -- 2284
				if "table" == _type_1 or "userdata" == _type_1 then -- 2284
					projectRoot = _obj_0.projectRoot -- 2284
				end -- 2284
			end -- 2284
			if projectRoot ~= nil then -- 2284
				if not getProjectSourceRoot(projectRoot) then -- 2285
					return { -- 2285
						success = false, -- 2285
						code = "INVALID_PROJECT", -- 2285
						message = "projectRoot must be an existing absolute directory" -- 2285
					} -- 2285
				end -- 2285
				local entryFile = req.body.entry or "init.lua" -- 2286
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2287
					return { -- 2287
						success = false, -- 2287
						code = "INVALID_ENTRY", -- 2287
						message = "entry must be a non-empty project-relative path" -- 2287
					} -- 2287
				end -- 2287
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2288
					0.5 -- 2288
				} -- 2288
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2289
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2290
					return { -- 2290
						success = false, -- 2290
						code = "INVALID_QUEUE_TIMEOUT", -- 2290
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2290
					} -- 2290
				end -- 2290
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2291
				local AgentOperation = require("Agent.Tool.Operation") -- 2292
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2293
				local requestId = AgentOperation.createOperationId() -- 2294
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2295
				if not enqueued.success then -- 2296
					return { -- 2296
						success = false, -- 2296
						code = "ENTRY_QUEUE_REJECTED", -- 2296
						message = enqueued.message -- 2296
					} -- 2296
				end -- 2296
				local queuedAt = App.runningTime -- 2297
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2298
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2299
						local state = agentEntryRunQueue:get(requestId) -- 2300
						agentEntryRunQueue:cancel(requestId) -- 2301
						return { -- 2303
							success = false, -- 2303
							code = "ENTRY_QUEUE_TIMEOUT", -- 2304
							message = "timed out waiting for the Dora entry runtime", -- 2305
							requestId = requestId, -- 2306
							queuePosition = state.position -- 2307
						} -- 2302
					end -- 2299
					sleep() -- 2308
				end -- 2298
				local queueWaitSeconds = App.runningTime - queuedAt -- 2309
				local _ <close> = setmetatable({ }, { -- 2310
					__close = function() -- 2310
						return agentEntryRunQueue:release(requestId) -- 2310
					end -- 2310
				}) -- 2310
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2311
				local Entry = require("Script.Dev.Entry") -- 2312
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2314
					workDir = projectRoot, -- 2314
					operationId = requestId, -- 2315
					print = function() end -- 2316
				}, Entry) -- 2313
				local result = preview({ -- 2318
					entry = entryFile, -- 2318
					captureAtSeconds = captureAtSeconds -- 2318
				}) -- 2318
				return { -- 2320
					success = result.success, -- 2320
					code = _anon_func_7(result), -- 2321
					message = result.message, -- 2322
					requestId = requestId, -- 2323
					queueWaitSeconds = queueWaitSeconds, -- 2324
					interruptedUserRun = result.interruptedUserRun, -- 2325
					files = result.files, -- 2326
					frames = result.frames -- 2327
				} -- 2319
			end -- 2284
		end -- 2284
	end -- 2284
	return { -- 2281
		success = false, -- 2281
		message = "invalid call" -- 2281
	} -- 2281
end) -- 2281
HttpServer:postSchedule("/agent/command", function(req) -- 2329
	local releaseAgent = AgentHost.acquire() -- 2330
	local _ <close> = setmetatable({ }, { -- 2331
		__close = function() -- 2331
			return releaseAgent() -- 2331
		end -- 2331
	}) -- 2331
	do -- 2332
		local _type_0 = type(req) -- 2332
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2332
		if _tab_0 then -- 2332
			local body = req.body -- 2332
			if body ~= nil then -- 2332
				local projectRoot = body.projectRoot -- 2333
				if not getProjectSourceRoot(projectRoot) then -- 2334
					return { -- 2334
						success = false, -- 2334
						code = "INVALID_PROJECT", -- 2334
						message = "projectRoot must be an existing absolute directory" -- 2334
					} -- 2334
				end -- 2334
				local AgentValidation = require("Agent.Tool.Validation") -- 2335
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2336
				if not validated.success then -- 2337
					return { -- 2337
						success = false, -- 2337
						code = "INVALID_COMMAND", -- 2337
						message = validated.message -- 2337
					} -- 2337
				end -- 2337
				local input = validated.value -- 2338
				local AgentCommand = require("Agent.Tool.Command") -- 2339
				local result = nil -- 2340
				local failure = nil -- 2341
				local promise = AgentCommand.executeCommand({ -- 2343
					workDir = projectRoot, -- 2343
					mode = input.mode, -- 2344
					code = input.code, -- 2345
					command = input.command, -- 2346
					cwd = input.cwd, -- 2347
					timeoutSeconds = input.timeoutSeconds -- 2348
				}) -- 2342
				promise:addCallbacks((function(_, value) -- 2349
					result = value -- 2349
				end), (function(_, err) -- 2349
					failure = tostring(err) -- 2349
				end)) -- 2349
				wait(function() -- 2350
					return result ~= nil or failure ~= nil -- 2350
				end) -- 2350
				if failure then -- 2351
					return { -- 2351
						success = false, -- 2351
						code = "COMMAND_BRIDGE_FAILED", -- 2351
						message = failure -- 2351
					} -- 2351
				end -- 2351
				if not result.success then -- 2352
					result.code = "COMMAND_FAILED" -- 2353
				end -- 2352
				return result -- 2354
			end -- 2332
		end -- 2332
	end -- 2332
	return { -- 2329
		success = false, -- 2329
		code = "INVALID_COMMAND", -- 2329
		message = "invalid call" -- 2329
	} -- 2329
end) -- 2329
HttpServer:postSchedule("/stop", function() -- 2356
	local Entry = require("Script.Dev.Entry") -- 2357
	return { -- 2358
		success = Entry.stop() -- 2358
	} -- 2358
end) -- 2356
local minifyAsync -- 2360
minifyAsync = function(sourcePath, minifyPath) -- 2360
	if not Content:exist(sourcePath) then -- 2361
		return -- 2361
	end -- 2361
	local Entry = require("Script.Dev.Entry") -- 2362
	local errors = { } -- 2363
	local files = Entry.getAllFiles(sourcePath, { -- 2364
		"lua" -- 2364
	}, true) -- 2364
	do -- 2365
		local _accum_0 = { } -- 2365
		local _len_0 = 1 -- 2365
		for _index_0 = 1, #files do -- 2365
			local file = files[_index_0] -- 2365
			if file:sub(1, 1) ~= '.' then -- 2365
				_accum_0[_len_0] = file -- 2365
				_len_0 = _len_0 + 1 -- 2365
			end -- 2365
		end -- 2365
		files = _accum_0 -- 2365
	end -- 2365
	local paths -- 2366
	do -- 2366
		local _tbl_0 = { } -- 2366
		for _index_0 = 1, #files do -- 2366
			local file = files[_index_0] -- 2366
			_tbl_0[Path:getPath(file)] = true -- 2366
		end -- 2366
		paths = _tbl_0 -- 2366
	end -- 2366
	for path in pairs(paths) do -- 2367
		Content:mkdir(Path(minifyPath, path)) -- 2367
	end -- 2367
	local _ <close> = setmetatable({ }, { -- 2368
		__close = function() -- 2368
			package.loaded["luaminify.FormatMini"] = nil -- 2369
			package.loaded["luaminify.ParseLua"] = nil -- 2370
			package.loaded["luaminify.Scope"] = nil -- 2371
			package.loaded["luaminify.Util"] = nil -- 2372
		end -- 2368
	}) -- 2368
	local FormatMini -- 2373
	do -- 2373
		local _obj_0 = require("luaminify") -- 2373
		FormatMini = _obj_0.FormatMini -- 2373
	end -- 2373
	local fileCount = #files -- 2374
	local count = 0 -- 2375
	for _index_0 = 1, #files do -- 2376
		local file = files[_index_0] -- 2376
		thread(function() -- 2377
			local _ <close> = setmetatable({ }, { -- 2378
				__close = function() -- 2378
					count = count + 1 -- 2378
				end -- 2378
			}) -- 2378
			local input = Path(sourcePath, file) -- 2379
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2380
			if Content:exist(input) then -- 2381
				local sourceCodes = Content:loadAsync(input) -- 2382
				local res, err = FormatMini(sourceCodes) -- 2383
				if res then -- 2384
					Content:saveAsync(output, res) -- 2385
					return print("Minify " .. tostring(file)) -- 2386
				else -- 2388
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2388
				end -- 2384
			else -- 2390
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2390
			end -- 2381
		end) -- 2377
		sleep() -- 2391
	end -- 2376
	wait(function() -- 2392
		return count == fileCount -- 2392
	end) -- 2392
	if #errors > 0 then -- 2393
		print(table.concat(errors, '\n')) -- 2394
	end -- 2393
	print("Obfuscation done.") -- 2395
	return files -- 2396
end -- 2360
local zipping = false -- 2398
HttpServer:postSchedule("/zip", function(req) -- 2400
	do -- 2401
		local _type_0 = type(req) -- 2401
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2401
		if _tab_0 then -- 2401
			local path -- 2401
			do -- 2401
				local _obj_0 = req.body -- 2401
				local _type_1 = type(_obj_0) -- 2401
				if "table" == _type_1 or "userdata" == _type_1 then -- 2401
					path = _obj_0.path -- 2401
				end -- 2401
			end -- 2401
			local zipFile -- 2401
			do -- 2401
				local _obj_0 = req.body -- 2401
				local _type_1 = type(_obj_0) -- 2401
				if "table" == _type_1 or "userdata" == _type_1 then -- 2401
					zipFile = _obj_0.zipFile -- 2401
				end -- 2401
			end -- 2401
			local obfuscated -- 2401
			do -- 2401
				local _obj_0 = req.body -- 2401
				local _type_1 = type(_obj_0) -- 2401
				if "table" == _type_1 or "userdata" == _type_1 then -- 2401
					obfuscated = _obj_0.obfuscated -- 2401
				end -- 2401
			end -- 2401
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2401
				if zipping then -- 2402
					goto failed -- 2402
				end -- 2402
				zipping = true -- 2403
				local _ <close> = setmetatable({ }, { -- 2404
					__close = function() -- 2404
						zipping = false -- 2404
					end -- 2404
				}) -- 2404
				if not Content:exist(path) then -- 2405
					goto failed -- 2405
				end -- 2405
				Content:mkdir(Path:getPath(zipFile)) -- 2406
				if obfuscated then -- 2407
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2408
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2409
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2410
					Content:remove(scriptPath) -- 2411
					Content:remove(obfuscatedPath) -- 2412
					Content:remove(tempPath) -- 2413
					Content:mkdir(scriptPath) -- 2414
					Content:mkdir(obfuscatedPath) -- 2415
					Content:mkdir(tempPath) -- 2416
					if not Content:copyAsync(path, tempPath) then -- 2417
						goto failed -- 2417
					end -- 2417
					local Entry = require("Script.Dev.Entry") -- 2418
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2419
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2420
						"tl", -- 2420
						"yue", -- 2420
						"lua", -- 2420
						"ts", -- 2420
						"tsx", -- 2420
						"vs", -- 2420
						"bl", -- 2420
						"xml", -- 2420
						"wa", -- 2420
						"mod" -- 2420
					}, true) -- 2420
					for _index_0 = 1, #scriptFiles do -- 2421
						local file = scriptFiles[_index_0] -- 2421
						Content:remove(Path(tempPath, file)) -- 2422
					end -- 2421
					for _index_0 = 1, #luaFiles do -- 2423
						local file = luaFiles[_index_0] -- 2423
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2424
					end -- 2423
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2425
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2426
					end) then -- 2425
						goto failed -- 2425
					end -- 2425
					return { -- 2427
						success = true -- 2427
					} -- 2427
				else -- 2429
					return { -- 2429
						success = Content:zipAsync(path, zipFile, function(file) -- 2429
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2430
						end) -- 2429
					} -- 2429
				end -- 2407
			end -- 2401
		end -- 2401
	end -- 2401
	::failed:: -- 2431
	return { -- 2400
		success = false -- 2400
	} -- 2400
end) -- 2400
HttpServer:postSchedule("/unzip", function(req) -- 2433
	do -- 2434
		local _type_0 = type(req) -- 2434
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2434
		if _tab_0 then -- 2434
			local zipFile -- 2434
			do -- 2434
				local _obj_0 = req.body -- 2434
				local _type_1 = type(_obj_0) -- 2434
				if "table" == _type_1 or "userdata" == _type_1 then -- 2434
					zipFile = _obj_0.zipFile -- 2434
				end -- 2434
			end -- 2434
			local path -- 2434
			do -- 2434
				local _obj_0 = req.body -- 2434
				local _type_1 = type(_obj_0) -- 2434
				if "table" == _type_1 or "userdata" == _type_1 then -- 2434
					path = _obj_0.path -- 2434
				end -- 2434
			end -- 2434
			if zipFile ~= nil and path ~= nil then -- 2434
				return { -- 2435
					success = Content:unzipAsync(zipFile, path, function(file) -- 2435
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2436
					end) -- 2435
				} -- 2435
			end -- 2434
		end -- 2434
	end -- 2434
	return { -- 2433
		success = false -- 2433
	} -- 2433
end) -- 2433
HttpServer:post("/editing-info", function(req) -- 2438
	local Entry = require("Script.Dev.Entry") -- 2439
	local config = Entry.getConfig() -- 2440
	local _type_0 = type(req) -- 2441
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2441
	local _match_0 = false -- 2441
	if _tab_0 then -- 2441
		local editingInfo -- 2441
		do -- 2441
			local _obj_0 = req.body -- 2441
			local _type_1 = type(_obj_0) -- 2441
			if "table" == _type_1 or "userdata" == _type_1 then -- 2441
				editingInfo = _obj_0.editingInfo -- 2441
			end -- 2441
		end -- 2441
		if editingInfo ~= nil then -- 2441
			_match_0 = true -- 2441
			config.editingInfo = editingInfo -- 2442
			return { -- 2443
				success = true -- 2443
			} -- 2443
		end -- 2441
	end -- 2441
	if not _match_0 then -- 2441
		if not (config.editingInfo ~= nil) then -- 2445
			local folder -- 2446
			if App.locale:match('^zh') then -- 2446
				folder = 'zh-Hans' -- 2446
			else -- 2446
				folder = 'en' -- 2446
			end -- 2446
			config.editingInfo = json.encode({ -- 2448
				index = 0, -- 2448
				files = { -- 2450
					{ -- 2451
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2451
						title = "welcome.md" -- 2452
					} -- 2450
				} -- 2449
			}) -- 2447
		end -- 2445
		return { -- 2456
			success = true, -- 2456
			editingInfo = config.editingInfo -- 2456
		} -- 2456
	end -- 2441
end) -- 2438
HttpServer:post("/command", function(req) -- 2458
	do -- 2459
		local _type_0 = type(req) -- 2459
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2459
		if _tab_0 then -- 2459
			local code -- 2459
			do -- 2459
				local _obj_0 = req.body -- 2459
				local _type_1 = type(_obj_0) -- 2459
				if "table" == _type_1 or "userdata" == _type_1 then -- 2459
					code = _obj_0.code -- 2459
				end -- 2459
			end -- 2459
			local log -- 2459
			do -- 2459
				local _obj_0 = req.body -- 2459
				local _type_1 = type(_obj_0) -- 2459
				if "table" == _type_1 or "userdata" == _type_1 then -- 2459
					log = _obj_0.log -- 2459
				end -- 2459
			end -- 2459
			if code ~= nil and log ~= nil then -- 2459
				emit("AppCommand", code, log) -- 2460
				return { -- 2461
					success = true -- 2461
				} -- 2461
			end -- 2459
		end -- 2459
	end -- 2459
	return { -- 2458
		success = false -- 2458
	} -- 2458
end) -- 2458
HttpServer:post("/log/save", function() -- 2463
	local folder = ".download" -- 2464
	local fullLogFile = "dora_full_logs.txt" -- 2465
	local fullFolder = Path(Content.writablePath, folder) -- 2466
	Content:mkdir(fullFolder) -- 2467
	local logPath = Path(fullFolder, fullLogFile) -- 2468
	if App:saveLog(logPath) then -- 2469
		return { -- 2470
			success = true, -- 2470
			path = Path(folder, fullLogFile) -- 2470
		} -- 2470
	end -- 2469
	return { -- 2463
		success = false -- 2463
	} -- 2463
end) -- 2463
local tailLines -- 2472
tailLines = function(text, count) -- 2472
	local lines = { } -- 2473
	text = text:gsub("\r\n", "\n") -- 2474
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2475
		lines[#lines + 1] = line -- 2476
	end -- 2475
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2477
		table.remove(lines) -- 2478
	end -- 2477
	local start = math.max(1, #lines - count + 1) -- 2479
	local out = { } -- 2480
	for i = start, #lines do -- 2481
		out[#out + 1] = lines[i] -- 2482
	end -- 2481
	return table.concat(out, "\n") -- 2483
end -- 2472
HttpServer:post("/log", function(req) -- 2485
	local count = 100 -- 2486
	if req and req.body and req.body.count ~= nil then -- 2487
		count = req.body.count -- 2488
	end -- 2487
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2489
		return { -- 2490
			success = false, -- 2490
			message = "count must be a positive integer" -- 2490
		} -- 2490
	end -- 2489
	local folder = ".download" -- 2491
	local fullLogFile = "dora_full_logs.txt" -- 2492
	local fullFolder = Path(Content.writablePath, folder) -- 2493
	Content:mkdir(fullFolder) -- 2494
	local logPath = Path(fullFolder, fullLogFile) -- 2495
	if App:saveLog(logPath) then -- 2496
		local text = Content:load(logPath) -- 2497
		if text then -- 2498
			return { -- 2499
				success = true, -- 2499
				log = tailLines(text, count) -- 2499
			} -- 2499
		else -- 2501
			return { -- 2501
				success = false, -- 2501
				message = "failed to read log" -- 2501
			} -- 2501
		end -- 2498
	else -- 2503
		return { -- 2503
			success = false, -- 2503
			message = "failed to save log" -- 2503
		} -- 2503
	end -- 2496
	return { -- 2485
		success = false -- 2485
	} -- 2485
end) -- 2485
HttpServer:post("/yarn/check", function(req) -- 2505
	local yarncompile = require("yarncompile") -- 2506
	do -- 2507
		local _type_0 = type(req) -- 2507
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2507
		if _tab_0 then -- 2507
			local code -- 2507
			do -- 2507
				local _obj_0 = req.body -- 2507
				local _type_1 = type(_obj_0) -- 2507
				if "table" == _type_1 or "userdata" == _type_1 then -- 2507
					code = _obj_0.code -- 2507
				end -- 2507
			end -- 2507
			if code ~= nil then -- 2507
				local jsonObject = json.decode(code) -- 2508
				if jsonObject then -- 2508
					local errors = { } -- 2509
					local _list_0 = jsonObject.nodes -- 2510
					for _index_0 = 1, #_list_0 do -- 2510
						local node = _list_0[_index_0] -- 2510
						local title, body = node.title, node.body -- 2511
						local luaCode, err = yarncompile(body) -- 2512
						if not luaCode then -- 2512
							errors[#errors + 1] = title .. ":" .. err -- 2513
						end -- 2512
					end -- 2510
					return { -- 2514
						success = true, -- 2514
						syntaxError = table.concat(errors, "\n\n") -- 2514
					} -- 2514
				end -- 2508
			end -- 2507
		end -- 2507
	end -- 2507
	return { -- 2505
		success = false -- 2505
	} -- 2505
end) -- 2505
HttpServer:post("/yarn/check-file", function(req) -- 2516
	local yarncompile = require("yarncompile") -- 2517
	do -- 2518
		local _type_0 = type(req) -- 2518
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2518
		if _tab_0 then -- 2518
			local code -- 2518
			do -- 2518
				local _obj_0 = req.body -- 2518
				local _type_1 = type(_obj_0) -- 2518
				if "table" == _type_1 or "userdata" == _type_1 then -- 2518
					code = _obj_0.code -- 2518
				end -- 2518
			end -- 2518
			if code ~= nil then -- 2518
				local res, _, err = yarncompile(code, true) -- 2519
				if not res then -- 2519
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2520
					return { -- 2521
						success = false, -- 2521
						message = message, -- 2521
						line = line, -- 2521
						column = column, -- 2521
						node = node -- 2521
					} -- 2521
				end -- 2519
			end -- 2518
		end -- 2518
	end -- 2518
	return { -- 2516
		success = true -- 2516
	} -- 2516
end) -- 2516
getWaProjectDirFromFile = function(file) -- 2523
	local current -- 2524
	if Content:isdir(file) then -- 2524
		current = file -- 2524
	else -- 2524
		current = Path:getPath(file) -- 2524
	end -- 2524
	if current == "" then -- 2525
		return nil -- 2525
	end -- 2525
	repeat -- 2526
		local modPath = Path(current, "wa.mod") -- 2527
		if Content:exist(modPath) then -- 2528
			return current, modPath -- 2529
		end -- 2528
		local parent = Path:getPath(current) -- 2530
		if parent == "" or parent == current then -- 2531
			break -- 2531
		end -- 2531
		current = parent -- 2532
	until false -- 2526
	return nil -- 2534
end -- 2523
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2536
	do -- 2537
		local _type_0 = type(req) -- 2537
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2537
		if _tab_0 then -- 2537
			local path -- 2537
			do -- 2537
				local _obj_0 = req.body -- 2537
				local _type_1 = type(_obj_0) -- 2537
				if "table" == _type_1 or "userdata" == _type_1 then -- 2537
					path = _obj_0.path -- 2537
				end -- 2537
			end -- 2537
			if path ~= nil then -- 2537
				local projDir = getWaProjectDirFromFile(path) -- 2538
				if projDir then -- 2538
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2539
					if not Content:exist(sourceDoraPath) then -- 2540
						return { -- 2541
							success = false, -- 2541
							message = "missing dora template" -- 2541
						} -- 2541
					end -- 2540
					local targetVendorPath = Path(projDir, "vendor") -- 2542
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2543
					if not Content:exist(targetVendorPath) then -- 2544
						if not Content:mkdir(targetVendorPath) then -- 2545
							return { -- 2546
								success = false, -- 2546
								message = "failed to create vendor folder" -- 2546
							} -- 2546
						end -- 2545
					elseif not Content:isdir(targetVendorPath) then -- 2547
						return { -- 2548
							success = false, -- 2548
							message = "vendor path is not a folder" -- 2548
						} -- 2548
					end -- 2544
					if Content:exist(targetDoraPath) then -- 2549
						if not Content:remove(targetDoraPath) then -- 2550
							return { -- 2551
								success = false, -- 2551
								message = "failed to remove old dora" -- 2551
							} -- 2551
						end -- 2550
					end -- 2549
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2552
						return { -- 2553
							success = false, -- 2553
							message = "failed to copy dora" -- 2553
						} -- 2553
					end -- 2552
					return { -- 2554
						success = true -- 2554
					} -- 2554
				else -- 2556
					return { -- 2556
						success = false, -- 2556
						message = 'Wa file needs a project' -- 2556
					} -- 2556
				end -- 2538
			end -- 2537
		end -- 2537
	end -- 2537
	return { -- 2536
		success = false, -- 2536
		message = "invalid call" -- 2536
	} -- 2536
end) -- 2536
HttpServer:postSchedule("/wa/build", function(req) -- 2558
	do -- 2559
		local _type_0 = type(req) -- 2559
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2559
		if _tab_0 then -- 2559
			local path -- 2559
			do -- 2559
				local _obj_0 = req.body -- 2559
				local _type_1 = type(_obj_0) -- 2559
				if "table" == _type_1 or "userdata" == _type_1 then -- 2559
					path = _obj_0.path -- 2559
				end -- 2559
			end -- 2559
			if path ~= nil then -- 2559
				local projDir = getWaProjectDirFromFile(path) -- 2560
				if projDir then -- 2560
					local message = Wasm:buildWaAsync(projDir) -- 2561
					if message == "" then -- 2562
						return { -- 2563
							success = true -- 2563
						} -- 2563
					else -- 2565
						return { -- 2565
							success = false, -- 2565
							message = message -- 2565
						} -- 2565
					end -- 2562
				else -- 2567
					return { -- 2567
						success = false, -- 2567
						message = 'Wa file needs a project' -- 2567
					} -- 2567
				end -- 2560
			end -- 2559
		end -- 2559
	end -- 2559
	return { -- 2568
		success = false, -- 2568
		message = 'failed to build' -- 2568
	} -- 2568
end) -- 2558
HttpServer:postSchedule("/wa/format", function(req) -- 2570
	do -- 2571
		local _type_0 = type(req) -- 2571
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2571
		if _tab_0 then -- 2571
			local file -- 2571
			do -- 2571
				local _obj_0 = req.body -- 2571
				local _type_1 = type(_obj_0) -- 2571
				if "table" == _type_1 or "userdata" == _type_1 then -- 2571
					file = _obj_0.file -- 2571
				end -- 2571
			end -- 2571
			if file ~= nil then -- 2571
				local code = Wasm:formatWaAsync(file) -- 2572
				if code == "" then -- 2573
					return { -- 2574
						success = false -- 2574
					} -- 2574
				else -- 2576
					return { -- 2576
						success = true, -- 2576
						code = code -- 2576
					} -- 2576
				end -- 2573
			end -- 2571
		end -- 2571
	end -- 2571
	return { -- 2577
		success = false -- 2577
	} -- 2577
end) -- 2570
HttpServer:postSchedule("/wa/create", function(req) -- 2579
	do -- 2580
		local _type_0 = type(req) -- 2580
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2580
		if _tab_0 then -- 2580
			local path -- 2580
			do -- 2580
				local _obj_0 = req.body -- 2580
				local _type_1 = type(_obj_0) -- 2580
				if "table" == _type_1 or "userdata" == _type_1 then -- 2580
					path = _obj_0.path -- 2580
				end -- 2580
			end -- 2580
			if path ~= nil then -- 2580
				if not Content:exist(Path:getPath(path)) then -- 2581
					return { -- 2582
						success = false, -- 2582
						message = "target path not existed" -- 2582
					} -- 2582
				end -- 2581
				if Content:exist(path) then -- 2583
					return { -- 2584
						success = false, -- 2584
						message = "target project folder existed" -- 2584
					} -- 2584
				end -- 2583
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2585
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2586
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2587
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2588
					return { -- 2591
						success = false, -- 2591
						message = "missing template project" -- 2591
					} -- 2591
				end -- 2588
				if not Content:mkdir(path) then -- 2592
					return { -- 2593
						success = false, -- 2593
						message = "failed to create project folder" -- 2593
					} -- 2593
				end -- 2592
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2594
					Content:remove(path) -- 2595
					return { -- 2596
						success = false, -- 2596
						message = "failed to copy template" -- 2596
					} -- 2596
				end -- 2594
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2597
					Content:remove(path) -- 2598
					return { -- 2599
						success = false, -- 2599
						message = "failed to copy template" -- 2599
					} -- 2599
				end -- 2597
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2600
					Content:remove(path) -- 2601
					return { -- 2602
						success = false, -- 2602
						message = "failed to copy template" -- 2602
					} -- 2602
				end -- 2600
				return { -- 2603
					success = true -- 2603
				} -- 2603
			end -- 2580
		end -- 2580
	end -- 2580
	return { -- 2579
		success = false, -- 2579
		message = "invalid call" -- 2579
	} -- 2579
end) -- 2579
local tsBuildGlobs = { -- 2606
	"**/*.ts", -- 2606
	"**/*.tsx", -- 2607
	"!**/.*/**", -- 2608
	"!**/node_modules/**" -- 2609
} -- 2605
local tsSnapshotGlobs = { -- 2612
	"**/*.ts", -- 2612
	"**/*.tsx", -- 2613
	"**/*.lua", -- 2614
	"!**/.*/**", -- 2615
	"!**/node_modules/**" -- 2616
} -- 2611
local collectTSVirtualFiles -- 2618
collectTSVirtualFiles = function(sourceRoot) -- 2618
	local files = { } -- 2619
	local seen = { } -- 2620
	local addFile -- 2621
	addFile = function(file, moduleName, virtualFile) -- 2621
		if moduleName == nil then -- 2621
			moduleName = nil -- 2621
		end -- 2621
		if virtualFile == nil then -- 2621
			virtualFile = nil -- 2621
		end -- 2621
		local targetFile = virtualFile or file -- 2622
		do -- 2623
			local entry = seen[targetFile] -- 2623
			if entry then -- 2623
				if moduleName and moduleName ~= "" then -- 2624
					entry.moduleName = moduleName -- 2624
				end -- 2624
				return -- 2625
			end -- 2623
		end -- 2623
		local content = Content:load(file) -- 2626
		if content then -- 2626
			local entry = { -- 2627
				file = targetFile, -- 2627
				content = content -- 2627
			} -- 2627
			if moduleName and moduleName ~= "" then -- 2628
				entry.moduleName = moduleName -- 2628
			end -- 2628
			seen[targetFile] = entry -- 2629
			files[#files + 1] = entry -- 2630
		end -- 2626
	end -- 2621
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2631
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2632
		for _index_0 = 1, #_list_0 do -- 2632
			local subFile = _list_0[_index_0] -- 2632
			addFile(Path(sourceRoot, subFile)) -- 2633
		end -- 2632
		local libraryRoots = { -- 2635
			Path(sourceRoot, "Script", "Lib"), -- 2635
			Path(sourceRoot, "Lib"), -- 2636
			Path(Content.assetPath, "Script", "Lib") -- 2637
		} -- 2634
		for _index_0 = 1, #libraryRoots do -- 2638
			local libraryRoot = libraryRoots[_index_0] -- 2638
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2639
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2640
				for _index_1 = 1, #_list_1 do -- 2640
					local subFile = _list_1[_index_1] -- 2640
					local file = Path(libraryRoot, subFile) -- 2641
					local virtualFile = Path(sourceRoot, subFile) -- 2642
					addFile(file, nil, virtualFile) -- 2643
				end -- 2640
			end -- 2639
		end -- 2638
	end -- 2631
	local locale -- 2644
	if App.locale:match('^zh') then -- 2644
		locale = 'zh-Hans' -- 2644
	else -- 2644
		locale = 'en' -- 2644
	end -- 2644
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2645
	local _list_0 = Content:getFiles(declarationRoot) -- 2646
	for _index_0 = 1, #_list_0 do -- 2646
		local file = _list_0[_index_0] -- 2646
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2647
			local fullPath = Path(declarationRoot, file) -- 2648
			local moduleName = Path:getName(Path:getName(file)) -- 2649
			addFile(fullPath, moduleName) -- 2650
		end -- 2647
	end -- 2646
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2651
	local lualibBundleTarget -- 2652
	if sourceRoot then -- 2652
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2652
	else -- 2652
		lualibBundleTarget = "lualib_bundle.lua" -- 2652
	end -- 2652
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2653
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2654
	local _list_1 = Content:getFiles(lualibRoot) -- 2655
	for _index_0 = 1, #_list_1 do -- 2655
		local file = _list_1[_index_0] -- 2655
		if Path:getExt(file) == "lua" then -- 2656
			local virtualFile -- 2657
			if sourceRoot then -- 2657
				virtualFile = Path(sourceRoot, "lualib", file) -- 2657
			else -- 2657
				virtualFile = Path("lualib", file) -- 2657
			end -- 2657
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2658
		end -- 2656
	end -- 2655
	return files -- 2659
end -- 2618
local supportsCompilerWebView -- 2661
supportsCompilerWebView = function() -- 2661
	local _val_0 = App.platform -- 2661
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2661
end -- 2661
local webIDECompilerReady = false -- 2662
local webIDEConnectionGeneration = 0 -- 2663
local tsProbeId = 0 -- 2664
local probeWebIDECompiler -- 2666
probeWebIDECompiler = function(isCancelled) -- 2666
	if HttpServer.wsConnectionCount == 0 then -- 2667
		return false -- 2667
	end -- 2667
	tsProbeId = tsProbeId + 1 -- 2668
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2669
	local generation = webIDEConnectionGeneration -- 2670
	local done, ready = false, false -- 2671
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2672
	local listener = Node() -- 2673
	listener:gslot("AppWS", function(event) -- 2674
		if event.type == "Receive" then -- 2675
			local res = json.decode(event.msg) -- 2676
			if res then -- 2676
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2677
					responses = responses + 1 -- 2678
					ready = ready or res.success == true -- 2679
					done = ready or responses >= expectedResponses -- 2680
				end -- 2677
			end -- 2676
		end -- 2675
	end) -- 2674
	emit("AppWS", "Send", json.encode({ -- 2681
		name = "TranspileTSProbe", -- 2681
		id = requestId -- 2681
	})) -- 2681
	local deadline = App.runningTime + 5 -- 2682
	wait(function() -- 2683
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2683
	end) -- 2683
	listener:removeFromParent() -- 2684
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2685
	if generation == webIDEConnectionGeneration then -- 2686
		webIDECompilerReady = ready -- 2686
	end -- 2686
	return ready -- 2687
end -- 2666
local compilerConnectionListener = Node() -- 2689
compilerConnectionListener:addTo(Director.systemUI) -- 2691
local _anon_func_8 = function(event) -- 2693
	local _val_0 = event.type -- 2693
	return "Open" == _val_0 or "Close" == _val_0 -- 2693
end -- 2693
compilerConnectionListener:gslot("AppWS", function(event) -- 2692
	if _anon_func_8(event) then -- 2693
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2694
		webIDECompilerReady = false -- 2695
		if HttpServer.wsConnectionCount > 0 then -- 2696
			return thread(function() -- 2697
				return probeWebIDECompiler() -- 2697
			end) -- 2697
		end -- 2696
	end -- 2693
end) -- 2692
local _anon_func_9 = function(res) -- 2722
	if res.success then -- 2722
		return "tool" -- 2722
	else -- 2722
		return res.failureKind -- 2722
	end -- 2722
end -- 2722
local transpileTSFileWithWebIDE -- 2699
do -- 2699
	local tsBuildRequestId = 0 -- 2700
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2701
		if not probeWebIDECompiler(isCancelled) then -- 2702
			if isCancelled and isCancelled() then -- 2703
				return { -- 2704
					success = false, -- 2704
					file = file, -- 2704
					message = "build canceled", -- 2704
					interrupted = true -- 2704
				} -- 2704
			end -- 2703
			return { -- 2705
				success = false, -- 2705
				file = file, -- 2705
				message = "TypeScript transpiler is not ready", -- 2705
				failureKind = "tool" -- 2705
			} -- 2705
		end -- 2702
		tsBuildRequestId = tsBuildRequestId + 1 -- 2706
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2707
		local done = false -- 2708
		local result = nil -- 2709
		local listener = Node() -- 2710
		listener:gslot("AppWS", function(event) -- 2711
			if event.type == "Receive" then -- 2712
				local res = json.decode(event.msg) -- 2713
				if res then -- 2713
					if res.name == "TranspileTS" and res.id == requestId then -- 2714
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2715
							local luaFile = Path:replaceExt(file, "lua") -- 2716
							if Content:save(luaFile, res.luaCode) then -- 2717
								result = { -- 2718
									success = true, -- 2718
									file = file -- 2718
								} -- 2718
							else -- 2720
								result = { -- 2720
									success = false, -- 2720
									file = file, -- 2720
									message = "failed to save " .. tostring(luaFile) -- 2720
								} -- 2720
							end -- 2717
						else -- 2722
							result = { -- 2722
								success = false, -- 2722
								file = file, -- 2722
								message = res.message or "Compiler returned no Lua output", -- 2722
								failureKind = _anon_func_9(res) -- 2722
							} -- 2722
						end -- 2715
						done = true -- 2723
					end -- 2714
				end -- 2713
			end -- 2712
		end) -- 2711
		emit("AppWS", "Send", json.encode({ -- 2724
			name = "TranspileTS", -- 2724
			id = requestId, -- 2724
			file = file, -- 2724
			content = content, -- 2724
			projectRoot = sourceRoot, -- 2724
			files = files -- 2724
		})) -- 2724
		local deadline = App.runningTime + 30 -- 2725
		wait(function() -- 2726
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2726
		end) -- 2726
		listener:removeFromParent() -- 2727
		if not done then -- 2728
			webIDECompilerReady = false -- 2729
			if isCancelled and isCancelled() then -- 2730
				return { -- 2731
					success = false, -- 2731
					file = file, -- 2731
					message = "build canceled", -- 2731
					interrupted = true -- 2731
				} -- 2731
			end -- 2730
			return { -- 2732
				success = false, -- 2732
				file = file, -- 2732
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2732
				failureKind = "tool" -- 2732
			} -- 2732
		end -- 2728
		return result -- 2733
	end -- 2701
end -- 2699
local compilerReadyTimeout <const> = 15 -- 2735
local compilerBuildTimeout <const> = 30 -- 2736
local compilerIdleCloseSeconds <const> = 8 -- 2737
local compilerReady = false -- 2738
local compilerRequested = false -- 2739
local compilerFailure = nil -- 2740
local compilerUsers = 0 -- 2741
local compilerCloseGeneration = 0 -- 2742
local compilerJobId = 0 -- 2743
local compilerJobs = { } -- 2744
local compilerResults = { } -- 2745
local compilerInFlight = { } -- 2746
HttpServer:post("/compiler/ready", function() -- 2748
	if not compilerRequested then -- 2749
		return { -- 2749
			success = false -- 2749
		} -- 2749
	end -- 2749
	compilerReady = true -- 2750
	return { -- 2751
		success = true -- 2751
	} -- 2751
end) -- 2748
HttpServer:post("/compiler/failure", function(req) -- 2753
	if not compilerRequested then -- 2754
		return { -- 2754
			success = false -- 2754
		} -- 2754
	end -- 2754
	do -- 2755
		local _type_0 = type(req) -- 2755
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2755
		if _tab_0 then -- 2755
			local message -- 2755
			do -- 2755
				local _obj_0 = req.body -- 2755
				local _type_1 = type(_obj_0) -- 2755
				if "table" == _type_1 or "userdata" == _type_1 then -- 2755
					message = _obj_0.message -- 2755
				end -- 2755
			end -- 2755
			if message ~= nil then -- 2755
				if type(message) == "string" then -- 2756
					compilerFailure = message -- 2757
					compilerReady = false -- 2758
					return { -- 2759
						success = true -- 2759
					} -- 2759
				end -- 2756
			end -- 2755
		end -- 2755
	end -- 2755
	return { -- 2753
		success = false -- 2753
	} -- 2753
end) -- 2753
HttpServer:postSchedule("/compiler/poll", function() -- 2761
	if not compilerRequested then -- 2762
		return { -- 2762
			success = false -- 2762
		} -- 2762
	end -- 2762
	compilerReady = true -- 2763
	local deadline = App.runningTime + 5 -- 2764
	wait(function() -- 2765
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2765
	end) -- 2765
	if not (compilerRequested and not compilerFailure) then -- 2766
		return { -- 2766
			success = false -- 2766
		} -- 2766
	end -- 2766
	local job = table.remove(compilerJobs, 1) -- 2767
	if job then -- 2768
		compilerInFlight[job.id] = true -- 2769
	end -- 2768
	return { -- 2770
		success = true, -- 2770
		job = job -- 2770
	} -- 2770
end) -- 2761
HttpServer:post("/compiler/result", function(req) -- 2772
	do -- 2773
		local _type_0 = type(req) -- 2773
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2773
		if _tab_0 then -- 2773
			local body = req.body -- 2773
			if body ~= nil then -- 2773
				local id = body.id -- 2774
				if not (id and compilerInFlight[id]) then -- 2775
					return { -- 2775
						success = false, -- 2775
						message = "invalid compiler job" -- 2775
					} -- 2775
				end -- 2775
				compilerInFlight[id] = nil -- 2776
				compilerResults[id] = body -- 2777
				return { -- 2778
					success = true -- 2778
				} -- 2778
			end -- 2773
		end -- 2773
	end -- 2773
	return { -- 2772
		success = false -- 2772
	} -- 2772
end) -- 2772
local acquireCompiler -- 2780
acquireCompiler = function() -- 2780
	compilerUsers = compilerUsers + 1 -- 2781
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2782
	if not compilerRequested then -- 2783
		compilerRequested = true -- 2784
		compilerReady = false -- 2785
		compilerFailure = nil -- 2786
		return emit("AppWebView", "/compiler.html", true) -- 2787
	end -- 2783
end -- 2780
local releaseCompiler -- 2789
releaseCompiler = function() -- 2789
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2790
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2791
	if not (compilerUsers == 0) then -- 2792
		return -- 2792
	end -- 2792
	local closeGeneration = compilerCloseGeneration -- 2793
	return thread(function() -- 2794
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2795
		wait(function() -- 2796
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2797
		end) -- 2796
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2802
			compilerRequested = false -- 2803
			compilerReady = false -- 2804
			return emit("AppWebView", "/compiler.html", false) -- 2805
		end -- 2802
	end) -- 2794
end -- 2789
local removeCompilerJob -- 2807
removeCompilerJob = function(id) -- 2807
	for index = #compilerJobs, 1, -1 do -- 2808
		if compilerJobs[index].id == id then -- 2809
			table.remove(compilerJobs, index) -- 2810
		end -- 2809
	end -- 2808
	compilerInFlight[id] = nil -- 2811
	compilerResults[id] = nil -- 2812
end -- 2807
local transpileTSFileWithCompiler -- 2814
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2814
	acquireCompiler() -- 2815
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2816
	wait(function() -- 2817
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2817
	end) -- 2817
	if not compilerReady then -- 2818
		releaseCompiler() -- 2819
		if isCancelled and isCancelled() then -- 2820
			return { -- 2821
				success = false, -- 2821
				file = file, -- 2821
				message = "build canceled", -- 2821
				interrupted = true -- 2821
			} -- 2821
		end -- 2820
		return { -- 2822
			success = false, -- 2822
			file = file, -- 2822
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2822
			failureKind = "tool" -- 2822
		} -- 2822
	end -- 2818
	compilerJobId = compilerJobId + 1 -- 2823
	local jobId = compilerJobId -- 2824
	compilerJobs[#compilerJobs + 1] = { -- 2826
		id = jobId, -- 2826
		file = file, -- 2827
		content = content, -- 2828
		projectRoot = sourceRoot, -- 2829
		files = files -- 2830
	} -- 2825
	local deadline = App.runningTime + compilerBuildTimeout -- 2831
	wait(function() -- 2832
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2832
	end) -- 2832
	local response = compilerResults[jobId] -- 2833
	removeCompilerJob(jobId) -- 2834
	releaseCompiler() -- 2835
	if not response then -- 2836
		if isCancelled and isCancelled() then -- 2837
			return { -- 2838
				success = false, -- 2838
				file = file, -- 2838
				message = "build canceled", -- 2838
				interrupted = true -- 2838
			} -- 2838
		end -- 2837
		return { -- 2839
			success = false, -- 2839
			file = file, -- 2839
			message = compilerFailure or "TypeScript transpile timed out", -- 2839
			failureKind = "tool" -- 2839
		} -- 2839
	end -- 2836
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2840
		local luaFile = Path:replaceExt(file, "lua") -- 2841
		if Content:save(luaFile, response.luaCode) then -- 2842
			return { -- 2843
				success = true, -- 2843
				file = file -- 2843
			} -- 2843
		end -- 2842
		return { -- 2844
			success = false, -- 2844
			file = file, -- 2844
			message = "failed to save " .. tostring(luaFile) -- 2844
		} -- 2844
	end -- 2840
	return { -- 2845
		success = false, -- 2845
		file = file, -- 2845
		message = response.message or "TypeScript transpile failed" -- 2845
	} -- 2845
end -- 2814
local compilerFailureListener = Node() -- 2847
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2848
	compilerFailure = message -- 2849
	compilerReady = false -- 2850
end) -- 2848
local transpileTSFile -- 2852
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2852
	if supportsCompilerWebView() and not files then -- 2853
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2854
	end -- 2853
	if HttpServer.wsConnectionCount > 0 then -- 2855
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2856
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2857
			return result -- 2857
		end -- 2857
		webIDECompilerReady = false -- 2858
	end -- 2855
	if supportsCompilerWebView() then -- 2859
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2860
	end -- 2859
	return { -- 2861
		success = false, -- 2861
		file = file, -- 2861
		message = "Web IDE compiler not connected", -- 2861
		failureKind = "tool" -- 2861
	} -- 2861
end -- 2852
local _anon_func_10 = function(path) -- 2876
	local _val_0 = Path:getExt(path) -- 2876
	return "ts" == _val_0 or "tsx" == _val_0 -- 2876
end -- 2876
HttpServer:postSchedule("/ts/build", function(req) -- 2863
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2864
	local buildSucceeded = false -- 2865
	local _ <close> = setmetatable({ }, { -- 2866
		__close = function() -- 2866
			return finishUpdate(buildSucceeded) -- 2866
		end -- 2866
	}) -- 2866
	do -- 2867
		local _type_0 = type(req) -- 2867
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2867
		if _tab_0 then -- 2867
			local path -- 2867
			do -- 2867
				local _obj_0 = req.body -- 2867
				local _type_1 = type(_obj_0) -- 2867
				if "table" == _type_1 or "userdata" == _type_1 then -- 2867
					path = _obj_0.path -- 2867
				end -- 2867
			end -- 2867
			if path ~= nil then -- 2867
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2868
					return { -- 2869
						success = false, -- 2869
						message = "Web IDE not connected" -- 2869
					} -- 2869
				end -- 2868
				local projectRoot = req.body.projectRoot -- 2870
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2871
				if not Content:exist(path) then -- 2872
					return { -- 2873
						success = false, -- 2873
						message = "path not existed" -- 2873
					} -- 2873
				end -- 2872
				local messages = { } -- 2874
				if not Content:isdir(path) then -- 2875
					if not (_anon_func_10(path)) then -- 2876
						return { -- 2877
							success = false, -- 2877
							message = "expecting a TypeScript file" -- 2877
						} -- 2877
					end -- 2876
					local content = Content:load(path) -- 2878
					if not content then -- 2879
						return { -- 2880
							success = false, -- 2880
							message = "failed to read file" -- 2880
						} -- 2880
					end -- 2879
					emit("AppWS", "Send", json.encode({ -- 2881
						name = "UpdateFile", -- 2881
						file = path, -- 2881
						exists = true, -- 2881
						content = content, -- 2881
						projectRoot = sourceRoot -- 2881
					})) -- 2881
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2882
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2883
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2884
					end -- 2882
				else -- 2886
					local fileData = { } -- 2886
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2887
					for _index_0 = 1, #_list_0 do -- 2887
						local subFile = _list_0[_index_0] -- 2887
						local file = Path(path, subFile) -- 2888
						local content = Content:load(file) -- 2889
						if content then -- 2889
							fileData[file] = content -- 2890
							emit("AppWS", "Send", json.encode({ -- 2891
								name = "UpdateFile", -- 2891
								file = file, -- 2891
								exists = true, -- 2891
								content = content, -- 2891
								projectRoot = sourceRoot -- 2891
							})) -- 2891
						else -- 2893
							messages[#messages + 1] = { -- 2893
								success = false, -- 2893
								file = file, -- 2893
								message = "failed to read file" -- 2893
							} -- 2893
						end -- 2889
					end -- 2887
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2894
					for file, content in pairs(fileData) do -- 2895
						if "d" == Path:getExt(Path:getName(file)) then -- 2896
							goto _continue_0 -- 2896
						end -- 2896
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2897
						::_continue_0:: -- 2896
					end -- 2895
				end -- 2875
				local success = true -- 2898
				for _index_0 = 1, #messages do -- 2899
					local item = messages[_index_0] -- 2899
					if not item.success then -- 2900
						success = false -- 2900
					end -- 2900
				end -- 2899
				local message = nil -- 2901
				if not success then -- 2902
					message = "TypeScript compilation failed" -- 2902
				end -- 2902
				buildSucceeded = success -- 2903
				return { -- 2904
					success = success, -- 2904
					messages = messages, -- 2904
					message = message -- 2904
				} -- 2904
			end -- 2867
		end -- 2867
	end -- 2867
	return { -- 2863
		success = false -- 2863
	} -- 2863
end) -- 2863
HttpServer:post("/download", function(req) -- 2906
	do -- 2907
		local _type_0 = type(req) -- 2907
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2907
		if _tab_0 then -- 2907
			local url -- 2907
			do -- 2907
				local _obj_0 = req.body -- 2907
				local _type_1 = type(_obj_0) -- 2907
				if "table" == _type_1 or "userdata" == _type_1 then -- 2907
					url = _obj_0.url -- 2907
				end -- 2907
			end -- 2907
			local target -- 2907
			do -- 2907
				local _obj_0 = req.body -- 2907
				local _type_1 = type(_obj_0) -- 2907
				if "table" == _type_1 or "userdata" == _type_1 then -- 2907
					target = _obj_0.target -- 2907
				end -- 2907
			end -- 2907
			if url ~= nil and target ~= nil then -- 2907
				local Entry = require("Script.Dev.Entry") -- 2908
				Entry.downloadFile(url, target) -- 2909
				return { -- 2910
					success = true -- 2910
				} -- 2910
			end -- 2907
		end -- 2907
	end -- 2907
	return { -- 2906
		success = false -- 2906
	} -- 2906
end) -- 2906
local isDesktopPlatform -- 2912
isDesktopPlatform = function() -- 2912
	local _val_0 = App.platform -- 2913
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2913
end -- 2912
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 2915
local nativeIDEListener = Node() -- 2916
nativeIDEListener:addTo(Director.systemUI) -- 2917
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 2918
	nativeIDEState, nativeIDEMessage = state, message -- 2919
end) -- 2918
local _anon_func_11 = function() -- 2922
	local _val_0 = App.platform -- 2922
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2922
end -- 2922
HttpServer:post("/ide", function(req) -- 2921
	if not (_anon_func_11()) then -- 2922
		return { -- 2922
			success = false, -- 2922
			message = "Native IDE is unavailable" -- 2922
		} -- 2922
	end -- 2922
	if not App.webIDEEnabled then -- 2923
		return { -- 2923
			success = false, -- 2923
			message = "Embedded Web IDE is disabled" -- 2923
		} -- 2923
	end -- 2923
	do -- 2924
		local _type_0 = type(req) -- 2924
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2924
		if _tab_0 then -- 2924
			local action -- 2924
			do -- 2924
				local _obj_0 = req.body -- 2924
				local _type_1 = type(_obj_0) -- 2924
				if "table" == _type_1 or "userdata" == _type_1 then -- 2924
					action = _obj_0.action -- 2924
				end -- 2924
			end -- 2924
			if action ~= nil then -- 2924
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 2925
					emit("AppWebView", "/ide/" .. action, true) -- 2926
					return { -- 2927
						success = true -- 2927
					} -- 2927
				end -- 2925
			end -- 2924
		end -- 2924
	end -- 2924
	return { -- 2921
		success = false, -- 2921
		message = "invalid IDE action" -- 2921
	} -- 2921
end) -- 2921
local _anon_func_12 = function() -- 2943
	local _val_0 = App.platform -- 2943
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2943
end -- 2943
local getServerStatus -- 2929
getServerStatus = function() -- 2929
	local Entry = require("Script.Dev.Entry") -- 2930
	local running = Entry.getCurrentEntryStatus() -- 2931
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2932
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2933
	return { -- 2935
		success = true, -- 2935
		platform = App.platform, -- 2936
		locale = App.locale, -- 2937
		version = App.version, -- 2938
		url = "http://localhost:8866", -- 2939
		wsConnectionCount = wsConnectionCount, -- 2940
		webIDEConnected = wsConnectionCount > 0, -- 2941
		nativeIDE = { -- 2943
			supported = _anon_func_12(), -- 2943
			enabled = App.webIDEEnabled, -- 2944
			state = nativeIDEState, -- 2945
			message = nativeIDEMessage -- 2946
		}, -- 2942
		typescriptCompiler = { -- 2948
			webIDEReady = webIDECompilerReady, -- 2948
			webIDEGeneration = webIDEConnectionGeneration, -- 2949
			embeddedSupported = supportsCompilerWebView(), -- 2950
			embeddedRequested = compilerRequested, -- 2951
			embeddedReady = compilerReady, -- 2952
			users = compilerUsers, -- 2953
			queuedJobs = #compilerJobs, -- 2954
			failure = compilerFailure -- 2955
		}, -- 2947
		assetPath = Content.assetPath, -- 2956
		writablePath = Content.writablePath, -- 2957
		appPath = Content.appPath, -- 2958
		waTemplateReady = waTemplateReady, -- 2959
		running = running -- 2960
	} -- 2934
end -- 2929
HttpServer:post("/status", function() -- 2963
	return getServerStatus() -- 2964
end) -- 2963
HttpServer:postSchedule("/doctor/fix", function(req) -- 2966
	do -- 2967
		local _type_0 = type(req) -- 2967
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2967
		if _tab_0 then -- 2967
			local openWebIDE -- 2967
			do -- 2967
				local _obj_0 = req.body -- 2967
				local _type_1 = type(_obj_0) -- 2967
				if "table" == _type_1 or "userdata" == _type_1 then -- 2967
					openWebIDE = _obj_0.openWebIDE -- 2967
				end -- 2967
			end -- 2967
			if openWebIDE ~= nil then -- 2967
				if not openWebIDE then -- 2968
					return { -- 2969
						success = false, -- 2969
						message = "nothing to fix" -- 2969
					} -- 2969
				end -- 2968
				local status = getServerStatus() -- 2970
				if status.webIDEConnected then -- 2971
					return { -- 2972
						success = true, -- 2972
						fixed = false, -- 2972
						message = "Web IDE already connected.", -- 2972
						status = status -- 2972
					} -- 2972
				end -- 2971
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2973
				if waitSeconds > 0 then -- 2974
					local deadline = os.time() + waitSeconds -- 2975
					repeat -- 2976
						sleep(0.2) -- 2977
						status = getServerStatus() -- 2978
						if status.webIDEConnected then -- 2979
							return { -- 2980
								success = true, -- 2980
								fixed = false, -- 2980
								reconnected = true, -- 2980
								message = "Web IDE reconnected.", -- 2980
								status = status -- 2980
							} -- 2980
						end -- 2979
					until os.time() >= deadline -- 2976
				end -- 2974
				if not isDesktopPlatform() then -- 2982
					return { -- 2983
						success = false, -- 2983
						message = "opening Web IDE is only supported on desktop platforms", -- 2983
						status = status -- 2983
					} -- 2983
				end -- 2982
				local url = "http://localhost:8866" -- 2984
				App:openURL(url) -- 2985
				status.openedURL = url -- 2986
				return { -- 2987
					success = true, -- 2987
					fixed = true, -- 2987
					message = "Opened Web IDE in the local browser.", -- 2987
					url = url, -- 2987
					status = status -- 2987
				} -- 2987
			end -- 2967
		end -- 2967
	end -- 2967
	return { -- 2966
		success = false, -- 2966
		message = "invalid call" -- 2966
	} -- 2966
end) -- 2966
local status = { } -- 2989
_module_0 = status -- 2990
status.transpileTSFile = transpileTSFile -- 2992
status.buildAsync = function(path) -- 2994
	if not Content:exist(path) then -- 2995
		return { -- 2996
			success = false, -- 2996
			file = path, -- 2996
			message = "file not existed" -- 2996
		} -- 2996
	end -- 2995
	do -- 2997
		local _exp_0 = Path:getExt(path) -- 2997
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2997
			if '' == Path:getExt(Path:getName(path)) then -- 2998
				local content = Content:loadAsync(path) -- 2999
				if content then -- 2999
					local resultCodes, err = compileFileAsync(path, content) -- 3000
					if resultCodes then -- 3000
						return { -- 3001
							success = true, -- 3001
							file = path -- 3001
						} -- 3001
					else -- 3003
						return { -- 3003
							success = false, -- 3003
							file = path, -- 3003
							message = err -- 3003
						} -- 3003
					end -- 3000
				end -- 2999
			end -- 2998
		elseif "lua" == _exp_0 then -- 3004
			local content = Content:loadAsync(path) -- 3005
			if content then -- 3005
				do -- 3006
					local isTIC80 = CheckTIC80Code(content) -- 3006
					if isTIC80 then -- 3006
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 3007
					end -- 3006
				end -- 3006
				local success, info -- 3008
				do -- 3008
					local _obj_0 = luaCheck(path, content) -- 3008
					success, info = _obj_0.success, _obj_0.info -- 3008
				end -- 3008
				if success then -- 3009
					return { -- 3010
						success = true, -- 3010
						file = path -- 3010
					} -- 3010
				elseif info and #info > 0 then -- 3011
					local messages = { } -- 3012
					for _index_0 = 1, #info do -- 3013
						local _des_0 = info[_index_0] -- 3013
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3013
						local lineText = "" -- 3014
						if line then -- 3015
							local currentLine = 1 -- 3016
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3017
								if currentLine == line then -- 3018
									lineText = text -- 3019
									break -- 3020
								end -- 3018
								currentLine = currentLine + 1 -- 3021
							end -- 3017
						end -- 3015
						if line then -- 3022
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3023
						else -- 3025
							messages[#messages + 1] = message -- 3025
						end -- 3022
					end -- 3013
					return { -- 3026
						success = false, -- 3026
						file = path, -- 3026
						message = table.concat(messages, "\n") -- 3026
					} -- 3026
				else -- 3028
					return { -- 3028
						success = false, -- 3028
						file = path, -- 3028
						message = "lua check failed" -- 3028
					} -- 3028
				end -- 3009
			end -- 3005
		elseif "yarn" == _exp_0 then -- 3029
			local content = Content:loadAsync(path) -- 3030
			if content then -- 3030
				local res, _, err = yarncompile(content, true) -- 3031
				if res then -- 3031
					return { -- 3032
						success = true, -- 3032
						file = path -- 3032
					} -- 3032
				else -- 3034
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3034
					local lineText = "" -- 3035
					if line then -- 3036
						local currentLine = 1 -- 3037
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3038
							if currentLine == line then -- 3039
								lineText = text -- 3040
								break -- 3041
							end -- 3039
							currentLine = currentLine + 1 -- 3042
						end -- 3038
					end -- 3036
					if node ~= "" then -- 3043
						node = "node: " .. tostring(node) .. ", " -- 3044
					else -- 3045
						node = "" -- 3045
					end -- 3043
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3046
					return { -- 3047
						success = false, -- 3047
						file = path, -- 3047
						message = message -- 3047
					} -- 3047
				end -- 3031
			end -- 3030
		end -- 2997
	end -- 2997
	return { -- 3048
		success = false, -- 3048
		file = path, -- 3048
		message = "invalid file to build" -- 3048
	} -- 3048
end -- 2994
HttpServer:postSchedule("/git/commit-files", function(req) -- 3050
	do -- 3051
		local _type_0 = type(req) -- 3051
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3051
		if _tab_0 then -- 3051
			local body = req.body -- 3051
			if body ~= nil then -- 3051
				local repoPath, commit = body.repoPath, body.commit -- 3052
				if gitInvalidRepoPath(repoPath) then -- 3053
					return { -- 3053
						success = false, -- 3053
						message = "invalid repoPath" -- 3053
					} -- 3053
				end -- 3053
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3054
					return { -- 3054
						success = false, -- 3054
						message = "invalid commit" -- 3054
					} -- 3054
				end -- 3054
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3055
				if not res.success then -- 3056
					return res -- 3056
				end -- 3056
				return { -- 3057
					success = true, -- 3057
					status = res.status, -- 3057
					data = res.status and res.status.data -- 3057
				} -- 3057
			end -- 3051
		end -- 3051
	end -- 3051
	return invalidArguments -- 3050
end) -- 3050
thread(function() -- 3059
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3060
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3061
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3062
		local storedAsset -- 3065
		storedAsset = function(file) -- 3065
			if Content:exist(file) then -- 3066
				return Content:load(file) -- 3067
			elseif Content:exist(file .. ".gz") then -- 3068
				return Content:load(file .. ".gz") -- 3069
			else -- 3070
				return "" -- 3070
			end -- 3066
		end -- 3065
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3071
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3072
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3073
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3074
		local readyContent = table.concat({ -- 3076
			App.version, -- 3076
			storedAsset(doraWeb), -- 3077
			storedAsset(heavyAssets), -- 3078
			storedAsset(runtimeIndex), -- 3079
			storedAsset(compilerIndex), -- 3080
			storedAsset(manifest) -- 3081
		}, "\n") -- 3075
		local needReload -- 3083
		if Content:exist(doraReady) then -- 3083
			needReload = readyContent ~= Content:load(doraReady) -- 3084
		else -- 3085
			needReload = true -- 3085
		end -- 3083
		if needReload then -- 3086
			Content:remove(Path(Content.appPath, ".www")) -- 3087
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3088
			Content:save(doraReady, readyContent) -- 3092
			print("Dora Dora is ready!") -- 3093
		end -- 3086
	end -- 3062
	if App.platform == "Emscripten" then -- 3094
		status.url = nil -- 3095
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3096
	end -- 3094
	HttpServer:clearStaticCacheControls() -- 3097
	HttpServer:setStaticCacheControl("no-cache") -- 3098
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3099
	if HttpServer:start(8866) then -- 3103
		local localIP = HttpServer.localIP -- 3104
		if localIP == "" then -- 3105
			localIP = "localhost" -- 3105
		end -- 3105
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3106
		return HttpServer:startWS(8868) -- 3107
	else -- 3109
		status.url = nil -- 3109
		return print("8866 Port not available!") -- 3110
	end -- 3103
end) -- 3059
return _module_0 -- 1
