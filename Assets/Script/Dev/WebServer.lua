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
		else -- 1515
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1515
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
	]]) -- 1516
	require("Agent.Config.LLMConfigMigration").upgradeLLMConfig() -- 1535
	return require("Agent.Config.LLMConfigNames").upgradeLLMConfigNames() -- 1536
end -- 1476
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
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options\n		from LLMConfig\n		order by id asc") -- 1578
	local items -- 1582
	if rows and #rows > 0 then -- 1582
		local _accum_0 = { } -- 1583
		local _len_0 = 1 -- 1583
		for _index_0 = 1, #rows do -- 1583
			local _des_0 = rows[_index_0] -- 1583
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10] -- 1583
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
				customOptions = normalizeCustomOptions(customOptions) -- 1584
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
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions -- 1590
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
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1611
					tostring(name), -- 1611
					tostring(url), -- 1612
					tostring(model), -- 1613
					tostring(key), -- 1614
					contextWindow, -- 1615
					temperature, -- 1616
					maxTokens, -- 1617
					reasoningEffort, -- 1618
					customOptions, -- 1619
					1, -- 1620
					now, -- 1621
					now -- 1622
				}) -- 1605
				if affected < 0 then -- 1624
					nameCheck = names.checkLLMConfigName(name) -- 1625
					if not nameCheck.success then -- 1626
						return nameCheck -- 1626
					end -- 1626
				end -- 1624
				return { -- 1627
					success = affected > 0 -- 1627
				} -- 1627
			end -- 1589
		end -- 1589
	end -- 1589
	return invalidArguments -- 1587
end) -- 1587
HttpServer:post("/llm/update", function(req) -- 1629
	ensureLLMConfigTable() -- 1630
	do -- 1631
		local _type_0 = type(req) -- 1631
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1631
		if _tab_0 then -- 1631
			local body = req.body -- 1631
			if body ~= nil then -- 1631
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions -- 1632
				local now = os.time() -- 1633
				id = tonumber(id) -- 1634
				if id == nil or id <= 0 or id ~= math.floor(id) then -- 1635
					return invalidArguments -- 1635
				end -- 1635
				local names = require("Agent.Config.LLMConfigNames") -- 1636
				name = names.normalizeLLMConfigName(name) -- 1637
				if not name then -- 1638
					return { -- 1638
						success = false, -- 1638
						code = "INVALID_LLM_CONFIG_NAME", -- 1638
						message = "LLM configuration name must be a non-empty string" -- 1638
					} -- 1638
				end -- 1638
				local nameCheck = names.checkLLMConfigName(name, id) -- 1639
				if not nameCheck.success then -- 1640
					return nameCheck -- 1640
				end -- 1640
				contextWindow = normalizeContextWindow(contextWindow) -- 1641
				temperature = normalizeTemperature(temperature) -- 1642
				maxTokens = normalizeMaxTokens(maxTokens) -- 1643
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1644
				customOptions = normalizeCustomOptions(customOptions) -- 1645
				if not validateCustomOptions(customOptions) then -- 1646
					return { -- 1646
						success = false, -- 1646
						message = "customOptions must be a JSON object" -- 1646
					} -- 1646
				end -- 1646
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, updated_at = ?\n			where id = ?", { -- 1651
					tostring(name), -- 1651
					tostring(url), -- 1652
					tostring(model), -- 1653
					tostring(key), -- 1654
					contextWindow, -- 1655
					temperature, -- 1656
					maxTokens, -- 1657
					reasoningEffort, -- 1658
					customOptions, -- 1659
					now, -- 1660
					id -- 1661
				}) -- 1647
				if affected < 0 then -- 1663
					nameCheck = names.checkLLMConfigName(name, id) -- 1664
					if not nameCheck.success then -- 1665
						return nameCheck -- 1665
					end -- 1665
				end -- 1663
				return { -- 1666
					success = affected > 0 -- 1666
				} -- 1666
			end -- 1631
		end -- 1631
	end -- 1631
	return invalidArguments -- 1629
end) -- 1629
HttpServer:post("/llm/delete", function(req) -- 1668
	ensureLLMConfigTable() -- 1669
	do -- 1670
		local _type_0 = type(req) -- 1670
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1670
		if _tab_0 then -- 1670
			local id -- 1670
			do -- 1670
				local _obj_0 = req.body -- 1670
				local _type_1 = type(_obj_0) -- 1670
				if "table" == _type_1 or "userdata" == _type_1 then -- 1670
					id = _obj_0.id -- 1670
				end -- 1670
			end -- 1670
			if id ~= nil then -- 1670
				id = tonumber(id) -- 1671
				if id == nil then -- 1672
					return invalidArguments -- 1672
				end -- 1672
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1673
					id -- 1673
				}) -- 1673
				return { -- 1674
					success = affected >= 0 -- 1674
				} -- 1674
			end -- 1670
		end -- 1670
	end -- 1670
	return invalidArguments -- 1668
end) -- 1668
HttpServer:post("/local-agent/list", function() -- 1676
	return { -- 1677
		success = true, -- 1677
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1677
		items = AgentLocalAgent.listConfigs() -- 1677
	} -- 1677
end) -- 1676
HttpServer:post("/local-agent/save", function(req) -- 1679
	do -- 1680
		local _type_0 = type(req) -- 1680
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1680
		if _tab_0 then -- 1680
			local body = req.body -- 1680
			if body ~= nil then -- 1680
				return AgentLocalAgent.saveConfig(body) -- 1681
			end -- 1680
		end -- 1680
	end -- 1680
	return invalidArguments -- 1679
end) -- 1679
HttpServer:post("/local-agent/delete", function(req) -- 1683
	do -- 1684
		local _type_0 = type(req) -- 1684
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1684
		if _tab_0 then -- 1684
			local id -- 1684
			do -- 1684
				local _obj_0 = req.body -- 1684
				local _type_1 = type(_obj_0) -- 1684
				if "table" == _type_1 or "userdata" == _type_1 then -- 1684
					id = _obj_0.id -- 1684
				end -- 1684
			end -- 1684
			if id ~= nil then -- 1684
				return AgentLocalAgent.deleteConfig(id) -- 1685
			end -- 1684
		end -- 1684
	end -- 1684
	return invalidArguments -- 1683
end) -- 1683
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1687
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
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1689
			end -- 1688
		end -- 1688
	end -- 1688
	return invalidArguments -- 1687
end) -- 1687
HttpServer:post("/stat", function(req) -- 1691
	do -- 1692
		local _type_0 = type(req) -- 1692
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1692
		if _tab_0 then -- 1692
			local path -- 1692
			do -- 1692
				local _obj_0 = req.body -- 1692
				local _type_1 = type(_obj_0) -- 1692
				if "table" == _type_1 or "userdata" == _type_1 then -- 1692
					path = _obj_0.path -- 1692
				end -- 1692
			end -- 1692
			if path ~= nil then -- 1692
				if not Content:exist(path) then -- 1693
					return { -- 1694
						success = false, -- 1694
						message = "target not existed" -- 1694
					} -- 1694
				end -- 1693
				if Content:isdir(path) then -- 1695
					return { -- 1696
						success = false, -- 1696
						message = "failed to stat a directory" -- 1696
					} -- 1696
				end -- 1695
				local size, isBinary = Content:getAttr(path) -- 1697
				if size then -- 1697
					return { -- 1698
						success = true, -- 1698
						size = size, -- 1698
						isBinary = isBinary -- 1698
					} -- 1698
				end -- 1697
			end -- 1692
		end -- 1692
	end -- 1692
	return { -- 1691
		success = false, -- 1691
		message = "failed to stat" -- 1691
	} -- 1691
end) -- 1691
HttpServer:post("/new", function(req) -- 1700
	do -- 1701
		local _type_0 = type(req) -- 1701
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1701
		if _tab_0 then -- 1701
			local path -- 1701
			do -- 1701
				local _obj_0 = req.body -- 1701
				local _type_1 = type(_obj_0) -- 1701
				if "table" == _type_1 or "userdata" == _type_1 then -- 1701
					path = _obj_0.path -- 1701
				end -- 1701
			end -- 1701
			local content -- 1701
			do -- 1701
				local _obj_0 = req.body -- 1701
				local _type_1 = type(_obj_0) -- 1701
				if "table" == _type_1 or "userdata" == _type_1 then -- 1701
					content = _obj_0.content -- 1701
				end -- 1701
			end -- 1701
			local folder -- 1701
			do -- 1701
				local _obj_0 = req.body -- 1701
				local _type_1 = type(_obj_0) -- 1701
				if "table" == _type_1 or "userdata" == _type_1 then -- 1701
					folder = _obj_0.folder -- 1701
				end -- 1701
			end -- 1701
			if path ~= nil and content ~= nil and folder ~= nil then -- 1701
				if Content:exist(path) then -- 1702
					return { -- 1703
						success = false, -- 1703
						message = "TargetExisted" -- 1703
					} -- 1703
				end -- 1702
				local parent = Path:getPath(path) -- 1704
				local files = Content:getFiles(parent) -- 1705
				if folder then -- 1706
					local name = Path:getFilename(path):lower() -- 1707
					for _index_0 = 1, #files do -- 1708
						local file = files[_index_0] -- 1708
						if name == Path:getFilename(file):lower() then -- 1709
							return { -- 1710
								success = false, -- 1710
								message = "TargetExisted" -- 1710
							} -- 1710
						end -- 1709
					end -- 1708
					if Content:mkdir(path) then -- 1711
						return { -- 1712
							success = true -- 1712
						} -- 1712
					end -- 1711
				else -- 1714
					local name = Path:getName(path):lower() -- 1714
					for _index_0 = 1, #files do -- 1715
						local file = files[_index_0] -- 1715
						if name == Path:getName(file):lower() then -- 1716
							local ext = Path:getExt(file) -- 1717
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1718
								goto _continue_0 -- 1719
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1720
								goto _continue_0 -- 1721
							end -- 1718
							return { -- 1722
								success = false, -- 1722
								message = "SourceExisted" -- 1722
							} -- 1722
						end -- 1716
						::_continue_0:: -- 1716
					end -- 1715
					if Content:save(path, content) then -- 1723
						return { -- 1724
							success = true -- 1724
						} -- 1724
					end -- 1723
				end -- 1706
			end -- 1701
		end -- 1701
	end -- 1701
	return { -- 1700
		success = false, -- 1700
		message = "Failed" -- 1700
	} -- 1700
end) -- 1700
local deleteAsset -- 1726
deleteAsset = function(path) -- 1726
	if not Content:exist(path) then -- 1727
		return false -- 1727
	end -- 1727
	local projectRoot -- 1728
	if Content:isdir(path) and isProjectRootDir(path) then -- 1728
		projectRoot = path -- 1728
	else -- 1728
		projectRoot = nil -- 1728
	end -- 1728
	local parent = Path:getPath(path) -- 1729
	local files = Content:getFiles(parent) -- 1730
	local name = Path:getName(path):lower() -- 1731
	local ext = Path:getExt(path) -- 1732
	for _index_0 = 1, #files do -- 1733
		local file = files[_index_0] -- 1733
		if name == Path:getName(file):lower() then -- 1734
			local _exp_0 = Path:getExt(file) -- 1735
			if "tl" == _exp_0 then -- 1735
				if ("vs" == ext) then -- 1735
					Content:remove(Path(parent, file)) -- 1736
				end -- 1735
			elseif "lua" == _exp_0 then -- 1737
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1737
					Content:remove(Path(parent, file)) -- 1738
				end -- 1737
			end -- 1735
		end -- 1734
	end -- 1733
	if Content:remove(path) then -- 1739
		if projectRoot then -- 1740
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1741
		end -- 1740
		return true -- 1742
	end -- 1739
	return false -- 1743
end -- 1726
local moveAsset -- 1745
moveAsset = function(old, new) -- 1745
	if not (Content:exist(old) and not Content:exist(new)) then -- 1746
		return false -- 1746
	end -- 1746
	local renamedDir = Content:isdir(old) -- 1747
	local parent = Path:getPath(new) -- 1748
	local files = Content:getFiles(parent) -- 1749
	if renamedDir then -- 1750
		local name = Path:getFilename(new):lower() -- 1751
		for _index_0 = 1, #files do -- 1752
			local file = files[_index_0] -- 1752
			if name == Path:getFilename(file):lower() then -- 1753
				return false -- 1754
			end -- 1753
		end -- 1752
	else -- 1756
		local name = Path:getName(new):lower() -- 1756
		local ext = Path:getExt(new) -- 1757
		for _index_0 = 1, #files do -- 1758
			local file = files[_index_0] -- 1758
			if name == Path:getName(file):lower() then -- 1759
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1760
					goto _continue_0 -- 1761
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1762
					goto _continue_0 -- 1763
				end -- 1760
				return false -- 1764
			end -- 1759
			::_continue_0:: -- 1759
		end -- 1758
	end -- 1750
	if not Content:move(old, new) then -- 1765
		return false -- 1765
	end -- 1765
	if renamedDir then -- 1766
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1767
	end -- 1766
	local newParent = Path:getPath(new) -- 1768
	parent = Path:getPath(old) -- 1769
	files = Content:getFiles(parent) -- 1770
	local newName = Path:getName(new) -- 1771
	local oldName = Path:getName(old) -- 1772
	local name = oldName:lower() -- 1773
	local ext = Path:getExt(old) -- 1774
	for _index_0 = 1, #files do -- 1775
		local file = files[_index_0] -- 1775
		if name == Path:getName(file):lower() then -- 1776
			local _exp_0 = Path:getExt(file) -- 1777
			if "tl" == _exp_0 then -- 1777
				if ("vs" == ext) then -- 1777
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1778
				end -- 1777
			elseif "lua" == _exp_0 then -- 1779
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1779
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1780
				end -- 1779
			end -- 1777
		end -- 1776
	end -- 1775
	return true -- 1781
end -- 1745
HttpServer:post("/delete", function(req) -- 1783
	do -- 1784
		local _type_0 = type(req) -- 1784
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1784
		if _tab_0 then -- 1784
			local path -- 1784
			do -- 1784
				local _obj_0 = req.body -- 1784
				local _type_1 = type(_obj_0) -- 1784
				if "table" == _type_1 or "userdata" == _type_1 then -- 1784
					path = _obj_0.path -- 1784
				end -- 1784
			end -- 1784
			if path ~= nil then -- 1784
				if deleteAsset(path) then -- 1785
					return { -- 1785
						success = true -- 1785
					} -- 1785
				end -- 1785
			end -- 1784
		end -- 1784
	end -- 1784
	return { -- 1783
		success = false -- 1783
	} -- 1783
end) -- 1783
HttpServer:post("/rename", function(req) -- 1787
	do -- 1788
		local _type_0 = type(req) -- 1788
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1788
		if _tab_0 then -- 1788
			local old -- 1788
			do -- 1788
				local _obj_0 = req.body -- 1788
				local _type_1 = type(_obj_0) -- 1788
				if "table" == _type_1 or "userdata" == _type_1 then -- 1788
					old = _obj_0.old -- 1788
				end -- 1788
			end -- 1788
			local new -- 1788
			do -- 1788
				local _obj_0 = req.body -- 1788
				local _type_1 = type(_obj_0) -- 1788
				if "table" == _type_1 or "userdata" == _type_1 then -- 1788
					new = _obj_0.new -- 1788
				end -- 1788
			end -- 1788
			if old ~= nil and new ~= nil then -- 1788
				if moveAsset(old, new) then -- 1789
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
local normalizeAssetPaths -- 1791
normalizeAssetPaths = function(paths) -- 1791
	if not (type(paths) == "table") then -- 1792
		return nil -- 1792
	end -- 1792
	local unique = { } -- 1793
	local candidates = { } -- 1794
	for _index_0 = 1, #paths do -- 1795
		local path = paths[_index_0] -- 1795
		if not (type(path) == "string") then -- 1796
			return nil -- 1796
		end -- 1796
		local relative = relativeToRoot(path, Content.writablePath) -- 1797
		if relative == nil or relative == "" or not Content:exist(path) then -- 1798
			return nil -- 1798
		end -- 1798
		if not unique[path] then -- 1799
			unique[path] = true -- 1800
			candidates[#candidates + 1] = path -- 1801
		end -- 1799
	end -- 1795
	table.sort(candidates, function(a, b) -- 1802
		return #a < #b -- 1802
	end) -- 1802
	local result = { } -- 1803
	for _index_0 = 1, #candidates do -- 1804
		local path = candidates[_index_0] -- 1804
		local contained = false -- 1805
		for _index_1 = 1, #result do -- 1806
			local parent = result[_index_1] -- 1806
			if relativeToRoot(path, parent) ~= nil then -- 1807
				contained = true -- 1808
				break -- 1809
			end -- 1807
		end -- 1806
		if not contained then -- 1810
			result[#result + 1] = path -- 1810
		end -- 1810
	end -- 1804
	return result -- 1811
end -- 1791
HttpServer:postSchedule("/assets/batch", function(req) -- 1813
	do -- 1814
		local _type_0 = type(req) -- 1814
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1814
		if _tab_0 then -- 1814
			local operation -- 1814
			do -- 1814
				local _obj_0 = req.body -- 1814
				local _type_1 = type(_obj_0) -- 1814
				if "table" == _type_1 or "userdata" == _type_1 then -- 1814
					operation = _obj_0.operation -- 1814
				end -- 1814
			end -- 1814
			local sources -- 1814
			do -- 1814
				local _obj_0 = req.body -- 1814
				local _type_1 = type(_obj_0) -- 1814
				if "table" == _type_1 or "userdata" == _type_1 then -- 1814
					sources = _obj_0.sources -- 1814
				end -- 1814
			end -- 1814
			if operation ~= nil and sources ~= nil then -- 1814
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1815
					return { -- 1815
						success = false, -- 1815
						message = "invalid operation" -- 1815
					} -- 1815
				end -- 1815
				sources = normalizeAssetPaths(sources) -- 1816
				if not (sources and #sources > 0) then -- 1817
					return { -- 1817
						success = false, -- 1817
						message = "invalid sources" -- 1817
					} -- 1817
				end -- 1817
				local target = req.body.target -- 1818
				local destinations = { } -- 1819
				if operation ~= "delete" then -- 1820
					if not (type(target) == "string") then -- 1821
						return { -- 1821
							success = false, -- 1821
							message = "invalid target" -- 1821
						} -- 1821
					end -- 1821
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1822
					if targetRelative == nil then -- 1823
						return { -- 1823
							success = false, -- 1823
							message = "invalid target" -- 1823
						} -- 1823
					end -- 1823
					if not (Content:exist(target) and Content:isdir(target)) then -- 1824
						return { -- 1824
							success = false, -- 1824
							message = "invalid target" -- 1824
						} -- 1824
					end -- 1824
					for _index_0 = 1, #sources do -- 1825
						local source = sources[_index_0] -- 1825
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1826
							return { -- 1827
								success = false, -- 1827
								message = "target inside source" -- 1827
							} -- 1827
						end -- 1826
						local destination = Path(target, Path:getFilename(source)) -- 1828
						if Content:exist(destination) then -- 1829
							return { -- 1829
								success = false, -- 1829
								message = "target existed" -- 1829
							} -- 1829
						end -- 1829
						if destinations[destination] then -- 1830
							return { -- 1830
								success = false, -- 1830
								message = "duplicate target" -- 1830
							} -- 1830
						end -- 1830
						destinations[destination] = true -- 1831
					end -- 1825
				end -- 1820
				local changes = { } -- 1832
				local affectedSet = { } -- 1833
				local affectedDirectories = { } -- 1834
				local addAffected -- 1835
				addAffected = function(dir) -- 1835
					if affectedSet[dir] then -- 1836
						return -- 1836
					end -- 1836
					affectedSet[dir] = true -- 1837
					affectedDirectories[#affectedDirectories + 1] = dir -- 1838
				end -- 1835
				if operation ~= "delete" then -- 1839
					addAffected(target) -- 1839
				end -- 1839
				for _index_0 = 1, #sources do -- 1840
					local source = sources[_index_0] -- 1840
					addAffected(Path:getPath(source)) -- 1841
					if operation == "delete" then -- 1842
						if not deleteAsset(source) then -- 1843
							return { -- 1843
								success = false, -- 1843
								message = "delete failed", -- 1843
								changes = changes, -- 1843
								affectedDirectories = affectedDirectories -- 1843
							} -- 1843
						end -- 1843
						changes[#changes + 1] = { -- 1844
							old = source -- 1844
						} -- 1844
					else -- 1846
						local destination = Path(target, Path:getFilename(source)) -- 1846
						local ok -- 1847
						if operation == "copy" then -- 1847
							ok = Content:copyAsync(source, destination) -- 1848
						else -- 1850
							ok = moveAsset(source, destination) -- 1850
						end -- 1847
						if not ok then -- 1851
							return { -- 1851
								success = false, -- 1851
								message = operation .. " failed", -- 1851
								changes = changes, -- 1851
								affectedDirectories = affectedDirectories -- 1851
							} -- 1851
						end -- 1851
						changes[#changes + 1] = { -- 1852
							old = source, -- 1852
							new = destination -- 1852
						} -- 1852
					end -- 1842
				end -- 1840
				return { -- 1853
					success = true, -- 1853
					changes = changes, -- 1853
					affectedDirectories = affectedDirectories -- 1853
				} -- 1853
			end -- 1814
		end -- 1814
	end -- 1814
	return { -- 1813
		success = false, -- 1813
		message = "invalid request" -- 1813
	} -- 1813
end) -- 1813
local withProjectSearchPaths -- 1855
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1855
	local fallbackPaths = { } -- 1856
	local addFallback -- 1857
	addFallback = function(dir) -- 1857
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1857
			fallbackPaths[#fallbackPaths + 1] = dir -- 1857
		end -- 1857
	end -- 1857
	if projectRoot and projectRoot ~= "" then -- 1858
		addFallback(Path(projectRoot, "Script")) -- 1859
		addFallback(projectRoot) -- 1860
	end -- 1858
	if projFile then -- 1861
		local projDir = getProjectDirFromFile(projFile) -- 1862
		if projDir then -- 1862
			addFallback(Path(projDir, "Script")) -- 1863
			addFallback(projDir) -- 1864
		else -- 1866
			addFallback(Path:getPath(projFile)) -- 1866
		end -- 1862
	end -- 1861
	if not (#fallbackPaths > 0) then -- 1867
		return fn() -- 1867
	end -- 1867
	local searchPaths = Content.searchPaths -- 1868
	for _index_0 = 1, #fallbackPaths do -- 1869
		local dir = fallbackPaths[_index_0] -- 1869
		Content:addSearchPath(dir) -- 1869
	end -- 1869
	local _ <close> = setmetatable({ }, { -- 1870
		__close = function() -- 1870
			Content.searchPaths = searchPaths -- 1870
		end -- 1870
	}) -- 1870
	return fn() -- 1871
end -- 1855
HttpServer:post("/exist", function(req) -- 1872
	do -- 1873
		local _type_0 = type(req) -- 1873
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1873
		if _tab_0 then -- 1873
			local file -- 1873
			do -- 1873
				local _obj_0 = req.body -- 1873
				local _type_1 = type(_obj_0) -- 1873
				if "table" == _type_1 or "userdata" == _type_1 then -- 1873
					file = _obj_0.file -- 1873
				end -- 1873
			end -- 1873
			if file ~= nil then -- 1873
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1874
					return { -- 1875
						success = Content:exist(file) -- 1875
					} -- 1875
				end) -- 1874
			end -- 1873
		end -- 1873
	end -- 1873
	return { -- 1872
		success = false -- 1872
	} -- 1872
end) -- 1872
HttpServer:postSchedule("/read", function(req) -- 1876
	do -- 1877
		local _type_0 = type(req) -- 1877
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1877
		if _tab_0 then -- 1877
			local path -- 1877
			do -- 1877
				local _obj_0 = req.body -- 1877
				local _type_1 = type(_obj_0) -- 1877
				if "table" == _type_1 or "userdata" == _type_1 then -- 1877
					path = _obj_0.path -- 1877
				end -- 1877
			end -- 1877
			if path ~= nil then -- 1877
				local readFile -- 1878
				readFile = function() -- 1878
					if Content:exist(path) and not Content:isdir(path) then -- 1879
						local content = Content:loadAsync(path) -- 1880
						if content then -- 1880
							return { -- 1881
								content = content, -- 1881
								success = true, -- 1881
								fullPath = Content:getFullPath(path) -- 1881
							} -- 1881
						end -- 1880
					end -- 1879
					return nil -- 1878
				end -- 1878
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1882
				if result then -- 1882
					return result -- 1882
				end -- 1882
			end -- 1877
		end -- 1877
	end -- 1877
	return { -- 1876
		success = false -- 1876
	} -- 1876
end) -- 1876
local agentDocLanguage -- 1884
agentDocLanguage = function(language) -- 1884
	if language == "zh-Hans" then -- 1885
		return "zh" -- 1885
	else -- 1885
		return "en" -- 1885
	end -- 1885
end -- 1884
HttpServer:postSchedule("/doc/search", function(req) -- 1887
	local body = req.body or { } -- 1888
	local language = body.docLanguage -- 1889
	if not (("en" == language or "zh-Hans" == language)) then -- 1890
		return { -- 1890
			success = false, -- 1890
			message = "unsupported doc language" -- 1890
		} -- 1890
	end -- 1890
	local docType = body.docType -- 1891
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1892
		return { -- 1892
			success = false, -- 1892
			message = "unsupported doc type" -- 1892
		} -- 1892
	end -- 1892
	local codeLanguage = body.programmingLanguage -- 1893
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1894
		return { -- 1894
			success = false, -- 1894
			message = "unsupported programming language" -- 1894
		} -- 1894
	end -- 1894
	if not body.pattern then -- 1895
		return { -- 1895
			success = false, -- 1895
			message = "missing pattern" -- 1895
		} -- 1895
	end -- 1895
	local result = nil -- 1896
	AgentTools.searchDoraDocHttp({ -- 1898
		pattern = body.pattern, -- 1898
		docLanguage = agentDocLanguage(language), -- 1899
		docType = docType, -- 1900
		programmingLanguage = codeLanguage, -- 1901
		limit = body.limit, -- 1902
		useRegex = body.useRegex, -- 1903
		caseSensitive = body.caseSensitive, -- 1904
		includeContent = body.includeContent, -- 1905
		contentWindow = body.contentWindow -- 1906
	}, function(res) -- 1907
		result = res -- 1908
	end) -- 1897
	wait(function() -- 1909
		return result ~= nil -- 1909
	end) -- 1909
	if result and result.success then -- 1910
		result.docLanguage = language -- 1911
	end -- 1910
	if result then -- 1912
		return result -- 1913
	else -- 1915
		return { -- 1915
			success = false, -- 1915
			message = "doc search failed" -- 1915
		} -- 1915
	end -- 1912
	return { -- 1887
		success = false, -- 1887
		message = "invalid call" -- 1887
	} -- 1887
end) -- 1887
HttpServer:postSchedule("/doc/read", function(req) -- 1917
	local body = req.body or { } -- 1918
	local language = body.docLanguage -- 1919
	if not (("en" == language or "zh-Hans" == language)) then -- 1920
		return { -- 1920
			success = false, -- 1920
			message = "unsupported doc language" -- 1920
		} -- 1920
	end -- 1920
	if not body.file then -- 1921
		return { -- 1921
			success = false, -- 1921
			message = "missing file" -- 1921
		} -- 1921
	end -- 1921
	local result = AgentTools.readDoraDoc({ -- 1923
		docLanguage = agentDocLanguage(language), -- 1923
		file = body.file, -- 1924
		startLine = body.startLine, -- 1925
		endLine = body.endLine -- 1926
	}) -- 1922
	if result and result.success then -- 1927
		result.docLanguage = language -- 1928
	end -- 1927
	return result -- 1929
end) -- 1917
HttpServer:get("/read-sync", function(req) -- 1931
	do -- 1932
		local _type_0 = type(req) -- 1932
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1932
		if _tab_0 then -- 1932
			local params = req.params -- 1932
			if params ~= nil then -- 1932
				local path = params.path -- 1933
				if not (type(path) == "string" and path ~= "") then -- 1934
					return { -- 1934
						success = false, -- 1934
						message = "invalid path" -- 1934
					} -- 1934
				end -- 1934
				local exts -- 1935
				if params.exts then -- 1935
					local _accum_0 = { } -- 1936
					local _len_0 = 1 -- 1936
					for ext in params.exts:gmatch("[^|]*") do -- 1936
						_accum_0[_len_0] = ext -- 1936
						_len_0 = _len_0 + 1 -- 1936
					end -- 1936
					exts = _accum_0 -- 1936
				else -- 1937
					exts = { -- 1937
						"" -- 1937
					} -- 1937
				end -- 1935
				local readFileAt -- 1938
				readFileAt = function(targetPath) -- 1938
					if Content:exist(targetPath) then -- 1939
						local content = Content:load(targetPath) -- 1940
						if content then -- 1940
							return { -- 1941
								content = content, -- 1941
								success = true, -- 1941
								fullPath = Content:getFullPath(targetPath) -- 1941
							} -- 1941
						end -- 1940
					end -- 1939
					return nil -- 1938
				end -- 1938
				local readFile -- 1942
				readFile = function(fallbackPaths) -- 1942
					for _index_0 = 1, #exts do -- 1943
						local ext = exts[_index_0] -- 1943
						local targetPath = path .. ext -- 1944
						if not Content:isAbsolutePath(targetPath) then -- 1945
							for _index_1 = 1, #fallbackPaths do -- 1946
								local fallback = fallbackPaths[_index_1] -- 1946
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1947
								if fallbackResult then -- 1947
									return fallbackResult -- 1948
								end -- 1947
							end -- 1946
						end -- 1945
						local fileResult = readFileAt(targetPath) -- 1949
						if fileResult then -- 1949
							return fileResult -- 1950
						end -- 1949
					end -- 1943
					return nil -- 1942
				end -- 1942
				local fallbackPaths = { } -- 1951
				local fallbackCandidates = { } -- 1952
				do -- 1953
					local projectRoot = req.params.projectRoot -- 1953
					if projectRoot then -- 1953
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1954
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1955
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1956
						end -- 1954
					end -- 1953
				end -- 1953
				do -- 1957
					local projFile = req.params.projFile -- 1957
					if projFile then -- 1957
						local projDir = getProjectDirFromFile(projFile) -- 1958
						if projDir then -- 1958
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1959
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1960
						else -- 1962
							projDir = Path:getPath(projFile) -- 1962
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1963
						end -- 1958
					end -- 1957
				end -- 1957
				for _index_0 = 1, #fallbackCandidates do -- 1964
					local dir = fallbackCandidates[_index_0] -- 1964
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1965
						local exists = false -- 1966
						for _index_1 = 1, #fallbackPaths do -- 1967
							local fallback = fallbackPaths[_index_1] -- 1967
							if fallback == dir then -- 1968
								exists = true -- 1969
								break -- 1970
							end -- 1968
						end -- 1967
						if not exists then -- 1971
							fallbackPaths[#fallbackPaths + 1] = dir -- 1971
						end -- 1971
					end -- 1965
				end -- 1964
				local readResult = readFile(fallbackPaths) -- 1972
				if readResult then -- 1972
					return readResult -- 1973
				end -- 1972
			end -- 1932
		end -- 1932
	end -- 1932
	return { -- 1931
		success = false -- 1931
	} -- 1931
end) -- 1931
local addGeneratedSourceHeader -- 1975
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 1975
	if preserveTIC80 == nil then -- 1975
		preserveTIC80 = false -- 1975
	end -- 1975
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 1976
	if preserveTIC80 then -- 1977
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 1978
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 1979
		end -- 1978
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 1980
	end -- 1977
	return tostring(header) .. "\n" .. tostring(codes) -- 1981
end -- 1975
local compileFileAsync -- 1983
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1983
	if projectRoot == nil then -- 1983
		projectRoot = nil -- 1983
	end -- 1983
	local file = inputFile -- 1984
	local searchPath -- 1985
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1985
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1986
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1990
	elseif not Content:isAbsolutePath(inputFile) then -- 1991
		searchPath = "" -- 1992
	else -- 1993
		local dir = getProjectDirFromFile(inputFile) -- 1993
		if dir then -- 1993
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1994
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1998
		else -- 2000
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2000
			searchPath = "" -- 2003
		end -- 1993
	end -- 1985
	local outputFile = Path:replaceExt(inputFile, "lua") -- 2004
	local yueext = yue.options.extension -- 2005
	local resultCodes = nil -- 2006
	local resultError = nil -- 2007
	do -- 2008
		local _exp_0 = Path:getExt(inputFile) -- 2008
		if yueext == _exp_0 then -- 2008
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 2009
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 2010
				if not codes then -- 2011
					resultError = err -- 2012
					return -- 2013
				end -- 2011
				local extraGlobal -- 2014
				if isTIC80 then -- 2014
					extraGlobal = tic80APIs -- 2014
				else -- 2014
					extraGlobal = nil -- 2014
				end -- 2014
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 2015
				if not success then -- 2016
					resultError = message -- 2017
					return -- 2018
				end -- 2016
				if codes == "" then -- 2019
					resultCodes = "" -- 2020
					return nil -- 2021
				end -- 2019
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 2022
				return resultCodes -- 2023
			end, function(success) -- 2010
				if not success then -- 2024
					Content:remove(outputFile) -- 2025
					if resultCodes == nil then -- 2026
						resultCodes = false -- 2027
					end -- 2026
				end -- 2024
			end) -- 2010
		elseif "tl" == _exp_0 then -- 2028
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 2029
			if isTIC80 then -- 2030
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2031
			end -- 2030
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2032
			if codes then -- 2032
				if isTIC80 then -- 2033
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2034
				end -- 2033
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2035
				Content:saveAsync(outputFile, resultCodes) -- 2036
			else -- 2038
				Content:remove(outputFile) -- 2038
				resultCodes = false -- 2039
				resultError = err -- 2040
			end -- 2032
		elseif "xml" == _exp_0 then -- 2041
			local codes, err = xml.tolua(sourceCodes) -- 2042
			if codes then -- 2042
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2043
				Content:saveAsync(outputFile, resultCodes) -- 2044
			else -- 2046
				Content:remove(outputFile) -- 2046
				resultCodes = false -- 2047
				resultError = err -- 2048
			end -- 2042
		end -- 2008
	end -- 2008
	wait(function() -- 2049
		return resultCodes ~= nil -- 2049
	end) -- 2049
	if resultCodes then -- 2050
		return resultCodes -- 2051
	else -- 2053
		return nil, resultError -- 2053
	end -- 2050
	return nil -- 1983
end -- 1983
HttpServer:postSchedule("/write", function(req) -- 2055
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2056
	local buildSucceeded = false -- 2057
	local _ <close> = setmetatable({ }, { -- 2058
		__close = function() -- 2058
			return finishUpdate(buildSucceeded) -- 2058
		end -- 2058
	}) -- 2058
	do -- 2059
		local _type_0 = type(req) -- 2059
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2059
		if _tab_0 then -- 2059
			local path -- 2059
			do -- 2059
				local _obj_0 = req.body -- 2059
				local _type_1 = type(_obj_0) -- 2059
				if "table" == _type_1 or "userdata" == _type_1 then -- 2059
					path = _obj_0.path -- 2059
				end -- 2059
			end -- 2059
			local content -- 2059
			do -- 2059
				local _obj_0 = req.body -- 2059
				local _type_1 = type(_obj_0) -- 2059
				if "table" == _type_1 or "userdata" == _type_1 then -- 2059
					content = _obj_0.content -- 2059
				end -- 2059
			end -- 2059
			if path ~= nil and content ~= nil then -- 2059
				if Content:saveAsync(path, content) then -- 2060
					do -- 2061
						local _exp_0 = Path:getExt(path) -- 2061
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2061
							if '' == Path:getExt(Path:getName(path)) then -- 2062
								local resultCodes = compileFileAsync(path, content) -- 2063
								buildSucceeded = resultCodes ~= nil -- 2064
								return { -- 2065
									success = true, -- 2065
									resultCodes = resultCodes -- 2065
								} -- 2065
							end -- 2062
						end -- 2061
					end -- 2061
					buildSucceeded = true -- 2066
					return { -- 2067
						success = true -- 2067
					} -- 2067
				end -- 2060
			end -- 2059
		end -- 2059
	end -- 2059
	return { -- 2055
		success = false -- 2055
	} -- 2055
end) -- 2055
local getWaProjectDirFromFile = nil -- 2069
HttpServer:postSchedule("/build", function(req) -- 2071
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2072
	local buildSucceeded = false -- 2073
	local _ <close> = setmetatable({ }, { -- 2074
		__close = function() -- 2074
			return finishUpdate(buildSucceeded) -- 2074
		end -- 2074
	}) -- 2074
	do -- 2075
		local _type_0 = type(req) -- 2075
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2075
		if _tab_0 then -- 2075
			local path -- 2075
			do -- 2075
				local _obj_0 = req.body -- 2075
				local _type_1 = type(_obj_0) -- 2075
				if "table" == _type_1 or "userdata" == _type_1 then -- 2075
					path = _obj_0.path -- 2075
				end -- 2075
			end -- 2075
			if path ~= nil then -- 2075
				local projectRoot = req.body.projectRoot -- 2076
				if Content:isdir(path) then -- 2077
					local projDir = getWaProjectDirFromFile(path) -- 2078
					if projDir then -- 2078
						local message = Wasm:buildWaAsync(projDir) -- 2079
						if message == "" then -- 2080
							return { -- 2081
								success = true -- 2081
							} -- 2081
						else -- 2083
							return { -- 2083
								success = false, -- 2083
								message = message -- 2083
							} -- 2083
						end -- 2080
					end -- 2078
				end -- 2077
				local _exp_0 = Path:getExt(path) -- 2084
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2085
					if '' == Path:getExt(Path:getName(path)) then -- 2086
						local content = Content:loadAsync(path) -- 2087
						if content then -- 2087
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2088
							if resultCodes then -- 2088
								buildSucceeded = true -- 2089
								return { -- 2090
									success = true, -- 2090
									resultCodes = resultCodes -- 2090
								} -- 2090
							end -- 2088
						end -- 2087
					end -- 2086
				elseif "wa" == _exp_0 then -- 2091
					local projDir = getWaProjectDirFromFile(path) -- 2092
					if projDir then -- 2092
						local message = Wasm:buildWaAsync(projDir) -- 2093
						if message == "" then -- 2094
							return { -- 2095
								success = true -- 2095
							} -- 2095
						else -- 2097
							return { -- 2097
								success = false, -- 2097
								message = message -- 2097
							} -- 2097
						end -- 2094
					else -- 2099
						return { -- 2099
							success = false, -- 2099
							message = 'Wa file needs a project' -- 2099
						} -- 2099
					end -- 2092
				end -- 2084
			end -- 2075
		end -- 2075
	end -- 2075
	return { -- 2071
		success = false -- 2071
	} -- 2071
end) -- 2071
local extentionLevels = { -- 2102
	vs = 2, -- 2102
	bl = 2, -- 2103
	ts = 1, -- 2104
	tsx = 1, -- 2105
	tl = 1, -- 2106
	yue = 1, -- 2107
	xml = 1, -- 2108
	lua = 0 -- 2109
} -- 2101
local visitAssets -- 2111
visitAssets = function(path, workspace, builtin, recursive) -- 2111
	if recursive == nil then -- 2111
		recursive = true -- 2111
	end -- 2111
	local children = nil -- 2112
	local dirs = Content:getDirs(path) -- 2113
	for _index_0 = 1, #dirs do -- 2114
		local dir = dirs[_index_0] -- 2114
		if workspace then -- 2115
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 2116
				goto _continue_0 -- 2117
			end -- 2116
		elseif dir == ".git" then -- 2118
			goto _continue_0 -- 2119
		end -- 2115
		if not children then -- 2120
			children = { } -- 2120
		end -- 2120
		local dirPath = Path(path, dir) -- 2121
		if recursive then -- 2122
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2123
		else -- 2125
			children[#children + 1] = { -- 2126
				key = dirPath, -- 2126
				dir = true, -- 2127
				title = dir, -- 2128
				builtin = builtin, -- 2129
				isLeaf = false -- 2130
			} -- 2125
		end -- 2122
		::_continue_0:: -- 2115
	end -- 2114
	local files = Content:getFiles(path) -- 2132
	local names = { } -- 2133
	for _index_0 = 1, #files do -- 2134
		local file = files[_index_0] -- 2134
		if (".DS_Store" == file) then -- 2135
			goto _continue_1 -- 2136
		end -- 2135
		local name = Path:getName(file) -- 2137
		local ext = names[name] -- 2138
		if ext then -- 2138
			local lv1 -- 2139
			do -- 2139
				local _exp_0 = extentionLevels[ext] -- 2139
				if _exp_0 ~= nil then -- 2139
					lv1 = _exp_0 -- 2139
				else -- 2139
					lv1 = -1 -- 2139
				end -- 2139
			end -- 2139
			ext = Path:getExt(file) -- 2140
			local lv2 -- 2141
			do -- 2141
				local _exp_0 = extentionLevels[ext] -- 2141
				if _exp_0 ~= nil then -- 2141
					lv2 = _exp_0 -- 2141
				else -- 2141
					lv2 = -1 -- 2141
				end -- 2141
			end -- 2141
			if lv2 > lv1 then -- 2142
				names[name] = ext -- 2143
			elseif lv2 == lv1 then -- 2144
				names[name .. '.' .. ext] = "" -- 2145
			end -- 2142
		else -- 2147
			ext = Path:getExt(file) -- 2147
			if not extentionLevels[ext] then -- 2148
				names[file] = "" -- 2149
			else -- 2151
				names[name] = ext -- 2151
			end -- 2148
		end -- 2138
		::_continue_1:: -- 2135
	end -- 2134
	do -- 2152
		local _accum_0 = { } -- 2152
		local _len_0 = 1 -- 2152
		for name, ext in pairs(names) do -- 2152
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2152
			_len_0 = _len_0 + 1 -- 2152
		end -- 2152
		files = _accum_0 -- 2152
	end -- 2152
	for _index_0 = 1, #files do -- 2153
		local file = files[_index_0] -- 2153
		if not children then -- 2154
			children = { } -- 2154
		end -- 2154
		children[#children + 1] = { -- 2156
			key = Path(path, file), -- 2156
			dir = false, -- 2157
			title = file, -- 2158
			builtin = builtin -- 2159
		} -- 2155
	end -- 2153
	if children then -- 2161
		table.sort(children, function(a, b) -- 2162
			if a.dir == b.dir then -- 2163
				return a.title < b.title -- 2164
			else -- 2166
				return a.dir -- 2166
			end -- 2163
		end) -- 2162
	end -- 2161
	return { -- 2168
		key = path, -- 2168
		dir = true, -- 2169
		title = Path:getFilename(path), -- 2170
		builtin = builtin, -- 2171
		isLeaf = not children, -- 2172
		children = children -- 2173
	} -- 2167
end -- 2111
HttpServer:post("/assets/children", function(req) -- 2176
	do -- 2177
		local _type_0 = type(req) -- 2177
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2177
		if _tab_0 then -- 2177
			local path -- 2177
			do -- 2177
				local _obj_0 = req.body -- 2177
				local _type_1 = type(_obj_0) -- 2177
				if "table" == _type_1 or "userdata" == _type_1 then -- 2177
					path = _obj_0.path -- 2177
				end -- 2177
			end -- 2177
			if path ~= nil then -- 2177
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2178
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2179
					return { -- 2179
						success = false -- 2179
					} -- 2179
				end -- 2179
				local node = visitAssets(path, workspace, builtin, false) -- 2180
				return { -- 2181
					success = true, -- 2181
					children = node.children or { } -- 2181
				} -- 2181
			end -- 2177
		end -- 2177
	end -- 2177
	return { -- 2176
		success = false -- 2176
	} -- 2176
end) -- 2176
HttpServer:post("/assets/files", function(req) -- 2183
	do -- 2184
		local _type_0 = type(req) -- 2184
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2184
		if _tab_0 then -- 2184
			local path -- 2184
			do -- 2184
				local _obj_0 = req.body -- 2184
				local _type_1 = type(_obj_0) -- 2184
				if "table" == _type_1 or "userdata" == _type_1 then -- 2184
					path = _obj_0.path -- 2184
				end -- 2184
			end -- 2184
			if path ~= nil then -- 2184
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2185
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2186
				if not (workspace or builtin) then -- 2187
					return { -- 2187
						success = false -- 2187
					} -- 2187
				end -- 2187
				if not (Content:exist(path) and Content:isdir(path)) then -- 2188
					return { -- 2188
						success = false -- 2188
					} -- 2188
				end -- 2188
				local globs = { -- 2189
					"**", -- 2189
					"!**/.DS_Store" -- 2189
				} -- 2189
				if workspace then -- 2190
					globs = { -- 2192
						"**", -- 2192
						"!**/.DS_Store", -- 2192
						"!**/.upload/**", -- 2193
						"!**/.download/**", -- 2193
						"!**/.www/**", -- 2194
						"!**/.build/**", -- 2194
						"!**/.git/**", -- 2195
						"!**/.cache/**", -- 2195
						"!**/node_modules/**" -- 2196
					} -- 2191
				end -- 2190
				local files -- 2198
				do -- 2198
					local _accum_0 = { } -- 2198
					local _len_0 = 1 -- 2198
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2198
					for _index_0 = 1, #_list_0 do -- 2198
						local file = _list_0[_index_0] -- 2198
						_accum_0[_len_0] = Path(path, file) -- 2198
						_len_0 = _len_0 + 1 -- 2198
					end -- 2198
					files = _accum_0 -- 2198
				end -- 2198
				return { -- 2199
					success = true, -- 2199
					files = files -- 2199
				} -- 2199
			end -- 2184
		end -- 2184
	end -- 2184
	return { -- 2183
		success = false -- 2183
	} -- 2183
end) -- 2183
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2240
	local _tab_0 = { -- 2240
		{ -- 2241
			key = Path(Content.assetPath), -- 2241
			dir = true, -- 2242
			builtin = true, -- 2243
			title = zh and "内置资源" or "Built-in", -- 2244
			children = builtinChildren -- 2245
		} -- 2240
	} -- 2247
	local _obj_0 = workspace.children or { } -- 2247
	local _idx_0 = #_tab_0 + 1 -- 2247
	for _index_0 = 1, #_obj_0 do -- 2247
		local _value_0 = _obj_0[_index_0] -- 2247
		_tab_0[_idx_0] = _value_0 -- 2247
		_idx_0 = _idx_0 + 1 -- 2247
	end -- 2247
	return _tab_0 -- 2240
end -- 2240
HttpServer:post("/assets", function() -- 2201
	local Entry = require("Script.Dev.Entry") -- 2202
	local engineDev = Entry.getEngineDev() -- 2203
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2204
	local zh = (App.locale:match("^zh") ~= nil) -- 2205
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2206
	readme.title = zh and "说明文档" or "Readme" -- 2207
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2208
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2209
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2210
	tools.title = zh and "开发工具" or "Tools" -- 2211
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2212
	font.title = zh and "字体" or "Font" -- 2213
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2214
	lib.title = zh and "程序库" or "Lib" -- 2215
	if engineDev then -- 2216
		local _list_0 = lib.children -- 2217
		for _index_0 = 1, #_list_0 do -- 2217
			local child = _list_0[_index_0] -- 2217
			if not (child.title == "Dora") then -- 2218
				goto _continue_0 -- 2218
			end -- 2218
			local title = zh and "zh-Hans" or "en" -- 2219
			do -- 2220
				local _accum_0 = { } -- 2220
				local _len_0 = 1 -- 2220
				local _list_1 = child.children -- 2220
				for _index_1 = 1, #_list_1 do -- 2220
					local c = _list_1[_index_1] -- 2220
					if c.title ~= title then -- 2220
						_accum_0[_len_0] = c -- 2220
						_len_0 = _len_0 + 1 -- 2220
					end -- 2220
				end -- 2220
				child.children = _accum_0 -- 2220
			end -- 2220
			break -- 2221
			::_continue_0:: -- 2218
		end -- 2217
	else -- 2223
		local _accum_0 = { } -- 2223
		local _len_0 = 1 -- 2223
		local _list_0 = lib.children -- 2223
		for _index_0 = 1, #_list_0 do -- 2223
			local child = _list_0[_index_0] -- 2223
			if child.title ~= "Dora" then -- 2223
				_accum_0[_len_0] = child -- 2223
				_len_0 = _len_0 + 1 -- 2223
			end -- 2223
		end -- 2223
		lib.children = _accum_0 -- 2223
	end -- 2216
	local builtinChildren = { -- 2224
		readme, -- 2224
		apiDoc, -- 2224
		tools, -- 2224
		font, -- 2224
		lib -- 2224
	} -- 2224
	if engineDev then -- 2225
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2226
		do -- 2227
			local _obj_0 = dev.children -- 2227
			_obj_0[#_obj_0 + 1] = { -- 2228
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2228
				dir = false, -- 2229
				builtin = true, -- 2230
				title = "init.yue" -- 2231
			} -- 2227
		end -- 2227
		builtinChildren[#builtinChildren + 1] = dev -- 2233
	end -- 2225
	return { -- 2235
		key = Content.writablePath, -- 2235
		dir = true, -- 2236
		root = true, -- 2237
		title = "Assets", -- 2238
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2239
	} -- 2234
end) -- 2201
HttpServer:post("/entry/list", function(req) -- 2251
	local Entry = require("Script.Dev.Entry") -- 2252
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2253
	res.success = true -- 2254
	return res -- 2255
end) -- 2251
HttpServer:post("/run/status", function() -- 2257
	local Entry = require("Script.Dev.Entry") -- 2258
	return Entry.getCurrentEntryStatus() -- 2259
end) -- 2257
HttpServer:postSchedule("/run", function(req) -- 2261
	do -- 2262
		local _type_0 = type(req) -- 2262
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2262
		if _tab_0 then -- 2262
			local file -- 2262
			do -- 2262
				local _obj_0 = req.body -- 2262
				local _type_1 = type(_obj_0) -- 2262
				if "table" == _type_1 or "userdata" == _type_1 then -- 2262
					file = _obj_0.file -- 2262
				end -- 2262
			end -- 2262
			local asProj -- 2262
			do -- 2262
				local _obj_0 = req.body -- 2262
				local _type_1 = type(_obj_0) -- 2262
				if "table" == _type_1 or "userdata" == _type_1 then -- 2262
					asProj = _obj_0.asProj -- 2262
				end -- 2262
			end -- 2262
			if file ~= nil and asProj ~= nil then -- 2262
				if not Content:isAbsolutePath(file) then -- 2263
					local devFile = Path(Content.writablePath, file) -- 2264
					if Content:exist(devFile) then -- 2265
						file = devFile -- 2265
					end -- 2265
				end -- 2263
				local Entry = require("Script.Dev.Entry") -- 2266
				local workDir -- 2267
				if asProj then -- 2268
					local projectRoot = req.body.projectRoot -- 2269
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2270
						workDir = projectRoot -- 2271
					else -- 2273
						workDir = getProjectDirFromFile(file) -- 2273
					end -- 2270
					if workDir then -- 2274
						Entry.allClear() -- 2275
						local target = Path(workDir, "init") -- 2276
						local success, err = Entry.enterEntryAsync({ -- 2277
							entryName = "Project", -- 2277
							fileName = target, -- 2277
							workDir = workDir, -- 2277
							projectRoot = workDir, -- 2277
							runKind = "project" -- 2277
						}) -- 2277
						target = Path:getName(Path:getPath(target)) -- 2278
						return { -- 2279
							success = success, -- 2279
							target = target, -- 2279
							err = err -- 2279
						} -- 2279
					end -- 2274
				else -- 2281
					workDir = getProjectDirFromFile(file) -- 2281
					if not workDir and Path:getExt(file) == "wasm" then -- 2282
						local parent = Path:getPath(file) -- 2283
						if Content:exist(Path(parent, "wa.mod")) then -- 2284
							workDir = parent -- 2285
						end -- 2284
					end -- 2282
				end -- 2268
				Entry.allClear() -- 2286
				file = Path:replaceExt(file, "") -- 2287
				local entry = { -- 2289
					entryName = Path:getName(file), -- 2289
					fileName = file, -- 2290
					runKind = "file" -- 2291
				} -- 2288
				if workDir then -- 2292
					entry.workDir = workDir -- 2293
					entry.projectRoot = workDir -- 2294
				end -- 2292
				local success, err = Entry.enterEntryAsync(entry) -- 2295
				return { -- 2296
					success = success, -- 2296
					err = err -- 2296
				} -- 2296
			end -- 2262
		end -- 2262
	end -- 2262
	return { -- 2261
		success = false -- 2261
	} -- 2261
end) -- 2261
local _anon_func_7 = function(result) -- 2338
	if result.success then -- 2338
		return nil -- 2338
	else -- 2338
		return "PREVIEW_FAILED" -- 2338
	end -- 2338
end -- 2338
HttpServer:postSchedule("/agent/preview", function(req) -- 2298
	local releaseAgent = AgentHost.acquire() -- 2299
	local _ <close> = setmetatable({ }, { -- 2300
		__close = function() -- 2300
			return releaseAgent() -- 2300
		end -- 2300
	}) -- 2300
	do -- 2301
		local _type_0 = type(req) -- 2301
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2301
		if _tab_0 then -- 2301
			local projectRoot -- 2301
			do -- 2301
				local _obj_0 = req.body -- 2301
				local _type_1 = type(_obj_0) -- 2301
				if "table" == _type_1 or "userdata" == _type_1 then -- 2301
					projectRoot = _obj_0.projectRoot -- 2301
				end -- 2301
			end -- 2301
			if projectRoot ~= nil then -- 2301
				if not getProjectSourceRoot(projectRoot) then -- 2302
					return { -- 2302
						success = false, -- 2302
						code = "INVALID_PROJECT", -- 2302
						message = "projectRoot must be an existing absolute directory" -- 2302
					} -- 2302
				end -- 2302
				local entryFile = req.body.entry or "init.lua" -- 2303
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2304
					return { -- 2304
						success = false, -- 2304
						code = "INVALID_ENTRY", -- 2304
						message = "entry must be a non-empty project-relative path" -- 2304
					} -- 2304
				end -- 2304
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2305
					0.5 -- 2305
				} -- 2305
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2306
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2307
					return { -- 2307
						success = false, -- 2307
						code = "INVALID_QUEUE_TIMEOUT", -- 2307
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2307
					} -- 2307
				end -- 2307
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2308
				local AgentOperation = require("Agent.Tool.Operation") -- 2309
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2310
				local requestId = AgentOperation.createOperationId() -- 2311
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2312
				if not enqueued.success then -- 2313
					return { -- 2313
						success = false, -- 2313
						code = "ENTRY_QUEUE_REJECTED", -- 2313
						message = enqueued.message -- 2313
					} -- 2313
				end -- 2313
				local queuedAt = App.runningTime -- 2314
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2315
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2316
						local state = agentEntryRunQueue:get(requestId) -- 2317
						agentEntryRunQueue:cancel(requestId) -- 2318
						return { -- 2320
							success = false, -- 2320
							code = "ENTRY_QUEUE_TIMEOUT", -- 2321
							message = "timed out waiting for the Dora entry runtime", -- 2322
							requestId = requestId, -- 2323
							queuePosition = state.position -- 2324
						} -- 2319
					end -- 2316
					sleep() -- 2325
				end -- 2315
				local queueWaitSeconds = App.runningTime - queuedAt -- 2326
				local _ <close> = setmetatable({ }, { -- 2327
					__close = function() -- 2327
						return agentEntryRunQueue:release(requestId) -- 2327
					end -- 2327
				}) -- 2327
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2328
				local Entry = require("Script.Dev.Entry") -- 2329
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2331
					workDir = projectRoot, -- 2331
					operationId = requestId, -- 2332
					print = function() end -- 2333
				}, Entry) -- 2330
				local result = preview({ -- 2335
					entry = entryFile, -- 2335
					captureAtSeconds = captureAtSeconds -- 2335
				}) -- 2335
				return { -- 2337
					success = result.success, -- 2337
					code = _anon_func_7(result), -- 2338
					message = result.message, -- 2339
					requestId = requestId, -- 2340
					queueWaitSeconds = queueWaitSeconds, -- 2341
					interruptedUserRun = result.interruptedUserRun, -- 2342
					files = result.files, -- 2343
					frames = result.frames -- 2344
				} -- 2336
			end -- 2301
		end -- 2301
	end -- 2301
	return { -- 2298
		success = false, -- 2298
		message = "invalid call" -- 2298
	} -- 2298
end) -- 2298
HttpServer:postSchedule("/agent/command", function(req) -- 2346
	local releaseAgent = AgentHost.acquire() -- 2347
	local _ <close> = setmetatable({ }, { -- 2348
		__close = function() -- 2348
			return releaseAgent() -- 2348
		end -- 2348
	}) -- 2348
	do -- 2349
		local _type_0 = type(req) -- 2349
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2349
		if _tab_0 then -- 2349
			local body = req.body -- 2349
			if body ~= nil then -- 2349
				local projectRoot = body.projectRoot -- 2350
				if not getProjectSourceRoot(projectRoot) then -- 2351
					return { -- 2351
						success = false, -- 2351
						code = "INVALID_PROJECT", -- 2351
						message = "projectRoot must be an existing absolute directory" -- 2351
					} -- 2351
				end -- 2351
				local AgentValidation = require("Agent.Tool.Validation") -- 2352
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2353
				if not validated.success then -- 2354
					return { -- 2354
						success = false, -- 2354
						code = "INVALID_COMMAND", -- 2354
						message = validated.message -- 2354
					} -- 2354
				end -- 2354
				local input = validated.value -- 2355
				local AgentCommand = require("Agent.Tool.Command") -- 2356
				local result = nil -- 2357
				local failure = nil -- 2358
				local promise = AgentCommand.executeCommand({ -- 2360
					workDir = projectRoot, -- 2360
					mode = input.mode, -- 2361
					code = input.code, -- 2362
					command = input.command, -- 2363
					cwd = input.cwd, -- 2364
					timeoutSeconds = input.timeoutSeconds -- 2365
				}) -- 2359
				promise:addCallbacks((function(_, value) -- 2366
					result = value -- 2366
				end), (function(_, err) -- 2366
					failure = tostring(err) -- 2366
				end)) -- 2366
				wait(function() -- 2367
					return result ~= nil or failure ~= nil -- 2367
				end) -- 2367
				if failure then -- 2368
					return { -- 2368
						success = false, -- 2368
						code = "COMMAND_BRIDGE_FAILED", -- 2368
						message = failure -- 2368
					} -- 2368
				end -- 2368
				if not result.success then -- 2369
					result.code = "COMMAND_FAILED" -- 2370
				end -- 2369
				return result -- 2371
			end -- 2349
		end -- 2349
	end -- 2349
	return { -- 2346
		success = false, -- 2346
		code = "INVALID_COMMAND", -- 2346
		message = "invalid call" -- 2346
	} -- 2346
end) -- 2346
HttpServer:postSchedule("/stop", function() -- 2373
	local Entry = require("Script.Dev.Entry") -- 2374
	return { -- 2375
		success = Entry.stop() -- 2375
	} -- 2375
end) -- 2373
local minifyAsync -- 2377
minifyAsync = function(sourcePath, minifyPath) -- 2377
	if not Content:exist(sourcePath) then -- 2378
		return -- 2378
	end -- 2378
	local Entry = require("Script.Dev.Entry") -- 2379
	local errors = { } -- 2380
	local files = Entry.getAllFiles(sourcePath, { -- 2381
		"lua" -- 2381
	}, true) -- 2381
	do -- 2382
		local _accum_0 = { } -- 2382
		local _len_0 = 1 -- 2382
		for _index_0 = 1, #files do -- 2382
			local file = files[_index_0] -- 2382
			if file:sub(1, 1) ~= '.' then -- 2382
				_accum_0[_len_0] = file -- 2382
				_len_0 = _len_0 + 1 -- 2382
			end -- 2382
		end -- 2382
		files = _accum_0 -- 2382
	end -- 2382
	local paths -- 2383
	do -- 2383
		local _tbl_0 = { } -- 2383
		for _index_0 = 1, #files do -- 2383
			local file = files[_index_0] -- 2383
			_tbl_0[Path:getPath(file)] = true -- 2383
		end -- 2383
		paths = _tbl_0 -- 2383
	end -- 2383
	for path in pairs(paths) do -- 2384
		Content:mkdir(Path(minifyPath, path)) -- 2384
	end -- 2384
	local _ <close> = setmetatable({ }, { -- 2385
		__close = function() -- 2385
			package.loaded["luaminify.FormatMini"] = nil -- 2386
			package.loaded["luaminify.ParseLua"] = nil -- 2387
			package.loaded["luaminify.Scope"] = nil -- 2388
			package.loaded["luaminify.Util"] = nil -- 2389
		end -- 2385
	}) -- 2385
	local FormatMini -- 2390
	do -- 2390
		local _obj_0 = require("luaminify") -- 2390
		FormatMini = _obj_0.FormatMini -- 2390
	end -- 2390
	local fileCount = #files -- 2391
	local count = 0 -- 2392
	for _index_0 = 1, #files do -- 2393
		local file = files[_index_0] -- 2393
		thread(function() -- 2394
			local _ <close> = setmetatable({ }, { -- 2395
				__close = function() -- 2395
					count = count + 1 -- 2395
				end -- 2395
			}) -- 2395
			local input = Path(sourcePath, file) -- 2396
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2397
			if Content:exist(input) then -- 2398
				local sourceCodes = Content:loadAsync(input) -- 2399
				local res, err = FormatMini(sourceCodes) -- 2400
				if res then -- 2401
					Content:saveAsync(output, res) -- 2402
					return print("Minify " .. tostring(file)) -- 2403
				else -- 2405
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2405
				end -- 2401
			else -- 2407
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2407
			end -- 2398
		end) -- 2394
		sleep() -- 2408
	end -- 2393
	wait(function() -- 2409
		return count == fileCount -- 2409
	end) -- 2409
	if #errors > 0 then -- 2410
		print(table.concat(errors, '\n')) -- 2411
	end -- 2410
	print("Obfuscation done.") -- 2412
	return files -- 2413
end -- 2377
local zipping = false -- 2415
HttpServer:postSchedule("/zip", function(req) -- 2417
	do -- 2418
		local _type_0 = type(req) -- 2418
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2418
		if _tab_0 then -- 2418
			local path -- 2418
			do -- 2418
				local _obj_0 = req.body -- 2418
				local _type_1 = type(_obj_0) -- 2418
				if "table" == _type_1 or "userdata" == _type_1 then -- 2418
					path = _obj_0.path -- 2418
				end -- 2418
			end -- 2418
			local zipFile -- 2418
			do -- 2418
				local _obj_0 = req.body -- 2418
				local _type_1 = type(_obj_0) -- 2418
				if "table" == _type_1 or "userdata" == _type_1 then -- 2418
					zipFile = _obj_0.zipFile -- 2418
				end -- 2418
			end -- 2418
			local obfuscated -- 2418
			do -- 2418
				local _obj_0 = req.body -- 2418
				local _type_1 = type(_obj_0) -- 2418
				if "table" == _type_1 or "userdata" == _type_1 then -- 2418
					obfuscated = _obj_0.obfuscated -- 2418
				end -- 2418
			end -- 2418
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2418
				if zipping then -- 2419
					goto failed -- 2419
				end -- 2419
				zipping = true -- 2420
				local _ <close> = setmetatable({ }, { -- 2421
					__close = function() -- 2421
						zipping = false -- 2421
					end -- 2421
				}) -- 2421
				if not Content:exist(path) then -- 2422
					goto failed -- 2422
				end -- 2422
				Content:mkdir(Path:getPath(zipFile)) -- 2423
				if obfuscated then -- 2424
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2425
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2426
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2427
					Content:remove(scriptPath) -- 2428
					Content:remove(obfuscatedPath) -- 2429
					Content:remove(tempPath) -- 2430
					Content:mkdir(scriptPath) -- 2431
					Content:mkdir(obfuscatedPath) -- 2432
					Content:mkdir(tempPath) -- 2433
					if not Content:copyAsync(path, tempPath) then -- 2434
						goto failed -- 2434
					end -- 2434
					local Entry = require("Script.Dev.Entry") -- 2435
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2436
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2437
						"tl", -- 2437
						"yue", -- 2437
						"lua", -- 2437
						"ts", -- 2437
						"tsx", -- 2437
						"vs", -- 2437
						"bl", -- 2437
						"xml", -- 2437
						"wa", -- 2437
						"mod" -- 2437
					}, true) -- 2437
					for _index_0 = 1, #scriptFiles do -- 2438
						local file = scriptFiles[_index_0] -- 2438
						Content:remove(Path(tempPath, file)) -- 2439
					end -- 2438
					for _index_0 = 1, #luaFiles do -- 2440
						local file = luaFiles[_index_0] -- 2440
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2441
					end -- 2440
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2442
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2443
					end) then -- 2442
						goto failed -- 2442
					end -- 2442
					return { -- 2444
						success = true -- 2444
					} -- 2444
				else -- 2446
					return { -- 2446
						success = Content:zipAsync(path, zipFile, function(file) -- 2446
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2447
						end) -- 2446
					} -- 2446
				end -- 2424
			end -- 2418
		end -- 2418
	end -- 2418
	::failed:: -- 2448
	return { -- 2417
		success = false -- 2417
	} -- 2417
end) -- 2417
HttpServer:postSchedule("/unzip", function(req) -- 2450
	do -- 2451
		local _type_0 = type(req) -- 2451
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2451
		if _tab_0 then -- 2451
			local zipFile -- 2451
			do -- 2451
				local _obj_0 = req.body -- 2451
				local _type_1 = type(_obj_0) -- 2451
				if "table" == _type_1 or "userdata" == _type_1 then -- 2451
					zipFile = _obj_0.zipFile -- 2451
				end -- 2451
			end -- 2451
			local path -- 2451
			do -- 2451
				local _obj_0 = req.body -- 2451
				local _type_1 = type(_obj_0) -- 2451
				if "table" == _type_1 or "userdata" == _type_1 then -- 2451
					path = _obj_0.path -- 2451
				end -- 2451
			end -- 2451
			if zipFile ~= nil and path ~= nil then -- 2451
				return { -- 2452
					success = Content:unzipAsync(zipFile, path, function(file) -- 2452
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2453
					end) -- 2452
				} -- 2452
			end -- 2451
		end -- 2451
	end -- 2451
	return { -- 2450
		success = false -- 2450
	} -- 2450
end) -- 2450
HttpServer:post("/editing-info", function(req) -- 2455
	local Entry = require("Script.Dev.Entry") -- 2456
	local config = Entry.getConfig() -- 2457
	local _type_0 = type(req) -- 2458
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2458
	local _match_0 = false -- 2458
	if _tab_0 then -- 2458
		local editingInfo -- 2458
		do -- 2458
			local _obj_0 = req.body -- 2458
			local _type_1 = type(_obj_0) -- 2458
			if "table" == _type_1 or "userdata" == _type_1 then -- 2458
				editingInfo = _obj_0.editingInfo -- 2458
			end -- 2458
		end -- 2458
		if editingInfo ~= nil then -- 2458
			_match_0 = true -- 2458
			config.editingInfo = editingInfo -- 2459
			return { -- 2460
				success = true -- 2460
			} -- 2460
		end -- 2458
	end -- 2458
	if not _match_0 then -- 2458
		if not (config.editingInfo ~= nil) then -- 2462
			local folder -- 2463
			if App.locale:match('^zh') then -- 2463
				folder = 'zh-Hans' -- 2463
			else -- 2463
				folder = 'en' -- 2463
			end -- 2463
			config.editingInfo = json.encode({ -- 2465
				index = 0, -- 2465
				files = { -- 2467
					{ -- 2468
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2468
						title = "welcome.md" -- 2469
					} -- 2467
				} -- 2466
			}) -- 2464
		end -- 2462
		return { -- 2473
			success = true, -- 2473
			editingInfo = config.editingInfo -- 2473
		} -- 2473
	end -- 2458
end) -- 2455
HttpServer:post("/command", function(req) -- 2475
	do -- 2476
		local _type_0 = type(req) -- 2476
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2476
		if _tab_0 then -- 2476
			local code -- 2476
			do -- 2476
				local _obj_0 = req.body -- 2476
				local _type_1 = type(_obj_0) -- 2476
				if "table" == _type_1 or "userdata" == _type_1 then -- 2476
					code = _obj_0.code -- 2476
				end -- 2476
			end -- 2476
			local log -- 2476
			do -- 2476
				local _obj_0 = req.body -- 2476
				local _type_1 = type(_obj_0) -- 2476
				if "table" == _type_1 or "userdata" == _type_1 then -- 2476
					log = _obj_0.log -- 2476
				end -- 2476
			end -- 2476
			if code ~= nil and log ~= nil then -- 2476
				emit("AppCommand", code, log) -- 2477
				return { -- 2478
					success = true -- 2478
				} -- 2478
			end -- 2476
		end -- 2476
	end -- 2476
	return { -- 2475
		success = false -- 2475
	} -- 2475
end) -- 2475
HttpServer:post("/log/save", function() -- 2480
	local folder = ".download" -- 2481
	local fullLogFile = "dora_full_logs.txt" -- 2482
	local fullFolder = Path(Content.writablePath, folder) -- 2483
	Content:mkdir(fullFolder) -- 2484
	local logPath = Path(fullFolder, fullLogFile) -- 2485
	if App:saveLog(logPath) then -- 2486
		return { -- 2487
			success = true, -- 2487
			path = Path(folder, fullLogFile) -- 2487
		} -- 2487
	end -- 2486
	return { -- 2480
		success = false -- 2480
	} -- 2480
end) -- 2480
local tailLines -- 2489
tailLines = function(text, count) -- 2489
	local lines = { } -- 2490
	text = text:gsub("\r\n", "\n") -- 2491
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2492
		lines[#lines + 1] = line -- 2493
	end -- 2492
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2494
		table.remove(lines) -- 2495
	end -- 2494
	local start = math.max(1, #lines - count + 1) -- 2496
	local out = { } -- 2497
	for i = start, #lines do -- 2498
		out[#out + 1] = lines[i] -- 2499
	end -- 2498
	return table.concat(out, "\n") -- 2500
end -- 2489
HttpServer:post("/log", function(req) -- 2502
	local count = 100 -- 2503
	if req and req.body and req.body.count ~= nil then -- 2504
		count = req.body.count -- 2505
	end -- 2504
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2506
		return { -- 2507
			success = false, -- 2507
			message = "count must be a positive integer" -- 2507
		} -- 2507
	end -- 2506
	local folder = ".download" -- 2508
	local fullLogFile = "dora_full_logs.txt" -- 2509
	local fullFolder = Path(Content.writablePath, folder) -- 2510
	Content:mkdir(fullFolder) -- 2511
	local logPath = Path(fullFolder, fullLogFile) -- 2512
	if App:saveLog(logPath) then -- 2513
		local text = Content:load(logPath) -- 2514
		if text then -- 2515
			return { -- 2516
				success = true, -- 2516
				log = tailLines(text, count) -- 2516
			} -- 2516
		else -- 2518
			return { -- 2518
				success = false, -- 2518
				message = "failed to read log" -- 2518
			} -- 2518
		end -- 2515
	else -- 2520
		return { -- 2520
			success = false, -- 2520
			message = "failed to save log" -- 2520
		} -- 2520
	end -- 2513
	return { -- 2502
		success = false -- 2502
	} -- 2502
end) -- 2502
HttpServer:post("/yarn/check", function(req) -- 2522
	local yarncompile = require("yarncompile") -- 2523
	do -- 2524
		local _type_0 = type(req) -- 2524
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2524
		if _tab_0 then -- 2524
			local code -- 2524
			do -- 2524
				local _obj_0 = req.body -- 2524
				local _type_1 = type(_obj_0) -- 2524
				if "table" == _type_1 or "userdata" == _type_1 then -- 2524
					code = _obj_0.code -- 2524
				end -- 2524
			end -- 2524
			if code ~= nil then -- 2524
				local jsonObject = json.decode(code) -- 2525
				if jsonObject then -- 2525
					local errors = { } -- 2526
					local _list_0 = jsonObject.nodes -- 2527
					for _index_0 = 1, #_list_0 do -- 2527
						local node = _list_0[_index_0] -- 2527
						local title, body = node.title, node.body -- 2528
						local luaCode, err = yarncompile(body) -- 2529
						if not luaCode then -- 2529
							errors[#errors + 1] = title .. ":" .. err -- 2530
						end -- 2529
					end -- 2527
					return { -- 2531
						success = true, -- 2531
						syntaxError = table.concat(errors, "\n\n") -- 2531
					} -- 2531
				end -- 2525
			end -- 2524
		end -- 2524
	end -- 2524
	return { -- 2522
		success = false -- 2522
	} -- 2522
end) -- 2522
HttpServer:post("/yarn/check-file", function(req) -- 2533
	local yarncompile = require("yarncompile") -- 2534
	do -- 2535
		local _type_0 = type(req) -- 2535
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2535
		if _tab_0 then -- 2535
			local code -- 2535
			do -- 2535
				local _obj_0 = req.body -- 2535
				local _type_1 = type(_obj_0) -- 2535
				if "table" == _type_1 or "userdata" == _type_1 then -- 2535
					code = _obj_0.code -- 2535
				end -- 2535
			end -- 2535
			if code ~= nil then -- 2535
				local res, _, err = yarncompile(code, true) -- 2536
				if not res then -- 2536
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2537
					return { -- 2538
						success = false, -- 2538
						message = message, -- 2538
						line = line, -- 2538
						column = column, -- 2538
						node = node -- 2538
					} -- 2538
				end -- 2536
			end -- 2535
		end -- 2535
	end -- 2535
	return { -- 2533
		success = true -- 2533
	} -- 2533
end) -- 2533
getWaProjectDirFromFile = function(file) -- 2540
	local current -- 2541
	if Content:isdir(file) then -- 2541
		current = file -- 2541
	else -- 2541
		current = Path:getPath(file) -- 2541
	end -- 2541
	if current == "" then -- 2542
		return nil -- 2542
	end -- 2542
	repeat -- 2543
		local modPath = Path(current, "wa.mod") -- 2544
		if Content:exist(modPath) then -- 2545
			return current, modPath -- 2546
		end -- 2545
		local parent = Path:getPath(current) -- 2547
		if parent == "" or parent == current then -- 2548
			break -- 2548
		end -- 2548
		current = parent -- 2549
	until false -- 2543
	return nil -- 2551
end -- 2540
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2553
	do -- 2554
		local _type_0 = type(req) -- 2554
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2554
		if _tab_0 then -- 2554
			local path -- 2554
			do -- 2554
				local _obj_0 = req.body -- 2554
				local _type_1 = type(_obj_0) -- 2554
				if "table" == _type_1 or "userdata" == _type_1 then -- 2554
					path = _obj_0.path -- 2554
				end -- 2554
			end -- 2554
			if path ~= nil then -- 2554
				local projDir = getWaProjectDirFromFile(path) -- 2555
				if projDir then -- 2555
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2556
					if not Content:exist(sourceDoraPath) then -- 2557
						return { -- 2558
							success = false, -- 2558
							message = "missing dora template" -- 2558
						} -- 2558
					end -- 2557
					local targetVendorPath = Path(projDir, "vendor") -- 2559
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2560
					if not Content:exist(targetVendorPath) then -- 2561
						if not Content:mkdir(targetVendorPath) then -- 2562
							return { -- 2563
								success = false, -- 2563
								message = "failed to create vendor folder" -- 2563
							} -- 2563
						end -- 2562
					elseif not Content:isdir(targetVendorPath) then -- 2564
						return { -- 2565
							success = false, -- 2565
							message = "vendor path is not a folder" -- 2565
						} -- 2565
					end -- 2561
					if Content:exist(targetDoraPath) then -- 2566
						if not Content:remove(targetDoraPath) then -- 2567
							return { -- 2568
								success = false, -- 2568
								message = "failed to remove old dora" -- 2568
							} -- 2568
						end -- 2567
					end -- 2566
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2569
						return { -- 2570
							success = false, -- 2570
							message = "failed to copy dora" -- 2570
						} -- 2570
					end -- 2569
					return { -- 2571
						success = true -- 2571
					} -- 2571
				else -- 2573
					return { -- 2573
						success = false, -- 2573
						message = 'Wa file needs a project' -- 2573
					} -- 2573
				end -- 2555
			end -- 2554
		end -- 2554
	end -- 2554
	return { -- 2553
		success = false, -- 2553
		message = "invalid call" -- 2553
	} -- 2553
end) -- 2553
HttpServer:postSchedule("/wa/build", function(req) -- 2575
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
				local projDir = getWaProjectDirFromFile(path) -- 2577
				if projDir then -- 2577
					local message = Wasm:buildWaAsync(projDir) -- 2578
					if message == "" then -- 2579
						return { -- 2580
							success = true -- 2580
						} -- 2580
					else -- 2582
						return { -- 2582
							success = false, -- 2582
							message = message -- 2582
						} -- 2582
					end -- 2579
				else -- 2584
					return { -- 2584
						success = false, -- 2584
						message = 'Wa file needs a project' -- 2584
					} -- 2584
				end -- 2577
			end -- 2576
		end -- 2576
	end -- 2576
	return { -- 2585
		success = false, -- 2585
		message = 'failed to build' -- 2585
	} -- 2585
end) -- 2575
HttpServer:postSchedule("/wa/format", function(req) -- 2587
	do -- 2588
		local _type_0 = type(req) -- 2588
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2588
		if _tab_0 then -- 2588
			local file -- 2588
			do -- 2588
				local _obj_0 = req.body -- 2588
				local _type_1 = type(_obj_0) -- 2588
				if "table" == _type_1 or "userdata" == _type_1 then -- 2588
					file = _obj_0.file -- 2588
				end -- 2588
			end -- 2588
			if file ~= nil then -- 2588
				local code = Wasm:formatWaAsync(file) -- 2589
				if code == "" then -- 2590
					return { -- 2591
						success = false -- 2591
					} -- 2591
				else -- 2593
					return { -- 2593
						success = true, -- 2593
						code = code -- 2593
					} -- 2593
				end -- 2590
			end -- 2588
		end -- 2588
	end -- 2588
	return { -- 2594
		success = false -- 2594
	} -- 2594
end) -- 2587
HttpServer:postSchedule("/wa/create", function(req) -- 2596
	do -- 2597
		local _type_0 = type(req) -- 2597
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2597
		if _tab_0 then -- 2597
			local path -- 2597
			do -- 2597
				local _obj_0 = req.body -- 2597
				local _type_1 = type(_obj_0) -- 2597
				if "table" == _type_1 or "userdata" == _type_1 then -- 2597
					path = _obj_0.path -- 2597
				end -- 2597
			end -- 2597
			if path ~= nil then -- 2597
				if not Content:exist(Path:getPath(path)) then -- 2598
					return { -- 2599
						success = false, -- 2599
						message = "target path not existed" -- 2599
					} -- 2599
				end -- 2598
				if Content:exist(path) then -- 2600
					return { -- 2601
						success = false, -- 2601
						message = "target project folder existed" -- 2601
					} -- 2601
				end -- 2600
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2602
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2603
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2604
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2605
					return { -- 2608
						success = false, -- 2608
						message = "missing template project" -- 2608
					} -- 2608
				end -- 2605
				if not Content:mkdir(path) then -- 2609
					return { -- 2610
						success = false, -- 2610
						message = "failed to create project folder" -- 2610
					} -- 2610
				end -- 2609
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2611
					Content:remove(path) -- 2612
					return { -- 2613
						success = false, -- 2613
						message = "failed to copy template" -- 2613
					} -- 2613
				end -- 2611
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2614
					Content:remove(path) -- 2615
					return { -- 2616
						success = false, -- 2616
						message = "failed to copy template" -- 2616
					} -- 2616
				end -- 2614
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2617
					Content:remove(path) -- 2618
					return { -- 2619
						success = false, -- 2619
						message = "failed to copy template" -- 2619
					} -- 2619
				end -- 2617
				return { -- 2620
					success = true -- 2620
				} -- 2620
			end -- 2597
		end -- 2597
	end -- 2597
	return { -- 2596
		success = false, -- 2596
		message = "invalid call" -- 2596
	} -- 2596
end) -- 2596
local tsBuildGlobs = { -- 2623
	"**/*.ts", -- 2623
	"**/*.tsx", -- 2624
	"!**/.*/**", -- 2625
	"!**/node_modules/**" -- 2626
} -- 2622
local tsSnapshotGlobs = { -- 2629
	"**/*.ts", -- 2629
	"**/*.tsx", -- 2630
	"**/*.lua", -- 2631
	"!**/.*/**", -- 2632
	"!**/node_modules/**" -- 2633
} -- 2628
local collectTSVirtualFiles -- 2635
collectTSVirtualFiles = function(sourceRoot) -- 2635
	local files = { } -- 2636
	local seen = { } -- 2637
	local addFile -- 2638
	addFile = function(file, moduleName, virtualFile) -- 2638
		if moduleName == nil then -- 2638
			moduleName = nil -- 2638
		end -- 2638
		if virtualFile == nil then -- 2638
			virtualFile = nil -- 2638
		end -- 2638
		local targetFile = virtualFile or file -- 2639
		do -- 2640
			local entry = seen[targetFile] -- 2640
			if entry then -- 2640
				if moduleName and moduleName ~= "" then -- 2641
					entry.moduleName = moduleName -- 2641
				end -- 2641
				return -- 2642
			end -- 2640
		end -- 2640
		local content = Content:load(file) -- 2643
		if content then -- 2643
			local entry = { -- 2644
				file = targetFile, -- 2644
				content = content -- 2644
			} -- 2644
			if moduleName and moduleName ~= "" then -- 2645
				entry.moduleName = moduleName -- 2645
			end -- 2645
			seen[targetFile] = entry -- 2646
			files[#files + 1] = entry -- 2647
		end -- 2643
	end -- 2638
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2648
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2649
		for _index_0 = 1, #_list_0 do -- 2649
			local subFile = _list_0[_index_0] -- 2649
			addFile(Path(sourceRoot, subFile)) -- 2650
		end -- 2649
		local libraryRoots = { -- 2652
			Path(sourceRoot, "Script", "Lib"), -- 2652
			Path(sourceRoot, "Lib"), -- 2653
			Path(Content.assetPath, "Script", "Lib") -- 2654
		} -- 2651
		for _index_0 = 1, #libraryRoots do -- 2655
			local libraryRoot = libraryRoots[_index_0] -- 2655
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2656
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2657
				for _index_1 = 1, #_list_1 do -- 2657
					local subFile = _list_1[_index_1] -- 2657
					local file = Path(libraryRoot, subFile) -- 2658
					local virtualFile = Path(sourceRoot, subFile) -- 2659
					addFile(file, nil, virtualFile) -- 2660
				end -- 2657
			end -- 2656
		end -- 2655
	end -- 2648
	local locale -- 2661
	if App.locale:match('^zh') then -- 2661
		locale = 'zh-Hans' -- 2661
	else -- 2661
		locale = 'en' -- 2661
	end -- 2661
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2662
	local _list_0 = Content:getFiles(declarationRoot) -- 2663
	for _index_0 = 1, #_list_0 do -- 2663
		local file = _list_0[_index_0] -- 2663
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2664
			local fullPath = Path(declarationRoot, file) -- 2665
			local moduleName = Path:getName(Path:getName(file)) -- 2666
			addFile(fullPath, moduleName) -- 2667
		end -- 2664
	end -- 2663
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2668
	local lualibBundleTarget -- 2669
	if sourceRoot then -- 2669
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2669
	else -- 2669
		lualibBundleTarget = "lualib_bundle.lua" -- 2669
	end -- 2669
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2670
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2671
	local _list_1 = Content:getFiles(lualibRoot) -- 2672
	for _index_0 = 1, #_list_1 do -- 2672
		local file = _list_1[_index_0] -- 2672
		if Path:getExt(file) == "lua" then -- 2673
			local virtualFile -- 2674
			if sourceRoot then -- 2674
				virtualFile = Path(sourceRoot, "lualib", file) -- 2674
			else -- 2674
				virtualFile = Path("lualib", file) -- 2674
			end -- 2674
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2675
		end -- 2673
	end -- 2672
	return files -- 2676
end -- 2635
local supportsCompilerWebView -- 2678
supportsCompilerWebView = function() -- 2678
	local _val_0 = App.platform -- 2678
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2678
end -- 2678
local webIDECompilerReady = false -- 2679
local webIDEConnectionGeneration = 0 -- 2680
local tsProbeId = 0 -- 2681
local probeWebIDECompiler -- 2683
probeWebIDECompiler = function(isCancelled) -- 2683
	if HttpServer.wsConnectionCount == 0 then -- 2684
		return false -- 2684
	end -- 2684
	tsProbeId = tsProbeId + 1 -- 2685
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2686
	local generation = webIDEConnectionGeneration -- 2687
	local done, ready = false, false -- 2688
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2689
	local listener = Node() -- 2690
	listener:gslot("AppWS", function(event) -- 2691
		if event.type == "Receive" then -- 2692
			local res = json.decode(event.msg) -- 2693
			if res then -- 2693
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2694
					responses = responses + 1 -- 2695
					ready = ready or res.success == true -- 2696
					done = ready or responses >= expectedResponses -- 2697
				end -- 2694
			end -- 2693
		end -- 2692
	end) -- 2691
	emit("AppWS", "Send", json.encode({ -- 2698
		name = "TranspileTSProbe", -- 2698
		id = requestId -- 2698
	})) -- 2698
	local deadline = App.runningTime + 5 -- 2699
	wait(function() -- 2700
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2700
	end) -- 2700
	listener:removeFromParent() -- 2701
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2702
	if generation == webIDEConnectionGeneration then -- 2703
		webIDECompilerReady = ready -- 2703
	end -- 2703
	return ready -- 2704
end -- 2683
local compilerConnectionListener = Node() -- 2706
compilerConnectionListener:addTo(Director.systemUI) -- 2708
local _anon_func_8 = function(event) -- 2710
	local _val_0 = event.type -- 2710
	return "Open" == _val_0 or "Close" == _val_0 -- 2710
end -- 2710
compilerConnectionListener:gslot("AppWS", function(event) -- 2709
	if _anon_func_8(event) then -- 2710
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2711
		webIDECompilerReady = false -- 2712
		if HttpServer.wsConnectionCount > 0 then -- 2713
			return thread(function() -- 2714
				return probeWebIDECompiler() -- 2714
			end) -- 2714
		end -- 2713
	end -- 2710
end) -- 2709
local _anon_func_9 = function(res) -- 2739
	if res.success then -- 2739
		return "tool" -- 2739
	else -- 2739
		return res.failureKind -- 2739
	end -- 2739
end -- 2739
local transpileTSFileWithWebIDE -- 2716
do -- 2716
	local tsBuildRequestId = 0 -- 2717
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2718
		if not probeWebIDECompiler(isCancelled) then -- 2719
			if isCancelled and isCancelled() then -- 2720
				return { -- 2721
					success = false, -- 2721
					file = file, -- 2721
					message = "build canceled", -- 2721
					interrupted = true -- 2721
				} -- 2721
			end -- 2720
			return { -- 2722
				success = false, -- 2722
				file = file, -- 2722
				message = "TypeScript transpiler is not ready", -- 2722
				failureKind = "tool" -- 2722
			} -- 2722
		end -- 2719
		tsBuildRequestId = tsBuildRequestId + 1 -- 2723
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2724
		local done = false -- 2725
		local result = nil -- 2726
		local listener = Node() -- 2727
		listener:gslot("AppWS", function(event) -- 2728
			if event.type == "Receive" then -- 2729
				local res = json.decode(event.msg) -- 2730
				if res then -- 2730
					if res.name == "TranspileTS" and res.id == requestId then -- 2731
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2732
							local luaFile = Path:replaceExt(file, "lua") -- 2733
							if Content:save(luaFile, res.luaCode) then -- 2734
								result = { -- 2735
									success = true, -- 2735
									file = file -- 2735
								} -- 2735
							else -- 2737
								result = { -- 2737
									success = false, -- 2737
									file = file, -- 2737
									message = "failed to save " .. tostring(luaFile) -- 2737
								} -- 2737
							end -- 2734
						else -- 2739
							result = { -- 2739
								success = false, -- 2739
								file = file, -- 2739
								message = res.message or "Compiler returned no Lua output", -- 2739
								failureKind = _anon_func_9(res) -- 2739
							} -- 2739
						end -- 2732
						done = true -- 2740
					end -- 2731
				end -- 2730
			end -- 2729
		end) -- 2728
		emit("AppWS", "Send", json.encode({ -- 2741
			name = "TranspileTS", -- 2741
			id = requestId, -- 2741
			file = file, -- 2741
			content = content, -- 2741
			projectRoot = sourceRoot, -- 2741
			files = files -- 2741
		})) -- 2741
		local deadline = App.runningTime + 30 -- 2742
		wait(function() -- 2743
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2743
		end) -- 2743
		listener:removeFromParent() -- 2744
		if not done then -- 2745
			webIDECompilerReady = false -- 2746
			if isCancelled and isCancelled() then -- 2747
				return { -- 2748
					success = false, -- 2748
					file = file, -- 2748
					message = "build canceled", -- 2748
					interrupted = true -- 2748
				} -- 2748
			end -- 2747
			return { -- 2749
				success = false, -- 2749
				file = file, -- 2749
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2749
				failureKind = "tool" -- 2749
			} -- 2749
		end -- 2745
		return result -- 2750
	end -- 2718
end -- 2716
local compilerReadyTimeout <const> = 15 -- 2752
local compilerBuildTimeout <const> = 30 -- 2753
local compilerIdleCloseSeconds <const> = 8 -- 2754
local compilerReady = false -- 2755
local compilerRequested = false -- 2756
local compilerFailure = nil -- 2757
local compilerUsers = 0 -- 2758
local compilerCloseGeneration = 0 -- 2759
local compilerJobId = 0 -- 2760
local compilerJobs = { } -- 2761
local compilerResults = { } -- 2762
local compilerInFlight = { } -- 2763
HttpServer:post("/compiler/ready", function() -- 2765
	if not compilerRequested then -- 2766
		return { -- 2766
			success = false -- 2766
		} -- 2766
	end -- 2766
	compilerReady = true -- 2767
	return { -- 2768
		success = true -- 2768
	} -- 2768
end) -- 2765
HttpServer:post("/compiler/failure", function(req) -- 2770
	if not compilerRequested then -- 2771
		return { -- 2771
			success = false -- 2771
		} -- 2771
	end -- 2771
	do -- 2772
		local _type_0 = type(req) -- 2772
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2772
		if _tab_0 then -- 2772
			local message -- 2772
			do -- 2772
				local _obj_0 = req.body -- 2772
				local _type_1 = type(_obj_0) -- 2772
				if "table" == _type_1 or "userdata" == _type_1 then -- 2772
					message = _obj_0.message -- 2772
				end -- 2772
			end -- 2772
			if message ~= nil then -- 2772
				if type(message) == "string" then -- 2773
					compilerFailure = message -- 2774
					compilerReady = false -- 2775
					return { -- 2776
						success = true -- 2776
					} -- 2776
				end -- 2773
			end -- 2772
		end -- 2772
	end -- 2772
	return { -- 2770
		success = false -- 2770
	} -- 2770
end) -- 2770
HttpServer:postSchedule("/compiler/poll", function() -- 2778
	if not compilerRequested then -- 2779
		return { -- 2779
			success = false -- 2779
		} -- 2779
	end -- 2779
	compilerReady = true -- 2780
	local deadline = App.runningTime + 5 -- 2781
	wait(function() -- 2782
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2782
	end) -- 2782
	if not (compilerRequested and not compilerFailure) then -- 2783
		return { -- 2783
			success = false -- 2783
		} -- 2783
	end -- 2783
	local job = table.remove(compilerJobs, 1) -- 2784
	if job then -- 2785
		compilerInFlight[job.id] = true -- 2786
	end -- 2785
	return { -- 2787
		success = true, -- 2787
		job = job -- 2787
	} -- 2787
end) -- 2778
HttpServer:post("/compiler/result", function(req) -- 2789
	do -- 2790
		local _type_0 = type(req) -- 2790
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2790
		if _tab_0 then -- 2790
			local body = req.body -- 2790
			if body ~= nil then -- 2790
				local id = body.id -- 2791
				if not (id and compilerInFlight[id]) then -- 2792
					return { -- 2792
						success = false, -- 2792
						message = "invalid compiler job" -- 2792
					} -- 2792
				end -- 2792
				compilerInFlight[id] = nil -- 2793
				compilerResults[id] = body -- 2794
				return { -- 2795
					success = true -- 2795
				} -- 2795
			end -- 2790
		end -- 2790
	end -- 2790
	return { -- 2789
		success = false -- 2789
	} -- 2789
end) -- 2789
local acquireCompiler -- 2797
acquireCompiler = function() -- 2797
	compilerUsers = compilerUsers + 1 -- 2798
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2799
	if not compilerRequested then -- 2800
		compilerRequested = true -- 2801
		compilerReady = false -- 2802
		compilerFailure = nil -- 2803
		return emit("AppWebView", "/compiler.html", true) -- 2804
	end -- 2800
end -- 2797
local releaseCompiler -- 2806
releaseCompiler = function() -- 2806
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2807
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2808
	if not (compilerUsers == 0) then -- 2809
		return -- 2809
	end -- 2809
	local closeGeneration = compilerCloseGeneration -- 2810
	return thread(function() -- 2811
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2812
		wait(function() -- 2813
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2814
		end) -- 2813
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2819
			compilerRequested = false -- 2820
			compilerReady = false -- 2821
			return emit("AppWebView", "/compiler.html", false) -- 2822
		end -- 2819
	end) -- 2811
end -- 2806
local removeCompilerJob -- 2824
removeCompilerJob = function(id) -- 2824
	for index = #compilerJobs, 1, -1 do -- 2825
		if compilerJobs[index].id == id then -- 2826
			table.remove(compilerJobs, index) -- 2827
		end -- 2826
	end -- 2825
	compilerInFlight[id] = nil -- 2828
	compilerResults[id] = nil -- 2829
end -- 2824
local transpileTSFileWithCompiler -- 2831
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2831
	acquireCompiler() -- 2832
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2833
	wait(function() -- 2834
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2834
	end) -- 2834
	if not compilerReady then -- 2835
		releaseCompiler() -- 2836
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
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2839
			failureKind = "tool" -- 2839
		} -- 2839
	end -- 2835
	compilerJobId = compilerJobId + 1 -- 2840
	local jobId = compilerJobId -- 2841
	compilerJobs[#compilerJobs + 1] = { -- 2843
		id = jobId, -- 2843
		file = file, -- 2844
		content = content, -- 2845
		projectRoot = sourceRoot, -- 2846
		files = files -- 2847
	} -- 2842
	local deadline = App.runningTime + compilerBuildTimeout -- 2848
	wait(function() -- 2849
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2849
	end) -- 2849
	local response = compilerResults[jobId] -- 2850
	removeCompilerJob(jobId) -- 2851
	releaseCompiler() -- 2852
	if not response then -- 2853
		if isCancelled and isCancelled() then -- 2854
			return { -- 2855
				success = false, -- 2855
				file = file, -- 2855
				message = "build canceled", -- 2855
				interrupted = true -- 2855
			} -- 2855
		end -- 2854
		return { -- 2856
			success = false, -- 2856
			file = file, -- 2856
			message = compilerFailure or "TypeScript transpile timed out", -- 2856
			failureKind = "tool" -- 2856
		} -- 2856
	end -- 2853
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2857
		local luaFile = Path:replaceExt(file, "lua") -- 2858
		if Content:save(luaFile, response.luaCode) then -- 2859
			return { -- 2860
				success = true, -- 2860
				file = file -- 2860
			} -- 2860
		end -- 2859
		return { -- 2861
			success = false, -- 2861
			file = file, -- 2861
			message = "failed to save " .. tostring(luaFile) -- 2861
		} -- 2861
	end -- 2857
	return { -- 2862
		success = false, -- 2862
		file = file, -- 2862
		message = response.message or "TypeScript transpile failed" -- 2862
	} -- 2862
end -- 2831
local compilerFailureListener = Node() -- 2864
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2865
	compilerFailure = message -- 2866
	compilerReady = false -- 2867
end) -- 2865
local transpileTSFile -- 2869
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2869
	if supportsCompilerWebView() and not files then -- 2870
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2871
	end -- 2870
	if HttpServer.wsConnectionCount > 0 then -- 2872
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2873
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2874
			return result -- 2874
		end -- 2874
		webIDECompilerReady = false -- 2875
	end -- 2872
	if supportsCompilerWebView() then -- 2876
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2877
	end -- 2876
	return { -- 2878
		success = false, -- 2878
		file = file, -- 2878
		message = "Web IDE compiler not connected", -- 2878
		failureKind = "tool" -- 2878
	} -- 2878
end -- 2869
local _anon_func_10 = function(path) -- 2893
	local _val_0 = Path:getExt(path) -- 2893
	return "ts" == _val_0 or "tsx" == _val_0 -- 2893
end -- 2893
HttpServer:postSchedule("/ts/build", function(req) -- 2880
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2881
	local buildSucceeded = false -- 2882
	local _ <close> = setmetatable({ }, { -- 2883
		__close = function() -- 2883
			return finishUpdate(buildSucceeded) -- 2883
		end -- 2883
	}) -- 2883
	do -- 2884
		local _type_0 = type(req) -- 2884
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2884
		if _tab_0 then -- 2884
			local path -- 2884
			do -- 2884
				local _obj_0 = req.body -- 2884
				local _type_1 = type(_obj_0) -- 2884
				if "table" == _type_1 or "userdata" == _type_1 then -- 2884
					path = _obj_0.path -- 2884
				end -- 2884
			end -- 2884
			if path ~= nil then -- 2884
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2885
					return { -- 2886
						success = false, -- 2886
						message = "Web IDE not connected" -- 2886
					} -- 2886
				end -- 2885
				local projectRoot = req.body.projectRoot -- 2887
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2888
				if not Content:exist(path) then -- 2889
					return { -- 2890
						success = false, -- 2890
						message = "path not existed" -- 2890
					} -- 2890
				end -- 2889
				local messages = { } -- 2891
				if not Content:isdir(path) then -- 2892
					if not (_anon_func_10(path)) then -- 2893
						return { -- 2894
							success = false, -- 2894
							message = "expecting a TypeScript file" -- 2894
						} -- 2894
					end -- 2893
					local content = Content:load(path) -- 2895
					if not content then -- 2896
						return { -- 2897
							success = false, -- 2897
							message = "failed to read file" -- 2897
						} -- 2897
					end -- 2896
					emit("AppWS", "Send", json.encode({ -- 2898
						name = "UpdateFile", -- 2898
						file = path, -- 2898
						exists = true, -- 2898
						content = content, -- 2898
						projectRoot = sourceRoot -- 2898
					})) -- 2898
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2899
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2900
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2901
					end -- 2899
				else -- 2903
					local fileData = { } -- 2903
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2904
					for _index_0 = 1, #_list_0 do -- 2904
						local subFile = _list_0[_index_0] -- 2904
						local file = Path(path, subFile) -- 2905
						local content = Content:load(file) -- 2906
						if content then -- 2906
							fileData[file] = content -- 2907
							emit("AppWS", "Send", json.encode({ -- 2908
								name = "UpdateFile", -- 2908
								file = file, -- 2908
								exists = true, -- 2908
								content = content, -- 2908
								projectRoot = sourceRoot -- 2908
							})) -- 2908
						else -- 2910
							messages[#messages + 1] = { -- 2910
								success = false, -- 2910
								file = file, -- 2910
								message = "failed to read file" -- 2910
							} -- 2910
						end -- 2906
					end -- 2904
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2911
					for file, content in pairs(fileData) do -- 2912
						if "d" == Path:getExt(Path:getName(file)) then -- 2913
							goto _continue_0 -- 2913
						end -- 2913
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2914
						::_continue_0:: -- 2913
					end -- 2912
				end -- 2892
				local success = true -- 2915
				for _index_0 = 1, #messages do -- 2916
					local item = messages[_index_0] -- 2916
					if not item.success then -- 2917
						success = false -- 2917
					end -- 2917
				end -- 2916
				local message = nil -- 2918
				if not success then -- 2919
					message = "TypeScript compilation failed" -- 2919
				end -- 2919
				buildSucceeded = success -- 2920
				return { -- 2921
					success = success, -- 2921
					messages = messages, -- 2921
					message = message -- 2921
				} -- 2921
			end -- 2884
		end -- 2884
	end -- 2884
	return { -- 2880
		success = false -- 2880
	} -- 2880
end) -- 2880
HttpServer:post("/download", function(req) -- 2923
	do -- 2924
		local _type_0 = type(req) -- 2924
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2924
		if _tab_0 then -- 2924
			local url -- 2924
			do -- 2924
				local _obj_0 = req.body -- 2924
				local _type_1 = type(_obj_0) -- 2924
				if "table" == _type_1 or "userdata" == _type_1 then -- 2924
					url = _obj_0.url -- 2924
				end -- 2924
			end -- 2924
			local target -- 2924
			do -- 2924
				local _obj_0 = req.body -- 2924
				local _type_1 = type(_obj_0) -- 2924
				if "table" == _type_1 or "userdata" == _type_1 then -- 2924
					target = _obj_0.target -- 2924
				end -- 2924
			end -- 2924
			if url ~= nil and target ~= nil then -- 2924
				local Entry = require("Script.Dev.Entry") -- 2925
				Entry.downloadFile(url, target) -- 2926
				return { -- 2927
					success = true -- 2927
				} -- 2927
			end -- 2924
		end -- 2924
	end -- 2924
	return { -- 2923
		success = false -- 2923
	} -- 2923
end) -- 2923
local isDesktopPlatform -- 2929
isDesktopPlatform = function() -- 2929
	local _val_0 = App.platform -- 2930
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2930
end -- 2929
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 2932
local nativeIDEListener = Node() -- 2933
nativeIDEListener:addTo(Director.systemUI) -- 2934
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 2935
	nativeIDEState, nativeIDEMessage = state, message -- 2936
end) -- 2935
local _anon_func_11 = function() -- 2939
	local _val_0 = App.platform -- 2939
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2939
end -- 2939
HttpServer:post("/ide", function(req) -- 2938
	if not (_anon_func_11()) then -- 2939
		return { -- 2939
			success = false, -- 2939
			message = "Native IDE is unavailable" -- 2939
		} -- 2939
	end -- 2939
	if not App.webIDEEnabled then -- 2940
		return { -- 2940
			success = false, -- 2940
			message = "Embedded Web IDE is disabled" -- 2940
		} -- 2940
	end -- 2940
	do -- 2941
		local _type_0 = type(req) -- 2941
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2941
		if _tab_0 then -- 2941
			local action -- 2941
			do -- 2941
				local _obj_0 = req.body -- 2941
				local _type_1 = type(_obj_0) -- 2941
				if "table" == _type_1 or "userdata" == _type_1 then -- 2941
					action = _obj_0.action -- 2941
				end -- 2941
			end -- 2941
			if action ~= nil then -- 2941
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 2942
					emit("AppWebView", "/ide/" .. action, true) -- 2943
					return { -- 2944
						success = true -- 2944
					} -- 2944
				end -- 2942
			end -- 2941
		end -- 2941
	end -- 2941
	return { -- 2938
		success = false, -- 2938
		message = "invalid IDE action" -- 2938
	} -- 2938
end) -- 2938
local _anon_func_12 = function() -- 2960
	local _val_0 = App.platform -- 2960
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2960
end -- 2960
local getServerStatus -- 2946
getServerStatus = function() -- 2946
	local Entry = require("Script.Dev.Entry") -- 2947
	local running = Entry.getCurrentEntryStatus() -- 2948
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2949
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2950
	return { -- 2952
		success = true, -- 2952
		platform = App.platform, -- 2953
		locale = App.locale, -- 2954
		version = App.version, -- 2955
		url = "http://localhost:8866", -- 2956
		wsConnectionCount = wsConnectionCount, -- 2957
		webIDEConnected = wsConnectionCount > 0, -- 2958
		nativeIDE = { -- 2960
			supported = _anon_func_12(), -- 2960
			enabled = App.webIDEEnabled, -- 2961
			state = nativeIDEState, -- 2962
			message = nativeIDEMessage -- 2963
		}, -- 2959
		typescriptCompiler = { -- 2965
			webIDEReady = webIDECompilerReady, -- 2965
			webIDEGeneration = webIDEConnectionGeneration, -- 2966
			embeddedSupported = supportsCompilerWebView(), -- 2967
			embeddedRequested = compilerRequested, -- 2968
			embeddedReady = compilerReady, -- 2969
			users = compilerUsers, -- 2970
			queuedJobs = #compilerJobs, -- 2971
			failure = compilerFailure -- 2972
		}, -- 2964
		assetPath = Content.assetPath, -- 2973
		writablePath = Content.writablePath, -- 2974
		appPath = Content.appPath, -- 2975
		waTemplateReady = waTemplateReady, -- 2976
		running = running -- 2977
	} -- 2951
end -- 2946
HttpServer:post("/status", function() -- 2980
	return getServerStatus() -- 2981
end) -- 2980
HttpServer:postSchedule("/doctor/fix", function(req) -- 2983
	do -- 2984
		local _type_0 = type(req) -- 2984
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2984
		if _tab_0 then -- 2984
			local openWebIDE -- 2984
			do -- 2984
				local _obj_0 = req.body -- 2984
				local _type_1 = type(_obj_0) -- 2984
				if "table" == _type_1 or "userdata" == _type_1 then -- 2984
					openWebIDE = _obj_0.openWebIDE -- 2984
				end -- 2984
			end -- 2984
			if openWebIDE ~= nil then -- 2984
				if not openWebIDE then -- 2985
					return { -- 2986
						success = false, -- 2986
						message = "nothing to fix" -- 2986
					} -- 2986
				end -- 2985
				local status = getServerStatus() -- 2987
				if status.webIDEConnected then -- 2988
					return { -- 2989
						success = true, -- 2989
						fixed = false, -- 2989
						message = "Web IDE already connected.", -- 2989
						status = status -- 2989
					} -- 2989
				end -- 2988
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2990
				if waitSeconds > 0 then -- 2991
					local deadline = os.time() + waitSeconds -- 2992
					repeat -- 2993
						sleep(0.2) -- 2994
						status = getServerStatus() -- 2995
						if status.webIDEConnected then -- 2996
							return { -- 2997
								success = true, -- 2997
								fixed = false, -- 2997
								reconnected = true, -- 2997
								message = "Web IDE reconnected.", -- 2997
								status = status -- 2997
							} -- 2997
						end -- 2996
					until os.time() >= deadline -- 2993
				end -- 2991
				if not isDesktopPlatform() then -- 2999
					return { -- 3000
						success = false, -- 3000
						message = "opening Web IDE is only supported on desktop platforms", -- 3000
						status = status -- 3000
					} -- 3000
				end -- 2999
				local url = "http://localhost:8866" -- 3001
				App:openURL(url) -- 3002
				status.openedURL = url -- 3003
				return { -- 3004
					success = true, -- 3004
					fixed = true, -- 3004
					message = "Opened Web IDE in the local browser.", -- 3004
					url = url, -- 3004
					status = status -- 3004
				} -- 3004
			end -- 2984
		end -- 2984
	end -- 2984
	return { -- 2983
		success = false, -- 2983
		message = "invalid call" -- 2983
	} -- 2983
end) -- 2983
local status = { } -- 3006
_module_0 = status -- 3007
status.transpileTSFile = transpileTSFile -- 3009
status.buildAsync = function(path) -- 3011
	if not Content:exist(path) then -- 3012
		return { -- 3013
			success = false, -- 3013
			file = path, -- 3013
			message = "file not existed" -- 3013
		} -- 3013
	end -- 3012
	do -- 3014
		local _exp_0 = Path:getExt(path) -- 3014
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 3014
			if '' == Path:getExt(Path:getName(path)) then -- 3015
				local content = Content:loadAsync(path) -- 3016
				if content then -- 3016
					local resultCodes, err = compileFileAsync(path, content) -- 3017
					if resultCodes then -- 3017
						return { -- 3018
							success = true, -- 3018
							file = path -- 3018
						} -- 3018
					else -- 3020
						return { -- 3020
							success = false, -- 3020
							file = path, -- 3020
							message = err -- 3020
						} -- 3020
					end -- 3017
				end -- 3016
			end -- 3015
		elseif "lua" == _exp_0 then -- 3021
			local content = Content:loadAsync(path) -- 3022
			if content then -- 3022
				do -- 3023
					local isTIC80 = CheckTIC80Code(content) -- 3023
					if isTIC80 then -- 3023
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 3024
					end -- 3023
				end -- 3023
				local success, info -- 3025
				do -- 3025
					local _obj_0 = luaCheck(path, content) -- 3025
					success, info = _obj_0.success, _obj_0.info -- 3025
				end -- 3025
				if success then -- 3026
					return { -- 3027
						success = true, -- 3027
						file = path -- 3027
					} -- 3027
				elseif info and #info > 0 then -- 3028
					local messages = { } -- 3029
					for _index_0 = 1, #info do -- 3030
						local _des_0 = info[_index_0] -- 3030
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3030
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
						if line then -- 3039
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3040
						else -- 3042
							messages[#messages + 1] = message -- 3042
						end -- 3039
					end -- 3030
					return { -- 3043
						success = false, -- 3043
						file = path, -- 3043
						message = table.concat(messages, "\n") -- 3043
					} -- 3043
				else -- 3045
					return { -- 3045
						success = false, -- 3045
						file = path, -- 3045
						message = "lua check failed" -- 3045
					} -- 3045
				end -- 3026
			end -- 3022
		elseif "yarn" == _exp_0 then -- 3046
			local content = Content:loadAsync(path) -- 3047
			if content then -- 3047
				local res, _, err = yarncompile(content, true) -- 3048
				if res then -- 3048
					return { -- 3049
						success = true, -- 3049
						file = path -- 3049
					} -- 3049
				else -- 3051
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3051
					local lineText = "" -- 3052
					if line then -- 3053
						local currentLine = 1 -- 3054
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3055
							if currentLine == line then -- 3056
								lineText = text -- 3057
								break -- 3058
							end -- 3056
							currentLine = currentLine + 1 -- 3059
						end -- 3055
					end -- 3053
					if node ~= "" then -- 3060
						node = "node: " .. tostring(node) .. ", " -- 3061
					else -- 3062
						node = "" -- 3062
					end -- 3060
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3063
					return { -- 3064
						success = false, -- 3064
						file = path, -- 3064
						message = message -- 3064
					} -- 3064
				end -- 3048
			end -- 3047
		end -- 3014
	end -- 3014
	return { -- 3065
		success = false, -- 3065
		file = path, -- 3065
		message = "invalid file to build" -- 3065
	} -- 3065
end -- 3011
HttpServer:postSchedule("/git/commit-files", function(req) -- 3067
	do -- 3068
		local _type_0 = type(req) -- 3068
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3068
		if _tab_0 then -- 3068
			local body = req.body -- 3068
			if body ~= nil then -- 3068
				local repoPath, commit = body.repoPath, body.commit -- 3069
				if gitInvalidRepoPath(repoPath) then -- 3070
					return { -- 3070
						success = false, -- 3070
						message = "invalid repoPath" -- 3070
					} -- 3070
				end -- 3070
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3071
					return { -- 3071
						success = false, -- 3071
						message = "invalid commit" -- 3071
					} -- 3071
				end -- 3071
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3072
				if not res.success then -- 3073
					return res -- 3073
				end -- 3073
				return { -- 3074
					success = true, -- 3074
					status = res.status, -- 3074
					data = res.status and res.status.data -- 3074
				} -- 3074
			end -- 3068
		end -- 3068
	end -- 3068
	return invalidArguments -- 3067
end) -- 3067
thread(function() -- 3076
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3077
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3078
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3079
		local storedAsset -- 3082
		storedAsset = function(file) -- 3082
			if Content:exist(file) then -- 3083
				return Content:load(file) -- 3084
			elseif Content:exist(file .. ".gz") then -- 3085
				return Content:load(file .. ".gz") -- 3086
			else -- 3087
				return "" -- 3087
			end -- 3083
		end -- 3082
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3088
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3089
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3090
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3091
		local readyContent = table.concat({ -- 3093
			App.version, -- 3093
			storedAsset(doraWeb), -- 3094
			storedAsset(heavyAssets), -- 3095
			storedAsset(runtimeIndex), -- 3096
			storedAsset(compilerIndex), -- 3097
			storedAsset(manifest) -- 3098
		}, "\n") -- 3092
		local needReload -- 3100
		if Content:exist(doraReady) then -- 3100
			needReload = readyContent ~= Content:load(doraReady) -- 3101
		else -- 3102
			needReload = true -- 3102
		end -- 3100
		if needReload then -- 3103
			Content:remove(Path(Content.appPath, ".www")) -- 3104
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3105
			Content:save(doraReady, readyContent) -- 3109
			print("Dora Dora is ready!") -- 3110
		end -- 3103
	end -- 3079
	if App.platform == "Emscripten" then -- 3111
		status.url = nil -- 3112
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3113
	end -- 3111
	HttpServer:clearStaticCacheControls() -- 3114
	HttpServer:setStaticCacheControl("no-cache") -- 3115
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3116
	if HttpServer:start(8866) then -- 3120
		local localIP = HttpServer.localIP -- 3121
		if localIP == "" then -- 3122
			localIP = "localhost" -- 3122
		end -- 3122
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3123
		return HttpServer:startWS(8868) -- 3124
	else -- 3126
		status.url = nil -- 3126
		return print("8866 Port not available!") -- 3127
	end -- 3120
end) -- 3076
return _module_0 -- 1
