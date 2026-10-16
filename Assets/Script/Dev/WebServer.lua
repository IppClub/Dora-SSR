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
local DB <const> = DB -- 10
local tonumber <const> = tonumber -- 10
local json <const> = json -- 10
local Git <const> = Git -- 10
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
local AgentLocalAgent = AgentHost.proxy("Agent.LocalAgent") -- 143
local AgentVisionAssets = AgentHost.proxy("Agent.Tool.VisionAssets") -- 144
HttpServer:post("/agent/runtime/status", function() -- 146
	return AgentHost.status() -- 146
end) -- 146
HttpServer:post("/agent/runtime/reload", function() -- 147
	return AgentHost.reload() -- 147
end) -- 147
HttpServer:post("/agent/runtime/automatic", function(req) -- 148
	do -- 149
		local _type_0 = type(req) -- 149
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 149
		if _tab_0 then -- 149
			local enabled -- 149
			do -- 149
				local _obj_0 = req.body -- 149
				local _type_1 = type(_obj_0) -- 149
				if "table" == _type_1 or "userdata" == _type_1 then -- 149
					enabled = _obj_0.enabled -- 149
				end -- 149
			end -- 149
			if enabled ~= nil then -- 149
				if type(enabled) == "boolean" then -- 150
					return AgentHost.setAutomatic(enabled) -- 150
				end -- 150
			end -- 149
		end -- 149
	end -- 149
	return invalidArguments -- 148
end) -- 148
local GitJobs = { } -- 152
local gitTerminalState -- 154
gitTerminalState = function(status) -- 154
	if not (status and status.state) then -- 155
		return false -- 155
	end -- 155
	local _val_0 = status.state -- 156
	return "done" == _val_0 or "error" == _val_0 or "canceled" == _val_0 -- 156
end -- 154
local GIT_JOB_TTL = 600 -- 158
local gitPruneJobs -- 160
gitPruneJobs = function() -- 160
	local time = os.time() -- 161
	for id, job in pairs(GitJobs) do -- 162
		if gitTerminalState(job.status) and time - (job.updatedAt or time) > GIT_JOB_TTL then -- 163
			GitJobs[id] = nil -- 164
		end -- 163
	end -- 162
end -- 160
local gitInvalidRepoPath -- 166
gitInvalidRepoPath = function(repoPath) -- 166
	return not repoPath or repoPath == "" or not Content:isAbsolutePath(repoPath) -- 167
end -- 166
local gitShellSplit -- 169
gitShellSplit = function(command) -- 169
	local args = { } -- 170
	local current = { } -- 171
	local quote = nil -- 172
	local escape = false -- 173
	for i = 1, #command do -- 174
		local ch = command:sub(i, i) -- 175
		if escape then -- 176
			current[#current + 1] = ch -- 177
			escape = false -- 178
		elseif ch == "\\" then -- 179
			escape = true -- 180
		elseif quote then -- 181
			if ch == quote then -- 182
				quote = nil -- 183
			else -- 185
				current[#current + 1] = ch -- 185
			end -- 182
		elseif ch == "'" or ch == '"' then -- 186
			quote = ch -- 187
		elseif ch:match("%s") then -- 188
			if #current > 0 then -- 189
				args[#args + 1] = table.concat(current) -- 190
				current = { } -- 191
			end -- 189
		else -- 193
			current[#current + 1] = ch -- 193
		end -- 176
	end -- 174
	if #current > 0 then -- 194
		args[#args + 1] = table.concat(current) -- 195
	end -- 194
	if args[1] == "git" then -- 196
		table.remove(args, 1) -- 197
	end -- 196
	return args -- 198
end -- 169
local gitQuote -- 200
gitQuote = function(value) -- 200
	local text = tostring(value) -- 201
	if text:match("^[%w%._%-%/]+$") then -- 202
		return text -- 203
	end -- 202
	return "\"" .. text:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"" -- 204
end -- 200
local gitDirNonEmpty -- 206
gitDirNonEmpty = function(targetPath) -- 206
	if not Content:exist(targetPath) then -- 207
		return false -- 207
	end -- 207
	if not Content:isdir(targetPath) then -- 208
		return false -- 208
	end -- 208
	return #Content:getFiles(targetPath) > 0 or #Content:getDirs(targetPath) > 0 -- 209
end -- 206
local gitSafeChildPath -- 211
gitSafeChildPath = function(parentPath, childPath) -- 211
	if not (parentPath and childPath and childPath ~= "") then -- 212
		return nil -- 212
	end -- 212
	if childPath:sub(1, 1) == "/" or childPath:match("^%a:[/\\]") then -- 213
		return nil -- 213
	end -- 213
	if childPath == "." or childPath:match("^%.%.[/\\]?" or childPath:match("[/\\]%.%.[/\\]")) then -- 214
		return nil -- 214
	end -- 214
	local targetPath = Path(parentPath, childPath) -- 215
	local relative = Path:getRelative(targetPath, parentPath) -- 216
	if relative == ".." or relative:sub(1, 3) == "../" or relative:sub(1, 3) == "..\\" then -- 217
		return nil -- 217
	end -- 217
	return targetPath -- 218
end -- 211
local gitCloneDirFromURL -- 220
gitCloneDirFromURL = function(url) -- 220
	if not (url and url ~= "") then -- 221
		return nil -- 221
	end -- 221
	local text = tostring(url):match("^%s*(.-)%s*$") -- 222
	if text == "" then -- 223
		return nil -- 223
	end -- 223
	text = text:gsub("[/\\]+$", "") -- 224
	local name = text:match("([^/:]+)$") -- 225
	if not (name and name ~= "") then -- 226
		return nil -- 226
	end -- 226
	name = name:gsub("%.git$", "") -- 227
	if name == "" or name == "." or name == ".." then -- 228
		return nil -- 228
	end -- 228
	return name -- 229
end -- 220
local gitCloneTargetPath -- 231
gitCloneTargetPath = function(repoPath, command) -- 231
	local args = gitShellSplit(command) -- 232
	if not (args[1] == "clone") then -- 233
		return nil -- 233
	end -- 233
	local url = args[2] -- 234
	local index = 3 -- 235
	while index <= #args do -- 236
		local arg = args[index] -- 237
		if ("-b" == arg or "--branch" == arg or "--depth" == arg) then -- 238
			index = index + 2 -- 239
		elseif arg:sub(1, 1) == "-" then -- 240
			index = index + 1 -- 241
		else -- 243
			return gitSafeChildPath(repoPath, arg) -- 243
		end -- 238
	end -- 236
	do -- 244
		local dirName = gitCloneDirFromURL(url) -- 244
		if dirName then -- 244
			return gitSafeChildPath(repoPath, dirName) -- 245
		end -- 244
	end -- 244
	return nil -- 246
end -- 231
local gitPathInsideRepo -- 248
gitPathInsideRepo = function(repoPath, relPath) -- 248
	if not (repoPath and relPath and relPath ~= "") then -- 249
		return false -- 249
	end -- 249
	if relPath:sub(1, 1) == "/" or relPath:match("^%a:[/\\]") then -- 250
		return false -- 250
	end -- 250
	if relPath == "." or relPath:match("^%.%.[/\\]?" or relPath:match("[/\\]%.%.[/\\]")) then -- 251
		return false -- 251
	end -- 251
	local targetPath = Path(repoPath, relPath) -- 252
	local relative = Path:getRelative(targetPath, repoPath) -- 253
	return relative ~= ".." and relative:sub(1, 3) ~= "../" and relative:sub(1, 3) ~= "..\\" -- 254
end -- 248
local gitHostFromURL -- 256
gitHostFromURL = function(url) -- 256
	if not (url and url ~= "") then -- 257
		return nil -- 257
	end -- 257
	local text = tostring(url):match("^%s*(.-)%s*$") -- 258
	if text == "" then -- 259
		return nil -- 259
	end -- 259
	local host = text:match("^[%w_%-]+://([^/:]+)") -- 260
	if not host then -- 261
		host = text:match("@([^:/]+)[:/]") -- 261
	end -- 261
	if not host then -- 262
		host = text:match("^([^:/]+):[^/]") -- 262
	end -- 262
	if not (host and host ~= "") then -- 263
		return nil -- 263
	end -- 263
	return string.lower(host) -- 264
end -- 256
local ensureGitTables -- 266
ensureGitTables = function() -- 266
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
	]]) -- 267
	DB:exec("CREATE INDEX IF NOT EXISTS idx_git_credential_host ON GitCredential(host);") -- 280
	return DB:exec([[		CREATE TABLE IF NOT EXISTS GitProfile(
			id INTEGER PRIMARY KEY CHECK(id = 1),
			name TEXT NOT NULL DEFAULT '',
			email TEXT NOT NULL DEFAULT '',
			updated_at INTEGER
		);
	]]) -- 281
end -- 266
local gitCredentialToPublic -- 290
gitCredentialToPublic = function(row) -- 290
	local id, host, label, typeName, username, createdAt, updatedAt, lastUsedAt = row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8] -- 291
	return { -- 292
		id = id, -- 292
		host = host, -- 292
		label = label, -- 292
		type = typeName, -- 292
		username = username, -- 292
		createdAt = createdAt, -- 292
		updatedAt = updatedAt, -- 292
		lastUsedAt = lastUsedAt -- 292
	} -- 292
end -- 290
local gitLoadCredential -- 294
gitLoadCredential = function(id) -- 294
	ensureGitTables() -- 295
	local credentialId = tonumber(id) or 0 -- 296
	local rows = DB:query("select id, host, label, type, username, secret from GitCredential where id = ? limit 1", { -- 297
		credentialId -- 297
	}) -- 297
	if not (rows and rows[1]) then -- 298
		return nil -- 298
	end -- 298
	local row = rows[1] -- 299
	return { -- 300
		id = row[1], -- 300
		host = row[2], -- 300
		label = row[3], -- 300
		type = row[4], -- 300
		username = row[5], -- 300
		secret = row[6] -- 300
	} -- 300
end -- 294
local gitAuthOptionsJSON -- 302
gitAuthOptionsJSON = function(credential) -- 302
	if not credential then -- 303
		return nil -- 303
	end -- 303
	local auth -- 304
	if credential.type == "token" then -- 304
		auth = { -- 306
			type = "token", -- 306
			token = credential.secret, -- 307
			username = credential.username ~= "" and credential.username or "token" -- 308
		} -- 305
	else -- 311
		auth = { -- 312
			type = "basic", -- 312
			username = credential.username, -- 313
			password = credential.secret -- 314
		} -- 311
	end -- 304
	return json.encode({ -- 316
		auth = auth -- 316
	}) -- 316
end -- 302
local gitLoadProfile -- 318
gitLoadProfile = function() -- 318
	ensureGitTables() -- 319
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 320
	if not (rows and rows[1]) then -- 321
		return nil -- 321
	end -- 321
	local name = tostring(rows[1][1] or "") -- 322
	local email = tostring(rows[1][2] or "") -- 323
	if name == "" and email == "" then -- 324
		return nil -- 324
	end -- 324
	return { -- 325
		name = name, -- 325
		email = email -- 325
	} -- 325
end -- 318
local _anon_func_2 = function(args, gitQuote) -- 344
	local _accum_0 = { } -- 344
	local _len_0 = 1 -- 344
	for _index_0 = 1, #args do -- 344
		local arg = args[_index_0] -- 344
		_accum_0[_len_0] = gitQuote(arg) -- 344
		_len_0 = _len_0 + 1 -- 344
	end -- 344
	return _accum_0 -- 344
end -- 344
local gitApplyProfileToCommit -- 327
gitApplyProfileToCommit = function(command) -- 327
	local args = gitShellSplit(command) -- 328
	if not (args[1] == "commit") then -- 329
		return command -- 329
	end -- 329
	local hasName = false -- 330
	local hasEmail = false -- 331
	for _index_0 = 1, #args do -- 332
		local arg = args[_index_0] -- 332
		if arg == "--author-name" then -- 333
			hasName = true -- 333
		end -- 333
		if arg == "--author-email" then -- 334
			hasEmail = true -- 334
		end -- 334
	end -- 332
	if hasName and hasEmail then -- 335
		return command -- 335
	end -- 335
	local profile = gitLoadProfile() -- 336
	if not profile then -- 337
		return command -- 337
	end -- 337
	if not hasName and profile.name ~= "" then -- 338
		args[#args + 1] = "--author-name" -- 339
		args[#args + 1] = profile.name -- 340
	end -- 338
	if not hasEmail and profile.email ~= "" then -- 341
		args[#args + 1] = "--author-email" -- 342
		args[#args + 1] = profile.email -- 343
	end -- 341
	return table.concat(_anon_func_2(args, gitQuote), " ") -- 344
end -- 327
local gitStartJob -- 346
gitStartJob = function(repoPath, command, optionsJSON) -- 346
	if optionsJSON == nil then -- 346
		optionsJSON = nil -- 346
	end -- 346
	gitPruneJobs() -- 347
	if gitInvalidRepoPath(repoPath) then -- 348
		return nil, "invalid repoPath" -- 348
	end -- 348
	if not (command and command ~= "") then -- 349
		return nil, "invalid command" -- 349
	end -- 349
	if not optionsJSON then -- 350
		optionsJSON = "" -- 350
	end -- 350
	command = gitApplyProfileToCommit(command) -- 351
	do -- 352
		local targetPath = gitCloneTargetPath(repoPath, command) -- 352
		if targetPath then -- 352
			if gitDirNonEmpty(targetPath) then -- 353
				return nil, "clone target directory is not empty" -- 354
			end -- 353
		elseif (gitShellSplit(command))[1] == "clone" then -- 355
			return nil, "invalid clone target" -- 356
		end -- 352
	end -- 352
	local statusRef = nil -- 357
	local startGit -- 358
	startGit = function() -- 358
		return Git:run(repoPath, command, (function(status) -- 359
			statusRef = status -- 360
			GitJobs[status.id] = { -- 362
				command = command, -- 362
				status = status, -- 363
				updatedAt = os.time() -- 364
			} -- 361
		end), optionsJSON) -- 359
	end -- 358
	local success, jobId = pcall(startGit) -- 366
	if not success then -- 367
		return nil, tostring(jobId) -- 367
	end -- 367
	if not jobId then -- 368
		return nil, "Git.run did not return a job id" -- 368
	end -- 368
	GitJobs[jobId] = { -- 370
		command = command, -- 370
		status = statusRef or { -- 372
			id = jobId, -- 372
			state = "queued", -- 373
			kind = gitShellSplit(command)[1] or "status", -- 374
			repoPath = repoPath, -- 375
			progress = 0, -- 376
			message = "queued" -- 377
		}, -- 371
		updatedAt = os.time() -- 379
	} -- 369
	return jobId -- 380
end -- 346
local gitRunSync -- 382
gitRunSync = function(repoPath, command, optionsJSON, timeout) -- 382
	if optionsJSON == nil then -- 382
		optionsJSON = nil -- 382
	end -- 382
	if timeout == nil then -- 382
		timeout = 20 -- 382
	end -- 382
	local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 383
	if not jobId then -- 384
		return { -- 384
			success = false, -- 384
			message = err -- 384
		} -- 384
	end -- 384
	local startedAt = os.time() -- 385
	wait(function() -- 386
		local job = GitJobs[jobId] -- 387
		local status = job and job.status -- 388
		return gitTerminalState(status) or os.time() - startedAt >= timeout -- 389
	end) -- 386
	local status = GitJobs[jobId] and GitJobs[jobId].status -- 390
	if not gitTerminalState(status) then -- 391
		Git:cancel(jobId) -- 392
		return { -- 393
			success = false, -- 393
			message = "git command timed out", -- 393
			jobId = jobId, -- 393
			status = status -- 393
		} -- 393
	end -- 391
	return { -- 394
		success = status.state == "done", -- 394
		jobId = jobId, -- 394
		status = status, -- 394
		message = status.error or status.message -- 394
	} -- 394
end -- 382
local gitCredentialsForHost -- 396
gitCredentialsForHost = function(host) -- 396
	if not (host and host ~= "") then -- 397
		return { } -- 397
	end -- 397
	ensureGitTables() -- 398
	local rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by last_used_at desc, label asc, id asc", { -- 399
		host -- 399
	}) -- 399
	if rows then -- 400
		local _accum_0 = { } -- 401
		local _len_0 = 1 -- 401
		for _index_0 = 1, #rows do -- 401
			local row = rows[_index_0] -- 401
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 401
			_len_0 = _len_0 + 1 -- 401
		end -- 401
		return _accum_0 -- 401
	else -- 402
		return { } -- 402
	end -- 400
end -- 396
local gitFirstRemoteURL -- 404
gitFirstRemoteURL = function(repoPath, remoteName) -- 404
	if remoteName == nil then -- 404
		remoteName = nil -- 404
	end -- 404
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 10) -- 405
	local data = remoteRes.status and remoteRes.status.data -- 406
	if not (data and data.remotes) then -- 407
		return nil -- 407
	end -- 407
	local _list_0 = data.remotes -- 408
	for _index_0 = 1, #_list_0 do -- 408
		local remote = _list_0[_index_0] -- 408
		if (not remoteName or remote.name == remoteName) and remote.urls and remote.urls[1] then -- 409
			return remote.urls[1] -- 410
		end -- 409
	end -- 408
	return nil -- 411
end -- 404
local gitConfigRemoteURL -- 413
gitConfigRemoteURL = function(repoPath, remoteName) -- 413
	if remoteName == nil then -- 413
		remoteName = nil -- 413
	end -- 413
	if gitInvalidRepoPath(repoPath) then -- 414
		return nil -- 414
	end -- 414
	local configPath = Path(repoPath, ".git/config") -- 415
	if not Content:exist(configPath) then -- 416
		return nil -- 416
	end -- 416
	local content = Content:load(configPath) -- 417
	if not (content and content ~= "") then -- 418
		return nil -- 418
	end -- 418
	local currentRemote = nil -- 419
	for line in content:gmatch("[^\r\n]+") do -- 420
		local sectionRemote = line:match('^%s*%[remote%s+"([^"]+)"%]%s*$') -- 421
		if sectionRemote then -- 422
			currentRemote = sectionRemote -- 423
		elseif currentRemote and (not remoteName or currentRemote == remoteName) then -- 424
			local url = line:match("^%s*url%s*=%s*(.-)%s*$") -- 425
			if url and url ~= "" then -- 426
				return url -- 426
			end -- 426
		end -- 422
	end -- 420
	return nil -- 427
end -- 413
local gitCommandRemoteArg -- 429
gitCommandRemoteArg = function(args, startIndex) -- 429
	if startIndex == nil then -- 429
		startIndex = 2 -- 429
	end -- 429
	local index = startIndex -- 430
	while index <= #args do -- 431
		local arg = args[index] -- 432
		if ("-u" == arg or "--set-upstream" == arg or "-f" == arg or "--force" == arg or "--all" == arg or "--prune" == arg) then -- 433
			index = index + 1 -- 434
		elseif ("--depth" == arg or "-b" == arg or "--branch" == arg) then -- 435
			index = index + 2 -- 436
		elseif arg and arg:sub(1, 1) == "-" then -- 437
			index = index + 1 -- 438
		else -- 440
			return arg -- 440
		end -- 433
	end -- 431
	return nil -- 441
end -- 429
local gitCommandHost -- 443
gitCommandHost = function(repoPath, command) -- 443
	local args = gitShellSplit(command) -- 444
	if not args[1] then -- 445
		return nil -- 445
	end -- 445
	do -- 446
		local _exp_0 = args[1] -- 446
		if "clone" == _exp_0 or "ls-remote" == _exp_0 then -- 447
			return gitHostFromURL(args[2]) -- 448
		elseif "fetch" == _exp_0 or "pull" == _exp_0 or "push" == _exp_0 then -- 449
			local remoteArg = gitCommandRemoteArg(args, 2) -- 450
			if not remoteArg then -- 451
				return nil -- 451
			end -- 451
			local url = gitHostFromURL(remoteArg) -- 452
			if url then -- 453
				return url -- 453
			end -- 453
			return gitHostFromURL(gitConfigRemoteURL(repoPath, remoteArg)) -- 454
		end -- 446
	end -- 446
	return nil -- 455
end -- 443
local gitAuthSelectionForCommand -- 457
gitAuthSelectionForCommand = function(repoPath, command) -- 457
	local host = gitCommandHost(repoPath, command) -- 458
	if not host then -- 459
		return nil -- 459
	end -- 459
	local items = gitCredentialsForHost(host) -- 460
	if #items == 0 then -- 461
		return nil -- 461
	end -- 461
	return { -- 462
		host = host, -- 462
		items = items -- 462
	} -- 462
end -- 457
local gitDefaultRemote -- 464
gitDefaultRemote = function(remoteStatus) -- 464
	local data = remoteStatus and remoteStatus.data -- 465
	if not (data and data.remotes and data.remotes[1]) then -- 466
		return nil -- 466
	end -- 466
	return data.remotes[1] -- 467
end -- 464
local gitCurrentBranch -- 469
gitCurrentBranch = function(branchStatus) -- 469
	local data = branchStatus and branchStatus.data -- 470
	if data and data.current and data.current ~= "" then -- 471
		return data.current -- 472
	end -- 471
	if data and data.branches then -- 473
		local _list_0 = data.branches -- 474
		for _index_0 = 1, #_list_0 do -- 474
			local branch = _list_0[_index_0] -- 474
			if branch.current then -- 475
				return branch.name -- 475
			end -- 475
		end -- 474
	end -- 473
	return nil -- 476
end -- 469
local gitHeadBranch -- 478
gitHeadBranch = function(repoPath) -- 478
	if gitInvalidRepoPath(repoPath) then -- 479
		return nil -- 479
	end -- 479
	local headPath = Path(repoPath, ".git", "HEAD") -- 480
	if not Content:exist(headPath) then -- 481
		return nil -- 481
	end -- 481
	local head = Content:load(headPath) -- 482
	if not head then -- 483
		return nil -- 483
	end -- 483
	local branch = head:match("^ref:%s*refs/heads/(.-)%s*$") -- 484
	if branch and branch ~= "" then -- 485
		return branch -- 485
	end -- 485
	return nil -- 486
end -- 478
local gitBranchesWithHead -- 488
gitBranchesWithHead = function(branchStatus, currentBranch) -- 488
	local branches = branchStatus and branchStatus.data and branchStatus.data.branches or { } -- 489
	if not (currentBranch and currentBranch ~= "") then -- 490
		return branches -- 490
	end -- 490
	for _index_0 = 1, #branches do -- 491
		local branch = branches[_index_0] -- 491
		if branch.name == currentBranch then -- 492
			return branches -- 492
		end -- 492
	end -- 491
	local withHead -- 493
	do -- 493
		local _accum_0 = { } -- 493
		local _len_0 = 1 -- 493
		for _index_0 = 1, #branches do -- 493
			local branch = branches[_index_0] -- 493
			_accum_0[_len_0] = branch -- 493
			_len_0 = _len_0 + 1 -- 493
		end -- 493
		withHead = _accum_0 -- 493
	end -- 493
	withHead[#withHead + 1] = { -- 494
		name = currentBranch, -- 494
		current = true, -- 494
		unborn = true -- 494
	} -- 494
	return withHead -- 495
end -- 488
local gitStatusMeansNotRepo -- 497
gitStatusMeansNotRepo = function(statusRes) -- 497
	local message = statusRes and (statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message)) or "" -- 498
	message = tostring(message):lower() -- 499
	return message:find("repository does not exist", 1, true) or message:find("not a git repository", 1, true) -- 500
end -- 497
local gitSummary -- 502
gitSummary = function(repoPath) -- 502
	local statusRes = gitRunSync(repoPath, "status", nil, 120) -- 503
	if not statusRes.success then -- 504
		if gitStatusMeansNotRepo(statusRes) then -- 505
			return { -- 506
				success = true, -- 506
				isRepo = false, -- 506
				message = statusRes.message, -- 506
				status = statusRes.status -- 506
			} -- 506
		end -- 505
		return { -- 507
			success = false, -- 507
			message = statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message) or "failed to check Git repository", -- 507
			status = statusRes.status -- 507
		} -- 507
	end -- 504
	local branchRes = gitRunSync(repoPath, "branch", nil, 120) -- 508
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 120) -- 509
	local status = statusRes.status -- 510
	local branchStatus = branchRes.status -- 511
	local remoteStatus = remoteRes.status -- 512
	local currentBranch = gitCurrentBranch(branchStatus) or gitHeadBranch(repoPath) -- 513
	local branches = gitBranchesWithHead(branchStatus, currentBranch) -- 514
	local logRes = gitRunSync(repoPath, "log --metadata-only -n 100", nil, 120) -- 515
	local logStatus -- 516
	if logRes.success then -- 516
		logStatus = logRes.status -- 517
	else -- 519
		logStatus = { -- 520
			state = "done", -- 520
			kind = "log", -- 521
			repoPath = repoPath, -- 522
			progress = 1, -- 523
			message = "git log completed", -- 524
			data = { -- 525
				commits = { } -- 525
			} -- 525
		} -- 519
	end -- 516
	local hasCommit = logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] ~= nil -- 527
	local tagStatus -- 528
	if hasCommit then -- 528
		tagStatus = (gitRunSync(repoPath, "tag", nil, 120)).status -- 529
	else -- 531
		tagStatus = { -- 532
			state = "done", -- 532
			kind = "tag", -- 533
			repoPath = repoPath, -- 534
			progress = 1, -- 535
			message = "git tag completed", -- 536
			data = { -- 537
				tags = { } -- 537
			} -- 537
		} -- 531
	end -- 528
	local defaultRemote = gitDefaultRemote(remoteStatus) -- 539
	local lastCommit = nil -- 540
	if logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] then -- 541
		lastCommit = logStatus.data.commits[1] -- 542
	end -- 541
	return { -- 544
		success = true, -- 544
		isRepo = true, -- 545
		clean = status.data and status.data.clean or false, -- 546
		currentBranch = currentBranch, -- 547
		defaultRemote = defaultRemote, -- 548
		remotes = remoteStatus and remoteStatus.data and remoteStatus.data.remotes or { }, -- 549
		branches = branches, -- 550
		lastCommit = lastCommit, -- 551
		status = status, -- 552
		branchStatus = branchStatus, -- 553
		remoteStatus = remoteStatus, -- 554
		historyStatus = logStatus, -- 555
		tagStatus = tagStatus -- 556
	} -- 543
end -- 502
HttpServer:post("/git/run", function(req) -- 558
	do -- 559
		local _type_0 = type(req) -- 559
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 559
		if _tab_0 then -- 559
			local body = req.body -- 559
			if body ~= nil then -- 559
				local repoPath, command, authId, optionsJSON = body.repoPath, body.command, body.authId, body.optionsJSON -- 560
				if authId and not optionsJSON then -- 561
					local credential = gitLoadCredential(authId) -- 562
					if credential then -- 562
						optionsJSON = gitAuthOptionsJSON(credential) -- 563
						DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 564
							os.time(), -- 564
							credential.id -- 564
						}) -- 564
					end -- 562
				elseif not optionsJSON then -- 565
					local authOk, authSelection = pcall(gitAuthSelectionForCommand, repoPath, command) -- 566
					if not authOk then -- 567
						authSelection = nil -- 567
					end -- 567
					if authSelection then -- 568
						if #authSelection.items == 1 then -- 569
							local credential = gitLoadCredential(authSelection.items[1].id) -- 570
							optionsJSON = gitAuthOptionsJSON(credential) -- 571
							DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 572
								os.time(), -- 572
								credential.id -- 572
							}) -- 572
						else -- 574
							return { -- 574
								success = false, -- 574
								message = "select a Git credential", -- 574
								needsCredentialSelection = true, -- 574
								host = authSelection.host, -- 574
								credentials = authSelection.items -- 574
							} -- 574
						end -- 569
					end -- 568
				end -- 561
				local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 575
				if not jobId then -- 576
					return { -- 576
						success = false, -- 576
						message = err -- 576
					} -- 576
				end -- 576
				return { -- 577
					success = true, -- 577
					jobId = jobId -- 577
				} -- 577
			end -- 559
		end -- 559
	end -- 559
	return invalidArguments -- 558
end) -- 558
HttpServer:post("/git/status", function(req) -- 579
	do -- 580
		local _type_0 = type(req) -- 580
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 580
		if _tab_0 then -- 580
			local jobId -- 580
			do -- 580
				local _obj_0 = req.body -- 580
				local _type_1 = type(_obj_0) -- 580
				if "table" == _type_1 or "userdata" == _type_1 then -- 580
					jobId = _obj_0.jobId -- 580
				end -- 580
			end -- 580
			if jobId ~= nil then -- 580
				local job = GitJobs[tonumber(jobId) or 0] -- 581
				if not job then -- 582
					return { -- 582
						success = false, -- 582
						message = "git job not found" -- 582
					} -- 582
				end -- 582
				return { -- 583
					success = true, -- 583
					status = job.status, -- 583
					command = job.command -- 583
				} -- 583
			end -- 580
		end -- 580
	end -- 580
	return invalidArguments -- 579
end) -- 579
HttpServer:post("/git/cancel", function(req) -- 585
	do -- 586
		local _type_0 = type(req) -- 586
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 586
		if _tab_0 then -- 586
			local jobId -- 586
			do -- 586
				local _obj_0 = req.body -- 586
				local _type_1 = type(_obj_0) -- 586
				if "table" == _type_1 or "userdata" == _type_1 then -- 586
					jobId = _obj_0.jobId -- 586
				end -- 586
			end -- 586
			if jobId ~= nil then -- 586
				local id = tonumber(jobId) -- 587
				if not id then -- 588
					return { -- 588
						success = false, -- 588
						message = "invalid jobId" -- 588
					} -- 588
				end -- 588
				return { -- 589
					success = Git:cancel(id) -- 589
				} -- 589
			end -- 586
		end -- 586
	end -- 586
	return invalidArguments -- 585
end) -- 585
HttpServer:postSchedule("/git/summary", function(req) -- 591
	do -- 592
		local _type_0 = type(req) -- 592
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 592
		if _tab_0 then -- 592
			local repoPath -- 592
			do -- 592
				local _obj_0 = req.body -- 592
				local _type_1 = type(_obj_0) -- 592
				if "table" == _type_1 or "userdata" == _type_1 then -- 592
					repoPath = _obj_0.repoPath -- 592
				end -- 592
			end -- 592
			if repoPath ~= nil then -- 592
				if gitInvalidRepoPath(repoPath) then -- 593
					return { -- 593
						success = false, -- 593
						message = "invalid repoPath" -- 593
					} -- 593
				end -- 593
				return gitSummary(repoPath) -- 594
			end -- 592
		end -- 592
	end -- 592
	return invalidArguments -- 591
end) -- 591
HttpServer:postSchedule("/git/status-files", function(req) -- 596
	do -- 597
		local _type_0 = type(req) -- 597
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 597
		if _tab_0 then -- 597
			local repoPath -- 597
			do -- 597
				local _obj_0 = req.body -- 597
				local _type_1 = type(_obj_0) -- 597
				if "table" == _type_1 or "userdata" == _type_1 then -- 597
					repoPath = _obj_0.repoPath -- 597
				end -- 597
			end -- 597
			if repoPath ~= nil then -- 597
				return gitRunSync(repoPath, "status", nil, 120) -- 598
			end -- 597
		end -- 597
	end -- 597
	return invalidArguments -- 596
end) -- 596
HttpServer:postSchedule("/git/discard-untracked", function(req) -- 600
	do -- 601
		local _type_0 = type(req) -- 601
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 601
		if _tab_0 then -- 601
			local body = req.body -- 601
			if body ~= nil then -- 601
				local repoPath, paths = body.repoPath, body.paths -- 602
				if gitInvalidRepoPath(repoPath) then -- 603
					return { -- 603
						success = false, -- 603
						message = "invalid repoPath" -- 603
					} -- 603
				end -- 603
				if not (type(paths) == "table") then -- 604
					return { -- 604
						success = false, -- 604
						message = "invalid paths" -- 604
					} -- 604
				end -- 604
				local statusRes = gitRunSync(repoPath, "status", nil, 10) -- 605
				if not statusRes.success then -- 606
					return statusRes -- 606
				end -- 606
				local untracked = { } -- 607
				local _list_0 = (statusRes.status.data and statusRes.status.data.files or { }) -- 608
				for _index_0 = 1, #_list_0 do -- 608
					local file = _list_0[_index_0] -- 608
					if file.staging == "?" or file.worktree == "?" then -- 609
						untracked[file.path] = true -- 610
					end -- 609
				end -- 608
				local removed = { } -- 611
				for _index_0 = 1, #paths do -- 612
					local relPath = paths[_index_0] -- 612
					relPath = tostring(relPath) -- 613
					if not gitPathInsideRepo(repoPath, relPath) then -- 614
						return { -- 614
							success = false, -- 614
							message = "unsafe path: " .. tostring(relPath) -- 614
						} -- 614
					end -- 614
					if not untracked[relPath] then -- 615
						return { -- 615
							success = false, -- 615
							message = "path is not untracked: " .. tostring(relPath) -- 615
						} -- 615
					end -- 615
				end -- 612
				for _index_0 = 1, #paths do -- 616
					local relPath = paths[_index_0] -- 616
					local targetPath = Path(repoPath, tostring(relPath)) -- 617
					if Content:exist(targetPath) then -- 618
						Content:remove(targetPath) -- 619
						removed[#removed + 1] = tostring(relPath) -- 620
					end -- 618
				end -- 616
				return { -- 621
					success = true, -- 621
					removed = removed -- 621
				} -- 621
			end -- 601
		end -- 601
	end -- 601
	return invalidArguments -- 600
end) -- 600
HttpServer:postSchedule("/git/file-diff", function(req) -- 623
	do -- 624
		local _type_0 = type(req) -- 624
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 624
		if _tab_0 then -- 624
			local body = req.body -- 624
			if body ~= nil then -- 624
				local repoPath, path, staged = body.repoPath, body.path, body.staged -- 625
				if gitInvalidRepoPath(repoPath) then -- 626
					return { -- 626
						success = false, -- 626
						message = "invalid repoPath" -- 626
					} -- 626
				end -- 626
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 627
					return { -- 627
						success = false, -- 627
						message = "unsafe path" -- 627
					} -- 627
				end -- 627
				local command -- 628
				if staged == true then -- 628
					command = "diff --staged -- " .. tostring(gitQuote(path)) -- 629
				else -- 631
					command = "diff -- " .. tostring(gitQuote(path)) -- 631
				end -- 628
				local res = gitRunSync(repoPath, command, nil, 10) -- 632
				if not res.success then -- 633
					return res -- 633
				end -- 633
				return { -- 634
					success = true, -- 634
					status = res.status, -- 634
					data = res.status and res.status.data -- 634
				} -- 634
			end -- 624
		end -- 624
	end -- 624
	return invalidArguments -- 623
end) -- 623
HttpServer:postSchedule("/git/commit-file-diff", function(req) -- 636
	do -- 637
		local _type_0 = type(req) -- 637
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 637
		if _tab_0 then -- 637
			local body = req.body -- 637
			if body ~= nil then -- 637
				local repoPath, commit, path = body.repoPath, body.commit, body.path -- 638
				if gitInvalidRepoPath(repoPath) then -- 639
					return { -- 639
						success = false, -- 639
						message = "invalid repoPath" -- 639
					} -- 639
				end -- 639
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 640
					return { -- 640
						success = false, -- 640
						message = "invalid commit" -- 640
					} -- 640
				end -- 640
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 641
					return { -- 641
						success = false, -- 641
						message = "unsafe path" -- 641
					} -- 641
				end -- 641
				local res = gitRunSync(repoPath, "diff " .. tostring(gitQuote(commit)) .. " -- " .. tostring(gitQuote(path)), nil, 10) -- 642
				if not res.success then -- 643
					return res -- 643
				end -- 643
				return { -- 644
					success = true, -- 644
					status = res.status, -- 644
					data = res.status and res.status.data -- 644
				} -- 644
			end -- 637
		end -- 637
	end -- 637
	return invalidArguments -- 636
end) -- 636
HttpServer:postSchedule("/git/history", function(req) -- 646
	do -- 647
		local _type_0 = type(req) -- 647
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 647
		if _tab_0 then -- 647
			local body = req.body -- 647
			if body ~= nil then -- 647
				local repoPath, limit = body.repoPath, body.limit -- 648
				limit = math.max(1, math.min(100, tonumber(limit) or 20)) -- 649
				return gitRunSync(repoPath, "log --metadata-only -n " .. tostring(limit), nil, 10) -- 650
			end -- 647
		end -- 647
	end -- 647
	return invalidArguments -- 646
end) -- 646
HttpServer:postSchedule("/git/remotes", function(req) -- 652
	do -- 653
		local _type_0 = type(req) -- 653
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 653
		if _tab_0 then -- 653
			local body = req.body -- 653
			if body ~= nil then -- 653
				local repoPath, command = body.repoPath, body.command -- 654
				command = command or "remote -v" -- 655
				return gitRunSync(repoPath, command, nil, 10) -- 656
			end -- 653
		end -- 653
	end -- 653
	return invalidArguments -- 652
end) -- 652
HttpServer:postSchedule("/git/branches", function(req) -- 658
	do -- 659
		local _type_0 = type(req) -- 659
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 659
		if _tab_0 then -- 659
			local body = req.body -- 659
			if body ~= nil then -- 659
				local repoPath, command = body.repoPath, body.command -- 660
				command = command or "branch" -- 661
				return gitRunSync(repoPath, command, nil, 10) -- 662
			end -- 659
		end -- 659
	end -- 659
	return invalidArguments -- 658
end) -- 658
HttpServer:postSchedule("/git/tags", function(req) -- 664
	do -- 665
		local _type_0 = type(req) -- 665
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 665
		if _tab_0 then -- 665
			local body = req.body -- 665
			if body ~= nil then -- 665
				local repoPath, command = body.repoPath, body.command -- 666
				command = command or "tag" -- 667
				return gitRunSync(repoPath, command, nil, 10) -- 668
			end -- 665
		end -- 665
	end -- 665
	return invalidArguments -- 664
end) -- 664
HttpServer:post("/git/profile/get", function() -- 670
	ensureGitTables() -- 671
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 672
	local profile -- 673
	if rows and rows[1] then -- 673
		profile = { -- 674
			name = rows[1][1], -- 674
			email = rows[1][2] -- 674
		} -- 674
	else -- 676
		profile = { -- 676
			name = "", -- 676
			email = "" -- 676
		} -- 676
	end -- 673
	return { -- 677
		success = true, -- 677
		profile = profile -- 677
	} -- 677
end) -- 670
HttpServer:post("/git/profile/save", function(req) -- 679
	do -- 680
		local _type_0 = type(req) -- 680
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 680
		if _tab_0 then -- 680
			local name -- 680
			do -- 680
				local _obj_0 = req.body -- 680
				local _type_1 = type(_obj_0) -- 680
				if "table" == _type_1 or "userdata" == _type_1 then -- 680
					name = _obj_0.name -- 680
				end -- 680
			end -- 680
			local email -- 680
			do -- 680
				local _obj_0 = req.body -- 680
				local _type_1 = type(_obj_0) -- 680
				if "table" == _type_1 or "userdata" == _type_1 then -- 680
					email = _obj_0.email -- 680
				end -- 680
			end -- 680
			if name ~= nil and email ~= nil then -- 680
				ensureGitTables() -- 681
				DB:exec("insert into GitProfile(id, name, email, updated_at) values(1, ?, ?, ?) on conflict(id) do update set name = excluded.name, email = excluded.email, updated_at = excluded.updated_at", { -- 683
					tostring(name or ""), -- 683
					tostring(email or ""), -- 684
					os.time() -- 685
				}) -- 682
				return { -- 687
					success = true -- 687
				} -- 687
			end -- 680
		end -- 680
	end -- 680
	return invalidArguments -- 679
end) -- 679
HttpServer:post("/git/auth/list", function(req) -- 689
	ensureGitTables() -- 690
	local host = nil -- 691
	do -- 692
		local _type_0 = type(req) -- 692
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 692
		if _tab_0 then -- 692
			local body = req.body -- 692
			if body ~= nil then -- 692
				host = body.host -- 693
			end -- 692
		end -- 692
	end -- 692
	local rows -- 694
	if host and host ~= "" then -- 694
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by host asc, label asc, id asc", { -- 695
			tostring(host):lower() -- 695
		}) -- 695
	else -- 697
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential order by host asc, label asc, id asc") -- 697
	end -- 694
	local items -- 698
	if rows then -- 698
		local _accum_0 = { } -- 698
		local _len_0 = 1 -- 698
		for _index_0 = 1, #rows do -- 698
			local row = rows[_index_0] -- 698
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 698
			_len_0 = _len_0 + 1 -- 698
		end -- 698
		items = _accum_0 -- 698
	else -- 698
		items = { } -- 698
	end -- 698
	return { -- 699
		success = true, -- 699
		items = items -- 699
	} -- 699
end) -- 689
HttpServer:postSchedule("/git/auth/match", function(req) -- 701
	do -- 702
		local _type_0 = type(req) -- 702
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 702
		if _tab_0 then -- 702
			local body = req.body -- 702
			if body ~= nil then -- 702
				if not (type(body) == "table") then -- 703
					return invalidArguments -- 703
				end -- 703
				local repoPath, command, url = body.repoPath, body.command, body.url -- 704
				if url ~= nil and type(url) ~= "string" then -- 705
					return invalidArguments -- 705
				end -- 705
				if not (type(url) == "string" and url ~= "") then -- 706
					if not (type(repoPath) == "string" and type(command) == "string") then -- 707
						return invalidArguments -- 707
					end -- 707
				end -- 706
				local host -- 708
				if url and url ~= "" then -- 708
					host = gitHostFromURL(url) -- 708
				else -- 708
					host = gitCommandHost(repoPath, command) -- 708
				end -- 708
				if not host then -- 709
					return { -- 709
						success = false, -- 709
						message = "git host is required" -- 709
					} -- 709
				end -- 709
				local items = gitCredentialsForHost(host) -- 710
				return { -- 711
					success = true, -- 711
					host = host, -- 711
					items = items, -- 711
					needsSelection = #items > 1, -- 711
					authId = (#items == 1 and items[1].id or nil) -- 711
				} -- 711
			end -- 702
		end -- 702
	end -- 702
	return invalidArguments -- 701
end) -- 701
HttpServer:post("/git/auth/save", function(req) -- 713
	do -- 714
		local _type_0 = type(req) -- 714
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 714
		if _tab_0 then -- 714
			local body = req.body -- 714
			if body ~= nil then -- 714
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token -- 715
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$") -- 716
				label = tostring(label or ""):match("^%s*(.-)%s*$") -- 717
				local credentialType = tostring(body.type or "token") -- 718
				username = tostring(username or "") -- 719
				local secret -- 720
				if credentialType == "basic" then -- 720
					secret = tostring(password or "") -- 720
				else -- 720
					secret = tostring(token or password or "") -- 720
				end -- 720
				if host == "" then -- 721
					return { -- 721
						success = false, -- 721
						message = "host is required" -- 721
					} -- 721
				end -- 721
				if label == "" then -- 722
					return { -- 722
						success = false, -- 722
						message = "label is required" -- 722
					} -- 722
				end -- 722
				if secret == "" then -- 723
					return { -- 723
						success = false, -- 723
						message = "secret is required" -- 723
					} -- 723
				end -- 723
				if not (("basic" == credentialType or "token" == credentialType)) then -- 724
					return { -- 724
						success = false, -- 724
						message = "invalid type" -- 724
					} -- 724
				end -- 724
				ensureGitTables() -- 725
				local now = os.time() -- 726
				if id then -- 727
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", { -- 729
						host, -- 729
						label, -- 729
						credentialType, -- 729
						username, -- 729
						secret, -- 729
						now, -- 729
						(tonumber(id) or 0) -- 729
					}) -- 728
					return { -- 731
						success = true, -- 731
						id = tonumber(id) -- 731
					} -- 731
				else -- 733
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", { -- 734
						host, -- 734
						label, -- 734
						credentialType, -- 734
						username, -- 734
						secret, -- 734
						now, -- 734
						now -- 734
					}) -- 733
					local rows = DB:query("select last_insert_rowid()") -- 736
					return { -- 737
						success = true, -- 737
						id = rows and rows[1] and rows[1][1] -- 737
					} -- 737
				end -- 727
			end -- 714
		end -- 714
	end -- 714
	return invalidArguments -- 713
end) -- 713
HttpServer:post("/git/auth/delete", function(req) -- 739
	do -- 740
		local _type_0 = type(req) -- 740
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 740
		if _tab_0 then -- 740
			local id -- 740
			do -- 740
				local _obj_0 = req.body -- 740
				local _type_1 = type(_obj_0) -- 740
				if "table" == _type_1 or "userdata" == _type_1 then -- 740
					id = _obj_0.id -- 740
				end -- 740
			end -- 740
			if id ~= nil then -- 740
				ensureGitTables() -- 741
				local credentialId = tonumber(id) or 0 -- 742
				DB:exec("delete from GitCredential where id = ?", { -- 743
					credentialId -- 743
				}) -- 743
				return { -- 744
					success = true -- 744
				} -- 744
			end -- 740
		end -- 740
	end -- 740
	return invalidArguments -- 739
end) -- 739
HttpServer:postSchedule("/git/auth/test", function(req) -- 746
	do -- 747
		local _type_0 = type(req) -- 747
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 747
		if _tab_0 then -- 747
			local body = req.body -- 747
			if body ~= nil then -- 747
				local repoPath, url, authId = body.repoPath, body.url, body.authId -- 748
				local credential = gitLoadCredential(authId) -- 749
				local optionsJSON = gitAuthOptionsJSON(credential) -- 750
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20) -- 751
			end -- 747
		end -- 747
	end -- 747
	return invalidArguments -- 746
end) -- 746
HttpServer:post("/agent/session/create", function(req) -- 753
	do -- 754
		local _type_0 = type(req) -- 754
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 754
		if _tab_0 then -- 754
			local projectRoot -- 754
			do -- 754
				local _obj_0 = req.body -- 754
				local _type_1 = type(_obj_0) -- 754
				if "table" == _type_1 or "userdata" == _type_1 then -- 754
					projectRoot = _obj_0.projectRoot -- 754
				end -- 754
			end -- 754
			local title -- 754
			do -- 754
				local _obj_0 = req.body -- 754
				local _type_1 = type(_obj_0) -- 754
				if "table" == _type_1 or "userdata" == _type_1 then -- 754
					title = _obj_0.title -- 754
				end -- 754
			end -- 754
			if projectRoot ~= nil and title ~= nil then -- 754
				return AgentSession.createSession(projectRoot, title) -- 755
			end -- 754
		end -- 754
	end -- 754
	return invalidArguments -- 753
end) -- 753
HttpServer:post("/agent/session/create-sub", function(req) -- 757
	do -- 758
		local _type_0 = type(req) -- 758
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 758
		if _tab_0 then -- 758
			local parentSessionId -- 758
			do -- 758
				local _obj_0 = req.body -- 758
				local _type_1 = type(_obj_0) -- 758
				if "table" == _type_1 or "userdata" == _type_1 then -- 758
					parentSessionId = _obj_0.parentSessionId -- 758
				end -- 758
			end -- 758
			local title -- 758
			do -- 758
				local _obj_0 = req.body -- 758
				local _type_1 = type(_obj_0) -- 758
				if "table" == _type_1 or "userdata" == _type_1 then -- 758
					title = _obj_0.title -- 758
				end -- 758
			end -- 758
			if parentSessionId ~= nil and title ~= nil then -- 758
				return AgentSession.createSubSession(parentSessionId, title) -- 759
			end -- 758
		end -- 758
	end -- 758
	return invalidArguments -- 757
end) -- 757
HttpServer:post("/agent/session/get", function(req) -- 761
	do -- 762
		local _type_0 = type(req) -- 762
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 762
		if _tab_0 then -- 762
			local sessionId -- 762
			do -- 762
				local _obj_0 = req.body -- 762
				local _type_1 = type(_obj_0) -- 762
				if "table" == _type_1 or "userdata" == _type_1 then -- 762
					sessionId = _obj_0.sessionId -- 762
				end -- 762
			end -- 762
			if sessionId ~= nil then -- 762
				return AgentSession.getSession(sessionId) -- 763
			end -- 762
		end -- 762
	end -- 762
	return invalidArguments -- 761
end) -- 761
HttpServer:post("/agent/vision/asset", function(req) -- 765
	do -- 766
		local _type_0 = type(req) -- 766
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 766
		if _tab_0 then -- 766
			local sessionId -- 766
			do -- 766
				local _obj_0 = req.body -- 766
				local _type_1 = type(_obj_0) -- 766
				if "table" == _type_1 or "userdata" == _type_1 then -- 766
					sessionId = _obj_0.sessionId -- 766
				end -- 766
			end -- 766
			local path -- 766
			do -- 766
				local _obj_0 = req.body -- 766
				local _type_1 = type(_obj_0) -- 766
				if "table" == _type_1 or "userdata" == _type_1 then -- 766
					path = _obj_0.path -- 766
				end -- 766
			end -- 766
			if sessionId ~= nil and path ~= nil then -- 766
				return AgentVisionAssets.getSessionVisionImageFromPath(sessionId, path) -- 767
			end -- 766
		end -- 766
	end -- 766
	return invalidArguments -- 765
end) -- 765
HttpServer:post("/agent/session/mode", function(req) -- 769
	do -- 770
		local _type_0 = type(req) -- 770
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 770
		if _tab_0 then -- 770
			local sessionId -- 770
			do -- 770
				local _obj_0 = req.body -- 770
				local _type_1 = type(_obj_0) -- 770
				if "table" == _type_1 or "userdata" == _type_1 then -- 770
					sessionId = _obj_0.sessionId -- 770
				end -- 770
			end -- 770
			local workMode -- 770
			do -- 770
				local _obj_0 = req.body -- 770
				local _type_1 = type(_obj_0) -- 770
				if "table" == _type_1 or "userdata" == _type_1 then -- 770
					workMode = _obj_0.workMode -- 770
				end -- 770
			end -- 770
			if sessionId ~= nil and workMode ~= nil then -- 770
				return AgentSession.setWorkMode(sessionId, workMode) -- 771
			end -- 770
		end -- 770
	end -- 770
	return invalidArguments -- 769
end) -- 769
HttpServer:post("/agent/session/send", function(req) -- 773
	do -- 774
		local _type_0 = type(req) -- 774
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 774
		if _tab_0 then -- 774
			local sessionId -- 774
			do -- 774
				local _obj_0 = req.body -- 774
				local _type_1 = type(_obj_0) -- 774
				if "table" == _type_1 or "userdata" == _type_1 then -- 774
					sessionId = _obj_0.sessionId -- 774
				end -- 774
			end -- 774
			local prompt -- 774
			do -- 774
				local _obj_0 = req.body -- 774
				local _type_1 = type(_obj_0) -- 774
				if "table" == _type_1 or "userdata" == _type_1 then -- 774
					prompt = _obj_0.prompt -- 774
				end -- 774
			end -- 774
			if sessionId ~= nil and prompt ~= nil then -- 774
				return AgentSession.sendPrompt(sessionId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 775
			end -- 774
		end -- 774
	end -- 774
	return invalidArguments -- 773
end) -- 773
HttpServer:post("/agent/session/send-local", function(req) -- 777
	do -- 778
		local _type_0 = type(req) -- 778
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 778
		if _tab_0 then -- 778
			local sessionId -- 778
			do -- 778
				local _obj_0 = req.body -- 778
				local _type_1 = type(_obj_0) -- 778
				if "table" == _type_1 or "userdata" == _type_1 then -- 778
					sessionId = _obj_0.sessionId -- 778
				end -- 778
			end -- 778
			local prompt -- 778
			do -- 778
				local _obj_0 = req.body -- 778
				local _type_1 = type(_obj_0) -- 778
				if "table" == _type_1 or "userdata" == _type_1 then -- 778
					prompt = _obj_0.prompt -- 778
				end -- 778
			end -- 778
			local localAgentConfigId -- 778
			do -- 778
				local _obj_0 = req.body -- 778
				local _type_1 = type(_obj_0) -- 778
				if "table" == _type_1 or "userdata" == _type_1 then -- 778
					localAgentConfigId = _obj_0.localAgentConfigId -- 778
				end -- 778
			end -- 778
			if sessionId ~= nil and prompt ~= nil and localAgentConfigId ~= nil then -- 778
				return AgentSession.sendLocalPrompt(sessionId, prompt, localAgentConfigId) -- 779
			end -- 778
		end -- 778
	end -- 778
	return invalidArguments -- 777
end) -- 777
HttpServer:post("/agent/session/local/new", function(req) -- 781
	do -- 782
		local _type_0 = type(req) -- 782
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 782
		if _tab_0 then -- 782
			local sessionId -- 782
			do -- 782
				local _obj_0 = req.body -- 782
				local _type_1 = type(_obj_0) -- 782
				if "table" == _type_1 or "userdata" == _type_1 then -- 782
					sessionId = _obj_0.sessionId -- 782
				end -- 782
			end -- 782
			if sessionId ~= nil then -- 782
				return AgentLocalAgent.abandonSession(sessionId) -- 783
			end -- 782
		end -- 782
	end -- 782
	return invalidArguments -- 781
end) -- 781
HttpServer:post("/agent/session/local/info", function(req) -- 785
	do -- 786
		local _type_0 = type(req) -- 786
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 786
		if _tab_0 then -- 786
			local sessionId -- 786
			do -- 786
				local _obj_0 = req.body -- 786
				local _type_1 = type(_obj_0) -- 786
				if "table" == _type_1 or "userdata" == _type_1 then -- 786
					sessionId = _obj_0.sessionId -- 786
				end -- 786
			end -- 786
			if sessionId ~= nil then -- 786
				local info = AgentLocalAgent.getSessionInfo(sessionId) -- 787
				return { -- 788
					success = true, -- 788
					info = info -- 788
				} -- 788
			end -- 786
		end -- 786
	end -- 786
	return invalidArguments -- 785
end) -- 785
HttpServer:post("/agent/session/continue", function(req) -- 790
	do -- 791
		local _type_0 = type(req) -- 791
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 791
		if _tab_0 then -- 791
			local sessionId -- 791
			do -- 791
				local _obj_0 = req.body -- 791
				local _type_1 = type(_obj_0) -- 791
				if "table" == _type_1 or "userdata" == _type_1 then -- 791
					sessionId = _obj_0.sessionId -- 791
				end -- 791
			end -- 791
			if sessionId ~= nil then -- 791
				return AgentSession.continuePrompt(sessionId, req.body.disabledAgentTools, req.body.llmConfigId) -- 792
			end -- 791
		end -- 791
	end -- 791
	return invalidArguments -- 790
end) -- 790
HttpServer:post("/agent/session/finish-handoff", function(req) -- 794
	do -- 795
		local _type_0 = type(req) -- 795
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 795
		if _tab_0 then -- 795
			local sessionId -- 795
			do -- 795
				local _obj_0 = req.body -- 795
				local _type_1 = type(_obj_0) -- 795
				if "table" == _type_1 or "userdata" == _type_1 then -- 795
					sessionId = _obj_0.sessionId -- 795
				end -- 795
			end -- 795
			if sessionId ~= nil then -- 795
				return AgentSession.finishSubSessionHandoff(sessionId, req.body.llmConfigId) -- 796
			end -- 795
		end -- 795
	end -- 795
	return invalidArguments -- 794
end) -- 794
HttpServer:post("/agent/session/resend", function(req) -- 798
	do -- 799
		local _type_0 = type(req) -- 799
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 799
		if _tab_0 then -- 799
			local sessionId -- 799
			do -- 799
				local _obj_0 = req.body -- 799
				local _type_1 = type(_obj_0) -- 799
				if "table" == _type_1 or "userdata" == _type_1 then -- 799
					sessionId = _obj_0.sessionId -- 799
				end -- 799
			end -- 799
			local messageId -- 799
			do -- 799
				local _obj_0 = req.body -- 799
				local _type_1 = type(_obj_0) -- 799
				if "table" == _type_1 or "userdata" == _type_1 then -- 799
					messageId = _obj_0.messageId -- 799
				end -- 799
			end -- 799
			local prompt -- 799
			do -- 799
				local _obj_0 = req.body -- 799
				local _type_1 = type(_obj_0) -- 799
				if "table" == _type_1 or "userdata" == _type_1 then -- 799
					prompt = _obj_0.prompt -- 799
				end -- 799
			end -- 799
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 799
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 800
			end -- 799
		end -- 799
	end -- 799
	return invalidArguments -- 798
end) -- 798
HttpServer:post("/agent/session/questionnaire/respond", function(req) -- 802
	do -- 803
		local _type_0 = type(req) -- 803
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 803
		if _tab_0 then -- 803
			local sessionId -- 803
			do -- 803
				local _obj_0 = req.body -- 803
				local _type_1 = type(_obj_0) -- 803
				if "table" == _type_1 or "userdata" == _type_1 then -- 803
					sessionId = _obj_0.sessionId -- 803
				end -- 803
			end -- 803
			local questionnaireId -- 803
			do -- 803
				local _obj_0 = req.body -- 803
				local _type_1 = type(_obj_0) -- 803
				if "table" == _type_1 or "userdata" == _type_1 then -- 803
					questionnaireId = _obj_0.questionnaireId -- 803
				end -- 803
			end -- 803
			local answers -- 803
			do -- 803
				local _obj_0 = req.body -- 803
				local _type_1 = type(_obj_0) -- 803
				if "table" == _type_1 or "userdata" == _type_1 then -- 803
					answers = _obj_0.answers -- 803
				end -- 803
			end -- 803
			if sessionId ~= nil and questionnaireId ~= nil and answers ~= nil then -- 803
				return AgentSession.respondQuestionnaire(sessionId, questionnaireId, answers, req.body.llmConfigId) -- 804
			end -- 803
		end -- 803
	end -- 803
	return invalidArguments -- 802
end) -- 802
HttpServer:post("/agent/session/questionnaire/cancel", function(req) -- 806
	do -- 807
		local _type_0 = type(req) -- 807
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 807
		if _tab_0 then -- 807
			local sessionId -- 807
			do -- 807
				local _obj_0 = req.body -- 807
				local _type_1 = type(_obj_0) -- 807
				if "table" == _type_1 or "userdata" == _type_1 then -- 807
					sessionId = _obj_0.sessionId -- 807
				end -- 807
			end -- 807
			local questionnaireId -- 807
			do -- 807
				local _obj_0 = req.body -- 807
				local _type_1 = type(_obj_0) -- 807
				if "table" == _type_1 or "userdata" == _type_1 then -- 807
					questionnaireId = _obj_0.questionnaireId -- 807
				end -- 807
			end -- 807
			if sessionId ~= nil and questionnaireId ~= nil then -- 807
				return AgentSession.cancelQuestionnaire(sessionId, questionnaireId, req.body.llmConfigId) -- 808
			end -- 807
		end -- 807
	end -- 807
	return invalidArguments -- 806
end) -- 806
HttpServer:post("/agent/task/status", function(req) -- 810
	do -- 811
		local _type_0 = type(req) -- 811
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 811
		if _tab_0 then -- 811
			local sessionId -- 811
			do -- 811
				local _obj_0 = req.body -- 811
				local _type_1 = type(_obj_0) -- 811
				if "table" == _type_1 or "userdata" == _type_1 then -- 811
					sessionId = _obj_0.sessionId -- 811
				end -- 811
			end -- 811
			if sessionId ~= nil then -- 811
				local res = AgentSession.getSession(sessionId) -- 812
				if not res.success then -- 813
					return res -- 813
				end -- 813
				local taskId = res.session.currentTaskId -- 814
				local checkpoints -- 815
				if taskId then -- 815
					checkpoints = AgentTools.listCheckpoints(taskId) -- 815
				else -- 815
					checkpoints = { } -- 815
				end -- 815
				return { -- 817
					success = true, -- 817
					session = res.session, -- 818
					relatedSessions = res.relatedSessions, -- 819
					spawnInfo = res.spawnInfo, -- 820
					messages = res.messages, -- 821
					steps = res.steps, -- 822
					checkpoints = checkpoints, -- 823
					pendingQuestionnaire = res.pendingQuestionnaire, -- 824
					hasActivePlan = res.hasActivePlan -- 825
				} -- 816
			end -- 811
		end -- 811
	end -- 811
	return invalidArguments -- 810
end) -- 810
HttpServer:post("/agent/task/running", function() -- 827
	local res = AgentSession.listRunningSessions() -- 828
	if res.success and #res.sessions == 0 then -- 829
		res.sessions = nil -- 830
	end -- 829
	return res -- 831
end) -- 827
HttpServer:post("/agent/task/stop", function(req) -- 833
	do -- 834
		local _type_0 = type(req) -- 834
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 834
		if _tab_0 then -- 834
			local sessionId -- 834
			do -- 834
				local _obj_0 = req.body -- 834
				local _type_1 = type(_obj_0) -- 834
				if "table" == _type_1 or "userdata" == _type_1 then -- 834
					sessionId = _obj_0.sessionId -- 834
				end -- 834
			end -- 834
			if sessionId ~= nil then -- 834
				return AgentSession.stopSessionTask(sessionId) -- 835
			end -- 834
		end -- 834
	end -- 834
	return invalidArguments -- 833
end) -- 833
HttpServer:post("/agent/checkpoint/list", function(req) -- 837
	do -- 838
		local _type_0 = type(req) -- 838
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 838
		if _tab_0 then -- 838
			local taskId -- 838
			do -- 838
				local _obj_0 = req.body -- 838
				local _type_1 = type(_obj_0) -- 838
				if "table" == _type_1 or "userdata" == _type_1 then -- 838
					taskId = _obj_0.taskId -- 838
				end -- 838
			end -- 838
			local sessionId -- 838
			do -- 838
				local _obj_0 = req.body -- 838
				local _type_1 = type(_obj_0) -- 838
				if "table" == _type_1 or "userdata" == _type_1 then -- 838
					sessionId = _obj_0.sessionId -- 838
				end -- 838
			end -- 838
			if sessionId ~= nil then -- 838
				if not taskId and sessionId then -- 839
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 840
				end -- 839
				if not taskId then -- 841
					return { -- 841
						success = false, -- 841
						message = "task not found" -- 841
					} -- 841
				end -- 841
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 842
				if not access.success then -- 843
					return access -- 843
				end -- 843
				return { -- 845
					success = true, -- 845
					taskId = taskId, -- 846
					checkpoints = AgentTools.listCheckpoints(taskId) -- 847
				} -- 844
			end -- 838
		end -- 838
	end -- 838
	return invalidArguments -- 837
end) -- 837
HttpServer:post("/agent/checkpoint/diff", function(req) -- 849
	do -- 850
		local _type_0 = type(req) -- 850
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 850
		if _tab_0 then -- 850
			local sessionId -- 850
			do -- 850
				local _obj_0 = req.body -- 850
				local _type_1 = type(_obj_0) -- 850
				if "table" == _type_1 or "userdata" == _type_1 then -- 850
					sessionId = _obj_0.sessionId -- 850
				end -- 850
			end -- 850
			local checkpointId -- 850
			do -- 850
				local _obj_0 = req.body -- 850
				local _type_1 = type(_obj_0) -- 850
				if "table" == _type_1 or "userdata" == _type_1 then -- 850
					checkpointId = _obj_0.checkpointId -- 850
				end -- 850
			end -- 850
			if sessionId ~= nil and checkpointId ~= nil then -- 850
				if not (checkpointId > 0) then -- 851
					return { -- 851
						success = false, -- 851
						message = "invalid checkpointId" -- 851
					} -- 851
				end -- 851
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 852
				if not access.success then -- 853
					return access -- 853
				end -- 853
				return AgentTools.getCheckpointDiff(checkpointId) -- 854
			end -- 850
		end -- 850
	end -- 850
	return invalidArguments -- 849
end) -- 849
HttpServer:post("/agent/task/diff", function(req) -- 856
	do -- 857
		local _type_0 = type(req) -- 857
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 857
		if _tab_0 then -- 857
			local sessionId -- 857
			do -- 857
				local _obj_0 = req.body -- 857
				local _type_1 = type(_obj_0) -- 857
				if "table" == _type_1 or "userdata" == _type_1 then -- 857
					sessionId = _obj_0.sessionId -- 857
				end -- 857
			end -- 857
			local taskId -- 857
			do -- 857
				local _obj_0 = req.body -- 857
				local _type_1 = type(_obj_0) -- 857
				if "table" == _type_1 or "userdata" == _type_1 then -- 857
					taskId = _obj_0.taskId -- 857
				end -- 857
			end -- 857
			if sessionId ~= nil and taskId ~= nil then -- 857
				if not (taskId > 0) then -- 858
					return { -- 858
						success = false, -- 858
						message = "invalid taskId" -- 858
					} -- 858
				end -- 858
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 859
				if not access.success then -- 860
					return access -- 860
				end -- 860
				return AgentTools.getTaskChangeSetDiff(taskId) -- 861
			end -- 857
		end -- 857
	end -- 857
	return invalidArguments -- 856
end) -- 856
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 863
	do -- 864
		local _type_0 = type(req) -- 864
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 864
		if _tab_0 then -- 864
			local sessionId -- 864
			do -- 864
				local _obj_0 = req.body -- 864
				local _type_1 = type(_obj_0) -- 864
				if "table" == _type_1 or "userdata" == _type_1 then -- 864
					sessionId = _obj_0.sessionId -- 864
				end -- 864
			end -- 864
			local checkpointId -- 864
			do -- 864
				local _obj_0 = req.body -- 864
				local _type_1 = type(_obj_0) -- 864
				if "table" == _type_1 or "userdata" == _type_1 then -- 864
					checkpointId = _obj_0.checkpointId -- 864
				end -- 864
			end -- 864
			if sessionId ~= nil and checkpointId ~= nil then -- 864
				if not (checkpointId > 0) then -- 865
					return { -- 865
						success = false, -- 865
						message = "invalid checkpointId" -- 865
					} -- 865
				end -- 865
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 866
				if not access.success then -- 867
					return access -- 867
				end -- 867
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, access.session.projectRoot) -- 868
				if not rollbackRes.success then -- 869
					return rollbackRes -- 869
				end -- 869
				return { -- 871
					success = true, -- 871
					checkpointId = rollbackRes.checkpointId -- 872
				} -- 870
			end -- 864
		end -- 864
	end -- 864
	return invalidArguments -- 863
end) -- 863
HttpServer:post("/agent/task/rollback", function(req) -- 874
	do -- 875
		local _type_0 = type(req) -- 875
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 875
		if _tab_0 then -- 875
			local sessionId -- 875
			do -- 875
				local _obj_0 = req.body -- 875
				local _type_1 = type(_obj_0) -- 875
				if "table" == _type_1 or "userdata" == _type_1 then -- 875
					sessionId = _obj_0.sessionId -- 875
				end -- 875
			end -- 875
			local taskId -- 875
			do -- 875
				local _obj_0 = req.body -- 875
				local _type_1 = type(_obj_0) -- 875
				if "table" == _type_1 or "userdata" == _type_1 then -- 875
					taskId = _obj_0.taskId -- 875
				end -- 875
			end -- 875
			if sessionId ~= nil and taskId ~= nil then -- 875
				if not (taskId > 0) then -- 876
					return { -- 876
						success = false, -- 876
						message = "invalid taskId" -- 876
					} -- 876
				end -- 876
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 877
				if not access.success then -- 878
					return access -- 878
				end -- 878
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, access.session.projectRoot) -- 879
				if not rollbackRes.success then -- 880
					return rollbackRes -- 880
				end -- 880
				return { -- 882
					success = true, -- 882
					taskId = rollbackRes.taskId, -- 883
					checkpointId = rollbackRes.checkpointId, -- 884
					checkpointCount = rollbackRes.checkpointCount -- 885
				} -- 881
			end -- 875
		end -- 875
	end -- 875
	return invalidArguments -- 874
end) -- 874
local getSearchPath -- 887
getSearchPath = function(file) -- 887
	do -- 888
		local dir = getProjectDirFromFile(file) -- 888
		if dir then -- 888
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 889
		end -- 888
	end -- 888
	return "" -- 887
end -- 887
local getSearchFolders -- 891
getSearchFolders = function(file) -- 891
	do -- 892
		local dir = getProjectDirFromFile(file) -- 892
		if dir then -- 892
			return { -- 894
				Path(dir, "Script"), -- 894
				dir -- 895
			} -- 893
		end -- 892
	end -- 892
	return { } -- 891
end -- 891
local disabledCheckForLua = { -- 898
	"incompatible number of returns", -- 898
	"unknown", -- 899
	"cannot index", -- 900
	"module not found", -- 901
	"don't know how to resolve", -- 902
	"ContainerItem", -- 903
	"cannot resolve a type", -- 904
	"invalid key", -- 905
	"inconsistent index type", -- 906
	"cannot use operator", -- 907
	"attempting ipairs loop", -- 908
	"expects record or nominal", -- 909
	"variable is not being assigned", -- 910
	"<invalid type>", -- 911
	"<any type>", -- 912
	"using the '#' operator", -- 913
	"can't match a record", -- 914
	"redeclaration of variable", -- 915
	"cannot apply pairs", -- 916
	"not a function", -- 917
	"to%-be%-closed" -- 918
} -- 897
local yueCheck -- 920
yueCheck = function(file, content, lax) -- 920
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 921
	if isTIC80 then -- 922
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 923
	end -- 922
	local searchPath = getSearchPath(file) -- 924
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 925
	local info = { } -- 926
	local globals = { } -- 927
	for _index_0 = 1, #checkResult do -- 928
		local _des_0 = checkResult[_index_0] -- 928
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 928
		if "error" == t then -- 929
			info[#info + 1] = { -- 930
				"syntax", -- 930
				file, -- 930
				line, -- 930
				col, -- 930
				msg -- 930
			} -- 930
		elseif "global" == t then -- 931
			globals[#globals + 1] = { -- 932
				msg, -- 932
				line, -- 932
				col -- 932
			} -- 932
		end -- 929
	end -- 928
	if luaCodes then -- 933
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 934
		if success then -- 935
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 936
			if not (lintResult == "") then -- 937
				lintResult = lintResult .. "\n" -- 937
			end -- 937
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 938
		else -- 939
			for _index_0 = 1, #lintResult do -- 939
				local _des_0 = lintResult[_index_0] -- 939
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 939
				if isTIC80 and tic80APIs[name] then -- 940
					goto _continue_0 -- 940
				end -- 940
				info[#info + 1] = { -- 941
					"syntax", -- 941
					file, -- 941
					line, -- 941
					col, -- 941
					"invalid global variable" -- 941
				} -- 941
				::_continue_0:: -- 940
			end -- 939
		end -- 935
	end -- 933
	return luaCodes, info -- 942
end -- 920
local luaCheck -- 944
luaCheck = function(file, content) -- 944
	local res, err = load(content, "check") -- 945
	if not res then -- 946
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 947
		return { -- 948
			success = false, -- 948
			info = { -- 948
				{ -- 948
					"syntax", -- 948
					file, -- 948
					tonumber(line), -- 948
					0, -- 948
					msg -- 948
				} -- 948
			} -- 948
		} -- 948
	end -- 946
	local success, info = teal.checkAsync(content, file, true, "") -- 949
	if info then -- 950
		do -- 951
			local _accum_0 = { } -- 951
			local _len_0 = 1 -- 951
			for _index_0 = 1, #info do -- 951
				local item = info[_index_0] -- 951
				local useCheck = true -- 952
				if not item[5]:match("unused") then -- 953
					for _index_1 = 1, #disabledCheckForLua do -- 954
						local check = disabledCheckForLua[_index_1] -- 954
						if item[5]:match(check) then -- 955
							useCheck = false -- 956
						end -- 955
					end -- 954
				end -- 953
				if not useCheck then -- 957
					goto _continue_0 -- 957
				end -- 957
				do -- 958
					local _exp_0 = item[1] -- 958
					if "type" == _exp_0 then -- 959
						item[1] = "warning" -- 960
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 961
						goto _continue_0 -- 962
					end -- 958
				end -- 958
				_accum_0[_len_0] = item -- 963
				_len_0 = _len_0 + 1 -- 952
				::_continue_0:: -- 952
			end -- 951
			info = _accum_0 -- 951
		end -- 951
		if #info == 0 then -- 964
			info = nil -- 965
			success = true -- 966
		end -- 964
	end -- 950
	return { -- 967
		success = success, -- 967
		info = info -- 967
	} -- 967
end -- 944
local luaCheckWithLineInfo -- 969
luaCheckWithLineInfo = function(file, luaCodes) -- 969
	local res = luaCheck(file, luaCodes) -- 970
	local info = { } -- 971
	if not res.success then -- 972
		local current = 1 -- 973
		local lastLine = 1 -- 974
		local lineMap = { } -- 975
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 976
			local num = lineCode:match("--%s*(%d+)%s*$") -- 977
			if num then -- 978
				lastLine = tonumber(num) -- 979
			end -- 978
			lineMap[current] = lastLine -- 980
			current = current + 1 -- 981
		end -- 976
		local _list_0 = res.info -- 982
		for _index_0 = 1, #_list_0 do -- 982
			local item = _list_0[_index_0] -- 982
			item[3] = lineMap[item[3]] or 0 -- 983
			item[4] = 0 -- 984
			info[#info + 1] = item -- 985
		end -- 982
		return false, info -- 986
	end -- 972
	return true, info -- 987
end -- 969
local getCompiledYueLine -- 989
getCompiledYueLine = function(content, line, row, file, lax) -- 989
	local luaCodes = yueCheck(file, content, lax) -- 990
	if not luaCodes then -- 991
		return nil -- 991
	end -- 991
	local current = 1 -- 992
	local lastLine = 1 -- 993
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 994
	local targetRow = nil -- 995
	local lineMap = { } -- 996
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 997
		local num = lineCode:match("--%s*(%d+)%s*$") -- 998
		if num then -- 999
			lastLine = tonumber(num) -- 999
		end -- 999
		lineMap[current] = lastLine -- 1000
		if row <= lastLine and not targetRow then -- 1001
			targetRow = current -- 1002
			break -- 1003
		end -- 1001
		current = current + 1 -- 1004
	end -- 997
	targetRow = current -- 1005
	if targetLine and targetRow then -- 1006
		return luaCodes, targetLine, targetRow, lineMap -- 1007
	else -- 1009
		return nil -- 1009
	end -- 1006
end -- 989
HttpServer:postSchedule("/check", function(req) -- 1011
	do -- 1012
		local _type_0 = type(req) -- 1012
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1012
		if _tab_0 then -- 1012
			local file -- 1012
			do -- 1012
				local _obj_0 = req.body -- 1012
				local _type_1 = type(_obj_0) -- 1012
				if "table" == _type_1 or "userdata" == _type_1 then -- 1012
					file = _obj_0.file -- 1012
				end -- 1012
			end -- 1012
			local content -- 1012
			do -- 1012
				local _obj_0 = req.body -- 1012
				local _type_1 = type(_obj_0) -- 1012
				if "table" == _type_1 or "userdata" == _type_1 then -- 1012
					content = _obj_0.content -- 1012
				end -- 1012
			end -- 1012
			if file ~= nil and content ~= nil then -- 1012
				local ext = Path:getExt(file) -- 1013
				if "tl" == ext then -- 1014
					local searchPath = getSearchPath(file) -- 1015
					do -- 1016
						local isTIC80 = CheckTIC80Code(content) -- 1016
						if isTIC80 then -- 1016
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1017
						end -- 1016
					end -- 1016
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 1018
					return { -- 1019
						success = success, -- 1019
						info = info -- 1019
					} -- 1019
				elseif "lua" == ext then -- 1020
					do -- 1021
						local isTIC80 = CheckTIC80Code(content) -- 1021
						if isTIC80 then -- 1021
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1022
						end -- 1021
					end -- 1021
					return luaCheck(file, content) -- 1023
				elseif "yue" == ext then -- 1024
					local luaCodes, info = yueCheck(file, content, false) -- 1025
					local success = luaCodes ~= nil -- 1026
					if luaCodes then -- 1027
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 1028
						do -- 1029
							local _tab_1 = { } -- 1029
							local _idx_0 = #_tab_1 + 1 -- 1029
							for _index_0 = 1, #info do -- 1029
								local _value_0 = info[_index_0] -- 1029
								_tab_1[_idx_0] = _value_0 -- 1029
								_idx_0 = _idx_0 + 1 -- 1029
							end -- 1029
							local _idx_1 = #_tab_1 + 1 -- 1029
							for _index_0 = 1, #luaInfo do -- 1029
								local _value_0 = luaInfo[_index_0] -- 1029
								_tab_1[_idx_1] = _value_0 -- 1029
								_idx_1 = _idx_1 + 1 -- 1029
							end -- 1029
							info = _tab_1 -- 1029
						end -- 1029
						success = success and luaSuccess -- 1030
					end -- 1027
					if #info > 0 then -- 1031
						return { -- 1032
							success = success, -- 1032
							info = info -- 1032
						} -- 1032
					else -- 1034
						return { -- 1034
							success = success -- 1034
						} -- 1034
					end -- 1031
				elseif "xml" == ext then -- 1035
					local success, result = xml.check(content) -- 1036
					if success then -- 1037
						local info -- 1038
						success, info = luaCheckWithLineInfo(file, result) -- 1038
						if #info > 0 then -- 1039
							return { -- 1040
								success = success, -- 1040
								info = info -- 1040
							} -- 1040
						else -- 1042
							return { -- 1042
								success = success -- 1042
							} -- 1042
						end -- 1039
					else -- 1044
						local info -- 1044
						do -- 1044
							local _accum_0 = { } -- 1044
							local _len_0 = 1 -- 1044
							for _index_0 = 1, #result do -- 1044
								local _des_0 = result[_index_0] -- 1044
								local row, err = _des_0[1], _des_0[2] -- 1044
								_accum_0[_len_0] = { -- 1045
									"syntax", -- 1045
									file, -- 1045
									row, -- 1045
									0, -- 1045
									err -- 1045
								} -- 1045
								_len_0 = _len_0 + 1 -- 1045
							end -- 1044
							info = _accum_0 -- 1044
						end -- 1044
						return { -- 1046
							success = false, -- 1046
							info = info -- 1046
						} -- 1046
					end -- 1037
				end -- 1014
			end -- 1012
		end -- 1012
	end -- 1012
	return { -- 1011
		success = true -- 1011
	} -- 1011
end) -- 1011
HttpServer:post("/body/parse", function(req) -- 1048
	do -- 1049
		local _type_0 = type(req) -- 1049
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1049
		if _tab_0 then -- 1049
			local file -- 1049
			do -- 1049
				local _obj_0 = req.body -- 1049
				local _type_1 = type(_obj_0) -- 1049
				if "table" == _type_1 or "userdata" == _type_1 then -- 1049
					file = _obj_0.file -- 1049
				end -- 1049
			end -- 1049
			local content -- 1049
			do -- 1049
				local _obj_0 = req.body -- 1049
				local _type_1 = type(_obj_0) -- 1049
				if "table" == _type_1 or "userdata" == _type_1 then -- 1049
					content = _obj_0.content -- 1049
				end -- 1049
			end -- 1049
			if file ~= nil and content ~= nil then -- 1049
				if not (file:sub(-6) == ".b.lua") then -- 1050
					return { -- 1051
						success = false, -- 1051
						phase = "request", -- 1051
						message = "only .b.lua files can be converted" -- 1051
					} -- 1051
				end -- 1050
				local loader, err = load("_ENV = {}\n" .. content) -- 1052
				if not loader then -- 1053
					return { -- 1054
						success = false, -- 1054
						phase = "parse", -- 1054
						message = tostring(err) -- 1054
					} -- 1054
				end -- 1053
				local ok, data = pcall(loader) -- 1055
				if not ok then -- 1056
					return { -- 1057
						success = false, -- 1057
						phase = "execute", -- 1057
						message = tostring(data) -- 1057
					} -- 1057
				end -- 1056
				if not ("table" == type(data) and data[1] == "Array") then -- 1058
					return { -- 1059
						success = false, -- 1059
						phase = "validate", -- 1059
						message = "body lua root must be {\"Array\", ...}" -- 1059
					} -- 1059
				end -- 1058
				local text, jsonErr = json.encode(data, false, true) -- 1060
				if not text then -- 1061
					return { -- 1062
						success = false, -- 1062
						phase = "encode", -- 1062
						message = tostring(jsonErr) -- 1062
					} -- 1062
				end -- 1061
				return { -- 1063
					success = true, -- 1063
					json = text -- 1063
				} -- 1063
			end -- 1049
		end -- 1049
	end -- 1049
	return { -- 1048
		success = false, -- 1048
		phase = "request", -- 1048
		message = "invalid request" -- 1048
	} -- 1048
end) -- 1048
local updateInferedDesc -- 1065
updateInferedDesc = function(infered) -- 1065
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1066
		return -- 1066
	end -- 1066
	local key, row = infered.key, infered.row -- 1067
	local codes = Content:loadAsync(key) -- 1068
	if codes then -- 1068
		local comments = { } -- 1069
		local line = 0 -- 1070
		local skipping = false -- 1071
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1072
			line = line + 1 -- 1073
			if line >= row then -- 1074
				break -- 1074
			end -- 1074
			if lineCode:match("^%s*%-%- @") then -- 1075
				skipping = true -- 1076
				goto _continue_0 -- 1077
			end -- 1075
			local result = lineCode:match("^%s*%-%- (.+)") -- 1078
			if result then -- 1078
				if not skipping then -- 1079
					comments[#comments + 1] = result -- 1079
				end -- 1079
			elseif #comments > 0 then -- 1080
				comments = { } -- 1081
				skipping = false -- 1082
			end -- 1078
			::_continue_0:: -- 1073
		end -- 1072
		infered.doc = table.concat(comments, "\n") -- 1083
	end -- 1068
end -- 1065
HttpServer:postSchedule("/infer", function(req) -- 1085
	do -- 1086
		local _type_0 = type(req) -- 1086
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1086
		if _tab_0 then -- 1086
			local lang -- 1086
			do -- 1086
				local _obj_0 = req.body -- 1086
				local _type_1 = type(_obj_0) -- 1086
				if "table" == _type_1 or "userdata" == _type_1 then -- 1086
					lang = _obj_0.lang -- 1086
				end -- 1086
			end -- 1086
			local file -- 1086
			do -- 1086
				local _obj_0 = req.body -- 1086
				local _type_1 = type(_obj_0) -- 1086
				if "table" == _type_1 or "userdata" == _type_1 then -- 1086
					file = _obj_0.file -- 1086
				end -- 1086
			end -- 1086
			local content -- 1086
			do -- 1086
				local _obj_0 = req.body -- 1086
				local _type_1 = type(_obj_0) -- 1086
				if "table" == _type_1 or "userdata" == _type_1 then -- 1086
					content = _obj_0.content -- 1086
				end -- 1086
			end -- 1086
			local line -- 1086
			do -- 1086
				local _obj_0 = req.body -- 1086
				local _type_1 = type(_obj_0) -- 1086
				if "table" == _type_1 or "userdata" == _type_1 then -- 1086
					line = _obj_0.line -- 1086
				end -- 1086
			end -- 1086
			local row -- 1086
			do -- 1086
				local _obj_0 = req.body -- 1086
				local _type_1 = type(_obj_0) -- 1086
				if "table" == _type_1 or "userdata" == _type_1 then -- 1086
					row = _obj_0.row -- 1086
				end -- 1086
			end -- 1086
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1086
				local searchPath = getSearchPath(file) -- 1087
				if "tl" == lang or "lua" == lang then -- 1088
					if CheckTIC80Code(content) then -- 1089
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1090
					end -- 1089
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1091
					if (infered ~= nil) then -- 1092
						updateInferedDesc(infered) -- 1093
						return { -- 1094
							success = true, -- 1094
							infered = infered -- 1094
						} -- 1094
					end -- 1092
				elseif "yue" == lang then -- 1095
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1096
					if not luaCodes then -- 1097
						return { -- 1097
							success = false -- 1097
						} -- 1097
					end -- 1097
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1098
					if (infered ~= nil) then -- 1099
						local col -- 1100
						file, row, col = infered.file, infered.row, infered.col -- 1100
						if file == "" and row > 0 and col > 0 then -- 1101
							infered.row = lineMap[row] or 0 -- 1102
							infered.col = 0 -- 1103
						end -- 1101
						updateInferedDesc(infered) -- 1104
						return { -- 1105
							success = true, -- 1105
							infered = infered -- 1105
						} -- 1105
					end -- 1099
				end -- 1088
			end -- 1086
		end -- 1086
	end -- 1086
	return { -- 1085
		success = false -- 1085
	} -- 1085
end) -- 1085
local _anon_func_3 = function(doc) -- 1166
	local _accum_0 = { } -- 1166
	local _len_0 = 1 -- 1166
	local _list_0 = doc.params -- 1166
	for _index_0 = 1, #_list_0 do -- 1166
		local param = _list_0[_index_0] -- 1166
		_accum_0[_len_0] = param.name -- 1166
		_len_0 = _len_0 + 1 -- 1166
	end -- 1166
	return _accum_0 -- 1166
end -- 1166
local getParamDocs -- 1107
getParamDocs = function(signatures) -- 1107
	if not (signatures and #signatures > 0) then -- 1108
		return nil -- 1108
	end -- 1108
	local docs = { } -- 1109
	do -- 1110
		local codes = Content:loadAsync(signatures[1].file) -- 1110
		if codes then -- 1110
			local comments = { } -- 1111
			local params = { } -- 1112
			local line = 0 -- 1113
			local returnType = nil -- 1114
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1115
				line = line + 1 -- 1116
				local needBreak = true -- 1117
				for i, _des_0 in ipairs(signatures) do -- 1118
					local row = _des_0.row -- 1118
					if line >= row and not (docs[i] ~= nil) then -- 1119
						if #comments > 0 or #params > 0 or returnType then -- 1120
							docs[i] = { -- 1122
								doc = table.concat(comments, "  \n"), -- 1122
								returnType = returnType -- 1123
							} -- 1121
							if #params > 0 then -- 1125
								docs[i].params = params -- 1125
							end -- 1125
						else -- 1127
							docs[i] = false -- 1127
						end -- 1120
					end -- 1119
					if not docs[i] then -- 1128
						needBreak = false -- 1128
					end -- 1128
				end -- 1118
				if needBreak then -- 1129
					break -- 1129
				end -- 1129
				local result = lineCode:match("%s*%-%- (.+)") -- 1130
				if result then -- 1130
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1131
					if not name then -- 1132
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1133
					end -- 1132
					if name then -- 1134
						local pname = name -- 1135
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1136
							pname = pname .. "?" -- 1136
						end -- 1136
						params[#params + 1] = { -- 1138
							name = tostring(pname) .. ": " .. tostring(typ), -- 1138
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1139
						} -- 1137
					else -- 1142
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1142
						if typ then -- 1142
							if returnType then -- 1143
								returnType = returnType .. ", " .. typ -- 1144
							else -- 1146
								returnType = typ -- 1146
							end -- 1143
							result = result:gsub("@return", "**return:**") -- 1147
						end -- 1142
						comments[#comments + 1] = result -- 1148
					end -- 1134
				elseif #comments > 0 then -- 1149
					comments = { } -- 1150
					params = { } -- 1151
					returnType = nil -- 1152
				end -- 1130
			end -- 1115
		end -- 1110
	end -- 1110
	local results = { } -- 1153
	for i, signature in ipairs(signatures) do -- 1154
		local item = { -- 1156
			desc = signature.desc, -- 1156
			doc = "", -- 1157
			file = signature.file, -- 1158
			row = signature.row, -- 1159
			col = signature.col -- 1160
		} -- 1155
		do -- 1162
			local doc = docs[i] -- 1162
			if doc then -- 1162
				item.doc = doc.doc -- 1163
				if doc.params then -- 1164
					item.params = doc.params -- 1165
					item.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1166
				elseif doc.returnType then -- 1167
					item.desc = "function()" -- 1168
				end -- 1164
				if doc.returnType then -- 1169
					item.desc = item.desc .. ": " .. tostring(doc.returnType) -- 1169
				end -- 1169
			end -- 1162
		end -- 1162
		results[#results + 1] = item -- 1170
	end -- 1154
	return results -- 1171
end -- 1107
HttpServer:postSchedule("/signature", function(req) -- 1173
	do -- 1174
		local _type_0 = type(req) -- 1174
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1174
		if _tab_0 then -- 1174
			local lang -- 1174
			do -- 1174
				local _obj_0 = req.body -- 1174
				local _type_1 = type(_obj_0) -- 1174
				if "table" == _type_1 or "userdata" == _type_1 then -- 1174
					lang = _obj_0.lang -- 1174
				end -- 1174
			end -- 1174
			local file -- 1174
			do -- 1174
				local _obj_0 = req.body -- 1174
				local _type_1 = type(_obj_0) -- 1174
				if "table" == _type_1 or "userdata" == _type_1 then -- 1174
					file = _obj_0.file -- 1174
				end -- 1174
			end -- 1174
			local content -- 1174
			do -- 1174
				local _obj_0 = req.body -- 1174
				local _type_1 = type(_obj_0) -- 1174
				if "table" == _type_1 or "userdata" == _type_1 then -- 1174
					content = _obj_0.content -- 1174
				end -- 1174
			end -- 1174
			local line -- 1174
			do -- 1174
				local _obj_0 = req.body -- 1174
				local _type_1 = type(_obj_0) -- 1174
				if "table" == _type_1 or "userdata" == _type_1 then -- 1174
					line = _obj_0.line -- 1174
				end -- 1174
			end -- 1174
			local row -- 1174
			do -- 1174
				local _obj_0 = req.body -- 1174
				local _type_1 = type(_obj_0) -- 1174
				if "table" == _type_1 or "userdata" == _type_1 then -- 1174
					row = _obj_0.row -- 1174
				end -- 1174
			end -- 1174
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1174
				local searchPath = getSearchPath(file) -- 1175
				if "tl" == lang or "lua" == lang then -- 1176
					if CheckTIC80Code(content) then -- 1177
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1178
					end -- 1177
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1179
					if signatures then -- 1179
						signatures = getParamDocs(signatures) -- 1180
						if signatures then -- 1180
							return { -- 1181
								success = true, -- 1181
								signatures = signatures -- 1181
							} -- 1181
						end -- 1180
					end -- 1179
				elseif "yue" == lang then -- 1182
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1183
					if not luaCodes then -- 1184
						return { -- 1184
							success = false -- 1184
						} -- 1184
					end -- 1184
					do -- 1185
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1185
						if chainOp then -- 1185
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1186
							if withVar then -- 1186
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1187
							end -- 1186
						end -- 1185
					end -- 1185
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1188
					if signatures then -- 1188
						signatures = getParamDocs(signatures) -- 1189
						if signatures then -- 1189
							return { -- 1190
								success = true, -- 1190
								signatures = signatures -- 1190
							} -- 1190
						end -- 1189
					else -- 1191
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1191
						if signatures then -- 1191
							signatures = getParamDocs(signatures) -- 1192
							if signatures then -- 1192
								return { -- 1193
									success = true, -- 1193
									signatures = signatures -- 1193
								} -- 1193
							end -- 1192
						end -- 1191
					end -- 1188
				end -- 1176
			end -- 1174
		end -- 1174
	end -- 1174
	return { -- 1173
		success = false -- 1173
	} -- 1173
end) -- 1173
local luaKeywords = { -- 1196
	'and', -- 1196
	'break', -- 1197
	'do', -- 1198
	'else', -- 1199
	'elseif', -- 1200
	'end', -- 1201
	'false', -- 1202
	'for', -- 1203
	'function', -- 1204
	'goto', -- 1205
	'if', -- 1206
	'in', -- 1207
	'local', -- 1208
	'nil', -- 1209
	'not', -- 1210
	'or', -- 1211
	'repeat', -- 1212
	'return', -- 1213
	'then', -- 1214
	'true', -- 1215
	'until', -- 1216
	'while' -- 1217
} -- 1195
local tealKeywords = { -- 1221
	'record', -- 1221
	'as', -- 1222
	'is', -- 1223
	'type', -- 1224
	'embed', -- 1225
	'enum', -- 1226
	'global', -- 1227
	'any', -- 1228
	'boolean', -- 1229
	'integer', -- 1230
	'number', -- 1231
	'string', -- 1232
	'thread' -- 1233
} -- 1220
local yueKeywords = { -- 1237
	"and", -- 1237
	"break", -- 1238
	"do", -- 1239
	"else", -- 1240
	"elseif", -- 1241
	"false", -- 1242
	"for", -- 1243
	"goto", -- 1244
	"if", -- 1245
	"in", -- 1246
	"local", -- 1247
	"nil", -- 1248
	"not", -- 1249
	"or", -- 1250
	"repeat", -- 1251
	"return", -- 1252
	"then", -- 1253
	"true", -- 1254
	"until", -- 1255
	"while", -- 1256
	"as", -- 1257
	"class", -- 1258
	"continue", -- 1259
	"export", -- 1260
	"extends", -- 1261
	"from", -- 1262
	"global", -- 1263
	"import", -- 1264
	"macro", -- 1265
	"switch", -- 1266
	"try", -- 1267
	"unless", -- 1268
	"using", -- 1269
	"when", -- 1270
	"with" -- 1271
} -- 1236
local _anon_func_4 = function(f) -- 1307
	local _val_0 = Path:getExt(f) -- 1307
	return "ttf" == _val_0 or "otf" == _val_0 -- 1307
end -- 1307
local _anon_func_5 = function(suggestions) -- 1333
	local _tbl_0 = { } -- 1333
	for _index_0 = 1, #suggestions do -- 1333
		local item = suggestions[_index_0] -- 1333
		_tbl_0[item[1] .. item[2]] = item -- 1333
	end -- 1333
	return _tbl_0 -- 1333
end -- 1333
HttpServer:postSchedule("/complete", function(req) -- 1274
	do -- 1275
		local _type_0 = type(req) -- 1275
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1275
		if _tab_0 then -- 1275
			local lang -- 1275
			do -- 1275
				local _obj_0 = req.body -- 1275
				local _type_1 = type(_obj_0) -- 1275
				if "table" == _type_1 or "userdata" == _type_1 then -- 1275
					lang = _obj_0.lang -- 1275
				end -- 1275
			end -- 1275
			local file -- 1275
			do -- 1275
				local _obj_0 = req.body -- 1275
				local _type_1 = type(_obj_0) -- 1275
				if "table" == _type_1 or "userdata" == _type_1 then -- 1275
					file = _obj_0.file -- 1275
				end -- 1275
			end -- 1275
			local content -- 1275
			do -- 1275
				local _obj_0 = req.body -- 1275
				local _type_1 = type(_obj_0) -- 1275
				if "table" == _type_1 or "userdata" == _type_1 then -- 1275
					content = _obj_0.content -- 1275
				end -- 1275
			end -- 1275
			local line -- 1275
			do -- 1275
				local _obj_0 = req.body -- 1275
				local _type_1 = type(_obj_0) -- 1275
				if "table" == _type_1 or "userdata" == _type_1 then -- 1275
					line = _obj_0.line -- 1275
				end -- 1275
			end -- 1275
			local row -- 1275
			do -- 1275
				local _obj_0 = req.body -- 1275
				local _type_1 = type(_obj_0) -- 1275
				if "table" == _type_1 or "userdata" == _type_1 then -- 1275
					row = _obj_0.row -- 1275
				end -- 1275
			end -- 1275
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1275
				local searchPath = getSearchPath(file) -- 1276
				repeat -- 1277
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1278
					if lang == "yue" then -- 1279
						if not item then -- 1280
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1280
						end -- 1280
						if not item then -- 1281
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1281
						end -- 1281
					end -- 1279
					local searchType = nil -- 1282
					if not item then -- 1283
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1284
						if lang == "yue" then -- 1285
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1286
						end -- 1285
						if (item ~= nil) then -- 1287
							searchType = "Image" -- 1287
						end -- 1287
					end -- 1283
					if not item then -- 1288
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1289
						if lang == "yue" then -- 1290
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1291
						end -- 1290
						if (item ~= nil) then -- 1292
							searchType = "Font" -- 1292
						end -- 1292
					end -- 1288
					if not item then -- 1293
						break -- 1293
					end -- 1293
					local searchPaths = Content.searchPaths -- 1294
					local _list_0 = getSearchFolders(file) -- 1295
					for _index_0 = 1, #_list_0 do -- 1295
						local folder = _list_0[_index_0] -- 1295
						searchPaths[#searchPaths + 1] = folder -- 1296
					end -- 1295
					if searchType then -- 1297
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1297
					end -- 1297
					local tokens -- 1298
					do -- 1298
						local _accum_0 = { } -- 1298
						local _len_0 = 1 -- 1298
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1298
							_accum_0[_len_0] = mod -- 1298
							_len_0 = _len_0 + 1 -- 1298
						end -- 1298
						tokens = _accum_0 -- 1298
					end -- 1298
					local suggestions = { } -- 1299
					for _index_0 = 1, #searchPaths do -- 1300
						local path = searchPaths[_index_0] -- 1300
						local sPath = Path(path, table.unpack(tokens)) -- 1301
						if not Content:exist(sPath) then -- 1302
							goto _continue_0 -- 1302
						end -- 1302
						if searchType == "Font" then -- 1303
							local fontPath = Path(sPath, "Font") -- 1304
							if Content:exist(fontPath) then -- 1305
								local _list_1 = Content:getFiles(fontPath) -- 1306
								for _index_1 = 1, #_list_1 do -- 1306
									local f = _list_1[_index_1] -- 1306
									if _anon_func_4(f) then -- 1307
										if "." == f:sub(1, 1) then -- 1308
											goto _continue_1 -- 1308
										end -- 1308
										suggestions[#suggestions + 1] = { -- 1309
											Path:getName(f), -- 1309
											"font", -- 1309
											"field" -- 1309
										} -- 1309
									end -- 1307
									::_continue_1:: -- 1307
								end -- 1306
							end -- 1305
						end -- 1303
						local _list_1 = Content:getFiles(sPath) -- 1310
						for _index_1 = 1, #_list_1 do -- 1310
							local f = _list_1[_index_1] -- 1310
							if "Image" == searchType then -- 1311
								do -- 1312
									local _exp_0 = Path:getExt(f) -- 1312
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1312
										if "." == f:sub(1, 1) then -- 1313
											goto _continue_2 -- 1313
										end -- 1313
										suggestions[#suggestions + 1] = { -- 1314
											f, -- 1314
											"image", -- 1314
											"field" -- 1314
										} -- 1314
									end -- 1312
								end -- 1312
								goto _continue_2 -- 1315
							elseif "Font" == searchType then -- 1316
								do -- 1317
									local _exp_0 = Path:getExt(f) -- 1317
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1317
										if "." == f:sub(1, 1) then -- 1318
											goto _continue_2 -- 1318
										end -- 1318
										suggestions[#suggestions + 1] = { -- 1319
											f, -- 1319
											"font", -- 1319
											"field" -- 1319
										} -- 1319
									end -- 1317
								end -- 1317
								goto _continue_2 -- 1320
							end -- 1311
							local _exp_0 = Path:getExt(f) -- 1321
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1321
								local name = Path:getName(f) -- 1322
								if "d" == Path:getExt(name) then -- 1323
									goto _continue_2 -- 1323
								end -- 1323
								if "." == name:sub(1, 1) then -- 1324
									goto _continue_2 -- 1324
								end -- 1324
								suggestions[#suggestions + 1] = { -- 1325
									name, -- 1325
									"module", -- 1325
									"field" -- 1325
								} -- 1325
							end -- 1321
							::_continue_2:: -- 1311
						end -- 1310
						local _list_2 = Content:getDirs(sPath) -- 1326
						for _index_1 = 1, #_list_2 do -- 1326
							local dir = _list_2[_index_1] -- 1326
							if "." == dir:sub(1, 1) then -- 1327
								goto _continue_3 -- 1327
							end -- 1327
							suggestions[#suggestions + 1] = { -- 1328
								dir, -- 1328
								"folder", -- 1328
								"variable" -- 1328
							} -- 1328
							::_continue_3:: -- 1327
						end -- 1326
						::_continue_0:: -- 1301
					end -- 1300
					if item == "" and not searchType then -- 1329
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1330
						for _index_0 = 1, #_list_1 do -- 1330
							local _des_0 = _list_1[_index_0] -- 1330
							local name = _des_0[1] -- 1330
							suggestions[#suggestions + 1] = { -- 1331
								name, -- 1331
								"dora module", -- 1331
								"function" -- 1331
							} -- 1331
						end -- 1330
					end -- 1329
					if #suggestions > 0 then -- 1332
						do -- 1333
							local _accum_0 = { } -- 1333
							local _len_0 = 1 -- 1333
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1333
								_accum_0[_len_0] = v -- 1333
								_len_0 = _len_0 + 1 -- 1333
							end -- 1333
							suggestions = _accum_0 -- 1333
						end -- 1333
						return { -- 1334
							success = true, -- 1334
							suggestions = suggestions -- 1334
						} -- 1334
					else -- 1336
						return { -- 1336
							success = false -- 1336
						} -- 1336
					end -- 1332
				until true -- 1277
				if "tl" == lang or "lua" == lang then -- 1338
					do -- 1339
						local isTIC80 = CheckTIC80Code(content) -- 1339
						if isTIC80 then -- 1339
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1340
						end -- 1339
					end -- 1339
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1341
					if not line:match("[%.:]$") then -- 1342
						local checkSet -- 1343
						do -- 1343
							local _tbl_0 = { } -- 1343
							for _index_0 = 1, #suggestions do -- 1343
								local _des_0 = suggestions[_index_0] -- 1343
								local name = _des_0[1] -- 1343
								_tbl_0[name] = true -- 1343
							end -- 1343
							checkSet = _tbl_0 -- 1343
						end -- 1343
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1344
						for _index_0 = 1, #_list_0 do -- 1344
							local item = _list_0[_index_0] -- 1344
							if not checkSet[item[1]] then -- 1345
								suggestions[#suggestions + 1] = item -- 1345
							end -- 1345
						end -- 1344
						for _index_0 = 1, #luaKeywords do -- 1346
							local word = luaKeywords[_index_0] -- 1346
							suggestions[#suggestions + 1] = { -- 1347
								word, -- 1347
								"keyword", -- 1347
								"keyword" -- 1347
							} -- 1347
						end -- 1346
						if lang == "tl" then -- 1348
							for _index_0 = 1, #tealKeywords do -- 1349
								local word = tealKeywords[_index_0] -- 1349
								suggestions[#suggestions + 1] = { -- 1350
									word, -- 1350
									"keyword", -- 1350
									"keyword" -- 1350
								} -- 1350
							end -- 1349
						end -- 1348
					end -- 1342
					if #suggestions > 0 then -- 1351
						return { -- 1352
							success = true, -- 1352
							suggestions = suggestions -- 1352
						} -- 1352
					end -- 1351
				elseif "yue" == lang then -- 1353
					local suggestions = { } -- 1354
					local gotGlobals = false -- 1355
					do -- 1356
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1356
						if luaCodes then -- 1356
							gotGlobals = true -- 1357
							do -- 1358
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1358
								if chainOp then -- 1358
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1359
									if not withVar then -- 1360
										return { -- 1360
											success = false -- 1360
										} -- 1360
									end -- 1360
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1361
								elseif line:match("^([%.\\])$") then -- 1362
									return { -- 1363
										success = false -- 1363
									} -- 1363
								end -- 1358
							end -- 1358
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1364
							for _index_0 = 1, #_list_0 do -- 1364
								local item = _list_0[_index_0] -- 1364
								suggestions[#suggestions + 1] = item -- 1364
							end -- 1364
							if #suggestions == 0 then -- 1365
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1366
								for _index_0 = 1, #_list_1 do -- 1366
									local item = _list_1[_index_0] -- 1366
									suggestions[#suggestions + 1] = item -- 1366
								end -- 1366
							end -- 1365
						end -- 1356
					end -- 1356
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1367
						local checkSet -- 1368
						do -- 1368
							local _tbl_0 = { } -- 1368
							for _index_0 = 1, #suggestions do -- 1368
								local _des_0 = suggestions[_index_0] -- 1368
								local name = _des_0[1] -- 1368
								_tbl_0[name] = true -- 1368
							end -- 1368
							checkSet = _tbl_0 -- 1368
						end -- 1368
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1369
						for _index_0 = 1, #_list_0 do -- 1369
							local item = _list_0[_index_0] -- 1369
							if not checkSet[item[1]] then -- 1370
								suggestions[#suggestions + 1] = item -- 1370
							end -- 1370
						end -- 1369
						if not gotGlobals then -- 1371
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1372
							for _index_0 = 1, #_list_1 do -- 1372
								local item = _list_1[_index_0] -- 1372
								if not checkSet[item[1]] then -- 1373
									suggestions[#suggestions + 1] = item -- 1373
								end -- 1373
							end -- 1372
						end -- 1371
						for _index_0 = 1, #yueKeywords do -- 1374
							local word = yueKeywords[_index_0] -- 1374
							if not checkSet[word] then -- 1375
								suggestions[#suggestions + 1] = { -- 1376
									word, -- 1376
									"keyword", -- 1376
									"keyword" -- 1376
								} -- 1376
							end -- 1375
						end -- 1374
					end -- 1367
					if #suggestions > 0 then -- 1377
						return { -- 1378
							success = true, -- 1378
							suggestions = suggestions -- 1378
						} -- 1378
					end -- 1377
				elseif "xml" == lang then -- 1379
					local items = xml.complete(content) -- 1380
					if #items > 0 then -- 1381
						local suggestions -- 1382
						do -- 1382
							local _accum_0 = { } -- 1382
							local _len_0 = 1 -- 1382
							for _index_0 = 1, #items do -- 1382
								local _des_0 = items[_index_0] -- 1382
								local label, insertText = _des_0[1], _des_0[2] -- 1382
								_accum_0[_len_0] = { -- 1383
									label, -- 1383
									insertText, -- 1383
									"field" -- 1383
								} -- 1383
								_len_0 = _len_0 + 1 -- 1383
							end -- 1382
							suggestions = _accum_0 -- 1382
						end -- 1382
						return { -- 1384
							success = true, -- 1384
							suggestions = suggestions -- 1384
						} -- 1384
					end -- 1381
				end -- 1338
			end -- 1275
		end -- 1275
	end -- 1275
	return { -- 1274
		success = false -- 1274
	} -- 1274
end) -- 1274
local getUploadFilename -- 1386
getUploadFilename = function(req, multipartFilename) -- 1386
	local filename = req.params.name -- 1387
	if not (type(filename) == "string" and filename ~= "") then -- 1388
		filename = multipartFilename -- 1388
	end -- 1388
	if not (type(filename) == "string" and filename ~= "") then -- 1389
		return -- 1389
	end -- 1389
	if filename:sub(1, 1) == "/" or filename:sub(-1) == "/" or filename:find("//", 1, true) or filename:find("\\", 1, true) or filename:find(":", 1, true) or filename:find("\0", 1, true) then -- 1392
		return -- 1392
	end -- 1392
	local parts -- 1393
	do -- 1393
		local _accum_0 = { } -- 1393
		local _len_0 = 1 -- 1393
		for part in filename:gmatch("[^/]+") do -- 1393
			_accum_0[_len_0] = part -- 1393
			_len_0 = _len_0 + 1 -- 1393
		end -- 1393
		parts = _accum_0 -- 1393
	end -- 1393
	if #parts == 0 then -- 1394
		return -- 1394
	end -- 1394
	for _index_0 = 1, #parts do -- 1395
		local part = parts[_index_0] -- 1395
		if part == "." or part == ".." or part == "" then -- 1396
			return -- 1396
		end -- 1396
	end -- 1395
	return filename -- 1397
end -- 1386
HttpServer:upload("/upload", function(req, multipartFilename) -- 1401
	do -- 1402
		local _type_0 = type(req) -- 1402
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1402
		if _tab_0 then -- 1402
			local path -- 1402
			do -- 1402
				local _obj_0 = req.params -- 1402
				local _type_1 = type(_obj_0) -- 1402
				if "table" == _type_1 or "userdata" == _type_1 then -- 1402
					path = _obj_0.path -- 1402
				end -- 1402
			end -- 1402
			if path ~= nil then -- 1402
				local filename = getUploadFilename(req, multipartFilename) -- 1403
				if filename then -- 1403
					local uploadPath = Path(Content.writablePath, ".upload") -- 1404
					if not Content:exist(uploadPath) then -- 1405
						Content:mkdir(uploadPath) -- 1406
					end -- 1405
					local targetPath = Path(uploadPath, filename) -- 1407
					Content:mkdir(Path:getPath(targetPath)) -- 1408
					return targetPath -- 1409
				end -- 1403
			end -- 1402
		end -- 1402
	end -- 1402
	return nil -- 1401
end, function(req, file) -- 1410
	do -- 1411
		local _type_0 = type(req) -- 1411
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1411
		if _tab_0 then -- 1411
			local path -- 1411
			do -- 1411
				local _obj_0 = req.params -- 1411
				local _type_1 = type(_obj_0) -- 1411
				if "table" == _type_1 or "userdata" == _type_1 then -- 1411
					path = _obj_0.path -- 1411
				end -- 1411
			end -- 1411
			if path ~= nil then -- 1411
				path = Path(Content.writablePath, path) -- 1412
				if Content:exist(path) then -- 1413
					local uploadPath = Path(Content.writablePath, ".upload") -- 1414
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1415
					Content:mkdir(Path:getPath(targetPath)) -- 1416
					if Content:move(file, targetPath) then -- 1417
						return true -- 1418
					end -- 1417
				end -- 1413
			end -- 1411
		end -- 1411
	end -- 1411
	return false -- 1410
end) -- 1399
HttpServer:post("/list", function(req) -- 1421
	do -- 1422
		local _type_0 = type(req) -- 1422
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1422
		if _tab_0 then -- 1422
			local path -- 1422
			do -- 1422
				local _obj_0 = req.body -- 1422
				local _type_1 = type(_obj_0) -- 1422
				if "table" == _type_1 or "userdata" == _type_1 then -- 1422
					path = _obj_0.path -- 1422
				end -- 1422
			end -- 1422
			if path ~= nil then -- 1422
				if Content:exist(path) then -- 1423
					local files = { } -- 1424
					local visitAssets -- 1425
					visitAssets = function(path, folder) -- 1425
						local dirs = Content:getDirs(path) -- 1426
						for _index_0 = 1, #dirs do -- 1427
							local dir = dirs[_index_0] -- 1427
							if dir:match("^%.") or dir == "node_modules" then -- 1428
								goto _continue_0 -- 1428
							end -- 1428
							local current -- 1429
							if folder == "" then -- 1429
								current = dir -- 1430
							else -- 1432
								current = Path(folder, dir) -- 1432
							end -- 1429
							files[#files + 1] = current -- 1433
							visitAssets(Path(path, dir), current) -- 1434
							::_continue_0:: -- 1428
						end -- 1427
						local fs = Content:getFiles(path) -- 1435
						for _index_0 = 1, #fs do -- 1436
							local f = fs[_index_0] -- 1436
							if (".DS_Store" == f) then -- 1437
								goto _continue_1 -- 1438
							end -- 1437
							if folder == "" then -- 1439
								files[#files + 1] = f -- 1440
							else -- 1442
								files[#files + 1] = Path(folder, f) -- 1442
							end -- 1439
							::_continue_1:: -- 1437
						end -- 1436
					end -- 1425
					visitAssets(path, "") -- 1443
					if #files == 0 then -- 1444
						files = nil -- 1444
					end -- 1444
					return { -- 1445
						success = true, -- 1445
						files = files -- 1445
					} -- 1445
				end -- 1423
			end -- 1422
		end -- 1422
	end -- 1422
	return { -- 1421
		success = false -- 1421
	} -- 1421
end) -- 1421
HttpServer:post("/info", function(req) -- 1447
	local Entry = require("Script.Dev.Entry") -- 1448
	local config = Entry.getConfig() -- 1449
	do -- 1450
		local _type_0 = type(req) -- 1450
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1450
		if _tab_0 then -- 1450
			local webIDETourCompleted -- 1450
			do -- 1450
				local _obj_0 = req.body -- 1450
				local _type_1 = type(_obj_0) -- 1450
				if "table" == _type_1 or "userdata" == _type_1 then -- 1450
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1450
				end -- 1450
			end -- 1450
			if webIDETourCompleted ~= nil then -- 1450
				config.webIDETourCompleted = webIDETourCompleted == true -- 1451
			end -- 1450
		end -- 1450
	end -- 1450
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1452
	local engineDev = Entry.getEngineDev() -- 1453
	Entry.connectWebIDE() -- 1454
	return { -- 1456
		platform = App.platform, -- 1456
		locale = App.locale, -- 1457
		version = App.version, -- 1458
		engineDev = engineDev, -- 1459
		webProfiler = webProfiler, -- 1460
		drawerWidth = drawerWidth, -- 1461
		webIDETourCompleted = webIDETourCompleted == true -- 1462
	} -- 1455
end) -- 1447
local ensureLLMConfigTable -- 1464
ensureLLMConfigTable = function() -- 1464
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1465
	if columns and #columns > 0 then -- 1466
		local expected = { -- 1468
			id = true, -- 1468
			name = true, -- 1469
			url = true, -- 1470
			model = true, -- 1471
			api_key = true, -- 1472
			context_window = true, -- 1473
			temperature = true, -- 1474
			max_tokens = true, -- 1475
			reasoning_effort = true, -- 1476
			custom_options = true, -- 1477
			supports_function_calling = true, -- 1478
			active = true, -- 1479
			created_at = true, -- 1480
			updated_at = true -- 1481
		} -- 1467
		local existing = { } -- 1483
		local valid = true -- 1484
		for _index_0 = 1, #columns do -- 1485
			local row = columns[_index_0] -- 1485
			local columnName = tostring(row[2]) -- 1486
			existing[columnName] = true -- 1487
			if not expected[columnName] then -- 1488
				valid = false -- 1489
				break -- 1490
			end -- 1488
		end -- 1485
		if valid then -- 1491
			if not existing.context_window then -- 1492
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1493
			end -- 1492
			if not existing.temperature then -- 1494
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1495
			end -- 1494
			if not existing.max_tokens then -- 1496
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 64000") -- 1497
			end -- 1496
			if not existing.reasoning_effort then -- 1498
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1499
			end -- 1498
			if not existing.custom_options then -- 1500
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1501
			end -- 1500
			if not existing.supports_function_calling then -- 1502
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1503
			end -- 1502
		else -- 1505
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1505
		end -- 1491
	end -- 1466
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
	]]) -- 1506
	return require("Agent.LLMConfigMigration").upgradeLLMConfig() -- 1525
end -- 1464
local normalizeContextWindow -- 1527
normalizeContextWindow = function(value) -- 1527
	local contextWindow = tonumber(value) -- 1528
	if contextWindow == nil or contextWindow < 64000 then -- 1529
		return 64000 -- 1530
	end -- 1529
	return math.max(64000, math.floor(contextWindow)) -- 1531
end -- 1527
local normalizeTemperature -- 1533
normalizeTemperature = function(value) -- 1533
	local temperature = tonumber(value) -- 1534
	if temperature == nil then -- 1535
		return 0.1 -- 1536
	end -- 1535
	return math.max(0, math.min(2, temperature)) -- 1537
end -- 1533
local normalizeMaxTokens -- 1539
normalizeMaxTokens = function(value) -- 1539
	local maxTokens = tonumber(value) -- 1540
	if maxTokens == nil or maxTokens < 1 then -- 1541
		return 64000 -- 1542
	end -- 1541
	return math.max(1, math.floor(maxTokens)) -- 1543
end -- 1539
local normalizeReasoningEffort -- 1545
normalizeReasoningEffort = function(value) -- 1545
	if value == nil then -- 1546
		return "" -- 1547
	end -- 1546
	local effort = tostring(value) -- 1548
	return effort:match("^%s*(.-)%s*$") or "" -- 1549
end -- 1545
local normalizeCustomOptions -- 1551
normalizeCustomOptions = function(value) -- 1551
	if value == nil then -- 1552
		return "" -- 1553
	end -- 1552
	local options = tostring(value) -- 1554
	options = options:match("^%s*(.-)%s*$") or "" -- 1555
	return options -- 1556
end -- 1551
local validateCustomOptions -- 1558
validateCustomOptions = function(value) -- 1558
	local options = normalizeCustomOptions(value) -- 1559
	if options == "" then -- 1560
		return true -- 1560
	end -- 1560
	if not options:match("^%s*{") then -- 1561
		return false -- 1561
	end -- 1561
	local decoded = json.decode(options) -- 1562
	return type(decoded) == "table" -- 1563
end -- 1558
HttpServer:post("/llm/list", function() -- 1565
	ensureLLMConfigTable() -- 1566
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1567
	local items -- 1571
	if rows and #rows > 0 then -- 1571
		local _accum_0 = { } -- 1572
		local _len_0 = 1 -- 1572
		for _index_0 = 1, #rows do -- 1572
			local _des_0 = rows[_index_0] -- 1572
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1572
			_accum_0[_len_0] = { -- 1573
				id = id, -- 1573
				name = name, -- 1573
				url = url, -- 1573
				model = model, -- 1573
				key = key, -- 1573
				contextWindow = normalizeContextWindow(contextWindow), -- 1573
				temperature = normalizeTemperature(temperature), -- 1573
				maxTokens = normalizeMaxTokens(maxTokens), -- 1573
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1573
				customOptions = normalizeCustomOptions(customOptions), -- 1573
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1573
			} -- 1573
			_len_0 = _len_0 + 1 -- 1573
		end -- 1572
		items = _accum_0 -- 1571
	end -- 1571
	return { -- 1574
		success = true, -- 1574
		items = items -- 1574
	} -- 1574
end) -- 1565
HttpServer:post("/llm/create", function(req) -- 1576
	ensureLLMConfigTable() -- 1577
	do -- 1578
		local _type_0 = type(req) -- 1578
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1578
		if _tab_0 then -- 1578
			local body = req.body -- 1578
			if body ~= nil then -- 1578
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1579
				local now = os.time() -- 1580
				if name == nil or url == nil or model == nil or key == nil then -- 1581
					return invalidArguments -- 1582
				end -- 1581
				contextWindow = normalizeContextWindow(contextWindow) -- 1583
				temperature = normalizeTemperature(temperature) -- 1584
				maxTokens = normalizeMaxTokens(maxTokens) -- 1585
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1586
				customOptions = normalizeCustomOptions(customOptions) -- 1587
				if not validateCustomOptions(customOptions) then -- 1588
					return { -- 1588
						success = false, -- 1588
						message = "customOptions must be a JSON object" -- 1588
					} -- 1588
				end -- 1588
				if supportsFunctionCalling == false then -- 1589
					supportsFunctionCalling = 0 -- 1589
				else -- 1589
					supportsFunctionCalling = 1 -- 1589
				end -- 1589
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1596
					tostring(name), -- 1596
					tostring(url), -- 1597
					tostring(model), -- 1598
					tostring(key), -- 1599
					contextWindow, -- 1600
					temperature, -- 1601
					maxTokens, -- 1602
					reasoningEffort, -- 1603
					customOptions, -- 1604
					supportsFunctionCalling, -- 1605
					1, -- 1606
					now, -- 1607
					now -- 1608
				}) -- 1590
				return { -- 1610
					success = affected >= 0 -- 1610
				} -- 1610
			end -- 1578
		end -- 1578
	end -- 1578
	return invalidArguments -- 1576
end) -- 1576
HttpServer:post("/llm/update", function(req) -- 1612
	ensureLLMConfigTable() -- 1613
	do -- 1614
		local _type_0 = type(req) -- 1614
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1614
		if _tab_0 then -- 1614
			local body = req.body -- 1614
			if body ~= nil then -- 1614
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1615
				local now = os.time() -- 1616
				id = tonumber(id) -- 1617
				if id == nil then -- 1618
					return invalidArguments -- 1618
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
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1630
					tostring(name), -- 1630
					tostring(url), -- 1631
					tostring(model), -- 1632
					tostring(key), -- 1633
					contextWindow, -- 1634
					temperature, -- 1635
					maxTokens, -- 1636
					reasoningEffort, -- 1637
					customOptions, -- 1638
					supportsFunctionCalling, -- 1639
					now, -- 1640
					id -- 1641
				}) -- 1626
				return { -- 1643
					success = affected >= 0 -- 1643
				} -- 1643
			end -- 1614
		end -- 1614
	end -- 1614
	return invalidArguments -- 1612
end) -- 1612
HttpServer:post("/llm/delete", function(req) -- 1645
	ensureLLMConfigTable() -- 1646
	do -- 1647
		local _type_0 = type(req) -- 1647
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1647
		if _tab_0 then -- 1647
			local id -- 1647
			do -- 1647
				local _obj_0 = req.body -- 1647
				local _type_1 = type(_obj_0) -- 1647
				if "table" == _type_1 or "userdata" == _type_1 then -- 1647
					id = _obj_0.id -- 1647
				end -- 1647
			end -- 1647
			if id ~= nil then -- 1647
				id = tonumber(id) -- 1648
				if id == nil then -- 1649
					return invalidArguments -- 1649
				end -- 1649
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1650
					id -- 1650
				}) -- 1650
				return { -- 1651
					success = affected >= 0 -- 1651
				} -- 1651
			end -- 1647
		end -- 1647
	end -- 1647
	return invalidArguments -- 1645
end) -- 1645
HttpServer:post("/local-agent/list", function() -- 1653
	return { -- 1654
		success = true, -- 1654
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1654
		items = AgentLocalAgent.listConfigs() -- 1654
	} -- 1654
end) -- 1653
HttpServer:post("/local-agent/save", function(req) -- 1656
	do -- 1657
		local _type_0 = type(req) -- 1657
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1657
		if _tab_0 then -- 1657
			local body = req.body -- 1657
			if body ~= nil then -- 1657
				return AgentLocalAgent.saveConfig(body) -- 1658
			end -- 1657
		end -- 1657
	end -- 1657
	return invalidArguments -- 1656
end) -- 1656
HttpServer:post("/local-agent/delete", function(req) -- 1660
	do -- 1661
		local _type_0 = type(req) -- 1661
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1661
		if _tab_0 then -- 1661
			local id -- 1661
			do -- 1661
				local _obj_0 = req.body -- 1661
				local _type_1 = type(_obj_0) -- 1661
				if "table" == _type_1 or "userdata" == _type_1 then -- 1661
					id = _obj_0.id -- 1661
				end -- 1661
			end -- 1661
			if id ~= nil then -- 1661
				return AgentLocalAgent.deleteConfig(id) -- 1662
			end -- 1661
		end -- 1661
	end -- 1661
	return invalidArguments -- 1660
end) -- 1660
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1664
	do -- 1665
		local _type_0 = type(req) -- 1665
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1665
		if _tab_0 then -- 1665
			local id -- 1665
			do -- 1665
				local _obj_0 = req.body -- 1665
				local _type_1 = type(_obj_0) -- 1665
				if "table" == _type_1 or "userdata" == _type_1 then -- 1665
					id = _obj_0.id -- 1665
				end -- 1665
			end -- 1665
			if id ~= nil then -- 1665
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1666
			end -- 1665
		end -- 1665
	end -- 1665
	return invalidArguments -- 1664
end) -- 1664
HttpServer:post("/stat", function(req) -- 1668
	do -- 1669
		local _type_0 = type(req) -- 1669
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1669
		if _tab_0 then -- 1669
			local path -- 1669
			do -- 1669
				local _obj_0 = req.body -- 1669
				local _type_1 = type(_obj_0) -- 1669
				if "table" == _type_1 or "userdata" == _type_1 then -- 1669
					path = _obj_0.path -- 1669
				end -- 1669
			end -- 1669
			if path ~= nil then -- 1669
				if not Content:exist(path) then -- 1670
					return { -- 1671
						success = false, -- 1671
						message = "target not existed" -- 1671
					} -- 1671
				end -- 1670
				if Content:isdir(path) then -- 1672
					return { -- 1673
						success = false, -- 1673
						message = "failed to stat a directory" -- 1673
					} -- 1673
				end -- 1672
				local size, isBinary = Content:getAttr(path) -- 1674
				if size then -- 1674
					return { -- 1675
						success = true, -- 1675
						size = size, -- 1675
						isBinary = isBinary -- 1675
					} -- 1675
				end -- 1674
			end -- 1669
		end -- 1669
	end -- 1669
	return { -- 1668
		success = false, -- 1668
		message = "failed to stat" -- 1668
	} -- 1668
end) -- 1668
HttpServer:post("/new", function(req) -- 1677
	do -- 1678
		local _type_0 = type(req) -- 1678
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1678
		if _tab_0 then -- 1678
			local path -- 1678
			do -- 1678
				local _obj_0 = req.body -- 1678
				local _type_1 = type(_obj_0) -- 1678
				if "table" == _type_1 or "userdata" == _type_1 then -- 1678
					path = _obj_0.path -- 1678
				end -- 1678
			end -- 1678
			local content -- 1678
			do -- 1678
				local _obj_0 = req.body -- 1678
				local _type_1 = type(_obj_0) -- 1678
				if "table" == _type_1 or "userdata" == _type_1 then -- 1678
					content = _obj_0.content -- 1678
				end -- 1678
			end -- 1678
			local folder -- 1678
			do -- 1678
				local _obj_0 = req.body -- 1678
				local _type_1 = type(_obj_0) -- 1678
				if "table" == _type_1 or "userdata" == _type_1 then -- 1678
					folder = _obj_0.folder -- 1678
				end -- 1678
			end -- 1678
			if path ~= nil and content ~= nil and folder ~= nil then -- 1678
				if Content:exist(path) then -- 1679
					return { -- 1680
						success = false, -- 1680
						message = "TargetExisted" -- 1680
					} -- 1680
				end -- 1679
				local parent = Path:getPath(path) -- 1681
				local files = Content:getFiles(parent) -- 1682
				if folder then -- 1683
					local name = Path:getFilename(path):lower() -- 1684
					for _index_0 = 1, #files do -- 1685
						local file = files[_index_0] -- 1685
						if name == Path:getFilename(file):lower() then -- 1686
							return { -- 1687
								success = false, -- 1687
								message = "TargetExisted" -- 1687
							} -- 1687
						end -- 1686
					end -- 1685
					if Content:mkdir(path) then -- 1688
						return { -- 1689
							success = true -- 1689
						} -- 1689
					end -- 1688
				else -- 1691
					local name = Path:getName(path):lower() -- 1691
					for _index_0 = 1, #files do -- 1692
						local file = files[_index_0] -- 1692
						if name == Path:getName(file):lower() then -- 1693
							local ext = Path:getExt(file) -- 1694
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1695
								goto _continue_0 -- 1696
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1697
								goto _continue_0 -- 1698
							end -- 1695
							return { -- 1699
								success = false, -- 1699
								message = "SourceExisted" -- 1699
							} -- 1699
						end -- 1693
						::_continue_0:: -- 1693
					end -- 1692
					if Content:save(path, content) then -- 1700
						return { -- 1701
							success = true -- 1701
						} -- 1701
					end -- 1700
				end -- 1683
			end -- 1678
		end -- 1678
	end -- 1678
	return { -- 1677
		success = false, -- 1677
		message = "Failed" -- 1677
	} -- 1677
end) -- 1677
local deleteAsset -- 1703
deleteAsset = function(path) -- 1703
	if not Content:exist(path) then -- 1704
		return false -- 1704
	end -- 1704
	local projectRoot -- 1705
	if Content:isdir(path) and isProjectRootDir(path) then -- 1705
		projectRoot = path -- 1705
	else -- 1705
		projectRoot = nil -- 1705
	end -- 1705
	local parent = Path:getPath(path) -- 1706
	local files = Content:getFiles(parent) -- 1707
	local name = Path:getName(path):lower() -- 1708
	local ext = Path:getExt(path) -- 1709
	for _index_0 = 1, #files do -- 1710
		local file = files[_index_0] -- 1710
		if name == Path:getName(file):lower() then -- 1711
			local _exp_0 = Path:getExt(file) -- 1712
			if "tl" == _exp_0 then -- 1712
				if ("vs" == ext) then -- 1712
					Content:remove(Path(parent, file)) -- 1713
				end -- 1712
			elseif "lua" == _exp_0 then -- 1714
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1714
					Content:remove(Path(parent, file)) -- 1715
				end -- 1714
			end -- 1712
		end -- 1711
	end -- 1710
	if Content:remove(path) then -- 1716
		if projectRoot then -- 1717
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1718
		end -- 1717
		return true -- 1719
	end -- 1716
	return false -- 1720
end -- 1703
local moveAsset -- 1722
moveAsset = function(old, new) -- 1722
	if not (Content:exist(old) and not Content:exist(new)) then -- 1723
		return false -- 1723
	end -- 1723
	local renamedDir = Content:isdir(old) -- 1724
	local parent = Path:getPath(new) -- 1725
	local files = Content:getFiles(parent) -- 1726
	if renamedDir then -- 1727
		local name = Path:getFilename(new):lower() -- 1728
		for _index_0 = 1, #files do -- 1729
			local file = files[_index_0] -- 1729
			if name == Path:getFilename(file):lower() then -- 1730
				return false -- 1731
			end -- 1730
		end -- 1729
	else -- 1733
		local name = Path:getName(new):lower() -- 1733
		local ext = Path:getExt(new) -- 1734
		for _index_0 = 1, #files do -- 1735
			local file = files[_index_0] -- 1735
			if name == Path:getName(file):lower() then -- 1736
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1737
					goto _continue_0 -- 1738
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1739
					goto _continue_0 -- 1740
				end -- 1737
				return false -- 1741
			end -- 1736
			::_continue_0:: -- 1736
		end -- 1735
	end -- 1727
	if not Content:move(old, new) then -- 1742
		return false -- 1742
	end -- 1742
	if renamedDir then -- 1743
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1744
	end -- 1743
	local newParent = Path:getPath(new) -- 1745
	parent = Path:getPath(old) -- 1746
	files = Content:getFiles(parent) -- 1747
	local newName = Path:getName(new) -- 1748
	local oldName = Path:getName(old) -- 1749
	local name = oldName:lower() -- 1750
	local ext = Path:getExt(old) -- 1751
	for _index_0 = 1, #files do -- 1752
		local file = files[_index_0] -- 1752
		if name == Path:getName(file):lower() then -- 1753
			local _exp_0 = Path:getExt(file) -- 1754
			if "tl" == _exp_0 then -- 1754
				if ("vs" == ext) then -- 1754
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1755
				end -- 1754
			elseif "lua" == _exp_0 then -- 1756
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1756
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1757
				end -- 1756
			end -- 1754
		end -- 1753
	end -- 1752
	return true -- 1758
end -- 1722
HttpServer:post("/delete", function(req) -- 1760
	do -- 1761
		local _type_0 = type(req) -- 1761
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1761
		if _tab_0 then -- 1761
			local path -- 1761
			do -- 1761
				local _obj_0 = req.body -- 1761
				local _type_1 = type(_obj_0) -- 1761
				if "table" == _type_1 or "userdata" == _type_1 then -- 1761
					path = _obj_0.path -- 1761
				end -- 1761
			end -- 1761
			if path ~= nil then -- 1761
				if deleteAsset(path) then -- 1762
					return { -- 1762
						success = true -- 1762
					} -- 1762
				end -- 1762
			end -- 1761
		end -- 1761
	end -- 1761
	return { -- 1760
		success = false -- 1760
	} -- 1760
end) -- 1760
HttpServer:post("/rename", function(req) -- 1764
	do -- 1765
		local _type_0 = type(req) -- 1765
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1765
		if _tab_0 then -- 1765
			local old -- 1765
			do -- 1765
				local _obj_0 = req.body -- 1765
				local _type_1 = type(_obj_0) -- 1765
				if "table" == _type_1 or "userdata" == _type_1 then -- 1765
					old = _obj_0.old -- 1765
				end -- 1765
			end -- 1765
			local new -- 1765
			do -- 1765
				local _obj_0 = req.body -- 1765
				local _type_1 = type(_obj_0) -- 1765
				if "table" == _type_1 or "userdata" == _type_1 then -- 1765
					new = _obj_0.new -- 1765
				end -- 1765
			end -- 1765
			if old ~= nil and new ~= nil then -- 1765
				if moveAsset(old, new) then -- 1766
					return { -- 1766
						success = true -- 1766
					} -- 1766
				end -- 1766
			end -- 1765
		end -- 1765
	end -- 1765
	return { -- 1764
		success = false -- 1764
	} -- 1764
end) -- 1764
local normalizeAssetPaths -- 1768
normalizeAssetPaths = function(paths) -- 1768
	if not (type(paths) == "table") then -- 1769
		return nil -- 1769
	end -- 1769
	local unique = { } -- 1770
	local candidates = { } -- 1771
	for _index_0 = 1, #paths do -- 1772
		local path = paths[_index_0] -- 1772
		if not (type(path) == "string") then -- 1773
			return nil -- 1773
		end -- 1773
		local relative = relativeToRoot(path, Content.writablePath) -- 1774
		if relative == nil or relative == "" or not Content:exist(path) then -- 1775
			return nil -- 1775
		end -- 1775
		if not unique[path] then -- 1776
			unique[path] = true -- 1777
			candidates[#candidates + 1] = path -- 1778
		end -- 1776
	end -- 1772
	table.sort(candidates, function(a, b) -- 1779
		return #a < #b -- 1779
	end) -- 1779
	local result = { } -- 1780
	for _index_0 = 1, #candidates do -- 1781
		local path = candidates[_index_0] -- 1781
		local contained = false -- 1782
		for _index_1 = 1, #result do -- 1783
			local parent = result[_index_1] -- 1783
			if relativeToRoot(path, parent) ~= nil then -- 1784
				contained = true -- 1785
				break -- 1786
			end -- 1784
		end -- 1783
		if not contained then -- 1787
			result[#result + 1] = path -- 1787
		end -- 1787
	end -- 1781
	return result -- 1788
end -- 1768
HttpServer:postSchedule("/assets/batch", function(req) -- 1790
	do -- 1791
		local _type_0 = type(req) -- 1791
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1791
		if _tab_0 then -- 1791
			local operation -- 1791
			do -- 1791
				local _obj_0 = req.body -- 1791
				local _type_1 = type(_obj_0) -- 1791
				if "table" == _type_1 or "userdata" == _type_1 then -- 1791
					operation = _obj_0.operation -- 1791
				end -- 1791
			end -- 1791
			local sources -- 1791
			do -- 1791
				local _obj_0 = req.body -- 1791
				local _type_1 = type(_obj_0) -- 1791
				if "table" == _type_1 or "userdata" == _type_1 then -- 1791
					sources = _obj_0.sources -- 1791
				end -- 1791
			end -- 1791
			if operation ~= nil and sources ~= nil then -- 1791
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1792
					return { -- 1792
						success = false, -- 1792
						message = "invalid operation" -- 1792
					} -- 1792
				end -- 1792
				sources = normalizeAssetPaths(sources) -- 1793
				if not (sources and #sources > 0) then -- 1794
					return { -- 1794
						success = false, -- 1794
						message = "invalid sources" -- 1794
					} -- 1794
				end -- 1794
				local target = req.body.target -- 1795
				local destinations = { } -- 1796
				if operation ~= "delete" then -- 1797
					if not (type(target) == "string") then -- 1798
						return { -- 1798
							success = false, -- 1798
							message = "invalid target" -- 1798
						} -- 1798
					end -- 1798
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1799
					if targetRelative == nil then -- 1800
						return { -- 1800
							success = false, -- 1800
							message = "invalid target" -- 1800
						} -- 1800
					end -- 1800
					if not (Content:exist(target) and Content:isdir(target)) then -- 1801
						return { -- 1801
							success = false, -- 1801
							message = "invalid target" -- 1801
						} -- 1801
					end -- 1801
					for _index_0 = 1, #sources do -- 1802
						local source = sources[_index_0] -- 1802
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1803
							return { -- 1804
								success = false, -- 1804
								message = "target inside source" -- 1804
							} -- 1804
						end -- 1803
						local destination = Path(target, Path:getFilename(source)) -- 1805
						if Content:exist(destination) then -- 1806
							return { -- 1806
								success = false, -- 1806
								message = "target existed" -- 1806
							} -- 1806
						end -- 1806
						if destinations[destination] then -- 1807
							return { -- 1807
								success = false, -- 1807
								message = "duplicate target" -- 1807
							} -- 1807
						end -- 1807
						destinations[destination] = true -- 1808
					end -- 1802
				end -- 1797
				local changes = { } -- 1809
				local affectedSet = { } -- 1810
				local affectedDirectories = { } -- 1811
				local addAffected -- 1812
				addAffected = function(dir) -- 1812
					if affectedSet[dir] then -- 1813
						return -- 1813
					end -- 1813
					affectedSet[dir] = true -- 1814
					affectedDirectories[#affectedDirectories + 1] = dir -- 1815
				end -- 1812
				if operation ~= "delete" then -- 1816
					addAffected(target) -- 1816
				end -- 1816
				for _index_0 = 1, #sources do -- 1817
					local source = sources[_index_0] -- 1817
					addAffected(Path:getPath(source)) -- 1818
					if operation == "delete" then -- 1819
						if not deleteAsset(source) then -- 1820
							return { -- 1820
								success = false, -- 1820
								message = "delete failed", -- 1820
								changes = changes, -- 1820
								affectedDirectories = affectedDirectories -- 1820
							} -- 1820
						end -- 1820
						changes[#changes + 1] = { -- 1821
							old = source -- 1821
						} -- 1821
					else -- 1823
						local destination = Path(target, Path:getFilename(source)) -- 1823
						local ok -- 1824
						if operation == "copy" then -- 1824
							ok = Content:copyAsync(source, destination) -- 1825
						else -- 1827
							ok = moveAsset(source, destination) -- 1827
						end -- 1824
						if not ok then -- 1828
							return { -- 1828
								success = false, -- 1828
								message = operation .. " failed", -- 1828
								changes = changes, -- 1828
								affectedDirectories = affectedDirectories -- 1828
							} -- 1828
						end -- 1828
						changes[#changes + 1] = { -- 1829
							old = source, -- 1829
							new = destination -- 1829
						} -- 1829
					end -- 1819
				end -- 1817
				return { -- 1830
					success = true, -- 1830
					changes = changes, -- 1830
					affectedDirectories = affectedDirectories -- 1830
				} -- 1830
			end -- 1791
		end -- 1791
	end -- 1791
	return { -- 1790
		success = false, -- 1790
		message = "invalid request" -- 1790
	} -- 1790
end) -- 1790
local withProjectSearchPaths -- 1832
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1832
	local fallbackPaths = { } -- 1833
	local addFallback -- 1834
	addFallback = function(dir) -- 1834
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1834
			fallbackPaths[#fallbackPaths + 1] = dir -- 1834
		end -- 1834
	end -- 1834
	if projectRoot and projectRoot ~= "" then -- 1835
		addFallback(Path(projectRoot, "Script")) -- 1836
		addFallback(projectRoot) -- 1837
	end -- 1835
	if projFile then -- 1838
		local projDir = getProjectDirFromFile(projFile) -- 1839
		if projDir then -- 1839
			addFallback(Path(projDir, "Script")) -- 1840
			addFallback(projDir) -- 1841
		else -- 1843
			addFallback(Path:getPath(projFile)) -- 1843
		end -- 1839
	end -- 1838
	if not (#fallbackPaths > 0) then -- 1844
		return fn() -- 1844
	end -- 1844
	local searchPaths = Content.searchPaths -- 1845
	for _index_0 = 1, #fallbackPaths do -- 1846
		local dir = fallbackPaths[_index_0] -- 1846
		Content:addSearchPath(dir) -- 1846
	end -- 1846
	local _ <close> = setmetatable({ }, { -- 1847
		__close = function() -- 1847
			Content.searchPaths = searchPaths -- 1847
		end -- 1847
	}) -- 1847
	return fn() -- 1848
end -- 1832
HttpServer:post("/exist", function(req) -- 1849
	do -- 1850
		local _type_0 = type(req) -- 1850
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1850
		if _tab_0 then -- 1850
			local file -- 1850
			do -- 1850
				local _obj_0 = req.body -- 1850
				local _type_1 = type(_obj_0) -- 1850
				if "table" == _type_1 or "userdata" == _type_1 then -- 1850
					file = _obj_0.file -- 1850
				end -- 1850
			end -- 1850
			if file ~= nil then -- 1850
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1851
					return { -- 1852
						success = Content:exist(file) -- 1852
					} -- 1852
				end) -- 1851
			end -- 1850
		end -- 1850
	end -- 1850
	return { -- 1849
		success = false -- 1849
	} -- 1849
end) -- 1849
HttpServer:postSchedule("/read", function(req) -- 1853
	do -- 1854
		local _type_0 = type(req) -- 1854
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1854
		if _tab_0 then -- 1854
			local path -- 1854
			do -- 1854
				local _obj_0 = req.body -- 1854
				local _type_1 = type(_obj_0) -- 1854
				if "table" == _type_1 or "userdata" == _type_1 then -- 1854
					path = _obj_0.path -- 1854
				end -- 1854
			end -- 1854
			if path ~= nil then -- 1854
				local readFile -- 1855
				readFile = function() -- 1855
					if Content:exist(path) and not Content:isdir(path) then -- 1856
						local content = Content:loadAsync(path) -- 1857
						if content then -- 1857
							return { -- 1858
								content = content, -- 1858
								success = true, -- 1858
								fullPath = Content:getFullPath(path) -- 1858
							} -- 1858
						end -- 1857
					end -- 1856
					return nil -- 1855
				end -- 1855
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1859
				if result then -- 1859
					return result -- 1859
				end -- 1859
			end -- 1854
		end -- 1854
	end -- 1854
	return { -- 1853
		success = false -- 1853
	} -- 1853
end) -- 1853
local agentDocLanguage -- 1861
agentDocLanguage = function(language) -- 1861
	if language == "zh-Hans" then -- 1862
		return "zh" -- 1862
	else -- 1862
		return "en" -- 1862
	end -- 1862
end -- 1861
HttpServer:postSchedule("/doc/search", function(req) -- 1864
	local body = req.body or { } -- 1865
	local language = body.docLanguage -- 1866
	if not (("en" == language or "zh-Hans" == language)) then -- 1867
		return { -- 1867
			success = false, -- 1867
			message = "unsupported doc language" -- 1867
		} -- 1867
	end -- 1867
	local docType = body.docType -- 1868
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1869
		return { -- 1869
			success = false, -- 1869
			message = "unsupported doc type" -- 1869
		} -- 1869
	end -- 1869
	local codeLanguage = body.programmingLanguage -- 1870
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1871
		return { -- 1871
			success = false, -- 1871
			message = "unsupported programming language" -- 1871
		} -- 1871
	end -- 1871
	if not body.pattern then -- 1872
		return { -- 1872
			success = false, -- 1872
			message = "missing pattern" -- 1872
		} -- 1872
	end -- 1872
	local result = nil -- 1873
	AgentTools.searchDoraDocHttp({ -- 1875
		pattern = body.pattern, -- 1875
		docLanguage = agentDocLanguage(language), -- 1876
		docType = docType, -- 1877
		programmingLanguage = codeLanguage, -- 1878
		limit = body.limit, -- 1879
		useRegex = body.useRegex, -- 1880
		caseSensitive = body.caseSensitive, -- 1881
		includeContent = body.includeContent, -- 1882
		contentWindow = body.contentWindow -- 1883
	}, function(res) -- 1884
		result = res -- 1885
	end) -- 1874
	wait(function() -- 1886
		return result ~= nil -- 1886
	end) -- 1886
	if result and result.success then -- 1887
		result.docLanguage = language -- 1888
	end -- 1887
	if result then -- 1889
		return result -- 1890
	else -- 1892
		return { -- 1892
			success = false, -- 1892
			message = "doc search failed" -- 1892
		} -- 1892
	end -- 1889
	return { -- 1864
		success = false, -- 1864
		message = "invalid call" -- 1864
	} -- 1864
end) -- 1864
HttpServer:postSchedule("/doc/read", function(req) -- 1894
	local body = req.body or { } -- 1895
	local language = body.docLanguage -- 1896
	if not (("en" == language or "zh-Hans" == language)) then -- 1897
		return { -- 1897
			success = false, -- 1897
			message = "unsupported doc language" -- 1897
		} -- 1897
	end -- 1897
	if not body.file then -- 1898
		return { -- 1898
			success = false, -- 1898
			message = "missing file" -- 1898
		} -- 1898
	end -- 1898
	local result = AgentTools.readDoraDoc({ -- 1900
		docLanguage = agentDocLanguage(language), -- 1900
		file = body.file, -- 1901
		startLine = body.startLine, -- 1902
		endLine = body.endLine -- 1903
	}) -- 1899
	if result and result.success then -- 1904
		result.docLanguage = language -- 1905
	end -- 1904
	return result -- 1906
end) -- 1894
HttpServer:get("/read-sync", function(req) -- 1908
	do -- 1909
		local _type_0 = type(req) -- 1909
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1909
		if _tab_0 then -- 1909
			local params = req.params -- 1909
			if params ~= nil then -- 1909
				local path = params.path -- 1910
				if not (type(path) == "string" and path ~= "") then -- 1911
					return { -- 1911
						success = false, -- 1911
						message = "invalid path" -- 1911
					} -- 1911
				end -- 1911
				local exts -- 1912
				if params.exts then -- 1912
					local _accum_0 = { } -- 1913
					local _len_0 = 1 -- 1913
					for ext in params.exts:gmatch("[^|]*") do -- 1913
						_accum_0[_len_0] = ext -- 1913
						_len_0 = _len_0 + 1 -- 1913
					end -- 1913
					exts = _accum_0 -- 1913
				else -- 1914
					exts = { -- 1914
						"" -- 1914
					} -- 1914
				end -- 1912
				local readFileAt -- 1915
				readFileAt = function(targetPath) -- 1915
					if Content:exist(targetPath) then -- 1916
						local content = Content:load(targetPath) -- 1917
						if content then -- 1917
							return { -- 1918
								content = content, -- 1918
								success = true, -- 1918
								fullPath = Content:getFullPath(targetPath) -- 1918
							} -- 1918
						end -- 1917
					end -- 1916
					return nil -- 1915
				end -- 1915
				local readFile -- 1919
				readFile = function(fallbackPaths) -- 1919
					for _index_0 = 1, #exts do -- 1920
						local ext = exts[_index_0] -- 1920
						local targetPath = path .. ext -- 1921
						if not Content:isAbsolutePath(targetPath) then -- 1922
							for _index_1 = 1, #fallbackPaths do -- 1923
								local fallback = fallbackPaths[_index_1] -- 1923
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1924
								if fallbackResult then -- 1924
									return fallbackResult -- 1925
								end -- 1924
							end -- 1923
						end -- 1922
						local fileResult = readFileAt(targetPath) -- 1926
						if fileResult then -- 1926
							return fileResult -- 1927
						end -- 1926
					end -- 1920
					return nil -- 1919
				end -- 1919
				local fallbackPaths = { } -- 1928
				local fallbackCandidates = { } -- 1929
				do -- 1930
					local projectRoot = req.params.projectRoot -- 1930
					if projectRoot then -- 1930
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1931
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1932
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1933
						end -- 1931
					end -- 1930
				end -- 1930
				do -- 1934
					local projFile = req.params.projFile -- 1934
					if projFile then -- 1934
						local projDir = getProjectDirFromFile(projFile) -- 1935
						if projDir then -- 1935
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1936
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1937
						else -- 1939
							projDir = Path:getPath(projFile) -- 1939
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1940
						end -- 1935
					end -- 1934
				end -- 1934
				for _index_0 = 1, #fallbackCandidates do -- 1941
					local dir = fallbackCandidates[_index_0] -- 1941
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1942
						local exists = false -- 1943
						for _index_1 = 1, #fallbackPaths do -- 1944
							local fallback = fallbackPaths[_index_1] -- 1944
							if fallback == dir then -- 1945
								exists = true -- 1946
								break -- 1947
							end -- 1945
						end -- 1944
						if not exists then -- 1948
							fallbackPaths[#fallbackPaths + 1] = dir -- 1948
						end -- 1948
					end -- 1942
				end -- 1941
				local readResult = readFile(fallbackPaths) -- 1949
				if readResult then -- 1949
					return readResult -- 1950
				end -- 1949
			end -- 1909
		end -- 1909
	end -- 1909
	return { -- 1908
		success = false -- 1908
	} -- 1908
end) -- 1908
local addGeneratedSourceHeader -- 1952
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 1952
	if preserveTIC80 == nil then -- 1952
		preserveTIC80 = false -- 1952
	end -- 1952
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 1953
	if preserveTIC80 then -- 1954
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 1955
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 1956
		end -- 1955
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 1957
	end -- 1954
	return tostring(header) .. "\n" .. tostring(codes) -- 1958
end -- 1952
local compileFileAsync -- 1960
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1960
	if projectRoot == nil then -- 1960
		projectRoot = nil -- 1960
	end -- 1960
	local file = inputFile -- 1961
	local searchPath -- 1962
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1962
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1963
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1967
	elseif not Content:isAbsolutePath(inputFile) then -- 1968
		searchPath = "" -- 1969
	else -- 1970
		local dir = getProjectDirFromFile(inputFile) -- 1970
		if dir then -- 1970
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1971
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1975
		else -- 1977
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1977
			searchPath = "" -- 1980
		end -- 1970
	end -- 1962
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1981
	local yueext = yue.options.extension -- 1982
	local resultCodes = nil -- 1983
	local resultError = nil -- 1984
	do -- 1985
		local _exp_0 = Path:getExt(inputFile) -- 1985
		if yueext == _exp_0 then -- 1985
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1986
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1987
				if not codes then -- 1988
					resultError = err -- 1989
					return -- 1990
				end -- 1988
				local extraGlobal -- 1991
				if isTIC80 then -- 1991
					extraGlobal = tic80APIs -- 1991
				else -- 1991
					extraGlobal = nil -- 1991
				end -- 1991
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1992
				if not success then -- 1993
					resultError = message -- 1994
					return -- 1995
				end -- 1993
				if codes == "" then -- 1996
					resultCodes = "" -- 1997
					return nil -- 1998
				end -- 1996
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 1999
				return resultCodes -- 2000
			end, function(success) -- 1987
				if not success then -- 2001
					Content:remove(outputFile) -- 2002
					if resultCodes == nil then -- 2003
						resultCodes = false -- 2004
					end -- 2003
				end -- 2001
			end) -- 1987
		elseif "tl" == _exp_0 then -- 2005
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 2006
			if isTIC80 then -- 2007
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2008
			end -- 2007
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2009
			if codes then -- 2009
				if isTIC80 then -- 2010
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2011
				end -- 2010
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2012
				Content:saveAsync(outputFile, resultCodes) -- 2013
			else -- 2015
				Content:remove(outputFile) -- 2015
				resultCodes = false -- 2016
				resultError = err -- 2017
			end -- 2009
		elseif "xml" == _exp_0 then -- 2018
			local codes, err = xml.tolua(sourceCodes) -- 2019
			if codes then -- 2019
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2020
				Content:saveAsync(outputFile, resultCodes) -- 2021
			else -- 2023
				Content:remove(outputFile) -- 2023
				resultCodes = false -- 2024
				resultError = err -- 2025
			end -- 2019
		end -- 1985
	end -- 1985
	wait(function() -- 2026
		return resultCodes ~= nil -- 2026
	end) -- 2026
	if resultCodes then -- 2027
		return resultCodes -- 2028
	else -- 2030
		return nil, resultError -- 2030
	end -- 2027
	return nil -- 1960
end -- 1960
HttpServer:postSchedule("/write", function(req) -- 2032
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2033
	local buildSucceeded = false -- 2034
	local _ <close> = setmetatable({ }, { -- 2035
		__close = function() -- 2035
			return finishUpdate(buildSucceeded) -- 2035
		end -- 2035
	}) -- 2035
	do -- 2036
		local _type_0 = type(req) -- 2036
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2036
		if _tab_0 then -- 2036
			local path -- 2036
			do -- 2036
				local _obj_0 = req.body -- 2036
				local _type_1 = type(_obj_0) -- 2036
				if "table" == _type_1 or "userdata" == _type_1 then -- 2036
					path = _obj_0.path -- 2036
				end -- 2036
			end -- 2036
			local content -- 2036
			do -- 2036
				local _obj_0 = req.body -- 2036
				local _type_1 = type(_obj_0) -- 2036
				if "table" == _type_1 or "userdata" == _type_1 then -- 2036
					content = _obj_0.content -- 2036
				end -- 2036
			end -- 2036
			if path ~= nil and content ~= nil then -- 2036
				if Content:saveAsync(path, content) then -- 2037
					do -- 2038
						local _exp_0 = Path:getExt(path) -- 2038
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2038
							if '' == Path:getExt(Path:getName(path)) then -- 2039
								local resultCodes = compileFileAsync(path, content) -- 2040
								buildSucceeded = resultCodes ~= nil -- 2041
								return { -- 2042
									success = true, -- 2042
									resultCodes = resultCodes -- 2042
								} -- 2042
							end -- 2039
						end -- 2038
					end -- 2038
					buildSucceeded = true -- 2043
					return { -- 2044
						success = true -- 2044
					} -- 2044
				end -- 2037
			end -- 2036
		end -- 2036
	end -- 2036
	return { -- 2032
		success = false -- 2032
	} -- 2032
end) -- 2032
local getWaProjectDirFromFile = nil -- 2046
HttpServer:postSchedule("/build", function(req) -- 2048
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2049
	local buildSucceeded = false -- 2050
	local _ <close> = setmetatable({ }, { -- 2051
		__close = function() -- 2051
			return finishUpdate(buildSucceeded) -- 2051
		end -- 2051
	}) -- 2051
	do -- 2052
		local _type_0 = type(req) -- 2052
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2052
		if _tab_0 then -- 2052
			local path -- 2052
			do -- 2052
				local _obj_0 = req.body -- 2052
				local _type_1 = type(_obj_0) -- 2052
				if "table" == _type_1 or "userdata" == _type_1 then -- 2052
					path = _obj_0.path -- 2052
				end -- 2052
			end -- 2052
			if path ~= nil then -- 2052
				local projectRoot = req.body.projectRoot -- 2053
				if Content:isdir(path) then -- 2054
					local projDir = getWaProjectDirFromFile(path) -- 2055
					if projDir then -- 2055
						local message = Wasm:buildWaAsync(projDir) -- 2056
						if message == "" then -- 2057
							return { -- 2058
								success = true -- 2058
							} -- 2058
						else -- 2060
							return { -- 2060
								success = false, -- 2060
								message = message -- 2060
							} -- 2060
						end -- 2057
					end -- 2055
				end -- 2054
				local _exp_0 = Path:getExt(path) -- 2061
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2062
					if '' == Path:getExt(Path:getName(path)) then -- 2063
						local content = Content:loadAsync(path) -- 2064
						if content then -- 2064
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2065
							if resultCodes then -- 2065
								buildSucceeded = true -- 2066
								return { -- 2067
									success = true, -- 2067
									resultCodes = resultCodes -- 2067
								} -- 2067
							end -- 2065
						end -- 2064
					end -- 2063
				elseif "wa" == _exp_0 then -- 2068
					local projDir = getWaProjectDirFromFile(path) -- 2069
					if projDir then -- 2069
						local message = Wasm:buildWaAsync(projDir) -- 2070
						if message == "" then -- 2071
							return { -- 2072
								success = true -- 2072
							} -- 2072
						else -- 2074
							return { -- 2074
								success = false, -- 2074
								message = message -- 2074
							} -- 2074
						end -- 2071
					else -- 2076
						return { -- 2076
							success = false, -- 2076
							message = 'Wa file needs a project' -- 2076
						} -- 2076
					end -- 2069
				end -- 2061
			end -- 2052
		end -- 2052
	end -- 2052
	return { -- 2048
		success = false -- 2048
	} -- 2048
end) -- 2048
local extentionLevels = { -- 2079
	vs = 2, -- 2079
	bl = 2, -- 2080
	ts = 1, -- 2081
	tsx = 1, -- 2082
	tl = 1, -- 2083
	yue = 1, -- 2084
	xml = 1, -- 2085
	lua = 0 -- 2086
} -- 2078
local visitAssets -- 2088
visitAssets = function(path, workspace, builtin, recursive) -- 2088
	if recursive == nil then -- 2088
		recursive = true -- 2088
	end -- 2088
	local children = nil -- 2089
	local dirs = Content:getDirs(path) -- 2090
	for _index_0 = 1, #dirs do -- 2091
		local dir = dirs[_index_0] -- 2091
		if workspace then -- 2092
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 2093
				goto _continue_0 -- 2094
			end -- 2093
		elseif dir == ".git" then -- 2095
			goto _continue_0 -- 2096
		end -- 2092
		if not children then -- 2097
			children = { } -- 2097
		end -- 2097
		local dirPath = Path(path, dir) -- 2098
		if recursive then -- 2099
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2100
		else -- 2102
			children[#children + 1] = { -- 2103
				key = dirPath, -- 2103
				dir = true, -- 2104
				title = dir, -- 2105
				builtin = builtin, -- 2106
				isLeaf = false -- 2107
			} -- 2102
		end -- 2099
		::_continue_0:: -- 2092
	end -- 2091
	local files = Content:getFiles(path) -- 2109
	local names = { } -- 2110
	for _index_0 = 1, #files do -- 2111
		local file = files[_index_0] -- 2111
		if (".DS_Store" == file) then -- 2112
			goto _continue_1 -- 2113
		end -- 2112
		local name = Path:getName(file) -- 2114
		local ext = names[name] -- 2115
		if ext then -- 2115
			local lv1 -- 2116
			do -- 2116
				local _exp_0 = extentionLevels[ext] -- 2116
				if _exp_0 ~= nil then -- 2116
					lv1 = _exp_0 -- 2116
				else -- 2116
					lv1 = -1 -- 2116
				end -- 2116
			end -- 2116
			ext = Path:getExt(file) -- 2117
			local lv2 -- 2118
			do -- 2118
				local _exp_0 = extentionLevels[ext] -- 2118
				if _exp_0 ~= nil then -- 2118
					lv2 = _exp_0 -- 2118
				else -- 2118
					lv2 = -1 -- 2118
				end -- 2118
			end -- 2118
			if lv2 > lv1 then -- 2119
				names[name] = ext -- 2120
			elseif lv2 == lv1 then -- 2121
				names[name .. '.' .. ext] = "" -- 2122
			end -- 2119
		else -- 2124
			ext = Path:getExt(file) -- 2124
			if not extentionLevels[ext] then -- 2125
				names[file] = "" -- 2126
			else -- 2128
				names[name] = ext -- 2128
			end -- 2125
		end -- 2115
		::_continue_1:: -- 2112
	end -- 2111
	do -- 2129
		local _accum_0 = { } -- 2129
		local _len_0 = 1 -- 2129
		for name, ext in pairs(names) do -- 2129
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2129
			_len_0 = _len_0 + 1 -- 2129
		end -- 2129
		files = _accum_0 -- 2129
	end -- 2129
	for _index_0 = 1, #files do -- 2130
		local file = files[_index_0] -- 2130
		if not children then -- 2131
			children = { } -- 2131
		end -- 2131
		children[#children + 1] = { -- 2133
			key = Path(path, file), -- 2133
			dir = false, -- 2134
			title = file, -- 2135
			builtin = builtin -- 2136
		} -- 2132
	end -- 2130
	if children then -- 2138
		table.sort(children, function(a, b) -- 2139
			if a.dir == b.dir then -- 2140
				return a.title < b.title -- 2141
			else -- 2143
				return a.dir -- 2143
			end -- 2140
		end) -- 2139
	end -- 2138
	return { -- 2145
		key = path, -- 2145
		dir = true, -- 2146
		title = Path:getFilename(path), -- 2147
		builtin = builtin, -- 2148
		isLeaf = not children, -- 2149
		children = children -- 2150
	} -- 2144
end -- 2088
HttpServer:post("/assets/children", function(req) -- 2153
	do -- 2154
		local _type_0 = type(req) -- 2154
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2154
		if _tab_0 then -- 2154
			local path -- 2154
			do -- 2154
				local _obj_0 = req.body -- 2154
				local _type_1 = type(_obj_0) -- 2154
				if "table" == _type_1 or "userdata" == _type_1 then -- 2154
					path = _obj_0.path -- 2154
				end -- 2154
			end -- 2154
			if path ~= nil then -- 2154
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2155
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2156
					return { -- 2156
						success = false -- 2156
					} -- 2156
				end -- 2156
				local node = visitAssets(path, workspace, builtin, false) -- 2157
				return { -- 2158
					success = true, -- 2158
					children = node.children or { } -- 2158
				} -- 2158
			end -- 2154
		end -- 2154
	end -- 2154
	return { -- 2153
		success = false -- 2153
	} -- 2153
end) -- 2153
HttpServer:post("/assets/files", function(req) -- 2160
	do -- 2161
		local _type_0 = type(req) -- 2161
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2161
		if _tab_0 then -- 2161
			local path -- 2161
			do -- 2161
				local _obj_0 = req.body -- 2161
				local _type_1 = type(_obj_0) -- 2161
				if "table" == _type_1 or "userdata" == _type_1 then -- 2161
					path = _obj_0.path -- 2161
				end -- 2161
			end -- 2161
			if path ~= nil then -- 2161
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2162
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2163
				if not (workspace or builtin) then -- 2164
					return { -- 2164
						success = false -- 2164
					} -- 2164
				end -- 2164
				if not (Content:exist(path) and Content:isdir(path)) then -- 2165
					return { -- 2165
						success = false -- 2165
					} -- 2165
				end -- 2165
				local globs = { -- 2166
					"**", -- 2166
					"!**/.DS_Store" -- 2166
				} -- 2166
				if workspace then -- 2167
					globs = { -- 2169
						"**", -- 2169
						"!**/.DS_Store", -- 2169
						"!**/.upload/**", -- 2170
						"!**/.download/**", -- 2170
						"!**/.www/**", -- 2171
						"!**/.build/**", -- 2171
						"!**/.git/**", -- 2172
						"!**/.cache/**", -- 2172
						"!**/node_modules/**" -- 2173
					} -- 2168
				end -- 2167
				local files -- 2175
				do -- 2175
					local _accum_0 = { } -- 2175
					local _len_0 = 1 -- 2175
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2175
					for _index_0 = 1, #_list_0 do -- 2175
						local file = _list_0[_index_0] -- 2175
						_accum_0[_len_0] = Path(path, file) -- 2175
						_len_0 = _len_0 + 1 -- 2175
					end -- 2175
					files = _accum_0 -- 2175
				end -- 2175
				return { -- 2176
					success = true, -- 2176
					files = files -- 2176
				} -- 2176
			end -- 2161
		end -- 2161
	end -- 2161
	return { -- 2160
		success = false -- 2160
	} -- 2160
end) -- 2160
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2217
	local _tab_0 = { -- 2217
		{ -- 2218
			key = Path(Content.assetPath), -- 2218
			dir = true, -- 2219
			builtin = true, -- 2220
			title = zh and "内置资源" or "Built-in", -- 2221
			children = builtinChildren -- 2222
		} -- 2217
	} -- 2224
	local _obj_0 = workspace.children or { } -- 2224
	local _idx_0 = #_tab_0 + 1 -- 2224
	for _index_0 = 1, #_obj_0 do -- 2224
		local _value_0 = _obj_0[_index_0] -- 2224
		_tab_0[_idx_0] = _value_0 -- 2224
		_idx_0 = _idx_0 + 1 -- 2224
	end -- 2224
	return _tab_0 -- 2217
end -- 2217
HttpServer:post("/assets", function() -- 2178
	local Entry = require("Script.Dev.Entry") -- 2179
	local engineDev = Entry.getEngineDev() -- 2180
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2181
	local zh = (App.locale:match("^zh") ~= nil) -- 2182
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2183
	readme.title = zh and "说明文档" or "Readme" -- 2184
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2185
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2186
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2187
	tools.title = zh and "开发工具" or "Tools" -- 2188
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2189
	font.title = zh and "字体" or "Font" -- 2190
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2191
	lib.title = zh and "程序库" or "Lib" -- 2192
	if engineDev then -- 2193
		local _list_0 = lib.children -- 2194
		for _index_0 = 1, #_list_0 do -- 2194
			local child = _list_0[_index_0] -- 2194
			if not (child.title == "Dora") then -- 2195
				goto _continue_0 -- 2195
			end -- 2195
			local title = zh and "zh-Hans" or "en" -- 2196
			do -- 2197
				local _accum_0 = { } -- 2197
				local _len_0 = 1 -- 2197
				local _list_1 = child.children -- 2197
				for _index_1 = 1, #_list_1 do -- 2197
					local c = _list_1[_index_1] -- 2197
					if c.title ~= title then -- 2197
						_accum_0[_len_0] = c -- 2197
						_len_0 = _len_0 + 1 -- 2197
					end -- 2197
				end -- 2197
				child.children = _accum_0 -- 2197
			end -- 2197
			break -- 2198
			::_continue_0:: -- 2195
		end -- 2194
	else -- 2200
		local _accum_0 = { } -- 2200
		local _len_0 = 1 -- 2200
		local _list_0 = lib.children -- 2200
		for _index_0 = 1, #_list_0 do -- 2200
			local child = _list_0[_index_0] -- 2200
			if child.title ~= "Dora" then -- 2200
				_accum_0[_len_0] = child -- 2200
				_len_0 = _len_0 + 1 -- 2200
			end -- 2200
		end -- 2200
		lib.children = _accum_0 -- 2200
	end -- 2193
	local builtinChildren = { -- 2201
		readme, -- 2201
		apiDoc, -- 2201
		tools, -- 2201
		font, -- 2201
		lib -- 2201
	} -- 2201
	if engineDev then -- 2202
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2203
		do -- 2204
			local _obj_0 = dev.children -- 2204
			_obj_0[#_obj_0 + 1] = { -- 2205
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2205
				dir = false, -- 2206
				builtin = true, -- 2207
				title = "init.yue" -- 2208
			} -- 2204
		end -- 2204
		builtinChildren[#builtinChildren + 1] = dev -- 2210
	end -- 2202
	return { -- 2212
		key = Content.writablePath, -- 2212
		dir = true, -- 2213
		root = true, -- 2214
		title = "Assets", -- 2215
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2216
	} -- 2211
end) -- 2178
HttpServer:post("/entry/list", function(req) -- 2228
	local Entry = require("Script.Dev.Entry") -- 2229
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2230
	res.success = true -- 2231
	return res -- 2232
end) -- 2228
HttpServer:post("/run/status", function() -- 2234
	local Entry = require("Script.Dev.Entry") -- 2235
	return Entry.getCurrentEntryStatus() -- 2236
end) -- 2234
HttpServer:postSchedule("/run", function(req) -- 2238
	do -- 2239
		local _type_0 = type(req) -- 2239
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2239
		if _tab_0 then -- 2239
			local file -- 2239
			do -- 2239
				local _obj_0 = req.body -- 2239
				local _type_1 = type(_obj_0) -- 2239
				if "table" == _type_1 or "userdata" == _type_1 then -- 2239
					file = _obj_0.file -- 2239
				end -- 2239
			end -- 2239
			local asProj -- 2239
			do -- 2239
				local _obj_0 = req.body -- 2239
				local _type_1 = type(_obj_0) -- 2239
				if "table" == _type_1 or "userdata" == _type_1 then -- 2239
					asProj = _obj_0.asProj -- 2239
				end -- 2239
			end -- 2239
			if file ~= nil and asProj ~= nil then -- 2239
				if not Content:isAbsolutePath(file) then -- 2240
					local devFile = Path(Content.writablePath, file) -- 2241
					if Content:exist(devFile) then -- 2242
						file = devFile -- 2242
					end -- 2242
				end -- 2240
				local Entry = require("Script.Dev.Entry") -- 2243
				local workDir -- 2244
				if asProj then -- 2245
					local projectRoot = req.body.projectRoot -- 2246
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2247
						workDir = projectRoot -- 2248
					else -- 2250
						workDir = getProjectDirFromFile(file) -- 2250
					end -- 2247
					if workDir then -- 2251
						Entry.allClear() -- 2252
						local target = Path(workDir, "init") -- 2253
						local success, err = Entry.enterEntryAsync({ -- 2254
							entryName = "Project", -- 2254
							fileName = target, -- 2254
							workDir = workDir, -- 2254
							projectRoot = workDir, -- 2254
							runKind = "project" -- 2254
						}) -- 2254
						target = Path:getName(Path:getPath(target)) -- 2255
						return { -- 2256
							success = success, -- 2256
							target = target, -- 2256
							err = err -- 2256
						} -- 2256
					end -- 2251
				else -- 2258
					workDir = getProjectDirFromFile(file) -- 2258
					if not workDir and Path:getExt(file) == "wasm" then -- 2259
						local parent = Path:getPath(file) -- 2260
						if Content:exist(Path(parent, "wa.mod")) then -- 2261
							workDir = parent -- 2262
						end -- 2261
					end -- 2259
				end -- 2245
				Entry.allClear() -- 2263
				file = Path:replaceExt(file, "") -- 2264
				local entry = { -- 2266
					entryName = Path:getName(file), -- 2266
					fileName = file, -- 2267
					runKind = "file" -- 2268
				} -- 2265
				if workDir then -- 2269
					entry.workDir = workDir -- 2270
					entry.projectRoot = workDir -- 2271
				end -- 2269
				local success, err = Entry.enterEntryAsync(entry) -- 2272
				return { -- 2273
					success = success, -- 2273
					err = err -- 2273
				} -- 2273
			end -- 2239
		end -- 2239
	end -- 2239
	return { -- 2238
		success = false -- 2238
	} -- 2238
end) -- 2238
local _anon_func_7 = function(result) -- 2315
	if result.success then -- 2315
		return nil -- 2315
	else -- 2315
		return "PREVIEW_FAILED" -- 2315
	end -- 2315
end -- 2315
HttpServer:postSchedule("/agent/preview", function(req) -- 2275
	local releaseAgent = AgentHost.acquire() -- 2276
	local _ <close> = setmetatable({ }, { -- 2277
		__close = function() -- 2277
			return releaseAgent() -- 2277
		end -- 2277
	}) -- 2277
	do -- 2278
		local _type_0 = type(req) -- 2278
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2278
		if _tab_0 then -- 2278
			local projectRoot -- 2278
			do -- 2278
				local _obj_0 = req.body -- 2278
				local _type_1 = type(_obj_0) -- 2278
				if "table" == _type_1 or "userdata" == _type_1 then -- 2278
					projectRoot = _obj_0.projectRoot -- 2278
				end -- 2278
			end -- 2278
			if projectRoot ~= nil then -- 2278
				if not getProjectSourceRoot(projectRoot) then -- 2279
					return { -- 2279
						success = false, -- 2279
						code = "INVALID_PROJECT", -- 2279
						message = "projectRoot must be an existing absolute directory" -- 2279
					} -- 2279
				end -- 2279
				local entryFile = req.body.entry or "init.lua" -- 2280
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2281
					return { -- 2281
						success = false, -- 2281
						code = "INVALID_ENTRY", -- 2281
						message = "entry must be a non-empty project-relative path" -- 2281
					} -- 2281
				end -- 2281
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2282
					0.5 -- 2282
				} -- 2282
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2283
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2284
					return { -- 2284
						success = false, -- 2284
						code = "INVALID_QUEUE_TIMEOUT", -- 2284
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2284
					} -- 2284
				end -- 2284
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2285
				local AgentOperation = require("Agent.Tool.Operation") -- 2286
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2287
				local requestId = AgentOperation.createOperationId() -- 2288
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2289
				if not enqueued.success then -- 2290
					return { -- 2290
						success = false, -- 2290
						code = "ENTRY_QUEUE_REJECTED", -- 2290
						message = enqueued.message -- 2290
					} -- 2290
				end -- 2290
				local queuedAt = App.runningTime -- 2291
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2292
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2293
						local state = agentEntryRunQueue:get(requestId) -- 2294
						agentEntryRunQueue:cancel(requestId) -- 2295
						return { -- 2297
							success = false, -- 2297
							code = "ENTRY_QUEUE_TIMEOUT", -- 2298
							message = "timed out waiting for the Dora entry runtime", -- 2299
							requestId = requestId, -- 2300
							queuePosition = state.position -- 2301
						} -- 2296
					end -- 2293
					sleep() -- 2302
				end -- 2292
				local queueWaitSeconds = App.runningTime - queuedAt -- 2303
				local _ <close> = setmetatable({ }, { -- 2304
					__close = function() -- 2304
						return agentEntryRunQueue:release(requestId) -- 2304
					end -- 2304
				}) -- 2304
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2305
				local Entry = require("Script.Dev.Entry") -- 2306
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2308
					workDir = projectRoot, -- 2308
					operationId = requestId, -- 2309
					print = function() end -- 2310
				}, Entry) -- 2307
				local result = preview({ -- 2312
					entry = entryFile, -- 2312
					captureAtSeconds = captureAtSeconds -- 2312
				}) -- 2312
				return { -- 2314
					success = result.success, -- 2314
					code = _anon_func_7(result), -- 2315
					message = result.message, -- 2316
					requestId = requestId, -- 2317
					queueWaitSeconds = queueWaitSeconds, -- 2318
					interruptedUserRun = result.interruptedUserRun, -- 2319
					files = result.files, -- 2320
					frames = result.frames -- 2321
				} -- 2313
			end -- 2278
		end -- 2278
	end -- 2278
	return { -- 2275
		success = false, -- 2275
		message = "invalid call" -- 2275
	} -- 2275
end) -- 2275
HttpServer:postSchedule("/agent/command", function(req) -- 2323
	local releaseAgent = AgentHost.acquire() -- 2324
	local _ <close> = setmetatable({ }, { -- 2325
		__close = function() -- 2325
			return releaseAgent() -- 2325
		end -- 2325
	}) -- 2325
	do -- 2326
		local _type_0 = type(req) -- 2326
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2326
		if _tab_0 then -- 2326
			local body = req.body -- 2326
			if body ~= nil then -- 2326
				local projectRoot = body.projectRoot -- 2327
				if not getProjectSourceRoot(projectRoot) then -- 2328
					return { -- 2328
						success = false, -- 2328
						code = "INVALID_PROJECT", -- 2328
						message = "projectRoot must be an existing absolute directory" -- 2328
					} -- 2328
				end -- 2328
				local AgentValidation = require("Agent.Tool.Validation") -- 2329
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2330
				if not validated.success then -- 2331
					return { -- 2331
						success = false, -- 2331
						code = "INVALID_COMMAND", -- 2331
						message = validated.message -- 2331
					} -- 2331
				end -- 2331
				local input = validated.value -- 2332
				local AgentCommand = require("Agent.Tool.Command") -- 2333
				local result = nil -- 2334
				local failure = nil -- 2335
				local promise = AgentCommand.executeCommand({ -- 2337
					workDir = projectRoot, -- 2337
					mode = input.mode, -- 2338
					code = input.code, -- 2339
					command = input.command, -- 2340
					cwd = input.cwd, -- 2341
					timeoutSeconds = input.timeoutSeconds -- 2342
				}) -- 2336
				promise:addCallbacks((function(_, value) -- 2343
					result = value -- 2343
				end), (function(_, err) -- 2343
					failure = tostring(err) -- 2343
				end)) -- 2343
				wait(function() -- 2344
					return result ~= nil or failure ~= nil -- 2344
				end) -- 2344
				if failure then -- 2345
					return { -- 2345
						success = false, -- 2345
						code = "COMMAND_BRIDGE_FAILED", -- 2345
						message = failure -- 2345
					} -- 2345
				end -- 2345
				if not result.success then -- 2346
					result.code = "COMMAND_FAILED" -- 2347
				end -- 2346
				return result -- 2348
			end -- 2326
		end -- 2326
	end -- 2326
	return { -- 2323
		success = false, -- 2323
		code = "INVALID_COMMAND", -- 2323
		message = "invalid call" -- 2323
	} -- 2323
end) -- 2323
HttpServer:postSchedule("/stop", function() -- 2350
	local Entry = require("Script.Dev.Entry") -- 2351
	return { -- 2352
		success = Entry.stop() -- 2352
	} -- 2352
end) -- 2350
local minifyAsync -- 2354
minifyAsync = function(sourcePath, minifyPath) -- 2354
	if not Content:exist(sourcePath) then -- 2355
		return -- 2355
	end -- 2355
	local Entry = require("Script.Dev.Entry") -- 2356
	local errors = { } -- 2357
	local files = Entry.getAllFiles(sourcePath, { -- 2358
		"lua" -- 2358
	}, true) -- 2358
	do -- 2359
		local _accum_0 = { } -- 2359
		local _len_0 = 1 -- 2359
		for _index_0 = 1, #files do -- 2359
			local file = files[_index_0] -- 2359
			if file:sub(1, 1) ~= '.' then -- 2359
				_accum_0[_len_0] = file -- 2359
				_len_0 = _len_0 + 1 -- 2359
			end -- 2359
		end -- 2359
		files = _accum_0 -- 2359
	end -- 2359
	local paths -- 2360
	do -- 2360
		local _tbl_0 = { } -- 2360
		for _index_0 = 1, #files do -- 2360
			local file = files[_index_0] -- 2360
			_tbl_0[Path:getPath(file)] = true -- 2360
		end -- 2360
		paths = _tbl_0 -- 2360
	end -- 2360
	for path in pairs(paths) do -- 2361
		Content:mkdir(Path(minifyPath, path)) -- 2361
	end -- 2361
	local _ <close> = setmetatable({ }, { -- 2362
		__close = function() -- 2362
			package.loaded["luaminify.FormatMini"] = nil -- 2363
			package.loaded["luaminify.ParseLua"] = nil -- 2364
			package.loaded["luaminify.Scope"] = nil -- 2365
			package.loaded["luaminify.Util"] = nil -- 2366
		end -- 2362
	}) -- 2362
	local FormatMini -- 2367
	do -- 2367
		local _obj_0 = require("luaminify") -- 2367
		FormatMini = _obj_0.FormatMini -- 2367
	end -- 2367
	local fileCount = #files -- 2368
	local count = 0 -- 2369
	for _index_0 = 1, #files do -- 2370
		local file = files[_index_0] -- 2370
		thread(function() -- 2371
			local _ <close> = setmetatable({ }, { -- 2372
				__close = function() -- 2372
					count = count + 1 -- 2372
				end -- 2372
			}) -- 2372
			local input = Path(sourcePath, file) -- 2373
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2374
			if Content:exist(input) then -- 2375
				local sourceCodes = Content:loadAsync(input) -- 2376
				local res, err = FormatMini(sourceCodes) -- 2377
				if res then -- 2378
					Content:saveAsync(output, res) -- 2379
					return print("Minify " .. tostring(file)) -- 2380
				else -- 2382
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2382
				end -- 2378
			else -- 2384
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2384
			end -- 2375
		end) -- 2371
		sleep() -- 2385
	end -- 2370
	wait(function() -- 2386
		return count == fileCount -- 2386
	end) -- 2386
	if #errors > 0 then -- 2387
		print(table.concat(errors, '\n')) -- 2388
	end -- 2387
	print("Obfuscation done.") -- 2389
	return files -- 2390
end -- 2354
local zipping = false -- 2392
HttpServer:postSchedule("/zip", function(req) -- 2394
	do -- 2395
		local _type_0 = type(req) -- 2395
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2395
		if _tab_0 then -- 2395
			local path -- 2395
			do -- 2395
				local _obj_0 = req.body -- 2395
				local _type_1 = type(_obj_0) -- 2395
				if "table" == _type_1 or "userdata" == _type_1 then -- 2395
					path = _obj_0.path -- 2395
				end -- 2395
			end -- 2395
			local zipFile -- 2395
			do -- 2395
				local _obj_0 = req.body -- 2395
				local _type_1 = type(_obj_0) -- 2395
				if "table" == _type_1 or "userdata" == _type_1 then -- 2395
					zipFile = _obj_0.zipFile -- 2395
				end -- 2395
			end -- 2395
			local obfuscated -- 2395
			do -- 2395
				local _obj_0 = req.body -- 2395
				local _type_1 = type(_obj_0) -- 2395
				if "table" == _type_1 or "userdata" == _type_1 then -- 2395
					obfuscated = _obj_0.obfuscated -- 2395
				end -- 2395
			end -- 2395
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2395
				if zipping then -- 2396
					goto failed -- 2396
				end -- 2396
				zipping = true -- 2397
				local _ <close> = setmetatable({ }, { -- 2398
					__close = function() -- 2398
						zipping = false -- 2398
					end -- 2398
				}) -- 2398
				if not Content:exist(path) then -- 2399
					goto failed -- 2399
				end -- 2399
				Content:mkdir(Path:getPath(zipFile)) -- 2400
				if obfuscated then -- 2401
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2402
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2403
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2404
					Content:remove(scriptPath) -- 2405
					Content:remove(obfuscatedPath) -- 2406
					Content:remove(tempPath) -- 2407
					Content:mkdir(scriptPath) -- 2408
					Content:mkdir(obfuscatedPath) -- 2409
					Content:mkdir(tempPath) -- 2410
					if not Content:copyAsync(path, tempPath) then -- 2411
						goto failed -- 2411
					end -- 2411
					local Entry = require("Script.Dev.Entry") -- 2412
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2413
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2414
						"tl", -- 2414
						"yue", -- 2414
						"lua", -- 2414
						"ts", -- 2414
						"tsx", -- 2414
						"vs", -- 2414
						"bl", -- 2414
						"xml", -- 2414
						"wa", -- 2414
						"mod" -- 2414
					}, true) -- 2414
					for _index_0 = 1, #scriptFiles do -- 2415
						local file = scriptFiles[_index_0] -- 2415
						Content:remove(Path(tempPath, file)) -- 2416
					end -- 2415
					for _index_0 = 1, #luaFiles do -- 2417
						local file = luaFiles[_index_0] -- 2417
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2418
					end -- 2417
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2419
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2420
					end) then -- 2419
						goto failed -- 2419
					end -- 2419
					return { -- 2421
						success = true -- 2421
					} -- 2421
				else -- 2423
					return { -- 2423
						success = Content:zipAsync(path, zipFile, function(file) -- 2423
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2424
						end) -- 2423
					} -- 2423
				end -- 2401
			end -- 2395
		end -- 2395
	end -- 2395
	::failed:: -- 2425
	return { -- 2394
		success = false -- 2394
	} -- 2394
end) -- 2394
HttpServer:postSchedule("/unzip", function(req) -- 2427
	do -- 2428
		local _type_0 = type(req) -- 2428
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2428
		if _tab_0 then -- 2428
			local zipFile -- 2428
			do -- 2428
				local _obj_0 = req.body -- 2428
				local _type_1 = type(_obj_0) -- 2428
				if "table" == _type_1 or "userdata" == _type_1 then -- 2428
					zipFile = _obj_0.zipFile -- 2428
				end -- 2428
			end -- 2428
			local path -- 2428
			do -- 2428
				local _obj_0 = req.body -- 2428
				local _type_1 = type(_obj_0) -- 2428
				if "table" == _type_1 or "userdata" == _type_1 then -- 2428
					path = _obj_0.path -- 2428
				end -- 2428
			end -- 2428
			if zipFile ~= nil and path ~= nil then -- 2428
				return { -- 2429
					success = Content:unzipAsync(zipFile, path, function(file) -- 2429
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2430
					end) -- 2429
				} -- 2429
			end -- 2428
		end -- 2428
	end -- 2428
	return { -- 2427
		success = false -- 2427
	} -- 2427
end) -- 2427
HttpServer:post("/editing-info", function(req) -- 2432
	local Entry = require("Script.Dev.Entry") -- 2433
	local config = Entry.getConfig() -- 2434
	local _type_0 = type(req) -- 2435
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2435
	local _match_0 = false -- 2435
	if _tab_0 then -- 2435
		local editingInfo -- 2435
		do -- 2435
			local _obj_0 = req.body -- 2435
			local _type_1 = type(_obj_0) -- 2435
			if "table" == _type_1 or "userdata" == _type_1 then -- 2435
				editingInfo = _obj_0.editingInfo -- 2435
			end -- 2435
		end -- 2435
		if editingInfo ~= nil then -- 2435
			_match_0 = true -- 2435
			config.editingInfo = editingInfo -- 2436
			return { -- 2437
				success = true -- 2437
			} -- 2437
		end -- 2435
	end -- 2435
	if not _match_0 then -- 2435
		if not (config.editingInfo ~= nil) then -- 2439
			local folder -- 2440
			if App.locale:match('^zh') then -- 2440
				folder = 'zh-Hans' -- 2440
			else -- 2440
				folder = 'en' -- 2440
			end -- 2440
			config.editingInfo = json.encode({ -- 2442
				index = 0, -- 2442
				files = { -- 2444
					{ -- 2445
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2445
						title = "welcome.md" -- 2446
					} -- 2444
				} -- 2443
			}) -- 2441
		end -- 2439
		return { -- 2450
			success = true, -- 2450
			editingInfo = config.editingInfo -- 2450
		} -- 2450
	end -- 2435
end) -- 2432
HttpServer:post("/command", function(req) -- 2452
	do -- 2453
		local _type_0 = type(req) -- 2453
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2453
		if _tab_0 then -- 2453
			local code -- 2453
			do -- 2453
				local _obj_0 = req.body -- 2453
				local _type_1 = type(_obj_0) -- 2453
				if "table" == _type_1 or "userdata" == _type_1 then -- 2453
					code = _obj_0.code -- 2453
				end -- 2453
			end -- 2453
			local log -- 2453
			do -- 2453
				local _obj_0 = req.body -- 2453
				local _type_1 = type(_obj_0) -- 2453
				if "table" == _type_1 or "userdata" == _type_1 then -- 2453
					log = _obj_0.log -- 2453
				end -- 2453
			end -- 2453
			if code ~= nil and log ~= nil then -- 2453
				emit("AppCommand", code, log) -- 2454
				return { -- 2455
					success = true -- 2455
				} -- 2455
			end -- 2453
		end -- 2453
	end -- 2453
	return { -- 2452
		success = false -- 2452
	} -- 2452
end) -- 2452
HttpServer:post("/log/save", function() -- 2457
	local folder = ".download" -- 2458
	local fullLogFile = "dora_full_logs.txt" -- 2459
	local fullFolder = Path(Content.writablePath, folder) -- 2460
	Content:mkdir(fullFolder) -- 2461
	local logPath = Path(fullFolder, fullLogFile) -- 2462
	if App:saveLog(logPath) then -- 2463
		return { -- 2464
			success = true, -- 2464
			path = Path(folder, fullLogFile) -- 2464
		} -- 2464
	end -- 2463
	return { -- 2457
		success = false -- 2457
	} -- 2457
end) -- 2457
local tailLines -- 2466
tailLines = function(text, count) -- 2466
	local lines = { } -- 2467
	text = text:gsub("\r\n", "\n") -- 2468
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2469
		lines[#lines + 1] = line -- 2470
	end -- 2469
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2471
		table.remove(lines) -- 2472
	end -- 2471
	local start = math.max(1, #lines - count + 1) -- 2473
	local out = { } -- 2474
	for i = start, #lines do -- 2475
		out[#out + 1] = lines[i] -- 2476
	end -- 2475
	return table.concat(out, "\n") -- 2477
end -- 2466
HttpServer:post("/log", function(req) -- 2479
	local count = 100 -- 2480
	if req and req.body and req.body.count ~= nil then -- 2481
		count = req.body.count -- 2482
	end -- 2481
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2483
		return { -- 2484
			success = false, -- 2484
			message = "count must be a positive integer" -- 2484
		} -- 2484
	end -- 2483
	local folder = ".download" -- 2485
	local fullLogFile = "dora_full_logs.txt" -- 2486
	local fullFolder = Path(Content.writablePath, folder) -- 2487
	Content:mkdir(fullFolder) -- 2488
	local logPath = Path(fullFolder, fullLogFile) -- 2489
	if App:saveLog(logPath) then -- 2490
		local text = Content:load(logPath) -- 2491
		if text then -- 2492
			return { -- 2493
				success = true, -- 2493
				log = tailLines(text, count) -- 2493
			} -- 2493
		else -- 2495
			return { -- 2495
				success = false, -- 2495
				message = "failed to read log" -- 2495
			} -- 2495
		end -- 2492
	else -- 2497
		return { -- 2497
			success = false, -- 2497
			message = "failed to save log" -- 2497
		} -- 2497
	end -- 2490
	return { -- 2479
		success = false -- 2479
	} -- 2479
end) -- 2479
HttpServer:post("/yarn/check", function(req) -- 2499
	local yarncompile = require("yarncompile") -- 2500
	do -- 2501
		local _type_0 = type(req) -- 2501
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2501
		if _tab_0 then -- 2501
			local code -- 2501
			do -- 2501
				local _obj_0 = req.body -- 2501
				local _type_1 = type(_obj_0) -- 2501
				if "table" == _type_1 or "userdata" == _type_1 then -- 2501
					code = _obj_0.code -- 2501
				end -- 2501
			end -- 2501
			if code ~= nil then -- 2501
				local jsonObject = json.decode(code) -- 2502
				if jsonObject then -- 2502
					local errors = { } -- 2503
					local _list_0 = jsonObject.nodes -- 2504
					for _index_0 = 1, #_list_0 do -- 2504
						local node = _list_0[_index_0] -- 2504
						local title, body = node.title, node.body -- 2505
						local luaCode, err = yarncompile(body) -- 2506
						if not luaCode then -- 2506
							errors[#errors + 1] = title .. ":" .. err -- 2507
						end -- 2506
					end -- 2504
					return { -- 2508
						success = true, -- 2508
						syntaxError = table.concat(errors, "\n\n") -- 2508
					} -- 2508
				end -- 2502
			end -- 2501
		end -- 2501
	end -- 2501
	return { -- 2499
		success = false -- 2499
	} -- 2499
end) -- 2499
HttpServer:post("/yarn/check-file", function(req) -- 2510
	local yarncompile = require("yarncompile") -- 2511
	do -- 2512
		local _type_0 = type(req) -- 2512
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2512
		if _tab_0 then -- 2512
			local code -- 2512
			do -- 2512
				local _obj_0 = req.body -- 2512
				local _type_1 = type(_obj_0) -- 2512
				if "table" == _type_1 or "userdata" == _type_1 then -- 2512
					code = _obj_0.code -- 2512
				end -- 2512
			end -- 2512
			if code ~= nil then -- 2512
				local res, _, err = yarncompile(code, true) -- 2513
				if not res then -- 2513
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2514
					return { -- 2515
						success = false, -- 2515
						message = message, -- 2515
						line = line, -- 2515
						column = column, -- 2515
						node = node -- 2515
					} -- 2515
				end -- 2513
			end -- 2512
		end -- 2512
	end -- 2512
	return { -- 2510
		success = true -- 2510
	} -- 2510
end) -- 2510
getWaProjectDirFromFile = function(file) -- 2517
	local current -- 2518
	if Content:isdir(file) then -- 2518
		current = file -- 2518
	else -- 2518
		current = Path:getPath(file) -- 2518
	end -- 2518
	if current == "" then -- 2519
		return nil -- 2519
	end -- 2519
	repeat -- 2520
		local modPath = Path(current, "wa.mod") -- 2521
		if Content:exist(modPath) then -- 2522
			return current, modPath -- 2523
		end -- 2522
		local parent = Path:getPath(current) -- 2524
		if parent == "" or parent == current then -- 2525
			break -- 2525
		end -- 2525
		current = parent -- 2526
	until false -- 2520
	return nil -- 2528
end -- 2517
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2530
	do -- 2531
		local _type_0 = type(req) -- 2531
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2531
		if _tab_0 then -- 2531
			local path -- 2531
			do -- 2531
				local _obj_0 = req.body -- 2531
				local _type_1 = type(_obj_0) -- 2531
				if "table" == _type_1 or "userdata" == _type_1 then -- 2531
					path = _obj_0.path -- 2531
				end -- 2531
			end -- 2531
			if path ~= nil then -- 2531
				local projDir = getWaProjectDirFromFile(path) -- 2532
				if projDir then -- 2532
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2533
					if not Content:exist(sourceDoraPath) then -- 2534
						return { -- 2535
							success = false, -- 2535
							message = "missing dora template" -- 2535
						} -- 2535
					end -- 2534
					local targetVendorPath = Path(projDir, "vendor") -- 2536
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2537
					if not Content:exist(targetVendorPath) then -- 2538
						if not Content:mkdir(targetVendorPath) then -- 2539
							return { -- 2540
								success = false, -- 2540
								message = "failed to create vendor folder" -- 2540
							} -- 2540
						end -- 2539
					elseif not Content:isdir(targetVendorPath) then -- 2541
						return { -- 2542
							success = false, -- 2542
							message = "vendor path is not a folder" -- 2542
						} -- 2542
					end -- 2538
					if Content:exist(targetDoraPath) then -- 2543
						if not Content:remove(targetDoraPath) then -- 2544
							return { -- 2545
								success = false, -- 2545
								message = "failed to remove old dora" -- 2545
							} -- 2545
						end -- 2544
					end -- 2543
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2546
						return { -- 2547
							success = false, -- 2547
							message = "failed to copy dora" -- 2547
						} -- 2547
					end -- 2546
					return { -- 2548
						success = true -- 2548
					} -- 2548
				else -- 2550
					return { -- 2550
						success = false, -- 2550
						message = 'Wa file needs a project' -- 2550
					} -- 2550
				end -- 2532
			end -- 2531
		end -- 2531
	end -- 2531
	return { -- 2530
		success = false, -- 2530
		message = "invalid call" -- 2530
	} -- 2530
end) -- 2530
HttpServer:postSchedule("/wa/build", function(req) -- 2552
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
					local message = Wasm:buildWaAsync(projDir) -- 2555
					if message == "" then -- 2556
						return { -- 2557
							success = true -- 2557
						} -- 2557
					else -- 2559
						return { -- 2559
							success = false, -- 2559
							message = message -- 2559
						} -- 2559
					end -- 2556
				else -- 2561
					return { -- 2561
						success = false, -- 2561
						message = 'Wa file needs a project' -- 2561
					} -- 2561
				end -- 2554
			end -- 2553
		end -- 2553
	end -- 2553
	return { -- 2562
		success = false, -- 2562
		message = 'failed to build' -- 2562
	} -- 2562
end) -- 2552
HttpServer:postSchedule("/wa/format", function(req) -- 2564
	do -- 2565
		local _type_0 = type(req) -- 2565
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2565
		if _tab_0 then -- 2565
			local file -- 2565
			do -- 2565
				local _obj_0 = req.body -- 2565
				local _type_1 = type(_obj_0) -- 2565
				if "table" == _type_1 or "userdata" == _type_1 then -- 2565
					file = _obj_0.file -- 2565
				end -- 2565
			end -- 2565
			if file ~= nil then -- 2565
				local code = Wasm:formatWaAsync(file) -- 2566
				if code == "" then -- 2567
					return { -- 2568
						success = false -- 2568
					} -- 2568
				else -- 2570
					return { -- 2570
						success = true, -- 2570
						code = code -- 2570
					} -- 2570
				end -- 2567
			end -- 2565
		end -- 2565
	end -- 2565
	return { -- 2571
		success = false -- 2571
	} -- 2571
end) -- 2564
HttpServer:postSchedule("/wa/create", function(req) -- 2573
	do -- 2574
		local _type_0 = type(req) -- 2574
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2574
		if _tab_0 then -- 2574
			local path -- 2574
			do -- 2574
				local _obj_0 = req.body -- 2574
				local _type_1 = type(_obj_0) -- 2574
				if "table" == _type_1 or "userdata" == _type_1 then -- 2574
					path = _obj_0.path -- 2574
				end -- 2574
			end -- 2574
			if path ~= nil then -- 2574
				if not Content:exist(Path:getPath(path)) then -- 2575
					return { -- 2576
						success = false, -- 2576
						message = "target path not existed" -- 2576
					} -- 2576
				end -- 2575
				if Content:exist(path) then -- 2577
					return { -- 2578
						success = false, -- 2578
						message = "target project folder existed" -- 2578
					} -- 2578
				end -- 2577
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2579
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2580
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2581
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2582
					return { -- 2585
						success = false, -- 2585
						message = "missing template project" -- 2585
					} -- 2585
				end -- 2582
				if not Content:mkdir(path) then -- 2586
					return { -- 2587
						success = false, -- 2587
						message = "failed to create project folder" -- 2587
					} -- 2587
				end -- 2586
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2588
					Content:remove(path) -- 2589
					return { -- 2590
						success = false, -- 2590
						message = "failed to copy template" -- 2590
					} -- 2590
				end -- 2588
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2591
					Content:remove(path) -- 2592
					return { -- 2593
						success = false, -- 2593
						message = "failed to copy template" -- 2593
					} -- 2593
				end -- 2591
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2594
					Content:remove(path) -- 2595
					return { -- 2596
						success = false, -- 2596
						message = "failed to copy template" -- 2596
					} -- 2596
				end -- 2594
				return { -- 2597
					success = true -- 2597
				} -- 2597
			end -- 2574
		end -- 2574
	end -- 2574
	return { -- 2573
		success = false, -- 2573
		message = "invalid call" -- 2573
	} -- 2573
end) -- 2573
local tsBuildGlobs = { -- 2600
	"**/*.ts", -- 2600
	"**/*.tsx", -- 2601
	"!**/.*/**", -- 2602
	"!**/node_modules/**" -- 2603
} -- 2599
local tsSnapshotGlobs = { -- 2606
	"**/*.ts", -- 2606
	"**/*.tsx", -- 2607
	"**/*.lua", -- 2608
	"!**/.*/**", -- 2609
	"!**/node_modules/**" -- 2610
} -- 2605
local collectTSVirtualFiles -- 2612
collectTSVirtualFiles = function(sourceRoot) -- 2612
	local files = { } -- 2613
	local seen = { } -- 2614
	local addFile -- 2615
	addFile = function(file, moduleName, virtualFile) -- 2615
		if moduleName == nil then -- 2615
			moduleName = nil -- 2615
		end -- 2615
		if virtualFile == nil then -- 2615
			virtualFile = nil -- 2615
		end -- 2615
		local targetFile = virtualFile or file -- 2616
		do -- 2617
			local entry = seen[targetFile] -- 2617
			if entry then -- 2617
				if moduleName and moduleName ~= "" then -- 2618
					entry.moduleName = moduleName -- 2618
				end -- 2618
				return -- 2619
			end -- 2617
		end -- 2617
		local content = Content:load(file) -- 2620
		if content then -- 2620
			local entry = { -- 2621
				file = targetFile, -- 2621
				content = content -- 2621
			} -- 2621
			if moduleName and moduleName ~= "" then -- 2622
				entry.moduleName = moduleName -- 2622
			end -- 2622
			seen[targetFile] = entry -- 2623
			files[#files + 1] = entry -- 2624
		end -- 2620
	end -- 2615
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2625
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2626
		for _index_0 = 1, #_list_0 do -- 2626
			local subFile = _list_0[_index_0] -- 2626
			addFile(Path(sourceRoot, subFile)) -- 2627
		end -- 2626
		local libraryRoots = { -- 2629
			Path(sourceRoot, "Script", "Lib"), -- 2629
			Path(sourceRoot, "Lib"), -- 2630
			Path(Content.assetPath, "Script", "Lib") -- 2631
		} -- 2628
		for _index_0 = 1, #libraryRoots do -- 2632
			local libraryRoot = libraryRoots[_index_0] -- 2632
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2633
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2634
				for _index_1 = 1, #_list_1 do -- 2634
					local subFile = _list_1[_index_1] -- 2634
					local file = Path(libraryRoot, subFile) -- 2635
					local virtualFile = Path(sourceRoot, subFile) -- 2636
					addFile(file, nil, virtualFile) -- 2637
				end -- 2634
			end -- 2633
		end -- 2632
	end -- 2625
	local locale -- 2638
	if App.locale:match('^zh') then -- 2638
		locale = 'zh-Hans' -- 2638
	else -- 2638
		locale = 'en' -- 2638
	end -- 2638
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2639
	local _list_0 = Content:getFiles(declarationRoot) -- 2640
	for _index_0 = 1, #_list_0 do -- 2640
		local file = _list_0[_index_0] -- 2640
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2641
			local fullPath = Path(declarationRoot, file) -- 2642
			local moduleName = Path:getName(Path:getName(file)) -- 2643
			addFile(fullPath, moduleName) -- 2644
		end -- 2641
	end -- 2640
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2645
	local lualibBundleTarget -- 2646
	if sourceRoot then -- 2646
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2646
	else -- 2646
		lualibBundleTarget = "lualib_bundle.lua" -- 2646
	end -- 2646
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2647
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2648
	local _list_1 = Content:getFiles(lualibRoot) -- 2649
	for _index_0 = 1, #_list_1 do -- 2649
		local file = _list_1[_index_0] -- 2649
		if Path:getExt(file) == "lua" then -- 2650
			local virtualFile -- 2651
			if sourceRoot then -- 2651
				virtualFile = Path(sourceRoot, "lualib", file) -- 2651
			else -- 2651
				virtualFile = Path("lualib", file) -- 2651
			end -- 2651
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2652
		end -- 2650
	end -- 2649
	return files -- 2653
end -- 2612
local supportsCompilerWebView -- 2655
supportsCompilerWebView = function() -- 2655
	local _val_0 = App.platform -- 2655
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2655
end -- 2655
local webIDECompilerReady = false -- 2656
local webIDEConnectionGeneration = 0 -- 2657
local tsProbeId = 0 -- 2658
local probeWebIDECompiler -- 2660
probeWebIDECompiler = function(isCancelled) -- 2660
	if HttpServer.wsConnectionCount == 0 then -- 2661
		return false -- 2661
	end -- 2661
	tsProbeId = tsProbeId + 1 -- 2662
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2663
	local generation = webIDEConnectionGeneration -- 2664
	local done, ready = false, false -- 2665
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2666
	local listener = Node() -- 2667
	listener:gslot("AppWS", function(event) -- 2668
		if event.type == "Receive" then -- 2669
			local res = json.decode(event.msg) -- 2670
			if res then -- 2670
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2671
					responses = responses + 1 -- 2672
					ready = ready or res.success == true -- 2673
					done = ready or responses >= expectedResponses -- 2674
				end -- 2671
			end -- 2670
		end -- 2669
	end) -- 2668
	emit("AppWS", "Send", json.encode({ -- 2675
		name = "TranspileTSProbe", -- 2675
		id = requestId -- 2675
	})) -- 2675
	local deadline = App.runningTime + 5 -- 2676
	wait(function() -- 2677
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2677
	end) -- 2677
	listener:removeFromParent() -- 2678
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2679
	if generation == webIDEConnectionGeneration then -- 2680
		webIDECompilerReady = ready -- 2680
	end -- 2680
	return ready -- 2681
end -- 2660
local compilerConnectionListener = Node() -- 2683
compilerConnectionListener:addTo(Director.systemUI) -- 2685
local _anon_func_8 = function(event) -- 2687
	local _val_0 = event.type -- 2687
	return "Open" == _val_0 or "Close" == _val_0 -- 2687
end -- 2687
compilerConnectionListener:gslot("AppWS", function(event) -- 2686
	if _anon_func_8(event) then -- 2687
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2688
		webIDECompilerReady = false -- 2689
		if HttpServer.wsConnectionCount > 0 then -- 2690
			return thread(function() -- 2691
				return probeWebIDECompiler() -- 2691
			end) -- 2691
		end -- 2690
	end -- 2687
end) -- 2686
local _anon_func_9 = function(res) -- 2716
	if res.success then -- 2716
		return "tool" -- 2716
	else -- 2716
		return res.failureKind -- 2716
	end -- 2716
end -- 2716
local transpileTSFileWithWebIDE -- 2693
do -- 2693
	local tsBuildRequestId = 0 -- 2694
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2695
		if not probeWebIDECompiler(isCancelled) then -- 2696
			if isCancelled and isCancelled() then -- 2697
				return { -- 2698
					success = false, -- 2698
					file = file, -- 2698
					message = "build canceled", -- 2698
					interrupted = true -- 2698
				} -- 2698
			end -- 2697
			return { -- 2699
				success = false, -- 2699
				file = file, -- 2699
				message = "TypeScript transpiler is not ready", -- 2699
				failureKind = "tool" -- 2699
			} -- 2699
		end -- 2696
		tsBuildRequestId = tsBuildRequestId + 1 -- 2700
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2701
		local done = false -- 2702
		local result = nil -- 2703
		local listener = Node() -- 2704
		listener:gslot("AppWS", function(event) -- 2705
			if event.type == "Receive" then -- 2706
				local res = json.decode(event.msg) -- 2707
				if res then -- 2707
					if res.name == "TranspileTS" and res.id == requestId then -- 2708
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2709
							local luaFile = Path:replaceExt(file, "lua") -- 2710
							if Content:save(luaFile, res.luaCode) then -- 2711
								result = { -- 2712
									success = true, -- 2712
									file = file -- 2712
								} -- 2712
							else -- 2714
								result = { -- 2714
									success = false, -- 2714
									file = file, -- 2714
									message = "failed to save " .. tostring(luaFile) -- 2714
								} -- 2714
							end -- 2711
						else -- 2716
							result = { -- 2716
								success = false, -- 2716
								file = file, -- 2716
								message = res.message or "Compiler returned no Lua output", -- 2716
								failureKind = _anon_func_9(res) -- 2716
							} -- 2716
						end -- 2709
						done = true -- 2717
					end -- 2708
				end -- 2707
			end -- 2706
		end) -- 2705
		emit("AppWS", "Send", json.encode({ -- 2718
			name = "TranspileTS", -- 2718
			id = requestId, -- 2718
			file = file, -- 2718
			content = content, -- 2718
			projectRoot = sourceRoot, -- 2718
			files = files -- 2718
		})) -- 2718
		local deadline = App.runningTime + 30 -- 2719
		wait(function() -- 2720
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2720
		end) -- 2720
		listener:removeFromParent() -- 2721
		if not done then -- 2722
			webIDECompilerReady = false -- 2723
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
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2726
				failureKind = "tool" -- 2726
			} -- 2726
		end -- 2722
		return result -- 2727
	end -- 2695
end -- 2693
local compilerReadyTimeout <const> = 15 -- 2729
local compilerBuildTimeout <const> = 30 -- 2730
local compilerIdleCloseSeconds <const> = 8 -- 2731
local compilerReady = false -- 2732
local compilerRequested = false -- 2733
local compilerFailure = nil -- 2734
local compilerUsers = 0 -- 2735
local compilerCloseGeneration = 0 -- 2736
local compilerJobId = 0 -- 2737
local compilerJobs = { } -- 2738
local compilerResults = { } -- 2739
local compilerInFlight = { } -- 2740
HttpServer:post("/compiler/ready", function() -- 2742
	if not compilerRequested then -- 2743
		return { -- 2743
			success = false -- 2743
		} -- 2743
	end -- 2743
	compilerReady = true -- 2744
	return { -- 2745
		success = true -- 2745
	} -- 2745
end) -- 2742
HttpServer:post("/compiler/failure", function(req) -- 2747
	if not compilerRequested then -- 2748
		return { -- 2748
			success = false -- 2748
		} -- 2748
	end -- 2748
	do -- 2749
		local _type_0 = type(req) -- 2749
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2749
		if _tab_0 then -- 2749
			local message -- 2749
			do -- 2749
				local _obj_0 = req.body -- 2749
				local _type_1 = type(_obj_0) -- 2749
				if "table" == _type_1 or "userdata" == _type_1 then -- 2749
					message = _obj_0.message -- 2749
				end -- 2749
			end -- 2749
			if message ~= nil then -- 2749
				if type(message) == "string" then -- 2750
					compilerFailure = message -- 2751
					compilerReady = false -- 2752
					return { -- 2753
						success = true -- 2753
					} -- 2753
				end -- 2750
			end -- 2749
		end -- 2749
	end -- 2749
	return { -- 2747
		success = false -- 2747
	} -- 2747
end) -- 2747
HttpServer:postSchedule("/compiler/poll", function() -- 2755
	if not compilerRequested then -- 2756
		return { -- 2756
			success = false -- 2756
		} -- 2756
	end -- 2756
	compilerReady = true -- 2757
	local deadline = App.runningTime + 5 -- 2758
	wait(function() -- 2759
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2759
	end) -- 2759
	if not (compilerRequested and not compilerFailure) then -- 2760
		return { -- 2760
			success = false -- 2760
		} -- 2760
	end -- 2760
	local job = table.remove(compilerJobs, 1) -- 2761
	if job then -- 2762
		compilerInFlight[job.id] = true -- 2763
	end -- 2762
	return { -- 2764
		success = true, -- 2764
		job = job -- 2764
	} -- 2764
end) -- 2755
HttpServer:post("/compiler/result", function(req) -- 2766
	do -- 2767
		local _type_0 = type(req) -- 2767
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2767
		if _tab_0 then -- 2767
			local body = req.body -- 2767
			if body ~= nil then -- 2767
				local id = body.id -- 2768
				if not (id and compilerInFlight[id]) then -- 2769
					return { -- 2769
						success = false, -- 2769
						message = "invalid compiler job" -- 2769
					} -- 2769
				end -- 2769
				compilerInFlight[id] = nil -- 2770
				compilerResults[id] = body -- 2771
				return { -- 2772
					success = true -- 2772
				} -- 2772
			end -- 2767
		end -- 2767
	end -- 2767
	return { -- 2766
		success = false -- 2766
	} -- 2766
end) -- 2766
local acquireCompiler -- 2774
acquireCompiler = function() -- 2774
	compilerUsers = compilerUsers + 1 -- 2775
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2776
	if not compilerRequested then -- 2777
		compilerRequested = true -- 2778
		compilerReady = false -- 2779
		compilerFailure = nil -- 2780
		return emit("AppWebView", "/compiler.html", true) -- 2781
	end -- 2777
end -- 2774
local releaseCompiler -- 2783
releaseCompiler = function() -- 2783
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2784
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2785
	if not (compilerUsers == 0) then -- 2786
		return -- 2786
	end -- 2786
	local closeGeneration = compilerCloseGeneration -- 2787
	return thread(function() -- 2788
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2789
		wait(function() -- 2790
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2791
		end) -- 2790
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2796
			compilerRequested = false -- 2797
			compilerReady = false -- 2798
			return emit("AppWebView", "/compiler.html", false) -- 2799
		end -- 2796
	end) -- 2788
end -- 2783
local removeCompilerJob -- 2801
removeCompilerJob = function(id) -- 2801
	for index = #compilerJobs, 1, -1 do -- 2802
		if compilerJobs[index].id == id then -- 2803
			table.remove(compilerJobs, index) -- 2804
		end -- 2803
	end -- 2802
	compilerInFlight[id] = nil -- 2805
	compilerResults[id] = nil -- 2806
end -- 2801
local transpileTSFileWithCompiler -- 2808
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2808
	acquireCompiler() -- 2809
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2810
	wait(function() -- 2811
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2811
	end) -- 2811
	if not compilerReady then -- 2812
		releaseCompiler() -- 2813
		if isCancelled and isCancelled() then -- 2814
			return { -- 2815
				success = false, -- 2815
				file = file, -- 2815
				message = "build canceled", -- 2815
				interrupted = true -- 2815
			} -- 2815
		end -- 2814
		return { -- 2816
			success = false, -- 2816
			file = file, -- 2816
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2816
			failureKind = "tool" -- 2816
		} -- 2816
	end -- 2812
	compilerJobId = compilerJobId + 1 -- 2817
	local jobId = compilerJobId -- 2818
	compilerJobs[#compilerJobs + 1] = { -- 2820
		id = jobId, -- 2820
		file = file, -- 2821
		content = content, -- 2822
		projectRoot = sourceRoot, -- 2823
		files = files -- 2824
	} -- 2819
	local deadline = App.runningTime + compilerBuildTimeout -- 2825
	wait(function() -- 2826
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2826
	end) -- 2826
	local response = compilerResults[jobId] -- 2827
	removeCompilerJob(jobId) -- 2828
	releaseCompiler() -- 2829
	if not response then -- 2830
		if isCancelled and isCancelled() then -- 2831
			return { -- 2832
				success = false, -- 2832
				file = file, -- 2832
				message = "build canceled", -- 2832
				interrupted = true -- 2832
			} -- 2832
		end -- 2831
		return { -- 2833
			success = false, -- 2833
			file = file, -- 2833
			message = compilerFailure or "TypeScript transpile timed out", -- 2833
			failureKind = "tool" -- 2833
		} -- 2833
	end -- 2830
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2834
		local luaFile = Path:replaceExt(file, "lua") -- 2835
		if Content:save(luaFile, response.luaCode) then -- 2836
			return { -- 2837
				success = true, -- 2837
				file = file -- 2837
			} -- 2837
		end -- 2836
		return { -- 2838
			success = false, -- 2838
			file = file, -- 2838
			message = "failed to save " .. tostring(luaFile) -- 2838
		} -- 2838
	end -- 2834
	return { -- 2839
		success = false, -- 2839
		file = file, -- 2839
		message = response.message or "TypeScript transpile failed" -- 2839
	} -- 2839
end -- 2808
local compilerFailureListener = Node() -- 2841
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2842
	compilerFailure = message -- 2843
	compilerReady = false -- 2844
end) -- 2842
local transpileTSFile -- 2846
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2846
	if supportsCompilerWebView() and not files then -- 2847
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2848
	end -- 2847
	if HttpServer.wsConnectionCount > 0 then -- 2849
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2850
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2851
			return result -- 2851
		end -- 2851
		webIDECompilerReady = false -- 2852
	end -- 2849
	if supportsCompilerWebView() then -- 2853
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2854
	end -- 2853
	return { -- 2855
		success = false, -- 2855
		file = file, -- 2855
		message = "Web IDE compiler not connected", -- 2855
		failureKind = "tool" -- 2855
	} -- 2855
end -- 2846
local _anon_func_10 = function(path) -- 2870
	local _val_0 = Path:getExt(path) -- 2870
	return "ts" == _val_0 or "tsx" == _val_0 -- 2870
end -- 2870
HttpServer:postSchedule("/ts/build", function(req) -- 2857
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2858
	local buildSucceeded = false -- 2859
	local _ <close> = setmetatable({ }, { -- 2860
		__close = function() -- 2860
			return finishUpdate(buildSucceeded) -- 2860
		end -- 2860
	}) -- 2860
	do -- 2861
		local _type_0 = type(req) -- 2861
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2861
		if _tab_0 then -- 2861
			local path -- 2861
			do -- 2861
				local _obj_0 = req.body -- 2861
				local _type_1 = type(_obj_0) -- 2861
				if "table" == _type_1 or "userdata" == _type_1 then -- 2861
					path = _obj_0.path -- 2861
				end -- 2861
			end -- 2861
			if path ~= nil then -- 2861
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2862
					return { -- 2863
						success = false, -- 2863
						message = "Web IDE not connected" -- 2863
					} -- 2863
				end -- 2862
				local projectRoot = req.body.projectRoot -- 2864
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2865
				if not Content:exist(path) then -- 2866
					return { -- 2867
						success = false, -- 2867
						message = "path not existed" -- 2867
					} -- 2867
				end -- 2866
				local messages = { } -- 2868
				if not Content:isdir(path) then -- 2869
					if not (_anon_func_10(path)) then -- 2870
						return { -- 2871
							success = false, -- 2871
							message = "expecting a TypeScript file" -- 2871
						} -- 2871
					end -- 2870
					local content = Content:load(path) -- 2872
					if not content then -- 2873
						return { -- 2874
							success = false, -- 2874
							message = "failed to read file" -- 2874
						} -- 2874
					end -- 2873
					emit("AppWS", "Send", json.encode({ -- 2875
						name = "UpdateFile", -- 2875
						file = path, -- 2875
						exists = true, -- 2875
						content = content, -- 2875
						projectRoot = sourceRoot -- 2875
					})) -- 2875
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2876
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2877
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2878
					end -- 2876
				else -- 2880
					local fileData = { } -- 2880
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2881
					for _index_0 = 1, #_list_0 do -- 2881
						local subFile = _list_0[_index_0] -- 2881
						local file = Path(path, subFile) -- 2882
						local content = Content:load(file) -- 2883
						if content then -- 2883
							fileData[file] = content -- 2884
							emit("AppWS", "Send", json.encode({ -- 2885
								name = "UpdateFile", -- 2885
								file = file, -- 2885
								exists = true, -- 2885
								content = content, -- 2885
								projectRoot = sourceRoot -- 2885
							})) -- 2885
						else -- 2887
							messages[#messages + 1] = { -- 2887
								success = false, -- 2887
								file = file, -- 2887
								message = "failed to read file" -- 2887
							} -- 2887
						end -- 2883
					end -- 2881
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2888
					for file, content in pairs(fileData) do -- 2889
						if "d" == Path:getExt(Path:getName(file)) then -- 2890
							goto _continue_0 -- 2890
						end -- 2890
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2891
						::_continue_0:: -- 2890
					end -- 2889
				end -- 2869
				local success = true -- 2892
				for _index_0 = 1, #messages do -- 2893
					local item = messages[_index_0] -- 2893
					if not item.success then -- 2894
						success = false -- 2894
					end -- 2894
				end -- 2893
				local message = nil -- 2895
				if not success then -- 2896
					message = "TypeScript compilation failed" -- 2896
				end -- 2896
				buildSucceeded = success -- 2897
				return { -- 2898
					success = success, -- 2898
					messages = messages, -- 2898
					message = message -- 2898
				} -- 2898
			end -- 2861
		end -- 2861
	end -- 2861
	return { -- 2857
		success = false -- 2857
	} -- 2857
end) -- 2857
HttpServer:post("/download", function(req) -- 2900
	do -- 2901
		local _type_0 = type(req) -- 2901
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2901
		if _tab_0 then -- 2901
			local url -- 2901
			do -- 2901
				local _obj_0 = req.body -- 2901
				local _type_1 = type(_obj_0) -- 2901
				if "table" == _type_1 or "userdata" == _type_1 then -- 2901
					url = _obj_0.url -- 2901
				end -- 2901
			end -- 2901
			local target -- 2901
			do -- 2901
				local _obj_0 = req.body -- 2901
				local _type_1 = type(_obj_0) -- 2901
				if "table" == _type_1 or "userdata" == _type_1 then -- 2901
					target = _obj_0.target -- 2901
				end -- 2901
			end -- 2901
			if url ~= nil and target ~= nil then -- 2901
				local Entry = require("Script.Dev.Entry") -- 2902
				Entry.downloadFile(url, target) -- 2903
				return { -- 2904
					success = true -- 2904
				} -- 2904
			end -- 2901
		end -- 2901
	end -- 2901
	return { -- 2900
		success = false -- 2900
	} -- 2900
end) -- 2900
local isDesktopPlatform -- 2906
isDesktopPlatform = function() -- 2906
	local _val_0 = App.platform -- 2907
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2907
end -- 2906
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 2909
local nativeIDEListener = Node() -- 2910
nativeIDEListener:addTo(Director.systemUI) -- 2911
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 2912
	nativeIDEState, nativeIDEMessage = state, message -- 2913
end) -- 2912
local _anon_func_11 = function() -- 2916
	local _val_0 = App.platform -- 2916
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2916
end -- 2916
HttpServer:post("/ide", function(req) -- 2915
	if not (_anon_func_11()) then -- 2916
		return { -- 2916
			success = false, -- 2916
			message = "Native IDE is unavailable" -- 2916
		} -- 2916
	end -- 2916
	if not App.webIDEEnabled then -- 2917
		return { -- 2917
			success = false, -- 2917
			message = "Embedded Web IDE is disabled" -- 2917
		} -- 2917
	end -- 2917
	do -- 2918
		local _type_0 = type(req) -- 2918
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2918
		if _tab_0 then -- 2918
			local action -- 2918
			do -- 2918
				local _obj_0 = req.body -- 2918
				local _type_1 = type(_obj_0) -- 2918
				if "table" == _type_1 or "userdata" == _type_1 then -- 2918
					action = _obj_0.action -- 2918
				end -- 2918
			end -- 2918
			if action ~= nil then -- 2918
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 2919
					emit("AppWebView", "/ide/" .. action, true) -- 2920
					return { -- 2921
						success = true -- 2921
					} -- 2921
				end -- 2919
			end -- 2918
		end -- 2918
	end -- 2918
	return { -- 2915
		success = false, -- 2915
		message = "invalid IDE action" -- 2915
	} -- 2915
end) -- 2915
local _anon_func_12 = function() -- 2937
	local _val_0 = App.platform -- 2937
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2937
end -- 2937
local getServerStatus -- 2923
getServerStatus = function() -- 2923
	local Entry = require("Script.Dev.Entry") -- 2924
	local running = Entry.getCurrentEntryStatus() -- 2925
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2926
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2927
	return { -- 2929
		success = true, -- 2929
		platform = App.platform, -- 2930
		locale = App.locale, -- 2931
		version = App.version, -- 2932
		url = "http://localhost:8866", -- 2933
		wsConnectionCount = wsConnectionCount, -- 2934
		webIDEConnected = wsConnectionCount > 0, -- 2935
		nativeIDE = { -- 2937
			supported = _anon_func_12(), -- 2937
			enabled = App.webIDEEnabled, -- 2938
			state = nativeIDEState, -- 2939
			message = nativeIDEMessage -- 2940
		}, -- 2936
		typescriptCompiler = { -- 2942
			webIDEReady = webIDECompilerReady, -- 2942
			webIDEGeneration = webIDEConnectionGeneration, -- 2943
			embeddedSupported = supportsCompilerWebView(), -- 2944
			embeddedRequested = compilerRequested, -- 2945
			embeddedReady = compilerReady, -- 2946
			users = compilerUsers, -- 2947
			queuedJobs = #compilerJobs, -- 2948
			failure = compilerFailure -- 2949
		}, -- 2941
		assetPath = Content.assetPath, -- 2950
		writablePath = Content.writablePath, -- 2951
		appPath = Content.appPath, -- 2952
		waTemplateReady = waTemplateReady, -- 2953
		running = running -- 2954
	} -- 2928
end -- 2923
HttpServer:post("/status", function() -- 2957
	return getServerStatus() -- 2958
end) -- 2957
HttpServer:postSchedule("/doctor/fix", function(req) -- 2960
	do -- 2961
		local _type_0 = type(req) -- 2961
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2961
		if _tab_0 then -- 2961
			local openWebIDE -- 2961
			do -- 2961
				local _obj_0 = req.body -- 2961
				local _type_1 = type(_obj_0) -- 2961
				if "table" == _type_1 or "userdata" == _type_1 then -- 2961
					openWebIDE = _obj_0.openWebIDE -- 2961
				end -- 2961
			end -- 2961
			if openWebIDE ~= nil then -- 2961
				if not openWebIDE then -- 2962
					return { -- 2963
						success = false, -- 2963
						message = "nothing to fix" -- 2963
					} -- 2963
				end -- 2962
				local status = getServerStatus() -- 2964
				if status.webIDEConnected then -- 2965
					return { -- 2966
						success = true, -- 2966
						fixed = false, -- 2966
						message = "Web IDE already connected.", -- 2966
						status = status -- 2966
					} -- 2966
				end -- 2965
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2967
				if waitSeconds > 0 then -- 2968
					local deadline = os.time() + waitSeconds -- 2969
					repeat -- 2970
						sleep(0.2) -- 2971
						status = getServerStatus() -- 2972
						if status.webIDEConnected then -- 2973
							return { -- 2974
								success = true, -- 2974
								fixed = false, -- 2974
								reconnected = true, -- 2974
								message = "Web IDE reconnected.", -- 2974
								status = status -- 2974
							} -- 2974
						end -- 2973
					until os.time() >= deadline -- 2970
				end -- 2968
				if not isDesktopPlatform() then -- 2976
					return { -- 2977
						success = false, -- 2977
						message = "opening Web IDE is only supported on desktop platforms", -- 2977
						status = status -- 2977
					} -- 2977
				end -- 2976
				local url = "http://localhost:8866" -- 2978
				App:openURL(url) -- 2979
				status.openedURL = url -- 2980
				return { -- 2981
					success = true, -- 2981
					fixed = true, -- 2981
					message = "Opened Web IDE in the local browser.", -- 2981
					url = url, -- 2981
					status = status -- 2981
				} -- 2981
			end -- 2961
		end -- 2961
	end -- 2961
	return { -- 2960
		success = false, -- 2960
		message = "invalid call" -- 2960
	} -- 2960
end) -- 2960
local status = { } -- 2983
_module_0 = status -- 2984
status.transpileTSFile = transpileTSFile -- 2986
status.buildAsync = function(path) -- 2988
	if not Content:exist(path) then -- 2989
		return { -- 2990
			success = false, -- 2990
			file = path, -- 2990
			message = "file not existed" -- 2990
		} -- 2990
	end -- 2989
	do -- 2991
		local _exp_0 = Path:getExt(path) -- 2991
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2991
			if '' == Path:getExt(Path:getName(path)) then -- 2992
				local content = Content:loadAsync(path) -- 2993
				if content then -- 2993
					local resultCodes, err = compileFileAsync(path, content) -- 2994
					if resultCodes then -- 2994
						return { -- 2995
							success = true, -- 2995
							file = path -- 2995
						} -- 2995
					else -- 2997
						return { -- 2997
							success = false, -- 2997
							file = path, -- 2997
							message = err -- 2997
						} -- 2997
					end -- 2994
				end -- 2993
			end -- 2992
		elseif "lua" == _exp_0 then -- 2998
			local content = Content:loadAsync(path) -- 2999
			if content then -- 2999
				do -- 3000
					local isTIC80 = CheckTIC80Code(content) -- 3000
					if isTIC80 then -- 3000
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 3001
					end -- 3000
				end -- 3000
				local success, info -- 3002
				do -- 3002
					local _obj_0 = luaCheck(path, content) -- 3002
					success, info = _obj_0.success, _obj_0.info -- 3002
				end -- 3002
				if success then -- 3003
					return { -- 3004
						success = true, -- 3004
						file = path -- 3004
					} -- 3004
				elseif info and #info > 0 then -- 3005
					local messages = { } -- 3006
					for _index_0 = 1, #info do -- 3007
						local _des_0 = info[_index_0] -- 3007
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3007
						local lineText = "" -- 3008
						if line then -- 3009
							local currentLine = 1 -- 3010
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3011
								if currentLine == line then -- 3012
									lineText = text -- 3013
									break -- 3014
								end -- 3012
								currentLine = currentLine + 1 -- 3015
							end -- 3011
						end -- 3009
						if line then -- 3016
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3017
						else -- 3019
							messages[#messages + 1] = message -- 3019
						end -- 3016
					end -- 3007
					return { -- 3020
						success = false, -- 3020
						file = path, -- 3020
						message = table.concat(messages, "\n") -- 3020
					} -- 3020
				else -- 3022
					return { -- 3022
						success = false, -- 3022
						file = path, -- 3022
						message = "lua check failed" -- 3022
					} -- 3022
				end -- 3003
			end -- 2999
		elseif "yarn" == _exp_0 then -- 3023
			local content = Content:loadAsync(path) -- 3024
			if content then -- 3024
				local res, _, err = yarncompile(content, true) -- 3025
				if res then -- 3025
					return { -- 3026
						success = true, -- 3026
						file = path -- 3026
					} -- 3026
				else -- 3028
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3028
					local lineText = "" -- 3029
					if line then -- 3030
						local currentLine = 1 -- 3031
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3032
							if currentLine == line then -- 3033
								lineText = text -- 3034
								break -- 3035
							end -- 3033
							currentLine = currentLine + 1 -- 3036
						end -- 3032
					end -- 3030
					if node ~= "" then -- 3037
						node = "node: " .. tostring(node) .. ", " -- 3038
					else -- 3039
						node = "" -- 3039
					end -- 3037
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3040
					return { -- 3041
						success = false, -- 3041
						file = path, -- 3041
						message = message -- 3041
					} -- 3041
				end -- 3025
			end -- 3024
		end -- 2991
	end -- 2991
	return { -- 3042
		success = false, -- 3042
		file = path, -- 3042
		message = "invalid file to build" -- 3042
	} -- 3042
end -- 2988
HttpServer:postSchedule("/git/commit-files", function(req) -- 3044
	do -- 3045
		local _type_0 = type(req) -- 3045
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3045
		if _tab_0 then -- 3045
			local body = req.body -- 3045
			if body ~= nil then -- 3045
				local repoPath, commit = body.repoPath, body.commit -- 3046
				if gitInvalidRepoPath(repoPath) then -- 3047
					return { -- 3047
						success = false, -- 3047
						message = "invalid repoPath" -- 3047
					} -- 3047
				end -- 3047
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3048
					return { -- 3048
						success = false, -- 3048
						message = "invalid commit" -- 3048
					} -- 3048
				end -- 3048
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3049
				if not res.success then -- 3050
					return res -- 3050
				end -- 3050
				return { -- 3051
					success = true, -- 3051
					status = res.status, -- 3051
					data = res.status and res.status.data -- 3051
				} -- 3051
			end -- 3045
		end -- 3045
	end -- 3045
	return invalidArguments -- 3044
end) -- 3044
thread(function() -- 3053
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3054
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3055
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3056
		local storedAsset -- 3059
		storedAsset = function(file) -- 3059
			if Content:exist(file) then -- 3060
				return Content:load(file) -- 3061
			elseif Content:exist(file .. ".gz") then -- 3062
				return Content:load(file .. ".gz") -- 3063
			else -- 3064
				return "" -- 3064
			end -- 3060
		end -- 3059
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3065
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3066
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3067
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3068
		local readyContent = table.concat({ -- 3070
			App.version, -- 3070
			storedAsset(doraWeb), -- 3071
			storedAsset(heavyAssets), -- 3072
			storedAsset(runtimeIndex), -- 3073
			storedAsset(compilerIndex), -- 3074
			storedAsset(manifest) -- 3075
		}, "\n") -- 3069
		local needReload -- 3077
		if Content:exist(doraReady) then -- 3077
			needReload = readyContent ~= Content:load(doraReady) -- 3078
		else -- 3079
			needReload = true -- 3079
		end -- 3077
		if needReload then -- 3080
			Content:remove(Path(Content.appPath, ".www")) -- 3081
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3082
			Content:save(doraReady, readyContent) -- 3086
			print("Dora Dora is ready!") -- 3087
		end -- 3080
	end -- 3056
	if App.platform == "Emscripten" then -- 3088
		status.url = nil -- 3089
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3090
	end -- 3088
	HttpServer:clearStaticCacheControls() -- 3091
	HttpServer:setStaticCacheControl("no-cache") -- 3092
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3093
	if HttpServer:start(8866) then -- 3097
		local localIP = HttpServer.localIP -- 3098
		if localIP == "" then -- 3099
			localIP = "localhost" -- 3099
		end -- 3099
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3100
		return HttpServer:startWS(8868) -- 3101
	else -- 3103
		status.url = nil -- 3103
		return print("8866 Port not available!") -- 3104
	end -- 3097
end) -- 3053
return _module_0 -- 1
