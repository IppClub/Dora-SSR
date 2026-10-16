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
				local repoPath, command, url = body.repoPath, body.command, body.url -- 703
				local host -- 704
				if url and url ~= "" then -- 704
					host = gitHostFromURL(url) -- 704
				else -- 704
					host = gitCommandHost(repoPath, command) -- 704
				end -- 704
				if not host then -- 705
					return { -- 705
						success = false, -- 705
						message = "git host is required" -- 705
					} -- 705
				end -- 705
				local items = gitCredentialsForHost(host) -- 706
				return { -- 707
					success = true, -- 707
					host = host, -- 707
					items = items, -- 707
					needsSelection = #items > 1, -- 707
					authId = (#items == 1 and items[1].id or nil) -- 707
				} -- 707
			end -- 702
		end -- 702
	end -- 702
	return invalidArguments -- 701
end) -- 701
HttpServer:post("/git/auth/save", function(req) -- 709
	do -- 710
		local _type_0 = type(req) -- 710
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 710
		if _tab_0 then -- 710
			local body = req.body -- 710
			if body ~= nil then -- 710
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token -- 711
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$") -- 712
				label = tostring(label or ""):match("^%s*(.-)%s*$") -- 713
				local credentialType = tostring(body.type or "token") -- 714
				username = tostring(username or "") -- 715
				local secret -- 716
				if credentialType == "basic" then -- 716
					secret = tostring(password or "") -- 716
				else -- 716
					secret = tostring(token or password or "") -- 716
				end -- 716
				if host == "" then -- 717
					return { -- 717
						success = false, -- 717
						message = "host is required" -- 717
					} -- 717
				end -- 717
				if label == "" then -- 718
					return { -- 718
						success = false, -- 718
						message = "label is required" -- 718
					} -- 718
				end -- 718
				if secret == "" then -- 719
					return { -- 719
						success = false, -- 719
						message = "secret is required" -- 719
					} -- 719
				end -- 719
				if not (("basic" == credentialType or "token" == credentialType)) then -- 720
					return { -- 720
						success = false, -- 720
						message = "invalid type" -- 720
					} -- 720
				end -- 720
				ensureGitTables() -- 721
				local now = os.time() -- 722
				if id then -- 723
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", { -- 725
						host, -- 725
						label, -- 725
						credentialType, -- 725
						username, -- 725
						secret, -- 725
						now, -- 725
						(tonumber(id) or 0) -- 725
					}) -- 724
					return { -- 727
						success = true, -- 727
						id = tonumber(id) -- 727
					} -- 727
				else -- 729
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", { -- 730
						host, -- 730
						label, -- 730
						credentialType, -- 730
						username, -- 730
						secret, -- 730
						now, -- 730
						now -- 730
					}) -- 729
					local rows = DB:query("select last_insert_rowid()") -- 732
					return { -- 733
						success = true, -- 733
						id = rows and rows[1] and rows[1][1] -- 733
					} -- 733
				end -- 723
			end -- 710
		end -- 710
	end -- 710
	return invalidArguments -- 709
end) -- 709
HttpServer:post("/git/auth/delete", function(req) -- 735
	do -- 736
		local _type_0 = type(req) -- 736
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 736
		if _tab_0 then -- 736
			local id -- 736
			do -- 736
				local _obj_0 = req.body -- 736
				local _type_1 = type(_obj_0) -- 736
				if "table" == _type_1 or "userdata" == _type_1 then -- 736
					id = _obj_0.id -- 736
				end -- 736
			end -- 736
			if id ~= nil then -- 736
				ensureGitTables() -- 737
				local credentialId = tonumber(id) or 0 -- 738
				DB:exec("delete from GitCredential where id = ?", { -- 739
					credentialId -- 739
				}) -- 739
				return { -- 740
					success = true -- 740
				} -- 740
			end -- 736
		end -- 736
	end -- 736
	return invalidArguments -- 735
end) -- 735
HttpServer:postSchedule("/git/auth/test", function(req) -- 742
	do -- 743
		local _type_0 = type(req) -- 743
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 743
		if _tab_0 then -- 743
			local body = req.body -- 743
			if body ~= nil then -- 743
				local repoPath, url, authId = body.repoPath, body.url, body.authId -- 744
				local credential = gitLoadCredential(authId) -- 745
				local optionsJSON = gitAuthOptionsJSON(credential) -- 746
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20) -- 747
			end -- 743
		end -- 743
	end -- 743
	return invalidArguments -- 742
end) -- 742
HttpServer:post("/agent/session/create", function(req) -- 749
	do -- 750
		local _type_0 = type(req) -- 750
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 750
		if _tab_0 then -- 750
			local projectRoot -- 750
			do -- 750
				local _obj_0 = req.body -- 750
				local _type_1 = type(_obj_0) -- 750
				if "table" == _type_1 or "userdata" == _type_1 then -- 750
					projectRoot = _obj_0.projectRoot -- 750
				end -- 750
			end -- 750
			local title -- 750
			do -- 750
				local _obj_0 = req.body -- 750
				local _type_1 = type(_obj_0) -- 750
				if "table" == _type_1 or "userdata" == _type_1 then -- 750
					title = _obj_0.title -- 750
				end -- 750
			end -- 750
			if projectRoot ~= nil and title ~= nil then -- 750
				return AgentSession.createSession(projectRoot, title) -- 751
			end -- 750
		end -- 750
	end -- 750
	return invalidArguments -- 749
end) -- 749
HttpServer:post("/agent/session/create-sub", function(req) -- 753
	do -- 754
		local _type_0 = type(req) -- 754
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 754
		if _tab_0 then -- 754
			local parentSessionId -- 754
			do -- 754
				local _obj_0 = req.body -- 754
				local _type_1 = type(_obj_0) -- 754
				if "table" == _type_1 or "userdata" == _type_1 then -- 754
					parentSessionId = _obj_0.parentSessionId -- 754
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
			if parentSessionId ~= nil and title ~= nil then -- 754
				return AgentSession.createSubSession(parentSessionId, title) -- 755
			end -- 754
		end -- 754
	end -- 754
	return invalidArguments -- 753
end) -- 753
HttpServer:post("/agent/session/get", function(req) -- 757
	do -- 758
		local _type_0 = type(req) -- 758
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 758
		if _tab_0 then -- 758
			local sessionId -- 758
			do -- 758
				local _obj_0 = req.body -- 758
				local _type_1 = type(_obj_0) -- 758
				if "table" == _type_1 or "userdata" == _type_1 then -- 758
					sessionId = _obj_0.sessionId -- 758
				end -- 758
			end -- 758
			if sessionId ~= nil then -- 758
				return AgentSession.getSession(sessionId) -- 759
			end -- 758
		end -- 758
	end -- 758
	return invalidArguments -- 757
end) -- 757
HttpServer:post("/agent/vision/asset", function(req) -- 761
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
			local path -- 762
			do -- 762
				local _obj_0 = req.body -- 762
				local _type_1 = type(_obj_0) -- 762
				if "table" == _type_1 or "userdata" == _type_1 then -- 762
					path = _obj_0.path -- 762
				end -- 762
			end -- 762
			if sessionId ~= nil and path ~= nil then -- 762
				return AgentVisionAssets.getSessionVisionImageFromPath(sessionId, path) -- 763
			end -- 762
		end -- 762
	end -- 762
	return invalidArguments -- 761
end) -- 761
HttpServer:post("/agent/session/mode", function(req) -- 765
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
			local workMode -- 766
			do -- 766
				local _obj_0 = req.body -- 766
				local _type_1 = type(_obj_0) -- 766
				if "table" == _type_1 or "userdata" == _type_1 then -- 766
					workMode = _obj_0.workMode -- 766
				end -- 766
			end -- 766
			if sessionId ~= nil and workMode ~= nil then -- 766
				return AgentSession.setWorkMode(sessionId, workMode) -- 767
			end -- 766
		end -- 766
	end -- 766
	return invalidArguments -- 765
end) -- 765
HttpServer:post("/agent/session/send", function(req) -- 769
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
			local prompt -- 770
			do -- 770
				local _obj_0 = req.body -- 770
				local _type_1 = type(_obj_0) -- 770
				if "table" == _type_1 or "userdata" == _type_1 then -- 770
					prompt = _obj_0.prompt -- 770
				end -- 770
			end -- 770
			if sessionId ~= nil and prompt ~= nil then -- 770
				return AgentSession.sendPrompt(sessionId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 771
			end -- 770
		end -- 770
	end -- 770
	return invalidArguments -- 769
end) -- 769
HttpServer:post("/agent/session/send-local", function(req) -- 773
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
			local localAgentConfigId -- 774
			do -- 774
				local _obj_0 = req.body -- 774
				local _type_1 = type(_obj_0) -- 774
				if "table" == _type_1 or "userdata" == _type_1 then -- 774
					localAgentConfigId = _obj_0.localAgentConfigId -- 774
				end -- 774
			end -- 774
			if sessionId ~= nil and prompt ~= nil and localAgentConfigId ~= nil then -- 774
				return AgentSession.sendLocalPrompt(sessionId, prompt, localAgentConfigId) -- 775
			end -- 774
		end -- 774
	end -- 774
	return invalidArguments -- 773
end) -- 773
HttpServer:post("/agent/session/local/new", function(req) -- 777
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
			if sessionId ~= nil then -- 778
				return AgentLocalAgent.abandonSession(sessionId) -- 779
			end -- 778
		end -- 778
	end -- 778
	return invalidArguments -- 777
end) -- 777
HttpServer:post("/agent/session/local/info", function(req) -- 781
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
				local info = AgentLocalAgent.getSessionInfo(sessionId) -- 783
				return { -- 784
					success = true, -- 784
					info = info -- 784
				} -- 784
			end -- 782
		end -- 782
	end -- 782
	return invalidArguments -- 781
end) -- 781
HttpServer:post("/agent/session/continue", function(req) -- 786
	do -- 787
		local _type_0 = type(req) -- 787
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 787
		if _tab_0 then -- 787
			local sessionId -- 787
			do -- 787
				local _obj_0 = req.body -- 787
				local _type_1 = type(_obj_0) -- 787
				if "table" == _type_1 or "userdata" == _type_1 then -- 787
					sessionId = _obj_0.sessionId -- 787
				end -- 787
			end -- 787
			if sessionId ~= nil then -- 787
				return AgentSession.continuePrompt(sessionId, req.body.disabledAgentTools, req.body.llmConfigId) -- 788
			end -- 787
		end -- 787
	end -- 787
	return invalidArguments -- 786
end) -- 786
HttpServer:post("/agent/session/finish-handoff", function(req) -- 790
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
				return AgentSession.finishSubSessionHandoff(sessionId, req.body.llmConfigId) -- 792
			end -- 791
		end -- 791
	end -- 791
	return invalidArguments -- 790
end) -- 790
HttpServer:post("/agent/session/resend", function(req) -- 794
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
			local messageId -- 795
			do -- 795
				local _obj_0 = req.body -- 795
				local _type_1 = type(_obj_0) -- 795
				if "table" == _type_1 or "userdata" == _type_1 then -- 795
					messageId = _obj_0.messageId -- 795
				end -- 795
			end -- 795
			local prompt -- 795
			do -- 795
				local _obj_0 = req.body -- 795
				local _type_1 = type(_obj_0) -- 795
				if "table" == _type_1 or "userdata" == _type_1 then -- 795
					prompt = _obj_0.prompt -- 795
				end -- 795
			end -- 795
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 795
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 796
			end -- 795
		end -- 795
	end -- 795
	return invalidArguments -- 794
end) -- 794
HttpServer:post("/agent/session/questionnaire/respond", function(req) -- 798
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
			local questionnaireId -- 799
			do -- 799
				local _obj_0 = req.body -- 799
				local _type_1 = type(_obj_0) -- 799
				if "table" == _type_1 or "userdata" == _type_1 then -- 799
					questionnaireId = _obj_0.questionnaireId -- 799
				end -- 799
			end -- 799
			local answers -- 799
			do -- 799
				local _obj_0 = req.body -- 799
				local _type_1 = type(_obj_0) -- 799
				if "table" == _type_1 or "userdata" == _type_1 then -- 799
					answers = _obj_0.answers -- 799
				end -- 799
			end -- 799
			if sessionId ~= nil and questionnaireId ~= nil and answers ~= nil then -- 799
				return AgentSession.respondQuestionnaire(sessionId, questionnaireId, answers, req.body.llmConfigId) -- 800
			end -- 799
		end -- 799
	end -- 799
	return invalidArguments -- 798
end) -- 798
HttpServer:post("/agent/session/questionnaire/cancel", function(req) -- 802
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
			if sessionId ~= nil and questionnaireId ~= nil then -- 803
				return AgentSession.cancelQuestionnaire(sessionId, questionnaireId, req.body.llmConfigId) -- 804
			end -- 803
		end -- 803
	end -- 803
	return invalidArguments -- 802
end) -- 802
HttpServer:post("/agent/task/status", function(req) -- 806
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
			if sessionId ~= nil then -- 807
				local res = AgentSession.getSession(sessionId) -- 808
				if not res.success then -- 809
					return res -- 809
				end -- 809
				local taskId = res.session.currentTaskId -- 810
				local checkpoints -- 811
				if taskId then -- 811
					checkpoints = AgentTools.listCheckpoints(taskId) -- 811
				else -- 811
					checkpoints = { } -- 811
				end -- 811
				return { -- 813
					success = true, -- 813
					session = res.session, -- 814
					relatedSessions = res.relatedSessions, -- 815
					spawnInfo = res.spawnInfo, -- 816
					messages = res.messages, -- 817
					steps = res.steps, -- 818
					checkpoints = checkpoints, -- 819
					pendingQuestionnaire = res.pendingQuestionnaire, -- 820
					hasActivePlan = res.hasActivePlan -- 821
				} -- 812
			end -- 807
		end -- 807
	end -- 807
	return invalidArguments -- 806
end) -- 806
HttpServer:post("/agent/task/running", function() -- 823
	local res = AgentSession.listRunningSessions() -- 824
	if res.success and #res.sessions == 0 then -- 825
		res.sessions = nil -- 826
	end -- 825
	return res -- 827
end) -- 823
HttpServer:post("/agent/task/stop", function(req) -- 829
	do -- 830
		local _type_0 = type(req) -- 830
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 830
		if _tab_0 then -- 830
			local sessionId -- 830
			do -- 830
				local _obj_0 = req.body -- 830
				local _type_1 = type(_obj_0) -- 830
				if "table" == _type_1 or "userdata" == _type_1 then -- 830
					sessionId = _obj_0.sessionId -- 830
				end -- 830
			end -- 830
			if sessionId ~= nil then -- 830
				return AgentSession.stopSessionTask(sessionId) -- 831
			end -- 830
		end -- 830
	end -- 830
	return invalidArguments -- 829
end) -- 829
HttpServer:post("/agent/checkpoint/list", function(req) -- 833
	do -- 834
		local _type_0 = type(req) -- 834
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 834
		if _tab_0 then -- 834
			local taskId -- 834
			do -- 834
				local _obj_0 = req.body -- 834
				local _type_1 = type(_obj_0) -- 834
				if "table" == _type_1 or "userdata" == _type_1 then -- 834
					taskId = _obj_0.taskId -- 834
				end -- 834
			end -- 834
			local sessionId -- 834
			do -- 834
				local _obj_0 = req.body -- 834
				local _type_1 = type(_obj_0) -- 834
				if "table" == _type_1 or "userdata" == _type_1 then -- 834
					sessionId = _obj_0.sessionId -- 834
				end -- 834
			end -- 834
			if sessionId ~= nil then -- 834
				if not taskId and sessionId then -- 835
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 836
				end -- 835
				if not taskId then -- 837
					return { -- 837
						success = false, -- 837
						message = "task not found" -- 837
					} -- 837
				end -- 837
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 838
				if not access.success then -- 839
					return access -- 839
				end -- 839
				return { -- 841
					success = true, -- 841
					taskId = taskId, -- 842
					checkpoints = AgentTools.listCheckpoints(taskId) -- 843
				} -- 840
			end -- 834
		end -- 834
	end -- 834
	return invalidArguments -- 833
end) -- 833
HttpServer:post("/agent/checkpoint/diff", function(req) -- 845
	do -- 846
		local _type_0 = type(req) -- 846
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 846
		if _tab_0 then -- 846
			local sessionId -- 846
			do -- 846
				local _obj_0 = req.body -- 846
				local _type_1 = type(_obj_0) -- 846
				if "table" == _type_1 or "userdata" == _type_1 then -- 846
					sessionId = _obj_0.sessionId -- 846
				end -- 846
			end -- 846
			local checkpointId -- 846
			do -- 846
				local _obj_0 = req.body -- 846
				local _type_1 = type(_obj_0) -- 846
				if "table" == _type_1 or "userdata" == _type_1 then -- 846
					checkpointId = _obj_0.checkpointId -- 846
				end -- 846
			end -- 846
			if sessionId ~= nil and checkpointId ~= nil then -- 846
				if not (checkpointId > 0) then -- 847
					return { -- 847
						success = false, -- 847
						message = "invalid checkpointId" -- 847
					} -- 847
				end -- 847
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 848
				if not access.success then -- 849
					return access -- 849
				end -- 849
				return AgentTools.getCheckpointDiff(checkpointId) -- 850
			end -- 846
		end -- 846
	end -- 846
	return invalidArguments -- 845
end) -- 845
HttpServer:post("/agent/task/diff", function(req) -- 852
	do -- 853
		local _type_0 = type(req) -- 853
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 853
		if _tab_0 then -- 853
			local sessionId -- 853
			do -- 853
				local _obj_0 = req.body -- 853
				local _type_1 = type(_obj_0) -- 853
				if "table" == _type_1 or "userdata" == _type_1 then -- 853
					sessionId = _obj_0.sessionId -- 853
				end -- 853
			end -- 853
			local taskId -- 853
			do -- 853
				local _obj_0 = req.body -- 853
				local _type_1 = type(_obj_0) -- 853
				if "table" == _type_1 or "userdata" == _type_1 then -- 853
					taskId = _obj_0.taskId -- 853
				end -- 853
			end -- 853
			if sessionId ~= nil and taskId ~= nil then -- 853
				if not (taskId > 0) then -- 854
					return { -- 854
						success = false, -- 854
						message = "invalid taskId" -- 854
					} -- 854
				end -- 854
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 855
				if not access.success then -- 856
					return access -- 856
				end -- 856
				return AgentTools.getTaskChangeSetDiff(taskId) -- 857
			end -- 853
		end -- 853
	end -- 853
	return invalidArguments -- 852
end) -- 852
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 859
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
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, access.session.projectRoot) -- 864
				if not rollbackRes.success then -- 865
					return rollbackRes -- 865
				end -- 865
				return { -- 867
					success = true, -- 867
					checkpointId = rollbackRes.checkpointId -- 868
				} -- 866
			end -- 860
		end -- 860
	end -- 860
	return invalidArguments -- 859
end) -- 859
HttpServer:post("/agent/task/rollback", function(req) -- 870
	do -- 871
		local _type_0 = type(req) -- 871
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 871
		if _tab_0 then -- 871
			local sessionId -- 871
			do -- 871
				local _obj_0 = req.body -- 871
				local _type_1 = type(_obj_0) -- 871
				if "table" == _type_1 or "userdata" == _type_1 then -- 871
					sessionId = _obj_0.sessionId -- 871
				end -- 871
			end -- 871
			local taskId -- 871
			do -- 871
				local _obj_0 = req.body -- 871
				local _type_1 = type(_obj_0) -- 871
				if "table" == _type_1 or "userdata" == _type_1 then -- 871
					taskId = _obj_0.taskId -- 871
				end -- 871
			end -- 871
			if sessionId ~= nil and taskId ~= nil then -- 871
				if not (taskId > 0) then -- 872
					return { -- 872
						success = false, -- 872
						message = "invalid taskId" -- 872
					} -- 872
				end -- 872
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 873
				if not access.success then -- 874
					return access -- 874
				end -- 874
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, access.session.projectRoot) -- 875
				if not rollbackRes.success then -- 876
					return rollbackRes -- 876
				end -- 876
				return { -- 878
					success = true, -- 878
					taskId = rollbackRes.taskId, -- 879
					checkpointId = rollbackRes.checkpointId, -- 880
					checkpointCount = rollbackRes.checkpointCount -- 881
				} -- 877
			end -- 871
		end -- 871
	end -- 871
	return invalidArguments -- 870
end) -- 870
local getSearchPath -- 883
getSearchPath = function(file) -- 883
	do -- 884
		local dir = getProjectDirFromFile(file) -- 884
		if dir then -- 884
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 885
		end -- 884
	end -- 884
	return "" -- 883
end -- 883
local getSearchFolders -- 887
getSearchFolders = function(file) -- 887
	do -- 888
		local dir = getProjectDirFromFile(file) -- 888
		if dir then -- 888
			return { -- 890
				Path(dir, "Script"), -- 890
				dir -- 891
			} -- 889
		end -- 888
	end -- 888
	return { } -- 887
end -- 887
local disabledCheckForLua = { -- 894
	"incompatible number of returns", -- 894
	"unknown", -- 895
	"cannot index", -- 896
	"module not found", -- 897
	"don't know how to resolve", -- 898
	"ContainerItem", -- 899
	"cannot resolve a type", -- 900
	"invalid key", -- 901
	"inconsistent index type", -- 902
	"cannot use operator", -- 903
	"attempting ipairs loop", -- 904
	"expects record or nominal", -- 905
	"variable is not being assigned", -- 906
	"<invalid type>", -- 907
	"<any type>", -- 908
	"using the '#' operator", -- 909
	"can't match a record", -- 910
	"redeclaration of variable", -- 911
	"cannot apply pairs", -- 912
	"not a function", -- 913
	"to%-be%-closed" -- 914
} -- 893
local yueCheck -- 916
yueCheck = function(file, content, lax) -- 916
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 917
	if isTIC80 then -- 918
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 919
	end -- 918
	local searchPath = getSearchPath(file) -- 920
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 921
	local info = { } -- 922
	local globals = { } -- 923
	for _index_0 = 1, #checkResult do -- 924
		local _des_0 = checkResult[_index_0] -- 924
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 924
		if "error" == t then -- 925
			info[#info + 1] = { -- 926
				"syntax", -- 926
				file, -- 926
				line, -- 926
				col, -- 926
				msg -- 926
			} -- 926
		elseif "global" == t then -- 927
			globals[#globals + 1] = { -- 928
				msg, -- 928
				line, -- 928
				col -- 928
			} -- 928
		end -- 925
	end -- 924
	if luaCodes then -- 929
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 930
		if success then -- 931
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 932
			if not (lintResult == "") then -- 933
				lintResult = lintResult .. "\n" -- 933
			end -- 933
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 934
		else -- 935
			for _index_0 = 1, #lintResult do -- 935
				local _des_0 = lintResult[_index_0] -- 935
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 935
				if isTIC80 and tic80APIs[name] then -- 936
					goto _continue_0 -- 936
				end -- 936
				info[#info + 1] = { -- 937
					"syntax", -- 937
					file, -- 937
					line, -- 937
					col, -- 937
					"invalid global variable" -- 937
				} -- 937
				::_continue_0:: -- 936
			end -- 935
		end -- 931
	end -- 929
	return luaCodes, info -- 938
end -- 916
local luaCheck -- 940
luaCheck = function(file, content) -- 940
	local res, err = load(content, "check") -- 941
	if not res then -- 942
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 943
		return { -- 944
			success = false, -- 944
			info = { -- 944
				{ -- 944
					"syntax", -- 944
					file, -- 944
					tonumber(line), -- 944
					0, -- 944
					msg -- 944
				} -- 944
			} -- 944
		} -- 944
	end -- 942
	local success, info = teal.checkAsync(content, file, true, "") -- 945
	if info then -- 946
		do -- 947
			local _accum_0 = { } -- 947
			local _len_0 = 1 -- 947
			for _index_0 = 1, #info do -- 947
				local item = info[_index_0] -- 947
				local useCheck = true -- 948
				if not item[5]:match("unused") then -- 949
					for _index_1 = 1, #disabledCheckForLua do -- 950
						local check = disabledCheckForLua[_index_1] -- 950
						if item[5]:match(check) then -- 951
							useCheck = false -- 952
						end -- 951
					end -- 950
				end -- 949
				if not useCheck then -- 953
					goto _continue_0 -- 953
				end -- 953
				do -- 954
					local _exp_0 = item[1] -- 954
					if "type" == _exp_0 then -- 955
						item[1] = "warning" -- 956
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 957
						goto _continue_0 -- 958
					end -- 954
				end -- 954
				_accum_0[_len_0] = item -- 959
				_len_0 = _len_0 + 1 -- 948
				::_continue_0:: -- 948
			end -- 947
			info = _accum_0 -- 947
		end -- 947
		if #info == 0 then -- 960
			info = nil -- 961
			success = true -- 962
		end -- 960
	end -- 946
	return { -- 963
		success = success, -- 963
		info = info -- 963
	} -- 963
end -- 940
local luaCheckWithLineInfo -- 965
luaCheckWithLineInfo = function(file, luaCodes) -- 965
	local res = luaCheck(file, luaCodes) -- 966
	local info = { } -- 967
	if not res.success then -- 968
		local current = 1 -- 969
		local lastLine = 1 -- 970
		local lineMap = { } -- 971
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 972
			local num = lineCode:match("--%s*(%d+)%s*$") -- 973
			if num then -- 974
				lastLine = tonumber(num) -- 975
			end -- 974
			lineMap[current] = lastLine -- 976
			current = current + 1 -- 977
		end -- 972
		local _list_0 = res.info -- 978
		for _index_0 = 1, #_list_0 do -- 978
			local item = _list_0[_index_0] -- 978
			item[3] = lineMap[item[3]] or 0 -- 979
			item[4] = 0 -- 980
			info[#info + 1] = item -- 981
		end -- 978
		return false, info -- 982
	end -- 968
	return true, info -- 983
end -- 965
local getCompiledYueLine -- 985
getCompiledYueLine = function(content, line, row, file, lax) -- 985
	local luaCodes = yueCheck(file, content, lax) -- 986
	if not luaCodes then -- 987
		return nil -- 987
	end -- 987
	local current = 1 -- 988
	local lastLine = 1 -- 989
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 990
	local targetRow = nil -- 991
	local lineMap = { } -- 992
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 993
		local num = lineCode:match("--%s*(%d+)%s*$") -- 994
		if num then -- 995
			lastLine = tonumber(num) -- 995
		end -- 995
		lineMap[current] = lastLine -- 996
		if row <= lastLine and not targetRow then -- 997
			targetRow = current -- 998
			break -- 999
		end -- 997
		current = current + 1 -- 1000
	end -- 993
	targetRow = current -- 1001
	if targetLine and targetRow then -- 1002
		return luaCodes, targetLine, targetRow, lineMap -- 1003
	else -- 1005
		return nil -- 1005
	end -- 1002
end -- 985
HttpServer:postSchedule("/check", function(req) -- 1007
	do -- 1008
		local _type_0 = type(req) -- 1008
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1008
		if _tab_0 then -- 1008
			local file -- 1008
			do -- 1008
				local _obj_0 = req.body -- 1008
				local _type_1 = type(_obj_0) -- 1008
				if "table" == _type_1 or "userdata" == _type_1 then -- 1008
					file = _obj_0.file -- 1008
				end -- 1008
			end -- 1008
			local content -- 1008
			do -- 1008
				local _obj_0 = req.body -- 1008
				local _type_1 = type(_obj_0) -- 1008
				if "table" == _type_1 or "userdata" == _type_1 then -- 1008
					content = _obj_0.content -- 1008
				end -- 1008
			end -- 1008
			if file ~= nil and content ~= nil then -- 1008
				local ext = Path:getExt(file) -- 1009
				if "tl" == ext then -- 1010
					local searchPath = getSearchPath(file) -- 1011
					do -- 1012
						local isTIC80 = CheckTIC80Code(content) -- 1012
						if isTIC80 then -- 1012
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1013
						end -- 1012
					end -- 1012
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 1014
					return { -- 1015
						success = success, -- 1015
						info = info -- 1015
					} -- 1015
				elseif "lua" == ext then -- 1016
					do -- 1017
						local isTIC80 = CheckTIC80Code(content) -- 1017
						if isTIC80 then -- 1017
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1018
						end -- 1017
					end -- 1017
					return luaCheck(file, content) -- 1019
				elseif "yue" == ext then -- 1020
					local luaCodes, info = yueCheck(file, content, false) -- 1021
					local success = luaCodes ~= nil -- 1022
					if luaCodes then -- 1023
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 1024
						do -- 1025
							local _tab_1 = { } -- 1025
							local _idx_0 = #_tab_1 + 1 -- 1025
							for _index_0 = 1, #info do -- 1025
								local _value_0 = info[_index_0] -- 1025
								_tab_1[_idx_0] = _value_0 -- 1025
								_idx_0 = _idx_0 + 1 -- 1025
							end -- 1025
							local _idx_1 = #_tab_1 + 1 -- 1025
							for _index_0 = 1, #luaInfo do -- 1025
								local _value_0 = luaInfo[_index_0] -- 1025
								_tab_1[_idx_1] = _value_0 -- 1025
								_idx_1 = _idx_1 + 1 -- 1025
							end -- 1025
							info = _tab_1 -- 1025
						end -- 1025
						success = success and luaSuccess -- 1026
					end -- 1023
					if #info > 0 then -- 1027
						return { -- 1028
							success = success, -- 1028
							info = info -- 1028
						} -- 1028
					else -- 1030
						return { -- 1030
							success = success -- 1030
						} -- 1030
					end -- 1027
				elseif "xml" == ext then -- 1031
					local success, result = xml.check(content) -- 1032
					if success then -- 1033
						local info -- 1034
						success, info = luaCheckWithLineInfo(file, result) -- 1034
						if #info > 0 then -- 1035
							return { -- 1036
								success = success, -- 1036
								info = info -- 1036
							} -- 1036
						else -- 1038
							return { -- 1038
								success = success -- 1038
							} -- 1038
						end -- 1035
					else -- 1040
						local info -- 1040
						do -- 1040
							local _accum_0 = { } -- 1040
							local _len_0 = 1 -- 1040
							for _index_0 = 1, #result do -- 1040
								local _des_0 = result[_index_0] -- 1040
								local row, err = _des_0[1], _des_0[2] -- 1040
								_accum_0[_len_0] = { -- 1041
									"syntax", -- 1041
									file, -- 1041
									row, -- 1041
									0, -- 1041
									err -- 1041
								} -- 1041
								_len_0 = _len_0 + 1 -- 1041
							end -- 1040
							info = _accum_0 -- 1040
						end -- 1040
						return { -- 1042
							success = false, -- 1042
							info = info -- 1042
						} -- 1042
					end -- 1033
				end -- 1010
			end -- 1008
		end -- 1008
	end -- 1008
	return { -- 1007
		success = true -- 1007
	} -- 1007
end) -- 1007
HttpServer:post("/body/parse", function(req) -- 1044
	do -- 1045
		local _type_0 = type(req) -- 1045
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1045
		if _tab_0 then -- 1045
			local file -- 1045
			do -- 1045
				local _obj_0 = req.body -- 1045
				local _type_1 = type(_obj_0) -- 1045
				if "table" == _type_1 or "userdata" == _type_1 then -- 1045
					file = _obj_0.file -- 1045
				end -- 1045
			end -- 1045
			local content -- 1045
			do -- 1045
				local _obj_0 = req.body -- 1045
				local _type_1 = type(_obj_0) -- 1045
				if "table" == _type_1 or "userdata" == _type_1 then -- 1045
					content = _obj_0.content -- 1045
				end -- 1045
			end -- 1045
			if file ~= nil and content ~= nil then -- 1045
				if not (file:sub(-6) == ".b.lua") then -- 1046
					return { -- 1047
						success = false, -- 1047
						phase = "request", -- 1047
						message = "only .b.lua files can be converted" -- 1047
					} -- 1047
				end -- 1046
				local loader, err = load("_ENV = {}\n" .. content) -- 1048
				if not loader then -- 1049
					return { -- 1050
						success = false, -- 1050
						phase = "parse", -- 1050
						message = tostring(err) -- 1050
					} -- 1050
				end -- 1049
				local ok, data = pcall(loader) -- 1051
				if not ok then -- 1052
					return { -- 1053
						success = false, -- 1053
						phase = "execute", -- 1053
						message = tostring(data) -- 1053
					} -- 1053
				end -- 1052
				if not ("table" == type(data) and data[1] == "Array") then -- 1054
					return { -- 1055
						success = false, -- 1055
						phase = "validate", -- 1055
						message = "body lua root must be {\"Array\", ...}" -- 1055
					} -- 1055
				end -- 1054
				local text, jsonErr = json.encode(data, false, true) -- 1056
				if not text then -- 1057
					return { -- 1058
						success = false, -- 1058
						phase = "encode", -- 1058
						message = tostring(jsonErr) -- 1058
					} -- 1058
				end -- 1057
				return { -- 1059
					success = true, -- 1059
					json = text -- 1059
				} -- 1059
			end -- 1045
		end -- 1045
	end -- 1045
	return { -- 1044
		success = false, -- 1044
		phase = "request", -- 1044
		message = "invalid request" -- 1044
	} -- 1044
end) -- 1044
local updateInferedDesc -- 1061
updateInferedDesc = function(infered) -- 1061
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1062
		return -- 1062
	end -- 1062
	local key, row = infered.key, infered.row -- 1063
	local codes = Content:loadAsync(key) -- 1064
	if codes then -- 1064
		local comments = { } -- 1065
		local line = 0 -- 1066
		local skipping = false -- 1067
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1068
			line = line + 1 -- 1069
			if line >= row then -- 1070
				break -- 1070
			end -- 1070
			if lineCode:match("^%s*%-%- @") then -- 1071
				skipping = true -- 1072
				goto _continue_0 -- 1073
			end -- 1071
			local result = lineCode:match("^%s*%-%- (.+)") -- 1074
			if result then -- 1074
				if not skipping then -- 1075
					comments[#comments + 1] = result -- 1075
				end -- 1075
			elseif #comments > 0 then -- 1076
				comments = { } -- 1077
				skipping = false -- 1078
			end -- 1074
			::_continue_0:: -- 1069
		end -- 1068
		infered.doc = table.concat(comments, "\n") -- 1079
	end -- 1064
end -- 1061
HttpServer:postSchedule("/infer", function(req) -- 1081
	do -- 1082
		local _type_0 = type(req) -- 1082
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1082
		if _tab_0 then -- 1082
			local lang -- 1082
			do -- 1082
				local _obj_0 = req.body -- 1082
				local _type_1 = type(_obj_0) -- 1082
				if "table" == _type_1 or "userdata" == _type_1 then -- 1082
					lang = _obj_0.lang -- 1082
				end -- 1082
			end -- 1082
			local file -- 1082
			do -- 1082
				local _obj_0 = req.body -- 1082
				local _type_1 = type(_obj_0) -- 1082
				if "table" == _type_1 or "userdata" == _type_1 then -- 1082
					file = _obj_0.file -- 1082
				end -- 1082
			end -- 1082
			local content -- 1082
			do -- 1082
				local _obj_0 = req.body -- 1082
				local _type_1 = type(_obj_0) -- 1082
				if "table" == _type_1 or "userdata" == _type_1 then -- 1082
					content = _obj_0.content -- 1082
				end -- 1082
			end -- 1082
			local line -- 1082
			do -- 1082
				local _obj_0 = req.body -- 1082
				local _type_1 = type(_obj_0) -- 1082
				if "table" == _type_1 or "userdata" == _type_1 then -- 1082
					line = _obj_0.line -- 1082
				end -- 1082
			end -- 1082
			local row -- 1082
			do -- 1082
				local _obj_0 = req.body -- 1082
				local _type_1 = type(_obj_0) -- 1082
				if "table" == _type_1 or "userdata" == _type_1 then -- 1082
					row = _obj_0.row -- 1082
				end -- 1082
			end -- 1082
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1082
				local searchPath = getSearchPath(file) -- 1083
				if "tl" == lang or "lua" == lang then -- 1084
					if CheckTIC80Code(content) then -- 1085
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1086
					end -- 1085
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1087
					if (infered ~= nil) then -- 1088
						updateInferedDesc(infered) -- 1089
						return { -- 1090
							success = true, -- 1090
							infered = infered -- 1090
						} -- 1090
					end -- 1088
				elseif "yue" == lang then -- 1091
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1092
					if not luaCodes then -- 1093
						return { -- 1093
							success = false -- 1093
						} -- 1093
					end -- 1093
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1094
					if (infered ~= nil) then -- 1095
						local col -- 1096
						file, row, col = infered.file, infered.row, infered.col -- 1096
						if file == "" and row > 0 and col > 0 then -- 1097
							infered.row = lineMap[row] or 0 -- 1098
							infered.col = 0 -- 1099
						end -- 1097
						updateInferedDesc(infered) -- 1100
						return { -- 1101
							success = true, -- 1101
							infered = infered -- 1101
						} -- 1101
					end -- 1095
				end -- 1084
			end -- 1082
		end -- 1082
	end -- 1082
	return { -- 1081
		success = false -- 1081
	} -- 1081
end) -- 1081
local _anon_func_3 = function(doc) -- 1162
	local _accum_0 = { } -- 1162
	local _len_0 = 1 -- 1162
	local _list_0 = doc.params -- 1162
	for _index_0 = 1, #_list_0 do -- 1162
		local param = _list_0[_index_0] -- 1162
		_accum_0[_len_0] = param.name -- 1162
		_len_0 = _len_0 + 1 -- 1162
	end -- 1162
	return _accum_0 -- 1162
end -- 1162
local getParamDocs -- 1103
getParamDocs = function(signatures) -- 1103
	if not (signatures and #signatures > 0) then -- 1104
		return nil -- 1104
	end -- 1104
	local docs = { } -- 1105
	do -- 1106
		local codes = Content:loadAsync(signatures[1].file) -- 1106
		if codes then -- 1106
			local comments = { } -- 1107
			local params = { } -- 1108
			local line = 0 -- 1109
			local returnType = nil -- 1110
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1111
				line = line + 1 -- 1112
				local needBreak = true -- 1113
				for i, _des_0 in ipairs(signatures) do -- 1114
					local row = _des_0.row -- 1114
					if line >= row and not (docs[i] ~= nil) then -- 1115
						if #comments > 0 or #params > 0 or returnType then -- 1116
							docs[i] = { -- 1118
								doc = table.concat(comments, "  \n"), -- 1118
								returnType = returnType -- 1119
							} -- 1117
							if #params > 0 then -- 1121
								docs[i].params = params -- 1121
							end -- 1121
						else -- 1123
							docs[i] = false -- 1123
						end -- 1116
					end -- 1115
					if not docs[i] then -- 1124
						needBreak = false -- 1124
					end -- 1124
				end -- 1114
				if needBreak then -- 1125
					break -- 1125
				end -- 1125
				local result = lineCode:match("%s*%-%- (.+)") -- 1126
				if result then -- 1126
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1127
					if not name then -- 1128
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1129
					end -- 1128
					if name then -- 1130
						local pname = name -- 1131
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1132
							pname = pname .. "?" -- 1132
						end -- 1132
						params[#params + 1] = { -- 1134
							name = tostring(pname) .. ": " .. tostring(typ), -- 1134
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1135
						} -- 1133
					else -- 1138
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1138
						if typ then -- 1138
							if returnType then -- 1139
								returnType = returnType .. ", " .. typ -- 1140
							else -- 1142
								returnType = typ -- 1142
							end -- 1139
							result = result:gsub("@return", "**return:**") -- 1143
						end -- 1138
						comments[#comments + 1] = result -- 1144
					end -- 1130
				elseif #comments > 0 then -- 1145
					comments = { } -- 1146
					params = { } -- 1147
					returnType = nil -- 1148
				end -- 1126
			end -- 1111
		end -- 1106
	end -- 1106
	local results = { } -- 1149
	for i, signature in ipairs(signatures) do -- 1150
		local item = { -- 1152
			desc = signature.desc, -- 1152
			doc = "", -- 1153
			file = signature.file, -- 1154
			row = signature.row, -- 1155
			col = signature.col -- 1156
		} -- 1151
		do -- 1158
			local doc = docs[i] -- 1158
			if doc then -- 1158
				item.doc = doc.doc -- 1159
				if doc.params then -- 1160
					item.params = doc.params -- 1161
					item.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1162
				elseif doc.returnType then -- 1163
					item.desc = "function()" -- 1164
				end -- 1160
				if doc.returnType then -- 1165
					item.desc = item.desc .. ": " .. tostring(doc.returnType) -- 1165
				end -- 1165
			end -- 1158
		end -- 1158
		results[#results + 1] = item -- 1166
	end -- 1150
	return results -- 1167
end -- 1103
HttpServer:postSchedule("/signature", function(req) -- 1169
	do -- 1170
		local _type_0 = type(req) -- 1170
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1170
		if _tab_0 then -- 1170
			local lang -- 1170
			do -- 1170
				local _obj_0 = req.body -- 1170
				local _type_1 = type(_obj_0) -- 1170
				if "table" == _type_1 or "userdata" == _type_1 then -- 1170
					lang = _obj_0.lang -- 1170
				end -- 1170
			end -- 1170
			local file -- 1170
			do -- 1170
				local _obj_0 = req.body -- 1170
				local _type_1 = type(_obj_0) -- 1170
				if "table" == _type_1 or "userdata" == _type_1 then -- 1170
					file = _obj_0.file -- 1170
				end -- 1170
			end -- 1170
			local content -- 1170
			do -- 1170
				local _obj_0 = req.body -- 1170
				local _type_1 = type(_obj_0) -- 1170
				if "table" == _type_1 or "userdata" == _type_1 then -- 1170
					content = _obj_0.content -- 1170
				end -- 1170
			end -- 1170
			local line -- 1170
			do -- 1170
				local _obj_0 = req.body -- 1170
				local _type_1 = type(_obj_0) -- 1170
				if "table" == _type_1 or "userdata" == _type_1 then -- 1170
					line = _obj_0.line -- 1170
				end -- 1170
			end -- 1170
			local row -- 1170
			do -- 1170
				local _obj_0 = req.body -- 1170
				local _type_1 = type(_obj_0) -- 1170
				if "table" == _type_1 or "userdata" == _type_1 then -- 1170
					row = _obj_0.row -- 1170
				end -- 1170
			end -- 1170
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1170
				local searchPath = getSearchPath(file) -- 1171
				if "tl" == lang or "lua" == lang then -- 1172
					if CheckTIC80Code(content) then -- 1173
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1174
					end -- 1173
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1175
					if signatures then -- 1175
						signatures = getParamDocs(signatures) -- 1176
						if signatures then -- 1176
							return { -- 1177
								success = true, -- 1177
								signatures = signatures -- 1177
							} -- 1177
						end -- 1176
					end -- 1175
				elseif "yue" == lang then -- 1178
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1179
					if not luaCodes then -- 1180
						return { -- 1180
							success = false -- 1180
						} -- 1180
					end -- 1180
					do -- 1181
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1181
						if chainOp then -- 1181
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1182
							if withVar then -- 1182
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1183
							end -- 1182
						end -- 1181
					end -- 1181
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1184
					if signatures then -- 1184
						signatures = getParamDocs(signatures) -- 1185
						if signatures then -- 1185
							return { -- 1186
								success = true, -- 1186
								signatures = signatures -- 1186
							} -- 1186
						end -- 1185
					else -- 1187
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1187
						if signatures then -- 1187
							signatures = getParamDocs(signatures) -- 1188
							if signatures then -- 1188
								return { -- 1189
									success = true, -- 1189
									signatures = signatures -- 1189
								} -- 1189
							end -- 1188
						end -- 1187
					end -- 1184
				end -- 1172
			end -- 1170
		end -- 1170
	end -- 1170
	return { -- 1169
		success = false -- 1169
	} -- 1169
end) -- 1169
local luaKeywords = { -- 1192
	'and', -- 1192
	'break', -- 1193
	'do', -- 1194
	'else', -- 1195
	'elseif', -- 1196
	'end', -- 1197
	'false', -- 1198
	'for', -- 1199
	'function', -- 1200
	'goto', -- 1201
	'if', -- 1202
	'in', -- 1203
	'local', -- 1204
	'nil', -- 1205
	'not', -- 1206
	'or', -- 1207
	'repeat', -- 1208
	'return', -- 1209
	'then', -- 1210
	'true', -- 1211
	'until', -- 1212
	'while' -- 1213
} -- 1191
local tealKeywords = { -- 1217
	'record', -- 1217
	'as', -- 1218
	'is', -- 1219
	'type', -- 1220
	'embed', -- 1221
	'enum', -- 1222
	'global', -- 1223
	'any', -- 1224
	'boolean', -- 1225
	'integer', -- 1226
	'number', -- 1227
	'string', -- 1228
	'thread' -- 1229
} -- 1216
local yueKeywords = { -- 1233
	"and", -- 1233
	"break", -- 1234
	"do", -- 1235
	"else", -- 1236
	"elseif", -- 1237
	"false", -- 1238
	"for", -- 1239
	"goto", -- 1240
	"if", -- 1241
	"in", -- 1242
	"local", -- 1243
	"nil", -- 1244
	"not", -- 1245
	"or", -- 1246
	"repeat", -- 1247
	"return", -- 1248
	"then", -- 1249
	"true", -- 1250
	"until", -- 1251
	"while", -- 1252
	"as", -- 1253
	"class", -- 1254
	"continue", -- 1255
	"export", -- 1256
	"extends", -- 1257
	"from", -- 1258
	"global", -- 1259
	"import", -- 1260
	"macro", -- 1261
	"switch", -- 1262
	"try", -- 1263
	"unless", -- 1264
	"using", -- 1265
	"when", -- 1266
	"with" -- 1267
} -- 1232
local _anon_func_4 = function(f) -- 1303
	local _val_0 = Path:getExt(f) -- 1303
	return "ttf" == _val_0 or "otf" == _val_0 -- 1303
end -- 1303
local _anon_func_5 = function(suggestions) -- 1329
	local _tbl_0 = { } -- 1329
	for _index_0 = 1, #suggestions do -- 1329
		local item = suggestions[_index_0] -- 1329
		_tbl_0[item[1] .. item[2]] = item -- 1329
	end -- 1329
	return _tbl_0 -- 1329
end -- 1329
HttpServer:postSchedule("/complete", function(req) -- 1270
	do -- 1271
		local _type_0 = type(req) -- 1271
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1271
		if _tab_0 then -- 1271
			local lang -- 1271
			do -- 1271
				local _obj_0 = req.body -- 1271
				local _type_1 = type(_obj_0) -- 1271
				if "table" == _type_1 or "userdata" == _type_1 then -- 1271
					lang = _obj_0.lang -- 1271
				end -- 1271
			end -- 1271
			local file -- 1271
			do -- 1271
				local _obj_0 = req.body -- 1271
				local _type_1 = type(_obj_0) -- 1271
				if "table" == _type_1 or "userdata" == _type_1 then -- 1271
					file = _obj_0.file -- 1271
				end -- 1271
			end -- 1271
			local content -- 1271
			do -- 1271
				local _obj_0 = req.body -- 1271
				local _type_1 = type(_obj_0) -- 1271
				if "table" == _type_1 or "userdata" == _type_1 then -- 1271
					content = _obj_0.content -- 1271
				end -- 1271
			end -- 1271
			local line -- 1271
			do -- 1271
				local _obj_0 = req.body -- 1271
				local _type_1 = type(_obj_0) -- 1271
				if "table" == _type_1 or "userdata" == _type_1 then -- 1271
					line = _obj_0.line -- 1271
				end -- 1271
			end -- 1271
			local row -- 1271
			do -- 1271
				local _obj_0 = req.body -- 1271
				local _type_1 = type(_obj_0) -- 1271
				if "table" == _type_1 or "userdata" == _type_1 then -- 1271
					row = _obj_0.row -- 1271
				end -- 1271
			end -- 1271
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1271
				local searchPath = getSearchPath(file) -- 1272
				repeat -- 1273
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1274
					if lang == "yue" then -- 1275
						if not item then -- 1276
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1276
						end -- 1276
						if not item then -- 1277
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1277
						end -- 1277
					end -- 1275
					local searchType = nil -- 1278
					if not item then -- 1279
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1280
						if lang == "yue" then -- 1281
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1282
						end -- 1281
						if (item ~= nil) then -- 1283
							searchType = "Image" -- 1283
						end -- 1283
					end -- 1279
					if not item then -- 1284
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1285
						if lang == "yue" then -- 1286
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1287
						end -- 1286
						if (item ~= nil) then -- 1288
							searchType = "Font" -- 1288
						end -- 1288
					end -- 1284
					if not item then -- 1289
						break -- 1289
					end -- 1289
					local searchPaths = Content.searchPaths -- 1290
					local _list_0 = getSearchFolders(file) -- 1291
					for _index_0 = 1, #_list_0 do -- 1291
						local folder = _list_0[_index_0] -- 1291
						searchPaths[#searchPaths + 1] = folder -- 1292
					end -- 1291
					if searchType then -- 1293
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1293
					end -- 1293
					local tokens -- 1294
					do -- 1294
						local _accum_0 = { } -- 1294
						local _len_0 = 1 -- 1294
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1294
							_accum_0[_len_0] = mod -- 1294
							_len_0 = _len_0 + 1 -- 1294
						end -- 1294
						tokens = _accum_0 -- 1294
					end -- 1294
					local suggestions = { } -- 1295
					for _index_0 = 1, #searchPaths do -- 1296
						local path = searchPaths[_index_0] -- 1296
						local sPath = Path(path, table.unpack(tokens)) -- 1297
						if not Content:exist(sPath) then -- 1298
							goto _continue_0 -- 1298
						end -- 1298
						if searchType == "Font" then -- 1299
							local fontPath = Path(sPath, "Font") -- 1300
							if Content:exist(fontPath) then -- 1301
								local _list_1 = Content:getFiles(fontPath) -- 1302
								for _index_1 = 1, #_list_1 do -- 1302
									local f = _list_1[_index_1] -- 1302
									if _anon_func_4(f) then -- 1303
										if "." == f:sub(1, 1) then -- 1304
											goto _continue_1 -- 1304
										end -- 1304
										suggestions[#suggestions + 1] = { -- 1305
											Path:getName(f), -- 1305
											"font", -- 1305
											"field" -- 1305
										} -- 1305
									end -- 1303
									::_continue_1:: -- 1303
								end -- 1302
							end -- 1301
						end -- 1299
						local _list_1 = Content:getFiles(sPath) -- 1306
						for _index_1 = 1, #_list_1 do -- 1306
							local f = _list_1[_index_1] -- 1306
							if "Image" == searchType then -- 1307
								do -- 1308
									local _exp_0 = Path:getExt(f) -- 1308
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1308
										if "." == f:sub(1, 1) then -- 1309
											goto _continue_2 -- 1309
										end -- 1309
										suggestions[#suggestions + 1] = { -- 1310
											f, -- 1310
											"image", -- 1310
											"field" -- 1310
										} -- 1310
									end -- 1308
								end -- 1308
								goto _continue_2 -- 1311
							elseif "Font" == searchType then -- 1312
								do -- 1313
									local _exp_0 = Path:getExt(f) -- 1313
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1313
										if "." == f:sub(1, 1) then -- 1314
											goto _continue_2 -- 1314
										end -- 1314
										suggestions[#suggestions + 1] = { -- 1315
											f, -- 1315
											"font", -- 1315
											"field" -- 1315
										} -- 1315
									end -- 1313
								end -- 1313
								goto _continue_2 -- 1316
							end -- 1307
							local _exp_0 = Path:getExt(f) -- 1317
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1317
								local name = Path:getName(f) -- 1318
								if "d" == Path:getExt(name) then -- 1319
									goto _continue_2 -- 1319
								end -- 1319
								if "." == name:sub(1, 1) then -- 1320
									goto _continue_2 -- 1320
								end -- 1320
								suggestions[#suggestions + 1] = { -- 1321
									name, -- 1321
									"module", -- 1321
									"field" -- 1321
								} -- 1321
							end -- 1317
							::_continue_2:: -- 1307
						end -- 1306
						local _list_2 = Content:getDirs(sPath) -- 1322
						for _index_1 = 1, #_list_2 do -- 1322
							local dir = _list_2[_index_1] -- 1322
							if "." == dir:sub(1, 1) then -- 1323
								goto _continue_3 -- 1323
							end -- 1323
							suggestions[#suggestions + 1] = { -- 1324
								dir, -- 1324
								"folder", -- 1324
								"variable" -- 1324
							} -- 1324
							::_continue_3:: -- 1323
						end -- 1322
						::_continue_0:: -- 1297
					end -- 1296
					if item == "" and not searchType then -- 1325
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1326
						for _index_0 = 1, #_list_1 do -- 1326
							local _des_0 = _list_1[_index_0] -- 1326
							local name = _des_0[1] -- 1326
							suggestions[#suggestions + 1] = { -- 1327
								name, -- 1327
								"dora module", -- 1327
								"function" -- 1327
							} -- 1327
						end -- 1326
					end -- 1325
					if #suggestions > 0 then -- 1328
						do -- 1329
							local _accum_0 = { } -- 1329
							local _len_0 = 1 -- 1329
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1329
								_accum_0[_len_0] = v -- 1329
								_len_0 = _len_0 + 1 -- 1329
							end -- 1329
							suggestions = _accum_0 -- 1329
						end -- 1329
						return { -- 1330
							success = true, -- 1330
							suggestions = suggestions -- 1330
						} -- 1330
					else -- 1332
						return { -- 1332
							success = false -- 1332
						} -- 1332
					end -- 1328
				until true -- 1273
				if "tl" == lang or "lua" == lang then -- 1334
					do -- 1335
						local isTIC80 = CheckTIC80Code(content) -- 1335
						if isTIC80 then -- 1335
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1336
						end -- 1335
					end -- 1335
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1337
					if not line:match("[%.:]$") then -- 1338
						local checkSet -- 1339
						do -- 1339
							local _tbl_0 = { } -- 1339
							for _index_0 = 1, #suggestions do -- 1339
								local _des_0 = suggestions[_index_0] -- 1339
								local name = _des_0[1] -- 1339
								_tbl_0[name] = true -- 1339
							end -- 1339
							checkSet = _tbl_0 -- 1339
						end -- 1339
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1340
						for _index_0 = 1, #_list_0 do -- 1340
							local item = _list_0[_index_0] -- 1340
							if not checkSet[item[1]] then -- 1341
								suggestions[#suggestions + 1] = item -- 1341
							end -- 1341
						end -- 1340
						for _index_0 = 1, #luaKeywords do -- 1342
							local word = luaKeywords[_index_0] -- 1342
							suggestions[#suggestions + 1] = { -- 1343
								word, -- 1343
								"keyword", -- 1343
								"keyword" -- 1343
							} -- 1343
						end -- 1342
						if lang == "tl" then -- 1344
							for _index_0 = 1, #tealKeywords do -- 1345
								local word = tealKeywords[_index_0] -- 1345
								suggestions[#suggestions + 1] = { -- 1346
									word, -- 1346
									"keyword", -- 1346
									"keyword" -- 1346
								} -- 1346
							end -- 1345
						end -- 1344
					end -- 1338
					if #suggestions > 0 then -- 1347
						return { -- 1348
							success = true, -- 1348
							suggestions = suggestions -- 1348
						} -- 1348
					end -- 1347
				elseif "yue" == lang then -- 1349
					local suggestions = { } -- 1350
					local gotGlobals = false -- 1351
					do -- 1352
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1352
						if luaCodes then -- 1352
							gotGlobals = true -- 1353
							do -- 1354
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1354
								if chainOp then -- 1354
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1355
									if not withVar then -- 1356
										return { -- 1356
											success = false -- 1356
										} -- 1356
									end -- 1356
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1357
								elseif line:match("^([%.\\])$") then -- 1358
									return { -- 1359
										success = false -- 1359
									} -- 1359
								end -- 1354
							end -- 1354
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1360
							for _index_0 = 1, #_list_0 do -- 1360
								local item = _list_0[_index_0] -- 1360
								suggestions[#suggestions + 1] = item -- 1360
							end -- 1360
							if #suggestions == 0 then -- 1361
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1362
								for _index_0 = 1, #_list_1 do -- 1362
									local item = _list_1[_index_0] -- 1362
									suggestions[#suggestions + 1] = item -- 1362
								end -- 1362
							end -- 1361
						end -- 1352
					end -- 1352
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1363
						local checkSet -- 1364
						do -- 1364
							local _tbl_0 = { } -- 1364
							for _index_0 = 1, #suggestions do -- 1364
								local _des_0 = suggestions[_index_0] -- 1364
								local name = _des_0[1] -- 1364
								_tbl_0[name] = true -- 1364
							end -- 1364
							checkSet = _tbl_0 -- 1364
						end -- 1364
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1365
						for _index_0 = 1, #_list_0 do -- 1365
							local item = _list_0[_index_0] -- 1365
							if not checkSet[item[1]] then -- 1366
								suggestions[#suggestions + 1] = item -- 1366
							end -- 1366
						end -- 1365
						if not gotGlobals then -- 1367
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1368
							for _index_0 = 1, #_list_1 do -- 1368
								local item = _list_1[_index_0] -- 1368
								if not checkSet[item[1]] then -- 1369
									suggestions[#suggestions + 1] = item -- 1369
								end -- 1369
							end -- 1368
						end -- 1367
						for _index_0 = 1, #yueKeywords do -- 1370
							local word = yueKeywords[_index_0] -- 1370
							if not checkSet[word] then -- 1371
								suggestions[#suggestions + 1] = { -- 1372
									word, -- 1372
									"keyword", -- 1372
									"keyword" -- 1372
								} -- 1372
							end -- 1371
						end -- 1370
					end -- 1363
					if #suggestions > 0 then -- 1373
						return { -- 1374
							success = true, -- 1374
							suggestions = suggestions -- 1374
						} -- 1374
					end -- 1373
				elseif "xml" == lang then -- 1375
					local items = xml.complete(content) -- 1376
					if #items > 0 then -- 1377
						local suggestions -- 1378
						do -- 1378
							local _accum_0 = { } -- 1378
							local _len_0 = 1 -- 1378
							for _index_0 = 1, #items do -- 1378
								local _des_0 = items[_index_0] -- 1378
								local label, insertText = _des_0[1], _des_0[2] -- 1378
								_accum_0[_len_0] = { -- 1379
									label, -- 1379
									insertText, -- 1379
									"field" -- 1379
								} -- 1379
								_len_0 = _len_0 + 1 -- 1379
							end -- 1378
							suggestions = _accum_0 -- 1378
						end -- 1378
						return { -- 1380
							success = true, -- 1380
							suggestions = suggestions -- 1380
						} -- 1380
					end -- 1377
				end -- 1334
			end -- 1271
		end -- 1271
	end -- 1271
	return { -- 1270
		success = false -- 1270
	} -- 1270
end) -- 1270
local getUploadFilename -- 1382
getUploadFilename = function(req, multipartFilename) -- 1382
	local filename = req.params.name -- 1383
	if not (type(filename) == "string" and filename ~= "") then -- 1384
		filename = multipartFilename -- 1384
	end -- 1384
	if not (type(filename) == "string" and filename ~= "") then -- 1385
		return -- 1385
	end -- 1385
	if filename:sub(1, 1) == "/" or filename:sub(-1) == "/" or filename:find("//", 1, true) or filename:find("\\", 1, true) or filename:find(":", 1, true) or filename:find("\0", 1, true) then -- 1388
		return -- 1388
	end -- 1388
	local parts -- 1389
	do -- 1389
		local _accum_0 = { } -- 1389
		local _len_0 = 1 -- 1389
		for part in filename:gmatch("[^/]+") do -- 1389
			_accum_0[_len_0] = part -- 1389
			_len_0 = _len_0 + 1 -- 1389
		end -- 1389
		parts = _accum_0 -- 1389
	end -- 1389
	if #parts == 0 then -- 1390
		return -- 1390
	end -- 1390
	for _index_0 = 1, #parts do -- 1391
		local part = parts[_index_0] -- 1391
		if part == "." or part == ".." or part == "" then -- 1392
			return -- 1392
		end -- 1392
	end -- 1391
	return filename -- 1393
end -- 1382
HttpServer:upload("/upload", function(req, multipartFilename) -- 1397
	do -- 1398
		local _type_0 = type(req) -- 1398
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1398
		if _tab_0 then -- 1398
			local path -- 1398
			do -- 1398
				local _obj_0 = req.params -- 1398
				local _type_1 = type(_obj_0) -- 1398
				if "table" == _type_1 or "userdata" == _type_1 then -- 1398
					path = _obj_0.path -- 1398
				end -- 1398
			end -- 1398
			if path ~= nil then -- 1398
				local filename = getUploadFilename(req, multipartFilename) -- 1399
				if filename then -- 1399
					local uploadPath = Path(Content.writablePath, ".upload") -- 1400
					if not Content:exist(uploadPath) then -- 1401
						Content:mkdir(uploadPath) -- 1402
					end -- 1401
					local targetPath = Path(uploadPath, filename) -- 1403
					Content:mkdir(Path:getPath(targetPath)) -- 1404
					return targetPath -- 1405
				end -- 1399
			end -- 1398
		end -- 1398
	end -- 1398
	return nil -- 1397
end, function(req, file) -- 1406
	do -- 1407
		local _type_0 = type(req) -- 1407
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1407
		if _tab_0 then -- 1407
			local path -- 1407
			do -- 1407
				local _obj_0 = req.params -- 1407
				local _type_1 = type(_obj_0) -- 1407
				if "table" == _type_1 or "userdata" == _type_1 then -- 1407
					path = _obj_0.path -- 1407
				end -- 1407
			end -- 1407
			if path ~= nil then -- 1407
				path = Path(Content.writablePath, path) -- 1408
				if Content:exist(path) then -- 1409
					local uploadPath = Path(Content.writablePath, ".upload") -- 1410
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1411
					Content:mkdir(Path:getPath(targetPath)) -- 1412
					if Content:move(file, targetPath) then -- 1413
						return true -- 1414
					end -- 1413
				end -- 1409
			end -- 1407
		end -- 1407
	end -- 1407
	return false -- 1406
end) -- 1395
HttpServer:post("/list", function(req) -- 1417
	do -- 1418
		local _type_0 = type(req) -- 1418
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1418
		if _tab_0 then -- 1418
			local path -- 1418
			do -- 1418
				local _obj_0 = req.body -- 1418
				local _type_1 = type(_obj_0) -- 1418
				if "table" == _type_1 or "userdata" == _type_1 then -- 1418
					path = _obj_0.path -- 1418
				end -- 1418
			end -- 1418
			if path ~= nil then -- 1418
				if Content:exist(path) then -- 1419
					local files = { } -- 1420
					local visitAssets -- 1421
					visitAssets = function(path, folder) -- 1421
						local dirs = Content:getDirs(path) -- 1422
						for _index_0 = 1, #dirs do -- 1423
							local dir = dirs[_index_0] -- 1423
							if dir:match("^%.") or dir == "node_modules" then -- 1424
								goto _continue_0 -- 1424
							end -- 1424
							local current -- 1425
							if folder == "" then -- 1425
								current = dir -- 1426
							else -- 1428
								current = Path(folder, dir) -- 1428
							end -- 1425
							files[#files + 1] = current -- 1429
							visitAssets(Path(path, dir), current) -- 1430
							::_continue_0:: -- 1424
						end -- 1423
						local fs = Content:getFiles(path) -- 1431
						for _index_0 = 1, #fs do -- 1432
							local f = fs[_index_0] -- 1432
							if (".DS_Store" == f) then -- 1433
								goto _continue_1 -- 1434
							end -- 1433
							if folder == "" then -- 1435
								files[#files + 1] = f -- 1436
							else -- 1438
								files[#files + 1] = Path(folder, f) -- 1438
							end -- 1435
							::_continue_1:: -- 1433
						end -- 1432
					end -- 1421
					visitAssets(path, "") -- 1439
					if #files == 0 then -- 1440
						files = nil -- 1440
					end -- 1440
					return { -- 1441
						success = true, -- 1441
						files = files -- 1441
					} -- 1441
				end -- 1419
			end -- 1418
		end -- 1418
	end -- 1418
	return { -- 1417
		success = false -- 1417
	} -- 1417
end) -- 1417
HttpServer:post("/info", function(req) -- 1443
	local Entry = require("Script.Dev.Entry") -- 1444
	local config = Entry.getConfig() -- 1445
	do -- 1446
		local _type_0 = type(req) -- 1446
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1446
		if _tab_0 then -- 1446
			local webIDETourCompleted -- 1446
			do -- 1446
				local _obj_0 = req.body -- 1446
				local _type_1 = type(_obj_0) -- 1446
				if "table" == _type_1 or "userdata" == _type_1 then -- 1446
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1446
				end -- 1446
			end -- 1446
			if webIDETourCompleted ~= nil then -- 1446
				config.webIDETourCompleted = webIDETourCompleted == true -- 1447
			end -- 1446
		end -- 1446
	end -- 1446
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1448
	local engineDev = Entry.getEngineDev() -- 1449
	Entry.connectWebIDE() -- 1450
	return { -- 1452
		platform = App.platform, -- 1452
		locale = App.locale, -- 1453
		version = App.version, -- 1454
		engineDev = engineDev, -- 1455
		webProfiler = webProfiler, -- 1456
		drawerWidth = drawerWidth, -- 1457
		webIDETourCompleted = webIDETourCompleted == true -- 1458
	} -- 1451
end) -- 1443
local ensureLLMConfigTable -- 1460
ensureLLMConfigTable = function() -- 1460
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1461
	if columns and #columns > 0 then -- 1462
		local expected = { -- 1464
			id = true, -- 1464
			name = true, -- 1465
			url = true, -- 1466
			model = true, -- 1467
			api_key = true, -- 1468
			context_window = true, -- 1469
			temperature = true, -- 1470
			max_tokens = true, -- 1471
			reasoning_effort = true, -- 1472
			custom_options = true, -- 1473
			supports_function_calling = true, -- 1474
			active = true, -- 1475
			created_at = true, -- 1476
			updated_at = true -- 1477
		} -- 1463
		local existing = { } -- 1479
		local valid = true -- 1480
		for _index_0 = 1, #columns do -- 1481
			local row = columns[_index_0] -- 1481
			local columnName = tostring(row[2]) -- 1482
			existing[columnName] = true -- 1483
			if not expected[columnName] then -- 1484
				valid = false -- 1485
				break -- 1486
			end -- 1484
		end -- 1481
		if valid then -- 1487
			if not existing.context_window then -- 1488
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1489
			end -- 1488
			if not existing.temperature then -- 1490
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1491
			end -- 1490
			if not existing.max_tokens then -- 1492
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 64000") -- 1493
			end -- 1492
			if not existing.reasoning_effort then -- 1494
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1495
			end -- 1494
			if not existing.custom_options then -- 1496
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1497
			end -- 1496
			if not existing.supports_function_calling then -- 1498
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1499
			end -- 1498
		else -- 1501
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1501
		end -- 1487
	end -- 1462
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
	]]) -- 1502
	return require("Agent.LLMConfigMigration").upgradeLLMConfig() -- 1521
end -- 1460
local normalizeContextWindow -- 1523
normalizeContextWindow = function(value) -- 1523
	local contextWindow = tonumber(value) -- 1524
	if contextWindow == nil or contextWindow < 64000 then -- 1525
		return 64000 -- 1526
	end -- 1525
	return math.max(64000, math.floor(contextWindow)) -- 1527
end -- 1523
local normalizeTemperature -- 1529
normalizeTemperature = function(value) -- 1529
	local temperature = tonumber(value) -- 1530
	if temperature == nil then -- 1531
		return 0.1 -- 1532
	end -- 1531
	return math.max(0, math.min(2, temperature)) -- 1533
end -- 1529
local normalizeMaxTokens -- 1535
normalizeMaxTokens = function(value) -- 1535
	local maxTokens = tonumber(value) -- 1536
	if maxTokens == nil or maxTokens < 1 then -- 1537
		return 64000 -- 1538
	end -- 1537
	return math.max(1, math.floor(maxTokens)) -- 1539
end -- 1535
local normalizeReasoningEffort -- 1541
normalizeReasoningEffort = function(value) -- 1541
	if value == nil then -- 1542
		return "" -- 1543
	end -- 1542
	local effort = tostring(value) -- 1544
	return effort:match("^%s*(.-)%s*$") or "" -- 1545
end -- 1541
local normalizeCustomOptions -- 1547
normalizeCustomOptions = function(value) -- 1547
	if value == nil then -- 1548
		return "" -- 1549
	end -- 1548
	local options = tostring(value) -- 1550
	options = options:match("^%s*(.-)%s*$") or "" -- 1551
	return options -- 1552
end -- 1547
local validateCustomOptions -- 1554
validateCustomOptions = function(value) -- 1554
	local options = normalizeCustomOptions(value) -- 1555
	if options == "" then -- 1556
		return true -- 1556
	end -- 1556
	if not options:match("^%s*{") then -- 1557
		return false -- 1557
	end -- 1557
	local decoded = json.decode(options) -- 1558
	return type(decoded) == "table" -- 1559
end -- 1554
HttpServer:post("/llm/list", function() -- 1561
	ensureLLMConfigTable() -- 1562
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1563
	local items -- 1567
	if rows and #rows > 0 then -- 1567
		local _accum_0 = { } -- 1568
		local _len_0 = 1 -- 1568
		for _index_0 = 1, #rows do -- 1568
			local _des_0 = rows[_index_0] -- 1568
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1568
			_accum_0[_len_0] = { -- 1569
				id = id, -- 1569
				name = name, -- 1569
				url = url, -- 1569
				model = model, -- 1569
				key = key, -- 1569
				contextWindow = normalizeContextWindow(contextWindow), -- 1569
				temperature = normalizeTemperature(temperature), -- 1569
				maxTokens = normalizeMaxTokens(maxTokens), -- 1569
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1569
				customOptions = normalizeCustomOptions(customOptions), -- 1569
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1569
			} -- 1569
			_len_0 = _len_0 + 1 -- 1569
		end -- 1568
		items = _accum_0 -- 1567
	end -- 1567
	return { -- 1570
		success = true, -- 1570
		items = items -- 1570
	} -- 1570
end) -- 1561
HttpServer:post("/llm/create", function(req) -- 1572
	ensureLLMConfigTable() -- 1573
	do -- 1574
		local _type_0 = type(req) -- 1574
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1574
		if _tab_0 then -- 1574
			local body = req.body -- 1574
			if body ~= nil then -- 1574
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1575
				local now = os.time() -- 1576
				if name == nil or url == nil or model == nil or key == nil then -- 1577
					return invalidArguments -- 1578
				end -- 1577
				contextWindow = normalizeContextWindow(contextWindow) -- 1579
				temperature = normalizeTemperature(temperature) -- 1580
				maxTokens = normalizeMaxTokens(maxTokens) -- 1581
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1582
				customOptions = normalizeCustomOptions(customOptions) -- 1583
				if not validateCustomOptions(customOptions) then -- 1584
					return { -- 1584
						success = false, -- 1584
						message = "customOptions must be a JSON object" -- 1584
					} -- 1584
				end -- 1584
				if supportsFunctionCalling == false then -- 1585
					supportsFunctionCalling = 0 -- 1585
				else -- 1585
					supportsFunctionCalling = 1 -- 1585
				end -- 1585
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1592
					tostring(name), -- 1592
					tostring(url), -- 1593
					tostring(model), -- 1594
					tostring(key), -- 1595
					contextWindow, -- 1596
					temperature, -- 1597
					maxTokens, -- 1598
					reasoningEffort, -- 1599
					customOptions, -- 1600
					supportsFunctionCalling, -- 1601
					1, -- 1602
					now, -- 1603
					now -- 1604
				}) -- 1586
				return { -- 1606
					success = affected >= 0 -- 1606
				} -- 1606
			end -- 1574
		end -- 1574
	end -- 1574
	return invalidArguments -- 1572
end) -- 1572
HttpServer:post("/llm/update", function(req) -- 1608
	ensureLLMConfigTable() -- 1609
	do -- 1610
		local _type_0 = type(req) -- 1610
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1610
		if _tab_0 then -- 1610
			local body = req.body -- 1610
			if body ~= nil then -- 1610
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1611
				local now = os.time() -- 1612
				id = tonumber(id) -- 1613
				if id == nil then -- 1614
					return invalidArguments -- 1614
				end -- 1614
				contextWindow = normalizeContextWindow(contextWindow) -- 1615
				temperature = normalizeTemperature(temperature) -- 1616
				maxTokens = normalizeMaxTokens(maxTokens) -- 1617
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1618
				customOptions = normalizeCustomOptions(customOptions) -- 1619
				if not validateCustomOptions(customOptions) then -- 1620
					return { -- 1620
						success = false, -- 1620
						message = "customOptions must be a JSON object" -- 1620
					} -- 1620
				end -- 1620
				if supportsFunctionCalling == false then -- 1621
					supportsFunctionCalling = 0 -- 1621
				else -- 1621
					supportsFunctionCalling = 1 -- 1621
				end -- 1621
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1626
					tostring(name), -- 1626
					tostring(url), -- 1627
					tostring(model), -- 1628
					tostring(key), -- 1629
					contextWindow, -- 1630
					temperature, -- 1631
					maxTokens, -- 1632
					reasoningEffort, -- 1633
					customOptions, -- 1634
					supportsFunctionCalling, -- 1635
					now, -- 1636
					id -- 1637
				}) -- 1622
				return { -- 1639
					success = affected >= 0 -- 1639
				} -- 1639
			end -- 1610
		end -- 1610
	end -- 1610
	return invalidArguments -- 1608
end) -- 1608
HttpServer:post("/llm/delete", function(req) -- 1641
	ensureLLMConfigTable() -- 1642
	do -- 1643
		local _type_0 = type(req) -- 1643
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1643
		if _tab_0 then -- 1643
			local id -- 1643
			do -- 1643
				local _obj_0 = req.body -- 1643
				local _type_1 = type(_obj_0) -- 1643
				if "table" == _type_1 or "userdata" == _type_1 then -- 1643
					id = _obj_0.id -- 1643
				end -- 1643
			end -- 1643
			if id ~= nil then -- 1643
				id = tonumber(id) -- 1644
				if id == nil then -- 1645
					return invalidArguments -- 1645
				end -- 1645
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1646
					id -- 1646
				}) -- 1646
				return { -- 1647
					success = affected >= 0 -- 1647
				} -- 1647
			end -- 1643
		end -- 1643
	end -- 1643
	return invalidArguments -- 1641
end) -- 1641
HttpServer:post("/local-agent/list", function() -- 1649
	return { -- 1650
		success = true, -- 1650
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1650
		items = AgentLocalAgent.listConfigs() -- 1650
	} -- 1650
end) -- 1649
HttpServer:post("/local-agent/save", function(req) -- 1652
	do -- 1653
		local _type_0 = type(req) -- 1653
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1653
		if _tab_0 then -- 1653
			local body = req.body -- 1653
			if body ~= nil then -- 1653
				return AgentLocalAgent.saveConfig(body) -- 1654
			end -- 1653
		end -- 1653
	end -- 1653
	return invalidArguments -- 1652
end) -- 1652
HttpServer:post("/local-agent/delete", function(req) -- 1656
	do -- 1657
		local _type_0 = type(req) -- 1657
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1657
		if _tab_0 then -- 1657
			local id -- 1657
			do -- 1657
				local _obj_0 = req.body -- 1657
				local _type_1 = type(_obj_0) -- 1657
				if "table" == _type_1 or "userdata" == _type_1 then -- 1657
					id = _obj_0.id -- 1657
				end -- 1657
			end -- 1657
			if id ~= nil then -- 1657
				return AgentLocalAgent.deleteConfig(id) -- 1658
			end -- 1657
		end -- 1657
	end -- 1657
	return invalidArguments -- 1656
end) -- 1656
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1660
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
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1662
			end -- 1661
		end -- 1661
	end -- 1661
	return invalidArguments -- 1660
end) -- 1660
HttpServer:post("/stat", function(req) -- 1664
	do -- 1665
		local _type_0 = type(req) -- 1665
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1665
		if _tab_0 then -- 1665
			local path -- 1665
			do -- 1665
				local _obj_0 = req.body -- 1665
				local _type_1 = type(_obj_0) -- 1665
				if "table" == _type_1 or "userdata" == _type_1 then -- 1665
					path = _obj_0.path -- 1665
				end -- 1665
			end -- 1665
			if path ~= nil then -- 1665
				if not Content:exist(path) then -- 1666
					return { -- 1667
						success = false, -- 1667
						message = "target not existed" -- 1667
					} -- 1667
				end -- 1666
				if Content:isdir(path) then -- 1668
					return { -- 1669
						success = false, -- 1669
						message = "failed to stat a directory" -- 1669
					} -- 1669
				end -- 1668
				local size, isBinary = Content:getAttr(path) -- 1670
				if size then -- 1670
					return { -- 1671
						success = true, -- 1671
						size = size, -- 1671
						isBinary = isBinary -- 1671
					} -- 1671
				end -- 1670
			end -- 1665
		end -- 1665
	end -- 1665
	return { -- 1664
		success = false, -- 1664
		message = "failed to stat" -- 1664
	} -- 1664
end) -- 1664
HttpServer:post("/new", function(req) -- 1673
	do -- 1674
		local _type_0 = type(req) -- 1674
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1674
		if _tab_0 then -- 1674
			local path -- 1674
			do -- 1674
				local _obj_0 = req.body -- 1674
				local _type_1 = type(_obj_0) -- 1674
				if "table" == _type_1 or "userdata" == _type_1 then -- 1674
					path = _obj_0.path -- 1674
				end -- 1674
			end -- 1674
			local content -- 1674
			do -- 1674
				local _obj_0 = req.body -- 1674
				local _type_1 = type(_obj_0) -- 1674
				if "table" == _type_1 or "userdata" == _type_1 then -- 1674
					content = _obj_0.content -- 1674
				end -- 1674
			end -- 1674
			local folder -- 1674
			do -- 1674
				local _obj_0 = req.body -- 1674
				local _type_1 = type(_obj_0) -- 1674
				if "table" == _type_1 or "userdata" == _type_1 then -- 1674
					folder = _obj_0.folder -- 1674
				end -- 1674
			end -- 1674
			if path ~= nil and content ~= nil and folder ~= nil then -- 1674
				if Content:exist(path) then -- 1675
					return { -- 1676
						success = false, -- 1676
						message = "TargetExisted" -- 1676
					} -- 1676
				end -- 1675
				local parent = Path:getPath(path) -- 1677
				local files = Content:getFiles(parent) -- 1678
				if folder then -- 1679
					local name = Path:getFilename(path):lower() -- 1680
					for _index_0 = 1, #files do -- 1681
						local file = files[_index_0] -- 1681
						if name == Path:getFilename(file):lower() then -- 1682
							return { -- 1683
								success = false, -- 1683
								message = "TargetExisted" -- 1683
							} -- 1683
						end -- 1682
					end -- 1681
					if Content:mkdir(path) then -- 1684
						return { -- 1685
							success = true -- 1685
						} -- 1685
					end -- 1684
				else -- 1687
					local name = Path:getName(path):lower() -- 1687
					for _index_0 = 1, #files do -- 1688
						local file = files[_index_0] -- 1688
						if name == Path:getName(file):lower() then -- 1689
							local ext = Path:getExt(file) -- 1690
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1691
								goto _continue_0 -- 1692
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1693
								goto _continue_0 -- 1694
							end -- 1691
							return { -- 1695
								success = false, -- 1695
								message = "SourceExisted" -- 1695
							} -- 1695
						end -- 1689
						::_continue_0:: -- 1689
					end -- 1688
					if Content:save(path, content) then -- 1696
						return { -- 1697
							success = true -- 1697
						} -- 1697
					end -- 1696
				end -- 1679
			end -- 1674
		end -- 1674
	end -- 1674
	return { -- 1673
		success = false, -- 1673
		message = "Failed" -- 1673
	} -- 1673
end) -- 1673
local deleteAsset -- 1699
deleteAsset = function(path) -- 1699
	if not Content:exist(path) then -- 1700
		return false -- 1700
	end -- 1700
	local projectRoot -- 1701
	if Content:isdir(path) and isProjectRootDir(path) then -- 1701
		projectRoot = path -- 1701
	else -- 1701
		projectRoot = nil -- 1701
	end -- 1701
	local parent = Path:getPath(path) -- 1702
	local files = Content:getFiles(parent) -- 1703
	local name = Path:getName(path):lower() -- 1704
	local ext = Path:getExt(path) -- 1705
	for _index_0 = 1, #files do -- 1706
		local file = files[_index_0] -- 1706
		if name == Path:getName(file):lower() then -- 1707
			local _exp_0 = Path:getExt(file) -- 1708
			if "tl" == _exp_0 then -- 1708
				if ("vs" == ext) then -- 1708
					Content:remove(Path(parent, file)) -- 1709
				end -- 1708
			elseif "lua" == _exp_0 then -- 1710
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1710
					Content:remove(Path(parent, file)) -- 1711
				end -- 1710
			end -- 1708
		end -- 1707
	end -- 1706
	if Content:remove(path) then -- 1712
		if projectRoot then -- 1713
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1714
		end -- 1713
		return true -- 1715
	end -- 1712
	return false -- 1716
end -- 1699
local moveAsset -- 1718
moveAsset = function(old, new) -- 1718
	if not (Content:exist(old) and not Content:exist(new)) then -- 1719
		return false -- 1719
	end -- 1719
	local renamedDir = Content:isdir(old) -- 1720
	local parent = Path:getPath(new) -- 1721
	local files = Content:getFiles(parent) -- 1722
	if renamedDir then -- 1723
		local name = Path:getFilename(new):lower() -- 1724
		for _index_0 = 1, #files do -- 1725
			local file = files[_index_0] -- 1725
			if name == Path:getFilename(file):lower() then -- 1726
				return false -- 1727
			end -- 1726
		end -- 1725
	else -- 1729
		local name = Path:getName(new):lower() -- 1729
		local ext = Path:getExt(new) -- 1730
		for _index_0 = 1, #files do -- 1731
			local file = files[_index_0] -- 1731
			if name == Path:getName(file):lower() then -- 1732
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1733
					goto _continue_0 -- 1734
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1735
					goto _continue_0 -- 1736
				end -- 1733
				return false -- 1737
			end -- 1732
			::_continue_0:: -- 1732
		end -- 1731
	end -- 1723
	if not Content:move(old, new) then -- 1738
		return false -- 1738
	end -- 1738
	if renamedDir then -- 1739
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1740
	end -- 1739
	local newParent = Path:getPath(new) -- 1741
	parent = Path:getPath(old) -- 1742
	files = Content:getFiles(parent) -- 1743
	local newName = Path:getName(new) -- 1744
	local oldName = Path:getName(old) -- 1745
	local name = oldName:lower() -- 1746
	local ext = Path:getExt(old) -- 1747
	for _index_0 = 1, #files do -- 1748
		local file = files[_index_0] -- 1748
		if name == Path:getName(file):lower() then -- 1749
			local _exp_0 = Path:getExt(file) -- 1750
			if "tl" == _exp_0 then -- 1750
				if ("vs" == ext) then -- 1750
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1751
				end -- 1750
			elseif "lua" == _exp_0 then -- 1752
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1752
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1753
				end -- 1752
			end -- 1750
		end -- 1749
	end -- 1748
	return true -- 1754
end -- 1718
HttpServer:post("/delete", function(req) -- 1756
	do -- 1757
		local _type_0 = type(req) -- 1757
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1757
		if _tab_0 then -- 1757
			local path -- 1757
			do -- 1757
				local _obj_0 = req.body -- 1757
				local _type_1 = type(_obj_0) -- 1757
				if "table" == _type_1 or "userdata" == _type_1 then -- 1757
					path = _obj_0.path -- 1757
				end -- 1757
			end -- 1757
			if path ~= nil then -- 1757
				if deleteAsset(path) then -- 1758
					return { -- 1758
						success = true -- 1758
					} -- 1758
				end -- 1758
			end -- 1757
		end -- 1757
	end -- 1757
	return { -- 1756
		success = false -- 1756
	} -- 1756
end) -- 1756
HttpServer:post("/rename", function(req) -- 1760
	do -- 1761
		local _type_0 = type(req) -- 1761
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1761
		if _tab_0 then -- 1761
			local old -- 1761
			do -- 1761
				local _obj_0 = req.body -- 1761
				local _type_1 = type(_obj_0) -- 1761
				if "table" == _type_1 or "userdata" == _type_1 then -- 1761
					old = _obj_0.old -- 1761
				end -- 1761
			end -- 1761
			local new -- 1761
			do -- 1761
				local _obj_0 = req.body -- 1761
				local _type_1 = type(_obj_0) -- 1761
				if "table" == _type_1 or "userdata" == _type_1 then -- 1761
					new = _obj_0.new -- 1761
				end -- 1761
			end -- 1761
			if old ~= nil and new ~= nil then -- 1761
				if moveAsset(old, new) then -- 1762
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
local normalizeAssetPaths -- 1764
normalizeAssetPaths = function(paths) -- 1764
	if not (type(paths) == "table") then -- 1765
		return nil -- 1765
	end -- 1765
	local unique = { } -- 1766
	local candidates = { } -- 1767
	for _index_0 = 1, #paths do -- 1768
		local path = paths[_index_0] -- 1768
		if not (type(path) == "string") then -- 1769
			return nil -- 1769
		end -- 1769
		local relative = relativeToRoot(path, Content.writablePath) -- 1770
		if relative == nil or relative == "" or not Content:exist(path) then -- 1771
			return nil -- 1771
		end -- 1771
		if not unique[path] then -- 1772
			unique[path] = true -- 1773
			candidates[#candidates + 1] = path -- 1774
		end -- 1772
	end -- 1768
	table.sort(candidates, function(a, b) -- 1775
		return #a < #b -- 1775
	end) -- 1775
	local result = { } -- 1776
	for _index_0 = 1, #candidates do -- 1777
		local path = candidates[_index_0] -- 1777
		local contained = false -- 1778
		for _index_1 = 1, #result do -- 1779
			local parent = result[_index_1] -- 1779
			if relativeToRoot(path, parent) ~= nil then -- 1780
				contained = true -- 1781
				break -- 1782
			end -- 1780
		end -- 1779
		if not contained then -- 1783
			result[#result + 1] = path -- 1783
		end -- 1783
	end -- 1777
	return result -- 1784
end -- 1764
HttpServer:postSchedule("/assets/batch", function(req) -- 1786
	do -- 1787
		local _type_0 = type(req) -- 1787
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1787
		if _tab_0 then -- 1787
			local operation -- 1787
			do -- 1787
				local _obj_0 = req.body -- 1787
				local _type_1 = type(_obj_0) -- 1787
				if "table" == _type_1 or "userdata" == _type_1 then -- 1787
					operation = _obj_0.operation -- 1787
				end -- 1787
			end -- 1787
			local sources -- 1787
			do -- 1787
				local _obj_0 = req.body -- 1787
				local _type_1 = type(_obj_0) -- 1787
				if "table" == _type_1 or "userdata" == _type_1 then -- 1787
					sources = _obj_0.sources -- 1787
				end -- 1787
			end -- 1787
			if operation ~= nil and sources ~= nil then -- 1787
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1788
					return { -- 1788
						success = false, -- 1788
						message = "invalid operation" -- 1788
					} -- 1788
				end -- 1788
				sources = normalizeAssetPaths(sources) -- 1789
				if not (sources and #sources > 0) then -- 1790
					return { -- 1790
						success = false, -- 1790
						message = "invalid sources" -- 1790
					} -- 1790
				end -- 1790
				local target = req.body.target -- 1791
				local destinations = { } -- 1792
				if operation ~= "delete" then -- 1793
					if not (type(target) == "string") then -- 1794
						return { -- 1794
							success = false, -- 1794
							message = "invalid target" -- 1794
						} -- 1794
					end -- 1794
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1795
					if targetRelative == nil then -- 1796
						return { -- 1796
							success = false, -- 1796
							message = "invalid target" -- 1796
						} -- 1796
					end -- 1796
					if not (Content:exist(target) and Content:isdir(target)) then -- 1797
						return { -- 1797
							success = false, -- 1797
							message = "invalid target" -- 1797
						} -- 1797
					end -- 1797
					for _index_0 = 1, #sources do -- 1798
						local source = sources[_index_0] -- 1798
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1799
							return { -- 1800
								success = false, -- 1800
								message = "target inside source" -- 1800
							} -- 1800
						end -- 1799
						local destination = Path(target, Path:getFilename(source)) -- 1801
						if Content:exist(destination) then -- 1802
							return { -- 1802
								success = false, -- 1802
								message = "target existed" -- 1802
							} -- 1802
						end -- 1802
						if destinations[destination] then -- 1803
							return { -- 1803
								success = false, -- 1803
								message = "duplicate target" -- 1803
							} -- 1803
						end -- 1803
						destinations[destination] = true -- 1804
					end -- 1798
				end -- 1793
				local changes = { } -- 1805
				local affectedSet = { } -- 1806
				local affectedDirectories = { } -- 1807
				local addAffected -- 1808
				addAffected = function(dir) -- 1808
					if affectedSet[dir] then -- 1809
						return -- 1809
					end -- 1809
					affectedSet[dir] = true -- 1810
					affectedDirectories[#affectedDirectories + 1] = dir -- 1811
				end -- 1808
				if operation ~= "delete" then -- 1812
					addAffected(target) -- 1812
				end -- 1812
				for _index_0 = 1, #sources do -- 1813
					local source = sources[_index_0] -- 1813
					addAffected(Path:getPath(source)) -- 1814
					if operation == "delete" then -- 1815
						if not deleteAsset(source) then -- 1816
							return { -- 1816
								success = false, -- 1816
								message = "delete failed", -- 1816
								changes = changes, -- 1816
								affectedDirectories = affectedDirectories -- 1816
							} -- 1816
						end -- 1816
						changes[#changes + 1] = { -- 1817
							old = source -- 1817
						} -- 1817
					else -- 1819
						local destination = Path(target, Path:getFilename(source)) -- 1819
						local ok -- 1820
						if operation == "copy" then -- 1820
							ok = Content:copyAsync(source, destination) -- 1821
						else -- 1823
							ok = moveAsset(source, destination) -- 1823
						end -- 1820
						if not ok then -- 1824
							return { -- 1824
								success = false, -- 1824
								message = operation .. " failed", -- 1824
								changes = changes, -- 1824
								affectedDirectories = affectedDirectories -- 1824
							} -- 1824
						end -- 1824
						changes[#changes + 1] = { -- 1825
							old = source, -- 1825
							new = destination -- 1825
						} -- 1825
					end -- 1815
				end -- 1813
				return { -- 1826
					success = true, -- 1826
					changes = changes, -- 1826
					affectedDirectories = affectedDirectories -- 1826
				} -- 1826
			end -- 1787
		end -- 1787
	end -- 1787
	return { -- 1786
		success = false, -- 1786
		message = "invalid request" -- 1786
	} -- 1786
end) -- 1786
local withProjectSearchPaths -- 1828
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1828
	local fallbackPaths = { } -- 1829
	local addFallback -- 1830
	addFallback = function(dir) -- 1830
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1830
			fallbackPaths[#fallbackPaths + 1] = dir -- 1830
		end -- 1830
	end -- 1830
	if projectRoot and projectRoot ~= "" then -- 1831
		addFallback(Path(projectRoot, "Script")) -- 1832
		addFallback(projectRoot) -- 1833
	end -- 1831
	if projFile then -- 1834
		local projDir = getProjectDirFromFile(projFile) -- 1835
		if projDir then -- 1835
			addFallback(Path(projDir, "Script")) -- 1836
			addFallback(projDir) -- 1837
		else -- 1839
			addFallback(Path:getPath(projFile)) -- 1839
		end -- 1835
	end -- 1834
	if not (#fallbackPaths > 0) then -- 1840
		return fn() -- 1840
	end -- 1840
	local searchPaths = Content.searchPaths -- 1841
	for _index_0 = 1, #fallbackPaths do -- 1842
		local dir = fallbackPaths[_index_0] -- 1842
		Content:addSearchPath(dir) -- 1842
	end -- 1842
	local _ <close> = setmetatable({ }, { -- 1843
		__close = function() -- 1843
			Content.searchPaths = searchPaths -- 1843
		end -- 1843
	}) -- 1843
	return fn() -- 1844
end -- 1828
HttpServer:post("/exist", function(req) -- 1845
	do -- 1846
		local _type_0 = type(req) -- 1846
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1846
		if _tab_0 then -- 1846
			local file -- 1846
			do -- 1846
				local _obj_0 = req.body -- 1846
				local _type_1 = type(_obj_0) -- 1846
				if "table" == _type_1 or "userdata" == _type_1 then -- 1846
					file = _obj_0.file -- 1846
				end -- 1846
			end -- 1846
			if file ~= nil then -- 1846
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1847
					return { -- 1848
						success = Content:exist(file) -- 1848
					} -- 1848
				end) -- 1847
			end -- 1846
		end -- 1846
	end -- 1846
	return { -- 1845
		success = false -- 1845
	} -- 1845
end) -- 1845
HttpServer:postSchedule("/read", function(req) -- 1849
	do -- 1850
		local _type_0 = type(req) -- 1850
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1850
		if _tab_0 then -- 1850
			local path -- 1850
			do -- 1850
				local _obj_0 = req.body -- 1850
				local _type_1 = type(_obj_0) -- 1850
				if "table" == _type_1 or "userdata" == _type_1 then -- 1850
					path = _obj_0.path -- 1850
				end -- 1850
			end -- 1850
			if path ~= nil then -- 1850
				local readFile -- 1851
				readFile = function() -- 1851
					if Content:exist(path) and not Content:isdir(path) then -- 1852
						local content = Content:loadAsync(path) -- 1853
						if content then -- 1853
							return { -- 1854
								content = content, -- 1854
								success = true, -- 1854
								fullPath = Content:getFullPath(path) -- 1854
							} -- 1854
						end -- 1853
					end -- 1852
					return nil -- 1851
				end -- 1851
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1855
				if result then -- 1855
					return result -- 1855
				end -- 1855
			end -- 1850
		end -- 1850
	end -- 1850
	return { -- 1849
		success = false -- 1849
	} -- 1849
end) -- 1849
local agentDocLanguage -- 1857
agentDocLanguage = function(language) -- 1857
	if language == "zh-Hans" then -- 1858
		return "zh" -- 1858
	else -- 1858
		return "en" -- 1858
	end -- 1858
end -- 1857
HttpServer:postSchedule("/doc/search", function(req) -- 1860
	local body = req.body or { } -- 1861
	local language = body.docLanguage -- 1862
	if not (("en" == language or "zh-Hans" == language)) then -- 1863
		return { -- 1863
			success = false, -- 1863
			message = "unsupported doc language" -- 1863
		} -- 1863
	end -- 1863
	local docType = body.docType -- 1864
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1865
		return { -- 1865
			success = false, -- 1865
			message = "unsupported doc type" -- 1865
		} -- 1865
	end -- 1865
	local codeLanguage = body.programmingLanguage -- 1866
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1867
		return { -- 1867
			success = false, -- 1867
			message = "unsupported programming language" -- 1867
		} -- 1867
	end -- 1867
	if not body.pattern then -- 1868
		return { -- 1868
			success = false, -- 1868
			message = "missing pattern" -- 1868
		} -- 1868
	end -- 1868
	local result = nil -- 1869
	AgentTools.searchDoraDocHttp({ -- 1871
		pattern = body.pattern, -- 1871
		docLanguage = agentDocLanguage(language), -- 1872
		docType = docType, -- 1873
		programmingLanguage = codeLanguage, -- 1874
		limit = body.limit, -- 1875
		useRegex = body.useRegex, -- 1876
		caseSensitive = body.caseSensitive, -- 1877
		includeContent = body.includeContent, -- 1878
		contentWindow = body.contentWindow -- 1879
	}, function(res) -- 1880
		result = res -- 1881
	end) -- 1870
	wait(function() -- 1882
		return result ~= nil -- 1882
	end) -- 1882
	if result and result.success then -- 1883
		result.docLanguage = language -- 1884
	end -- 1883
	if result then -- 1885
		return result -- 1886
	else -- 1888
		return { -- 1888
			success = false, -- 1888
			message = "doc search failed" -- 1888
		} -- 1888
	end -- 1885
	return { -- 1860
		success = false, -- 1860
		message = "invalid call" -- 1860
	} -- 1860
end) -- 1860
HttpServer:postSchedule("/doc/read", function(req) -- 1890
	local body = req.body or { } -- 1891
	local language = body.docLanguage -- 1892
	if not (("en" == language or "zh-Hans" == language)) then -- 1893
		return { -- 1893
			success = false, -- 1893
			message = "unsupported doc language" -- 1893
		} -- 1893
	end -- 1893
	if not body.file then -- 1894
		return { -- 1894
			success = false, -- 1894
			message = "missing file" -- 1894
		} -- 1894
	end -- 1894
	local result = AgentTools.readDoraDoc({ -- 1896
		docLanguage = agentDocLanguage(language), -- 1896
		file = body.file, -- 1897
		startLine = body.startLine, -- 1898
		endLine = body.endLine -- 1899
	}) -- 1895
	if result and result.success then -- 1900
		result.docLanguage = language -- 1901
	end -- 1900
	return result -- 1902
end) -- 1890
HttpServer:get("/read-sync", function(req) -- 1904
	do -- 1905
		local _type_0 = type(req) -- 1905
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1905
		if _tab_0 then -- 1905
			local params = req.params -- 1905
			if params ~= nil then -- 1905
				local path = params.path -- 1906
				local exts -- 1907
				if params.exts then -- 1907
					local _accum_0 = { } -- 1908
					local _len_0 = 1 -- 1908
					for ext in params.exts:gmatch("[^|]*") do -- 1908
						_accum_0[_len_0] = ext -- 1908
						_len_0 = _len_0 + 1 -- 1908
					end -- 1908
					exts = _accum_0 -- 1908
				else -- 1909
					exts = { -- 1909
						"" -- 1909
					} -- 1909
				end -- 1907
				local readFileAt -- 1910
				readFileAt = function(targetPath) -- 1910
					if Content:exist(targetPath) then -- 1911
						local content = Content:load(targetPath) -- 1912
						if content then -- 1912
							return { -- 1913
								content = content, -- 1913
								success = true, -- 1913
								fullPath = Content:getFullPath(targetPath) -- 1913
							} -- 1913
						end -- 1912
					end -- 1911
					return nil -- 1910
				end -- 1910
				local readFile -- 1914
				readFile = function(fallbackPaths) -- 1914
					for _index_0 = 1, #exts do -- 1915
						local ext = exts[_index_0] -- 1915
						local targetPath = path .. ext -- 1916
						if not Content:isAbsolutePath(targetPath) then -- 1917
							for _index_1 = 1, #fallbackPaths do -- 1918
								local fallback = fallbackPaths[_index_1] -- 1918
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1919
								if fallbackResult then -- 1919
									return fallbackResult -- 1920
								end -- 1919
							end -- 1918
						end -- 1917
						local fileResult = readFileAt(targetPath) -- 1921
						if fileResult then -- 1921
							return fileResult -- 1922
						end -- 1921
					end -- 1915
					return nil -- 1914
				end -- 1914
				local fallbackPaths = { } -- 1923
				local fallbackCandidates = { } -- 1924
				do -- 1925
					local projectRoot = req.params.projectRoot -- 1925
					if projectRoot then -- 1925
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1926
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1927
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1928
						end -- 1926
					end -- 1925
				end -- 1925
				do -- 1929
					local projFile = req.params.projFile -- 1929
					if projFile then -- 1929
						local projDir = getProjectDirFromFile(projFile) -- 1930
						if projDir then -- 1930
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1931
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1932
						else -- 1934
							projDir = Path:getPath(projFile) -- 1934
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1935
						end -- 1930
					end -- 1929
				end -- 1929
				for _index_0 = 1, #fallbackCandidates do -- 1936
					local dir = fallbackCandidates[_index_0] -- 1936
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1937
						local exists = false -- 1938
						for _index_1 = 1, #fallbackPaths do -- 1939
							local fallback = fallbackPaths[_index_1] -- 1939
							if fallback == dir then -- 1940
								exists = true -- 1941
								break -- 1942
							end -- 1940
						end -- 1939
						if not exists then -- 1943
							fallbackPaths[#fallbackPaths + 1] = dir -- 1943
						end -- 1943
					end -- 1937
				end -- 1936
				local readResult = readFile(fallbackPaths) -- 1944
				if readResult then -- 1944
					return readResult -- 1945
				end -- 1944
			end -- 1905
		end -- 1905
	end -- 1905
	return { -- 1904
		success = false -- 1904
	} -- 1904
end) -- 1904
local addGeneratedSourceHeader -- 1947
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 1947
	if preserveTIC80 == nil then -- 1947
		preserveTIC80 = false -- 1947
	end -- 1947
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 1948
	if preserveTIC80 then -- 1949
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 1950
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 1951
		end -- 1950
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 1952
	end -- 1949
	return tostring(header) .. "\n" .. tostring(codes) -- 1953
end -- 1947
local compileFileAsync -- 1955
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1955
	if projectRoot == nil then -- 1955
		projectRoot = nil -- 1955
	end -- 1955
	local file = inputFile -- 1956
	local searchPath -- 1957
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1957
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1958
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1962
	elseif not Content:isAbsolutePath(inputFile) then -- 1963
		searchPath = "" -- 1964
	else -- 1965
		local dir = getProjectDirFromFile(inputFile) -- 1965
		if dir then -- 1965
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1966
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1970
		else -- 1972
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1972
			searchPath = "" -- 1975
		end -- 1965
	end -- 1957
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1976
	local yueext = yue.options.extension -- 1977
	local resultCodes = nil -- 1978
	local resultError = nil -- 1979
	do -- 1980
		local _exp_0 = Path:getExt(inputFile) -- 1980
		if yueext == _exp_0 then -- 1980
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1981
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1982
				if not codes then -- 1983
					resultError = err -- 1984
					return -- 1985
				end -- 1983
				local extraGlobal -- 1986
				if isTIC80 then -- 1986
					extraGlobal = tic80APIs -- 1986
				else -- 1986
					extraGlobal = nil -- 1986
				end -- 1986
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1987
				if not success then -- 1988
					resultError = message -- 1989
					return -- 1990
				end -- 1988
				if codes == "" then -- 1991
					resultCodes = "" -- 1992
					return nil -- 1993
				end -- 1991
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 1994
				return resultCodes -- 1995
			end, function(success) -- 1982
				if not success then -- 1996
					Content:remove(outputFile) -- 1997
					if resultCodes == nil then -- 1998
						resultCodes = false -- 1999
					end -- 1998
				end -- 1996
			end) -- 1982
		elseif "tl" == _exp_0 then -- 2000
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 2001
			if isTIC80 then -- 2002
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2003
			end -- 2002
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2004
			if codes then -- 2004
				if isTIC80 then -- 2005
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2006
				end -- 2005
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2007
				Content:saveAsync(outputFile, resultCodes) -- 2008
			else -- 2010
				Content:remove(outputFile) -- 2010
				resultCodes = false -- 2011
				resultError = err -- 2012
			end -- 2004
		elseif "xml" == _exp_0 then -- 2013
			local codes, err = xml.tolua(sourceCodes) -- 2014
			if codes then -- 2014
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2015
				Content:saveAsync(outputFile, resultCodes) -- 2016
			else -- 2018
				Content:remove(outputFile) -- 2018
				resultCodes = false -- 2019
				resultError = err -- 2020
			end -- 2014
		end -- 1980
	end -- 1980
	wait(function() -- 2021
		return resultCodes ~= nil -- 2021
	end) -- 2021
	if resultCodes then -- 2022
		return resultCodes -- 2023
	else -- 2025
		return nil, resultError -- 2025
	end -- 2022
	return nil -- 1955
end -- 1955
HttpServer:postSchedule("/write", function(req) -- 2027
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2028
	local buildSucceeded = false -- 2029
	local _ <close> = setmetatable({ }, { -- 2030
		__close = function() -- 2030
			return finishUpdate(buildSucceeded) -- 2030
		end -- 2030
	}) -- 2030
	do -- 2031
		local _type_0 = type(req) -- 2031
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2031
		if _tab_0 then -- 2031
			local path -- 2031
			do -- 2031
				local _obj_0 = req.body -- 2031
				local _type_1 = type(_obj_0) -- 2031
				if "table" == _type_1 or "userdata" == _type_1 then -- 2031
					path = _obj_0.path -- 2031
				end -- 2031
			end -- 2031
			local content -- 2031
			do -- 2031
				local _obj_0 = req.body -- 2031
				local _type_1 = type(_obj_0) -- 2031
				if "table" == _type_1 or "userdata" == _type_1 then -- 2031
					content = _obj_0.content -- 2031
				end -- 2031
			end -- 2031
			if path ~= nil and content ~= nil then -- 2031
				if Content:saveAsync(path, content) then -- 2032
					do -- 2033
						local _exp_0 = Path:getExt(path) -- 2033
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2033
							if '' == Path:getExt(Path:getName(path)) then -- 2034
								local resultCodes = compileFileAsync(path, content) -- 2035
								buildSucceeded = resultCodes ~= nil -- 2036
								return { -- 2037
									success = true, -- 2037
									resultCodes = resultCodes -- 2037
								} -- 2037
							end -- 2034
						end -- 2033
					end -- 2033
					buildSucceeded = true -- 2038
					return { -- 2039
						success = true -- 2039
					} -- 2039
				end -- 2032
			end -- 2031
		end -- 2031
	end -- 2031
	return { -- 2027
		success = false -- 2027
	} -- 2027
end) -- 2027
local getWaProjectDirFromFile = nil -- 2041
HttpServer:postSchedule("/build", function(req) -- 2043
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2044
	local buildSucceeded = false -- 2045
	local _ <close> = setmetatable({ }, { -- 2046
		__close = function() -- 2046
			return finishUpdate(buildSucceeded) -- 2046
		end -- 2046
	}) -- 2046
	do -- 2047
		local _type_0 = type(req) -- 2047
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2047
		if _tab_0 then -- 2047
			local path -- 2047
			do -- 2047
				local _obj_0 = req.body -- 2047
				local _type_1 = type(_obj_0) -- 2047
				if "table" == _type_1 or "userdata" == _type_1 then -- 2047
					path = _obj_0.path -- 2047
				end -- 2047
			end -- 2047
			if path ~= nil then -- 2047
				local projectRoot = req.body.projectRoot -- 2048
				if Content:isdir(path) then -- 2049
					local projDir = getWaProjectDirFromFile(path) -- 2050
					if projDir then -- 2050
						local message = Wasm:buildWaAsync(projDir) -- 2051
						if message == "" then -- 2052
							return { -- 2053
								success = true -- 2053
							} -- 2053
						else -- 2055
							return { -- 2055
								success = false, -- 2055
								message = message -- 2055
							} -- 2055
						end -- 2052
					end -- 2050
				end -- 2049
				local _exp_0 = Path:getExt(path) -- 2056
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2057
					if '' == Path:getExt(Path:getName(path)) then -- 2058
						local content = Content:loadAsync(path) -- 2059
						if content then -- 2059
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2060
							if resultCodes then -- 2060
								buildSucceeded = true -- 2061
								return { -- 2062
									success = true, -- 2062
									resultCodes = resultCodes -- 2062
								} -- 2062
							end -- 2060
						end -- 2059
					end -- 2058
				elseif "wa" == _exp_0 then -- 2063
					local projDir = getWaProjectDirFromFile(path) -- 2064
					if projDir then -- 2064
						local message = Wasm:buildWaAsync(projDir) -- 2065
						if message == "" then -- 2066
							return { -- 2067
								success = true -- 2067
							} -- 2067
						else -- 2069
							return { -- 2069
								success = false, -- 2069
								message = message -- 2069
							} -- 2069
						end -- 2066
					else -- 2071
						return { -- 2071
							success = false, -- 2071
							message = 'Wa file needs a project' -- 2071
						} -- 2071
					end -- 2064
				end -- 2056
			end -- 2047
		end -- 2047
	end -- 2047
	return { -- 2043
		success = false -- 2043
	} -- 2043
end) -- 2043
local extentionLevels = { -- 2074
	vs = 2, -- 2074
	bl = 2, -- 2075
	ts = 1, -- 2076
	tsx = 1, -- 2077
	tl = 1, -- 2078
	yue = 1, -- 2079
	xml = 1, -- 2080
	lua = 0 -- 2081
} -- 2073
local visitAssets -- 2083
visitAssets = function(path, workspace, builtin, recursive) -- 2083
	if recursive == nil then -- 2083
		recursive = true -- 2083
	end -- 2083
	local children = nil -- 2084
	local dirs = Content:getDirs(path) -- 2085
	for _index_0 = 1, #dirs do -- 2086
		local dir = dirs[_index_0] -- 2086
		if workspace then -- 2087
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 2088
				goto _continue_0 -- 2089
			end -- 2088
		elseif dir == ".git" then -- 2090
			goto _continue_0 -- 2091
		end -- 2087
		if not children then -- 2092
			children = { } -- 2092
		end -- 2092
		local dirPath = Path(path, dir) -- 2093
		if recursive then -- 2094
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2095
		else -- 2097
			children[#children + 1] = { -- 2098
				key = dirPath, -- 2098
				dir = true, -- 2099
				title = dir, -- 2100
				builtin = builtin, -- 2101
				isLeaf = false -- 2102
			} -- 2097
		end -- 2094
		::_continue_0:: -- 2087
	end -- 2086
	local files = Content:getFiles(path) -- 2104
	local names = { } -- 2105
	for _index_0 = 1, #files do -- 2106
		local file = files[_index_0] -- 2106
		if (".DS_Store" == file) then -- 2107
			goto _continue_1 -- 2108
		end -- 2107
		local name = Path:getName(file) -- 2109
		local ext = names[name] -- 2110
		if ext then -- 2110
			local lv1 -- 2111
			do -- 2111
				local _exp_0 = extentionLevels[ext] -- 2111
				if _exp_0 ~= nil then -- 2111
					lv1 = _exp_0 -- 2111
				else -- 2111
					lv1 = -1 -- 2111
				end -- 2111
			end -- 2111
			ext = Path:getExt(file) -- 2112
			local lv2 -- 2113
			do -- 2113
				local _exp_0 = extentionLevels[ext] -- 2113
				if _exp_0 ~= nil then -- 2113
					lv2 = _exp_0 -- 2113
				else -- 2113
					lv2 = -1 -- 2113
				end -- 2113
			end -- 2113
			if lv2 > lv1 then -- 2114
				names[name] = ext -- 2115
			elseif lv2 == lv1 then -- 2116
				names[name .. '.' .. ext] = "" -- 2117
			end -- 2114
		else -- 2119
			ext = Path:getExt(file) -- 2119
			if not extentionLevels[ext] then -- 2120
				names[file] = "" -- 2121
			else -- 2123
				names[name] = ext -- 2123
			end -- 2120
		end -- 2110
		::_continue_1:: -- 2107
	end -- 2106
	do -- 2124
		local _accum_0 = { } -- 2124
		local _len_0 = 1 -- 2124
		for name, ext in pairs(names) do -- 2124
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2124
			_len_0 = _len_0 + 1 -- 2124
		end -- 2124
		files = _accum_0 -- 2124
	end -- 2124
	for _index_0 = 1, #files do -- 2125
		local file = files[_index_0] -- 2125
		if not children then -- 2126
			children = { } -- 2126
		end -- 2126
		children[#children + 1] = { -- 2128
			key = Path(path, file), -- 2128
			dir = false, -- 2129
			title = file, -- 2130
			builtin = builtin -- 2131
		} -- 2127
	end -- 2125
	if children then -- 2133
		table.sort(children, function(a, b) -- 2134
			if a.dir == b.dir then -- 2135
				return a.title < b.title -- 2136
			else -- 2138
				return a.dir -- 2138
			end -- 2135
		end) -- 2134
	end -- 2133
	return { -- 2140
		key = path, -- 2140
		dir = true, -- 2141
		title = Path:getFilename(path), -- 2142
		builtin = builtin, -- 2143
		isLeaf = not children, -- 2144
		children = children -- 2145
	} -- 2139
end -- 2083
HttpServer:post("/assets/children", function(req) -- 2148
	do -- 2149
		local _type_0 = type(req) -- 2149
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2149
		if _tab_0 then -- 2149
			local path -- 2149
			do -- 2149
				local _obj_0 = req.body -- 2149
				local _type_1 = type(_obj_0) -- 2149
				if "table" == _type_1 or "userdata" == _type_1 then -- 2149
					path = _obj_0.path -- 2149
				end -- 2149
			end -- 2149
			if path ~= nil then -- 2149
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2150
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2151
					return { -- 2151
						success = false -- 2151
					} -- 2151
				end -- 2151
				local node = visitAssets(path, workspace, builtin, false) -- 2152
				return { -- 2153
					success = true, -- 2153
					children = node.children or { } -- 2153
				} -- 2153
			end -- 2149
		end -- 2149
	end -- 2149
	return { -- 2148
		success = false -- 2148
	} -- 2148
end) -- 2148
HttpServer:post("/assets/files", function(req) -- 2155
	do -- 2156
		local _type_0 = type(req) -- 2156
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2156
		if _tab_0 then -- 2156
			local path -- 2156
			do -- 2156
				local _obj_0 = req.body -- 2156
				local _type_1 = type(_obj_0) -- 2156
				if "table" == _type_1 or "userdata" == _type_1 then -- 2156
					path = _obj_0.path -- 2156
				end -- 2156
			end -- 2156
			if path ~= nil then -- 2156
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2157
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2158
				if not (workspace or builtin) then -- 2159
					return { -- 2159
						success = false -- 2159
					} -- 2159
				end -- 2159
				if not (Content:exist(path) and Content:isdir(path)) then -- 2160
					return { -- 2160
						success = false -- 2160
					} -- 2160
				end -- 2160
				local globs = { -- 2161
					"**", -- 2161
					"!**/.DS_Store" -- 2161
				} -- 2161
				if workspace then -- 2162
					globs = { -- 2164
						"**", -- 2164
						"!**/.DS_Store", -- 2164
						"!**/.upload/**", -- 2165
						"!**/.download/**", -- 2165
						"!**/.www/**", -- 2166
						"!**/.build/**", -- 2166
						"!**/.git/**", -- 2167
						"!**/.cache/**", -- 2167
						"!**/node_modules/**" -- 2168
					} -- 2163
				end -- 2162
				local files -- 2170
				do -- 2170
					local _accum_0 = { } -- 2170
					local _len_0 = 1 -- 2170
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2170
					for _index_0 = 1, #_list_0 do -- 2170
						local file = _list_0[_index_0] -- 2170
						_accum_0[_len_0] = Path(path, file) -- 2170
						_len_0 = _len_0 + 1 -- 2170
					end -- 2170
					files = _accum_0 -- 2170
				end -- 2170
				return { -- 2171
					success = true, -- 2171
					files = files -- 2171
				} -- 2171
			end -- 2156
		end -- 2156
	end -- 2156
	return { -- 2155
		success = false -- 2155
	} -- 2155
end) -- 2155
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2212
	local _tab_0 = { -- 2212
		{ -- 2213
			key = Path(Content.assetPath), -- 2213
			dir = true, -- 2214
			builtin = true, -- 2215
			title = zh and "内置资源" or "Built-in", -- 2216
			children = builtinChildren -- 2217
		} -- 2212
	} -- 2219
	local _obj_0 = workspace.children or { } -- 2219
	local _idx_0 = #_tab_0 + 1 -- 2219
	for _index_0 = 1, #_obj_0 do -- 2219
		local _value_0 = _obj_0[_index_0] -- 2219
		_tab_0[_idx_0] = _value_0 -- 2219
		_idx_0 = _idx_0 + 1 -- 2219
	end -- 2219
	return _tab_0 -- 2212
end -- 2212
HttpServer:post("/assets", function() -- 2173
	local Entry = require("Script.Dev.Entry") -- 2174
	local engineDev = Entry.getEngineDev() -- 2175
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2176
	local zh = (App.locale:match("^zh") ~= nil) -- 2177
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2178
	readme.title = zh and "说明文档" or "Readme" -- 2179
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2180
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2181
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2182
	tools.title = zh and "开发工具" or "Tools" -- 2183
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2184
	font.title = zh and "字体" or "Font" -- 2185
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2186
	lib.title = zh and "程序库" or "Lib" -- 2187
	if engineDev then -- 2188
		local _list_0 = lib.children -- 2189
		for _index_0 = 1, #_list_0 do -- 2189
			local child = _list_0[_index_0] -- 2189
			if not (child.title == "Dora") then -- 2190
				goto _continue_0 -- 2190
			end -- 2190
			local title = zh and "zh-Hans" or "en" -- 2191
			do -- 2192
				local _accum_0 = { } -- 2192
				local _len_0 = 1 -- 2192
				local _list_1 = child.children -- 2192
				for _index_1 = 1, #_list_1 do -- 2192
					local c = _list_1[_index_1] -- 2192
					if c.title ~= title then -- 2192
						_accum_0[_len_0] = c -- 2192
						_len_0 = _len_0 + 1 -- 2192
					end -- 2192
				end -- 2192
				child.children = _accum_0 -- 2192
			end -- 2192
			break -- 2193
			::_continue_0:: -- 2190
		end -- 2189
	else -- 2195
		local _accum_0 = { } -- 2195
		local _len_0 = 1 -- 2195
		local _list_0 = lib.children -- 2195
		for _index_0 = 1, #_list_0 do -- 2195
			local child = _list_0[_index_0] -- 2195
			if child.title ~= "Dora" then -- 2195
				_accum_0[_len_0] = child -- 2195
				_len_0 = _len_0 + 1 -- 2195
			end -- 2195
		end -- 2195
		lib.children = _accum_0 -- 2195
	end -- 2188
	local builtinChildren = { -- 2196
		readme, -- 2196
		apiDoc, -- 2196
		tools, -- 2196
		font, -- 2196
		lib -- 2196
	} -- 2196
	if engineDev then -- 2197
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2198
		do -- 2199
			local _obj_0 = dev.children -- 2199
			_obj_0[#_obj_0 + 1] = { -- 2200
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2200
				dir = false, -- 2201
				builtin = true, -- 2202
				title = "init.yue" -- 2203
			} -- 2199
		end -- 2199
		builtinChildren[#builtinChildren + 1] = dev -- 2205
	end -- 2197
	return { -- 2207
		key = Content.writablePath, -- 2207
		dir = true, -- 2208
		root = true, -- 2209
		title = "Assets", -- 2210
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2211
	} -- 2206
end) -- 2173
HttpServer:post("/entry/list", function(req) -- 2223
	local Entry = require("Script.Dev.Entry") -- 2224
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2225
	res.success = true -- 2226
	return res -- 2227
end) -- 2223
HttpServer:post("/run/status", function() -- 2229
	local Entry = require("Script.Dev.Entry") -- 2230
	return Entry.getCurrentEntryStatus() -- 2231
end) -- 2229
HttpServer:postSchedule("/run", function(req) -- 2233
	do -- 2234
		local _type_0 = type(req) -- 2234
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2234
		if _tab_0 then -- 2234
			local file -- 2234
			do -- 2234
				local _obj_0 = req.body -- 2234
				local _type_1 = type(_obj_0) -- 2234
				if "table" == _type_1 or "userdata" == _type_1 then -- 2234
					file = _obj_0.file -- 2234
				end -- 2234
			end -- 2234
			local asProj -- 2234
			do -- 2234
				local _obj_0 = req.body -- 2234
				local _type_1 = type(_obj_0) -- 2234
				if "table" == _type_1 or "userdata" == _type_1 then -- 2234
					asProj = _obj_0.asProj -- 2234
				end -- 2234
			end -- 2234
			if file ~= nil and asProj ~= nil then -- 2234
				if not Content:isAbsolutePath(file) then -- 2235
					local devFile = Path(Content.writablePath, file) -- 2236
					if Content:exist(devFile) then -- 2237
						file = devFile -- 2237
					end -- 2237
				end -- 2235
				local Entry = require("Script.Dev.Entry") -- 2238
				local workDir -- 2239
				if asProj then -- 2240
					local projectRoot = req.body.projectRoot -- 2241
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2242
						workDir = projectRoot -- 2243
					else -- 2245
						workDir = getProjectDirFromFile(file) -- 2245
					end -- 2242
					if workDir then -- 2246
						Entry.allClear() -- 2247
						local target = Path(workDir, "init") -- 2248
						local success, err = Entry.enterEntryAsync({ -- 2249
							entryName = "Project", -- 2249
							fileName = target, -- 2249
							workDir = workDir, -- 2249
							projectRoot = workDir, -- 2249
							runKind = "project" -- 2249
						}) -- 2249
						target = Path:getName(Path:getPath(target)) -- 2250
						return { -- 2251
							success = success, -- 2251
							target = target, -- 2251
							err = err -- 2251
						} -- 2251
					end -- 2246
				else -- 2253
					workDir = getProjectDirFromFile(file) -- 2253
					if not workDir and Path:getExt(file) == "wasm" then -- 2254
						local parent = Path:getPath(file) -- 2255
						if Content:exist(Path(parent, "wa.mod")) then -- 2256
							workDir = parent -- 2257
						end -- 2256
					end -- 2254
				end -- 2240
				Entry.allClear() -- 2258
				file = Path:replaceExt(file, "") -- 2259
				local entry = { -- 2261
					entryName = Path:getName(file), -- 2261
					fileName = file, -- 2262
					runKind = "file" -- 2263
				} -- 2260
				if workDir then -- 2264
					entry.workDir = workDir -- 2265
					entry.projectRoot = workDir -- 2266
				end -- 2264
				local success, err = Entry.enterEntryAsync(entry) -- 2267
				return { -- 2268
					success = success, -- 2268
					err = err -- 2268
				} -- 2268
			end -- 2234
		end -- 2234
	end -- 2234
	return { -- 2233
		success = false -- 2233
	} -- 2233
end) -- 2233
local _anon_func_7 = function(result) -- 2310
	if result.success then -- 2310
		return nil -- 2310
	else -- 2310
		return "PREVIEW_FAILED" -- 2310
	end -- 2310
end -- 2310
HttpServer:postSchedule("/agent/preview", function(req) -- 2270
	local releaseAgent = AgentHost.acquire() -- 2271
	local _ <close> = setmetatable({ }, { -- 2272
		__close = function() -- 2272
			return releaseAgent() -- 2272
		end -- 2272
	}) -- 2272
	do -- 2273
		local _type_0 = type(req) -- 2273
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2273
		if _tab_0 then -- 2273
			local projectRoot -- 2273
			do -- 2273
				local _obj_0 = req.body -- 2273
				local _type_1 = type(_obj_0) -- 2273
				if "table" == _type_1 or "userdata" == _type_1 then -- 2273
					projectRoot = _obj_0.projectRoot -- 2273
				end -- 2273
			end -- 2273
			if projectRoot ~= nil then -- 2273
				if not getProjectSourceRoot(projectRoot) then -- 2274
					return { -- 2274
						success = false, -- 2274
						code = "INVALID_PROJECT", -- 2274
						message = "projectRoot must be an existing absolute directory" -- 2274
					} -- 2274
				end -- 2274
				local entryFile = req.body.entry or "init.lua" -- 2275
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2276
					return { -- 2276
						success = false, -- 2276
						code = "INVALID_ENTRY", -- 2276
						message = "entry must be a non-empty project-relative path" -- 2276
					} -- 2276
				end -- 2276
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2277
					0.5 -- 2277
				} -- 2277
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2278
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2279
					return { -- 2279
						success = false, -- 2279
						code = "INVALID_QUEUE_TIMEOUT", -- 2279
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2279
					} -- 2279
				end -- 2279
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2280
				local AgentOperation = require("Agent.Tool.Operation") -- 2281
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2282
				local requestId = AgentOperation.createOperationId() -- 2283
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2284
				if not enqueued.success then -- 2285
					return { -- 2285
						success = false, -- 2285
						code = "ENTRY_QUEUE_REJECTED", -- 2285
						message = enqueued.message -- 2285
					} -- 2285
				end -- 2285
				local queuedAt = App.runningTime -- 2286
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2287
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2288
						local state = agentEntryRunQueue:get(requestId) -- 2289
						agentEntryRunQueue:cancel(requestId) -- 2290
						return { -- 2292
							success = false, -- 2292
							code = "ENTRY_QUEUE_TIMEOUT", -- 2293
							message = "timed out waiting for the Dora entry runtime", -- 2294
							requestId = requestId, -- 2295
							queuePosition = state.position -- 2296
						} -- 2291
					end -- 2288
					sleep() -- 2297
				end -- 2287
				local queueWaitSeconds = App.runningTime - queuedAt -- 2298
				local _ <close> = setmetatable({ }, { -- 2299
					__close = function() -- 2299
						return agentEntryRunQueue:release(requestId) -- 2299
					end -- 2299
				}) -- 2299
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2300
				local Entry = require("Script.Dev.Entry") -- 2301
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2303
					workDir = projectRoot, -- 2303
					operationId = requestId, -- 2304
					print = function() end -- 2305
				}, Entry) -- 2302
				local result = preview({ -- 2307
					entry = entryFile, -- 2307
					captureAtSeconds = captureAtSeconds -- 2307
				}) -- 2307
				return { -- 2309
					success = result.success, -- 2309
					code = _anon_func_7(result), -- 2310
					message = result.message, -- 2311
					requestId = requestId, -- 2312
					queueWaitSeconds = queueWaitSeconds, -- 2313
					interruptedUserRun = result.interruptedUserRun, -- 2314
					files = result.files, -- 2315
					frames = result.frames -- 2316
				} -- 2308
			end -- 2273
		end -- 2273
	end -- 2273
	return { -- 2270
		success = false, -- 2270
		message = "invalid call" -- 2270
	} -- 2270
end) -- 2270
HttpServer:postSchedule("/agent/command", function(req) -- 2318
	local releaseAgent = AgentHost.acquire() -- 2319
	local _ <close> = setmetatable({ }, { -- 2320
		__close = function() -- 2320
			return releaseAgent() -- 2320
		end -- 2320
	}) -- 2320
	do -- 2321
		local _type_0 = type(req) -- 2321
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2321
		if _tab_0 then -- 2321
			local body = req.body -- 2321
			if body ~= nil then -- 2321
				local projectRoot = body.projectRoot -- 2322
				if not getProjectSourceRoot(projectRoot) then -- 2323
					return { -- 2323
						success = false, -- 2323
						code = "INVALID_PROJECT", -- 2323
						message = "projectRoot must be an existing absolute directory" -- 2323
					} -- 2323
				end -- 2323
				local AgentValidation = require("Agent.Tool.Validation") -- 2324
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2325
				if not validated.success then -- 2326
					return { -- 2326
						success = false, -- 2326
						code = "INVALID_COMMAND", -- 2326
						message = validated.message -- 2326
					} -- 2326
				end -- 2326
				local input = validated.value -- 2327
				local AgentCommand = require("Agent.Tool.Command") -- 2328
				local result = nil -- 2329
				local failure = nil -- 2330
				local promise = AgentCommand.executeCommand({ -- 2332
					workDir = projectRoot, -- 2332
					mode = input.mode, -- 2333
					code = input.code, -- 2334
					command = input.command, -- 2335
					cwd = input.cwd, -- 2336
					timeoutSeconds = input.timeoutSeconds -- 2337
				}) -- 2331
				promise:addCallbacks((function(_, value) -- 2338
					result = value -- 2338
				end), (function(_, err) -- 2338
					failure = tostring(err) -- 2338
				end)) -- 2338
				wait(function() -- 2339
					return result ~= nil or failure ~= nil -- 2339
				end) -- 2339
				if failure then -- 2340
					return { -- 2340
						success = false, -- 2340
						code = "COMMAND_BRIDGE_FAILED", -- 2340
						message = failure -- 2340
					} -- 2340
				end -- 2340
				if not result.success then -- 2341
					result.code = "COMMAND_FAILED" -- 2342
				end -- 2341
				return result -- 2343
			end -- 2321
		end -- 2321
	end -- 2321
	return { -- 2318
		success = false, -- 2318
		code = "INVALID_COMMAND", -- 2318
		message = "invalid call" -- 2318
	} -- 2318
end) -- 2318
HttpServer:postSchedule("/stop", function() -- 2345
	local Entry = require("Script.Dev.Entry") -- 2346
	return { -- 2347
		success = Entry.stop() -- 2347
	} -- 2347
end) -- 2345
local minifyAsync -- 2349
minifyAsync = function(sourcePath, minifyPath) -- 2349
	if not Content:exist(sourcePath) then -- 2350
		return -- 2350
	end -- 2350
	local Entry = require("Script.Dev.Entry") -- 2351
	local errors = { } -- 2352
	local files = Entry.getAllFiles(sourcePath, { -- 2353
		"lua" -- 2353
	}, true) -- 2353
	do -- 2354
		local _accum_0 = { } -- 2354
		local _len_0 = 1 -- 2354
		for _index_0 = 1, #files do -- 2354
			local file = files[_index_0] -- 2354
			if file:sub(1, 1) ~= '.' then -- 2354
				_accum_0[_len_0] = file -- 2354
				_len_0 = _len_0 + 1 -- 2354
			end -- 2354
		end -- 2354
		files = _accum_0 -- 2354
	end -- 2354
	local paths -- 2355
	do -- 2355
		local _tbl_0 = { } -- 2355
		for _index_0 = 1, #files do -- 2355
			local file = files[_index_0] -- 2355
			_tbl_0[Path:getPath(file)] = true -- 2355
		end -- 2355
		paths = _tbl_0 -- 2355
	end -- 2355
	for path in pairs(paths) do -- 2356
		Content:mkdir(Path(minifyPath, path)) -- 2356
	end -- 2356
	local _ <close> = setmetatable({ }, { -- 2357
		__close = function() -- 2357
			package.loaded["luaminify.FormatMini"] = nil -- 2358
			package.loaded["luaminify.ParseLua"] = nil -- 2359
			package.loaded["luaminify.Scope"] = nil -- 2360
			package.loaded["luaminify.Util"] = nil -- 2361
		end -- 2357
	}) -- 2357
	local FormatMini -- 2362
	do -- 2362
		local _obj_0 = require("luaminify") -- 2362
		FormatMini = _obj_0.FormatMini -- 2362
	end -- 2362
	local fileCount = #files -- 2363
	local count = 0 -- 2364
	for _index_0 = 1, #files do -- 2365
		local file = files[_index_0] -- 2365
		thread(function() -- 2366
			local _ <close> = setmetatable({ }, { -- 2367
				__close = function() -- 2367
					count = count + 1 -- 2367
				end -- 2367
			}) -- 2367
			local input = Path(sourcePath, file) -- 2368
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2369
			if Content:exist(input) then -- 2370
				local sourceCodes = Content:loadAsync(input) -- 2371
				local res, err = FormatMini(sourceCodes) -- 2372
				if res then -- 2373
					Content:saveAsync(output, res) -- 2374
					return print("Minify " .. tostring(file)) -- 2375
				else -- 2377
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2377
				end -- 2373
			else -- 2379
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2379
			end -- 2370
		end) -- 2366
		sleep() -- 2380
	end -- 2365
	wait(function() -- 2381
		return count == fileCount -- 2381
	end) -- 2381
	if #errors > 0 then -- 2382
		print(table.concat(errors, '\n')) -- 2383
	end -- 2382
	print("Obfuscation done.") -- 2384
	return files -- 2385
end -- 2349
local zipping = false -- 2387
HttpServer:postSchedule("/zip", function(req) -- 2389
	do -- 2390
		local _type_0 = type(req) -- 2390
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2390
		if _tab_0 then -- 2390
			local path -- 2390
			do -- 2390
				local _obj_0 = req.body -- 2390
				local _type_1 = type(_obj_0) -- 2390
				if "table" == _type_1 or "userdata" == _type_1 then -- 2390
					path = _obj_0.path -- 2390
				end -- 2390
			end -- 2390
			local zipFile -- 2390
			do -- 2390
				local _obj_0 = req.body -- 2390
				local _type_1 = type(_obj_0) -- 2390
				if "table" == _type_1 or "userdata" == _type_1 then -- 2390
					zipFile = _obj_0.zipFile -- 2390
				end -- 2390
			end -- 2390
			local obfuscated -- 2390
			do -- 2390
				local _obj_0 = req.body -- 2390
				local _type_1 = type(_obj_0) -- 2390
				if "table" == _type_1 or "userdata" == _type_1 then -- 2390
					obfuscated = _obj_0.obfuscated -- 2390
				end -- 2390
			end -- 2390
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2390
				if zipping then -- 2391
					goto failed -- 2391
				end -- 2391
				zipping = true -- 2392
				local _ <close> = setmetatable({ }, { -- 2393
					__close = function() -- 2393
						zipping = false -- 2393
					end -- 2393
				}) -- 2393
				if not Content:exist(path) then -- 2394
					goto failed -- 2394
				end -- 2394
				Content:mkdir(Path:getPath(zipFile)) -- 2395
				if obfuscated then -- 2396
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2397
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2398
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2399
					Content:remove(scriptPath) -- 2400
					Content:remove(obfuscatedPath) -- 2401
					Content:remove(tempPath) -- 2402
					Content:mkdir(scriptPath) -- 2403
					Content:mkdir(obfuscatedPath) -- 2404
					Content:mkdir(tempPath) -- 2405
					if not Content:copyAsync(path, tempPath) then -- 2406
						goto failed -- 2406
					end -- 2406
					local Entry = require("Script.Dev.Entry") -- 2407
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2408
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2409
						"tl", -- 2409
						"yue", -- 2409
						"lua", -- 2409
						"ts", -- 2409
						"tsx", -- 2409
						"vs", -- 2409
						"bl", -- 2409
						"xml", -- 2409
						"wa", -- 2409
						"mod" -- 2409
					}, true) -- 2409
					for _index_0 = 1, #scriptFiles do -- 2410
						local file = scriptFiles[_index_0] -- 2410
						Content:remove(Path(tempPath, file)) -- 2411
					end -- 2410
					for _index_0 = 1, #luaFiles do -- 2412
						local file = luaFiles[_index_0] -- 2412
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2413
					end -- 2412
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2414
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2415
					end) then -- 2414
						goto failed -- 2414
					end -- 2414
					return { -- 2416
						success = true -- 2416
					} -- 2416
				else -- 2418
					return { -- 2418
						success = Content:zipAsync(path, zipFile, function(file) -- 2418
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2419
						end) -- 2418
					} -- 2418
				end -- 2396
			end -- 2390
		end -- 2390
	end -- 2390
	::failed:: -- 2420
	return { -- 2389
		success = false -- 2389
	} -- 2389
end) -- 2389
HttpServer:postSchedule("/unzip", function(req) -- 2422
	do -- 2423
		local _type_0 = type(req) -- 2423
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2423
		if _tab_0 then -- 2423
			local zipFile -- 2423
			do -- 2423
				local _obj_0 = req.body -- 2423
				local _type_1 = type(_obj_0) -- 2423
				if "table" == _type_1 or "userdata" == _type_1 then -- 2423
					zipFile = _obj_0.zipFile -- 2423
				end -- 2423
			end -- 2423
			local path -- 2423
			do -- 2423
				local _obj_0 = req.body -- 2423
				local _type_1 = type(_obj_0) -- 2423
				if "table" == _type_1 or "userdata" == _type_1 then -- 2423
					path = _obj_0.path -- 2423
				end -- 2423
			end -- 2423
			if zipFile ~= nil and path ~= nil then -- 2423
				return { -- 2424
					success = Content:unzipAsync(zipFile, path, function(file) -- 2424
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2425
					end) -- 2424
				} -- 2424
			end -- 2423
		end -- 2423
	end -- 2423
	return { -- 2422
		success = false -- 2422
	} -- 2422
end) -- 2422
HttpServer:post("/editing-info", function(req) -- 2427
	local Entry = require("Script.Dev.Entry") -- 2428
	local config = Entry.getConfig() -- 2429
	local _type_0 = type(req) -- 2430
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2430
	local _match_0 = false -- 2430
	if _tab_0 then -- 2430
		local editingInfo -- 2430
		do -- 2430
			local _obj_0 = req.body -- 2430
			local _type_1 = type(_obj_0) -- 2430
			if "table" == _type_1 or "userdata" == _type_1 then -- 2430
				editingInfo = _obj_0.editingInfo -- 2430
			end -- 2430
		end -- 2430
		if editingInfo ~= nil then -- 2430
			_match_0 = true -- 2430
			config.editingInfo = editingInfo -- 2431
			return { -- 2432
				success = true -- 2432
			} -- 2432
		end -- 2430
	end -- 2430
	if not _match_0 then -- 2430
		if not (config.editingInfo ~= nil) then -- 2434
			local folder -- 2435
			if App.locale:match('^zh') then -- 2435
				folder = 'zh-Hans' -- 2435
			else -- 2435
				folder = 'en' -- 2435
			end -- 2435
			config.editingInfo = json.encode({ -- 2437
				index = 0, -- 2437
				files = { -- 2439
					{ -- 2440
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2440
						title = "welcome.md" -- 2441
					} -- 2439
				} -- 2438
			}) -- 2436
		end -- 2434
		return { -- 2445
			success = true, -- 2445
			editingInfo = config.editingInfo -- 2445
		} -- 2445
	end -- 2430
end) -- 2427
HttpServer:post("/command", function(req) -- 2447
	do -- 2448
		local _type_0 = type(req) -- 2448
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2448
		if _tab_0 then -- 2448
			local code -- 2448
			do -- 2448
				local _obj_0 = req.body -- 2448
				local _type_1 = type(_obj_0) -- 2448
				if "table" == _type_1 or "userdata" == _type_1 then -- 2448
					code = _obj_0.code -- 2448
				end -- 2448
			end -- 2448
			local log -- 2448
			do -- 2448
				local _obj_0 = req.body -- 2448
				local _type_1 = type(_obj_0) -- 2448
				if "table" == _type_1 or "userdata" == _type_1 then -- 2448
					log = _obj_0.log -- 2448
				end -- 2448
			end -- 2448
			if code ~= nil and log ~= nil then -- 2448
				emit("AppCommand", code, log) -- 2449
				return { -- 2450
					success = true -- 2450
				} -- 2450
			end -- 2448
		end -- 2448
	end -- 2448
	return { -- 2447
		success = false -- 2447
	} -- 2447
end) -- 2447
HttpServer:post("/log/save", function() -- 2452
	local folder = ".download" -- 2453
	local fullLogFile = "dora_full_logs.txt" -- 2454
	local fullFolder = Path(Content.writablePath, folder) -- 2455
	Content:mkdir(fullFolder) -- 2456
	local logPath = Path(fullFolder, fullLogFile) -- 2457
	if App:saveLog(logPath) then -- 2458
		return { -- 2459
			success = true, -- 2459
			path = Path(folder, fullLogFile) -- 2459
		} -- 2459
	end -- 2458
	return { -- 2452
		success = false -- 2452
	} -- 2452
end) -- 2452
local tailLines -- 2461
tailLines = function(text, count) -- 2461
	local lines = { } -- 2462
	text = text:gsub("\r\n", "\n") -- 2463
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2464
		lines[#lines + 1] = line -- 2465
	end -- 2464
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2466
		table.remove(lines) -- 2467
	end -- 2466
	local start = math.max(1, #lines - count + 1) -- 2468
	local out = { } -- 2469
	for i = start, #lines do -- 2470
		out[#out + 1] = lines[i] -- 2471
	end -- 2470
	return table.concat(out, "\n") -- 2472
end -- 2461
HttpServer:post("/log", function(req) -- 2474
	local count = 100 -- 2475
	if req and req.body and req.body.count ~= nil then -- 2476
		count = req.body.count -- 2477
	end -- 2476
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2478
		return { -- 2479
			success = false, -- 2479
			message = "count must be a positive integer" -- 2479
		} -- 2479
	end -- 2478
	local folder = ".download" -- 2480
	local fullLogFile = "dora_full_logs.txt" -- 2481
	local fullFolder = Path(Content.writablePath, folder) -- 2482
	Content:mkdir(fullFolder) -- 2483
	local logPath = Path(fullFolder, fullLogFile) -- 2484
	if App:saveLog(logPath) then -- 2485
		local text = Content:load(logPath) -- 2486
		if text then -- 2487
			return { -- 2488
				success = true, -- 2488
				log = tailLines(text, count) -- 2488
			} -- 2488
		else -- 2490
			return { -- 2490
				success = false, -- 2490
				message = "failed to read log" -- 2490
			} -- 2490
		end -- 2487
	else -- 2492
		return { -- 2492
			success = false, -- 2492
			message = "failed to save log" -- 2492
		} -- 2492
	end -- 2485
	return { -- 2474
		success = false -- 2474
	} -- 2474
end) -- 2474
HttpServer:post("/yarn/check", function(req) -- 2494
	local yarncompile = require("yarncompile") -- 2495
	do -- 2496
		local _type_0 = type(req) -- 2496
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2496
		if _tab_0 then -- 2496
			local code -- 2496
			do -- 2496
				local _obj_0 = req.body -- 2496
				local _type_1 = type(_obj_0) -- 2496
				if "table" == _type_1 or "userdata" == _type_1 then -- 2496
					code = _obj_0.code -- 2496
				end -- 2496
			end -- 2496
			if code ~= nil then -- 2496
				local jsonObject = json.decode(code) -- 2497
				if jsonObject then -- 2497
					local errors = { } -- 2498
					local _list_0 = jsonObject.nodes -- 2499
					for _index_0 = 1, #_list_0 do -- 2499
						local node = _list_0[_index_0] -- 2499
						local title, body = node.title, node.body -- 2500
						local luaCode, err = yarncompile(body) -- 2501
						if not luaCode then -- 2501
							errors[#errors + 1] = title .. ":" .. err -- 2502
						end -- 2501
					end -- 2499
					return { -- 2503
						success = true, -- 2503
						syntaxError = table.concat(errors, "\n\n") -- 2503
					} -- 2503
				end -- 2497
			end -- 2496
		end -- 2496
	end -- 2496
	return { -- 2494
		success = false -- 2494
	} -- 2494
end) -- 2494
HttpServer:post("/yarn/check-file", function(req) -- 2505
	local yarncompile = require("yarncompile") -- 2506
	do -- 2507
		local _type_0 = type(req) -- 2507
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2507
		if _tab_0 then -- 2507
			local code -- 2507
			do -- 2507
				local _obj_0 = req.body -- 2507
				local _type_1 = type(_obj_0) -- 2507
				if "table" == _type_1 or "userdata" == _type_1 then -- 2507
					code = _obj_0.code -- 2507
				end -- 2507
			end -- 2507
			if code ~= nil then -- 2507
				local res, _, err = yarncompile(code, true) -- 2508
				if not res then -- 2508
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2509
					return { -- 2510
						success = false, -- 2510
						message = message, -- 2510
						line = line, -- 2510
						column = column, -- 2510
						node = node -- 2510
					} -- 2510
				end -- 2508
			end -- 2507
		end -- 2507
	end -- 2507
	return { -- 2505
		success = true -- 2505
	} -- 2505
end) -- 2505
getWaProjectDirFromFile = function(file) -- 2512
	local current -- 2513
	if Content:isdir(file) then -- 2513
		current = file -- 2513
	else -- 2513
		current = Path:getPath(file) -- 2513
	end -- 2513
	if current == "" then -- 2514
		return nil -- 2514
	end -- 2514
	repeat -- 2515
		local modPath = Path(current, "wa.mod") -- 2516
		if Content:exist(modPath) then -- 2517
			return current, modPath -- 2518
		end -- 2517
		local parent = Path:getPath(current) -- 2519
		if parent == "" or parent == current then -- 2520
			break -- 2520
		end -- 2520
		current = parent -- 2521
	until false -- 2515
	return nil -- 2523
end -- 2512
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2525
	do -- 2526
		local _type_0 = type(req) -- 2526
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2526
		if _tab_0 then -- 2526
			local path -- 2526
			do -- 2526
				local _obj_0 = req.body -- 2526
				local _type_1 = type(_obj_0) -- 2526
				if "table" == _type_1 or "userdata" == _type_1 then -- 2526
					path = _obj_0.path -- 2526
				end -- 2526
			end -- 2526
			if path ~= nil then -- 2526
				local projDir = getWaProjectDirFromFile(path) -- 2527
				if projDir then -- 2527
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2528
					if not Content:exist(sourceDoraPath) then -- 2529
						return { -- 2530
							success = false, -- 2530
							message = "missing dora template" -- 2530
						} -- 2530
					end -- 2529
					local targetVendorPath = Path(projDir, "vendor") -- 2531
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2532
					if not Content:exist(targetVendorPath) then -- 2533
						if not Content:mkdir(targetVendorPath) then -- 2534
							return { -- 2535
								success = false, -- 2535
								message = "failed to create vendor folder" -- 2535
							} -- 2535
						end -- 2534
					elseif not Content:isdir(targetVendorPath) then -- 2536
						return { -- 2537
							success = false, -- 2537
							message = "vendor path is not a folder" -- 2537
						} -- 2537
					end -- 2533
					if Content:exist(targetDoraPath) then -- 2538
						if not Content:remove(targetDoraPath) then -- 2539
							return { -- 2540
								success = false, -- 2540
								message = "failed to remove old dora" -- 2540
							} -- 2540
						end -- 2539
					end -- 2538
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2541
						return { -- 2542
							success = false, -- 2542
							message = "failed to copy dora" -- 2542
						} -- 2542
					end -- 2541
					return { -- 2543
						success = true -- 2543
					} -- 2543
				else -- 2545
					return { -- 2545
						success = false, -- 2545
						message = 'Wa file needs a project' -- 2545
					} -- 2545
				end -- 2527
			end -- 2526
		end -- 2526
	end -- 2526
	return { -- 2525
		success = false, -- 2525
		message = "invalid call" -- 2525
	} -- 2525
end) -- 2525
HttpServer:postSchedule("/wa/build", function(req) -- 2547
	do -- 2548
		local _type_0 = type(req) -- 2548
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2548
		if _tab_0 then -- 2548
			local path -- 2548
			do -- 2548
				local _obj_0 = req.body -- 2548
				local _type_1 = type(_obj_0) -- 2548
				if "table" == _type_1 or "userdata" == _type_1 then -- 2548
					path = _obj_0.path -- 2548
				end -- 2548
			end -- 2548
			if path ~= nil then -- 2548
				local projDir = getWaProjectDirFromFile(path) -- 2549
				if projDir then -- 2549
					local message = Wasm:buildWaAsync(projDir) -- 2550
					if message == "" then -- 2551
						return { -- 2552
							success = true -- 2552
						} -- 2552
					else -- 2554
						return { -- 2554
							success = false, -- 2554
							message = message -- 2554
						} -- 2554
					end -- 2551
				else -- 2556
					return { -- 2556
						success = false, -- 2556
						message = 'Wa file needs a project' -- 2556
					} -- 2556
				end -- 2549
			end -- 2548
		end -- 2548
	end -- 2548
	return { -- 2557
		success = false, -- 2557
		message = 'failed to build' -- 2557
	} -- 2557
end) -- 2547
HttpServer:postSchedule("/wa/format", function(req) -- 2559
	do -- 2560
		local _type_0 = type(req) -- 2560
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2560
		if _tab_0 then -- 2560
			local file -- 2560
			do -- 2560
				local _obj_0 = req.body -- 2560
				local _type_1 = type(_obj_0) -- 2560
				if "table" == _type_1 or "userdata" == _type_1 then -- 2560
					file = _obj_0.file -- 2560
				end -- 2560
			end -- 2560
			if file ~= nil then -- 2560
				local code = Wasm:formatWaAsync(file) -- 2561
				if code == "" then -- 2562
					return { -- 2563
						success = false -- 2563
					} -- 2563
				else -- 2565
					return { -- 2565
						success = true, -- 2565
						code = code -- 2565
					} -- 2565
				end -- 2562
			end -- 2560
		end -- 2560
	end -- 2560
	return { -- 2566
		success = false -- 2566
	} -- 2566
end) -- 2559
HttpServer:postSchedule("/wa/create", function(req) -- 2568
	do -- 2569
		local _type_0 = type(req) -- 2569
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2569
		if _tab_0 then -- 2569
			local path -- 2569
			do -- 2569
				local _obj_0 = req.body -- 2569
				local _type_1 = type(_obj_0) -- 2569
				if "table" == _type_1 or "userdata" == _type_1 then -- 2569
					path = _obj_0.path -- 2569
				end -- 2569
			end -- 2569
			if path ~= nil then -- 2569
				if not Content:exist(Path:getPath(path)) then -- 2570
					return { -- 2571
						success = false, -- 2571
						message = "target path not existed" -- 2571
					} -- 2571
				end -- 2570
				if Content:exist(path) then -- 2572
					return { -- 2573
						success = false, -- 2573
						message = "target project folder existed" -- 2573
					} -- 2573
				end -- 2572
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2574
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2575
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2576
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2577
					return { -- 2580
						success = false, -- 2580
						message = "missing template project" -- 2580
					} -- 2580
				end -- 2577
				if not Content:mkdir(path) then -- 2581
					return { -- 2582
						success = false, -- 2582
						message = "failed to create project folder" -- 2582
					} -- 2582
				end -- 2581
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2583
					Content:remove(path) -- 2584
					return { -- 2585
						success = false, -- 2585
						message = "failed to copy template" -- 2585
					} -- 2585
				end -- 2583
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2586
					Content:remove(path) -- 2587
					return { -- 2588
						success = false, -- 2588
						message = "failed to copy template" -- 2588
					} -- 2588
				end -- 2586
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2589
					Content:remove(path) -- 2590
					return { -- 2591
						success = false, -- 2591
						message = "failed to copy template" -- 2591
					} -- 2591
				end -- 2589
				return { -- 2592
					success = true -- 2592
				} -- 2592
			end -- 2569
		end -- 2569
	end -- 2569
	return { -- 2568
		success = false, -- 2568
		message = "invalid call" -- 2568
	} -- 2568
end) -- 2568
local tsBuildGlobs = { -- 2595
	"**/*.ts", -- 2595
	"**/*.tsx", -- 2596
	"!**/.*/**", -- 2597
	"!**/node_modules/**" -- 2598
} -- 2594
local tsSnapshotGlobs = { -- 2601
	"**/*.ts", -- 2601
	"**/*.tsx", -- 2602
	"**/*.lua", -- 2603
	"!**/.*/**", -- 2604
	"!**/node_modules/**" -- 2605
} -- 2600
local collectTSVirtualFiles -- 2607
collectTSVirtualFiles = function(sourceRoot) -- 2607
	local files = { } -- 2608
	local seen = { } -- 2609
	local addFile -- 2610
	addFile = function(file, moduleName, virtualFile) -- 2610
		if moduleName == nil then -- 2610
			moduleName = nil -- 2610
		end -- 2610
		if virtualFile == nil then -- 2610
			virtualFile = nil -- 2610
		end -- 2610
		local targetFile = virtualFile or file -- 2611
		do -- 2612
			local entry = seen[targetFile] -- 2612
			if entry then -- 2612
				if moduleName and moduleName ~= "" then -- 2613
					entry.moduleName = moduleName -- 2613
				end -- 2613
				return -- 2614
			end -- 2612
		end -- 2612
		local content = Content:load(file) -- 2615
		if content then -- 2615
			local entry = { -- 2616
				file = targetFile, -- 2616
				content = content -- 2616
			} -- 2616
			if moduleName and moduleName ~= "" then -- 2617
				entry.moduleName = moduleName -- 2617
			end -- 2617
			seen[targetFile] = entry -- 2618
			files[#files + 1] = entry -- 2619
		end -- 2615
	end -- 2610
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2620
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2621
		for _index_0 = 1, #_list_0 do -- 2621
			local subFile = _list_0[_index_0] -- 2621
			addFile(Path(sourceRoot, subFile)) -- 2622
		end -- 2621
		local libraryRoots = { -- 2624
			Path(sourceRoot, "Script", "Lib"), -- 2624
			Path(sourceRoot, "Lib"), -- 2625
			Path(Content.assetPath, "Script", "Lib") -- 2626
		} -- 2623
		for _index_0 = 1, #libraryRoots do -- 2627
			local libraryRoot = libraryRoots[_index_0] -- 2627
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2628
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2629
				for _index_1 = 1, #_list_1 do -- 2629
					local subFile = _list_1[_index_1] -- 2629
					local file = Path(libraryRoot, subFile) -- 2630
					local virtualFile = Path(sourceRoot, subFile) -- 2631
					addFile(file, nil, virtualFile) -- 2632
				end -- 2629
			end -- 2628
		end -- 2627
	end -- 2620
	local locale -- 2633
	if App.locale:match('^zh') then -- 2633
		locale = 'zh-Hans' -- 2633
	else -- 2633
		locale = 'en' -- 2633
	end -- 2633
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2634
	local _list_0 = Content:getFiles(declarationRoot) -- 2635
	for _index_0 = 1, #_list_0 do -- 2635
		local file = _list_0[_index_0] -- 2635
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2636
			local fullPath = Path(declarationRoot, file) -- 2637
			local moduleName = Path:getName(Path:getName(file)) -- 2638
			addFile(fullPath, moduleName) -- 2639
		end -- 2636
	end -- 2635
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2640
	local lualibBundleTarget -- 2641
	if sourceRoot then -- 2641
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2641
	else -- 2641
		lualibBundleTarget = "lualib_bundle.lua" -- 2641
	end -- 2641
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2642
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2643
	local _list_1 = Content:getFiles(lualibRoot) -- 2644
	for _index_0 = 1, #_list_1 do -- 2644
		local file = _list_1[_index_0] -- 2644
		if Path:getExt(file) == "lua" then -- 2645
			local virtualFile -- 2646
			if sourceRoot then -- 2646
				virtualFile = Path(sourceRoot, "lualib", file) -- 2646
			else -- 2646
				virtualFile = Path("lualib", file) -- 2646
			end -- 2646
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2647
		end -- 2645
	end -- 2644
	return files -- 2648
end -- 2607
local supportsCompilerWebView -- 2650
supportsCompilerWebView = function() -- 2650
	local _val_0 = App.platform -- 2650
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2650
end -- 2650
local webIDECompilerReady = false -- 2651
local webIDEConnectionGeneration = 0 -- 2652
local tsProbeId = 0 -- 2653
local probeWebIDECompiler -- 2655
probeWebIDECompiler = function(isCancelled) -- 2655
	if HttpServer.wsConnectionCount == 0 then -- 2656
		return false -- 2656
	end -- 2656
	tsProbeId = tsProbeId + 1 -- 2657
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2658
	local generation = webIDEConnectionGeneration -- 2659
	local done, ready = false, false -- 2660
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2661
	local listener = Node() -- 2662
	listener:gslot("AppWS", function(event) -- 2663
		if event.type == "Receive" then -- 2664
			local res = json.decode(event.msg) -- 2665
			if res then -- 2665
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2666
					responses = responses + 1 -- 2667
					ready = ready or res.success == true -- 2668
					done = ready or responses >= expectedResponses -- 2669
				end -- 2666
			end -- 2665
		end -- 2664
	end) -- 2663
	emit("AppWS", "Send", json.encode({ -- 2670
		name = "TranspileTSProbe", -- 2670
		id = requestId -- 2670
	})) -- 2670
	local deadline = App.runningTime + 5 -- 2671
	wait(function() -- 2672
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2672
	end) -- 2672
	listener:removeFromParent() -- 2673
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2674
	if generation == webIDEConnectionGeneration then -- 2675
		webIDECompilerReady = ready -- 2675
	end -- 2675
	return ready -- 2676
end -- 2655
local compilerConnectionListener = Node() -- 2678
compilerConnectionListener:addTo(Director.systemUI) -- 2680
local _anon_func_8 = function(event) -- 2682
	local _val_0 = event.type -- 2682
	return "Open" == _val_0 or "Close" == _val_0 -- 2682
end -- 2682
compilerConnectionListener:gslot("AppWS", function(event) -- 2681
	if _anon_func_8(event) then -- 2682
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2683
		webIDECompilerReady = false -- 2684
		if HttpServer.wsConnectionCount > 0 then -- 2685
			return thread(function() -- 2686
				return probeWebIDECompiler() -- 2686
			end) -- 2686
		end -- 2685
	end -- 2682
end) -- 2681
local _anon_func_9 = function(res) -- 2711
	if res.success then -- 2711
		return "tool" -- 2711
	else -- 2711
		return res.failureKind -- 2711
	end -- 2711
end -- 2711
local transpileTSFileWithWebIDE -- 2688
do -- 2688
	local tsBuildRequestId = 0 -- 2689
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2690
		if not probeWebIDECompiler(isCancelled) then -- 2691
			if isCancelled and isCancelled() then -- 2692
				return { -- 2693
					success = false, -- 2693
					file = file, -- 2693
					message = "build canceled", -- 2693
					interrupted = true -- 2693
				} -- 2693
			end -- 2692
			return { -- 2694
				success = false, -- 2694
				file = file, -- 2694
				message = "TypeScript transpiler is not ready", -- 2694
				failureKind = "tool" -- 2694
			} -- 2694
		end -- 2691
		tsBuildRequestId = tsBuildRequestId + 1 -- 2695
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2696
		local done = false -- 2697
		local result = nil -- 2698
		local listener = Node() -- 2699
		listener:gslot("AppWS", function(event) -- 2700
			if event.type == "Receive" then -- 2701
				local res = json.decode(event.msg) -- 2702
				if res then -- 2702
					if res.name == "TranspileTS" and res.id == requestId then -- 2703
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2704
							local luaFile = Path:replaceExt(file, "lua") -- 2705
							if Content:save(luaFile, res.luaCode) then -- 2706
								result = { -- 2707
									success = true, -- 2707
									file = file -- 2707
								} -- 2707
							else -- 2709
								result = { -- 2709
									success = false, -- 2709
									file = file, -- 2709
									message = "failed to save " .. tostring(luaFile) -- 2709
								} -- 2709
							end -- 2706
						else -- 2711
							result = { -- 2711
								success = false, -- 2711
								file = file, -- 2711
								message = res.message or "Compiler returned no Lua output", -- 2711
								failureKind = _anon_func_9(res) -- 2711
							} -- 2711
						end -- 2704
						done = true -- 2712
					end -- 2703
				end -- 2702
			end -- 2701
		end) -- 2700
		emit("AppWS", "Send", json.encode({ -- 2713
			name = "TranspileTS", -- 2713
			id = requestId, -- 2713
			file = file, -- 2713
			content = content, -- 2713
			projectRoot = sourceRoot, -- 2713
			files = files -- 2713
		})) -- 2713
		local deadline = App.runningTime + 30 -- 2714
		wait(function() -- 2715
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2715
		end) -- 2715
		listener:removeFromParent() -- 2716
		if not done then -- 2717
			webIDECompilerReady = false -- 2718
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
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2721
				failureKind = "tool" -- 2721
			} -- 2721
		end -- 2717
		return result -- 2722
	end -- 2690
end -- 2688
local compilerReadyTimeout <const> = 15 -- 2724
local compilerBuildTimeout <const> = 30 -- 2725
local compilerIdleCloseSeconds <const> = 8 -- 2726
local compilerReady = false -- 2727
local compilerRequested = false -- 2728
local compilerFailure = nil -- 2729
local compilerUsers = 0 -- 2730
local compilerCloseGeneration = 0 -- 2731
local compilerJobId = 0 -- 2732
local compilerJobs = { } -- 2733
local compilerResults = { } -- 2734
local compilerInFlight = { } -- 2735
HttpServer:post("/compiler/ready", function() -- 2737
	if not compilerRequested then -- 2738
		return { -- 2738
			success = false -- 2738
		} -- 2738
	end -- 2738
	compilerReady = true -- 2739
	return { -- 2740
		success = true -- 2740
	} -- 2740
end) -- 2737
HttpServer:post("/compiler/failure", function(req) -- 2742
	if not compilerRequested then -- 2743
		return { -- 2743
			success = false -- 2743
		} -- 2743
	end -- 2743
	do -- 2744
		local _type_0 = type(req) -- 2744
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2744
		if _tab_0 then -- 2744
			local message -- 2744
			do -- 2744
				local _obj_0 = req.body -- 2744
				local _type_1 = type(_obj_0) -- 2744
				if "table" == _type_1 or "userdata" == _type_1 then -- 2744
					message = _obj_0.message -- 2744
				end -- 2744
			end -- 2744
			if message ~= nil then -- 2744
				if type(message) == "string" then -- 2745
					compilerFailure = message -- 2746
					compilerReady = false -- 2747
					return { -- 2748
						success = true -- 2748
					} -- 2748
				end -- 2745
			end -- 2744
		end -- 2744
	end -- 2744
	return { -- 2742
		success = false -- 2742
	} -- 2742
end) -- 2742
HttpServer:postSchedule("/compiler/poll", function() -- 2750
	if not compilerRequested then -- 2751
		return { -- 2751
			success = false -- 2751
		} -- 2751
	end -- 2751
	compilerReady = true -- 2752
	local deadline = App.runningTime + 5 -- 2753
	wait(function() -- 2754
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2754
	end) -- 2754
	if not (compilerRequested and not compilerFailure) then -- 2755
		return { -- 2755
			success = false -- 2755
		} -- 2755
	end -- 2755
	local job = table.remove(compilerJobs, 1) -- 2756
	if job then -- 2757
		compilerInFlight[job.id] = true -- 2758
	end -- 2757
	return { -- 2759
		success = true, -- 2759
		job = job -- 2759
	} -- 2759
end) -- 2750
HttpServer:post("/compiler/result", function(req) -- 2761
	do -- 2762
		local _type_0 = type(req) -- 2762
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2762
		if _tab_0 then -- 2762
			local body = req.body -- 2762
			if body ~= nil then -- 2762
				local id = body.id -- 2763
				if not (id and compilerInFlight[id]) then -- 2764
					return { -- 2764
						success = false, -- 2764
						message = "invalid compiler job" -- 2764
					} -- 2764
				end -- 2764
				compilerInFlight[id] = nil -- 2765
				compilerResults[id] = body -- 2766
				return { -- 2767
					success = true -- 2767
				} -- 2767
			end -- 2762
		end -- 2762
	end -- 2762
	return { -- 2761
		success = false -- 2761
	} -- 2761
end) -- 2761
local acquireCompiler -- 2769
acquireCompiler = function() -- 2769
	compilerUsers = compilerUsers + 1 -- 2770
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2771
	if not compilerRequested then -- 2772
		compilerRequested = true -- 2773
		compilerReady = false -- 2774
		compilerFailure = nil -- 2775
		return emit("AppWebView", "/compiler.html", true) -- 2776
	end -- 2772
end -- 2769
local releaseCompiler -- 2778
releaseCompiler = function() -- 2778
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2779
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2780
	if not (compilerUsers == 0) then -- 2781
		return -- 2781
	end -- 2781
	local closeGeneration = compilerCloseGeneration -- 2782
	return thread(function() -- 2783
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2784
		wait(function() -- 2785
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2786
		end) -- 2785
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2791
			compilerRequested = false -- 2792
			compilerReady = false -- 2793
			return emit("AppWebView", "/compiler.html", false) -- 2794
		end -- 2791
	end) -- 2783
end -- 2778
local removeCompilerJob -- 2796
removeCompilerJob = function(id) -- 2796
	for index = #compilerJobs, 1, -1 do -- 2797
		if compilerJobs[index].id == id then -- 2798
			table.remove(compilerJobs, index) -- 2799
		end -- 2798
	end -- 2797
	compilerInFlight[id] = nil -- 2800
	compilerResults[id] = nil -- 2801
end -- 2796
local transpileTSFileWithCompiler -- 2803
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2803
	acquireCompiler() -- 2804
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2805
	wait(function() -- 2806
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2806
	end) -- 2806
	if not compilerReady then -- 2807
		releaseCompiler() -- 2808
		if isCancelled and isCancelled() then -- 2809
			return { -- 2810
				success = false, -- 2810
				file = file, -- 2810
				message = "build canceled", -- 2810
				interrupted = true -- 2810
			} -- 2810
		end -- 2809
		return { -- 2811
			success = false, -- 2811
			file = file, -- 2811
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2811
			failureKind = "tool" -- 2811
		} -- 2811
	end -- 2807
	compilerJobId = compilerJobId + 1 -- 2812
	local jobId = compilerJobId -- 2813
	compilerJobs[#compilerJobs + 1] = { -- 2815
		id = jobId, -- 2815
		file = file, -- 2816
		content = content, -- 2817
		projectRoot = sourceRoot, -- 2818
		files = files -- 2819
	} -- 2814
	local deadline = App.runningTime + compilerBuildTimeout -- 2820
	wait(function() -- 2821
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2821
	end) -- 2821
	local response = compilerResults[jobId] -- 2822
	removeCompilerJob(jobId) -- 2823
	releaseCompiler() -- 2824
	if not response then -- 2825
		if isCancelled and isCancelled() then -- 2826
			return { -- 2827
				success = false, -- 2827
				file = file, -- 2827
				message = "build canceled", -- 2827
				interrupted = true -- 2827
			} -- 2827
		end -- 2826
		return { -- 2828
			success = false, -- 2828
			file = file, -- 2828
			message = compilerFailure or "TypeScript transpile timed out", -- 2828
			failureKind = "tool" -- 2828
		} -- 2828
	end -- 2825
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2829
		local luaFile = Path:replaceExt(file, "lua") -- 2830
		if Content:save(luaFile, response.luaCode) then -- 2831
			return { -- 2832
				success = true, -- 2832
				file = file -- 2832
			} -- 2832
		end -- 2831
		return { -- 2833
			success = false, -- 2833
			file = file, -- 2833
			message = "failed to save " .. tostring(luaFile) -- 2833
		} -- 2833
	end -- 2829
	return { -- 2834
		success = false, -- 2834
		file = file, -- 2834
		message = response.message or "TypeScript transpile failed" -- 2834
	} -- 2834
end -- 2803
local compilerFailureListener = Node() -- 2836
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2837
	compilerFailure = message -- 2838
	compilerReady = false -- 2839
end) -- 2837
local transpileTSFile -- 2841
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2841
	if supportsCompilerWebView() and not files then -- 2842
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2843
	end -- 2842
	if HttpServer.wsConnectionCount > 0 then -- 2844
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2845
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2846
			return result -- 2846
		end -- 2846
		webIDECompilerReady = false -- 2847
	end -- 2844
	if supportsCompilerWebView() then -- 2848
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2849
	end -- 2848
	return { -- 2850
		success = false, -- 2850
		file = file, -- 2850
		message = "Web IDE compiler not connected", -- 2850
		failureKind = "tool" -- 2850
	} -- 2850
end -- 2841
local _anon_func_10 = function(path) -- 2865
	local _val_0 = Path:getExt(path) -- 2865
	return "ts" == _val_0 or "tsx" == _val_0 -- 2865
end -- 2865
HttpServer:postSchedule("/ts/build", function(req) -- 2852
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2853
	local buildSucceeded = false -- 2854
	local _ <close> = setmetatable({ }, { -- 2855
		__close = function() -- 2855
			return finishUpdate(buildSucceeded) -- 2855
		end -- 2855
	}) -- 2855
	do -- 2856
		local _type_0 = type(req) -- 2856
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2856
		if _tab_0 then -- 2856
			local path -- 2856
			do -- 2856
				local _obj_0 = req.body -- 2856
				local _type_1 = type(_obj_0) -- 2856
				if "table" == _type_1 or "userdata" == _type_1 then -- 2856
					path = _obj_0.path -- 2856
				end -- 2856
			end -- 2856
			if path ~= nil then -- 2856
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2857
					return { -- 2858
						success = false, -- 2858
						message = "Web IDE not connected" -- 2858
					} -- 2858
				end -- 2857
				local projectRoot = req.body.projectRoot -- 2859
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2860
				if not Content:exist(path) then -- 2861
					return { -- 2862
						success = false, -- 2862
						message = "path not existed" -- 2862
					} -- 2862
				end -- 2861
				local messages = { } -- 2863
				if not Content:isdir(path) then -- 2864
					if not (_anon_func_10(path)) then -- 2865
						return { -- 2866
							success = false, -- 2866
							message = "expecting a TypeScript file" -- 2866
						} -- 2866
					end -- 2865
					local content = Content:load(path) -- 2867
					if not content then -- 2868
						return { -- 2869
							success = false, -- 2869
							message = "failed to read file" -- 2869
						} -- 2869
					end -- 2868
					emit("AppWS", "Send", json.encode({ -- 2870
						name = "UpdateFile", -- 2870
						file = path, -- 2870
						exists = true, -- 2870
						content = content, -- 2870
						projectRoot = sourceRoot -- 2870
					})) -- 2870
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2871
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2872
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2873
					end -- 2871
				else -- 2875
					local fileData = { } -- 2875
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2876
					for _index_0 = 1, #_list_0 do -- 2876
						local subFile = _list_0[_index_0] -- 2876
						local file = Path(path, subFile) -- 2877
						local content = Content:load(file) -- 2878
						if content then -- 2878
							fileData[file] = content -- 2879
							emit("AppWS", "Send", json.encode({ -- 2880
								name = "UpdateFile", -- 2880
								file = file, -- 2880
								exists = true, -- 2880
								content = content, -- 2880
								projectRoot = sourceRoot -- 2880
							})) -- 2880
						else -- 2882
							messages[#messages + 1] = { -- 2882
								success = false, -- 2882
								file = file, -- 2882
								message = "failed to read file" -- 2882
							} -- 2882
						end -- 2878
					end -- 2876
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2883
					for file, content in pairs(fileData) do -- 2884
						if "d" == Path:getExt(Path:getName(file)) then -- 2885
							goto _continue_0 -- 2885
						end -- 2885
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2886
						::_continue_0:: -- 2885
					end -- 2884
				end -- 2864
				local success = true -- 2887
				for _index_0 = 1, #messages do -- 2888
					local item = messages[_index_0] -- 2888
					if not item.success then -- 2889
						success = false -- 2889
					end -- 2889
				end -- 2888
				local message = nil -- 2890
				if not success then -- 2891
					message = "TypeScript compilation failed" -- 2891
				end -- 2891
				buildSucceeded = success -- 2892
				return { -- 2893
					success = success, -- 2893
					messages = messages, -- 2893
					message = message -- 2893
				} -- 2893
			end -- 2856
		end -- 2856
	end -- 2856
	return { -- 2852
		success = false -- 2852
	} -- 2852
end) -- 2852
HttpServer:post("/download", function(req) -- 2895
	do -- 2896
		local _type_0 = type(req) -- 2896
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2896
		if _tab_0 then -- 2896
			local url -- 2896
			do -- 2896
				local _obj_0 = req.body -- 2896
				local _type_1 = type(_obj_0) -- 2896
				if "table" == _type_1 or "userdata" == _type_1 then -- 2896
					url = _obj_0.url -- 2896
				end -- 2896
			end -- 2896
			local target -- 2896
			do -- 2896
				local _obj_0 = req.body -- 2896
				local _type_1 = type(_obj_0) -- 2896
				if "table" == _type_1 or "userdata" == _type_1 then -- 2896
					target = _obj_0.target -- 2896
				end -- 2896
			end -- 2896
			if url ~= nil and target ~= nil then -- 2896
				local Entry = require("Script.Dev.Entry") -- 2897
				Entry.downloadFile(url, target) -- 2898
				return { -- 2899
					success = true -- 2899
				} -- 2899
			end -- 2896
		end -- 2896
	end -- 2896
	return { -- 2895
		success = false -- 2895
	} -- 2895
end) -- 2895
local isDesktopPlatform -- 2901
isDesktopPlatform = function() -- 2901
	local _val_0 = App.platform -- 2902
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2902
end -- 2901
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 2904
local nativeIDEListener = Node() -- 2905
nativeIDEListener:addTo(Director.systemUI) -- 2906
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 2907
	nativeIDEState, nativeIDEMessage = state, message -- 2908
end) -- 2907
local _anon_func_11 = function() -- 2911
	local _val_0 = App.platform -- 2911
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2911
end -- 2911
HttpServer:post("/ide", function(req) -- 2910
	if not (_anon_func_11()) then -- 2911
		return { -- 2911
			success = false, -- 2911
			message = "Native IDE is unavailable" -- 2911
		} -- 2911
	end -- 2911
	if not App.webIDEEnabled then -- 2912
		return { -- 2912
			success = false, -- 2912
			message = "Embedded Web IDE is disabled" -- 2912
		} -- 2912
	end -- 2912
	do -- 2913
		local _type_0 = type(req) -- 2913
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2913
		if _tab_0 then -- 2913
			local action -- 2913
			do -- 2913
				local _obj_0 = req.body -- 2913
				local _type_1 = type(_obj_0) -- 2913
				if "table" == _type_1 or "userdata" == _type_1 then -- 2913
					action = _obj_0.action -- 2913
				end -- 2913
			end -- 2913
			if action ~= nil then -- 2913
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 2914
					emit("AppWebView", "/ide/" .. action, true) -- 2915
					return { -- 2916
						success = true -- 2916
					} -- 2916
				end -- 2914
			end -- 2913
		end -- 2913
	end -- 2913
	return { -- 2910
		success = false, -- 2910
		message = "invalid IDE action" -- 2910
	} -- 2910
end) -- 2910
local _anon_func_12 = function() -- 2932
	local _val_0 = App.platform -- 2932
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2932
end -- 2932
local getServerStatus -- 2918
getServerStatus = function() -- 2918
	local Entry = require("Script.Dev.Entry") -- 2919
	local running = Entry.getCurrentEntryStatus() -- 2920
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2921
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2922
	return { -- 2924
		success = true, -- 2924
		platform = App.platform, -- 2925
		locale = App.locale, -- 2926
		version = App.version, -- 2927
		url = "http://localhost:8866", -- 2928
		wsConnectionCount = wsConnectionCount, -- 2929
		webIDEConnected = wsConnectionCount > 0, -- 2930
		nativeIDE = { -- 2932
			supported = _anon_func_12(), -- 2932
			enabled = App.webIDEEnabled, -- 2933
			state = nativeIDEState, -- 2934
			message = nativeIDEMessage -- 2935
		}, -- 2931
		typescriptCompiler = { -- 2937
			webIDEReady = webIDECompilerReady, -- 2937
			webIDEGeneration = webIDEConnectionGeneration, -- 2938
			embeddedSupported = supportsCompilerWebView(), -- 2939
			embeddedRequested = compilerRequested, -- 2940
			embeddedReady = compilerReady, -- 2941
			users = compilerUsers, -- 2942
			queuedJobs = #compilerJobs, -- 2943
			failure = compilerFailure -- 2944
		}, -- 2936
		assetPath = Content.assetPath, -- 2945
		writablePath = Content.writablePath, -- 2946
		appPath = Content.appPath, -- 2947
		waTemplateReady = waTemplateReady, -- 2948
		running = running -- 2949
	} -- 2923
end -- 2918
HttpServer:post("/status", function() -- 2952
	return getServerStatus() -- 2953
end) -- 2952
HttpServer:postSchedule("/doctor/fix", function(req) -- 2955
	do -- 2956
		local _type_0 = type(req) -- 2956
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2956
		if _tab_0 then -- 2956
			local openWebIDE -- 2956
			do -- 2956
				local _obj_0 = req.body -- 2956
				local _type_1 = type(_obj_0) -- 2956
				if "table" == _type_1 or "userdata" == _type_1 then -- 2956
					openWebIDE = _obj_0.openWebIDE -- 2956
				end -- 2956
			end -- 2956
			if openWebIDE ~= nil then -- 2956
				if not openWebIDE then -- 2957
					return { -- 2958
						success = false, -- 2958
						message = "nothing to fix" -- 2958
					} -- 2958
				end -- 2957
				local status = getServerStatus() -- 2959
				if status.webIDEConnected then -- 2960
					return { -- 2961
						success = true, -- 2961
						fixed = false, -- 2961
						message = "Web IDE already connected.", -- 2961
						status = status -- 2961
					} -- 2961
				end -- 2960
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2962
				if waitSeconds > 0 then -- 2963
					local deadline = os.time() + waitSeconds -- 2964
					repeat -- 2965
						sleep(0.2) -- 2966
						status = getServerStatus() -- 2967
						if status.webIDEConnected then -- 2968
							return { -- 2969
								success = true, -- 2969
								fixed = false, -- 2969
								reconnected = true, -- 2969
								message = "Web IDE reconnected.", -- 2969
								status = status -- 2969
							} -- 2969
						end -- 2968
					until os.time() >= deadline -- 2965
				end -- 2963
				if not isDesktopPlatform() then -- 2971
					return { -- 2972
						success = false, -- 2972
						message = "opening Web IDE is only supported on desktop platforms", -- 2972
						status = status -- 2972
					} -- 2972
				end -- 2971
				local url = "http://localhost:8866" -- 2973
				App:openURL(url) -- 2974
				status.openedURL = url -- 2975
				return { -- 2976
					success = true, -- 2976
					fixed = true, -- 2976
					message = "Opened Web IDE in the local browser.", -- 2976
					url = url, -- 2976
					status = status -- 2976
				} -- 2976
			end -- 2956
		end -- 2956
	end -- 2956
	return { -- 2955
		success = false, -- 2955
		message = "invalid call" -- 2955
	} -- 2955
end) -- 2955
local status = { } -- 2978
_module_0 = status -- 2979
status.transpileTSFile = transpileTSFile -- 2981
status.buildAsync = function(path) -- 2983
	if not Content:exist(path) then -- 2984
		return { -- 2985
			success = false, -- 2985
			file = path, -- 2985
			message = "file not existed" -- 2985
		} -- 2985
	end -- 2984
	do -- 2986
		local _exp_0 = Path:getExt(path) -- 2986
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2986
			if '' == Path:getExt(Path:getName(path)) then -- 2987
				local content = Content:loadAsync(path) -- 2988
				if content then -- 2988
					local resultCodes, err = compileFileAsync(path, content) -- 2989
					if resultCodes then -- 2989
						return { -- 2990
							success = true, -- 2990
							file = path -- 2990
						} -- 2990
					else -- 2992
						return { -- 2992
							success = false, -- 2992
							file = path, -- 2992
							message = err -- 2992
						} -- 2992
					end -- 2989
				end -- 2988
			end -- 2987
		elseif "lua" == _exp_0 then -- 2993
			local content = Content:loadAsync(path) -- 2994
			if content then -- 2994
				do -- 2995
					local isTIC80 = CheckTIC80Code(content) -- 2995
					if isTIC80 then -- 2995
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2996
					end -- 2995
				end -- 2995
				local success, info -- 2997
				do -- 2997
					local _obj_0 = luaCheck(path, content) -- 2997
					success, info = _obj_0.success, _obj_0.info -- 2997
				end -- 2997
				if success then -- 2998
					return { -- 2999
						success = true, -- 2999
						file = path -- 2999
					} -- 2999
				elseif info and #info > 0 then -- 3000
					local messages = { } -- 3001
					for _index_0 = 1, #info do -- 3002
						local _des_0 = info[_index_0] -- 3002
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3002
						local lineText = "" -- 3003
						if line then -- 3004
							local currentLine = 1 -- 3005
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3006
								if currentLine == line then -- 3007
									lineText = text -- 3008
									break -- 3009
								end -- 3007
								currentLine = currentLine + 1 -- 3010
							end -- 3006
						end -- 3004
						if line then -- 3011
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3012
						else -- 3014
							messages[#messages + 1] = message -- 3014
						end -- 3011
					end -- 3002
					return { -- 3015
						success = false, -- 3015
						file = path, -- 3015
						message = table.concat(messages, "\n") -- 3015
					} -- 3015
				else -- 3017
					return { -- 3017
						success = false, -- 3017
						file = path, -- 3017
						message = "lua check failed" -- 3017
					} -- 3017
				end -- 2998
			end -- 2994
		elseif "yarn" == _exp_0 then -- 3018
			local content = Content:loadAsync(path) -- 3019
			if content then -- 3019
				local res, _, err = yarncompile(content, true) -- 3020
				if res then -- 3020
					return { -- 3021
						success = true, -- 3021
						file = path -- 3021
					} -- 3021
				else -- 3023
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3023
					local lineText = "" -- 3024
					if line then -- 3025
						local currentLine = 1 -- 3026
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3027
							if currentLine == line then -- 3028
								lineText = text -- 3029
								break -- 3030
							end -- 3028
							currentLine = currentLine + 1 -- 3031
						end -- 3027
					end -- 3025
					if node ~= "" then -- 3032
						node = "node: " .. tostring(node) .. ", " -- 3033
					else -- 3034
						node = "" -- 3034
					end -- 3032
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3035
					return { -- 3036
						success = false, -- 3036
						file = path, -- 3036
						message = message -- 3036
					} -- 3036
				end -- 3020
			end -- 3019
		end -- 2986
	end -- 2986
	return { -- 3037
		success = false, -- 3037
		file = path, -- 3037
		message = "invalid file to build" -- 3037
	} -- 3037
end -- 2983
HttpServer:postSchedule("/git/commit-files", function(req) -- 3039
	do -- 3040
		local _type_0 = type(req) -- 3040
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3040
		if _tab_0 then -- 3040
			local body = req.body -- 3040
			if body ~= nil then -- 3040
				local repoPath, commit = body.repoPath, body.commit -- 3041
				if gitInvalidRepoPath(repoPath) then -- 3042
					return { -- 3042
						success = false, -- 3042
						message = "invalid repoPath" -- 3042
					} -- 3042
				end -- 3042
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3043
					return { -- 3043
						success = false, -- 3043
						message = "invalid commit" -- 3043
					} -- 3043
				end -- 3043
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3044
				if not res.success then -- 3045
					return res -- 3045
				end -- 3045
				return { -- 3046
					success = true, -- 3046
					status = res.status, -- 3046
					data = res.status and res.status.data -- 3046
				} -- 3046
			end -- 3040
		end -- 3040
	end -- 3040
	return invalidArguments -- 3039
end) -- 3039
thread(function() -- 3048
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3049
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3050
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3051
		local storedAsset -- 3054
		storedAsset = function(file) -- 3054
			if Content:exist(file) then -- 3055
				return Content:load(file) -- 3056
			elseif Content:exist(file .. ".gz") then -- 3057
				return Content:load(file .. ".gz") -- 3058
			else -- 3059
				return "" -- 3059
			end -- 3055
		end -- 3054
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3060
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3061
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3062
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3063
		local readyContent = table.concat({ -- 3065
			App.version, -- 3065
			storedAsset(doraWeb), -- 3066
			storedAsset(heavyAssets), -- 3067
			storedAsset(runtimeIndex), -- 3068
			storedAsset(compilerIndex), -- 3069
			storedAsset(manifest) -- 3070
		}, "\n") -- 3064
		local needReload -- 3072
		if Content:exist(doraReady) then -- 3072
			needReload = readyContent ~= Content:load(doraReady) -- 3073
		else -- 3074
			needReload = true -- 3074
		end -- 3072
		if needReload then -- 3075
			Content:remove(Path(Content.appPath, ".www")) -- 3076
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3077
			Content:save(doraReady, readyContent) -- 3081
			print("Dora Dora is ready!") -- 3082
		end -- 3075
	end -- 3051
	if App.platform == "Emscripten" then -- 3083
		status.url = nil -- 3084
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3085
	end -- 3083
	HttpServer:clearStaticCacheControls() -- 3086
	HttpServer:setStaticCacheControl("no-cache") -- 3087
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3088
	if HttpServer:start(8866) then -- 3092
		local localIP = HttpServer.localIP -- 3093
		if localIP == "" then -- 3094
			localIP = "localhost" -- 3094
		end -- 3094
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3095
		return HttpServer:startWS(8868) -- 3096
	else -- 3098
		status.url = nil -- 3098
		return print("8866 Port not available!") -- 3099
	end -- 3092
end) -- 3048
return _module_0 -- 1
