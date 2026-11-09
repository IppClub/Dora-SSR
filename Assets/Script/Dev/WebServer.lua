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
			active INTEGER NOT NULL DEFAULT 1,
			created_at INTEGER,
			updated_at INTEGER
		);
	]]) -- 1516
	require("Agent.Config.LLMConfigMigration").upgradeLLMConfig() -- 1534
	return require("Agent.Config.LLMConfigNames").upgradeLLMConfigNames() -- 1535
end -- 1476
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
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options\n		from LLMConfig\n		order by id asc") -- 1577
	local items -- 1581
	if rows and #rows > 0 then -- 1581
		local _accum_0 = { } -- 1582
		local _len_0 = 1 -- 1582
		for _index_0 = 1, #rows do -- 1582
			local _des_0 = rows[_index_0] -- 1582
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10] -- 1582
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
				customOptions = normalizeCustomOptions(customOptions) -- 1583
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
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions -- 1589
				local now = os.time() -- 1590
				if name == nil or url == nil or model == nil or key == nil then -- 1591
					return invalidArguments -- 1592
				end -- 1591
				local names = require("Agent.Config.LLMConfigNames") -- 1593
				name = names.normalizeLLMConfigName(name) -- 1594
				if not name then -- 1595
					return { -- 1595
						success = false, -- 1595
						code = "INVALID_LLM_CONFIG_NAME", -- 1595
						message = "LLM configuration name must be a non-empty string" -- 1595
					} -- 1595
				end -- 1595
				local nameCheck = names.checkLLMConfigName(name) -- 1596
				if not nameCheck.success then -- 1597
					return nameCheck -- 1597
				end -- 1597
				contextWindow = normalizeContextWindow(contextWindow) -- 1598
				temperature = normalizeTemperature(temperature) -- 1599
				maxTokens = normalizeMaxTokens(maxTokens) -- 1600
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1601
				customOptions = normalizeCustomOptions(customOptions) -- 1602
				if not validateCustomOptions(customOptions) then -- 1603
					return { -- 1603
						success = false, -- 1603
						message = "customOptions must be a JSON object" -- 1603
					} -- 1603
				end -- 1603
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1610
					tostring(name), -- 1610
					tostring(url), -- 1611
					tostring(model), -- 1612
					tostring(key), -- 1613
					contextWindow, -- 1614
					temperature, -- 1615
					maxTokens, -- 1616
					reasoningEffort, -- 1617
					customOptions, -- 1618
					1, -- 1619
					now, -- 1620
					now -- 1621
				}) -- 1604
				if affected < 0 then -- 1623
					nameCheck = names.checkLLMConfigName(name) -- 1624
					if not nameCheck.success then -- 1625
						return nameCheck -- 1625
					end -- 1625
				end -- 1623
				return { -- 1626
					success = affected > 0 -- 1626
				} -- 1626
			end -- 1588
		end -- 1588
	end -- 1588
	return invalidArguments -- 1586
end) -- 1586
HttpServer:post("/llm/update", function(req) -- 1628
	ensureLLMConfigTable() -- 1629
	do -- 1630
		local _type_0 = type(req) -- 1630
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1630
		if _tab_0 then -- 1630
			local body = req.body -- 1630
			if body ~= nil then -- 1630
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions -- 1631
				local now = os.time() -- 1632
				id = tonumber(id) -- 1633
				if id == nil or id <= 0 or id ~= math.floor(id) then -- 1634
					return invalidArguments -- 1634
				end -- 1634
				local names = require("Agent.Config.LLMConfigNames") -- 1635
				name = names.normalizeLLMConfigName(name) -- 1636
				if not name then -- 1637
					return { -- 1637
						success = false, -- 1637
						code = "INVALID_LLM_CONFIG_NAME", -- 1637
						message = "LLM configuration name must be a non-empty string" -- 1637
					} -- 1637
				end -- 1637
				local nameCheck = names.checkLLMConfigName(name, id) -- 1638
				if not nameCheck.success then -- 1639
					return nameCheck -- 1639
				end -- 1639
				contextWindow = normalizeContextWindow(contextWindow) -- 1640
				temperature = normalizeTemperature(temperature) -- 1641
				maxTokens = normalizeMaxTokens(maxTokens) -- 1642
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1643
				customOptions = normalizeCustomOptions(customOptions) -- 1644
				if not validateCustomOptions(customOptions) then -- 1645
					return { -- 1645
						success = false, -- 1645
						message = "customOptions must be a JSON object" -- 1645
					} -- 1645
				end -- 1645
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, updated_at = ?\n			where id = ?", { -- 1650
					tostring(name), -- 1650
					tostring(url), -- 1651
					tostring(model), -- 1652
					tostring(key), -- 1653
					contextWindow, -- 1654
					temperature, -- 1655
					maxTokens, -- 1656
					reasoningEffort, -- 1657
					customOptions, -- 1658
					now, -- 1659
					id -- 1660
				}) -- 1646
				if affected < 0 then -- 1662
					nameCheck = names.checkLLMConfigName(name, id) -- 1663
					if not nameCheck.success then -- 1664
						return nameCheck -- 1664
					end -- 1664
				end -- 1662
				return { -- 1665
					success = affected > 0 -- 1665
				} -- 1665
			end -- 1630
		end -- 1630
	end -- 1630
	return invalidArguments -- 1628
end) -- 1628
HttpServer:post("/llm/delete", function(req) -- 1667
	ensureLLMConfigTable() -- 1668
	do -- 1669
		local _type_0 = type(req) -- 1669
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1669
		if _tab_0 then -- 1669
			local id -- 1669
			do -- 1669
				local _obj_0 = req.body -- 1669
				local _type_1 = type(_obj_0) -- 1669
				if "table" == _type_1 or "userdata" == _type_1 then -- 1669
					id = _obj_0.id -- 1669
				end -- 1669
			end -- 1669
			if id ~= nil then -- 1669
				id = tonumber(id) -- 1670
				if id == nil then -- 1671
					return invalidArguments -- 1671
				end -- 1671
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1672
					id -- 1672
				}) -- 1672
				return { -- 1673
					success = affected >= 0 -- 1673
				} -- 1673
			end -- 1669
		end -- 1669
	end -- 1669
	return invalidArguments -- 1667
end) -- 1667
HttpServer:post("/local-agent/list", function() -- 1675
	return { -- 1676
		success = true, -- 1676
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1676
		items = AgentLocalAgent.listConfigs() -- 1676
	} -- 1676
end) -- 1675
HttpServer:post("/local-agent/save", function(req) -- 1678
	do -- 1679
		local _type_0 = type(req) -- 1679
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1679
		if _tab_0 then -- 1679
			local body = req.body -- 1679
			if body ~= nil then -- 1679
				return AgentLocalAgent.saveConfig(body) -- 1680
			end -- 1679
		end -- 1679
	end -- 1679
	return invalidArguments -- 1678
end) -- 1678
HttpServer:post("/local-agent/delete", function(req) -- 1682
	do -- 1683
		local _type_0 = type(req) -- 1683
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1683
		if _tab_0 then -- 1683
			local id -- 1683
			do -- 1683
				local _obj_0 = req.body -- 1683
				local _type_1 = type(_obj_0) -- 1683
				if "table" == _type_1 or "userdata" == _type_1 then -- 1683
					id = _obj_0.id -- 1683
				end -- 1683
			end -- 1683
			if id ~= nil then -- 1683
				return AgentLocalAgent.deleteConfig(id) -- 1684
			end -- 1683
		end -- 1683
	end -- 1683
	return invalidArguments -- 1682
end) -- 1682
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1686
	do -- 1687
		local _type_0 = type(req) -- 1687
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1687
		if _tab_0 then -- 1687
			local id -- 1687
			do -- 1687
				local _obj_0 = req.body -- 1687
				local _type_1 = type(_obj_0) -- 1687
				if "table" == _type_1 or "userdata" == _type_1 then -- 1687
					id = _obj_0.id -- 1687
				end -- 1687
			end -- 1687
			if id ~= nil then -- 1687
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1688
			end -- 1687
		end -- 1687
	end -- 1687
	return invalidArguments -- 1686
end) -- 1686
HttpServer:post("/stat", function(req) -- 1690
	do -- 1691
		local _type_0 = type(req) -- 1691
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1691
		if _tab_0 then -- 1691
			local path -- 1691
			do -- 1691
				local _obj_0 = req.body -- 1691
				local _type_1 = type(_obj_0) -- 1691
				if "table" == _type_1 or "userdata" == _type_1 then -- 1691
					path = _obj_0.path -- 1691
				end -- 1691
			end -- 1691
			if path ~= nil then -- 1691
				if not Content:exist(path) then -- 1692
					return { -- 1693
						success = false, -- 1693
						message = "target not existed" -- 1693
					} -- 1693
				end -- 1692
				if Content:isdir(path) then -- 1694
					return { -- 1695
						success = false, -- 1695
						message = "failed to stat a directory" -- 1695
					} -- 1695
				end -- 1694
				local size, isBinary = Content:getAttr(path) -- 1696
				if size then -- 1696
					return { -- 1697
						success = true, -- 1697
						size = size, -- 1697
						isBinary = isBinary -- 1697
					} -- 1697
				end -- 1696
			end -- 1691
		end -- 1691
	end -- 1691
	return { -- 1690
		success = false, -- 1690
		message = "failed to stat" -- 1690
	} -- 1690
end) -- 1690
HttpServer:post("/new", function(req) -- 1699
	do -- 1700
		local _type_0 = type(req) -- 1700
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1700
		if _tab_0 then -- 1700
			local path -- 1700
			do -- 1700
				local _obj_0 = req.body -- 1700
				local _type_1 = type(_obj_0) -- 1700
				if "table" == _type_1 or "userdata" == _type_1 then -- 1700
					path = _obj_0.path -- 1700
				end -- 1700
			end -- 1700
			local content -- 1700
			do -- 1700
				local _obj_0 = req.body -- 1700
				local _type_1 = type(_obj_0) -- 1700
				if "table" == _type_1 or "userdata" == _type_1 then -- 1700
					content = _obj_0.content -- 1700
				end -- 1700
			end -- 1700
			local folder -- 1700
			do -- 1700
				local _obj_0 = req.body -- 1700
				local _type_1 = type(_obj_0) -- 1700
				if "table" == _type_1 or "userdata" == _type_1 then -- 1700
					folder = _obj_0.folder -- 1700
				end -- 1700
			end -- 1700
			if path ~= nil and content ~= nil and folder ~= nil then -- 1700
				if Content:exist(path) then -- 1701
					return { -- 1702
						success = false, -- 1702
						message = "TargetExisted" -- 1702
					} -- 1702
				end -- 1701
				local parent = Path:getPath(path) -- 1703
				local files = Content:getFiles(parent) -- 1704
				if folder then -- 1705
					local name = Path:getFilename(path):lower() -- 1706
					for _index_0 = 1, #files do -- 1707
						local file = files[_index_0] -- 1707
						if name == Path:getFilename(file):lower() then -- 1708
							return { -- 1709
								success = false, -- 1709
								message = "TargetExisted" -- 1709
							} -- 1709
						end -- 1708
					end -- 1707
					if Content:mkdir(path) then -- 1710
						return { -- 1711
							success = true -- 1711
						} -- 1711
					end -- 1710
				else -- 1713
					local name = Path:getName(path):lower() -- 1713
					for _index_0 = 1, #files do -- 1714
						local file = files[_index_0] -- 1714
						if name == Path:getName(file):lower() then -- 1715
							local ext = Path:getExt(file) -- 1716
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1717
								goto _continue_0 -- 1718
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1719
								goto _continue_0 -- 1720
							end -- 1717
							return { -- 1721
								success = false, -- 1721
								message = "SourceExisted" -- 1721
							} -- 1721
						end -- 1715
						::_continue_0:: -- 1715
					end -- 1714
					if Content:save(path, content) then -- 1722
						return { -- 1723
							success = true -- 1723
						} -- 1723
					end -- 1722
				end -- 1705
			end -- 1700
		end -- 1700
	end -- 1700
	return { -- 1699
		success = false, -- 1699
		message = "Failed" -- 1699
	} -- 1699
end) -- 1699
local deleteAsset -- 1725
deleteAsset = function(path) -- 1725
	if not Content:exist(path) then -- 1726
		return false -- 1726
	end -- 1726
	local projectRoot -- 1727
	if Content:isdir(path) and isProjectRootDir(path) then -- 1727
		projectRoot = path -- 1727
	else -- 1727
		projectRoot = nil -- 1727
	end -- 1727
	local parent = Path:getPath(path) -- 1728
	local files = Content:getFiles(parent) -- 1729
	local name = Path:getName(path):lower() -- 1730
	local ext = Path:getExt(path) -- 1731
	for _index_0 = 1, #files do -- 1732
		local file = files[_index_0] -- 1732
		if name == Path:getName(file):lower() then -- 1733
			local _exp_0 = Path:getExt(file) -- 1734
			if "tl" == _exp_0 then -- 1734
				if ("vs" == ext) then -- 1734
					Content:remove(Path(parent, file)) -- 1735
				end -- 1734
			elseif "lua" == _exp_0 then -- 1736
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1736
					Content:remove(Path(parent, file)) -- 1737
				end -- 1736
			end -- 1734
		end -- 1733
	end -- 1732
	if Content:remove(path) then -- 1738
		if projectRoot then -- 1739
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1740
		end -- 1739
		return true -- 1741
	end -- 1738
	return false -- 1742
end -- 1725
local moveAsset -- 1744
moveAsset = function(old, new) -- 1744
	if not (Content:exist(old) and not Content:exist(new)) then -- 1745
		return false -- 1745
	end -- 1745
	local renamedDir = Content:isdir(old) -- 1746
	local parent = Path:getPath(new) -- 1747
	local files = Content:getFiles(parent) -- 1748
	if renamedDir then -- 1749
		local name = Path:getFilename(new):lower() -- 1750
		for _index_0 = 1, #files do -- 1751
			local file = files[_index_0] -- 1751
			if name == Path:getFilename(file):lower() then -- 1752
				return false -- 1753
			end -- 1752
		end -- 1751
	else -- 1755
		local name = Path:getName(new):lower() -- 1755
		local ext = Path:getExt(new) -- 1756
		for _index_0 = 1, #files do -- 1757
			local file = files[_index_0] -- 1757
			if name == Path:getName(file):lower() then -- 1758
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1759
					goto _continue_0 -- 1760
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1761
					goto _continue_0 -- 1762
				end -- 1759
				return false -- 1763
			end -- 1758
			::_continue_0:: -- 1758
		end -- 1757
	end -- 1749
	if not Content:move(old, new) then -- 1764
		return false -- 1764
	end -- 1764
	if renamedDir then -- 1765
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1766
	end -- 1765
	local newParent = Path:getPath(new) -- 1767
	parent = Path:getPath(old) -- 1768
	files = Content:getFiles(parent) -- 1769
	local newName = Path:getName(new) -- 1770
	local oldName = Path:getName(old) -- 1771
	local name = oldName:lower() -- 1772
	local ext = Path:getExt(old) -- 1773
	for _index_0 = 1, #files do -- 1774
		local file = files[_index_0] -- 1774
		if name == Path:getName(file):lower() then -- 1775
			local _exp_0 = Path:getExt(file) -- 1776
			if "tl" == _exp_0 then -- 1776
				if ("vs" == ext) then -- 1776
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1777
				end -- 1776
			elseif "lua" == _exp_0 then -- 1778
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1778
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1779
				end -- 1778
			end -- 1776
		end -- 1775
	end -- 1774
	return true -- 1780
end -- 1744
HttpServer:post("/delete", function(req) -- 1782
	do -- 1783
		local _type_0 = type(req) -- 1783
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1783
		if _tab_0 then -- 1783
			local path -- 1783
			do -- 1783
				local _obj_0 = req.body -- 1783
				local _type_1 = type(_obj_0) -- 1783
				if "table" == _type_1 or "userdata" == _type_1 then -- 1783
					path = _obj_0.path -- 1783
				end -- 1783
			end -- 1783
			if path ~= nil then -- 1783
				if deleteAsset(path) then -- 1784
					return { -- 1784
						success = true -- 1784
					} -- 1784
				end -- 1784
			end -- 1783
		end -- 1783
	end -- 1783
	return { -- 1782
		success = false -- 1782
	} -- 1782
end) -- 1782
HttpServer:post("/rename", function(req) -- 1786
	do -- 1787
		local _type_0 = type(req) -- 1787
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1787
		if _tab_0 then -- 1787
			local old -- 1787
			do -- 1787
				local _obj_0 = req.body -- 1787
				local _type_1 = type(_obj_0) -- 1787
				if "table" == _type_1 or "userdata" == _type_1 then -- 1787
					old = _obj_0.old -- 1787
				end -- 1787
			end -- 1787
			local new -- 1787
			do -- 1787
				local _obj_0 = req.body -- 1787
				local _type_1 = type(_obj_0) -- 1787
				if "table" == _type_1 or "userdata" == _type_1 then -- 1787
					new = _obj_0.new -- 1787
				end -- 1787
			end -- 1787
			if old ~= nil and new ~= nil then -- 1787
				if moveAsset(old, new) then -- 1788
					return { -- 1788
						success = true -- 1788
					} -- 1788
				end -- 1788
			end -- 1787
		end -- 1787
	end -- 1787
	return { -- 1786
		success = false -- 1786
	} -- 1786
end) -- 1786
local normalizeAssetPaths -- 1790
normalizeAssetPaths = function(paths) -- 1790
	if not (type(paths) == "table") then -- 1791
		return nil -- 1791
	end -- 1791
	local unique = { } -- 1792
	local candidates = { } -- 1793
	for _index_0 = 1, #paths do -- 1794
		local path = paths[_index_0] -- 1794
		if not (type(path) == "string") then -- 1795
			return nil -- 1795
		end -- 1795
		local relative = relativeToRoot(path, Content.writablePath) -- 1796
		if relative == nil or relative == "" or not Content:exist(path) then -- 1797
			return nil -- 1797
		end -- 1797
		if not unique[path] then -- 1798
			unique[path] = true -- 1799
			candidates[#candidates + 1] = path -- 1800
		end -- 1798
	end -- 1794
	table.sort(candidates, function(a, b) -- 1801
		return #a < #b -- 1801
	end) -- 1801
	local result = { } -- 1802
	for _index_0 = 1, #candidates do -- 1803
		local path = candidates[_index_0] -- 1803
		local contained = false -- 1804
		for _index_1 = 1, #result do -- 1805
			local parent = result[_index_1] -- 1805
			if relativeToRoot(path, parent) ~= nil then -- 1806
				contained = true -- 1807
				break -- 1808
			end -- 1806
		end -- 1805
		if not contained then -- 1809
			result[#result + 1] = path -- 1809
		end -- 1809
	end -- 1803
	return result -- 1810
end -- 1790
HttpServer:postSchedule("/assets/batch", function(req) -- 1812
	do -- 1813
		local _type_0 = type(req) -- 1813
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1813
		if _tab_0 then -- 1813
			local operation -- 1813
			do -- 1813
				local _obj_0 = req.body -- 1813
				local _type_1 = type(_obj_0) -- 1813
				if "table" == _type_1 or "userdata" == _type_1 then -- 1813
					operation = _obj_0.operation -- 1813
				end -- 1813
			end -- 1813
			local sources -- 1813
			do -- 1813
				local _obj_0 = req.body -- 1813
				local _type_1 = type(_obj_0) -- 1813
				if "table" == _type_1 or "userdata" == _type_1 then -- 1813
					sources = _obj_0.sources -- 1813
				end -- 1813
			end -- 1813
			if operation ~= nil and sources ~= nil then -- 1813
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1814
					return { -- 1814
						success = false, -- 1814
						message = "invalid operation" -- 1814
					} -- 1814
				end -- 1814
				sources = normalizeAssetPaths(sources) -- 1815
				if not (sources and #sources > 0) then -- 1816
					return { -- 1816
						success = false, -- 1816
						message = "invalid sources" -- 1816
					} -- 1816
				end -- 1816
				local target = req.body.target -- 1817
				local destinations = { } -- 1818
				if operation ~= "delete" then -- 1819
					if not (type(target) == "string") then -- 1820
						return { -- 1820
							success = false, -- 1820
							message = "invalid target" -- 1820
						} -- 1820
					end -- 1820
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1821
					if targetRelative == nil then -- 1822
						return { -- 1822
							success = false, -- 1822
							message = "invalid target" -- 1822
						} -- 1822
					end -- 1822
					if not (Content:exist(target) and Content:isdir(target)) then -- 1823
						return { -- 1823
							success = false, -- 1823
							message = "invalid target" -- 1823
						} -- 1823
					end -- 1823
					for _index_0 = 1, #sources do -- 1824
						local source = sources[_index_0] -- 1824
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1825
							return { -- 1826
								success = false, -- 1826
								message = "target inside source" -- 1826
							} -- 1826
						end -- 1825
						local destination = Path(target, Path:getFilename(source)) -- 1827
						if Content:exist(destination) then -- 1828
							return { -- 1828
								success = false, -- 1828
								message = "target existed" -- 1828
							} -- 1828
						end -- 1828
						if destinations[destination] then -- 1829
							return { -- 1829
								success = false, -- 1829
								message = "duplicate target" -- 1829
							} -- 1829
						end -- 1829
						destinations[destination] = true -- 1830
					end -- 1824
				end -- 1819
				local changes = { } -- 1831
				local affectedSet = { } -- 1832
				local affectedDirectories = { } -- 1833
				local addAffected -- 1834
				addAffected = function(dir) -- 1834
					if affectedSet[dir] then -- 1835
						return -- 1835
					end -- 1835
					affectedSet[dir] = true -- 1836
					affectedDirectories[#affectedDirectories + 1] = dir -- 1837
				end -- 1834
				if operation ~= "delete" then -- 1838
					addAffected(target) -- 1838
				end -- 1838
				for _index_0 = 1, #sources do -- 1839
					local source = sources[_index_0] -- 1839
					addAffected(Path:getPath(source)) -- 1840
					if operation == "delete" then -- 1841
						if not deleteAsset(source) then -- 1842
							return { -- 1842
								success = false, -- 1842
								message = "delete failed", -- 1842
								changes = changes, -- 1842
								affectedDirectories = affectedDirectories -- 1842
							} -- 1842
						end -- 1842
						changes[#changes + 1] = { -- 1843
							old = source -- 1843
						} -- 1843
					else -- 1845
						local destination = Path(target, Path:getFilename(source)) -- 1845
						local ok -- 1846
						if operation == "copy" then -- 1846
							ok = Content:copyAsync(source, destination) -- 1847
						else -- 1849
							ok = moveAsset(source, destination) -- 1849
						end -- 1846
						if not ok then -- 1850
							return { -- 1850
								success = false, -- 1850
								message = operation .. " failed", -- 1850
								changes = changes, -- 1850
								affectedDirectories = affectedDirectories -- 1850
							} -- 1850
						end -- 1850
						changes[#changes + 1] = { -- 1851
							old = source, -- 1851
							new = destination -- 1851
						} -- 1851
					end -- 1841
				end -- 1839
				return { -- 1852
					success = true, -- 1852
					changes = changes, -- 1852
					affectedDirectories = affectedDirectories -- 1852
				} -- 1852
			end -- 1813
		end -- 1813
	end -- 1813
	return { -- 1812
		success = false, -- 1812
		message = "invalid request" -- 1812
	} -- 1812
end) -- 1812
local withProjectSearchPaths -- 1854
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1854
	local fallbackPaths = { } -- 1855
	local addFallback -- 1856
	addFallback = function(dir) -- 1856
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1856
			fallbackPaths[#fallbackPaths + 1] = dir -- 1856
		end -- 1856
	end -- 1856
	if projectRoot and projectRoot ~= "" then -- 1857
		addFallback(Path(projectRoot, "Script")) -- 1858
		addFallback(projectRoot) -- 1859
	end -- 1857
	if projFile then -- 1860
		local projDir = getProjectDirFromFile(projFile) -- 1861
		if projDir then -- 1861
			addFallback(Path(projDir, "Script")) -- 1862
			addFallback(projDir) -- 1863
		else -- 1865
			addFallback(Path:getPath(projFile)) -- 1865
		end -- 1861
	end -- 1860
	if not (#fallbackPaths > 0) then -- 1866
		return fn() -- 1866
	end -- 1866
	local searchPaths = Content.searchPaths -- 1867
	for _index_0 = 1, #fallbackPaths do -- 1868
		local dir = fallbackPaths[_index_0] -- 1868
		Content:addSearchPath(dir) -- 1868
	end -- 1868
	local _ <close> = setmetatable({ }, { -- 1869
		__close = function() -- 1869
			Content.searchPaths = searchPaths -- 1869
		end -- 1869
	}) -- 1869
	return fn() -- 1870
end -- 1854
HttpServer:post("/exist", function(req) -- 1871
	do -- 1872
		local _type_0 = type(req) -- 1872
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1872
		if _tab_0 then -- 1872
			local file -- 1872
			do -- 1872
				local _obj_0 = req.body -- 1872
				local _type_1 = type(_obj_0) -- 1872
				if "table" == _type_1 or "userdata" == _type_1 then -- 1872
					file = _obj_0.file -- 1872
				end -- 1872
			end -- 1872
			if file ~= nil then -- 1872
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1873
					return { -- 1874
						success = Content:exist(file) -- 1874
					} -- 1874
				end) -- 1873
			end -- 1872
		end -- 1872
	end -- 1872
	return { -- 1871
		success = false -- 1871
	} -- 1871
end) -- 1871
HttpServer:postSchedule("/read", function(req) -- 1875
	do -- 1876
		local _type_0 = type(req) -- 1876
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1876
		if _tab_0 then -- 1876
			local path -- 1876
			do -- 1876
				local _obj_0 = req.body -- 1876
				local _type_1 = type(_obj_0) -- 1876
				if "table" == _type_1 or "userdata" == _type_1 then -- 1876
					path = _obj_0.path -- 1876
				end -- 1876
			end -- 1876
			if path ~= nil then -- 1876
				local readFile -- 1877
				readFile = function() -- 1877
					if Content:exist(path) and not Content:isdir(path) then -- 1878
						local content = Content:loadAsync(path) -- 1879
						if content then -- 1879
							return { -- 1880
								content = content, -- 1880
								success = true, -- 1880
								fullPath = Content:getFullPath(path) -- 1880
							} -- 1880
						end -- 1879
					end -- 1878
					return nil -- 1877
				end -- 1877
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1881
				if result then -- 1881
					return result -- 1881
				end -- 1881
			end -- 1876
		end -- 1876
	end -- 1876
	return { -- 1875
		success = false -- 1875
	} -- 1875
end) -- 1875
local agentDocLanguage -- 1883
agentDocLanguage = function(language) -- 1883
	if language == "zh-Hans" then -- 1884
		return "zh" -- 1884
	else -- 1884
		return "en" -- 1884
	end -- 1884
end -- 1883
HttpServer:postSchedule("/doc/search", function(req) -- 1886
	local body = req.body or { } -- 1887
	local language = body.docLanguage -- 1888
	if not (("en" == language or "zh-Hans" == language)) then -- 1889
		return { -- 1889
			success = false, -- 1889
			message = "unsupported doc language" -- 1889
		} -- 1889
	end -- 1889
	local docType = body.docType -- 1890
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1891
		return { -- 1891
			success = false, -- 1891
			message = "unsupported doc type" -- 1891
		} -- 1891
	end -- 1891
	local codeLanguage = body.programmingLanguage -- 1892
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1893
		return { -- 1893
			success = false, -- 1893
			message = "unsupported programming language" -- 1893
		} -- 1893
	end -- 1893
	if not body.pattern then -- 1894
		return { -- 1894
			success = false, -- 1894
			message = "missing pattern" -- 1894
		} -- 1894
	end -- 1894
	local result = nil -- 1895
	AgentTools.searchDoraDocHttp({ -- 1897
		pattern = body.pattern, -- 1897
		docLanguage = agentDocLanguage(language), -- 1898
		docType = docType, -- 1899
		programmingLanguage = codeLanguage, -- 1900
		limit = body.limit, -- 1901
		useRegex = body.useRegex, -- 1902
		caseSensitive = body.caseSensitive, -- 1903
		includeContent = body.includeContent, -- 1904
		contentWindow = body.contentWindow -- 1905
	}, function(res) -- 1906
		result = res -- 1907
	end) -- 1896
	wait(function() -- 1908
		return result ~= nil -- 1908
	end) -- 1908
	if result and result.success then -- 1909
		result.docLanguage = language -- 1910
	end -- 1909
	if result then -- 1911
		return result -- 1912
	else -- 1914
		return { -- 1914
			success = false, -- 1914
			message = "doc search failed" -- 1914
		} -- 1914
	end -- 1911
	return { -- 1886
		success = false, -- 1886
		message = "invalid call" -- 1886
	} -- 1886
end) -- 1886
HttpServer:postSchedule("/doc/read", function(req) -- 1916
	local body = req.body or { } -- 1917
	local language = body.docLanguage -- 1918
	if not (("en" == language or "zh-Hans" == language)) then -- 1919
		return { -- 1919
			success = false, -- 1919
			message = "unsupported doc language" -- 1919
		} -- 1919
	end -- 1919
	if not body.file then -- 1920
		return { -- 1920
			success = false, -- 1920
			message = "missing file" -- 1920
		} -- 1920
	end -- 1920
	local result = AgentTools.readDoraDoc({ -- 1922
		docLanguage = agentDocLanguage(language), -- 1922
		file = body.file, -- 1923
		startLine = body.startLine, -- 1924
		endLine = body.endLine -- 1925
	}) -- 1921
	if result and result.success then -- 1926
		result.docLanguage = language -- 1927
	end -- 1926
	return result -- 1928
end) -- 1916
HttpServer:get("/read-sync", function(req) -- 1930
	do -- 1931
		local _type_0 = type(req) -- 1931
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1931
		if _tab_0 then -- 1931
			local params = req.params -- 1931
			if params ~= nil then -- 1931
				local path = params.path -- 1932
				if not (type(path) == "string" and path ~= "") then -- 1933
					return { -- 1933
						success = false, -- 1933
						message = "invalid path" -- 1933
					} -- 1933
				end -- 1933
				local exts -- 1934
				if params.exts then -- 1934
					local _accum_0 = { } -- 1935
					local _len_0 = 1 -- 1935
					for ext in params.exts:gmatch("[^|]*") do -- 1935
						_accum_0[_len_0] = ext -- 1935
						_len_0 = _len_0 + 1 -- 1935
					end -- 1935
					exts = _accum_0 -- 1935
				else -- 1936
					exts = { -- 1936
						"" -- 1936
					} -- 1936
				end -- 1934
				local readFileAt -- 1937
				readFileAt = function(targetPath) -- 1937
					if Content:exist(targetPath) then -- 1938
						local content = Content:load(targetPath) -- 1939
						if content then -- 1939
							return { -- 1940
								content = content, -- 1940
								success = true, -- 1940
								fullPath = Content:getFullPath(targetPath) -- 1940
							} -- 1940
						end -- 1939
					end -- 1938
					return nil -- 1937
				end -- 1937
				local readFile -- 1941
				readFile = function(fallbackPaths) -- 1941
					for _index_0 = 1, #exts do -- 1942
						local ext = exts[_index_0] -- 1942
						local targetPath = path .. ext -- 1943
						if not Content:isAbsolutePath(targetPath) then -- 1944
							for _index_1 = 1, #fallbackPaths do -- 1945
								local fallback = fallbackPaths[_index_1] -- 1945
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1946
								if fallbackResult then -- 1946
									return fallbackResult -- 1947
								end -- 1946
							end -- 1945
						end -- 1944
						local fileResult = readFileAt(targetPath) -- 1948
						if fileResult then -- 1948
							return fileResult -- 1949
						end -- 1948
					end -- 1942
					return nil -- 1941
				end -- 1941
				local fallbackPaths = { } -- 1950
				local fallbackCandidates = { } -- 1951
				do -- 1952
					local projectRoot = req.params.projectRoot -- 1952
					if projectRoot then -- 1952
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1953
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1954
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1955
						end -- 1953
					end -- 1952
				end -- 1952
				do -- 1956
					local projFile = req.params.projFile -- 1956
					if projFile then -- 1956
						local projDir = getProjectDirFromFile(projFile) -- 1957
						if projDir then -- 1957
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1958
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1959
						else -- 1961
							projDir = Path:getPath(projFile) -- 1961
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1962
						end -- 1957
					end -- 1956
				end -- 1956
				for _index_0 = 1, #fallbackCandidates do -- 1963
					local dir = fallbackCandidates[_index_0] -- 1963
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1964
						local exists = false -- 1965
						for _index_1 = 1, #fallbackPaths do -- 1966
							local fallback = fallbackPaths[_index_1] -- 1966
							if fallback == dir then -- 1967
								exists = true -- 1968
								break -- 1969
							end -- 1967
						end -- 1966
						if not exists then -- 1970
							fallbackPaths[#fallbackPaths + 1] = dir -- 1970
						end -- 1970
					end -- 1964
				end -- 1963
				local readResult = readFile(fallbackPaths) -- 1971
				if readResult then -- 1971
					return readResult -- 1972
				end -- 1971
			end -- 1931
		end -- 1931
	end -- 1931
	return { -- 1930
		success = false -- 1930
	} -- 1930
end) -- 1930
local addGeneratedSourceHeader -- 1974
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 1974
	if preserveTIC80 == nil then -- 1974
		preserveTIC80 = false -- 1974
	end -- 1974
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 1975
	if preserveTIC80 then -- 1976
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 1977
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 1978
		end -- 1977
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 1979
	end -- 1976
	return tostring(header) .. "\n" .. tostring(codes) -- 1980
end -- 1974
local compileFileAsync -- 1982
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1982
	if projectRoot == nil then -- 1982
		projectRoot = nil -- 1982
	end -- 1982
	local file = inputFile -- 1983
	local searchPath -- 1984
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1984
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1985
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1989
	elseif not Content:isAbsolutePath(inputFile) then -- 1990
		searchPath = "" -- 1991
	else -- 1992
		local dir = getProjectDirFromFile(inputFile) -- 1992
		if dir then -- 1992
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1993
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1997
		else -- 1999
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1999
			searchPath = "" -- 2002
		end -- 1992
	end -- 1984
	local outputFile = Path:replaceExt(inputFile, "lua") -- 2003
	local yueext = yue.options.extension -- 2004
	local resultCodes = nil -- 2005
	local resultError = nil -- 2006
	do -- 2007
		local _exp_0 = Path:getExt(inputFile) -- 2007
		if yueext == _exp_0 then -- 2007
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 2008
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 2009
				if not codes then -- 2010
					resultError = err -- 2011
					return -- 2012
				end -- 2010
				local extraGlobal -- 2013
				if isTIC80 then -- 2013
					extraGlobal = tic80APIs -- 2013
				else -- 2013
					extraGlobal = nil -- 2013
				end -- 2013
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 2014
				if not success then -- 2015
					resultError = message -- 2016
					return -- 2017
				end -- 2015
				if codes == "" then -- 2018
					resultCodes = "" -- 2019
					return nil -- 2020
				end -- 2018
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 2021
				return resultCodes -- 2022
			end, function(success) -- 2009
				if not success then -- 2023
					Content:remove(outputFile) -- 2024
					if resultCodes == nil then -- 2025
						resultCodes = false -- 2026
					end -- 2025
				end -- 2023
			end) -- 2009
		elseif "tl" == _exp_0 then -- 2027
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 2028
			if isTIC80 then -- 2029
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2030
			end -- 2029
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2031
			if codes then -- 2031
				if isTIC80 then -- 2032
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2033
				end -- 2032
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2034
				Content:saveAsync(outputFile, resultCodes) -- 2035
			else -- 2037
				Content:remove(outputFile) -- 2037
				resultCodes = false -- 2038
				resultError = err -- 2039
			end -- 2031
		elseif "xml" == _exp_0 then -- 2040
			local codes, err = xml.tolua(sourceCodes) -- 2041
			if codes then -- 2041
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2042
				Content:saveAsync(outputFile, resultCodes) -- 2043
			else -- 2045
				Content:remove(outputFile) -- 2045
				resultCodes = false -- 2046
				resultError = err -- 2047
			end -- 2041
		end -- 2007
	end -- 2007
	wait(function() -- 2048
		return resultCodes ~= nil -- 2048
	end) -- 2048
	if resultCodes then -- 2049
		return resultCodes -- 2050
	else -- 2052
		return nil, resultError -- 2052
	end -- 2049
	return nil -- 1982
end -- 1982
HttpServer:postSchedule("/write", function(req) -- 2054
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
			local content -- 2058
			do -- 2058
				local _obj_0 = req.body -- 2058
				local _type_1 = type(_obj_0) -- 2058
				if "table" == _type_1 or "userdata" == _type_1 then -- 2058
					content = _obj_0.content -- 2058
				end -- 2058
			end -- 2058
			if path ~= nil and content ~= nil then -- 2058
				if Content:saveAsync(path, content) then -- 2059
					do -- 2060
						local _exp_0 = Path:getExt(path) -- 2060
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2060
							if '' == Path:getExt(Path:getName(path)) then -- 2061
								local resultCodes = compileFileAsync(path, content) -- 2062
								buildSucceeded = resultCodes ~= nil -- 2063
								return { -- 2064
									success = true, -- 2064
									resultCodes = resultCodes -- 2064
								} -- 2064
							end -- 2061
						end -- 2060
					end -- 2060
					buildSucceeded = true -- 2065
					return { -- 2066
						success = true -- 2066
					} -- 2066
				end -- 2059
			end -- 2058
		end -- 2058
	end -- 2058
	return { -- 2054
		success = false -- 2054
	} -- 2054
end) -- 2054
local getWaProjectDirFromFile = nil -- 2068
HttpServer:postSchedule("/build", function(req) -- 2070
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2071
	local buildSucceeded = false -- 2072
	local _ <close> = setmetatable({ }, { -- 2073
		__close = function() -- 2073
			return finishUpdate(buildSucceeded) -- 2073
		end -- 2073
	}) -- 2073
	do -- 2074
		local _type_0 = type(req) -- 2074
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2074
		if _tab_0 then -- 2074
			local path -- 2074
			do -- 2074
				local _obj_0 = req.body -- 2074
				local _type_1 = type(_obj_0) -- 2074
				if "table" == _type_1 or "userdata" == _type_1 then -- 2074
					path = _obj_0.path -- 2074
				end -- 2074
			end -- 2074
			if path ~= nil then -- 2074
				local projectRoot = req.body.projectRoot -- 2075
				if Content:isdir(path) then -- 2076
					local projDir = getWaProjectDirFromFile(path) -- 2077
					if projDir then -- 2077
						local message = Wasm:buildWaAsync(projDir) -- 2078
						if message == "" then -- 2079
							return { -- 2080
								success = true -- 2080
							} -- 2080
						else -- 2082
							return { -- 2082
								success = false, -- 2082
								message = message -- 2082
							} -- 2082
						end -- 2079
					end -- 2077
				end -- 2076
				local _exp_0 = Path:getExt(path) -- 2083
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2084
					if '' == Path:getExt(Path:getName(path)) then -- 2085
						local content = Content:loadAsync(path) -- 2086
						if content then -- 2086
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2087
							if resultCodes then -- 2087
								buildSucceeded = true -- 2088
								return { -- 2089
									success = true, -- 2089
									resultCodes = resultCodes -- 2089
								} -- 2089
							end -- 2087
						end -- 2086
					end -- 2085
				elseif "wa" == _exp_0 then -- 2090
					local projDir = getWaProjectDirFromFile(path) -- 2091
					if projDir then -- 2091
						local message = Wasm:buildWaAsync(projDir) -- 2092
						if message == "" then -- 2093
							return { -- 2094
								success = true -- 2094
							} -- 2094
						else -- 2096
							return { -- 2096
								success = false, -- 2096
								message = message -- 2096
							} -- 2096
						end -- 2093
					else -- 2098
						return { -- 2098
							success = false, -- 2098
							message = 'Wa file needs a project' -- 2098
						} -- 2098
					end -- 2091
				end -- 2083
			end -- 2074
		end -- 2074
	end -- 2074
	return { -- 2070
		success = false -- 2070
	} -- 2070
end) -- 2070
local extentionLevels = { -- 2101
	vs = 2, -- 2101
	bl = 2, -- 2102
	ts = 1, -- 2103
	tsx = 1, -- 2104
	tl = 1, -- 2105
	yue = 1, -- 2106
	xml = 1, -- 2107
	lua = 0 -- 2108
} -- 2100
local visitAssets -- 2110
visitAssets = function(path, workspace, builtin, recursive) -- 2110
	if recursive == nil then -- 2110
		recursive = true -- 2110
	end -- 2110
	local children = nil -- 2111
	local dirs = Content:getDirs(path) -- 2112
	for _index_0 = 1, #dirs do -- 2113
		local dir = dirs[_index_0] -- 2113
		if workspace then -- 2114
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 2115
				goto _continue_0 -- 2116
			end -- 2115
		elseif dir == ".git" then -- 2117
			goto _continue_0 -- 2118
		end -- 2114
		if not children then -- 2119
			children = { } -- 2119
		end -- 2119
		local dirPath = Path(path, dir) -- 2120
		if recursive then -- 2121
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2122
		else -- 2124
			children[#children + 1] = { -- 2125
				key = dirPath, -- 2125
				dir = true, -- 2126
				title = dir, -- 2127
				builtin = builtin, -- 2128
				isLeaf = false -- 2129
			} -- 2124
		end -- 2121
		::_continue_0:: -- 2114
	end -- 2113
	local files = Content:getFiles(path) -- 2131
	local names = { } -- 2132
	for _index_0 = 1, #files do -- 2133
		local file = files[_index_0] -- 2133
		if (".DS_Store" == file) then -- 2134
			goto _continue_1 -- 2135
		end -- 2134
		local name = Path:getName(file) -- 2136
		local ext = names[name] -- 2137
		if ext then -- 2137
			local lv1 -- 2138
			do -- 2138
				local _exp_0 = extentionLevels[ext] -- 2138
				if _exp_0 ~= nil then -- 2138
					lv1 = _exp_0 -- 2138
				else -- 2138
					lv1 = -1 -- 2138
				end -- 2138
			end -- 2138
			ext = Path:getExt(file) -- 2139
			local lv2 -- 2140
			do -- 2140
				local _exp_0 = extentionLevels[ext] -- 2140
				if _exp_0 ~= nil then -- 2140
					lv2 = _exp_0 -- 2140
				else -- 2140
					lv2 = -1 -- 2140
				end -- 2140
			end -- 2140
			if lv2 > lv1 then -- 2141
				names[name] = ext -- 2142
			elseif lv2 == lv1 then -- 2143
				names[name .. '.' .. ext] = "" -- 2144
			end -- 2141
		else -- 2146
			ext = Path:getExt(file) -- 2146
			if not extentionLevels[ext] then -- 2147
				names[file] = "" -- 2148
			else -- 2150
				names[name] = ext -- 2150
			end -- 2147
		end -- 2137
		::_continue_1:: -- 2134
	end -- 2133
	do -- 2151
		local _accum_0 = { } -- 2151
		local _len_0 = 1 -- 2151
		for name, ext in pairs(names) do -- 2151
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2151
			_len_0 = _len_0 + 1 -- 2151
		end -- 2151
		files = _accum_0 -- 2151
	end -- 2151
	for _index_0 = 1, #files do -- 2152
		local file = files[_index_0] -- 2152
		if not children then -- 2153
			children = { } -- 2153
		end -- 2153
		children[#children + 1] = { -- 2155
			key = Path(path, file), -- 2155
			dir = false, -- 2156
			title = file, -- 2157
			builtin = builtin -- 2158
		} -- 2154
	end -- 2152
	if children then -- 2160
		table.sort(children, function(a, b) -- 2161
			if a.dir == b.dir then -- 2162
				return a.title < b.title -- 2163
			else -- 2165
				return a.dir -- 2165
			end -- 2162
		end) -- 2161
	end -- 2160
	return { -- 2167
		key = path, -- 2167
		dir = true, -- 2168
		title = Path:getFilename(path), -- 2169
		builtin = builtin, -- 2170
		isLeaf = not children, -- 2171
		children = children -- 2172
	} -- 2166
end -- 2110
HttpServer:post("/assets/children", function(req) -- 2175
	do -- 2176
		local _type_0 = type(req) -- 2176
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2176
		if _tab_0 then -- 2176
			local path -- 2176
			do -- 2176
				local _obj_0 = req.body -- 2176
				local _type_1 = type(_obj_0) -- 2176
				if "table" == _type_1 or "userdata" == _type_1 then -- 2176
					path = _obj_0.path -- 2176
				end -- 2176
			end -- 2176
			if path ~= nil then -- 2176
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2177
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2178
					return { -- 2178
						success = false -- 2178
					} -- 2178
				end -- 2178
				local node = visitAssets(path, workspace, builtin, false) -- 2179
				return { -- 2180
					success = true, -- 2180
					children = node.children or { } -- 2180
				} -- 2180
			end -- 2176
		end -- 2176
	end -- 2176
	return { -- 2175
		success = false -- 2175
	} -- 2175
end) -- 2175
HttpServer:post("/assets/files", function(req) -- 2182
	do -- 2183
		local _type_0 = type(req) -- 2183
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2183
		if _tab_0 then -- 2183
			local path -- 2183
			do -- 2183
				local _obj_0 = req.body -- 2183
				local _type_1 = type(_obj_0) -- 2183
				if "table" == _type_1 or "userdata" == _type_1 then -- 2183
					path = _obj_0.path -- 2183
				end -- 2183
			end -- 2183
			if path ~= nil then -- 2183
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2184
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2185
				if not (workspace or builtin) then -- 2186
					return { -- 2186
						success = false -- 2186
					} -- 2186
				end -- 2186
				if not (Content:exist(path) and Content:isdir(path)) then -- 2187
					return { -- 2187
						success = false -- 2187
					} -- 2187
				end -- 2187
				local globs = { -- 2188
					"**", -- 2188
					"!**/.DS_Store" -- 2188
				} -- 2188
				if workspace then -- 2189
					globs = { -- 2191
						"**", -- 2191
						"!**/.DS_Store", -- 2191
						"!**/.upload/**", -- 2192
						"!**/.download/**", -- 2192
						"!**/.www/**", -- 2193
						"!**/.build/**", -- 2193
						"!**/.git/**", -- 2194
						"!**/.cache/**", -- 2194
						"!**/node_modules/**" -- 2195
					} -- 2190
				end -- 2189
				local files -- 2197
				do -- 2197
					local _accum_0 = { } -- 2197
					local _len_0 = 1 -- 2197
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2197
					for _index_0 = 1, #_list_0 do -- 2197
						local file = _list_0[_index_0] -- 2197
						_accum_0[_len_0] = Path(path, file) -- 2197
						_len_0 = _len_0 + 1 -- 2197
					end -- 2197
					files = _accum_0 -- 2197
				end -- 2197
				return { -- 2198
					success = true, -- 2198
					files = files -- 2198
				} -- 2198
			end -- 2183
		end -- 2183
	end -- 2183
	return { -- 2182
		success = false -- 2182
	} -- 2182
end) -- 2182
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2239
	local _tab_0 = { -- 2239
		{ -- 2240
			key = Path(Content.assetPath), -- 2240
			dir = true, -- 2241
			builtin = true, -- 2242
			title = zh and "内置资源" or "Built-in", -- 2243
			children = builtinChildren -- 2244
		} -- 2239
	} -- 2246
	local _obj_0 = workspace.children or { } -- 2246
	local _idx_0 = #_tab_0 + 1 -- 2246
	for _index_0 = 1, #_obj_0 do -- 2246
		local _value_0 = _obj_0[_index_0] -- 2246
		_tab_0[_idx_0] = _value_0 -- 2246
		_idx_0 = _idx_0 + 1 -- 2246
	end -- 2246
	return _tab_0 -- 2239
end -- 2239
HttpServer:post("/assets", function() -- 2200
	local Entry = require("Script.Dev.Entry") -- 2201
	local engineDev = Entry.getEngineDev() -- 2202
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2203
	local zh = (App.locale:match("^zh") ~= nil) -- 2204
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2205
	readme.title = zh and "说明文档" or "Readme" -- 2206
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2207
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2208
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2209
	tools.title = zh and "开发工具" or "Tools" -- 2210
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2211
	font.title = zh and "字体" or "Font" -- 2212
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2213
	lib.title = zh and "程序库" or "Lib" -- 2214
	if engineDev then -- 2215
		local _list_0 = lib.children -- 2216
		for _index_0 = 1, #_list_0 do -- 2216
			local child = _list_0[_index_0] -- 2216
			if not (child.title == "Dora") then -- 2217
				goto _continue_0 -- 2217
			end -- 2217
			local title = zh and "zh-Hans" or "en" -- 2218
			do -- 2219
				local _accum_0 = { } -- 2219
				local _len_0 = 1 -- 2219
				local _list_1 = child.children -- 2219
				for _index_1 = 1, #_list_1 do -- 2219
					local c = _list_1[_index_1] -- 2219
					if c.title ~= title then -- 2219
						_accum_0[_len_0] = c -- 2219
						_len_0 = _len_0 + 1 -- 2219
					end -- 2219
				end -- 2219
				child.children = _accum_0 -- 2219
			end -- 2219
			break -- 2220
			::_continue_0:: -- 2217
		end -- 2216
	else -- 2222
		local _accum_0 = { } -- 2222
		local _len_0 = 1 -- 2222
		local _list_0 = lib.children -- 2222
		for _index_0 = 1, #_list_0 do -- 2222
			local child = _list_0[_index_0] -- 2222
			if child.title ~= "Dora" then -- 2222
				_accum_0[_len_0] = child -- 2222
				_len_0 = _len_0 + 1 -- 2222
			end -- 2222
		end -- 2222
		lib.children = _accum_0 -- 2222
	end -- 2215
	local builtinChildren = { -- 2223
		readme, -- 2223
		apiDoc, -- 2223
		tools, -- 2223
		font, -- 2223
		lib -- 2223
	} -- 2223
	if engineDev then -- 2224
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2225
		do -- 2226
			local _obj_0 = dev.children -- 2226
			_obj_0[#_obj_0 + 1] = { -- 2227
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2227
				dir = false, -- 2228
				builtin = true, -- 2229
				title = "init.yue" -- 2230
			} -- 2226
		end -- 2226
		builtinChildren[#builtinChildren + 1] = dev -- 2232
	end -- 2224
	return { -- 2234
		key = Content.writablePath, -- 2234
		dir = true, -- 2235
		root = true, -- 2236
		title = "Assets", -- 2237
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2238
	} -- 2233
end) -- 2200
HttpServer:post("/entry/list", function(req) -- 2250
	local Entry = require("Script.Dev.Entry") -- 2251
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2252
	res.success = true -- 2253
	return res -- 2254
end) -- 2250
HttpServer:post("/run/status", function() -- 2256
	local Entry = require("Script.Dev.Entry") -- 2257
	return Entry.getCurrentEntryStatus() -- 2258
end) -- 2256
HttpServer:postSchedule("/run", function(req) -- 2260
	do -- 2261
		local _type_0 = type(req) -- 2261
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2261
		if _tab_0 then -- 2261
			local file -- 2261
			do -- 2261
				local _obj_0 = req.body -- 2261
				local _type_1 = type(_obj_0) -- 2261
				if "table" == _type_1 or "userdata" == _type_1 then -- 2261
					file = _obj_0.file -- 2261
				end -- 2261
			end -- 2261
			local asProj -- 2261
			do -- 2261
				local _obj_0 = req.body -- 2261
				local _type_1 = type(_obj_0) -- 2261
				if "table" == _type_1 or "userdata" == _type_1 then -- 2261
					asProj = _obj_0.asProj -- 2261
				end -- 2261
			end -- 2261
			if file ~= nil and asProj ~= nil then -- 2261
				if not Content:isAbsolutePath(file) then -- 2262
					local devFile = Path(Content.writablePath, file) -- 2263
					if Content:exist(devFile) then -- 2264
						file = devFile -- 2264
					end -- 2264
				end -- 2262
				local Entry = require("Script.Dev.Entry") -- 2265
				local workDir -- 2266
				if asProj then -- 2267
					local projectRoot = req.body.projectRoot -- 2268
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2269
						workDir = projectRoot -- 2270
					else -- 2272
						workDir = getProjectDirFromFile(file) -- 2272
					end -- 2269
					if workDir then -- 2273
						Entry.allClear() -- 2274
						local target = Path(workDir, "init") -- 2275
						local success, err = Entry.enterEntryAsync({ -- 2276
							entryName = "Project", -- 2276
							fileName = target, -- 2276
							workDir = workDir, -- 2276
							projectRoot = workDir, -- 2276
							runKind = "project" -- 2276
						}) -- 2276
						target = Path:getName(Path:getPath(target)) -- 2277
						return { -- 2278
							success = success, -- 2278
							target = target, -- 2278
							err = err -- 2278
						} -- 2278
					end -- 2273
				else -- 2280
					workDir = getProjectDirFromFile(file) -- 2280
					if not workDir and Path:getExt(file) == "wasm" then -- 2281
						local parent = Path:getPath(file) -- 2282
						if Content:exist(Path(parent, "wa.mod")) then -- 2283
							workDir = parent -- 2284
						end -- 2283
					end -- 2281
				end -- 2267
				Entry.allClear() -- 2285
				file = Path:replaceExt(file, "") -- 2286
				local entry = { -- 2288
					entryName = Path:getName(file), -- 2288
					fileName = file, -- 2289
					runKind = "file" -- 2290
				} -- 2287
				if workDir then -- 2291
					entry.workDir = workDir -- 2292
					entry.projectRoot = workDir -- 2293
				end -- 2291
				local success, err = Entry.enterEntryAsync(entry) -- 2294
				return { -- 2295
					success = success, -- 2295
					err = err -- 2295
				} -- 2295
			end -- 2261
		end -- 2261
	end -- 2261
	return { -- 2260
		success = false -- 2260
	} -- 2260
end) -- 2260
local _anon_func_7 = function(result) -- 2337
	if result.success then -- 2337
		return nil -- 2337
	else -- 2337
		return "PREVIEW_FAILED" -- 2337
	end -- 2337
end -- 2337
HttpServer:postSchedule("/agent/preview", function(req) -- 2297
	local releaseAgent = AgentHost.acquire() -- 2298
	local _ <close> = setmetatable({ }, { -- 2299
		__close = function() -- 2299
			return releaseAgent() -- 2299
		end -- 2299
	}) -- 2299
	do -- 2300
		local _type_0 = type(req) -- 2300
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2300
		if _tab_0 then -- 2300
			local projectRoot -- 2300
			do -- 2300
				local _obj_0 = req.body -- 2300
				local _type_1 = type(_obj_0) -- 2300
				if "table" == _type_1 or "userdata" == _type_1 then -- 2300
					projectRoot = _obj_0.projectRoot -- 2300
				end -- 2300
			end -- 2300
			if projectRoot ~= nil then -- 2300
				if not getProjectSourceRoot(projectRoot) then -- 2301
					return { -- 2301
						success = false, -- 2301
						code = "INVALID_PROJECT", -- 2301
						message = "projectRoot must be an existing absolute directory" -- 2301
					} -- 2301
				end -- 2301
				local entryFile = req.body.entry or "init.lua" -- 2302
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2303
					return { -- 2303
						success = false, -- 2303
						code = "INVALID_ENTRY", -- 2303
						message = "entry must be a non-empty project-relative path" -- 2303
					} -- 2303
				end -- 2303
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2304
					0.5 -- 2304
				} -- 2304
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2305
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2306
					return { -- 2306
						success = false, -- 2306
						code = "INVALID_QUEUE_TIMEOUT", -- 2306
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2306
					} -- 2306
				end -- 2306
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2307
				local AgentOperation = require("Agent.Tool.Operation") -- 2308
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2309
				local requestId = AgentOperation.createOperationId() -- 2310
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2311
				if not enqueued.success then -- 2312
					return { -- 2312
						success = false, -- 2312
						code = "ENTRY_QUEUE_REJECTED", -- 2312
						message = enqueued.message -- 2312
					} -- 2312
				end -- 2312
				local queuedAt = App.runningTime -- 2313
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2314
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2315
						local state = agentEntryRunQueue:get(requestId) -- 2316
						agentEntryRunQueue:cancel(requestId) -- 2317
						return { -- 2319
							success = false, -- 2319
							code = "ENTRY_QUEUE_TIMEOUT", -- 2320
							message = "timed out waiting for the Dora entry runtime", -- 2321
							requestId = requestId, -- 2322
							queuePosition = state.position -- 2323
						} -- 2318
					end -- 2315
					sleep() -- 2324
				end -- 2314
				local queueWaitSeconds = App.runningTime - queuedAt -- 2325
				local _ <close> = setmetatable({ }, { -- 2326
					__close = function() -- 2326
						return agentEntryRunQueue:release(requestId) -- 2326
					end -- 2326
				}) -- 2326
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2327
				local Entry = require("Script.Dev.Entry") -- 2328
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2330
					workDir = projectRoot, -- 2330
					operationId = requestId, -- 2331
					print = function() end -- 2332
				}, Entry) -- 2329
				local result = preview({ -- 2334
					entry = entryFile, -- 2334
					captureAtSeconds = captureAtSeconds -- 2334
				}) -- 2334
				return { -- 2336
					success = result.success, -- 2336
					code = _anon_func_7(result), -- 2337
					message = result.message, -- 2338
					requestId = requestId, -- 2339
					queueWaitSeconds = queueWaitSeconds, -- 2340
					interruptedUserRun = result.interruptedUserRun, -- 2341
					files = result.files, -- 2342
					frames = result.frames -- 2343
				} -- 2335
			end -- 2300
		end -- 2300
	end -- 2300
	return { -- 2297
		success = false, -- 2297
		message = "invalid call" -- 2297
	} -- 2297
end) -- 2297
HttpServer:postSchedule("/agent/command", function(req) -- 2345
	local releaseAgent = AgentHost.acquire() -- 2346
	local _ <close> = setmetatable({ }, { -- 2347
		__close = function() -- 2347
			return releaseAgent() -- 2347
		end -- 2347
	}) -- 2347
	do -- 2348
		local _type_0 = type(req) -- 2348
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2348
		if _tab_0 then -- 2348
			local body = req.body -- 2348
			if body ~= nil then -- 2348
				local projectRoot = body.projectRoot -- 2349
				if not getProjectSourceRoot(projectRoot) then -- 2350
					return { -- 2350
						success = false, -- 2350
						code = "INVALID_PROJECT", -- 2350
						message = "projectRoot must be an existing absolute directory" -- 2350
					} -- 2350
				end -- 2350
				local AgentValidation = require("Agent.Tool.Validation") -- 2351
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2352
				if not validated.success then -- 2353
					return { -- 2353
						success = false, -- 2353
						code = "INVALID_COMMAND", -- 2353
						message = validated.message -- 2353
					} -- 2353
				end -- 2353
				local input = validated.value -- 2354
				local AgentCommand = require("Agent.Tool.Command") -- 2355
				local result = nil -- 2356
				local failure = nil -- 2357
				local promise = AgentCommand.executeCommand({ -- 2359
					workDir = projectRoot, -- 2359
					mode = input.mode, -- 2360
					code = input.code, -- 2361
					command = input.command, -- 2362
					cwd = input.cwd, -- 2363
					timeoutSeconds = input.timeoutSeconds -- 2364
				}) -- 2358
				promise:addCallbacks((function(_, value) -- 2365
					result = value -- 2365
				end), (function(_, err) -- 2365
					failure = tostring(err) -- 2365
				end)) -- 2365
				wait(function() -- 2366
					return result ~= nil or failure ~= nil -- 2366
				end) -- 2366
				if failure then -- 2367
					return { -- 2367
						success = false, -- 2367
						code = "COMMAND_BRIDGE_FAILED", -- 2367
						message = failure -- 2367
					} -- 2367
				end -- 2367
				if not result.success then -- 2368
					result.code = "COMMAND_FAILED" -- 2369
				end -- 2368
				return result -- 2370
			end -- 2348
		end -- 2348
	end -- 2348
	return { -- 2345
		success = false, -- 2345
		code = "INVALID_COMMAND", -- 2345
		message = "invalid call" -- 2345
	} -- 2345
end) -- 2345
HttpServer:postSchedule("/stop", function() -- 2372
	local Entry = require("Script.Dev.Entry") -- 2373
	return { -- 2374
		success = Entry.stop() -- 2374
	} -- 2374
end) -- 2372
local minifyAsync -- 2376
minifyAsync = function(sourcePath, minifyPath) -- 2376
	if not Content:exist(sourcePath) then -- 2377
		return -- 2377
	end -- 2377
	local Entry = require("Script.Dev.Entry") -- 2378
	local errors = { } -- 2379
	local files = Entry.getAllFiles(sourcePath, { -- 2380
		"lua" -- 2380
	}, true) -- 2380
	do -- 2381
		local _accum_0 = { } -- 2381
		local _len_0 = 1 -- 2381
		for _index_0 = 1, #files do -- 2381
			local file = files[_index_0] -- 2381
			if file:sub(1, 1) ~= '.' then -- 2381
				_accum_0[_len_0] = file -- 2381
				_len_0 = _len_0 + 1 -- 2381
			end -- 2381
		end -- 2381
		files = _accum_0 -- 2381
	end -- 2381
	local paths -- 2382
	do -- 2382
		local _tbl_0 = { } -- 2382
		for _index_0 = 1, #files do -- 2382
			local file = files[_index_0] -- 2382
			_tbl_0[Path:getPath(file)] = true -- 2382
		end -- 2382
		paths = _tbl_0 -- 2382
	end -- 2382
	for path in pairs(paths) do -- 2383
		Content:mkdir(Path(minifyPath, path)) -- 2383
	end -- 2383
	local _ <close> = setmetatable({ }, { -- 2384
		__close = function() -- 2384
			package.loaded["luaminify.FormatMini"] = nil -- 2385
			package.loaded["luaminify.ParseLua"] = nil -- 2386
			package.loaded["luaminify.Scope"] = nil -- 2387
			package.loaded["luaminify.Util"] = nil -- 2388
		end -- 2384
	}) -- 2384
	local FormatMini -- 2389
	do -- 2389
		local _obj_0 = require("luaminify") -- 2389
		FormatMini = _obj_0.FormatMini -- 2389
	end -- 2389
	local fileCount = #files -- 2390
	local count = 0 -- 2391
	for _index_0 = 1, #files do -- 2392
		local file = files[_index_0] -- 2392
		thread(function() -- 2393
			local _ <close> = setmetatable({ }, { -- 2394
				__close = function() -- 2394
					count = count + 1 -- 2394
				end -- 2394
			}) -- 2394
			local input = Path(sourcePath, file) -- 2395
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2396
			if Content:exist(input) then -- 2397
				local sourceCodes = Content:loadAsync(input) -- 2398
				local res, err = FormatMini(sourceCodes) -- 2399
				if res then -- 2400
					Content:saveAsync(output, res) -- 2401
					return print("Minify " .. tostring(file)) -- 2402
				else -- 2404
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2404
				end -- 2400
			else -- 2406
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2406
			end -- 2397
		end) -- 2393
		sleep() -- 2407
	end -- 2392
	wait(function() -- 2408
		return count == fileCount -- 2408
	end) -- 2408
	if #errors > 0 then -- 2409
		print(table.concat(errors, '\n')) -- 2410
	end -- 2409
	print("Obfuscation done.") -- 2411
	return files -- 2412
end -- 2376
local zipping = false -- 2414
HttpServer:postSchedule("/zip", function(req) -- 2416
	do -- 2417
		local _type_0 = type(req) -- 2417
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2417
		if _tab_0 then -- 2417
			local path -- 2417
			do -- 2417
				local _obj_0 = req.body -- 2417
				local _type_1 = type(_obj_0) -- 2417
				if "table" == _type_1 or "userdata" == _type_1 then -- 2417
					path = _obj_0.path -- 2417
				end -- 2417
			end -- 2417
			local zipFile -- 2417
			do -- 2417
				local _obj_0 = req.body -- 2417
				local _type_1 = type(_obj_0) -- 2417
				if "table" == _type_1 or "userdata" == _type_1 then -- 2417
					zipFile = _obj_0.zipFile -- 2417
				end -- 2417
			end -- 2417
			local obfuscated -- 2417
			do -- 2417
				local _obj_0 = req.body -- 2417
				local _type_1 = type(_obj_0) -- 2417
				if "table" == _type_1 or "userdata" == _type_1 then -- 2417
					obfuscated = _obj_0.obfuscated -- 2417
				end -- 2417
			end -- 2417
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2417
				if zipping then -- 2418
					goto failed -- 2418
				end -- 2418
				zipping = true -- 2419
				local _ <close> = setmetatable({ }, { -- 2420
					__close = function() -- 2420
						zipping = false -- 2420
					end -- 2420
				}) -- 2420
				if not Content:exist(path) then -- 2421
					goto failed -- 2421
				end -- 2421
				Content:mkdir(Path:getPath(zipFile)) -- 2422
				if obfuscated then -- 2423
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2424
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2425
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2426
					Content:remove(scriptPath) -- 2427
					Content:remove(obfuscatedPath) -- 2428
					Content:remove(tempPath) -- 2429
					Content:mkdir(scriptPath) -- 2430
					Content:mkdir(obfuscatedPath) -- 2431
					Content:mkdir(tempPath) -- 2432
					if not Content:copyAsync(path, tempPath) then -- 2433
						goto failed -- 2433
					end -- 2433
					local Entry = require("Script.Dev.Entry") -- 2434
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2435
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2436
						"tl", -- 2436
						"yue", -- 2436
						"lua", -- 2436
						"ts", -- 2436
						"tsx", -- 2436
						"vs", -- 2436
						"bl", -- 2436
						"xml", -- 2436
						"wa", -- 2436
						"mod" -- 2436
					}, true) -- 2436
					for _index_0 = 1, #scriptFiles do -- 2437
						local file = scriptFiles[_index_0] -- 2437
						Content:remove(Path(tempPath, file)) -- 2438
					end -- 2437
					for _index_0 = 1, #luaFiles do -- 2439
						local file = luaFiles[_index_0] -- 2439
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2440
					end -- 2439
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2441
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2442
					end) then -- 2441
						goto failed -- 2441
					end -- 2441
					return { -- 2443
						success = true -- 2443
					} -- 2443
				else -- 2445
					return { -- 2445
						success = Content:zipAsync(path, zipFile, function(file) -- 2445
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2446
						end) -- 2445
					} -- 2445
				end -- 2423
			end -- 2417
		end -- 2417
	end -- 2417
	::failed:: -- 2447
	return { -- 2416
		success = false -- 2416
	} -- 2416
end) -- 2416
HttpServer:postSchedule("/unzip", function(req) -- 2449
	do -- 2450
		local _type_0 = type(req) -- 2450
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2450
		if _tab_0 then -- 2450
			local zipFile -- 2450
			do -- 2450
				local _obj_0 = req.body -- 2450
				local _type_1 = type(_obj_0) -- 2450
				if "table" == _type_1 or "userdata" == _type_1 then -- 2450
					zipFile = _obj_0.zipFile -- 2450
				end -- 2450
			end -- 2450
			local path -- 2450
			do -- 2450
				local _obj_0 = req.body -- 2450
				local _type_1 = type(_obj_0) -- 2450
				if "table" == _type_1 or "userdata" == _type_1 then -- 2450
					path = _obj_0.path -- 2450
				end -- 2450
			end -- 2450
			if zipFile ~= nil and path ~= nil then -- 2450
				return { -- 2451
					success = Content:unzipAsync(zipFile, path, function(file) -- 2451
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2452
					end) -- 2451
				} -- 2451
			end -- 2450
		end -- 2450
	end -- 2450
	return { -- 2449
		success = false -- 2449
	} -- 2449
end) -- 2449
HttpServer:post("/editing-info", function(req) -- 2454
	local Entry = require("Script.Dev.Entry") -- 2455
	local config = Entry.getConfig() -- 2456
	local _type_0 = type(req) -- 2457
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2457
	local _match_0 = false -- 2457
	if _tab_0 then -- 2457
		local editingInfo -- 2457
		do -- 2457
			local _obj_0 = req.body -- 2457
			local _type_1 = type(_obj_0) -- 2457
			if "table" == _type_1 or "userdata" == _type_1 then -- 2457
				editingInfo = _obj_0.editingInfo -- 2457
			end -- 2457
		end -- 2457
		if editingInfo ~= nil then -- 2457
			_match_0 = true -- 2457
			config.editingInfo = editingInfo -- 2458
			return { -- 2459
				success = true -- 2459
			} -- 2459
		end -- 2457
	end -- 2457
	if not _match_0 then -- 2457
		if not (config.editingInfo ~= nil) then -- 2461
			local folder -- 2462
			if App.locale:match('^zh') then -- 2462
				folder = 'zh-Hans' -- 2462
			else -- 2462
				folder = 'en' -- 2462
			end -- 2462
			config.editingInfo = json.encode({ -- 2464
				index = 0, -- 2464
				files = { -- 2466
					{ -- 2467
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2467
						title = "welcome.md" -- 2468
					} -- 2466
				} -- 2465
			}) -- 2463
		end -- 2461
		return { -- 2472
			success = true, -- 2472
			editingInfo = config.editingInfo -- 2472
		} -- 2472
	end -- 2457
end) -- 2454
HttpServer:post("/command", function(req) -- 2474
	do -- 2475
		local _type_0 = type(req) -- 2475
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2475
		if _tab_0 then -- 2475
			local code -- 2475
			do -- 2475
				local _obj_0 = req.body -- 2475
				local _type_1 = type(_obj_0) -- 2475
				if "table" == _type_1 or "userdata" == _type_1 then -- 2475
					code = _obj_0.code -- 2475
				end -- 2475
			end -- 2475
			local log -- 2475
			do -- 2475
				local _obj_0 = req.body -- 2475
				local _type_1 = type(_obj_0) -- 2475
				if "table" == _type_1 or "userdata" == _type_1 then -- 2475
					log = _obj_0.log -- 2475
				end -- 2475
			end -- 2475
			if code ~= nil and log ~= nil then -- 2475
				emit("AppCommand", code, log) -- 2476
				return { -- 2477
					success = true -- 2477
				} -- 2477
			end -- 2475
		end -- 2475
	end -- 2475
	return { -- 2474
		success = false -- 2474
	} -- 2474
end) -- 2474
HttpServer:post("/log/save", function() -- 2479
	local folder = ".download" -- 2480
	local fullLogFile = "dora_full_logs.txt" -- 2481
	local fullFolder = Path(Content.writablePath, folder) -- 2482
	Content:mkdir(fullFolder) -- 2483
	local logPath = Path(fullFolder, fullLogFile) -- 2484
	if App:saveLog(logPath) then -- 2485
		return { -- 2486
			success = true, -- 2486
			path = Path(folder, fullLogFile) -- 2486
		} -- 2486
	end -- 2485
	return { -- 2479
		success = false -- 2479
	} -- 2479
end) -- 2479
local tailLines -- 2488
tailLines = function(text, count) -- 2488
	local lines = { } -- 2489
	text = text:gsub("\r\n", "\n") -- 2490
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2491
		lines[#lines + 1] = line -- 2492
	end -- 2491
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2493
		table.remove(lines) -- 2494
	end -- 2493
	local start = math.max(1, #lines - count + 1) -- 2495
	local out = { } -- 2496
	for i = start, #lines do -- 2497
		out[#out + 1] = lines[i] -- 2498
	end -- 2497
	return table.concat(out, "\n") -- 2499
end -- 2488
HttpServer:post("/log", function(req) -- 2501
	local count = 100 -- 2502
	if req and req.body and req.body.count ~= nil then -- 2503
		count = req.body.count -- 2504
	end -- 2503
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2505
		return { -- 2506
			success = false, -- 2506
			message = "count must be a positive integer" -- 2506
		} -- 2506
	end -- 2505
	local folder = ".download" -- 2507
	local fullLogFile = "dora_full_logs.txt" -- 2508
	local fullFolder = Path(Content.writablePath, folder) -- 2509
	Content:mkdir(fullFolder) -- 2510
	local logPath = Path(fullFolder, fullLogFile) -- 2511
	if App:saveLog(logPath) then -- 2512
		local text = Content:load(logPath) -- 2513
		if text then -- 2514
			return { -- 2515
				success = true, -- 2515
				log = tailLines(text, count) -- 2515
			} -- 2515
		else -- 2517
			return { -- 2517
				success = false, -- 2517
				message = "failed to read log" -- 2517
			} -- 2517
		end -- 2514
	else -- 2519
		return { -- 2519
			success = false, -- 2519
			message = "failed to save log" -- 2519
		} -- 2519
	end -- 2512
	return { -- 2501
		success = false -- 2501
	} -- 2501
end) -- 2501
HttpServer:post("/yarn/check", function(req) -- 2521
	local yarncompile = require("yarncompile") -- 2522
	do -- 2523
		local _type_0 = type(req) -- 2523
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2523
		if _tab_0 then -- 2523
			local code -- 2523
			do -- 2523
				local _obj_0 = req.body -- 2523
				local _type_1 = type(_obj_0) -- 2523
				if "table" == _type_1 or "userdata" == _type_1 then -- 2523
					code = _obj_0.code -- 2523
				end -- 2523
			end -- 2523
			if code ~= nil then -- 2523
				local jsonObject = json.decode(code) -- 2524
				if jsonObject then -- 2524
					local errors = { } -- 2525
					local _list_0 = jsonObject.nodes -- 2526
					for _index_0 = 1, #_list_0 do -- 2526
						local node = _list_0[_index_0] -- 2526
						local title, body = node.title, node.body -- 2527
						local luaCode, err = yarncompile(body) -- 2528
						if not luaCode then -- 2528
							errors[#errors + 1] = title .. ":" .. err -- 2529
						end -- 2528
					end -- 2526
					return { -- 2530
						success = true, -- 2530
						syntaxError = table.concat(errors, "\n\n") -- 2530
					} -- 2530
				end -- 2524
			end -- 2523
		end -- 2523
	end -- 2523
	return { -- 2521
		success = false -- 2521
	} -- 2521
end) -- 2521
HttpServer:post("/yarn/check-file", function(req) -- 2532
	local yarncompile = require("yarncompile") -- 2533
	do -- 2534
		local _type_0 = type(req) -- 2534
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2534
		if _tab_0 then -- 2534
			local code -- 2534
			do -- 2534
				local _obj_0 = req.body -- 2534
				local _type_1 = type(_obj_0) -- 2534
				if "table" == _type_1 or "userdata" == _type_1 then -- 2534
					code = _obj_0.code -- 2534
				end -- 2534
			end -- 2534
			if code ~= nil then -- 2534
				local res, _, err = yarncompile(code, true) -- 2535
				if not res then -- 2535
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2536
					return { -- 2537
						success = false, -- 2537
						message = message, -- 2537
						line = line, -- 2537
						column = column, -- 2537
						node = node -- 2537
					} -- 2537
				end -- 2535
			end -- 2534
		end -- 2534
	end -- 2534
	return { -- 2532
		success = true -- 2532
	} -- 2532
end) -- 2532
getWaProjectDirFromFile = function(file) -- 2539
	local current -- 2540
	if Content:isdir(file) then -- 2540
		current = file -- 2540
	else -- 2540
		current = Path:getPath(file) -- 2540
	end -- 2540
	if current == "" then -- 2541
		return nil -- 2541
	end -- 2541
	repeat -- 2542
		local modPath = Path(current, "wa.mod") -- 2543
		if Content:exist(modPath) then -- 2544
			return current, modPath -- 2545
		end -- 2544
		local parent = Path:getPath(current) -- 2546
		if parent == "" or parent == current then -- 2547
			break -- 2547
		end -- 2547
		current = parent -- 2548
	until false -- 2542
	return nil -- 2550
end -- 2539
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2552
	do -- 2553
		local _type_0 = type(req) -- 2553
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2553
		if _tab_0 then -- 2553
			local path -- 2553
			do -- 2553
				local _obj_0 = req.body -- 2553
				local _type_1 = type(_obj_0) -- 2553
				if "table" == _type_1 or "userdata" == _type_1 then -- 2553
					path = _obj_0.path -- 2553
				end -- 2553
			end -- 2553
			if path ~= nil then -- 2553
				local projDir = getWaProjectDirFromFile(path) -- 2554
				if projDir then -- 2554
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2555
					if not Content:exist(sourceDoraPath) then -- 2556
						return { -- 2557
							success = false, -- 2557
							message = "missing dora template" -- 2557
						} -- 2557
					end -- 2556
					local targetVendorPath = Path(projDir, "vendor") -- 2558
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2559
					if not Content:exist(targetVendorPath) then -- 2560
						if not Content:mkdir(targetVendorPath) then -- 2561
							return { -- 2562
								success = false, -- 2562
								message = "failed to create vendor folder" -- 2562
							} -- 2562
						end -- 2561
					elseif not Content:isdir(targetVendorPath) then -- 2563
						return { -- 2564
							success = false, -- 2564
							message = "vendor path is not a folder" -- 2564
						} -- 2564
					end -- 2560
					if Content:exist(targetDoraPath) then -- 2565
						if not Content:remove(targetDoraPath) then -- 2566
							return { -- 2567
								success = false, -- 2567
								message = "failed to remove old dora" -- 2567
							} -- 2567
						end -- 2566
					end -- 2565
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2568
						return { -- 2569
							success = false, -- 2569
							message = "failed to copy dora" -- 2569
						} -- 2569
					end -- 2568
					return { -- 2570
						success = true -- 2570
					} -- 2570
				else -- 2572
					return { -- 2572
						success = false, -- 2572
						message = 'Wa file needs a project' -- 2572
					} -- 2572
				end -- 2554
			end -- 2553
		end -- 2553
	end -- 2553
	return { -- 2552
		success = false, -- 2552
		message = "invalid call" -- 2552
	} -- 2552
end) -- 2552
HttpServer:postSchedule("/wa/build", function(req) -- 2574
	do -- 2575
		local _type_0 = type(req) -- 2575
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2575
		if _tab_0 then -- 2575
			local path -- 2575
			do -- 2575
				local _obj_0 = req.body -- 2575
				local _type_1 = type(_obj_0) -- 2575
				if "table" == _type_1 or "userdata" == _type_1 then -- 2575
					path = _obj_0.path -- 2575
				end -- 2575
			end -- 2575
			if path ~= nil then -- 2575
				local projDir = getWaProjectDirFromFile(path) -- 2576
				if projDir then -- 2576
					local message = Wasm:buildWaAsync(projDir) -- 2577
					if message == "" then -- 2578
						return { -- 2579
							success = true -- 2579
						} -- 2579
					else -- 2581
						return { -- 2581
							success = false, -- 2581
							message = message -- 2581
						} -- 2581
					end -- 2578
				else -- 2583
					return { -- 2583
						success = false, -- 2583
						message = 'Wa file needs a project' -- 2583
					} -- 2583
				end -- 2576
			end -- 2575
		end -- 2575
	end -- 2575
	return { -- 2584
		success = false, -- 2584
		message = 'failed to build' -- 2584
	} -- 2584
end) -- 2574
HttpServer:postSchedule("/wa/format", function(req) -- 2586
	do -- 2587
		local _type_0 = type(req) -- 2587
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2587
		if _tab_0 then -- 2587
			local file -- 2587
			do -- 2587
				local _obj_0 = req.body -- 2587
				local _type_1 = type(_obj_0) -- 2587
				if "table" == _type_1 or "userdata" == _type_1 then -- 2587
					file = _obj_0.file -- 2587
				end -- 2587
			end -- 2587
			if file ~= nil then -- 2587
				local code = Wasm:formatWaAsync(file) -- 2588
				if code == "" then -- 2589
					return { -- 2590
						success = false -- 2590
					} -- 2590
				else -- 2592
					return { -- 2592
						success = true, -- 2592
						code = code -- 2592
					} -- 2592
				end -- 2589
			end -- 2587
		end -- 2587
	end -- 2587
	return { -- 2593
		success = false -- 2593
	} -- 2593
end) -- 2586
HttpServer:postSchedule("/wa/create", function(req) -- 2595
	do -- 2596
		local _type_0 = type(req) -- 2596
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2596
		if _tab_0 then -- 2596
			local path -- 2596
			do -- 2596
				local _obj_0 = req.body -- 2596
				local _type_1 = type(_obj_0) -- 2596
				if "table" == _type_1 or "userdata" == _type_1 then -- 2596
					path = _obj_0.path -- 2596
				end -- 2596
			end -- 2596
			if path ~= nil then -- 2596
				if not Content:exist(Path:getPath(path)) then -- 2597
					return { -- 2598
						success = false, -- 2598
						message = "target path not existed" -- 2598
					} -- 2598
				end -- 2597
				if Content:exist(path) then -- 2599
					return { -- 2600
						success = false, -- 2600
						message = "target project folder existed" -- 2600
					} -- 2600
				end -- 2599
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2601
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2602
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2603
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2604
					return { -- 2607
						success = false, -- 2607
						message = "missing template project" -- 2607
					} -- 2607
				end -- 2604
				if not Content:mkdir(path) then -- 2608
					return { -- 2609
						success = false, -- 2609
						message = "failed to create project folder" -- 2609
					} -- 2609
				end -- 2608
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2610
					Content:remove(path) -- 2611
					return { -- 2612
						success = false, -- 2612
						message = "failed to copy template" -- 2612
					} -- 2612
				end -- 2610
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2613
					Content:remove(path) -- 2614
					return { -- 2615
						success = false, -- 2615
						message = "failed to copy template" -- 2615
					} -- 2615
				end -- 2613
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2616
					Content:remove(path) -- 2617
					return { -- 2618
						success = false, -- 2618
						message = "failed to copy template" -- 2618
					} -- 2618
				end -- 2616
				return { -- 2619
					success = true -- 2619
				} -- 2619
			end -- 2596
		end -- 2596
	end -- 2596
	return { -- 2595
		success = false, -- 2595
		message = "invalid call" -- 2595
	} -- 2595
end) -- 2595
local tsBuildGlobs = { -- 2622
	"**/*.ts", -- 2622
	"**/*.tsx", -- 2623
	"!**/.*/**", -- 2624
	"!**/node_modules/**" -- 2625
} -- 2621
local tsSnapshotGlobs = { -- 2628
	"**/*.ts", -- 2628
	"**/*.tsx", -- 2629
	"**/*.lua", -- 2630
	"!**/.*/**", -- 2631
	"!**/node_modules/**" -- 2632
} -- 2627
local collectTSVirtualFiles -- 2634
collectTSVirtualFiles = function(sourceRoot) -- 2634
	local files = { } -- 2635
	local seen = { } -- 2636
	local addFile -- 2637
	addFile = function(file, moduleName, virtualFile) -- 2637
		if moduleName == nil then -- 2637
			moduleName = nil -- 2637
		end -- 2637
		if virtualFile == nil then -- 2637
			virtualFile = nil -- 2637
		end -- 2637
		local targetFile = virtualFile or file -- 2638
		do -- 2639
			local entry = seen[targetFile] -- 2639
			if entry then -- 2639
				if moduleName and moduleName ~= "" then -- 2640
					entry.moduleName = moduleName -- 2640
				end -- 2640
				return -- 2641
			end -- 2639
		end -- 2639
		local content = Content:load(file) -- 2642
		if content then -- 2642
			local entry = { -- 2643
				file = targetFile, -- 2643
				content = content -- 2643
			} -- 2643
			if moduleName and moduleName ~= "" then -- 2644
				entry.moduleName = moduleName -- 2644
			end -- 2644
			seen[targetFile] = entry -- 2645
			files[#files + 1] = entry -- 2646
		end -- 2642
	end -- 2637
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2647
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2648
		for _index_0 = 1, #_list_0 do -- 2648
			local subFile = _list_0[_index_0] -- 2648
			addFile(Path(sourceRoot, subFile)) -- 2649
		end -- 2648
		local libraryRoots = { -- 2651
			Path(sourceRoot, "Script", "Lib"), -- 2651
			Path(sourceRoot, "Lib"), -- 2652
			Path(Content.assetPath, "Script", "Lib") -- 2653
		} -- 2650
		for _index_0 = 1, #libraryRoots do -- 2654
			local libraryRoot = libraryRoots[_index_0] -- 2654
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2655
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2656
				for _index_1 = 1, #_list_1 do -- 2656
					local subFile = _list_1[_index_1] -- 2656
					local file = Path(libraryRoot, subFile) -- 2657
					local virtualFile = Path(sourceRoot, subFile) -- 2658
					addFile(file, nil, virtualFile) -- 2659
				end -- 2656
			end -- 2655
		end -- 2654
	end -- 2647
	local locale -- 2660
	if App.locale:match('^zh') then -- 2660
		locale = 'zh-Hans' -- 2660
	else -- 2660
		locale = 'en' -- 2660
	end -- 2660
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2661
	local _list_0 = Content:getFiles(declarationRoot) -- 2662
	for _index_0 = 1, #_list_0 do -- 2662
		local file = _list_0[_index_0] -- 2662
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2663
			local fullPath = Path(declarationRoot, file) -- 2664
			local moduleName = Path:getName(Path:getName(file)) -- 2665
			addFile(fullPath, moduleName) -- 2666
		end -- 2663
	end -- 2662
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2667
	local lualibBundleTarget -- 2668
	if sourceRoot then -- 2668
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2668
	else -- 2668
		lualibBundleTarget = "lualib_bundle.lua" -- 2668
	end -- 2668
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2669
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2670
	local _list_1 = Content:getFiles(lualibRoot) -- 2671
	for _index_0 = 1, #_list_1 do -- 2671
		local file = _list_1[_index_0] -- 2671
		if Path:getExt(file) == "lua" then -- 2672
			local virtualFile -- 2673
			if sourceRoot then -- 2673
				virtualFile = Path(sourceRoot, "lualib", file) -- 2673
			else -- 2673
				virtualFile = Path("lualib", file) -- 2673
			end -- 2673
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2674
		end -- 2672
	end -- 2671
	return files -- 2675
end -- 2634
local supportsCompilerWebView -- 2677
supportsCompilerWebView = function() -- 2677
	local _val_0 = App.platform -- 2677
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2677
end -- 2677
local webIDECompilerReady = false -- 2678
local webIDEConnectionGeneration = 0 -- 2679
local tsProbeId = 0 -- 2680
local probeWebIDECompiler -- 2682
probeWebIDECompiler = function(isCancelled) -- 2682
	if HttpServer.wsConnectionCount == 0 then -- 2683
		return false -- 2683
	end -- 2683
	tsProbeId = tsProbeId + 1 -- 2684
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2685
	local generation = webIDEConnectionGeneration -- 2686
	local done, ready = false, false -- 2687
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2688
	local listener = Node() -- 2689
	listener:gslot("AppWS", function(event) -- 2690
		if event.type == "Receive" then -- 2691
			local res = json.decode(event.msg) -- 2692
			if res then -- 2692
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2693
					responses = responses + 1 -- 2694
					ready = ready or res.success == true -- 2695
					done = ready or responses >= expectedResponses -- 2696
				end -- 2693
			end -- 2692
		end -- 2691
	end) -- 2690
	emit("AppWS", "Send", json.encode({ -- 2697
		name = "TranspileTSProbe", -- 2697
		id = requestId -- 2697
	})) -- 2697
	local deadline = App.runningTime + 5 -- 2698
	wait(function() -- 2699
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2699
	end) -- 2699
	listener:removeFromParent() -- 2700
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2701
	if generation == webIDEConnectionGeneration then -- 2702
		webIDECompilerReady = ready -- 2702
	end -- 2702
	return ready -- 2703
end -- 2682
local compilerConnectionListener = Node() -- 2705
compilerConnectionListener:addTo(Director.systemUI) -- 2707
local _anon_func_8 = function(event) -- 2709
	local _val_0 = event.type -- 2709
	return "Open" == _val_0 or "Close" == _val_0 -- 2709
end -- 2709
compilerConnectionListener:gslot("AppWS", function(event) -- 2708
	if _anon_func_8(event) then -- 2709
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2710
		webIDECompilerReady = false -- 2711
		if HttpServer.wsConnectionCount > 0 then -- 2712
			return thread(function() -- 2713
				return probeWebIDECompiler() -- 2713
			end) -- 2713
		end -- 2712
	end -- 2709
end) -- 2708
local _anon_func_9 = function(res) -- 2738
	if res.success then -- 2738
		return "tool" -- 2738
	else -- 2738
		return res.failureKind -- 2738
	end -- 2738
end -- 2738
local transpileTSFileWithWebIDE -- 2715
do -- 2715
	local tsBuildRequestId = 0 -- 2716
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2717
		if not probeWebIDECompiler(isCancelled) then -- 2718
			if isCancelled and isCancelled() then -- 2719
				return { -- 2720
					success = false, -- 2720
					file = file, -- 2720
					message = "build canceled", -- 2720
					interrupted = true -- 2720
				} -- 2720
			end -- 2719
			return { -- 2721
				success = false, -- 2721
				file = file, -- 2721
				message = "TypeScript transpiler is not ready", -- 2721
				failureKind = "tool" -- 2721
			} -- 2721
		end -- 2718
		tsBuildRequestId = tsBuildRequestId + 1 -- 2722
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2723
		local done = false -- 2724
		local result = nil -- 2725
		local listener = Node() -- 2726
		listener:gslot("AppWS", function(event) -- 2727
			if event.type == "Receive" then -- 2728
				local res = json.decode(event.msg) -- 2729
				if res then -- 2729
					if res.name == "TranspileTS" and res.id == requestId then -- 2730
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2731
							local luaFile = Path:replaceExt(file, "lua") -- 2732
							if Content:save(luaFile, res.luaCode) then -- 2733
								result = { -- 2734
									success = true, -- 2734
									file = file -- 2734
								} -- 2734
							else -- 2736
								result = { -- 2736
									success = false, -- 2736
									file = file, -- 2736
									message = "failed to save " .. tostring(luaFile) -- 2736
								} -- 2736
							end -- 2733
						else -- 2738
							result = { -- 2738
								success = false, -- 2738
								file = file, -- 2738
								message = res.message or "Compiler returned no Lua output", -- 2738
								failureKind = _anon_func_9(res) -- 2738
							} -- 2738
						end -- 2731
						done = true -- 2739
					end -- 2730
				end -- 2729
			end -- 2728
		end) -- 2727
		emit("AppWS", "Send", json.encode({ -- 2740
			name = "TranspileTS", -- 2740
			id = requestId, -- 2740
			file = file, -- 2740
			content = content, -- 2740
			projectRoot = sourceRoot, -- 2740
			files = files -- 2740
		})) -- 2740
		local deadline = App.runningTime + 30 -- 2741
		wait(function() -- 2742
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2742
		end) -- 2742
		listener:removeFromParent() -- 2743
		if not done then -- 2744
			webIDECompilerReady = false -- 2745
			if isCancelled and isCancelled() then -- 2746
				return { -- 2747
					success = false, -- 2747
					file = file, -- 2747
					message = "build canceled", -- 2747
					interrupted = true -- 2747
				} -- 2747
			end -- 2746
			return { -- 2748
				success = false, -- 2748
				file = file, -- 2748
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2748
				failureKind = "tool" -- 2748
			} -- 2748
		end -- 2744
		return result -- 2749
	end -- 2717
end -- 2715
local compilerReadyTimeout <const> = 15 -- 2751
local compilerBuildTimeout <const> = 30 -- 2752
local compilerIdleCloseSeconds <const> = 8 -- 2753
local compilerReady = false -- 2754
local compilerRequested = false -- 2755
local compilerFailure = nil -- 2756
local compilerUsers = 0 -- 2757
local compilerCloseGeneration = 0 -- 2758
local compilerJobId = 0 -- 2759
local compilerJobs = { } -- 2760
local compilerResults = { } -- 2761
local compilerInFlight = { } -- 2762
HttpServer:post("/compiler/ready", function() -- 2764
	if not compilerRequested then -- 2765
		return { -- 2765
			success = false -- 2765
		} -- 2765
	end -- 2765
	compilerReady = true -- 2766
	return { -- 2767
		success = true -- 2767
	} -- 2767
end) -- 2764
HttpServer:post("/compiler/failure", function(req) -- 2769
	if not compilerRequested then -- 2770
		return { -- 2770
			success = false -- 2770
		} -- 2770
	end -- 2770
	do -- 2771
		local _type_0 = type(req) -- 2771
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2771
		if _tab_0 then -- 2771
			local message -- 2771
			do -- 2771
				local _obj_0 = req.body -- 2771
				local _type_1 = type(_obj_0) -- 2771
				if "table" == _type_1 or "userdata" == _type_1 then -- 2771
					message = _obj_0.message -- 2771
				end -- 2771
			end -- 2771
			if message ~= nil then -- 2771
				if type(message) == "string" then -- 2772
					compilerFailure = message -- 2773
					compilerReady = false -- 2774
					return { -- 2775
						success = true -- 2775
					} -- 2775
				end -- 2772
			end -- 2771
		end -- 2771
	end -- 2771
	return { -- 2769
		success = false -- 2769
	} -- 2769
end) -- 2769
HttpServer:postSchedule("/compiler/poll", function() -- 2777
	if not compilerRequested then -- 2778
		return { -- 2778
			success = false -- 2778
		} -- 2778
	end -- 2778
	compilerReady = true -- 2779
	local deadline = App.runningTime + 5 -- 2780
	wait(function() -- 2781
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2781
	end) -- 2781
	if not (compilerRequested and not compilerFailure) then -- 2782
		return { -- 2782
			success = false -- 2782
		} -- 2782
	end -- 2782
	local job = table.remove(compilerJobs, 1) -- 2783
	if job then -- 2784
		compilerInFlight[job.id] = true -- 2785
	end -- 2784
	return { -- 2786
		success = true, -- 2786
		job = job -- 2786
	} -- 2786
end) -- 2777
HttpServer:post("/compiler/result", function(req) -- 2788
	do -- 2789
		local _type_0 = type(req) -- 2789
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2789
		if _tab_0 then -- 2789
			local body = req.body -- 2789
			if body ~= nil then -- 2789
				local id = body.id -- 2790
				if not (id and compilerInFlight[id]) then -- 2791
					return { -- 2791
						success = false, -- 2791
						message = "invalid compiler job" -- 2791
					} -- 2791
				end -- 2791
				compilerInFlight[id] = nil -- 2792
				compilerResults[id] = body -- 2793
				return { -- 2794
					success = true -- 2794
				} -- 2794
			end -- 2789
		end -- 2789
	end -- 2789
	return { -- 2788
		success = false -- 2788
	} -- 2788
end) -- 2788
local acquireCompiler -- 2796
acquireCompiler = function() -- 2796
	compilerUsers = compilerUsers + 1 -- 2797
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2798
	if not compilerRequested then -- 2799
		compilerRequested = true -- 2800
		compilerReady = false -- 2801
		compilerFailure = nil -- 2802
		return emit("AppWebView", "/compiler.html", true) -- 2803
	end -- 2799
end -- 2796
local releaseCompiler -- 2805
releaseCompiler = function() -- 2805
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2806
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2807
	if not (compilerUsers == 0) then -- 2808
		return -- 2808
	end -- 2808
	local closeGeneration = compilerCloseGeneration -- 2809
	return thread(function() -- 2810
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2811
		wait(function() -- 2812
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2813
		end) -- 2812
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2818
			compilerRequested = false -- 2819
			compilerReady = false -- 2820
			return emit("AppWebView", "/compiler.html", false) -- 2821
		end -- 2818
	end) -- 2810
end -- 2805
local removeCompilerJob -- 2823
removeCompilerJob = function(id) -- 2823
	for index = #compilerJobs, 1, -1 do -- 2824
		if compilerJobs[index].id == id then -- 2825
			table.remove(compilerJobs, index) -- 2826
		end -- 2825
	end -- 2824
	compilerInFlight[id] = nil -- 2827
	compilerResults[id] = nil -- 2828
end -- 2823
local transpileTSFileWithCompiler -- 2830
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2830
	acquireCompiler() -- 2831
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2832
	wait(function() -- 2833
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2833
	end) -- 2833
	if not compilerReady then -- 2834
		releaseCompiler() -- 2835
		if isCancelled and isCancelled() then -- 2836
			return { -- 2837
				success = false, -- 2837
				file = file, -- 2837
				message = "build canceled", -- 2837
				interrupted = true -- 2837
			} -- 2837
		end -- 2836
		return { -- 2838
			success = false, -- 2838
			file = file, -- 2838
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2838
			failureKind = "tool" -- 2838
		} -- 2838
	end -- 2834
	compilerJobId = compilerJobId + 1 -- 2839
	local jobId = compilerJobId -- 2840
	compilerJobs[#compilerJobs + 1] = { -- 2842
		id = jobId, -- 2842
		file = file, -- 2843
		content = content, -- 2844
		projectRoot = sourceRoot, -- 2845
		files = files -- 2846
	} -- 2841
	local deadline = App.runningTime + compilerBuildTimeout -- 2847
	wait(function() -- 2848
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2848
	end) -- 2848
	local response = compilerResults[jobId] -- 2849
	removeCompilerJob(jobId) -- 2850
	releaseCompiler() -- 2851
	if not response then -- 2852
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
			message = compilerFailure or "TypeScript transpile timed out", -- 2855
			failureKind = "tool" -- 2855
		} -- 2855
	end -- 2852
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2856
		local luaFile = Path:replaceExt(file, "lua") -- 2857
		if Content:save(luaFile, response.luaCode) then -- 2858
			return { -- 2859
				success = true, -- 2859
				file = file -- 2859
			} -- 2859
		end -- 2858
		return { -- 2860
			success = false, -- 2860
			file = file, -- 2860
			message = "failed to save " .. tostring(luaFile) -- 2860
		} -- 2860
	end -- 2856
	return { -- 2861
		success = false, -- 2861
		file = file, -- 2861
		message = response.message or "TypeScript transpile failed" -- 2861
	} -- 2861
end -- 2830
local compilerFailureListener = Node() -- 2863
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2864
	compilerFailure = message -- 2865
	compilerReady = false -- 2866
end) -- 2864
local transpileTSFile -- 2868
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2868
	if supportsCompilerWebView() and not files then -- 2869
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2870
	end -- 2869
	if HttpServer.wsConnectionCount > 0 then -- 2871
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2872
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2873
			return result -- 2873
		end -- 2873
		webIDECompilerReady = false -- 2874
	end -- 2871
	if supportsCompilerWebView() then -- 2875
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2876
	end -- 2875
	return { -- 2877
		success = false, -- 2877
		file = file, -- 2877
		message = "Web IDE compiler not connected", -- 2877
		failureKind = "tool" -- 2877
	} -- 2877
end -- 2868
local _anon_func_10 = function(path) -- 2892
	local _val_0 = Path:getExt(path) -- 2892
	return "ts" == _val_0 or "tsx" == _val_0 -- 2892
end -- 2892
HttpServer:postSchedule("/ts/build", function(req) -- 2879
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2880
	local buildSucceeded = false -- 2881
	local _ <close> = setmetatable({ }, { -- 2882
		__close = function() -- 2882
			return finishUpdate(buildSucceeded) -- 2882
		end -- 2882
	}) -- 2882
	do -- 2883
		local _type_0 = type(req) -- 2883
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2883
		if _tab_0 then -- 2883
			local path -- 2883
			do -- 2883
				local _obj_0 = req.body -- 2883
				local _type_1 = type(_obj_0) -- 2883
				if "table" == _type_1 or "userdata" == _type_1 then -- 2883
					path = _obj_0.path -- 2883
				end -- 2883
			end -- 2883
			if path ~= nil then -- 2883
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2884
					return { -- 2885
						success = false, -- 2885
						message = "Web IDE not connected" -- 2885
					} -- 2885
				end -- 2884
				local projectRoot = req.body.projectRoot -- 2886
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2887
				if not Content:exist(path) then -- 2888
					return { -- 2889
						success = false, -- 2889
						message = "path not existed" -- 2889
					} -- 2889
				end -- 2888
				local messages = { } -- 2890
				if not Content:isdir(path) then -- 2891
					if not (_anon_func_10(path)) then -- 2892
						return { -- 2893
							success = false, -- 2893
							message = "expecting a TypeScript file" -- 2893
						} -- 2893
					end -- 2892
					local content = Content:load(path) -- 2894
					if not content then -- 2895
						return { -- 2896
							success = false, -- 2896
							message = "failed to read file" -- 2896
						} -- 2896
					end -- 2895
					emit("AppWS", "Send", json.encode({ -- 2897
						name = "UpdateFile", -- 2897
						file = path, -- 2897
						exists = true, -- 2897
						content = content, -- 2897
						projectRoot = sourceRoot -- 2897
					})) -- 2897
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2898
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2899
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2900
					end -- 2898
				else -- 2902
					local fileData = { } -- 2902
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2903
					for _index_0 = 1, #_list_0 do -- 2903
						local subFile = _list_0[_index_0] -- 2903
						local file = Path(path, subFile) -- 2904
						local content = Content:load(file) -- 2905
						if content then -- 2905
							fileData[file] = content -- 2906
							emit("AppWS", "Send", json.encode({ -- 2907
								name = "UpdateFile", -- 2907
								file = file, -- 2907
								exists = true, -- 2907
								content = content, -- 2907
								projectRoot = sourceRoot -- 2907
							})) -- 2907
						else -- 2909
							messages[#messages + 1] = { -- 2909
								success = false, -- 2909
								file = file, -- 2909
								message = "failed to read file" -- 2909
							} -- 2909
						end -- 2905
					end -- 2903
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2910
					for file, content in pairs(fileData) do -- 2911
						if "d" == Path:getExt(Path:getName(file)) then -- 2912
							goto _continue_0 -- 2912
						end -- 2912
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2913
						::_continue_0:: -- 2912
					end -- 2911
				end -- 2891
				local success = true -- 2914
				for _index_0 = 1, #messages do -- 2915
					local item = messages[_index_0] -- 2915
					if not item.success then -- 2916
						success = false -- 2916
					end -- 2916
				end -- 2915
				local message = nil -- 2917
				if not success then -- 2918
					message = "TypeScript compilation failed" -- 2918
				end -- 2918
				buildSucceeded = success -- 2919
				return { -- 2920
					success = success, -- 2920
					messages = messages, -- 2920
					message = message -- 2920
				} -- 2920
			end -- 2883
		end -- 2883
	end -- 2883
	return { -- 2879
		success = false -- 2879
	} -- 2879
end) -- 2879
HttpServer:post("/download", function(req) -- 2922
	do -- 2923
		local _type_0 = type(req) -- 2923
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2923
		if _tab_0 then -- 2923
			local url -- 2923
			do -- 2923
				local _obj_0 = req.body -- 2923
				local _type_1 = type(_obj_0) -- 2923
				if "table" == _type_1 or "userdata" == _type_1 then -- 2923
					url = _obj_0.url -- 2923
				end -- 2923
			end -- 2923
			local target -- 2923
			do -- 2923
				local _obj_0 = req.body -- 2923
				local _type_1 = type(_obj_0) -- 2923
				if "table" == _type_1 or "userdata" == _type_1 then -- 2923
					target = _obj_0.target -- 2923
				end -- 2923
			end -- 2923
			if url ~= nil and target ~= nil then -- 2923
				local Entry = require("Script.Dev.Entry") -- 2924
				Entry.downloadFile(url, target) -- 2925
				return { -- 2926
					success = true -- 2926
				} -- 2926
			end -- 2923
		end -- 2923
	end -- 2923
	return { -- 2922
		success = false -- 2922
	} -- 2922
end) -- 2922
local isDesktopPlatform -- 2928
isDesktopPlatform = function() -- 2928
	local _val_0 = App.platform -- 2929
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2929
end -- 2928
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 2931
local nativeIDEListener = Node() -- 2932
nativeIDEListener:addTo(Director.systemUI) -- 2933
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 2934
	nativeIDEState, nativeIDEMessage = state, message -- 2935
end) -- 2934
local _anon_func_11 = function() -- 2938
	local _val_0 = App.platform -- 2938
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2938
end -- 2938
HttpServer:post("/ide", function(req) -- 2937
	if not (_anon_func_11()) then -- 2938
		return { -- 2938
			success = false, -- 2938
			message = "Native IDE is unavailable" -- 2938
		} -- 2938
	end -- 2938
	if not App.webIDEEnabled then -- 2939
		return { -- 2939
			success = false, -- 2939
			message = "Embedded Web IDE is disabled" -- 2939
		} -- 2939
	end -- 2939
	do -- 2940
		local _type_0 = type(req) -- 2940
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2940
		if _tab_0 then -- 2940
			local action -- 2940
			do -- 2940
				local _obj_0 = req.body -- 2940
				local _type_1 = type(_obj_0) -- 2940
				if "table" == _type_1 or "userdata" == _type_1 then -- 2940
					action = _obj_0.action -- 2940
				end -- 2940
			end -- 2940
			if action ~= nil then -- 2940
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 2941
					emit("AppWebView", "/ide/" .. action, true) -- 2942
					return { -- 2943
						success = true -- 2943
					} -- 2943
				end -- 2941
			end -- 2940
		end -- 2940
	end -- 2940
	return { -- 2937
		success = false, -- 2937
		message = "invalid IDE action" -- 2937
	} -- 2937
end) -- 2937
local _anon_func_12 = function() -- 2959
	local _val_0 = App.platform -- 2959
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2959
end -- 2959
local getServerStatus -- 2945
getServerStatus = function() -- 2945
	local Entry = require("Script.Dev.Entry") -- 2946
	local running = Entry.getCurrentEntryStatus() -- 2947
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2948
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2949
	return { -- 2951
		success = true, -- 2951
		platform = App.platform, -- 2952
		locale = App.locale, -- 2953
		version = App.version, -- 2954
		url = "http://localhost:8866", -- 2955
		wsConnectionCount = wsConnectionCount, -- 2956
		webIDEConnected = wsConnectionCount > 0, -- 2957
		nativeIDE = { -- 2959
			supported = _anon_func_12(), -- 2959
			enabled = App.webIDEEnabled, -- 2960
			state = nativeIDEState, -- 2961
			message = nativeIDEMessage -- 2962
		}, -- 2958
		typescriptCompiler = { -- 2964
			webIDEReady = webIDECompilerReady, -- 2964
			webIDEGeneration = webIDEConnectionGeneration, -- 2965
			embeddedSupported = supportsCompilerWebView(), -- 2966
			embeddedRequested = compilerRequested, -- 2967
			embeddedReady = compilerReady, -- 2968
			users = compilerUsers, -- 2969
			queuedJobs = #compilerJobs, -- 2970
			failure = compilerFailure -- 2971
		}, -- 2963
		assetPath = Content.assetPath, -- 2972
		writablePath = Content.writablePath, -- 2973
		appPath = Content.appPath, -- 2974
		waTemplateReady = waTemplateReady, -- 2975
		running = running -- 2976
	} -- 2950
end -- 2945
HttpServer:post("/status", function() -- 2979
	return getServerStatus() -- 2980
end) -- 2979
HttpServer:postSchedule("/doctor/fix", function(req) -- 2982
	do -- 2983
		local _type_0 = type(req) -- 2983
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2983
		if _tab_0 then -- 2983
			local openWebIDE -- 2983
			do -- 2983
				local _obj_0 = req.body -- 2983
				local _type_1 = type(_obj_0) -- 2983
				if "table" == _type_1 or "userdata" == _type_1 then -- 2983
					openWebIDE = _obj_0.openWebIDE -- 2983
				end -- 2983
			end -- 2983
			if openWebIDE ~= nil then -- 2983
				if not openWebIDE then -- 2984
					return { -- 2985
						success = false, -- 2985
						message = "nothing to fix" -- 2985
					} -- 2985
				end -- 2984
				local status = getServerStatus() -- 2986
				if status.webIDEConnected then -- 2987
					return { -- 2988
						success = true, -- 2988
						fixed = false, -- 2988
						message = "Web IDE already connected.", -- 2988
						status = status -- 2988
					} -- 2988
				end -- 2987
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2989
				if waitSeconds > 0 then -- 2990
					local deadline = os.time() + waitSeconds -- 2991
					repeat -- 2992
						sleep(0.2) -- 2993
						status = getServerStatus() -- 2994
						if status.webIDEConnected then -- 2995
							return { -- 2996
								success = true, -- 2996
								fixed = false, -- 2996
								reconnected = true, -- 2996
								message = "Web IDE reconnected.", -- 2996
								status = status -- 2996
							} -- 2996
						end -- 2995
					until os.time() >= deadline -- 2992
				end -- 2990
				if not isDesktopPlatform() then -- 2998
					return { -- 2999
						success = false, -- 2999
						message = "opening Web IDE is only supported on desktop platforms", -- 2999
						status = status -- 2999
					} -- 2999
				end -- 2998
				local url = "http://localhost:8866" -- 3000
				App:openURL(url) -- 3001
				status.openedURL = url -- 3002
				return { -- 3003
					success = true, -- 3003
					fixed = true, -- 3003
					message = "Opened Web IDE in the local browser.", -- 3003
					url = url, -- 3003
					status = status -- 3003
				} -- 3003
			end -- 2983
		end -- 2983
	end -- 2983
	return { -- 2982
		success = false, -- 2982
		message = "invalid call" -- 2982
	} -- 2982
end) -- 2982
local status = { } -- 3005
_module_0 = status -- 3006
status.transpileTSFile = transpileTSFile -- 3008
status.buildAsync = function(path) -- 3010
	if not Content:exist(path) then -- 3011
		return { -- 3012
			success = false, -- 3012
			file = path, -- 3012
			message = "file not existed" -- 3012
		} -- 3012
	end -- 3011
	do -- 3013
		local _exp_0 = Path:getExt(path) -- 3013
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 3013
			if '' == Path:getExt(Path:getName(path)) then -- 3014
				local content = Content:loadAsync(path) -- 3015
				if content then -- 3015
					local resultCodes, err = compileFileAsync(path, content) -- 3016
					if resultCodes then -- 3016
						return { -- 3017
							success = true, -- 3017
							file = path -- 3017
						} -- 3017
					else -- 3019
						return { -- 3019
							success = false, -- 3019
							file = path, -- 3019
							message = err -- 3019
						} -- 3019
					end -- 3016
				end -- 3015
			end -- 3014
		elseif "lua" == _exp_0 then -- 3020
			local content = Content:loadAsync(path) -- 3021
			if content then -- 3021
				do -- 3022
					local isTIC80 = CheckTIC80Code(content) -- 3022
					if isTIC80 then -- 3022
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 3023
					end -- 3022
				end -- 3022
				local success, info -- 3024
				do -- 3024
					local _obj_0 = luaCheck(path, content) -- 3024
					success, info = _obj_0.success, _obj_0.info -- 3024
				end -- 3024
				if success then -- 3025
					return { -- 3026
						success = true, -- 3026
						file = path -- 3026
					} -- 3026
				elseif info and #info > 0 then -- 3027
					local messages = { } -- 3028
					for _index_0 = 1, #info do -- 3029
						local _des_0 = info[_index_0] -- 3029
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3029
						local lineText = "" -- 3030
						if line then -- 3031
							local currentLine = 1 -- 3032
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3033
								if currentLine == line then -- 3034
									lineText = text -- 3035
									break -- 3036
								end -- 3034
								currentLine = currentLine + 1 -- 3037
							end -- 3033
						end -- 3031
						if line then -- 3038
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3039
						else -- 3041
							messages[#messages + 1] = message -- 3041
						end -- 3038
					end -- 3029
					return { -- 3042
						success = false, -- 3042
						file = path, -- 3042
						message = table.concat(messages, "\n") -- 3042
					} -- 3042
				else -- 3044
					return { -- 3044
						success = false, -- 3044
						file = path, -- 3044
						message = "lua check failed" -- 3044
					} -- 3044
				end -- 3025
			end -- 3021
		elseif "yarn" == _exp_0 then -- 3045
			local content = Content:loadAsync(path) -- 3046
			if content then -- 3046
				local res, _, err = yarncompile(content, true) -- 3047
				if res then -- 3047
					return { -- 3048
						success = true, -- 3048
						file = path -- 3048
					} -- 3048
				else -- 3050
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3050
					local lineText = "" -- 3051
					if line then -- 3052
						local currentLine = 1 -- 3053
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3054
							if currentLine == line then -- 3055
								lineText = text -- 3056
								break -- 3057
							end -- 3055
							currentLine = currentLine + 1 -- 3058
						end -- 3054
					end -- 3052
					if node ~= "" then -- 3059
						node = "node: " .. tostring(node) .. ", " -- 3060
					else -- 3061
						node = "" -- 3061
					end -- 3059
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3062
					return { -- 3063
						success = false, -- 3063
						file = path, -- 3063
						message = message -- 3063
					} -- 3063
				end -- 3047
			end -- 3046
		end -- 3013
	end -- 3013
	return { -- 3064
		success = false, -- 3064
		file = path, -- 3064
		message = "invalid file to build" -- 3064
	} -- 3064
end -- 3010
HttpServer:postSchedule("/git/commit-files", function(req) -- 3066
	do -- 3067
		local _type_0 = type(req) -- 3067
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3067
		if _tab_0 then -- 3067
			local body = req.body -- 3067
			if body ~= nil then -- 3067
				local repoPath, commit = body.repoPath, body.commit -- 3068
				if gitInvalidRepoPath(repoPath) then -- 3069
					return { -- 3069
						success = false, -- 3069
						message = "invalid repoPath" -- 3069
					} -- 3069
				end -- 3069
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3070
					return { -- 3070
						success = false, -- 3070
						message = "invalid commit" -- 3070
					} -- 3070
				end -- 3070
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3071
				if not res.success then -- 3072
					return res -- 3072
				end -- 3072
				return { -- 3073
					success = true, -- 3073
					status = res.status, -- 3073
					data = res.status and res.status.data -- 3073
				} -- 3073
			end -- 3067
		end -- 3067
	end -- 3067
	return invalidArguments -- 3066
end) -- 3066
thread(function() -- 3075
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3076
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3077
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3078
		local storedAsset -- 3081
		storedAsset = function(file) -- 3081
			if Content:exist(file) then -- 3082
				return Content:load(file) -- 3083
			elseif Content:exist(file .. ".gz") then -- 3084
				return Content:load(file .. ".gz") -- 3085
			else -- 3086
				return "" -- 3086
			end -- 3082
		end -- 3081
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3087
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3088
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3089
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3090
		local readyContent = table.concat({ -- 3092
			App.version, -- 3092
			storedAsset(doraWeb), -- 3093
			storedAsset(heavyAssets), -- 3094
			storedAsset(runtimeIndex), -- 3095
			storedAsset(compilerIndex), -- 3096
			storedAsset(manifest) -- 3097
		}, "\n") -- 3091
		local needReload -- 3099
		if Content:exist(doraReady) then -- 3099
			needReload = readyContent ~= Content:load(doraReady) -- 3100
		else -- 3101
			needReload = true -- 3101
		end -- 3099
		if needReload then -- 3102
			Content:remove(Path(Content.appPath, ".www")) -- 3103
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3104
			Content:save(doraReady, readyContent) -- 3108
			print("Dora Dora is ready!") -- 3109
		end -- 3102
	end -- 3078
	if App.platform == "Emscripten" then -- 3110
		status.url = nil -- 3111
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3112
	end -- 3110
	HttpServer:clearStaticCacheControls() -- 3113
	HttpServer:setStaticCacheControl("no-cache") -- 3114
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3115
	if HttpServer:start(8866) then -- 3119
		local localIP = HttpServer.localIP -- 3120
		if localIP == "" then -- 3121
			localIP = "localhost" -- 3121
		end -- 3121
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3122
		return HttpServer:startWS(8868) -- 3123
	else -- 3125
		status.url = nil -- 3125
		return print("8866 Port not available!") -- 3126
	end -- 3119
end) -- 3075
return _module_0 -- 1
