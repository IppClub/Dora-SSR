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
				return AgentSession.sendPrompt(sessionId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId, nil, nil, req.body.submission) -- 785
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
				return AgentSession.sendLocalPrompt(sessionId, prompt, localAgentConfigId, req.body.submission) -- 789
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
local updater = require("Tools.SelfUpdater.Service") -- 1478
HttpServer:post("/engine-update/state", function() -- 1479
	return require("Script.Dev.Entry").getUpdateState() -- 1479
end) -- 1479
HttpServer:post("/engine-update/check", function(req) -- 1480
	local source = req.body and req.body.source -- 1481
	if not (source == nil or ("AtomGit" == source or "GitHub" == source)) then -- 1482
		return { -- 1482
			success = false -- 1482
		} -- 1482
	end -- 1482
	return { -- 1483
		success = require("Script.Dev.Entry").checkForUpdates(true, source) -- 1483
	} -- 1483
end) -- 1480
HttpServer:post("/engine-update/download", function(req) -- 1484
	local target = req.body and req.body.platform -- 1485
	if target ~= nil then -- 1486
		if not (("windows-x64" == target or "windows-x64-opengl" == target or "windows-x64-msi" == target or "windows-x64-opengl-msi" == target)) then -- 1487
			return { -- 1487
				success = false -- 1487
			} -- 1487
		end -- 1487
	end -- 1486
	return { -- 1488
		success = updater.downloadUpdate(target) -- 1488
	} -- 1488
end) -- 1484
HttpServer:post("/engine-update/cancel", function() -- 1489
	return { -- 1489
		success = updater.cancelOperation() -- 1489
	} -- 1489
end) -- 1489
HttpServer:post("/engine-update/discard", function() -- 1490
	return { -- 1490
		success = updater.discardPrepared() -- 1490
	} -- 1490
end) -- 1490
HttpServer:post("/engine-update/ignore", function() -- 1491
	return { -- 1491
		success = updater.ignoreUpdate() -- 1491
	} -- 1491
end) -- 1491
HttpServer:post("/engine-update/install", function(req) -- 1492
	return { -- 1492
		success = updater.installUpdate(req.body and req.body.confirmed == true) -- 1492
	} -- 1492
end) -- 1492
HttpServer:post("/info", function(req) -- 1494
	local Entry = require("Script.Dev.Entry") -- 1495
	local config = Entry.getConfig() -- 1496
	do -- 1497
		local _type_0 = type(req) -- 1497
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1497
		if _tab_0 then -- 1497
			local webIDETourCompleted -- 1497
			do -- 1497
				local _obj_0 = req.body -- 1497
				local _type_1 = type(_obj_0) -- 1497
				if "table" == _type_1 or "userdata" == _type_1 then -- 1497
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1497
				end -- 1497
			end -- 1497
			if webIDETourCompleted ~= nil then -- 1497
				config.webIDETourCompleted = webIDETourCompleted == true -- 1498
			end -- 1497
		end -- 1497
	end -- 1497
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1499
	local engineDev = Entry.getEngineDev() -- 1500
	Entry.connectWebIDE(req.body and req.body.embedded == true) -- 1501
	return { -- 1503
		platform = App.platform, -- 1503
		locale = App.locale, -- 1504
		version = App.version, -- 1505
		engineDev = engineDev, -- 1506
		webProfiler = webProfiler, -- 1507
		drawerWidth = drawerWidth, -- 1508
		webIDETourCompleted = webIDETourCompleted == true -- 1509
	} -- 1502
end) -- 1494
local ensureLLMConfigTable -- 1511
ensureLLMConfigTable = function() -- 1511
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1512
	if columns and #columns > 0 then -- 1513
		local expected = { -- 1515
			id = true, -- 1515
			name = true, -- 1516
			url = true, -- 1517
			model = true, -- 1518
			api_key = true, -- 1519
			context_window = true, -- 1520
			temperature = true, -- 1521
			max_tokens = true, -- 1522
			reasoning_effort = true, -- 1523
			custom_options = true, -- 1524
			supports_function_calling = true, -- 1525
			active = true, -- 1526
			created_at = true, -- 1527
			updated_at = true -- 1528
		} -- 1514
		local existing = { } -- 1530
		local valid = true -- 1531
		for _index_0 = 1, #columns do -- 1532
			local row = columns[_index_0] -- 1532
			local columnName = tostring(row[2]) -- 1533
			existing[columnName] = true -- 1534
			if not expected[columnName] then -- 1535
				valid = false -- 1536
				break -- 1537
			end -- 1535
		end -- 1532
		if valid then -- 1538
			if not existing.context_window then -- 1539
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1540
			end -- 1539
			if not existing.temperature then -- 1541
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1542
			end -- 1541
			if not existing.max_tokens then -- 1543
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 64000") -- 1544
			end -- 1543
			if not existing.reasoning_effort then -- 1545
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1546
			end -- 1545
			if not existing.custom_options then -- 1547
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1548
			end -- 1547
		else -- 1550
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1550
		end -- 1538
	end -- 1513
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
	]]) -- 1551
	require("Agent.Config.LLMConfigMigration").upgradeLLMConfig() -- 1570
	return require("Agent.Config.LLMConfigNames").upgradeLLMConfigNames() -- 1571
end -- 1511
local normalizeContextWindow -- 1573
normalizeContextWindow = function(value) -- 1573
	local contextWindow = tonumber(value) -- 1574
	if contextWindow == nil or contextWindow < 64000 then -- 1575
		return 64000 -- 1576
	end -- 1575
	return math.max(64000, math.floor(contextWindow)) -- 1577
end -- 1573
local normalizeTemperature -- 1579
normalizeTemperature = function(value) -- 1579
	local temperature = tonumber(value) -- 1580
	if temperature == nil then -- 1581
		return 0.1 -- 1582
	end -- 1581
	return math.max(0, math.min(2, temperature)) -- 1583
end -- 1579
local normalizeMaxTokens -- 1585
normalizeMaxTokens = function(value) -- 1585
	local maxTokens = tonumber(value) -- 1586
	if maxTokens == nil or maxTokens < 1 then -- 1587
		return 64000 -- 1588
	end -- 1587
	return math.max(1, math.floor(maxTokens)) -- 1589
end -- 1585
local normalizeReasoningEffort -- 1591
normalizeReasoningEffort = function(value) -- 1591
	if value == nil then -- 1592
		return "" -- 1593
	end -- 1592
	local effort = tostring(value) -- 1594
	return effort:match("^%s*(.-)%s*$") or "" -- 1595
end -- 1591
local normalizeCustomOptions -- 1597
normalizeCustomOptions = function(value) -- 1597
	if value == nil then -- 1598
		return "" -- 1599
	end -- 1598
	local options = tostring(value) -- 1600
	options = options:match("^%s*(.-)%s*$") or "" -- 1601
	return options -- 1602
end -- 1597
local validateCustomOptions -- 1604
validateCustomOptions = function(value) -- 1604
	local options = normalizeCustomOptions(value) -- 1605
	if options == "" then -- 1606
		return true -- 1606
	end -- 1606
	if not options:match("^%s*{") then -- 1607
		return false -- 1607
	end -- 1607
	local decoded = json.decode(options) -- 1608
	return type(decoded) == "table" -- 1609
end -- 1604
HttpServer:post("/llm/list", function() -- 1611
	ensureLLMConfigTable() -- 1612
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options\n		from LLMConfig\n		order by id asc") -- 1613
	local items -- 1617
	if rows and #rows > 0 then -- 1617
		local _accum_0 = { } -- 1618
		local _len_0 = 1 -- 1618
		for _index_0 = 1, #rows do -- 1618
			local _des_0 = rows[_index_0] -- 1618
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10] -- 1618
			_accum_0[_len_0] = { -- 1619
				id = id, -- 1619
				name = name, -- 1619
				url = url, -- 1619
				model = model, -- 1619
				key = key, -- 1619
				contextWindow = normalizeContextWindow(contextWindow), -- 1619
				temperature = normalizeTemperature(temperature), -- 1619
				maxTokens = normalizeMaxTokens(maxTokens), -- 1619
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1619
				customOptions = normalizeCustomOptions(customOptions) -- 1619
			} -- 1619
			_len_0 = _len_0 + 1 -- 1619
		end -- 1618
		items = _accum_0 -- 1617
	end -- 1617
	return { -- 1620
		success = true, -- 1620
		items = items -- 1620
	} -- 1620
end) -- 1611
HttpServer:post("/llm/create", function(req) -- 1622
	ensureLLMConfigTable() -- 1623
	do -- 1624
		local _type_0 = type(req) -- 1624
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1624
		if _tab_0 then -- 1624
			local body = req.body -- 1624
			if body ~= nil then -- 1624
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions -- 1625
				local now = os.time() -- 1626
				if name == nil or url == nil or model == nil or key == nil then -- 1627
					return invalidArguments -- 1628
				end -- 1627
				local names = require("Agent.Config.LLMConfigNames") -- 1629
				name = names.normalizeLLMConfigName(name) -- 1630
				if not name then -- 1631
					return { -- 1631
						success = false, -- 1631
						code = "INVALID_LLM_CONFIG_NAME", -- 1631
						message = "LLM configuration name must be a non-empty string" -- 1631
					} -- 1631
				end -- 1631
				local nameCheck = names.checkLLMConfigName(name) -- 1632
				if not nameCheck.success then -- 1633
					return nameCheck -- 1633
				end -- 1633
				contextWindow = normalizeContextWindow(contextWindow) -- 1634
				temperature = normalizeTemperature(temperature) -- 1635
				maxTokens = normalizeMaxTokens(maxTokens) -- 1636
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1637
				customOptions = normalizeCustomOptions(customOptions) -- 1638
				if not validateCustomOptions(customOptions) then -- 1639
					return { -- 1639
						success = false, -- 1639
						message = "customOptions must be a JSON object" -- 1639
					} -- 1639
				end -- 1639
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1646
					tostring(name), -- 1646
					tostring(url), -- 1647
					tostring(model), -- 1648
					tostring(key), -- 1649
					contextWindow, -- 1650
					temperature, -- 1651
					maxTokens, -- 1652
					reasoningEffort, -- 1653
					customOptions, -- 1654
					1, -- 1655
					now, -- 1656
					now -- 1657
				}) -- 1640
				if affected < 0 then -- 1659
					nameCheck = names.checkLLMConfigName(name) -- 1660
					if not nameCheck.success then -- 1661
						return nameCheck -- 1661
					end -- 1661
				end -- 1659
				return { -- 1662
					success = affected > 0 -- 1662
				} -- 1662
			end -- 1624
		end -- 1624
	end -- 1624
	return invalidArguments -- 1622
end) -- 1622
HttpServer:post("/llm/update", function(req) -- 1664
	ensureLLMConfigTable() -- 1665
	do -- 1666
		local _type_0 = type(req) -- 1666
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1666
		if _tab_0 then -- 1666
			local body = req.body -- 1666
			if body ~= nil then -- 1666
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions -- 1667
				local now = os.time() -- 1668
				id = tonumber(id) -- 1669
				if id == nil or id <= 0 or id ~= math.floor(id) then -- 1670
					return invalidArguments -- 1670
				end -- 1670
				local names = require("Agent.Config.LLMConfigNames") -- 1671
				name = names.normalizeLLMConfigName(name) -- 1672
				if not name then -- 1673
					return { -- 1673
						success = false, -- 1673
						code = "INVALID_LLM_CONFIG_NAME", -- 1673
						message = "LLM configuration name must be a non-empty string" -- 1673
					} -- 1673
				end -- 1673
				local nameCheck = names.checkLLMConfigName(name, id) -- 1674
				if not nameCheck.success then -- 1675
					return nameCheck -- 1675
				end -- 1675
				contextWindow = normalizeContextWindow(contextWindow) -- 1676
				temperature = normalizeTemperature(temperature) -- 1677
				maxTokens = normalizeMaxTokens(maxTokens) -- 1678
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1679
				customOptions = normalizeCustomOptions(customOptions) -- 1680
				if not validateCustomOptions(customOptions) then -- 1681
					return { -- 1681
						success = false, -- 1681
						message = "customOptions must be a JSON object" -- 1681
					} -- 1681
				end -- 1681
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, updated_at = ?\n			where id = ?", { -- 1686
					tostring(name), -- 1686
					tostring(url), -- 1687
					tostring(model), -- 1688
					tostring(key), -- 1689
					contextWindow, -- 1690
					temperature, -- 1691
					maxTokens, -- 1692
					reasoningEffort, -- 1693
					customOptions, -- 1694
					now, -- 1695
					id -- 1696
				}) -- 1682
				if affected < 0 then -- 1698
					nameCheck = names.checkLLMConfigName(name, id) -- 1699
					if not nameCheck.success then -- 1700
						return nameCheck -- 1700
					end -- 1700
				end -- 1698
				return { -- 1701
					success = affected > 0 -- 1701
				} -- 1701
			end -- 1666
		end -- 1666
	end -- 1666
	return invalidArguments -- 1664
end) -- 1664
HttpServer:post("/llm/delete", function(req) -- 1703
	ensureLLMConfigTable() -- 1704
	do -- 1705
		local _type_0 = type(req) -- 1705
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1705
		if _tab_0 then -- 1705
			local id -- 1705
			do -- 1705
				local _obj_0 = req.body -- 1705
				local _type_1 = type(_obj_0) -- 1705
				if "table" == _type_1 or "userdata" == _type_1 then -- 1705
					id = _obj_0.id -- 1705
				end -- 1705
			end -- 1705
			if id ~= nil then -- 1705
				id = tonumber(id) -- 1706
				if id == nil then -- 1707
					return invalidArguments -- 1707
				end -- 1707
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1708
					id -- 1708
				}) -- 1708
				return { -- 1709
					success = affected >= 0 -- 1709
				} -- 1709
			end -- 1705
		end -- 1705
	end -- 1705
	return invalidArguments -- 1703
end) -- 1703
HttpServer:post("/local-agent/list", function() -- 1711
	return { -- 1712
		success = true, -- 1712
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1712
		items = AgentLocalAgent.listConfigs() -- 1712
	} -- 1712
end) -- 1711
HttpServer:post("/local-agent/save", function(req) -- 1714
	do -- 1715
		local _type_0 = type(req) -- 1715
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1715
		if _tab_0 then -- 1715
			local body = req.body -- 1715
			if body ~= nil then -- 1715
				return AgentLocalAgent.saveConfig(body) -- 1716
			end -- 1715
		end -- 1715
	end -- 1715
	return invalidArguments -- 1714
end) -- 1714
HttpServer:post("/local-agent/delete", function(req) -- 1718
	do -- 1719
		local _type_0 = type(req) -- 1719
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1719
		if _tab_0 then -- 1719
			local id -- 1719
			do -- 1719
				local _obj_0 = req.body -- 1719
				local _type_1 = type(_obj_0) -- 1719
				if "table" == _type_1 or "userdata" == _type_1 then -- 1719
					id = _obj_0.id -- 1719
				end -- 1719
			end -- 1719
			if id ~= nil then -- 1719
				return AgentLocalAgent.deleteConfig(id) -- 1720
			end -- 1719
		end -- 1719
	end -- 1719
	return invalidArguments -- 1718
end) -- 1718
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1722
	do -- 1723
		local _type_0 = type(req) -- 1723
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1723
		if _tab_0 then -- 1723
			local id -- 1723
			do -- 1723
				local _obj_0 = req.body -- 1723
				local _type_1 = type(_obj_0) -- 1723
				if "table" == _type_1 or "userdata" == _type_1 then -- 1723
					id = _obj_0.id -- 1723
				end -- 1723
			end -- 1723
			if id ~= nil then -- 1723
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1724
			end -- 1723
		end -- 1723
	end -- 1723
	return invalidArguments -- 1722
end) -- 1722
HttpServer:post("/stat", function(req) -- 1726
	do -- 1727
		local _type_0 = type(req) -- 1727
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1727
		if _tab_0 then -- 1727
			local path -- 1727
			do -- 1727
				local _obj_0 = req.body -- 1727
				local _type_1 = type(_obj_0) -- 1727
				if "table" == _type_1 or "userdata" == _type_1 then -- 1727
					path = _obj_0.path -- 1727
				end -- 1727
			end -- 1727
			if path ~= nil then -- 1727
				if not Content:exist(path) then -- 1728
					return { -- 1729
						success = false, -- 1729
						message = "target not existed" -- 1729
					} -- 1729
				end -- 1728
				if Content:isdir(path) then -- 1730
					return { -- 1731
						success = false, -- 1731
						message = "failed to stat a directory" -- 1731
					} -- 1731
				end -- 1730
				local size, isBinary = Content:getAttr(path) -- 1732
				if size then -- 1732
					return { -- 1733
						success = true, -- 1733
						size = size, -- 1733
						isBinary = isBinary -- 1733
					} -- 1733
				end -- 1732
			end -- 1727
		end -- 1727
	end -- 1727
	return { -- 1726
		success = false, -- 1726
		message = "failed to stat" -- 1726
	} -- 1726
end) -- 1726
HttpServer:post("/new", function(req) -- 1735
	do -- 1736
		local _type_0 = type(req) -- 1736
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1736
		if _tab_0 then -- 1736
			local path -- 1736
			do -- 1736
				local _obj_0 = req.body -- 1736
				local _type_1 = type(_obj_0) -- 1736
				if "table" == _type_1 or "userdata" == _type_1 then -- 1736
					path = _obj_0.path -- 1736
				end -- 1736
			end -- 1736
			local content -- 1736
			do -- 1736
				local _obj_0 = req.body -- 1736
				local _type_1 = type(_obj_0) -- 1736
				if "table" == _type_1 or "userdata" == _type_1 then -- 1736
					content = _obj_0.content -- 1736
				end -- 1736
			end -- 1736
			local folder -- 1736
			do -- 1736
				local _obj_0 = req.body -- 1736
				local _type_1 = type(_obj_0) -- 1736
				if "table" == _type_1 or "userdata" == _type_1 then -- 1736
					folder = _obj_0.folder -- 1736
				end -- 1736
			end -- 1736
			if path ~= nil and content ~= nil and folder ~= nil then -- 1736
				if Content:exist(path) then -- 1737
					return { -- 1738
						success = false, -- 1738
						message = "TargetExisted" -- 1738
					} -- 1738
				end -- 1737
				local parent = Path:getPath(path) -- 1739
				local files = Content:getFiles(parent) -- 1740
				if folder then -- 1741
					local name = Path:getFilename(path):lower() -- 1742
					for _index_0 = 1, #files do -- 1743
						local file = files[_index_0] -- 1743
						if name == Path:getFilename(file):lower() then -- 1744
							return { -- 1745
								success = false, -- 1745
								message = "TargetExisted" -- 1745
							} -- 1745
						end -- 1744
					end -- 1743
					if Content:mkdir(path) then -- 1746
						return { -- 1747
							success = true -- 1747
						} -- 1747
					end -- 1746
				else -- 1749
					local name = Path:getName(path):lower() -- 1749
					local targetExt = Path:getExt(path) -- 1750
					for _index_0 = 1, #files do -- 1751
						local file = files[_index_0] -- 1751
						if name == Path:getName(file):lower() then -- 1752
							local ext = Path:getExt(file) -- 1753
							if not ("tl" == targetExt or "yue" == targetExt or "ts" == targetExt or "tsx" == targetExt or "vs" == targetExt or "bl" == targetExt or "xml" == targetExt or "lua" == targetExt) or not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1754
								goto _continue_0 -- 1755
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1756
								goto _continue_0 -- 1757
							end -- 1754
							return { -- 1758
								success = false, -- 1758
								message = "SourceExisted" -- 1758
							} -- 1758
						end -- 1752
						::_continue_0:: -- 1752
					end -- 1751
					if Content:save(path, content) then -- 1759
						return { -- 1760
							success = true -- 1760
						} -- 1760
					end -- 1759
				end -- 1741
			end -- 1736
		end -- 1736
	end -- 1736
	return { -- 1735
		success = false, -- 1735
		message = "Failed" -- 1735
	} -- 1735
end) -- 1735
local deleteAsset -- 1762
deleteAsset = function(path) -- 1762
	if not Content:exist(path) then -- 1763
		return false -- 1763
	end -- 1763
	local projectRoot -- 1764
	if Content:isdir(path) and isProjectRootDir(path) then -- 1764
		projectRoot = path -- 1764
	else -- 1764
		projectRoot = nil -- 1764
	end -- 1764
	local parent = Path:getPath(path) -- 1765
	local files = Content:getFiles(parent) -- 1766
	local name = Path:getName(path):lower() -- 1767
	local ext = Path:getExt(path) -- 1768
	for _index_0 = 1, #files do -- 1769
		local file = files[_index_0] -- 1769
		if name == Path:getName(file):lower() then -- 1770
			local _exp_0 = Path:getExt(file) -- 1771
			if "tl" == _exp_0 then -- 1771
				if ("vs" == ext) then -- 1771
					Content:remove(Path(parent, file)) -- 1772
				end -- 1771
			elseif "lua" == _exp_0 then -- 1773
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1773
					Content:remove(Path(parent, file)) -- 1774
				end -- 1773
			end -- 1771
		end -- 1770
	end -- 1769
	if Content:remove(path) then -- 1775
		if projectRoot then -- 1776
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1777
		end -- 1776
		return true -- 1778
	end -- 1775
	return false -- 1779
end -- 1762
local moveAsset -- 1781
moveAsset = function(old, new) -- 1781
	if not (Content:exist(old) and not Content:exist(new)) then -- 1782
		return false -- 1782
	end -- 1782
	local renamedDir = Content:isdir(old) -- 1783
	local parent = Path:getPath(new) -- 1784
	local files = Content:getFiles(parent) -- 1785
	if renamedDir then -- 1786
		local name = Path:getFilename(new):lower() -- 1787
		for _index_0 = 1, #files do -- 1788
			local file = files[_index_0] -- 1788
			if name == Path:getFilename(file):lower() then -- 1789
				return false -- 1790
			end -- 1789
		end -- 1788
	else -- 1792
		local name = Path:getName(new):lower() -- 1792
		local ext = Path:getExt(new) -- 1793
		for _index_0 = 1, #files do -- 1794
			local file = files[_index_0] -- 1794
			if name == Path:getName(file):lower() then -- 1795
				local fileExt = Path:getExt(file) -- 1796
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) or not ("tl" == fileExt or "yue" == fileExt or "ts" == fileExt or "tsx" == fileExt or "vs" == fileExt or "bl" == fileExt or "xml" == fileExt or "lua" == fileExt) then -- 1797
					goto _continue_0 -- 1798
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1799
					goto _continue_0 -- 1800
				end -- 1797
				return false -- 1801
			end -- 1795
			::_continue_0:: -- 1795
		end -- 1794
	end -- 1786
	if not Content:move(old, new) then -- 1802
		return false -- 1802
	end -- 1802
	if renamedDir then -- 1803
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1804
	end -- 1803
	local newParent = Path:getPath(new) -- 1805
	parent = Path:getPath(old) -- 1806
	files = Content:getFiles(parent) -- 1807
	local newName = Path:getName(new) -- 1808
	local oldName = Path:getName(old) -- 1809
	local name = oldName:lower() -- 1810
	local ext = Path:getExt(old) -- 1811
	for _index_0 = 1, #files do -- 1812
		local file = files[_index_0] -- 1812
		if name == Path:getName(file):lower() then -- 1813
			local _exp_0 = Path:getExt(file) -- 1814
			if "tl" == _exp_0 then -- 1814
				if ("vs" == ext) then -- 1814
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1815
				end -- 1814
			elseif "lua" == _exp_0 then -- 1816
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1816
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1817
				end -- 1816
			end -- 1814
		end -- 1813
	end -- 1812
	return true -- 1818
end -- 1781
HttpServer:post("/delete", function(req) -- 1820
	do -- 1821
		local _type_0 = type(req) -- 1821
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1821
		if _tab_0 then -- 1821
			local path -- 1821
			do -- 1821
				local _obj_0 = req.body -- 1821
				local _type_1 = type(_obj_0) -- 1821
				if "table" == _type_1 or "userdata" == _type_1 then -- 1821
					path = _obj_0.path -- 1821
				end -- 1821
			end -- 1821
			if path ~= nil then -- 1821
				if deleteAsset(path) then -- 1822
					return { -- 1822
						success = true -- 1822
					} -- 1822
				end -- 1822
			end -- 1821
		end -- 1821
	end -- 1821
	return { -- 1820
		success = false -- 1820
	} -- 1820
end) -- 1820
HttpServer:post("/rename", function(req) -- 1824
	do -- 1825
		local _type_0 = type(req) -- 1825
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1825
		if _tab_0 then -- 1825
			local old -- 1825
			do -- 1825
				local _obj_0 = req.body -- 1825
				local _type_1 = type(_obj_0) -- 1825
				if "table" == _type_1 or "userdata" == _type_1 then -- 1825
					old = _obj_0.old -- 1825
				end -- 1825
			end -- 1825
			local new -- 1825
			do -- 1825
				local _obj_0 = req.body -- 1825
				local _type_1 = type(_obj_0) -- 1825
				if "table" == _type_1 or "userdata" == _type_1 then -- 1825
					new = _obj_0.new -- 1825
				end -- 1825
			end -- 1825
			if old ~= nil and new ~= nil then -- 1825
				if moveAsset(old, new) then -- 1826
					return { -- 1826
						success = true -- 1826
					} -- 1826
				end -- 1826
			end -- 1825
		end -- 1825
	end -- 1825
	return { -- 1824
		success = false -- 1824
	} -- 1824
end) -- 1824
local normalizeAssetPaths -- 1828
normalizeAssetPaths = function(paths) -- 1828
	if not (type(paths) == "table") then -- 1829
		return nil -- 1829
	end -- 1829
	local unique = { } -- 1830
	local candidates = { } -- 1831
	for _index_0 = 1, #paths do -- 1832
		local path = paths[_index_0] -- 1832
		if not (type(path) == "string") then -- 1833
			return nil -- 1833
		end -- 1833
		local relative = relativeToRoot(path, Content.writablePath) -- 1834
		if relative == nil or relative == "" or not Content:exist(path) then -- 1835
			return nil -- 1835
		end -- 1835
		if not unique[path] then -- 1836
			unique[path] = true -- 1837
			candidates[#candidates + 1] = path -- 1838
		end -- 1836
	end -- 1832
	table.sort(candidates, function(a, b) -- 1839
		return #a < #b -- 1839
	end) -- 1839
	local result = { } -- 1840
	for _index_0 = 1, #candidates do -- 1841
		local path = candidates[_index_0] -- 1841
		local contained = false -- 1842
		for _index_1 = 1, #result do -- 1843
			local parent = result[_index_1] -- 1843
			if relativeToRoot(path, parent) ~= nil then -- 1844
				contained = true -- 1845
				break -- 1846
			end -- 1844
		end -- 1843
		if not contained then -- 1847
			result[#result + 1] = path -- 1847
		end -- 1847
	end -- 1841
	return result -- 1848
end -- 1828
HttpServer:postSchedule("/assets/batch", function(req) -- 1850
	do -- 1851
		local _type_0 = type(req) -- 1851
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1851
		if _tab_0 then -- 1851
			local operation -- 1851
			do -- 1851
				local _obj_0 = req.body -- 1851
				local _type_1 = type(_obj_0) -- 1851
				if "table" == _type_1 or "userdata" == _type_1 then -- 1851
					operation = _obj_0.operation -- 1851
				end -- 1851
			end -- 1851
			local sources -- 1851
			do -- 1851
				local _obj_0 = req.body -- 1851
				local _type_1 = type(_obj_0) -- 1851
				if "table" == _type_1 or "userdata" == _type_1 then -- 1851
					sources = _obj_0.sources -- 1851
				end -- 1851
			end -- 1851
			if operation ~= nil and sources ~= nil then -- 1851
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1852
					return { -- 1852
						success = false, -- 1852
						message = "invalid operation" -- 1852
					} -- 1852
				end -- 1852
				sources = normalizeAssetPaths(sources) -- 1853
				if not (sources and #sources > 0) then -- 1854
					return { -- 1854
						success = false, -- 1854
						message = "invalid sources" -- 1854
					} -- 1854
				end -- 1854
				local target = req.body.target -- 1855
				local destinations = { } -- 1856
				if operation ~= "delete" then -- 1857
					if not (type(target) == "string") then -- 1858
						return { -- 1858
							success = false, -- 1858
							message = "invalid target" -- 1858
						} -- 1858
					end -- 1858
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1859
					if targetRelative == nil then -- 1860
						return { -- 1860
							success = false, -- 1860
							message = "invalid target" -- 1860
						} -- 1860
					end -- 1860
					if not (Content:exist(target) and Content:isdir(target)) then -- 1861
						return { -- 1861
							success = false, -- 1861
							message = "invalid target" -- 1861
						} -- 1861
					end -- 1861
					for _index_0 = 1, #sources do -- 1862
						local source = sources[_index_0] -- 1862
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1863
							return { -- 1864
								success = false, -- 1864
								message = "target inside source" -- 1864
							} -- 1864
						end -- 1863
						local destination = Path(target, Path:getFilename(source)) -- 1865
						if Content:exist(destination) then -- 1866
							return { -- 1866
								success = false, -- 1866
								message = "target existed" -- 1866
							} -- 1866
						end -- 1866
						if destinations[destination] then -- 1867
							return { -- 1867
								success = false, -- 1867
								message = "duplicate target" -- 1867
							} -- 1867
						end -- 1867
						destinations[destination] = true -- 1868
					end -- 1862
				end -- 1857
				local changes = { } -- 1869
				local affectedSet = { } -- 1870
				local affectedDirectories = { } -- 1871
				local addAffected -- 1872
				addAffected = function(dir) -- 1872
					if affectedSet[dir] then -- 1873
						return -- 1873
					end -- 1873
					affectedSet[dir] = true -- 1874
					affectedDirectories[#affectedDirectories + 1] = dir -- 1875
				end -- 1872
				if operation ~= "delete" then -- 1876
					addAffected(target) -- 1876
				end -- 1876
				for _index_0 = 1, #sources do -- 1877
					local source = sources[_index_0] -- 1877
					addAffected(Path:getPath(source)) -- 1878
					if operation == "delete" then -- 1879
						if not deleteAsset(source) then -- 1880
							return { -- 1880
								success = false, -- 1880
								message = "delete failed", -- 1880
								changes = changes, -- 1880
								affectedDirectories = affectedDirectories -- 1880
							} -- 1880
						end -- 1880
						changes[#changes + 1] = { -- 1881
							old = source -- 1881
						} -- 1881
					else -- 1883
						local destination = Path(target, Path:getFilename(source)) -- 1883
						local ok -- 1884
						if operation == "copy" then -- 1884
							ok = Content:copyAsync(source, destination) -- 1885
						else -- 1887
							ok = moveAsset(source, destination) -- 1887
						end -- 1884
						if not ok then -- 1888
							return { -- 1888
								success = false, -- 1888
								message = operation .. " failed", -- 1888
								changes = changes, -- 1888
								affectedDirectories = affectedDirectories -- 1888
							} -- 1888
						end -- 1888
						changes[#changes + 1] = { -- 1889
							old = source, -- 1889
							new = destination -- 1889
						} -- 1889
					end -- 1879
				end -- 1877
				return { -- 1890
					success = true, -- 1890
					changes = changes, -- 1890
					affectedDirectories = affectedDirectories -- 1890
				} -- 1890
			end -- 1851
		end -- 1851
	end -- 1851
	return { -- 1850
		success = false, -- 1850
		message = "invalid request" -- 1850
	} -- 1850
end) -- 1850
local withProjectSearchPaths -- 1892
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1892
	local fallbackPaths = { } -- 1893
	local addFallback -- 1894
	addFallback = function(dir) -- 1894
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1894
			fallbackPaths[#fallbackPaths + 1] = dir -- 1894
		end -- 1894
	end -- 1894
	if projectRoot and projectRoot ~= "" then -- 1895
		addFallback(Path(projectRoot, "Script")) -- 1896
		addFallback(projectRoot) -- 1897
	end -- 1895
	if projFile then -- 1898
		local projDir = getProjectDirFromFile(projFile) -- 1899
		if projDir then -- 1899
			addFallback(Path(projDir, "Script")) -- 1900
			addFallback(projDir) -- 1901
		else -- 1903
			addFallback(Path:getPath(projFile)) -- 1903
		end -- 1899
	end -- 1898
	if not (#fallbackPaths > 0) then -- 1904
		return fn() -- 1904
	end -- 1904
	local searchPaths = Content.searchPaths -- 1905
	for _index_0 = 1, #fallbackPaths do -- 1906
		local dir = fallbackPaths[_index_0] -- 1906
		Content:addSearchPath(dir) -- 1906
	end -- 1906
	local _ <close> = setmetatable({ }, { -- 1907
		__close = function() -- 1907
			Content.searchPaths = searchPaths -- 1907
		end -- 1907
	}) -- 1907
	return fn() -- 1908
end -- 1892
HttpServer:post("/exist", function(req) -- 1909
	do -- 1910
		local _type_0 = type(req) -- 1910
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1910
		if _tab_0 then -- 1910
			local file -- 1910
			do -- 1910
				local _obj_0 = req.body -- 1910
				local _type_1 = type(_obj_0) -- 1910
				if "table" == _type_1 or "userdata" == _type_1 then -- 1910
					file = _obj_0.file -- 1910
				end -- 1910
			end -- 1910
			if file ~= nil then -- 1910
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1911
					return { -- 1912
						success = Content:exist(file) -- 1912
					} -- 1912
				end) -- 1911
			end -- 1910
		end -- 1910
	end -- 1910
	return { -- 1909
		success = false -- 1909
	} -- 1909
end) -- 1909
HttpServer:postSchedule("/read", function(req) -- 1913
	do -- 1914
		local _type_0 = type(req) -- 1914
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1914
		if _tab_0 then -- 1914
			local path -- 1914
			do -- 1914
				local _obj_0 = req.body -- 1914
				local _type_1 = type(_obj_0) -- 1914
				if "table" == _type_1 or "userdata" == _type_1 then -- 1914
					path = _obj_0.path -- 1914
				end -- 1914
			end -- 1914
			if path ~= nil then -- 1914
				local readFile -- 1915
				readFile = function() -- 1915
					if Content:exist(path) and not Content:isdir(path) then -- 1916
						local content = Content:loadAsync(path) -- 1917
						if content then -- 1917
							return { -- 1918
								content = content, -- 1918
								success = true, -- 1918
								fullPath = Content:getFullPath(path) -- 1918
							} -- 1918
						end -- 1917
					end -- 1916
					return nil -- 1915
				end -- 1915
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1919
				if result then -- 1919
					return result -- 1919
				end -- 1919
			end -- 1914
		end -- 1914
	end -- 1914
	return { -- 1913
		success = false -- 1913
	} -- 1913
end) -- 1913
local agentDocLanguage -- 1921
agentDocLanguage = function(language) -- 1921
	if language == "zh-Hans" then -- 1922
		return "zh" -- 1922
	else -- 1922
		return "en" -- 1922
	end -- 1922
end -- 1921
HttpServer:postSchedule("/doc/search", function(req) -- 1924
	local body = req.body or { } -- 1925
	local language = body.docLanguage -- 1926
	if not (("en" == language or "zh-Hans" == language)) then -- 1927
		return { -- 1927
			success = false, -- 1927
			message = "unsupported doc language" -- 1927
		} -- 1927
	end -- 1927
	local docType = body.docType -- 1928
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1929
		return { -- 1929
			success = false, -- 1929
			message = "unsupported doc type" -- 1929
		} -- 1929
	end -- 1929
	local codeLanguage = body.programmingLanguage -- 1930
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1931
		return { -- 1931
			success = false, -- 1931
			message = "unsupported programming language" -- 1931
		} -- 1931
	end -- 1931
	if not body.pattern then -- 1932
		return { -- 1932
			success = false, -- 1932
			message = "missing pattern" -- 1932
		} -- 1932
	end -- 1932
	local result = nil -- 1933
	AgentTools.searchDoraDocHttp({ -- 1935
		pattern = body.pattern, -- 1935
		docLanguage = agentDocLanguage(language), -- 1936
		docType = docType, -- 1937
		programmingLanguage = codeLanguage, -- 1938
		limit = body.limit, -- 1939
		useRegex = body.useRegex, -- 1940
		caseSensitive = body.caseSensitive, -- 1941
		includeContent = body.includeContent, -- 1942
		contentWindow = body.contentWindow -- 1943
	}, function(res) -- 1944
		result = res -- 1945
	end) -- 1934
	wait(function() -- 1946
		return result ~= nil -- 1946
	end) -- 1946
	if result and result.success then -- 1947
		result.docLanguage = language -- 1948
	end -- 1947
	if result then -- 1949
		return result -- 1950
	else -- 1952
		return { -- 1952
			success = false, -- 1952
			message = "doc search failed" -- 1952
		} -- 1952
	end -- 1949
	return { -- 1924
		success = false, -- 1924
		message = "invalid call" -- 1924
	} -- 1924
end) -- 1924
HttpServer:postSchedule("/doc/read", function(req) -- 1954
	local body = req.body or { } -- 1955
	local language = body.docLanguage -- 1956
	if not (("en" == language or "zh-Hans" == language)) then -- 1957
		return { -- 1957
			success = false, -- 1957
			message = "unsupported doc language" -- 1957
		} -- 1957
	end -- 1957
	if not body.file then -- 1958
		return { -- 1958
			success = false, -- 1958
			message = "missing file" -- 1958
		} -- 1958
	end -- 1958
	local result = AgentTools.readDoraDoc({ -- 1960
		docLanguage = agentDocLanguage(language), -- 1960
		file = body.file, -- 1961
		startLine = body.startLine, -- 1962
		endLine = body.endLine -- 1963
	}) -- 1959
	if result and result.success then -- 1964
		result.docLanguage = language -- 1965
	end -- 1964
	return result -- 1966
end) -- 1954
local readSyncFile -- 1968
readSyncFile = function(req) -- 1968
	do -- 1969
		local _type_0 = type(req) -- 1969
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1969
		if _tab_0 then -- 1969
			local params = req.params -- 1969
			if params ~= nil then -- 1969
				local path = params.path -- 1970
				if not (type(path) == "string" and path ~= "") then -- 1971
					return { -- 1971
						success = false, -- 1971
						message = "invalid path" -- 1971
					} -- 1971
				end -- 1971
				local exts -- 1972
				if params.exts then -- 1972
					local _accum_0 = { } -- 1973
					local _len_0 = 1 -- 1973
					for ext in params.exts:gmatch("[^|]*") do -- 1973
						_accum_0[_len_0] = ext -- 1973
						_len_0 = _len_0 + 1 -- 1973
					end -- 1973
					exts = _accum_0 -- 1973
				else -- 1974
					exts = { -- 1974
						"" -- 1974
					} -- 1974
				end -- 1972
				local readFileAt -- 1975
				readFileAt = function(targetPath) -- 1975
					if Content:exist(targetPath) then -- 1976
						local content = Content:load(targetPath) -- 1977
						if content then -- 1977
							return { -- 1978
								content = content, -- 1978
								success = true, -- 1978
								fullPath = Content:getFullPath(targetPath) -- 1978
							} -- 1978
						end -- 1977
					end -- 1976
					return nil -- 1975
				end -- 1975
				local readFile -- 1979
				readFile = function(fallbackPaths) -- 1979
					for _index_0 = 1, #exts do -- 1980
						local ext = exts[_index_0] -- 1980
						local targetPath = path .. ext -- 1981
						if not Content:isAbsolutePath(targetPath) then -- 1982
							for _index_1 = 1, #fallbackPaths do -- 1983
								local fallback = fallbackPaths[_index_1] -- 1983
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1984
								if fallbackResult then -- 1984
									return fallbackResult -- 1985
								end -- 1984
							end -- 1983
						end -- 1982
						local fileResult = readFileAt(targetPath) -- 1986
						if fileResult then -- 1986
							return fileResult -- 1987
						end -- 1986
					end -- 1980
					return nil -- 1979
				end -- 1979
				local fallbackPaths = { } -- 1988
				local fallbackCandidates = { } -- 1989
				do -- 1990
					local projectRoot = req.params.projectRoot -- 1990
					if projectRoot then -- 1990
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1991
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1992
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1993
						end -- 1991
					end -- 1990
				end -- 1990
				do -- 1994
					local projFile = req.params.projFile -- 1994
					if projFile then -- 1994
						local projDir = getProjectDirFromFile(projFile) -- 1995
						if projDir then -- 1995
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1996
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1997
						else -- 1999
							projDir = Path:getPath(projFile) -- 1999
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 2000
						end -- 1995
					end -- 1994
				end -- 1994
				for _index_0 = 1, #fallbackCandidates do -- 2001
					local dir = fallbackCandidates[_index_0] -- 2001
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 2002
						local exists = false -- 2003
						for _index_1 = 1, #fallbackPaths do -- 2004
							local fallback = fallbackPaths[_index_1] -- 2004
							if fallback == dir then -- 2005
								exists = true -- 2006
								break -- 2007
							end -- 2005
						end -- 2004
						if not exists then -- 2008
							fallbackPaths[#fallbackPaths + 1] = dir -- 2008
						end -- 2008
					end -- 2002
				end -- 2001
				local readResult = readFile(fallbackPaths) -- 2009
				if readResult then -- 2009
					return readResult -- 2010
				end -- 2009
			end -- 1969
		end -- 1969
	end -- 1969
	return { -- 1968
		success = false -- 1968
	} -- 1968
end -- 1968
HttpServer:get("/read-sync", readSyncFile) -- 2012
HttpServer:post("/read-sync", function(req) -- 2013
	return readSyncFile({ -- 2013
		params = req.body -- 2013
	}) -- 2013
end) -- 2013
local addGeneratedSourceHeader -- 2015
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 2015
	if preserveTIC80 == nil then -- 2015
		preserveTIC80 = false -- 2015
	end -- 2015
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 2016
	if preserveTIC80 then -- 2017
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 2018
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 2019
		end -- 2018
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 2020
	end -- 2017
	return tostring(header) .. "\n" .. tostring(codes) -- 2021
end -- 2015
local compileFileAsync -- 2023
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 2023
	if projectRoot == nil then -- 2023
		projectRoot = nil -- 2023
	end -- 2023
	local file = inputFile -- 2024
	local searchPath -- 2025
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2025
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 2026
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 2030
	elseif not Content:isAbsolutePath(inputFile) then -- 2031
		searchPath = "" -- 2032
	else -- 2033
		local dir = getProjectDirFromFile(inputFile) -- 2033
		if dir then -- 2033
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2034
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 2038
		else -- 2040
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2040
			searchPath = "" -- 2043
		end -- 2033
	end -- 2025
	local outputFile = Path:replaceExt(inputFile, "lua") -- 2044
	local yueext = yue.options.extension -- 2045
	local resultCodes = nil -- 2046
	local resultError = nil -- 2047
	do -- 2048
		local _exp_0 = Path:getExt(inputFile) -- 2048
		if yueext == _exp_0 then -- 2048
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 2049
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 2050
				if not codes then -- 2051
					resultError = err -- 2052
					return -- 2053
				end -- 2051
				local extraGlobal -- 2054
				if isTIC80 then -- 2054
					extraGlobal = tic80APIs -- 2054
				else -- 2054
					extraGlobal = nil -- 2054
				end -- 2054
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 2055
				if not success then -- 2056
					resultError = message -- 2057
					return -- 2058
				end -- 2056
				if codes == "" then -- 2059
					resultCodes = "" -- 2060
					return nil -- 2061
				end -- 2059
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 2062
				return resultCodes -- 2063
			end, function(success) -- 2050
				if not success then -- 2064
					Content:remove(outputFile) -- 2065
					if resultCodes == nil then -- 2066
						resultCodes = false -- 2067
					end -- 2066
				end -- 2064
			end) -- 2050
		elseif "tl" == _exp_0 then -- 2068
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 2069
			if isTIC80 then -- 2070
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2071
			end -- 2070
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2072
			if codes then -- 2072
				if isTIC80 then -- 2073
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2074
				end -- 2073
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2075
				Content:saveAsync(outputFile, resultCodes) -- 2076
			else -- 2078
				Content:remove(outputFile) -- 2078
				resultCodes = false -- 2079
				resultError = err -- 2080
			end -- 2072
		elseif "xml" == _exp_0 then -- 2081
			local codes, err = xml.tolua(sourceCodes) -- 2082
			if codes then -- 2082
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2083
				Content:saveAsync(outputFile, resultCodes) -- 2084
			else -- 2086
				Content:remove(outputFile) -- 2086
				resultCodes = false -- 2087
				resultError = err -- 2088
			end -- 2082
		end -- 2048
	end -- 2048
	wait(function() -- 2089
		return resultCodes ~= nil -- 2089
	end) -- 2089
	if resultCodes then -- 2090
		return resultCodes -- 2091
	else -- 2093
		return nil, resultError -- 2093
	end -- 2090
	return nil -- 2023
end -- 2023
HttpServer:postSchedule("/write", function(req) -- 2095
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2096
	local buildSucceeded = false -- 2097
	local _ <close> = setmetatable({ }, { -- 2098
		__close = function() -- 2098
			return finishUpdate(buildSucceeded) -- 2098
		end -- 2098
	}) -- 2098
	do -- 2099
		local _type_0 = type(req) -- 2099
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2099
		if _tab_0 then -- 2099
			local path -- 2099
			do -- 2099
				local _obj_0 = req.body -- 2099
				local _type_1 = type(_obj_0) -- 2099
				if "table" == _type_1 or "userdata" == _type_1 then -- 2099
					path = _obj_0.path -- 2099
				end -- 2099
			end -- 2099
			local content -- 2099
			do -- 2099
				local _obj_0 = req.body -- 2099
				local _type_1 = type(_obj_0) -- 2099
				if "table" == _type_1 or "userdata" == _type_1 then -- 2099
					content = _obj_0.content -- 2099
				end -- 2099
			end -- 2099
			if path ~= nil and content ~= nil then -- 2099
				if Content:saveAsync(path, content) then -- 2100
					do -- 2101
						local _exp_0 = Path:getExt(path) -- 2101
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2101
							if '' == Path:getExt(Path:getName(path)) then -- 2102
								local resultCodes = compileFileAsync(path, content) -- 2103
								buildSucceeded = resultCodes ~= nil -- 2104
								return { -- 2105
									success = true, -- 2105
									resultCodes = resultCodes -- 2105
								} -- 2105
							end -- 2102
						end -- 2101
					end -- 2101
					buildSucceeded = true -- 2106
					return { -- 2107
						success = true -- 2107
					} -- 2107
				end -- 2100
			end -- 2099
		end -- 2099
	end -- 2099
	return { -- 2095
		success = false -- 2095
	} -- 2095
end) -- 2095
local getWaProjectDirFromFile = nil -- 2109
HttpServer:postSchedule("/build", function(req) -- 2111
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2112
	local buildSucceeded = false -- 2113
	local _ <close> = setmetatable({ }, { -- 2114
		__close = function() -- 2114
			return finishUpdate(buildSucceeded) -- 2114
		end -- 2114
	}) -- 2114
	do -- 2115
		local _type_0 = type(req) -- 2115
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2115
		if _tab_0 then -- 2115
			local path -- 2115
			do -- 2115
				local _obj_0 = req.body -- 2115
				local _type_1 = type(_obj_0) -- 2115
				if "table" == _type_1 or "userdata" == _type_1 then -- 2115
					path = _obj_0.path -- 2115
				end -- 2115
			end -- 2115
			if path ~= nil then -- 2115
				local projectRoot = req.body.projectRoot -- 2116
				if Content:isdir(path) then -- 2117
					local projDir = getWaProjectDirFromFile(path) -- 2118
					if projDir then -- 2118
						local message = Wasm:buildWaAsync(projDir) -- 2119
						if message == "" then -- 2120
							return { -- 2121
								success = true -- 2121
							} -- 2121
						else -- 2123
							return { -- 2123
								success = false, -- 2123
								message = message -- 2123
							} -- 2123
						end -- 2120
					end -- 2118
				end -- 2117
				local _exp_0 = Path:getExt(path) -- 2124
				if "gd" == _exp_0 or "tscn" == _exp_0 or "tres" == _exp_0 or "gdshader" == _exp_0 or "gdshaderinc" == _exp_0 then -- 2125
					local content = Content:loadAsync(path) -- 2126
					if content then -- 2126
						local result = godotCheckAsync(path, content, false) -- 2127
						buildSucceeded = result.success and not result.skipped -- 2128
						return { -- 2129
							success = buildSucceeded, -- 2129
							resultCodes = "", -- 2129
							info = result.info -- 2129
						} -- 2129
					end -- 2126
				elseif "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2130
					if '' == Path:getExt(Path:getName(path)) then -- 2131
						local content = Content:loadAsync(path) -- 2132
						if content then -- 2132
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2133
							if resultCodes then -- 2133
								buildSucceeded = true -- 2134
								return { -- 2135
									success = true, -- 2135
									resultCodes = resultCodes -- 2135
								} -- 2135
							end -- 2133
						end -- 2132
					end -- 2131
				elseif "wa" == _exp_0 then -- 2136
					local projDir = getWaProjectDirFromFile(path) -- 2137
					if projDir then -- 2137
						local message = Wasm:buildWaAsync(projDir) -- 2138
						if message == "" then -- 2139
							return { -- 2140
								success = true -- 2140
							} -- 2140
						else -- 2142
							return { -- 2142
								success = false, -- 2142
								message = message -- 2142
							} -- 2142
						end -- 2139
					else -- 2144
						return { -- 2144
							success = false, -- 2144
							message = 'Wa file needs a project' -- 2144
						} -- 2144
					end -- 2137
				end -- 2124
			end -- 2115
		end -- 2115
	end -- 2115
	return { -- 2111
		success = false -- 2111
	} -- 2111
end) -- 2111
local extentionLevels = { -- 2147
	vs = 2, -- 2147
	bl = 2, -- 2148
	ts = 1, -- 2149
	tsx = 1, -- 2150
	tl = 1, -- 2151
	yue = 1, -- 2152
	xml = 1, -- 2153
	lua = 0 -- 2154
} -- 2146
local visitAssets -- 2156
visitAssets = function(path, workspace, builtin, recursive) -- 2156
	if recursive == nil then -- 2156
		recursive = true -- 2156
	end -- 2156
	local children = nil -- 2157
	local dirs = Content:getDirs(path) -- 2158
	for _index_0 = 1, #dirs do -- 2159
		local dir = dirs[_index_0] -- 2159
		if workspace then -- 2160
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or ".godot" == dir or "node_modules" == dir) then -- 2161
				goto _continue_0 -- 2162
			end -- 2161
		elseif dir == ".git" or dir == ".godot" then -- 2163
			goto _continue_0 -- 2164
		end -- 2160
		if not children then -- 2165
			children = { } -- 2165
		end -- 2165
		local dirPath = Path(path, dir) -- 2166
		if recursive then -- 2167
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2168
		else -- 2170
			children[#children + 1] = { -- 2171
				key = dirPath, -- 2171
				dir = true, -- 2172
				title = dir, -- 2173
				builtin = builtin, -- 2174
				isLeaf = false -- 2175
			} -- 2170
		end -- 2167
		::_continue_0:: -- 2160
	end -- 2159
	local files = Content:getFiles(path) -- 2177
	local names = { } -- 2178
	for _index_0 = 1, #files do -- 2179
		local file = files[_index_0] -- 2179
		if (".DS_Store" == file) then -- 2180
			goto _continue_1 -- 2181
		end -- 2180
		local ext = Path:getExt(file) -- 2182
		if not extentionLevels[ext] then -- 2183
			names[file] = "" -- 2184
			goto _continue_1 -- 2185
		end -- 2183
		local name = Path:getName(file) -- 2186
		ext = names[name] -- 2187
		if ext then -- 2187
			local lv1 -- 2188
			do -- 2188
				local _exp_0 = extentionLevels[ext] -- 2188
				if _exp_0 ~= nil then -- 2188
					lv1 = _exp_0 -- 2188
				else -- 2188
					lv1 = -1 -- 2188
				end -- 2188
			end -- 2188
			ext = Path:getExt(file) -- 2189
			local lv2 -- 2190
			do -- 2190
				local _exp_0 = extentionLevels[ext] -- 2190
				if _exp_0 ~= nil then -- 2190
					lv2 = _exp_0 -- 2190
				else -- 2190
					lv2 = -1 -- 2190
				end -- 2190
			end -- 2190
			if lv2 > lv1 then -- 2191
				names[name] = ext -- 2192
			elseif lv2 == lv1 then -- 2193
				names[name .. '.' .. ext] = "" -- 2194
			end -- 2191
		else -- 2196
			ext = Path:getExt(file) -- 2196
			if not extentionLevels[ext] then -- 2197
				names[file] = "" -- 2198
			else -- 2200
				names[name] = ext -- 2200
			end -- 2197
		end -- 2187
		::_continue_1:: -- 2180
	end -- 2179
	do -- 2201
		local _accum_0 = { } -- 2201
		local _len_0 = 1 -- 2201
		for name, ext in pairs(names) do -- 2201
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2201
			_len_0 = _len_0 + 1 -- 2201
		end -- 2201
		files = _accum_0 -- 2201
	end -- 2201
	for _index_0 = 1, #files do -- 2202
		local file = files[_index_0] -- 2202
		if not children then -- 2203
			children = { } -- 2203
		end -- 2203
		children[#children + 1] = { -- 2205
			key = Path(path, file), -- 2205
			dir = false, -- 2206
			title = file, -- 2207
			builtin = builtin -- 2208
		} -- 2204
	end -- 2202
	if children then -- 2210
		table.sort(children, function(a, b) -- 2211
			if a.dir == b.dir then -- 2212
				return a.title < b.title -- 2213
			else -- 2215
				return a.dir -- 2215
			end -- 2212
		end) -- 2211
	end -- 2210
	return { -- 2217
		key = path, -- 2217
		dir = true, -- 2218
		title = Path:getFilename(path), -- 2219
		builtin = builtin, -- 2220
		isLeaf = not children, -- 2221
		children = children -- 2222
	} -- 2216
end -- 2156
HttpServer:post("/assets/children", function(req) -- 2225
	do -- 2226
		local _type_0 = type(req) -- 2226
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2226
		if _tab_0 then -- 2226
			local path -- 2226
			do -- 2226
				local _obj_0 = req.body -- 2226
				local _type_1 = type(_obj_0) -- 2226
				if "table" == _type_1 or "userdata" == _type_1 then -- 2226
					path = _obj_0.path -- 2226
				end -- 2226
			end -- 2226
			if path ~= nil then -- 2226
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2227
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2228
					return { -- 2228
						success = false -- 2228
					} -- 2228
				end -- 2228
				local node = visitAssets(path, workspace, builtin, false) -- 2229
				return { -- 2230
					success = true, -- 2230
					children = node.children or { } -- 2230
				} -- 2230
			end -- 2226
		end -- 2226
	end -- 2226
	return { -- 2225
		success = false -- 2225
	} -- 2225
end) -- 2225
HttpServer:post("/assets/files", function(req) -- 2232
	do -- 2233
		local _type_0 = type(req) -- 2233
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2233
		if _tab_0 then -- 2233
			local path -- 2233
			do -- 2233
				local _obj_0 = req.body -- 2233
				local _type_1 = type(_obj_0) -- 2233
				if "table" == _type_1 or "userdata" == _type_1 then -- 2233
					path = _obj_0.path -- 2233
				end -- 2233
			end -- 2233
			if path ~= nil then -- 2233
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2234
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2235
				if not (workspace or builtin) then -- 2236
					return { -- 2236
						success = false -- 2236
					} -- 2236
				end -- 2236
				if not (Content:exist(path) and Content:isdir(path)) then -- 2237
					return { -- 2237
						success = false -- 2237
					} -- 2237
				end -- 2237
				local globs = { -- 2238
					"**", -- 2238
					"!**/.DS_Store", -- 2238
					"!**/.godot/**" -- 2238
				} -- 2238
				if workspace then -- 2239
					globs = { -- 2241
						"**", -- 2241
						"!**/.DS_Store", -- 2241
						"!**/.upload/**", -- 2242
						"!**/.download/**", -- 2242
						"!**/.www/**", -- 2243
						"!**/.build/**", -- 2243
						"!**/.git/**", -- 2244
						"!**/.cache/**", -- 2244
						"!**/.godot/**", -- 2245
						"!**/node_modules/**" -- 2246
					} -- 2240
				end -- 2239
				local files -- 2248
				do -- 2248
					local _accum_0 = { } -- 2248
					local _len_0 = 1 -- 2248
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2248
					for _index_0 = 1, #_list_0 do -- 2248
						local file = _list_0[_index_0] -- 2248
						_accum_0[_len_0] = Path(path, file) -- 2248
						_len_0 = _len_0 + 1 -- 2248
					end -- 2248
					files = _accum_0 -- 2248
				end -- 2248
				return { -- 2249
					success = true, -- 2249
					files = files -- 2249
				} -- 2249
			end -- 2233
		end -- 2233
	end -- 2233
	return { -- 2232
		success = false -- 2232
	} -- 2232
end) -- 2232
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2290
	local _tab_0 = { -- 2290
		{ -- 2291
			key = Path(Content.assetPath), -- 2291
			dir = true, -- 2292
			builtin = true, -- 2293
			title = zh and "内置资源" or "Built-in", -- 2294
			children = builtinChildren -- 2295
		} -- 2290
	} -- 2297
	local _obj_0 = workspace.children or { } -- 2297
	local _idx_0 = #_tab_0 + 1 -- 2297
	for _index_0 = 1, #_obj_0 do -- 2297
		local _value_0 = _obj_0[_index_0] -- 2297
		_tab_0[_idx_0] = _value_0 -- 2297
		_idx_0 = _idx_0 + 1 -- 2297
	end -- 2297
	return _tab_0 -- 2290
end -- 2290
HttpServer:post("/assets", function() -- 2251
	local Entry = require("Script.Dev.Entry") -- 2252
	local engineDev = Entry.getEngineDev() -- 2253
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2254
	local zh = (App.locale:match("^zh") ~= nil) -- 2255
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2256
	readme.title = zh and "说明文档" or "Readme" -- 2257
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2258
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2259
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2260
	tools.title = zh and "开发工具" or "Tools" -- 2261
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2262
	font.title = zh and "字体" or "Font" -- 2263
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2264
	lib.title = zh and "程序库" or "Lib" -- 2265
	if engineDev then -- 2266
		local _list_0 = lib.children -- 2267
		for _index_0 = 1, #_list_0 do -- 2267
			local child = _list_0[_index_0] -- 2267
			if not (child.title == "Dora") then -- 2268
				goto _continue_0 -- 2268
			end -- 2268
			local title = zh and "zh-Hans" or "en" -- 2269
			do -- 2270
				local _accum_0 = { } -- 2270
				local _len_0 = 1 -- 2270
				local _list_1 = child.children -- 2270
				for _index_1 = 1, #_list_1 do -- 2270
					local c = _list_1[_index_1] -- 2270
					if c.title ~= title then -- 2270
						_accum_0[_len_0] = c -- 2270
						_len_0 = _len_0 + 1 -- 2270
					end -- 2270
				end -- 2270
				child.children = _accum_0 -- 2270
			end -- 2270
			break -- 2271
			::_continue_0:: -- 2268
		end -- 2267
	else -- 2273
		local _accum_0 = { } -- 2273
		local _len_0 = 1 -- 2273
		local _list_0 = lib.children -- 2273
		for _index_0 = 1, #_list_0 do -- 2273
			local child = _list_0[_index_0] -- 2273
			if child.title ~= "Dora" then -- 2273
				_accum_0[_len_0] = child -- 2273
				_len_0 = _len_0 + 1 -- 2273
			end -- 2273
		end -- 2273
		lib.children = _accum_0 -- 2273
	end -- 2266
	local builtinChildren = { -- 2274
		readme, -- 2274
		apiDoc, -- 2274
		tools, -- 2274
		font, -- 2274
		lib -- 2274
	} -- 2274
	if engineDev then -- 2275
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2276
		do -- 2277
			local _obj_0 = dev.children -- 2277
			_obj_0[#_obj_0 + 1] = { -- 2278
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2278
				dir = false, -- 2279
				builtin = true, -- 2280
				title = "init.yue" -- 2281
			} -- 2277
		end -- 2277
		builtinChildren[#builtinChildren + 1] = dev -- 2283
	end -- 2275
	return { -- 2285
		key = Content.writablePath, -- 2285
		dir = true, -- 2286
		root = true, -- 2287
		title = "Assets", -- 2288
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2289
	} -- 2284
end) -- 2251
HttpServer:post("/entry/list", function(req) -- 2301
	local Entry = require("Script.Dev.Entry") -- 2302
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2303
	res.success = true -- 2304
	return res -- 2305
end) -- 2301
HttpServer:post("/run/status", function() -- 2307
	local Entry = require("Script.Dev.Entry") -- 2308
	return Entry.getCurrentEntryStatus() -- 2309
end) -- 2307
HttpServer:postSchedule("/run", function(req) -- 2311
	do -- 2312
		local _type_0 = type(req) -- 2312
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2312
		if _tab_0 then -- 2312
			local file -- 2312
			do -- 2312
				local _obj_0 = req.body -- 2312
				local _type_1 = type(_obj_0) -- 2312
				if "table" == _type_1 or "userdata" == _type_1 then -- 2312
					file = _obj_0.file -- 2312
				end -- 2312
			end -- 2312
			local asProj -- 2312
			do -- 2312
				local _obj_0 = req.body -- 2312
				local _type_1 = type(_obj_0) -- 2312
				if "table" == _type_1 or "userdata" == _type_1 then -- 2312
					asProj = _obj_0.asProj -- 2312
				end -- 2312
			end -- 2312
			if file ~= nil and asProj ~= nil then -- 2312
				if not Content:isAbsolutePath(file) then -- 2313
					local devFile = Path(Content.writablePath, file) -- 2314
					if Content:exist(devFile) then -- 2315
						file = devFile -- 2315
					end -- 2315
				end -- 2313
				local Entry = require("Script.Dev.Entry") -- 2316
				local workDir -- 2317
				if asProj then -- 2318
					local projectRoot = req.body.projectRoot -- 2319
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2320
						workDir = projectRoot -- 2321
					else -- 2323
						workDir = getProjectDirFromFile(file) -- 2323
					end -- 2320
					if workDir then -- 2324
						Entry.allClear() -- 2325
						local target = Path(workDir, "init") -- 2326
						local runId = Entry.getCurrentEntryStatus().runId + 1 -- 2327
						local success, err = Entry.enterEntryAsync({ -- 2328
							entryName = "Project", -- 2328
							fileName = target, -- 2328
							workDir = workDir, -- 2328
							projectRoot = workDir, -- 2328
							runKind = "project" -- 2328
						}) -- 2328
						if success and not err and req.body.waitForFrame == true then -- 2329
							local RunTransition = require("Script.Dev.RunTransition") -- 2330
							success, err = RunTransition.waitForFrameAsync(Entry, runId, Content:exist(Path(workDir, "project.godot"))) -- 2331
						end -- 2329
						target = Path:getName(Path:getPath(target)) -- 2332
						return { -- 2333
							success = success, -- 2333
							target = target, -- 2333
							err = err -- 2333
						} -- 2333
					end -- 2324
				else -- 2335
					workDir = getProjectDirFromFile(file) -- 2335
					if not workDir and Path:getExt(file) == "wasm" then -- 2336
						local parent = Path:getPath(file) -- 2337
						if Content:exist(Path(parent, "wa.mod")) then -- 2338
							workDir = parent -- 2339
						end -- 2338
					end -- 2336
				end -- 2318
				Entry.allClear() -- 2340
				file = Path:replaceExt(file, "") -- 2341
				local entry = { -- 2343
					entryName = Path:getName(file), -- 2343
					fileName = file, -- 2344
					runKind = "file" -- 2345
				} -- 2342
				if workDir then -- 2346
					entry.workDir = workDir -- 2347
					entry.projectRoot = workDir -- 2348
				end -- 2346
				local runId = Entry.getCurrentEntryStatus().runId + 1 -- 2349
				local success, err = Entry.enterEntryAsync(entry) -- 2350
				if success and not err and req.body.waitForFrame == true then -- 2351
					local RunTransition = require("Script.Dev.RunTransition") -- 2352
					success, err = RunTransition.waitForFrameAsync(Entry, runId, workDir and Content:exist(Path(workDir, "project.godot"))) -- 2353
				end -- 2351
				return { -- 2354
					success = success, -- 2354
					err = err -- 2354
				} -- 2354
			end -- 2312
		end -- 2312
	end -- 2312
	return { -- 2311
		success = false -- 2311
	} -- 2311
end) -- 2311
local _anon_func_7 = function(result) -- 2396
	if result.success then -- 2396
		return nil -- 2396
	else -- 2396
		return "PREVIEW_FAILED" -- 2396
	end -- 2396
end -- 2396
HttpServer:postSchedule("/agent/preview", function(req) -- 2356
	local releaseAgent = AgentHost.acquire() -- 2357
	local _ <close> = setmetatable({ }, { -- 2358
		__close = function() -- 2358
			return releaseAgent() -- 2358
		end -- 2358
	}) -- 2358
	do -- 2359
		local _type_0 = type(req) -- 2359
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2359
		if _tab_0 then -- 2359
			local projectRoot -- 2359
			do -- 2359
				local _obj_0 = req.body -- 2359
				local _type_1 = type(_obj_0) -- 2359
				if "table" == _type_1 or "userdata" == _type_1 then -- 2359
					projectRoot = _obj_0.projectRoot -- 2359
				end -- 2359
			end -- 2359
			if projectRoot ~= nil then -- 2359
				if not getProjectSourceRoot(projectRoot) then -- 2360
					return { -- 2360
						success = false, -- 2360
						code = "INVALID_PROJECT", -- 2360
						message = "projectRoot must be an existing absolute directory" -- 2360
					} -- 2360
				end -- 2360
				local entryFile = req.body.entry or "init.lua" -- 2361
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2362
					return { -- 2362
						success = false, -- 2362
						code = "INVALID_ENTRY", -- 2362
						message = "entry must be a non-empty project-relative path" -- 2362
					} -- 2362
				end -- 2362
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2363
					0.5 -- 2363
				} -- 2363
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2364
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2365
					return { -- 2365
						success = false, -- 2365
						code = "INVALID_QUEUE_TIMEOUT", -- 2365
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2365
					} -- 2365
				end -- 2365
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2366
				local AgentOperation = require("Agent.Tool.Operation") -- 2367
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2368
				local requestId = AgentOperation.createOperationId() -- 2369
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2370
				if not enqueued.success then -- 2371
					return { -- 2371
						success = false, -- 2371
						code = "ENTRY_QUEUE_REJECTED", -- 2371
						message = enqueued.message -- 2371
					} -- 2371
				end -- 2371
				local queuedAt = App.runningTime -- 2372
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2373
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2374
						local state = agentEntryRunQueue:get(requestId) -- 2375
						agentEntryRunQueue:cancel(requestId) -- 2376
						return { -- 2378
							success = false, -- 2378
							code = "ENTRY_QUEUE_TIMEOUT", -- 2379
							message = "timed out waiting for the Dora entry runtime", -- 2380
							requestId = requestId, -- 2381
							queuePosition = state.position -- 2382
						} -- 2377
					end -- 2374
					sleep() -- 2383
				end -- 2373
				local queueWaitSeconds = App.runningTime - queuedAt -- 2384
				local _ <close> = setmetatable({ }, { -- 2385
					__close = function() -- 2385
						return agentEntryRunQueue:release(requestId) -- 2385
					end -- 2385
				}) -- 2385
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2386
				local Entry = require("Script.Dev.Entry") -- 2387
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2389
					workDir = projectRoot, -- 2389
					operationId = requestId, -- 2390
					print = function() end -- 2391
				}, Entry) -- 2388
				local result = preview({ -- 2393
					entry = entryFile, -- 2393
					captureAtSeconds = captureAtSeconds -- 2393
				}) -- 2393
				return { -- 2395
					success = result.success, -- 2395
					code = _anon_func_7(result), -- 2396
					message = result.message, -- 2397
					requestId = requestId, -- 2398
					queueWaitSeconds = queueWaitSeconds, -- 2399
					interruptedUserRun = result.interruptedUserRun, -- 2400
					files = result.files, -- 2401
					frames = result.frames -- 2402
				} -- 2394
			end -- 2359
		end -- 2359
	end -- 2359
	return { -- 2356
		success = false, -- 2356
		message = "invalid call" -- 2356
	} -- 2356
end) -- 2356
HttpServer:postSchedule("/agent/command", function(req) -- 2404
	local releaseAgent = AgentHost.acquire() -- 2405
	local _ <close> = setmetatable({ }, { -- 2406
		__close = function() -- 2406
			return releaseAgent() -- 2406
		end -- 2406
	}) -- 2406
	do -- 2407
		local _type_0 = type(req) -- 2407
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2407
		if _tab_0 then -- 2407
			local body = req.body -- 2407
			if body ~= nil then -- 2407
				local projectRoot = body.projectRoot -- 2408
				if not getProjectSourceRoot(projectRoot) then -- 2409
					return { -- 2409
						success = false, -- 2409
						code = "INVALID_PROJECT", -- 2409
						message = "projectRoot must be an existing absolute directory" -- 2409
					} -- 2409
				end -- 2409
				local AgentValidation = require("Agent.Tool.Validation") -- 2410
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2411
				if not validated.success then -- 2412
					return { -- 2412
						success = false, -- 2412
						code = "INVALID_COMMAND", -- 2412
						message = validated.message -- 2412
					} -- 2412
				end -- 2412
				local input = validated.value -- 2413
				local AgentCommand = require("Agent.Tool.Command") -- 2414
				local result = nil -- 2415
				local failure = nil -- 2416
				local promise = AgentCommand.executeCommand({ -- 2418
					workDir = projectRoot, -- 2418
					mode = input.mode, -- 2419
					code = input.code, -- 2420
					command = input.command, -- 2421
					cwd = input.cwd, -- 2422
					timeoutSeconds = input.timeoutSeconds -- 2423
				}) -- 2417
				promise:addCallbacks((function(_, value) -- 2424
					result = value -- 2424
				end), (function(_, err) -- 2424
					failure = tostring(err) -- 2424
				end)) -- 2424
				wait(function() -- 2425
					return result ~= nil or failure ~= nil -- 2425
				end) -- 2425
				if failure then -- 2426
					return { -- 2426
						success = false, -- 2426
						code = "COMMAND_BRIDGE_FAILED", -- 2426
						message = failure -- 2426
					} -- 2426
				end -- 2426
				if not result.success then -- 2427
					result.code = "COMMAND_FAILED" -- 2428
				end -- 2427
				return result -- 2429
			end -- 2407
		end -- 2407
	end -- 2407
	return { -- 2404
		success = false, -- 2404
		code = "INVALID_COMMAND", -- 2404
		message = "invalid call" -- 2404
	} -- 2404
end) -- 2404
HttpServer:postSchedule("/stop", function() -- 2431
	local Entry = require("Script.Dev.Entry") -- 2432
	return { -- 2433
		success = Entry.stop() -- 2433
	} -- 2433
end) -- 2431
local minifyAsync -- 2435
minifyAsync = function(sourcePath, minifyPath) -- 2435
	if not Content:exist(sourcePath) then -- 2436
		return -- 2436
	end -- 2436
	local Entry = require("Script.Dev.Entry") -- 2437
	local errors = { } -- 2438
	local files = Entry.getAllFiles(sourcePath, { -- 2439
		"lua" -- 2439
	}, true) -- 2439
	do -- 2440
		local _accum_0 = { } -- 2440
		local _len_0 = 1 -- 2440
		for _index_0 = 1, #files do -- 2440
			local file = files[_index_0] -- 2440
			if file:sub(1, 1) ~= '.' then -- 2440
				_accum_0[_len_0] = file -- 2440
				_len_0 = _len_0 + 1 -- 2440
			end -- 2440
		end -- 2440
		files = _accum_0 -- 2440
	end -- 2440
	local paths -- 2441
	do -- 2441
		local _tbl_0 = { } -- 2441
		for _index_0 = 1, #files do -- 2441
			local file = files[_index_0] -- 2441
			_tbl_0[Path:getPath(file)] = true -- 2441
		end -- 2441
		paths = _tbl_0 -- 2441
	end -- 2441
	for path in pairs(paths) do -- 2442
		Content:mkdir(Path(minifyPath, path)) -- 2442
	end -- 2442
	local _ <close> = setmetatable({ }, { -- 2443
		__close = function() -- 2443
			package.loaded["luaminify.FormatMini"] = nil -- 2444
			package.loaded["luaminify.ParseLua"] = nil -- 2445
			package.loaded["luaminify.Scope"] = nil -- 2446
			package.loaded["luaminify.Util"] = nil -- 2447
		end -- 2443
	}) -- 2443
	local FormatMini -- 2448
	do -- 2448
		local _obj_0 = require("luaminify") -- 2448
		FormatMini = _obj_0.FormatMini -- 2448
	end -- 2448
	local fileCount = #files -- 2449
	local count = 0 -- 2450
	for _index_0 = 1, #files do -- 2451
		local file = files[_index_0] -- 2451
		thread(function() -- 2452
			local _ <close> = setmetatable({ }, { -- 2453
				__close = function() -- 2453
					count = count + 1 -- 2453
				end -- 2453
			}) -- 2453
			local input = Path(sourcePath, file) -- 2454
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2455
			if Content:exist(input) then -- 2456
				local sourceCodes = Content:loadAsync(input) -- 2457
				local res, err = FormatMini(sourceCodes) -- 2458
				if res then -- 2459
					Content:saveAsync(output, res) -- 2460
					return print("Minify " .. tostring(file)) -- 2461
				else -- 2463
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2463
				end -- 2459
			else -- 2465
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2465
			end -- 2456
		end) -- 2452
		sleep() -- 2466
	end -- 2451
	wait(function() -- 2467
		return count == fileCount -- 2467
	end) -- 2467
	if #errors > 0 then -- 2468
		print(table.concat(errors, '\n')) -- 2469
	end -- 2468
	print("Obfuscation done.") -- 2470
	return files -- 2471
end -- 2435
local zipping = false -- 2473
HttpServer:postSchedule("/zip", function(req) -- 2475
	do -- 2476
		local _type_0 = type(req) -- 2476
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2476
		if _tab_0 then -- 2476
			local path -- 2476
			do -- 2476
				local _obj_0 = req.body -- 2476
				local _type_1 = type(_obj_0) -- 2476
				if "table" == _type_1 or "userdata" == _type_1 then -- 2476
					path = _obj_0.path -- 2476
				end -- 2476
			end -- 2476
			local zipFile -- 2476
			do -- 2476
				local _obj_0 = req.body -- 2476
				local _type_1 = type(_obj_0) -- 2476
				if "table" == _type_1 or "userdata" == _type_1 then -- 2476
					zipFile = _obj_0.zipFile -- 2476
				end -- 2476
			end -- 2476
			local obfuscated -- 2476
			do -- 2476
				local _obj_0 = req.body -- 2476
				local _type_1 = type(_obj_0) -- 2476
				if "table" == _type_1 or "userdata" == _type_1 then -- 2476
					obfuscated = _obj_0.obfuscated -- 2476
				end -- 2476
			end -- 2476
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2476
				if zipping then -- 2477
					goto failed -- 2477
				end -- 2477
				zipping = true -- 2478
				local _ <close> = setmetatable({ }, { -- 2479
					__close = function() -- 2479
						zipping = false -- 2479
					end -- 2479
				}) -- 2479
				if not Content:exist(path) then -- 2480
					goto failed -- 2480
				end -- 2480
				Content:mkdir(Path:getPath(zipFile)) -- 2481
				if obfuscated then -- 2482
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2483
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2484
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2485
					Content:remove(scriptPath) -- 2486
					Content:remove(obfuscatedPath) -- 2487
					Content:remove(tempPath) -- 2488
					Content:mkdir(scriptPath) -- 2489
					Content:mkdir(obfuscatedPath) -- 2490
					Content:mkdir(tempPath) -- 2491
					if not Content:copyAsync(path, tempPath) then -- 2492
						goto failed -- 2492
					end -- 2492
					local Entry = require("Script.Dev.Entry") -- 2493
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2494
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2495
						"tl", -- 2495
						"yue", -- 2495
						"lua", -- 2495
						"ts", -- 2495
						"tsx", -- 2495
						"vs", -- 2495
						"bl", -- 2495
						"xml", -- 2495
						"wa", -- 2495
						"mod" -- 2495
					}, true) -- 2495
					for _index_0 = 1, #scriptFiles do -- 2496
						local file = scriptFiles[_index_0] -- 2496
						Content:remove(Path(tempPath, file)) -- 2497
					end -- 2496
					for _index_0 = 1, #luaFiles do -- 2498
						local file = luaFiles[_index_0] -- 2498
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2499
					end -- 2498
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2500
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2501
					end) then -- 2500
						goto failed -- 2500
					end -- 2500
					return { -- 2502
						success = true -- 2502
					} -- 2502
				else -- 2504
					return { -- 2504
						success = Content:zipAsync(path, zipFile, function(file) -- 2504
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2505
						end) -- 2504
					} -- 2504
				end -- 2482
			end -- 2476
		end -- 2476
	end -- 2476
	::failed:: -- 2506
	return { -- 2475
		success = false -- 2475
	} -- 2475
end) -- 2475
HttpServer:postSchedule("/unzip", function(req) -- 2508
	do -- 2509
		local _type_0 = type(req) -- 2509
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2509
		if _tab_0 then -- 2509
			local zipFile -- 2509
			do -- 2509
				local _obj_0 = req.body -- 2509
				local _type_1 = type(_obj_0) -- 2509
				if "table" == _type_1 or "userdata" == _type_1 then -- 2509
					zipFile = _obj_0.zipFile -- 2509
				end -- 2509
			end -- 2509
			local path -- 2509
			do -- 2509
				local _obj_0 = req.body -- 2509
				local _type_1 = type(_obj_0) -- 2509
				if "table" == _type_1 or "userdata" == _type_1 then -- 2509
					path = _obj_0.path -- 2509
				end -- 2509
			end -- 2509
			if zipFile ~= nil and path ~= nil then -- 2509
				return { -- 2510
					success = Content:unzipAsync(zipFile, path, function(file) -- 2510
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2511
					end) -- 2510
				} -- 2510
			end -- 2509
		end -- 2509
	end -- 2509
	return { -- 2508
		success = false -- 2508
	} -- 2508
end) -- 2508
HttpServer:post("/editing-info", function(req) -- 2513
	local Entry = require("Script.Dev.Entry") -- 2514
	local config = Entry.getConfig() -- 2515
	local _type_0 = type(req) -- 2516
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2516
	local _match_0 = false -- 2516
	if _tab_0 then -- 2516
		local editingInfo -- 2516
		do -- 2516
			local _obj_0 = req.body -- 2516
			local _type_1 = type(_obj_0) -- 2516
			if "table" == _type_1 or "userdata" == _type_1 then -- 2516
				editingInfo = _obj_0.editingInfo -- 2516
			end -- 2516
		end -- 2516
		if editingInfo ~= nil then -- 2516
			_match_0 = true -- 2516
			config.editingInfo = editingInfo -- 2517
			return { -- 2518
				success = true -- 2518
			} -- 2518
		end -- 2516
	end -- 2516
	if not _match_0 then -- 2516
		if not (config.editingInfo ~= nil) then -- 2520
			local folder -- 2521
			if App.locale:match('^zh') then -- 2521
				folder = 'zh-Hans' -- 2521
			else -- 2521
				folder = 'en' -- 2521
			end -- 2521
			config.editingInfo = json.encode({ -- 2523
				index = 0, -- 2523
				files = { -- 2525
					{ -- 2526
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2526
						title = "welcome.md" -- 2527
					} -- 2525
				} -- 2524
			}) -- 2522
		end -- 2520
		return { -- 2531
			success = true, -- 2531
			editingInfo = config.editingInfo -- 2531
		} -- 2531
	end -- 2516
end) -- 2513
HttpServer:post("/command", function(req) -- 2533
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
			local log -- 2534
			do -- 2534
				local _obj_0 = req.body -- 2534
				local _type_1 = type(_obj_0) -- 2534
				if "table" == _type_1 or "userdata" == _type_1 then -- 2534
					log = _obj_0.log -- 2534
				end -- 2534
			end -- 2534
			if code ~= nil and log ~= nil then -- 2534
				emit("AppCommand", code, log) -- 2535
				return { -- 2536
					success = true -- 2536
				} -- 2536
			end -- 2534
		end -- 2534
	end -- 2534
	return { -- 2533
		success = false -- 2533
	} -- 2533
end) -- 2533
HttpServer:post("/log/save", function() -- 2538
	local folder = ".download" -- 2539
	local fullLogFile = "dora_full_logs.txt" -- 2540
	local fullFolder = Path(Content.writablePath, folder) -- 2541
	Content:mkdir(fullFolder) -- 2542
	local logPath = Path(fullFolder, fullLogFile) -- 2543
	if App:saveLog(logPath) then -- 2544
		return { -- 2545
			success = true, -- 2545
			path = Path(folder, fullLogFile) -- 2545
		} -- 2545
	end -- 2544
	return { -- 2538
		success = false -- 2538
	} -- 2538
end) -- 2538
local tailLines -- 2547
tailLines = function(text, count) -- 2547
	local lines = { } -- 2548
	text = text:gsub("\r\n", "\n") -- 2549
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2550
		lines[#lines + 1] = line -- 2551
	end -- 2550
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2552
		table.remove(lines) -- 2553
	end -- 2552
	local start = math.max(1, #lines - count + 1) -- 2554
	local out = { } -- 2555
	for i = start, #lines do -- 2556
		out[#out + 1] = lines[i] -- 2557
	end -- 2556
	return table.concat(out, "\n") -- 2558
end -- 2547
HttpServer:post("/log", function(req) -- 2560
	local count = 100 -- 2561
	if req and req.body and req.body.count ~= nil then -- 2562
		count = req.body.count -- 2563
	end -- 2562
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2564
		return { -- 2565
			success = false, -- 2565
			message = "count must be a positive integer" -- 2565
		} -- 2565
	end -- 2564
	local folder = ".download" -- 2566
	local fullLogFile = "dora_full_logs.txt" -- 2567
	local fullFolder = Path(Content.writablePath, folder) -- 2568
	Content:mkdir(fullFolder) -- 2569
	local logPath = Path(fullFolder, fullLogFile) -- 2570
	if App:saveLog(logPath) then -- 2571
		local text = Content:load(logPath) -- 2572
		if text then -- 2573
			return { -- 2574
				success = true, -- 2574
				log = tailLines(text, count) -- 2574
			} -- 2574
		else -- 2576
			return { -- 2576
				success = false, -- 2576
				message = "failed to read log" -- 2576
			} -- 2576
		end -- 2573
	else -- 2578
		return { -- 2578
			success = false, -- 2578
			message = "failed to save log" -- 2578
		} -- 2578
	end -- 2571
	return { -- 2560
		success = false -- 2560
	} -- 2560
end) -- 2560
HttpServer:post("/yarn/check", function(req) -- 2580
	local yarncompile = require("yarncompile") -- 2581
	do -- 2582
		local _type_0 = type(req) -- 2582
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2582
		if _tab_0 then -- 2582
			local code -- 2582
			do -- 2582
				local _obj_0 = req.body -- 2582
				local _type_1 = type(_obj_0) -- 2582
				if "table" == _type_1 or "userdata" == _type_1 then -- 2582
					code = _obj_0.code -- 2582
				end -- 2582
			end -- 2582
			if code ~= nil then -- 2582
				local jsonObject = json.decode(code) -- 2583
				if jsonObject then -- 2583
					local errors = { } -- 2584
					local _list_0 = jsonObject.nodes -- 2585
					for _index_0 = 1, #_list_0 do -- 2585
						local node = _list_0[_index_0] -- 2585
						local title, body = node.title, node.body -- 2586
						local luaCode, err = yarncompile(body) -- 2587
						if not luaCode then -- 2587
							errors[#errors + 1] = title .. ":" .. err -- 2588
						end -- 2587
					end -- 2585
					return { -- 2589
						success = true, -- 2589
						syntaxError = table.concat(errors, "\n\n") -- 2589
					} -- 2589
				end -- 2583
			end -- 2582
		end -- 2582
	end -- 2582
	return { -- 2580
		success = false -- 2580
	} -- 2580
end) -- 2580
HttpServer:post("/yarn/check-file", function(req) -- 2591
	local yarncompile = require("yarncompile") -- 2592
	do -- 2593
		local _type_0 = type(req) -- 2593
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2593
		if _tab_0 then -- 2593
			local code -- 2593
			do -- 2593
				local _obj_0 = req.body -- 2593
				local _type_1 = type(_obj_0) -- 2593
				if "table" == _type_1 or "userdata" == _type_1 then -- 2593
					code = _obj_0.code -- 2593
				end -- 2593
			end -- 2593
			if code ~= nil then -- 2593
				local res, _, err = yarncompile(code, true) -- 2594
				if not res then -- 2594
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2595
					return { -- 2596
						success = false, -- 2596
						message = message, -- 2596
						line = line, -- 2596
						column = column, -- 2596
						node = node -- 2596
					} -- 2596
				end -- 2594
			end -- 2593
		end -- 2593
	end -- 2593
	return { -- 2591
		success = true -- 2591
	} -- 2591
end) -- 2591
getWaProjectDirFromFile = function(file) -- 2598
	local current -- 2599
	if Content:isdir(file) then -- 2599
		current = file -- 2599
	else -- 2599
		current = Path:getPath(file) -- 2599
	end -- 2599
	if current == "" then -- 2600
		return nil -- 2600
	end -- 2600
	repeat -- 2601
		local modPath = Path(current, "wa.mod") -- 2602
		if Content:exist(modPath) then -- 2603
			return current, modPath -- 2604
		end -- 2603
		local parent = Path:getPath(current) -- 2605
		if parent == "" or parent == current then -- 2606
			break -- 2606
		end -- 2606
		current = parent -- 2607
	until false -- 2601
	return nil -- 2609
end -- 2598
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2611
	do -- 2612
		local _type_0 = type(req) -- 2612
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2612
		if _tab_0 then -- 2612
			local path -- 2612
			do -- 2612
				local _obj_0 = req.body -- 2612
				local _type_1 = type(_obj_0) -- 2612
				if "table" == _type_1 or "userdata" == _type_1 then -- 2612
					path = _obj_0.path -- 2612
				end -- 2612
			end -- 2612
			if path ~= nil then -- 2612
				local projDir = getWaProjectDirFromFile(path) -- 2613
				if projDir then -- 2613
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2614
					if not Content:exist(sourceDoraPath) then -- 2615
						return { -- 2616
							success = false, -- 2616
							message = "missing dora template" -- 2616
						} -- 2616
					end -- 2615
					local targetVendorPath = Path(projDir, "vendor") -- 2617
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2618
					if not Content:exist(targetVendorPath) then -- 2619
						if not Content:mkdir(targetVendorPath) then -- 2620
							return { -- 2621
								success = false, -- 2621
								message = "failed to create vendor folder" -- 2621
							} -- 2621
						end -- 2620
					elseif not Content:isdir(targetVendorPath) then -- 2622
						return { -- 2623
							success = false, -- 2623
							message = "vendor path is not a folder" -- 2623
						} -- 2623
					end -- 2619
					if Content:exist(targetDoraPath) then -- 2624
						if not Content:remove(targetDoraPath) then -- 2625
							return { -- 2626
								success = false, -- 2626
								message = "failed to remove old dora" -- 2626
							} -- 2626
						end -- 2625
					end -- 2624
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2627
						return { -- 2628
							success = false, -- 2628
							message = "failed to copy dora" -- 2628
						} -- 2628
					end -- 2627
					return { -- 2629
						success = true -- 2629
					} -- 2629
				else -- 2631
					return { -- 2631
						success = false, -- 2631
						message = 'Wa file needs a project' -- 2631
					} -- 2631
				end -- 2613
			end -- 2612
		end -- 2612
	end -- 2612
	return { -- 2611
		success = false, -- 2611
		message = "invalid call" -- 2611
	} -- 2611
end) -- 2611
HttpServer:postSchedule("/wa/build", function(req) -- 2633
	do -- 2634
		local _type_0 = type(req) -- 2634
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2634
		if _tab_0 then -- 2634
			local path -- 2634
			do -- 2634
				local _obj_0 = req.body -- 2634
				local _type_1 = type(_obj_0) -- 2634
				if "table" == _type_1 or "userdata" == _type_1 then -- 2634
					path = _obj_0.path -- 2634
				end -- 2634
			end -- 2634
			if path ~= nil then -- 2634
				local projDir = getWaProjectDirFromFile(path) -- 2635
				if projDir then -- 2635
					local message = Wasm:buildWaAsync(projDir) -- 2636
					if message == "" then -- 2637
						return { -- 2638
							success = true -- 2638
						} -- 2638
					else -- 2640
						return { -- 2640
							success = false, -- 2640
							message = message -- 2640
						} -- 2640
					end -- 2637
				else -- 2642
					return { -- 2642
						success = false, -- 2642
						message = 'Wa file needs a project' -- 2642
					} -- 2642
				end -- 2635
			end -- 2634
		end -- 2634
	end -- 2634
	return { -- 2643
		success = false, -- 2643
		message = 'failed to build' -- 2643
	} -- 2643
end) -- 2633
HttpServer:postSchedule("/wa/format", function(req) -- 2645
	do -- 2646
		local _type_0 = type(req) -- 2646
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2646
		if _tab_0 then -- 2646
			local file -- 2646
			do -- 2646
				local _obj_0 = req.body -- 2646
				local _type_1 = type(_obj_0) -- 2646
				if "table" == _type_1 or "userdata" == _type_1 then -- 2646
					file = _obj_0.file -- 2646
				end -- 2646
			end -- 2646
			if file ~= nil then -- 2646
				local code = Wasm:formatWaAsync(file) -- 2647
				if code == "" then -- 2648
					return { -- 2649
						success = false -- 2649
					} -- 2649
				else -- 2651
					return { -- 2651
						success = true, -- 2651
						code = code -- 2651
					} -- 2651
				end -- 2648
			end -- 2646
		end -- 2646
	end -- 2646
	return { -- 2652
		success = false -- 2652
	} -- 2652
end) -- 2645
HttpServer:postSchedule("/wa/create", function(req) -- 2654
	do -- 2655
		local _type_0 = type(req) -- 2655
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2655
		if _tab_0 then -- 2655
			local path -- 2655
			do -- 2655
				local _obj_0 = req.body -- 2655
				local _type_1 = type(_obj_0) -- 2655
				if "table" == _type_1 or "userdata" == _type_1 then -- 2655
					path = _obj_0.path -- 2655
				end -- 2655
			end -- 2655
			if path ~= nil then -- 2655
				if not Content:exist(Path:getPath(path)) then -- 2656
					return { -- 2657
						success = false, -- 2657
						message = "target path not existed" -- 2657
					} -- 2657
				end -- 2656
				if Content:exist(path) then -- 2658
					return { -- 2659
						success = false, -- 2659
						message = "target project folder existed" -- 2659
					} -- 2659
				end -- 2658
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2660
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2661
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2662
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2663
					return { -- 2666
						success = false, -- 2666
						message = "missing template project" -- 2666
					} -- 2666
				end -- 2663
				if not Content:mkdir(path) then -- 2667
					return { -- 2668
						success = false, -- 2668
						message = "failed to create project folder" -- 2668
					} -- 2668
				end -- 2667
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2669
					Content:remove(path) -- 2670
					return { -- 2671
						success = false, -- 2671
						message = "failed to copy template" -- 2671
					} -- 2671
				end -- 2669
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2672
					Content:remove(path) -- 2673
					return { -- 2674
						success = false, -- 2674
						message = "failed to copy template" -- 2674
					} -- 2674
				end -- 2672
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2675
					Content:remove(path) -- 2676
					return { -- 2677
						success = false, -- 2677
						message = "failed to copy template" -- 2677
					} -- 2677
				end -- 2675
				return { -- 2678
					success = true -- 2678
				} -- 2678
			end -- 2655
		end -- 2655
	end -- 2655
	return { -- 2654
		success = false, -- 2654
		message = "invalid call" -- 2654
	} -- 2654
end) -- 2654
local tsBuildGlobs = { -- 2681
	"**/*.ts", -- 2681
	"**/*.tsx", -- 2682
	"!**/.*/**", -- 2683
	"!**/node_modules/**" -- 2684
} -- 2680
local tsSnapshotGlobs = { -- 2687
	"**/*.ts", -- 2687
	"**/*.tsx", -- 2688
	"**/*.lua", -- 2689
	"!**/.*/**", -- 2690
	"!**/node_modules/**" -- 2691
} -- 2686
local _anon_func_8 = function(file) -- 2718
	local _val_0 = Path:getExt(file) -- 2718
	return "ts" == _val_0 or "tsx" == _val_0 -- 2718
end -- 2718
local collectTSVirtualFiles -- 2693
collectTSVirtualFiles = function(sourceRoot) -- 2693
	local files = { } -- 2694
	local seen = { } -- 2695
	local addFile -- 2696
	addFile = function(file, moduleName, virtualFile) -- 2696
		if moduleName == nil then -- 2696
			moduleName = nil -- 2696
		end -- 2696
		if virtualFile == nil then -- 2696
			virtualFile = nil -- 2696
		end -- 2696
		local targetFile = virtualFile or file -- 2697
		do -- 2698
			local entry = seen[targetFile] -- 2698
			if entry then -- 2698
				if moduleName and moduleName ~= "" then -- 2699
					entry.moduleName = moduleName -- 2699
				end -- 2699
				return -- 2700
			end -- 2698
		end -- 2698
		local content = Content:load(file) -- 2701
		if content then -- 2701
			local entry = { -- 2702
				file = targetFile, -- 2702
				content = content -- 2702
			} -- 2702
			if moduleName and moduleName ~= "" then -- 2703
				entry.moduleName = moduleName -- 2703
			end -- 2703
			seen[targetFile] = entry -- 2704
			files[#files + 1] = entry -- 2705
		end -- 2701
	end -- 2696
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2706
		local builtinScriptRoot = Path(Content.assetPath, "Script") -- 2707
		local builtinPrefix -- 2709
		if relativeToRoot(sourceRoot, builtinScriptRoot) == "" then -- 2709
			builtinPrefix = "Script/" -- 2710
		elseif relativeToRoot(sourceRoot, Content.assetPath) == "" then -- 2711
			builtinPrefix = "" -- 2712
		else -- 2714
			builtinPrefix = nil -- 2714
		end -- 2709
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2715
		for _index_0 = 1, #_list_0 do -- 2715
			local subFile = _list_0[_index_0] -- 2715
			local file = Path(sourceRoot, subFile) -- 2716
			local moduleName = nil -- 2717
			if builtinPrefix and _anon_func_8(file) and Path:getExt(Path:getName(file)) ~= "d" then -- 2718
				local relative = relativeToRoot(file, builtinScriptRoot) -- 2719
				if relative then -- 2719
					moduleName = (builtinPrefix .. Path:replaceExt(relative, "")):gsub("\\", "/") -- 2720
				end -- 2719
			end -- 2718
			addFile(file, moduleName) -- 2721
		end -- 2715
		local libraryRoots = { -- 2723
			Path(sourceRoot, "Script", "Lib"), -- 2723
			Path(sourceRoot, "Lib"), -- 2724
			Path(Content.assetPath, "Script", "Lib") -- 2725
		} -- 2722
		for _index_0 = 1, #libraryRoots do -- 2726
			local libraryRoot = libraryRoots[_index_0] -- 2726
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2727
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2728
				for _index_1 = 1, #_list_1 do -- 2728
					local subFile = _list_1[_index_1] -- 2728
					local file = Path(libraryRoot, subFile) -- 2729
					local virtualFile = Path(sourceRoot, subFile) -- 2730
					addFile(file, nil, virtualFile) -- 2731
				end -- 2728
			end -- 2727
		end -- 2726
	end -- 2706
	local locale -- 2732
	if App.locale:match('^zh') then -- 2732
		locale = 'zh-Hans' -- 2732
	else -- 2732
		locale = 'en' -- 2732
	end -- 2732
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2733
	local _list_0 = Content:getFiles(declarationRoot) -- 2734
	for _index_0 = 1, #_list_0 do -- 2734
		local file = _list_0[_index_0] -- 2734
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2735
			local fullPath = Path(declarationRoot, file) -- 2736
			local moduleName = Path:getName(Path:getName(file)) -- 2737
			addFile(fullPath, moduleName) -- 2738
		end -- 2735
	end -- 2734
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2739
	local lualibBundleTarget -- 2740
	if sourceRoot then -- 2740
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2740
	else -- 2740
		lualibBundleTarget = "lualib_bundle.lua" -- 2740
	end -- 2740
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2741
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2742
	local _list_1 = Content:getFiles(lualibRoot) -- 2743
	for _index_0 = 1, #_list_1 do -- 2743
		local file = _list_1[_index_0] -- 2743
		if Path:getExt(file) == "lua" then -- 2744
			local virtualFile -- 2745
			if sourceRoot then -- 2745
				virtualFile = Path(sourceRoot, "lualib", file) -- 2745
			else -- 2745
				virtualFile = Path("lualib", file) -- 2745
			end -- 2745
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2746
		end -- 2744
	end -- 2743
	return files -- 2747
end -- 2693
local supportsCompilerWebView -- 2749
supportsCompilerWebView = function() -- 2749
	local _val_0 = App.platform -- 2749
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2749
end -- 2749
local webIDECompilerReady = false -- 2750
local webIDEConnectionGeneration = 0 -- 2751
local tsProbeId = 0 -- 2752
local probeWebIDECompiler -- 2754
probeWebIDECompiler = function(isCancelled) -- 2754
	if HttpServer.wsConnectionCount == 0 then -- 2755
		return false -- 2755
	end -- 2755
	tsProbeId = tsProbeId + 1 -- 2756
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2757
	local generation = webIDEConnectionGeneration -- 2758
	local done, ready = false, false -- 2759
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2760
	local listener = Node() -- 2761
	listener:gslot("AppWS", function(event) -- 2762
		if event.type == "Receive" then -- 2763
			local res = json.decode(event.msg) -- 2764
			if res then -- 2764
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2765
					responses = responses + 1 -- 2766
					ready = ready or res.success == true -- 2767
					done = ready or responses >= expectedResponses -- 2768
				end -- 2765
			end -- 2764
		end -- 2763
	end) -- 2762
	emit("AppWS", "Send", json.encode({ -- 2769
		name = "TranspileTSProbe", -- 2769
		id = requestId -- 2769
	})) -- 2769
	local deadline = App.runningTime + 5 -- 2770
	wait(function() -- 2771
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2771
	end) -- 2771
	listener:removeFromParent() -- 2772
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2773
	if generation == webIDEConnectionGeneration then -- 2774
		webIDECompilerReady = ready -- 2774
	end -- 2774
	return ready -- 2775
end -- 2754
local compilerConnectionListener = Node() -- 2777
compilerConnectionListener:addTo(Director.systemUI) -- 2779
local _anon_func_9 = function(event) -- 2781
	local _val_0 = event.type -- 2781
	return "Open" == _val_0 or "Close" == _val_0 -- 2781
end -- 2781
compilerConnectionListener:gslot("AppWS", function(event) -- 2780
	if _anon_func_9(event) then -- 2781
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2782
		webIDECompilerReady = false -- 2783
		if HttpServer.wsConnectionCount > 0 then -- 2784
			return thread(function() -- 2785
				return probeWebIDECompiler() -- 2785
			end) -- 2785
		end -- 2784
	end -- 2781
end) -- 2780
local _anon_func_10 = function(res) -- 2810
	if res.success then -- 2810
		return "tool" -- 2810
	else -- 2810
		return res.failureKind -- 2810
	end -- 2810
end -- 2810
local transpileTSFileWithWebIDE -- 2787
do -- 2787
	local tsBuildRequestId = 0 -- 2788
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2789
		if not probeWebIDECompiler(isCancelled) then -- 2790
			if isCancelled and isCancelled() then -- 2791
				return { -- 2792
					success = false, -- 2792
					file = file, -- 2792
					message = "build canceled", -- 2792
					interrupted = true -- 2792
				} -- 2792
			end -- 2791
			return { -- 2793
				success = false, -- 2793
				file = file, -- 2793
				message = "TypeScript transpiler is not ready", -- 2793
				failureKind = "tool" -- 2793
			} -- 2793
		end -- 2790
		tsBuildRequestId = tsBuildRequestId + 1 -- 2794
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2795
		local done = false -- 2796
		local result = nil -- 2797
		local listener = Node() -- 2798
		listener:gslot("AppWS", function(event) -- 2799
			if event.type == "Receive" then -- 2800
				local res = json.decode(event.msg) -- 2801
				if res then -- 2801
					if res.name == "TranspileTS" and res.id == requestId then -- 2802
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2803
							local luaFile = Path:replaceExt(file, "lua") -- 2804
							if Content:save(luaFile, res.luaCode) then -- 2805
								result = { -- 2806
									success = true, -- 2806
									file = file -- 2806
								} -- 2806
							else -- 2808
								result = { -- 2808
									success = false, -- 2808
									file = file, -- 2808
									message = "failed to save " .. tostring(luaFile) -- 2808
								} -- 2808
							end -- 2805
						else -- 2810
							result = { -- 2810
								success = false, -- 2810
								file = file, -- 2810
								message = res.message or "Compiler returned no Lua output", -- 2810
								failureKind = _anon_func_10(res) -- 2810
							} -- 2810
						end -- 2803
						done = true -- 2811
					end -- 2802
				end -- 2801
			end -- 2800
		end) -- 2799
		emit("AppWS", "Send", json.encode({ -- 2812
			name = "TranspileTS", -- 2812
			id = requestId, -- 2812
			file = file, -- 2812
			content = content, -- 2812
			projectRoot = sourceRoot, -- 2812
			files = files -- 2812
		})) -- 2812
		local deadline = App.runningTime + 30 -- 2813
		wait(function() -- 2814
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2814
		end) -- 2814
		listener:removeFromParent() -- 2815
		if not done then -- 2816
			webIDECompilerReady = false -- 2817
			if isCancelled and isCancelled() then -- 2818
				return { -- 2819
					success = false, -- 2819
					file = file, -- 2819
					message = "build canceled", -- 2819
					interrupted = true -- 2819
				} -- 2819
			end -- 2818
			return { -- 2820
				success = false, -- 2820
				file = file, -- 2820
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2820
				failureKind = "tool" -- 2820
			} -- 2820
		end -- 2816
		return result -- 2821
	end -- 2789
end -- 2787
local compilerReadyTimeout <const> = 15 -- 2823
local compilerBuildTimeout <const> = 30 -- 2824
local compilerIdleCloseSeconds <const> = 8 -- 2825
local compilerReady = false -- 2826
local compilerRequested = false -- 2827
local compilerFailure = nil -- 2828
local compilerUsers = 0 -- 2829
local compilerCloseGeneration = 0 -- 2830
local compilerJobId = 0 -- 2831
local compilerJobs = { } -- 2832
local compilerResults = { } -- 2833
local compilerInFlight = { } -- 2834
HttpServer:post("/compiler/ready", function() -- 2836
	if not compilerRequested then -- 2837
		return { -- 2837
			success = false -- 2837
		} -- 2837
	end -- 2837
	compilerReady = true -- 2838
	return { -- 2839
		success = true -- 2839
	} -- 2839
end) -- 2836
HttpServer:post("/compiler/failure", function(req) -- 2841
	if not compilerRequested then -- 2842
		return { -- 2842
			success = false -- 2842
		} -- 2842
	end -- 2842
	do -- 2843
		local _type_0 = type(req) -- 2843
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2843
		if _tab_0 then -- 2843
			local message -- 2843
			do -- 2843
				local _obj_0 = req.body -- 2843
				local _type_1 = type(_obj_0) -- 2843
				if "table" == _type_1 or "userdata" == _type_1 then -- 2843
					message = _obj_0.message -- 2843
				end -- 2843
			end -- 2843
			if message ~= nil then -- 2843
				if type(message) == "string" then -- 2844
					compilerFailure = message -- 2845
					compilerReady = false -- 2846
					return { -- 2847
						success = true -- 2847
					} -- 2847
				end -- 2844
			end -- 2843
		end -- 2843
	end -- 2843
	return { -- 2841
		success = false -- 2841
	} -- 2841
end) -- 2841
HttpServer:postSchedule("/compiler/poll", function() -- 2849
	if not compilerRequested then -- 2850
		return { -- 2850
			success = false -- 2850
		} -- 2850
	end -- 2850
	compilerReady = true -- 2851
	local deadline = App.runningTime + 5 -- 2852
	wait(function() -- 2853
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2853
	end) -- 2853
	if not (compilerRequested and not compilerFailure) then -- 2854
		return { -- 2854
			success = false -- 2854
		} -- 2854
	end -- 2854
	local job = table.remove(compilerJobs, 1) -- 2855
	if job then -- 2856
		compilerInFlight[job.id] = true -- 2857
	end -- 2856
	return { -- 2858
		success = true, -- 2858
		job = job -- 2858
	} -- 2858
end) -- 2849
HttpServer:post("/compiler/result", function(req) -- 2860
	do -- 2861
		local _type_0 = type(req) -- 2861
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2861
		if _tab_0 then -- 2861
			local body = req.body -- 2861
			if body ~= nil then -- 2861
				local id = body.id -- 2862
				if not (id and compilerInFlight[id]) then -- 2863
					return { -- 2863
						success = false, -- 2863
						message = "invalid compiler job" -- 2863
					} -- 2863
				end -- 2863
				compilerInFlight[id] = nil -- 2864
				compilerResults[id] = body -- 2865
				return { -- 2866
					success = true -- 2866
				} -- 2866
			end -- 2861
		end -- 2861
	end -- 2861
	return { -- 2860
		success = false -- 2860
	} -- 2860
end) -- 2860
local acquireCompiler -- 2868
acquireCompiler = function() -- 2868
	compilerUsers = compilerUsers + 1 -- 2869
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2870
	if not compilerRequested then -- 2871
		compilerRequested = true -- 2872
		compilerReady = false -- 2873
		compilerFailure = nil -- 2874
		return emit("AppWebView", "/compiler.html", true) -- 2875
	end -- 2871
end -- 2868
local releaseCompiler -- 2877
releaseCompiler = function() -- 2877
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2878
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2879
	if not (compilerUsers == 0) then -- 2880
		return -- 2880
	end -- 2880
	local closeGeneration = compilerCloseGeneration -- 2881
	return thread(function() -- 2882
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2883
		wait(function() -- 2884
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2885
		end) -- 2884
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2890
			compilerRequested = false -- 2891
			compilerReady = false -- 2892
			return emit("AppWebView", "/compiler.html", false) -- 2893
		end -- 2890
	end) -- 2882
end -- 2877
local removeCompilerJob -- 2895
removeCompilerJob = function(id) -- 2895
	for index = #compilerJobs, 1, -1 do -- 2896
		if compilerJobs[index].id == id then -- 2897
			table.remove(compilerJobs, index) -- 2898
		end -- 2897
	end -- 2896
	compilerInFlight[id] = nil -- 2899
	compilerResults[id] = nil -- 2900
end -- 2895
local transpileTSFileWithCompiler -- 2902
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2902
	acquireCompiler() -- 2903
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2904
	wait(function() -- 2905
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2905
	end) -- 2905
	if not compilerReady then -- 2906
		releaseCompiler() -- 2907
		if isCancelled and isCancelled() then -- 2908
			return { -- 2909
				success = false, -- 2909
				file = file, -- 2909
				message = "build canceled", -- 2909
				interrupted = true -- 2909
			} -- 2909
		end -- 2908
		return { -- 2910
			success = false, -- 2910
			file = file, -- 2910
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2910
			failureKind = "tool" -- 2910
		} -- 2910
	end -- 2906
	compilerJobId = compilerJobId + 1 -- 2911
	local jobId = compilerJobId -- 2912
	compilerJobs[#compilerJobs + 1] = { -- 2914
		id = jobId, -- 2914
		file = file, -- 2915
		content = content, -- 2916
		projectRoot = sourceRoot, -- 2917
		files = files -- 2918
	} -- 2913
	local deadline = App.runningTime + compilerBuildTimeout -- 2919
	wait(function() -- 2920
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2920
	end) -- 2920
	local response = compilerResults[jobId] -- 2921
	removeCompilerJob(jobId) -- 2922
	releaseCompiler() -- 2923
	if not response then -- 2924
		if isCancelled and isCancelled() then -- 2925
			return { -- 2926
				success = false, -- 2926
				file = file, -- 2926
				message = "build canceled", -- 2926
				interrupted = true -- 2926
			} -- 2926
		end -- 2925
		return { -- 2927
			success = false, -- 2927
			file = file, -- 2927
			message = compilerFailure or "TypeScript transpile timed out", -- 2927
			failureKind = "tool" -- 2927
		} -- 2927
	end -- 2924
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2928
		local luaFile = Path:replaceExt(file, "lua") -- 2929
		if Content:save(luaFile, response.luaCode) then -- 2930
			return { -- 2931
				success = true, -- 2931
				file = file -- 2931
			} -- 2931
		end -- 2930
		return { -- 2932
			success = false, -- 2932
			file = file, -- 2932
			message = "failed to save " .. tostring(luaFile) -- 2932
		} -- 2932
	end -- 2928
	return { -- 2933
		success = false, -- 2933
		file = file, -- 2933
		message = response.message or "TypeScript transpile failed" -- 2933
	} -- 2933
end -- 2902
local compilerFailureListener = Node() -- 2935
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2936
	compilerFailure = message -- 2937
	compilerReady = false -- 2938
end) -- 2936
local transpileTSFile -- 2940
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2940
	if supportsCompilerWebView() and not files then -- 2941
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2942
	end -- 2941
	if HttpServer.wsConnectionCount > 0 then -- 2943
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2944
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2945
			return result -- 2945
		end -- 2945
		webIDECompilerReady = false -- 2946
	end -- 2943
	if supportsCompilerWebView() then -- 2947
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2948
	end -- 2947
	return { -- 2949
		success = false, -- 2949
		file = file, -- 2949
		message = "Web IDE compiler not connected", -- 2949
		failureKind = "tool" -- 2949
	} -- 2949
end -- 2940
local _anon_func_11 = function(path) -- 2964
	local _val_0 = Path:getExt(path) -- 2964
	return "ts" == _val_0 or "tsx" == _val_0 -- 2964
end -- 2964
HttpServer:postSchedule("/ts/build", function(req) -- 2951
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2952
	local buildSucceeded = false -- 2953
	local _ <close> = setmetatable({ }, { -- 2954
		__close = function() -- 2954
			return finishUpdate(buildSucceeded) -- 2954
		end -- 2954
	}) -- 2954
	do -- 2955
		local _type_0 = type(req) -- 2955
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2955
		if _tab_0 then -- 2955
			local path -- 2955
			do -- 2955
				local _obj_0 = req.body -- 2955
				local _type_1 = type(_obj_0) -- 2955
				if "table" == _type_1 or "userdata" == _type_1 then -- 2955
					path = _obj_0.path -- 2955
				end -- 2955
			end -- 2955
			if path ~= nil then -- 2955
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2956
					return { -- 2957
						success = false, -- 2957
						message = "Web IDE not connected" -- 2957
					} -- 2957
				end -- 2956
				local projectRoot = req.body.projectRoot -- 2958
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2959
				if not Content:exist(path) then -- 2960
					return { -- 2961
						success = false, -- 2961
						message = "path not existed" -- 2961
					} -- 2961
				end -- 2960
				local messages = { } -- 2962
				if not Content:isdir(path) then -- 2963
					if not (_anon_func_11(path)) then -- 2964
						return { -- 2965
							success = false, -- 2965
							message = "expecting a TypeScript file" -- 2965
						} -- 2965
					end -- 2964
					local content = Content:load(path) -- 2966
					if not content then -- 2967
						return { -- 2968
							success = false, -- 2968
							message = "failed to read file" -- 2968
						} -- 2968
					end -- 2967
					emit("AppWS", "Send", json.encode({ -- 2969
						name = "UpdateFile", -- 2969
						file = path, -- 2969
						exists = true, -- 2969
						content = content, -- 2969
						projectRoot = sourceRoot -- 2969
					})) -- 2969
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2970
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2971
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2972
					end -- 2970
				else -- 2974
					local fileData = { } -- 2974
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2975
					for _index_0 = 1, #_list_0 do -- 2975
						local subFile = _list_0[_index_0] -- 2975
						local file = Path(path, subFile) -- 2976
						local content = Content:load(file) -- 2977
						if content then -- 2977
							fileData[file] = content -- 2978
							emit("AppWS", "Send", json.encode({ -- 2979
								name = "UpdateFile", -- 2979
								file = file, -- 2979
								exists = true, -- 2979
								content = content, -- 2979
								projectRoot = sourceRoot -- 2979
							})) -- 2979
						else -- 2981
							messages[#messages + 1] = { -- 2981
								success = false, -- 2981
								file = file, -- 2981
								message = "failed to read file" -- 2981
							} -- 2981
						end -- 2977
					end -- 2975
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2982
					for file, content in pairs(fileData) do -- 2983
						if "d" == Path:getExt(Path:getName(file)) then -- 2984
							goto _continue_0 -- 2984
						end -- 2984
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2985
						::_continue_0:: -- 2984
					end -- 2983
				end -- 2963
				local success = true -- 2986
				for _index_0 = 1, #messages do -- 2987
					local item = messages[_index_0] -- 2987
					if not item.success then -- 2988
						success = false -- 2988
					end -- 2988
				end -- 2987
				local message = nil -- 2989
				if not success then -- 2990
					message = "TypeScript compilation failed" -- 2990
				end -- 2990
				buildSucceeded = success -- 2991
				return { -- 2992
					success = success, -- 2992
					messages = messages, -- 2992
					message = message -- 2992
				} -- 2992
			end -- 2955
		end -- 2955
	end -- 2955
	return { -- 2951
		success = false -- 2951
	} -- 2951
end) -- 2951
HttpServer:post("/download", function(req) -- 2994
	do -- 2995
		local _type_0 = type(req) -- 2995
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2995
		if _tab_0 then -- 2995
			local url -- 2995
			do -- 2995
				local _obj_0 = req.body -- 2995
				local _type_1 = type(_obj_0) -- 2995
				if "table" == _type_1 or "userdata" == _type_1 then -- 2995
					url = _obj_0.url -- 2995
				end -- 2995
			end -- 2995
			local target -- 2995
			do -- 2995
				local _obj_0 = req.body -- 2995
				local _type_1 = type(_obj_0) -- 2995
				if "table" == _type_1 or "userdata" == _type_1 then -- 2995
					target = _obj_0.target -- 2995
				end -- 2995
			end -- 2995
			if url ~= nil and target ~= nil then -- 2995
				local Entry = require("Script.Dev.Entry") -- 2996
				Entry.downloadFile(url, target) -- 2997
				return { -- 2998
					success = true -- 2998
				} -- 2998
			end -- 2995
		end -- 2995
	end -- 2995
	return { -- 2994
		success = false -- 2994
	} -- 2994
end) -- 2994
local isDesktopPlatform -- 3000
isDesktopPlatform = function() -- 3000
	local _val_0 = App.platform -- 3001
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 3001
end -- 3000
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 3003
local nativeIDEListener = Node() -- 3004
nativeIDEListener:addTo(Director.systemUI) -- 3005
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 3006
	nativeIDEState, nativeIDEMessage = state, message -- 3007
end) -- 3006
local _anon_func_12 = function() -- 3010
	local _val_0 = App.platform -- 3010
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 3010
end -- 3010
HttpServer:post("/ide", function(req) -- 3009
	if not (_anon_func_12()) then -- 3010
		return { -- 3010
			success = false, -- 3010
			message = "Native IDE is unavailable" -- 3010
		} -- 3010
	end -- 3010
	if not App.webIDEEnabled then -- 3011
		return { -- 3011
			success = false, -- 3011
			message = "Embedded Web IDE is disabled" -- 3011
		} -- 3011
	end -- 3011
	do -- 3012
		local _type_0 = type(req) -- 3012
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3012
		if _tab_0 then -- 3012
			local action -- 3012
			do -- 3012
				local _obj_0 = req.body -- 3012
				local _type_1 = type(_obj_0) -- 3012
				if "table" == _type_1 or "userdata" == _type_1 then -- 3012
					action = _obj_0.action -- 3012
				end -- 3012
			end -- 3012
			if action ~= nil then -- 3012
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 3013
					emit("AppWebView", "/ide/" .. action, true) -- 3014
					return { -- 3015
						success = true -- 3015
					} -- 3015
				end -- 3013
			end -- 3012
		end -- 3012
	end -- 3012
	return { -- 3009
		success = false, -- 3009
		message = "invalid IDE action" -- 3009
	} -- 3009
end) -- 3009
local _anon_func_13 = function() -- 3031
	local _val_0 = App.platform -- 3031
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 3031
end -- 3031
local getServerStatus -- 3017
getServerStatus = function() -- 3017
	local Entry = require("Script.Dev.Entry") -- 3018
	local running = Entry.getCurrentEntryStatus() -- 3019
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 3020
	local wsConnectionCount = HttpServer.wsConnectionCount -- 3021
	return { -- 3023
		success = true, -- 3023
		platform = App.platform, -- 3024
		locale = App.locale, -- 3025
		version = App.version, -- 3026
		url = "http://localhost:8866", -- 3027
		wsConnectionCount = wsConnectionCount, -- 3028
		webIDEConnected = wsConnectionCount > 0, -- 3029
		nativeIDE = { -- 3031
			supported = _anon_func_13(), -- 3031
			enabled = App.webIDEEnabled, -- 3032
			state = nativeIDEState, -- 3033
			message = nativeIDEMessage -- 3034
		}, -- 3030
		typescriptCompiler = { -- 3036
			webIDEReady = webIDECompilerReady, -- 3036
			webIDEGeneration = webIDEConnectionGeneration, -- 3037
			embeddedSupported = supportsCompilerWebView(), -- 3038
			embeddedRequested = compilerRequested, -- 3039
			embeddedReady = compilerReady, -- 3040
			users = compilerUsers, -- 3041
			queuedJobs = #compilerJobs, -- 3042
			failure = compilerFailure -- 3043
		}, -- 3035
		assetPath = Content.assetPath, -- 3044
		writablePath = Content.writablePath, -- 3045
		appPath = Content.appPath, -- 3046
		waTemplateReady = waTemplateReady, -- 3047
		running = running -- 3048
	} -- 3022
end -- 3017
HttpServer:post("/status", function() -- 3051
	return getServerStatus() -- 3052
end) -- 3051
HttpServer:postSchedule("/doctor/fix", function(req) -- 3054
	do -- 3055
		local _type_0 = type(req) -- 3055
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3055
		if _tab_0 then -- 3055
			local openWebIDE -- 3055
			do -- 3055
				local _obj_0 = req.body -- 3055
				local _type_1 = type(_obj_0) -- 3055
				if "table" == _type_1 or "userdata" == _type_1 then -- 3055
					openWebIDE = _obj_0.openWebIDE -- 3055
				end -- 3055
			end -- 3055
			if openWebIDE ~= nil then -- 3055
				if not openWebIDE then -- 3056
					return { -- 3057
						success = false, -- 3057
						message = "nothing to fix" -- 3057
					} -- 3057
				end -- 3056
				local status = getServerStatus() -- 3058
				if status.webIDEConnected then -- 3059
					return { -- 3060
						success = true, -- 3060
						fixed = false, -- 3060
						message = "Web IDE already connected.", -- 3060
						status = status -- 3060
					} -- 3060
				end -- 3059
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 3061
				if waitSeconds > 0 then -- 3062
					local deadline = os.time() + waitSeconds -- 3063
					repeat -- 3064
						sleep(0.2) -- 3065
						status = getServerStatus() -- 3066
						if status.webIDEConnected then -- 3067
							return { -- 3068
								success = true, -- 3068
								fixed = false, -- 3068
								reconnected = true, -- 3068
								message = "Web IDE reconnected.", -- 3068
								status = status -- 3068
							} -- 3068
						end -- 3067
					until os.time() >= deadline -- 3064
				end -- 3062
				if not isDesktopPlatform() then -- 3070
					return { -- 3071
						success = false, -- 3071
						message = "opening Web IDE is only supported on desktop platforms", -- 3071
						status = status -- 3071
					} -- 3071
				end -- 3070
				local url = "http://localhost:8866" -- 3072
				App:openURL(url) -- 3073
				status.openedURL = url -- 3074
				return { -- 3075
					success = true, -- 3075
					fixed = true, -- 3075
					message = "Opened Web IDE in the local browser.", -- 3075
					url = url, -- 3075
					status = status -- 3075
				} -- 3075
			end -- 3055
		end -- 3055
	end -- 3055
	return { -- 3054
		success = false, -- 3054
		message = "invalid call" -- 3054
	} -- 3054
end) -- 3054
local status = { } -- 3077
_module_0 = status -- 3078
status.transpileTSFile = transpileTSFile -- 3080
HttpServer:postSchedule("/godot/project", function(req) -- 3083
	do -- 3084
		local _type_0 = type(req) -- 3084
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3084
		if _tab_0 then -- 3084
			local path -- 3084
			do -- 3084
				local _obj_0 = req.body -- 3084
				local _type_1 = type(_obj_0) -- 3084
				if "table" == _type_1 or "userdata" == _type_1 then -- 3084
					path = _obj_0.path -- 3084
				end -- 3084
			end -- 3084
			if path ~= nil then -- 3084
				if not (type(path) == "string" and Content:isAbsolutePath(path)) then -- 3085
					return invalidArguments -- 3085
				end -- 3085
				local releaseAgent = AgentHost.acquire() -- 3086
				local _ <close> = setmetatable({ }, { -- 3087
					__close = function() -- 3087
						return releaseAgent() -- 3087
					end -- 3087
				}) -- 3087
				local GodotBuild = require("Agent.Tool.GodotBuild") -- 3088
				local project = GodotBuild.findGodotProject(Content.writablePath, path) or GodotBuild.findGodotProject(Content.assetPath, path) -- 3089
				if not project then -- 3090
					return { -- 3090
						success = true, -- 3090
						found = false -- 3090
					} -- 3090
				end -- 3090
				if not (req.body.build == true) then -- 3091
					return { -- 3091
						success = true, -- 3091
						found = true, -- 3091
						projectRoot = project -- 3091
					} -- 3091
				end -- 3091
				local result -- 3092
				local promise = GodotBuild.buildGodotProject(project) -- 3093
				local onFulfilled -- 3094
				onFulfilled = function(_, value) -- 3094
					result = value -- 3095
				end -- 3094
				local onRejected -- 3096
				onRejected = function(_, err) -- 3096
					result = { -- 3097
						success = false, -- 3097
						message = tostring(err) -- 3097
					} -- 3097
				end -- 3096
				promise["then"](promise, onFulfilled, onRejected) -- 3098
				wait(function() -- 3099
					return result ~= nil -- 3099
				end) -- 3099
				result.found = true -- 3100
				result.projectRoot = project -- 3101
				return result -- 3102
			end -- 3084
		end -- 3084
	end -- 3084
	return invalidArguments -- 3083
end) -- 3083
status.buildAsync = function(path) -- 3104
	if not Content:exist(path) then -- 3105
		return { -- 3106
			success = false, -- 3106
			file = path, -- 3106
			message = "file not existed" -- 3106
		} -- 3106
	end -- 3105
	do -- 3107
		local _exp_0 = Path:getExt(path) -- 3107
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 3107
			if '' == Path:getExt(Path:getName(path)) then -- 3108
				local content = Content:loadAsync(path) -- 3109
				if content then -- 3109
					local resultCodes, err = compileFileAsync(path, content) -- 3110
					if resultCodes then -- 3110
						return { -- 3111
							success = true, -- 3111
							file = path -- 3111
						} -- 3111
					else -- 3113
						return { -- 3113
							success = false, -- 3113
							file = path, -- 3113
							message = err -- 3113
						} -- 3113
					end -- 3110
				end -- 3109
			end -- 3108
		elseif "lua" == _exp_0 then -- 3114
			local content = Content:loadAsync(path) -- 3115
			if content then -- 3115
				do -- 3116
					local isTIC80 = CheckTIC80Code(content) -- 3116
					if isTIC80 then -- 3116
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 3117
					end -- 3116
				end -- 3116
				local success, info -- 3118
				do -- 3118
					local _obj_0 = luaCheck(path, content) -- 3118
					success, info = _obj_0.success, _obj_0.info -- 3118
				end -- 3118
				if success then -- 3119
					return { -- 3120
						success = true, -- 3120
						file = path -- 3120
					} -- 3120
				elseif info and #info > 0 then -- 3121
					local messages = { } -- 3122
					for _index_0 = 1, #info do -- 3123
						local _des_0 = info[_index_0] -- 3123
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3123
						local lineText = "" -- 3124
						if line then -- 3125
							local currentLine = 1 -- 3126
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3127
								if currentLine == line then -- 3128
									lineText = text -- 3129
									break -- 3130
								end -- 3128
								currentLine = currentLine + 1 -- 3131
							end -- 3127
						end -- 3125
						if line then -- 3132
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3133
						else -- 3135
							messages[#messages + 1] = message -- 3135
						end -- 3132
					end -- 3123
					return { -- 3136
						success = false, -- 3136
						file = path, -- 3136
						message = table.concat(messages, "\n") -- 3136
					} -- 3136
				else -- 3138
					return { -- 3138
						success = false, -- 3138
						file = path, -- 3138
						message = "lua check failed" -- 3138
					} -- 3138
				end -- 3119
			end -- 3115
		elseif "yarn" == _exp_0 then -- 3139
			local content = Content:loadAsync(path) -- 3140
			if content then -- 3140
				local res, _, err = yarncompile(content, true) -- 3141
				if res then -- 3141
					return { -- 3142
						success = true, -- 3142
						file = path -- 3142
					} -- 3142
				else -- 3144
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3144
					local lineText = "" -- 3145
					if line then -- 3146
						local currentLine = 1 -- 3147
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3148
							if currentLine == line then -- 3149
								lineText = text -- 3150
								break -- 3151
							end -- 3149
							currentLine = currentLine + 1 -- 3152
						end -- 3148
					end -- 3146
					if node ~= "" then -- 3153
						node = "node: " .. tostring(node) .. ", " -- 3154
					else -- 3155
						node = "" -- 3155
					end -- 3153
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3156
					return { -- 3157
						success = false, -- 3157
						file = path, -- 3157
						message = message -- 3157
					} -- 3157
				end -- 3141
			end -- 3140
		end -- 3107
	end -- 3107
	return { -- 3158
		success = false, -- 3158
		file = path, -- 3158
		message = "invalid file to build" -- 3158
	} -- 3158
end -- 3104
HttpServer:postSchedule("/git/commit-files", function(req) -- 3160
	do -- 3161
		local _type_0 = type(req) -- 3161
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3161
		if _tab_0 then -- 3161
			local body = req.body -- 3161
			if body ~= nil then -- 3161
				local repoPath, commit = body.repoPath, body.commit -- 3162
				if gitInvalidRepoPath(repoPath) then -- 3163
					return { -- 3163
						success = false, -- 3163
						message = "invalid repoPath" -- 3163
					} -- 3163
				end -- 3163
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3164
					return { -- 3164
						success = false, -- 3164
						message = "invalid commit" -- 3164
					} -- 3164
				end -- 3164
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3165
				if not res.success then -- 3166
					return res -- 3166
				end -- 3166
				return { -- 3167
					success = true, -- 3167
					status = res.status, -- 3167
					data = res.status and res.status.data -- 3167
				} -- 3167
			end -- 3161
		end -- 3161
	end -- 3161
	return invalidArguments -- 3160
end) -- 3160
thread(function() -- 3169
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3170
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3171
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3172
		local storedAsset -- 3175
		storedAsset = function(file) -- 3175
			if Content:exist(file) then -- 3176
				return Content:load(file) -- 3177
			elseif Content:exist(file .. ".gz") then -- 3178
				return Content:load(file .. ".gz") -- 3179
			else -- 3180
				return "" -- 3180
			end -- 3176
		end -- 3175
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3181
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3182
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3183
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3184
		local readyContent = table.concat({ -- 3186
			App.version, -- 3186
			storedAsset(doraWeb), -- 3187
			storedAsset(heavyAssets), -- 3188
			storedAsset(runtimeIndex), -- 3189
			storedAsset(compilerIndex), -- 3190
			storedAsset(manifest) -- 3191
		}, "\n") -- 3185
		local needReload -- 3193
		if Content:exist(doraReady) then -- 3193
			needReload = readyContent ~= Content:load(doraReady) -- 3194
		else -- 3195
			needReload = true -- 3195
		end -- 3193
		if needReload then -- 3196
			Content:remove(Path(Content.appPath, ".www")) -- 3197
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3198
			Content:save(doraReady, readyContent) -- 3202
			print("Dora Dora is ready!") -- 3203
		end -- 3196
	end -- 3172
	if App.platform == "Emscripten" then -- 3204
		status.url = nil -- 3205
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3206
	end -- 3204
	HttpServer:clearStaticCacheControls() -- 3207
	HttpServer:setStaticCacheControl("no-cache") -- 3208
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3209
	if HttpServer:start(8866) then -- 3213
		local localIP = HttpServer.localIP -- 3214
		if localIP == "" then -- 3215
			localIP = "localhost" -- 3215
		end -- 3215
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3216
		return HttpServer:startWS(8868) -- 3217
	else -- 3219
		status.url = nil -- 3219
		return print("8866 Port not available!") -- 3220
	end -- 3213
end) -- 3169
return _module_0 -- 1
