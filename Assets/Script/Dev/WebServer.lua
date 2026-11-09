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
local setmetatable <const> = setmetatable -- 10
local xml <const> = xml -- 10
local ipairs <const> = ipairs -- 10
local App <const> = App -- 10
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
				if item[1] ~= "global" and not item[5]:match("unused") then -- 963
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
					if "global" == _exp_0 then -- 969
						item[1] = "syntax" -- 970
					elseif "type" == _exp_0 then -- 971
						item[1] = "warning" -- 972
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 973
						goto _continue_0 -- 974
					end -- 968
				end -- 968
				_accum_0[_len_0] = item -- 975
				_len_0 = _len_0 + 1 -- 962
				::_continue_0:: -- 962
			end -- 961
			info = _accum_0 -- 961
		end -- 961
		if #info == 0 then -- 976
			info = nil -- 977
			success = true -- 978
		end -- 976
	end -- 960
	return { -- 979
		success = success, -- 979
		info = info -- 979
	} -- 979
end -- 954
local luaCheckWithLineInfo -- 981
luaCheckWithLineInfo = function(file, luaCodes) -- 981
	local res = luaCheck(file, luaCodes) -- 982
	local info = { } -- 983
	if not res.success then -- 984
		local current = 1 -- 985
		local lastLine = 1 -- 986
		local lineMap = { } -- 987
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 988
			local num = lineCode:match("--%s*(%d+)%s*$") -- 989
			if num then -- 990
				lastLine = tonumber(num) -- 991
			end -- 990
			lineMap[current] = lastLine -- 992
			current = current + 1 -- 993
		end -- 988
		local _list_0 = res.info -- 994
		for _index_0 = 1, #_list_0 do -- 994
			local item = _list_0[_index_0] -- 994
			item[3] = lineMap[item[3]] or 0 -- 995
			item[4] = 0 -- 996
			info[#info + 1] = item -- 997
		end -- 994
		return false, info -- 998
	end -- 984
	return true, info -- 999
end -- 981
local getCompiledYueLine -- 1001
getCompiledYueLine = function(content, line, row, file, lax) -- 1001
	local luaCodes = yueCheck(file, content, lax) -- 1002
	if not luaCodes then -- 1003
		return nil -- 1003
	end -- 1003
	local current = 1 -- 1004
	local lastLine = 1 -- 1005
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 1006
	local targetRow = nil -- 1007
	local lineMap = { } -- 1008
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 1009
		local num = lineCode:match("--%s*(%d+)%s*$") -- 1010
		if num then -- 1011
			lastLine = tonumber(num) -- 1011
		end -- 1011
		lineMap[current] = lastLine -- 1012
		if row <= lastLine and not targetRow then -- 1013
			targetRow = current -- 1014
			break -- 1015
		end -- 1013
		current = current + 1 -- 1016
	end -- 1009
	targetRow = current -- 1017
	if targetLine and targetRow then -- 1018
		return luaCodes, targetLine, targetRow, lineMap -- 1019
	else -- 1021
		return nil -- 1021
	end -- 1018
end -- 1001
local godotCheckAsync -- 1023
godotCheckAsync = function(file, content, coalesce) -- 1023
	if coalesce == nil then -- 1023
		coalesce = true -- 1023
	end -- 1023
	if not (type(file) == "string" and Content:isAbsolutePath(file) and type(content) == "string") then -- 1024
		return { -- 1024
			success = false, -- 1024
			info = { -- 1024
				{ -- 1024
					"syntax", -- 1024
					tostring(file), -- 1024
					1, -- 1024
					0, -- 1024
					"Invalid Godot check request" -- 1024
				} -- 1024
			} -- 1024
		} -- 1024
	end -- 1024
	local releaseAgent = AgentHost.acquire() -- 1025
	local _ <close> = setmetatable({ }, { -- 1026
		__close = function() -- 1026
			return releaseAgent() -- 1026
		end -- 1026
	}) -- 1026
	local GodotBuild = require("Agent.Tool.GodotBuild") -- 1027
	local project = GodotBuild.findGodotProject(Content.writablePath, file) or GodotBuild.findGodotProject(Content.assetPath, file) -- 1028
	if not project then -- 1029
		return { -- 1029
			success = false, -- 1029
			info = { -- 1029
				{ -- 1029
					"syntax", -- 1029
					file, -- 1029
					1, -- 1029
					0, -- 1029
					"Godot file does not belong to a project with project.godot" -- 1029
				} -- 1029
			} -- 1029
		} -- 1029
	end -- 1029
	local GodotCheck = require("Agent.Tool.GodotCheck") -- 1030
	local result -- 1031
	local onFulfilled -- 1032
	onFulfilled = function(_, value) -- 1032
		result = value -- 1032
	end -- 1032
	local onRejected -- 1033
	onRejected = function(_, err) -- 1033
		result = { -- 1033
			success = false, -- 1033
			info = { -- 1033
				{ -- 1033
					"tool", -- 1033
					file, -- 1033
					1, -- 1033
					0, -- 1033
					tostring(err) -- 1033
				} -- 1033
			} -- 1033
		} -- 1033
	end -- 1033
	local promise = GodotCheck.checkGodotFile(project, file, content, coalesce) -- 1034
	promise["then"](promise, onFulfilled, onRejected) -- 1035
	wait(function() -- 1036
		return result ~= nil -- 1036
	end) -- 1036
	return result -- 1037
end -- 1023
HttpServer:postSchedule("/check", function(req) -- 1039
	do -- 1040
		local _type_0 = type(req) -- 1040
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1040
		if _tab_0 then -- 1040
			local file -- 1040
			do -- 1040
				local _obj_0 = req.body -- 1040
				local _type_1 = type(_obj_0) -- 1040
				if "table" == _type_1 or "userdata" == _type_1 then -- 1040
					file = _obj_0.file -- 1040
				end -- 1040
			end -- 1040
			local content -- 1040
			do -- 1040
				local _obj_0 = req.body -- 1040
				local _type_1 = type(_obj_0) -- 1040
				if "table" == _type_1 or "userdata" == _type_1 then -- 1040
					content = _obj_0.content -- 1040
				end -- 1040
			end -- 1040
			if file ~= nil and content ~= nil then -- 1040
				local ext = Path:getExt(file) -- 1041
				if "gd" == ext or "tscn" == ext or "tres" == ext or "gdshader" == ext or "gdshaderinc" == ext then -- 1042
					return godotCheckAsync(file, content) -- 1043
				elseif "tl" == ext then -- 1044
					local searchPath = getSearchPath(file) -- 1045
					do -- 1046
						local isTIC80 = CheckTIC80Code(content) -- 1046
						if isTIC80 then -- 1046
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1047
						end -- 1046
					end -- 1046
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 1048
					return { -- 1049
						success = success, -- 1049
						info = info -- 1049
					} -- 1049
				elseif "lua" == ext then -- 1050
					do -- 1051
						local isTIC80 = CheckTIC80Code(content) -- 1051
						if isTIC80 then -- 1051
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1052
						end -- 1051
					end -- 1051
					return luaCheck(file, content) -- 1053
				elseif "yue" == ext then -- 1054
					local luaCodes, info = yueCheck(file, content, false) -- 1055
					local success = luaCodes ~= nil -- 1056
					if luaCodes then -- 1057
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 1058
						do -- 1059
							local _tab_1 = { } -- 1059
							local _idx_0 = #_tab_1 + 1 -- 1059
							for _index_0 = 1, #info do -- 1059
								local _value_0 = info[_index_0] -- 1059
								_tab_1[_idx_0] = _value_0 -- 1059
								_idx_0 = _idx_0 + 1 -- 1059
							end -- 1059
							local _idx_1 = #_tab_1 + 1 -- 1059
							for _index_0 = 1, #luaInfo do -- 1059
								local _value_0 = luaInfo[_index_0] -- 1059
								_tab_1[_idx_1] = _value_0 -- 1059
								_idx_1 = _idx_1 + 1 -- 1059
							end -- 1059
							info = _tab_1 -- 1059
						end -- 1059
						success = success and luaSuccess -- 1060
					end -- 1057
					if #info > 0 then -- 1061
						return { -- 1062
							success = success, -- 1062
							info = info -- 1062
						} -- 1062
					else -- 1064
						return { -- 1064
							success = success -- 1064
						} -- 1064
					end -- 1061
				elseif "xml" == ext then -- 1065
					local success, result = xml.check(content) -- 1066
					if success then -- 1067
						local info -- 1068
						success, info = luaCheckWithLineInfo(file, result) -- 1068
						if #info > 0 then -- 1069
							return { -- 1070
								success = success, -- 1070
								info = info -- 1070
							} -- 1070
						else -- 1072
							return { -- 1072
								success = success -- 1072
							} -- 1072
						end -- 1069
					else -- 1074
						local info -- 1074
						do -- 1074
							local _accum_0 = { } -- 1074
							local _len_0 = 1 -- 1074
							for _index_0 = 1, #result do -- 1074
								local _des_0 = result[_index_0] -- 1074
								local row, err = _des_0[1], _des_0[2] -- 1074
								_accum_0[_len_0] = { -- 1075
									"syntax", -- 1075
									file, -- 1075
									row, -- 1075
									0, -- 1075
									err -- 1075
								} -- 1075
								_len_0 = _len_0 + 1 -- 1075
							end -- 1074
							info = _accum_0 -- 1074
						end -- 1074
						return { -- 1076
							success = false, -- 1076
							info = info -- 1076
						} -- 1076
					end -- 1067
				end -- 1042
			end -- 1040
		end -- 1040
	end -- 1040
	return { -- 1039
		success = true -- 1039
	} -- 1039
end) -- 1039
HttpServer:post("/body/parse", function(req) -- 1078
	do -- 1079
		local _type_0 = type(req) -- 1079
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1079
		if _tab_0 then -- 1079
			local file -- 1079
			do -- 1079
				local _obj_0 = req.body -- 1079
				local _type_1 = type(_obj_0) -- 1079
				if "table" == _type_1 or "userdata" == _type_1 then -- 1079
					file = _obj_0.file -- 1079
				end -- 1079
			end -- 1079
			local content -- 1079
			do -- 1079
				local _obj_0 = req.body -- 1079
				local _type_1 = type(_obj_0) -- 1079
				if "table" == _type_1 or "userdata" == _type_1 then -- 1079
					content = _obj_0.content -- 1079
				end -- 1079
			end -- 1079
			if file ~= nil and content ~= nil then -- 1079
				if not (file:sub(-6) == ".b.lua") then -- 1080
					return { -- 1081
						success = false, -- 1081
						phase = "request", -- 1081
						message = "only .b.lua files can be converted" -- 1081
					} -- 1081
				end -- 1080
				local loader, err = load("_ENV = {}\n" .. content) -- 1082
				if not loader then -- 1083
					return { -- 1084
						success = false, -- 1084
						phase = "parse", -- 1084
						message = tostring(err) -- 1084
					} -- 1084
				end -- 1083
				local ok, data = pcall(loader) -- 1085
				if not ok then -- 1086
					return { -- 1087
						success = false, -- 1087
						phase = "execute", -- 1087
						message = tostring(data) -- 1087
					} -- 1087
				end -- 1086
				if not ("table" == type(data) and data[1] == "Array") then -- 1088
					return { -- 1089
						success = false, -- 1089
						phase = "validate", -- 1089
						message = "body lua root must be {\"Array\", ...}" -- 1089
					} -- 1089
				end -- 1088
				local text, jsonErr = json.encode(data, false, true) -- 1090
				if not text then -- 1091
					return { -- 1092
						success = false, -- 1092
						phase = "encode", -- 1092
						message = tostring(jsonErr) -- 1092
					} -- 1092
				end -- 1091
				return { -- 1093
					success = true, -- 1093
					json = text -- 1093
				} -- 1093
			end -- 1079
		end -- 1079
	end -- 1079
	return { -- 1078
		success = false, -- 1078
		phase = "request", -- 1078
		message = "invalid request" -- 1078
	} -- 1078
end) -- 1078
local updateInferedDesc -- 1095
updateInferedDesc = function(infered) -- 1095
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1096
		return -- 1096
	end -- 1096
	local key, row = infered.key, infered.row -- 1097
	local codes = Content:loadAsync(key) -- 1098
	if codes then -- 1098
		local comments = { } -- 1099
		local line = 0 -- 1100
		local skipping = false -- 1101
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1102
			line = line + 1 -- 1103
			if line >= row then -- 1104
				break -- 1104
			end -- 1104
			if lineCode:match("^%s*%-%- @") then -- 1105
				skipping = true -- 1106
				goto _continue_0 -- 1107
			end -- 1105
			local result = lineCode:match("^%s*%-%- (.+)") -- 1108
			if result then -- 1108
				if not skipping then -- 1109
					comments[#comments + 1] = result -- 1109
				end -- 1109
			elseif #comments > 0 then -- 1110
				comments = { } -- 1111
				skipping = false -- 1112
			end -- 1108
			::_continue_0:: -- 1103
		end -- 1102
		infered.doc = table.concat(comments, "\n") -- 1113
	end -- 1098
end -- 1095
HttpServer:postSchedule("/infer", function(req) -- 1115
	do -- 1116
		local _type_0 = type(req) -- 1116
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1116
		if _tab_0 then -- 1116
			local lang -- 1116
			do -- 1116
				local _obj_0 = req.body -- 1116
				local _type_1 = type(_obj_0) -- 1116
				if "table" == _type_1 or "userdata" == _type_1 then -- 1116
					lang = _obj_0.lang -- 1116
				end -- 1116
			end -- 1116
			local file -- 1116
			do -- 1116
				local _obj_0 = req.body -- 1116
				local _type_1 = type(_obj_0) -- 1116
				if "table" == _type_1 or "userdata" == _type_1 then -- 1116
					file = _obj_0.file -- 1116
				end -- 1116
			end -- 1116
			local content -- 1116
			do -- 1116
				local _obj_0 = req.body -- 1116
				local _type_1 = type(_obj_0) -- 1116
				if "table" == _type_1 or "userdata" == _type_1 then -- 1116
					content = _obj_0.content -- 1116
				end -- 1116
			end -- 1116
			local line -- 1116
			do -- 1116
				local _obj_0 = req.body -- 1116
				local _type_1 = type(_obj_0) -- 1116
				if "table" == _type_1 or "userdata" == _type_1 then -- 1116
					line = _obj_0.line -- 1116
				end -- 1116
			end -- 1116
			local row -- 1116
			do -- 1116
				local _obj_0 = req.body -- 1116
				local _type_1 = type(_obj_0) -- 1116
				if "table" == _type_1 or "userdata" == _type_1 then -- 1116
					row = _obj_0.row -- 1116
				end -- 1116
			end -- 1116
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1116
				local searchPath = getSearchPath(file) -- 1117
				if "tl" == lang or "lua" == lang then -- 1118
					if CheckTIC80Code(content) then -- 1119
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1120
					end -- 1119
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1121
					if (infered ~= nil) then -- 1122
						updateInferedDesc(infered) -- 1123
						return { -- 1124
							success = true, -- 1124
							infered = infered -- 1124
						} -- 1124
					end -- 1122
				elseif "yue" == lang then -- 1125
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1126
					if not luaCodes then -- 1127
						return { -- 1127
							success = false -- 1127
						} -- 1127
					end -- 1127
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1128
					if (infered ~= nil) then -- 1129
						local col -- 1130
						file, row, col = infered.file, infered.row, infered.col -- 1130
						if file == "" and row > 0 and col > 0 then -- 1131
							infered.row = lineMap[row] or 0 -- 1132
							infered.col = 0 -- 1133
						end -- 1131
						updateInferedDesc(infered) -- 1134
						return { -- 1135
							success = true, -- 1135
							infered = infered -- 1135
						} -- 1135
					end -- 1129
				end -- 1118
			end -- 1116
		end -- 1116
	end -- 1116
	return { -- 1115
		success = false -- 1115
	} -- 1115
end) -- 1115
local _anon_func_3 = function(doc) -- 1196
	local _accum_0 = { } -- 1196
	local _len_0 = 1 -- 1196
	local _list_0 = doc.params -- 1196
	for _index_0 = 1, #_list_0 do -- 1196
		local param = _list_0[_index_0] -- 1196
		_accum_0[_len_0] = param.name -- 1196
		_len_0 = _len_0 + 1 -- 1196
	end -- 1196
	return _accum_0 -- 1196
end -- 1196
local getParamDocs -- 1137
getParamDocs = function(signatures) -- 1137
	if not (signatures and #signatures > 0) then -- 1138
		return nil -- 1138
	end -- 1138
	local docs = { } -- 1139
	do -- 1140
		local codes = Content:loadAsync(signatures[1].file) -- 1140
		if codes then -- 1140
			local comments = { } -- 1141
			local params = { } -- 1142
			local line = 0 -- 1143
			local returnType = nil -- 1144
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1145
				line = line + 1 -- 1146
				local needBreak = true -- 1147
				for i, _des_0 in ipairs(signatures) do -- 1148
					local row = _des_0.row -- 1148
					if line >= row and not (docs[i] ~= nil) then -- 1149
						if #comments > 0 or #params > 0 or returnType then -- 1150
							docs[i] = { -- 1152
								doc = table.concat(comments, "  \n"), -- 1152
								returnType = returnType -- 1153
							} -- 1151
							if #params > 0 then -- 1155
								docs[i].params = params -- 1155
							end -- 1155
						else -- 1157
							docs[i] = false -- 1157
						end -- 1150
					end -- 1149
					if not docs[i] then -- 1158
						needBreak = false -- 1158
					end -- 1158
				end -- 1148
				if needBreak then -- 1159
					break -- 1159
				end -- 1159
				local result = lineCode:match("%s*%-%- (.+)") -- 1160
				if result then -- 1160
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1161
					if not name then -- 1162
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1163
					end -- 1162
					if name then -- 1164
						local pname = name -- 1165
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1166
							pname = pname .. "?" -- 1166
						end -- 1166
						params[#params + 1] = { -- 1168
							name = tostring(pname) .. ": " .. tostring(typ), -- 1168
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1169
						} -- 1167
					else -- 1172
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1172
						if typ then -- 1172
							if returnType then -- 1173
								returnType = returnType .. ", " .. typ -- 1174
							else -- 1176
								returnType = typ -- 1176
							end -- 1173
							result = result:gsub("@return", "**return:**") -- 1177
						end -- 1172
						comments[#comments + 1] = result -- 1178
					end -- 1164
				elseif #comments > 0 then -- 1179
					comments = { } -- 1180
					params = { } -- 1181
					returnType = nil -- 1182
				end -- 1160
			end -- 1145
		end -- 1140
	end -- 1140
	local results = { } -- 1183
	for i, signature in ipairs(signatures) do -- 1184
		local item = { -- 1186
			desc = signature.desc, -- 1186
			doc = "", -- 1187
			file = signature.file, -- 1188
			row = signature.row, -- 1189
			col = signature.col -- 1190
		} -- 1185
		do -- 1192
			local doc = docs[i] -- 1192
			if doc then -- 1192
				item.doc = doc.doc -- 1193
				if doc.params then -- 1194
					item.params = doc.params -- 1195
					item.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1196
				elseif doc.returnType then -- 1197
					item.desc = "function()" -- 1198
				end -- 1194
				if doc.returnType then -- 1199
					item.desc = item.desc .. ": " .. tostring(doc.returnType) -- 1199
				end -- 1199
			end -- 1192
		end -- 1192
		results[#results + 1] = item -- 1200
	end -- 1184
	return results -- 1201
end -- 1137
HttpServer:postSchedule("/signature", function(req) -- 1203
	do -- 1204
		local _type_0 = type(req) -- 1204
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1204
		if _tab_0 then -- 1204
			local lang -- 1204
			do -- 1204
				local _obj_0 = req.body -- 1204
				local _type_1 = type(_obj_0) -- 1204
				if "table" == _type_1 or "userdata" == _type_1 then -- 1204
					lang = _obj_0.lang -- 1204
				end -- 1204
			end -- 1204
			local file -- 1204
			do -- 1204
				local _obj_0 = req.body -- 1204
				local _type_1 = type(_obj_0) -- 1204
				if "table" == _type_1 or "userdata" == _type_1 then -- 1204
					file = _obj_0.file -- 1204
				end -- 1204
			end -- 1204
			local content -- 1204
			do -- 1204
				local _obj_0 = req.body -- 1204
				local _type_1 = type(_obj_0) -- 1204
				if "table" == _type_1 or "userdata" == _type_1 then -- 1204
					content = _obj_0.content -- 1204
				end -- 1204
			end -- 1204
			local line -- 1204
			do -- 1204
				local _obj_0 = req.body -- 1204
				local _type_1 = type(_obj_0) -- 1204
				if "table" == _type_1 or "userdata" == _type_1 then -- 1204
					line = _obj_0.line -- 1204
				end -- 1204
			end -- 1204
			local row -- 1204
			do -- 1204
				local _obj_0 = req.body -- 1204
				local _type_1 = type(_obj_0) -- 1204
				if "table" == _type_1 or "userdata" == _type_1 then -- 1204
					row = _obj_0.row -- 1204
				end -- 1204
			end -- 1204
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1204
				local searchPath = getSearchPath(file) -- 1205
				if "tl" == lang or "lua" == lang then -- 1206
					if CheckTIC80Code(content) then -- 1207
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1208
					end -- 1207
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1209
					if signatures then -- 1209
						signatures = getParamDocs(signatures) -- 1210
						if signatures then -- 1210
							return { -- 1211
								success = true, -- 1211
								signatures = signatures -- 1211
							} -- 1211
						end -- 1210
					end -- 1209
				elseif "yue" == lang then -- 1212
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1213
					if not luaCodes then -- 1214
						return { -- 1214
							success = false -- 1214
						} -- 1214
					end -- 1214
					do -- 1215
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1215
						if chainOp then -- 1215
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1216
							if withVar then -- 1216
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1217
							end -- 1216
						end -- 1215
					end -- 1215
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1218
					if signatures then -- 1218
						signatures = getParamDocs(signatures) -- 1219
						if signatures then -- 1219
							return { -- 1220
								success = true, -- 1220
								signatures = signatures -- 1220
							} -- 1220
						end -- 1219
					else -- 1221
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1221
						if signatures then -- 1221
							signatures = getParamDocs(signatures) -- 1222
							if signatures then -- 1222
								return { -- 1223
									success = true, -- 1223
									signatures = signatures -- 1223
								} -- 1223
							end -- 1222
						end -- 1221
					end -- 1218
				end -- 1206
			end -- 1204
		end -- 1204
	end -- 1204
	return { -- 1203
		success = false -- 1203
	} -- 1203
end) -- 1203
local luaKeywords = { -- 1226
	'and', -- 1226
	'break', -- 1227
	'do', -- 1228
	'else', -- 1229
	'elseif', -- 1230
	'end', -- 1231
	'false', -- 1232
	'for', -- 1233
	'function', -- 1234
	'goto', -- 1235
	'if', -- 1236
	'in', -- 1237
	'local', -- 1238
	'nil', -- 1239
	'not', -- 1240
	'or', -- 1241
	'repeat', -- 1242
	'return', -- 1243
	'then', -- 1244
	'true', -- 1245
	'until', -- 1246
	'while' -- 1247
} -- 1225
local tealKeywords = { -- 1251
	'record', -- 1251
	'as', -- 1252
	'is', -- 1253
	'type', -- 1254
	'embed', -- 1255
	'enum', -- 1256
	'global', -- 1257
	'any', -- 1258
	'boolean', -- 1259
	'integer', -- 1260
	'number', -- 1261
	'string', -- 1262
	'thread' -- 1263
} -- 1250
local yueKeywords = { -- 1267
	"and", -- 1267
	"break", -- 1268
	"do", -- 1269
	"else", -- 1270
	"elseif", -- 1271
	"false", -- 1272
	"for", -- 1273
	"goto", -- 1274
	"if", -- 1275
	"in", -- 1276
	"local", -- 1277
	"nil", -- 1278
	"not", -- 1279
	"or", -- 1280
	"repeat", -- 1281
	"return", -- 1282
	"then", -- 1283
	"true", -- 1284
	"until", -- 1285
	"while", -- 1286
	"as", -- 1287
	"class", -- 1288
	"continue", -- 1289
	"export", -- 1290
	"extends", -- 1291
	"from", -- 1292
	"global", -- 1293
	"import", -- 1294
	"macro", -- 1295
	"switch", -- 1296
	"try", -- 1297
	"unless", -- 1298
	"using", -- 1299
	"when", -- 1300
	"with" -- 1301
} -- 1266
local _anon_func_4 = function(f) -- 1337
	local _val_0 = Path:getExt(f) -- 1337
	return "ttf" == _val_0 or "otf" == _val_0 -- 1337
end -- 1337
local _anon_func_5 = function(suggestions) -- 1363
	local _tbl_0 = { } -- 1363
	for _index_0 = 1, #suggestions do -- 1363
		local item = suggestions[_index_0] -- 1363
		_tbl_0[item[1] .. item[2]] = item -- 1363
	end -- 1363
	return _tbl_0 -- 1363
end -- 1363
HttpServer:postSchedule("/complete", function(req) -- 1304
	do -- 1305
		local _type_0 = type(req) -- 1305
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1305
		if _tab_0 then -- 1305
			local lang -- 1305
			do -- 1305
				local _obj_0 = req.body -- 1305
				local _type_1 = type(_obj_0) -- 1305
				if "table" == _type_1 or "userdata" == _type_1 then -- 1305
					lang = _obj_0.lang -- 1305
				end -- 1305
			end -- 1305
			local file -- 1305
			do -- 1305
				local _obj_0 = req.body -- 1305
				local _type_1 = type(_obj_0) -- 1305
				if "table" == _type_1 or "userdata" == _type_1 then -- 1305
					file = _obj_0.file -- 1305
				end -- 1305
			end -- 1305
			local content -- 1305
			do -- 1305
				local _obj_0 = req.body -- 1305
				local _type_1 = type(_obj_0) -- 1305
				if "table" == _type_1 or "userdata" == _type_1 then -- 1305
					content = _obj_0.content -- 1305
				end -- 1305
			end -- 1305
			local line -- 1305
			do -- 1305
				local _obj_0 = req.body -- 1305
				local _type_1 = type(_obj_0) -- 1305
				if "table" == _type_1 or "userdata" == _type_1 then -- 1305
					line = _obj_0.line -- 1305
				end -- 1305
			end -- 1305
			local row -- 1305
			do -- 1305
				local _obj_0 = req.body -- 1305
				local _type_1 = type(_obj_0) -- 1305
				if "table" == _type_1 or "userdata" == _type_1 then -- 1305
					row = _obj_0.row -- 1305
				end -- 1305
			end -- 1305
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1305
				local searchPath = getSearchPath(file) -- 1306
				repeat -- 1307
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1308
					if lang == "yue" then -- 1309
						if not item then -- 1310
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1310
						end -- 1310
						if not item then -- 1311
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1311
						end -- 1311
					end -- 1309
					local searchType = nil -- 1312
					if not item then -- 1313
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1314
						if lang == "yue" then -- 1315
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1316
						end -- 1315
						if (item ~= nil) then -- 1317
							searchType = "Image" -- 1317
						end -- 1317
					end -- 1313
					if not item then -- 1318
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1319
						if lang == "yue" then -- 1320
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1321
						end -- 1320
						if (item ~= nil) then -- 1322
							searchType = "Font" -- 1322
						end -- 1322
					end -- 1318
					if not item then -- 1323
						break -- 1323
					end -- 1323
					local searchPaths = Content.searchPaths -- 1324
					local _list_0 = getSearchFolders(file) -- 1325
					for _index_0 = 1, #_list_0 do -- 1325
						local folder = _list_0[_index_0] -- 1325
						searchPaths[#searchPaths + 1] = folder -- 1326
					end -- 1325
					if searchType then -- 1327
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1327
					end -- 1327
					local tokens -- 1328
					do -- 1328
						local _accum_0 = { } -- 1328
						local _len_0 = 1 -- 1328
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1328
							_accum_0[_len_0] = mod -- 1328
							_len_0 = _len_0 + 1 -- 1328
						end -- 1328
						tokens = _accum_0 -- 1328
					end -- 1328
					local suggestions = { } -- 1329
					for _index_0 = 1, #searchPaths do -- 1330
						local path = searchPaths[_index_0] -- 1330
						local sPath = Path(path, table.unpack(tokens)) -- 1331
						if not Content:exist(sPath) then -- 1332
							goto _continue_0 -- 1332
						end -- 1332
						if searchType == "Font" then -- 1333
							local fontPath = Path(sPath, "Font") -- 1334
							if Content:exist(fontPath) then -- 1335
								local _list_1 = Content:getFiles(fontPath) -- 1336
								for _index_1 = 1, #_list_1 do -- 1336
									local f = _list_1[_index_1] -- 1336
									if _anon_func_4(f) then -- 1337
										if "." == f:sub(1, 1) then -- 1338
											goto _continue_1 -- 1338
										end -- 1338
										suggestions[#suggestions + 1] = { -- 1339
											Path:getName(f), -- 1339
											"font", -- 1339
											"field" -- 1339
										} -- 1339
									end -- 1337
									::_continue_1:: -- 1337
								end -- 1336
							end -- 1335
						end -- 1333
						local _list_1 = Content:getFiles(sPath) -- 1340
						for _index_1 = 1, #_list_1 do -- 1340
							local f = _list_1[_index_1] -- 1340
							if "Image" == searchType then -- 1341
								do -- 1342
									local _exp_0 = Path:getExt(f) -- 1342
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1342
										if "." == f:sub(1, 1) then -- 1343
											goto _continue_2 -- 1343
										end -- 1343
										suggestions[#suggestions + 1] = { -- 1344
											f, -- 1344
											"image", -- 1344
											"field" -- 1344
										} -- 1344
									end -- 1342
								end -- 1342
								goto _continue_2 -- 1345
							elseif "Font" == searchType then -- 1346
								do -- 1347
									local _exp_0 = Path:getExt(f) -- 1347
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1347
										if "." == f:sub(1, 1) then -- 1348
											goto _continue_2 -- 1348
										end -- 1348
										suggestions[#suggestions + 1] = { -- 1349
											f, -- 1349
											"font", -- 1349
											"field" -- 1349
										} -- 1349
									end -- 1347
								end -- 1347
								goto _continue_2 -- 1350
							end -- 1341
							local _exp_0 = Path:getExt(f) -- 1351
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1351
								local name = Path:getName(f) -- 1352
								if "d" == Path:getExt(name) then -- 1353
									goto _continue_2 -- 1353
								end -- 1353
								if "." == name:sub(1, 1) then -- 1354
									goto _continue_2 -- 1354
								end -- 1354
								suggestions[#suggestions + 1] = { -- 1355
									name, -- 1355
									"module", -- 1355
									"field" -- 1355
								} -- 1355
							end -- 1351
							::_continue_2:: -- 1341
						end -- 1340
						local _list_2 = Content:getDirs(sPath) -- 1356
						for _index_1 = 1, #_list_2 do -- 1356
							local dir = _list_2[_index_1] -- 1356
							if "." == dir:sub(1, 1) then -- 1357
								goto _continue_3 -- 1357
							end -- 1357
							suggestions[#suggestions + 1] = { -- 1358
								dir, -- 1358
								"folder", -- 1358
								"variable" -- 1358
							} -- 1358
							::_continue_3:: -- 1357
						end -- 1356
						::_continue_0:: -- 1331
					end -- 1330
					if item == "" and not searchType then -- 1359
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1360
						for _index_0 = 1, #_list_1 do -- 1360
							local _des_0 = _list_1[_index_0] -- 1360
							local name = _des_0[1] -- 1360
							suggestions[#suggestions + 1] = { -- 1361
								name, -- 1361
								"dora module", -- 1361
								"function" -- 1361
							} -- 1361
						end -- 1360
					end -- 1359
					if #suggestions > 0 then -- 1362
						do -- 1363
							local _accum_0 = { } -- 1363
							local _len_0 = 1 -- 1363
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1363
								_accum_0[_len_0] = v -- 1363
								_len_0 = _len_0 + 1 -- 1363
							end -- 1363
							suggestions = _accum_0 -- 1363
						end -- 1363
						return { -- 1364
							success = true, -- 1364
							suggestions = suggestions -- 1364
						} -- 1364
					else -- 1366
						return { -- 1366
							success = false -- 1366
						} -- 1366
					end -- 1362
				until true -- 1307
				if "tl" == lang or "lua" == lang then -- 1368
					do -- 1369
						local isTIC80 = CheckTIC80Code(content) -- 1369
						if isTIC80 then -- 1369
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1370
						end -- 1369
					end -- 1369
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1371
					if not line:match("[%.:]$") then -- 1372
						local checkSet -- 1373
						do -- 1373
							local _tbl_0 = { } -- 1373
							for _index_0 = 1, #suggestions do -- 1373
								local _des_0 = suggestions[_index_0] -- 1373
								local name = _des_0[1] -- 1373
								_tbl_0[name] = true -- 1373
							end -- 1373
							checkSet = _tbl_0 -- 1373
						end -- 1373
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1374
						for _index_0 = 1, #_list_0 do -- 1374
							local item = _list_0[_index_0] -- 1374
							if not checkSet[item[1]] then -- 1375
								suggestions[#suggestions + 1] = item -- 1375
							end -- 1375
						end -- 1374
						for _index_0 = 1, #luaKeywords do -- 1376
							local word = luaKeywords[_index_0] -- 1376
							suggestions[#suggestions + 1] = { -- 1377
								word, -- 1377
								"keyword", -- 1377
								"keyword" -- 1377
							} -- 1377
						end -- 1376
						if lang == "tl" then -- 1378
							for _index_0 = 1, #tealKeywords do -- 1379
								local word = tealKeywords[_index_0] -- 1379
								suggestions[#suggestions + 1] = { -- 1380
									word, -- 1380
									"keyword", -- 1380
									"keyword" -- 1380
								} -- 1380
							end -- 1379
						end -- 1378
					end -- 1372
					if #suggestions > 0 then -- 1381
						return { -- 1382
							success = true, -- 1382
							suggestions = suggestions -- 1382
						} -- 1382
					end -- 1381
				elseif "yue" == lang then -- 1383
					local suggestions = { } -- 1384
					local gotGlobals = false -- 1385
					do -- 1386
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1386
						if luaCodes then -- 1386
							gotGlobals = true -- 1387
							do -- 1388
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1388
								if chainOp then -- 1388
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1389
									if not withVar then -- 1390
										return { -- 1390
											success = false -- 1390
										} -- 1390
									end -- 1390
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1391
								elseif line:match("^([%.\\])$") then -- 1392
									return { -- 1393
										success = false -- 1393
									} -- 1393
								end -- 1388
							end -- 1388
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1394
							for _index_0 = 1, #_list_0 do -- 1394
								local item = _list_0[_index_0] -- 1394
								suggestions[#suggestions + 1] = item -- 1394
							end -- 1394
							if #suggestions == 0 then -- 1395
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1396
								for _index_0 = 1, #_list_1 do -- 1396
									local item = _list_1[_index_0] -- 1396
									suggestions[#suggestions + 1] = item -- 1396
								end -- 1396
							end -- 1395
						end -- 1386
					end -- 1386
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1397
						local checkSet -- 1398
						do -- 1398
							local _tbl_0 = { } -- 1398
							for _index_0 = 1, #suggestions do -- 1398
								local _des_0 = suggestions[_index_0] -- 1398
								local name = _des_0[1] -- 1398
								_tbl_0[name] = true -- 1398
							end -- 1398
							checkSet = _tbl_0 -- 1398
						end -- 1398
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1399
						for _index_0 = 1, #_list_0 do -- 1399
							local item = _list_0[_index_0] -- 1399
							if not checkSet[item[1]] then -- 1400
								suggestions[#suggestions + 1] = item -- 1400
							end -- 1400
						end -- 1399
						if not gotGlobals then -- 1401
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1402
							for _index_0 = 1, #_list_1 do -- 1402
								local item = _list_1[_index_0] -- 1402
								if not checkSet[item[1]] then -- 1403
									suggestions[#suggestions + 1] = item -- 1403
								end -- 1403
							end -- 1402
						end -- 1401
						for _index_0 = 1, #yueKeywords do -- 1404
							local word = yueKeywords[_index_0] -- 1404
							if not checkSet[word] then -- 1405
								suggestions[#suggestions + 1] = { -- 1406
									word, -- 1406
									"keyword", -- 1406
									"keyword" -- 1406
								} -- 1406
							end -- 1405
						end -- 1404
					end -- 1397
					if #suggestions > 0 then -- 1407
						return { -- 1408
							success = true, -- 1408
							suggestions = suggestions -- 1408
						} -- 1408
					end -- 1407
				elseif "xml" == lang then -- 1409
					local items = xml.complete(content) -- 1410
					if #items > 0 then -- 1411
						local suggestions -- 1412
						do -- 1412
							local _accum_0 = { } -- 1412
							local _len_0 = 1 -- 1412
							for _index_0 = 1, #items do -- 1412
								local _des_0 = items[_index_0] -- 1412
								local label, insertText = _des_0[1], _des_0[2] -- 1412
								_accum_0[_len_0] = { -- 1413
									label, -- 1413
									insertText, -- 1413
									"field" -- 1413
								} -- 1413
								_len_0 = _len_0 + 1 -- 1413
							end -- 1412
							suggestions = _accum_0 -- 1412
						end -- 1412
						return { -- 1414
							success = true, -- 1414
							suggestions = suggestions -- 1414
						} -- 1414
					end -- 1411
				end -- 1368
			end -- 1305
		end -- 1305
	end -- 1305
	return { -- 1304
		success = false -- 1304
	} -- 1304
end) -- 1304
local getUploadFilename -- 1416
getUploadFilename = function(req, multipartFilename) -- 1416
	local filename = req.params.name -- 1417
	if not (type(filename) == "string" and filename ~= "") then -- 1418
		filename = multipartFilename -- 1418
	end -- 1418
	if not (type(filename) == "string" and filename ~= "") then -- 1419
		return -- 1419
	end -- 1419
	if filename:sub(1, 1) == "/" or filename:sub(-1) == "/" or filename:find("//", 1, true) or filename:find("\\", 1, true) or filename:find(":", 1, true) or filename:find("\0", 1, true) then -- 1422
		return -- 1422
	end -- 1422
	local parts -- 1423
	do -- 1423
		local _accum_0 = { } -- 1423
		local _len_0 = 1 -- 1423
		for part in filename:gmatch("[^/]+") do -- 1423
			_accum_0[_len_0] = part -- 1423
			_len_0 = _len_0 + 1 -- 1423
		end -- 1423
		parts = _accum_0 -- 1423
	end -- 1423
	if #parts == 0 then -- 1424
		return -- 1424
	end -- 1424
	for _index_0 = 1, #parts do -- 1425
		local part = parts[_index_0] -- 1425
		if part == "." or part == ".." or part == "" then -- 1426
			return -- 1426
		end -- 1426
	end -- 1425
	return filename -- 1427
end -- 1416
HttpServer:upload("/upload", function(req, multipartFilename) -- 1431
	do -- 1432
		local _type_0 = type(req) -- 1432
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1432
		if _tab_0 then -- 1432
			local path -- 1432
			do -- 1432
				local _obj_0 = req.params -- 1432
				local _type_1 = type(_obj_0) -- 1432
				if "table" == _type_1 or "userdata" == _type_1 then -- 1432
					path = _obj_0.path -- 1432
				end -- 1432
			end -- 1432
			if path ~= nil then -- 1432
				local filename = getUploadFilename(req, multipartFilename) -- 1433
				if filename then -- 1433
					local uploadPath = Path(Content.writablePath, ".upload", "files") -- 1434
					if not Content:exist(uploadPath) then -- 1435
						Content:mkdir(uploadPath) -- 1436
					end -- 1435
					local targetPath = Path(uploadPath, filename) -- 1437
					Content:mkdir(Path:getPath(targetPath)) -- 1438
					return targetPath -- 1439
				end -- 1433
			end -- 1432
		end -- 1432
	end -- 1432
	return nil -- 1431
end, function(req, file) -- 1440
	do -- 1441
		local _type_0 = type(req) -- 1441
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1441
		if _tab_0 then -- 1441
			local path -- 1441
			do -- 1441
				local _obj_0 = req.params -- 1441
				local _type_1 = type(_obj_0) -- 1441
				if "table" == _type_1 or "userdata" == _type_1 then -- 1441
					path = _obj_0.path -- 1441
				end -- 1441
			end -- 1441
			if path ~= nil then -- 1441
				path = Path(Content.writablePath, path) -- 1442
				if Content:exist(path) then -- 1443
					local uploadPath = Path(Content.writablePath, ".upload", "files") -- 1444
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1445
					Content:mkdir(Path:getPath(targetPath)) -- 1446
					if Content:move(file, targetPath) then -- 1447
						return true -- 1448
					end -- 1447
				end -- 1443
			end -- 1441
		end -- 1441
	end -- 1441
	return false -- 1440
end) -- 1429
HttpServer:post("/list", function(req) -- 1451
	do -- 1452
		local _type_0 = type(req) -- 1452
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1452
		if _tab_0 then -- 1452
			local path -- 1452
			do -- 1452
				local _obj_0 = req.body -- 1452
				local _type_1 = type(_obj_0) -- 1452
				if "table" == _type_1 or "userdata" == _type_1 then -- 1452
					path = _obj_0.path -- 1452
				end -- 1452
			end -- 1452
			if path ~= nil then -- 1452
				if Content:exist(path) then -- 1453
					local files = { } -- 1454
					local visitAssets -- 1455
					visitAssets = function(path, folder) -- 1455
						local dirs = Content:getDirs(path) -- 1456
						for _index_0 = 1, #dirs do -- 1457
							local dir = dirs[_index_0] -- 1457
							if dir:match("^%.") or dir == "node_modules" then -- 1458
								goto _continue_0 -- 1458
							end -- 1458
							local current -- 1459
							if folder == "" then -- 1459
								current = dir -- 1460
							else -- 1462
								current = Path(folder, dir) -- 1462
							end -- 1459
							files[#files + 1] = current -- 1463
							visitAssets(Path(path, dir), current) -- 1464
							::_continue_0:: -- 1458
						end -- 1457
						local fs = Content:getFiles(path) -- 1465
						for _index_0 = 1, #fs do -- 1466
							local f = fs[_index_0] -- 1466
							if (".DS_Store" == f) then -- 1467
								goto _continue_1 -- 1468
							end -- 1467
							if folder == "" then -- 1469
								files[#files + 1] = f -- 1470
							else -- 1472
								files[#files + 1] = Path(folder, f) -- 1472
							end -- 1469
							::_continue_1:: -- 1467
						end -- 1466
					end -- 1455
					visitAssets(path, "") -- 1473
					if #files == 0 then -- 1474
						files = nil -- 1474
					end -- 1474
					return { -- 1475
						success = true, -- 1475
						files = files -- 1475
					} -- 1475
				end -- 1453
			end -- 1452
		end -- 1452
	end -- 1452
	return { -- 1451
		success = false -- 1451
	} -- 1451
end) -- 1451
HttpServer:post("/info", function(req) -- 1477
	local Entry = require("Script.Dev.Entry") -- 1478
	local config = Entry.getConfig() -- 1479
	do -- 1480
		local _type_0 = type(req) -- 1480
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1480
		if _tab_0 then -- 1480
			local webIDETourCompleted -- 1480
			do -- 1480
				local _obj_0 = req.body -- 1480
				local _type_1 = type(_obj_0) -- 1480
				if "table" == _type_1 or "userdata" == _type_1 then -- 1480
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1480
				end -- 1480
			end -- 1480
			if webIDETourCompleted ~= nil then -- 1480
				config.webIDETourCompleted = webIDETourCompleted == true -- 1481
			end -- 1480
		end -- 1480
	end -- 1480
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1482
	local engineDev = Entry.getEngineDev() -- 1483
	Entry.connectWebIDE(req.body and req.body.embedded == true) -- 1484
	return { -- 1486
		platform = App.platform, -- 1486
		locale = App.locale, -- 1487
		version = App.version, -- 1488
		engineDev = engineDev, -- 1489
		webProfiler = webProfiler, -- 1490
		drawerWidth = drawerWidth, -- 1491
		webIDETourCompleted = webIDETourCompleted == true -- 1492
	} -- 1485
end) -- 1477
local ensureLLMConfigTable -- 1494
ensureLLMConfigTable = function() -- 1494
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1495
	if columns and #columns > 0 then -- 1496
		local expected = { -- 1498
			id = true, -- 1498
			name = true, -- 1499
			url = true, -- 1500
			model = true, -- 1501
			api_key = true, -- 1502
			context_window = true, -- 1503
			temperature = true, -- 1504
			max_tokens = true, -- 1505
			reasoning_effort = true, -- 1506
			custom_options = true, -- 1507
			supports_function_calling = true, -- 1508
			active = true, -- 1509
			created_at = true, -- 1510
			updated_at = true -- 1511
		} -- 1497
		local existing = { } -- 1513
		local valid = true -- 1514
		for _index_0 = 1, #columns do -- 1515
			local row = columns[_index_0] -- 1515
			local columnName = tostring(row[2]) -- 1516
			existing[columnName] = true -- 1517
			if not expected[columnName] then -- 1518
				valid = false -- 1519
				break -- 1520
			end -- 1518
		end -- 1515
		if valid then -- 1521
			if not existing.context_window then -- 1522
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1523
			end -- 1522
			if not existing.temperature then -- 1524
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1525
			end -- 1524
			if not existing.max_tokens then -- 1526
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 64000") -- 1527
			end -- 1526
			if not existing.reasoning_effort then -- 1528
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1529
			end -- 1528
			if not existing.custom_options then -- 1530
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1531
			end -- 1530
			if not existing.supports_function_calling then -- 1532
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1533
			end -- 1532
		else -- 1535
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1535
		end -- 1521
	end -- 1496
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
	]]) -- 1536
	require("Agent.Config.LLMConfigMigration").upgradeLLMConfig() -- 1555
	return require("Agent.Config.LLMConfigNames").upgradeLLMConfigNames() -- 1556
end -- 1494
local normalizeContextWindow -- 1558
normalizeContextWindow = function(value) -- 1558
	local contextWindow = tonumber(value) -- 1559
	if contextWindow == nil or contextWindow < 64000 then -- 1560
		return 64000 -- 1561
	end -- 1560
	return math.max(64000, math.floor(contextWindow)) -- 1562
end -- 1558
local normalizeTemperature -- 1564
normalizeTemperature = function(value) -- 1564
	local temperature = tonumber(value) -- 1565
	if temperature == nil then -- 1566
		return 0.1 -- 1567
	end -- 1566
	return math.max(0, math.min(2, temperature)) -- 1568
end -- 1564
local normalizeMaxTokens -- 1570
normalizeMaxTokens = function(value) -- 1570
	local maxTokens = tonumber(value) -- 1571
	if maxTokens == nil or maxTokens < 1 then -- 1572
		return 64000 -- 1573
	end -- 1572
	return math.max(1, math.floor(maxTokens)) -- 1574
end -- 1570
local normalizeReasoningEffort -- 1576
normalizeReasoningEffort = function(value) -- 1576
	if value == nil then -- 1577
		return "" -- 1578
	end -- 1577
	local effort = tostring(value) -- 1579
	return effort:match("^%s*(.-)%s*$") or "" -- 1580
end -- 1576
local normalizeCustomOptions -- 1582
normalizeCustomOptions = function(value) -- 1582
	if value == nil then -- 1583
		return "" -- 1584
	end -- 1583
	local options = tostring(value) -- 1585
	options = options:match("^%s*(.-)%s*$") or "" -- 1586
	return options -- 1587
end -- 1582
local validateCustomOptions -- 1589
validateCustomOptions = function(value) -- 1589
	local options = normalizeCustomOptions(value) -- 1590
	if options == "" then -- 1591
		return true -- 1591
	end -- 1591
	if not options:match("^%s*{") then -- 1592
		return false -- 1592
	end -- 1592
	local decoded = json.decode(options) -- 1593
	return type(decoded) == "table" -- 1594
end -- 1589
HttpServer:post("/llm/list", function() -- 1596
	ensureLLMConfigTable() -- 1597
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1598
	local items -- 1602
	if rows and #rows > 0 then -- 1602
		local _accum_0 = { } -- 1603
		local _len_0 = 1 -- 1603
		for _index_0 = 1, #rows do -- 1603
			local _des_0 = rows[_index_0] -- 1603
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1603
			_accum_0[_len_0] = { -- 1604
				id = id, -- 1604
				name = name, -- 1604
				url = url, -- 1604
				model = model, -- 1604
				key = key, -- 1604
				contextWindow = normalizeContextWindow(contextWindow), -- 1604
				temperature = normalizeTemperature(temperature), -- 1604
				maxTokens = normalizeMaxTokens(maxTokens), -- 1604
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1604
				customOptions = normalizeCustomOptions(customOptions), -- 1604
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1604
			} -- 1604
			_len_0 = _len_0 + 1 -- 1604
		end -- 1603
		items = _accum_0 -- 1602
	end -- 1602
	return { -- 1605
		success = true, -- 1605
		items = items -- 1605
	} -- 1605
end) -- 1596
HttpServer:post("/llm/create", function(req) -- 1607
	ensureLLMConfigTable() -- 1608
	do -- 1609
		local _type_0 = type(req) -- 1609
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1609
		if _tab_0 then -- 1609
			local body = req.body -- 1609
			if body ~= nil then -- 1609
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1610
				local now = os.time() -- 1611
				if name == nil or url == nil or model == nil or key == nil then -- 1612
					return invalidArguments -- 1613
				end -- 1612
				local names = require("Agent.Config.LLMConfigNames") -- 1614
				name = names.normalizeLLMConfigName(name) -- 1615
				if not name then -- 1616
					return { -- 1616
						success = false, -- 1616
						code = "INVALID_LLM_CONFIG_NAME", -- 1616
						message = "LLM configuration name must be a non-empty string" -- 1616
					} -- 1616
				end -- 1616
				local nameCheck = names.checkLLMConfigName(name) -- 1617
				if not nameCheck.success then -- 1618
					return nameCheck -- 1618
				end -- 1618
				contextWindow = normalizeContextWindow(contextWindow) -- 1619
				temperature = normalizeTemperature(temperature) -- 1620
				maxTokens = normalizeMaxTokens(maxTokens) -- 1621
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1622
				customOptions = normalizeCustomOptions(customOptions) -- 1623
				if not validateCustomOptions(customOptions) then -- 1624
					return { -- 1624
						success = false, -- 1624
						message = "customOptions must be a JSON object" -- 1624
					} -- 1624
				end -- 1624
				if supportsFunctionCalling == false then -- 1625
					supportsFunctionCalling = 0 -- 1625
				else -- 1625
					supportsFunctionCalling = 1 -- 1625
				end -- 1625
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1632
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
					1, -- 1642
					now, -- 1643
					now -- 1644
				}) -- 1626
				if affected < 0 then -- 1646
					nameCheck = names.checkLLMConfigName(name) -- 1647
					if not nameCheck.success then -- 1648
						return nameCheck -- 1648
					end -- 1648
				end -- 1646
				return { -- 1649
					success = affected > 0 -- 1649
				} -- 1649
			end -- 1609
		end -- 1609
	end -- 1609
	return invalidArguments -- 1607
end) -- 1607
HttpServer:post("/llm/update", function(req) -- 1651
	ensureLLMConfigTable() -- 1652
	do -- 1653
		local _type_0 = type(req) -- 1653
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1653
		if _tab_0 then -- 1653
			local body = req.body -- 1653
			if body ~= nil then -- 1653
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1654
				local now = os.time() -- 1655
				id = tonumber(id) -- 1656
				if id == nil or id <= 0 or id ~= math.floor(id) then -- 1657
					return invalidArguments -- 1657
				end -- 1657
				local names = require("Agent.Config.LLMConfigNames") -- 1658
				name = names.normalizeLLMConfigName(name) -- 1659
				if not name then -- 1660
					return { -- 1660
						success = false, -- 1660
						code = "INVALID_LLM_CONFIG_NAME", -- 1660
						message = "LLM configuration name must be a non-empty string" -- 1660
					} -- 1660
				end -- 1660
				local nameCheck = names.checkLLMConfigName(name, id) -- 1661
				if not nameCheck.success then -- 1662
					return nameCheck -- 1662
				end -- 1662
				contextWindow = normalizeContextWindow(contextWindow) -- 1663
				temperature = normalizeTemperature(temperature) -- 1664
				maxTokens = normalizeMaxTokens(maxTokens) -- 1665
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1666
				customOptions = normalizeCustomOptions(customOptions) -- 1667
				if not validateCustomOptions(customOptions) then -- 1668
					return { -- 1668
						success = false, -- 1668
						message = "customOptions must be a JSON object" -- 1668
					} -- 1668
				end -- 1668
				if supportsFunctionCalling == false then -- 1669
					supportsFunctionCalling = 0 -- 1669
				else -- 1669
					supportsFunctionCalling = 1 -- 1669
				end -- 1669
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1674
					tostring(name), -- 1674
					tostring(url), -- 1675
					tostring(model), -- 1676
					tostring(key), -- 1677
					contextWindow, -- 1678
					temperature, -- 1679
					maxTokens, -- 1680
					reasoningEffort, -- 1681
					customOptions, -- 1682
					supportsFunctionCalling, -- 1683
					now, -- 1684
					id -- 1685
				}) -- 1670
				if affected < 0 then -- 1687
					nameCheck = names.checkLLMConfigName(name, id) -- 1688
					if not nameCheck.success then -- 1689
						return nameCheck -- 1689
					end -- 1689
				end -- 1687
				return { -- 1690
					success = affected > 0 -- 1690
				} -- 1690
			end -- 1653
		end -- 1653
	end -- 1653
	return invalidArguments -- 1651
end) -- 1651
HttpServer:post("/llm/delete", function(req) -- 1692
	ensureLLMConfigTable() -- 1693
	do -- 1694
		local _type_0 = type(req) -- 1694
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1694
		if _tab_0 then -- 1694
			local id -- 1694
			do -- 1694
				local _obj_0 = req.body -- 1694
				local _type_1 = type(_obj_0) -- 1694
				if "table" == _type_1 or "userdata" == _type_1 then -- 1694
					id = _obj_0.id -- 1694
				end -- 1694
			end -- 1694
			if id ~= nil then -- 1694
				id = tonumber(id) -- 1695
				if id == nil then -- 1696
					return invalidArguments -- 1696
				end -- 1696
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1697
					id -- 1697
				}) -- 1697
				return { -- 1698
					success = affected >= 0 -- 1698
				} -- 1698
			end -- 1694
		end -- 1694
	end -- 1694
	return invalidArguments -- 1692
end) -- 1692
HttpServer:post("/local-agent/list", function() -- 1700
	return { -- 1701
		success = true, -- 1701
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1701
		items = AgentLocalAgent.listConfigs() -- 1701
	} -- 1701
end) -- 1700
HttpServer:post("/local-agent/save", function(req) -- 1703
	do -- 1704
		local _type_0 = type(req) -- 1704
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1704
		if _tab_0 then -- 1704
			local body = req.body -- 1704
			if body ~= nil then -- 1704
				return AgentLocalAgent.saveConfig(body) -- 1705
			end -- 1704
		end -- 1704
	end -- 1704
	return invalidArguments -- 1703
end) -- 1703
HttpServer:post("/local-agent/delete", function(req) -- 1707
	do -- 1708
		local _type_0 = type(req) -- 1708
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1708
		if _tab_0 then -- 1708
			local id -- 1708
			do -- 1708
				local _obj_0 = req.body -- 1708
				local _type_1 = type(_obj_0) -- 1708
				if "table" == _type_1 or "userdata" == _type_1 then -- 1708
					id = _obj_0.id -- 1708
				end -- 1708
			end -- 1708
			if id ~= nil then -- 1708
				return AgentLocalAgent.deleteConfig(id) -- 1709
			end -- 1708
		end -- 1708
	end -- 1708
	return invalidArguments -- 1707
end) -- 1707
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1711
	do -- 1712
		local _type_0 = type(req) -- 1712
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1712
		if _tab_0 then -- 1712
			local id -- 1712
			do -- 1712
				local _obj_0 = req.body -- 1712
				local _type_1 = type(_obj_0) -- 1712
				if "table" == _type_1 or "userdata" == _type_1 then -- 1712
					id = _obj_0.id -- 1712
				end -- 1712
			end -- 1712
			if id ~= nil then -- 1712
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1713
			end -- 1712
		end -- 1712
	end -- 1712
	return invalidArguments -- 1711
end) -- 1711
HttpServer:post("/stat", function(req) -- 1715
	do -- 1716
		local _type_0 = type(req) -- 1716
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1716
		if _tab_0 then -- 1716
			local path -- 1716
			do -- 1716
				local _obj_0 = req.body -- 1716
				local _type_1 = type(_obj_0) -- 1716
				if "table" == _type_1 or "userdata" == _type_1 then -- 1716
					path = _obj_0.path -- 1716
				end -- 1716
			end -- 1716
			if path ~= nil then -- 1716
				if not Content:exist(path) then -- 1717
					return { -- 1718
						success = false, -- 1718
						message = "target not existed" -- 1718
					} -- 1718
				end -- 1717
				if Content:isdir(path) then -- 1719
					return { -- 1720
						success = false, -- 1720
						message = "failed to stat a directory" -- 1720
					} -- 1720
				end -- 1719
				local size, isBinary = Content:getAttr(path) -- 1721
				if size then -- 1721
					return { -- 1722
						success = true, -- 1722
						size = size, -- 1722
						isBinary = isBinary -- 1722
					} -- 1722
				end -- 1721
			end -- 1716
		end -- 1716
	end -- 1716
	return { -- 1715
		success = false, -- 1715
		message = "failed to stat" -- 1715
	} -- 1715
end) -- 1715
HttpServer:post("/new", function(req) -- 1724
	do -- 1725
		local _type_0 = type(req) -- 1725
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1725
		if _tab_0 then -- 1725
			local path -- 1725
			do -- 1725
				local _obj_0 = req.body -- 1725
				local _type_1 = type(_obj_0) -- 1725
				if "table" == _type_1 or "userdata" == _type_1 then -- 1725
					path = _obj_0.path -- 1725
				end -- 1725
			end -- 1725
			local content -- 1725
			do -- 1725
				local _obj_0 = req.body -- 1725
				local _type_1 = type(_obj_0) -- 1725
				if "table" == _type_1 or "userdata" == _type_1 then -- 1725
					content = _obj_0.content -- 1725
				end -- 1725
			end -- 1725
			local folder -- 1725
			do -- 1725
				local _obj_0 = req.body -- 1725
				local _type_1 = type(_obj_0) -- 1725
				if "table" == _type_1 or "userdata" == _type_1 then -- 1725
					folder = _obj_0.folder -- 1725
				end -- 1725
			end -- 1725
			if path ~= nil and content ~= nil and folder ~= nil then -- 1725
				if Content:exist(path) then -- 1726
					return { -- 1727
						success = false, -- 1727
						message = "TargetExisted" -- 1727
					} -- 1727
				end -- 1726
				local parent = Path:getPath(path) -- 1728
				local files = Content:getFiles(parent) -- 1729
				if folder then -- 1730
					local name = Path:getFilename(path):lower() -- 1731
					for _index_0 = 1, #files do -- 1732
						local file = files[_index_0] -- 1732
						if name == Path:getFilename(file):lower() then -- 1733
							return { -- 1734
								success = false, -- 1734
								message = "TargetExisted" -- 1734
							} -- 1734
						end -- 1733
					end -- 1732
					if Content:mkdir(path) then -- 1735
						return { -- 1736
							success = true -- 1736
						} -- 1736
					end -- 1735
				else -- 1738
					local name = Path:getName(path):lower() -- 1738
					local targetExt = Path:getExt(path) -- 1739
					for _index_0 = 1, #files do -- 1740
						local file = files[_index_0] -- 1740
						if name == Path:getName(file):lower() then -- 1741
							local ext = Path:getExt(file) -- 1742
							if not ("tl" == targetExt or "yue" == targetExt or "ts" == targetExt or "tsx" == targetExt or "vs" == targetExt or "bl" == targetExt or "xml" == targetExt or "lua" == targetExt) or not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1743
								goto _continue_0 -- 1744
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1745
								goto _continue_0 -- 1746
							end -- 1743
							return { -- 1747
								success = false, -- 1747
								message = "SourceExisted" -- 1747
							} -- 1747
						end -- 1741
						::_continue_0:: -- 1741
					end -- 1740
					if Content:save(path, content) then -- 1748
						return { -- 1749
							success = true -- 1749
						} -- 1749
					end -- 1748
				end -- 1730
			end -- 1725
		end -- 1725
	end -- 1725
	return { -- 1724
		success = false, -- 1724
		message = "Failed" -- 1724
	} -- 1724
end) -- 1724
local deleteAsset -- 1751
deleteAsset = function(path) -- 1751
	if not Content:exist(path) then -- 1752
		return false -- 1752
	end -- 1752
	local projectRoot -- 1753
	if Content:isdir(path) and isProjectRootDir(path) then -- 1753
		projectRoot = path -- 1753
	else -- 1753
		projectRoot = nil -- 1753
	end -- 1753
	local parent = Path:getPath(path) -- 1754
	local files = Content:getFiles(parent) -- 1755
	local name = Path:getName(path):lower() -- 1756
	local ext = Path:getExt(path) -- 1757
	for _index_0 = 1, #files do -- 1758
		local file = files[_index_0] -- 1758
		if name == Path:getName(file):lower() then -- 1759
			local _exp_0 = Path:getExt(file) -- 1760
			if "tl" == _exp_0 then -- 1760
				if ("vs" == ext) then -- 1760
					Content:remove(Path(parent, file)) -- 1761
				end -- 1760
			elseif "lua" == _exp_0 then -- 1762
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1762
					Content:remove(Path(parent, file)) -- 1763
				end -- 1762
			end -- 1760
		end -- 1759
	end -- 1758
	if Content:remove(path) then -- 1764
		if projectRoot then -- 1765
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1766
		end -- 1765
		return true -- 1767
	end -- 1764
	return false -- 1768
end -- 1751
local moveAsset -- 1770
moveAsset = function(old, new) -- 1770
	if not (Content:exist(old) and not Content:exist(new)) then -- 1771
		return false -- 1771
	end -- 1771
	local renamedDir = Content:isdir(old) -- 1772
	local parent = Path:getPath(new) -- 1773
	local files = Content:getFiles(parent) -- 1774
	if renamedDir then -- 1775
		local name = Path:getFilename(new):lower() -- 1776
		for _index_0 = 1, #files do -- 1777
			local file = files[_index_0] -- 1777
			if name == Path:getFilename(file):lower() then -- 1778
				return false -- 1779
			end -- 1778
		end -- 1777
	else -- 1781
		local name = Path:getName(new):lower() -- 1781
		local ext = Path:getExt(new) -- 1782
		for _index_0 = 1, #files do -- 1783
			local file = files[_index_0] -- 1783
			if name == Path:getName(file):lower() then -- 1784
				local fileExt = Path:getExt(file) -- 1785
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) or not ("tl" == fileExt or "yue" == fileExt or "ts" == fileExt or "tsx" == fileExt or "vs" == fileExt or "bl" == fileExt or "xml" == fileExt or "lua" == fileExt) then -- 1786
					goto _continue_0 -- 1787
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1788
					goto _continue_0 -- 1789
				end -- 1786
				return false -- 1790
			end -- 1784
			::_continue_0:: -- 1784
		end -- 1783
	end -- 1775
	if not Content:move(old, new) then -- 1791
		return false -- 1791
	end -- 1791
	if renamedDir then -- 1792
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1793
	end -- 1792
	local newParent = Path:getPath(new) -- 1794
	parent = Path:getPath(old) -- 1795
	files = Content:getFiles(parent) -- 1796
	local newName = Path:getName(new) -- 1797
	local oldName = Path:getName(old) -- 1798
	local name = oldName:lower() -- 1799
	local ext = Path:getExt(old) -- 1800
	for _index_0 = 1, #files do -- 1801
		local file = files[_index_0] -- 1801
		if name == Path:getName(file):lower() then -- 1802
			local _exp_0 = Path:getExt(file) -- 1803
			if "tl" == _exp_0 then -- 1803
				if ("vs" == ext) then -- 1803
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1804
				end -- 1803
			elseif "lua" == _exp_0 then -- 1805
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1805
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1806
				end -- 1805
			end -- 1803
		end -- 1802
	end -- 1801
	return true -- 1807
end -- 1770
HttpServer:post("/delete", function(req) -- 1809
	do -- 1810
		local _type_0 = type(req) -- 1810
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1810
		if _tab_0 then -- 1810
			local path -- 1810
			do -- 1810
				local _obj_0 = req.body -- 1810
				local _type_1 = type(_obj_0) -- 1810
				if "table" == _type_1 or "userdata" == _type_1 then -- 1810
					path = _obj_0.path -- 1810
				end -- 1810
			end -- 1810
			if path ~= nil then -- 1810
				if deleteAsset(path) then -- 1811
					return { -- 1811
						success = true -- 1811
					} -- 1811
				end -- 1811
			end -- 1810
		end -- 1810
	end -- 1810
	return { -- 1809
		success = false -- 1809
	} -- 1809
end) -- 1809
HttpServer:post("/rename", function(req) -- 1813
	do -- 1814
		local _type_0 = type(req) -- 1814
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1814
		if _tab_0 then -- 1814
			local old -- 1814
			do -- 1814
				local _obj_0 = req.body -- 1814
				local _type_1 = type(_obj_0) -- 1814
				if "table" == _type_1 or "userdata" == _type_1 then -- 1814
					old = _obj_0.old -- 1814
				end -- 1814
			end -- 1814
			local new -- 1814
			do -- 1814
				local _obj_0 = req.body -- 1814
				local _type_1 = type(_obj_0) -- 1814
				if "table" == _type_1 or "userdata" == _type_1 then -- 1814
					new = _obj_0.new -- 1814
				end -- 1814
			end -- 1814
			if old ~= nil and new ~= nil then -- 1814
				if moveAsset(old, new) then -- 1815
					return { -- 1815
						success = true -- 1815
					} -- 1815
				end -- 1815
			end -- 1814
		end -- 1814
	end -- 1814
	return { -- 1813
		success = false -- 1813
	} -- 1813
end) -- 1813
local normalizeAssetPaths -- 1817
normalizeAssetPaths = function(paths) -- 1817
	if not (type(paths) == "table") then -- 1818
		return nil -- 1818
	end -- 1818
	local unique = { } -- 1819
	local candidates = { } -- 1820
	for _index_0 = 1, #paths do -- 1821
		local path = paths[_index_0] -- 1821
		if not (type(path) == "string") then -- 1822
			return nil -- 1822
		end -- 1822
		local relative = relativeToRoot(path, Content.writablePath) -- 1823
		if relative == nil or relative == "" or not Content:exist(path) then -- 1824
			return nil -- 1824
		end -- 1824
		if not unique[path] then -- 1825
			unique[path] = true -- 1826
			candidates[#candidates + 1] = path -- 1827
		end -- 1825
	end -- 1821
	table.sort(candidates, function(a, b) -- 1828
		return #a < #b -- 1828
	end) -- 1828
	local result = { } -- 1829
	for _index_0 = 1, #candidates do -- 1830
		local path = candidates[_index_0] -- 1830
		local contained = false -- 1831
		for _index_1 = 1, #result do -- 1832
			local parent = result[_index_1] -- 1832
			if relativeToRoot(path, parent) ~= nil then -- 1833
				contained = true -- 1834
				break -- 1835
			end -- 1833
		end -- 1832
		if not contained then -- 1836
			result[#result + 1] = path -- 1836
		end -- 1836
	end -- 1830
	return result -- 1837
end -- 1817
HttpServer:postSchedule("/assets/batch", function(req) -- 1839
	do -- 1840
		local _type_0 = type(req) -- 1840
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1840
		if _tab_0 then -- 1840
			local operation -- 1840
			do -- 1840
				local _obj_0 = req.body -- 1840
				local _type_1 = type(_obj_0) -- 1840
				if "table" == _type_1 or "userdata" == _type_1 then -- 1840
					operation = _obj_0.operation -- 1840
				end -- 1840
			end -- 1840
			local sources -- 1840
			do -- 1840
				local _obj_0 = req.body -- 1840
				local _type_1 = type(_obj_0) -- 1840
				if "table" == _type_1 or "userdata" == _type_1 then -- 1840
					sources = _obj_0.sources -- 1840
				end -- 1840
			end -- 1840
			if operation ~= nil and sources ~= nil then -- 1840
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1841
					return { -- 1841
						success = false, -- 1841
						message = "invalid operation" -- 1841
					} -- 1841
				end -- 1841
				sources = normalizeAssetPaths(sources) -- 1842
				if not (sources and #sources > 0) then -- 1843
					return { -- 1843
						success = false, -- 1843
						message = "invalid sources" -- 1843
					} -- 1843
				end -- 1843
				local target = req.body.target -- 1844
				local destinations = { } -- 1845
				if operation ~= "delete" then -- 1846
					if not (type(target) == "string") then -- 1847
						return { -- 1847
							success = false, -- 1847
							message = "invalid target" -- 1847
						} -- 1847
					end -- 1847
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1848
					if targetRelative == nil then -- 1849
						return { -- 1849
							success = false, -- 1849
							message = "invalid target" -- 1849
						} -- 1849
					end -- 1849
					if not (Content:exist(target) and Content:isdir(target)) then -- 1850
						return { -- 1850
							success = false, -- 1850
							message = "invalid target" -- 1850
						} -- 1850
					end -- 1850
					for _index_0 = 1, #sources do -- 1851
						local source = sources[_index_0] -- 1851
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1852
							return { -- 1853
								success = false, -- 1853
								message = "target inside source" -- 1853
							} -- 1853
						end -- 1852
						local destination = Path(target, Path:getFilename(source)) -- 1854
						if Content:exist(destination) then -- 1855
							return { -- 1855
								success = false, -- 1855
								message = "target existed" -- 1855
							} -- 1855
						end -- 1855
						if destinations[destination] then -- 1856
							return { -- 1856
								success = false, -- 1856
								message = "duplicate target" -- 1856
							} -- 1856
						end -- 1856
						destinations[destination] = true -- 1857
					end -- 1851
				end -- 1846
				local changes = { } -- 1858
				local affectedSet = { } -- 1859
				local affectedDirectories = { } -- 1860
				local addAffected -- 1861
				addAffected = function(dir) -- 1861
					if affectedSet[dir] then -- 1862
						return -- 1862
					end -- 1862
					affectedSet[dir] = true -- 1863
					affectedDirectories[#affectedDirectories + 1] = dir -- 1864
				end -- 1861
				if operation ~= "delete" then -- 1865
					addAffected(target) -- 1865
				end -- 1865
				for _index_0 = 1, #sources do -- 1866
					local source = sources[_index_0] -- 1866
					addAffected(Path:getPath(source)) -- 1867
					if operation == "delete" then -- 1868
						if not deleteAsset(source) then -- 1869
							return { -- 1869
								success = false, -- 1869
								message = "delete failed", -- 1869
								changes = changes, -- 1869
								affectedDirectories = affectedDirectories -- 1869
							} -- 1869
						end -- 1869
						changes[#changes + 1] = { -- 1870
							old = source -- 1870
						} -- 1870
					else -- 1872
						local destination = Path(target, Path:getFilename(source)) -- 1872
						local ok -- 1873
						if operation == "copy" then -- 1873
							ok = Content:copyAsync(source, destination) -- 1874
						else -- 1876
							ok = moveAsset(source, destination) -- 1876
						end -- 1873
						if not ok then -- 1877
							return { -- 1877
								success = false, -- 1877
								message = operation .. " failed", -- 1877
								changes = changes, -- 1877
								affectedDirectories = affectedDirectories -- 1877
							} -- 1877
						end -- 1877
						changes[#changes + 1] = { -- 1878
							old = source, -- 1878
							new = destination -- 1878
						} -- 1878
					end -- 1868
				end -- 1866
				return { -- 1879
					success = true, -- 1879
					changes = changes, -- 1879
					affectedDirectories = affectedDirectories -- 1879
				} -- 1879
			end -- 1840
		end -- 1840
	end -- 1840
	return { -- 1839
		success = false, -- 1839
		message = "invalid request" -- 1839
	} -- 1839
end) -- 1839
local withProjectSearchPaths -- 1881
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1881
	local fallbackPaths = { } -- 1882
	local addFallback -- 1883
	addFallback = function(dir) -- 1883
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1883
			fallbackPaths[#fallbackPaths + 1] = dir -- 1883
		end -- 1883
	end -- 1883
	if projectRoot and projectRoot ~= "" then -- 1884
		addFallback(Path(projectRoot, "Script")) -- 1885
		addFallback(projectRoot) -- 1886
	end -- 1884
	if projFile then -- 1887
		local projDir = getProjectDirFromFile(projFile) -- 1888
		if projDir then -- 1888
			addFallback(Path(projDir, "Script")) -- 1889
			addFallback(projDir) -- 1890
		else -- 1892
			addFallback(Path:getPath(projFile)) -- 1892
		end -- 1888
	end -- 1887
	if not (#fallbackPaths > 0) then -- 1893
		return fn() -- 1893
	end -- 1893
	local searchPaths = Content.searchPaths -- 1894
	for _index_0 = 1, #fallbackPaths do -- 1895
		local dir = fallbackPaths[_index_0] -- 1895
		Content:addSearchPath(dir) -- 1895
	end -- 1895
	local _ <close> = setmetatable({ }, { -- 1896
		__close = function() -- 1896
			Content.searchPaths = searchPaths -- 1896
		end -- 1896
	}) -- 1896
	return fn() -- 1897
end -- 1881
HttpServer:post("/exist", function(req) -- 1898
	do -- 1899
		local _type_0 = type(req) -- 1899
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1899
		if _tab_0 then -- 1899
			local file -- 1899
			do -- 1899
				local _obj_0 = req.body -- 1899
				local _type_1 = type(_obj_0) -- 1899
				if "table" == _type_1 or "userdata" == _type_1 then -- 1899
					file = _obj_0.file -- 1899
				end -- 1899
			end -- 1899
			if file ~= nil then -- 1899
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1900
					return { -- 1901
						success = Content:exist(file) -- 1901
					} -- 1901
				end) -- 1900
			end -- 1899
		end -- 1899
	end -- 1899
	return { -- 1898
		success = false -- 1898
	} -- 1898
end) -- 1898
HttpServer:postSchedule("/read", function(req) -- 1902
	do -- 1903
		local _type_0 = type(req) -- 1903
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1903
		if _tab_0 then -- 1903
			local path -- 1903
			do -- 1903
				local _obj_0 = req.body -- 1903
				local _type_1 = type(_obj_0) -- 1903
				if "table" == _type_1 or "userdata" == _type_1 then -- 1903
					path = _obj_0.path -- 1903
				end -- 1903
			end -- 1903
			if path ~= nil then -- 1903
				local readFile -- 1904
				readFile = function() -- 1904
					if Content:exist(path) and not Content:isdir(path) then -- 1905
						local content = Content:loadAsync(path) -- 1906
						if content then -- 1906
							return { -- 1907
								content = content, -- 1907
								success = true, -- 1907
								fullPath = Content:getFullPath(path) -- 1907
							} -- 1907
						end -- 1906
					end -- 1905
					return nil -- 1904
				end -- 1904
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1908
				if result then -- 1908
					return result -- 1908
				end -- 1908
			end -- 1903
		end -- 1903
	end -- 1903
	return { -- 1902
		success = false -- 1902
	} -- 1902
end) -- 1902
local agentDocLanguage -- 1910
agentDocLanguage = function(language) -- 1910
	if language == "zh-Hans" then -- 1911
		return "zh" -- 1911
	else -- 1911
		return "en" -- 1911
	end -- 1911
end -- 1910
HttpServer:postSchedule("/doc/search", function(req) -- 1913
	local body = req.body or { } -- 1914
	local language = body.docLanguage -- 1915
	if not (("en" == language or "zh-Hans" == language)) then -- 1916
		return { -- 1916
			success = false, -- 1916
			message = "unsupported doc language" -- 1916
		} -- 1916
	end -- 1916
	local docType = body.docType -- 1917
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1918
		return { -- 1918
			success = false, -- 1918
			message = "unsupported doc type" -- 1918
		} -- 1918
	end -- 1918
	local codeLanguage = body.programmingLanguage -- 1919
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1920
		return { -- 1920
			success = false, -- 1920
			message = "unsupported programming language" -- 1920
		} -- 1920
	end -- 1920
	if not body.pattern then -- 1921
		return { -- 1921
			success = false, -- 1921
			message = "missing pattern" -- 1921
		} -- 1921
	end -- 1921
	local result = nil -- 1922
	AgentTools.searchDoraDocHttp({ -- 1924
		pattern = body.pattern, -- 1924
		docLanguage = agentDocLanguage(language), -- 1925
		docType = docType, -- 1926
		programmingLanguage = codeLanguage, -- 1927
		limit = body.limit, -- 1928
		useRegex = body.useRegex, -- 1929
		caseSensitive = body.caseSensitive, -- 1930
		includeContent = body.includeContent, -- 1931
		contentWindow = body.contentWindow -- 1932
	}, function(res) -- 1933
		result = res -- 1934
	end) -- 1923
	wait(function() -- 1935
		return result ~= nil -- 1935
	end) -- 1935
	if result and result.success then -- 1936
		result.docLanguage = language -- 1937
	end -- 1936
	if result then -- 1938
		return result -- 1939
	else -- 1941
		return { -- 1941
			success = false, -- 1941
			message = "doc search failed" -- 1941
		} -- 1941
	end -- 1938
	return { -- 1913
		success = false, -- 1913
		message = "invalid call" -- 1913
	} -- 1913
end) -- 1913
HttpServer:postSchedule("/doc/read", function(req) -- 1943
	local body = req.body or { } -- 1944
	local language = body.docLanguage -- 1945
	if not (("en" == language or "zh-Hans" == language)) then -- 1946
		return { -- 1946
			success = false, -- 1946
			message = "unsupported doc language" -- 1946
		} -- 1946
	end -- 1946
	if not body.file then -- 1947
		return { -- 1947
			success = false, -- 1947
			message = "missing file" -- 1947
		} -- 1947
	end -- 1947
	local result = AgentTools.readDoraDoc({ -- 1949
		docLanguage = agentDocLanguage(language), -- 1949
		file = body.file, -- 1950
		startLine = body.startLine, -- 1951
		endLine = body.endLine -- 1952
	}) -- 1948
	if result and result.success then -- 1953
		result.docLanguage = language -- 1954
	end -- 1953
	return result -- 1955
end) -- 1943
local readSyncFile -- 1957
readSyncFile = function(req) -- 1957
	do -- 1958
		local _type_0 = type(req) -- 1958
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1958
		if _tab_0 then -- 1958
			local params = req.params -- 1958
			if params ~= nil then -- 1958
				local path = params.path -- 1959
				if not (type(path) == "string" and path ~= "") then -- 1960
					return { -- 1960
						success = false, -- 1960
						message = "invalid path" -- 1960
					} -- 1960
				end -- 1960
				local exts -- 1961
				if params.exts then -- 1961
					local _accum_0 = { } -- 1962
					local _len_0 = 1 -- 1962
					for ext in params.exts:gmatch("[^|]*") do -- 1962
						_accum_0[_len_0] = ext -- 1962
						_len_0 = _len_0 + 1 -- 1962
					end -- 1962
					exts = _accum_0 -- 1962
				else -- 1963
					exts = { -- 1963
						"" -- 1963
					} -- 1963
				end -- 1961
				local readFileAt -- 1964
				readFileAt = function(targetPath) -- 1964
					if Content:exist(targetPath) then -- 1965
						local content = Content:load(targetPath) -- 1966
						if content then -- 1966
							return { -- 1967
								content = content, -- 1967
								success = true, -- 1967
								fullPath = Content:getFullPath(targetPath) -- 1967
							} -- 1967
						end -- 1966
					end -- 1965
					return nil -- 1964
				end -- 1964
				local readFile -- 1968
				readFile = function(fallbackPaths) -- 1968
					for _index_0 = 1, #exts do -- 1969
						local ext = exts[_index_0] -- 1969
						local targetPath = path .. ext -- 1970
						if not Content:isAbsolutePath(targetPath) then -- 1971
							for _index_1 = 1, #fallbackPaths do -- 1972
								local fallback = fallbackPaths[_index_1] -- 1972
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1973
								if fallbackResult then -- 1973
									return fallbackResult -- 1974
								end -- 1973
							end -- 1972
						end -- 1971
						local fileResult = readFileAt(targetPath) -- 1975
						if fileResult then -- 1975
							return fileResult -- 1976
						end -- 1975
					end -- 1969
					return nil -- 1968
				end -- 1968
				local fallbackPaths = { } -- 1977
				local fallbackCandidates = { } -- 1978
				do -- 1979
					local projectRoot = req.params.projectRoot -- 1979
					if projectRoot then -- 1979
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1980
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1981
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1982
						end -- 1980
					end -- 1979
				end -- 1979
				do -- 1983
					local projFile = req.params.projFile -- 1983
					if projFile then -- 1983
						local projDir = getProjectDirFromFile(projFile) -- 1984
						if projDir then -- 1984
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1985
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1986
						else -- 1988
							projDir = Path:getPath(projFile) -- 1988
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1989
						end -- 1984
					end -- 1983
				end -- 1983
				for _index_0 = 1, #fallbackCandidates do -- 1990
					local dir = fallbackCandidates[_index_0] -- 1990
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1991
						local exists = false -- 1992
						for _index_1 = 1, #fallbackPaths do -- 1993
							local fallback = fallbackPaths[_index_1] -- 1993
							if fallback == dir then -- 1994
								exists = true -- 1995
								break -- 1996
							end -- 1994
						end -- 1993
						if not exists then -- 1997
							fallbackPaths[#fallbackPaths + 1] = dir -- 1997
						end -- 1997
					end -- 1991
				end -- 1990
				local readResult = readFile(fallbackPaths) -- 1998
				if readResult then -- 1998
					return readResult -- 1999
				end -- 1998
			end -- 1958
		end -- 1958
	end -- 1958
	return { -- 1957
		success = false -- 1957
	} -- 1957
end -- 1957
HttpServer:get("/read-sync", readSyncFile) -- 2001
HttpServer:post("/read-sync", function(req) -- 2002
	return readSyncFile({ -- 2002
		params = req.body -- 2002
	}) -- 2002
end) -- 2002
local addGeneratedSourceHeader -- 2004
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 2004
	if preserveTIC80 == nil then -- 2004
		preserveTIC80 = false -- 2004
	end -- 2004
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 2005
	if preserveTIC80 then -- 2006
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 2007
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 2008
		end -- 2007
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 2009
	end -- 2006
	return tostring(header) .. "\n" .. tostring(codes) -- 2010
end -- 2004
local compileFileAsync -- 2012
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 2012
	if projectRoot == nil then -- 2012
		projectRoot = nil -- 2012
	end -- 2012
	local file = inputFile -- 2013
	local searchPath -- 2014
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2014
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 2015
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 2019
	elseif not Content:isAbsolutePath(inputFile) then -- 2020
		searchPath = "" -- 2021
	else -- 2022
		local dir = getProjectDirFromFile(inputFile) -- 2022
		if dir then -- 2022
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2023
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 2027
		else -- 2029
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2029
			searchPath = "" -- 2032
		end -- 2022
	end -- 2014
	local outputFile = Path:replaceExt(inputFile, "lua") -- 2033
	local yueext = yue.options.extension -- 2034
	local resultCodes = nil -- 2035
	local resultError = nil -- 2036
	do -- 2037
		local _exp_0 = Path:getExt(inputFile) -- 2037
		if yueext == _exp_0 then -- 2037
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 2038
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 2039
				if not codes then -- 2040
					resultError = err -- 2041
					return -- 2042
				end -- 2040
				local extraGlobal -- 2043
				if isTIC80 then -- 2043
					extraGlobal = tic80APIs -- 2043
				else -- 2043
					extraGlobal = nil -- 2043
				end -- 2043
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 2044
				if not success then -- 2045
					resultError = message -- 2046
					return -- 2047
				end -- 2045
				if codes == "" then -- 2048
					resultCodes = "" -- 2049
					return nil -- 2050
				end -- 2048
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 2051
				return resultCodes -- 2052
			end, function(success) -- 2039
				if not success then -- 2053
					Content:remove(outputFile) -- 2054
					if resultCodes == nil then -- 2055
						resultCodes = false -- 2056
					end -- 2055
				end -- 2053
			end) -- 2039
		elseif "tl" == _exp_0 then -- 2057
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 2058
			if isTIC80 then -- 2059
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2060
			end -- 2059
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2061
			if codes then -- 2061
				if isTIC80 then -- 2062
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2063
				end -- 2062
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2064
				Content:saveAsync(outputFile, resultCodes) -- 2065
			else -- 2067
				Content:remove(outputFile) -- 2067
				resultCodes = false -- 2068
				resultError = err -- 2069
			end -- 2061
		elseif "xml" == _exp_0 then -- 2070
			local codes, err = xml.tolua(sourceCodes) -- 2071
			if codes then -- 2071
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2072
				Content:saveAsync(outputFile, resultCodes) -- 2073
			else -- 2075
				Content:remove(outputFile) -- 2075
				resultCodes = false -- 2076
				resultError = err -- 2077
			end -- 2071
		end -- 2037
	end -- 2037
	wait(function() -- 2078
		return resultCodes ~= nil -- 2078
	end) -- 2078
	if resultCodes then -- 2079
		return resultCodes -- 2080
	else -- 2082
		return nil, resultError -- 2082
	end -- 2079
	return nil -- 2012
end -- 2012
HttpServer:postSchedule("/write", function(req) -- 2084
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2085
	local buildSucceeded = false -- 2086
	local _ <close> = setmetatable({ }, { -- 2087
		__close = function() -- 2087
			return finishUpdate(buildSucceeded) -- 2087
		end -- 2087
	}) -- 2087
	do -- 2088
		local _type_0 = type(req) -- 2088
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2088
		if _tab_0 then -- 2088
			local path -- 2088
			do -- 2088
				local _obj_0 = req.body -- 2088
				local _type_1 = type(_obj_0) -- 2088
				if "table" == _type_1 or "userdata" == _type_1 then -- 2088
					path = _obj_0.path -- 2088
				end -- 2088
			end -- 2088
			local content -- 2088
			do -- 2088
				local _obj_0 = req.body -- 2088
				local _type_1 = type(_obj_0) -- 2088
				if "table" == _type_1 or "userdata" == _type_1 then -- 2088
					content = _obj_0.content -- 2088
				end -- 2088
			end -- 2088
			if path ~= nil and content ~= nil then -- 2088
				if Content:saveAsync(path, content) then -- 2089
					do -- 2090
						local _exp_0 = Path:getExt(path) -- 2090
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2090
							if '' == Path:getExt(Path:getName(path)) then -- 2091
								local resultCodes = compileFileAsync(path, content) -- 2092
								buildSucceeded = resultCodes ~= nil -- 2093
								return { -- 2094
									success = true, -- 2094
									resultCodes = resultCodes -- 2094
								} -- 2094
							end -- 2091
						end -- 2090
					end -- 2090
					buildSucceeded = true -- 2095
					return { -- 2096
						success = true -- 2096
					} -- 2096
				end -- 2089
			end -- 2088
		end -- 2088
	end -- 2088
	return { -- 2084
		success = false -- 2084
	} -- 2084
end) -- 2084
local getWaProjectDirFromFile = nil -- 2098
HttpServer:postSchedule("/build", function(req) -- 2100
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2101
	local buildSucceeded = false -- 2102
	local _ <close> = setmetatable({ }, { -- 2103
		__close = function() -- 2103
			return finishUpdate(buildSucceeded) -- 2103
		end -- 2103
	}) -- 2103
	do -- 2104
		local _type_0 = type(req) -- 2104
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2104
		if _tab_0 then -- 2104
			local path -- 2104
			do -- 2104
				local _obj_0 = req.body -- 2104
				local _type_1 = type(_obj_0) -- 2104
				if "table" == _type_1 or "userdata" == _type_1 then -- 2104
					path = _obj_0.path -- 2104
				end -- 2104
			end -- 2104
			if path ~= nil then -- 2104
				local projectRoot = req.body.projectRoot -- 2105
				if Content:isdir(path) then -- 2106
					local projDir = getWaProjectDirFromFile(path) -- 2107
					if projDir then -- 2107
						local message = Wasm:buildWaAsync(projDir) -- 2108
						if message == "" then -- 2109
							return { -- 2110
								success = true -- 2110
							} -- 2110
						else -- 2112
							return { -- 2112
								success = false, -- 2112
								message = message -- 2112
							} -- 2112
						end -- 2109
					end -- 2107
				end -- 2106
				local _exp_0 = Path:getExt(path) -- 2113
				if "gd" == _exp_0 or "tscn" == _exp_0 or "tres" == _exp_0 or "gdshader" == _exp_0 or "gdshaderinc" == _exp_0 then -- 2114
					local content = Content:loadAsync(path) -- 2115
					if content then -- 2115
						local result = godotCheckAsync(path, content, false) -- 2116
						buildSucceeded = result.success and not result.skipped -- 2117
						return { -- 2118
							success = buildSucceeded, -- 2118
							resultCodes = "", -- 2118
							info = result.info -- 2118
						} -- 2118
					end -- 2115
				elseif "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2119
					if '' == Path:getExt(Path:getName(path)) then -- 2120
						local content = Content:loadAsync(path) -- 2121
						if content then -- 2121
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2122
							if resultCodes then -- 2122
								buildSucceeded = true -- 2123
								return { -- 2124
									success = true, -- 2124
									resultCodes = resultCodes -- 2124
								} -- 2124
							end -- 2122
						end -- 2121
					end -- 2120
				elseif "wa" == _exp_0 then -- 2125
					local projDir = getWaProjectDirFromFile(path) -- 2126
					if projDir then -- 2126
						local message = Wasm:buildWaAsync(projDir) -- 2127
						if message == "" then -- 2128
							return { -- 2129
								success = true -- 2129
							} -- 2129
						else -- 2131
							return { -- 2131
								success = false, -- 2131
								message = message -- 2131
							} -- 2131
						end -- 2128
					else -- 2133
						return { -- 2133
							success = false, -- 2133
							message = 'Wa file needs a project' -- 2133
						} -- 2133
					end -- 2126
				end -- 2113
			end -- 2104
		end -- 2104
	end -- 2104
	return { -- 2100
		success = false -- 2100
	} -- 2100
end) -- 2100
local extentionLevels = { -- 2136
	vs = 2, -- 2136
	bl = 2, -- 2137
	ts = 1, -- 2138
	tsx = 1, -- 2139
	tl = 1, -- 2140
	yue = 1, -- 2141
	xml = 1, -- 2142
	lua = 0 -- 2143
} -- 2135
local visitAssets -- 2145
visitAssets = function(path, workspace, builtin, recursive) -- 2145
	if recursive == nil then -- 2145
		recursive = true -- 2145
	end -- 2145
	local children = nil -- 2146
	local dirs = Content:getDirs(path) -- 2147
	for _index_0 = 1, #dirs do -- 2148
		local dir = dirs[_index_0] -- 2148
		if workspace then -- 2149
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or ".godot" == dir or "node_modules" == dir) then -- 2150
				goto _continue_0 -- 2151
			end -- 2150
		elseif dir == ".git" or dir == ".godot" then -- 2152
			goto _continue_0 -- 2153
		end -- 2149
		if not children then -- 2154
			children = { } -- 2154
		end -- 2154
		local dirPath = Path(path, dir) -- 2155
		if recursive then -- 2156
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2157
		else -- 2159
			children[#children + 1] = { -- 2160
				key = dirPath, -- 2160
				dir = true, -- 2161
				title = dir, -- 2162
				builtin = builtin, -- 2163
				isLeaf = false -- 2164
			} -- 2159
		end -- 2156
		::_continue_0:: -- 2149
	end -- 2148
	local files = Content:getFiles(path) -- 2166
	local names = { } -- 2167
	for _index_0 = 1, #files do -- 2168
		local file = files[_index_0] -- 2168
		if (".DS_Store" == file) then -- 2169
			goto _continue_1 -- 2170
		end -- 2169
		local ext = Path:getExt(file) -- 2171
		if not extentionLevels[ext] then -- 2172
			names[file] = "" -- 2173
			goto _continue_1 -- 2174
		end -- 2172
		local name = Path:getName(file) -- 2175
		ext = names[name] -- 2176
		if ext then -- 2176
			local lv1 -- 2177
			do -- 2177
				local _exp_0 = extentionLevels[ext] -- 2177
				if _exp_0 ~= nil then -- 2177
					lv1 = _exp_0 -- 2177
				else -- 2177
					lv1 = -1 -- 2177
				end -- 2177
			end -- 2177
			ext = Path:getExt(file) -- 2178
			local lv2 -- 2179
			do -- 2179
				local _exp_0 = extentionLevels[ext] -- 2179
				if _exp_0 ~= nil then -- 2179
					lv2 = _exp_0 -- 2179
				else -- 2179
					lv2 = -1 -- 2179
				end -- 2179
			end -- 2179
			if lv2 > lv1 then -- 2180
				names[name] = ext -- 2181
			elseif lv2 == lv1 then -- 2182
				names[name .. '.' .. ext] = "" -- 2183
			end -- 2180
		else -- 2185
			ext = Path:getExt(file) -- 2185
			if not extentionLevels[ext] then -- 2186
				names[file] = "" -- 2187
			else -- 2189
				names[name] = ext -- 2189
			end -- 2186
		end -- 2176
		::_continue_1:: -- 2169
	end -- 2168
	do -- 2190
		local _accum_0 = { } -- 2190
		local _len_0 = 1 -- 2190
		for name, ext in pairs(names) do -- 2190
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2190
			_len_0 = _len_0 + 1 -- 2190
		end -- 2190
		files = _accum_0 -- 2190
	end -- 2190
	for _index_0 = 1, #files do -- 2191
		local file = files[_index_0] -- 2191
		if not children then -- 2192
			children = { } -- 2192
		end -- 2192
		children[#children + 1] = { -- 2194
			key = Path(path, file), -- 2194
			dir = false, -- 2195
			title = file, -- 2196
			builtin = builtin -- 2197
		} -- 2193
	end -- 2191
	if children then -- 2199
		table.sort(children, function(a, b) -- 2200
			if a.dir == b.dir then -- 2201
				return a.title < b.title -- 2202
			else -- 2204
				return a.dir -- 2204
			end -- 2201
		end) -- 2200
	end -- 2199
	return { -- 2206
		key = path, -- 2206
		dir = true, -- 2207
		title = Path:getFilename(path), -- 2208
		builtin = builtin, -- 2209
		isLeaf = not children, -- 2210
		children = children -- 2211
	} -- 2205
end -- 2145
HttpServer:post("/assets/children", function(req) -- 2214
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
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2216
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2217
					return { -- 2217
						success = false -- 2217
					} -- 2217
				end -- 2217
				local node = visitAssets(path, workspace, builtin, false) -- 2218
				return { -- 2219
					success = true, -- 2219
					children = node.children or { } -- 2219
				} -- 2219
			end -- 2215
		end -- 2215
	end -- 2215
	return { -- 2214
		success = false -- 2214
	} -- 2214
end) -- 2214
HttpServer:post("/assets/files", function(req) -- 2221
	do -- 2222
		local _type_0 = type(req) -- 2222
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2222
		if _tab_0 then -- 2222
			local path -- 2222
			do -- 2222
				local _obj_0 = req.body -- 2222
				local _type_1 = type(_obj_0) -- 2222
				if "table" == _type_1 or "userdata" == _type_1 then -- 2222
					path = _obj_0.path -- 2222
				end -- 2222
			end -- 2222
			if path ~= nil then -- 2222
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2223
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2224
				if not (workspace or builtin) then -- 2225
					return { -- 2225
						success = false -- 2225
					} -- 2225
				end -- 2225
				if not (Content:exist(path) and Content:isdir(path)) then -- 2226
					return { -- 2226
						success = false -- 2226
					} -- 2226
				end -- 2226
				local globs = { -- 2227
					"**", -- 2227
					"!**/.DS_Store", -- 2227
					"!**/.godot/**" -- 2227
				} -- 2227
				if workspace then -- 2228
					globs = { -- 2230
						"**", -- 2230
						"!**/.DS_Store", -- 2230
						"!**/.upload/**", -- 2231
						"!**/.download/**", -- 2231
						"!**/.www/**", -- 2232
						"!**/.build/**", -- 2232
						"!**/.git/**", -- 2233
						"!**/.cache/**", -- 2233
						"!**/.godot/**", -- 2234
						"!**/node_modules/**" -- 2235
					} -- 2229
				end -- 2228
				local files -- 2237
				do -- 2237
					local _accum_0 = { } -- 2237
					local _len_0 = 1 -- 2237
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2237
					for _index_0 = 1, #_list_0 do -- 2237
						local file = _list_0[_index_0] -- 2237
						_accum_0[_len_0] = Path(path, file) -- 2237
						_len_0 = _len_0 + 1 -- 2237
					end -- 2237
					files = _accum_0 -- 2237
				end -- 2237
				return { -- 2238
					success = true, -- 2238
					files = files -- 2238
				} -- 2238
			end -- 2222
		end -- 2222
	end -- 2222
	return { -- 2221
		success = false -- 2221
	} -- 2221
end) -- 2221
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2279
	local _tab_0 = { -- 2279
		{ -- 2280
			key = Path(Content.assetPath), -- 2280
			dir = true, -- 2281
			builtin = true, -- 2282
			title = zh and "内置资源" or "Built-in", -- 2283
			children = builtinChildren -- 2284
		} -- 2279
	} -- 2286
	local _obj_0 = workspace.children or { } -- 2286
	local _idx_0 = #_tab_0 + 1 -- 2286
	for _index_0 = 1, #_obj_0 do -- 2286
		local _value_0 = _obj_0[_index_0] -- 2286
		_tab_0[_idx_0] = _value_0 -- 2286
		_idx_0 = _idx_0 + 1 -- 2286
	end -- 2286
	return _tab_0 -- 2279
end -- 2279
HttpServer:post("/assets", function() -- 2240
	local Entry = require("Script.Dev.Entry") -- 2241
	local engineDev = Entry.getEngineDev() -- 2242
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2243
	local zh = (App.locale:match("^zh") ~= nil) -- 2244
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2245
	readme.title = zh and "说明文档" or "Readme" -- 2246
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2247
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2248
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2249
	tools.title = zh and "开发工具" or "Tools" -- 2250
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2251
	font.title = zh and "字体" or "Font" -- 2252
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2253
	lib.title = zh and "程序库" or "Lib" -- 2254
	if engineDev then -- 2255
		local _list_0 = lib.children -- 2256
		for _index_0 = 1, #_list_0 do -- 2256
			local child = _list_0[_index_0] -- 2256
			if not (child.title == "Dora") then -- 2257
				goto _continue_0 -- 2257
			end -- 2257
			local title = zh and "zh-Hans" or "en" -- 2258
			do -- 2259
				local _accum_0 = { } -- 2259
				local _len_0 = 1 -- 2259
				local _list_1 = child.children -- 2259
				for _index_1 = 1, #_list_1 do -- 2259
					local c = _list_1[_index_1] -- 2259
					if c.title ~= title then -- 2259
						_accum_0[_len_0] = c -- 2259
						_len_0 = _len_0 + 1 -- 2259
					end -- 2259
				end -- 2259
				child.children = _accum_0 -- 2259
			end -- 2259
			break -- 2260
			::_continue_0:: -- 2257
		end -- 2256
	else -- 2262
		local _accum_0 = { } -- 2262
		local _len_0 = 1 -- 2262
		local _list_0 = lib.children -- 2262
		for _index_0 = 1, #_list_0 do -- 2262
			local child = _list_0[_index_0] -- 2262
			if child.title ~= "Dora" then -- 2262
				_accum_0[_len_0] = child -- 2262
				_len_0 = _len_0 + 1 -- 2262
			end -- 2262
		end -- 2262
		lib.children = _accum_0 -- 2262
	end -- 2255
	local builtinChildren = { -- 2263
		readme, -- 2263
		apiDoc, -- 2263
		tools, -- 2263
		font, -- 2263
		lib -- 2263
	} -- 2263
	if engineDev then -- 2264
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2265
		do -- 2266
			local _obj_0 = dev.children -- 2266
			_obj_0[#_obj_0 + 1] = { -- 2267
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2267
				dir = false, -- 2268
				builtin = true, -- 2269
				title = "init.yue" -- 2270
			} -- 2266
		end -- 2266
		builtinChildren[#builtinChildren + 1] = dev -- 2272
	end -- 2264
	return { -- 2274
		key = Content.writablePath, -- 2274
		dir = true, -- 2275
		root = true, -- 2276
		title = "Assets", -- 2277
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2278
	} -- 2273
end) -- 2240
HttpServer:post("/entry/list", function(req) -- 2290
	local Entry = require("Script.Dev.Entry") -- 2291
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2292
	res.success = true -- 2293
	return res -- 2294
end) -- 2290
HttpServer:post("/run/status", function() -- 2296
	local Entry = require("Script.Dev.Entry") -- 2297
	return Entry.getCurrentEntryStatus() -- 2298
end) -- 2296
HttpServer:postSchedule("/run", function(req) -- 2300
	do -- 2301
		local _type_0 = type(req) -- 2301
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2301
		if _tab_0 then -- 2301
			local file -- 2301
			do -- 2301
				local _obj_0 = req.body -- 2301
				local _type_1 = type(_obj_0) -- 2301
				if "table" == _type_1 or "userdata" == _type_1 then -- 2301
					file = _obj_0.file -- 2301
				end -- 2301
			end -- 2301
			local asProj -- 2301
			do -- 2301
				local _obj_0 = req.body -- 2301
				local _type_1 = type(_obj_0) -- 2301
				if "table" == _type_1 or "userdata" == _type_1 then -- 2301
					asProj = _obj_0.asProj -- 2301
				end -- 2301
			end -- 2301
			if file ~= nil and asProj ~= nil then -- 2301
				if not Content:isAbsolutePath(file) then -- 2302
					local devFile = Path(Content.writablePath, file) -- 2303
					if Content:exist(devFile) then -- 2304
						file = devFile -- 2304
					end -- 2304
				end -- 2302
				local Entry = require("Script.Dev.Entry") -- 2305
				local workDir -- 2306
				if asProj then -- 2307
					local projectRoot = req.body.projectRoot -- 2308
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2309
						workDir = projectRoot -- 2310
					else -- 2312
						workDir = getProjectDirFromFile(file) -- 2312
					end -- 2309
					if workDir then -- 2313
						Entry.allClear() -- 2314
						local target = Path(workDir, "init") -- 2315
						local success, err = Entry.enterEntryAsync({ -- 2316
							entryName = "Project", -- 2316
							fileName = target, -- 2316
							workDir = workDir, -- 2316
							projectRoot = workDir, -- 2316
							runKind = "project" -- 2316
						}) -- 2316
						target = Path:getName(Path:getPath(target)) -- 2317
						return { -- 2318
							success = success, -- 2318
							target = target, -- 2318
							err = err -- 2318
						} -- 2318
					end -- 2313
				else -- 2320
					workDir = getProjectDirFromFile(file) -- 2320
					if not workDir and Path:getExt(file) == "wasm" then -- 2321
						local parent = Path:getPath(file) -- 2322
						if Content:exist(Path(parent, "wa.mod")) then -- 2323
							workDir = parent -- 2324
						end -- 2323
					end -- 2321
				end -- 2307
				Entry.allClear() -- 2325
				file = Path:replaceExt(file, "") -- 2326
				local entry = { -- 2328
					entryName = Path:getName(file), -- 2328
					fileName = file, -- 2329
					runKind = "file" -- 2330
				} -- 2327
				if workDir then -- 2331
					entry.workDir = workDir -- 2332
					entry.projectRoot = workDir -- 2333
				end -- 2331
				local success, err = Entry.enterEntryAsync(entry) -- 2334
				return { -- 2335
					success = success, -- 2335
					err = err -- 2335
				} -- 2335
			end -- 2301
		end -- 2301
	end -- 2301
	return { -- 2300
		success = false -- 2300
	} -- 2300
end) -- 2300
local _anon_func_7 = function(result) -- 2377
	if result.success then -- 2377
		return nil -- 2377
	else -- 2377
		return "PREVIEW_FAILED" -- 2377
	end -- 2377
end -- 2377
HttpServer:postSchedule("/agent/preview", function(req) -- 2337
	local releaseAgent = AgentHost.acquire() -- 2338
	local _ <close> = setmetatable({ }, { -- 2339
		__close = function() -- 2339
			return releaseAgent() -- 2339
		end -- 2339
	}) -- 2339
	do -- 2340
		local _type_0 = type(req) -- 2340
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2340
		if _tab_0 then -- 2340
			local projectRoot -- 2340
			do -- 2340
				local _obj_0 = req.body -- 2340
				local _type_1 = type(_obj_0) -- 2340
				if "table" == _type_1 or "userdata" == _type_1 then -- 2340
					projectRoot = _obj_0.projectRoot -- 2340
				end -- 2340
			end -- 2340
			if projectRoot ~= nil then -- 2340
				if not getProjectSourceRoot(projectRoot) then -- 2341
					return { -- 2341
						success = false, -- 2341
						code = "INVALID_PROJECT", -- 2341
						message = "projectRoot must be an existing absolute directory" -- 2341
					} -- 2341
				end -- 2341
				local entryFile = req.body.entry or "init.lua" -- 2342
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2343
					return { -- 2343
						success = false, -- 2343
						code = "INVALID_ENTRY", -- 2343
						message = "entry must be a non-empty project-relative path" -- 2343
					} -- 2343
				end -- 2343
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2344
					0.5 -- 2344
				} -- 2344
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2345
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2346
					return { -- 2346
						success = false, -- 2346
						code = "INVALID_QUEUE_TIMEOUT", -- 2346
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2346
					} -- 2346
				end -- 2346
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2347
				local AgentOperation = require("Agent.Tool.Operation") -- 2348
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2349
				local requestId = AgentOperation.createOperationId() -- 2350
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2351
				if not enqueued.success then -- 2352
					return { -- 2352
						success = false, -- 2352
						code = "ENTRY_QUEUE_REJECTED", -- 2352
						message = enqueued.message -- 2352
					} -- 2352
				end -- 2352
				local queuedAt = App.runningTime -- 2353
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2354
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2355
						local state = agentEntryRunQueue:get(requestId) -- 2356
						agentEntryRunQueue:cancel(requestId) -- 2357
						return { -- 2359
							success = false, -- 2359
							code = "ENTRY_QUEUE_TIMEOUT", -- 2360
							message = "timed out waiting for the Dora entry runtime", -- 2361
							requestId = requestId, -- 2362
							queuePosition = state.position -- 2363
						} -- 2358
					end -- 2355
					sleep() -- 2364
				end -- 2354
				local queueWaitSeconds = App.runningTime - queuedAt -- 2365
				local _ <close> = setmetatable({ }, { -- 2366
					__close = function() -- 2366
						return agentEntryRunQueue:release(requestId) -- 2366
					end -- 2366
				}) -- 2366
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2367
				local Entry = require("Script.Dev.Entry") -- 2368
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2370
					workDir = projectRoot, -- 2370
					operationId = requestId, -- 2371
					print = function() end -- 2372
				}, Entry) -- 2369
				local result = preview({ -- 2374
					entry = entryFile, -- 2374
					captureAtSeconds = captureAtSeconds -- 2374
				}) -- 2374
				return { -- 2376
					success = result.success, -- 2376
					code = _anon_func_7(result), -- 2377
					message = result.message, -- 2378
					requestId = requestId, -- 2379
					queueWaitSeconds = queueWaitSeconds, -- 2380
					interruptedUserRun = result.interruptedUserRun, -- 2381
					files = result.files, -- 2382
					frames = result.frames -- 2383
				} -- 2375
			end -- 2340
		end -- 2340
	end -- 2340
	return { -- 2337
		success = false, -- 2337
		message = "invalid call" -- 2337
	} -- 2337
end) -- 2337
HttpServer:postSchedule("/agent/command", function(req) -- 2385
	local releaseAgent = AgentHost.acquire() -- 2386
	local _ <close> = setmetatable({ }, { -- 2387
		__close = function() -- 2387
			return releaseAgent() -- 2387
		end -- 2387
	}) -- 2387
	do -- 2388
		local _type_0 = type(req) -- 2388
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2388
		if _tab_0 then -- 2388
			local body = req.body -- 2388
			if body ~= nil then -- 2388
				local projectRoot = body.projectRoot -- 2389
				if not getProjectSourceRoot(projectRoot) then -- 2390
					return { -- 2390
						success = false, -- 2390
						code = "INVALID_PROJECT", -- 2390
						message = "projectRoot must be an existing absolute directory" -- 2390
					} -- 2390
				end -- 2390
				local AgentValidation = require("Agent.Tool.Validation") -- 2391
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2392
				if not validated.success then -- 2393
					return { -- 2393
						success = false, -- 2393
						code = "INVALID_COMMAND", -- 2393
						message = validated.message -- 2393
					} -- 2393
				end -- 2393
				local input = validated.value -- 2394
				local AgentCommand = require("Agent.Tool.Command") -- 2395
				local result = nil -- 2396
				local failure = nil -- 2397
				local promise = AgentCommand.executeCommand({ -- 2399
					workDir = projectRoot, -- 2399
					mode = input.mode, -- 2400
					code = input.code, -- 2401
					command = input.command, -- 2402
					cwd = input.cwd, -- 2403
					timeoutSeconds = input.timeoutSeconds -- 2404
				}) -- 2398
				promise:addCallbacks((function(_, value) -- 2405
					result = value -- 2405
				end), (function(_, err) -- 2405
					failure = tostring(err) -- 2405
				end)) -- 2405
				wait(function() -- 2406
					return result ~= nil or failure ~= nil -- 2406
				end) -- 2406
				if failure then -- 2407
					return { -- 2407
						success = false, -- 2407
						code = "COMMAND_BRIDGE_FAILED", -- 2407
						message = failure -- 2407
					} -- 2407
				end -- 2407
				if not result.success then -- 2408
					result.code = "COMMAND_FAILED" -- 2409
				end -- 2408
				return result -- 2410
			end -- 2388
		end -- 2388
	end -- 2388
	return { -- 2385
		success = false, -- 2385
		code = "INVALID_COMMAND", -- 2385
		message = "invalid call" -- 2385
	} -- 2385
end) -- 2385
HttpServer:postSchedule("/stop", function() -- 2412
	local Entry = require("Script.Dev.Entry") -- 2413
	return { -- 2414
		success = Entry.stop() -- 2414
	} -- 2414
end) -- 2412
local minifyAsync -- 2416
minifyAsync = function(sourcePath, minifyPath) -- 2416
	if not Content:exist(sourcePath) then -- 2417
		return -- 2417
	end -- 2417
	local Entry = require("Script.Dev.Entry") -- 2418
	local errors = { } -- 2419
	local files = Entry.getAllFiles(sourcePath, { -- 2420
		"lua" -- 2420
	}, true) -- 2420
	do -- 2421
		local _accum_0 = { } -- 2421
		local _len_0 = 1 -- 2421
		for _index_0 = 1, #files do -- 2421
			local file = files[_index_0] -- 2421
			if file:sub(1, 1) ~= '.' then -- 2421
				_accum_0[_len_0] = file -- 2421
				_len_0 = _len_0 + 1 -- 2421
			end -- 2421
		end -- 2421
		files = _accum_0 -- 2421
	end -- 2421
	local paths -- 2422
	do -- 2422
		local _tbl_0 = { } -- 2422
		for _index_0 = 1, #files do -- 2422
			local file = files[_index_0] -- 2422
			_tbl_0[Path:getPath(file)] = true -- 2422
		end -- 2422
		paths = _tbl_0 -- 2422
	end -- 2422
	for path in pairs(paths) do -- 2423
		Content:mkdir(Path(minifyPath, path)) -- 2423
	end -- 2423
	local _ <close> = setmetatable({ }, { -- 2424
		__close = function() -- 2424
			package.loaded["luaminify.FormatMini"] = nil -- 2425
			package.loaded["luaminify.ParseLua"] = nil -- 2426
			package.loaded["luaminify.Scope"] = nil -- 2427
			package.loaded["luaminify.Util"] = nil -- 2428
		end -- 2424
	}) -- 2424
	local FormatMini -- 2429
	do -- 2429
		local _obj_0 = require("luaminify") -- 2429
		FormatMini = _obj_0.FormatMini -- 2429
	end -- 2429
	local fileCount = #files -- 2430
	local count = 0 -- 2431
	for _index_0 = 1, #files do -- 2432
		local file = files[_index_0] -- 2432
		thread(function() -- 2433
			local _ <close> = setmetatable({ }, { -- 2434
				__close = function() -- 2434
					count = count + 1 -- 2434
				end -- 2434
			}) -- 2434
			local input = Path(sourcePath, file) -- 2435
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2436
			if Content:exist(input) then -- 2437
				local sourceCodes = Content:loadAsync(input) -- 2438
				local res, err = FormatMini(sourceCodes) -- 2439
				if res then -- 2440
					Content:saveAsync(output, res) -- 2441
					return print("Minify " .. tostring(file)) -- 2442
				else -- 2444
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2444
				end -- 2440
			else -- 2446
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2446
			end -- 2437
		end) -- 2433
		sleep() -- 2447
	end -- 2432
	wait(function() -- 2448
		return count == fileCount -- 2448
	end) -- 2448
	if #errors > 0 then -- 2449
		print(table.concat(errors, '\n')) -- 2450
	end -- 2449
	print("Obfuscation done.") -- 2451
	return files -- 2452
end -- 2416
local zipping = false -- 2454
HttpServer:postSchedule("/zip", function(req) -- 2456
	do -- 2457
		local _type_0 = type(req) -- 2457
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2457
		if _tab_0 then -- 2457
			local path -- 2457
			do -- 2457
				local _obj_0 = req.body -- 2457
				local _type_1 = type(_obj_0) -- 2457
				if "table" == _type_1 or "userdata" == _type_1 then -- 2457
					path = _obj_0.path -- 2457
				end -- 2457
			end -- 2457
			local zipFile -- 2457
			do -- 2457
				local _obj_0 = req.body -- 2457
				local _type_1 = type(_obj_0) -- 2457
				if "table" == _type_1 or "userdata" == _type_1 then -- 2457
					zipFile = _obj_0.zipFile -- 2457
				end -- 2457
			end -- 2457
			local obfuscated -- 2457
			do -- 2457
				local _obj_0 = req.body -- 2457
				local _type_1 = type(_obj_0) -- 2457
				if "table" == _type_1 or "userdata" == _type_1 then -- 2457
					obfuscated = _obj_0.obfuscated -- 2457
				end -- 2457
			end -- 2457
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2457
				if zipping then -- 2458
					goto failed -- 2458
				end -- 2458
				zipping = true -- 2459
				local _ <close> = setmetatable({ }, { -- 2460
					__close = function() -- 2460
						zipping = false -- 2460
					end -- 2460
				}) -- 2460
				if not Content:exist(path) then -- 2461
					goto failed -- 2461
				end -- 2461
				Content:mkdir(Path:getPath(zipFile)) -- 2462
				if obfuscated then -- 2463
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2464
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2465
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2466
					Content:remove(scriptPath) -- 2467
					Content:remove(obfuscatedPath) -- 2468
					Content:remove(tempPath) -- 2469
					Content:mkdir(scriptPath) -- 2470
					Content:mkdir(obfuscatedPath) -- 2471
					Content:mkdir(tempPath) -- 2472
					if not Content:copyAsync(path, tempPath) then -- 2473
						goto failed -- 2473
					end -- 2473
					local Entry = require("Script.Dev.Entry") -- 2474
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2475
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2476
						"tl", -- 2476
						"yue", -- 2476
						"lua", -- 2476
						"ts", -- 2476
						"tsx", -- 2476
						"vs", -- 2476
						"bl", -- 2476
						"xml", -- 2476
						"wa", -- 2476
						"mod" -- 2476
					}, true) -- 2476
					for _index_0 = 1, #scriptFiles do -- 2477
						local file = scriptFiles[_index_0] -- 2477
						Content:remove(Path(tempPath, file)) -- 2478
					end -- 2477
					for _index_0 = 1, #luaFiles do -- 2479
						local file = luaFiles[_index_0] -- 2479
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2480
					end -- 2479
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2481
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2482
					end) then -- 2481
						goto failed -- 2481
					end -- 2481
					return { -- 2483
						success = true -- 2483
					} -- 2483
				else -- 2485
					return { -- 2485
						success = Content:zipAsync(path, zipFile, function(file) -- 2485
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2486
						end) -- 2485
					} -- 2485
				end -- 2463
			end -- 2457
		end -- 2457
	end -- 2457
	::failed:: -- 2487
	return { -- 2456
		success = false -- 2456
	} -- 2456
end) -- 2456
HttpServer:postSchedule("/unzip", function(req) -- 2489
	do -- 2490
		local _type_0 = type(req) -- 2490
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2490
		if _tab_0 then -- 2490
			local zipFile -- 2490
			do -- 2490
				local _obj_0 = req.body -- 2490
				local _type_1 = type(_obj_0) -- 2490
				if "table" == _type_1 or "userdata" == _type_1 then -- 2490
					zipFile = _obj_0.zipFile -- 2490
				end -- 2490
			end -- 2490
			local path -- 2490
			do -- 2490
				local _obj_0 = req.body -- 2490
				local _type_1 = type(_obj_0) -- 2490
				if "table" == _type_1 or "userdata" == _type_1 then -- 2490
					path = _obj_0.path -- 2490
				end -- 2490
			end -- 2490
			if zipFile ~= nil and path ~= nil then -- 2490
				return { -- 2491
					success = Content:unzipAsync(zipFile, path, function(file) -- 2491
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2492
					end) -- 2491
				} -- 2491
			end -- 2490
		end -- 2490
	end -- 2490
	return { -- 2489
		success = false -- 2489
	} -- 2489
end) -- 2489
HttpServer:post("/editing-info", function(req) -- 2494
	local Entry = require("Script.Dev.Entry") -- 2495
	local config = Entry.getConfig() -- 2496
	local _type_0 = type(req) -- 2497
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2497
	local _match_0 = false -- 2497
	if _tab_0 then -- 2497
		local editingInfo -- 2497
		do -- 2497
			local _obj_0 = req.body -- 2497
			local _type_1 = type(_obj_0) -- 2497
			if "table" == _type_1 or "userdata" == _type_1 then -- 2497
				editingInfo = _obj_0.editingInfo -- 2497
			end -- 2497
		end -- 2497
		if editingInfo ~= nil then -- 2497
			_match_0 = true -- 2497
			config.editingInfo = editingInfo -- 2498
			return { -- 2499
				success = true -- 2499
			} -- 2499
		end -- 2497
	end -- 2497
	if not _match_0 then -- 2497
		if not (config.editingInfo ~= nil) then -- 2501
			local folder -- 2502
			if App.locale:match('^zh') then -- 2502
				folder = 'zh-Hans' -- 2502
			else -- 2502
				folder = 'en' -- 2502
			end -- 2502
			config.editingInfo = json.encode({ -- 2504
				index = 0, -- 2504
				files = { -- 2506
					{ -- 2507
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2507
						title = "welcome.md" -- 2508
					} -- 2506
				} -- 2505
			}) -- 2503
		end -- 2501
		return { -- 2512
			success = true, -- 2512
			editingInfo = config.editingInfo -- 2512
		} -- 2512
	end -- 2497
end) -- 2494
HttpServer:post("/command", function(req) -- 2514
	do -- 2515
		local _type_0 = type(req) -- 2515
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2515
		if _tab_0 then -- 2515
			local code -- 2515
			do -- 2515
				local _obj_0 = req.body -- 2515
				local _type_1 = type(_obj_0) -- 2515
				if "table" == _type_1 or "userdata" == _type_1 then -- 2515
					code = _obj_0.code -- 2515
				end -- 2515
			end -- 2515
			local log -- 2515
			do -- 2515
				local _obj_0 = req.body -- 2515
				local _type_1 = type(_obj_0) -- 2515
				if "table" == _type_1 or "userdata" == _type_1 then -- 2515
					log = _obj_0.log -- 2515
				end -- 2515
			end -- 2515
			if code ~= nil and log ~= nil then -- 2515
				emit("AppCommand", code, log) -- 2516
				return { -- 2517
					success = true -- 2517
				} -- 2517
			end -- 2515
		end -- 2515
	end -- 2515
	return { -- 2514
		success = false -- 2514
	} -- 2514
end) -- 2514
HttpServer:post("/log/save", function() -- 2519
	local folder = ".download" -- 2520
	local fullLogFile = "dora_full_logs.txt" -- 2521
	local fullFolder = Path(Content.writablePath, folder) -- 2522
	Content:mkdir(fullFolder) -- 2523
	local logPath = Path(fullFolder, fullLogFile) -- 2524
	if App:saveLog(logPath) then -- 2525
		return { -- 2526
			success = true, -- 2526
			path = Path(folder, fullLogFile) -- 2526
		} -- 2526
	end -- 2525
	return { -- 2519
		success = false -- 2519
	} -- 2519
end) -- 2519
local tailLines -- 2528
tailLines = function(text, count) -- 2528
	local lines = { } -- 2529
	text = text:gsub("\r\n", "\n") -- 2530
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2531
		lines[#lines + 1] = line -- 2532
	end -- 2531
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2533
		table.remove(lines) -- 2534
	end -- 2533
	local start = math.max(1, #lines - count + 1) -- 2535
	local out = { } -- 2536
	for i = start, #lines do -- 2537
		out[#out + 1] = lines[i] -- 2538
	end -- 2537
	return table.concat(out, "\n") -- 2539
end -- 2528
HttpServer:post("/log", function(req) -- 2541
	local count = 100 -- 2542
	if req and req.body and req.body.count ~= nil then -- 2543
		count = req.body.count -- 2544
	end -- 2543
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2545
		return { -- 2546
			success = false, -- 2546
			message = "count must be a positive integer" -- 2546
		} -- 2546
	end -- 2545
	local folder = ".download" -- 2547
	local fullLogFile = "dora_full_logs.txt" -- 2548
	local fullFolder = Path(Content.writablePath, folder) -- 2549
	Content:mkdir(fullFolder) -- 2550
	local logPath = Path(fullFolder, fullLogFile) -- 2551
	if App:saveLog(logPath) then -- 2552
		local text = Content:load(logPath) -- 2553
		if text then -- 2554
			return { -- 2555
				success = true, -- 2555
				log = tailLines(text, count) -- 2555
			} -- 2555
		else -- 2557
			return { -- 2557
				success = false, -- 2557
				message = "failed to read log" -- 2557
			} -- 2557
		end -- 2554
	else -- 2559
		return { -- 2559
			success = false, -- 2559
			message = "failed to save log" -- 2559
		} -- 2559
	end -- 2552
	return { -- 2541
		success = false -- 2541
	} -- 2541
end) -- 2541
HttpServer:post("/yarn/check", function(req) -- 2561
	local yarncompile = require("yarncompile") -- 2562
	do -- 2563
		local _type_0 = type(req) -- 2563
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2563
		if _tab_0 then -- 2563
			local code -- 2563
			do -- 2563
				local _obj_0 = req.body -- 2563
				local _type_1 = type(_obj_0) -- 2563
				if "table" == _type_1 or "userdata" == _type_1 then -- 2563
					code = _obj_0.code -- 2563
				end -- 2563
			end -- 2563
			if code ~= nil then -- 2563
				local jsonObject = json.decode(code) -- 2564
				if jsonObject then -- 2564
					local errors = { } -- 2565
					local _list_0 = jsonObject.nodes -- 2566
					for _index_0 = 1, #_list_0 do -- 2566
						local node = _list_0[_index_0] -- 2566
						local title, body = node.title, node.body -- 2567
						local luaCode, err = yarncompile(body) -- 2568
						if not luaCode then -- 2568
							errors[#errors + 1] = title .. ":" .. err -- 2569
						end -- 2568
					end -- 2566
					return { -- 2570
						success = true, -- 2570
						syntaxError = table.concat(errors, "\n\n") -- 2570
					} -- 2570
				end -- 2564
			end -- 2563
		end -- 2563
	end -- 2563
	return { -- 2561
		success = false -- 2561
	} -- 2561
end) -- 2561
HttpServer:post("/yarn/check-file", function(req) -- 2572
	local yarncompile = require("yarncompile") -- 2573
	do -- 2574
		local _type_0 = type(req) -- 2574
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2574
		if _tab_0 then -- 2574
			local code -- 2574
			do -- 2574
				local _obj_0 = req.body -- 2574
				local _type_1 = type(_obj_0) -- 2574
				if "table" == _type_1 or "userdata" == _type_1 then -- 2574
					code = _obj_0.code -- 2574
				end -- 2574
			end -- 2574
			if code ~= nil then -- 2574
				local res, _, err = yarncompile(code, true) -- 2575
				if not res then -- 2575
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2576
					return { -- 2577
						success = false, -- 2577
						message = message, -- 2577
						line = line, -- 2577
						column = column, -- 2577
						node = node -- 2577
					} -- 2577
				end -- 2575
			end -- 2574
		end -- 2574
	end -- 2574
	return { -- 2572
		success = true -- 2572
	} -- 2572
end) -- 2572
getWaProjectDirFromFile = function(file) -- 2579
	local current -- 2580
	if Content:isdir(file) then -- 2580
		current = file -- 2580
	else -- 2580
		current = Path:getPath(file) -- 2580
	end -- 2580
	if current == "" then -- 2581
		return nil -- 2581
	end -- 2581
	repeat -- 2582
		local modPath = Path(current, "wa.mod") -- 2583
		if Content:exist(modPath) then -- 2584
			return current, modPath -- 2585
		end -- 2584
		local parent = Path:getPath(current) -- 2586
		if parent == "" or parent == current then -- 2587
			break -- 2587
		end -- 2587
		current = parent -- 2588
	until false -- 2582
	return nil -- 2590
end -- 2579
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2592
	do -- 2593
		local _type_0 = type(req) -- 2593
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2593
		if _tab_0 then -- 2593
			local path -- 2593
			do -- 2593
				local _obj_0 = req.body -- 2593
				local _type_1 = type(_obj_0) -- 2593
				if "table" == _type_1 or "userdata" == _type_1 then -- 2593
					path = _obj_0.path -- 2593
				end -- 2593
			end -- 2593
			if path ~= nil then -- 2593
				local projDir = getWaProjectDirFromFile(path) -- 2594
				if projDir then -- 2594
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2595
					if not Content:exist(sourceDoraPath) then -- 2596
						return { -- 2597
							success = false, -- 2597
							message = "missing dora template" -- 2597
						} -- 2597
					end -- 2596
					local targetVendorPath = Path(projDir, "vendor") -- 2598
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2599
					if not Content:exist(targetVendorPath) then -- 2600
						if not Content:mkdir(targetVendorPath) then -- 2601
							return { -- 2602
								success = false, -- 2602
								message = "failed to create vendor folder" -- 2602
							} -- 2602
						end -- 2601
					elseif not Content:isdir(targetVendorPath) then -- 2603
						return { -- 2604
							success = false, -- 2604
							message = "vendor path is not a folder" -- 2604
						} -- 2604
					end -- 2600
					if Content:exist(targetDoraPath) then -- 2605
						if not Content:remove(targetDoraPath) then -- 2606
							return { -- 2607
								success = false, -- 2607
								message = "failed to remove old dora" -- 2607
							} -- 2607
						end -- 2606
					end -- 2605
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2608
						return { -- 2609
							success = false, -- 2609
							message = "failed to copy dora" -- 2609
						} -- 2609
					end -- 2608
					return { -- 2610
						success = true -- 2610
					} -- 2610
				else -- 2612
					return { -- 2612
						success = false, -- 2612
						message = 'Wa file needs a project' -- 2612
					} -- 2612
				end -- 2594
			end -- 2593
		end -- 2593
	end -- 2593
	return { -- 2592
		success = false, -- 2592
		message = "invalid call" -- 2592
	} -- 2592
end) -- 2592
HttpServer:postSchedule("/wa/build", function(req) -- 2614
	do -- 2615
		local _type_0 = type(req) -- 2615
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2615
		if _tab_0 then -- 2615
			local path -- 2615
			do -- 2615
				local _obj_0 = req.body -- 2615
				local _type_1 = type(_obj_0) -- 2615
				if "table" == _type_1 or "userdata" == _type_1 then -- 2615
					path = _obj_0.path -- 2615
				end -- 2615
			end -- 2615
			if path ~= nil then -- 2615
				local projDir = getWaProjectDirFromFile(path) -- 2616
				if projDir then -- 2616
					local message = Wasm:buildWaAsync(projDir) -- 2617
					if message == "" then -- 2618
						return { -- 2619
							success = true -- 2619
						} -- 2619
					else -- 2621
						return { -- 2621
							success = false, -- 2621
							message = message -- 2621
						} -- 2621
					end -- 2618
				else -- 2623
					return { -- 2623
						success = false, -- 2623
						message = 'Wa file needs a project' -- 2623
					} -- 2623
				end -- 2616
			end -- 2615
		end -- 2615
	end -- 2615
	return { -- 2624
		success = false, -- 2624
		message = 'failed to build' -- 2624
	} -- 2624
end) -- 2614
HttpServer:postSchedule("/wa/format", function(req) -- 2626
	do -- 2627
		local _type_0 = type(req) -- 2627
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2627
		if _tab_0 then -- 2627
			local file -- 2627
			do -- 2627
				local _obj_0 = req.body -- 2627
				local _type_1 = type(_obj_0) -- 2627
				if "table" == _type_1 or "userdata" == _type_1 then -- 2627
					file = _obj_0.file -- 2627
				end -- 2627
			end -- 2627
			if file ~= nil then -- 2627
				local code = Wasm:formatWaAsync(file) -- 2628
				if code == "" then -- 2629
					return { -- 2630
						success = false -- 2630
					} -- 2630
				else -- 2632
					return { -- 2632
						success = true, -- 2632
						code = code -- 2632
					} -- 2632
				end -- 2629
			end -- 2627
		end -- 2627
	end -- 2627
	return { -- 2633
		success = false -- 2633
	} -- 2633
end) -- 2626
HttpServer:postSchedule("/wa/create", function(req) -- 2635
	do -- 2636
		local _type_0 = type(req) -- 2636
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2636
		if _tab_0 then -- 2636
			local path -- 2636
			do -- 2636
				local _obj_0 = req.body -- 2636
				local _type_1 = type(_obj_0) -- 2636
				if "table" == _type_1 or "userdata" == _type_1 then -- 2636
					path = _obj_0.path -- 2636
				end -- 2636
			end -- 2636
			if path ~= nil then -- 2636
				if not Content:exist(Path:getPath(path)) then -- 2637
					return { -- 2638
						success = false, -- 2638
						message = "target path not existed" -- 2638
					} -- 2638
				end -- 2637
				if Content:exist(path) then -- 2639
					return { -- 2640
						success = false, -- 2640
						message = "target project folder existed" -- 2640
					} -- 2640
				end -- 2639
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2641
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2642
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2643
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2644
					return { -- 2647
						success = false, -- 2647
						message = "missing template project" -- 2647
					} -- 2647
				end -- 2644
				if not Content:mkdir(path) then -- 2648
					return { -- 2649
						success = false, -- 2649
						message = "failed to create project folder" -- 2649
					} -- 2649
				end -- 2648
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2650
					Content:remove(path) -- 2651
					return { -- 2652
						success = false, -- 2652
						message = "failed to copy template" -- 2652
					} -- 2652
				end -- 2650
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2653
					Content:remove(path) -- 2654
					return { -- 2655
						success = false, -- 2655
						message = "failed to copy template" -- 2655
					} -- 2655
				end -- 2653
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2656
					Content:remove(path) -- 2657
					return { -- 2658
						success = false, -- 2658
						message = "failed to copy template" -- 2658
					} -- 2658
				end -- 2656
				return { -- 2659
					success = true -- 2659
				} -- 2659
			end -- 2636
		end -- 2636
	end -- 2636
	return { -- 2635
		success = false, -- 2635
		message = "invalid call" -- 2635
	} -- 2635
end) -- 2635
local tsBuildGlobs = { -- 2662
	"**/*.ts", -- 2662
	"**/*.tsx", -- 2663
	"!**/.*/**", -- 2664
	"!**/node_modules/**" -- 2665
} -- 2661
local tsSnapshotGlobs = { -- 2668
	"**/*.ts", -- 2668
	"**/*.tsx", -- 2669
	"**/*.lua", -- 2670
	"!**/.*/**", -- 2671
	"!**/node_modules/**" -- 2672
} -- 2667
local collectTSVirtualFiles -- 2674
collectTSVirtualFiles = function(sourceRoot) -- 2674
	local files = { } -- 2675
	local seen = { } -- 2676
	local addFile -- 2677
	addFile = function(file, moduleName, virtualFile) -- 2677
		if moduleName == nil then -- 2677
			moduleName = nil -- 2677
		end -- 2677
		if virtualFile == nil then -- 2677
			virtualFile = nil -- 2677
		end -- 2677
		local targetFile = virtualFile or file -- 2678
		do -- 2679
			local entry = seen[targetFile] -- 2679
			if entry then -- 2679
				if moduleName and moduleName ~= "" then -- 2680
					entry.moduleName = moduleName -- 2680
				end -- 2680
				return -- 2681
			end -- 2679
		end -- 2679
		local content = Content:load(file) -- 2682
		if content then -- 2682
			local entry = { -- 2683
				file = targetFile, -- 2683
				content = content -- 2683
			} -- 2683
			if moduleName and moduleName ~= "" then -- 2684
				entry.moduleName = moduleName -- 2684
			end -- 2684
			seen[targetFile] = entry -- 2685
			files[#files + 1] = entry -- 2686
		end -- 2682
	end -- 2677
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2687
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2688
		for _index_0 = 1, #_list_0 do -- 2688
			local subFile = _list_0[_index_0] -- 2688
			addFile(Path(sourceRoot, subFile)) -- 2689
		end -- 2688
		local libraryRoots = { -- 2691
			Path(sourceRoot, "Script", "Lib"), -- 2691
			Path(sourceRoot, "Lib"), -- 2692
			Path(Content.assetPath, "Script", "Lib") -- 2693
		} -- 2690
		for _index_0 = 1, #libraryRoots do -- 2694
			local libraryRoot = libraryRoots[_index_0] -- 2694
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2695
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2696
				for _index_1 = 1, #_list_1 do -- 2696
					local subFile = _list_1[_index_1] -- 2696
					local file = Path(libraryRoot, subFile) -- 2697
					local virtualFile = Path(sourceRoot, subFile) -- 2698
					addFile(file, nil, virtualFile) -- 2699
				end -- 2696
			end -- 2695
		end -- 2694
	end -- 2687
	local locale -- 2700
	if App.locale:match('^zh') then -- 2700
		locale = 'zh-Hans' -- 2700
	else -- 2700
		locale = 'en' -- 2700
	end -- 2700
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2701
	local _list_0 = Content:getFiles(declarationRoot) -- 2702
	for _index_0 = 1, #_list_0 do -- 2702
		local file = _list_0[_index_0] -- 2702
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2703
			local fullPath = Path(declarationRoot, file) -- 2704
			local moduleName = Path:getName(Path:getName(file)) -- 2705
			addFile(fullPath, moduleName) -- 2706
		end -- 2703
	end -- 2702
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2707
	local lualibBundleTarget -- 2708
	if sourceRoot then -- 2708
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2708
	else -- 2708
		lualibBundleTarget = "lualib_bundle.lua" -- 2708
	end -- 2708
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2709
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2710
	local _list_1 = Content:getFiles(lualibRoot) -- 2711
	for _index_0 = 1, #_list_1 do -- 2711
		local file = _list_1[_index_0] -- 2711
		if Path:getExt(file) == "lua" then -- 2712
			local virtualFile -- 2713
			if sourceRoot then -- 2713
				virtualFile = Path(sourceRoot, "lualib", file) -- 2713
			else -- 2713
				virtualFile = Path("lualib", file) -- 2713
			end -- 2713
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2714
		end -- 2712
	end -- 2711
	return files -- 2715
end -- 2674
local supportsCompilerWebView -- 2717
supportsCompilerWebView = function() -- 2717
	local _val_0 = App.platform -- 2717
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2717
end -- 2717
local webIDECompilerReady = false -- 2718
local webIDEConnectionGeneration = 0 -- 2719
local tsProbeId = 0 -- 2720
local probeWebIDECompiler -- 2722
probeWebIDECompiler = function(isCancelled) -- 2722
	if HttpServer.wsConnectionCount == 0 then -- 2723
		return false -- 2723
	end -- 2723
	tsProbeId = tsProbeId + 1 -- 2724
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2725
	local generation = webIDEConnectionGeneration -- 2726
	local done, ready = false, false -- 2727
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2728
	local listener = Node() -- 2729
	listener:gslot("AppWS", function(event) -- 2730
		if event.type == "Receive" then -- 2731
			local res = json.decode(event.msg) -- 2732
			if res then -- 2732
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2733
					responses = responses + 1 -- 2734
					ready = ready or res.success == true -- 2735
					done = ready or responses >= expectedResponses -- 2736
				end -- 2733
			end -- 2732
		end -- 2731
	end) -- 2730
	emit("AppWS", "Send", json.encode({ -- 2737
		name = "TranspileTSProbe", -- 2737
		id = requestId -- 2737
	})) -- 2737
	local deadline = App.runningTime + 5 -- 2738
	wait(function() -- 2739
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2739
	end) -- 2739
	listener:removeFromParent() -- 2740
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2741
	if generation == webIDEConnectionGeneration then -- 2742
		webIDECompilerReady = ready -- 2742
	end -- 2742
	return ready -- 2743
end -- 2722
local compilerConnectionListener = Node() -- 2745
compilerConnectionListener:addTo(Director.systemUI) -- 2747
local _anon_func_8 = function(event) -- 2749
	local _val_0 = event.type -- 2749
	return "Open" == _val_0 or "Close" == _val_0 -- 2749
end -- 2749
compilerConnectionListener:gslot("AppWS", function(event) -- 2748
	if _anon_func_8(event) then -- 2749
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2750
		webIDECompilerReady = false -- 2751
		if HttpServer.wsConnectionCount > 0 then -- 2752
			return thread(function() -- 2753
				return probeWebIDECompiler() -- 2753
			end) -- 2753
		end -- 2752
	end -- 2749
end) -- 2748
local _anon_func_9 = function(res) -- 2778
	if res.success then -- 2778
		return "tool" -- 2778
	else -- 2778
		return res.failureKind -- 2778
	end -- 2778
end -- 2778
local transpileTSFileWithWebIDE -- 2755
do -- 2755
	local tsBuildRequestId = 0 -- 2756
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2757
		if not probeWebIDECompiler(isCancelled) then -- 2758
			if isCancelled and isCancelled() then -- 2759
				return { -- 2760
					success = false, -- 2760
					file = file, -- 2760
					message = "build canceled", -- 2760
					interrupted = true -- 2760
				} -- 2760
			end -- 2759
			return { -- 2761
				success = false, -- 2761
				file = file, -- 2761
				message = "TypeScript transpiler is not ready", -- 2761
				failureKind = "tool" -- 2761
			} -- 2761
		end -- 2758
		tsBuildRequestId = tsBuildRequestId + 1 -- 2762
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2763
		local done = false -- 2764
		local result = nil -- 2765
		local listener = Node() -- 2766
		listener:gslot("AppWS", function(event) -- 2767
			if event.type == "Receive" then -- 2768
				local res = json.decode(event.msg) -- 2769
				if res then -- 2769
					if res.name == "TranspileTS" and res.id == requestId then -- 2770
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2771
							local luaFile = Path:replaceExt(file, "lua") -- 2772
							if Content:save(luaFile, res.luaCode) then -- 2773
								result = { -- 2774
									success = true, -- 2774
									file = file -- 2774
								} -- 2774
							else -- 2776
								result = { -- 2776
									success = false, -- 2776
									file = file, -- 2776
									message = "failed to save " .. tostring(luaFile) -- 2776
								} -- 2776
							end -- 2773
						else -- 2778
							result = { -- 2778
								success = false, -- 2778
								file = file, -- 2778
								message = res.message or "Compiler returned no Lua output", -- 2778
								failureKind = _anon_func_9(res) -- 2778
							} -- 2778
						end -- 2771
						done = true -- 2779
					end -- 2770
				end -- 2769
			end -- 2768
		end) -- 2767
		emit("AppWS", "Send", json.encode({ -- 2780
			name = "TranspileTS", -- 2780
			id = requestId, -- 2780
			file = file, -- 2780
			content = content, -- 2780
			projectRoot = sourceRoot, -- 2780
			files = files -- 2780
		})) -- 2780
		local deadline = App.runningTime + 30 -- 2781
		wait(function() -- 2782
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2782
		end) -- 2782
		listener:removeFromParent() -- 2783
		if not done then -- 2784
			webIDECompilerReady = false -- 2785
			if isCancelled and isCancelled() then -- 2786
				return { -- 2787
					success = false, -- 2787
					file = file, -- 2787
					message = "build canceled", -- 2787
					interrupted = true -- 2787
				} -- 2787
			end -- 2786
			return { -- 2788
				success = false, -- 2788
				file = file, -- 2788
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2788
				failureKind = "tool" -- 2788
			} -- 2788
		end -- 2784
		return result -- 2789
	end -- 2757
end -- 2755
local compilerReadyTimeout <const> = 15 -- 2791
local compilerBuildTimeout <const> = 30 -- 2792
local compilerIdleCloseSeconds <const> = 8 -- 2793
local compilerReady = false -- 2794
local compilerRequested = false -- 2795
local compilerFailure = nil -- 2796
local compilerUsers = 0 -- 2797
local compilerCloseGeneration = 0 -- 2798
local compilerJobId = 0 -- 2799
local compilerJobs = { } -- 2800
local compilerResults = { } -- 2801
local compilerInFlight = { } -- 2802
HttpServer:post("/compiler/ready", function() -- 2804
	if not compilerRequested then -- 2805
		return { -- 2805
			success = false -- 2805
		} -- 2805
	end -- 2805
	compilerReady = true -- 2806
	return { -- 2807
		success = true -- 2807
	} -- 2807
end) -- 2804
HttpServer:post("/compiler/failure", function(req) -- 2809
	if not compilerRequested then -- 2810
		return { -- 2810
			success = false -- 2810
		} -- 2810
	end -- 2810
	do -- 2811
		local _type_0 = type(req) -- 2811
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2811
		if _tab_0 then -- 2811
			local message -- 2811
			do -- 2811
				local _obj_0 = req.body -- 2811
				local _type_1 = type(_obj_0) -- 2811
				if "table" == _type_1 or "userdata" == _type_1 then -- 2811
					message = _obj_0.message -- 2811
				end -- 2811
			end -- 2811
			if message ~= nil then -- 2811
				if type(message) == "string" then -- 2812
					compilerFailure = message -- 2813
					compilerReady = false -- 2814
					return { -- 2815
						success = true -- 2815
					} -- 2815
				end -- 2812
			end -- 2811
		end -- 2811
	end -- 2811
	return { -- 2809
		success = false -- 2809
	} -- 2809
end) -- 2809
HttpServer:postSchedule("/compiler/poll", function() -- 2817
	if not compilerRequested then -- 2818
		return { -- 2818
			success = false -- 2818
		} -- 2818
	end -- 2818
	compilerReady = true -- 2819
	local deadline = App.runningTime + 5 -- 2820
	wait(function() -- 2821
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2821
	end) -- 2821
	if not (compilerRequested and not compilerFailure) then -- 2822
		return { -- 2822
			success = false -- 2822
		} -- 2822
	end -- 2822
	local job = table.remove(compilerJobs, 1) -- 2823
	if job then -- 2824
		compilerInFlight[job.id] = true -- 2825
	end -- 2824
	return { -- 2826
		success = true, -- 2826
		job = job -- 2826
	} -- 2826
end) -- 2817
HttpServer:post("/compiler/result", function(req) -- 2828
	do -- 2829
		local _type_0 = type(req) -- 2829
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2829
		if _tab_0 then -- 2829
			local body = req.body -- 2829
			if body ~= nil then -- 2829
				local id = body.id -- 2830
				if not (id and compilerInFlight[id]) then -- 2831
					return { -- 2831
						success = false, -- 2831
						message = "invalid compiler job" -- 2831
					} -- 2831
				end -- 2831
				compilerInFlight[id] = nil -- 2832
				compilerResults[id] = body -- 2833
				return { -- 2834
					success = true -- 2834
				} -- 2834
			end -- 2829
		end -- 2829
	end -- 2829
	return { -- 2828
		success = false -- 2828
	} -- 2828
end) -- 2828
local acquireCompiler -- 2836
acquireCompiler = function() -- 2836
	compilerUsers = compilerUsers + 1 -- 2837
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2838
	if not compilerRequested then -- 2839
		compilerRequested = true -- 2840
		compilerReady = false -- 2841
		compilerFailure = nil -- 2842
		return emit("AppWebView", "/compiler.html", true) -- 2843
	end -- 2839
end -- 2836
local releaseCompiler -- 2845
releaseCompiler = function() -- 2845
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2846
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2847
	if not (compilerUsers == 0) then -- 2848
		return -- 2848
	end -- 2848
	local closeGeneration = compilerCloseGeneration -- 2849
	return thread(function() -- 2850
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2851
		wait(function() -- 2852
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2853
		end) -- 2852
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2858
			compilerRequested = false -- 2859
			compilerReady = false -- 2860
			return emit("AppWebView", "/compiler.html", false) -- 2861
		end -- 2858
	end) -- 2850
end -- 2845
local removeCompilerJob -- 2863
removeCompilerJob = function(id) -- 2863
	for index = #compilerJobs, 1, -1 do -- 2864
		if compilerJobs[index].id == id then -- 2865
			table.remove(compilerJobs, index) -- 2866
		end -- 2865
	end -- 2864
	compilerInFlight[id] = nil -- 2867
	compilerResults[id] = nil -- 2868
end -- 2863
local transpileTSFileWithCompiler -- 2870
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2870
	acquireCompiler() -- 2871
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2872
	wait(function() -- 2873
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2873
	end) -- 2873
	if not compilerReady then -- 2874
		releaseCompiler() -- 2875
		if isCancelled and isCancelled() then -- 2876
			return { -- 2877
				success = false, -- 2877
				file = file, -- 2877
				message = "build canceled", -- 2877
				interrupted = true -- 2877
			} -- 2877
		end -- 2876
		return { -- 2878
			success = false, -- 2878
			file = file, -- 2878
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2878
			failureKind = "tool" -- 2878
		} -- 2878
	end -- 2874
	compilerJobId = compilerJobId + 1 -- 2879
	local jobId = compilerJobId -- 2880
	compilerJobs[#compilerJobs + 1] = { -- 2882
		id = jobId, -- 2882
		file = file, -- 2883
		content = content, -- 2884
		projectRoot = sourceRoot, -- 2885
		files = files -- 2886
	} -- 2881
	local deadline = App.runningTime + compilerBuildTimeout -- 2887
	wait(function() -- 2888
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2888
	end) -- 2888
	local response = compilerResults[jobId] -- 2889
	removeCompilerJob(jobId) -- 2890
	releaseCompiler() -- 2891
	if not response then -- 2892
		if isCancelled and isCancelled() then -- 2893
			return { -- 2894
				success = false, -- 2894
				file = file, -- 2894
				message = "build canceled", -- 2894
				interrupted = true -- 2894
			} -- 2894
		end -- 2893
		return { -- 2895
			success = false, -- 2895
			file = file, -- 2895
			message = compilerFailure or "TypeScript transpile timed out", -- 2895
			failureKind = "tool" -- 2895
		} -- 2895
	end -- 2892
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2896
		local luaFile = Path:replaceExt(file, "lua") -- 2897
		if Content:save(luaFile, response.luaCode) then -- 2898
			return { -- 2899
				success = true, -- 2899
				file = file -- 2899
			} -- 2899
		end -- 2898
		return { -- 2900
			success = false, -- 2900
			file = file, -- 2900
			message = "failed to save " .. tostring(luaFile) -- 2900
		} -- 2900
	end -- 2896
	return { -- 2901
		success = false, -- 2901
		file = file, -- 2901
		message = response.message or "TypeScript transpile failed" -- 2901
	} -- 2901
end -- 2870
local compilerFailureListener = Node() -- 2903
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2904
	compilerFailure = message -- 2905
	compilerReady = false -- 2906
end) -- 2904
local transpileTSFile -- 2908
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2908
	if supportsCompilerWebView() and not files then -- 2909
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2910
	end -- 2909
	if HttpServer.wsConnectionCount > 0 then -- 2911
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2912
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2913
			return result -- 2913
		end -- 2913
		webIDECompilerReady = false -- 2914
	end -- 2911
	if supportsCompilerWebView() then -- 2915
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2916
	end -- 2915
	return { -- 2917
		success = false, -- 2917
		file = file, -- 2917
		message = "Web IDE compiler not connected", -- 2917
		failureKind = "tool" -- 2917
	} -- 2917
end -- 2908
local _anon_func_10 = function(path) -- 2932
	local _val_0 = Path:getExt(path) -- 2932
	return "ts" == _val_0 or "tsx" == _val_0 -- 2932
end -- 2932
HttpServer:postSchedule("/ts/build", function(req) -- 2919
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2920
	local buildSucceeded = false -- 2921
	local _ <close> = setmetatable({ }, { -- 2922
		__close = function() -- 2922
			return finishUpdate(buildSucceeded) -- 2922
		end -- 2922
	}) -- 2922
	do -- 2923
		local _type_0 = type(req) -- 2923
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2923
		if _tab_0 then -- 2923
			local path -- 2923
			do -- 2923
				local _obj_0 = req.body -- 2923
				local _type_1 = type(_obj_0) -- 2923
				if "table" == _type_1 or "userdata" == _type_1 then -- 2923
					path = _obj_0.path -- 2923
				end -- 2923
			end -- 2923
			if path ~= nil then -- 2923
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2924
					return { -- 2925
						success = false, -- 2925
						message = "Web IDE not connected" -- 2925
					} -- 2925
				end -- 2924
				local projectRoot = req.body.projectRoot -- 2926
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2927
				if not Content:exist(path) then -- 2928
					return { -- 2929
						success = false, -- 2929
						message = "path not existed" -- 2929
					} -- 2929
				end -- 2928
				local messages = { } -- 2930
				if not Content:isdir(path) then -- 2931
					if not (_anon_func_10(path)) then -- 2932
						return { -- 2933
							success = false, -- 2933
							message = "expecting a TypeScript file" -- 2933
						} -- 2933
					end -- 2932
					local content = Content:load(path) -- 2934
					if not content then -- 2935
						return { -- 2936
							success = false, -- 2936
							message = "failed to read file" -- 2936
						} -- 2936
					end -- 2935
					emit("AppWS", "Send", json.encode({ -- 2937
						name = "UpdateFile", -- 2937
						file = path, -- 2937
						exists = true, -- 2937
						content = content, -- 2937
						projectRoot = sourceRoot -- 2937
					})) -- 2937
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2938
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2939
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2940
					end -- 2938
				else -- 2942
					local fileData = { } -- 2942
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2943
					for _index_0 = 1, #_list_0 do -- 2943
						local subFile = _list_0[_index_0] -- 2943
						local file = Path(path, subFile) -- 2944
						local content = Content:load(file) -- 2945
						if content then -- 2945
							fileData[file] = content -- 2946
							emit("AppWS", "Send", json.encode({ -- 2947
								name = "UpdateFile", -- 2947
								file = file, -- 2947
								exists = true, -- 2947
								content = content, -- 2947
								projectRoot = sourceRoot -- 2947
							})) -- 2947
						else -- 2949
							messages[#messages + 1] = { -- 2949
								success = false, -- 2949
								file = file, -- 2949
								message = "failed to read file" -- 2949
							} -- 2949
						end -- 2945
					end -- 2943
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2950
					for file, content in pairs(fileData) do -- 2951
						if "d" == Path:getExt(Path:getName(file)) then -- 2952
							goto _continue_0 -- 2952
						end -- 2952
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2953
						::_continue_0:: -- 2952
					end -- 2951
				end -- 2931
				local success = true -- 2954
				for _index_0 = 1, #messages do -- 2955
					local item = messages[_index_0] -- 2955
					if not item.success then -- 2956
						success = false -- 2956
					end -- 2956
				end -- 2955
				local message = nil -- 2957
				if not success then -- 2958
					message = "TypeScript compilation failed" -- 2958
				end -- 2958
				buildSucceeded = success -- 2959
				return { -- 2960
					success = success, -- 2960
					messages = messages, -- 2960
					message = message -- 2960
				} -- 2960
			end -- 2923
		end -- 2923
	end -- 2923
	return { -- 2919
		success = false -- 2919
	} -- 2919
end) -- 2919
HttpServer:post("/download", function(req) -- 2962
	do -- 2963
		local _type_0 = type(req) -- 2963
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2963
		if _tab_0 then -- 2963
			local url -- 2963
			do -- 2963
				local _obj_0 = req.body -- 2963
				local _type_1 = type(_obj_0) -- 2963
				if "table" == _type_1 or "userdata" == _type_1 then -- 2963
					url = _obj_0.url -- 2963
				end -- 2963
			end -- 2963
			local target -- 2963
			do -- 2963
				local _obj_0 = req.body -- 2963
				local _type_1 = type(_obj_0) -- 2963
				if "table" == _type_1 or "userdata" == _type_1 then -- 2963
					target = _obj_0.target -- 2963
				end -- 2963
			end -- 2963
			if url ~= nil and target ~= nil then -- 2963
				local Entry = require("Script.Dev.Entry") -- 2964
				Entry.downloadFile(url, target) -- 2965
				return { -- 2966
					success = true -- 2966
				} -- 2966
			end -- 2963
		end -- 2963
	end -- 2963
	return { -- 2962
		success = false -- 2962
	} -- 2962
end) -- 2962
local isDesktopPlatform -- 2968
isDesktopPlatform = function() -- 2968
	local _val_0 = App.platform -- 2969
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2969
end -- 2968
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 2971
local nativeIDEListener = Node() -- 2972
nativeIDEListener:addTo(Director.systemUI) -- 2973
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 2974
	nativeIDEState, nativeIDEMessage = state, message -- 2975
end) -- 2974
local _anon_func_11 = function() -- 2978
	local _val_0 = App.platform -- 2978
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2978
end -- 2978
HttpServer:post("/ide", function(req) -- 2977
	if not (_anon_func_11()) then -- 2978
		return { -- 2978
			success = false, -- 2978
			message = "Native IDE is unavailable" -- 2978
		} -- 2978
	end -- 2978
	if not App.webIDEEnabled then -- 2979
		return { -- 2979
			success = false, -- 2979
			message = "Embedded Web IDE is disabled" -- 2979
		} -- 2979
	end -- 2979
	do -- 2980
		local _type_0 = type(req) -- 2980
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2980
		if _tab_0 then -- 2980
			local action -- 2980
			do -- 2980
				local _obj_0 = req.body -- 2980
				local _type_1 = type(_obj_0) -- 2980
				if "table" == _type_1 or "userdata" == _type_1 then -- 2980
					action = _obj_0.action -- 2980
				end -- 2980
			end -- 2980
			if action ~= nil then -- 2980
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 2981
					emit("AppWebView", "/ide/" .. action, true) -- 2982
					return { -- 2983
						success = true -- 2983
					} -- 2983
				end -- 2981
			end -- 2980
		end -- 2980
	end -- 2980
	return { -- 2977
		success = false, -- 2977
		message = "invalid IDE action" -- 2977
	} -- 2977
end) -- 2977
local _anon_func_12 = function() -- 2999
	local _val_0 = App.platform -- 2999
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2999
end -- 2999
local getServerStatus -- 2985
getServerStatus = function() -- 2985
	local Entry = require("Script.Dev.Entry") -- 2986
	local running = Entry.getCurrentEntryStatus() -- 2987
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2988
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2989
	return { -- 2991
		success = true, -- 2991
		platform = App.platform, -- 2992
		locale = App.locale, -- 2993
		version = App.version, -- 2994
		url = "http://localhost:8866", -- 2995
		wsConnectionCount = wsConnectionCount, -- 2996
		webIDEConnected = wsConnectionCount > 0, -- 2997
		nativeIDE = { -- 2999
			supported = _anon_func_12(), -- 2999
			enabled = App.webIDEEnabled, -- 3000
			state = nativeIDEState, -- 3001
			message = nativeIDEMessage -- 3002
		}, -- 2998
		typescriptCompiler = { -- 3004
			webIDEReady = webIDECompilerReady, -- 3004
			webIDEGeneration = webIDEConnectionGeneration, -- 3005
			embeddedSupported = supportsCompilerWebView(), -- 3006
			embeddedRequested = compilerRequested, -- 3007
			embeddedReady = compilerReady, -- 3008
			users = compilerUsers, -- 3009
			queuedJobs = #compilerJobs, -- 3010
			failure = compilerFailure -- 3011
		}, -- 3003
		assetPath = Content.assetPath, -- 3012
		writablePath = Content.writablePath, -- 3013
		appPath = Content.appPath, -- 3014
		waTemplateReady = waTemplateReady, -- 3015
		running = running -- 3016
	} -- 2990
end -- 2985
HttpServer:post("/status", function() -- 3019
	return getServerStatus() -- 3020
end) -- 3019
HttpServer:postSchedule("/doctor/fix", function(req) -- 3022
	do -- 3023
		local _type_0 = type(req) -- 3023
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3023
		if _tab_0 then -- 3023
			local openWebIDE -- 3023
			do -- 3023
				local _obj_0 = req.body -- 3023
				local _type_1 = type(_obj_0) -- 3023
				if "table" == _type_1 or "userdata" == _type_1 then -- 3023
					openWebIDE = _obj_0.openWebIDE -- 3023
				end -- 3023
			end -- 3023
			if openWebIDE ~= nil then -- 3023
				if not openWebIDE then -- 3024
					return { -- 3025
						success = false, -- 3025
						message = "nothing to fix" -- 3025
					} -- 3025
				end -- 3024
				local status = getServerStatus() -- 3026
				if status.webIDEConnected then -- 3027
					return { -- 3028
						success = true, -- 3028
						fixed = false, -- 3028
						message = "Web IDE already connected.", -- 3028
						status = status -- 3028
					} -- 3028
				end -- 3027
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 3029
				if waitSeconds > 0 then -- 3030
					local deadline = os.time() + waitSeconds -- 3031
					repeat -- 3032
						sleep(0.2) -- 3033
						status = getServerStatus() -- 3034
						if status.webIDEConnected then -- 3035
							return { -- 3036
								success = true, -- 3036
								fixed = false, -- 3036
								reconnected = true, -- 3036
								message = "Web IDE reconnected.", -- 3036
								status = status -- 3036
							} -- 3036
						end -- 3035
					until os.time() >= deadline -- 3032
				end -- 3030
				if not isDesktopPlatform() then -- 3038
					return { -- 3039
						success = false, -- 3039
						message = "opening Web IDE is only supported on desktop platforms", -- 3039
						status = status -- 3039
					} -- 3039
				end -- 3038
				local url = "http://localhost:8866" -- 3040
				App:openURL(url) -- 3041
				status.openedURL = url -- 3042
				return { -- 3043
					success = true, -- 3043
					fixed = true, -- 3043
					message = "Opened Web IDE in the local browser.", -- 3043
					url = url, -- 3043
					status = status -- 3043
				} -- 3043
			end -- 3023
		end -- 3023
	end -- 3023
	return { -- 3022
		success = false, -- 3022
		message = "invalid call" -- 3022
	} -- 3022
end) -- 3022
local status = { } -- 3045
_module_0 = status -- 3046
status.transpileTSFile = transpileTSFile -- 3048
HttpServer:postSchedule("/godot/project", function(req) -- 3051
	do -- 3052
		local _type_0 = type(req) -- 3052
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3052
		if _tab_0 then -- 3052
			local path -- 3052
			do -- 3052
				local _obj_0 = req.body -- 3052
				local _type_1 = type(_obj_0) -- 3052
				if "table" == _type_1 or "userdata" == _type_1 then -- 3052
					path = _obj_0.path -- 3052
				end -- 3052
			end -- 3052
			if path ~= nil then -- 3052
				if not (type(path) == "string" and Content:isAbsolutePath(path)) then -- 3053
					return invalidArguments -- 3053
				end -- 3053
				local releaseAgent = AgentHost.acquire() -- 3054
				local _ <close> = setmetatable({ }, { -- 3055
					__close = function() -- 3055
						return releaseAgent() -- 3055
					end -- 3055
				}) -- 3055
				local GodotBuild = require("Agent.Tool.GodotBuild") -- 3056
				local project = GodotBuild.findGodotProject(Content.writablePath, path) or GodotBuild.findGodotProject(Content.assetPath, path) -- 3057
				if not project then -- 3058
					return { -- 3058
						success = true, -- 3058
						found = false -- 3058
					} -- 3058
				end -- 3058
				if not (req.body.build == true) then -- 3059
					return { -- 3059
						success = true, -- 3059
						found = true, -- 3059
						projectRoot = project -- 3059
					} -- 3059
				end -- 3059
				local result -- 3060
				local promise = GodotBuild.buildGodotProject(project) -- 3061
				local onFulfilled -- 3062
				onFulfilled = function(_, value) -- 3062
					result = value -- 3063
				end -- 3062
				local onRejected -- 3064
				onRejected = function(_, err) -- 3064
					result = { -- 3065
						success = false, -- 3065
						message = tostring(err) -- 3065
					} -- 3065
				end -- 3064
				promise["then"](promise, onFulfilled, onRejected) -- 3066
				wait(function() -- 3067
					return result ~= nil -- 3067
				end) -- 3067
				result.found = true -- 3068
				result.projectRoot = project -- 3069
				return result -- 3070
			end -- 3052
		end -- 3052
	end -- 3052
	return invalidArguments -- 3051
end) -- 3051
status.buildAsync = function(path) -- 3072
	if not Content:exist(path) then -- 3073
		return { -- 3074
			success = false, -- 3074
			file = path, -- 3074
			message = "file not existed" -- 3074
		} -- 3074
	end -- 3073
	do -- 3075
		local _exp_0 = Path:getExt(path) -- 3075
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 3075
			if '' == Path:getExt(Path:getName(path)) then -- 3076
				local content = Content:loadAsync(path) -- 3077
				if content then -- 3077
					local resultCodes, err = compileFileAsync(path, content) -- 3078
					if resultCodes then -- 3078
						return { -- 3079
							success = true, -- 3079
							file = path -- 3079
						} -- 3079
					else -- 3081
						return { -- 3081
							success = false, -- 3081
							file = path, -- 3081
							message = err -- 3081
						} -- 3081
					end -- 3078
				end -- 3077
			end -- 3076
		elseif "lua" == _exp_0 then -- 3082
			local content = Content:loadAsync(path) -- 3083
			if content then -- 3083
				do -- 3084
					local isTIC80 = CheckTIC80Code(content) -- 3084
					if isTIC80 then -- 3084
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 3085
					end -- 3084
				end -- 3084
				local success, info -- 3086
				do -- 3086
					local _obj_0 = luaCheck(path, content) -- 3086
					success, info = _obj_0.success, _obj_0.info -- 3086
				end -- 3086
				if success then -- 3087
					return { -- 3088
						success = true, -- 3088
						file = path -- 3088
					} -- 3088
				elseif info and #info > 0 then -- 3089
					local messages = { } -- 3090
					for _index_0 = 1, #info do -- 3091
						local _des_0 = info[_index_0] -- 3091
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3091
						local lineText = "" -- 3092
						if line then -- 3093
							local currentLine = 1 -- 3094
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3095
								if currentLine == line then -- 3096
									lineText = text -- 3097
									break -- 3098
								end -- 3096
								currentLine = currentLine + 1 -- 3099
							end -- 3095
						end -- 3093
						if line then -- 3100
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3101
						else -- 3103
							messages[#messages + 1] = message -- 3103
						end -- 3100
					end -- 3091
					return { -- 3104
						success = false, -- 3104
						file = path, -- 3104
						message = table.concat(messages, "\n") -- 3104
					} -- 3104
				else -- 3106
					return { -- 3106
						success = false, -- 3106
						file = path, -- 3106
						message = "lua check failed" -- 3106
					} -- 3106
				end -- 3087
			end -- 3083
		elseif "yarn" == _exp_0 then -- 3107
			local content = Content:loadAsync(path) -- 3108
			if content then -- 3108
				local res, _, err = yarncompile(content, true) -- 3109
				if res then -- 3109
					return { -- 3110
						success = true, -- 3110
						file = path -- 3110
					} -- 3110
				else -- 3112
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3112
					local lineText = "" -- 3113
					if line then -- 3114
						local currentLine = 1 -- 3115
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3116
							if currentLine == line then -- 3117
								lineText = text -- 3118
								break -- 3119
							end -- 3117
							currentLine = currentLine + 1 -- 3120
						end -- 3116
					end -- 3114
					if node ~= "" then -- 3121
						node = "node: " .. tostring(node) .. ", " -- 3122
					else -- 3123
						node = "" -- 3123
					end -- 3121
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3124
					return { -- 3125
						success = false, -- 3125
						file = path, -- 3125
						message = message -- 3125
					} -- 3125
				end -- 3109
			end -- 3108
		end -- 3075
	end -- 3075
	return { -- 3126
		success = false, -- 3126
		file = path, -- 3126
		message = "invalid file to build" -- 3126
	} -- 3126
end -- 3072
HttpServer:postSchedule("/git/commit-files", function(req) -- 3128
	do -- 3129
		local _type_0 = type(req) -- 3129
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3129
		if _tab_0 then -- 3129
			local body = req.body -- 3129
			if body ~= nil then -- 3129
				local repoPath, commit = body.repoPath, body.commit -- 3130
				if gitInvalidRepoPath(repoPath) then -- 3131
					return { -- 3131
						success = false, -- 3131
						message = "invalid repoPath" -- 3131
					} -- 3131
				end -- 3131
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3132
					return { -- 3132
						success = false, -- 3132
						message = "invalid commit" -- 3132
					} -- 3132
				end -- 3132
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3133
				if not res.success then -- 3134
					return res -- 3134
				end -- 3134
				return { -- 3135
					success = true, -- 3135
					status = res.status, -- 3135
					data = res.status and res.status.data -- 3135
				} -- 3135
			end -- 3129
		end -- 3129
	end -- 3129
	return invalidArguments -- 3128
end) -- 3128
thread(function() -- 3137
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3138
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3139
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3140
		local storedAsset -- 3143
		storedAsset = function(file) -- 3143
			if Content:exist(file) then -- 3144
				return Content:load(file) -- 3145
			elseif Content:exist(file .. ".gz") then -- 3146
				return Content:load(file .. ".gz") -- 3147
			else -- 3148
				return "" -- 3148
			end -- 3144
		end -- 3143
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3149
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3150
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3151
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3152
		local readyContent = table.concat({ -- 3154
			App.version, -- 3154
			storedAsset(doraWeb), -- 3155
			storedAsset(heavyAssets), -- 3156
			storedAsset(runtimeIndex), -- 3157
			storedAsset(compilerIndex), -- 3158
			storedAsset(manifest) -- 3159
		}, "\n") -- 3153
		local needReload -- 3161
		if Content:exist(doraReady) then -- 3161
			needReload = readyContent ~= Content:load(doraReady) -- 3162
		else -- 3163
			needReload = true -- 3163
		end -- 3161
		if needReload then -- 3164
			Content:remove(Path(Content.appPath, ".www")) -- 3165
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3166
			Content:save(doraReady, readyContent) -- 3170
			print("Dora Dora is ready!") -- 3171
		end -- 3164
	end -- 3140
	if App.platform == "Emscripten" then -- 3172
		status.url = nil -- 3173
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3174
	end -- 3172
	HttpServer:clearStaticCacheControls() -- 3175
	HttpServer:setStaticCacheControl("no-cache") -- 3176
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3177
	if HttpServer:start(8866) then -- 3181
		local localIP = HttpServer.localIP -- 3182
		if localIP == "" then -- 3183
			localIP = "localhost" -- 3183
		end -- 3183
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3184
		return HttpServer:startWS(8868) -- 3185
	else -- 3187
		status.url = nil -- 3187
		return print("8866 Port not available!") -- 3188
	end -- 3181
end) -- 3137
return _module_0 -- 1
