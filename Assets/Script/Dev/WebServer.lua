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
					local targetExt = Path:getExt(path) -- 1721
					for _index_0 = 1, #files do -- 1722
						local file = files[_index_0] -- 1722
						if name == Path:getName(file):lower() then -- 1723
							local ext = Path:getExt(file) -- 1724
							if not ("tl" == targetExt or "yue" == targetExt or "ts" == targetExt or "tsx" == targetExt or "vs" == targetExt or "bl" == targetExt or "xml" == targetExt or "lua" == targetExt) or not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1725
								goto _continue_0 -- 1726
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1727
								goto _continue_0 -- 1728
							end -- 1725
							return { -- 1729
								success = false, -- 1729
								message = "SourceExisted" -- 1729
							} -- 1729
						end -- 1723
						::_continue_0:: -- 1723
					end -- 1722
					if Content:save(path, content) then -- 1730
						return { -- 1731
							success = true -- 1731
						} -- 1731
					end -- 1730
				end -- 1712
			end -- 1707
		end -- 1707
	end -- 1707
	return { -- 1706
		success = false, -- 1706
		message = "Failed" -- 1706
	} -- 1706
end) -- 1706
local deleteAsset -- 1733
deleteAsset = function(path) -- 1733
	if not Content:exist(path) then -- 1734
		return false -- 1734
	end -- 1734
	local projectRoot -- 1735
	if Content:isdir(path) and isProjectRootDir(path) then -- 1735
		projectRoot = path -- 1735
	else -- 1735
		projectRoot = nil -- 1735
	end -- 1735
	local parent = Path:getPath(path) -- 1736
	local files = Content:getFiles(parent) -- 1737
	local name = Path:getName(path):lower() -- 1738
	local ext = Path:getExt(path) -- 1739
	for _index_0 = 1, #files do -- 1740
		local file = files[_index_0] -- 1740
		if name == Path:getName(file):lower() then -- 1741
			local _exp_0 = Path:getExt(file) -- 1742
			if "tl" == _exp_0 then -- 1742
				if ("vs" == ext) then -- 1742
					Content:remove(Path(parent, file)) -- 1743
				end -- 1742
			elseif "lua" == _exp_0 then -- 1744
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1744
					Content:remove(Path(parent, file)) -- 1745
				end -- 1744
			end -- 1742
		end -- 1741
	end -- 1740
	if Content:remove(path) then -- 1746
		if projectRoot then -- 1747
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1748
		end -- 1747
		return true -- 1749
	end -- 1746
	return false -- 1750
end -- 1733
local moveAsset -- 1752
moveAsset = function(old, new) -- 1752
	if not (Content:exist(old) and not Content:exist(new)) then -- 1753
		return false -- 1753
	end -- 1753
	local renamedDir = Content:isdir(old) -- 1754
	local parent = Path:getPath(new) -- 1755
	local files = Content:getFiles(parent) -- 1756
	if renamedDir then -- 1757
		local name = Path:getFilename(new):lower() -- 1758
		for _index_0 = 1, #files do -- 1759
			local file = files[_index_0] -- 1759
			if name == Path:getFilename(file):lower() then -- 1760
				return false -- 1761
			end -- 1760
		end -- 1759
	else -- 1763
		local name = Path:getName(new):lower() -- 1763
		local ext = Path:getExt(new) -- 1764
		for _index_0 = 1, #files do -- 1765
			local file = files[_index_0] -- 1765
			if name == Path:getName(file):lower() then -- 1766
				local fileExt = Path:getExt(file) -- 1767
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) or not ("tl" == fileExt or "yue" == fileExt or "ts" == fileExt or "tsx" == fileExt or "vs" == fileExt or "bl" == fileExt or "xml" == fileExt or "lua" == fileExt) then -- 1768
					goto _continue_0 -- 1769
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1770
					goto _continue_0 -- 1771
				end -- 1768
				return false -- 1772
			end -- 1766
			::_continue_0:: -- 1766
		end -- 1765
	end -- 1757
	if not Content:move(old, new) then -- 1773
		return false -- 1773
	end -- 1773
	if renamedDir then -- 1774
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1775
	end -- 1774
	local newParent = Path:getPath(new) -- 1776
	parent = Path:getPath(old) -- 1777
	files = Content:getFiles(parent) -- 1778
	local newName = Path:getName(new) -- 1779
	local oldName = Path:getName(old) -- 1780
	local name = oldName:lower() -- 1781
	local ext = Path:getExt(old) -- 1782
	for _index_0 = 1, #files do -- 1783
		local file = files[_index_0] -- 1783
		if name == Path:getName(file):lower() then -- 1784
			local _exp_0 = Path:getExt(file) -- 1785
			if "tl" == _exp_0 then -- 1785
				if ("vs" == ext) then -- 1785
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1786
				end -- 1785
			elseif "lua" == _exp_0 then -- 1787
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1787
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1788
				end -- 1787
			end -- 1785
		end -- 1784
	end -- 1783
	return true -- 1789
end -- 1752
HttpServer:post("/delete", function(req) -- 1791
	do -- 1792
		local _type_0 = type(req) -- 1792
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1792
		if _tab_0 then -- 1792
			local path -- 1792
			do -- 1792
				local _obj_0 = req.body -- 1792
				local _type_1 = type(_obj_0) -- 1792
				if "table" == _type_1 or "userdata" == _type_1 then -- 1792
					path = _obj_0.path -- 1792
				end -- 1792
			end -- 1792
			if path ~= nil then -- 1792
				if deleteAsset(path) then -- 1793
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
HttpServer:post("/rename", function(req) -- 1795
	do -- 1796
		local _type_0 = type(req) -- 1796
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1796
		if _tab_0 then -- 1796
			local old -- 1796
			do -- 1796
				local _obj_0 = req.body -- 1796
				local _type_1 = type(_obj_0) -- 1796
				if "table" == _type_1 or "userdata" == _type_1 then -- 1796
					old = _obj_0.old -- 1796
				end -- 1796
			end -- 1796
			local new -- 1796
			do -- 1796
				local _obj_0 = req.body -- 1796
				local _type_1 = type(_obj_0) -- 1796
				if "table" == _type_1 or "userdata" == _type_1 then -- 1796
					new = _obj_0.new -- 1796
				end -- 1796
			end -- 1796
			if old ~= nil and new ~= nil then -- 1796
				if moveAsset(old, new) then -- 1797
					return { -- 1797
						success = true -- 1797
					} -- 1797
				end -- 1797
			end -- 1796
		end -- 1796
	end -- 1796
	return { -- 1795
		success = false -- 1795
	} -- 1795
end) -- 1795
local normalizeAssetPaths -- 1799
normalizeAssetPaths = function(paths) -- 1799
	if not (type(paths) == "table") then -- 1800
		return nil -- 1800
	end -- 1800
	local unique = { } -- 1801
	local candidates = { } -- 1802
	for _index_0 = 1, #paths do -- 1803
		local path = paths[_index_0] -- 1803
		if not (type(path) == "string") then -- 1804
			return nil -- 1804
		end -- 1804
		local relative = relativeToRoot(path, Content.writablePath) -- 1805
		if relative == nil or relative == "" or not Content:exist(path) then -- 1806
			return nil -- 1806
		end -- 1806
		if not unique[path] then -- 1807
			unique[path] = true -- 1808
			candidates[#candidates + 1] = path -- 1809
		end -- 1807
	end -- 1803
	table.sort(candidates, function(a, b) -- 1810
		return #a < #b -- 1810
	end) -- 1810
	local result = { } -- 1811
	for _index_0 = 1, #candidates do -- 1812
		local path = candidates[_index_0] -- 1812
		local contained = false -- 1813
		for _index_1 = 1, #result do -- 1814
			local parent = result[_index_1] -- 1814
			if relativeToRoot(path, parent) ~= nil then -- 1815
				contained = true -- 1816
				break -- 1817
			end -- 1815
		end -- 1814
		if not contained then -- 1818
			result[#result + 1] = path -- 1818
		end -- 1818
	end -- 1812
	return result -- 1819
end -- 1799
HttpServer:postSchedule("/assets/batch", function(req) -- 1821
	do -- 1822
		local _type_0 = type(req) -- 1822
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1822
		if _tab_0 then -- 1822
			local operation -- 1822
			do -- 1822
				local _obj_0 = req.body -- 1822
				local _type_1 = type(_obj_0) -- 1822
				if "table" == _type_1 or "userdata" == _type_1 then -- 1822
					operation = _obj_0.operation -- 1822
				end -- 1822
			end -- 1822
			local sources -- 1822
			do -- 1822
				local _obj_0 = req.body -- 1822
				local _type_1 = type(_obj_0) -- 1822
				if "table" == _type_1 or "userdata" == _type_1 then -- 1822
					sources = _obj_0.sources -- 1822
				end -- 1822
			end -- 1822
			if operation ~= nil and sources ~= nil then -- 1822
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1823
					return { -- 1823
						success = false, -- 1823
						message = "invalid operation" -- 1823
					} -- 1823
				end -- 1823
				sources = normalizeAssetPaths(sources) -- 1824
				if not (sources and #sources > 0) then -- 1825
					return { -- 1825
						success = false, -- 1825
						message = "invalid sources" -- 1825
					} -- 1825
				end -- 1825
				local target = req.body.target -- 1826
				local destinations = { } -- 1827
				if operation ~= "delete" then -- 1828
					if not (type(target) == "string") then -- 1829
						return { -- 1829
							success = false, -- 1829
							message = "invalid target" -- 1829
						} -- 1829
					end -- 1829
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1830
					if targetRelative == nil then -- 1831
						return { -- 1831
							success = false, -- 1831
							message = "invalid target" -- 1831
						} -- 1831
					end -- 1831
					if not (Content:exist(target) and Content:isdir(target)) then -- 1832
						return { -- 1832
							success = false, -- 1832
							message = "invalid target" -- 1832
						} -- 1832
					end -- 1832
					for _index_0 = 1, #sources do -- 1833
						local source = sources[_index_0] -- 1833
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1834
							return { -- 1835
								success = false, -- 1835
								message = "target inside source" -- 1835
							} -- 1835
						end -- 1834
						local destination = Path(target, Path:getFilename(source)) -- 1836
						if Content:exist(destination) then -- 1837
							return { -- 1837
								success = false, -- 1837
								message = "target existed" -- 1837
							} -- 1837
						end -- 1837
						if destinations[destination] then -- 1838
							return { -- 1838
								success = false, -- 1838
								message = "duplicate target" -- 1838
							} -- 1838
						end -- 1838
						destinations[destination] = true -- 1839
					end -- 1833
				end -- 1828
				local changes = { } -- 1840
				local affectedSet = { } -- 1841
				local affectedDirectories = { } -- 1842
				local addAffected -- 1843
				addAffected = function(dir) -- 1843
					if affectedSet[dir] then -- 1844
						return -- 1844
					end -- 1844
					affectedSet[dir] = true -- 1845
					affectedDirectories[#affectedDirectories + 1] = dir -- 1846
				end -- 1843
				if operation ~= "delete" then -- 1847
					addAffected(target) -- 1847
				end -- 1847
				for _index_0 = 1, #sources do -- 1848
					local source = sources[_index_0] -- 1848
					addAffected(Path:getPath(source)) -- 1849
					if operation == "delete" then -- 1850
						if not deleteAsset(source) then -- 1851
							return { -- 1851
								success = false, -- 1851
								message = "delete failed", -- 1851
								changes = changes, -- 1851
								affectedDirectories = affectedDirectories -- 1851
							} -- 1851
						end -- 1851
						changes[#changes + 1] = { -- 1852
							old = source -- 1852
						} -- 1852
					else -- 1854
						local destination = Path(target, Path:getFilename(source)) -- 1854
						local ok -- 1855
						if operation == "copy" then -- 1855
							ok = Content:copyAsync(source, destination) -- 1856
						else -- 1858
							ok = moveAsset(source, destination) -- 1858
						end -- 1855
						if not ok then -- 1859
							return { -- 1859
								success = false, -- 1859
								message = operation .. " failed", -- 1859
								changes = changes, -- 1859
								affectedDirectories = affectedDirectories -- 1859
							} -- 1859
						end -- 1859
						changes[#changes + 1] = { -- 1860
							old = source, -- 1860
							new = destination -- 1860
						} -- 1860
					end -- 1850
				end -- 1848
				return { -- 1861
					success = true, -- 1861
					changes = changes, -- 1861
					affectedDirectories = affectedDirectories -- 1861
				} -- 1861
			end -- 1822
		end -- 1822
	end -- 1822
	return { -- 1821
		success = false, -- 1821
		message = "invalid request" -- 1821
	} -- 1821
end) -- 1821
local withProjectSearchPaths -- 1863
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1863
	local fallbackPaths = { } -- 1864
	local addFallback -- 1865
	addFallback = function(dir) -- 1865
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1865
			fallbackPaths[#fallbackPaths + 1] = dir -- 1865
		end -- 1865
	end -- 1865
	if projectRoot and projectRoot ~= "" then -- 1866
		addFallback(Path(projectRoot, "Script")) -- 1867
		addFallback(projectRoot) -- 1868
	end -- 1866
	if projFile then -- 1869
		local projDir = getProjectDirFromFile(projFile) -- 1870
		if projDir then -- 1870
			addFallback(Path(projDir, "Script")) -- 1871
			addFallback(projDir) -- 1872
		else -- 1874
			addFallback(Path:getPath(projFile)) -- 1874
		end -- 1870
	end -- 1869
	if not (#fallbackPaths > 0) then -- 1875
		return fn() -- 1875
	end -- 1875
	local searchPaths = Content.searchPaths -- 1876
	for _index_0 = 1, #fallbackPaths do -- 1877
		local dir = fallbackPaths[_index_0] -- 1877
		Content:addSearchPath(dir) -- 1877
	end -- 1877
	local _ <close> = setmetatable({ }, { -- 1878
		__close = function() -- 1878
			Content.searchPaths = searchPaths -- 1878
		end -- 1878
	}) -- 1878
	return fn() -- 1879
end -- 1863
HttpServer:post("/exist", function(req) -- 1880
	do -- 1881
		local _type_0 = type(req) -- 1881
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1881
		if _tab_0 then -- 1881
			local file -- 1881
			do -- 1881
				local _obj_0 = req.body -- 1881
				local _type_1 = type(_obj_0) -- 1881
				if "table" == _type_1 or "userdata" == _type_1 then -- 1881
					file = _obj_0.file -- 1881
				end -- 1881
			end -- 1881
			if file ~= nil then -- 1881
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1882
					return { -- 1883
						success = Content:exist(file) -- 1883
					} -- 1883
				end) -- 1882
			end -- 1881
		end -- 1881
	end -- 1881
	return { -- 1880
		success = false -- 1880
	} -- 1880
end) -- 1880
HttpServer:postSchedule("/read", function(req) -- 1884
	do -- 1885
		local _type_0 = type(req) -- 1885
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1885
		if _tab_0 then -- 1885
			local path -- 1885
			do -- 1885
				local _obj_0 = req.body -- 1885
				local _type_1 = type(_obj_0) -- 1885
				if "table" == _type_1 or "userdata" == _type_1 then -- 1885
					path = _obj_0.path -- 1885
				end -- 1885
			end -- 1885
			if path ~= nil then -- 1885
				local readFile -- 1886
				readFile = function() -- 1886
					if Content:exist(path) and not Content:isdir(path) then -- 1887
						local content = Content:loadAsync(path) -- 1888
						if content then -- 1888
							return { -- 1889
								content = content, -- 1889
								success = true, -- 1889
								fullPath = Content:getFullPath(path) -- 1889
							} -- 1889
						end -- 1888
					end -- 1887
					return nil -- 1886
				end -- 1886
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1890
				if result then -- 1890
					return result -- 1890
				end -- 1890
			end -- 1885
		end -- 1885
	end -- 1885
	return { -- 1884
		success = false -- 1884
	} -- 1884
end) -- 1884
local agentDocLanguage -- 1892
agentDocLanguage = function(language) -- 1892
	if language == "zh-Hans" then -- 1893
		return "zh" -- 1893
	else -- 1893
		return "en" -- 1893
	end -- 1893
end -- 1892
HttpServer:postSchedule("/doc/search", function(req) -- 1895
	local body = req.body or { } -- 1896
	local language = body.docLanguage -- 1897
	if not (("en" == language or "zh-Hans" == language)) then -- 1898
		return { -- 1898
			success = false, -- 1898
			message = "unsupported doc language" -- 1898
		} -- 1898
	end -- 1898
	local docType = body.docType -- 1899
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1900
		return { -- 1900
			success = false, -- 1900
			message = "unsupported doc type" -- 1900
		} -- 1900
	end -- 1900
	local codeLanguage = body.programmingLanguage -- 1901
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1902
		return { -- 1902
			success = false, -- 1902
			message = "unsupported programming language" -- 1902
		} -- 1902
	end -- 1902
	if not body.pattern then -- 1903
		return { -- 1903
			success = false, -- 1903
			message = "missing pattern" -- 1903
		} -- 1903
	end -- 1903
	local result = nil -- 1904
	AgentTools.searchDoraDocHttp({ -- 1906
		pattern = body.pattern, -- 1906
		docLanguage = agentDocLanguage(language), -- 1907
		docType = docType, -- 1908
		programmingLanguage = codeLanguage, -- 1909
		limit = body.limit, -- 1910
		useRegex = body.useRegex, -- 1911
		caseSensitive = body.caseSensitive, -- 1912
		includeContent = body.includeContent, -- 1913
		contentWindow = body.contentWindow -- 1914
	}, function(res) -- 1915
		result = res -- 1916
	end) -- 1905
	wait(function() -- 1917
		return result ~= nil -- 1917
	end) -- 1917
	if result and result.success then -- 1918
		result.docLanguage = language -- 1919
	end -- 1918
	if result then -- 1920
		return result -- 1921
	else -- 1923
		return { -- 1923
			success = false, -- 1923
			message = "doc search failed" -- 1923
		} -- 1923
	end -- 1920
	return { -- 1895
		success = false, -- 1895
		message = "invalid call" -- 1895
	} -- 1895
end) -- 1895
HttpServer:postSchedule("/doc/read", function(req) -- 1925
	local body = req.body or { } -- 1926
	local language = body.docLanguage -- 1927
	if not (("en" == language or "zh-Hans" == language)) then -- 1928
		return { -- 1928
			success = false, -- 1928
			message = "unsupported doc language" -- 1928
		} -- 1928
	end -- 1928
	if not body.file then -- 1929
		return { -- 1929
			success = false, -- 1929
			message = "missing file" -- 1929
		} -- 1929
	end -- 1929
	local result = AgentTools.readDoraDoc({ -- 1931
		docLanguage = agentDocLanguage(language), -- 1931
		file = body.file, -- 1932
		startLine = body.startLine, -- 1933
		endLine = body.endLine -- 1934
	}) -- 1930
	if result and result.success then -- 1935
		result.docLanguage = language -- 1936
	end -- 1935
	return result -- 1937
end) -- 1925
local readSyncFile -- 1939
readSyncFile = function(req) -- 1939
	do -- 1940
		local _type_0 = type(req) -- 1940
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1940
		if _tab_0 then -- 1940
			local params = req.params -- 1940
			if params ~= nil then -- 1940
				local path = params.path -- 1941
				if not (type(path) == "string" and path ~= "") then -- 1942
					return { -- 1942
						success = false, -- 1942
						message = "invalid path" -- 1942
					} -- 1942
				end -- 1942
				local exts -- 1943
				if params.exts then -- 1943
					local _accum_0 = { } -- 1944
					local _len_0 = 1 -- 1944
					for ext in params.exts:gmatch("[^|]*") do -- 1944
						_accum_0[_len_0] = ext -- 1944
						_len_0 = _len_0 + 1 -- 1944
					end -- 1944
					exts = _accum_0 -- 1944
				else -- 1945
					exts = { -- 1945
						"" -- 1945
					} -- 1945
				end -- 1943
				local readFileAt -- 1946
				readFileAt = function(targetPath) -- 1946
					if Content:exist(targetPath) then -- 1947
						local content = Content:load(targetPath) -- 1948
						if content then -- 1948
							return { -- 1949
								content = content, -- 1949
								success = true, -- 1949
								fullPath = Content:getFullPath(targetPath) -- 1949
							} -- 1949
						end -- 1948
					end -- 1947
					return nil -- 1946
				end -- 1946
				local readFile -- 1950
				readFile = function(fallbackPaths) -- 1950
					for _index_0 = 1, #exts do -- 1951
						local ext = exts[_index_0] -- 1951
						local targetPath = path .. ext -- 1952
						if not Content:isAbsolutePath(targetPath) then -- 1953
							for _index_1 = 1, #fallbackPaths do -- 1954
								local fallback = fallbackPaths[_index_1] -- 1954
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1955
								if fallbackResult then -- 1955
									return fallbackResult -- 1956
								end -- 1955
							end -- 1954
						end -- 1953
						local fileResult = readFileAt(targetPath) -- 1957
						if fileResult then -- 1957
							return fileResult -- 1958
						end -- 1957
					end -- 1951
					return nil -- 1950
				end -- 1950
				local fallbackPaths = { } -- 1959
				local fallbackCandidates = { } -- 1960
				do -- 1961
					local projectRoot = req.params.projectRoot -- 1961
					if projectRoot then -- 1961
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1962
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1963
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1964
						end -- 1962
					end -- 1961
				end -- 1961
				do -- 1965
					local projFile = req.params.projFile -- 1965
					if projFile then -- 1965
						local projDir = getProjectDirFromFile(projFile) -- 1966
						if projDir then -- 1966
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1967
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1968
						else -- 1970
							projDir = Path:getPath(projFile) -- 1970
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1971
						end -- 1966
					end -- 1965
				end -- 1965
				for _index_0 = 1, #fallbackCandidates do -- 1972
					local dir = fallbackCandidates[_index_0] -- 1972
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1973
						local exists = false -- 1974
						for _index_1 = 1, #fallbackPaths do -- 1975
							local fallback = fallbackPaths[_index_1] -- 1975
							if fallback == dir then -- 1976
								exists = true -- 1977
								break -- 1978
							end -- 1976
						end -- 1975
						if not exists then -- 1979
							fallbackPaths[#fallbackPaths + 1] = dir -- 1979
						end -- 1979
					end -- 1973
				end -- 1972
				local readResult = readFile(fallbackPaths) -- 1980
				if readResult then -- 1980
					return readResult -- 1981
				end -- 1980
			end -- 1940
		end -- 1940
	end -- 1940
	return { -- 1939
		success = false -- 1939
	} -- 1939
end -- 1939
HttpServer:get("/read-sync", readSyncFile) -- 1983
HttpServer:post("/read-sync", function(req) -- 1984
	return readSyncFile({ -- 1984
		params = req.body -- 1984
	}) -- 1984
end) -- 1984
local addGeneratedSourceHeader -- 1986
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 1986
	if preserveTIC80 == nil then -- 1986
		preserveTIC80 = false -- 1986
	end -- 1986
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 1987
	if preserveTIC80 then -- 1988
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 1989
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 1990
		end -- 1989
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 1991
	end -- 1988
	return tostring(header) .. "\n" .. tostring(codes) -- 1992
end -- 1986
local compileFileAsync -- 1994
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1994
	if projectRoot == nil then -- 1994
		projectRoot = nil -- 1994
	end -- 1994
	local file = inputFile -- 1995
	local searchPath -- 1996
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1996
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1997
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 2001
	elseif not Content:isAbsolutePath(inputFile) then -- 2002
		searchPath = "" -- 2003
	else -- 2004
		local dir = getProjectDirFromFile(inputFile) -- 2004
		if dir then -- 2004
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2005
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 2009
		else -- 2011
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2011
			searchPath = "" -- 2014
		end -- 2004
	end -- 1996
	local outputFile = Path:replaceExt(inputFile, "lua") -- 2015
	local yueext = yue.options.extension -- 2016
	local resultCodes = nil -- 2017
	local resultError = nil -- 2018
	do -- 2019
		local _exp_0 = Path:getExt(inputFile) -- 2019
		if yueext == _exp_0 then -- 2019
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 2020
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 2021
				if not codes then -- 2022
					resultError = err -- 2023
					return -- 2024
				end -- 2022
				local extraGlobal -- 2025
				if isTIC80 then -- 2025
					extraGlobal = tic80APIs -- 2025
				else -- 2025
					extraGlobal = nil -- 2025
				end -- 2025
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 2026
				if not success then -- 2027
					resultError = message -- 2028
					return -- 2029
				end -- 2027
				if codes == "" then -- 2030
					resultCodes = "" -- 2031
					return nil -- 2032
				end -- 2030
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 2033
				return resultCodes -- 2034
			end, function(success) -- 2021
				if not success then -- 2035
					Content:remove(outputFile) -- 2036
					if resultCodes == nil then -- 2037
						resultCodes = false -- 2038
					end -- 2037
				end -- 2035
			end) -- 2021
		elseif "tl" == _exp_0 then -- 2039
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 2040
			if isTIC80 then -- 2041
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2042
			end -- 2041
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2043
			if codes then -- 2043
				if isTIC80 then -- 2044
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2045
				end -- 2044
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2046
				Content:saveAsync(outputFile, resultCodes) -- 2047
			else -- 2049
				Content:remove(outputFile) -- 2049
				resultCodes = false -- 2050
				resultError = err -- 2051
			end -- 2043
		elseif "xml" == _exp_0 then -- 2052
			local codes, err = xml.tolua(sourceCodes) -- 2053
			if codes then -- 2053
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2054
				Content:saveAsync(outputFile, resultCodes) -- 2055
			else -- 2057
				Content:remove(outputFile) -- 2057
				resultCodes = false -- 2058
				resultError = err -- 2059
			end -- 2053
		end -- 2019
	end -- 2019
	wait(function() -- 2060
		return resultCodes ~= nil -- 2060
	end) -- 2060
	if resultCodes then -- 2061
		return resultCodes -- 2062
	else -- 2064
		return nil, resultError -- 2064
	end -- 2061
	return nil -- 1994
end -- 1994
HttpServer:postSchedule("/write", function(req) -- 2066
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2067
	local buildSucceeded = false -- 2068
	local _ <close> = setmetatable({ }, { -- 2069
		__close = function() -- 2069
			return finishUpdate(buildSucceeded) -- 2069
		end -- 2069
	}) -- 2069
	do -- 2070
		local _type_0 = type(req) -- 2070
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2070
		if _tab_0 then -- 2070
			local path -- 2070
			do -- 2070
				local _obj_0 = req.body -- 2070
				local _type_1 = type(_obj_0) -- 2070
				if "table" == _type_1 or "userdata" == _type_1 then -- 2070
					path = _obj_0.path -- 2070
				end -- 2070
			end -- 2070
			local content -- 2070
			do -- 2070
				local _obj_0 = req.body -- 2070
				local _type_1 = type(_obj_0) -- 2070
				if "table" == _type_1 or "userdata" == _type_1 then -- 2070
					content = _obj_0.content -- 2070
				end -- 2070
			end -- 2070
			if path ~= nil and content ~= nil then -- 2070
				if Content:saveAsync(path, content) then -- 2071
					do -- 2072
						local _exp_0 = Path:getExt(path) -- 2072
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2072
							if '' == Path:getExt(Path:getName(path)) then -- 2073
								local resultCodes = compileFileAsync(path, content) -- 2074
								buildSucceeded = resultCodes ~= nil -- 2075
								return { -- 2076
									success = true, -- 2076
									resultCodes = resultCodes -- 2076
								} -- 2076
							end -- 2073
						end -- 2072
					end -- 2072
					buildSucceeded = true -- 2077
					return { -- 2078
						success = true -- 2078
					} -- 2078
				end -- 2071
			end -- 2070
		end -- 2070
	end -- 2070
	return { -- 2066
		success = false -- 2066
	} -- 2066
end) -- 2066
local getWaProjectDirFromFile = nil -- 2080
HttpServer:postSchedule("/build", function(req) -- 2082
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2083
	local buildSucceeded = false -- 2084
	local _ <close> = setmetatable({ }, { -- 2085
		__close = function() -- 2085
			return finishUpdate(buildSucceeded) -- 2085
		end -- 2085
	}) -- 2085
	do -- 2086
		local _type_0 = type(req) -- 2086
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2086
		if _tab_0 then -- 2086
			local path -- 2086
			do -- 2086
				local _obj_0 = req.body -- 2086
				local _type_1 = type(_obj_0) -- 2086
				if "table" == _type_1 or "userdata" == _type_1 then -- 2086
					path = _obj_0.path -- 2086
				end -- 2086
			end -- 2086
			if path ~= nil then -- 2086
				local projectRoot = req.body.projectRoot -- 2087
				if Content:isdir(path) then -- 2088
					local projDir = getWaProjectDirFromFile(path) -- 2089
					if projDir then -- 2089
						local message = Wasm:buildWaAsync(projDir) -- 2090
						if message == "" then -- 2091
							return { -- 2092
								success = true -- 2092
							} -- 2092
						else -- 2094
							return { -- 2094
								success = false, -- 2094
								message = message -- 2094
							} -- 2094
						end -- 2091
					end -- 2089
				end -- 2088
				local _exp_0 = Path:getExt(path) -- 2095
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2096
					if '' == Path:getExt(Path:getName(path)) then -- 2097
						local content = Content:loadAsync(path) -- 2098
						if content then -- 2098
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2099
							if resultCodes then -- 2099
								buildSucceeded = true -- 2100
								return { -- 2101
									success = true, -- 2101
									resultCodes = resultCodes -- 2101
								} -- 2101
							end -- 2099
						end -- 2098
					end -- 2097
				elseif "wa" == _exp_0 then -- 2102
					local projDir = getWaProjectDirFromFile(path) -- 2103
					if projDir then -- 2103
						local message = Wasm:buildWaAsync(projDir) -- 2104
						if message == "" then -- 2105
							return { -- 2106
								success = true -- 2106
							} -- 2106
						else -- 2108
							return { -- 2108
								success = false, -- 2108
								message = message -- 2108
							} -- 2108
						end -- 2105
					else -- 2110
						return { -- 2110
							success = false, -- 2110
							message = 'Wa file needs a project' -- 2110
						} -- 2110
					end -- 2103
				end -- 2095
			end -- 2086
		end -- 2086
	end -- 2086
	return { -- 2082
		success = false -- 2082
	} -- 2082
end) -- 2082
local extentionLevels = { -- 2113
	vs = 2, -- 2113
	bl = 2, -- 2114
	ts = 1, -- 2115
	tsx = 1, -- 2116
	tl = 1, -- 2117
	yue = 1, -- 2118
	xml = 1, -- 2119
	lua = 0 -- 2120
} -- 2112
local visitAssets -- 2122
visitAssets = function(path, workspace, builtin, recursive) -- 2122
	if recursive == nil then -- 2122
		recursive = true -- 2122
	end -- 2122
	local children = nil -- 2123
	local dirs = Content:getDirs(path) -- 2124
	for _index_0 = 1, #dirs do -- 2125
		local dir = dirs[_index_0] -- 2125
		if workspace then -- 2126
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or ".godot" == dir or "node_modules" == dir) then -- 2127
				goto _continue_0 -- 2128
			end -- 2127
		elseif dir == ".git" or dir == ".godot" then -- 2129
			goto _continue_0 -- 2130
		end -- 2126
		if not children then -- 2131
			children = { } -- 2131
		end -- 2131
		local dirPath = Path(path, dir) -- 2132
		if recursive then -- 2133
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2134
		else -- 2136
			children[#children + 1] = { -- 2137
				key = dirPath, -- 2137
				dir = true, -- 2138
				title = dir, -- 2139
				builtin = builtin, -- 2140
				isLeaf = false -- 2141
			} -- 2136
		end -- 2133
		::_continue_0:: -- 2126
	end -- 2125
	local files = Content:getFiles(path) -- 2143
	local names = { } -- 2144
	for _index_0 = 1, #files do -- 2145
		local file = files[_index_0] -- 2145
		if (".DS_Store" == file) then -- 2146
			goto _continue_1 -- 2147
		end -- 2146
		local ext = Path:getExt(file) -- 2148
		if not extentionLevels[ext] then -- 2149
			names[file] = "" -- 2150
			goto _continue_1 -- 2151
		end -- 2149
		local name = Path:getName(file) -- 2152
		ext = names[name] -- 2153
		if ext then -- 2153
			local lv1 -- 2154
			do -- 2154
				local _exp_0 = extentionLevels[ext] -- 2154
				if _exp_0 ~= nil then -- 2154
					lv1 = _exp_0 -- 2154
				else -- 2154
					lv1 = -1 -- 2154
				end -- 2154
			end -- 2154
			ext = Path:getExt(file) -- 2155
			local lv2 -- 2156
			do -- 2156
				local _exp_0 = extentionLevels[ext] -- 2156
				if _exp_0 ~= nil then -- 2156
					lv2 = _exp_0 -- 2156
				else -- 2156
					lv2 = -1 -- 2156
				end -- 2156
			end -- 2156
			if lv2 > lv1 then -- 2157
				names[name] = ext -- 2158
			elseif lv2 == lv1 then -- 2159
				names[name .. '.' .. ext] = "" -- 2160
			end -- 2157
		else -- 2162
			ext = Path:getExt(file) -- 2162
			if not extentionLevels[ext] then -- 2163
				names[file] = "" -- 2164
			else -- 2166
				names[name] = ext -- 2166
			end -- 2163
		end -- 2153
		::_continue_1:: -- 2146
	end -- 2145
	do -- 2167
		local _accum_0 = { } -- 2167
		local _len_0 = 1 -- 2167
		for name, ext in pairs(names) do -- 2167
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2167
			_len_0 = _len_0 + 1 -- 2167
		end -- 2167
		files = _accum_0 -- 2167
	end -- 2167
	for _index_0 = 1, #files do -- 2168
		local file = files[_index_0] -- 2168
		if not children then -- 2169
			children = { } -- 2169
		end -- 2169
		children[#children + 1] = { -- 2171
			key = Path(path, file), -- 2171
			dir = false, -- 2172
			title = file, -- 2173
			builtin = builtin -- 2174
		} -- 2170
	end -- 2168
	if children then -- 2176
		table.sort(children, function(a, b) -- 2177
			if a.dir == b.dir then -- 2178
				return a.title < b.title -- 2179
			else -- 2181
				return a.dir -- 2181
			end -- 2178
		end) -- 2177
	end -- 2176
	return { -- 2183
		key = path, -- 2183
		dir = true, -- 2184
		title = Path:getFilename(path), -- 2185
		builtin = builtin, -- 2186
		isLeaf = not children, -- 2187
		children = children -- 2188
	} -- 2182
end -- 2122
HttpServer:post("/assets/children", function(req) -- 2191
	do -- 2192
		local _type_0 = type(req) -- 2192
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2192
		if _tab_0 then -- 2192
			local path -- 2192
			do -- 2192
				local _obj_0 = req.body -- 2192
				local _type_1 = type(_obj_0) -- 2192
				if "table" == _type_1 or "userdata" == _type_1 then -- 2192
					path = _obj_0.path -- 2192
				end -- 2192
			end -- 2192
			if path ~= nil then -- 2192
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2193
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2194
					return { -- 2194
						success = false -- 2194
					} -- 2194
				end -- 2194
				local node = visitAssets(path, workspace, builtin, false) -- 2195
				return { -- 2196
					success = true, -- 2196
					children = node.children or { } -- 2196
				} -- 2196
			end -- 2192
		end -- 2192
	end -- 2192
	return { -- 2191
		success = false -- 2191
	} -- 2191
end) -- 2191
HttpServer:post("/assets/files", function(req) -- 2198
	do -- 2199
		local _type_0 = type(req) -- 2199
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2199
		if _tab_0 then -- 2199
			local path -- 2199
			do -- 2199
				local _obj_0 = req.body -- 2199
				local _type_1 = type(_obj_0) -- 2199
				if "table" == _type_1 or "userdata" == _type_1 then -- 2199
					path = _obj_0.path -- 2199
				end -- 2199
			end -- 2199
			if path ~= nil then -- 2199
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2200
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2201
				if not (workspace or builtin) then -- 2202
					return { -- 2202
						success = false -- 2202
					} -- 2202
				end -- 2202
				if not (Content:exist(path) and Content:isdir(path)) then -- 2203
					return { -- 2203
						success = false -- 2203
					} -- 2203
				end -- 2203
				local globs = { -- 2204
					"**", -- 2204
					"!**/.DS_Store", -- 2204
					"!**/.godot/**" -- 2204
				} -- 2204
				if workspace then -- 2205
					globs = { -- 2207
						"**", -- 2207
						"!**/.DS_Store", -- 2207
						"!**/.upload/**", -- 2208
						"!**/.download/**", -- 2208
						"!**/.www/**", -- 2209
						"!**/.build/**", -- 2209
						"!**/.git/**", -- 2210
						"!**/.cache/**", -- 2210
						"!**/.godot/**", -- 2211
						"!**/node_modules/**" -- 2212
					} -- 2206
				end -- 2205
				local files -- 2214
				do -- 2214
					local _accum_0 = { } -- 2214
					local _len_0 = 1 -- 2214
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2214
					for _index_0 = 1, #_list_0 do -- 2214
						local file = _list_0[_index_0] -- 2214
						_accum_0[_len_0] = Path(path, file) -- 2214
						_len_0 = _len_0 + 1 -- 2214
					end -- 2214
					files = _accum_0 -- 2214
				end -- 2214
				return { -- 2215
					success = true, -- 2215
					files = files -- 2215
				} -- 2215
			end -- 2199
		end -- 2199
	end -- 2199
	return { -- 2198
		success = false -- 2198
	} -- 2198
end) -- 2198
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2256
	local _tab_0 = { -- 2256
		{ -- 2257
			key = Path(Content.assetPath), -- 2257
			dir = true, -- 2258
			builtin = true, -- 2259
			title = zh and "内置资源" or "Built-in", -- 2260
			children = builtinChildren -- 2261
		} -- 2256
	} -- 2263
	local _obj_0 = workspace.children or { } -- 2263
	local _idx_0 = #_tab_0 + 1 -- 2263
	for _index_0 = 1, #_obj_0 do -- 2263
		local _value_0 = _obj_0[_index_0] -- 2263
		_tab_0[_idx_0] = _value_0 -- 2263
		_idx_0 = _idx_0 + 1 -- 2263
	end -- 2263
	return _tab_0 -- 2256
end -- 2256
HttpServer:post("/assets", function() -- 2217
	local Entry = require("Script.Dev.Entry") -- 2218
	local engineDev = Entry.getEngineDev() -- 2219
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2220
	local zh = (App.locale:match("^zh") ~= nil) -- 2221
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2222
	readme.title = zh and "说明文档" or "Readme" -- 2223
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2224
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2225
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2226
	tools.title = zh and "开发工具" or "Tools" -- 2227
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2228
	font.title = zh and "字体" or "Font" -- 2229
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2230
	lib.title = zh and "程序库" or "Lib" -- 2231
	if engineDev then -- 2232
		local _list_0 = lib.children -- 2233
		for _index_0 = 1, #_list_0 do -- 2233
			local child = _list_0[_index_0] -- 2233
			if not (child.title == "Dora") then -- 2234
				goto _continue_0 -- 2234
			end -- 2234
			local title = zh and "zh-Hans" or "en" -- 2235
			do -- 2236
				local _accum_0 = { } -- 2236
				local _len_0 = 1 -- 2236
				local _list_1 = child.children -- 2236
				for _index_1 = 1, #_list_1 do -- 2236
					local c = _list_1[_index_1] -- 2236
					if c.title ~= title then -- 2236
						_accum_0[_len_0] = c -- 2236
						_len_0 = _len_0 + 1 -- 2236
					end -- 2236
				end -- 2236
				child.children = _accum_0 -- 2236
			end -- 2236
			break -- 2237
			::_continue_0:: -- 2234
		end -- 2233
	else -- 2239
		local _accum_0 = { } -- 2239
		local _len_0 = 1 -- 2239
		local _list_0 = lib.children -- 2239
		for _index_0 = 1, #_list_0 do -- 2239
			local child = _list_0[_index_0] -- 2239
			if child.title ~= "Dora" then -- 2239
				_accum_0[_len_0] = child -- 2239
				_len_0 = _len_0 + 1 -- 2239
			end -- 2239
		end -- 2239
		lib.children = _accum_0 -- 2239
	end -- 2232
	local builtinChildren = { -- 2240
		readme, -- 2240
		apiDoc, -- 2240
		tools, -- 2240
		font, -- 2240
		lib -- 2240
	} -- 2240
	if engineDev then -- 2241
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2242
		do -- 2243
			local _obj_0 = dev.children -- 2243
			_obj_0[#_obj_0 + 1] = { -- 2244
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2244
				dir = false, -- 2245
				builtin = true, -- 2246
				title = "init.yue" -- 2247
			} -- 2243
		end -- 2243
		builtinChildren[#builtinChildren + 1] = dev -- 2249
	end -- 2241
	return { -- 2251
		key = Content.writablePath, -- 2251
		dir = true, -- 2252
		root = true, -- 2253
		title = "Assets", -- 2254
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2255
	} -- 2250
end) -- 2217
HttpServer:post("/entry/list", function(req) -- 2267
	local Entry = require("Script.Dev.Entry") -- 2268
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2269
	res.success = true -- 2270
	return res -- 2271
end) -- 2267
HttpServer:post("/run/status", function() -- 2273
	local Entry = require("Script.Dev.Entry") -- 2274
	return Entry.getCurrentEntryStatus() -- 2275
end) -- 2273
HttpServer:postSchedule("/run", function(req) -- 2277
	do -- 2278
		local _type_0 = type(req) -- 2278
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2278
		if _tab_0 then -- 2278
			local file -- 2278
			do -- 2278
				local _obj_0 = req.body -- 2278
				local _type_1 = type(_obj_0) -- 2278
				if "table" == _type_1 or "userdata" == _type_1 then -- 2278
					file = _obj_0.file -- 2278
				end -- 2278
			end -- 2278
			local asProj -- 2278
			do -- 2278
				local _obj_0 = req.body -- 2278
				local _type_1 = type(_obj_0) -- 2278
				if "table" == _type_1 or "userdata" == _type_1 then -- 2278
					asProj = _obj_0.asProj -- 2278
				end -- 2278
			end -- 2278
			if file ~= nil and asProj ~= nil then -- 2278
				if not Content:isAbsolutePath(file) then -- 2279
					local devFile = Path(Content.writablePath, file) -- 2280
					if Content:exist(devFile) then -- 2281
						file = devFile -- 2281
					end -- 2281
				end -- 2279
				local Entry = require("Script.Dev.Entry") -- 2282
				local workDir -- 2283
				if asProj then -- 2284
					local projectRoot = req.body.projectRoot -- 2285
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2286
						workDir = projectRoot -- 2287
					else -- 2289
						workDir = getProjectDirFromFile(file) -- 2289
					end -- 2286
					if workDir then -- 2290
						Entry.allClear() -- 2291
						local target = Path(workDir, "init") -- 2292
						local success, err = Entry.enterEntryAsync({ -- 2293
							entryName = "Project", -- 2293
							fileName = target, -- 2293
							workDir = workDir, -- 2293
							projectRoot = workDir, -- 2293
							runKind = "project" -- 2293
						}) -- 2293
						target = Path:getName(Path:getPath(target)) -- 2294
						return { -- 2295
							success = success, -- 2295
							target = target, -- 2295
							err = err -- 2295
						} -- 2295
					end -- 2290
				else -- 2297
					workDir = getProjectDirFromFile(file) -- 2297
					if not workDir and Path:getExt(file) == "wasm" then -- 2298
						local parent = Path:getPath(file) -- 2299
						if Content:exist(Path(parent, "wa.mod")) then -- 2300
							workDir = parent -- 2301
						end -- 2300
					end -- 2298
				end -- 2284
				Entry.allClear() -- 2302
				file = Path:replaceExt(file, "") -- 2303
				local entry = { -- 2305
					entryName = Path:getName(file), -- 2305
					fileName = file, -- 2306
					runKind = "file" -- 2307
				} -- 2304
				if workDir then -- 2308
					entry.workDir = workDir -- 2309
					entry.projectRoot = workDir -- 2310
				end -- 2308
				local success, err = Entry.enterEntryAsync(entry) -- 2311
				return { -- 2312
					success = success, -- 2312
					err = err -- 2312
				} -- 2312
			end -- 2278
		end -- 2278
	end -- 2278
	return { -- 2277
		success = false -- 2277
	} -- 2277
end) -- 2277
local _anon_func_7 = function(result) -- 2354
	if result.success then -- 2354
		return nil -- 2354
	else -- 2354
		return "PREVIEW_FAILED" -- 2354
	end -- 2354
end -- 2354
HttpServer:postSchedule("/agent/preview", function(req) -- 2314
	local releaseAgent = AgentHost.acquire() -- 2315
	local _ <close> = setmetatable({ }, { -- 2316
		__close = function() -- 2316
			return releaseAgent() -- 2316
		end -- 2316
	}) -- 2316
	do -- 2317
		local _type_0 = type(req) -- 2317
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2317
		if _tab_0 then -- 2317
			local projectRoot -- 2317
			do -- 2317
				local _obj_0 = req.body -- 2317
				local _type_1 = type(_obj_0) -- 2317
				if "table" == _type_1 or "userdata" == _type_1 then -- 2317
					projectRoot = _obj_0.projectRoot -- 2317
				end -- 2317
			end -- 2317
			if projectRoot ~= nil then -- 2317
				if not getProjectSourceRoot(projectRoot) then -- 2318
					return { -- 2318
						success = false, -- 2318
						code = "INVALID_PROJECT", -- 2318
						message = "projectRoot must be an existing absolute directory" -- 2318
					} -- 2318
				end -- 2318
				local entryFile = req.body.entry or "init.lua" -- 2319
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2320
					return { -- 2320
						success = false, -- 2320
						code = "INVALID_ENTRY", -- 2320
						message = "entry must be a non-empty project-relative path" -- 2320
					} -- 2320
				end -- 2320
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2321
					0.5 -- 2321
				} -- 2321
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2322
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2323
					return { -- 2323
						success = false, -- 2323
						code = "INVALID_QUEUE_TIMEOUT", -- 2323
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2323
					} -- 2323
				end -- 2323
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2324
				local AgentOperation = require("Agent.Tool.Operation") -- 2325
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2326
				local requestId = AgentOperation.createOperationId() -- 2327
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2328
				if not enqueued.success then -- 2329
					return { -- 2329
						success = false, -- 2329
						code = "ENTRY_QUEUE_REJECTED", -- 2329
						message = enqueued.message -- 2329
					} -- 2329
				end -- 2329
				local queuedAt = App.runningTime -- 2330
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2331
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2332
						local state = agentEntryRunQueue:get(requestId) -- 2333
						agentEntryRunQueue:cancel(requestId) -- 2334
						return { -- 2336
							success = false, -- 2336
							code = "ENTRY_QUEUE_TIMEOUT", -- 2337
							message = "timed out waiting for the Dora entry runtime", -- 2338
							requestId = requestId, -- 2339
							queuePosition = state.position -- 2340
						} -- 2335
					end -- 2332
					sleep() -- 2341
				end -- 2331
				local queueWaitSeconds = App.runningTime - queuedAt -- 2342
				local _ <close> = setmetatable({ }, { -- 2343
					__close = function() -- 2343
						return agentEntryRunQueue:release(requestId) -- 2343
					end -- 2343
				}) -- 2343
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2344
				local Entry = require("Script.Dev.Entry") -- 2345
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2347
					workDir = projectRoot, -- 2347
					operationId = requestId, -- 2348
					print = function() end -- 2349
				}, Entry) -- 2346
				local result = preview({ -- 2351
					entry = entryFile, -- 2351
					captureAtSeconds = captureAtSeconds -- 2351
				}) -- 2351
				return { -- 2353
					success = result.success, -- 2353
					code = _anon_func_7(result), -- 2354
					message = result.message, -- 2355
					requestId = requestId, -- 2356
					queueWaitSeconds = queueWaitSeconds, -- 2357
					interruptedUserRun = result.interruptedUserRun, -- 2358
					files = result.files, -- 2359
					frames = result.frames -- 2360
				} -- 2352
			end -- 2317
		end -- 2317
	end -- 2317
	return { -- 2314
		success = false, -- 2314
		message = "invalid call" -- 2314
	} -- 2314
end) -- 2314
HttpServer:postSchedule("/agent/command", function(req) -- 2362
	local releaseAgent = AgentHost.acquire() -- 2363
	local _ <close> = setmetatable({ }, { -- 2364
		__close = function() -- 2364
			return releaseAgent() -- 2364
		end -- 2364
	}) -- 2364
	do -- 2365
		local _type_0 = type(req) -- 2365
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2365
		if _tab_0 then -- 2365
			local body = req.body -- 2365
			if body ~= nil then -- 2365
				local projectRoot = body.projectRoot -- 2366
				if not getProjectSourceRoot(projectRoot) then -- 2367
					return { -- 2367
						success = false, -- 2367
						code = "INVALID_PROJECT", -- 2367
						message = "projectRoot must be an existing absolute directory" -- 2367
					} -- 2367
				end -- 2367
				local AgentValidation = require("Agent.Tool.Validation") -- 2368
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2369
				if not validated.success then -- 2370
					return { -- 2370
						success = false, -- 2370
						code = "INVALID_COMMAND", -- 2370
						message = validated.message -- 2370
					} -- 2370
				end -- 2370
				local input = validated.value -- 2371
				local AgentCommand = require("Agent.Tool.Command") -- 2372
				local result = nil -- 2373
				local failure = nil -- 2374
				local promise = AgentCommand.executeCommand({ -- 2376
					workDir = projectRoot, -- 2376
					mode = input.mode, -- 2377
					code = input.code, -- 2378
					command = input.command, -- 2379
					cwd = input.cwd, -- 2380
					timeoutSeconds = input.timeoutSeconds -- 2381
				}) -- 2375
				promise:addCallbacks((function(_, value) -- 2382
					result = value -- 2382
				end), (function(_, err) -- 2382
					failure = tostring(err) -- 2382
				end)) -- 2382
				wait(function() -- 2383
					return result ~= nil or failure ~= nil -- 2383
				end) -- 2383
				if failure then -- 2384
					return { -- 2384
						success = false, -- 2384
						code = "COMMAND_BRIDGE_FAILED", -- 2384
						message = failure -- 2384
					} -- 2384
				end -- 2384
				if not result.success then -- 2385
					result.code = "COMMAND_FAILED" -- 2386
				end -- 2385
				return result -- 2387
			end -- 2365
		end -- 2365
	end -- 2365
	return { -- 2362
		success = false, -- 2362
		code = "INVALID_COMMAND", -- 2362
		message = "invalid call" -- 2362
	} -- 2362
end) -- 2362
HttpServer:postSchedule("/stop", function() -- 2389
	local Entry = require("Script.Dev.Entry") -- 2390
	return { -- 2391
		success = Entry.stop() -- 2391
	} -- 2391
end) -- 2389
local minifyAsync -- 2393
minifyAsync = function(sourcePath, minifyPath) -- 2393
	if not Content:exist(sourcePath) then -- 2394
		return -- 2394
	end -- 2394
	local Entry = require("Script.Dev.Entry") -- 2395
	local errors = { } -- 2396
	local files = Entry.getAllFiles(sourcePath, { -- 2397
		"lua" -- 2397
	}, true) -- 2397
	do -- 2398
		local _accum_0 = { } -- 2398
		local _len_0 = 1 -- 2398
		for _index_0 = 1, #files do -- 2398
			local file = files[_index_0] -- 2398
			if file:sub(1, 1) ~= '.' then -- 2398
				_accum_0[_len_0] = file -- 2398
				_len_0 = _len_0 + 1 -- 2398
			end -- 2398
		end -- 2398
		files = _accum_0 -- 2398
	end -- 2398
	local paths -- 2399
	do -- 2399
		local _tbl_0 = { } -- 2399
		for _index_0 = 1, #files do -- 2399
			local file = files[_index_0] -- 2399
			_tbl_0[Path:getPath(file)] = true -- 2399
		end -- 2399
		paths = _tbl_0 -- 2399
	end -- 2399
	for path in pairs(paths) do -- 2400
		Content:mkdir(Path(minifyPath, path)) -- 2400
	end -- 2400
	local _ <close> = setmetatable({ }, { -- 2401
		__close = function() -- 2401
			package.loaded["luaminify.FormatMini"] = nil -- 2402
			package.loaded["luaminify.ParseLua"] = nil -- 2403
			package.loaded["luaminify.Scope"] = nil -- 2404
			package.loaded["luaminify.Util"] = nil -- 2405
		end -- 2401
	}) -- 2401
	local FormatMini -- 2406
	do -- 2406
		local _obj_0 = require("luaminify") -- 2406
		FormatMini = _obj_0.FormatMini -- 2406
	end -- 2406
	local fileCount = #files -- 2407
	local count = 0 -- 2408
	for _index_0 = 1, #files do -- 2409
		local file = files[_index_0] -- 2409
		thread(function() -- 2410
			local _ <close> = setmetatable({ }, { -- 2411
				__close = function() -- 2411
					count = count + 1 -- 2411
				end -- 2411
			}) -- 2411
			local input = Path(sourcePath, file) -- 2412
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2413
			if Content:exist(input) then -- 2414
				local sourceCodes = Content:loadAsync(input) -- 2415
				local res, err = FormatMini(sourceCodes) -- 2416
				if res then -- 2417
					Content:saveAsync(output, res) -- 2418
					return print("Minify " .. tostring(file)) -- 2419
				else -- 2421
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2421
				end -- 2417
			else -- 2423
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2423
			end -- 2414
		end) -- 2410
		sleep() -- 2424
	end -- 2409
	wait(function() -- 2425
		return count == fileCount -- 2425
	end) -- 2425
	if #errors > 0 then -- 2426
		print(table.concat(errors, '\n')) -- 2427
	end -- 2426
	print("Obfuscation done.") -- 2428
	return files -- 2429
end -- 2393
local zipping = false -- 2431
HttpServer:postSchedule("/zip", function(req) -- 2433
	do -- 2434
		local _type_0 = type(req) -- 2434
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2434
		if _tab_0 then -- 2434
			local path -- 2434
			do -- 2434
				local _obj_0 = req.body -- 2434
				local _type_1 = type(_obj_0) -- 2434
				if "table" == _type_1 or "userdata" == _type_1 then -- 2434
					path = _obj_0.path -- 2434
				end -- 2434
			end -- 2434
			local zipFile -- 2434
			do -- 2434
				local _obj_0 = req.body -- 2434
				local _type_1 = type(_obj_0) -- 2434
				if "table" == _type_1 or "userdata" == _type_1 then -- 2434
					zipFile = _obj_0.zipFile -- 2434
				end -- 2434
			end -- 2434
			local obfuscated -- 2434
			do -- 2434
				local _obj_0 = req.body -- 2434
				local _type_1 = type(_obj_0) -- 2434
				if "table" == _type_1 or "userdata" == _type_1 then -- 2434
					obfuscated = _obj_0.obfuscated -- 2434
				end -- 2434
			end -- 2434
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2434
				if zipping then -- 2435
					goto failed -- 2435
				end -- 2435
				zipping = true -- 2436
				local _ <close> = setmetatable({ }, { -- 2437
					__close = function() -- 2437
						zipping = false -- 2437
					end -- 2437
				}) -- 2437
				if not Content:exist(path) then -- 2438
					goto failed -- 2438
				end -- 2438
				Content:mkdir(Path:getPath(zipFile)) -- 2439
				if obfuscated then -- 2440
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2441
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2442
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2443
					Content:remove(scriptPath) -- 2444
					Content:remove(obfuscatedPath) -- 2445
					Content:remove(tempPath) -- 2446
					Content:mkdir(scriptPath) -- 2447
					Content:mkdir(obfuscatedPath) -- 2448
					Content:mkdir(tempPath) -- 2449
					if not Content:copyAsync(path, tempPath) then -- 2450
						goto failed -- 2450
					end -- 2450
					local Entry = require("Script.Dev.Entry") -- 2451
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2452
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2453
						"tl", -- 2453
						"yue", -- 2453
						"lua", -- 2453
						"ts", -- 2453
						"tsx", -- 2453
						"vs", -- 2453
						"bl", -- 2453
						"xml", -- 2453
						"wa", -- 2453
						"mod" -- 2453
					}, true) -- 2453
					for _index_0 = 1, #scriptFiles do -- 2454
						local file = scriptFiles[_index_0] -- 2454
						Content:remove(Path(tempPath, file)) -- 2455
					end -- 2454
					for _index_0 = 1, #luaFiles do -- 2456
						local file = luaFiles[_index_0] -- 2456
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2457
					end -- 2456
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2458
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2459
					end) then -- 2458
						goto failed -- 2458
					end -- 2458
					return { -- 2460
						success = true -- 2460
					} -- 2460
				else -- 2462
					return { -- 2462
						success = Content:zipAsync(path, zipFile, function(file) -- 2462
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2463
						end) -- 2462
					} -- 2462
				end -- 2440
			end -- 2434
		end -- 2434
	end -- 2434
	::failed:: -- 2464
	return { -- 2433
		success = false -- 2433
	} -- 2433
end) -- 2433
HttpServer:postSchedule("/unzip", function(req) -- 2466
	do -- 2467
		local _type_0 = type(req) -- 2467
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2467
		if _tab_0 then -- 2467
			local zipFile -- 2467
			do -- 2467
				local _obj_0 = req.body -- 2467
				local _type_1 = type(_obj_0) -- 2467
				if "table" == _type_1 or "userdata" == _type_1 then -- 2467
					zipFile = _obj_0.zipFile -- 2467
				end -- 2467
			end -- 2467
			local path -- 2467
			do -- 2467
				local _obj_0 = req.body -- 2467
				local _type_1 = type(_obj_0) -- 2467
				if "table" == _type_1 or "userdata" == _type_1 then -- 2467
					path = _obj_0.path -- 2467
				end -- 2467
			end -- 2467
			if zipFile ~= nil and path ~= nil then -- 2467
				return { -- 2468
					success = Content:unzipAsync(zipFile, path, function(file) -- 2468
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2469
					end) -- 2468
				} -- 2468
			end -- 2467
		end -- 2467
	end -- 2467
	return { -- 2466
		success = false -- 2466
	} -- 2466
end) -- 2466
HttpServer:post("/editing-info", function(req) -- 2471
	local Entry = require("Script.Dev.Entry") -- 2472
	local config = Entry.getConfig() -- 2473
	local _type_0 = type(req) -- 2474
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2474
	local _match_0 = false -- 2474
	if _tab_0 then -- 2474
		local editingInfo -- 2474
		do -- 2474
			local _obj_0 = req.body -- 2474
			local _type_1 = type(_obj_0) -- 2474
			if "table" == _type_1 or "userdata" == _type_1 then -- 2474
				editingInfo = _obj_0.editingInfo -- 2474
			end -- 2474
		end -- 2474
		if editingInfo ~= nil then -- 2474
			_match_0 = true -- 2474
			config.editingInfo = editingInfo -- 2475
			return { -- 2476
				success = true -- 2476
			} -- 2476
		end -- 2474
	end -- 2474
	if not _match_0 then -- 2474
		if not (config.editingInfo ~= nil) then -- 2478
			local folder -- 2479
			if App.locale:match('^zh') then -- 2479
				folder = 'zh-Hans' -- 2479
			else -- 2479
				folder = 'en' -- 2479
			end -- 2479
			config.editingInfo = json.encode({ -- 2481
				index = 0, -- 2481
				files = { -- 2483
					{ -- 2484
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2484
						title = "welcome.md" -- 2485
					} -- 2483
				} -- 2482
			}) -- 2480
		end -- 2478
		return { -- 2489
			success = true, -- 2489
			editingInfo = config.editingInfo -- 2489
		} -- 2489
	end -- 2474
end) -- 2471
HttpServer:post("/command", function(req) -- 2491
	do -- 2492
		local _type_0 = type(req) -- 2492
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2492
		if _tab_0 then -- 2492
			local code -- 2492
			do -- 2492
				local _obj_0 = req.body -- 2492
				local _type_1 = type(_obj_0) -- 2492
				if "table" == _type_1 or "userdata" == _type_1 then -- 2492
					code = _obj_0.code -- 2492
				end -- 2492
			end -- 2492
			local log -- 2492
			do -- 2492
				local _obj_0 = req.body -- 2492
				local _type_1 = type(_obj_0) -- 2492
				if "table" == _type_1 or "userdata" == _type_1 then -- 2492
					log = _obj_0.log -- 2492
				end -- 2492
			end -- 2492
			if code ~= nil and log ~= nil then -- 2492
				emit("AppCommand", code, log) -- 2493
				return { -- 2494
					success = true -- 2494
				} -- 2494
			end -- 2492
		end -- 2492
	end -- 2492
	return { -- 2491
		success = false -- 2491
	} -- 2491
end) -- 2491
HttpServer:post("/log/save", function() -- 2496
	local folder = ".download" -- 2497
	local fullLogFile = "dora_full_logs.txt" -- 2498
	local fullFolder = Path(Content.writablePath, folder) -- 2499
	Content:mkdir(fullFolder) -- 2500
	local logPath = Path(fullFolder, fullLogFile) -- 2501
	if App:saveLog(logPath) then -- 2502
		return { -- 2503
			success = true, -- 2503
			path = Path(folder, fullLogFile) -- 2503
		} -- 2503
	end -- 2502
	return { -- 2496
		success = false -- 2496
	} -- 2496
end) -- 2496
local tailLines -- 2505
tailLines = function(text, count) -- 2505
	local lines = { } -- 2506
	text = text:gsub("\r\n", "\n") -- 2507
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2508
		lines[#lines + 1] = line -- 2509
	end -- 2508
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2510
		table.remove(lines) -- 2511
	end -- 2510
	local start = math.max(1, #lines - count + 1) -- 2512
	local out = { } -- 2513
	for i = start, #lines do -- 2514
		out[#out + 1] = lines[i] -- 2515
	end -- 2514
	return table.concat(out, "\n") -- 2516
end -- 2505
HttpServer:post("/log", function(req) -- 2518
	local count = 100 -- 2519
	if req and req.body and req.body.count ~= nil then -- 2520
		count = req.body.count -- 2521
	end -- 2520
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2522
		return { -- 2523
			success = false, -- 2523
			message = "count must be a positive integer" -- 2523
		} -- 2523
	end -- 2522
	local folder = ".download" -- 2524
	local fullLogFile = "dora_full_logs.txt" -- 2525
	local fullFolder = Path(Content.writablePath, folder) -- 2526
	Content:mkdir(fullFolder) -- 2527
	local logPath = Path(fullFolder, fullLogFile) -- 2528
	if App:saveLog(logPath) then -- 2529
		local text = Content:load(logPath) -- 2530
		if text then -- 2531
			return { -- 2532
				success = true, -- 2532
				log = tailLines(text, count) -- 2532
			} -- 2532
		else -- 2534
			return { -- 2534
				success = false, -- 2534
				message = "failed to read log" -- 2534
			} -- 2534
		end -- 2531
	else -- 2536
		return { -- 2536
			success = false, -- 2536
			message = "failed to save log" -- 2536
		} -- 2536
	end -- 2529
	return { -- 2518
		success = false -- 2518
	} -- 2518
end) -- 2518
HttpServer:post("/yarn/check", function(req) -- 2538
	local yarncompile = require("yarncompile") -- 2539
	do -- 2540
		local _type_0 = type(req) -- 2540
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2540
		if _tab_0 then -- 2540
			local code -- 2540
			do -- 2540
				local _obj_0 = req.body -- 2540
				local _type_1 = type(_obj_0) -- 2540
				if "table" == _type_1 or "userdata" == _type_1 then -- 2540
					code = _obj_0.code -- 2540
				end -- 2540
			end -- 2540
			if code ~= nil then -- 2540
				local jsonObject = json.decode(code) -- 2541
				if jsonObject then -- 2541
					local errors = { } -- 2542
					local _list_0 = jsonObject.nodes -- 2543
					for _index_0 = 1, #_list_0 do -- 2543
						local node = _list_0[_index_0] -- 2543
						local title, body = node.title, node.body -- 2544
						local luaCode, err = yarncompile(body) -- 2545
						if not luaCode then -- 2545
							errors[#errors + 1] = title .. ":" .. err -- 2546
						end -- 2545
					end -- 2543
					return { -- 2547
						success = true, -- 2547
						syntaxError = table.concat(errors, "\n\n") -- 2547
					} -- 2547
				end -- 2541
			end -- 2540
		end -- 2540
	end -- 2540
	return { -- 2538
		success = false -- 2538
	} -- 2538
end) -- 2538
HttpServer:post("/yarn/check-file", function(req) -- 2549
	local yarncompile = require("yarncompile") -- 2550
	do -- 2551
		local _type_0 = type(req) -- 2551
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2551
		if _tab_0 then -- 2551
			local code -- 2551
			do -- 2551
				local _obj_0 = req.body -- 2551
				local _type_1 = type(_obj_0) -- 2551
				if "table" == _type_1 or "userdata" == _type_1 then -- 2551
					code = _obj_0.code -- 2551
				end -- 2551
			end -- 2551
			if code ~= nil then -- 2551
				local res, _, err = yarncompile(code, true) -- 2552
				if not res then -- 2552
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2553
					return { -- 2554
						success = false, -- 2554
						message = message, -- 2554
						line = line, -- 2554
						column = column, -- 2554
						node = node -- 2554
					} -- 2554
				end -- 2552
			end -- 2551
		end -- 2551
	end -- 2551
	return { -- 2549
		success = true -- 2549
	} -- 2549
end) -- 2549
getWaProjectDirFromFile = function(file) -- 2556
	local current -- 2557
	if Content:isdir(file) then -- 2557
		current = file -- 2557
	else -- 2557
		current = Path:getPath(file) -- 2557
	end -- 2557
	if current == "" then -- 2558
		return nil -- 2558
	end -- 2558
	repeat -- 2559
		local modPath = Path(current, "wa.mod") -- 2560
		if Content:exist(modPath) then -- 2561
			return current, modPath -- 2562
		end -- 2561
		local parent = Path:getPath(current) -- 2563
		if parent == "" or parent == current then -- 2564
			break -- 2564
		end -- 2564
		current = parent -- 2565
	until false -- 2559
	return nil -- 2567
end -- 2556
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2569
	do -- 2570
		local _type_0 = type(req) -- 2570
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2570
		if _tab_0 then -- 2570
			local path -- 2570
			do -- 2570
				local _obj_0 = req.body -- 2570
				local _type_1 = type(_obj_0) -- 2570
				if "table" == _type_1 or "userdata" == _type_1 then -- 2570
					path = _obj_0.path -- 2570
				end -- 2570
			end -- 2570
			if path ~= nil then -- 2570
				local projDir = getWaProjectDirFromFile(path) -- 2571
				if projDir then -- 2571
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2572
					if not Content:exist(sourceDoraPath) then -- 2573
						return { -- 2574
							success = false, -- 2574
							message = "missing dora template" -- 2574
						} -- 2574
					end -- 2573
					local targetVendorPath = Path(projDir, "vendor") -- 2575
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2576
					if not Content:exist(targetVendorPath) then -- 2577
						if not Content:mkdir(targetVendorPath) then -- 2578
							return { -- 2579
								success = false, -- 2579
								message = "failed to create vendor folder" -- 2579
							} -- 2579
						end -- 2578
					elseif not Content:isdir(targetVendorPath) then -- 2580
						return { -- 2581
							success = false, -- 2581
							message = "vendor path is not a folder" -- 2581
						} -- 2581
					end -- 2577
					if Content:exist(targetDoraPath) then -- 2582
						if not Content:remove(targetDoraPath) then -- 2583
							return { -- 2584
								success = false, -- 2584
								message = "failed to remove old dora" -- 2584
							} -- 2584
						end -- 2583
					end -- 2582
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2585
						return { -- 2586
							success = false, -- 2586
							message = "failed to copy dora" -- 2586
						} -- 2586
					end -- 2585
					return { -- 2587
						success = true -- 2587
					} -- 2587
				else -- 2589
					return { -- 2589
						success = false, -- 2589
						message = 'Wa file needs a project' -- 2589
					} -- 2589
				end -- 2571
			end -- 2570
		end -- 2570
	end -- 2570
	return { -- 2569
		success = false, -- 2569
		message = "invalid call" -- 2569
	} -- 2569
end) -- 2569
HttpServer:postSchedule("/wa/build", function(req) -- 2591
	do -- 2592
		local _type_0 = type(req) -- 2592
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2592
		if _tab_0 then -- 2592
			local path -- 2592
			do -- 2592
				local _obj_0 = req.body -- 2592
				local _type_1 = type(_obj_0) -- 2592
				if "table" == _type_1 or "userdata" == _type_1 then -- 2592
					path = _obj_0.path -- 2592
				end -- 2592
			end -- 2592
			if path ~= nil then -- 2592
				local projDir = getWaProjectDirFromFile(path) -- 2593
				if projDir then -- 2593
					local message = Wasm:buildWaAsync(projDir) -- 2594
					if message == "" then -- 2595
						return { -- 2596
							success = true -- 2596
						} -- 2596
					else -- 2598
						return { -- 2598
							success = false, -- 2598
							message = message -- 2598
						} -- 2598
					end -- 2595
				else -- 2600
					return { -- 2600
						success = false, -- 2600
						message = 'Wa file needs a project' -- 2600
					} -- 2600
				end -- 2593
			end -- 2592
		end -- 2592
	end -- 2592
	return { -- 2601
		success = false, -- 2601
		message = 'failed to build' -- 2601
	} -- 2601
end) -- 2591
HttpServer:postSchedule("/wa/format", function(req) -- 2603
	do -- 2604
		local _type_0 = type(req) -- 2604
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2604
		if _tab_0 then -- 2604
			local file -- 2604
			do -- 2604
				local _obj_0 = req.body -- 2604
				local _type_1 = type(_obj_0) -- 2604
				if "table" == _type_1 or "userdata" == _type_1 then -- 2604
					file = _obj_0.file -- 2604
				end -- 2604
			end -- 2604
			if file ~= nil then -- 2604
				local code = Wasm:formatWaAsync(file) -- 2605
				if code == "" then -- 2606
					return { -- 2607
						success = false -- 2607
					} -- 2607
				else -- 2609
					return { -- 2609
						success = true, -- 2609
						code = code -- 2609
					} -- 2609
				end -- 2606
			end -- 2604
		end -- 2604
	end -- 2604
	return { -- 2610
		success = false -- 2610
	} -- 2610
end) -- 2603
HttpServer:postSchedule("/wa/create", function(req) -- 2612
	do -- 2613
		local _type_0 = type(req) -- 2613
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2613
		if _tab_0 then -- 2613
			local path -- 2613
			do -- 2613
				local _obj_0 = req.body -- 2613
				local _type_1 = type(_obj_0) -- 2613
				if "table" == _type_1 or "userdata" == _type_1 then -- 2613
					path = _obj_0.path -- 2613
				end -- 2613
			end -- 2613
			if path ~= nil then -- 2613
				if not Content:exist(Path:getPath(path)) then -- 2614
					return { -- 2615
						success = false, -- 2615
						message = "target path not existed" -- 2615
					} -- 2615
				end -- 2614
				if Content:exist(path) then -- 2616
					return { -- 2617
						success = false, -- 2617
						message = "target project folder existed" -- 2617
					} -- 2617
				end -- 2616
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2618
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2619
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2620
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2621
					return { -- 2624
						success = false, -- 2624
						message = "missing template project" -- 2624
					} -- 2624
				end -- 2621
				if not Content:mkdir(path) then -- 2625
					return { -- 2626
						success = false, -- 2626
						message = "failed to create project folder" -- 2626
					} -- 2626
				end -- 2625
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2627
					Content:remove(path) -- 2628
					return { -- 2629
						success = false, -- 2629
						message = "failed to copy template" -- 2629
					} -- 2629
				end -- 2627
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2630
					Content:remove(path) -- 2631
					return { -- 2632
						success = false, -- 2632
						message = "failed to copy template" -- 2632
					} -- 2632
				end -- 2630
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2633
					Content:remove(path) -- 2634
					return { -- 2635
						success = false, -- 2635
						message = "failed to copy template" -- 2635
					} -- 2635
				end -- 2633
				return { -- 2636
					success = true -- 2636
				} -- 2636
			end -- 2613
		end -- 2613
	end -- 2613
	return { -- 2612
		success = false, -- 2612
		message = "invalid call" -- 2612
	} -- 2612
end) -- 2612
local tsBuildGlobs = { -- 2639
	"**/*.ts", -- 2639
	"**/*.tsx", -- 2640
	"!**/.*/**", -- 2641
	"!**/node_modules/**" -- 2642
} -- 2638
local tsSnapshotGlobs = { -- 2645
	"**/*.ts", -- 2645
	"**/*.tsx", -- 2646
	"**/*.lua", -- 2647
	"!**/.*/**", -- 2648
	"!**/node_modules/**" -- 2649
} -- 2644
local collectTSVirtualFiles -- 2651
collectTSVirtualFiles = function(sourceRoot) -- 2651
	local files = { } -- 2652
	local seen = { } -- 2653
	local addFile -- 2654
	addFile = function(file, moduleName, virtualFile) -- 2654
		if moduleName == nil then -- 2654
			moduleName = nil -- 2654
		end -- 2654
		if virtualFile == nil then -- 2654
			virtualFile = nil -- 2654
		end -- 2654
		local targetFile = virtualFile or file -- 2655
		do -- 2656
			local entry = seen[targetFile] -- 2656
			if entry then -- 2656
				if moduleName and moduleName ~= "" then -- 2657
					entry.moduleName = moduleName -- 2657
				end -- 2657
				return -- 2658
			end -- 2656
		end -- 2656
		local content = Content:load(file) -- 2659
		if content then -- 2659
			local entry = { -- 2660
				file = targetFile, -- 2660
				content = content -- 2660
			} -- 2660
			if moduleName and moduleName ~= "" then -- 2661
				entry.moduleName = moduleName -- 2661
			end -- 2661
			seen[targetFile] = entry -- 2662
			files[#files + 1] = entry -- 2663
		end -- 2659
	end -- 2654
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2664
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2665
		for _index_0 = 1, #_list_0 do -- 2665
			local subFile = _list_0[_index_0] -- 2665
			addFile(Path(sourceRoot, subFile)) -- 2666
		end -- 2665
		local libraryRoots = { -- 2668
			Path(sourceRoot, "Script", "Lib"), -- 2668
			Path(sourceRoot, "Lib"), -- 2669
			Path(Content.assetPath, "Script", "Lib") -- 2670
		} -- 2667
		for _index_0 = 1, #libraryRoots do -- 2671
			local libraryRoot = libraryRoots[_index_0] -- 2671
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2672
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2673
				for _index_1 = 1, #_list_1 do -- 2673
					local subFile = _list_1[_index_1] -- 2673
					local file = Path(libraryRoot, subFile) -- 2674
					local virtualFile = Path(sourceRoot, subFile) -- 2675
					addFile(file, nil, virtualFile) -- 2676
				end -- 2673
			end -- 2672
		end -- 2671
	end -- 2664
	local locale -- 2677
	if App.locale:match('^zh') then -- 2677
		locale = 'zh-Hans' -- 2677
	else -- 2677
		locale = 'en' -- 2677
	end -- 2677
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2678
	local _list_0 = Content:getFiles(declarationRoot) -- 2679
	for _index_0 = 1, #_list_0 do -- 2679
		local file = _list_0[_index_0] -- 2679
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2680
			local fullPath = Path(declarationRoot, file) -- 2681
			local moduleName = Path:getName(Path:getName(file)) -- 2682
			addFile(fullPath, moduleName) -- 2683
		end -- 2680
	end -- 2679
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2684
	local lualibBundleTarget -- 2685
	if sourceRoot then -- 2685
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2685
	else -- 2685
		lualibBundleTarget = "lualib_bundle.lua" -- 2685
	end -- 2685
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2686
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2687
	local _list_1 = Content:getFiles(lualibRoot) -- 2688
	for _index_0 = 1, #_list_1 do -- 2688
		local file = _list_1[_index_0] -- 2688
		if Path:getExt(file) == "lua" then -- 2689
			local virtualFile -- 2690
			if sourceRoot then -- 2690
				virtualFile = Path(sourceRoot, "lualib", file) -- 2690
			else -- 2690
				virtualFile = Path("lualib", file) -- 2690
			end -- 2690
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2691
		end -- 2689
	end -- 2688
	return files -- 2692
end -- 2651
local supportsCompilerWebView -- 2694
supportsCompilerWebView = function() -- 2694
	local _val_0 = App.platform -- 2694
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2694
end -- 2694
local webIDECompilerReady = false -- 2695
local webIDEConnectionGeneration = 0 -- 2696
local tsProbeId = 0 -- 2697
local probeWebIDECompiler -- 2699
probeWebIDECompiler = function(isCancelled) -- 2699
	if HttpServer.wsConnectionCount == 0 then -- 2700
		return false -- 2700
	end -- 2700
	tsProbeId = tsProbeId + 1 -- 2701
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2702
	local generation = webIDEConnectionGeneration -- 2703
	local done, ready = false, false -- 2704
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2705
	local listener = Node() -- 2706
	listener:gslot("AppWS", function(event) -- 2707
		if event.type == "Receive" then -- 2708
			local res = json.decode(event.msg) -- 2709
			if res then -- 2709
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2710
					responses = responses + 1 -- 2711
					ready = ready or res.success == true -- 2712
					done = ready or responses >= expectedResponses -- 2713
				end -- 2710
			end -- 2709
		end -- 2708
	end) -- 2707
	emit("AppWS", "Send", json.encode({ -- 2714
		name = "TranspileTSProbe", -- 2714
		id = requestId -- 2714
	})) -- 2714
	local deadline = App.runningTime + 5 -- 2715
	wait(function() -- 2716
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2716
	end) -- 2716
	listener:removeFromParent() -- 2717
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2718
	if generation == webIDEConnectionGeneration then -- 2719
		webIDECompilerReady = ready -- 2719
	end -- 2719
	return ready -- 2720
end -- 2699
local compilerConnectionListener = Node() -- 2722
compilerConnectionListener:addTo(Director.systemUI) -- 2724
local _anon_func_8 = function(event) -- 2726
	local _val_0 = event.type -- 2726
	return "Open" == _val_0 or "Close" == _val_0 -- 2726
end -- 2726
compilerConnectionListener:gslot("AppWS", function(event) -- 2725
	if _anon_func_8(event) then -- 2726
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2727
		webIDECompilerReady = false -- 2728
		if HttpServer.wsConnectionCount > 0 then -- 2729
			return thread(function() -- 2730
				return probeWebIDECompiler() -- 2730
			end) -- 2730
		end -- 2729
	end -- 2726
end) -- 2725
local _anon_func_9 = function(res) -- 2755
	if res.success then -- 2755
		return "tool" -- 2755
	else -- 2755
		return res.failureKind -- 2755
	end -- 2755
end -- 2755
local transpileTSFileWithWebIDE -- 2732
do -- 2732
	local tsBuildRequestId = 0 -- 2733
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2734
		if not probeWebIDECompiler(isCancelled) then -- 2735
			if isCancelled and isCancelled() then -- 2736
				return { -- 2737
					success = false, -- 2737
					file = file, -- 2737
					message = "build canceled", -- 2737
					interrupted = true -- 2737
				} -- 2737
			end -- 2736
			return { -- 2738
				success = false, -- 2738
				file = file, -- 2738
				message = "TypeScript transpiler is not ready", -- 2738
				failureKind = "tool" -- 2738
			} -- 2738
		end -- 2735
		tsBuildRequestId = tsBuildRequestId + 1 -- 2739
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2740
		local done = false -- 2741
		local result = nil -- 2742
		local listener = Node() -- 2743
		listener:gslot("AppWS", function(event) -- 2744
			if event.type == "Receive" then -- 2745
				local res = json.decode(event.msg) -- 2746
				if res then -- 2746
					if res.name == "TranspileTS" and res.id == requestId then -- 2747
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2748
							local luaFile = Path:replaceExt(file, "lua") -- 2749
							if Content:save(luaFile, res.luaCode) then -- 2750
								result = { -- 2751
									success = true, -- 2751
									file = file -- 2751
								} -- 2751
							else -- 2753
								result = { -- 2753
									success = false, -- 2753
									file = file, -- 2753
									message = "failed to save " .. tostring(luaFile) -- 2753
								} -- 2753
							end -- 2750
						else -- 2755
							result = { -- 2755
								success = false, -- 2755
								file = file, -- 2755
								message = res.message or "Compiler returned no Lua output", -- 2755
								failureKind = _anon_func_9(res) -- 2755
							} -- 2755
						end -- 2748
						done = true -- 2756
					end -- 2747
				end -- 2746
			end -- 2745
		end) -- 2744
		emit("AppWS", "Send", json.encode({ -- 2757
			name = "TranspileTS", -- 2757
			id = requestId, -- 2757
			file = file, -- 2757
			content = content, -- 2757
			projectRoot = sourceRoot, -- 2757
			files = files -- 2757
		})) -- 2757
		local deadline = App.runningTime + 30 -- 2758
		wait(function() -- 2759
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2759
		end) -- 2759
		listener:removeFromParent() -- 2760
		if not done then -- 2761
			webIDECompilerReady = false -- 2762
			if isCancelled and isCancelled() then -- 2763
				return { -- 2764
					success = false, -- 2764
					file = file, -- 2764
					message = "build canceled", -- 2764
					interrupted = true -- 2764
				} -- 2764
			end -- 2763
			return { -- 2765
				success = false, -- 2765
				file = file, -- 2765
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2765
				failureKind = "tool" -- 2765
			} -- 2765
		end -- 2761
		return result -- 2766
	end -- 2734
end -- 2732
local compilerReadyTimeout <const> = 15 -- 2768
local compilerBuildTimeout <const> = 30 -- 2769
local compilerIdleCloseSeconds <const> = 8 -- 2770
local compilerReady = false -- 2771
local compilerRequested = false -- 2772
local compilerFailure = nil -- 2773
local compilerUsers = 0 -- 2774
local compilerCloseGeneration = 0 -- 2775
local compilerJobId = 0 -- 2776
local compilerJobs = { } -- 2777
local compilerResults = { } -- 2778
local compilerInFlight = { } -- 2779
HttpServer:post("/compiler/ready", function() -- 2781
	if not compilerRequested then -- 2782
		return { -- 2782
			success = false -- 2782
		} -- 2782
	end -- 2782
	compilerReady = true -- 2783
	return { -- 2784
		success = true -- 2784
	} -- 2784
end) -- 2781
HttpServer:post("/compiler/failure", function(req) -- 2786
	if not compilerRequested then -- 2787
		return { -- 2787
			success = false -- 2787
		} -- 2787
	end -- 2787
	do -- 2788
		local _type_0 = type(req) -- 2788
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2788
		if _tab_0 then -- 2788
			local message -- 2788
			do -- 2788
				local _obj_0 = req.body -- 2788
				local _type_1 = type(_obj_0) -- 2788
				if "table" == _type_1 or "userdata" == _type_1 then -- 2788
					message = _obj_0.message -- 2788
				end -- 2788
			end -- 2788
			if message ~= nil then -- 2788
				if type(message) == "string" then -- 2789
					compilerFailure = message -- 2790
					compilerReady = false -- 2791
					return { -- 2792
						success = true -- 2792
					} -- 2792
				end -- 2789
			end -- 2788
		end -- 2788
	end -- 2788
	return { -- 2786
		success = false -- 2786
	} -- 2786
end) -- 2786
HttpServer:postSchedule("/compiler/poll", function() -- 2794
	if not compilerRequested then -- 2795
		return { -- 2795
			success = false -- 2795
		} -- 2795
	end -- 2795
	compilerReady = true -- 2796
	local deadline = App.runningTime + 5 -- 2797
	wait(function() -- 2798
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2798
	end) -- 2798
	if not (compilerRequested and not compilerFailure) then -- 2799
		return { -- 2799
			success = false -- 2799
		} -- 2799
	end -- 2799
	local job = table.remove(compilerJobs, 1) -- 2800
	if job then -- 2801
		compilerInFlight[job.id] = true -- 2802
	end -- 2801
	return { -- 2803
		success = true, -- 2803
		job = job -- 2803
	} -- 2803
end) -- 2794
HttpServer:post("/compiler/result", function(req) -- 2805
	do -- 2806
		local _type_0 = type(req) -- 2806
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2806
		if _tab_0 then -- 2806
			local body = req.body -- 2806
			if body ~= nil then -- 2806
				local id = body.id -- 2807
				if not (id and compilerInFlight[id]) then -- 2808
					return { -- 2808
						success = false, -- 2808
						message = "invalid compiler job" -- 2808
					} -- 2808
				end -- 2808
				compilerInFlight[id] = nil -- 2809
				compilerResults[id] = body -- 2810
				return { -- 2811
					success = true -- 2811
				} -- 2811
			end -- 2806
		end -- 2806
	end -- 2806
	return { -- 2805
		success = false -- 2805
	} -- 2805
end) -- 2805
local acquireCompiler -- 2813
acquireCompiler = function() -- 2813
	compilerUsers = compilerUsers + 1 -- 2814
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2815
	if not compilerRequested then -- 2816
		compilerRequested = true -- 2817
		compilerReady = false -- 2818
		compilerFailure = nil -- 2819
		return emit("AppWebView", "/compiler.html", true) -- 2820
	end -- 2816
end -- 2813
local releaseCompiler -- 2822
releaseCompiler = function() -- 2822
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2823
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2824
	if not (compilerUsers == 0) then -- 2825
		return -- 2825
	end -- 2825
	local closeGeneration = compilerCloseGeneration -- 2826
	return thread(function() -- 2827
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2828
		wait(function() -- 2829
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2830
		end) -- 2829
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2835
			compilerRequested = false -- 2836
			compilerReady = false -- 2837
			return emit("AppWebView", "/compiler.html", false) -- 2838
		end -- 2835
	end) -- 2827
end -- 2822
local removeCompilerJob -- 2840
removeCompilerJob = function(id) -- 2840
	for index = #compilerJobs, 1, -1 do -- 2841
		if compilerJobs[index].id == id then -- 2842
			table.remove(compilerJobs, index) -- 2843
		end -- 2842
	end -- 2841
	compilerInFlight[id] = nil -- 2844
	compilerResults[id] = nil -- 2845
end -- 2840
local transpileTSFileWithCompiler -- 2847
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2847
	acquireCompiler() -- 2848
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2849
	wait(function() -- 2850
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2850
	end) -- 2850
	if not compilerReady then -- 2851
		releaseCompiler() -- 2852
		if isCancelled and isCancelled() then -- 2853
			return { -- 2854
				success = false, -- 2854
				file = file, -- 2854
				message = "build canceled", -- 2854
				interrupted = true -- 2854
			} -- 2854
		end -- 2853
		return { -- 2855
			success = false, -- 2855
			file = file, -- 2855
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2855
			failureKind = "tool" -- 2855
		} -- 2855
	end -- 2851
	compilerJobId = compilerJobId + 1 -- 2856
	local jobId = compilerJobId -- 2857
	compilerJobs[#compilerJobs + 1] = { -- 2859
		id = jobId, -- 2859
		file = file, -- 2860
		content = content, -- 2861
		projectRoot = sourceRoot, -- 2862
		files = files -- 2863
	} -- 2858
	local deadline = App.runningTime + compilerBuildTimeout -- 2864
	wait(function() -- 2865
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2865
	end) -- 2865
	local response = compilerResults[jobId] -- 2866
	removeCompilerJob(jobId) -- 2867
	releaseCompiler() -- 2868
	if not response then -- 2869
		if isCancelled and isCancelled() then -- 2870
			return { -- 2871
				success = false, -- 2871
				file = file, -- 2871
				message = "build canceled", -- 2871
				interrupted = true -- 2871
			} -- 2871
		end -- 2870
		return { -- 2872
			success = false, -- 2872
			file = file, -- 2872
			message = compilerFailure or "TypeScript transpile timed out", -- 2872
			failureKind = "tool" -- 2872
		} -- 2872
	end -- 2869
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2873
		local luaFile = Path:replaceExt(file, "lua") -- 2874
		if Content:save(luaFile, response.luaCode) then -- 2875
			return { -- 2876
				success = true, -- 2876
				file = file -- 2876
			} -- 2876
		end -- 2875
		return { -- 2877
			success = false, -- 2877
			file = file, -- 2877
			message = "failed to save " .. tostring(luaFile) -- 2877
		} -- 2877
	end -- 2873
	return { -- 2878
		success = false, -- 2878
		file = file, -- 2878
		message = response.message or "TypeScript transpile failed" -- 2878
	} -- 2878
end -- 2847
local compilerFailureListener = Node() -- 2880
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2881
	compilerFailure = message -- 2882
	compilerReady = false -- 2883
end) -- 2881
local transpileTSFile -- 2885
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2885
	if supportsCompilerWebView() and not files then -- 2886
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2887
	end -- 2886
	if HttpServer.wsConnectionCount > 0 then -- 2888
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2889
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2890
			return result -- 2890
		end -- 2890
		webIDECompilerReady = false -- 2891
	end -- 2888
	if supportsCompilerWebView() then -- 2892
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2893
	end -- 2892
	return { -- 2894
		success = false, -- 2894
		file = file, -- 2894
		message = "Web IDE compiler not connected", -- 2894
		failureKind = "tool" -- 2894
	} -- 2894
end -- 2885
local _anon_func_10 = function(path) -- 2909
	local _val_0 = Path:getExt(path) -- 2909
	return "ts" == _val_0 or "tsx" == _val_0 -- 2909
end -- 2909
HttpServer:postSchedule("/ts/build", function(req) -- 2896
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2897
	local buildSucceeded = false -- 2898
	local _ <close> = setmetatable({ }, { -- 2899
		__close = function() -- 2899
			return finishUpdate(buildSucceeded) -- 2899
		end -- 2899
	}) -- 2899
	do -- 2900
		local _type_0 = type(req) -- 2900
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2900
		if _tab_0 then -- 2900
			local path -- 2900
			do -- 2900
				local _obj_0 = req.body -- 2900
				local _type_1 = type(_obj_0) -- 2900
				if "table" == _type_1 or "userdata" == _type_1 then -- 2900
					path = _obj_0.path -- 2900
				end -- 2900
			end -- 2900
			if path ~= nil then -- 2900
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2901
					return { -- 2902
						success = false, -- 2902
						message = "Web IDE not connected" -- 2902
					} -- 2902
				end -- 2901
				local projectRoot = req.body.projectRoot -- 2903
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2904
				if not Content:exist(path) then -- 2905
					return { -- 2906
						success = false, -- 2906
						message = "path not existed" -- 2906
					} -- 2906
				end -- 2905
				local messages = { } -- 2907
				if not Content:isdir(path) then -- 2908
					if not (_anon_func_10(path)) then -- 2909
						return { -- 2910
							success = false, -- 2910
							message = "expecting a TypeScript file" -- 2910
						} -- 2910
					end -- 2909
					local content = Content:load(path) -- 2911
					if not content then -- 2912
						return { -- 2913
							success = false, -- 2913
							message = "failed to read file" -- 2913
						} -- 2913
					end -- 2912
					emit("AppWS", "Send", json.encode({ -- 2914
						name = "UpdateFile", -- 2914
						file = path, -- 2914
						exists = true, -- 2914
						content = content, -- 2914
						projectRoot = sourceRoot -- 2914
					})) -- 2914
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2915
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2916
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2917
					end -- 2915
				else -- 2919
					local fileData = { } -- 2919
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2920
					for _index_0 = 1, #_list_0 do -- 2920
						local subFile = _list_0[_index_0] -- 2920
						local file = Path(path, subFile) -- 2921
						local content = Content:load(file) -- 2922
						if content then -- 2922
							fileData[file] = content -- 2923
							emit("AppWS", "Send", json.encode({ -- 2924
								name = "UpdateFile", -- 2924
								file = file, -- 2924
								exists = true, -- 2924
								content = content, -- 2924
								projectRoot = sourceRoot -- 2924
							})) -- 2924
						else -- 2926
							messages[#messages + 1] = { -- 2926
								success = false, -- 2926
								file = file, -- 2926
								message = "failed to read file" -- 2926
							} -- 2926
						end -- 2922
					end -- 2920
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2927
					for file, content in pairs(fileData) do -- 2928
						if "d" == Path:getExt(Path:getName(file)) then -- 2929
							goto _continue_0 -- 2929
						end -- 2929
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2930
						::_continue_0:: -- 2929
					end -- 2928
				end -- 2908
				local success = true -- 2931
				for _index_0 = 1, #messages do -- 2932
					local item = messages[_index_0] -- 2932
					if not item.success then -- 2933
						success = false -- 2933
					end -- 2933
				end -- 2932
				local message = nil -- 2934
				if not success then -- 2935
					message = "TypeScript compilation failed" -- 2935
				end -- 2935
				buildSucceeded = success -- 2936
				return { -- 2937
					success = success, -- 2937
					messages = messages, -- 2937
					message = message -- 2937
				} -- 2937
			end -- 2900
		end -- 2900
	end -- 2900
	return { -- 2896
		success = false -- 2896
	} -- 2896
end) -- 2896
HttpServer:post("/download", function(req) -- 2939
	do -- 2940
		local _type_0 = type(req) -- 2940
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2940
		if _tab_0 then -- 2940
			local url -- 2940
			do -- 2940
				local _obj_0 = req.body -- 2940
				local _type_1 = type(_obj_0) -- 2940
				if "table" == _type_1 or "userdata" == _type_1 then -- 2940
					url = _obj_0.url -- 2940
				end -- 2940
			end -- 2940
			local target -- 2940
			do -- 2940
				local _obj_0 = req.body -- 2940
				local _type_1 = type(_obj_0) -- 2940
				if "table" == _type_1 or "userdata" == _type_1 then -- 2940
					target = _obj_0.target -- 2940
				end -- 2940
			end -- 2940
			if url ~= nil and target ~= nil then -- 2940
				local Entry = require("Script.Dev.Entry") -- 2941
				Entry.downloadFile(url, target) -- 2942
				return { -- 2943
					success = true -- 2943
				} -- 2943
			end -- 2940
		end -- 2940
	end -- 2940
	return { -- 2939
		success = false -- 2939
	} -- 2939
end) -- 2939
local isDesktopPlatform -- 2945
isDesktopPlatform = function() -- 2945
	local _val_0 = App.platform -- 2946
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2946
end -- 2945
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 2948
local nativeIDEListener = Node() -- 2949
nativeIDEListener:addTo(Director.systemUI) -- 2950
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 2951
	nativeIDEState, nativeIDEMessage = state, message -- 2952
end) -- 2951
local _anon_func_11 = function() -- 2955
	local _val_0 = App.platform -- 2955
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2955
end -- 2955
HttpServer:post("/ide", function(req) -- 2954
	if not (_anon_func_11()) then -- 2955
		return { -- 2955
			success = false, -- 2955
			message = "Native IDE is unavailable" -- 2955
		} -- 2955
	end -- 2955
	if not App.webIDEEnabled then -- 2956
		return { -- 2956
			success = false, -- 2956
			message = "Embedded Web IDE is disabled" -- 2956
		} -- 2956
	end -- 2956
	do -- 2957
		local _type_0 = type(req) -- 2957
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2957
		if _tab_0 then -- 2957
			local action -- 2957
			do -- 2957
				local _obj_0 = req.body -- 2957
				local _type_1 = type(_obj_0) -- 2957
				if "table" == _type_1 or "userdata" == _type_1 then -- 2957
					action = _obj_0.action -- 2957
				end -- 2957
			end -- 2957
			if action ~= nil then -- 2957
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 2958
					emit("AppWebView", "/ide/" .. action, true) -- 2959
					return { -- 2960
						success = true -- 2960
					} -- 2960
				end -- 2958
			end -- 2957
		end -- 2957
	end -- 2957
	return { -- 2954
		success = false, -- 2954
		message = "invalid IDE action" -- 2954
	} -- 2954
end) -- 2954
local _anon_func_12 = function() -- 2976
	local _val_0 = App.platform -- 2976
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2976
end -- 2976
local getServerStatus -- 2962
getServerStatus = function() -- 2962
	local Entry = require("Script.Dev.Entry") -- 2963
	local running = Entry.getCurrentEntryStatus() -- 2964
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2965
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2966
	return { -- 2968
		success = true, -- 2968
		platform = App.platform, -- 2969
		locale = App.locale, -- 2970
		version = App.version, -- 2971
		url = "http://localhost:8866", -- 2972
		wsConnectionCount = wsConnectionCount, -- 2973
		webIDEConnected = wsConnectionCount > 0, -- 2974
		nativeIDE = { -- 2976
			supported = _anon_func_12(), -- 2976
			enabled = App.webIDEEnabled, -- 2977
			state = nativeIDEState, -- 2978
			message = nativeIDEMessage -- 2979
		}, -- 2975
		typescriptCompiler = { -- 2981
			webIDEReady = webIDECompilerReady, -- 2981
			webIDEGeneration = webIDEConnectionGeneration, -- 2982
			embeddedSupported = supportsCompilerWebView(), -- 2983
			embeddedRequested = compilerRequested, -- 2984
			embeddedReady = compilerReady, -- 2985
			users = compilerUsers, -- 2986
			queuedJobs = #compilerJobs, -- 2987
			failure = compilerFailure -- 2988
		}, -- 2980
		assetPath = Content.assetPath, -- 2989
		writablePath = Content.writablePath, -- 2990
		appPath = Content.appPath, -- 2991
		waTemplateReady = waTemplateReady, -- 2992
		running = running -- 2993
	} -- 2967
end -- 2962
HttpServer:post("/status", function() -- 2996
	return getServerStatus() -- 2997
end) -- 2996
HttpServer:postSchedule("/doctor/fix", function(req) -- 2999
	do -- 3000
		local _type_0 = type(req) -- 3000
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3000
		if _tab_0 then -- 3000
			local openWebIDE -- 3000
			do -- 3000
				local _obj_0 = req.body -- 3000
				local _type_1 = type(_obj_0) -- 3000
				if "table" == _type_1 or "userdata" == _type_1 then -- 3000
					openWebIDE = _obj_0.openWebIDE -- 3000
				end -- 3000
			end -- 3000
			if openWebIDE ~= nil then -- 3000
				if not openWebIDE then -- 3001
					return { -- 3002
						success = false, -- 3002
						message = "nothing to fix" -- 3002
					} -- 3002
				end -- 3001
				local status = getServerStatus() -- 3003
				if status.webIDEConnected then -- 3004
					return { -- 3005
						success = true, -- 3005
						fixed = false, -- 3005
						message = "Web IDE already connected.", -- 3005
						status = status -- 3005
					} -- 3005
				end -- 3004
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 3006
				if waitSeconds > 0 then -- 3007
					local deadline = os.time() + waitSeconds -- 3008
					repeat -- 3009
						sleep(0.2) -- 3010
						status = getServerStatus() -- 3011
						if status.webIDEConnected then -- 3012
							return { -- 3013
								success = true, -- 3013
								fixed = false, -- 3013
								reconnected = true, -- 3013
								message = "Web IDE reconnected.", -- 3013
								status = status -- 3013
							} -- 3013
						end -- 3012
					until os.time() >= deadline -- 3009
				end -- 3007
				if not isDesktopPlatform() then -- 3015
					return { -- 3016
						success = false, -- 3016
						message = "opening Web IDE is only supported on desktop platforms", -- 3016
						status = status -- 3016
					} -- 3016
				end -- 3015
				local url = "http://localhost:8866" -- 3017
				App:openURL(url) -- 3018
				status.openedURL = url -- 3019
				return { -- 3020
					success = true, -- 3020
					fixed = true, -- 3020
					message = "Opened Web IDE in the local browser.", -- 3020
					url = url, -- 3020
					status = status -- 3020
				} -- 3020
			end -- 3000
		end -- 3000
	end -- 3000
	return { -- 2999
		success = false, -- 2999
		message = "invalid call" -- 2999
	} -- 2999
end) -- 2999
local status = { } -- 3022
_module_0 = status -- 3023
status.transpileTSFile = transpileTSFile -- 3025
HttpServer:postSchedule("/godot/project", function(req) -- 3028
	do -- 3029
		local _type_0 = type(req) -- 3029
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3029
		if _tab_0 then -- 3029
			local path -- 3029
			do -- 3029
				local _obj_0 = req.body -- 3029
				local _type_1 = type(_obj_0) -- 3029
				if "table" == _type_1 or "userdata" == _type_1 then -- 3029
					path = _obj_0.path -- 3029
				end -- 3029
			end -- 3029
			if path ~= nil then -- 3029
				if not (type(path) == "string" and Content:isAbsolutePath(path)) then -- 3030
					return invalidArguments -- 3030
				end -- 3030
				local releaseAgent = AgentHost.acquire() -- 3031
				local _ <close> = setmetatable({ }, { -- 3032
					__close = function() -- 3032
						return releaseAgent() -- 3032
					end -- 3032
				}) -- 3032
				local GodotBuild = require("Agent.Tool.GodotBuild") -- 3033
				local project = GodotBuild.findGodotProject(Content.writablePath, path) or GodotBuild.findGodotProject(Content.assetPath, path) -- 3034
				if not project then -- 3035
					return { -- 3035
						success = true, -- 3035
						found = false -- 3035
					} -- 3035
				end -- 3035
				if not (req.body.build == true) then -- 3036
					return { -- 3036
						success = true, -- 3036
						found = true, -- 3036
						projectRoot = project -- 3036
					} -- 3036
				end -- 3036
				local result -- 3037
				local promise = GodotBuild.buildGodotProject(project) -- 3038
				local onFulfilled -- 3039
				onFulfilled = function(_, value) -- 3039
					result = value -- 3040
				end -- 3039
				local onRejected -- 3041
				onRejected = function(_, err) -- 3041
					result = { -- 3042
						success = false, -- 3042
						message = tostring(err) -- 3042
					} -- 3042
				end -- 3041
				promise["then"](promise, onFulfilled, onRejected) -- 3043
				wait(function() -- 3044
					return result ~= nil -- 3044
				end) -- 3044
				result.found = true -- 3045
				result.projectRoot = project -- 3046
				return result -- 3047
			end -- 3029
		end -- 3029
	end -- 3029
	return invalidArguments -- 3028
end) -- 3028
status.buildAsync = function(path) -- 3049
	if not Content:exist(path) then -- 3050
		return { -- 3051
			success = false, -- 3051
			file = path, -- 3051
			message = "file not existed" -- 3051
		} -- 3051
	end -- 3050
	do -- 3052
		local _exp_0 = Path:getExt(path) -- 3052
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 3052
			if '' == Path:getExt(Path:getName(path)) then -- 3053
				local content = Content:loadAsync(path) -- 3054
				if content then -- 3054
					local resultCodes, err = compileFileAsync(path, content) -- 3055
					if resultCodes then -- 3055
						return { -- 3056
							success = true, -- 3056
							file = path -- 3056
						} -- 3056
					else -- 3058
						return { -- 3058
							success = false, -- 3058
							file = path, -- 3058
							message = err -- 3058
						} -- 3058
					end -- 3055
				end -- 3054
			end -- 3053
		elseif "lua" == _exp_0 then -- 3059
			local content = Content:loadAsync(path) -- 3060
			if content then -- 3060
				do -- 3061
					local isTIC80 = CheckTIC80Code(content) -- 3061
					if isTIC80 then -- 3061
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 3062
					end -- 3061
				end -- 3061
				local success, info -- 3063
				do -- 3063
					local _obj_0 = luaCheck(path, content) -- 3063
					success, info = _obj_0.success, _obj_0.info -- 3063
				end -- 3063
				if success then -- 3064
					return { -- 3065
						success = true, -- 3065
						file = path -- 3065
					} -- 3065
				elseif info and #info > 0 then -- 3066
					local messages = { } -- 3067
					for _index_0 = 1, #info do -- 3068
						local _des_0 = info[_index_0] -- 3068
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3068
						local lineText = "" -- 3069
						if line then -- 3070
							local currentLine = 1 -- 3071
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3072
								if currentLine == line then -- 3073
									lineText = text -- 3074
									break -- 3075
								end -- 3073
								currentLine = currentLine + 1 -- 3076
							end -- 3072
						end -- 3070
						if line then -- 3077
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3078
						else -- 3080
							messages[#messages + 1] = message -- 3080
						end -- 3077
					end -- 3068
					return { -- 3081
						success = false, -- 3081
						file = path, -- 3081
						message = table.concat(messages, "\n") -- 3081
					} -- 3081
				else -- 3083
					return { -- 3083
						success = false, -- 3083
						file = path, -- 3083
						message = "lua check failed" -- 3083
					} -- 3083
				end -- 3064
			end -- 3060
		elseif "yarn" == _exp_0 then -- 3084
			local content = Content:loadAsync(path) -- 3085
			if content then -- 3085
				local res, _, err = yarncompile(content, true) -- 3086
				if res then -- 3086
					return { -- 3087
						success = true, -- 3087
						file = path -- 3087
					} -- 3087
				else -- 3089
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3089
					local lineText = "" -- 3090
					if line then -- 3091
						local currentLine = 1 -- 3092
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3093
							if currentLine == line then -- 3094
								lineText = text -- 3095
								break -- 3096
							end -- 3094
							currentLine = currentLine + 1 -- 3097
						end -- 3093
					end -- 3091
					if node ~= "" then -- 3098
						node = "node: " .. tostring(node) .. ", " -- 3099
					else -- 3100
						node = "" -- 3100
					end -- 3098
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3101
					return { -- 3102
						success = false, -- 3102
						file = path, -- 3102
						message = message -- 3102
					} -- 3102
				end -- 3086
			end -- 3085
		end -- 3052
	end -- 3052
	return { -- 3103
		success = false, -- 3103
		file = path, -- 3103
		message = "invalid file to build" -- 3103
	} -- 3103
end -- 3049
HttpServer:postSchedule("/git/commit-files", function(req) -- 3105
	do -- 3106
		local _type_0 = type(req) -- 3106
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3106
		if _tab_0 then -- 3106
			local body = req.body -- 3106
			if body ~= nil then -- 3106
				local repoPath, commit = body.repoPath, body.commit -- 3107
				if gitInvalidRepoPath(repoPath) then -- 3108
					return { -- 3108
						success = false, -- 3108
						message = "invalid repoPath" -- 3108
					} -- 3108
				end -- 3108
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3109
					return { -- 3109
						success = false, -- 3109
						message = "invalid commit" -- 3109
					} -- 3109
				end -- 3109
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3110
				if not res.success then -- 3111
					return res -- 3111
				end -- 3111
				return { -- 3112
					success = true, -- 3112
					status = res.status, -- 3112
					data = res.status and res.status.data -- 3112
				} -- 3112
			end -- 3106
		end -- 3106
	end -- 3106
	return invalidArguments -- 3105
end) -- 3105
thread(function() -- 3114
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3115
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3116
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3117
		local storedAsset -- 3120
		storedAsset = function(file) -- 3120
			if Content:exist(file) then -- 3121
				return Content:load(file) -- 3122
			elseif Content:exist(file .. ".gz") then -- 3123
				return Content:load(file .. ".gz") -- 3124
			else -- 3125
				return "" -- 3125
			end -- 3121
		end -- 3120
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3126
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3127
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3128
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3129
		local readyContent = table.concat({ -- 3131
			App.version, -- 3131
			storedAsset(doraWeb), -- 3132
			storedAsset(heavyAssets), -- 3133
			storedAsset(runtimeIndex), -- 3134
			storedAsset(compilerIndex), -- 3135
			storedAsset(manifest) -- 3136
		}, "\n") -- 3130
		local needReload -- 3138
		if Content:exist(doraReady) then -- 3138
			needReload = readyContent ~= Content:load(doraReady) -- 3139
		else -- 3140
			needReload = true -- 3140
		end -- 3138
		if needReload then -- 3141
			Content:remove(Path(Content.appPath, ".www")) -- 3142
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3143
			Content:save(doraReady, readyContent) -- 3147
			print("Dora Dora is ready!") -- 3148
		end -- 3141
	end -- 3117
	if App.platform == "Emscripten" then -- 3149
		status.url = nil -- 3150
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3151
	end -- 3149
	HttpServer:clearStaticCacheControls() -- 3152
	HttpServer:setStaticCacheControl("no-cache") -- 3153
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3154
	if HttpServer:start(8866) then -- 3158
		local localIP = HttpServer.localIP -- 3159
		if localIP == "" then -- 3160
			localIP = "localhost" -- 3160
		end -- 3160
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3161
		return HttpServer:startWS(8868) -- 3162
	else -- 3164
		status.url = nil -- 3164
		return print("8866 Port not available!") -- 3165
	end -- 3158
end) -- 3114
return _module_0 -- 1
