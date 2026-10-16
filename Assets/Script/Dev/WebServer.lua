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
local isUnderPath -- 158
isUnderPath = function(path, root) -- 158
	if not (root and root ~= "") then -- 159
		return false -- 159
	end -- 159
	if path == root then -- 160
		return true -- 160
	end -- 160
	local prefix = root:sub(-1) == "/" and root or (root .. "/") -- 161
	return path:sub(1, #prefix) == prefix -- 162
end -- 158
local gitInvalidRepoPath -- 164
gitInvalidRepoPath = function(repoPath) -- 164
	if not repoPath or repoPath == "" or not Content:isAbsolutePath(repoPath) then -- 165
		return true -- 165
	end -- 165
	local normalized = repoPath:gsub("\\", "/") -- 166
	local _list_0 = { -- 167
		Content.writablePath, -- 167
		Content.assetPath -- 167
	} -- 167
	for _index_0 = 1, #_list_0 do -- 167
		local root = _list_0[_index_0] -- 167
		if not (root and root ~= "") then -- 168
			goto _continue_0 -- 168
		end -- 168
		if isUnderPath(normalized, root:gsub("\\", "/")) then -- 169
			do -- 169
				return false -- 169
			end -- 169
		end -- 169
		::_continue_0:: -- 168
	end -- 167
	return true -- 170
end -- 164
local gitShellSplit -- 172
gitShellSplit = function(command) -- 172
	local args = { } -- 173
	local current = { } -- 174
	local quote = nil -- 175
	local escape = false -- 176
	for i = 1, #command do -- 177
		local ch = command:sub(i, i) -- 178
		if escape then -- 179
			current[#current + 1] = ch -- 180
			escape = false -- 181
		elseif ch == "\\" then -- 182
			escape = true -- 183
		elseif quote then -- 184
			if ch == quote then -- 185
				quote = nil -- 186
			else -- 188
				current[#current + 1] = ch -- 188
			end -- 185
		elseif ch == "'" or ch == '"' then -- 189
			quote = ch -- 190
		elseif ch:match("%s") then -- 191
			if #current > 0 then -- 192
				args[#args + 1] = table.concat(current) -- 193
				current = { } -- 194
			end -- 192
		else -- 196
			current[#current + 1] = ch -- 196
		end -- 179
	end -- 177
	if #current > 0 then -- 197
		args[#args + 1] = table.concat(current) -- 198
	end -- 197
	if args[1] == "git" then -- 199
		table.remove(args, 1) -- 200
	end -- 199
	return args -- 201
end -- 172
local gitQuote -- 203
gitQuote = function(value) -- 203
	local text = tostring(value) -- 204
	if text:match("^[%w%._%-%/]+$") then -- 205
		return text -- 206
	end -- 205
	return "\"" .. text:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"" -- 207
end -- 203
local gitDirNonEmpty -- 209
gitDirNonEmpty = function(targetPath) -- 209
	if not Content:exist(targetPath) then -- 210
		return false -- 210
	end -- 210
	if not Content:isdir(targetPath) then -- 211
		return false -- 211
	end -- 211
	return #Content:getFiles(targetPath) > 0 or #Content:getDirs(targetPath) > 0 -- 212
end -- 209
local gitSafeChildPath -- 214
gitSafeChildPath = function(parentPath, childPath) -- 214
	if not (parentPath and childPath and childPath ~= "") then -- 215
		return nil -- 215
	end -- 215
	if childPath:sub(1, 1) == "/" or childPath:match("^%a:[/\\]") then -- 216
		return nil -- 216
	end -- 216
	if childPath == "." or childPath:match("^%.%.[/\\]?" or childPath:match("[/\\]%.%.[/\\]")) then -- 217
		return nil -- 217
	end -- 217
	local targetPath = Path(parentPath, childPath) -- 218
	local relative = Path:getRelative(targetPath, parentPath) -- 219
	if relative == ".." or relative:sub(1, 3) == "../" or relative:sub(1, 3) == "..\\" then -- 220
		return nil -- 220
	end -- 220
	return targetPath -- 221
end -- 214
local gitCloneDirFromURL -- 223
gitCloneDirFromURL = function(url) -- 223
	if not (url and url ~= "") then -- 224
		return nil -- 224
	end -- 224
	local text = tostring(url):match("^%s*(.-)%s*$") -- 225
	if text == "" then -- 226
		return nil -- 226
	end -- 226
	text = text:gsub("[/\\]+$", "") -- 227
	local name = text:match("([^/:]+)$") -- 228
	if not (name and name ~= "") then -- 229
		return nil -- 229
	end -- 229
	name = name:gsub("%.git$", "") -- 230
	if name == "" or name == "." or name == ".." then -- 231
		return nil -- 231
	end -- 231
	return name -- 232
end -- 223
local gitCloneTargetPath -- 234
gitCloneTargetPath = function(repoPath, command) -- 234
	local args = gitShellSplit(command) -- 235
	if not (args[1] == "clone") then -- 236
		return nil -- 236
	end -- 236
	local url = args[2] -- 237
	local index = 3 -- 238
	while index <= #args do -- 239
		local arg = args[index] -- 240
		if ("-b" == arg or "--branch" == arg or "--depth" == arg) then -- 241
			index = index + 2 -- 242
		elseif arg:sub(1, 1) == "-" then -- 243
			index = index + 1 -- 244
		else -- 246
			return gitSafeChildPath(repoPath, arg) -- 246
		end -- 241
	end -- 239
	do -- 247
		local dirName = gitCloneDirFromURL(url) -- 247
		if dirName then -- 247
			return gitSafeChildPath(repoPath, dirName) -- 248
		end -- 247
	end -- 247
	return nil -- 249
end -- 234
local gitPathInsideRepo -- 251
gitPathInsideRepo = function(repoPath, relPath) -- 251
	if not (repoPath and relPath and relPath ~= "") then -- 252
		return false -- 252
	end -- 252
	if relPath:sub(1, 1) == "/" or relPath:match("^%a:[/\\]") then -- 253
		return false -- 253
	end -- 253
	if relPath == "." or relPath:match("^%.%.[/\\]?" or relPath:match("[/\\]%.%.[/\\]")) then -- 254
		return false -- 254
	end -- 254
	local targetPath = Path(repoPath, relPath) -- 255
	local relative = Path:getRelative(targetPath, repoPath) -- 256
	return relative ~= ".." and relative:sub(1, 3) ~= "../" and relative:sub(1, 3) ~= "..\\" -- 257
end -- 251
local gitHostFromURL -- 259
gitHostFromURL = function(url) -- 259
	if not (url and url ~= "") then -- 260
		return nil -- 260
	end -- 260
	local text = tostring(url):match("^%s*(.-)%s*$") -- 261
	if text == "" then -- 262
		return nil -- 262
	end -- 262
	local host = text:match("^[%w_%-]+://([^/:]+)") -- 263
	if not host then -- 264
		host = text:match("@([^:/]+)[:/]") -- 264
	end -- 264
	if not host then -- 265
		host = text:match("^([^:/]+):[^/]") -- 265
	end -- 265
	if not (host and host ~= "") then -- 266
		return nil -- 266
	end -- 266
	return string.lower(host) -- 267
end -- 259
local ensureGitTables -- 269
ensureGitTables = function() -- 269
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
	]]) -- 270
	DB:exec("CREATE INDEX IF NOT EXISTS idx_git_credential_host ON GitCredential(host);") -- 283
	return DB:exec([[		CREATE TABLE IF NOT EXISTS GitProfile(
			id INTEGER PRIMARY KEY CHECK(id = 1),
			name TEXT NOT NULL DEFAULT '',
			email TEXT NOT NULL DEFAULT '',
			updated_at INTEGER
		);
	]]) -- 284
end -- 269
local gitCredentialToPublic -- 293
gitCredentialToPublic = function(row) -- 293
	local id, host, label, typeName, username, createdAt, updatedAt, lastUsedAt = row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8] -- 294
	return { -- 295
		id = id, -- 295
		host = host, -- 295
		label = label, -- 295
		type = typeName, -- 295
		username = username, -- 295
		createdAt = createdAt, -- 295
		updatedAt = updatedAt, -- 295
		lastUsedAt = lastUsedAt -- 295
	} -- 295
end -- 293
local gitLoadCredential -- 297
gitLoadCredential = function(id) -- 297
	ensureGitTables() -- 298
	local credentialId = tonumber(id) or 0 -- 299
	local rows = DB:query("select id, host, label, type, username, secret from GitCredential where id = ? limit 1", { -- 300
		credentialId -- 300
	}) -- 300
	if not (rows and rows[1]) then -- 301
		return nil -- 301
	end -- 301
	local row = rows[1] -- 302
	return { -- 303
		id = row[1], -- 303
		host = row[2], -- 303
		label = row[3], -- 303
		type = row[4], -- 303
		username = row[5], -- 303
		secret = row[6] -- 303
	} -- 303
end -- 297
local gitAuthOptionsJSON -- 305
gitAuthOptionsJSON = function(credential) -- 305
	if not credential then -- 306
		return nil -- 306
	end -- 306
	local auth -- 307
	if credential.type == "token" then -- 307
		auth = { -- 309
			type = "token", -- 309
			token = credential.secret, -- 310
			username = credential.username ~= "" and credential.username or "token" -- 311
		} -- 308
	else -- 314
		auth = { -- 315
			type = "basic", -- 315
			username = credential.username, -- 316
			password = credential.secret -- 317
		} -- 314
	end -- 307
	return json.encode({ -- 319
		auth = auth -- 319
	}) -- 319
end -- 305
local gitLoadProfile -- 321
gitLoadProfile = function() -- 321
	ensureGitTables() -- 322
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 323
	if not (rows and rows[1]) then -- 324
		return nil -- 324
	end -- 324
	local name = tostring(rows[1][1] or "") -- 325
	local email = tostring(rows[1][2] or "") -- 326
	if name == "" and email == "" then -- 327
		return nil -- 327
	end -- 327
	return { -- 328
		name = name, -- 328
		email = email -- 328
	} -- 328
end -- 321
local _anon_func_2 = function(args, gitQuote) -- 347
	local _accum_0 = { } -- 347
	local _len_0 = 1 -- 347
	for _index_0 = 1, #args do -- 347
		local arg = args[_index_0] -- 347
		_accum_0[_len_0] = gitQuote(arg) -- 347
		_len_0 = _len_0 + 1 -- 347
	end -- 347
	return _accum_0 -- 347
end -- 347
local gitApplyProfileToCommit -- 330
gitApplyProfileToCommit = function(command) -- 330
	local args = gitShellSplit(command) -- 331
	if not (args[1] == "commit") then -- 332
		return command -- 332
	end -- 332
	local hasName = false -- 333
	local hasEmail = false -- 334
	for _index_0 = 1, #args do -- 335
		local arg = args[_index_0] -- 335
		if arg == "--author-name" then -- 336
			hasName = true -- 336
		end -- 336
		if arg == "--author-email" then -- 337
			hasEmail = true -- 337
		end -- 337
	end -- 335
	if hasName and hasEmail then -- 338
		return command -- 338
	end -- 338
	local profile = gitLoadProfile() -- 339
	if not profile then -- 340
		return command -- 340
	end -- 340
	if not hasName and profile.name ~= "" then -- 341
		args[#args + 1] = "--author-name" -- 342
		args[#args + 1] = profile.name -- 343
	end -- 341
	if not hasEmail and profile.email ~= "" then -- 344
		args[#args + 1] = "--author-email" -- 345
		args[#args + 1] = profile.email -- 346
	end -- 344
	return table.concat(_anon_func_2(args, gitQuote), " ") -- 347
end -- 330
local gitStartJob -- 349
gitStartJob = function(repoPath, command, optionsJSON) -- 349
	if optionsJSON == nil then -- 349
		optionsJSON = nil -- 349
	end -- 349
	if gitInvalidRepoPath(repoPath) then -- 350
		return nil, "invalid repoPath" -- 350
	end -- 350
	if not (command and command ~= "") then -- 351
		return nil, "invalid command" -- 351
	end -- 351
	if not optionsJSON then -- 352
		optionsJSON = "" -- 352
	end -- 352
	command = gitApplyProfileToCommit(command) -- 353
	do -- 354
		local targetPath = gitCloneTargetPath(repoPath, command) -- 354
		if targetPath then -- 354
			if gitDirNonEmpty(targetPath) then -- 355
				return nil, "clone target directory is not empty" -- 356
			end -- 355
		elseif (gitShellSplit(command))[1] == "clone" then -- 357
			return nil, "invalid clone target" -- 358
		end -- 354
	end -- 354
	local statusRef = nil -- 359
	local startGit -- 360
	startGit = function() -- 360
		return Git:run(repoPath, command, (function(status) -- 361
			statusRef = status -- 362
			GitJobs[status.id] = { -- 364
				command = command, -- 364
				status = status, -- 365
				updatedAt = os.time() -- 366
			} -- 363
		end), optionsJSON) -- 361
	end -- 360
	local success, jobId = pcall(startGit) -- 368
	if not success then -- 369
		return nil, tostring(jobId) -- 369
	end -- 369
	if not jobId then -- 370
		return nil, "Git.run did not return a job id" -- 370
	end -- 370
	GitJobs[jobId] = { -- 372
		command = command, -- 372
		status = statusRef or { -- 374
			id = jobId, -- 374
			state = "queued", -- 375
			kind = gitShellSplit(command)[1] or "status", -- 376
			repoPath = repoPath, -- 377
			progress = 0, -- 378
			message = "queued" -- 379
		}, -- 373
		updatedAt = os.time() -- 381
	} -- 371
	return jobId -- 382
end -- 349
local gitRunSync -- 384
gitRunSync = function(repoPath, command, optionsJSON, timeout) -- 384
	if optionsJSON == nil then -- 384
		optionsJSON = nil -- 384
	end -- 384
	if timeout == nil then -- 384
		timeout = 20 -- 384
	end -- 384
	local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 385
	if not jobId then -- 386
		return { -- 386
			success = false, -- 386
			message = err -- 386
		} -- 386
	end -- 386
	local startedAt = os.time() -- 387
	wait(function() -- 388
		local job = GitJobs[jobId] -- 389
		local status = job and job.status -- 390
		return gitTerminalState(status) or os.time() - startedAt >= timeout -- 391
	end) -- 388
	local status = GitJobs[jobId] and GitJobs[jobId].status -- 392
	if not gitTerminalState(status) then -- 393
		Git:cancel(jobId) -- 394
		return { -- 395
			success = false, -- 395
			message = "git command timed out", -- 395
			jobId = jobId, -- 395
			status = status -- 395
		} -- 395
	end -- 393
	return { -- 396
		success = status.state == "done", -- 396
		jobId = jobId, -- 396
		status = status, -- 396
		message = status.error or status.message -- 396
	} -- 396
end -- 384
local gitCredentialsForHost -- 398
gitCredentialsForHost = function(host) -- 398
	if not (host and host ~= "") then -- 399
		return { } -- 399
	end -- 399
	ensureGitTables() -- 400
	local rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by last_used_at desc, label asc, id asc", { -- 401
		host -- 401
	}) -- 401
	if rows then -- 402
		local _accum_0 = { } -- 403
		local _len_0 = 1 -- 403
		for _index_0 = 1, #rows do -- 403
			local row = rows[_index_0] -- 403
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 403
			_len_0 = _len_0 + 1 -- 403
		end -- 403
		return _accum_0 -- 403
	else -- 404
		return { } -- 404
	end -- 402
end -- 398
local gitFirstRemoteURL -- 406
gitFirstRemoteURL = function(repoPath, remoteName) -- 406
	if remoteName == nil then -- 406
		remoteName = nil -- 406
	end -- 406
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 10) -- 407
	local data = remoteRes.status and remoteRes.status.data -- 408
	if not (data and data.remotes) then -- 409
		return nil -- 409
	end -- 409
	local _list_0 = data.remotes -- 410
	for _index_0 = 1, #_list_0 do -- 410
		local remote = _list_0[_index_0] -- 410
		if (not remoteName or remote.name == remoteName) and remote.urls and remote.urls[1] then -- 411
			return remote.urls[1] -- 412
		end -- 411
	end -- 410
	return nil -- 413
end -- 406
local gitConfigRemoteURL -- 415
gitConfigRemoteURL = function(repoPath, remoteName) -- 415
	if remoteName == nil then -- 415
		remoteName = nil -- 415
	end -- 415
	if gitInvalidRepoPath(repoPath) then -- 416
		return nil -- 416
	end -- 416
	local configPath = Path(repoPath, ".git/config") -- 417
	if not Content:exist(configPath) then -- 418
		return nil -- 418
	end -- 418
	local content = Content:load(configPath) -- 419
	if not (content and content ~= "") then -- 420
		return nil -- 420
	end -- 420
	local currentRemote = nil -- 421
	for line in content:gmatch("[^\r\n]+") do -- 422
		local sectionRemote = line:match('^%s*%[remote%s+"([^"]+)"%]%s*$') -- 423
		if sectionRemote then -- 424
			currentRemote = sectionRemote -- 425
		elseif currentRemote and (not remoteName or currentRemote == remoteName) then -- 426
			local url = line:match("^%s*url%s*=%s*(.-)%s*$") -- 427
			if url and url ~= "" then -- 428
				return url -- 428
			end -- 428
		end -- 424
	end -- 422
	return nil -- 429
end -- 415
local gitCommandRemoteArg -- 431
gitCommandRemoteArg = function(args, startIndex) -- 431
	if startIndex == nil then -- 431
		startIndex = 2 -- 431
	end -- 431
	local index = startIndex -- 432
	while index <= #args do -- 433
		local arg = args[index] -- 434
		if ("-u" == arg or "--set-upstream" == arg or "-f" == arg or "--force" == arg or "--all" == arg or "--prune" == arg) then -- 435
			index = index + 1 -- 436
		elseif ("--depth" == arg or "-b" == arg or "--branch" == arg) then -- 437
			index = index + 2 -- 438
		elseif arg and arg:sub(1, 1) == "-" then -- 439
			index = index + 1 -- 440
		else -- 442
			return arg -- 442
		end -- 435
	end -- 433
	return nil -- 443
end -- 431
local gitCommandHost -- 445
gitCommandHost = function(repoPath, command) -- 445
	local args = gitShellSplit(command) -- 446
	if not args[1] then -- 447
		return nil -- 447
	end -- 447
	do -- 448
		local _exp_0 = args[1] -- 448
		if "clone" == _exp_0 or "ls-remote" == _exp_0 then -- 449
			return gitHostFromURL(args[2]) -- 450
		elseif "fetch" == _exp_0 or "pull" == _exp_0 or "push" == _exp_0 then -- 451
			local remoteArg = gitCommandRemoteArg(args, 2) -- 452
			if not remoteArg then -- 453
				return nil -- 453
			end -- 453
			local url = gitHostFromURL(remoteArg) -- 454
			if url then -- 455
				return url -- 455
			end -- 455
			return gitHostFromURL(gitConfigRemoteURL(repoPath, remoteArg)) -- 456
		end -- 448
	end -- 448
	return nil -- 457
end -- 445
local gitAuthSelectionForCommand -- 459
gitAuthSelectionForCommand = function(repoPath, command) -- 459
	local host = gitCommandHost(repoPath, command) -- 460
	if not host then -- 461
		return nil -- 461
	end -- 461
	local items = gitCredentialsForHost(host) -- 462
	if #items == 0 then -- 463
		return nil -- 463
	end -- 463
	return { -- 464
		host = host, -- 464
		items = items -- 464
	} -- 464
end -- 459
local gitDefaultRemote -- 466
gitDefaultRemote = function(remoteStatus) -- 466
	local data = remoteStatus and remoteStatus.data -- 467
	if not (data and data.remotes and data.remotes[1]) then -- 468
		return nil -- 468
	end -- 468
	return data.remotes[1] -- 469
end -- 466
local gitCurrentBranch -- 471
gitCurrentBranch = function(branchStatus) -- 471
	local data = branchStatus and branchStatus.data -- 472
	if data and data.current and data.current ~= "" then -- 473
		return data.current -- 474
	end -- 473
	if data and data.branches then -- 475
		local _list_0 = data.branches -- 476
		for _index_0 = 1, #_list_0 do -- 476
			local branch = _list_0[_index_0] -- 476
			if branch.current then -- 477
				return branch.name -- 477
			end -- 477
		end -- 476
	end -- 475
	return nil -- 478
end -- 471
local gitHeadBranch -- 480
gitHeadBranch = function(repoPath) -- 480
	if gitInvalidRepoPath(repoPath) then -- 481
		return nil -- 481
	end -- 481
	local headPath = Path(repoPath, ".git", "HEAD") -- 482
	if not Content:exist(headPath) then -- 483
		return nil -- 483
	end -- 483
	local head = Content:load(headPath) -- 484
	if not head then -- 485
		return nil -- 485
	end -- 485
	local branch = head:match("^ref:%s*refs/heads/(.-)%s*$") -- 486
	if branch and branch ~= "" then -- 487
		return branch -- 487
	end -- 487
	return nil -- 488
end -- 480
local gitBranchesWithHead -- 490
gitBranchesWithHead = function(branchStatus, currentBranch) -- 490
	local branches = branchStatus and branchStatus.data and branchStatus.data.branches or { } -- 491
	if not (currentBranch and currentBranch ~= "") then -- 492
		return branches -- 492
	end -- 492
	for _index_0 = 1, #branches do -- 493
		local branch = branches[_index_0] -- 493
		if branch.name == currentBranch then -- 494
			return branches -- 494
		end -- 494
	end -- 493
	local withHead -- 495
	do -- 495
		local _accum_0 = { } -- 495
		local _len_0 = 1 -- 495
		for _index_0 = 1, #branches do -- 495
			local branch = branches[_index_0] -- 495
			_accum_0[_len_0] = branch -- 495
			_len_0 = _len_0 + 1 -- 495
		end -- 495
		withHead = _accum_0 -- 495
	end -- 495
	withHead[#withHead + 1] = { -- 496
		name = currentBranch, -- 496
		current = true, -- 496
		unborn = true -- 496
	} -- 496
	return withHead -- 497
end -- 490
local gitStatusMeansNotRepo -- 499
gitStatusMeansNotRepo = function(statusRes) -- 499
	local message = statusRes and (statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message)) or "" -- 500
	message = tostring(message):lower() -- 501
	return message:find("repository does not exist", 1, true) or message:find("not a git repository", 1, true) -- 502
end -- 499
local gitSummary -- 504
gitSummary = function(repoPath) -- 504
	local statusRes = gitRunSync(repoPath, "status", nil, 120) -- 505
	if not statusRes.success then -- 506
		if gitStatusMeansNotRepo(statusRes) then -- 507
			return { -- 508
				success = true, -- 508
				isRepo = false, -- 508
				message = statusRes.message, -- 508
				status = statusRes.status -- 508
			} -- 508
		end -- 507
		return { -- 509
			success = false, -- 509
			message = statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message) or "failed to check Git repository", -- 509
			status = statusRes.status -- 509
		} -- 509
	end -- 506
	local branchRes = gitRunSync(repoPath, "branch", nil, 120) -- 510
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 120) -- 511
	local status = statusRes.status -- 512
	local branchStatus = branchRes.status -- 513
	local remoteStatus = remoteRes.status -- 514
	local currentBranch = gitCurrentBranch(branchStatus) or gitHeadBranch(repoPath) -- 515
	local branches = gitBranchesWithHead(branchStatus, currentBranch) -- 516
	local logRes = gitRunSync(repoPath, "log --metadata-only -n 100", nil, 120) -- 517
	local logStatus -- 518
	if logRes.success then -- 518
		logStatus = logRes.status -- 519
	else -- 521
		logStatus = { -- 522
			state = "done", -- 522
			kind = "log", -- 523
			repoPath = repoPath, -- 524
			progress = 1, -- 525
			message = "git log completed", -- 526
			data = { -- 527
				commits = { } -- 527
			} -- 527
		} -- 521
	end -- 518
	local hasCommit = logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] ~= nil -- 529
	local tagStatus -- 530
	if hasCommit then -- 530
		tagStatus = (gitRunSync(repoPath, "tag", nil, 120)).status -- 531
	else -- 533
		tagStatus = { -- 534
			state = "done", -- 534
			kind = "tag", -- 535
			repoPath = repoPath, -- 536
			progress = 1, -- 537
			message = "git tag completed", -- 538
			data = { -- 539
				tags = { } -- 539
			} -- 539
		} -- 533
	end -- 530
	local defaultRemote = gitDefaultRemote(remoteStatus) -- 541
	local lastCommit = nil -- 542
	if logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] then -- 543
		lastCommit = logStatus.data.commits[1] -- 544
	end -- 543
	return { -- 546
		success = true, -- 546
		isRepo = true, -- 547
		clean = status.data and status.data.clean or false, -- 548
		currentBranch = currentBranch, -- 549
		defaultRemote = defaultRemote, -- 550
		remotes = remoteStatus and remoteStatus.data and remoteStatus.data.remotes or { }, -- 551
		branches = branches, -- 552
		lastCommit = lastCommit, -- 553
		status = status, -- 554
		branchStatus = branchStatus, -- 555
		remoteStatus = remoteStatus, -- 556
		historyStatus = logStatus, -- 557
		tagStatus = tagStatus -- 558
	} -- 545
end -- 504
HttpServer:post("/git/run", function(req) -- 560
	do -- 561
		local _type_0 = type(req) -- 561
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 561
		if _tab_0 then -- 561
			local body = req.body -- 561
			if body ~= nil then -- 561
				local repoPath, command, authId, optionsJSON = body.repoPath, body.command, body.authId, body.optionsJSON -- 562
				if authId and not optionsJSON then -- 563
					local credential = gitLoadCredential(authId) -- 564
					if credential then -- 564
						optionsJSON = gitAuthOptionsJSON(credential) -- 565
						DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 566
							os.time(), -- 566
							credential.id -- 566
						}) -- 566
					end -- 564
				elseif not optionsJSON then -- 567
					local authOk, authSelection = pcall(gitAuthSelectionForCommand, repoPath, command) -- 568
					if not authOk then -- 569
						authSelection = nil -- 569
					end -- 569
					if authSelection then -- 570
						if #authSelection.items == 1 then -- 571
							local credential = gitLoadCredential(authSelection.items[1].id) -- 572
							optionsJSON = gitAuthOptionsJSON(credential) -- 573
							DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 574
								os.time(), -- 574
								credential.id -- 574
							}) -- 574
						else -- 576
							return { -- 576
								success = false, -- 576
								message = "select a Git credential", -- 576
								needsCredentialSelection = true, -- 576
								host = authSelection.host, -- 576
								credentials = authSelection.items -- 576
							} -- 576
						end -- 571
					end -- 570
				end -- 563
				local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 577
				if not jobId then -- 578
					return { -- 578
						success = false, -- 578
						message = err -- 578
					} -- 578
				end -- 578
				return { -- 579
					success = true, -- 579
					jobId = jobId -- 579
				} -- 579
			end -- 561
		end -- 561
	end -- 561
	return invalidArguments -- 560
end) -- 560
HttpServer:post("/git/status", function(req) -- 581
	do -- 582
		local _type_0 = type(req) -- 582
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 582
		if _tab_0 then -- 582
			local jobId -- 582
			do -- 582
				local _obj_0 = req.body -- 582
				local _type_1 = type(_obj_0) -- 582
				if "table" == _type_1 or "userdata" == _type_1 then -- 582
					jobId = _obj_0.jobId -- 582
				end -- 582
			end -- 582
			if jobId ~= nil then -- 582
				local job = GitJobs[tonumber(jobId) or 0] -- 583
				if not job then -- 584
					return { -- 584
						success = false, -- 584
						message = "git job not found" -- 584
					} -- 584
				end -- 584
				return { -- 585
					success = true, -- 585
					status = job.status, -- 585
					command = job.command -- 585
				} -- 585
			end -- 582
		end -- 582
	end -- 582
	return invalidArguments -- 581
end) -- 581
HttpServer:post("/git/cancel", function(req) -- 587
	do -- 588
		local _type_0 = type(req) -- 588
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 588
		if _tab_0 then -- 588
			local jobId -- 588
			do -- 588
				local _obj_0 = req.body -- 588
				local _type_1 = type(_obj_0) -- 588
				if "table" == _type_1 or "userdata" == _type_1 then -- 588
					jobId = _obj_0.jobId -- 588
				end -- 588
			end -- 588
			if jobId ~= nil then -- 588
				local id = tonumber(jobId) -- 589
				if not id then -- 590
					return { -- 590
						success = false, -- 590
						message = "invalid jobId" -- 590
					} -- 590
				end -- 590
				return { -- 591
					success = Git:cancel(id) -- 591
				} -- 591
			end -- 588
		end -- 588
	end -- 588
	return invalidArguments -- 587
end) -- 587
HttpServer:postSchedule("/git/summary", function(req) -- 593
	do -- 594
		local _type_0 = type(req) -- 594
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 594
		if _tab_0 then -- 594
			local repoPath -- 594
			do -- 594
				local _obj_0 = req.body -- 594
				local _type_1 = type(_obj_0) -- 594
				if "table" == _type_1 or "userdata" == _type_1 then -- 594
					repoPath = _obj_0.repoPath -- 594
				end -- 594
			end -- 594
			if repoPath ~= nil then -- 594
				if gitInvalidRepoPath(repoPath) then -- 595
					return { -- 595
						success = false, -- 595
						message = "invalid repoPath" -- 595
					} -- 595
				end -- 595
				return gitSummary(repoPath) -- 596
			end -- 594
		end -- 594
	end -- 594
	return invalidArguments -- 593
end) -- 593
HttpServer:postSchedule("/git/status-files", function(req) -- 598
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
				return gitRunSync(repoPath, "status", nil, 120) -- 600
			end -- 599
		end -- 599
	end -- 599
	return invalidArguments -- 598
end) -- 598
HttpServer:postSchedule("/git/discard-untracked", function(req) -- 602
	do -- 603
		local _type_0 = type(req) -- 603
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 603
		if _tab_0 then -- 603
			local body = req.body -- 603
			if body ~= nil then -- 603
				local repoPath, paths = body.repoPath, body.paths -- 604
				if gitInvalidRepoPath(repoPath) then -- 605
					return { -- 605
						success = false, -- 605
						message = "invalid repoPath" -- 605
					} -- 605
				end -- 605
				if not (type(paths) == "table") then -- 606
					return { -- 606
						success = false, -- 606
						message = "invalid paths" -- 606
					} -- 606
				end -- 606
				local statusRes = gitRunSync(repoPath, "status", nil, 10) -- 607
				if not statusRes.success then -- 608
					return statusRes -- 608
				end -- 608
				local untracked = { } -- 609
				local _list_0 = (statusRes.status.data and statusRes.status.data.files or { }) -- 610
				for _index_0 = 1, #_list_0 do -- 610
					local file = _list_0[_index_0] -- 610
					if file.staging == "?" or file.worktree == "?" then -- 611
						untracked[file.path] = true -- 612
					end -- 611
				end -- 610
				local removed = { } -- 613
				for _index_0 = 1, #paths do -- 614
					local relPath = paths[_index_0] -- 614
					relPath = tostring(relPath) -- 615
					if not gitPathInsideRepo(repoPath, relPath) then -- 616
						return { -- 616
							success = false, -- 616
							message = "unsafe path: " .. tostring(relPath) -- 616
						} -- 616
					end -- 616
					if not untracked[relPath] then -- 617
						return { -- 617
							success = false, -- 617
							message = "path is not untracked: " .. tostring(relPath) -- 617
						} -- 617
					end -- 617
				end -- 614
				for _index_0 = 1, #paths do -- 618
					local relPath = paths[_index_0] -- 618
					local targetPath = Path(repoPath, tostring(relPath)) -- 619
					if Content:exist(targetPath) then -- 620
						Content:remove(targetPath) -- 621
						removed[#removed + 1] = tostring(relPath) -- 622
					end -- 620
				end -- 618
				return { -- 623
					success = true, -- 623
					removed = removed -- 623
				} -- 623
			end -- 603
		end -- 603
	end -- 603
	return invalidArguments -- 602
end) -- 602
HttpServer:postSchedule("/git/file-diff", function(req) -- 625
	do -- 626
		local _type_0 = type(req) -- 626
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 626
		if _tab_0 then -- 626
			local body = req.body -- 626
			if body ~= nil then -- 626
				local repoPath, path, staged = body.repoPath, body.path, body.staged -- 627
				if gitInvalidRepoPath(repoPath) then -- 628
					return { -- 628
						success = false, -- 628
						message = "invalid repoPath" -- 628
					} -- 628
				end -- 628
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 629
					return { -- 629
						success = false, -- 629
						message = "unsafe path" -- 629
					} -- 629
				end -- 629
				local command -- 630
				if staged == true then -- 630
					command = "diff --staged -- " .. tostring(gitQuote(path)) -- 631
				else -- 633
					command = "diff -- " .. tostring(gitQuote(path)) -- 633
				end -- 630
				local res = gitRunSync(repoPath, command, nil, 10) -- 634
				if not res.success then -- 635
					return res -- 635
				end -- 635
				return { -- 636
					success = true, -- 636
					status = res.status, -- 636
					data = res.status and res.status.data -- 636
				} -- 636
			end -- 626
		end -- 626
	end -- 626
	return invalidArguments -- 625
end) -- 625
HttpServer:postSchedule("/git/commit-file-diff", function(req) -- 638
	do -- 639
		local _type_0 = type(req) -- 639
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 639
		if _tab_0 then -- 639
			local body = req.body -- 639
			if body ~= nil then -- 639
				local repoPath, commit, path = body.repoPath, body.commit, body.path -- 640
				if gitInvalidRepoPath(repoPath) then -- 641
					return { -- 641
						success = false, -- 641
						message = "invalid repoPath" -- 641
					} -- 641
				end -- 641
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 642
					return { -- 642
						success = false, -- 642
						message = "invalid commit" -- 642
					} -- 642
				end -- 642
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 643
					return { -- 643
						success = false, -- 643
						message = "unsafe path" -- 643
					} -- 643
				end -- 643
				local res = gitRunSync(repoPath, "diff " .. tostring(gitQuote(commit)) .. " -- " .. tostring(gitQuote(path)), nil, 10) -- 644
				if not res.success then -- 645
					return res -- 645
				end -- 645
				return { -- 646
					success = true, -- 646
					status = res.status, -- 646
					data = res.status and res.status.data -- 646
				} -- 646
			end -- 639
		end -- 639
	end -- 639
	return invalidArguments -- 638
end) -- 638
HttpServer:postSchedule("/git/history", function(req) -- 648
	do -- 649
		local _type_0 = type(req) -- 649
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 649
		if _tab_0 then -- 649
			local body = req.body -- 649
			if body ~= nil then -- 649
				local repoPath, limit = body.repoPath, body.limit -- 650
				limit = math.max(1, math.min(100, tonumber(limit) or 20)) -- 651
				return gitRunSync(repoPath, "log --metadata-only -n " .. tostring(limit), nil, 10) -- 652
			end -- 649
		end -- 649
	end -- 649
	return invalidArguments -- 648
end) -- 648
HttpServer:postSchedule("/git/remotes", function(req) -- 654
	do -- 655
		local _type_0 = type(req) -- 655
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 655
		if _tab_0 then -- 655
			local body = req.body -- 655
			if body ~= nil then -- 655
				local repoPath, command = body.repoPath, body.command -- 656
				command = command or "remote -v" -- 657
				return gitRunSync(repoPath, command, nil, 10) -- 658
			end -- 655
		end -- 655
	end -- 655
	return invalidArguments -- 654
end) -- 654
HttpServer:postSchedule("/git/branches", function(req) -- 660
	do -- 661
		local _type_0 = type(req) -- 661
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 661
		if _tab_0 then -- 661
			local body = req.body -- 661
			if body ~= nil then -- 661
				local repoPath, command = body.repoPath, body.command -- 662
				command = command or "branch" -- 663
				return gitRunSync(repoPath, command, nil, 10) -- 664
			end -- 661
		end -- 661
	end -- 661
	return invalidArguments -- 660
end) -- 660
HttpServer:postSchedule("/git/tags", function(req) -- 666
	do -- 667
		local _type_0 = type(req) -- 667
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 667
		if _tab_0 then -- 667
			local body = req.body -- 667
			if body ~= nil then -- 667
				local repoPath, command = body.repoPath, body.command -- 668
				command = command or "tag" -- 669
				return gitRunSync(repoPath, command, nil, 10) -- 670
			end -- 667
		end -- 667
	end -- 667
	return invalidArguments -- 666
end) -- 666
HttpServer:post("/git/profile/get", function() -- 672
	ensureGitTables() -- 673
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 674
	local profile -- 675
	if rows and rows[1] then -- 675
		profile = { -- 676
			name = rows[1][1], -- 676
			email = rows[1][2] -- 676
		} -- 676
	else -- 678
		profile = { -- 678
			name = "", -- 678
			email = "" -- 678
		} -- 678
	end -- 675
	return { -- 679
		success = true, -- 679
		profile = profile -- 679
	} -- 679
end) -- 672
HttpServer:post("/git/profile/save", function(req) -- 681
	do -- 682
		local _type_0 = type(req) -- 682
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 682
		if _tab_0 then -- 682
			local name -- 682
			do -- 682
				local _obj_0 = req.body -- 682
				local _type_1 = type(_obj_0) -- 682
				if "table" == _type_1 or "userdata" == _type_1 then -- 682
					name = _obj_0.name -- 682
				end -- 682
			end -- 682
			local email -- 682
			do -- 682
				local _obj_0 = req.body -- 682
				local _type_1 = type(_obj_0) -- 682
				if "table" == _type_1 or "userdata" == _type_1 then -- 682
					email = _obj_0.email -- 682
				end -- 682
			end -- 682
			if name ~= nil and email ~= nil then -- 682
				ensureGitTables() -- 683
				DB:exec("insert into GitProfile(id, name, email, updated_at) values(1, ?, ?, ?) on conflict(id) do update set name = excluded.name, email = excluded.email, updated_at = excluded.updated_at", { -- 685
					tostring(name or ""), -- 685
					tostring(email or ""), -- 686
					os.time() -- 687
				}) -- 684
				return { -- 689
					success = true -- 689
				} -- 689
			end -- 682
		end -- 682
	end -- 682
	return invalidArguments -- 681
end) -- 681
HttpServer:post("/git/auth/list", function(req) -- 691
	ensureGitTables() -- 692
	local host = nil -- 693
	do -- 694
		local _type_0 = type(req) -- 694
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 694
		if _tab_0 then -- 694
			local body = req.body -- 694
			if body ~= nil then -- 694
				host = body.host -- 695
			end -- 694
		end -- 694
	end -- 694
	local rows -- 696
	if host and host ~= "" then -- 696
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by host asc, label asc, id asc", { -- 697
			tostring(host):lower() -- 697
		}) -- 697
	else -- 699
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential order by host asc, label asc, id asc") -- 699
	end -- 696
	local items -- 700
	if rows then -- 700
		local _accum_0 = { } -- 700
		local _len_0 = 1 -- 700
		for _index_0 = 1, #rows do -- 700
			local row = rows[_index_0] -- 700
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 700
			_len_0 = _len_0 + 1 -- 700
		end -- 700
		items = _accum_0 -- 700
	else -- 700
		items = { } -- 700
	end -- 700
	return { -- 701
		success = true, -- 701
		items = items -- 701
	} -- 701
end) -- 691
HttpServer:postSchedule("/git/auth/match", function(req) -- 703
	do -- 704
		local _type_0 = type(req) -- 704
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 704
		if _tab_0 then -- 704
			local body = req.body -- 704
			if body ~= nil then -- 704
				local repoPath, command, url = body.repoPath, body.command, body.url -- 705
				local host -- 706
				if url and url ~= "" then -- 706
					host = gitHostFromURL(url) -- 706
				else -- 706
					host = gitCommandHost(repoPath, command) -- 706
				end -- 706
				if not host then -- 707
					return { -- 707
						success = false, -- 707
						message = "git host is required" -- 707
					} -- 707
				end -- 707
				local items = gitCredentialsForHost(host) -- 708
				return { -- 709
					success = true, -- 709
					host = host, -- 709
					items = items, -- 709
					needsSelection = #items > 1, -- 709
					authId = (#items == 1 and items[1].id or nil) -- 709
				} -- 709
			end -- 704
		end -- 704
	end -- 704
	return invalidArguments -- 703
end) -- 703
HttpServer:post("/git/auth/save", function(req) -- 711
	do -- 712
		local _type_0 = type(req) -- 712
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 712
		if _tab_0 then -- 712
			local body = req.body -- 712
			if body ~= nil then -- 712
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token -- 713
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$") -- 714
				label = tostring(label or ""):match("^%s*(.-)%s*$") -- 715
				local credentialType = tostring(body.type or "token") -- 716
				username = tostring(username or "") -- 717
				local secret -- 718
				if credentialType == "basic" then -- 718
					secret = tostring(password or "") -- 718
				else -- 718
					secret = tostring(token or password or "") -- 718
				end -- 718
				if host == "" then -- 719
					return { -- 719
						success = false, -- 719
						message = "host is required" -- 719
					} -- 719
				end -- 719
				if label == "" then -- 720
					return { -- 720
						success = false, -- 720
						message = "label is required" -- 720
					} -- 720
				end -- 720
				if secret == "" then -- 721
					return { -- 721
						success = false, -- 721
						message = "secret is required" -- 721
					} -- 721
				end -- 721
				if not (("basic" == credentialType or "token" == credentialType)) then -- 722
					return { -- 722
						success = false, -- 722
						message = "invalid type" -- 722
					} -- 722
				end -- 722
				ensureGitTables() -- 723
				local now = os.time() -- 724
				if id then -- 725
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", { -- 727
						host, -- 727
						label, -- 727
						credentialType, -- 727
						username, -- 727
						secret, -- 727
						now, -- 727
						(tonumber(id) or 0) -- 727
					}) -- 726
					return { -- 729
						success = true, -- 729
						id = tonumber(id) -- 729
					} -- 729
				else -- 731
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", { -- 732
						host, -- 732
						label, -- 732
						credentialType, -- 732
						username, -- 732
						secret, -- 732
						now, -- 732
						now -- 732
					}) -- 731
					local rows = DB:query("select last_insert_rowid()") -- 734
					return { -- 735
						success = true, -- 735
						id = rows and rows[1] and rows[1][1] -- 735
					} -- 735
				end -- 725
			end -- 712
		end -- 712
	end -- 712
	return invalidArguments -- 711
end) -- 711
HttpServer:post("/git/auth/delete", function(req) -- 737
	do -- 738
		local _type_0 = type(req) -- 738
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 738
		if _tab_0 then -- 738
			local id -- 738
			do -- 738
				local _obj_0 = req.body -- 738
				local _type_1 = type(_obj_0) -- 738
				if "table" == _type_1 or "userdata" == _type_1 then -- 738
					id = _obj_0.id -- 738
				end -- 738
			end -- 738
			if id ~= nil then -- 738
				ensureGitTables() -- 739
				local credentialId = tonumber(id) or 0 -- 740
				DB:exec("delete from GitCredential where id = ?", { -- 741
					credentialId -- 741
				}) -- 741
				return { -- 742
					success = true -- 742
				} -- 742
			end -- 738
		end -- 738
	end -- 738
	return invalidArguments -- 737
end) -- 737
HttpServer:postSchedule("/git/auth/test", function(req) -- 744
	do -- 745
		local _type_0 = type(req) -- 745
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 745
		if _tab_0 then -- 745
			local body = req.body -- 745
			if body ~= nil then -- 745
				local repoPath, url, authId = body.repoPath, body.url, body.authId -- 746
				local credential = gitLoadCredential(authId) -- 747
				local optionsJSON = gitAuthOptionsJSON(credential) -- 748
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20) -- 749
			end -- 745
		end -- 745
	end -- 745
	return invalidArguments -- 744
end) -- 744
HttpServer:post("/agent/session/create", function(req) -- 751
	do -- 752
		local _type_0 = type(req) -- 752
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 752
		if _tab_0 then -- 752
			local projectRoot -- 752
			do -- 752
				local _obj_0 = req.body -- 752
				local _type_1 = type(_obj_0) -- 752
				if "table" == _type_1 or "userdata" == _type_1 then -- 752
					projectRoot = _obj_0.projectRoot -- 752
				end -- 752
			end -- 752
			local title -- 752
			do -- 752
				local _obj_0 = req.body -- 752
				local _type_1 = type(_obj_0) -- 752
				if "table" == _type_1 or "userdata" == _type_1 then -- 752
					title = _obj_0.title -- 752
				end -- 752
			end -- 752
			if projectRoot ~= nil and title ~= nil then -- 752
				return AgentSession.createSession(projectRoot, title) -- 753
			end -- 752
		end -- 752
	end -- 752
	return invalidArguments -- 751
end) -- 751
HttpServer:post("/agent/session/create-sub", function(req) -- 755
	do -- 756
		local _type_0 = type(req) -- 756
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 756
		if _tab_0 then -- 756
			local parentSessionId -- 756
			do -- 756
				local _obj_0 = req.body -- 756
				local _type_1 = type(_obj_0) -- 756
				if "table" == _type_1 or "userdata" == _type_1 then -- 756
					parentSessionId = _obj_0.parentSessionId -- 756
				end -- 756
			end -- 756
			local title -- 756
			do -- 756
				local _obj_0 = req.body -- 756
				local _type_1 = type(_obj_0) -- 756
				if "table" == _type_1 or "userdata" == _type_1 then -- 756
					title = _obj_0.title -- 756
				end -- 756
			end -- 756
			if parentSessionId ~= nil and title ~= nil then -- 756
				return AgentSession.createSubSession(parentSessionId, title) -- 757
			end -- 756
		end -- 756
	end -- 756
	return invalidArguments -- 755
end) -- 755
HttpServer:post("/agent/session/get", function(req) -- 759
	do -- 760
		local _type_0 = type(req) -- 760
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 760
		if _tab_0 then -- 760
			local sessionId -- 760
			do -- 760
				local _obj_0 = req.body -- 760
				local _type_1 = type(_obj_0) -- 760
				if "table" == _type_1 or "userdata" == _type_1 then -- 760
					sessionId = _obj_0.sessionId -- 760
				end -- 760
			end -- 760
			if sessionId ~= nil then -- 760
				return AgentSession.getSession(sessionId) -- 761
			end -- 760
		end -- 760
	end -- 760
	return invalidArguments -- 759
end) -- 759
HttpServer:post("/agent/vision/asset", function(req) -- 763
	do -- 764
		local _type_0 = type(req) -- 764
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 764
		if _tab_0 then -- 764
			local sessionId -- 764
			do -- 764
				local _obj_0 = req.body -- 764
				local _type_1 = type(_obj_0) -- 764
				if "table" == _type_1 or "userdata" == _type_1 then -- 764
					sessionId = _obj_0.sessionId -- 764
				end -- 764
			end -- 764
			local path -- 764
			do -- 764
				local _obj_0 = req.body -- 764
				local _type_1 = type(_obj_0) -- 764
				if "table" == _type_1 or "userdata" == _type_1 then -- 764
					path = _obj_0.path -- 764
				end -- 764
			end -- 764
			if sessionId ~= nil and path ~= nil then -- 764
				return AgentVisionAssets.getSessionVisionImageFromPath(sessionId, path) -- 765
			end -- 764
		end -- 764
	end -- 764
	return invalidArguments -- 763
end) -- 763
HttpServer:post("/agent/session/mode", function(req) -- 767
	do -- 768
		local _type_0 = type(req) -- 768
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 768
		if _tab_0 then -- 768
			local sessionId -- 768
			do -- 768
				local _obj_0 = req.body -- 768
				local _type_1 = type(_obj_0) -- 768
				if "table" == _type_1 or "userdata" == _type_1 then -- 768
					sessionId = _obj_0.sessionId -- 768
				end -- 768
			end -- 768
			local workMode -- 768
			do -- 768
				local _obj_0 = req.body -- 768
				local _type_1 = type(_obj_0) -- 768
				if "table" == _type_1 or "userdata" == _type_1 then -- 768
					workMode = _obj_0.workMode -- 768
				end -- 768
			end -- 768
			if sessionId ~= nil and workMode ~= nil then -- 768
				return AgentSession.setWorkMode(sessionId, workMode) -- 769
			end -- 768
		end -- 768
	end -- 768
	return invalidArguments -- 767
end) -- 767
HttpServer:post("/agent/session/send", function(req) -- 771
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
			local prompt -- 772
			do -- 772
				local _obj_0 = req.body -- 772
				local _type_1 = type(_obj_0) -- 772
				if "table" == _type_1 or "userdata" == _type_1 then -- 772
					prompt = _obj_0.prompt -- 772
				end -- 772
			end -- 772
			if sessionId ~= nil and prompt ~= nil then -- 772
				return AgentSession.sendPrompt(sessionId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 773
			end -- 772
		end -- 772
	end -- 772
	return invalidArguments -- 771
end) -- 771
HttpServer:post("/agent/session/send-local", function(req) -- 775
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
			local prompt -- 776
			do -- 776
				local _obj_0 = req.body -- 776
				local _type_1 = type(_obj_0) -- 776
				if "table" == _type_1 or "userdata" == _type_1 then -- 776
					prompt = _obj_0.prompt -- 776
				end -- 776
			end -- 776
			local localAgentConfigId -- 776
			do -- 776
				local _obj_0 = req.body -- 776
				local _type_1 = type(_obj_0) -- 776
				if "table" == _type_1 or "userdata" == _type_1 then -- 776
					localAgentConfigId = _obj_0.localAgentConfigId -- 776
				end -- 776
			end -- 776
			if sessionId ~= nil and prompt ~= nil and localAgentConfigId ~= nil then -- 776
				return AgentSession.sendLocalPrompt(sessionId, prompt, localAgentConfigId) -- 777
			end -- 776
		end -- 776
	end -- 776
	return invalidArguments -- 775
end) -- 775
HttpServer:post("/agent/session/local/new", function(req) -- 779
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
			if sessionId ~= nil then -- 780
				return AgentLocalAgent.abandonSession(sessionId) -- 781
			end -- 780
		end -- 780
	end -- 780
	return invalidArguments -- 779
end) -- 779
HttpServer:post("/agent/session/local/info", function(req) -- 783
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
				local info = AgentLocalAgent.getSessionInfo(sessionId) -- 785
				return { -- 786
					success = true, -- 786
					info = info -- 786
				} -- 786
			end -- 784
		end -- 784
	end -- 784
	return invalidArguments -- 783
end) -- 783
HttpServer:post("/agent/session/continue", function(req) -- 788
	do -- 789
		local _type_0 = type(req) -- 789
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 789
		if _tab_0 then -- 789
			local sessionId -- 789
			do -- 789
				local _obj_0 = req.body -- 789
				local _type_1 = type(_obj_0) -- 789
				if "table" == _type_1 or "userdata" == _type_1 then -- 789
					sessionId = _obj_0.sessionId -- 789
				end -- 789
			end -- 789
			if sessionId ~= nil then -- 789
				return AgentSession.continuePrompt(sessionId, req.body.disabledAgentTools, req.body.llmConfigId) -- 790
			end -- 789
		end -- 789
	end -- 789
	return invalidArguments -- 788
end) -- 788
HttpServer:post("/agent/session/finish-handoff", function(req) -- 792
	do -- 793
		local _type_0 = type(req) -- 793
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 793
		if _tab_0 then -- 793
			local sessionId -- 793
			do -- 793
				local _obj_0 = req.body -- 793
				local _type_1 = type(_obj_0) -- 793
				if "table" == _type_1 or "userdata" == _type_1 then -- 793
					sessionId = _obj_0.sessionId -- 793
				end -- 793
			end -- 793
			if sessionId ~= nil then -- 793
				return AgentSession.finishSubSessionHandoff(sessionId, req.body.llmConfigId) -- 794
			end -- 793
		end -- 793
	end -- 793
	return invalidArguments -- 792
end) -- 792
HttpServer:post("/agent/session/resend", function(req) -- 796
	do -- 797
		local _type_0 = type(req) -- 797
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 797
		if _tab_0 then -- 797
			local sessionId -- 797
			do -- 797
				local _obj_0 = req.body -- 797
				local _type_1 = type(_obj_0) -- 797
				if "table" == _type_1 or "userdata" == _type_1 then -- 797
					sessionId = _obj_0.sessionId -- 797
				end -- 797
			end -- 797
			local messageId -- 797
			do -- 797
				local _obj_0 = req.body -- 797
				local _type_1 = type(_obj_0) -- 797
				if "table" == _type_1 or "userdata" == _type_1 then -- 797
					messageId = _obj_0.messageId -- 797
				end -- 797
			end -- 797
			local prompt -- 797
			do -- 797
				local _obj_0 = req.body -- 797
				local _type_1 = type(_obj_0) -- 797
				if "table" == _type_1 or "userdata" == _type_1 then -- 797
					prompt = _obj_0.prompt -- 797
				end -- 797
			end -- 797
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 797
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 798
			end -- 797
		end -- 797
	end -- 797
	return invalidArguments -- 796
end) -- 796
HttpServer:post("/agent/session/questionnaire/respond", function(req) -- 800
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
			local questionnaireId -- 801
			do -- 801
				local _obj_0 = req.body -- 801
				local _type_1 = type(_obj_0) -- 801
				if "table" == _type_1 or "userdata" == _type_1 then -- 801
					questionnaireId = _obj_0.questionnaireId -- 801
				end -- 801
			end -- 801
			local answers -- 801
			do -- 801
				local _obj_0 = req.body -- 801
				local _type_1 = type(_obj_0) -- 801
				if "table" == _type_1 or "userdata" == _type_1 then -- 801
					answers = _obj_0.answers -- 801
				end -- 801
			end -- 801
			if sessionId ~= nil and questionnaireId ~= nil and answers ~= nil then -- 801
				return AgentSession.respondQuestionnaire(sessionId, questionnaireId, answers, req.body.llmConfigId) -- 802
			end -- 801
		end -- 801
	end -- 801
	return invalidArguments -- 800
end) -- 800
HttpServer:post("/agent/session/questionnaire/cancel", function(req) -- 804
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
			local questionnaireId -- 805
			do -- 805
				local _obj_0 = req.body -- 805
				local _type_1 = type(_obj_0) -- 805
				if "table" == _type_1 or "userdata" == _type_1 then -- 805
					questionnaireId = _obj_0.questionnaireId -- 805
				end -- 805
			end -- 805
			if sessionId ~= nil and questionnaireId ~= nil then -- 805
				return AgentSession.cancelQuestionnaire(sessionId, questionnaireId, req.body.llmConfigId) -- 806
			end -- 805
		end -- 805
	end -- 805
	return invalidArguments -- 804
end) -- 804
HttpServer:post("/agent/task/status", function(req) -- 808
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
			if sessionId ~= nil then -- 809
				local res = AgentSession.getSession(sessionId) -- 810
				if not res.success then -- 811
					return res -- 811
				end -- 811
				local taskId = res.session.currentTaskId -- 812
				local checkpoints -- 813
				if taskId then -- 813
					checkpoints = AgentTools.listCheckpoints(taskId) -- 813
				else -- 813
					checkpoints = { } -- 813
				end -- 813
				return { -- 815
					success = true, -- 815
					session = res.session, -- 816
					relatedSessions = res.relatedSessions, -- 817
					spawnInfo = res.spawnInfo, -- 818
					messages = res.messages, -- 819
					steps = res.steps, -- 820
					checkpoints = checkpoints, -- 821
					pendingQuestionnaire = res.pendingQuestionnaire, -- 822
					hasActivePlan = res.hasActivePlan -- 823
				} -- 814
			end -- 809
		end -- 809
	end -- 809
	return invalidArguments -- 808
end) -- 808
HttpServer:post("/agent/task/running", function() -- 825
	local res = AgentSession.listRunningSessions() -- 826
	if res.success and #res.sessions == 0 then -- 827
		res.sessions = nil -- 828
	end -- 827
	return res -- 829
end) -- 825
HttpServer:post("/agent/task/stop", function(req) -- 831
	do -- 832
		local _type_0 = type(req) -- 832
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 832
		if _tab_0 then -- 832
			local sessionId -- 832
			do -- 832
				local _obj_0 = req.body -- 832
				local _type_1 = type(_obj_0) -- 832
				if "table" == _type_1 or "userdata" == _type_1 then -- 832
					sessionId = _obj_0.sessionId -- 832
				end -- 832
			end -- 832
			if sessionId ~= nil then -- 832
				return AgentSession.stopSessionTask(sessionId) -- 833
			end -- 832
		end -- 832
	end -- 832
	return invalidArguments -- 831
end) -- 831
HttpServer:post("/agent/checkpoint/list", function(req) -- 835
	do -- 836
		local _type_0 = type(req) -- 836
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 836
		if _tab_0 then -- 836
			local taskId -- 836
			do -- 836
				local _obj_0 = req.body -- 836
				local _type_1 = type(_obj_0) -- 836
				if "table" == _type_1 or "userdata" == _type_1 then -- 836
					taskId = _obj_0.taskId -- 836
				end -- 836
			end -- 836
			local sessionId -- 836
			do -- 836
				local _obj_0 = req.body -- 836
				local _type_1 = type(_obj_0) -- 836
				if "table" == _type_1 or "userdata" == _type_1 then -- 836
					sessionId = _obj_0.sessionId -- 836
				end -- 836
			end -- 836
			if sessionId ~= nil then -- 836
				if not taskId and sessionId then -- 837
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 838
				end -- 837
				if not taskId then -- 839
					return { -- 839
						success = false, -- 839
						message = "task not found" -- 839
					} -- 839
				end -- 839
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 840
				if not access.success then -- 841
					return access -- 841
				end -- 841
				return { -- 843
					success = true, -- 843
					taskId = taskId, -- 844
					checkpoints = AgentTools.listCheckpoints(taskId) -- 845
				} -- 842
			end -- 836
		end -- 836
	end -- 836
	return invalidArguments -- 835
end) -- 835
HttpServer:post("/agent/checkpoint/diff", function(req) -- 847
	do -- 848
		local _type_0 = type(req) -- 848
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 848
		if _tab_0 then -- 848
			local sessionId -- 848
			do -- 848
				local _obj_0 = req.body -- 848
				local _type_1 = type(_obj_0) -- 848
				if "table" == _type_1 or "userdata" == _type_1 then -- 848
					sessionId = _obj_0.sessionId -- 848
				end -- 848
			end -- 848
			local checkpointId -- 848
			do -- 848
				local _obj_0 = req.body -- 848
				local _type_1 = type(_obj_0) -- 848
				if "table" == _type_1 or "userdata" == _type_1 then -- 848
					checkpointId = _obj_0.checkpointId -- 848
				end -- 848
			end -- 848
			if sessionId ~= nil and checkpointId ~= nil then -- 848
				if not (checkpointId > 0) then -- 849
					return { -- 849
						success = false, -- 849
						message = "invalid checkpointId" -- 849
					} -- 849
				end -- 849
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 850
				if not access.success then -- 851
					return access -- 851
				end -- 851
				return AgentTools.getCheckpointDiff(checkpointId) -- 852
			end -- 848
		end -- 848
	end -- 848
	return invalidArguments -- 847
end) -- 847
HttpServer:post("/agent/task/diff", function(req) -- 854
	do -- 855
		local _type_0 = type(req) -- 855
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 855
		if _tab_0 then -- 855
			local sessionId -- 855
			do -- 855
				local _obj_0 = req.body -- 855
				local _type_1 = type(_obj_0) -- 855
				if "table" == _type_1 or "userdata" == _type_1 then -- 855
					sessionId = _obj_0.sessionId -- 855
				end -- 855
			end -- 855
			local taskId -- 855
			do -- 855
				local _obj_0 = req.body -- 855
				local _type_1 = type(_obj_0) -- 855
				if "table" == _type_1 or "userdata" == _type_1 then -- 855
					taskId = _obj_0.taskId -- 855
				end -- 855
			end -- 855
			if sessionId ~= nil and taskId ~= nil then -- 855
				if not (taskId > 0) then -- 856
					return { -- 856
						success = false, -- 856
						message = "invalid taskId" -- 856
					} -- 856
				end -- 856
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 857
				if not access.success then -- 858
					return access -- 858
				end -- 858
				return AgentTools.getTaskChangeSetDiff(taskId) -- 859
			end -- 855
		end -- 855
	end -- 855
	return invalidArguments -- 854
end) -- 854
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 861
	do -- 862
		local _type_0 = type(req) -- 862
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 862
		if _tab_0 then -- 862
			local sessionId -- 862
			do -- 862
				local _obj_0 = req.body -- 862
				local _type_1 = type(_obj_0) -- 862
				if "table" == _type_1 or "userdata" == _type_1 then -- 862
					sessionId = _obj_0.sessionId -- 862
				end -- 862
			end -- 862
			local checkpointId -- 862
			do -- 862
				local _obj_0 = req.body -- 862
				local _type_1 = type(_obj_0) -- 862
				if "table" == _type_1 or "userdata" == _type_1 then -- 862
					checkpointId = _obj_0.checkpointId -- 862
				end -- 862
			end -- 862
			if sessionId ~= nil and checkpointId ~= nil then -- 862
				if not (checkpointId > 0) then -- 863
					return { -- 863
						success = false, -- 863
						message = "invalid checkpointId" -- 863
					} -- 863
				end -- 863
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 864
				if not access.success then -- 865
					return access -- 865
				end -- 865
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, access.session.projectRoot) -- 866
				if not rollbackRes.success then -- 867
					return rollbackRes -- 867
				end -- 867
				return { -- 869
					success = true, -- 869
					checkpointId = rollbackRes.checkpointId -- 870
				} -- 868
			end -- 862
		end -- 862
	end -- 862
	return invalidArguments -- 861
end) -- 861
HttpServer:post("/agent/task/rollback", function(req) -- 872
	do -- 873
		local _type_0 = type(req) -- 873
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 873
		if _tab_0 then -- 873
			local sessionId -- 873
			do -- 873
				local _obj_0 = req.body -- 873
				local _type_1 = type(_obj_0) -- 873
				if "table" == _type_1 or "userdata" == _type_1 then -- 873
					sessionId = _obj_0.sessionId -- 873
				end -- 873
			end -- 873
			local taskId -- 873
			do -- 873
				local _obj_0 = req.body -- 873
				local _type_1 = type(_obj_0) -- 873
				if "table" == _type_1 or "userdata" == _type_1 then -- 873
					taskId = _obj_0.taskId -- 873
				end -- 873
			end -- 873
			if sessionId ~= nil and taskId ~= nil then -- 873
				if not (taskId > 0) then -- 874
					return { -- 874
						success = false, -- 874
						message = "invalid taskId" -- 874
					} -- 874
				end -- 874
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 875
				if not access.success then -- 876
					return access -- 876
				end -- 876
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, access.session.projectRoot) -- 877
				if not rollbackRes.success then -- 878
					return rollbackRes -- 878
				end -- 878
				return { -- 880
					success = true, -- 880
					taskId = rollbackRes.taskId, -- 881
					checkpointId = rollbackRes.checkpointId, -- 882
					checkpointCount = rollbackRes.checkpointCount -- 883
				} -- 879
			end -- 873
		end -- 873
	end -- 873
	return invalidArguments -- 872
end) -- 872
local getSearchPath -- 885
getSearchPath = function(file) -- 885
	do -- 886
		local dir = getProjectDirFromFile(file) -- 886
		if dir then -- 886
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 887
		end -- 886
	end -- 886
	return "" -- 885
end -- 885
local getSearchFolders -- 889
getSearchFolders = function(file) -- 889
	do -- 890
		local dir = getProjectDirFromFile(file) -- 890
		if dir then -- 890
			return { -- 892
				Path(dir, "Script"), -- 892
				dir -- 893
			} -- 891
		end -- 890
	end -- 890
	return { } -- 889
end -- 889
local disabledCheckForLua = { -- 896
	"incompatible number of returns", -- 896
	"unknown", -- 897
	"cannot index", -- 898
	"module not found", -- 899
	"don't know how to resolve", -- 900
	"ContainerItem", -- 901
	"cannot resolve a type", -- 902
	"invalid key", -- 903
	"inconsistent index type", -- 904
	"cannot use operator", -- 905
	"attempting ipairs loop", -- 906
	"expects record or nominal", -- 907
	"variable is not being assigned", -- 908
	"<invalid type>", -- 909
	"<any type>", -- 910
	"using the '#' operator", -- 911
	"can't match a record", -- 912
	"redeclaration of variable", -- 913
	"cannot apply pairs", -- 914
	"not a function", -- 915
	"to%-be%-closed" -- 916
} -- 895
local yueCheck -- 918
yueCheck = function(file, content, lax) -- 918
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 919
	if isTIC80 then -- 920
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 921
	end -- 920
	local searchPath = getSearchPath(file) -- 922
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 923
	local info = { } -- 924
	local globals = { } -- 925
	for _index_0 = 1, #checkResult do -- 926
		local _des_0 = checkResult[_index_0] -- 926
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 926
		if "error" == t then -- 927
			info[#info + 1] = { -- 928
				"syntax", -- 928
				file, -- 928
				line, -- 928
				col, -- 928
				msg -- 928
			} -- 928
		elseif "global" == t then -- 929
			globals[#globals + 1] = { -- 930
				msg, -- 930
				line, -- 930
				col -- 930
			} -- 930
		end -- 927
	end -- 926
	if luaCodes then -- 931
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 932
		if success then -- 933
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 934
			if not (lintResult == "") then -- 935
				lintResult = lintResult .. "\n" -- 935
			end -- 935
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 936
		else -- 937
			for _index_0 = 1, #lintResult do -- 937
				local _des_0 = lintResult[_index_0] -- 937
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 937
				if isTIC80 and tic80APIs[name] then -- 938
					goto _continue_0 -- 938
				end -- 938
				info[#info + 1] = { -- 939
					"syntax", -- 939
					file, -- 939
					line, -- 939
					col, -- 939
					"invalid global variable" -- 939
				} -- 939
				::_continue_0:: -- 938
			end -- 937
		end -- 933
	end -- 931
	return luaCodes, info -- 940
end -- 918
local luaCheck -- 942
luaCheck = function(file, content) -- 942
	local res, err = load(content, "check") -- 943
	if not res then -- 944
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 945
		return { -- 946
			success = false, -- 946
			info = { -- 946
				{ -- 946
					"syntax", -- 946
					file, -- 946
					tonumber(line), -- 946
					0, -- 946
					msg -- 946
				} -- 946
			} -- 946
		} -- 946
	end -- 944
	local success, info = teal.checkAsync(content, file, true, "") -- 947
	if info then -- 948
		do -- 949
			local _accum_0 = { } -- 949
			local _len_0 = 1 -- 949
			for _index_0 = 1, #info do -- 949
				local item = info[_index_0] -- 949
				local useCheck = true -- 950
				if not item[5]:match("unused") then -- 951
					for _index_1 = 1, #disabledCheckForLua do -- 952
						local check = disabledCheckForLua[_index_1] -- 952
						if item[5]:match(check) then -- 953
							useCheck = false -- 954
						end -- 953
					end -- 952
				end -- 951
				if not useCheck then -- 955
					goto _continue_0 -- 955
				end -- 955
				do -- 956
					local _exp_0 = item[1] -- 956
					if "type" == _exp_0 then -- 957
						item[1] = "warning" -- 958
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 959
						goto _continue_0 -- 960
					end -- 956
				end -- 956
				_accum_0[_len_0] = item -- 961
				_len_0 = _len_0 + 1 -- 950
				::_continue_0:: -- 950
			end -- 949
			info = _accum_0 -- 949
		end -- 949
		if #info == 0 then -- 962
			info = nil -- 963
			success = true -- 964
		end -- 962
	end -- 948
	return { -- 965
		success = success, -- 965
		info = info -- 965
	} -- 965
end -- 942
local luaCheckWithLineInfo -- 967
luaCheckWithLineInfo = function(file, luaCodes) -- 967
	local res = luaCheck(file, luaCodes) -- 968
	local info = { } -- 969
	if not res.success then -- 970
		local current = 1 -- 971
		local lastLine = 1 -- 972
		local lineMap = { } -- 973
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 974
			local num = lineCode:match("--%s*(%d+)%s*$") -- 975
			if num then -- 976
				lastLine = tonumber(num) -- 977
			end -- 976
			lineMap[current] = lastLine -- 978
			current = current + 1 -- 979
		end -- 974
		local _list_0 = res.info -- 980
		for _index_0 = 1, #_list_0 do -- 980
			local item = _list_0[_index_0] -- 980
			item[3] = lineMap[item[3]] or 0 -- 981
			item[4] = 0 -- 982
			info[#info + 1] = item -- 983
		end -- 980
		return false, info -- 984
	end -- 970
	return true, info -- 985
end -- 967
local getCompiledYueLine -- 987
getCompiledYueLine = function(content, line, row, file, lax) -- 987
	local luaCodes = yueCheck(file, content, lax) -- 988
	if not luaCodes then -- 989
		return nil -- 989
	end -- 989
	local current = 1 -- 990
	local lastLine = 1 -- 991
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 992
	local targetRow = nil -- 993
	local lineMap = { } -- 994
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 995
		local num = lineCode:match("--%s*(%d+)%s*$") -- 996
		if num then -- 997
			lastLine = tonumber(num) -- 997
		end -- 997
		lineMap[current] = lastLine -- 998
		if row <= lastLine and not targetRow then -- 999
			targetRow = current -- 1000
			break -- 1001
		end -- 999
		current = current + 1 -- 1002
	end -- 995
	targetRow = current -- 1003
	if targetLine and targetRow then -- 1004
		return luaCodes, targetLine, targetRow, lineMap -- 1005
	else -- 1007
		return nil -- 1007
	end -- 1004
end -- 987
HttpServer:postSchedule("/check", function(req) -- 1009
	do -- 1010
		local _type_0 = type(req) -- 1010
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1010
		if _tab_0 then -- 1010
			local file -- 1010
			do -- 1010
				local _obj_0 = req.body -- 1010
				local _type_1 = type(_obj_0) -- 1010
				if "table" == _type_1 or "userdata" == _type_1 then -- 1010
					file = _obj_0.file -- 1010
				end -- 1010
			end -- 1010
			local content -- 1010
			do -- 1010
				local _obj_0 = req.body -- 1010
				local _type_1 = type(_obj_0) -- 1010
				if "table" == _type_1 or "userdata" == _type_1 then -- 1010
					content = _obj_0.content -- 1010
				end -- 1010
			end -- 1010
			if file ~= nil and content ~= nil then -- 1010
				local ext = Path:getExt(file) -- 1011
				if "tl" == ext then -- 1012
					local searchPath = getSearchPath(file) -- 1013
					do -- 1014
						local isTIC80 = CheckTIC80Code(content) -- 1014
						if isTIC80 then -- 1014
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1015
						end -- 1014
					end -- 1014
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 1016
					return { -- 1017
						success = success, -- 1017
						info = info -- 1017
					} -- 1017
				elseif "lua" == ext then -- 1018
					do -- 1019
						local isTIC80 = CheckTIC80Code(content) -- 1019
						if isTIC80 then -- 1019
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1020
						end -- 1019
					end -- 1019
					return luaCheck(file, content) -- 1021
				elseif "yue" == ext then -- 1022
					local luaCodes, info = yueCheck(file, content, false) -- 1023
					local success = luaCodes ~= nil -- 1024
					if luaCodes then -- 1025
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 1026
						do -- 1027
							local _tab_1 = { } -- 1027
							local _idx_0 = #_tab_1 + 1 -- 1027
							for _index_0 = 1, #info do -- 1027
								local _value_0 = info[_index_0] -- 1027
								_tab_1[_idx_0] = _value_0 -- 1027
								_idx_0 = _idx_0 + 1 -- 1027
							end -- 1027
							local _idx_1 = #_tab_1 + 1 -- 1027
							for _index_0 = 1, #luaInfo do -- 1027
								local _value_0 = luaInfo[_index_0] -- 1027
								_tab_1[_idx_1] = _value_0 -- 1027
								_idx_1 = _idx_1 + 1 -- 1027
							end -- 1027
							info = _tab_1 -- 1027
						end -- 1027
						success = success and luaSuccess -- 1028
					end -- 1025
					if #info > 0 then -- 1029
						return { -- 1030
							success = success, -- 1030
							info = info -- 1030
						} -- 1030
					else -- 1032
						return { -- 1032
							success = success -- 1032
						} -- 1032
					end -- 1029
				elseif "xml" == ext then -- 1033
					local success, result = xml.check(content) -- 1034
					if success then -- 1035
						local info -- 1036
						success, info = luaCheckWithLineInfo(file, result) -- 1036
						if #info > 0 then -- 1037
							return { -- 1038
								success = success, -- 1038
								info = info -- 1038
							} -- 1038
						else -- 1040
							return { -- 1040
								success = success -- 1040
							} -- 1040
						end -- 1037
					else -- 1042
						local info -- 1042
						do -- 1042
							local _accum_0 = { } -- 1042
							local _len_0 = 1 -- 1042
							for _index_0 = 1, #result do -- 1042
								local _des_0 = result[_index_0] -- 1042
								local row, err = _des_0[1], _des_0[2] -- 1042
								_accum_0[_len_0] = { -- 1043
									"syntax", -- 1043
									file, -- 1043
									row, -- 1043
									0, -- 1043
									err -- 1043
								} -- 1043
								_len_0 = _len_0 + 1 -- 1043
							end -- 1042
							info = _accum_0 -- 1042
						end -- 1042
						return { -- 1044
							success = false, -- 1044
							info = info -- 1044
						} -- 1044
					end -- 1035
				end -- 1012
			end -- 1010
		end -- 1010
	end -- 1010
	return { -- 1009
		success = true -- 1009
	} -- 1009
end) -- 1009
HttpServer:post("/body/parse", function(req) -- 1046
	do -- 1047
		local _type_0 = type(req) -- 1047
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1047
		if _tab_0 then -- 1047
			local file -- 1047
			do -- 1047
				local _obj_0 = req.body -- 1047
				local _type_1 = type(_obj_0) -- 1047
				if "table" == _type_1 or "userdata" == _type_1 then -- 1047
					file = _obj_0.file -- 1047
				end -- 1047
			end -- 1047
			local content -- 1047
			do -- 1047
				local _obj_0 = req.body -- 1047
				local _type_1 = type(_obj_0) -- 1047
				if "table" == _type_1 or "userdata" == _type_1 then -- 1047
					content = _obj_0.content -- 1047
				end -- 1047
			end -- 1047
			if file ~= nil and content ~= nil then -- 1047
				if not (file:sub(-6) == ".b.lua") then -- 1048
					return { -- 1049
						success = false, -- 1049
						phase = "request", -- 1049
						message = "only .b.lua files can be converted" -- 1049
					} -- 1049
				end -- 1048
				local loader, err = load("_ENV = {}\n" .. content) -- 1050
				if not loader then -- 1051
					return { -- 1052
						success = false, -- 1052
						phase = "parse", -- 1052
						message = tostring(err) -- 1052
					} -- 1052
				end -- 1051
				local ok, data = pcall(loader) -- 1053
				if not ok then -- 1054
					return { -- 1055
						success = false, -- 1055
						phase = "execute", -- 1055
						message = tostring(data) -- 1055
					} -- 1055
				end -- 1054
				if not ("table" == type(data) and data[1] == "Array") then -- 1056
					return { -- 1057
						success = false, -- 1057
						phase = "validate", -- 1057
						message = "body lua root must be {\"Array\", ...}" -- 1057
					} -- 1057
				end -- 1056
				local text, jsonErr = json.encode(data, false, true) -- 1058
				if not text then -- 1059
					return { -- 1060
						success = false, -- 1060
						phase = "encode", -- 1060
						message = tostring(jsonErr) -- 1060
					} -- 1060
				end -- 1059
				return { -- 1061
					success = true, -- 1061
					json = text -- 1061
				} -- 1061
			end -- 1047
		end -- 1047
	end -- 1047
	return { -- 1046
		success = false, -- 1046
		phase = "request", -- 1046
		message = "invalid request" -- 1046
	} -- 1046
end) -- 1046
local updateInferedDesc -- 1063
updateInferedDesc = function(infered) -- 1063
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1064
		return -- 1064
	end -- 1064
	local key, row = infered.key, infered.row -- 1065
	local codes = Content:loadAsync(key) -- 1066
	if codes then -- 1066
		local comments = { } -- 1067
		local line = 0 -- 1068
		local skipping = false -- 1069
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1070
			line = line + 1 -- 1071
			if line >= row then -- 1072
				break -- 1072
			end -- 1072
			if lineCode:match("^%s*%-%- @") then -- 1073
				skipping = true -- 1074
				goto _continue_0 -- 1075
			end -- 1073
			local result = lineCode:match("^%s*%-%- (.+)") -- 1076
			if result then -- 1076
				if not skipping then -- 1077
					comments[#comments + 1] = result -- 1077
				end -- 1077
			elseif #comments > 0 then -- 1078
				comments = { } -- 1079
				skipping = false -- 1080
			end -- 1076
			::_continue_0:: -- 1071
		end -- 1070
		infered.doc = table.concat(comments, "\n") -- 1081
	end -- 1066
end -- 1063
HttpServer:postSchedule("/infer", function(req) -- 1083
	do -- 1084
		local _type_0 = type(req) -- 1084
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1084
		if _tab_0 then -- 1084
			local lang -- 1084
			do -- 1084
				local _obj_0 = req.body -- 1084
				local _type_1 = type(_obj_0) -- 1084
				if "table" == _type_1 or "userdata" == _type_1 then -- 1084
					lang = _obj_0.lang -- 1084
				end -- 1084
			end -- 1084
			local file -- 1084
			do -- 1084
				local _obj_0 = req.body -- 1084
				local _type_1 = type(_obj_0) -- 1084
				if "table" == _type_1 or "userdata" == _type_1 then -- 1084
					file = _obj_0.file -- 1084
				end -- 1084
			end -- 1084
			local content -- 1084
			do -- 1084
				local _obj_0 = req.body -- 1084
				local _type_1 = type(_obj_0) -- 1084
				if "table" == _type_1 or "userdata" == _type_1 then -- 1084
					content = _obj_0.content -- 1084
				end -- 1084
			end -- 1084
			local line -- 1084
			do -- 1084
				local _obj_0 = req.body -- 1084
				local _type_1 = type(_obj_0) -- 1084
				if "table" == _type_1 or "userdata" == _type_1 then -- 1084
					line = _obj_0.line -- 1084
				end -- 1084
			end -- 1084
			local row -- 1084
			do -- 1084
				local _obj_0 = req.body -- 1084
				local _type_1 = type(_obj_0) -- 1084
				if "table" == _type_1 or "userdata" == _type_1 then -- 1084
					row = _obj_0.row -- 1084
				end -- 1084
			end -- 1084
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1084
				local searchPath = getSearchPath(file) -- 1085
				if "tl" == lang or "lua" == lang then -- 1086
					if CheckTIC80Code(content) then -- 1087
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1088
					end -- 1087
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1089
					if (infered ~= nil) then -- 1090
						updateInferedDesc(infered) -- 1091
						return { -- 1092
							success = true, -- 1092
							infered = infered -- 1092
						} -- 1092
					end -- 1090
				elseif "yue" == lang then -- 1093
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1094
					if not luaCodes then -- 1095
						return { -- 1095
							success = false -- 1095
						} -- 1095
					end -- 1095
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1096
					if (infered ~= nil) then -- 1097
						local col -- 1098
						file, row, col = infered.file, infered.row, infered.col -- 1098
						if file == "" and row > 0 and col > 0 then -- 1099
							infered.row = lineMap[row] or 0 -- 1100
							infered.col = 0 -- 1101
						end -- 1099
						updateInferedDesc(infered) -- 1102
						return { -- 1103
							success = true, -- 1103
							infered = infered -- 1103
						} -- 1103
					end -- 1097
				end -- 1086
			end -- 1084
		end -- 1084
	end -- 1084
	return { -- 1083
		success = false -- 1083
	} -- 1083
end) -- 1083
local _anon_func_3 = function(doc) -- 1164
	local _accum_0 = { } -- 1164
	local _len_0 = 1 -- 1164
	local _list_0 = doc.params -- 1164
	for _index_0 = 1, #_list_0 do -- 1164
		local param = _list_0[_index_0] -- 1164
		_accum_0[_len_0] = param.name -- 1164
		_len_0 = _len_0 + 1 -- 1164
	end -- 1164
	return _accum_0 -- 1164
end -- 1164
local getParamDocs -- 1105
getParamDocs = function(signatures) -- 1105
	if not (signatures and #signatures > 0) then -- 1106
		return nil -- 1106
	end -- 1106
	local docs = { } -- 1107
	do -- 1108
		local codes = Content:loadAsync(signatures[1].file) -- 1108
		if codes then -- 1108
			local comments = { } -- 1109
			local params = { } -- 1110
			local line = 0 -- 1111
			local returnType = nil -- 1112
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1113
				line = line + 1 -- 1114
				local needBreak = true -- 1115
				for i, _des_0 in ipairs(signatures) do -- 1116
					local row = _des_0.row -- 1116
					if line >= row and not (docs[i] ~= nil) then -- 1117
						if #comments > 0 or #params > 0 or returnType then -- 1118
							docs[i] = { -- 1120
								doc = table.concat(comments, "  \n"), -- 1120
								returnType = returnType -- 1121
							} -- 1119
							if #params > 0 then -- 1123
								docs[i].params = params -- 1123
							end -- 1123
						else -- 1125
							docs[i] = false -- 1125
						end -- 1118
					end -- 1117
					if not docs[i] then -- 1126
						needBreak = false -- 1126
					end -- 1126
				end -- 1116
				if needBreak then -- 1127
					break -- 1127
				end -- 1127
				local result = lineCode:match("%s*%-%- (.+)") -- 1128
				if result then -- 1128
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1129
					if not name then -- 1130
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1131
					end -- 1130
					if name then -- 1132
						local pname = name -- 1133
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1134
							pname = pname .. "?" -- 1134
						end -- 1134
						params[#params + 1] = { -- 1136
							name = tostring(pname) .. ": " .. tostring(typ), -- 1136
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1137
						} -- 1135
					else -- 1140
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1140
						if typ then -- 1140
							if returnType then -- 1141
								returnType = returnType .. ", " .. typ -- 1142
							else -- 1144
								returnType = typ -- 1144
							end -- 1141
							result = result:gsub("@return", "**return:**") -- 1145
						end -- 1140
						comments[#comments + 1] = result -- 1146
					end -- 1132
				elseif #comments > 0 then -- 1147
					comments = { } -- 1148
					params = { } -- 1149
					returnType = nil -- 1150
				end -- 1128
			end -- 1113
		end -- 1108
	end -- 1108
	local results = { } -- 1151
	for i, signature in ipairs(signatures) do -- 1152
		local item = { -- 1154
			desc = signature.desc, -- 1154
			doc = "", -- 1155
			file = signature.file, -- 1156
			row = signature.row, -- 1157
			col = signature.col -- 1158
		} -- 1153
		do -- 1160
			local doc = docs[i] -- 1160
			if doc then -- 1160
				item.doc = doc.doc -- 1161
				if doc.params then -- 1162
					item.params = doc.params -- 1163
					item.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1164
				elseif doc.returnType then -- 1165
					item.desc = "function()" -- 1166
				end -- 1162
				if doc.returnType then -- 1167
					item.desc = item.desc .. ": " .. tostring(doc.returnType) -- 1167
				end -- 1167
			end -- 1160
		end -- 1160
		results[#results + 1] = item -- 1168
	end -- 1152
	return results -- 1169
end -- 1105
HttpServer:postSchedule("/signature", function(req) -- 1171
	do -- 1172
		local _type_0 = type(req) -- 1172
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1172
		if _tab_0 then -- 1172
			local lang -- 1172
			do -- 1172
				local _obj_0 = req.body -- 1172
				local _type_1 = type(_obj_0) -- 1172
				if "table" == _type_1 or "userdata" == _type_1 then -- 1172
					lang = _obj_0.lang -- 1172
				end -- 1172
			end -- 1172
			local file -- 1172
			do -- 1172
				local _obj_0 = req.body -- 1172
				local _type_1 = type(_obj_0) -- 1172
				if "table" == _type_1 or "userdata" == _type_1 then -- 1172
					file = _obj_0.file -- 1172
				end -- 1172
			end -- 1172
			local content -- 1172
			do -- 1172
				local _obj_0 = req.body -- 1172
				local _type_1 = type(_obj_0) -- 1172
				if "table" == _type_1 or "userdata" == _type_1 then -- 1172
					content = _obj_0.content -- 1172
				end -- 1172
			end -- 1172
			local line -- 1172
			do -- 1172
				local _obj_0 = req.body -- 1172
				local _type_1 = type(_obj_0) -- 1172
				if "table" == _type_1 or "userdata" == _type_1 then -- 1172
					line = _obj_0.line -- 1172
				end -- 1172
			end -- 1172
			local row -- 1172
			do -- 1172
				local _obj_0 = req.body -- 1172
				local _type_1 = type(_obj_0) -- 1172
				if "table" == _type_1 or "userdata" == _type_1 then -- 1172
					row = _obj_0.row -- 1172
				end -- 1172
			end -- 1172
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1172
				local searchPath = getSearchPath(file) -- 1173
				if "tl" == lang or "lua" == lang then -- 1174
					if CheckTIC80Code(content) then -- 1175
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1176
					end -- 1175
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1177
					if signatures then -- 1177
						signatures = getParamDocs(signatures) -- 1178
						if signatures then -- 1178
							return { -- 1179
								success = true, -- 1179
								signatures = signatures -- 1179
							} -- 1179
						end -- 1178
					end -- 1177
				elseif "yue" == lang then -- 1180
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1181
					if not luaCodes then -- 1182
						return { -- 1182
							success = false -- 1182
						} -- 1182
					end -- 1182
					do -- 1183
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1183
						if chainOp then -- 1183
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1184
							if withVar then -- 1184
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1185
							end -- 1184
						end -- 1183
					end -- 1183
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1186
					if signatures then -- 1186
						signatures = getParamDocs(signatures) -- 1187
						if signatures then -- 1187
							return { -- 1188
								success = true, -- 1188
								signatures = signatures -- 1188
							} -- 1188
						end -- 1187
					else -- 1189
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1189
						if signatures then -- 1189
							signatures = getParamDocs(signatures) -- 1190
							if signatures then -- 1190
								return { -- 1191
									success = true, -- 1191
									signatures = signatures -- 1191
								} -- 1191
							end -- 1190
						end -- 1189
					end -- 1186
				end -- 1174
			end -- 1172
		end -- 1172
	end -- 1172
	return { -- 1171
		success = false -- 1171
	} -- 1171
end) -- 1171
local luaKeywords = { -- 1194
	'and', -- 1194
	'break', -- 1195
	'do', -- 1196
	'else', -- 1197
	'elseif', -- 1198
	'end', -- 1199
	'false', -- 1200
	'for', -- 1201
	'function', -- 1202
	'goto', -- 1203
	'if', -- 1204
	'in', -- 1205
	'local', -- 1206
	'nil', -- 1207
	'not', -- 1208
	'or', -- 1209
	'repeat', -- 1210
	'return', -- 1211
	'then', -- 1212
	'true', -- 1213
	'until', -- 1214
	'while' -- 1215
} -- 1193
local tealKeywords = { -- 1219
	'record', -- 1219
	'as', -- 1220
	'is', -- 1221
	'type', -- 1222
	'embed', -- 1223
	'enum', -- 1224
	'global', -- 1225
	'any', -- 1226
	'boolean', -- 1227
	'integer', -- 1228
	'number', -- 1229
	'string', -- 1230
	'thread' -- 1231
} -- 1218
local yueKeywords = { -- 1235
	"and", -- 1235
	"break", -- 1236
	"do", -- 1237
	"else", -- 1238
	"elseif", -- 1239
	"false", -- 1240
	"for", -- 1241
	"goto", -- 1242
	"if", -- 1243
	"in", -- 1244
	"local", -- 1245
	"nil", -- 1246
	"not", -- 1247
	"or", -- 1248
	"repeat", -- 1249
	"return", -- 1250
	"then", -- 1251
	"true", -- 1252
	"until", -- 1253
	"while", -- 1254
	"as", -- 1255
	"class", -- 1256
	"continue", -- 1257
	"export", -- 1258
	"extends", -- 1259
	"from", -- 1260
	"global", -- 1261
	"import", -- 1262
	"macro", -- 1263
	"switch", -- 1264
	"try", -- 1265
	"unless", -- 1266
	"using", -- 1267
	"when", -- 1268
	"with" -- 1269
} -- 1234
local _anon_func_4 = function(f) -- 1305
	local _val_0 = Path:getExt(f) -- 1305
	return "ttf" == _val_0 or "otf" == _val_0 -- 1305
end -- 1305
local _anon_func_5 = function(suggestions) -- 1331
	local _tbl_0 = { } -- 1331
	for _index_0 = 1, #suggestions do -- 1331
		local item = suggestions[_index_0] -- 1331
		_tbl_0[item[1] .. item[2]] = item -- 1331
	end -- 1331
	return _tbl_0 -- 1331
end -- 1331
HttpServer:postSchedule("/complete", function(req) -- 1272
	do -- 1273
		local _type_0 = type(req) -- 1273
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1273
		if _tab_0 then -- 1273
			local lang -- 1273
			do -- 1273
				local _obj_0 = req.body -- 1273
				local _type_1 = type(_obj_0) -- 1273
				if "table" == _type_1 or "userdata" == _type_1 then -- 1273
					lang = _obj_0.lang -- 1273
				end -- 1273
			end -- 1273
			local file -- 1273
			do -- 1273
				local _obj_0 = req.body -- 1273
				local _type_1 = type(_obj_0) -- 1273
				if "table" == _type_1 or "userdata" == _type_1 then -- 1273
					file = _obj_0.file -- 1273
				end -- 1273
			end -- 1273
			local content -- 1273
			do -- 1273
				local _obj_0 = req.body -- 1273
				local _type_1 = type(_obj_0) -- 1273
				if "table" == _type_1 or "userdata" == _type_1 then -- 1273
					content = _obj_0.content -- 1273
				end -- 1273
			end -- 1273
			local line -- 1273
			do -- 1273
				local _obj_0 = req.body -- 1273
				local _type_1 = type(_obj_0) -- 1273
				if "table" == _type_1 or "userdata" == _type_1 then -- 1273
					line = _obj_0.line -- 1273
				end -- 1273
			end -- 1273
			local row -- 1273
			do -- 1273
				local _obj_0 = req.body -- 1273
				local _type_1 = type(_obj_0) -- 1273
				if "table" == _type_1 or "userdata" == _type_1 then -- 1273
					row = _obj_0.row -- 1273
				end -- 1273
			end -- 1273
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1273
				local searchPath = getSearchPath(file) -- 1274
				repeat -- 1275
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1276
					if lang == "yue" then -- 1277
						if not item then -- 1278
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1278
						end -- 1278
						if not item then -- 1279
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1279
						end -- 1279
					end -- 1277
					local searchType = nil -- 1280
					if not item then -- 1281
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1282
						if lang == "yue" then -- 1283
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1284
						end -- 1283
						if (item ~= nil) then -- 1285
							searchType = "Image" -- 1285
						end -- 1285
					end -- 1281
					if not item then -- 1286
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1287
						if lang == "yue" then -- 1288
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1289
						end -- 1288
						if (item ~= nil) then -- 1290
							searchType = "Font" -- 1290
						end -- 1290
					end -- 1286
					if not item then -- 1291
						break -- 1291
					end -- 1291
					local searchPaths = Content.searchPaths -- 1292
					local _list_0 = getSearchFolders(file) -- 1293
					for _index_0 = 1, #_list_0 do -- 1293
						local folder = _list_0[_index_0] -- 1293
						searchPaths[#searchPaths + 1] = folder -- 1294
					end -- 1293
					if searchType then -- 1295
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1295
					end -- 1295
					local tokens -- 1296
					do -- 1296
						local _accum_0 = { } -- 1296
						local _len_0 = 1 -- 1296
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1296
							_accum_0[_len_0] = mod -- 1296
							_len_0 = _len_0 + 1 -- 1296
						end -- 1296
						tokens = _accum_0 -- 1296
					end -- 1296
					local suggestions = { } -- 1297
					for _index_0 = 1, #searchPaths do -- 1298
						local path = searchPaths[_index_0] -- 1298
						local sPath = Path(path, table.unpack(tokens)) -- 1299
						if not Content:exist(sPath) then -- 1300
							goto _continue_0 -- 1300
						end -- 1300
						if searchType == "Font" then -- 1301
							local fontPath = Path(sPath, "Font") -- 1302
							if Content:exist(fontPath) then -- 1303
								local _list_1 = Content:getFiles(fontPath) -- 1304
								for _index_1 = 1, #_list_1 do -- 1304
									local f = _list_1[_index_1] -- 1304
									if _anon_func_4(f) then -- 1305
										if "." == f:sub(1, 1) then -- 1306
											goto _continue_1 -- 1306
										end -- 1306
										suggestions[#suggestions + 1] = { -- 1307
											Path:getName(f), -- 1307
											"font", -- 1307
											"field" -- 1307
										} -- 1307
									end -- 1305
									::_continue_1:: -- 1305
								end -- 1304
							end -- 1303
						end -- 1301
						local _list_1 = Content:getFiles(sPath) -- 1308
						for _index_1 = 1, #_list_1 do -- 1308
							local f = _list_1[_index_1] -- 1308
							if "Image" == searchType then -- 1309
								do -- 1310
									local _exp_0 = Path:getExt(f) -- 1310
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1310
										if "." == f:sub(1, 1) then -- 1311
											goto _continue_2 -- 1311
										end -- 1311
										suggestions[#suggestions + 1] = { -- 1312
											f, -- 1312
											"image", -- 1312
											"field" -- 1312
										} -- 1312
									end -- 1310
								end -- 1310
								goto _continue_2 -- 1313
							elseif "Font" == searchType then -- 1314
								do -- 1315
									local _exp_0 = Path:getExt(f) -- 1315
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1315
										if "." == f:sub(1, 1) then -- 1316
											goto _continue_2 -- 1316
										end -- 1316
										suggestions[#suggestions + 1] = { -- 1317
											f, -- 1317
											"font", -- 1317
											"field" -- 1317
										} -- 1317
									end -- 1315
								end -- 1315
								goto _continue_2 -- 1318
							end -- 1309
							local _exp_0 = Path:getExt(f) -- 1319
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1319
								local name = Path:getName(f) -- 1320
								if "d" == Path:getExt(name) then -- 1321
									goto _continue_2 -- 1321
								end -- 1321
								if "." == name:sub(1, 1) then -- 1322
									goto _continue_2 -- 1322
								end -- 1322
								suggestions[#suggestions + 1] = { -- 1323
									name, -- 1323
									"module", -- 1323
									"field" -- 1323
								} -- 1323
							end -- 1319
							::_continue_2:: -- 1309
						end -- 1308
						local _list_2 = Content:getDirs(sPath) -- 1324
						for _index_1 = 1, #_list_2 do -- 1324
							local dir = _list_2[_index_1] -- 1324
							if "." == dir:sub(1, 1) then -- 1325
								goto _continue_3 -- 1325
							end -- 1325
							suggestions[#suggestions + 1] = { -- 1326
								dir, -- 1326
								"folder", -- 1326
								"variable" -- 1326
							} -- 1326
							::_continue_3:: -- 1325
						end -- 1324
						::_continue_0:: -- 1299
					end -- 1298
					if item == "" and not searchType then -- 1327
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1328
						for _index_0 = 1, #_list_1 do -- 1328
							local _des_0 = _list_1[_index_0] -- 1328
							local name = _des_0[1] -- 1328
							suggestions[#suggestions + 1] = { -- 1329
								name, -- 1329
								"dora module", -- 1329
								"function" -- 1329
							} -- 1329
						end -- 1328
					end -- 1327
					if #suggestions > 0 then -- 1330
						do -- 1331
							local _accum_0 = { } -- 1331
							local _len_0 = 1 -- 1331
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1331
								_accum_0[_len_0] = v -- 1331
								_len_0 = _len_0 + 1 -- 1331
							end -- 1331
							suggestions = _accum_0 -- 1331
						end -- 1331
						return { -- 1332
							success = true, -- 1332
							suggestions = suggestions -- 1332
						} -- 1332
					else -- 1334
						return { -- 1334
							success = false -- 1334
						} -- 1334
					end -- 1330
				until true -- 1275
				if "tl" == lang or "lua" == lang then -- 1336
					do -- 1337
						local isTIC80 = CheckTIC80Code(content) -- 1337
						if isTIC80 then -- 1337
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1338
						end -- 1337
					end -- 1337
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1339
					if not line:match("[%.:]$") then -- 1340
						local checkSet -- 1341
						do -- 1341
							local _tbl_0 = { } -- 1341
							for _index_0 = 1, #suggestions do -- 1341
								local _des_0 = suggestions[_index_0] -- 1341
								local name = _des_0[1] -- 1341
								_tbl_0[name] = true -- 1341
							end -- 1341
							checkSet = _tbl_0 -- 1341
						end -- 1341
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1342
						for _index_0 = 1, #_list_0 do -- 1342
							local item = _list_0[_index_0] -- 1342
							if not checkSet[item[1]] then -- 1343
								suggestions[#suggestions + 1] = item -- 1343
							end -- 1343
						end -- 1342
						for _index_0 = 1, #luaKeywords do -- 1344
							local word = luaKeywords[_index_0] -- 1344
							suggestions[#suggestions + 1] = { -- 1345
								word, -- 1345
								"keyword", -- 1345
								"keyword" -- 1345
							} -- 1345
						end -- 1344
						if lang == "tl" then -- 1346
							for _index_0 = 1, #tealKeywords do -- 1347
								local word = tealKeywords[_index_0] -- 1347
								suggestions[#suggestions + 1] = { -- 1348
									word, -- 1348
									"keyword", -- 1348
									"keyword" -- 1348
								} -- 1348
							end -- 1347
						end -- 1346
					end -- 1340
					if #suggestions > 0 then -- 1349
						return { -- 1350
							success = true, -- 1350
							suggestions = suggestions -- 1350
						} -- 1350
					end -- 1349
				elseif "yue" == lang then -- 1351
					local suggestions = { } -- 1352
					local gotGlobals = false -- 1353
					do -- 1354
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1354
						if luaCodes then -- 1354
							gotGlobals = true -- 1355
							do -- 1356
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1356
								if chainOp then -- 1356
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1357
									if not withVar then -- 1358
										return { -- 1358
											success = false -- 1358
										} -- 1358
									end -- 1358
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1359
								elseif line:match("^([%.\\])$") then -- 1360
									return { -- 1361
										success = false -- 1361
									} -- 1361
								end -- 1356
							end -- 1356
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1362
							for _index_0 = 1, #_list_0 do -- 1362
								local item = _list_0[_index_0] -- 1362
								suggestions[#suggestions + 1] = item -- 1362
							end -- 1362
							if #suggestions == 0 then -- 1363
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1364
								for _index_0 = 1, #_list_1 do -- 1364
									local item = _list_1[_index_0] -- 1364
									suggestions[#suggestions + 1] = item -- 1364
								end -- 1364
							end -- 1363
						end -- 1354
					end -- 1354
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1365
						local checkSet -- 1366
						do -- 1366
							local _tbl_0 = { } -- 1366
							for _index_0 = 1, #suggestions do -- 1366
								local _des_0 = suggestions[_index_0] -- 1366
								local name = _des_0[1] -- 1366
								_tbl_0[name] = true -- 1366
							end -- 1366
							checkSet = _tbl_0 -- 1366
						end -- 1366
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1367
						for _index_0 = 1, #_list_0 do -- 1367
							local item = _list_0[_index_0] -- 1367
							if not checkSet[item[1]] then -- 1368
								suggestions[#suggestions + 1] = item -- 1368
							end -- 1368
						end -- 1367
						if not gotGlobals then -- 1369
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1370
							for _index_0 = 1, #_list_1 do -- 1370
								local item = _list_1[_index_0] -- 1370
								if not checkSet[item[1]] then -- 1371
									suggestions[#suggestions + 1] = item -- 1371
								end -- 1371
							end -- 1370
						end -- 1369
						for _index_0 = 1, #yueKeywords do -- 1372
							local word = yueKeywords[_index_0] -- 1372
							if not checkSet[word] then -- 1373
								suggestions[#suggestions + 1] = { -- 1374
									word, -- 1374
									"keyword", -- 1374
									"keyword" -- 1374
								} -- 1374
							end -- 1373
						end -- 1372
					end -- 1365
					if #suggestions > 0 then -- 1375
						return { -- 1376
							success = true, -- 1376
							suggestions = suggestions -- 1376
						} -- 1376
					end -- 1375
				elseif "xml" == lang then -- 1377
					local items = xml.complete(content) -- 1378
					if #items > 0 then -- 1379
						local suggestions -- 1380
						do -- 1380
							local _accum_0 = { } -- 1380
							local _len_0 = 1 -- 1380
							for _index_0 = 1, #items do -- 1380
								local _des_0 = items[_index_0] -- 1380
								local label, insertText = _des_0[1], _des_0[2] -- 1380
								_accum_0[_len_0] = { -- 1381
									label, -- 1381
									insertText, -- 1381
									"field" -- 1381
								} -- 1381
								_len_0 = _len_0 + 1 -- 1381
							end -- 1380
							suggestions = _accum_0 -- 1380
						end -- 1380
						return { -- 1382
							success = true, -- 1382
							suggestions = suggestions -- 1382
						} -- 1382
					end -- 1379
				end -- 1336
			end -- 1273
		end -- 1273
	end -- 1273
	return { -- 1272
		success = false -- 1272
	} -- 1272
end) -- 1272
local getUploadFilename -- 1384
getUploadFilename = function(req, multipartFilename) -- 1384
	local filename = req.params.name -- 1385
	if not (type(filename) == "string" and filename ~= "") then -- 1386
		filename = multipartFilename -- 1386
	end -- 1386
	if not (type(filename) == "string" and filename ~= "") then -- 1387
		return -- 1387
	end -- 1387
	if filename:sub(1, 1) == "/" or filename:sub(-1) == "/" or filename:find("//", 1, true) or filename:find("\\", 1, true) or filename:find(":", 1, true) or filename:find("\0", 1, true) then -- 1390
		return -- 1390
	end -- 1390
	local parts -- 1391
	do -- 1391
		local _accum_0 = { } -- 1391
		local _len_0 = 1 -- 1391
		for part in filename:gmatch("[^/]+") do -- 1391
			_accum_0[_len_0] = part -- 1391
			_len_0 = _len_0 + 1 -- 1391
		end -- 1391
		parts = _accum_0 -- 1391
	end -- 1391
	if #parts == 0 then -- 1392
		return -- 1392
	end -- 1392
	for _index_0 = 1, #parts do -- 1393
		local part = parts[_index_0] -- 1393
		if part == "." or part == ".." or part == "" then -- 1394
			return -- 1394
		end -- 1394
	end -- 1393
	return filename -- 1395
end -- 1384
HttpServer:upload("/upload", function(req, multipartFilename) -- 1399
	do -- 1400
		local _type_0 = type(req) -- 1400
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1400
		if _tab_0 then -- 1400
			local path -- 1400
			do -- 1400
				local _obj_0 = req.params -- 1400
				local _type_1 = type(_obj_0) -- 1400
				if "table" == _type_1 or "userdata" == _type_1 then -- 1400
					path = _obj_0.path -- 1400
				end -- 1400
			end -- 1400
			if path ~= nil then -- 1400
				local filename = getUploadFilename(req, multipartFilename) -- 1401
				if filename then -- 1401
					local uploadPath = Path(Content.writablePath, ".upload") -- 1402
					if not Content:exist(uploadPath) then -- 1403
						Content:mkdir(uploadPath) -- 1404
					end -- 1403
					local targetPath = Path(uploadPath, filename) -- 1405
					Content:mkdir(Path:getPath(targetPath)) -- 1406
					return targetPath -- 1407
				end -- 1401
			end -- 1400
		end -- 1400
	end -- 1400
	return nil -- 1399
end, function(req, file) -- 1408
	do -- 1409
		local _type_0 = type(req) -- 1409
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1409
		if _tab_0 then -- 1409
			local path -- 1409
			do -- 1409
				local _obj_0 = req.params -- 1409
				local _type_1 = type(_obj_0) -- 1409
				if "table" == _type_1 or "userdata" == _type_1 then -- 1409
					path = _obj_0.path -- 1409
				end -- 1409
			end -- 1409
			if path ~= nil then -- 1409
				path = Path(Content.writablePath, path) -- 1410
				if Content:exist(path) then -- 1411
					local uploadPath = Path(Content.writablePath, ".upload") -- 1412
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1413
					Content:mkdir(Path:getPath(targetPath)) -- 1414
					if Content:move(file, targetPath) then -- 1415
						return true -- 1416
					end -- 1415
				end -- 1411
			end -- 1409
		end -- 1409
	end -- 1409
	return false -- 1408
end) -- 1397
HttpServer:post("/list", function(req) -- 1419
	do -- 1420
		local _type_0 = type(req) -- 1420
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1420
		if _tab_0 then -- 1420
			local path -- 1420
			do -- 1420
				local _obj_0 = req.body -- 1420
				local _type_1 = type(_obj_0) -- 1420
				if "table" == _type_1 or "userdata" == _type_1 then -- 1420
					path = _obj_0.path -- 1420
				end -- 1420
			end -- 1420
			if path ~= nil then -- 1420
				if Content:exist(path) then -- 1421
					local files = { } -- 1422
					local visitAssets -- 1423
					visitAssets = function(path, folder) -- 1423
						local dirs = Content:getDirs(path) -- 1424
						for _index_0 = 1, #dirs do -- 1425
							local dir = dirs[_index_0] -- 1425
							if dir:match("^%.") or dir == "node_modules" then -- 1426
								goto _continue_0 -- 1426
							end -- 1426
							local current -- 1427
							if folder == "" then -- 1427
								current = dir -- 1428
							else -- 1430
								current = Path(folder, dir) -- 1430
							end -- 1427
							files[#files + 1] = current -- 1431
							visitAssets(Path(path, dir), current) -- 1432
							::_continue_0:: -- 1426
						end -- 1425
						local fs = Content:getFiles(path) -- 1433
						for _index_0 = 1, #fs do -- 1434
							local f = fs[_index_0] -- 1434
							if (".DS_Store" == f) then -- 1435
								goto _continue_1 -- 1436
							end -- 1435
							if folder == "" then -- 1437
								files[#files + 1] = f -- 1438
							else -- 1440
								files[#files + 1] = Path(folder, f) -- 1440
							end -- 1437
							::_continue_1:: -- 1435
						end -- 1434
					end -- 1423
					visitAssets(path, "") -- 1441
					if #files == 0 then -- 1442
						files = nil -- 1442
					end -- 1442
					return { -- 1443
						success = true, -- 1443
						files = files -- 1443
					} -- 1443
				end -- 1421
			end -- 1420
		end -- 1420
	end -- 1420
	return { -- 1419
		success = false -- 1419
	} -- 1419
end) -- 1419
HttpServer:post("/info", function(req) -- 1445
	local Entry = require("Script.Dev.Entry") -- 1446
	local config = Entry.getConfig() -- 1447
	do -- 1448
		local _type_0 = type(req) -- 1448
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1448
		if _tab_0 then -- 1448
			local webIDETourCompleted -- 1448
			do -- 1448
				local _obj_0 = req.body -- 1448
				local _type_1 = type(_obj_0) -- 1448
				if "table" == _type_1 or "userdata" == _type_1 then -- 1448
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1448
				end -- 1448
			end -- 1448
			if webIDETourCompleted ~= nil then -- 1448
				config.webIDETourCompleted = webIDETourCompleted == true -- 1449
			end -- 1448
		end -- 1448
	end -- 1448
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1450
	local engineDev = Entry.getEngineDev() -- 1451
	Entry.connectWebIDE() -- 1452
	return { -- 1454
		platform = App.platform, -- 1454
		locale = App.locale, -- 1455
		version = App.version, -- 1456
		engineDev = engineDev, -- 1457
		webProfiler = webProfiler, -- 1458
		drawerWidth = drawerWidth, -- 1459
		webIDETourCompleted = webIDETourCompleted == true -- 1460
	} -- 1453
end) -- 1445
local ensureLLMConfigTable -- 1462
ensureLLMConfigTable = function() -- 1462
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1463
	if columns and #columns > 0 then -- 1464
		local expected = { -- 1466
			id = true, -- 1466
			name = true, -- 1467
			url = true, -- 1468
			model = true, -- 1469
			api_key = true, -- 1470
			context_window = true, -- 1471
			temperature = true, -- 1472
			max_tokens = true, -- 1473
			reasoning_effort = true, -- 1474
			custom_options = true, -- 1475
			supports_function_calling = true, -- 1476
			active = true, -- 1477
			created_at = true, -- 1478
			updated_at = true -- 1479
		} -- 1465
		local existing = { } -- 1481
		local valid = true -- 1482
		for _index_0 = 1, #columns do -- 1483
			local row = columns[_index_0] -- 1483
			local columnName = tostring(row[2]) -- 1484
			existing[columnName] = true -- 1485
			if not expected[columnName] then -- 1486
				valid = false -- 1487
				break -- 1488
			end -- 1486
		end -- 1483
		if valid then -- 1489
			if not existing.context_window then -- 1490
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1491
			end -- 1490
			if not existing.temperature then -- 1492
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1493
			end -- 1492
			if not existing.max_tokens then -- 1494
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 64000") -- 1495
			end -- 1494
			if not existing.reasoning_effort then -- 1496
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1497
			end -- 1496
			if not existing.custom_options then -- 1498
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1499
			end -- 1498
			if not existing.supports_function_calling then -- 1500
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1501
			end -- 1500
		else -- 1503
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1503
		end -- 1489
	end -- 1464
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
	]]) -- 1504
	return require("Agent.LLMConfigMigration").upgradeLLMConfig() -- 1523
end -- 1462
local normalizeContextWindow -- 1525
normalizeContextWindow = function(value) -- 1525
	local contextWindow = tonumber(value) -- 1526
	if contextWindow == nil or contextWindow < 64000 then -- 1527
		return 64000 -- 1528
	end -- 1527
	return math.max(64000, math.floor(contextWindow)) -- 1529
end -- 1525
local normalizeTemperature -- 1531
normalizeTemperature = function(value) -- 1531
	local temperature = tonumber(value) -- 1532
	if temperature == nil then -- 1533
		return 0.1 -- 1534
	end -- 1533
	return math.max(0, math.min(2, temperature)) -- 1535
end -- 1531
local normalizeMaxTokens -- 1537
normalizeMaxTokens = function(value) -- 1537
	local maxTokens = tonumber(value) -- 1538
	if maxTokens == nil or maxTokens < 1 then -- 1539
		return 64000 -- 1540
	end -- 1539
	return math.max(1, math.floor(maxTokens)) -- 1541
end -- 1537
local normalizeReasoningEffort -- 1543
normalizeReasoningEffort = function(value) -- 1543
	if value == nil then -- 1544
		return "" -- 1545
	end -- 1544
	local effort = tostring(value) -- 1546
	return effort:match("^%s*(.-)%s*$") or "" -- 1547
end -- 1543
local normalizeCustomOptions -- 1549
normalizeCustomOptions = function(value) -- 1549
	if value == nil then -- 1550
		return "" -- 1551
	end -- 1550
	local options = tostring(value) -- 1552
	options = options:match("^%s*(.-)%s*$") or "" -- 1553
	return options -- 1554
end -- 1549
local validateCustomOptions -- 1556
validateCustomOptions = function(value) -- 1556
	local options = normalizeCustomOptions(value) -- 1557
	if options == "" then -- 1558
		return true -- 1558
	end -- 1558
	if not options:match("^%s*{") then -- 1559
		return false -- 1559
	end -- 1559
	local decoded = json.decode(options) -- 1560
	return type(decoded) == "table" -- 1561
end -- 1556
HttpServer:post("/llm/list", function() -- 1563
	ensureLLMConfigTable() -- 1564
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1565
	local items -- 1569
	if rows and #rows > 0 then -- 1569
		local _accum_0 = { } -- 1570
		local _len_0 = 1 -- 1570
		for _index_0 = 1, #rows do -- 1570
			local _des_0 = rows[_index_0] -- 1570
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1570
			_accum_0[_len_0] = { -- 1571
				id = id, -- 1571
				name = name, -- 1571
				url = url, -- 1571
				model = model, -- 1571
				key = key, -- 1571
				contextWindow = normalizeContextWindow(contextWindow), -- 1571
				temperature = normalizeTemperature(temperature), -- 1571
				maxTokens = normalizeMaxTokens(maxTokens), -- 1571
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1571
				customOptions = normalizeCustomOptions(customOptions), -- 1571
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1571
			} -- 1571
			_len_0 = _len_0 + 1 -- 1571
		end -- 1570
		items = _accum_0 -- 1569
	end -- 1569
	return { -- 1572
		success = true, -- 1572
		items = items -- 1572
	} -- 1572
end) -- 1563
HttpServer:post("/llm/create", function(req) -- 1574
	ensureLLMConfigTable() -- 1575
	do -- 1576
		local _type_0 = type(req) -- 1576
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1576
		if _tab_0 then -- 1576
			local body = req.body -- 1576
			if body ~= nil then -- 1576
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1577
				local now = os.time() -- 1578
				if name == nil or url == nil or model == nil or key == nil then -- 1579
					return invalidArguments -- 1580
				end -- 1579
				contextWindow = normalizeContextWindow(contextWindow) -- 1581
				temperature = normalizeTemperature(temperature) -- 1582
				maxTokens = normalizeMaxTokens(maxTokens) -- 1583
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1584
				customOptions = normalizeCustomOptions(customOptions) -- 1585
				if not validateCustomOptions(customOptions) then -- 1586
					return { -- 1586
						success = false, -- 1586
						message = "customOptions must be a JSON object" -- 1586
					} -- 1586
				end -- 1586
				if supportsFunctionCalling == false then -- 1587
					supportsFunctionCalling = 0 -- 1587
				else -- 1587
					supportsFunctionCalling = 1 -- 1587
				end -- 1587
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1594
					tostring(name), -- 1594
					tostring(url), -- 1595
					tostring(model), -- 1596
					tostring(key), -- 1597
					contextWindow, -- 1598
					temperature, -- 1599
					maxTokens, -- 1600
					reasoningEffort, -- 1601
					customOptions, -- 1602
					supportsFunctionCalling, -- 1603
					1, -- 1604
					now, -- 1605
					now -- 1606
				}) -- 1588
				return { -- 1608
					success = affected >= 0 -- 1608
				} -- 1608
			end -- 1576
		end -- 1576
	end -- 1576
	return invalidArguments -- 1574
end) -- 1574
HttpServer:post("/llm/update", function(req) -- 1610
	ensureLLMConfigTable() -- 1611
	do -- 1612
		local _type_0 = type(req) -- 1612
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1612
		if _tab_0 then -- 1612
			local body = req.body -- 1612
			if body ~= nil then -- 1612
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1613
				local now = os.time() -- 1614
				id = tonumber(id) -- 1615
				if id == nil then -- 1616
					return invalidArguments -- 1616
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
				if supportsFunctionCalling == false then -- 1623
					supportsFunctionCalling = 0 -- 1623
				else -- 1623
					supportsFunctionCalling = 1 -- 1623
				end -- 1623
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1628
					tostring(name), -- 1628
					tostring(url), -- 1629
					tostring(model), -- 1630
					tostring(key), -- 1631
					contextWindow, -- 1632
					temperature, -- 1633
					maxTokens, -- 1634
					reasoningEffort, -- 1635
					customOptions, -- 1636
					supportsFunctionCalling, -- 1637
					now, -- 1638
					id -- 1639
				}) -- 1624
				return { -- 1641
					success = affected >= 0 -- 1641
				} -- 1641
			end -- 1612
		end -- 1612
	end -- 1612
	return invalidArguments -- 1610
end) -- 1610
HttpServer:post("/llm/delete", function(req) -- 1643
	ensureLLMConfigTable() -- 1644
	do -- 1645
		local _type_0 = type(req) -- 1645
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1645
		if _tab_0 then -- 1645
			local id -- 1645
			do -- 1645
				local _obj_0 = req.body -- 1645
				local _type_1 = type(_obj_0) -- 1645
				if "table" == _type_1 or "userdata" == _type_1 then -- 1645
					id = _obj_0.id -- 1645
				end -- 1645
			end -- 1645
			if id ~= nil then -- 1645
				id = tonumber(id) -- 1646
				if id == nil then -- 1647
					return invalidArguments -- 1647
				end -- 1647
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1648
					id -- 1648
				}) -- 1648
				return { -- 1649
					success = affected >= 0 -- 1649
				} -- 1649
			end -- 1645
		end -- 1645
	end -- 1645
	return invalidArguments -- 1643
end) -- 1643
HttpServer:post("/local-agent/list", function() -- 1651
	return { -- 1652
		success = true, -- 1652
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1652
		items = AgentLocalAgent.listConfigs() -- 1652
	} -- 1652
end) -- 1651
HttpServer:post("/local-agent/save", function(req) -- 1654
	do -- 1655
		local _type_0 = type(req) -- 1655
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1655
		if _tab_0 then -- 1655
			local body = req.body -- 1655
			if body ~= nil then -- 1655
				return AgentLocalAgent.saveConfig(body) -- 1656
			end -- 1655
		end -- 1655
	end -- 1655
	return invalidArguments -- 1654
end) -- 1654
HttpServer:post("/local-agent/delete", function(req) -- 1658
	do -- 1659
		local _type_0 = type(req) -- 1659
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1659
		if _tab_0 then -- 1659
			local id -- 1659
			do -- 1659
				local _obj_0 = req.body -- 1659
				local _type_1 = type(_obj_0) -- 1659
				if "table" == _type_1 or "userdata" == _type_1 then -- 1659
					id = _obj_0.id -- 1659
				end -- 1659
			end -- 1659
			if id ~= nil then -- 1659
				return AgentLocalAgent.deleteConfig(id) -- 1660
			end -- 1659
		end -- 1659
	end -- 1659
	return invalidArguments -- 1658
end) -- 1658
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1662
	do -- 1663
		local _type_0 = type(req) -- 1663
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1663
		if _tab_0 then -- 1663
			local id -- 1663
			do -- 1663
				local _obj_0 = req.body -- 1663
				local _type_1 = type(_obj_0) -- 1663
				if "table" == _type_1 or "userdata" == _type_1 then -- 1663
					id = _obj_0.id -- 1663
				end -- 1663
			end -- 1663
			if id ~= nil then -- 1663
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1664
			end -- 1663
		end -- 1663
	end -- 1663
	return invalidArguments -- 1662
end) -- 1662
HttpServer:post("/stat", function(req) -- 1666
	do -- 1667
		local _type_0 = type(req) -- 1667
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1667
		if _tab_0 then -- 1667
			local path -- 1667
			do -- 1667
				local _obj_0 = req.body -- 1667
				local _type_1 = type(_obj_0) -- 1667
				if "table" == _type_1 or "userdata" == _type_1 then -- 1667
					path = _obj_0.path -- 1667
				end -- 1667
			end -- 1667
			if path ~= nil then -- 1667
				if not Content:exist(path) then -- 1668
					return { -- 1669
						success = false, -- 1669
						message = "target not existed" -- 1669
					} -- 1669
				end -- 1668
				if Content:isdir(path) then -- 1670
					return { -- 1671
						success = false, -- 1671
						message = "failed to stat a directory" -- 1671
					} -- 1671
				end -- 1670
				local size, isBinary = Content:getAttr(path) -- 1672
				if size then -- 1672
					return { -- 1673
						success = true, -- 1673
						size = size, -- 1673
						isBinary = isBinary -- 1673
					} -- 1673
				end -- 1672
			end -- 1667
		end -- 1667
	end -- 1667
	return { -- 1666
		success = false, -- 1666
		message = "failed to stat" -- 1666
	} -- 1666
end) -- 1666
HttpServer:post("/new", function(req) -- 1675
	do -- 1676
		local _type_0 = type(req) -- 1676
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1676
		if _tab_0 then -- 1676
			local path -- 1676
			do -- 1676
				local _obj_0 = req.body -- 1676
				local _type_1 = type(_obj_0) -- 1676
				if "table" == _type_1 or "userdata" == _type_1 then -- 1676
					path = _obj_0.path -- 1676
				end -- 1676
			end -- 1676
			local content -- 1676
			do -- 1676
				local _obj_0 = req.body -- 1676
				local _type_1 = type(_obj_0) -- 1676
				if "table" == _type_1 or "userdata" == _type_1 then -- 1676
					content = _obj_0.content -- 1676
				end -- 1676
			end -- 1676
			local folder -- 1676
			do -- 1676
				local _obj_0 = req.body -- 1676
				local _type_1 = type(_obj_0) -- 1676
				if "table" == _type_1 or "userdata" == _type_1 then -- 1676
					folder = _obj_0.folder -- 1676
				end -- 1676
			end -- 1676
			if path ~= nil and content ~= nil and folder ~= nil then -- 1676
				if Content:exist(path) then -- 1677
					return { -- 1678
						success = false, -- 1678
						message = "TargetExisted" -- 1678
					} -- 1678
				end -- 1677
				local parent = Path:getPath(path) -- 1679
				local files = Content:getFiles(parent) -- 1680
				if folder then -- 1681
					local name = Path:getFilename(path):lower() -- 1682
					for _index_0 = 1, #files do -- 1683
						local file = files[_index_0] -- 1683
						if name == Path:getFilename(file):lower() then -- 1684
							return { -- 1685
								success = false, -- 1685
								message = "TargetExisted" -- 1685
							} -- 1685
						end -- 1684
					end -- 1683
					if Content:mkdir(path) then -- 1686
						return { -- 1687
							success = true -- 1687
						} -- 1687
					end -- 1686
				else -- 1689
					local name = Path:getName(path):lower() -- 1689
					for _index_0 = 1, #files do -- 1690
						local file = files[_index_0] -- 1690
						if name == Path:getName(file):lower() then -- 1691
							local ext = Path:getExt(file) -- 1692
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1693
								goto _continue_0 -- 1694
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1695
								goto _continue_0 -- 1696
							end -- 1693
							return { -- 1697
								success = false, -- 1697
								message = "SourceExisted" -- 1697
							} -- 1697
						end -- 1691
						::_continue_0:: -- 1691
					end -- 1690
					if Content:save(path, content) then -- 1698
						return { -- 1699
							success = true -- 1699
						} -- 1699
					end -- 1698
				end -- 1681
			end -- 1676
		end -- 1676
	end -- 1676
	return { -- 1675
		success = false, -- 1675
		message = "Failed" -- 1675
	} -- 1675
end) -- 1675
local deleteAsset -- 1701
deleteAsset = function(path) -- 1701
	if not Content:exist(path) then -- 1702
		return false -- 1702
	end -- 1702
	local projectRoot -- 1703
	if Content:isdir(path) and isProjectRootDir(path) then -- 1703
		projectRoot = path -- 1703
	else -- 1703
		projectRoot = nil -- 1703
	end -- 1703
	local parent = Path:getPath(path) -- 1704
	local files = Content:getFiles(parent) -- 1705
	local name = Path:getName(path):lower() -- 1706
	local ext = Path:getExt(path) -- 1707
	for _index_0 = 1, #files do -- 1708
		local file = files[_index_0] -- 1708
		if name == Path:getName(file):lower() then -- 1709
			local _exp_0 = Path:getExt(file) -- 1710
			if "tl" == _exp_0 then -- 1710
				if ("vs" == ext) then -- 1710
					Content:remove(Path(parent, file)) -- 1711
				end -- 1710
			elseif "lua" == _exp_0 then -- 1712
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1712
					Content:remove(Path(parent, file)) -- 1713
				end -- 1712
			end -- 1710
		end -- 1709
	end -- 1708
	if Content:remove(path) then -- 1714
		if projectRoot then -- 1715
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1716
		end -- 1715
		return true -- 1717
	end -- 1714
	return false -- 1718
end -- 1701
local moveAsset -- 1720
moveAsset = function(old, new) -- 1720
	if not (Content:exist(old) and not Content:exist(new)) then -- 1721
		return false -- 1721
	end -- 1721
	local renamedDir = Content:isdir(old) -- 1722
	local parent = Path:getPath(new) -- 1723
	local files = Content:getFiles(parent) -- 1724
	if renamedDir then -- 1725
		local name = Path:getFilename(new):lower() -- 1726
		for _index_0 = 1, #files do -- 1727
			local file = files[_index_0] -- 1727
			if name == Path:getFilename(file):lower() then -- 1728
				return false -- 1729
			end -- 1728
		end -- 1727
	else -- 1731
		local name = Path:getName(new):lower() -- 1731
		local ext = Path:getExt(new) -- 1732
		for _index_0 = 1, #files do -- 1733
			local file = files[_index_0] -- 1733
			if name == Path:getName(file):lower() then -- 1734
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1735
					goto _continue_0 -- 1736
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1737
					goto _continue_0 -- 1738
				end -- 1735
				return false -- 1739
			end -- 1734
			::_continue_0:: -- 1734
		end -- 1733
	end -- 1725
	if not Content:move(old, new) then -- 1740
		return false -- 1740
	end -- 1740
	if renamedDir then -- 1741
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1742
	end -- 1741
	local newParent = Path:getPath(new) -- 1743
	parent = Path:getPath(old) -- 1744
	files = Content:getFiles(parent) -- 1745
	local newName = Path:getName(new) -- 1746
	local oldName = Path:getName(old) -- 1747
	local name = oldName:lower() -- 1748
	local ext = Path:getExt(old) -- 1749
	for _index_0 = 1, #files do -- 1750
		local file = files[_index_0] -- 1750
		if name == Path:getName(file):lower() then -- 1751
			local _exp_0 = Path:getExt(file) -- 1752
			if "tl" == _exp_0 then -- 1752
				if ("vs" == ext) then -- 1752
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1753
				end -- 1752
			elseif "lua" == _exp_0 then -- 1754
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1754
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1755
				end -- 1754
			end -- 1752
		end -- 1751
	end -- 1750
	return true -- 1756
end -- 1720
HttpServer:post("/delete", function(req) -- 1758
	do -- 1759
		local _type_0 = type(req) -- 1759
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1759
		if _tab_0 then -- 1759
			local path -- 1759
			do -- 1759
				local _obj_0 = req.body -- 1759
				local _type_1 = type(_obj_0) -- 1759
				if "table" == _type_1 or "userdata" == _type_1 then -- 1759
					path = _obj_0.path -- 1759
				end -- 1759
			end -- 1759
			if path ~= nil then -- 1759
				if deleteAsset(path) then -- 1760
					return { -- 1760
						success = true -- 1760
					} -- 1760
				end -- 1760
			end -- 1759
		end -- 1759
	end -- 1759
	return { -- 1758
		success = false -- 1758
	} -- 1758
end) -- 1758
HttpServer:post("/rename", function(req) -- 1762
	do -- 1763
		local _type_0 = type(req) -- 1763
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1763
		if _tab_0 then -- 1763
			local old -- 1763
			do -- 1763
				local _obj_0 = req.body -- 1763
				local _type_1 = type(_obj_0) -- 1763
				if "table" == _type_1 or "userdata" == _type_1 then -- 1763
					old = _obj_0.old -- 1763
				end -- 1763
			end -- 1763
			local new -- 1763
			do -- 1763
				local _obj_0 = req.body -- 1763
				local _type_1 = type(_obj_0) -- 1763
				if "table" == _type_1 or "userdata" == _type_1 then -- 1763
					new = _obj_0.new -- 1763
				end -- 1763
			end -- 1763
			if old ~= nil and new ~= nil then -- 1763
				if moveAsset(old, new) then -- 1764
					return { -- 1764
						success = true -- 1764
					} -- 1764
				end -- 1764
			end -- 1763
		end -- 1763
	end -- 1763
	return { -- 1762
		success = false -- 1762
	} -- 1762
end) -- 1762
local normalizeAssetPaths -- 1766
normalizeAssetPaths = function(paths) -- 1766
	if not (type(paths) == "table") then -- 1767
		return nil -- 1767
	end -- 1767
	local unique = { } -- 1768
	local candidates = { } -- 1769
	for _index_0 = 1, #paths do -- 1770
		local path = paths[_index_0] -- 1770
		if not (type(path) == "string") then -- 1771
			return nil -- 1771
		end -- 1771
		local relative = relativeToRoot(path, Content.writablePath) -- 1772
		if relative == nil or relative == "" or not Content:exist(path) then -- 1773
			return nil -- 1773
		end -- 1773
		if not unique[path] then -- 1774
			unique[path] = true -- 1775
			candidates[#candidates + 1] = path -- 1776
		end -- 1774
	end -- 1770
	table.sort(candidates, function(a, b) -- 1777
		return #a < #b -- 1777
	end) -- 1777
	local result = { } -- 1778
	for _index_0 = 1, #candidates do -- 1779
		local path = candidates[_index_0] -- 1779
		local contained = false -- 1780
		for _index_1 = 1, #result do -- 1781
			local parent = result[_index_1] -- 1781
			if relativeToRoot(path, parent) ~= nil then -- 1782
				contained = true -- 1783
				break -- 1784
			end -- 1782
		end -- 1781
		if not contained then -- 1785
			result[#result + 1] = path -- 1785
		end -- 1785
	end -- 1779
	return result -- 1786
end -- 1766
HttpServer:postSchedule("/assets/batch", function(req) -- 1788
	do -- 1789
		local _type_0 = type(req) -- 1789
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1789
		if _tab_0 then -- 1789
			local operation -- 1789
			do -- 1789
				local _obj_0 = req.body -- 1789
				local _type_1 = type(_obj_0) -- 1789
				if "table" == _type_1 or "userdata" == _type_1 then -- 1789
					operation = _obj_0.operation -- 1789
				end -- 1789
			end -- 1789
			local sources -- 1789
			do -- 1789
				local _obj_0 = req.body -- 1789
				local _type_1 = type(_obj_0) -- 1789
				if "table" == _type_1 or "userdata" == _type_1 then -- 1789
					sources = _obj_0.sources -- 1789
				end -- 1789
			end -- 1789
			if operation ~= nil and sources ~= nil then -- 1789
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1790
					return { -- 1790
						success = false, -- 1790
						message = "invalid operation" -- 1790
					} -- 1790
				end -- 1790
				sources = normalizeAssetPaths(sources) -- 1791
				if not (sources and #sources > 0) then -- 1792
					return { -- 1792
						success = false, -- 1792
						message = "invalid sources" -- 1792
					} -- 1792
				end -- 1792
				local target = req.body.target -- 1793
				local destinations = { } -- 1794
				if operation ~= "delete" then -- 1795
					if not (type(target) == "string") then -- 1796
						return { -- 1796
							success = false, -- 1796
							message = "invalid target" -- 1796
						} -- 1796
					end -- 1796
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1797
					if targetRelative == nil then -- 1798
						return { -- 1798
							success = false, -- 1798
							message = "invalid target" -- 1798
						} -- 1798
					end -- 1798
					if not (Content:exist(target) and Content:isdir(target)) then -- 1799
						return { -- 1799
							success = false, -- 1799
							message = "invalid target" -- 1799
						} -- 1799
					end -- 1799
					for _index_0 = 1, #sources do -- 1800
						local source = sources[_index_0] -- 1800
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1801
							return { -- 1802
								success = false, -- 1802
								message = "target inside source" -- 1802
							} -- 1802
						end -- 1801
						local destination = Path(target, Path:getFilename(source)) -- 1803
						if Content:exist(destination) then -- 1804
							return { -- 1804
								success = false, -- 1804
								message = "target existed" -- 1804
							} -- 1804
						end -- 1804
						if destinations[destination] then -- 1805
							return { -- 1805
								success = false, -- 1805
								message = "duplicate target" -- 1805
							} -- 1805
						end -- 1805
						destinations[destination] = true -- 1806
					end -- 1800
				end -- 1795
				local changes = { } -- 1807
				local affectedSet = { } -- 1808
				local affectedDirectories = { } -- 1809
				local addAffected -- 1810
				addAffected = function(dir) -- 1810
					if affectedSet[dir] then -- 1811
						return -- 1811
					end -- 1811
					affectedSet[dir] = true -- 1812
					affectedDirectories[#affectedDirectories + 1] = dir -- 1813
				end -- 1810
				if operation ~= "delete" then -- 1814
					addAffected(target) -- 1814
				end -- 1814
				for _index_0 = 1, #sources do -- 1815
					local source = sources[_index_0] -- 1815
					addAffected(Path:getPath(source)) -- 1816
					if operation == "delete" then -- 1817
						if not deleteAsset(source) then -- 1818
							return { -- 1818
								success = false, -- 1818
								message = "delete failed", -- 1818
								changes = changes, -- 1818
								affectedDirectories = affectedDirectories -- 1818
							} -- 1818
						end -- 1818
						changes[#changes + 1] = { -- 1819
							old = source -- 1819
						} -- 1819
					else -- 1821
						local destination = Path(target, Path:getFilename(source)) -- 1821
						local ok -- 1822
						if operation == "copy" then -- 1822
							ok = Content:copyAsync(source, destination) -- 1823
						else -- 1825
							ok = moveAsset(source, destination) -- 1825
						end -- 1822
						if not ok then -- 1826
							return { -- 1826
								success = false, -- 1826
								message = operation .. " failed", -- 1826
								changes = changes, -- 1826
								affectedDirectories = affectedDirectories -- 1826
							} -- 1826
						end -- 1826
						changes[#changes + 1] = { -- 1827
							old = source, -- 1827
							new = destination -- 1827
						} -- 1827
					end -- 1817
				end -- 1815
				return { -- 1828
					success = true, -- 1828
					changes = changes, -- 1828
					affectedDirectories = affectedDirectories -- 1828
				} -- 1828
			end -- 1789
		end -- 1789
	end -- 1789
	return { -- 1788
		success = false, -- 1788
		message = "invalid request" -- 1788
	} -- 1788
end) -- 1788
local withProjectSearchPaths -- 1830
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1830
	local fallbackPaths = { } -- 1831
	local addFallback -- 1832
	addFallback = function(dir) -- 1832
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1832
			fallbackPaths[#fallbackPaths + 1] = dir -- 1832
		end -- 1832
	end -- 1832
	if projectRoot and projectRoot ~= "" then -- 1833
		addFallback(Path(projectRoot, "Script")) -- 1834
		addFallback(projectRoot) -- 1835
	end -- 1833
	if projFile then -- 1836
		local projDir = getProjectDirFromFile(projFile) -- 1837
		if projDir then -- 1837
			addFallback(Path(projDir, "Script")) -- 1838
			addFallback(projDir) -- 1839
		else -- 1841
			addFallback(Path:getPath(projFile)) -- 1841
		end -- 1837
	end -- 1836
	if not (#fallbackPaths > 0) then -- 1842
		return fn() -- 1842
	end -- 1842
	local searchPaths = Content.searchPaths -- 1843
	for _index_0 = 1, #fallbackPaths do -- 1844
		local dir = fallbackPaths[_index_0] -- 1844
		Content:addSearchPath(dir) -- 1844
	end -- 1844
	local _ <close> = setmetatable({ }, { -- 1845
		__close = function() -- 1845
			Content.searchPaths = searchPaths -- 1845
		end -- 1845
	}) -- 1845
	return fn() -- 1846
end -- 1830
HttpServer:post("/exist", function(req) -- 1847
	do -- 1848
		local _type_0 = type(req) -- 1848
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1848
		if _tab_0 then -- 1848
			local file -- 1848
			do -- 1848
				local _obj_0 = req.body -- 1848
				local _type_1 = type(_obj_0) -- 1848
				if "table" == _type_1 or "userdata" == _type_1 then -- 1848
					file = _obj_0.file -- 1848
				end -- 1848
			end -- 1848
			if file ~= nil then -- 1848
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1849
					return { -- 1850
						success = Content:exist(file) -- 1850
					} -- 1850
				end) -- 1849
			end -- 1848
		end -- 1848
	end -- 1848
	return { -- 1847
		success = false -- 1847
	} -- 1847
end) -- 1847
HttpServer:postSchedule("/read", function(req) -- 1851
	do -- 1852
		local _type_0 = type(req) -- 1852
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1852
		if _tab_0 then -- 1852
			local path -- 1852
			do -- 1852
				local _obj_0 = req.body -- 1852
				local _type_1 = type(_obj_0) -- 1852
				if "table" == _type_1 or "userdata" == _type_1 then -- 1852
					path = _obj_0.path -- 1852
				end -- 1852
			end -- 1852
			if path ~= nil then -- 1852
				local readFile -- 1853
				readFile = function() -- 1853
					if Content:exist(path) and not Content:isdir(path) then -- 1854
						local content = Content:loadAsync(path) -- 1855
						if content then -- 1855
							return { -- 1856
								content = content, -- 1856
								success = true, -- 1856
								fullPath = Content:getFullPath(path) -- 1856
							} -- 1856
						end -- 1855
					end -- 1854
					return nil -- 1853
				end -- 1853
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1857
				if result then -- 1857
					return result -- 1857
				end -- 1857
			end -- 1852
		end -- 1852
	end -- 1852
	return { -- 1851
		success = false -- 1851
	} -- 1851
end) -- 1851
local agentDocLanguage -- 1859
agentDocLanguage = function(language) -- 1859
	if language == "zh-Hans" then -- 1860
		return "zh" -- 1860
	else -- 1860
		return "en" -- 1860
	end -- 1860
end -- 1859
HttpServer:postSchedule("/doc/search", function(req) -- 1862
	local body = req.body or { } -- 1863
	local language = body.docLanguage -- 1864
	if not (("en" == language or "zh-Hans" == language)) then -- 1865
		return { -- 1865
			success = false, -- 1865
			message = "unsupported doc language" -- 1865
		} -- 1865
	end -- 1865
	local docType = body.docType -- 1866
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1867
		return { -- 1867
			success = false, -- 1867
			message = "unsupported doc type" -- 1867
		} -- 1867
	end -- 1867
	local codeLanguage = body.programmingLanguage -- 1868
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1869
		return { -- 1869
			success = false, -- 1869
			message = "unsupported programming language" -- 1869
		} -- 1869
	end -- 1869
	if not body.pattern then -- 1870
		return { -- 1870
			success = false, -- 1870
			message = "missing pattern" -- 1870
		} -- 1870
	end -- 1870
	local result = nil -- 1871
	AgentTools.searchDoraDocHttp({ -- 1873
		pattern = body.pattern, -- 1873
		docLanguage = agentDocLanguage(language), -- 1874
		docType = docType, -- 1875
		programmingLanguage = codeLanguage, -- 1876
		limit = body.limit, -- 1877
		useRegex = body.useRegex, -- 1878
		caseSensitive = body.caseSensitive, -- 1879
		includeContent = body.includeContent, -- 1880
		contentWindow = body.contentWindow -- 1881
	}, function(res) -- 1882
		result = res -- 1883
	end) -- 1872
	wait(function() -- 1884
		return result ~= nil -- 1884
	end) -- 1884
	if result and result.success then -- 1885
		result.docLanguage = language -- 1886
	end -- 1885
	if result then -- 1887
		return result -- 1888
	else -- 1890
		return { -- 1890
			success = false, -- 1890
			message = "doc search failed" -- 1890
		} -- 1890
	end -- 1887
	return { -- 1862
		success = false, -- 1862
		message = "invalid call" -- 1862
	} -- 1862
end) -- 1862
HttpServer:postSchedule("/doc/read", function(req) -- 1892
	local body = req.body or { } -- 1893
	local language = body.docLanguage -- 1894
	if not (("en" == language or "zh-Hans" == language)) then -- 1895
		return { -- 1895
			success = false, -- 1895
			message = "unsupported doc language" -- 1895
		} -- 1895
	end -- 1895
	if not body.file then -- 1896
		return { -- 1896
			success = false, -- 1896
			message = "missing file" -- 1896
		} -- 1896
	end -- 1896
	local result = AgentTools.readDoraDoc({ -- 1898
		docLanguage = agentDocLanguage(language), -- 1898
		file = body.file, -- 1899
		startLine = body.startLine, -- 1900
		endLine = body.endLine -- 1901
	}) -- 1897
	if result and result.success then -- 1902
		result.docLanguage = language -- 1903
	end -- 1902
	return result -- 1904
end) -- 1892
HttpServer:get("/read-sync", function(req) -- 1906
	do -- 1907
		local _type_0 = type(req) -- 1907
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1907
		if _tab_0 then -- 1907
			local params = req.params -- 1907
			if params ~= nil then -- 1907
				local path = params.path -- 1908
				local exts -- 1909
				if params.exts then -- 1909
					local _accum_0 = { } -- 1910
					local _len_0 = 1 -- 1910
					for ext in params.exts:gmatch("[^|]*") do -- 1910
						_accum_0[_len_0] = ext -- 1910
						_len_0 = _len_0 + 1 -- 1910
					end -- 1910
					exts = _accum_0 -- 1910
				else -- 1911
					exts = { -- 1911
						"" -- 1911
					} -- 1911
				end -- 1909
				local readFileAt -- 1912
				readFileAt = function(targetPath) -- 1912
					if Content:exist(targetPath) then -- 1913
						local content = Content:load(targetPath) -- 1914
						if content then -- 1914
							return { -- 1915
								content = content, -- 1915
								success = true, -- 1915
								fullPath = Content:getFullPath(targetPath) -- 1915
							} -- 1915
						end -- 1914
					end -- 1913
					return nil -- 1912
				end -- 1912
				local readFile -- 1916
				readFile = function(fallbackPaths) -- 1916
					for _index_0 = 1, #exts do -- 1917
						local ext = exts[_index_0] -- 1917
						local targetPath = path .. ext -- 1918
						if not Content:isAbsolutePath(targetPath) then -- 1919
							for _index_1 = 1, #fallbackPaths do -- 1920
								local fallback = fallbackPaths[_index_1] -- 1920
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1921
								if fallbackResult then -- 1921
									return fallbackResult -- 1922
								end -- 1921
							end -- 1920
						end -- 1919
						local fileResult = readFileAt(targetPath) -- 1923
						if fileResult then -- 1923
							return fileResult -- 1924
						end -- 1923
					end -- 1917
					return nil -- 1916
				end -- 1916
				local fallbackPaths = { } -- 1925
				local fallbackCandidates = { } -- 1926
				do -- 1927
					local projectRoot = req.params.projectRoot -- 1927
					if projectRoot then -- 1927
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1928
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1929
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1930
						end -- 1928
					end -- 1927
				end -- 1927
				do -- 1931
					local projFile = req.params.projFile -- 1931
					if projFile then -- 1931
						local projDir = getProjectDirFromFile(projFile) -- 1932
						if projDir then -- 1932
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1933
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1934
						else -- 1936
							projDir = Path:getPath(projFile) -- 1936
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1937
						end -- 1932
					end -- 1931
				end -- 1931
				for _index_0 = 1, #fallbackCandidates do -- 1938
					local dir = fallbackCandidates[_index_0] -- 1938
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1939
						local exists = false -- 1940
						for _index_1 = 1, #fallbackPaths do -- 1941
							local fallback = fallbackPaths[_index_1] -- 1941
							if fallback == dir then -- 1942
								exists = true -- 1943
								break -- 1944
							end -- 1942
						end -- 1941
						if not exists then -- 1945
							fallbackPaths[#fallbackPaths + 1] = dir -- 1945
						end -- 1945
					end -- 1939
				end -- 1938
				local readResult = readFile(fallbackPaths) -- 1946
				if readResult then -- 1946
					return readResult -- 1947
				end -- 1946
			end -- 1907
		end -- 1907
	end -- 1907
	return { -- 1906
		success = false -- 1906
	} -- 1906
end) -- 1906
local addGeneratedSourceHeader -- 1949
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 1949
	if preserveTIC80 == nil then -- 1949
		preserveTIC80 = false -- 1949
	end -- 1949
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 1950
	if preserveTIC80 then -- 1951
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 1952
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 1953
		end -- 1952
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 1954
	end -- 1951
	return tostring(header) .. "\n" .. tostring(codes) -- 1955
end -- 1949
local compileFileAsync -- 1957
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1957
	if projectRoot == nil then -- 1957
		projectRoot = nil -- 1957
	end -- 1957
	local file = inputFile -- 1958
	local searchPath -- 1959
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1959
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1960
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1964
	elseif not Content:isAbsolutePath(inputFile) then -- 1965
		searchPath = "" -- 1966
	else -- 1967
		local dir = getProjectDirFromFile(inputFile) -- 1967
		if dir then -- 1967
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1968
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1972
		else -- 1974
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1974
			searchPath = "" -- 1977
		end -- 1967
	end -- 1959
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1978
	local yueext = yue.options.extension -- 1979
	local resultCodes = nil -- 1980
	local resultError = nil -- 1981
	do -- 1982
		local _exp_0 = Path:getExt(inputFile) -- 1982
		if yueext == _exp_0 then -- 1982
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1983
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1984
				if not codes then -- 1985
					resultError = err -- 1986
					return -- 1987
				end -- 1985
				local extraGlobal -- 1988
				if isTIC80 then -- 1988
					extraGlobal = tic80APIs -- 1988
				else -- 1988
					extraGlobal = nil -- 1988
				end -- 1988
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1989
				if not success then -- 1990
					resultError = message -- 1991
					return -- 1992
				end -- 1990
				if codes == "" then -- 1993
					resultCodes = "" -- 1994
					return nil -- 1995
				end -- 1993
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 1996
				return resultCodes -- 1997
			end, function(success) -- 1984
				if not success then -- 1998
					Content:remove(outputFile) -- 1999
					if resultCodes == nil then -- 2000
						resultCodes = false -- 2001
					end -- 2000
				end -- 1998
			end) -- 1984
		elseif "tl" == _exp_0 then -- 2002
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 2003
			if isTIC80 then -- 2004
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2005
			end -- 2004
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2006
			if codes then -- 2006
				if isTIC80 then -- 2007
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2008
				end -- 2007
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2009
				Content:saveAsync(outputFile, resultCodes) -- 2010
			else -- 2012
				Content:remove(outputFile) -- 2012
				resultCodes = false -- 2013
				resultError = err -- 2014
			end -- 2006
		elseif "xml" == _exp_0 then -- 2015
			local codes, err = xml.tolua(sourceCodes) -- 2016
			if codes then -- 2016
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2017
				Content:saveAsync(outputFile, resultCodes) -- 2018
			else -- 2020
				Content:remove(outputFile) -- 2020
				resultCodes = false -- 2021
				resultError = err -- 2022
			end -- 2016
		end -- 1982
	end -- 1982
	wait(function() -- 2023
		return resultCodes ~= nil -- 2023
	end) -- 2023
	if resultCodes then -- 2024
		return resultCodes -- 2025
	else -- 2027
		return nil, resultError -- 2027
	end -- 2024
	return nil -- 1957
end -- 1957
HttpServer:postSchedule("/write", function(req) -- 2029
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2030
	local buildSucceeded = false -- 2031
	local _ <close> = setmetatable({ }, { -- 2032
		__close = function() -- 2032
			return finishUpdate(buildSucceeded) -- 2032
		end -- 2032
	}) -- 2032
	do -- 2033
		local _type_0 = type(req) -- 2033
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2033
		if _tab_0 then -- 2033
			local path -- 2033
			do -- 2033
				local _obj_0 = req.body -- 2033
				local _type_1 = type(_obj_0) -- 2033
				if "table" == _type_1 or "userdata" == _type_1 then -- 2033
					path = _obj_0.path -- 2033
				end -- 2033
			end -- 2033
			local content -- 2033
			do -- 2033
				local _obj_0 = req.body -- 2033
				local _type_1 = type(_obj_0) -- 2033
				if "table" == _type_1 or "userdata" == _type_1 then -- 2033
					content = _obj_0.content -- 2033
				end -- 2033
			end -- 2033
			if path ~= nil and content ~= nil then -- 2033
				if Content:saveAsync(path, content) then -- 2034
					do -- 2035
						local _exp_0 = Path:getExt(path) -- 2035
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2035
							if '' == Path:getExt(Path:getName(path)) then -- 2036
								local resultCodes = compileFileAsync(path, content) -- 2037
								buildSucceeded = resultCodes ~= nil -- 2038
								return { -- 2039
									success = true, -- 2039
									resultCodes = resultCodes -- 2039
								} -- 2039
							end -- 2036
						end -- 2035
					end -- 2035
					buildSucceeded = true -- 2040
					return { -- 2041
						success = true -- 2041
					} -- 2041
				end -- 2034
			end -- 2033
		end -- 2033
	end -- 2033
	return { -- 2029
		success = false -- 2029
	} -- 2029
end) -- 2029
local getWaProjectDirFromFile = nil -- 2043
HttpServer:postSchedule("/build", function(req) -- 2045
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2046
	local buildSucceeded = false -- 2047
	local _ <close> = setmetatable({ }, { -- 2048
		__close = function() -- 2048
			return finishUpdate(buildSucceeded) -- 2048
		end -- 2048
	}) -- 2048
	do -- 2049
		local _type_0 = type(req) -- 2049
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2049
		if _tab_0 then -- 2049
			local path -- 2049
			do -- 2049
				local _obj_0 = req.body -- 2049
				local _type_1 = type(_obj_0) -- 2049
				if "table" == _type_1 or "userdata" == _type_1 then -- 2049
					path = _obj_0.path -- 2049
				end -- 2049
			end -- 2049
			if path ~= nil then -- 2049
				local projectRoot = req.body.projectRoot -- 2050
				if Content:isdir(path) then -- 2051
					local projDir = getWaProjectDirFromFile(path) -- 2052
					if projDir then -- 2052
						local message = Wasm:buildWaAsync(projDir) -- 2053
						if message == "" then -- 2054
							return { -- 2055
								success = true -- 2055
							} -- 2055
						else -- 2057
							return { -- 2057
								success = false, -- 2057
								message = message -- 2057
							} -- 2057
						end -- 2054
					end -- 2052
				end -- 2051
				local _exp_0 = Path:getExt(path) -- 2058
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2059
					if '' == Path:getExt(Path:getName(path)) then -- 2060
						local content = Content:loadAsync(path) -- 2061
						if content then -- 2061
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2062
							if resultCodes then -- 2062
								buildSucceeded = true -- 2063
								return { -- 2064
									success = true, -- 2064
									resultCodes = resultCodes -- 2064
								} -- 2064
							end -- 2062
						end -- 2061
					end -- 2060
				elseif "wa" == _exp_0 then -- 2065
					local projDir = getWaProjectDirFromFile(path) -- 2066
					if projDir then -- 2066
						local message = Wasm:buildWaAsync(projDir) -- 2067
						if message == "" then -- 2068
							return { -- 2069
								success = true -- 2069
							} -- 2069
						else -- 2071
							return { -- 2071
								success = false, -- 2071
								message = message -- 2071
							} -- 2071
						end -- 2068
					else -- 2073
						return { -- 2073
							success = false, -- 2073
							message = 'Wa file needs a project' -- 2073
						} -- 2073
					end -- 2066
				end -- 2058
			end -- 2049
		end -- 2049
	end -- 2049
	return { -- 2045
		success = false -- 2045
	} -- 2045
end) -- 2045
local extentionLevels = { -- 2076
	vs = 2, -- 2076
	bl = 2, -- 2077
	ts = 1, -- 2078
	tsx = 1, -- 2079
	tl = 1, -- 2080
	yue = 1, -- 2081
	xml = 1, -- 2082
	lua = 0 -- 2083
} -- 2075
local visitAssets -- 2085
visitAssets = function(path, workspace, builtin, recursive) -- 2085
	if recursive == nil then -- 2085
		recursive = true -- 2085
	end -- 2085
	local children = nil -- 2086
	local dirs = Content:getDirs(path) -- 2087
	for _index_0 = 1, #dirs do -- 2088
		local dir = dirs[_index_0] -- 2088
		if workspace then -- 2089
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 2090
				goto _continue_0 -- 2091
			end -- 2090
		elseif dir == ".git" then -- 2092
			goto _continue_0 -- 2093
		end -- 2089
		if not children then -- 2094
			children = { } -- 2094
		end -- 2094
		local dirPath = Path(path, dir) -- 2095
		if recursive then -- 2096
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2097
		else -- 2099
			children[#children + 1] = { -- 2100
				key = dirPath, -- 2100
				dir = true, -- 2101
				title = dir, -- 2102
				builtin = builtin, -- 2103
				isLeaf = false -- 2104
			} -- 2099
		end -- 2096
		::_continue_0:: -- 2089
	end -- 2088
	local files = Content:getFiles(path) -- 2106
	local names = { } -- 2107
	for _index_0 = 1, #files do -- 2108
		local file = files[_index_0] -- 2108
		if (".DS_Store" == file) then -- 2109
			goto _continue_1 -- 2110
		end -- 2109
		local name = Path:getName(file) -- 2111
		local ext = names[name] -- 2112
		if ext then -- 2112
			local lv1 -- 2113
			do -- 2113
				local _exp_0 = extentionLevels[ext] -- 2113
				if _exp_0 ~= nil then -- 2113
					lv1 = _exp_0 -- 2113
				else -- 2113
					lv1 = -1 -- 2113
				end -- 2113
			end -- 2113
			ext = Path:getExt(file) -- 2114
			local lv2 -- 2115
			do -- 2115
				local _exp_0 = extentionLevels[ext] -- 2115
				if _exp_0 ~= nil then -- 2115
					lv2 = _exp_0 -- 2115
				else -- 2115
					lv2 = -1 -- 2115
				end -- 2115
			end -- 2115
			if lv2 > lv1 then -- 2116
				names[name] = ext -- 2117
			elseif lv2 == lv1 then -- 2118
				names[name .. '.' .. ext] = "" -- 2119
			end -- 2116
		else -- 2121
			ext = Path:getExt(file) -- 2121
			if not extentionLevels[ext] then -- 2122
				names[file] = "" -- 2123
			else -- 2125
				names[name] = ext -- 2125
			end -- 2122
		end -- 2112
		::_continue_1:: -- 2109
	end -- 2108
	do -- 2126
		local _accum_0 = { } -- 2126
		local _len_0 = 1 -- 2126
		for name, ext in pairs(names) do -- 2126
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2126
			_len_0 = _len_0 + 1 -- 2126
		end -- 2126
		files = _accum_0 -- 2126
	end -- 2126
	for _index_0 = 1, #files do -- 2127
		local file = files[_index_0] -- 2127
		if not children then -- 2128
			children = { } -- 2128
		end -- 2128
		children[#children + 1] = { -- 2130
			key = Path(path, file), -- 2130
			dir = false, -- 2131
			title = file, -- 2132
			builtin = builtin -- 2133
		} -- 2129
	end -- 2127
	if children then -- 2135
		table.sort(children, function(a, b) -- 2136
			if a.dir == b.dir then -- 2137
				return a.title < b.title -- 2138
			else -- 2140
				return a.dir -- 2140
			end -- 2137
		end) -- 2136
	end -- 2135
	return { -- 2142
		key = path, -- 2142
		dir = true, -- 2143
		title = Path:getFilename(path), -- 2144
		builtin = builtin, -- 2145
		isLeaf = not children, -- 2146
		children = children -- 2147
	} -- 2141
end -- 2085
HttpServer:post("/assets/children", function(req) -- 2150
	do -- 2151
		local _type_0 = type(req) -- 2151
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2151
		if _tab_0 then -- 2151
			local path -- 2151
			do -- 2151
				local _obj_0 = req.body -- 2151
				local _type_1 = type(_obj_0) -- 2151
				if "table" == _type_1 or "userdata" == _type_1 then -- 2151
					path = _obj_0.path -- 2151
				end -- 2151
			end -- 2151
			if path ~= nil then -- 2151
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2152
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2153
					return { -- 2153
						success = false -- 2153
					} -- 2153
				end -- 2153
				local node = visitAssets(path, workspace, builtin, false) -- 2154
				return { -- 2155
					success = true, -- 2155
					children = node.children or { } -- 2155
				} -- 2155
			end -- 2151
		end -- 2151
	end -- 2151
	return { -- 2150
		success = false -- 2150
	} -- 2150
end) -- 2150
HttpServer:post("/assets/files", function(req) -- 2157
	do -- 2158
		local _type_0 = type(req) -- 2158
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2158
		if _tab_0 then -- 2158
			local path -- 2158
			do -- 2158
				local _obj_0 = req.body -- 2158
				local _type_1 = type(_obj_0) -- 2158
				if "table" == _type_1 or "userdata" == _type_1 then -- 2158
					path = _obj_0.path -- 2158
				end -- 2158
			end -- 2158
			if path ~= nil then -- 2158
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2159
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2160
				if not (workspace or builtin) then -- 2161
					return { -- 2161
						success = false -- 2161
					} -- 2161
				end -- 2161
				if not (Content:exist(path) and Content:isdir(path)) then -- 2162
					return { -- 2162
						success = false -- 2162
					} -- 2162
				end -- 2162
				local globs = { -- 2163
					"**", -- 2163
					"!**/.DS_Store" -- 2163
				} -- 2163
				if workspace then -- 2164
					globs = { -- 2166
						"**", -- 2166
						"!**/.DS_Store", -- 2166
						"!**/.upload/**", -- 2167
						"!**/.download/**", -- 2167
						"!**/.www/**", -- 2168
						"!**/.build/**", -- 2168
						"!**/.git/**", -- 2169
						"!**/.cache/**", -- 2169
						"!**/node_modules/**" -- 2170
					} -- 2165
				end -- 2164
				local files -- 2172
				do -- 2172
					local _accum_0 = { } -- 2172
					local _len_0 = 1 -- 2172
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2172
					for _index_0 = 1, #_list_0 do -- 2172
						local file = _list_0[_index_0] -- 2172
						_accum_0[_len_0] = Path(path, file) -- 2172
						_len_0 = _len_0 + 1 -- 2172
					end -- 2172
					files = _accum_0 -- 2172
				end -- 2172
				return { -- 2173
					success = true, -- 2173
					files = files -- 2173
				} -- 2173
			end -- 2158
		end -- 2158
	end -- 2158
	return { -- 2157
		success = false -- 2157
	} -- 2157
end) -- 2157
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2214
	local _tab_0 = { -- 2214
		{ -- 2215
			key = Path(Content.assetPath), -- 2215
			dir = true, -- 2216
			builtin = true, -- 2217
			title = zh and "内置资源" or "Built-in", -- 2218
			children = builtinChildren -- 2219
		} -- 2214
	} -- 2221
	local _obj_0 = workspace.children or { } -- 2221
	local _idx_0 = #_tab_0 + 1 -- 2221
	for _index_0 = 1, #_obj_0 do -- 2221
		local _value_0 = _obj_0[_index_0] -- 2221
		_tab_0[_idx_0] = _value_0 -- 2221
		_idx_0 = _idx_0 + 1 -- 2221
	end -- 2221
	return _tab_0 -- 2214
end -- 2214
HttpServer:post("/assets", function() -- 2175
	local Entry = require("Script.Dev.Entry") -- 2176
	local engineDev = Entry.getEngineDev() -- 2177
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2178
	local zh = (App.locale:match("^zh") ~= nil) -- 2179
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2180
	readme.title = zh and "说明文档" or "Readme" -- 2181
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2182
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2183
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2184
	tools.title = zh and "开发工具" or "Tools" -- 2185
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2186
	font.title = zh and "字体" or "Font" -- 2187
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2188
	lib.title = zh and "程序库" or "Lib" -- 2189
	if engineDev then -- 2190
		local _list_0 = lib.children -- 2191
		for _index_0 = 1, #_list_0 do -- 2191
			local child = _list_0[_index_0] -- 2191
			if not (child.title == "Dora") then -- 2192
				goto _continue_0 -- 2192
			end -- 2192
			local title = zh and "zh-Hans" or "en" -- 2193
			do -- 2194
				local _accum_0 = { } -- 2194
				local _len_0 = 1 -- 2194
				local _list_1 = child.children -- 2194
				for _index_1 = 1, #_list_1 do -- 2194
					local c = _list_1[_index_1] -- 2194
					if c.title ~= title then -- 2194
						_accum_0[_len_0] = c -- 2194
						_len_0 = _len_0 + 1 -- 2194
					end -- 2194
				end -- 2194
				child.children = _accum_0 -- 2194
			end -- 2194
			break -- 2195
			::_continue_0:: -- 2192
		end -- 2191
	else -- 2197
		local _accum_0 = { } -- 2197
		local _len_0 = 1 -- 2197
		local _list_0 = lib.children -- 2197
		for _index_0 = 1, #_list_0 do -- 2197
			local child = _list_0[_index_0] -- 2197
			if child.title ~= "Dora" then -- 2197
				_accum_0[_len_0] = child -- 2197
				_len_0 = _len_0 + 1 -- 2197
			end -- 2197
		end -- 2197
		lib.children = _accum_0 -- 2197
	end -- 2190
	local builtinChildren = { -- 2198
		readme, -- 2198
		apiDoc, -- 2198
		tools, -- 2198
		font, -- 2198
		lib -- 2198
	} -- 2198
	if engineDev then -- 2199
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2200
		do -- 2201
			local _obj_0 = dev.children -- 2201
			_obj_0[#_obj_0 + 1] = { -- 2202
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2202
				dir = false, -- 2203
				builtin = true, -- 2204
				title = "init.yue" -- 2205
			} -- 2201
		end -- 2201
		builtinChildren[#builtinChildren + 1] = dev -- 2207
	end -- 2199
	return { -- 2209
		key = Content.writablePath, -- 2209
		dir = true, -- 2210
		root = true, -- 2211
		title = "Assets", -- 2212
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2213
	} -- 2208
end) -- 2175
HttpServer:post("/entry/list", function(req) -- 2225
	local Entry = require("Script.Dev.Entry") -- 2226
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2227
	res.success = true -- 2228
	return res -- 2229
end) -- 2225
HttpServer:post("/run/status", function() -- 2231
	local Entry = require("Script.Dev.Entry") -- 2232
	return Entry.getCurrentEntryStatus() -- 2233
end) -- 2231
HttpServer:postSchedule("/run", function(req) -- 2235
	do -- 2236
		local _type_0 = type(req) -- 2236
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2236
		if _tab_0 then -- 2236
			local file -- 2236
			do -- 2236
				local _obj_0 = req.body -- 2236
				local _type_1 = type(_obj_0) -- 2236
				if "table" == _type_1 or "userdata" == _type_1 then -- 2236
					file = _obj_0.file -- 2236
				end -- 2236
			end -- 2236
			local asProj -- 2236
			do -- 2236
				local _obj_0 = req.body -- 2236
				local _type_1 = type(_obj_0) -- 2236
				if "table" == _type_1 or "userdata" == _type_1 then -- 2236
					asProj = _obj_0.asProj -- 2236
				end -- 2236
			end -- 2236
			if file ~= nil and asProj ~= nil then -- 2236
				if not Content:isAbsolutePath(file) then -- 2237
					local devFile = Path(Content.writablePath, file) -- 2238
					if Content:exist(devFile) then -- 2239
						file = devFile -- 2239
					end -- 2239
				end -- 2237
				local Entry = require("Script.Dev.Entry") -- 2240
				local workDir -- 2241
				if asProj then -- 2242
					local projectRoot = req.body.projectRoot -- 2243
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2244
						workDir = projectRoot -- 2245
					else -- 2247
						workDir = getProjectDirFromFile(file) -- 2247
					end -- 2244
					if workDir then -- 2248
						Entry.allClear() -- 2249
						local target = Path(workDir, "init") -- 2250
						local success, err = Entry.enterEntryAsync({ -- 2251
							entryName = "Project", -- 2251
							fileName = target, -- 2251
							workDir = workDir, -- 2251
							projectRoot = workDir, -- 2251
							runKind = "project" -- 2251
						}) -- 2251
						target = Path:getName(Path:getPath(target)) -- 2252
						return { -- 2253
							success = success, -- 2253
							target = target, -- 2253
							err = err -- 2253
						} -- 2253
					end -- 2248
				else -- 2255
					workDir = getProjectDirFromFile(file) -- 2255
					if not workDir and Path:getExt(file) == "wasm" then -- 2256
						local parent = Path:getPath(file) -- 2257
						if Content:exist(Path(parent, "wa.mod")) then -- 2258
							workDir = parent -- 2259
						end -- 2258
					end -- 2256
				end -- 2242
				Entry.allClear() -- 2260
				file = Path:replaceExt(file, "") -- 2261
				local entry = { -- 2263
					entryName = Path:getName(file), -- 2263
					fileName = file, -- 2264
					runKind = "file" -- 2265
				} -- 2262
				if workDir then -- 2266
					entry.workDir = workDir -- 2267
					entry.projectRoot = workDir -- 2268
				end -- 2266
				local success, err = Entry.enterEntryAsync(entry) -- 2269
				return { -- 2270
					success = success, -- 2270
					err = err -- 2270
				} -- 2270
			end -- 2236
		end -- 2236
	end -- 2236
	return { -- 2235
		success = false -- 2235
	} -- 2235
end) -- 2235
local _anon_func_7 = function(result) -- 2312
	if result.success then -- 2312
		return nil -- 2312
	else -- 2312
		return "PREVIEW_FAILED" -- 2312
	end -- 2312
end -- 2312
HttpServer:postSchedule("/agent/preview", function(req) -- 2272
	local releaseAgent = AgentHost.acquire() -- 2273
	local _ <close> = setmetatable({ }, { -- 2274
		__close = function() -- 2274
			return releaseAgent() -- 2274
		end -- 2274
	}) -- 2274
	do -- 2275
		local _type_0 = type(req) -- 2275
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2275
		if _tab_0 then -- 2275
			local projectRoot -- 2275
			do -- 2275
				local _obj_0 = req.body -- 2275
				local _type_1 = type(_obj_0) -- 2275
				if "table" == _type_1 or "userdata" == _type_1 then -- 2275
					projectRoot = _obj_0.projectRoot -- 2275
				end -- 2275
			end -- 2275
			if projectRoot ~= nil then -- 2275
				if not getProjectSourceRoot(projectRoot) then -- 2276
					return { -- 2276
						success = false, -- 2276
						code = "INVALID_PROJECT", -- 2276
						message = "projectRoot must be an existing absolute directory" -- 2276
					} -- 2276
				end -- 2276
				local entryFile = req.body.entry or "init.lua" -- 2277
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2278
					return { -- 2278
						success = false, -- 2278
						code = "INVALID_ENTRY", -- 2278
						message = "entry must be a non-empty project-relative path" -- 2278
					} -- 2278
				end -- 2278
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2279
					0.5 -- 2279
				} -- 2279
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2280
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2281
					return { -- 2281
						success = false, -- 2281
						code = "INVALID_QUEUE_TIMEOUT", -- 2281
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2281
					} -- 2281
				end -- 2281
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2282
				local AgentOperation = require("Agent.Tool.Operation") -- 2283
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2284
				local requestId = AgentOperation.createOperationId() -- 2285
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2286
				if not enqueued.success then -- 2287
					return { -- 2287
						success = false, -- 2287
						code = "ENTRY_QUEUE_REJECTED", -- 2287
						message = enqueued.message -- 2287
					} -- 2287
				end -- 2287
				local queuedAt = App.runningTime -- 2288
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2289
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2290
						local state = agentEntryRunQueue:get(requestId) -- 2291
						agentEntryRunQueue:cancel(requestId) -- 2292
						return { -- 2294
							success = false, -- 2294
							code = "ENTRY_QUEUE_TIMEOUT", -- 2295
							message = "timed out waiting for the Dora entry runtime", -- 2296
							requestId = requestId, -- 2297
							queuePosition = state.position -- 2298
						} -- 2293
					end -- 2290
					sleep() -- 2299
				end -- 2289
				local queueWaitSeconds = App.runningTime - queuedAt -- 2300
				local _ <close> = setmetatable({ }, { -- 2301
					__close = function() -- 2301
						return agentEntryRunQueue:release(requestId) -- 2301
					end -- 2301
				}) -- 2301
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2302
				local Entry = require("Script.Dev.Entry") -- 2303
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2305
					workDir = projectRoot, -- 2305
					operationId = requestId, -- 2306
					print = function() end -- 2307
				}, Entry) -- 2304
				local result = preview({ -- 2309
					entry = entryFile, -- 2309
					captureAtSeconds = captureAtSeconds -- 2309
				}) -- 2309
				return { -- 2311
					success = result.success, -- 2311
					code = _anon_func_7(result), -- 2312
					message = result.message, -- 2313
					requestId = requestId, -- 2314
					queueWaitSeconds = queueWaitSeconds, -- 2315
					interruptedUserRun = result.interruptedUserRun, -- 2316
					files = result.files, -- 2317
					frames = result.frames -- 2318
				} -- 2310
			end -- 2275
		end -- 2275
	end -- 2275
	return { -- 2272
		success = false, -- 2272
		message = "invalid call" -- 2272
	} -- 2272
end) -- 2272
HttpServer:postSchedule("/agent/command", function(req) -- 2320
	local releaseAgent = AgentHost.acquire() -- 2321
	local _ <close> = setmetatable({ }, { -- 2322
		__close = function() -- 2322
			return releaseAgent() -- 2322
		end -- 2322
	}) -- 2322
	do -- 2323
		local _type_0 = type(req) -- 2323
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2323
		if _tab_0 then -- 2323
			local body = req.body -- 2323
			if body ~= nil then -- 2323
				local projectRoot = body.projectRoot -- 2324
				if not getProjectSourceRoot(projectRoot) then -- 2325
					return { -- 2325
						success = false, -- 2325
						code = "INVALID_PROJECT", -- 2325
						message = "projectRoot must be an existing absolute directory" -- 2325
					} -- 2325
				end -- 2325
				local AgentValidation = require("Agent.Tool.Validation") -- 2326
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2327
				if not validated.success then -- 2328
					return { -- 2328
						success = false, -- 2328
						code = "INVALID_COMMAND", -- 2328
						message = validated.message -- 2328
					} -- 2328
				end -- 2328
				local input = validated.value -- 2329
				local AgentCommand = require("Agent.Tool.Command") -- 2330
				local result = nil -- 2331
				local failure = nil -- 2332
				local promise = AgentCommand.executeCommand({ -- 2334
					workDir = projectRoot, -- 2334
					mode = input.mode, -- 2335
					code = input.code, -- 2336
					command = input.command, -- 2337
					cwd = input.cwd, -- 2338
					timeoutSeconds = input.timeoutSeconds -- 2339
				}) -- 2333
				promise:addCallbacks((function(_, value) -- 2340
					result = value -- 2340
				end), (function(_, err) -- 2340
					failure = tostring(err) -- 2340
				end)) -- 2340
				wait(function() -- 2341
					return result ~= nil or failure ~= nil -- 2341
				end) -- 2341
				if failure then -- 2342
					return { -- 2342
						success = false, -- 2342
						code = "COMMAND_BRIDGE_FAILED", -- 2342
						message = failure -- 2342
					} -- 2342
				end -- 2342
				if not result.success then -- 2343
					result.code = "COMMAND_FAILED" -- 2344
				end -- 2343
				return result -- 2345
			end -- 2323
		end -- 2323
	end -- 2323
	return { -- 2320
		success = false, -- 2320
		code = "INVALID_COMMAND", -- 2320
		message = "invalid call" -- 2320
	} -- 2320
end) -- 2320
HttpServer:postSchedule("/stop", function() -- 2347
	local Entry = require("Script.Dev.Entry") -- 2348
	return { -- 2349
		success = Entry.stop() -- 2349
	} -- 2349
end) -- 2347
local minifyAsync -- 2351
minifyAsync = function(sourcePath, minifyPath) -- 2351
	if not Content:exist(sourcePath) then -- 2352
		return -- 2352
	end -- 2352
	local Entry = require("Script.Dev.Entry") -- 2353
	local errors = { } -- 2354
	local files = Entry.getAllFiles(sourcePath, { -- 2355
		"lua" -- 2355
	}, true) -- 2355
	do -- 2356
		local _accum_0 = { } -- 2356
		local _len_0 = 1 -- 2356
		for _index_0 = 1, #files do -- 2356
			local file = files[_index_0] -- 2356
			if file:sub(1, 1) ~= '.' then -- 2356
				_accum_0[_len_0] = file -- 2356
				_len_0 = _len_0 + 1 -- 2356
			end -- 2356
		end -- 2356
		files = _accum_0 -- 2356
	end -- 2356
	local paths -- 2357
	do -- 2357
		local _tbl_0 = { } -- 2357
		for _index_0 = 1, #files do -- 2357
			local file = files[_index_0] -- 2357
			_tbl_0[Path:getPath(file)] = true -- 2357
		end -- 2357
		paths = _tbl_0 -- 2357
	end -- 2357
	for path in pairs(paths) do -- 2358
		Content:mkdir(Path(minifyPath, path)) -- 2358
	end -- 2358
	local _ <close> = setmetatable({ }, { -- 2359
		__close = function() -- 2359
			package.loaded["luaminify.FormatMini"] = nil -- 2360
			package.loaded["luaminify.ParseLua"] = nil -- 2361
			package.loaded["luaminify.Scope"] = nil -- 2362
			package.loaded["luaminify.Util"] = nil -- 2363
		end -- 2359
	}) -- 2359
	local FormatMini -- 2364
	do -- 2364
		local _obj_0 = require("luaminify") -- 2364
		FormatMini = _obj_0.FormatMini -- 2364
	end -- 2364
	local fileCount = #files -- 2365
	local count = 0 -- 2366
	for _index_0 = 1, #files do -- 2367
		local file = files[_index_0] -- 2367
		thread(function() -- 2368
			local _ <close> = setmetatable({ }, { -- 2369
				__close = function() -- 2369
					count = count + 1 -- 2369
				end -- 2369
			}) -- 2369
			local input = Path(sourcePath, file) -- 2370
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2371
			if Content:exist(input) then -- 2372
				local sourceCodes = Content:loadAsync(input) -- 2373
				local res, err = FormatMini(sourceCodes) -- 2374
				if res then -- 2375
					Content:saveAsync(output, res) -- 2376
					return print("Minify " .. tostring(file)) -- 2377
				else -- 2379
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2379
				end -- 2375
			else -- 2381
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2381
			end -- 2372
		end) -- 2368
		sleep() -- 2382
	end -- 2367
	wait(function() -- 2383
		return count == fileCount -- 2383
	end) -- 2383
	if #errors > 0 then -- 2384
		print(table.concat(errors, '\n')) -- 2385
	end -- 2384
	print("Obfuscation done.") -- 2386
	return files -- 2387
end -- 2351
local zipping = false -- 2389
HttpServer:postSchedule("/zip", function(req) -- 2391
	do -- 2392
		local _type_0 = type(req) -- 2392
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2392
		if _tab_0 then -- 2392
			local path -- 2392
			do -- 2392
				local _obj_0 = req.body -- 2392
				local _type_1 = type(_obj_0) -- 2392
				if "table" == _type_1 or "userdata" == _type_1 then -- 2392
					path = _obj_0.path -- 2392
				end -- 2392
			end -- 2392
			local zipFile -- 2392
			do -- 2392
				local _obj_0 = req.body -- 2392
				local _type_1 = type(_obj_0) -- 2392
				if "table" == _type_1 or "userdata" == _type_1 then -- 2392
					zipFile = _obj_0.zipFile -- 2392
				end -- 2392
			end -- 2392
			local obfuscated -- 2392
			do -- 2392
				local _obj_0 = req.body -- 2392
				local _type_1 = type(_obj_0) -- 2392
				if "table" == _type_1 or "userdata" == _type_1 then -- 2392
					obfuscated = _obj_0.obfuscated -- 2392
				end -- 2392
			end -- 2392
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2392
				if zipping then -- 2393
					goto failed -- 2393
				end -- 2393
				zipping = true -- 2394
				local _ <close> = setmetatable({ }, { -- 2395
					__close = function() -- 2395
						zipping = false -- 2395
					end -- 2395
				}) -- 2395
				if not Content:exist(path) then -- 2396
					goto failed -- 2396
				end -- 2396
				Content:mkdir(Path:getPath(zipFile)) -- 2397
				if obfuscated then -- 2398
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2399
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2400
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2401
					Content:remove(scriptPath) -- 2402
					Content:remove(obfuscatedPath) -- 2403
					Content:remove(tempPath) -- 2404
					Content:mkdir(scriptPath) -- 2405
					Content:mkdir(obfuscatedPath) -- 2406
					Content:mkdir(tempPath) -- 2407
					if not Content:copyAsync(path, tempPath) then -- 2408
						goto failed -- 2408
					end -- 2408
					local Entry = require("Script.Dev.Entry") -- 2409
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2410
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2411
						"tl", -- 2411
						"yue", -- 2411
						"lua", -- 2411
						"ts", -- 2411
						"tsx", -- 2411
						"vs", -- 2411
						"bl", -- 2411
						"xml", -- 2411
						"wa", -- 2411
						"mod" -- 2411
					}, true) -- 2411
					for _index_0 = 1, #scriptFiles do -- 2412
						local file = scriptFiles[_index_0] -- 2412
						Content:remove(Path(tempPath, file)) -- 2413
					end -- 2412
					for _index_0 = 1, #luaFiles do -- 2414
						local file = luaFiles[_index_0] -- 2414
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2415
					end -- 2414
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2416
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2417
					end) then -- 2416
						goto failed -- 2416
					end -- 2416
					return { -- 2418
						success = true -- 2418
					} -- 2418
				else -- 2420
					return { -- 2420
						success = Content:zipAsync(path, zipFile, function(file) -- 2420
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2421
						end) -- 2420
					} -- 2420
				end -- 2398
			end -- 2392
		end -- 2392
	end -- 2392
	::failed:: -- 2422
	return { -- 2391
		success = false -- 2391
	} -- 2391
end) -- 2391
HttpServer:postSchedule("/unzip", function(req) -- 2424
	do -- 2425
		local _type_0 = type(req) -- 2425
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2425
		if _tab_0 then -- 2425
			local zipFile -- 2425
			do -- 2425
				local _obj_0 = req.body -- 2425
				local _type_1 = type(_obj_0) -- 2425
				if "table" == _type_1 or "userdata" == _type_1 then -- 2425
					zipFile = _obj_0.zipFile -- 2425
				end -- 2425
			end -- 2425
			local path -- 2425
			do -- 2425
				local _obj_0 = req.body -- 2425
				local _type_1 = type(_obj_0) -- 2425
				if "table" == _type_1 or "userdata" == _type_1 then -- 2425
					path = _obj_0.path -- 2425
				end -- 2425
			end -- 2425
			if zipFile ~= nil and path ~= nil then -- 2425
				return { -- 2426
					success = Content:unzipAsync(zipFile, path, function(file) -- 2426
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2427
					end) -- 2426
				} -- 2426
			end -- 2425
		end -- 2425
	end -- 2425
	return { -- 2424
		success = false -- 2424
	} -- 2424
end) -- 2424
HttpServer:post("/editing-info", function(req) -- 2429
	local Entry = require("Script.Dev.Entry") -- 2430
	local config = Entry.getConfig() -- 2431
	local _type_0 = type(req) -- 2432
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2432
	local _match_0 = false -- 2432
	if _tab_0 then -- 2432
		local editingInfo -- 2432
		do -- 2432
			local _obj_0 = req.body -- 2432
			local _type_1 = type(_obj_0) -- 2432
			if "table" == _type_1 or "userdata" == _type_1 then -- 2432
				editingInfo = _obj_0.editingInfo -- 2432
			end -- 2432
		end -- 2432
		if editingInfo ~= nil then -- 2432
			_match_0 = true -- 2432
			config.editingInfo = editingInfo -- 2433
			return { -- 2434
				success = true -- 2434
			} -- 2434
		end -- 2432
	end -- 2432
	if not _match_0 then -- 2432
		if not (config.editingInfo ~= nil) then -- 2436
			local folder -- 2437
			if App.locale:match('^zh') then -- 2437
				folder = 'zh-Hans' -- 2437
			else -- 2437
				folder = 'en' -- 2437
			end -- 2437
			config.editingInfo = json.encode({ -- 2439
				index = 0, -- 2439
				files = { -- 2441
					{ -- 2442
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2442
						title = "welcome.md" -- 2443
					} -- 2441
				} -- 2440
			}) -- 2438
		end -- 2436
		return { -- 2447
			success = true, -- 2447
			editingInfo = config.editingInfo -- 2447
		} -- 2447
	end -- 2432
end) -- 2429
HttpServer:post("/command", function(req) -- 2449
	do -- 2450
		local _type_0 = type(req) -- 2450
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2450
		if _tab_0 then -- 2450
			local code -- 2450
			do -- 2450
				local _obj_0 = req.body -- 2450
				local _type_1 = type(_obj_0) -- 2450
				if "table" == _type_1 or "userdata" == _type_1 then -- 2450
					code = _obj_0.code -- 2450
				end -- 2450
			end -- 2450
			local log -- 2450
			do -- 2450
				local _obj_0 = req.body -- 2450
				local _type_1 = type(_obj_0) -- 2450
				if "table" == _type_1 or "userdata" == _type_1 then -- 2450
					log = _obj_0.log -- 2450
				end -- 2450
			end -- 2450
			if code ~= nil and log ~= nil then -- 2450
				emit("AppCommand", code, log) -- 2451
				return { -- 2452
					success = true -- 2452
				} -- 2452
			end -- 2450
		end -- 2450
	end -- 2450
	return { -- 2449
		success = false -- 2449
	} -- 2449
end) -- 2449
HttpServer:post("/log/save", function() -- 2454
	local folder = ".download" -- 2455
	local fullLogFile = "dora_full_logs.txt" -- 2456
	local fullFolder = Path(Content.writablePath, folder) -- 2457
	Content:mkdir(fullFolder) -- 2458
	local logPath = Path(fullFolder, fullLogFile) -- 2459
	if App:saveLog(logPath) then -- 2460
		return { -- 2461
			success = true, -- 2461
			path = Path(folder, fullLogFile) -- 2461
		} -- 2461
	end -- 2460
	return { -- 2454
		success = false -- 2454
	} -- 2454
end) -- 2454
local tailLines -- 2463
tailLines = function(text, count) -- 2463
	local lines = { } -- 2464
	text = text:gsub("\r\n", "\n") -- 2465
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2466
		lines[#lines + 1] = line -- 2467
	end -- 2466
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2468
		table.remove(lines) -- 2469
	end -- 2468
	local start = math.max(1, #lines - count + 1) -- 2470
	local out = { } -- 2471
	for i = start, #lines do -- 2472
		out[#out + 1] = lines[i] -- 2473
	end -- 2472
	return table.concat(out, "\n") -- 2474
end -- 2463
HttpServer:post("/log", function(req) -- 2476
	local count = 100 -- 2477
	if req and req.body and req.body.count ~= nil then -- 2478
		count = req.body.count -- 2479
	end -- 2478
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2480
		return { -- 2481
			success = false, -- 2481
			message = "count must be a positive integer" -- 2481
		} -- 2481
	end -- 2480
	local folder = ".download" -- 2482
	local fullLogFile = "dora_full_logs.txt" -- 2483
	local fullFolder = Path(Content.writablePath, folder) -- 2484
	Content:mkdir(fullFolder) -- 2485
	local logPath = Path(fullFolder, fullLogFile) -- 2486
	if App:saveLog(logPath) then -- 2487
		local text = Content:load(logPath) -- 2488
		if text then -- 2489
			return { -- 2490
				success = true, -- 2490
				log = tailLines(text, count) -- 2490
			} -- 2490
		else -- 2492
			return { -- 2492
				success = false, -- 2492
				message = "failed to read log" -- 2492
			} -- 2492
		end -- 2489
	else -- 2494
		return { -- 2494
			success = false, -- 2494
			message = "failed to save log" -- 2494
		} -- 2494
	end -- 2487
	return { -- 2476
		success = false -- 2476
	} -- 2476
end) -- 2476
HttpServer:post("/yarn/check", function(req) -- 2496
	local yarncompile = require("yarncompile") -- 2497
	do -- 2498
		local _type_0 = type(req) -- 2498
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2498
		if _tab_0 then -- 2498
			local code -- 2498
			do -- 2498
				local _obj_0 = req.body -- 2498
				local _type_1 = type(_obj_0) -- 2498
				if "table" == _type_1 or "userdata" == _type_1 then -- 2498
					code = _obj_0.code -- 2498
				end -- 2498
			end -- 2498
			if code ~= nil then -- 2498
				local jsonObject = json.decode(code) -- 2499
				if jsonObject then -- 2499
					local errors = { } -- 2500
					local _list_0 = jsonObject.nodes -- 2501
					for _index_0 = 1, #_list_0 do -- 2501
						local node = _list_0[_index_0] -- 2501
						local title, body = node.title, node.body -- 2502
						local luaCode, err = yarncompile(body) -- 2503
						if not luaCode then -- 2503
							errors[#errors + 1] = title .. ":" .. err -- 2504
						end -- 2503
					end -- 2501
					return { -- 2505
						success = true, -- 2505
						syntaxError = table.concat(errors, "\n\n") -- 2505
					} -- 2505
				end -- 2499
			end -- 2498
		end -- 2498
	end -- 2498
	return { -- 2496
		success = false -- 2496
	} -- 2496
end) -- 2496
HttpServer:post("/yarn/check-file", function(req) -- 2507
	local yarncompile = require("yarncompile") -- 2508
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
			if code ~= nil then -- 2509
				local res, _, err = yarncompile(code, true) -- 2510
				if not res then -- 2510
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2511
					return { -- 2512
						success = false, -- 2512
						message = message, -- 2512
						line = line, -- 2512
						column = column, -- 2512
						node = node -- 2512
					} -- 2512
				end -- 2510
			end -- 2509
		end -- 2509
	end -- 2509
	return { -- 2507
		success = true -- 2507
	} -- 2507
end) -- 2507
getWaProjectDirFromFile = function(file) -- 2514
	local current -- 2515
	if Content:isdir(file) then -- 2515
		current = file -- 2515
	else -- 2515
		current = Path:getPath(file) -- 2515
	end -- 2515
	if current == "" then -- 2516
		return nil -- 2516
	end -- 2516
	repeat -- 2517
		local modPath = Path(current, "wa.mod") -- 2518
		if Content:exist(modPath) then -- 2519
			return current, modPath -- 2520
		end -- 2519
		local parent = Path:getPath(current) -- 2521
		if parent == "" or parent == current then -- 2522
			break -- 2522
		end -- 2522
		current = parent -- 2523
	until false -- 2517
	return nil -- 2525
end -- 2514
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2527
	do -- 2528
		local _type_0 = type(req) -- 2528
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2528
		if _tab_0 then -- 2528
			local path -- 2528
			do -- 2528
				local _obj_0 = req.body -- 2528
				local _type_1 = type(_obj_0) -- 2528
				if "table" == _type_1 or "userdata" == _type_1 then -- 2528
					path = _obj_0.path -- 2528
				end -- 2528
			end -- 2528
			if path ~= nil then -- 2528
				local projDir = getWaProjectDirFromFile(path) -- 2529
				if projDir then -- 2529
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2530
					if not Content:exist(sourceDoraPath) then -- 2531
						return { -- 2532
							success = false, -- 2532
							message = "missing dora template" -- 2532
						} -- 2532
					end -- 2531
					local targetVendorPath = Path(projDir, "vendor") -- 2533
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2534
					if not Content:exist(targetVendorPath) then -- 2535
						if not Content:mkdir(targetVendorPath) then -- 2536
							return { -- 2537
								success = false, -- 2537
								message = "failed to create vendor folder" -- 2537
							} -- 2537
						end -- 2536
					elseif not Content:isdir(targetVendorPath) then -- 2538
						return { -- 2539
							success = false, -- 2539
							message = "vendor path is not a folder" -- 2539
						} -- 2539
					end -- 2535
					if Content:exist(targetDoraPath) then -- 2540
						if not Content:remove(targetDoraPath) then -- 2541
							return { -- 2542
								success = false, -- 2542
								message = "failed to remove old dora" -- 2542
							} -- 2542
						end -- 2541
					end -- 2540
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2543
						return { -- 2544
							success = false, -- 2544
							message = "failed to copy dora" -- 2544
						} -- 2544
					end -- 2543
					return { -- 2545
						success = true -- 2545
					} -- 2545
				else -- 2547
					return { -- 2547
						success = false, -- 2547
						message = 'Wa file needs a project' -- 2547
					} -- 2547
				end -- 2529
			end -- 2528
		end -- 2528
	end -- 2528
	return { -- 2527
		success = false, -- 2527
		message = "invalid call" -- 2527
	} -- 2527
end) -- 2527
HttpServer:postSchedule("/wa/build", function(req) -- 2549
	do -- 2550
		local _type_0 = type(req) -- 2550
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2550
		if _tab_0 then -- 2550
			local path -- 2550
			do -- 2550
				local _obj_0 = req.body -- 2550
				local _type_1 = type(_obj_0) -- 2550
				if "table" == _type_1 or "userdata" == _type_1 then -- 2550
					path = _obj_0.path -- 2550
				end -- 2550
			end -- 2550
			if path ~= nil then -- 2550
				local projDir = getWaProjectDirFromFile(path) -- 2551
				if projDir then -- 2551
					local message = Wasm:buildWaAsync(projDir) -- 2552
					if message == "" then -- 2553
						return { -- 2554
							success = true -- 2554
						} -- 2554
					else -- 2556
						return { -- 2556
							success = false, -- 2556
							message = message -- 2556
						} -- 2556
					end -- 2553
				else -- 2558
					return { -- 2558
						success = false, -- 2558
						message = 'Wa file needs a project' -- 2558
					} -- 2558
				end -- 2551
			end -- 2550
		end -- 2550
	end -- 2550
	return { -- 2559
		success = false, -- 2559
		message = 'failed to build' -- 2559
	} -- 2559
end) -- 2549
HttpServer:postSchedule("/wa/format", function(req) -- 2561
	do -- 2562
		local _type_0 = type(req) -- 2562
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2562
		if _tab_0 then -- 2562
			local file -- 2562
			do -- 2562
				local _obj_0 = req.body -- 2562
				local _type_1 = type(_obj_0) -- 2562
				if "table" == _type_1 or "userdata" == _type_1 then -- 2562
					file = _obj_0.file -- 2562
				end -- 2562
			end -- 2562
			if file ~= nil then -- 2562
				local code = Wasm:formatWaAsync(file) -- 2563
				if code == "" then -- 2564
					return { -- 2565
						success = false -- 2565
					} -- 2565
				else -- 2567
					return { -- 2567
						success = true, -- 2567
						code = code -- 2567
					} -- 2567
				end -- 2564
			end -- 2562
		end -- 2562
	end -- 2562
	return { -- 2568
		success = false -- 2568
	} -- 2568
end) -- 2561
HttpServer:postSchedule("/wa/create", function(req) -- 2570
	do -- 2571
		local _type_0 = type(req) -- 2571
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2571
		if _tab_0 then -- 2571
			local path -- 2571
			do -- 2571
				local _obj_0 = req.body -- 2571
				local _type_1 = type(_obj_0) -- 2571
				if "table" == _type_1 or "userdata" == _type_1 then -- 2571
					path = _obj_0.path -- 2571
				end -- 2571
			end -- 2571
			if path ~= nil then -- 2571
				if not Content:exist(Path:getPath(path)) then -- 2572
					return { -- 2573
						success = false, -- 2573
						message = "target path not existed" -- 2573
					} -- 2573
				end -- 2572
				if Content:exist(path) then -- 2574
					return { -- 2575
						success = false, -- 2575
						message = "target project folder existed" -- 2575
					} -- 2575
				end -- 2574
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2576
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2577
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2578
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2579
					return { -- 2582
						success = false, -- 2582
						message = "missing template project" -- 2582
					} -- 2582
				end -- 2579
				if not Content:mkdir(path) then -- 2583
					return { -- 2584
						success = false, -- 2584
						message = "failed to create project folder" -- 2584
					} -- 2584
				end -- 2583
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2585
					Content:remove(path) -- 2586
					return { -- 2587
						success = false, -- 2587
						message = "failed to copy template" -- 2587
					} -- 2587
				end -- 2585
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2588
					Content:remove(path) -- 2589
					return { -- 2590
						success = false, -- 2590
						message = "failed to copy template" -- 2590
					} -- 2590
				end -- 2588
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2591
					Content:remove(path) -- 2592
					return { -- 2593
						success = false, -- 2593
						message = "failed to copy template" -- 2593
					} -- 2593
				end -- 2591
				return { -- 2594
					success = true -- 2594
				} -- 2594
			end -- 2571
		end -- 2571
	end -- 2571
	return { -- 2570
		success = false, -- 2570
		message = "invalid call" -- 2570
	} -- 2570
end) -- 2570
local tsBuildGlobs = { -- 2597
	"**/*.ts", -- 2597
	"**/*.tsx", -- 2598
	"!**/.*/**", -- 2599
	"!**/node_modules/**" -- 2600
} -- 2596
local tsSnapshotGlobs = { -- 2603
	"**/*.ts", -- 2603
	"**/*.tsx", -- 2604
	"**/*.lua", -- 2605
	"!**/.*/**", -- 2606
	"!**/node_modules/**" -- 2607
} -- 2602
local collectTSVirtualFiles -- 2609
collectTSVirtualFiles = function(sourceRoot) -- 2609
	local files = { } -- 2610
	local seen = { } -- 2611
	local addFile -- 2612
	addFile = function(file, moduleName, virtualFile) -- 2612
		if moduleName == nil then -- 2612
			moduleName = nil -- 2612
		end -- 2612
		if virtualFile == nil then -- 2612
			virtualFile = nil -- 2612
		end -- 2612
		local targetFile = virtualFile or file -- 2613
		do -- 2614
			local entry = seen[targetFile] -- 2614
			if entry then -- 2614
				if moduleName and moduleName ~= "" then -- 2615
					entry.moduleName = moduleName -- 2615
				end -- 2615
				return -- 2616
			end -- 2614
		end -- 2614
		local content = Content:load(file) -- 2617
		if content then -- 2617
			local entry = { -- 2618
				file = targetFile, -- 2618
				content = content -- 2618
			} -- 2618
			if moduleName and moduleName ~= "" then -- 2619
				entry.moduleName = moduleName -- 2619
			end -- 2619
			seen[targetFile] = entry -- 2620
			files[#files + 1] = entry -- 2621
		end -- 2617
	end -- 2612
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2622
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2623
		for _index_0 = 1, #_list_0 do -- 2623
			local subFile = _list_0[_index_0] -- 2623
			addFile(Path(sourceRoot, subFile)) -- 2624
		end -- 2623
		local libraryRoots = { -- 2626
			Path(sourceRoot, "Script", "Lib"), -- 2626
			Path(sourceRoot, "Lib"), -- 2627
			Path(Content.assetPath, "Script", "Lib") -- 2628
		} -- 2625
		for _index_0 = 1, #libraryRoots do -- 2629
			local libraryRoot = libraryRoots[_index_0] -- 2629
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2630
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2631
				for _index_1 = 1, #_list_1 do -- 2631
					local subFile = _list_1[_index_1] -- 2631
					local file = Path(libraryRoot, subFile) -- 2632
					local virtualFile = Path(sourceRoot, subFile) -- 2633
					addFile(file, nil, virtualFile) -- 2634
				end -- 2631
			end -- 2630
		end -- 2629
	end -- 2622
	local locale -- 2635
	if App.locale:match('^zh') then -- 2635
		locale = 'zh-Hans' -- 2635
	else -- 2635
		locale = 'en' -- 2635
	end -- 2635
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2636
	local _list_0 = Content:getFiles(declarationRoot) -- 2637
	for _index_0 = 1, #_list_0 do -- 2637
		local file = _list_0[_index_0] -- 2637
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2638
			local fullPath = Path(declarationRoot, file) -- 2639
			local moduleName = Path:getName(Path:getName(file)) -- 2640
			addFile(fullPath, moduleName) -- 2641
		end -- 2638
	end -- 2637
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2642
	local lualibBundleTarget -- 2643
	if sourceRoot then -- 2643
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2643
	else -- 2643
		lualibBundleTarget = "lualib_bundle.lua" -- 2643
	end -- 2643
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2644
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2645
	local _list_1 = Content:getFiles(lualibRoot) -- 2646
	for _index_0 = 1, #_list_1 do -- 2646
		local file = _list_1[_index_0] -- 2646
		if Path:getExt(file) == "lua" then -- 2647
			local virtualFile -- 2648
			if sourceRoot then -- 2648
				virtualFile = Path(sourceRoot, "lualib", file) -- 2648
			else -- 2648
				virtualFile = Path("lualib", file) -- 2648
			end -- 2648
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2649
		end -- 2647
	end -- 2646
	return files -- 2650
end -- 2609
local supportsCompilerWebView -- 2652
supportsCompilerWebView = function() -- 2652
	local _val_0 = App.platform -- 2652
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2652
end -- 2652
local webIDECompilerReady = false -- 2653
local webIDEConnectionGeneration = 0 -- 2654
local tsProbeId = 0 -- 2655
local probeWebIDECompiler -- 2657
probeWebIDECompiler = function(isCancelled) -- 2657
	if HttpServer.wsConnectionCount == 0 then -- 2658
		return false -- 2658
	end -- 2658
	tsProbeId = tsProbeId + 1 -- 2659
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2660
	local generation = webIDEConnectionGeneration -- 2661
	local done, ready = false, false -- 2662
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2663
	local listener = Node() -- 2664
	listener:gslot("AppWS", function(event) -- 2665
		if event.type == "Receive" then -- 2666
			local res = json.decode(event.msg) -- 2667
			if res then -- 2667
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2668
					responses = responses + 1 -- 2669
					ready = ready or res.success == true -- 2670
					done = ready or responses >= expectedResponses -- 2671
				end -- 2668
			end -- 2667
		end -- 2666
	end) -- 2665
	emit("AppWS", "Send", json.encode({ -- 2672
		name = "TranspileTSProbe", -- 2672
		id = requestId -- 2672
	})) -- 2672
	local deadline = App.runningTime + 5 -- 2673
	wait(function() -- 2674
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2674
	end) -- 2674
	listener:removeFromParent() -- 2675
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2676
	if generation == webIDEConnectionGeneration then -- 2677
		webIDECompilerReady = ready -- 2677
	end -- 2677
	return ready -- 2678
end -- 2657
local compilerConnectionListener = Node() -- 2680
compilerConnectionListener:addTo(Director.systemUI) -- 2682
local _anon_func_8 = function(event) -- 2684
	local _val_0 = event.type -- 2684
	return "Open" == _val_0 or "Close" == _val_0 -- 2684
end -- 2684
compilerConnectionListener:gslot("AppWS", function(event) -- 2683
	if _anon_func_8(event) then -- 2684
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2685
		webIDECompilerReady = false -- 2686
		if HttpServer.wsConnectionCount > 0 then -- 2687
			return thread(function() -- 2688
				return probeWebIDECompiler() -- 2688
			end) -- 2688
		end -- 2687
	end -- 2684
end) -- 2683
local _anon_func_9 = function(res) -- 2713
	if res.success then -- 2713
		return "tool" -- 2713
	else -- 2713
		return res.failureKind -- 2713
	end -- 2713
end -- 2713
local transpileTSFileWithWebIDE -- 2690
do -- 2690
	local tsBuildRequestId = 0 -- 2691
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2692
		if not probeWebIDECompiler(isCancelled) then -- 2693
			if isCancelled and isCancelled() then -- 2694
				return { -- 2695
					success = false, -- 2695
					file = file, -- 2695
					message = "build canceled", -- 2695
					interrupted = true -- 2695
				} -- 2695
			end -- 2694
			return { -- 2696
				success = false, -- 2696
				file = file, -- 2696
				message = "TypeScript transpiler is not ready", -- 2696
				failureKind = "tool" -- 2696
			} -- 2696
		end -- 2693
		tsBuildRequestId = tsBuildRequestId + 1 -- 2697
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2698
		local done = false -- 2699
		local result = nil -- 2700
		local listener = Node() -- 2701
		listener:gslot("AppWS", function(event) -- 2702
			if event.type == "Receive" then -- 2703
				local res = json.decode(event.msg) -- 2704
				if res then -- 2704
					if res.name == "TranspileTS" and res.id == requestId then -- 2705
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2706
							local luaFile = Path:replaceExt(file, "lua") -- 2707
							if Content:save(luaFile, res.luaCode) then -- 2708
								result = { -- 2709
									success = true, -- 2709
									file = file -- 2709
								} -- 2709
							else -- 2711
								result = { -- 2711
									success = false, -- 2711
									file = file, -- 2711
									message = "failed to save " .. tostring(luaFile) -- 2711
								} -- 2711
							end -- 2708
						else -- 2713
							result = { -- 2713
								success = false, -- 2713
								file = file, -- 2713
								message = res.message or "Compiler returned no Lua output", -- 2713
								failureKind = _anon_func_9(res) -- 2713
							} -- 2713
						end -- 2706
						done = true -- 2714
					end -- 2705
				end -- 2704
			end -- 2703
		end) -- 2702
		emit("AppWS", "Send", json.encode({ -- 2715
			name = "TranspileTS", -- 2715
			id = requestId, -- 2715
			file = file, -- 2715
			content = content, -- 2715
			projectRoot = sourceRoot, -- 2715
			files = files -- 2715
		})) -- 2715
		local deadline = App.runningTime + 30 -- 2716
		wait(function() -- 2717
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2717
		end) -- 2717
		listener:removeFromParent() -- 2718
		if not done then -- 2719
			webIDECompilerReady = false -- 2720
			if isCancelled and isCancelled() then -- 2721
				return { -- 2722
					success = false, -- 2722
					file = file, -- 2722
					message = "build canceled", -- 2722
					interrupted = true -- 2722
				} -- 2722
			end -- 2721
			return { -- 2723
				success = false, -- 2723
				file = file, -- 2723
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2723
				failureKind = "tool" -- 2723
			} -- 2723
		end -- 2719
		return result -- 2724
	end -- 2692
end -- 2690
local compilerReadyTimeout <const> = 15 -- 2726
local compilerBuildTimeout <const> = 30 -- 2727
local compilerIdleCloseSeconds <const> = 8 -- 2728
local compilerReady = false -- 2729
local compilerRequested = false -- 2730
local compilerFailure = nil -- 2731
local compilerUsers = 0 -- 2732
local compilerCloseGeneration = 0 -- 2733
local compilerJobId = 0 -- 2734
local compilerJobs = { } -- 2735
local compilerResults = { } -- 2736
local compilerInFlight = { } -- 2737
HttpServer:post("/compiler/ready", function() -- 2739
	if not compilerRequested then -- 2740
		return { -- 2740
			success = false -- 2740
		} -- 2740
	end -- 2740
	compilerReady = true -- 2741
	return { -- 2742
		success = true -- 2742
	} -- 2742
end) -- 2739
HttpServer:post("/compiler/failure", function(req) -- 2744
	if not compilerRequested then -- 2745
		return { -- 2745
			success = false -- 2745
		} -- 2745
	end -- 2745
	do -- 2746
		local _type_0 = type(req) -- 2746
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2746
		if _tab_0 then -- 2746
			local message -- 2746
			do -- 2746
				local _obj_0 = req.body -- 2746
				local _type_1 = type(_obj_0) -- 2746
				if "table" == _type_1 or "userdata" == _type_1 then -- 2746
					message = _obj_0.message -- 2746
				end -- 2746
			end -- 2746
			if message ~= nil then -- 2746
				if type(message) == "string" then -- 2747
					compilerFailure = message -- 2748
					compilerReady = false -- 2749
					return { -- 2750
						success = true -- 2750
					} -- 2750
				end -- 2747
			end -- 2746
		end -- 2746
	end -- 2746
	return { -- 2744
		success = false -- 2744
	} -- 2744
end) -- 2744
HttpServer:postSchedule("/compiler/poll", function() -- 2752
	if not compilerRequested then -- 2753
		return { -- 2753
			success = false -- 2753
		} -- 2753
	end -- 2753
	compilerReady = true -- 2754
	local deadline = App.runningTime + 5 -- 2755
	wait(function() -- 2756
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2756
	end) -- 2756
	if not (compilerRequested and not compilerFailure) then -- 2757
		return { -- 2757
			success = false -- 2757
		} -- 2757
	end -- 2757
	local job = table.remove(compilerJobs, 1) -- 2758
	if job then -- 2759
		compilerInFlight[job.id] = true -- 2760
	end -- 2759
	return { -- 2761
		success = true, -- 2761
		job = job -- 2761
	} -- 2761
end) -- 2752
HttpServer:post("/compiler/result", function(req) -- 2763
	do -- 2764
		local _type_0 = type(req) -- 2764
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2764
		if _tab_0 then -- 2764
			local body = req.body -- 2764
			if body ~= nil then -- 2764
				local id = body.id -- 2765
				if not (id and compilerInFlight[id]) then -- 2766
					return { -- 2766
						success = false, -- 2766
						message = "invalid compiler job" -- 2766
					} -- 2766
				end -- 2766
				compilerInFlight[id] = nil -- 2767
				compilerResults[id] = body -- 2768
				return { -- 2769
					success = true -- 2769
				} -- 2769
			end -- 2764
		end -- 2764
	end -- 2764
	return { -- 2763
		success = false -- 2763
	} -- 2763
end) -- 2763
local acquireCompiler -- 2771
acquireCompiler = function() -- 2771
	compilerUsers = compilerUsers + 1 -- 2772
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2773
	if not compilerRequested then -- 2774
		compilerRequested = true -- 2775
		compilerReady = false -- 2776
		compilerFailure = nil -- 2777
		return emit("AppWebView", "/compiler.html", true) -- 2778
	end -- 2774
end -- 2771
local releaseCompiler -- 2780
releaseCompiler = function() -- 2780
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2781
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2782
	if not (compilerUsers == 0) then -- 2783
		return -- 2783
	end -- 2783
	local closeGeneration = compilerCloseGeneration -- 2784
	return thread(function() -- 2785
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2786
		wait(function() -- 2787
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2788
		end) -- 2787
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2793
			compilerRequested = false -- 2794
			compilerReady = false -- 2795
			return emit("AppWebView", "/compiler.html", false) -- 2796
		end -- 2793
	end) -- 2785
end -- 2780
local removeCompilerJob -- 2798
removeCompilerJob = function(id) -- 2798
	for index = #compilerJobs, 1, -1 do -- 2799
		if compilerJobs[index].id == id then -- 2800
			table.remove(compilerJobs, index) -- 2801
		end -- 2800
	end -- 2799
	compilerInFlight[id] = nil -- 2802
	compilerResults[id] = nil -- 2803
end -- 2798
local transpileTSFileWithCompiler -- 2805
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2805
	acquireCompiler() -- 2806
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2807
	wait(function() -- 2808
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2808
	end) -- 2808
	if not compilerReady then -- 2809
		releaseCompiler() -- 2810
		if isCancelled and isCancelled() then -- 2811
			return { -- 2812
				success = false, -- 2812
				file = file, -- 2812
				message = "build canceled", -- 2812
				interrupted = true -- 2812
			} -- 2812
		end -- 2811
		return { -- 2813
			success = false, -- 2813
			file = file, -- 2813
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2813
			failureKind = "tool" -- 2813
		} -- 2813
	end -- 2809
	compilerJobId = compilerJobId + 1 -- 2814
	local jobId = compilerJobId -- 2815
	compilerJobs[#compilerJobs + 1] = { -- 2817
		id = jobId, -- 2817
		file = file, -- 2818
		content = content, -- 2819
		projectRoot = sourceRoot, -- 2820
		files = files -- 2821
	} -- 2816
	local deadline = App.runningTime + compilerBuildTimeout -- 2822
	wait(function() -- 2823
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2823
	end) -- 2823
	local response = compilerResults[jobId] -- 2824
	removeCompilerJob(jobId) -- 2825
	releaseCompiler() -- 2826
	if not response then -- 2827
		if isCancelled and isCancelled() then -- 2828
			return { -- 2829
				success = false, -- 2829
				file = file, -- 2829
				message = "build canceled", -- 2829
				interrupted = true -- 2829
			} -- 2829
		end -- 2828
		return { -- 2830
			success = false, -- 2830
			file = file, -- 2830
			message = compilerFailure or "TypeScript transpile timed out", -- 2830
			failureKind = "tool" -- 2830
		} -- 2830
	end -- 2827
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2831
		local luaFile = Path:replaceExt(file, "lua") -- 2832
		if Content:save(luaFile, response.luaCode) then -- 2833
			return { -- 2834
				success = true, -- 2834
				file = file -- 2834
			} -- 2834
		end -- 2833
		return { -- 2835
			success = false, -- 2835
			file = file, -- 2835
			message = "failed to save " .. tostring(luaFile) -- 2835
		} -- 2835
	end -- 2831
	return { -- 2836
		success = false, -- 2836
		file = file, -- 2836
		message = response.message or "TypeScript transpile failed" -- 2836
	} -- 2836
end -- 2805
local compilerFailureListener = Node() -- 2838
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2839
	compilerFailure = message -- 2840
	compilerReady = false -- 2841
end) -- 2839
local transpileTSFile -- 2843
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2843
	if supportsCompilerWebView() and not files then -- 2844
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2845
	end -- 2844
	if HttpServer.wsConnectionCount > 0 then -- 2846
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2847
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2848
			return result -- 2848
		end -- 2848
		webIDECompilerReady = false -- 2849
	end -- 2846
	if supportsCompilerWebView() then -- 2850
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2851
	end -- 2850
	return { -- 2852
		success = false, -- 2852
		file = file, -- 2852
		message = "Web IDE compiler not connected", -- 2852
		failureKind = "tool" -- 2852
	} -- 2852
end -- 2843
local _anon_func_10 = function(path) -- 2867
	local _val_0 = Path:getExt(path) -- 2867
	return "ts" == _val_0 or "tsx" == _val_0 -- 2867
end -- 2867
HttpServer:postSchedule("/ts/build", function(req) -- 2854
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2855
	local buildSucceeded = false -- 2856
	local _ <close> = setmetatable({ }, { -- 2857
		__close = function() -- 2857
			return finishUpdate(buildSucceeded) -- 2857
		end -- 2857
	}) -- 2857
	do -- 2858
		local _type_0 = type(req) -- 2858
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2858
		if _tab_0 then -- 2858
			local path -- 2858
			do -- 2858
				local _obj_0 = req.body -- 2858
				local _type_1 = type(_obj_0) -- 2858
				if "table" == _type_1 or "userdata" == _type_1 then -- 2858
					path = _obj_0.path -- 2858
				end -- 2858
			end -- 2858
			if path ~= nil then -- 2858
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2859
					return { -- 2860
						success = false, -- 2860
						message = "Web IDE not connected" -- 2860
					} -- 2860
				end -- 2859
				local projectRoot = req.body.projectRoot -- 2861
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2862
				if not Content:exist(path) then -- 2863
					return { -- 2864
						success = false, -- 2864
						message = "path not existed" -- 2864
					} -- 2864
				end -- 2863
				local messages = { } -- 2865
				if not Content:isdir(path) then -- 2866
					if not (_anon_func_10(path)) then -- 2867
						return { -- 2868
							success = false, -- 2868
							message = "expecting a TypeScript file" -- 2868
						} -- 2868
					end -- 2867
					local content = Content:load(path) -- 2869
					if not content then -- 2870
						return { -- 2871
							success = false, -- 2871
							message = "failed to read file" -- 2871
						} -- 2871
					end -- 2870
					emit("AppWS", "Send", json.encode({ -- 2872
						name = "UpdateFile", -- 2872
						file = path, -- 2872
						exists = true, -- 2872
						content = content, -- 2872
						projectRoot = sourceRoot -- 2872
					})) -- 2872
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2873
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2874
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2875
					end -- 2873
				else -- 2877
					local fileData = { } -- 2877
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2878
					for _index_0 = 1, #_list_0 do -- 2878
						local subFile = _list_0[_index_0] -- 2878
						local file = Path(path, subFile) -- 2879
						local content = Content:load(file) -- 2880
						if content then -- 2880
							fileData[file] = content -- 2881
							emit("AppWS", "Send", json.encode({ -- 2882
								name = "UpdateFile", -- 2882
								file = file, -- 2882
								exists = true, -- 2882
								content = content, -- 2882
								projectRoot = sourceRoot -- 2882
							})) -- 2882
						else -- 2884
							messages[#messages + 1] = { -- 2884
								success = false, -- 2884
								file = file, -- 2884
								message = "failed to read file" -- 2884
							} -- 2884
						end -- 2880
					end -- 2878
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2885
					for file, content in pairs(fileData) do -- 2886
						if "d" == Path:getExt(Path:getName(file)) then -- 2887
							goto _continue_0 -- 2887
						end -- 2887
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2888
						::_continue_0:: -- 2887
					end -- 2886
				end -- 2866
				local success = true -- 2889
				for _index_0 = 1, #messages do -- 2890
					local item = messages[_index_0] -- 2890
					if not item.success then -- 2891
						success = false -- 2891
					end -- 2891
				end -- 2890
				local message = nil -- 2892
				if not success then -- 2893
					message = "TypeScript compilation failed" -- 2893
				end -- 2893
				buildSucceeded = success -- 2894
				return { -- 2895
					success = success, -- 2895
					messages = messages, -- 2895
					message = message -- 2895
				} -- 2895
			end -- 2858
		end -- 2858
	end -- 2858
	return { -- 2854
		success = false -- 2854
	} -- 2854
end) -- 2854
HttpServer:post("/download", function(req) -- 2897
	do -- 2898
		local _type_0 = type(req) -- 2898
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2898
		if _tab_0 then -- 2898
			local url -- 2898
			do -- 2898
				local _obj_0 = req.body -- 2898
				local _type_1 = type(_obj_0) -- 2898
				if "table" == _type_1 or "userdata" == _type_1 then -- 2898
					url = _obj_0.url -- 2898
				end -- 2898
			end -- 2898
			local target -- 2898
			do -- 2898
				local _obj_0 = req.body -- 2898
				local _type_1 = type(_obj_0) -- 2898
				if "table" == _type_1 or "userdata" == _type_1 then -- 2898
					target = _obj_0.target -- 2898
				end -- 2898
			end -- 2898
			if url ~= nil and target ~= nil then -- 2898
				local Entry = require("Script.Dev.Entry") -- 2899
				Entry.downloadFile(url, target) -- 2900
				return { -- 2901
					success = true -- 2901
				} -- 2901
			end -- 2898
		end -- 2898
	end -- 2898
	return { -- 2897
		success = false -- 2897
	} -- 2897
end) -- 2897
local isDesktopPlatform -- 2903
isDesktopPlatform = function() -- 2903
	local _val_0 = App.platform -- 2904
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2904
end -- 2903
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 2906
local nativeIDEListener = Node() -- 2907
nativeIDEListener:addTo(Director.systemUI) -- 2908
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 2909
	nativeIDEState, nativeIDEMessage = state, message -- 2910
end) -- 2909
local _anon_func_11 = function() -- 2913
	local _val_0 = App.platform -- 2913
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2913
end -- 2913
HttpServer:post("/ide", function(req) -- 2912
	if not (_anon_func_11()) then -- 2913
		return { -- 2913
			success = false, -- 2913
			message = "Native IDE is unavailable" -- 2913
		} -- 2913
	end -- 2913
	if not App.webIDEEnabled then -- 2914
		return { -- 2914
			success = false, -- 2914
			message = "Embedded Web IDE is disabled" -- 2914
		} -- 2914
	end -- 2914
	do -- 2915
		local _type_0 = type(req) -- 2915
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2915
		if _tab_0 then -- 2915
			local action -- 2915
			do -- 2915
				local _obj_0 = req.body -- 2915
				local _type_1 = type(_obj_0) -- 2915
				if "table" == _type_1 or "userdata" == _type_1 then -- 2915
					action = _obj_0.action -- 2915
				end -- 2915
			end -- 2915
			if action ~= nil then -- 2915
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 2916
					emit("AppWebView", "/ide/" .. action, true) -- 2917
					return { -- 2918
						success = true -- 2918
					} -- 2918
				end -- 2916
			end -- 2915
		end -- 2915
	end -- 2915
	return { -- 2912
		success = false, -- 2912
		message = "invalid IDE action" -- 2912
	} -- 2912
end) -- 2912
local _anon_func_12 = function() -- 2934
	local _val_0 = App.platform -- 2934
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2934
end -- 2934
local getServerStatus -- 2920
getServerStatus = function() -- 2920
	local Entry = require("Script.Dev.Entry") -- 2921
	local running = Entry.getCurrentEntryStatus() -- 2922
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2923
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2924
	return { -- 2926
		success = true, -- 2926
		platform = App.platform, -- 2927
		locale = App.locale, -- 2928
		version = App.version, -- 2929
		url = "http://localhost:8866", -- 2930
		wsConnectionCount = wsConnectionCount, -- 2931
		webIDEConnected = wsConnectionCount > 0, -- 2932
		nativeIDE = { -- 2934
			supported = _anon_func_12(), -- 2934
			enabled = App.webIDEEnabled, -- 2935
			state = nativeIDEState, -- 2936
			message = nativeIDEMessage -- 2937
		}, -- 2933
		typescriptCompiler = { -- 2939
			webIDEReady = webIDECompilerReady, -- 2939
			webIDEGeneration = webIDEConnectionGeneration, -- 2940
			embeddedSupported = supportsCompilerWebView(), -- 2941
			embeddedRequested = compilerRequested, -- 2942
			embeddedReady = compilerReady, -- 2943
			users = compilerUsers, -- 2944
			queuedJobs = #compilerJobs, -- 2945
			failure = compilerFailure -- 2946
		}, -- 2938
		assetPath = Content.assetPath, -- 2947
		writablePath = Content.writablePath, -- 2948
		appPath = Content.appPath, -- 2949
		waTemplateReady = waTemplateReady, -- 2950
		running = running -- 2951
	} -- 2925
end -- 2920
HttpServer:post("/status", function() -- 2954
	return getServerStatus() -- 2955
end) -- 2954
HttpServer:postSchedule("/doctor/fix", function(req) -- 2957
	do -- 2958
		local _type_0 = type(req) -- 2958
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2958
		if _tab_0 then -- 2958
			local openWebIDE -- 2958
			do -- 2958
				local _obj_0 = req.body -- 2958
				local _type_1 = type(_obj_0) -- 2958
				if "table" == _type_1 or "userdata" == _type_1 then -- 2958
					openWebIDE = _obj_0.openWebIDE -- 2958
				end -- 2958
			end -- 2958
			if openWebIDE ~= nil then -- 2958
				if not openWebIDE then -- 2959
					return { -- 2960
						success = false, -- 2960
						message = "nothing to fix" -- 2960
					} -- 2960
				end -- 2959
				local status = getServerStatus() -- 2961
				if status.webIDEConnected then -- 2962
					return { -- 2963
						success = true, -- 2963
						fixed = false, -- 2963
						message = "Web IDE already connected.", -- 2963
						status = status -- 2963
					} -- 2963
				end -- 2962
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2964
				if waitSeconds > 0 then -- 2965
					local deadline = os.time() + waitSeconds -- 2966
					repeat -- 2967
						sleep(0.2) -- 2968
						status = getServerStatus() -- 2969
						if status.webIDEConnected then -- 2970
							return { -- 2971
								success = true, -- 2971
								fixed = false, -- 2971
								reconnected = true, -- 2971
								message = "Web IDE reconnected.", -- 2971
								status = status -- 2971
							} -- 2971
						end -- 2970
					until os.time() >= deadline -- 2967
				end -- 2965
				if not isDesktopPlatform() then -- 2973
					return { -- 2974
						success = false, -- 2974
						message = "opening Web IDE is only supported on desktop platforms", -- 2974
						status = status -- 2974
					} -- 2974
				end -- 2973
				local url = "http://localhost:8866" -- 2975
				App:openURL(url) -- 2976
				status.openedURL = url -- 2977
				return { -- 2978
					success = true, -- 2978
					fixed = true, -- 2978
					message = "Opened Web IDE in the local browser.", -- 2978
					url = url, -- 2978
					status = status -- 2978
				} -- 2978
			end -- 2958
		end -- 2958
	end -- 2958
	return { -- 2957
		success = false, -- 2957
		message = "invalid call" -- 2957
	} -- 2957
end) -- 2957
local status = { } -- 2980
_module_0 = status -- 2981
status.transpileTSFile = transpileTSFile -- 2983
status.buildAsync = function(path) -- 2985
	if not Content:exist(path) then -- 2986
		return { -- 2987
			success = false, -- 2987
			file = path, -- 2987
			message = "file not existed" -- 2987
		} -- 2987
	end -- 2986
	do -- 2988
		local _exp_0 = Path:getExt(path) -- 2988
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2988
			if '' == Path:getExt(Path:getName(path)) then -- 2989
				local content = Content:loadAsync(path) -- 2990
				if content then -- 2990
					local resultCodes, err = compileFileAsync(path, content) -- 2991
					if resultCodes then -- 2991
						return { -- 2992
							success = true, -- 2992
							file = path -- 2992
						} -- 2992
					else -- 2994
						return { -- 2994
							success = false, -- 2994
							file = path, -- 2994
							message = err -- 2994
						} -- 2994
					end -- 2991
				end -- 2990
			end -- 2989
		elseif "lua" == _exp_0 then -- 2995
			local content = Content:loadAsync(path) -- 2996
			if content then -- 2996
				do -- 2997
					local isTIC80 = CheckTIC80Code(content) -- 2997
					if isTIC80 then -- 2997
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2998
					end -- 2997
				end -- 2997
				local success, info -- 2999
				do -- 2999
					local _obj_0 = luaCheck(path, content) -- 2999
					success, info = _obj_0.success, _obj_0.info -- 2999
				end -- 2999
				if success then -- 3000
					return { -- 3001
						success = true, -- 3001
						file = path -- 3001
					} -- 3001
				elseif info and #info > 0 then -- 3002
					local messages = { } -- 3003
					for _index_0 = 1, #info do -- 3004
						local _des_0 = info[_index_0] -- 3004
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3004
						local lineText = "" -- 3005
						if line then -- 3006
							local currentLine = 1 -- 3007
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3008
								if currentLine == line then -- 3009
									lineText = text -- 3010
									break -- 3011
								end -- 3009
								currentLine = currentLine + 1 -- 3012
							end -- 3008
						end -- 3006
						if line then -- 3013
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3014
						else -- 3016
							messages[#messages + 1] = message -- 3016
						end -- 3013
					end -- 3004
					return { -- 3017
						success = false, -- 3017
						file = path, -- 3017
						message = table.concat(messages, "\n") -- 3017
					} -- 3017
				else -- 3019
					return { -- 3019
						success = false, -- 3019
						file = path, -- 3019
						message = "lua check failed" -- 3019
					} -- 3019
				end -- 3000
			end -- 2996
		elseif "yarn" == _exp_0 then -- 3020
			local content = Content:loadAsync(path) -- 3021
			if content then -- 3021
				local res, _, err = yarncompile(content, true) -- 3022
				if res then -- 3022
					return { -- 3023
						success = true, -- 3023
						file = path -- 3023
					} -- 3023
				else -- 3025
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3025
					local lineText = "" -- 3026
					if line then -- 3027
						local currentLine = 1 -- 3028
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3029
							if currentLine == line then -- 3030
								lineText = text -- 3031
								break -- 3032
							end -- 3030
							currentLine = currentLine + 1 -- 3033
						end -- 3029
					end -- 3027
					if node ~= "" then -- 3034
						node = "node: " .. tostring(node) .. ", " -- 3035
					else -- 3036
						node = "" -- 3036
					end -- 3034
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3037
					return { -- 3038
						success = false, -- 3038
						file = path, -- 3038
						message = message -- 3038
					} -- 3038
				end -- 3022
			end -- 3021
		end -- 2988
	end -- 2988
	return { -- 3039
		success = false, -- 3039
		file = path, -- 3039
		message = "invalid file to build" -- 3039
	} -- 3039
end -- 2985
HttpServer:postSchedule("/git/commit-files", function(req) -- 3041
	do -- 3042
		local _type_0 = type(req) -- 3042
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3042
		if _tab_0 then -- 3042
			local body = req.body -- 3042
			if body ~= nil then -- 3042
				local repoPath, commit = body.repoPath, body.commit -- 3043
				if gitInvalidRepoPath(repoPath) then -- 3044
					return { -- 3044
						success = false, -- 3044
						message = "invalid repoPath" -- 3044
					} -- 3044
				end -- 3044
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3045
					return { -- 3045
						success = false, -- 3045
						message = "invalid commit" -- 3045
					} -- 3045
				end -- 3045
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3046
				if not res.success then -- 3047
					return res -- 3047
				end -- 3047
				return { -- 3048
					success = true, -- 3048
					status = res.status, -- 3048
					data = res.status and res.status.data -- 3048
				} -- 3048
			end -- 3042
		end -- 3042
	end -- 3042
	return invalidArguments -- 3041
end) -- 3041
thread(function() -- 3050
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3051
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3052
	if Content:exist(doraWeb) then -- 3053
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3054
		local heavyAssetsContent -- 3055
		if Content:exist(heavyAssets) then -- 3055
			heavyAssetsContent = Content:load(heavyAssets) -- 3055
		else -- 3055
			heavyAssetsContent = "" -- 3055
		end -- 3055
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3056
		local runtimeIndexContent -- 3057
		if Content:exist(runtimeIndex) then -- 3057
			runtimeIndexContent = Content:load(runtimeIndex) -- 3057
		else -- 3057
			runtimeIndexContent = "" -- 3057
		end -- 3057
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3058
		local compilerIndexContent -- 3059
		if Content:exist(compilerIndex) then -- 3059
			compilerIndexContent = Content:load(compilerIndex) -- 3059
		else -- 3059
			compilerIndexContent = "" -- 3059
		end -- 3059
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) .. "\n" .. heavyAssetsContent .. "\n" .. runtimeIndexContent .. "\n" .. compilerIndexContent -- 3060
		local needReload -- 3061
		if Content:exist(doraReady) then -- 3061
			needReload = readyContent ~= Content:load(doraReady) -- 3062
		else -- 3063
			needReload = true -- 3063
		end -- 3061
		if needReload then -- 3064
			Content:remove(Path(Content.appPath, ".www")) -- 3065
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3066
			Content:save(doraReady, readyContent) -- 3070
			print("Dora Dora is ready!") -- 3071
		end -- 3064
	end -- 3053
	if App.platform == "Emscripten" then -- 3072
		status.url = nil -- 3073
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3074
	end -- 3072
	HttpServer:clearStaticCacheControls() -- 3075
	HttpServer:setStaticCacheControl("no-cache") -- 3076
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3077
	if HttpServer:start(8866) then -- 3081
		local localIP = HttpServer.localIP -- 3082
		if localIP == "" then -- 3083
			localIP = "localhost" -- 3083
		end -- 3083
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3084
		return HttpServer:startWS(8868) -- 3085
	else -- 3087
		status.url = nil -- 3087
		return print("8866 Port not available!") -- 3088
	end -- 3081
end) -- 3050
return _module_0 -- 1
