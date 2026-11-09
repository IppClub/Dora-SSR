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
						local success, err = Entry.enterEntryAsync({ -- 2310
							entryName = "Project", -- 2310
							fileName = target, -- 2310
							workDir = workDir, -- 2310
							projectRoot = workDir, -- 2310
							runKind = "project" -- 2310
						}) -- 2310
						target = Path:getName(Path:getPath(target)) -- 2311
						return { -- 2312
							success = success, -- 2312
							target = target, -- 2312
							err = err -- 2312
						} -- 2312
					end -- 2307
				else -- 2314
					workDir = getProjectDirFromFile(file) -- 2314
					if not workDir and Path:getExt(file) == "wasm" then -- 2315
						local parent = Path:getPath(file) -- 2316
						if Content:exist(Path(parent, "wa.mod")) then -- 2317
							workDir = parent -- 2318
						end -- 2317
					end -- 2315
				end -- 2301
				Entry.allClear() -- 2319
				file = Path:replaceExt(file, "") -- 2320
				local entry = { -- 2322
					entryName = Path:getName(file), -- 2322
					fileName = file, -- 2323
					runKind = "file" -- 2324
				} -- 2321
				if workDir then -- 2325
					entry.workDir = workDir -- 2326
					entry.projectRoot = workDir -- 2327
				end -- 2325
				local success, err = Entry.enterEntryAsync(entry) -- 2328
				return { -- 2329
					success = success, -- 2329
					err = err -- 2329
				} -- 2329
			end -- 2295
		end -- 2295
	end -- 2295
	return { -- 2294
		success = false -- 2294
	} -- 2294
end) -- 2294
local _anon_func_7 = function(result) -- 2371
	if result.success then -- 2371
		return nil -- 2371
	else -- 2371
		return "PREVIEW_FAILED" -- 2371
	end -- 2371
end -- 2371
HttpServer:postSchedule("/agent/preview", function(req) -- 2331
	local releaseAgent = AgentHost.acquire() -- 2332
	local _ <close> = setmetatable({ }, { -- 2333
		__close = function() -- 2333
			return releaseAgent() -- 2333
		end -- 2333
	}) -- 2333
	do -- 2334
		local _type_0 = type(req) -- 2334
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2334
		if _tab_0 then -- 2334
			local projectRoot -- 2334
			do -- 2334
				local _obj_0 = req.body -- 2334
				local _type_1 = type(_obj_0) -- 2334
				if "table" == _type_1 or "userdata" == _type_1 then -- 2334
					projectRoot = _obj_0.projectRoot -- 2334
				end -- 2334
			end -- 2334
			if projectRoot ~= nil then -- 2334
				if not getProjectSourceRoot(projectRoot) then -- 2335
					return { -- 2335
						success = false, -- 2335
						code = "INVALID_PROJECT", -- 2335
						message = "projectRoot must be an existing absolute directory" -- 2335
					} -- 2335
				end -- 2335
				local entryFile = req.body.entry or "init.lua" -- 2336
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2337
					return { -- 2337
						success = false, -- 2337
						code = "INVALID_ENTRY", -- 2337
						message = "entry must be a non-empty project-relative path" -- 2337
					} -- 2337
				end -- 2337
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2338
					0.5 -- 2338
				} -- 2338
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2339
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2340
					return { -- 2340
						success = false, -- 2340
						code = "INVALID_QUEUE_TIMEOUT", -- 2340
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2340
					} -- 2340
				end -- 2340
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2341
				local AgentOperation = require("Agent.Tool.Operation") -- 2342
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2343
				local requestId = AgentOperation.createOperationId() -- 2344
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2345
				if not enqueued.success then -- 2346
					return { -- 2346
						success = false, -- 2346
						code = "ENTRY_QUEUE_REJECTED", -- 2346
						message = enqueued.message -- 2346
					} -- 2346
				end -- 2346
				local queuedAt = App.runningTime -- 2347
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2348
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2349
						local state = agentEntryRunQueue:get(requestId) -- 2350
						agentEntryRunQueue:cancel(requestId) -- 2351
						return { -- 2353
							success = false, -- 2353
							code = "ENTRY_QUEUE_TIMEOUT", -- 2354
							message = "timed out waiting for the Dora entry runtime", -- 2355
							requestId = requestId, -- 2356
							queuePosition = state.position -- 2357
						} -- 2352
					end -- 2349
					sleep() -- 2358
				end -- 2348
				local queueWaitSeconds = App.runningTime - queuedAt -- 2359
				local _ <close> = setmetatable({ }, { -- 2360
					__close = function() -- 2360
						return agentEntryRunQueue:release(requestId) -- 2360
					end -- 2360
				}) -- 2360
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2361
				local Entry = require("Script.Dev.Entry") -- 2362
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2364
					workDir = projectRoot, -- 2364
					operationId = requestId, -- 2365
					print = function() end -- 2366
				}, Entry) -- 2363
				local result = preview({ -- 2368
					entry = entryFile, -- 2368
					captureAtSeconds = captureAtSeconds -- 2368
				}) -- 2368
				return { -- 2370
					success = result.success, -- 2370
					code = _anon_func_7(result), -- 2371
					message = result.message, -- 2372
					requestId = requestId, -- 2373
					queueWaitSeconds = queueWaitSeconds, -- 2374
					interruptedUserRun = result.interruptedUserRun, -- 2375
					files = result.files, -- 2376
					frames = result.frames -- 2377
				} -- 2369
			end -- 2334
		end -- 2334
	end -- 2334
	return { -- 2331
		success = false, -- 2331
		message = "invalid call" -- 2331
	} -- 2331
end) -- 2331
HttpServer:postSchedule("/agent/command", function(req) -- 2379
	local releaseAgent = AgentHost.acquire() -- 2380
	local _ <close> = setmetatable({ }, { -- 2381
		__close = function() -- 2381
			return releaseAgent() -- 2381
		end -- 2381
	}) -- 2381
	do -- 2382
		local _type_0 = type(req) -- 2382
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2382
		if _tab_0 then -- 2382
			local body = req.body -- 2382
			if body ~= nil then -- 2382
				local projectRoot = body.projectRoot -- 2383
				if not getProjectSourceRoot(projectRoot) then -- 2384
					return { -- 2384
						success = false, -- 2384
						code = "INVALID_PROJECT", -- 2384
						message = "projectRoot must be an existing absolute directory" -- 2384
					} -- 2384
				end -- 2384
				local AgentValidation = require("Agent.Tool.Validation") -- 2385
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2386
				if not validated.success then -- 2387
					return { -- 2387
						success = false, -- 2387
						code = "INVALID_COMMAND", -- 2387
						message = validated.message -- 2387
					} -- 2387
				end -- 2387
				local input = validated.value -- 2388
				local AgentCommand = require("Agent.Tool.Command") -- 2389
				local result = nil -- 2390
				local failure = nil -- 2391
				local promise = AgentCommand.executeCommand({ -- 2393
					workDir = projectRoot, -- 2393
					mode = input.mode, -- 2394
					code = input.code, -- 2395
					command = input.command, -- 2396
					cwd = input.cwd, -- 2397
					timeoutSeconds = input.timeoutSeconds -- 2398
				}) -- 2392
				promise:addCallbacks((function(_, value) -- 2399
					result = value -- 2399
				end), (function(_, err) -- 2399
					failure = tostring(err) -- 2399
				end)) -- 2399
				wait(function() -- 2400
					return result ~= nil or failure ~= nil -- 2400
				end) -- 2400
				if failure then -- 2401
					return { -- 2401
						success = false, -- 2401
						code = "COMMAND_BRIDGE_FAILED", -- 2401
						message = failure -- 2401
					} -- 2401
				end -- 2401
				if not result.success then -- 2402
					result.code = "COMMAND_FAILED" -- 2403
				end -- 2402
				return result -- 2404
			end -- 2382
		end -- 2382
	end -- 2382
	return { -- 2379
		success = false, -- 2379
		code = "INVALID_COMMAND", -- 2379
		message = "invalid call" -- 2379
	} -- 2379
end) -- 2379
HttpServer:postSchedule("/stop", function() -- 2406
	local Entry = require("Script.Dev.Entry") -- 2407
	return { -- 2408
		success = Entry.stop() -- 2408
	} -- 2408
end) -- 2406
local minifyAsync -- 2410
minifyAsync = function(sourcePath, minifyPath) -- 2410
	if not Content:exist(sourcePath) then -- 2411
		return -- 2411
	end -- 2411
	local Entry = require("Script.Dev.Entry") -- 2412
	local errors = { } -- 2413
	local files = Entry.getAllFiles(sourcePath, { -- 2414
		"lua" -- 2414
	}, true) -- 2414
	do -- 2415
		local _accum_0 = { } -- 2415
		local _len_0 = 1 -- 2415
		for _index_0 = 1, #files do -- 2415
			local file = files[_index_0] -- 2415
			if file:sub(1, 1) ~= '.' then -- 2415
				_accum_0[_len_0] = file -- 2415
				_len_0 = _len_0 + 1 -- 2415
			end -- 2415
		end -- 2415
		files = _accum_0 -- 2415
	end -- 2415
	local paths -- 2416
	do -- 2416
		local _tbl_0 = { } -- 2416
		for _index_0 = 1, #files do -- 2416
			local file = files[_index_0] -- 2416
			_tbl_0[Path:getPath(file)] = true -- 2416
		end -- 2416
		paths = _tbl_0 -- 2416
	end -- 2416
	for path in pairs(paths) do -- 2417
		Content:mkdir(Path(minifyPath, path)) -- 2417
	end -- 2417
	local _ <close> = setmetatable({ }, { -- 2418
		__close = function() -- 2418
			package.loaded["luaminify.FormatMini"] = nil -- 2419
			package.loaded["luaminify.ParseLua"] = nil -- 2420
			package.loaded["luaminify.Scope"] = nil -- 2421
			package.loaded["luaminify.Util"] = nil -- 2422
		end -- 2418
	}) -- 2418
	local FormatMini -- 2423
	do -- 2423
		local _obj_0 = require("luaminify") -- 2423
		FormatMini = _obj_0.FormatMini -- 2423
	end -- 2423
	local fileCount = #files -- 2424
	local count = 0 -- 2425
	for _index_0 = 1, #files do -- 2426
		local file = files[_index_0] -- 2426
		thread(function() -- 2427
			local _ <close> = setmetatable({ }, { -- 2428
				__close = function() -- 2428
					count = count + 1 -- 2428
				end -- 2428
			}) -- 2428
			local input = Path(sourcePath, file) -- 2429
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2430
			if Content:exist(input) then -- 2431
				local sourceCodes = Content:loadAsync(input) -- 2432
				local res, err = FormatMini(sourceCodes) -- 2433
				if res then -- 2434
					Content:saveAsync(output, res) -- 2435
					return print("Minify " .. tostring(file)) -- 2436
				else -- 2438
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2438
				end -- 2434
			else -- 2440
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2440
			end -- 2431
		end) -- 2427
		sleep() -- 2441
	end -- 2426
	wait(function() -- 2442
		return count == fileCount -- 2442
	end) -- 2442
	if #errors > 0 then -- 2443
		print(table.concat(errors, '\n')) -- 2444
	end -- 2443
	print("Obfuscation done.") -- 2445
	return files -- 2446
end -- 2410
local zipping = false -- 2448
HttpServer:postSchedule("/zip", function(req) -- 2450
	do -- 2451
		local _type_0 = type(req) -- 2451
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2451
		if _tab_0 then -- 2451
			local path -- 2451
			do -- 2451
				local _obj_0 = req.body -- 2451
				local _type_1 = type(_obj_0) -- 2451
				if "table" == _type_1 or "userdata" == _type_1 then -- 2451
					path = _obj_0.path -- 2451
				end -- 2451
			end -- 2451
			local zipFile -- 2451
			do -- 2451
				local _obj_0 = req.body -- 2451
				local _type_1 = type(_obj_0) -- 2451
				if "table" == _type_1 or "userdata" == _type_1 then -- 2451
					zipFile = _obj_0.zipFile -- 2451
				end -- 2451
			end -- 2451
			local obfuscated -- 2451
			do -- 2451
				local _obj_0 = req.body -- 2451
				local _type_1 = type(_obj_0) -- 2451
				if "table" == _type_1 or "userdata" == _type_1 then -- 2451
					obfuscated = _obj_0.obfuscated -- 2451
				end -- 2451
			end -- 2451
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2451
				if zipping then -- 2452
					goto failed -- 2452
				end -- 2452
				zipping = true -- 2453
				local _ <close> = setmetatable({ }, { -- 2454
					__close = function() -- 2454
						zipping = false -- 2454
					end -- 2454
				}) -- 2454
				if not Content:exist(path) then -- 2455
					goto failed -- 2455
				end -- 2455
				Content:mkdir(Path:getPath(zipFile)) -- 2456
				if obfuscated then -- 2457
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2458
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2459
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2460
					Content:remove(scriptPath) -- 2461
					Content:remove(obfuscatedPath) -- 2462
					Content:remove(tempPath) -- 2463
					Content:mkdir(scriptPath) -- 2464
					Content:mkdir(obfuscatedPath) -- 2465
					Content:mkdir(tempPath) -- 2466
					if not Content:copyAsync(path, tempPath) then -- 2467
						goto failed -- 2467
					end -- 2467
					local Entry = require("Script.Dev.Entry") -- 2468
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2469
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2470
						"tl", -- 2470
						"yue", -- 2470
						"lua", -- 2470
						"ts", -- 2470
						"tsx", -- 2470
						"vs", -- 2470
						"bl", -- 2470
						"xml", -- 2470
						"wa", -- 2470
						"mod" -- 2470
					}, true) -- 2470
					for _index_0 = 1, #scriptFiles do -- 2471
						local file = scriptFiles[_index_0] -- 2471
						Content:remove(Path(tempPath, file)) -- 2472
					end -- 2471
					for _index_0 = 1, #luaFiles do -- 2473
						local file = luaFiles[_index_0] -- 2473
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2474
					end -- 2473
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2475
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2476
					end) then -- 2475
						goto failed -- 2475
					end -- 2475
					return { -- 2477
						success = true -- 2477
					} -- 2477
				else -- 2479
					return { -- 2479
						success = Content:zipAsync(path, zipFile, function(file) -- 2479
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2480
						end) -- 2479
					} -- 2479
				end -- 2457
			end -- 2451
		end -- 2451
	end -- 2451
	::failed:: -- 2481
	return { -- 2450
		success = false -- 2450
	} -- 2450
end) -- 2450
HttpServer:postSchedule("/unzip", function(req) -- 2483
	do -- 2484
		local _type_0 = type(req) -- 2484
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2484
		if _tab_0 then -- 2484
			local zipFile -- 2484
			do -- 2484
				local _obj_0 = req.body -- 2484
				local _type_1 = type(_obj_0) -- 2484
				if "table" == _type_1 or "userdata" == _type_1 then -- 2484
					zipFile = _obj_0.zipFile -- 2484
				end -- 2484
			end -- 2484
			local path -- 2484
			do -- 2484
				local _obj_0 = req.body -- 2484
				local _type_1 = type(_obj_0) -- 2484
				if "table" == _type_1 or "userdata" == _type_1 then -- 2484
					path = _obj_0.path -- 2484
				end -- 2484
			end -- 2484
			if zipFile ~= nil and path ~= nil then -- 2484
				return { -- 2485
					success = Content:unzipAsync(zipFile, path, function(file) -- 2485
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2486
					end) -- 2485
				} -- 2485
			end -- 2484
		end -- 2484
	end -- 2484
	return { -- 2483
		success = false -- 2483
	} -- 2483
end) -- 2483
HttpServer:post("/editing-info", function(req) -- 2488
	local Entry = require("Script.Dev.Entry") -- 2489
	local config = Entry.getConfig() -- 2490
	local _type_0 = type(req) -- 2491
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2491
	local _match_0 = false -- 2491
	if _tab_0 then -- 2491
		local editingInfo -- 2491
		do -- 2491
			local _obj_0 = req.body -- 2491
			local _type_1 = type(_obj_0) -- 2491
			if "table" == _type_1 or "userdata" == _type_1 then -- 2491
				editingInfo = _obj_0.editingInfo -- 2491
			end -- 2491
		end -- 2491
		if editingInfo ~= nil then -- 2491
			_match_0 = true -- 2491
			config.editingInfo = editingInfo -- 2492
			return { -- 2493
				success = true -- 2493
			} -- 2493
		end -- 2491
	end -- 2491
	if not _match_0 then -- 2491
		if not (config.editingInfo ~= nil) then -- 2495
			local folder -- 2496
			if App.locale:match('^zh') then -- 2496
				folder = 'zh-Hans' -- 2496
			else -- 2496
				folder = 'en' -- 2496
			end -- 2496
			config.editingInfo = json.encode({ -- 2498
				index = 0, -- 2498
				files = { -- 2500
					{ -- 2501
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2501
						title = "welcome.md" -- 2502
					} -- 2500
				} -- 2499
			}) -- 2497
		end -- 2495
		return { -- 2506
			success = true, -- 2506
			editingInfo = config.editingInfo -- 2506
		} -- 2506
	end -- 2491
end) -- 2488
HttpServer:post("/command", function(req) -- 2508
	do -- 2509
		local _type_0 = type(req) -- 2509
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2509
		if _tab_0 then -- 2509
			local code -- 2509
			do -- 2509
				local _obj_0 = req.body -- 2509
				local _type_1 = type(_obj_0) -- 2509
				if "table" == _type_1 or "userdata" == _type_1 then -- 2509
					code = _obj_0.code -- 2509
				end -- 2509
			end -- 2509
			local log -- 2509
			do -- 2509
				local _obj_0 = req.body -- 2509
				local _type_1 = type(_obj_0) -- 2509
				if "table" == _type_1 or "userdata" == _type_1 then -- 2509
					log = _obj_0.log -- 2509
				end -- 2509
			end -- 2509
			if code ~= nil and log ~= nil then -- 2509
				emit("AppCommand", code, log) -- 2510
				return { -- 2511
					success = true -- 2511
				} -- 2511
			end -- 2509
		end -- 2509
	end -- 2509
	return { -- 2508
		success = false -- 2508
	} -- 2508
end) -- 2508
HttpServer:post("/log/save", function() -- 2513
	local folder = ".download" -- 2514
	local fullLogFile = "dora_full_logs.txt" -- 2515
	local fullFolder = Path(Content.writablePath, folder) -- 2516
	Content:mkdir(fullFolder) -- 2517
	local logPath = Path(fullFolder, fullLogFile) -- 2518
	if App:saveLog(logPath) then -- 2519
		return { -- 2520
			success = true, -- 2520
			path = Path(folder, fullLogFile) -- 2520
		} -- 2520
	end -- 2519
	return { -- 2513
		success = false -- 2513
	} -- 2513
end) -- 2513
local tailLines -- 2522
tailLines = function(text, count) -- 2522
	local lines = { } -- 2523
	text = text:gsub("\r\n", "\n") -- 2524
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2525
		lines[#lines + 1] = line -- 2526
	end -- 2525
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2527
		table.remove(lines) -- 2528
	end -- 2527
	local start = math.max(1, #lines - count + 1) -- 2529
	local out = { } -- 2530
	for i = start, #lines do -- 2531
		out[#out + 1] = lines[i] -- 2532
	end -- 2531
	return table.concat(out, "\n") -- 2533
end -- 2522
HttpServer:post("/log", function(req) -- 2535
	local count = 100 -- 2536
	if req and req.body and req.body.count ~= nil then -- 2537
		count = req.body.count -- 2538
	end -- 2537
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2539
		return { -- 2540
			success = false, -- 2540
			message = "count must be a positive integer" -- 2540
		} -- 2540
	end -- 2539
	local folder = ".download" -- 2541
	local fullLogFile = "dora_full_logs.txt" -- 2542
	local fullFolder = Path(Content.writablePath, folder) -- 2543
	Content:mkdir(fullFolder) -- 2544
	local logPath = Path(fullFolder, fullLogFile) -- 2545
	if App:saveLog(logPath) then -- 2546
		local text = Content:load(logPath) -- 2547
		if text then -- 2548
			return { -- 2549
				success = true, -- 2549
				log = tailLines(text, count) -- 2549
			} -- 2549
		else -- 2551
			return { -- 2551
				success = false, -- 2551
				message = "failed to read log" -- 2551
			} -- 2551
		end -- 2548
	else -- 2553
		return { -- 2553
			success = false, -- 2553
			message = "failed to save log" -- 2553
		} -- 2553
	end -- 2546
	return { -- 2535
		success = false -- 2535
	} -- 2535
end) -- 2535
HttpServer:post("/yarn/check", function(req) -- 2555
	local yarncompile = require("yarncompile") -- 2556
	do -- 2557
		local _type_0 = type(req) -- 2557
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2557
		if _tab_0 then -- 2557
			local code -- 2557
			do -- 2557
				local _obj_0 = req.body -- 2557
				local _type_1 = type(_obj_0) -- 2557
				if "table" == _type_1 or "userdata" == _type_1 then -- 2557
					code = _obj_0.code -- 2557
				end -- 2557
			end -- 2557
			if code ~= nil then -- 2557
				local jsonObject = json.decode(code) -- 2558
				if jsonObject then -- 2558
					local errors = { } -- 2559
					local _list_0 = jsonObject.nodes -- 2560
					for _index_0 = 1, #_list_0 do -- 2560
						local node = _list_0[_index_0] -- 2560
						local title, body = node.title, node.body -- 2561
						local luaCode, err = yarncompile(body) -- 2562
						if not luaCode then -- 2562
							errors[#errors + 1] = title .. ":" .. err -- 2563
						end -- 2562
					end -- 2560
					return { -- 2564
						success = true, -- 2564
						syntaxError = table.concat(errors, "\n\n") -- 2564
					} -- 2564
				end -- 2558
			end -- 2557
		end -- 2557
	end -- 2557
	return { -- 2555
		success = false -- 2555
	} -- 2555
end) -- 2555
HttpServer:post("/yarn/check-file", function(req) -- 2566
	local yarncompile = require("yarncompile") -- 2567
	do -- 2568
		local _type_0 = type(req) -- 2568
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2568
		if _tab_0 then -- 2568
			local code -- 2568
			do -- 2568
				local _obj_0 = req.body -- 2568
				local _type_1 = type(_obj_0) -- 2568
				if "table" == _type_1 or "userdata" == _type_1 then -- 2568
					code = _obj_0.code -- 2568
				end -- 2568
			end -- 2568
			if code ~= nil then -- 2568
				local res, _, err = yarncompile(code, true) -- 2569
				if not res then -- 2569
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2570
					return { -- 2571
						success = false, -- 2571
						message = message, -- 2571
						line = line, -- 2571
						column = column, -- 2571
						node = node -- 2571
					} -- 2571
				end -- 2569
			end -- 2568
		end -- 2568
	end -- 2568
	return { -- 2566
		success = true -- 2566
	} -- 2566
end) -- 2566
getWaProjectDirFromFile = function(file) -- 2573
	local current -- 2574
	if Content:isdir(file) then -- 2574
		current = file -- 2574
	else -- 2574
		current = Path:getPath(file) -- 2574
	end -- 2574
	if current == "" then -- 2575
		return nil -- 2575
	end -- 2575
	repeat -- 2576
		local modPath = Path(current, "wa.mod") -- 2577
		if Content:exist(modPath) then -- 2578
			return current, modPath -- 2579
		end -- 2578
		local parent = Path:getPath(current) -- 2580
		if parent == "" or parent == current then -- 2581
			break -- 2581
		end -- 2581
		current = parent -- 2582
	until false -- 2576
	return nil -- 2584
end -- 2573
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2586
	do -- 2587
		local _type_0 = type(req) -- 2587
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2587
		if _tab_0 then -- 2587
			local path -- 2587
			do -- 2587
				local _obj_0 = req.body -- 2587
				local _type_1 = type(_obj_0) -- 2587
				if "table" == _type_1 or "userdata" == _type_1 then -- 2587
					path = _obj_0.path -- 2587
				end -- 2587
			end -- 2587
			if path ~= nil then -- 2587
				local projDir = getWaProjectDirFromFile(path) -- 2588
				if projDir then -- 2588
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2589
					if not Content:exist(sourceDoraPath) then -- 2590
						return { -- 2591
							success = false, -- 2591
							message = "missing dora template" -- 2591
						} -- 2591
					end -- 2590
					local targetVendorPath = Path(projDir, "vendor") -- 2592
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2593
					if not Content:exist(targetVendorPath) then -- 2594
						if not Content:mkdir(targetVendorPath) then -- 2595
							return { -- 2596
								success = false, -- 2596
								message = "failed to create vendor folder" -- 2596
							} -- 2596
						end -- 2595
					elseif not Content:isdir(targetVendorPath) then -- 2597
						return { -- 2598
							success = false, -- 2598
							message = "vendor path is not a folder" -- 2598
						} -- 2598
					end -- 2594
					if Content:exist(targetDoraPath) then -- 2599
						if not Content:remove(targetDoraPath) then -- 2600
							return { -- 2601
								success = false, -- 2601
								message = "failed to remove old dora" -- 2601
							} -- 2601
						end -- 2600
					end -- 2599
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2602
						return { -- 2603
							success = false, -- 2603
							message = "failed to copy dora" -- 2603
						} -- 2603
					end -- 2602
					return { -- 2604
						success = true -- 2604
					} -- 2604
				else -- 2606
					return { -- 2606
						success = false, -- 2606
						message = 'Wa file needs a project' -- 2606
					} -- 2606
				end -- 2588
			end -- 2587
		end -- 2587
	end -- 2587
	return { -- 2586
		success = false, -- 2586
		message = "invalid call" -- 2586
	} -- 2586
end) -- 2586
HttpServer:postSchedule("/wa/build", function(req) -- 2608
	do -- 2609
		local _type_0 = type(req) -- 2609
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2609
		if _tab_0 then -- 2609
			local path -- 2609
			do -- 2609
				local _obj_0 = req.body -- 2609
				local _type_1 = type(_obj_0) -- 2609
				if "table" == _type_1 or "userdata" == _type_1 then -- 2609
					path = _obj_0.path -- 2609
				end -- 2609
			end -- 2609
			if path ~= nil then -- 2609
				local projDir = getWaProjectDirFromFile(path) -- 2610
				if projDir then -- 2610
					local message = Wasm:buildWaAsync(projDir) -- 2611
					if message == "" then -- 2612
						return { -- 2613
							success = true -- 2613
						} -- 2613
					else -- 2615
						return { -- 2615
							success = false, -- 2615
							message = message -- 2615
						} -- 2615
					end -- 2612
				else -- 2617
					return { -- 2617
						success = false, -- 2617
						message = 'Wa file needs a project' -- 2617
					} -- 2617
				end -- 2610
			end -- 2609
		end -- 2609
	end -- 2609
	return { -- 2618
		success = false, -- 2618
		message = 'failed to build' -- 2618
	} -- 2618
end) -- 2608
HttpServer:postSchedule("/wa/format", function(req) -- 2620
	do -- 2621
		local _type_0 = type(req) -- 2621
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2621
		if _tab_0 then -- 2621
			local file -- 2621
			do -- 2621
				local _obj_0 = req.body -- 2621
				local _type_1 = type(_obj_0) -- 2621
				if "table" == _type_1 or "userdata" == _type_1 then -- 2621
					file = _obj_0.file -- 2621
				end -- 2621
			end -- 2621
			if file ~= nil then -- 2621
				local code = Wasm:formatWaAsync(file) -- 2622
				if code == "" then -- 2623
					return { -- 2624
						success = false -- 2624
					} -- 2624
				else -- 2626
					return { -- 2626
						success = true, -- 2626
						code = code -- 2626
					} -- 2626
				end -- 2623
			end -- 2621
		end -- 2621
	end -- 2621
	return { -- 2627
		success = false -- 2627
	} -- 2627
end) -- 2620
HttpServer:postSchedule("/wa/create", function(req) -- 2629
	do -- 2630
		local _type_0 = type(req) -- 2630
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2630
		if _tab_0 then -- 2630
			local path -- 2630
			do -- 2630
				local _obj_0 = req.body -- 2630
				local _type_1 = type(_obj_0) -- 2630
				if "table" == _type_1 or "userdata" == _type_1 then -- 2630
					path = _obj_0.path -- 2630
				end -- 2630
			end -- 2630
			if path ~= nil then -- 2630
				if not Content:exist(Path:getPath(path)) then -- 2631
					return { -- 2632
						success = false, -- 2632
						message = "target path not existed" -- 2632
					} -- 2632
				end -- 2631
				if Content:exist(path) then -- 2633
					return { -- 2634
						success = false, -- 2634
						message = "target project folder existed" -- 2634
					} -- 2634
				end -- 2633
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2635
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2636
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2637
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2638
					return { -- 2641
						success = false, -- 2641
						message = "missing template project" -- 2641
					} -- 2641
				end -- 2638
				if not Content:mkdir(path) then -- 2642
					return { -- 2643
						success = false, -- 2643
						message = "failed to create project folder" -- 2643
					} -- 2643
				end -- 2642
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2644
					Content:remove(path) -- 2645
					return { -- 2646
						success = false, -- 2646
						message = "failed to copy template" -- 2646
					} -- 2646
				end -- 2644
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2647
					Content:remove(path) -- 2648
					return { -- 2649
						success = false, -- 2649
						message = "failed to copy template" -- 2649
					} -- 2649
				end -- 2647
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2650
					Content:remove(path) -- 2651
					return { -- 2652
						success = false, -- 2652
						message = "failed to copy template" -- 2652
					} -- 2652
				end -- 2650
				return { -- 2653
					success = true -- 2653
				} -- 2653
			end -- 2630
		end -- 2630
	end -- 2630
	return { -- 2629
		success = false, -- 2629
		message = "invalid call" -- 2629
	} -- 2629
end) -- 2629
local tsBuildGlobs = { -- 2656
	"**/*.ts", -- 2656
	"**/*.tsx", -- 2657
	"!**/.*/**", -- 2658
	"!**/node_modules/**" -- 2659
} -- 2655
local tsSnapshotGlobs = { -- 2662
	"**/*.ts", -- 2662
	"**/*.tsx", -- 2663
	"**/*.lua", -- 2664
	"!**/.*/**", -- 2665
	"!**/node_modules/**" -- 2666
} -- 2661
local collectTSVirtualFiles -- 2668
collectTSVirtualFiles = function(sourceRoot) -- 2668
	local files = { } -- 2669
	local seen = { } -- 2670
	local addFile -- 2671
	addFile = function(file, moduleName, virtualFile) -- 2671
		if moduleName == nil then -- 2671
			moduleName = nil -- 2671
		end -- 2671
		if virtualFile == nil then -- 2671
			virtualFile = nil -- 2671
		end -- 2671
		local targetFile = virtualFile or file -- 2672
		do -- 2673
			local entry = seen[targetFile] -- 2673
			if entry then -- 2673
				if moduleName and moduleName ~= "" then -- 2674
					entry.moduleName = moduleName -- 2674
				end -- 2674
				return -- 2675
			end -- 2673
		end -- 2673
		local content = Content:load(file) -- 2676
		if content then -- 2676
			local entry = { -- 2677
				file = targetFile, -- 2677
				content = content -- 2677
			} -- 2677
			if moduleName and moduleName ~= "" then -- 2678
				entry.moduleName = moduleName -- 2678
			end -- 2678
			seen[targetFile] = entry -- 2679
			files[#files + 1] = entry -- 2680
		end -- 2676
	end -- 2671
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2681
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2682
		for _index_0 = 1, #_list_0 do -- 2682
			local subFile = _list_0[_index_0] -- 2682
			addFile(Path(sourceRoot, subFile)) -- 2683
		end -- 2682
		local libraryRoots = { -- 2685
			Path(sourceRoot, "Script", "Lib"), -- 2685
			Path(sourceRoot, "Lib"), -- 2686
			Path(Content.assetPath, "Script", "Lib") -- 2687
		} -- 2684
		for _index_0 = 1, #libraryRoots do -- 2688
			local libraryRoot = libraryRoots[_index_0] -- 2688
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2689
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2690
				for _index_1 = 1, #_list_1 do -- 2690
					local subFile = _list_1[_index_1] -- 2690
					local file = Path(libraryRoot, subFile) -- 2691
					local virtualFile = Path(sourceRoot, subFile) -- 2692
					addFile(file, nil, virtualFile) -- 2693
				end -- 2690
			end -- 2689
		end -- 2688
	end -- 2681
	local locale -- 2694
	if App.locale:match('^zh') then -- 2694
		locale = 'zh-Hans' -- 2694
	else -- 2694
		locale = 'en' -- 2694
	end -- 2694
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2695
	local _list_0 = Content:getFiles(declarationRoot) -- 2696
	for _index_0 = 1, #_list_0 do -- 2696
		local file = _list_0[_index_0] -- 2696
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2697
			local fullPath = Path(declarationRoot, file) -- 2698
			local moduleName = Path:getName(Path:getName(file)) -- 2699
			addFile(fullPath, moduleName) -- 2700
		end -- 2697
	end -- 2696
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2701
	local lualibBundleTarget -- 2702
	if sourceRoot then -- 2702
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2702
	else -- 2702
		lualibBundleTarget = "lualib_bundle.lua" -- 2702
	end -- 2702
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2703
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2704
	local _list_1 = Content:getFiles(lualibRoot) -- 2705
	for _index_0 = 1, #_list_1 do -- 2705
		local file = _list_1[_index_0] -- 2705
		if Path:getExt(file) == "lua" then -- 2706
			local virtualFile -- 2707
			if sourceRoot then -- 2707
				virtualFile = Path(sourceRoot, "lualib", file) -- 2707
			else -- 2707
				virtualFile = Path("lualib", file) -- 2707
			end -- 2707
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2708
		end -- 2706
	end -- 2705
	return files -- 2709
end -- 2668
local supportsCompilerWebView -- 2711
supportsCompilerWebView = function() -- 2711
	local _val_0 = App.platform -- 2711
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2711
end -- 2711
local webIDECompilerReady = false -- 2712
local webIDEConnectionGeneration = 0 -- 2713
local tsProbeId = 0 -- 2714
local probeWebIDECompiler -- 2716
probeWebIDECompiler = function(isCancelled) -- 2716
	if HttpServer.wsConnectionCount == 0 then -- 2717
		return false -- 2717
	end -- 2717
	tsProbeId = tsProbeId + 1 -- 2718
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2719
	local generation = webIDEConnectionGeneration -- 2720
	local done, ready = false, false -- 2721
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2722
	local listener = Node() -- 2723
	listener:gslot("AppWS", function(event) -- 2724
		if event.type == "Receive" then -- 2725
			local res = json.decode(event.msg) -- 2726
			if res then -- 2726
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2727
					responses = responses + 1 -- 2728
					ready = ready or res.success == true -- 2729
					done = ready or responses >= expectedResponses -- 2730
				end -- 2727
			end -- 2726
		end -- 2725
	end) -- 2724
	emit("AppWS", "Send", json.encode({ -- 2731
		name = "TranspileTSProbe", -- 2731
		id = requestId -- 2731
	})) -- 2731
	local deadline = App.runningTime + 5 -- 2732
	wait(function() -- 2733
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2733
	end) -- 2733
	listener:removeFromParent() -- 2734
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2735
	if generation == webIDEConnectionGeneration then -- 2736
		webIDECompilerReady = ready -- 2736
	end -- 2736
	return ready -- 2737
end -- 2716
local compilerConnectionListener = Node() -- 2739
compilerConnectionListener:addTo(Director.systemUI) -- 2741
local _anon_func_8 = function(event) -- 2743
	local _val_0 = event.type -- 2743
	return "Open" == _val_0 or "Close" == _val_0 -- 2743
end -- 2743
compilerConnectionListener:gslot("AppWS", function(event) -- 2742
	if _anon_func_8(event) then -- 2743
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2744
		webIDECompilerReady = false -- 2745
		if HttpServer.wsConnectionCount > 0 then -- 2746
			return thread(function() -- 2747
				return probeWebIDECompiler() -- 2747
			end) -- 2747
		end -- 2746
	end -- 2743
end) -- 2742
local _anon_func_9 = function(res) -- 2772
	if res.success then -- 2772
		return "tool" -- 2772
	else -- 2772
		return res.failureKind -- 2772
	end -- 2772
end -- 2772
local transpileTSFileWithWebIDE -- 2749
do -- 2749
	local tsBuildRequestId = 0 -- 2750
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2751
		if not probeWebIDECompiler(isCancelled) then -- 2752
			if isCancelled and isCancelled() then -- 2753
				return { -- 2754
					success = false, -- 2754
					file = file, -- 2754
					message = "build canceled", -- 2754
					interrupted = true -- 2754
				} -- 2754
			end -- 2753
			return { -- 2755
				success = false, -- 2755
				file = file, -- 2755
				message = "TypeScript transpiler is not ready", -- 2755
				failureKind = "tool" -- 2755
			} -- 2755
		end -- 2752
		tsBuildRequestId = tsBuildRequestId + 1 -- 2756
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2757
		local done = false -- 2758
		local result = nil -- 2759
		local listener = Node() -- 2760
		listener:gslot("AppWS", function(event) -- 2761
			if event.type == "Receive" then -- 2762
				local res = json.decode(event.msg) -- 2763
				if res then -- 2763
					if res.name == "TranspileTS" and res.id == requestId then -- 2764
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2765
							local luaFile = Path:replaceExt(file, "lua") -- 2766
							if Content:save(luaFile, res.luaCode) then -- 2767
								result = { -- 2768
									success = true, -- 2768
									file = file -- 2768
								} -- 2768
							else -- 2770
								result = { -- 2770
									success = false, -- 2770
									file = file, -- 2770
									message = "failed to save " .. tostring(luaFile) -- 2770
								} -- 2770
							end -- 2767
						else -- 2772
							result = { -- 2772
								success = false, -- 2772
								file = file, -- 2772
								message = res.message or "Compiler returned no Lua output", -- 2772
								failureKind = _anon_func_9(res) -- 2772
							} -- 2772
						end -- 2765
						done = true -- 2773
					end -- 2764
				end -- 2763
			end -- 2762
		end) -- 2761
		emit("AppWS", "Send", json.encode({ -- 2774
			name = "TranspileTS", -- 2774
			id = requestId, -- 2774
			file = file, -- 2774
			content = content, -- 2774
			projectRoot = sourceRoot, -- 2774
			files = files -- 2774
		})) -- 2774
		local deadline = App.runningTime + 30 -- 2775
		wait(function() -- 2776
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2776
		end) -- 2776
		listener:removeFromParent() -- 2777
		if not done then -- 2778
			webIDECompilerReady = false -- 2779
			if isCancelled and isCancelled() then -- 2780
				return { -- 2781
					success = false, -- 2781
					file = file, -- 2781
					message = "build canceled", -- 2781
					interrupted = true -- 2781
				} -- 2781
			end -- 2780
			return { -- 2782
				success = false, -- 2782
				file = file, -- 2782
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2782
				failureKind = "tool" -- 2782
			} -- 2782
		end -- 2778
		return result -- 2783
	end -- 2751
end -- 2749
local compilerReadyTimeout <const> = 15 -- 2785
local compilerBuildTimeout <const> = 30 -- 2786
local compilerIdleCloseSeconds <const> = 8 -- 2787
local compilerReady = false -- 2788
local compilerRequested = false -- 2789
local compilerFailure = nil -- 2790
local compilerUsers = 0 -- 2791
local compilerCloseGeneration = 0 -- 2792
local compilerJobId = 0 -- 2793
local compilerJobs = { } -- 2794
local compilerResults = { } -- 2795
local compilerInFlight = { } -- 2796
HttpServer:post("/compiler/ready", function() -- 2798
	if not compilerRequested then -- 2799
		return { -- 2799
			success = false -- 2799
		} -- 2799
	end -- 2799
	compilerReady = true -- 2800
	return { -- 2801
		success = true -- 2801
	} -- 2801
end) -- 2798
HttpServer:post("/compiler/failure", function(req) -- 2803
	if not compilerRequested then -- 2804
		return { -- 2804
			success = false -- 2804
		} -- 2804
	end -- 2804
	do -- 2805
		local _type_0 = type(req) -- 2805
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2805
		if _tab_0 then -- 2805
			local message -- 2805
			do -- 2805
				local _obj_0 = req.body -- 2805
				local _type_1 = type(_obj_0) -- 2805
				if "table" == _type_1 or "userdata" == _type_1 then -- 2805
					message = _obj_0.message -- 2805
				end -- 2805
			end -- 2805
			if message ~= nil then -- 2805
				if type(message) == "string" then -- 2806
					compilerFailure = message -- 2807
					compilerReady = false -- 2808
					return { -- 2809
						success = true -- 2809
					} -- 2809
				end -- 2806
			end -- 2805
		end -- 2805
	end -- 2805
	return { -- 2803
		success = false -- 2803
	} -- 2803
end) -- 2803
HttpServer:postSchedule("/compiler/poll", function() -- 2811
	if not compilerRequested then -- 2812
		return { -- 2812
			success = false -- 2812
		} -- 2812
	end -- 2812
	compilerReady = true -- 2813
	local deadline = App.runningTime + 5 -- 2814
	wait(function() -- 2815
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2815
	end) -- 2815
	if not (compilerRequested and not compilerFailure) then -- 2816
		return { -- 2816
			success = false -- 2816
		} -- 2816
	end -- 2816
	local job = table.remove(compilerJobs, 1) -- 2817
	if job then -- 2818
		compilerInFlight[job.id] = true -- 2819
	end -- 2818
	return { -- 2820
		success = true, -- 2820
		job = job -- 2820
	} -- 2820
end) -- 2811
HttpServer:post("/compiler/result", function(req) -- 2822
	do -- 2823
		local _type_0 = type(req) -- 2823
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2823
		if _tab_0 then -- 2823
			local body = req.body -- 2823
			if body ~= nil then -- 2823
				local id = body.id -- 2824
				if not (id and compilerInFlight[id]) then -- 2825
					return { -- 2825
						success = false, -- 2825
						message = "invalid compiler job" -- 2825
					} -- 2825
				end -- 2825
				compilerInFlight[id] = nil -- 2826
				compilerResults[id] = body -- 2827
				return { -- 2828
					success = true -- 2828
				} -- 2828
			end -- 2823
		end -- 2823
	end -- 2823
	return { -- 2822
		success = false -- 2822
	} -- 2822
end) -- 2822
local acquireCompiler -- 2830
acquireCompiler = function() -- 2830
	compilerUsers = compilerUsers + 1 -- 2831
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2832
	if not compilerRequested then -- 2833
		compilerRequested = true -- 2834
		compilerReady = false -- 2835
		compilerFailure = nil -- 2836
		return emit("AppWebView", "/compiler.html", true) -- 2837
	end -- 2833
end -- 2830
local releaseCompiler -- 2839
releaseCompiler = function() -- 2839
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2840
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2841
	if not (compilerUsers == 0) then -- 2842
		return -- 2842
	end -- 2842
	local closeGeneration = compilerCloseGeneration -- 2843
	return thread(function() -- 2844
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2845
		wait(function() -- 2846
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2847
		end) -- 2846
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2852
			compilerRequested = false -- 2853
			compilerReady = false -- 2854
			return emit("AppWebView", "/compiler.html", false) -- 2855
		end -- 2852
	end) -- 2844
end -- 2839
local removeCompilerJob -- 2857
removeCompilerJob = function(id) -- 2857
	for index = #compilerJobs, 1, -1 do -- 2858
		if compilerJobs[index].id == id then -- 2859
			table.remove(compilerJobs, index) -- 2860
		end -- 2859
	end -- 2858
	compilerInFlight[id] = nil -- 2861
	compilerResults[id] = nil -- 2862
end -- 2857
local transpileTSFileWithCompiler -- 2864
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2864
	acquireCompiler() -- 2865
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2866
	wait(function() -- 2867
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2867
	end) -- 2867
	if not compilerReady then -- 2868
		releaseCompiler() -- 2869
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
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2872
			failureKind = "tool" -- 2872
		} -- 2872
	end -- 2868
	compilerJobId = compilerJobId + 1 -- 2873
	local jobId = compilerJobId -- 2874
	compilerJobs[#compilerJobs + 1] = { -- 2876
		id = jobId, -- 2876
		file = file, -- 2877
		content = content, -- 2878
		projectRoot = sourceRoot, -- 2879
		files = files -- 2880
	} -- 2875
	local deadline = App.runningTime + compilerBuildTimeout -- 2881
	wait(function() -- 2882
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2882
	end) -- 2882
	local response = compilerResults[jobId] -- 2883
	removeCompilerJob(jobId) -- 2884
	releaseCompiler() -- 2885
	if not response then -- 2886
		if isCancelled and isCancelled() then -- 2887
			return { -- 2888
				success = false, -- 2888
				file = file, -- 2888
				message = "build canceled", -- 2888
				interrupted = true -- 2888
			} -- 2888
		end -- 2887
		return { -- 2889
			success = false, -- 2889
			file = file, -- 2889
			message = compilerFailure or "TypeScript transpile timed out", -- 2889
			failureKind = "tool" -- 2889
		} -- 2889
	end -- 2886
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2890
		local luaFile = Path:replaceExt(file, "lua") -- 2891
		if Content:save(luaFile, response.luaCode) then -- 2892
			return { -- 2893
				success = true, -- 2893
				file = file -- 2893
			} -- 2893
		end -- 2892
		return { -- 2894
			success = false, -- 2894
			file = file, -- 2894
			message = "failed to save " .. tostring(luaFile) -- 2894
		} -- 2894
	end -- 2890
	return { -- 2895
		success = false, -- 2895
		file = file, -- 2895
		message = response.message or "TypeScript transpile failed" -- 2895
	} -- 2895
end -- 2864
local compilerFailureListener = Node() -- 2897
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2898
	compilerFailure = message -- 2899
	compilerReady = false -- 2900
end) -- 2898
local transpileTSFile -- 2902
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2902
	if supportsCompilerWebView() and not files then -- 2903
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2904
	end -- 2903
	if HttpServer.wsConnectionCount > 0 then -- 2905
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2906
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2907
			return result -- 2907
		end -- 2907
		webIDECompilerReady = false -- 2908
	end -- 2905
	if supportsCompilerWebView() then -- 2909
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2910
	end -- 2909
	return { -- 2911
		success = false, -- 2911
		file = file, -- 2911
		message = "Web IDE compiler not connected", -- 2911
		failureKind = "tool" -- 2911
	} -- 2911
end -- 2902
local _anon_func_10 = function(path) -- 2926
	local _val_0 = Path:getExt(path) -- 2926
	return "ts" == _val_0 or "tsx" == _val_0 -- 2926
end -- 2926
HttpServer:postSchedule("/ts/build", function(req) -- 2913
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2914
	local buildSucceeded = false -- 2915
	local _ <close> = setmetatable({ }, { -- 2916
		__close = function() -- 2916
			return finishUpdate(buildSucceeded) -- 2916
		end -- 2916
	}) -- 2916
	do -- 2917
		local _type_0 = type(req) -- 2917
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2917
		if _tab_0 then -- 2917
			local path -- 2917
			do -- 2917
				local _obj_0 = req.body -- 2917
				local _type_1 = type(_obj_0) -- 2917
				if "table" == _type_1 or "userdata" == _type_1 then -- 2917
					path = _obj_0.path -- 2917
				end -- 2917
			end -- 2917
			if path ~= nil then -- 2917
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2918
					return { -- 2919
						success = false, -- 2919
						message = "Web IDE not connected" -- 2919
					} -- 2919
				end -- 2918
				local projectRoot = req.body.projectRoot -- 2920
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2921
				if not Content:exist(path) then -- 2922
					return { -- 2923
						success = false, -- 2923
						message = "path not existed" -- 2923
					} -- 2923
				end -- 2922
				local messages = { } -- 2924
				if not Content:isdir(path) then -- 2925
					if not (_anon_func_10(path)) then -- 2926
						return { -- 2927
							success = false, -- 2927
							message = "expecting a TypeScript file" -- 2927
						} -- 2927
					end -- 2926
					local content = Content:load(path) -- 2928
					if not content then -- 2929
						return { -- 2930
							success = false, -- 2930
							message = "failed to read file" -- 2930
						} -- 2930
					end -- 2929
					emit("AppWS", "Send", json.encode({ -- 2931
						name = "UpdateFile", -- 2931
						file = path, -- 2931
						exists = true, -- 2931
						content = content, -- 2931
						projectRoot = sourceRoot -- 2931
					})) -- 2931
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2932
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2933
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2934
					end -- 2932
				else -- 2936
					local fileData = { } -- 2936
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2937
					for _index_0 = 1, #_list_0 do -- 2937
						local subFile = _list_0[_index_0] -- 2937
						local file = Path(path, subFile) -- 2938
						local content = Content:load(file) -- 2939
						if content then -- 2939
							fileData[file] = content -- 2940
							emit("AppWS", "Send", json.encode({ -- 2941
								name = "UpdateFile", -- 2941
								file = file, -- 2941
								exists = true, -- 2941
								content = content, -- 2941
								projectRoot = sourceRoot -- 2941
							})) -- 2941
						else -- 2943
							messages[#messages + 1] = { -- 2943
								success = false, -- 2943
								file = file, -- 2943
								message = "failed to read file" -- 2943
							} -- 2943
						end -- 2939
					end -- 2937
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2944
					for file, content in pairs(fileData) do -- 2945
						if "d" == Path:getExt(Path:getName(file)) then -- 2946
							goto _continue_0 -- 2946
						end -- 2946
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2947
						::_continue_0:: -- 2946
					end -- 2945
				end -- 2925
				local success = true -- 2948
				for _index_0 = 1, #messages do -- 2949
					local item = messages[_index_0] -- 2949
					if not item.success then -- 2950
						success = false -- 2950
					end -- 2950
				end -- 2949
				local message = nil -- 2951
				if not success then -- 2952
					message = "TypeScript compilation failed" -- 2952
				end -- 2952
				buildSucceeded = success -- 2953
				return { -- 2954
					success = success, -- 2954
					messages = messages, -- 2954
					message = message -- 2954
				} -- 2954
			end -- 2917
		end -- 2917
	end -- 2917
	return { -- 2913
		success = false -- 2913
	} -- 2913
end) -- 2913
HttpServer:post("/download", function(req) -- 2956
	do -- 2957
		local _type_0 = type(req) -- 2957
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2957
		if _tab_0 then -- 2957
			local url -- 2957
			do -- 2957
				local _obj_0 = req.body -- 2957
				local _type_1 = type(_obj_0) -- 2957
				if "table" == _type_1 or "userdata" == _type_1 then -- 2957
					url = _obj_0.url -- 2957
				end -- 2957
			end -- 2957
			local target -- 2957
			do -- 2957
				local _obj_0 = req.body -- 2957
				local _type_1 = type(_obj_0) -- 2957
				if "table" == _type_1 or "userdata" == _type_1 then -- 2957
					target = _obj_0.target -- 2957
				end -- 2957
			end -- 2957
			if url ~= nil and target ~= nil then -- 2957
				local Entry = require("Script.Dev.Entry") -- 2958
				Entry.downloadFile(url, target) -- 2959
				return { -- 2960
					success = true -- 2960
				} -- 2960
			end -- 2957
		end -- 2957
	end -- 2957
	return { -- 2956
		success = false -- 2956
	} -- 2956
end) -- 2956
local isDesktopPlatform -- 2962
isDesktopPlatform = function() -- 2962
	local _val_0 = App.platform -- 2963
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2963
end -- 2962
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 2965
local nativeIDEListener = Node() -- 2966
nativeIDEListener:addTo(Director.systemUI) -- 2967
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 2968
	nativeIDEState, nativeIDEMessage = state, message -- 2969
end) -- 2968
local _anon_func_11 = function() -- 2972
	local _val_0 = App.platform -- 2972
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2972
end -- 2972
HttpServer:post("/ide", function(req) -- 2971
	if not (_anon_func_11()) then -- 2972
		return { -- 2972
			success = false, -- 2972
			message = "Native IDE is unavailable" -- 2972
		} -- 2972
	end -- 2972
	if not App.webIDEEnabled then -- 2973
		return { -- 2973
			success = false, -- 2973
			message = "Embedded Web IDE is disabled" -- 2973
		} -- 2973
	end -- 2973
	do -- 2974
		local _type_0 = type(req) -- 2974
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2974
		if _tab_0 then -- 2974
			local action -- 2974
			do -- 2974
				local _obj_0 = req.body -- 2974
				local _type_1 = type(_obj_0) -- 2974
				if "table" == _type_1 or "userdata" == _type_1 then -- 2974
					action = _obj_0.action -- 2974
				end -- 2974
			end -- 2974
			if action ~= nil then -- 2974
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 2975
					emit("AppWebView", "/ide/" .. action, true) -- 2976
					return { -- 2977
						success = true -- 2977
					} -- 2977
				end -- 2975
			end -- 2974
		end -- 2974
	end -- 2974
	return { -- 2971
		success = false, -- 2971
		message = "invalid IDE action" -- 2971
	} -- 2971
end) -- 2971
local _anon_func_12 = function() -- 2993
	local _val_0 = App.platform -- 2993
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2993
end -- 2993
local getServerStatus -- 2979
getServerStatus = function() -- 2979
	local Entry = require("Script.Dev.Entry") -- 2980
	local running = Entry.getCurrentEntryStatus() -- 2981
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2982
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2983
	return { -- 2985
		success = true, -- 2985
		platform = App.platform, -- 2986
		locale = App.locale, -- 2987
		version = App.version, -- 2988
		url = "http://localhost:8866", -- 2989
		wsConnectionCount = wsConnectionCount, -- 2990
		webIDEConnected = wsConnectionCount > 0, -- 2991
		nativeIDE = { -- 2993
			supported = _anon_func_12(), -- 2993
			enabled = App.webIDEEnabled, -- 2994
			state = nativeIDEState, -- 2995
			message = nativeIDEMessage -- 2996
		}, -- 2992
		typescriptCompiler = { -- 2998
			webIDEReady = webIDECompilerReady, -- 2998
			webIDEGeneration = webIDEConnectionGeneration, -- 2999
			embeddedSupported = supportsCompilerWebView(), -- 3000
			embeddedRequested = compilerRequested, -- 3001
			embeddedReady = compilerReady, -- 3002
			users = compilerUsers, -- 3003
			queuedJobs = #compilerJobs, -- 3004
			failure = compilerFailure -- 3005
		}, -- 2997
		assetPath = Content.assetPath, -- 3006
		writablePath = Content.writablePath, -- 3007
		appPath = Content.appPath, -- 3008
		waTemplateReady = waTemplateReady, -- 3009
		running = running -- 3010
	} -- 2984
end -- 2979
HttpServer:post("/status", function() -- 3013
	return getServerStatus() -- 3014
end) -- 3013
HttpServer:postSchedule("/doctor/fix", function(req) -- 3016
	do -- 3017
		local _type_0 = type(req) -- 3017
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3017
		if _tab_0 then -- 3017
			local openWebIDE -- 3017
			do -- 3017
				local _obj_0 = req.body -- 3017
				local _type_1 = type(_obj_0) -- 3017
				if "table" == _type_1 or "userdata" == _type_1 then -- 3017
					openWebIDE = _obj_0.openWebIDE -- 3017
				end -- 3017
			end -- 3017
			if openWebIDE ~= nil then -- 3017
				if not openWebIDE then -- 3018
					return { -- 3019
						success = false, -- 3019
						message = "nothing to fix" -- 3019
					} -- 3019
				end -- 3018
				local status = getServerStatus() -- 3020
				if status.webIDEConnected then -- 3021
					return { -- 3022
						success = true, -- 3022
						fixed = false, -- 3022
						message = "Web IDE already connected.", -- 3022
						status = status -- 3022
					} -- 3022
				end -- 3021
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 3023
				if waitSeconds > 0 then -- 3024
					local deadline = os.time() + waitSeconds -- 3025
					repeat -- 3026
						sleep(0.2) -- 3027
						status = getServerStatus() -- 3028
						if status.webIDEConnected then -- 3029
							return { -- 3030
								success = true, -- 3030
								fixed = false, -- 3030
								reconnected = true, -- 3030
								message = "Web IDE reconnected.", -- 3030
								status = status -- 3030
							} -- 3030
						end -- 3029
					until os.time() >= deadline -- 3026
				end -- 3024
				if not isDesktopPlatform() then -- 3032
					return { -- 3033
						success = false, -- 3033
						message = "opening Web IDE is only supported on desktop platforms", -- 3033
						status = status -- 3033
					} -- 3033
				end -- 3032
				local url = "http://localhost:8866" -- 3034
				App:openURL(url) -- 3035
				status.openedURL = url -- 3036
				return { -- 3037
					success = true, -- 3037
					fixed = true, -- 3037
					message = "Opened Web IDE in the local browser.", -- 3037
					url = url, -- 3037
					status = status -- 3037
				} -- 3037
			end -- 3017
		end -- 3017
	end -- 3017
	return { -- 3016
		success = false, -- 3016
		message = "invalid call" -- 3016
	} -- 3016
end) -- 3016
local status = { } -- 3039
_module_0 = status -- 3040
status.transpileTSFile = transpileTSFile -- 3042
HttpServer:postSchedule("/godot/project", function(req) -- 3045
	do -- 3046
		local _type_0 = type(req) -- 3046
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3046
		if _tab_0 then -- 3046
			local path -- 3046
			do -- 3046
				local _obj_0 = req.body -- 3046
				local _type_1 = type(_obj_0) -- 3046
				if "table" == _type_1 or "userdata" == _type_1 then -- 3046
					path = _obj_0.path -- 3046
				end -- 3046
			end -- 3046
			if path ~= nil then -- 3046
				if not (type(path) == "string" and Content:isAbsolutePath(path)) then -- 3047
					return invalidArguments -- 3047
				end -- 3047
				local releaseAgent = AgentHost.acquire() -- 3048
				local _ <close> = setmetatable({ }, { -- 3049
					__close = function() -- 3049
						return releaseAgent() -- 3049
					end -- 3049
				}) -- 3049
				local GodotBuild = require("Agent.Tool.GodotBuild") -- 3050
				local project = GodotBuild.findGodotProject(Content.writablePath, path) or GodotBuild.findGodotProject(Content.assetPath, path) -- 3051
				if not project then -- 3052
					return { -- 3052
						success = true, -- 3052
						found = false -- 3052
					} -- 3052
				end -- 3052
				if not (req.body.build == true) then -- 3053
					return { -- 3053
						success = true, -- 3053
						found = true, -- 3053
						projectRoot = project -- 3053
					} -- 3053
				end -- 3053
				local result -- 3054
				local promise = GodotBuild.buildGodotProject(project) -- 3055
				local onFulfilled -- 3056
				onFulfilled = function(_, value) -- 3056
					result = value -- 3057
				end -- 3056
				local onRejected -- 3058
				onRejected = function(_, err) -- 3058
					result = { -- 3059
						success = false, -- 3059
						message = tostring(err) -- 3059
					} -- 3059
				end -- 3058
				promise["then"](promise, onFulfilled, onRejected) -- 3060
				wait(function() -- 3061
					return result ~= nil -- 3061
				end) -- 3061
				result.found = true -- 3062
				result.projectRoot = project -- 3063
				return result -- 3064
			end -- 3046
		end -- 3046
	end -- 3046
	return invalidArguments -- 3045
end) -- 3045
status.buildAsync = function(path) -- 3066
	if not Content:exist(path) then -- 3067
		return { -- 3068
			success = false, -- 3068
			file = path, -- 3068
			message = "file not existed" -- 3068
		} -- 3068
	end -- 3067
	do -- 3069
		local _exp_0 = Path:getExt(path) -- 3069
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 3069
			if '' == Path:getExt(Path:getName(path)) then -- 3070
				local content = Content:loadAsync(path) -- 3071
				if content then -- 3071
					local resultCodes, err = compileFileAsync(path, content) -- 3072
					if resultCodes then -- 3072
						return { -- 3073
							success = true, -- 3073
							file = path -- 3073
						} -- 3073
					else -- 3075
						return { -- 3075
							success = false, -- 3075
							file = path, -- 3075
							message = err -- 3075
						} -- 3075
					end -- 3072
				end -- 3071
			end -- 3070
		elseif "lua" == _exp_0 then -- 3076
			local content = Content:loadAsync(path) -- 3077
			if content then -- 3077
				do -- 3078
					local isTIC80 = CheckTIC80Code(content) -- 3078
					if isTIC80 then -- 3078
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 3079
					end -- 3078
				end -- 3078
				local success, info -- 3080
				do -- 3080
					local _obj_0 = luaCheck(path, content) -- 3080
					success, info = _obj_0.success, _obj_0.info -- 3080
				end -- 3080
				if success then -- 3081
					return { -- 3082
						success = true, -- 3082
						file = path -- 3082
					} -- 3082
				elseif info and #info > 0 then -- 3083
					local messages = { } -- 3084
					for _index_0 = 1, #info do -- 3085
						local _des_0 = info[_index_0] -- 3085
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3085
						local lineText = "" -- 3086
						if line then -- 3087
							local currentLine = 1 -- 3088
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3089
								if currentLine == line then -- 3090
									lineText = text -- 3091
									break -- 3092
								end -- 3090
								currentLine = currentLine + 1 -- 3093
							end -- 3089
						end -- 3087
						if line then -- 3094
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3095
						else -- 3097
							messages[#messages + 1] = message -- 3097
						end -- 3094
					end -- 3085
					return { -- 3098
						success = false, -- 3098
						file = path, -- 3098
						message = table.concat(messages, "\n") -- 3098
					} -- 3098
				else -- 3100
					return { -- 3100
						success = false, -- 3100
						file = path, -- 3100
						message = "lua check failed" -- 3100
					} -- 3100
				end -- 3081
			end -- 3077
		elseif "yarn" == _exp_0 then -- 3101
			local content = Content:loadAsync(path) -- 3102
			if content then -- 3102
				local res, _, err = yarncompile(content, true) -- 3103
				if res then -- 3103
					return { -- 3104
						success = true, -- 3104
						file = path -- 3104
					} -- 3104
				else -- 3106
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3106
					local lineText = "" -- 3107
					if line then -- 3108
						local currentLine = 1 -- 3109
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3110
							if currentLine == line then -- 3111
								lineText = text -- 3112
								break -- 3113
							end -- 3111
							currentLine = currentLine + 1 -- 3114
						end -- 3110
					end -- 3108
					if node ~= "" then -- 3115
						node = "node: " .. tostring(node) .. ", " -- 3116
					else -- 3117
						node = "" -- 3117
					end -- 3115
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3118
					return { -- 3119
						success = false, -- 3119
						file = path, -- 3119
						message = message -- 3119
					} -- 3119
				end -- 3103
			end -- 3102
		end -- 3069
	end -- 3069
	return { -- 3120
		success = false, -- 3120
		file = path, -- 3120
		message = "invalid file to build" -- 3120
	} -- 3120
end -- 3066
HttpServer:postSchedule("/git/commit-files", function(req) -- 3122
	do -- 3123
		local _type_0 = type(req) -- 3123
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3123
		if _tab_0 then -- 3123
			local body = req.body -- 3123
			if body ~= nil then -- 3123
				local repoPath, commit = body.repoPath, body.commit -- 3124
				if gitInvalidRepoPath(repoPath) then -- 3125
					return { -- 3125
						success = false, -- 3125
						message = "invalid repoPath" -- 3125
					} -- 3125
				end -- 3125
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3126
					return { -- 3126
						success = false, -- 3126
						message = "invalid commit" -- 3126
					} -- 3126
				end -- 3126
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3127
				if not res.success then -- 3128
					return res -- 3128
				end -- 3128
				return { -- 3129
					success = true, -- 3129
					status = res.status, -- 3129
					data = res.status and res.status.data -- 3129
				} -- 3129
			end -- 3123
		end -- 3123
	end -- 3123
	return invalidArguments -- 3122
end) -- 3122
thread(function() -- 3131
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3132
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3133
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3134
		local storedAsset -- 3137
		storedAsset = function(file) -- 3137
			if Content:exist(file) then -- 3138
				return Content:load(file) -- 3139
			elseif Content:exist(file .. ".gz") then -- 3140
				return Content:load(file .. ".gz") -- 3141
			else -- 3142
				return "" -- 3142
			end -- 3138
		end -- 3137
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3143
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3144
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3145
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3146
		local readyContent = table.concat({ -- 3148
			App.version, -- 3148
			storedAsset(doraWeb), -- 3149
			storedAsset(heavyAssets), -- 3150
			storedAsset(runtimeIndex), -- 3151
			storedAsset(compilerIndex), -- 3152
			storedAsset(manifest) -- 3153
		}, "\n") -- 3147
		local needReload -- 3155
		if Content:exist(doraReady) then -- 3155
			needReload = readyContent ~= Content:load(doraReady) -- 3156
		else -- 3157
			needReload = true -- 3157
		end -- 3155
		if needReload then -- 3158
			Content:remove(Path(Content.appPath, ".www")) -- 3159
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3160
			Content:save(doraReady, readyContent) -- 3164
			print("Dora Dora is ready!") -- 3165
		end -- 3158
	end -- 3134
	if App.platform == "Emscripten" then -- 3166
		status.url = nil -- 3167
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3168
	end -- 3166
	HttpServer:clearStaticCacheControls() -- 3169
	HttpServer:setStaticCacheControl("no-cache") -- 3170
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3171
	if HttpServer:start(8866) then -- 3175
		local localIP = HttpServer.localIP -- 3176
		if localIP == "" then -- 3177
			localIP = "localhost" -- 3177
		end -- 3177
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3178
		return HttpServer:startWS(8868) -- 3179
	else -- 3181
		status.url = nil -- 3181
		return print("8866 Port not available!") -- 3182
	end -- 3175
end) -- 3131
return _module_0 -- 1
