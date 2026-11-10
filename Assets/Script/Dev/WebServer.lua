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
		else -- 1533
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1533
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
	]]) -- 1534
	require("Agent.Config.LLMConfigMigration").upgradeLLMConfig() -- 1553
	return require("Agent.Config.LLMConfigNames").upgradeLLMConfigNames() -- 1554
end -- 1494
local normalizeContextWindow -- 1556
normalizeContextWindow = function(value) -- 1556
	local contextWindow = tonumber(value) -- 1557
	if contextWindow == nil or contextWindow < 64000 then -- 1558
		return 64000 -- 1559
	end -- 1558
	return math.max(64000, math.floor(contextWindow)) -- 1560
end -- 1556
local normalizeTemperature -- 1562
normalizeTemperature = function(value) -- 1562
	local temperature = tonumber(value) -- 1563
	if temperature == nil then -- 1564
		return 0.1 -- 1565
	end -- 1564
	return math.max(0, math.min(2, temperature)) -- 1566
end -- 1562
local normalizeMaxTokens -- 1568
normalizeMaxTokens = function(value) -- 1568
	local maxTokens = tonumber(value) -- 1569
	if maxTokens == nil or maxTokens < 1 then -- 1570
		return 64000 -- 1571
	end -- 1570
	return math.max(1, math.floor(maxTokens)) -- 1572
end -- 1568
local normalizeReasoningEffort -- 1574
normalizeReasoningEffort = function(value) -- 1574
	if value == nil then -- 1575
		return "" -- 1576
	end -- 1575
	local effort = tostring(value) -- 1577
	return effort:match("^%s*(.-)%s*$") or "" -- 1578
end -- 1574
local normalizeCustomOptions -- 1580
normalizeCustomOptions = function(value) -- 1580
	if value == nil then -- 1581
		return "" -- 1582
	end -- 1581
	local options = tostring(value) -- 1583
	options = options:match("^%s*(.-)%s*$") or "" -- 1584
	return options -- 1585
end -- 1580
local validateCustomOptions -- 1587
validateCustomOptions = function(value) -- 1587
	local options = normalizeCustomOptions(value) -- 1588
	if options == "" then -- 1589
		return true -- 1589
	end -- 1589
	if not options:match("^%s*{") then -- 1590
		return false -- 1590
	end -- 1590
	local decoded = json.decode(options) -- 1591
	return type(decoded) == "table" -- 1592
end -- 1587
HttpServer:post("/llm/list", function() -- 1594
	ensureLLMConfigTable() -- 1595
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options\n		from LLMConfig\n		order by id asc") -- 1596
	local items -- 1600
	if rows and #rows > 0 then -- 1600
		local _accum_0 = { } -- 1601
		local _len_0 = 1 -- 1601
		for _index_0 = 1, #rows do -- 1601
			local _des_0 = rows[_index_0] -- 1601
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10] -- 1601
			_accum_0[_len_0] = { -- 1602
				id = id, -- 1602
				name = name, -- 1602
				url = url, -- 1602
				model = model, -- 1602
				key = key, -- 1602
				contextWindow = normalizeContextWindow(contextWindow), -- 1602
				temperature = normalizeTemperature(temperature), -- 1602
				maxTokens = normalizeMaxTokens(maxTokens), -- 1602
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1602
				customOptions = normalizeCustomOptions(customOptions) -- 1602
			} -- 1602
			_len_0 = _len_0 + 1 -- 1602
		end -- 1601
		items = _accum_0 -- 1600
	end -- 1600
	return { -- 1603
		success = true, -- 1603
		items = items -- 1603
	} -- 1603
end) -- 1594
HttpServer:post("/llm/create", function(req) -- 1605
	ensureLLMConfigTable() -- 1606
	do -- 1607
		local _type_0 = type(req) -- 1607
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1607
		if _tab_0 then -- 1607
			local body = req.body -- 1607
			if body ~= nil then -- 1607
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions -- 1608
				local now = os.time() -- 1609
				if name == nil or url == nil or model == nil or key == nil then -- 1610
					return invalidArguments -- 1611
				end -- 1610
				local names = require("Agent.Config.LLMConfigNames") -- 1612
				name = names.normalizeLLMConfigName(name) -- 1613
				if not name then -- 1614
					return { -- 1614
						success = false, -- 1614
						code = "INVALID_LLM_CONFIG_NAME", -- 1614
						message = "LLM configuration name must be a non-empty string" -- 1614
					} -- 1614
				end -- 1614
				local nameCheck = names.checkLLMConfigName(name) -- 1615
				if not nameCheck.success then -- 1616
					return nameCheck -- 1616
				end -- 1616
				contextWindow = normalizeContextWindow(contextWindow) -- 1617
				temperature = normalizeTemperature(temperature) -- 1618
				maxTokens = normalizeMaxTokens(maxTokens) -- 1619
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1620
				customOptions = normalizeCustomOptions(customOptions) -- 1621
				if not validateCustomOptions(customOptions) then -- 1622
					return { -- 1622
						success = false, -- 1622
						message = "customOptions must be a JSON object" -- 1622
					} -- 1622
				end -- 1622
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1629
					tostring(name), -- 1629
					tostring(url), -- 1630
					tostring(model), -- 1631
					tostring(key), -- 1632
					contextWindow, -- 1633
					temperature, -- 1634
					maxTokens, -- 1635
					reasoningEffort, -- 1636
					customOptions, -- 1637
					1, -- 1638
					now, -- 1639
					now -- 1640
				}) -- 1623
				if affected < 0 then -- 1642
					nameCheck = names.checkLLMConfigName(name) -- 1643
					if not nameCheck.success then -- 1644
						return nameCheck -- 1644
					end -- 1644
				end -- 1642
				return { -- 1645
					success = affected > 0 -- 1645
				} -- 1645
			end -- 1607
		end -- 1607
	end -- 1607
	return invalidArguments -- 1605
end) -- 1605
HttpServer:post("/llm/update", function(req) -- 1647
	ensureLLMConfigTable() -- 1648
	do -- 1649
		local _type_0 = type(req) -- 1649
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1649
		if _tab_0 then -- 1649
			local body = req.body -- 1649
			if body ~= nil then -- 1649
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions -- 1650
				local now = os.time() -- 1651
				id = tonumber(id) -- 1652
				if id == nil or id <= 0 or id ~= math.floor(id) then -- 1653
					return invalidArguments -- 1653
				end -- 1653
				local names = require("Agent.Config.LLMConfigNames") -- 1654
				name = names.normalizeLLMConfigName(name) -- 1655
				if not name then -- 1656
					return { -- 1656
						success = false, -- 1656
						code = "INVALID_LLM_CONFIG_NAME", -- 1656
						message = "LLM configuration name must be a non-empty string" -- 1656
					} -- 1656
				end -- 1656
				local nameCheck = names.checkLLMConfigName(name, id) -- 1657
				if not nameCheck.success then -- 1658
					return nameCheck -- 1658
				end -- 1658
				contextWindow = normalizeContextWindow(contextWindow) -- 1659
				temperature = normalizeTemperature(temperature) -- 1660
				maxTokens = normalizeMaxTokens(maxTokens) -- 1661
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1662
				customOptions = normalizeCustomOptions(customOptions) -- 1663
				if not validateCustomOptions(customOptions) then -- 1664
					return { -- 1664
						success = false, -- 1664
						message = "customOptions must be a JSON object" -- 1664
					} -- 1664
				end -- 1664
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, updated_at = ?\n			where id = ?", { -- 1669
					tostring(name), -- 1669
					tostring(url), -- 1670
					tostring(model), -- 1671
					tostring(key), -- 1672
					contextWindow, -- 1673
					temperature, -- 1674
					maxTokens, -- 1675
					reasoningEffort, -- 1676
					customOptions, -- 1677
					now, -- 1678
					id -- 1679
				}) -- 1665
				if affected < 0 then -- 1681
					nameCheck = names.checkLLMConfigName(name, id) -- 1682
					if not nameCheck.success then -- 1683
						return nameCheck -- 1683
					end -- 1683
				end -- 1681
				return { -- 1684
					success = affected > 0 -- 1684
				} -- 1684
			end -- 1649
		end -- 1649
	end -- 1649
	return invalidArguments -- 1647
end) -- 1647
HttpServer:post("/llm/delete", function(req) -- 1686
	ensureLLMConfigTable() -- 1687
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
				id = tonumber(id) -- 1689
				if id == nil then -- 1690
					return invalidArguments -- 1690
				end -- 1690
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1691
					id -- 1691
				}) -- 1691
				return { -- 1692
					success = affected >= 0 -- 1692
				} -- 1692
			end -- 1688
		end -- 1688
	end -- 1688
	return invalidArguments -- 1686
end) -- 1686
HttpServer:post("/local-agent/list", function() -- 1694
	return { -- 1695
		success = true, -- 1695
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1695
		items = AgentLocalAgent.listConfigs() -- 1695
	} -- 1695
end) -- 1694
HttpServer:post("/local-agent/save", function(req) -- 1697
	do -- 1698
		local _type_0 = type(req) -- 1698
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1698
		if _tab_0 then -- 1698
			local body = req.body -- 1698
			if body ~= nil then -- 1698
				return AgentLocalAgent.saveConfig(body) -- 1699
			end -- 1698
		end -- 1698
	end -- 1698
	return invalidArguments -- 1697
end) -- 1697
HttpServer:post("/local-agent/delete", function(req) -- 1701
	do -- 1702
		local _type_0 = type(req) -- 1702
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1702
		if _tab_0 then -- 1702
			local id -- 1702
			do -- 1702
				local _obj_0 = req.body -- 1702
				local _type_1 = type(_obj_0) -- 1702
				if "table" == _type_1 or "userdata" == _type_1 then -- 1702
					id = _obj_0.id -- 1702
				end -- 1702
			end -- 1702
			if id ~= nil then -- 1702
				return AgentLocalAgent.deleteConfig(id) -- 1703
			end -- 1702
		end -- 1702
	end -- 1702
	return invalidArguments -- 1701
end) -- 1701
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1705
	do -- 1706
		local _type_0 = type(req) -- 1706
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1706
		if _tab_0 then -- 1706
			local id -- 1706
			do -- 1706
				local _obj_0 = req.body -- 1706
				local _type_1 = type(_obj_0) -- 1706
				if "table" == _type_1 or "userdata" == _type_1 then -- 1706
					id = _obj_0.id -- 1706
				end -- 1706
			end -- 1706
			if id ~= nil then -- 1706
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1707
			end -- 1706
		end -- 1706
	end -- 1706
	return invalidArguments -- 1705
end) -- 1705
HttpServer:post("/stat", function(req) -- 1709
	do -- 1710
		local _type_0 = type(req) -- 1710
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1710
		if _tab_0 then -- 1710
			local path -- 1710
			do -- 1710
				local _obj_0 = req.body -- 1710
				local _type_1 = type(_obj_0) -- 1710
				if "table" == _type_1 or "userdata" == _type_1 then -- 1710
					path = _obj_0.path -- 1710
				end -- 1710
			end -- 1710
			if path ~= nil then -- 1710
				if not Content:exist(path) then -- 1711
					return { -- 1712
						success = false, -- 1712
						message = "target not existed" -- 1712
					} -- 1712
				end -- 1711
				if Content:isdir(path) then -- 1713
					return { -- 1714
						success = false, -- 1714
						message = "failed to stat a directory" -- 1714
					} -- 1714
				end -- 1713
				local size, isBinary = Content:getAttr(path) -- 1715
				if size then -- 1715
					return { -- 1716
						success = true, -- 1716
						size = size, -- 1716
						isBinary = isBinary -- 1716
					} -- 1716
				end -- 1715
			end -- 1710
		end -- 1710
	end -- 1710
	return { -- 1709
		success = false, -- 1709
		message = "failed to stat" -- 1709
	} -- 1709
end) -- 1709
HttpServer:post("/new", function(req) -- 1718
	do -- 1719
		local _type_0 = type(req) -- 1719
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1719
		if _tab_0 then -- 1719
			local path -- 1719
			do -- 1719
				local _obj_0 = req.body -- 1719
				local _type_1 = type(_obj_0) -- 1719
				if "table" == _type_1 or "userdata" == _type_1 then -- 1719
					path = _obj_0.path -- 1719
				end -- 1719
			end -- 1719
			local content -- 1719
			do -- 1719
				local _obj_0 = req.body -- 1719
				local _type_1 = type(_obj_0) -- 1719
				if "table" == _type_1 or "userdata" == _type_1 then -- 1719
					content = _obj_0.content -- 1719
				end -- 1719
			end -- 1719
			local folder -- 1719
			do -- 1719
				local _obj_0 = req.body -- 1719
				local _type_1 = type(_obj_0) -- 1719
				if "table" == _type_1 or "userdata" == _type_1 then -- 1719
					folder = _obj_0.folder -- 1719
				end -- 1719
			end -- 1719
			if path ~= nil and content ~= nil and folder ~= nil then -- 1719
				if Content:exist(path) then -- 1720
					return { -- 1721
						success = false, -- 1721
						message = "TargetExisted" -- 1721
					} -- 1721
				end -- 1720
				local parent = Path:getPath(path) -- 1722
				local files = Content:getFiles(parent) -- 1723
				if folder then -- 1724
					local name = Path:getFilename(path):lower() -- 1725
					for _index_0 = 1, #files do -- 1726
						local file = files[_index_0] -- 1726
						if name == Path:getFilename(file):lower() then -- 1727
							return { -- 1728
								success = false, -- 1728
								message = "TargetExisted" -- 1728
							} -- 1728
						end -- 1727
					end -- 1726
					if Content:mkdir(path) then -- 1729
						return { -- 1730
							success = true -- 1730
						} -- 1730
					end -- 1729
				else -- 1732
					local name = Path:getName(path):lower() -- 1732
					local targetExt = Path:getExt(path) -- 1733
					for _index_0 = 1, #files do -- 1734
						local file = files[_index_0] -- 1734
						if name == Path:getName(file):lower() then -- 1735
							local ext = Path:getExt(file) -- 1736
							if not ("tl" == targetExt or "yue" == targetExt or "ts" == targetExt or "tsx" == targetExt or "vs" == targetExt or "bl" == targetExt or "xml" == targetExt or "lua" == targetExt) or not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1737
								goto _continue_0 -- 1738
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1739
								goto _continue_0 -- 1740
							end -- 1737
							return { -- 1741
								success = false, -- 1741
								message = "SourceExisted" -- 1741
							} -- 1741
						end -- 1735
						::_continue_0:: -- 1735
					end -- 1734
					if Content:save(path, content) then -- 1742
						return { -- 1743
							success = true -- 1743
						} -- 1743
					end -- 1742
				end -- 1724
			end -- 1719
		end -- 1719
	end -- 1719
	return { -- 1718
		success = false, -- 1718
		message = "Failed" -- 1718
	} -- 1718
end) -- 1718
local deleteAsset -- 1745
deleteAsset = function(path) -- 1745
	if not Content:exist(path) then -- 1746
		return false -- 1746
	end -- 1746
	local projectRoot -- 1747
	if Content:isdir(path) and isProjectRootDir(path) then -- 1747
		projectRoot = path -- 1747
	else -- 1747
		projectRoot = nil -- 1747
	end -- 1747
	local parent = Path:getPath(path) -- 1748
	local files = Content:getFiles(parent) -- 1749
	local name = Path:getName(path):lower() -- 1750
	local ext = Path:getExt(path) -- 1751
	for _index_0 = 1, #files do -- 1752
		local file = files[_index_0] -- 1752
		if name == Path:getName(file):lower() then -- 1753
			local _exp_0 = Path:getExt(file) -- 1754
			if "tl" == _exp_0 then -- 1754
				if ("vs" == ext) then -- 1754
					Content:remove(Path(parent, file)) -- 1755
				end -- 1754
			elseif "lua" == _exp_0 then -- 1756
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1756
					Content:remove(Path(parent, file)) -- 1757
				end -- 1756
			end -- 1754
		end -- 1753
	end -- 1752
	if Content:remove(path) then -- 1758
		if projectRoot then -- 1759
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1760
		end -- 1759
		return true -- 1761
	end -- 1758
	return false -- 1762
end -- 1745
local moveAsset -- 1764
moveAsset = function(old, new) -- 1764
	if not (Content:exist(old) and not Content:exist(new)) then -- 1765
		return false -- 1765
	end -- 1765
	local renamedDir = Content:isdir(old) -- 1766
	local parent = Path:getPath(new) -- 1767
	local files = Content:getFiles(parent) -- 1768
	if renamedDir then -- 1769
		local name = Path:getFilename(new):lower() -- 1770
		for _index_0 = 1, #files do -- 1771
			local file = files[_index_0] -- 1771
			if name == Path:getFilename(file):lower() then -- 1772
				return false -- 1773
			end -- 1772
		end -- 1771
	else -- 1775
		local name = Path:getName(new):lower() -- 1775
		local ext = Path:getExt(new) -- 1776
		for _index_0 = 1, #files do -- 1777
			local file = files[_index_0] -- 1777
			if name == Path:getName(file):lower() then -- 1778
				local fileExt = Path:getExt(file) -- 1779
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) or not ("tl" == fileExt or "yue" == fileExt or "ts" == fileExt or "tsx" == fileExt or "vs" == fileExt or "bl" == fileExt or "xml" == fileExt or "lua" == fileExt) then -- 1780
					goto _continue_0 -- 1781
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1782
					goto _continue_0 -- 1783
				end -- 1780
				return false -- 1784
			end -- 1778
			::_continue_0:: -- 1778
		end -- 1777
	end -- 1769
	if not Content:move(old, new) then -- 1785
		return false -- 1785
	end -- 1785
	if renamedDir then -- 1786
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1787
	end -- 1786
	local newParent = Path:getPath(new) -- 1788
	parent = Path:getPath(old) -- 1789
	files = Content:getFiles(parent) -- 1790
	local newName = Path:getName(new) -- 1791
	local oldName = Path:getName(old) -- 1792
	local name = oldName:lower() -- 1793
	local ext = Path:getExt(old) -- 1794
	for _index_0 = 1, #files do -- 1795
		local file = files[_index_0] -- 1795
		if name == Path:getName(file):lower() then -- 1796
			local _exp_0 = Path:getExt(file) -- 1797
			if "tl" == _exp_0 then -- 1797
				if ("vs" == ext) then -- 1797
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1798
				end -- 1797
			elseif "lua" == _exp_0 then -- 1799
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1799
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1800
				end -- 1799
			end -- 1797
		end -- 1796
	end -- 1795
	return true -- 1801
end -- 1764
HttpServer:post("/delete", function(req) -- 1803
	do -- 1804
		local _type_0 = type(req) -- 1804
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1804
		if _tab_0 then -- 1804
			local path -- 1804
			do -- 1804
				local _obj_0 = req.body -- 1804
				local _type_1 = type(_obj_0) -- 1804
				if "table" == _type_1 or "userdata" == _type_1 then -- 1804
					path = _obj_0.path -- 1804
				end -- 1804
			end -- 1804
			if path ~= nil then -- 1804
				if deleteAsset(path) then -- 1805
					return { -- 1805
						success = true -- 1805
					} -- 1805
				end -- 1805
			end -- 1804
		end -- 1804
	end -- 1804
	return { -- 1803
		success = false -- 1803
	} -- 1803
end) -- 1803
HttpServer:post("/rename", function(req) -- 1807
	do -- 1808
		local _type_0 = type(req) -- 1808
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1808
		if _tab_0 then -- 1808
			local old -- 1808
			do -- 1808
				local _obj_0 = req.body -- 1808
				local _type_1 = type(_obj_0) -- 1808
				if "table" == _type_1 or "userdata" == _type_1 then -- 1808
					old = _obj_0.old -- 1808
				end -- 1808
			end -- 1808
			local new -- 1808
			do -- 1808
				local _obj_0 = req.body -- 1808
				local _type_1 = type(_obj_0) -- 1808
				if "table" == _type_1 or "userdata" == _type_1 then -- 1808
					new = _obj_0.new -- 1808
				end -- 1808
			end -- 1808
			if old ~= nil and new ~= nil then -- 1808
				if moveAsset(old, new) then -- 1809
					return { -- 1809
						success = true -- 1809
					} -- 1809
				end -- 1809
			end -- 1808
		end -- 1808
	end -- 1808
	return { -- 1807
		success = false -- 1807
	} -- 1807
end) -- 1807
local normalizeAssetPaths -- 1811
normalizeAssetPaths = function(paths) -- 1811
	if not (type(paths) == "table") then -- 1812
		return nil -- 1812
	end -- 1812
	local unique = { } -- 1813
	local candidates = { } -- 1814
	for _index_0 = 1, #paths do -- 1815
		local path = paths[_index_0] -- 1815
		if not (type(path) == "string") then -- 1816
			return nil -- 1816
		end -- 1816
		local relative = relativeToRoot(path, Content.writablePath) -- 1817
		if relative == nil or relative == "" or not Content:exist(path) then -- 1818
			return nil -- 1818
		end -- 1818
		if not unique[path] then -- 1819
			unique[path] = true -- 1820
			candidates[#candidates + 1] = path -- 1821
		end -- 1819
	end -- 1815
	table.sort(candidates, function(a, b) -- 1822
		return #a < #b -- 1822
	end) -- 1822
	local result = { } -- 1823
	for _index_0 = 1, #candidates do -- 1824
		local path = candidates[_index_0] -- 1824
		local contained = false -- 1825
		for _index_1 = 1, #result do -- 1826
			local parent = result[_index_1] -- 1826
			if relativeToRoot(path, parent) ~= nil then -- 1827
				contained = true -- 1828
				break -- 1829
			end -- 1827
		end -- 1826
		if not contained then -- 1830
			result[#result + 1] = path -- 1830
		end -- 1830
	end -- 1824
	return result -- 1831
end -- 1811
HttpServer:postSchedule("/assets/batch", function(req) -- 1833
	do -- 1834
		local _type_0 = type(req) -- 1834
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1834
		if _tab_0 then -- 1834
			local operation -- 1834
			do -- 1834
				local _obj_0 = req.body -- 1834
				local _type_1 = type(_obj_0) -- 1834
				if "table" == _type_1 or "userdata" == _type_1 then -- 1834
					operation = _obj_0.operation -- 1834
				end -- 1834
			end -- 1834
			local sources -- 1834
			do -- 1834
				local _obj_0 = req.body -- 1834
				local _type_1 = type(_obj_0) -- 1834
				if "table" == _type_1 or "userdata" == _type_1 then -- 1834
					sources = _obj_0.sources -- 1834
				end -- 1834
			end -- 1834
			if operation ~= nil and sources ~= nil then -- 1834
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1835
					return { -- 1835
						success = false, -- 1835
						message = "invalid operation" -- 1835
					} -- 1835
				end -- 1835
				sources = normalizeAssetPaths(sources) -- 1836
				if not (sources and #sources > 0) then -- 1837
					return { -- 1837
						success = false, -- 1837
						message = "invalid sources" -- 1837
					} -- 1837
				end -- 1837
				local target = req.body.target -- 1838
				local destinations = { } -- 1839
				if operation ~= "delete" then -- 1840
					if not (type(target) == "string") then -- 1841
						return { -- 1841
							success = false, -- 1841
							message = "invalid target" -- 1841
						} -- 1841
					end -- 1841
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1842
					if targetRelative == nil then -- 1843
						return { -- 1843
							success = false, -- 1843
							message = "invalid target" -- 1843
						} -- 1843
					end -- 1843
					if not (Content:exist(target) and Content:isdir(target)) then -- 1844
						return { -- 1844
							success = false, -- 1844
							message = "invalid target" -- 1844
						} -- 1844
					end -- 1844
					for _index_0 = 1, #sources do -- 1845
						local source = sources[_index_0] -- 1845
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1846
							return { -- 1847
								success = false, -- 1847
								message = "target inside source" -- 1847
							} -- 1847
						end -- 1846
						local destination = Path(target, Path:getFilename(source)) -- 1848
						if Content:exist(destination) then -- 1849
							return { -- 1849
								success = false, -- 1849
								message = "target existed" -- 1849
							} -- 1849
						end -- 1849
						if destinations[destination] then -- 1850
							return { -- 1850
								success = false, -- 1850
								message = "duplicate target" -- 1850
							} -- 1850
						end -- 1850
						destinations[destination] = true -- 1851
					end -- 1845
				end -- 1840
				local changes = { } -- 1852
				local affectedSet = { } -- 1853
				local affectedDirectories = { } -- 1854
				local addAffected -- 1855
				addAffected = function(dir) -- 1855
					if affectedSet[dir] then -- 1856
						return -- 1856
					end -- 1856
					affectedSet[dir] = true -- 1857
					affectedDirectories[#affectedDirectories + 1] = dir -- 1858
				end -- 1855
				if operation ~= "delete" then -- 1859
					addAffected(target) -- 1859
				end -- 1859
				for _index_0 = 1, #sources do -- 1860
					local source = sources[_index_0] -- 1860
					addAffected(Path:getPath(source)) -- 1861
					if operation == "delete" then -- 1862
						if not deleteAsset(source) then -- 1863
							return { -- 1863
								success = false, -- 1863
								message = "delete failed", -- 1863
								changes = changes, -- 1863
								affectedDirectories = affectedDirectories -- 1863
							} -- 1863
						end -- 1863
						changes[#changes + 1] = { -- 1864
							old = source -- 1864
						} -- 1864
					else -- 1866
						local destination = Path(target, Path:getFilename(source)) -- 1866
						local ok -- 1867
						if operation == "copy" then -- 1867
							ok = Content:copyAsync(source, destination) -- 1868
						else -- 1870
							ok = moveAsset(source, destination) -- 1870
						end -- 1867
						if not ok then -- 1871
							return { -- 1871
								success = false, -- 1871
								message = operation .. " failed", -- 1871
								changes = changes, -- 1871
								affectedDirectories = affectedDirectories -- 1871
							} -- 1871
						end -- 1871
						changes[#changes + 1] = { -- 1872
							old = source, -- 1872
							new = destination -- 1872
						} -- 1872
					end -- 1862
				end -- 1860
				return { -- 1873
					success = true, -- 1873
					changes = changes, -- 1873
					affectedDirectories = affectedDirectories -- 1873
				} -- 1873
			end -- 1834
		end -- 1834
	end -- 1834
	return { -- 1833
		success = false, -- 1833
		message = "invalid request" -- 1833
	} -- 1833
end) -- 1833
local withProjectSearchPaths -- 1875
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1875
	local fallbackPaths = { } -- 1876
	local addFallback -- 1877
	addFallback = function(dir) -- 1877
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1877
			fallbackPaths[#fallbackPaths + 1] = dir -- 1877
		end -- 1877
	end -- 1877
	if projectRoot and projectRoot ~= "" then -- 1878
		addFallback(Path(projectRoot, "Script")) -- 1879
		addFallback(projectRoot) -- 1880
	end -- 1878
	if projFile then -- 1881
		local projDir = getProjectDirFromFile(projFile) -- 1882
		if projDir then -- 1882
			addFallback(Path(projDir, "Script")) -- 1883
			addFallback(projDir) -- 1884
		else -- 1886
			addFallback(Path:getPath(projFile)) -- 1886
		end -- 1882
	end -- 1881
	if not (#fallbackPaths > 0) then -- 1887
		return fn() -- 1887
	end -- 1887
	local searchPaths = Content.searchPaths -- 1888
	for _index_0 = 1, #fallbackPaths do -- 1889
		local dir = fallbackPaths[_index_0] -- 1889
		Content:addSearchPath(dir) -- 1889
	end -- 1889
	local _ <close> = setmetatable({ }, { -- 1890
		__close = function() -- 1890
			Content.searchPaths = searchPaths -- 1890
		end -- 1890
	}) -- 1890
	return fn() -- 1891
end -- 1875
HttpServer:post("/exist", function(req) -- 1892
	do -- 1893
		local _type_0 = type(req) -- 1893
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1893
		if _tab_0 then -- 1893
			local file -- 1893
			do -- 1893
				local _obj_0 = req.body -- 1893
				local _type_1 = type(_obj_0) -- 1893
				if "table" == _type_1 or "userdata" == _type_1 then -- 1893
					file = _obj_0.file -- 1893
				end -- 1893
			end -- 1893
			if file ~= nil then -- 1893
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1894
					return { -- 1895
						success = Content:exist(file) -- 1895
					} -- 1895
				end) -- 1894
			end -- 1893
		end -- 1893
	end -- 1893
	return { -- 1892
		success = false -- 1892
	} -- 1892
end) -- 1892
HttpServer:postSchedule("/read", function(req) -- 1896
	do -- 1897
		local _type_0 = type(req) -- 1897
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1897
		if _tab_0 then -- 1897
			local path -- 1897
			do -- 1897
				local _obj_0 = req.body -- 1897
				local _type_1 = type(_obj_0) -- 1897
				if "table" == _type_1 or "userdata" == _type_1 then -- 1897
					path = _obj_0.path -- 1897
				end -- 1897
			end -- 1897
			if path ~= nil then -- 1897
				local readFile -- 1898
				readFile = function() -- 1898
					if Content:exist(path) and not Content:isdir(path) then -- 1899
						local content = Content:loadAsync(path) -- 1900
						if content then -- 1900
							return { -- 1901
								content = content, -- 1901
								success = true, -- 1901
								fullPath = Content:getFullPath(path) -- 1901
							} -- 1901
						end -- 1900
					end -- 1899
					return nil -- 1898
				end -- 1898
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1902
				if result then -- 1902
					return result -- 1902
				end -- 1902
			end -- 1897
		end -- 1897
	end -- 1897
	return { -- 1896
		success = false -- 1896
	} -- 1896
end) -- 1896
local agentDocLanguage -- 1904
agentDocLanguage = function(language) -- 1904
	if language == "zh-Hans" then -- 1905
		return "zh" -- 1905
	else -- 1905
		return "en" -- 1905
	end -- 1905
end -- 1904
HttpServer:postSchedule("/doc/search", function(req) -- 1907
	local body = req.body or { } -- 1908
	local language = body.docLanguage -- 1909
	if not (("en" == language or "zh-Hans" == language)) then -- 1910
		return { -- 1910
			success = false, -- 1910
			message = "unsupported doc language" -- 1910
		} -- 1910
	end -- 1910
	local docType = body.docType -- 1911
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1912
		return { -- 1912
			success = false, -- 1912
			message = "unsupported doc type" -- 1912
		} -- 1912
	end -- 1912
	local codeLanguage = body.programmingLanguage -- 1913
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1914
		return { -- 1914
			success = false, -- 1914
			message = "unsupported programming language" -- 1914
		} -- 1914
	end -- 1914
	if not body.pattern then -- 1915
		return { -- 1915
			success = false, -- 1915
			message = "missing pattern" -- 1915
		} -- 1915
	end -- 1915
	local result = nil -- 1916
	AgentTools.searchDoraDocHttp({ -- 1918
		pattern = body.pattern, -- 1918
		docLanguage = agentDocLanguage(language), -- 1919
		docType = docType, -- 1920
		programmingLanguage = codeLanguage, -- 1921
		limit = body.limit, -- 1922
		useRegex = body.useRegex, -- 1923
		caseSensitive = body.caseSensitive, -- 1924
		includeContent = body.includeContent, -- 1925
		contentWindow = body.contentWindow -- 1926
	}, function(res) -- 1927
		result = res -- 1928
	end) -- 1917
	wait(function() -- 1929
		return result ~= nil -- 1929
	end) -- 1929
	if result and result.success then -- 1930
		result.docLanguage = language -- 1931
	end -- 1930
	if result then -- 1932
		return result -- 1933
	else -- 1935
		return { -- 1935
			success = false, -- 1935
			message = "doc search failed" -- 1935
		} -- 1935
	end -- 1932
	return { -- 1907
		success = false, -- 1907
		message = "invalid call" -- 1907
	} -- 1907
end) -- 1907
HttpServer:postSchedule("/doc/read", function(req) -- 1937
	local body = req.body or { } -- 1938
	local language = body.docLanguage -- 1939
	if not (("en" == language or "zh-Hans" == language)) then -- 1940
		return { -- 1940
			success = false, -- 1940
			message = "unsupported doc language" -- 1940
		} -- 1940
	end -- 1940
	if not body.file then -- 1941
		return { -- 1941
			success = false, -- 1941
			message = "missing file" -- 1941
		} -- 1941
	end -- 1941
	local result = AgentTools.readDoraDoc({ -- 1943
		docLanguage = agentDocLanguage(language), -- 1943
		file = body.file, -- 1944
		startLine = body.startLine, -- 1945
		endLine = body.endLine -- 1946
	}) -- 1942
	if result and result.success then -- 1947
		result.docLanguage = language -- 1948
	end -- 1947
	return result -- 1949
end) -- 1937
local readSyncFile -- 1951
readSyncFile = function(req) -- 1951
	do -- 1952
		local _type_0 = type(req) -- 1952
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1952
		if _tab_0 then -- 1952
			local params = req.params -- 1952
			if params ~= nil then -- 1952
				local path = params.path -- 1953
				if not (type(path) == "string" and path ~= "") then -- 1954
					return { -- 1954
						success = false, -- 1954
						message = "invalid path" -- 1954
					} -- 1954
				end -- 1954
				local exts -- 1955
				if params.exts then -- 1955
					local _accum_0 = { } -- 1956
					local _len_0 = 1 -- 1956
					for ext in params.exts:gmatch("[^|]*") do -- 1956
						_accum_0[_len_0] = ext -- 1956
						_len_0 = _len_0 + 1 -- 1956
					end -- 1956
					exts = _accum_0 -- 1956
				else -- 1957
					exts = { -- 1957
						"" -- 1957
					} -- 1957
				end -- 1955
				local readFileAt -- 1958
				readFileAt = function(targetPath) -- 1958
					if Content:exist(targetPath) then -- 1959
						local content = Content:load(targetPath) -- 1960
						if content then -- 1960
							return { -- 1961
								content = content, -- 1961
								success = true, -- 1961
								fullPath = Content:getFullPath(targetPath) -- 1961
							} -- 1961
						end -- 1960
					end -- 1959
					return nil -- 1958
				end -- 1958
				local readFile -- 1962
				readFile = function(fallbackPaths) -- 1962
					for _index_0 = 1, #exts do -- 1963
						local ext = exts[_index_0] -- 1963
						local targetPath = path .. ext -- 1964
						if not Content:isAbsolutePath(targetPath) then -- 1965
							for _index_1 = 1, #fallbackPaths do -- 1966
								local fallback = fallbackPaths[_index_1] -- 1966
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1967
								if fallbackResult then -- 1967
									return fallbackResult -- 1968
								end -- 1967
							end -- 1966
						end -- 1965
						local fileResult = readFileAt(targetPath) -- 1969
						if fileResult then -- 1969
							return fileResult -- 1970
						end -- 1969
					end -- 1963
					return nil -- 1962
				end -- 1962
				local fallbackPaths = { } -- 1971
				local fallbackCandidates = { } -- 1972
				do -- 1973
					local projectRoot = req.params.projectRoot -- 1973
					if projectRoot then -- 1973
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1974
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1975
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1976
						end -- 1974
					end -- 1973
				end -- 1973
				do -- 1977
					local projFile = req.params.projFile -- 1977
					if projFile then -- 1977
						local projDir = getProjectDirFromFile(projFile) -- 1978
						if projDir then -- 1978
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1979
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1980
						else -- 1982
							projDir = Path:getPath(projFile) -- 1982
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1983
						end -- 1978
					end -- 1977
				end -- 1977
				for _index_0 = 1, #fallbackCandidates do -- 1984
					local dir = fallbackCandidates[_index_0] -- 1984
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1985
						local exists = false -- 1986
						for _index_1 = 1, #fallbackPaths do -- 1987
							local fallback = fallbackPaths[_index_1] -- 1987
							if fallback == dir then -- 1988
								exists = true -- 1989
								break -- 1990
							end -- 1988
						end -- 1987
						if not exists then -- 1991
							fallbackPaths[#fallbackPaths + 1] = dir -- 1991
						end -- 1991
					end -- 1985
				end -- 1984
				local readResult = readFile(fallbackPaths) -- 1992
				if readResult then -- 1992
					return readResult -- 1993
				end -- 1992
			end -- 1952
		end -- 1952
	end -- 1952
	return { -- 1951
		success = false -- 1951
	} -- 1951
end -- 1951
HttpServer:get("/read-sync", readSyncFile) -- 1995
HttpServer:post("/read-sync", function(req) -- 1996
	return readSyncFile({ -- 1996
		params = req.body -- 1996
	}) -- 1996
end) -- 1996
local addGeneratedSourceHeader -- 1998
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 1998
	if preserveTIC80 == nil then -- 1998
		preserveTIC80 = false -- 1998
	end -- 1998
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 1999
	if preserveTIC80 then -- 2000
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 2001
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 2002
		end -- 2001
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 2003
	end -- 2000
	return tostring(header) .. "\n" .. tostring(codes) -- 2004
end -- 1998
local compileFileAsync -- 2006
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 2006
	if projectRoot == nil then -- 2006
		projectRoot = nil -- 2006
	end -- 2006
	local file = inputFile -- 2007
	local searchPath -- 2008
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2008
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 2009
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 2013
	elseif not Content:isAbsolutePath(inputFile) then -- 2014
		searchPath = "" -- 2015
	else -- 2016
		local dir = getProjectDirFromFile(inputFile) -- 2016
		if dir then -- 2016
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2017
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 2021
		else -- 2023
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2023
			searchPath = "" -- 2026
		end -- 2016
	end -- 2008
	local outputFile = Path:replaceExt(inputFile, "lua") -- 2027
	local yueext = yue.options.extension -- 2028
	local resultCodes = nil -- 2029
	local resultError = nil -- 2030
	do -- 2031
		local _exp_0 = Path:getExt(inputFile) -- 2031
		if yueext == _exp_0 then -- 2031
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 2032
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 2033
				if not codes then -- 2034
					resultError = err -- 2035
					return -- 2036
				end -- 2034
				local extraGlobal -- 2037
				if isTIC80 then -- 2037
					extraGlobal = tic80APIs -- 2037
				else -- 2037
					extraGlobal = nil -- 2037
				end -- 2037
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 2038
				if not success then -- 2039
					resultError = message -- 2040
					return -- 2041
				end -- 2039
				if codes == "" then -- 2042
					resultCodes = "" -- 2043
					return nil -- 2044
				end -- 2042
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 2045
				return resultCodes -- 2046
			end, function(success) -- 2033
				if not success then -- 2047
					Content:remove(outputFile) -- 2048
					if resultCodes == nil then -- 2049
						resultCodes = false -- 2050
					end -- 2049
				end -- 2047
			end) -- 2033
		elseif "tl" == _exp_0 then -- 2051
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 2052
			if isTIC80 then -- 2053
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2054
			end -- 2053
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2055
			if codes then -- 2055
				if isTIC80 then -- 2056
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2057
				end -- 2056
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2058
				Content:saveAsync(outputFile, resultCodes) -- 2059
			else -- 2061
				Content:remove(outputFile) -- 2061
				resultCodes = false -- 2062
				resultError = err -- 2063
			end -- 2055
		elseif "xml" == _exp_0 then -- 2064
			local codes, err = xml.tolua(sourceCodes) -- 2065
			if codes then -- 2065
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2066
				Content:saveAsync(outputFile, resultCodes) -- 2067
			else -- 2069
				Content:remove(outputFile) -- 2069
				resultCodes = false -- 2070
				resultError = err -- 2071
			end -- 2065
		end -- 2031
	end -- 2031
	wait(function() -- 2072
		return resultCodes ~= nil -- 2072
	end) -- 2072
	if resultCodes then -- 2073
		return resultCodes -- 2074
	else -- 2076
		return nil, resultError -- 2076
	end -- 2073
	return nil -- 2006
end -- 2006
HttpServer:postSchedule("/write", function(req) -- 2078
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2079
	local buildSucceeded = false -- 2080
	local _ <close> = setmetatable({ }, { -- 2081
		__close = function() -- 2081
			return finishUpdate(buildSucceeded) -- 2081
		end -- 2081
	}) -- 2081
	do -- 2082
		local _type_0 = type(req) -- 2082
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2082
		if _tab_0 then -- 2082
			local path -- 2082
			do -- 2082
				local _obj_0 = req.body -- 2082
				local _type_1 = type(_obj_0) -- 2082
				if "table" == _type_1 or "userdata" == _type_1 then -- 2082
					path = _obj_0.path -- 2082
				end -- 2082
			end -- 2082
			local content -- 2082
			do -- 2082
				local _obj_0 = req.body -- 2082
				local _type_1 = type(_obj_0) -- 2082
				if "table" == _type_1 or "userdata" == _type_1 then -- 2082
					content = _obj_0.content -- 2082
				end -- 2082
			end -- 2082
			if path ~= nil and content ~= nil then -- 2082
				if Content:saveAsync(path, content) then -- 2083
					do -- 2084
						local _exp_0 = Path:getExt(path) -- 2084
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2084
							if '' == Path:getExt(Path:getName(path)) then -- 2085
								local resultCodes = compileFileAsync(path, content) -- 2086
								buildSucceeded = resultCodes ~= nil -- 2087
								return { -- 2088
									success = true, -- 2088
									resultCodes = resultCodes -- 2088
								} -- 2088
							end -- 2085
						end -- 2084
					end -- 2084
					buildSucceeded = true -- 2089
					return { -- 2090
						success = true -- 2090
					} -- 2090
				end -- 2083
			end -- 2082
		end -- 2082
	end -- 2082
	return { -- 2078
		success = false -- 2078
	} -- 2078
end) -- 2078
local getWaProjectDirFromFile = nil -- 2092
HttpServer:postSchedule("/build", function(req) -- 2094
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2095
	local buildSucceeded = false -- 2096
	local _ <close> = setmetatable({ }, { -- 2097
		__close = function() -- 2097
			return finishUpdate(buildSucceeded) -- 2097
		end -- 2097
	}) -- 2097
	do -- 2098
		local _type_0 = type(req) -- 2098
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2098
		if _tab_0 then -- 2098
			local path -- 2098
			do -- 2098
				local _obj_0 = req.body -- 2098
				local _type_1 = type(_obj_0) -- 2098
				if "table" == _type_1 or "userdata" == _type_1 then -- 2098
					path = _obj_0.path -- 2098
				end -- 2098
			end -- 2098
			if path ~= nil then -- 2098
				local projectRoot = req.body.projectRoot -- 2099
				if Content:isdir(path) then -- 2100
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
					end -- 2101
				end -- 2100
				local _exp_0 = Path:getExt(path) -- 2107
				if "gd" == _exp_0 or "tscn" == _exp_0 or "tres" == _exp_0 or "gdshader" == _exp_0 or "gdshaderinc" == _exp_0 then -- 2108
					local content = Content:loadAsync(path) -- 2109
					if content then -- 2109
						local result = godotCheckAsync(path, content, false) -- 2110
						buildSucceeded = result.success and not result.skipped -- 2111
						return { -- 2112
							success = buildSucceeded, -- 2112
							resultCodes = "", -- 2112
							info = result.info -- 2112
						} -- 2112
					end -- 2109
				elseif "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2113
					if '' == Path:getExt(Path:getName(path)) then -- 2114
						local content = Content:loadAsync(path) -- 2115
						if content then -- 2115
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2116
							if resultCodes then -- 2116
								buildSucceeded = true -- 2117
								return { -- 2118
									success = true, -- 2118
									resultCodes = resultCodes -- 2118
								} -- 2118
							end -- 2116
						end -- 2115
					end -- 2114
				elseif "wa" == _exp_0 then -- 2119
					local projDir = getWaProjectDirFromFile(path) -- 2120
					if projDir then -- 2120
						local message = Wasm:buildWaAsync(projDir) -- 2121
						if message == "" then -- 2122
							return { -- 2123
								success = true -- 2123
							} -- 2123
						else -- 2125
							return { -- 2125
								success = false, -- 2125
								message = message -- 2125
							} -- 2125
						end -- 2122
					else -- 2127
						return { -- 2127
							success = false, -- 2127
							message = 'Wa file needs a project' -- 2127
						} -- 2127
					end -- 2120
				end -- 2107
			end -- 2098
		end -- 2098
	end -- 2098
	return { -- 2094
		success = false -- 2094
	} -- 2094
end) -- 2094
local extentionLevels = { -- 2130
	vs = 2, -- 2130
	bl = 2, -- 2131
	ts = 1, -- 2132
	tsx = 1, -- 2133
	tl = 1, -- 2134
	yue = 1, -- 2135
	xml = 1, -- 2136
	lua = 0 -- 2137
} -- 2129
local visitAssets -- 2139
visitAssets = function(path, workspace, builtin, recursive) -- 2139
	if recursive == nil then -- 2139
		recursive = true -- 2139
	end -- 2139
	local children = nil -- 2140
	local dirs = Content:getDirs(path) -- 2141
	for _index_0 = 1, #dirs do -- 2142
		local dir = dirs[_index_0] -- 2142
		if workspace then -- 2143
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or ".godot" == dir or "node_modules" == dir) then -- 2144
				goto _continue_0 -- 2145
			end -- 2144
		elseif dir == ".git" or dir == ".godot" then -- 2146
			goto _continue_0 -- 2147
		end -- 2143
		if not children then -- 2148
			children = { } -- 2148
		end -- 2148
		local dirPath = Path(path, dir) -- 2149
		if recursive then -- 2150
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2151
		else -- 2153
			children[#children + 1] = { -- 2154
				key = dirPath, -- 2154
				dir = true, -- 2155
				title = dir, -- 2156
				builtin = builtin, -- 2157
				isLeaf = false -- 2158
			} -- 2153
		end -- 2150
		::_continue_0:: -- 2143
	end -- 2142
	local files = Content:getFiles(path) -- 2160
	local names = { } -- 2161
	for _index_0 = 1, #files do -- 2162
		local file = files[_index_0] -- 2162
		if (".DS_Store" == file) then -- 2163
			goto _continue_1 -- 2164
		end -- 2163
		local ext = Path:getExt(file) -- 2165
		if not extentionLevels[ext] then -- 2166
			names[file] = "" -- 2167
			goto _continue_1 -- 2168
		end -- 2166
		local name = Path:getName(file) -- 2169
		ext = names[name] -- 2170
		if ext then -- 2170
			local lv1 -- 2171
			do -- 2171
				local _exp_0 = extentionLevels[ext] -- 2171
				if _exp_0 ~= nil then -- 2171
					lv1 = _exp_0 -- 2171
				else -- 2171
					lv1 = -1 -- 2171
				end -- 2171
			end -- 2171
			ext = Path:getExt(file) -- 2172
			local lv2 -- 2173
			do -- 2173
				local _exp_0 = extentionLevels[ext] -- 2173
				if _exp_0 ~= nil then -- 2173
					lv2 = _exp_0 -- 2173
				else -- 2173
					lv2 = -1 -- 2173
				end -- 2173
			end -- 2173
			if lv2 > lv1 then -- 2174
				names[name] = ext -- 2175
			elseif lv2 == lv1 then -- 2176
				names[name .. '.' .. ext] = "" -- 2177
			end -- 2174
		else -- 2179
			ext = Path:getExt(file) -- 2179
			if not extentionLevels[ext] then -- 2180
				names[file] = "" -- 2181
			else -- 2183
				names[name] = ext -- 2183
			end -- 2180
		end -- 2170
		::_continue_1:: -- 2163
	end -- 2162
	do -- 2184
		local _accum_0 = { } -- 2184
		local _len_0 = 1 -- 2184
		for name, ext in pairs(names) do -- 2184
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2184
			_len_0 = _len_0 + 1 -- 2184
		end -- 2184
		files = _accum_0 -- 2184
	end -- 2184
	for _index_0 = 1, #files do -- 2185
		local file = files[_index_0] -- 2185
		if not children then -- 2186
			children = { } -- 2186
		end -- 2186
		children[#children + 1] = { -- 2188
			key = Path(path, file), -- 2188
			dir = false, -- 2189
			title = file, -- 2190
			builtin = builtin -- 2191
		} -- 2187
	end -- 2185
	if children then -- 2193
		table.sort(children, function(a, b) -- 2194
			if a.dir == b.dir then -- 2195
				return a.title < b.title -- 2196
			else -- 2198
				return a.dir -- 2198
			end -- 2195
		end) -- 2194
	end -- 2193
	return { -- 2200
		key = path, -- 2200
		dir = true, -- 2201
		title = Path:getFilename(path), -- 2202
		builtin = builtin, -- 2203
		isLeaf = not children, -- 2204
		children = children -- 2205
	} -- 2199
end -- 2139
HttpServer:post("/assets/children", function(req) -- 2208
	do -- 2209
		local _type_0 = type(req) -- 2209
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2209
		if _tab_0 then -- 2209
			local path -- 2209
			do -- 2209
				local _obj_0 = req.body -- 2209
				local _type_1 = type(_obj_0) -- 2209
				if "table" == _type_1 or "userdata" == _type_1 then -- 2209
					path = _obj_0.path -- 2209
				end -- 2209
			end -- 2209
			if path ~= nil then -- 2209
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2210
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2211
					return { -- 2211
						success = false -- 2211
					} -- 2211
				end -- 2211
				local node = visitAssets(path, workspace, builtin, false) -- 2212
				return { -- 2213
					success = true, -- 2213
					children = node.children or { } -- 2213
				} -- 2213
			end -- 2209
		end -- 2209
	end -- 2209
	return { -- 2208
		success = false -- 2208
	} -- 2208
end) -- 2208
HttpServer:post("/assets/files", function(req) -- 2215
	do -- 2216
		local _type_0 = type(req) -- 2216
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2216
		if _tab_0 then -- 2216
			local path -- 2216
			do -- 2216
				local _obj_0 = req.body -- 2216
				local _type_1 = type(_obj_0) -- 2216
				if "table" == _type_1 or "userdata" == _type_1 then -- 2216
					path = _obj_0.path -- 2216
				end -- 2216
			end -- 2216
			if path ~= nil then -- 2216
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2217
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2218
				if not (workspace or builtin) then -- 2219
					return { -- 2219
						success = false -- 2219
					} -- 2219
				end -- 2219
				if not (Content:exist(path) and Content:isdir(path)) then -- 2220
					return { -- 2220
						success = false -- 2220
					} -- 2220
				end -- 2220
				local globs = { -- 2221
					"**", -- 2221
					"!**/.DS_Store", -- 2221
					"!**/.godot/**" -- 2221
				} -- 2221
				if workspace then -- 2222
					globs = { -- 2224
						"**", -- 2224
						"!**/.DS_Store", -- 2224
						"!**/.upload/**", -- 2225
						"!**/.download/**", -- 2225
						"!**/.www/**", -- 2226
						"!**/.build/**", -- 2226
						"!**/.git/**", -- 2227
						"!**/.cache/**", -- 2227
						"!**/.godot/**", -- 2228
						"!**/node_modules/**" -- 2229
					} -- 2223
				end -- 2222
				local files -- 2231
				do -- 2231
					local _accum_0 = { } -- 2231
					local _len_0 = 1 -- 2231
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2231
					for _index_0 = 1, #_list_0 do -- 2231
						local file = _list_0[_index_0] -- 2231
						_accum_0[_len_0] = Path(path, file) -- 2231
						_len_0 = _len_0 + 1 -- 2231
					end -- 2231
					files = _accum_0 -- 2231
				end -- 2231
				return { -- 2232
					success = true, -- 2232
					files = files -- 2232
				} -- 2232
			end -- 2216
		end -- 2216
	end -- 2216
	return { -- 2215
		success = false -- 2215
	} -- 2215
end) -- 2215
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2273
	local _tab_0 = { -- 2273
		{ -- 2274
			key = Path(Content.assetPath), -- 2274
			dir = true, -- 2275
			builtin = true, -- 2276
			title = zh and "内置资源" or "Built-in", -- 2277
			children = builtinChildren -- 2278
		} -- 2273
	} -- 2280
	local _obj_0 = workspace.children or { } -- 2280
	local _idx_0 = #_tab_0 + 1 -- 2280
	for _index_0 = 1, #_obj_0 do -- 2280
		local _value_0 = _obj_0[_index_0] -- 2280
		_tab_0[_idx_0] = _value_0 -- 2280
		_idx_0 = _idx_0 + 1 -- 2280
	end -- 2280
	return _tab_0 -- 2273
end -- 2273
HttpServer:post("/assets", function() -- 2234
	local Entry = require("Script.Dev.Entry") -- 2235
	local engineDev = Entry.getEngineDev() -- 2236
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2237
	local zh = (App.locale:match("^zh") ~= nil) -- 2238
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2239
	readme.title = zh and "说明文档" or "Readme" -- 2240
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2241
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2242
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2243
	tools.title = zh and "开发工具" or "Tools" -- 2244
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2245
	font.title = zh and "字体" or "Font" -- 2246
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2247
	lib.title = zh and "程序库" or "Lib" -- 2248
	if engineDev then -- 2249
		local _list_0 = lib.children -- 2250
		for _index_0 = 1, #_list_0 do -- 2250
			local child = _list_0[_index_0] -- 2250
			if not (child.title == "Dora") then -- 2251
				goto _continue_0 -- 2251
			end -- 2251
			local title = zh and "zh-Hans" or "en" -- 2252
			do -- 2253
				local _accum_0 = { } -- 2253
				local _len_0 = 1 -- 2253
				local _list_1 = child.children -- 2253
				for _index_1 = 1, #_list_1 do -- 2253
					local c = _list_1[_index_1] -- 2253
					if c.title ~= title then -- 2253
						_accum_0[_len_0] = c -- 2253
						_len_0 = _len_0 + 1 -- 2253
					end -- 2253
				end -- 2253
				child.children = _accum_0 -- 2253
			end -- 2253
			break -- 2254
			::_continue_0:: -- 2251
		end -- 2250
	else -- 2256
		local _accum_0 = { } -- 2256
		local _len_0 = 1 -- 2256
		local _list_0 = lib.children -- 2256
		for _index_0 = 1, #_list_0 do -- 2256
			local child = _list_0[_index_0] -- 2256
			if child.title ~= "Dora" then -- 2256
				_accum_0[_len_0] = child -- 2256
				_len_0 = _len_0 + 1 -- 2256
			end -- 2256
		end -- 2256
		lib.children = _accum_0 -- 2256
	end -- 2249
	local builtinChildren = { -- 2257
		readme, -- 2257
		apiDoc, -- 2257
		tools, -- 2257
		font, -- 2257
		lib -- 2257
	} -- 2257
	if engineDev then -- 2258
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2259
		do -- 2260
			local _obj_0 = dev.children -- 2260
			_obj_0[#_obj_0 + 1] = { -- 2261
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2261
				dir = false, -- 2262
				builtin = true, -- 2263
				title = "init.yue" -- 2264
			} -- 2260
		end -- 2260
		builtinChildren[#builtinChildren + 1] = dev -- 2266
	end -- 2258
	return { -- 2268
		key = Content.writablePath, -- 2268
		dir = true, -- 2269
		root = true, -- 2270
		title = "Assets", -- 2271
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2272
	} -- 2267
end) -- 2234
HttpServer:post("/entry/list", function(req) -- 2284
	local Entry = require("Script.Dev.Entry") -- 2285
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2286
	res.success = true -- 2287
	return res -- 2288
end) -- 2284
HttpServer:post("/run/status", function() -- 2290
	local Entry = require("Script.Dev.Entry") -- 2291
	return Entry.getCurrentEntryStatus() -- 2292
end) -- 2290
HttpServer:postSchedule("/run", function(req) -- 2294
	do -- 2295
		local _type_0 = type(req) -- 2295
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2295
		if _tab_0 then -- 2295
			local file -- 2295
			do -- 2295
				local _obj_0 = req.body -- 2295
				local _type_1 = type(_obj_0) -- 2295
				if "table" == _type_1 or "userdata" == _type_1 then -- 2295
					file = _obj_0.file -- 2295
				end -- 2295
			end -- 2295
			local asProj -- 2295
			do -- 2295
				local _obj_0 = req.body -- 2295
				local _type_1 = type(_obj_0) -- 2295
				if "table" == _type_1 or "userdata" == _type_1 then -- 2295
					asProj = _obj_0.asProj -- 2295
				end -- 2295
			end -- 2295
			if file ~= nil and asProj ~= nil then -- 2295
				if not Content:isAbsolutePath(file) then -- 2296
					local devFile = Path(Content.writablePath, file) -- 2297
					if Content:exist(devFile) then -- 2298
						file = devFile -- 2298
					end -- 2298
				end -- 2296
				local Entry = require("Script.Dev.Entry") -- 2299
				local workDir -- 2300
				if asProj then -- 2301
					local projectRoot = req.body.projectRoot -- 2302
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2303
						workDir = projectRoot -- 2304
					else -- 2306
						workDir = getProjectDirFromFile(file) -- 2306
					end -- 2303
					if workDir then -- 2307
						Entry.allClear() -- 2308
						local target = Path(workDir, "init") -- 2309
						local runId = Entry.getCurrentEntryStatus().runId + 1 -- 2310
						local success, err = Entry.enterEntryAsync({ -- 2311
							entryName = "Project", -- 2311
							fileName = target, -- 2311
							workDir = workDir, -- 2311
							projectRoot = workDir, -- 2311
							runKind = "project" -- 2311
						}) -- 2311
						if success and not err and req.body.waitForFrame == true then -- 2312
							local RunTransition = require("Script.Dev.RunTransition") -- 2313
							success, err = RunTransition.waitForFrameAsync(Entry, runId, Content:exist(Path(workDir, "project.godot"))) -- 2314
						end -- 2312
						target = Path:getName(Path:getPath(target)) -- 2315
						return { -- 2316
							success = success, -- 2316
							target = target, -- 2316
							err = err -- 2316
						} -- 2316
					end -- 2307
				else -- 2318
					workDir = getProjectDirFromFile(file) -- 2318
					if not workDir and Path:getExt(file) == "wasm" then -- 2319
						local parent = Path:getPath(file) -- 2320
						if Content:exist(Path(parent, "wa.mod")) then -- 2321
							workDir = parent -- 2322
						end -- 2321
					end -- 2319
				end -- 2301
				Entry.allClear() -- 2323
				file = Path:replaceExt(file, "") -- 2324
				local entry = { -- 2326
					entryName = Path:getName(file), -- 2326
					fileName = file, -- 2327
					runKind = "file" -- 2328
				} -- 2325
				if workDir then -- 2329
					entry.workDir = workDir -- 2330
					entry.projectRoot = workDir -- 2331
				end -- 2329
				local runId = Entry.getCurrentEntryStatus().runId + 1 -- 2332
				local success, err = Entry.enterEntryAsync(entry) -- 2333
				if success and not err and req.body.waitForFrame == true then -- 2334
					local RunTransition = require("Script.Dev.RunTransition") -- 2335
					success, err = RunTransition.waitForFrameAsync(Entry, runId, workDir and Content:exist(Path(workDir, "project.godot"))) -- 2336
				end -- 2334
				return { -- 2337
					success = success, -- 2337
					err = err -- 2337
				} -- 2337
			end -- 2295
		end -- 2295
	end -- 2295
	return { -- 2294
		success = false -- 2294
	} -- 2294
end) -- 2294
local _anon_func_7 = function(result) -- 2379
	if result.success then -- 2379
		return nil -- 2379
	else -- 2379
		return "PREVIEW_FAILED" -- 2379
	end -- 2379
end -- 2379
HttpServer:postSchedule("/agent/preview", function(req) -- 2339
	local releaseAgent = AgentHost.acquire() -- 2340
	local _ <close> = setmetatable({ }, { -- 2341
		__close = function() -- 2341
			return releaseAgent() -- 2341
		end -- 2341
	}) -- 2341
	do -- 2342
		local _type_0 = type(req) -- 2342
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2342
		if _tab_0 then -- 2342
			local projectRoot -- 2342
			do -- 2342
				local _obj_0 = req.body -- 2342
				local _type_1 = type(_obj_0) -- 2342
				if "table" == _type_1 or "userdata" == _type_1 then -- 2342
					projectRoot = _obj_0.projectRoot -- 2342
				end -- 2342
			end -- 2342
			if projectRoot ~= nil then -- 2342
				if not getProjectSourceRoot(projectRoot) then -- 2343
					return { -- 2343
						success = false, -- 2343
						code = "INVALID_PROJECT", -- 2343
						message = "projectRoot must be an existing absolute directory" -- 2343
					} -- 2343
				end -- 2343
				local entryFile = req.body.entry or "init.lua" -- 2344
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2345
					return { -- 2345
						success = false, -- 2345
						code = "INVALID_ENTRY", -- 2345
						message = "entry must be a non-empty project-relative path" -- 2345
					} -- 2345
				end -- 2345
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2346
					0.5 -- 2346
				} -- 2346
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2347
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2348
					return { -- 2348
						success = false, -- 2348
						code = "INVALID_QUEUE_TIMEOUT", -- 2348
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2348
					} -- 2348
				end -- 2348
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2349
				local AgentOperation = require("Agent.Tool.Operation") -- 2350
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2351
				local requestId = AgentOperation.createOperationId() -- 2352
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2353
				if not enqueued.success then -- 2354
					return { -- 2354
						success = false, -- 2354
						code = "ENTRY_QUEUE_REJECTED", -- 2354
						message = enqueued.message -- 2354
					} -- 2354
				end -- 2354
				local queuedAt = App.runningTime -- 2355
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2356
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2357
						local state = agentEntryRunQueue:get(requestId) -- 2358
						agentEntryRunQueue:cancel(requestId) -- 2359
						return { -- 2361
							success = false, -- 2361
							code = "ENTRY_QUEUE_TIMEOUT", -- 2362
							message = "timed out waiting for the Dora entry runtime", -- 2363
							requestId = requestId, -- 2364
							queuePosition = state.position -- 2365
						} -- 2360
					end -- 2357
					sleep() -- 2366
				end -- 2356
				local queueWaitSeconds = App.runningTime - queuedAt -- 2367
				local _ <close> = setmetatable({ }, { -- 2368
					__close = function() -- 2368
						return agentEntryRunQueue:release(requestId) -- 2368
					end -- 2368
				}) -- 2368
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2369
				local Entry = require("Script.Dev.Entry") -- 2370
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2372
					workDir = projectRoot, -- 2372
					operationId = requestId, -- 2373
					print = function() end -- 2374
				}, Entry) -- 2371
				local result = preview({ -- 2376
					entry = entryFile, -- 2376
					captureAtSeconds = captureAtSeconds -- 2376
				}) -- 2376
				return { -- 2378
					success = result.success, -- 2378
					code = _anon_func_7(result), -- 2379
					message = result.message, -- 2380
					requestId = requestId, -- 2381
					queueWaitSeconds = queueWaitSeconds, -- 2382
					interruptedUserRun = result.interruptedUserRun, -- 2383
					files = result.files, -- 2384
					frames = result.frames -- 2385
				} -- 2377
			end -- 2342
		end -- 2342
	end -- 2342
	return { -- 2339
		success = false, -- 2339
		message = "invalid call" -- 2339
	} -- 2339
end) -- 2339
HttpServer:postSchedule("/agent/command", function(req) -- 2387
	local releaseAgent = AgentHost.acquire() -- 2388
	local _ <close> = setmetatable({ }, { -- 2389
		__close = function() -- 2389
			return releaseAgent() -- 2389
		end -- 2389
	}) -- 2389
	do -- 2390
		local _type_0 = type(req) -- 2390
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2390
		if _tab_0 then -- 2390
			local body = req.body -- 2390
			if body ~= nil then -- 2390
				local projectRoot = body.projectRoot -- 2391
				if not getProjectSourceRoot(projectRoot) then -- 2392
					return { -- 2392
						success = false, -- 2392
						code = "INVALID_PROJECT", -- 2392
						message = "projectRoot must be an existing absolute directory" -- 2392
					} -- 2392
				end -- 2392
				local AgentValidation = require("Agent.Tool.Validation") -- 2393
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2394
				if not validated.success then -- 2395
					return { -- 2395
						success = false, -- 2395
						code = "INVALID_COMMAND", -- 2395
						message = validated.message -- 2395
					} -- 2395
				end -- 2395
				local input = validated.value -- 2396
				local AgentCommand = require("Agent.Tool.Command") -- 2397
				local result = nil -- 2398
				local failure = nil -- 2399
				local promise = AgentCommand.executeCommand({ -- 2401
					workDir = projectRoot, -- 2401
					mode = input.mode, -- 2402
					code = input.code, -- 2403
					command = input.command, -- 2404
					cwd = input.cwd, -- 2405
					timeoutSeconds = input.timeoutSeconds -- 2406
				}) -- 2400
				promise:addCallbacks((function(_, value) -- 2407
					result = value -- 2407
				end), (function(_, err) -- 2407
					failure = tostring(err) -- 2407
				end)) -- 2407
				wait(function() -- 2408
					return result ~= nil or failure ~= nil -- 2408
				end) -- 2408
				if failure then -- 2409
					return { -- 2409
						success = false, -- 2409
						code = "COMMAND_BRIDGE_FAILED", -- 2409
						message = failure -- 2409
					} -- 2409
				end -- 2409
				if not result.success then -- 2410
					result.code = "COMMAND_FAILED" -- 2411
				end -- 2410
				return result -- 2412
			end -- 2390
		end -- 2390
	end -- 2390
	return { -- 2387
		success = false, -- 2387
		code = "INVALID_COMMAND", -- 2387
		message = "invalid call" -- 2387
	} -- 2387
end) -- 2387
HttpServer:postSchedule("/stop", function() -- 2414
	local Entry = require("Script.Dev.Entry") -- 2415
	return { -- 2416
		success = Entry.stop() -- 2416
	} -- 2416
end) -- 2414
local minifyAsync -- 2418
minifyAsync = function(sourcePath, minifyPath) -- 2418
	if not Content:exist(sourcePath) then -- 2419
		return -- 2419
	end -- 2419
	local Entry = require("Script.Dev.Entry") -- 2420
	local errors = { } -- 2421
	local files = Entry.getAllFiles(sourcePath, { -- 2422
		"lua" -- 2422
	}, true) -- 2422
	do -- 2423
		local _accum_0 = { } -- 2423
		local _len_0 = 1 -- 2423
		for _index_0 = 1, #files do -- 2423
			local file = files[_index_0] -- 2423
			if file:sub(1, 1) ~= '.' then -- 2423
				_accum_0[_len_0] = file -- 2423
				_len_0 = _len_0 + 1 -- 2423
			end -- 2423
		end -- 2423
		files = _accum_0 -- 2423
	end -- 2423
	local paths -- 2424
	do -- 2424
		local _tbl_0 = { } -- 2424
		for _index_0 = 1, #files do -- 2424
			local file = files[_index_0] -- 2424
			_tbl_0[Path:getPath(file)] = true -- 2424
		end -- 2424
		paths = _tbl_0 -- 2424
	end -- 2424
	for path in pairs(paths) do -- 2425
		Content:mkdir(Path(minifyPath, path)) -- 2425
	end -- 2425
	local _ <close> = setmetatable({ }, { -- 2426
		__close = function() -- 2426
			package.loaded["luaminify.FormatMini"] = nil -- 2427
			package.loaded["luaminify.ParseLua"] = nil -- 2428
			package.loaded["luaminify.Scope"] = nil -- 2429
			package.loaded["luaminify.Util"] = nil -- 2430
		end -- 2426
	}) -- 2426
	local FormatMini -- 2431
	do -- 2431
		local _obj_0 = require("luaminify") -- 2431
		FormatMini = _obj_0.FormatMini -- 2431
	end -- 2431
	local fileCount = #files -- 2432
	local count = 0 -- 2433
	for _index_0 = 1, #files do -- 2434
		local file = files[_index_0] -- 2434
		thread(function() -- 2435
			local _ <close> = setmetatable({ }, { -- 2436
				__close = function() -- 2436
					count = count + 1 -- 2436
				end -- 2436
			}) -- 2436
			local input = Path(sourcePath, file) -- 2437
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2438
			if Content:exist(input) then -- 2439
				local sourceCodes = Content:loadAsync(input) -- 2440
				local res, err = FormatMini(sourceCodes) -- 2441
				if res then -- 2442
					Content:saveAsync(output, res) -- 2443
					return print("Minify " .. tostring(file)) -- 2444
				else -- 2446
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2446
				end -- 2442
			else -- 2448
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2448
			end -- 2439
		end) -- 2435
		sleep() -- 2449
	end -- 2434
	wait(function() -- 2450
		return count == fileCount -- 2450
	end) -- 2450
	if #errors > 0 then -- 2451
		print(table.concat(errors, '\n')) -- 2452
	end -- 2451
	print("Obfuscation done.") -- 2453
	return files -- 2454
end -- 2418
local zipping = false -- 2456
HttpServer:postSchedule("/zip", function(req) -- 2458
	do -- 2459
		local _type_0 = type(req) -- 2459
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2459
		if _tab_0 then -- 2459
			local path -- 2459
			do -- 2459
				local _obj_0 = req.body -- 2459
				local _type_1 = type(_obj_0) -- 2459
				if "table" == _type_1 or "userdata" == _type_1 then -- 2459
					path = _obj_0.path -- 2459
				end -- 2459
			end -- 2459
			local zipFile -- 2459
			do -- 2459
				local _obj_0 = req.body -- 2459
				local _type_1 = type(_obj_0) -- 2459
				if "table" == _type_1 or "userdata" == _type_1 then -- 2459
					zipFile = _obj_0.zipFile -- 2459
				end -- 2459
			end -- 2459
			local obfuscated -- 2459
			do -- 2459
				local _obj_0 = req.body -- 2459
				local _type_1 = type(_obj_0) -- 2459
				if "table" == _type_1 or "userdata" == _type_1 then -- 2459
					obfuscated = _obj_0.obfuscated -- 2459
				end -- 2459
			end -- 2459
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2459
				if zipping then -- 2460
					goto failed -- 2460
				end -- 2460
				zipping = true -- 2461
				local _ <close> = setmetatable({ }, { -- 2462
					__close = function() -- 2462
						zipping = false -- 2462
					end -- 2462
				}) -- 2462
				if not Content:exist(path) then -- 2463
					goto failed -- 2463
				end -- 2463
				Content:mkdir(Path:getPath(zipFile)) -- 2464
				if obfuscated then -- 2465
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2466
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2467
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2468
					Content:remove(scriptPath) -- 2469
					Content:remove(obfuscatedPath) -- 2470
					Content:remove(tempPath) -- 2471
					Content:mkdir(scriptPath) -- 2472
					Content:mkdir(obfuscatedPath) -- 2473
					Content:mkdir(tempPath) -- 2474
					if not Content:copyAsync(path, tempPath) then -- 2475
						goto failed -- 2475
					end -- 2475
					local Entry = require("Script.Dev.Entry") -- 2476
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2477
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2478
						"tl", -- 2478
						"yue", -- 2478
						"lua", -- 2478
						"ts", -- 2478
						"tsx", -- 2478
						"vs", -- 2478
						"bl", -- 2478
						"xml", -- 2478
						"wa", -- 2478
						"mod" -- 2478
					}, true) -- 2478
					for _index_0 = 1, #scriptFiles do -- 2479
						local file = scriptFiles[_index_0] -- 2479
						Content:remove(Path(tempPath, file)) -- 2480
					end -- 2479
					for _index_0 = 1, #luaFiles do -- 2481
						local file = luaFiles[_index_0] -- 2481
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2482
					end -- 2481
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2483
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2484
					end) then -- 2483
						goto failed -- 2483
					end -- 2483
					return { -- 2485
						success = true -- 2485
					} -- 2485
				else -- 2487
					return { -- 2487
						success = Content:zipAsync(path, zipFile, function(file) -- 2487
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2488
						end) -- 2487
					} -- 2487
				end -- 2465
			end -- 2459
		end -- 2459
	end -- 2459
	::failed:: -- 2489
	return { -- 2458
		success = false -- 2458
	} -- 2458
end) -- 2458
HttpServer:postSchedule("/unzip", function(req) -- 2491
	do -- 2492
		local _type_0 = type(req) -- 2492
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2492
		if _tab_0 then -- 2492
			local zipFile -- 2492
			do -- 2492
				local _obj_0 = req.body -- 2492
				local _type_1 = type(_obj_0) -- 2492
				if "table" == _type_1 or "userdata" == _type_1 then -- 2492
					zipFile = _obj_0.zipFile -- 2492
				end -- 2492
			end -- 2492
			local path -- 2492
			do -- 2492
				local _obj_0 = req.body -- 2492
				local _type_1 = type(_obj_0) -- 2492
				if "table" == _type_1 or "userdata" == _type_1 then -- 2492
					path = _obj_0.path -- 2492
				end -- 2492
			end -- 2492
			if zipFile ~= nil and path ~= nil then -- 2492
				return { -- 2493
					success = Content:unzipAsync(zipFile, path, function(file) -- 2493
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2494
					end) -- 2493
				} -- 2493
			end -- 2492
		end -- 2492
	end -- 2492
	return { -- 2491
		success = false -- 2491
	} -- 2491
end) -- 2491
HttpServer:post("/editing-info", function(req) -- 2496
	local Entry = require("Script.Dev.Entry") -- 2497
	local config = Entry.getConfig() -- 2498
	local _type_0 = type(req) -- 2499
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2499
	local _match_0 = false -- 2499
	if _tab_0 then -- 2499
		local editingInfo -- 2499
		do -- 2499
			local _obj_0 = req.body -- 2499
			local _type_1 = type(_obj_0) -- 2499
			if "table" == _type_1 or "userdata" == _type_1 then -- 2499
				editingInfo = _obj_0.editingInfo -- 2499
			end -- 2499
		end -- 2499
		if editingInfo ~= nil then -- 2499
			_match_0 = true -- 2499
			config.editingInfo = editingInfo -- 2500
			return { -- 2501
				success = true -- 2501
			} -- 2501
		end -- 2499
	end -- 2499
	if not _match_0 then -- 2499
		if not (config.editingInfo ~= nil) then -- 2503
			local folder -- 2504
			if App.locale:match('^zh') then -- 2504
				folder = 'zh-Hans' -- 2504
			else -- 2504
				folder = 'en' -- 2504
			end -- 2504
			config.editingInfo = json.encode({ -- 2506
				index = 0, -- 2506
				files = { -- 2508
					{ -- 2509
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2509
						title = "welcome.md" -- 2510
					} -- 2508
				} -- 2507
			}) -- 2505
		end -- 2503
		return { -- 2514
			success = true, -- 2514
			editingInfo = config.editingInfo -- 2514
		} -- 2514
	end -- 2499
end) -- 2496
HttpServer:post("/command", function(req) -- 2516
	do -- 2517
		local _type_0 = type(req) -- 2517
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2517
		if _tab_0 then -- 2517
			local code -- 2517
			do -- 2517
				local _obj_0 = req.body -- 2517
				local _type_1 = type(_obj_0) -- 2517
				if "table" == _type_1 or "userdata" == _type_1 then -- 2517
					code = _obj_0.code -- 2517
				end -- 2517
			end -- 2517
			local log -- 2517
			do -- 2517
				local _obj_0 = req.body -- 2517
				local _type_1 = type(_obj_0) -- 2517
				if "table" == _type_1 or "userdata" == _type_1 then -- 2517
					log = _obj_0.log -- 2517
				end -- 2517
			end -- 2517
			if code ~= nil and log ~= nil then -- 2517
				emit("AppCommand", code, log) -- 2518
				return { -- 2519
					success = true -- 2519
				} -- 2519
			end -- 2517
		end -- 2517
	end -- 2517
	return { -- 2516
		success = false -- 2516
	} -- 2516
end) -- 2516
HttpServer:post("/log/save", function() -- 2521
	local folder = ".download" -- 2522
	local fullLogFile = "dora_full_logs.txt" -- 2523
	local fullFolder = Path(Content.writablePath, folder) -- 2524
	Content:mkdir(fullFolder) -- 2525
	local logPath = Path(fullFolder, fullLogFile) -- 2526
	if App:saveLog(logPath) then -- 2527
		return { -- 2528
			success = true, -- 2528
			path = Path(folder, fullLogFile) -- 2528
		} -- 2528
	end -- 2527
	return { -- 2521
		success = false -- 2521
	} -- 2521
end) -- 2521
local tailLines -- 2530
tailLines = function(text, count) -- 2530
	local lines = { } -- 2531
	text = text:gsub("\r\n", "\n") -- 2532
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2533
		lines[#lines + 1] = line -- 2534
	end -- 2533
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2535
		table.remove(lines) -- 2536
	end -- 2535
	local start = math.max(1, #lines - count + 1) -- 2537
	local out = { } -- 2538
	for i = start, #lines do -- 2539
		out[#out + 1] = lines[i] -- 2540
	end -- 2539
	return table.concat(out, "\n") -- 2541
end -- 2530
HttpServer:post("/log", function(req) -- 2543
	local count = 100 -- 2544
	if req and req.body and req.body.count ~= nil then -- 2545
		count = req.body.count -- 2546
	end -- 2545
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2547
		return { -- 2548
			success = false, -- 2548
			message = "count must be a positive integer" -- 2548
		} -- 2548
	end -- 2547
	local folder = ".download" -- 2549
	local fullLogFile = "dora_full_logs.txt" -- 2550
	local fullFolder = Path(Content.writablePath, folder) -- 2551
	Content:mkdir(fullFolder) -- 2552
	local logPath = Path(fullFolder, fullLogFile) -- 2553
	if App:saveLog(logPath) then -- 2554
		local text = Content:load(logPath) -- 2555
		if text then -- 2556
			return { -- 2557
				success = true, -- 2557
				log = tailLines(text, count) -- 2557
			} -- 2557
		else -- 2559
			return { -- 2559
				success = false, -- 2559
				message = "failed to read log" -- 2559
			} -- 2559
		end -- 2556
	else -- 2561
		return { -- 2561
			success = false, -- 2561
			message = "failed to save log" -- 2561
		} -- 2561
	end -- 2554
	return { -- 2543
		success = false -- 2543
	} -- 2543
end) -- 2543
HttpServer:post("/yarn/check", function(req) -- 2563
	local yarncompile = require("yarncompile") -- 2564
	do -- 2565
		local _type_0 = type(req) -- 2565
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2565
		if _tab_0 then -- 2565
			local code -- 2565
			do -- 2565
				local _obj_0 = req.body -- 2565
				local _type_1 = type(_obj_0) -- 2565
				if "table" == _type_1 or "userdata" == _type_1 then -- 2565
					code = _obj_0.code -- 2565
				end -- 2565
			end -- 2565
			if code ~= nil then -- 2565
				local jsonObject = json.decode(code) -- 2566
				if jsonObject then -- 2566
					local errors = { } -- 2567
					local _list_0 = jsonObject.nodes -- 2568
					for _index_0 = 1, #_list_0 do -- 2568
						local node = _list_0[_index_0] -- 2568
						local title, body = node.title, node.body -- 2569
						local luaCode, err = yarncompile(body) -- 2570
						if not luaCode then -- 2570
							errors[#errors + 1] = title .. ":" .. err -- 2571
						end -- 2570
					end -- 2568
					return { -- 2572
						success = true, -- 2572
						syntaxError = table.concat(errors, "\n\n") -- 2572
					} -- 2572
				end -- 2566
			end -- 2565
		end -- 2565
	end -- 2565
	return { -- 2563
		success = false -- 2563
	} -- 2563
end) -- 2563
HttpServer:post("/yarn/check-file", function(req) -- 2574
	local yarncompile = require("yarncompile") -- 2575
	do -- 2576
		local _type_0 = type(req) -- 2576
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2576
		if _tab_0 then -- 2576
			local code -- 2576
			do -- 2576
				local _obj_0 = req.body -- 2576
				local _type_1 = type(_obj_0) -- 2576
				if "table" == _type_1 or "userdata" == _type_1 then -- 2576
					code = _obj_0.code -- 2576
				end -- 2576
			end -- 2576
			if code ~= nil then -- 2576
				local res, _, err = yarncompile(code, true) -- 2577
				if not res then -- 2577
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2578
					return { -- 2579
						success = false, -- 2579
						message = message, -- 2579
						line = line, -- 2579
						column = column, -- 2579
						node = node -- 2579
					} -- 2579
				end -- 2577
			end -- 2576
		end -- 2576
	end -- 2576
	return { -- 2574
		success = true -- 2574
	} -- 2574
end) -- 2574
getWaProjectDirFromFile = function(file) -- 2581
	local current -- 2582
	if Content:isdir(file) then -- 2582
		current = file -- 2582
	else -- 2582
		current = Path:getPath(file) -- 2582
	end -- 2582
	if current == "" then -- 2583
		return nil -- 2583
	end -- 2583
	repeat -- 2584
		local modPath = Path(current, "wa.mod") -- 2585
		if Content:exist(modPath) then -- 2586
			return current, modPath -- 2587
		end -- 2586
		local parent = Path:getPath(current) -- 2588
		if parent == "" or parent == current then -- 2589
			break -- 2589
		end -- 2589
		current = parent -- 2590
	until false -- 2584
	return nil -- 2592
end -- 2581
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2594
	do -- 2595
		local _type_0 = type(req) -- 2595
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2595
		if _tab_0 then -- 2595
			local path -- 2595
			do -- 2595
				local _obj_0 = req.body -- 2595
				local _type_1 = type(_obj_0) -- 2595
				if "table" == _type_1 or "userdata" == _type_1 then -- 2595
					path = _obj_0.path -- 2595
				end -- 2595
			end -- 2595
			if path ~= nil then -- 2595
				local projDir = getWaProjectDirFromFile(path) -- 2596
				if projDir then -- 2596
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2597
					if not Content:exist(sourceDoraPath) then -- 2598
						return { -- 2599
							success = false, -- 2599
							message = "missing dora template" -- 2599
						} -- 2599
					end -- 2598
					local targetVendorPath = Path(projDir, "vendor") -- 2600
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2601
					if not Content:exist(targetVendorPath) then -- 2602
						if not Content:mkdir(targetVendorPath) then -- 2603
							return { -- 2604
								success = false, -- 2604
								message = "failed to create vendor folder" -- 2604
							} -- 2604
						end -- 2603
					elseif not Content:isdir(targetVendorPath) then -- 2605
						return { -- 2606
							success = false, -- 2606
							message = "vendor path is not a folder" -- 2606
						} -- 2606
					end -- 2602
					if Content:exist(targetDoraPath) then -- 2607
						if not Content:remove(targetDoraPath) then -- 2608
							return { -- 2609
								success = false, -- 2609
								message = "failed to remove old dora" -- 2609
							} -- 2609
						end -- 2608
					end -- 2607
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2610
						return { -- 2611
							success = false, -- 2611
							message = "failed to copy dora" -- 2611
						} -- 2611
					end -- 2610
					return { -- 2612
						success = true -- 2612
					} -- 2612
				else -- 2614
					return { -- 2614
						success = false, -- 2614
						message = 'Wa file needs a project' -- 2614
					} -- 2614
				end -- 2596
			end -- 2595
		end -- 2595
	end -- 2595
	return { -- 2594
		success = false, -- 2594
		message = "invalid call" -- 2594
	} -- 2594
end) -- 2594
HttpServer:postSchedule("/wa/build", function(req) -- 2616
	do -- 2617
		local _type_0 = type(req) -- 2617
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2617
		if _tab_0 then -- 2617
			local path -- 2617
			do -- 2617
				local _obj_0 = req.body -- 2617
				local _type_1 = type(_obj_0) -- 2617
				if "table" == _type_1 or "userdata" == _type_1 then -- 2617
					path = _obj_0.path -- 2617
				end -- 2617
			end -- 2617
			if path ~= nil then -- 2617
				local projDir = getWaProjectDirFromFile(path) -- 2618
				if projDir then -- 2618
					local message = Wasm:buildWaAsync(projDir) -- 2619
					if message == "" then -- 2620
						return { -- 2621
							success = true -- 2621
						} -- 2621
					else -- 2623
						return { -- 2623
							success = false, -- 2623
							message = message -- 2623
						} -- 2623
					end -- 2620
				else -- 2625
					return { -- 2625
						success = false, -- 2625
						message = 'Wa file needs a project' -- 2625
					} -- 2625
				end -- 2618
			end -- 2617
		end -- 2617
	end -- 2617
	return { -- 2626
		success = false, -- 2626
		message = 'failed to build' -- 2626
	} -- 2626
end) -- 2616
HttpServer:postSchedule("/wa/format", function(req) -- 2628
	do -- 2629
		local _type_0 = type(req) -- 2629
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2629
		if _tab_0 then -- 2629
			local file -- 2629
			do -- 2629
				local _obj_0 = req.body -- 2629
				local _type_1 = type(_obj_0) -- 2629
				if "table" == _type_1 or "userdata" == _type_1 then -- 2629
					file = _obj_0.file -- 2629
				end -- 2629
			end -- 2629
			if file ~= nil then -- 2629
				local code = Wasm:formatWaAsync(file) -- 2630
				if code == "" then -- 2631
					return { -- 2632
						success = false -- 2632
					} -- 2632
				else -- 2634
					return { -- 2634
						success = true, -- 2634
						code = code -- 2634
					} -- 2634
				end -- 2631
			end -- 2629
		end -- 2629
	end -- 2629
	return { -- 2635
		success = false -- 2635
	} -- 2635
end) -- 2628
HttpServer:postSchedule("/wa/create", function(req) -- 2637
	do -- 2638
		local _type_0 = type(req) -- 2638
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2638
		if _tab_0 then -- 2638
			local path -- 2638
			do -- 2638
				local _obj_0 = req.body -- 2638
				local _type_1 = type(_obj_0) -- 2638
				if "table" == _type_1 or "userdata" == _type_1 then -- 2638
					path = _obj_0.path -- 2638
				end -- 2638
			end -- 2638
			if path ~= nil then -- 2638
				if not Content:exist(Path:getPath(path)) then -- 2639
					return { -- 2640
						success = false, -- 2640
						message = "target path not existed" -- 2640
					} -- 2640
				end -- 2639
				if Content:exist(path) then -- 2641
					return { -- 2642
						success = false, -- 2642
						message = "target project folder existed" -- 2642
					} -- 2642
				end -- 2641
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2643
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2644
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2645
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2646
					return { -- 2649
						success = false, -- 2649
						message = "missing template project" -- 2649
					} -- 2649
				end -- 2646
				if not Content:mkdir(path) then -- 2650
					return { -- 2651
						success = false, -- 2651
						message = "failed to create project folder" -- 2651
					} -- 2651
				end -- 2650
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2652
					Content:remove(path) -- 2653
					return { -- 2654
						success = false, -- 2654
						message = "failed to copy template" -- 2654
					} -- 2654
				end -- 2652
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2655
					Content:remove(path) -- 2656
					return { -- 2657
						success = false, -- 2657
						message = "failed to copy template" -- 2657
					} -- 2657
				end -- 2655
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2658
					Content:remove(path) -- 2659
					return { -- 2660
						success = false, -- 2660
						message = "failed to copy template" -- 2660
					} -- 2660
				end -- 2658
				return { -- 2661
					success = true -- 2661
				} -- 2661
			end -- 2638
		end -- 2638
	end -- 2638
	return { -- 2637
		success = false, -- 2637
		message = "invalid call" -- 2637
	} -- 2637
end) -- 2637
local tsBuildGlobs = { -- 2664
	"**/*.ts", -- 2664
	"**/*.tsx", -- 2665
	"!**/.*/**", -- 2666
	"!**/node_modules/**" -- 2667
} -- 2663
local tsSnapshotGlobs = { -- 2670
	"**/*.ts", -- 2670
	"**/*.tsx", -- 2671
	"**/*.lua", -- 2672
	"!**/.*/**", -- 2673
	"!**/node_modules/**" -- 2674
} -- 2669
local collectTSVirtualFiles -- 2676
collectTSVirtualFiles = function(sourceRoot) -- 2676
	local files = { } -- 2677
	local seen = { } -- 2678
	local addFile -- 2679
	addFile = function(file, moduleName, virtualFile) -- 2679
		if moduleName == nil then -- 2679
			moduleName = nil -- 2679
		end -- 2679
		if virtualFile == nil then -- 2679
			virtualFile = nil -- 2679
		end -- 2679
		local targetFile = virtualFile or file -- 2680
		do -- 2681
			local entry = seen[targetFile] -- 2681
			if entry then -- 2681
				if moduleName and moduleName ~= "" then -- 2682
					entry.moduleName = moduleName -- 2682
				end -- 2682
				return -- 2683
			end -- 2681
		end -- 2681
		local content = Content:load(file) -- 2684
		if content then -- 2684
			local entry = { -- 2685
				file = targetFile, -- 2685
				content = content -- 2685
			} -- 2685
			if moduleName and moduleName ~= "" then -- 2686
				entry.moduleName = moduleName -- 2686
			end -- 2686
			seen[targetFile] = entry -- 2687
			files[#files + 1] = entry -- 2688
		end -- 2684
	end -- 2679
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2689
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2690
		for _index_0 = 1, #_list_0 do -- 2690
			local subFile = _list_0[_index_0] -- 2690
			addFile(Path(sourceRoot, subFile)) -- 2691
		end -- 2690
		local libraryRoots = { -- 2693
			Path(sourceRoot, "Script", "Lib"), -- 2693
			Path(sourceRoot, "Lib"), -- 2694
			Path(Content.assetPath, "Script", "Lib") -- 2695
		} -- 2692
		for _index_0 = 1, #libraryRoots do -- 2696
			local libraryRoot = libraryRoots[_index_0] -- 2696
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2697
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2698
				for _index_1 = 1, #_list_1 do -- 2698
					local subFile = _list_1[_index_1] -- 2698
					local file = Path(libraryRoot, subFile) -- 2699
					local virtualFile = Path(sourceRoot, subFile) -- 2700
					addFile(file, nil, virtualFile) -- 2701
				end -- 2698
			end -- 2697
		end -- 2696
	end -- 2689
	local locale -- 2702
	if App.locale:match('^zh') then -- 2702
		locale = 'zh-Hans' -- 2702
	else -- 2702
		locale = 'en' -- 2702
	end -- 2702
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2703
	local _list_0 = Content:getFiles(declarationRoot) -- 2704
	for _index_0 = 1, #_list_0 do -- 2704
		local file = _list_0[_index_0] -- 2704
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2705
			local fullPath = Path(declarationRoot, file) -- 2706
			local moduleName = Path:getName(Path:getName(file)) -- 2707
			addFile(fullPath, moduleName) -- 2708
		end -- 2705
	end -- 2704
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2709
	local lualibBundleTarget -- 2710
	if sourceRoot then -- 2710
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2710
	else -- 2710
		lualibBundleTarget = "lualib_bundle.lua" -- 2710
	end -- 2710
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2711
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2712
	local _list_1 = Content:getFiles(lualibRoot) -- 2713
	for _index_0 = 1, #_list_1 do -- 2713
		local file = _list_1[_index_0] -- 2713
		if Path:getExt(file) == "lua" then -- 2714
			local virtualFile -- 2715
			if sourceRoot then -- 2715
				virtualFile = Path(sourceRoot, "lualib", file) -- 2715
			else -- 2715
				virtualFile = Path("lualib", file) -- 2715
			end -- 2715
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2716
		end -- 2714
	end -- 2713
	return files -- 2717
end -- 2676
local supportsCompilerWebView -- 2719
supportsCompilerWebView = function() -- 2719
	local _val_0 = App.platform -- 2719
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2719
end -- 2719
local webIDECompilerReady = false -- 2720
local webIDEConnectionGeneration = 0 -- 2721
local tsProbeId = 0 -- 2722
local probeWebIDECompiler -- 2724
probeWebIDECompiler = function(isCancelled) -- 2724
	if HttpServer.wsConnectionCount == 0 then -- 2725
		return false -- 2725
	end -- 2725
	tsProbeId = tsProbeId + 1 -- 2726
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2727
	local generation = webIDEConnectionGeneration -- 2728
	local done, ready = false, false -- 2729
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2730
	local listener = Node() -- 2731
	listener:gslot("AppWS", function(event) -- 2732
		if event.type == "Receive" then -- 2733
			local res = json.decode(event.msg) -- 2734
			if res then -- 2734
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2735
					responses = responses + 1 -- 2736
					ready = ready or res.success == true -- 2737
					done = ready or responses >= expectedResponses -- 2738
				end -- 2735
			end -- 2734
		end -- 2733
	end) -- 2732
	emit("AppWS", "Send", json.encode({ -- 2739
		name = "TranspileTSProbe", -- 2739
		id = requestId -- 2739
	})) -- 2739
	local deadline = App.runningTime + 5 -- 2740
	wait(function() -- 2741
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2741
	end) -- 2741
	listener:removeFromParent() -- 2742
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2743
	if generation == webIDEConnectionGeneration then -- 2744
		webIDECompilerReady = ready -- 2744
	end -- 2744
	return ready -- 2745
end -- 2724
local compilerConnectionListener = Node() -- 2747
compilerConnectionListener:addTo(Director.systemUI) -- 2749
local _anon_func_8 = function(event) -- 2751
	local _val_0 = event.type -- 2751
	return "Open" == _val_0 or "Close" == _val_0 -- 2751
end -- 2751
compilerConnectionListener:gslot("AppWS", function(event) -- 2750
	if _anon_func_8(event) then -- 2751
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2752
		webIDECompilerReady = false -- 2753
		if HttpServer.wsConnectionCount > 0 then -- 2754
			return thread(function() -- 2755
				return probeWebIDECompiler() -- 2755
			end) -- 2755
		end -- 2754
	end -- 2751
end) -- 2750
local _anon_func_9 = function(res) -- 2780
	if res.success then -- 2780
		return "tool" -- 2780
	else -- 2780
		return res.failureKind -- 2780
	end -- 2780
end -- 2780
local transpileTSFileWithWebIDE -- 2757
do -- 2757
	local tsBuildRequestId = 0 -- 2758
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2759
		if not probeWebIDECompiler(isCancelled) then -- 2760
			if isCancelled and isCancelled() then -- 2761
				return { -- 2762
					success = false, -- 2762
					file = file, -- 2762
					message = "build canceled", -- 2762
					interrupted = true -- 2762
				} -- 2762
			end -- 2761
			return { -- 2763
				success = false, -- 2763
				file = file, -- 2763
				message = "TypeScript transpiler is not ready", -- 2763
				failureKind = "tool" -- 2763
			} -- 2763
		end -- 2760
		tsBuildRequestId = tsBuildRequestId + 1 -- 2764
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2765
		local done = false -- 2766
		local result = nil -- 2767
		local listener = Node() -- 2768
		listener:gslot("AppWS", function(event) -- 2769
			if event.type == "Receive" then -- 2770
				local res = json.decode(event.msg) -- 2771
				if res then -- 2771
					if res.name == "TranspileTS" and res.id == requestId then -- 2772
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2773
							local luaFile = Path:replaceExt(file, "lua") -- 2774
							if Content:save(luaFile, res.luaCode) then -- 2775
								result = { -- 2776
									success = true, -- 2776
									file = file -- 2776
								} -- 2776
							else -- 2778
								result = { -- 2778
									success = false, -- 2778
									file = file, -- 2778
									message = "failed to save " .. tostring(luaFile) -- 2778
								} -- 2778
							end -- 2775
						else -- 2780
							result = { -- 2780
								success = false, -- 2780
								file = file, -- 2780
								message = res.message or "Compiler returned no Lua output", -- 2780
								failureKind = _anon_func_9(res) -- 2780
							} -- 2780
						end -- 2773
						done = true -- 2781
					end -- 2772
				end -- 2771
			end -- 2770
		end) -- 2769
		emit("AppWS", "Send", json.encode({ -- 2782
			name = "TranspileTS", -- 2782
			id = requestId, -- 2782
			file = file, -- 2782
			content = content, -- 2782
			projectRoot = sourceRoot, -- 2782
			files = files -- 2782
		})) -- 2782
		local deadline = App.runningTime + 30 -- 2783
		wait(function() -- 2784
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2784
		end) -- 2784
		listener:removeFromParent() -- 2785
		if not done then -- 2786
			webIDECompilerReady = false -- 2787
			if isCancelled and isCancelled() then -- 2788
				return { -- 2789
					success = false, -- 2789
					file = file, -- 2789
					message = "build canceled", -- 2789
					interrupted = true -- 2789
				} -- 2789
			end -- 2788
			return { -- 2790
				success = false, -- 2790
				file = file, -- 2790
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2790
				failureKind = "tool" -- 2790
			} -- 2790
		end -- 2786
		return result -- 2791
	end -- 2759
end -- 2757
local compilerReadyTimeout <const> = 15 -- 2793
local compilerBuildTimeout <const> = 30 -- 2794
local compilerIdleCloseSeconds <const> = 8 -- 2795
local compilerReady = false -- 2796
local compilerRequested = false -- 2797
local compilerFailure = nil -- 2798
local compilerUsers = 0 -- 2799
local compilerCloseGeneration = 0 -- 2800
local compilerJobId = 0 -- 2801
local compilerJobs = { } -- 2802
local compilerResults = { } -- 2803
local compilerInFlight = { } -- 2804
HttpServer:post("/compiler/ready", function() -- 2806
	if not compilerRequested then -- 2807
		return { -- 2807
			success = false -- 2807
		} -- 2807
	end -- 2807
	compilerReady = true -- 2808
	return { -- 2809
		success = true -- 2809
	} -- 2809
end) -- 2806
HttpServer:post("/compiler/failure", function(req) -- 2811
	if not compilerRequested then -- 2812
		return { -- 2812
			success = false -- 2812
		} -- 2812
	end -- 2812
	do -- 2813
		local _type_0 = type(req) -- 2813
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2813
		if _tab_0 then -- 2813
			local message -- 2813
			do -- 2813
				local _obj_0 = req.body -- 2813
				local _type_1 = type(_obj_0) -- 2813
				if "table" == _type_1 or "userdata" == _type_1 then -- 2813
					message = _obj_0.message -- 2813
				end -- 2813
			end -- 2813
			if message ~= nil then -- 2813
				if type(message) == "string" then -- 2814
					compilerFailure = message -- 2815
					compilerReady = false -- 2816
					return { -- 2817
						success = true -- 2817
					} -- 2817
				end -- 2814
			end -- 2813
		end -- 2813
	end -- 2813
	return { -- 2811
		success = false -- 2811
	} -- 2811
end) -- 2811
HttpServer:postSchedule("/compiler/poll", function() -- 2819
	if not compilerRequested then -- 2820
		return { -- 2820
			success = false -- 2820
		} -- 2820
	end -- 2820
	compilerReady = true -- 2821
	local deadline = App.runningTime + 5 -- 2822
	wait(function() -- 2823
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2823
	end) -- 2823
	if not (compilerRequested and not compilerFailure) then -- 2824
		return { -- 2824
			success = false -- 2824
		} -- 2824
	end -- 2824
	local job = table.remove(compilerJobs, 1) -- 2825
	if job then -- 2826
		compilerInFlight[job.id] = true -- 2827
	end -- 2826
	return { -- 2828
		success = true, -- 2828
		job = job -- 2828
	} -- 2828
end) -- 2819
HttpServer:post("/compiler/result", function(req) -- 2830
	do -- 2831
		local _type_0 = type(req) -- 2831
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2831
		if _tab_0 then -- 2831
			local body = req.body -- 2831
			if body ~= nil then -- 2831
				local id = body.id -- 2832
				if not (id and compilerInFlight[id]) then -- 2833
					return { -- 2833
						success = false, -- 2833
						message = "invalid compiler job" -- 2833
					} -- 2833
				end -- 2833
				compilerInFlight[id] = nil -- 2834
				compilerResults[id] = body -- 2835
				return { -- 2836
					success = true -- 2836
				} -- 2836
			end -- 2831
		end -- 2831
	end -- 2831
	return { -- 2830
		success = false -- 2830
	} -- 2830
end) -- 2830
local acquireCompiler -- 2838
acquireCompiler = function() -- 2838
	compilerUsers = compilerUsers + 1 -- 2839
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2840
	if not compilerRequested then -- 2841
		compilerRequested = true -- 2842
		compilerReady = false -- 2843
		compilerFailure = nil -- 2844
		return emit("AppWebView", "/compiler.html", true) -- 2845
	end -- 2841
end -- 2838
local releaseCompiler -- 2847
releaseCompiler = function() -- 2847
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2848
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2849
	if not (compilerUsers == 0) then -- 2850
		return -- 2850
	end -- 2850
	local closeGeneration = compilerCloseGeneration -- 2851
	return thread(function() -- 2852
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2853
		wait(function() -- 2854
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2855
		end) -- 2854
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2860
			compilerRequested = false -- 2861
			compilerReady = false -- 2862
			return emit("AppWebView", "/compiler.html", false) -- 2863
		end -- 2860
	end) -- 2852
end -- 2847
local removeCompilerJob -- 2865
removeCompilerJob = function(id) -- 2865
	for index = #compilerJobs, 1, -1 do -- 2866
		if compilerJobs[index].id == id then -- 2867
			table.remove(compilerJobs, index) -- 2868
		end -- 2867
	end -- 2866
	compilerInFlight[id] = nil -- 2869
	compilerResults[id] = nil -- 2870
end -- 2865
local transpileTSFileWithCompiler -- 2872
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2872
	acquireCompiler() -- 2873
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2874
	wait(function() -- 2875
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2875
	end) -- 2875
	if not compilerReady then -- 2876
		releaseCompiler() -- 2877
		if isCancelled and isCancelled() then -- 2878
			return { -- 2879
				success = false, -- 2879
				file = file, -- 2879
				message = "build canceled", -- 2879
				interrupted = true -- 2879
			} -- 2879
		end -- 2878
		return { -- 2880
			success = false, -- 2880
			file = file, -- 2880
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2880
			failureKind = "tool" -- 2880
		} -- 2880
	end -- 2876
	compilerJobId = compilerJobId + 1 -- 2881
	local jobId = compilerJobId -- 2882
	compilerJobs[#compilerJobs + 1] = { -- 2884
		id = jobId, -- 2884
		file = file, -- 2885
		content = content, -- 2886
		projectRoot = sourceRoot, -- 2887
		files = files -- 2888
	} -- 2883
	local deadline = App.runningTime + compilerBuildTimeout -- 2889
	wait(function() -- 2890
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2890
	end) -- 2890
	local response = compilerResults[jobId] -- 2891
	removeCompilerJob(jobId) -- 2892
	releaseCompiler() -- 2893
	if not response then -- 2894
		if isCancelled and isCancelled() then -- 2895
			return { -- 2896
				success = false, -- 2896
				file = file, -- 2896
				message = "build canceled", -- 2896
				interrupted = true -- 2896
			} -- 2896
		end -- 2895
		return { -- 2897
			success = false, -- 2897
			file = file, -- 2897
			message = compilerFailure or "TypeScript transpile timed out", -- 2897
			failureKind = "tool" -- 2897
		} -- 2897
	end -- 2894
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2898
		local luaFile = Path:replaceExt(file, "lua") -- 2899
		if Content:save(luaFile, response.luaCode) then -- 2900
			return { -- 2901
				success = true, -- 2901
				file = file -- 2901
			} -- 2901
		end -- 2900
		return { -- 2902
			success = false, -- 2902
			file = file, -- 2902
			message = "failed to save " .. tostring(luaFile) -- 2902
		} -- 2902
	end -- 2898
	return { -- 2903
		success = false, -- 2903
		file = file, -- 2903
		message = response.message or "TypeScript transpile failed" -- 2903
	} -- 2903
end -- 2872
local compilerFailureListener = Node() -- 2905
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2906
	compilerFailure = message -- 2907
	compilerReady = false -- 2908
end) -- 2906
local transpileTSFile -- 2910
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2910
	if supportsCompilerWebView() and not files then -- 2911
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2912
	end -- 2911
	if HttpServer.wsConnectionCount > 0 then -- 2913
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2914
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2915
			return result -- 2915
		end -- 2915
		webIDECompilerReady = false -- 2916
	end -- 2913
	if supportsCompilerWebView() then -- 2917
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2918
	end -- 2917
	return { -- 2919
		success = false, -- 2919
		file = file, -- 2919
		message = "Web IDE compiler not connected", -- 2919
		failureKind = "tool" -- 2919
	} -- 2919
end -- 2910
local _anon_func_10 = function(path) -- 2934
	local _val_0 = Path:getExt(path) -- 2934
	return "ts" == _val_0 or "tsx" == _val_0 -- 2934
end -- 2934
HttpServer:postSchedule("/ts/build", function(req) -- 2921
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2922
	local buildSucceeded = false -- 2923
	local _ <close> = setmetatable({ }, { -- 2924
		__close = function() -- 2924
			return finishUpdate(buildSucceeded) -- 2924
		end -- 2924
	}) -- 2924
	do -- 2925
		local _type_0 = type(req) -- 2925
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2925
		if _tab_0 then -- 2925
			local path -- 2925
			do -- 2925
				local _obj_0 = req.body -- 2925
				local _type_1 = type(_obj_0) -- 2925
				if "table" == _type_1 or "userdata" == _type_1 then -- 2925
					path = _obj_0.path -- 2925
				end -- 2925
			end -- 2925
			if path ~= nil then -- 2925
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2926
					return { -- 2927
						success = false, -- 2927
						message = "Web IDE not connected" -- 2927
					} -- 2927
				end -- 2926
				local projectRoot = req.body.projectRoot -- 2928
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2929
				if not Content:exist(path) then -- 2930
					return { -- 2931
						success = false, -- 2931
						message = "path not existed" -- 2931
					} -- 2931
				end -- 2930
				local messages = { } -- 2932
				if not Content:isdir(path) then -- 2933
					if not (_anon_func_10(path)) then -- 2934
						return { -- 2935
							success = false, -- 2935
							message = "expecting a TypeScript file" -- 2935
						} -- 2935
					end -- 2934
					local content = Content:load(path) -- 2936
					if not content then -- 2937
						return { -- 2938
							success = false, -- 2938
							message = "failed to read file" -- 2938
						} -- 2938
					end -- 2937
					emit("AppWS", "Send", json.encode({ -- 2939
						name = "UpdateFile", -- 2939
						file = path, -- 2939
						exists = true, -- 2939
						content = content, -- 2939
						projectRoot = sourceRoot -- 2939
					})) -- 2939
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2940
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2941
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2942
					end -- 2940
				else -- 2944
					local fileData = { } -- 2944
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2945
					for _index_0 = 1, #_list_0 do -- 2945
						local subFile = _list_0[_index_0] -- 2945
						local file = Path(path, subFile) -- 2946
						local content = Content:load(file) -- 2947
						if content then -- 2947
							fileData[file] = content -- 2948
							emit("AppWS", "Send", json.encode({ -- 2949
								name = "UpdateFile", -- 2949
								file = file, -- 2949
								exists = true, -- 2949
								content = content, -- 2949
								projectRoot = sourceRoot -- 2949
							})) -- 2949
						else -- 2951
							messages[#messages + 1] = { -- 2951
								success = false, -- 2951
								file = file, -- 2951
								message = "failed to read file" -- 2951
							} -- 2951
						end -- 2947
					end -- 2945
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2952
					for file, content in pairs(fileData) do -- 2953
						if "d" == Path:getExt(Path:getName(file)) then -- 2954
							goto _continue_0 -- 2954
						end -- 2954
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2955
						::_continue_0:: -- 2954
					end -- 2953
				end -- 2933
				local success = true -- 2956
				for _index_0 = 1, #messages do -- 2957
					local item = messages[_index_0] -- 2957
					if not item.success then -- 2958
						success = false -- 2958
					end -- 2958
				end -- 2957
				local message = nil -- 2959
				if not success then -- 2960
					message = "TypeScript compilation failed" -- 2960
				end -- 2960
				buildSucceeded = success -- 2961
				return { -- 2962
					success = success, -- 2962
					messages = messages, -- 2962
					message = message -- 2962
				} -- 2962
			end -- 2925
		end -- 2925
	end -- 2925
	return { -- 2921
		success = false -- 2921
	} -- 2921
end) -- 2921
HttpServer:post("/download", function(req) -- 2964
	do -- 2965
		local _type_0 = type(req) -- 2965
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2965
		if _tab_0 then -- 2965
			local url -- 2965
			do -- 2965
				local _obj_0 = req.body -- 2965
				local _type_1 = type(_obj_0) -- 2965
				if "table" == _type_1 or "userdata" == _type_1 then -- 2965
					url = _obj_0.url -- 2965
				end -- 2965
			end -- 2965
			local target -- 2965
			do -- 2965
				local _obj_0 = req.body -- 2965
				local _type_1 = type(_obj_0) -- 2965
				if "table" == _type_1 or "userdata" == _type_1 then -- 2965
					target = _obj_0.target -- 2965
				end -- 2965
			end -- 2965
			if url ~= nil and target ~= nil then -- 2965
				local Entry = require("Script.Dev.Entry") -- 2966
				Entry.downloadFile(url, target) -- 2967
				return { -- 2968
					success = true -- 2968
				} -- 2968
			end -- 2965
		end -- 2965
	end -- 2965
	return { -- 2964
		success = false -- 2964
	} -- 2964
end) -- 2964
local isDesktopPlatform -- 2970
isDesktopPlatform = function() -- 2970
	local _val_0 = App.platform -- 2971
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2971
end -- 2970
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 2973
local nativeIDEListener = Node() -- 2974
nativeIDEListener:addTo(Director.systemUI) -- 2975
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 2976
	nativeIDEState, nativeIDEMessage = state, message -- 2977
end) -- 2976
local _anon_func_11 = function() -- 2980
	local _val_0 = App.platform -- 2980
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2980
end -- 2980
HttpServer:post("/ide", function(req) -- 2979
	if not (_anon_func_11()) then -- 2980
		return { -- 2980
			success = false, -- 2980
			message = "Native IDE is unavailable" -- 2980
		} -- 2980
	end -- 2980
	if not App.webIDEEnabled then -- 2981
		return { -- 2981
			success = false, -- 2981
			message = "Embedded Web IDE is disabled" -- 2981
		} -- 2981
	end -- 2981
	do -- 2982
		local _type_0 = type(req) -- 2982
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2982
		if _tab_0 then -- 2982
			local action -- 2982
			do -- 2982
				local _obj_0 = req.body -- 2982
				local _type_1 = type(_obj_0) -- 2982
				if "table" == _type_1 or "userdata" == _type_1 then -- 2982
					action = _obj_0.action -- 2982
				end -- 2982
			end -- 2982
			if action ~= nil then -- 2982
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 2983
					emit("AppWebView", "/ide/" .. action, true) -- 2984
					return { -- 2985
						success = true -- 2985
					} -- 2985
				end -- 2983
			end -- 2982
		end -- 2982
	end -- 2982
	return { -- 2979
		success = false, -- 2979
		message = "invalid IDE action" -- 2979
	} -- 2979
end) -- 2979
local _anon_func_12 = function() -- 3001
	local _val_0 = App.platform -- 3001
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 3001
end -- 3001
local getServerStatus -- 2987
getServerStatus = function() -- 2987
	local Entry = require("Script.Dev.Entry") -- 2988
	local running = Entry.getCurrentEntryStatus() -- 2989
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2990
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2991
	return { -- 2993
		success = true, -- 2993
		platform = App.platform, -- 2994
		locale = App.locale, -- 2995
		version = App.version, -- 2996
		url = "http://localhost:8866", -- 2997
		wsConnectionCount = wsConnectionCount, -- 2998
		webIDEConnected = wsConnectionCount > 0, -- 2999
		nativeIDE = { -- 3001
			supported = _anon_func_12(), -- 3001
			enabled = App.webIDEEnabled, -- 3002
			state = nativeIDEState, -- 3003
			message = nativeIDEMessage -- 3004
		}, -- 3000
		typescriptCompiler = { -- 3006
			webIDEReady = webIDECompilerReady, -- 3006
			webIDEGeneration = webIDEConnectionGeneration, -- 3007
			embeddedSupported = supportsCompilerWebView(), -- 3008
			embeddedRequested = compilerRequested, -- 3009
			embeddedReady = compilerReady, -- 3010
			users = compilerUsers, -- 3011
			queuedJobs = #compilerJobs, -- 3012
			failure = compilerFailure -- 3013
		}, -- 3005
		assetPath = Content.assetPath, -- 3014
		writablePath = Content.writablePath, -- 3015
		appPath = Content.appPath, -- 3016
		waTemplateReady = waTemplateReady, -- 3017
		running = running -- 3018
	} -- 2992
end -- 2987
HttpServer:post("/status", function() -- 3021
	return getServerStatus() -- 3022
end) -- 3021
HttpServer:postSchedule("/doctor/fix", function(req) -- 3024
	do -- 3025
		local _type_0 = type(req) -- 3025
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3025
		if _tab_0 then -- 3025
			local openWebIDE -- 3025
			do -- 3025
				local _obj_0 = req.body -- 3025
				local _type_1 = type(_obj_0) -- 3025
				if "table" == _type_1 or "userdata" == _type_1 then -- 3025
					openWebIDE = _obj_0.openWebIDE -- 3025
				end -- 3025
			end -- 3025
			if openWebIDE ~= nil then -- 3025
				if not openWebIDE then -- 3026
					return { -- 3027
						success = false, -- 3027
						message = "nothing to fix" -- 3027
					} -- 3027
				end -- 3026
				local status = getServerStatus() -- 3028
				if status.webIDEConnected then -- 3029
					return { -- 3030
						success = true, -- 3030
						fixed = false, -- 3030
						message = "Web IDE already connected.", -- 3030
						status = status -- 3030
					} -- 3030
				end -- 3029
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 3031
				if waitSeconds > 0 then -- 3032
					local deadline = os.time() + waitSeconds -- 3033
					repeat -- 3034
						sleep(0.2) -- 3035
						status = getServerStatus() -- 3036
						if status.webIDEConnected then -- 3037
							return { -- 3038
								success = true, -- 3038
								fixed = false, -- 3038
								reconnected = true, -- 3038
								message = "Web IDE reconnected.", -- 3038
								status = status -- 3038
							} -- 3038
						end -- 3037
					until os.time() >= deadline -- 3034
				end -- 3032
				if not isDesktopPlatform() then -- 3040
					return { -- 3041
						success = false, -- 3041
						message = "opening Web IDE is only supported on desktop platforms", -- 3041
						status = status -- 3041
					} -- 3041
				end -- 3040
				local url = "http://localhost:8866" -- 3042
				App:openURL(url) -- 3043
				status.openedURL = url -- 3044
				return { -- 3045
					success = true, -- 3045
					fixed = true, -- 3045
					message = "Opened Web IDE in the local browser.", -- 3045
					url = url, -- 3045
					status = status -- 3045
				} -- 3045
			end -- 3025
		end -- 3025
	end -- 3025
	return { -- 3024
		success = false, -- 3024
		message = "invalid call" -- 3024
	} -- 3024
end) -- 3024
local status = { } -- 3047
_module_0 = status -- 3048
status.transpileTSFile = transpileTSFile -- 3050
HttpServer:postSchedule("/godot/project", function(req) -- 3053
	do -- 3054
		local _type_0 = type(req) -- 3054
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3054
		if _tab_0 then -- 3054
			local path -- 3054
			do -- 3054
				local _obj_0 = req.body -- 3054
				local _type_1 = type(_obj_0) -- 3054
				if "table" == _type_1 or "userdata" == _type_1 then -- 3054
					path = _obj_0.path -- 3054
				end -- 3054
			end -- 3054
			if path ~= nil then -- 3054
				if not (type(path) == "string" and Content:isAbsolutePath(path)) then -- 3055
					return invalidArguments -- 3055
				end -- 3055
				local releaseAgent = AgentHost.acquire() -- 3056
				local _ <close> = setmetatable({ }, { -- 3057
					__close = function() -- 3057
						return releaseAgent() -- 3057
					end -- 3057
				}) -- 3057
				local GodotBuild = require("Agent.Tool.GodotBuild") -- 3058
				local project = GodotBuild.findGodotProject(Content.writablePath, path) or GodotBuild.findGodotProject(Content.assetPath, path) -- 3059
				if not project then -- 3060
					return { -- 3060
						success = true, -- 3060
						found = false -- 3060
					} -- 3060
				end -- 3060
				if not (req.body.build == true) then -- 3061
					return { -- 3061
						success = true, -- 3061
						found = true, -- 3061
						projectRoot = project -- 3061
					} -- 3061
				end -- 3061
				local result -- 3062
				local promise = GodotBuild.buildGodotProject(project) -- 3063
				local onFulfilled -- 3064
				onFulfilled = function(_, value) -- 3064
					result = value -- 3065
				end -- 3064
				local onRejected -- 3066
				onRejected = function(_, err) -- 3066
					result = { -- 3067
						success = false, -- 3067
						message = tostring(err) -- 3067
					} -- 3067
				end -- 3066
				promise["then"](promise, onFulfilled, onRejected) -- 3068
				wait(function() -- 3069
					return result ~= nil -- 3069
				end) -- 3069
				result.found = true -- 3070
				result.projectRoot = project -- 3071
				return result -- 3072
			end -- 3054
		end -- 3054
	end -- 3054
	return invalidArguments -- 3053
end) -- 3053
status.buildAsync = function(path) -- 3074
	if not Content:exist(path) then -- 3075
		return { -- 3076
			success = false, -- 3076
			file = path, -- 3076
			message = "file not existed" -- 3076
		} -- 3076
	end -- 3075
	do -- 3077
		local _exp_0 = Path:getExt(path) -- 3077
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 3077
			if '' == Path:getExt(Path:getName(path)) then -- 3078
				local content = Content:loadAsync(path) -- 3079
				if content then -- 3079
					local resultCodes, err = compileFileAsync(path, content) -- 3080
					if resultCodes then -- 3080
						return { -- 3081
							success = true, -- 3081
							file = path -- 3081
						} -- 3081
					else -- 3083
						return { -- 3083
							success = false, -- 3083
							file = path, -- 3083
							message = err -- 3083
						} -- 3083
					end -- 3080
				end -- 3079
			end -- 3078
		elseif "lua" == _exp_0 then -- 3084
			local content = Content:loadAsync(path) -- 3085
			if content then -- 3085
				do -- 3086
					local isTIC80 = CheckTIC80Code(content) -- 3086
					if isTIC80 then -- 3086
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 3087
					end -- 3086
				end -- 3086
				local success, info -- 3088
				do -- 3088
					local _obj_0 = luaCheck(path, content) -- 3088
					success, info = _obj_0.success, _obj_0.info -- 3088
				end -- 3088
				if success then -- 3089
					return { -- 3090
						success = true, -- 3090
						file = path -- 3090
					} -- 3090
				elseif info and #info > 0 then -- 3091
					local messages = { } -- 3092
					for _index_0 = 1, #info do -- 3093
						local _des_0 = info[_index_0] -- 3093
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3093
						local lineText = "" -- 3094
						if line then -- 3095
							local currentLine = 1 -- 3096
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3097
								if currentLine == line then -- 3098
									lineText = text -- 3099
									break -- 3100
								end -- 3098
								currentLine = currentLine + 1 -- 3101
							end -- 3097
						end -- 3095
						if line then -- 3102
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3103
						else -- 3105
							messages[#messages + 1] = message -- 3105
						end -- 3102
					end -- 3093
					return { -- 3106
						success = false, -- 3106
						file = path, -- 3106
						message = table.concat(messages, "\n") -- 3106
					} -- 3106
				else -- 3108
					return { -- 3108
						success = false, -- 3108
						file = path, -- 3108
						message = "lua check failed" -- 3108
					} -- 3108
				end -- 3089
			end -- 3085
		elseif "yarn" == _exp_0 then -- 3109
			local content = Content:loadAsync(path) -- 3110
			if content then -- 3110
				local res, _, err = yarncompile(content, true) -- 3111
				if res then -- 3111
					return { -- 3112
						success = true, -- 3112
						file = path -- 3112
					} -- 3112
				else -- 3114
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3114
					local lineText = "" -- 3115
					if line then -- 3116
						local currentLine = 1 -- 3117
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3118
							if currentLine == line then -- 3119
								lineText = text -- 3120
								break -- 3121
							end -- 3119
							currentLine = currentLine + 1 -- 3122
						end -- 3118
					end -- 3116
					if node ~= "" then -- 3123
						node = "node: " .. tostring(node) .. ", " -- 3124
					else -- 3125
						node = "" -- 3125
					end -- 3123
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3126
					return { -- 3127
						success = false, -- 3127
						file = path, -- 3127
						message = message -- 3127
					} -- 3127
				end -- 3111
			end -- 3110
		end -- 3077
	end -- 3077
	return { -- 3128
		success = false, -- 3128
		file = path, -- 3128
		message = "invalid file to build" -- 3128
	} -- 3128
end -- 3074
HttpServer:postSchedule("/git/commit-files", function(req) -- 3130
	do -- 3131
		local _type_0 = type(req) -- 3131
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3131
		if _tab_0 then -- 3131
			local body = req.body -- 3131
			if body ~= nil then -- 3131
				local repoPath, commit = body.repoPath, body.commit -- 3132
				if gitInvalidRepoPath(repoPath) then -- 3133
					return { -- 3133
						success = false, -- 3133
						message = "invalid repoPath" -- 3133
					} -- 3133
				end -- 3133
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3134
					return { -- 3134
						success = false, -- 3134
						message = "invalid commit" -- 3134
					} -- 3134
				end -- 3134
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3135
				if not res.success then -- 3136
					return res -- 3136
				end -- 3136
				return { -- 3137
					success = true, -- 3137
					status = res.status, -- 3137
					data = res.status and res.status.data -- 3137
				} -- 3137
			end -- 3131
		end -- 3131
	end -- 3131
	return invalidArguments -- 3130
end) -- 3130
thread(function() -- 3139
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3140
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3141
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3142
		local storedAsset -- 3145
		storedAsset = function(file) -- 3145
			if Content:exist(file) then -- 3146
				return Content:load(file) -- 3147
			elseif Content:exist(file .. ".gz") then -- 3148
				return Content:load(file .. ".gz") -- 3149
			else -- 3150
				return "" -- 3150
			end -- 3146
		end -- 3145
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3151
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3152
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3153
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3154
		local readyContent = table.concat({ -- 3156
			App.version, -- 3156
			storedAsset(doraWeb), -- 3157
			storedAsset(heavyAssets), -- 3158
			storedAsset(runtimeIndex), -- 3159
			storedAsset(compilerIndex), -- 3160
			storedAsset(manifest) -- 3161
		}, "\n") -- 3155
		local needReload -- 3163
		if Content:exist(doraReady) then -- 3163
			needReload = readyContent ~= Content:load(doraReady) -- 3164
		else -- 3165
			needReload = true -- 3165
		end -- 3163
		if needReload then -- 3166
			Content:remove(Path(Content.appPath, ".www")) -- 3167
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3168
			Content:save(doraReady, readyContent) -- 3172
			print("Dora Dora is ready!") -- 3173
		end -- 3166
	end -- 3142
	if App.platform == "Emscripten" then -- 3174
		status.url = nil -- 3175
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3176
	end -- 3174
	HttpServer:clearStaticCacheControls() -- 3177
	HttpServer:setStaticCacheControl("no-cache") -- 3178
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3179
	if HttpServer:start(8866) then -- 3183
		local localIP = HttpServer.localIP -- 3184
		if localIP == "" then -- 3185
			localIP = "localhost" -- 3185
		end -- 3185
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3186
		return HttpServer:startWS(8868) -- 3187
	else -- 3189
		status.url = nil -- 3189
		return print("8866 Port not available!") -- 3190
	end -- 3183
end) -- 3139
return _module_0 -- 1
