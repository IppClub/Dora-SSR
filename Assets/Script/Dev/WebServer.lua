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
local AgentLocalAgent = AgentHost.proxy("Agent.Runtime.LocalAgent") -- 144
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
	require("Agent.Config.LLMConfigMigration").upgradeLLMConfig() -- 1535
	return require("Agent.Config.LLMConfigNames").upgradeLLMConfigNames() -- 1536
end -- 1474
local normalizeContextWindow -- 1538
normalizeContextWindow = function(value) -- 1538
	local contextWindow = tonumber(value) -- 1539
	if contextWindow == nil or contextWindow < 64000 then -- 1540
		return 64000 -- 1541
	end -- 1540
	return math.max(64000, math.floor(contextWindow)) -- 1542
end -- 1538
local normalizeTemperature -- 1544
normalizeTemperature = function(value) -- 1544
	local temperature = tonumber(value) -- 1545
	if temperature == nil then -- 1546
		return 0.1 -- 1547
	end -- 1546
	return math.max(0, math.min(2, temperature)) -- 1548
end -- 1544
local normalizeMaxTokens -- 1550
normalizeMaxTokens = function(value) -- 1550
	local maxTokens = tonumber(value) -- 1551
	if maxTokens == nil or maxTokens < 1 then -- 1552
		return 64000 -- 1553
	end -- 1552
	return math.max(1, math.floor(maxTokens)) -- 1554
end -- 1550
local normalizeReasoningEffort -- 1556
normalizeReasoningEffort = function(value) -- 1556
	if value == nil then -- 1557
		return "" -- 1558
	end -- 1557
	local effort = tostring(value) -- 1559
	return effort:match("^%s*(.-)%s*$") or "" -- 1560
end -- 1556
local normalizeCustomOptions -- 1562
normalizeCustomOptions = function(value) -- 1562
	if value == nil then -- 1563
		return "" -- 1564
	end -- 1563
	local options = tostring(value) -- 1565
	options = options:match("^%s*(.-)%s*$") or "" -- 1566
	return options -- 1567
end -- 1562
local validateCustomOptions -- 1569
validateCustomOptions = function(value) -- 1569
	local options = normalizeCustomOptions(value) -- 1570
	if options == "" then -- 1571
		return true -- 1571
	end -- 1571
	if not options:match("^%s*{") then -- 1572
		return false -- 1572
	end -- 1572
	local decoded = json.decode(options) -- 1573
	return type(decoded) == "table" -- 1574
end -- 1569
HttpServer:post("/llm/list", function() -- 1576
	ensureLLMConfigTable() -- 1577
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1578
	local items -- 1582
	if rows and #rows > 0 then -- 1582
		local _accum_0 = { } -- 1583
		local _len_0 = 1 -- 1583
		for _index_0 = 1, #rows do -- 1583
			local _des_0 = rows[_index_0] -- 1583
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1583
			_accum_0[_len_0] = { -- 1584
				id = id, -- 1584
				name = name, -- 1584
				url = url, -- 1584
				model = model, -- 1584
				key = key, -- 1584
				contextWindow = normalizeContextWindow(contextWindow), -- 1584
				temperature = normalizeTemperature(temperature), -- 1584
				maxTokens = normalizeMaxTokens(maxTokens), -- 1584
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1584
				customOptions = normalizeCustomOptions(customOptions), -- 1584
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1584
			} -- 1584
			_len_0 = _len_0 + 1 -- 1584
		end -- 1583
		items = _accum_0 -- 1582
	end -- 1582
	return { -- 1585
		success = true, -- 1585
		items = items -- 1585
	} -- 1585
end) -- 1576
HttpServer:post("/llm/create", function(req) -- 1587
	ensureLLMConfigTable() -- 1588
	do -- 1589
		local _type_0 = type(req) -- 1589
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1589
		if _tab_0 then -- 1589
			local body = req.body -- 1589
			if body ~= nil then -- 1589
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1590
				local now = os.time() -- 1591
				if name == nil or url == nil or model == nil or key == nil then -- 1592
					return invalidArguments -- 1593
				end -- 1592
				local names = require("Agent.Config.LLMConfigNames") -- 1594
				name = names.normalizeLLMConfigName(name) -- 1595
				if not name then -- 1596
					return { -- 1596
						success = false, -- 1596
						code = "INVALID_LLM_CONFIG_NAME", -- 1596
						message = "LLM configuration name must be a non-empty string" -- 1596
					} -- 1596
				end -- 1596
				local nameCheck = names.checkLLMConfigName(name) -- 1597
				if not nameCheck.success then -- 1598
					return nameCheck -- 1598
				end -- 1598
				contextWindow = normalizeContextWindow(contextWindow) -- 1599
				temperature = normalizeTemperature(temperature) -- 1600
				maxTokens = normalizeMaxTokens(maxTokens) -- 1601
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1602
				customOptions = normalizeCustomOptions(customOptions) -- 1603
				if not validateCustomOptions(customOptions) then -- 1604
					return { -- 1604
						success = false, -- 1604
						message = "customOptions must be a JSON object" -- 1604
					} -- 1604
				end -- 1604
				if supportsFunctionCalling == false then -- 1605
					supportsFunctionCalling = 0 -- 1605
				else -- 1605
					supportsFunctionCalling = 1 -- 1605
				end -- 1605
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1612
					tostring(name), -- 1612
					tostring(url), -- 1613
					tostring(model), -- 1614
					tostring(key), -- 1615
					contextWindow, -- 1616
					temperature, -- 1617
					maxTokens, -- 1618
					reasoningEffort, -- 1619
					customOptions, -- 1620
					supportsFunctionCalling, -- 1621
					1, -- 1622
					now, -- 1623
					now -- 1624
				}) -- 1606
				if affected < 0 then -- 1626
					nameCheck = names.checkLLMConfigName(name) -- 1627
					if not nameCheck.success then -- 1628
						return nameCheck -- 1628
					end -- 1628
				end -- 1626
				return { -- 1629
					success = affected > 0 -- 1629
				} -- 1629
			end -- 1589
		end -- 1589
	end -- 1589
	return invalidArguments -- 1587
end) -- 1587
HttpServer:post("/llm/update", function(req) -- 1631
	ensureLLMConfigTable() -- 1632
	do -- 1633
		local _type_0 = type(req) -- 1633
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1633
		if _tab_0 then -- 1633
			local body = req.body -- 1633
			if body ~= nil then -- 1633
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1634
				local now = os.time() -- 1635
				id = tonumber(id) -- 1636
				if id == nil or id <= 0 or id ~= math.floor(id) then -- 1637
					return invalidArguments -- 1637
				end -- 1637
				local names = require("Agent.Config.LLMConfigNames") -- 1638
				name = names.normalizeLLMConfigName(name) -- 1639
				if not name then -- 1640
					return { -- 1640
						success = false, -- 1640
						code = "INVALID_LLM_CONFIG_NAME", -- 1640
						message = "LLM configuration name must be a non-empty string" -- 1640
					} -- 1640
				end -- 1640
				local nameCheck = names.checkLLMConfigName(name, id) -- 1641
				if not nameCheck.success then -- 1642
					return nameCheck -- 1642
				end -- 1642
				contextWindow = normalizeContextWindow(contextWindow) -- 1643
				temperature = normalizeTemperature(temperature) -- 1644
				maxTokens = normalizeMaxTokens(maxTokens) -- 1645
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1646
				customOptions = normalizeCustomOptions(customOptions) -- 1647
				if not validateCustomOptions(customOptions) then -- 1648
					return { -- 1648
						success = false, -- 1648
						message = "customOptions must be a JSON object" -- 1648
					} -- 1648
				end -- 1648
				if supportsFunctionCalling == false then -- 1649
					supportsFunctionCalling = 0 -- 1649
				else -- 1649
					supportsFunctionCalling = 1 -- 1649
				end -- 1649
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1654
					tostring(name), -- 1654
					tostring(url), -- 1655
					tostring(model), -- 1656
					tostring(key), -- 1657
					contextWindow, -- 1658
					temperature, -- 1659
					maxTokens, -- 1660
					reasoningEffort, -- 1661
					customOptions, -- 1662
					supportsFunctionCalling, -- 1663
					now, -- 1664
					id -- 1665
				}) -- 1650
				if affected < 0 then -- 1667
					nameCheck = names.checkLLMConfigName(name, id) -- 1668
					if not nameCheck.success then -- 1669
						return nameCheck -- 1669
					end -- 1669
				end -- 1667
				return { -- 1670
					success = affected > 0 -- 1670
				} -- 1670
			end -- 1633
		end -- 1633
	end -- 1633
	return invalidArguments -- 1631
end) -- 1631
HttpServer:post("/llm/delete", function(req) -- 1672
	ensureLLMConfigTable() -- 1673
	do -- 1674
		local _type_0 = type(req) -- 1674
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1674
		if _tab_0 then -- 1674
			local id -- 1674
			do -- 1674
				local _obj_0 = req.body -- 1674
				local _type_1 = type(_obj_0) -- 1674
				if "table" == _type_1 or "userdata" == _type_1 then -- 1674
					id = _obj_0.id -- 1674
				end -- 1674
			end -- 1674
			if id ~= nil then -- 1674
				id = tonumber(id) -- 1675
				if id == nil then -- 1676
					return invalidArguments -- 1676
				end -- 1676
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1677
					id -- 1677
				}) -- 1677
				return { -- 1678
					success = affected >= 0 -- 1678
				} -- 1678
			end -- 1674
		end -- 1674
	end -- 1674
	return invalidArguments -- 1672
end) -- 1672
HttpServer:post("/local-agent/list", function() -- 1680
	return { -- 1681
		success = true, -- 1681
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1681
		items = AgentLocalAgent.listConfigs() -- 1681
	} -- 1681
end) -- 1680
HttpServer:post("/local-agent/save", function(req) -- 1683
	do -- 1684
		local _type_0 = type(req) -- 1684
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1684
		if _tab_0 then -- 1684
			local body = req.body -- 1684
			if body ~= nil then -- 1684
				return AgentLocalAgent.saveConfig(body) -- 1685
			end -- 1684
		end -- 1684
	end -- 1684
	return invalidArguments -- 1683
end) -- 1683
HttpServer:post("/local-agent/delete", function(req) -- 1687
	do -- 1688
		local _type_0 = type(req) -- 1688
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1688
		if _tab_0 then -- 1688
			local id -- 1688
			do -- 1688
				local _obj_0 = req.body -- 1688
				local _type_1 = type(_obj_0) -- 1688
				if "table" == _type_1 or "userdata" == _type_1 then -- 1688
					id = _obj_0.id -- 1688
				end -- 1688
			end -- 1688
			if id ~= nil then -- 1688
				return AgentLocalAgent.deleteConfig(id) -- 1689
			end -- 1688
		end -- 1688
	end -- 1688
	return invalidArguments -- 1687
end) -- 1687
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1691
	do -- 1692
		local _type_0 = type(req) -- 1692
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1692
		if _tab_0 then -- 1692
			local id -- 1692
			do -- 1692
				local _obj_0 = req.body -- 1692
				local _type_1 = type(_obj_0) -- 1692
				if "table" == _type_1 or "userdata" == _type_1 then -- 1692
					id = _obj_0.id -- 1692
				end -- 1692
			end -- 1692
			if id ~= nil then -- 1692
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1693
			end -- 1692
		end -- 1692
	end -- 1692
	return invalidArguments -- 1691
end) -- 1691
HttpServer:post("/stat", function(req) -- 1695
	do -- 1696
		local _type_0 = type(req) -- 1696
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1696
		if _tab_0 then -- 1696
			local path -- 1696
			do -- 1696
				local _obj_0 = req.body -- 1696
				local _type_1 = type(_obj_0) -- 1696
				if "table" == _type_1 or "userdata" == _type_1 then -- 1696
					path = _obj_0.path -- 1696
				end -- 1696
			end -- 1696
			if path ~= nil then -- 1696
				if not Content:exist(path) then -- 1697
					return { -- 1698
						success = false, -- 1698
						message = "target not existed" -- 1698
					} -- 1698
				end -- 1697
				if Content:isdir(path) then -- 1699
					return { -- 1700
						success = false, -- 1700
						message = "failed to stat a directory" -- 1700
					} -- 1700
				end -- 1699
				local size, isBinary = Content:getAttr(path) -- 1701
				if size then -- 1701
					return { -- 1702
						success = true, -- 1702
						size = size, -- 1702
						isBinary = isBinary -- 1702
					} -- 1702
				end -- 1701
			end -- 1696
		end -- 1696
	end -- 1696
	return { -- 1695
		success = false, -- 1695
		message = "failed to stat" -- 1695
	} -- 1695
end) -- 1695
HttpServer:post("/new", function(req) -- 1704
	do -- 1705
		local _type_0 = type(req) -- 1705
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1705
		if _tab_0 then -- 1705
			local path -- 1705
			do -- 1705
				local _obj_0 = req.body -- 1705
				local _type_1 = type(_obj_0) -- 1705
				if "table" == _type_1 or "userdata" == _type_1 then -- 1705
					path = _obj_0.path -- 1705
				end -- 1705
			end -- 1705
			local content -- 1705
			do -- 1705
				local _obj_0 = req.body -- 1705
				local _type_1 = type(_obj_0) -- 1705
				if "table" == _type_1 or "userdata" == _type_1 then -- 1705
					content = _obj_0.content -- 1705
				end -- 1705
			end -- 1705
			local folder -- 1705
			do -- 1705
				local _obj_0 = req.body -- 1705
				local _type_1 = type(_obj_0) -- 1705
				if "table" == _type_1 or "userdata" == _type_1 then -- 1705
					folder = _obj_0.folder -- 1705
				end -- 1705
			end -- 1705
			if path ~= nil and content ~= nil and folder ~= nil then -- 1705
				if Content:exist(path) then -- 1706
					return { -- 1707
						success = false, -- 1707
						message = "TargetExisted" -- 1707
					} -- 1707
				end -- 1706
				local parent = Path:getPath(path) -- 1708
				local files = Content:getFiles(parent) -- 1709
				if folder then -- 1710
					local name = Path:getFilename(path):lower() -- 1711
					for _index_0 = 1, #files do -- 1712
						local file = files[_index_0] -- 1712
						if name == Path:getFilename(file):lower() then -- 1713
							return { -- 1714
								success = false, -- 1714
								message = "TargetExisted" -- 1714
							} -- 1714
						end -- 1713
					end -- 1712
					if Content:mkdir(path) then -- 1715
						return { -- 1716
							success = true -- 1716
						} -- 1716
					end -- 1715
				else -- 1718
					local name = Path:getName(path):lower() -- 1718
					for _index_0 = 1, #files do -- 1719
						local file = files[_index_0] -- 1719
						if name == Path:getName(file):lower() then -- 1720
							local ext = Path:getExt(file) -- 1721
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1722
								goto _continue_0 -- 1723
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1724
								goto _continue_0 -- 1725
							end -- 1722
							return { -- 1726
								success = false, -- 1726
								message = "SourceExisted" -- 1726
							} -- 1726
						end -- 1720
						::_continue_0:: -- 1720
					end -- 1719
					if Content:save(path, content) then -- 1727
						return { -- 1728
							success = true -- 1728
						} -- 1728
					end -- 1727
				end -- 1710
			end -- 1705
		end -- 1705
	end -- 1705
	return { -- 1704
		success = false, -- 1704
		message = "Failed" -- 1704
	} -- 1704
end) -- 1704
local deleteAsset -- 1730
deleteAsset = function(path) -- 1730
	if not Content:exist(path) then -- 1731
		return false -- 1731
	end -- 1731
	local projectRoot -- 1732
	if Content:isdir(path) and isProjectRootDir(path) then -- 1732
		projectRoot = path -- 1732
	else -- 1732
		projectRoot = nil -- 1732
	end -- 1732
	local parent = Path:getPath(path) -- 1733
	local files = Content:getFiles(parent) -- 1734
	local name = Path:getName(path):lower() -- 1735
	local ext = Path:getExt(path) -- 1736
	for _index_0 = 1, #files do -- 1737
		local file = files[_index_0] -- 1737
		if name == Path:getName(file):lower() then -- 1738
			local _exp_0 = Path:getExt(file) -- 1739
			if "tl" == _exp_0 then -- 1739
				if ("vs" == ext) then -- 1739
					Content:remove(Path(parent, file)) -- 1740
				end -- 1739
			elseif "lua" == _exp_0 then -- 1741
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1741
					Content:remove(Path(parent, file)) -- 1742
				end -- 1741
			end -- 1739
		end -- 1738
	end -- 1737
	if Content:remove(path) then -- 1743
		if projectRoot then -- 1744
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1745
		end -- 1744
		return true -- 1746
	end -- 1743
	return false -- 1747
end -- 1730
local moveAsset -- 1749
moveAsset = function(old, new) -- 1749
	if not (Content:exist(old) and not Content:exist(new)) then -- 1750
		return false -- 1750
	end -- 1750
	local renamedDir = Content:isdir(old) -- 1751
	local parent = Path:getPath(new) -- 1752
	local files = Content:getFiles(parent) -- 1753
	if renamedDir then -- 1754
		local name = Path:getFilename(new):lower() -- 1755
		for _index_0 = 1, #files do -- 1756
			local file = files[_index_0] -- 1756
			if name == Path:getFilename(file):lower() then -- 1757
				return false -- 1758
			end -- 1757
		end -- 1756
	else -- 1760
		local name = Path:getName(new):lower() -- 1760
		local ext = Path:getExt(new) -- 1761
		for _index_0 = 1, #files do -- 1762
			local file = files[_index_0] -- 1762
			if name == Path:getName(file):lower() then -- 1763
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1764
					goto _continue_0 -- 1765
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1766
					goto _continue_0 -- 1767
				end -- 1764
				return false -- 1768
			end -- 1763
			::_continue_0:: -- 1763
		end -- 1762
	end -- 1754
	if not Content:move(old, new) then -- 1769
		return false -- 1769
	end -- 1769
	if renamedDir then -- 1770
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1771
	end -- 1770
	local newParent = Path:getPath(new) -- 1772
	parent = Path:getPath(old) -- 1773
	files = Content:getFiles(parent) -- 1774
	local newName = Path:getName(new) -- 1775
	local oldName = Path:getName(old) -- 1776
	local name = oldName:lower() -- 1777
	local ext = Path:getExt(old) -- 1778
	for _index_0 = 1, #files do -- 1779
		local file = files[_index_0] -- 1779
		if name == Path:getName(file):lower() then -- 1780
			local _exp_0 = Path:getExt(file) -- 1781
			if "tl" == _exp_0 then -- 1781
				if ("vs" == ext) then -- 1781
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1782
				end -- 1781
			elseif "lua" == _exp_0 then -- 1783
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1783
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1784
				end -- 1783
			end -- 1781
		end -- 1780
	end -- 1779
	return true -- 1785
end -- 1749
HttpServer:post("/delete", function(req) -- 1787
	do -- 1788
		local _type_0 = type(req) -- 1788
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1788
		if _tab_0 then -- 1788
			local path -- 1788
			do -- 1788
				local _obj_0 = req.body -- 1788
				local _type_1 = type(_obj_0) -- 1788
				if "table" == _type_1 or "userdata" == _type_1 then -- 1788
					path = _obj_0.path -- 1788
				end -- 1788
			end -- 1788
			if path ~= nil then -- 1788
				if deleteAsset(path) then -- 1789
					return { -- 1789
						success = true -- 1789
					} -- 1789
				end -- 1789
			end -- 1788
		end -- 1788
	end -- 1788
	return { -- 1787
		success = false -- 1787
	} -- 1787
end) -- 1787
HttpServer:post("/rename", function(req) -- 1791
	do -- 1792
		local _type_0 = type(req) -- 1792
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1792
		if _tab_0 then -- 1792
			local old -- 1792
			do -- 1792
				local _obj_0 = req.body -- 1792
				local _type_1 = type(_obj_0) -- 1792
				if "table" == _type_1 or "userdata" == _type_1 then -- 1792
					old = _obj_0.old -- 1792
				end -- 1792
			end -- 1792
			local new -- 1792
			do -- 1792
				local _obj_0 = req.body -- 1792
				local _type_1 = type(_obj_0) -- 1792
				if "table" == _type_1 or "userdata" == _type_1 then -- 1792
					new = _obj_0.new -- 1792
				end -- 1792
			end -- 1792
			if old ~= nil and new ~= nil then -- 1792
				if moveAsset(old, new) then -- 1793
					return { -- 1793
						success = true -- 1793
					} -- 1793
				end -- 1793
			end -- 1792
		end -- 1792
	end -- 1792
	return { -- 1791
		success = false -- 1791
	} -- 1791
end) -- 1791
local normalizeAssetPaths -- 1795
normalizeAssetPaths = function(paths) -- 1795
	if not (type(paths) == "table") then -- 1796
		return nil -- 1796
	end -- 1796
	local unique = { } -- 1797
	local candidates = { } -- 1798
	for _index_0 = 1, #paths do -- 1799
		local path = paths[_index_0] -- 1799
		if not (type(path) == "string") then -- 1800
			return nil -- 1800
		end -- 1800
		local relative = relativeToRoot(path, Content.writablePath) -- 1801
		if relative == nil or relative == "" or not Content:exist(path) then -- 1802
			return nil -- 1802
		end -- 1802
		if not unique[path] then -- 1803
			unique[path] = true -- 1804
			candidates[#candidates + 1] = path -- 1805
		end -- 1803
	end -- 1799
	table.sort(candidates, function(a, b) -- 1806
		return #a < #b -- 1806
	end) -- 1806
	local result = { } -- 1807
	for _index_0 = 1, #candidates do -- 1808
		local path = candidates[_index_0] -- 1808
		local contained = false -- 1809
		for _index_1 = 1, #result do -- 1810
			local parent = result[_index_1] -- 1810
			if relativeToRoot(path, parent) ~= nil then -- 1811
				contained = true -- 1812
				break -- 1813
			end -- 1811
		end -- 1810
		if not contained then -- 1814
			result[#result + 1] = path -- 1814
		end -- 1814
	end -- 1808
	return result -- 1815
end -- 1795
HttpServer:postSchedule("/assets/batch", function(req) -- 1817
	do -- 1818
		local _type_0 = type(req) -- 1818
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1818
		if _tab_0 then -- 1818
			local operation -- 1818
			do -- 1818
				local _obj_0 = req.body -- 1818
				local _type_1 = type(_obj_0) -- 1818
				if "table" == _type_1 or "userdata" == _type_1 then -- 1818
					operation = _obj_0.operation -- 1818
				end -- 1818
			end -- 1818
			local sources -- 1818
			do -- 1818
				local _obj_0 = req.body -- 1818
				local _type_1 = type(_obj_0) -- 1818
				if "table" == _type_1 or "userdata" == _type_1 then -- 1818
					sources = _obj_0.sources -- 1818
				end -- 1818
			end -- 1818
			if operation ~= nil and sources ~= nil then -- 1818
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1819
					return { -- 1819
						success = false, -- 1819
						message = "invalid operation" -- 1819
					} -- 1819
				end -- 1819
				sources = normalizeAssetPaths(sources) -- 1820
				if not (sources and #sources > 0) then -- 1821
					return { -- 1821
						success = false, -- 1821
						message = "invalid sources" -- 1821
					} -- 1821
				end -- 1821
				local target = req.body.target -- 1822
				local destinations = { } -- 1823
				if operation ~= "delete" then -- 1824
					if not (type(target) == "string") then -- 1825
						return { -- 1825
							success = false, -- 1825
							message = "invalid target" -- 1825
						} -- 1825
					end -- 1825
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1826
					if targetRelative == nil then -- 1827
						return { -- 1827
							success = false, -- 1827
							message = "invalid target" -- 1827
						} -- 1827
					end -- 1827
					if not (Content:exist(target) and Content:isdir(target)) then -- 1828
						return { -- 1828
							success = false, -- 1828
							message = "invalid target" -- 1828
						} -- 1828
					end -- 1828
					for _index_0 = 1, #sources do -- 1829
						local source = sources[_index_0] -- 1829
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1830
							return { -- 1831
								success = false, -- 1831
								message = "target inside source" -- 1831
							} -- 1831
						end -- 1830
						local destination = Path(target, Path:getFilename(source)) -- 1832
						if Content:exist(destination) then -- 1833
							return { -- 1833
								success = false, -- 1833
								message = "target existed" -- 1833
							} -- 1833
						end -- 1833
						if destinations[destination] then -- 1834
							return { -- 1834
								success = false, -- 1834
								message = "duplicate target" -- 1834
							} -- 1834
						end -- 1834
						destinations[destination] = true -- 1835
					end -- 1829
				end -- 1824
				local changes = { } -- 1836
				local affectedSet = { } -- 1837
				local affectedDirectories = { } -- 1838
				local addAffected -- 1839
				addAffected = function(dir) -- 1839
					if affectedSet[dir] then -- 1840
						return -- 1840
					end -- 1840
					affectedSet[dir] = true -- 1841
					affectedDirectories[#affectedDirectories + 1] = dir -- 1842
				end -- 1839
				if operation ~= "delete" then -- 1843
					addAffected(target) -- 1843
				end -- 1843
				for _index_0 = 1, #sources do -- 1844
					local source = sources[_index_0] -- 1844
					addAffected(Path:getPath(source)) -- 1845
					if operation == "delete" then -- 1846
						if not deleteAsset(source) then -- 1847
							return { -- 1847
								success = false, -- 1847
								message = "delete failed", -- 1847
								changes = changes, -- 1847
								affectedDirectories = affectedDirectories -- 1847
							} -- 1847
						end -- 1847
						changes[#changes + 1] = { -- 1848
							old = source -- 1848
						} -- 1848
					else -- 1850
						local destination = Path(target, Path:getFilename(source)) -- 1850
						local ok -- 1851
						if operation == "copy" then -- 1851
							ok = Content:copyAsync(source, destination) -- 1852
						else -- 1854
							ok = moveAsset(source, destination) -- 1854
						end -- 1851
						if not ok then -- 1855
							return { -- 1855
								success = false, -- 1855
								message = operation .. " failed", -- 1855
								changes = changes, -- 1855
								affectedDirectories = affectedDirectories -- 1855
							} -- 1855
						end -- 1855
						changes[#changes + 1] = { -- 1856
							old = source, -- 1856
							new = destination -- 1856
						} -- 1856
					end -- 1846
				end -- 1844
				return { -- 1857
					success = true, -- 1857
					changes = changes, -- 1857
					affectedDirectories = affectedDirectories -- 1857
				} -- 1857
			end -- 1818
		end -- 1818
	end -- 1818
	return { -- 1817
		success = false, -- 1817
		message = "invalid request" -- 1817
	} -- 1817
end) -- 1817
local withProjectSearchPaths -- 1859
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1859
	local fallbackPaths = { } -- 1860
	local addFallback -- 1861
	addFallback = function(dir) -- 1861
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1861
			fallbackPaths[#fallbackPaths + 1] = dir -- 1861
		end -- 1861
	end -- 1861
	if projectRoot and projectRoot ~= "" then -- 1862
		addFallback(Path(projectRoot, "Script")) -- 1863
		addFallback(projectRoot) -- 1864
	end -- 1862
	if projFile then -- 1865
		local projDir = getProjectDirFromFile(projFile) -- 1866
		if projDir then -- 1866
			addFallback(Path(projDir, "Script")) -- 1867
			addFallback(projDir) -- 1868
		else -- 1870
			addFallback(Path:getPath(projFile)) -- 1870
		end -- 1866
	end -- 1865
	if not (#fallbackPaths > 0) then -- 1871
		return fn() -- 1871
	end -- 1871
	local searchPaths = Content.searchPaths -- 1872
	for _index_0 = 1, #fallbackPaths do -- 1873
		local dir = fallbackPaths[_index_0] -- 1873
		Content:addSearchPath(dir) -- 1873
	end -- 1873
	local _ <close> = setmetatable({ }, { -- 1874
		__close = function() -- 1874
			Content.searchPaths = searchPaths -- 1874
		end -- 1874
	}) -- 1874
	return fn() -- 1875
end -- 1859
HttpServer:post("/exist", function(req) -- 1876
	do -- 1877
		local _type_0 = type(req) -- 1877
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1877
		if _tab_0 then -- 1877
			local file -- 1877
			do -- 1877
				local _obj_0 = req.body -- 1877
				local _type_1 = type(_obj_0) -- 1877
				if "table" == _type_1 or "userdata" == _type_1 then -- 1877
					file = _obj_0.file -- 1877
				end -- 1877
			end -- 1877
			if file ~= nil then -- 1877
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1878
					return { -- 1879
						success = Content:exist(file) -- 1879
					} -- 1879
				end) -- 1878
			end -- 1877
		end -- 1877
	end -- 1877
	return { -- 1876
		success = false -- 1876
	} -- 1876
end) -- 1876
HttpServer:postSchedule("/read", function(req) -- 1880
	do -- 1881
		local _type_0 = type(req) -- 1881
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1881
		if _tab_0 then -- 1881
			local path -- 1881
			do -- 1881
				local _obj_0 = req.body -- 1881
				local _type_1 = type(_obj_0) -- 1881
				if "table" == _type_1 or "userdata" == _type_1 then -- 1881
					path = _obj_0.path -- 1881
				end -- 1881
			end -- 1881
			if path ~= nil then -- 1881
				local readFile -- 1882
				readFile = function() -- 1882
					if Content:exist(path) and not Content:isdir(path) then -- 1883
						local content = Content:loadAsync(path) -- 1884
						if content then -- 1884
							return { -- 1885
								content = content, -- 1885
								success = true, -- 1885
								fullPath = Content:getFullPath(path) -- 1885
							} -- 1885
						end -- 1884
					end -- 1883
					return nil -- 1882
				end -- 1882
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1886
				if result then -- 1886
					return result -- 1886
				end -- 1886
			end -- 1881
		end -- 1881
	end -- 1881
	return { -- 1880
		success = false -- 1880
	} -- 1880
end) -- 1880
local agentDocLanguage -- 1888
agentDocLanguage = function(language) -- 1888
	if language == "zh-Hans" then -- 1889
		return "zh" -- 1889
	else -- 1889
		return "en" -- 1889
	end -- 1889
end -- 1888
HttpServer:postSchedule("/doc/search", function(req) -- 1891
	local body = req.body or { } -- 1892
	local language = body.docLanguage -- 1893
	if not (("en" == language or "zh-Hans" == language)) then -- 1894
		return { -- 1894
			success = false, -- 1894
			message = "unsupported doc language" -- 1894
		} -- 1894
	end -- 1894
	local docType = body.docType -- 1895
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1896
		return { -- 1896
			success = false, -- 1896
			message = "unsupported doc type" -- 1896
		} -- 1896
	end -- 1896
	local codeLanguage = body.programmingLanguage -- 1897
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1898
		return { -- 1898
			success = false, -- 1898
			message = "unsupported programming language" -- 1898
		} -- 1898
	end -- 1898
	if not body.pattern then -- 1899
		return { -- 1899
			success = false, -- 1899
			message = "missing pattern" -- 1899
		} -- 1899
	end -- 1899
	local result = nil -- 1900
	AgentTools.searchDoraDocHttp({ -- 1902
		pattern = body.pattern, -- 1902
		docLanguage = agentDocLanguage(language), -- 1903
		docType = docType, -- 1904
		programmingLanguage = codeLanguage, -- 1905
		limit = body.limit, -- 1906
		useRegex = body.useRegex, -- 1907
		caseSensitive = body.caseSensitive, -- 1908
		includeContent = body.includeContent, -- 1909
		contentWindow = body.contentWindow -- 1910
	}, function(res) -- 1911
		result = res -- 1912
	end) -- 1901
	wait(function() -- 1913
		return result ~= nil -- 1913
	end) -- 1913
	if result and result.success then -- 1914
		result.docLanguage = language -- 1915
	end -- 1914
	if result then -- 1916
		return result -- 1917
	else -- 1919
		return { -- 1919
			success = false, -- 1919
			message = "doc search failed" -- 1919
		} -- 1919
	end -- 1916
	return { -- 1891
		success = false, -- 1891
		message = "invalid call" -- 1891
	} -- 1891
end) -- 1891
HttpServer:postSchedule("/doc/read", function(req) -- 1921
	local body = req.body or { } -- 1922
	local language = body.docLanguage -- 1923
	if not (("en" == language or "zh-Hans" == language)) then -- 1924
		return { -- 1924
			success = false, -- 1924
			message = "unsupported doc language" -- 1924
		} -- 1924
	end -- 1924
	if not body.file then -- 1925
		return { -- 1925
			success = false, -- 1925
			message = "missing file" -- 1925
		} -- 1925
	end -- 1925
	local result = AgentTools.readDoraDoc({ -- 1927
		docLanguage = agentDocLanguage(language), -- 1927
		file = body.file, -- 1928
		startLine = body.startLine, -- 1929
		endLine = body.endLine -- 1930
	}) -- 1926
	if result and result.success then -- 1931
		result.docLanguage = language -- 1932
	end -- 1931
	return result -- 1933
end) -- 1921
HttpServer:get("/read-sync", function(req) -- 1935
	do -- 1936
		local _type_0 = type(req) -- 1936
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1936
		if _tab_0 then -- 1936
			local params = req.params -- 1936
			if params ~= nil then -- 1936
				local path = params.path -- 1937
				if not (type(path) == "string" and path ~= "") then -- 1938
					return { -- 1938
						success = false, -- 1938
						message = "invalid path" -- 1938
					} -- 1938
				end -- 1938
				local exts -- 1939
				if params.exts then -- 1939
					local _accum_0 = { } -- 1940
					local _len_0 = 1 -- 1940
					for ext in params.exts:gmatch("[^|]*") do -- 1940
						_accum_0[_len_0] = ext -- 1940
						_len_0 = _len_0 + 1 -- 1940
					end -- 1940
					exts = _accum_0 -- 1940
				else -- 1941
					exts = { -- 1941
						"" -- 1941
					} -- 1941
				end -- 1939
				local readFileAt -- 1942
				readFileAt = function(targetPath) -- 1942
					if Content:exist(targetPath) then -- 1943
						local content = Content:load(targetPath) -- 1944
						if content then -- 1944
							return { -- 1945
								content = content, -- 1945
								success = true, -- 1945
								fullPath = Content:getFullPath(targetPath) -- 1945
							} -- 1945
						end -- 1944
					end -- 1943
					return nil -- 1942
				end -- 1942
				local readFile -- 1946
				readFile = function(fallbackPaths) -- 1946
					for _index_0 = 1, #exts do -- 1947
						local ext = exts[_index_0] -- 1947
						local targetPath = path .. ext -- 1948
						if not Content:isAbsolutePath(targetPath) then -- 1949
							for _index_1 = 1, #fallbackPaths do -- 1950
								local fallback = fallbackPaths[_index_1] -- 1950
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1951
								if fallbackResult then -- 1951
									return fallbackResult -- 1952
								end -- 1951
							end -- 1950
						end -- 1949
						local fileResult = readFileAt(targetPath) -- 1953
						if fileResult then -- 1953
							return fileResult -- 1954
						end -- 1953
					end -- 1947
					return nil -- 1946
				end -- 1946
				local fallbackPaths = { } -- 1955
				local fallbackCandidates = { } -- 1956
				do -- 1957
					local projectRoot = req.params.projectRoot -- 1957
					if projectRoot then -- 1957
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1958
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1959
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1960
						end -- 1958
					end -- 1957
				end -- 1957
				do -- 1961
					local projFile = req.params.projFile -- 1961
					if projFile then -- 1961
						local projDir = getProjectDirFromFile(projFile) -- 1962
						if projDir then -- 1962
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1963
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1964
						else -- 1966
							projDir = Path:getPath(projFile) -- 1966
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1967
						end -- 1962
					end -- 1961
				end -- 1961
				for _index_0 = 1, #fallbackCandidates do -- 1968
					local dir = fallbackCandidates[_index_0] -- 1968
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1969
						local exists = false -- 1970
						for _index_1 = 1, #fallbackPaths do -- 1971
							local fallback = fallbackPaths[_index_1] -- 1971
							if fallback == dir then -- 1972
								exists = true -- 1973
								break -- 1974
							end -- 1972
						end -- 1971
						if not exists then -- 1975
							fallbackPaths[#fallbackPaths + 1] = dir -- 1975
						end -- 1975
					end -- 1969
				end -- 1968
				local readResult = readFile(fallbackPaths) -- 1976
				if readResult then -- 1976
					return readResult -- 1977
				end -- 1976
			end -- 1936
		end -- 1936
	end -- 1936
	return { -- 1935
		success = false -- 1935
	} -- 1935
end) -- 1935
local addGeneratedSourceHeader -- 1979
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 1979
	if preserveTIC80 == nil then -- 1979
		preserveTIC80 = false -- 1979
	end -- 1979
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 1980
	if preserveTIC80 then -- 1981
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 1982
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 1983
		end -- 1982
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 1984
	end -- 1981
	return tostring(header) .. "\n" .. tostring(codes) -- 1985
end -- 1979
local compileFileAsync -- 1987
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1987
	if projectRoot == nil then -- 1987
		projectRoot = nil -- 1987
	end -- 1987
	local file = inputFile -- 1988
	local searchPath -- 1989
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1989
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1990
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1994
	elseif not Content:isAbsolutePath(inputFile) then -- 1995
		searchPath = "" -- 1996
	else -- 1997
		local dir = getProjectDirFromFile(inputFile) -- 1997
		if dir then -- 1997
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1998
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 2002
		else -- 2004
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2004
			searchPath = "" -- 2007
		end -- 1997
	end -- 1989
	local outputFile = Path:replaceExt(inputFile, "lua") -- 2008
	local yueext = yue.options.extension -- 2009
	local resultCodes = nil -- 2010
	local resultError = nil -- 2011
	do -- 2012
		local _exp_0 = Path:getExt(inputFile) -- 2012
		if yueext == _exp_0 then -- 2012
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 2013
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 2014
				if not codes then -- 2015
					resultError = err -- 2016
					return -- 2017
				end -- 2015
				local extraGlobal -- 2018
				if isTIC80 then -- 2018
					extraGlobal = tic80APIs -- 2018
				else -- 2018
					extraGlobal = nil -- 2018
				end -- 2018
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 2019
				if not success then -- 2020
					resultError = message -- 2021
					return -- 2022
				end -- 2020
				if codes == "" then -- 2023
					resultCodes = "" -- 2024
					return nil -- 2025
				end -- 2023
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 2026
				return resultCodes -- 2027
			end, function(success) -- 2014
				if not success then -- 2028
					Content:remove(outputFile) -- 2029
					if resultCodes == nil then -- 2030
						resultCodes = false -- 2031
					end -- 2030
				end -- 2028
			end) -- 2014
		elseif "tl" == _exp_0 then -- 2032
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 2033
			if isTIC80 then -- 2034
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2035
			end -- 2034
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2036
			if codes then -- 2036
				if isTIC80 then -- 2037
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2038
				end -- 2037
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2039
				Content:saveAsync(outputFile, resultCodes) -- 2040
			else -- 2042
				Content:remove(outputFile) -- 2042
				resultCodes = false -- 2043
				resultError = err -- 2044
			end -- 2036
		elseif "xml" == _exp_0 then -- 2045
			local codes, err = xml.tolua(sourceCodes) -- 2046
			if codes then -- 2046
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2047
				Content:saveAsync(outputFile, resultCodes) -- 2048
			else -- 2050
				Content:remove(outputFile) -- 2050
				resultCodes = false -- 2051
				resultError = err -- 2052
			end -- 2046
		end -- 2012
	end -- 2012
	wait(function() -- 2053
		return resultCodes ~= nil -- 2053
	end) -- 2053
	if resultCodes then -- 2054
		return resultCodes -- 2055
	else -- 2057
		return nil, resultError -- 2057
	end -- 2054
	return nil -- 1987
end -- 1987
HttpServer:postSchedule("/write", function(req) -- 2059
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2060
	local buildSucceeded = false -- 2061
	local _ <close> = setmetatable({ }, { -- 2062
		__close = function() -- 2062
			return finishUpdate(buildSucceeded) -- 2062
		end -- 2062
	}) -- 2062
	do -- 2063
		local _type_0 = type(req) -- 2063
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2063
		if _tab_0 then -- 2063
			local path -- 2063
			do -- 2063
				local _obj_0 = req.body -- 2063
				local _type_1 = type(_obj_0) -- 2063
				if "table" == _type_1 or "userdata" == _type_1 then -- 2063
					path = _obj_0.path -- 2063
				end -- 2063
			end -- 2063
			local content -- 2063
			do -- 2063
				local _obj_0 = req.body -- 2063
				local _type_1 = type(_obj_0) -- 2063
				if "table" == _type_1 or "userdata" == _type_1 then -- 2063
					content = _obj_0.content -- 2063
				end -- 2063
			end -- 2063
			if path ~= nil and content ~= nil then -- 2063
				if Content:saveAsync(path, content) then -- 2064
					do -- 2065
						local _exp_0 = Path:getExt(path) -- 2065
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2065
							if '' == Path:getExt(Path:getName(path)) then -- 2066
								local resultCodes = compileFileAsync(path, content) -- 2067
								buildSucceeded = resultCodes ~= nil -- 2068
								return { -- 2069
									success = true, -- 2069
									resultCodes = resultCodes -- 2069
								} -- 2069
							end -- 2066
						end -- 2065
					end -- 2065
					buildSucceeded = true -- 2070
					return { -- 2071
						success = true -- 2071
					} -- 2071
				end -- 2064
			end -- 2063
		end -- 2063
	end -- 2063
	return { -- 2059
		success = false -- 2059
	} -- 2059
end) -- 2059
local getWaProjectDirFromFile = nil -- 2073
HttpServer:postSchedule("/build", function(req) -- 2075
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2076
	local buildSucceeded = false -- 2077
	local _ <close> = setmetatable({ }, { -- 2078
		__close = function() -- 2078
			return finishUpdate(buildSucceeded) -- 2078
		end -- 2078
	}) -- 2078
	do -- 2079
		local _type_0 = type(req) -- 2079
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2079
		if _tab_0 then -- 2079
			local path -- 2079
			do -- 2079
				local _obj_0 = req.body -- 2079
				local _type_1 = type(_obj_0) -- 2079
				if "table" == _type_1 or "userdata" == _type_1 then -- 2079
					path = _obj_0.path -- 2079
				end -- 2079
			end -- 2079
			if path ~= nil then -- 2079
				local projectRoot = req.body.projectRoot -- 2080
				if Content:isdir(path) then -- 2081
					local projDir = getWaProjectDirFromFile(path) -- 2082
					if projDir then -- 2082
						local message = Wasm:buildWaAsync(projDir) -- 2083
						if message == "" then -- 2084
							return { -- 2085
								success = true -- 2085
							} -- 2085
						else -- 2087
							return { -- 2087
								success = false, -- 2087
								message = message -- 2087
							} -- 2087
						end -- 2084
					end -- 2082
				end -- 2081
				local _exp_0 = Path:getExt(path) -- 2088
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2089
					if '' == Path:getExt(Path:getName(path)) then -- 2090
						local content = Content:loadAsync(path) -- 2091
						if content then -- 2091
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2092
							if resultCodes then -- 2092
								buildSucceeded = true -- 2093
								return { -- 2094
									success = true, -- 2094
									resultCodes = resultCodes -- 2094
								} -- 2094
							end -- 2092
						end -- 2091
					end -- 2090
				elseif "wa" == _exp_0 then -- 2095
					local projDir = getWaProjectDirFromFile(path) -- 2096
					if projDir then -- 2096
						local message = Wasm:buildWaAsync(projDir) -- 2097
						if message == "" then -- 2098
							return { -- 2099
								success = true -- 2099
							} -- 2099
						else -- 2101
							return { -- 2101
								success = false, -- 2101
								message = message -- 2101
							} -- 2101
						end -- 2098
					else -- 2103
						return { -- 2103
							success = false, -- 2103
							message = 'Wa file needs a project' -- 2103
						} -- 2103
					end -- 2096
				end -- 2088
			end -- 2079
		end -- 2079
	end -- 2079
	return { -- 2075
		success = false -- 2075
	} -- 2075
end) -- 2075
local extentionLevels = { -- 2106
	vs = 2, -- 2106
	bl = 2, -- 2107
	ts = 1, -- 2108
	tsx = 1, -- 2109
	tl = 1, -- 2110
	yue = 1, -- 2111
	xml = 1, -- 2112
	lua = 0 -- 2113
} -- 2105
local visitAssets -- 2115
visitAssets = function(path, workspace, builtin, recursive) -- 2115
	if recursive == nil then -- 2115
		recursive = true -- 2115
	end -- 2115
	local children = nil -- 2116
	local dirs = Content:getDirs(path) -- 2117
	for _index_0 = 1, #dirs do -- 2118
		local dir = dirs[_index_0] -- 2118
		if workspace then -- 2119
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 2120
				goto _continue_0 -- 2121
			end -- 2120
		elseif dir == ".git" then -- 2122
			goto _continue_0 -- 2123
		end -- 2119
		if not children then -- 2124
			children = { } -- 2124
		end -- 2124
		local dirPath = Path(path, dir) -- 2125
		if recursive then -- 2126
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2127
		else -- 2129
			children[#children + 1] = { -- 2130
				key = dirPath, -- 2130
				dir = true, -- 2131
				title = dir, -- 2132
				builtin = builtin, -- 2133
				isLeaf = false -- 2134
			} -- 2129
		end -- 2126
		::_continue_0:: -- 2119
	end -- 2118
	local files = Content:getFiles(path) -- 2136
	local names = { } -- 2137
	for _index_0 = 1, #files do -- 2138
		local file = files[_index_0] -- 2138
		if (".DS_Store" == file) then -- 2139
			goto _continue_1 -- 2140
		end -- 2139
		local name = Path:getName(file) -- 2141
		local ext = names[name] -- 2142
		if ext then -- 2142
			local lv1 -- 2143
			do -- 2143
				local _exp_0 = extentionLevels[ext] -- 2143
				if _exp_0 ~= nil then -- 2143
					lv1 = _exp_0 -- 2143
				else -- 2143
					lv1 = -1 -- 2143
				end -- 2143
			end -- 2143
			ext = Path:getExt(file) -- 2144
			local lv2 -- 2145
			do -- 2145
				local _exp_0 = extentionLevels[ext] -- 2145
				if _exp_0 ~= nil then -- 2145
					lv2 = _exp_0 -- 2145
				else -- 2145
					lv2 = -1 -- 2145
				end -- 2145
			end -- 2145
			if lv2 > lv1 then -- 2146
				names[name] = ext -- 2147
			elseif lv2 == lv1 then -- 2148
				names[name .. '.' .. ext] = "" -- 2149
			end -- 2146
		else -- 2151
			ext = Path:getExt(file) -- 2151
			if not extentionLevels[ext] then -- 2152
				names[file] = "" -- 2153
			else -- 2155
				names[name] = ext -- 2155
			end -- 2152
		end -- 2142
		::_continue_1:: -- 2139
	end -- 2138
	do -- 2156
		local _accum_0 = { } -- 2156
		local _len_0 = 1 -- 2156
		for name, ext in pairs(names) do -- 2156
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2156
			_len_0 = _len_0 + 1 -- 2156
		end -- 2156
		files = _accum_0 -- 2156
	end -- 2156
	for _index_0 = 1, #files do -- 2157
		local file = files[_index_0] -- 2157
		if not children then -- 2158
			children = { } -- 2158
		end -- 2158
		children[#children + 1] = { -- 2160
			key = Path(path, file), -- 2160
			dir = false, -- 2161
			title = file, -- 2162
			builtin = builtin -- 2163
		} -- 2159
	end -- 2157
	if children then -- 2165
		table.sort(children, function(a, b) -- 2166
			if a.dir == b.dir then -- 2167
				return a.title < b.title -- 2168
			else -- 2170
				return a.dir -- 2170
			end -- 2167
		end) -- 2166
	end -- 2165
	return { -- 2172
		key = path, -- 2172
		dir = true, -- 2173
		title = Path:getFilename(path), -- 2174
		builtin = builtin, -- 2175
		isLeaf = not children, -- 2176
		children = children -- 2177
	} -- 2171
end -- 2115
HttpServer:post("/assets/children", function(req) -- 2180
	do -- 2181
		local _type_0 = type(req) -- 2181
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2181
		if _tab_0 then -- 2181
			local path -- 2181
			do -- 2181
				local _obj_0 = req.body -- 2181
				local _type_1 = type(_obj_0) -- 2181
				if "table" == _type_1 or "userdata" == _type_1 then -- 2181
					path = _obj_0.path -- 2181
				end -- 2181
			end -- 2181
			if path ~= nil then -- 2181
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2182
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2183
					return { -- 2183
						success = false -- 2183
					} -- 2183
				end -- 2183
				local node = visitAssets(path, workspace, builtin, false) -- 2184
				return { -- 2185
					success = true, -- 2185
					children = node.children or { } -- 2185
				} -- 2185
			end -- 2181
		end -- 2181
	end -- 2181
	return { -- 2180
		success = false -- 2180
	} -- 2180
end) -- 2180
HttpServer:post("/assets/files", function(req) -- 2187
	do -- 2188
		local _type_0 = type(req) -- 2188
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2188
		if _tab_0 then -- 2188
			local path -- 2188
			do -- 2188
				local _obj_0 = req.body -- 2188
				local _type_1 = type(_obj_0) -- 2188
				if "table" == _type_1 or "userdata" == _type_1 then -- 2188
					path = _obj_0.path -- 2188
				end -- 2188
			end -- 2188
			if path ~= nil then -- 2188
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2189
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2190
				if not (workspace or builtin) then -- 2191
					return { -- 2191
						success = false -- 2191
					} -- 2191
				end -- 2191
				if not (Content:exist(path) and Content:isdir(path)) then -- 2192
					return { -- 2192
						success = false -- 2192
					} -- 2192
				end -- 2192
				local globs = { -- 2193
					"**", -- 2193
					"!**/.DS_Store" -- 2193
				} -- 2193
				if workspace then -- 2194
					globs = { -- 2196
						"**", -- 2196
						"!**/.DS_Store", -- 2196
						"!**/.upload/**", -- 2197
						"!**/.download/**", -- 2197
						"!**/.www/**", -- 2198
						"!**/.build/**", -- 2198
						"!**/.git/**", -- 2199
						"!**/.cache/**", -- 2199
						"!**/node_modules/**" -- 2200
					} -- 2195
				end -- 2194
				local files -- 2202
				do -- 2202
					local _accum_0 = { } -- 2202
					local _len_0 = 1 -- 2202
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2202
					for _index_0 = 1, #_list_0 do -- 2202
						local file = _list_0[_index_0] -- 2202
						_accum_0[_len_0] = Path(path, file) -- 2202
						_len_0 = _len_0 + 1 -- 2202
					end -- 2202
					files = _accum_0 -- 2202
				end -- 2202
				return { -- 2203
					success = true, -- 2203
					files = files -- 2203
				} -- 2203
			end -- 2188
		end -- 2188
	end -- 2188
	return { -- 2187
		success = false -- 2187
	} -- 2187
end) -- 2187
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2244
	local _tab_0 = { -- 2244
		{ -- 2245
			key = Path(Content.assetPath), -- 2245
			dir = true, -- 2246
			builtin = true, -- 2247
			title = zh and "内置资源" or "Built-in", -- 2248
			children = builtinChildren -- 2249
		} -- 2244
	} -- 2251
	local _obj_0 = workspace.children or { } -- 2251
	local _idx_0 = #_tab_0 + 1 -- 2251
	for _index_0 = 1, #_obj_0 do -- 2251
		local _value_0 = _obj_0[_index_0] -- 2251
		_tab_0[_idx_0] = _value_0 -- 2251
		_idx_0 = _idx_0 + 1 -- 2251
	end -- 2251
	return _tab_0 -- 2244
end -- 2244
HttpServer:post("/assets", function() -- 2205
	local Entry = require("Script.Dev.Entry") -- 2206
	local engineDev = Entry.getEngineDev() -- 2207
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2208
	local zh = (App.locale:match("^zh") ~= nil) -- 2209
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2210
	readme.title = zh and "说明文档" or "Readme" -- 2211
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2212
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2213
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2214
	tools.title = zh and "开发工具" or "Tools" -- 2215
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2216
	font.title = zh and "字体" or "Font" -- 2217
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2218
	lib.title = zh and "程序库" or "Lib" -- 2219
	if engineDev then -- 2220
		local _list_0 = lib.children -- 2221
		for _index_0 = 1, #_list_0 do -- 2221
			local child = _list_0[_index_0] -- 2221
			if not (child.title == "Dora") then -- 2222
				goto _continue_0 -- 2222
			end -- 2222
			local title = zh and "zh-Hans" or "en" -- 2223
			do -- 2224
				local _accum_0 = { } -- 2224
				local _len_0 = 1 -- 2224
				local _list_1 = child.children -- 2224
				for _index_1 = 1, #_list_1 do -- 2224
					local c = _list_1[_index_1] -- 2224
					if c.title ~= title then -- 2224
						_accum_0[_len_0] = c -- 2224
						_len_0 = _len_0 + 1 -- 2224
					end -- 2224
				end -- 2224
				child.children = _accum_0 -- 2224
			end -- 2224
			break -- 2225
			::_continue_0:: -- 2222
		end -- 2221
	else -- 2227
		local _accum_0 = { } -- 2227
		local _len_0 = 1 -- 2227
		local _list_0 = lib.children -- 2227
		for _index_0 = 1, #_list_0 do -- 2227
			local child = _list_0[_index_0] -- 2227
			if child.title ~= "Dora" then -- 2227
				_accum_0[_len_0] = child -- 2227
				_len_0 = _len_0 + 1 -- 2227
			end -- 2227
		end -- 2227
		lib.children = _accum_0 -- 2227
	end -- 2220
	local builtinChildren = { -- 2228
		readme, -- 2228
		apiDoc, -- 2228
		tools, -- 2228
		font, -- 2228
		lib -- 2228
	} -- 2228
	if engineDev then -- 2229
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2230
		do -- 2231
			local _obj_0 = dev.children -- 2231
			_obj_0[#_obj_0 + 1] = { -- 2232
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2232
				dir = false, -- 2233
				builtin = true, -- 2234
				title = "init.yue" -- 2235
			} -- 2231
		end -- 2231
		builtinChildren[#builtinChildren + 1] = dev -- 2237
	end -- 2229
	return { -- 2239
		key = Content.writablePath, -- 2239
		dir = true, -- 2240
		root = true, -- 2241
		title = "Assets", -- 2242
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2243
	} -- 2238
end) -- 2205
HttpServer:post("/entry/list", function(req) -- 2255
	local Entry = require("Script.Dev.Entry") -- 2256
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2257
	res.success = true -- 2258
	return res -- 2259
end) -- 2255
HttpServer:post("/run/status", function() -- 2261
	local Entry = require("Script.Dev.Entry") -- 2262
	return Entry.getCurrentEntryStatus() -- 2263
end) -- 2261
HttpServer:postSchedule("/run", function(req) -- 2265
	do -- 2266
		local _type_0 = type(req) -- 2266
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2266
		if _tab_0 then -- 2266
			local file -- 2266
			do -- 2266
				local _obj_0 = req.body -- 2266
				local _type_1 = type(_obj_0) -- 2266
				if "table" == _type_1 or "userdata" == _type_1 then -- 2266
					file = _obj_0.file -- 2266
				end -- 2266
			end -- 2266
			local asProj -- 2266
			do -- 2266
				local _obj_0 = req.body -- 2266
				local _type_1 = type(_obj_0) -- 2266
				if "table" == _type_1 or "userdata" == _type_1 then -- 2266
					asProj = _obj_0.asProj -- 2266
				end -- 2266
			end -- 2266
			if file ~= nil and asProj ~= nil then -- 2266
				if not Content:isAbsolutePath(file) then -- 2267
					local devFile = Path(Content.writablePath, file) -- 2268
					if Content:exist(devFile) then -- 2269
						file = devFile -- 2269
					end -- 2269
				end -- 2267
				local Entry = require("Script.Dev.Entry") -- 2270
				local workDir -- 2271
				if asProj then -- 2272
					local projectRoot = req.body.projectRoot -- 2273
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2274
						workDir = projectRoot -- 2275
					else -- 2277
						workDir = getProjectDirFromFile(file) -- 2277
					end -- 2274
					if workDir then -- 2278
						Entry.allClear() -- 2279
						local target = Path(workDir, "init") -- 2280
						local success, err = Entry.enterEntryAsync({ -- 2281
							entryName = "Project", -- 2281
							fileName = target, -- 2281
							workDir = workDir, -- 2281
							projectRoot = workDir, -- 2281
							runKind = "project" -- 2281
						}) -- 2281
						target = Path:getName(Path:getPath(target)) -- 2282
						return { -- 2283
							success = success, -- 2283
							target = target, -- 2283
							err = err -- 2283
						} -- 2283
					end -- 2278
				else -- 2285
					workDir = getProjectDirFromFile(file) -- 2285
					if not workDir and Path:getExt(file) == "wasm" then -- 2286
						local parent = Path:getPath(file) -- 2287
						if Content:exist(Path(parent, "wa.mod")) then -- 2288
							workDir = parent -- 2289
						end -- 2288
					end -- 2286
				end -- 2272
				Entry.allClear() -- 2290
				file = Path:replaceExt(file, "") -- 2291
				local entry = { -- 2293
					entryName = Path:getName(file), -- 2293
					fileName = file, -- 2294
					runKind = "file" -- 2295
				} -- 2292
				if workDir then -- 2296
					entry.workDir = workDir -- 2297
					entry.projectRoot = workDir -- 2298
				end -- 2296
				local success, err = Entry.enterEntryAsync(entry) -- 2299
				return { -- 2300
					success = success, -- 2300
					err = err -- 2300
				} -- 2300
			end -- 2266
		end -- 2266
	end -- 2266
	return { -- 2265
		success = false -- 2265
	} -- 2265
end) -- 2265
local _anon_func_7 = function(result) -- 2342
	if result.success then -- 2342
		return nil -- 2342
	else -- 2342
		return "PREVIEW_FAILED" -- 2342
	end -- 2342
end -- 2342
HttpServer:postSchedule("/agent/preview", function(req) -- 2302
	local releaseAgent = AgentHost.acquire() -- 2303
	local _ <close> = setmetatable({ }, { -- 2304
		__close = function() -- 2304
			return releaseAgent() -- 2304
		end -- 2304
	}) -- 2304
	do -- 2305
		local _type_0 = type(req) -- 2305
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2305
		if _tab_0 then -- 2305
			local projectRoot -- 2305
			do -- 2305
				local _obj_0 = req.body -- 2305
				local _type_1 = type(_obj_0) -- 2305
				if "table" == _type_1 or "userdata" == _type_1 then -- 2305
					projectRoot = _obj_0.projectRoot -- 2305
				end -- 2305
			end -- 2305
			if projectRoot ~= nil then -- 2305
				if not getProjectSourceRoot(projectRoot) then -- 2306
					return { -- 2306
						success = false, -- 2306
						code = "INVALID_PROJECT", -- 2306
						message = "projectRoot must be an existing absolute directory" -- 2306
					} -- 2306
				end -- 2306
				local entryFile = req.body.entry or "init.lua" -- 2307
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2308
					return { -- 2308
						success = false, -- 2308
						code = "INVALID_ENTRY", -- 2308
						message = "entry must be a non-empty project-relative path" -- 2308
					} -- 2308
				end -- 2308
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2309
					0.5 -- 2309
				} -- 2309
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2310
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2311
					return { -- 2311
						success = false, -- 2311
						code = "INVALID_QUEUE_TIMEOUT", -- 2311
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2311
					} -- 2311
				end -- 2311
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2312
				local AgentOperation = require("Agent.Tool.Operation") -- 2313
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2314
				local requestId = AgentOperation.createOperationId() -- 2315
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2316
				if not enqueued.success then -- 2317
					return { -- 2317
						success = false, -- 2317
						code = "ENTRY_QUEUE_REJECTED", -- 2317
						message = enqueued.message -- 2317
					} -- 2317
				end -- 2317
				local queuedAt = App.runningTime -- 2318
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2319
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2320
						local state = agentEntryRunQueue:get(requestId) -- 2321
						agentEntryRunQueue:cancel(requestId) -- 2322
						return { -- 2324
							success = false, -- 2324
							code = "ENTRY_QUEUE_TIMEOUT", -- 2325
							message = "timed out waiting for the Dora entry runtime", -- 2326
							requestId = requestId, -- 2327
							queuePosition = state.position -- 2328
						} -- 2323
					end -- 2320
					sleep() -- 2329
				end -- 2319
				local queueWaitSeconds = App.runningTime - queuedAt -- 2330
				local _ <close> = setmetatable({ }, { -- 2331
					__close = function() -- 2331
						return agentEntryRunQueue:release(requestId) -- 2331
					end -- 2331
				}) -- 2331
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2332
				local Entry = require("Script.Dev.Entry") -- 2333
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2335
					workDir = projectRoot, -- 2335
					operationId = requestId, -- 2336
					print = function() end -- 2337
				}, Entry) -- 2334
				local result = preview({ -- 2339
					entry = entryFile, -- 2339
					captureAtSeconds = captureAtSeconds -- 2339
				}) -- 2339
				return { -- 2341
					success = result.success, -- 2341
					code = _anon_func_7(result), -- 2342
					message = result.message, -- 2343
					requestId = requestId, -- 2344
					queueWaitSeconds = queueWaitSeconds, -- 2345
					interruptedUserRun = result.interruptedUserRun, -- 2346
					files = result.files, -- 2347
					frames = result.frames -- 2348
				} -- 2340
			end -- 2305
		end -- 2305
	end -- 2305
	return { -- 2302
		success = false, -- 2302
		message = "invalid call" -- 2302
	} -- 2302
end) -- 2302
HttpServer:postSchedule("/agent/command", function(req) -- 2350
	local releaseAgent = AgentHost.acquire() -- 2351
	local _ <close> = setmetatable({ }, { -- 2352
		__close = function() -- 2352
			return releaseAgent() -- 2352
		end -- 2352
	}) -- 2352
	do -- 2353
		local _type_0 = type(req) -- 2353
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2353
		if _tab_0 then -- 2353
			local body = req.body -- 2353
			if body ~= nil then -- 2353
				local projectRoot = body.projectRoot -- 2354
				if not getProjectSourceRoot(projectRoot) then -- 2355
					return { -- 2355
						success = false, -- 2355
						code = "INVALID_PROJECT", -- 2355
						message = "projectRoot must be an existing absolute directory" -- 2355
					} -- 2355
				end -- 2355
				local AgentValidation = require("Agent.Tool.Validation") -- 2356
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2357
				if not validated.success then -- 2358
					return { -- 2358
						success = false, -- 2358
						code = "INVALID_COMMAND", -- 2358
						message = validated.message -- 2358
					} -- 2358
				end -- 2358
				local input = validated.value -- 2359
				local AgentCommand = require("Agent.Tool.Command") -- 2360
				local result = nil -- 2361
				local failure = nil -- 2362
				local promise = AgentCommand.executeCommand({ -- 2364
					workDir = projectRoot, -- 2364
					mode = input.mode, -- 2365
					code = input.code, -- 2366
					command = input.command, -- 2367
					cwd = input.cwd, -- 2368
					timeoutSeconds = input.timeoutSeconds -- 2369
				}) -- 2363
				promise:addCallbacks((function(_, value) -- 2370
					result = value -- 2370
				end), (function(_, err) -- 2370
					failure = tostring(err) -- 2370
				end)) -- 2370
				wait(function() -- 2371
					return result ~= nil or failure ~= nil -- 2371
				end) -- 2371
				if failure then -- 2372
					return { -- 2372
						success = false, -- 2372
						code = "COMMAND_BRIDGE_FAILED", -- 2372
						message = failure -- 2372
					} -- 2372
				end -- 2372
				if not result.success then -- 2373
					result.code = "COMMAND_FAILED" -- 2374
				end -- 2373
				return result -- 2375
			end -- 2353
		end -- 2353
	end -- 2353
	return { -- 2350
		success = false, -- 2350
		code = "INVALID_COMMAND", -- 2350
		message = "invalid call" -- 2350
	} -- 2350
end) -- 2350
HttpServer:postSchedule("/stop", function() -- 2377
	local Entry = require("Script.Dev.Entry") -- 2378
	return { -- 2379
		success = Entry.stop() -- 2379
	} -- 2379
end) -- 2377
local minifyAsync -- 2381
minifyAsync = function(sourcePath, minifyPath) -- 2381
	if not Content:exist(sourcePath) then -- 2382
		return -- 2382
	end -- 2382
	local Entry = require("Script.Dev.Entry") -- 2383
	local errors = { } -- 2384
	local files = Entry.getAllFiles(sourcePath, { -- 2385
		"lua" -- 2385
	}, true) -- 2385
	do -- 2386
		local _accum_0 = { } -- 2386
		local _len_0 = 1 -- 2386
		for _index_0 = 1, #files do -- 2386
			local file = files[_index_0] -- 2386
			if file:sub(1, 1) ~= '.' then -- 2386
				_accum_0[_len_0] = file -- 2386
				_len_0 = _len_0 + 1 -- 2386
			end -- 2386
		end -- 2386
		files = _accum_0 -- 2386
	end -- 2386
	local paths -- 2387
	do -- 2387
		local _tbl_0 = { } -- 2387
		for _index_0 = 1, #files do -- 2387
			local file = files[_index_0] -- 2387
			_tbl_0[Path:getPath(file)] = true -- 2387
		end -- 2387
		paths = _tbl_0 -- 2387
	end -- 2387
	for path in pairs(paths) do -- 2388
		Content:mkdir(Path(minifyPath, path)) -- 2388
	end -- 2388
	local _ <close> = setmetatable({ }, { -- 2389
		__close = function() -- 2389
			package.loaded["luaminify.FormatMini"] = nil -- 2390
			package.loaded["luaminify.ParseLua"] = nil -- 2391
			package.loaded["luaminify.Scope"] = nil -- 2392
			package.loaded["luaminify.Util"] = nil -- 2393
		end -- 2389
	}) -- 2389
	local FormatMini -- 2394
	do -- 2394
		local _obj_0 = require("luaminify") -- 2394
		FormatMini = _obj_0.FormatMini -- 2394
	end -- 2394
	local fileCount = #files -- 2395
	local count = 0 -- 2396
	for _index_0 = 1, #files do -- 2397
		local file = files[_index_0] -- 2397
		thread(function() -- 2398
			local _ <close> = setmetatable({ }, { -- 2399
				__close = function() -- 2399
					count = count + 1 -- 2399
				end -- 2399
			}) -- 2399
			local input = Path(sourcePath, file) -- 2400
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2401
			if Content:exist(input) then -- 2402
				local sourceCodes = Content:loadAsync(input) -- 2403
				local res, err = FormatMini(sourceCodes) -- 2404
				if res then -- 2405
					Content:saveAsync(output, res) -- 2406
					return print("Minify " .. tostring(file)) -- 2407
				else -- 2409
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2409
				end -- 2405
			else -- 2411
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2411
			end -- 2402
		end) -- 2398
		sleep() -- 2412
	end -- 2397
	wait(function() -- 2413
		return count == fileCount -- 2413
	end) -- 2413
	if #errors > 0 then -- 2414
		print(table.concat(errors, '\n')) -- 2415
	end -- 2414
	print("Obfuscation done.") -- 2416
	return files -- 2417
end -- 2381
local zipping = false -- 2419
HttpServer:postSchedule("/zip", function(req) -- 2421
	do -- 2422
		local _type_0 = type(req) -- 2422
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2422
		if _tab_0 then -- 2422
			local path -- 2422
			do -- 2422
				local _obj_0 = req.body -- 2422
				local _type_1 = type(_obj_0) -- 2422
				if "table" == _type_1 or "userdata" == _type_1 then -- 2422
					path = _obj_0.path -- 2422
				end -- 2422
			end -- 2422
			local zipFile -- 2422
			do -- 2422
				local _obj_0 = req.body -- 2422
				local _type_1 = type(_obj_0) -- 2422
				if "table" == _type_1 or "userdata" == _type_1 then -- 2422
					zipFile = _obj_0.zipFile -- 2422
				end -- 2422
			end -- 2422
			local obfuscated -- 2422
			do -- 2422
				local _obj_0 = req.body -- 2422
				local _type_1 = type(_obj_0) -- 2422
				if "table" == _type_1 or "userdata" == _type_1 then -- 2422
					obfuscated = _obj_0.obfuscated -- 2422
				end -- 2422
			end -- 2422
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2422
				if zipping then -- 2423
					goto failed -- 2423
				end -- 2423
				zipping = true -- 2424
				local _ <close> = setmetatable({ }, { -- 2425
					__close = function() -- 2425
						zipping = false -- 2425
					end -- 2425
				}) -- 2425
				if not Content:exist(path) then -- 2426
					goto failed -- 2426
				end -- 2426
				Content:mkdir(Path:getPath(zipFile)) -- 2427
				if obfuscated then -- 2428
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2429
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2430
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2431
					Content:remove(scriptPath) -- 2432
					Content:remove(obfuscatedPath) -- 2433
					Content:remove(tempPath) -- 2434
					Content:mkdir(scriptPath) -- 2435
					Content:mkdir(obfuscatedPath) -- 2436
					Content:mkdir(tempPath) -- 2437
					if not Content:copyAsync(path, tempPath) then -- 2438
						goto failed -- 2438
					end -- 2438
					local Entry = require("Script.Dev.Entry") -- 2439
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2440
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2441
						"tl", -- 2441
						"yue", -- 2441
						"lua", -- 2441
						"ts", -- 2441
						"tsx", -- 2441
						"vs", -- 2441
						"bl", -- 2441
						"xml", -- 2441
						"wa", -- 2441
						"mod" -- 2441
					}, true) -- 2441
					for _index_0 = 1, #scriptFiles do -- 2442
						local file = scriptFiles[_index_0] -- 2442
						Content:remove(Path(tempPath, file)) -- 2443
					end -- 2442
					for _index_0 = 1, #luaFiles do -- 2444
						local file = luaFiles[_index_0] -- 2444
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2445
					end -- 2444
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2446
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2447
					end) then -- 2446
						goto failed -- 2446
					end -- 2446
					return { -- 2448
						success = true -- 2448
					} -- 2448
				else -- 2450
					return { -- 2450
						success = Content:zipAsync(path, zipFile, function(file) -- 2450
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2451
						end) -- 2450
					} -- 2450
				end -- 2428
			end -- 2422
		end -- 2422
	end -- 2422
	::failed:: -- 2452
	return { -- 2421
		success = false -- 2421
	} -- 2421
end) -- 2421
HttpServer:postSchedule("/unzip", function(req) -- 2454
	do -- 2455
		local _type_0 = type(req) -- 2455
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2455
		if _tab_0 then -- 2455
			local zipFile -- 2455
			do -- 2455
				local _obj_0 = req.body -- 2455
				local _type_1 = type(_obj_0) -- 2455
				if "table" == _type_1 or "userdata" == _type_1 then -- 2455
					zipFile = _obj_0.zipFile -- 2455
				end -- 2455
			end -- 2455
			local path -- 2455
			do -- 2455
				local _obj_0 = req.body -- 2455
				local _type_1 = type(_obj_0) -- 2455
				if "table" == _type_1 or "userdata" == _type_1 then -- 2455
					path = _obj_0.path -- 2455
				end -- 2455
			end -- 2455
			if zipFile ~= nil and path ~= nil then -- 2455
				return { -- 2456
					success = Content:unzipAsync(zipFile, path, function(file) -- 2456
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2457
					end) -- 2456
				} -- 2456
			end -- 2455
		end -- 2455
	end -- 2455
	return { -- 2454
		success = false -- 2454
	} -- 2454
end) -- 2454
HttpServer:post("/editing-info", function(req) -- 2459
	local Entry = require("Script.Dev.Entry") -- 2460
	local config = Entry.getConfig() -- 2461
	local _type_0 = type(req) -- 2462
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2462
	local _match_0 = false -- 2462
	if _tab_0 then -- 2462
		local editingInfo -- 2462
		do -- 2462
			local _obj_0 = req.body -- 2462
			local _type_1 = type(_obj_0) -- 2462
			if "table" == _type_1 or "userdata" == _type_1 then -- 2462
				editingInfo = _obj_0.editingInfo -- 2462
			end -- 2462
		end -- 2462
		if editingInfo ~= nil then -- 2462
			_match_0 = true -- 2462
			config.editingInfo = editingInfo -- 2463
			return { -- 2464
				success = true -- 2464
			} -- 2464
		end -- 2462
	end -- 2462
	if not _match_0 then -- 2462
		if not (config.editingInfo ~= nil) then -- 2466
			local folder -- 2467
			if App.locale:match('^zh') then -- 2467
				folder = 'zh-Hans' -- 2467
			else -- 2467
				folder = 'en' -- 2467
			end -- 2467
			config.editingInfo = json.encode({ -- 2469
				index = 0, -- 2469
				files = { -- 2471
					{ -- 2472
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2472
						title = "welcome.md" -- 2473
					} -- 2471
				} -- 2470
			}) -- 2468
		end -- 2466
		return { -- 2477
			success = true, -- 2477
			editingInfo = config.editingInfo -- 2477
		} -- 2477
	end -- 2462
end) -- 2459
HttpServer:post("/command", function(req) -- 2479
	do -- 2480
		local _type_0 = type(req) -- 2480
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2480
		if _tab_0 then -- 2480
			local code -- 2480
			do -- 2480
				local _obj_0 = req.body -- 2480
				local _type_1 = type(_obj_0) -- 2480
				if "table" == _type_1 or "userdata" == _type_1 then -- 2480
					code = _obj_0.code -- 2480
				end -- 2480
			end -- 2480
			local log -- 2480
			do -- 2480
				local _obj_0 = req.body -- 2480
				local _type_1 = type(_obj_0) -- 2480
				if "table" == _type_1 or "userdata" == _type_1 then -- 2480
					log = _obj_0.log -- 2480
				end -- 2480
			end -- 2480
			if code ~= nil and log ~= nil then -- 2480
				emit("AppCommand", code, log) -- 2481
				return { -- 2482
					success = true -- 2482
				} -- 2482
			end -- 2480
		end -- 2480
	end -- 2480
	return { -- 2479
		success = false -- 2479
	} -- 2479
end) -- 2479
HttpServer:post("/log/save", function() -- 2484
	local folder = ".download" -- 2485
	local fullLogFile = "dora_full_logs.txt" -- 2486
	local fullFolder = Path(Content.writablePath, folder) -- 2487
	Content:mkdir(fullFolder) -- 2488
	local logPath = Path(fullFolder, fullLogFile) -- 2489
	if App:saveLog(logPath) then -- 2490
		return { -- 2491
			success = true, -- 2491
			path = Path(folder, fullLogFile) -- 2491
		} -- 2491
	end -- 2490
	return { -- 2484
		success = false -- 2484
	} -- 2484
end) -- 2484
local tailLines -- 2493
tailLines = function(text, count) -- 2493
	local lines = { } -- 2494
	text = text:gsub("\r\n", "\n") -- 2495
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2496
		lines[#lines + 1] = line -- 2497
	end -- 2496
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2498
		table.remove(lines) -- 2499
	end -- 2498
	local start = math.max(1, #lines - count + 1) -- 2500
	local out = { } -- 2501
	for i = start, #lines do -- 2502
		out[#out + 1] = lines[i] -- 2503
	end -- 2502
	return table.concat(out, "\n") -- 2504
end -- 2493
HttpServer:post("/log", function(req) -- 2506
	local count = 100 -- 2507
	if req and req.body and req.body.count ~= nil then -- 2508
		count = req.body.count -- 2509
	end -- 2508
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2510
		return { -- 2511
			success = false, -- 2511
			message = "count must be a positive integer" -- 2511
		} -- 2511
	end -- 2510
	local folder = ".download" -- 2512
	local fullLogFile = "dora_full_logs.txt" -- 2513
	local fullFolder = Path(Content.writablePath, folder) -- 2514
	Content:mkdir(fullFolder) -- 2515
	local logPath = Path(fullFolder, fullLogFile) -- 2516
	if App:saveLog(logPath) then -- 2517
		local text = Content:load(logPath) -- 2518
		if text then -- 2519
			return { -- 2520
				success = true, -- 2520
				log = tailLines(text, count) -- 2520
			} -- 2520
		else -- 2522
			return { -- 2522
				success = false, -- 2522
				message = "failed to read log" -- 2522
			} -- 2522
		end -- 2519
	else -- 2524
		return { -- 2524
			success = false, -- 2524
			message = "failed to save log" -- 2524
		} -- 2524
	end -- 2517
	return { -- 2506
		success = false -- 2506
	} -- 2506
end) -- 2506
HttpServer:post("/yarn/check", function(req) -- 2526
	local yarncompile = require("yarncompile") -- 2527
	do -- 2528
		local _type_0 = type(req) -- 2528
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2528
		if _tab_0 then -- 2528
			local code -- 2528
			do -- 2528
				local _obj_0 = req.body -- 2528
				local _type_1 = type(_obj_0) -- 2528
				if "table" == _type_1 or "userdata" == _type_1 then -- 2528
					code = _obj_0.code -- 2528
				end -- 2528
			end -- 2528
			if code ~= nil then -- 2528
				local jsonObject = json.decode(code) -- 2529
				if jsonObject then -- 2529
					local errors = { } -- 2530
					local _list_0 = jsonObject.nodes -- 2531
					for _index_0 = 1, #_list_0 do -- 2531
						local node = _list_0[_index_0] -- 2531
						local title, body = node.title, node.body -- 2532
						local luaCode, err = yarncompile(body) -- 2533
						if not luaCode then -- 2533
							errors[#errors + 1] = title .. ":" .. err -- 2534
						end -- 2533
					end -- 2531
					return { -- 2535
						success = true, -- 2535
						syntaxError = table.concat(errors, "\n\n") -- 2535
					} -- 2535
				end -- 2529
			end -- 2528
		end -- 2528
	end -- 2528
	return { -- 2526
		success = false -- 2526
	} -- 2526
end) -- 2526
HttpServer:post("/yarn/check-file", function(req) -- 2537
	local yarncompile = require("yarncompile") -- 2538
	do -- 2539
		local _type_0 = type(req) -- 2539
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2539
		if _tab_0 then -- 2539
			local code -- 2539
			do -- 2539
				local _obj_0 = req.body -- 2539
				local _type_1 = type(_obj_0) -- 2539
				if "table" == _type_1 or "userdata" == _type_1 then -- 2539
					code = _obj_0.code -- 2539
				end -- 2539
			end -- 2539
			if code ~= nil then -- 2539
				local res, _, err = yarncompile(code, true) -- 2540
				if not res then -- 2540
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2541
					return { -- 2542
						success = false, -- 2542
						message = message, -- 2542
						line = line, -- 2542
						column = column, -- 2542
						node = node -- 2542
					} -- 2542
				end -- 2540
			end -- 2539
		end -- 2539
	end -- 2539
	return { -- 2537
		success = true -- 2537
	} -- 2537
end) -- 2537
getWaProjectDirFromFile = function(file) -- 2544
	local current -- 2545
	if Content:isdir(file) then -- 2545
		current = file -- 2545
	else -- 2545
		current = Path:getPath(file) -- 2545
	end -- 2545
	if current == "" then -- 2546
		return nil -- 2546
	end -- 2546
	repeat -- 2547
		local modPath = Path(current, "wa.mod") -- 2548
		if Content:exist(modPath) then -- 2549
			return current, modPath -- 2550
		end -- 2549
		local parent = Path:getPath(current) -- 2551
		if parent == "" or parent == current then -- 2552
			break -- 2552
		end -- 2552
		current = parent -- 2553
	until false -- 2547
	return nil -- 2555
end -- 2544
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2557
	do -- 2558
		local _type_0 = type(req) -- 2558
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2558
		if _tab_0 then -- 2558
			local path -- 2558
			do -- 2558
				local _obj_0 = req.body -- 2558
				local _type_1 = type(_obj_0) -- 2558
				if "table" == _type_1 or "userdata" == _type_1 then -- 2558
					path = _obj_0.path -- 2558
				end -- 2558
			end -- 2558
			if path ~= nil then -- 2558
				local projDir = getWaProjectDirFromFile(path) -- 2559
				if projDir then -- 2559
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2560
					if not Content:exist(sourceDoraPath) then -- 2561
						return { -- 2562
							success = false, -- 2562
							message = "missing dora template" -- 2562
						} -- 2562
					end -- 2561
					local targetVendorPath = Path(projDir, "vendor") -- 2563
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2564
					if not Content:exist(targetVendorPath) then -- 2565
						if not Content:mkdir(targetVendorPath) then -- 2566
							return { -- 2567
								success = false, -- 2567
								message = "failed to create vendor folder" -- 2567
							} -- 2567
						end -- 2566
					elseif not Content:isdir(targetVendorPath) then -- 2568
						return { -- 2569
							success = false, -- 2569
							message = "vendor path is not a folder" -- 2569
						} -- 2569
					end -- 2565
					if Content:exist(targetDoraPath) then -- 2570
						if not Content:remove(targetDoraPath) then -- 2571
							return { -- 2572
								success = false, -- 2572
								message = "failed to remove old dora" -- 2572
							} -- 2572
						end -- 2571
					end -- 2570
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2573
						return { -- 2574
							success = false, -- 2574
							message = "failed to copy dora" -- 2574
						} -- 2574
					end -- 2573
					return { -- 2575
						success = true -- 2575
					} -- 2575
				else -- 2577
					return { -- 2577
						success = false, -- 2577
						message = 'Wa file needs a project' -- 2577
					} -- 2577
				end -- 2559
			end -- 2558
		end -- 2558
	end -- 2558
	return { -- 2557
		success = false, -- 2557
		message = "invalid call" -- 2557
	} -- 2557
end) -- 2557
HttpServer:postSchedule("/wa/build", function(req) -- 2579
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
				local projDir = getWaProjectDirFromFile(path) -- 2581
				if projDir then -- 2581
					local message = Wasm:buildWaAsync(projDir) -- 2582
					if message == "" then -- 2583
						return { -- 2584
							success = true -- 2584
						} -- 2584
					else -- 2586
						return { -- 2586
							success = false, -- 2586
							message = message -- 2586
						} -- 2586
					end -- 2583
				else -- 2588
					return { -- 2588
						success = false, -- 2588
						message = 'Wa file needs a project' -- 2588
					} -- 2588
				end -- 2581
			end -- 2580
		end -- 2580
	end -- 2580
	return { -- 2589
		success = false, -- 2589
		message = 'failed to build' -- 2589
	} -- 2589
end) -- 2579
HttpServer:postSchedule("/wa/format", function(req) -- 2591
	do -- 2592
		local _type_0 = type(req) -- 2592
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2592
		if _tab_0 then -- 2592
			local file -- 2592
			do -- 2592
				local _obj_0 = req.body -- 2592
				local _type_1 = type(_obj_0) -- 2592
				if "table" == _type_1 or "userdata" == _type_1 then -- 2592
					file = _obj_0.file -- 2592
				end -- 2592
			end -- 2592
			if file ~= nil then -- 2592
				local code = Wasm:formatWaAsync(file) -- 2593
				if code == "" then -- 2594
					return { -- 2595
						success = false -- 2595
					} -- 2595
				else -- 2597
					return { -- 2597
						success = true, -- 2597
						code = code -- 2597
					} -- 2597
				end -- 2594
			end -- 2592
		end -- 2592
	end -- 2592
	return { -- 2598
		success = false -- 2598
	} -- 2598
end) -- 2591
HttpServer:postSchedule("/wa/create", function(req) -- 2600
	do -- 2601
		local _type_0 = type(req) -- 2601
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2601
		if _tab_0 then -- 2601
			local path -- 2601
			do -- 2601
				local _obj_0 = req.body -- 2601
				local _type_1 = type(_obj_0) -- 2601
				if "table" == _type_1 or "userdata" == _type_1 then -- 2601
					path = _obj_0.path -- 2601
				end -- 2601
			end -- 2601
			if path ~= nil then -- 2601
				if not Content:exist(Path:getPath(path)) then -- 2602
					return { -- 2603
						success = false, -- 2603
						message = "target path not existed" -- 2603
					} -- 2603
				end -- 2602
				if Content:exist(path) then -- 2604
					return { -- 2605
						success = false, -- 2605
						message = "target project folder existed" -- 2605
					} -- 2605
				end -- 2604
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2606
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2607
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2608
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2609
					return { -- 2612
						success = false, -- 2612
						message = "missing template project" -- 2612
					} -- 2612
				end -- 2609
				if not Content:mkdir(path) then -- 2613
					return { -- 2614
						success = false, -- 2614
						message = "failed to create project folder" -- 2614
					} -- 2614
				end -- 2613
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2615
					Content:remove(path) -- 2616
					return { -- 2617
						success = false, -- 2617
						message = "failed to copy template" -- 2617
					} -- 2617
				end -- 2615
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2618
					Content:remove(path) -- 2619
					return { -- 2620
						success = false, -- 2620
						message = "failed to copy template" -- 2620
					} -- 2620
				end -- 2618
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2621
					Content:remove(path) -- 2622
					return { -- 2623
						success = false, -- 2623
						message = "failed to copy template" -- 2623
					} -- 2623
				end -- 2621
				return { -- 2624
					success = true -- 2624
				} -- 2624
			end -- 2601
		end -- 2601
	end -- 2601
	return { -- 2600
		success = false, -- 2600
		message = "invalid call" -- 2600
	} -- 2600
end) -- 2600
local tsBuildGlobs = { -- 2627
	"**/*.ts", -- 2627
	"**/*.tsx", -- 2628
	"!**/.*/**", -- 2629
	"!**/node_modules/**" -- 2630
} -- 2626
local tsSnapshotGlobs = { -- 2633
	"**/*.ts", -- 2633
	"**/*.tsx", -- 2634
	"**/*.lua", -- 2635
	"!**/.*/**", -- 2636
	"!**/node_modules/**" -- 2637
} -- 2632
local collectTSVirtualFiles -- 2639
collectTSVirtualFiles = function(sourceRoot) -- 2639
	local files = { } -- 2640
	local seen = { } -- 2641
	local addFile -- 2642
	addFile = function(file, moduleName, virtualFile) -- 2642
		if moduleName == nil then -- 2642
			moduleName = nil -- 2642
		end -- 2642
		if virtualFile == nil then -- 2642
			virtualFile = nil -- 2642
		end -- 2642
		local targetFile = virtualFile or file -- 2643
		do -- 2644
			local entry = seen[targetFile] -- 2644
			if entry then -- 2644
				if moduleName and moduleName ~= "" then -- 2645
					entry.moduleName = moduleName -- 2645
				end -- 2645
				return -- 2646
			end -- 2644
		end -- 2644
		local content = Content:load(file) -- 2647
		if content then -- 2647
			local entry = { -- 2648
				file = targetFile, -- 2648
				content = content -- 2648
			} -- 2648
			if moduleName and moduleName ~= "" then -- 2649
				entry.moduleName = moduleName -- 2649
			end -- 2649
			seen[targetFile] = entry -- 2650
			files[#files + 1] = entry -- 2651
		end -- 2647
	end -- 2642
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2652
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2653
		for _index_0 = 1, #_list_0 do -- 2653
			local subFile = _list_0[_index_0] -- 2653
			addFile(Path(sourceRoot, subFile)) -- 2654
		end -- 2653
		local libraryRoots = { -- 2656
			Path(sourceRoot, "Script", "Lib"), -- 2656
			Path(sourceRoot, "Lib"), -- 2657
			Path(Content.assetPath, "Script", "Lib") -- 2658
		} -- 2655
		for _index_0 = 1, #libraryRoots do -- 2659
			local libraryRoot = libraryRoots[_index_0] -- 2659
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2660
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2661
				for _index_1 = 1, #_list_1 do -- 2661
					local subFile = _list_1[_index_1] -- 2661
					local file = Path(libraryRoot, subFile) -- 2662
					local virtualFile = Path(sourceRoot, subFile) -- 2663
					addFile(file, nil, virtualFile) -- 2664
				end -- 2661
			end -- 2660
		end -- 2659
	end -- 2652
	local locale -- 2665
	if App.locale:match('^zh') then -- 2665
		locale = 'zh-Hans' -- 2665
	else -- 2665
		locale = 'en' -- 2665
	end -- 2665
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2666
	local _list_0 = Content:getFiles(declarationRoot) -- 2667
	for _index_0 = 1, #_list_0 do -- 2667
		local file = _list_0[_index_0] -- 2667
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2668
			local fullPath = Path(declarationRoot, file) -- 2669
			local moduleName = Path:getName(Path:getName(file)) -- 2670
			addFile(fullPath, moduleName) -- 2671
		end -- 2668
	end -- 2667
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2672
	local lualibBundleTarget -- 2673
	if sourceRoot then -- 2673
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2673
	else -- 2673
		lualibBundleTarget = "lualib_bundle.lua" -- 2673
	end -- 2673
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2674
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2675
	local _list_1 = Content:getFiles(lualibRoot) -- 2676
	for _index_0 = 1, #_list_1 do -- 2676
		local file = _list_1[_index_0] -- 2676
		if Path:getExt(file) == "lua" then -- 2677
			local virtualFile -- 2678
			if sourceRoot then -- 2678
				virtualFile = Path(sourceRoot, "lualib", file) -- 2678
			else -- 2678
				virtualFile = Path("lualib", file) -- 2678
			end -- 2678
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2679
		end -- 2677
	end -- 2676
	return files -- 2680
end -- 2639
local supportsCompilerWebView -- 2682
supportsCompilerWebView = function() -- 2682
	local _val_0 = App.platform -- 2682
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2682
end -- 2682
local webIDECompilerReady = false -- 2683
local webIDEConnectionGeneration = 0 -- 2684
local tsProbeId = 0 -- 2685
local probeWebIDECompiler -- 2687
probeWebIDECompiler = function(isCancelled) -- 2687
	if HttpServer.wsConnectionCount == 0 then -- 2688
		return false -- 2688
	end -- 2688
	tsProbeId = tsProbeId + 1 -- 2689
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2690
	local generation = webIDEConnectionGeneration -- 2691
	local done, ready = false, false -- 2692
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2693
	local listener = Node() -- 2694
	listener:gslot("AppWS", function(event) -- 2695
		if event.type == "Receive" then -- 2696
			local res = json.decode(event.msg) -- 2697
			if res then -- 2697
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2698
					responses = responses + 1 -- 2699
					ready = ready or res.success == true -- 2700
					done = ready or responses >= expectedResponses -- 2701
				end -- 2698
			end -- 2697
		end -- 2696
	end) -- 2695
	emit("AppWS", "Send", json.encode({ -- 2702
		name = "TranspileTSProbe", -- 2702
		id = requestId -- 2702
	})) -- 2702
	local deadline = App.runningTime + 5 -- 2703
	wait(function() -- 2704
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2704
	end) -- 2704
	listener:removeFromParent() -- 2705
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2706
	if generation == webIDEConnectionGeneration then -- 2707
		webIDECompilerReady = ready -- 2707
	end -- 2707
	return ready -- 2708
end -- 2687
local compilerConnectionListener = Node() -- 2710
compilerConnectionListener:addTo(Director.systemUI) -- 2712
local _anon_func_8 = function(event) -- 2714
	local _val_0 = event.type -- 2714
	return "Open" == _val_0 or "Close" == _val_0 -- 2714
end -- 2714
compilerConnectionListener:gslot("AppWS", function(event) -- 2713
	if _anon_func_8(event) then -- 2714
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2715
		webIDECompilerReady = false -- 2716
		if HttpServer.wsConnectionCount > 0 then -- 2717
			return thread(function() -- 2718
				return probeWebIDECompiler() -- 2718
			end) -- 2718
		end -- 2717
	end -- 2714
end) -- 2713
local _anon_func_9 = function(res) -- 2743
	if res.success then -- 2743
		return "tool" -- 2743
	else -- 2743
		return res.failureKind -- 2743
	end -- 2743
end -- 2743
local transpileTSFileWithWebIDE -- 2720
do -- 2720
	local tsBuildRequestId = 0 -- 2721
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2722
		if not probeWebIDECompiler(isCancelled) then -- 2723
			if isCancelled and isCancelled() then -- 2724
				return { -- 2725
					success = false, -- 2725
					file = file, -- 2725
					message = "build canceled", -- 2725
					interrupted = true -- 2725
				} -- 2725
			end -- 2724
			return { -- 2726
				success = false, -- 2726
				file = file, -- 2726
				message = "TypeScript transpiler is not ready", -- 2726
				failureKind = "tool" -- 2726
			} -- 2726
		end -- 2723
		tsBuildRequestId = tsBuildRequestId + 1 -- 2727
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2728
		local done = false -- 2729
		local result = nil -- 2730
		local listener = Node() -- 2731
		listener:gslot("AppWS", function(event) -- 2732
			if event.type == "Receive" then -- 2733
				local res = json.decode(event.msg) -- 2734
				if res then -- 2734
					if res.name == "TranspileTS" and res.id == requestId then -- 2735
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2736
							local luaFile = Path:replaceExt(file, "lua") -- 2737
							if Content:save(luaFile, res.luaCode) then -- 2738
								result = { -- 2739
									success = true, -- 2739
									file = file -- 2739
								} -- 2739
							else -- 2741
								result = { -- 2741
									success = false, -- 2741
									file = file, -- 2741
									message = "failed to save " .. tostring(luaFile) -- 2741
								} -- 2741
							end -- 2738
						else -- 2743
							result = { -- 2743
								success = false, -- 2743
								file = file, -- 2743
								message = res.message or "Compiler returned no Lua output", -- 2743
								failureKind = _anon_func_9(res) -- 2743
							} -- 2743
						end -- 2736
						done = true -- 2744
					end -- 2735
				end -- 2734
			end -- 2733
		end) -- 2732
		emit("AppWS", "Send", json.encode({ -- 2745
			name = "TranspileTS", -- 2745
			id = requestId, -- 2745
			file = file, -- 2745
			content = content, -- 2745
			projectRoot = sourceRoot, -- 2745
			files = files -- 2745
		})) -- 2745
		local deadline = App.runningTime + 30 -- 2746
		wait(function() -- 2747
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2747
		end) -- 2747
		listener:removeFromParent() -- 2748
		if not done then -- 2749
			webIDECompilerReady = false -- 2750
			if isCancelled and isCancelled() then -- 2751
				return { -- 2752
					success = false, -- 2752
					file = file, -- 2752
					message = "build canceled", -- 2752
					interrupted = true -- 2752
				} -- 2752
			end -- 2751
			return { -- 2753
				success = false, -- 2753
				file = file, -- 2753
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2753
				failureKind = "tool" -- 2753
			} -- 2753
		end -- 2749
		return result -- 2754
	end -- 2722
end -- 2720
local compilerReadyTimeout <const> = 15 -- 2756
local compilerBuildTimeout <const> = 30 -- 2757
local compilerIdleCloseSeconds <const> = 8 -- 2758
local compilerReady = false -- 2759
local compilerRequested = false -- 2760
local compilerFailure = nil -- 2761
local compilerUsers = 0 -- 2762
local compilerCloseGeneration = 0 -- 2763
local compilerJobId = 0 -- 2764
local compilerJobs = { } -- 2765
local compilerResults = { } -- 2766
local compilerInFlight = { } -- 2767
HttpServer:post("/compiler/ready", function() -- 2769
	if not compilerRequested then -- 2770
		return { -- 2770
			success = false -- 2770
		} -- 2770
	end -- 2770
	compilerReady = true -- 2771
	return { -- 2772
		success = true -- 2772
	} -- 2772
end) -- 2769
HttpServer:post("/compiler/failure", function(req) -- 2774
	if not compilerRequested then -- 2775
		return { -- 2775
			success = false -- 2775
		} -- 2775
	end -- 2775
	do -- 2776
		local _type_0 = type(req) -- 2776
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2776
		if _tab_0 then -- 2776
			local message -- 2776
			do -- 2776
				local _obj_0 = req.body -- 2776
				local _type_1 = type(_obj_0) -- 2776
				if "table" == _type_1 or "userdata" == _type_1 then -- 2776
					message = _obj_0.message -- 2776
				end -- 2776
			end -- 2776
			if message ~= nil then -- 2776
				if type(message) == "string" then -- 2777
					compilerFailure = message -- 2778
					compilerReady = false -- 2779
					return { -- 2780
						success = true -- 2780
					} -- 2780
				end -- 2777
			end -- 2776
		end -- 2776
	end -- 2776
	return { -- 2774
		success = false -- 2774
	} -- 2774
end) -- 2774
HttpServer:postSchedule("/compiler/poll", function() -- 2782
	if not compilerRequested then -- 2783
		return { -- 2783
			success = false -- 2783
		} -- 2783
	end -- 2783
	compilerReady = true -- 2784
	local deadline = App.runningTime + 5 -- 2785
	wait(function() -- 2786
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2786
	end) -- 2786
	if not (compilerRequested and not compilerFailure) then -- 2787
		return { -- 2787
			success = false -- 2787
		} -- 2787
	end -- 2787
	local job = table.remove(compilerJobs, 1) -- 2788
	if job then -- 2789
		compilerInFlight[job.id] = true -- 2790
	end -- 2789
	return { -- 2791
		success = true, -- 2791
		job = job -- 2791
	} -- 2791
end) -- 2782
HttpServer:post("/compiler/result", function(req) -- 2793
	do -- 2794
		local _type_0 = type(req) -- 2794
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2794
		if _tab_0 then -- 2794
			local body = req.body -- 2794
			if body ~= nil then -- 2794
				local id = body.id -- 2795
				if not (id and compilerInFlight[id]) then -- 2796
					return { -- 2796
						success = false, -- 2796
						message = "invalid compiler job" -- 2796
					} -- 2796
				end -- 2796
				compilerInFlight[id] = nil -- 2797
				compilerResults[id] = body -- 2798
				return { -- 2799
					success = true -- 2799
				} -- 2799
			end -- 2794
		end -- 2794
	end -- 2794
	return { -- 2793
		success = false -- 2793
	} -- 2793
end) -- 2793
local acquireCompiler -- 2801
acquireCompiler = function() -- 2801
	compilerUsers = compilerUsers + 1 -- 2802
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2803
	if not compilerRequested then -- 2804
		compilerRequested = true -- 2805
		compilerReady = false -- 2806
		compilerFailure = nil -- 2807
		return emit("AppWebView", "/compiler.html", true) -- 2808
	end -- 2804
end -- 2801
local releaseCompiler -- 2810
releaseCompiler = function() -- 2810
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2811
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2812
	if not (compilerUsers == 0) then -- 2813
		return -- 2813
	end -- 2813
	local closeGeneration = compilerCloseGeneration -- 2814
	return thread(function() -- 2815
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2816
		wait(function() -- 2817
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2818
		end) -- 2817
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2823
			compilerRequested = false -- 2824
			compilerReady = false -- 2825
			return emit("AppWebView", "/compiler.html", false) -- 2826
		end -- 2823
	end) -- 2815
end -- 2810
local removeCompilerJob -- 2828
removeCompilerJob = function(id) -- 2828
	for index = #compilerJobs, 1, -1 do -- 2829
		if compilerJobs[index].id == id then -- 2830
			table.remove(compilerJobs, index) -- 2831
		end -- 2830
	end -- 2829
	compilerInFlight[id] = nil -- 2832
	compilerResults[id] = nil -- 2833
end -- 2828
local transpileTSFileWithCompiler -- 2835
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2835
	acquireCompiler() -- 2836
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2837
	wait(function() -- 2838
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2838
	end) -- 2838
	if not compilerReady then -- 2839
		releaseCompiler() -- 2840
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
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2843
			failureKind = "tool" -- 2843
		} -- 2843
	end -- 2839
	compilerJobId = compilerJobId + 1 -- 2844
	local jobId = compilerJobId -- 2845
	compilerJobs[#compilerJobs + 1] = { -- 2847
		id = jobId, -- 2847
		file = file, -- 2848
		content = content, -- 2849
		projectRoot = sourceRoot, -- 2850
		files = files -- 2851
	} -- 2846
	local deadline = App.runningTime + compilerBuildTimeout -- 2852
	wait(function() -- 2853
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2853
	end) -- 2853
	local response = compilerResults[jobId] -- 2854
	removeCompilerJob(jobId) -- 2855
	releaseCompiler() -- 2856
	if not response then -- 2857
		if isCancelled and isCancelled() then -- 2858
			return { -- 2859
				success = false, -- 2859
				file = file, -- 2859
				message = "build canceled", -- 2859
				interrupted = true -- 2859
			} -- 2859
		end -- 2858
		return { -- 2860
			success = false, -- 2860
			file = file, -- 2860
			message = compilerFailure or "TypeScript transpile timed out", -- 2860
			failureKind = "tool" -- 2860
		} -- 2860
	end -- 2857
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2861
		local luaFile = Path:replaceExt(file, "lua") -- 2862
		if Content:save(luaFile, response.luaCode) then -- 2863
			return { -- 2864
				success = true, -- 2864
				file = file -- 2864
			} -- 2864
		end -- 2863
		return { -- 2865
			success = false, -- 2865
			file = file, -- 2865
			message = "failed to save " .. tostring(luaFile) -- 2865
		} -- 2865
	end -- 2861
	return { -- 2866
		success = false, -- 2866
		file = file, -- 2866
		message = response.message or "TypeScript transpile failed" -- 2866
	} -- 2866
end -- 2835
local compilerFailureListener = Node() -- 2868
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2869
	compilerFailure = message -- 2870
	compilerReady = false -- 2871
end) -- 2869
local transpileTSFile -- 2873
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2873
	if supportsCompilerWebView() and not files then -- 2874
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2875
	end -- 2874
	if HttpServer.wsConnectionCount > 0 then -- 2876
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2877
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2878
			return result -- 2878
		end -- 2878
		webIDECompilerReady = false -- 2879
	end -- 2876
	if supportsCompilerWebView() then -- 2880
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2881
	end -- 2880
	return { -- 2882
		success = false, -- 2882
		file = file, -- 2882
		message = "Web IDE compiler not connected", -- 2882
		failureKind = "tool" -- 2882
	} -- 2882
end -- 2873
local _anon_func_10 = function(path) -- 2897
	local _val_0 = Path:getExt(path) -- 2897
	return "ts" == _val_0 or "tsx" == _val_0 -- 2897
end -- 2897
HttpServer:postSchedule("/ts/build", function(req) -- 2884
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2885
	local buildSucceeded = false -- 2886
	local _ <close> = setmetatable({ }, { -- 2887
		__close = function() -- 2887
			return finishUpdate(buildSucceeded) -- 2887
		end -- 2887
	}) -- 2887
	do -- 2888
		local _type_0 = type(req) -- 2888
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2888
		if _tab_0 then -- 2888
			local path -- 2888
			do -- 2888
				local _obj_0 = req.body -- 2888
				local _type_1 = type(_obj_0) -- 2888
				if "table" == _type_1 or "userdata" == _type_1 then -- 2888
					path = _obj_0.path -- 2888
				end -- 2888
			end -- 2888
			if path ~= nil then -- 2888
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2889
					return { -- 2890
						success = false, -- 2890
						message = "Web IDE not connected" -- 2890
					} -- 2890
				end -- 2889
				local projectRoot = req.body.projectRoot -- 2891
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2892
				if not Content:exist(path) then -- 2893
					return { -- 2894
						success = false, -- 2894
						message = "path not existed" -- 2894
					} -- 2894
				end -- 2893
				local messages = { } -- 2895
				if not Content:isdir(path) then -- 2896
					if not (_anon_func_10(path)) then -- 2897
						return { -- 2898
							success = false, -- 2898
							message = "expecting a TypeScript file" -- 2898
						} -- 2898
					end -- 2897
					local content = Content:load(path) -- 2899
					if not content then -- 2900
						return { -- 2901
							success = false, -- 2901
							message = "failed to read file" -- 2901
						} -- 2901
					end -- 2900
					emit("AppWS", "Send", json.encode({ -- 2902
						name = "UpdateFile", -- 2902
						file = path, -- 2902
						exists = true, -- 2902
						content = content, -- 2902
						projectRoot = sourceRoot -- 2902
					})) -- 2902
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2903
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2904
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2905
					end -- 2903
				else -- 2907
					local fileData = { } -- 2907
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2908
					for _index_0 = 1, #_list_0 do -- 2908
						local subFile = _list_0[_index_0] -- 2908
						local file = Path(path, subFile) -- 2909
						local content = Content:load(file) -- 2910
						if content then -- 2910
							fileData[file] = content -- 2911
							emit("AppWS", "Send", json.encode({ -- 2912
								name = "UpdateFile", -- 2912
								file = file, -- 2912
								exists = true, -- 2912
								content = content, -- 2912
								projectRoot = sourceRoot -- 2912
							})) -- 2912
						else -- 2914
							messages[#messages + 1] = { -- 2914
								success = false, -- 2914
								file = file, -- 2914
								message = "failed to read file" -- 2914
							} -- 2914
						end -- 2910
					end -- 2908
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2915
					for file, content in pairs(fileData) do -- 2916
						if "d" == Path:getExt(Path:getName(file)) then -- 2917
							goto _continue_0 -- 2917
						end -- 2917
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2918
						::_continue_0:: -- 2917
					end -- 2916
				end -- 2896
				local success = true -- 2919
				for _index_0 = 1, #messages do -- 2920
					local item = messages[_index_0] -- 2920
					if not item.success then -- 2921
						success = false -- 2921
					end -- 2921
				end -- 2920
				local message = nil -- 2922
				if not success then -- 2923
					message = "TypeScript compilation failed" -- 2923
				end -- 2923
				buildSucceeded = success -- 2924
				return { -- 2925
					success = success, -- 2925
					messages = messages, -- 2925
					message = message -- 2925
				} -- 2925
			end -- 2888
		end -- 2888
	end -- 2888
	return { -- 2884
		success = false -- 2884
	} -- 2884
end) -- 2884
HttpServer:post("/download", function(req) -- 2927
	do -- 2928
		local _type_0 = type(req) -- 2928
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2928
		if _tab_0 then -- 2928
			local url -- 2928
			do -- 2928
				local _obj_0 = req.body -- 2928
				local _type_1 = type(_obj_0) -- 2928
				if "table" == _type_1 or "userdata" == _type_1 then -- 2928
					url = _obj_0.url -- 2928
				end -- 2928
			end -- 2928
			local target -- 2928
			do -- 2928
				local _obj_0 = req.body -- 2928
				local _type_1 = type(_obj_0) -- 2928
				if "table" == _type_1 or "userdata" == _type_1 then -- 2928
					target = _obj_0.target -- 2928
				end -- 2928
			end -- 2928
			if url ~= nil and target ~= nil then -- 2928
				local Entry = require("Script.Dev.Entry") -- 2929
				Entry.downloadFile(url, target) -- 2930
				return { -- 2931
					success = true -- 2931
				} -- 2931
			end -- 2928
		end -- 2928
	end -- 2928
	return { -- 2927
		success = false -- 2927
	} -- 2927
end) -- 2927
local isDesktopPlatform -- 2933
isDesktopPlatform = function() -- 2933
	local _val_0 = App.platform -- 2934
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2934
end -- 2933
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 2936
local nativeIDEListener = Node() -- 2937
nativeIDEListener:addTo(Director.systemUI) -- 2938
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 2939
	nativeIDEState, nativeIDEMessage = state, message -- 2940
end) -- 2939
local _anon_func_11 = function() -- 2943
	local _val_0 = App.platform -- 2943
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2943
end -- 2943
HttpServer:post("/ide", function(req) -- 2942
	if not (_anon_func_11()) then -- 2943
		return { -- 2943
			success = false, -- 2943
			message = "Native IDE is unavailable" -- 2943
		} -- 2943
	end -- 2943
	if not App.webIDEEnabled then -- 2944
		return { -- 2944
			success = false, -- 2944
			message = "Embedded Web IDE is disabled" -- 2944
		} -- 2944
	end -- 2944
	do -- 2945
		local _type_0 = type(req) -- 2945
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2945
		if _tab_0 then -- 2945
			local action -- 2945
			do -- 2945
				local _obj_0 = req.body -- 2945
				local _type_1 = type(_obj_0) -- 2945
				if "table" == _type_1 or "userdata" == _type_1 then -- 2945
					action = _obj_0.action -- 2945
				end -- 2945
			end -- 2945
			if action ~= nil then -- 2945
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 2946
					emit("AppWebView", "/ide/" .. action, true) -- 2947
					return { -- 2948
						success = true -- 2948
					} -- 2948
				end -- 2946
			end -- 2945
		end -- 2945
	end -- 2945
	return { -- 2942
		success = false, -- 2942
		message = "invalid IDE action" -- 2942
	} -- 2942
end) -- 2942
local _anon_func_12 = function() -- 2964
	local _val_0 = App.platform -- 2964
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2964
end -- 2964
local getServerStatus -- 2950
getServerStatus = function() -- 2950
	local Entry = require("Script.Dev.Entry") -- 2951
	local running = Entry.getCurrentEntryStatus() -- 2952
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2953
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2954
	return { -- 2956
		success = true, -- 2956
		platform = App.platform, -- 2957
		locale = App.locale, -- 2958
		version = App.version, -- 2959
		url = "http://localhost:8866", -- 2960
		wsConnectionCount = wsConnectionCount, -- 2961
		webIDEConnected = wsConnectionCount > 0, -- 2962
		nativeIDE = { -- 2964
			supported = _anon_func_12(), -- 2964
			enabled = App.webIDEEnabled, -- 2965
			state = nativeIDEState, -- 2966
			message = nativeIDEMessage -- 2967
		}, -- 2963
		typescriptCompiler = { -- 2969
			webIDEReady = webIDECompilerReady, -- 2969
			webIDEGeneration = webIDEConnectionGeneration, -- 2970
			embeddedSupported = supportsCompilerWebView(), -- 2971
			embeddedRequested = compilerRequested, -- 2972
			embeddedReady = compilerReady, -- 2973
			users = compilerUsers, -- 2974
			queuedJobs = #compilerJobs, -- 2975
			failure = compilerFailure -- 2976
		}, -- 2968
		assetPath = Content.assetPath, -- 2977
		writablePath = Content.writablePath, -- 2978
		appPath = Content.appPath, -- 2979
		waTemplateReady = waTemplateReady, -- 2980
		running = running -- 2981
	} -- 2955
end -- 2950
HttpServer:post("/status", function() -- 2984
	return getServerStatus() -- 2985
end) -- 2984
HttpServer:postSchedule("/doctor/fix", function(req) -- 2987
	do -- 2988
		local _type_0 = type(req) -- 2988
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2988
		if _tab_0 then -- 2988
			local openWebIDE -- 2988
			do -- 2988
				local _obj_0 = req.body -- 2988
				local _type_1 = type(_obj_0) -- 2988
				if "table" == _type_1 or "userdata" == _type_1 then -- 2988
					openWebIDE = _obj_0.openWebIDE -- 2988
				end -- 2988
			end -- 2988
			if openWebIDE ~= nil then -- 2988
				if not openWebIDE then -- 2989
					return { -- 2990
						success = false, -- 2990
						message = "nothing to fix" -- 2990
					} -- 2990
				end -- 2989
				local status = getServerStatus() -- 2991
				if status.webIDEConnected then -- 2992
					return { -- 2993
						success = true, -- 2993
						fixed = false, -- 2993
						message = "Web IDE already connected.", -- 2993
						status = status -- 2993
					} -- 2993
				end -- 2992
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2994
				if waitSeconds > 0 then -- 2995
					local deadline = os.time() + waitSeconds -- 2996
					repeat -- 2997
						sleep(0.2) -- 2998
						status = getServerStatus() -- 2999
						if status.webIDEConnected then -- 3000
							return { -- 3001
								success = true, -- 3001
								fixed = false, -- 3001
								reconnected = true, -- 3001
								message = "Web IDE reconnected.", -- 3001
								status = status -- 3001
							} -- 3001
						end -- 3000
					until os.time() >= deadline -- 2997
				end -- 2995
				if not isDesktopPlatform() then -- 3003
					return { -- 3004
						success = false, -- 3004
						message = "opening Web IDE is only supported on desktop platforms", -- 3004
						status = status -- 3004
					} -- 3004
				end -- 3003
				local url = "http://localhost:8866" -- 3005
				App:openURL(url) -- 3006
				status.openedURL = url -- 3007
				return { -- 3008
					success = true, -- 3008
					fixed = true, -- 3008
					message = "Opened Web IDE in the local browser.", -- 3008
					url = url, -- 3008
					status = status -- 3008
				} -- 3008
			end -- 2988
		end -- 2988
	end -- 2988
	return { -- 2987
		success = false, -- 2987
		message = "invalid call" -- 2987
	} -- 2987
end) -- 2987
local status = { } -- 3010
_module_0 = status -- 3011
status.transpileTSFile = transpileTSFile -- 3013
status.buildAsync = function(path) -- 3015
	if not Content:exist(path) then -- 3016
		return { -- 3017
			success = false, -- 3017
			file = path, -- 3017
			message = "file not existed" -- 3017
		} -- 3017
	end -- 3016
	do -- 3018
		local _exp_0 = Path:getExt(path) -- 3018
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 3018
			if '' == Path:getExt(Path:getName(path)) then -- 3019
				local content = Content:loadAsync(path) -- 3020
				if content then -- 3020
					local resultCodes, err = compileFileAsync(path, content) -- 3021
					if resultCodes then -- 3021
						return { -- 3022
							success = true, -- 3022
							file = path -- 3022
						} -- 3022
					else -- 3024
						return { -- 3024
							success = false, -- 3024
							file = path, -- 3024
							message = err -- 3024
						} -- 3024
					end -- 3021
				end -- 3020
			end -- 3019
		elseif "lua" == _exp_0 then -- 3025
			local content = Content:loadAsync(path) -- 3026
			if content then -- 3026
				do -- 3027
					local isTIC80 = CheckTIC80Code(content) -- 3027
					if isTIC80 then -- 3027
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 3028
					end -- 3027
				end -- 3027
				local success, info -- 3029
				do -- 3029
					local _obj_0 = luaCheck(path, content) -- 3029
					success, info = _obj_0.success, _obj_0.info -- 3029
				end -- 3029
				if success then -- 3030
					return { -- 3031
						success = true, -- 3031
						file = path -- 3031
					} -- 3031
				elseif info and #info > 0 then -- 3032
					local messages = { } -- 3033
					for _index_0 = 1, #info do -- 3034
						local _des_0 = info[_index_0] -- 3034
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3034
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
						if line then -- 3043
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3044
						else -- 3046
							messages[#messages + 1] = message -- 3046
						end -- 3043
					end -- 3034
					return { -- 3047
						success = false, -- 3047
						file = path, -- 3047
						message = table.concat(messages, "\n") -- 3047
					} -- 3047
				else -- 3049
					return { -- 3049
						success = false, -- 3049
						file = path, -- 3049
						message = "lua check failed" -- 3049
					} -- 3049
				end -- 3030
			end -- 3026
		elseif "yarn" == _exp_0 then -- 3050
			local content = Content:loadAsync(path) -- 3051
			if content then -- 3051
				local res, _, err = yarncompile(content, true) -- 3052
				if res then -- 3052
					return { -- 3053
						success = true, -- 3053
						file = path -- 3053
					} -- 3053
				else -- 3055
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3055
					local lineText = "" -- 3056
					if line then -- 3057
						local currentLine = 1 -- 3058
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3059
							if currentLine == line then -- 3060
								lineText = text -- 3061
								break -- 3062
							end -- 3060
							currentLine = currentLine + 1 -- 3063
						end -- 3059
					end -- 3057
					if node ~= "" then -- 3064
						node = "node: " .. tostring(node) .. ", " -- 3065
					else -- 3066
						node = "" -- 3066
					end -- 3064
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3067
					return { -- 3068
						success = false, -- 3068
						file = path, -- 3068
						message = message -- 3068
					} -- 3068
				end -- 3052
			end -- 3051
		end -- 3018
	end -- 3018
	return { -- 3069
		success = false, -- 3069
		file = path, -- 3069
		message = "invalid file to build" -- 3069
	} -- 3069
end -- 3015
HttpServer:postSchedule("/git/commit-files", function(req) -- 3071
	do -- 3072
		local _type_0 = type(req) -- 3072
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3072
		if _tab_0 then -- 3072
			local body = req.body -- 3072
			if body ~= nil then -- 3072
				local repoPath, commit = body.repoPath, body.commit -- 3073
				if gitInvalidRepoPath(repoPath) then -- 3074
					return { -- 3074
						success = false, -- 3074
						message = "invalid repoPath" -- 3074
					} -- 3074
				end -- 3074
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3075
					return { -- 3075
						success = false, -- 3075
						message = "invalid commit" -- 3075
					} -- 3075
				end -- 3075
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3076
				if not res.success then -- 3077
					return res -- 3077
				end -- 3077
				return { -- 3078
					success = true, -- 3078
					status = res.status, -- 3078
					data = res.status and res.status.data -- 3078
				} -- 3078
			end -- 3072
		end -- 3072
	end -- 3072
	return invalidArguments -- 3071
end) -- 3071
thread(function() -- 3080
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3081
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3082
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3083
		local storedAsset -- 3086
		storedAsset = function(file) -- 3086
			if Content:exist(file) then -- 3087
				return Content:load(file) -- 3088
			elseif Content:exist(file .. ".gz") then -- 3089
				return Content:load(file .. ".gz") -- 3090
			else -- 3091
				return "" -- 3091
			end -- 3087
		end -- 3086
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3092
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3093
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3094
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3095
		local readyContent = table.concat({ -- 3097
			App.version, -- 3097
			storedAsset(doraWeb), -- 3098
			storedAsset(heavyAssets), -- 3099
			storedAsset(runtimeIndex), -- 3100
			storedAsset(compilerIndex), -- 3101
			storedAsset(manifest) -- 3102
		}, "\n") -- 3096
		local needReload -- 3104
		if Content:exist(doraReady) then -- 3104
			needReload = readyContent ~= Content:load(doraReady) -- 3105
		else -- 3106
			needReload = true -- 3106
		end -- 3104
		if needReload then -- 3107
			Content:remove(Path(Content.appPath, ".www")) -- 3108
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3109
			Content:save(doraReady, readyContent) -- 3113
			print("Dora Dora is ready!") -- 3114
		end -- 3107
	end -- 3083
	if App.platform == "Emscripten" then -- 3115
		status.url = nil -- 3116
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3117
	end -- 3115
	HttpServer:clearStaticCacheControls() -- 3118
	HttpServer:setStaticCacheControl("no-cache") -- 3119
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3120
	if HttpServer:start(8866) then -- 3124
		local localIP = HttpServer.localIP -- 3125
		if localIP == "" then -- 3126
			localIP = "localhost" -- 3126
		end -- 3126
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3127
		return HttpServer:startWS(8868) -- 3128
	else -- 3130
		status.url = nil -- 3130
		return print("8866 Port not available!") -- 3131
	end -- 3124
end) -- 3080
return _module_0 -- 1
