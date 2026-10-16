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
local gitInvalidRepoPath -- 158
gitInvalidRepoPath = function(repoPath) -- 158
	return not repoPath or repoPath == "" or not Content:isAbsolutePath(repoPath) -- 159
end -- 158
local gitShellSplit -- 161
gitShellSplit = function(command) -- 161
	local args = { } -- 162
	local current = { } -- 163
	local quote = nil -- 164
	local escape = false -- 165
	for i = 1, #command do -- 166
		local ch = command:sub(i, i) -- 167
		if escape then -- 168
			current[#current + 1] = ch -- 169
			escape = false -- 170
		elseif ch == "\\" then -- 171
			escape = true -- 172
		elseif quote then -- 173
			if ch == quote then -- 174
				quote = nil -- 175
			else -- 177
				current[#current + 1] = ch -- 177
			end -- 174
		elseif ch == "'" or ch == '"' then -- 178
			quote = ch -- 179
		elseif ch:match("%s") then -- 180
			if #current > 0 then -- 181
				args[#args + 1] = table.concat(current) -- 182
				current = { } -- 183
			end -- 181
		else -- 185
			current[#current + 1] = ch -- 185
		end -- 168
	end -- 166
	if #current > 0 then -- 186
		args[#args + 1] = table.concat(current) -- 187
	end -- 186
	if args[1] == "git" then -- 188
		table.remove(args, 1) -- 189
	end -- 188
	return args -- 190
end -- 161
local gitQuote -- 192
gitQuote = function(value) -- 192
	local text = tostring(value) -- 193
	if text:match("^[%w%._%-%/]+$") then -- 194
		return text -- 195
	end -- 194
	return "\"" .. text:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\"" -- 196
end -- 192
local gitDirNonEmpty -- 198
gitDirNonEmpty = function(targetPath) -- 198
	if not Content:exist(targetPath) then -- 199
		return false -- 199
	end -- 199
	if not Content:isdir(targetPath) then -- 200
		return false -- 200
	end -- 200
	return #Content:getFiles(targetPath) > 0 or #Content:getDirs(targetPath) > 0 -- 201
end -- 198
local gitSafeChildPath -- 203
gitSafeChildPath = function(parentPath, childPath) -- 203
	if not (parentPath and childPath and childPath ~= "") then -- 204
		return nil -- 204
	end -- 204
	if childPath:sub(1, 1) == "/" or childPath:match("^%a:[/\\]") then -- 205
		return nil -- 205
	end -- 205
	if childPath == "." or childPath:match("^%.%.[/\\]?" or childPath:match("[/\\]%.%.[/\\]")) then -- 206
		return nil -- 206
	end -- 206
	local targetPath = Path(parentPath, childPath) -- 207
	local relative = Path:getRelative(targetPath, parentPath) -- 208
	if relative == ".." or relative:sub(1, 3) == "../" or relative:sub(1, 3) == "..\\" then -- 209
		return nil -- 209
	end -- 209
	return targetPath -- 210
end -- 203
local gitCloneDirFromURL -- 212
gitCloneDirFromURL = function(url) -- 212
	if not (url and url ~= "") then -- 213
		return nil -- 213
	end -- 213
	local text = tostring(url):match("^%s*(.-)%s*$") -- 214
	if text == "" then -- 215
		return nil -- 215
	end -- 215
	text = text:gsub("[/\\]+$", "") -- 216
	local name = text:match("([^/:]+)$") -- 217
	if not (name and name ~= "") then -- 218
		return nil -- 218
	end -- 218
	name = name:gsub("%.git$", "") -- 219
	if name == "" or name == "." or name == ".." then -- 220
		return nil -- 220
	end -- 220
	return name -- 221
end -- 212
local gitCloneTargetPath -- 223
gitCloneTargetPath = function(repoPath, command) -- 223
	local args = gitShellSplit(command) -- 224
	if not (args[1] == "clone") then -- 225
		return nil -- 225
	end -- 225
	local url = args[2] -- 226
	local index = 3 -- 227
	while index <= #args do -- 228
		local arg = args[index] -- 229
		if ("-b" == arg or "--branch" == arg or "--depth" == arg) then -- 230
			index = index + 2 -- 231
		elseif arg:sub(1, 1) == "-" then -- 232
			index = index + 1 -- 233
		else -- 235
			return gitSafeChildPath(repoPath, arg) -- 235
		end -- 230
	end -- 228
	do -- 236
		local dirName = gitCloneDirFromURL(url) -- 236
		if dirName then -- 236
			return gitSafeChildPath(repoPath, dirName) -- 237
		end -- 236
	end -- 236
	return nil -- 238
end -- 223
local gitPathInsideRepo -- 240
gitPathInsideRepo = function(repoPath, relPath) -- 240
	if not (repoPath and relPath and relPath ~= "") then -- 241
		return false -- 241
	end -- 241
	if relPath:sub(1, 1) == "/" or relPath:match("^%a:[/\\]") then -- 242
		return false -- 242
	end -- 242
	if relPath == "." or relPath:match("^%.%.[/\\]?" or relPath:match("[/\\]%.%.[/\\]")) then -- 243
		return false -- 243
	end -- 243
	local targetPath = Path(repoPath, relPath) -- 244
	local relative = Path:getRelative(targetPath, repoPath) -- 245
	return relative ~= ".." and relative:sub(1, 3) ~= "../" and relative:sub(1, 3) ~= "..\\" -- 246
end -- 240
local gitHostFromURL -- 248
gitHostFromURL = function(url) -- 248
	if not (url and url ~= "") then -- 249
		return nil -- 249
	end -- 249
	local text = tostring(url):match("^%s*(.-)%s*$") -- 250
	if text == "" then -- 251
		return nil -- 251
	end -- 251
	local host = text:match("^[%w_%-]+://([^/:]+)") -- 252
	if not host then -- 253
		host = text:match("@([^:/]+)[:/]") -- 253
	end -- 253
	if not host then -- 254
		host = text:match("^([^:/]+):[^/]") -- 254
	end -- 254
	if not (host and host ~= "") then -- 255
		return nil -- 255
	end -- 255
	return string.lower(host) -- 256
end -- 248
local ensureGitTables -- 258
ensureGitTables = function() -- 258
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
	]]) -- 259
	DB:exec("CREATE INDEX IF NOT EXISTS idx_git_credential_host ON GitCredential(host);") -- 272
	return DB:exec([[		CREATE TABLE IF NOT EXISTS GitProfile(
			id INTEGER PRIMARY KEY CHECK(id = 1),
			name TEXT NOT NULL DEFAULT '',
			email TEXT NOT NULL DEFAULT '',
			updated_at INTEGER
		);
	]]) -- 273
end -- 258
local gitCredentialToPublic -- 282
gitCredentialToPublic = function(row) -- 282
	local id, host, label, typeName, username, createdAt, updatedAt, lastUsedAt = row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8] -- 283
	return { -- 284
		id = id, -- 284
		host = host, -- 284
		label = label, -- 284
		type = typeName, -- 284
		username = username, -- 284
		createdAt = createdAt, -- 284
		updatedAt = updatedAt, -- 284
		lastUsedAt = lastUsedAt -- 284
	} -- 284
end -- 282
local gitLoadCredential -- 286
gitLoadCredential = function(id) -- 286
	ensureGitTables() -- 287
	local credentialId = tonumber(id) or 0 -- 288
	local rows = DB:query("select id, host, label, type, username, secret from GitCredential where id = ? limit 1", { -- 289
		credentialId -- 289
	}) -- 289
	if not (rows and rows[1]) then -- 290
		return nil -- 290
	end -- 290
	local row = rows[1] -- 291
	return { -- 292
		id = row[1], -- 292
		host = row[2], -- 292
		label = row[3], -- 292
		type = row[4], -- 292
		username = row[5], -- 292
		secret = row[6] -- 292
	} -- 292
end -- 286
local gitAuthOptionsJSON -- 294
gitAuthOptionsJSON = function(credential) -- 294
	if not credential then -- 295
		return nil -- 295
	end -- 295
	local auth -- 296
	if credential.type == "token" then -- 296
		auth = { -- 298
			type = "token", -- 298
			token = credential.secret, -- 299
			username = credential.username ~= "" and credential.username or "token" -- 300
		} -- 297
	else -- 303
		auth = { -- 304
			type = "basic", -- 304
			username = credential.username, -- 305
			password = credential.secret -- 306
		} -- 303
	end -- 296
	return json.encode({ -- 308
		auth = auth -- 308
	}) -- 308
end -- 294
local gitLoadProfile -- 310
gitLoadProfile = function() -- 310
	ensureGitTables() -- 311
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 312
	if not (rows and rows[1]) then -- 313
		return nil -- 313
	end -- 313
	local name = tostring(rows[1][1] or "") -- 314
	local email = tostring(rows[1][2] or "") -- 315
	if name == "" and email == "" then -- 316
		return nil -- 316
	end -- 316
	return { -- 317
		name = name, -- 317
		email = email -- 317
	} -- 317
end -- 310
local _anon_func_2 = function(args, gitQuote) -- 336
	local _accum_0 = { } -- 336
	local _len_0 = 1 -- 336
	for _index_0 = 1, #args do -- 336
		local arg = args[_index_0] -- 336
		_accum_0[_len_0] = gitQuote(arg) -- 336
		_len_0 = _len_0 + 1 -- 336
	end -- 336
	return _accum_0 -- 336
end -- 336
local gitApplyProfileToCommit -- 319
gitApplyProfileToCommit = function(command) -- 319
	local args = gitShellSplit(command) -- 320
	if not (args[1] == "commit") then -- 321
		return command -- 321
	end -- 321
	local hasName = false -- 322
	local hasEmail = false -- 323
	for _index_0 = 1, #args do -- 324
		local arg = args[_index_0] -- 324
		if arg == "--author-name" then -- 325
			hasName = true -- 325
		end -- 325
		if arg == "--author-email" then -- 326
			hasEmail = true -- 326
		end -- 326
	end -- 324
	if hasName and hasEmail then -- 327
		return command -- 327
	end -- 327
	local profile = gitLoadProfile() -- 328
	if not profile then -- 329
		return command -- 329
	end -- 329
	if not hasName and profile.name ~= "" then -- 330
		args[#args + 1] = "--author-name" -- 331
		args[#args + 1] = profile.name -- 332
	end -- 330
	if not hasEmail and profile.email ~= "" then -- 333
		args[#args + 1] = "--author-email" -- 334
		args[#args + 1] = profile.email -- 335
	end -- 333
	return table.concat(_anon_func_2(args, gitQuote), " ") -- 336
end -- 319
local gitStartJob -- 338
gitStartJob = function(repoPath, command, optionsJSON) -- 338
	if optionsJSON == nil then -- 338
		optionsJSON = nil -- 338
	end -- 338
	if gitInvalidRepoPath(repoPath) then -- 339
		return nil, "invalid repoPath" -- 339
	end -- 339
	if not (command and command ~= "") then -- 340
		return nil, "invalid command" -- 340
	end -- 340
	if not optionsJSON then -- 341
		optionsJSON = "" -- 341
	end -- 341
	command = gitApplyProfileToCommit(command) -- 342
	do -- 343
		local targetPath = gitCloneTargetPath(repoPath, command) -- 343
		if targetPath then -- 343
			if gitDirNonEmpty(targetPath) then -- 344
				return nil, "clone target directory is not empty" -- 345
			end -- 344
		elseif (gitShellSplit(command))[1] == "clone" then -- 346
			return nil, "invalid clone target" -- 347
		end -- 343
	end -- 343
	local statusRef = nil -- 348
	local startGit -- 349
	startGit = function() -- 349
		return Git:run(repoPath, command, (function(status) -- 350
			statusRef = status -- 351
			GitJobs[status.id] = { -- 353
				command = command, -- 353
				status = status, -- 354
				updatedAt = os.time() -- 355
			} -- 352
		end), optionsJSON) -- 350
	end -- 349
	local success, jobId = pcall(startGit) -- 357
	if not success then -- 358
		return nil, tostring(jobId) -- 358
	end -- 358
	if not jobId then -- 359
		return nil, "Git.run did not return a job id" -- 359
	end -- 359
	GitJobs[jobId] = { -- 361
		command = command, -- 361
		status = statusRef or { -- 363
			id = jobId, -- 363
			state = "queued", -- 364
			kind = gitShellSplit(command)[1] or "status", -- 365
			repoPath = repoPath, -- 366
			progress = 0, -- 367
			message = "queued" -- 368
		}, -- 362
		updatedAt = os.time() -- 370
	} -- 360
	return jobId -- 371
end -- 338
local gitRunSync -- 373
gitRunSync = function(repoPath, command, optionsJSON, timeout) -- 373
	if optionsJSON == nil then -- 373
		optionsJSON = nil -- 373
	end -- 373
	if timeout == nil then -- 373
		timeout = 20 -- 373
	end -- 373
	local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 374
	if not jobId then -- 375
		return { -- 375
			success = false, -- 375
			message = err -- 375
		} -- 375
	end -- 375
	local startedAt = os.time() -- 376
	wait(function() -- 377
		local job = GitJobs[jobId] -- 378
		local status = job and job.status -- 379
		return gitTerminalState(status) or os.time() - startedAt >= timeout -- 380
	end) -- 377
	local status = GitJobs[jobId] and GitJobs[jobId].status -- 381
	if not gitTerminalState(status) then -- 382
		Git:cancel(jobId) -- 383
		return { -- 384
			success = false, -- 384
			message = "git command timed out", -- 384
			jobId = jobId, -- 384
			status = status -- 384
		} -- 384
	end -- 382
	return { -- 385
		success = status.state == "done", -- 385
		jobId = jobId, -- 385
		status = status, -- 385
		message = status.error or status.message -- 385
	} -- 385
end -- 373
local gitCredentialsForHost -- 387
gitCredentialsForHost = function(host) -- 387
	if not (host and host ~= "") then -- 388
		return { } -- 388
	end -- 388
	ensureGitTables() -- 389
	local rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by last_used_at desc, label asc, id asc", { -- 390
		host -- 390
	}) -- 390
	if rows then -- 391
		local _accum_0 = { } -- 392
		local _len_0 = 1 -- 392
		for _index_0 = 1, #rows do -- 392
			local row = rows[_index_0] -- 392
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 392
			_len_0 = _len_0 + 1 -- 392
		end -- 392
		return _accum_0 -- 392
	else -- 393
		return { } -- 393
	end -- 391
end -- 387
local gitFirstRemoteURL -- 395
gitFirstRemoteURL = function(repoPath, remoteName) -- 395
	if remoteName == nil then -- 395
		remoteName = nil -- 395
	end -- 395
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 10) -- 396
	local data = remoteRes.status and remoteRes.status.data -- 397
	if not (data and data.remotes) then -- 398
		return nil -- 398
	end -- 398
	local _list_0 = data.remotes -- 399
	for _index_0 = 1, #_list_0 do -- 399
		local remote = _list_0[_index_0] -- 399
		if (not remoteName or remote.name == remoteName) and remote.urls and remote.urls[1] then -- 400
			return remote.urls[1] -- 401
		end -- 400
	end -- 399
	return nil -- 402
end -- 395
local gitConfigRemoteURL -- 404
gitConfigRemoteURL = function(repoPath, remoteName) -- 404
	if remoteName == nil then -- 404
		remoteName = nil -- 404
	end -- 404
	if gitInvalidRepoPath(repoPath) then -- 405
		return nil -- 405
	end -- 405
	local configPath = Path(repoPath, ".git/config") -- 406
	if not Content:exist(configPath) then -- 407
		return nil -- 407
	end -- 407
	local content = Content:load(configPath) -- 408
	if not (content and content ~= "") then -- 409
		return nil -- 409
	end -- 409
	local currentRemote = nil -- 410
	for line in content:gmatch("[^\r\n]+") do -- 411
		local sectionRemote = line:match('^%s*%[remote%s+"([^"]+)"%]%s*$') -- 412
		if sectionRemote then -- 413
			currentRemote = sectionRemote -- 414
		elseif currentRemote and (not remoteName or currentRemote == remoteName) then -- 415
			local url = line:match("^%s*url%s*=%s*(.-)%s*$") -- 416
			if url and url ~= "" then -- 417
				return url -- 417
			end -- 417
		end -- 413
	end -- 411
	return nil -- 418
end -- 404
local gitCommandRemoteArg -- 420
gitCommandRemoteArg = function(args, startIndex) -- 420
	if startIndex == nil then -- 420
		startIndex = 2 -- 420
	end -- 420
	local index = startIndex -- 421
	while index <= #args do -- 422
		local arg = args[index] -- 423
		if ("-u" == arg or "--set-upstream" == arg or "-f" == arg or "--force" == arg or "--all" == arg or "--prune" == arg) then -- 424
			index = index + 1 -- 425
		elseif ("--depth" == arg or "-b" == arg or "--branch" == arg) then -- 426
			index = index + 2 -- 427
		elseif arg and arg:sub(1, 1) == "-" then -- 428
			index = index + 1 -- 429
		else -- 431
			return arg -- 431
		end -- 424
	end -- 422
	return nil -- 432
end -- 420
local gitCommandHost -- 434
gitCommandHost = function(repoPath, command) -- 434
	local args = gitShellSplit(command) -- 435
	if not args[1] then -- 436
		return nil -- 436
	end -- 436
	do -- 437
		local _exp_0 = args[1] -- 437
		if "clone" == _exp_0 or "ls-remote" == _exp_0 then -- 438
			return gitHostFromURL(args[2]) -- 439
		elseif "fetch" == _exp_0 or "pull" == _exp_0 or "push" == _exp_0 then -- 440
			local remoteArg = gitCommandRemoteArg(args, 2) -- 441
			if not remoteArg then -- 442
				return nil -- 442
			end -- 442
			local url = gitHostFromURL(remoteArg) -- 443
			if url then -- 444
				return url -- 444
			end -- 444
			return gitHostFromURL(gitConfigRemoteURL(repoPath, remoteArg)) -- 445
		end -- 437
	end -- 437
	return nil -- 446
end -- 434
local gitAuthSelectionForCommand -- 448
gitAuthSelectionForCommand = function(repoPath, command) -- 448
	local host = gitCommandHost(repoPath, command) -- 449
	if not host then -- 450
		return nil -- 450
	end -- 450
	local items = gitCredentialsForHost(host) -- 451
	if #items == 0 then -- 452
		return nil -- 452
	end -- 452
	return { -- 453
		host = host, -- 453
		items = items -- 453
	} -- 453
end -- 448
local gitDefaultRemote -- 455
gitDefaultRemote = function(remoteStatus) -- 455
	local data = remoteStatus and remoteStatus.data -- 456
	if not (data and data.remotes and data.remotes[1]) then -- 457
		return nil -- 457
	end -- 457
	return data.remotes[1] -- 458
end -- 455
local gitCurrentBranch -- 460
gitCurrentBranch = function(branchStatus) -- 460
	local data = branchStatus and branchStatus.data -- 461
	if data and data.current and data.current ~= "" then -- 462
		return data.current -- 463
	end -- 462
	if data and data.branches then -- 464
		local _list_0 = data.branches -- 465
		for _index_0 = 1, #_list_0 do -- 465
			local branch = _list_0[_index_0] -- 465
			if branch.current then -- 466
				return branch.name -- 466
			end -- 466
		end -- 465
	end -- 464
	return nil -- 467
end -- 460
local gitHeadBranch -- 469
gitHeadBranch = function(repoPath) -- 469
	if gitInvalidRepoPath(repoPath) then -- 470
		return nil -- 470
	end -- 470
	local headPath = Path(repoPath, ".git", "HEAD") -- 471
	if not Content:exist(headPath) then -- 472
		return nil -- 472
	end -- 472
	local head = Content:load(headPath) -- 473
	if not head then -- 474
		return nil -- 474
	end -- 474
	local branch = head:match("^ref:%s*refs/heads/(.-)%s*$") -- 475
	if branch and branch ~= "" then -- 476
		return branch -- 476
	end -- 476
	return nil -- 477
end -- 469
local gitBranchesWithHead -- 479
gitBranchesWithHead = function(branchStatus, currentBranch) -- 479
	local branches = branchStatus and branchStatus.data and branchStatus.data.branches or { } -- 480
	if not (currentBranch and currentBranch ~= "") then -- 481
		return branches -- 481
	end -- 481
	for _index_0 = 1, #branches do -- 482
		local branch = branches[_index_0] -- 482
		if branch.name == currentBranch then -- 483
			return branches -- 483
		end -- 483
	end -- 482
	local withHead -- 484
	do -- 484
		local _accum_0 = { } -- 484
		local _len_0 = 1 -- 484
		for _index_0 = 1, #branches do -- 484
			local branch = branches[_index_0] -- 484
			_accum_0[_len_0] = branch -- 484
			_len_0 = _len_0 + 1 -- 484
		end -- 484
		withHead = _accum_0 -- 484
	end -- 484
	withHead[#withHead + 1] = { -- 485
		name = currentBranch, -- 485
		current = true, -- 485
		unborn = true -- 485
	} -- 485
	return withHead -- 486
end -- 479
local gitStatusMeansNotRepo -- 488
gitStatusMeansNotRepo = function(statusRes) -- 488
	local message = statusRes and (statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message)) or "" -- 489
	message = tostring(message):lower() -- 490
	return message:find("repository does not exist", 1, true) or message:find("not a git repository", 1, true) -- 491
end -- 488
local gitSummary -- 493
gitSummary = function(repoPath) -- 493
	local statusRes = gitRunSync(repoPath, "status", nil, 120) -- 494
	if not statusRes.success then -- 495
		if gitStatusMeansNotRepo(statusRes) then -- 496
			return { -- 497
				success = true, -- 497
				isRepo = false, -- 497
				message = statusRes.message, -- 497
				status = statusRes.status -- 497
			} -- 497
		end -- 496
		return { -- 498
			success = false, -- 498
			message = statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message) or "failed to check Git repository", -- 498
			status = statusRes.status -- 498
		} -- 498
	end -- 495
	local branchRes = gitRunSync(repoPath, "branch", nil, 120) -- 499
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 120) -- 500
	local status = statusRes.status -- 501
	local branchStatus = branchRes.status -- 502
	local remoteStatus = remoteRes.status -- 503
	local currentBranch = gitCurrentBranch(branchStatus) or gitHeadBranch(repoPath) -- 504
	local branches = gitBranchesWithHead(branchStatus, currentBranch) -- 505
	local logRes = gitRunSync(repoPath, "log --metadata-only -n 100", nil, 120) -- 506
	local logStatus -- 507
	if logRes.success then -- 507
		logStatus = logRes.status -- 508
	else -- 510
		logStatus = { -- 511
			state = "done", -- 511
			kind = "log", -- 512
			repoPath = repoPath, -- 513
			progress = 1, -- 514
			message = "git log completed", -- 515
			data = { -- 516
				commits = { } -- 516
			} -- 516
		} -- 510
	end -- 507
	local hasCommit = logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] ~= nil -- 518
	local tagStatus -- 519
	if hasCommit then -- 519
		tagStatus = (gitRunSync(repoPath, "tag", nil, 120)).status -- 520
	else -- 522
		tagStatus = { -- 523
			state = "done", -- 523
			kind = "tag", -- 524
			repoPath = repoPath, -- 525
			progress = 1, -- 526
			message = "git tag completed", -- 527
			data = { -- 528
				tags = { } -- 528
			} -- 528
		} -- 522
	end -- 519
	local defaultRemote = gitDefaultRemote(remoteStatus) -- 530
	local lastCommit = nil -- 531
	if logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] then -- 532
		lastCommit = logStatus.data.commits[1] -- 533
	end -- 532
	return { -- 535
		success = true, -- 535
		isRepo = true, -- 536
		clean = status.data and status.data.clean or false, -- 537
		currentBranch = currentBranch, -- 538
		defaultRemote = defaultRemote, -- 539
		remotes = remoteStatus and remoteStatus.data and remoteStatus.data.remotes or { }, -- 540
		branches = branches, -- 541
		lastCommit = lastCommit, -- 542
		status = status, -- 543
		branchStatus = branchStatus, -- 544
		remoteStatus = remoteStatus, -- 545
		historyStatus = logStatus, -- 546
		tagStatus = tagStatus -- 547
	} -- 534
end -- 493
HttpServer:post("/git/run", function(req) -- 549
	do -- 550
		local _type_0 = type(req) -- 550
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 550
		if _tab_0 then -- 550
			local body = req.body -- 550
			if body ~= nil then -- 550
				local repoPath, command, authId, optionsJSON = body.repoPath, body.command, body.authId, body.optionsJSON -- 551
				if authId and not optionsJSON then -- 552
					local credential = gitLoadCredential(authId) -- 553
					if credential then -- 553
						optionsJSON = gitAuthOptionsJSON(credential) -- 554
						DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 555
							os.time(), -- 555
							credential.id -- 555
						}) -- 555
					end -- 553
				elseif not optionsJSON then -- 556
					local authOk, authSelection = pcall(gitAuthSelectionForCommand, repoPath, command) -- 557
					if not authOk then -- 558
						authSelection = nil -- 558
					end -- 558
					if authSelection then -- 559
						if #authSelection.items == 1 then -- 560
							local credential = gitLoadCredential(authSelection.items[1].id) -- 561
							optionsJSON = gitAuthOptionsJSON(credential) -- 562
							DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 563
								os.time(), -- 563
								credential.id -- 563
							}) -- 563
						else -- 565
							return { -- 565
								success = false, -- 565
								message = "select a Git credential", -- 565
								needsCredentialSelection = true, -- 565
								host = authSelection.host, -- 565
								credentials = authSelection.items -- 565
							} -- 565
						end -- 560
					end -- 559
				end -- 552
				local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 566
				if not jobId then -- 567
					return { -- 567
						success = false, -- 567
						message = err -- 567
					} -- 567
				end -- 567
				return { -- 568
					success = true, -- 568
					jobId = jobId -- 568
				} -- 568
			end -- 550
		end -- 550
	end -- 550
	return invalidArguments -- 549
end) -- 549
HttpServer:post("/git/status", function(req) -- 570
	do -- 571
		local _type_0 = type(req) -- 571
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 571
		if _tab_0 then -- 571
			local jobId -- 571
			do -- 571
				local _obj_0 = req.body -- 571
				local _type_1 = type(_obj_0) -- 571
				if "table" == _type_1 or "userdata" == _type_1 then -- 571
					jobId = _obj_0.jobId -- 571
				end -- 571
			end -- 571
			if jobId ~= nil then -- 571
				local job = GitJobs[tonumber(jobId) or 0] -- 572
				if not job then -- 573
					return { -- 573
						success = false, -- 573
						message = "git job not found" -- 573
					} -- 573
				end -- 573
				return { -- 574
					success = true, -- 574
					status = job.status, -- 574
					command = job.command -- 574
				} -- 574
			end -- 571
		end -- 571
	end -- 571
	return invalidArguments -- 570
end) -- 570
HttpServer:post("/git/cancel", function(req) -- 576
	do -- 577
		local _type_0 = type(req) -- 577
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 577
		if _tab_0 then -- 577
			local jobId -- 577
			do -- 577
				local _obj_0 = req.body -- 577
				local _type_1 = type(_obj_0) -- 577
				if "table" == _type_1 or "userdata" == _type_1 then -- 577
					jobId = _obj_0.jobId -- 577
				end -- 577
			end -- 577
			if jobId ~= nil then -- 577
				local id = tonumber(jobId) -- 578
				if not id then -- 579
					return { -- 579
						success = false, -- 579
						message = "invalid jobId" -- 579
					} -- 579
				end -- 579
				return { -- 580
					success = Git:cancel(id) -- 580
				} -- 580
			end -- 577
		end -- 577
	end -- 577
	return invalidArguments -- 576
end) -- 576
HttpServer:postSchedule("/git/summary", function(req) -- 582
	do -- 583
		local _type_0 = type(req) -- 583
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 583
		if _tab_0 then -- 583
			local repoPath -- 583
			do -- 583
				local _obj_0 = req.body -- 583
				local _type_1 = type(_obj_0) -- 583
				if "table" == _type_1 or "userdata" == _type_1 then -- 583
					repoPath = _obj_0.repoPath -- 583
				end -- 583
			end -- 583
			if repoPath ~= nil then -- 583
				if gitInvalidRepoPath(repoPath) then -- 584
					return { -- 584
						success = false, -- 584
						message = "invalid repoPath" -- 584
					} -- 584
				end -- 584
				return gitSummary(repoPath) -- 585
			end -- 583
		end -- 583
	end -- 583
	return invalidArguments -- 582
end) -- 582
HttpServer:postSchedule("/git/status-files", function(req) -- 587
	do -- 588
		local _type_0 = type(req) -- 588
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 588
		if _tab_0 then -- 588
			local repoPath -- 588
			do -- 588
				local _obj_0 = req.body -- 588
				local _type_1 = type(_obj_0) -- 588
				if "table" == _type_1 or "userdata" == _type_1 then -- 588
					repoPath = _obj_0.repoPath -- 588
				end -- 588
			end -- 588
			if repoPath ~= nil then -- 588
				return gitRunSync(repoPath, "status", nil, 120) -- 589
			end -- 588
		end -- 588
	end -- 588
	return invalidArguments -- 587
end) -- 587
HttpServer:postSchedule("/git/discard-untracked", function(req) -- 591
	do -- 592
		local _type_0 = type(req) -- 592
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 592
		if _tab_0 then -- 592
			local body = req.body -- 592
			if body ~= nil then -- 592
				local repoPath, paths = body.repoPath, body.paths -- 593
				if gitInvalidRepoPath(repoPath) then -- 594
					return { -- 594
						success = false, -- 594
						message = "invalid repoPath" -- 594
					} -- 594
				end -- 594
				if not (type(paths) == "table") then -- 595
					return { -- 595
						success = false, -- 595
						message = "invalid paths" -- 595
					} -- 595
				end -- 595
				local statusRes = gitRunSync(repoPath, "status", nil, 10) -- 596
				if not statusRes.success then -- 597
					return statusRes -- 597
				end -- 597
				local untracked = { } -- 598
				local _list_0 = (statusRes.status.data and statusRes.status.data.files or { }) -- 599
				for _index_0 = 1, #_list_0 do -- 599
					local file = _list_0[_index_0] -- 599
					if file.staging == "?" or file.worktree == "?" then -- 600
						untracked[file.path] = true -- 601
					end -- 600
				end -- 599
				local removed = { } -- 602
				for _index_0 = 1, #paths do -- 603
					local relPath = paths[_index_0] -- 603
					relPath = tostring(relPath) -- 604
					if not gitPathInsideRepo(repoPath, relPath) then -- 605
						return { -- 605
							success = false, -- 605
							message = "unsafe path: " .. tostring(relPath) -- 605
						} -- 605
					end -- 605
					if not untracked[relPath] then -- 606
						return { -- 606
							success = false, -- 606
							message = "path is not untracked: " .. tostring(relPath) -- 606
						} -- 606
					end -- 606
				end -- 603
				for _index_0 = 1, #paths do -- 607
					local relPath = paths[_index_0] -- 607
					local targetPath = Path(repoPath, tostring(relPath)) -- 608
					if Content:exist(targetPath) then -- 609
						Content:remove(targetPath) -- 610
						removed[#removed + 1] = tostring(relPath) -- 611
					end -- 609
				end -- 607
				return { -- 612
					success = true, -- 612
					removed = removed -- 612
				} -- 612
			end -- 592
		end -- 592
	end -- 592
	return invalidArguments -- 591
end) -- 591
HttpServer:postSchedule("/git/file-diff", function(req) -- 614
	do -- 615
		local _type_0 = type(req) -- 615
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 615
		if _tab_0 then -- 615
			local body = req.body -- 615
			if body ~= nil then -- 615
				local repoPath, path, staged = body.repoPath, body.path, body.staged -- 616
				if gitInvalidRepoPath(repoPath) then -- 617
					return { -- 617
						success = false, -- 617
						message = "invalid repoPath" -- 617
					} -- 617
				end -- 617
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 618
					return { -- 618
						success = false, -- 618
						message = "unsafe path" -- 618
					} -- 618
				end -- 618
				local command -- 619
				if staged == true then -- 619
					command = "diff --staged -- " .. tostring(gitQuote(path)) -- 620
				else -- 622
					command = "diff -- " .. tostring(gitQuote(path)) -- 622
				end -- 619
				local res = gitRunSync(repoPath, command, nil, 10) -- 623
				if not res.success then -- 624
					return res -- 624
				end -- 624
				return { -- 625
					success = true, -- 625
					status = res.status, -- 625
					data = res.status and res.status.data -- 625
				} -- 625
			end -- 615
		end -- 615
	end -- 615
	return invalidArguments -- 614
end) -- 614
HttpServer:postSchedule("/git/commit-file-diff", function(req) -- 627
	do -- 628
		local _type_0 = type(req) -- 628
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 628
		if _tab_0 then -- 628
			local body = req.body -- 628
			if body ~= nil then -- 628
				local repoPath, commit, path = body.repoPath, body.commit, body.path -- 629
				if gitInvalidRepoPath(repoPath) then -- 630
					return { -- 630
						success = false, -- 630
						message = "invalid repoPath" -- 630
					} -- 630
				end -- 630
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 631
					return { -- 631
						success = false, -- 631
						message = "invalid commit" -- 631
					} -- 631
				end -- 631
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 632
					return { -- 632
						success = false, -- 632
						message = "unsafe path" -- 632
					} -- 632
				end -- 632
				local res = gitRunSync(repoPath, "diff " .. tostring(gitQuote(commit)) .. " -- " .. tostring(gitQuote(path)), nil, 10) -- 633
				if not res.success then -- 634
					return res -- 634
				end -- 634
				return { -- 635
					success = true, -- 635
					status = res.status, -- 635
					data = res.status and res.status.data -- 635
				} -- 635
			end -- 628
		end -- 628
	end -- 628
	return invalidArguments -- 627
end) -- 627
HttpServer:postSchedule("/git/history", function(req) -- 637
	do -- 638
		local _type_0 = type(req) -- 638
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 638
		if _tab_0 then -- 638
			local body = req.body -- 638
			if body ~= nil then -- 638
				local repoPath, limit = body.repoPath, body.limit -- 639
				limit = math.max(1, math.min(100, tonumber(limit) or 20)) -- 640
				return gitRunSync(repoPath, "log --metadata-only -n " .. tostring(limit), nil, 10) -- 641
			end -- 638
		end -- 638
	end -- 638
	return invalidArguments -- 637
end) -- 637
HttpServer:postSchedule("/git/remotes", function(req) -- 643
	do -- 644
		local _type_0 = type(req) -- 644
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 644
		if _tab_0 then -- 644
			local body = req.body -- 644
			if body ~= nil then -- 644
				local repoPath, command = body.repoPath, body.command -- 645
				command = command or "remote -v" -- 646
				return gitRunSync(repoPath, command, nil, 10) -- 647
			end -- 644
		end -- 644
	end -- 644
	return invalidArguments -- 643
end) -- 643
HttpServer:postSchedule("/git/branches", function(req) -- 649
	do -- 650
		local _type_0 = type(req) -- 650
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 650
		if _tab_0 then -- 650
			local body = req.body -- 650
			if body ~= nil then -- 650
				local repoPath, command = body.repoPath, body.command -- 651
				command = command or "branch" -- 652
				return gitRunSync(repoPath, command, nil, 10) -- 653
			end -- 650
		end -- 650
	end -- 650
	return invalidArguments -- 649
end) -- 649
HttpServer:postSchedule("/git/tags", function(req) -- 655
	do -- 656
		local _type_0 = type(req) -- 656
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 656
		if _tab_0 then -- 656
			local body = req.body -- 656
			if body ~= nil then -- 656
				local repoPath, command = body.repoPath, body.command -- 657
				command = command or "tag" -- 658
				return gitRunSync(repoPath, command, nil, 10) -- 659
			end -- 656
		end -- 656
	end -- 656
	return invalidArguments -- 655
end) -- 655
HttpServer:post("/git/profile/get", function() -- 661
	ensureGitTables() -- 662
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 663
	local profile -- 664
	if rows and rows[1] then -- 664
		profile = { -- 665
			name = rows[1][1], -- 665
			email = rows[1][2] -- 665
		} -- 665
	else -- 667
		profile = { -- 667
			name = "", -- 667
			email = "" -- 667
		} -- 667
	end -- 664
	return { -- 668
		success = true, -- 668
		profile = profile -- 668
	} -- 668
end) -- 661
HttpServer:post("/git/profile/save", function(req) -- 670
	do -- 671
		local _type_0 = type(req) -- 671
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 671
		if _tab_0 then -- 671
			local name -- 671
			do -- 671
				local _obj_0 = req.body -- 671
				local _type_1 = type(_obj_0) -- 671
				if "table" == _type_1 or "userdata" == _type_1 then -- 671
					name = _obj_0.name -- 671
				end -- 671
			end -- 671
			local email -- 671
			do -- 671
				local _obj_0 = req.body -- 671
				local _type_1 = type(_obj_0) -- 671
				if "table" == _type_1 or "userdata" == _type_1 then -- 671
					email = _obj_0.email -- 671
				end -- 671
			end -- 671
			if name ~= nil and email ~= nil then -- 671
				ensureGitTables() -- 672
				DB:exec("insert into GitProfile(id, name, email, updated_at) values(1, ?, ?, ?) on conflict(id) do update set name = excluded.name, email = excluded.email, updated_at = excluded.updated_at", { -- 674
					tostring(name or ""), -- 674
					tostring(email or ""), -- 675
					os.time() -- 676
				}) -- 673
				return { -- 678
					success = true -- 678
				} -- 678
			end -- 671
		end -- 671
	end -- 671
	return invalidArguments -- 670
end) -- 670
HttpServer:post("/git/auth/list", function(req) -- 680
	ensureGitTables() -- 681
	local host = nil -- 682
	do -- 683
		local _type_0 = type(req) -- 683
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 683
		if _tab_0 then -- 683
			local body = req.body -- 683
			if body ~= nil then -- 683
				host = body.host -- 684
			end -- 683
		end -- 683
	end -- 683
	local rows -- 685
	if host and host ~= "" then -- 685
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by host asc, label asc, id asc", { -- 686
			tostring(host):lower() -- 686
		}) -- 686
	else -- 688
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential order by host asc, label asc, id asc") -- 688
	end -- 685
	local items -- 689
	if rows then -- 689
		local _accum_0 = { } -- 689
		local _len_0 = 1 -- 689
		for _index_0 = 1, #rows do -- 689
			local row = rows[_index_0] -- 689
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 689
			_len_0 = _len_0 + 1 -- 689
		end -- 689
		items = _accum_0 -- 689
	else -- 689
		items = { } -- 689
	end -- 689
	return { -- 690
		success = true, -- 690
		items = items -- 690
	} -- 690
end) -- 680
HttpServer:postSchedule("/git/auth/match", function(req) -- 692
	do -- 693
		local _type_0 = type(req) -- 693
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 693
		if _tab_0 then -- 693
			local body = req.body -- 693
			if body ~= nil then -- 693
				if not (type(body) == "table") then -- 694
					return invalidArguments -- 694
				end -- 694
				local repoPath, command, url = body.repoPath, body.command, body.url -- 695
				if url ~= nil and type(url) ~= "string" then -- 696
					return invalidArguments -- 696
				end -- 696
				if not (type(url) == "string" and url ~= "") then -- 697
					if not (type(repoPath) == "string" and type(command) == "string") then -- 698
						return invalidArguments -- 698
					end -- 698
				end -- 697
				local host -- 699
				if url and url ~= "" then -- 699
					host = gitHostFromURL(url) -- 699
				else -- 699
					host = gitCommandHost(repoPath, command) -- 699
				end -- 699
				if not host then -- 700
					return { -- 700
						success = false, -- 700
						message = "git host is required" -- 700
					} -- 700
				end -- 700
				local items = gitCredentialsForHost(host) -- 701
				return { -- 702
					success = true, -- 702
					host = host, -- 702
					items = items, -- 702
					needsSelection = #items > 1, -- 702
					authId = (#items == 1 and items[1].id or nil) -- 702
				} -- 702
			end -- 693
		end -- 693
	end -- 693
	return invalidArguments -- 692
end) -- 692
HttpServer:post("/git/auth/save", function(req) -- 704
	do -- 705
		local _type_0 = type(req) -- 705
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 705
		if _tab_0 then -- 705
			local body = req.body -- 705
			if body ~= nil then -- 705
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token -- 706
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$") -- 707
				label = tostring(label or ""):match("^%s*(.-)%s*$") -- 708
				local credentialType = tostring(body.type or "token") -- 709
				username = tostring(username or "") -- 710
				local secret -- 711
				if credentialType == "basic" then -- 711
					secret = tostring(password or "") -- 711
				else -- 711
					secret = tostring(token or password or "") -- 711
				end -- 711
				if host == "" then -- 712
					return { -- 712
						success = false, -- 712
						message = "host is required" -- 712
					} -- 712
				end -- 712
				if label == "" then -- 713
					return { -- 713
						success = false, -- 713
						message = "label is required" -- 713
					} -- 713
				end -- 713
				if secret == "" then -- 714
					return { -- 714
						success = false, -- 714
						message = "secret is required" -- 714
					} -- 714
				end -- 714
				if not (("basic" == credentialType or "token" == credentialType)) then -- 715
					return { -- 715
						success = false, -- 715
						message = "invalid type" -- 715
					} -- 715
				end -- 715
				ensureGitTables() -- 716
				local now = os.time() -- 717
				if id then -- 718
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", { -- 720
						host, -- 720
						label, -- 720
						credentialType, -- 720
						username, -- 720
						secret, -- 720
						now, -- 720
						(tonumber(id) or 0) -- 720
					}) -- 719
					return { -- 722
						success = true, -- 722
						id = tonumber(id) -- 722
					} -- 722
				else -- 724
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", { -- 725
						host, -- 725
						label, -- 725
						credentialType, -- 725
						username, -- 725
						secret, -- 725
						now, -- 725
						now -- 725
					}) -- 724
					local rows = DB:query("select last_insert_rowid()") -- 727
					return { -- 728
						success = true, -- 728
						id = rows and rows[1] and rows[1][1] -- 728
					} -- 728
				end -- 718
			end -- 705
		end -- 705
	end -- 705
	return invalidArguments -- 704
end) -- 704
HttpServer:post("/git/auth/delete", function(req) -- 730
	do -- 731
		local _type_0 = type(req) -- 731
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 731
		if _tab_0 then -- 731
			local id -- 731
			do -- 731
				local _obj_0 = req.body -- 731
				local _type_1 = type(_obj_0) -- 731
				if "table" == _type_1 or "userdata" == _type_1 then -- 731
					id = _obj_0.id -- 731
				end -- 731
			end -- 731
			if id ~= nil then -- 731
				ensureGitTables() -- 732
				local credentialId = tonumber(id) or 0 -- 733
				DB:exec("delete from GitCredential where id = ?", { -- 734
					credentialId -- 734
				}) -- 734
				return { -- 735
					success = true -- 735
				} -- 735
			end -- 731
		end -- 731
	end -- 731
	return invalidArguments -- 730
end) -- 730
HttpServer:postSchedule("/git/auth/test", function(req) -- 737
	do -- 738
		local _type_0 = type(req) -- 738
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 738
		if _tab_0 then -- 738
			local body = req.body -- 738
			if body ~= nil then -- 738
				local repoPath, url, authId = body.repoPath, body.url, body.authId -- 739
				local credential = gitLoadCredential(authId) -- 740
				local optionsJSON = gitAuthOptionsJSON(credential) -- 741
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20) -- 742
			end -- 738
		end -- 738
	end -- 738
	return invalidArguments -- 737
end) -- 737
HttpServer:post("/agent/session/create", function(req) -- 744
	do -- 745
		local _type_0 = type(req) -- 745
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 745
		if _tab_0 then -- 745
			local projectRoot -- 745
			do -- 745
				local _obj_0 = req.body -- 745
				local _type_1 = type(_obj_0) -- 745
				if "table" == _type_1 or "userdata" == _type_1 then -- 745
					projectRoot = _obj_0.projectRoot -- 745
				end -- 745
			end -- 745
			local title -- 745
			do -- 745
				local _obj_0 = req.body -- 745
				local _type_1 = type(_obj_0) -- 745
				if "table" == _type_1 or "userdata" == _type_1 then -- 745
					title = _obj_0.title -- 745
				end -- 745
			end -- 745
			if projectRoot ~= nil and title ~= nil then -- 745
				return AgentSession.createSession(projectRoot, title) -- 746
			end -- 745
		end -- 745
	end -- 745
	return invalidArguments -- 744
end) -- 744
HttpServer:post("/agent/session/create-sub", function(req) -- 748
	do -- 749
		local _type_0 = type(req) -- 749
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 749
		if _tab_0 then -- 749
			local parentSessionId -- 749
			do -- 749
				local _obj_0 = req.body -- 749
				local _type_1 = type(_obj_0) -- 749
				if "table" == _type_1 or "userdata" == _type_1 then -- 749
					parentSessionId = _obj_0.parentSessionId -- 749
				end -- 749
			end -- 749
			local title -- 749
			do -- 749
				local _obj_0 = req.body -- 749
				local _type_1 = type(_obj_0) -- 749
				if "table" == _type_1 or "userdata" == _type_1 then -- 749
					title = _obj_0.title -- 749
				end -- 749
			end -- 749
			if parentSessionId ~= nil and title ~= nil then -- 749
				return AgentSession.createSubSession(parentSessionId, title) -- 750
			end -- 749
		end -- 749
	end -- 749
	return invalidArguments -- 748
end) -- 748
HttpServer:post("/agent/session/get", function(req) -- 752
	do -- 753
		local _type_0 = type(req) -- 753
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 753
		if _tab_0 then -- 753
			local sessionId -- 753
			do -- 753
				local _obj_0 = req.body -- 753
				local _type_1 = type(_obj_0) -- 753
				if "table" == _type_1 or "userdata" == _type_1 then -- 753
					sessionId = _obj_0.sessionId -- 753
				end -- 753
			end -- 753
			if sessionId ~= nil then -- 753
				return AgentSession.getSession(sessionId) -- 754
			end -- 753
		end -- 753
	end -- 753
	return invalidArguments -- 752
end) -- 752
HttpServer:post("/agent/vision/asset", function(req) -- 756
	do -- 757
		local _type_0 = type(req) -- 757
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 757
		if _tab_0 then -- 757
			local sessionId -- 757
			do -- 757
				local _obj_0 = req.body -- 757
				local _type_1 = type(_obj_0) -- 757
				if "table" == _type_1 or "userdata" == _type_1 then -- 757
					sessionId = _obj_0.sessionId -- 757
				end -- 757
			end -- 757
			local path -- 757
			do -- 757
				local _obj_0 = req.body -- 757
				local _type_1 = type(_obj_0) -- 757
				if "table" == _type_1 or "userdata" == _type_1 then -- 757
					path = _obj_0.path -- 757
				end -- 757
			end -- 757
			if sessionId ~= nil and path ~= nil then -- 757
				return AgentVisionAssets.getSessionVisionImageFromPath(sessionId, path) -- 758
			end -- 757
		end -- 757
	end -- 757
	return invalidArguments -- 756
end) -- 756
HttpServer:post("/agent/session/mode", function(req) -- 760
	do -- 761
		local _type_0 = type(req) -- 761
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 761
		if _tab_0 then -- 761
			local sessionId -- 761
			do -- 761
				local _obj_0 = req.body -- 761
				local _type_1 = type(_obj_0) -- 761
				if "table" == _type_1 or "userdata" == _type_1 then -- 761
					sessionId = _obj_0.sessionId -- 761
				end -- 761
			end -- 761
			local workMode -- 761
			do -- 761
				local _obj_0 = req.body -- 761
				local _type_1 = type(_obj_0) -- 761
				if "table" == _type_1 or "userdata" == _type_1 then -- 761
					workMode = _obj_0.workMode -- 761
				end -- 761
			end -- 761
			if sessionId ~= nil and workMode ~= nil then -- 761
				return AgentSession.setWorkMode(sessionId, workMode) -- 762
			end -- 761
		end -- 761
	end -- 761
	return invalidArguments -- 760
end) -- 760
HttpServer:post("/agent/session/send", function(req) -- 764
	do -- 765
		local _type_0 = type(req) -- 765
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 765
		if _tab_0 then -- 765
			local sessionId -- 765
			do -- 765
				local _obj_0 = req.body -- 765
				local _type_1 = type(_obj_0) -- 765
				if "table" == _type_1 or "userdata" == _type_1 then -- 765
					sessionId = _obj_0.sessionId -- 765
				end -- 765
			end -- 765
			local prompt -- 765
			do -- 765
				local _obj_0 = req.body -- 765
				local _type_1 = type(_obj_0) -- 765
				if "table" == _type_1 or "userdata" == _type_1 then -- 765
					prompt = _obj_0.prompt -- 765
				end -- 765
			end -- 765
			if sessionId ~= nil and prompt ~= nil then -- 765
				return AgentSession.sendPrompt(sessionId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 766
			end -- 765
		end -- 765
	end -- 765
	return invalidArguments -- 764
end) -- 764
HttpServer:post("/agent/session/send-local", function(req) -- 768
	do -- 769
		local _type_0 = type(req) -- 769
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 769
		if _tab_0 then -- 769
			local sessionId -- 769
			do -- 769
				local _obj_0 = req.body -- 769
				local _type_1 = type(_obj_0) -- 769
				if "table" == _type_1 or "userdata" == _type_1 then -- 769
					sessionId = _obj_0.sessionId -- 769
				end -- 769
			end -- 769
			local prompt -- 769
			do -- 769
				local _obj_0 = req.body -- 769
				local _type_1 = type(_obj_0) -- 769
				if "table" == _type_1 or "userdata" == _type_1 then -- 769
					prompt = _obj_0.prompt -- 769
				end -- 769
			end -- 769
			local localAgentConfigId -- 769
			do -- 769
				local _obj_0 = req.body -- 769
				local _type_1 = type(_obj_0) -- 769
				if "table" == _type_1 or "userdata" == _type_1 then -- 769
					localAgentConfigId = _obj_0.localAgentConfigId -- 769
				end -- 769
			end -- 769
			if sessionId ~= nil and prompt ~= nil and localAgentConfigId ~= nil then -- 769
				return AgentSession.sendLocalPrompt(sessionId, prompt, localAgentConfigId) -- 770
			end -- 769
		end -- 769
	end -- 769
	return invalidArguments -- 768
end) -- 768
HttpServer:post("/agent/session/local/new", function(req) -- 772
	do -- 773
		local _type_0 = type(req) -- 773
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 773
		if _tab_0 then -- 773
			local sessionId -- 773
			do -- 773
				local _obj_0 = req.body -- 773
				local _type_1 = type(_obj_0) -- 773
				if "table" == _type_1 or "userdata" == _type_1 then -- 773
					sessionId = _obj_0.sessionId -- 773
				end -- 773
			end -- 773
			if sessionId ~= nil then -- 773
				return AgentLocalAgent.abandonSession(sessionId) -- 774
			end -- 773
		end -- 773
	end -- 773
	return invalidArguments -- 772
end) -- 772
HttpServer:post("/agent/session/local/info", function(req) -- 776
	do -- 777
		local _type_0 = type(req) -- 777
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 777
		if _tab_0 then -- 777
			local sessionId -- 777
			do -- 777
				local _obj_0 = req.body -- 777
				local _type_1 = type(_obj_0) -- 777
				if "table" == _type_1 or "userdata" == _type_1 then -- 777
					sessionId = _obj_0.sessionId -- 777
				end -- 777
			end -- 777
			if sessionId ~= nil then -- 777
				local info = AgentLocalAgent.getSessionInfo(sessionId) -- 778
				return { -- 779
					success = true, -- 779
					info = info -- 779
				} -- 779
			end -- 777
		end -- 777
	end -- 777
	return invalidArguments -- 776
end) -- 776
HttpServer:post("/agent/session/continue", function(req) -- 781
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
				return AgentSession.continuePrompt(sessionId, req.body.disabledAgentTools, req.body.llmConfigId) -- 783
			end -- 782
		end -- 782
	end -- 782
	return invalidArguments -- 781
end) -- 781
HttpServer:post("/agent/session/finish-handoff", function(req) -- 785
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
				return AgentSession.finishSubSessionHandoff(sessionId, req.body.llmConfigId) -- 787
			end -- 786
		end -- 786
	end -- 786
	return invalidArguments -- 785
end) -- 785
HttpServer:post("/agent/session/resend", function(req) -- 789
	do -- 790
		local _type_0 = type(req) -- 790
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 790
		if _tab_0 then -- 790
			local sessionId -- 790
			do -- 790
				local _obj_0 = req.body -- 790
				local _type_1 = type(_obj_0) -- 790
				if "table" == _type_1 or "userdata" == _type_1 then -- 790
					sessionId = _obj_0.sessionId -- 790
				end -- 790
			end -- 790
			local messageId -- 790
			do -- 790
				local _obj_0 = req.body -- 790
				local _type_1 = type(_obj_0) -- 790
				if "table" == _type_1 or "userdata" == _type_1 then -- 790
					messageId = _obj_0.messageId -- 790
				end -- 790
			end -- 790
			local prompt -- 790
			do -- 790
				local _obj_0 = req.body -- 790
				local _type_1 = type(_obj_0) -- 790
				if "table" == _type_1 or "userdata" == _type_1 then -- 790
					prompt = _obj_0.prompt -- 790
				end -- 790
			end -- 790
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 790
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 791
			end -- 790
		end -- 790
	end -- 790
	return invalidArguments -- 789
end) -- 789
HttpServer:post("/agent/session/questionnaire/respond", function(req) -- 793
	do -- 794
		local _type_0 = type(req) -- 794
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 794
		if _tab_0 then -- 794
			local sessionId -- 794
			do -- 794
				local _obj_0 = req.body -- 794
				local _type_1 = type(_obj_0) -- 794
				if "table" == _type_1 or "userdata" == _type_1 then -- 794
					sessionId = _obj_0.sessionId -- 794
				end -- 794
			end -- 794
			local questionnaireId -- 794
			do -- 794
				local _obj_0 = req.body -- 794
				local _type_1 = type(_obj_0) -- 794
				if "table" == _type_1 or "userdata" == _type_1 then -- 794
					questionnaireId = _obj_0.questionnaireId -- 794
				end -- 794
			end -- 794
			local answers -- 794
			do -- 794
				local _obj_0 = req.body -- 794
				local _type_1 = type(_obj_0) -- 794
				if "table" == _type_1 or "userdata" == _type_1 then -- 794
					answers = _obj_0.answers -- 794
				end -- 794
			end -- 794
			if sessionId ~= nil and questionnaireId ~= nil and answers ~= nil then -- 794
				return AgentSession.respondQuestionnaire(sessionId, questionnaireId, answers, req.body.llmConfigId) -- 795
			end -- 794
		end -- 794
	end -- 794
	return invalidArguments -- 793
end) -- 793
HttpServer:post("/agent/session/questionnaire/cancel", function(req) -- 797
	do -- 798
		local _type_0 = type(req) -- 798
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 798
		if _tab_0 then -- 798
			local sessionId -- 798
			do -- 798
				local _obj_0 = req.body -- 798
				local _type_1 = type(_obj_0) -- 798
				if "table" == _type_1 or "userdata" == _type_1 then -- 798
					sessionId = _obj_0.sessionId -- 798
				end -- 798
			end -- 798
			local questionnaireId -- 798
			do -- 798
				local _obj_0 = req.body -- 798
				local _type_1 = type(_obj_0) -- 798
				if "table" == _type_1 or "userdata" == _type_1 then -- 798
					questionnaireId = _obj_0.questionnaireId -- 798
				end -- 798
			end -- 798
			if sessionId ~= nil and questionnaireId ~= nil then -- 798
				return AgentSession.cancelQuestionnaire(sessionId, questionnaireId, req.body.llmConfigId) -- 799
			end -- 798
		end -- 798
	end -- 798
	return invalidArguments -- 797
end) -- 797
HttpServer:post("/agent/task/status", function(req) -- 801
	do -- 802
		local _type_0 = type(req) -- 802
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 802
		if _tab_0 then -- 802
			local sessionId -- 802
			do -- 802
				local _obj_0 = req.body -- 802
				local _type_1 = type(_obj_0) -- 802
				if "table" == _type_1 or "userdata" == _type_1 then -- 802
					sessionId = _obj_0.sessionId -- 802
				end -- 802
			end -- 802
			if sessionId ~= nil then -- 802
				local res = AgentSession.getSession(sessionId) -- 803
				if not res.success then -- 804
					return res -- 804
				end -- 804
				local taskId = res.session.currentTaskId -- 805
				local checkpoints -- 806
				if taskId then -- 806
					checkpoints = AgentTools.listCheckpoints(taskId) -- 806
				else -- 806
					checkpoints = { } -- 806
				end -- 806
				return { -- 808
					success = true, -- 808
					session = res.session, -- 809
					relatedSessions = res.relatedSessions, -- 810
					spawnInfo = res.spawnInfo, -- 811
					messages = res.messages, -- 812
					steps = res.steps, -- 813
					checkpoints = checkpoints, -- 814
					pendingQuestionnaire = res.pendingQuestionnaire, -- 815
					hasActivePlan = res.hasActivePlan -- 816
				} -- 807
			end -- 802
		end -- 802
	end -- 802
	return invalidArguments -- 801
end) -- 801
HttpServer:post("/agent/task/running", function() -- 818
	local res = AgentSession.listRunningSessions() -- 819
	if res.success and #res.sessions == 0 then -- 820
		res.sessions = nil -- 821
	end -- 820
	return res -- 822
end) -- 818
HttpServer:post("/agent/task/stop", function(req) -- 824
	do -- 825
		local _type_0 = type(req) -- 825
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 825
		if _tab_0 then -- 825
			local sessionId -- 825
			do -- 825
				local _obj_0 = req.body -- 825
				local _type_1 = type(_obj_0) -- 825
				if "table" == _type_1 or "userdata" == _type_1 then -- 825
					sessionId = _obj_0.sessionId -- 825
				end -- 825
			end -- 825
			if sessionId ~= nil then -- 825
				return AgentSession.stopSessionTask(sessionId) -- 826
			end -- 825
		end -- 825
	end -- 825
	return invalidArguments -- 824
end) -- 824
HttpServer:post("/agent/checkpoint/list", function(req) -- 828
	do -- 829
		local _type_0 = type(req) -- 829
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 829
		if _tab_0 then -- 829
			local taskId -- 829
			do -- 829
				local _obj_0 = req.body -- 829
				local _type_1 = type(_obj_0) -- 829
				if "table" == _type_1 or "userdata" == _type_1 then -- 829
					taskId = _obj_0.taskId -- 829
				end -- 829
			end -- 829
			local sessionId -- 829
			do -- 829
				local _obj_0 = req.body -- 829
				local _type_1 = type(_obj_0) -- 829
				if "table" == _type_1 or "userdata" == _type_1 then -- 829
					sessionId = _obj_0.sessionId -- 829
				end -- 829
			end -- 829
			if sessionId ~= nil then -- 829
				if not taskId and sessionId then -- 830
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 831
				end -- 830
				if not taskId then -- 832
					return { -- 832
						success = false, -- 832
						message = "task not found" -- 832
					} -- 832
				end -- 832
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 833
				if not access.success then -- 834
					return access -- 834
				end -- 834
				return { -- 836
					success = true, -- 836
					taskId = taskId, -- 837
					checkpoints = AgentTools.listCheckpoints(taskId) -- 838
				} -- 835
			end -- 829
		end -- 829
	end -- 829
	return invalidArguments -- 828
end) -- 828
HttpServer:post("/agent/checkpoint/diff", function(req) -- 840
	do -- 841
		local _type_0 = type(req) -- 841
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 841
		if _tab_0 then -- 841
			local sessionId -- 841
			do -- 841
				local _obj_0 = req.body -- 841
				local _type_1 = type(_obj_0) -- 841
				if "table" == _type_1 or "userdata" == _type_1 then -- 841
					sessionId = _obj_0.sessionId -- 841
				end -- 841
			end -- 841
			local checkpointId -- 841
			do -- 841
				local _obj_0 = req.body -- 841
				local _type_1 = type(_obj_0) -- 841
				if "table" == _type_1 or "userdata" == _type_1 then -- 841
					checkpointId = _obj_0.checkpointId -- 841
				end -- 841
			end -- 841
			if sessionId ~= nil and checkpointId ~= nil then -- 841
				if not (checkpointId > 0) then -- 842
					return { -- 842
						success = false, -- 842
						message = "invalid checkpointId" -- 842
					} -- 842
				end -- 842
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 843
				if not access.success then -- 844
					return access -- 844
				end -- 844
				return AgentTools.getCheckpointDiff(checkpointId) -- 845
			end -- 841
		end -- 841
	end -- 841
	return invalidArguments -- 840
end) -- 840
HttpServer:post("/agent/task/diff", function(req) -- 847
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
			local taskId -- 848
			do -- 848
				local _obj_0 = req.body -- 848
				local _type_1 = type(_obj_0) -- 848
				if "table" == _type_1 or "userdata" == _type_1 then -- 848
					taskId = _obj_0.taskId -- 848
				end -- 848
			end -- 848
			if sessionId ~= nil and taskId ~= nil then -- 848
				if not (taskId > 0) then -- 849
					return { -- 849
						success = false, -- 849
						message = "invalid taskId" -- 849
					} -- 849
				end -- 849
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 850
				if not access.success then -- 851
					return access -- 851
				end -- 851
				return AgentTools.getTaskChangeSetDiff(taskId) -- 852
			end -- 848
		end -- 848
	end -- 848
	return invalidArguments -- 847
end) -- 847
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 854
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
			local checkpointId -- 855
			do -- 855
				local _obj_0 = req.body -- 855
				local _type_1 = type(_obj_0) -- 855
				if "table" == _type_1 or "userdata" == _type_1 then -- 855
					checkpointId = _obj_0.checkpointId -- 855
				end -- 855
			end -- 855
			if sessionId ~= nil and checkpointId ~= nil then -- 855
				if not (checkpointId > 0) then -- 856
					return { -- 856
						success = false, -- 856
						message = "invalid checkpointId" -- 856
					} -- 856
				end -- 856
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 857
				if not access.success then -- 858
					return access -- 858
				end -- 858
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, access.session.projectRoot) -- 859
				if not rollbackRes.success then -- 860
					return rollbackRes -- 860
				end -- 860
				return { -- 862
					success = true, -- 862
					checkpointId = rollbackRes.checkpointId -- 863
				} -- 861
			end -- 855
		end -- 855
	end -- 855
	return invalidArguments -- 854
end) -- 854
HttpServer:post("/agent/task/rollback", function(req) -- 865
	do -- 866
		local _type_0 = type(req) -- 866
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 866
		if _tab_0 then -- 866
			local sessionId -- 866
			do -- 866
				local _obj_0 = req.body -- 866
				local _type_1 = type(_obj_0) -- 866
				if "table" == _type_1 or "userdata" == _type_1 then -- 866
					sessionId = _obj_0.sessionId -- 866
				end -- 866
			end -- 866
			local taskId -- 866
			do -- 866
				local _obj_0 = req.body -- 866
				local _type_1 = type(_obj_0) -- 866
				if "table" == _type_1 or "userdata" == _type_1 then -- 866
					taskId = _obj_0.taskId -- 866
				end -- 866
			end -- 866
			if sessionId ~= nil and taskId ~= nil then -- 866
				if not (taskId > 0) then -- 867
					return { -- 867
						success = false, -- 867
						message = "invalid taskId" -- 867
					} -- 867
				end -- 867
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 868
				if not access.success then -- 869
					return access -- 869
				end -- 869
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, access.session.projectRoot) -- 870
				if not rollbackRes.success then -- 871
					return rollbackRes -- 871
				end -- 871
				return { -- 873
					success = true, -- 873
					taskId = rollbackRes.taskId, -- 874
					checkpointId = rollbackRes.checkpointId, -- 875
					checkpointCount = rollbackRes.checkpointCount -- 876
				} -- 872
			end -- 866
		end -- 866
	end -- 866
	return invalidArguments -- 865
end) -- 865
local getSearchPath -- 878
getSearchPath = function(file) -- 878
	do -- 879
		local dir = getProjectDirFromFile(file) -- 879
		if dir then -- 879
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 880
		end -- 879
	end -- 879
	return "" -- 878
end -- 878
local getSearchFolders -- 882
getSearchFolders = function(file) -- 882
	do -- 883
		local dir = getProjectDirFromFile(file) -- 883
		if dir then -- 883
			return { -- 885
				Path(dir, "Script"), -- 885
				dir -- 886
			} -- 884
		end -- 883
	end -- 883
	return { } -- 882
end -- 882
local disabledCheckForLua = { -- 889
	"incompatible number of returns", -- 889
	"unknown", -- 890
	"cannot index", -- 891
	"module not found", -- 892
	"don't know how to resolve", -- 893
	"ContainerItem", -- 894
	"cannot resolve a type", -- 895
	"invalid key", -- 896
	"inconsistent index type", -- 897
	"cannot use operator", -- 898
	"attempting ipairs loop", -- 899
	"expects record or nominal", -- 900
	"variable is not being assigned", -- 901
	"<invalid type>", -- 902
	"<any type>", -- 903
	"using the '#' operator", -- 904
	"can't match a record", -- 905
	"redeclaration of variable", -- 906
	"cannot apply pairs", -- 907
	"not a function", -- 908
	"to%-be%-closed" -- 909
} -- 888
local yueCheck -- 911
yueCheck = function(file, content, lax) -- 911
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 912
	if isTIC80 then -- 913
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 914
	end -- 913
	local searchPath = getSearchPath(file) -- 915
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 916
	local info = { } -- 917
	local globals = { } -- 918
	for _index_0 = 1, #checkResult do -- 919
		local _des_0 = checkResult[_index_0] -- 919
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 919
		if "error" == t then -- 920
			info[#info + 1] = { -- 921
				"syntax", -- 921
				file, -- 921
				line, -- 921
				col, -- 921
				msg -- 921
			} -- 921
		elseif "global" == t then -- 922
			globals[#globals + 1] = { -- 923
				msg, -- 923
				line, -- 923
				col -- 923
			} -- 923
		end -- 920
	end -- 919
	if luaCodes then -- 924
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 925
		if success then -- 926
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 927
			if not (lintResult == "") then -- 928
				lintResult = lintResult .. "\n" -- 928
			end -- 928
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 929
		else -- 930
			for _index_0 = 1, #lintResult do -- 930
				local _des_0 = lintResult[_index_0] -- 930
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 930
				if isTIC80 and tic80APIs[name] then -- 931
					goto _continue_0 -- 931
				end -- 931
				info[#info + 1] = { -- 932
					"syntax", -- 932
					file, -- 932
					line, -- 932
					col, -- 932
					"invalid global variable" -- 932
				} -- 932
				::_continue_0:: -- 931
			end -- 930
		end -- 926
	end -- 924
	return luaCodes, info -- 933
end -- 911
local luaCheck -- 935
luaCheck = function(file, content) -- 935
	local res, err = load(content, "check") -- 936
	if not res then -- 937
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 938
		return { -- 939
			success = false, -- 939
			info = { -- 939
				{ -- 939
					"syntax", -- 939
					file, -- 939
					tonumber(line), -- 939
					0, -- 939
					msg -- 939
				} -- 939
			} -- 939
		} -- 939
	end -- 937
	local success, info = teal.checkAsync(content, file, true, "") -- 940
	if info then -- 941
		do -- 942
			local _accum_0 = { } -- 942
			local _len_0 = 1 -- 942
			for _index_0 = 1, #info do -- 942
				local item = info[_index_0] -- 942
				local useCheck = true -- 943
				if not item[5]:match("unused") then -- 944
					for _index_1 = 1, #disabledCheckForLua do -- 945
						local check = disabledCheckForLua[_index_1] -- 945
						if item[5]:match(check) then -- 946
							useCheck = false -- 947
						end -- 946
					end -- 945
				end -- 944
				if not useCheck then -- 948
					goto _continue_0 -- 948
				end -- 948
				do -- 949
					local _exp_0 = item[1] -- 949
					if "type" == _exp_0 then -- 950
						item[1] = "warning" -- 951
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 952
						goto _continue_0 -- 953
					end -- 949
				end -- 949
				_accum_0[_len_0] = item -- 954
				_len_0 = _len_0 + 1 -- 943
				::_continue_0:: -- 943
			end -- 942
			info = _accum_0 -- 942
		end -- 942
		if #info == 0 then -- 955
			info = nil -- 956
			success = true -- 957
		end -- 955
	end -- 941
	return { -- 958
		success = success, -- 958
		info = info -- 958
	} -- 958
end -- 935
local luaCheckWithLineInfo -- 960
luaCheckWithLineInfo = function(file, luaCodes) -- 960
	local res = luaCheck(file, luaCodes) -- 961
	local info = { } -- 962
	if not res.success then -- 963
		local current = 1 -- 964
		local lastLine = 1 -- 965
		local lineMap = { } -- 966
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 967
			local num = lineCode:match("--%s*(%d+)%s*$") -- 968
			if num then -- 969
				lastLine = tonumber(num) -- 970
			end -- 969
			lineMap[current] = lastLine -- 971
			current = current + 1 -- 972
		end -- 967
		local _list_0 = res.info -- 973
		for _index_0 = 1, #_list_0 do -- 973
			local item = _list_0[_index_0] -- 973
			item[3] = lineMap[item[3]] or 0 -- 974
			item[4] = 0 -- 975
			info[#info + 1] = item -- 976
		end -- 973
		return false, info -- 977
	end -- 963
	return true, info -- 978
end -- 960
local getCompiledYueLine -- 980
getCompiledYueLine = function(content, line, row, file, lax) -- 980
	local luaCodes = yueCheck(file, content, lax) -- 981
	if not luaCodes then -- 982
		return nil -- 982
	end -- 982
	local current = 1 -- 983
	local lastLine = 1 -- 984
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 985
	local targetRow = nil -- 986
	local lineMap = { } -- 987
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 988
		local num = lineCode:match("--%s*(%d+)%s*$") -- 989
		if num then -- 990
			lastLine = tonumber(num) -- 990
		end -- 990
		lineMap[current] = lastLine -- 991
		if row <= lastLine and not targetRow then -- 992
			targetRow = current -- 993
			break -- 994
		end -- 992
		current = current + 1 -- 995
	end -- 988
	targetRow = current -- 996
	if targetLine and targetRow then -- 997
		return luaCodes, targetLine, targetRow, lineMap -- 998
	else -- 1000
		return nil -- 1000
	end -- 997
end -- 980
HttpServer:postSchedule("/check", function(req) -- 1002
	do -- 1003
		local _type_0 = type(req) -- 1003
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1003
		if _tab_0 then -- 1003
			local file -- 1003
			do -- 1003
				local _obj_0 = req.body -- 1003
				local _type_1 = type(_obj_0) -- 1003
				if "table" == _type_1 or "userdata" == _type_1 then -- 1003
					file = _obj_0.file -- 1003
				end -- 1003
			end -- 1003
			local content -- 1003
			do -- 1003
				local _obj_0 = req.body -- 1003
				local _type_1 = type(_obj_0) -- 1003
				if "table" == _type_1 or "userdata" == _type_1 then -- 1003
					content = _obj_0.content -- 1003
				end -- 1003
			end -- 1003
			if file ~= nil and content ~= nil then -- 1003
				local ext = Path:getExt(file) -- 1004
				if "tl" == ext then -- 1005
					local searchPath = getSearchPath(file) -- 1006
					do -- 1007
						local isTIC80 = CheckTIC80Code(content) -- 1007
						if isTIC80 then -- 1007
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1008
						end -- 1007
					end -- 1007
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 1009
					return { -- 1010
						success = success, -- 1010
						info = info -- 1010
					} -- 1010
				elseif "lua" == ext then -- 1011
					do -- 1012
						local isTIC80 = CheckTIC80Code(content) -- 1012
						if isTIC80 then -- 1012
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1013
						end -- 1012
					end -- 1012
					return luaCheck(file, content) -- 1014
				elseif "yue" == ext then -- 1015
					local luaCodes, info = yueCheck(file, content, false) -- 1016
					local success = luaCodes ~= nil -- 1017
					if luaCodes then -- 1018
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 1019
						do -- 1020
							local _tab_1 = { } -- 1020
							local _idx_0 = #_tab_1 + 1 -- 1020
							for _index_0 = 1, #info do -- 1020
								local _value_0 = info[_index_0] -- 1020
								_tab_1[_idx_0] = _value_0 -- 1020
								_idx_0 = _idx_0 + 1 -- 1020
							end -- 1020
							local _idx_1 = #_tab_1 + 1 -- 1020
							for _index_0 = 1, #luaInfo do -- 1020
								local _value_0 = luaInfo[_index_0] -- 1020
								_tab_1[_idx_1] = _value_0 -- 1020
								_idx_1 = _idx_1 + 1 -- 1020
							end -- 1020
							info = _tab_1 -- 1020
						end -- 1020
						success = success and luaSuccess -- 1021
					end -- 1018
					if #info > 0 then -- 1022
						return { -- 1023
							success = success, -- 1023
							info = info -- 1023
						} -- 1023
					else -- 1025
						return { -- 1025
							success = success -- 1025
						} -- 1025
					end -- 1022
				elseif "xml" == ext then -- 1026
					local success, result = xml.check(content) -- 1027
					if success then -- 1028
						local info -- 1029
						success, info = luaCheckWithLineInfo(file, result) -- 1029
						if #info > 0 then -- 1030
							return { -- 1031
								success = success, -- 1031
								info = info -- 1031
							} -- 1031
						else -- 1033
							return { -- 1033
								success = success -- 1033
							} -- 1033
						end -- 1030
					else -- 1035
						local info -- 1035
						do -- 1035
							local _accum_0 = { } -- 1035
							local _len_0 = 1 -- 1035
							for _index_0 = 1, #result do -- 1035
								local _des_0 = result[_index_0] -- 1035
								local row, err = _des_0[1], _des_0[2] -- 1035
								_accum_0[_len_0] = { -- 1036
									"syntax", -- 1036
									file, -- 1036
									row, -- 1036
									0, -- 1036
									err -- 1036
								} -- 1036
								_len_0 = _len_0 + 1 -- 1036
							end -- 1035
							info = _accum_0 -- 1035
						end -- 1035
						return { -- 1037
							success = false, -- 1037
							info = info -- 1037
						} -- 1037
					end -- 1028
				end -- 1005
			end -- 1003
		end -- 1003
	end -- 1003
	return { -- 1002
		success = true -- 1002
	} -- 1002
end) -- 1002
HttpServer:post("/body/parse", function(req) -- 1039
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
				if not (file:sub(-6) == ".b.lua") then -- 1041
					return { -- 1042
						success = false, -- 1042
						phase = "request", -- 1042
						message = "only .b.lua files can be converted" -- 1042
					} -- 1042
				end -- 1041
				local loader, err = load("_ENV = {}\n" .. content) -- 1043
				if not loader then -- 1044
					return { -- 1045
						success = false, -- 1045
						phase = "parse", -- 1045
						message = tostring(err) -- 1045
					} -- 1045
				end -- 1044
				local ok, data = pcall(loader) -- 1046
				if not ok then -- 1047
					return { -- 1048
						success = false, -- 1048
						phase = "execute", -- 1048
						message = tostring(data) -- 1048
					} -- 1048
				end -- 1047
				if not ("table" == type(data) and data[1] == "Array") then -- 1049
					return { -- 1050
						success = false, -- 1050
						phase = "validate", -- 1050
						message = "body lua root must be {\"Array\", ...}" -- 1050
					} -- 1050
				end -- 1049
				local text, jsonErr = json.encode(data, false, true) -- 1051
				if not text then -- 1052
					return { -- 1053
						success = false, -- 1053
						phase = "encode", -- 1053
						message = tostring(jsonErr) -- 1053
					} -- 1053
				end -- 1052
				return { -- 1054
					success = true, -- 1054
					json = text -- 1054
				} -- 1054
			end -- 1040
		end -- 1040
	end -- 1040
	return { -- 1039
		success = false, -- 1039
		phase = "request", -- 1039
		message = "invalid request" -- 1039
	} -- 1039
end) -- 1039
local updateInferedDesc -- 1056
updateInferedDesc = function(infered) -- 1056
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1057
		return -- 1057
	end -- 1057
	local key, row = infered.key, infered.row -- 1058
	local codes = Content:loadAsync(key) -- 1059
	if codes then -- 1059
		local comments = { } -- 1060
		local line = 0 -- 1061
		local skipping = false -- 1062
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1063
			line = line + 1 -- 1064
			if line >= row then -- 1065
				break -- 1065
			end -- 1065
			if lineCode:match("^%s*%-%- @") then -- 1066
				skipping = true -- 1067
				goto _continue_0 -- 1068
			end -- 1066
			local result = lineCode:match("^%s*%-%- (.+)") -- 1069
			if result then -- 1069
				if not skipping then -- 1070
					comments[#comments + 1] = result -- 1070
				end -- 1070
			elseif #comments > 0 then -- 1071
				comments = { } -- 1072
				skipping = false -- 1073
			end -- 1069
			::_continue_0:: -- 1064
		end -- 1063
		infered.doc = table.concat(comments, "\n") -- 1074
	end -- 1059
end -- 1056
HttpServer:postSchedule("/infer", function(req) -- 1076
	do -- 1077
		local _type_0 = type(req) -- 1077
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1077
		if _tab_0 then -- 1077
			local lang -- 1077
			do -- 1077
				local _obj_0 = req.body -- 1077
				local _type_1 = type(_obj_0) -- 1077
				if "table" == _type_1 or "userdata" == _type_1 then -- 1077
					lang = _obj_0.lang -- 1077
				end -- 1077
			end -- 1077
			local file -- 1077
			do -- 1077
				local _obj_0 = req.body -- 1077
				local _type_1 = type(_obj_0) -- 1077
				if "table" == _type_1 or "userdata" == _type_1 then -- 1077
					file = _obj_0.file -- 1077
				end -- 1077
			end -- 1077
			local content -- 1077
			do -- 1077
				local _obj_0 = req.body -- 1077
				local _type_1 = type(_obj_0) -- 1077
				if "table" == _type_1 or "userdata" == _type_1 then -- 1077
					content = _obj_0.content -- 1077
				end -- 1077
			end -- 1077
			local line -- 1077
			do -- 1077
				local _obj_0 = req.body -- 1077
				local _type_1 = type(_obj_0) -- 1077
				if "table" == _type_1 or "userdata" == _type_1 then -- 1077
					line = _obj_0.line -- 1077
				end -- 1077
			end -- 1077
			local row -- 1077
			do -- 1077
				local _obj_0 = req.body -- 1077
				local _type_1 = type(_obj_0) -- 1077
				if "table" == _type_1 or "userdata" == _type_1 then -- 1077
					row = _obj_0.row -- 1077
				end -- 1077
			end -- 1077
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1077
				local searchPath = getSearchPath(file) -- 1078
				if "tl" == lang or "lua" == lang then -- 1079
					if CheckTIC80Code(content) then -- 1080
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1081
					end -- 1080
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1082
					if (infered ~= nil) then -- 1083
						updateInferedDesc(infered) -- 1084
						return { -- 1085
							success = true, -- 1085
							infered = infered -- 1085
						} -- 1085
					end -- 1083
				elseif "yue" == lang then -- 1086
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1087
					if not luaCodes then -- 1088
						return { -- 1088
							success = false -- 1088
						} -- 1088
					end -- 1088
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1089
					if (infered ~= nil) then -- 1090
						local col -- 1091
						file, row, col = infered.file, infered.row, infered.col -- 1091
						if file == "" and row > 0 and col > 0 then -- 1092
							infered.row = lineMap[row] or 0 -- 1093
							infered.col = 0 -- 1094
						end -- 1092
						updateInferedDesc(infered) -- 1095
						return { -- 1096
							success = true, -- 1096
							infered = infered -- 1096
						} -- 1096
					end -- 1090
				end -- 1079
			end -- 1077
		end -- 1077
	end -- 1077
	return { -- 1076
		success = false -- 1076
	} -- 1076
end) -- 1076
local _anon_func_3 = function(doc) -- 1157
	local _accum_0 = { } -- 1157
	local _len_0 = 1 -- 1157
	local _list_0 = doc.params -- 1157
	for _index_0 = 1, #_list_0 do -- 1157
		local param = _list_0[_index_0] -- 1157
		_accum_0[_len_0] = param.name -- 1157
		_len_0 = _len_0 + 1 -- 1157
	end -- 1157
	return _accum_0 -- 1157
end -- 1157
local getParamDocs -- 1098
getParamDocs = function(signatures) -- 1098
	if not (signatures and #signatures > 0) then -- 1099
		return nil -- 1099
	end -- 1099
	local docs = { } -- 1100
	do -- 1101
		local codes = Content:loadAsync(signatures[1].file) -- 1101
		if codes then -- 1101
			local comments = { } -- 1102
			local params = { } -- 1103
			local line = 0 -- 1104
			local returnType = nil -- 1105
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1106
				line = line + 1 -- 1107
				local needBreak = true -- 1108
				for i, _des_0 in ipairs(signatures) do -- 1109
					local row = _des_0.row -- 1109
					if line >= row and not (docs[i] ~= nil) then -- 1110
						if #comments > 0 or #params > 0 or returnType then -- 1111
							docs[i] = { -- 1113
								doc = table.concat(comments, "  \n"), -- 1113
								returnType = returnType -- 1114
							} -- 1112
							if #params > 0 then -- 1116
								docs[i].params = params -- 1116
							end -- 1116
						else -- 1118
							docs[i] = false -- 1118
						end -- 1111
					end -- 1110
					if not docs[i] then -- 1119
						needBreak = false -- 1119
					end -- 1119
				end -- 1109
				if needBreak then -- 1120
					break -- 1120
				end -- 1120
				local result = lineCode:match("%s*%-%- (.+)") -- 1121
				if result then -- 1121
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1122
					if not name then -- 1123
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1124
					end -- 1123
					if name then -- 1125
						local pname = name -- 1126
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1127
							pname = pname .. "?" -- 1127
						end -- 1127
						params[#params + 1] = { -- 1129
							name = tostring(pname) .. ": " .. tostring(typ), -- 1129
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1130
						} -- 1128
					else -- 1133
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1133
						if typ then -- 1133
							if returnType then -- 1134
								returnType = returnType .. ", " .. typ -- 1135
							else -- 1137
								returnType = typ -- 1137
							end -- 1134
							result = result:gsub("@return", "**return:**") -- 1138
						end -- 1133
						comments[#comments + 1] = result -- 1139
					end -- 1125
				elseif #comments > 0 then -- 1140
					comments = { } -- 1141
					params = { } -- 1142
					returnType = nil -- 1143
				end -- 1121
			end -- 1106
		end -- 1101
	end -- 1101
	local results = { } -- 1144
	for i, signature in ipairs(signatures) do -- 1145
		local item = { -- 1147
			desc = signature.desc, -- 1147
			doc = "", -- 1148
			file = signature.file, -- 1149
			row = signature.row, -- 1150
			col = signature.col -- 1151
		} -- 1146
		do -- 1153
			local doc = docs[i] -- 1153
			if doc then -- 1153
				item.doc = doc.doc -- 1154
				if doc.params then -- 1155
					item.params = doc.params -- 1156
					item.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1157
				elseif doc.returnType then -- 1158
					item.desc = "function()" -- 1159
				end -- 1155
				if doc.returnType then -- 1160
					item.desc = item.desc .. ": " .. tostring(doc.returnType) -- 1160
				end -- 1160
			end -- 1153
		end -- 1153
		results[#results + 1] = item -- 1161
	end -- 1145
	return results -- 1162
end -- 1098
HttpServer:postSchedule("/signature", function(req) -- 1164
	do -- 1165
		local _type_0 = type(req) -- 1165
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1165
		if _tab_0 then -- 1165
			local lang -- 1165
			do -- 1165
				local _obj_0 = req.body -- 1165
				local _type_1 = type(_obj_0) -- 1165
				if "table" == _type_1 or "userdata" == _type_1 then -- 1165
					lang = _obj_0.lang -- 1165
				end -- 1165
			end -- 1165
			local file -- 1165
			do -- 1165
				local _obj_0 = req.body -- 1165
				local _type_1 = type(_obj_0) -- 1165
				if "table" == _type_1 or "userdata" == _type_1 then -- 1165
					file = _obj_0.file -- 1165
				end -- 1165
			end -- 1165
			local content -- 1165
			do -- 1165
				local _obj_0 = req.body -- 1165
				local _type_1 = type(_obj_0) -- 1165
				if "table" == _type_1 or "userdata" == _type_1 then -- 1165
					content = _obj_0.content -- 1165
				end -- 1165
			end -- 1165
			local line -- 1165
			do -- 1165
				local _obj_0 = req.body -- 1165
				local _type_1 = type(_obj_0) -- 1165
				if "table" == _type_1 or "userdata" == _type_1 then -- 1165
					line = _obj_0.line -- 1165
				end -- 1165
			end -- 1165
			local row -- 1165
			do -- 1165
				local _obj_0 = req.body -- 1165
				local _type_1 = type(_obj_0) -- 1165
				if "table" == _type_1 or "userdata" == _type_1 then -- 1165
					row = _obj_0.row -- 1165
				end -- 1165
			end -- 1165
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1165
				local searchPath = getSearchPath(file) -- 1166
				if "tl" == lang or "lua" == lang then -- 1167
					if CheckTIC80Code(content) then -- 1168
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1169
					end -- 1168
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1170
					if signatures then -- 1170
						signatures = getParamDocs(signatures) -- 1171
						if signatures then -- 1171
							return { -- 1172
								success = true, -- 1172
								signatures = signatures -- 1172
							} -- 1172
						end -- 1171
					end -- 1170
				elseif "yue" == lang then -- 1173
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1174
					if not luaCodes then -- 1175
						return { -- 1175
							success = false -- 1175
						} -- 1175
					end -- 1175
					do -- 1176
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1176
						if chainOp then -- 1176
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1177
							if withVar then -- 1177
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1178
							end -- 1177
						end -- 1176
					end -- 1176
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1179
					if signatures then -- 1179
						signatures = getParamDocs(signatures) -- 1180
						if signatures then -- 1180
							return { -- 1181
								success = true, -- 1181
								signatures = signatures -- 1181
							} -- 1181
						end -- 1180
					else -- 1182
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1182
						if signatures then -- 1182
							signatures = getParamDocs(signatures) -- 1183
							if signatures then -- 1183
								return { -- 1184
									success = true, -- 1184
									signatures = signatures -- 1184
								} -- 1184
							end -- 1183
						end -- 1182
					end -- 1179
				end -- 1167
			end -- 1165
		end -- 1165
	end -- 1165
	return { -- 1164
		success = false -- 1164
	} -- 1164
end) -- 1164
local luaKeywords = { -- 1187
	'and', -- 1187
	'break', -- 1188
	'do', -- 1189
	'else', -- 1190
	'elseif', -- 1191
	'end', -- 1192
	'false', -- 1193
	'for', -- 1194
	'function', -- 1195
	'goto', -- 1196
	'if', -- 1197
	'in', -- 1198
	'local', -- 1199
	'nil', -- 1200
	'not', -- 1201
	'or', -- 1202
	'repeat', -- 1203
	'return', -- 1204
	'then', -- 1205
	'true', -- 1206
	'until', -- 1207
	'while' -- 1208
} -- 1186
local tealKeywords = { -- 1212
	'record', -- 1212
	'as', -- 1213
	'is', -- 1214
	'type', -- 1215
	'embed', -- 1216
	'enum', -- 1217
	'global', -- 1218
	'any', -- 1219
	'boolean', -- 1220
	'integer', -- 1221
	'number', -- 1222
	'string', -- 1223
	'thread' -- 1224
} -- 1211
local yueKeywords = { -- 1228
	"and", -- 1228
	"break", -- 1229
	"do", -- 1230
	"else", -- 1231
	"elseif", -- 1232
	"false", -- 1233
	"for", -- 1234
	"goto", -- 1235
	"if", -- 1236
	"in", -- 1237
	"local", -- 1238
	"nil", -- 1239
	"not", -- 1240
	"or", -- 1241
	"repeat", -- 1242
	"return", -- 1243
	"then", -- 1244
	"true", -- 1245
	"until", -- 1246
	"while", -- 1247
	"as", -- 1248
	"class", -- 1249
	"continue", -- 1250
	"export", -- 1251
	"extends", -- 1252
	"from", -- 1253
	"global", -- 1254
	"import", -- 1255
	"macro", -- 1256
	"switch", -- 1257
	"try", -- 1258
	"unless", -- 1259
	"using", -- 1260
	"when", -- 1261
	"with" -- 1262
} -- 1227
local _anon_func_4 = function(f) -- 1298
	local _val_0 = Path:getExt(f) -- 1298
	return "ttf" == _val_0 or "otf" == _val_0 -- 1298
end -- 1298
local _anon_func_5 = function(suggestions) -- 1324
	local _tbl_0 = { } -- 1324
	for _index_0 = 1, #suggestions do -- 1324
		local item = suggestions[_index_0] -- 1324
		_tbl_0[item[1] .. item[2]] = item -- 1324
	end -- 1324
	return _tbl_0 -- 1324
end -- 1324
HttpServer:postSchedule("/complete", function(req) -- 1265
	do -- 1266
		local _type_0 = type(req) -- 1266
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1266
		if _tab_0 then -- 1266
			local lang -- 1266
			do -- 1266
				local _obj_0 = req.body -- 1266
				local _type_1 = type(_obj_0) -- 1266
				if "table" == _type_1 or "userdata" == _type_1 then -- 1266
					lang = _obj_0.lang -- 1266
				end -- 1266
			end -- 1266
			local file -- 1266
			do -- 1266
				local _obj_0 = req.body -- 1266
				local _type_1 = type(_obj_0) -- 1266
				if "table" == _type_1 or "userdata" == _type_1 then -- 1266
					file = _obj_0.file -- 1266
				end -- 1266
			end -- 1266
			local content -- 1266
			do -- 1266
				local _obj_0 = req.body -- 1266
				local _type_1 = type(_obj_0) -- 1266
				if "table" == _type_1 or "userdata" == _type_1 then -- 1266
					content = _obj_0.content -- 1266
				end -- 1266
			end -- 1266
			local line -- 1266
			do -- 1266
				local _obj_0 = req.body -- 1266
				local _type_1 = type(_obj_0) -- 1266
				if "table" == _type_1 or "userdata" == _type_1 then -- 1266
					line = _obj_0.line -- 1266
				end -- 1266
			end -- 1266
			local row -- 1266
			do -- 1266
				local _obj_0 = req.body -- 1266
				local _type_1 = type(_obj_0) -- 1266
				if "table" == _type_1 or "userdata" == _type_1 then -- 1266
					row = _obj_0.row -- 1266
				end -- 1266
			end -- 1266
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1266
				local searchPath = getSearchPath(file) -- 1267
				repeat -- 1268
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1269
					if lang == "yue" then -- 1270
						if not item then -- 1271
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1271
						end -- 1271
						if not item then -- 1272
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1272
						end -- 1272
					end -- 1270
					local searchType = nil -- 1273
					if not item then -- 1274
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1275
						if lang == "yue" then -- 1276
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1277
						end -- 1276
						if (item ~= nil) then -- 1278
							searchType = "Image" -- 1278
						end -- 1278
					end -- 1274
					if not item then -- 1279
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1280
						if lang == "yue" then -- 1281
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1282
						end -- 1281
						if (item ~= nil) then -- 1283
							searchType = "Font" -- 1283
						end -- 1283
					end -- 1279
					if not item then -- 1284
						break -- 1284
					end -- 1284
					local searchPaths = Content.searchPaths -- 1285
					local _list_0 = getSearchFolders(file) -- 1286
					for _index_0 = 1, #_list_0 do -- 1286
						local folder = _list_0[_index_0] -- 1286
						searchPaths[#searchPaths + 1] = folder -- 1287
					end -- 1286
					if searchType then -- 1288
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1288
					end -- 1288
					local tokens -- 1289
					do -- 1289
						local _accum_0 = { } -- 1289
						local _len_0 = 1 -- 1289
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1289
							_accum_0[_len_0] = mod -- 1289
							_len_0 = _len_0 + 1 -- 1289
						end -- 1289
						tokens = _accum_0 -- 1289
					end -- 1289
					local suggestions = { } -- 1290
					for _index_0 = 1, #searchPaths do -- 1291
						local path = searchPaths[_index_0] -- 1291
						local sPath = Path(path, table.unpack(tokens)) -- 1292
						if not Content:exist(sPath) then -- 1293
							goto _continue_0 -- 1293
						end -- 1293
						if searchType == "Font" then -- 1294
							local fontPath = Path(sPath, "Font") -- 1295
							if Content:exist(fontPath) then -- 1296
								local _list_1 = Content:getFiles(fontPath) -- 1297
								for _index_1 = 1, #_list_1 do -- 1297
									local f = _list_1[_index_1] -- 1297
									if _anon_func_4(f) then -- 1298
										if "." == f:sub(1, 1) then -- 1299
											goto _continue_1 -- 1299
										end -- 1299
										suggestions[#suggestions + 1] = { -- 1300
											Path:getName(f), -- 1300
											"font", -- 1300
											"field" -- 1300
										} -- 1300
									end -- 1298
									::_continue_1:: -- 1298
								end -- 1297
							end -- 1296
						end -- 1294
						local _list_1 = Content:getFiles(sPath) -- 1301
						for _index_1 = 1, #_list_1 do -- 1301
							local f = _list_1[_index_1] -- 1301
							if "Image" == searchType then -- 1302
								do -- 1303
									local _exp_0 = Path:getExt(f) -- 1303
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1303
										if "." == f:sub(1, 1) then -- 1304
											goto _continue_2 -- 1304
										end -- 1304
										suggestions[#suggestions + 1] = { -- 1305
											f, -- 1305
											"image", -- 1305
											"field" -- 1305
										} -- 1305
									end -- 1303
								end -- 1303
								goto _continue_2 -- 1306
							elseif "Font" == searchType then -- 1307
								do -- 1308
									local _exp_0 = Path:getExt(f) -- 1308
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1308
										if "." == f:sub(1, 1) then -- 1309
											goto _continue_2 -- 1309
										end -- 1309
										suggestions[#suggestions + 1] = { -- 1310
											f, -- 1310
											"font", -- 1310
											"field" -- 1310
										} -- 1310
									end -- 1308
								end -- 1308
								goto _continue_2 -- 1311
							end -- 1302
							local _exp_0 = Path:getExt(f) -- 1312
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1312
								local name = Path:getName(f) -- 1313
								if "d" == Path:getExt(name) then -- 1314
									goto _continue_2 -- 1314
								end -- 1314
								if "." == name:sub(1, 1) then -- 1315
									goto _continue_2 -- 1315
								end -- 1315
								suggestions[#suggestions + 1] = { -- 1316
									name, -- 1316
									"module", -- 1316
									"field" -- 1316
								} -- 1316
							end -- 1312
							::_continue_2:: -- 1302
						end -- 1301
						local _list_2 = Content:getDirs(sPath) -- 1317
						for _index_1 = 1, #_list_2 do -- 1317
							local dir = _list_2[_index_1] -- 1317
							if "." == dir:sub(1, 1) then -- 1318
								goto _continue_3 -- 1318
							end -- 1318
							suggestions[#suggestions + 1] = { -- 1319
								dir, -- 1319
								"folder", -- 1319
								"variable" -- 1319
							} -- 1319
							::_continue_3:: -- 1318
						end -- 1317
						::_continue_0:: -- 1292
					end -- 1291
					if item == "" and not searchType then -- 1320
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1321
						for _index_0 = 1, #_list_1 do -- 1321
							local _des_0 = _list_1[_index_0] -- 1321
							local name = _des_0[1] -- 1321
							suggestions[#suggestions + 1] = { -- 1322
								name, -- 1322
								"dora module", -- 1322
								"function" -- 1322
							} -- 1322
						end -- 1321
					end -- 1320
					if #suggestions > 0 then -- 1323
						do -- 1324
							local _accum_0 = { } -- 1324
							local _len_0 = 1 -- 1324
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1324
								_accum_0[_len_0] = v -- 1324
								_len_0 = _len_0 + 1 -- 1324
							end -- 1324
							suggestions = _accum_0 -- 1324
						end -- 1324
						return { -- 1325
							success = true, -- 1325
							suggestions = suggestions -- 1325
						} -- 1325
					else -- 1327
						return { -- 1327
							success = false -- 1327
						} -- 1327
					end -- 1323
				until true -- 1268
				if "tl" == lang or "lua" == lang then -- 1329
					do -- 1330
						local isTIC80 = CheckTIC80Code(content) -- 1330
						if isTIC80 then -- 1330
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1331
						end -- 1330
					end -- 1330
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1332
					if not line:match("[%.:]$") then -- 1333
						local checkSet -- 1334
						do -- 1334
							local _tbl_0 = { } -- 1334
							for _index_0 = 1, #suggestions do -- 1334
								local _des_0 = suggestions[_index_0] -- 1334
								local name = _des_0[1] -- 1334
								_tbl_0[name] = true -- 1334
							end -- 1334
							checkSet = _tbl_0 -- 1334
						end -- 1334
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1335
						for _index_0 = 1, #_list_0 do -- 1335
							local item = _list_0[_index_0] -- 1335
							if not checkSet[item[1]] then -- 1336
								suggestions[#suggestions + 1] = item -- 1336
							end -- 1336
						end -- 1335
						for _index_0 = 1, #luaKeywords do -- 1337
							local word = luaKeywords[_index_0] -- 1337
							suggestions[#suggestions + 1] = { -- 1338
								word, -- 1338
								"keyword", -- 1338
								"keyword" -- 1338
							} -- 1338
						end -- 1337
						if lang == "tl" then -- 1339
							for _index_0 = 1, #tealKeywords do -- 1340
								local word = tealKeywords[_index_0] -- 1340
								suggestions[#suggestions + 1] = { -- 1341
									word, -- 1341
									"keyword", -- 1341
									"keyword" -- 1341
								} -- 1341
							end -- 1340
						end -- 1339
					end -- 1333
					if #suggestions > 0 then -- 1342
						return { -- 1343
							success = true, -- 1343
							suggestions = suggestions -- 1343
						} -- 1343
					end -- 1342
				elseif "yue" == lang then -- 1344
					local suggestions = { } -- 1345
					local gotGlobals = false -- 1346
					do -- 1347
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1347
						if luaCodes then -- 1347
							gotGlobals = true -- 1348
							do -- 1349
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1349
								if chainOp then -- 1349
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1350
									if not withVar then -- 1351
										return { -- 1351
											success = false -- 1351
										} -- 1351
									end -- 1351
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1352
								elseif line:match("^([%.\\])$") then -- 1353
									return { -- 1354
										success = false -- 1354
									} -- 1354
								end -- 1349
							end -- 1349
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1355
							for _index_0 = 1, #_list_0 do -- 1355
								local item = _list_0[_index_0] -- 1355
								suggestions[#suggestions + 1] = item -- 1355
							end -- 1355
							if #suggestions == 0 then -- 1356
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1357
								for _index_0 = 1, #_list_1 do -- 1357
									local item = _list_1[_index_0] -- 1357
									suggestions[#suggestions + 1] = item -- 1357
								end -- 1357
							end -- 1356
						end -- 1347
					end -- 1347
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1358
						local checkSet -- 1359
						do -- 1359
							local _tbl_0 = { } -- 1359
							for _index_0 = 1, #suggestions do -- 1359
								local _des_0 = suggestions[_index_0] -- 1359
								local name = _des_0[1] -- 1359
								_tbl_0[name] = true -- 1359
							end -- 1359
							checkSet = _tbl_0 -- 1359
						end -- 1359
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1360
						for _index_0 = 1, #_list_0 do -- 1360
							local item = _list_0[_index_0] -- 1360
							if not checkSet[item[1]] then -- 1361
								suggestions[#suggestions + 1] = item -- 1361
							end -- 1361
						end -- 1360
						if not gotGlobals then -- 1362
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1363
							for _index_0 = 1, #_list_1 do -- 1363
								local item = _list_1[_index_0] -- 1363
								if not checkSet[item[1]] then -- 1364
									suggestions[#suggestions + 1] = item -- 1364
								end -- 1364
							end -- 1363
						end -- 1362
						for _index_0 = 1, #yueKeywords do -- 1365
							local word = yueKeywords[_index_0] -- 1365
							if not checkSet[word] then -- 1366
								suggestions[#suggestions + 1] = { -- 1367
									word, -- 1367
									"keyword", -- 1367
									"keyword" -- 1367
								} -- 1367
							end -- 1366
						end -- 1365
					end -- 1358
					if #suggestions > 0 then -- 1368
						return { -- 1369
							success = true, -- 1369
							suggestions = suggestions -- 1369
						} -- 1369
					end -- 1368
				elseif "xml" == lang then -- 1370
					local items = xml.complete(content) -- 1371
					if #items > 0 then -- 1372
						local suggestions -- 1373
						do -- 1373
							local _accum_0 = { } -- 1373
							local _len_0 = 1 -- 1373
							for _index_0 = 1, #items do -- 1373
								local _des_0 = items[_index_0] -- 1373
								local label, insertText = _des_0[1], _des_0[2] -- 1373
								_accum_0[_len_0] = { -- 1374
									label, -- 1374
									insertText, -- 1374
									"field" -- 1374
								} -- 1374
								_len_0 = _len_0 + 1 -- 1374
							end -- 1373
							suggestions = _accum_0 -- 1373
						end -- 1373
						return { -- 1375
							success = true, -- 1375
							suggestions = suggestions -- 1375
						} -- 1375
					end -- 1372
				end -- 1329
			end -- 1266
		end -- 1266
	end -- 1266
	return { -- 1265
		success = false -- 1265
	} -- 1265
end) -- 1265
local getUploadFilename -- 1377
getUploadFilename = function(req, multipartFilename) -- 1377
	local filename = req.params.name -- 1378
	if not (type(filename) == "string" and filename ~= "") then -- 1379
		filename = multipartFilename -- 1379
	end -- 1379
	if not (type(filename) == "string" and filename ~= "") then -- 1380
		return -- 1380
	end -- 1380
	if filename:sub(1, 1) == "/" or filename:sub(-1) == "/" or filename:find("//", 1, true) or filename:find("\\", 1, true) or filename:find(":", 1, true) or filename:find("\0", 1, true) then -- 1383
		return -- 1383
	end -- 1383
	local parts -- 1384
	do -- 1384
		local _accum_0 = { } -- 1384
		local _len_0 = 1 -- 1384
		for part in filename:gmatch("[^/]+") do -- 1384
			_accum_0[_len_0] = part -- 1384
			_len_0 = _len_0 + 1 -- 1384
		end -- 1384
		parts = _accum_0 -- 1384
	end -- 1384
	if #parts == 0 then -- 1385
		return -- 1385
	end -- 1385
	for _index_0 = 1, #parts do -- 1386
		local part = parts[_index_0] -- 1386
		if part == "." or part == ".." or part == "" then -- 1387
			return -- 1387
		end -- 1387
	end -- 1386
	return filename -- 1388
end -- 1377
HttpServer:upload("/upload", function(req, multipartFilename) -- 1392
	do -- 1393
		local _type_0 = type(req) -- 1393
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1393
		if _tab_0 then -- 1393
			local path -- 1393
			do -- 1393
				local _obj_0 = req.params -- 1393
				local _type_1 = type(_obj_0) -- 1393
				if "table" == _type_1 or "userdata" == _type_1 then -- 1393
					path = _obj_0.path -- 1393
				end -- 1393
			end -- 1393
			if path ~= nil then -- 1393
				local filename = getUploadFilename(req, multipartFilename) -- 1394
				if filename then -- 1394
					local uploadPath = Path(Content.writablePath, ".upload") -- 1395
					if not Content:exist(uploadPath) then -- 1396
						Content:mkdir(uploadPath) -- 1397
					end -- 1396
					local targetPath = Path(uploadPath, filename) -- 1398
					Content:mkdir(Path:getPath(targetPath)) -- 1399
					return targetPath -- 1400
				end -- 1394
			end -- 1393
		end -- 1393
	end -- 1393
	return nil -- 1392
end, function(req, file) -- 1401
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
				path = Path(Content.writablePath, path) -- 1403
				if Content:exist(path) then -- 1404
					local uploadPath = Path(Content.writablePath, ".upload") -- 1405
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1406
					Content:mkdir(Path:getPath(targetPath)) -- 1407
					if Content:move(file, targetPath) then -- 1408
						return true -- 1409
					end -- 1408
				end -- 1404
			end -- 1402
		end -- 1402
	end -- 1402
	return false -- 1401
end) -- 1390
HttpServer:post("/list", function(req) -- 1412
	do -- 1413
		local _type_0 = type(req) -- 1413
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1413
		if _tab_0 then -- 1413
			local path -- 1413
			do -- 1413
				local _obj_0 = req.body -- 1413
				local _type_1 = type(_obj_0) -- 1413
				if "table" == _type_1 or "userdata" == _type_1 then -- 1413
					path = _obj_0.path -- 1413
				end -- 1413
			end -- 1413
			if path ~= nil then -- 1413
				if Content:exist(path) then -- 1414
					local files = { } -- 1415
					local visitAssets -- 1416
					visitAssets = function(path, folder) -- 1416
						local dirs = Content:getDirs(path) -- 1417
						for _index_0 = 1, #dirs do -- 1418
							local dir = dirs[_index_0] -- 1418
							if dir:match("^%.") or dir == "node_modules" then -- 1419
								goto _continue_0 -- 1419
							end -- 1419
							local current -- 1420
							if folder == "" then -- 1420
								current = dir -- 1421
							else -- 1423
								current = Path(folder, dir) -- 1423
							end -- 1420
							files[#files + 1] = current -- 1424
							visitAssets(Path(path, dir), current) -- 1425
							::_continue_0:: -- 1419
						end -- 1418
						local fs = Content:getFiles(path) -- 1426
						for _index_0 = 1, #fs do -- 1427
							local f = fs[_index_0] -- 1427
							if (".DS_Store" == f) then -- 1428
								goto _continue_1 -- 1429
							end -- 1428
							if folder == "" then -- 1430
								files[#files + 1] = f -- 1431
							else -- 1433
								files[#files + 1] = Path(folder, f) -- 1433
							end -- 1430
							::_continue_1:: -- 1428
						end -- 1427
					end -- 1416
					visitAssets(path, "") -- 1434
					if #files == 0 then -- 1435
						files = nil -- 1435
					end -- 1435
					return { -- 1436
						success = true, -- 1436
						files = files -- 1436
					} -- 1436
				end -- 1414
			end -- 1413
		end -- 1413
	end -- 1413
	return { -- 1412
		success = false -- 1412
	} -- 1412
end) -- 1412
HttpServer:post("/info", function(req) -- 1438
	local Entry = require("Script.Dev.Entry") -- 1439
	local config = Entry.getConfig() -- 1440
	do -- 1441
		local _type_0 = type(req) -- 1441
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1441
		if _tab_0 then -- 1441
			local webIDETourCompleted -- 1441
			do -- 1441
				local _obj_0 = req.body -- 1441
				local _type_1 = type(_obj_0) -- 1441
				if "table" == _type_1 or "userdata" == _type_1 then -- 1441
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1441
				end -- 1441
			end -- 1441
			if webIDETourCompleted ~= nil then -- 1441
				config.webIDETourCompleted = webIDETourCompleted == true -- 1442
			end -- 1441
		end -- 1441
	end -- 1441
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1443
	local engineDev = Entry.getEngineDev() -- 1444
	Entry.connectWebIDE() -- 1445
	return { -- 1447
		platform = App.platform, -- 1447
		locale = App.locale, -- 1448
		version = App.version, -- 1449
		engineDev = engineDev, -- 1450
		webProfiler = webProfiler, -- 1451
		drawerWidth = drawerWidth, -- 1452
		webIDETourCompleted = webIDETourCompleted == true -- 1453
	} -- 1446
end) -- 1438
local ensureLLMConfigTable -- 1455
ensureLLMConfigTable = function() -- 1455
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1456
	if columns and #columns > 0 then -- 1457
		local expected = { -- 1459
			id = true, -- 1459
			name = true, -- 1460
			url = true, -- 1461
			model = true, -- 1462
			api_key = true, -- 1463
			context_window = true, -- 1464
			temperature = true, -- 1465
			max_tokens = true, -- 1466
			reasoning_effort = true, -- 1467
			custom_options = true, -- 1468
			supports_function_calling = true, -- 1469
			active = true, -- 1470
			created_at = true, -- 1471
			updated_at = true -- 1472
		} -- 1458
		local existing = { } -- 1474
		local valid = true -- 1475
		for _index_0 = 1, #columns do -- 1476
			local row = columns[_index_0] -- 1476
			local columnName = tostring(row[2]) -- 1477
			existing[columnName] = true -- 1478
			if not expected[columnName] then -- 1479
				valid = false -- 1480
				break -- 1481
			end -- 1479
		end -- 1476
		if valid then -- 1482
			if not existing.context_window then -- 1483
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1484
			end -- 1483
			if not existing.temperature then -- 1485
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1486
			end -- 1485
			if not existing.max_tokens then -- 1487
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 64000") -- 1488
			end -- 1487
			if not existing.reasoning_effort then -- 1489
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1490
			end -- 1489
			if not existing.custom_options then -- 1491
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1492
			end -- 1491
			if not existing.supports_function_calling then -- 1493
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1494
			end -- 1493
		else -- 1496
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1496
		end -- 1482
	end -- 1457
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
	]]) -- 1497
	return require("Agent.LLMConfigMigration").upgradeLLMConfig() -- 1516
end -- 1455
local normalizeContextWindow -- 1518
normalizeContextWindow = function(value) -- 1518
	local contextWindow = tonumber(value) -- 1519
	if contextWindow == nil or contextWindow < 64000 then -- 1520
		return 64000 -- 1521
	end -- 1520
	return math.max(64000, math.floor(contextWindow)) -- 1522
end -- 1518
local normalizeTemperature -- 1524
normalizeTemperature = function(value) -- 1524
	local temperature = tonumber(value) -- 1525
	if temperature == nil then -- 1526
		return 0.1 -- 1527
	end -- 1526
	return math.max(0, math.min(2, temperature)) -- 1528
end -- 1524
local normalizeMaxTokens -- 1530
normalizeMaxTokens = function(value) -- 1530
	local maxTokens = tonumber(value) -- 1531
	if maxTokens == nil or maxTokens < 1 then -- 1532
		return 64000 -- 1533
	end -- 1532
	return math.max(1, math.floor(maxTokens)) -- 1534
end -- 1530
local normalizeReasoningEffort -- 1536
normalizeReasoningEffort = function(value) -- 1536
	if value == nil then -- 1537
		return "" -- 1538
	end -- 1537
	local effort = tostring(value) -- 1539
	return effort:match("^%s*(.-)%s*$") or "" -- 1540
end -- 1536
local normalizeCustomOptions -- 1542
normalizeCustomOptions = function(value) -- 1542
	if value == nil then -- 1543
		return "" -- 1544
	end -- 1543
	local options = tostring(value) -- 1545
	options = options:match("^%s*(.-)%s*$") or "" -- 1546
	return options -- 1547
end -- 1542
local validateCustomOptions -- 1549
validateCustomOptions = function(value) -- 1549
	local options = normalizeCustomOptions(value) -- 1550
	if options == "" then -- 1551
		return true -- 1551
	end -- 1551
	if not options:match("^%s*{") then -- 1552
		return false -- 1552
	end -- 1552
	local decoded = json.decode(options) -- 1553
	return type(decoded) == "table" -- 1554
end -- 1549
HttpServer:post("/llm/list", function() -- 1556
	ensureLLMConfigTable() -- 1557
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1558
	local items -- 1562
	if rows and #rows > 0 then -- 1562
		local _accum_0 = { } -- 1563
		local _len_0 = 1 -- 1563
		for _index_0 = 1, #rows do -- 1563
			local _des_0 = rows[_index_0] -- 1563
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1563
			_accum_0[_len_0] = { -- 1564
				id = id, -- 1564
				name = name, -- 1564
				url = url, -- 1564
				model = model, -- 1564
				key = key, -- 1564
				contextWindow = normalizeContextWindow(contextWindow), -- 1564
				temperature = normalizeTemperature(temperature), -- 1564
				maxTokens = normalizeMaxTokens(maxTokens), -- 1564
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1564
				customOptions = normalizeCustomOptions(customOptions), -- 1564
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1564
			} -- 1564
			_len_0 = _len_0 + 1 -- 1564
		end -- 1563
		items = _accum_0 -- 1562
	end -- 1562
	return { -- 1565
		success = true, -- 1565
		items = items -- 1565
	} -- 1565
end) -- 1556
HttpServer:post("/llm/create", function(req) -- 1567
	ensureLLMConfigTable() -- 1568
	do -- 1569
		local _type_0 = type(req) -- 1569
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1569
		if _tab_0 then -- 1569
			local body = req.body -- 1569
			if body ~= nil then -- 1569
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1570
				local now = os.time() -- 1571
				if name == nil or url == nil or model == nil or key == nil then -- 1572
					return invalidArguments -- 1573
				end -- 1572
				contextWindow = normalizeContextWindow(contextWindow) -- 1574
				temperature = normalizeTemperature(temperature) -- 1575
				maxTokens = normalizeMaxTokens(maxTokens) -- 1576
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1577
				customOptions = normalizeCustomOptions(customOptions) -- 1578
				if not validateCustomOptions(customOptions) then -- 1579
					return { -- 1579
						success = false, -- 1579
						message = "customOptions must be a JSON object" -- 1579
					} -- 1579
				end -- 1579
				if supportsFunctionCalling == false then -- 1580
					supportsFunctionCalling = 0 -- 1580
				else -- 1580
					supportsFunctionCalling = 1 -- 1580
				end -- 1580
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1587
					tostring(name), -- 1587
					tostring(url), -- 1588
					tostring(model), -- 1589
					tostring(key), -- 1590
					contextWindow, -- 1591
					temperature, -- 1592
					maxTokens, -- 1593
					reasoningEffort, -- 1594
					customOptions, -- 1595
					supportsFunctionCalling, -- 1596
					1, -- 1597
					now, -- 1598
					now -- 1599
				}) -- 1581
				return { -- 1601
					success = affected >= 0 -- 1601
				} -- 1601
			end -- 1569
		end -- 1569
	end -- 1569
	return invalidArguments -- 1567
end) -- 1567
HttpServer:post("/llm/update", function(req) -- 1603
	ensureLLMConfigTable() -- 1604
	do -- 1605
		local _type_0 = type(req) -- 1605
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1605
		if _tab_0 then -- 1605
			local body = req.body -- 1605
			if body ~= nil then -- 1605
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1606
				local now = os.time() -- 1607
				id = tonumber(id) -- 1608
				if id == nil then -- 1609
					return invalidArguments -- 1609
				end -- 1609
				contextWindow = normalizeContextWindow(contextWindow) -- 1610
				temperature = normalizeTemperature(temperature) -- 1611
				maxTokens = normalizeMaxTokens(maxTokens) -- 1612
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1613
				customOptions = normalizeCustomOptions(customOptions) -- 1614
				if not validateCustomOptions(customOptions) then -- 1615
					return { -- 1615
						success = false, -- 1615
						message = "customOptions must be a JSON object" -- 1615
					} -- 1615
				end -- 1615
				if supportsFunctionCalling == false then -- 1616
					supportsFunctionCalling = 0 -- 1616
				else -- 1616
					supportsFunctionCalling = 1 -- 1616
				end -- 1616
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1621
					tostring(name), -- 1621
					tostring(url), -- 1622
					tostring(model), -- 1623
					tostring(key), -- 1624
					contextWindow, -- 1625
					temperature, -- 1626
					maxTokens, -- 1627
					reasoningEffort, -- 1628
					customOptions, -- 1629
					supportsFunctionCalling, -- 1630
					now, -- 1631
					id -- 1632
				}) -- 1617
				return { -- 1634
					success = affected >= 0 -- 1634
				} -- 1634
			end -- 1605
		end -- 1605
	end -- 1605
	return invalidArguments -- 1603
end) -- 1603
HttpServer:post("/llm/delete", function(req) -- 1636
	ensureLLMConfigTable() -- 1637
	do -- 1638
		local _type_0 = type(req) -- 1638
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1638
		if _tab_0 then -- 1638
			local id -- 1638
			do -- 1638
				local _obj_0 = req.body -- 1638
				local _type_1 = type(_obj_0) -- 1638
				if "table" == _type_1 or "userdata" == _type_1 then -- 1638
					id = _obj_0.id -- 1638
				end -- 1638
			end -- 1638
			if id ~= nil then -- 1638
				id = tonumber(id) -- 1639
				if id == nil then -- 1640
					return invalidArguments -- 1640
				end -- 1640
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1641
					id -- 1641
				}) -- 1641
				return { -- 1642
					success = affected >= 0 -- 1642
				} -- 1642
			end -- 1638
		end -- 1638
	end -- 1638
	return invalidArguments -- 1636
end) -- 1636
HttpServer:post("/local-agent/list", function() -- 1644
	return { -- 1645
		success = true, -- 1645
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1645
		items = AgentLocalAgent.listConfigs() -- 1645
	} -- 1645
end) -- 1644
HttpServer:post("/local-agent/save", function(req) -- 1647
	do -- 1648
		local _type_0 = type(req) -- 1648
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1648
		if _tab_0 then -- 1648
			local body = req.body -- 1648
			if body ~= nil then -- 1648
				return AgentLocalAgent.saveConfig(body) -- 1649
			end -- 1648
		end -- 1648
	end -- 1648
	return invalidArguments -- 1647
end) -- 1647
HttpServer:post("/local-agent/delete", function(req) -- 1651
	do -- 1652
		local _type_0 = type(req) -- 1652
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1652
		if _tab_0 then -- 1652
			local id -- 1652
			do -- 1652
				local _obj_0 = req.body -- 1652
				local _type_1 = type(_obj_0) -- 1652
				if "table" == _type_1 or "userdata" == _type_1 then -- 1652
					id = _obj_0.id -- 1652
				end -- 1652
			end -- 1652
			if id ~= nil then -- 1652
				return AgentLocalAgent.deleteConfig(id) -- 1653
			end -- 1652
		end -- 1652
	end -- 1652
	return invalidArguments -- 1651
end) -- 1651
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1655
	do -- 1656
		local _type_0 = type(req) -- 1656
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1656
		if _tab_0 then -- 1656
			local id -- 1656
			do -- 1656
				local _obj_0 = req.body -- 1656
				local _type_1 = type(_obj_0) -- 1656
				if "table" == _type_1 or "userdata" == _type_1 then -- 1656
					id = _obj_0.id -- 1656
				end -- 1656
			end -- 1656
			if id ~= nil then -- 1656
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1657
			end -- 1656
		end -- 1656
	end -- 1656
	return invalidArguments -- 1655
end) -- 1655
HttpServer:post("/stat", function(req) -- 1659
	do -- 1660
		local _type_0 = type(req) -- 1660
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1660
		if _tab_0 then -- 1660
			local path -- 1660
			do -- 1660
				local _obj_0 = req.body -- 1660
				local _type_1 = type(_obj_0) -- 1660
				if "table" == _type_1 or "userdata" == _type_1 then -- 1660
					path = _obj_0.path -- 1660
				end -- 1660
			end -- 1660
			if path ~= nil then -- 1660
				if not Content:exist(path) then -- 1661
					return { -- 1662
						success = false, -- 1662
						message = "target not existed" -- 1662
					} -- 1662
				end -- 1661
				if Content:isdir(path) then -- 1663
					return { -- 1664
						success = false, -- 1664
						message = "failed to stat a directory" -- 1664
					} -- 1664
				end -- 1663
				local size, isBinary = Content:getAttr(path) -- 1665
				if size then -- 1665
					return { -- 1666
						success = true, -- 1666
						size = size, -- 1666
						isBinary = isBinary -- 1666
					} -- 1666
				end -- 1665
			end -- 1660
		end -- 1660
	end -- 1660
	return { -- 1659
		success = false, -- 1659
		message = "failed to stat" -- 1659
	} -- 1659
end) -- 1659
HttpServer:post("/new", function(req) -- 1668
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
			local content -- 1669
			do -- 1669
				local _obj_0 = req.body -- 1669
				local _type_1 = type(_obj_0) -- 1669
				if "table" == _type_1 or "userdata" == _type_1 then -- 1669
					content = _obj_0.content -- 1669
				end -- 1669
			end -- 1669
			local folder -- 1669
			do -- 1669
				local _obj_0 = req.body -- 1669
				local _type_1 = type(_obj_0) -- 1669
				if "table" == _type_1 or "userdata" == _type_1 then -- 1669
					folder = _obj_0.folder -- 1669
				end -- 1669
			end -- 1669
			if path ~= nil and content ~= nil and folder ~= nil then -- 1669
				if Content:exist(path) then -- 1670
					return { -- 1671
						success = false, -- 1671
						message = "TargetExisted" -- 1671
					} -- 1671
				end -- 1670
				local parent = Path:getPath(path) -- 1672
				local files = Content:getFiles(parent) -- 1673
				if folder then -- 1674
					local name = Path:getFilename(path):lower() -- 1675
					for _index_0 = 1, #files do -- 1676
						local file = files[_index_0] -- 1676
						if name == Path:getFilename(file):lower() then -- 1677
							return { -- 1678
								success = false, -- 1678
								message = "TargetExisted" -- 1678
							} -- 1678
						end -- 1677
					end -- 1676
					if Content:mkdir(path) then -- 1679
						return { -- 1680
							success = true -- 1680
						} -- 1680
					end -- 1679
				else -- 1682
					local name = Path:getName(path):lower() -- 1682
					for _index_0 = 1, #files do -- 1683
						local file = files[_index_0] -- 1683
						if name == Path:getName(file):lower() then -- 1684
							local ext = Path:getExt(file) -- 1685
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1686
								goto _continue_0 -- 1687
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1688
								goto _continue_0 -- 1689
							end -- 1686
							return { -- 1690
								success = false, -- 1690
								message = "SourceExisted" -- 1690
							} -- 1690
						end -- 1684
						::_continue_0:: -- 1684
					end -- 1683
					if Content:save(path, content) then -- 1691
						return { -- 1692
							success = true -- 1692
						} -- 1692
					end -- 1691
				end -- 1674
			end -- 1669
		end -- 1669
	end -- 1669
	return { -- 1668
		success = false, -- 1668
		message = "Failed" -- 1668
	} -- 1668
end) -- 1668
local deleteAsset -- 1694
deleteAsset = function(path) -- 1694
	if not Content:exist(path) then -- 1695
		return false -- 1695
	end -- 1695
	local projectRoot -- 1696
	if Content:isdir(path) and isProjectRootDir(path) then -- 1696
		projectRoot = path -- 1696
	else -- 1696
		projectRoot = nil -- 1696
	end -- 1696
	local parent = Path:getPath(path) -- 1697
	local files = Content:getFiles(parent) -- 1698
	local name = Path:getName(path):lower() -- 1699
	local ext = Path:getExt(path) -- 1700
	for _index_0 = 1, #files do -- 1701
		local file = files[_index_0] -- 1701
		if name == Path:getName(file):lower() then -- 1702
			local _exp_0 = Path:getExt(file) -- 1703
			if "tl" == _exp_0 then -- 1703
				if ("vs" == ext) then -- 1703
					Content:remove(Path(parent, file)) -- 1704
				end -- 1703
			elseif "lua" == _exp_0 then -- 1705
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1705
					Content:remove(Path(parent, file)) -- 1706
				end -- 1705
			end -- 1703
		end -- 1702
	end -- 1701
	if Content:remove(path) then -- 1707
		if projectRoot then -- 1708
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1709
		end -- 1708
		return true -- 1710
	end -- 1707
	return false -- 1711
end -- 1694
local moveAsset -- 1713
moveAsset = function(old, new) -- 1713
	if not (Content:exist(old) and not Content:exist(new)) then -- 1714
		return false -- 1714
	end -- 1714
	local renamedDir = Content:isdir(old) -- 1715
	local parent = Path:getPath(new) -- 1716
	local files = Content:getFiles(parent) -- 1717
	if renamedDir then -- 1718
		local name = Path:getFilename(new):lower() -- 1719
		for _index_0 = 1, #files do -- 1720
			local file = files[_index_0] -- 1720
			if name == Path:getFilename(file):lower() then -- 1721
				return false -- 1722
			end -- 1721
		end -- 1720
	else -- 1724
		local name = Path:getName(new):lower() -- 1724
		local ext = Path:getExt(new) -- 1725
		for _index_0 = 1, #files do -- 1726
			local file = files[_index_0] -- 1726
			if name == Path:getName(file):lower() then -- 1727
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1728
					goto _continue_0 -- 1729
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1730
					goto _continue_0 -- 1731
				end -- 1728
				return false -- 1732
			end -- 1727
			::_continue_0:: -- 1727
		end -- 1726
	end -- 1718
	if not Content:move(old, new) then -- 1733
		return false -- 1733
	end -- 1733
	if renamedDir then -- 1734
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1735
	end -- 1734
	local newParent = Path:getPath(new) -- 1736
	parent = Path:getPath(old) -- 1737
	files = Content:getFiles(parent) -- 1738
	local newName = Path:getName(new) -- 1739
	local oldName = Path:getName(old) -- 1740
	local name = oldName:lower() -- 1741
	local ext = Path:getExt(old) -- 1742
	for _index_0 = 1, #files do -- 1743
		local file = files[_index_0] -- 1743
		if name == Path:getName(file):lower() then -- 1744
			local _exp_0 = Path:getExt(file) -- 1745
			if "tl" == _exp_0 then -- 1745
				if ("vs" == ext) then -- 1745
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1746
				end -- 1745
			elseif "lua" == _exp_0 then -- 1747
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1747
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1748
				end -- 1747
			end -- 1745
		end -- 1744
	end -- 1743
	return true -- 1749
end -- 1713
HttpServer:post("/delete", function(req) -- 1751
	do -- 1752
		local _type_0 = type(req) -- 1752
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1752
		if _tab_0 then -- 1752
			local path -- 1752
			do -- 1752
				local _obj_0 = req.body -- 1752
				local _type_1 = type(_obj_0) -- 1752
				if "table" == _type_1 or "userdata" == _type_1 then -- 1752
					path = _obj_0.path -- 1752
				end -- 1752
			end -- 1752
			if path ~= nil then -- 1752
				if deleteAsset(path) then -- 1753
					return { -- 1753
						success = true -- 1753
					} -- 1753
				end -- 1753
			end -- 1752
		end -- 1752
	end -- 1752
	return { -- 1751
		success = false -- 1751
	} -- 1751
end) -- 1751
HttpServer:post("/rename", function(req) -- 1755
	do -- 1756
		local _type_0 = type(req) -- 1756
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1756
		if _tab_0 then -- 1756
			local old -- 1756
			do -- 1756
				local _obj_0 = req.body -- 1756
				local _type_1 = type(_obj_0) -- 1756
				if "table" == _type_1 or "userdata" == _type_1 then -- 1756
					old = _obj_0.old -- 1756
				end -- 1756
			end -- 1756
			local new -- 1756
			do -- 1756
				local _obj_0 = req.body -- 1756
				local _type_1 = type(_obj_0) -- 1756
				if "table" == _type_1 or "userdata" == _type_1 then -- 1756
					new = _obj_0.new -- 1756
				end -- 1756
			end -- 1756
			if old ~= nil and new ~= nil then -- 1756
				if moveAsset(old, new) then -- 1757
					return { -- 1757
						success = true -- 1757
					} -- 1757
				end -- 1757
			end -- 1756
		end -- 1756
	end -- 1756
	return { -- 1755
		success = false -- 1755
	} -- 1755
end) -- 1755
local normalizeAssetPaths -- 1759
normalizeAssetPaths = function(paths) -- 1759
	if not (type(paths) == "table") then -- 1760
		return nil -- 1760
	end -- 1760
	local unique = { } -- 1761
	local candidates = { } -- 1762
	for _index_0 = 1, #paths do -- 1763
		local path = paths[_index_0] -- 1763
		if not (type(path) == "string") then -- 1764
			return nil -- 1764
		end -- 1764
		local relative = relativeToRoot(path, Content.writablePath) -- 1765
		if relative == nil or relative == "" or not Content:exist(path) then -- 1766
			return nil -- 1766
		end -- 1766
		if not unique[path] then -- 1767
			unique[path] = true -- 1768
			candidates[#candidates + 1] = path -- 1769
		end -- 1767
	end -- 1763
	table.sort(candidates, function(a, b) -- 1770
		return #a < #b -- 1770
	end) -- 1770
	local result = { } -- 1771
	for _index_0 = 1, #candidates do -- 1772
		local path = candidates[_index_0] -- 1772
		local contained = false -- 1773
		for _index_1 = 1, #result do -- 1774
			local parent = result[_index_1] -- 1774
			if relativeToRoot(path, parent) ~= nil then -- 1775
				contained = true -- 1776
				break -- 1777
			end -- 1775
		end -- 1774
		if not contained then -- 1778
			result[#result + 1] = path -- 1778
		end -- 1778
	end -- 1772
	return result -- 1779
end -- 1759
HttpServer:postSchedule("/assets/batch", function(req) -- 1781
	do -- 1782
		local _type_0 = type(req) -- 1782
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1782
		if _tab_0 then -- 1782
			local operation -- 1782
			do -- 1782
				local _obj_0 = req.body -- 1782
				local _type_1 = type(_obj_0) -- 1782
				if "table" == _type_1 or "userdata" == _type_1 then -- 1782
					operation = _obj_0.operation -- 1782
				end -- 1782
			end -- 1782
			local sources -- 1782
			do -- 1782
				local _obj_0 = req.body -- 1782
				local _type_1 = type(_obj_0) -- 1782
				if "table" == _type_1 or "userdata" == _type_1 then -- 1782
					sources = _obj_0.sources -- 1782
				end -- 1782
			end -- 1782
			if operation ~= nil and sources ~= nil then -- 1782
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1783
					return { -- 1783
						success = false, -- 1783
						message = "invalid operation" -- 1783
					} -- 1783
				end -- 1783
				sources = normalizeAssetPaths(sources) -- 1784
				if not (sources and #sources > 0) then -- 1785
					return { -- 1785
						success = false, -- 1785
						message = "invalid sources" -- 1785
					} -- 1785
				end -- 1785
				local target = req.body.target -- 1786
				local destinations = { } -- 1787
				if operation ~= "delete" then -- 1788
					if not (type(target) == "string") then -- 1789
						return { -- 1789
							success = false, -- 1789
							message = "invalid target" -- 1789
						} -- 1789
					end -- 1789
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1790
					if targetRelative == nil then -- 1791
						return { -- 1791
							success = false, -- 1791
							message = "invalid target" -- 1791
						} -- 1791
					end -- 1791
					if not (Content:exist(target) and Content:isdir(target)) then -- 1792
						return { -- 1792
							success = false, -- 1792
							message = "invalid target" -- 1792
						} -- 1792
					end -- 1792
					for _index_0 = 1, #sources do -- 1793
						local source = sources[_index_0] -- 1793
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1794
							return { -- 1795
								success = false, -- 1795
								message = "target inside source" -- 1795
							} -- 1795
						end -- 1794
						local destination = Path(target, Path:getFilename(source)) -- 1796
						if Content:exist(destination) then -- 1797
							return { -- 1797
								success = false, -- 1797
								message = "target existed" -- 1797
							} -- 1797
						end -- 1797
						if destinations[destination] then -- 1798
							return { -- 1798
								success = false, -- 1798
								message = "duplicate target" -- 1798
							} -- 1798
						end -- 1798
						destinations[destination] = true -- 1799
					end -- 1793
				end -- 1788
				local changes = { } -- 1800
				local affectedSet = { } -- 1801
				local affectedDirectories = { } -- 1802
				local addAffected -- 1803
				addAffected = function(dir) -- 1803
					if affectedSet[dir] then -- 1804
						return -- 1804
					end -- 1804
					affectedSet[dir] = true -- 1805
					affectedDirectories[#affectedDirectories + 1] = dir -- 1806
				end -- 1803
				if operation ~= "delete" then -- 1807
					addAffected(target) -- 1807
				end -- 1807
				for _index_0 = 1, #sources do -- 1808
					local source = sources[_index_0] -- 1808
					addAffected(Path:getPath(source)) -- 1809
					if operation == "delete" then -- 1810
						if not deleteAsset(source) then -- 1811
							return { -- 1811
								success = false, -- 1811
								message = "delete failed", -- 1811
								changes = changes, -- 1811
								affectedDirectories = affectedDirectories -- 1811
							} -- 1811
						end -- 1811
						changes[#changes + 1] = { -- 1812
							old = source -- 1812
						} -- 1812
					else -- 1814
						local destination = Path(target, Path:getFilename(source)) -- 1814
						local ok -- 1815
						if operation == "copy" then -- 1815
							ok = Content:copyAsync(source, destination) -- 1816
						else -- 1818
							ok = moveAsset(source, destination) -- 1818
						end -- 1815
						if not ok then -- 1819
							return { -- 1819
								success = false, -- 1819
								message = operation .. " failed", -- 1819
								changes = changes, -- 1819
								affectedDirectories = affectedDirectories -- 1819
							} -- 1819
						end -- 1819
						changes[#changes + 1] = { -- 1820
							old = source, -- 1820
							new = destination -- 1820
						} -- 1820
					end -- 1810
				end -- 1808
				return { -- 1821
					success = true, -- 1821
					changes = changes, -- 1821
					affectedDirectories = affectedDirectories -- 1821
				} -- 1821
			end -- 1782
		end -- 1782
	end -- 1782
	return { -- 1781
		success = false, -- 1781
		message = "invalid request" -- 1781
	} -- 1781
end) -- 1781
local withProjectSearchPaths -- 1823
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1823
	local fallbackPaths = { } -- 1824
	local addFallback -- 1825
	addFallback = function(dir) -- 1825
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1825
			fallbackPaths[#fallbackPaths + 1] = dir -- 1825
		end -- 1825
	end -- 1825
	if projectRoot and projectRoot ~= "" then -- 1826
		addFallback(Path(projectRoot, "Script")) -- 1827
		addFallback(projectRoot) -- 1828
	end -- 1826
	if projFile then -- 1829
		local projDir = getProjectDirFromFile(projFile) -- 1830
		if projDir then -- 1830
			addFallback(Path(projDir, "Script")) -- 1831
			addFallback(projDir) -- 1832
		else -- 1834
			addFallback(Path:getPath(projFile)) -- 1834
		end -- 1830
	end -- 1829
	if not (#fallbackPaths > 0) then -- 1835
		return fn() -- 1835
	end -- 1835
	local searchPaths = Content.searchPaths -- 1836
	for _index_0 = 1, #fallbackPaths do -- 1837
		local dir = fallbackPaths[_index_0] -- 1837
		Content:addSearchPath(dir) -- 1837
	end -- 1837
	local _ <close> = setmetatable({ }, { -- 1838
		__close = function() -- 1838
			Content.searchPaths = searchPaths -- 1838
		end -- 1838
	}) -- 1838
	return fn() -- 1839
end -- 1823
HttpServer:post("/exist", function(req) -- 1840
	do -- 1841
		local _type_0 = type(req) -- 1841
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1841
		if _tab_0 then -- 1841
			local file -- 1841
			do -- 1841
				local _obj_0 = req.body -- 1841
				local _type_1 = type(_obj_0) -- 1841
				if "table" == _type_1 or "userdata" == _type_1 then -- 1841
					file = _obj_0.file -- 1841
				end -- 1841
			end -- 1841
			if file ~= nil then -- 1841
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1842
					return { -- 1843
						success = Content:exist(file) -- 1843
					} -- 1843
				end) -- 1842
			end -- 1841
		end -- 1841
	end -- 1841
	return { -- 1840
		success = false -- 1840
	} -- 1840
end) -- 1840
HttpServer:postSchedule("/read", function(req) -- 1844
	do -- 1845
		local _type_0 = type(req) -- 1845
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1845
		if _tab_0 then -- 1845
			local path -- 1845
			do -- 1845
				local _obj_0 = req.body -- 1845
				local _type_1 = type(_obj_0) -- 1845
				if "table" == _type_1 or "userdata" == _type_1 then -- 1845
					path = _obj_0.path -- 1845
				end -- 1845
			end -- 1845
			if path ~= nil then -- 1845
				local readFile -- 1846
				readFile = function() -- 1846
					if Content:exist(path) and not Content:isdir(path) then -- 1847
						local content = Content:loadAsync(path) -- 1848
						if content then -- 1848
							return { -- 1849
								content = content, -- 1849
								success = true, -- 1849
								fullPath = Content:getFullPath(path) -- 1849
							} -- 1849
						end -- 1848
					end -- 1847
					return nil -- 1846
				end -- 1846
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1850
				if result then -- 1850
					return result -- 1850
				end -- 1850
			end -- 1845
		end -- 1845
	end -- 1845
	return { -- 1844
		success = false -- 1844
	} -- 1844
end) -- 1844
local agentDocLanguage -- 1852
agentDocLanguage = function(language) -- 1852
	if language == "zh-Hans" then -- 1853
		return "zh" -- 1853
	else -- 1853
		return "en" -- 1853
	end -- 1853
end -- 1852
HttpServer:postSchedule("/doc/search", function(req) -- 1855
	local body = req.body or { } -- 1856
	local language = body.docLanguage -- 1857
	if not (("en" == language or "zh-Hans" == language)) then -- 1858
		return { -- 1858
			success = false, -- 1858
			message = "unsupported doc language" -- 1858
		} -- 1858
	end -- 1858
	local docType = body.docType -- 1859
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1860
		return { -- 1860
			success = false, -- 1860
			message = "unsupported doc type" -- 1860
		} -- 1860
	end -- 1860
	local codeLanguage = body.programmingLanguage -- 1861
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1862
		return { -- 1862
			success = false, -- 1862
			message = "unsupported programming language" -- 1862
		} -- 1862
	end -- 1862
	if not body.pattern then -- 1863
		return { -- 1863
			success = false, -- 1863
			message = "missing pattern" -- 1863
		} -- 1863
	end -- 1863
	local result = nil -- 1864
	AgentTools.searchDoraDocHttp({ -- 1866
		pattern = body.pattern, -- 1866
		docLanguage = agentDocLanguage(language), -- 1867
		docType = docType, -- 1868
		programmingLanguage = codeLanguage, -- 1869
		limit = body.limit, -- 1870
		useRegex = body.useRegex, -- 1871
		caseSensitive = body.caseSensitive, -- 1872
		includeContent = body.includeContent, -- 1873
		contentWindow = body.contentWindow -- 1874
	}, function(res) -- 1875
		result = res -- 1876
	end) -- 1865
	wait(function() -- 1877
		return result ~= nil -- 1877
	end) -- 1877
	if result and result.success then -- 1878
		result.docLanguage = language -- 1879
	end -- 1878
	if result then -- 1880
		return result -- 1881
	else -- 1883
		return { -- 1883
			success = false, -- 1883
			message = "doc search failed" -- 1883
		} -- 1883
	end -- 1880
	return { -- 1855
		success = false, -- 1855
		message = "invalid call" -- 1855
	} -- 1855
end) -- 1855
HttpServer:postSchedule("/doc/read", function(req) -- 1885
	local body = req.body or { } -- 1886
	local language = body.docLanguage -- 1887
	if not (("en" == language or "zh-Hans" == language)) then -- 1888
		return { -- 1888
			success = false, -- 1888
			message = "unsupported doc language" -- 1888
		} -- 1888
	end -- 1888
	if not body.file then -- 1889
		return { -- 1889
			success = false, -- 1889
			message = "missing file" -- 1889
		} -- 1889
	end -- 1889
	local result = AgentTools.readDoraDoc({ -- 1891
		docLanguage = agentDocLanguage(language), -- 1891
		file = body.file, -- 1892
		startLine = body.startLine, -- 1893
		endLine = body.endLine -- 1894
	}) -- 1890
	if result and result.success then -- 1895
		result.docLanguage = language -- 1896
	end -- 1895
	return result -- 1897
end) -- 1885
HttpServer:get("/read-sync", function(req) -- 1899
	do -- 1900
		local _type_0 = type(req) -- 1900
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1900
		if _tab_0 then -- 1900
			local params = req.params -- 1900
			if params ~= nil then -- 1900
				local path = params.path -- 1901
				if not (type(path) == "string" and path ~= "") then -- 1902
					return { -- 1902
						success = false, -- 1902
						message = "invalid path" -- 1902
					} -- 1902
				end -- 1902
				local exts -- 1903
				if params.exts then -- 1903
					local _accum_0 = { } -- 1904
					local _len_0 = 1 -- 1904
					for ext in params.exts:gmatch("[^|]*") do -- 1904
						_accum_0[_len_0] = ext -- 1904
						_len_0 = _len_0 + 1 -- 1904
					end -- 1904
					exts = _accum_0 -- 1904
				else -- 1905
					exts = { -- 1905
						"" -- 1905
					} -- 1905
				end -- 1903
				local readFileAt -- 1906
				readFileAt = function(targetPath) -- 1906
					if Content:exist(targetPath) then -- 1907
						local content = Content:load(targetPath) -- 1908
						if content then -- 1908
							return { -- 1909
								content = content, -- 1909
								success = true, -- 1909
								fullPath = Content:getFullPath(targetPath) -- 1909
							} -- 1909
						end -- 1908
					end -- 1907
					return nil -- 1906
				end -- 1906
				local readFile -- 1910
				readFile = function(fallbackPaths) -- 1910
					for _index_0 = 1, #exts do -- 1911
						local ext = exts[_index_0] -- 1911
						local targetPath = path .. ext -- 1912
						if not Content:isAbsolutePath(targetPath) then -- 1913
							for _index_1 = 1, #fallbackPaths do -- 1914
								local fallback = fallbackPaths[_index_1] -- 1914
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1915
								if fallbackResult then -- 1915
									return fallbackResult -- 1916
								end -- 1915
							end -- 1914
						end -- 1913
						local fileResult = readFileAt(targetPath) -- 1917
						if fileResult then -- 1917
							return fileResult -- 1918
						end -- 1917
					end -- 1911
					return nil -- 1910
				end -- 1910
				local fallbackPaths = { } -- 1919
				local fallbackCandidates = { } -- 1920
				do -- 1921
					local projectRoot = req.params.projectRoot -- 1921
					if projectRoot then -- 1921
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1922
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1923
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1924
						end -- 1922
					end -- 1921
				end -- 1921
				do -- 1925
					local projFile = req.params.projFile -- 1925
					if projFile then -- 1925
						local projDir = getProjectDirFromFile(projFile) -- 1926
						if projDir then -- 1926
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1927
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1928
						else -- 1930
							projDir = Path:getPath(projFile) -- 1930
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1931
						end -- 1926
					end -- 1925
				end -- 1925
				for _index_0 = 1, #fallbackCandidates do -- 1932
					local dir = fallbackCandidates[_index_0] -- 1932
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1933
						local exists = false -- 1934
						for _index_1 = 1, #fallbackPaths do -- 1935
							local fallback = fallbackPaths[_index_1] -- 1935
							if fallback == dir then -- 1936
								exists = true -- 1937
								break -- 1938
							end -- 1936
						end -- 1935
						if not exists then -- 1939
							fallbackPaths[#fallbackPaths + 1] = dir -- 1939
						end -- 1939
					end -- 1933
				end -- 1932
				local readResult = readFile(fallbackPaths) -- 1940
				if readResult then -- 1940
					return readResult -- 1941
				end -- 1940
			end -- 1900
		end -- 1900
	end -- 1900
	return { -- 1899
		success = false -- 1899
	} -- 1899
end) -- 1899
local addGeneratedSourceHeader -- 1943
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 1943
	if preserveTIC80 == nil then -- 1943
		preserveTIC80 = false -- 1943
	end -- 1943
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 1944
	if preserveTIC80 then -- 1945
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 1946
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 1947
		end -- 1946
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 1948
	end -- 1945
	return tostring(header) .. "\n" .. tostring(codes) -- 1949
end -- 1943
local compileFileAsync -- 1951
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1951
	if projectRoot == nil then -- 1951
		projectRoot = nil -- 1951
	end -- 1951
	local file = inputFile -- 1952
	local searchPath -- 1953
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1953
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1954
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1958
	elseif not Content:isAbsolutePath(inputFile) then -- 1959
		searchPath = "" -- 1960
	else -- 1961
		local dir = getProjectDirFromFile(inputFile) -- 1961
		if dir then -- 1961
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1962
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1966
		else -- 1968
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1968
			searchPath = "" -- 1971
		end -- 1961
	end -- 1953
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1972
	local yueext = yue.options.extension -- 1973
	local resultCodes = nil -- 1974
	local resultError = nil -- 1975
	do -- 1976
		local _exp_0 = Path:getExt(inputFile) -- 1976
		if yueext == _exp_0 then -- 1976
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1977
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1978
				if not codes then -- 1979
					resultError = err -- 1980
					return -- 1981
				end -- 1979
				local extraGlobal -- 1982
				if isTIC80 then -- 1982
					extraGlobal = tic80APIs -- 1982
				else -- 1982
					extraGlobal = nil -- 1982
				end -- 1982
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1983
				if not success then -- 1984
					resultError = message -- 1985
					return -- 1986
				end -- 1984
				if codes == "" then -- 1987
					resultCodes = "" -- 1988
					return nil -- 1989
				end -- 1987
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 1990
				return resultCodes -- 1991
			end, function(success) -- 1978
				if not success then -- 1992
					Content:remove(outputFile) -- 1993
					if resultCodes == nil then -- 1994
						resultCodes = false -- 1995
					end -- 1994
				end -- 1992
			end) -- 1978
		elseif "tl" == _exp_0 then -- 1996
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1997
			if isTIC80 then -- 1998
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1999
			end -- 1998
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2000
			if codes then -- 2000
				if isTIC80 then -- 2001
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2002
				end -- 2001
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2003
				Content:saveAsync(outputFile, resultCodes) -- 2004
			else -- 2006
				Content:remove(outputFile) -- 2006
				resultCodes = false -- 2007
				resultError = err -- 2008
			end -- 2000
		elseif "xml" == _exp_0 then -- 2009
			local codes, err = xml.tolua(sourceCodes) -- 2010
			if codes then -- 2010
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2011
				Content:saveAsync(outputFile, resultCodes) -- 2012
			else -- 2014
				Content:remove(outputFile) -- 2014
				resultCodes = false -- 2015
				resultError = err -- 2016
			end -- 2010
		end -- 1976
	end -- 1976
	wait(function() -- 2017
		return resultCodes ~= nil -- 2017
	end) -- 2017
	if resultCodes then -- 2018
		return resultCodes -- 2019
	else -- 2021
		return nil, resultError -- 2021
	end -- 2018
	return nil -- 1951
end -- 1951
HttpServer:postSchedule("/write", function(req) -- 2023
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2024
	local buildSucceeded = false -- 2025
	local _ <close> = setmetatable({ }, { -- 2026
		__close = function() -- 2026
			return finishUpdate(buildSucceeded) -- 2026
		end -- 2026
	}) -- 2026
	do -- 2027
		local _type_0 = type(req) -- 2027
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2027
		if _tab_0 then -- 2027
			local path -- 2027
			do -- 2027
				local _obj_0 = req.body -- 2027
				local _type_1 = type(_obj_0) -- 2027
				if "table" == _type_1 or "userdata" == _type_1 then -- 2027
					path = _obj_0.path -- 2027
				end -- 2027
			end -- 2027
			local content -- 2027
			do -- 2027
				local _obj_0 = req.body -- 2027
				local _type_1 = type(_obj_0) -- 2027
				if "table" == _type_1 or "userdata" == _type_1 then -- 2027
					content = _obj_0.content -- 2027
				end -- 2027
			end -- 2027
			if path ~= nil and content ~= nil then -- 2027
				if Content:saveAsync(path, content) then -- 2028
					do -- 2029
						local _exp_0 = Path:getExt(path) -- 2029
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2029
							if '' == Path:getExt(Path:getName(path)) then -- 2030
								local resultCodes = compileFileAsync(path, content) -- 2031
								buildSucceeded = resultCodes ~= nil -- 2032
								return { -- 2033
									success = true, -- 2033
									resultCodes = resultCodes -- 2033
								} -- 2033
							end -- 2030
						end -- 2029
					end -- 2029
					buildSucceeded = true -- 2034
					return { -- 2035
						success = true -- 2035
					} -- 2035
				end -- 2028
			end -- 2027
		end -- 2027
	end -- 2027
	return { -- 2023
		success = false -- 2023
	} -- 2023
end) -- 2023
local getWaProjectDirFromFile = nil -- 2037
HttpServer:postSchedule("/build", function(req) -- 2039
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2040
	local buildSucceeded = false -- 2041
	local _ <close> = setmetatable({ }, { -- 2042
		__close = function() -- 2042
			return finishUpdate(buildSucceeded) -- 2042
		end -- 2042
	}) -- 2042
	do -- 2043
		local _type_0 = type(req) -- 2043
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2043
		if _tab_0 then -- 2043
			local path -- 2043
			do -- 2043
				local _obj_0 = req.body -- 2043
				local _type_1 = type(_obj_0) -- 2043
				if "table" == _type_1 or "userdata" == _type_1 then -- 2043
					path = _obj_0.path -- 2043
				end -- 2043
			end -- 2043
			if path ~= nil then -- 2043
				local projectRoot = req.body.projectRoot -- 2044
				if Content:isdir(path) then -- 2045
					local projDir = getWaProjectDirFromFile(path) -- 2046
					if projDir then -- 2046
						local message = Wasm:buildWaAsync(projDir) -- 2047
						if message == "" then -- 2048
							return { -- 2049
								success = true -- 2049
							} -- 2049
						else -- 2051
							return { -- 2051
								success = false, -- 2051
								message = message -- 2051
							} -- 2051
						end -- 2048
					end -- 2046
				end -- 2045
				local _exp_0 = Path:getExt(path) -- 2052
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2053
					if '' == Path:getExt(Path:getName(path)) then -- 2054
						local content = Content:loadAsync(path) -- 2055
						if content then -- 2055
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2056
							if resultCodes then -- 2056
								buildSucceeded = true -- 2057
								return { -- 2058
									success = true, -- 2058
									resultCodes = resultCodes -- 2058
								} -- 2058
							end -- 2056
						end -- 2055
					end -- 2054
				elseif "wa" == _exp_0 then -- 2059
					local projDir = getWaProjectDirFromFile(path) -- 2060
					if projDir then -- 2060
						local message = Wasm:buildWaAsync(projDir) -- 2061
						if message == "" then -- 2062
							return { -- 2063
								success = true -- 2063
							} -- 2063
						else -- 2065
							return { -- 2065
								success = false, -- 2065
								message = message -- 2065
							} -- 2065
						end -- 2062
					else -- 2067
						return { -- 2067
							success = false, -- 2067
							message = 'Wa file needs a project' -- 2067
						} -- 2067
					end -- 2060
				end -- 2052
			end -- 2043
		end -- 2043
	end -- 2043
	return { -- 2039
		success = false -- 2039
	} -- 2039
end) -- 2039
local extentionLevels = { -- 2070
	vs = 2, -- 2070
	bl = 2, -- 2071
	ts = 1, -- 2072
	tsx = 1, -- 2073
	tl = 1, -- 2074
	yue = 1, -- 2075
	xml = 1, -- 2076
	lua = 0 -- 2077
} -- 2069
local visitAssets -- 2079
visitAssets = function(path, workspace, builtin, recursive) -- 2079
	if recursive == nil then -- 2079
		recursive = true -- 2079
	end -- 2079
	local children = nil -- 2080
	local dirs = Content:getDirs(path) -- 2081
	for _index_0 = 1, #dirs do -- 2082
		local dir = dirs[_index_0] -- 2082
		if workspace then -- 2083
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 2084
				goto _continue_0 -- 2085
			end -- 2084
		elseif dir == ".git" then -- 2086
			goto _continue_0 -- 2087
		end -- 2083
		if not children then -- 2088
			children = { } -- 2088
		end -- 2088
		local dirPath = Path(path, dir) -- 2089
		if recursive then -- 2090
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2091
		else -- 2093
			children[#children + 1] = { -- 2094
				key = dirPath, -- 2094
				dir = true, -- 2095
				title = dir, -- 2096
				builtin = builtin, -- 2097
				isLeaf = false -- 2098
			} -- 2093
		end -- 2090
		::_continue_0:: -- 2083
	end -- 2082
	local files = Content:getFiles(path) -- 2100
	local names = { } -- 2101
	for _index_0 = 1, #files do -- 2102
		local file = files[_index_0] -- 2102
		if (".DS_Store" == file) then -- 2103
			goto _continue_1 -- 2104
		end -- 2103
		local name = Path:getName(file) -- 2105
		local ext = names[name] -- 2106
		if ext then -- 2106
			local lv1 -- 2107
			do -- 2107
				local _exp_0 = extentionLevels[ext] -- 2107
				if _exp_0 ~= nil then -- 2107
					lv1 = _exp_0 -- 2107
				else -- 2107
					lv1 = -1 -- 2107
				end -- 2107
			end -- 2107
			ext = Path:getExt(file) -- 2108
			local lv2 -- 2109
			do -- 2109
				local _exp_0 = extentionLevels[ext] -- 2109
				if _exp_0 ~= nil then -- 2109
					lv2 = _exp_0 -- 2109
				else -- 2109
					lv2 = -1 -- 2109
				end -- 2109
			end -- 2109
			if lv2 > lv1 then -- 2110
				names[name] = ext -- 2111
			elseif lv2 == lv1 then -- 2112
				names[name .. '.' .. ext] = "" -- 2113
			end -- 2110
		else -- 2115
			ext = Path:getExt(file) -- 2115
			if not extentionLevels[ext] then -- 2116
				names[file] = "" -- 2117
			else -- 2119
				names[name] = ext -- 2119
			end -- 2116
		end -- 2106
		::_continue_1:: -- 2103
	end -- 2102
	do -- 2120
		local _accum_0 = { } -- 2120
		local _len_0 = 1 -- 2120
		for name, ext in pairs(names) do -- 2120
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2120
			_len_0 = _len_0 + 1 -- 2120
		end -- 2120
		files = _accum_0 -- 2120
	end -- 2120
	for _index_0 = 1, #files do -- 2121
		local file = files[_index_0] -- 2121
		if not children then -- 2122
			children = { } -- 2122
		end -- 2122
		children[#children + 1] = { -- 2124
			key = Path(path, file), -- 2124
			dir = false, -- 2125
			title = file, -- 2126
			builtin = builtin -- 2127
		} -- 2123
	end -- 2121
	if children then -- 2129
		table.sort(children, function(a, b) -- 2130
			if a.dir == b.dir then -- 2131
				return a.title < b.title -- 2132
			else -- 2134
				return a.dir -- 2134
			end -- 2131
		end) -- 2130
	end -- 2129
	return { -- 2136
		key = path, -- 2136
		dir = true, -- 2137
		title = Path:getFilename(path), -- 2138
		builtin = builtin, -- 2139
		isLeaf = not children, -- 2140
		children = children -- 2141
	} -- 2135
end -- 2079
HttpServer:post("/assets/children", function(req) -- 2144
	do -- 2145
		local _type_0 = type(req) -- 2145
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2145
		if _tab_0 then -- 2145
			local path -- 2145
			do -- 2145
				local _obj_0 = req.body -- 2145
				local _type_1 = type(_obj_0) -- 2145
				if "table" == _type_1 or "userdata" == _type_1 then -- 2145
					path = _obj_0.path -- 2145
				end -- 2145
			end -- 2145
			if path ~= nil then -- 2145
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2146
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2147
					return { -- 2147
						success = false -- 2147
					} -- 2147
				end -- 2147
				local node = visitAssets(path, workspace, builtin, false) -- 2148
				return { -- 2149
					success = true, -- 2149
					children = node.children or { } -- 2149
				} -- 2149
			end -- 2145
		end -- 2145
	end -- 2145
	return { -- 2144
		success = false -- 2144
	} -- 2144
end) -- 2144
HttpServer:post("/assets/files", function(req) -- 2151
	do -- 2152
		local _type_0 = type(req) -- 2152
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2152
		if _tab_0 then -- 2152
			local path -- 2152
			do -- 2152
				local _obj_0 = req.body -- 2152
				local _type_1 = type(_obj_0) -- 2152
				if "table" == _type_1 or "userdata" == _type_1 then -- 2152
					path = _obj_0.path -- 2152
				end -- 2152
			end -- 2152
			if path ~= nil then -- 2152
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2153
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2154
				if not (workspace or builtin) then -- 2155
					return { -- 2155
						success = false -- 2155
					} -- 2155
				end -- 2155
				if not (Content:exist(path) and Content:isdir(path)) then -- 2156
					return { -- 2156
						success = false -- 2156
					} -- 2156
				end -- 2156
				local globs = { -- 2157
					"**", -- 2157
					"!**/.DS_Store" -- 2157
				} -- 2157
				if workspace then -- 2158
					globs = { -- 2160
						"**", -- 2160
						"!**/.DS_Store", -- 2160
						"!**/.upload/**", -- 2161
						"!**/.download/**", -- 2161
						"!**/.www/**", -- 2162
						"!**/.build/**", -- 2162
						"!**/.git/**", -- 2163
						"!**/.cache/**", -- 2163
						"!**/node_modules/**" -- 2164
					} -- 2159
				end -- 2158
				local files -- 2166
				do -- 2166
					local _accum_0 = { } -- 2166
					local _len_0 = 1 -- 2166
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2166
					for _index_0 = 1, #_list_0 do -- 2166
						local file = _list_0[_index_0] -- 2166
						_accum_0[_len_0] = Path(path, file) -- 2166
						_len_0 = _len_0 + 1 -- 2166
					end -- 2166
					files = _accum_0 -- 2166
				end -- 2166
				return { -- 2167
					success = true, -- 2167
					files = files -- 2167
				} -- 2167
			end -- 2152
		end -- 2152
	end -- 2152
	return { -- 2151
		success = false -- 2151
	} -- 2151
end) -- 2151
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2208
	local _tab_0 = { -- 2208
		{ -- 2209
			key = Path(Content.assetPath), -- 2209
			dir = true, -- 2210
			builtin = true, -- 2211
			title = zh and "内置资源" or "Built-in", -- 2212
			children = builtinChildren -- 2213
		} -- 2208
	} -- 2215
	local _obj_0 = workspace.children or { } -- 2215
	local _idx_0 = #_tab_0 + 1 -- 2215
	for _index_0 = 1, #_obj_0 do -- 2215
		local _value_0 = _obj_0[_index_0] -- 2215
		_tab_0[_idx_0] = _value_0 -- 2215
		_idx_0 = _idx_0 + 1 -- 2215
	end -- 2215
	return _tab_0 -- 2208
end -- 2208
HttpServer:post("/assets", function() -- 2169
	local Entry = require("Script.Dev.Entry") -- 2170
	local engineDev = Entry.getEngineDev() -- 2171
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2172
	local zh = (App.locale:match("^zh") ~= nil) -- 2173
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2174
	readme.title = zh and "说明文档" or "Readme" -- 2175
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2176
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2177
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2178
	tools.title = zh and "开发工具" or "Tools" -- 2179
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2180
	font.title = zh and "字体" or "Font" -- 2181
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2182
	lib.title = zh and "程序库" or "Lib" -- 2183
	if engineDev then -- 2184
		local _list_0 = lib.children -- 2185
		for _index_0 = 1, #_list_0 do -- 2185
			local child = _list_0[_index_0] -- 2185
			if not (child.title == "Dora") then -- 2186
				goto _continue_0 -- 2186
			end -- 2186
			local title = zh and "zh-Hans" or "en" -- 2187
			do -- 2188
				local _accum_0 = { } -- 2188
				local _len_0 = 1 -- 2188
				local _list_1 = child.children -- 2188
				for _index_1 = 1, #_list_1 do -- 2188
					local c = _list_1[_index_1] -- 2188
					if c.title ~= title then -- 2188
						_accum_0[_len_0] = c -- 2188
						_len_0 = _len_0 + 1 -- 2188
					end -- 2188
				end -- 2188
				child.children = _accum_0 -- 2188
			end -- 2188
			break -- 2189
			::_continue_0:: -- 2186
		end -- 2185
	else -- 2191
		local _accum_0 = { } -- 2191
		local _len_0 = 1 -- 2191
		local _list_0 = lib.children -- 2191
		for _index_0 = 1, #_list_0 do -- 2191
			local child = _list_0[_index_0] -- 2191
			if child.title ~= "Dora" then -- 2191
				_accum_0[_len_0] = child -- 2191
				_len_0 = _len_0 + 1 -- 2191
			end -- 2191
		end -- 2191
		lib.children = _accum_0 -- 2191
	end -- 2184
	local builtinChildren = { -- 2192
		readme, -- 2192
		apiDoc, -- 2192
		tools, -- 2192
		font, -- 2192
		lib -- 2192
	} -- 2192
	if engineDev then -- 2193
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2194
		do -- 2195
			local _obj_0 = dev.children -- 2195
			_obj_0[#_obj_0 + 1] = { -- 2196
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2196
				dir = false, -- 2197
				builtin = true, -- 2198
				title = "init.yue" -- 2199
			} -- 2195
		end -- 2195
		builtinChildren[#builtinChildren + 1] = dev -- 2201
	end -- 2193
	return { -- 2203
		key = Content.writablePath, -- 2203
		dir = true, -- 2204
		root = true, -- 2205
		title = "Assets", -- 2206
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2207
	} -- 2202
end) -- 2169
HttpServer:post("/entry/list", function(req) -- 2219
	local Entry = require("Script.Dev.Entry") -- 2220
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2221
	res.success = true -- 2222
	return res -- 2223
end) -- 2219
HttpServer:post("/run/status", function() -- 2225
	local Entry = require("Script.Dev.Entry") -- 2226
	return Entry.getCurrentEntryStatus() -- 2227
end) -- 2225
HttpServer:postSchedule("/run", function(req) -- 2229
	do -- 2230
		local _type_0 = type(req) -- 2230
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2230
		if _tab_0 then -- 2230
			local file -- 2230
			do -- 2230
				local _obj_0 = req.body -- 2230
				local _type_1 = type(_obj_0) -- 2230
				if "table" == _type_1 or "userdata" == _type_1 then -- 2230
					file = _obj_0.file -- 2230
				end -- 2230
			end -- 2230
			local asProj -- 2230
			do -- 2230
				local _obj_0 = req.body -- 2230
				local _type_1 = type(_obj_0) -- 2230
				if "table" == _type_1 or "userdata" == _type_1 then -- 2230
					asProj = _obj_0.asProj -- 2230
				end -- 2230
			end -- 2230
			if file ~= nil and asProj ~= nil then -- 2230
				if not Content:isAbsolutePath(file) then -- 2231
					local devFile = Path(Content.writablePath, file) -- 2232
					if Content:exist(devFile) then -- 2233
						file = devFile -- 2233
					end -- 2233
				end -- 2231
				local Entry = require("Script.Dev.Entry") -- 2234
				local workDir -- 2235
				if asProj then -- 2236
					local projectRoot = req.body.projectRoot -- 2237
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2238
						workDir = projectRoot -- 2239
					else -- 2241
						workDir = getProjectDirFromFile(file) -- 2241
					end -- 2238
					if workDir then -- 2242
						Entry.allClear() -- 2243
						local target = Path(workDir, "init") -- 2244
						local success, err = Entry.enterEntryAsync({ -- 2245
							entryName = "Project", -- 2245
							fileName = target, -- 2245
							workDir = workDir, -- 2245
							projectRoot = workDir, -- 2245
							runKind = "project" -- 2245
						}) -- 2245
						target = Path:getName(Path:getPath(target)) -- 2246
						return { -- 2247
							success = success, -- 2247
							target = target, -- 2247
							err = err -- 2247
						} -- 2247
					end -- 2242
				else -- 2249
					workDir = getProjectDirFromFile(file) -- 2249
					if not workDir and Path:getExt(file) == "wasm" then -- 2250
						local parent = Path:getPath(file) -- 2251
						if Content:exist(Path(parent, "wa.mod")) then -- 2252
							workDir = parent -- 2253
						end -- 2252
					end -- 2250
				end -- 2236
				Entry.allClear() -- 2254
				file = Path:replaceExt(file, "") -- 2255
				local entry = { -- 2257
					entryName = Path:getName(file), -- 2257
					fileName = file, -- 2258
					runKind = "file" -- 2259
				} -- 2256
				if workDir then -- 2260
					entry.workDir = workDir -- 2261
					entry.projectRoot = workDir -- 2262
				end -- 2260
				local success, err = Entry.enterEntryAsync(entry) -- 2263
				return { -- 2264
					success = success, -- 2264
					err = err -- 2264
				} -- 2264
			end -- 2230
		end -- 2230
	end -- 2230
	return { -- 2229
		success = false -- 2229
	} -- 2229
end) -- 2229
local _anon_func_7 = function(result) -- 2306
	if result.success then -- 2306
		return nil -- 2306
	else -- 2306
		return "PREVIEW_FAILED" -- 2306
	end -- 2306
end -- 2306
HttpServer:postSchedule("/agent/preview", function(req) -- 2266
	local releaseAgent = AgentHost.acquire() -- 2267
	local _ <close> = setmetatable({ }, { -- 2268
		__close = function() -- 2268
			return releaseAgent() -- 2268
		end -- 2268
	}) -- 2268
	do -- 2269
		local _type_0 = type(req) -- 2269
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2269
		if _tab_0 then -- 2269
			local projectRoot -- 2269
			do -- 2269
				local _obj_0 = req.body -- 2269
				local _type_1 = type(_obj_0) -- 2269
				if "table" == _type_1 or "userdata" == _type_1 then -- 2269
					projectRoot = _obj_0.projectRoot -- 2269
				end -- 2269
			end -- 2269
			if projectRoot ~= nil then -- 2269
				if not getProjectSourceRoot(projectRoot) then -- 2270
					return { -- 2270
						success = false, -- 2270
						code = "INVALID_PROJECT", -- 2270
						message = "projectRoot must be an existing absolute directory" -- 2270
					} -- 2270
				end -- 2270
				local entryFile = req.body.entry or "init.lua" -- 2271
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2272
					return { -- 2272
						success = false, -- 2272
						code = "INVALID_ENTRY", -- 2272
						message = "entry must be a non-empty project-relative path" -- 2272
					} -- 2272
				end -- 2272
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2273
					0.5 -- 2273
				} -- 2273
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2274
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2275
					return { -- 2275
						success = false, -- 2275
						code = "INVALID_QUEUE_TIMEOUT", -- 2275
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2275
					} -- 2275
				end -- 2275
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2276
				local AgentOperation = require("Agent.Tool.Operation") -- 2277
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2278
				local requestId = AgentOperation.createOperationId() -- 2279
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2280
				if not enqueued.success then -- 2281
					return { -- 2281
						success = false, -- 2281
						code = "ENTRY_QUEUE_REJECTED", -- 2281
						message = enqueued.message -- 2281
					} -- 2281
				end -- 2281
				local queuedAt = App.runningTime -- 2282
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2283
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2284
						local state = agentEntryRunQueue:get(requestId) -- 2285
						agentEntryRunQueue:cancel(requestId) -- 2286
						return { -- 2288
							success = false, -- 2288
							code = "ENTRY_QUEUE_TIMEOUT", -- 2289
							message = "timed out waiting for the Dora entry runtime", -- 2290
							requestId = requestId, -- 2291
							queuePosition = state.position -- 2292
						} -- 2287
					end -- 2284
					sleep() -- 2293
				end -- 2283
				local queueWaitSeconds = App.runningTime - queuedAt -- 2294
				local _ <close> = setmetatable({ }, { -- 2295
					__close = function() -- 2295
						return agentEntryRunQueue:release(requestId) -- 2295
					end -- 2295
				}) -- 2295
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2296
				local Entry = require("Script.Dev.Entry") -- 2297
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2299
					workDir = projectRoot, -- 2299
					operationId = requestId, -- 2300
					print = function() end -- 2301
				}, Entry) -- 2298
				local result = preview({ -- 2303
					entry = entryFile, -- 2303
					captureAtSeconds = captureAtSeconds -- 2303
				}) -- 2303
				return { -- 2305
					success = result.success, -- 2305
					code = _anon_func_7(result), -- 2306
					message = result.message, -- 2307
					requestId = requestId, -- 2308
					queueWaitSeconds = queueWaitSeconds, -- 2309
					interruptedUserRun = result.interruptedUserRun, -- 2310
					files = result.files, -- 2311
					frames = result.frames -- 2312
				} -- 2304
			end -- 2269
		end -- 2269
	end -- 2269
	return { -- 2266
		success = false, -- 2266
		message = "invalid call" -- 2266
	} -- 2266
end) -- 2266
HttpServer:postSchedule("/agent/command", function(req) -- 2314
	local releaseAgent = AgentHost.acquire() -- 2315
	local _ <close> = setmetatable({ }, { -- 2316
		__close = function() -- 2316
			return releaseAgent() -- 2316
		end -- 2316
	}) -- 2316
	do -- 2317
		local _type_0 = type(req) -- 2317
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2317
		if _tab_0 then -- 2317
			local body = req.body -- 2317
			if body ~= nil then -- 2317
				local projectRoot = body.projectRoot -- 2318
				if not getProjectSourceRoot(projectRoot) then -- 2319
					return { -- 2319
						success = false, -- 2319
						code = "INVALID_PROJECT", -- 2319
						message = "projectRoot must be an existing absolute directory" -- 2319
					} -- 2319
				end -- 2319
				local AgentValidation = require("Agent.Tool.Validation") -- 2320
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2321
				if not validated.success then -- 2322
					return { -- 2322
						success = false, -- 2322
						code = "INVALID_COMMAND", -- 2322
						message = validated.message -- 2322
					} -- 2322
				end -- 2322
				local input = validated.value -- 2323
				local AgentCommand = require("Agent.Tool.Command") -- 2324
				local result = nil -- 2325
				local failure = nil -- 2326
				local promise = AgentCommand.executeCommand({ -- 2328
					workDir = projectRoot, -- 2328
					mode = input.mode, -- 2329
					code = input.code, -- 2330
					command = input.command, -- 2331
					cwd = input.cwd, -- 2332
					timeoutSeconds = input.timeoutSeconds -- 2333
				}) -- 2327
				promise:addCallbacks((function(_, value) -- 2334
					result = value -- 2334
				end), (function(_, err) -- 2334
					failure = tostring(err) -- 2334
				end)) -- 2334
				wait(function() -- 2335
					return result ~= nil or failure ~= nil -- 2335
				end) -- 2335
				if failure then -- 2336
					return { -- 2336
						success = false, -- 2336
						code = "COMMAND_BRIDGE_FAILED", -- 2336
						message = failure -- 2336
					} -- 2336
				end -- 2336
				if not result.success then -- 2337
					result.code = "COMMAND_FAILED" -- 2338
				end -- 2337
				return result -- 2339
			end -- 2317
		end -- 2317
	end -- 2317
	return { -- 2314
		success = false, -- 2314
		code = "INVALID_COMMAND", -- 2314
		message = "invalid call" -- 2314
	} -- 2314
end) -- 2314
HttpServer:postSchedule("/stop", function() -- 2341
	local Entry = require("Script.Dev.Entry") -- 2342
	return { -- 2343
		success = Entry.stop() -- 2343
	} -- 2343
end) -- 2341
local minifyAsync -- 2345
minifyAsync = function(sourcePath, minifyPath) -- 2345
	if not Content:exist(sourcePath) then -- 2346
		return -- 2346
	end -- 2346
	local Entry = require("Script.Dev.Entry") -- 2347
	local errors = { } -- 2348
	local files = Entry.getAllFiles(sourcePath, { -- 2349
		"lua" -- 2349
	}, true) -- 2349
	do -- 2350
		local _accum_0 = { } -- 2350
		local _len_0 = 1 -- 2350
		for _index_0 = 1, #files do -- 2350
			local file = files[_index_0] -- 2350
			if file:sub(1, 1) ~= '.' then -- 2350
				_accum_0[_len_0] = file -- 2350
				_len_0 = _len_0 + 1 -- 2350
			end -- 2350
		end -- 2350
		files = _accum_0 -- 2350
	end -- 2350
	local paths -- 2351
	do -- 2351
		local _tbl_0 = { } -- 2351
		for _index_0 = 1, #files do -- 2351
			local file = files[_index_0] -- 2351
			_tbl_0[Path:getPath(file)] = true -- 2351
		end -- 2351
		paths = _tbl_0 -- 2351
	end -- 2351
	for path in pairs(paths) do -- 2352
		Content:mkdir(Path(minifyPath, path)) -- 2352
	end -- 2352
	local _ <close> = setmetatable({ }, { -- 2353
		__close = function() -- 2353
			package.loaded["luaminify.FormatMini"] = nil -- 2354
			package.loaded["luaminify.ParseLua"] = nil -- 2355
			package.loaded["luaminify.Scope"] = nil -- 2356
			package.loaded["luaminify.Util"] = nil -- 2357
		end -- 2353
	}) -- 2353
	local FormatMini -- 2358
	do -- 2358
		local _obj_0 = require("luaminify") -- 2358
		FormatMini = _obj_0.FormatMini -- 2358
	end -- 2358
	local fileCount = #files -- 2359
	local count = 0 -- 2360
	for _index_0 = 1, #files do -- 2361
		local file = files[_index_0] -- 2361
		thread(function() -- 2362
			local _ <close> = setmetatable({ }, { -- 2363
				__close = function() -- 2363
					count = count + 1 -- 2363
				end -- 2363
			}) -- 2363
			local input = Path(sourcePath, file) -- 2364
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2365
			if Content:exist(input) then -- 2366
				local sourceCodes = Content:loadAsync(input) -- 2367
				local res, err = FormatMini(sourceCodes) -- 2368
				if res then -- 2369
					Content:saveAsync(output, res) -- 2370
					return print("Minify " .. tostring(file)) -- 2371
				else -- 2373
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2373
				end -- 2369
			else -- 2375
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2375
			end -- 2366
		end) -- 2362
		sleep() -- 2376
	end -- 2361
	wait(function() -- 2377
		return count == fileCount -- 2377
	end) -- 2377
	if #errors > 0 then -- 2378
		print(table.concat(errors, '\n')) -- 2379
	end -- 2378
	print("Obfuscation done.") -- 2380
	return files -- 2381
end -- 2345
local zipping = false -- 2383
HttpServer:postSchedule("/zip", function(req) -- 2385
	do -- 2386
		local _type_0 = type(req) -- 2386
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2386
		if _tab_0 then -- 2386
			local path -- 2386
			do -- 2386
				local _obj_0 = req.body -- 2386
				local _type_1 = type(_obj_0) -- 2386
				if "table" == _type_1 or "userdata" == _type_1 then -- 2386
					path = _obj_0.path -- 2386
				end -- 2386
			end -- 2386
			local zipFile -- 2386
			do -- 2386
				local _obj_0 = req.body -- 2386
				local _type_1 = type(_obj_0) -- 2386
				if "table" == _type_1 or "userdata" == _type_1 then -- 2386
					zipFile = _obj_0.zipFile -- 2386
				end -- 2386
			end -- 2386
			local obfuscated -- 2386
			do -- 2386
				local _obj_0 = req.body -- 2386
				local _type_1 = type(_obj_0) -- 2386
				if "table" == _type_1 or "userdata" == _type_1 then -- 2386
					obfuscated = _obj_0.obfuscated -- 2386
				end -- 2386
			end -- 2386
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2386
				if zipping then -- 2387
					goto failed -- 2387
				end -- 2387
				zipping = true -- 2388
				local _ <close> = setmetatable({ }, { -- 2389
					__close = function() -- 2389
						zipping = false -- 2389
					end -- 2389
				}) -- 2389
				if not Content:exist(path) then -- 2390
					goto failed -- 2390
				end -- 2390
				Content:mkdir(Path:getPath(zipFile)) -- 2391
				if obfuscated then -- 2392
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2393
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2394
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2395
					Content:remove(scriptPath) -- 2396
					Content:remove(obfuscatedPath) -- 2397
					Content:remove(tempPath) -- 2398
					Content:mkdir(scriptPath) -- 2399
					Content:mkdir(obfuscatedPath) -- 2400
					Content:mkdir(tempPath) -- 2401
					if not Content:copyAsync(path, tempPath) then -- 2402
						goto failed -- 2402
					end -- 2402
					local Entry = require("Script.Dev.Entry") -- 2403
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2404
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2405
						"tl", -- 2405
						"yue", -- 2405
						"lua", -- 2405
						"ts", -- 2405
						"tsx", -- 2405
						"vs", -- 2405
						"bl", -- 2405
						"xml", -- 2405
						"wa", -- 2405
						"mod" -- 2405
					}, true) -- 2405
					for _index_0 = 1, #scriptFiles do -- 2406
						local file = scriptFiles[_index_0] -- 2406
						Content:remove(Path(tempPath, file)) -- 2407
					end -- 2406
					for _index_0 = 1, #luaFiles do -- 2408
						local file = luaFiles[_index_0] -- 2408
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2409
					end -- 2408
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2410
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2411
					end) then -- 2410
						goto failed -- 2410
					end -- 2410
					return { -- 2412
						success = true -- 2412
					} -- 2412
				else -- 2414
					return { -- 2414
						success = Content:zipAsync(path, zipFile, function(file) -- 2414
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2415
						end) -- 2414
					} -- 2414
				end -- 2392
			end -- 2386
		end -- 2386
	end -- 2386
	::failed:: -- 2416
	return { -- 2385
		success = false -- 2385
	} -- 2385
end) -- 2385
HttpServer:postSchedule("/unzip", function(req) -- 2418
	do -- 2419
		local _type_0 = type(req) -- 2419
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2419
		if _tab_0 then -- 2419
			local zipFile -- 2419
			do -- 2419
				local _obj_0 = req.body -- 2419
				local _type_1 = type(_obj_0) -- 2419
				if "table" == _type_1 or "userdata" == _type_1 then -- 2419
					zipFile = _obj_0.zipFile -- 2419
				end -- 2419
			end -- 2419
			local path -- 2419
			do -- 2419
				local _obj_0 = req.body -- 2419
				local _type_1 = type(_obj_0) -- 2419
				if "table" == _type_1 or "userdata" == _type_1 then -- 2419
					path = _obj_0.path -- 2419
				end -- 2419
			end -- 2419
			if zipFile ~= nil and path ~= nil then -- 2419
				return { -- 2420
					success = Content:unzipAsync(zipFile, path, function(file) -- 2420
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2421
					end) -- 2420
				} -- 2420
			end -- 2419
		end -- 2419
	end -- 2419
	return { -- 2418
		success = false -- 2418
	} -- 2418
end) -- 2418
HttpServer:post("/editing-info", function(req) -- 2423
	local Entry = require("Script.Dev.Entry") -- 2424
	local config = Entry.getConfig() -- 2425
	local _type_0 = type(req) -- 2426
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2426
	local _match_0 = false -- 2426
	if _tab_0 then -- 2426
		local editingInfo -- 2426
		do -- 2426
			local _obj_0 = req.body -- 2426
			local _type_1 = type(_obj_0) -- 2426
			if "table" == _type_1 or "userdata" == _type_1 then -- 2426
				editingInfo = _obj_0.editingInfo -- 2426
			end -- 2426
		end -- 2426
		if editingInfo ~= nil then -- 2426
			_match_0 = true -- 2426
			config.editingInfo = editingInfo -- 2427
			return { -- 2428
				success = true -- 2428
			} -- 2428
		end -- 2426
	end -- 2426
	if not _match_0 then -- 2426
		if not (config.editingInfo ~= nil) then -- 2430
			local folder -- 2431
			if App.locale:match('^zh') then -- 2431
				folder = 'zh-Hans' -- 2431
			else -- 2431
				folder = 'en' -- 2431
			end -- 2431
			config.editingInfo = json.encode({ -- 2433
				index = 0, -- 2433
				files = { -- 2435
					{ -- 2436
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2436
						title = "welcome.md" -- 2437
					} -- 2435
				} -- 2434
			}) -- 2432
		end -- 2430
		return { -- 2441
			success = true, -- 2441
			editingInfo = config.editingInfo -- 2441
		} -- 2441
	end -- 2426
end) -- 2423
HttpServer:post("/command", function(req) -- 2443
	do -- 2444
		local _type_0 = type(req) -- 2444
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2444
		if _tab_0 then -- 2444
			local code -- 2444
			do -- 2444
				local _obj_0 = req.body -- 2444
				local _type_1 = type(_obj_0) -- 2444
				if "table" == _type_1 or "userdata" == _type_1 then -- 2444
					code = _obj_0.code -- 2444
				end -- 2444
			end -- 2444
			local log -- 2444
			do -- 2444
				local _obj_0 = req.body -- 2444
				local _type_1 = type(_obj_0) -- 2444
				if "table" == _type_1 or "userdata" == _type_1 then -- 2444
					log = _obj_0.log -- 2444
				end -- 2444
			end -- 2444
			if code ~= nil and log ~= nil then -- 2444
				emit("AppCommand", code, log) -- 2445
				return { -- 2446
					success = true -- 2446
				} -- 2446
			end -- 2444
		end -- 2444
	end -- 2444
	return { -- 2443
		success = false -- 2443
	} -- 2443
end) -- 2443
HttpServer:post("/log/save", function() -- 2448
	local folder = ".download" -- 2449
	local fullLogFile = "dora_full_logs.txt" -- 2450
	local fullFolder = Path(Content.writablePath, folder) -- 2451
	Content:mkdir(fullFolder) -- 2452
	local logPath = Path(fullFolder, fullLogFile) -- 2453
	if App:saveLog(logPath) then -- 2454
		return { -- 2455
			success = true, -- 2455
			path = Path(folder, fullLogFile) -- 2455
		} -- 2455
	end -- 2454
	return { -- 2448
		success = false -- 2448
	} -- 2448
end) -- 2448
local tailLines -- 2457
tailLines = function(text, count) -- 2457
	local lines = { } -- 2458
	text = text:gsub("\r\n", "\n") -- 2459
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2460
		lines[#lines + 1] = line -- 2461
	end -- 2460
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2462
		table.remove(lines) -- 2463
	end -- 2462
	local start = math.max(1, #lines - count + 1) -- 2464
	local out = { } -- 2465
	for i = start, #lines do -- 2466
		out[#out + 1] = lines[i] -- 2467
	end -- 2466
	return table.concat(out, "\n") -- 2468
end -- 2457
HttpServer:post("/log", function(req) -- 2470
	local count = 100 -- 2471
	if req and req.body and req.body.count ~= nil then -- 2472
		count = req.body.count -- 2473
	end -- 2472
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2474
		return { -- 2475
			success = false, -- 2475
			message = "count must be a positive integer" -- 2475
		} -- 2475
	end -- 2474
	local folder = ".download" -- 2476
	local fullLogFile = "dora_full_logs.txt" -- 2477
	local fullFolder = Path(Content.writablePath, folder) -- 2478
	Content:mkdir(fullFolder) -- 2479
	local logPath = Path(fullFolder, fullLogFile) -- 2480
	if App:saveLog(logPath) then -- 2481
		local text = Content:load(logPath) -- 2482
		if text then -- 2483
			return { -- 2484
				success = true, -- 2484
				log = tailLines(text, count) -- 2484
			} -- 2484
		else -- 2486
			return { -- 2486
				success = false, -- 2486
				message = "failed to read log" -- 2486
			} -- 2486
		end -- 2483
	else -- 2488
		return { -- 2488
			success = false, -- 2488
			message = "failed to save log" -- 2488
		} -- 2488
	end -- 2481
	return { -- 2470
		success = false -- 2470
	} -- 2470
end) -- 2470
HttpServer:post("/yarn/check", function(req) -- 2490
	local yarncompile = require("yarncompile") -- 2491
	do -- 2492
		local _type_0 = type(req) -- 2492
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2492
		if _tab_0 then -- 2492
			local code -- 2492
			do -- 2492
				local _obj_0 = req.body -- 2492
				local _type_1 = type(_obj_0) -- 2492
				if "table" == _type_1 or "userdata" == _type_1 then -- 2492
					code = _obj_0.code -- 2492
				end -- 2492
			end -- 2492
			if code ~= nil then -- 2492
				local jsonObject = json.decode(code) -- 2493
				if jsonObject then -- 2493
					local errors = { } -- 2494
					local _list_0 = jsonObject.nodes -- 2495
					for _index_0 = 1, #_list_0 do -- 2495
						local node = _list_0[_index_0] -- 2495
						local title, body = node.title, node.body -- 2496
						local luaCode, err = yarncompile(body) -- 2497
						if not luaCode then -- 2497
							errors[#errors + 1] = title .. ":" .. err -- 2498
						end -- 2497
					end -- 2495
					return { -- 2499
						success = true, -- 2499
						syntaxError = table.concat(errors, "\n\n") -- 2499
					} -- 2499
				end -- 2493
			end -- 2492
		end -- 2492
	end -- 2492
	return { -- 2490
		success = false -- 2490
	} -- 2490
end) -- 2490
HttpServer:post("/yarn/check-file", function(req) -- 2501
	local yarncompile = require("yarncompile") -- 2502
	do -- 2503
		local _type_0 = type(req) -- 2503
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2503
		if _tab_0 then -- 2503
			local code -- 2503
			do -- 2503
				local _obj_0 = req.body -- 2503
				local _type_1 = type(_obj_0) -- 2503
				if "table" == _type_1 or "userdata" == _type_1 then -- 2503
					code = _obj_0.code -- 2503
				end -- 2503
			end -- 2503
			if code ~= nil then -- 2503
				local res, _, err = yarncompile(code, true) -- 2504
				if not res then -- 2504
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2505
					return { -- 2506
						success = false, -- 2506
						message = message, -- 2506
						line = line, -- 2506
						column = column, -- 2506
						node = node -- 2506
					} -- 2506
				end -- 2504
			end -- 2503
		end -- 2503
	end -- 2503
	return { -- 2501
		success = true -- 2501
	} -- 2501
end) -- 2501
getWaProjectDirFromFile = function(file) -- 2508
	local current -- 2509
	if Content:isdir(file) then -- 2509
		current = file -- 2509
	else -- 2509
		current = Path:getPath(file) -- 2509
	end -- 2509
	if current == "" then -- 2510
		return nil -- 2510
	end -- 2510
	repeat -- 2511
		local modPath = Path(current, "wa.mod") -- 2512
		if Content:exist(modPath) then -- 2513
			return current, modPath -- 2514
		end -- 2513
		local parent = Path:getPath(current) -- 2515
		if parent == "" or parent == current then -- 2516
			break -- 2516
		end -- 2516
		current = parent -- 2517
	until false -- 2511
	return nil -- 2519
end -- 2508
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2521
	do -- 2522
		local _type_0 = type(req) -- 2522
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2522
		if _tab_0 then -- 2522
			local path -- 2522
			do -- 2522
				local _obj_0 = req.body -- 2522
				local _type_1 = type(_obj_0) -- 2522
				if "table" == _type_1 or "userdata" == _type_1 then -- 2522
					path = _obj_0.path -- 2522
				end -- 2522
			end -- 2522
			if path ~= nil then -- 2522
				local projDir = getWaProjectDirFromFile(path) -- 2523
				if projDir then -- 2523
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2524
					if not Content:exist(sourceDoraPath) then -- 2525
						return { -- 2526
							success = false, -- 2526
							message = "missing dora template" -- 2526
						} -- 2526
					end -- 2525
					local targetVendorPath = Path(projDir, "vendor") -- 2527
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2528
					if not Content:exist(targetVendorPath) then -- 2529
						if not Content:mkdir(targetVendorPath) then -- 2530
							return { -- 2531
								success = false, -- 2531
								message = "failed to create vendor folder" -- 2531
							} -- 2531
						end -- 2530
					elseif not Content:isdir(targetVendorPath) then -- 2532
						return { -- 2533
							success = false, -- 2533
							message = "vendor path is not a folder" -- 2533
						} -- 2533
					end -- 2529
					if Content:exist(targetDoraPath) then -- 2534
						if not Content:remove(targetDoraPath) then -- 2535
							return { -- 2536
								success = false, -- 2536
								message = "failed to remove old dora" -- 2536
							} -- 2536
						end -- 2535
					end -- 2534
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2537
						return { -- 2538
							success = false, -- 2538
							message = "failed to copy dora" -- 2538
						} -- 2538
					end -- 2537
					return { -- 2539
						success = true -- 2539
					} -- 2539
				else -- 2541
					return { -- 2541
						success = false, -- 2541
						message = 'Wa file needs a project' -- 2541
					} -- 2541
				end -- 2523
			end -- 2522
		end -- 2522
	end -- 2522
	return { -- 2521
		success = false, -- 2521
		message = "invalid call" -- 2521
	} -- 2521
end) -- 2521
HttpServer:postSchedule("/wa/build", function(req) -- 2543
	do -- 2544
		local _type_0 = type(req) -- 2544
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2544
		if _tab_0 then -- 2544
			local path -- 2544
			do -- 2544
				local _obj_0 = req.body -- 2544
				local _type_1 = type(_obj_0) -- 2544
				if "table" == _type_1 or "userdata" == _type_1 then -- 2544
					path = _obj_0.path -- 2544
				end -- 2544
			end -- 2544
			if path ~= nil then -- 2544
				local projDir = getWaProjectDirFromFile(path) -- 2545
				if projDir then -- 2545
					local message = Wasm:buildWaAsync(projDir) -- 2546
					if message == "" then -- 2547
						return { -- 2548
							success = true -- 2548
						} -- 2548
					else -- 2550
						return { -- 2550
							success = false, -- 2550
							message = message -- 2550
						} -- 2550
					end -- 2547
				else -- 2552
					return { -- 2552
						success = false, -- 2552
						message = 'Wa file needs a project' -- 2552
					} -- 2552
				end -- 2545
			end -- 2544
		end -- 2544
	end -- 2544
	return { -- 2553
		success = false, -- 2553
		message = 'failed to build' -- 2553
	} -- 2553
end) -- 2543
HttpServer:postSchedule("/wa/format", function(req) -- 2555
	do -- 2556
		local _type_0 = type(req) -- 2556
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2556
		if _tab_0 then -- 2556
			local file -- 2556
			do -- 2556
				local _obj_0 = req.body -- 2556
				local _type_1 = type(_obj_0) -- 2556
				if "table" == _type_1 or "userdata" == _type_1 then -- 2556
					file = _obj_0.file -- 2556
				end -- 2556
			end -- 2556
			if file ~= nil then -- 2556
				local code = Wasm:formatWaAsync(file) -- 2557
				if code == "" then -- 2558
					return { -- 2559
						success = false -- 2559
					} -- 2559
				else -- 2561
					return { -- 2561
						success = true, -- 2561
						code = code -- 2561
					} -- 2561
				end -- 2558
			end -- 2556
		end -- 2556
	end -- 2556
	return { -- 2562
		success = false -- 2562
	} -- 2562
end) -- 2555
HttpServer:postSchedule("/wa/create", function(req) -- 2564
	do -- 2565
		local _type_0 = type(req) -- 2565
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2565
		if _tab_0 then -- 2565
			local path -- 2565
			do -- 2565
				local _obj_0 = req.body -- 2565
				local _type_1 = type(_obj_0) -- 2565
				if "table" == _type_1 or "userdata" == _type_1 then -- 2565
					path = _obj_0.path -- 2565
				end -- 2565
			end -- 2565
			if path ~= nil then -- 2565
				if not Content:exist(Path:getPath(path)) then -- 2566
					return { -- 2567
						success = false, -- 2567
						message = "target path not existed" -- 2567
					} -- 2567
				end -- 2566
				if Content:exist(path) then -- 2568
					return { -- 2569
						success = false, -- 2569
						message = "target project folder existed" -- 2569
					} -- 2569
				end -- 2568
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2570
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2571
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2572
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2573
					return { -- 2576
						success = false, -- 2576
						message = "missing template project" -- 2576
					} -- 2576
				end -- 2573
				if not Content:mkdir(path) then -- 2577
					return { -- 2578
						success = false, -- 2578
						message = "failed to create project folder" -- 2578
					} -- 2578
				end -- 2577
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2579
					Content:remove(path) -- 2580
					return { -- 2581
						success = false, -- 2581
						message = "failed to copy template" -- 2581
					} -- 2581
				end -- 2579
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2582
					Content:remove(path) -- 2583
					return { -- 2584
						success = false, -- 2584
						message = "failed to copy template" -- 2584
					} -- 2584
				end -- 2582
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2585
					Content:remove(path) -- 2586
					return { -- 2587
						success = false, -- 2587
						message = "failed to copy template" -- 2587
					} -- 2587
				end -- 2585
				return { -- 2588
					success = true -- 2588
				} -- 2588
			end -- 2565
		end -- 2565
	end -- 2565
	return { -- 2564
		success = false, -- 2564
		message = "invalid call" -- 2564
	} -- 2564
end) -- 2564
local tsBuildGlobs = { -- 2591
	"**/*.ts", -- 2591
	"**/*.tsx", -- 2592
	"!**/.*/**", -- 2593
	"!**/node_modules/**" -- 2594
} -- 2590
local tsSnapshotGlobs = { -- 2597
	"**/*.ts", -- 2597
	"**/*.tsx", -- 2598
	"**/*.lua", -- 2599
	"!**/.*/**", -- 2600
	"!**/node_modules/**" -- 2601
} -- 2596
local collectTSVirtualFiles -- 2603
collectTSVirtualFiles = function(sourceRoot) -- 2603
	local files = { } -- 2604
	local seen = { } -- 2605
	local addFile -- 2606
	addFile = function(file, moduleName, virtualFile) -- 2606
		if moduleName == nil then -- 2606
			moduleName = nil -- 2606
		end -- 2606
		if virtualFile == nil then -- 2606
			virtualFile = nil -- 2606
		end -- 2606
		local targetFile = virtualFile or file -- 2607
		do -- 2608
			local entry = seen[targetFile] -- 2608
			if entry then -- 2608
				if moduleName and moduleName ~= "" then -- 2609
					entry.moduleName = moduleName -- 2609
				end -- 2609
				return -- 2610
			end -- 2608
		end -- 2608
		local content = Content:load(file) -- 2611
		if content then -- 2611
			local entry = { -- 2612
				file = targetFile, -- 2612
				content = content -- 2612
			} -- 2612
			if moduleName and moduleName ~= "" then -- 2613
				entry.moduleName = moduleName -- 2613
			end -- 2613
			seen[targetFile] = entry -- 2614
			files[#files + 1] = entry -- 2615
		end -- 2611
	end -- 2606
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2616
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2617
		for _index_0 = 1, #_list_0 do -- 2617
			local subFile = _list_0[_index_0] -- 2617
			addFile(Path(sourceRoot, subFile)) -- 2618
		end -- 2617
		local libraryRoots = { -- 2620
			Path(sourceRoot, "Script", "Lib"), -- 2620
			Path(sourceRoot, "Lib"), -- 2621
			Path(Content.assetPath, "Script", "Lib") -- 2622
		} -- 2619
		for _index_0 = 1, #libraryRoots do -- 2623
			local libraryRoot = libraryRoots[_index_0] -- 2623
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2624
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2625
				for _index_1 = 1, #_list_1 do -- 2625
					local subFile = _list_1[_index_1] -- 2625
					local file = Path(libraryRoot, subFile) -- 2626
					local virtualFile = Path(sourceRoot, subFile) -- 2627
					addFile(file, nil, virtualFile) -- 2628
				end -- 2625
			end -- 2624
		end -- 2623
	end -- 2616
	local locale -- 2629
	if App.locale:match('^zh') then -- 2629
		locale = 'zh-Hans' -- 2629
	else -- 2629
		locale = 'en' -- 2629
	end -- 2629
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2630
	local _list_0 = Content:getFiles(declarationRoot) -- 2631
	for _index_0 = 1, #_list_0 do -- 2631
		local file = _list_0[_index_0] -- 2631
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2632
			local fullPath = Path(declarationRoot, file) -- 2633
			local moduleName = Path:getName(Path:getName(file)) -- 2634
			addFile(fullPath, moduleName) -- 2635
		end -- 2632
	end -- 2631
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2636
	local lualibBundleTarget -- 2637
	if sourceRoot then -- 2637
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2637
	else -- 2637
		lualibBundleTarget = "lualib_bundle.lua" -- 2637
	end -- 2637
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2638
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2639
	local _list_1 = Content:getFiles(lualibRoot) -- 2640
	for _index_0 = 1, #_list_1 do -- 2640
		local file = _list_1[_index_0] -- 2640
		if Path:getExt(file) == "lua" then -- 2641
			local virtualFile -- 2642
			if sourceRoot then -- 2642
				virtualFile = Path(sourceRoot, "lualib", file) -- 2642
			else -- 2642
				virtualFile = Path("lualib", file) -- 2642
			end -- 2642
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2643
		end -- 2641
	end -- 2640
	return files -- 2644
end -- 2603
local supportsCompilerWebView -- 2646
supportsCompilerWebView = function() -- 2646
	local _val_0 = App.platform -- 2646
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2646
end -- 2646
local webIDECompilerReady = false -- 2647
local webIDEConnectionGeneration = 0 -- 2648
local tsProbeId = 0 -- 2649
local probeWebIDECompiler -- 2651
probeWebIDECompiler = function(isCancelled) -- 2651
	if HttpServer.wsConnectionCount == 0 then -- 2652
		return false -- 2652
	end -- 2652
	tsProbeId = tsProbeId + 1 -- 2653
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2654
	local generation = webIDEConnectionGeneration -- 2655
	local done, ready = false, false -- 2656
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2657
	local listener = Node() -- 2658
	listener:gslot("AppWS", function(event) -- 2659
		if event.type == "Receive" then -- 2660
			local res = json.decode(event.msg) -- 2661
			if res then -- 2661
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2662
					responses = responses + 1 -- 2663
					ready = ready or res.success == true -- 2664
					done = ready or responses >= expectedResponses -- 2665
				end -- 2662
			end -- 2661
		end -- 2660
	end) -- 2659
	emit("AppWS", "Send", json.encode({ -- 2666
		name = "TranspileTSProbe", -- 2666
		id = requestId -- 2666
	})) -- 2666
	local deadline = App.runningTime + 5 -- 2667
	wait(function() -- 2668
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2668
	end) -- 2668
	listener:removeFromParent() -- 2669
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2670
	if generation == webIDEConnectionGeneration then -- 2671
		webIDECompilerReady = ready -- 2671
	end -- 2671
	return ready -- 2672
end -- 2651
local compilerConnectionListener = Node() -- 2674
compilerConnectionListener:addTo(Director.systemUI) -- 2676
local _anon_func_8 = function(event) -- 2678
	local _val_0 = event.type -- 2678
	return "Open" == _val_0 or "Close" == _val_0 -- 2678
end -- 2678
compilerConnectionListener:gslot("AppWS", function(event) -- 2677
	if _anon_func_8(event) then -- 2678
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2679
		webIDECompilerReady = false -- 2680
		if HttpServer.wsConnectionCount > 0 then -- 2681
			return thread(function() -- 2682
				return probeWebIDECompiler() -- 2682
			end) -- 2682
		end -- 2681
	end -- 2678
end) -- 2677
local _anon_func_9 = function(res) -- 2707
	if res.success then -- 2707
		return "tool" -- 2707
	else -- 2707
		return res.failureKind -- 2707
	end -- 2707
end -- 2707
local transpileTSFileWithWebIDE -- 2684
do -- 2684
	local tsBuildRequestId = 0 -- 2685
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2686
		if not probeWebIDECompiler(isCancelled) then -- 2687
			if isCancelled and isCancelled() then -- 2688
				return { -- 2689
					success = false, -- 2689
					file = file, -- 2689
					message = "build canceled", -- 2689
					interrupted = true -- 2689
				} -- 2689
			end -- 2688
			return { -- 2690
				success = false, -- 2690
				file = file, -- 2690
				message = "TypeScript transpiler is not ready", -- 2690
				failureKind = "tool" -- 2690
			} -- 2690
		end -- 2687
		tsBuildRequestId = tsBuildRequestId + 1 -- 2691
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2692
		local done = false -- 2693
		local result = nil -- 2694
		local listener = Node() -- 2695
		listener:gslot("AppWS", function(event) -- 2696
			if event.type == "Receive" then -- 2697
				local res = json.decode(event.msg) -- 2698
				if res then -- 2698
					if res.name == "TranspileTS" and res.id == requestId then -- 2699
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2700
							local luaFile = Path:replaceExt(file, "lua") -- 2701
							if Content:save(luaFile, res.luaCode) then -- 2702
								result = { -- 2703
									success = true, -- 2703
									file = file -- 2703
								} -- 2703
							else -- 2705
								result = { -- 2705
									success = false, -- 2705
									file = file, -- 2705
									message = "failed to save " .. tostring(luaFile) -- 2705
								} -- 2705
							end -- 2702
						else -- 2707
							result = { -- 2707
								success = false, -- 2707
								file = file, -- 2707
								message = res.message or "Compiler returned no Lua output", -- 2707
								failureKind = _anon_func_9(res) -- 2707
							} -- 2707
						end -- 2700
						done = true -- 2708
					end -- 2699
				end -- 2698
			end -- 2697
		end) -- 2696
		emit("AppWS", "Send", json.encode({ -- 2709
			name = "TranspileTS", -- 2709
			id = requestId, -- 2709
			file = file, -- 2709
			content = content, -- 2709
			projectRoot = sourceRoot, -- 2709
			files = files -- 2709
		})) -- 2709
		local deadline = App.runningTime + 30 -- 2710
		wait(function() -- 2711
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2711
		end) -- 2711
		listener:removeFromParent() -- 2712
		if not done then -- 2713
			webIDECompilerReady = false -- 2714
			if isCancelled and isCancelled() then -- 2715
				return { -- 2716
					success = false, -- 2716
					file = file, -- 2716
					message = "build canceled", -- 2716
					interrupted = true -- 2716
				} -- 2716
			end -- 2715
			return { -- 2717
				success = false, -- 2717
				file = file, -- 2717
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2717
				failureKind = "tool" -- 2717
			} -- 2717
		end -- 2713
		return result -- 2718
	end -- 2686
end -- 2684
local compilerReadyTimeout <const> = 15 -- 2720
local compilerBuildTimeout <const> = 30 -- 2721
local compilerIdleCloseSeconds <const> = 8 -- 2722
local compilerReady = false -- 2723
local compilerRequested = false -- 2724
local compilerFailure = nil -- 2725
local compilerUsers = 0 -- 2726
local compilerCloseGeneration = 0 -- 2727
local compilerJobId = 0 -- 2728
local compilerJobs = { } -- 2729
local compilerResults = { } -- 2730
local compilerInFlight = { } -- 2731
HttpServer:post("/compiler/ready", function() -- 2733
	if not compilerRequested then -- 2734
		return { -- 2734
			success = false -- 2734
		} -- 2734
	end -- 2734
	compilerReady = true -- 2735
	return { -- 2736
		success = true -- 2736
	} -- 2736
end) -- 2733
HttpServer:post("/compiler/failure", function(req) -- 2738
	if not compilerRequested then -- 2739
		return { -- 2739
			success = false -- 2739
		} -- 2739
	end -- 2739
	do -- 2740
		local _type_0 = type(req) -- 2740
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2740
		if _tab_0 then -- 2740
			local message -- 2740
			do -- 2740
				local _obj_0 = req.body -- 2740
				local _type_1 = type(_obj_0) -- 2740
				if "table" == _type_1 or "userdata" == _type_1 then -- 2740
					message = _obj_0.message -- 2740
				end -- 2740
			end -- 2740
			if message ~= nil then -- 2740
				if type(message) == "string" then -- 2741
					compilerFailure = message -- 2742
					compilerReady = false -- 2743
					return { -- 2744
						success = true -- 2744
					} -- 2744
				end -- 2741
			end -- 2740
		end -- 2740
	end -- 2740
	return { -- 2738
		success = false -- 2738
	} -- 2738
end) -- 2738
HttpServer:postSchedule("/compiler/poll", function() -- 2746
	if not compilerRequested then -- 2747
		return { -- 2747
			success = false -- 2747
		} -- 2747
	end -- 2747
	compilerReady = true -- 2748
	local deadline = App.runningTime + 5 -- 2749
	wait(function() -- 2750
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2750
	end) -- 2750
	if not (compilerRequested and not compilerFailure) then -- 2751
		return { -- 2751
			success = false -- 2751
		} -- 2751
	end -- 2751
	local job = table.remove(compilerJobs, 1) -- 2752
	if job then -- 2753
		compilerInFlight[job.id] = true -- 2754
	end -- 2753
	return { -- 2755
		success = true, -- 2755
		job = job -- 2755
	} -- 2755
end) -- 2746
HttpServer:post("/compiler/result", function(req) -- 2757
	do -- 2758
		local _type_0 = type(req) -- 2758
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2758
		if _tab_0 then -- 2758
			local body = req.body -- 2758
			if body ~= nil then -- 2758
				local id = body.id -- 2759
				if not (id and compilerInFlight[id]) then -- 2760
					return { -- 2760
						success = false, -- 2760
						message = "invalid compiler job" -- 2760
					} -- 2760
				end -- 2760
				compilerInFlight[id] = nil -- 2761
				compilerResults[id] = body -- 2762
				return { -- 2763
					success = true -- 2763
				} -- 2763
			end -- 2758
		end -- 2758
	end -- 2758
	return { -- 2757
		success = false -- 2757
	} -- 2757
end) -- 2757
local acquireCompiler -- 2765
acquireCompiler = function() -- 2765
	compilerUsers = compilerUsers + 1 -- 2766
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2767
	if not compilerRequested then -- 2768
		compilerRequested = true -- 2769
		compilerReady = false -- 2770
		compilerFailure = nil -- 2771
		return emit("AppWebView", "/compiler.html", true) -- 2772
	end -- 2768
end -- 2765
local releaseCompiler -- 2774
releaseCompiler = function() -- 2774
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2775
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2776
	if not (compilerUsers == 0) then -- 2777
		return -- 2777
	end -- 2777
	local closeGeneration = compilerCloseGeneration -- 2778
	return thread(function() -- 2779
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2780
		wait(function() -- 2781
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2782
		end) -- 2781
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2787
			compilerRequested = false -- 2788
			compilerReady = false -- 2789
			return emit("AppWebView", "/compiler.html", false) -- 2790
		end -- 2787
	end) -- 2779
end -- 2774
local removeCompilerJob -- 2792
removeCompilerJob = function(id) -- 2792
	for index = #compilerJobs, 1, -1 do -- 2793
		if compilerJobs[index].id == id then -- 2794
			table.remove(compilerJobs, index) -- 2795
		end -- 2794
	end -- 2793
	compilerInFlight[id] = nil -- 2796
	compilerResults[id] = nil -- 2797
end -- 2792
local transpileTSFileWithCompiler -- 2799
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2799
	acquireCompiler() -- 2800
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2801
	wait(function() -- 2802
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2802
	end) -- 2802
	if not compilerReady then -- 2803
		releaseCompiler() -- 2804
		if isCancelled and isCancelled() then -- 2805
			return { -- 2806
				success = false, -- 2806
				file = file, -- 2806
				message = "build canceled", -- 2806
				interrupted = true -- 2806
			} -- 2806
		end -- 2805
		return { -- 2807
			success = false, -- 2807
			file = file, -- 2807
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2807
			failureKind = "tool" -- 2807
		} -- 2807
	end -- 2803
	compilerJobId = compilerJobId + 1 -- 2808
	local jobId = compilerJobId -- 2809
	compilerJobs[#compilerJobs + 1] = { -- 2811
		id = jobId, -- 2811
		file = file, -- 2812
		content = content, -- 2813
		projectRoot = sourceRoot, -- 2814
		files = files -- 2815
	} -- 2810
	local deadline = App.runningTime + compilerBuildTimeout -- 2816
	wait(function() -- 2817
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2817
	end) -- 2817
	local response = compilerResults[jobId] -- 2818
	removeCompilerJob(jobId) -- 2819
	releaseCompiler() -- 2820
	if not response then -- 2821
		if isCancelled and isCancelled() then -- 2822
			return { -- 2823
				success = false, -- 2823
				file = file, -- 2823
				message = "build canceled", -- 2823
				interrupted = true -- 2823
			} -- 2823
		end -- 2822
		return { -- 2824
			success = false, -- 2824
			file = file, -- 2824
			message = compilerFailure or "TypeScript transpile timed out", -- 2824
			failureKind = "tool" -- 2824
		} -- 2824
	end -- 2821
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2825
		local luaFile = Path:replaceExt(file, "lua") -- 2826
		if Content:save(luaFile, response.luaCode) then -- 2827
			return { -- 2828
				success = true, -- 2828
				file = file -- 2828
			} -- 2828
		end -- 2827
		return { -- 2829
			success = false, -- 2829
			file = file, -- 2829
			message = "failed to save " .. tostring(luaFile) -- 2829
		} -- 2829
	end -- 2825
	return { -- 2830
		success = false, -- 2830
		file = file, -- 2830
		message = response.message or "TypeScript transpile failed" -- 2830
	} -- 2830
end -- 2799
local compilerFailureListener = Node() -- 2832
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2833
	compilerFailure = message -- 2834
	compilerReady = false -- 2835
end) -- 2833
local transpileTSFile -- 2837
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2837
	if supportsCompilerWebView() and not files then -- 2838
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2839
	end -- 2838
	if HttpServer.wsConnectionCount > 0 then -- 2840
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2841
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2842
			return result -- 2842
		end -- 2842
		webIDECompilerReady = false -- 2843
	end -- 2840
	if supportsCompilerWebView() then -- 2844
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2845
	end -- 2844
	return { -- 2846
		success = false, -- 2846
		file = file, -- 2846
		message = "Web IDE compiler not connected", -- 2846
		failureKind = "tool" -- 2846
	} -- 2846
end -- 2837
local _anon_func_10 = function(path) -- 2861
	local _val_0 = Path:getExt(path) -- 2861
	return "ts" == _val_0 or "tsx" == _val_0 -- 2861
end -- 2861
HttpServer:postSchedule("/ts/build", function(req) -- 2848
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2849
	local buildSucceeded = false -- 2850
	local _ <close> = setmetatable({ }, { -- 2851
		__close = function() -- 2851
			return finishUpdate(buildSucceeded) -- 2851
		end -- 2851
	}) -- 2851
	do -- 2852
		local _type_0 = type(req) -- 2852
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2852
		if _tab_0 then -- 2852
			local path -- 2852
			do -- 2852
				local _obj_0 = req.body -- 2852
				local _type_1 = type(_obj_0) -- 2852
				if "table" == _type_1 or "userdata" == _type_1 then -- 2852
					path = _obj_0.path -- 2852
				end -- 2852
			end -- 2852
			if path ~= nil then -- 2852
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2853
					return { -- 2854
						success = false, -- 2854
						message = "Web IDE not connected" -- 2854
					} -- 2854
				end -- 2853
				local projectRoot = req.body.projectRoot -- 2855
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2856
				if not Content:exist(path) then -- 2857
					return { -- 2858
						success = false, -- 2858
						message = "path not existed" -- 2858
					} -- 2858
				end -- 2857
				local messages = { } -- 2859
				if not Content:isdir(path) then -- 2860
					if not (_anon_func_10(path)) then -- 2861
						return { -- 2862
							success = false, -- 2862
							message = "expecting a TypeScript file" -- 2862
						} -- 2862
					end -- 2861
					local content = Content:load(path) -- 2863
					if not content then -- 2864
						return { -- 2865
							success = false, -- 2865
							message = "failed to read file" -- 2865
						} -- 2865
					end -- 2864
					emit("AppWS", "Send", json.encode({ -- 2866
						name = "UpdateFile", -- 2866
						file = path, -- 2866
						exists = true, -- 2866
						content = content, -- 2866
						projectRoot = sourceRoot -- 2866
					})) -- 2866
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2867
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2868
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2869
					end -- 2867
				else -- 2871
					local fileData = { } -- 2871
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2872
					for _index_0 = 1, #_list_0 do -- 2872
						local subFile = _list_0[_index_0] -- 2872
						local file = Path(path, subFile) -- 2873
						local content = Content:load(file) -- 2874
						if content then -- 2874
							fileData[file] = content -- 2875
							emit("AppWS", "Send", json.encode({ -- 2876
								name = "UpdateFile", -- 2876
								file = file, -- 2876
								exists = true, -- 2876
								content = content, -- 2876
								projectRoot = sourceRoot -- 2876
							})) -- 2876
						else -- 2878
							messages[#messages + 1] = { -- 2878
								success = false, -- 2878
								file = file, -- 2878
								message = "failed to read file" -- 2878
							} -- 2878
						end -- 2874
					end -- 2872
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2879
					for file, content in pairs(fileData) do -- 2880
						if "d" == Path:getExt(Path:getName(file)) then -- 2881
							goto _continue_0 -- 2881
						end -- 2881
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2882
						::_continue_0:: -- 2881
					end -- 2880
				end -- 2860
				local success = true -- 2883
				for _index_0 = 1, #messages do -- 2884
					local item = messages[_index_0] -- 2884
					if not item.success then -- 2885
						success = false -- 2885
					end -- 2885
				end -- 2884
				local message = nil -- 2886
				if not success then -- 2887
					message = "TypeScript compilation failed" -- 2887
				end -- 2887
				buildSucceeded = success -- 2888
				return { -- 2889
					success = success, -- 2889
					messages = messages, -- 2889
					message = message -- 2889
				} -- 2889
			end -- 2852
		end -- 2852
	end -- 2852
	return { -- 2848
		success = false -- 2848
	} -- 2848
end) -- 2848
HttpServer:post("/download", function(req) -- 2891
	do -- 2892
		local _type_0 = type(req) -- 2892
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2892
		if _tab_0 then -- 2892
			local url -- 2892
			do -- 2892
				local _obj_0 = req.body -- 2892
				local _type_1 = type(_obj_0) -- 2892
				if "table" == _type_1 or "userdata" == _type_1 then -- 2892
					url = _obj_0.url -- 2892
				end -- 2892
			end -- 2892
			local target -- 2892
			do -- 2892
				local _obj_0 = req.body -- 2892
				local _type_1 = type(_obj_0) -- 2892
				if "table" == _type_1 or "userdata" == _type_1 then -- 2892
					target = _obj_0.target -- 2892
				end -- 2892
			end -- 2892
			if url ~= nil and target ~= nil then -- 2892
				local Entry = require("Script.Dev.Entry") -- 2893
				Entry.downloadFile(url, target) -- 2894
				return { -- 2895
					success = true -- 2895
				} -- 2895
			end -- 2892
		end -- 2892
	end -- 2892
	return { -- 2891
		success = false -- 2891
	} -- 2891
end) -- 2891
local isDesktopPlatform -- 2897
isDesktopPlatform = function() -- 2897
	local _val_0 = App.platform -- 2898
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2898
end -- 2897
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 2900
local nativeIDEListener = Node() -- 2901
nativeIDEListener:addTo(Director.systemUI) -- 2902
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 2903
	nativeIDEState, nativeIDEMessage = state, message -- 2904
end) -- 2903
local _anon_func_11 = function() -- 2907
	local _val_0 = App.platform -- 2907
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2907
end -- 2907
HttpServer:post("/ide", function(req) -- 2906
	if not (_anon_func_11()) then -- 2907
		return { -- 2907
			success = false, -- 2907
			message = "Native IDE is unavailable" -- 2907
		} -- 2907
	end -- 2907
	if not App.webIDEEnabled then -- 2908
		return { -- 2908
			success = false, -- 2908
			message = "Embedded Web IDE is disabled" -- 2908
		} -- 2908
	end -- 2908
	do -- 2909
		local _type_0 = type(req) -- 2909
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2909
		if _tab_0 then -- 2909
			local action -- 2909
			do -- 2909
				local _obj_0 = req.body -- 2909
				local _type_1 = type(_obj_0) -- 2909
				if "table" == _type_1 or "userdata" == _type_1 then -- 2909
					action = _obj_0.action -- 2909
				end -- 2909
			end -- 2909
			if action ~= nil then -- 2909
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 2910
					emit("AppWebView", "/ide/" .. action, true) -- 2911
					return { -- 2912
						success = true -- 2912
					} -- 2912
				end -- 2910
			end -- 2909
		end -- 2909
	end -- 2909
	return { -- 2906
		success = false, -- 2906
		message = "invalid IDE action" -- 2906
	} -- 2906
end) -- 2906
local _anon_func_12 = function() -- 2928
	local _val_0 = App.platform -- 2928
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2928
end -- 2928
local getServerStatus -- 2914
getServerStatus = function() -- 2914
	local Entry = require("Script.Dev.Entry") -- 2915
	local running = Entry.getCurrentEntryStatus() -- 2916
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2917
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2918
	return { -- 2920
		success = true, -- 2920
		platform = App.platform, -- 2921
		locale = App.locale, -- 2922
		version = App.version, -- 2923
		url = "http://localhost:8866", -- 2924
		wsConnectionCount = wsConnectionCount, -- 2925
		webIDEConnected = wsConnectionCount > 0, -- 2926
		nativeIDE = { -- 2928
			supported = _anon_func_12(), -- 2928
			enabled = App.webIDEEnabled, -- 2929
			state = nativeIDEState, -- 2930
			message = nativeIDEMessage -- 2931
		}, -- 2927
		typescriptCompiler = { -- 2933
			webIDEReady = webIDECompilerReady, -- 2933
			webIDEGeneration = webIDEConnectionGeneration, -- 2934
			embeddedSupported = supportsCompilerWebView(), -- 2935
			embeddedRequested = compilerRequested, -- 2936
			embeddedReady = compilerReady, -- 2937
			users = compilerUsers, -- 2938
			queuedJobs = #compilerJobs, -- 2939
			failure = compilerFailure -- 2940
		}, -- 2932
		assetPath = Content.assetPath, -- 2941
		writablePath = Content.writablePath, -- 2942
		appPath = Content.appPath, -- 2943
		waTemplateReady = waTemplateReady, -- 2944
		running = running -- 2945
	} -- 2919
end -- 2914
HttpServer:post("/status", function() -- 2948
	return getServerStatus() -- 2949
end) -- 2948
HttpServer:postSchedule("/doctor/fix", function(req) -- 2951
	do -- 2952
		local _type_0 = type(req) -- 2952
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2952
		if _tab_0 then -- 2952
			local openWebIDE -- 2952
			do -- 2952
				local _obj_0 = req.body -- 2952
				local _type_1 = type(_obj_0) -- 2952
				if "table" == _type_1 or "userdata" == _type_1 then -- 2952
					openWebIDE = _obj_0.openWebIDE -- 2952
				end -- 2952
			end -- 2952
			if openWebIDE ~= nil then -- 2952
				if not openWebIDE then -- 2953
					return { -- 2954
						success = false, -- 2954
						message = "nothing to fix" -- 2954
					} -- 2954
				end -- 2953
				local status = getServerStatus() -- 2955
				if status.webIDEConnected then -- 2956
					return { -- 2957
						success = true, -- 2957
						fixed = false, -- 2957
						message = "Web IDE already connected.", -- 2957
						status = status -- 2957
					} -- 2957
				end -- 2956
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2958
				if waitSeconds > 0 then -- 2959
					local deadline = os.time() + waitSeconds -- 2960
					repeat -- 2961
						sleep(0.2) -- 2962
						status = getServerStatus() -- 2963
						if status.webIDEConnected then -- 2964
							return { -- 2965
								success = true, -- 2965
								fixed = false, -- 2965
								reconnected = true, -- 2965
								message = "Web IDE reconnected.", -- 2965
								status = status -- 2965
							} -- 2965
						end -- 2964
					until os.time() >= deadline -- 2961
				end -- 2959
				if not isDesktopPlatform() then -- 2967
					return { -- 2968
						success = false, -- 2968
						message = "opening Web IDE is only supported on desktop platforms", -- 2968
						status = status -- 2968
					} -- 2968
				end -- 2967
				local url = "http://localhost:8866" -- 2969
				App:openURL(url) -- 2970
				status.openedURL = url -- 2971
				return { -- 2972
					success = true, -- 2972
					fixed = true, -- 2972
					message = "Opened Web IDE in the local browser.", -- 2972
					url = url, -- 2972
					status = status -- 2972
				} -- 2972
			end -- 2952
		end -- 2952
	end -- 2952
	return { -- 2951
		success = false, -- 2951
		message = "invalid call" -- 2951
	} -- 2951
end) -- 2951
local status = { } -- 2974
_module_0 = status -- 2975
status.transpileTSFile = transpileTSFile -- 2977
status.buildAsync = function(path) -- 2979
	if not Content:exist(path) then -- 2980
		return { -- 2981
			success = false, -- 2981
			file = path, -- 2981
			message = "file not existed" -- 2981
		} -- 2981
	end -- 2980
	do -- 2982
		local _exp_0 = Path:getExt(path) -- 2982
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2982
			if '' == Path:getExt(Path:getName(path)) then -- 2983
				local content = Content:loadAsync(path) -- 2984
				if content then -- 2984
					local resultCodes, err = compileFileAsync(path, content) -- 2985
					if resultCodes then -- 2985
						return { -- 2986
							success = true, -- 2986
							file = path -- 2986
						} -- 2986
					else -- 2988
						return { -- 2988
							success = false, -- 2988
							file = path, -- 2988
							message = err -- 2988
						} -- 2988
					end -- 2985
				end -- 2984
			end -- 2983
		elseif "lua" == _exp_0 then -- 2989
			local content = Content:loadAsync(path) -- 2990
			if content then -- 2990
				do -- 2991
					local isTIC80 = CheckTIC80Code(content) -- 2991
					if isTIC80 then -- 2991
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2992
					end -- 2991
				end -- 2991
				local success, info -- 2993
				do -- 2993
					local _obj_0 = luaCheck(path, content) -- 2993
					success, info = _obj_0.success, _obj_0.info -- 2993
				end -- 2993
				if success then -- 2994
					return { -- 2995
						success = true, -- 2995
						file = path -- 2995
					} -- 2995
				elseif info and #info > 0 then -- 2996
					local messages = { } -- 2997
					for _index_0 = 1, #info do -- 2998
						local _des_0 = info[_index_0] -- 2998
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2998
						local lineText = "" -- 2999
						if line then -- 3000
							local currentLine = 1 -- 3001
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3002
								if currentLine == line then -- 3003
									lineText = text -- 3004
									break -- 3005
								end -- 3003
								currentLine = currentLine + 1 -- 3006
							end -- 3002
						end -- 3000
						if line then -- 3007
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3008
						else -- 3010
							messages[#messages + 1] = message -- 3010
						end -- 3007
					end -- 2998
					return { -- 3011
						success = false, -- 3011
						file = path, -- 3011
						message = table.concat(messages, "\n") -- 3011
					} -- 3011
				else -- 3013
					return { -- 3013
						success = false, -- 3013
						file = path, -- 3013
						message = "lua check failed" -- 3013
					} -- 3013
				end -- 2994
			end -- 2990
		elseif "yarn" == _exp_0 then -- 3014
			local content = Content:loadAsync(path) -- 3015
			if content then -- 3015
				local res, _, err = yarncompile(content, true) -- 3016
				if res then -- 3016
					return { -- 3017
						success = true, -- 3017
						file = path -- 3017
					} -- 3017
				else -- 3019
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3019
					local lineText = "" -- 3020
					if line then -- 3021
						local currentLine = 1 -- 3022
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3023
							if currentLine == line then -- 3024
								lineText = text -- 3025
								break -- 3026
							end -- 3024
							currentLine = currentLine + 1 -- 3027
						end -- 3023
					end -- 3021
					if node ~= "" then -- 3028
						node = "node: " .. tostring(node) .. ", " -- 3029
					else -- 3030
						node = "" -- 3030
					end -- 3028
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3031
					return { -- 3032
						success = false, -- 3032
						file = path, -- 3032
						message = message -- 3032
					} -- 3032
				end -- 3016
			end -- 3015
		end -- 2982
	end -- 2982
	return { -- 3033
		success = false, -- 3033
		file = path, -- 3033
		message = "invalid file to build" -- 3033
	} -- 3033
end -- 2979
HttpServer:postSchedule("/git/commit-files", function(req) -- 3035
	do -- 3036
		local _type_0 = type(req) -- 3036
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3036
		if _tab_0 then -- 3036
			local body = req.body -- 3036
			if body ~= nil then -- 3036
				local repoPath, commit = body.repoPath, body.commit -- 3037
				if gitInvalidRepoPath(repoPath) then -- 3038
					return { -- 3038
						success = false, -- 3038
						message = "invalid repoPath" -- 3038
					} -- 3038
				end -- 3038
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3039
					return { -- 3039
						success = false, -- 3039
						message = "invalid commit" -- 3039
					} -- 3039
				end -- 3039
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3040
				if not res.success then -- 3041
					return res -- 3041
				end -- 3041
				return { -- 3042
					success = true, -- 3042
					status = res.status, -- 3042
					data = res.status and res.status.data -- 3042
				} -- 3042
			end -- 3036
		end -- 3036
	end -- 3036
	return invalidArguments -- 3035
end) -- 3035
thread(function() -- 3044
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3045
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3046
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3047
		local storedAsset -- 3050
		storedAsset = function(file) -- 3050
			if Content:exist(file) then -- 3051
				return Content:load(file) -- 3052
			elseif Content:exist(file .. ".gz") then -- 3053
				return Content:load(file .. ".gz") -- 3054
			else -- 3055
				return "" -- 3055
			end -- 3051
		end -- 3050
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3056
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3057
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3058
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3059
		local readyContent = table.concat({ -- 3061
			App.version, -- 3061
			storedAsset(doraWeb), -- 3062
			storedAsset(heavyAssets), -- 3063
			storedAsset(runtimeIndex), -- 3064
			storedAsset(compilerIndex), -- 3065
			storedAsset(manifest) -- 3066
		}, "\n") -- 3060
		local needReload -- 3068
		if Content:exist(doraReady) then -- 3068
			needReload = readyContent ~= Content:load(doraReady) -- 3069
		else -- 3070
			needReload = true -- 3070
		end -- 3068
		if needReload then -- 3071
			Content:remove(Path(Content.appPath, ".www")) -- 3072
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3073
			Content:save(doraReady, readyContent) -- 3077
			print("Dora Dora is ready!") -- 3078
		end -- 3071
	end -- 3047
	if App.platform == "Emscripten" then -- 3079
		status.url = nil -- 3080
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3081
	end -- 3079
	HttpServer:clearStaticCacheControls() -- 3082
	HttpServer:setStaticCacheControl("no-cache") -- 3083
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3084
	if HttpServer:start(8866) then -- 3088
		local localIP = HttpServer.localIP -- 3089
		if localIP == "" then -- 3090
			localIP = "localhost" -- 3090
		end -- 3090
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3091
		return HttpServer:startWS(8868) -- 3092
	else -- 3094
		status.url = nil -- 3094
		return print("8866 Port not available!") -- 3095
	end -- 3088
end) -- 3044
return _module_0 -- 1
