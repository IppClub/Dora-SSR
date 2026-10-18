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
local AgentStorage = AgentHost.proxy("Agent.Storage.Database") -- 143
local AgentLocalAgent = AgentHost.proxy("Agent.LocalAgent") -- 144
local AgentVisionAssets = AgentHost.proxy("Agent.Tool.VisionAssets") -- 145
HttpServer:post("/agent/runtime/status", function() -- 147
	return AgentHost.status() -- 147
end) -- 147
HttpServer:post("/agent/runtime/reload", function() -- 148
	return AgentHost.reload() -- 148
end) -- 148
HttpServer:post("/agent/runtime/automatic", function(req) -- 149
	do -- 150
		local _type_0 = type(req) -- 150
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 150
		if _tab_0 then -- 150
			local enabled -- 150
			do -- 150
				local _obj_0 = req.body -- 150
				local _type_1 = type(_obj_0) -- 150
				if "table" == _type_1 or "userdata" == _type_1 then -- 150
					enabled = _obj_0.enabled -- 150
				end -- 150
			end -- 150
			if enabled ~= nil then -- 150
				if type(enabled) == "boolean" then -- 151
					return AgentHost.setAutomatic(enabled) -- 151
				end -- 151
			end -- 150
		end -- 150
	end -- 150
	return invalidArguments -- 149
end) -- 149
local GitJobs = { } -- 153
local gitTerminalState -- 155
gitTerminalState = function(status) -- 155
	if not (status and status.state) then -- 156
		return false -- 156
	end -- 156
	local _val_0 = status.state -- 157
	return "done" == _val_0 or "error" == _val_0 or "canceled" == _val_0 -- 157
end -- 155
local GIT_JOB_TTL = 600 -- 159
local gitPruneJobs -- 161
gitPruneJobs = function() -- 161
	local time = os.time() -- 162
	for id, job in pairs(GitJobs) do -- 163
		if gitTerminalState(job.status) and time - (job.updatedAt or time) > GIT_JOB_TTL then -- 164
			GitJobs[id] = nil -- 165
		end -- 164
	end -- 163
end -- 161
local gitInvalidRepoPath -- 167
gitInvalidRepoPath = function(repoPath) -- 167
	if not (type(repoPath) == "string" and repoPath ~= "") then -- 168
		return true -- 168
	end -- 168
	return not Git:isRepoPathAllowed(repoPath) -- 169
end -- 167
local gitShellSplit -- 171
gitShellSplit = function(command) -- 171
	local args = { } -- 172
	local current = { } -- 173
	local quote = nil -- 174
	local escape = false -- 175
	for i = 1, #command do -- 176
		local ch = command:sub(i, i) -- 177
		if escape then -- 178
			current[#current + 1] = ch -- 179
			escape = false -- 180
		elseif ch == "\\" and quote ~= "'" then -- 181
			escape = true -- 182
		elseif quote then -- 183
			if ch == quote then -- 184
				quote = nil -- 185
			else -- 187
				current[#current + 1] = ch -- 187
			end -- 184
		elseif ch == "'" or ch == '"' then -- 188
			quote = ch -- 189
		elseif ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 190
			if #current > 0 then -- 191
				args[#args + 1] = table.concat(current) -- 192
				current = { } -- 193
			end -- 191
		else -- 195
			current[#current + 1] = ch -- 195
		end -- 178
	end -- 176
	if #current > 0 then -- 196
		args[#args + 1] = table.concat(current) -- 197
	end -- 196
	if args[1] == "git" then -- 198
		table.remove(args, 1) -- 199
	end -- 198
	return args -- 200
end -- 171
local gitQuote -- 202
gitQuote = function(value) -- 202
	local text = tostring(value) -- 203
	if text:match("^[%w%._%-%/]+$") then -- 204
		return text -- 205
	end -- 204
	return "\"" .. text:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"" -- 206
end -- 202
local gitDirNonEmpty -- 208
gitDirNonEmpty = function(targetPath) -- 208
	if not Content:exist(targetPath) then -- 209
		return false -- 209
	end -- 209
	if not Content:isdir(targetPath) then -- 210
		return false -- 210
	end -- 210
	return #Content:getFiles(targetPath) > 0 or #Content:getDirs(targetPath) > 0 -- 211
end -- 208
local gitSafeChildPath -- 213
gitSafeChildPath = function(parentPath, childPath) -- 213
	if not (parentPath and childPath and childPath ~= "") then -- 214
		return nil -- 214
	end -- 214
	if childPath:sub(1, 1) == "/" or childPath:match("^%a:[/\\]") then -- 215
		return nil -- 215
	end -- 215
	if childPath == "." or childPath:match("^%.%.[/\\]?" or childPath:match("[/\\]%.%.[/\\]")) then -- 216
		return nil -- 216
	end -- 216
	local targetPath = Path(parentPath, childPath) -- 217
	local relative = Path:getRelative(targetPath, parentPath) -- 218
	if relative == ".." or relative:sub(1, 3) == "../" or relative:sub(1, 3) == "..\\" then -- 219
		return nil -- 219
	end -- 219
	return targetPath -- 220
end -- 213
local gitCloneDirFromURL -- 222
gitCloneDirFromURL = function(url) -- 222
	if not (url and url ~= "") then -- 223
		return nil -- 223
	end -- 223
	local text = tostring(url):gsub("/+$", "") -- 225
	text = text:match(".*:([^/]+)$") or text -- 226
	local name = Path:getFilename(text):gsub("%.git$", "") -- 227
	if name == "" or name == "." or name == ".." then -- 228
		return nil -- 228
	end -- 228
	return name -- 229
end -- 222
local gitCloneTargetPath -- 231
gitCloneTargetPath = function(repoPath, command) -- 231
	local args = gitShellSplit(command) -- 232
	if not (args[1] == "clone") then -- 233
		return nil -- 233
	end -- 233
	local url, target = nil, nil -- 234
	local index = 2 -- 235
	while index <= #args do -- 236
		local arg = args[index] -- 237
		if ("-b" == arg or "--branch" == arg or "--depth" == arg) then -- 238
			if not args[index + 1] then -- 239
				return nil -- 239
			end -- 239
			index = index + 2 -- 240
		else -- 242
			if arg:sub(1, 1) == "-" then -- 242
				return nil -- 242
			end -- 242
			if not url then -- 243
				url = arg -- 244
			elseif not target then -- 245
				target = arg -- 246
			else -- 248
				return nil -- 248
			end -- 243
			index = index + 1 -- 249
		end -- 238
	end -- 236
	if not url then -- 250
		return nil -- 250
	end -- 250
	target = target or gitCloneDirFromURL(url) -- 251
	return gitSafeChildPath(repoPath, target) -- 252
end -- 231
local gitPathInsideRepo -- 254
gitPathInsideRepo = function(repoPath, relPath) -- 254
	if not (repoPath and relPath and relPath ~= "") then -- 255
		return false -- 255
	end -- 255
	if relPath:sub(1, 1) == "/" or relPath:match("^%a:[/\\]") then -- 256
		return false -- 256
	end -- 256
	if relPath == "." or relPath:match("^%.%.[/\\]?" or relPath:match("[/\\]%.%.[/\\]")) then -- 257
		return false -- 257
	end -- 257
	local targetPath = Path(repoPath, relPath) -- 258
	local relative = Path:getRelative(targetPath, repoPath) -- 259
	return relative ~= ".." and relative:sub(1, 3) ~= "../" and relative:sub(1, 3) ~= "..\\" -- 260
end -- 254
local gitHostFromURL -- 262
gitHostFromURL = function(url) -- 262
	if not (url and url ~= "") then -- 263
		return nil -- 263
	end -- 263
	local text = tostring(url):match("^%s*(.-)%s*$") -- 264
	if text == "" then -- 265
		return nil -- 265
	end -- 265
	local host = text:match("^[%w_%-]+://([^/:]+)") -- 266
	if not host then -- 267
		host = text:match("@([^:/]+)[:/]") -- 267
	end -- 267
	if not host then -- 268
		host = text:match("^([^:/]+):[^/]") -- 268
	end -- 268
	if not (host and host ~= "") then -- 269
		return nil -- 269
	end -- 269
	return string.lower(host) -- 270
end -- 262
local ensureGitTables -- 272
ensureGitTables = function() -- 272
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
	]]) -- 273
	DB:exec("CREATE INDEX IF NOT EXISTS idx_git_credential_host ON GitCredential(host);") -- 286
	return DB:exec([[		CREATE TABLE IF NOT EXISTS GitProfile(
			id INTEGER PRIMARY KEY CHECK(id = 1),
			name TEXT NOT NULL DEFAULT '',
			email TEXT NOT NULL DEFAULT '',
			updated_at INTEGER
		);
	]]) -- 287
end -- 272
local gitCredentialToPublic -- 296
gitCredentialToPublic = function(row) -- 296
	local id, host, label, typeName, username, createdAt, updatedAt, lastUsedAt = row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8] -- 297
	return { -- 298
		id = id, -- 298
		host = host, -- 298
		label = label, -- 298
		type = typeName, -- 298
		username = username, -- 298
		createdAt = createdAt, -- 298
		updatedAt = updatedAt, -- 298
		lastUsedAt = lastUsedAt -- 298
	} -- 298
end -- 296
local gitLoadCredential -- 300
gitLoadCredential = function(id) -- 300
	ensureGitTables() -- 301
	local credentialId = tonumber(id) or 0 -- 302
	local rows = DB:query("select id, host, label, type, username, secret from GitCredential where id = ? limit 1", { -- 303
		credentialId -- 303
	}) -- 303
	if not (rows and rows[1]) then -- 304
		return nil -- 304
	end -- 304
	local row = rows[1] -- 305
	return { -- 306
		id = row[1], -- 306
		host = row[2], -- 306
		label = row[3], -- 306
		type = row[4], -- 306
		username = row[5], -- 306
		secret = row[6] -- 306
	} -- 306
end -- 300
local gitAuthOptionsJSON -- 308
gitAuthOptionsJSON = function(credential) -- 308
	if not credential then -- 309
		return nil -- 309
	end -- 309
	local auth -- 310
	if credential.type == "token" then -- 310
		auth = { -- 312
			type = "token", -- 312
			token = credential.secret, -- 313
			username = credential.username ~= "" and credential.username or "token" -- 314
		} -- 311
	else -- 317
		auth = { -- 318
			type = "basic", -- 318
			username = credential.username, -- 319
			password = credential.secret -- 320
		} -- 317
	end -- 310
	return json.encode({ -- 322
		auth = auth -- 322
	}) -- 322
end -- 308
local gitLoadProfile -- 324
gitLoadProfile = function() -- 324
	ensureGitTables() -- 325
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 326
	if not (rows and rows[1]) then -- 327
		return nil -- 327
	end -- 327
	local name = tostring(rows[1][1] or "") -- 328
	local email = tostring(rows[1][2] or "") -- 329
	if name == "" and email == "" then -- 330
		return nil -- 330
	end -- 330
	return { -- 331
		name = name, -- 331
		email = email -- 331
	} -- 331
end -- 324
local _anon_func_2 = function(args, gitQuote) -- 350
	local _accum_0 = { } -- 350
	local _len_0 = 1 -- 350
	for _index_0 = 1, #args do -- 350
		local arg = args[_index_0] -- 350
		_accum_0[_len_0] = gitQuote(arg) -- 350
		_len_0 = _len_0 + 1 -- 350
	end -- 350
	return _accum_0 -- 350
end -- 350
local gitApplyProfileToCommit -- 333
gitApplyProfileToCommit = function(command) -- 333
	local args = gitShellSplit(command) -- 334
	if not (args[1] == "commit") then -- 335
		return command -- 335
	end -- 335
	local hasName = false -- 336
	local hasEmail = false -- 337
	for _index_0 = 1, #args do -- 338
		local arg = args[_index_0] -- 338
		if arg == "--author-name" then -- 339
			hasName = true -- 339
		end -- 339
		if arg == "--author-email" then -- 340
			hasEmail = true -- 340
		end -- 340
	end -- 338
	if hasName and hasEmail then -- 341
		return command -- 341
	end -- 341
	local profile = gitLoadProfile() -- 342
	if not profile then -- 343
		return command -- 343
	end -- 343
	if not hasName and profile.name ~= "" then -- 344
		args[#args + 1] = "--author-name" -- 345
		args[#args + 1] = profile.name -- 346
	end -- 344
	if not hasEmail and profile.email ~= "" then -- 347
		args[#args + 1] = "--author-email" -- 348
		args[#args + 1] = profile.email -- 349
	end -- 347
	return table.concat(_anon_func_2(args, gitQuote), " ") -- 350
end -- 333
local gitStartJob -- 352
gitStartJob = function(repoPath, command, optionsJSON) -- 352
	if optionsJSON == nil then -- 352
		optionsJSON = nil -- 352
	end -- 352
	gitPruneJobs() -- 353
	if gitInvalidRepoPath(repoPath) then -- 354
		return nil, "invalid repoPath" -- 354
	end -- 354
	if not (command and command ~= "") then -- 355
		return nil, "invalid command" -- 355
	end -- 355
	if not optionsJSON then -- 356
		optionsJSON = "" -- 356
	end -- 356
	command = gitApplyProfileToCommit(command) -- 357
	do -- 358
		local targetPath = gitCloneTargetPath(repoPath, command) -- 358
		if targetPath then -- 358
			if gitInvalidRepoPath(targetPath) then -- 359
				return nil, "invalid clone target" -- 359
			end -- 359
			if gitDirNonEmpty(targetPath) then -- 360
				return nil, "clone target directory is not empty" -- 361
			end -- 360
		elseif (gitShellSplit(command))[1] == "clone" then -- 362
			return nil, "invalid clone target" -- 363
		end -- 358
	end -- 358
	local statusRef = nil -- 364
	local startGit -- 365
	startGit = function() -- 365
		return Git:run(repoPath, command, (function(status) -- 366
			statusRef = status -- 367
			GitJobs[status.id] = { -- 369
				command = command, -- 369
				status = status, -- 370
				updatedAt = os.time() -- 371
			} -- 368
		end), optionsJSON) -- 366
	end -- 365
	local success, jobId = pcall(startGit) -- 373
	if not success then -- 374
		return nil, tostring(jobId) -- 374
	end -- 374
	if not jobId then -- 375
		return nil, "Git.run did not return a job id" -- 375
	end -- 375
	GitJobs[jobId] = { -- 377
		command = command, -- 377
		status = statusRef or { -- 379
			id = jobId, -- 379
			state = "queued", -- 380
			kind = gitShellSplit(command)[1] or "status", -- 381
			repoPath = repoPath, -- 382
			progress = 0, -- 383
			message = "queued" -- 384
		}, -- 378
		updatedAt = os.time() -- 386
	} -- 376
	return jobId -- 387
end -- 352
local gitRunSync -- 389
gitRunSync = function(repoPath, command, optionsJSON, timeout) -- 389
	if optionsJSON == nil then -- 389
		optionsJSON = nil -- 389
	end -- 389
	if timeout == nil then -- 389
		timeout = 20 -- 389
	end -- 389
	local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 390
	if not jobId then -- 391
		return { -- 391
			success = false, -- 391
			message = err -- 391
		} -- 391
	end -- 391
	local startedAt = os.time() -- 392
	wait(function() -- 393
		local job = GitJobs[jobId] -- 394
		local status = job and job.status -- 395
		return gitTerminalState(status) or os.time() - startedAt >= timeout -- 396
	end) -- 393
	local status = GitJobs[jobId] and GitJobs[jobId].status -- 397
	if not gitTerminalState(status) then -- 398
		Git:cancel(jobId) -- 399
		return { -- 400
			success = false, -- 400
			message = "git command timed out", -- 400
			jobId = jobId, -- 400
			status = status -- 400
		} -- 400
	end -- 398
	return { -- 401
		success = status.state == "done", -- 401
		jobId = jobId, -- 401
		status = status, -- 401
		message = status.error or status.message -- 401
	} -- 401
end -- 389
local gitCredentialsForHost -- 403
gitCredentialsForHost = function(host) -- 403
	if not (host and host ~= "") then -- 404
		return { } -- 404
	end -- 404
	ensureGitTables() -- 405
	local rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by last_used_at desc, label asc, id asc", { -- 406
		host -- 406
	}) -- 406
	if rows then -- 407
		local _accum_0 = { } -- 408
		local _len_0 = 1 -- 408
		for _index_0 = 1, #rows do -- 408
			local row = rows[_index_0] -- 408
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 408
			_len_0 = _len_0 + 1 -- 408
		end -- 408
		return _accum_0 -- 408
	else -- 409
		return { } -- 409
	end -- 407
end -- 403
local gitFirstRemoteURL -- 411
gitFirstRemoteURL = function(repoPath, remoteName) -- 411
	if remoteName == nil then -- 411
		remoteName = nil -- 411
	end -- 411
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 10) -- 412
	local data = remoteRes.status and remoteRes.status.data -- 413
	if not (data and data.remotes) then -- 414
		return nil -- 414
	end -- 414
	local _list_0 = data.remotes -- 415
	for _index_0 = 1, #_list_0 do -- 415
		local remote = _list_0[_index_0] -- 415
		if (not remoteName or remote.name == remoteName) and remote.urls and remote.urls[1] then -- 416
			return remote.urls[1] -- 417
		end -- 416
	end -- 415
	return nil -- 418
end -- 411
local gitConfigRemoteURL -- 420
gitConfigRemoteURL = function(repoPath, remoteName) -- 420
	if remoteName == nil then -- 420
		remoteName = nil -- 420
	end -- 420
	if gitInvalidRepoPath(repoPath) then -- 421
		return nil -- 421
	end -- 421
	local configPath = Path(repoPath, ".git/config") -- 422
	if not Content:exist(configPath) then -- 423
		return nil -- 423
	end -- 423
	local content = Content:load(configPath) -- 424
	if not (content and content ~= "") then -- 425
		return nil -- 425
	end -- 425
	local currentRemote = nil -- 426
	for line in content:gmatch("[^\r\n]+") do -- 427
		local sectionRemote = line:match('^%s*%[remote%s+"([^"]+)"%]%s*$') -- 428
		if sectionRemote then -- 429
			currentRemote = sectionRemote -- 430
		elseif currentRemote and (not remoteName or currentRemote == remoteName) then -- 431
			local url = line:match("^%s*url%s*=%s*(.-)%s*$") -- 432
			if url and url ~= "" then -- 433
				return url -- 433
			end -- 433
		end -- 429
	end -- 427
	return nil -- 434
end -- 420
local gitCommandRemoteArg -- 436
gitCommandRemoteArg = function(args, startIndex) -- 436
	if startIndex == nil then -- 436
		startIndex = 2 -- 436
	end -- 436
	local index = startIndex -- 437
	while index <= #args do -- 438
		local arg = args[index] -- 439
		if ("-u" == arg or "--set-upstream" == arg or "-f" == arg or "--force" == arg or "--all" == arg or "--prune" == arg) then -- 440
			index = index + 1 -- 441
		elseif ("--depth" == arg or "-b" == arg or "--branch" == arg) then -- 442
			index = index + 2 -- 443
		elseif arg and arg:sub(1, 1) == "-" then -- 444
			index = index + 1 -- 445
		else -- 447
			return arg -- 447
		end -- 440
	end -- 438
	return nil -- 448
end -- 436
local gitCommandHost -- 450
gitCommandHost = function(repoPath, command) -- 450
	local args = gitShellSplit(command) -- 451
	if not args[1] then -- 452
		return nil -- 452
	end -- 452
	do -- 453
		local _exp_0 = args[1] -- 453
		if "clone" == _exp_0 or "ls-remote" == _exp_0 then -- 454
			return gitHostFromURL(args[2]) -- 455
		elseif "fetch" == _exp_0 or "pull" == _exp_0 or "push" == _exp_0 then -- 456
			local remoteArg = gitCommandRemoteArg(args, 2) -- 457
			if not remoteArg then -- 458
				return nil -- 458
			end -- 458
			local url = gitHostFromURL(remoteArg) -- 459
			if url then -- 460
				return url -- 460
			end -- 460
			return gitHostFromURL(gitConfigRemoteURL(repoPath, remoteArg)) -- 461
		end -- 453
	end -- 453
	return nil -- 462
end -- 450
local gitAuthSelectionForCommand -- 464
gitAuthSelectionForCommand = function(repoPath, command) -- 464
	local host = gitCommandHost(repoPath, command) -- 465
	if not host then -- 466
		return nil -- 466
	end -- 466
	local items = gitCredentialsForHost(host) -- 467
	if #items == 0 then -- 468
		return nil -- 468
	end -- 468
	return { -- 469
		host = host, -- 469
		items = items -- 469
	} -- 469
end -- 464
local gitDefaultRemote -- 471
gitDefaultRemote = function(remoteStatus) -- 471
	local data = remoteStatus and remoteStatus.data -- 472
	if not (data and data.remotes and data.remotes[1]) then -- 473
		return nil -- 473
	end -- 473
	return data.remotes[1] -- 474
end -- 471
local gitCurrentBranch -- 476
gitCurrentBranch = function(branchStatus) -- 476
	local data = branchStatus and branchStatus.data -- 477
	if data and data.current and data.current ~= "" then -- 478
		return data.current -- 479
	end -- 478
	if data and data.branches then -- 480
		local _list_0 = data.branches -- 481
		for _index_0 = 1, #_list_0 do -- 481
			local branch = _list_0[_index_0] -- 481
			if branch.current then -- 482
				return branch.name -- 482
			end -- 482
		end -- 481
	end -- 480
	return nil -- 483
end -- 476
local gitHeadBranch -- 485
gitHeadBranch = function(repoPath) -- 485
	if gitInvalidRepoPath(repoPath) then -- 486
		return nil -- 486
	end -- 486
	local headPath = Path(repoPath, ".git", "HEAD") -- 487
	if not Content:exist(headPath) then -- 488
		return nil -- 488
	end -- 488
	local head = Content:load(headPath) -- 489
	if not head then -- 490
		return nil -- 490
	end -- 490
	local branch = head:match("^ref:%s*refs/heads/(.-)%s*$") -- 491
	if branch and branch ~= "" then -- 492
		return branch -- 492
	end -- 492
	return nil -- 493
end -- 485
local gitBranchesWithHead -- 495
gitBranchesWithHead = function(branchStatus, currentBranch) -- 495
	local branches = branchStatus and branchStatus.data and branchStatus.data.branches or { } -- 496
	if not (currentBranch and currentBranch ~= "") then -- 497
		return branches -- 497
	end -- 497
	for _index_0 = 1, #branches do -- 498
		local branch = branches[_index_0] -- 498
		if branch.name == currentBranch then -- 499
			return branches -- 499
		end -- 499
	end -- 498
	local withHead -- 500
	do -- 500
		local _accum_0 = { } -- 500
		local _len_0 = 1 -- 500
		for _index_0 = 1, #branches do -- 500
			local branch = branches[_index_0] -- 500
			_accum_0[_len_0] = branch -- 500
			_len_0 = _len_0 + 1 -- 500
		end -- 500
		withHead = _accum_0 -- 500
	end -- 500
	withHead[#withHead + 1] = { -- 501
		name = currentBranch, -- 501
		current = true, -- 501
		unborn = true -- 501
	} -- 501
	return withHead -- 502
end -- 495
local gitStatusMeansNotRepo -- 504
gitStatusMeansNotRepo = function(statusRes) -- 504
	local message = statusRes and (statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message)) or "" -- 505
	message = tostring(message):lower() -- 506
	return message:find("repository does not exist", 1, true) or message:find("not a git repository", 1, true) -- 507
end -- 504
local gitSummary -- 509
gitSummary = function(repoPath) -- 509
	local statusRes = gitRunSync(repoPath, "status", nil, 120) -- 510
	if not statusRes.success then -- 511
		if gitStatusMeansNotRepo(statusRes) then -- 512
			return { -- 513
				success = true, -- 513
				isRepo = false, -- 513
				message = statusRes.message, -- 513
				status = statusRes.status -- 513
			} -- 513
		end -- 512
		return { -- 514
			success = false, -- 514
			message = statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message) or "failed to check Git repository", -- 514
			status = statusRes.status -- 514
		} -- 514
	end -- 511
	local branchRes = gitRunSync(repoPath, "branch", nil, 120) -- 515
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 120) -- 516
	local status = statusRes.status -- 517
	local branchStatus = branchRes.status -- 518
	local remoteStatus = remoteRes.status -- 519
	local currentBranch = gitCurrentBranch(branchStatus) or gitHeadBranch(repoPath) -- 520
	local branches = gitBranchesWithHead(branchStatus, currentBranch) -- 521
	local logRes = gitRunSync(repoPath, "log --metadata-only -n 100", nil, 120) -- 522
	local logStatus -- 523
	if logRes.success then -- 523
		logStatus = logRes.status -- 524
	else -- 526
		logStatus = { -- 527
			state = "done", -- 527
			kind = "log", -- 528
			repoPath = repoPath, -- 529
			progress = 1, -- 530
			message = "git log completed", -- 531
			data = { -- 532
				commits = { } -- 532
			} -- 532
		} -- 526
	end -- 523
	local hasCommit = logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] ~= nil -- 534
	local tagStatus -- 535
	if hasCommit then -- 535
		tagStatus = (gitRunSync(repoPath, "tag", nil, 120)).status -- 536
	else -- 538
		tagStatus = { -- 539
			state = "done", -- 539
			kind = "tag", -- 540
			repoPath = repoPath, -- 541
			progress = 1, -- 542
			message = "git tag completed", -- 543
			data = { -- 544
				tags = { } -- 544
			} -- 544
		} -- 538
	end -- 535
	local defaultRemote = gitDefaultRemote(remoteStatus) -- 546
	local lastCommit = nil -- 547
	if logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] then -- 548
		lastCommit = logStatus.data.commits[1] -- 549
	end -- 548
	return { -- 551
		success = true, -- 551
		isRepo = true, -- 552
		clean = status.data and status.data.clean or false, -- 553
		currentBranch = currentBranch, -- 554
		defaultRemote = defaultRemote, -- 555
		remotes = remoteStatus and remoteStatus.data and remoteStatus.data.remotes or { }, -- 556
		branches = branches, -- 557
		lastCommit = lastCommit, -- 558
		status = status, -- 559
		branchStatus = branchStatus, -- 560
		remoteStatus = remoteStatus, -- 561
		historyStatus = logStatus, -- 562
		tagStatus = tagStatus -- 563
	} -- 550
end -- 509
HttpServer:post("/git/run", function(req) -- 565
	do -- 566
		local _type_0 = type(req) -- 566
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 566
		if _tab_0 then -- 566
			local body = req.body -- 566
			if body ~= nil then -- 566
				local repoPath, command, authId, optionsJSON = body.repoPath, body.command, body.authId, body.optionsJSON -- 567
				if authId and not optionsJSON then -- 568
					local credential = gitLoadCredential(authId) -- 569
					if credential then -- 569
						optionsJSON = gitAuthOptionsJSON(credential) -- 570
						DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 571
							os.time(), -- 571
							credential.id -- 571
						}) -- 571
					end -- 569
				elseif not optionsJSON then -- 572
					local authOk, authSelection = pcall(gitAuthSelectionForCommand, repoPath, command) -- 573
					if not authOk then -- 574
						authSelection = nil -- 574
					end -- 574
					if authSelection then -- 575
						if #authSelection.items == 1 then -- 576
							local credential = gitLoadCredential(authSelection.items[1].id) -- 577
							optionsJSON = gitAuthOptionsJSON(credential) -- 578
							DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 579
								os.time(), -- 579
								credential.id -- 579
							}) -- 579
						else -- 581
							return { -- 581
								success = false, -- 581
								message = "select a Git credential", -- 581
								needsCredentialSelection = true, -- 581
								host = authSelection.host, -- 581
								credentials = authSelection.items -- 581
							} -- 581
						end -- 576
					end -- 575
				end -- 568
				local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 582
				if not jobId then -- 583
					return { -- 583
						success = false, -- 583
						message = err -- 583
					} -- 583
				end -- 583
				return { -- 584
					success = true, -- 584
					jobId = jobId -- 584
				} -- 584
			end -- 566
		end -- 566
	end -- 566
	return invalidArguments -- 565
end) -- 565
HttpServer:post("/git/status", function(req) -- 586
	do -- 587
		local _type_0 = type(req) -- 587
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 587
		if _tab_0 then -- 587
			local jobId -- 587
			do -- 587
				local _obj_0 = req.body -- 587
				local _type_1 = type(_obj_0) -- 587
				if "table" == _type_1 or "userdata" == _type_1 then -- 587
					jobId = _obj_0.jobId -- 587
				end -- 587
			end -- 587
			if jobId ~= nil then -- 587
				local job = GitJobs[tonumber(jobId) or 0] -- 588
				if not job then -- 589
					return { -- 589
						success = false, -- 589
						message = "git job not found" -- 589
					} -- 589
				end -- 589
				return { -- 590
					success = true, -- 590
					status = job.status, -- 590
					command = job.command -- 590
				} -- 590
			end -- 587
		end -- 587
	end -- 587
	return invalidArguments -- 586
end) -- 586
HttpServer:post("/git/cancel", function(req) -- 592
	do -- 593
		local _type_0 = type(req) -- 593
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 593
		if _tab_0 then -- 593
			local jobId -- 593
			do -- 593
				local _obj_0 = req.body -- 593
				local _type_1 = type(_obj_0) -- 593
				if "table" == _type_1 or "userdata" == _type_1 then -- 593
					jobId = _obj_0.jobId -- 593
				end -- 593
			end -- 593
			if jobId ~= nil then -- 593
				local id = tonumber(jobId) -- 594
				if not id then -- 595
					return { -- 595
						success = false, -- 595
						message = "invalid jobId" -- 595
					} -- 595
				end -- 595
				return { -- 596
					success = Git:cancel(id) -- 596
				} -- 596
			end -- 593
		end -- 593
	end -- 593
	return invalidArguments -- 592
end) -- 592
HttpServer:postSchedule("/git/summary", function(req) -- 598
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
				if gitInvalidRepoPath(repoPath) then -- 600
					return { -- 600
						success = false, -- 600
						message = "invalid repoPath" -- 600
					} -- 600
				end -- 600
				return gitSummary(repoPath) -- 601
			end -- 599
		end -- 599
	end -- 599
	return invalidArguments -- 598
end) -- 598
HttpServer:postSchedule("/git/status-files", function(req) -- 603
	do -- 604
		local _type_0 = type(req) -- 604
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 604
		if _tab_0 then -- 604
			local repoPath -- 604
			do -- 604
				local _obj_0 = req.body -- 604
				local _type_1 = type(_obj_0) -- 604
				if "table" == _type_1 or "userdata" == _type_1 then -- 604
					repoPath = _obj_0.repoPath -- 604
				end -- 604
			end -- 604
			if repoPath ~= nil then -- 604
				return gitRunSync(repoPath, "status", nil, 120) -- 605
			end -- 604
		end -- 604
	end -- 604
	return invalidArguments -- 603
end) -- 603
HttpServer:postSchedule("/git/discard-untracked", function(req) -- 607
	do -- 608
		local _type_0 = type(req) -- 608
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 608
		if _tab_0 then -- 608
			local body = req.body -- 608
			if body ~= nil then -- 608
				local repoPath, paths = body.repoPath, body.paths -- 609
				if gitInvalidRepoPath(repoPath) then -- 610
					return { -- 610
						success = false, -- 610
						message = "invalid repoPath" -- 610
					} -- 610
				end -- 610
				if not (type(paths) == "table") then -- 611
					return { -- 611
						success = false, -- 611
						message = "invalid paths" -- 611
					} -- 611
				end -- 611
				local statusRes = gitRunSync(repoPath, "status", nil, 10) -- 612
				if not statusRes.success then -- 613
					return statusRes -- 613
				end -- 613
				local untracked = { } -- 614
				local _list_0 = (statusRes.status.data and statusRes.status.data.files or { }) -- 615
				for _index_0 = 1, #_list_0 do -- 615
					local file = _list_0[_index_0] -- 615
					if file.staging == "?" or file.worktree == "?" then -- 616
						untracked[file.path] = true -- 617
					end -- 616
				end -- 615
				local removed = { } -- 618
				for _index_0 = 1, #paths do -- 619
					local relPath = paths[_index_0] -- 619
					relPath = tostring(relPath) -- 620
					if not gitPathInsideRepo(repoPath, relPath) then -- 621
						return { -- 621
							success = false, -- 621
							message = "unsafe path: " .. tostring(relPath) -- 621
						} -- 621
					end -- 621
					if not untracked[relPath] then -- 622
						return { -- 622
							success = false, -- 622
							message = "path is not untracked: " .. tostring(relPath) -- 622
						} -- 622
					end -- 622
				end -- 619
				for _index_0 = 1, #paths do -- 623
					local relPath = paths[_index_0] -- 623
					local targetPath = Path(repoPath, tostring(relPath)) -- 624
					if Content:exist(targetPath) then -- 625
						Content:remove(targetPath) -- 626
						removed[#removed + 1] = tostring(relPath) -- 627
					end -- 625
				end -- 623
				return { -- 628
					success = true, -- 628
					removed = removed -- 628
				} -- 628
			end -- 608
		end -- 608
	end -- 608
	return invalidArguments -- 607
end) -- 607
HttpServer:postSchedule("/git/file-diff", function(req) -- 630
	do -- 631
		local _type_0 = type(req) -- 631
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 631
		if _tab_0 then -- 631
			local body = req.body -- 631
			if body ~= nil then -- 631
				local repoPath, path, staged = body.repoPath, body.path, body.staged -- 632
				if gitInvalidRepoPath(repoPath) then -- 633
					return { -- 633
						success = false, -- 633
						message = "invalid repoPath" -- 633
					} -- 633
				end -- 633
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 634
					return { -- 634
						success = false, -- 634
						message = "unsafe path" -- 634
					} -- 634
				end -- 634
				local command -- 635
				if staged == true then -- 635
					command = "diff --staged -- " .. tostring(gitQuote(path)) -- 636
				else -- 638
					command = "diff -- " .. tostring(gitQuote(path)) -- 638
				end -- 635
				local res = gitRunSync(repoPath, command, nil, 10) -- 639
				if not res.success then -- 640
					return res -- 640
				end -- 640
				return { -- 641
					success = true, -- 641
					status = res.status, -- 641
					data = res.status and res.status.data -- 641
				} -- 641
			end -- 631
		end -- 631
	end -- 631
	return invalidArguments -- 630
end) -- 630
HttpServer:postSchedule("/git/commit-file-diff", function(req) -- 643
	do -- 644
		local _type_0 = type(req) -- 644
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 644
		if _tab_0 then -- 644
			local body = req.body -- 644
			if body ~= nil then -- 644
				local repoPath, commit, path = body.repoPath, body.commit, body.path -- 645
				if gitInvalidRepoPath(repoPath) then -- 646
					return { -- 646
						success = false, -- 646
						message = "invalid repoPath" -- 646
					} -- 646
				end -- 646
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 647
					return { -- 647
						success = false, -- 647
						message = "invalid commit" -- 647
					} -- 647
				end -- 647
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 648
					return { -- 648
						success = false, -- 648
						message = "unsafe path" -- 648
					} -- 648
				end -- 648
				local res = gitRunSync(repoPath, "diff " .. tostring(gitQuote(commit)) .. " -- " .. tostring(gitQuote(path)), nil, 10) -- 649
				if not res.success then -- 650
					return res -- 650
				end -- 650
				return { -- 651
					success = true, -- 651
					status = res.status, -- 651
					data = res.status and res.status.data -- 651
				} -- 651
			end -- 644
		end -- 644
	end -- 644
	return invalidArguments -- 643
end) -- 643
HttpServer:postSchedule("/git/history", function(req) -- 653
	do -- 654
		local _type_0 = type(req) -- 654
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 654
		if _tab_0 then -- 654
			local body = req.body -- 654
			if body ~= nil then -- 654
				local repoPath, limit = body.repoPath, body.limit -- 655
				limit = math.max(1, math.min(100, tonumber(limit) or 20)) -- 656
				return gitRunSync(repoPath, "log --metadata-only -n " .. tostring(limit), nil, 10) -- 657
			end -- 654
		end -- 654
	end -- 654
	return invalidArguments -- 653
end) -- 653
HttpServer:postSchedule("/git/remotes", function(req) -- 659
	do -- 660
		local _type_0 = type(req) -- 660
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 660
		if _tab_0 then -- 660
			local body = req.body -- 660
			if body ~= nil then -- 660
				local repoPath, command = body.repoPath, body.command -- 661
				command = command or "remote -v" -- 662
				return gitRunSync(repoPath, command, nil, 10) -- 663
			end -- 660
		end -- 660
	end -- 660
	return invalidArguments -- 659
end) -- 659
HttpServer:postSchedule("/git/branches", function(req) -- 665
	do -- 666
		local _type_0 = type(req) -- 666
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 666
		if _tab_0 then -- 666
			local body = req.body -- 666
			if body ~= nil then -- 666
				local repoPath, command = body.repoPath, body.command -- 667
				command = command or "branch" -- 668
				return gitRunSync(repoPath, command, nil, 10) -- 669
			end -- 666
		end -- 666
	end -- 666
	return invalidArguments -- 665
end) -- 665
HttpServer:postSchedule("/git/tags", function(req) -- 671
	do -- 672
		local _type_0 = type(req) -- 672
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 672
		if _tab_0 then -- 672
			local body = req.body -- 672
			if body ~= nil then -- 672
				local repoPath, command = body.repoPath, body.command -- 673
				command = command or "tag" -- 674
				return gitRunSync(repoPath, command, nil, 10) -- 675
			end -- 672
		end -- 672
	end -- 672
	return invalidArguments -- 671
end) -- 671
HttpServer:post("/git/profile/get", function() -- 677
	ensureGitTables() -- 678
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 679
	local profile -- 680
	if rows and rows[1] then -- 680
		profile = { -- 681
			name = rows[1][1], -- 681
			email = rows[1][2] -- 681
		} -- 681
	else -- 683
		profile = { -- 683
			name = "", -- 683
			email = "" -- 683
		} -- 683
	end -- 680
	return { -- 684
		success = true, -- 684
		profile = profile -- 684
	} -- 684
end) -- 677
HttpServer:post("/git/profile/save", function(req) -- 686
	do -- 687
		local _type_0 = type(req) -- 687
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 687
		if _tab_0 then -- 687
			local name -- 687
			do -- 687
				local _obj_0 = req.body -- 687
				local _type_1 = type(_obj_0) -- 687
				if "table" == _type_1 or "userdata" == _type_1 then -- 687
					name = _obj_0.name -- 687
				end -- 687
			end -- 687
			local email -- 687
			do -- 687
				local _obj_0 = req.body -- 687
				local _type_1 = type(_obj_0) -- 687
				if "table" == _type_1 or "userdata" == _type_1 then -- 687
					email = _obj_0.email -- 687
				end -- 687
			end -- 687
			if name ~= nil and email ~= nil then -- 687
				ensureGitTables() -- 688
				DB:exec("insert into GitProfile(id, name, email, updated_at) values(1, ?, ?, ?) on conflict(id) do update set name = excluded.name, email = excluded.email, updated_at = excluded.updated_at", { -- 690
					tostring(name or ""), -- 690
					tostring(email or ""), -- 691
					os.time() -- 692
				}) -- 689
				return { -- 694
					success = true -- 694
				} -- 694
			end -- 687
		end -- 687
	end -- 687
	return invalidArguments -- 686
end) -- 686
HttpServer:post("/git/auth/list", function(req) -- 696
	ensureGitTables() -- 697
	local host = nil -- 698
	do -- 699
		local _type_0 = type(req) -- 699
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 699
		if _tab_0 then -- 699
			local body = req.body -- 699
			if body ~= nil then -- 699
				host = body.host -- 700
			end -- 699
		end -- 699
	end -- 699
	local rows -- 701
	if host and host ~= "" then -- 701
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by host asc, label asc, id asc", { -- 702
			tostring(host):lower() -- 702
		}) -- 702
	else -- 704
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential order by host asc, label asc, id asc") -- 704
	end -- 701
	local items -- 705
	if rows then -- 705
		local _accum_0 = { } -- 705
		local _len_0 = 1 -- 705
		for _index_0 = 1, #rows do -- 705
			local row = rows[_index_0] -- 705
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 705
			_len_0 = _len_0 + 1 -- 705
		end -- 705
		items = _accum_0 -- 705
	else -- 705
		items = { } -- 705
	end -- 705
	return { -- 706
		success = true, -- 706
		items = items -- 706
	} -- 706
end) -- 696
HttpServer:postSchedule("/git/auth/match", function(req) -- 708
	do -- 709
		local _type_0 = type(req) -- 709
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 709
		if _tab_0 then -- 709
			local body = req.body -- 709
			if body ~= nil then -- 709
				if not (type(body) == "table") then -- 710
					return invalidArguments -- 710
				end -- 710
				local repoPath, command, url = body.repoPath, body.command, body.url -- 711
				if url ~= nil and type(url) ~= "string" then -- 712
					return invalidArguments -- 712
				end -- 712
				if not (type(url) == "string" and url ~= "") then -- 713
					if not (type(repoPath) == "string" and type(command) == "string") then -- 714
						return invalidArguments -- 714
					end -- 714
				end -- 713
				local host -- 715
				if url and url ~= "" then -- 715
					host = gitHostFromURL(url) -- 715
				else -- 715
					host = gitCommandHost(repoPath, command) -- 715
				end -- 715
				if not host then -- 716
					return { -- 716
						success = false, -- 716
						message = "git host is required" -- 716
					} -- 716
				end -- 716
				local items = gitCredentialsForHost(host) -- 717
				return { -- 718
					success = true, -- 718
					host = host, -- 718
					items = items, -- 718
					needsSelection = #items > 1, -- 718
					authId = (#items == 1 and items[1].id or nil) -- 718
				} -- 718
			end -- 709
		end -- 709
	end -- 709
	return invalidArguments -- 708
end) -- 708
HttpServer:post("/git/auth/save", function(req) -- 720
	do -- 721
		local _type_0 = type(req) -- 721
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 721
		if _tab_0 then -- 721
			local body = req.body -- 721
			if body ~= nil then -- 721
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token -- 722
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$") -- 723
				label = tostring(label or ""):match("^%s*(.-)%s*$") -- 724
				local credentialType = tostring(body.type or "token") -- 725
				username = tostring(username or "") -- 726
				local secret -- 727
				if credentialType == "basic" then -- 727
					secret = tostring(password or "") -- 727
				else -- 727
					secret = tostring(token or password or "") -- 727
				end -- 727
				if host == "" then -- 728
					return { -- 728
						success = false, -- 728
						message = "host is required" -- 728
					} -- 728
				end -- 728
				if label == "" then -- 729
					return { -- 729
						success = false, -- 729
						message = "label is required" -- 729
					} -- 729
				end -- 729
				if secret == "" then -- 730
					return { -- 730
						success = false, -- 730
						message = "secret is required" -- 730
					} -- 730
				end -- 730
				if not (("basic" == credentialType or "token" == credentialType)) then -- 731
					return { -- 731
						success = false, -- 731
						message = "invalid type" -- 731
					} -- 731
				end -- 731
				ensureGitTables() -- 732
				local now = os.time() -- 733
				if id then -- 734
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", { -- 736
						host, -- 736
						label, -- 736
						credentialType, -- 736
						username, -- 736
						secret, -- 736
						now, -- 736
						(tonumber(id) or 0) -- 736
					}) -- 735
					return { -- 738
						success = true, -- 738
						id = tonumber(id) -- 738
					} -- 738
				else -- 740
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", { -- 741
						host, -- 741
						label, -- 741
						credentialType, -- 741
						username, -- 741
						secret, -- 741
						now, -- 741
						now -- 741
					}) -- 740
					local rows = DB:query("select last_insert_rowid()") -- 743
					return { -- 744
						success = true, -- 744
						id = rows and rows[1] and rows[1][1] -- 744
					} -- 744
				end -- 734
			end -- 721
		end -- 721
	end -- 721
	return invalidArguments -- 720
end) -- 720
HttpServer:post("/git/auth/delete", function(req) -- 746
	do -- 747
		local _type_0 = type(req) -- 747
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 747
		if _tab_0 then -- 747
			local id -- 747
			do -- 747
				local _obj_0 = req.body -- 747
				local _type_1 = type(_obj_0) -- 747
				if "table" == _type_1 or "userdata" == _type_1 then -- 747
					id = _obj_0.id -- 747
				end -- 747
			end -- 747
			if id ~= nil then -- 747
				ensureGitTables() -- 748
				local credentialId = tonumber(id) or 0 -- 749
				DB:exec("delete from GitCredential where id = ?", { -- 750
					credentialId -- 750
				}) -- 750
				return { -- 751
					success = true -- 751
				} -- 751
			end -- 747
		end -- 747
	end -- 747
	return invalidArguments -- 746
end) -- 746
HttpServer:postSchedule("/git/auth/test", function(req) -- 753
	do -- 754
		local _type_0 = type(req) -- 754
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 754
		if _tab_0 then -- 754
			local body = req.body -- 754
			if body ~= nil then -- 754
				local repoPath, url, authId = body.repoPath, body.url, body.authId -- 755
				local credential = gitLoadCredential(authId) -- 756
				local optionsJSON = gitAuthOptionsJSON(credential) -- 757
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20) -- 758
			end -- 754
		end -- 754
	end -- 754
	return invalidArguments -- 753
end) -- 753
HttpServer:post("/agent/storage/usage", function() -- 761
	return AgentStorage.getStorageUsage() -- 761
end) -- 761
HttpServer:post("/agent/session/create", function(req) -- 763
	do -- 764
		local _type_0 = type(req) -- 764
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 764
		if _tab_0 then -- 764
			local projectRoot -- 764
			do -- 764
				local _obj_0 = req.body -- 764
				local _type_1 = type(_obj_0) -- 764
				if "table" == _type_1 or "userdata" == _type_1 then -- 764
					projectRoot = _obj_0.projectRoot -- 764
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
			if projectRoot ~= nil and title ~= nil then -- 764
				return AgentSession.createSession(projectRoot, title) -- 765
			end -- 764
		end -- 764
	end -- 764
	return invalidArguments -- 763
end) -- 763
HttpServer:post("/agent/session/create-sub", function(req) -- 767
	do -- 768
		local _type_0 = type(req) -- 768
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 768
		if _tab_0 then -- 768
			local parentSessionId -- 768
			do -- 768
				local _obj_0 = req.body -- 768
				local _type_1 = type(_obj_0) -- 768
				if "table" == _type_1 or "userdata" == _type_1 then -- 768
					parentSessionId = _obj_0.parentSessionId -- 768
				end -- 768
			end -- 768
			local title -- 768
			do -- 768
				local _obj_0 = req.body -- 768
				local _type_1 = type(_obj_0) -- 768
				if "table" == _type_1 or "userdata" == _type_1 then -- 768
					title = _obj_0.title -- 768
				end -- 768
			end -- 768
			if parentSessionId ~= nil and title ~= nil then -- 768
				return AgentSession.createSubSession(parentSessionId, title) -- 769
			end -- 768
		end -- 768
	end -- 768
	return invalidArguments -- 767
end) -- 767
HttpServer:post("/agent/session/get", function(req) -- 771
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
			if sessionId ~= nil then -- 772
				return AgentSession.getSession(sessionId) -- 773
			end -- 772
		end -- 772
	end -- 772
	return invalidArguments -- 771
end) -- 771
HttpServer:post("/agent/vision/asset", function(req) -- 775
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
			local path -- 776
			do -- 776
				local _obj_0 = req.body -- 776
				local _type_1 = type(_obj_0) -- 776
				if "table" == _type_1 or "userdata" == _type_1 then -- 776
					path = _obj_0.path -- 776
				end -- 776
			end -- 776
			if sessionId ~= nil and path ~= nil then -- 776
				return AgentVisionAssets.getSessionVisionImageFromPath(sessionId, path) -- 777
			end -- 776
		end -- 776
	end -- 776
	return invalidArguments -- 775
end) -- 775
HttpServer:post("/agent/session/mode", function(req) -- 779
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
			local workMode -- 780
			do -- 780
				local _obj_0 = req.body -- 780
				local _type_1 = type(_obj_0) -- 780
				if "table" == _type_1 or "userdata" == _type_1 then -- 780
					workMode = _obj_0.workMode -- 780
				end -- 780
			end -- 780
			if sessionId ~= nil and workMode ~= nil then -- 780
				return AgentSession.setWorkMode(sessionId, workMode) -- 781
			end -- 780
		end -- 780
	end -- 780
	return invalidArguments -- 779
end) -- 779
HttpServer:post("/agent/session/send", function(req) -- 783
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
			if sessionId ~= nil and prompt ~= nil then -- 784
				return AgentSession.sendPrompt(sessionId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 785
			end -- 784
		end -- 784
	end -- 784
	return invalidArguments -- 783
end) -- 783
HttpServer:post("/agent/session/send-local", function(req) -- 787
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
			local prompt -- 788
			do -- 788
				local _obj_0 = req.body -- 788
				local _type_1 = type(_obj_0) -- 788
				if "table" == _type_1 or "userdata" == _type_1 then -- 788
					prompt = _obj_0.prompt -- 788
				end -- 788
			end -- 788
			local localAgentConfigId -- 788
			do -- 788
				local _obj_0 = req.body -- 788
				local _type_1 = type(_obj_0) -- 788
				if "table" == _type_1 or "userdata" == _type_1 then -- 788
					localAgentConfigId = _obj_0.localAgentConfigId -- 788
				end -- 788
			end -- 788
			if sessionId ~= nil and prompt ~= nil and localAgentConfigId ~= nil then -- 788
				return AgentSession.sendLocalPrompt(sessionId, prompt, localAgentConfigId) -- 789
			end -- 788
		end -- 788
	end -- 788
	return invalidArguments -- 787
end) -- 787
HttpServer:post("/agent/session/local/new", function(req) -- 791
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
				return AgentLocalAgent.abandonSession(sessionId) -- 793
			end -- 792
		end -- 792
	end -- 792
	return invalidArguments -- 791
end) -- 791
HttpServer:post("/agent/session/local/info", function(req) -- 795
	do -- 796
		local _type_0 = type(req) -- 796
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 796
		if _tab_0 then -- 796
			local sessionId -- 796
			do -- 796
				local _obj_0 = req.body -- 796
				local _type_1 = type(_obj_0) -- 796
				if "table" == _type_1 or "userdata" == _type_1 then -- 796
					sessionId = _obj_0.sessionId -- 796
				end -- 796
			end -- 796
			if sessionId ~= nil then -- 796
				local info = AgentLocalAgent.getSessionInfo(sessionId) -- 797
				return { -- 798
					success = true, -- 798
					info = info -- 798
				} -- 798
			end -- 796
		end -- 796
	end -- 796
	return invalidArguments -- 795
end) -- 795
HttpServer:post("/agent/session/continue", function(req) -- 800
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
				return AgentSession.continuePrompt(sessionId, req.body.disabledAgentTools, req.body.llmConfigId) -- 802
			end -- 801
		end -- 801
	end -- 801
	return invalidArguments -- 800
end) -- 800
HttpServer:post("/agent/session/finish-handoff", function(req) -- 804
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
			if sessionId ~= nil then -- 805
				return AgentSession.finishSubSessionHandoff(sessionId, req.body.llmConfigId) -- 806
			end -- 805
		end -- 805
	end -- 805
	return invalidArguments -- 804
end) -- 804
HttpServer:post("/agent/session/resend", function(req) -- 808
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
			local messageId -- 809
			do -- 809
				local _obj_0 = req.body -- 809
				local _type_1 = type(_obj_0) -- 809
				if "table" == _type_1 or "userdata" == _type_1 then -- 809
					messageId = _obj_0.messageId -- 809
				end -- 809
			end -- 809
			local prompt -- 809
			do -- 809
				local _obj_0 = req.body -- 809
				local _type_1 = type(_obj_0) -- 809
				if "table" == _type_1 or "userdata" == _type_1 then -- 809
					prompt = _obj_0.prompt -- 809
				end -- 809
			end -- 809
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 809
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 810
			end -- 809
		end -- 809
	end -- 809
	return invalidArguments -- 808
end) -- 808
HttpServer:post("/agent/session/questionnaire/respond", function(req) -- 812
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
			local answers -- 813
			do -- 813
				local _obj_0 = req.body -- 813
				local _type_1 = type(_obj_0) -- 813
				if "table" == _type_1 or "userdata" == _type_1 then -- 813
					answers = _obj_0.answers -- 813
				end -- 813
			end -- 813
			if sessionId ~= nil and questionnaireId ~= nil and answers ~= nil then -- 813
				return AgentSession.respondQuestionnaire(sessionId, questionnaireId, answers, req.body.llmConfigId) -- 814
			end -- 813
		end -- 813
	end -- 813
	return invalidArguments -- 812
end) -- 812
HttpServer:post("/agent/session/questionnaire/cancel", function(req) -- 816
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
			local questionnaireId -- 817
			do -- 817
				local _obj_0 = req.body -- 817
				local _type_1 = type(_obj_0) -- 817
				if "table" == _type_1 or "userdata" == _type_1 then -- 817
					questionnaireId = _obj_0.questionnaireId -- 817
				end -- 817
			end -- 817
			if sessionId ~= nil and questionnaireId ~= nil then -- 817
				return AgentSession.cancelQuestionnaire(sessionId, questionnaireId, req.body.llmConfigId) -- 818
			end -- 817
		end -- 817
	end -- 817
	return invalidArguments -- 816
end) -- 816
HttpServer:post("/agent/task/status", function(req) -- 820
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
			if sessionId ~= nil then -- 821
				local res = AgentSession.getSession(sessionId) -- 822
				if not res.success then -- 823
					return res -- 823
				end -- 823
				local taskId = res.session.currentTaskId -- 824
				local checkpoints -- 825
				if taskId then -- 825
					checkpoints = AgentTools.listCheckpoints(taskId) -- 825
				else -- 825
					checkpoints = { } -- 825
				end -- 825
				return { -- 827
					success = true, -- 827
					session = res.session, -- 828
					relatedSessions = res.relatedSessions, -- 829
					spawnInfo = res.spawnInfo, -- 830
					messages = res.messages, -- 831
					steps = res.steps, -- 832
					checkpoints = checkpoints, -- 833
					pendingQuestionnaire = res.pendingQuestionnaire, -- 834
					hasActivePlan = res.hasActivePlan -- 835
				} -- 826
			end -- 821
		end -- 821
	end -- 821
	return invalidArguments -- 820
end) -- 820
HttpServer:post("/agent/task/running", function() -- 837
	local res = AgentSession.listRunningSessions() -- 838
	if res.success and #res.sessions == 0 then -- 839
		res.sessions = nil -- 840
	end -- 839
	return res -- 841
end) -- 837
HttpServer:post("/agent/task/stop", function(req) -- 843
	do -- 844
		local _type_0 = type(req) -- 844
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 844
		if _tab_0 then -- 844
			local sessionId -- 844
			do -- 844
				local _obj_0 = req.body -- 844
				local _type_1 = type(_obj_0) -- 844
				if "table" == _type_1 or "userdata" == _type_1 then -- 844
					sessionId = _obj_0.sessionId -- 844
				end -- 844
			end -- 844
			if sessionId ~= nil then -- 844
				return AgentSession.stopSessionTask(sessionId) -- 845
			end -- 844
		end -- 844
	end -- 844
	return invalidArguments -- 843
end) -- 843
HttpServer:post("/agent/checkpoint/list", function(req) -- 847
	do -- 848
		local _type_0 = type(req) -- 848
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 848
		if _tab_0 then -- 848
			local taskId -- 848
			do -- 848
				local _obj_0 = req.body -- 848
				local _type_1 = type(_obj_0) -- 848
				if "table" == _type_1 or "userdata" == _type_1 then -- 848
					taskId = _obj_0.taskId -- 848
				end -- 848
			end -- 848
			local sessionId -- 848
			do -- 848
				local _obj_0 = req.body -- 848
				local _type_1 = type(_obj_0) -- 848
				if "table" == _type_1 or "userdata" == _type_1 then -- 848
					sessionId = _obj_0.sessionId -- 848
				end -- 848
			end -- 848
			if sessionId ~= nil then -- 848
				if not taskId and sessionId then -- 849
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 850
				end -- 849
				if not taskId then -- 851
					return { -- 851
						success = false, -- 851
						message = "task not found" -- 851
					} -- 851
				end -- 851
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 852
				if not access.success then -- 853
					return access -- 853
				end -- 853
				return { -- 855
					success = true, -- 855
					taskId = taskId, -- 856
					checkpoints = AgentTools.listCheckpoints(taskId) -- 857
				} -- 854
			end -- 848
		end -- 848
	end -- 848
	return invalidArguments -- 847
end) -- 847
HttpServer:post("/agent/checkpoint/diff", function(req) -- 859
	do -- 860
		local _type_0 = type(req) -- 860
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 860
		if _tab_0 then -- 860
			local sessionId -- 860
			do -- 860
				local _obj_0 = req.body -- 860
				local _type_1 = type(_obj_0) -- 860
				if "table" == _type_1 or "userdata" == _type_1 then -- 860
					sessionId = _obj_0.sessionId -- 860
				end -- 860
			end -- 860
			local checkpointId -- 860
			do -- 860
				local _obj_0 = req.body -- 860
				local _type_1 = type(_obj_0) -- 860
				if "table" == _type_1 or "userdata" == _type_1 then -- 860
					checkpointId = _obj_0.checkpointId -- 860
				end -- 860
			end -- 860
			if sessionId ~= nil and checkpointId ~= nil then -- 860
				if not (checkpointId > 0) then -- 861
					return { -- 861
						success = false, -- 861
						message = "invalid checkpointId" -- 861
					} -- 861
				end -- 861
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 862
				if not access.success then -- 863
					return access -- 863
				end -- 863
				return AgentTools.getCheckpointDiff(checkpointId) -- 864
			end -- 860
		end -- 860
	end -- 860
	return invalidArguments -- 859
end) -- 859
HttpServer:post("/agent/task/diff", function(req) -- 866
	do -- 867
		local _type_0 = type(req) -- 867
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 867
		if _tab_0 then -- 867
			local sessionId -- 867
			do -- 867
				local _obj_0 = req.body -- 867
				local _type_1 = type(_obj_0) -- 867
				if "table" == _type_1 or "userdata" == _type_1 then -- 867
					sessionId = _obj_0.sessionId -- 867
				end -- 867
			end -- 867
			local taskId -- 867
			do -- 867
				local _obj_0 = req.body -- 867
				local _type_1 = type(_obj_0) -- 867
				if "table" == _type_1 or "userdata" == _type_1 then -- 867
					taskId = _obj_0.taskId -- 867
				end -- 867
			end -- 867
			if sessionId ~= nil and taskId ~= nil then -- 867
				if not (taskId > 0) then -- 868
					return { -- 868
						success = false, -- 868
						message = "invalid taskId" -- 868
					} -- 868
				end -- 868
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 869
				if not access.success then -- 870
					return access -- 870
				end -- 870
				return AgentTools.getTaskChangeSetDiff(taskId) -- 871
			end -- 867
		end -- 867
	end -- 867
	return invalidArguments -- 866
end) -- 866
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 873
	do -- 874
		local _type_0 = type(req) -- 874
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 874
		if _tab_0 then -- 874
			local sessionId -- 874
			do -- 874
				local _obj_0 = req.body -- 874
				local _type_1 = type(_obj_0) -- 874
				if "table" == _type_1 or "userdata" == _type_1 then -- 874
					sessionId = _obj_0.sessionId -- 874
				end -- 874
			end -- 874
			local checkpointId -- 874
			do -- 874
				local _obj_0 = req.body -- 874
				local _type_1 = type(_obj_0) -- 874
				if "table" == _type_1 or "userdata" == _type_1 then -- 874
					checkpointId = _obj_0.checkpointId -- 874
				end -- 874
			end -- 874
			if sessionId ~= nil and checkpointId ~= nil then -- 874
				if not (checkpointId > 0) then -- 875
					return { -- 875
						success = false, -- 875
						message = "invalid checkpointId" -- 875
					} -- 875
				end -- 875
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 876
				if not access.success then -- 877
					return access -- 877
				end -- 877
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, access.session.projectRoot) -- 878
				if not rollbackRes.success then -- 879
					return rollbackRes -- 879
				end -- 879
				return { -- 881
					success = true, -- 881
					checkpointId = rollbackRes.checkpointId -- 882
				} -- 880
			end -- 874
		end -- 874
	end -- 874
	return invalidArguments -- 873
end) -- 873
HttpServer:post("/agent/task/rollback", function(req) -- 884
	do -- 885
		local _type_0 = type(req) -- 885
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 885
		if _tab_0 then -- 885
			local sessionId -- 885
			do -- 885
				local _obj_0 = req.body -- 885
				local _type_1 = type(_obj_0) -- 885
				if "table" == _type_1 or "userdata" == _type_1 then -- 885
					sessionId = _obj_0.sessionId -- 885
				end -- 885
			end -- 885
			local taskId -- 885
			do -- 885
				local _obj_0 = req.body -- 885
				local _type_1 = type(_obj_0) -- 885
				if "table" == _type_1 or "userdata" == _type_1 then -- 885
					taskId = _obj_0.taskId -- 885
				end -- 885
			end -- 885
			if sessionId ~= nil and taskId ~= nil then -- 885
				if not (taskId > 0) then -- 886
					return { -- 886
						success = false, -- 886
						message = "invalid taskId" -- 886
					} -- 886
				end -- 886
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 887
				if not access.success then -- 888
					return access -- 888
				end -- 888
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, access.session.projectRoot) -- 889
				if not rollbackRes.success then -- 890
					return rollbackRes -- 890
				end -- 890
				return { -- 892
					success = true, -- 892
					taskId = rollbackRes.taskId, -- 893
					checkpointId = rollbackRes.checkpointId, -- 894
					checkpointCount = rollbackRes.checkpointCount -- 895
				} -- 891
			end -- 885
		end -- 885
	end -- 885
	return invalidArguments -- 884
end) -- 884
local getSearchPath -- 897
getSearchPath = function(file) -- 897
	do -- 898
		local dir = getProjectDirFromFile(file) -- 898
		if dir then -- 898
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 899
		end -- 898
	end -- 898
	return "" -- 897
end -- 897
local getSearchFolders -- 901
getSearchFolders = function(file) -- 901
	do -- 902
		local dir = getProjectDirFromFile(file) -- 902
		if dir then -- 902
			return { -- 904
				Path(dir, "Script"), -- 904
				dir -- 905
			} -- 903
		end -- 902
	end -- 902
	return { } -- 901
end -- 901
local disabledCheckForLua = { -- 908
	"incompatible number of returns", -- 908
	"unknown", -- 909
	"cannot index", -- 910
	"module not found", -- 911
	"don't know how to resolve", -- 912
	"ContainerItem", -- 913
	"cannot resolve a type", -- 914
	"invalid key", -- 915
	"inconsistent index type", -- 916
	"cannot use operator", -- 917
	"attempting ipairs loop", -- 918
	"expects record or nominal", -- 919
	"variable is not being assigned", -- 920
	"<invalid type>", -- 921
	"<any type>", -- 922
	"using the '#' operator", -- 923
	"can't match a record", -- 924
	"redeclaration of variable", -- 925
	"cannot apply pairs", -- 926
	"not a function", -- 927
	"to%-be%-closed" -- 928
} -- 907
local yueCheck -- 930
yueCheck = function(file, content, lax) -- 930
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 931
	if isTIC80 then -- 932
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 933
	end -- 932
	local searchPath = getSearchPath(file) -- 934
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 935
	local info = { } -- 936
	local globals = { } -- 937
	for _index_0 = 1, #checkResult do -- 938
		local _des_0 = checkResult[_index_0] -- 938
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 938
		if "error" == t then -- 939
			info[#info + 1] = { -- 940
				"syntax", -- 940
				file, -- 940
				line, -- 940
				col, -- 940
				msg -- 940
			} -- 940
		elseif "global" == t then -- 941
			globals[#globals + 1] = { -- 942
				msg, -- 942
				line, -- 942
				col -- 942
			} -- 942
		end -- 939
	end -- 938
	if luaCodes then -- 943
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 944
		if success then -- 945
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 946
			if not (lintResult == "") then -- 947
				lintResult = lintResult .. "\n" -- 947
			end -- 947
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 948
		else -- 949
			for _index_0 = 1, #lintResult do -- 949
				local _des_0 = lintResult[_index_0] -- 949
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 949
				if isTIC80 and tic80APIs[name] then -- 950
					goto _continue_0 -- 950
				end -- 950
				info[#info + 1] = { -- 951
					"syntax", -- 951
					file, -- 951
					line, -- 951
					col, -- 951
					"invalid global variable" -- 951
				} -- 951
				::_continue_0:: -- 950
			end -- 949
		end -- 945
	end -- 943
	return luaCodes, info -- 952
end -- 930
local luaCheck -- 954
luaCheck = function(file, content) -- 954
	local res, err = load(content, "check") -- 955
	if not res then -- 956
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 957
		return { -- 958
			success = false, -- 958
			info = { -- 958
				{ -- 958
					"syntax", -- 958
					file, -- 958
					tonumber(line), -- 958
					0, -- 958
					msg -- 958
				} -- 958
			} -- 958
		} -- 958
	end -- 956
	local success, info = teal.checkAsync(content, file, true, "") -- 959
	if info then -- 960
		do -- 961
			local _accum_0 = { } -- 961
			local _len_0 = 1 -- 961
			for _index_0 = 1, #info do -- 961
				local item = info[_index_0] -- 961
				local useCheck = true -- 962
				if not item[5]:match("unused") then -- 963
					for _index_1 = 1, #disabledCheckForLua do -- 964
						local check = disabledCheckForLua[_index_1] -- 964
						if item[5]:match(check) then -- 965
							useCheck = false -- 966
						end -- 965
					end -- 964
				end -- 963
				if not useCheck then -- 967
					goto _continue_0 -- 967
				end -- 967
				do -- 968
					local _exp_0 = item[1] -- 968
					if "type" == _exp_0 then -- 969
						item[1] = "warning" -- 970
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 971
						goto _continue_0 -- 972
					end -- 968
				end -- 968
				_accum_0[_len_0] = item -- 973
				_len_0 = _len_0 + 1 -- 962
				::_continue_0:: -- 962
			end -- 961
			info = _accum_0 -- 961
		end -- 961
		if #info == 0 then -- 974
			info = nil -- 975
			success = true -- 976
		end -- 974
	end -- 960
	return { -- 977
		success = success, -- 977
		info = info -- 977
	} -- 977
end -- 954
local luaCheckWithLineInfo -- 979
luaCheckWithLineInfo = function(file, luaCodes) -- 979
	local res = luaCheck(file, luaCodes) -- 980
	local info = { } -- 981
	if not res.success then -- 982
		local current = 1 -- 983
		local lastLine = 1 -- 984
		local lineMap = { } -- 985
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 986
			local num = lineCode:match("--%s*(%d+)%s*$") -- 987
			if num then -- 988
				lastLine = tonumber(num) -- 989
			end -- 988
			lineMap[current] = lastLine -- 990
			current = current + 1 -- 991
		end -- 986
		local _list_0 = res.info -- 992
		for _index_0 = 1, #_list_0 do -- 992
			local item = _list_0[_index_0] -- 992
			item[3] = lineMap[item[3]] or 0 -- 993
			item[4] = 0 -- 994
			info[#info + 1] = item -- 995
		end -- 992
		return false, info -- 996
	end -- 982
	return true, info -- 997
end -- 979
local getCompiledYueLine -- 999
getCompiledYueLine = function(content, line, row, file, lax) -- 999
	local luaCodes = yueCheck(file, content, lax) -- 1000
	if not luaCodes then -- 1001
		return nil -- 1001
	end -- 1001
	local current = 1 -- 1002
	local lastLine = 1 -- 1003
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 1004
	local targetRow = nil -- 1005
	local lineMap = { } -- 1006
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 1007
		local num = lineCode:match("--%s*(%d+)%s*$") -- 1008
		if num then -- 1009
			lastLine = tonumber(num) -- 1009
		end -- 1009
		lineMap[current] = lastLine -- 1010
		if row <= lastLine and not targetRow then -- 1011
			targetRow = current -- 1012
			break -- 1013
		end -- 1011
		current = current + 1 -- 1014
	end -- 1007
	targetRow = current -- 1015
	if targetLine and targetRow then -- 1016
		return luaCodes, targetLine, targetRow, lineMap -- 1017
	else -- 1019
		return nil -- 1019
	end -- 1016
end -- 999
HttpServer:postSchedule("/check", function(req) -- 1021
	do -- 1022
		local _type_0 = type(req) -- 1022
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1022
		if _tab_0 then -- 1022
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
			if file ~= nil and content ~= nil then -- 1022
				local ext = Path:getExt(file) -- 1023
				if "tl" == ext then -- 1024
					local searchPath = getSearchPath(file) -- 1025
					do -- 1026
						local isTIC80 = CheckTIC80Code(content) -- 1026
						if isTIC80 then -- 1026
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1027
						end -- 1026
					end -- 1026
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 1028
					return { -- 1029
						success = success, -- 1029
						info = info -- 1029
					} -- 1029
				elseif "lua" == ext then -- 1030
					do -- 1031
						local isTIC80 = CheckTIC80Code(content) -- 1031
						if isTIC80 then -- 1031
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1032
						end -- 1031
					end -- 1031
					return luaCheck(file, content) -- 1033
				elseif "yue" == ext then -- 1034
					local luaCodes, info = yueCheck(file, content, false) -- 1035
					local success = luaCodes ~= nil -- 1036
					if luaCodes then -- 1037
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 1038
						do -- 1039
							local _tab_1 = { } -- 1039
							local _idx_0 = #_tab_1 + 1 -- 1039
							for _index_0 = 1, #info do -- 1039
								local _value_0 = info[_index_0] -- 1039
								_tab_1[_idx_0] = _value_0 -- 1039
								_idx_0 = _idx_0 + 1 -- 1039
							end -- 1039
							local _idx_1 = #_tab_1 + 1 -- 1039
							for _index_0 = 1, #luaInfo do -- 1039
								local _value_0 = luaInfo[_index_0] -- 1039
								_tab_1[_idx_1] = _value_0 -- 1039
								_idx_1 = _idx_1 + 1 -- 1039
							end -- 1039
							info = _tab_1 -- 1039
						end -- 1039
						success = success and luaSuccess -- 1040
					end -- 1037
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
				elseif "xml" == ext then -- 1045
					local success, result = xml.check(content) -- 1046
					if success then -- 1047
						local info -- 1048
						success, info = luaCheckWithLineInfo(file, result) -- 1048
						if #info > 0 then -- 1049
							return { -- 1050
								success = success, -- 1050
								info = info -- 1050
							} -- 1050
						else -- 1052
							return { -- 1052
								success = success -- 1052
							} -- 1052
						end -- 1049
					else -- 1054
						local info -- 1054
						do -- 1054
							local _accum_0 = { } -- 1054
							local _len_0 = 1 -- 1054
							for _index_0 = 1, #result do -- 1054
								local _des_0 = result[_index_0] -- 1054
								local row, err = _des_0[1], _des_0[2] -- 1054
								_accum_0[_len_0] = { -- 1055
									"syntax", -- 1055
									file, -- 1055
									row, -- 1055
									0, -- 1055
									err -- 1055
								} -- 1055
								_len_0 = _len_0 + 1 -- 1055
							end -- 1054
							info = _accum_0 -- 1054
						end -- 1054
						return { -- 1056
							success = false, -- 1056
							info = info -- 1056
						} -- 1056
					end -- 1047
				end -- 1024
			end -- 1022
		end -- 1022
	end -- 1022
	return { -- 1021
		success = true -- 1021
	} -- 1021
end) -- 1021
HttpServer:post("/body/parse", function(req) -- 1058
	do -- 1059
		local _type_0 = type(req) -- 1059
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1059
		if _tab_0 then -- 1059
			local file -- 1059
			do -- 1059
				local _obj_0 = req.body -- 1059
				local _type_1 = type(_obj_0) -- 1059
				if "table" == _type_1 or "userdata" == _type_1 then -- 1059
					file = _obj_0.file -- 1059
				end -- 1059
			end -- 1059
			local content -- 1059
			do -- 1059
				local _obj_0 = req.body -- 1059
				local _type_1 = type(_obj_0) -- 1059
				if "table" == _type_1 or "userdata" == _type_1 then -- 1059
					content = _obj_0.content -- 1059
				end -- 1059
			end -- 1059
			if file ~= nil and content ~= nil then -- 1059
				if not (file:sub(-6) == ".b.lua") then -- 1060
					return { -- 1061
						success = false, -- 1061
						phase = "request", -- 1061
						message = "only .b.lua files can be converted" -- 1061
					} -- 1061
				end -- 1060
				local loader, err = load("_ENV = {}\n" .. content) -- 1062
				if not loader then -- 1063
					return { -- 1064
						success = false, -- 1064
						phase = "parse", -- 1064
						message = tostring(err) -- 1064
					} -- 1064
				end -- 1063
				local ok, data = pcall(loader) -- 1065
				if not ok then -- 1066
					return { -- 1067
						success = false, -- 1067
						phase = "execute", -- 1067
						message = tostring(data) -- 1067
					} -- 1067
				end -- 1066
				if not ("table" == type(data) and data[1] == "Array") then -- 1068
					return { -- 1069
						success = false, -- 1069
						phase = "validate", -- 1069
						message = "body lua root must be {\"Array\", ...}" -- 1069
					} -- 1069
				end -- 1068
				local text, jsonErr = json.encode(data, false, true) -- 1070
				if not text then -- 1071
					return { -- 1072
						success = false, -- 1072
						phase = "encode", -- 1072
						message = tostring(jsonErr) -- 1072
					} -- 1072
				end -- 1071
				return { -- 1073
					success = true, -- 1073
					json = text -- 1073
				} -- 1073
			end -- 1059
		end -- 1059
	end -- 1059
	return { -- 1058
		success = false, -- 1058
		phase = "request", -- 1058
		message = "invalid request" -- 1058
	} -- 1058
end) -- 1058
local updateInferedDesc -- 1075
updateInferedDesc = function(infered) -- 1075
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1076
		return -- 1076
	end -- 1076
	local key, row = infered.key, infered.row -- 1077
	local codes = Content:loadAsync(key) -- 1078
	if codes then -- 1078
		local comments = { } -- 1079
		local line = 0 -- 1080
		local skipping = false -- 1081
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1082
			line = line + 1 -- 1083
			if line >= row then -- 1084
				break -- 1084
			end -- 1084
			if lineCode:match("^%s*%-%- @") then -- 1085
				skipping = true -- 1086
				goto _continue_0 -- 1087
			end -- 1085
			local result = lineCode:match("^%s*%-%- (.+)") -- 1088
			if result then -- 1088
				if not skipping then -- 1089
					comments[#comments + 1] = result -- 1089
				end -- 1089
			elseif #comments > 0 then -- 1090
				comments = { } -- 1091
				skipping = false -- 1092
			end -- 1088
			::_continue_0:: -- 1083
		end -- 1082
		infered.doc = table.concat(comments, "\n") -- 1093
	end -- 1078
end -- 1075
HttpServer:postSchedule("/infer", function(req) -- 1095
	do -- 1096
		local _type_0 = type(req) -- 1096
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1096
		if _tab_0 then -- 1096
			local lang -- 1096
			do -- 1096
				local _obj_0 = req.body -- 1096
				local _type_1 = type(_obj_0) -- 1096
				if "table" == _type_1 or "userdata" == _type_1 then -- 1096
					lang = _obj_0.lang -- 1096
				end -- 1096
			end -- 1096
			local file -- 1096
			do -- 1096
				local _obj_0 = req.body -- 1096
				local _type_1 = type(_obj_0) -- 1096
				if "table" == _type_1 or "userdata" == _type_1 then -- 1096
					file = _obj_0.file -- 1096
				end -- 1096
			end -- 1096
			local content -- 1096
			do -- 1096
				local _obj_0 = req.body -- 1096
				local _type_1 = type(_obj_0) -- 1096
				if "table" == _type_1 or "userdata" == _type_1 then -- 1096
					content = _obj_0.content -- 1096
				end -- 1096
			end -- 1096
			local line -- 1096
			do -- 1096
				local _obj_0 = req.body -- 1096
				local _type_1 = type(_obj_0) -- 1096
				if "table" == _type_1 or "userdata" == _type_1 then -- 1096
					line = _obj_0.line -- 1096
				end -- 1096
			end -- 1096
			local row -- 1096
			do -- 1096
				local _obj_0 = req.body -- 1096
				local _type_1 = type(_obj_0) -- 1096
				if "table" == _type_1 or "userdata" == _type_1 then -- 1096
					row = _obj_0.row -- 1096
				end -- 1096
			end -- 1096
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1096
				local searchPath = getSearchPath(file) -- 1097
				if "tl" == lang or "lua" == lang then -- 1098
					if CheckTIC80Code(content) then -- 1099
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1100
					end -- 1099
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1101
					if (infered ~= nil) then -- 1102
						updateInferedDesc(infered) -- 1103
						return { -- 1104
							success = true, -- 1104
							infered = infered -- 1104
						} -- 1104
					end -- 1102
				elseif "yue" == lang then -- 1105
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1106
					if not luaCodes then -- 1107
						return { -- 1107
							success = false -- 1107
						} -- 1107
					end -- 1107
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1108
					if (infered ~= nil) then -- 1109
						local col -- 1110
						file, row, col = infered.file, infered.row, infered.col -- 1110
						if file == "" and row > 0 and col > 0 then -- 1111
							infered.row = lineMap[row] or 0 -- 1112
							infered.col = 0 -- 1113
						end -- 1111
						updateInferedDesc(infered) -- 1114
						return { -- 1115
							success = true, -- 1115
							infered = infered -- 1115
						} -- 1115
					end -- 1109
				end -- 1098
			end -- 1096
		end -- 1096
	end -- 1096
	return { -- 1095
		success = false -- 1095
	} -- 1095
end) -- 1095
local _anon_func_3 = function(doc) -- 1176
	local _accum_0 = { } -- 1176
	local _len_0 = 1 -- 1176
	local _list_0 = doc.params -- 1176
	for _index_0 = 1, #_list_0 do -- 1176
		local param = _list_0[_index_0] -- 1176
		_accum_0[_len_0] = param.name -- 1176
		_len_0 = _len_0 + 1 -- 1176
	end -- 1176
	return _accum_0 -- 1176
end -- 1176
local getParamDocs -- 1117
getParamDocs = function(signatures) -- 1117
	if not (signatures and #signatures > 0) then -- 1118
		return nil -- 1118
	end -- 1118
	local docs = { } -- 1119
	do -- 1120
		local codes = Content:loadAsync(signatures[1].file) -- 1120
		if codes then -- 1120
			local comments = { } -- 1121
			local params = { } -- 1122
			local line = 0 -- 1123
			local returnType = nil -- 1124
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1125
				line = line + 1 -- 1126
				local needBreak = true -- 1127
				for i, _des_0 in ipairs(signatures) do -- 1128
					local row = _des_0.row -- 1128
					if line >= row and not (docs[i] ~= nil) then -- 1129
						if #comments > 0 or #params > 0 or returnType then -- 1130
							docs[i] = { -- 1132
								doc = table.concat(comments, "  \n"), -- 1132
								returnType = returnType -- 1133
							} -- 1131
							if #params > 0 then -- 1135
								docs[i].params = params -- 1135
							end -- 1135
						else -- 1137
							docs[i] = false -- 1137
						end -- 1130
					end -- 1129
					if not docs[i] then -- 1138
						needBreak = false -- 1138
					end -- 1138
				end -- 1128
				if needBreak then -- 1139
					break -- 1139
				end -- 1139
				local result = lineCode:match("%s*%-%- (.+)") -- 1140
				if result then -- 1140
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1141
					if not name then -- 1142
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1143
					end -- 1142
					if name then -- 1144
						local pname = name -- 1145
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1146
							pname = pname .. "?" -- 1146
						end -- 1146
						params[#params + 1] = { -- 1148
							name = tostring(pname) .. ": " .. tostring(typ), -- 1148
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1149
						} -- 1147
					else -- 1152
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1152
						if typ then -- 1152
							if returnType then -- 1153
								returnType = returnType .. ", " .. typ -- 1154
							else -- 1156
								returnType = typ -- 1156
							end -- 1153
							result = result:gsub("@return", "**return:**") -- 1157
						end -- 1152
						comments[#comments + 1] = result -- 1158
					end -- 1144
				elseif #comments > 0 then -- 1159
					comments = { } -- 1160
					params = { } -- 1161
					returnType = nil -- 1162
				end -- 1140
			end -- 1125
		end -- 1120
	end -- 1120
	local results = { } -- 1163
	for i, signature in ipairs(signatures) do -- 1164
		local item = { -- 1166
			desc = signature.desc, -- 1166
			doc = "", -- 1167
			file = signature.file, -- 1168
			row = signature.row, -- 1169
			col = signature.col -- 1170
		} -- 1165
		do -- 1172
			local doc = docs[i] -- 1172
			if doc then -- 1172
				item.doc = doc.doc -- 1173
				if doc.params then -- 1174
					item.params = doc.params -- 1175
					item.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1176
				elseif doc.returnType then -- 1177
					item.desc = "function()" -- 1178
				end -- 1174
				if doc.returnType then -- 1179
					item.desc = item.desc .. ": " .. tostring(doc.returnType) -- 1179
				end -- 1179
			end -- 1172
		end -- 1172
		results[#results + 1] = item -- 1180
	end -- 1164
	return results -- 1181
end -- 1117
HttpServer:postSchedule("/signature", function(req) -- 1183
	do -- 1184
		local _type_0 = type(req) -- 1184
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1184
		if _tab_0 then -- 1184
			local lang -- 1184
			do -- 1184
				local _obj_0 = req.body -- 1184
				local _type_1 = type(_obj_0) -- 1184
				if "table" == _type_1 or "userdata" == _type_1 then -- 1184
					lang = _obj_0.lang -- 1184
				end -- 1184
			end -- 1184
			local file -- 1184
			do -- 1184
				local _obj_0 = req.body -- 1184
				local _type_1 = type(_obj_0) -- 1184
				if "table" == _type_1 or "userdata" == _type_1 then -- 1184
					file = _obj_0.file -- 1184
				end -- 1184
			end -- 1184
			local content -- 1184
			do -- 1184
				local _obj_0 = req.body -- 1184
				local _type_1 = type(_obj_0) -- 1184
				if "table" == _type_1 or "userdata" == _type_1 then -- 1184
					content = _obj_0.content -- 1184
				end -- 1184
			end -- 1184
			local line -- 1184
			do -- 1184
				local _obj_0 = req.body -- 1184
				local _type_1 = type(_obj_0) -- 1184
				if "table" == _type_1 or "userdata" == _type_1 then -- 1184
					line = _obj_0.line -- 1184
				end -- 1184
			end -- 1184
			local row -- 1184
			do -- 1184
				local _obj_0 = req.body -- 1184
				local _type_1 = type(_obj_0) -- 1184
				if "table" == _type_1 or "userdata" == _type_1 then -- 1184
					row = _obj_0.row -- 1184
				end -- 1184
			end -- 1184
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1184
				local searchPath = getSearchPath(file) -- 1185
				if "tl" == lang or "lua" == lang then -- 1186
					if CheckTIC80Code(content) then -- 1187
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1188
					end -- 1187
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1189
					if signatures then -- 1189
						signatures = getParamDocs(signatures) -- 1190
						if signatures then -- 1190
							return { -- 1191
								success = true, -- 1191
								signatures = signatures -- 1191
							} -- 1191
						end -- 1190
					end -- 1189
				elseif "yue" == lang then -- 1192
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1193
					if not luaCodes then -- 1194
						return { -- 1194
							success = false -- 1194
						} -- 1194
					end -- 1194
					do -- 1195
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1195
						if chainOp then -- 1195
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1196
							if withVar then -- 1196
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1197
							end -- 1196
						end -- 1195
					end -- 1195
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1198
					if signatures then -- 1198
						signatures = getParamDocs(signatures) -- 1199
						if signatures then -- 1199
							return { -- 1200
								success = true, -- 1200
								signatures = signatures -- 1200
							} -- 1200
						end -- 1199
					else -- 1201
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1201
						if signatures then -- 1201
							signatures = getParamDocs(signatures) -- 1202
							if signatures then -- 1202
								return { -- 1203
									success = true, -- 1203
									signatures = signatures -- 1203
								} -- 1203
							end -- 1202
						end -- 1201
					end -- 1198
				end -- 1186
			end -- 1184
		end -- 1184
	end -- 1184
	return { -- 1183
		success = false -- 1183
	} -- 1183
end) -- 1183
local luaKeywords = { -- 1206
	'and', -- 1206
	'break', -- 1207
	'do', -- 1208
	'else', -- 1209
	'elseif', -- 1210
	'end', -- 1211
	'false', -- 1212
	'for', -- 1213
	'function', -- 1214
	'goto', -- 1215
	'if', -- 1216
	'in', -- 1217
	'local', -- 1218
	'nil', -- 1219
	'not', -- 1220
	'or', -- 1221
	'repeat', -- 1222
	'return', -- 1223
	'then', -- 1224
	'true', -- 1225
	'until', -- 1226
	'while' -- 1227
} -- 1205
local tealKeywords = { -- 1231
	'record', -- 1231
	'as', -- 1232
	'is', -- 1233
	'type', -- 1234
	'embed', -- 1235
	'enum', -- 1236
	'global', -- 1237
	'any', -- 1238
	'boolean', -- 1239
	'integer', -- 1240
	'number', -- 1241
	'string', -- 1242
	'thread' -- 1243
} -- 1230
local yueKeywords = { -- 1247
	"and", -- 1247
	"break", -- 1248
	"do", -- 1249
	"else", -- 1250
	"elseif", -- 1251
	"false", -- 1252
	"for", -- 1253
	"goto", -- 1254
	"if", -- 1255
	"in", -- 1256
	"local", -- 1257
	"nil", -- 1258
	"not", -- 1259
	"or", -- 1260
	"repeat", -- 1261
	"return", -- 1262
	"then", -- 1263
	"true", -- 1264
	"until", -- 1265
	"while", -- 1266
	"as", -- 1267
	"class", -- 1268
	"continue", -- 1269
	"export", -- 1270
	"extends", -- 1271
	"from", -- 1272
	"global", -- 1273
	"import", -- 1274
	"macro", -- 1275
	"switch", -- 1276
	"try", -- 1277
	"unless", -- 1278
	"using", -- 1279
	"when", -- 1280
	"with" -- 1281
} -- 1246
local _anon_func_4 = function(f) -- 1317
	local _val_0 = Path:getExt(f) -- 1317
	return "ttf" == _val_0 or "otf" == _val_0 -- 1317
end -- 1317
local _anon_func_5 = function(suggestions) -- 1343
	local _tbl_0 = { } -- 1343
	for _index_0 = 1, #suggestions do -- 1343
		local item = suggestions[_index_0] -- 1343
		_tbl_0[item[1] .. item[2]] = item -- 1343
	end -- 1343
	return _tbl_0 -- 1343
end -- 1343
HttpServer:postSchedule("/complete", function(req) -- 1284
	do -- 1285
		local _type_0 = type(req) -- 1285
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1285
		if _tab_0 then -- 1285
			local lang -- 1285
			do -- 1285
				local _obj_0 = req.body -- 1285
				local _type_1 = type(_obj_0) -- 1285
				if "table" == _type_1 or "userdata" == _type_1 then -- 1285
					lang = _obj_0.lang -- 1285
				end -- 1285
			end -- 1285
			local file -- 1285
			do -- 1285
				local _obj_0 = req.body -- 1285
				local _type_1 = type(_obj_0) -- 1285
				if "table" == _type_1 or "userdata" == _type_1 then -- 1285
					file = _obj_0.file -- 1285
				end -- 1285
			end -- 1285
			local content -- 1285
			do -- 1285
				local _obj_0 = req.body -- 1285
				local _type_1 = type(_obj_0) -- 1285
				if "table" == _type_1 or "userdata" == _type_1 then -- 1285
					content = _obj_0.content -- 1285
				end -- 1285
			end -- 1285
			local line -- 1285
			do -- 1285
				local _obj_0 = req.body -- 1285
				local _type_1 = type(_obj_0) -- 1285
				if "table" == _type_1 or "userdata" == _type_1 then -- 1285
					line = _obj_0.line -- 1285
				end -- 1285
			end -- 1285
			local row -- 1285
			do -- 1285
				local _obj_0 = req.body -- 1285
				local _type_1 = type(_obj_0) -- 1285
				if "table" == _type_1 or "userdata" == _type_1 then -- 1285
					row = _obj_0.row -- 1285
				end -- 1285
			end -- 1285
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1285
				local searchPath = getSearchPath(file) -- 1286
				repeat -- 1287
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1288
					if lang == "yue" then -- 1289
						if not item then -- 1290
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1290
						end -- 1290
						if not item then -- 1291
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1291
						end -- 1291
					end -- 1289
					local searchType = nil -- 1292
					if not item then -- 1293
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1294
						if lang == "yue" then -- 1295
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1296
						end -- 1295
						if (item ~= nil) then -- 1297
							searchType = "Image" -- 1297
						end -- 1297
					end -- 1293
					if not item then -- 1298
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1299
						if lang == "yue" then -- 1300
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1301
						end -- 1300
						if (item ~= nil) then -- 1302
							searchType = "Font" -- 1302
						end -- 1302
					end -- 1298
					if not item then -- 1303
						break -- 1303
					end -- 1303
					local searchPaths = Content.searchPaths -- 1304
					local _list_0 = getSearchFolders(file) -- 1305
					for _index_0 = 1, #_list_0 do -- 1305
						local folder = _list_0[_index_0] -- 1305
						searchPaths[#searchPaths + 1] = folder -- 1306
					end -- 1305
					if searchType then -- 1307
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1307
					end -- 1307
					local tokens -- 1308
					do -- 1308
						local _accum_0 = { } -- 1308
						local _len_0 = 1 -- 1308
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1308
							_accum_0[_len_0] = mod -- 1308
							_len_0 = _len_0 + 1 -- 1308
						end -- 1308
						tokens = _accum_0 -- 1308
					end -- 1308
					local suggestions = { } -- 1309
					for _index_0 = 1, #searchPaths do -- 1310
						local path = searchPaths[_index_0] -- 1310
						local sPath = Path(path, table.unpack(tokens)) -- 1311
						if not Content:exist(sPath) then -- 1312
							goto _continue_0 -- 1312
						end -- 1312
						if searchType == "Font" then -- 1313
							local fontPath = Path(sPath, "Font") -- 1314
							if Content:exist(fontPath) then -- 1315
								local _list_1 = Content:getFiles(fontPath) -- 1316
								for _index_1 = 1, #_list_1 do -- 1316
									local f = _list_1[_index_1] -- 1316
									if _anon_func_4(f) then -- 1317
										if "." == f:sub(1, 1) then -- 1318
											goto _continue_1 -- 1318
										end -- 1318
										suggestions[#suggestions + 1] = { -- 1319
											Path:getName(f), -- 1319
											"font", -- 1319
											"field" -- 1319
										} -- 1319
									end -- 1317
									::_continue_1:: -- 1317
								end -- 1316
							end -- 1315
						end -- 1313
						local _list_1 = Content:getFiles(sPath) -- 1320
						for _index_1 = 1, #_list_1 do -- 1320
							local f = _list_1[_index_1] -- 1320
							if "Image" == searchType then -- 1321
								do -- 1322
									local _exp_0 = Path:getExt(f) -- 1322
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1322
										if "." == f:sub(1, 1) then -- 1323
											goto _continue_2 -- 1323
										end -- 1323
										suggestions[#suggestions + 1] = { -- 1324
											f, -- 1324
											"image", -- 1324
											"field" -- 1324
										} -- 1324
									end -- 1322
								end -- 1322
								goto _continue_2 -- 1325
							elseif "Font" == searchType then -- 1326
								do -- 1327
									local _exp_0 = Path:getExt(f) -- 1327
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1327
										if "." == f:sub(1, 1) then -- 1328
											goto _continue_2 -- 1328
										end -- 1328
										suggestions[#suggestions + 1] = { -- 1329
											f, -- 1329
											"font", -- 1329
											"field" -- 1329
										} -- 1329
									end -- 1327
								end -- 1327
								goto _continue_2 -- 1330
							end -- 1321
							local _exp_0 = Path:getExt(f) -- 1331
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1331
								local name = Path:getName(f) -- 1332
								if "d" == Path:getExt(name) then -- 1333
									goto _continue_2 -- 1333
								end -- 1333
								if "." == name:sub(1, 1) then -- 1334
									goto _continue_2 -- 1334
								end -- 1334
								suggestions[#suggestions + 1] = { -- 1335
									name, -- 1335
									"module", -- 1335
									"field" -- 1335
								} -- 1335
							end -- 1331
							::_continue_2:: -- 1321
						end -- 1320
						local _list_2 = Content:getDirs(sPath) -- 1336
						for _index_1 = 1, #_list_2 do -- 1336
							local dir = _list_2[_index_1] -- 1336
							if "." == dir:sub(1, 1) then -- 1337
								goto _continue_3 -- 1337
							end -- 1337
							suggestions[#suggestions + 1] = { -- 1338
								dir, -- 1338
								"folder", -- 1338
								"variable" -- 1338
							} -- 1338
							::_continue_3:: -- 1337
						end -- 1336
						::_continue_0:: -- 1311
					end -- 1310
					if item == "" and not searchType then -- 1339
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1340
						for _index_0 = 1, #_list_1 do -- 1340
							local _des_0 = _list_1[_index_0] -- 1340
							local name = _des_0[1] -- 1340
							suggestions[#suggestions + 1] = { -- 1341
								name, -- 1341
								"dora module", -- 1341
								"function" -- 1341
							} -- 1341
						end -- 1340
					end -- 1339
					if #suggestions > 0 then -- 1342
						do -- 1343
							local _accum_0 = { } -- 1343
							local _len_0 = 1 -- 1343
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1343
								_accum_0[_len_0] = v -- 1343
								_len_0 = _len_0 + 1 -- 1343
							end -- 1343
							suggestions = _accum_0 -- 1343
						end -- 1343
						return { -- 1344
							success = true, -- 1344
							suggestions = suggestions -- 1344
						} -- 1344
					else -- 1346
						return { -- 1346
							success = false -- 1346
						} -- 1346
					end -- 1342
				until true -- 1287
				if "tl" == lang or "lua" == lang then -- 1348
					do -- 1349
						local isTIC80 = CheckTIC80Code(content) -- 1349
						if isTIC80 then -- 1349
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1350
						end -- 1349
					end -- 1349
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1351
					if not line:match("[%.:]$") then -- 1352
						local checkSet -- 1353
						do -- 1353
							local _tbl_0 = { } -- 1353
							for _index_0 = 1, #suggestions do -- 1353
								local _des_0 = suggestions[_index_0] -- 1353
								local name = _des_0[1] -- 1353
								_tbl_0[name] = true -- 1353
							end -- 1353
							checkSet = _tbl_0 -- 1353
						end -- 1353
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1354
						for _index_0 = 1, #_list_0 do -- 1354
							local item = _list_0[_index_0] -- 1354
							if not checkSet[item[1]] then -- 1355
								suggestions[#suggestions + 1] = item -- 1355
							end -- 1355
						end -- 1354
						for _index_0 = 1, #luaKeywords do -- 1356
							local word = luaKeywords[_index_0] -- 1356
							suggestions[#suggestions + 1] = { -- 1357
								word, -- 1357
								"keyword", -- 1357
								"keyword" -- 1357
							} -- 1357
						end -- 1356
						if lang == "tl" then -- 1358
							for _index_0 = 1, #tealKeywords do -- 1359
								local word = tealKeywords[_index_0] -- 1359
								suggestions[#suggestions + 1] = { -- 1360
									word, -- 1360
									"keyword", -- 1360
									"keyword" -- 1360
								} -- 1360
							end -- 1359
						end -- 1358
					end -- 1352
					if #suggestions > 0 then -- 1361
						return { -- 1362
							success = true, -- 1362
							suggestions = suggestions -- 1362
						} -- 1362
					end -- 1361
				elseif "yue" == lang then -- 1363
					local suggestions = { } -- 1364
					local gotGlobals = false -- 1365
					do -- 1366
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1366
						if luaCodes then -- 1366
							gotGlobals = true -- 1367
							do -- 1368
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1368
								if chainOp then -- 1368
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1369
									if not withVar then -- 1370
										return { -- 1370
											success = false -- 1370
										} -- 1370
									end -- 1370
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1371
								elseif line:match("^([%.\\])$") then -- 1372
									return { -- 1373
										success = false -- 1373
									} -- 1373
								end -- 1368
							end -- 1368
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1374
							for _index_0 = 1, #_list_0 do -- 1374
								local item = _list_0[_index_0] -- 1374
								suggestions[#suggestions + 1] = item -- 1374
							end -- 1374
							if #suggestions == 0 then -- 1375
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1376
								for _index_0 = 1, #_list_1 do -- 1376
									local item = _list_1[_index_0] -- 1376
									suggestions[#suggestions + 1] = item -- 1376
								end -- 1376
							end -- 1375
						end -- 1366
					end -- 1366
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1377
						local checkSet -- 1378
						do -- 1378
							local _tbl_0 = { } -- 1378
							for _index_0 = 1, #suggestions do -- 1378
								local _des_0 = suggestions[_index_0] -- 1378
								local name = _des_0[1] -- 1378
								_tbl_0[name] = true -- 1378
							end -- 1378
							checkSet = _tbl_0 -- 1378
						end -- 1378
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1379
						for _index_0 = 1, #_list_0 do -- 1379
							local item = _list_0[_index_0] -- 1379
							if not checkSet[item[1]] then -- 1380
								suggestions[#suggestions + 1] = item -- 1380
							end -- 1380
						end -- 1379
						if not gotGlobals then -- 1381
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1382
							for _index_0 = 1, #_list_1 do -- 1382
								local item = _list_1[_index_0] -- 1382
								if not checkSet[item[1]] then -- 1383
									suggestions[#suggestions + 1] = item -- 1383
								end -- 1383
							end -- 1382
						end -- 1381
						for _index_0 = 1, #yueKeywords do -- 1384
							local word = yueKeywords[_index_0] -- 1384
							if not checkSet[word] then -- 1385
								suggestions[#suggestions + 1] = { -- 1386
									word, -- 1386
									"keyword", -- 1386
									"keyword" -- 1386
								} -- 1386
							end -- 1385
						end -- 1384
					end -- 1377
					if #suggestions > 0 then -- 1387
						return { -- 1388
							success = true, -- 1388
							suggestions = suggestions -- 1388
						} -- 1388
					end -- 1387
				elseif "xml" == lang then -- 1389
					local items = xml.complete(content) -- 1390
					if #items > 0 then -- 1391
						local suggestions -- 1392
						do -- 1392
							local _accum_0 = { } -- 1392
							local _len_0 = 1 -- 1392
							for _index_0 = 1, #items do -- 1392
								local _des_0 = items[_index_0] -- 1392
								local label, insertText = _des_0[1], _des_0[2] -- 1392
								_accum_0[_len_0] = { -- 1393
									label, -- 1393
									insertText, -- 1393
									"field" -- 1393
								} -- 1393
								_len_0 = _len_0 + 1 -- 1393
							end -- 1392
							suggestions = _accum_0 -- 1392
						end -- 1392
						return { -- 1394
							success = true, -- 1394
							suggestions = suggestions -- 1394
						} -- 1394
					end -- 1391
				end -- 1348
			end -- 1285
		end -- 1285
	end -- 1285
	return { -- 1284
		success = false -- 1284
	} -- 1284
end) -- 1284
local getUploadFilename -- 1396
getUploadFilename = function(req, multipartFilename) -- 1396
	local filename = req.params.name -- 1397
	if not (type(filename) == "string" and filename ~= "") then -- 1398
		filename = multipartFilename -- 1398
	end -- 1398
	if not (type(filename) == "string" and filename ~= "") then -- 1399
		return -- 1399
	end -- 1399
	if filename:sub(1, 1) == "/" or filename:sub(-1) == "/" or filename:find("//", 1, true) or filename:find("\\", 1, true) or filename:find(":", 1, true) or filename:find("\0", 1, true) then -- 1402
		return -- 1402
	end -- 1402
	local parts -- 1403
	do -- 1403
		local _accum_0 = { } -- 1403
		local _len_0 = 1 -- 1403
		for part in filename:gmatch("[^/]+") do -- 1403
			_accum_0[_len_0] = part -- 1403
			_len_0 = _len_0 + 1 -- 1403
		end -- 1403
		parts = _accum_0 -- 1403
	end -- 1403
	if #parts == 0 then -- 1404
		return -- 1404
	end -- 1404
	for _index_0 = 1, #parts do -- 1405
		local part = parts[_index_0] -- 1405
		if part == "." or part == ".." or part == "" then -- 1406
			return -- 1406
		end -- 1406
	end -- 1405
	return filename -- 1407
end -- 1396
HttpServer:upload("/upload", function(req, multipartFilename) -- 1411
	do -- 1412
		local _type_0 = type(req) -- 1412
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1412
		if _tab_0 then -- 1412
			local path -- 1412
			do -- 1412
				local _obj_0 = req.params -- 1412
				local _type_1 = type(_obj_0) -- 1412
				if "table" == _type_1 or "userdata" == _type_1 then -- 1412
					path = _obj_0.path -- 1412
				end -- 1412
			end -- 1412
			if path ~= nil then -- 1412
				local filename = getUploadFilename(req, multipartFilename) -- 1413
				if filename then -- 1413
					local uploadPath = Path(Content.writablePath, ".upload") -- 1414
					if not Content:exist(uploadPath) then -- 1415
						Content:mkdir(uploadPath) -- 1416
					end -- 1415
					local targetPath = Path(uploadPath, filename) -- 1417
					Content:mkdir(Path:getPath(targetPath)) -- 1418
					return targetPath -- 1419
				end -- 1413
			end -- 1412
		end -- 1412
	end -- 1412
	return nil -- 1411
end, function(req, file) -- 1420
	do -- 1421
		local _type_0 = type(req) -- 1421
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1421
		if _tab_0 then -- 1421
			local path -- 1421
			do -- 1421
				local _obj_0 = req.params -- 1421
				local _type_1 = type(_obj_0) -- 1421
				if "table" == _type_1 or "userdata" == _type_1 then -- 1421
					path = _obj_0.path -- 1421
				end -- 1421
			end -- 1421
			if path ~= nil then -- 1421
				path = Path(Content.writablePath, path) -- 1422
				if Content:exist(path) then -- 1423
					local uploadPath = Path(Content.writablePath, ".upload") -- 1424
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1425
					Content:mkdir(Path:getPath(targetPath)) -- 1426
					if Content:move(file, targetPath) then -- 1427
						return true -- 1428
					end -- 1427
				end -- 1423
			end -- 1421
		end -- 1421
	end -- 1421
	return false -- 1420
end) -- 1409
HttpServer:post("/list", function(req) -- 1431
	do -- 1432
		local _type_0 = type(req) -- 1432
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1432
		if _tab_0 then -- 1432
			local path -- 1432
			do -- 1432
				local _obj_0 = req.body -- 1432
				local _type_1 = type(_obj_0) -- 1432
				if "table" == _type_1 or "userdata" == _type_1 then -- 1432
					path = _obj_0.path -- 1432
				end -- 1432
			end -- 1432
			if path ~= nil then -- 1432
				if Content:exist(path) then -- 1433
					local files = { } -- 1434
					local visitAssets -- 1435
					visitAssets = function(path, folder) -- 1435
						local dirs = Content:getDirs(path) -- 1436
						for _index_0 = 1, #dirs do -- 1437
							local dir = dirs[_index_0] -- 1437
							if dir:match("^%.") or dir == "node_modules" then -- 1438
								goto _continue_0 -- 1438
							end -- 1438
							local current -- 1439
							if folder == "" then -- 1439
								current = dir -- 1440
							else -- 1442
								current = Path(folder, dir) -- 1442
							end -- 1439
							files[#files + 1] = current -- 1443
							visitAssets(Path(path, dir), current) -- 1444
							::_continue_0:: -- 1438
						end -- 1437
						local fs = Content:getFiles(path) -- 1445
						for _index_0 = 1, #fs do -- 1446
							local f = fs[_index_0] -- 1446
							if (".DS_Store" == f) then -- 1447
								goto _continue_1 -- 1448
							end -- 1447
							if folder == "" then -- 1449
								files[#files + 1] = f -- 1450
							else -- 1452
								files[#files + 1] = Path(folder, f) -- 1452
							end -- 1449
							::_continue_1:: -- 1447
						end -- 1446
					end -- 1435
					visitAssets(path, "") -- 1453
					if #files == 0 then -- 1454
						files = nil -- 1454
					end -- 1454
					return { -- 1455
						success = true, -- 1455
						files = files -- 1455
					} -- 1455
				end -- 1433
			end -- 1432
		end -- 1432
	end -- 1432
	return { -- 1431
		success = false -- 1431
	} -- 1431
end) -- 1431
HttpServer:post("/info", function(req) -- 1457
	local Entry = require("Script.Dev.Entry") -- 1458
	local config = Entry.getConfig() -- 1459
	do -- 1460
		local _type_0 = type(req) -- 1460
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1460
		if _tab_0 then -- 1460
			local webIDETourCompleted -- 1460
			do -- 1460
				local _obj_0 = req.body -- 1460
				local _type_1 = type(_obj_0) -- 1460
				if "table" == _type_1 or "userdata" == _type_1 then -- 1460
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1460
				end -- 1460
			end -- 1460
			if webIDETourCompleted ~= nil then -- 1460
				config.webIDETourCompleted = webIDETourCompleted == true -- 1461
			end -- 1460
		end -- 1460
	end -- 1460
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1462
	local engineDev = Entry.getEngineDev() -- 1463
	Entry.connectWebIDE() -- 1464
	return { -- 1466
		platform = App.platform, -- 1466
		locale = App.locale, -- 1467
		version = App.version, -- 1468
		engineDev = engineDev, -- 1469
		webProfiler = webProfiler, -- 1470
		drawerWidth = drawerWidth, -- 1471
		webIDETourCompleted = webIDETourCompleted == true -- 1472
	} -- 1465
end) -- 1457
local ensureLLMConfigTable -- 1474
ensureLLMConfigTable = function() -- 1474
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1475
	if columns and #columns > 0 then -- 1476
		local expected = { -- 1478
			id = true, -- 1478
			name = true, -- 1479
			url = true, -- 1480
			model = true, -- 1481
			api_key = true, -- 1482
			context_window = true, -- 1483
			temperature = true, -- 1484
			max_tokens = true, -- 1485
			reasoning_effort = true, -- 1486
			custom_options = true, -- 1487
			supports_function_calling = true, -- 1488
			active = true, -- 1489
			created_at = true, -- 1490
			updated_at = true -- 1491
		} -- 1477
		local existing = { } -- 1493
		local valid = true -- 1494
		for _index_0 = 1, #columns do -- 1495
			local row = columns[_index_0] -- 1495
			local columnName = tostring(row[2]) -- 1496
			existing[columnName] = true -- 1497
			if not expected[columnName] then -- 1498
				valid = false -- 1499
				break -- 1500
			end -- 1498
		end -- 1495
		if valid then -- 1501
			if not existing.context_window then -- 1502
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1503
			end -- 1502
			if not existing.temperature then -- 1504
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1505
			end -- 1504
			if not existing.max_tokens then -- 1506
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 64000") -- 1507
			end -- 1506
			if not existing.reasoning_effort then -- 1508
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1509
			end -- 1508
			if not existing.custom_options then -- 1510
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1511
			end -- 1510
			if not existing.supports_function_calling then -- 1512
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1513
			end -- 1512
		else -- 1515
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1515
		end -- 1501
	end -- 1476
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
	]]) -- 1516
	return require("Agent.LLMConfigMigration").upgradeLLMConfig() -- 1535
end -- 1474
local normalizeContextWindow -- 1537
normalizeContextWindow = function(value) -- 1537
	local contextWindow = tonumber(value) -- 1538
	if contextWindow == nil or contextWindow < 64000 then -- 1539
		return 64000 -- 1540
	end -- 1539
	return math.max(64000, math.floor(contextWindow)) -- 1541
end -- 1537
local normalizeTemperature -- 1543
normalizeTemperature = function(value) -- 1543
	local temperature = tonumber(value) -- 1544
	if temperature == nil then -- 1545
		return 0.1 -- 1546
	end -- 1545
	return math.max(0, math.min(2, temperature)) -- 1547
end -- 1543
local normalizeMaxTokens -- 1549
normalizeMaxTokens = function(value) -- 1549
	local maxTokens = tonumber(value) -- 1550
	if maxTokens == nil or maxTokens < 1 then -- 1551
		return 64000 -- 1552
	end -- 1551
	return math.max(1, math.floor(maxTokens)) -- 1553
end -- 1549
local normalizeReasoningEffort -- 1555
normalizeReasoningEffort = function(value) -- 1555
	if value == nil then -- 1556
		return "" -- 1557
	end -- 1556
	local effort = tostring(value) -- 1558
	return effort:match("^%s*(.-)%s*$") or "" -- 1559
end -- 1555
local normalizeCustomOptions -- 1561
normalizeCustomOptions = function(value) -- 1561
	if value == nil then -- 1562
		return "" -- 1563
	end -- 1562
	local options = tostring(value) -- 1564
	options = options:match("^%s*(.-)%s*$") or "" -- 1565
	return options -- 1566
end -- 1561
local validateCustomOptions -- 1568
validateCustomOptions = function(value) -- 1568
	local options = normalizeCustomOptions(value) -- 1569
	if options == "" then -- 1570
		return true -- 1570
	end -- 1570
	if not options:match("^%s*{") then -- 1571
		return false -- 1571
	end -- 1571
	local decoded = json.decode(options) -- 1572
	return type(decoded) == "table" -- 1573
end -- 1568
HttpServer:post("/llm/list", function() -- 1575
	ensureLLMConfigTable() -- 1576
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1577
	local items -- 1581
	if rows and #rows > 0 then -- 1581
		local _accum_0 = { } -- 1582
		local _len_0 = 1 -- 1582
		for _index_0 = 1, #rows do -- 1582
			local _des_0 = rows[_index_0] -- 1582
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1582
			_accum_0[_len_0] = { -- 1583
				id = id, -- 1583
				name = name, -- 1583
				url = url, -- 1583
				model = model, -- 1583
				key = key, -- 1583
				contextWindow = normalizeContextWindow(contextWindow), -- 1583
				temperature = normalizeTemperature(temperature), -- 1583
				maxTokens = normalizeMaxTokens(maxTokens), -- 1583
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1583
				customOptions = normalizeCustomOptions(customOptions), -- 1583
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1583
			} -- 1583
			_len_0 = _len_0 + 1 -- 1583
		end -- 1582
		items = _accum_0 -- 1581
	end -- 1581
	return { -- 1584
		success = true, -- 1584
		items = items -- 1584
	} -- 1584
end) -- 1575
HttpServer:post("/llm/create", function(req) -- 1586
	ensureLLMConfigTable() -- 1587
	do -- 1588
		local _type_0 = type(req) -- 1588
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1588
		if _tab_0 then -- 1588
			local body = req.body -- 1588
			if body ~= nil then -- 1588
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1589
				local now = os.time() -- 1590
				if name == nil or url == nil or model == nil or key == nil then -- 1591
					return invalidArguments -- 1592
				end -- 1591
				contextWindow = normalizeContextWindow(contextWindow) -- 1593
				temperature = normalizeTemperature(temperature) -- 1594
				maxTokens = normalizeMaxTokens(maxTokens) -- 1595
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1596
				customOptions = normalizeCustomOptions(customOptions) -- 1597
				if not validateCustomOptions(customOptions) then -- 1598
					return { -- 1598
						success = false, -- 1598
						message = "customOptions must be a JSON object" -- 1598
					} -- 1598
				end -- 1598
				if supportsFunctionCalling == false then -- 1599
					supportsFunctionCalling = 0 -- 1599
				else -- 1599
					supportsFunctionCalling = 1 -- 1599
				end -- 1599
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1606
					tostring(name), -- 1606
					tostring(url), -- 1607
					tostring(model), -- 1608
					tostring(key), -- 1609
					contextWindow, -- 1610
					temperature, -- 1611
					maxTokens, -- 1612
					reasoningEffort, -- 1613
					customOptions, -- 1614
					supportsFunctionCalling, -- 1615
					1, -- 1616
					now, -- 1617
					now -- 1618
				}) -- 1600
				return { -- 1620
					success = affected >= 0 -- 1620
				} -- 1620
			end -- 1588
		end -- 1588
	end -- 1588
	return invalidArguments -- 1586
end) -- 1586
HttpServer:post("/llm/update", function(req) -- 1622
	ensureLLMConfigTable() -- 1623
	do -- 1624
		local _type_0 = type(req) -- 1624
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1624
		if _tab_0 then -- 1624
			local body = req.body -- 1624
			if body ~= nil then -- 1624
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1625
				local now = os.time() -- 1626
				id = tonumber(id) -- 1627
				if id == nil then -- 1628
					return invalidArguments -- 1628
				end -- 1628
				contextWindow = normalizeContextWindow(contextWindow) -- 1629
				temperature = normalizeTemperature(temperature) -- 1630
				maxTokens = normalizeMaxTokens(maxTokens) -- 1631
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1632
				customOptions = normalizeCustomOptions(customOptions) -- 1633
				if not validateCustomOptions(customOptions) then -- 1634
					return { -- 1634
						success = false, -- 1634
						message = "customOptions must be a JSON object" -- 1634
					} -- 1634
				end -- 1634
				if supportsFunctionCalling == false then -- 1635
					supportsFunctionCalling = 0 -- 1635
				else -- 1635
					supportsFunctionCalling = 1 -- 1635
				end -- 1635
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1640
					tostring(name), -- 1640
					tostring(url), -- 1641
					tostring(model), -- 1642
					tostring(key), -- 1643
					contextWindow, -- 1644
					temperature, -- 1645
					maxTokens, -- 1646
					reasoningEffort, -- 1647
					customOptions, -- 1648
					supportsFunctionCalling, -- 1649
					now, -- 1650
					id -- 1651
				}) -- 1636
				return { -- 1653
					success = affected >= 0 -- 1653
				} -- 1653
			end -- 1624
		end -- 1624
	end -- 1624
	return invalidArguments -- 1622
end) -- 1622
HttpServer:post("/llm/delete", function(req) -- 1655
	ensureLLMConfigTable() -- 1656
	do -- 1657
		local _type_0 = type(req) -- 1657
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1657
		if _tab_0 then -- 1657
			local id -- 1657
			do -- 1657
				local _obj_0 = req.body -- 1657
				local _type_1 = type(_obj_0) -- 1657
				if "table" == _type_1 or "userdata" == _type_1 then -- 1657
					id = _obj_0.id -- 1657
				end -- 1657
			end -- 1657
			if id ~= nil then -- 1657
				id = tonumber(id) -- 1658
				if id == nil then -- 1659
					return invalidArguments -- 1659
				end -- 1659
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1660
					id -- 1660
				}) -- 1660
				return { -- 1661
					success = affected >= 0 -- 1661
				} -- 1661
			end -- 1657
		end -- 1657
	end -- 1657
	return invalidArguments -- 1655
end) -- 1655
HttpServer:post("/local-agent/list", function() -- 1663
	return { -- 1664
		success = true, -- 1664
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1664
		items = AgentLocalAgent.listConfigs() -- 1664
	} -- 1664
end) -- 1663
HttpServer:post("/local-agent/save", function(req) -- 1666
	do -- 1667
		local _type_0 = type(req) -- 1667
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1667
		if _tab_0 then -- 1667
			local body = req.body -- 1667
			if body ~= nil then -- 1667
				return AgentLocalAgent.saveConfig(body) -- 1668
			end -- 1667
		end -- 1667
	end -- 1667
	return invalidArguments -- 1666
end) -- 1666
HttpServer:post("/local-agent/delete", function(req) -- 1670
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
				return AgentLocalAgent.deleteConfig(id) -- 1672
			end -- 1671
		end -- 1671
	end -- 1671
	return invalidArguments -- 1670
end) -- 1670
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1674
	do -- 1675
		local _type_0 = type(req) -- 1675
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1675
		if _tab_0 then -- 1675
			local id -- 1675
			do -- 1675
				local _obj_0 = req.body -- 1675
				local _type_1 = type(_obj_0) -- 1675
				if "table" == _type_1 or "userdata" == _type_1 then -- 1675
					id = _obj_0.id -- 1675
				end -- 1675
			end -- 1675
			if id ~= nil then -- 1675
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1676
			end -- 1675
		end -- 1675
	end -- 1675
	return invalidArguments -- 1674
end) -- 1674
HttpServer:post("/stat", function(req) -- 1678
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
				if not Content:exist(path) then -- 1680
					return { -- 1681
						success = false, -- 1681
						message = "target not existed" -- 1681
					} -- 1681
				end -- 1680
				if Content:isdir(path) then -- 1682
					return { -- 1683
						success = false, -- 1683
						message = "failed to stat a directory" -- 1683
					} -- 1683
				end -- 1682
				local size, isBinary = Content:getAttr(path) -- 1684
				if size then -- 1684
					return { -- 1685
						success = true, -- 1685
						size = size, -- 1685
						isBinary = isBinary -- 1685
					} -- 1685
				end -- 1684
			end -- 1679
		end -- 1679
	end -- 1679
	return { -- 1678
		success = false, -- 1678
		message = "failed to stat" -- 1678
	} -- 1678
end) -- 1678
HttpServer:post("/new", function(req) -- 1687
	do -- 1688
		local _type_0 = type(req) -- 1688
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1688
		if _tab_0 then -- 1688
			local path -- 1688
			do -- 1688
				local _obj_0 = req.body -- 1688
				local _type_1 = type(_obj_0) -- 1688
				if "table" == _type_1 or "userdata" == _type_1 then -- 1688
					path = _obj_0.path -- 1688
				end -- 1688
			end -- 1688
			local content -- 1688
			do -- 1688
				local _obj_0 = req.body -- 1688
				local _type_1 = type(_obj_0) -- 1688
				if "table" == _type_1 or "userdata" == _type_1 then -- 1688
					content = _obj_0.content -- 1688
				end -- 1688
			end -- 1688
			local folder -- 1688
			do -- 1688
				local _obj_0 = req.body -- 1688
				local _type_1 = type(_obj_0) -- 1688
				if "table" == _type_1 or "userdata" == _type_1 then -- 1688
					folder = _obj_0.folder -- 1688
				end -- 1688
			end -- 1688
			if path ~= nil and content ~= nil and folder ~= nil then -- 1688
				if Content:exist(path) then -- 1689
					return { -- 1690
						success = false, -- 1690
						message = "TargetExisted" -- 1690
					} -- 1690
				end -- 1689
				local parent = Path:getPath(path) -- 1691
				local files = Content:getFiles(parent) -- 1692
				if folder then -- 1693
					local name = Path:getFilename(path):lower() -- 1694
					for _index_0 = 1, #files do -- 1695
						local file = files[_index_0] -- 1695
						if name == Path:getFilename(file):lower() then -- 1696
							return { -- 1697
								success = false, -- 1697
								message = "TargetExisted" -- 1697
							} -- 1697
						end -- 1696
					end -- 1695
					if Content:mkdir(path) then -- 1698
						return { -- 1699
							success = true -- 1699
						} -- 1699
					end -- 1698
				else -- 1701
					local name = Path:getName(path):lower() -- 1701
					for _index_0 = 1, #files do -- 1702
						local file = files[_index_0] -- 1702
						if name == Path:getName(file):lower() then -- 1703
							local ext = Path:getExt(file) -- 1704
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1705
								goto _continue_0 -- 1706
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1707
								goto _continue_0 -- 1708
							end -- 1705
							return { -- 1709
								success = false, -- 1709
								message = "SourceExisted" -- 1709
							} -- 1709
						end -- 1703
						::_continue_0:: -- 1703
					end -- 1702
					if Content:save(path, content) then -- 1710
						return { -- 1711
							success = true -- 1711
						} -- 1711
					end -- 1710
				end -- 1693
			end -- 1688
		end -- 1688
	end -- 1688
	return { -- 1687
		success = false, -- 1687
		message = "Failed" -- 1687
	} -- 1687
end) -- 1687
local deleteAsset -- 1713
deleteAsset = function(path) -- 1713
	if not Content:exist(path) then -- 1714
		return false -- 1714
	end -- 1714
	local projectRoot -- 1715
	if Content:isdir(path) and isProjectRootDir(path) then -- 1715
		projectRoot = path -- 1715
	else -- 1715
		projectRoot = nil -- 1715
	end -- 1715
	local parent = Path:getPath(path) -- 1716
	local files = Content:getFiles(parent) -- 1717
	local name = Path:getName(path):lower() -- 1718
	local ext = Path:getExt(path) -- 1719
	for _index_0 = 1, #files do -- 1720
		local file = files[_index_0] -- 1720
		if name == Path:getName(file):lower() then -- 1721
			local _exp_0 = Path:getExt(file) -- 1722
			if "tl" == _exp_0 then -- 1722
				if ("vs" == ext) then -- 1722
					Content:remove(Path(parent, file)) -- 1723
				end -- 1722
			elseif "lua" == _exp_0 then -- 1724
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1724
					Content:remove(Path(parent, file)) -- 1725
				end -- 1724
			end -- 1722
		end -- 1721
	end -- 1720
	if Content:remove(path) then -- 1726
		if projectRoot then -- 1727
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1728
		end -- 1727
		return true -- 1729
	end -- 1726
	return false -- 1730
end -- 1713
local moveAsset -- 1732
moveAsset = function(old, new) -- 1732
	if not (Content:exist(old) and not Content:exist(new)) then -- 1733
		return false -- 1733
	end -- 1733
	local renamedDir = Content:isdir(old) -- 1734
	local parent = Path:getPath(new) -- 1735
	local files = Content:getFiles(parent) -- 1736
	if renamedDir then -- 1737
		local name = Path:getFilename(new):lower() -- 1738
		for _index_0 = 1, #files do -- 1739
			local file = files[_index_0] -- 1739
			if name == Path:getFilename(file):lower() then -- 1740
				return false -- 1741
			end -- 1740
		end -- 1739
	else -- 1743
		local name = Path:getName(new):lower() -- 1743
		local ext = Path:getExt(new) -- 1744
		for _index_0 = 1, #files do -- 1745
			local file = files[_index_0] -- 1745
			if name == Path:getName(file):lower() then -- 1746
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1747
					goto _continue_0 -- 1748
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1749
					goto _continue_0 -- 1750
				end -- 1747
				return false -- 1751
			end -- 1746
			::_continue_0:: -- 1746
		end -- 1745
	end -- 1737
	if not Content:move(old, new) then -- 1752
		return false -- 1752
	end -- 1752
	if renamedDir then -- 1753
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1754
	end -- 1753
	local newParent = Path:getPath(new) -- 1755
	parent = Path:getPath(old) -- 1756
	files = Content:getFiles(parent) -- 1757
	local newName = Path:getName(new) -- 1758
	local oldName = Path:getName(old) -- 1759
	local name = oldName:lower() -- 1760
	local ext = Path:getExt(old) -- 1761
	for _index_0 = 1, #files do -- 1762
		local file = files[_index_0] -- 1762
		if name == Path:getName(file):lower() then -- 1763
			local _exp_0 = Path:getExt(file) -- 1764
			if "tl" == _exp_0 then -- 1764
				if ("vs" == ext) then -- 1764
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1765
				end -- 1764
			elseif "lua" == _exp_0 then -- 1766
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1766
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1767
				end -- 1766
			end -- 1764
		end -- 1763
	end -- 1762
	return true -- 1768
end -- 1732
HttpServer:post("/delete", function(req) -- 1770
	do -- 1771
		local _type_0 = type(req) -- 1771
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1771
		if _tab_0 then -- 1771
			local path -- 1771
			do -- 1771
				local _obj_0 = req.body -- 1771
				local _type_1 = type(_obj_0) -- 1771
				if "table" == _type_1 or "userdata" == _type_1 then -- 1771
					path = _obj_0.path -- 1771
				end -- 1771
			end -- 1771
			if path ~= nil then -- 1771
				if deleteAsset(path) then -- 1772
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
HttpServer:post("/rename", function(req) -- 1774
	do -- 1775
		local _type_0 = type(req) -- 1775
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1775
		if _tab_0 then -- 1775
			local old -- 1775
			do -- 1775
				local _obj_0 = req.body -- 1775
				local _type_1 = type(_obj_0) -- 1775
				if "table" == _type_1 or "userdata" == _type_1 then -- 1775
					old = _obj_0.old -- 1775
				end -- 1775
			end -- 1775
			local new -- 1775
			do -- 1775
				local _obj_0 = req.body -- 1775
				local _type_1 = type(_obj_0) -- 1775
				if "table" == _type_1 or "userdata" == _type_1 then -- 1775
					new = _obj_0.new -- 1775
				end -- 1775
			end -- 1775
			if old ~= nil and new ~= nil then -- 1775
				if moveAsset(old, new) then -- 1776
					return { -- 1776
						success = true -- 1776
					} -- 1776
				end -- 1776
			end -- 1775
		end -- 1775
	end -- 1775
	return { -- 1774
		success = false -- 1774
	} -- 1774
end) -- 1774
local normalizeAssetPaths -- 1778
normalizeAssetPaths = function(paths) -- 1778
	if not (type(paths) == "table") then -- 1779
		return nil -- 1779
	end -- 1779
	local unique = { } -- 1780
	local candidates = { } -- 1781
	for _index_0 = 1, #paths do -- 1782
		local path = paths[_index_0] -- 1782
		if not (type(path) == "string") then -- 1783
			return nil -- 1783
		end -- 1783
		local relative = relativeToRoot(path, Content.writablePath) -- 1784
		if relative == nil or relative == "" or not Content:exist(path) then -- 1785
			return nil -- 1785
		end -- 1785
		if not unique[path] then -- 1786
			unique[path] = true -- 1787
			candidates[#candidates + 1] = path -- 1788
		end -- 1786
	end -- 1782
	table.sort(candidates, function(a, b) -- 1789
		return #a < #b -- 1789
	end) -- 1789
	local result = { } -- 1790
	for _index_0 = 1, #candidates do -- 1791
		local path = candidates[_index_0] -- 1791
		local contained = false -- 1792
		for _index_1 = 1, #result do -- 1793
			local parent = result[_index_1] -- 1793
			if relativeToRoot(path, parent) ~= nil then -- 1794
				contained = true -- 1795
				break -- 1796
			end -- 1794
		end -- 1793
		if not contained then -- 1797
			result[#result + 1] = path -- 1797
		end -- 1797
	end -- 1791
	return result -- 1798
end -- 1778
HttpServer:postSchedule("/assets/batch", function(req) -- 1800
	do -- 1801
		local _type_0 = type(req) -- 1801
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1801
		if _tab_0 then -- 1801
			local operation -- 1801
			do -- 1801
				local _obj_0 = req.body -- 1801
				local _type_1 = type(_obj_0) -- 1801
				if "table" == _type_1 or "userdata" == _type_1 then -- 1801
					operation = _obj_0.operation -- 1801
				end -- 1801
			end -- 1801
			local sources -- 1801
			do -- 1801
				local _obj_0 = req.body -- 1801
				local _type_1 = type(_obj_0) -- 1801
				if "table" == _type_1 or "userdata" == _type_1 then -- 1801
					sources = _obj_0.sources -- 1801
				end -- 1801
			end -- 1801
			if operation ~= nil and sources ~= nil then -- 1801
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1802
					return { -- 1802
						success = false, -- 1802
						message = "invalid operation" -- 1802
					} -- 1802
				end -- 1802
				sources = normalizeAssetPaths(sources) -- 1803
				if not (sources and #sources > 0) then -- 1804
					return { -- 1804
						success = false, -- 1804
						message = "invalid sources" -- 1804
					} -- 1804
				end -- 1804
				local target = req.body.target -- 1805
				local destinations = { } -- 1806
				if operation ~= "delete" then -- 1807
					if not (type(target) == "string") then -- 1808
						return { -- 1808
							success = false, -- 1808
							message = "invalid target" -- 1808
						} -- 1808
					end -- 1808
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1809
					if targetRelative == nil then -- 1810
						return { -- 1810
							success = false, -- 1810
							message = "invalid target" -- 1810
						} -- 1810
					end -- 1810
					if not (Content:exist(target) and Content:isdir(target)) then -- 1811
						return { -- 1811
							success = false, -- 1811
							message = "invalid target" -- 1811
						} -- 1811
					end -- 1811
					for _index_0 = 1, #sources do -- 1812
						local source = sources[_index_0] -- 1812
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1813
							return { -- 1814
								success = false, -- 1814
								message = "target inside source" -- 1814
							} -- 1814
						end -- 1813
						local destination = Path(target, Path:getFilename(source)) -- 1815
						if Content:exist(destination) then -- 1816
							return { -- 1816
								success = false, -- 1816
								message = "target existed" -- 1816
							} -- 1816
						end -- 1816
						if destinations[destination] then -- 1817
							return { -- 1817
								success = false, -- 1817
								message = "duplicate target" -- 1817
							} -- 1817
						end -- 1817
						destinations[destination] = true -- 1818
					end -- 1812
				end -- 1807
				local changes = { } -- 1819
				local affectedSet = { } -- 1820
				local affectedDirectories = { } -- 1821
				local addAffected -- 1822
				addAffected = function(dir) -- 1822
					if affectedSet[dir] then -- 1823
						return -- 1823
					end -- 1823
					affectedSet[dir] = true -- 1824
					affectedDirectories[#affectedDirectories + 1] = dir -- 1825
				end -- 1822
				if operation ~= "delete" then -- 1826
					addAffected(target) -- 1826
				end -- 1826
				for _index_0 = 1, #sources do -- 1827
					local source = sources[_index_0] -- 1827
					addAffected(Path:getPath(source)) -- 1828
					if operation == "delete" then -- 1829
						if not deleteAsset(source) then -- 1830
							return { -- 1830
								success = false, -- 1830
								message = "delete failed", -- 1830
								changes = changes, -- 1830
								affectedDirectories = affectedDirectories -- 1830
							} -- 1830
						end -- 1830
						changes[#changes + 1] = { -- 1831
							old = source -- 1831
						} -- 1831
					else -- 1833
						local destination = Path(target, Path:getFilename(source)) -- 1833
						local ok -- 1834
						if operation == "copy" then -- 1834
							ok = Content:copyAsync(source, destination) -- 1835
						else -- 1837
							ok = moveAsset(source, destination) -- 1837
						end -- 1834
						if not ok then -- 1838
							return { -- 1838
								success = false, -- 1838
								message = operation .. " failed", -- 1838
								changes = changes, -- 1838
								affectedDirectories = affectedDirectories -- 1838
							} -- 1838
						end -- 1838
						changes[#changes + 1] = { -- 1839
							old = source, -- 1839
							new = destination -- 1839
						} -- 1839
					end -- 1829
				end -- 1827
				return { -- 1840
					success = true, -- 1840
					changes = changes, -- 1840
					affectedDirectories = affectedDirectories -- 1840
				} -- 1840
			end -- 1801
		end -- 1801
	end -- 1801
	return { -- 1800
		success = false, -- 1800
		message = "invalid request" -- 1800
	} -- 1800
end) -- 1800
local withProjectSearchPaths -- 1842
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1842
	local fallbackPaths = { } -- 1843
	local addFallback -- 1844
	addFallback = function(dir) -- 1844
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1844
			fallbackPaths[#fallbackPaths + 1] = dir -- 1844
		end -- 1844
	end -- 1844
	if projectRoot and projectRoot ~= "" then -- 1845
		addFallback(Path(projectRoot, "Script")) -- 1846
		addFallback(projectRoot) -- 1847
	end -- 1845
	if projFile then -- 1848
		local projDir = getProjectDirFromFile(projFile) -- 1849
		if projDir then -- 1849
			addFallback(Path(projDir, "Script")) -- 1850
			addFallback(projDir) -- 1851
		else -- 1853
			addFallback(Path:getPath(projFile)) -- 1853
		end -- 1849
	end -- 1848
	if not (#fallbackPaths > 0) then -- 1854
		return fn() -- 1854
	end -- 1854
	local searchPaths = Content.searchPaths -- 1855
	for _index_0 = 1, #fallbackPaths do -- 1856
		local dir = fallbackPaths[_index_0] -- 1856
		Content:addSearchPath(dir) -- 1856
	end -- 1856
	local _ <close> = setmetatable({ }, { -- 1857
		__close = function() -- 1857
			Content.searchPaths = searchPaths -- 1857
		end -- 1857
	}) -- 1857
	return fn() -- 1858
end -- 1842
HttpServer:post("/exist", function(req) -- 1859
	do -- 1860
		local _type_0 = type(req) -- 1860
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1860
		if _tab_0 then -- 1860
			local file -- 1860
			do -- 1860
				local _obj_0 = req.body -- 1860
				local _type_1 = type(_obj_0) -- 1860
				if "table" == _type_1 or "userdata" == _type_1 then -- 1860
					file = _obj_0.file -- 1860
				end -- 1860
			end -- 1860
			if file ~= nil then -- 1860
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1861
					return { -- 1862
						success = Content:exist(file) -- 1862
					} -- 1862
				end) -- 1861
			end -- 1860
		end -- 1860
	end -- 1860
	return { -- 1859
		success = false -- 1859
	} -- 1859
end) -- 1859
HttpServer:postSchedule("/read", function(req) -- 1863
	do -- 1864
		local _type_0 = type(req) -- 1864
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1864
		if _tab_0 then -- 1864
			local path -- 1864
			do -- 1864
				local _obj_0 = req.body -- 1864
				local _type_1 = type(_obj_0) -- 1864
				if "table" == _type_1 or "userdata" == _type_1 then -- 1864
					path = _obj_0.path -- 1864
				end -- 1864
			end -- 1864
			if path ~= nil then -- 1864
				local readFile -- 1865
				readFile = function() -- 1865
					if Content:exist(path) and not Content:isdir(path) then -- 1866
						local content = Content:loadAsync(path) -- 1867
						if content then -- 1867
							return { -- 1868
								content = content, -- 1868
								success = true, -- 1868
								fullPath = Content:getFullPath(path) -- 1868
							} -- 1868
						end -- 1867
					end -- 1866
					return nil -- 1865
				end -- 1865
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1869
				if result then -- 1869
					return result -- 1869
				end -- 1869
			end -- 1864
		end -- 1864
	end -- 1864
	return { -- 1863
		success = false -- 1863
	} -- 1863
end) -- 1863
local agentDocLanguage -- 1871
agentDocLanguage = function(language) -- 1871
	if language == "zh-Hans" then -- 1872
		return "zh" -- 1872
	else -- 1872
		return "en" -- 1872
	end -- 1872
end -- 1871
HttpServer:postSchedule("/doc/search", function(req) -- 1874
	local body = req.body or { } -- 1875
	local language = body.docLanguage -- 1876
	if not (("en" == language or "zh-Hans" == language)) then -- 1877
		return { -- 1877
			success = false, -- 1877
			message = "unsupported doc language" -- 1877
		} -- 1877
	end -- 1877
	local docType = body.docType -- 1878
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1879
		return { -- 1879
			success = false, -- 1879
			message = "unsupported doc type" -- 1879
		} -- 1879
	end -- 1879
	local codeLanguage = body.programmingLanguage -- 1880
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1881
		return { -- 1881
			success = false, -- 1881
			message = "unsupported programming language" -- 1881
		} -- 1881
	end -- 1881
	if not body.pattern then -- 1882
		return { -- 1882
			success = false, -- 1882
			message = "missing pattern" -- 1882
		} -- 1882
	end -- 1882
	local result = nil -- 1883
	AgentTools.searchDoraDocHttp({ -- 1885
		pattern = body.pattern, -- 1885
		docLanguage = agentDocLanguage(language), -- 1886
		docType = docType, -- 1887
		programmingLanguage = codeLanguage, -- 1888
		limit = body.limit, -- 1889
		useRegex = body.useRegex, -- 1890
		caseSensitive = body.caseSensitive, -- 1891
		includeContent = body.includeContent, -- 1892
		contentWindow = body.contentWindow -- 1893
	}, function(res) -- 1894
		result = res -- 1895
	end) -- 1884
	wait(function() -- 1896
		return result ~= nil -- 1896
	end) -- 1896
	if result and result.success then -- 1897
		result.docLanguage = language -- 1898
	end -- 1897
	if result then -- 1899
		return result -- 1900
	else -- 1902
		return { -- 1902
			success = false, -- 1902
			message = "doc search failed" -- 1902
		} -- 1902
	end -- 1899
	return { -- 1874
		success = false, -- 1874
		message = "invalid call" -- 1874
	} -- 1874
end) -- 1874
HttpServer:postSchedule("/doc/read", function(req) -- 1904
	local body = req.body or { } -- 1905
	local language = body.docLanguage -- 1906
	if not (("en" == language or "zh-Hans" == language)) then -- 1907
		return { -- 1907
			success = false, -- 1907
			message = "unsupported doc language" -- 1907
		} -- 1907
	end -- 1907
	if not body.file then -- 1908
		return { -- 1908
			success = false, -- 1908
			message = "missing file" -- 1908
		} -- 1908
	end -- 1908
	local result = AgentTools.readDoraDoc({ -- 1910
		docLanguage = agentDocLanguage(language), -- 1910
		file = body.file, -- 1911
		startLine = body.startLine, -- 1912
		endLine = body.endLine -- 1913
	}) -- 1909
	if result and result.success then -- 1914
		result.docLanguage = language -- 1915
	end -- 1914
	return result -- 1916
end) -- 1904
HttpServer:get("/read-sync", function(req) -- 1918
	do -- 1919
		local _type_0 = type(req) -- 1919
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1919
		if _tab_0 then -- 1919
			local params = req.params -- 1919
			if params ~= nil then -- 1919
				local path = params.path -- 1920
				if not (type(path) == "string" and path ~= "") then -- 1921
					return { -- 1921
						success = false, -- 1921
						message = "invalid path" -- 1921
					} -- 1921
				end -- 1921
				local exts -- 1922
				if params.exts then -- 1922
					local _accum_0 = { } -- 1923
					local _len_0 = 1 -- 1923
					for ext in params.exts:gmatch("[^|]*") do -- 1923
						_accum_0[_len_0] = ext -- 1923
						_len_0 = _len_0 + 1 -- 1923
					end -- 1923
					exts = _accum_0 -- 1923
				else -- 1924
					exts = { -- 1924
						"" -- 1924
					} -- 1924
				end -- 1922
				local readFileAt -- 1925
				readFileAt = function(targetPath) -- 1925
					if Content:exist(targetPath) then -- 1926
						local content = Content:load(targetPath) -- 1927
						if content then -- 1927
							return { -- 1928
								content = content, -- 1928
								success = true, -- 1928
								fullPath = Content:getFullPath(targetPath) -- 1928
							} -- 1928
						end -- 1927
					end -- 1926
					return nil -- 1925
				end -- 1925
				local readFile -- 1929
				readFile = function(fallbackPaths) -- 1929
					for _index_0 = 1, #exts do -- 1930
						local ext = exts[_index_0] -- 1930
						local targetPath = path .. ext -- 1931
						if not Content:isAbsolutePath(targetPath) then -- 1932
							for _index_1 = 1, #fallbackPaths do -- 1933
								local fallback = fallbackPaths[_index_1] -- 1933
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1934
								if fallbackResult then -- 1934
									return fallbackResult -- 1935
								end -- 1934
							end -- 1933
						end -- 1932
						local fileResult = readFileAt(targetPath) -- 1936
						if fileResult then -- 1936
							return fileResult -- 1937
						end -- 1936
					end -- 1930
					return nil -- 1929
				end -- 1929
				local fallbackPaths = { } -- 1938
				local fallbackCandidates = { } -- 1939
				do -- 1940
					local projectRoot = req.params.projectRoot -- 1940
					if projectRoot then -- 1940
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1941
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1942
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1943
						end -- 1941
					end -- 1940
				end -- 1940
				do -- 1944
					local projFile = req.params.projFile -- 1944
					if projFile then -- 1944
						local projDir = getProjectDirFromFile(projFile) -- 1945
						if projDir then -- 1945
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1946
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1947
						else -- 1949
							projDir = Path:getPath(projFile) -- 1949
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1950
						end -- 1945
					end -- 1944
				end -- 1944
				for _index_0 = 1, #fallbackCandidates do -- 1951
					local dir = fallbackCandidates[_index_0] -- 1951
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1952
						local exists = false -- 1953
						for _index_1 = 1, #fallbackPaths do -- 1954
							local fallback = fallbackPaths[_index_1] -- 1954
							if fallback == dir then -- 1955
								exists = true -- 1956
								break -- 1957
							end -- 1955
						end -- 1954
						if not exists then -- 1958
							fallbackPaths[#fallbackPaths + 1] = dir -- 1958
						end -- 1958
					end -- 1952
				end -- 1951
				local readResult = readFile(fallbackPaths) -- 1959
				if readResult then -- 1959
					return readResult -- 1960
				end -- 1959
			end -- 1919
		end -- 1919
	end -- 1919
	return { -- 1918
		success = false -- 1918
	} -- 1918
end) -- 1918
local addGeneratedSourceHeader -- 1962
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 1962
	if preserveTIC80 == nil then -- 1962
		preserveTIC80 = false -- 1962
	end -- 1962
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 1963
	if preserveTIC80 then -- 1964
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 1965
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 1966
		end -- 1965
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 1967
	end -- 1964
	return tostring(header) .. "\n" .. tostring(codes) -- 1968
end -- 1962
local compileFileAsync -- 1970
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1970
	if projectRoot == nil then -- 1970
		projectRoot = nil -- 1970
	end -- 1970
	local file = inputFile -- 1971
	local searchPath -- 1972
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1972
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1973
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1977
	elseif not Content:isAbsolutePath(inputFile) then -- 1978
		searchPath = "" -- 1979
	else -- 1980
		local dir = getProjectDirFromFile(inputFile) -- 1980
		if dir then -- 1980
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1981
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1985
		else -- 1987
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1987
			searchPath = "" -- 1990
		end -- 1980
	end -- 1972
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1991
	local yueext = yue.options.extension -- 1992
	local resultCodes = nil -- 1993
	local resultError = nil -- 1994
	do -- 1995
		local _exp_0 = Path:getExt(inputFile) -- 1995
		if yueext == _exp_0 then -- 1995
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1996
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1997
				if not codes then -- 1998
					resultError = err -- 1999
					return -- 2000
				end -- 1998
				local extraGlobal -- 2001
				if isTIC80 then -- 2001
					extraGlobal = tic80APIs -- 2001
				else -- 2001
					extraGlobal = nil -- 2001
				end -- 2001
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 2002
				if not success then -- 2003
					resultError = message -- 2004
					return -- 2005
				end -- 2003
				if codes == "" then -- 2006
					resultCodes = "" -- 2007
					return nil -- 2008
				end -- 2006
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 2009
				return resultCodes -- 2010
			end, function(success) -- 1997
				if not success then -- 2011
					Content:remove(outputFile) -- 2012
					if resultCodes == nil then -- 2013
						resultCodes = false -- 2014
					end -- 2013
				end -- 2011
			end) -- 1997
		elseif "tl" == _exp_0 then -- 2015
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 2016
			if isTIC80 then -- 2017
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2018
			end -- 2017
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2019
			if codes then -- 2019
				if isTIC80 then -- 2020
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2021
				end -- 2020
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2022
				Content:saveAsync(outputFile, resultCodes) -- 2023
			else -- 2025
				Content:remove(outputFile) -- 2025
				resultCodes = false -- 2026
				resultError = err -- 2027
			end -- 2019
		elseif "xml" == _exp_0 then -- 2028
			local codes, err = xml.tolua(sourceCodes) -- 2029
			if codes then -- 2029
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2030
				Content:saveAsync(outputFile, resultCodes) -- 2031
			else -- 2033
				Content:remove(outputFile) -- 2033
				resultCodes = false -- 2034
				resultError = err -- 2035
			end -- 2029
		end -- 1995
	end -- 1995
	wait(function() -- 2036
		return resultCodes ~= nil -- 2036
	end) -- 2036
	if resultCodes then -- 2037
		return resultCodes -- 2038
	else -- 2040
		return nil, resultError -- 2040
	end -- 2037
	return nil -- 1970
end -- 1970
HttpServer:postSchedule("/write", function(req) -- 2042
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2043
	local buildSucceeded = false -- 2044
	local _ <close> = setmetatable({ }, { -- 2045
		__close = function() -- 2045
			return finishUpdate(buildSucceeded) -- 2045
		end -- 2045
	}) -- 2045
	do -- 2046
		local _type_0 = type(req) -- 2046
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2046
		if _tab_0 then -- 2046
			local path -- 2046
			do -- 2046
				local _obj_0 = req.body -- 2046
				local _type_1 = type(_obj_0) -- 2046
				if "table" == _type_1 or "userdata" == _type_1 then -- 2046
					path = _obj_0.path -- 2046
				end -- 2046
			end -- 2046
			local content -- 2046
			do -- 2046
				local _obj_0 = req.body -- 2046
				local _type_1 = type(_obj_0) -- 2046
				if "table" == _type_1 or "userdata" == _type_1 then -- 2046
					content = _obj_0.content -- 2046
				end -- 2046
			end -- 2046
			if path ~= nil and content ~= nil then -- 2046
				if Content:saveAsync(path, content) then -- 2047
					do -- 2048
						local _exp_0 = Path:getExt(path) -- 2048
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2048
							if '' == Path:getExt(Path:getName(path)) then -- 2049
								local resultCodes = compileFileAsync(path, content) -- 2050
								buildSucceeded = resultCodes ~= nil -- 2051
								return { -- 2052
									success = true, -- 2052
									resultCodes = resultCodes -- 2052
								} -- 2052
							end -- 2049
						end -- 2048
					end -- 2048
					buildSucceeded = true -- 2053
					return { -- 2054
						success = true -- 2054
					} -- 2054
				end -- 2047
			end -- 2046
		end -- 2046
	end -- 2046
	return { -- 2042
		success = false -- 2042
	} -- 2042
end) -- 2042
local getWaProjectDirFromFile = nil -- 2056
HttpServer:postSchedule("/build", function(req) -- 2058
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2059
	local buildSucceeded = false -- 2060
	local _ <close> = setmetatable({ }, { -- 2061
		__close = function() -- 2061
			return finishUpdate(buildSucceeded) -- 2061
		end -- 2061
	}) -- 2061
	do -- 2062
		local _type_0 = type(req) -- 2062
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2062
		if _tab_0 then -- 2062
			local path -- 2062
			do -- 2062
				local _obj_0 = req.body -- 2062
				local _type_1 = type(_obj_0) -- 2062
				if "table" == _type_1 or "userdata" == _type_1 then -- 2062
					path = _obj_0.path -- 2062
				end -- 2062
			end -- 2062
			if path ~= nil then -- 2062
				local projectRoot = req.body.projectRoot -- 2063
				if Content:isdir(path) then -- 2064
					local projDir = getWaProjectDirFromFile(path) -- 2065
					if projDir then -- 2065
						local message = Wasm:buildWaAsync(projDir) -- 2066
						if message == "" then -- 2067
							return { -- 2068
								success = true -- 2068
							} -- 2068
						else -- 2070
							return { -- 2070
								success = false, -- 2070
								message = message -- 2070
							} -- 2070
						end -- 2067
					end -- 2065
				end -- 2064
				local _exp_0 = Path:getExt(path) -- 2071
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2072
					if '' == Path:getExt(Path:getName(path)) then -- 2073
						local content = Content:loadAsync(path) -- 2074
						if content then -- 2074
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2075
							if resultCodes then -- 2075
								buildSucceeded = true -- 2076
								return { -- 2077
									success = true, -- 2077
									resultCodes = resultCodes -- 2077
								} -- 2077
							end -- 2075
						end -- 2074
					end -- 2073
				elseif "wa" == _exp_0 then -- 2078
					local projDir = getWaProjectDirFromFile(path) -- 2079
					if projDir then -- 2079
						local message = Wasm:buildWaAsync(projDir) -- 2080
						if message == "" then -- 2081
							return { -- 2082
								success = true -- 2082
							} -- 2082
						else -- 2084
							return { -- 2084
								success = false, -- 2084
								message = message -- 2084
							} -- 2084
						end -- 2081
					else -- 2086
						return { -- 2086
							success = false, -- 2086
							message = 'Wa file needs a project' -- 2086
						} -- 2086
					end -- 2079
				end -- 2071
			end -- 2062
		end -- 2062
	end -- 2062
	return { -- 2058
		success = false -- 2058
	} -- 2058
end) -- 2058
local extentionLevels = { -- 2089
	vs = 2, -- 2089
	bl = 2, -- 2090
	ts = 1, -- 2091
	tsx = 1, -- 2092
	tl = 1, -- 2093
	yue = 1, -- 2094
	xml = 1, -- 2095
	lua = 0 -- 2096
} -- 2088
local visitAssets -- 2098
visitAssets = function(path, workspace, builtin, recursive) -- 2098
	if recursive == nil then -- 2098
		recursive = true -- 2098
	end -- 2098
	local children = nil -- 2099
	local dirs = Content:getDirs(path) -- 2100
	for _index_0 = 1, #dirs do -- 2101
		local dir = dirs[_index_0] -- 2101
		if workspace then -- 2102
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 2103
				goto _continue_0 -- 2104
			end -- 2103
		elseif dir == ".git" then -- 2105
			goto _continue_0 -- 2106
		end -- 2102
		if not children then -- 2107
			children = { } -- 2107
		end -- 2107
		local dirPath = Path(path, dir) -- 2108
		if recursive then -- 2109
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2110
		else -- 2112
			children[#children + 1] = { -- 2113
				key = dirPath, -- 2113
				dir = true, -- 2114
				title = dir, -- 2115
				builtin = builtin, -- 2116
				isLeaf = false -- 2117
			} -- 2112
		end -- 2109
		::_continue_0:: -- 2102
	end -- 2101
	local files = Content:getFiles(path) -- 2119
	local names = { } -- 2120
	for _index_0 = 1, #files do -- 2121
		local file = files[_index_0] -- 2121
		if (".DS_Store" == file) then -- 2122
			goto _continue_1 -- 2123
		end -- 2122
		local name = Path:getName(file) -- 2124
		local ext = names[name] -- 2125
		if ext then -- 2125
			local lv1 -- 2126
			do -- 2126
				local _exp_0 = extentionLevels[ext] -- 2126
				if _exp_0 ~= nil then -- 2126
					lv1 = _exp_0 -- 2126
				else -- 2126
					lv1 = -1 -- 2126
				end -- 2126
			end -- 2126
			ext = Path:getExt(file) -- 2127
			local lv2 -- 2128
			do -- 2128
				local _exp_0 = extentionLevels[ext] -- 2128
				if _exp_0 ~= nil then -- 2128
					lv2 = _exp_0 -- 2128
				else -- 2128
					lv2 = -1 -- 2128
				end -- 2128
			end -- 2128
			if lv2 > lv1 then -- 2129
				names[name] = ext -- 2130
			elseif lv2 == lv1 then -- 2131
				names[name .. '.' .. ext] = "" -- 2132
			end -- 2129
		else -- 2134
			ext = Path:getExt(file) -- 2134
			if not extentionLevels[ext] then -- 2135
				names[file] = "" -- 2136
			else -- 2138
				names[name] = ext -- 2138
			end -- 2135
		end -- 2125
		::_continue_1:: -- 2122
	end -- 2121
	do -- 2139
		local _accum_0 = { } -- 2139
		local _len_0 = 1 -- 2139
		for name, ext in pairs(names) do -- 2139
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2139
			_len_0 = _len_0 + 1 -- 2139
		end -- 2139
		files = _accum_0 -- 2139
	end -- 2139
	for _index_0 = 1, #files do -- 2140
		local file = files[_index_0] -- 2140
		if not children then -- 2141
			children = { } -- 2141
		end -- 2141
		children[#children + 1] = { -- 2143
			key = Path(path, file), -- 2143
			dir = false, -- 2144
			title = file, -- 2145
			builtin = builtin -- 2146
		} -- 2142
	end -- 2140
	if children then -- 2148
		table.sort(children, function(a, b) -- 2149
			if a.dir == b.dir then -- 2150
				return a.title < b.title -- 2151
			else -- 2153
				return a.dir -- 2153
			end -- 2150
		end) -- 2149
	end -- 2148
	return { -- 2155
		key = path, -- 2155
		dir = true, -- 2156
		title = Path:getFilename(path), -- 2157
		builtin = builtin, -- 2158
		isLeaf = not children, -- 2159
		children = children -- 2160
	} -- 2154
end -- 2098
HttpServer:post("/assets/children", function(req) -- 2163
	do -- 2164
		local _type_0 = type(req) -- 2164
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2164
		if _tab_0 then -- 2164
			local path -- 2164
			do -- 2164
				local _obj_0 = req.body -- 2164
				local _type_1 = type(_obj_0) -- 2164
				if "table" == _type_1 or "userdata" == _type_1 then -- 2164
					path = _obj_0.path -- 2164
				end -- 2164
			end -- 2164
			if path ~= nil then -- 2164
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2165
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2166
					return { -- 2166
						success = false -- 2166
					} -- 2166
				end -- 2166
				local node = visitAssets(path, workspace, builtin, false) -- 2167
				return { -- 2168
					success = true, -- 2168
					children = node.children or { } -- 2168
				} -- 2168
			end -- 2164
		end -- 2164
	end -- 2164
	return { -- 2163
		success = false -- 2163
	} -- 2163
end) -- 2163
HttpServer:post("/assets/files", function(req) -- 2170
	do -- 2171
		local _type_0 = type(req) -- 2171
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2171
		if _tab_0 then -- 2171
			local path -- 2171
			do -- 2171
				local _obj_0 = req.body -- 2171
				local _type_1 = type(_obj_0) -- 2171
				if "table" == _type_1 or "userdata" == _type_1 then -- 2171
					path = _obj_0.path -- 2171
				end -- 2171
			end -- 2171
			if path ~= nil then -- 2171
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2172
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2173
				if not (workspace or builtin) then -- 2174
					return { -- 2174
						success = false -- 2174
					} -- 2174
				end -- 2174
				if not (Content:exist(path) and Content:isdir(path)) then -- 2175
					return { -- 2175
						success = false -- 2175
					} -- 2175
				end -- 2175
				local globs = { -- 2176
					"**", -- 2176
					"!**/.DS_Store" -- 2176
				} -- 2176
				if workspace then -- 2177
					globs = { -- 2179
						"**", -- 2179
						"!**/.DS_Store", -- 2179
						"!**/.upload/**", -- 2180
						"!**/.download/**", -- 2180
						"!**/.www/**", -- 2181
						"!**/.build/**", -- 2181
						"!**/.git/**", -- 2182
						"!**/.cache/**", -- 2182
						"!**/node_modules/**" -- 2183
					} -- 2178
				end -- 2177
				local files -- 2185
				do -- 2185
					local _accum_0 = { } -- 2185
					local _len_0 = 1 -- 2185
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2185
					for _index_0 = 1, #_list_0 do -- 2185
						local file = _list_0[_index_0] -- 2185
						_accum_0[_len_0] = Path(path, file) -- 2185
						_len_0 = _len_0 + 1 -- 2185
					end -- 2185
					files = _accum_0 -- 2185
				end -- 2185
				return { -- 2186
					success = true, -- 2186
					files = files -- 2186
				} -- 2186
			end -- 2171
		end -- 2171
	end -- 2171
	return { -- 2170
		success = false -- 2170
	} -- 2170
end) -- 2170
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2227
	local _tab_0 = { -- 2227
		{ -- 2228
			key = Path(Content.assetPath), -- 2228
			dir = true, -- 2229
			builtin = true, -- 2230
			title = zh and "内置资源" or "Built-in", -- 2231
			children = builtinChildren -- 2232
		} -- 2227
	} -- 2234
	local _obj_0 = workspace.children or { } -- 2234
	local _idx_0 = #_tab_0 + 1 -- 2234
	for _index_0 = 1, #_obj_0 do -- 2234
		local _value_0 = _obj_0[_index_0] -- 2234
		_tab_0[_idx_0] = _value_0 -- 2234
		_idx_0 = _idx_0 + 1 -- 2234
	end -- 2234
	return _tab_0 -- 2227
end -- 2227
HttpServer:post("/assets", function() -- 2188
	local Entry = require("Script.Dev.Entry") -- 2189
	local engineDev = Entry.getEngineDev() -- 2190
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2191
	local zh = (App.locale:match("^zh") ~= nil) -- 2192
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2193
	readme.title = zh and "说明文档" or "Readme" -- 2194
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2195
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2196
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2197
	tools.title = zh and "开发工具" or "Tools" -- 2198
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2199
	font.title = zh and "字体" or "Font" -- 2200
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2201
	lib.title = zh and "程序库" or "Lib" -- 2202
	if engineDev then -- 2203
		local _list_0 = lib.children -- 2204
		for _index_0 = 1, #_list_0 do -- 2204
			local child = _list_0[_index_0] -- 2204
			if not (child.title == "Dora") then -- 2205
				goto _continue_0 -- 2205
			end -- 2205
			local title = zh and "zh-Hans" or "en" -- 2206
			do -- 2207
				local _accum_0 = { } -- 2207
				local _len_0 = 1 -- 2207
				local _list_1 = child.children -- 2207
				for _index_1 = 1, #_list_1 do -- 2207
					local c = _list_1[_index_1] -- 2207
					if c.title ~= title then -- 2207
						_accum_0[_len_0] = c -- 2207
						_len_0 = _len_0 + 1 -- 2207
					end -- 2207
				end -- 2207
				child.children = _accum_0 -- 2207
			end -- 2207
			break -- 2208
			::_continue_0:: -- 2205
		end -- 2204
	else -- 2210
		local _accum_0 = { } -- 2210
		local _len_0 = 1 -- 2210
		local _list_0 = lib.children -- 2210
		for _index_0 = 1, #_list_0 do -- 2210
			local child = _list_0[_index_0] -- 2210
			if child.title ~= "Dora" then -- 2210
				_accum_0[_len_0] = child -- 2210
				_len_0 = _len_0 + 1 -- 2210
			end -- 2210
		end -- 2210
		lib.children = _accum_0 -- 2210
	end -- 2203
	local builtinChildren = { -- 2211
		readme, -- 2211
		apiDoc, -- 2211
		tools, -- 2211
		font, -- 2211
		lib -- 2211
	} -- 2211
	if engineDev then -- 2212
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2213
		do -- 2214
			local _obj_0 = dev.children -- 2214
			_obj_0[#_obj_0 + 1] = { -- 2215
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2215
				dir = false, -- 2216
				builtin = true, -- 2217
				title = "init.yue" -- 2218
			} -- 2214
		end -- 2214
		builtinChildren[#builtinChildren + 1] = dev -- 2220
	end -- 2212
	return { -- 2222
		key = Content.writablePath, -- 2222
		dir = true, -- 2223
		root = true, -- 2224
		title = "Assets", -- 2225
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2226
	} -- 2221
end) -- 2188
HttpServer:post("/entry/list", function(req) -- 2238
	local Entry = require("Script.Dev.Entry") -- 2239
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2240
	res.success = true -- 2241
	return res -- 2242
end) -- 2238
HttpServer:post("/run/status", function() -- 2244
	local Entry = require("Script.Dev.Entry") -- 2245
	return Entry.getCurrentEntryStatus() -- 2246
end) -- 2244
HttpServer:postSchedule("/run", function(req) -- 2248
	do -- 2249
		local _type_0 = type(req) -- 2249
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2249
		if _tab_0 then -- 2249
			local file -- 2249
			do -- 2249
				local _obj_0 = req.body -- 2249
				local _type_1 = type(_obj_0) -- 2249
				if "table" == _type_1 or "userdata" == _type_1 then -- 2249
					file = _obj_0.file -- 2249
				end -- 2249
			end -- 2249
			local asProj -- 2249
			do -- 2249
				local _obj_0 = req.body -- 2249
				local _type_1 = type(_obj_0) -- 2249
				if "table" == _type_1 or "userdata" == _type_1 then -- 2249
					asProj = _obj_0.asProj -- 2249
				end -- 2249
			end -- 2249
			if file ~= nil and asProj ~= nil then -- 2249
				if not Content:isAbsolutePath(file) then -- 2250
					local devFile = Path(Content.writablePath, file) -- 2251
					if Content:exist(devFile) then -- 2252
						file = devFile -- 2252
					end -- 2252
				end -- 2250
				local Entry = require("Script.Dev.Entry") -- 2253
				local workDir -- 2254
				if asProj then -- 2255
					local projectRoot = req.body.projectRoot -- 2256
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2257
						workDir = projectRoot -- 2258
					else -- 2260
						workDir = getProjectDirFromFile(file) -- 2260
					end -- 2257
					if workDir then -- 2261
						Entry.allClear() -- 2262
						local target = Path(workDir, "init") -- 2263
						local success, err = Entry.enterEntryAsync({ -- 2264
							entryName = "Project", -- 2264
							fileName = target, -- 2264
							workDir = workDir, -- 2264
							projectRoot = workDir, -- 2264
							runKind = "project" -- 2264
						}) -- 2264
						target = Path:getName(Path:getPath(target)) -- 2265
						return { -- 2266
							success = success, -- 2266
							target = target, -- 2266
							err = err -- 2266
						} -- 2266
					end -- 2261
				else -- 2268
					workDir = getProjectDirFromFile(file) -- 2268
					if not workDir and Path:getExt(file) == "wasm" then -- 2269
						local parent = Path:getPath(file) -- 2270
						if Content:exist(Path(parent, "wa.mod")) then -- 2271
							workDir = parent -- 2272
						end -- 2271
					end -- 2269
				end -- 2255
				Entry.allClear() -- 2273
				file = Path:replaceExt(file, "") -- 2274
				local entry = { -- 2276
					entryName = Path:getName(file), -- 2276
					fileName = file, -- 2277
					runKind = "file" -- 2278
				} -- 2275
				if workDir then -- 2279
					entry.workDir = workDir -- 2280
					entry.projectRoot = workDir -- 2281
				end -- 2279
				local success, err = Entry.enterEntryAsync(entry) -- 2282
				return { -- 2283
					success = success, -- 2283
					err = err -- 2283
				} -- 2283
			end -- 2249
		end -- 2249
	end -- 2249
	return { -- 2248
		success = false -- 2248
	} -- 2248
end) -- 2248
local _anon_func_7 = function(result) -- 2325
	if result.success then -- 2325
		return nil -- 2325
	else -- 2325
		return "PREVIEW_FAILED" -- 2325
	end -- 2325
end -- 2325
HttpServer:postSchedule("/agent/preview", function(req) -- 2285
	local releaseAgent = AgentHost.acquire() -- 2286
	local _ <close> = setmetatable({ }, { -- 2287
		__close = function() -- 2287
			return releaseAgent() -- 2287
		end -- 2287
	}) -- 2287
	do -- 2288
		local _type_0 = type(req) -- 2288
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2288
		if _tab_0 then -- 2288
			local projectRoot -- 2288
			do -- 2288
				local _obj_0 = req.body -- 2288
				local _type_1 = type(_obj_0) -- 2288
				if "table" == _type_1 or "userdata" == _type_1 then -- 2288
					projectRoot = _obj_0.projectRoot -- 2288
				end -- 2288
			end -- 2288
			if projectRoot ~= nil then -- 2288
				if not getProjectSourceRoot(projectRoot) then -- 2289
					return { -- 2289
						success = false, -- 2289
						code = "INVALID_PROJECT", -- 2289
						message = "projectRoot must be an existing absolute directory" -- 2289
					} -- 2289
				end -- 2289
				local entryFile = req.body.entry or "init.lua" -- 2290
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2291
					return { -- 2291
						success = false, -- 2291
						code = "INVALID_ENTRY", -- 2291
						message = "entry must be a non-empty project-relative path" -- 2291
					} -- 2291
				end -- 2291
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2292
					0.5 -- 2292
				} -- 2292
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2293
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2294
					return { -- 2294
						success = false, -- 2294
						code = "INVALID_QUEUE_TIMEOUT", -- 2294
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2294
					} -- 2294
				end -- 2294
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2295
				local AgentOperation = require("Agent.Tool.Operation") -- 2296
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2297
				local requestId = AgentOperation.createOperationId() -- 2298
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2299
				if not enqueued.success then -- 2300
					return { -- 2300
						success = false, -- 2300
						code = "ENTRY_QUEUE_REJECTED", -- 2300
						message = enqueued.message -- 2300
					} -- 2300
				end -- 2300
				local queuedAt = App.runningTime -- 2301
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2302
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2303
						local state = agentEntryRunQueue:get(requestId) -- 2304
						agentEntryRunQueue:cancel(requestId) -- 2305
						return { -- 2307
							success = false, -- 2307
							code = "ENTRY_QUEUE_TIMEOUT", -- 2308
							message = "timed out waiting for the Dora entry runtime", -- 2309
							requestId = requestId, -- 2310
							queuePosition = state.position -- 2311
						} -- 2306
					end -- 2303
					sleep() -- 2312
				end -- 2302
				local queueWaitSeconds = App.runningTime - queuedAt -- 2313
				local _ <close> = setmetatable({ }, { -- 2314
					__close = function() -- 2314
						return agentEntryRunQueue:release(requestId) -- 2314
					end -- 2314
				}) -- 2314
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2315
				local Entry = require("Script.Dev.Entry") -- 2316
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2318
					workDir = projectRoot, -- 2318
					operationId = requestId, -- 2319
					print = function() end -- 2320
				}, Entry) -- 2317
				local result = preview({ -- 2322
					entry = entryFile, -- 2322
					captureAtSeconds = captureAtSeconds -- 2322
				}) -- 2322
				return { -- 2324
					success = result.success, -- 2324
					code = _anon_func_7(result), -- 2325
					message = result.message, -- 2326
					requestId = requestId, -- 2327
					queueWaitSeconds = queueWaitSeconds, -- 2328
					interruptedUserRun = result.interruptedUserRun, -- 2329
					files = result.files, -- 2330
					frames = result.frames -- 2331
				} -- 2323
			end -- 2288
		end -- 2288
	end -- 2288
	return { -- 2285
		success = false, -- 2285
		message = "invalid call" -- 2285
	} -- 2285
end) -- 2285
HttpServer:postSchedule("/agent/command", function(req) -- 2333
	local releaseAgent = AgentHost.acquire() -- 2334
	local _ <close> = setmetatable({ }, { -- 2335
		__close = function() -- 2335
			return releaseAgent() -- 2335
		end -- 2335
	}) -- 2335
	do -- 2336
		local _type_0 = type(req) -- 2336
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2336
		if _tab_0 then -- 2336
			local body = req.body -- 2336
			if body ~= nil then -- 2336
				local projectRoot = body.projectRoot -- 2337
				if not getProjectSourceRoot(projectRoot) then -- 2338
					return { -- 2338
						success = false, -- 2338
						code = "INVALID_PROJECT", -- 2338
						message = "projectRoot must be an existing absolute directory" -- 2338
					} -- 2338
				end -- 2338
				local AgentValidation = require("Agent.Tool.Validation") -- 2339
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2340
				if not validated.success then -- 2341
					return { -- 2341
						success = false, -- 2341
						code = "INVALID_COMMAND", -- 2341
						message = validated.message -- 2341
					} -- 2341
				end -- 2341
				local input = validated.value -- 2342
				local AgentCommand = require("Agent.Tool.Command") -- 2343
				local result = nil -- 2344
				local failure = nil -- 2345
				local promise = AgentCommand.executeCommand({ -- 2347
					workDir = projectRoot, -- 2347
					mode = input.mode, -- 2348
					code = input.code, -- 2349
					command = input.command, -- 2350
					cwd = input.cwd, -- 2351
					timeoutSeconds = input.timeoutSeconds -- 2352
				}) -- 2346
				promise:addCallbacks((function(_, value) -- 2353
					result = value -- 2353
				end), (function(_, err) -- 2353
					failure = tostring(err) -- 2353
				end)) -- 2353
				wait(function() -- 2354
					return result ~= nil or failure ~= nil -- 2354
				end) -- 2354
				if failure then -- 2355
					return { -- 2355
						success = false, -- 2355
						code = "COMMAND_BRIDGE_FAILED", -- 2355
						message = failure -- 2355
					} -- 2355
				end -- 2355
				if not result.success then -- 2356
					result.code = "COMMAND_FAILED" -- 2357
				end -- 2356
				return result -- 2358
			end -- 2336
		end -- 2336
	end -- 2336
	return { -- 2333
		success = false, -- 2333
		code = "INVALID_COMMAND", -- 2333
		message = "invalid call" -- 2333
	} -- 2333
end) -- 2333
HttpServer:postSchedule("/stop", function() -- 2360
	local Entry = require("Script.Dev.Entry") -- 2361
	return { -- 2362
		success = Entry.stop() -- 2362
	} -- 2362
end) -- 2360
local minifyAsync -- 2364
minifyAsync = function(sourcePath, minifyPath) -- 2364
	if not Content:exist(sourcePath) then -- 2365
		return -- 2365
	end -- 2365
	local Entry = require("Script.Dev.Entry") -- 2366
	local errors = { } -- 2367
	local files = Entry.getAllFiles(sourcePath, { -- 2368
		"lua" -- 2368
	}, true) -- 2368
	do -- 2369
		local _accum_0 = { } -- 2369
		local _len_0 = 1 -- 2369
		for _index_0 = 1, #files do -- 2369
			local file = files[_index_0] -- 2369
			if file:sub(1, 1) ~= '.' then -- 2369
				_accum_0[_len_0] = file -- 2369
				_len_0 = _len_0 + 1 -- 2369
			end -- 2369
		end -- 2369
		files = _accum_0 -- 2369
	end -- 2369
	local paths -- 2370
	do -- 2370
		local _tbl_0 = { } -- 2370
		for _index_0 = 1, #files do -- 2370
			local file = files[_index_0] -- 2370
			_tbl_0[Path:getPath(file)] = true -- 2370
		end -- 2370
		paths = _tbl_0 -- 2370
	end -- 2370
	for path in pairs(paths) do -- 2371
		Content:mkdir(Path(minifyPath, path)) -- 2371
	end -- 2371
	local _ <close> = setmetatable({ }, { -- 2372
		__close = function() -- 2372
			package.loaded["luaminify.FormatMini"] = nil -- 2373
			package.loaded["luaminify.ParseLua"] = nil -- 2374
			package.loaded["luaminify.Scope"] = nil -- 2375
			package.loaded["luaminify.Util"] = nil -- 2376
		end -- 2372
	}) -- 2372
	local FormatMini -- 2377
	do -- 2377
		local _obj_0 = require("luaminify") -- 2377
		FormatMini = _obj_0.FormatMini -- 2377
	end -- 2377
	local fileCount = #files -- 2378
	local count = 0 -- 2379
	for _index_0 = 1, #files do -- 2380
		local file = files[_index_0] -- 2380
		thread(function() -- 2381
			local _ <close> = setmetatable({ }, { -- 2382
				__close = function() -- 2382
					count = count + 1 -- 2382
				end -- 2382
			}) -- 2382
			local input = Path(sourcePath, file) -- 2383
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2384
			if Content:exist(input) then -- 2385
				local sourceCodes = Content:loadAsync(input) -- 2386
				local res, err = FormatMini(sourceCodes) -- 2387
				if res then -- 2388
					Content:saveAsync(output, res) -- 2389
					return print("Minify " .. tostring(file)) -- 2390
				else -- 2392
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2392
				end -- 2388
			else -- 2394
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2394
			end -- 2385
		end) -- 2381
		sleep() -- 2395
	end -- 2380
	wait(function() -- 2396
		return count == fileCount -- 2396
	end) -- 2396
	if #errors > 0 then -- 2397
		print(table.concat(errors, '\n')) -- 2398
	end -- 2397
	print("Obfuscation done.") -- 2399
	return files -- 2400
end -- 2364
local zipping = false -- 2402
HttpServer:postSchedule("/zip", function(req) -- 2404
	do -- 2405
		local _type_0 = type(req) -- 2405
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2405
		if _tab_0 then -- 2405
			local path -- 2405
			do -- 2405
				local _obj_0 = req.body -- 2405
				local _type_1 = type(_obj_0) -- 2405
				if "table" == _type_1 or "userdata" == _type_1 then -- 2405
					path = _obj_0.path -- 2405
				end -- 2405
			end -- 2405
			local zipFile -- 2405
			do -- 2405
				local _obj_0 = req.body -- 2405
				local _type_1 = type(_obj_0) -- 2405
				if "table" == _type_1 or "userdata" == _type_1 then -- 2405
					zipFile = _obj_0.zipFile -- 2405
				end -- 2405
			end -- 2405
			local obfuscated -- 2405
			do -- 2405
				local _obj_0 = req.body -- 2405
				local _type_1 = type(_obj_0) -- 2405
				if "table" == _type_1 or "userdata" == _type_1 then -- 2405
					obfuscated = _obj_0.obfuscated -- 2405
				end -- 2405
			end -- 2405
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2405
				if zipping then -- 2406
					goto failed -- 2406
				end -- 2406
				zipping = true -- 2407
				local _ <close> = setmetatable({ }, { -- 2408
					__close = function() -- 2408
						zipping = false -- 2408
					end -- 2408
				}) -- 2408
				if not Content:exist(path) then -- 2409
					goto failed -- 2409
				end -- 2409
				Content:mkdir(Path:getPath(zipFile)) -- 2410
				if obfuscated then -- 2411
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2412
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2413
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2414
					Content:remove(scriptPath) -- 2415
					Content:remove(obfuscatedPath) -- 2416
					Content:remove(tempPath) -- 2417
					Content:mkdir(scriptPath) -- 2418
					Content:mkdir(obfuscatedPath) -- 2419
					Content:mkdir(tempPath) -- 2420
					if not Content:copyAsync(path, tempPath) then -- 2421
						goto failed -- 2421
					end -- 2421
					local Entry = require("Script.Dev.Entry") -- 2422
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2423
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2424
						"tl", -- 2424
						"yue", -- 2424
						"lua", -- 2424
						"ts", -- 2424
						"tsx", -- 2424
						"vs", -- 2424
						"bl", -- 2424
						"xml", -- 2424
						"wa", -- 2424
						"mod" -- 2424
					}, true) -- 2424
					for _index_0 = 1, #scriptFiles do -- 2425
						local file = scriptFiles[_index_0] -- 2425
						Content:remove(Path(tempPath, file)) -- 2426
					end -- 2425
					for _index_0 = 1, #luaFiles do -- 2427
						local file = luaFiles[_index_0] -- 2427
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2428
					end -- 2427
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2429
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2430
					end) then -- 2429
						goto failed -- 2429
					end -- 2429
					return { -- 2431
						success = true -- 2431
					} -- 2431
				else -- 2433
					return { -- 2433
						success = Content:zipAsync(path, zipFile, function(file) -- 2433
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2434
						end) -- 2433
					} -- 2433
				end -- 2411
			end -- 2405
		end -- 2405
	end -- 2405
	::failed:: -- 2435
	return { -- 2404
		success = false -- 2404
	} -- 2404
end) -- 2404
HttpServer:postSchedule("/unzip", function(req) -- 2437
	do -- 2438
		local _type_0 = type(req) -- 2438
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2438
		if _tab_0 then -- 2438
			local zipFile -- 2438
			do -- 2438
				local _obj_0 = req.body -- 2438
				local _type_1 = type(_obj_0) -- 2438
				if "table" == _type_1 or "userdata" == _type_1 then -- 2438
					zipFile = _obj_0.zipFile -- 2438
				end -- 2438
			end -- 2438
			local path -- 2438
			do -- 2438
				local _obj_0 = req.body -- 2438
				local _type_1 = type(_obj_0) -- 2438
				if "table" == _type_1 or "userdata" == _type_1 then -- 2438
					path = _obj_0.path -- 2438
				end -- 2438
			end -- 2438
			if zipFile ~= nil and path ~= nil then -- 2438
				return { -- 2439
					success = Content:unzipAsync(zipFile, path, function(file) -- 2439
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2440
					end) -- 2439
				} -- 2439
			end -- 2438
		end -- 2438
	end -- 2438
	return { -- 2437
		success = false -- 2437
	} -- 2437
end) -- 2437
HttpServer:post("/editing-info", function(req) -- 2442
	local Entry = require("Script.Dev.Entry") -- 2443
	local config = Entry.getConfig() -- 2444
	local _type_0 = type(req) -- 2445
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2445
	local _match_0 = false -- 2445
	if _tab_0 then -- 2445
		local editingInfo -- 2445
		do -- 2445
			local _obj_0 = req.body -- 2445
			local _type_1 = type(_obj_0) -- 2445
			if "table" == _type_1 or "userdata" == _type_1 then -- 2445
				editingInfo = _obj_0.editingInfo -- 2445
			end -- 2445
		end -- 2445
		if editingInfo ~= nil then -- 2445
			_match_0 = true -- 2445
			config.editingInfo = editingInfo -- 2446
			return { -- 2447
				success = true -- 2447
			} -- 2447
		end -- 2445
	end -- 2445
	if not _match_0 then -- 2445
		if not (config.editingInfo ~= nil) then -- 2449
			local folder -- 2450
			if App.locale:match('^zh') then -- 2450
				folder = 'zh-Hans' -- 2450
			else -- 2450
				folder = 'en' -- 2450
			end -- 2450
			config.editingInfo = json.encode({ -- 2452
				index = 0, -- 2452
				files = { -- 2454
					{ -- 2455
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2455
						title = "welcome.md" -- 2456
					} -- 2454
				} -- 2453
			}) -- 2451
		end -- 2449
		return { -- 2460
			success = true, -- 2460
			editingInfo = config.editingInfo -- 2460
		} -- 2460
	end -- 2445
end) -- 2442
HttpServer:post("/command", function(req) -- 2462
	do -- 2463
		local _type_0 = type(req) -- 2463
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2463
		if _tab_0 then -- 2463
			local code -- 2463
			do -- 2463
				local _obj_0 = req.body -- 2463
				local _type_1 = type(_obj_0) -- 2463
				if "table" == _type_1 or "userdata" == _type_1 then -- 2463
					code = _obj_0.code -- 2463
				end -- 2463
			end -- 2463
			local log -- 2463
			do -- 2463
				local _obj_0 = req.body -- 2463
				local _type_1 = type(_obj_0) -- 2463
				if "table" == _type_1 or "userdata" == _type_1 then -- 2463
					log = _obj_0.log -- 2463
				end -- 2463
			end -- 2463
			if code ~= nil and log ~= nil then -- 2463
				emit("AppCommand", code, log) -- 2464
				return { -- 2465
					success = true -- 2465
				} -- 2465
			end -- 2463
		end -- 2463
	end -- 2463
	return { -- 2462
		success = false -- 2462
	} -- 2462
end) -- 2462
HttpServer:post("/log/save", function() -- 2467
	local folder = ".download" -- 2468
	local fullLogFile = "dora_full_logs.txt" -- 2469
	local fullFolder = Path(Content.writablePath, folder) -- 2470
	Content:mkdir(fullFolder) -- 2471
	local logPath = Path(fullFolder, fullLogFile) -- 2472
	if App:saveLog(logPath) then -- 2473
		return { -- 2474
			success = true, -- 2474
			path = Path(folder, fullLogFile) -- 2474
		} -- 2474
	end -- 2473
	return { -- 2467
		success = false -- 2467
	} -- 2467
end) -- 2467
local tailLines -- 2476
tailLines = function(text, count) -- 2476
	local lines = { } -- 2477
	text = text:gsub("\r\n", "\n") -- 2478
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2479
		lines[#lines + 1] = line -- 2480
	end -- 2479
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2481
		table.remove(lines) -- 2482
	end -- 2481
	local start = math.max(1, #lines - count + 1) -- 2483
	local out = { } -- 2484
	for i = start, #lines do -- 2485
		out[#out + 1] = lines[i] -- 2486
	end -- 2485
	return table.concat(out, "\n") -- 2487
end -- 2476
HttpServer:post("/log", function(req) -- 2489
	local count = 100 -- 2490
	if req and req.body and req.body.count ~= nil then -- 2491
		count = req.body.count -- 2492
	end -- 2491
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2493
		return { -- 2494
			success = false, -- 2494
			message = "count must be a positive integer" -- 2494
		} -- 2494
	end -- 2493
	local folder = ".download" -- 2495
	local fullLogFile = "dora_full_logs.txt" -- 2496
	local fullFolder = Path(Content.writablePath, folder) -- 2497
	Content:mkdir(fullFolder) -- 2498
	local logPath = Path(fullFolder, fullLogFile) -- 2499
	if App:saveLog(logPath) then -- 2500
		local text = Content:load(logPath) -- 2501
		if text then -- 2502
			return { -- 2503
				success = true, -- 2503
				log = tailLines(text, count) -- 2503
			} -- 2503
		else -- 2505
			return { -- 2505
				success = false, -- 2505
				message = "failed to read log" -- 2505
			} -- 2505
		end -- 2502
	else -- 2507
		return { -- 2507
			success = false, -- 2507
			message = "failed to save log" -- 2507
		} -- 2507
	end -- 2500
	return { -- 2489
		success = false -- 2489
	} -- 2489
end) -- 2489
HttpServer:post("/yarn/check", function(req) -- 2509
	local yarncompile = require("yarncompile") -- 2510
	do -- 2511
		local _type_0 = type(req) -- 2511
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2511
		if _tab_0 then -- 2511
			local code -- 2511
			do -- 2511
				local _obj_0 = req.body -- 2511
				local _type_1 = type(_obj_0) -- 2511
				if "table" == _type_1 or "userdata" == _type_1 then -- 2511
					code = _obj_0.code -- 2511
				end -- 2511
			end -- 2511
			if code ~= nil then -- 2511
				local jsonObject = json.decode(code) -- 2512
				if jsonObject then -- 2512
					local errors = { } -- 2513
					local _list_0 = jsonObject.nodes -- 2514
					for _index_0 = 1, #_list_0 do -- 2514
						local node = _list_0[_index_0] -- 2514
						local title, body = node.title, node.body -- 2515
						local luaCode, err = yarncompile(body) -- 2516
						if not luaCode then -- 2516
							errors[#errors + 1] = title .. ":" .. err -- 2517
						end -- 2516
					end -- 2514
					return { -- 2518
						success = true, -- 2518
						syntaxError = table.concat(errors, "\n\n") -- 2518
					} -- 2518
				end -- 2512
			end -- 2511
		end -- 2511
	end -- 2511
	return { -- 2509
		success = false -- 2509
	} -- 2509
end) -- 2509
HttpServer:post("/yarn/check-file", function(req) -- 2520
	local yarncompile = require("yarncompile") -- 2521
	do -- 2522
		local _type_0 = type(req) -- 2522
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2522
		if _tab_0 then -- 2522
			local code -- 2522
			do -- 2522
				local _obj_0 = req.body -- 2522
				local _type_1 = type(_obj_0) -- 2522
				if "table" == _type_1 or "userdata" == _type_1 then -- 2522
					code = _obj_0.code -- 2522
				end -- 2522
			end -- 2522
			if code ~= nil then -- 2522
				local res, _, err = yarncompile(code, true) -- 2523
				if not res then -- 2523
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2524
					return { -- 2525
						success = false, -- 2525
						message = message, -- 2525
						line = line, -- 2525
						column = column, -- 2525
						node = node -- 2525
					} -- 2525
				end -- 2523
			end -- 2522
		end -- 2522
	end -- 2522
	return { -- 2520
		success = true -- 2520
	} -- 2520
end) -- 2520
getWaProjectDirFromFile = function(file) -- 2527
	local current -- 2528
	if Content:isdir(file) then -- 2528
		current = file -- 2528
	else -- 2528
		current = Path:getPath(file) -- 2528
	end -- 2528
	if current == "" then -- 2529
		return nil -- 2529
	end -- 2529
	repeat -- 2530
		local modPath = Path(current, "wa.mod") -- 2531
		if Content:exist(modPath) then -- 2532
			return current, modPath -- 2533
		end -- 2532
		local parent = Path:getPath(current) -- 2534
		if parent == "" or parent == current then -- 2535
			break -- 2535
		end -- 2535
		current = parent -- 2536
	until false -- 2530
	return nil -- 2538
end -- 2527
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2540
	do -- 2541
		local _type_0 = type(req) -- 2541
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2541
		if _tab_0 then -- 2541
			local path -- 2541
			do -- 2541
				local _obj_0 = req.body -- 2541
				local _type_1 = type(_obj_0) -- 2541
				if "table" == _type_1 or "userdata" == _type_1 then -- 2541
					path = _obj_0.path -- 2541
				end -- 2541
			end -- 2541
			if path ~= nil then -- 2541
				local projDir = getWaProjectDirFromFile(path) -- 2542
				if projDir then -- 2542
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2543
					if not Content:exist(sourceDoraPath) then -- 2544
						return { -- 2545
							success = false, -- 2545
							message = "missing dora template" -- 2545
						} -- 2545
					end -- 2544
					local targetVendorPath = Path(projDir, "vendor") -- 2546
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2547
					if not Content:exist(targetVendorPath) then -- 2548
						if not Content:mkdir(targetVendorPath) then -- 2549
							return { -- 2550
								success = false, -- 2550
								message = "failed to create vendor folder" -- 2550
							} -- 2550
						end -- 2549
					elseif not Content:isdir(targetVendorPath) then -- 2551
						return { -- 2552
							success = false, -- 2552
							message = "vendor path is not a folder" -- 2552
						} -- 2552
					end -- 2548
					if Content:exist(targetDoraPath) then -- 2553
						if not Content:remove(targetDoraPath) then -- 2554
							return { -- 2555
								success = false, -- 2555
								message = "failed to remove old dora" -- 2555
							} -- 2555
						end -- 2554
					end -- 2553
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2556
						return { -- 2557
							success = false, -- 2557
							message = "failed to copy dora" -- 2557
						} -- 2557
					end -- 2556
					return { -- 2558
						success = true -- 2558
					} -- 2558
				else -- 2560
					return { -- 2560
						success = false, -- 2560
						message = 'Wa file needs a project' -- 2560
					} -- 2560
				end -- 2542
			end -- 2541
		end -- 2541
	end -- 2541
	return { -- 2540
		success = false, -- 2540
		message = "invalid call" -- 2540
	} -- 2540
end) -- 2540
HttpServer:postSchedule("/wa/build", function(req) -- 2562
	do -- 2563
		local _type_0 = type(req) -- 2563
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2563
		if _tab_0 then -- 2563
			local path -- 2563
			do -- 2563
				local _obj_0 = req.body -- 2563
				local _type_1 = type(_obj_0) -- 2563
				if "table" == _type_1 or "userdata" == _type_1 then -- 2563
					path = _obj_0.path -- 2563
				end -- 2563
			end -- 2563
			if path ~= nil then -- 2563
				local projDir = getWaProjectDirFromFile(path) -- 2564
				if projDir then -- 2564
					local message = Wasm:buildWaAsync(projDir) -- 2565
					if message == "" then -- 2566
						return { -- 2567
							success = true -- 2567
						} -- 2567
					else -- 2569
						return { -- 2569
							success = false, -- 2569
							message = message -- 2569
						} -- 2569
					end -- 2566
				else -- 2571
					return { -- 2571
						success = false, -- 2571
						message = 'Wa file needs a project' -- 2571
					} -- 2571
				end -- 2564
			end -- 2563
		end -- 2563
	end -- 2563
	return { -- 2572
		success = false, -- 2572
		message = 'failed to build' -- 2572
	} -- 2572
end) -- 2562
HttpServer:postSchedule("/wa/format", function(req) -- 2574
	do -- 2575
		local _type_0 = type(req) -- 2575
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2575
		if _tab_0 then -- 2575
			local file -- 2575
			do -- 2575
				local _obj_0 = req.body -- 2575
				local _type_1 = type(_obj_0) -- 2575
				if "table" == _type_1 or "userdata" == _type_1 then -- 2575
					file = _obj_0.file -- 2575
				end -- 2575
			end -- 2575
			if file ~= nil then -- 2575
				local code = Wasm:formatWaAsync(file) -- 2576
				if code == "" then -- 2577
					return { -- 2578
						success = false -- 2578
					} -- 2578
				else -- 2580
					return { -- 2580
						success = true, -- 2580
						code = code -- 2580
					} -- 2580
				end -- 2577
			end -- 2575
		end -- 2575
	end -- 2575
	return { -- 2581
		success = false -- 2581
	} -- 2581
end) -- 2574
HttpServer:postSchedule("/wa/create", function(req) -- 2583
	do -- 2584
		local _type_0 = type(req) -- 2584
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2584
		if _tab_0 then -- 2584
			local path -- 2584
			do -- 2584
				local _obj_0 = req.body -- 2584
				local _type_1 = type(_obj_0) -- 2584
				if "table" == _type_1 or "userdata" == _type_1 then -- 2584
					path = _obj_0.path -- 2584
				end -- 2584
			end -- 2584
			if path ~= nil then -- 2584
				if not Content:exist(Path:getPath(path)) then -- 2585
					return { -- 2586
						success = false, -- 2586
						message = "target path not existed" -- 2586
					} -- 2586
				end -- 2585
				if Content:exist(path) then -- 2587
					return { -- 2588
						success = false, -- 2588
						message = "target project folder existed" -- 2588
					} -- 2588
				end -- 2587
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2589
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2590
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2591
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2592
					return { -- 2595
						success = false, -- 2595
						message = "missing template project" -- 2595
					} -- 2595
				end -- 2592
				if not Content:mkdir(path) then -- 2596
					return { -- 2597
						success = false, -- 2597
						message = "failed to create project folder" -- 2597
					} -- 2597
				end -- 2596
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2598
					Content:remove(path) -- 2599
					return { -- 2600
						success = false, -- 2600
						message = "failed to copy template" -- 2600
					} -- 2600
				end -- 2598
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2601
					Content:remove(path) -- 2602
					return { -- 2603
						success = false, -- 2603
						message = "failed to copy template" -- 2603
					} -- 2603
				end -- 2601
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2604
					Content:remove(path) -- 2605
					return { -- 2606
						success = false, -- 2606
						message = "failed to copy template" -- 2606
					} -- 2606
				end -- 2604
				return { -- 2607
					success = true -- 2607
				} -- 2607
			end -- 2584
		end -- 2584
	end -- 2584
	return { -- 2583
		success = false, -- 2583
		message = "invalid call" -- 2583
	} -- 2583
end) -- 2583
local tsBuildGlobs = { -- 2610
	"**/*.ts", -- 2610
	"**/*.tsx", -- 2611
	"!**/.*/**", -- 2612
	"!**/node_modules/**" -- 2613
} -- 2609
local tsSnapshotGlobs = { -- 2616
	"**/*.ts", -- 2616
	"**/*.tsx", -- 2617
	"**/*.lua", -- 2618
	"!**/.*/**", -- 2619
	"!**/node_modules/**" -- 2620
} -- 2615
local collectTSVirtualFiles -- 2622
collectTSVirtualFiles = function(sourceRoot) -- 2622
	local files = { } -- 2623
	local seen = { } -- 2624
	local addFile -- 2625
	addFile = function(file, moduleName, virtualFile) -- 2625
		if moduleName == nil then -- 2625
			moduleName = nil -- 2625
		end -- 2625
		if virtualFile == nil then -- 2625
			virtualFile = nil -- 2625
		end -- 2625
		local targetFile = virtualFile or file -- 2626
		do -- 2627
			local entry = seen[targetFile] -- 2627
			if entry then -- 2627
				if moduleName and moduleName ~= "" then -- 2628
					entry.moduleName = moduleName -- 2628
				end -- 2628
				return -- 2629
			end -- 2627
		end -- 2627
		local content = Content:load(file) -- 2630
		if content then -- 2630
			local entry = { -- 2631
				file = targetFile, -- 2631
				content = content -- 2631
			} -- 2631
			if moduleName and moduleName ~= "" then -- 2632
				entry.moduleName = moduleName -- 2632
			end -- 2632
			seen[targetFile] = entry -- 2633
			files[#files + 1] = entry -- 2634
		end -- 2630
	end -- 2625
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2635
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2636
		for _index_0 = 1, #_list_0 do -- 2636
			local subFile = _list_0[_index_0] -- 2636
			addFile(Path(sourceRoot, subFile)) -- 2637
		end -- 2636
		local libraryRoots = { -- 2639
			Path(sourceRoot, "Script", "Lib"), -- 2639
			Path(sourceRoot, "Lib"), -- 2640
			Path(Content.assetPath, "Script", "Lib") -- 2641
		} -- 2638
		for _index_0 = 1, #libraryRoots do -- 2642
			local libraryRoot = libraryRoots[_index_0] -- 2642
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2643
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2644
				for _index_1 = 1, #_list_1 do -- 2644
					local subFile = _list_1[_index_1] -- 2644
					local file = Path(libraryRoot, subFile) -- 2645
					local virtualFile = Path(sourceRoot, subFile) -- 2646
					addFile(file, nil, virtualFile) -- 2647
				end -- 2644
			end -- 2643
		end -- 2642
	end -- 2635
	local locale -- 2648
	if App.locale:match('^zh') then -- 2648
		locale = 'zh-Hans' -- 2648
	else -- 2648
		locale = 'en' -- 2648
	end -- 2648
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2649
	local _list_0 = Content:getFiles(declarationRoot) -- 2650
	for _index_0 = 1, #_list_0 do -- 2650
		local file = _list_0[_index_0] -- 2650
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2651
			local fullPath = Path(declarationRoot, file) -- 2652
			local moduleName = Path:getName(Path:getName(file)) -- 2653
			addFile(fullPath, moduleName) -- 2654
		end -- 2651
	end -- 2650
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2655
	local lualibBundleTarget -- 2656
	if sourceRoot then -- 2656
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2656
	else -- 2656
		lualibBundleTarget = "lualib_bundle.lua" -- 2656
	end -- 2656
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2657
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2658
	local _list_1 = Content:getFiles(lualibRoot) -- 2659
	for _index_0 = 1, #_list_1 do -- 2659
		local file = _list_1[_index_0] -- 2659
		if Path:getExt(file) == "lua" then -- 2660
			local virtualFile -- 2661
			if sourceRoot then -- 2661
				virtualFile = Path(sourceRoot, "lualib", file) -- 2661
			else -- 2661
				virtualFile = Path("lualib", file) -- 2661
			end -- 2661
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2662
		end -- 2660
	end -- 2659
	return files -- 2663
end -- 2622
local supportsCompilerWebView -- 2665
supportsCompilerWebView = function() -- 2665
	local _val_0 = App.platform -- 2665
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2665
end -- 2665
local webIDECompilerReady = false -- 2666
local webIDEConnectionGeneration = 0 -- 2667
local tsProbeId = 0 -- 2668
local probeWebIDECompiler -- 2670
probeWebIDECompiler = function(isCancelled) -- 2670
	if HttpServer.wsConnectionCount == 0 then -- 2671
		return false -- 2671
	end -- 2671
	tsProbeId = tsProbeId + 1 -- 2672
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2673
	local generation = webIDEConnectionGeneration -- 2674
	local done, ready = false, false -- 2675
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2676
	local listener = Node() -- 2677
	listener:gslot("AppWS", function(event) -- 2678
		if event.type == "Receive" then -- 2679
			local res = json.decode(event.msg) -- 2680
			if res then -- 2680
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2681
					responses = responses + 1 -- 2682
					ready = ready or res.success == true -- 2683
					done = ready or responses >= expectedResponses -- 2684
				end -- 2681
			end -- 2680
		end -- 2679
	end) -- 2678
	emit("AppWS", "Send", json.encode({ -- 2685
		name = "TranspileTSProbe", -- 2685
		id = requestId -- 2685
	})) -- 2685
	local deadline = App.runningTime + 5 -- 2686
	wait(function() -- 2687
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2687
	end) -- 2687
	listener:removeFromParent() -- 2688
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2689
	if generation == webIDEConnectionGeneration then -- 2690
		webIDECompilerReady = ready -- 2690
	end -- 2690
	return ready -- 2691
end -- 2670
local compilerConnectionListener = Node() -- 2693
compilerConnectionListener:addTo(Director.systemUI) -- 2695
local _anon_func_8 = function(event) -- 2697
	local _val_0 = event.type -- 2697
	return "Open" == _val_0 or "Close" == _val_0 -- 2697
end -- 2697
compilerConnectionListener:gslot("AppWS", function(event) -- 2696
	if _anon_func_8(event) then -- 2697
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2698
		webIDECompilerReady = false -- 2699
		if HttpServer.wsConnectionCount > 0 then -- 2700
			return thread(function() -- 2701
				return probeWebIDECompiler() -- 2701
			end) -- 2701
		end -- 2700
	end -- 2697
end) -- 2696
local _anon_func_9 = function(res) -- 2726
	if res.success then -- 2726
		return "tool" -- 2726
	else -- 2726
		return res.failureKind -- 2726
	end -- 2726
end -- 2726
local transpileTSFileWithWebIDE -- 2703
do -- 2703
	local tsBuildRequestId = 0 -- 2704
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2705
		if not probeWebIDECompiler(isCancelled) then -- 2706
			if isCancelled and isCancelled() then -- 2707
				return { -- 2708
					success = false, -- 2708
					file = file, -- 2708
					message = "build canceled", -- 2708
					interrupted = true -- 2708
				} -- 2708
			end -- 2707
			return { -- 2709
				success = false, -- 2709
				file = file, -- 2709
				message = "TypeScript transpiler is not ready", -- 2709
				failureKind = "tool" -- 2709
			} -- 2709
		end -- 2706
		tsBuildRequestId = tsBuildRequestId + 1 -- 2710
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2711
		local done = false -- 2712
		local result = nil -- 2713
		local listener = Node() -- 2714
		listener:gslot("AppWS", function(event) -- 2715
			if event.type == "Receive" then -- 2716
				local res = json.decode(event.msg) -- 2717
				if res then -- 2717
					if res.name == "TranspileTS" and res.id == requestId then -- 2718
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2719
							local luaFile = Path:replaceExt(file, "lua") -- 2720
							if Content:save(luaFile, res.luaCode) then -- 2721
								result = { -- 2722
									success = true, -- 2722
									file = file -- 2722
								} -- 2722
							else -- 2724
								result = { -- 2724
									success = false, -- 2724
									file = file, -- 2724
									message = "failed to save " .. tostring(luaFile) -- 2724
								} -- 2724
							end -- 2721
						else -- 2726
							result = { -- 2726
								success = false, -- 2726
								file = file, -- 2726
								message = res.message or "Compiler returned no Lua output", -- 2726
								failureKind = _anon_func_9(res) -- 2726
							} -- 2726
						end -- 2719
						done = true -- 2727
					end -- 2718
				end -- 2717
			end -- 2716
		end) -- 2715
		emit("AppWS", "Send", json.encode({ -- 2728
			name = "TranspileTS", -- 2728
			id = requestId, -- 2728
			file = file, -- 2728
			content = content, -- 2728
			projectRoot = sourceRoot, -- 2728
			files = files -- 2728
		})) -- 2728
		local deadline = App.runningTime + 30 -- 2729
		wait(function() -- 2730
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2730
		end) -- 2730
		listener:removeFromParent() -- 2731
		if not done then -- 2732
			webIDECompilerReady = false -- 2733
			if isCancelled and isCancelled() then -- 2734
				return { -- 2735
					success = false, -- 2735
					file = file, -- 2735
					message = "build canceled", -- 2735
					interrupted = true -- 2735
				} -- 2735
			end -- 2734
			return { -- 2736
				success = false, -- 2736
				file = file, -- 2736
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2736
				failureKind = "tool" -- 2736
			} -- 2736
		end -- 2732
		return result -- 2737
	end -- 2705
end -- 2703
local compilerReadyTimeout <const> = 15 -- 2739
local compilerBuildTimeout <const> = 30 -- 2740
local compilerIdleCloseSeconds <const> = 8 -- 2741
local compilerReady = false -- 2742
local compilerRequested = false -- 2743
local compilerFailure = nil -- 2744
local compilerUsers = 0 -- 2745
local compilerCloseGeneration = 0 -- 2746
local compilerJobId = 0 -- 2747
local compilerJobs = { } -- 2748
local compilerResults = { } -- 2749
local compilerInFlight = { } -- 2750
HttpServer:post("/compiler/ready", function() -- 2752
	if not compilerRequested then -- 2753
		return { -- 2753
			success = false -- 2753
		} -- 2753
	end -- 2753
	compilerReady = true -- 2754
	return { -- 2755
		success = true -- 2755
	} -- 2755
end) -- 2752
HttpServer:post("/compiler/failure", function(req) -- 2757
	if not compilerRequested then -- 2758
		return { -- 2758
			success = false -- 2758
		} -- 2758
	end -- 2758
	do -- 2759
		local _type_0 = type(req) -- 2759
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2759
		if _tab_0 then -- 2759
			local message -- 2759
			do -- 2759
				local _obj_0 = req.body -- 2759
				local _type_1 = type(_obj_0) -- 2759
				if "table" == _type_1 or "userdata" == _type_1 then -- 2759
					message = _obj_0.message -- 2759
				end -- 2759
			end -- 2759
			if message ~= nil then -- 2759
				if type(message) == "string" then -- 2760
					compilerFailure = message -- 2761
					compilerReady = false -- 2762
					return { -- 2763
						success = true -- 2763
					} -- 2763
				end -- 2760
			end -- 2759
		end -- 2759
	end -- 2759
	return { -- 2757
		success = false -- 2757
	} -- 2757
end) -- 2757
HttpServer:postSchedule("/compiler/poll", function() -- 2765
	if not compilerRequested then -- 2766
		return { -- 2766
			success = false -- 2766
		} -- 2766
	end -- 2766
	compilerReady = true -- 2767
	local deadline = App.runningTime + 5 -- 2768
	wait(function() -- 2769
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2769
	end) -- 2769
	if not (compilerRequested and not compilerFailure) then -- 2770
		return { -- 2770
			success = false -- 2770
		} -- 2770
	end -- 2770
	local job = table.remove(compilerJobs, 1) -- 2771
	if job then -- 2772
		compilerInFlight[job.id] = true -- 2773
	end -- 2772
	return { -- 2774
		success = true, -- 2774
		job = job -- 2774
	} -- 2774
end) -- 2765
HttpServer:post("/compiler/result", function(req) -- 2776
	do -- 2777
		local _type_0 = type(req) -- 2777
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2777
		if _tab_0 then -- 2777
			local body = req.body -- 2777
			if body ~= nil then -- 2777
				local id = body.id -- 2778
				if not (id and compilerInFlight[id]) then -- 2779
					return { -- 2779
						success = false, -- 2779
						message = "invalid compiler job" -- 2779
					} -- 2779
				end -- 2779
				compilerInFlight[id] = nil -- 2780
				compilerResults[id] = body -- 2781
				return { -- 2782
					success = true -- 2782
				} -- 2782
			end -- 2777
		end -- 2777
	end -- 2777
	return { -- 2776
		success = false -- 2776
	} -- 2776
end) -- 2776
local acquireCompiler -- 2784
acquireCompiler = function() -- 2784
	compilerUsers = compilerUsers + 1 -- 2785
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2786
	if not compilerRequested then -- 2787
		compilerRequested = true -- 2788
		compilerReady = false -- 2789
		compilerFailure = nil -- 2790
		return emit("AppWebView", "/compiler.html", true) -- 2791
	end -- 2787
end -- 2784
local releaseCompiler -- 2793
releaseCompiler = function() -- 2793
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2794
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2795
	if not (compilerUsers == 0) then -- 2796
		return -- 2796
	end -- 2796
	local closeGeneration = compilerCloseGeneration -- 2797
	return thread(function() -- 2798
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2799
		wait(function() -- 2800
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2801
		end) -- 2800
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2806
			compilerRequested = false -- 2807
			compilerReady = false -- 2808
			return emit("AppWebView", "/compiler.html", false) -- 2809
		end -- 2806
	end) -- 2798
end -- 2793
local removeCompilerJob -- 2811
removeCompilerJob = function(id) -- 2811
	for index = #compilerJobs, 1, -1 do -- 2812
		if compilerJobs[index].id == id then -- 2813
			table.remove(compilerJobs, index) -- 2814
		end -- 2813
	end -- 2812
	compilerInFlight[id] = nil -- 2815
	compilerResults[id] = nil -- 2816
end -- 2811
local transpileTSFileWithCompiler -- 2818
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2818
	acquireCompiler() -- 2819
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2820
	wait(function() -- 2821
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2821
	end) -- 2821
	if not compilerReady then -- 2822
		releaseCompiler() -- 2823
		if isCancelled and isCancelled() then -- 2824
			return { -- 2825
				success = false, -- 2825
				file = file, -- 2825
				message = "build canceled", -- 2825
				interrupted = true -- 2825
			} -- 2825
		end -- 2824
		return { -- 2826
			success = false, -- 2826
			file = file, -- 2826
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2826
			failureKind = "tool" -- 2826
		} -- 2826
	end -- 2822
	compilerJobId = compilerJobId + 1 -- 2827
	local jobId = compilerJobId -- 2828
	compilerJobs[#compilerJobs + 1] = { -- 2830
		id = jobId, -- 2830
		file = file, -- 2831
		content = content, -- 2832
		projectRoot = sourceRoot, -- 2833
		files = files -- 2834
	} -- 2829
	local deadline = App.runningTime + compilerBuildTimeout -- 2835
	wait(function() -- 2836
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2836
	end) -- 2836
	local response = compilerResults[jobId] -- 2837
	removeCompilerJob(jobId) -- 2838
	releaseCompiler() -- 2839
	if not response then -- 2840
		if isCancelled and isCancelled() then -- 2841
			return { -- 2842
				success = false, -- 2842
				file = file, -- 2842
				message = "build canceled", -- 2842
				interrupted = true -- 2842
			} -- 2842
		end -- 2841
		return { -- 2843
			success = false, -- 2843
			file = file, -- 2843
			message = compilerFailure or "TypeScript transpile timed out", -- 2843
			failureKind = "tool" -- 2843
		} -- 2843
	end -- 2840
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2844
		local luaFile = Path:replaceExt(file, "lua") -- 2845
		if Content:save(luaFile, response.luaCode) then -- 2846
			return { -- 2847
				success = true, -- 2847
				file = file -- 2847
			} -- 2847
		end -- 2846
		return { -- 2848
			success = false, -- 2848
			file = file, -- 2848
			message = "failed to save " .. tostring(luaFile) -- 2848
		} -- 2848
	end -- 2844
	return { -- 2849
		success = false, -- 2849
		file = file, -- 2849
		message = response.message or "TypeScript transpile failed" -- 2849
	} -- 2849
end -- 2818
local compilerFailureListener = Node() -- 2851
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2852
	compilerFailure = message -- 2853
	compilerReady = false -- 2854
end) -- 2852
local transpileTSFile -- 2856
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2856
	if supportsCompilerWebView() and not files then -- 2857
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2858
	end -- 2857
	if HttpServer.wsConnectionCount > 0 then -- 2859
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2860
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2861
			return result -- 2861
		end -- 2861
		webIDECompilerReady = false -- 2862
	end -- 2859
	if supportsCompilerWebView() then -- 2863
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2864
	end -- 2863
	return { -- 2865
		success = false, -- 2865
		file = file, -- 2865
		message = "Web IDE compiler not connected", -- 2865
		failureKind = "tool" -- 2865
	} -- 2865
end -- 2856
local _anon_func_10 = function(path) -- 2880
	local _val_0 = Path:getExt(path) -- 2880
	return "ts" == _val_0 or "tsx" == _val_0 -- 2880
end -- 2880
HttpServer:postSchedule("/ts/build", function(req) -- 2867
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2868
	local buildSucceeded = false -- 2869
	local _ <close> = setmetatable({ }, { -- 2870
		__close = function() -- 2870
			return finishUpdate(buildSucceeded) -- 2870
		end -- 2870
	}) -- 2870
	do -- 2871
		local _type_0 = type(req) -- 2871
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2871
		if _tab_0 then -- 2871
			local path -- 2871
			do -- 2871
				local _obj_0 = req.body -- 2871
				local _type_1 = type(_obj_0) -- 2871
				if "table" == _type_1 or "userdata" == _type_1 then -- 2871
					path = _obj_0.path -- 2871
				end -- 2871
			end -- 2871
			if path ~= nil then -- 2871
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2872
					return { -- 2873
						success = false, -- 2873
						message = "Web IDE not connected" -- 2873
					} -- 2873
				end -- 2872
				local projectRoot = req.body.projectRoot -- 2874
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2875
				if not Content:exist(path) then -- 2876
					return { -- 2877
						success = false, -- 2877
						message = "path not existed" -- 2877
					} -- 2877
				end -- 2876
				local messages = { } -- 2878
				if not Content:isdir(path) then -- 2879
					if not (_anon_func_10(path)) then -- 2880
						return { -- 2881
							success = false, -- 2881
							message = "expecting a TypeScript file" -- 2881
						} -- 2881
					end -- 2880
					local content = Content:load(path) -- 2882
					if not content then -- 2883
						return { -- 2884
							success = false, -- 2884
							message = "failed to read file" -- 2884
						} -- 2884
					end -- 2883
					emit("AppWS", "Send", json.encode({ -- 2885
						name = "UpdateFile", -- 2885
						file = path, -- 2885
						exists = true, -- 2885
						content = content, -- 2885
						projectRoot = sourceRoot -- 2885
					})) -- 2885
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2886
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2887
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2888
					end -- 2886
				else -- 2890
					local fileData = { } -- 2890
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2891
					for _index_0 = 1, #_list_0 do -- 2891
						local subFile = _list_0[_index_0] -- 2891
						local file = Path(path, subFile) -- 2892
						local content = Content:load(file) -- 2893
						if content then -- 2893
							fileData[file] = content -- 2894
							emit("AppWS", "Send", json.encode({ -- 2895
								name = "UpdateFile", -- 2895
								file = file, -- 2895
								exists = true, -- 2895
								content = content, -- 2895
								projectRoot = sourceRoot -- 2895
							})) -- 2895
						else -- 2897
							messages[#messages + 1] = { -- 2897
								success = false, -- 2897
								file = file, -- 2897
								message = "failed to read file" -- 2897
							} -- 2897
						end -- 2893
					end -- 2891
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2898
					for file, content in pairs(fileData) do -- 2899
						if "d" == Path:getExt(Path:getName(file)) then -- 2900
							goto _continue_0 -- 2900
						end -- 2900
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2901
						::_continue_0:: -- 2900
					end -- 2899
				end -- 2879
				local success = true -- 2902
				for _index_0 = 1, #messages do -- 2903
					local item = messages[_index_0] -- 2903
					if not item.success then -- 2904
						success = false -- 2904
					end -- 2904
				end -- 2903
				local message = nil -- 2905
				if not success then -- 2906
					message = "TypeScript compilation failed" -- 2906
				end -- 2906
				buildSucceeded = success -- 2907
				return { -- 2908
					success = success, -- 2908
					messages = messages, -- 2908
					message = message -- 2908
				} -- 2908
			end -- 2871
		end -- 2871
	end -- 2871
	return { -- 2867
		success = false -- 2867
	} -- 2867
end) -- 2867
HttpServer:post("/download", function(req) -- 2910
	do -- 2911
		local _type_0 = type(req) -- 2911
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2911
		if _tab_0 then -- 2911
			local url -- 2911
			do -- 2911
				local _obj_0 = req.body -- 2911
				local _type_1 = type(_obj_0) -- 2911
				if "table" == _type_1 or "userdata" == _type_1 then -- 2911
					url = _obj_0.url -- 2911
				end -- 2911
			end -- 2911
			local target -- 2911
			do -- 2911
				local _obj_0 = req.body -- 2911
				local _type_1 = type(_obj_0) -- 2911
				if "table" == _type_1 or "userdata" == _type_1 then -- 2911
					target = _obj_0.target -- 2911
				end -- 2911
			end -- 2911
			if url ~= nil and target ~= nil then -- 2911
				local Entry = require("Script.Dev.Entry") -- 2912
				Entry.downloadFile(url, target) -- 2913
				return { -- 2914
					success = true -- 2914
				} -- 2914
			end -- 2911
		end -- 2911
	end -- 2911
	return { -- 2910
		success = false -- 2910
	} -- 2910
end) -- 2910
local isDesktopPlatform -- 2916
isDesktopPlatform = function() -- 2916
	local _val_0 = App.platform -- 2917
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2917
end -- 2916
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 2919
local nativeIDEListener = Node() -- 2920
nativeIDEListener:addTo(Director.systemUI) -- 2921
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 2922
	nativeIDEState, nativeIDEMessage = state, message -- 2923
end) -- 2922
local _anon_func_11 = function() -- 2926
	local _val_0 = App.platform -- 2926
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2926
end -- 2926
HttpServer:post("/ide", function(req) -- 2925
	if not (_anon_func_11()) then -- 2926
		return { -- 2926
			success = false, -- 2926
			message = "Native IDE is unavailable" -- 2926
		} -- 2926
	end -- 2926
	if not App.webIDEEnabled then -- 2927
		return { -- 2927
			success = false, -- 2927
			message = "Embedded Web IDE is disabled" -- 2927
		} -- 2927
	end -- 2927
	do -- 2928
		local _type_0 = type(req) -- 2928
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2928
		if _tab_0 then -- 2928
			local action -- 2928
			do -- 2928
				local _obj_0 = req.body -- 2928
				local _type_1 = type(_obj_0) -- 2928
				if "table" == _type_1 or "userdata" == _type_1 then -- 2928
					action = _obj_0.action -- 2928
				end -- 2928
			end -- 2928
			if action ~= nil then -- 2928
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 2929
					emit("AppWebView", "/ide/" .. action, true) -- 2930
					return { -- 2931
						success = true -- 2931
					} -- 2931
				end -- 2929
			end -- 2928
		end -- 2928
	end -- 2928
	return { -- 2925
		success = false, -- 2925
		message = "invalid IDE action" -- 2925
	} -- 2925
end) -- 2925
local _anon_func_12 = function() -- 2947
	local _val_0 = App.platform -- 2947
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2947
end -- 2947
local getServerStatus -- 2933
getServerStatus = function() -- 2933
	local Entry = require("Script.Dev.Entry") -- 2934
	local running = Entry.getCurrentEntryStatus() -- 2935
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2936
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2937
	return { -- 2939
		success = true, -- 2939
		platform = App.platform, -- 2940
		locale = App.locale, -- 2941
		version = App.version, -- 2942
		url = "http://localhost:8866", -- 2943
		wsConnectionCount = wsConnectionCount, -- 2944
		webIDEConnected = wsConnectionCount > 0, -- 2945
		nativeIDE = { -- 2947
			supported = _anon_func_12(), -- 2947
			enabled = App.webIDEEnabled, -- 2948
			state = nativeIDEState, -- 2949
			message = nativeIDEMessage -- 2950
		}, -- 2946
		typescriptCompiler = { -- 2952
			webIDEReady = webIDECompilerReady, -- 2952
			webIDEGeneration = webIDEConnectionGeneration, -- 2953
			embeddedSupported = supportsCompilerWebView(), -- 2954
			embeddedRequested = compilerRequested, -- 2955
			embeddedReady = compilerReady, -- 2956
			users = compilerUsers, -- 2957
			queuedJobs = #compilerJobs, -- 2958
			failure = compilerFailure -- 2959
		}, -- 2951
		assetPath = Content.assetPath, -- 2960
		writablePath = Content.writablePath, -- 2961
		appPath = Content.appPath, -- 2962
		waTemplateReady = waTemplateReady, -- 2963
		running = running -- 2964
	} -- 2938
end -- 2933
HttpServer:post("/status", function() -- 2967
	return getServerStatus() -- 2968
end) -- 2967
HttpServer:postSchedule("/doctor/fix", function(req) -- 2970
	do -- 2971
		local _type_0 = type(req) -- 2971
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2971
		if _tab_0 then -- 2971
			local openWebIDE -- 2971
			do -- 2971
				local _obj_0 = req.body -- 2971
				local _type_1 = type(_obj_0) -- 2971
				if "table" == _type_1 or "userdata" == _type_1 then -- 2971
					openWebIDE = _obj_0.openWebIDE -- 2971
				end -- 2971
			end -- 2971
			if openWebIDE ~= nil then -- 2971
				if not openWebIDE then -- 2972
					return { -- 2973
						success = false, -- 2973
						message = "nothing to fix" -- 2973
					} -- 2973
				end -- 2972
				local status = getServerStatus() -- 2974
				if status.webIDEConnected then -- 2975
					return { -- 2976
						success = true, -- 2976
						fixed = false, -- 2976
						message = "Web IDE already connected.", -- 2976
						status = status -- 2976
					} -- 2976
				end -- 2975
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2977
				if waitSeconds > 0 then -- 2978
					local deadline = os.time() + waitSeconds -- 2979
					repeat -- 2980
						sleep(0.2) -- 2981
						status = getServerStatus() -- 2982
						if status.webIDEConnected then -- 2983
							return { -- 2984
								success = true, -- 2984
								fixed = false, -- 2984
								reconnected = true, -- 2984
								message = "Web IDE reconnected.", -- 2984
								status = status -- 2984
							} -- 2984
						end -- 2983
					until os.time() >= deadline -- 2980
				end -- 2978
				if not isDesktopPlatform() then -- 2986
					return { -- 2987
						success = false, -- 2987
						message = "opening Web IDE is only supported on desktop platforms", -- 2987
						status = status -- 2987
					} -- 2987
				end -- 2986
				local url = "http://localhost:8866" -- 2988
				App:openURL(url) -- 2989
				status.openedURL = url -- 2990
				return { -- 2991
					success = true, -- 2991
					fixed = true, -- 2991
					message = "Opened Web IDE in the local browser.", -- 2991
					url = url, -- 2991
					status = status -- 2991
				} -- 2991
			end -- 2971
		end -- 2971
	end -- 2971
	return { -- 2970
		success = false, -- 2970
		message = "invalid call" -- 2970
	} -- 2970
end) -- 2970
local status = { } -- 2993
_module_0 = status -- 2994
status.transpileTSFile = transpileTSFile -- 2996
status.buildAsync = function(path) -- 2998
	if not Content:exist(path) then -- 2999
		return { -- 3000
			success = false, -- 3000
			file = path, -- 3000
			message = "file not existed" -- 3000
		} -- 3000
	end -- 2999
	do -- 3001
		local _exp_0 = Path:getExt(path) -- 3001
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 3001
			if '' == Path:getExt(Path:getName(path)) then -- 3002
				local content = Content:loadAsync(path) -- 3003
				if content then -- 3003
					local resultCodes, err = compileFileAsync(path, content) -- 3004
					if resultCodes then -- 3004
						return { -- 3005
							success = true, -- 3005
							file = path -- 3005
						} -- 3005
					else -- 3007
						return { -- 3007
							success = false, -- 3007
							file = path, -- 3007
							message = err -- 3007
						} -- 3007
					end -- 3004
				end -- 3003
			end -- 3002
		elseif "lua" == _exp_0 then -- 3008
			local content = Content:loadAsync(path) -- 3009
			if content then -- 3009
				do -- 3010
					local isTIC80 = CheckTIC80Code(content) -- 3010
					if isTIC80 then -- 3010
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 3011
					end -- 3010
				end -- 3010
				local success, info -- 3012
				do -- 3012
					local _obj_0 = luaCheck(path, content) -- 3012
					success, info = _obj_0.success, _obj_0.info -- 3012
				end -- 3012
				if success then -- 3013
					return { -- 3014
						success = true, -- 3014
						file = path -- 3014
					} -- 3014
				elseif info and #info > 0 then -- 3015
					local messages = { } -- 3016
					for _index_0 = 1, #info do -- 3017
						local _des_0 = info[_index_0] -- 3017
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3017
						local lineText = "" -- 3018
						if line then -- 3019
							local currentLine = 1 -- 3020
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3021
								if currentLine == line then -- 3022
									lineText = text -- 3023
									break -- 3024
								end -- 3022
								currentLine = currentLine + 1 -- 3025
							end -- 3021
						end -- 3019
						if line then -- 3026
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3027
						else -- 3029
							messages[#messages + 1] = message -- 3029
						end -- 3026
					end -- 3017
					return { -- 3030
						success = false, -- 3030
						file = path, -- 3030
						message = table.concat(messages, "\n") -- 3030
					} -- 3030
				else -- 3032
					return { -- 3032
						success = false, -- 3032
						file = path, -- 3032
						message = "lua check failed" -- 3032
					} -- 3032
				end -- 3013
			end -- 3009
		elseif "yarn" == _exp_0 then -- 3033
			local content = Content:loadAsync(path) -- 3034
			if content then -- 3034
				local res, _, err = yarncompile(content, true) -- 3035
				if res then -- 3035
					return { -- 3036
						success = true, -- 3036
						file = path -- 3036
					} -- 3036
				else -- 3038
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3038
					local lineText = "" -- 3039
					if line then -- 3040
						local currentLine = 1 -- 3041
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3042
							if currentLine == line then -- 3043
								lineText = text -- 3044
								break -- 3045
							end -- 3043
							currentLine = currentLine + 1 -- 3046
						end -- 3042
					end -- 3040
					if node ~= "" then -- 3047
						node = "node: " .. tostring(node) .. ", " -- 3048
					else -- 3049
						node = "" -- 3049
					end -- 3047
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3050
					return { -- 3051
						success = false, -- 3051
						file = path, -- 3051
						message = message -- 3051
					} -- 3051
				end -- 3035
			end -- 3034
		end -- 3001
	end -- 3001
	return { -- 3052
		success = false, -- 3052
		file = path, -- 3052
		message = "invalid file to build" -- 3052
	} -- 3052
end -- 2998
HttpServer:postSchedule("/git/commit-files", function(req) -- 3054
	do -- 3055
		local _type_0 = type(req) -- 3055
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3055
		if _tab_0 then -- 3055
			local body = req.body -- 3055
			if body ~= nil then -- 3055
				local repoPath, commit = body.repoPath, body.commit -- 3056
				if gitInvalidRepoPath(repoPath) then -- 3057
					return { -- 3057
						success = false, -- 3057
						message = "invalid repoPath" -- 3057
					} -- 3057
				end -- 3057
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3058
					return { -- 3058
						success = false, -- 3058
						message = "invalid commit" -- 3058
					} -- 3058
				end -- 3058
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3059
				if not res.success then -- 3060
					return res -- 3060
				end -- 3060
				return { -- 3061
					success = true, -- 3061
					status = res.status, -- 3061
					data = res.status and res.status.data -- 3061
				} -- 3061
			end -- 3055
		end -- 3055
	end -- 3055
	return invalidArguments -- 3054
end) -- 3054
thread(function() -- 3063
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3064
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3065
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3066
		local storedAsset -- 3069
		storedAsset = function(file) -- 3069
			if Content:exist(file) then -- 3070
				return Content:load(file) -- 3071
			elseif Content:exist(file .. ".gz") then -- 3072
				return Content:load(file .. ".gz") -- 3073
			else -- 3074
				return "" -- 3074
			end -- 3070
		end -- 3069
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3075
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3076
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3077
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3078
		local readyContent = table.concat({ -- 3080
			App.version, -- 3080
			storedAsset(doraWeb), -- 3081
			storedAsset(heavyAssets), -- 3082
			storedAsset(runtimeIndex), -- 3083
			storedAsset(compilerIndex), -- 3084
			storedAsset(manifest) -- 3085
		}, "\n") -- 3079
		local needReload -- 3087
		if Content:exist(doraReady) then -- 3087
			needReload = readyContent ~= Content:load(doraReady) -- 3088
		else -- 3089
			needReload = true -- 3089
		end -- 3087
		if needReload then -- 3090
			Content:remove(Path(Content.appPath, ".www")) -- 3091
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3092
			Content:save(doraReady, readyContent) -- 3096
			print("Dora Dora is ready!") -- 3097
		end -- 3090
	end -- 3066
	if App.platform == "Emscripten" then -- 3098
		status.url = nil -- 3099
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3100
	end -- 3098
	HttpServer:clearStaticCacheControls() -- 3101
	HttpServer:setStaticCacheControl("no-cache") -- 3102
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3103
	if HttpServer:start(8866) then -- 3107
		local localIP = HttpServer.localIP -- 3108
		if localIP == "" then -- 3109
			localIP = "localhost" -- 3109
		end -- 3109
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3110
		return HttpServer:startWS(8868) -- 3111
	else -- 3113
		status.url = nil -- 3113
		return print("8866 Port not available!") -- 3114
	end -- 3107
end) -- 3063
return _module_0 -- 1
