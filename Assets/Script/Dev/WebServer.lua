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
HttpServer:post("/engine-update/install", function(req) -- 1491
	return { -- 1491
		success = updater.installUpdate(req.body and req.body.confirmed == true) -- 1491
	} -- 1491
end) -- 1491
HttpServer:post("/info", function(req) -- 1493
	local Entry = require("Script.Dev.Entry") -- 1494
	local config = Entry.getConfig() -- 1495
	do -- 1496
		local _type_0 = type(req) -- 1496
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1496
		if _tab_0 then -- 1496
			local webIDETourCompleted -- 1496
			do -- 1496
				local _obj_0 = req.body -- 1496
				local _type_1 = type(_obj_0) -- 1496
				if "table" == _type_1 or "userdata" == _type_1 then -- 1496
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1496
				end -- 1496
			end -- 1496
			if webIDETourCompleted ~= nil then -- 1496
				config.webIDETourCompleted = webIDETourCompleted == true -- 1497
			end -- 1496
		end -- 1496
	end -- 1496
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1498
	local engineDev = Entry.getEngineDev() -- 1499
	Entry.connectWebIDE(req.body and req.body.embedded == true) -- 1500
	return { -- 1502
		platform = App.platform, -- 1502
		locale = App.locale, -- 1503
		version = App.version, -- 1504
		engineDev = engineDev, -- 1505
		webProfiler = webProfiler, -- 1506
		drawerWidth = drawerWidth, -- 1507
		webIDETourCompleted = webIDETourCompleted == true -- 1508
	} -- 1501
end) -- 1493
local ensureLLMConfigTable -- 1510
ensureLLMConfigTable = function() -- 1510
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1511
	if columns and #columns > 0 then -- 1512
		local expected = { -- 1514
			id = true, -- 1514
			name = true, -- 1515
			url = true, -- 1516
			model = true, -- 1517
			api_key = true, -- 1518
			context_window = true, -- 1519
			temperature = true, -- 1520
			max_tokens = true, -- 1521
			reasoning_effort = true, -- 1522
			custom_options = true, -- 1523
			supports_function_calling = true, -- 1524
			active = true, -- 1525
			created_at = true, -- 1526
			updated_at = true -- 1527
		} -- 1513
		local existing = { } -- 1529
		local valid = true -- 1530
		for _index_0 = 1, #columns do -- 1531
			local row = columns[_index_0] -- 1531
			local columnName = tostring(row[2]) -- 1532
			existing[columnName] = true -- 1533
			if not expected[columnName] then -- 1534
				valid = false -- 1535
				break -- 1536
			end -- 1534
		end -- 1531
		if valid then -- 1537
			if not existing.context_window then -- 1538
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1539
			end -- 1538
			if not existing.temperature then -- 1540
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1541
			end -- 1540
			if not existing.max_tokens then -- 1542
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 64000") -- 1543
			end -- 1542
			if not existing.reasoning_effort then -- 1544
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1545
			end -- 1544
			if not existing.custom_options then -- 1546
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1547
			end -- 1546
		else -- 1549
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1549
		end -- 1537
	end -- 1512
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
	]]) -- 1550
	require("Agent.Config.LLMConfigMigration").upgradeLLMConfig() -- 1569
	return require("Agent.Config.LLMConfigNames").upgradeLLMConfigNames() -- 1570
end -- 1510
local normalizeContextWindow -- 1572
normalizeContextWindow = function(value) -- 1572
	local contextWindow = tonumber(value) -- 1573
	if contextWindow == nil or contextWindow < 64000 then -- 1574
		return 64000 -- 1575
	end -- 1574
	return math.max(64000, math.floor(contextWindow)) -- 1576
end -- 1572
local normalizeTemperature -- 1578
normalizeTemperature = function(value) -- 1578
	local temperature = tonumber(value) -- 1579
	if temperature == nil then -- 1580
		return 0.1 -- 1581
	end -- 1580
	return math.max(0, math.min(2, temperature)) -- 1582
end -- 1578
local normalizeMaxTokens -- 1584
normalizeMaxTokens = function(value) -- 1584
	local maxTokens = tonumber(value) -- 1585
	if maxTokens == nil or maxTokens < 1 then -- 1586
		return 64000 -- 1587
	end -- 1586
	return math.max(1, math.floor(maxTokens)) -- 1588
end -- 1584
local normalizeReasoningEffort -- 1590
normalizeReasoningEffort = function(value) -- 1590
	if value == nil then -- 1591
		return "" -- 1592
	end -- 1591
	local effort = tostring(value) -- 1593
	return effort:match("^%s*(.-)%s*$") or "" -- 1594
end -- 1590
local normalizeCustomOptions -- 1596
normalizeCustomOptions = function(value) -- 1596
	if value == nil then -- 1597
		return "" -- 1598
	end -- 1597
	local options = tostring(value) -- 1599
	options = options:match("^%s*(.-)%s*$") or "" -- 1600
	return options -- 1601
end -- 1596
local validateCustomOptions -- 1603
validateCustomOptions = function(value) -- 1603
	local options = normalizeCustomOptions(value) -- 1604
	if options == "" then -- 1605
		return true -- 1605
	end -- 1605
	if not options:match("^%s*{") then -- 1606
		return false -- 1606
	end -- 1606
	local decoded = json.decode(options) -- 1607
	return type(decoded) == "table" -- 1608
end -- 1603
HttpServer:post("/llm/list", function() -- 1610
	ensureLLMConfigTable() -- 1611
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options\n		from LLMConfig\n		order by id asc") -- 1612
	local items -- 1616
	if rows and #rows > 0 then -- 1616
		local _accum_0 = { } -- 1617
		local _len_0 = 1 -- 1617
		for _index_0 = 1, #rows do -- 1617
			local _des_0 = rows[_index_0] -- 1617
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10] -- 1617
			_accum_0[_len_0] = { -- 1618
				id = id, -- 1618
				name = name, -- 1618
				url = url, -- 1618
				model = model, -- 1618
				key = key, -- 1618
				contextWindow = normalizeContextWindow(contextWindow), -- 1618
				temperature = normalizeTemperature(temperature), -- 1618
				maxTokens = normalizeMaxTokens(maxTokens), -- 1618
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1618
				customOptions = normalizeCustomOptions(customOptions) -- 1618
			} -- 1618
			_len_0 = _len_0 + 1 -- 1618
		end -- 1617
		items = _accum_0 -- 1616
	end -- 1616
	return { -- 1619
		success = true, -- 1619
		items = items -- 1619
	} -- 1619
end) -- 1610
HttpServer:post("/llm/create", function(req) -- 1621
	ensureLLMConfigTable() -- 1622
	do -- 1623
		local _type_0 = type(req) -- 1623
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1623
		if _tab_0 then -- 1623
			local body = req.body -- 1623
			if body ~= nil then -- 1623
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions -- 1624
				local now = os.time() -- 1625
				if name == nil or url == nil or model == nil or key == nil then -- 1626
					return invalidArguments -- 1627
				end -- 1626
				local names = require("Agent.Config.LLMConfigNames") -- 1628
				name = names.normalizeLLMConfigName(name) -- 1629
				if not name then -- 1630
					return { -- 1630
						success = false, -- 1630
						code = "INVALID_LLM_CONFIG_NAME", -- 1630
						message = "LLM configuration name must be a non-empty string" -- 1630
					} -- 1630
				end -- 1630
				local nameCheck = names.checkLLMConfigName(name) -- 1631
				if not nameCheck.success then -- 1632
					return nameCheck -- 1632
				end -- 1632
				contextWindow = normalizeContextWindow(contextWindow) -- 1633
				temperature = normalizeTemperature(temperature) -- 1634
				maxTokens = normalizeMaxTokens(maxTokens) -- 1635
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1636
				customOptions = normalizeCustomOptions(customOptions) -- 1637
				if not validateCustomOptions(customOptions) then -- 1638
					return { -- 1638
						success = false, -- 1638
						message = "customOptions must be a JSON object" -- 1638
					} -- 1638
				end -- 1638
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1645
					tostring(name), -- 1645
					tostring(url), -- 1646
					tostring(model), -- 1647
					tostring(key), -- 1648
					contextWindow, -- 1649
					temperature, -- 1650
					maxTokens, -- 1651
					reasoningEffort, -- 1652
					customOptions, -- 1653
					1, -- 1654
					now, -- 1655
					now -- 1656
				}) -- 1639
				if affected < 0 then -- 1658
					nameCheck = names.checkLLMConfigName(name) -- 1659
					if not nameCheck.success then -- 1660
						return nameCheck -- 1660
					end -- 1660
				end -- 1658
				return { -- 1661
					success = affected > 0 -- 1661
				} -- 1661
			end -- 1623
		end -- 1623
	end -- 1623
	return invalidArguments -- 1621
end) -- 1621
HttpServer:post("/llm/update", function(req) -- 1663
	ensureLLMConfigTable() -- 1664
	do -- 1665
		local _type_0 = type(req) -- 1665
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1665
		if _tab_0 then -- 1665
			local body = req.body -- 1665
			if body ~= nil then -- 1665
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions -- 1666
				local now = os.time() -- 1667
				id = tonumber(id) -- 1668
				if id == nil or id <= 0 or id ~= math.floor(id) then -- 1669
					return invalidArguments -- 1669
				end -- 1669
				local names = require("Agent.Config.LLMConfigNames") -- 1670
				name = names.normalizeLLMConfigName(name) -- 1671
				if not name then -- 1672
					return { -- 1672
						success = false, -- 1672
						code = "INVALID_LLM_CONFIG_NAME", -- 1672
						message = "LLM configuration name must be a non-empty string" -- 1672
					} -- 1672
				end -- 1672
				local nameCheck = names.checkLLMConfigName(name, id) -- 1673
				if not nameCheck.success then -- 1674
					return nameCheck -- 1674
				end -- 1674
				contextWindow = normalizeContextWindow(contextWindow) -- 1675
				temperature = normalizeTemperature(temperature) -- 1676
				maxTokens = normalizeMaxTokens(maxTokens) -- 1677
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1678
				customOptions = normalizeCustomOptions(customOptions) -- 1679
				if not validateCustomOptions(customOptions) then -- 1680
					return { -- 1680
						success = false, -- 1680
						message = "customOptions must be a JSON object" -- 1680
					} -- 1680
				end -- 1680
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, updated_at = ?\n			where id = ?", { -- 1685
					tostring(name), -- 1685
					tostring(url), -- 1686
					tostring(model), -- 1687
					tostring(key), -- 1688
					contextWindow, -- 1689
					temperature, -- 1690
					maxTokens, -- 1691
					reasoningEffort, -- 1692
					customOptions, -- 1693
					now, -- 1694
					id -- 1695
				}) -- 1681
				if affected < 0 then -- 1697
					nameCheck = names.checkLLMConfigName(name, id) -- 1698
					if not nameCheck.success then -- 1699
						return nameCheck -- 1699
					end -- 1699
				end -- 1697
				return { -- 1700
					success = affected > 0 -- 1700
				} -- 1700
			end -- 1665
		end -- 1665
	end -- 1665
	return invalidArguments -- 1663
end) -- 1663
HttpServer:post("/llm/delete", function(req) -- 1702
	ensureLLMConfigTable() -- 1703
	do -- 1704
		local _type_0 = type(req) -- 1704
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1704
		if _tab_0 then -- 1704
			local id -- 1704
			do -- 1704
				local _obj_0 = req.body -- 1704
				local _type_1 = type(_obj_0) -- 1704
				if "table" == _type_1 or "userdata" == _type_1 then -- 1704
					id = _obj_0.id -- 1704
				end -- 1704
			end -- 1704
			if id ~= nil then -- 1704
				id = tonumber(id) -- 1705
				if id == nil then -- 1706
					return invalidArguments -- 1706
				end -- 1706
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1707
					id -- 1707
				}) -- 1707
				return { -- 1708
					success = affected >= 0 -- 1708
				} -- 1708
			end -- 1704
		end -- 1704
	end -- 1704
	return invalidArguments -- 1702
end) -- 1702
HttpServer:post("/local-agent/list", function() -- 1710
	return { -- 1711
		success = true, -- 1711
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1711
		items = AgentLocalAgent.listConfigs() -- 1711
	} -- 1711
end) -- 1710
HttpServer:post("/local-agent/save", function(req) -- 1713
	do -- 1714
		local _type_0 = type(req) -- 1714
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1714
		if _tab_0 then -- 1714
			local body = req.body -- 1714
			if body ~= nil then -- 1714
				return AgentLocalAgent.saveConfig(body) -- 1715
			end -- 1714
		end -- 1714
	end -- 1714
	return invalidArguments -- 1713
end) -- 1713
HttpServer:post("/local-agent/delete", function(req) -- 1717
	do -- 1718
		local _type_0 = type(req) -- 1718
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1718
		if _tab_0 then -- 1718
			local id -- 1718
			do -- 1718
				local _obj_0 = req.body -- 1718
				local _type_1 = type(_obj_0) -- 1718
				if "table" == _type_1 or "userdata" == _type_1 then -- 1718
					id = _obj_0.id -- 1718
				end -- 1718
			end -- 1718
			if id ~= nil then -- 1718
				return AgentLocalAgent.deleteConfig(id) -- 1719
			end -- 1718
		end -- 1718
	end -- 1718
	return invalidArguments -- 1717
end) -- 1717
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1721
	do -- 1722
		local _type_0 = type(req) -- 1722
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1722
		if _tab_0 then -- 1722
			local id -- 1722
			do -- 1722
				local _obj_0 = req.body -- 1722
				local _type_1 = type(_obj_0) -- 1722
				if "table" == _type_1 or "userdata" == _type_1 then -- 1722
					id = _obj_0.id -- 1722
				end -- 1722
			end -- 1722
			if id ~= nil then -- 1722
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1723
			end -- 1722
		end -- 1722
	end -- 1722
	return invalidArguments -- 1721
end) -- 1721
HttpServer:post("/stat", function(req) -- 1725
	do -- 1726
		local _type_0 = type(req) -- 1726
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1726
		if _tab_0 then -- 1726
			local path -- 1726
			do -- 1726
				local _obj_0 = req.body -- 1726
				local _type_1 = type(_obj_0) -- 1726
				if "table" == _type_1 or "userdata" == _type_1 then -- 1726
					path = _obj_0.path -- 1726
				end -- 1726
			end -- 1726
			if path ~= nil then -- 1726
				if not Content:exist(path) then -- 1727
					return { -- 1728
						success = false, -- 1728
						message = "target not existed" -- 1728
					} -- 1728
				end -- 1727
				if Content:isdir(path) then -- 1729
					return { -- 1730
						success = false, -- 1730
						message = "failed to stat a directory" -- 1730
					} -- 1730
				end -- 1729
				local size, isBinary = Content:getAttr(path) -- 1731
				if size then -- 1731
					return { -- 1732
						success = true, -- 1732
						size = size, -- 1732
						isBinary = isBinary -- 1732
					} -- 1732
				end -- 1731
			end -- 1726
		end -- 1726
	end -- 1726
	return { -- 1725
		success = false, -- 1725
		message = "failed to stat" -- 1725
	} -- 1725
end) -- 1725
HttpServer:post("/new", function(req) -- 1734
	do -- 1735
		local _type_0 = type(req) -- 1735
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1735
		if _tab_0 then -- 1735
			local path -- 1735
			do -- 1735
				local _obj_0 = req.body -- 1735
				local _type_1 = type(_obj_0) -- 1735
				if "table" == _type_1 or "userdata" == _type_1 then -- 1735
					path = _obj_0.path -- 1735
				end -- 1735
			end -- 1735
			local content -- 1735
			do -- 1735
				local _obj_0 = req.body -- 1735
				local _type_1 = type(_obj_0) -- 1735
				if "table" == _type_1 or "userdata" == _type_1 then -- 1735
					content = _obj_0.content -- 1735
				end -- 1735
			end -- 1735
			local folder -- 1735
			do -- 1735
				local _obj_0 = req.body -- 1735
				local _type_1 = type(_obj_0) -- 1735
				if "table" == _type_1 or "userdata" == _type_1 then -- 1735
					folder = _obj_0.folder -- 1735
				end -- 1735
			end -- 1735
			if path ~= nil and content ~= nil and folder ~= nil then -- 1735
				if Content:exist(path) then -- 1736
					return { -- 1737
						success = false, -- 1737
						message = "TargetExisted" -- 1737
					} -- 1737
				end -- 1736
				local parent = Path:getPath(path) -- 1738
				local files = Content:getFiles(parent) -- 1739
				if folder then -- 1740
					local name = Path:getFilename(path):lower() -- 1741
					for _index_0 = 1, #files do -- 1742
						local file = files[_index_0] -- 1742
						if name == Path:getFilename(file):lower() then -- 1743
							return { -- 1744
								success = false, -- 1744
								message = "TargetExisted" -- 1744
							} -- 1744
						end -- 1743
					end -- 1742
					if Content:mkdir(path) then -- 1745
						return { -- 1746
							success = true -- 1746
						} -- 1746
					end -- 1745
				else -- 1748
					local name = Path:getName(path):lower() -- 1748
					local targetExt = Path:getExt(path) -- 1749
					for _index_0 = 1, #files do -- 1750
						local file = files[_index_0] -- 1750
						if name == Path:getName(file):lower() then -- 1751
							local ext = Path:getExt(file) -- 1752
							if not ("tl" == targetExt or "yue" == targetExt or "ts" == targetExt or "tsx" == targetExt or "vs" == targetExt or "bl" == targetExt or "xml" == targetExt or "lua" == targetExt) or not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1753
								goto _continue_0 -- 1754
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1755
								goto _continue_0 -- 1756
							end -- 1753
							return { -- 1757
								success = false, -- 1757
								message = "SourceExisted" -- 1757
							} -- 1757
						end -- 1751
						::_continue_0:: -- 1751
					end -- 1750
					if Content:save(path, content) then -- 1758
						return { -- 1759
							success = true -- 1759
						} -- 1759
					end -- 1758
				end -- 1740
			end -- 1735
		end -- 1735
	end -- 1735
	return { -- 1734
		success = false, -- 1734
		message = "Failed" -- 1734
	} -- 1734
end) -- 1734
local deleteAsset -- 1761
deleteAsset = function(path) -- 1761
	if not Content:exist(path) then -- 1762
		return false -- 1762
	end -- 1762
	local projectRoot -- 1763
	if Content:isdir(path) and isProjectRootDir(path) then -- 1763
		projectRoot = path -- 1763
	else -- 1763
		projectRoot = nil -- 1763
	end -- 1763
	local parent = Path:getPath(path) -- 1764
	local files = Content:getFiles(parent) -- 1765
	local name = Path:getName(path):lower() -- 1766
	local ext = Path:getExt(path) -- 1767
	for _index_0 = 1, #files do -- 1768
		local file = files[_index_0] -- 1768
		if name == Path:getName(file):lower() then -- 1769
			local _exp_0 = Path:getExt(file) -- 1770
			if "tl" == _exp_0 then -- 1770
				if ("vs" == ext) then -- 1770
					Content:remove(Path(parent, file)) -- 1771
				end -- 1770
			elseif "lua" == _exp_0 then -- 1772
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1772
					Content:remove(Path(parent, file)) -- 1773
				end -- 1772
			end -- 1770
		end -- 1769
	end -- 1768
	if Content:remove(path) then -- 1774
		if projectRoot then -- 1775
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1776
		end -- 1775
		return true -- 1777
	end -- 1774
	return false -- 1778
end -- 1761
local moveAsset -- 1780
moveAsset = function(old, new) -- 1780
	if not (Content:exist(old) and not Content:exist(new)) then -- 1781
		return false -- 1781
	end -- 1781
	local renamedDir = Content:isdir(old) -- 1782
	local parent = Path:getPath(new) -- 1783
	local files = Content:getFiles(parent) -- 1784
	if renamedDir then -- 1785
		local name = Path:getFilename(new):lower() -- 1786
		for _index_0 = 1, #files do -- 1787
			local file = files[_index_0] -- 1787
			if name == Path:getFilename(file):lower() then -- 1788
				return false -- 1789
			end -- 1788
		end -- 1787
	else -- 1791
		local name = Path:getName(new):lower() -- 1791
		local ext = Path:getExt(new) -- 1792
		for _index_0 = 1, #files do -- 1793
			local file = files[_index_0] -- 1793
			if name == Path:getName(file):lower() then -- 1794
				local fileExt = Path:getExt(file) -- 1795
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) or not ("tl" == fileExt or "yue" == fileExt or "ts" == fileExt or "tsx" == fileExt or "vs" == fileExt or "bl" == fileExt or "xml" == fileExt or "lua" == fileExt) then -- 1796
					goto _continue_0 -- 1797
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1798
					goto _continue_0 -- 1799
				end -- 1796
				return false -- 1800
			end -- 1794
			::_continue_0:: -- 1794
		end -- 1793
	end -- 1785
	if not Content:move(old, new) then -- 1801
		return false -- 1801
	end -- 1801
	if renamedDir then -- 1802
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1803
	end -- 1802
	local newParent = Path:getPath(new) -- 1804
	parent = Path:getPath(old) -- 1805
	files = Content:getFiles(parent) -- 1806
	local newName = Path:getName(new) -- 1807
	local oldName = Path:getName(old) -- 1808
	local name = oldName:lower() -- 1809
	local ext = Path:getExt(old) -- 1810
	for _index_0 = 1, #files do -- 1811
		local file = files[_index_0] -- 1811
		if name == Path:getName(file):lower() then -- 1812
			local _exp_0 = Path:getExt(file) -- 1813
			if "tl" == _exp_0 then -- 1813
				if ("vs" == ext) then -- 1813
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1814
				end -- 1813
			elseif "lua" == _exp_0 then -- 1815
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1815
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1816
				end -- 1815
			end -- 1813
		end -- 1812
	end -- 1811
	return true -- 1817
end -- 1780
HttpServer:post("/delete", function(req) -- 1819
	do -- 1820
		local _type_0 = type(req) -- 1820
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1820
		if _tab_0 then -- 1820
			local path -- 1820
			do -- 1820
				local _obj_0 = req.body -- 1820
				local _type_1 = type(_obj_0) -- 1820
				if "table" == _type_1 or "userdata" == _type_1 then -- 1820
					path = _obj_0.path -- 1820
				end -- 1820
			end -- 1820
			if path ~= nil then -- 1820
				if deleteAsset(path) then -- 1821
					return { -- 1821
						success = true -- 1821
					} -- 1821
				end -- 1821
			end -- 1820
		end -- 1820
	end -- 1820
	return { -- 1819
		success = false -- 1819
	} -- 1819
end) -- 1819
HttpServer:post("/rename", function(req) -- 1823
	do -- 1824
		local _type_0 = type(req) -- 1824
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1824
		if _tab_0 then -- 1824
			local old -- 1824
			do -- 1824
				local _obj_0 = req.body -- 1824
				local _type_1 = type(_obj_0) -- 1824
				if "table" == _type_1 or "userdata" == _type_1 then -- 1824
					old = _obj_0.old -- 1824
				end -- 1824
			end -- 1824
			local new -- 1824
			do -- 1824
				local _obj_0 = req.body -- 1824
				local _type_1 = type(_obj_0) -- 1824
				if "table" == _type_1 or "userdata" == _type_1 then -- 1824
					new = _obj_0.new -- 1824
				end -- 1824
			end -- 1824
			if old ~= nil and new ~= nil then -- 1824
				if moveAsset(old, new) then -- 1825
					return { -- 1825
						success = true -- 1825
					} -- 1825
				end -- 1825
			end -- 1824
		end -- 1824
	end -- 1824
	return { -- 1823
		success = false -- 1823
	} -- 1823
end) -- 1823
local normalizeAssetPaths -- 1827
normalizeAssetPaths = function(paths) -- 1827
	if not (type(paths) == "table") then -- 1828
		return nil -- 1828
	end -- 1828
	local unique = { } -- 1829
	local candidates = { } -- 1830
	for _index_0 = 1, #paths do -- 1831
		local path = paths[_index_0] -- 1831
		if not (type(path) == "string") then -- 1832
			return nil -- 1832
		end -- 1832
		local relative = relativeToRoot(path, Content.writablePath) -- 1833
		if relative == nil or relative == "" or not Content:exist(path) then -- 1834
			return nil -- 1834
		end -- 1834
		if not unique[path] then -- 1835
			unique[path] = true -- 1836
			candidates[#candidates + 1] = path -- 1837
		end -- 1835
	end -- 1831
	table.sort(candidates, function(a, b) -- 1838
		return #a < #b -- 1838
	end) -- 1838
	local result = { } -- 1839
	for _index_0 = 1, #candidates do -- 1840
		local path = candidates[_index_0] -- 1840
		local contained = false -- 1841
		for _index_1 = 1, #result do -- 1842
			local parent = result[_index_1] -- 1842
			if relativeToRoot(path, parent) ~= nil then -- 1843
				contained = true -- 1844
				break -- 1845
			end -- 1843
		end -- 1842
		if not contained then -- 1846
			result[#result + 1] = path -- 1846
		end -- 1846
	end -- 1840
	return result -- 1847
end -- 1827
HttpServer:postSchedule("/assets/batch", function(req) -- 1849
	do -- 1850
		local _type_0 = type(req) -- 1850
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1850
		if _tab_0 then -- 1850
			local operation -- 1850
			do -- 1850
				local _obj_0 = req.body -- 1850
				local _type_1 = type(_obj_0) -- 1850
				if "table" == _type_1 or "userdata" == _type_1 then -- 1850
					operation = _obj_0.operation -- 1850
				end -- 1850
			end -- 1850
			local sources -- 1850
			do -- 1850
				local _obj_0 = req.body -- 1850
				local _type_1 = type(_obj_0) -- 1850
				if "table" == _type_1 or "userdata" == _type_1 then -- 1850
					sources = _obj_0.sources -- 1850
				end -- 1850
			end -- 1850
			if operation ~= nil and sources ~= nil then -- 1850
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1851
					return { -- 1851
						success = false, -- 1851
						message = "invalid operation" -- 1851
					} -- 1851
				end -- 1851
				sources = normalizeAssetPaths(sources) -- 1852
				if not (sources and #sources > 0) then -- 1853
					return { -- 1853
						success = false, -- 1853
						message = "invalid sources" -- 1853
					} -- 1853
				end -- 1853
				local target = req.body.target -- 1854
				local destinations = { } -- 1855
				if operation ~= "delete" then -- 1856
					if not (type(target) == "string") then -- 1857
						return { -- 1857
							success = false, -- 1857
							message = "invalid target" -- 1857
						} -- 1857
					end -- 1857
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1858
					if targetRelative == nil then -- 1859
						return { -- 1859
							success = false, -- 1859
							message = "invalid target" -- 1859
						} -- 1859
					end -- 1859
					if not (Content:exist(target) and Content:isdir(target)) then -- 1860
						return { -- 1860
							success = false, -- 1860
							message = "invalid target" -- 1860
						} -- 1860
					end -- 1860
					for _index_0 = 1, #sources do -- 1861
						local source = sources[_index_0] -- 1861
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1862
							return { -- 1863
								success = false, -- 1863
								message = "target inside source" -- 1863
							} -- 1863
						end -- 1862
						local destination = Path(target, Path:getFilename(source)) -- 1864
						if Content:exist(destination) then -- 1865
							return { -- 1865
								success = false, -- 1865
								message = "target existed" -- 1865
							} -- 1865
						end -- 1865
						if destinations[destination] then -- 1866
							return { -- 1866
								success = false, -- 1866
								message = "duplicate target" -- 1866
							} -- 1866
						end -- 1866
						destinations[destination] = true -- 1867
					end -- 1861
				end -- 1856
				local changes = { } -- 1868
				local affectedSet = { } -- 1869
				local affectedDirectories = { } -- 1870
				local addAffected -- 1871
				addAffected = function(dir) -- 1871
					if affectedSet[dir] then -- 1872
						return -- 1872
					end -- 1872
					affectedSet[dir] = true -- 1873
					affectedDirectories[#affectedDirectories + 1] = dir -- 1874
				end -- 1871
				if operation ~= "delete" then -- 1875
					addAffected(target) -- 1875
				end -- 1875
				for _index_0 = 1, #sources do -- 1876
					local source = sources[_index_0] -- 1876
					addAffected(Path:getPath(source)) -- 1877
					if operation == "delete" then -- 1878
						if not deleteAsset(source) then -- 1879
							return { -- 1879
								success = false, -- 1879
								message = "delete failed", -- 1879
								changes = changes, -- 1879
								affectedDirectories = affectedDirectories -- 1879
							} -- 1879
						end -- 1879
						changes[#changes + 1] = { -- 1880
							old = source -- 1880
						} -- 1880
					else -- 1882
						local destination = Path(target, Path:getFilename(source)) -- 1882
						local ok -- 1883
						if operation == "copy" then -- 1883
							ok = Content:copyAsync(source, destination) -- 1884
						else -- 1886
							ok = moveAsset(source, destination) -- 1886
						end -- 1883
						if not ok then -- 1887
							return { -- 1887
								success = false, -- 1887
								message = operation .. " failed", -- 1887
								changes = changes, -- 1887
								affectedDirectories = affectedDirectories -- 1887
							} -- 1887
						end -- 1887
						changes[#changes + 1] = { -- 1888
							old = source, -- 1888
							new = destination -- 1888
						} -- 1888
					end -- 1878
				end -- 1876
				return { -- 1889
					success = true, -- 1889
					changes = changes, -- 1889
					affectedDirectories = affectedDirectories -- 1889
				} -- 1889
			end -- 1850
		end -- 1850
	end -- 1850
	return { -- 1849
		success = false, -- 1849
		message = "invalid request" -- 1849
	} -- 1849
end) -- 1849
local withProjectSearchPaths -- 1891
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1891
	local fallbackPaths = { } -- 1892
	local addFallback -- 1893
	addFallback = function(dir) -- 1893
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1893
			fallbackPaths[#fallbackPaths + 1] = dir -- 1893
		end -- 1893
	end -- 1893
	if projectRoot and projectRoot ~= "" then -- 1894
		addFallback(Path(projectRoot, "Script")) -- 1895
		addFallback(projectRoot) -- 1896
	end -- 1894
	if projFile then -- 1897
		local projDir = getProjectDirFromFile(projFile) -- 1898
		if projDir then -- 1898
			addFallback(Path(projDir, "Script")) -- 1899
			addFallback(projDir) -- 1900
		else -- 1902
			addFallback(Path:getPath(projFile)) -- 1902
		end -- 1898
	end -- 1897
	if not (#fallbackPaths > 0) then -- 1903
		return fn() -- 1903
	end -- 1903
	local searchPaths = Content.searchPaths -- 1904
	for _index_0 = 1, #fallbackPaths do -- 1905
		local dir = fallbackPaths[_index_0] -- 1905
		Content:addSearchPath(dir) -- 1905
	end -- 1905
	local _ <close> = setmetatable({ }, { -- 1906
		__close = function() -- 1906
			Content.searchPaths = searchPaths -- 1906
		end -- 1906
	}) -- 1906
	return fn() -- 1907
end -- 1891
HttpServer:post("/exist", function(req) -- 1908
	do -- 1909
		local _type_0 = type(req) -- 1909
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1909
		if _tab_0 then -- 1909
			local file -- 1909
			do -- 1909
				local _obj_0 = req.body -- 1909
				local _type_1 = type(_obj_0) -- 1909
				if "table" == _type_1 or "userdata" == _type_1 then -- 1909
					file = _obj_0.file -- 1909
				end -- 1909
			end -- 1909
			if file ~= nil then -- 1909
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1910
					return { -- 1911
						success = Content:exist(file) -- 1911
					} -- 1911
				end) -- 1910
			end -- 1909
		end -- 1909
	end -- 1909
	return { -- 1908
		success = false -- 1908
	} -- 1908
end) -- 1908
HttpServer:postSchedule("/read", function(req) -- 1912
	do -- 1913
		local _type_0 = type(req) -- 1913
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1913
		if _tab_0 then -- 1913
			local path -- 1913
			do -- 1913
				local _obj_0 = req.body -- 1913
				local _type_1 = type(_obj_0) -- 1913
				if "table" == _type_1 or "userdata" == _type_1 then -- 1913
					path = _obj_0.path -- 1913
				end -- 1913
			end -- 1913
			if path ~= nil then -- 1913
				local readFile -- 1914
				readFile = function() -- 1914
					if Content:exist(path) and not Content:isdir(path) then -- 1915
						local content = Content:loadAsync(path) -- 1916
						if content then -- 1916
							return { -- 1917
								content = content, -- 1917
								success = true, -- 1917
								fullPath = Content:getFullPath(path) -- 1917
							} -- 1917
						end -- 1916
					end -- 1915
					return nil -- 1914
				end -- 1914
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1918
				if result then -- 1918
					return result -- 1918
				end -- 1918
			end -- 1913
		end -- 1913
	end -- 1913
	return { -- 1912
		success = false -- 1912
	} -- 1912
end) -- 1912
local agentDocLanguage -- 1920
agentDocLanguage = function(language) -- 1920
	if language == "zh-Hans" then -- 1921
		return "zh" -- 1921
	else -- 1921
		return "en" -- 1921
	end -- 1921
end -- 1920
HttpServer:postSchedule("/doc/search", function(req) -- 1923
	local body = req.body or { } -- 1924
	local language = body.docLanguage -- 1925
	if not (("en" == language or "zh-Hans" == language)) then -- 1926
		return { -- 1926
			success = false, -- 1926
			message = "unsupported doc language" -- 1926
		} -- 1926
	end -- 1926
	local docType = body.docType -- 1927
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1928
		return { -- 1928
			success = false, -- 1928
			message = "unsupported doc type" -- 1928
		} -- 1928
	end -- 1928
	local codeLanguage = body.programmingLanguage -- 1929
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1930
		return { -- 1930
			success = false, -- 1930
			message = "unsupported programming language" -- 1930
		} -- 1930
	end -- 1930
	if not body.pattern then -- 1931
		return { -- 1931
			success = false, -- 1931
			message = "missing pattern" -- 1931
		} -- 1931
	end -- 1931
	local result = nil -- 1932
	AgentTools.searchDoraDocHttp({ -- 1934
		pattern = body.pattern, -- 1934
		docLanguage = agentDocLanguage(language), -- 1935
		docType = docType, -- 1936
		programmingLanguage = codeLanguage, -- 1937
		limit = body.limit, -- 1938
		useRegex = body.useRegex, -- 1939
		caseSensitive = body.caseSensitive, -- 1940
		includeContent = body.includeContent, -- 1941
		contentWindow = body.contentWindow -- 1942
	}, function(res) -- 1943
		result = res -- 1944
	end) -- 1933
	wait(function() -- 1945
		return result ~= nil -- 1945
	end) -- 1945
	if result and result.success then -- 1946
		result.docLanguage = language -- 1947
	end -- 1946
	if result then -- 1948
		return result -- 1949
	else -- 1951
		return { -- 1951
			success = false, -- 1951
			message = "doc search failed" -- 1951
		} -- 1951
	end -- 1948
	return { -- 1923
		success = false, -- 1923
		message = "invalid call" -- 1923
	} -- 1923
end) -- 1923
HttpServer:postSchedule("/doc/read", function(req) -- 1953
	local body = req.body or { } -- 1954
	local language = body.docLanguage -- 1955
	if not (("en" == language or "zh-Hans" == language)) then -- 1956
		return { -- 1956
			success = false, -- 1956
			message = "unsupported doc language" -- 1956
		} -- 1956
	end -- 1956
	if not body.file then -- 1957
		return { -- 1957
			success = false, -- 1957
			message = "missing file" -- 1957
		} -- 1957
	end -- 1957
	local result = AgentTools.readDoraDoc({ -- 1959
		docLanguage = agentDocLanguage(language), -- 1959
		file = body.file, -- 1960
		startLine = body.startLine, -- 1961
		endLine = body.endLine -- 1962
	}) -- 1958
	if result and result.success then -- 1963
		result.docLanguage = language -- 1964
	end -- 1963
	return result -- 1965
end) -- 1953
local readSyncFile -- 1967
readSyncFile = function(req) -- 1967
	do -- 1968
		local _type_0 = type(req) -- 1968
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1968
		if _tab_0 then -- 1968
			local params = req.params -- 1968
			if params ~= nil then -- 1968
				local path = params.path -- 1969
				if not (type(path) == "string" and path ~= "") then -- 1970
					return { -- 1970
						success = false, -- 1970
						message = "invalid path" -- 1970
					} -- 1970
				end -- 1970
				local exts -- 1971
				if params.exts then -- 1971
					local _accum_0 = { } -- 1972
					local _len_0 = 1 -- 1972
					for ext in params.exts:gmatch("[^|]*") do -- 1972
						_accum_0[_len_0] = ext -- 1972
						_len_0 = _len_0 + 1 -- 1972
					end -- 1972
					exts = _accum_0 -- 1972
				else -- 1973
					exts = { -- 1973
						"" -- 1973
					} -- 1973
				end -- 1971
				local readFileAt -- 1974
				readFileAt = function(targetPath) -- 1974
					if Content:exist(targetPath) then -- 1975
						local content = Content:load(targetPath) -- 1976
						if content then -- 1976
							return { -- 1977
								content = content, -- 1977
								success = true, -- 1977
								fullPath = Content:getFullPath(targetPath) -- 1977
							} -- 1977
						end -- 1976
					end -- 1975
					return nil -- 1974
				end -- 1974
				local readFile -- 1978
				readFile = function(fallbackPaths) -- 1978
					for _index_0 = 1, #exts do -- 1979
						local ext = exts[_index_0] -- 1979
						local targetPath = path .. ext -- 1980
						if not Content:isAbsolutePath(targetPath) then -- 1981
							for _index_1 = 1, #fallbackPaths do -- 1982
								local fallback = fallbackPaths[_index_1] -- 1982
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1983
								if fallbackResult then -- 1983
									return fallbackResult -- 1984
								end -- 1983
							end -- 1982
						end -- 1981
						local fileResult = readFileAt(targetPath) -- 1985
						if fileResult then -- 1985
							return fileResult -- 1986
						end -- 1985
					end -- 1979
					return nil -- 1978
				end -- 1978
				local fallbackPaths = { } -- 1987
				local fallbackCandidates = { } -- 1988
				do -- 1989
					local projectRoot = req.params.projectRoot -- 1989
					if projectRoot then -- 1989
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1990
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1991
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1992
						end -- 1990
					end -- 1989
				end -- 1989
				do -- 1993
					local projFile = req.params.projFile -- 1993
					if projFile then -- 1993
						local projDir = getProjectDirFromFile(projFile) -- 1994
						if projDir then -- 1994
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1995
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1996
						else -- 1998
							projDir = Path:getPath(projFile) -- 1998
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1999
						end -- 1994
					end -- 1993
				end -- 1993
				for _index_0 = 1, #fallbackCandidates do -- 2000
					local dir = fallbackCandidates[_index_0] -- 2000
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 2001
						local exists = false -- 2002
						for _index_1 = 1, #fallbackPaths do -- 2003
							local fallback = fallbackPaths[_index_1] -- 2003
							if fallback == dir then -- 2004
								exists = true -- 2005
								break -- 2006
							end -- 2004
						end -- 2003
						if not exists then -- 2007
							fallbackPaths[#fallbackPaths + 1] = dir -- 2007
						end -- 2007
					end -- 2001
				end -- 2000
				local readResult = readFile(fallbackPaths) -- 2008
				if readResult then -- 2008
					return readResult -- 2009
				end -- 2008
			end -- 1968
		end -- 1968
	end -- 1968
	return { -- 1967
		success = false -- 1967
	} -- 1967
end -- 1967
HttpServer:get("/read-sync", readSyncFile) -- 2011
HttpServer:post("/read-sync", function(req) -- 2012
	return readSyncFile({ -- 2012
		params = req.body -- 2012
	}) -- 2012
end) -- 2012
local addGeneratedSourceHeader -- 2014
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 2014
	if preserveTIC80 == nil then -- 2014
		preserveTIC80 = false -- 2014
	end -- 2014
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 2015
	if preserveTIC80 then -- 2016
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 2017
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 2018
		end -- 2017
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 2019
	end -- 2016
	return tostring(header) .. "\n" .. tostring(codes) -- 2020
end -- 2014
local compileFileAsync -- 2022
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 2022
	if projectRoot == nil then -- 2022
		projectRoot = nil -- 2022
	end -- 2022
	local file = inputFile -- 2023
	local searchPath -- 2024
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2024
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 2025
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 2029
	elseif not Content:isAbsolutePath(inputFile) then -- 2030
		searchPath = "" -- 2031
	else -- 2032
		local dir = getProjectDirFromFile(inputFile) -- 2032
		if dir then -- 2032
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2033
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 2037
		else -- 2039
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2039
			searchPath = "" -- 2042
		end -- 2032
	end -- 2024
	local outputFile = Path:replaceExt(inputFile, "lua") -- 2043
	local yueext = yue.options.extension -- 2044
	local resultCodes = nil -- 2045
	local resultError = nil -- 2046
	do -- 2047
		local _exp_0 = Path:getExt(inputFile) -- 2047
		if yueext == _exp_0 then -- 2047
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 2048
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 2049
				if not codes then -- 2050
					resultError = err -- 2051
					return -- 2052
				end -- 2050
				local extraGlobal -- 2053
				if isTIC80 then -- 2053
					extraGlobal = tic80APIs -- 2053
				else -- 2053
					extraGlobal = nil -- 2053
				end -- 2053
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 2054
				if not success then -- 2055
					resultError = message -- 2056
					return -- 2057
				end -- 2055
				if codes == "" then -- 2058
					resultCodes = "" -- 2059
					return nil -- 2060
				end -- 2058
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 2061
				return resultCodes -- 2062
			end, function(success) -- 2049
				if not success then -- 2063
					Content:remove(outputFile) -- 2064
					if resultCodes == nil then -- 2065
						resultCodes = false -- 2066
					end -- 2065
				end -- 2063
			end) -- 2049
		elseif "tl" == _exp_0 then -- 2067
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 2068
			if isTIC80 then -- 2069
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2070
			end -- 2069
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2071
			if codes then -- 2071
				if isTIC80 then -- 2072
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2073
				end -- 2072
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2074
				Content:saveAsync(outputFile, resultCodes) -- 2075
			else -- 2077
				Content:remove(outputFile) -- 2077
				resultCodes = false -- 2078
				resultError = err -- 2079
			end -- 2071
		elseif "xml" == _exp_0 then -- 2080
			local codes, err = xml.tolua(sourceCodes) -- 2081
			if codes then -- 2081
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2082
				Content:saveAsync(outputFile, resultCodes) -- 2083
			else -- 2085
				Content:remove(outputFile) -- 2085
				resultCodes = false -- 2086
				resultError = err -- 2087
			end -- 2081
		end -- 2047
	end -- 2047
	wait(function() -- 2088
		return resultCodes ~= nil -- 2088
	end) -- 2088
	if resultCodes then -- 2089
		return resultCodes -- 2090
	else -- 2092
		return nil, resultError -- 2092
	end -- 2089
	return nil -- 2022
end -- 2022
HttpServer:postSchedule("/write", function(req) -- 2094
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
			local content -- 2098
			do -- 2098
				local _obj_0 = req.body -- 2098
				local _type_1 = type(_obj_0) -- 2098
				if "table" == _type_1 or "userdata" == _type_1 then -- 2098
					content = _obj_0.content -- 2098
				end -- 2098
			end -- 2098
			if path ~= nil and content ~= nil then -- 2098
				if Content:saveAsync(path, content) then -- 2099
					do -- 2100
						local _exp_0 = Path:getExt(path) -- 2100
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2100
							if '' == Path:getExt(Path:getName(path)) then -- 2101
								local resultCodes = compileFileAsync(path, content) -- 2102
								buildSucceeded = resultCodes ~= nil -- 2103
								return { -- 2104
									success = true, -- 2104
									resultCodes = resultCodes -- 2104
								} -- 2104
							end -- 2101
						end -- 2100
					end -- 2100
					buildSucceeded = true -- 2105
					return { -- 2106
						success = true -- 2106
					} -- 2106
				end -- 2099
			end -- 2098
		end -- 2098
	end -- 2098
	return { -- 2094
		success = false -- 2094
	} -- 2094
end) -- 2094
local getWaProjectDirFromFile = nil -- 2108
HttpServer:postSchedule("/build", function(req) -- 2110
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2111
	local buildSucceeded = false -- 2112
	local _ <close> = setmetatable({ }, { -- 2113
		__close = function() -- 2113
			return finishUpdate(buildSucceeded) -- 2113
		end -- 2113
	}) -- 2113
	do -- 2114
		local _type_0 = type(req) -- 2114
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2114
		if _tab_0 then -- 2114
			local path -- 2114
			do -- 2114
				local _obj_0 = req.body -- 2114
				local _type_1 = type(_obj_0) -- 2114
				if "table" == _type_1 or "userdata" == _type_1 then -- 2114
					path = _obj_0.path -- 2114
				end -- 2114
			end -- 2114
			if path ~= nil then -- 2114
				local projectRoot = req.body.projectRoot -- 2115
				if Content:isdir(path) then -- 2116
					local projDir = getWaProjectDirFromFile(path) -- 2117
					if projDir then -- 2117
						local message = Wasm:buildWaAsync(projDir) -- 2118
						if message == "" then -- 2119
							return { -- 2120
								success = true -- 2120
							} -- 2120
						else -- 2122
							return { -- 2122
								success = false, -- 2122
								message = message -- 2122
							} -- 2122
						end -- 2119
					end -- 2117
				end -- 2116
				local _exp_0 = Path:getExt(path) -- 2123
				if "gd" == _exp_0 or "tscn" == _exp_0 or "tres" == _exp_0 or "gdshader" == _exp_0 or "gdshaderinc" == _exp_0 then -- 2124
					local content = Content:loadAsync(path) -- 2125
					if content then -- 2125
						local result = godotCheckAsync(path, content, false) -- 2126
						buildSucceeded = result.success and not result.skipped -- 2127
						return { -- 2128
							success = buildSucceeded, -- 2128
							resultCodes = "", -- 2128
							info = result.info -- 2128
						} -- 2128
					end -- 2125
				elseif "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2129
					if '' == Path:getExt(Path:getName(path)) then -- 2130
						local content = Content:loadAsync(path) -- 2131
						if content then -- 2131
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2132
							if resultCodes then -- 2132
								buildSucceeded = true -- 2133
								return { -- 2134
									success = true, -- 2134
									resultCodes = resultCodes -- 2134
								} -- 2134
							end -- 2132
						end -- 2131
					end -- 2130
				elseif "wa" == _exp_0 then -- 2135
					local projDir = getWaProjectDirFromFile(path) -- 2136
					if projDir then -- 2136
						local message = Wasm:buildWaAsync(projDir) -- 2137
						if message == "" then -- 2138
							return { -- 2139
								success = true -- 2139
							} -- 2139
						else -- 2141
							return { -- 2141
								success = false, -- 2141
								message = message -- 2141
							} -- 2141
						end -- 2138
					else -- 2143
						return { -- 2143
							success = false, -- 2143
							message = 'Wa file needs a project' -- 2143
						} -- 2143
					end -- 2136
				end -- 2123
			end -- 2114
		end -- 2114
	end -- 2114
	return { -- 2110
		success = false -- 2110
	} -- 2110
end) -- 2110
local extentionLevels = { -- 2146
	vs = 2, -- 2146
	bl = 2, -- 2147
	ts = 1, -- 2148
	tsx = 1, -- 2149
	tl = 1, -- 2150
	yue = 1, -- 2151
	xml = 1, -- 2152
	lua = 0 -- 2153
} -- 2145
local visitAssets -- 2155
visitAssets = function(path, workspace, builtin, recursive) -- 2155
	if recursive == nil then -- 2155
		recursive = true -- 2155
	end -- 2155
	local children = nil -- 2156
	local dirs = Content:getDirs(path) -- 2157
	for _index_0 = 1, #dirs do -- 2158
		local dir = dirs[_index_0] -- 2158
		if workspace then -- 2159
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or ".godot" == dir or "node_modules" == dir) then -- 2160
				goto _continue_0 -- 2161
			end -- 2160
		elseif dir == ".git" or dir == ".godot" then -- 2162
			goto _continue_0 -- 2163
		end -- 2159
		if not children then -- 2164
			children = { } -- 2164
		end -- 2164
		local dirPath = Path(path, dir) -- 2165
		if recursive then -- 2166
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2167
		else -- 2169
			children[#children + 1] = { -- 2170
				key = dirPath, -- 2170
				dir = true, -- 2171
				title = dir, -- 2172
				builtin = builtin, -- 2173
				isLeaf = false -- 2174
			} -- 2169
		end -- 2166
		::_continue_0:: -- 2159
	end -- 2158
	local files = Content:getFiles(path) -- 2176
	local names = { } -- 2177
	for _index_0 = 1, #files do -- 2178
		local file = files[_index_0] -- 2178
		if (".DS_Store" == file) then -- 2179
			goto _continue_1 -- 2180
		end -- 2179
		local ext = Path:getExt(file) -- 2181
		if not extentionLevels[ext] then -- 2182
			names[file] = "" -- 2183
			goto _continue_1 -- 2184
		end -- 2182
		local name = Path:getName(file) -- 2185
		ext = names[name] -- 2186
		if ext then -- 2186
			local lv1 -- 2187
			do -- 2187
				local _exp_0 = extentionLevels[ext] -- 2187
				if _exp_0 ~= nil then -- 2187
					lv1 = _exp_0 -- 2187
				else -- 2187
					lv1 = -1 -- 2187
				end -- 2187
			end -- 2187
			ext = Path:getExt(file) -- 2188
			local lv2 -- 2189
			do -- 2189
				local _exp_0 = extentionLevels[ext] -- 2189
				if _exp_0 ~= nil then -- 2189
					lv2 = _exp_0 -- 2189
				else -- 2189
					lv2 = -1 -- 2189
				end -- 2189
			end -- 2189
			if lv2 > lv1 then -- 2190
				names[name] = ext -- 2191
			elseif lv2 == lv1 then -- 2192
				names[name .. '.' .. ext] = "" -- 2193
			end -- 2190
		else -- 2195
			ext = Path:getExt(file) -- 2195
			if not extentionLevels[ext] then -- 2196
				names[file] = "" -- 2197
			else -- 2199
				names[name] = ext -- 2199
			end -- 2196
		end -- 2186
		::_continue_1:: -- 2179
	end -- 2178
	do -- 2200
		local _accum_0 = { } -- 2200
		local _len_0 = 1 -- 2200
		for name, ext in pairs(names) do -- 2200
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2200
			_len_0 = _len_0 + 1 -- 2200
		end -- 2200
		files = _accum_0 -- 2200
	end -- 2200
	for _index_0 = 1, #files do -- 2201
		local file = files[_index_0] -- 2201
		if not children then -- 2202
			children = { } -- 2202
		end -- 2202
		children[#children + 1] = { -- 2204
			key = Path(path, file), -- 2204
			dir = false, -- 2205
			title = file, -- 2206
			builtin = builtin -- 2207
		} -- 2203
	end -- 2201
	if children then -- 2209
		table.sort(children, function(a, b) -- 2210
			if a.dir == b.dir then -- 2211
				return a.title < b.title -- 2212
			else -- 2214
				return a.dir -- 2214
			end -- 2211
		end) -- 2210
	end -- 2209
	return { -- 2216
		key = path, -- 2216
		dir = true, -- 2217
		title = Path:getFilename(path), -- 2218
		builtin = builtin, -- 2219
		isLeaf = not children, -- 2220
		children = children -- 2221
	} -- 2215
end -- 2155
HttpServer:post("/assets/children", function(req) -- 2224
	do -- 2225
		local _type_0 = type(req) -- 2225
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2225
		if _tab_0 then -- 2225
			local path -- 2225
			do -- 2225
				local _obj_0 = req.body -- 2225
				local _type_1 = type(_obj_0) -- 2225
				if "table" == _type_1 or "userdata" == _type_1 then -- 2225
					path = _obj_0.path -- 2225
				end -- 2225
			end -- 2225
			if path ~= nil then -- 2225
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2226
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2227
					return { -- 2227
						success = false -- 2227
					} -- 2227
				end -- 2227
				local node = visitAssets(path, workspace, builtin, false) -- 2228
				return { -- 2229
					success = true, -- 2229
					children = node.children or { } -- 2229
				} -- 2229
			end -- 2225
		end -- 2225
	end -- 2225
	return { -- 2224
		success = false -- 2224
	} -- 2224
end) -- 2224
HttpServer:post("/assets/files", function(req) -- 2231
	do -- 2232
		local _type_0 = type(req) -- 2232
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2232
		if _tab_0 then -- 2232
			local path -- 2232
			do -- 2232
				local _obj_0 = req.body -- 2232
				local _type_1 = type(_obj_0) -- 2232
				if "table" == _type_1 or "userdata" == _type_1 then -- 2232
					path = _obj_0.path -- 2232
				end -- 2232
			end -- 2232
			if path ~= nil then -- 2232
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2233
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2234
				if not (workspace or builtin) then -- 2235
					return { -- 2235
						success = false -- 2235
					} -- 2235
				end -- 2235
				if not (Content:exist(path) and Content:isdir(path)) then -- 2236
					return { -- 2236
						success = false -- 2236
					} -- 2236
				end -- 2236
				local globs = { -- 2237
					"**", -- 2237
					"!**/.DS_Store", -- 2237
					"!**/.godot/**" -- 2237
				} -- 2237
				if workspace then -- 2238
					globs = { -- 2240
						"**", -- 2240
						"!**/.DS_Store", -- 2240
						"!**/.upload/**", -- 2241
						"!**/.download/**", -- 2241
						"!**/.www/**", -- 2242
						"!**/.build/**", -- 2242
						"!**/.git/**", -- 2243
						"!**/.cache/**", -- 2243
						"!**/.godot/**", -- 2244
						"!**/node_modules/**" -- 2245
					} -- 2239
				end -- 2238
				local files -- 2247
				do -- 2247
					local _accum_0 = { } -- 2247
					local _len_0 = 1 -- 2247
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2247
					for _index_0 = 1, #_list_0 do -- 2247
						local file = _list_0[_index_0] -- 2247
						_accum_0[_len_0] = Path(path, file) -- 2247
						_len_0 = _len_0 + 1 -- 2247
					end -- 2247
					files = _accum_0 -- 2247
				end -- 2247
				return { -- 2248
					success = true, -- 2248
					files = files -- 2248
				} -- 2248
			end -- 2232
		end -- 2232
	end -- 2232
	return { -- 2231
		success = false -- 2231
	} -- 2231
end) -- 2231
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2289
	local _tab_0 = { -- 2289
		{ -- 2290
			key = Path(Content.assetPath), -- 2290
			dir = true, -- 2291
			builtin = true, -- 2292
			title = zh and "内置资源" or "Built-in", -- 2293
			children = builtinChildren -- 2294
		} -- 2289
	} -- 2296
	local _obj_0 = workspace.children or { } -- 2296
	local _idx_0 = #_tab_0 + 1 -- 2296
	for _index_0 = 1, #_obj_0 do -- 2296
		local _value_0 = _obj_0[_index_0] -- 2296
		_tab_0[_idx_0] = _value_0 -- 2296
		_idx_0 = _idx_0 + 1 -- 2296
	end -- 2296
	return _tab_0 -- 2289
end -- 2289
HttpServer:post("/assets", function() -- 2250
	local Entry = require("Script.Dev.Entry") -- 2251
	local engineDev = Entry.getEngineDev() -- 2252
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2253
	local zh = (App.locale:match("^zh") ~= nil) -- 2254
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2255
	readme.title = zh and "说明文档" or "Readme" -- 2256
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2257
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2258
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2259
	tools.title = zh and "开发工具" or "Tools" -- 2260
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2261
	font.title = zh and "字体" or "Font" -- 2262
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2263
	lib.title = zh and "程序库" or "Lib" -- 2264
	if engineDev then -- 2265
		local _list_0 = lib.children -- 2266
		for _index_0 = 1, #_list_0 do -- 2266
			local child = _list_0[_index_0] -- 2266
			if not (child.title == "Dora") then -- 2267
				goto _continue_0 -- 2267
			end -- 2267
			local title = zh and "zh-Hans" or "en" -- 2268
			do -- 2269
				local _accum_0 = { } -- 2269
				local _len_0 = 1 -- 2269
				local _list_1 = child.children -- 2269
				for _index_1 = 1, #_list_1 do -- 2269
					local c = _list_1[_index_1] -- 2269
					if c.title ~= title then -- 2269
						_accum_0[_len_0] = c -- 2269
						_len_0 = _len_0 + 1 -- 2269
					end -- 2269
				end -- 2269
				child.children = _accum_0 -- 2269
			end -- 2269
			break -- 2270
			::_continue_0:: -- 2267
		end -- 2266
	else -- 2272
		local _accum_0 = { } -- 2272
		local _len_0 = 1 -- 2272
		local _list_0 = lib.children -- 2272
		for _index_0 = 1, #_list_0 do -- 2272
			local child = _list_0[_index_0] -- 2272
			if child.title ~= "Dora" then -- 2272
				_accum_0[_len_0] = child -- 2272
				_len_0 = _len_0 + 1 -- 2272
			end -- 2272
		end -- 2272
		lib.children = _accum_0 -- 2272
	end -- 2265
	local builtinChildren = { -- 2273
		readme, -- 2273
		apiDoc, -- 2273
		tools, -- 2273
		font, -- 2273
		lib -- 2273
	} -- 2273
	if engineDev then -- 2274
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2275
		do -- 2276
			local _obj_0 = dev.children -- 2276
			_obj_0[#_obj_0 + 1] = { -- 2277
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2277
				dir = false, -- 2278
				builtin = true, -- 2279
				title = "init.yue" -- 2280
			} -- 2276
		end -- 2276
		builtinChildren[#builtinChildren + 1] = dev -- 2282
	end -- 2274
	return { -- 2284
		key = Content.writablePath, -- 2284
		dir = true, -- 2285
		root = true, -- 2286
		title = "Assets", -- 2287
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2288
	} -- 2283
end) -- 2250
HttpServer:post("/entry/list", function(req) -- 2300
	local Entry = require("Script.Dev.Entry") -- 2301
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2302
	res.success = true -- 2303
	return res -- 2304
end) -- 2300
HttpServer:post("/run/status", function() -- 2306
	local Entry = require("Script.Dev.Entry") -- 2307
	return Entry.getCurrentEntryStatus() -- 2308
end) -- 2306
HttpServer:postSchedule("/run", function(req) -- 2310
	do -- 2311
		local _type_0 = type(req) -- 2311
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2311
		if _tab_0 then -- 2311
			local file -- 2311
			do -- 2311
				local _obj_0 = req.body -- 2311
				local _type_1 = type(_obj_0) -- 2311
				if "table" == _type_1 or "userdata" == _type_1 then -- 2311
					file = _obj_0.file -- 2311
				end -- 2311
			end -- 2311
			local asProj -- 2311
			do -- 2311
				local _obj_0 = req.body -- 2311
				local _type_1 = type(_obj_0) -- 2311
				if "table" == _type_1 or "userdata" == _type_1 then -- 2311
					asProj = _obj_0.asProj -- 2311
				end -- 2311
			end -- 2311
			if file ~= nil and asProj ~= nil then -- 2311
				if not Content:isAbsolutePath(file) then -- 2312
					local devFile = Path(Content.writablePath, file) -- 2313
					if Content:exist(devFile) then -- 2314
						file = devFile -- 2314
					end -- 2314
				end -- 2312
				local Entry = require("Script.Dev.Entry") -- 2315
				local workDir -- 2316
				if asProj then -- 2317
					local projectRoot = req.body.projectRoot -- 2318
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2319
						workDir = projectRoot -- 2320
					else -- 2322
						workDir = getProjectDirFromFile(file) -- 2322
					end -- 2319
					if workDir then -- 2323
						Entry.allClear() -- 2324
						local target = Path(workDir, "init") -- 2325
						local runId = Entry.getCurrentEntryStatus().runId + 1 -- 2326
						local success, err = Entry.enterEntryAsync({ -- 2327
							entryName = "Project", -- 2327
							fileName = target, -- 2327
							workDir = workDir, -- 2327
							projectRoot = workDir, -- 2327
							runKind = "project" -- 2327
						}) -- 2327
						if success and not err and req.body.waitForFrame == true then -- 2328
							local RunTransition = require("Script.Dev.RunTransition") -- 2329
							success, err = RunTransition.waitForFrameAsync(Entry, runId, Content:exist(Path(workDir, "project.godot"))) -- 2330
						end -- 2328
						target = Path:getName(Path:getPath(target)) -- 2331
						return { -- 2332
							success = success, -- 2332
							target = target, -- 2332
							err = err -- 2332
						} -- 2332
					end -- 2323
				else -- 2334
					workDir = getProjectDirFromFile(file) -- 2334
					if not workDir and Path:getExt(file) == "wasm" then -- 2335
						local parent = Path:getPath(file) -- 2336
						if Content:exist(Path(parent, "wa.mod")) then -- 2337
							workDir = parent -- 2338
						end -- 2337
					end -- 2335
				end -- 2317
				Entry.allClear() -- 2339
				file = Path:replaceExt(file, "") -- 2340
				local entry = { -- 2342
					entryName = Path:getName(file), -- 2342
					fileName = file, -- 2343
					runKind = "file" -- 2344
				} -- 2341
				if workDir then -- 2345
					entry.workDir = workDir -- 2346
					entry.projectRoot = workDir -- 2347
				end -- 2345
				local runId = Entry.getCurrentEntryStatus().runId + 1 -- 2348
				local success, err = Entry.enterEntryAsync(entry) -- 2349
				if success and not err and req.body.waitForFrame == true then -- 2350
					local RunTransition = require("Script.Dev.RunTransition") -- 2351
					success, err = RunTransition.waitForFrameAsync(Entry, runId, workDir and Content:exist(Path(workDir, "project.godot"))) -- 2352
				end -- 2350
				return { -- 2353
					success = success, -- 2353
					err = err -- 2353
				} -- 2353
			end -- 2311
		end -- 2311
	end -- 2311
	return { -- 2310
		success = false -- 2310
	} -- 2310
end) -- 2310
local _anon_func_7 = function(result) -- 2395
	if result.success then -- 2395
		return nil -- 2395
	else -- 2395
		return "PREVIEW_FAILED" -- 2395
	end -- 2395
end -- 2395
HttpServer:postSchedule("/agent/preview", function(req) -- 2355
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
			local projectRoot -- 2358
			do -- 2358
				local _obj_0 = req.body -- 2358
				local _type_1 = type(_obj_0) -- 2358
				if "table" == _type_1 or "userdata" == _type_1 then -- 2358
					projectRoot = _obj_0.projectRoot -- 2358
				end -- 2358
			end -- 2358
			if projectRoot ~= nil then -- 2358
				if not getProjectSourceRoot(projectRoot) then -- 2359
					return { -- 2359
						success = false, -- 2359
						code = "INVALID_PROJECT", -- 2359
						message = "projectRoot must be an existing absolute directory" -- 2359
					} -- 2359
				end -- 2359
				local entryFile = req.body.entry or "init.lua" -- 2360
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2361
					return { -- 2361
						success = false, -- 2361
						code = "INVALID_ENTRY", -- 2361
						message = "entry must be a non-empty project-relative path" -- 2361
					} -- 2361
				end -- 2361
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2362
					0.5 -- 2362
				} -- 2362
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2363
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2364
					return { -- 2364
						success = false, -- 2364
						code = "INVALID_QUEUE_TIMEOUT", -- 2364
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2364
					} -- 2364
				end -- 2364
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2365
				local AgentOperation = require("Agent.Tool.Operation") -- 2366
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2367
				local requestId = AgentOperation.createOperationId() -- 2368
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2369
				if not enqueued.success then -- 2370
					return { -- 2370
						success = false, -- 2370
						code = "ENTRY_QUEUE_REJECTED", -- 2370
						message = enqueued.message -- 2370
					} -- 2370
				end -- 2370
				local queuedAt = App.runningTime -- 2371
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2372
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2373
						local state = agentEntryRunQueue:get(requestId) -- 2374
						agentEntryRunQueue:cancel(requestId) -- 2375
						return { -- 2377
							success = false, -- 2377
							code = "ENTRY_QUEUE_TIMEOUT", -- 2378
							message = "timed out waiting for the Dora entry runtime", -- 2379
							requestId = requestId, -- 2380
							queuePosition = state.position -- 2381
						} -- 2376
					end -- 2373
					sleep() -- 2382
				end -- 2372
				local queueWaitSeconds = App.runningTime - queuedAt -- 2383
				local _ <close> = setmetatable({ }, { -- 2384
					__close = function() -- 2384
						return agentEntryRunQueue:release(requestId) -- 2384
					end -- 2384
				}) -- 2384
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2385
				local Entry = require("Script.Dev.Entry") -- 2386
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2388
					workDir = projectRoot, -- 2388
					operationId = requestId, -- 2389
					print = function() end -- 2390
				}, Entry) -- 2387
				local result = preview({ -- 2392
					entry = entryFile, -- 2392
					captureAtSeconds = captureAtSeconds -- 2392
				}) -- 2392
				return { -- 2394
					success = result.success, -- 2394
					code = _anon_func_7(result), -- 2395
					message = result.message, -- 2396
					requestId = requestId, -- 2397
					queueWaitSeconds = queueWaitSeconds, -- 2398
					interruptedUserRun = result.interruptedUserRun, -- 2399
					files = result.files, -- 2400
					frames = result.frames -- 2401
				} -- 2393
			end -- 2358
		end -- 2358
	end -- 2358
	return { -- 2355
		success = false, -- 2355
		message = "invalid call" -- 2355
	} -- 2355
end) -- 2355
HttpServer:postSchedule("/agent/command", function(req) -- 2403
	local releaseAgent = AgentHost.acquire() -- 2404
	local _ <close> = setmetatable({ }, { -- 2405
		__close = function() -- 2405
			return releaseAgent() -- 2405
		end -- 2405
	}) -- 2405
	do -- 2406
		local _type_0 = type(req) -- 2406
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2406
		if _tab_0 then -- 2406
			local body = req.body -- 2406
			if body ~= nil then -- 2406
				local projectRoot = body.projectRoot -- 2407
				if not getProjectSourceRoot(projectRoot) then -- 2408
					return { -- 2408
						success = false, -- 2408
						code = "INVALID_PROJECT", -- 2408
						message = "projectRoot must be an existing absolute directory" -- 2408
					} -- 2408
				end -- 2408
				local AgentValidation = require("Agent.Tool.Validation") -- 2409
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2410
				if not validated.success then -- 2411
					return { -- 2411
						success = false, -- 2411
						code = "INVALID_COMMAND", -- 2411
						message = validated.message -- 2411
					} -- 2411
				end -- 2411
				local input = validated.value -- 2412
				local AgentCommand = require("Agent.Tool.Command") -- 2413
				local result = nil -- 2414
				local failure = nil -- 2415
				local promise = AgentCommand.executeCommand({ -- 2417
					workDir = projectRoot, -- 2417
					mode = input.mode, -- 2418
					code = input.code, -- 2419
					command = input.command, -- 2420
					cwd = input.cwd, -- 2421
					timeoutSeconds = input.timeoutSeconds -- 2422
				}) -- 2416
				promise:addCallbacks((function(_, value) -- 2423
					result = value -- 2423
				end), (function(_, err) -- 2423
					failure = tostring(err) -- 2423
				end)) -- 2423
				wait(function() -- 2424
					return result ~= nil or failure ~= nil -- 2424
				end) -- 2424
				if failure then -- 2425
					return { -- 2425
						success = false, -- 2425
						code = "COMMAND_BRIDGE_FAILED", -- 2425
						message = failure -- 2425
					} -- 2425
				end -- 2425
				if not result.success then -- 2426
					result.code = "COMMAND_FAILED" -- 2427
				end -- 2426
				return result -- 2428
			end -- 2406
		end -- 2406
	end -- 2406
	return { -- 2403
		success = false, -- 2403
		code = "INVALID_COMMAND", -- 2403
		message = "invalid call" -- 2403
	} -- 2403
end) -- 2403
HttpServer:postSchedule("/stop", function() -- 2430
	local Entry = require("Script.Dev.Entry") -- 2431
	return { -- 2432
		success = Entry.stop() -- 2432
	} -- 2432
end) -- 2430
local minifyAsync -- 2434
minifyAsync = function(sourcePath, minifyPath) -- 2434
	if not Content:exist(sourcePath) then -- 2435
		return -- 2435
	end -- 2435
	local Entry = require("Script.Dev.Entry") -- 2436
	local errors = { } -- 2437
	local files = Entry.getAllFiles(sourcePath, { -- 2438
		"lua" -- 2438
	}, true) -- 2438
	do -- 2439
		local _accum_0 = { } -- 2439
		local _len_0 = 1 -- 2439
		for _index_0 = 1, #files do -- 2439
			local file = files[_index_0] -- 2439
			if file:sub(1, 1) ~= '.' then -- 2439
				_accum_0[_len_0] = file -- 2439
				_len_0 = _len_0 + 1 -- 2439
			end -- 2439
		end -- 2439
		files = _accum_0 -- 2439
	end -- 2439
	local paths -- 2440
	do -- 2440
		local _tbl_0 = { } -- 2440
		for _index_0 = 1, #files do -- 2440
			local file = files[_index_0] -- 2440
			_tbl_0[Path:getPath(file)] = true -- 2440
		end -- 2440
		paths = _tbl_0 -- 2440
	end -- 2440
	for path in pairs(paths) do -- 2441
		Content:mkdir(Path(minifyPath, path)) -- 2441
	end -- 2441
	local _ <close> = setmetatable({ }, { -- 2442
		__close = function() -- 2442
			package.loaded["luaminify.FormatMini"] = nil -- 2443
			package.loaded["luaminify.ParseLua"] = nil -- 2444
			package.loaded["luaminify.Scope"] = nil -- 2445
			package.loaded["luaminify.Util"] = nil -- 2446
		end -- 2442
	}) -- 2442
	local FormatMini -- 2447
	do -- 2447
		local _obj_0 = require("luaminify") -- 2447
		FormatMini = _obj_0.FormatMini -- 2447
	end -- 2447
	local fileCount = #files -- 2448
	local count = 0 -- 2449
	for _index_0 = 1, #files do -- 2450
		local file = files[_index_0] -- 2450
		thread(function() -- 2451
			local _ <close> = setmetatable({ }, { -- 2452
				__close = function() -- 2452
					count = count + 1 -- 2452
				end -- 2452
			}) -- 2452
			local input = Path(sourcePath, file) -- 2453
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2454
			if Content:exist(input) then -- 2455
				local sourceCodes = Content:loadAsync(input) -- 2456
				local res, err = FormatMini(sourceCodes) -- 2457
				if res then -- 2458
					Content:saveAsync(output, res) -- 2459
					return print("Minify " .. tostring(file)) -- 2460
				else -- 2462
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2462
				end -- 2458
			else -- 2464
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2464
			end -- 2455
		end) -- 2451
		sleep() -- 2465
	end -- 2450
	wait(function() -- 2466
		return count == fileCount -- 2466
	end) -- 2466
	if #errors > 0 then -- 2467
		print(table.concat(errors, '\n')) -- 2468
	end -- 2467
	print("Obfuscation done.") -- 2469
	return files -- 2470
end -- 2434
local zipping = false -- 2472
HttpServer:postSchedule("/zip", function(req) -- 2474
	do -- 2475
		local _type_0 = type(req) -- 2475
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2475
		if _tab_0 then -- 2475
			local path -- 2475
			do -- 2475
				local _obj_0 = req.body -- 2475
				local _type_1 = type(_obj_0) -- 2475
				if "table" == _type_1 or "userdata" == _type_1 then -- 2475
					path = _obj_0.path -- 2475
				end -- 2475
			end -- 2475
			local zipFile -- 2475
			do -- 2475
				local _obj_0 = req.body -- 2475
				local _type_1 = type(_obj_0) -- 2475
				if "table" == _type_1 or "userdata" == _type_1 then -- 2475
					zipFile = _obj_0.zipFile -- 2475
				end -- 2475
			end -- 2475
			local obfuscated -- 2475
			do -- 2475
				local _obj_0 = req.body -- 2475
				local _type_1 = type(_obj_0) -- 2475
				if "table" == _type_1 or "userdata" == _type_1 then -- 2475
					obfuscated = _obj_0.obfuscated -- 2475
				end -- 2475
			end -- 2475
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2475
				if zipping then -- 2476
					goto failed -- 2476
				end -- 2476
				zipping = true -- 2477
				local _ <close> = setmetatable({ }, { -- 2478
					__close = function() -- 2478
						zipping = false -- 2478
					end -- 2478
				}) -- 2478
				if not Content:exist(path) then -- 2479
					goto failed -- 2479
				end -- 2479
				Content:mkdir(Path:getPath(zipFile)) -- 2480
				if obfuscated then -- 2481
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2482
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2483
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2484
					Content:remove(scriptPath) -- 2485
					Content:remove(obfuscatedPath) -- 2486
					Content:remove(tempPath) -- 2487
					Content:mkdir(scriptPath) -- 2488
					Content:mkdir(obfuscatedPath) -- 2489
					Content:mkdir(tempPath) -- 2490
					if not Content:copyAsync(path, tempPath) then -- 2491
						goto failed -- 2491
					end -- 2491
					local Entry = require("Script.Dev.Entry") -- 2492
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2493
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2494
						"tl", -- 2494
						"yue", -- 2494
						"lua", -- 2494
						"ts", -- 2494
						"tsx", -- 2494
						"vs", -- 2494
						"bl", -- 2494
						"xml", -- 2494
						"wa", -- 2494
						"mod" -- 2494
					}, true) -- 2494
					for _index_0 = 1, #scriptFiles do -- 2495
						local file = scriptFiles[_index_0] -- 2495
						Content:remove(Path(tempPath, file)) -- 2496
					end -- 2495
					for _index_0 = 1, #luaFiles do -- 2497
						local file = luaFiles[_index_0] -- 2497
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2498
					end -- 2497
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2499
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2500
					end) then -- 2499
						goto failed -- 2499
					end -- 2499
					return { -- 2501
						success = true -- 2501
					} -- 2501
				else -- 2503
					return { -- 2503
						success = Content:zipAsync(path, zipFile, function(file) -- 2503
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2504
						end) -- 2503
					} -- 2503
				end -- 2481
			end -- 2475
		end -- 2475
	end -- 2475
	::failed:: -- 2505
	return { -- 2474
		success = false -- 2474
	} -- 2474
end) -- 2474
HttpServer:postSchedule("/unzip", function(req) -- 2507
	do -- 2508
		local _type_0 = type(req) -- 2508
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2508
		if _tab_0 then -- 2508
			local zipFile -- 2508
			do -- 2508
				local _obj_0 = req.body -- 2508
				local _type_1 = type(_obj_0) -- 2508
				if "table" == _type_1 or "userdata" == _type_1 then -- 2508
					zipFile = _obj_0.zipFile -- 2508
				end -- 2508
			end -- 2508
			local path -- 2508
			do -- 2508
				local _obj_0 = req.body -- 2508
				local _type_1 = type(_obj_0) -- 2508
				if "table" == _type_1 or "userdata" == _type_1 then -- 2508
					path = _obj_0.path -- 2508
				end -- 2508
			end -- 2508
			if zipFile ~= nil and path ~= nil then -- 2508
				return { -- 2509
					success = Content:unzipAsync(zipFile, path, function(file) -- 2509
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2510
					end) -- 2509
				} -- 2509
			end -- 2508
		end -- 2508
	end -- 2508
	return { -- 2507
		success = false -- 2507
	} -- 2507
end) -- 2507
HttpServer:post("/editing-info", function(req) -- 2512
	local Entry = require("Script.Dev.Entry") -- 2513
	local config = Entry.getConfig() -- 2514
	local _type_0 = type(req) -- 2515
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2515
	local _match_0 = false -- 2515
	if _tab_0 then -- 2515
		local editingInfo -- 2515
		do -- 2515
			local _obj_0 = req.body -- 2515
			local _type_1 = type(_obj_0) -- 2515
			if "table" == _type_1 or "userdata" == _type_1 then -- 2515
				editingInfo = _obj_0.editingInfo -- 2515
			end -- 2515
		end -- 2515
		if editingInfo ~= nil then -- 2515
			_match_0 = true -- 2515
			config.editingInfo = editingInfo -- 2516
			return { -- 2517
				success = true -- 2517
			} -- 2517
		end -- 2515
	end -- 2515
	if not _match_0 then -- 2515
		if not (config.editingInfo ~= nil) then -- 2519
			local folder -- 2520
			if App.locale:match('^zh') then -- 2520
				folder = 'zh-Hans' -- 2520
			else -- 2520
				folder = 'en' -- 2520
			end -- 2520
			config.editingInfo = json.encode({ -- 2522
				index = 0, -- 2522
				files = { -- 2524
					{ -- 2525
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2525
						title = "welcome.md" -- 2526
					} -- 2524
				} -- 2523
			}) -- 2521
		end -- 2519
		return { -- 2530
			success = true, -- 2530
			editingInfo = config.editingInfo -- 2530
		} -- 2530
	end -- 2515
end) -- 2512
HttpServer:post("/command", function(req) -- 2532
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
			local log -- 2533
			do -- 2533
				local _obj_0 = req.body -- 2533
				local _type_1 = type(_obj_0) -- 2533
				if "table" == _type_1 or "userdata" == _type_1 then -- 2533
					log = _obj_0.log -- 2533
				end -- 2533
			end -- 2533
			if code ~= nil and log ~= nil then -- 2533
				emit("AppCommand", code, log) -- 2534
				return { -- 2535
					success = true -- 2535
				} -- 2535
			end -- 2533
		end -- 2533
	end -- 2533
	return { -- 2532
		success = false -- 2532
	} -- 2532
end) -- 2532
HttpServer:post("/log/save", function() -- 2537
	local folder = ".download" -- 2538
	local fullLogFile = "dora_full_logs.txt" -- 2539
	local fullFolder = Path(Content.writablePath, folder) -- 2540
	Content:mkdir(fullFolder) -- 2541
	local logPath = Path(fullFolder, fullLogFile) -- 2542
	if App:saveLog(logPath) then -- 2543
		return { -- 2544
			success = true, -- 2544
			path = Path(folder, fullLogFile) -- 2544
		} -- 2544
	end -- 2543
	return { -- 2537
		success = false -- 2537
	} -- 2537
end) -- 2537
local tailLines -- 2546
tailLines = function(text, count) -- 2546
	local lines = { } -- 2547
	text = text:gsub("\r\n", "\n") -- 2548
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2549
		lines[#lines + 1] = line -- 2550
	end -- 2549
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2551
		table.remove(lines) -- 2552
	end -- 2551
	local start = math.max(1, #lines - count + 1) -- 2553
	local out = { } -- 2554
	for i = start, #lines do -- 2555
		out[#out + 1] = lines[i] -- 2556
	end -- 2555
	return table.concat(out, "\n") -- 2557
end -- 2546
HttpServer:post("/log", function(req) -- 2559
	local count = 100 -- 2560
	if req and req.body and req.body.count ~= nil then -- 2561
		count = req.body.count -- 2562
	end -- 2561
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2563
		return { -- 2564
			success = false, -- 2564
			message = "count must be a positive integer" -- 2564
		} -- 2564
	end -- 2563
	local folder = ".download" -- 2565
	local fullLogFile = "dora_full_logs.txt" -- 2566
	local fullFolder = Path(Content.writablePath, folder) -- 2567
	Content:mkdir(fullFolder) -- 2568
	local logPath = Path(fullFolder, fullLogFile) -- 2569
	if App:saveLog(logPath) then -- 2570
		local text = Content:load(logPath) -- 2571
		if text then -- 2572
			return { -- 2573
				success = true, -- 2573
				log = tailLines(text, count) -- 2573
			} -- 2573
		else -- 2575
			return { -- 2575
				success = false, -- 2575
				message = "failed to read log" -- 2575
			} -- 2575
		end -- 2572
	else -- 2577
		return { -- 2577
			success = false, -- 2577
			message = "failed to save log" -- 2577
		} -- 2577
	end -- 2570
	return { -- 2559
		success = false -- 2559
	} -- 2559
end) -- 2559
HttpServer:post("/yarn/check", function(req) -- 2579
	local yarncompile = require("yarncompile") -- 2580
	do -- 2581
		local _type_0 = type(req) -- 2581
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2581
		if _tab_0 then -- 2581
			local code -- 2581
			do -- 2581
				local _obj_0 = req.body -- 2581
				local _type_1 = type(_obj_0) -- 2581
				if "table" == _type_1 or "userdata" == _type_1 then -- 2581
					code = _obj_0.code -- 2581
				end -- 2581
			end -- 2581
			if code ~= nil then -- 2581
				local jsonObject = json.decode(code) -- 2582
				if jsonObject then -- 2582
					local errors = { } -- 2583
					local _list_0 = jsonObject.nodes -- 2584
					for _index_0 = 1, #_list_0 do -- 2584
						local node = _list_0[_index_0] -- 2584
						local title, body = node.title, node.body -- 2585
						local luaCode, err = yarncompile(body) -- 2586
						if not luaCode then -- 2586
							errors[#errors + 1] = title .. ":" .. err -- 2587
						end -- 2586
					end -- 2584
					return { -- 2588
						success = true, -- 2588
						syntaxError = table.concat(errors, "\n\n") -- 2588
					} -- 2588
				end -- 2582
			end -- 2581
		end -- 2581
	end -- 2581
	return { -- 2579
		success = false -- 2579
	} -- 2579
end) -- 2579
HttpServer:post("/yarn/check-file", function(req) -- 2590
	local yarncompile = require("yarncompile") -- 2591
	do -- 2592
		local _type_0 = type(req) -- 2592
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2592
		if _tab_0 then -- 2592
			local code -- 2592
			do -- 2592
				local _obj_0 = req.body -- 2592
				local _type_1 = type(_obj_0) -- 2592
				if "table" == _type_1 or "userdata" == _type_1 then -- 2592
					code = _obj_0.code -- 2592
				end -- 2592
			end -- 2592
			if code ~= nil then -- 2592
				local res, _, err = yarncompile(code, true) -- 2593
				if not res then -- 2593
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2594
					return { -- 2595
						success = false, -- 2595
						message = message, -- 2595
						line = line, -- 2595
						column = column, -- 2595
						node = node -- 2595
					} -- 2595
				end -- 2593
			end -- 2592
		end -- 2592
	end -- 2592
	return { -- 2590
		success = true -- 2590
	} -- 2590
end) -- 2590
getWaProjectDirFromFile = function(file) -- 2597
	local current -- 2598
	if Content:isdir(file) then -- 2598
		current = file -- 2598
	else -- 2598
		current = Path:getPath(file) -- 2598
	end -- 2598
	if current == "" then -- 2599
		return nil -- 2599
	end -- 2599
	repeat -- 2600
		local modPath = Path(current, "wa.mod") -- 2601
		if Content:exist(modPath) then -- 2602
			return current, modPath -- 2603
		end -- 2602
		local parent = Path:getPath(current) -- 2604
		if parent == "" or parent == current then -- 2605
			break -- 2605
		end -- 2605
		current = parent -- 2606
	until false -- 2600
	return nil -- 2608
end -- 2597
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2610
	do -- 2611
		local _type_0 = type(req) -- 2611
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2611
		if _tab_0 then -- 2611
			local path -- 2611
			do -- 2611
				local _obj_0 = req.body -- 2611
				local _type_1 = type(_obj_0) -- 2611
				if "table" == _type_1 or "userdata" == _type_1 then -- 2611
					path = _obj_0.path -- 2611
				end -- 2611
			end -- 2611
			if path ~= nil then -- 2611
				local projDir = getWaProjectDirFromFile(path) -- 2612
				if projDir then -- 2612
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2613
					if not Content:exist(sourceDoraPath) then -- 2614
						return { -- 2615
							success = false, -- 2615
							message = "missing dora template" -- 2615
						} -- 2615
					end -- 2614
					local targetVendorPath = Path(projDir, "vendor") -- 2616
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2617
					if not Content:exist(targetVendorPath) then -- 2618
						if not Content:mkdir(targetVendorPath) then -- 2619
							return { -- 2620
								success = false, -- 2620
								message = "failed to create vendor folder" -- 2620
							} -- 2620
						end -- 2619
					elseif not Content:isdir(targetVendorPath) then -- 2621
						return { -- 2622
							success = false, -- 2622
							message = "vendor path is not a folder" -- 2622
						} -- 2622
					end -- 2618
					if Content:exist(targetDoraPath) then -- 2623
						if not Content:remove(targetDoraPath) then -- 2624
							return { -- 2625
								success = false, -- 2625
								message = "failed to remove old dora" -- 2625
							} -- 2625
						end -- 2624
					end -- 2623
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2626
						return { -- 2627
							success = false, -- 2627
							message = "failed to copy dora" -- 2627
						} -- 2627
					end -- 2626
					return { -- 2628
						success = true -- 2628
					} -- 2628
				else -- 2630
					return { -- 2630
						success = false, -- 2630
						message = 'Wa file needs a project' -- 2630
					} -- 2630
				end -- 2612
			end -- 2611
		end -- 2611
	end -- 2611
	return { -- 2610
		success = false, -- 2610
		message = "invalid call" -- 2610
	} -- 2610
end) -- 2610
HttpServer:postSchedule("/wa/build", function(req) -- 2632
	do -- 2633
		local _type_0 = type(req) -- 2633
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2633
		if _tab_0 then -- 2633
			local path -- 2633
			do -- 2633
				local _obj_0 = req.body -- 2633
				local _type_1 = type(_obj_0) -- 2633
				if "table" == _type_1 or "userdata" == _type_1 then -- 2633
					path = _obj_0.path -- 2633
				end -- 2633
			end -- 2633
			if path ~= nil then -- 2633
				local projDir = getWaProjectDirFromFile(path) -- 2634
				if projDir then -- 2634
					local message = Wasm:buildWaAsync(projDir) -- 2635
					if message == "" then -- 2636
						return { -- 2637
							success = true -- 2637
						} -- 2637
					else -- 2639
						return { -- 2639
							success = false, -- 2639
							message = message -- 2639
						} -- 2639
					end -- 2636
				else -- 2641
					return { -- 2641
						success = false, -- 2641
						message = 'Wa file needs a project' -- 2641
					} -- 2641
				end -- 2634
			end -- 2633
		end -- 2633
	end -- 2633
	return { -- 2642
		success = false, -- 2642
		message = 'failed to build' -- 2642
	} -- 2642
end) -- 2632
HttpServer:postSchedule("/wa/format", function(req) -- 2644
	do -- 2645
		local _type_0 = type(req) -- 2645
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2645
		if _tab_0 then -- 2645
			local file -- 2645
			do -- 2645
				local _obj_0 = req.body -- 2645
				local _type_1 = type(_obj_0) -- 2645
				if "table" == _type_1 or "userdata" == _type_1 then -- 2645
					file = _obj_0.file -- 2645
				end -- 2645
			end -- 2645
			if file ~= nil then -- 2645
				local code = Wasm:formatWaAsync(file) -- 2646
				if code == "" then -- 2647
					return { -- 2648
						success = false -- 2648
					} -- 2648
				else -- 2650
					return { -- 2650
						success = true, -- 2650
						code = code -- 2650
					} -- 2650
				end -- 2647
			end -- 2645
		end -- 2645
	end -- 2645
	return { -- 2651
		success = false -- 2651
	} -- 2651
end) -- 2644
HttpServer:postSchedule("/wa/create", function(req) -- 2653
	do -- 2654
		local _type_0 = type(req) -- 2654
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2654
		if _tab_0 then -- 2654
			local path -- 2654
			do -- 2654
				local _obj_0 = req.body -- 2654
				local _type_1 = type(_obj_0) -- 2654
				if "table" == _type_1 or "userdata" == _type_1 then -- 2654
					path = _obj_0.path -- 2654
				end -- 2654
			end -- 2654
			if path ~= nil then -- 2654
				if not Content:exist(Path:getPath(path)) then -- 2655
					return { -- 2656
						success = false, -- 2656
						message = "target path not existed" -- 2656
					} -- 2656
				end -- 2655
				if Content:exist(path) then -- 2657
					return { -- 2658
						success = false, -- 2658
						message = "target project folder existed" -- 2658
					} -- 2658
				end -- 2657
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2659
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2660
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2661
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2662
					return { -- 2665
						success = false, -- 2665
						message = "missing template project" -- 2665
					} -- 2665
				end -- 2662
				if not Content:mkdir(path) then -- 2666
					return { -- 2667
						success = false, -- 2667
						message = "failed to create project folder" -- 2667
					} -- 2667
				end -- 2666
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2668
					Content:remove(path) -- 2669
					return { -- 2670
						success = false, -- 2670
						message = "failed to copy template" -- 2670
					} -- 2670
				end -- 2668
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2671
					Content:remove(path) -- 2672
					return { -- 2673
						success = false, -- 2673
						message = "failed to copy template" -- 2673
					} -- 2673
				end -- 2671
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2674
					Content:remove(path) -- 2675
					return { -- 2676
						success = false, -- 2676
						message = "failed to copy template" -- 2676
					} -- 2676
				end -- 2674
				return { -- 2677
					success = true -- 2677
				} -- 2677
			end -- 2654
		end -- 2654
	end -- 2654
	return { -- 2653
		success = false, -- 2653
		message = "invalid call" -- 2653
	} -- 2653
end) -- 2653
local tsBuildGlobs = { -- 2680
	"**/*.ts", -- 2680
	"**/*.tsx", -- 2681
	"!**/.*/**", -- 2682
	"!**/node_modules/**" -- 2683
} -- 2679
local tsSnapshotGlobs = { -- 2686
	"**/*.ts", -- 2686
	"**/*.tsx", -- 2687
	"**/*.lua", -- 2688
	"!**/.*/**", -- 2689
	"!**/node_modules/**" -- 2690
} -- 2685
local collectTSVirtualFiles -- 2692
collectTSVirtualFiles = function(sourceRoot) -- 2692
	local files = { } -- 2693
	local seen = { } -- 2694
	local addFile -- 2695
	addFile = function(file, moduleName, virtualFile) -- 2695
		if moduleName == nil then -- 2695
			moduleName = nil -- 2695
		end -- 2695
		if virtualFile == nil then -- 2695
			virtualFile = nil -- 2695
		end -- 2695
		local targetFile = virtualFile or file -- 2696
		do -- 2697
			local entry = seen[targetFile] -- 2697
			if entry then -- 2697
				if moduleName and moduleName ~= "" then -- 2698
					entry.moduleName = moduleName -- 2698
				end -- 2698
				return -- 2699
			end -- 2697
		end -- 2697
		local content = Content:load(file) -- 2700
		if content then -- 2700
			local entry = { -- 2701
				file = targetFile, -- 2701
				content = content -- 2701
			} -- 2701
			if moduleName and moduleName ~= "" then -- 2702
				entry.moduleName = moduleName -- 2702
			end -- 2702
			seen[targetFile] = entry -- 2703
			files[#files + 1] = entry -- 2704
		end -- 2700
	end -- 2695
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2705
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2706
		for _index_0 = 1, #_list_0 do -- 2706
			local subFile = _list_0[_index_0] -- 2706
			addFile(Path(sourceRoot, subFile)) -- 2707
		end -- 2706
		local libraryRoots = { -- 2709
			Path(sourceRoot, "Script", "Lib"), -- 2709
			Path(sourceRoot, "Lib"), -- 2710
			Path(Content.assetPath, "Script", "Lib") -- 2711
		} -- 2708
		for _index_0 = 1, #libraryRoots do -- 2712
			local libraryRoot = libraryRoots[_index_0] -- 2712
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2713
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2714
				for _index_1 = 1, #_list_1 do -- 2714
					local subFile = _list_1[_index_1] -- 2714
					local file = Path(libraryRoot, subFile) -- 2715
					local virtualFile = Path(sourceRoot, subFile) -- 2716
					addFile(file, nil, virtualFile) -- 2717
				end -- 2714
			end -- 2713
		end -- 2712
	end -- 2705
	local locale -- 2718
	if App.locale:match('^zh') then -- 2718
		locale = 'zh-Hans' -- 2718
	else -- 2718
		locale = 'en' -- 2718
	end -- 2718
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2719
	local _list_0 = Content:getFiles(declarationRoot) -- 2720
	for _index_0 = 1, #_list_0 do -- 2720
		local file = _list_0[_index_0] -- 2720
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2721
			local fullPath = Path(declarationRoot, file) -- 2722
			local moduleName = Path:getName(Path:getName(file)) -- 2723
			addFile(fullPath, moduleName) -- 2724
		end -- 2721
	end -- 2720
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2725
	local lualibBundleTarget -- 2726
	if sourceRoot then -- 2726
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2726
	else -- 2726
		lualibBundleTarget = "lualib_bundle.lua" -- 2726
	end -- 2726
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2727
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2728
	local _list_1 = Content:getFiles(lualibRoot) -- 2729
	for _index_0 = 1, #_list_1 do -- 2729
		local file = _list_1[_index_0] -- 2729
		if Path:getExt(file) == "lua" then -- 2730
			local virtualFile -- 2731
			if sourceRoot then -- 2731
				virtualFile = Path(sourceRoot, "lualib", file) -- 2731
			else -- 2731
				virtualFile = Path("lualib", file) -- 2731
			end -- 2731
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2732
		end -- 2730
	end -- 2729
	return files -- 2733
end -- 2692
local supportsCompilerWebView -- 2735
supportsCompilerWebView = function() -- 2735
	local _val_0 = App.platform -- 2735
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2735
end -- 2735
local webIDECompilerReady = false -- 2736
local webIDEConnectionGeneration = 0 -- 2737
local tsProbeId = 0 -- 2738
local probeWebIDECompiler -- 2740
probeWebIDECompiler = function(isCancelled) -- 2740
	if HttpServer.wsConnectionCount == 0 then -- 2741
		return false -- 2741
	end -- 2741
	tsProbeId = tsProbeId + 1 -- 2742
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2743
	local generation = webIDEConnectionGeneration -- 2744
	local done, ready = false, false -- 2745
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2746
	local listener = Node() -- 2747
	listener:gslot("AppWS", function(event) -- 2748
		if event.type == "Receive" then -- 2749
			local res = json.decode(event.msg) -- 2750
			if res then -- 2750
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2751
					responses = responses + 1 -- 2752
					ready = ready or res.success == true -- 2753
					done = ready or responses >= expectedResponses -- 2754
				end -- 2751
			end -- 2750
		end -- 2749
	end) -- 2748
	emit("AppWS", "Send", json.encode({ -- 2755
		name = "TranspileTSProbe", -- 2755
		id = requestId -- 2755
	})) -- 2755
	local deadline = App.runningTime + 5 -- 2756
	wait(function() -- 2757
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2757
	end) -- 2757
	listener:removeFromParent() -- 2758
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2759
	if generation == webIDEConnectionGeneration then -- 2760
		webIDECompilerReady = ready -- 2760
	end -- 2760
	return ready -- 2761
end -- 2740
local compilerConnectionListener = Node() -- 2763
compilerConnectionListener:addTo(Director.systemUI) -- 2765
local _anon_func_8 = function(event) -- 2767
	local _val_0 = event.type -- 2767
	return "Open" == _val_0 or "Close" == _val_0 -- 2767
end -- 2767
compilerConnectionListener:gslot("AppWS", function(event) -- 2766
	if _anon_func_8(event) then -- 2767
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2768
		webIDECompilerReady = false -- 2769
		if HttpServer.wsConnectionCount > 0 then -- 2770
			return thread(function() -- 2771
				return probeWebIDECompiler() -- 2771
			end) -- 2771
		end -- 2770
	end -- 2767
end) -- 2766
local _anon_func_9 = function(res) -- 2796
	if res.success then -- 2796
		return "tool" -- 2796
	else -- 2796
		return res.failureKind -- 2796
	end -- 2796
end -- 2796
local transpileTSFileWithWebIDE -- 2773
do -- 2773
	local tsBuildRequestId = 0 -- 2774
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2775
		if not probeWebIDECompiler(isCancelled) then -- 2776
			if isCancelled and isCancelled() then -- 2777
				return { -- 2778
					success = false, -- 2778
					file = file, -- 2778
					message = "build canceled", -- 2778
					interrupted = true -- 2778
				} -- 2778
			end -- 2777
			return { -- 2779
				success = false, -- 2779
				file = file, -- 2779
				message = "TypeScript transpiler is not ready", -- 2779
				failureKind = "tool" -- 2779
			} -- 2779
		end -- 2776
		tsBuildRequestId = tsBuildRequestId + 1 -- 2780
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2781
		local done = false -- 2782
		local result = nil -- 2783
		local listener = Node() -- 2784
		listener:gslot("AppWS", function(event) -- 2785
			if event.type == "Receive" then -- 2786
				local res = json.decode(event.msg) -- 2787
				if res then -- 2787
					if res.name == "TranspileTS" and res.id == requestId then -- 2788
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2789
							local luaFile = Path:replaceExt(file, "lua") -- 2790
							if Content:save(luaFile, res.luaCode) then -- 2791
								result = { -- 2792
									success = true, -- 2792
									file = file -- 2792
								} -- 2792
							else -- 2794
								result = { -- 2794
									success = false, -- 2794
									file = file, -- 2794
									message = "failed to save " .. tostring(luaFile) -- 2794
								} -- 2794
							end -- 2791
						else -- 2796
							result = { -- 2796
								success = false, -- 2796
								file = file, -- 2796
								message = res.message or "Compiler returned no Lua output", -- 2796
								failureKind = _anon_func_9(res) -- 2796
							} -- 2796
						end -- 2789
						done = true -- 2797
					end -- 2788
				end -- 2787
			end -- 2786
		end) -- 2785
		emit("AppWS", "Send", json.encode({ -- 2798
			name = "TranspileTS", -- 2798
			id = requestId, -- 2798
			file = file, -- 2798
			content = content, -- 2798
			projectRoot = sourceRoot, -- 2798
			files = files -- 2798
		})) -- 2798
		local deadline = App.runningTime + 30 -- 2799
		wait(function() -- 2800
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2800
		end) -- 2800
		listener:removeFromParent() -- 2801
		if not done then -- 2802
			webIDECompilerReady = false -- 2803
			if isCancelled and isCancelled() then -- 2804
				return { -- 2805
					success = false, -- 2805
					file = file, -- 2805
					message = "build canceled", -- 2805
					interrupted = true -- 2805
				} -- 2805
			end -- 2804
			return { -- 2806
				success = false, -- 2806
				file = file, -- 2806
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2806
				failureKind = "tool" -- 2806
			} -- 2806
		end -- 2802
		return result -- 2807
	end -- 2775
end -- 2773
local compilerReadyTimeout <const> = 15 -- 2809
local compilerBuildTimeout <const> = 30 -- 2810
local compilerIdleCloseSeconds <const> = 8 -- 2811
local compilerReady = false -- 2812
local compilerRequested = false -- 2813
local compilerFailure = nil -- 2814
local compilerUsers = 0 -- 2815
local compilerCloseGeneration = 0 -- 2816
local compilerJobId = 0 -- 2817
local compilerJobs = { } -- 2818
local compilerResults = { } -- 2819
local compilerInFlight = { } -- 2820
HttpServer:post("/compiler/ready", function() -- 2822
	if not compilerRequested then -- 2823
		return { -- 2823
			success = false -- 2823
		} -- 2823
	end -- 2823
	compilerReady = true -- 2824
	return { -- 2825
		success = true -- 2825
	} -- 2825
end) -- 2822
HttpServer:post("/compiler/failure", function(req) -- 2827
	if not compilerRequested then -- 2828
		return { -- 2828
			success = false -- 2828
		} -- 2828
	end -- 2828
	do -- 2829
		local _type_0 = type(req) -- 2829
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2829
		if _tab_0 then -- 2829
			local message -- 2829
			do -- 2829
				local _obj_0 = req.body -- 2829
				local _type_1 = type(_obj_0) -- 2829
				if "table" == _type_1 or "userdata" == _type_1 then -- 2829
					message = _obj_0.message -- 2829
				end -- 2829
			end -- 2829
			if message ~= nil then -- 2829
				if type(message) == "string" then -- 2830
					compilerFailure = message -- 2831
					compilerReady = false -- 2832
					return { -- 2833
						success = true -- 2833
					} -- 2833
				end -- 2830
			end -- 2829
		end -- 2829
	end -- 2829
	return { -- 2827
		success = false -- 2827
	} -- 2827
end) -- 2827
HttpServer:postSchedule("/compiler/poll", function() -- 2835
	if not compilerRequested then -- 2836
		return { -- 2836
			success = false -- 2836
		} -- 2836
	end -- 2836
	compilerReady = true -- 2837
	local deadline = App.runningTime + 5 -- 2838
	wait(function() -- 2839
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2839
	end) -- 2839
	if not (compilerRequested and not compilerFailure) then -- 2840
		return { -- 2840
			success = false -- 2840
		} -- 2840
	end -- 2840
	local job = table.remove(compilerJobs, 1) -- 2841
	if job then -- 2842
		compilerInFlight[job.id] = true -- 2843
	end -- 2842
	return { -- 2844
		success = true, -- 2844
		job = job -- 2844
	} -- 2844
end) -- 2835
HttpServer:post("/compiler/result", function(req) -- 2846
	do -- 2847
		local _type_0 = type(req) -- 2847
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2847
		if _tab_0 then -- 2847
			local body = req.body -- 2847
			if body ~= nil then -- 2847
				local id = body.id -- 2848
				if not (id and compilerInFlight[id]) then -- 2849
					return { -- 2849
						success = false, -- 2849
						message = "invalid compiler job" -- 2849
					} -- 2849
				end -- 2849
				compilerInFlight[id] = nil -- 2850
				compilerResults[id] = body -- 2851
				return { -- 2852
					success = true -- 2852
				} -- 2852
			end -- 2847
		end -- 2847
	end -- 2847
	return { -- 2846
		success = false -- 2846
	} -- 2846
end) -- 2846
local acquireCompiler -- 2854
acquireCompiler = function() -- 2854
	compilerUsers = compilerUsers + 1 -- 2855
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2856
	if not compilerRequested then -- 2857
		compilerRequested = true -- 2858
		compilerReady = false -- 2859
		compilerFailure = nil -- 2860
		return emit("AppWebView", "/compiler.html", true) -- 2861
	end -- 2857
end -- 2854
local releaseCompiler -- 2863
releaseCompiler = function() -- 2863
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2864
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2865
	if not (compilerUsers == 0) then -- 2866
		return -- 2866
	end -- 2866
	local closeGeneration = compilerCloseGeneration -- 2867
	return thread(function() -- 2868
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2869
		wait(function() -- 2870
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2871
		end) -- 2870
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2876
			compilerRequested = false -- 2877
			compilerReady = false -- 2878
			return emit("AppWebView", "/compiler.html", false) -- 2879
		end -- 2876
	end) -- 2868
end -- 2863
local removeCompilerJob -- 2881
removeCompilerJob = function(id) -- 2881
	for index = #compilerJobs, 1, -1 do -- 2882
		if compilerJobs[index].id == id then -- 2883
			table.remove(compilerJobs, index) -- 2884
		end -- 2883
	end -- 2882
	compilerInFlight[id] = nil -- 2885
	compilerResults[id] = nil -- 2886
end -- 2881
local transpileTSFileWithCompiler -- 2888
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2888
	acquireCompiler() -- 2889
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2890
	wait(function() -- 2891
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2891
	end) -- 2891
	if not compilerReady then -- 2892
		releaseCompiler() -- 2893
		if isCancelled and isCancelled() then -- 2894
			return { -- 2895
				success = false, -- 2895
				file = file, -- 2895
				message = "build canceled", -- 2895
				interrupted = true -- 2895
			} -- 2895
		end -- 2894
		return { -- 2896
			success = false, -- 2896
			file = file, -- 2896
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2896
			failureKind = "tool" -- 2896
		} -- 2896
	end -- 2892
	compilerJobId = compilerJobId + 1 -- 2897
	local jobId = compilerJobId -- 2898
	compilerJobs[#compilerJobs + 1] = { -- 2900
		id = jobId, -- 2900
		file = file, -- 2901
		content = content, -- 2902
		projectRoot = sourceRoot, -- 2903
		files = files -- 2904
	} -- 2899
	local deadline = App.runningTime + compilerBuildTimeout -- 2905
	wait(function() -- 2906
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2906
	end) -- 2906
	local response = compilerResults[jobId] -- 2907
	removeCompilerJob(jobId) -- 2908
	releaseCompiler() -- 2909
	if not response then -- 2910
		if isCancelled and isCancelled() then -- 2911
			return { -- 2912
				success = false, -- 2912
				file = file, -- 2912
				message = "build canceled", -- 2912
				interrupted = true -- 2912
			} -- 2912
		end -- 2911
		return { -- 2913
			success = false, -- 2913
			file = file, -- 2913
			message = compilerFailure or "TypeScript transpile timed out", -- 2913
			failureKind = "tool" -- 2913
		} -- 2913
	end -- 2910
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2914
		local luaFile = Path:replaceExt(file, "lua") -- 2915
		if Content:save(luaFile, response.luaCode) then -- 2916
			return { -- 2917
				success = true, -- 2917
				file = file -- 2917
			} -- 2917
		end -- 2916
		return { -- 2918
			success = false, -- 2918
			file = file, -- 2918
			message = "failed to save " .. tostring(luaFile) -- 2918
		} -- 2918
	end -- 2914
	return { -- 2919
		success = false, -- 2919
		file = file, -- 2919
		message = response.message or "TypeScript transpile failed" -- 2919
	} -- 2919
end -- 2888
local compilerFailureListener = Node() -- 2921
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2922
	compilerFailure = message -- 2923
	compilerReady = false -- 2924
end) -- 2922
local transpileTSFile -- 2926
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2926
	if supportsCompilerWebView() and not files then -- 2927
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2928
	end -- 2927
	if HttpServer.wsConnectionCount > 0 then -- 2929
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2930
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2931
			return result -- 2931
		end -- 2931
		webIDECompilerReady = false -- 2932
	end -- 2929
	if supportsCompilerWebView() then -- 2933
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2934
	end -- 2933
	return { -- 2935
		success = false, -- 2935
		file = file, -- 2935
		message = "Web IDE compiler not connected", -- 2935
		failureKind = "tool" -- 2935
	} -- 2935
end -- 2926
local _anon_func_10 = function(path) -- 2950
	local _val_0 = Path:getExt(path) -- 2950
	return "ts" == _val_0 or "tsx" == _val_0 -- 2950
end -- 2950
HttpServer:postSchedule("/ts/build", function(req) -- 2937
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2938
	local buildSucceeded = false -- 2939
	local _ <close> = setmetatable({ }, { -- 2940
		__close = function() -- 2940
			return finishUpdate(buildSucceeded) -- 2940
		end -- 2940
	}) -- 2940
	do -- 2941
		local _type_0 = type(req) -- 2941
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2941
		if _tab_0 then -- 2941
			local path -- 2941
			do -- 2941
				local _obj_0 = req.body -- 2941
				local _type_1 = type(_obj_0) -- 2941
				if "table" == _type_1 or "userdata" == _type_1 then -- 2941
					path = _obj_0.path -- 2941
				end -- 2941
			end -- 2941
			if path ~= nil then -- 2941
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2942
					return { -- 2943
						success = false, -- 2943
						message = "Web IDE not connected" -- 2943
					} -- 2943
				end -- 2942
				local projectRoot = req.body.projectRoot -- 2944
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2945
				if not Content:exist(path) then -- 2946
					return { -- 2947
						success = false, -- 2947
						message = "path not existed" -- 2947
					} -- 2947
				end -- 2946
				local messages = { } -- 2948
				if not Content:isdir(path) then -- 2949
					if not (_anon_func_10(path)) then -- 2950
						return { -- 2951
							success = false, -- 2951
							message = "expecting a TypeScript file" -- 2951
						} -- 2951
					end -- 2950
					local content = Content:load(path) -- 2952
					if not content then -- 2953
						return { -- 2954
							success = false, -- 2954
							message = "failed to read file" -- 2954
						} -- 2954
					end -- 2953
					emit("AppWS", "Send", json.encode({ -- 2955
						name = "UpdateFile", -- 2955
						file = path, -- 2955
						exists = true, -- 2955
						content = content, -- 2955
						projectRoot = sourceRoot -- 2955
					})) -- 2955
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2956
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2957
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2958
					end -- 2956
				else -- 2960
					local fileData = { } -- 2960
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2961
					for _index_0 = 1, #_list_0 do -- 2961
						local subFile = _list_0[_index_0] -- 2961
						local file = Path(path, subFile) -- 2962
						local content = Content:load(file) -- 2963
						if content then -- 2963
							fileData[file] = content -- 2964
							emit("AppWS", "Send", json.encode({ -- 2965
								name = "UpdateFile", -- 2965
								file = file, -- 2965
								exists = true, -- 2965
								content = content, -- 2965
								projectRoot = sourceRoot -- 2965
							})) -- 2965
						else -- 2967
							messages[#messages + 1] = { -- 2967
								success = false, -- 2967
								file = file, -- 2967
								message = "failed to read file" -- 2967
							} -- 2967
						end -- 2963
					end -- 2961
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2968
					for file, content in pairs(fileData) do -- 2969
						if "d" == Path:getExt(Path:getName(file)) then -- 2970
							goto _continue_0 -- 2970
						end -- 2970
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2971
						::_continue_0:: -- 2970
					end -- 2969
				end -- 2949
				local success = true -- 2972
				for _index_0 = 1, #messages do -- 2973
					local item = messages[_index_0] -- 2973
					if not item.success then -- 2974
						success = false -- 2974
					end -- 2974
				end -- 2973
				local message = nil -- 2975
				if not success then -- 2976
					message = "TypeScript compilation failed" -- 2976
				end -- 2976
				buildSucceeded = success -- 2977
				return { -- 2978
					success = success, -- 2978
					messages = messages, -- 2978
					message = message -- 2978
				} -- 2978
			end -- 2941
		end -- 2941
	end -- 2941
	return { -- 2937
		success = false -- 2937
	} -- 2937
end) -- 2937
HttpServer:post("/download", function(req) -- 2980
	do -- 2981
		local _type_0 = type(req) -- 2981
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2981
		if _tab_0 then -- 2981
			local url -- 2981
			do -- 2981
				local _obj_0 = req.body -- 2981
				local _type_1 = type(_obj_0) -- 2981
				if "table" == _type_1 or "userdata" == _type_1 then -- 2981
					url = _obj_0.url -- 2981
				end -- 2981
			end -- 2981
			local target -- 2981
			do -- 2981
				local _obj_0 = req.body -- 2981
				local _type_1 = type(_obj_0) -- 2981
				if "table" == _type_1 or "userdata" == _type_1 then -- 2981
					target = _obj_0.target -- 2981
				end -- 2981
			end -- 2981
			if url ~= nil and target ~= nil then -- 2981
				local Entry = require("Script.Dev.Entry") -- 2982
				Entry.downloadFile(url, target) -- 2983
				return { -- 2984
					success = true -- 2984
				} -- 2984
			end -- 2981
		end -- 2981
	end -- 2981
	return { -- 2980
		success = false -- 2980
	} -- 2980
end) -- 2980
local isDesktopPlatform -- 2986
isDesktopPlatform = function() -- 2986
	local _val_0 = App.platform -- 2987
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2987
end -- 2986
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 2989
local nativeIDEListener = Node() -- 2990
nativeIDEListener:addTo(Director.systemUI) -- 2991
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 2992
	nativeIDEState, nativeIDEMessage = state, message -- 2993
end) -- 2992
local _anon_func_11 = function() -- 2996
	local _val_0 = App.platform -- 2996
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2996
end -- 2996
HttpServer:post("/ide", function(req) -- 2995
	if not (_anon_func_11()) then -- 2996
		return { -- 2996
			success = false, -- 2996
			message = "Native IDE is unavailable" -- 2996
		} -- 2996
	end -- 2996
	if not App.webIDEEnabled then -- 2997
		return { -- 2997
			success = false, -- 2997
			message = "Embedded Web IDE is disabled" -- 2997
		} -- 2997
	end -- 2997
	do -- 2998
		local _type_0 = type(req) -- 2998
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2998
		if _tab_0 then -- 2998
			local action -- 2998
			do -- 2998
				local _obj_0 = req.body -- 2998
				local _type_1 = type(_obj_0) -- 2998
				if "table" == _type_1 or "userdata" == _type_1 then -- 2998
					action = _obj_0.action -- 2998
				end -- 2998
			end -- 2998
			if action ~= nil then -- 2998
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 2999
					emit("AppWebView", "/ide/" .. action, true) -- 3000
					return { -- 3001
						success = true -- 3001
					} -- 3001
				end -- 2999
			end -- 2998
		end -- 2998
	end -- 2998
	return { -- 2995
		success = false, -- 2995
		message = "invalid IDE action" -- 2995
	} -- 2995
end) -- 2995
local _anon_func_12 = function() -- 3017
	local _val_0 = App.platform -- 3017
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 3017
end -- 3017
local getServerStatus -- 3003
getServerStatus = function() -- 3003
	local Entry = require("Script.Dev.Entry") -- 3004
	local running = Entry.getCurrentEntryStatus() -- 3005
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 3006
	local wsConnectionCount = HttpServer.wsConnectionCount -- 3007
	return { -- 3009
		success = true, -- 3009
		platform = App.platform, -- 3010
		locale = App.locale, -- 3011
		version = App.version, -- 3012
		url = "http://localhost:8866", -- 3013
		wsConnectionCount = wsConnectionCount, -- 3014
		webIDEConnected = wsConnectionCount > 0, -- 3015
		nativeIDE = { -- 3017
			supported = _anon_func_12(), -- 3017
			enabled = App.webIDEEnabled, -- 3018
			state = nativeIDEState, -- 3019
			message = nativeIDEMessage -- 3020
		}, -- 3016
		typescriptCompiler = { -- 3022
			webIDEReady = webIDECompilerReady, -- 3022
			webIDEGeneration = webIDEConnectionGeneration, -- 3023
			embeddedSupported = supportsCompilerWebView(), -- 3024
			embeddedRequested = compilerRequested, -- 3025
			embeddedReady = compilerReady, -- 3026
			users = compilerUsers, -- 3027
			queuedJobs = #compilerJobs, -- 3028
			failure = compilerFailure -- 3029
		}, -- 3021
		assetPath = Content.assetPath, -- 3030
		writablePath = Content.writablePath, -- 3031
		appPath = Content.appPath, -- 3032
		waTemplateReady = waTemplateReady, -- 3033
		running = running -- 3034
	} -- 3008
end -- 3003
HttpServer:post("/status", function() -- 3037
	return getServerStatus() -- 3038
end) -- 3037
HttpServer:postSchedule("/doctor/fix", function(req) -- 3040
	do -- 3041
		local _type_0 = type(req) -- 3041
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3041
		if _tab_0 then -- 3041
			local openWebIDE -- 3041
			do -- 3041
				local _obj_0 = req.body -- 3041
				local _type_1 = type(_obj_0) -- 3041
				if "table" == _type_1 or "userdata" == _type_1 then -- 3041
					openWebIDE = _obj_0.openWebIDE -- 3041
				end -- 3041
			end -- 3041
			if openWebIDE ~= nil then -- 3041
				if not openWebIDE then -- 3042
					return { -- 3043
						success = false, -- 3043
						message = "nothing to fix" -- 3043
					} -- 3043
				end -- 3042
				local status = getServerStatus() -- 3044
				if status.webIDEConnected then -- 3045
					return { -- 3046
						success = true, -- 3046
						fixed = false, -- 3046
						message = "Web IDE already connected.", -- 3046
						status = status -- 3046
					} -- 3046
				end -- 3045
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 3047
				if waitSeconds > 0 then -- 3048
					local deadline = os.time() + waitSeconds -- 3049
					repeat -- 3050
						sleep(0.2) -- 3051
						status = getServerStatus() -- 3052
						if status.webIDEConnected then -- 3053
							return { -- 3054
								success = true, -- 3054
								fixed = false, -- 3054
								reconnected = true, -- 3054
								message = "Web IDE reconnected.", -- 3054
								status = status -- 3054
							} -- 3054
						end -- 3053
					until os.time() >= deadline -- 3050
				end -- 3048
				if not isDesktopPlatform() then -- 3056
					return { -- 3057
						success = false, -- 3057
						message = "opening Web IDE is only supported on desktop platforms", -- 3057
						status = status -- 3057
					} -- 3057
				end -- 3056
				local url = "http://localhost:8866" -- 3058
				App:openURL(url) -- 3059
				status.openedURL = url -- 3060
				return { -- 3061
					success = true, -- 3061
					fixed = true, -- 3061
					message = "Opened Web IDE in the local browser.", -- 3061
					url = url, -- 3061
					status = status -- 3061
				} -- 3061
			end -- 3041
		end -- 3041
	end -- 3041
	return { -- 3040
		success = false, -- 3040
		message = "invalid call" -- 3040
	} -- 3040
end) -- 3040
local status = { } -- 3063
_module_0 = status -- 3064
status.transpileTSFile = transpileTSFile -- 3066
HttpServer:postSchedule("/godot/project", function(req) -- 3069
	do -- 3070
		local _type_0 = type(req) -- 3070
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3070
		if _tab_0 then -- 3070
			local path -- 3070
			do -- 3070
				local _obj_0 = req.body -- 3070
				local _type_1 = type(_obj_0) -- 3070
				if "table" == _type_1 or "userdata" == _type_1 then -- 3070
					path = _obj_0.path -- 3070
				end -- 3070
			end -- 3070
			if path ~= nil then -- 3070
				if not (type(path) == "string" and Content:isAbsolutePath(path)) then -- 3071
					return invalidArguments -- 3071
				end -- 3071
				local releaseAgent = AgentHost.acquire() -- 3072
				local _ <close> = setmetatable({ }, { -- 3073
					__close = function() -- 3073
						return releaseAgent() -- 3073
					end -- 3073
				}) -- 3073
				local GodotBuild = require("Agent.Tool.GodotBuild") -- 3074
				local project = GodotBuild.findGodotProject(Content.writablePath, path) or GodotBuild.findGodotProject(Content.assetPath, path) -- 3075
				if not project then -- 3076
					return { -- 3076
						success = true, -- 3076
						found = false -- 3076
					} -- 3076
				end -- 3076
				if not (req.body.build == true) then -- 3077
					return { -- 3077
						success = true, -- 3077
						found = true, -- 3077
						projectRoot = project -- 3077
					} -- 3077
				end -- 3077
				local result -- 3078
				local promise = GodotBuild.buildGodotProject(project) -- 3079
				local onFulfilled -- 3080
				onFulfilled = function(_, value) -- 3080
					result = value -- 3081
				end -- 3080
				local onRejected -- 3082
				onRejected = function(_, err) -- 3082
					result = { -- 3083
						success = false, -- 3083
						message = tostring(err) -- 3083
					} -- 3083
				end -- 3082
				promise["then"](promise, onFulfilled, onRejected) -- 3084
				wait(function() -- 3085
					return result ~= nil -- 3085
				end) -- 3085
				result.found = true -- 3086
				result.projectRoot = project -- 3087
				return result -- 3088
			end -- 3070
		end -- 3070
	end -- 3070
	return invalidArguments -- 3069
end) -- 3069
status.buildAsync = function(path) -- 3090
	if not Content:exist(path) then -- 3091
		return { -- 3092
			success = false, -- 3092
			file = path, -- 3092
			message = "file not existed" -- 3092
		} -- 3092
	end -- 3091
	do -- 3093
		local _exp_0 = Path:getExt(path) -- 3093
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 3093
			if '' == Path:getExt(Path:getName(path)) then -- 3094
				local content = Content:loadAsync(path) -- 3095
				if content then -- 3095
					local resultCodes, err = compileFileAsync(path, content) -- 3096
					if resultCodes then -- 3096
						return { -- 3097
							success = true, -- 3097
							file = path -- 3097
						} -- 3097
					else -- 3099
						return { -- 3099
							success = false, -- 3099
							file = path, -- 3099
							message = err -- 3099
						} -- 3099
					end -- 3096
				end -- 3095
			end -- 3094
		elseif "lua" == _exp_0 then -- 3100
			local content = Content:loadAsync(path) -- 3101
			if content then -- 3101
				do -- 3102
					local isTIC80 = CheckTIC80Code(content) -- 3102
					if isTIC80 then -- 3102
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 3103
					end -- 3102
				end -- 3102
				local success, info -- 3104
				do -- 3104
					local _obj_0 = luaCheck(path, content) -- 3104
					success, info = _obj_0.success, _obj_0.info -- 3104
				end -- 3104
				if success then -- 3105
					return { -- 3106
						success = true, -- 3106
						file = path -- 3106
					} -- 3106
				elseif info and #info > 0 then -- 3107
					local messages = { } -- 3108
					for _index_0 = 1, #info do -- 3109
						local _des_0 = info[_index_0] -- 3109
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3109
						local lineText = "" -- 3110
						if line then -- 3111
							local currentLine = 1 -- 3112
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3113
								if currentLine == line then -- 3114
									lineText = text -- 3115
									break -- 3116
								end -- 3114
								currentLine = currentLine + 1 -- 3117
							end -- 3113
						end -- 3111
						if line then -- 3118
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3119
						else -- 3121
							messages[#messages + 1] = message -- 3121
						end -- 3118
					end -- 3109
					return { -- 3122
						success = false, -- 3122
						file = path, -- 3122
						message = table.concat(messages, "\n") -- 3122
					} -- 3122
				else -- 3124
					return { -- 3124
						success = false, -- 3124
						file = path, -- 3124
						message = "lua check failed" -- 3124
					} -- 3124
				end -- 3105
			end -- 3101
		elseif "yarn" == _exp_0 then -- 3125
			local content = Content:loadAsync(path) -- 3126
			if content then -- 3126
				local res, _, err = yarncompile(content, true) -- 3127
				if res then -- 3127
					return { -- 3128
						success = true, -- 3128
						file = path -- 3128
					} -- 3128
				else -- 3130
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3130
					local lineText = "" -- 3131
					if line then -- 3132
						local currentLine = 1 -- 3133
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3134
							if currentLine == line then -- 3135
								lineText = text -- 3136
								break -- 3137
							end -- 3135
							currentLine = currentLine + 1 -- 3138
						end -- 3134
					end -- 3132
					if node ~= "" then -- 3139
						node = "node: " .. tostring(node) .. ", " -- 3140
					else -- 3141
						node = "" -- 3141
					end -- 3139
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3142
					return { -- 3143
						success = false, -- 3143
						file = path, -- 3143
						message = message -- 3143
					} -- 3143
				end -- 3127
			end -- 3126
		end -- 3093
	end -- 3093
	return { -- 3144
		success = false, -- 3144
		file = path, -- 3144
		message = "invalid file to build" -- 3144
	} -- 3144
end -- 3090
HttpServer:postSchedule("/git/commit-files", function(req) -- 3146
	do -- 3147
		local _type_0 = type(req) -- 3147
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3147
		if _tab_0 then -- 3147
			local body = req.body -- 3147
			if body ~= nil then -- 3147
				local repoPath, commit = body.repoPath, body.commit -- 3148
				if gitInvalidRepoPath(repoPath) then -- 3149
					return { -- 3149
						success = false, -- 3149
						message = "invalid repoPath" -- 3149
					} -- 3149
				end -- 3149
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3150
					return { -- 3150
						success = false, -- 3150
						message = "invalid commit" -- 3150
					} -- 3150
				end -- 3150
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3151
				if not res.success then -- 3152
					return res -- 3152
				end -- 3152
				return { -- 3153
					success = true, -- 3153
					status = res.status, -- 3153
					data = res.status and res.status.data -- 3153
				} -- 3153
			end -- 3147
		end -- 3147
	end -- 3147
	return invalidArguments -- 3146
end) -- 3146
thread(function() -- 3155
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3156
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3157
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3158
		local storedAsset -- 3161
		storedAsset = function(file) -- 3161
			if Content:exist(file) then -- 3162
				return Content:load(file) -- 3163
			elseif Content:exist(file .. ".gz") then -- 3164
				return Content:load(file .. ".gz") -- 3165
			else -- 3166
				return "" -- 3166
			end -- 3162
		end -- 3161
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3167
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3168
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3169
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3170
		local readyContent = table.concat({ -- 3172
			App.version, -- 3172
			storedAsset(doraWeb), -- 3173
			storedAsset(heavyAssets), -- 3174
			storedAsset(runtimeIndex), -- 3175
			storedAsset(compilerIndex), -- 3176
			storedAsset(manifest) -- 3177
		}, "\n") -- 3171
		local needReload -- 3179
		if Content:exist(doraReady) then -- 3179
			needReload = readyContent ~= Content:load(doraReady) -- 3180
		else -- 3181
			needReload = true -- 3181
		end -- 3179
		if needReload then -- 3182
			Content:remove(Path(Content.appPath, ".www")) -- 3183
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3184
			Content:save(doraReady, readyContent) -- 3188
			print("Dora Dora is ready!") -- 3189
		end -- 3182
	end -- 3158
	if App.platform == "Emscripten" then -- 3190
		status.url = nil -- 3191
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3192
	end -- 3190
	HttpServer:clearStaticCacheControls() -- 3193
	HttpServer:setStaticCacheControl("no-cache") -- 3194
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3195
	if HttpServer:start(8866) then -- 3199
		local localIP = HttpServer.localIP -- 3200
		if localIP == "" then -- 3201
			localIP = "localhost" -- 3201
		end -- 3201
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3202
		return HttpServer:startWS(8868) -- 3203
	else -- 3205
		status.url = nil -- 3205
		return print("8866 Port not available!") -- 3206
	end -- 3199
end) -- 3155
return _module_0 -- 1
