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
HttpServer:postSchedule("/check", function(req) -- 1023
	do -- 1024
		local _type_0 = type(req) -- 1024
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1024
		if _tab_0 then -- 1024
			local file -- 1024
			do -- 1024
				local _obj_0 = req.body -- 1024
				local _type_1 = type(_obj_0) -- 1024
				if "table" == _type_1 or "userdata" == _type_1 then -- 1024
					file = _obj_0.file -- 1024
				end -- 1024
			end -- 1024
			local content -- 1024
			do -- 1024
				local _obj_0 = req.body -- 1024
				local _type_1 = type(_obj_0) -- 1024
				if "table" == _type_1 or "userdata" == _type_1 then -- 1024
					content = _obj_0.content -- 1024
				end -- 1024
			end -- 1024
			if file ~= nil and content ~= nil then -- 1024
				local ext = Path:getExt(file) -- 1025
				if "tl" == ext then -- 1026
					local searchPath = getSearchPath(file) -- 1027
					do -- 1028
						local isTIC80 = CheckTIC80Code(content) -- 1028
						if isTIC80 then -- 1028
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1029
						end -- 1028
					end -- 1028
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 1030
					return { -- 1031
						success = success, -- 1031
						info = info -- 1031
					} -- 1031
				elseif "lua" == ext then -- 1032
					do -- 1033
						local isTIC80 = CheckTIC80Code(content) -- 1033
						if isTIC80 then -- 1033
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1034
						end -- 1033
					end -- 1033
					return luaCheck(file, content) -- 1035
				elseif "yue" == ext then -- 1036
					local luaCodes, info = yueCheck(file, content, false) -- 1037
					local success = luaCodes ~= nil -- 1038
					if luaCodes then -- 1039
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 1040
						do -- 1041
							local _tab_1 = { } -- 1041
							local _idx_0 = #_tab_1 + 1 -- 1041
							for _index_0 = 1, #info do -- 1041
								local _value_0 = info[_index_0] -- 1041
								_tab_1[_idx_0] = _value_0 -- 1041
								_idx_0 = _idx_0 + 1 -- 1041
							end -- 1041
							local _idx_1 = #_tab_1 + 1 -- 1041
							for _index_0 = 1, #luaInfo do -- 1041
								local _value_0 = luaInfo[_index_0] -- 1041
								_tab_1[_idx_1] = _value_0 -- 1041
								_idx_1 = _idx_1 + 1 -- 1041
							end -- 1041
							info = _tab_1 -- 1041
						end -- 1041
						success = success and luaSuccess -- 1042
					end -- 1039
					if #info > 0 then -- 1043
						return { -- 1044
							success = success, -- 1044
							info = info -- 1044
						} -- 1044
					else -- 1046
						return { -- 1046
							success = success -- 1046
						} -- 1046
					end -- 1043
				elseif "xml" == ext then -- 1047
					local success, result = xml.check(content) -- 1048
					if success then -- 1049
						local info -- 1050
						success, info = luaCheckWithLineInfo(file, result) -- 1050
						if #info > 0 then -- 1051
							return { -- 1052
								success = success, -- 1052
								info = info -- 1052
							} -- 1052
						else -- 1054
							return { -- 1054
								success = success -- 1054
							} -- 1054
						end -- 1051
					else -- 1056
						local info -- 1056
						do -- 1056
							local _accum_0 = { } -- 1056
							local _len_0 = 1 -- 1056
							for _index_0 = 1, #result do -- 1056
								local _des_0 = result[_index_0] -- 1056
								local row, err = _des_0[1], _des_0[2] -- 1056
								_accum_0[_len_0] = { -- 1057
									"syntax", -- 1057
									file, -- 1057
									row, -- 1057
									0, -- 1057
									err -- 1057
								} -- 1057
								_len_0 = _len_0 + 1 -- 1057
							end -- 1056
							info = _accum_0 -- 1056
						end -- 1056
						return { -- 1058
							success = false, -- 1058
							info = info -- 1058
						} -- 1058
					end -- 1049
				end -- 1026
			end -- 1024
		end -- 1024
	end -- 1024
	return { -- 1023
		success = true -- 1023
	} -- 1023
end) -- 1023
HttpServer:post("/body/parse", function(req) -- 1060
	do -- 1061
		local _type_0 = type(req) -- 1061
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1061
		if _tab_0 then -- 1061
			local file -- 1061
			do -- 1061
				local _obj_0 = req.body -- 1061
				local _type_1 = type(_obj_0) -- 1061
				if "table" == _type_1 or "userdata" == _type_1 then -- 1061
					file = _obj_0.file -- 1061
				end -- 1061
			end -- 1061
			local content -- 1061
			do -- 1061
				local _obj_0 = req.body -- 1061
				local _type_1 = type(_obj_0) -- 1061
				if "table" == _type_1 or "userdata" == _type_1 then -- 1061
					content = _obj_0.content -- 1061
				end -- 1061
			end -- 1061
			if file ~= nil and content ~= nil then -- 1061
				if not (file:sub(-6) == ".b.lua") then -- 1062
					return { -- 1063
						success = false, -- 1063
						phase = "request", -- 1063
						message = "only .b.lua files can be converted" -- 1063
					} -- 1063
				end -- 1062
				local loader, err = load("_ENV = {}\n" .. content) -- 1064
				if not loader then -- 1065
					return { -- 1066
						success = false, -- 1066
						phase = "parse", -- 1066
						message = tostring(err) -- 1066
					} -- 1066
				end -- 1065
				local ok, data = pcall(loader) -- 1067
				if not ok then -- 1068
					return { -- 1069
						success = false, -- 1069
						phase = "execute", -- 1069
						message = tostring(data) -- 1069
					} -- 1069
				end -- 1068
				if not ("table" == type(data) and data[1] == "Array") then -- 1070
					return { -- 1071
						success = false, -- 1071
						phase = "validate", -- 1071
						message = "body lua root must be {\"Array\", ...}" -- 1071
					} -- 1071
				end -- 1070
				local text, jsonErr = json.encode(data, false, true) -- 1072
				if not text then -- 1073
					return { -- 1074
						success = false, -- 1074
						phase = "encode", -- 1074
						message = tostring(jsonErr) -- 1074
					} -- 1074
				end -- 1073
				return { -- 1075
					success = true, -- 1075
					json = text -- 1075
				} -- 1075
			end -- 1061
		end -- 1061
	end -- 1061
	return { -- 1060
		success = false, -- 1060
		phase = "request", -- 1060
		message = "invalid request" -- 1060
	} -- 1060
end) -- 1060
local updateInferedDesc -- 1077
updateInferedDesc = function(infered) -- 1077
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1078
		return -- 1078
	end -- 1078
	local key, row = infered.key, infered.row -- 1079
	local codes = Content:loadAsync(key) -- 1080
	if codes then -- 1080
		local comments = { } -- 1081
		local line = 0 -- 1082
		local skipping = false -- 1083
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1084
			line = line + 1 -- 1085
			if line >= row then -- 1086
				break -- 1086
			end -- 1086
			if lineCode:match("^%s*%-%- @") then -- 1087
				skipping = true -- 1088
				goto _continue_0 -- 1089
			end -- 1087
			local result = lineCode:match("^%s*%-%- (.+)") -- 1090
			if result then -- 1090
				if not skipping then -- 1091
					comments[#comments + 1] = result -- 1091
				end -- 1091
			elseif #comments > 0 then -- 1092
				comments = { } -- 1093
				skipping = false -- 1094
			end -- 1090
			::_continue_0:: -- 1085
		end -- 1084
		infered.doc = table.concat(comments, "\n") -- 1095
	end -- 1080
end -- 1077
HttpServer:postSchedule("/infer", function(req) -- 1097
	do -- 1098
		local _type_0 = type(req) -- 1098
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1098
		if _tab_0 then -- 1098
			local lang -- 1098
			do -- 1098
				local _obj_0 = req.body -- 1098
				local _type_1 = type(_obj_0) -- 1098
				if "table" == _type_1 or "userdata" == _type_1 then -- 1098
					lang = _obj_0.lang -- 1098
				end -- 1098
			end -- 1098
			local file -- 1098
			do -- 1098
				local _obj_0 = req.body -- 1098
				local _type_1 = type(_obj_0) -- 1098
				if "table" == _type_1 or "userdata" == _type_1 then -- 1098
					file = _obj_0.file -- 1098
				end -- 1098
			end -- 1098
			local content -- 1098
			do -- 1098
				local _obj_0 = req.body -- 1098
				local _type_1 = type(_obj_0) -- 1098
				if "table" == _type_1 or "userdata" == _type_1 then -- 1098
					content = _obj_0.content -- 1098
				end -- 1098
			end -- 1098
			local line -- 1098
			do -- 1098
				local _obj_0 = req.body -- 1098
				local _type_1 = type(_obj_0) -- 1098
				if "table" == _type_1 or "userdata" == _type_1 then -- 1098
					line = _obj_0.line -- 1098
				end -- 1098
			end -- 1098
			local row -- 1098
			do -- 1098
				local _obj_0 = req.body -- 1098
				local _type_1 = type(_obj_0) -- 1098
				if "table" == _type_1 or "userdata" == _type_1 then -- 1098
					row = _obj_0.row -- 1098
				end -- 1098
			end -- 1098
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1098
				local searchPath = getSearchPath(file) -- 1099
				if "tl" == lang or "lua" == lang then -- 1100
					if CheckTIC80Code(content) then -- 1101
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1102
					end -- 1101
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1103
					if (infered ~= nil) then -- 1104
						updateInferedDesc(infered) -- 1105
						return { -- 1106
							success = true, -- 1106
							infered = infered -- 1106
						} -- 1106
					end -- 1104
				elseif "yue" == lang then -- 1107
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1108
					if not luaCodes then -- 1109
						return { -- 1109
							success = false -- 1109
						} -- 1109
					end -- 1109
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1110
					if (infered ~= nil) then -- 1111
						local col -- 1112
						file, row, col = infered.file, infered.row, infered.col -- 1112
						if file == "" and row > 0 and col > 0 then -- 1113
							infered.row = lineMap[row] or 0 -- 1114
							infered.col = 0 -- 1115
						end -- 1113
						updateInferedDesc(infered) -- 1116
						return { -- 1117
							success = true, -- 1117
							infered = infered -- 1117
						} -- 1117
					end -- 1111
				end -- 1100
			end -- 1098
		end -- 1098
	end -- 1098
	return { -- 1097
		success = false -- 1097
	} -- 1097
end) -- 1097
local _anon_func_3 = function(doc) -- 1178
	local _accum_0 = { } -- 1178
	local _len_0 = 1 -- 1178
	local _list_0 = doc.params -- 1178
	for _index_0 = 1, #_list_0 do -- 1178
		local param = _list_0[_index_0] -- 1178
		_accum_0[_len_0] = param.name -- 1178
		_len_0 = _len_0 + 1 -- 1178
	end -- 1178
	return _accum_0 -- 1178
end -- 1178
local getParamDocs -- 1119
getParamDocs = function(signatures) -- 1119
	if not (signatures and #signatures > 0) then -- 1120
		return nil -- 1120
	end -- 1120
	local docs = { } -- 1121
	do -- 1122
		local codes = Content:loadAsync(signatures[1].file) -- 1122
		if codes then -- 1122
			local comments = { } -- 1123
			local params = { } -- 1124
			local line = 0 -- 1125
			local returnType = nil -- 1126
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1127
				line = line + 1 -- 1128
				local needBreak = true -- 1129
				for i, _des_0 in ipairs(signatures) do -- 1130
					local row = _des_0.row -- 1130
					if line >= row and not (docs[i] ~= nil) then -- 1131
						if #comments > 0 or #params > 0 or returnType then -- 1132
							docs[i] = { -- 1134
								doc = table.concat(comments, "  \n"), -- 1134
								returnType = returnType -- 1135
							} -- 1133
							if #params > 0 then -- 1137
								docs[i].params = params -- 1137
							end -- 1137
						else -- 1139
							docs[i] = false -- 1139
						end -- 1132
					end -- 1131
					if not docs[i] then -- 1140
						needBreak = false -- 1140
					end -- 1140
				end -- 1130
				if needBreak then -- 1141
					break -- 1141
				end -- 1141
				local result = lineCode:match("%s*%-%- (.+)") -- 1142
				if result then -- 1142
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1143
					if not name then -- 1144
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1145
					end -- 1144
					if name then -- 1146
						local pname = name -- 1147
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1148
							pname = pname .. "?" -- 1148
						end -- 1148
						params[#params + 1] = { -- 1150
							name = tostring(pname) .. ": " .. tostring(typ), -- 1150
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1151
						} -- 1149
					else -- 1154
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1154
						if typ then -- 1154
							if returnType then -- 1155
								returnType = returnType .. ", " .. typ -- 1156
							else -- 1158
								returnType = typ -- 1158
							end -- 1155
							result = result:gsub("@return", "**return:**") -- 1159
						end -- 1154
						comments[#comments + 1] = result -- 1160
					end -- 1146
				elseif #comments > 0 then -- 1161
					comments = { } -- 1162
					params = { } -- 1163
					returnType = nil -- 1164
				end -- 1142
			end -- 1127
		end -- 1122
	end -- 1122
	local results = { } -- 1165
	for i, signature in ipairs(signatures) do -- 1166
		local item = { -- 1168
			desc = signature.desc, -- 1168
			doc = "", -- 1169
			file = signature.file, -- 1170
			row = signature.row, -- 1171
			col = signature.col -- 1172
		} -- 1167
		do -- 1174
			local doc = docs[i] -- 1174
			if doc then -- 1174
				item.doc = doc.doc -- 1175
				if doc.params then -- 1176
					item.params = doc.params -- 1177
					item.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1178
				elseif doc.returnType then -- 1179
					item.desc = "function()" -- 1180
				end -- 1176
				if doc.returnType then -- 1181
					item.desc = item.desc .. ": " .. tostring(doc.returnType) -- 1181
				end -- 1181
			end -- 1174
		end -- 1174
		results[#results + 1] = item -- 1182
	end -- 1166
	return results -- 1183
end -- 1119
HttpServer:postSchedule("/signature", function(req) -- 1185
	do -- 1186
		local _type_0 = type(req) -- 1186
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1186
		if _tab_0 then -- 1186
			local lang -- 1186
			do -- 1186
				local _obj_0 = req.body -- 1186
				local _type_1 = type(_obj_0) -- 1186
				if "table" == _type_1 or "userdata" == _type_1 then -- 1186
					lang = _obj_0.lang -- 1186
				end -- 1186
			end -- 1186
			local file -- 1186
			do -- 1186
				local _obj_0 = req.body -- 1186
				local _type_1 = type(_obj_0) -- 1186
				if "table" == _type_1 or "userdata" == _type_1 then -- 1186
					file = _obj_0.file -- 1186
				end -- 1186
			end -- 1186
			local content -- 1186
			do -- 1186
				local _obj_0 = req.body -- 1186
				local _type_1 = type(_obj_0) -- 1186
				if "table" == _type_1 or "userdata" == _type_1 then -- 1186
					content = _obj_0.content -- 1186
				end -- 1186
			end -- 1186
			local line -- 1186
			do -- 1186
				local _obj_0 = req.body -- 1186
				local _type_1 = type(_obj_0) -- 1186
				if "table" == _type_1 or "userdata" == _type_1 then -- 1186
					line = _obj_0.line -- 1186
				end -- 1186
			end -- 1186
			local row -- 1186
			do -- 1186
				local _obj_0 = req.body -- 1186
				local _type_1 = type(_obj_0) -- 1186
				if "table" == _type_1 or "userdata" == _type_1 then -- 1186
					row = _obj_0.row -- 1186
				end -- 1186
			end -- 1186
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1186
				local searchPath = getSearchPath(file) -- 1187
				if "tl" == lang or "lua" == lang then -- 1188
					if CheckTIC80Code(content) then -- 1189
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1190
					end -- 1189
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1191
					if signatures then -- 1191
						signatures = getParamDocs(signatures) -- 1192
						if signatures then -- 1192
							return { -- 1193
								success = true, -- 1193
								signatures = signatures -- 1193
							} -- 1193
						end -- 1192
					end -- 1191
				elseif "yue" == lang then -- 1194
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1195
					if not luaCodes then -- 1196
						return { -- 1196
							success = false -- 1196
						} -- 1196
					end -- 1196
					do -- 1197
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1197
						if chainOp then -- 1197
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1198
							if withVar then -- 1198
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1199
							end -- 1198
						end -- 1197
					end -- 1197
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1200
					if signatures then -- 1200
						signatures = getParamDocs(signatures) -- 1201
						if signatures then -- 1201
							return { -- 1202
								success = true, -- 1202
								signatures = signatures -- 1202
							} -- 1202
						end -- 1201
					else -- 1203
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1203
						if signatures then -- 1203
							signatures = getParamDocs(signatures) -- 1204
							if signatures then -- 1204
								return { -- 1205
									success = true, -- 1205
									signatures = signatures -- 1205
								} -- 1205
							end -- 1204
						end -- 1203
					end -- 1200
				end -- 1188
			end -- 1186
		end -- 1186
	end -- 1186
	return { -- 1185
		success = false -- 1185
	} -- 1185
end) -- 1185
local luaKeywords = { -- 1208
	'and', -- 1208
	'break', -- 1209
	'do', -- 1210
	'else', -- 1211
	'elseif', -- 1212
	'end', -- 1213
	'false', -- 1214
	'for', -- 1215
	'function', -- 1216
	'goto', -- 1217
	'if', -- 1218
	'in', -- 1219
	'local', -- 1220
	'nil', -- 1221
	'not', -- 1222
	'or', -- 1223
	'repeat', -- 1224
	'return', -- 1225
	'then', -- 1226
	'true', -- 1227
	'until', -- 1228
	'while' -- 1229
} -- 1207
local tealKeywords = { -- 1233
	'record', -- 1233
	'as', -- 1234
	'is', -- 1235
	'type', -- 1236
	'embed', -- 1237
	'enum', -- 1238
	'global', -- 1239
	'any', -- 1240
	'boolean', -- 1241
	'integer', -- 1242
	'number', -- 1243
	'string', -- 1244
	'thread' -- 1245
} -- 1232
local yueKeywords = { -- 1249
	"and", -- 1249
	"break", -- 1250
	"do", -- 1251
	"else", -- 1252
	"elseif", -- 1253
	"false", -- 1254
	"for", -- 1255
	"goto", -- 1256
	"if", -- 1257
	"in", -- 1258
	"local", -- 1259
	"nil", -- 1260
	"not", -- 1261
	"or", -- 1262
	"repeat", -- 1263
	"return", -- 1264
	"then", -- 1265
	"true", -- 1266
	"until", -- 1267
	"while", -- 1268
	"as", -- 1269
	"class", -- 1270
	"continue", -- 1271
	"export", -- 1272
	"extends", -- 1273
	"from", -- 1274
	"global", -- 1275
	"import", -- 1276
	"macro", -- 1277
	"switch", -- 1278
	"try", -- 1279
	"unless", -- 1280
	"using", -- 1281
	"when", -- 1282
	"with" -- 1283
} -- 1248
local _anon_func_4 = function(f) -- 1319
	local _val_0 = Path:getExt(f) -- 1319
	return "ttf" == _val_0 or "otf" == _val_0 -- 1319
end -- 1319
local _anon_func_5 = function(suggestions) -- 1345
	local _tbl_0 = { } -- 1345
	for _index_0 = 1, #suggestions do -- 1345
		local item = suggestions[_index_0] -- 1345
		_tbl_0[item[1] .. item[2]] = item -- 1345
	end -- 1345
	return _tbl_0 -- 1345
end -- 1345
HttpServer:postSchedule("/complete", function(req) -- 1286
	do -- 1287
		local _type_0 = type(req) -- 1287
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1287
		if _tab_0 then -- 1287
			local lang -- 1287
			do -- 1287
				local _obj_0 = req.body -- 1287
				local _type_1 = type(_obj_0) -- 1287
				if "table" == _type_1 or "userdata" == _type_1 then -- 1287
					lang = _obj_0.lang -- 1287
				end -- 1287
			end -- 1287
			local file -- 1287
			do -- 1287
				local _obj_0 = req.body -- 1287
				local _type_1 = type(_obj_0) -- 1287
				if "table" == _type_1 or "userdata" == _type_1 then -- 1287
					file = _obj_0.file -- 1287
				end -- 1287
			end -- 1287
			local content -- 1287
			do -- 1287
				local _obj_0 = req.body -- 1287
				local _type_1 = type(_obj_0) -- 1287
				if "table" == _type_1 or "userdata" == _type_1 then -- 1287
					content = _obj_0.content -- 1287
				end -- 1287
			end -- 1287
			local line -- 1287
			do -- 1287
				local _obj_0 = req.body -- 1287
				local _type_1 = type(_obj_0) -- 1287
				if "table" == _type_1 or "userdata" == _type_1 then -- 1287
					line = _obj_0.line -- 1287
				end -- 1287
			end -- 1287
			local row -- 1287
			do -- 1287
				local _obj_0 = req.body -- 1287
				local _type_1 = type(_obj_0) -- 1287
				if "table" == _type_1 or "userdata" == _type_1 then -- 1287
					row = _obj_0.row -- 1287
				end -- 1287
			end -- 1287
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1287
				local searchPath = getSearchPath(file) -- 1288
				repeat -- 1289
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1290
					if lang == "yue" then -- 1291
						if not item then -- 1292
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1292
						end -- 1292
						if not item then -- 1293
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1293
						end -- 1293
					end -- 1291
					local searchType = nil -- 1294
					if not item then -- 1295
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1296
						if lang == "yue" then -- 1297
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1298
						end -- 1297
						if (item ~= nil) then -- 1299
							searchType = "Image" -- 1299
						end -- 1299
					end -- 1295
					if not item then -- 1300
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1301
						if lang == "yue" then -- 1302
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1303
						end -- 1302
						if (item ~= nil) then -- 1304
							searchType = "Font" -- 1304
						end -- 1304
					end -- 1300
					if not item then -- 1305
						break -- 1305
					end -- 1305
					local searchPaths = Content.searchPaths -- 1306
					local _list_0 = getSearchFolders(file) -- 1307
					for _index_0 = 1, #_list_0 do -- 1307
						local folder = _list_0[_index_0] -- 1307
						searchPaths[#searchPaths + 1] = folder -- 1308
					end -- 1307
					if searchType then -- 1309
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1309
					end -- 1309
					local tokens -- 1310
					do -- 1310
						local _accum_0 = { } -- 1310
						local _len_0 = 1 -- 1310
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1310
							_accum_0[_len_0] = mod -- 1310
							_len_0 = _len_0 + 1 -- 1310
						end -- 1310
						tokens = _accum_0 -- 1310
					end -- 1310
					local suggestions = { } -- 1311
					for _index_0 = 1, #searchPaths do -- 1312
						local path = searchPaths[_index_0] -- 1312
						local sPath = Path(path, table.unpack(tokens)) -- 1313
						if not Content:exist(sPath) then -- 1314
							goto _continue_0 -- 1314
						end -- 1314
						if searchType == "Font" then -- 1315
							local fontPath = Path(sPath, "Font") -- 1316
							if Content:exist(fontPath) then -- 1317
								local _list_1 = Content:getFiles(fontPath) -- 1318
								for _index_1 = 1, #_list_1 do -- 1318
									local f = _list_1[_index_1] -- 1318
									if _anon_func_4(f) then -- 1319
										if "." == f:sub(1, 1) then -- 1320
											goto _continue_1 -- 1320
										end -- 1320
										suggestions[#suggestions + 1] = { -- 1321
											Path:getName(f), -- 1321
											"font", -- 1321
											"field" -- 1321
										} -- 1321
									end -- 1319
									::_continue_1:: -- 1319
								end -- 1318
							end -- 1317
						end -- 1315
						local _list_1 = Content:getFiles(sPath) -- 1322
						for _index_1 = 1, #_list_1 do -- 1322
							local f = _list_1[_index_1] -- 1322
							if "Image" == searchType then -- 1323
								do -- 1324
									local _exp_0 = Path:getExt(f) -- 1324
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1324
										if "." == f:sub(1, 1) then -- 1325
											goto _continue_2 -- 1325
										end -- 1325
										suggestions[#suggestions + 1] = { -- 1326
											f, -- 1326
											"image", -- 1326
											"field" -- 1326
										} -- 1326
									end -- 1324
								end -- 1324
								goto _continue_2 -- 1327
							elseif "Font" == searchType then -- 1328
								do -- 1329
									local _exp_0 = Path:getExt(f) -- 1329
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1329
										if "." == f:sub(1, 1) then -- 1330
											goto _continue_2 -- 1330
										end -- 1330
										suggestions[#suggestions + 1] = { -- 1331
											f, -- 1331
											"font", -- 1331
											"field" -- 1331
										} -- 1331
									end -- 1329
								end -- 1329
								goto _continue_2 -- 1332
							end -- 1323
							local _exp_0 = Path:getExt(f) -- 1333
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1333
								local name = Path:getName(f) -- 1334
								if "d" == Path:getExt(name) then -- 1335
									goto _continue_2 -- 1335
								end -- 1335
								if "." == name:sub(1, 1) then -- 1336
									goto _continue_2 -- 1336
								end -- 1336
								suggestions[#suggestions + 1] = { -- 1337
									name, -- 1337
									"module", -- 1337
									"field" -- 1337
								} -- 1337
							end -- 1333
							::_continue_2:: -- 1323
						end -- 1322
						local _list_2 = Content:getDirs(sPath) -- 1338
						for _index_1 = 1, #_list_2 do -- 1338
							local dir = _list_2[_index_1] -- 1338
							if "." == dir:sub(1, 1) then -- 1339
								goto _continue_3 -- 1339
							end -- 1339
							suggestions[#suggestions + 1] = { -- 1340
								dir, -- 1340
								"folder", -- 1340
								"variable" -- 1340
							} -- 1340
							::_continue_3:: -- 1339
						end -- 1338
						::_continue_0:: -- 1313
					end -- 1312
					if item == "" and not searchType then -- 1341
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1342
						for _index_0 = 1, #_list_1 do -- 1342
							local _des_0 = _list_1[_index_0] -- 1342
							local name = _des_0[1] -- 1342
							suggestions[#suggestions + 1] = { -- 1343
								name, -- 1343
								"dora module", -- 1343
								"function" -- 1343
							} -- 1343
						end -- 1342
					end -- 1341
					if #suggestions > 0 then -- 1344
						do -- 1345
							local _accum_0 = { } -- 1345
							local _len_0 = 1 -- 1345
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1345
								_accum_0[_len_0] = v -- 1345
								_len_0 = _len_0 + 1 -- 1345
							end -- 1345
							suggestions = _accum_0 -- 1345
						end -- 1345
						return { -- 1346
							success = true, -- 1346
							suggestions = suggestions -- 1346
						} -- 1346
					else -- 1348
						return { -- 1348
							success = false -- 1348
						} -- 1348
					end -- 1344
				until true -- 1289
				if "tl" == lang or "lua" == lang then -- 1350
					do -- 1351
						local isTIC80 = CheckTIC80Code(content) -- 1351
						if isTIC80 then -- 1351
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1352
						end -- 1351
					end -- 1351
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1353
					if not line:match("[%.:]$") then -- 1354
						local checkSet -- 1355
						do -- 1355
							local _tbl_0 = { } -- 1355
							for _index_0 = 1, #suggestions do -- 1355
								local _des_0 = suggestions[_index_0] -- 1355
								local name = _des_0[1] -- 1355
								_tbl_0[name] = true -- 1355
							end -- 1355
							checkSet = _tbl_0 -- 1355
						end -- 1355
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1356
						for _index_0 = 1, #_list_0 do -- 1356
							local item = _list_0[_index_0] -- 1356
							if not checkSet[item[1]] then -- 1357
								suggestions[#suggestions + 1] = item -- 1357
							end -- 1357
						end -- 1356
						for _index_0 = 1, #luaKeywords do -- 1358
							local word = luaKeywords[_index_0] -- 1358
							suggestions[#suggestions + 1] = { -- 1359
								word, -- 1359
								"keyword", -- 1359
								"keyword" -- 1359
							} -- 1359
						end -- 1358
						if lang == "tl" then -- 1360
							for _index_0 = 1, #tealKeywords do -- 1361
								local word = tealKeywords[_index_0] -- 1361
								suggestions[#suggestions + 1] = { -- 1362
									word, -- 1362
									"keyword", -- 1362
									"keyword" -- 1362
								} -- 1362
							end -- 1361
						end -- 1360
					end -- 1354
					if #suggestions > 0 then -- 1363
						return { -- 1364
							success = true, -- 1364
							suggestions = suggestions -- 1364
						} -- 1364
					end -- 1363
				elseif "yue" == lang then -- 1365
					local suggestions = { } -- 1366
					local gotGlobals = false -- 1367
					do -- 1368
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1368
						if luaCodes then -- 1368
							gotGlobals = true -- 1369
							do -- 1370
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1370
								if chainOp then -- 1370
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1371
									if not withVar then -- 1372
										return { -- 1372
											success = false -- 1372
										} -- 1372
									end -- 1372
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1373
								elseif line:match("^([%.\\])$") then -- 1374
									return { -- 1375
										success = false -- 1375
									} -- 1375
								end -- 1370
							end -- 1370
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1376
							for _index_0 = 1, #_list_0 do -- 1376
								local item = _list_0[_index_0] -- 1376
								suggestions[#suggestions + 1] = item -- 1376
							end -- 1376
							if #suggestions == 0 then -- 1377
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1378
								for _index_0 = 1, #_list_1 do -- 1378
									local item = _list_1[_index_0] -- 1378
									suggestions[#suggestions + 1] = item -- 1378
								end -- 1378
							end -- 1377
						end -- 1368
					end -- 1368
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1379
						local checkSet -- 1380
						do -- 1380
							local _tbl_0 = { } -- 1380
							for _index_0 = 1, #suggestions do -- 1380
								local _des_0 = suggestions[_index_0] -- 1380
								local name = _des_0[1] -- 1380
								_tbl_0[name] = true -- 1380
							end -- 1380
							checkSet = _tbl_0 -- 1380
						end -- 1380
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1381
						for _index_0 = 1, #_list_0 do -- 1381
							local item = _list_0[_index_0] -- 1381
							if not checkSet[item[1]] then -- 1382
								suggestions[#suggestions + 1] = item -- 1382
							end -- 1382
						end -- 1381
						if not gotGlobals then -- 1383
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1384
							for _index_0 = 1, #_list_1 do -- 1384
								local item = _list_1[_index_0] -- 1384
								if not checkSet[item[1]] then -- 1385
									suggestions[#suggestions + 1] = item -- 1385
								end -- 1385
							end -- 1384
						end -- 1383
						for _index_0 = 1, #yueKeywords do -- 1386
							local word = yueKeywords[_index_0] -- 1386
							if not checkSet[word] then -- 1387
								suggestions[#suggestions + 1] = { -- 1388
									word, -- 1388
									"keyword", -- 1388
									"keyword" -- 1388
								} -- 1388
							end -- 1387
						end -- 1386
					end -- 1379
					if #suggestions > 0 then -- 1389
						return { -- 1390
							success = true, -- 1390
							suggestions = suggestions -- 1390
						} -- 1390
					end -- 1389
				elseif "xml" == lang then -- 1391
					local items = xml.complete(content) -- 1392
					if #items > 0 then -- 1393
						local suggestions -- 1394
						do -- 1394
							local _accum_0 = { } -- 1394
							local _len_0 = 1 -- 1394
							for _index_0 = 1, #items do -- 1394
								local _des_0 = items[_index_0] -- 1394
								local label, insertText = _des_0[1], _des_0[2] -- 1394
								_accum_0[_len_0] = { -- 1395
									label, -- 1395
									insertText, -- 1395
									"field" -- 1395
								} -- 1395
								_len_0 = _len_0 + 1 -- 1395
							end -- 1394
							suggestions = _accum_0 -- 1394
						end -- 1394
						return { -- 1396
							success = true, -- 1396
							suggestions = suggestions -- 1396
						} -- 1396
					end -- 1393
				end -- 1350
			end -- 1287
		end -- 1287
	end -- 1287
	return { -- 1286
		success = false -- 1286
	} -- 1286
end) -- 1286
local getUploadFilename -- 1398
getUploadFilename = function(req, multipartFilename) -- 1398
	local filename = req.params.name -- 1399
	if not (type(filename) == "string" and filename ~= "") then -- 1400
		filename = multipartFilename -- 1400
	end -- 1400
	if not (type(filename) == "string" and filename ~= "") then -- 1401
		return -- 1401
	end -- 1401
	if filename:sub(1, 1) == "/" or filename:sub(-1) == "/" or filename:find("//", 1, true) or filename:find("\\", 1, true) or filename:find(":", 1, true) or filename:find("\0", 1, true) then -- 1404
		return -- 1404
	end -- 1404
	local parts -- 1405
	do -- 1405
		local _accum_0 = { } -- 1405
		local _len_0 = 1 -- 1405
		for part in filename:gmatch("[^/]+") do -- 1405
			_accum_0[_len_0] = part -- 1405
			_len_0 = _len_0 + 1 -- 1405
		end -- 1405
		parts = _accum_0 -- 1405
	end -- 1405
	if #parts == 0 then -- 1406
		return -- 1406
	end -- 1406
	for _index_0 = 1, #parts do -- 1407
		local part = parts[_index_0] -- 1407
		if part == "." or part == ".." or part == "" then -- 1408
			return -- 1408
		end -- 1408
	end -- 1407
	return filename -- 1409
end -- 1398
HttpServer:upload("/upload", function(req, multipartFilename) -- 1413
	do -- 1414
		local _type_0 = type(req) -- 1414
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1414
		if _tab_0 then -- 1414
			local path -- 1414
			do -- 1414
				local _obj_0 = req.params -- 1414
				local _type_1 = type(_obj_0) -- 1414
				if "table" == _type_1 or "userdata" == _type_1 then -- 1414
					path = _obj_0.path -- 1414
				end -- 1414
			end -- 1414
			if path ~= nil then -- 1414
				local filename = getUploadFilename(req, multipartFilename) -- 1415
				if filename then -- 1415
					local uploadPath = Path(Content.writablePath, ".upload", "files") -- 1416
					if not Content:exist(uploadPath) then -- 1417
						Content:mkdir(uploadPath) -- 1418
					end -- 1417
					local targetPath = Path(uploadPath, filename) -- 1419
					Content:mkdir(Path:getPath(targetPath)) -- 1420
					return targetPath -- 1421
				end -- 1415
			end -- 1414
		end -- 1414
	end -- 1414
	return nil -- 1413
end, function(req, file) -- 1422
	do -- 1423
		local _type_0 = type(req) -- 1423
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1423
		if _tab_0 then -- 1423
			local path -- 1423
			do -- 1423
				local _obj_0 = req.params -- 1423
				local _type_1 = type(_obj_0) -- 1423
				if "table" == _type_1 or "userdata" == _type_1 then -- 1423
					path = _obj_0.path -- 1423
				end -- 1423
			end -- 1423
			if path ~= nil then -- 1423
				path = Path(Content.writablePath, path) -- 1424
				if Content:exist(path) then -- 1425
					local uploadPath = Path(Content.writablePath, ".upload", "files") -- 1426
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1427
					Content:mkdir(Path:getPath(targetPath)) -- 1428
					if Content:move(file, targetPath) then -- 1429
						return true -- 1430
					end -- 1429
				end -- 1425
			end -- 1423
		end -- 1423
	end -- 1423
	return false -- 1422
end) -- 1411
HttpServer:post("/list", function(req) -- 1433
	do -- 1434
		local _type_0 = type(req) -- 1434
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1434
		if _tab_0 then -- 1434
			local path -- 1434
			do -- 1434
				local _obj_0 = req.body -- 1434
				local _type_1 = type(_obj_0) -- 1434
				if "table" == _type_1 or "userdata" == _type_1 then -- 1434
					path = _obj_0.path -- 1434
				end -- 1434
			end -- 1434
			if path ~= nil then -- 1434
				if Content:exist(path) then -- 1435
					local files = { } -- 1436
					local visitAssets -- 1437
					visitAssets = function(path, folder) -- 1437
						local dirs = Content:getDirs(path) -- 1438
						for _index_0 = 1, #dirs do -- 1439
							local dir = dirs[_index_0] -- 1439
							if dir:match("^%.") or dir == "node_modules" then -- 1440
								goto _continue_0 -- 1440
							end -- 1440
							local current -- 1441
							if folder == "" then -- 1441
								current = dir -- 1442
							else -- 1444
								current = Path(folder, dir) -- 1444
							end -- 1441
							files[#files + 1] = current -- 1445
							visitAssets(Path(path, dir), current) -- 1446
							::_continue_0:: -- 1440
						end -- 1439
						local fs = Content:getFiles(path) -- 1447
						for _index_0 = 1, #fs do -- 1448
							local f = fs[_index_0] -- 1448
							if (".DS_Store" == f) then -- 1449
								goto _continue_1 -- 1450
							end -- 1449
							if folder == "" then -- 1451
								files[#files + 1] = f -- 1452
							else -- 1454
								files[#files + 1] = Path(folder, f) -- 1454
							end -- 1451
							::_continue_1:: -- 1449
						end -- 1448
					end -- 1437
					visitAssets(path, "") -- 1455
					if #files == 0 then -- 1456
						files = nil -- 1456
					end -- 1456
					return { -- 1457
						success = true, -- 1457
						files = files -- 1457
					} -- 1457
				end -- 1435
			end -- 1434
		end -- 1434
	end -- 1434
	return { -- 1433
		success = false -- 1433
	} -- 1433
end) -- 1433
HttpServer:post("/info", function(req) -- 1459
	local Entry = require("Script.Dev.Entry") -- 1460
	local config = Entry.getConfig() -- 1461
	do -- 1462
		local _type_0 = type(req) -- 1462
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1462
		if _tab_0 then -- 1462
			local webIDETourCompleted -- 1462
			do -- 1462
				local _obj_0 = req.body -- 1462
				local _type_1 = type(_obj_0) -- 1462
				if "table" == _type_1 or "userdata" == _type_1 then -- 1462
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1462
				end -- 1462
			end -- 1462
			if webIDETourCompleted ~= nil then -- 1462
				config.webIDETourCompleted = webIDETourCompleted == true -- 1463
			end -- 1462
		end -- 1462
	end -- 1462
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1464
	local engineDev = Entry.getEngineDev() -- 1465
	Entry.connectWebIDE(req.body and req.body.embedded == true) -- 1466
	return { -- 1468
		platform = App.platform, -- 1468
		locale = App.locale, -- 1469
		version = App.version, -- 1470
		engineDev = engineDev, -- 1471
		webProfiler = webProfiler, -- 1472
		drawerWidth = drawerWidth, -- 1473
		webIDETourCompleted = webIDETourCompleted == true -- 1474
	} -- 1467
end) -- 1459
local ensureLLMConfigTable -- 1476
ensureLLMConfigTable = function() -- 1476
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1477
	if columns and #columns > 0 then -- 1478
		local expected = { -- 1480
			id = true, -- 1480
			name = true, -- 1481
			url = true, -- 1482
			model = true, -- 1483
			api_key = true, -- 1484
			context_window = true, -- 1485
			temperature = true, -- 1486
			max_tokens = true, -- 1487
			reasoning_effort = true, -- 1488
			custom_options = true, -- 1489
			supports_function_calling = true, -- 1490
			active = true, -- 1491
			created_at = true, -- 1492
			updated_at = true -- 1493
		} -- 1479
		local existing = { } -- 1495
		local valid = true -- 1496
		for _index_0 = 1, #columns do -- 1497
			local row = columns[_index_0] -- 1497
			local columnName = tostring(row[2]) -- 1498
			existing[columnName] = true -- 1499
			if not expected[columnName] then -- 1500
				valid = false -- 1501
				break -- 1502
			end -- 1500
		end -- 1497
		if valid then -- 1503
			if not existing.context_window then -- 1504
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1505
			end -- 1504
			if not existing.temperature then -- 1506
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1507
			end -- 1506
			if not existing.max_tokens then -- 1508
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 64000") -- 1509
			end -- 1508
			if not existing.reasoning_effort then -- 1510
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1511
			end -- 1510
			if not existing.custom_options then -- 1512
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1513
			end -- 1512
			if not existing.supports_function_calling then -- 1514
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1515
			end -- 1514
		else -- 1517
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1517
		end -- 1503
	end -- 1478
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
	]]) -- 1518
	require("Agent.Config.LLMConfigMigration").upgradeLLMConfig() -- 1537
	return require("Agent.Config.LLMConfigNames").upgradeLLMConfigNames() -- 1538
end -- 1476
local normalizeContextWindow -- 1540
normalizeContextWindow = function(value) -- 1540
	local contextWindow = tonumber(value) -- 1541
	if contextWindow == nil or contextWindow < 64000 then -- 1542
		return 64000 -- 1543
	end -- 1542
	return math.max(64000, math.floor(contextWindow)) -- 1544
end -- 1540
local normalizeTemperature -- 1546
normalizeTemperature = function(value) -- 1546
	local temperature = tonumber(value) -- 1547
	if temperature == nil then -- 1548
		return 0.1 -- 1549
	end -- 1548
	return math.max(0, math.min(2, temperature)) -- 1550
end -- 1546
local normalizeMaxTokens -- 1552
normalizeMaxTokens = function(value) -- 1552
	local maxTokens = tonumber(value) -- 1553
	if maxTokens == nil or maxTokens < 1 then -- 1554
		return 64000 -- 1555
	end -- 1554
	return math.max(1, math.floor(maxTokens)) -- 1556
end -- 1552
local normalizeReasoningEffort -- 1558
normalizeReasoningEffort = function(value) -- 1558
	if value == nil then -- 1559
		return "" -- 1560
	end -- 1559
	local effort = tostring(value) -- 1561
	return effort:match("^%s*(.-)%s*$") or "" -- 1562
end -- 1558
local normalizeCustomOptions -- 1564
normalizeCustomOptions = function(value) -- 1564
	if value == nil then -- 1565
		return "" -- 1566
	end -- 1565
	local options = tostring(value) -- 1567
	options = options:match("^%s*(.-)%s*$") or "" -- 1568
	return options -- 1569
end -- 1564
local validateCustomOptions -- 1571
validateCustomOptions = function(value) -- 1571
	local options = normalizeCustomOptions(value) -- 1572
	if options == "" then -- 1573
		return true -- 1573
	end -- 1573
	if not options:match("^%s*{") then -- 1574
		return false -- 1574
	end -- 1574
	local decoded = json.decode(options) -- 1575
	return type(decoded) == "table" -- 1576
end -- 1571
HttpServer:post("/llm/list", function() -- 1578
	ensureLLMConfigTable() -- 1579
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1580
	local items -- 1584
	if rows and #rows > 0 then -- 1584
		local _accum_0 = { } -- 1585
		local _len_0 = 1 -- 1585
		for _index_0 = 1, #rows do -- 1585
			local _des_0 = rows[_index_0] -- 1585
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1585
			_accum_0[_len_0] = { -- 1586
				id = id, -- 1586
				name = name, -- 1586
				url = url, -- 1586
				model = model, -- 1586
				key = key, -- 1586
				contextWindow = normalizeContextWindow(contextWindow), -- 1586
				temperature = normalizeTemperature(temperature), -- 1586
				maxTokens = normalizeMaxTokens(maxTokens), -- 1586
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1586
				customOptions = normalizeCustomOptions(customOptions), -- 1586
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1586
			} -- 1586
			_len_0 = _len_0 + 1 -- 1586
		end -- 1585
		items = _accum_0 -- 1584
	end -- 1584
	return { -- 1587
		success = true, -- 1587
		items = items -- 1587
	} -- 1587
end) -- 1578
HttpServer:post("/llm/create", function(req) -- 1589
	ensureLLMConfigTable() -- 1590
	do -- 1591
		local _type_0 = type(req) -- 1591
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1591
		if _tab_0 then -- 1591
			local body = req.body -- 1591
			if body ~= nil then -- 1591
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1592
				local now = os.time() -- 1593
				if name == nil or url == nil or model == nil or key == nil then -- 1594
					return invalidArguments -- 1595
				end -- 1594
				local names = require("Agent.Config.LLMConfigNames") -- 1596
				name = names.normalizeLLMConfigName(name) -- 1597
				if not name then -- 1598
					return { -- 1598
						success = false, -- 1598
						code = "INVALID_LLM_CONFIG_NAME", -- 1598
						message = "LLM configuration name must be a non-empty string" -- 1598
					} -- 1598
				end -- 1598
				local nameCheck = names.checkLLMConfigName(name) -- 1599
				if not nameCheck.success then -- 1600
					return nameCheck -- 1600
				end -- 1600
				contextWindow = normalizeContextWindow(contextWindow) -- 1601
				temperature = normalizeTemperature(temperature) -- 1602
				maxTokens = normalizeMaxTokens(maxTokens) -- 1603
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1604
				customOptions = normalizeCustomOptions(customOptions) -- 1605
				if not validateCustomOptions(customOptions) then -- 1606
					return { -- 1606
						success = false, -- 1606
						message = "customOptions must be a JSON object" -- 1606
					} -- 1606
				end -- 1606
				if supportsFunctionCalling == false then -- 1607
					supportsFunctionCalling = 0 -- 1607
				else -- 1607
					supportsFunctionCalling = 1 -- 1607
				end -- 1607
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1614
					tostring(name), -- 1614
					tostring(url), -- 1615
					tostring(model), -- 1616
					tostring(key), -- 1617
					contextWindow, -- 1618
					temperature, -- 1619
					maxTokens, -- 1620
					reasoningEffort, -- 1621
					customOptions, -- 1622
					supportsFunctionCalling, -- 1623
					1, -- 1624
					now, -- 1625
					now -- 1626
				}) -- 1608
				if affected < 0 then -- 1628
					nameCheck = names.checkLLMConfigName(name) -- 1629
					if not nameCheck.success then -- 1630
						return nameCheck -- 1630
					end -- 1630
				end -- 1628
				return { -- 1631
					success = affected > 0 -- 1631
				} -- 1631
			end -- 1591
		end -- 1591
	end -- 1591
	return invalidArguments -- 1589
end) -- 1589
HttpServer:post("/llm/update", function(req) -- 1633
	ensureLLMConfigTable() -- 1634
	do -- 1635
		local _type_0 = type(req) -- 1635
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1635
		if _tab_0 then -- 1635
			local body = req.body -- 1635
			if body ~= nil then -- 1635
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1636
				local now = os.time() -- 1637
				id = tonumber(id) -- 1638
				if id == nil or id <= 0 or id ~= math.floor(id) then -- 1639
					return invalidArguments -- 1639
				end -- 1639
				local names = require("Agent.Config.LLMConfigNames") -- 1640
				name = names.normalizeLLMConfigName(name) -- 1641
				if not name then -- 1642
					return { -- 1642
						success = false, -- 1642
						code = "INVALID_LLM_CONFIG_NAME", -- 1642
						message = "LLM configuration name must be a non-empty string" -- 1642
					} -- 1642
				end -- 1642
				local nameCheck = names.checkLLMConfigName(name, id) -- 1643
				if not nameCheck.success then -- 1644
					return nameCheck -- 1644
				end -- 1644
				contextWindow = normalizeContextWindow(contextWindow) -- 1645
				temperature = normalizeTemperature(temperature) -- 1646
				maxTokens = normalizeMaxTokens(maxTokens) -- 1647
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1648
				customOptions = normalizeCustomOptions(customOptions) -- 1649
				if not validateCustomOptions(customOptions) then -- 1650
					return { -- 1650
						success = false, -- 1650
						message = "customOptions must be a JSON object" -- 1650
					} -- 1650
				end -- 1650
				if supportsFunctionCalling == false then -- 1651
					supportsFunctionCalling = 0 -- 1651
				else -- 1651
					supportsFunctionCalling = 1 -- 1651
				end -- 1651
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1656
					tostring(name), -- 1656
					tostring(url), -- 1657
					tostring(model), -- 1658
					tostring(key), -- 1659
					contextWindow, -- 1660
					temperature, -- 1661
					maxTokens, -- 1662
					reasoningEffort, -- 1663
					customOptions, -- 1664
					supportsFunctionCalling, -- 1665
					now, -- 1666
					id -- 1667
				}) -- 1652
				if affected < 0 then -- 1669
					nameCheck = names.checkLLMConfigName(name, id) -- 1670
					if not nameCheck.success then -- 1671
						return nameCheck -- 1671
					end -- 1671
				end -- 1669
				return { -- 1672
					success = affected > 0 -- 1672
				} -- 1672
			end -- 1635
		end -- 1635
	end -- 1635
	return invalidArguments -- 1633
end) -- 1633
HttpServer:post("/llm/delete", function(req) -- 1674
	ensureLLMConfigTable() -- 1675
	do -- 1676
		local _type_0 = type(req) -- 1676
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1676
		if _tab_0 then -- 1676
			local id -- 1676
			do -- 1676
				local _obj_0 = req.body -- 1676
				local _type_1 = type(_obj_0) -- 1676
				if "table" == _type_1 or "userdata" == _type_1 then -- 1676
					id = _obj_0.id -- 1676
				end -- 1676
			end -- 1676
			if id ~= nil then -- 1676
				id = tonumber(id) -- 1677
				if id == nil then -- 1678
					return invalidArguments -- 1678
				end -- 1678
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1679
					id -- 1679
				}) -- 1679
				return { -- 1680
					success = affected >= 0 -- 1680
				} -- 1680
			end -- 1676
		end -- 1676
	end -- 1676
	return invalidArguments -- 1674
end) -- 1674
HttpServer:post("/local-agent/list", function() -- 1682
	return { -- 1683
		success = true, -- 1683
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1683
		items = AgentLocalAgent.listConfigs() -- 1683
	} -- 1683
end) -- 1682
HttpServer:post("/local-agent/save", function(req) -- 1685
	do -- 1686
		local _type_0 = type(req) -- 1686
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1686
		if _tab_0 then -- 1686
			local body = req.body -- 1686
			if body ~= nil then -- 1686
				return AgentLocalAgent.saveConfig(body) -- 1687
			end -- 1686
		end -- 1686
	end -- 1686
	return invalidArguments -- 1685
end) -- 1685
HttpServer:post("/local-agent/delete", function(req) -- 1689
	do -- 1690
		local _type_0 = type(req) -- 1690
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1690
		if _tab_0 then -- 1690
			local id -- 1690
			do -- 1690
				local _obj_0 = req.body -- 1690
				local _type_1 = type(_obj_0) -- 1690
				if "table" == _type_1 or "userdata" == _type_1 then -- 1690
					id = _obj_0.id -- 1690
				end -- 1690
			end -- 1690
			if id ~= nil then -- 1690
				return AgentLocalAgent.deleteConfig(id) -- 1691
			end -- 1690
		end -- 1690
	end -- 1690
	return invalidArguments -- 1689
end) -- 1689
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1693
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
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1695
			end -- 1694
		end -- 1694
	end -- 1694
	return invalidArguments -- 1693
end) -- 1693
HttpServer:post("/stat", function(req) -- 1697
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
				if not Content:exist(path) then -- 1699
					return { -- 1700
						success = false, -- 1700
						message = "target not existed" -- 1700
					} -- 1700
				end -- 1699
				if Content:isdir(path) then -- 1701
					return { -- 1702
						success = false, -- 1702
						message = "failed to stat a directory" -- 1702
					} -- 1702
				end -- 1701
				local size, isBinary = Content:getAttr(path) -- 1703
				if size then -- 1703
					return { -- 1704
						success = true, -- 1704
						size = size, -- 1704
						isBinary = isBinary -- 1704
					} -- 1704
				end -- 1703
			end -- 1698
		end -- 1698
	end -- 1698
	return { -- 1697
		success = false, -- 1697
		message = "failed to stat" -- 1697
	} -- 1697
end) -- 1697
HttpServer:post("/new", function(req) -- 1706
	do -- 1707
		local _type_0 = type(req) -- 1707
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1707
		if _tab_0 then -- 1707
			local path -- 1707
			do -- 1707
				local _obj_0 = req.body -- 1707
				local _type_1 = type(_obj_0) -- 1707
				if "table" == _type_1 or "userdata" == _type_1 then -- 1707
					path = _obj_0.path -- 1707
				end -- 1707
			end -- 1707
			local content -- 1707
			do -- 1707
				local _obj_0 = req.body -- 1707
				local _type_1 = type(_obj_0) -- 1707
				if "table" == _type_1 or "userdata" == _type_1 then -- 1707
					content = _obj_0.content -- 1707
				end -- 1707
			end -- 1707
			local folder -- 1707
			do -- 1707
				local _obj_0 = req.body -- 1707
				local _type_1 = type(_obj_0) -- 1707
				if "table" == _type_1 or "userdata" == _type_1 then -- 1707
					folder = _obj_0.folder -- 1707
				end -- 1707
			end -- 1707
			if path ~= nil and content ~= nil and folder ~= nil then -- 1707
				if Content:exist(path) then -- 1708
					return { -- 1709
						success = false, -- 1709
						message = "TargetExisted" -- 1709
					} -- 1709
				end -- 1708
				local parent = Path:getPath(path) -- 1710
				local files = Content:getFiles(parent) -- 1711
				if folder then -- 1712
					local name = Path:getFilename(path):lower() -- 1713
					for _index_0 = 1, #files do -- 1714
						local file = files[_index_0] -- 1714
						if name == Path:getFilename(file):lower() then -- 1715
							return { -- 1716
								success = false, -- 1716
								message = "TargetExisted" -- 1716
							} -- 1716
						end -- 1715
					end -- 1714
					if Content:mkdir(path) then -- 1717
						return { -- 1718
							success = true -- 1718
						} -- 1718
					end -- 1717
				else -- 1720
					local name = Path:getName(path):lower() -- 1720
					for _index_0 = 1, #files do -- 1721
						local file = files[_index_0] -- 1721
						if name == Path:getName(file):lower() then -- 1722
							local ext = Path:getExt(file) -- 1723
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1724
								goto _continue_0 -- 1725
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1726
								goto _continue_0 -- 1727
							end -- 1724
							return { -- 1728
								success = false, -- 1728
								message = "SourceExisted" -- 1728
							} -- 1728
						end -- 1722
						::_continue_0:: -- 1722
					end -- 1721
					if Content:save(path, content) then -- 1729
						return { -- 1730
							success = true -- 1730
						} -- 1730
					end -- 1729
				end -- 1712
			end -- 1707
		end -- 1707
	end -- 1707
	return { -- 1706
		success = false, -- 1706
		message = "Failed" -- 1706
	} -- 1706
end) -- 1706
local deleteAsset -- 1732
deleteAsset = function(path) -- 1732
	if not Content:exist(path) then -- 1733
		return false -- 1733
	end -- 1733
	local projectRoot -- 1734
	if Content:isdir(path) and isProjectRootDir(path) then -- 1734
		projectRoot = path -- 1734
	else -- 1734
		projectRoot = nil -- 1734
	end -- 1734
	local parent = Path:getPath(path) -- 1735
	local files = Content:getFiles(parent) -- 1736
	local name = Path:getName(path):lower() -- 1737
	local ext = Path:getExt(path) -- 1738
	for _index_0 = 1, #files do -- 1739
		local file = files[_index_0] -- 1739
		if name == Path:getName(file):lower() then -- 1740
			local _exp_0 = Path:getExt(file) -- 1741
			if "tl" == _exp_0 then -- 1741
				if ("vs" == ext) then -- 1741
					Content:remove(Path(parent, file)) -- 1742
				end -- 1741
			elseif "lua" == _exp_0 then -- 1743
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1743
					Content:remove(Path(parent, file)) -- 1744
				end -- 1743
			end -- 1741
		end -- 1740
	end -- 1739
	if Content:remove(path) then -- 1745
		if projectRoot then -- 1746
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1747
		end -- 1746
		return true -- 1748
	end -- 1745
	return false -- 1749
end -- 1732
local moveAsset -- 1751
moveAsset = function(old, new) -- 1751
	if not (Content:exist(old) and not Content:exist(new)) then -- 1752
		return false -- 1752
	end -- 1752
	local renamedDir = Content:isdir(old) -- 1753
	local parent = Path:getPath(new) -- 1754
	local files = Content:getFiles(parent) -- 1755
	if renamedDir then -- 1756
		local name = Path:getFilename(new):lower() -- 1757
		for _index_0 = 1, #files do -- 1758
			local file = files[_index_0] -- 1758
			if name == Path:getFilename(file):lower() then -- 1759
				return false -- 1760
			end -- 1759
		end -- 1758
	else -- 1762
		local name = Path:getName(new):lower() -- 1762
		local ext = Path:getExt(new) -- 1763
		for _index_0 = 1, #files do -- 1764
			local file = files[_index_0] -- 1764
			if name == Path:getName(file):lower() then -- 1765
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1766
					goto _continue_0 -- 1767
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1768
					goto _continue_0 -- 1769
				end -- 1766
				return false -- 1770
			end -- 1765
			::_continue_0:: -- 1765
		end -- 1764
	end -- 1756
	if not Content:move(old, new) then -- 1771
		return false -- 1771
	end -- 1771
	if renamedDir then -- 1772
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1773
	end -- 1772
	local newParent = Path:getPath(new) -- 1774
	parent = Path:getPath(old) -- 1775
	files = Content:getFiles(parent) -- 1776
	local newName = Path:getName(new) -- 1777
	local oldName = Path:getName(old) -- 1778
	local name = oldName:lower() -- 1779
	local ext = Path:getExt(old) -- 1780
	for _index_0 = 1, #files do -- 1781
		local file = files[_index_0] -- 1781
		if name == Path:getName(file):lower() then -- 1782
			local _exp_0 = Path:getExt(file) -- 1783
			if "tl" == _exp_0 then -- 1783
				if ("vs" == ext) then -- 1783
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1784
				end -- 1783
			elseif "lua" == _exp_0 then -- 1785
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1785
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1786
				end -- 1785
			end -- 1783
		end -- 1782
	end -- 1781
	return true -- 1787
end -- 1751
HttpServer:post("/delete", function(req) -- 1789
	do -- 1790
		local _type_0 = type(req) -- 1790
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1790
		if _tab_0 then -- 1790
			local path -- 1790
			do -- 1790
				local _obj_0 = req.body -- 1790
				local _type_1 = type(_obj_0) -- 1790
				if "table" == _type_1 or "userdata" == _type_1 then -- 1790
					path = _obj_0.path -- 1790
				end -- 1790
			end -- 1790
			if path ~= nil then -- 1790
				if deleteAsset(path) then -- 1791
					return { -- 1791
						success = true -- 1791
					} -- 1791
				end -- 1791
			end -- 1790
		end -- 1790
	end -- 1790
	return { -- 1789
		success = false -- 1789
	} -- 1789
end) -- 1789
HttpServer:post("/rename", function(req) -- 1793
	do -- 1794
		local _type_0 = type(req) -- 1794
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1794
		if _tab_0 then -- 1794
			local old -- 1794
			do -- 1794
				local _obj_0 = req.body -- 1794
				local _type_1 = type(_obj_0) -- 1794
				if "table" == _type_1 or "userdata" == _type_1 then -- 1794
					old = _obj_0.old -- 1794
				end -- 1794
			end -- 1794
			local new -- 1794
			do -- 1794
				local _obj_0 = req.body -- 1794
				local _type_1 = type(_obj_0) -- 1794
				if "table" == _type_1 or "userdata" == _type_1 then -- 1794
					new = _obj_0.new -- 1794
				end -- 1794
			end -- 1794
			if old ~= nil and new ~= nil then -- 1794
				if moveAsset(old, new) then -- 1795
					return { -- 1795
						success = true -- 1795
					} -- 1795
				end -- 1795
			end -- 1794
		end -- 1794
	end -- 1794
	return { -- 1793
		success = false -- 1793
	} -- 1793
end) -- 1793
local normalizeAssetPaths -- 1797
normalizeAssetPaths = function(paths) -- 1797
	if not (type(paths) == "table") then -- 1798
		return nil -- 1798
	end -- 1798
	local unique = { } -- 1799
	local candidates = { } -- 1800
	for _index_0 = 1, #paths do -- 1801
		local path = paths[_index_0] -- 1801
		if not (type(path) == "string") then -- 1802
			return nil -- 1802
		end -- 1802
		local relative = relativeToRoot(path, Content.writablePath) -- 1803
		if relative == nil or relative == "" or not Content:exist(path) then -- 1804
			return nil -- 1804
		end -- 1804
		if not unique[path] then -- 1805
			unique[path] = true -- 1806
			candidates[#candidates + 1] = path -- 1807
		end -- 1805
	end -- 1801
	table.sort(candidates, function(a, b) -- 1808
		return #a < #b -- 1808
	end) -- 1808
	local result = { } -- 1809
	for _index_0 = 1, #candidates do -- 1810
		local path = candidates[_index_0] -- 1810
		local contained = false -- 1811
		for _index_1 = 1, #result do -- 1812
			local parent = result[_index_1] -- 1812
			if relativeToRoot(path, parent) ~= nil then -- 1813
				contained = true -- 1814
				break -- 1815
			end -- 1813
		end -- 1812
		if not contained then -- 1816
			result[#result + 1] = path -- 1816
		end -- 1816
	end -- 1810
	return result -- 1817
end -- 1797
HttpServer:postSchedule("/assets/batch", function(req) -- 1819
	do -- 1820
		local _type_0 = type(req) -- 1820
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1820
		if _tab_0 then -- 1820
			local operation -- 1820
			do -- 1820
				local _obj_0 = req.body -- 1820
				local _type_1 = type(_obj_0) -- 1820
				if "table" == _type_1 or "userdata" == _type_1 then -- 1820
					operation = _obj_0.operation -- 1820
				end -- 1820
			end -- 1820
			local sources -- 1820
			do -- 1820
				local _obj_0 = req.body -- 1820
				local _type_1 = type(_obj_0) -- 1820
				if "table" == _type_1 or "userdata" == _type_1 then -- 1820
					sources = _obj_0.sources -- 1820
				end -- 1820
			end -- 1820
			if operation ~= nil and sources ~= nil then -- 1820
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1821
					return { -- 1821
						success = false, -- 1821
						message = "invalid operation" -- 1821
					} -- 1821
				end -- 1821
				sources = normalizeAssetPaths(sources) -- 1822
				if not (sources and #sources > 0) then -- 1823
					return { -- 1823
						success = false, -- 1823
						message = "invalid sources" -- 1823
					} -- 1823
				end -- 1823
				local target = req.body.target -- 1824
				local destinations = { } -- 1825
				if operation ~= "delete" then -- 1826
					if not (type(target) == "string") then -- 1827
						return { -- 1827
							success = false, -- 1827
							message = "invalid target" -- 1827
						} -- 1827
					end -- 1827
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1828
					if targetRelative == nil then -- 1829
						return { -- 1829
							success = false, -- 1829
							message = "invalid target" -- 1829
						} -- 1829
					end -- 1829
					if not (Content:exist(target) and Content:isdir(target)) then -- 1830
						return { -- 1830
							success = false, -- 1830
							message = "invalid target" -- 1830
						} -- 1830
					end -- 1830
					for _index_0 = 1, #sources do -- 1831
						local source = sources[_index_0] -- 1831
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1832
							return { -- 1833
								success = false, -- 1833
								message = "target inside source" -- 1833
							} -- 1833
						end -- 1832
						local destination = Path(target, Path:getFilename(source)) -- 1834
						if Content:exist(destination) then -- 1835
							return { -- 1835
								success = false, -- 1835
								message = "target existed" -- 1835
							} -- 1835
						end -- 1835
						if destinations[destination] then -- 1836
							return { -- 1836
								success = false, -- 1836
								message = "duplicate target" -- 1836
							} -- 1836
						end -- 1836
						destinations[destination] = true -- 1837
					end -- 1831
				end -- 1826
				local changes = { } -- 1838
				local affectedSet = { } -- 1839
				local affectedDirectories = { } -- 1840
				local addAffected -- 1841
				addAffected = function(dir) -- 1841
					if affectedSet[dir] then -- 1842
						return -- 1842
					end -- 1842
					affectedSet[dir] = true -- 1843
					affectedDirectories[#affectedDirectories + 1] = dir -- 1844
				end -- 1841
				if operation ~= "delete" then -- 1845
					addAffected(target) -- 1845
				end -- 1845
				for _index_0 = 1, #sources do -- 1846
					local source = sources[_index_0] -- 1846
					addAffected(Path:getPath(source)) -- 1847
					if operation == "delete" then -- 1848
						if not deleteAsset(source) then -- 1849
							return { -- 1849
								success = false, -- 1849
								message = "delete failed", -- 1849
								changes = changes, -- 1849
								affectedDirectories = affectedDirectories -- 1849
							} -- 1849
						end -- 1849
						changes[#changes + 1] = { -- 1850
							old = source -- 1850
						} -- 1850
					else -- 1852
						local destination = Path(target, Path:getFilename(source)) -- 1852
						local ok -- 1853
						if operation == "copy" then -- 1853
							ok = Content:copyAsync(source, destination) -- 1854
						else -- 1856
							ok = moveAsset(source, destination) -- 1856
						end -- 1853
						if not ok then -- 1857
							return { -- 1857
								success = false, -- 1857
								message = operation .. " failed", -- 1857
								changes = changes, -- 1857
								affectedDirectories = affectedDirectories -- 1857
							} -- 1857
						end -- 1857
						changes[#changes + 1] = { -- 1858
							old = source, -- 1858
							new = destination -- 1858
						} -- 1858
					end -- 1848
				end -- 1846
				return { -- 1859
					success = true, -- 1859
					changes = changes, -- 1859
					affectedDirectories = affectedDirectories -- 1859
				} -- 1859
			end -- 1820
		end -- 1820
	end -- 1820
	return { -- 1819
		success = false, -- 1819
		message = "invalid request" -- 1819
	} -- 1819
end) -- 1819
local withProjectSearchPaths -- 1861
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1861
	local fallbackPaths = { } -- 1862
	local addFallback -- 1863
	addFallback = function(dir) -- 1863
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1863
			fallbackPaths[#fallbackPaths + 1] = dir -- 1863
		end -- 1863
	end -- 1863
	if projectRoot and projectRoot ~= "" then -- 1864
		addFallback(Path(projectRoot, "Script")) -- 1865
		addFallback(projectRoot) -- 1866
	end -- 1864
	if projFile then -- 1867
		local projDir = getProjectDirFromFile(projFile) -- 1868
		if projDir then -- 1868
			addFallback(Path(projDir, "Script")) -- 1869
			addFallback(projDir) -- 1870
		else -- 1872
			addFallback(Path:getPath(projFile)) -- 1872
		end -- 1868
	end -- 1867
	if not (#fallbackPaths > 0) then -- 1873
		return fn() -- 1873
	end -- 1873
	local searchPaths = Content.searchPaths -- 1874
	for _index_0 = 1, #fallbackPaths do -- 1875
		local dir = fallbackPaths[_index_0] -- 1875
		Content:addSearchPath(dir) -- 1875
	end -- 1875
	local _ <close> = setmetatable({ }, { -- 1876
		__close = function() -- 1876
			Content.searchPaths = searchPaths -- 1876
		end -- 1876
	}) -- 1876
	return fn() -- 1877
end -- 1861
HttpServer:post("/exist", function(req) -- 1878
	do -- 1879
		local _type_0 = type(req) -- 1879
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1879
		if _tab_0 then -- 1879
			local file -- 1879
			do -- 1879
				local _obj_0 = req.body -- 1879
				local _type_1 = type(_obj_0) -- 1879
				if "table" == _type_1 or "userdata" == _type_1 then -- 1879
					file = _obj_0.file -- 1879
				end -- 1879
			end -- 1879
			if file ~= nil then -- 1879
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1880
					return { -- 1881
						success = Content:exist(file) -- 1881
					} -- 1881
				end) -- 1880
			end -- 1879
		end -- 1879
	end -- 1879
	return { -- 1878
		success = false -- 1878
	} -- 1878
end) -- 1878
HttpServer:postSchedule("/read", function(req) -- 1882
	do -- 1883
		local _type_0 = type(req) -- 1883
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1883
		if _tab_0 then -- 1883
			local path -- 1883
			do -- 1883
				local _obj_0 = req.body -- 1883
				local _type_1 = type(_obj_0) -- 1883
				if "table" == _type_1 or "userdata" == _type_1 then -- 1883
					path = _obj_0.path -- 1883
				end -- 1883
			end -- 1883
			if path ~= nil then -- 1883
				local readFile -- 1884
				readFile = function() -- 1884
					if Content:exist(path) and not Content:isdir(path) then -- 1885
						local content = Content:loadAsync(path) -- 1886
						if content then -- 1886
							return { -- 1887
								content = content, -- 1887
								success = true, -- 1887
								fullPath = Content:getFullPath(path) -- 1887
							} -- 1887
						end -- 1886
					end -- 1885
					return nil -- 1884
				end -- 1884
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1888
				if result then -- 1888
					return result -- 1888
				end -- 1888
			end -- 1883
		end -- 1883
	end -- 1883
	return { -- 1882
		success = false -- 1882
	} -- 1882
end) -- 1882
local agentDocLanguage -- 1890
agentDocLanguage = function(language) -- 1890
	if language == "zh-Hans" then -- 1891
		return "zh" -- 1891
	else -- 1891
		return "en" -- 1891
	end -- 1891
end -- 1890
HttpServer:postSchedule("/doc/search", function(req) -- 1893
	local body = req.body or { } -- 1894
	local language = body.docLanguage -- 1895
	if not (("en" == language or "zh-Hans" == language)) then -- 1896
		return { -- 1896
			success = false, -- 1896
			message = "unsupported doc language" -- 1896
		} -- 1896
	end -- 1896
	local docType = body.docType -- 1897
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1898
		return { -- 1898
			success = false, -- 1898
			message = "unsupported doc type" -- 1898
		} -- 1898
	end -- 1898
	local codeLanguage = body.programmingLanguage -- 1899
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1900
		return { -- 1900
			success = false, -- 1900
			message = "unsupported programming language" -- 1900
		} -- 1900
	end -- 1900
	if not body.pattern then -- 1901
		return { -- 1901
			success = false, -- 1901
			message = "missing pattern" -- 1901
		} -- 1901
	end -- 1901
	local result = nil -- 1902
	AgentTools.searchDoraDocHttp({ -- 1904
		pattern = body.pattern, -- 1904
		docLanguage = agentDocLanguage(language), -- 1905
		docType = docType, -- 1906
		programmingLanguage = codeLanguage, -- 1907
		limit = body.limit, -- 1908
		useRegex = body.useRegex, -- 1909
		caseSensitive = body.caseSensitive, -- 1910
		includeContent = body.includeContent, -- 1911
		contentWindow = body.contentWindow -- 1912
	}, function(res) -- 1913
		result = res -- 1914
	end) -- 1903
	wait(function() -- 1915
		return result ~= nil -- 1915
	end) -- 1915
	if result and result.success then -- 1916
		result.docLanguage = language -- 1917
	end -- 1916
	if result then -- 1918
		return result -- 1919
	else -- 1921
		return { -- 1921
			success = false, -- 1921
			message = "doc search failed" -- 1921
		} -- 1921
	end -- 1918
	return { -- 1893
		success = false, -- 1893
		message = "invalid call" -- 1893
	} -- 1893
end) -- 1893
HttpServer:postSchedule("/doc/read", function(req) -- 1923
	local body = req.body or { } -- 1924
	local language = body.docLanguage -- 1925
	if not (("en" == language or "zh-Hans" == language)) then -- 1926
		return { -- 1926
			success = false, -- 1926
			message = "unsupported doc language" -- 1926
		} -- 1926
	end -- 1926
	if not body.file then -- 1927
		return { -- 1927
			success = false, -- 1927
			message = "missing file" -- 1927
		} -- 1927
	end -- 1927
	local result = AgentTools.readDoraDoc({ -- 1929
		docLanguage = agentDocLanguage(language), -- 1929
		file = body.file, -- 1930
		startLine = body.startLine, -- 1931
		endLine = body.endLine -- 1932
	}) -- 1928
	if result and result.success then -- 1933
		result.docLanguage = language -- 1934
	end -- 1933
	return result -- 1935
end) -- 1923
local readSyncFile -- 1937
readSyncFile = function(req) -- 1937
	do -- 1938
		local _type_0 = type(req) -- 1938
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1938
		if _tab_0 then -- 1938
			local params = req.params -- 1938
			if params ~= nil then -- 1938
				local path = params.path -- 1939
				if not (type(path) == "string" and path ~= "") then -- 1940
					return { -- 1940
						success = false, -- 1940
						message = "invalid path" -- 1940
					} -- 1940
				end -- 1940
				local exts -- 1941
				if params.exts then -- 1941
					local _accum_0 = { } -- 1942
					local _len_0 = 1 -- 1942
					for ext in params.exts:gmatch("[^|]*") do -- 1942
						_accum_0[_len_0] = ext -- 1942
						_len_0 = _len_0 + 1 -- 1942
					end -- 1942
					exts = _accum_0 -- 1942
				else -- 1943
					exts = { -- 1943
						"" -- 1943
					} -- 1943
				end -- 1941
				local readFileAt -- 1944
				readFileAt = function(targetPath) -- 1944
					if Content:exist(targetPath) then -- 1945
						local content = Content:load(targetPath) -- 1946
						if content then -- 1946
							return { -- 1947
								content = content, -- 1947
								success = true, -- 1947
								fullPath = Content:getFullPath(targetPath) -- 1947
							} -- 1947
						end -- 1946
					end -- 1945
					return nil -- 1944
				end -- 1944
				local readFile -- 1948
				readFile = function(fallbackPaths) -- 1948
					for _index_0 = 1, #exts do -- 1949
						local ext = exts[_index_0] -- 1949
						local targetPath = path .. ext -- 1950
						if not Content:isAbsolutePath(targetPath) then -- 1951
							for _index_1 = 1, #fallbackPaths do -- 1952
								local fallback = fallbackPaths[_index_1] -- 1952
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1953
								if fallbackResult then -- 1953
									return fallbackResult -- 1954
								end -- 1953
							end -- 1952
						end -- 1951
						local fileResult = readFileAt(targetPath) -- 1955
						if fileResult then -- 1955
							return fileResult -- 1956
						end -- 1955
					end -- 1949
					return nil -- 1948
				end -- 1948
				local fallbackPaths = { } -- 1957
				local fallbackCandidates = { } -- 1958
				do -- 1959
					local projectRoot = req.params.projectRoot -- 1959
					if projectRoot then -- 1959
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1960
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1961
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1962
						end -- 1960
					end -- 1959
				end -- 1959
				do -- 1963
					local projFile = req.params.projFile -- 1963
					if projFile then -- 1963
						local projDir = getProjectDirFromFile(projFile) -- 1964
						if projDir then -- 1964
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1965
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1966
						else -- 1968
							projDir = Path:getPath(projFile) -- 1968
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1969
						end -- 1964
					end -- 1963
				end -- 1963
				for _index_0 = 1, #fallbackCandidates do -- 1970
					local dir = fallbackCandidates[_index_0] -- 1970
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1971
						local exists = false -- 1972
						for _index_1 = 1, #fallbackPaths do -- 1973
							local fallback = fallbackPaths[_index_1] -- 1973
							if fallback == dir then -- 1974
								exists = true -- 1975
								break -- 1976
							end -- 1974
						end -- 1973
						if not exists then -- 1977
							fallbackPaths[#fallbackPaths + 1] = dir -- 1977
						end -- 1977
					end -- 1971
				end -- 1970
				local readResult = readFile(fallbackPaths) -- 1978
				if readResult then -- 1978
					return readResult -- 1979
				end -- 1978
			end -- 1938
		end -- 1938
	end -- 1938
	return { -- 1937
		success = false -- 1937
	} -- 1937
end -- 1937
HttpServer:get("/read-sync", readSyncFile) -- 1981
HttpServer:post("/read-sync", function(req) -- 1982
	return readSyncFile({ -- 1982
		params = req.body -- 1982
	}) -- 1982
end) -- 1982
local addGeneratedSourceHeader -- 1984
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 1984
	if preserveTIC80 == nil then -- 1984
		preserveTIC80 = false -- 1984
	end -- 1984
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 1985
	if preserveTIC80 then -- 1986
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 1987
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 1988
		end -- 1987
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 1989
	end -- 1986
	return tostring(header) .. "\n" .. tostring(codes) -- 1990
end -- 1984
local compileFileAsync -- 1992
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1992
	if projectRoot == nil then -- 1992
		projectRoot = nil -- 1992
	end -- 1992
	local file = inputFile -- 1993
	local searchPath -- 1994
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1994
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1995
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1999
	elseif not Content:isAbsolutePath(inputFile) then -- 2000
		searchPath = "" -- 2001
	else -- 2002
		local dir = getProjectDirFromFile(inputFile) -- 2002
		if dir then -- 2002
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2003
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 2007
		else -- 2009
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2009
			searchPath = "" -- 2012
		end -- 2002
	end -- 1994
	local outputFile = Path:replaceExt(inputFile, "lua") -- 2013
	local yueext = yue.options.extension -- 2014
	local resultCodes = nil -- 2015
	local resultError = nil -- 2016
	do -- 2017
		local _exp_0 = Path:getExt(inputFile) -- 2017
		if yueext == _exp_0 then -- 2017
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 2018
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 2019
				if not codes then -- 2020
					resultError = err -- 2021
					return -- 2022
				end -- 2020
				local extraGlobal -- 2023
				if isTIC80 then -- 2023
					extraGlobal = tic80APIs -- 2023
				else -- 2023
					extraGlobal = nil -- 2023
				end -- 2023
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 2024
				if not success then -- 2025
					resultError = message -- 2026
					return -- 2027
				end -- 2025
				if codes == "" then -- 2028
					resultCodes = "" -- 2029
					return nil -- 2030
				end -- 2028
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 2031
				return resultCodes -- 2032
			end, function(success) -- 2019
				if not success then -- 2033
					Content:remove(outputFile) -- 2034
					if resultCodes == nil then -- 2035
						resultCodes = false -- 2036
					end -- 2035
				end -- 2033
			end) -- 2019
		elseif "tl" == _exp_0 then -- 2037
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 2038
			if isTIC80 then -- 2039
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2040
			end -- 2039
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2041
			if codes then -- 2041
				if isTIC80 then -- 2042
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2043
				end -- 2042
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2044
				Content:saveAsync(outputFile, resultCodes) -- 2045
			else -- 2047
				Content:remove(outputFile) -- 2047
				resultCodes = false -- 2048
				resultError = err -- 2049
			end -- 2041
		elseif "xml" == _exp_0 then -- 2050
			local codes, err = xml.tolua(sourceCodes) -- 2051
			if codes then -- 2051
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2052
				Content:saveAsync(outputFile, resultCodes) -- 2053
			else -- 2055
				Content:remove(outputFile) -- 2055
				resultCodes = false -- 2056
				resultError = err -- 2057
			end -- 2051
		end -- 2017
	end -- 2017
	wait(function() -- 2058
		return resultCodes ~= nil -- 2058
	end) -- 2058
	if resultCodes then -- 2059
		return resultCodes -- 2060
	else -- 2062
		return nil, resultError -- 2062
	end -- 2059
	return nil -- 1992
end -- 1992
HttpServer:postSchedule("/write", function(req) -- 2064
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2065
	local buildSucceeded = false -- 2066
	local _ <close> = setmetatable({ }, { -- 2067
		__close = function() -- 2067
			return finishUpdate(buildSucceeded) -- 2067
		end -- 2067
	}) -- 2067
	do -- 2068
		local _type_0 = type(req) -- 2068
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2068
		if _tab_0 then -- 2068
			local path -- 2068
			do -- 2068
				local _obj_0 = req.body -- 2068
				local _type_1 = type(_obj_0) -- 2068
				if "table" == _type_1 or "userdata" == _type_1 then -- 2068
					path = _obj_0.path -- 2068
				end -- 2068
			end -- 2068
			local content -- 2068
			do -- 2068
				local _obj_0 = req.body -- 2068
				local _type_1 = type(_obj_0) -- 2068
				if "table" == _type_1 or "userdata" == _type_1 then -- 2068
					content = _obj_0.content -- 2068
				end -- 2068
			end -- 2068
			if path ~= nil and content ~= nil then -- 2068
				if Content:saveAsync(path, content) then -- 2069
					do -- 2070
						local _exp_0 = Path:getExt(path) -- 2070
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2070
							if '' == Path:getExt(Path:getName(path)) then -- 2071
								local resultCodes = compileFileAsync(path, content) -- 2072
								buildSucceeded = resultCodes ~= nil -- 2073
								return { -- 2074
									success = true, -- 2074
									resultCodes = resultCodes -- 2074
								} -- 2074
							end -- 2071
						end -- 2070
					end -- 2070
					buildSucceeded = true -- 2075
					return { -- 2076
						success = true -- 2076
					} -- 2076
				end -- 2069
			end -- 2068
		end -- 2068
	end -- 2068
	return { -- 2064
		success = false -- 2064
	} -- 2064
end) -- 2064
local getWaProjectDirFromFile = nil -- 2078
HttpServer:postSchedule("/build", function(req) -- 2080
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2081
	local buildSucceeded = false -- 2082
	local _ <close> = setmetatable({ }, { -- 2083
		__close = function() -- 2083
			return finishUpdate(buildSucceeded) -- 2083
		end -- 2083
	}) -- 2083
	do -- 2084
		local _type_0 = type(req) -- 2084
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2084
		if _tab_0 then -- 2084
			local path -- 2084
			do -- 2084
				local _obj_0 = req.body -- 2084
				local _type_1 = type(_obj_0) -- 2084
				if "table" == _type_1 or "userdata" == _type_1 then -- 2084
					path = _obj_0.path -- 2084
				end -- 2084
			end -- 2084
			if path ~= nil then -- 2084
				local projectRoot = req.body.projectRoot -- 2085
				if Content:isdir(path) then -- 2086
					local projDir = getWaProjectDirFromFile(path) -- 2087
					if projDir then -- 2087
						local message = Wasm:buildWaAsync(projDir) -- 2088
						if message == "" then -- 2089
							return { -- 2090
								success = true -- 2090
							} -- 2090
						else -- 2092
							return { -- 2092
								success = false, -- 2092
								message = message -- 2092
							} -- 2092
						end -- 2089
					end -- 2087
				end -- 2086
				local _exp_0 = Path:getExt(path) -- 2093
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2094
					if '' == Path:getExt(Path:getName(path)) then -- 2095
						local content = Content:loadAsync(path) -- 2096
						if content then -- 2096
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2097
							if resultCodes then -- 2097
								buildSucceeded = true -- 2098
								return { -- 2099
									success = true, -- 2099
									resultCodes = resultCodes -- 2099
								} -- 2099
							end -- 2097
						end -- 2096
					end -- 2095
				elseif "wa" == _exp_0 then -- 2100
					local projDir = getWaProjectDirFromFile(path) -- 2101
					if projDir then -- 2101
						local message = Wasm:buildWaAsync(projDir) -- 2102
						if message == "" then -- 2103
							return { -- 2104
								success = true -- 2104
							} -- 2104
						else -- 2106
							return { -- 2106
								success = false, -- 2106
								message = message -- 2106
							} -- 2106
						end -- 2103
					else -- 2108
						return { -- 2108
							success = false, -- 2108
							message = 'Wa file needs a project' -- 2108
						} -- 2108
					end -- 2101
				end -- 2093
			end -- 2084
		end -- 2084
	end -- 2084
	return { -- 2080
		success = false -- 2080
	} -- 2080
end) -- 2080
local extentionLevels = { -- 2111
	vs = 2, -- 2111
	bl = 2, -- 2112
	ts = 1, -- 2113
	tsx = 1, -- 2114
	tl = 1, -- 2115
	yue = 1, -- 2116
	xml = 1, -- 2117
	lua = 0 -- 2118
} -- 2110
local visitAssets -- 2120
visitAssets = function(path, workspace, builtin, recursive) -- 2120
	if recursive == nil then -- 2120
		recursive = true -- 2120
	end -- 2120
	local children = nil -- 2121
	local dirs = Content:getDirs(path) -- 2122
	for _index_0 = 1, #dirs do -- 2123
		local dir = dirs[_index_0] -- 2123
		if workspace then -- 2124
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 2125
				goto _continue_0 -- 2126
			end -- 2125
		elseif dir == ".git" then -- 2127
			goto _continue_0 -- 2128
		end -- 2124
		if not children then -- 2129
			children = { } -- 2129
		end -- 2129
		local dirPath = Path(path, dir) -- 2130
		if recursive then -- 2131
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2132
		else -- 2134
			children[#children + 1] = { -- 2135
				key = dirPath, -- 2135
				dir = true, -- 2136
				title = dir, -- 2137
				builtin = builtin, -- 2138
				isLeaf = false -- 2139
			} -- 2134
		end -- 2131
		::_continue_0:: -- 2124
	end -- 2123
	local files = Content:getFiles(path) -- 2141
	local names = { } -- 2142
	for _index_0 = 1, #files do -- 2143
		local file = files[_index_0] -- 2143
		if (".DS_Store" == file) then -- 2144
			goto _continue_1 -- 2145
		end -- 2144
		local name = Path:getName(file) -- 2146
		local ext = names[name] -- 2147
		if ext then -- 2147
			local lv1 -- 2148
			do -- 2148
				local _exp_0 = extentionLevels[ext] -- 2148
				if _exp_0 ~= nil then -- 2148
					lv1 = _exp_0 -- 2148
				else -- 2148
					lv1 = -1 -- 2148
				end -- 2148
			end -- 2148
			ext = Path:getExt(file) -- 2149
			local lv2 -- 2150
			do -- 2150
				local _exp_0 = extentionLevels[ext] -- 2150
				if _exp_0 ~= nil then -- 2150
					lv2 = _exp_0 -- 2150
				else -- 2150
					lv2 = -1 -- 2150
				end -- 2150
			end -- 2150
			if lv2 > lv1 then -- 2151
				names[name] = ext -- 2152
			elseif lv2 == lv1 then -- 2153
				names[name .. '.' .. ext] = "" -- 2154
			end -- 2151
		else -- 2156
			ext = Path:getExt(file) -- 2156
			if not extentionLevels[ext] then -- 2157
				names[file] = "" -- 2158
			else -- 2160
				names[name] = ext -- 2160
			end -- 2157
		end -- 2147
		::_continue_1:: -- 2144
	end -- 2143
	do -- 2161
		local _accum_0 = { } -- 2161
		local _len_0 = 1 -- 2161
		for name, ext in pairs(names) do -- 2161
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2161
			_len_0 = _len_0 + 1 -- 2161
		end -- 2161
		files = _accum_0 -- 2161
	end -- 2161
	for _index_0 = 1, #files do -- 2162
		local file = files[_index_0] -- 2162
		if not children then -- 2163
			children = { } -- 2163
		end -- 2163
		children[#children + 1] = { -- 2165
			key = Path(path, file), -- 2165
			dir = false, -- 2166
			title = file, -- 2167
			builtin = builtin -- 2168
		} -- 2164
	end -- 2162
	if children then -- 2170
		table.sort(children, function(a, b) -- 2171
			if a.dir == b.dir then -- 2172
				return a.title < b.title -- 2173
			else -- 2175
				return a.dir -- 2175
			end -- 2172
		end) -- 2171
	end -- 2170
	return { -- 2177
		key = path, -- 2177
		dir = true, -- 2178
		title = Path:getFilename(path), -- 2179
		builtin = builtin, -- 2180
		isLeaf = not children, -- 2181
		children = children -- 2182
	} -- 2176
end -- 2120
HttpServer:post("/assets/children", function(req) -- 2185
	do -- 2186
		local _type_0 = type(req) -- 2186
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2186
		if _tab_0 then -- 2186
			local path -- 2186
			do -- 2186
				local _obj_0 = req.body -- 2186
				local _type_1 = type(_obj_0) -- 2186
				if "table" == _type_1 or "userdata" == _type_1 then -- 2186
					path = _obj_0.path -- 2186
				end -- 2186
			end -- 2186
			if path ~= nil then -- 2186
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2187
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2188
					return { -- 2188
						success = false -- 2188
					} -- 2188
				end -- 2188
				local node = visitAssets(path, workspace, builtin, false) -- 2189
				return { -- 2190
					success = true, -- 2190
					children = node.children or { } -- 2190
				} -- 2190
			end -- 2186
		end -- 2186
	end -- 2186
	return { -- 2185
		success = false -- 2185
	} -- 2185
end) -- 2185
HttpServer:post("/assets/files", function(req) -- 2192
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
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2194
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2195
				if not (workspace or builtin) then -- 2196
					return { -- 2196
						success = false -- 2196
					} -- 2196
				end -- 2196
				if not (Content:exist(path) and Content:isdir(path)) then -- 2197
					return { -- 2197
						success = false -- 2197
					} -- 2197
				end -- 2197
				local globs = { -- 2198
					"**", -- 2198
					"!**/.DS_Store" -- 2198
				} -- 2198
				if workspace then -- 2199
					globs = { -- 2201
						"**", -- 2201
						"!**/.DS_Store", -- 2201
						"!**/.upload/**", -- 2202
						"!**/.download/**", -- 2202
						"!**/.www/**", -- 2203
						"!**/.build/**", -- 2203
						"!**/.git/**", -- 2204
						"!**/.cache/**", -- 2204
						"!**/node_modules/**" -- 2205
					} -- 2200
				end -- 2199
				local files -- 2207
				do -- 2207
					local _accum_0 = { } -- 2207
					local _len_0 = 1 -- 2207
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2207
					for _index_0 = 1, #_list_0 do -- 2207
						local file = _list_0[_index_0] -- 2207
						_accum_0[_len_0] = Path(path, file) -- 2207
						_len_0 = _len_0 + 1 -- 2207
					end -- 2207
					files = _accum_0 -- 2207
				end -- 2207
				return { -- 2208
					success = true, -- 2208
					files = files -- 2208
				} -- 2208
			end -- 2193
		end -- 2193
	end -- 2193
	return { -- 2192
		success = false -- 2192
	} -- 2192
end) -- 2192
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2249
	local _tab_0 = { -- 2249
		{ -- 2250
			key = Path(Content.assetPath), -- 2250
			dir = true, -- 2251
			builtin = true, -- 2252
			title = zh and "内置资源" or "Built-in", -- 2253
			children = builtinChildren -- 2254
		} -- 2249
	} -- 2256
	local _obj_0 = workspace.children or { } -- 2256
	local _idx_0 = #_tab_0 + 1 -- 2256
	for _index_0 = 1, #_obj_0 do -- 2256
		local _value_0 = _obj_0[_index_0] -- 2256
		_tab_0[_idx_0] = _value_0 -- 2256
		_idx_0 = _idx_0 + 1 -- 2256
	end -- 2256
	return _tab_0 -- 2249
end -- 2249
HttpServer:post("/assets", function() -- 2210
	local Entry = require("Script.Dev.Entry") -- 2211
	local engineDev = Entry.getEngineDev() -- 2212
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2213
	local zh = (App.locale:match("^zh") ~= nil) -- 2214
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2215
	readme.title = zh and "说明文档" or "Readme" -- 2216
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2217
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2218
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2219
	tools.title = zh and "开发工具" or "Tools" -- 2220
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2221
	font.title = zh and "字体" or "Font" -- 2222
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2223
	lib.title = zh and "程序库" or "Lib" -- 2224
	if engineDev then -- 2225
		local _list_0 = lib.children -- 2226
		for _index_0 = 1, #_list_0 do -- 2226
			local child = _list_0[_index_0] -- 2226
			if not (child.title == "Dora") then -- 2227
				goto _continue_0 -- 2227
			end -- 2227
			local title = zh and "zh-Hans" or "en" -- 2228
			do -- 2229
				local _accum_0 = { } -- 2229
				local _len_0 = 1 -- 2229
				local _list_1 = child.children -- 2229
				for _index_1 = 1, #_list_1 do -- 2229
					local c = _list_1[_index_1] -- 2229
					if c.title ~= title then -- 2229
						_accum_0[_len_0] = c -- 2229
						_len_0 = _len_0 + 1 -- 2229
					end -- 2229
				end -- 2229
				child.children = _accum_0 -- 2229
			end -- 2229
			break -- 2230
			::_continue_0:: -- 2227
		end -- 2226
	else -- 2232
		local _accum_0 = { } -- 2232
		local _len_0 = 1 -- 2232
		local _list_0 = lib.children -- 2232
		for _index_0 = 1, #_list_0 do -- 2232
			local child = _list_0[_index_0] -- 2232
			if child.title ~= "Dora" then -- 2232
				_accum_0[_len_0] = child -- 2232
				_len_0 = _len_0 + 1 -- 2232
			end -- 2232
		end -- 2232
		lib.children = _accum_0 -- 2232
	end -- 2225
	local builtinChildren = { -- 2233
		readme, -- 2233
		apiDoc, -- 2233
		tools, -- 2233
		font, -- 2233
		lib -- 2233
	} -- 2233
	if engineDev then -- 2234
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2235
		do -- 2236
			local _obj_0 = dev.children -- 2236
			_obj_0[#_obj_0 + 1] = { -- 2237
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2237
				dir = false, -- 2238
				builtin = true, -- 2239
				title = "init.yue" -- 2240
			} -- 2236
		end -- 2236
		builtinChildren[#builtinChildren + 1] = dev -- 2242
	end -- 2234
	return { -- 2244
		key = Content.writablePath, -- 2244
		dir = true, -- 2245
		root = true, -- 2246
		title = "Assets", -- 2247
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2248
	} -- 2243
end) -- 2210
HttpServer:post("/entry/list", function(req) -- 2260
	local Entry = require("Script.Dev.Entry") -- 2261
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2262
	res.success = true -- 2263
	return res -- 2264
end) -- 2260
HttpServer:post("/run/status", function() -- 2266
	local Entry = require("Script.Dev.Entry") -- 2267
	return Entry.getCurrentEntryStatus() -- 2268
end) -- 2266
HttpServer:postSchedule("/run", function(req) -- 2270
	do -- 2271
		local _type_0 = type(req) -- 2271
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2271
		if _tab_0 then -- 2271
			local file -- 2271
			do -- 2271
				local _obj_0 = req.body -- 2271
				local _type_1 = type(_obj_0) -- 2271
				if "table" == _type_1 or "userdata" == _type_1 then -- 2271
					file = _obj_0.file -- 2271
				end -- 2271
			end -- 2271
			local asProj -- 2271
			do -- 2271
				local _obj_0 = req.body -- 2271
				local _type_1 = type(_obj_0) -- 2271
				if "table" == _type_1 or "userdata" == _type_1 then -- 2271
					asProj = _obj_0.asProj -- 2271
				end -- 2271
			end -- 2271
			if file ~= nil and asProj ~= nil then -- 2271
				if not Content:isAbsolutePath(file) then -- 2272
					local devFile = Path(Content.writablePath, file) -- 2273
					if Content:exist(devFile) then -- 2274
						file = devFile -- 2274
					end -- 2274
				end -- 2272
				local Entry = require("Script.Dev.Entry") -- 2275
				local workDir -- 2276
				if asProj then -- 2277
					local projectRoot = req.body.projectRoot -- 2278
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2279
						workDir = projectRoot -- 2280
					else -- 2282
						workDir = getProjectDirFromFile(file) -- 2282
					end -- 2279
					if workDir then -- 2283
						Entry.allClear() -- 2284
						local target = Path(workDir, "init") -- 2285
						local success, err = Entry.enterEntryAsync({ -- 2286
							entryName = "Project", -- 2286
							fileName = target, -- 2286
							workDir = workDir, -- 2286
							projectRoot = workDir, -- 2286
							runKind = "project" -- 2286
						}) -- 2286
						target = Path:getName(Path:getPath(target)) -- 2287
						return { -- 2288
							success = success, -- 2288
							target = target, -- 2288
							err = err -- 2288
						} -- 2288
					end -- 2283
				else -- 2290
					workDir = getProjectDirFromFile(file) -- 2290
					if not workDir and Path:getExt(file) == "wasm" then -- 2291
						local parent = Path:getPath(file) -- 2292
						if Content:exist(Path(parent, "wa.mod")) then -- 2293
							workDir = parent -- 2294
						end -- 2293
					end -- 2291
				end -- 2277
				Entry.allClear() -- 2295
				file = Path:replaceExt(file, "") -- 2296
				local entry = { -- 2298
					entryName = Path:getName(file), -- 2298
					fileName = file, -- 2299
					runKind = "file" -- 2300
				} -- 2297
				if workDir then -- 2301
					entry.workDir = workDir -- 2302
					entry.projectRoot = workDir -- 2303
				end -- 2301
				local success, err = Entry.enterEntryAsync(entry) -- 2304
				return { -- 2305
					success = success, -- 2305
					err = err -- 2305
				} -- 2305
			end -- 2271
		end -- 2271
	end -- 2271
	return { -- 2270
		success = false -- 2270
	} -- 2270
end) -- 2270
local _anon_func_7 = function(result) -- 2347
	if result.success then -- 2347
		return nil -- 2347
	else -- 2347
		return "PREVIEW_FAILED" -- 2347
	end -- 2347
end -- 2347
HttpServer:postSchedule("/agent/preview", function(req) -- 2307
	local releaseAgent = AgentHost.acquire() -- 2308
	local _ <close> = setmetatable({ }, { -- 2309
		__close = function() -- 2309
			return releaseAgent() -- 2309
		end -- 2309
	}) -- 2309
	do -- 2310
		local _type_0 = type(req) -- 2310
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2310
		if _tab_0 then -- 2310
			local projectRoot -- 2310
			do -- 2310
				local _obj_0 = req.body -- 2310
				local _type_1 = type(_obj_0) -- 2310
				if "table" == _type_1 or "userdata" == _type_1 then -- 2310
					projectRoot = _obj_0.projectRoot -- 2310
				end -- 2310
			end -- 2310
			if projectRoot ~= nil then -- 2310
				if not getProjectSourceRoot(projectRoot) then -- 2311
					return { -- 2311
						success = false, -- 2311
						code = "INVALID_PROJECT", -- 2311
						message = "projectRoot must be an existing absolute directory" -- 2311
					} -- 2311
				end -- 2311
				local entryFile = req.body.entry or "init.lua" -- 2312
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2313
					return { -- 2313
						success = false, -- 2313
						code = "INVALID_ENTRY", -- 2313
						message = "entry must be a non-empty project-relative path" -- 2313
					} -- 2313
				end -- 2313
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2314
					0.5 -- 2314
				} -- 2314
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2315
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2316
					return { -- 2316
						success = false, -- 2316
						code = "INVALID_QUEUE_TIMEOUT", -- 2316
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2316
					} -- 2316
				end -- 2316
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2317
				local AgentOperation = require("Agent.Tool.Operation") -- 2318
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2319
				local requestId = AgentOperation.createOperationId() -- 2320
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2321
				if not enqueued.success then -- 2322
					return { -- 2322
						success = false, -- 2322
						code = "ENTRY_QUEUE_REJECTED", -- 2322
						message = enqueued.message -- 2322
					} -- 2322
				end -- 2322
				local queuedAt = App.runningTime -- 2323
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2324
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2325
						local state = agentEntryRunQueue:get(requestId) -- 2326
						agentEntryRunQueue:cancel(requestId) -- 2327
						return { -- 2329
							success = false, -- 2329
							code = "ENTRY_QUEUE_TIMEOUT", -- 2330
							message = "timed out waiting for the Dora entry runtime", -- 2331
							requestId = requestId, -- 2332
							queuePosition = state.position -- 2333
						} -- 2328
					end -- 2325
					sleep() -- 2334
				end -- 2324
				local queueWaitSeconds = App.runningTime - queuedAt -- 2335
				local _ <close> = setmetatable({ }, { -- 2336
					__close = function() -- 2336
						return agentEntryRunQueue:release(requestId) -- 2336
					end -- 2336
				}) -- 2336
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2337
				local Entry = require("Script.Dev.Entry") -- 2338
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2340
					workDir = projectRoot, -- 2340
					operationId = requestId, -- 2341
					print = function() end -- 2342
				}, Entry) -- 2339
				local result = preview({ -- 2344
					entry = entryFile, -- 2344
					captureAtSeconds = captureAtSeconds -- 2344
				}) -- 2344
				return { -- 2346
					success = result.success, -- 2346
					code = _anon_func_7(result), -- 2347
					message = result.message, -- 2348
					requestId = requestId, -- 2349
					queueWaitSeconds = queueWaitSeconds, -- 2350
					interruptedUserRun = result.interruptedUserRun, -- 2351
					files = result.files, -- 2352
					frames = result.frames -- 2353
				} -- 2345
			end -- 2310
		end -- 2310
	end -- 2310
	return { -- 2307
		success = false, -- 2307
		message = "invalid call" -- 2307
	} -- 2307
end) -- 2307
HttpServer:postSchedule("/agent/command", function(req) -- 2355
	local releaseAgent = AgentHost.acquire() -- 2356
	local _ <close> = setmetatable({ }, { -- 2357
		__close = function() -- 2357
			return releaseAgent() -- 2357
		end -- 2357
	}) -- 2357
	do -- 2358
		local _type_0 = type(req) -- 2358
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2358
		if _tab_0 then -- 2358
			local body = req.body -- 2358
			if body ~= nil then -- 2358
				local projectRoot = body.projectRoot -- 2359
				if not getProjectSourceRoot(projectRoot) then -- 2360
					return { -- 2360
						success = false, -- 2360
						code = "INVALID_PROJECT", -- 2360
						message = "projectRoot must be an existing absolute directory" -- 2360
					} -- 2360
				end -- 2360
				local AgentValidation = require("Agent.Tool.Validation") -- 2361
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2362
				if not validated.success then -- 2363
					return { -- 2363
						success = false, -- 2363
						code = "INVALID_COMMAND", -- 2363
						message = validated.message -- 2363
					} -- 2363
				end -- 2363
				local input = validated.value -- 2364
				local AgentCommand = require("Agent.Tool.Command") -- 2365
				local result = nil -- 2366
				local failure = nil -- 2367
				local promise = AgentCommand.executeCommand({ -- 2369
					workDir = projectRoot, -- 2369
					mode = input.mode, -- 2370
					code = input.code, -- 2371
					command = input.command, -- 2372
					cwd = input.cwd, -- 2373
					timeoutSeconds = input.timeoutSeconds -- 2374
				}) -- 2368
				promise:addCallbacks((function(_, value) -- 2375
					result = value -- 2375
				end), (function(_, err) -- 2375
					failure = tostring(err) -- 2375
				end)) -- 2375
				wait(function() -- 2376
					return result ~= nil or failure ~= nil -- 2376
				end) -- 2376
				if failure then -- 2377
					return { -- 2377
						success = false, -- 2377
						code = "COMMAND_BRIDGE_FAILED", -- 2377
						message = failure -- 2377
					} -- 2377
				end -- 2377
				if not result.success then -- 2378
					result.code = "COMMAND_FAILED" -- 2379
				end -- 2378
				return result -- 2380
			end -- 2358
		end -- 2358
	end -- 2358
	return { -- 2355
		success = false, -- 2355
		code = "INVALID_COMMAND", -- 2355
		message = "invalid call" -- 2355
	} -- 2355
end) -- 2355
HttpServer:postSchedule("/stop", function() -- 2382
	local Entry = require("Script.Dev.Entry") -- 2383
	return { -- 2384
		success = Entry.stop() -- 2384
	} -- 2384
end) -- 2382
local minifyAsync -- 2386
minifyAsync = function(sourcePath, minifyPath) -- 2386
	if not Content:exist(sourcePath) then -- 2387
		return -- 2387
	end -- 2387
	local Entry = require("Script.Dev.Entry") -- 2388
	local errors = { } -- 2389
	local files = Entry.getAllFiles(sourcePath, { -- 2390
		"lua" -- 2390
	}, true) -- 2390
	do -- 2391
		local _accum_0 = { } -- 2391
		local _len_0 = 1 -- 2391
		for _index_0 = 1, #files do -- 2391
			local file = files[_index_0] -- 2391
			if file:sub(1, 1) ~= '.' then -- 2391
				_accum_0[_len_0] = file -- 2391
				_len_0 = _len_0 + 1 -- 2391
			end -- 2391
		end -- 2391
		files = _accum_0 -- 2391
	end -- 2391
	local paths -- 2392
	do -- 2392
		local _tbl_0 = { } -- 2392
		for _index_0 = 1, #files do -- 2392
			local file = files[_index_0] -- 2392
			_tbl_0[Path:getPath(file)] = true -- 2392
		end -- 2392
		paths = _tbl_0 -- 2392
	end -- 2392
	for path in pairs(paths) do -- 2393
		Content:mkdir(Path(minifyPath, path)) -- 2393
	end -- 2393
	local _ <close> = setmetatable({ }, { -- 2394
		__close = function() -- 2394
			package.loaded["luaminify.FormatMini"] = nil -- 2395
			package.loaded["luaminify.ParseLua"] = nil -- 2396
			package.loaded["luaminify.Scope"] = nil -- 2397
			package.loaded["luaminify.Util"] = nil -- 2398
		end -- 2394
	}) -- 2394
	local FormatMini -- 2399
	do -- 2399
		local _obj_0 = require("luaminify") -- 2399
		FormatMini = _obj_0.FormatMini -- 2399
	end -- 2399
	local fileCount = #files -- 2400
	local count = 0 -- 2401
	for _index_0 = 1, #files do -- 2402
		local file = files[_index_0] -- 2402
		thread(function() -- 2403
			local _ <close> = setmetatable({ }, { -- 2404
				__close = function() -- 2404
					count = count + 1 -- 2404
				end -- 2404
			}) -- 2404
			local input = Path(sourcePath, file) -- 2405
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2406
			if Content:exist(input) then -- 2407
				local sourceCodes = Content:loadAsync(input) -- 2408
				local res, err = FormatMini(sourceCodes) -- 2409
				if res then -- 2410
					Content:saveAsync(output, res) -- 2411
					return print("Minify " .. tostring(file)) -- 2412
				else -- 2414
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2414
				end -- 2410
			else -- 2416
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2416
			end -- 2407
		end) -- 2403
		sleep() -- 2417
	end -- 2402
	wait(function() -- 2418
		return count == fileCount -- 2418
	end) -- 2418
	if #errors > 0 then -- 2419
		print(table.concat(errors, '\n')) -- 2420
	end -- 2419
	print("Obfuscation done.") -- 2421
	return files -- 2422
end -- 2386
local zipping = false -- 2424
HttpServer:postSchedule("/zip", function(req) -- 2426
	do -- 2427
		local _type_0 = type(req) -- 2427
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2427
		if _tab_0 then -- 2427
			local path -- 2427
			do -- 2427
				local _obj_0 = req.body -- 2427
				local _type_1 = type(_obj_0) -- 2427
				if "table" == _type_1 or "userdata" == _type_1 then -- 2427
					path = _obj_0.path -- 2427
				end -- 2427
			end -- 2427
			local zipFile -- 2427
			do -- 2427
				local _obj_0 = req.body -- 2427
				local _type_1 = type(_obj_0) -- 2427
				if "table" == _type_1 or "userdata" == _type_1 then -- 2427
					zipFile = _obj_0.zipFile -- 2427
				end -- 2427
			end -- 2427
			local obfuscated -- 2427
			do -- 2427
				local _obj_0 = req.body -- 2427
				local _type_1 = type(_obj_0) -- 2427
				if "table" == _type_1 or "userdata" == _type_1 then -- 2427
					obfuscated = _obj_0.obfuscated -- 2427
				end -- 2427
			end -- 2427
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2427
				if zipping then -- 2428
					goto failed -- 2428
				end -- 2428
				zipping = true -- 2429
				local _ <close> = setmetatable({ }, { -- 2430
					__close = function() -- 2430
						zipping = false -- 2430
					end -- 2430
				}) -- 2430
				if not Content:exist(path) then -- 2431
					goto failed -- 2431
				end -- 2431
				Content:mkdir(Path:getPath(zipFile)) -- 2432
				if obfuscated then -- 2433
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2434
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2435
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2436
					Content:remove(scriptPath) -- 2437
					Content:remove(obfuscatedPath) -- 2438
					Content:remove(tempPath) -- 2439
					Content:mkdir(scriptPath) -- 2440
					Content:mkdir(obfuscatedPath) -- 2441
					Content:mkdir(tempPath) -- 2442
					if not Content:copyAsync(path, tempPath) then -- 2443
						goto failed -- 2443
					end -- 2443
					local Entry = require("Script.Dev.Entry") -- 2444
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2445
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2446
						"tl", -- 2446
						"yue", -- 2446
						"lua", -- 2446
						"ts", -- 2446
						"tsx", -- 2446
						"vs", -- 2446
						"bl", -- 2446
						"xml", -- 2446
						"wa", -- 2446
						"mod" -- 2446
					}, true) -- 2446
					for _index_0 = 1, #scriptFiles do -- 2447
						local file = scriptFiles[_index_0] -- 2447
						Content:remove(Path(tempPath, file)) -- 2448
					end -- 2447
					for _index_0 = 1, #luaFiles do -- 2449
						local file = luaFiles[_index_0] -- 2449
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2450
					end -- 2449
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2451
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2452
					end) then -- 2451
						goto failed -- 2451
					end -- 2451
					return { -- 2453
						success = true -- 2453
					} -- 2453
				else -- 2455
					return { -- 2455
						success = Content:zipAsync(path, zipFile, function(file) -- 2455
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2456
						end) -- 2455
					} -- 2455
				end -- 2433
			end -- 2427
		end -- 2427
	end -- 2427
	::failed:: -- 2457
	return { -- 2426
		success = false -- 2426
	} -- 2426
end) -- 2426
HttpServer:postSchedule("/unzip", function(req) -- 2459
	do -- 2460
		local _type_0 = type(req) -- 2460
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2460
		if _tab_0 then -- 2460
			local zipFile -- 2460
			do -- 2460
				local _obj_0 = req.body -- 2460
				local _type_1 = type(_obj_0) -- 2460
				if "table" == _type_1 or "userdata" == _type_1 then -- 2460
					zipFile = _obj_0.zipFile -- 2460
				end -- 2460
			end -- 2460
			local path -- 2460
			do -- 2460
				local _obj_0 = req.body -- 2460
				local _type_1 = type(_obj_0) -- 2460
				if "table" == _type_1 or "userdata" == _type_1 then -- 2460
					path = _obj_0.path -- 2460
				end -- 2460
			end -- 2460
			if zipFile ~= nil and path ~= nil then -- 2460
				return { -- 2461
					success = Content:unzipAsync(zipFile, path, function(file) -- 2461
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2462
					end) -- 2461
				} -- 2461
			end -- 2460
		end -- 2460
	end -- 2460
	return { -- 2459
		success = false -- 2459
	} -- 2459
end) -- 2459
HttpServer:post("/editing-info", function(req) -- 2464
	local Entry = require("Script.Dev.Entry") -- 2465
	local config = Entry.getConfig() -- 2466
	local _type_0 = type(req) -- 2467
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2467
	local _match_0 = false -- 2467
	if _tab_0 then -- 2467
		local editingInfo -- 2467
		do -- 2467
			local _obj_0 = req.body -- 2467
			local _type_1 = type(_obj_0) -- 2467
			if "table" == _type_1 or "userdata" == _type_1 then -- 2467
				editingInfo = _obj_0.editingInfo -- 2467
			end -- 2467
		end -- 2467
		if editingInfo ~= nil then -- 2467
			_match_0 = true -- 2467
			config.editingInfo = editingInfo -- 2468
			return { -- 2469
				success = true -- 2469
			} -- 2469
		end -- 2467
	end -- 2467
	if not _match_0 then -- 2467
		if not (config.editingInfo ~= nil) then -- 2471
			local folder -- 2472
			if App.locale:match('^zh') then -- 2472
				folder = 'zh-Hans' -- 2472
			else -- 2472
				folder = 'en' -- 2472
			end -- 2472
			config.editingInfo = json.encode({ -- 2474
				index = 0, -- 2474
				files = { -- 2476
					{ -- 2477
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2477
						title = "welcome.md" -- 2478
					} -- 2476
				} -- 2475
			}) -- 2473
		end -- 2471
		return { -- 2482
			success = true, -- 2482
			editingInfo = config.editingInfo -- 2482
		} -- 2482
	end -- 2467
end) -- 2464
HttpServer:post("/command", function(req) -- 2484
	do -- 2485
		local _type_0 = type(req) -- 2485
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2485
		if _tab_0 then -- 2485
			local code -- 2485
			do -- 2485
				local _obj_0 = req.body -- 2485
				local _type_1 = type(_obj_0) -- 2485
				if "table" == _type_1 or "userdata" == _type_1 then -- 2485
					code = _obj_0.code -- 2485
				end -- 2485
			end -- 2485
			local log -- 2485
			do -- 2485
				local _obj_0 = req.body -- 2485
				local _type_1 = type(_obj_0) -- 2485
				if "table" == _type_1 or "userdata" == _type_1 then -- 2485
					log = _obj_0.log -- 2485
				end -- 2485
			end -- 2485
			if code ~= nil and log ~= nil then -- 2485
				emit("AppCommand", code, log) -- 2486
				return { -- 2487
					success = true -- 2487
				} -- 2487
			end -- 2485
		end -- 2485
	end -- 2485
	return { -- 2484
		success = false -- 2484
	} -- 2484
end) -- 2484
HttpServer:post("/log/save", function() -- 2489
	local folder = ".download" -- 2490
	local fullLogFile = "dora_full_logs.txt" -- 2491
	local fullFolder = Path(Content.writablePath, folder) -- 2492
	Content:mkdir(fullFolder) -- 2493
	local logPath = Path(fullFolder, fullLogFile) -- 2494
	if App:saveLog(logPath) then -- 2495
		return { -- 2496
			success = true, -- 2496
			path = Path(folder, fullLogFile) -- 2496
		} -- 2496
	end -- 2495
	return { -- 2489
		success = false -- 2489
	} -- 2489
end) -- 2489
local tailLines -- 2498
tailLines = function(text, count) -- 2498
	local lines = { } -- 2499
	text = text:gsub("\r\n", "\n") -- 2500
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2501
		lines[#lines + 1] = line -- 2502
	end -- 2501
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2503
		table.remove(lines) -- 2504
	end -- 2503
	local start = math.max(1, #lines - count + 1) -- 2505
	local out = { } -- 2506
	for i = start, #lines do -- 2507
		out[#out + 1] = lines[i] -- 2508
	end -- 2507
	return table.concat(out, "\n") -- 2509
end -- 2498
HttpServer:post("/log", function(req) -- 2511
	local count = 100 -- 2512
	if req and req.body and req.body.count ~= nil then -- 2513
		count = req.body.count -- 2514
	end -- 2513
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2515
		return { -- 2516
			success = false, -- 2516
			message = "count must be a positive integer" -- 2516
		} -- 2516
	end -- 2515
	local folder = ".download" -- 2517
	local fullLogFile = "dora_full_logs.txt" -- 2518
	local fullFolder = Path(Content.writablePath, folder) -- 2519
	Content:mkdir(fullFolder) -- 2520
	local logPath = Path(fullFolder, fullLogFile) -- 2521
	if App:saveLog(logPath) then -- 2522
		local text = Content:load(logPath) -- 2523
		if text then -- 2524
			return { -- 2525
				success = true, -- 2525
				log = tailLines(text, count) -- 2525
			} -- 2525
		else -- 2527
			return { -- 2527
				success = false, -- 2527
				message = "failed to read log" -- 2527
			} -- 2527
		end -- 2524
	else -- 2529
		return { -- 2529
			success = false, -- 2529
			message = "failed to save log" -- 2529
		} -- 2529
	end -- 2522
	return { -- 2511
		success = false -- 2511
	} -- 2511
end) -- 2511
HttpServer:post("/yarn/check", function(req) -- 2531
	local yarncompile = require("yarncompile") -- 2532
	do -- 2533
		local _type_0 = type(req) -- 2533
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2533
		if _tab_0 then -- 2533
			local code -- 2533
			do -- 2533
				local _obj_0 = req.body -- 2533
				local _type_1 = type(_obj_0) -- 2533
				if "table" == _type_1 or "userdata" == _type_1 then -- 2533
					code = _obj_0.code -- 2533
				end -- 2533
			end -- 2533
			if code ~= nil then -- 2533
				local jsonObject = json.decode(code) -- 2534
				if jsonObject then -- 2534
					local errors = { } -- 2535
					local _list_0 = jsonObject.nodes -- 2536
					for _index_0 = 1, #_list_0 do -- 2536
						local node = _list_0[_index_0] -- 2536
						local title, body = node.title, node.body -- 2537
						local luaCode, err = yarncompile(body) -- 2538
						if not luaCode then -- 2538
							errors[#errors + 1] = title .. ":" .. err -- 2539
						end -- 2538
					end -- 2536
					return { -- 2540
						success = true, -- 2540
						syntaxError = table.concat(errors, "\n\n") -- 2540
					} -- 2540
				end -- 2534
			end -- 2533
		end -- 2533
	end -- 2533
	return { -- 2531
		success = false -- 2531
	} -- 2531
end) -- 2531
HttpServer:post("/yarn/check-file", function(req) -- 2542
	local yarncompile = require("yarncompile") -- 2543
	do -- 2544
		local _type_0 = type(req) -- 2544
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2544
		if _tab_0 then -- 2544
			local code -- 2544
			do -- 2544
				local _obj_0 = req.body -- 2544
				local _type_1 = type(_obj_0) -- 2544
				if "table" == _type_1 or "userdata" == _type_1 then -- 2544
					code = _obj_0.code -- 2544
				end -- 2544
			end -- 2544
			if code ~= nil then -- 2544
				local res, _, err = yarncompile(code, true) -- 2545
				if not res then -- 2545
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2546
					return { -- 2547
						success = false, -- 2547
						message = message, -- 2547
						line = line, -- 2547
						column = column, -- 2547
						node = node -- 2547
					} -- 2547
				end -- 2545
			end -- 2544
		end -- 2544
	end -- 2544
	return { -- 2542
		success = true -- 2542
	} -- 2542
end) -- 2542
getWaProjectDirFromFile = function(file) -- 2549
	local current -- 2550
	if Content:isdir(file) then -- 2550
		current = file -- 2550
	else -- 2550
		current = Path:getPath(file) -- 2550
	end -- 2550
	if current == "" then -- 2551
		return nil -- 2551
	end -- 2551
	repeat -- 2552
		local modPath = Path(current, "wa.mod") -- 2553
		if Content:exist(modPath) then -- 2554
			return current, modPath -- 2555
		end -- 2554
		local parent = Path:getPath(current) -- 2556
		if parent == "" or parent == current then -- 2557
			break -- 2557
		end -- 2557
		current = parent -- 2558
	until false -- 2552
	return nil -- 2560
end -- 2549
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2562
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
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2565
					if not Content:exist(sourceDoraPath) then -- 2566
						return { -- 2567
							success = false, -- 2567
							message = "missing dora template" -- 2567
						} -- 2567
					end -- 2566
					local targetVendorPath = Path(projDir, "vendor") -- 2568
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2569
					if not Content:exist(targetVendorPath) then -- 2570
						if not Content:mkdir(targetVendorPath) then -- 2571
							return { -- 2572
								success = false, -- 2572
								message = "failed to create vendor folder" -- 2572
							} -- 2572
						end -- 2571
					elseif not Content:isdir(targetVendorPath) then -- 2573
						return { -- 2574
							success = false, -- 2574
							message = "vendor path is not a folder" -- 2574
						} -- 2574
					end -- 2570
					if Content:exist(targetDoraPath) then -- 2575
						if not Content:remove(targetDoraPath) then -- 2576
							return { -- 2577
								success = false, -- 2577
								message = "failed to remove old dora" -- 2577
							} -- 2577
						end -- 2576
					end -- 2575
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2578
						return { -- 2579
							success = false, -- 2579
							message = "failed to copy dora" -- 2579
						} -- 2579
					end -- 2578
					return { -- 2580
						success = true -- 2580
					} -- 2580
				else -- 2582
					return { -- 2582
						success = false, -- 2582
						message = 'Wa file needs a project' -- 2582
					} -- 2582
				end -- 2564
			end -- 2563
		end -- 2563
	end -- 2563
	return { -- 2562
		success = false, -- 2562
		message = "invalid call" -- 2562
	} -- 2562
end) -- 2562
HttpServer:postSchedule("/wa/build", function(req) -- 2584
	do -- 2585
		local _type_0 = type(req) -- 2585
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2585
		if _tab_0 then -- 2585
			local path -- 2585
			do -- 2585
				local _obj_0 = req.body -- 2585
				local _type_1 = type(_obj_0) -- 2585
				if "table" == _type_1 or "userdata" == _type_1 then -- 2585
					path = _obj_0.path -- 2585
				end -- 2585
			end -- 2585
			if path ~= nil then -- 2585
				local projDir = getWaProjectDirFromFile(path) -- 2586
				if projDir then -- 2586
					local message = Wasm:buildWaAsync(projDir) -- 2587
					if message == "" then -- 2588
						return { -- 2589
							success = true -- 2589
						} -- 2589
					else -- 2591
						return { -- 2591
							success = false, -- 2591
							message = message -- 2591
						} -- 2591
					end -- 2588
				else -- 2593
					return { -- 2593
						success = false, -- 2593
						message = 'Wa file needs a project' -- 2593
					} -- 2593
				end -- 2586
			end -- 2585
		end -- 2585
	end -- 2585
	return { -- 2594
		success = false, -- 2594
		message = 'failed to build' -- 2594
	} -- 2594
end) -- 2584
HttpServer:postSchedule("/wa/format", function(req) -- 2596
	do -- 2597
		local _type_0 = type(req) -- 2597
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2597
		if _tab_0 then -- 2597
			local file -- 2597
			do -- 2597
				local _obj_0 = req.body -- 2597
				local _type_1 = type(_obj_0) -- 2597
				if "table" == _type_1 or "userdata" == _type_1 then -- 2597
					file = _obj_0.file -- 2597
				end -- 2597
			end -- 2597
			if file ~= nil then -- 2597
				local code = Wasm:formatWaAsync(file) -- 2598
				if code == "" then -- 2599
					return { -- 2600
						success = false -- 2600
					} -- 2600
				else -- 2602
					return { -- 2602
						success = true, -- 2602
						code = code -- 2602
					} -- 2602
				end -- 2599
			end -- 2597
		end -- 2597
	end -- 2597
	return { -- 2603
		success = false -- 2603
	} -- 2603
end) -- 2596
HttpServer:postSchedule("/wa/create", function(req) -- 2605
	do -- 2606
		local _type_0 = type(req) -- 2606
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2606
		if _tab_0 then -- 2606
			local path -- 2606
			do -- 2606
				local _obj_0 = req.body -- 2606
				local _type_1 = type(_obj_0) -- 2606
				if "table" == _type_1 or "userdata" == _type_1 then -- 2606
					path = _obj_0.path -- 2606
				end -- 2606
			end -- 2606
			if path ~= nil then -- 2606
				if not Content:exist(Path:getPath(path)) then -- 2607
					return { -- 2608
						success = false, -- 2608
						message = "target path not existed" -- 2608
					} -- 2608
				end -- 2607
				if Content:exist(path) then -- 2609
					return { -- 2610
						success = false, -- 2610
						message = "target project folder existed" -- 2610
					} -- 2610
				end -- 2609
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2611
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2612
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2613
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2614
					return { -- 2617
						success = false, -- 2617
						message = "missing template project" -- 2617
					} -- 2617
				end -- 2614
				if not Content:mkdir(path) then -- 2618
					return { -- 2619
						success = false, -- 2619
						message = "failed to create project folder" -- 2619
					} -- 2619
				end -- 2618
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2620
					Content:remove(path) -- 2621
					return { -- 2622
						success = false, -- 2622
						message = "failed to copy template" -- 2622
					} -- 2622
				end -- 2620
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2623
					Content:remove(path) -- 2624
					return { -- 2625
						success = false, -- 2625
						message = "failed to copy template" -- 2625
					} -- 2625
				end -- 2623
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2626
					Content:remove(path) -- 2627
					return { -- 2628
						success = false, -- 2628
						message = "failed to copy template" -- 2628
					} -- 2628
				end -- 2626
				return { -- 2629
					success = true -- 2629
				} -- 2629
			end -- 2606
		end -- 2606
	end -- 2606
	return { -- 2605
		success = false, -- 2605
		message = "invalid call" -- 2605
	} -- 2605
end) -- 2605
local tsBuildGlobs = { -- 2632
	"**/*.ts", -- 2632
	"**/*.tsx", -- 2633
	"!**/.*/**", -- 2634
	"!**/node_modules/**" -- 2635
} -- 2631
local tsSnapshotGlobs = { -- 2638
	"**/*.ts", -- 2638
	"**/*.tsx", -- 2639
	"**/*.lua", -- 2640
	"!**/.*/**", -- 2641
	"!**/node_modules/**" -- 2642
} -- 2637
local collectTSVirtualFiles -- 2644
collectTSVirtualFiles = function(sourceRoot) -- 2644
	local files = { } -- 2645
	local seen = { } -- 2646
	local addFile -- 2647
	addFile = function(file, moduleName, virtualFile) -- 2647
		if moduleName == nil then -- 2647
			moduleName = nil -- 2647
		end -- 2647
		if virtualFile == nil then -- 2647
			virtualFile = nil -- 2647
		end -- 2647
		local targetFile = virtualFile or file -- 2648
		do -- 2649
			local entry = seen[targetFile] -- 2649
			if entry then -- 2649
				if moduleName and moduleName ~= "" then -- 2650
					entry.moduleName = moduleName -- 2650
				end -- 2650
				return -- 2651
			end -- 2649
		end -- 2649
		local content = Content:load(file) -- 2652
		if content then -- 2652
			local entry = { -- 2653
				file = targetFile, -- 2653
				content = content -- 2653
			} -- 2653
			if moduleName and moduleName ~= "" then -- 2654
				entry.moduleName = moduleName -- 2654
			end -- 2654
			seen[targetFile] = entry -- 2655
			files[#files + 1] = entry -- 2656
		end -- 2652
	end -- 2647
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2657
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2658
		for _index_0 = 1, #_list_0 do -- 2658
			local subFile = _list_0[_index_0] -- 2658
			addFile(Path(sourceRoot, subFile)) -- 2659
		end -- 2658
		local libraryRoots = { -- 2661
			Path(sourceRoot, "Script", "Lib"), -- 2661
			Path(sourceRoot, "Lib"), -- 2662
			Path(Content.assetPath, "Script", "Lib") -- 2663
		} -- 2660
		for _index_0 = 1, #libraryRoots do -- 2664
			local libraryRoot = libraryRoots[_index_0] -- 2664
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2665
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2666
				for _index_1 = 1, #_list_1 do -- 2666
					local subFile = _list_1[_index_1] -- 2666
					local file = Path(libraryRoot, subFile) -- 2667
					local virtualFile = Path(sourceRoot, subFile) -- 2668
					addFile(file, nil, virtualFile) -- 2669
				end -- 2666
			end -- 2665
		end -- 2664
	end -- 2657
	local locale -- 2670
	if App.locale:match('^zh') then -- 2670
		locale = 'zh-Hans' -- 2670
	else -- 2670
		locale = 'en' -- 2670
	end -- 2670
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2671
	local _list_0 = Content:getFiles(declarationRoot) -- 2672
	for _index_0 = 1, #_list_0 do -- 2672
		local file = _list_0[_index_0] -- 2672
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2673
			local fullPath = Path(declarationRoot, file) -- 2674
			local moduleName = Path:getName(Path:getName(file)) -- 2675
			addFile(fullPath, moduleName) -- 2676
		end -- 2673
	end -- 2672
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2677
	local lualibBundleTarget -- 2678
	if sourceRoot then -- 2678
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2678
	else -- 2678
		lualibBundleTarget = "lualib_bundle.lua" -- 2678
	end -- 2678
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2679
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2680
	local _list_1 = Content:getFiles(lualibRoot) -- 2681
	for _index_0 = 1, #_list_1 do -- 2681
		local file = _list_1[_index_0] -- 2681
		if Path:getExt(file) == "lua" then -- 2682
			local virtualFile -- 2683
			if sourceRoot then -- 2683
				virtualFile = Path(sourceRoot, "lualib", file) -- 2683
			else -- 2683
				virtualFile = Path("lualib", file) -- 2683
			end -- 2683
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2684
		end -- 2682
	end -- 2681
	return files -- 2685
end -- 2644
local supportsCompilerWebView -- 2687
supportsCompilerWebView = function() -- 2687
	local _val_0 = App.platform -- 2687
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2687
end -- 2687
local webIDECompilerReady = false -- 2688
local webIDEConnectionGeneration = 0 -- 2689
local tsProbeId = 0 -- 2690
local probeWebIDECompiler -- 2692
probeWebIDECompiler = function(isCancelled) -- 2692
	if HttpServer.wsConnectionCount == 0 then -- 2693
		return false -- 2693
	end -- 2693
	tsProbeId = tsProbeId + 1 -- 2694
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2695
	local generation = webIDEConnectionGeneration -- 2696
	local done, ready = false, false -- 2697
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2698
	local listener = Node() -- 2699
	listener:gslot("AppWS", function(event) -- 2700
		if event.type == "Receive" then -- 2701
			local res = json.decode(event.msg) -- 2702
			if res then -- 2702
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2703
					responses = responses + 1 -- 2704
					ready = ready or res.success == true -- 2705
					done = ready or responses >= expectedResponses -- 2706
				end -- 2703
			end -- 2702
		end -- 2701
	end) -- 2700
	emit("AppWS", "Send", json.encode({ -- 2707
		name = "TranspileTSProbe", -- 2707
		id = requestId -- 2707
	})) -- 2707
	local deadline = App.runningTime + 5 -- 2708
	wait(function() -- 2709
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2709
	end) -- 2709
	listener:removeFromParent() -- 2710
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2711
	if generation == webIDEConnectionGeneration then -- 2712
		webIDECompilerReady = ready -- 2712
	end -- 2712
	return ready -- 2713
end -- 2692
local compilerConnectionListener = Node() -- 2715
compilerConnectionListener:addTo(Director.systemUI) -- 2717
local _anon_func_8 = function(event) -- 2719
	local _val_0 = event.type -- 2719
	return "Open" == _val_0 or "Close" == _val_0 -- 2719
end -- 2719
compilerConnectionListener:gslot("AppWS", function(event) -- 2718
	if _anon_func_8(event) then -- 2719
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2720
		webIDECompilerReady = false -- 2721
		if HttpServer.wsConnectionCount > 0 then -- 2722
			return thread(function() -- 2723
				return probeWebIDECompiler() -- 2723
			end) -- 2723
		end -- 2722
	end -- 2719
end) -- 2718
local _anon_func_9 = function(res) -- 2748
	if res.success then -- 2748
		return "tool" -- 2748
	else -- 2748
		return res.failureKind -- 2748
	end -- 2748
end -- 2748
local transpileTSFileWithWebIDE -- 2725
do -- 2725
	local tsBuildRequestId = 0 -- 2726
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2727
		if not probeWebIDECompiler(isCancelled) then -- 2728
			if isCancelled and isCancelled() then -- 2729
				return { -- 2730
					success = false, -- 2730
					file = file, -- 2730
					message = "build canceled", -- 2730
					interrupted = true -- 2730
				} -- 2730
			end -- 2729
			return { -- 2731
				success = false, -- 2731
				file = file, -- 2731
				message = "TypeScript transpiler is not ready", -- 2731
				failureKind = "tool" -- 2731
			} -- 2731
		end -- 2728
		tsBuildRequestId = tsBuildRequestId + 1 -- 2732
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2733
		local done = false -- 2734
		local result = nil -- 2735
		local listener = Node() -- 2736
		listener:gslot("AppWS", function(event) -- 2737
			if event.type == "Receive" then -- 2738
				local res = json.decode(event.msg) -- 2739
				if res then -- 2739
					if res.name == "TranspileTS" and res.id == requestId then -- 2740
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2741
							local luaFile = Path:replaceExt(file, "lua") -- 2742
							if Content:save(luaFile, res.luaCode) then -- 2743
								result = { -- 2744
									success = true, -- 2744
									file = file -- 2744
								} -- 2744
							else -- 2746
								result = { -- 2746
									success = false, -- 2746
									file = file, -- 2746
									message = "failed to save " .. tostring(luaFile) -- 2746
								} -- 2746
							end -- 2743
						else -- 2748
							result = { -- 2748
								success = false, -- 2748
								file = file, -- 2748
								message = res.message or "Compiler returned no Lua output", -- 2748
								failureKind = _anon_func_9(res) -- 2748
							} -- 2748
						end -- 2741
						done = true -- 2749
					end -- 2740
				end -- 2739
			end -- 2738
		end) -- 2737
		emit("AppWS", "Send", json.encode({ -- 2750
			name = "TranspileTS", -- 2750
			id = requestId, -- 2750
			file = file, -- 2750
			content = content, -- 2750
			projectRoot = sourceRoot, -- 2750
			files = files -- 2750
		})) -- 2750
		local deadline = App.runningTime + 30 -- 2751
		wait(function() -- 2752
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2752
		end) -- 2752
		listener:removeFromParent() -- 2753
		if not done then -- 2754
			webIDECompilerReady = false -- 2755
			if isCancelled and isCancelled() then -- 2756
				return { -- 2757
					success = false, -- 2757
					file = file, -- 2757
					message = "build canceled", -- 2757
					interrupted = true -- 2757
				} -- 2757
			end -- 2756
			return { -- 2758
				success = false, -- 2758
				file = file, -- 2758
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2758
				failureKind = "tool" -- 2758
			} -- 2758
		end -- 2754
		return result -- 2759
	end -- 2727
end -- 2725
local compilerReadyTimeout <const> = 15 -- 2761
local compilerBuildTimeout <const> = 30 -- 2762
local compilerIdleCloseSeconds <const> = 8 -- 2763
local compilerReady = false -- 2764
local compilerRequested = false -- 2765
local compilerFailure = nil -- 2766
local compilerUsers = 0 -- 2767
local compilerCloseGeneration = 0 -- 2768
local compilerJobId = 0 -- 2769
local compilerJobs = { } -- 2770
local compilerResults = { } -- 2771
local compilerInFlight = { } -- 2772
HttpServer:post("/compiler/ready", function() -- 2774
	if not compilerRequested then -- 2775
		return { -- 2775
			success = false -- 2775
		} -- 2775
	end -- 2775
	compilerReady = true -- 2776
	return { -- 2777
		success = true -- 2777
	} -- 2777
end) -- 2774
HttpServer:post("/compiler/failure", function(req) -- 2779
	if not compilerRequested then -- 2780
		return { -- 2780
			success = false -- 2780
		} -- 2780
	end -- 2780
	do -- 2781
		local _type_0 = type(req) -- 2781
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2781
		if _tab_0 then -- 2781
			local message -- 2781
			do -- 2781
				local _obj_0 = req.body -- 2781
				local _type_1 = type(_obj_0) -- 2781
				if "table" == _type_1 or "userdata" == _type_1 then -- 2781
					message = _obj_0.message -- 2781
				end -- 2781
			end -- 2781
			if message ~= nil then -- 2781
				if type(message) == "string" then -- 2782
					compilerFailure = message -- 2783
					compilerReady = false -- 2784
					return { -- 2785
						success = true -- 2785
					} -- 2785
				end -- 2782
			end -- 2781
		end -- 2781
	end -- 2781
	return { -- 2779
		success = false -- 2779
	} -- 2779
end) -- 2779
HttpServer:postSchedule("/compiler/poll", function() -- 2787
	if not compilerRequested then -- 2788
		return { -- 2788
			success = false -- 2788
		} -- 2788
	end -- 2788
	compilerReady = true -- 2789
	local deadline = App.runningTime + 5 -- 2790
	wait(function() -- 2791
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2791
	end) -- 2791
	if not (compilerRequested and not compilerFailure) then -- 2792
		return { -- 2792
			success = false -- 2792
		} -- 2792
	end -- 2792
	local job = table.remove(compilerJobs, 1) -- 2793
	if job then -- 2794
		compilerInFlight[job.id] = true -- 2795
	end -- 2794
	return { -- 2796
		success = true, -- 2796
		job = job -- 2796
	} -- 2796
end) -- 2787
HttpServer:post("/compiler/result", function(req) -- 2798
	do -- 2799
		local _type_0 = type(req) -- 2799
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2799
		if _tab_0 then -- 2799
			local body = req.body -- 2799
			if body ~= nil then -- 2799
				local id = body.id -- 2800
				if not (id and compilerInFlight[id]) then -- 2801
					return { -- 2801
						success = false, -- 2801
						message = "invalid compiler job" -- 2801
					} -- 2801
				end -- 2801
				compilerInFlight[id] = nil -- 2802
				compilerResults[id] = body -- 2803
				return { -- 2804
					success = true -- 2804
				} -- 2804
			end -- 2799
		end -- 2799
	end -- 2799
	return { -- 2798
		success = false -- 2798
	} -- 2798
end) -- 2798
local acquireCompiler -- 2806
acquireCompiler = function() -- 2806
	compilerUsers = compilerUsers + 1 -- 2807
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2808
	if not compilerRequested then -- 2809
		compilerRequested = true -- 2810
		compilerReady = false -- 2811
		compilerFailure = nil -- 2812
		return emit("AppWebView", "/compiler.html", true) -- 2813
	end -- 2809
end -- 2806
local releaseCompiler -- 2815
releaseCompiler = function() -- 2815
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2816
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2817
	if not (compilerUsers == 0) then -- 2818
		return -- 2818
	end -- 2818
	local closeGeneration = compilerCloseGeneration -- 2819
	return thread(function() -- 2820
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2821
		wait(function() -- 2822
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2823
		end) -- 2822
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2828
			compilerRequested = false -- 2829
			compilerReady = false -- 2830
			return emit("AppWebView", "/compiler.html", false) -- 2831
		end -- 2828
	end) -- 2820
end -- 2815
local removeCompilerJob -- 2833
removeCompilerJob = function(id) -- 2833
	for index = #compilerJobs, 1, -1 do -- 2834
		if compilerJobs[index].id == id then -- 2835
			table.remove(compilerJobs, index) -- 2836
		end -- 2835
	end -- 2834
	compilerInFlight[id] = nil -- 2837
	compilerResults[id] = nil -- 2838
end -- 2833
local transpileTSFileWithCompiler -- 2840
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2840
	acquireCompiler() -- 2841
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2842
	wait(function() -- 2843
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2843
	end) -- 2843
	if not compilerReady then -- 2844
		releaseCompiler() -- 2845
		if isCancelled and isCancelled() then -- 2846
			return { -- 2847
				success = false, -- 2847
				file = file, -- 2847
				message = "build canceled", -- 2847
				interrupted = true -- 2847
			} -- 2847
		end -- 2846
		return { -- 2848
			success = false, -- 2848
			file = file, -- 2848
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2848
			failureKind = "tool" -- 2848
		} -- 2848
	end -- 2844
	compilerJobId = compilerJobId + 1 -- 2849
	local jobId = compilerJobId -- 2850
	compilerJobs[#compilerJobs + 1] = { -- 2852
		id = jobId, -- 2852
		file = file, -- 2853
		content = content, -- 2854
		projectRoot = sourceRoot, -- 2855
		files = files -- 2856
	} -- 2851
	local deadline = App.runningTime + compilerBuildTimeout -- 2857
	wait(function() -- 2858
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2858
	end) -- 2858
	local response = compilerResults[jobId] -- 2859
	removeCompilerJob(jobId) -- 2860
	releaseCompiler() -- 2861
	if not response then -- 2862
		if isCancelled and isCancelled() then -- 2863
			return { -- 2864
				success = false, -- 2864
				file = file, -- 2864
				message = "build canceled", -- 2864
				interrupted = true -- 2864
			} -- 2864
		end -- 2863
		return { -- 2865
			success = false, -- 2865
			file = file, -- 2865
			message = compilerFailure or "TypeScript transpile timed out", -- 2865
			failureKind = "tool" -- 2865
		} -- 2865
	end -- 2862
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2866
		local luaFile = Path:replaceExt(file, "lua") -- 2867
		if Content:save(luaFile, response.luaCode) then -- 2868
			return { -- 2869
				success = true, -- 2869
				file = file -- 2869
			} -- 2869
		end -- 2868
		return { -- 2870
			success = false, -- 2870
			file = file, -- 2870
			message = "failed to save " .. tostring(luaFile) -- 2870
		} -- 2870
	end -- 2866
	return { -- 2871
		success = false, -- 2871
		file = file, -- 2871
		message = response.message or "TypeScript transpile failed" -- 2871
	} -- 2871
end -- 2840
local compilerFailureListener = Node() -- 2873
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2874
	compilerFailure = message -- 2875
	compilerReady = false -- 2876
end) -- 2874
local transpileTSFile -- 2878
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2878
	if supportsCompilerWebView() and not files then -- 2879
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2880
	end -- 2879
	if HttpServer.wsConnectionCount > 0 then -- 2881
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2882
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2883
			return result -- 2883
		end -- 2883
		webIDECompilerReady = false -- 2884
	end -- 2881
	if supportsCompilerWebView() then -- 2885
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2886
	end -- 2885
	return { -- 2887
		success = false, -- 2887
		file = file, -- 2887
		message = "Web IDE compiler not connected", -- 2887
		failureKind = "tool" -- 2887
	} -- 2887
end -- 2878
local _anon_func_10 = function(path) -- 2902
	local _val_0 = Path:getExt(path) -- 2902
	return "ts" == _val_0 or "tsx" == _val_0 -- 2902
end -- 2902
HttpServer:postSchedule("/ts/build", function(req) -- 2889
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2890
	local buildSucceeded = false -- 2891
	local _ <close> = setmetatable({ }, { -- 2892
		__close = function() -- 2892
			return finishUpdate(buildSucceeded) -- 2892
		end -- 2892
	}) -- 2892
	do -- 2893
		local _type_0 = type(req) -- 2893
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2893
		if _tab_0 then -- 2893
			local path -- 2893
			do -- 2893
				local _obj_0 = req.body -- 2893
				local _type_1 = type(_obj_0) -- 2893
				if "table" == _type_1 or "userdata" == _type_1 then -- 2893
					path = _obj_0.path -- 2893
				end -- 2893
			end -- 2893
			if path ~= nil then -- 2893
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2894
					return { -- 2895
						success = false, -- 2895
						message = "Web IDE not connected" -- 2895
					} -- 2895
				end -- 2894
				local projectRoot = req.body.projectRoot -- 2896
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2897
				if not Content:exist(path) then -- 2898
					return { -- 2899
						success = false, -- 2899
						message = "path not existed" -- 2899
					} -- 2899
				end -- 2898
				local messages = { } -- 2900
				if not Content:isdir(path) then -- 2901
					if not (_anon_func_10(path)) then -- 2902
						return { -- 2903
							success = false, -- 2903
							message = "expecting a TypeScript file" -- 2903
						} -- 2903
					end -- 2902
					local content = Content:load(path) -- 2904
					if not content then -- 2905
						return { -- 2906
							success = false, -- 2906
							message = "failed to read file" -- 2906
						} -- 2906
					end -- 2905
					emit("AppWS", "Send", json.encode({ -- 2907
						name = "UpdateFile", -- 2907
						file = path, -- 2907
						exists = true, -- 2907
						content = content, -- 2907
						projectRoot = sourceRoot -- 2907
					})) -- 2907
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2908
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2909
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2910
					end -- 2908
				else -- 2912
					local fileData = { } -- 2912
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2913
					for _index_0 = 1, #_list_0 do -- 2913
						local subFile = _list_0[_index_0] -- 2913
						local file = Path(path, subFile) -- 2914
						local content = Content:load(file) -- 2915
						if content then -- 2915
							fileData[file] = content -- 2916
							emit("AppWS", "Send", json.encode({ -- 2917
								name = "UpdateFile", -- 2917
								file = file, -- 2917
								exists = true, -- 2917
								content = content, -- 2917
								projectRoot = sourceRoot -- 2917
							})) -- 2917
						else -- 2919
							messages[#messages + 1] = { -- 2919
								success = false, -- 2919
								file = file, -- 2919
								message = "failed to read file" -- 2919
							} -- 2919
						end -- 2915
					end -- 2913
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2920
					for file, content in pairs(fileData) do -- 2921
						if "d" == Path:getExt(Path:getName(file)) then -- 2922
							goto _continue_0 -- 2922
						end -- 2922
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2923
						::_continue_0:: -- 2922
					end -- 2921
				end -- 2901
				local success = true -- 2924
				for _index_0 = 1, #messages do -- 2925
					local item = messages[_index_0] -- 2925
					if not item.success then -- 2926
						success = false -- 2926
					end -- 2926
				end -- 2925
				local message = nil -- 2927
				if not success then -- 2928
					message = "TypeScript compilation failed" -- 2928
				end -- 2928
				buildSucceeded = success -- 2929
				return { -- 2930
					success = success, -- 2930
					messages = messages, -- 2930
					message = message -- 2930
				} -- 2930
			end -- 2893
		end -- 2893
	end -- 2893
	return { -- 2889
		success = false -- 2889
	} -- 2889
end) -- 2889
HttpServer:post("/download", function(req) -- 2932
	do -- 2933
		local _type_0 = type(req) -- 2933
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2933
		if _tab_0 then -- 2933
			local url -- 2933
			do -- 2933
				local _obj_0 = req.body -- 2933
				local _type_1 = type(_obj_0) -- 2933
				if "table" == _type_1 or "userdata" == _type_1 then -- 2933
					url = _obj_0.url -- 2933
				end -- 2933
			end -- 2933
			local target -- 2933
			do -- 2933
				local _obj_0 = req.body -- 2933
				local _type_1 = type(_obj_0) -- 2933
				if "table" == _type_1 or "userdata" == _type_1 then -- 2933
					target = _obj_0.target -- 2933
				end -- 2933
			end -- 2933
			if url ~= nil and target ~= nil then -- 2933
				local Entry = require("Script.Dev.Entry") -- 2934
				Entry.downloadFile(url, target) -- 2935
				return { -- 2936
					success = true -- 2936
				} -- 2936
			end -- 2933
		end -- 2933
	end -- 2933
	return { -- 2932
		success = false -- 2932
	} -- 2932
end) -- 2932
local isDesktopPlatform -- 2938
isDesktopPlatform = function() -- 2938
	local _val_0 = App.platform -- 2939
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2939
end -- 2938
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 2941
local nativeIDEListener = Node() -- 2942
nativeIDEListener:addTo(Director.systemUI) -- 2943
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 2944
	nativeIDEState, nativeIDEMessage = state, message -- 2945
end) -- 2944
local _anon_func_11 = function() -- 2948
	local _val_0 = App.platform -- 2948
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2948
end -- 2948
HttpServer:post("/ide", function(req) -- 2947
	if not (_anon_func_11()) then -- 2948
		return { -- 2948
			success = false, -- 2948
			message = "Native IDE is unavailable" -- 2948
		} -- 2948
	end -- 2948
	if not App.webIDEEnabled then -- 2949
		return { -- 2949
			success = false, -- 2949
			message = "Embedded Web IDE is disabled" -- 2949
		} -- 2949
	end -- 2949
	do -- 2950
		local _type_0 = type(req) -- 2950
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2950
		if _tab_0 then -- 2950
			local action -- 2950
			do -- 2950
				local _obj_0 = req.body -- 2950
				local _type_1 = type(_obj_0) -- 2950
				if "table" == _type_1 or "userdata" == _type_1 then -- 2950
					action = _obj_0.action -- 2950
				end -- 2950
			end -- 2950
			if action ~= nil then -- 2950
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 2951
					emit("AppWebView", "/ide/" .. action, true) -- 2952
					return { -- 2953
						success = true -- 2953
					} -- 2953
				end -- 2951
			end -- 2950
		end -- 2950
	end -- 2950
	return { -- 2947
		success = false, -- 2947
		message = "invalid IDE action" -- 2947
	} -- 2947
end) -- 2947
local _anon_func_12 = function() -- 2969
	local _val_0 = App.platform -- 2969
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2969
end -- 2969
local getServerStatus -- 2955
getServerStatus = function() -- 2955
	local Entry = require("Script.Dev.Entry") -- 2956
	local running = Entry.getCurrentEntryStatus() -- 2957
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2958
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2959
	return { -- 2961
		success = true, -- 2961
		platform = App.platform, -- 2962
		locale = App.locale, -- 2963
		version = App.version, -- 2964
		url = "http://localhost:8866", -- 2965
		wsConnectionCount = wsConnectionCount, -- 2966
		webIDEConnected = wsConnectionCount > 0, -- 2967
		nativeIDE = { -- 2969
			supported = _anon_func_12(), -- 2969
			enabled = App.webIDEEnabled, -- 2970
			state = nativeIDEState, -- 2971
			message = nativeIDEMessage -- 2972
		}, -- 2968
		typescriptCompiler = { -- 2974
			webIDEReady = webIDECompilerReady, -- 2974
			webIDEGeneration = webIDEConnectionGeneration, -- 2975
			embeddedSupported = supportsCompilerWebView(), -- 2976
			embeddedRequested = compilerRequested, -- 2977
			embeddedReady = compilerReady, -- 2978
			users = compilerUsers, -- 2979
			queuedJobs = #compilerJobs, -- 2980
			failure = compilerFailure -- 2981
		}, -- 2973
		assetPath = Content.assetPath, -- 2982
		writablePath = Content.writablePath, -- 2983
		appPath = Content.appPath, -- 2984
		waTemplateReady = waTemplateReady, -- 2985
		running = running -- 2986
	} -- 2960
end -- 2955
HttpServer:post("/status", function() -- 2989
	return getServerStatus() -- 2990
end) -- 2989
HttpServer:postSchedule("/doctor/fix", function(req) -- 2992
	do -- 2993
		local _type_0 = type(req) -- 2993
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2993
		if _tab_0 then -- 2993
			local openWebIDE -- 2993
			do -- 2993
				local _obj_0 = req.body -- 2993
				local _type_1 = type(_obj_0) -- 2993
				if "table" == _type_1 or "userdata" == _type_1 then -- 2993
					openWebIDE = _obj_0.openWebIDE -- 2993
				end -- 2993
			end -- 2993
			if openWebIDE ~= nil then -- 2993
				if not openWebIDE then -- 2994
					return { -- 2995
						success = false, -- 2995
						message = "nothing to fix" -- 2995
					} -- 2995
				end -- 2994
				local status = getServerStatus() -- 2996
				if status.webIDEConnected then -- 2997
					return { -- 2998
						success = true, -- 2998
						fixed = false, -- 2998
						message = "Web IDE already connected.", -- 2998
						status = status -- 2998
					} -- 2998
				end -- 2997
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2999
				if waitSeconds > 0 then -- 3000
					local deadline = os.time() + waitSeconds -- 3001
					repeat -- 3002
						sleep(0.2) -- 3003
						status = getServerStatus() -- 3004
						if status.webIDEConnected then -- 3005
							return { -- 3006
								success = true, -- 3006
								fixed = false, -- 3006
								reconnected = true, -- 3006
								message = "Web IDE reconnected.", -- 3006
								status = status -- 3006
							} -- 3006
						end -- 3005
					until os.time() >= deadline -- 3002
				end -- 3000
				if not isDesktopPlatform() then -- 3008
					return { -- 3009
						success = false, -- 3009
						message = "opening Web IDE is only supported on desktop platforms", -- 3009
						status = status -- 3009
					} -- 3009
				end -- 3008
				local url = "http://localhost:8866" -- 3010
				App:openURL(url) -- 3011
				status.openedURL = url -- 3012
				return { -- 3013
					success = true, -- 3013
					fixed = true, -- 3013
					message = "Opened Web IDE in the local browser.", -- 3013
					url = url, -- 3013
					status = status -- 3013
				} -- 3013
			end -- 2993
		end -- 2993
	end -- 2993
	return { -- 2992
		success = false, -- 2992
		message = "invalid call" -- 2992
	} -- 2992
end) -- 2992
local status = { } -- 3015
_module_0 = status -- 3016
status.transpileTSFile = transpileTSFile -- 3018
status.buildAsync = function(path) -- 3020
	if not Content:exist(path) then -- 3021
		return { -- 3022
			success = false, -- 3022
			file = path, -- 3022
			message = "file not existed" -- 3022
		} -- 3022
	end -- 3021
	do -- 3023
		local _exp_0 = Path:getExt(path) -- 3023
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 3023
			if '' == Path:getExt(Path:getName(path)) then -- 3024
				local content = Content:loadAsync(path) -- 3025
				if content then -- 3025
					local resultCodes, err = compileFileAsync(path, content) -- 3026
					if resultCodes then -- 3026
						return { -- 3027
							success = true, -- 3027
							file = path -- 3027
						} -- 3027
					else -- 3029
						return { -- 3029
							success = false, -- 3029
							file = path, -- 3029
							message = err -- 3029
						} -- 3029
					end -- 3026
				end -- 3025
			end -- 3024
		elseif "lua" == _exp_0 then -- 3030
			local content = Content:loadAsync(path) -- 3031
			if content then -- 3031
				do -- 3032
					local isTIC80 = CheckTIC80Code(content) -- 3032
					if isTIC80 then -- 3032
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 3033
					end -- 3032
				end -- 3032
				local success, info -- 3034
				do -- 3034
					local _obj_0 = luaCheck(path, content) -- 3034
					success, info = _obj_0.success, _obj_0.info -- 3034
				end -- 3034
				if success then -- 3035
					return { -- 3036
						success = true, -- 3036
						file = path -- 3036
					} -- 3036
				elseif info and #info > 0 then -- 3037
					local messages = { } -- 3038
					for _index_0 = 1, #info do -- 3039
						local _des_0 = info[_index_0] -- 3039
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3039
						local lineText = "" -- 3040
						if line then -- 3041
							local currentLine = 1 -- 3042
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3043
								if currentLine == line then -- 3044
									lineText = text -- 3045
									break -- 3046
								end -- 3044
								currentLine = currentLine + 1 -- 3047
							end -- 3043
						end -- 3041
						if line then -- 3048
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3049
						else -- 3051
							messages[#messages + 1] = message -- 3051
						end -- 3048
					end -- 3039
					return { -- 3052
						success = false, -- 3052
						file = path, -- 3052
						message = table.concat(messages, "\n") -- 3052
					} -- 3052
				else -- 3054
					return { -- 3054
						success = false, -- 3054
						file = path, -- 3054
						message = "lua check failed" -- 3054
					} -- 3054
				end -- 3035
			end -- 3031
		elseif "yarn" == _exp_0 then -- 3055
			local content = Content:loadAsync(path) -- 3056
			if content then -- 3056
				local res, _, err = yarncompile(content, true) -- 3057
				if res then -- 3057
					return { -- 3058
						success = true, -- 3058
						file = path -- 3058
					} -- 3058
				else -- 3060
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3060
					local lineText = "" -- 3061
					if line then -- 3062
						local currentLine = 1 -- 3063
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3064
							if currentLine == line then -- 3065
								lineText = text -- 3066
								break -- 3067
							end -- 3065
							currentLine = currentLine + 1 -- 3068
						end -- 3064
					end -- 3062
					if node ~= "" then -- 3069
						node = "node: " .. tostring(node) .. ", " -- 3070
					else -- 3071
						node = "" -- 3071
					end -- 3069
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3072
					return { -- 3073
						success = false, -- 3073
						file = path, -- 3073
						message = message -- 3073
					} -- 3073
				end -- 3057
			end -- 3056
		end -- 3023
	end -- 3023
	return { -- 3074
		success = false, -- 3074
		file = path, -- 3074
		message = "invalid file to build" -- 3074
	} -- 3074
end -- 3020
HttpServer:postSchedule("/git/commit-files", function(req) -- 3076
	do -- 3077
		local _type_0 = type(req) -- 3077
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3077
		if _tab_0 then -- 3077
			local body = req.body -- 3077
			if body ~= nil then -- 3077
				local repoPath, commit = body.repoPath, body.commit -- 3078
				if gitInvalidRepoPath(repoPath) then -- 3079
					return { -- 3079
						success = false, -- 3079
						message = "invalid repoPath" -- 3079
					} -- 3079
				end -- 3079
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3080
					return { -- 3080
						success = false, -- 3080
						message = "invalid commit" -- 3080
					} -- 3080
				end -- 3080
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3081
				if not res.success then -- 3082
					return res -- 3082
				end -- 3082
				return { -- 3083
					success = true, -- 3083
					status = res.status, -- 3083
					data = res.status and res.status.data -- 3083
				} -- 3083
			end -- 3077
		end -- 3077
	end -- 3077
	return invalidArguments -- 3076
end) -- 3076
thread(function() -- 3085
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3086
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3087
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3088
		local storedAsset -- 3091
		storedAsset = function(file) -- 3091
			if Content:exist(file) then -- 3092
				return Content:load(file) -- 3093
			elseif Content:exist(file .. ".gz") then -- 3094
				return Content:load(file .. ".gz") -- 3095
			else -- 3096
				return "" -- 3096
			end -- 3092
		end -- 3091
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3097
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3098
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3099
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3100
		local readyContent = table.concat({ -- 3102
			App.version, -- 3102
			storedAsset(doraWeb), -- 3103
			storedAsset(heavyAssets), -- 3104
			storedAsset(runtimeIndex), -- 3105
			storedAsset(compilerIndex), -- 3106
			storedAsset(manifest) -- 3107
		}, "\n") -- 3101
		local needReload -- 3109
		if Content:exist(doraReady) then -- 3109
			needReload = readyContent ~= Content:load(doraReady) -- 3110
		else -- 3111
			needReload = true -- 3111
		end -- 3109
		if needReload then -- 3112
			Content:remove(Path(Content.appPath, ".www")) -- 3113
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3114
			Content:save(doraReady, readyContent) -- 3118
			print("Dora Dora is ready!") -- 3119
		end -- 3112
	end -- 3088
	if App.platform == "Emscripten" then -- 3120
		status.url = nil -- 3121
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3122
	end -- 3120
	HttpServer:clearStaticCacheControls() -- 3123
	HttpServer:setStaticCacheControl("no-cache") -- 3124
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3125
	if HttpServer:start(8866) then -- 3129
		local localIP = HttpServer.localIP -- 3130
		if localIP == "" then -- 3131
			localIP = "localhost" -- 3131
		end -- 3131
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3132
		return HttpServer:startWS(8868) -- 3133
	else -- 3135
		status.url = nil -- 3135
		return print("8866 Port not available!") -- 3136
	end -- 3129
end) -- 3085
return _module_0 -- 1
