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
local pairs <const> = pairs -- 10
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
local gitInvalidRepoPath -- 158
gitInvalidRepoPath = function(repoPath) -- 158
	if not (type(repoPath) == "string" and repoPath ~= "") then -- 159
		return true -- 159
	end -- 159
	return not Git:isRepoPathAllowed(repoPath) -- 160
end -- 158
local gitShellSplit -- 162
gitShellSplit = function(command) -- 162
	local args = { } -- 163
	local current = { } -- 164
	local quote = nil -- 165
	local escape = false -- 166
	for i = 1, #command do -- 167
		local ch = command:sub(i, i) -- 168
		if escape then -- 169
			current[#current + 1] = ch -- 170
			escape = false -- 171
		elseif ch == "\\" then -- 172
			escape = true -- 173
		elseif quote then -- 174
			if ch == quote then -- 175
				quote = nil -- 176
			else -- 178
				current[#current + 1] = ch -- 178
			end -- 175
		elseif ch == "'" or ch == '"' then -- 179
			quote = ch -- 180
		elseif ch:match("%s") then -- 181
			if #current > 0 then -- 182
				args[#args + 1] = table.concat(current) -- 183
				current = { } -- 184
			end -- 182
		else -- 186
			current[#current + 1] = ch -- 186
		end -- 169
	end -- 167
	if #current > 0 then -- 187
		args[#args + 1] = table.concat(current) -- 188
	end -- 187
	if args[1] == "git" then -- 189
		table.remove(args, 1) -- 190
	end -- 189
	return args -- 191
end -- 162
local gitQuote -- 193
gitQuote = function(value) -- 193
	local text = tostring(value) -- 194
	if text:match("^[%w%._%-%/]+$") then -- 195
		return text -- 196
	end -- 195
	return "\"" .. text:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"" -- 197
end -- 193
local gitDirNonEmpty -- 199
gitDirNonEmpty = function(targetPath) -- 199
	if not Content:exist(targetPath) then -- 200
		return false -- 200
	end -- 200
	if not Content:isdir(targetPath) then -- 201
		return false -- 201
	end -- 201
	return #Content:getFiles(targetPath) > 0 or #Content:getDirs(targetPath) > 0 -- 202
end -- 199
local gitSafeChildPath -- 204
gitSafeChildPath = function(parentPath, childPath) -- 204
	if not (parentPath and childPath and childPath ~= "") then -- 205
		return nil -- 205
	end -- 205
	if childPath:sub(1, 1) == "/" or childPath:match("^%a:[/\\]") then -- 206
		return nil -- 206
	end -- 206
	if childPath == "." or childPath:match("^%.%.[/\\]?" or childPath:match("[/\\]%.%.[/\\]")) then -- 207
		return nil -- 207
	end -- 207
	local targetPath = Path(parentPath, childPath) -- 208
	local relative = Path:getRelative(targetPath, parentPath) -- 209
	if relative == ".." or relative:sub(1, 3) == "../" or relative:sub(1, 3) == "..\\" then -- 210
		return nil -- 210
	end -- 210
	return targetPath -- 211
end -- 204
local gitCloneDirFromURL -- 213
gitCloneDirFromURL = function(url) -- 213
	if not (url and url ~= "") then -- 214
		return nil -- 214
	end -- 214
	local text = tostring(url):match("^%s*(.-)%s*$") -- 215
	if text == "" then -- 216
		return nil -- 216
	end -- 216
	text = text:gsub("[/\\]+$", "") -- 217
	local name = text:match("([^/:]+)$") -- 218
	if not (name and name ~= "") then -- 219
		return nil -- 219
	end -- 219
	name = name:gsub("%.git$", "") -- 220
	if name == "" or name == "." or name == ".." then -- 221
		return nil -- 221
	end -- 221
	return name -- 222
end -- 213
local gitCloneTargetPath -- 224
gitCloneTargetPath = function(repoPath, command) -- 224
	local args = gitShellSplit(command) -- 225
	if not (args[1] == "clone") then -- 226
		return nil -- 226
	end -- 226
	local url = args[2] -- 227
	local index = 3 -- 228
	while index <= #args do -- 229
		local arg = args[index] -- 230
		if ("-b" == arg or "--branch" == arg or "--depth" == arg) then -- 231
			index = index + 2 -- 232
		elseif arg:sub(1, 1) == "-" then -- 233
			index = index + 1 -- 234
		else -- 236
			return gitSafeChildPath(repoPath, arg) -- 236
		end -- 231
	end -- 229
	do -- 237
		local dirName = gitCloneDirFromURL(url) -- 237
		if dirName then -- 237
			return gitSafeChildPath(repoPath, dirName) -- 238
		end -- 237
	end -- 237
	return nil -- 239
end -- 224
local gitPathInsideRepo -- 241
gitPathInsideRepo = function(repoPath, relPath) -- 241
	if not (repoPath and relPath and relPath ~= "") then -- 242
		return false -- 242
	end -- 242
	if relPath:sub(1, 1) == "/" or relPath:match("^%a:[/\\]") then -- 243
		return false -- 243
	end -- 243
	if relPath == "." or relPath:match("^%.%.[/\\]?" or relPath:match("[/\\]%.%.[/\\]")) then -- 244
		return false -- 244
	end -- 244
	local targetPath = Path(repoPath, relPath) -- 245
	local relative = Path:getRelative(targetPath, repoPath) -- 246
	return relative ~= ".." and relative:sub(1, 3) ~= "../" and relative:sub(1, 3) ~= "..\\" -- 247
end -- 241
local gitHostFromURL -- 249
gitHostFromURL = function(url) -- 249
	if not (url and url ~= "") then -- 250
		return nil -- 250
	end -- 250
	local text = tostring(url):match("^%s*(.-)%s*$") -- 251
	if text == "" then -- 252
		return nil -- 252
	end -- 252
	local host = text:match("^[%w_%-]+://([^/:]+)") -- 253
	if not host then -- 254
		host = text:match("@([^:/]+)[:/]") -- 254
	end -- 254
	if not host then -- 255
		host = text:match("^([^:/]+):[^/]") -- 255
	end -- 255
	if not (host and host ~= "") then -- 256
		return nil -- 256
	end -- 256
	return string.lower(host) -- 257
end -- 249
local ensureGitTables -- 259
ensureGitTables = function() -- 259
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
	]]) -- 260
	DB:exec("CREATE INDEX IF NOT EXISTS idx_git_credential_host ON GitCredential(host);") -- 273
	return DB:exec([[		CREATE TABLE IF NOT EXISTS GitProfile(
			id INTEGER PRIMARY KEY CHECK(id = 1),
			name TEXT NOT NULL DEFAULT '',
			email TEXT NOT NULL DEFAULT '',
			updated_at INTEGER
		);
	]]) -- 274
end -- 259
local gitCredentialToPublic -- 283
gitCredentialToPublic = function(row) -- 283
	local id, host, label, typeName, username, createdAt, updatedAt, lastUsedAt = row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8] -- 284
	return { -- 285
		id = id, -- 285
		host = host, -- 285
		label = label, -- 285
		type = typeName, -- 285
		username = username, -- 285
		createdAt = createdAt, -- 285
		updatedAt = updatedAt, -- 285
		lastUsedAt = lastUsedAt -- 285
	} -- 285
end -- 283
local gitLoadCredential -- 287
gitLoadCredential = function(id) -- 287
	ensureGitTables() -- 288
	local credentialId = tonumber(id) or 0 -- 289
	local rows = DB:query("select id, host, label, type, username, secret from GitCredential where id = ? limit 1", { -- 290
		credentialId -- 290
	}) -- 290
	if not (rows and rows[1]) then -- 291
		return nil -- 291
	end -- 291
	local row = rows[1] -- 292
	return { -- 293
		id = row[1], -- 293
		host = row[2], -- 293
		label = row[3], -- 293
		type = row[4], -- 293
		username = row[5], -- 293
		secret = row[6] -- 293
	} -- 293
end -- 287
local gitAuthOptionsJSON -- 295
gitAuthOptionsJSON = function(credential) -- 295
	if not credential then -- 296
		return nil -- 296
	end -- 296
	local auth -- 297
	if credential.type == "token" then -- 297
		auth = { -- 299
			type = "token", -- 299
			token = credential.secret, -- 300
			username = credential.username ~= "" and credential.username or "token" -- 301
		} -- 298
	else -- 304
		auth = { -- 305
			type = "basic", -- 305
			username = credential.username, -- 306
			password = credential.secret -- 307
		} -- 304
	end -- 297
	return json.encode({ -- 309
		auth = auth -- 309
	}) -- 309
end -- 295
local gitLoadProfile -- 311
gitLoadProfile = function() -- 311
	ensureGitTables() -- 312
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 313
	if not (rows and rows[1]) then -- 314
		return nil -- 314
	end -- 314
	local name = tostring(rows[1][1] or "") -- 315
	local email = tostring(rows[1][2] or "") -- 316
	if name == "" and email == "" then -- 317
		return nil -- 317
	end -- 317
	return { -- 318
		name = name, -- 318
		email = email -- 318
	} -- 318
end -- 311
local _anon_func_2 = function(args, gitQuote) -- 337
	local _accum_0 = { } -- 337
	local _len_0 = 1 -- 337
	for _index_0 = 1, #args do -- 337
		local arg = args[_index_0] -- 337
		_accum_0[_len_0] = gitQuote(arg) -- 337
		_len_0 = _len_0 + 1 -- 337
	end -- 337
	return _accum_0 -- 337
end -- 337
local gitApplyProfileToCommit -- 320
gitApplyProfileToCommit = function(command) -- 320
	local args = gitShellSplit(command) -- 321
	if not (args[1] == "commit") then -- 322
		return command -- 322
	end -- 322
	local hasName = false -- 323
	local hasEmail = false -- 324
	for _index_0 = 1, #args do -- 325
		local arg = args[_index_0] -- 325
		if arg == "--author-name" then -- 326
			hasName = true -- 326
		end -- 326
		if arg == "--author-email" then -- 327
			hasEmail = true -- 327
		end -- 327
	end -- 325
	if hasName and hasEmail then -- 328
		return command -- 328
	end -- 328
	local profile = gitLoadProfile() -- 329
	if not profile then -- 330
		return command -- 330
	end -- 330
	if not hasName and profile.name ~= "" then -- 331
		args[#args + 1] = "--author-name" -- 332
		args[#args + 1] = profile.name -- 333
	end -- 331
	if not hasEmail and profile.email ~= "" then -- 334
		args[#args + 1] = "--author-email" -- 335
		args[#args + 1] = profile.email -- 336
	end -- 334
	return table.concat(_anon_func_2(args, gitQuote), " ") -- 337
end -- 320
local gitStartJob -- 339
gitStartJob = function(repoPath, command, optionsJSON) -- 339
	if optionsJSON == nil then -- 339
		optionsJSON = nil -- 339
	end -- 339
	if gitInvalidRepoPath(repoPath) then -- 340
		return nil, "invalid repoPath" -- 340
	end -- 340
	if not (command and command ~= "") then -- 341
		return nil, "invalid command" -- 341
	end -- 341
	if not optionsJSON then -- 342
		optionsJSON = "" -- 342
	end -- 342
	command = gitApplyProfileToCommit(command) -- 343
	do -- 344
		local targetPath = gitCloneTargetPath(repoPath, command) -- 344
		if targetPath then -- 344
			if gitInvalidRepoPath(targetPath) then -- 345
				return nil, "invalid clone target" -- 345
			end -- 345
			if gitDirNonEmpty(targetPath) then -- 346
				return nil, "clone target directory is not empty" -- 347
			end -- 346
		elseif (gitShellSplit(command))[1] == "clone" then -- 348
			return nil, "invalid clone target" -- 349
		end -- 344
	end -- 344
	local statusRef = nil -- 350
	local startGit -- 351
	startGit = function() -- 351
		return Git:run(repoPath, command, (function(status) -- 352
			statusRef = status -- 353
			GitJobs[status.id] = { -- 355
				command = command, -- 355
				status = status, -- 356
				updatedAt = os.time() -- 357
			} -- 354
		end), optionsJSON) -- 352
	end -- 351
	local success, jobId = pcall(startGit) -- 359
	if not success then -- 360
		return nil, tostring(jobId) -- 360
	end -- 360
	if not jobId then -- 361
		return nil, "Git.run did not return a job id" -- 361
	end -- 361
	GitJobs[jobId] = { -- 363
		command = command, -- 363
		status = statusRef or { -- 365
			id = jobId, -- 365
			state = "queued", -- 366
			kind = gitShellSplit(command)[1] or "status", -- 367
			repoPath = repoPath, -- 368
			progress = 0, -- 369
			message = "queued" -- 370
		}, -- 364
		updatedAt = os.time() -- 372
	} -- 362
	return jobId -- 373
end -- 339
local gitRunSync -- 375
gitRunSync = function(repoPath, command, optionsJSON, timeout) -- 375
	if optionsJSON == nil then -- 375
		optionsJSON = nil -- 375
	end -- 375
	if timeout == nil then -- 375
		timeout = 20 -- 375
	end -- 375
	local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 376
	if not jobId then -- 377
		return { -- 377
			success = false, -- 377
			message = err -- 377
		} -- 377
	end -- 377
	local startedAt = os.time() -- 378
	wait(function() -- 379
		local job = GitJobs[jobId] -- 380
		local status = job and job.status -- 381
		return gitTerminalState(status) or os.time() - startedAt >= timeout -- 382
	end) -- 379
	local status = GitJobs[jobId] and GitJobs[jobId].status -- 383
	if not gitTerminalState(status) then -- 384
		Git:cancel(jobId) -- 385
		return { -- 386
			success = false, -- 386
			message = "git command timed out", -- 386
			jobId = jobId, -- 386
			status = status -- 386
		} -- 386
	end -- 384
	return { -- 387
		success = status.state == "done", -- 387
		jobId = jobId, -- 387
		status = status, -- 387
		message = status.error or status.message -- 387
	} -- 387
end -- 375
local gitCredentialsForHost -- 389
gitCredentialsForHost = function(host) -- 389
	if not (host and host ~= "") then -- 390
		return { } -- 390
	end -- 390
	ensureGitTables() -- 391
	local rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by last_used_at desc, label asc, id asc", { -- 392
		host -- 392
	}) -- 392
	if rows then -- 393
		local _accum_0 = { } -- 394
		local _len_0 = 1 -- 394
		for _index_0 = 1, #rows do -- 394
			local row = rows[_index_0] -- 394
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 394
			_len_0 = _len_0 + 1 -- 394
		end -- 394
		return _accum_0 -- 394
	else -- 395
		return { } -- 395
	end -- 393
end -- 389
local gitFirstRemoteURL -- 397
gitFirstRemoteURL = function(repoPath, remoteName) -- 397
	if remoteName == nil then -- 397
		remoteName = nil -- 397
	end -- 397
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 10) -- 398
	local data = remoteRes.status and remoteRes.status.data -- 399
	if not (data and data.remotes) then -- 400
		return nil -- 400
	end -- 400
	local _list_0 = data.remotes -- 401
	for _index_0 = 1, #_list_0 do -- 401
		local remote = _list_0[_index_0] -- 401
		if (not remoteName or remote.name == remoteName) and remote.urls and remote.urls[1] then -- 402
			return remote.urls[1] -- 403
		end -- 402
	end -- 401
	return nil -- 404
end -- 397
local gitConfigRemoteURL -- 406
gitConfigRemoteURL = function(repoPath, remoteName) -- 406
	if remoteName == nil then -- 406
		remoteName = nil -- 406
	end -- 406
	if gitInvalidRepoPath(repoPath) then -- 407
		return nil -- 407
	end -- 407
	local configPath = Path(repoPath, ".git/config") -- 408
	if not Content:exist(configPath) then -- 409
		return nil -- 409
	end -- 409
	local content = Content:load(configPath) -- 410
	if not (content and content ~= "") then -- 411
		return nil -- 411
	end -- 411
	local currentRemote = nil -- 412
	for line in content:gmatch("[^\r\n]+") do -- 413
		local sectionRemote = line:match('^%s*%[remote%s+"([^"]+)"%]%s*$') -- 414
		if sectionRemote then -- 415
			currentRemote = sectionRemote -- 416
		elseif currentRemote and (not remoteName or currentRemote == remoteName) then -- 417
			local url = line:match("^%s*url%s*=%s*(.-)%s*$") -- 418
			if url and url ~= "" then -- 419
				return url -- 419
			end -- 419
		end -- 415
	end -- 413
	return nil -- 420
end -- 406
local gitCommandRemoteArg -- 422
gitCommandRemoteArg = function(args, startIndex) -- 422
	if startIndex == nil then -- 422
		startIndex = 2 -- 422
	end -- 422
	local index = startIndex -- 423
	while index <= #args do -- 424
		local arg = args[index] -- 425
		if ("-u" == arg or "--set-upstream" == arg or "-f" == arg or "--force" == arg or "--all" == arg or "--prune" == arg) then -- 426
			index = index + 1 -- 427
		elseif ("--depth" == arg or "-b" == arg or "--branch" == arg) then -- 428
			index = index + 2 -- 429
		elseif arg and arg:sub(1, 1) == "-" then -- 430
			index = index + 1 -- 431
		else -- 433
			return arg -- 433
		end -- 426
	end -- 424
	return nil -- 434
end -- 422
local gitCommandHost -- 436
gitCommandHost = function(repoPath, command) -- 436
	local args = gitShellSplit(command) -- 437
	if not args[1] then -- 438
		return nil -- 438
	end -- 438
	do -- 439
		local _exp_0 = args[1] -- 439
		if "clone" == _exp_0 or "ls-remote" == _exp_0 then -- 440
			return gitHostFromURL(args[2]) -- 441
		elseif "fetch" == _exp_0 or "pull" == _exp_0 or "push" == _exp_0 then -- 442
			local remoteArg = gitCommandRemoteArg(args, 2) -- 443
			if not remoteArg then -- 444
				return nil -- 444
			end -- 444
			local url = gitHostFromURL(remoteArg) -- 445
			if url then -- 446
				return url -- 446
			end -- 446
			return gitHostFromURL(gitConfigRemoteURL(repoPath, remoteArg)) -- 447
		end -- 439
	end -- 439
	return nil -- 448
end -- 436
local gitAuthSelectionForCommand -- 450
gitAuthSelectionForCommand = function(repoPath, command) -- 450
	local host = gitCommandHost(repoPath, command) -- 451
	if not host then -- 452
		return nil -- 452
	end -- 452
	local items = gitCredentialsForHost(host) -- 453
	if #items == 0 then -- 454
		return nil -- 454
	end -- 454
	return { -- 455
		host = host, -- 455
		items = items -- 455
	} -- 455
end -- 450
local gitDefaultRemote -- 457
gitDefaultRemote = function(remoteStatus) -- 457
	local data = remoteStatus and remoteStatus.data -- 458
	if not (data and data.remotes and data.remotes[1]) then -- 459
		return nil -- 459
	end -- 459
	return data.remotes[1] -- 460
end -- 457
local gitCurrentBranch -- 462
gitCurrentBranch = function(branchStatus) -- 462
	local data = branchStatus and branchStatus.data -- 463
	if data and data.current and data.current ~= "" then -- 464
		return data.current -- 465
	end -- 464
	if data and data.branches then -- 466
		local _list_0 = data.branches -- 467
		for _index_0 = 1, #_list_0 do -- 467
			local branch = _list_0[_index_0] -- 467
			if branch.current then -- 468
				return branch.name -- 468
			end -- 468
		end -- 467
	end -- 466
	return nil -- 469
end -- 462
local gitHeadBranch -- 471
gitHeadBranch = function(repoPath) -- 471
	if gitInvalidRepoPath(repoPath) then -- 472
		return nil -- 472
	end -- 472
	local headPath = Path(repoPath, ".git", "HEAD") -- 473
	if not Content:exist(headPath) then -- 474
		return nil -- 474
	end -- 474
	local head = Content:load(headPath) -- 475
	if not head then -- 476
		return nil -- 476
	end -- 476
	local branch = head:match("^ref:%s*refs/heads/(.-)%s*$") -- 477
	if branch and branch ~= "" then -- 478
		return branch -- 478
	end -- 478
	return nil -- 479
end -- 471
local gitBranchesWithHead -- 481
gitBranchesWithHead = function(branchStatus, currentBranch) -- 481
	local branches = branchStatus and branchStatus.data and branchStatus.data.branches or { } -- 482
	if not (currentBranch and currentBranch ~= "") then -- 483
		return branches -- 483
	end -- 483
	for _index_0 = 1, #branches do -- 484
		local branch = branches[_index_0] -- 484
		if branch.name == currentBranch then -- 485
			return branches -- 485
		end -- 485
	end -- 484
	local withHead -- 486
	do -- 486
		local _accum_0 = { } -- 486
		local _len_0 = 1 -- 486
		for _index_0 = 1, #branches do -- 486
			local branch = branches[_index_0] -- 486
			_accum_0[_len_0] = branch -- 486
			_len_0 = _len_0 + 1 -- 486
		end -- 486
		withHead = _accum_0 -- 486
	end -- 486
	withHead[#withHead + 1] = { -- 487
		name = currentBranch, -- 487
		current = true, -- 487
		unborn = true -- 487
	} -- 487
	return withHead -- 488
end -- 481
local gitStatusMeansNotRepo -- 490
gitStatusMeansNotRepo = function(statusRes) -- 490
	local message = statusRes and (statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message)) or "" -- 491
	message = tostring(message):lower() -- 492
	return message:find("repository does not exist", 1, true) or message:find("not a git repository", 1, true) -- 493
end -- 490
local gitSummary -- 495
gitSummary = function(repoPath) -- 495
	local statusRes = gitRunSync(repoPath, "status", nil, 120) -- 496
	if not statusRes.success then -- 497
		if gitStatusMeansNotRepo(statusRes) then -- 498
			return { -- 499
				success = true, -- 499
				isRepo = false, -- 499
				message = statusRes.message, -- 499
				status = statusRes.status -- 499
			} -- 499
		end -- 498
		return { -- 500
			success = false, -- 500
			message = statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message) or "failed to check Git repository", -- 500
			status = statusRes.status -- 500
		} -- 500
	end -- 497
	local branchRes = gitRunSync(repoPath, "branch", nil, 120) -- 501
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 120) -- 502
	local status = statusRes.status -- 503
	local branchStatus = branchRes.status -- 504
	local remoteStatus = remoteRes.status -- 505
	local currentBranch = gitCurrentBranch(branchStatus) or gitHeadBranch(repoPath) -- 506
	local branches = gitBranchesWithHead(branchStatus, currentBranch) -- 507
	local logRes = gitRunSync(repoPath, "log --metadata-only -n 100", nil, 120) -- 508
	local logStatus -- 509
	if logRes.success then -- 509
		logStatus = logRes.status -- 510
	else -- 512
		logStatus = { -- 513
			state = "done", -- 513
			kind = "log", -- 514
			repoPath = repoPath, -- 515
			progress = 1, -- 516
			message = "git log completed", -- 517
			data = { -- 518
				commits = { } -- 518
			} -- 518
		} -- 512
	end -- 509
	local hasCommit = logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] ~= nil -- 520
	local tagStatus -- 521
	if hasCommit then -- 521
		tagStatus = (gitRunSync(repoPath, "tag", nil, 120)).status -- 522
	else -- 524
		tagStatus = { -- 525
			state = "done", -- 525
			kind = "tag", -- 526
			repoPath = repoPath, -- 527
			progress = 1, -- 528
			message = "git tag completed", -- 529
			data = { -- 530
				tags = { } -- 530
			} -- 530
		} -- 524
	end -- 521
	local defaultRemote = gitDefaultRemote(remoteStatus) -- 532
	local lastCommit = nil -- 533
	if logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] then -- 534
		lastCommit = logStatus.data.commits[1] -- 535
	end -- 534
	return { -- 537
		success = true, -- 537
		isRepo = true, -- 538
		clean = status.data and status.data.clean or false, -- 539
		currentBranch = currentBranch, -- 540
		defaultRemote = defaultRemote, -- 541
		remotes = remoteStatus and remoteStatus.data and remoteStatus.data.remotes or { }, -- 542
		branches = branches, -- 543
		lastCommit = lastCommit, -- 544
		status = status, -- 545
		branchStatus = branchStatus, -- 546
		remoteStatus = remoteStatus, -- 547
		historyStatus = logStatus, -- 548
		tagStatus = tagStatus -- 549
	} -- 536
end -- 495
HttpServer:post("/git/run", function(req) -- 551
	do -- 552
		local _type_0 = type(req) -- 552
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 552
		if _tab_0 then -- 552
			local body = req.body -- 552
			if body ~= nil then -- 552
				local repoPath, command, authId, optionsJSON = body.repoPath, body.command, body.authId, body.optionsJSON -- 553
				if authId and not optionsJSON then -- 554
					local credential = gitLoadCredential(authId) -- 555
					if credential then -- 555
						optionsJSON = gitAuthOptionsJSON(credential) -- 556
						DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 557
							os.time(), -- 557
							credential.id -- 557
						}) -- 557
					end -- 555
				elseif not optionsJSON then -- 558
					local authOk, authSelection = pcall(gitAuthSelectionForCommand, repoPath, command) -- 559
					if not authOk then -- 560
						authSelection = nil -- 560
					end -- 560
					if authSelection then -- 561
						if #authSelection.items == 1 then -- 562
							local credential = gitLoadCredential(authSelection.items[1].id) -- 563
							optionsJSON = gitAuthOptionsJSON(credential) -- 564
							DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 565
								os.time(), -- 565
								credential.id -- 565
							}) -- 565
						else -- 567
							return { -- 567
								success = false, -- 567
								message = "select a Git credential", -- 567
								needsCredentialSelection = true, -- 567
								host = authSelection.host, -- 567
								credentials = authSelection.items -- 567
							} -- 567
						end -- 562
					end -- 561
				end -- 554
				local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 568
				if not jobId then -- 569
					return { -- 569
						success = false, -- 569
						message = err -- 569
					} -- 569
				end -- 569
				return { -- 570
					success = true, -- 570
					jobId = jobId -- 570
				} -- 570
			end -- 552
		end -- 552
	end -- 552
	return invalidArguments -- 551
end) -- 551
HttpServer:post("/git/status", function(req) -- 572
	do -- 573
		local _type_0 = type(req) -- 573
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 573
		if _tab_0 then -- 573
			local jobId -- 573
			do -- 573
				local _obj_0 = req.body -- 573
				local _type_1 = type(_obj_0) -- 573
				if "table" == _type_1 or "userdata" == _type_1 then -- 573
					jobId = _obj_0.jobId -- 573
				end -- 573
			end -- 573
			if jobId ~= nil then -- 573
				local job = GitJobs[tonumber(jobId) or 0] -- 574
				if not job then -- 575
					return { -- 575
						success = false, -- 575
						message = "git job not found" -- 575
					} -- 575
				end -- 575
				return { -- 576
					success = true, -- 576
					status = job.status, -- 576
					command = job.command -- 576
				} -- 576
			end -- 573
		end -- 573
	end -- 573
	return invalidArguments -- 572
end) -- 572
HttpServer:post("/git/cancel", function(req) -- 578
	do -- 579
		local _type_0 = type(req) -- 579
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 579
		if _tab_0 then -- 579
			local jobId -- 579
			do -- 579
				local _obj_0 = req.body -- 579
				local _type_1 = type(_obj_0) -- 579
				if "table" == _type_1 or "userdata" == _type_1 then -- 579
					jobId = _obj_0.jobId -- 579
				end -- 579
			end -- 579
			if jobId ~= nil then -- 579
				local id = tonumber(jobId) -- 580
				if not id then -- 581
					return { -- 581
						success = false, -- 581
						message = "invalid jobId" -- 581
					} -- 581
				end -- 581
				return { -- 582
					success = Git:cancel(id) -- 582
				} -- 582
			end -- 579
		end -- 579
	end -- 579
	return invalidArguments -- 578
end) -- 578
HttpServer:postSchedule("/git/summary", function(req) -- 584
	do -- 585
		local _type_0 = type(req) -- 585
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 585
		if _tab_0 then -- 585
			local repoPath -- 585
			do -- 585
				local _obj_0 = req.body -- 585
				local _type_1 = type(_obj_0) -- 585
				if "table" == _type_1 or "userdata" == _type_1 then -- 585
					repoPath = _obj_0.repoPath -- 585
				end -- 585
			end -- 585
			if repoPath ~= nil then -- 585
				if gitInvalidRepoPath(repoPath) then -- 586
					return { -- 586
						success = false, -- 586
						message = "invalid repoPath" -- 586
					} -- 586
				end -- 586
				return gitSummary(repoPath) -- 587
			end -- 585
		end -- 585
	end -- 585
	return invalidArguments -- 584
end) -- 584
HttpServer:postSchedule("/git/status-files", function(req) -- 589
	do -- 590
		local _type_0 = type(req) -- 590
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 590
		if _tab_0 then -- 590
			local repoPath -- 590
			do -- 590
				local _obj_0 = req.body -- 590
				local _type_1 = type(_obj_0) -- 590
				if "table" == _type_1 or "userdata" == _type_1 then -- 590
					repoPath = _obj_0.repoPath -- 590
				end -- 590
			end -- 590
			if repoPath ~= nil then -- 590
				return gitRunSync(repoPath, "status", nil, 120) -- 591
			end -- 590
		end -- 590
	end -- 590
	return invalidArguments -- 589
end) -- 589
HttpServer:postSchedule("/git/discard-untracked", function(req) -- 593
	do -- 594
		local _type_0 = type(req) -- 594
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 594
		if _tab_0 then -- 594
			local body = req.body -- 594
			if body ~= nil then -- 594
				local repoPath, paths = body.repoPath, body.paths -- 595
				if gitInvalidRepoPath(repoPath) then -- 596
					return { -- 596
						success = false, -- 596
						message = "invalid repoPath" -- 596
					} -- 596
				end -- 596
				if not (type(paths) == "table") then -- 597
					return { -- 597
						success = false, -- 597
						message = "invalid paths" -- 597
					} -- 597
				end -- 597
				local statusRes = gitRunSync(repoPath, "status", nil, 10) -- 598
				if not statusRes.success then -- 599
					return statusRes -- 599
				end -- 599
				local untracked = { } -- 600
				local _list_0 = (statusRes.status.data and statusRes.status.data.files or { }) -- 601
				for _index_0 = 1, #_list_0 do -- 601
					local file = _list_0[_index_0] -- 601
					if file.staging == "?" or file.worktree == "?" then -- 602
						untracked[file.path] = true -- 603
					end -- 602
				end -- 601
				local removed = { } -- 604
				for _index_0 = 1, #paths do -- 605
					local relPath = paths[_index_0] -- 605
					relPath = tostring(relPath) -- 606
					if not gitPathInsideRepo(repoPath, relPath) then -- 607
						return { -- 607
							success = false, -- 607
							message = "unsafe path: " .. tostring(relPath) -- 607
						} -- 607
					end -- 607
					if not untracked[relPath] then -- 608
						return { -- 608
							success = false, -- 608
							message = "path is not untracked: " .. tostring(relPath) -- 608
						} -- 608
					end -- 608
				end -- 605
				for _index_0 = 1, #paths do -- 609
					local relPath = paths[_index_0] -- 609
					local targetPath = Path(repoPath, tostring(relPath)) -- 610
					if Content:exist(targetPath) then -- 611
						Content:remove(targetPath) -- 612
						removed[#removed + 1] = tostring(relPath) -- 613
					end -- 611
				end -- 609
				return { -- 614
					success = true, -- 614
					removed = removed -- 614
				} -- 614
			end -- 594
		end -- 594
	end -- 594
	return invalidArguments -- 593
end) -- 593
HttpServer:postSchedule("/git/file-diff", function(req) -- 616
	do -- 617
		local _type_0 = type(req) -- 617
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 617
		if _tab_0 then -- 617
			local body = req.body -- 617
			if body ~= nil then -- 617
				local repoPath, path, staged = body.repoPath, body.path, body.staged -- 618
				if gitInvalidRepoPath(repoPath) then -- 619
					return { -- 619
						success = false, -- 619
						message = "invalid repoPath" -- 619
					} -- 619
				end -- 619
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 620
					return { -- 620
						success = false, -- 620
						message = "unsafe path" -- 620
					} -- 620
				end -- 620
				local command -- 621
				if staged == true then -- 621
					command = "diff --staged -- " .. tostring(gitQuote(path)) -- 622
				else -- 624
					command = "diff -- " .. tostring(gitQuote(path)) -- 624
				end -- 621
				local res = gitRunSync(repoPath, command, nil, 10) -- 625
				if not res.success then -- 626
					return res -- 626
				end -- 626
				return { -- 627
					success = true, -- 627
					status = res.status, -- 627
					data = res.status and res.status.data -- 627
				} -- 627
			end -- 617
		end -- 617
	end -- 617
	return invalidArguments -- 616
end) -- 616
HttpServer:postSchedule("/git/commit-file-diff", function(req) -- 629
	do -- 630
		local _type_0 = type(req) -- 630
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 630
		if _tab_0 then -- 630
			local body = req.body -- 630
			if body ~= nil then -- 630
				local repoPath, commit, path = body.repoPath, body.commit, body.path -- 631
				if gitInvalidRepoPath(repoPath) then -- 632
					return { -- 632
						success = false, -- 632
						message = "invalid repoPath" -- 632
					} -- 632
				end -- 632
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 633
					return { -- 633
						success = false, -- 633
						message = "invalid commit" -- 633
					} -- 633
				end -- 633
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 634
					return { -- 634
						success = false, -- 634
						message = "unsafe path" -- 634
					} -- 634
				end -- 634
				local res = gitRunSync(repoPath, "diff " .. tostring(gitQuote(commit)) .. " -- " .. tostring(gitQuote(path)), nil, 10) -- 635
				if not res.success then -- 636
					return res -- 636
				end -- 636
				return { -- 637
					success = true, -- 637
					status = res.status, -- 637
					data = res.status and res.status.data -- 637
				} -- 637
			end -- 630
		end -- 630
	end -- 630
	return invalidArguments -- 629
end) -- 629
HttpServer:postSchedule("/git/history", function(req) -- 639
	do -- 640
		local _type_0 = type(req) -- 640
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 640
		if _tab_0 then -- 640
			local body = req.body -- 640
			if body ~= nil then -- 640
				local repoPath, limit = body.repoPath, body.limit -- 641
				limit = math.max(1, math.min(100, tonumber(limit) or 20)) -- 642
				return gitRunSync(repoPath, "log --metadata-only -n " .. tostring(limit), nil, 10) -- 643
			end -- 640
		end -- 640
	end -- 640
	return invalidArguments -- 639
end) -- 639
HttpServer:postSchedule("/git/remotes", function(req) -- 645
	do -- 646
		local _type_0 = type(req) -- 646
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 646
		if _tab_0 then -- 646
			local body = req.body -- 646
			if body ~= nil then -- 646
				local repoPath, command = body.repoPath, body.command -- 647
				command = command or "remote -v" -- 648
				return gitRunSync(repoPath, command, nil, 10) -- 649
			end -- 646
		end -- 646
	end -- 646
	return invalidArguments -- 645
end) -- 645
HttpServer:postSchedule("/git/branches", function(req) -- 651
	do -- 652
		local _type_0 = type(req) -- 652
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 652
		if _tab_0 then -- 652
			local body = req.body -- 652
			if body ~= nil then -- 652
				local repoPath, command = body.repoPath, body.command -- 653
				command = command or "branch" -- 654
				return gitRunSync(repoPath, command, nil, 10) -- 655
			end -- 652
		end -- 652
	end -- 652
	return invalidArguments -- 651
end) -- 651
HttpServer:postSchedule("/git/tags", function(req) -- 657
	do -- 658
		local _type_0 = type(req) -- 658
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 658
		if _tab_0 then -- 658
			local body = req.body -- 658
			if body ~= nil then -- 658
				local repoPath, command = body.repoPath, body.command -- 659
				command = command or "tag" -- 660
				return gitRunSync(repoPath, command, nil, 10) -- 661
			end -- 658
		end -- 658
	end -- 658
	return invalidArguments -- 657
end) -- 657
HttpServer:post("/git/profile/get", function() -- 663
	ensureGitTables() -- 664
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 665
	local profile -- 666
	if rows and rows[1] then -- 666
		profile = { -- 667
			name = rows[1][1], -- 667
			email = rows[1][2] -- 667
		} -- 667
	else -- 669
		profile = { -- 669
			name = "", -- 669
			email = "" -- 669
		} -- 669
	end -- 666
	return { -- 670
		success = true, -- 670
		profile = profile -- 670
	} -- 670
end) -- 663
HttpServer:post("/git/profile/save", function(req) -- 672
	do -- 673
		local _type_0 = type(req) -- 673
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 673
		if _tab_0 then -- 673
			local name -- 673
			do -- 673
				local _obj_0 = req.body -- 673
				local _type_1 = type(_obj_0) -- 673
				if "table" == _type_1 or "userdata" == _type_1 then -- 673
					name = _obj_0.name -- 673
				end -- 673
			end -- 673
			local email -- 673
			do -- 673
				local _obj_0 = req.body -- 673
				local _type_1 = type(_obj_0) -- 673
				if "table" == _type_1 or "userdata" == _type_1 then -- 673
					email = _obj_0.email -- 673
				end -- 673
			end -- 673
			if name ~= nil and email ~= nil then -- 673
				ensureGitTables() -- 674
				DB:exec("insert into GitProfile(id, name, email, updated_at) values(1, ?, ?, ?) on conflict(id) do update set name = excluded.name, email = excluded.email, updated_at = excluded.updated_at", { -- 676
					tostring(name or ""), -- 676
					tostring(email or ""), -- 677
					os.time() -- 678
				}) -- 675
				return { -- 680
					success = true -- 680
				} -- 680
			end -- 673
		end -- 673
	end -- 673
	return invalidArguments -- 672
end) -- 672
HttpServer:post("/git/auth/list", function(req) -- 682
	ensureGitTables() -- 683
	local host = nil -- 684
	do -- 685
		local _type_0 = type(req) -- 685
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 685
		if _tab_0 then -- 685
			local body = req.body -- 685
			if body ~= nil then -- 685
				host = body.host -- 686
			end -- 685
		end -- 685
	end -- 685
	local rows -- 687
	if host and host ~= "" then -- 687
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by host asc, label asc, id asc", { -- 688
			tostring(host):lower() -- 688
		}) -- 688
	else -- 690
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential order by host asc, label asc, id asc") -- 690
	end -- 687
	local items -- 691
	if rows then -- 691
		local _accum_0 = { } -- 691
		local _len_0 = 1 -- 691
		for _index_0 = 1, #rows do -- 691
			local row = rows[_index_0] -- 691
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 691
			_len_0 = _len_0 + 1 -- 691
		end -- 691
		items = _accum_0 -- 691
	else -- 691
		items = { } -- 691
	end -- 691
	return { -- 692
		success = true, -- 692
		items = items -- 692
	} -- 692
end) -- 682
HttpServer:postSchedule("/git/auth/match", function(req) -- 694
	do -- 695
		local _type_0 = type(req) -- 695
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 695
		if _tab_0 then -- 695
			local body = req.body -- 695
			if body ~= nil then -- 695
				if not (type(body) == "table") then -- 696
					return invalidArguments -- 696
				end -- 696
				local repoPath, command, url = body.repoPath, body.command, body.url -- 697
				if url ~= nil and type(url) ~= "string" then -- 698
					return invalidArguments -- 698
				end -- 698
				if not (type(url) == "string" and url ~= "") then -- 699
					if not (type(repoPath) == "string" and type(command) == "string") then -- 700
						return invalidArguments -- 700
					end -- 700
				end -- 699
				local host -- 701
				if url and url ~= "" then -- 701
					host = gitHostFromURL(url) -- 701
				else -- 701
					host = gitCommandHost(repoPath, command) -- 701
				end -- 701
				if not host then -- 702
					return { -- 702
						success = false, -- 702
						message = "git host is required" -- 702
					} -- 702
				end -- 702
				local items = gitCredentialsForHost(host) -- 703
				return { -- 704
					success = true, -- 704
					host = host, -- 704
					items = items, -- 704
					needsSelection = #items > 1, -- 704
					authId = (#items == 1 and items[1].id or nil) -- 704
				} -- 704
			end -- 695
		end -- 695
	end -- 695
	return invalidArguments -- 694
end) -- 694
HttpServer:post("/git/auth/save", function(req) -- 706
	do -- 707
		local _type_0 = type(req) -- 707
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 707
		if _tab_0 then -- 707
			local body = req.body -- 707
			if body ~= nil then -- 707
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token -- 708
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$") -- 709
				label = tostring(label or ""):match("^%s*(.-)%s*$") -- 710
				local credentialType = tostring(body.type or "token") -- 711
				username = tostring(username or "") -- 712
				local secret -- 713
				if credentialType == "basic" then -- 713
					secret = tostring(password or "") -- 713
				else -- 713
					secret = tostring(token or password or "") -- 713
				end -- 713
				if host == "" then -- 714
					return { -- 714
						success = false, -- 714
						message = "host is required" -- 714
					} -- 714
				end -- 714
				if label == "" then -- 715
					return { -- 715
						success = false, -- 715
						message = "label is required" -- 715
					} -- 715
				end -- 715
				if secret == "" then -- 716
					return { -- 716
						success = false, -- 716
						message = "secret is required" -- 716
					} -- 716
				end -- 716
				if not (("basic" == credentialType or "token" == credentialType)) then -- 717
					return { -- 717
						success = false, -- 717
						message = "invalid type" -- 717
					} -- 717
				end -- 717
				ensureGitTables() -- 718
				local now = os.time() -- 719
				if id then -- 720
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", { -- 722
						host, -- 722
						label, -- 722
						credentialType, -- 722
						username, -- 722
						secret, -- 722
						now, -- 722
						(tonumber(id) or 0) -- 722
					}) -- 721
					return { -- 724
						success = true, -- 724
						id = tonumber(id) -- 724
					} -- 724
				else -- 726
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", { -- 727
						host, -- 727
						label, -- 727
						credentialType, -- 727
						username, -- 727
						secret, -- 727
						now, -- 727
						now -- 727
					}) -- 726
					local rows = DB:query("select last_insert_rowid()") -- 729
					return { -- 730
						success = true, -- 730
						id = rows and rows[1] and rows[1][1] -- 730
					} -- 730
				end -- 720
			end -- 707
		end -- 707
	end -- 707
	return invalidArguments -- 706
end) -- 706
HttpServer:post("/git/auth/delete", function(req) -- 732
	do -- 733
		local _type_0 = type(req) -- 733
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 733
		if _tab_0 then -- 733
			local id -- 733
			do -- 733
				local _obj_0 = req.body -- 733
				local _type_1 = type(_obj_0) -- 733
				if "table" == _type_1 or "userdata" == _type_1 then -- 733
					id = _obj_0.id -- 733
				end -- 733
			end -- 733
			if id ~= nil then -- 733
				ensureGitTables() -- 734
				local credentialId = tonumber(id) or 0 -- 735
				DB:exec("delete from GitCredential where id = ?", { -- 736
					credentialId -- 736
				}) -- 736
				return { -- 737
					success = true -- 737
				} -- 737
			end -- 733
		end -- 733
	end -- 733
	return invalidArguments -- 732
end) -- 732
HttpServer:postSchedule("/git/auth/test", function(req) -- 739
	do -- 740
		local _type_0 = type(req) -- 740
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 740
		if _tab_0 then -- 740
			local body = req.body -- 740
			if body ~= nil then -- 740
				local repoPath, url, authId = body.repoPath, body.url, body.authId -- 741
				local credential = gitLoadCredential(authId) -- 742
				local optionsJSON = gitAuthOptionsJSON(credential) -- 743
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20) -- 744
			end -- 740
		end -- 740
	end -- 740
	return invalidArguments -- 739
end) -- 739
HttpServer:post("/agent/session/create", function(req) -- 746
	do -- 747
		local _type_0 = type(req) -- 747
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 747
		if _tab_0 then -- 747
			local projectRoot -- 747
			do -- 747
				local _obj_0 = req.body -- 747
				local _type_1 = type(_obj_0) -- 747
				if "table" == _type_1 or "userdata" == _type_1 then -- 747
					projectRoot = _obj_0.projectRoot -- 747
				end -- 747
			end -- 747
			local title -- 747
			do -- 747
				local _obj_0 = req.body -- 747
				local _type_1 = type(_obj_0) -- 747
				if "table" == _type_1 or "userdata" == _type_1 then -- 747
					title = _obj_0.title -- 747
				end -- 747
			end -- 747
			if projectRoot ~= nil and title ~= nil then -- 747
				return AgentSession.createSession(projectRoot, title) -- 748
			end -- 747
		end -- 747
	end -- 747
	return invalidArguments -- 746
end) -- 746
HttpServer:post("/agent/session/create-sub", function(req) -- 750
	do -- 751
		local _type_0 = type(req) -- 751
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 751
		if _tab_0 then -- 751
			local parentSessionId -- 751
			do -- 751
				local _obj_0 = req.body -- 751
				local _type_1 = type(_obj_0) -- 751
				if "table" == _type_1 or "userdata" == _type_1 then -- 751
					parentSessionId = _obj_0.parentSessionId -- 751
				end -- 751
			end -- 751
			local title -- 751
			do -- 751
				local _obj_0 = req.body -- 751
				local _type_1 = type(_obj_0) -- 751
				if "table" == _type_1 or "userdata" == _type_1 then -- 751
					title = _obj_0.title -- 751
				end -- 751
			end -- 751
			if parentSessionId ~= nil and title ~= nil then -- 751
				return AgentSession.createSubSession(parentSessionId, title) -- 752
			end -- 751
		end -- 751
	end -- 751
	return invalidArguments -- 750
end) -- 750
HttpServer:post("/agent/session/get", function(req) -- 754
	do -- 755
		local _type_0 = type(req) -- 755
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 755
		if _tab_0 then -- 755
			local sessionId -- 755
			do -- 755
				local _obj_0 = req.body -- 755
				local _type_1 = type(_obj_0) -- 755
				if "table" == _type_1 or "userdata" == _type_1 then -- 755
					sessionId = _obj_0.sessionId -- 755
				end -- 755
			end -- 755
			if sessionId ~= nil then -- 755
				return AgentSession.getSession(sessionId) -- 756
			end -- 755
		end -- 755
	end -- 755
	return invalidArguments -- 754
end) -- 754
HttpServer:post("/agent/vision/asset", function(req) -- 758
	do -- 759
		local _type_0 = type(req) -- 759
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 759
		if _tab_0 then -- 759
			local sessionId -- 759
			do -- 759
				local _obj_0 = req.body -- 759
				local _type_1 = type(_obj_0) -- 759
				if "table" == _type_1 or "userdata" == _type_1 then -- 759
					sessionId = _obj_0.sessionId -- 759
				end -- 759
			end -- 759
			local path -- 759
			do -- 759
				local _obj_0 = req.body -- 759
				local _type_1 = type(_obj_0) -- 759
				if "table" == _type_1 or "userdata" == _type_1 then -- 759
					path = _obj_0.path -- 759
				end -- 759
			end -- 759
			if sessionId ~= nil and path ~= nil then -- 759
				return AgentVisionAssets.getSessionVisionImageFromPath(sessionId, path) -- 760
			end -- 759
		end -- 759
	end -- 759
	return invalidArguments -- 758
end) -- 758
HttpServer:post("/agent/session/mode", function(req) -- 762
	do -- 763
		local _type_0 = type(req) -- 763
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 763
		if _tab_0 then -- 763
			local sessionId -- 763
			do -- 763
				local _obj_0 = req.body -- 763
				local _type_1 = type(_obj_0) -- 763
				if "table" == _type_1 or "userdata" == _type_1 then -- 763
					sessionId = _obj_0.sessionId -- 763
				end -- 763
			end -- 763
			local workMode -- 763
			do -- 763
				local _obj_0 = req.body -- 763
				local _type_1 = type(_obj_0) -- 763
				if "table" == _type_1 or "userdata" == _type_1 then -- 763
					workMode = _obj_0.workMode -- 763
				end -- 763
			end -- 763
			if sessionId ~= nil and workMode ~= nil then -- 763
				return AgentSession.setWorkMode(sessionId, workMode) -- 764
			end -- 763
		end -- 763
	end -- 763
	return invalidArguments -- 762
end) -- 762
HttpServer:post("/agent/session/send", function(req) -- 766
	do -- 767
		local _type_0 = type(req) -- 767
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 767
		if _tab_0 then -- 767
			local sessionId -- 767
			do -- 767
				local _obj_0 = req.body -- 767
				local _type_1 = type(_obj_0) -- 767
				if "table" == _type_1 or "userdata" == _type_1 then -- 767
					sessionId = _obj_0.sessionId -- 767
				end -- 767
			end -- 767
			local prompt -- 767
			do -- 767
				local _obj_0 = req.body -- 767
				local _type_1 = type(_obj_0) -- 767
				if "table" == _type_1 or "userdata" == _type_1 then -- 767
					prompt = _obj_0.prompt -- 767
				end -- 767
			end -- 767
			if sessionId ~= nil and prompt ~= nil then -- 767
				return AgentSession.sendPrompt(sessionId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 768
			end -- 767
		end -- 767
	end -- 767
	return invalidArguments -- 766
end) -- 766
HttpServer:post("/agent/session/send-local", function(req) -- 770
	do -- 771
		local _type_0 = type(req) -- 771
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 771
		if _tab_0 then -- 771
			local sessionId -- 771
			do -- 771
				local _obj_0 = req.body -- 771
				local _type_1 = type(_obj_0) -- 771
				if "table" == _type_1 or "userdata" == _type_1 then -- 771
					sessionId = _obj_0.sessionId -- 771
				end -- 771
			end -- 771
			local prompt -- 771
			do -- 771
				local _obj_0 = req.body -- 771
				local _type_1 = type(_obj_0) -- 771
				if "table" == _type_1 or "userdata" == _type_1 then -- 771
					prompt = _obj_0.prompt -- 771
				end -- 771
			end -- 771
			local localAgentConfigId -- 771
			do -- 771
				local _obj_0 = req.body -- 771
				local _type_1 = type(_obj_0) -- 771
				if "table" == _type_1 or "userdata" == _type_1 then -- 771
					localAgentConfigId = _obj_0.localAgentConfigId -- 771
				end -- 771
			end -- 771
			if sessionId ~= nil and prompt ~= nil and localAgentConfigId ~= nil then -- 771
				return AgentSession.sendLocalPrompt(sessionId, prompt, localAgentConfigId) -- 772
			end -- 771
		end -- 771
	end -- 771
	return invalidArguments -- 770
end) -- 770
HttpServer:post("/agent/session/local/new", function(req) -- 774
	do -- 775
		local _type_0 = type(req) -- 775
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 775
		if _tab_0 then -- 775
			local sessionId -- 775
			do -- 775
				local _obj_0 = req.body -- 775
				local _type_1 = type(_obj_0) -- 775
				if "table" == _type_1 or "userdata" == _type_1 then -- 775
					sessionId = _obj_0.sessionId -- 775
				end -- 775
			end -- 775
			if sessionId ~= nil then -- 775
				return AgentLocalAgent.abandonSession(sessionId) -- 776
			end -- 775
		end -- 775
	end -- 775
	return invalidArguments -- 774
end) -- 774
HttpServer:post("/agent/session/local/info", function(req) -- 778
	do -- 779
		local _type_0 = type(req) -- 779
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 779
		if _tab_0 then -- 779
			local sessionId -- 779
			do -- 779
				local _obj_0 = req.body -- 779
				local _type_1 = type(_obj_0) -- 779
				if "table" == _type_1 or "userdata" == _type_1 then -- 779
					sessionId = _obj_0.sessionId -- 779
				end -- 779
			end -- 779
			if sessionId ~= nil then -- 779
				local info = AgentLocalAgent.getSessionInfo(sessionId) -- 780
				return { -- 781
					success = true, -- 781
					info = info -- 781
				} -- 781
			end -- 779
		end -- 779
	end -- 779
	return invalidArguments -- 778
end) -- 778
HttpServer:post("/agent/session/continue", function(req) -- 783
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
			if sessionId ~= nil then -- 784
				return AgentSession.continuePrompt(sessionId, req.body.disabledAgentTools, req.body.llmConfigId) -- 785
			end -- 784
		end -- 784
	end -- 784
	return invalidArguments -- 783
end) -- 783
HttpServer:post("/agent/session/finish-handoff", function(req) -- 787
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
			if sessionId ~= nil then -- 788
				return AgentSession.finishSubSessionHandoff(sessionId, req.body.llmConfigId) -- 789
			end -- 788
		end -- 788
	end -- 788
	return invalidArguments -- 787
end) -- 787
HttpServer:post("/agent/session/resend", function(req) -- 791
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
			local messageId -- 792
			do -- 792
				local _obj_0 = req.body -- 792
				local _type_1 = type(_obj_0) -- 792
				if "table" == _type_1 or "userdata" == _type_1 then -- 792
					messageId = _obj_0.messageId -- 792
				end -- 792
			end -- 792
			local prompt -- 792
			do -- 792
				local _obj_0 = req.body -- 792
				local _type_1 = type(_obj_0) -- 792
				if "table" == _type_1 or "userdata" == _type_1 then -- 792
					prompt = _obj_0.prompt -- 792
				end -- 792
			end -- 792
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 792
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 793
			end -- 792
		end -- 792
	end -- 792
	return invalidArguments -- 791
end) -- 791
HttpServer:post("/agent/session/questionnaire/respond", function(req) -- 795
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
			local questionnaireId -- 796
			do -- 796
				local _obj_0 = req.body -- 796
				local _type_1 = type(_obj_0) -- 796
				if "table" == _type_1 or "userdata" == _type_1 then -- 796
					questionnaireId = _obj_0.questionnaireId -- 796
				end -- 796
			end -- 796
			local answers -- 796
			do -- 796
				local _obj_0 = req.body -- 796
				local _type_1 = type(_obj_0) -- 796
				if "table" == _type_1 or "userdata" == _type_1 then -- 796
					answers = _obj_0.answers -- 796
				end -- 796
			end -- 796
			if sessionId ~= nil and questionnaireId ~= nil and answers ~= nil then -- 796
				return AgentSession.respondQuestionnaire(sessionId, questionnaireId, answers, req.body.llmConfigId) -- 797
			end -- 796
		end -- 796
	end -- 796
	return invalidArguments -- 795
end) -- 795
HttpServer:post("/agent/session/questionnaire/cancel", function(req) -- 799
	do -- 800
		local _type_0 = type(req) -- 800
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 800
		if _tab_0 then -- 800
			local sessionId -- 800
			do -- 800
				local _obj_0 = req.body -- 800
				local _type_1 = type(_obj_0) -- 800
				if "table" == _type_1 or "userdata" == _type_1 then -- 800
					sessionId = _obj_0.sessionId -- 800
				end -- 800
			end -- 800
			local questionnaireId -- 800
			do -- 800
				local _obj_0 = req.body -- 800
				local _type_1 = type(_obj_0) -- 800
				if "table" == _type_1 or "userdata" == _type_1 then -- 800
					questionnaireId = _obj_0.questionnaireId -- 800
				end -- 800
			end -- 800
			if sessionId ~= nil and questionnaireId ~= nil then -- 800
				return AgentSession.cancelQuestionnaire(sessionId, questionnaireId, req.body.llmConfigId) -- 801
			end -- 800
		end -- 800
	end -- 800
	return invalidArguments -- 799
end) -- 799
HttpServer:post("/agent/task/status", function(req) -- 803
	do -- 804
		local _type_0 = type(req) -- 804
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 804
		if _tab_0 then -- 804
			local sessionId -- 804
			do -- 804
				local _obj_0 = req.body -- 804
				local _type_1 = type(_obj_0) -- 804
				if "table" == _type_1 or "userdata" == _type_1 then -- 804
					sessionId = _obj_0.sessionId -- 804
				end -- 804
			end -- 804
			if sessionId ~= nil then -- 804
				local res = AgentSession.getSession(sessionId) -- 805
				if not res.success then -- 806
					return res -- 806
				end -- 806
				local taskId = res.session.currentTaskId -- 807
				local checkpoints -- 808
				if taskId then -- 808
					checkpoints = AgentTools.listCheckpoints(taskId) -- 808
				else -- 808
					checkpoints = { } -- 808
				end -- 808
				return { -- 810
					success = true, -- 810
					session = res.session, -- 811
					relatedSessions = res.relatedSessions, -- 812
					spawnInfo = res.spawnInfo, -- 813
					messages = res.messages, -- 814
					steps = res.steps, -- 815
					checkpoints = checkpoints, -- 816
					pendingQuestionnaire = res.pendingQuestionnaire, -- 817
					hasActivePlan = res.hasActivePlan -- 818
				} -- 809
			end -- 804
		end -- 804
	end -- 804
	return invalidArguments -- 803
end) -- 803
HttpServer:post("/agent/task/running", function() -- 820
	local res = AgentSession.listRunningSessions() -- 821
	if res.success and #res.sessions == 0 then -- 822
		res.sessions = nil -- 823
	end -- 822
	return res -- 824
end) -- 820
HttpServer:post("/agent/task/stop", function(req) -- 826
	do -- 827
		local _type_0 = type(req) -- 827
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 827
		if _tab_0 then -- 827
			local sessionId -- 827
			do -- 827
				local _obj_0 = req.body -- 827
				local _type_1 = type(_obj_0) -- 827
				if "table" == _type_1 or "userdata" == _type_1 then -- 827
					sessionId = _obj_0.sessionId -- 827
				end -- 827
			end -- 827
			if sessionId ~= nil then -- 827
				return AgentSession.stopSessionTask(sessionId) -- 828
			end -- 827
		end -- 827
	end -- 827
	return invalidArguments -- 826
end) -- 826
HttpServer:post("/agent/checkpoint/list", function(req) -- 830
	do -- 831
		local _type_0 = type(req) -- 831
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 831
		if _tab_0 then -- 831
			local taskId -- 831
			do -- 831
				local _obj_0 = req.body -- 831
				local _type_1 = type(_obj_0) -- 831
				if "table" == _type_1 or "userdata" == _type_1 then -- 831
					taskId = _obj_0.taskId -- 831
				end -- 831
			end -- 831
			local sessionId -- 831
			do -- 831
				local _obj_0 = req.body -- 831
				local _type_1 = type(_obj_0) -- 831
				if "table" == _type_1 or "userdata" == _type_1 then -- 831
					sessionId = _obj_0.sessionId -- 831
				end -- 831
			end -- 831
			if sessionId ~= nil then -- 831
				if not taskId and sessionId then -- 832
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 833
				end -- 832
				if not taskId then -- 834
					return { -- 834
						success = false, -- 834
						message = "task not found" -- 834
					} -- 834
				end -- 834
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 835
				if not access.success then -- 836
					return access -- 836
				end -- 836
				return { -- 838
					success = true, -- 838
					taskId = taskId, -- 839
					checkpoints = AgentTools.listCheckpoints(taskId) -- 840
				} -- 837
			end -- 831
		end -- 831
	end -- 831
	return invalidArguments -- 830
end) -- 830
HttpServer:post("/agent/checkpoint/diff", function(req) -- 842
	do -- 843
		local _type_0 = type(req) -- 843
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 843
		if _tab_0 then -- 843
			local sessionId -- 843
			do -- 843
				local _obj_0 = req.body -- 843
				local _type_1 = type(_obj_0) -- 843
				if "table" == _type_1 or "userdata" == _type_1 then -- 843
					sessionId = _obj_0.sessionId -- 843
				end -- 843
			end -- 843
			local checkpointId -- 843
			do -- 843
				local _obj_0 = req.body -- 843
				local _type_1 = type(_obj_0) -- 843
				if "table" == _type_1 or "userdata" == _type_1 then -- 843
					checkpointId = _obj_0.checkpointId -- 843
				end -- 843
			end -- 843
			if sessionId ~= nil and checkpointId ~= nil then -- 843
				if not (checkpointId > 0) then -- 844
					return { -- 844
						success = false, -- 844
						message = "invalid checkpointId" -- 844
					} -- 844
				end -- 844
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 845
				if not access.success then -- 846
					return access -- 846
				end -- 846
				return AgentTools.getCheckpointDiff(checkpointId) -- 847
			end -- 843
		end -- 843
	end -- 843
	return invalidArguments -- 842
end) -- 842
HttpServer:post("/agent/task/diff", function(req) -- 849
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
			local taskId -- 850
			do -- 850
				local _obj_0 = req.body -- 850
				local _type_1 = type(_obj_0) -- 850
				if "table" == _type_1 or "userdata" == _type_1 then -- 850
					taskId = _obj_0.taskId -- 850
				end -- 850
			end -- 850
			if sessionId ~= nil and taskId ~= nil then -- 850
				if not (taskId > 0) then -- 851
					return { -- 851
						success = false, -- 851
						message = "invalid taskId" -- 851
					} -- 851
				end -- 851
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 852
				if not access.success then -- 853
					return access -- 853
				end -- 853
				return AgentTools.getTaskChangeSetDiff(taskId) -- 854
			end -- 850
		end -- 850
	end -- 850
	return invalidArguments -- 849
end) -- 849
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 856
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
			local checkpointId -- 857
			do -- 857
				local _obj_0 = req.body -- 857
				local _type_1 = type(_obj_0) -- 857
				if "table" == _type_1 or "userdata" == _type_1 then -- 857
					checkpointId = _obj_0.checkpointId -- 857
				end -- 857
			end -- 857
			if sessionId ~= nil and checkpointId ~= nil then -- 857
				if not (checkpointId > 0) then -- 858
					return { -- 858
						success = false, -- 858
						message = "invalid checkpointId" -- 858
					} -- 858
				end -- 858
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 859
				if not access.success then -- 860
					return access -- 860
				end -- 860
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, access.session.projectRoot) -- 861
				if not rollbackRes.success then -- 862
					return rollbackRes -- 862
				end -- 862
				return { -- 864
					success = true, -- 864
					checkpointId = rollbackRes.checkpointId -- 865
				} -- 863
			end -- 857
		end -- 857
	end -- 857
	return invalidArguments -- 856
end) -- 856
HttpServer:post("/agent/task/rollback", function(req) -- 867
	do -- 868
		local _type_0 = type(req) -- 868
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 868
		if _tab_0 then -- 868
			local sessionId -- 868
			do -- 868
				local _obj_0 = req.body -- 868
				local _type_1 = type(_obj_0) -- 868
				if "table" == _type_1 or "userdata" == _type_1 then -- 868
					sessionId = _obj_0.sessionId -- 868
				end -- 868
			end -- 868
			local taskId -- 868
			do -- 868
				local _obj_0 = req.body -- 868
				local _type_1 = type(_obj_0) -- 868
				if "table" == _type_1 or "userdata" == _type_1 then -- 868
					taskId = _obj_0.taskId -- 868
				end -- 868
			end -- 868
			if sessionId ~= nil and taskId ~= nil then -- 868
				if not (taskId > 0) then -- 869
					return { -- 869
						success = false, -- 869
						message = "invalid taskId" -- 869
					} -- 869
				end -- 869
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 870
				if not access.success then -- 871
					return access -- 871
				end -- 871
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, access.session.projectRoot) -- 872
				if not rollbackRes.success then -- 873
					return rollbackRes -- 873
				end -- 873
				return { -- 875
					success = true, -- 875
					taskId = rollbackRes.taskId, -- 876
					checkpointId = rollbackRes.checkpointId, -- 877
					checkpointCount = rollbackRes.checkpointCount -- 878
				} -- 874
			end -- 868
		end -- 868
	end -- 868
	return invalidArguments -- 867
end) -- 867
local getSearchPath -- 880
getSearchPath = function(file) -- 880
	do -- 881
		local dir = getProjectDirFromFile(file) -- 881
		if dir then -- 881
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 882
		end -- 881
	end -- 881
	return "" -- 880
end -- 880
local getSearchFolders -- 884
getSearchFolders = function(file) -- 884
	do -- 885
		local dir = getProjectDirFromFile(file) -- 885
		if dir then -- 885
			return { -- 887
				Path(dir, "Script"), -- 887
				dir -- 888
			} -- 886
		end -- 885
	end -- 885
	return { } -- 884
end -- 884
local disabledCheckForLua = { -- 891
	"incompatible number of returns", -- 891
	"unknown", -- 892
	"cannot index", -- 893
	"module not found", -- 894
	"don't know how to resolve", -- 895
	"ContainerItem", -- 896
	"cannot resolve a type", -- 897
	"invalid key", -- 898
	"inconsistent index type", -- 899
	"cannot use operator", -- 900
	"attempting ipairs loop", -- 901
	"expects record or nominal", -- 902
	"variable is not being assigned", -- 903
	"<invalid type>", -- 904
	"<any type>", -- 905
	"using the '#' operator", -- 906
	"can't match a record", -- 907
	"redeclaration of variable", -- 908
	"cannot apply pairs", -- 909
	"not a function", -- 910
	"to%-be%-closed" -- 911
} -- 890
local yueCheck -- 913
yueCheck = function(file, content, lax) -- 913
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 914
	if isTIC80 then -- 915
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 916
	end -- 915
	local searchPath = getSearchPath(file) -- 917
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 918
	local info = { } -- 919
	local globals = { } -- 920
	for _index_0 = 1, #checkResult do -- 921
		local _des_0 = checkResult[_index_0] -- 921
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 921
		if "error" == t then -- 922
			info[#info + 1] = { -- 923
				"syntax", -- 923
				file, -- 923
				line, -- 923
				col, -- 923
				msg -- 923
			} -- 923
		elseif "global" == t then -- 924
			globals[#globals + 1] = { -- 925
				msg, -- 925
				line, -- 925
				col -- 925
			} -- 925
		end -- 922
	end -- 921
	if luaCodes then -- 926
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 927
		if success then -- 928
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 929
			if not (lintResult == "") then -- 930
				lintResult = lintResult .. "\n" -- 930
			end -- 930
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 931
		else -- 932
			for _index_0 = 1, #lintResult do -- 932
				local _des_0 = lintResult[_index_0] -- 932
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 932
				if isTIC80 and tic80APIs[name] then -- 933
					goto _continue_0 -- 933
				end -- 933
				info[#info + 1] = { -- 934
					"syntax", -- 934
					file, -- 934
					line, -- 934
					col, -- 934
					"invalid global variable" -- 934
				} -- 934
				::_continue_0:: -- 933
			end -- 932
		end -- 928
	end -- 926
	return luaCodes, info -- 935
end -- 913
local luaCheck -- 937
luaCheck = function(file, content) -- 937
	local res, err = load(content, "check") -- 938
	if not res then -- 939
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 940
		return { -- 941
			success = false, -- 941
			info = { -- 941
				{ -- 941
					"syntax", -- 941
					file, -- 941
					tonumber(line), -- 941
					0, -- 941
					msg -- 941
				} -- 941
			} -- 941
		} -- 941
	end -- 939
	local success, info = teal.checkAsync(content, file, true, "") -- 942
	if info then -- 943
		do -- 944
			local _accum_0 = { } -- 944
			local _len_0 = 1 -- 944
			for _index_0 = 1, #info do -- 944
				local item = info[_index_0] -- 944
				local useCheck = true -- 945
				if not item[5]:match("unused") then -- 946
					for _index_1 = 1, #disabledCheckForLua do -- 947
						local check = disabledCheckForLua[_index_1] -- 947
						if item[5]:match(check) then -- 948
							useCheck = false -- 949
						end -- 948
					end -- 947
				end -- 946
				if not useCheck then -- 950
					goto _continue_0 -- 950
				end -- 950
				do -- 951
					local _exp_0 = item[1] -- 951
					if "type" == _exp_0 then -- 952
						item[1] = "warning" -- 953
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 954
						goto _continue_0 -- 955
					end -- 951
				end -- 951
				_accum_0[_len_0] = item -- 956
				_len_0 = _len_0 + 1 -- 945
				::_continue_0:: -- 945
			end -- 944
			info = _accum_0 -- 944
		end -- 944
		if #info == 0 then -- 957
			info = nil -- 958
			success = true -- 959
		end -- 957
	end -- 943
	return { -- 960
		success = success, -- 960
		info = info -- 960
	} -- 960
end -- 937
local luaCheckWithLineInfo -- 962
luaCheckWithLineInfo = function(file, luaCodes) -- 962
	local res = luaCheck(file, luaCodes) -- 963
	local info = { } -- 964
	if not res.success then -- 965
		local current = 1 -- 966
		local lastLine = 1 -- 967
		local lineMap = { } -- 968
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 969
			local num = lineCode:match("--%s*(%d+)%s*$") -- 970
			if num then -- 971
				lastLine = tonumber(num) -- 972
			end -- 971
			lineMap[current] = lastLine -- 973
			current = current + 1 -- 974
		end -- 969
		local _list_0 = res.info -- 975
		for _index_0 = 1, #_list_0 do -- 975
			local item = _list_0[_index_0] -- 975
			item[3] = lineMap[item[3]] or 0 -- 976
			item[4] = 0 -- 977
			info[#info + 1] = item -- 978
		end -- 975
		return false, info -- 979
	end -- 965
	return true, info -- 980
end -- 962
local getCompiledYueLine -- 982
getCompiledYueLine = function(content, line, row, file, lax) -- 982
	local luaCodes = yueCheck(file, content, lax) -- 983
	if not luaCodes then -- 984
		return nil -- 984
	end -- 984
	local current = 1 -- 985
	local lastLine = 1 -- 986
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 987
	local targetRow = nil -- 988
	local lineMap = { } -- 989
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 990
		local num = lineCode:match("--%s*(%d+)%s*$") -- 991
		if num then -- 992
			lastLine = tonumber(num) -- 992
		end -- 992
		lineMap[current] = lastLine -- 993
		if row <= lastLine and not targetRow then -- 994
			targetRow = current -- 995
			break -- 996
		end -- 994
		current = current + 1 -- 997
	end -- 990
	targetRow = current -- 998
	if targetLine and targetRow then -- 999
		return luaCodes, targetLine, targetRow, lineMap -- 1000
	else -- 1002
		return nil -- 1002
	end -- 999
end -- 982
HttpServer:postSchedule("/check", function(req) -- 1004
	do -- 1005
		local _type_0 = type(req) -- 1005
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1005
		if _tab_0 then -- 1005
			local file -- 1005
			do -- 1005
				local _obj_0 = req.body -- 1005
				local _type_1 = type(_obj_0) -- 1005
				if "table" == _type_1 or "userdata" == _type_1 then -- 1005
					file = _obj_0.file -- 1005
				end -- 1005
			end -- 1005
			local content -- 1005
			do -- 1005
				local _obj_0 = req.body -- 1005
				local _type_1 = type(_obj_0) -- 1005
				if "table" == _type_1 or "userdata" == _type_1 then -- 1005
					content = _obj_0.content -- 1005
				end -- 1005
			end -- 1005
			if file ~= nil and content ~= nil then -- 1005
				local ext = Path:getExt(file) -- 1006
				if "tl" == ext then -- 1007
					local searchPath = getSearchPath(file) -- 1008
					do -- 1009
						local isTIC80 = CheckTIC80Code(content) -- 1009
						if isTIC80 then -- 1009
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1010
						end -- 1009
					end -- 1009
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 1011
					return { -- 1012
						success = success, -- 1012
						info = info -- 1012
					} -- 1012
				elseif "lua" == ext then -- 1013
					do -- 1014
						local isTIC80 = CheckTIC80Code(content) -- 1014
						if isTIC80 then -- 1014
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1015
						end -- 1014
					end -- 1014
					return luaCheck(file, content) -- 1016
				elseif "yue" == ext then -- 1017
					local luaCodes, info = yueCheck(file, content, false) -- 1018
					local success = luaCodes ~= nil -- 1019
					if luaCodes then -- 1020
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 1021
						do -- 1022
							local _tab_1 = { } -- 1022
							local _idx_0 = #_tab_1 + 1 -- 1022
							for _index_0 = 1, #info do -- 1022
								local _value_0 = info[_index_0] -- 1022
								_tab_1[_idx_0] = _value_0 -- 1022
								_idx_0 = _idx_0 + 1 -- 1022
							end -- 1022
							local _idx_1 = #_tab_1 + 1 -- 1022
							for _index_0 = 1, #luaInfo do -- 1022
								local _value_0 = luaInfo[_index_0] -- 1022
								_tab_1[_idx_1] = _value_0 -- 1022
								_idx_1 = _idx_1 + 1 -- 1022
							end -- 1022
							info = _tab_1 -- 1022
						end -- 1022
						success = success and luaSuccess -- 1023
					end -- 1020
					if #info > 0 then -- 1024
						return { -- 1025
							success = success, -- 1025
							info = info -- 1025
						} -- 1025
					else -- 1027
						return { -- 1027
							success = success -- 1027
						} -- 1027
					end -- 1024
				elseif "xml" == ext then -- 1028
					local success, result = xml.check(content) -- 1029
					if success then -- 1030
						local info -- 1031
						success, info = luaCheckWithLineInfo(file, result) -- 1031
						if #info > 0 then -- 1032
							return { -- 1033
								success = success, -- 1033
								info = info -- 1033
							} -- 1033
						else -- 1035
							return { -- 1035
								success = success -- 1035
							} -- 1035
						end -- 1032
					else -- 1037
						local info -- 1037
						do -- 1037
							local _accum_0 = { } -- 1037
							local _len_0 = 1 -- 1037
							for _index_0 = 1, #result do -- 1037
								local _des_0 = result[_index_0] -- 1037
								local row, err = _des_0[1], _des_0[2] -- 1037
								_accum_0[_len_0] = { -- 1038
									"syntax", -- 1038
									file, -- 1038
									row, -- 1038
									0, -- 1038
									err -- 1038
								} -- 1038
								_len_0 = _len_0 + 1 -- 1038
							end -- 1037
							info = _accum_0 -- 1037
						end -- 1037
						return { -- 1039
							success = false, -- 1039
							info = info -- 1039
						} -- 1039
					end -- 1030
				end -- 1007
			end -- 1005
		end -- 1005
	end -- 1005
	return { -- 1004
		success = true -- 1004
	} -- 1004
end) -- 1004
HttpServer:post("/body/parse", function(req) -- 1041
	do -- 1042
		local _type_0 = type(req) -- 1042
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1042
		if _tab_0 then -- 1042
			local file -- 1042
			do -- 1042
				local _obj_0 = req.body -- 1042
				local _type_1 = type(_obj_0) -- 1042
				if "table" == _type_1 or "userdata" == _type_1 then -- 1042
					file = _obj_0.file -- 1042
				end -- 1042
			end -- 1042
			local content -- 1042
			do -- 1042
				local _obj_0 = req.body -- 1042
				local _type_1 = type(_obj_0) -- 1042
				if "table" == _type_1 or "userdata" == _type_1 then -- 1042
					content = _obj_0.content -- 1042
				end -- 1042
			end -- 1042
			if file ~= nil and content ~= nil then -- 1042
				if not (file:sub(-6) == ".b.lua") then -- 1043
					return { -- 1044
						success = false, -- 1044
						phase = "request", -- 1044
						message = "only .b.lua files can be converted" -- 1044
					} -- 1044
				end -- 1043
				local loader, err = load("_ENV = {}\n" .. content) -- 1045
				if not loader then -- 1046
					return { -- 1047
						success = false, -- 1047
						phase = "parse", -- 1047
						message = tostring(err) -- 1047
					} -- 1047
				end -- 1046
				local ok, data = pcall(loader) -- 1048
				if not ok then -- 1049
					return { -- 1050
						success = false, -- 1050
						phase = "execute", -- 1050
						message = tostring(data) -- 1050
					} -- 1050
				end -- 1049
				if not ("table" == type(data) and data[1] == "Array") then -- 1051
					return { -- 1052
						success = false, -- 1052
						phase = "validate", -- 1052
						message = "body lua root must be {\"Array\", ...}" -- 1052
					} -- 1052
				end -- 1051
				local text, jsonErr = json.encode(data, false, true) -- 1053
				if not text then -- 1054
					return { -- 1055
						success = false, -- 1055
						phase = "encode", -- 1055
						message = tostring(jsonErr) -- 1055
					} -- 1055
				end -- 1054
				return { -- 1056
					success = true, -- 1056
					json = text -- 1056
				} -- 1056
			end -- 1042
		end -- 1042
	end -- 1042
	return { -- 1041
		success = false, -- 1041
		phase = "request", -- 1041
		message = "invalid request" -- 1041
	} -- 1041
end) -- 1041
local updateInferedDesc -- 1058
updateInferedDesc = function(infered) -- 1058
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1059
		return -- 1059
	end -- 1059
	local key, row = infered.key, infered.row -- 1060
	local codes = Content:loadAsync(key) -- 1061
	if codes then -- 1061
		local comments = { } -- 1062
		local line = 0 -- 1063
		local skipping = false -- 1064
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1065
			line = line + 1 -- 1066
			if line >= row then -- 1067
				break -- 1067
			end -- 1067
			if lineCode:match("^%s*%-%- @") then -- 1068
				skipping = true -- 1069
				goto _continue_0 -- 1070
			end -- 1068
			local result = lineCode:match("^%s*%-%- (.+)") -- 1071
			if result then -- 1071
				if not skipping then -- 1072
					comments[#comments + 1] = result -- 1072
				end -- 1072
			elseif #comments > 0 then -- 1073
				comments = { } -- 1074
				skipping = false -- 1075
			end -- 1071
			::_continue_0:: -- 1066
		end -- 1065
		infered.doc = table.concat(comments, "\n") -- 1076
	end -- 1061
end -- 1058
HttpServer:postSchedule("/infer", function(req) -- 1078
	do -- 1079
		local _type_0 = type(req) -- 1079
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1079
		if _tab_0 then -- 1079
			local lang -- 1079
			do -- 1079
				local _obj_0 = req.body -- 1079
				local _type_1 = type(_obj_0) -- 1079
				if "table" == _type_1 or "userdata" == _type_1 then -- 1079
					lang = _obj_0.lang -- 1079
				end -- 1079
			end -- 1079
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
			local line -- 1079
			do -- 1079
				local _obj_0 = req.body -- 1079
				local _type_1 = type(_obj_0) -- 1079
				if "table" == _type_1 or "userdata" == _type_1 then -- 1079
					line = _obj_0.line -- 1079
				end -- 1079
			end -- 1079
			local row -- 1079
			do -- 1079
				local _obj_0 = req.body -- 1079
				local _type_1 = type(_obj_0) -- 1079
				if "table" == _type_1 or "userdata" == _type_1 then -- 1079
					row = _obj_0.row -- 1079
				end -- 1079
			end -- 1079
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1079
				local searchPath = getSearchPath(file) -- 1080
				if "tl" == lang or "lua" == lang then -- 1081
					if CheckTIC80Code(content) then -- 1082
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1083
					end -- 1082
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1084
					if (infered ~= nil) then -- 1085
						updateInferedDesc(infered) -- 1086
						return { -- 1087
							success = true, -- 1087
							infered = infered -- 1087
						} -- 1087
					end -- 1085
				elseif "yue" == lang then -- 1088
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1089
					if not luaCodes then -- 1090
						return { -- 1090
							success = false -- 1090
						} -- 1090
					end -- 1090
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1091
					if (infered ~= nil) then -- 1092
						local col -- 1093
						file, row, col = infered.file, infered.row, infered.col -- 1093
						if file == "" and row > 0 and col > 0 then -- 1094
							infered.row = lineMap[row] or 0 -- 1095
							infered.col = 0 -- 1096
						end -- 1094
						updateInferedDesc(infered) -- 1097
						return { -- 1098
							success = true, -- 1098
							infered = infered -- 1098
						} -- 1098
					end -- 1092
				end -- 1081
			end -- 1079
		end -- 1079
	end -- 1079
	return { -- 1078
		success = false -- 1078
	} -- 1078
end) -- 1078
local _anon_func_3 = function(doc) -- 1159
	local _accum_0 = { } -- 1159
	local _len_0 = 1 -- 1159
	local _list_0 = doc.params -- 1159
	for _index_0 = 1, #_list_0 do -- 1159
		local param = _list_0[_index_0] -- 1159
		_accum_0[_len_0] = param.name -- 1159
		_len_0 = _len_0 + 1 -- 1159
	end -- 1159
	return _accum_0 -- 1159
end -- 1159
local getParamDocs -- 1100
getParamDocs = function(signatures) -- 1100
	if not (signatures and #signatures > 0) then -- 1101
		return nil -- 1101
	end -- 1101
	local docs = { } -- 1102
	do -- 1103
		local codes = Content:loadAsync(signatures[1].file) -- 1103
		if codes then -- 1103
			local comments = { } -- 1104
			local params = { } -- 1105
			local line = 0 -- 1106
			local returnType = nil -- 1107
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1108
				line = line + 1 -- 1109
				local needBreak = true -- 1110
				for i, _des_0 in ipairs(signatures) do -- 1111
					local row = _des_0.row -- 1111
					if line >= row and not (docs[i] ~= nil) then -- 1112
						if #comments > 0 or #params > 0 or returnType then -- 1113
							docs[i] = { -- 1115
								doc = table.concat(comments, "  \n"), -- 1115
								returnType = returnType -- 1116
							} -- 1114
							if #params > 0 then -- 1118
								docs[i].params = params -- 1118
							end -- 1118
						else -- 1120
							docs[i] = false -- 1120
						end -- 1113
					end -- 1112
					if not docs[i] then -- 1121
						needBreak = false -- 1121
					end -- 1121
				end -- 1111
				if needBreak then -- 1122
					break -- 1122
				end -- 1122
				local result = lineCode:match("%s*%-%- (.+)") -- 1123
				if result then -- 1123
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1124
					if not name then -- 1125
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1126
					end -- 1125
					if name then -- 1127
						local pname = name -- 1128
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1129
							pname = pname .. "?" -- 1129
						end -- 1129
						params[#params + 1] = { -- 1131
							name = tostring(pname) .. ": " .. tostring(typ), -- 1131
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1132
						} -- 1130
					else -- 1135
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1135
						if typ then -- 1135
							if returnType then -- 1136
								returnType = returnType .. ", " .. typ -- 1137
							else -- 1139
								returnType = typ -- 1139
							end -- 1136
							result = result:gsub("@return", "**return:**") -- 1140
						end -- 1135
						comments[#comments + 1] = result -- 1141
					end -- 1127
				elseif #comments > 0 then -- 1142
					comments = { } -- 1143
					params = { } -- 1144
					returnType = nil -- 1145
				end -- 1123
			end -- 1108
		end -- 1103
	end -- 1103
	local results = { } -- 1146
	for i, signature in ipairs(signatures) do -- 1147
		local item = { -- 1149
			desc = signature.desc, -- 1149
			doc = "", -- 1150
			file = signature.file, -- 1151
			row = signature.row, -- 1152
			col = signature.col -- 1153
		} -- 1148
		do -- 1155
			local doc = docs[i] -- 1155
			if doc then -- 1155
				item.doc = doc.doc -- 1156
				if doc.params then -- 1157
					item.params = doc.params -- 1158
					item.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1159
				elseif doc.returnType then -- 1160
					item.desc = "function()" -- 1161
				end -- 1157
				if doc.returnType then -- 1162
					item.desc = item.desc .. ": " .. tostring(doc.returnType) -- 1162
				end -- 1162
			end -- 1155
		end -- 1155
		results[#results + 1] = item -- 1163
	end -- 1147
	return results -- 1164
end -- 1100
HttpServer:postSchedule("/signature", function(req) -- 1166
	do -- 1167
		local _type_0 = type(req) -- 1167
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1167
		if _tab_0 then -- 1167
			local lang -- 1167
			do -- 1167
				local _obj_0 = req.body -- 1167
				local _type_1 = type(_obj_0) -- 1167
				if "table" == _type_1 or "userdata" == _type_1 then -- 1167
					lang = _obj_0.lang -- 1167
				end -- 1167
			end -- 1167
			local file -- 1167
			do -- 1167
				local _obj_0 = req.body -- 1167
				local _type_1 = type(_obj_0) -- 1167
				if "table" == _type_1 or "userdata" == _type_1 then -- 1167
					file = _obj_0.file -- 1167
				end -- 1167
			end -- 1167
			local content -- 1167
			do -- 1167
				local _obj_0 = req.body -- 1167
				local _type_1 = type(_obj_0) -- 1167
				if "table" == _type_1 or "userdata" == _type_1 then -- 1167
					content = _obj_0.content -- 1167
				end -- 1167
			end -- 1167
			local line -- 1167
			do -- 1167
				local _obj_0 = req.body -- 1167
				local _type_1 = type(_obj_0) -- 1167
				if "table" == _type_1 or "userdata" == _type_1 then -- 1167
					line = _obj_0.line -- 1167
				end -- 1167
			end -- 1167
			local row -- 1167
			do -- 1167
				local _obj_0 = req.body -- 1167
				local _type_1 = type(_obj_0) -- 1167
				if "table" == _type_1 or "userdata" == _type_1 then -- 1167
					row = _obj_0.row -- 1167
				end -- 1167
			end -- 1167
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1167
				local searchPath = getSearchPath(file) -- 1168
				if "tl" == lang or "lua" == lang then -- 1169
					if CheckTIC80Code(content) then -- 1170
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1171
					end -- 1170
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1172
					if signatures then -- 1172
						signatures = getParamDocs(signatures) -- 1173
						if signatures then -- 1173
							return { -- 1174
								success = true, -- 1174
								signatures = signatures -- 1174
							} -- 1174
						end -- 1173
					end -- 1172
				elseif "yue" == lang then -- 1175
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1176
					if not luaCodes then -- 1177
						return { -- 1177
							success = false -- 1177
						} -- 1177
					end -- 1177
					do -- 1178
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1178
						if chainOp then -- 1178
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1179
							if withVar then -- 1179
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1180
							end -- 1179
						end -- 1178
					end -- 1178
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1181
					if signatures then -- 1181
						signatures = getParamDocs(signatures) -- 1182
						if signatures then -- 1182
							return { -- 1183
								success = true, -- 1183
								signatures = signatures -- 1183
							} -- 1183
						end -- 1182
					else -- 1184
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1184
						if signatures then -- 1184
							signatures = getParamDocs(signatures) -- 1185
							if signatures then -- 1185
								return { -- 1186
									success = true, -- 1186
									signatures = signatures -- 1186
								} -- 1186
							end -- 1185
						end -- 1184
					end -- 1181
				end -- 1169
			end -- 1167
		end -- 1167
	end -- 1167
	return { -- 1166
		success = false -- 1166
	} -- 1166
end) -- 1166
local luaKeywords = { -- 1189
	'and', -- 1189
	'break', -- 1190
	'do', -- 1191
	'else', -- 1192
	'elseif', -- 1193
	'end', -- 1194
	'false', -- 1195
	'for', -- 1196
	'function', -- 1197
	'goto', -- 1198
	'if', -- 1199
	'in', -- 1200
	'local', -- 1201
	'nil', -- 1202
	'not', -- 1203
	'or', -- 1204
	'repeat', -- 1205
	'return', -- 1206
	'then', -- 1207
	'true', -- 1208
	'until', -- 1209
	'while' -- 1210
} -- 1188
local tealKeywords = { -- 1214
	'record', -- 1214
	'as', -- 1215
	'is', -- 1216
	'type', -- 1217
	'embed', -- 1218
	'enum', -- 1219
	'global', -- 1220
	'any', -- 1221
	'boolean', -- 1222
	'integer', -- 1223
	'number', -- 1224
	'string', -- 1225
	'thread' -- 1226
} -- 1213
local yueKeywords = { -- 1230
	"and", -- 1230
	"break", -- 1231
	"do", -- 1232
	"else", -- 1233
	"elseif", -- 1234
	"false", -- 1235
	"for", -- 1236
	"goto", -- 1237
	"if", -- 1238
	"in", -- 1239
	"local", -- 1240
	"nil", -- 1241
	"not", -- 1242
	"or", -- 1243
	"repeat", -- 1244
	"return", -- 1245
	"then", -- 1246
	"true", -- 1247
	"until", -- 1248
	"while", -- 1249
	"as", -- 1250
	"class", -- 1251
	"continue", -- 1252
	"export", -- 1253
	"extends", -- 1254
	"from", -- 1255
	"global", -- 1256
	"import", -- 1257
	"macro", -- 1258
	"switch", -- 1259
	"try", -- 1260
	"unless", -- 1261
	"using", -- 1262
	"when", -- 1263
	"with" -- 1264
} -- 1229
local _anon_func_4 = function(f) -- 1300
	local _val_0 = Path:getExt(f) -- 1300
	return "ttf" == _val_0 or "otf" == _val_0 -- 1300
end -- 1300
local _anon_func_5 = function(suggestions) -- 1326
	local _tbl_0 = { } -- 1326
	for _index_0 = 1, #suggestions do -- 1326
		local item = suggestions[_index_0] -- 1326
		_tbl_0[item[1] .. item[2]] = item -- 1326
	end -- 1326
	return _tbl_0 -- 1326
end -- 1326
HttpServer:postSchedule("/complete", function(req) -- 1267
	do -- 1268
		local _type_0 = type(req) -- 1268
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1268
		if _tab_0 then -- 1268
			local lang -- 1268
			do -- 1268
				local _obj_0 = req.body -- 1268
				local _type_1 = type(_obj_0) -- 1268
				if "table" == _type_1 or "userdata" == _type_1 then -- 1268
					lang = _obj_0.lang -- 1268
				end -- 1268
			end -- 1268
			local file -- 1268
			do -- 1268
				local _obj_0 = req.body -- 1268
				local _type_1 = type(_obj_0) -- 1268
				if "table" == _type_1 or "userdata" == _type_1 then -- 1268
					file = _obj_0.file -- 1268
				end -- 1268
			end -- 1268
			local content -- 1268
			do -- 1268
				local _obj_0 = req.body -- 1268
				local _type_1 = type(_obj_0) -- 1268
				if "table" == _type_1 or "userdata" == _type_1 then -- 1268
					content = _obj_0.content -- 1268
				end -- 1268
			end -- 1268
			local line -- 1268
			do -- 1268
				local _obj_0 = req.body -- 1268
				local _type_1 = type(_obj_0) -- 1268
				if "table" == _type_1 or "userdata" == _type_1 then -- 1268
					line = _obj_0.line -- 1268
				end -- 1268
			end -- 1268
			local row -- 1268
			do -- 1268
				local _obj_0 = req.body -- 1268
				local _type_1 = type(_obj_0) -- 1268
				if "table" == _type_1 or "userdata" == _type_1 then -- 1268
					row = _obj_0.row -- 1268
				end -- 1268
			end -- 1268
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1268
				local searchPath = getSearchPath(file) -- 1269
				repeat -- 1270
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1271
					if lang == "yue" then -- 1272
						if not item then -- 1273
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1273
						end -- 1273
						if not item then -- 1274
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1274
						end -- 1274
					end -- 1272
					local searchType = nil -- 1275
					if not item then -- 1276
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1277
						if lang == "yue" then -- 1278
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1279
						end -- 1278
						if (item ~= nil) then -- 1280
							searchType = "Image" -- 1280
						end -- 1280
					end -- 1276
					if not item then -- 1281
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1282
						if lang == "yue" then -- 1283
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1284
						end -- 1283
						if (item ~= nil) then -- 1285
							searchType = "Font" -- 1285
						end -- 1285
					end -- 1281
					if not item then -- 1286
						break -- 1286
					end -- 1286
					local searchPaths = Content.searchPaths -- 1287
					local _list_0 = getSearchFolders(file) -- 1288
					for _index_0 = 1, #_list_0 do -- 1288
						local folder = _list_0[_index_0] -- 1288
						searchPaths[#searchPaths + 1] = folder -- 1289
					end -- 1288
					if searchType then -- 1290
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1290
					end -- 1290
					local tokens -- 1291
					do -- 1291
						local _accum_0 = { } -- 1291
						local _len_0 = 1 -- 1291
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1291
							_accum_0[_len_0] = mod -- 1291
							_len_0 = _len_0 + 1 -- 1291
						end -- 1291
						tokens = _accum_0 -- 1291
					end -- 1291
					local suggestions = { } -- 1292
					for _index_0 = 1, #searchPaths do -- 1293
						local path = searchPaths[_index_0] -- 1293
						local sPath = Path(path, table.unpack(tokens)) -- 1294
						if not Content:exist(sPath) then -- 1295
							goto _continue_0 -- 1295
						end -- 1295
						if searchType == "Font" then -- 1296
							local fontPath = Path(sPath, "Font") -- 1297
							if Content:exist(fontPath) then -- 1298
								local _list_1 = Content:getFiles(fontPath) -- 1299
								for _index_1 = 1, #_list_1 do -- 1299
									local f = _list_1[_index_1] -- 1299
									if _anon_func_4(f) then -- 1300
										if "." == f:sub(1, 1) then -- 1301
											goto _continue_1 -- 1301
										end -- 1301
										suggestions[#suggestions + 1] = { -- 1302
											Path:getName(f), -- 1302
											"font", -- 1302
											"field" -- 1302
										} -- 1302
									end -- 1300
									::_continue_1:: -- 1300
								end -- 1299
							end -- 1298
						end -- 1296
						local _list_1 = Content:getFiles(sPath) -- 1303
						for _index_1 = 1, #_list_1 do -- 1303
							local f = _list_1[_index_1] -- 1303
							if "Image" == searchType then -- 1304
								do -- 1305
									local _exp_0 = Path:getExt(f) -- 1305
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1305
										if "." == f:sub(1, 1) then -- 1306
											goto _continue_2 -- 1306
										end -- 1306
										suggestions[#suggestions + 1] = { -- 1307
											f, -- 1307
											"image", -- 1307
											"field" -- 1307
										} -- 1307
									end -- 1305
								end -- 1305
								goto _continue_2 -- 1308
							elseif "Font" == searchType then -- 1309
								do -- 1310
									local _exp_0 = Path:getExt(f) -- 1310
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1310
										if "." == f:sub(1, 1) then -- 1311
											goto _continue_2 -- 1311
										end -- 1311
										suggestions[#suggestions + 1] = { -- 1312
											f, -- 1312
											"font", -- 1312
											"field" -- 1312
										} -- 1312
									end -- 1310
								end -- 1310
								goto _continue_2 -- 1313
							end -- 1304
							local _exp_0 = Path:getExt(f) -- 1314
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1314
								local name = Path:getName(f) -- 1315
								if "d" == Path:getExt(name) then -- 1316
									goto _continue_2 -- 1316
								end -- 1316
								if "." == name:sub(1, 1) then -- 1317
									goto _continue_2 -- 1317
								end -- 1317
								suggestions[#suggestions + 1] = { -- 1318
									name, -- 1318
									"module", -- 1318
									"field" -- 1318
								} -- 1318
							end -- 1314
							::_continue_2:: -- 1304
						end -- 1303
						local _list_2 = Content:getDirs(sPath) -- 1319
						for _index_1 = 1, #_list_2 do -- 1319
							local dir = _list_2[_index_1] -- 1319
							if "." == dir:sub(1, 1) then -- 1320
								goto _continue_3 -- 1320
							end -- 1320
							suggestions[#suggestions + 1] = { -- 1321
								dir, -- 1321
								"folder", -- 1321
								"variable" -- 1321
							} -- 1321
							::_continue_3:: -- 1320
						end -- 1319
						::_continue_0:: -- 1294
					end -- 1293
					if item == "" and not searchType then -- 1322
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1323
						for _index_0 = 1, #_list_1 do -- 1323
							local _des_0 = _list_1[_index_0] -- 1323
							local name = _des_0[1] -- 1323
							suggestions[#suggestions + 1] = { -- 1324
								name, -- 1324
								"dora module", -- 1324
								"function" -- 1324
							} -- 1324
						end -- 1323
					end -- 1322
					if #suggestions > 0 then -- 1325
						do -- 1326
							local _accum_0 = { } -- 1326
							local _len_0 = 1 -- 1326
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1326
								_accum_0[_len_0] = v -- 1326
								_len_0 = _len_0 + 1 -- 1326
							end -- 1326
							suggestions = _accum_0 -- 1326
						end -- 1326
						return { -- 1327
							success = true, -- 1327
							suggestions = suggestions -- 1327
						} -- 1327
					else -- 1329
						return { -- 1329
							success = false -- 1329
						} -- 1329
					end -- 1325
				until true -- 1270
				if "tl" == lang or "lua" == lang then -- 1331
					do -- 1332
						local isTIC80 = CheckTIC80Code(content) -- 1332
						if isTIC80 then -- 1332
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1333
						end -- 1332
					end -- 1332
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1334
					if not line:match("[%.:]$") then -- 1335
						local checkSet -- 1336
						do -- 1336
							local _tbl_0 = { } -- 1336
							for _index_0 = 1, #suggestions do -- 1336
								local _des_0 = suggestions[_index_0] -- 1336
								local name = _des_0[1] -- 1336
								_tbl_0[name] = true -- 1336
							end -- 1336
							checkSet = _tbl_0 -- 1336
						end -- 1336
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1337
						for _index_0 = 1, #_list_0 do -- 1337
							local item = _list_0[_index_0] -- 1337
							if not checkSet[item[1]] then -- 1338
								suggestions[#suggestions + 1] = item -- 1338
							end -- 1338
						end -- 1337
						for _index_0 = 1, #luaKeywords do -- 1339
							local word = luaKeywords[_index_0] -- 1339
							suggestions[#suggestions + 1] = { -- 1340
								word, -- 1340
								"keyword", -- 1340
								"keyword" -- 1340
							} -- 1340
						end -- 1339
						if lang == "tl" then -- 1341
							for _index_0 = 1, #tealKeywords do -- 1342
								local word = tealKeywords[_index_0] -- 1342
								suggestions[#suggestions + 1] = { -- 1343
									word, -- 1343
									"keyword", -- 1343
									"keyword" -- 1343
								} -- 1343
							end -- 1342
						end -- 1341
					end -- 1335
					if #suggestions > 0 then -- 1344
						return { -- 1345
							success = true, -- 1345
							suggestions = suggestions -- 1345
						} -- 1345
					end -- 1344
				elseif "yue" == lang then -- 1346
					local suggestions = { } -- 1347
					local gotGlobals = false -- 1348
					do -- 1349
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1349
						if luaCodes then -- 1349
							gotGlobals = true -- 1350
							do -- 1351
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1351
								if chainOp then -- 1351
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1352
									if not withVar then -- 1353
										return { -- 1353
											success = false -- 1353
										} -- 1353
									end -- 1353
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1354
								elseif line:match("^([%.\\])$") then -- 1355
									return { -- 1356
										success = false -- 1356
									} -- 1356
								end -- 1351
							end -- 1351
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1357
							for _index_0 = 1, #_list_0 do -- 1357
								local item = _list_0[_index_0] -- 1357
								suggestions[#suggestions + 1] = item -- 1357
							end -- 1357
							if #suggestions == 0 then -- 1358
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1359
								for _index_0 = 1, #_list_1 do -- 1359
									local item = _list_1[_index_0] -- 1359
									suggestions[#suggestions + 1] = item -- 1359
								end -- 1359
							end -- 1358
						end -- 1349
					end -- 1349
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1360
						local checkSet -- 1361
						do -- 1361
							local _tbl_0 = { } -- 1361
							for _index_0 = 1, #suggestions do -- 1361
								local _des_0 = suggestions[_index_0] -- 1361
								local name = _des_0[1] -- 1361
								_tbl_0[name] = true -- 1361
							end -- 1361
							checkSet = _tbl_0 -- 1361
						end -- 1361
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1362
						for _index_0 = 1, #_list_0 do -- 1362
							local item = _list_0[_index_0] -- 1362
							if not checkSet[item[1]] then -- 1363
								suggestions[#suggestions + 1] = item -- 1363
							end -- 1363
						end -- 1362
						if not gotGlobals then -- 1364
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1365
							for _index_0 = 1, #_list_1 do -- 1365
								local item = _list_1[_index_0] -- 1365
								if not checkSet[item[1]] then -- 1366
									suggestions[#suggestions + 1] = item -- 1366
								end -- 1366
							end -- 1365
						end -- 1364
						for _index_0 = 1, #yueKeywords do -- 1367
							local word = yueKeywords[_index_0] -- 1367
							if not checkSet[word] then -- 1368
								suggestions[#suggestions + 1] = { -- 1369
									word, -- 1369
									"keyword", -- 1369
									"keyword" -- 1369
								} -- 1369
							end -- 1368
						end -- 1367
					end -- 1360
					if #suggestions > 0 then -- 1370
						return { -- 1371
							success = true, -- 1371
							suggestions = suggestions -- 1371
						} -- 1371
					end -- 1370
				elseif "xml" == lang then -- 1372
					local items = xml.complete(content) -- 1373
					if #items > 0 then -- 1374
						local suggestions -- 1375
						do -- 1375
							local _accum_0 = { } -- 1375
							local _len_0 = 1 -- 1375
							for _index_0 = 1, #items do -- 1375
								local _des_0 = items[_index_0] -- 1375
								local label, insertText = _des_0[1], _des_0[2] -- 1375
								_accum_0[_len_0] = { -- 1376
									label, -- 1376
									insertText, -- 1376
									"field" -- 1376
								} -- 1376
								_len_0 = _len_0 + 1 -- 1376
							end -- 1375
							suggestions = _accum_0 -- 1375
						end -- 1375
						return { -- 1377
							success = true, -- 1377
							suggestions = suggestions -- 1377
						} -- 1377
					end -- 1374
				end -- 1331
			end -- 1268
		end -- 1268
	end -- 1268
	return { -- 1267
		success = false -- 1267
	} -- 1267
end) -- 1267
local getUploadFilename -- 1379
getUploadFilename = function(req, multipartFilename) -- 1379
	local filename = req.params.name -- 1380
	if not (type(filename) == "string" and filename ~= "") then -- 1381
		filename = multipartFilename -- 1381
	end -- 1381
	if not (type(filename) == "string" and filename ~= "") then -- 1382
		return -- 1382
	end -- 1382
	if filename:sub(1, 1) == "/" or filename:sub(-1) == "/" or filename:find("//", 1, true) or filename:find("\\", 1, true) or filename:find(":", 1, true) or filename:find("\0", 1, true) then -- 1385
		return -- 1385
	end -- 1385
	local parts -- 1386
	do -- 1386
		local _accum_0 = { } -- 1386
		local _len_0 = 1 -- 1386
		for part in filename:gmatch("[^/]+") do -- 1386
			_accum_0[_len_0] = part -- 1386
			_len_0 = _len_0 + 1 -- 1386
		end -- 1386
		parts = _accum_0 -- 1386
	end -- 1386
	if #parts == 0 then -- 1387
		return -- 1387
	end -- 1387
	for _index_0 = 1, #parts do -- 1388
		local part = parts[_index_0] -- 1388
		if part == "." or part == ".." or part == "" then -- 1389
			return -- 1389
		end -- 1389
	end -- 1388
	return filename -- 1390
end -- 1379
HttpServer:upload("/upload", function(req, multipartFilename) -- 1394
	do -- 1395
		local _type_0 = type(req) -- 1395
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1395
		if _tab_0 then -- 1395
			local path -- 1395
			do -- 1395
				local _obj_0 = req.params -- 1395
				local _type_1 = type(_obj_0) -- 1395
				if "table" == _type_1 or "userdata" == _type_1 then -- 1395
					path = _obj_0.path -- 1395
				end -- 1395
			end -- 1395
			if path ~= nil then -- 1395
				local filename = getUploadFilename(req, multipartFilename) -- 1396
				if filename then -- 1396
					local uploadPath = Path(Content.writablePath, ".upload") -- 1397
					if not Content:exist(uploadPath) then -- 1398
						Content:mkdir(uploadPath) -- 1399
					end -- 1398
					local targetPath = Path(uploadPath, filename) -- 1400
					Content:mkdir(Path:getPath(targetPath)) -- 1401
					return targetPath -- 1402
				end -- 1396
			end -- 1395
		end -- 1395
	end -- 1395
	return nil -- 1394
end, function(req, file) -- 1403
	do -- 1404
		local _type_0 = type(req) -- 1404
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1404
		if _tab_0 then -- 1404
			local path -- 1404
			do -- 1404
				local _obj_0 = req.params -- 1404
				local _type_1 = type(_obj_0) -- 1404
				if "table" == _type_1 or "userdata" == _type_1 then -- 1404
					path = _obj_0.path -- 1404
				end -- 1404
			end -- 1404
			if path ~= nil then -- 1404
				path = Path(Content.writablePath, path) -- 1405
				if Content:exist(path) then -- 1406
					local uploadPath = Path(Content.writablePath, ".upload") -- 1407
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1408
					Content:mkdir(Path:getPath(targetPath)) -- 1409
					if Content:move(file, targetPath) then -- 1410
						return true -- 1411
					end -- 1410
				end -- 1406
			end -- 1404
		end -- 1404
	end -- 1404
	return false -- 1403
end) -- 1392
HttpServer:post("/list", function(req) -- 1414
	do -- 1415
		local _type_0 = type(req) -- 1415
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1415
		if _tab_0 then -- 1415
			local path -- 1415
			do -- 1415
				local _obj_0 = req.body -- 1415
				local _type_1 = type(_obj_0) -- 1415
				if "table" == _type_1 or "userdata" == _type_1 then -- 1415
					path = _obj_0.path -- 1415
				end -- 1415
			end -- 1415
			if path ~= nil then -- 1415
				if Content:exist(path) then -- 1416
					local files = { } -- 1417
					local visitAssets -- 1418
					visitAssets = function(path, folder) -- 1418
						local dirs = Content:getDirs(path) -- 1419
						for _index_0 = 1, #dirs do -- 1420
							local dir = dirs[_index_0] -- 1420
							if dir:match("^%.") or dir == "node_modules" then -- 1421
								goto _continue_0 -- 1421
							end -- 1421
							local current -- 1422
							if folder == "" then -- 1422
								current = dir -- 1423
							else -- 1425
								current = Path(folder, dir) -- 1425
							end -- 1422
							files[#files + 1] = current -- 1426
							visitAssets(Path(path, dir), current) -- 1427
							::_continue_0:: -- 1421
						end -- 1420
						local fs = Content:getFiles(path) -- 1428
						for _index_0 = 1, #fs do -- 1429
							local f = fs[_index_0] -- 1429
							if (".DS_Store" == f) then -- 1430
								goto _continue_1 -- 1431
							end -- 1430
							if folder == "" then -- 1432
								files[#files + 1] = f -- 1433
							else -- 1435
								files[#files + 1] = Path(folder, f) -- 1435
							end -- 1432
							::_continue_1:: -- 1430
						end -- 1429
					end -- 1418
					visitAssets(path, "") -- 1436
					if #files == 0 then -- 1437
						files = nil -- 1437
					end -- 1437
					return { -- 1438
						success = true, -- 1438
						files = files -- 1438
					} -- 1438
				end -- 1416
			end -- 1415
		end -- 1415
	end -- 1415
	return { -- 1414
		success = false -- 1414
	} -- 1414
end) -- 1414
HttpServer:post("/info", function(req) -- 1440
	local Entry = require("Script.Dev.Entry") -- 1441
	local config = Entry.getConfig() -- 1442
	do -- 1443
		local _type_0 = type(req) -- 1443
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1443
		if _tab_0 then -- 1443
			local webIDETourCompleted -- 1443
			do -- 1443
				local _obj_0 = req.body -- 1443
				local _type_1 = type(_obj_0) -- 1443
				if "table" == _type_1 or "userdata" == _type_1 then -- 1443
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1443
				end -- 1443
			end -- 1443
			if webIDETourCompleted ~= nil then -- 1443
				config.webIDETourCompleted = webIDETourCompleted == true -- 1444
			end -- 1443
		end -- 1443
	end -- 1443
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1445
	local engineDev = Entry.getEngineDev() -- 1446
	Entry.connectWebIDE() -- 1447
	return { -- 1449
		platform = App.platform, -- 1449
		locale = App.locale, -- 1450
		version = App.version, -- 1451
		engineDev = engineDev, -- 1452
		webProfiler = webProfiler, -- 1453
		drawerWidth = drawerWidth, -- 1454
		webIDETourCompleted = webIDETourCompleted == true -- 1455
	} -- 1448
end) -- 1440
local ensureLLMConfigTable -- 1457
ensureLLMConfigTable = function() -- 1457
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1458
	if columns and #columns > 0 then -- 1459
		local expected = { -- 1461
			id = true, -- 1461
			name = true, -- 1462
			url = true, -- 1463
			model = true, -- 1464
			api_key = true, -- 1465
			context_window = true, -- 1466
			temperature = true, -- 1467
			max_tokens = true, -- 1468
			reasoning_effort = true, -- 1469
			custom_options = true, -- 1470
			supports_function_calling = true, -- 1471
			active = true, -- 1472
			created_at = true, -- 1473
			updated_at = true -- 1474
		} -- 1460
		local existing = { } -- 1476
		local valid = true -- 1477
		for _index_0 = 1, #columns do -- 1478
			local row = columns[_index_0] -- 1478
			local columnName = tostring(row[2]) -- 1479
			existing[columnName] = true -- 1480
			if not expected[columnName] then -- 1481
				valid = false -- 1482
				break -- 1483
			end -- 1481
		end -- 1478
		if valid then -- 1484
			if not existing.context_window then -- 1485
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1486
			end -- 1485
			if not existing.temperature then -- 1487
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1488
			end -- 1487
			if not existing.max_tokens then -- 1489
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 64000") -- 1490
			end -- 1489
			if not existing.reasoning_effort then -- 1491
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1492
			end -- 1491
			if not existing.custom_options then -- 1493
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1494
			end -- 1493
			if not existing.supports_function_calling then -- 1495
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1496
			end -- 1495
		else -- 1498
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1498
		end -- 1484
	end -- 1459
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
	]]) -- 1499
	return require("Agent.LLMConfigMigration").upgradeLLMConfig() -- 1518
end -- 1457
local normalizeContextWindow -- 1520
normalizeContextWindow = function(value) -- 1520
	local contextWindow = tonumber(value) -- 1521
	if contextWindow == nil or contextWindow < 64000 then -- 1522
		return 64000 -- 1523
	end -- 1522
	return math.max(64000, math.floor(contextWindow)) -- 1524
end -- 1520
local normalizeTemperature -- 1526
normalizeTemperature = function(value) -- 1526
	local temperature = tonumber(value) -- 1527
	if temperature == nil then -- 1528
		return 0.1 -- 1529
	end -- 1528
	return math.max(0, math.min(2, temperature)) -- 1530
end -- 1526
local normalizeMaxTokens -- 1532
normalizeMaxTokens = function(value) -- 1532
	local maxTokens = tonumber(value) -- 1533
	if maxTokens == nil or maxTokens < 1 then -- 1534
		return 64000 -- 1535
	end -- 1534
	return math.max(1, math.floor(maxTokens)) -- 1536
end -- 1532
local normalizeReasoningEffort -- 1538
normalizeReasoningEffort = function(value) -- 1538
	if value == nil then -- 1539
		return "" -- 1540
	end -- 1539
	local effort = tostring(value) -- 1541
	return effort:match("^%s*(.-)%s*$") or "" -- 1542
end -- 1538
local normalizeCustomOptions -- 1544
normalizeCustomOptions = function(value) -- 1544
	if value == nil then -- 1545
		return "" -- 1546
	end -- 1545
	local options = tostring(value) -- 1547
	options = options:match("^%s*(.-)%s*$") or "" -- 1548
	return options -- 1549
end -- 1544
local validateCustomOptions -- 1551
validateCustomOptions = function(value) -- 1551
	local options = normalizeCustomOptions(value) -- 1552
	if options == "" then -- 1553
		return true -- 1553
	end -- 1553
	if not options:match("^%s*{") then -- 1554
		return false -- 1554
	end -- 1554
	local decoded = json.decode(options) -- 1555
	return type(decoded) == "table" -- 1556
end -- 1551
HttpServer:post("/llm/list", function() -- 1558
	ensureLLMConfigTable() -- 1559
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1560
	local items -- 1564
	if rows and #rows > 0 then -- 1564
		local _accum_0 = { } -- 1565
		local _len_0 = 1 -- 1565
		for _index_0 = 1, #rows do -- 1565
			local _des_0 = rows[_index_0] -- 1565
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1565
			_accum_0[_len_0] = { -- 1566
				id = id, -- 1566
				name = name, -- 1566
				url = url, -- 1566
				model = model, -- 1566
				key = key, -- 1566
				contextWindow = normalizeContextWindow(contextWindow), -- 1566
				temperature = normalizeTemperature(temperature), -- 1566
				maxTokens = normalizeMaxTokens(maxTokens), -- 1566
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1566
				customOptions = normalizeCustomOptions(customOptions), -- 1566
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1566
			} -- 1566
			_len_0 = _len_0 + 1 -- 1566
		end -- 1565
		items = _accum_0 -- 1564
	end -- 1564
	return { -- 1567
		success = true, -- 1567
		items = items -- 1567
	} -- 1567
end) -- 1558
HttpServer:post("/llm/create", function(req) -- 1569
	ensureLLMConfigTable() -- 1570
	do -- 1571
		local _type_0 = type(req) -- 1571
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1571
		if _tab_0 then -- 1571
			local body = req.body -- 1571
			if body ~= nil then -- 1571
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1572
				local now = os.time() -- 1573
				if name == nil or url == nil or model == nil or key == nil then -- 1574
					return invalidArguments -- 1575
				end -- 1574
				contextWindow = normalizeContextWindow(contextWindow) -- 1576
				temperature = normalizeTemperature(temperature) -- 1577
				maxTokens = normalizeMaxTokens(maxTokens) -- 1578
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1579
				customOptions = normalizeCustomOptions(customOptions) -- 1580
				if not validateCustomOptions(customOptions) then -- 1581
					return { -- 1581
						success = false, -- 1581
						message = "customOptions must be a JSON object" -- 1581
					} -- 1581
				end -- 1581
				if supportsFunctionCalling == false then -- 1582
					supportsFunctionCalling = 0 -- 1582
				else -- 1582
					supportsFunctionCalling = 1 -- 1582
				end -- 1582
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1589
					tostring(name), -- 1589
					tostring(url), -- 1590
					tostring(model), -- 1591
					tostring(key), -- 1592
					contextWindow, -- 1593
					temperature, -- 1594
					maxTokens, -- 1595
					reasoningEffort, -- 1596
					customOptions, -- 1597
					supportsFunctionCalling, -- 1598
					1, -- 1599
					now, -- 1600
					now -- 1601
				}) -- 1583
				return { -- 1603
					success = affected >= 0 -- 1603
				} -- 1603
			end -- 1571
		end -- 1571
	end -- 1571
	return invalidArguments -- 1569
end) -- 1569
HttpServer:post("/llm/update", function(req) -- 1605
	ensureLLMConfigTable() -- 1606
	do -- 1607
		local _type_0 = type(req) -- 1607
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1607
		if _tab_0 then -- 1607
			local body = req.body -- 1607
			if body ~= nil then -- 1607
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1608
				local now = os.time() -- 1609
				id = tonumber(id) -- 1610
				if id == nil then -- 1611
					return invalidArguments -- 1611
				end -- 1611
				contextWindow = normalizeContextWindow(contextWindow) -- 1612
				temperature = normalizeTemperature(temperature) -- 1613
				maxTokens = normalizeMaxTokens(maxTokens) -- 1614
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1615
				customOptions = normalizeCustomOptions(customOptions) -- 1616
				if not validateCustomOptions(customOptions) then -- 1617
					return { -- 1617
						success = false, -- 1617
						message = "customOptions must be a JSON object" -- 1617
					} -- 1617
				end -- 1617
				if supportsFunctionCalling == false then -- 1618
					supportsFunctionCalling = 0 -- 1618
				else -- 1618
					supportsFunctionCalling = 1 -- 1618
				end -- 1618
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1623
					tostring(name), -- 1623
					tostring(url), -- 1624
					tostring(model), -- 1625
					tostring(key), -- 1626
					contextWindow, -- 1627
					temperature, -- 1628
					maxTokens, -- 1629
					reasoningEffort, -- 1630
					customOptions, -- 1631
					supportsFunctionCalling, -- 1632
					now, -- 1633
					id -- 1634
				}) -- 1619
				return { -- 1636
					success = affected >= 0 -- 1636
				} -- 1636
			end -- 1607
		end -- 1607
	end -- 1607
	return invalidArguments -- 1605
end) -- 1605
HttpServer:post("/llm/delete", function(req) -- 1638
	ensureLLMConfigTable() -- 1639
	do -- 1640
		local _type_0 = type(req) -- 1640
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1640
		if _tab_0 then -- 1640
			local id -- 1640
			do -- 1640
				local _obj_0 = req.body -- 1640
				local _type_1 = type(_obj_0) -- 1640
				if "table" == _type_1 or "userdata" == _type_1 then -- 1640
					id = _obj_0.id -- 1640
				end -- 1640
			end -- 1640
			if id ~= nil then -- 1640
				id = tonumber(id) -- 1641
				if id == nil then -- 1642
					return invalidArguments -- 1642
				end -- 1642
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1643
					id -- 1643
				}) -- 1643
				return { -- 1644
					success = affected >= 0 -- 1644
				} -- 1644
			end -- 1640
		end -- 1640
	end -- 1640
	return invalidArguments -- 1638
end) -- 1638
HttpServer:post("/local-agent/list", function() -- 1646
	return { -- 1647
		success = true, -- 1647
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1647
		items = AgentLocalAgent.listConfigs() -- 1647
	} -- 1647
end) -- 1646
HttpServer:post("/local-agent/save", function(req) -- 1649
	do -- 1650
		local _type_0 = type(req) -- 1650
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1650
		if _tab_0 then -- 1650
			local body = req.body -- 1650
			if body ~= nil then -- 1650
				return AgentLocalAgent.saveConfig(body) -- 1651
			end -- 1650
		end -- 1650
	end -- 1650
	return invalidArguments -- 1649
end) -- 1649
HttpServer:post("/local-agent/delete", function(req) -- 1653
	do -- 1654
		local _type_0 = type(req) -- 1654
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1654
		if _tab_0 then -- 1654
			local id -- 1654
			do -- 1654
				local _obj_0 = req.body -- 1654
				local _type_1 = type(_obj_0) -- 1654
				if "table" == _type_1 or "userdata" == _type_1 then -- 1654
					id = _obj_0.id -- 1654
				end -- 1654
			end -- 1654
			if id ~= nil then -- 1654
				return AgentLocalAgent.deleteConfig(id) -- 1655
			end -- 1654
		end -- 1654
	end -- 1654
	return invalidArguments -- 1653
end) -- 1653
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1657
	do -- 1658
		local _type_0 = type(req) -- 1658
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1658
		if _tab_0 then -- 1658
			local id -- 1658
			do -- 1658
				local _obj_0 = req.body -- 1658
				local _type_1 = type(_obj_0) -- 1658
				if "table" == _type_1 or "userdata" == _type_1 then -- 1658
					id = _obj_0.id -- 1658
				end -- 1658
			end -- 1658
			if id ~= nil then -- 1658
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1659
			end -- 1658
		end -- 1658
	end -- 1658
	return invalidArguments -- 1657
end) -- 1657
HttpServer:post("/stat", function(req) -- 1661
	do -- 1662
		local _type_0 = type(req) -- 1662
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1662
		if _tab_0 then -- 1662
			local path -- 1662
			do -- 1662
				local _obj_0 = req.body -- 1662
				local _type_1 = type(_obj_0) -- 1662
				if "table" == _type_1 or "userdata" == _type_1 then -- 1662
					path = _obj_0.path -- 1662
				end -- 1662
			end -- 1662
			if path ~= nil then -- 1662
				if not Content:exist(path) then -- 1663
					return { -- 1664
						success = false, -- 1664
						message = "target not existed" -- 1664
					} -- 1664
				end -- 1663
				if Content:isdir(path) then -- 1665
					return { -- 1666
						success = false, -- 1666
						message = "failed to stat a directory" -- 1666
					} -- 1666
				end -- 1665
				local size, isBinary = Content:getAttr(path) -- 1667
				if size then -- 1667
					return { -- 1668
						success = true, -- 1668
						size = size, -- 1668
						isBinary = isBinary -- 1668
					} -- 1668
				end -- 1667
			end -- 1662
		end -- 1662
	end -- 1662
	return { -- 1661
		success = false, -- 1661
		message = "failed to stat" -- 1661
	} -- 1661
end) -- 1661
HttpServer:post("/new", function(req) -- 1670
	do -- 1671
		local _type_0 = type(req) -- 1671
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1671
		if _tab_0 then -- 1671
			local path -- 1671
			do -- 1671
				local _obj_0 = req.body -- 1671
				local _type_1 = type(_obj_0) -- 1671
				if "table" == _type_1 or "userdata" == _type_1 then -- 1671
					path = _obj_0.path -- 1671
				end -- 1671
			end -- 1671
			local content -- 1671
			do -- 1671
				local _obj_0 = req.body -- 1671
				local _type_1 = type(_obj_0) -- 1671
				if "table" == _type_1 or "userdata" == _type_1 then -- 1671
					content = _obj_0.content -- 1671
				end -- 1671
			end -- 1671
			local folder -- 1671
			do -- 1671
				local _obj_0 = req.body -- 1671
				local _type_1 = type(_obj_0) -- 1671
				if "table" == _type_1 or "userdata" == _type_1 then -- 1671
					folder = _obj_0.folder -- 1671
				end -- 1671
			end -- 1671
			if path ~= nil and content ~= nil and folder ~= nil then -- 1671
				if Content:exist(path) then -- 1672
					return { -- 1673
						success = false, -- 1673
						message = "TargetExisted" -- 1673
					} -- 1673
				end -- 1672
				local parent = Path:getPath(path) -- 1674
				local files = Content:getFiles(parent) -- 1675
				if folder then -- 1676
					local name = Path:getFilename(path):lower() -- 1677
					for _index_0 = 1, #files do -- 1678
						local file = files[_index_0] -- 1678
						if name == Path:getFilename(file):lower() then -- 1679
							return { -- 1680
								success = false, -- 1680
								message = "TargetExisted" -- 1680
							} -- 1680
						end -- 1679
					end -- 1678
					if Content:mkdir(path) then -- 1681
						return { -- 1682
							success = true -- 1682
						} -- 1682
					end -- 1681
				else -- 1684
					local name = Path:getName(path):lower() -- 1684
					for _index_0 = 1, #files do -- 1685
						local file = files[_index_0] -- 1685
						if name == Path:getName(file):lower() then -- 1686
							local ext = Path:getExt(file) -- 1687
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1688
								goto _continue_0 -- 1689
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1690
								goto _continue_0 -- 1691
							end -- 1688
							return { -- 1692
								success = false, -- 1692
								message = "SourceExisted" -- 1692
							} -- 1692
						end -- 1686
						::_continue_0:: -- 1686
					end -- 1685
					if Content:save(path, content) then -- 1693
						return { -- 1694
							success = true -- 1694
						} -- 1694
					end -- 1693
				end -- 1676
			end -- 1671
		end -- 1671
	end -- 1671
	return { -- 1670
		success = false, -- 1670
		message = "Failed" -- 1670
	} -- 1670
end) -- 1670
local deleteAsset -- 1696
deleteAsset = function(path) -- 1696
	if not Content:exist(path) then -- 1697
		return false -- 1697
	end -- 1697
	local projectRoot -- 1698
	if Content:isdir(path) and isProjectRootDir(path) then -- 1698
		projectRoot = path -- 1698
	else -- 1698
		projectRoot = nil -- 1698
	end -- 1698
	local parent = Path:getPath(path) -- 1699
	local files = Content:getFiles(parent) -- 1700
	local name = Path:getName(path):lower() -- 1701
	local ext = Path:getExt(path) -- 1702
	for _index_0 = 1, #files do -- 1703
		local file = files[_index_0] -- 1703
		if name == Path:getName(file):lower() then -- 1704
			local _exp_0 = Path:getExt(file) -- 1705
			if "tl" == _exp_0 then -- 1705
				if ("vs" == ext) then -- 1705
					Content:remove(Path(parent, file)) -- 1706
				end -- 1705
			elseif "lua" == _exp_0 then -- 1707
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1707
					Content:remove(Path(parent, file)) -- 1708
				end -- 1707
			end -- 1705
		end -- 1704
	end -- 1703
	if Content:remove(path) then -- 1709
		if projectRoot then -- 1710
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1711
		end -- 1710
		return true -- 1712
	end -- 1709
	return false -- 1713
end -- 1696
local moveAsset -- 1715
moveAsset = function(old, new) -- 1715
	if not (Content:exist(old) and not Content:exist(new)) then -- 1716
		return false -- 1716
	end -- 1716
	local renamedDir = Content:isdir(old) -- 1717
	local parent = Path:getPath(new) -- 1718
	local files = Content:getFiles(parent) -- 1719
	if renamedDir then -- 1720
		local name = Path:getFilename(new):lower() -- 1721
		for _index_0 = 1, #files do -- 1722
			local file = files[_index_0] -- 1722
			if name == Path:getFilename(file):lower() then -- 1723
				return false -- 1724
			end -- 1723
		end -- 1722
	else -- 1726
		local name = Path:getName(new):lower() -- 1726
		local ext = Path:getExt(new) -- 1727
		for _index_0 = 1, #files do -- 1728
			local file = files[_index_0] -- 1728
			if name == Path:getName(file):lower() then -- 1729
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1730
					goto _continue_0 -- 1731
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1732
					goto _continue_0 -- 1733
				end -- 1730
				return false -- 1734
			end -- 1729
			::_continue_0:: -- 1729
		end -- 1728
	end -- 1720
	if not Content:move(old, new) then -- 1735
		return false -- 1735
	end -- 1735
	if renamedDir then -- 1736
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1737
	end -- 1736
	local newParent = Path:getPath(new) -- 1738
	parent = Path:getPath(old) -- 1739
	files = Content:getFiles(parent) -- 1740
	local newName = Path:getName(new) -- 1741
	local oldName = Path:getName(old) -- 1742
	local name = oldName:lower() -- 1743
	local ext = Path:getExt(old) -- 1744
	for _index_0 = 1, #files do -- 1745
		local file = files[_index_0] -- 1745
		if name == Path:getName(file):lower() then -- 1746
			local _exp_0 = Path:getExt(file) -- 1747
			if "tl" == _exp_0 then -- 1747
				if ("vs" == ext) then -- 1747
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1748
				end -- 1747
			elseif "lua" == _exp_0 then -- 1749
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1749
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1750
				end -- 1749
			end -- 1747
		end -- 1746
	end -- 1745
	return true -- 1751
end -- 1715
HttpServer:post("/delete", function(req) -- 1753
	do -- 1754
		local _type_0 = type(req) -- 1754
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1754
		if _tab_0 then -- 1754
			local path -- 1754
			do -- 1754
				local _obj_0 = req.body -- 1754
				local _type_1 = type(_obj_0) -- 1754
				if "table" == _type_1 or "userdata" == _type_1 then -- 1754
					path = _obj_0.path -- 1754
				end -- 1754
			end -- 1754
			if path ~= nil then -- 1754
				if deleteAsset(path) then -- 1755
					return { -- 1755
						success = true -- 1755
					} -- 1755
				end -- 1755
			end -- 1754
		end -- 1754
	end -- 1754
	return { -- 1753
		success = false -- 1753
	} -- 1753
end) -- 1753
HttpServer:post("/rename", function(req) -- 1757
	do -- 1758
		local _type_0 = type(req) -- 1758
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1758
		if _tab_0 then -- 1758
			local old -- 1758
			do -- 1758
				local _obj_0 = req.body -- 1758
				local _type_1 = type(_obj_0) -- 1758
				if "table" == _type_1 or "userdata" == _type_1 then -- 1758
					old = _obj_0.old -- 1758
				end -- 1758
			end -- 1758
			local new -- 1758
			do -- 1758
				local _obj_0 = req.body -- 1758
				local _type_1 = type(_obj_0) -- 1758
				if "table" == _type_1 or "userdata" == _type_1 then -- 1758
					new = _obj_0.new -- 1758
				end -- 1758
			end -- 1758
			if old ~= nil and new ~= nil then -- 1758
				if moveAsset(old, new) then -- 1759
					return { -- 1759
						success = true -- 1759
					} -- 1759
				end -- 1759
			end -- 1758
		end -- 1758
	end -- 1758
	return { -- 1757
		success = false -- 1757
	} -- 1757
end) -- 1757
local normalizeAssetPaths -- 1761
normalizeAssetPaths = function(paths) -- 1761
	if not (type(paths) == "table") then -- 1762
		return nil -- 1762
	end -- 1762
	local unique = { } -- 1763
	local candidates = { } -- 1764
	for _index_0 = 1, #paths do -- 1765
		local path = paths[_index_0] -- 1765
		if not (type(path) == "string") then -- 1766
			return nil -- 1766
		end -- 1766
		local relative = relativeToRoot(path, Content.writablePath) -- 1767
		if relative == nil or relative == "" or not Content:exist(path) then -- 1768
			return nil -- 1768
		end -- 1768
		if not unique[path] then -- 1769
			unique[path] = true -- 1770
			candidates[#candidates + 1] = path -- 1771
		end -- 1769
	end -- 1765
	table.sort(candidates, function(a, b) -- 1772
		return #a < #b -- 1772
	end) -- 1772
	local result = { } -- 1773
	for _index_0 = 1, #candidates do -- 1774
		local path = candidates[_index_0] -- 1774
		local contained = false -- 1775
		for _index_1 = 1, #result do -- 1776
			local parent = result[_index_1] -- 1776
			if relativeToRoot(path, parent) ~= nil then -- 1777
				contained = true -- 1778
				break -- 1779
			end -- 1777
		end -- 1776
		if not contained then -- 1780
			result[#result + 1] = path -- 1780
		end -- 1780
	end -- 1774
	return result -- 1781
end -- 1761
HttpServer:postSchedule("/assets/batch", function(req) -- 1783
	do -- 1784
		local _type_0 = type(req) -- 1784
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1784
		if _tab_0 then -- 1784
			local operation -- 1784
			do -- 1784
				local _obj_0 = req.body -- 1784
				local _type_1 = type(_obj_0) -- 1784
				if "table" == _type_1 or "userdata" == _type_1 then -- 1784
					operation = _obj_0.operation -- 1784
				end -- 1784
			end -- 1784
			local sources -- 1784
			do -- 1784
				local _obj_0 = req.body -- 1784
				local _type_1 = type(_obj_0) -- 1784
				if "table" == _type_1 or "userdata" == _type_1 then -- 1784
					sources = _obj_0.sources -- 1784
				end -- 1784
			end -- 1784
			if operation ~= nil and sources ~= nil then -- 1784
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1785
					return { -- 1785
						success = false, -- 1785
						message = "invalid operation" -- 1785
					} -- 1785
				end -- 1785
				sources = normalizeAssetPaths(sources) -- 1786
				if not (sources and #sources > 0) then -- 1787
					return { -- 1787
						success = false, -- 1787
						message = "invalid sources" -- 1787
					} -- 1787
				end -- 1787
				local target = req.body.target -- 1788
				local destinations = { } -- 1789
				if operation ~= "delete" then -- 1790
					if not (type(target) == "string") then -- 1791
						return { -- 1791
							success = false, -- 1791
							message = "invalid target" -- 1791
						} -- 1791
					end -- 1791
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1792
					if targetRelative == nil then -- 1793
						return { -- 1793
							success = false, -- 1793
							message = "invalid target" -- 1793
						} -- 1793
					end -- 1793
					if not (Content:exist(target) and Content:isdir(target)) then -- 1794
						return { -- 1794
							success = false, -- 1794
							message = "invalid target" -- 1794
						} -- 1794
					end -- 1794
					for _index_0 = 1, #sources do -- 1795
						local source = sources[_index_0] -- 1795
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1796
							return { -- 1797
								success = false, -- 1797
								message = "target inside source" -- 1797
							} -- 1797
						end -- 1796
						local destination = Path(target, Path:getFilename(source)) -- 1798
						if Content:exist(destination) then -- 1799
							return { -- 1799
								success = false, -- 1799
								message = "target existed" -- 1799
							} -- 1799
						end -- 1799
						if destinations[destination] then -- 1800
							return { -- 1800
								success = false, -- 1800
								message = "duplicate target" -- 1800
							} -- 1800
						end -- 1800
						destinations[destination] = true -- 1801
					end -- 1795
				end -- 1790
				local changes = { } -- 1802
				local affectedSet = { } -- 1803
				local affectedDirectories = { } -- 1804
				local addAffected -- 1805
				addAffected = function(dir) -- 1805
					if affectedSet[dir] then -- 1806
						return -- 1806
					end -- 1806
					affectedSet[dir] = true -- 1807
					affectedDirectories[#affectedDirectories + 1] = dir -- 1808
				end -- 1805
				if operation ~= "delete" then -- 1809
					addAffected(target) -- 1809
				end -- 1809
				for _index_0 = 1, #sources do -- 1810
					local source = sources[_index_0] -- 1810
					addAffected(Path:getPath(source)) -- 1811
					if operation == "delete" then -- 1812
						if not deleteAsset(source) then -- 1813
							return { -- 1813
								success = false, -- 1813
								message = "delete failed", -- 1813
								changes = changes, -- 1813
								affectedDirectories = affectedDirectories -- 1813
							} -- 1813
						end -- 1813
						changes[#changes + 1] = { -- 1814
							old = source -- 1814
						} -- 1814
					else -- 1816
						local destination = Path(target, Path:getFilename(source)) -- 1816
						local ok -- 1817
						if operation == "copy" then -- 1817
							ok = Content:copyAsync(source, destination) -- 1818
						else -- 1820
							ok = moveAsset(source, destination) -- 1820
						end -- 1817
						if not ok then -- 1821
							return { -- 1821
								success = false, -- 1821
								message = operation .. " failed", -- 1821
								changes = changes, -- 1821
								affectedDirectories = affectedDirectories -- 1821
							} -- 1821
						end -- 1821
						changes[#changes + 1] = { -- 1822
							old = source, -- 1822
							new = destination -- 1822
						} -- 1822
					end -- 1812
				end -- 1810
				return { -- 1823
					success = true, -- 1823
					changes = changes, -- 1823
					affectedDirectories = affectedDirectories -- 1823
				} -- 1823
			end -- 1784
		end -- 1784
	end -- 1784
	return { -- 1783
		success = false, -- 1783
		message = "invalid request" -- 1783
	} -- 1783
end) -- 1783
local withProjectSearchPaths -- 1825
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1825
	local fallbackPaths = { } -- 1826
	local addFallback -- 1827
	addFallback = function(dir) -- 1827
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1827
			fallbackPaths[#fallbackPaths + 1] = dir -- 1827
		end -- 1827
	end -- 1827
	if projectRoot and projectRoot ~= "" then -- 1828
		addFallback(Path(projectRoot, "Script")) -- 1829
		addFallback(projectRoot) -- 1830
	end -- 1828
	if projFile then -- 1831
		local projDir = getProjectDirFromFile(projFile) -- 1832
		if projDir then -- 1832
			addFallback(Path(projDir, "Script")) -- 1833
			addFallback(projDir) -- 1834
		else -- 1836
			addFallback(Path:getPath(projFile)) -- 1836
		end -- 1832
	end -- 1831
	if not (#fallbackPaths > 0) then -- 1837
		return fn() -- 1837
	end -- 1837
	local searchPaths = Content.searchPaths -- 1838
	for _index_0 = 1, #fallbackPaths do -- 1839
		local dir = fallbackPaths[_index_0] -- 1839
		Content:addSearchPath(dir) -- 1839
	end -- 1839
	local _ <close> = setmetatable({ }, { -- 1840
		__close = function() -- 1840
			Content.searchPaths = searchPaths -- 1840
		end -- 1840
	}) -- 1840
	return fn() -- 1841
end -- 1825
HttpServer:post("/exist", function(req) -- 1842
	do -- 1843
		local _type_0 = type(req) -- 1843
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1843
		if _tab_0 then -- 1843
			local file -- 1843
			do -- 1843
				local _obj_0 = req.body -- 1843
				local _type_1 = type(_obj_0) -- 1843
				if "table" == _type_1 or "userdata" == _type_1 then -- 1843
					file = _obj_0.file -- 1843
				end -- 1843
			end -- 1843
			if file ~= nil then -- 1843
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1844
					return { -- 1845
						success = Content:exist(file) -- 1845
					} -- 1845
				end) -- 1844
			end -- 1843
		end -- 1843
	end -- 1843
	return { -- 1842
		success = false -- 1842
	} -- 1842
end) -- 1842
HttpServer:postSchedule("/read", function(req) -- 1846
	do -- 1847
		local _type_0 = type(req) -- 1847
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1847
		if _tab_0 then -- 1847
			local path -- 1847
			do -- 1847
				local _obj_0 = req.body -- 1847
				local _type_1 = type(_obj_0) -- 1847
				if "table" == _type_1 or "userdata" == _type_1 then -- 1847
					path = _obj_0.path -- 1847
				end -- 1847
			end -- 1847
			if path ~= nil then -- 1847
				local readFile -- 1848
				readFile = function() -- 1848
					if Content:exist(path) and not Content:isdir(path) then -- 1849
						local content = Content:loadAsync(path) -- 1850
						if content then -- 1850
							return { -- 1851
								content = content, -- 1851
								success = true, -- 1851
								fullPath = Content:getFullPath(path) -- 1851
							} -- 1851
						end -- 1850
					end -- 1849
					return nil -- 1848
				end -- 1848
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1852
				if result then -- 1852
					return result -- 1852
				end -- 1852
			end -- 1847
		end -- 1847
	end -- 1847
	return { -- 1846
		success = false -- 1846
	} -- 1846
end) -- 1846
local agentDocLanguage -- 1854
agentDocLanguage = function(language) -- 1854
	if language == "zh-Hans" then -- 1855
		return "zh" -- 1855
	else -- 1855
		return "en" -- 1855
	end -- 1855
end -- 1854
HttpServer:postSchedule("/doc/search", function(req) -- 1857
	local body = req.body or { } -- 1858
	local language = body.docLanguage -- 1859
	if not (("en" == language or "zh-Hans" == language)) then -- 1860
		return { -- 1860
			success = false, -- 1860
			message = "unsupported doc language" -- 1860
		} -- 1860
	end -- 1860
	local docType = body.docType -- 1861
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1862
		return { -- 1862
			success = false, -- 1862
			message = "unsupported doc type" -- 1862
		} -- 1862
	end -- 1862
	local codeLanguage = body.programmingLanguage -- 1863
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1864
		return { -- 1864
			success = false, -- 1864
			message = "unsupported programming language" -- 1864
		} -- 1864
	end -- 1864
	if not body.pattern then -- 1865
		return { -- 1865
			success = false, -- 1865
			message = "missing pattern" -- 1865
		} -- 1865
	end -- 1865
	local result = nil -- 1866
	AgentTools.searchDoraDocHttp({ -- 1868
		pattern = body.pattern, -- 1868
		docLanguage = agentDocLanguage(language), -- 1869
		docType = docType, -- 1870
		programmingLanguage = codeLanguage, -- 1871
		limit = body.limit, -- 1872
		useRegex = body.useRegex, -- 1873
		caseSensitive = body.caseSensitive, -- 1874
		includeContent = body.includeContent, -- 1875
		contentWindow = body.contentWindow -- 1876
	}, function(res) -- 1877
		result = res -- 1878
	end) -- 1867
	wait(function() -- 1879
		return result ~= nil -- 1879
	end) -- 1879
	if result and result.success then -- 1880
		result.docLanguage = language -- 1881
	end -- 1880
	if result then -- 1882
		return result -- 1883
	else -- 1885
		return { -- 1885
			success = false, -- 1885
			message = "doc search failed" -- 1885
		} -- 1885
	end -- 1882
	return { -- 1857
		success = false, -- 1857
		message = "invalid call" -- 1857
	} -- 1857
end) -- 1857
HttpServer:postSchedule("/doc/read", function(req) -- 1887
	local body = req.body or { } -- 1888
	local language = body.docLanguage -- 1889
	if not (("en" == language or "zh-Hans" == language)) then -- 1890
		return { -- 1890
			success = false, -- 1890
			message = "unsupported doc language" -- 1890
		} -- 1890
	end -- 1890
	if not body.file then -- 1891
		return { -- 1891
			success = false, -- 1891
			message = "missing file" -- 1891
		} -- 1891
	end -- 1891
	local result = AgentTools.readDoraDoc({ -- 1893
		docLanguage = agentDocLanguage(language), -- 1893
		file = body.file, -- 1894
		startLine = body.startLine, -- 1895
		endLine = body.endLine -- 1896
	}) -- 1892
	if result and result.success then -- 1897
		result.docLanguage = language -- 1898
	end -- 1897
	return result -- 1899
end) -- 1887
HttpServer:get("/read-sync", function(req) -- 1901
	do -- 1902
		local _type_0 = type(req) -- 1902
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1902
		if _tab_0 then -- 1902
			local params = req.params -- 1902
			if params ~= nil then -- 1902
				local path = params.path -- 1903
				if not (type(path) == "string" and path ~= "") then -- 1904
					return { -- 1904
						success = false, -- 1904
						message = "invalid path" -- 1904
					} -- 1904
				end -- 1904
				local exts -- 1905
				if params.exts then -- 1905
					local _accum_0 = { } -- 1906
					local _len_0 = 1 -- 1906
					for ext in params.exts:gmatch("[^|]*") do -- 1906
						_accum_0[_len_0] = ext -- 1906
						_len_0 = _len_0 + 1 -- 1906
					end -- 1906
					exts = _accum_0 -- 1906
				else -- 1907
					exts = { -- 1907
						"" -- 1907
					} -- 1907
				end -- 1905
				local readFileAt -- 1908
				readFileAt = function(targetPath) -- 1908
					if Content:exist(targetPath) then -- 1909
						local content = Content:load(targetPath) -- 1910
						if content then -- 1910
							return { -- 1911
								content = content, -- 1911
								success = true, -- 1911
								fullPath = Content:getFullPath(targetPath) -- 1911
							} -- 1911
						end -- 1910
					end -- 1909
					return nil -- 1908
				end -- 1908
				local readFile -- 1912
				readFile = function(fallbackPaths) -- 1912
					for _index_0 = 1, #exts do -- 1913
						local ext = exts[_index_0] -- 1913
						local targetPath = path .. ext -- 1914
						if not Content:isAbsolutePath(targetPath) then -- 1915
							for _index_1 = 1, #fallbackPaths do -- 1916
								local fallback = fallbackPaths[_index_1] -- 1916
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1917
								if fallbackResult then -- 1917
									return fallbackResult -- 1918
								end -- 1917
							end -- 1916
						end -- 1915
						local fileResult = readFileAt(targetPath) -- 1919
						if fileResult then -- 1919
							return fileResult -- 1920
						end -- 1919
					end -- 1913
					return nil -- 1912
				end -- 1912
				local fallbackPaths = { } -- 1921
				local fallbackCandidates = { } -- 1922
				do -- 1923
					local projectRoot = req.params.projectRoot -- 1923
					if projectRoot then -- 1923
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1924
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1925
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1926
						end -- 1924
					end -- 1923
				end -- 1923
				do -- 1927
					local projFile = req.params.projFile -- 1927
					if projFile then -- 1927
						local projDir = getProjectDirFromFile(projFile) -- 1928
						if projDir then -- 1928
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1929
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1930
						else -- 1932
							projDir = Path:getPath(projFile) -- 1932
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1933
						end -- 1928
					end -- 1927
				end -- 1927
				for _index_0 = 1, #fallbackCandidates do -- 1934
					local dir = fallbackCandidates[_index_0] -- 1934
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1935
						local exists = false -- 1936
						for _index_1 = 1, #fallbackPaths do -- 1937
							local fallback = fallbackPaths[_index_1] -- 1937
							if fallback == dir then -- 1938
								exists = true -- 1939
								break -- 1940
							end -- 1938
						end -- 1937
						if not exists then -- 1941
							fallbackPaths[#fallbackPaths + 1] = dir -- 1941
						end -- 1941
					end -- 1935
				end -- 1934
				local readResult = readFile(fallbackPaths) -- 1942
				if readResult then -- 1942
					return readResult -- 1943
				end -- 1942
			end -- 1902
		end -- 1902
	end -- 1902
	return { -- 1901
		success = false -- 1901
	} -- 1901
end) -- 1901
local addGeneratedSourceHeader -- 1945
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 1945
	if preserveTIC80 == nil then -- 1945
		preserveTIC80 = false -- 1945
	end -- 1945
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 1946
	if preserveTIC80 then -- 1947
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 1948
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 1949
		end -- 1948
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 1950
	end -- 1947
	return tostring(header) .. "\n" .. tostring(codes) -- 1951
end -- 1945
local compileFileAsync -- 1953
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1953
	if projectRoot == nil then -- 1953
		projectRoot = nil -- 1953
	end -- 1953
	local file = inputFile -- 1954
	local searchPath -- 1955
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1955
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1956
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1960
	elseif not Content:isAbsolutePath(inputFile) then -- 1961
		searchPath = "" -- 1962
	else -- 1963
		local dir = getProjectDirFromFile(inputFile) -- 1963
		if dir then -- 1963
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1964
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1968
		else -- 1970
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1970
			searchPath = "" -- 1973
		end -- 1963
	end -- 1955
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1974
	local yueext = yue.options.extension -- 1975
	local resultCodes = nil -- 1976
	local resultError = nil -- 1977
	do -- 1978
		local _exp_0 = Path:getExt(inputFile) -- 1978
		if yueext == _exp_0 then -- 1978
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1979
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1980
				if not codes then -- 1981
					resultError = err -- 1982
					return -- 1983
				end -- 1981
				local extraGlobal -- 1984
				if isTIC80 then -- 1984
					extraGlobal = tic80APIs -- 1984
				else -- 1984
					extraGlobal = nil -- 1984
				end -- 1984
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1985
				if not success then -- 1986
					resultError = message -- 1987
					return -- 1988
				end -- 1986
				if codes == "" then -- 1989
					resultCodes = "" -- 1990
					return nil -- 1991
				end -- 1989
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 1992
				return resultCodes -- 1993
			end, function(success) -- 1980
				if not success then -- 1994
					Content:remove(outputFile) -- 1995
					if resultCodes == nil then -- 1996
						resultCodes = false -- 1997
					end -- 1996
				end -- 1994
			end) -- 1980
		elseif "tl" == _exp_0 then -- 1998
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1999
			if isTIC80 then -- 2000
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2001
			end -- 2000
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2002
			if codes then -- 2002
				if isTIC80 then -- 2003
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2004
				end -- 2003
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2005
				Content:saveAsync(outputFile, resultCodes) -- 2006
			else -- 2008
				Content:remove(outputFile) -- 2008
				resultCodes = false -- 2009
				resultError = err -- 2010
			end -- 2002
		elseif "xml" == _exp_0 then -- 2011
			local codes, err = xml.tolua(sourceCodes) -- 2012
			if codes then -- 2012
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2013
				Content:saveAsync(outputFile, resultCodes) -- 2014
			else -- 2016
				Content:remove(outputFile) -- 2016
				resultCodes = false -- 2017
				resultError = err -- 2018
			end -- 2012
		end -- 1978
	end -- 1978
	wait(function() -- 2019
		return resultCodes ~= nil -- 2019
	end) -- 2019
	if resultCodes then -- 2020
		return resultCodes -- 2021
	else -- 2023
		return nil, resultError -- 2023
	end -- 2020
	return nil -- 1953
end -- 1953
HttpServer:postSchedule("/write", function(req) -- 2025
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2026
	local buildSucceeded = false -- 2027
	local _ <close> = setmetatable({ }, { -- 2028
		__close = function() -- 2028
			return finishUpdate(buildSucceeded) -- 2028
		end -- 2028
	}) -- 2028
	do -- 2029
		local _type_0 = type(req) -- 2029
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2029
		if _tab_0 then -- 2029
			local path -- 2029
			do -- 2029
				local _obj_0 = req.body -- 2029
				local _type_1 = type(_obj_0) -- 2029
				if "table" == _type_1 or "userdata" == _type_1 then -- 2029
					path = _obj_0.path -- 2029
				end -- 2029
			end -- 2029
			local content -- 2029
			do -- 2029
				local _obj_0 = req.body -- 2029
				local _type_1 = type(_obj_0) -- 2029
				if "table" == _type_1 or "userdata" == _type_1 then -- 2029
					content = _obj_0.content -- 2029
				end -- 2029
			end -- 2029
			if path ~= nil and content ~= nil then -- 2029
				if Content:saveAsync(path, content) then -- 2030
					do -- 2031
						local _exp_0 = Path:getExt(path) -- 2031
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2031
							if '' == Path:getExt(Path:getName(path)) then -- 2032
								local resultCodes = compileFileAsync(path, content) -- 2033
								buildSucceeded = resultCodes ~= nil -- 2034
								return { -- 2035
									success = true, -- 2035
									resultCodes = resultCodes -- 2035
								} -- 2035
							end -- 2032
						end -- 2031
					end -- 2031
					buildSucceeded = true -- 2036
					return { -- 2037
						success = true -- 2037
					} -- 2037
				end -- 2030
			end -- 2029
		end -- 2029
	end -- 2029
	return { -- 2025
		success = false -- 2025
	} -- 2025
end) -- 2025
local getWaProjectDirFromFile = nil -- 2039
HttpServer:postSchedule("/build", function(req) -- 2041
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2042
	local buildSucceeded = false -- 2043
	local _ <close> = setmetatable({ }, { -- 2044
		__close = function() -- 2044
			return finishUpdate(buildSucceeded) -- 2044
		end -- 2044
	}) -- 2044
	do -- 2045
		local _type_0 = type(req) -- 2045
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2045
		if _tab_0 then -- 2045
			local path -- 2045
			do -- 2045
				local _obj_0 = req.body -- 2045
				local _type_1 = type(_obj_0) -- 2045
				if "table" == _type_1 or "userdata" == _type_1 then -- 2045
					path = _obj_0.path -- 2045
				end -- 2045
			end -- 2045
			if path ~= nil then -- 2045
				local projectRoot = req.body.projectRoot -- 2046
				if Content:isdir(path) then -- 2047
					local projDir = getWaProjectDirFromFile(path) -- 2048
					if projDir then -- 2048
						local message = Wasm:buildWaAsync(projDir) -- 2049
						if message == "" then -- 2050
							return { -- 2051
								success = true -- 2051
							} -- 2051
						else -- 2053
							return { -- 2053
								success = false, -- 2053
								message = message -- 2053
							} -- 2053
						end -- 2050
					end -- 2048
				end -- 2047
				local _exp_0 = Path:getExt(path) -- 2054
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2055
					if '' == Path:getExt(Path:getName(path)) then -- 2056
						local content = Content:loadAsync(path) -- 2057
						if content then -- 2057
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2058
							if resultCodes then -- 2058
								buildSucceeded = true -- 2059
								return { -- 2060
									success = true, -- 2060
									resultCodes = resultCodes -- 2060
								} -- 2060
							end -- 2058
						end -- 2057
					end -- 2056
				elseif "wa" == _exp_0 then -- 2061
					local projDir = getWaProjectDirFromFile(path) -- 2062
					if projDir then -- 2062
						local message = Wasm:buildWaAsync(projDir) -- 2063
						if message == "" then -- 2064
							return { -- 2065
								success = true -- 2065
							} -- 2065
						else -- 2067
							return { -- 2067
								success = false, -- 2067
								message = message -- 2067
							} -- 2067
						end -- 2064
					else -- 2069
						return { -- 2069
							success = false, -- 2069
							message = 'Wa file needs a project' -- 2069
						} -- 2069
					end -- 2062
				end -- 2054
			end -- 2045
		end -- 2045
	end -- 2045
	return { -- 2041
		success = false -- 2041
	} -- 2041
end) -- 2041
local extentionLevels = { -- 2072
	vs = 2, -- 2072
	bl = 2, -- 2073
	ts = 1, -- 2074
	tsx = 1, -- 2075
	tl = 1, -- 2076
	yue = 1, -- 2077
	xml = 1, -- 2078
	lua = 0 -- 2079
} -- 2071
local visitAssets -- 2081
visitAssets = function(path, workspace, builtin, recursive) -- 2081
	if recursive == nil then -- 2081
		recursive = true -- 2081
	end -- 2081
	local children = nil -- 2082
	local dirs = Content:getDirs(path) -- 2083
	for _index_0 = 1, #dirs do -- 2084
		local dir = dirs[_index_0] -- 2084
		if workspace then -- 2085
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 2086
				goto _continue_0 -- 2087
			end -- 2086
		elseif dir == ".git" then -- 2088
			goto _continue_0 -- 2089
		end -- 2085
		if not children then -- 2090
			children = { } -- 2090
		end -- 2090
		local dirPath = Path(path, dir) -- 2091
		if recursive then -- 2092
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2093
		else -- 2095
			children[#children + 1] = { -- 2096
				key = dirPath, -- 2096
				dir = true, -- 2097
				title = dir, -- 2098
				builtin = builtin, -- 2099
				isLeaf = false -- 2100
			} -- 2095
		end -- 2092
		::_continue_0:: -- 2085
	end -- 2084
	local files = Content:getFiles(path) -- 2102
	local names = { } -- 2103
	for _index_0 = 1, #files do -- 2104
		local file = files[_index_0] -- 2104
		if (".DS_Store" == file) then -- 2105
			goto _continue_1 -- 2106
		end -- 2105
		local name = Path:getName(file) -- 2107
		local ext = names[name] -- 2108
		if ext then -- 2108
			local lv1 -- 2109
			do -- 2109
				local _exp_0 = extentionLevels[ext] -- 2109
				if _exp_0 ~= nil then -- 2109
					lv1 = _exp_0 -- 2109
				else -- 2109
					lv1 = -1 -- 2109
				end -- 2109
			end -- 2109
			ext = Path:getExt(file) -- 2110
			local lv2 -- 2111
			do -- 2111
				local _exp_0 = extentionLevels[ext] -- 2111
				if _exp_0 ~= nil then -- 2111
					lv2 = _exp_0 -- 2111
				else -- 2111
					lv2 = -1 -- 2111
				end -- 2111
			end -- 2111
			if lv2 > lv1 then -- 2112
				names[name] = ext -- 2113
			elseif lv2 == lv1 then -- 2114
				names[name .. '.' .. ext] = "" -- 2115
			end -- 2112
		else -- 2117
			ext = Path:getExt(file) -- 2117
			if not extentionLevels[ext] then -- 2118
				names[file] = "" -- 2119
			else -- 2121
				names[name] = ext -- 2121
			end -- 2118
		end -- 2108
		::_continue_1:: -- 2105
	end -- 2104
	do -- 2122
		local _accum_0 = { } -- 2122
		local _len_0 = 1 -- 2122
		for name, ext in pairs(names) do -- 2122
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2122
			_len_0 = _len_0 + 1 -- 2122
		end -- 2122
		files = _accum_0 -- 2122
	end -- 2122
	for _index_0 = 1, #files do -- 2123
		local file = files[_index_0] -- 2123
		if not children then -- 2124
			children = { } -- 2124
		end -- 2124
		children[#children + 1] = { -- 2126
			key = Path(path, file), -- 2126
			dir = false, -- 2127
			title = file, -- 2128
			builtin = builtin -- 2129
		} -- 2125
	end -- 2123
	if children then -- 2131
		table.sort(children, function(a, b) -- 2132
			if a.dir == b.dir then -- 2133
				return a.title < b.title -- 2134
			else -- 2136
				return a.dir -- 2136
			end -- 2133
		end) -- 2132
	end -- 2131
	return { -- 2138
		key = path, -- 2138
		dir = true, -- 2139
		title = Path:getFilename(path), -- 2140
		builtin = builtin, -- 2141
		isLeaf = not children, -- 2142
		children = children -- 2143
	} -- 2137
end -- 2081
HttpServer:post("/assets/children", function(req) -- 2146
	do -- 2147
		local _type_0 = type(req) -- 2147
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2147
		if _tab_0 then -- 2147
			local path -- 2147
			do -- 2147
				local _obj_0 = req.body -- 2147
				local _type_1 = type(_obj_0) -- 2147
				if "table" == _type_1 or "userdata" == _type_1 then -- 2147
					path = _obj_0.path -- 2147
				end -- 2147
			end -- 2147
			if path ~= nil then -- 2147
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2148
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2149
					return { -- 2149
						success = false -- 2149
					} -- 2149
				end -- 2149
				local node = visitAssets(path, workspace, builtin, false) -- 2150
				return { -- 2151
					success = true, -- 2151
					children = node.children or { } -- 2151
				} -- 2151
			end -- 2147
		end -- 2147
	end -- 2147
	return { -- 2146
		success = false -- 2146
	} -- 2146
end) -- 2146
HttpServer:post("/assets/files", function(req) -- 2153
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
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2155
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2156
				if not (workspace or builtin) then -- 2157
					return { -- 2157
						success = false -- 2157
					} -- 2157
				end -- 2157
				if not (Content:exist(path) and Content:isdir(path)) then -- 2158
					return { -- 2158
						success = false -- 2158
					} -- 2158
				end -- 2158
				local globs = { -- 2159
					"**", -- 2159
					"!**/.DS_Store" -- 2159
				} -- 2159
				if workspace then -- 2160
					globs = { -- 2162
						"**", -- 2162
						"!**/.DS_Store", -- 2162
						"!**/.upload/**", -- 2163
						"!**/.download/**", -- 2163
						"!**/.www/**", -- 2164
						"!**/.build/**", -- 2164
						"!**/.git/**", -- 2165
						"!**/.cache/**", -- 2165
						"!**/node_modules/**" -- 2166
					} -- 2161
				end -- 2160
				local files -- 2168
				do -- 2168
					local _accum_0 = { } -- 2168
					local _len_0 = 1 -- 2168
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2168
					for _index_0 = 1, #_list_0 do -- 2168
						local file = _list_0[_index_0] -- 2168
						_accum_0[_len_0] = Path(path, file) -- 2168
						_len_0 = _len_0 + 1 -- 2168
					end -- 2168
					files = _accum_0 -- 2168
				end -- 2168
				return { -- 2169
					success = true, -- 2169
					files = files -- 2169
				} -- 2169
			end -- 2154
		end -- 2154
	end -- 2154
	return { -- 2153
		success = false -- 2153
	} -- 2153
end) -- 2153
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2210
	local _tab_0 = { -- 2210
		{ -- 2211
			key = Path(Content.assetPath), -- 2211
			dir = true, -- 2212
			builtin = true, -- 2213
			title = zh and "内置资源" or "Built-in", -- 2214
			children = builtinChildren -- 2215
		} -- 2210
	} -- 2217
	local _obj_0 = workspace.children or { } -- 2217
	local _idx_0 = #_tab_0 + 1 -- 2217
	for _index_0 = 1, #_obj_0 do -- 2217
		local _value_0 = _obj_0[_index_0] -- 2217
		_tab_0[_idx_0] = _value_0 -- 2217
		_idx_0 = _idx_0 + 1 -- 2217
	end -- 2217
	return _tab_0 -- 2210
end -- 2210
HttpServer:post("/assets", function() -- 2171
	local Entry = require("Script.Dev.Entry") -- 2172
	local engineDev = Entry.getEngineDev() -- 2173
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2174
	local zh = (App.locale:match("^zh") ~= nil) -- 2175
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2176
	readme.title = zh and "说明文档" or "Readme" -- 2177
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2178
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2179
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2180
	tools.title = zh and "开发工具" or "Tools" -- 2181
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2182
	font.title = zh and "字体" or "Font" -- 2183
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2184
	lib.title = zh and "程序库" or "Lib" -- 2185
	if engineDev then -- 2186
		local _list_0 = lib.children -- 2187
		for _index_0 = 1, #_list_0 do -- 2187
			local child = _list_0[_index_0] -- 2187
			if not (child.title == "Dora") then -- 2188
				goto _continue_0 -- 2188
			end -- 2188
			local title = zh and "zh-Hans" or "en" -- 2189
			do -- 2190
				local _accum_0 = { } -- 2190
				local _len_0 = 1 -- 2190
				local _list_1 = child.children -- 2190
				for _index_1 = 1, #_list_1 do -- 2190
					local c = _list_1[_index_1] -- 2190
					if c.title ~= title then -- 2190
						_accum_0[_len_0] = c -- 2190
						_len_0 = _len_0 + 1 -- 2190
					end -- 2190
				end -- 2190
				child.children = _accum_0 -- 2190
			end -- 2190
			break -- 2191
			::_continue_0:: -- 2188
		end -- 2187
	else -- 2193
		local _accum_0 = { } -- 2193
		local _len_0 = 1 -- 2193
		local _list_0 = lib.children -- 2193
		for _index_0 = 1, #_list_0 do -- 2193
			local child = _list_0[_index_0] -- 2193
			if child.title ~= "Dora" then -- 2193
				_accum_0[_len_0] = child -- 2193
				_len_0 = _len_0 + 1 -- 2193
			end -- 2193
		end -- 2193
		lib.children = _accum_0 -- 2193
	end -- 2186
	local builtinChildren = { -- 2194
		readme, -- 2194
		apiDoc, -- 2194
		tools, -- 2194
		font, -- 2194
		lib -- 2194
	} -- 2194
	if engineDev then -- 2195
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2196
		do -- 2197
			local _obj_0 = dev.children -- 2197
			_obj_0[#_obj_0 + 1] = { -- 2198
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2198
				dir = false, -- 2199
				builtin = true, -- 2200
				title = "init.yue" -- 2201
			} -- 2197
		end -- 2197
		builtinChildren[#builtinChildren + 1] = dev -- 2203
	end -- 2195
	return { -- 2205
		key = Content.writablePath, -- 2205
		dir = true, -- 2206
		root = true, -- 2207
		title = "Assets", -- 2208
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2209
	} -- 2204
end) -- 2171
HttpServer:post("/entry/list", function(req) -- 2221
	local Entry = require("Script.Dev.Entry") -- 2222
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2223
	res.success = true -- 2224
	return res -- 2225
end) -- 2221
HttpServer:post("/run/status", function() -- 2227
	local Entry = require("Script.Dev.Entry") -- 2228
	return Entry.getCurrentEntryStatus() -- 2229
end) -- 2227
HttpServer:postSchedule("/run", function(req) -- 2231
	do -- 2232
		local _type_0 = type(req) -- 2232
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2232
		if _tab_0 then -- 2232
			local file -- 2232
			do -- 2232
				local _obj_0 = req.body -- 2232
				local _type_1 = type(_obj_0) -- 2232
				if "table" == _type_1 or "userdata" == _type_1 then -- 2232
					file = _obj_0.file -- 2232
				end -- 2232
			end -- 2232
			local asProj -- 2232
			do -- 2232
				local _obj_0 = req.body -- 2232
				local _type_1 = type(_obj_0) -- 2232
				if "table" == _type_1 or "userdata" == _type_1 then -- 2232
					asProj = _obj_0.asProj -- 2232
				end -- 2232
			end -- 2232
			if file ~= nil and asProj ~= nil then -- 2232
				if not Content:isAbsolutePath(file) then -- 2233
					local devFile = Path(Content.writablePath, file) -- 2234
					if Content:exist(devFile) then -- 2235
						file = devFile -- 2235
					end -- 2235
				end -- 2233
				local Entry = require("Script.Dev.Entry") -- 2236
				local workDir -- 2237
				if asProj then -- 2238
					local projectRoot = req.body.projectRoot -- 2239
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2240
						workDir = projectRoot -- 2241
					else -- 2243
						workDir = getProjectDirFromFile(file) -- 2243
					end -- 2240
					if workDir then -- 2244
						Entry.allClear() -- 2245
						local target = Path(workDir, "init") -- 2246
						local success, err = Entry.enterEntryAsync({ -- 2247
							entryName = "Project", -- 2247
							fileName = target, -- 2247
							workDir = workDir, -- 2247
							projectRoot = workDir, -- 2247
							runKind = "project" -- 2247
						}) -- 2247
						target = Path:getName(Path:getPath(target)) -- 2248
						return { -- 2249
							success = success, -- 2249
							target = target, -- 2249
							err = err -- 2249
						} -- 2249
					end -- 2244
				else -- 2251
					workDir = getProjectDirFromFile(file) -- 2251
					if not workDir and Path:getExt(file) == "wasm" then -- 2252
						local parent = Path:getPath(file) -- 2253
						if Content:exist(Path(parent, "wa.mod")) then -- 2254
							workDir = parent -- 2255
						end -- 2254
					end -- 2252
				end -- 2238
				Entry.allClear() -- 2256
				file = Path:replaceExt(file, "") -- 2257
				local entry = { -- 2259
					entryName = Path:getName(file), -- 2259
					fileName = file, -- 2260
					runKind = "file" -- 2261
				} -- 2258
				if workDir then -- 2262
					entry.workDir = workDir -- 2263
					entry.projectRoot = workDir -- 2264
				end -- 2262
				local success, err = Entry.enterEntryAsync(entry) -- 2265
				return { -- 2266
					success = success, -- 2266
					err = err -- 2266
				} -- 2266
			end -- 2232
		end -- 2232
	end -- 2232
	return { -- 2231
		success = false -- 2231
	} -- 2231
end) -- 2231
local _anon_func_7 = function(result) -- 2308
	if result.success then -- 2308
		return nil -- 2308
	else -- 2308
		return "PREVIEW_FAILED" -- 2308
	end -- 2308
end -- 2308
HttpServer:postSchedule("/agent/preview", function(req) -- 2268
	local releaseAgent = AgentHost.acquire() -- 2269
	local _ <close> = setmetatable({ }, { -- 2270
		__close = function() -- 2270
			return releaseAgent() -- 2270
		end -- 2270
	}) -- 2270
	do -- 2271
		local _type_0 = type(req) -- 2271
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2271
		if _tab_0 then -- 2271
			local projectRoot -- 2271
			do -- 2271
				local _obj_0 = req.body -- 2271
				local _type_1 = type(_obj_0) -- 2271
				if "table" == _type_1 or "userdata" == _type_1 then -- 2271
					projectRoot = _obj_0.projectRoot -- 2271
				end -- 2271
			end -- 2271
			if projectRoot ~= nil then -- 2271
				if not getProjectSourceRoot(projectRoot) then -- 2272
					return { -- 2272
						success = false, -- 2272
						code = "INVALID_PROJECT", -- 2272
						message = "projectRoot must be an existing absolute directory" -- 2272
					} -- 2272
				end -- 2272
				local entryFile = req.body.entry or "init.lua" -- 2273
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2274
					return { -- 2274
						success = false, -- 2274
						code = "INVALID_ENTRY", -- 2274
						message = "entry must be a non-empty project-relative path" -- 2274
					} -- 2274
				end -- 2274
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2275
					0.5 -- 2275
				} -- 2275
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2276
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2277
					return { -- 2277
						success = false, -- 2277
						code = "INVALID_QUEUE_TIMEOUT", -- 2277
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2277
					} -- 2277
				end -- 2277
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2278
				local AgentOperation = require("Agent.Tool.Operation") -- 2279
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2280
				local requestId = AgentOperation.createOperationId() -- 2281
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2282
				if not enqueued.success then -- 2283
					return { -- 2283
						success = false, -- 2283
						code = "ENTRY_QUEUE_REJECTED", -- 2283
						message = enqueued.message -- 2283
					} -- 2283
				end -- 2283
				local queuedAt = App.runningTime -- 2284
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2285
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2286
						local state = agentEntryRunQueue:get(requestId) -- 2287
						agentEntryRunQueue:cancel(requestId) -- 2288
						return { -- 2290
							success = false, -- 2290
							code = "ENTRY_QUEUE_TIMEOUT", -- 2291
							message = "timed out waiting for the Dora entry runtime", -- 2292
							requestId = requestId, -- 2293
							queuePosition = state.position -- 2294
						} -- 2289
					end -- 2286
					sleep() -- 2295
				end -- 2285
				local queueWaitSeconds = App.runningTime - queuedAt -- 2296
				local _ <close> = setmetatable({ }, { -- 2297
					__close = function() -- 2297
						return agentEntryRunQueue:release(requestId) -- 2297
					end -- 2297
				}) -- 2297
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2298
				local Entry = require("Script.Dev.Entry") -- 2299
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2301
					workDir = projectRoot, -- 2301
					operationId = requestId, -- 2302
					print = function() end -- 2303
				}, Entry) -- 2300
				local result = preview({ -- 2305
					entry = entryFile, -- 2305
					captureAtSeconds = captureAtSeconds -- 2305
				}) -- 2305
				return { -- 2307
					success = result.success, -- 2307
					code = _anon_func_7(result), -- 2308
					message = result.message, -- 2309
					requestId = requestId, -- 2310
					queueWaitSeconds = queueWaitSeconds, -- 2311
					interruptedUserRun = result.interruptedUserRun, -- 2312
					files = result.files, -- 2313
					frames = result.frames -- 2314
				} -- 2306
			end -- 2271
		end -- 2271
	end -- 2271
	return { -- 2268
		success = false, -- 2268
		message = "invalid call" -- 2268
	} -- 2268
end) -- 2268
HttpServer:postSchedule("/agent/command", function(req) -- 2316
	local releaseAgent = AgentHost.acquire() -- 2317
	local _ <close> = setmetatable({ }, { -- 2318
		__close = function() -- 2318
			return releaseAgent() -- 2318
		end -- 2318
	}) -- 2318
	do -- 2319
		local _type_0 = type(req) -- 2319
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2319
		if _tab_0 then -- 2319
			local body = req.body -- 2319
			if body ~= nil then -- 2319
				local projectRoot = body.projectRoot -- 2320
				if not getProjectSourceRoot(projectRoot) then -- 2321
					return { -- 2321
						success = false, -- 2321
						code = "INVALID_PROJECT", -- 2321
						message = "projectRoot must be an existing absolute directory" -- 2321
					} -- 2321
				end -- 2321
				local AgentValidation = require("Agent.Tool.Validation") -- 2322
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2323
				if not validated.success then -- 2324
					return { -- 2324
						success = false, -- 2324
						code = "INVALID_COMMAND", -- 2324
						message = validated.message -- 2324
					} -- 2324
				end -- 2324
				local input = validated.value -- 2325
				local AgentCommand = require("Agent.Tool.Command") -- 2326
				local result = nil -- 2327
				local failure = nil -- 2328
				local promise = AgentCommand.executeCommand({ -- 2330
					workDir = projectRoot, -- 2330
					mode = input.mode, -- 2331
					code = input.code, -- 2332
					command = input.command, -- 2333
					cwd = input.cwd, -- 2334
					timeoutSeconds = input.timeoutSeconds -- 2335
				}) -- 2329
				promise:addCallbacks((function(_, value) -- 2336
					result = value -- 2336
				end), (function(_, err) -- 2336
					failure = tostring(err) -- 2336
				end)) -- 2336
				wait(function() -- 2337
					return result ~= nil or failure ~= nil -- 2337
				end) -- 2337
				if failure then -- 2338
					return { -- 2338
						success = false, -- 2338
						code = "COMMAND_BRIDGE_FAILED", -- 2338
						message = failure -- 2338
					} -- 2338
				end -- 2338
				if not result.success then -- 2339
					result.code = "COMMAND_FAILED" -- 2340
				end -- 2339
				return result -- 2341
			end -- 2319
		end -- 2319
	end -- 2319
	return { -- 2316
		success = false, -- 2316
		code = "INVALID_COMMAND", -- 2316
		message = "invalid call" -- 2316
	} -- 2316
end) -- 2316
HttpServer:postSchedule("/stop", function() -- 2343
	local Entry = require("Script.Dev.Entry") -- 2344
	return { -- 2345
		success = Entry.stop() -- 2345
	} -- 2345
end) -- 2343
local minifyAsync -- 2347
minifyAsync = function(sourcePath, minifyPath) -- 2347
	if not Content:exist(sourcePath) then -- 2348
		return -- 2348
	end -- 2348
	local Entry = require("Script.Dev.Entry") -- 2349
	local errors = { } -- 2350
	local files = Entry.getAllFiles(sourcePath, { -- 2351
		"lua" -- 2351
	}, true) -- 2351
	do -- 2352
		local _accum_0 = { } -- 2352
		local _len_0 = 1 -- 2352
		for _index_0 = 1, #files do -- 2352
			local file = files[_index_0] -- 2352
			if file:sub(1, 1) ~= '.' then -- 2352
				_accum_0[_len_0] = file -- 2352
				_len_0 = _len_0 + 1 -- 2352
			end -- 2352
		end -- 2352
		files = _accum_0 -- 2352
	end -- 2352
	local paths -- 2353
	do -- 2353
		local _tbl_0 = { } -- 2353
		for _index_0 = 1, #files do -- 2353
			local file = files[_index_0] -- 2353
			_tbl_0[Path:getPath(file)] = true -- 2353
		end -- 2353
		paths = _tbl_0 -- 2353
	end -- 2353
	for path in pairs(paths) do -- 2354
		Content:mkdir(Path(minifyPath, path)) -- 2354
	end -- 2354
	local _ <close> = setmetatable({ }, { -- 2355
		__close = function() -- 2355
			package.loaded["luaminify.FormatMini"] = nil -- 2356
			package.loaded["luaminify.ParseLua"] = nil -- 2357
			package.loaded["luaminify.Scope"] = nil -- 2358
			package.loaded["luaminify.Util"] = nil -- 2359
		end -- 2355
	}) -- 2355
	local FormatMini -- 2360
	do -- 2360
		local _obj_0 = require("luaminify") -- 2360
		FormatMini = _obj_0.FormatMini -- 2360
	end -- 2360
	local fileCount = #files -- 2361
	local count = 0 -- 2362
	for _index_0 = 1, #files do -- 2363
		local file = files[_index_0] -- 2363
		thread(function() -- 2364
			local _ <close> = setmetatable({ }, { -- 2365
				__close = function() -- 2365
					count = count + 1 -- 2365
				end -- 2365
			}) -- 2365
			local input = Path(sourcePath, file) -- 2366
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2367
			if Content:exist(input) then -- 2368
				local sourceCodes = Content:loadAsync(input) -- 2369
				local res, err = FormatMini(sourceCodes) -- 2370
				if res then -- 2371
					Content:saveAsync(output, res) -- 2372
					return print("Minify " .. tostring(file)) -- 2373
				else -- 2375
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2375
				end -- 2371
			else -- 2377
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2377
			end -- 2368
		end) -- 2364
		sleep() -- 2378
	end -- 2363
	wait(function() -- 2379
		return count == fileCount -- 2379
	end) -- 2379
	if #errors > 0 then -- 2380
		print(table.concat(errors, '\n')) -- 2381
	end -- 2380
	print("Obfuscation done.") -- 2382
	return files -- 2383
end -- 2347
local zipping = false -- 2385
HttpServer:postSchedule("/zip", function(req) -- 2387
	do -- 2388
		local _type_0 = type(req) -- 2388
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2388
		if _tab_0 then -- 2388
			local path -- 2388
			do -- 2388
				local _obj_0 = req.body -- 2388
				local _type_1 = type(_obj_0) -- 2388
				if "table" == _type_1 or "userdata" == _type_1 then -- 2388
					path = _obj_0.path -- 2388
				end -- 2388
			end -- 2388
			local zipFile -- 2388
			do -- 2388
				local _obj_0 = req.body -- 2388
				local _type_1 = type(_obj_0) -- 2388
				if "table" == _type_1 or "userdata" == _type_1 then -- 2388
					zipFile = _obj_0.zipFile -- 2388
				end -- 2388
			end -- 2388
			local obfuscated -- 2388
			do -- 2388
				local _obj_0 = req.body -- 2388
				local _type_1 = type(_obj_0) -- 2388
				if "table" == _type_1 or "userdata" == _type_1 then -- 2388
					obfuscated = _obj_0.obfuscated -- 2388
				end -- 2388
			end -- 2388
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2388
				if zipping then -- 2389
					goto failed -- 2389
				end -- 2389
				zipping = true -- 2390
				local _ <close> = setmetatable({ }, { -- 2391
					__close = function() -- 2391
						zipping = false -- 2391
					end -- 2391
				}) -- 2391
				if not Content:exist(path) then -- 2392
					goto failed -- 2392
				end -- 2392
				Content:mkdir(Path:getPath(zipFile)) -- 2393
				if obfuscated then -- 2394
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2395
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2396
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2397
					Content:remove(scriptPath) -- 2398
					Content:remove(obfuscatedPath) -- 2399
					Content:remove(tempPath) -- 2400
					Content:mkdir(scriptPath) -- 2401
					Content:mkdir(obfuscatedPath) -- 2402
					Content:mkdir(tempPath) -- 2403
					if not Content:copyAsync(path, tempPath) then -- 2404
						goto failed -- 2404
					end -- 2404
					local Entry = require("Script.Dev.Entry") -- 2405
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2406
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2407
						"tl", -- 2407
						"yue", -- 2407
						"lua", -- 2407
						"ts", -- 2407
						"tsx", -- 2407
						"vs", -- 2407
						"bl", -- 2407
						"xml", -- 2407
						"wa", -- 2407
						"mod" -- 2407
					}, true) -- 2407
					for _index_0 = 1, #scriptFiles do -- 2408
						local file = scriptFiles[_index_0] -- 2408
						Content:remove(Path(tempPath, file)) -- 2409
					end -- 2408
					for _index_0 = 1, #luaFiles do -- 2410
						local file = luaFiles[_index_0] -- 2410
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2411
					end -- 2410
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2412
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2413
					end) then -- 2412
						goto failed -- 2412
					end -- 2412
					return { -- 2414
						success = true -- 2414
					} -- 2414
				else -- 2416
					return { -- 2416
						success = Content:zipAsync(path, zipFile, function(file) -- 2416
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2417
						end) -- 2416
					} -- 2416
				end -- 2394
			end -- 2388
		end -- 2388
	end -- 2388
	::failed:: -- 2418
	return { -- 2387
		success = false -- 2387
	} -- 2387
end) -- 2387
HttpServer:postSchedule("/unzip", function(req) -- 2420
	do -- 2421
		local _type_0 = type(req) -- 2421
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2421
		if _tab_0 then -- 2421
			local zipFile -- 2421
			do -- 2421
				local _obj_0 = req.body -- 2421
				local _type_1 = type(_obj_0) -- 2421
				if "table" == _type_1 or "userdata" == _type_1 then -- 2421
					zipFile = _obj_0.zipFile -- 2421
				end -- 2421
			end -- 2421
			local path -- 2421
			do -- 2421
				local _obj_0 = req.body -- 2421
				local _type_1 = type(_obj_0) -- 2421
				if "table" == _type_1 or "userdata" == _type_1 then -- 2421
					path = _obj_0.path -- 2421
				end -- 2421
			end -- 2421
			if zipFile ~= nil and path ~= nil then -- 2421
				return { -- 2422
					success = Content:unzipAsync(zipFile, path, function(file) -- 2422
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2423
					end) -- 2422
				} -- 2422
			end -- 2421
		end -- 2421
	end -- 2421
	return { -- 2420
		success = false -- 2420
	} -- 2420
end) -- 2420
HttpServer:post("/editing-info", function(req) -- 2425
	local Entry = require("Script.Dev.Entry") -- 2426
	local config = Entry.getConfig() -- 2427
	local _type_0 = type(req) -- 2428
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2428
	local _match_0 = false -- 2428
	if _tab_0 then -- 2428
		local editingInfo -- 2428
		do -- 2428
			local _obj_0 = req.body -- 2428
			local _type_1 = type(_obj_0) -- 2428
			if "table" == _type_1 or "userdata" == _type_1 then -- 2428
				editingInfo = _obj_0.editingInfo -- 2428
			end -- 2428
		end -- 2428
		if editingInfo ~= nil then -- 2428
			_match_0 = true -- 2428
			config.editingInfo = editingInfo -- 2429
			return { -- 2430
				success = true -- 2430
			} -- 2430
		end -- 2428
	end -- 2428
	if not _match_0 then -- 2428
		if not (config.editingInfo ~= nil) then -- 2432
			local folder -- 2433
			if App.locale:match('^zh') then -- 2433
				folder = 'zh-Hans' -- 2433
			else -- 2433
				folder = 'en' -- 2433
			end -- 2433
			config.editingInfo = json.encode({ -- 2435
				index = 0, -- 2435
				files = { -- 2437
					{ -- 2438
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2438
						title = "welcome.md" -- 2439
					} -- 2437
				} -- 2436
			}) -- 2434
		end -- 2432
		return { -- 2443
			success = true, -- 2443
			editingInfo = config.editingInfo -- 2443
		} -- 2443
	end -- 2428
end) -- 2425
HttpServer:post("/command", function(req) -- 2445
	do -- 2446
		local _type_0 = type(req) -- 2446
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2446
		if _tab_0 then -- 2446
			local code -- 2446
			do -- 2446
				local _obj_0 = req.body -- 2446
				local _type_1 = type(_obj_0) -- 2446
				if "table" == _type_1 or "userdata" == _type_1 then -- 2446
					code = _obj_0.code -- 2446
				end -- 2446
			end -- 2446
			local log -- 2446
			do -- 2446
				local _obj_0 = req.body -- 2446
				local _type_1 = type(_obj_0) -- 2446
				if "table" == _type_1 or "userdata" == _type_1 then -- 2446
					log = _obj_0.log -- 2446
				end -- 2446
			end -- 2446
			if code ~= nil and log ~= nil then -- 2446
				emit("AppCommand", code, log) -- 2447
				return { -- 2448
					success = true -- 2448
				} -- 2448
			end -- 2446
		end -- 2446
	end -- 2446
	return { -- 2445
		success = false -- 2445
	} -- 2445
end) -- 2445
HttpServer:post("/log/save", function() -- 2450
	local folder = ".download" -- 2451
	local fullLogFile = "dora_full_logs.txt" -- 2452
	local fullFolder = Path(Content.writablePath, folder) -- 2453
	Content:mkdir(fullFolder) -- 2454
	local logPath = Path(fullFolder, fullLogFile) -- 2455
	if App:saveLog(logPath) then -- 2456
		return { -- 2457
			success = true, -- 2457
			path = Path(folder, fullLogFile) -- 2457
		} -- 2457
	end -- 2456
	return { -- 2450
		success = false -- 2450
	} -- 2450
end) -- 2450
local tailLines -- 2459
tailLines = function(text, count) -- 2459
	local lines = { } -- 2460
	text = text:gsub("\r\n", "\n") -- 2461
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2462
		lines[#lines + 1] = line -- 2463
	end -- 2462
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2464
		table.remove(lines) -- 2465
	end -- 2464
	local start = math.max(1, #lines - count + 1) -- 2466
	local out = { } -- 2467
	for i = start, #lines do -- 2468
		out[#out + 1] = lines[i] -- 2469
	end -- 2468
	return table.concat(out, "\n") -- 2470
end -- 2459
HttpServer:post("/log", function(req) -- 2472
	local count = 100 -- 2473
	if req and req.body and req.body.count ~= nil then -- 2474
		count = req.body.count -- 2475
	end -- 2474
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2476
		return { -- 2477
			success = false, -- 2477
			message = "count must be a positive integer" -- 2477
		} -- 2477
	end -- 2476
	local folder = ".download" -- 2478
	local fullLogFile = "dora_full_logs.txt" -- 2479
	local fullFolder = Path(Content.writablePath, folder) -- 2480
	Content:mkdir(fullFolder) -- 2481
	local logPath = Path(fullFolder, fullLogFile) -- 2482
	if App:saveLog(logPath) then -- 2483
		local text = Content:load(logPath) -- 2484
		if text then -- 2485
			return { -- 2486
				success = true, -- 2486
				log = tailLines(text, count) -- 2486
			} -- 2486
		else -- 2488
			return { -- 2488
				success = false, -- 2488
				message = "failed to read log" -- 2488
			} -- 2488
		end -- 2485
	else -- 2490
		return { -- 2490
			success = false, -- 2490
			message = "failed to save log" -- 2490
		} -- 2490
	end -- 2483
	return { -- 2472
		success = false -- 2472
	} -- 2472
end) -- 2472
HttpServer:post("/yarn/check", function(req) -- 2492
	local yarncompile = require("yarncompile") -- 2493
	do -- 2494
		local _type_0 = type(req) -- 2494
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2494
		if _tab_0 then -- 2494
			local code -- 2494
			do -- 2494
				local _obj_0 = req.body -- 2494
				local _type_1 = type(_obj_0) -- 2494
				if "table" == _type_1 or "userdata" == _type_1 then -- 2494
					code = _obj_0.code -- 2494
				end -- 2494
			end -- 2494
			if code ~= nil then -- 2494
				local jsonObject = json.decode(code) -- 2495
				if jsonObject then -- 2495
					local errors = { } -- 2496
					local _list_0 = jsonObject.nodes -- 2497
					for _index_0 = 1, #_list_0 do -- 2497
						local node = _list_0[_index_0] -- 2497
						local title, body = node.title, node.body -- 2498
						local luaCode, err = yarncompile(body) -- 2499
						if not luaCode then -- 2499
							errors[#errors + 1] = title .. ":" .. err -- 2500
						end -- 2499
					end -- 2497
					return { -- 2501
						success = true, -- 2501
						syntaxError = table.concat(errors, "\n\n") -- 2501
					} -- 2501
				end -- 2495
			end -- 2494
		end -- 2494
	end -- 2494
	return { -- 2492
		success = false -- 2492
	} -- 2492
end) -- 2492
HttpServer:post("/yarn/check-file", function(req) -- 2503
	local yarncompile = require("yarncompile") -- 2504
	do -- 2505
		local _type_0 = type(req) -- 2505
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2505
		if _tab_0 then -- 2505
			local code -- 2505
			do -- 2505
				local _obj_0 = req.body -- 2505
				local _type_1 = type(_obj_0) -- 2505
				if "table" == _type_1 or "userdata" == _type_1 then -- 2505
					code = _obj_0.code -- 2505
				end -- 2505
			end -- 2505
			if code ~= nil then -- 2505
				local res, _, err = yarncompile(code, true) -- 2506
				if not res then -- 2506
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2507
					return { -- 2508
						success = false, -- 2508
						message = message, -- 2508
						line = line, -- 2508
						column = column, -- 2508
						node = node -- 2508
					} -- 2508
				end -- 2506
			end -- 2505
		end -- 2505
	end -- 2505
	return { -- 2503
		success = true -- 2503
	} -- 2503
end) -- 2503
getWaProjectDirFromFile = function(file) -- 2510
	local current -- 2511
	if Content:isdir(file) then -- 2511
		current = file -- 2511
	else -- 2511
		current = Path:getPath(file) -- 2511
	end -- 2511
	if current == "" then -- 2512
		return nil -- 2512
	end -- 2512
	repeat -- 2513
		local modPath = Path(current, "wa.mod") -- 2514
		if Content:exist(modPath) then -- 2515
			return current, modPath -- 2516
		end -- 2515
		local parent = Path:getPath(current) -- 2517
		if parent == "" or parent == current then -- 2518
			break -- 2518
		end -- 2518
		current = parent -- 2519
	until false -- 2513
	return nil -- 2521
end -- 2510
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2523
	do -- 2524
		local _type_0 = type(req) -- 2524
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2524
		if _tab_0 then -- 2524
			local path -- 2524
			do -- 2524
				local _obj_0 = req.body -- 2524
				local _type_1 = type(_obj_0) -- 2524
				if "table" == _type_1 or "userdata" == _type_1 then -- 2524
					path = _obj_0.path -- 2524
				end -- 2524
			end -- 2524
			if path ~= nil then -- 2524
				local projDir = getWaProjectDirFromFile(path) -- 2525
				if projDir then -- 2525
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2526
					if not Content:exist(sourceDoraPath) then -- 2527
						return { -- 2528
							success = false, -- 2528
							message = "missing dora template" -- 2528
						} -- 2528
					end -- 2527
					local targetVendorPath = Path(projDir, "vendor") -- 2529
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2530
					if not Content:exist(targetVendorPath) then -- 2531
						if not Content:mkdir(targetVendorPath) then -- 2532
							return { -- 2533
								success = false, -- 2533
								message = "failed to create vendor folder" -- 2533
							} -- 2533
						end -- 2532
					elseif not Content:isdir(targetVendorPath) then -- 2534
						return { -- 2535
							success = false, -- 2535
							message = "vendor path is not a folder" -- 2535
						} -- 2535
					end -- 2531
					if Content:exist(targetDoraPath) then -- 2536
						if not Content:remove(targetDoraPath) then -- 2537
							return { -- 2538
								success = false, -- 2538
								message = "failed to remove old dora" -- 2538
							} -- 2538
						end -- 2537
					end -- 2536
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2539
						return { -- 2540
							success = false, -- 2540
							message = "failed to copy dora" -- 2540
						} -- 2540
					end -- 2539
					return { -- 2541
						success = true -- 2541
					} -- 2541
				else -- 2543
					return { -- 2543
						success = false, -- 2543
						message = 'Wa file needs a project' -- 2543
					} -- 2543
				end -- 2525
			end -- 2524
		end -- 2524
	end -- 2524
	return { -- 2523
		success = false, -- 2523
		message = "invalid call" -- 2523
	} -- 2523
end) -- 2523
HttpServer:postSchedule("/wa/build", function(req) -- 2545
	do -- 2546
		local _type_0 = type(req) -- 2546
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2546
		if _tab_0 then -- 2546
			local path -- 2546
			do -- 2546
				local _obj_0 = req.body -- 2546
				local _type_1 = type(_obj_0) -- 2546
				if "table" == _type_1 or "userdata" == _type_1 then -- 2546
					path = _obj_0.path -- 2546
				end -- 2546
			end -- 2546
			if path ~= nil then -- 2546
				local projDir = getWaProjectDirFromFile(path) -- 2547
				if projDir then -- 2547
					local message = Wasm:buildWaAsync(projDir) -- 2548
					if message == "" then -- 2549
						return { -- 2550
							success = true -- 2550
						} -- 2550
					else -- 2552
						return { -- 2552
							success = false, -- 2552
							message = message -- 2552
						} -- 2552
					end -- 2549
				else -- 2554
					return { -- 2554
						success = false, -- 2554
						message = 'Wa file needs a project' -- 2554
					} -- 2554
				end -- 2547
			end -- 2546
		end -- 2546
	end -- 2546
	return { -- 2555
		success = false, -- 2555
		message = 'failed to build' -- 2555
	} -- 2555
end) -- 2545
HttpServer:postSchedule("/wa/format", function(req) -- 2557
	do -- 2558
		local _type_0 = type(req) -- 2558
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2558
		if _tab_0 then -- 2558
			local file -- 2558
			do -- 2558
				local _obj_0 = req.body -- 2558
				local _type_1 = type(_obj_0) -- 2558
				if "table" == _type_1 or "userdata" == _type_1 then -- 2558
					file = _obj_0.file -- 2558
				end -- 2558
			end -- 2558
			if file ~= nil then -- 2558
				local code = Wasm:formatWaAsync(file) -- 2559
				if code == "" then -- 2560
					return { -- 2561
						success = false -- 2561
					} -- 2561
				else -- 2563
					return { -- 2563
						success = true, -- 2563
						code = code -- 2563
					} -- 2563
				end -- 2560
			end -- 2558
		end -- 2558
	end -- 2558
	return { -- 2564
		success = false -- 2564
	} -- 2564
end) -- 2557
HttpServer:postSchedule("/wa/create", function(req) -- 2566
	do -- 2567
		local _type_0 = type(req) -- 2567
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2567
		if _tab_0 then -- 2567
			local path -- 2567
			do -- 2567
				local _obj_0 = req.body -- 2567
				local _type_1 = type(_obj_0) -- 2567
				if "table" == _type_1 or "userdata" == _type_1 then -- 2567
					path = _obj_0.path -- 2567
				end -- 2567
			end -- 2567
			if path ~= nil then -- 2567
				if not Content:exist(Path:getPath(path)) then -- 2568
					return { -- 2569
						success = false, -- 2569
						message = "target path not existed" -- 2569
					} -- 2569
				end -- 2568
				if Content:exist(path) then -- 2570
					return { -- 2571
						success = false, -- 2571
						message = "target project folder existed" -- 2571
					} -- 2571
				end -- 2570
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2572
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2573
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2574
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2575
					return { -- 2578
						success = false, -- 2578
						message = "missing template project" -- 2578
					} -- 2578
				end -- 2575
				if not Content:mkdir(path) then -- 2579
					return { -- 2580
						success = false, -- 2580
						message = "failed to create project folder" -- 2580
					} -- 2580
				end -- 2579
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2581
					Content:remove(path) -- 2582
					return { -- 2583
						success = false, -- 2583
						message = "failed to copy template" -- 2583
					} -- 2583
				end -- 2581
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2584
					Content:remove(path) -- 2585
					return { -- 2586
						success = false, -- 2586
						message = "failed to copy template" -- 2586
					} -- 2586
				end -- 2584
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2587
					Content:remove(path) -- 2588
					return { -- 2589
						success = false, -- 2589
						message = "failed to copy template" -- 2589
					} -- 2589
				end -- 2587
				return { -- 2590
					success = true -- 2590
				} -- 2590
			end -- 2567
		end -- 2567
	end -- 2567
	return { -- 2566
		success = false, -- 2566
		message = "invalid call" -- 2566
	} -- 2566
end) -- 2566
local tsBuildGlobs = { -- 2593
	"**/*.ts", -- 2593
	"**/*.tsx", -- 2594
	"!**/.*/**", -- 2595
	"!**/node_modules/**" -- 2596
} -- 2592
local tsSnapshotGlobs = { -- 2599
	"**/*.ts", -- 2599
	"**/*.tsx", -- 2600
	"**/*.lua", -- 2601
	"!**/.*/**", -- 2602
	"!**/node_modules/**" -- 2603
} -- 2598
local collectTSVirtualFiles -- 2605
collectTSVirtualFiles = function(sourceRoot) -- 2605
	local files = { } -- 2606
	local seen = { } -- 2607
	local addFile -- 2608
	addFile = function(file, moduleName, virtualFile) -- 2608
		if moduleName == nil then -- 2608
			moduleName = nil -- 2608
		end -- 2608
		if virtualFile == nil then -- 2608
			virtualFile = nil -- 2608
		end -- 2608
		local targetFile = virtualFile or file -- 2609
		do -- 2610
			local entry = seen[targetFile] -- 2610
			if entry then -- 2610
				if moduleName and moduleName ~= "" then -- 2611
					entry.moduleName = moduleName -- 2611
				end -- 2611
				return -- 2612
			end -- 2610
		end -- 2610
		local content = Content:load(file) -- 2613
		if content then -- 2613
			local entry = { -- 2614
				file = targetFile, -- 2614
				content = content -- 2614
			} -- 2614
			if moduleName and moduleName ~= "" then -- 2615
				entry.moduleName = moduleName -- 2615
			end -- 2615
			seen[targetFile] = entry -- 2616
			files[#files + 1] = entry -- 2617
		end -- 2613
	end -- 2608
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2618
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2619
		for _index_0 = 1, #_list_0 do -- 2619
			local subFile = _list_0[_index_0] -- 2619
			addFile(Path(sourceRoot, subFile)) -- 2620
		end -- 2619
		local libraryRoots = { -- 2622
			Path(sourceRoot, "Script", "Lib"), -- 2622
			Path(sourceRoot, "Lib"), -- 2623
			Path(Content.assetPath, "Script", "Lib") -- 2624
		} -- 2621
		for _index_0 = 1, #libraryRoots do -- 2625
			local libraryRoot = libraryRoots[_index_0] -- 2625
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2626
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2627
				for _index_1 = 1, #_list_1 do -- 2627
					local subFile = _list_1[_index_1] -- 2627
					local file = Path(libraryRoot, subFile) -- 2628
					local virtualFile = Path(sourceRoot, subFile) -- 2629
					addFile(file, nil, virtualFile) -- 2630
				end -- 2627
			end -- 2626
		end -- 2625
	end -- 2618
	local locale -- 2631
	if App.locale:match('^zh') then -- 2631
		locale = 'zh-Hans' -- 2631
	else -- 2631
		locale = 'en' -- 2631
	end -- 2631
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2632
	local _list_0 = Content:getFiles(declarationRoot) -- 2633
	for _index_0 = 1, #_list_0 do -- 2633
		local file = _list_0[_index_0] -- 2633
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2634
			local fullPath = Path(declarationRoot, file) -- 2635
			local moduleName = Path:getName(Path:getName(file)) -- 2636
			addFile(fullPath, moduleName) -- 2637
		end -- 2634
	end -- 2633
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2638
	local lualibBundleTarget -- 2639
	if sourceRoot then -- 2639
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2639
	else -- 2639
		lualibBundleTarget = "lualib_bundle.lua" -- 2639
	end -- 2639
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2640
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2641
	local _list_1 = Content:getFiles(lualibRoot) -- 2642
	for _index_0 = 1, #_list_1 do -- 2642
		local file = _list_1[_index_0] -- 2642
		if Path:getExt(file) == "lua" then -- 2643
			local virtualFile -- 2644
			if sourceRoot then -- 2644
				virtualFile = Path(sourceRoot, "lualib", file) -- 2644
			else -- 2644
				virtualFile = Path("lualib", file) -- 2644
			end -- 2644
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2645
		end -- 2643
	end -- 2642
	return files -- 2646
end -- 2605
local supportsCompilerWebView -- 2648
supportsCompilerWebView = function() -- 2648
	local _val_0 = App.platform -- 2648
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2648
end -- 2648
local webIDECompilerReady = false -- 2649
local webIDEConnectionGeneration = 0 -- 2650
local tsProbeId = 0 -- 2651
local probeWebIDECompiler -- 2653
probeWebIDECompiler = function(isCancelled) -- 2653
	if HttpServer.wsConnectionCount == 0 then -- 2654
		return false -- 2654
	end -- 2654
	tsProbeId = tsProbeId + 1 -- 2655
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2656
	local generation = webIDEConnectionGeneration -- 2657
	local done, ready = false, false -- 2658
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2659
	local listener = Node() -- 2660
	listener:gslot("AppWS", function(event) -- 2661
		if event.type == "Receive" then -- 2662
			local res = json.decode(event.msg) -- 2663
			if res then -- 2663
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2664
					responses = responses + 1 -- 2665
					ready = ready or res.success == true -- 2666
					done = ready or responses >= expectedResponses -- 2667
				end -- 2664
			end -- 2663
		end -- 2662
	end) -- 2661
	emit("AppWS", "Send", json.encode({ -- 2668
		name = "TranspileTSProbe", -- 2668
		id = requestId -- 2668
	})) -- 2668
	local deadline = App.runningTime + 5 -- 2669
	wait(function() -- 2670
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2670
	end) -- 2670
	listener:removeFromParent() -- 2671
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2672
	if generation == webIDEConnectionGeneration then -- 2673
		webIDECompilerReady = ready -- 2673
	end -- 2673
	return ready -- 2674
end -- 2653
local compilerConnectionListener = Node() -- 2676
compilerConnectionListener:addTo(Director.systemUI) -- 2678
local _anon_func_8 = function(event) -- 2680
	local _val_0 = event.type -- 2680
	return "Open" == _val_0 or "Close" == _val_0 -- 2680
end -- 2680
compilerConnectionListener:gslot("AppWS", function(event) -- 2679
	if _anon_func_8(event) then -- 2680
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2681
		webIDECompilerReady = false -- 2682
		if HttpServer.wsConnectionCount > 0 then -- 2683
			return thread(function() -- 2684
				return probeWebIDECompiler() -- 2684
			end) -- 2684
		end -- 2683
	end -- 2680
end) -- 2679
local _anon_func_9 = function(res) -- 2709
	if res.success then -- 2709
		return "tool" -- 2709
	else -- 2709
		return res.failureKind -- 2709
	end -- 2709
end -- 2709
local transpileTSFileWithWebIDE -- 2686
do -- 2686
	local tsBuildRequestId = 0 -- 2687
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2688
		if not probeWebIDECompiler(isCancelled) then -- 2689
			if isCancelled and isCancelled() then -- 2690
				return { -- 2691
					success = false, -- 2691
					file = file, -- 2691
					message = "build canceled", -- 2691
					interrupted = true -- 2691
				} -- 2691
			end -- 2690
			return { -- 2692
				success = false, -- 2692
				file = file, -- 2692
				message = "TypeScript transpiler is not ready", -- 2692
				failureKind = "tool" -- 2692
			} -- 2692
		end -- 2689
		tsBuildRequestId = tsBuildRequestId + 1 -- 2693
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2694
		local done = false -- 2695
		local result = nil -- 2696
		local listener = Node() -- 2697
		listener:gslot("AppWS", function(event) -- 2698
			if event.type == "Receive" then -- 2699
				local res = json.decode(event.msg) -- 2700
				if res then -- 2700
					if res.name == "TranspileTS" and res.id == requestId then -- 2701
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2702
							local luaFile = Path:replaceExt(file, "lua") -- 2703
							if Content:save(luaFile, res.luaCode) then -- 2704
								result = { -- 2705
									success = true, -- 2705
									file = file -- 2705
								} -- 2705
							else -- 2707
								result = { -- 2707
									success = false, -- 2707
									file = file, -- 2707
									message = "failed to save " .. tostring(luaFile) -- 2707
								} -- 2707
							end -- 2704
						else -- 2709
							result = { -- 2709
								success = false, -- 2709
								file = file, -- 2709
								message = res.message or "Compiler returned no Lua output", -- 2709
								failureKind = _anon_func_9(res) -- 2709
							} -- 2709
						end -- 2702
						done = true -- 2710
					end -- 2701
				end -- 2700
			end -- 2699
		end) -- 2698
		emit("AppWS", "Send", json.encode({ -- 2711
			name = "TranspileTS", -- 2711
			id = requestId, -- 2711
			file = file, -- 2711
			content = content, -- 2711
			projectRoot = sourceRoot, -- 2711
			files = files -- 2711
		})) -- 2711
		local deadline = App.runningTime + 30 -- 2712
		wait(function() -- 2713
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2713
		end) -- 2713
		listener:removeFromParent() -- 2714
		if not done then -- 2715
			webIDECompilerReady = false -- 2716
			if isCancelled and isCancelled() then -- 2717
				return { -- 2718
					success = false, -- 2718
					file = file, -- 2718
					message = "build canceled", -- 2718
					interrupted = true -- 2718
				} -- 2718
			end -- 2717
			return { -- 2719
				success = false, -- 2719
				file = file, -- 2719
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2719
				failureKind = "tool" -- 2719
			} -- 2719
		end -- 2715
		return result -- 2720
	end -- 2688
end -- 2686
local compilerReadyTimeout <const> = 15 -- 2722
local compilerBuildTimeout <const> = 30 -- 2723
local compilerIdleCloseSeconds <const> = 8 -- 2724
local compilerReady = false -- 2725
local compilerRequested = false -- 2726
local compilerFailure = nil -- 2727
local compilerUsers = 0 -- 2728
local compilerCloseGeneration = 0 -- 2729
local compilerJobId = 0 -- 2730
local compilerJobs = { } -- 2731
local compilerResults = { } -- 2732
local compilerInFlight = { } -- 2733
HttpServer:post("/compiler/ready", function() -- 2735
	if not compilerRequested then -- 2736
		return { -- 2736
			success = false -- 2736
		} -- 2736
	end -- 2736
	compilerReady = true -- 2737
	return { -- 2738
		success = true -- 2738
	} -- 2738
end) -- 2735
HttpServer:post("/compiler/failure", function(req) -- 2740
	if not compilerRequested then -- 2741
		return { -- 2741
			success = false -- 2741
		} -- 2741
	end -- 2741
	do -- 2742
		local _type_0 = type(req) -- 2742
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2742
		if _tab_0 then -- 2742
			local message -- 2742
			do -- 2742
				local _obj_0 = req.body -- 2742
				local _type_1 = type(_obj_0) -- 2742
				if "table" == _type_1 or "userdata" == _type_1 then -- 2742
					message = _obj_0.message -- 2742
				end -- 2742
			end -- 2742
			if message ~= nil then -- 2742
				if type(message) == "string" then -- 2743
					compilerFailure = message -- 2744
					compilerReady = false -- 2745
					return { -- 2746
						success = true -- 2746
					} -- 2746
				end -- 2743
			end -- 2742
		end -- 2742
	end -- 2742
	return { -- 2740
		success = false -- 2740
	} -- 2740
end) -- 2740
HttpServer:postSchedule("/compiler/poll", function() -- 2748
	if not compilerRequested then -- 2749
		return { -- 2749
			success = false -- 2749
		} -- 2749
	end -- 2749
	compilerReady = true -- 2750
	local deadline = App.runningTime + 5 -- 2751
	wait(function() -- 2752
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2752
	end) -- 2752
	if not (compilerRequested and not compilerFailure) then -- 2753
		return { -- 2753
			success = false -- 2753
		} -- 2753
	end -- 2753
	local job = table.remove(compilerJobs, 1) -- 2754
	if job then -- 2755
		compilerInFlight[job.id] = true -- 2756
	end -- 2755
	return { -- 2757
		success = true, -- 2757
		job = job -- 2757
	} -- 2757
end) -- 2748
HttpServer:post("/compiler/result", function(req) -- 2759
	do -- 2760
		local _type_0 = type(req) -- 2760
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2760
		if _tab_0 then -- 2760
			local body = req.body -- 2760
			if body ~= nil then -- 2760
				local id = body.id -- 2761
				if not (id and compilerInFlight[id]) then -- 2762
					return { -- 2762
						success = false, -- 2762
						message = "invalid compiler job" -- 2762
					} -- 2762
				end -- 2762
				compilerInFlight[id] = nil -- 2763
				compilerResults[id] = body -- 2764
				return { -- 2765
					success = true -- 2765
				} -- 2765
			end -- 2760
		end -- 2760
	end -- 2760
	return { -- 2759
		success = false -- 2759
	} -- 2759
end) -- 2759
local acquireCompiler -- 2767
acquireCompiler = function() -- 2767
	compilerUsers = compilerUsers + 1 -- 2768
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2769
	if not compilerRequested then -- 2770
		compilerRequested = true -- 2771
		compilerReady = false -- 2772
		compilerFailure = nil -- 2773
		return emit("AppWebView", "/compiler.html", true) -- 2774
	end -- 2770
end -- 2767
local releaseCompiler -- 2776
releaseCompiler = function() -- 2776
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2777
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2778
	if not (compilerUsers == 0) then -- 2779
		return -- 2779
	end -- 2779
	local closeGeneration = compilerCloseGeneration -- 2780
	return thread(function() -- 2781
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2782
		wait(function() -- 2783
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2784
		end) -- 2783
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2789
			compilerRequested = false -- 2790
			compilerReady = false -- 2791
			return emit("AppWebView", "/compiler.html", false) -- 2792
		end -- 2789
	end) -- 2781
end -- 2776
local removeCompilerJob -- 2794
removeCompilerJob = function(id) -- 2794
	for index = #compilerJobs, 1, -1 do -- 2795
		if compilerJobs[index].id == id then -- 2796
			table.remove(compilerJobs, index) -- 2797
		end -- 2796
	end -- 2795
	compilerInFlight[id] = nil -- 2798
	compilerResults[id] = nil -- 2799
end -- 2794
local transpileTSFileWithCompiler -- 2801
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2801
	acquireCompiler() -- 2802
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2803
	wait(function() -- 2804
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2804
	end) -- 2804
	if not compilerReady then -- 2805
		releaseCompiler() -- 2806
		if isCancelled and isCancelled() then -- 2807
			return { -- 2808
				success = false, -- 2808
				file = file, -- 2808
				message = "build canceled", -- 2808
				interrupted = true -- 2808
			} -- 2808
		end -- 2807
		return { -- 2809
			success = false, -- 2809
			file = file, -- 2809
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2809
			failureKind = "tool" -- 2809
		} -- 2809
	end -- 2805
	compilerJobId = compilerJobId + 1 -- 2810
	local jobId = compilerJobId -- 2811
	compilerJobs[#compilerJobs + 1] = { -- 2813
		id = jobId, -- 2813
		file = file, -- 2814
		content = content, -- 2815
		projectRoot = sourceRoot, -- 2816
		files = files -- 2817
	} -- 2812
	local deadline = App.runningTime + compilerBuildTimeout -- 2818
	wait(function() -- 2819
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2819
	end) -- 2819
	local response = compilerResults[jobId] -- 2820
	removeCompilerJob(jobId) -- 2821
	releaseCompiler() -- 2822
	if not response then -- 2823
		if isCancelled and isCancelled() then -- 2824
			return { -- 2825
				success = false, -- 2825
				file = file, -- 2825
				message = "build canceled", -- 2825
				interrupted = true -- 2825
			} -- 2825
		end -- 2824
		return { -- 2826
			success = false, -- 2826
			file = file, -- 2826
			message = compilerFailure or "TypeScript transpile timed out", -- 2826
			failureKind = "tool" -- 2826
		} -- 2826
	end -- 2823
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2827
		local luaFile = Path:replaceExt(file, "lua") -- 2828
		if Content:save(luaFile, response.luaCode) then -- 2829
			return { -- 2830
				success = true, -- 2830
				file = file -- 2830
			} -- 2830
		end -- 2829
		return { -- 2831
			success = false, -- 2831
			file = file, -- 2831
			message = "failed to save " .. tostring(luaFile) -- 2831
		} -- 2831
	end -- 2827
	return { -- 2832
		success = false, -- 2832
		file = file, -- 2832
		message = response.message or "TypeScript transpile failed" -- 2832
	} -- 2832
end -- 2801
local compilerFailureListener = Node() -- 2834
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2835
	compilerFailure = message -- 2836
	compilerReady = false -- 2837
end) -- 2835
local transpileTSFile -- 2839
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2839
	if supportsCompilerWebView() and not files then -- 2840
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2841
	end -- 2840
	if HttpServer.wsConnectionCount > 0 then -- 2842
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2843
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2844
			return result -- 2844
		end -- 2844
		webIDECompilerReady = false -- 2845
	end -- 2842
	if supportsCompilerWebView() then -- 2846
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2847
	end -- 2846
	return { -- 2848
		success = false, -- 2848
		file = file, -- 2848
		message = "Web IDE compiler not connected", -- 2848
		failureKind = "tool" -- 2848
	} -- 2848
end -- 2839
local _anon_func_10 = function(path) -- 2863
	local _val_0 = Path:getExt(path) -- 2863
	return "ts" == _val_0 or "tsx" == _val_0 -- 2863
end -- 2863
HttpServer:postSchedule("/ts/build", function(req) -- 2850
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2851
	local buildSucceeded = false -- 2852
	local _ <close> = setmetatable({ }, { -- 2853
		__close = function() -- 2853
			return finishUpdate(buildSucceeded) -- 2853
		end -- 2853
	}) -- 2853
	do -- 2854
		local _type_0 = type(req) -- 2854
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2854
		if _tab_0 then -- 2854
			local path -- 2854
			do -- 2854
				local _obj_0 = req.body -- 2854
				local _type_1 = type(_obj_0) -- 2854
				if "table" == _type_1 or "userdata" == _type_1 then -- 2854
					path = _obj_0.path -- 2854
				end -- 2854
			end -- 2854
			if path ~= nil then -- 2854
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2855
					return { -- 2856
						success = false, -- 2856
						message = "Web IDE not connected" -- 2856
					} -- 2856
				end -- 2855
				local projectRoot = req.body.projectRoot -- 2857
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2858
				if not Content:exist(path) then -- 2859
					return { -- 2860
						success = false, -- 2860
						message = "path not existed" -- 2860
					} -- 2860
				end -- 2859
				local messages = { } -- 2861
				if not Content:isdir(path) then -- 2862
					if not (_anon_func_10(path)) then -- 2863
						return { -- 2864
							success = false, -- 2864
							message = "expecting a TypeScript file" -- 2864
						} -- 2864
					end -- 2863
					local content = Content:load(path) -- 2865
					if not content then -- 2866
						return { -- 2867
							success = false, -- 2867
							message = "failed to read file" -- 2867
						} -- 2867
					end -- 2866
					emit("AppWS", "Send", json.encode({ -- 2868
						name = "UpdateFile", -- 2868
						file = path, -- 2868
						exists = true, -- 2868
						content = content, -- 2868
						projectRoot = sourceRoot -- 2868
					})) -- 2868
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2869
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2870
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2871
					end -- 2869
				else -- 2873
					local fileData = { } -- 2873
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2874
					for _index_0 = 1, #_list_0 do -- 2874
						local subFile = _list_0[_index_0] -- 2874
						local file = Path(path, subFile) -- 2875
						local content = Content:load(file) -- 2876
						if content then -- 2876
							fileData[file] = content -- 2877
							emit("AppWS", "Send", json.encode({ -- 2878
								name = "UpdateFile", -- 2878
								file = file, -- 2878
								exists = true, -- 2878
								content = content, -- 2878
								projectRoot = sourceRoot -- 2878
							})) -- 2878
						else -- 2880
							messages[#messages + 1] = { -- 2880
								success = false, -- 2880
								file = file, -- 2880
								message = "failed to read file" -- 2880
							} -- 2880
						end -- 2876
					end -- 2874
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2881
					for file, content in pairs(fileData) do -- 2882
						if "d" == Path:getExt(Path:getName(file)) then -- 2883
							goto _continue_0 -- 2883
						end -- 2883
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2884
						::_continue_0:: -- 2883
					end -- 2882
				end -- 2862
				local success = true -- 2885
				for _index_0 = 1, #messages do -- 2886
					local item = messages[_index_0] -- 2886
					if not item.success then -- 2887
						success = false -- 2887
					end -- 2887
				end -- 2886
				local message = nil -- 2888
				if not success then -- 2889
					message = "TypeScript compilation failed" -- 2889
				end -- 2889
				buildSucceeded = success -- 2890
				return { -- 2891
					success = success, -- 2891
					messages = messages, -- 2891
					message = message -- 2891
				} -- 2891
			end -- 2854
		end -- 2854
	end -- 2854
	return { -- 2850
		success = false -- 2850
	} -- 2850
end) -- 2850
HttpServer:post("/download", function(req) -- 2893
	do -- 2894
		local _type_0 = type(req) -- 2894
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2894
		if _tab_0 then -- 2894
			local url -- 2894
			do -- 2894
				local _obj_0 = req.body -- 2894
				local _type_1 = type(_obj_0) -- 2894
				if "table" == _type_1 or "userdata" == _type_1 then -- 2894
					url = _obj_0.url -- 2894
				end -- 2894
			end -- 2894
			local target -- 2894
			do -- 2894
				local _obj_0 = req.body -- 2894
				local _type_1 = type(_obj_0) -- 2894
				if "table" == _type_1 or "userdata" == _type_1 then -- 2894
					target = _obj_0.target -- 2894
				end -- 2894
			end -- 2894
			if url ~= nil and target ~= nil then -- 2894
				local Entry = require("Script.Dev.Entry") -- 2895
				Entry.downloadFile(url, target) -- 2896
				return { -- 2897
					success = true -- 2897
				} -- 2897
			end -- 2894
		end -- 2894
	end -- 2894
	return { -- 2893
		success = false -- 2893
	} -- 2893
end) -- 2893
local isDesktopPlatform -- 2899
isDesktopPlatform = function() -- 2899
	local _val_0 = App.platform -- 2900
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2900
end -- 2899
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 2902
local nativeIDEListener = Node() -- 2903
nativeIDEListener:addTo(Director.systemUI) -- 2904
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 2905
	nativeIDEState, nativeIDEMessage = state, message -- 2906
end) -- 2905
local _anon_func_11 = function() -- 2909
	local _val_0 = App.platform -- 2909
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2909
end -- 2909
HttpServer:post("/ide", function(req) -- 2908
	if not (_anon_func_11()) then -- 2909
		return { -- 2909
			success = false, -- 2909
			message = "Native IDE is unavailable" -- 2909
		} -- 2909
	end -- 2909
	if not App.webIDEEnabled then -- 2910
		return { -- 2910
			success = false, -- 2910
			message = "Embedded Web IDE is disabled" -- 2910
		} -- 2910
	end -- 2910
	do -- 2911
		local _type_0 = type(req) -- 2911
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2911
		if _tab_0 then -- 2911
			local action -- 2911
			do -- 2911
				local _obj_0 = req.body -- 2911
				local _type_1 = type(_obj_0) -- 2911
				if "table" == _type_1 or "userdata" == _type_1 then -- 2911
					action = _obj_0.action -- 2911
				end -- 2911
			end -- 2911
			if action ~= nil then -- 2911
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 2912
					emit("AppWebView", "/ide/" .. action, true) -- 2913
					return { -- 2914
						success = true -- 2914
					} -- 2914
				end -- 2912
			end -- 2911
		end -- 2911
	end -- 2911
	return { -- 2908
		success = false, -- 2908
		message = "invalid IDE action" -- 2908
	} -- 2908
end) -- 2908
local _anon_func_12 = function() -- 2930
	local _val_0 = App.platform -- 2930
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2930
end -- 2930
local getServerStatus -- 2916
getServerStatus = function() -- 2916
	local Entry = require("Script.Dev.Entry") -- 2917
	local running = Entry.getCurrentEntryStatus() -- 2918
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2919
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2920
	return { -- 2922
		success = true, -- 2922
		platform = App.platform, -- 2923
		locale = App.locale, -- 2924
		version = App.version, -- 2925
		url = "http://localhost:8866", -- 2926
		wsConnectionCount = wsConnectionCount, -- 2927
		webIDEConnected = wsConnectionCount > 0, -- 2928
		nativeIDE = { -- 2930
			supported = _anon_func_12(), -- 2930
			enabled = App.webIDEEnabled, -- 2931
			state = nativeIDEState, -- 2932
			message = nativeIDEMessage -- 2933
		}, -- 2929
		typescriptCompiler = { -- 2935
			webIDEReady = webIDECompilerReady, -- 2935
			webIDEGeneration = webIDEConnectionGeneration, -- 2936
			embeddedSupported = supportsCompilerWebView(), -- 2937
			embeddedRequested = compilerRequested, -- 2938
			embeddedReady = compilerReady, -- 2939
			users = compilerUsers, -- 2940
			queuedJobs = #compilerJobs, -- 2941
			failure = compilerFailure -- 2942
		}, -- 2934
		assetPath = Content.assetPath, -- 2943
		writablePath = Content.writablePath, -- 2944
		appPath = Content.appPath, -- 2945
		waTemplateReady = waTemplateReady, -- 2946
		running = running -- 2947
	} -- 2921
end -- 2916
HttpServer:post("/status", function() -- 2950
	return getServerStatus() -- 2951
end) -- 2950
HttpServer:postSchedule("/doctor/fix", function(req) -- 2953
	do -- 2954
		local _type_0 = type(req) -- 2954
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2954
		if _tab_0 then -- 2954
			local openWebIDE -- 2954
			do -- 2954
				local _obj_0 = req.body -- 2954
				local _type_1 = type(_obj_0) -- 2954
				if "table" == _type_1 or "userdata" == _type_1 then -- 2954
					openWebIDE = _obj_0.openWebIDE -- 2954
				end -- 2954
			end -- 2954
			if openWebIDE ~= nil then -- 2954
				if not openWebIDE then -- 2955
					return { -- 2956
						success = false, -- 2956
						message = "nothing to fix" -- 2956
					} -- 2956
				end -- 2955
				local status = getServerStatus() -- 2957
				if status.webIDEConnected then -- 2958
					return { -- 2959
						success = true, -- 2959
						fixed = false, -- 2959
						message = "Web IDE already connected.", -- 2959
						status = status -- 2959
					} -- 2959
				end -- 2958
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2960
				if waitSeconds > 0 then -- 2961
					local deadline = os.time() + waitSeconds -- 2962
					repeat -- 2963
						sleep(0.2) -- 2964
						status = getServerStatus() -- 2965
						if status.webIDEConnected then -- 2966
							return { -- 2967
								success = true, -- 2967
								fixed = false, -- 2967
								reconnected = true, -- 2967
								message = "Web IDE reconnected.", -- 2967
								status = status -- 2967
							} -- 2967
						end -- 2966
					until os.time() >= deadline -- 2963
				end -- 2961
				if not isDesktopPlatform() then -- 2969
					return { -- 2970
						success = false, -- 2970
						message = "opening Web IDE is only supported on desktop platforms", -- 2970
						status = status -- 2970
					} -- 2970
				end -- 2969
				local url = "http://localhost:8866" -- 2971
				App:openURL(url) -- 2972
				status.openedURL = url -- 2973
				return { -- 2974
					success = true, -- 2974
					fixed = true, -- 2974
					message = "Opened Web IDE in the local browser.", -- 2974
					url = url, -- 2974
					status = status -- 2974
				} -- 2974
			end -- 2954
		end -- 2954
	end -- 2954
	return { -- 2953
		success = false, -- 2953
		message = "invalid call" -- 2953
	} -- 2953
end) -- 2953
local status = { } -- 2976
_module_0 = status -- 2977
status.transpileTSFile = transpileTSFile -- 2979
status.buildAsync = function(path) -- 2981
	if not Content:exist(path) then -- 2982
		return { -- 2983
			success = false, -- 2983
			file = path, -- 2983
			message = "file not existed" -- 2983
		} -- 2983
	end -- 2982
	do -- 2984
		local _exp_0 = Path:getExt(path) -- 2984
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2984
			if '' == Path:getExt(Path:getName(path)) then -- 2985
				local content = Content:loadAsync(path) -- 2986
				if content then -- 2986
					local resultCodes, err = compileFileAsync(path, content) -- 2987
					if resultCodes then -- 2987
						return { -- 2988
							success = true, -- 2988
							file = path -- 2988
						} -- 2988
					else -- 2990
						return { -- 2990
							success = false, -- 2990
							file = path, -- 2990
							message = err -- 2990
						} -- 2990
					end -- 2987
				end -- 2986
			end -- 2985
		elseif "lua" == _exp_0 then -- 2991
			local content = Content:loadAsync(path) -- 2992
			if content then -- 2992
				do -- 2993
					local isTIC80 = CheckTIC80Code(content) -- 2993
					if isTIC80 then -- 2993
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2994
					end -- 2993
				end -- 2993
				local success, info -- 2995
				do -- 2995
					local _obj_0 = luaCheck(path, content) -- 2995
					success, info = _obj_0.success, _obj_0.info -- 2995
				end -- 2995
				if success then -- 2996
					return { -- 2997
						success = true, -- 2997
						file = path -- 2997
					} -- 2997
				elseif info and #info > 0 then -- 2998
					local messages = { } -- 2999
					for _index_0 = 1, #info do -- 3000
						local _des_0 = info[_index_0] -- 3000
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3000
						local lineText = "" -- 3001
						if line then -- 3002
							local currentLine = 1 -- 3003
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3004
								if currentLine == line then -- 3005
									lineText = text -- 3006
									break -- 3007
								end -- 3005
								currentLine = currentLine + 1 -- 3008
							end -- 3004
						end -- 3002
						if line then -- 3009
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3010
						else -- 3012
							messages[#messages + 1] = message -- 3012
						end -- 3009
					end -- 3000
					return { -- 3013
						success = false, -- 3013
						file = path, -- 3013
						message = table.concat(messages, "\n") -- 3013
					} -- 3013
				else -- 3015
					return { -- 3015
						success = false, -- 3015
						file = path, -- 3015
						message = "lua check failed" -- 3015
					} -- 3015
				end -- 2996
			end -- 2992
		elseif "yarn" == _exp_0 then -- 3016
			local content = Content:loadAsync(path) -- 3017
			if content then -- 3017
				local res, _, err = yarncompile(content, true) -- 3018
				if res then -- 3018
					return { -- 3019
						success = true, -- 3019
						file = path -- 3019
					} -- 3019
				else -- 3021
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3021
					local lineText = "" -- 3022
					if line then -- 3023
						local currentLine = 1 -- 3024
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3025
							if currentLine == line then -- 3026
								lineText = text -- 3027
								break -- 3028
							end -- 3026
							currentLine = currentLine + 1 -- 3029
						end -- 3025
					end -- 3023
					if node ~= "" then -- 3030
						node = "node: " .. tostring(node) .. ", " -- 3031
					else -- 3032
						node = "" -- 3032
					end -- 3030
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3033
					return { -- 3034
						success = false, -- 3034
						file = path, -- 3034
						message = message -- 3034
					} -- 3034
				end -- 3018
			end -- 3017
		end -- 2984
	end -- 2984
	return { -- 3035
		success = false, -- 3035
		file = path, -- 3035
		message = "invalid file to build" -- 3035
	} -- 3035
end -- 2981
HttpServer:postSchedule("/git/commit-files", function(req) -- 3037
	do -- 3038
		local _type_0 = type(req) -- 3038
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3038
		if _tab_0 then -- 3038
			local body = req.body -- 3038
			if body ~= nil then -- 3038
				local repoPath, commit = body.repoPath, body.commit -- 3039
				if gitInvalidRepoPath(repoPath) then -- 3040
					return { -- 3040
						success = false, -- 3040
						message = "invalid repoPath" -- 3040
					} -- 3040
				end -- 3040
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3041
					return { -- 3041
						success = false, -- 3041
						message = "invalid commit" -- 3041
					} -- 3041
				end -- 3041
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3042
				if not res.success then -- 3043
					return res -- 3043
				end -- 3043
				return { -- 3044
					success = true, -- 3044
					status = res.status, -- 3044
					data = res.status and res.status.data -- 3044
				} -- 3044
			end -- 3038
		end -- 3038
	end -- 3038
	return invalidArguments -- 3037
end) -- 3037
thread(function() -- 3046
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3047
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3048
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3049
		local storedAsset -- 3052
		storedAsset = function(file) -- 3052
			if Content:exist(file) then -- 3053
				return Content:load(file) -- 3054
			elseif Content:exist(file .. ".gz") then -- 3055
				return Content:load(file .. ".gz") -- 3056
			else -- 3057
				return "" -- 3057
			end -- 3053
		end -- 3052
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3058
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3059
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3060
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3061
		local readyContent = table.concat({ -- 3063
			App.version, -- 3063
			storedAsset(doraWeb), -- 3064
			storedAsset(heavyAssets), -- 3065
			storedAsset(runtimeIndex), -- 3066
			storedAsset(compilerIndex), -- 3067
			storedAsset(manifest) -- 3068
		}, "\n") -- 3062
		local needReload -- 3070
		if Content:exist(doraReady) then -- 3070
			needReload = readyContent ~= Content:load(doraReady) -- 3071
		else -- 3072
			needReload = true -- 3072
		end -- 3070
		if needReload then -- 3073
			Content:remove(Path(Content.appPath, ".www")) -- 3074
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3075
			Content:save(doraReady, readyContent) -- 3079
			print("Dora Dora is ready!") -- 3080
		end -- 3073
	end -- 3049
	if App.platform == "Emscripten" then -- 3081
		status.url = nil -- 3082
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3083
	end -- 3081
	HttpServer:clearStaticCacheControls() -- 3084
	HttpServer:setStaticCacheControl("no-cache") -- 3085
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3086
	if HttpServer:start(8866) then -- 3090
		local localIP = HttpServer.localIP -- 3091
		if localIP == "" then -- 3092
			localIP = "localhost" -- 3092
		end -- 3092
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3093
		return HttpServer:startWS(8868) -- 3094
	else -- 3096
		status.url = nil -- 3096
		return print("8866 Port not available!") -- 3097
	end -- 3090
end) -- 3046
return _module_0 -- 1
