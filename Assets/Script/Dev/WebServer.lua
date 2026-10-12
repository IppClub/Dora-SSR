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
				local repoPath, command, url = body.repoPath, body.command, body.url -- 694
				local host -- 695
				if url and url ~= "" then -- 695
					host = gitHostFromURL(url) -- 695
				else -- 695
					host = gitCommandHost(repoPath, command) -- 695
				end -- 695
				if not host then -- 696
					return { -- 696
						success = false, -- 696
						message = "git host is required" -- 696
					} -- 696
				end -- 696
				local items = gitCredentialsForHost(host) -- 697
				return { -- 698
					success = true, -- 698
					host = host, -- 698
					items = items, -- 698
					needsSelection = #items > 1, -- 698
					authId = (#items == 1 and items[1].id or nil) -- 698
				} -- 698
			end -- 693
		end -- 693
	end -- 693
	return invalidArguments -- 692
end) -- 692
HttpServer:post("/git/auth/save", function(req) -- 700
	do -- 701
		local _type_0 = type(req) -- 701
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 701
		if _tab_0 then -- 701
			local body = req.body -- 701
			if body ~= nil then -- 701
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token -- 702
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$") -- 703
				label = tostring(label or ""):match("^%s*(.-)%s*$") -- 704
				local credentialType = tostring(body.type or "token") -- 705
				username = tostring(username or "") -- 706
				local secret -- 707
				if credentialType == "basic" then -- 707
					secret = tostring(password or "") -- 707
				else -- 707
					secret = tostring(token or password or "") -- 707
				end -- 707
				if host == "" then -- 708
					return { -- 708
						success = false, -- 708
						message = "host is required" -- 708
					} -- 708
				end -- 708
				if label == "" then -- 709
					return { -- 709
						success = false, -- 709
						message = "label is required" -- 709
					} -- 709
				end -- 709
				if secret == "" then -- 710
					return { -- 710
						success = false, -- 710
						message = "secret is required" -- 710
					} -- 710
				end -- 710
				if not (("basic" == credentialType or "token" == credentialType)) then -- 711
					return { -- 711
						success = false, -- 711
						message = "invalid type" -- 711
					} -- 711
				end -- 711
				ensureGitTables() -- 712
				local now = os.time() -- 713
				if id then -- 714
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", { -- 716
						host, -- 716
						label, -- 716
						credentialType, -- 716
						username, -- 716
						secret, -- 716
						now, -- 716
						(tonumber(id) or 0) -- 716
					}) -- 715
					return { -- 718
						success = true, -- 718
						id = tonumber(id) -- 718
					} -- 718
				else -- 720
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", { -- 721
						host, -- 721
						label, -- 721
						credentialType, -- 721
						username, -- 721
						secret, -- 721
						now, -- 721
						now -- 721
					}) -- 720
					local rows = DB:query("select last_insert_rowid()") -- 723
					return { -- 724
						success = true, -- 724
						id = rows and rows[1] and rows[1][1] -- 724
					} -- 724
				end -- 714
			end -- 701
		end -- 701
	end -- 701
	return invalidArguments -- 700
end) -- 700
HttpServer:post("/git/auth/delete", function(req) -- 726
	do -- 727
		local _type_0 = type(req) -- 727
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 727
		if _tab_0 then -- 727
			local id -- 727
			do -- 727
				local _obj_0 = req.body -- 727
				local _type_1 = type(_obj_0) -- 727
				if "table" == _type_1 or "userdata" == _type_1 then -- 727
					id = _obj_0.id -- 727
				end -- 727
			end -- 727
			if id ~= nil then -- 727
				ensureGitTables() -- 728
				local credentialId = tonumber(id) or 0 -- 729
				DB:exec("delete from GitCredential where id = ?", { -- 730
					credentialId -- 730
				}) -- 730
				return { -- 731
					success = true -- 731
				} -- 731
			end -- 727
		end -- 727
	end -- 727
	return invalidArguments -- 726
end) -- 726
HttpServer:postSchedule("/git/auth/test", function(req) -- 733
	do -- 734
		local _type_0 = type(req) -- 734
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 734
		if _tab_0 then -- 734
			local body = req.body -- 734
			if body ~= nil then -- 734
				local repoPath, url, authId = body.repoPath, body.url, body.authId -- 735
				local credential = gitLoadCredential(authId) -- 736
				local optionsJSON = gitAuthOptionsJSON(credential) -- 737
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20) -- 738
			end -- 734
		end -- 734
	end -- 734
	return invalidArguments -- 733
end) -- 733
HttpServer:post("/agent/session/create", function(req) -- 740
	do -- 741
		local _type_0 = type(req) -- 741
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 741
		if _tab_0 then -- 741
			local projectRoot -- 741
			do -- 741
				local _obj_0 = req.body -- 741
				local _type_1 = type(_obj_0) -- 741
				if "table" == _type_1 or "userdata" == _type_1 then -- 741
					projectRoot = _obj_0.projectRoot -- 741
				end -- 741
			end -- 741
			local title -- 741
			do -- 741
				local _obj_0 = req.body -- 741
				local _type_1 = type(_obj_0) -- 741
				if "table" == _type_1 or "userdata" == _type_1 then -- 741
					title = _obj_0.title -- 741
				end -- 741
			end -- 741
			if projectRoot ~= nil and title ~= nil then -- 741
				return AgentSession.createSession(projectRoot, title) -- 742
			end -- 741
		end -- 741
	end -- 741
	return invalidArguments -- 740
end) -- 740
HttpServer:post("/agent/session/create-sub", function(req) -- 744
	do -- 745
		local _type_0 = type(req) -- 745
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 745
		if _tab_0 then -- 745
			local parentSessionId -- 745
			do -- 745
				local _obj_0 = req.body -- 745
				local _type_1 = type(_obj_0) -- 745
				if "table" == _type_1 or "userdata" == _type_1 then -- 745
					parentSessionId = _obj_0.parentSessionId -- 745
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
			if parentSessionId ~= nil and title ~= nil then -- 745
				return AgentSession.createSubSession(parentSessionId, title) -- 746
			end -- 745
		end -- 745
	end -- 745
	return invalidArguments -- 744
end) -- 744
HttpServer:post("/agent/session/get", function(req) -- 748
	do -- 749
		local _type_0 = type(req) -- 749
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 749
		if _tab_0 then -- 749
			local sessionId -- 749
			do -- 749
				local _obj_0 = req.body -- 749
				local _type_1 = type(_obj_0) -- 749
				if "table" == _type_1 or "userdata" == _type_1 then -- 749
					sessionId = _obj_0.sessionId -- 749
				end -- 749
			end -- 749
			if sessionId ~= nil then -- 749
				return AgentSession.getSession(sessionId) -- 750
			end -- 749
		end -- 749
	end -- 749
	return invalidArguments -- 748
end) -- 748
HttpServer:post("/agent/vision/asset", function(req) -- 752
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
			local path -- 753
			do -- 753
				local _obj_0 = req.body -- 753
				local _type_1 = type(_obj_0) -- 753
				if "table" == _type_1 or "userdata" == _type_1 then -- 753
					path = _obj_0.path -- 753
				end -- 753
			end -- 753
			if sessionId ~= nil and path ~= nil then -- 753
				return AgentVisionAssets.getSessionVisionImageFromPath(sessionId, path) -- 754
			end -- 753
		end -- 753
	end -- 753
	return invalidArguments -- 752
end) -- 752
HttpServer:post("/agent/session/mode", function(req) -- 756
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
			local workMode -- 757
			do -- 757
				local _obj_0 = req.body -- 757
				local _type_1 = type(_obj_0) -- 757
				if "table" == _type_1 or "userdata" == _type_1 then -- 757
					workMode = _obj_0.workMode -- 757
				end -- 757
			end -- 757
			if sessionId ~= nil and workMode ~= nil then -- 757
				return AgentSession.setWorkMode(sessionId, workMode) -- 758
			end -- 757
		end -- 757
	end -- 757
	return invalidArguments -- 756
end) -- 756
HttpServer:post("/agent/session/send", function(req) -- 760
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
			local prompt -- 761
			do -- 761
				local _obj_0 = req.body -- 761
				local _type_1 = type(_obj_0) -- 761
				if "table" == _type_1 or "userdata" == _type_1 then -- 761
					prompt = _obj_0.prompt -- 761
				end -- 761
			end -- 761
			if sessionId ~= nil and prompt ~= nil then -- 761
				return AgentSession.sendPrompt(sessionId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 762
			end -- 761
		end -- 761
	end -- 761
	return invalidArguments -- 760
end) -- 760
HttpServer:post("/agent/session/send-local", function(req) -- 764
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
			local localAgentConfigId -- 765
			do -- 765
				local _obj_0 = req.body -- 765
				local _type_1 = type(_obj_0) -- 765
				if "table" == _type_1 or "userdata" == _type_1 then -- 765
					localAgentConfigId = _obj_0.localAgentConfigId -- 765
				end -- 765
			end -- 765
			if sessionId ~= nil and prompt ~= nil and localAgentConfigId ~= nil then -- 765
				return AgentSession.sendLocalPrompt(sessionId, prompt, localAgentConfigId) -- 766
			end -- 765
		end -- 765
	end -- 765
	return invalidArguments -- 764
end) -- 764
HttpServer:post("/agent/session/local/new", function(req) -- 768
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
			if sessionId ~= nil then -- 769
				return AgentLocalAgent.abandonSession(sessionId) -- 770
			end -- 769
		end -- 769
	end -- 769
	return invalidArguments -- 768
end) -- 768
HttpServer:post("/agent/session/local/info", function(req) -- 772
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
				local info = AgentLocalAgent.getSessionInfo(sessionId) -- 774
				return { -- 775
					success = true, -- 775
					info = info -- 775
				} -- 775
			end -- 773
		end -- 773
	end -- 773
	return invalidArguments -- 772
end) -- 772
HttpServer:post("/agent/session/continue", function(req) -- 777
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
				return AgentSession.continuePrompt(sessionId, req.body.disabledAgentTools, req.body.llmConfigId) -- 779
			end -- 778
		end -- 778
	end -- 778
	return invalidArguments -- 777
end) -- 777
HttpServer:post("/agent/session/finish-handoff", function(req) -- 781
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
				return AgentSession.finishSubSessionHandoff(sessionId, req.body.llmConfigId) -- 783
			end -- 782
		end -- 782
	end -- 782
	return invalidArguments -- 781
end) -- 781
HttpServer:post("/agent/session/resend", function(req) -- 785
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
			local messageId -- 786
			do -- 786
				local _obj_0 = req.body -- 786
				local _type_1 = type(_obj_0) -- 786
				if "table" == _type_1 or "userdata" == _type_1 then -- 786
					messageId = _obj_0.messageId -- 786
				end -- 786
			end -- 786
			local prompt -- 786
			do -- 786
				local _obj_0 = req.body -- 786
				local _type_1 = type(_obj_0) -- 786
				if "table" == _type_1 or "userdata" == _type_1 then -- 786
					prompt = _obj_0.prompt -- 786
				end -- 786
			end -- 786
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 786
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 787
			end -- 786
		end -- 786
	end -- 786
	return invalidArguments -- 785
end) -- 785
HttpServer:post("/agent/session/questionnaire/respond", function(req) -- 789
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
			local questionnaireId -- 790
			do -- 790
				local _obj_0 = req.body -- 790
				local _type_1 = type(_obj_0) -- 790
				if "table" == _type_1 or "userdata" == _type_1 then -- 790
					questionnaireId = _obj_0.questionnaireId -- 790
				end -- 790
			end -- 790
			local answers -- 790
			do -- 790
				local _obj_0 = req.body -- 790
				local _type_1 = type(_obj_0) -- 790
				if "table" == _type_1 or "userdata" == _type_1 then -- 790
					answers = _obj_0.answers -- 790
				end -- 790
			end -- 790
			if sessionId ~= nil and questionnaireId ~= nil and answers ~= nil then -- 790
				return AgentSession.respondQuestionnaire(sessionId, questionnaireId, answers, req.body.llmConfigId) -- 791
			end -- 790
		end -- 790
	end -- 790
	return invalidArguments -- 789
end) -- 789
HttpServer:post("/agent/session/questionnaire/cancel", function(req) -- 793
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
			if sessionId ~= nil and questionnaireId ~= nil then -- 794
				return AgentSession.cancelQuestionnaire(sessionId, questionnaireId, req.body.llmConfigId) -- 795
			end -- 794
		end -- 794
	end -- 794
	return invalidArguments -- 793
end) -- 793
HttpServer:post("/agent/task/status", function(req) -- 797
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
			if sessionId ~= nil then -- 798
				local res = AgentSession.getSession(sessionId) -- 799
				if not res.success then -- 800
					return res -- 800
				end -- 800
				local taskId = res.session.currentTaskId -- 801
				local checkpoints -- 802
				if taskId then -- 802
					checkpoints = AgentTools.listCheckpoints(taskId) -- 802
				else -- 802
					checkpoints = { } -- 802
				end -- 802
				return { -- 804
					success = true, -- 804
					session = res.session, -- 805
					relatedSessions = res.relatedSessions, -- 806
					spawnInfo = res.spawnInfo, -- 807
					messages = res.messages, -- 808
					steps = res.steps, -- 809
					checkpoints = checkpoints, -- 810
					pendingQuestionnaire = res.pendingQuestionnaire, -- 811
					hasActivePlan = res.hasActivePlan -- 812
				} -- 803
			end -- 798
		end -- 798
	end -- 798
	return invalidArguments -- 797
end) -- 797
HttpServer:post("/agent/task/running", function() -- 814
	local res = AgentSession.listRunningSessions() -- 815
	if res.success and #res.sessions == 0 then -- 816
		res.sessions = nil -- 817
	end -- 816
	return res -- 818
end) -- 814
HttpServer:post("/agent/task/stop", function(req) -- 820
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
				return AgentSession.stopSessionTask(sessionId) -- 822
			end -- 821
		end -- 821
	end -- 821
	return invalidArguments -- 820
end) -- 820
HttpServer:post("/agent/checkpoint/list", function(req) -- 824
	do -- 825
		local _type_0 = type(req) -- 825
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 825
		if _tab_0 then -- 825
			local taskId -- 825
			do -- 825
				local _obj_0 = req.body -- 825
				local _type_1 = type(_obj_0) -- 825
				if "table" == _type_1 or "userdata" == _type_1 then -- 825
					taskId = _obj_0.taskId -- 825
				end -- 825
			end -- 825
			local sessionId -- 825
			do -- 825
				local _obj_0 = req.body -- 825
				local _type_1 = type(_obj_0) -- 825
				if "table" == _type_1 or "userdata" == _type_1 then -- 825
					sessionId = _obj_0.sessionId -- 825
				end -- 825
			end -- 825
			if sessionId ~= nil then -- 825
				if not taskId and sessionId then -- 826
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 827
				end -- 826
				if not taskId then -- 828
					return { -- 828
						success = false, -- 828
						message = "task not found" -- 828
					} -- 828
				end -- 828
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 829
				if not access.success then -- 830
					return access -- 830
				end -- 830
				return { -- 832
					success = true, -- 832
					taskId = taskId, -- 833
					checkpoints = AgentTools.listCheckpoints(taskId) -- 834
				} -- 831
			end -- 825
		end -- 825
	end -- 825
	return invalidArguments -- 824
end) -- 824
HttpServer:post("/agent/checkpoint/diff", function(req) -- 836
	do -- 837
		local _type_0 = type(req) -- 837
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 837
		if _tab_0 then -- 837
			local sessionId -- 837
			do -- 837
				local _obj_0 = req.body -- 837
				local _type_1 = type(_obj_0) -- 837
				if "table" == _type_1 or "userdata" == _type_1 then -- 837
					sessionId = _obj_0.sessionId -- 837
				end -- 837
			end -- 837
			local checkpointId -- 837
			do -- 837
				local _obj_0 = req.body -- 837
				local _type_1 = type(_obj_0) -- 837
				if "table" == _type_1 or "userdata" == _type_1 then -- 837
					checkpointId = _obj_0.checkpointId -- 837
				end -- 837
			end -- 837
			if sessionId ~= nil and checkpointId ~= nil then -- 837
				if not (checkpointId > 0) then -- 838
					return { -- 838
						success = false, -- 838
						message = "invalid checkpointId" -- 838
					} -- 838
				end -- 838
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 839
				if not access.success then -- 840
					return access -- 840
				end -- 840
				return AgentTools.getCheckpointDiff(checkpointId) -- 841
			end -- 837
		end -- 837
	end -- 837
	return invalidArguments -- 836
end) -- 836
HttpServer:post("/agent/task/diff", function(req) -- 843
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
			local taskId -- 844
			do -- 844
				local _obj_0 = req.body -- 844
				local _type_1 = type(_obj_0) -- 844
				if "table" == _type_1 or "userdata" == _type_1 then -- 844
					taskId = _obj_0.taskId -- 844
				end -- 844
			end -- 844
			if sessionId ~= nil and taskId ~= nil then -- 844
				if not (taskId > 0) then -- 845
					return { -- 845
						success = false, -- 845
						message = "invalid taskId" -- 845
					} -- 845
				end -- 845
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 846
				if not access.success then -- 847
					return access -- 847
				end -- 847
				return AgentTools.getTaskChangeSetDiff(taskId) -- 848
			end -- 844
		end -- 844
	end -- 844
	return invalidArguments -- 843
end) -- 843
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 850
	do -- 851
		local _type_0 = type(req) -- 851
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 851
		if _tab_0 then -- 851
			local sessionId -- 851
			do -- 851
				local _obj_0 = req.body -- 851
				local _type_1 = type(_obj_0) -- 851
				if "table" == _type_1 or "userdata" == _type_1 then -- 851
					sessionId = _obj_0.sessionId -- 851
				end -- 851
			end -- 851
			local checkpointId -- 851
			do -- 851
				local _obj_0 = req.body -- 851
				local _type_1 = type(_obj_0) -- 851
				if "table" == _type_1 or "userdata" == _type_1 then -- 851
					checkpointId = _obj_0.checkpointId -- 851
				end -- 851
			end -- 851
			if sessionId ~= nil and checkpointId ~= nil then -- 851
				if not (checkpointId > 0) then -- 852
					return { -- 852
						success = false, -- 852
						message = "invalid checkpointId" -- 852
					} -- 852
				end -- 852
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 853
				if not access.success then -- 854
					return access -- 854
				end -- 854
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, access.session.projectRoot) -- 855
				if not rollbackRes.success then -- 856
					return rollbackRes -- 856
				end -- 856
				return { -- 858
					success = true, -- 858
					checkpointId = rollbackRes.checkpointId -- 859
				} -- 857
			end -- 851
		end -- 851
	end -- 851
	return invalidArguments -- 850
end) -- 850
HttpServer:post("/agent/task/rollback", function(req) -- 861
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
			local taskId -- 862
			do -- 862
				local _obj_0 = req.body -- 862
				local _type_1 = type(_obj_0) -- 862
				if "table" == _type_1 or "userdata" == _type_1 then -- 862
					taskId = _obj_0.taskId -- 862
				end -- 862
			end -- 862
			if sessionId ~= nil and taskId ~= nil then -- 862
				if not (taskId > 0) then -- 863
					return { -- 863
						success = false, -- 863
						message = "invalid taskId" -- 863
					} -- 863
				end -- 863
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 864
				if not access.success then -- 865
					return access -- 865
				end -- 865
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, access.session.projectRoot) -- 866
				if not rollbackRes.success then -- 867
					return rollbackRes -- 867
				end -- 867
				return { -- 869
					success = true, -- 869
					taskId = rollbackRes.taskId, -- 870
					checkpointId = rollbackRes.checkpointId, -- 871
					checkpointCount = rollbackRes.checkpointCount -- 872
				} -- 868
			end -- 862
		end -- 862
	end -- 862
	return invalidArguments -- 861
end) -- 861
local getSearchPath -- 874
getSearchPath = function(file) -- 874
	do -- 875
		local dir = getProjectDirFromFile(file) -- 875
		if dir then -- 875
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 876
		end -- 875
	end -- 875
	return "" -- 874
end -- 874
local getSearchFolders -- 878
getSearchFolders = function(file) -- 878
	do -- 879
		local dir = getProjectDirFromFile(file) -- 879
		if dir then -- 879
			return { -- 881
				Path(dir, "Script"), -- 881
				dir -- 882
			} -- 880
		end -- 879
	end -- 879
	return { } -- 878
end -- 878
local disabledCheckForLua = { -- 885
	"incompatible number of returns", -- 885
	"unknown", -- 886
	"cannot index", -- 887
	"module not found", -- 888
	"don't know how to resolve", -- 889
	"ContainerItem", -- 890
	"cannot resolve a type", -- 891
	"invalid key", -- 892
	"inconsistent index type", -- 893
	"cannot use operator", -- 894
	"attempting ipairs loop", -- 895
	"expects record or nominal", -- 896
	"variable is not being assigned", -- 897
	"<invalid type>", -- 898
	"<any type>", -- 899
	"using the '#' operator", -- 900
	"can't match a record", -- 901
	"redeclaration of variable", -- 902
	"cannot apply pairs", -- 903
	"not a function", -- 904
	"to%-be%-closed" -- 905
} -- 884
local yueCheck -- 907
yueCheck = function(file, content, lax) -- 907
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 908
	if isTIC80 then -- 909
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 910
	end -- 909
	local searchPath = getSearchPath(file) -- 911
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 912
	local info = { } -- 913
	local globals = { } -- 914
	for _index_0 = 1, #checkResult do -- 915
		local _des_0 = checkResult[_index_0] -- 915
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 915
		if "error" == t then -- 916
			info[#info + 1] = { -- 917
				"syntax", -- 917
				file, -- 917
				line, -- 917
				col, -- 917
				msg -- 917
			} -- 917
		elseif "global" == t then -- 918
			globals[#globals + 1] = { -- 919
				msg, -- 919
				line, -- 919
				col -- 919
			} -- 919
		end -- 916
	end -- 915
	if luaCodes then -- 920
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 921
		if success then -- 922
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 923
			if not (lintResult == "") then -- 924
				lintResult = lintResult .. "\n" -- 924
			end -- 924
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 925
		else -- 926
			for _index_0 = 1, #lintResult do -- 926
				local _des_0 = lintResult[_index_0] -- 926
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 926
				if isTIC80 and tic80APIs[name] then -- 927
					goto _continue_0 -- 927
				end -- 927
				info[#info + 1] = { -- 928
					"syntax", -- 928
					file, -- 928
					line, -- 928
					col, -- 928
					"invalid global variable" -- 928
				} -- 928
				::_continue_0:: -- 927
			end -- 926
		end -- 922
	end -- 920
	return luaCodes, info -- 929
end -- 907
local luaCheck -- 931
luaCheck = function(file, content) -- 931
	local res, err = load(content, "check") -- 932
	if not res then -- 933
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 934
		return { -- 935
			success = false, -- 935
			info = { -- 935
				{ -- 935
					"syntax", -- 935
					file, -- 935
					tonumber(line), -- 935
					0, -- 935
					msg -- 935
				} -- 935
			} -- 935
		} -- 935
	end -- 933
	local success, info = teal.checkAsync(content, file, true, "") -- 936
	if info then -- 937
		do -- 938
			local _accum_0 = { } -- 938
			local _len_0 = 1 -- 938
			for _index_0 = 1, #info do -- 938
				local item = info[_index_0] -- 938
				local useCheck = true -- 939
				if not item[5]:match("unused") then -- 940
					for _index_1 = 1, #disabledCheckForLua do -- 941
						local check = disabledCheckForLua[_index_1] -- 941
						if item[5]:match(check) then -- 942
							useCheck = false -- 943
						end -- 942
					end -- 941
				end -- 940
				if not useCheck then -- 944
					goto _continue_0 -- 944
				end -- 944
				do -- 945
					local _exp_0 = item[1] -- 945
					if "type" == _exp_0 then -- 946
						item[1] = "warning" -- 947
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 948
						goto _continue_0 -- 949
					end -- 945
				end -- 945
				_accum_0[_len_0] = item -- 950
				_len_0 = _len_0 + 1 -- 939
				::_continue_0:: -- 939
			end -- 938
			info = _accum_0 -- 938
		end -- 938
		if #info == 0 then -- 951
			info = nil -- 952
			success = true -- 953
		end -- 951
	end -- 937
	return { -- 954
		success = success, -- 954
		info = info -- 954
	} -- 954
end -- 931
local luaCheckWithLineInfo -- 956
luaCheckWithLineInfo = function(file, luaCodes) -- 956
	local res = luaCheck(file, luaCodes) -- 957
	local info = { } -- 958
	if not res.success then -- 959
		local current = 1 -- 960
		local lastLine = 1 -- 961
		local lineMap = { } -- 962
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 963
			local num = lineCode:match("--%s*(%d+)%s*$") -- 964
			if num then -- 965
				lastLine = tonumber(num) -- 966
			end -- 965
			lineMap[current] = lastLine -- 967
			current = current + 1 -- 968
		end -- 963
		local _list_0 = res.info -- 969
		for _index_0 = 1, #_list_0 do -- 969
			local item = _list_0[_index_0] -- 969
			item[3] = lineMap[item[3]] or 0 -- 970
			item[4] = 0 -- 971
			info[#info + 1] = item -- 972
		end -- 969
		return false, info -- 973
	end -- 959
	return true, info -- 974
end -- 956
local getCompiledYueLine -- 976
getCompiledYueLine = function(content, line, row, file, lax) -- 976
	local luaCodes = yueCheck(file, content, lax) -- 977
	if not luaCodes then -- 978
		return nil -- 978
	end -- 978
	local current = 1 -- 979
	local lastLine = 1 -- 980
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 981
	local targetRow = nil -- 982
	local lineMap = { } -- 983
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 984
		local num = lineCode:match("--%s*(%d+)%s*$") -- 985
		if num then -- 986
			lastLine = tonumber(num) -- 986
		end -- 986
		lineMap[current] = lastLine -- 987
		if row <= lastLine and not targetRow then -- 988
			targetRow = current -- 989
			break -- 990
		end -- 988
		current = current + 1 -- 991
	end -- 984
	targetRow = current -- 992
	if targetLine and targetRow then -- 993
		return luaCodes, targetLine, targetRow, lineMap -- 994
	else -- 996
		return nil -- 996
	end -- 993
end -- 976
HttpServer:postSchedule("/check", function(req) -- 998
	do -- 999
		local _type_0 = type(req) -- 999
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 999
		if _tab_0 then -- 999
			local file -- 999
			do -- 999
				local _obj_0 = req.body -- 999
				local _type_1 = type(_obj_0) -- 999
				if "table" == _type_1 or "userdata" == _type_1 then -- 999
					file = _obj_0.file -- 999
				end -- 999
			end -- 999
			local content -- 999
			do -- 999
				local _obj_0 = req.body -- 999
				local _type_1 = type(_obj_0) -- 999
				if "table" == _type_1 or "userdata" == _type_1 then -- 999
					content = _obj_0.content -- 999
				end -- 999
			end -- 999
			if file ~= nil and content ~= nil then -- 999
				local ext = Path:getExt(file) -- 1000
				if "tl" == ext then -- 1001
					local searchPath = getSearchPath(file) -- 1002
					do -- 1003
						local isTIC80 = CheckTIC80Code(content) -- 1003
						if isTIC80 then -- 1003
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1004
						end -- 1003
					end -- 1003
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 1005
					return { -- 1006
						success = success, -- 1006
						info = info -- 1006
					} -- 1006
				elseif "lua" == ext then -- 1007
					do -- 1008
						local isTIC80 = CheckTIC80Code(content) -- 1008
						if isTIC80 then -- 1008
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1009
						end -- 1008
					end -- 1008
					return luaCheck(file, content) -- 1010
				elseif "yue" == ext then -- 1011
					local luaCodes, info = yueCheck(file, content, false) -- 1012
					local success = luaCodes ~= nil -- 1013
					if luaCodes then -- 1014
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 1015
						do -- 1016
							local _tab_1 = { } -- 1016
							local _idx_0 = #_tab_1 + 1 -- 1016
							for _index_0 = 1, #info do -- 1016
								local _value_0 = info[_index_0] -- 1016
								_tab_1[_idx_0] = _value_0 -- 1016
								_idx_0 = _idx_0 + 1 -- 1016
							end -- 1016
							local _idx_1 = #_tab_1 + 1 -- 1016
							for _index_0 = 1, #luaInfo do -- 1016
								local _value_0 = luaInfo[_index_0] -- 1016
								_tab_1[_idx_1] = _value_0 -- 1016
								_idx_1 = _idx_1 + 1 -- 1016
							end -- 1016
							info = _tab_1 -- 1016
						end -- 1016
						success = success and luaSuccess -- 1017
					end -- 1014
					if #info > 0 then -- 1018
						return { -- 1019
							success = success, -- 1019
							info = info -- 1019
						} -- 1019
					else -- 1021
						return { -- 1021
							success = success -- 1021
						} -- 1021
					end -- 1018
				elseif "xml" == ext then -- 1022
					local success, result = xml.check(content) -- 1023
					if success then -- 1024
						local info -- 1025
						success, info = luaCheckWithLineInfo(file, result) -- 1025
						if #info > 0 then -- 1026
							return { -- 1027
								success = success, -- 1027
								info = info -- 1027
							} -- 1027
						else -- 1029
							return { -- 1029
								success = success -- 1029
							} -- 1029
						end -- 1026
					else -- 1031
						local info -- 1031
						do -- 1031
							local _accum_0 = { } -- 1031
							local _len_0 = 1 -- 1031
							for _index_0 = 1, #result do -- 1031
								local _des_0 = result[_index_0] -- 1031
								local row, err = _des_0[1], _des_0[2] -- 1031
								_accum_0[_len_0] = { -- 1032
									"syntax", -- 1032
									file, -- 1032
									row, -- 1032
									0, -- 1032
									err -- 1032
								} -- 1032
								_len_0 = _len_0 + 1 -- 1032
							end -- 1031
							info = _accum_0 -- 1031
						end -- 1031
						return { -- 1033
							success = false, -- 1033
							info = info -- 1033
						} -- 1033
					end -- 1024
				end -- 1001
			end -- 999
		end -- 999
	end -- 999
	return { -- 998
		success = true -- 998
	} -- 998
end) -- 998
HttpServer:post("/body/parse", function(req) -- 1035
	do -- 1036
		local _type_0 = type(req) -- 1036
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1036
		if _tab_0 then -- 1036
			local file -- 1036
			do -- 1036
				local _obj_0 = req.body -- 1036
				local _type_1 = type(_obj_0) -- 1036
				if "table" == _type_1 or "userdata" == _type_1 then -- 1036
					file = _obj_0.file -- 1036
				end -- 1036
			end -- 1036
			local content -- 1036
			do -- 1036
				local _obj_0 = req.body -- 1036
				local _type_1 = type(_obj_0) -- 1036
				if "table" == _type_1 or "userdata" == _type_1 then -- 1036
					content = _obj_0.content -- 1036
				end -- 1036
			end -- 1036
			if file ~= nil and content ~= nil then -- 1036
				if not (file:sub(-6) == ".b.lua") then -- 1037
					return { -- 1038
						success = false, -- 1038
						phase = "request", -- 1038
						message = "only .b.lua files can be converted" -- 1038
					} -- 1038
				end -- 1037
				local loader, err = load("_ENV = {}\n" .. content) -- 1039
				if not loader then -- 1040
					return { -- 1041
						success = false, -- 1041
						phase = "parse", -- 1041
						message = tostring(err) -- 1041
					} -- 1041
				end -- 1040
				local ok, data = pcall(loader) -- 1042
				if not ok then -- 1043
					return { -- 1044
						success = false, -- 1044
						phase = "execute", -- 1044
						message = tostring(data) -- 1044
					} -- 1044
				end -- 1043
				if not ("table" == type(data) and data[1] == "Array") then -- 1045
					return { -- 1046
						success = false, -- 1046
						phase = "validate", -- 1046
						message = "body lua root must be {\"Array\", ...}" -- 1046
					} -- 1046
				end -- 1045
				local text, jsonErr = json.encode(data, false, true) -- 1047
				if not text then -- 1048
					return { -- 1049
						success = false, -- 1049
						phase = "encode", -- 1049
						message = tostring(jsonErr) -- 1049
					} -- 1049
				end -- 1048
				return { -- 1050
					success = true, -- 1050
					json = text -- 1050
				} -- 1050
			end -- 1036
		end -- 1036
	end -- 1036
	return { -- 1035
		success = false, -- 1035
		phase = "request", -- 1035
		message = "invalid request" -- 1035
	} -- 1035
end) -- 1035
local updateInferedDesc -- 1052
updateInferedDesc = function(infered) -- 1052
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1053
		return -- 1053
	end -- 1053
	local key, row = infered.key, infered.row -- 1054
	local codes = Content:loadAsync(key) -- 1055
	if codes then -- 1055
		local comments = { } -- 1056
		local line = 0 -- 1057
		local skipping = false -- 1058
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1059
			line = line + 1 -- 1060
			if line >= row then -- 1061
				break -- 1061
			end -- 1061
			if lineCode:match("^%s*%-%- @") then -- 1062
				skipping = true -- 1063
				goto _continue_0 -- 1064
			end -- 1062
			local result = lineCode:match("^%s*%-%- (.+)") -- 1065
			if result then -- 1065
				if not skipping then -- 1066
					comments[#comments + 1] = result -- 1066
				end -- 1066
			elseif #comments > 0 then -- 1067
				comments = { } -- 1068
				skipping = false -- 1069
			end -- 1065
			::_continue_0:: -- 1060
		end -- 1059
		infered.doc = table.concat(comments, "\n") -- 1070
	end -- 1055
end -- 1052
HttpServer:postSchedule("/infer", function(req) -- 1072
	do -- 1073
		local _type_0 = type(req) -- 1073
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1073
		if _tab_0 then -- 1073
			local lang -- 1073
			do -- 1073
				local _obj_0 = req.body -- 1073
				local _type_1 = type(_obj_0) -- 1073
				if "table" == _type_1 or "userdata" == _type_1 then -- 1073
					lang = _obj_0.lang -- 1073
				end -- 1073
			end -- 1073
			local file -- 1073
			do -- 1073
				local _obj_0 = req.body -- 1073
				local _type_1 = type(_obj_0) -- 1073
				if "table" == _type_1 or "userdata" == _type_1 then -- 1073
					file = _obj_0.file -- 1073
				end -- 1073
			end -- 1073
			local content -- 1073
			do -- 1073
				local _obj_0 = req.body -- 1073
				local _type_1 = type(_obj_0) -- 1073
				if "table" == _type_1 or "userdata" == _type_1 then -- 1073
					content = _obj_0.content -- 1073
				end -- 1073
			end -- 1073
			local line -- 1073
			do -- 1073
				local _obj_0 = req.body -- 1073
				local _type_1 = type(_obj_0) -- 1073
				if "table" == _type_1 or "userdata" == _type_1 then -- 1073
					line = _obj_0.line -- 1073
				end -- 1073
			end -- 1073
			local row -- 1073
			do -- 1073
				local _obj_0 = req.body -- 1073
				local _type_1 = type(_obj_0) -- 1073
				if "table" == _type_1 or "userdata" == _type_1 then -- 1073
					row = _obj_0.row -- 1073
				end -- 1073
			end -- 1073
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1073
				local searchPath = getSearchPath(file) -- 1074
				if "tl" == lang or "lua" == lang then -- 1075
					if CheckTIC80Code(content) then -- 1076
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1077
					end -- 1076
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1078
					if (infered ~= nil) then -- 1079
						updateInferedDesc(infered) -- 1080
						return { -- 1081
							success = true, -- 1081
							infered = infered -- 1081
						} -- 1081
					end -- 1079
				elseif "yue" == lang then -- 1082
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1083
					if not luaCodes then -- 1084
						return { -- 1084
							success = false -- 1084
						} -- 1084
					end -- 1084
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1085
					if (infered ~= nil) then -- 1086
						local col -- 1087
						file, row, col = infered.file, infered.row, infered.col -- 1087
						if file == "" and row > 0 and col > 0 then -- 1088
							infered.row = lineMap[row] or 0 -- 1089
							infered.col = 0 -- 1090
						end -- 1088
						updateInferedDesc(infered) -- 1091
						return { -- 1092
							success = true, -- 1092
							infered = infered -- 1092
						} -- 1092
					end -- 1086
				end -- 1075
			end -- 1073
		end -- 1073
	end -- 1073
	return { -- 1072
		success = false -- 1072
	} -- 1072
end) -- 1072
local _anon_func_3 = function(doc) -- 1153
	local _accum_0 = { } -- 1153
	local _len_0 = 1 -- 1153
	local _list_0 = doc.params -- 1153
	for _index_0 = 1, #_list_0 do -- 1153
		local param = _list_0[_index_0] -- 1153
		_accum_0[_len_0] = param.name -- 1153
		_len_0 = _len_0 + 1 -- 1153
	end -- 1153
	return _accum_0 -- 1153
end -- 1153
local getParamDocs -- 1094
getParamDocs = function(signatures) -- 1094
	if not (signatures and #signatures > 0) then -- 1095
		return nil -- 1095
	end -- 1095
	local docs = { } -- 1096
	do -- 1097
		local codes = Content:loadAsync(signatures[1].file) -- 1097
		if codes then -- 1097
			local comments = { } -- 1098
			local params = { } -- 1099
			local line = 0 -- 1100
			local returnType = nil -- 1101
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1102
				line = line + 1 -- 1103
				local needBreak = true -- 1104
				for i, _des_0 in ipairs(signatures) do -- 1105
					local row = _des_0.row -- 1105
					if line >= row and not (docs[i] ~= nil) then -- 1106
						if #comments > 0 or #params > 0 or returnType then -- 1107
							docs[i] = { -- 1109
								doc = table.concat(comments, "  \n"), -- 1109
								returnType = returnType -- 1110
							} -- 1108
							if #params > 0 then -- 1112
								docs[i].params = params -- 1112
							end -- 1112
						else -- 1114
							docs[i] = false -- 1114
						end -- 1107
					end -- 1106
					if not docs[i] then -- 1115
						needBreak = false -- 1115
					end -- 1115
				end -- 1105
				if needBreak then -- 1116
					break -- 1116
				end -- 1116
				local result = lineCode:match("%s*%-%- (.+)") -- 1117
				if result then -- 1117
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1118
					if not name then -- 1119
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1120
					end -- 1119
					if name then -- 1121
						local pname = name -- 1122
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1123
							pname = pname .. "?" -- 1123
						end -- 1123
						params[#params + 1] = { -- 1125
							name = tostring(pname) .. ": " .. tostring(typ), -- 1125
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1126
						} -- 1124
					else -- 1129
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1129
						if typ then -- 1129
							if returnType then -- 1130
								returnType = returnType .. ", " .. typ -- 1131
							else -- 1133
								returnType = typ -- 1133
							end -- 1130
							result = result:gsub("@return", "**return:**") -- 1134
						end -- 1129
						comments[#comments + 1] = result -- 1135
					end -- 1121
				elseif #comments > 0 then -- 1136
					comments = { } -- 1137
					params = { } -- 1138
					returnType = nil -- 1139
				end -- 1117
			end -- 1102
		end -- 1097
	end -- 1097
	local results = { } -- 1140
	for i, signature in ipairs(signatures) do -- 1141
		local item = { -- 1143
			desc = signature.desc, -- 1143
			doc = "", -- 1144
			file = signature.file, -- 1145
			row = signature.row, -- 1146
			col = signature.col -- 1147
		} -- 1142
		do -- 1149
			local doc = docs[i] -- 1149
			if doc then -- 1149
				item.doc = doc.doc -- 1150
				if doc.params then -- 1151
					item.params = doc.params -- 1152
					item.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1153
				elseif doc.returnType then -- 1154
					item.desc = "function()" -- 1155
				end -- 1151
				if doc.returnType then -- 1156
					item.desc = item.desc .. ": " .. tostring(doc.returnType) -- 1156
				end -- 1156
			end -- 1149
		end -- 1149
		results[#results + 1] = item -- 1157
	end -- 1141
	return results -- 1158
end -- 1094
HttpServer:postSchedule("/signature", function(req) -- 1160
	do -- 1161
		local _type_0 = type(req) -- 1161
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1161
		if _tab_0 then -- 1161
			local lang -- 1161
			do -- 1161
				local _obj_0 = req.body -- 1161
				local _type_1 = type(_obj_0) -- 1161
				if "table" == _type_1 or "userdata" == _type_1 then -- 1161
					lang = _obj_0.lang -- 1161
				end -- 1161
			end -- 1161
			local file -- 1161
			do -- 1161
				local _obj_0 = req.body -- 1161
				local _type_1 = type(_obj_0) -- 1161
				if "table" == _type_1 or "userdata" == _type_1 then -- 1161
					file = _obj_0.file -- 1161
				end -- 1161
			end -- 1161
			local content -- 1161
			do -- 1161
				local _obj_0 = req.body -- 1161
				local _type_1 = type(_obj_0) -- 1161
				if "table" == _type_1 or "userdata" == _type_1 then -- 1161
					content = _obj_0.content -- 1161
				end -- 1161
			end -- 1161
			local line -- 1161
			do -- 1161
				local _obj_0 = req.body -- 1161
				local _type_1 = type(_obj_0) -- 1161
				if "table" == _type_1 or "userdata" == _type_1 then -- 1161
					line = _obj_0.line -- 1161
				end -- 1161
			end -- 1161
			local row -- 1161
			do -- 1161
				local _obj_0 = req.body -- 1161
				local _type_1 = type(_obj_0) -- 1161
				if "table" == _type_1 or "userdata" == _type_1 then -- 1161
					row = _obj_0.row -- 1161
				end -- 1161
			end -- 1161
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1161
				local searchPath = getSearchPath(file) -- 1162
				if "tl" == lang or "lua" == lang then -- 1163
					if CheckTIC80Code(content) then -- 1164
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1165
					end -- 1164
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1166
					if signatures then -- 1166
						signatures = getParamDocs(signatures) -- 1167
						if signatures then -- 1167
							return { -- 1168
								success = true, -- 1168
								signatures = signatures -- 1168
							} -- 1168
						end -- 1167
					end -- 1166
				elseif "yue" == lang then -- 1169
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1170
					if not luaCodes then -- 1171
						return { -- 1171
							success = false -- 1171
						} -- 1171
					end -- 1171
					do -- 1172
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1172
						if chainOp then -- 1172
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1173
							if withVar then -- 1173
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1174
							end -- 1173
						end -- 1172
					end -- 1172
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1175
					if signatures then -- 1175
						signatures = getParamDocs(signatures) -- 1176
						if signatures then -- 1176
							return { -- 1177
								success = true, -- 1177
								signatures = signatures -- 1177
							} -- 1177
						end -- 1176
					else -- 1178
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1178
						if signatures then -- 1178
							signatures = getParamDocs(signatures) -- 1179
							if signatures then -- 1179
								return { -- 1180
									success = true, -- 1180
									signatures = signatures -- 1180
								} -- 1180
							end -- 1179
						end -- 1178
					end -- 1175
				end -- 1163
			end -- 1161
		end -- 1161
	end -- 1161
	return { -- 1160
		success = false -- 1160
	} -- 1160
end) -- 1160
local luaKeywords = { -- 1183
	'and', -- 1183
	'break', -- 1184
	'do', -- 1185
	'else', -- 1186
	'elseif', -- 1187
	'end', -- 1188
	'false', -- 1189
	'for', -- 1190
	'function', -- 1191
	'goto', -- 1192
	'if', -- 1193
	'in', -- 1194
	'local', -- 1195
	'nil', -- 1196
	'not', -- 1197
	'or', -- 1198
	'repeat', -- 1199
	'return', -- 1200
	'then', -- 1201
	'true', -- 1202
	'until', -- 1203
	'while' -- 1204
} -- 1182
local tealKeywords = { -- 1208
	'record', -- 1208
	'as', -- 1209
	'is', -- 1210
	'type', -- 1211
	'embed', -- 1212
	'enum', -- 1213
	'global', -- 1214
	'any', -- 1215
	'boolean', -- 1216
	'integer', -- 1217
	'number', -- 1218
	'string', -- 1219
	'thread' -- 1220
} -- 1207
local yueKeywords = { -- 1224
	"and", -- 1224
	"break", -- 1225
	"do", -- 1226
	"else", -- 1227
	"elseif", -- 1228
	"false", -- 1229
	"for", -- 1230
	"goto", -- 1231
	"if", -- 1232
	"in", -- 1233
	"local", -- 1234
	"nil", -- 1235
	"not", -- 1236
	"or", -- 1237
	"repeat", -- 1238
	"return", -- 1239
	"then", -- 1240
	"true", -- 1241
	"until", -- 1242
	"while", -- 1243
	"as", -- 1244
	"class", -- 1245
	"continue", -- 1246
	"export", -- 1247
	"extends", -- 1248
	"from", -- 1249
	"global", -- 1250
	"import", -- 1251
	"macro", -- 1252
	"switch", -- 1253
	"try", -- 1254
	"unless", -- 1255
	"using", -- 1256
	"when", -- 1257
	"with" -- 1258
} -- 1223
local _anon_func_4 = function(f) -- 1294
	local _val_0 = Path:getExt(f) -- 1294
	return "ttf" == _val_0 or "otf" == _val_0 -- 1294
end -- 1294
local _anon_func_5 = function(suggestions) -- 1320
	local _tbl_0 = { } -- 1320
	for _index_0 = 1, #suggestions do -- 1320
		local item = suggestions[_index_0] -- 1320
		_tbl_0[item[1] .. item[2]] = item -- 1320
	end -- 1320
	return _tbl_0 -- 1320
end -- 1320
HttpServer:postSchedule("/complete", function(req) -- 1261
	do -- 1262
		local _type_0 = type(req) -- 1262
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1262
		if _tab_0 then -- 1262
			local lang -- 1262
			do -- 1262
				local _obj_0 = req.body -- 1262
				local _type_1 = type(_obj_0) -- 1262
				if "table" == _type_1 or "userdata" == _type_1 then -- 1262
					lang = _obj_0.lang -- 1262
				end -- 1262
			end -- 1262
			local file -- 1262
			do -- 1262
				local _obj_0 = req.body -- 1262
				local _type_1 = type(_obj_0) -- 1262
				if "table" == _type_1 or "userdata" == _type_1 then -- 1262
					file = _obj_0.file -- 1262
				end -- 1262
			end -- 1262
			local content -- 1262
			do -- 1262
				local _obj_0 = req.body -- 1262
				local _type_1 = type(_obj_0) -- 1262
				if "table" == _type_1 or "userdata" == _type_1 then -- 1262
					content = _obj_0.content -- 1262
				end -- 1262
			end -- 1262
			local line -- 1262
			do -- 1262
				local _obj_0 = req.body -- 1262
				local _type_1 = type(_obj_0) -- 1262
				if "table" == _type_1 or "userdata" == _type_1 then -- 1262
					line = _obj_0.line -- 1262
				end -- 1262
			end -- 1262
			local row -- 1262
			do -- 1262
				local _obj_0 = req.body -- 1262
				local _type_1 = type(_obj_0) -- 1262
				if "table" == _type_1 or "userdata" == _type_1 then -- 1262
					row = _obj_0.row -- 1262
				end -- 1262
			end -- 1262
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1262
				local searchPath = getSearchPath(file) -- 1263
				repeat -- 1264
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1265
					if lang == "yue" then -- 1266
						if not item then -- 1267
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1267
						end -- 1267
						if not item then -- 1268
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1268
						end -- 1268
					end -- 1266
					local searchType = nil -- 1269
					if not item then -- 1270
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1271
						if lang == "yue" then -- 1272
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1273
						end -- 1272
						if (item ~= nil) then -- 1274
							searchType = "Image" -- 1274
						end -- 1274
					end -- 1270
					if not item then -- 1275
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1276
						if lang == "yue" then -- 1277
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1278
						end -- 1277
						if (item ~= nil) then -- 1279
							searchType = "Font" -- 1279
						end -- 1279
					end -- 1275
					if not item then -- 1280
						break -- 1280
					end -- 1280
					local searchPaths = Content.searchPaths -- 1281
					local _list_0 = getSearchFolders(file) -- 1282
					for _index_0 = 1, #_list_0 do -- 1282
						local folder = _list_0[_index_0] -- 1282
						searchPaths[#searchPaths + 1] = folder -- 1283
					end -- 1282
					if searchType then -- 1284
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1284
					end -- 1284
					local tokens -- 1285
					do -- 1285
						local _accum_0 = { } -- 1285
						local _len_0 = 1 -- 1285
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1285
							_accum_0[_len_0] = mod -- 1285
							_len_0 = _len_0 + 1 -- 1285
						end -- 1285
						tokens = _accum_0 -- 1285
					end -- 1285
					local suggestions = { } -- 1286
					for _index_0 = 1, #searchPaths do -- 1287
						local path = searchPaths[_index_0] -- 1287
						local sPath = Path(path, table.unpack(tokens)) -- 1288
						if not Content:exist(sPath) then -- 1289
							goto _continue_0 -- 1289
						end -- 1289
						if searchType == "Font" then -- 1290
							local fontPath = Path(sPath, "Font") -- 1291
							if Content:exist(fontPath) then -- 1292
								local _list_1 = Content:getFiles(fontPath) -- 1293
								for _index_1 = 1, #_list_1 do -- 1293
									local f = _list_1[_index_1] -- 1293
									if _anon_func_4(f) then -- 1294
										if "." == f:sub(1, 1) then -- 1295
											goto _continue_1 -- 1295
										end -- 1295
										suggestions[#suggestions + 1] = { -- 1296
											Path:getName(f), -- 1296
											"font", -- 1296
											"field" -- 1296
										} -- 1296
									end -- 1294
									::_continue_1:: -- 1294
								end -- 1293
							end -- 1292
						end -- 1290
						local _list_1 = Content:getFiles(sPath) -- 1297
						for _index_1 = 1, #_list_1 do -- 1297
							local f = _list_1[_index_1] -- 1297
							if "Image" == searchType then -- 1298
								do -- 1299
									local _exp_0 = Path:getExt(f) -- 1299
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1299
										if "." == f:sub(1, 1) then -- 1300
											goto _continue_2 -- 1300
										end -- 1300
										suggestions[#suggestions + 1] = { -- 1301
											f, -- 1301
											"image", -- 1301
											"field" -- 1301
										} -- 1301
									end -- 1299
								end -- 1299
								goto _continue_2 -- 1302
							elseif "Font" == searchType then -- 1303
								do -- 1304
									local _exp_0 = Path:getExt(f) -- 1304
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1304
										if "." == f:sub(1, 1) then -- 1305
											goto _continue_2 -- 1305
										end -- 1305
										suggestions[#suggestions + 1] = { -- 1306
											f, -- 1306
											"font", -- 1306
											"field" -- 1306
										} -- 1306
									end -- 1304
								end -- 1304
								goto _continue_2 -- 1307
							end -- 1298
							local _exp_0 = Path:getExt(f) -- 1308
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1308
								local name = Path:getName(f) -- 1309
								if "d" == Path:getExt(name) then -- 1310
									goto _continue_2 -- 1310
								end -- 1310
								if "." == name:sub(1, 1) then -- 1311
									goto _continue_2 -- 1311
								end -- 1311
								suggestions[#suggestions + 1] = { -- 1312
									name, -- 1312
									"module", -- 1312
									"field" -- 1312
								} -- 1312
							end -- 1308
							::_continue_2:: -- 1298
						end -- 1297
						local _list_2 = Content:getDirs(sPath) -- 1313
						for _index_1 = 1, #_list_2 do -- 1313
							local dir = _list_2[_index_1] -- 1313
							if "." == dir:sub(1, 1) then -- 1314
								goto _continue_3 -- 1314
							end -- 1314
							suggestions[#suggestions + 1] = { -- 1315
								dir, -- 1315
								"folder", -- 1315
								"variable" -- 1315
							} -- 1315
							::_continue_3:: -- 1314
						end -- 1313
						::_continue_0:: -- 1288
					end -- 1287
					if item == "" and not searchType then -- 1316
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1317
						for _index_0 = 1, #_list_1 do -- 1317
							local _des_0 = _list_1[_index_0] -- 1317
							local name = _des_0[1] -- 1317
							suggestions[#suggestions + 1] = { -- 1318
								name, -- 1318
								"dora module", -- 1318
								"function" -- 1318
							} -- 1318
						end -- 1317
					end -- 1316
					if #suggestions > 0 then -- 1319
						do -- 1320
							local _accum_0 = { } -- 1320
							local _len_0 = 1 -- 1320
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1320
								_accum_0[_len_0] = v -- 1320
								_len_0 = _len_0 + 1 -- 1320
							end -- 1320
							suggestions = _accum_0 -- 1320
						end -- 1320
						return { -- 1321
							success = true, -- 1321
							suggestions = suggestions -- 1321
						} -- 1321
					else -- 1323
						return { -- 1323
							success = false -- 1323
						} -- 1323
					end -- 1319
				until true -- 1264
				if "tl" == lang or "lua" == lang then -- 1325
					do -- 1326
						local isTIC80 = CheckTIC80Code(content) -- 1326
						if isTIC80 then -- 1326
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1327
						end -- 1326
					end -- 1326
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1328
					if not line:match("[%.:]$") then -- 1329
						local checkSet -- 1330
						do -- 1330
							local _tbl_0 = { } -- 1330
							for _index_0 = 1, #suggestions do -- 1330
								local _des_0 = suggestions[_index_0] -- 1330
								local name = _des_0[1] -- 1330
								_tbl_0[name] = true -- 1330
							end -- 1330
							checkSet = _tbl_0 -- 1330
						end -- 1330
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1331
						for _index_0 = 1, #_list_0 do -- 1331
							local item = _list_0[_index_0] -- 1331
							if not checkSet[item[1]] then -- 1332
								suggestions[#suggestions + 1] = item -- 1332
							end -- 1332
						end -- 1331
						for _index_0 = 1, #luaKeywords do -- 1333
							local word = luaKeywords[_index_0] -- 1333
							suggestions[#suggestions + 1] = { -- 1334
								word, -- 1334
								"keyword", -- 1334
								"keyword" -- 1334
							} -- 1334
						end -- 1333
						if lang == "tl" then -- 1335
							for _index_0 = 1, #tealKeywords do -- 1336
								local word = tealKeywords[_index_0] -- 1336
								suggestions[#suggestions + 1] = { -- 1337
									word, -- 1337
									"keyword", -- 1337
									"keyword" -- 1337
								} -- 1337
							end -- 1336
						end -- 1335
					end -- 1329
					if #suggestions > 0 then -- 1338
						return { -- 1339
							success = true, -- 1339
							suggestions = suggestions -- 1339
						} -- 1339
					end -- 1338
				elseif "yue" == lang then -- 1340
					local suggestions = { } -- 1341
					local gotGlobals = false -- 1342
					do -- 1343
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1343
						if luaCodes then -- 1343
							gotGlobals = true -- 1344
							do -- 1345
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1345
								if chainOp then -- 1345
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1346
									if not withVar then -- 1347
										return { -- 1347
											success = false -- 1347
										} -- 1347
									end -- 1347
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1348
								elseif line:match("^([%.\\])$") then -- 1349
									return { -- 1350
										success = false -- 1350
									} -- 1350
								end -- 1345
							end -- 1345
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1351
							for _index_0 = 1, #_list_0 do -- 1351
								local item = _list_0[_index_0] -- 1351
								suggestions[#suggestions + 1] = item -- 1351
							end -- 1351
							if #suggestions == 0 then -- 1352
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1353
								for _index_0 = 1, #_list_1 do -- 1353
									local item = _list_1[_index_0] -- 1353
									suggestions[#suggestions + 1] = item -- 1353
								end -- 1353
							end -- 1352
						end -- 1343
					end -- 1343
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1354
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
						if not gotGlobals then -- 1358
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1359
							for _index_0 = 1, #_list_1 do -- 1359
								local item = _list_1[_index_0] -- 1359
								if not checkSet[item[1]] then -- 1360
									suggestions[#suggestions + 1] = item -- 1360
								end -- 1360
							end -- 1359
						end -- 1358
						for _index_0 = 1, #yueKeywords do -- 1361
							local word = yueKeywords[_index_0] -- 1361
							if not checkSet[word] then -- 1362
								suggestions[#suggestions + 1] = { -- 1363
									word, -- 1363
									"keyword", -- 1363
									"keyword" -- 1363
								} -- 1363
							end -- 1362
						end -- 1361
					end -- 1354
					if #suggestions > 0 then -- 1364
						return { -- 1365
							success = true, -- 1365
							suggestions = suggestions -- 1365
						} -- 1365
					end -- 1364
				elseif "xml" == lang then -- 1366
					local items = xml.complete(content) -- 1367
					if #items > 0 then -- 1368
						local suggestions -- 1369
						do -- 1369
							local _accum_0 = { } -- 1369
							local _len_0 = 1 -- 1369
							for _index_0 = 1, #items do -- 1369
								local _des_0 = items[_index_0] -- 1369
								local label, insertText = _des_0[1], _des_0[2] -- 1369
								_accum_0[_len_0] = { -- 1370
									label, -- 1370
									insertText, -- 1370
									"field" -- 1370
								} -- 1370
								_len_0 = _len_0 + 1 -- 1370
							end -- 1369
							suggestions = _accum_0 -- 1369
						end -- 1369
						return { -- 1371
							success = true, -- 1371
							suggestions = suggestions -- 1371
						} -- 1371
					end -- 1368
				end -- 1325
			end -- 1262
		end -- 1262
	end -- 1262
	return { -- 1261
		success = false -- 1261
	} -- 1261
end) -- 1261
local getUploadFilename -- 1373
getUploadFilename = function(req, multipartFilename) -- 1373
	local filename = req.params.name -- 1374
	if not (type(filename) == "string" and filename ~= "") then -- 1375
		filename = multipartFilename -- 1375
	end -- 1375
	if not (type(filename) == "string" and filename ~= "") then -- 1376
		return -- 1376
	end -- 1376
	if filename:sub(1, 1) == "/" or filename:sub(-1) == "/" or filename:find("//", 1, true) or filename:find("\\", 1, true) or filename:find(":", 1, true) or filename:find("\0", 1, true) then -- 1379
		return -- 1379
	end -- 1379
	local parts -- 1380
	do -- 1380
		local _accum_0 = { } -- 1380
		local _len_0 = 1 -- 1380
		for part in filename:gmatch("[^/]+") do -- 1380
			_accum_0[_len_0] = part -- 1380
			_len_0 = _len_0 + 1 -- 1380
		end -- 1380
		parts = _accum_0 -- 1380
	end -- 1380
	if #parts == 0 then -- 1381
		return -- 1381
	end -- 1381
	for _index_0 = 1, #parts do -- 1382
		local part = parts[_index_0] -- 1382
		if part == "." or part == ".." or part == "" then -- 1383
			return -- 1383
		end -- 1383
	end -- 1382
	return filename -- 1384
end -- 1373
HttpServer:upload("/upload", function(req, multipartFilename) -- 1388
	do -- 1389
		local _type_0 = type(req) -- 1389
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1389
		if _tab_0 then -- 1389
			local path -- 1389
			do -- 1389
				local _obj_0 = req.params -- 1389
				local _type_1 = type(_obj_0) -- 1389
				if "table" == _type_1 or "userdata" == _type_1 then -- 1389
					path = _obj_0.path -- 1389
				end -- 1389
			end -- 1389
			if path ~= nil then -- 1389
				local filename = getUploadFilename(req, multipartFilename) -- 1390
				if filename then -- 1390
					local uploadPath = Path(Content.writablePath, ".upload") -- 1391
					if not Content:exist(uploadPath) then -- 1392
						Content:mkdir(uploadPath) -- 1393
					end -- 1392
					local targetPath = Path(uploadPath, filename) -- 1394
					Content:mkdir(Path:getPath(targetPath)) -- 1395
					return targetPath -- 1396
				end -- 1390
			end -- 1389
		end -- 1389
	end -- 1389
	return nil -- 1388
end, function(req, file) -- 1397
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
				path = Path(Content.writablePath, path) -- 1399
				if Content:exist(path) then -- 1400
					local uploadPath = Path(Content.writablePath, ".upload") -- 1401
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1402
					Content:mkdir(Path:getPath(targetPath)) -- 1403
					if Content:move(file, targetPath) then -- 1404
						return true -- 1405
					end -- 1404
				end -- 1400
			end -- 1398
		end -- 1398
	end -- 1398
	return false -- 1397
end) -- 1386
HttpServer:post("/list", function(req) -- 1408
	do -- 1409
		local _type_0 = type(req) -- 1409
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1409
		if _tab_0 then -- 1409
			local path -- 1409
			do -- 1409
				local _obj_0 = req.body -- 1409
				local _type_1 = type(_obj_0) -- 1409
				if "table" == _type_1 or "userdata" == _type_1 then -- 1409
					path = _obj_0.path -- 1409
				end -- 1409
			end -- 1409
			if path ~= nil then -- 1409
				if Content:exist(path) then -- 1410
					local files = { } -- 1411
					local visitAssets -- 1412
					visitAssets = function(path, folder) -- 1412
						local dirs = Content:getDirs(path) -- 1413
						for _index_0 = 1, #dirs do -- 1414
							local dir = dirs[_index_0] -- 1414
							if dir:match("^%.") or dir == "node_modules" then -- 1415
								goto _continue_0 -- 1415
							end -- 1415
							local current -- 1416
							if folder == "" then -- 1416
								current = dir -- 1417
							else -- 1419
								current = Path(folder, dir) -- 1419
							end -- 1416
							files[#files + 1] = current -- 1420
							visitAssets(Path(path, dir), current) -- 1421
							::_continue_0:: -- 1415
						end -- 1414
						local fs = Content:getFiles(path) -- 1422
						for _index_0 = 1, #fs do -- 1423
							local f = fs[_index_0] -- 1423
							if (".DS_Store" == f) then -- 1424
								goto _continue_1 -- 1425
							end -- 1424
							if folder == "" then -- 1426
								files[#files + 1] = f -- 1427
							else -- 1429
								files[#files + 1] = Path(folder, f) -- 1429
							end -- 1426
							::_continue_1:: -- 1424
						end -- 1423
					end -- 1412
					visitAssets(path, "") -- 1430
					if #files == 0 then -- 1431
						files = nil -- 1431
					end -- 1431
					return { -- 1432
						success = true, -- 1432
						files = files -- 1432
					} -- 1432
				end -- 1410
			end -- 1409
		end -- 1409
	end -- 1409
	return { -- 1408
		success = false -- 1408
	} -- 1408
end) -- 1408
HttpServer:post("/info", function(req) -- 1434
	local Entry = require("Script.Dev.Entry") -- 1435
	local config = Entry.getConfig() -- 1436
	do -- 1437
		local _type_0 = type(req) -- 1437
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1437
		if _tab_0 then -- 1437
			local webIDETourCompleted -- 1437
			do -- 1437
				local _obj_0 = req.body -- 1437
				local _type_1 = type(_obj_0) -- 1437
				if "table" == _type_1 or "userdata" == _type_1 then -- 1437
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1437
				end -- 1437
			end -- 1437
			if webIDETourCompleted ~= nil then -- 1437
				config.webIDETourCompleted = webIDETourCompleted == true -- 1438
			end -- 1437
		end -- 1437
	end -- 1437
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1439
	local engineDev = Entry.getEngineDev() -- 1440
	Entry.connectWebIDE() -- 1441
	return { -- 1443
		platform = App.platform, -- 1443
		locale = App.locale, -- 1444
		version = App.version, -- 1445
		engineDev = engineDev, -- 1446
		webProfiler = webProfiler, -- 1447
		drawerWidth = drawerWidth, -- 1448
		webIDETourCompleted = webIDETourCompleted == true -- 1449
	} -- 1442
end) -- 1434
local ensureLLMConfigTable -- 1451
ensureLLMConfigTable = function() -- 1451
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1452
	if columns and #columns > 0 then -- 1453
		local expected = { -- 1455
			id = true, -- 1455
			name = true, -- 1456
			url = true, -- 1457
			model = true, -- 1458
			api_key = true, -- 1459
			context_window = true, -- 1460
			temperature = true, -- 1461
			max_tokens = true, -- 1462
			reasoning_effort = true, -- 1463
			custom_options = true, -- 1464
			supports_function_calling = true, -- 1465
			active = true, -- 1466
			created_at = true, -- 1467
			updated_at = true -- 1468
		} -- 1454
		local existing = { } -- 1470
		local valid = true -- 1471
		for _index_0 = 1, #columns do -- 1472
			local row = columns[_index_0] -- 1472
			local columnName = tostring(row[2]) -- 1473
			existing[columnName] = true -- 1474
			if not expected[columnName] then -- 1475
				valid = false -- 1476
				break -- 1477
			end -- 1475
		end -- 1472
		if valid then -- 1478
			if not existing.context_window then -- 1479
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1480
			end -- 1479
			if not existing.temperature then -- 1481
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1482
			end -- 1481
			if not existing.max_tokens then -- 1483
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 8192") -- 1484
			end -- 1483
			if not existing.reasoning_effort then -- 1485
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1486
			end -- 1485
			if not existing.custom_options then -- 1487
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1488
			end -- 1487
			if not existing.supports_function_calling then -- 1489
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN supports_function_calling INTEGER NOT NULL DEFAULT 1") -- 1490
			end -- 1489
		else -- 1492
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1492
		end -- 1478
	end -- 1453
	return DB:exec([[		CREATE TABLE IF NOT EXISTS LLMConfig(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT NOT NULL,
			url TEXT NOT NULL,
			model TEXT NOT NULL,
			api_key TEXT NOT NULL,
			context_window INTEGER NOT NULL DEFAULT 64000,
			temperature REAL NOT NULL DEFAULT 0.1,
			max_tokens INTEGER NOT NULL DEFAULT 8192,
			reasoning_effort TEXT NOT NULL DEFAULT '',
			custom_options TEXT NOT NULL DEFAULT '',
			supports_function_calling INTEGER NOT NULL DEFAULT 1,
			active INTEGER NOT NULL DEFAULT 1,
			created_at INTEGER,
			updated_at INTEGER
		);
	]]) -- 1493
end -- 1451
local normalizeContextWindow -- 1512
normalizeContextWindow = function(value) -- 1512
	local contextWindow = tonumber(value) -- 1513
	if contextWindow == nil or contextWindow < 64000 then -- 1514
		return 64000 -- 1515
	end -- 1514
	return math.max(64000, math.floor(contextWindow)) -- 1516
end -- 1512
local normalizeTemperature -- 1518
normalizeTemperature = function(value) -- 1518
	local temperature = tonumber(value) -- 1519
	if temperature == nil then -- 1520
		return 0.1 -- 1521
	end -- 1520
	return math.max(0, math.min(2, temperature)) -- 1522
end -- 1518
local normalizeMaxTokens -- 1524
normalizeMaxTokens = function(value) -- 1524
	local maxTokens = tonumber(value) -- 1525
	if maxTokens == nil or maxTokens < 1 then -- 1526
		return 8192 -- 1527
	end -- 1526
	return math.max(1, math.floor(maxTokens)) -- 1528
end -- 1524
local normalizeReasoningEffort -- 1530
normalizeReasoningEffort = function(value) -- 1530
	if value == nil then -- 1531
		return "" -- 1532
	end -- 1531
	local effort = tostring(value) -- 1533
	return effort:match("^%s*(.-)%s*$") or "" -- 1534
end -- 1530
local normalizeCustomOptions -- 1536
normalizeCustomOptions = function(value) -- 1536
	if value == nil then -- 1537
		return "" -- 1538
	end -- 1537
	local options = tostring(value) -- 1539
	options = options:match("^%s*(.-)%s*$") or "" -- 1540
	return options -- 1541
end -- 1536
local validateCustomOptions -- 1543
validateCustomOptions = function(value) -- 1543
	local options = normalizeCustomOptions(value) -- 1544
	if options == "" then -- 1545
		return true -- 1545
	end -- 1545
	if not options:match("^%s*{") then -- 1546
		return false -- 1546
	end -- 1546
	local decoded = json.decode(options) -- 1547
	return type(decoded) == "table" -- 1548
end -- 1543
HttpServer:post("/llm/list", function() -- 1550
	ensureLLMConfigTable() -- 1551
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1552
	local items -- 1556
	if rows and #rows > 0 then -- 1556
		local _accum_0 = { } -- 1557
		local _len_0 = 1 -- 1557
		for _index_0 = 1, #rows do -- 1557
			local _des_0 = rows[_index_0] -- 1557
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1557
			_accum_0[_len_0] = { -- 1558
				id = id, -- 1558
				name = name, -- 1558
				url = url, -- 1558
				model = model, -- 1558
				key = key, -- 1558
				contextWindow = normalizeContextWindow(contextWindow), -- 1558
				temperature = normalizeTemperature(temperature), -- 1558
				maxTokens = normalizeMaxTokens(maxTokens), -- 1558
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1558
				customOptions = normalizeCustomOptions(customOptions), -- 1558
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1558
			} -- 1558
			_len_0 = _len_0 + 1 -- 1558
		end -- 1557
		items = _accum_0 -- 1556
	end -- 1556
	return { -- 1559
		success = true, -- 1559
		items = items -- 1559
	} -- 1559
end) -- 1550
HttpServer:post("/llm/create", function(req) -- 1561
	ensureLLMConfigTable() -- 1562
	do -- 1563
		local _type_0 = type(req) -- 1563
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1563
		if _tab_0 then -- 1563
			local body = req.body -- 1563
			if body ~= nil then -- 1563
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1564
				local now = os.time() -- 1565
				if name == nil or url == nil or model == nil or key == nil then -- 1566
					return invalidArguments -- 1567
				end -- 1566
				contextWindow = normalizeContextWindow(contextWindow) -- 1568
				temperature = normalizeTemperature(temperature) -- 1569
				maxTokens = normalizeMaxTokens(maxTokens) -- 1570
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1571
				customOptions = normalizeCustomOptions(customOptions) -- 1572
				if not validateCustomOptions(customOptions) then -- 1573
					return { -- 1573
						success = false, -- 1573
						message = "customOptions must be a JSON object" -- 1573
					} -- 1573
				end -- 1573
				if supportsFunctionCalling == false then -- 1574
					supportsFunctionCalling = 0 -- 1574
				else -- 1574
					supportsFunctionCalling = 1 -- 1574
				end -- 1574
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1581
					tostring(name), -- 1581
					tostring(url), -- 1582
					tostring(model), -- 1583
					tostring(key), -- 1584
					contextWindow, -- 1585
					temperature, -- 1586
					maxTokens, -- 1587
					reasoningEffort, -- 1588
					customOptions, -- 1589
					supportsFunctionCalling, -- 1590
					1, -- 1591
					now, -- 1592
					now -- 1593
				}) -- 1575
				return { -- 1595
					success = affected >= 0 -- 1595
				} -- 1595
			end -- 1563
		end -- 1563
	end -- 1563
	return invalidArguments -- 1561
end) -- 1561
HttpServer:post("/llm/update", function(req) -- 1597
	ensureLLMConfigTable() -- 1598
	do -- 1599
		local _type_0 = type(req) -- 1599
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1599
		if _tab_0 then -- 1599
			local body = req.body -- 1599
			if body ~= nil then -- 1599
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1600
				local now = os.time() -- 1601
				id = tonumber(id) -- 1602
				if id == nil then -- 1603
					return invalidArguments -- 1603
				end -- 1603
				contextWindow = normalizeContextWindow(contextWindow) -- 1604
				temperature = normalizeTemperature(temperature) -- 1605
				maxTokens = normalizeMaxTokens(maxTokens) -- 1606
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1607
				customOptions = normalizeCustomOptions(customOptions) -- 1608
				if not validateCustomOptions(customOptions) then -- 1609
					return { -- 1609
						success = false, -- 1609
						message = "customOptions must be a JSON object" -- 1609
					} -- 1609
				end -- 1609
				if supportsFunctionCalling == false then -- 1610
					supportsFunctionCalling = 0 -- 1610
				else -- 1610
					supportsFunctionCalling = 1 -- 1610
				end -- 1610
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1615
					tostring(name), -- 1615
					tostring(url), -- 1616
					tostring(model), -- 1617
					tostring(key), -- 1618
					contextWindow, -- 1619
					temperature, -- 1620
					maxTokens, -- 1621
					reasoningEffort, -- 1622
					customOptions, -- 1623
					supportsFunctionCalling, -- 1624
					now, -- 1625
					id -- 1626
				}) -- 1611
				return { -- 1628
					success = affected >= 0 -- 1628
				} -- 1628
			end -- 1599
		end -- 1599
	end -- 1599
	return invalidArguments -- 1597
end) -- 1597
HttpServer:post("/llm/delete", function(req) -- 1630
	ensureLLMConfigTable() -- 1631
	do -- 1632
		local _type_0 = type(req) -- 1632
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1632
		if _tab_0 then -- 1632
			local id -- 1632
			do -- 1632
				local _obj_0 = req.body -- 1632
				local _type_1 = type(_obj_0) -- 1632
				if "table" == _type_1 or "userdata" == _type_1 then -- 1632
					id = _obj_0.id -- 1632
				end -- 1632
			end -- 1632
			if id ~= nil then -- 1632
				id = tonumber(id) -- 1633
				if id == nil then -- 1634
					return invalidArguments -- 1634
				end -- 1634
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1635
					id -- 1635
				}) -- 1635
				return { -- 1636
					success = affected >= 0 -- 1636
				} -- 1636
			end -- 1632
		end -- 1632
	end -- 1632
	return invalidArguments -- 1630
end) -- 1630
HttpServer:post("/local-agent/list", function() -- 1638
	return { -- 1639
		success = true, -- 1639
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1639
		items = AgentLocalAgent.listConfigs() -- 1639
	} -- 1639
end) -- 1638
HttpServer:post("/local-agent/save", function(req) -- 1641
	do -- 1642
		local _type_0 = type(req) -- 1642
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1642
		if _tab_0 then -- 1642
			local body = req.body -- 1642
			if body ~= nil then -- 1642
				return AgentLocalAgent.saveConfig(body) -- 1643
			end -- 1642
		end -- 1642
	end -- 1642
	return invalidArguments -- 1641
end) -- 1641
HttpServer:post("/local-agent/delete", function(req) -- 1645
	do -- 1646
		local _type_0 = type(req) -- 1646
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1646
		if _tab_0 then -- 1646
			local id -- 1646
			do -- 1646
				local _obj_0 = req.body -- 1646
				local _type_1 = type(_obj_0) -- 1646
				if "table" == _type_1 or "userdata" == _type_1 then -- 1646
					id = _obj_0.id -- 1646
				end -- 1646
			end -- 1646
			if id ~= nil then -- 1646
				return AgentLocalAgent.deleteConfig(id) -- 1647
			end -- 1646
		end -- 1646
	end -- 1646
	return invalidArguments -- 1645
end) -- 1645
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1649
	do -- 1650
		local _type_0 = type(req) -- 1650
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1650
		if _tab_0 then -- 1650
			local id -- 1650
			do -- 1650
				local _obj_0 = req.body -- 1650
				local _type_1 = type(_obj_0) -- 1650
				if "table" == _type_1 or "userdata" == _type_1 then -- 1650
					id = _obj_0.id -- 1650
				end -- 1650
			end -- 1650
			if id ~= nil then -- 1650
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1651
			end -- 1650
		end -- 1650
	end -- 1650
	return invalidArguments -- 1649
end) -- 1649
HttpServer:post("/stat", function(req) -- 1653
	do -- 1654
		local _type_0 = type(req) -- 1654
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1654
		if _tab_0 then -- 1654
			local path -- 1654
			do -- 1654
				local _obj_0 = req.body -- 1654
				local _type_1 = type(_obj_0) -- 1654
				if "table" == _type_1 or "userdata" == _type_1 then -- 1654
					path = _obj_0.path -- 1654
				end -- 1654
			end -- 1654
			if path ~= nil then -- 1654
				if not Content:exist(path) then -- 1655
					return { -- 1656
						success = false, -- 1656
						message = "target not existed" -- 1656
					} -- 1656
				end -- 1655
				if Content:isdir(path) then -- 1657
					return { -- 1658
						success = false, -- 1658
						message = "failed to stat a directory" -- 1658
					} -- 1658
				end -- 1657
				local size, isBinary = Content:getAttr(path) -- 1659
				if size then -- 1659
					return { -- 1660
						success = true, -- 1660
						size = size, -- 1660
						isBinary = isBinary -- 1660
					} -- 1660
				end -- 1659
			end -- 1654
		end -- 1654
	end -- 1654
	return { -- 1653
		success = false, -- 1653
		message = "failed to stat" -- 1653
	} -- 1653
end) -- 1653
HttpServer:post("/new", function(req) -- 1662
	do -- 1663
		local _type_0 = type(req) -- 1663
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1663
		if _tab_0 then -- 1663
			local path -- 1663
			do -- 1663
				local _obj_0 = req.body -- 1663
				local _type_1 = type(_obj_0) -- 1663
				if "table" == _type_1 or "userdata" == _type_1 then -- 1663
					path = _obj_0.path -- 1663
				end -- 1663
			end -- 1663
			local content -- 1663
			do -- 1663
				local _obj_0 = req.body -- 1663
				local _type_1 = type(_obj_0) -- 1663
				if "table" == _type_1 or "userdata" == _type_1 then -- 1663
					content = _obj_0.content -- 1663
				end -- 1663
			end -- 1663
			local folder -- 1663
			do -- 1663
				local _obj_0 = req.body -- 1663
				local _type_1 = type(_obj_0) -- 1663
				if "table" == _type_1 or "userdata" == _type_1 then -- 1663
					folder = _obj_0.folder -- 1663
				end -- 1663
			end -- 1663
			if path ~= nil and content ~= nil and folder ~= nil then -- 1663
				if Content:exist(path) then -- 1664
					return { -- 1665
						success = false, -- 1665
						message = "TargetExisted" -- 1665
					} -- 1665
				end -- 1664
				local parent = Path:getPath(path) -- 1666
				local files = Content:getFiles(parent) -- 1667
				if folder then -- 1668
					local name = Path:getFilename(path):lower() -- 1669
					for _index_0 = 1, #files do -- 1670
						local file = files[_index_0] -- 1670
						if name == Path:getFilename(file):lower() then -- 1671
							return { -- 1672
								success = false, -- 1672
								message = "TargetExisted" -- 1672
							} -- 1672
						end -- 1671
					end -- 1670
					if Content:mkdir(path) then -- 1673
						return { -- 1674
							success = true -- 1674
						} -- 1674
					end -- 1673
				else -- 1676
					local name = Path:getName(path):lower() -- 1676
					for _index_0 = 1, #files do -- 1677
						local file = files[_index_0] -- 1677
						if name == Path:getName(file):lower() then -- 1678
							local ext = Path:getExt(file) -- 1679
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1680
								goto _continue_0 -- 1681
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1682
								goto _continue_0 -- 1683
							end -- 1680
							return { -- 1684
								success = false, -- 1684
								message = "SourceExisted" -- 1684
							} -- 1684
						end -- 1678
						::_continue_0:: -- 1678
					end -- 1677
					if Content:save(path, content) then -- 1685
						return { -- 1686
							success = true -- 1686
						} -- 1686
					end -- 1685
				end -- 1668
			end -- 1663
		end -- 1663
	end -- 1663
	return { -- 1662
		success = false, -- 1662
		message = "Failed" -- 1662
	} -- 1662
end) -- 1662
local deleteAsset -- 1688
deleteAsset = function(path) -- 1688
	if not Content:exist(path) then -- 1689
		return false -- 1689
	end -- 1689
	local projectRoot -- 1690
	if Content:isdir(path) and isProjectRootDir(path) then -- 1690
		projectRoot = path -- 1690
	else -- 1690
		projectRoot = nil -- 1690
	end -- 1690
	local parent = Path:getPath(path) -- 1691
	local files = Content:getFiles(parent) -- 1692
	local name = Path:getName(path):lower() -- 1693
	local ext = Path:getExt(path) -- 1694
	for _index_0 = 1, #files do -- 1695
		local file = files[_index_0] -- 1695
		if name == Path:getName(file):lower() then -- 1696
			local _exp_0 = Path:getExt(file) -- 1697
			if "tl" == _exp_0 then -- 1697
				if ("vs" == ext) then -- 1697
					Content:remove(Path(parent, file)) -- 1698
				end -- 1697
			elseif "lua" == _exp_0 then -- 1699
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1699
					Content:remove(Path(parent, file)) -- 1700
				end -- 1699
			end -- 1697
		end -- 1696
	end -- 1695
	if Content:remove(path) then -- 1701
		if projectRoot then -- 1702
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1703
		end -- 1702
		return true -- 1704
	end -- 1701
	return false -- 1705
end -- 1688
local moveAsset -- 1707
moveAsset = function(old, new) -- 1707
	if not (Content:exist(old) and not Content:exist(new)) then -- 1708
		return false -- 1708
	end -- 1708
	local renamedDir = Content:isdir(old) -- 1709
	local parent = Path:getPath(new) -- 1710
	local files = Content:getFiles(parent) -- 1711
	if renamedDir then -- 1712
		local name = Path:getFilename(new):lower() -- 1713
		for _index_0 = 1, #files do -- 1714
			local file = files[_index_0] -- 1714
			if name == Path:getFilename(file):lower() then -- 1715
				return false -- 1716
			end -- 1715
		end -- 1714
	else -- 1718
		local name = Path:getName(new):lower() -- 1718
		local ext = Path:getExt(new) -- 1719
		for _index_0 = 1, #files do -- 1720
			local file = files[_index_0] -- 1720
			if name == Path:getName(file):lower() then -- 1721
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1722
					goto _continue_0 -- 1723
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1724
					goto _continue_0 -- 1725
				end -- 1722
				return false -- 1726
			end -- 1721
			::_continue_0:: -- 1721
		end -- 1720
	end -- 1712
	if not Content:move(old, new) then -- 1727
		return false -- 1727
	end -- 1727
	if renamedDir then -- 1728
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1729
	end -- 1728
	local newParent = Path:getPath(new) -- 1730
	parent = Path:getPath(old) -- 1731
	files = Content:getFiles(parent) -- 1732
	local newName = Path:getName(new) -- 1733
	local oldName = Path:getName(old) -- 1734
	local name = oldName:lower() -- 1735
	local ext = Path:getExt(old) -- 1736
	for _index_0 = 1, #files do -- 1737
		local file = files[_index_0] -- 1737
		if name == Path:getName(file):lower() then -- 1738
			local _exp_0 = Path:getExt(file) -- 1739
			if "tl" == _exp_0 then -- 1739
				if ("vs" == ext) then -- 1739
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1740
				end -- 1739
			elseif "lua" == _exp_0 then -- 1741
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1741
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1742
				end -- 1741
			end -- 1739
		end -- 1738
	end -- 1737
	return true -- 1743
end -- 1707
HttpServer:post("/delete", function(req) -- 1745
	do -- 1746
		local _type_0 = type(req) -- 1746
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1746
		if _tab_0 then -- 1746
			local path -- 1746
			do -- 1746
				local _obj_0 = req.body -- 1746
				local _type_1 = type(_obj_0) -- 1746
				if "table" == _type_1 or "userdata" == _type_1 then -- 1746
					path = _obj_0.path -- 1746
				end -- 1746
			end -- 1746
			if path ~= nil then -- 1746
				if deleteAsset(path) then -- 1747
					return { -- 1747
						success = true -- 1747
					} -- 1747
				end -- 1747
			end -- 1746
		end -- 1746
	end -- 1746
	return { -- 1745
		success = false -- 1745
	} -- 1745
end) -- 1745
HttpServer:post("/rename", function(req) -- 1749
	do -- 1750
		local _type_0 = type(req) -- 1750
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1750
		if _tab_0 then -- 1750
			local old -- 1750
			do -- 1750
				local _obj_0 = req.body -- 1750
				local _type_1 = type(_obj_0) -- 1750
				if "table" == _type_1 or "userdata" == _type_1 then -- 1750
					old = _obj_0.old -- 1750
				end -- 1750
			end -- 1750
			local new -- 1750
			do -- 1750
				local _obj_0 = req.body -- 1750
				local _type_1 = type(_obj_0) -- 1750
				if "table" == _type_1 or "userdata" == _type_1 then -- 1750
					new = _obj_0.new -- 1750
				end -- 1750
			end -- 1750
			if old ~= nil and new ~= nil then -- 1750
				if moveAsset(old, new) then -- 1751
					return { -- 1751
						success = true -- 1751
					} -- 1751
				end -- 1751
			end -- 1750
		end -- 1750
	end -- 1750
	return { -- 1749
		success = false -- 1749
	} -- 1749
end) -- 1749
local normalizeAssetPaths -- 1753
normalizeAssetPaths = function(paths) -- 1753
	if not (type(paths) == "table") then -- 1754
		return nil -- 1754
	end -- 1754
	local unique = { } -- 1755
	local candidates = { } -- 1756
	for _index_0 = 1, #paths do -- 1757
		local path = paths[_index_0] -- 1757
		if not (type(path) == "string") then -- 1758
			return nil -- 1758
		end -- 1758
		local relative = relativeToRoot(path, Content.writablePath) -- 1759
		if relative == nil or relative == "" or not Content:exist(path) then -- 1760
			return nil -- 1760
		end -- 1760
		if not unique[path] then -- 1761
			unique[path] = true -- 1762
			candidates[#candidates + 1] = path -- 1763
		end -- 1761
	end -- 1757
	table.sort(candidates, function(a, b) -- 1764
		return #a < #b -- 1764
	end) -- 1764
	local result = { } -- 1765
	for _index_0 = 1, #candidates do -- 1766
		local path = candidates[_index_0] -- 1766
		local contained = false -- 1767
		for _index_1 = 1, #result do -- 1768
			local parent = result[_index_1] -- 1768
			if relativeToRoot(path, parent) ~= nil then -- 1769
				contained = true -- 1770
				break -- 1771
			end -- 1769
		end -- 1768
		if not contained then -- 1772
			result[#result + 1] = path -- 1772
		end -- 1772
	end -- 1766
	return result -- 1773
end -- 1753
HttpServer:postSchedule("/assets/batch", function(req) -- 1775
	do -- 1776
		local _type_0 = type(req) -- 1776
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1776
		if _tab_0 then -- 1776
			local operation -- 1776
			do -- 1776
				local _obj_0 = req.body -- 1776
				local _type_1 = type(_obj_0) -- 1776
				if "table" == _type_1 or "userdata" == _type_1 then -- 1776
					operation = _obj_0.operation -- 1776
				end -- 1776
			end -- 1776
			local sources -- 1776
			do -- 1776
				local _obj_0 = req.body -- 1776
				local _type_1 = type(_obj_0) -- 1776
				if "table" == _type_1 or "userdata" == _type_1 then -- 1776
					sources = _obj_0.sources -- 1776
				end -- 1776
			end -- 1776
			if operation ~= nil and sources ~= nil then -- 1776
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1777
					return { -- 1777
						success = false, -- 1777
						message = "invalid operation" -- 1777
					} -- 1777
				end -- 1777
				sources = normalizeAssetPaths(sources) -- 1778
				if not (sources and #sources > 0) then -- 1779
					return { -- 1779
						success = false, -- 1779
						message = "invalid sources" -- 1779
					} -- 1779
				end -- 1779
				local target = req.body.target -- 1780
				local destinations = { } -- 1781
				if operation ~= "delete" then -- 1782
					if not (type(target) == "string") then -- 1783
						return { -- 1783
							success = false, -- 1783
							message = "invalid target" -- 1783
						} -- 1783
					end -- 1783
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1784
					if targetRelative == nil then -- 1785
						return { -- 1785
							success = false, -- 1785
							message = "invalid target" -- 1785
						} -- 1785
					end -- 1785
					if not (Content:exist(target) and Content:isdir(target)) then -- 1786
						return { -- 1786
							success = false, -- 1786
							message = "invalid target" -- 1786
						} -- 1786
					end -- 1786
					for _index_0 = 1, #sources do -- 1787
						local source = sources[_index_0] -- 1787
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1788
							return { -- 1789
								success = false, -- 1789
								message = "target inside source" -- 1789
							} -- 1789
						end -- 1788
						local destination = Path(target, Path:getFilename(source)) -- 1790
						if Content:exist(destination) then -- 1791
							return { -- 1791
								success = false, -- 1791
								message = "target existed" -- 1791
							} -- 1791
						end -- 1791
						if destinations[destination] then -- 1792
							return { -- 1792
								success = false, -- 1792
								message = "duplicate target" -- 1792
							} -- 1792
						end -- 1792
						destinations[destination] = true -- 1793
					end -- 1787
				end -- 1782
				local changes = { } -- 1794
				local affectedSet = { } -- 1795
				local affectedDirectories = { } -- 1796
				local addAffected -- 1797
				addAffected = function(dir) -- 1797
					if affectedSet[dir] then -- 1798
						return -- 1798
					end -- 1798
					affectedSet[dir] = true -- 1799
					affectedDirectories[#affectedDirectories + 1] = dir -- 1800
				end -- 1797
				if operation ~= "delete" then -- 1801
					addAffected(target) -- 1801
				end -- 1801
				for _index_0 = 1, #sources do -- 1802
					local source = sources[_index_0] -- 1802
					addAffected(Path:getPath(source)) -- 1803
					if operation == "delete" then -- 1804
						if not deleteAsset(source) then -- 1805
							return { -- 1805
								success = false, -- 1805
								message = "delete failed", -- 1805
								changes = changes, -- 1805
								affectedDirectories = affectedDirectories -- 1805
							} -- 1805
						end -- 1805
						changes[#changes + 1] = { -- 1806
							old = source -- 1806
						} -- 1806
					else -- 1808
						local destination = Path(target, Path:getFilename(source)) -- 1808
						local ok -- 1809
						if operation == "copy" then -- 1809
							ok = Content:copyAsync(source, destination) -- 1810
						else -- 1812
							ok = moveAsset(source, destination) -- 1812
						end -- 1809
						if not ok then -- 1813
							return { -- 1813
								success = false, -- 1813
								message = operation .. " failed", -- 1813
								changes = changes, -- 1813
								affectedDirectories = affectedDirectories -- 1813
							} -- 1813
						end -- 1813
						changes[#changes + 1] = { -- 1814
							old = source, -- 1814
							new = destination -- 1814
						} -- 1814
					end -- 1804
				end -- 1802
				return { -- 1815
					success = true, -- 1815
					changes = changes, -- 1815
					affectedDirectories = affectedDirectories -- 1815
				} -- 1815
			end -- 1776
		end -- 1776
	end -- 1776
	return { -- 1775
		success = false, -- 1775
		message = "invalid request" -- 1775
	} -- 1775
end) -- 1775
local withProjectSearchPaths -- 1817
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1817
	local fallbackPaths = { } -- 1818
	local addFallback -- 1819
	addFallback = function(dir) -- 1819
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1819
			fallbackPaths[#fallbackPaths + 1] = dir -- 1819
		end -- 1819
	end -- 1819
	if projectRoot and projectRoot ~= "" then -- 1820
		addFallback(Path(projectRoot, "Script")) -- 1821
		addFallback(projectRoot) -- 1822
	end -- 1820
	if projFile then -- 1823
		local projDir = getProjectDirFromFile(projFile) -- 1824
		if projDir then -- 1824
			addFallback(Path(projDir, "Script")) -- 1825
			addFallback(projDir) -- 1826
		else -- 1828
			addFallback(Path:getPath(projFile)) -- 1828
		end -- 1824
	end -- 1823
	if not (#fallbackPaths > 0) then -- 1829
		return fn() -- 1829
	end -- 1829
	local searchPaths = Content.searchPaths -- 1830
	for _index_0 = 1, #fallbackPaths do -- 1831
		local dir = fallbackPaths[_index_0] -- 1831
		Content:addSearchPath(dir) -- 1831
	end -- 1831
	local _ <close> = setmetatable({ }, { -- 1832
		__close = function() -- 1832
			Content.searchPaths = searchPaths -- 1832
		end -- 1832
	}) -- 1832
	return fn() -- 1833
end -- 1817
HttpServer:post("/exist", function(req) -- 1834
	do -- 1835
		local _type_0 = type(req) -- 1835
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1835
		if _tab_0 then -- 1835
			local file -- 1835
			do -- 1835
				local _obj_0 = req.body -- 1835
				local _type_1 = type(_obj_0) -- 1835
				if "table" == _type_1 or "userdata" == _type_1 then -- 1835
					file = _obj_0.file -- 1835
				end -- 1835
			end -- 1835
			if file ~= nil then -- 1835
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1836
					return { -- 1837
						success = Content:exist(file) -- 1837
					} -- 1837
				end) -- 1836
			end -- 1835
		end -- 1835
	end -- 1835
	return { -- 1834
		success = false -- 1834
	} -- 1834
end) -- 1834
HttpServer:postSchedule("/read", function(req) -- 1838
	do -- 1839
		local _type_0 = type(req) -- 1839
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1839
		if _tab_0 then -- 1839
			local path -- 1839
			do -- 1839
				local _obj_0 = req.body -- 1839
				local _type_1 = type(_obj_0) -- 1839
				if "table" == _type_1 or "userdata" == _type_1 then -- 1839
					path = _obj_0.path -- 1839
				end -- 1839
			end -- 1839
			if path ~= nil then -- 1839
				local readFile -- 1840
				readFile = function() -- 1840
					if Content:exist(path) and not Content:isdir(path) then -- 1841
						local content = Content:loadAsync(path) -- 1842
						if content then -- 1842
							return { -- 1843
								content = content, -- 1843
								success = true, -- 1843
								fullPath = Content:getFullPath(path) -- 1843
							} -- 1843
						end -- 1842
					end -- 1841
					return nil -- 1840
				end -- 1840
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1844
				if result then -- 1844
					return result -- 1844
				end -- 1844
			end -- 1839
		end -- 1839
	end -- 1839
	return { -- 1838
		success = false -- 1838
	} -- 1838
end) -- 1838
local agentDocLanguage -- 1846
agentDocLanguage = function(language) -- 1846
	if language == "zh-Hans" then -- 1847
		return "zh" -- 1847
	else -- 1847
		return "en" -- 1847
	end -- 1847
end -- 1846
HttpServer:postSchedule("/doc/search", function(req) -- 1849
	local body = req.body or { } -- 1850
	local language = body.docLanguage -- 1851
	if not (("en" == language or "zh-Hans" == language)) then -- 1852
		return { -- 1852
			success = false, -- 1852
			message = "unsupported doc language" -- 1852
		} -- 1852
	end -- 1852
	local docType = body.docType -- 1853
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1854
		return { -- 1854
			success = false, -- 1854
			message = "unsupported doc type" -- 1854
		} -- 1854
	end -- 1854
	local codeLanguage = body.programmingLanguage -- 1855
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1856
		return { -- 1856
			success = false, -- 1856
			message = "unsupported programming language" -- 1856
		} -- 1856
	end -- 1856
	if not body.pattern then -- 1857
		return { -- 1857
			success = false, -- 1857
			message = "missing pattern" -- 1857
		} -- 1857
	end -- 1857
	local result = nil -- 1858
	AgentTools.searchDoraDocHttp({ -- 1860
		pattern = body.pattern, -- 1860
		docLanguage = agentDocLanguage(language), -- 1861
		docType = docType, -- 1862
		programmingLanguage = codeLanguage, -- 1863
		limit = body.limit, -- 1864
		useRegex = body.useRegex, -- 1865
		caseSensitive = body.caseSensitive, -- 1866
		includeContent = body.includeContent, -- 1867
		contentWindow = body.contentWindow -- 1868
	}, function(res) -- 1869
		result = res -- 1870
	end) -- 1859
	wait(function() -- 1871
		return result ~= nil -- 1871
	end) -- 1871
	if result and result.success then -- 1872
		result.docLanguage = language -- 1873
	end -- 1872
	if result then -- 1874
		return result -- 1875
	else -- 1877
		return { -- 1877
			success = false, -- 1877
			message = "doc search failed" -- 1877
		} -- 1877
	end -- 1874
	return { -- 1849
		success = false, -- 1849
		message = "invalid call" -- 1849
	} -- 1849
end) -- 1849
HttpServer:postSchedule("/doc/read", function(req) -- 1879
	local body = req.body or { } -- 1880
	local language = body.docLanguage -- 1881
	if not (("en" == language or "zh-Hans" == language)) then -- 1882
		return { -- 1882
			success = false, -- 1882
			message = "unsupported doc language" -- 1882
		} -- 1882
	end -- 1882
	if not body.file then -- 1883
		return { -- 1883
			success = false, -- 1883
			message = "missing file" -- 1883
		} -- 1883
	end -- 1883
	local result = AgentTools.readDoraDoc({ -- 1885
		docLanguage = agentDocLanguage(language), -- 1885
		file = body.file, -- 1886
		startLine = body.startLine, -- 1887
		endLine = body.endLine -- 1888
	}) -- 1884
	if result and result.success then -- 1889
		result.docLanguage = language -- 1890
	end -- 1889
	return result -- 1891
end) -- 1879
HttpServer:get("/read-sync", function(req) -- 1893
	do -- 1894
		local _type_0 = type(req) -- 1894
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1894
		if _tab_0 then -- 1894
			local params = req.params -- 1894
			if params ~= nil then -- 1894
				local path = params.path -- 1895
				local exts -- 1896
				if params.exts then -- 1896
					local _accum_0 = { } -- 1897
					local _len_0 = 1 -- 1897
					for ext in params.exts:gmatch("[^|]*") do -- 1897
						_accum_0[_len_0] = ext -- 1897
						_len_0 = _len_0 + 1 -- 1897
					end -- 1897
					exts = _accum_0 -- 1897
				else -- 1898
					exts = { -- 1898
						"" -- 1898
					} -- 1898
				end -- 1896
				local readFileAt -- 1899
				readFileAt = function(targetPath) -- 1899
					if Content:exist(targetPath) then -- 1900
						local content = Content:load(targetPath) -- 1901
						if content then -- 1901
							return { -- 1902
								content = content, -- 1902
								success = true, -- 1902
								fullPath = Content:getFullPath(targetPath) -- 1902
							} -- 1902
						end -- 1901
					end -- 1900
					return nil -- 1899
				end -- 1899
				local readFile -- 1903
				readFile = function(fallbackPaths) -- 1903
					for _index_0 = 1, #exts do -- 1904
						local ext = exts[_index_0] -- 1904
						local targetPath = path .. ext -- 1905
						if not Content:isAbsolutePath(targetPath) then -- 1906
							for _index_1 = 1, #fallbackPaths do -- 1907
								local fallback = fallbackPaths[_index_1] -- 1907
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1908
								if fallbackResult then -- 1908
									return fallbackResult -- 1909
								end -- 1908
							end -- 1907
						end -- 1906
						local fileResult = readFileAt(targetPath) -- 1910
						if fileResult then -- 1910
							return fileResult -- 1911
						end -- 1910
					end -- 1904
					return nil -- 1903
				end -- 1903
				local fallbackPaths = { } -- 1912
				local fallbackCandidates = { } -- 1913
				do -- 1914
					local projectRoot = req.params.projectRoot -- 1914
					if projectRoot then -- 1914
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1915
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1916
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1917
						end -- 1915
					end -- 1914
				end -- 1914
				do -- 1918
					local projFile = req.params.projFile -- 1918
					if projFile then -- 1918
						local projDir = getProjectDirFromFile(projFile) -- 1919
						if projDir then -- 1919
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1920
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1921
						else -- 1923
							projDir = Path:getPath(projFile) -- 1923
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1924
						end -- 1919
					end -- 1918
				end -- 1918
				for _index_0 = 1, #fallbackCandidates do -- 1925
					local dir = fallbackCandidates[_index_0] -- 1925
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1926
						local exists = false -- 1927
						for _index_1 = 1, #fallbackPaths do -- 1928
							local fallback = fallbackPaths[_index_1] -- 1928
							if fallback == dir then -- 1929
								exists = true -- 1930
								break -- 1931
							end -- 1929
						end -- 1928
						if not exists then -- 1932
							fallbackPaths[#fallbackPaths + 1] = dir -- 1932
						end -- 1932
					end -- 1926
				end -- 1925
				local readResult = readFile(fallbackPaths) -- 1933
				if readResult then -- 1933
					return readResult -- 1934
				end -- 1933
			end -- 1894
		end -- 1894
	end -- 1894
	return { -- 1893
		success = false -- 1893
	} -- 1893
end) -- 1893
local addGeneratedSourceHeader -- 1936
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 1936
	if preserveTIC80 == nil then -- 1936
		preserveTIC80 = false -- 1936
	end -- 1936
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 1937
	if preserveTIC80 then -- 1938
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 1939
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 1940
		end -- 1939
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 1941
	end -- 1938
	return tostring(header) .. "\n" .. tostring(codes) -- 1942
end -- 1936
local compileFileAsync -- 1944
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1944
	if projectRoot == nil then -- 1944
		projectRoot = nil -- 1944
	end -- 1944
	local file = inputFile -- 1945
	local searchPath -- 1946
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1946
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1947
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1951
	elseif not Content:isAbsolutePath(inputFile) then -- 1952
		searchPath = "" -- 1953
	else -- 1954
		local dir = getProjectDirFromFile(inputFile) -- 1954
		if dir then -- 1954
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1955
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1959
		else -- 1961
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1961
			searchPath = "" -- 1964
		end -- 1954
	end -- 1946
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1965
	local yueext = yue.options.extension -- 1966
	local resultCodes = nil -- 1967
	local resultError = nil -- 1968
	do -- 1969
		local _exp_0 = Path:getExt(inputFile) -- 1969
		if yueext == _exp_0 then -- 1969
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1970
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1971
				if not codes then -- 1972
					resultError = err -- 1973
					return -- 1974
				end -- 1972
				local extraGlobal -- 1975
				if isTIC80 then -- 1975
					extraGlobal = tic80APIs -- 1975
				else -- 1975
					extraGlobal = nil -- 1975
				end -- 1975
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1976
				if not success then -- 1977
					resultError = message -- 1978
					return -- 1979
				end -- 1977
				if codes == "" then -- 1980
					resultCodes = "" -- 1981
					return nil -- 1982
				end -- 1980
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 1983
				return resultCodes -- 1984
			end, function(success) -- 1971
				if not success then -- 1985
					Content:remove(outputFile) -- 1986
					if resultCodes == nil then -- 1987
						resultCodes = false -- 1988
					end -- 1987
				end -- 1985
			end) -- 1971
		elseif "tl" == _exp_0 then -- 1989
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1990
			if isTIC80 then -- 1991
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1992
			end -- 1991
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1993
			if codes then -- 1993
				if isTIC80 then -- 1994
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1995
				end -- 1994
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 1996
				Content:saveAsync(outputFile, resultCodes) -- 1997
			else -- 1999
				Content:remove(outputFile) -- 1999
				resultCodes = false -- 2000
				resultError = err -- 2001
			end -- 1993
		elseif "xml" == _exp_0 then -- 2002
			local codes, err = xml.tolua(sourceCodes) -- 2003
			if codes then -- 2003
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2004
				Content:saveAsync(outputFile, resultCodes) -- 2005
			else -- 2007
				Content:remove(outputFile) -- 2007
				resultCodes = false -- 2008
				resultError = err -- 2009
			end -- 2003
		end -- 1969
	end -- 1969
	wait(function() -- 2010
		return resultCodes ~= nil -- 2010
	end) -- 2010
	if resultCodes then -- 2011
		return resultCodes -- 2012
	else -- 2014
		return nil, resultError -- 2014
	end -- 2011
	return nil -- 1944
end -- 1944
HttpServer:postSchedule("/write", function(req) -- 2016
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2017
	local buildSucceeded = false -- 2018
	local _ <close> = setmetatable({ }, { -- 2019
		__close = function() -- 2019
			return finishUpdate(buildSucceeded) -- 2019
		end -- 2019
	}) -- 2019
	do -- 2020
		local _type_0 = type(req) -- 2020
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2020
		if _tab_0 then -- 2020
			local path -- 2020
			do -- 2020
				local _obj_0 = req.body -- 2020
				local _type_1 = type(_obj_0) -- 2020
				if "table" == _type_1 or "userdata" == _type_1 then -- 2020
					path = _obj_0.path -- 2020
				end -- 2020
			end -- 2020
			local content -- 2020
			do -- 2020
				local _obj_0 = req.body -- 2020
				local _type_1 = type(_obj_0) -- 2020
				if "table" == _type_1 or "userdata" == _type_1 then -- 2020
					content = _obj_0.content -- 2020
				end -- 2020
			end -- 2020
			if path ~= nil and content ~= nil then -- 2020
				if Content:saveAsync(path, content) then -- 2021
					do -- 2022
						local _exp_0 = Path:getExt(path) -- 2022
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2022
							if '' == Path:getExt(Path:getName(path)) then -- 2023
								local resultCodes = compileFileAsync(path, content) -- 2024
								buildSucceeded = resultCodes ~= nil -- 2025
								return { -- 2026
									success = true, -- 2026
									resultCodes = resultCodes -- 2026
								} -- 2026
							end -- 2023
						end -- 2022
					end -- 2022
					buildSucceeded = true -- 2027
					return { -- 2028
						success = true -- 2028
					} -- 2028
				end -- 2021
			end -- 2020
		end -- 2020
	end -- 2020
	return { -- 2016
		success = false -- 2016
	} -- 2016
end) -- 2016
local getWaProjectDirFromFile = nil -- 2030
HttpServer:postSchedule("/build", function(req) -- 2032
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
			if path ~= nil then -- 2036
				local projectRoot = req.body.projectRoot -- 2037
				if Content:isdir(path) then -- 2038
					local projDir = getWaProjectDirFromFile(path) -- 2039
					if projDir then -- 2039
						local message = Wasm:buildWaAsync(projDir) -- 2040
						if message == "" then -- 2041
							return { -- 2042
								success = true -- 2042
							} -- 2042
						else -- 2044
							return { -- 2044
								success = false, -- 2044
								message = message -- 2044
							} -- 2044
						end -- 2041
					end -- 2039
				end -- 2038
				local _exp_0 = Path:getExt(path) -- 2045
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2046
					if '' == Path:getExt(Path:getName(path)) then -- 2047
						local content = Content:loadAsync(path) -- 2048
						if content then -- 2048
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2049
							if resultCodes then -- 2049
								buildSucceeded = true -- 2050
								return { -- 2051
									success = true, -- 2051
									resultCodes = resultCodes -- 2051
								} -- 2051
							end -- 2049
						end -- 2048
					end -- 2047
				elseif "wa" == _exp_0 then -- 2052
					local projDir = getWaProjectDirFromFile(path) -- 2053
					if projDir then -- 2053
						local message = Wasm:buildWaAsync(projDir) -- 2054
						if message == "" then -- 2055
							return { -- 2056
								success = true -- 2056
							} -- 2056
						else -- 2058
							return { -- 2058
								success = false, -- 2058
								message = message -- 2058
							} -- 2058
						end -- 2055
					else -- 2060
						return { -- 2060
							success = false, -- 2060
							message = 'Wa file needs a project' -- 2060
						} -- 2060
					end -- 2053
				end -- 2045
			end -- 2036
		end -- 2036
	end -- 2036
	return { -- 2032
		success = false -- 2032
	} -- 2032
end) -- 2032
local extentionLevels = { -- 2063
	vs = 2, -- 2063
	bl = 2, -- 2064
	ts = 1, -- 2065
	tsx = 1, -- 2066
	tl = 1, -- 2067
	yue = 1, -- 2068
	xml = 1, -- 2069
	lua = 0 -- 2070
} -- 2062
local visitAssets -- 2072
visitAssets = function(path, workspace, builtin, recursive) -- 2072
	if recursive == nil then -- 2072
		recursive = true -- 2072
	end -- 2072
	local children = nil -- 2073
	local dirs = Content:getDirs(path) -- 2074
	for _index_0 = 1, #dirs do -- 2075
		local dir = dirs[_index_0] -- 2075
		if workspace then -- 2076
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 2077
				goto _continue_0 -- 2078
			end -- 2077
		elseif dir == ".git" then -- 2079
			goto _continue_0 -- 2080
		end -- 2076
		if not children then -- 2081
			children = { } -- 2081
		end -- 2081
		local dirPath = Path(path, dir) -- 2082
		if recursive then -- 2083
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2084
		else -- 2086
			children[#children + 1] = { -- 2087
				key = dirPath, -- 2087
				dir = true, -- 2088
				title = dir, -- 2089
				builtin = builtin, -- 2090
				isLeaf = false -- 2091
			} -- 2086
		end -- 2083
		::_continue_0:: -- 2076
	end -- 2075
	local files = Content:getFiles(path) -- 2093
	local names = { } -- 2094
	for _index_0 = 1, #files do -- 2095
		local file = files[_index_0] -- 2095
		if (".DS_Store" == file) then -- 2096
			goto _continue_1 -- 2097
		end -- 2096
		local name = Path:getName(file) -- 2098
		local ext = names[name] -- 2099
		if ext then -- 2099
			local lv1 -- 2100
			do -- 2100
				local _exp_0 = extentionLevels[ext] -- 2100
				if _exp_0 ~= nil then -- 2100
					lv1 = _exp_0 -- 2100
				else -- 2100
					lv1 = -1 -- 2100
				end -- 2100
			end -- 2100
			ext = Path:getExt(file) -- 2101
			local lv2 -- 2102
			do -- 2102
				local _exp_0 = extentionLevels[ext] -- 2102
				if _exp_0 ~= nil then -- 2102
					lv2 = _exp_0 -- 2102
				else -- 2102
					lv2 = -1 -- 2102
				end -- 2102
			end -- 2102
			if lv2 > lv1 then -- 2103
				names[name] = ext -- 2104
			elseif lv2 == lv1 then -- 2105
				names[name .. '.' .. ext] = "" -- 2106
			end -- 2103
		else -- 2108
			ext = Path:getExt(file) -- 2108
			if not extentionLevels[ext] then -- 2109
				names[file] = "" -- 2110
			else -- 2112
				names[name] = ext -- 2112
			end -- 2109
		end -- 2099
		::_continue_1:: -- 2096
	end -- 2095
	do -- 2113
		local _accum_0 = { } -- 2113
		local _len_0 = 1 -- 2113
		for name, ext in pairs(names) do -- 2113
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2113
			_len_0 = _len_0 + 1 -- 2113
		end -- 2113
		files = _accum_0 -- 2113
	end -- 2113
	for _index_0 = 1, #files do -- 2114
		local file = files[_index_0] -- 2114
		if not children then -- 2115
			children = { } -- 2115
		end -- 2115
		children[#children + 1] = { -- 2117
			key = Path(path, file), -- 2117
			dir = false, -- 2118
			title = file, -- 2119
			builtin = builtin -- 2120
		} -- 2116
	end -- 2114
	if children then -- 2122
		table.sort(children, function(a, b) -- 2123
			if a.dir == b.dir then -- 2124
				return a.title < b.title -- 2125
			else -- 2127
				return a.dir -- 2127
			end -- 2124
		end) -- 2123
	end -- 2122
	return { -- 2129
		key = path, -- 2129
		dir = true, -- 2130
		title = Path:getFilename(path), -- 2131
		builtin = builtin, -- 2132
		isLeaf = not children, -- 2133
		children = children -- 2134
	} -- 2128
end -- 2072
HttpServer:post("/assets/children", function(req) -- 2137
	do -- 2138
		local _type_0 = type(req) -- 2138
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2138
		if _tab_0 then -- 2138
			local path -- 2138
			do -- 2138
				local _obj_0 = req.body -- 2138
				local _type_1 = type(_obj_0) -- 2138
				if "table" == _type_1 or "userdata" == _type_1 then -- 2138
					path = _obj_0.path -- 2138
				end -- 2138
			end -- 2138
			if path ~= nil then -- 2138
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2139
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2140
					return { -- 2140
						success = false -- 2140
					} -- 2140
				end -- 2140
				local node = visitAssets(path, workspace, builtin, false) -- 2141
				return { -- 2142
					success = true, -- 2142
					children = node.children or { } -- 2142
				} -- 2142
			end -- 2138
		end -- 2138
	end -- 2138
	return { -- 2137
		success = false -- 2137
	} -- 2137
end) -- 2137
HttpServer:post("/assets/files", function(req) -- 2144
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
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2146
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2147
				if not (workspace or builtin) then -- 2148
					return { -- 2148
						success = false -- 2148
					} -- 2148
				end -- 2148
				if not (Content:exist(path) and Content:isdir(path)) then -- 2149
					return { -- 2149
						success = false -- 2149
					} -- 2149
				end -- 2149
				local globs = { -- 2150
					"**", -- 2150
					"!**/.DS_Store" -- 2150
				} -- 2150
				if workspace then -- 2151
					globs = { -- 2153
						"**", -- 2153
						"!**/.DS_Store", -- 2153
						"!**/.upload/**", -- 2154
						"!**/.download/**", -- 2154
						"!**/.www/**", -- 2155
						"!**/.build/**", -- 2155
						"!**/.git/**", -- 2156
						"!**/.cache/**", -- 2156
						"!**/node_modules/**" -- 2157
					} -- 2152
				end -- 2151
				local files -- 2159
				do -- 2159
					local _accum_0 = { } -- 2159
					local _len_0 = 1 -- 2159
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2159
					for _index_0 = 1, #_list_0 do -- 2159
						local file = _list_0[_index_0] -- 2159
						_accum_0[_len_0] = Path(path, file) -- 2159
						_len_0 = _len_0 + 1 -- 2159
					end -- 2159
					files = _accum_0 -- 2159
				end -- 2159
				return { -- 2160
					success = true, -- 2160
					files = files -- 2160
				} -- 2160
			end -- 2145
		end -- 2145
	end -- 2145
	return { -- 2144
		success = false -- 2144
	} -- 2144
end) -- 2144
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2201
	local _tab_0 = { -- 2201
		{ -- 2202
			key = Path(Content.assetPath), -- 2202
			dir = true, -- 2203
			builtin = true, -- 2204
			title = zh and "内置资源" or "Built-in", -- 2205
			children = builtinChildren -- 2206
		} -- 2201
	} -- 2208
	local _obj_0 = workspace.children or { } -- 2208
	local _idx_0 = #_tab_0 + 1 -- 2208
	for _index_0 = 1, #_obj_0 do -- 2208
		local _value_0 = _obj_0[_index_0] -- 2208
		_tab_0[_idx_0] = _value_0 -- 2208
		_idx_0 = _idx_0 + 1 -- 2208
	end -- 2208
	return _tab_0 -- 2201
end -- 2201
HttpServer:post("/assets", function() -- 2162
	local Entry = require("Script.Dev.Entry") -- 2163
	local engineDev = Entry.getEngineDev() -- 2164
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2165
	local zh = (App.locale:match("^zh") ~= nil) -- 2166
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2167
	readme.title = zh and "说明文档" or "Readme" -- 2168
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2169
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2170
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2171
	tools.title = zh and "开发工具" or "Tools" -- 2172
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2173
	font.title = zh and "字体" or "Font" -- 2174
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2175
	lib.title = zh and "程序库" or "Lib" -- 2176
	if engineDev then -- 2177
		local _list_0 = lib.children -- 2178
		for _index_0 = 1, #_list_0 do -- 2178
			local child = _list_0[_index_0] -- 2178
			if not (child.title == "Dora") then -- 2179
				goto _continue_0 -- 2179
			end -- 2179
			local title = zh and "zh-Hans" or "en" -- 2180
			do -- 2181
				local _accum_0 = { } -- 2181
				local _len_0 = 1 -- 2181
				local _list_1 = child.children -- 2181
				for _index_1 = 1, #_list_1 do -- 2181
					local c = _list_1[_index_1] -- 2181
					if c.title ~= title then -- 2181
						_accum_0[_len_0] = c -- 2181
						_len_0 = _len_0 + 1 -- 2181
					end -- 2181
				end -- 2181
				child.children = _accum_0 -- 2181
			end -- 2181
			break -- 2182
			::_continue_0:: -- 2179
		end -- 2178
	else -- 2184
		local _accum_0 = { } -- 2184
		local _len_0 = 1 -- 2184
		local _list_0 = lib.children -- 2184
		for _index_0 = 1, #_list_0 do -- 2184
			local child = _list_0[_index_0] -- 2184
			if child.title ~= "Dora" then -- 2184
				_accum_0[_len_0] = child -- 2184
				_len_0 = _len_0 + 1 -- 2184
			end -- 2184
		end -- 2184
		lib.children = _accum_0 -- 2184
	end -- 2177
	local builtinChildren = { -- 2185
		readme, -- 2185
		apiDoc, -- 2185
		tools, -- 2185
		font, -- 2185
		lib -- 2185
	} -- 2185
	if engineDev then -- 2186
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2187
		do -- 2188
			local _obj_0 = dev.children -- 2188
			_obj_0[#_obj_0 + 1] = { -- 2189
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2189
				dir = false, -- 2190
				builtin = true, -- 2191
				title = "init.yue" -- 2192
			} -- 2188
		end -- 2188
		builtinChildren[#builtinChildren + 1] = dev -- 2194
	end -- 2186
	return { -- 2196
		key = Content.writablePath, -- 2196
		dir = true, -- 2197
		root = true, -- 2198
		title = "Assets", -- 2199
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2200
	} -- 2195
end) -- 2162
HttpServer:post("/entry/list", function(req) -- 2212
	local Entry = require("Script.Dev.Entry") -- 2213
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2214
	res.success = true -- 2215
	return res -- 2216
end) -- 2212
HttpServer:post("/run/status", function() -- 2218
	local Entry = require("Script.Dev.Entry") -- 2219
	return Entry.getCurrentEntryStatus() -- 2220
end) -- 2218
HttpServer:postSchedule("/run", function(req) -- 2222
	do -- 2223
		local _type_0 = type(req) -- 2223
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2223
		if _tab_0 then -- 2223
			local file -- 2223
			do -- 2223
				local _obj_0 = req.body -- 2223
				local _type_1 = type(_obj_0) -- 2223
				if "table" == _type_1 or "userdata" == _type_1 then -- 2223
					file = _obj_0.file -- 2223
				end -- 2223
			end -- 2223
			local asProj -- 2223
			do -- 2223
				local _obj_0 = req.body -- 2223
				local _type_1 = type(_obj_0) -- 2223
				if "table" == _type_1 or "userdata" == _type_1 then -- 2223
					asProj = _obj_0.asProj -- 2223
				end -- 2223
			end -- 2223
			if file ~= nil and asProj ~= nil then -- 2223
				if not Content:isAbsolutePath(file) then -- 2224
					local devFile = Path(Content.writablePath, file) -- 2225
					if Content:exist(devFile) then -- 2226
						file = devFile -- 2226
					end -- 2226
				end -- 2224
				local Entry = require("Script.Dev.Entry") -- 2227
				local workDir -- 2228
				if asProj then -- 2229
					local projectRoot = req.body.projectRoot -- 2230
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2231
						workDir = projectRoot -- 2232
					else -- 2234
						workDir = getProjectDirFromFile(file) -- 2234
					end -- 2231
					if workDir then -- 2235
						Entry.allClear() -- 2236
						local target = Path(workDir, "init") -- 2237
						local success, err = Entry.enterEntryAsync({ -- 2238
							entryName = "Project", -- 2238
							fileName = target, -- 2238
							workDir = workDir, -- 2238
							projectRoot = workDir, -- 2238
							runKind = "project" -- 2238
						}) -- 2238
						target = Path:getName(Path:getPath(target)) -- 2239
						return { -- 2240
							success = success, -- 2240
							target = target, -- 2240
							err = err -- 2240
						} -- 2240
					end -- 2235
				else -- 2242
					workDir = getProjectDirFromFile(file) -- 2242
					if not workDir and Path:getExt(file) == "wasm" then -- 2243
						local parent = Path:getPath(file) -- 2244
						if Content:exist(Path(parent, "wa.mod")) then -- 2245
							workDir = parent -- 2246
						end -- 2245
					end -- 2243
				end -- 2229
				Entry.allClear() -- 2247
				file = Path:replaceExt(file, "") -- 2248
				local entry = { -- 2250
					entryName = Path:getName(file), -- 2250
					fileName = file, -- 2251
					runKind = "file" -- 2252
				} -- 2249
				if workDir then -- 2253
					entry.workDir = workDir -- 2254
					entry.projectRoot = workDir -- 2255
				end -- 2253
				local success, err = Entry.enterEntryAsync(entry) -- 2256
				return { -- 2257
					success = success, -- 2257
					err = err -- 2257
				} -- 2257
			end -- 2223
		end -- 2223
	end -- 2223
	return { -- 2222
		success = false -- 2222
	} -- 2222
end) -- 2222
local _anon_func_7 = function(result) -- 2299
	if result.success then -- 2299
		return nil -- 2299
	else -- 2299
		return "PREVIEW_FAILED" -- 2299
	end -- 2299
end -- 2299
HttpServer:postSchedule("/agent/preview", function(req) -- 2259
	local releaseAgent = AgentHost.acquire() -- 2260
	local _ <close> = setmetatable({ }, { -- 2261
		__close = function() -- 2261
			return releaseAgent() -- 2261
		end -- 2261
	}) -- 2261
	do -- 2262
		local _type_0 = type(req) -- 2262
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2262
		if _tab_0 then -- 2262
			local projectRoot -- 2262
			do -- 2262
				local _obj_0 = req.body -- 2262
				local _type_1 = type(_obj_0) -- 2262
				if "table" == _type_1 or "userdata" == _type_1 then -- 2262
					projectRoot = _obj_0.projectRoot -- 2262
				end -- 2262
			end -- 2262
			if projectRoot ~= nil then -- 2262
				if not getProjectSourceRoot(projectRoot) then -- 2263
					return { -- 2263
						success = false, -- 2263
						code = "INVALID_PROJECT", -- 2263
						message = "projectRoot must be an existing absolute directory" -- 2263
					} -- 2263
				end -- 2263
				local entryFile = req.body.entry or "init.lua" -- 2264
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2265
					return { -- 2265
						success = false, -- 2265
						code = "INVALID_ENTRY", -- 2265
						message = "entry must be a non-empty project-relative path" -- 2265
					} -- 2265
				end -- 2265
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2266
					0.5 -- 2266
				} -- 2266
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2267
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2268
					return { -- 2268
						success = false, -- 2268
						code = "INVALID_QUEUE_TIMEOUT", -- 2268
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2268
					} -- 2268
				end -- 2268
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2269
				local AgentOperation = require("Agent.Tool.Operation") -- 2270
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2271
				local requestId = AgentOperation.createOperationId() -- 2272
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2273
				if not enqueued.success then -- 2274
					return { -- 2274
						success = false, -- 2274
						code = "ENTRY_QUEUE_REJECTED", -- 2274
						message = enqueued.message -- 2274
					} -- 2274
				end -- 2274
				local queuedAt = App.runningTime -- 2275
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2276
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2277
						local state = agentEntryRunQueue:get(requestId) -- 2278
						agentEntryRunQueue:cancel(requestId) -- 2279
						return { -- 2281
							success = false, -- 2281
							code = "ENTRY_QUEUE_TIMEOUT", -- 2282
							message = "timed out waiting for the Dora entry runtime", -- 2283
							requestId = requestId, -- 2284
							queuePosition = state.position -- 2285
						} -- 2280
					end -- 2277
					sleep() -- 2286
				end -- 2276
				local queueWaitSeconds = App.runningTime - queuedAt -- 2287
				local _ <close> = setmetatable({ }, { -- 2288
					__close = function() -- 2288
						return agentEntryRunQueue:release(requestId) -- 2288
					end -- 2288
				}) -- 2288
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2289
				local Entry = require("Script.Dev.Entry") -- 2290
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2292
					workDir = projectRoot, -- 2292
					operationId = requestId, -- 2293
					print = function() end -- 2294
				}, Entry) -- 2291
				local result = preview({ -- 2296
					entry = entryFile, -- 2296
					captureAtSeconds = captureAtSeconds -- 2296
				}) -- 2296
				return { -- 2298
					success = result.success, -- 2298
					code = _anon_func_7(result), -- 2299
					message = result.message, -- 2300
					requestId = requestId, -- 2301
					queueWaitSeconds = queueWaitSeconds, -- 2302
					interruptedUserRun = result.interruptedUserRun, -- 2303
					files = result.files, -- 2304
					frames = result.frames -- 2305
				} -- 2297
			end -- 2262
		end -- 2262
	end -- 2262
	return { -- 2259
		success = false, -- 2259
		message = "invalid call" -- 2259
	} -- 2259
end) -- 2259
HttpServer:postSchedule("/agent/command", function(req) -- 2307
	local releaseAgent = AgentHost.acquire() -- 2308
	local _ <close> = setmetatable({ }, { -- 2309
		__close = function() -- 2309
			return releaseAgent() -- 2309
		end -- 2309
	}) -- 2309
	do -- 2310
		local _type_0 = type(req) -- 2310
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2310
		if _tab_0 then -- 2310
			local body = req.body -- 2310
			if body ~= nil then -- 2310
				local projectRoot = body.projectRoot -- 2311
				if not getProjectSourceRoot(projectRoot) then -- 2312
					return { -- 2312
						success = false, -- 2312
						code = "INVALID_PROJECT", -- 2312
						message = "projectRoot must be an existing absolute directory" -- 2312
					} -- 2312
				end -- 2312
				local AgentValidation = require("Agent.Tool.Validation") -- 2313
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2314
				if not validated.success then -- 2315
					return { -- 2315
						success = false, -- 2315
						code = "INVALID_COMMAND", -- 2315
						message = validated.message -- 2315
					} -- 2315
				end -- 2315
				local input = validated.value -- 2316
				local AgentCommand = require("Agent.Tool.Command") -- 2317
				local result = nil -- 2318
				local failure = nil -- 2319
				local promise = AgentCommand.executeCommand({ -- 2321
					workDir = projectRoot, -- 2321
					mode = input.mode, -- 2322
					code = input.code, -- 2323
					command = input.command, -- 2324
					cwd = input.cwd, -- 2325
					timeoutSeconds = input.timeoutSeconds -- 2326
				}) -- 2320
				promise:addCallbacks((function(_, value) -- 2327
					result = value -- 2327
				end), (function(_, err) -- 2327
					failure = tostring(err) -- 2327
				end)) -- 2327
				wait(function() -- 2328
					return result ~= nil or failure ~= nil -- 2328
				end) -- 2328
				if failure then -- 2329
					return { -- 2329
						success = false, -- 2329
						code = "COMMAND_BRIDGE_FAILED", -- 2329
						message = failure -- 2329
					} -- 2329
				end -- 2329
				if not result.success then -- 2330
					result.code = "COMMAND_FAILED" -- 2331
				end -- 2330
				return result -- 2332
			end -- 2310
		end -- 2310
	end -- 2310
	return { -- 2307
		success = false, -- 2307
		code = "INVALID_COMMAND", -- 2307
		message = "invalid call" -- 2307
	} -- 2307
end) -- 2307
HttpServer:postSchedule("/stop", function() -- 2334
	local Entry = require("Script.Dev.Entry") -- 2335
	return { -- 2336
		success = Entry.stop() -- 2336
	} -- 2336
end) -- 2334
local minifyAsync -- 2338
minifyAsync = function(sourcePath, minifyPath) -- 2338
	if not Content:exist(sourcePath) then -- 2339
		return -- 2339
	end -- 2339
	local Entry = require("Script.Dev.Entry") -- 2340
	local errors = { } -- 2341
	local files = Entry.getAllFiles(sourcePath, { -- 2342
		"lua" -- 2342
	}, true) -- 2342
	do -- 2343
		local _accum_0 = { } -- 2343
		local _len_0 = 1 -- 2343
		for _index_0 = 1, #files do -- 2343
			local file = files[_index_0] -- 2343
			if file:sub(1, 1) ~= '.' then -- 2343
				_accum_0[_len_0] = file -- 2343
				_len_0 = _len_0 + 1 -- 2343
			end -- 2343
		end -- 2343
		files = _accum_0 -- 2343
	end -- 2343
	local paths -- 2344
	do -- 2344
		local _tbl_0 = { } -- 2344
		for _index_0 = 1, #files do -- 2344
			local file = files[_index_0] -- 2344
			_tbl_0[Path:getPath(file)] = true -- 2344
		end -- 2344
		paths = _tbl_0 -- 2344
	end -- 2344
	for path in pairs(paths) do -- 2345
		Content:mkdir(Path(minifyPath, path)) -- 2345
	end -- 2345
	local _ <close> = setmetatable({ }, { -- 2346
		__close = function() -- 2346
			package.loaded["luaminify.FormatMini"] = nil -- 2347
			package.loaded["luaminify.ParseLua"] = nil -- 2348
			package.loaded["luaminify.Scope"] = nil -- 2349
			package.loaded["luaminify.Util"] = nil -- 2350
		end -- 2346
	}) -- 2346
	local FormatMini -- 2351
	do -- 2351
		local _obj_0 = require("luaminify") -- 2351
		FormatMini = _obj_0.FormatMini -- 2351
	end -- 2351
	local fileCount = #files -- 2352
	local count = 0 -- 2353
	for _index_0 = 1, #files do -- 2354
		local file = files[_index_0] -- 2354
		thread(function() -- 2355
			local _ <close> = setmetatable({ }, { -- 2356
				__close = function() -- 2356
					count = count + 1 -- 2356
				end -- 2356
			}) -- 2356
			local input = Path(sourcePath, file) -- 2357
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2358
			if Content:exist(input) then -- 2359
				local sourceCodes = Content:loadAsync(input) -- 2360
				local res, err = FormatMini(sourceCodes) -- 2361
				if res then -- 2362
					Content:saveAsync(output, res) -- 2363
					return print("Minify " .. tostring(file)) -- 2364
				else -- 2366
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2366
				end -- 2362
			else -- 2368
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2368
			end -- 2359
		end) -- 2355
		sleep() -- 2369
	end -- 2354
	wait(function() -- 2370
		return count == fileCount -- 2370
	end) -- 2370
	if #errors > 0 then -- 2371
		print(table.concat(errors, '\n')) -- 2372
	end -- 2371
	print("Obfuscation done.") -- 2373
	return files -- 2374
end -- 2338
local zipping = false -- 2376
HttpServer:postSchedule("/zip", function(req) -- 2378
	do -- 2379
		local _type_0 = type(req) -- 2379
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2379
		if _tab_0 then -- 2379
			local path -- 2379
			do -- 2379
				local _obj_0 = req.body -- 2379
				local _type_1 = type(_obj_0) -- 2379
				if "table" == _type_1 or "userdata" == _type_1 then -- 2379
					path = _obj_0.path -- 2379
				end -- 2379
			end -- 2379
			local zipFile -- 2379
			do -- 2379
				local _obj_0 = req.body -- 2379
				local _type_1 = type(_obj_0) -- 2379
				if "table" == _type_1 or "userdata" == _type_1 then -- 2379
					zipFile = _obj_0.zipFile -- 2379
				end -- 2379
			end -- 2379
			local obfuscated -- 2379
			do -- 2379
				local _obj_0 = req.body -- 2379
				local _type_1 = type(_obj_0) -- 2379
				if "table" == _type_1 or "userdata" == _type_1 then -- 2379
					obfuscated = _obj_0.obfuscated -- 2379
				end -- 2379
			end -- 2379
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2379
				if zipping then -- 2380
					goto failed -- 2380
				end -- 2380
				zipping = true -- 2381
				local _ <close> = setmetatable({ }, { -- 2382
					__close = function() -- 2382
						zipping = false -- 2382
					end -- 2382
				}) -- 2382
				if not Content:exist(path) then -- 2383
					goto failed -- 2383
				end -- 2383
				Content:mkdir(Path:getPath(zipFile)) -- 2384
				if obfuscated then -- 2385
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2386
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2387
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2388
					Content:remove(scriptPath) -- 2389
					Content:remove(obfuscatedPath) -- 2390
					Content:remove(tempPath) -- 2391
					Content:mkdir(scriptPath) -- 2392
					Content:mkdir(obfuscatedPath) -- 2393
					Content:mkdir(tempPath) -- 2394
					if not Content:copyAsync(path, tempPath) then -- 2395
						goto failed -- 2395
					end -- 2395
					local Entry = require("Script.Dev.Entry") -- 2396
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2397
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2398
						"tl", -- 2398
						"yue", -- 2398
						"lua", -- 2398
						"ts", -- 2398
						"tsx", -- 2398
						"vs", -- 2398
						"bl", -- 2398
						"xml", -- 2398
						"wa", -- 2398
						"mod" -- 2398
					}, true) -- 2398
					for _index_0 = 1, #scriptFiles do -- 2399
						local file = scriptFiles[_index_0] -- 2399
						Content:remove(Path(tempPath, file)) -- 2400
					end -- 2399
					for _index_0 = 1, #luaFiles do -- 2401
						local file = luaFiles[_index_0] -- 2401
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2402
					end -- 2401
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2403
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2404
					end) then -- 2403
						goto failed -- 2403
					end -- 2403
					return { -- 2405
						success = true -- 2405
					} -- 2405
				else -- 2407
					return { -- 2407
						success = Content:zipAsync(path, zipFile, function(file) -- 2407
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2408
						end) -- 2407
					} -- 2407
				end -- 2385
			end -- 2379
		end -- 2379
	end -- 2379
	::failed:: -- 2409
	return { -- 2378
		success = false -- 2378
	} -- 2378
end) -- 2378
HttpServer:postSchedule("/unzip", function(req) -- 2411
	do -- 2412
		local _type_0 = type(req) -- 2412
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2412
		if _tab_0 then -- 2412
			local zipFile -- 2412
			do -- 2412
				local _obj_0 = req.body -- 2412
				local _type_1 = type(_obj_0) -- 2412
				if "table" == _type_1 or "userdata" == _type_1 then -- 2412
					zipFile = _obj_0.zipFile -- 2412
				end -- 2412
			end -- 2412
			local path -- 2412
			do -- 2412
				local _obj_0 = req.body -- 2412
				local _type_1 = type(_obj_0) -- 2412
				if "table" == _type_1 or "userdata" == _type_1 then -- 2412
					path = _obj_0.path -- 2412
				end -- 2412
			end -- 2412
			if zipFile ~= nil and path ~= nil then -- 2412
				return { -- 2413
					success = Content:unzipAsync(zipFile, path, function(file) -- 2413
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2414
					end) -- 2413
				} -- 2413
			end -- 2412
		end -- 2412
	end -- 2412
	return { -- 2411
		success = false -- 2411
	} -- 2411
end) -- 2411
HttpServer:post("/editing-info", function(req) -- 2416
	local Entry = require("Script.Dev.Entry") -- 2417
	local config = Entry.getConfig() -- 2418
	local _type_0 = type(req) -- 2419
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2419
	local _match_0 = false -- 2419
	if _tab_0 then -- 2419
		local editingInfo -- 2419
		do -- 2419
			local _obj_0 = req.body -- 2419
			local _type_1 = type(_obj_0) -- 2419
			if "table" == _type_1 or "userdata" == _type_1 then -- 2419
				editingInfo = _obj_0.editingInfo -- 2419
			end -- 2419
		end -- 2419
		if editingInfo ~= nil then -- 2419
			_match_0 = true -- 2419
			config.editingInfo = editingInfo -- 2420
			return { -- 2421
				success = true -- 2421
			} -- 2421
		end -- 2419
	end -- 2419
	if not _match_0 then -- 2419
		if not (config.editingInfo ~= nil) then -- 2423
			local folder -- 2424
			if App.locale:match('^zh') then -- 2424
				folder = 'zh-Hans' -- 2424
			else -- 2424
				folder = 'en' -- 2424
			end -- 2424
			config.editingInfo = json.encode({ -- 2426
				index = 0, -- 2426
				files = { -- 2428
					{ -- 2429
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2429
						title = "welcome.md" -- 2430
					} -- 2428
				} -- 2427
			}) -- 2425
		end -- 2423
		return { -- 2434
			success = true, -- 2434
			editingInfo = config.editingInfo -- 2434
		} -- 2434
	end -- 2419
end) -- 2416
HttpServer:post("/command", function(req) -- 2436
	do -- 2437
		local _type_0 = type(req) -- 2437
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2437
		if _tab_0 then -- 2437
			local code -- 2437
			do -- 2437
				local _obj_0 = req.body -- 2437
				local _type_1 = type(_obj_0) -- 2437
				if "table" == _type_1 or "userdata" == _type_1 then -- 2437
					code = _obj_0.code -- 2437
				end -- 2437
			end -- 2437
			local log -- 2437
			do -- 2437
				local _obj_0 = req.body -- 2437
				local _type_1 = type(_obj_0) -- 2437
				if "table" == _type_1 or "userdata" == _type_1 then -- 2437
					log = _obj_0.log -- 2437
				end -- 2437
			end -- 2437
			if code ~= nil and log ~= nil then -- 2437
				emit("AppCommand", code, log) -- 2438
				return { -- 2439
					success = true -- 2439
				} -- 2439
			end -- 2437
		end -- 2437
	end -- 2437
	return { -- 2436
		success = false -- 2436
	} -- 2436
end) -- 2436
HttpServer:post("/log/save", function() -- 2441
	local folder = ".download" -- 2442
	local fullLogFile = "dora_full_logs.txt" -- 2443
	local fullFolder = Path(Content.writablePath, folder) -- 2444
	Content:mkdir(fullFolder) -- 2445
	local logPath = Path(fullFolder, fullLogFile) -- 2446
	if App:saveLog(logPath) then -- 2447
		return { -- 2448
			success = true, -- 2448
			path = Path(folder, fullLogFile) -- 2448
		} -- 2448
	end -- 2447
	return { -- 2441
		success = false -- 2441
	} -- 2441
end) -- 2441
local tailLines -- 2450
tailLines = function(text, count) -- 2450
	local lines = { } -- 2451
	text = text:gsub("\r\n", "\n") -- 2452
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2453
		lines[#lines + 1] = line -- 2454
	end -- 2453
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2455
		table.remove(lines) -- 2456
	end -- 2455
	local start = math.max(1, #lines - count + 1) -- 2457
	local out = { } -- 2458
	for i = start, #lines do -- 2459
		out[#out + 1] = lines[i] -- 2460
	end -- 2459
	return table.concat(out, "\n") -- 2461
end -- 2450
HttpServer:post("/log", function(req) -- 2463
	local count = 100 -- 2464
	if req and req.body and req.body.count ~= nil then -- 2465
		count = req.body.count -- 2466
	end -- 2465
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2467
		return { -- 2468
			success = false, -- 2468
			message = "count must be a positive integer" -- 2468
		} -- 2468
	end -- 2467
	local folder = ".download" -- 2469
	local fullLogFile = "dora_full_logs.txt" -- 2470
	local fullFolder = Path(Content.writablePath, folder) -- 2471
	Content:mkdir(fullFolder) -- 2472
	local logPath = Path(fullFolder, fullLogFile) -- 2473
	if App:saveLog(logPath) then -- 2474
		local text = Content:load(logPath) -- 2475
		if text then -- 2476
			return { -- 2477
				success = true, -- 2477
				log = tailLines(text, count) -- 2477
			} -- 2477
		else -- 2479
			return { -- 2479
				success = false, -- 2479
				message = "failed to read log" -- 2479
			} -- 2479
		end -- 2476
	else -- 2481
		return { -- 2481
			success = false, -- 2481
			message = "failed to save log" -- 2481
		} -- 2481
	end -- 2474
	return { -- 2463
		success = false -- 2463
	} -- 2463
end) -- 2463
HttpServer:post("/yarn/check", function(req) -- 2483
	local yarncompile = require("yarncompile") -- 2484
	do -- 2485
		local _type_0 = type(req) -- 2485
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2485
		if _tab_0 then -- 2485
			local code -- 2485
			do -- 2485
				local _obj_0 = req.body -- 2485
				local _type_1 = type(_obj_0) -- 2485
				if "table" == _type_1 or "userdata" == _type_1 then -- 2485
					code = _obj_0.code -- 2485
				end -- 2485
			end -- 2485
			if code ~= nil then -- 2485
				local jsonObject = json.decode(code) -- 2486
				if jsonObject then -- 2486
					local errors = { } -- 2487
					local _list_0 = jsonObject.nodes -- 2488
					for _index_0 = 1, #_list_0 do -- 2488
						local node = _list_0[_index_0] -- 2488
						local title, body = node.title, node.body -- 2489
						local luaCode, err = yarncompile(body) -- 2490
						if not luaCode then -- 2490
							errors[#errors + 1] = title .. ":" .. err -- 2491
						end -- 2490
					end -- 2488
					return { -- 2492
						success = true, -- 2492
						syntaxError = table.concat(errors, "\n\n") -- 2492
					} -- 2492
				end -- 2486
			end -- 2485
		end -- 2485
	end -- 2485
	return { -- 2483
		success = false -- 2483
	} -- 2483
end) -- 2483
HttpServer:post("/yarn/check-file", function(req) -- 2494
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
				local res, _, err = yarncompile(code, true) -- 2497
				if not res then -- 2497
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2498
					return { -- 2499
						success = false, -- 2499
						message = message, -- 2499
						line = line, -- 2499
						column = column, -- 2499
						node = node -- 2499
					} -- 2499
				end -- 2497
			end -- 2496
		end -- 2496
	end -- 2496
	return { -- 2494
		success = true -- 2494
	} -- 2494
end) -- 2494
getWaProjectDirFromFile = function(file) -- 2501
	local current -- 2502
	if Content:isdir(file) then -- 2502
		current = file -- 2502
	else -- 2502
		current = Path:getPath(file) -- 2502
	end -- 2502
	if current == "" then -- 2503
		return nil -- 2503
	end -- 2503
	repeat -- 2504
		local modPath = Path(current, "wa.mod") -- 2505
		if Content:exist(modPath) then -- 2506
			return current, modPath -- 2507
		end -- 2506
		local parent = Path:getPath(current) -- 2508
		if parent == "" or parent == current then -- 2509
			break -- 2509
		end -- 2509
		current = parent -- 2510
	until false -- 2504
	return nil -- 2512
end -- 2501
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2514
	do -- 2515
		local _type_0 = type(req) -- 2515
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2515
		if _tab_0 then -- 2515
			local path -- 2515
			do -- 2515
				local _obj_0 = req.body -- 2515
				local _type_1 = type(_obj_0) -- 2515
				if "table" == _type_1 or "userdata" == _type_1 then -- 2515
					path = _obj_0.path -- 2515
				end -- 2515
			end -- 2515
			if path ~= nil then -- 2515
				local projDir = getWaProjectDirFromFile(path) -- 2516
				if projDir then -- 2516
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2517
					if not Content:exist(sourceDoraPath) then -- 2518
						return { -- 2519
							success = false, -- 2519
							message = "missing dora template" -- 2519
						} -- 2519
					end -- 2518
					local targetVendorPath = Path(projDir, "vendor") -- 2520
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2521
					if not Content:exist(targetVendorPath) then -- 2522
						if not Content:mkdir(targetVendorPath) then -- 2523
							return { -- 2524
								success = false, -- 2524
								message = "failed to create vendor folder" -- 2524
							} -- 2524
						end -- 2523
					elseif not Content:isdir(targetVendorPath) then -- 2525
						return { -- 2526
							success = false, -- 2526
							message = "vendor path is not a folder" -- 2526
						} -- 2526
					end -- 2522
					if Content:exist(targetDoraPath) then -- 2527
						if not Content:remove(targetDoraPath) then -- 2528
							return { -- 2529
								success = false, -- 2529
								message = "failed to remove old dora" -- 2529
							} -- 2529
						end -- 2528
					end -- 2527
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2530
						return { -- 2531
							success = false, -- 2531
							message = "failed to copy dora" -- 2531
						} -- 2531
					end -- 2530
					return { -- 2532
						success = true -- 2532
					} -- 2532
				else -- 2534
					return { -- 2534
						success = false, -- 2534
						message = 'Wa file needs a project' -- 2534
					} -- 2534
				end -- 2516
			end -- 2515
		end -- 2515
	end -- 2515
	return { -- 2514
		success = false, -- 2514
		message = "invalid call" -- 2514
	} -- 2514
end) -- 2514
HttpServer:postSchedule("/wa/build", function(req) -- 2536
	do -- 2537
		local _type_0 = type(req) -- 2537
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2537
		if _tab_0 then -- 2537
			local path -- 2537
			do -- 2537
				local _obj_0 = req.body -- 2537
				local _type_1 = type(_obj_0) -- 2537
				if "table" == _type_1 or "userdata" == _type_1 then -- 2537
					path = _obj_0.path -- 2537
				end -- 2537
			end -- 2537
			if path ~= nil then -- 2537
				local projDir = getWaProjectDirFromFile(path) -- 2538
				if projDir then -- 2538
					local message = Wasm:buildWaAsync(projDir) -- 2539
					if message == "" then -- 2540
						return { -- 2541
							success = true -- 2541
						} -- 2541
					else -- 2543
						return { -- 2543
							success = false, -- 2543
							message = message -- 2543
						} -- 2543
					end -- 2540
				else -- 2545
					return { -- 2545
						success = false, -- 2545
						message = 'Wa file needs a project' -- 2545
					} -- 2545
				end -- 2538
			end -- 2537
		end -- 2537
	end -- 2537
	return { -- 2546
		success = false, -- 2546
		message = 'failed to build' -- 2546
	} -- 2546
end) -- 2536
HttpServer:postSchedule("/wa/format", function(req) -- 2548
	do -- 2549
		local _type_0 = type(req) -- 2549
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2549
		if _tab_0 then -- 2549
			local file -- 2549
			do -- 2549
				local _obj_0 = req.body -- 2549
				local _type_1 = type(_obj_0) -- 2549
				if "table" == _type_1 or "userdata" == _type_1 then -- 2549
					file = _obj_0.file -- 2549
				end -- 2549
			end -- 2549
			if file ~= nil then -- 2549
				local code = Wasm:formatWaAsync(file) -- 2550
				if code == "" then -- 2551
					return { -- 2552
						success = false -- 2552
					} -- 2552
				else -- 2554
					return { -- 2554
						success = true, -- 2554
						code = code -- 2554
					} -- 2554
				end -- 2551
			end -- 2549
		end -- 2549
	end -- 2549
	return { -- 2555
		success = false -- 2555
	} -- 2555
end) -- 2548
HttpServer:postSchedule("/wa/create", function(req) -- 2557
	do -- 2558
		local _type_0 = type(req) -- 2558
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2558
		if _tab_0 then -- 2558
			local path -- 2558
			do -- 2558
				local _obj_0 = req.body -- 2558
				local _type_1 = type(_obj_0) -- 2558
				if "table" == _type_1 or "userdata" == _type_1 then -- 2558
					path = _obj_0.path -- 2558
				end -- 2558
			end -- 2558
			if path ~= nil then -- 2558
				if not Content:exist(Path:getPath(path)) then -- 2559
					return { -- 2560
						success = false, -- 2560
						message = "target path not existed" -- 2560
					} -- 2560
				end -- 2559
				if Content:exist(path) then -- 2561
					return { -- 2562
						success = false, -- 2562
						message = "target project folder existed" -- 2562
					} -- 2562
				end -- 2561
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2563
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2564
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2565
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2566
					return { -- 2569
						success = false, -- 2569
						message = "missing template project" -- 2569
					} -- 2569
				end -- 2566
				if not Content:mkdir(path) then -- 2570
					return { -- 2571
						success = false, -- 2571
						message = "failed to create project folder" -- 2571
					} -- 2571
				end -- 2570
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2572
					Content:remove(path) -- 2573
					return { -- 2574
						success = false, -- 2574
						message = "failed to copy template" -- 2574
					} -- 2574
				end -- 2572
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2575
					Content:remove(path) -- 2576
					return { -- 2577
						success = false, -- 2577
						message = "failed to copy template" -- 2577
					} -- 2577
				end -- 2575
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2578
					Content:remove(path) -- 2579
					return { -- 2580
						success = false, -- 2580
						message = "failed to copy template" -- 2580
					} -- 2580
				end -- 2578
				return { -- 2581
					success = true -- 2581
				} -- 2581
			end -- 2558
		end -- 2558
	end -- 2558
	return { -- 2557
		success = false, -- 2557
		message = "invalid call" -- 2557
	} -- 2557
end) -- 2557
local tsBuildGlobs = { -- 2584
	"**/*.ts", -- 2584
	"**/*.tsx", -- 2585
	"!**/.*/**", -- 2586
	"!**/node_modules/**" -- 2587
} -- 2583
local tsSnapshotGlobs = { -- 2590
	"**/*.ts", -- 2590
	"**/*.tsx", -- 2591
	"**/*.lua", -- 2592
	"!**/.*/**", -- 2593
	"!**/node_modules/**" -- 2594
} -- 2589
local collectTSVirtualFiles -- 2596
collectTSVirtualFiles = function(sourceRoot) -- 2596
	local files = { } -- 2597
	local seen = { } -- 2598
	local addFile -- 2599
	addFile = function(file, moduleName, virtualFile) -- 2599
		if moduleName == nil then -- 2599
			moduleName = nil -- 2599
		end -- 2599
		if virtualFile == nil then -- 2599
			virtualFile = nil -- 2599
		end -- 2599
		local targetFile = virtualFile or file -- 2600
		do -- 2601
			local entry = seen[targetFile] -- 2601
			if entry then -- 2601
				if moduleName and moduleName ~= "" then -- 2602
					entry.moduleName = moduleName -- 2602
				end -- 2602
				return -- 2603
			end -- 2601
		end -- 2601
		local content = Content:load(file) -- 2604
		if content then -- 2604
			local entry = { -- 2605
				file = targetFile, -- 2605
				content = content -- 2605
			} -- 2605
			if moduleName and moduleName ~= "" then -- 2606
				entry.moduleName = moduleName -- 2606
			end -- 2606
			seen[targetFile] = entry -- 2607
			files[#files + 1] = entry -- 2608
		end -- 2604
	end -- 2599
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2609
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2610
		for _index_0 = 1, #_list_0 do -- 2610
			local subFile = _list_0[_index_0] -- 2610
			addFile(Path(sourceRoot, subFile)) -- 2611
		end -- 2610
		local libraryRoots = { -- 2613
			Path(sourceRoot, "Script", "Lib"), -- 2613
			Path(sourceRoot, "Lib"), -- 2614
			Path(Content.assetPath, "Script", "Lib") -- 2615
		} -- 2612
		for _index_0 = 1, #libraryRoots do -- 2616
			local libraryRoot = libraryRoots[_index_0] -- 2616
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2617
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2618
				for _index_1 = 1, #_list_1 do -- 2618
					local subFile = _list_1[_index_1] -- 2618
					local file = Path(libraryRoot, subFile) -- 2619
					local virtualFile = Path(sourceRoot, subFile) -- 2620
					addFile(file, nil, virtualFile) -- 2621
				end -- 2618
			end -- 2617
		end -- 2616
	end -- 2609
	local locale -- 2622
	if App.locale:match('^zh') then -- 2622
		locale = 'zh-Hans' -- 2622
	else -- 2622
		locale = 'en' -- 2622
	end -- 2622
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2623
	local _list_0 = Content:getFiles(declarationRoot) -- 2624
	for _index_0 = 1, #_list_0 do -- 2624
		local file = _list_0[_index_0] -- 2624
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2625
			local fullPath = Path(declarationRoot, file) -- 2626
			local moduleName = Path:getName(Path:getName(file)) -- 2627
			addFile(fullPath, moduleName) -- 2628
		end -- 2625
	end -- 2624
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2629
	local lualibBundleTarget -- 2630
	if sourceRoot then -- 2630
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2630
	else -- 2630
		lualibBundleTarget = "lualib_bundle.lua" -- 2630
	end -- 2630
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2631
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2632
	local _list_1 = Content:getFiles(lualibRoot) -- 2633
	for _index_0 = 1, #_list_1 do -- 2633
		local file = _list_1[_index_0] -- 2633
		if Path:getExt(file) == "lua" then -- 2634
			local virtualFile -- 2635
			if sourceRoot then -- 2635
				virtualFile = Path(sourceRoot, "lualib", file) -- 2635
			else -- 2635
				virtualFile = Path("lualib", file) -- 2635
			end -- 2635
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2636
		end -- 2634
	end -- 2633
	return files -- 2637
end -- 2596
local transpileTSFileWithWebIDE -- 2639
do -- 2639
	local tsReadyTimeout <const> = 5 -- 2640
	local tsBuildTimeout <const> = 30 -- 2641
	local tsBuildRequestId = 0 -- 2642
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files) -- 2643
		tsBuildRequestId = tsBuildRequestId + 1 -- 2644
		local requestId = tsBuildRequestId -- 2645
		local done = false -- 2646
		local ready = false -- 2647
		local result = nil -- 2648
		local listener = Node() -- 2649
		listener:gslot("AppWS", function(event) -- 2650
			if event.type == "Receive" then -- 2651
				local res = json.decode(event.msg) -- 2652
				if res then -- 2652
					if res.name == "TranspileTSProbe" and res.id == requestId then -- 2653
						ready = true -- 2654
					elseif res.name == "TranspileTS" and res.id == requestId then -- 2655
						listener:removeFromParent() -- 2656
						if res.success then -- 2657
							local luaFile = Path:replaceExt(file, "lua") -- 2658
							Content:save(luaFile, res.luaCode) -- 2659
							result = { -- 2660
								success = true, -- 2660
								file = file -- 2660
							} -- 2660
						else -- 2662
							result = { -- 2662
								success = false, -- 2662
								file = file, -- 2662
								message = res.message -- 2662
							} -- 2662
						end -- 2657
						done = true -- 2663
					end -- 2653
				end -- 2652
			end -- 2651
		end) -- 2650
		emit("AppWS", "Send", json.encode({ -- 2664
			name = "TranspileTSProbe", -- 2664
			id = requestId -- 2664
		})) -- 2664
		local readyDeadline = App.runningTime + tsReadyTimeout -- 2665
		wait(function() -- 2666
			return ready or HttpServer.wsConnectionCount == 0 or App.runningTime >= readyDeadline -- 2666
		end) -- 2666
		if not ready then -- 2667
			listener:removeFromParent() -- 2668
			if HttpServer.wsConnectionCount == 0 then -- 2669
				return { -- 2670
					success = false, -- 2670
					file = file, -- 2670
					message = "Web IDE disconnected" -- 2670
				} -- 2670
			end -- 2669
			return { -- 2671
				success = false, -- 2671
				file = file, -- 2671
				message = "TypeScript transpiler is not ready" -- 2671
			} -- 2671
		end -- 2667
		emit("AppWS", "Send", json.encode({ -- 2672
			name = "TranspileTS", -- 2672
			id = requestId, -- 2672
			file = file, -- 2672
			content = content, -- 2672
			projectRoot = sourceRoot, -- 2672
			files = files -- 2672
		})) -- 2672
		local deadline = App.runningTime + tsBuildTimeout -- 2673
		wait(function() -- 2674
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline -- 2674
		end) -- 2674
		if not done then -- 2675
			listener:removeFromParent() -- 2676
			if HttpServer.wsConnectionCount == 0 then -- 2677
				return { -- 2678
					success = false, -- 2678
					file = file, -- 2678
					message = "Web IDE disconnected" -- 2678
				} -- 2678
			end -- 2677
			return { -- 2679
				success = false, -- 2679
				file = file, -- 2679
				message = "TypeScript transpile timed out" -- 2679
			} -- 2679
		end -- 2675
		return result -- 2680
	end -- 2643
end -- 2639
local compilerReadyTimeout <const> = 15 -- 2682
local compilerBuildTimeout <const> = 30 -- 2683
local compilerIdleCloseSeconds <const> = 8 -- 2684
local compilerReady = false -- 2685
local compilerRequested = false -- 2686
local compilerUsers = 0 -- 2687
local compilerCloseGeneration = 0 -- 2688
local compilerJobId = 0 -- 2689
local compilerJobs = { } -- 2690
local compilerResults = { } -- 2691
local compilerInFlight = { } -- 2692
HttpServer:post("/compiler/ready", function() -- 2694
	compilerReady = true -- 2695
	return { -- 2696
		success = true -- 2696
	} -- 2696
end) -- 2694
HttpServer:post("/compiler/poll", function() -- 2698
	compilerReady = true -- 2699
	local job = table.remove(compilerJobs, 1) -- 2700
	if job then -- 2701
		compilerInFlight[job.id] = true -- 2702
	end -- 2701
	return { -- 2703
		success = true, -- 2703
		job = job -- 2703
	} -- 2703
end) -- 2698
HttpServer:post("/compiler/result", function(req) -- 2705
	do -- 2706
		local _type_0 = type(req) -- 2706
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2706
		if _tab_0 then -- 2706
			local body = req.body -- 2706
			if body ~= nil then -- 2706
				local id = body.id -- 2707
				if not (id and compilerInFlight[id]) then -- 2708
					return { -- 2708
						success = false, -- 2708
						message = "invalid compiler job" -- 2708
					} -- 2708
				end -- 2708
				compilerInFlight[id] = nil -- 2709
				compilerResults[id] = body -- 2710
				return { -- 2711
					success = true -- 2711
				} -- 2711
			end -- 2706
		end -- 2706
	end -- 2706
	return { -- 2705
		success = false -- 2705
	} -- 2705
end) -- 2705
local acquireCompiler -- 2713
acquireCompiler = function() -- 2713
	compilerUsers = compilerUsers + 1 -- 2714
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2715
	if not compilerRequested then -- 2716
		compilerRequested = true -- 2717
		compilerReady = false -- 2718
		return emit("AppWebView", "/compiler.html", true) -- 2719
	end -- 2716
end -- 2713
local releaseCompiler -- 2721
releaseCompiler = function() -- 2721
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2722
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2723
	if not (compilerUsers == 0) then -- 2724
		return -- 2724
	end -- 2724
	local closeGeneration = compilerCloseGeneration -- 2725
	return thread(function() -- 2726
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2727
		wait(function() -- 2728
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or HttpServer.wsConnectionCount > 0 or App.runningTime >= closeDeadline -- 2729
		end) -- 2728
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2733
			compilerRequested = false -- 2734
			compilerReady = false -- 2735
			return emit("AppWebView", "/compiler.html", false) -- 2736
		end -- 2733
	end) -- 2726
end -- 2721
local removeCompilerJob -- 2738
removeCompilerJob = function(id) -- 2738
	for index = #compilerJobs, 1, -1 do -- 2739
		if compilerJobs[index].id == id then -- 2740
			table.remove(compilerJobs, index) -- 2741
		end -- 2740
	end -- 2739
	compilerInFlight[id] = nil -- 2742
	compilerResults[id] = nil -- 2743
end -- 2738
local transpileTSFileWithCompiler -- 2745
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2745
	acquireCompiler() -- 2746
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2747
	wait(function() -- 2748
		return compilerReady or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2748
	end) -- 2748
	if not compilerReady then -- 2749
		releaseCompiler() -- 2750
		if isCancelled and isCancelled() then -- 2751
			return { -- 2752
				success = false, -- 2752
				file = file, -- 2752
				message = "build canceled", -- 2752
				interrupted = true -- 2752
			} -- 2752
		end -- 2751
		return { -- 2753
			success = false, -- 2753
			file = file, -- 2753
			message = "TypeScript compiler WebView is not ready" -- 2753
		} -- 2753
	end -- 2749
	compilerJobId = compilerJobId + 1 -- 2754
	local jobId = compilerJobId -- 2755
	compilerJobs[#compilerJobs + 1] = { -- 2757
		id = jobId, -- 2757
		file = file, -- 2758
		content = content, -- 2759
		projectRoot = sourceRoot, -- 2760
		files = files -- 2761
	} -- 2756
	local deadline = App.runningTime + compilerBuildTimeout -- 2762
	wait(function() -- 2763
		return compilerResults[jobId] or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2763
	end) -- 2763
	local response = compilerResults[jobId] -- 2764
	removeCompilerJob(jobId) -- 2765
	releaseCompiler() -- 2766
	if not response then -- 2767
		if isCancelled and isCancelled() then -- 2768
			return { -- 2769
				success = false, -- 2769
				file = file, -- 2769
				message = "build canceled", -- 2769
				interrupted = true -- 2769
			} -- 2769
		end -- 2768
		return { -- 2770
			success = false, -- 2770
			file = file, -- 2770
			message = "TypeScript transpile timed out" -- 2770
		} -- 2770
	end -- 2767
	if response.success then -- 2771
		local luaFile = Path:replaceExt(file, "lua") -- 2772
		if Content:save(luaFile, response.luaCode) then -- 2773
			return { -- 2774
				success = true, -- 2774
				file = file -- 2774
			} -- 2774
		end -- 2773
		return { -- 2775
			success = false, -- 2775
			file = file, -- 2775
			message = "failed to save " .. tostring(luaFile) -- 2775
		} -- 2775
	end -- 2771
	return { -- 2776
		success = false, -- 2776
		file = file, -- 2776
		message = response.message or "TypeScript transpile failed" -- 2776
	} -- 2776
end -- 2745
local transpileTSFile -- 2778
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2778
	if App.platform == "Android" and HttpServer.wsConnectionCount == 0 then -- 2779
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2780
	end -- 2779
	return transpileTSFileWithWebIDE(file, content, sourceRoot, files) -- 2781
end -- 2778
local _anon_func_8 = function(path) -- 2796
	local _val_0 = Path:getExt(path) -- 2796
	return "ts" == _val_0 or "tsx" == _val_0 -- 2796
end -- 2796
HttpServer:postSchedule("/ts/build", function(req) -- 2783
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2784
	local buildSucceeded = false -- 2785
	local _ <close> = setmetatable({ }, { -- 2786
		__close = function() -- 2786
			return finishUpdate(buildSucceeded) -- 2786
		end -- 2786
	}) -- 2786
	do -- 2787
		local _type_0 = type(req) -- 2787
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2787
		if _tab_0 then -- 2787
			local path -- 2787
			do -- 2787
				local _obj_0 = req.body -- 2787
				local _type_1 = type(_obj_0) -- 2787
				if "table" == _type_1 or "userdata" == _type_1 then -- 2787
					path = _obj_0.path -- 2787
				end -- 2787
			end -- 2787
			if path ~= nil then -- 2787
				if App.platform ~= "Android" and HttpServer.wsConnectionCount == 0 then -- 2788
					return { -- 2789
						success = false, -- 2789
						message = "Web IDE not connected" -- 2789
					} -- 2789
				end -- 2788
				local projectRoot = req.body.projectRoot -- 2790
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2791
				if not Content:exist(path) then -- 2792
					return { -- 2793
						success = false, -- 2793
						message = "path not existed" -- 2793
					} -- 2793
				end -- 2792
				local messages = { } -- 2794
				if not Content:isdir(path) then -- 2795
					if not (_anon_func_8(path)) then -- 2796
						return { -- 2797
							success = false, -- 2797
							message = "expecting a TypeScript file" -- 2797
						} -- 2797
					end -- 2796
					local content = Content:load(path) -- 2798
					if not content then -- 2799
						return { -- 2800
							success = false, -- 2800
							message = "failed to read file" -- 2800
						} -- 2800
					end -- 2799
					emit("AppWS", "Send", json.encode({ -- 2801
						name = "UpdateFile", -- 2801
						file = path, -- 2801
						exists = true, -- 2801
						content = content, -- 2801
						projectRoot = sourceRoot -- 2801
					})) -- 2801
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2802
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2803
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2804
					end -- 2802
				else -- 2806
					local fileData = { } -- 2806
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2807
					for _index_0 = 1, #_list_0 do -- 2807
						local subFile = _list_0[_index_0] -- 2807
						local file = Path(path, subFile) -- 2808
						local content = Content:load(file) -- 2809
						if content then -- 2809
							fileData[file] = content -- 2810
							emit("AppWS", "Send", json.encode({ -- 2811
								name = "UpdateFile", -- 2811
								file = file, -- 2811
								exists = true, -- 2811
								content = content, -- 2811
								projectRoot = sourceRoot -- 2811
							})) -- 2811
						else -- 2813
							messages[#messages + 1] = { -- 2813
								success = false, -- 2813
								file = file, -- 2813
								message = "failed to read file" -- 2813
							} -- 2813
						end -- 2809
					end -- 2807
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2814
					for file, content in pairs(fileData) do -- 2815
						if "d" == Path:getExt(Path:getName(file)) then -- 2816
							goto _continue_0 -- 2816
						end -- 2816
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2817
						::_continue_0:: -- 2816
					end -- 2815
				end -- 2795
				local success = true -- 2818
				for _index_0 = 1, #messages do -- 2819
					local item = messages[_index_0] -- 2819
					if not item.success then -- 2820
						success = false -- 2820
					end -- 2820
				end -- 2819
				local message = nil -- 2821
				if not success then -- 2822
					message = "TypeScript compilation failed" -- 2822
				end -- 2822
				buildSucceeded = success -- 2823
				return { -- 2824
					success = success, -- 2824
					messages = messages, -- 2824
					message = message -- 2824
				} -- 2824
			end -- 2787
		end -- 2787
	end -- 2787
	return { -- 2783
		success = false -- 2783
	} -- 2783
end) -- 2783
HttpServer:post("/download", function(req) -- 2826
	do -- 2827
		local _type_0 = type(req) -- 2827
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2827
		if _tab_0 then -- 2827
			local url -- 2827
			do -- 2827
				local _obj_0 = req.body -- 2827
				local _type_1 = type(_obj_0) -- 2827
				if "table" == _type_1 or "userdata" == _type_1 then -- 2827
					url = _obj_0.url -- 2827
				end -- 2827
			end -- 2827
			local target -- 2827
			do -- 2827
				local _obj_0 = req.body -- 2827
				local _type_1 = type(_obj_0) -- 2827
				if "table" == _type_1 or "userdata" == _type_1 then -- 2827
					target = _obj_0.target -- 2827
				end -- 2827
			end -- 2827
			if url ~= nil and target ~= nil then -- 2827
				local Entry = require("Script.Dev.Entry") -- 2828
				Entry.downloadFile(url, target) -- 2829
				return { -- 2830
					success = true -- 2830
				} -- 2830
			end -- 2827
		end -- 2827
	end -- 2827
	return { -- 2826
		success = false -- 2826
	} -- 2826
end) -- 2826
local isDesktopPlatform -- 2832
isDesktopPlatform = function() -- 2832
	local _val_0 = App.platform -- 2833
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2833
end -- 2832
local getServerStatus -- 2835
getServerStatus = function() -- 2835
	local Entry = require("Script.Dev.Entry") -- 2836
	local running = Entry.getCurrentEntryStatus() -- 2837
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2838
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2839
	return { -- 2841
		success = true, -- 2841
		platform = App.platform, -- 2842
		locale = App.locale, -- 2843
		version = App.version, -- 2844
		url = "http://localhost:8866", -- 2845
		wsConnectionCount = wsConnectionCount, -- 2846
		webIDEConnected = wsConnectionCount > 0, -- 2847
		assetPath = Content.assetPath, -- 2848
		writablePath = Content.writablePath, -- 2849
		appPath = Content.appPath, -- 2850
		waTemplateReady = waTemplateReady, -- 2851
		running = running -- 2852
	} -- 2840
end -- 2835
HttpServer:post("/status", function() -- 2855
	return getServerStatus() -- 2856
end) -- 2855
HttpServer:postSchedule("/doctor/fix", function(req) -- 2858
	do -- 2859
		local _type_0 = type(req) -- 2859
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2859
		if _tab_0 then -- 2859
			local openWebIDE -- 2859
			do -- 2859
				local _obj_0 = req.body -- 2859
				local _type_1 = type(_obj_0) -- 2859
				if "table" == _type_1 or "userdata" == _type_1 then -- 2859
					openWebIDE = _obj_0.openWebIDE -- 2859
				end -- 2859
			end -- 2859
			if openWebIDE ~= nil then -- 2859
				if not openWebIDE then -- 2860
					return { -- 2861
						success = false, -- 2861
						message = "nothing to fix" -- 2861
					} -- 2861
				end -- 2860
				local status = getServerStatus() -- 2862
				if status.webIDEConnected then -- 2863
					return { -- 2864
						success = true, -- 2864
						fixed = false, -- 2864
						message = "Web IDE already connected.", -- 2864
						status = status -- 2864
					} -- 2864
				end -- 2863
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2865
				if waitSeconds > 0 then -- 2866
					local deadline = os.time() + waitSeconds -- 2867
					repeat -- 2868
						sleep(0.2) -- 2869
						status = getServerStatus() -- 2870
						if status.webIDEConnected then -- 2871
							return { -- 2872
								success = true, -- 2872
								fixed = false, -- 2872
								reconnected = true, -- 2872
								message = "Web IDE reconnected.", -- 2872
								status = status -- 2872
							} -- 2872
						end -- 2871
					until os.time() >= deadline -- 2868
				end -- 2866
				if not isDesktopPlatform() then -- 2874
					return { -- 2875
						success = false, -- 2875
						message = "opening Web IDE is only supported on desktop platforms", -- 2875
						status = status -- 2875
					} -- 2875
				end -- 2874
				local url = "http://localhost:8866" -- 2876
				App:openURL(url) -- 2877
				status.openedURL = url -- 2878
				return { -- 2879
					success = true, -- 2879
					fixed = true, -- 2879
					message = "Opened Web IDE in the local browser.", -- 2879
					url = url, -- 2879
					status = status -- 2879
				} -- 2879
			end -- 2859
		end -- 2859
	end -- 2859
	return { -- 2858
		success = false, -- 2858
		message = "invalid call" -- 2858
	} -- 2858
end) -- 2858
local status = { } -- 2881
_module_0 = status -- 2882
status.transpileTSFile = transpileTSFile -- 2884
status.buildAsync = function(path) -- 2886
	if not Content:exist(path) then -- 2887
		return { -- 2888
			success = false, -- 2888
			file = path, -- 2888
			message = "file not existed" -- 2888
		} -- 2888
	end -- 2887
	do -- 2889
		local _exp_0 = Path:getExt(path) -- 2889
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2889
			if '' == Path:getExt(Path:getName(path)) then -- 2890
				local content = Content:loadAsync(path) -- 2891
				if content then -- 2891
					local resultCodes, err = compileFileAsync(path, content) -- 2892
					if resultCodes then -- 2892
						return { -- 2893
							success = true, -- 2893
							file = path -- 2893
						} -- 2893
					else -- 2895
						return { -- 2895
							success = false, -- 2895
							file = path, -- 2895
							message = err -- 2895
						} -- 2895
					end -- 2892
				end -- 2891
			end -- 2890
		elseif "lua" == _exp_0 then -- 2896
			local content = Content:loadAsync(path) -- 2897
			if content then -- 2897
				do -- 2898
					local isTIC80 = CheckTIC80Code(content) -- 2898
					if isTIC80 then -- 2898
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2899
					end -- 2898
				end -- 2898
				local success, info -- 2900
				do -- 2900
					local _obj_0 = luaCheck(path, content) -- 2900
					success, info = _obj_0.success, _obj_0.info -- 2900
				end -- 2900
				if success then -- 2901
					return { -- 2902
						success = true, -- 2902
						file = path -- 2902
					} -- 2902
				elseif info and #info > 0 then -- 2903
					local messages = { } -- 2904
					for _index_0 = 1, #info do -- 2905
						local _des_0 = info[_index_0] -- 2905
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2905
						local lineText = "" -- 2906
						if line then -- 2907
							local currentLine = 1 -- 2908
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2909
								if currentLine == line then -- 2910
									lineText = text -- 2911
									break -- 2912
								end -- 2910
								currentLine = currentLine + 1 -- 2913
							end -- 2909
						end -- 2907
						if line then -- 2914
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2915
						else -- 2917
							messages[#messages + 1] = message -- 2917
						end -- 2914
					end -- 2905
					return { -- 2918
						success = false, -- 2918
						file = path, -- 2918
						message = table.concat(messages, "\n") -- 2918
					} -- 2918
				else -- 2920
					return { -- 2920
						success = false, -- 2920
						file = path, -- 2920
						message = "lua check failed" -- 2920
					} -- 2920
				end -- 2901
			end -- 2897
		elseif "yarn" == _exp_0 then -- 2921
			local content = Content:loadAsync(path) -- 2922
			if content then -- 2922
				local res, _, err = yarncompile(content, true) -- 2923
				if res then -- 2923
					return { -- 2924
						success = true, -- 2924
						file = path -- 2924
					} -- 2924
				else -- 2926
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2926
					local lineText = "" -- 2927
					if line then -- 2928
						local currentLine = 1 -- 2929
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2930
							if currentLine == line then -- 2931
								lineText = text -- 2932
								break -- 2933
							end -- 2931
							currentLine = currentLine + 1 -- 2934
						end -- 2930
					end -- 2928
					if node ~= "" then -- 2935
						node = "node: " .. tostring(node) .. ", " -- 2936
					else -- 2937
						node = "" -- 2937
					end -- 2935
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2938
					return { -- 2939
						success = false, -- 2939
						file = path, -- 2939
						message = message -- 2939
					} -- 2939
				end -- 2923
			end -- 2922
		end -- 2889
	end -- 2889
	return { -- 2940
		success = false, -- 2940
		file = path, -- 2940
		message = "invalid file to build" -- 2940
	} -- 2940
end -- 2886
HttpServer:postSchedule("/git/commit-files", function(req) -- 2942
	do -- 2943
		local _type_0 = type(req) -- 2943
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2943
		if _tab_0 then -- 2943
			local body = req.body -- 2943
			if body ~= nil then -- 2943
				local repoPath, commit = body.repoPath, body.commit -- 2944
				if gitInvalidRepoPath(repoPath) then -- 2945
					return { -- 2945
						success = false, -- 2945
						message = "invalid repoPath" -- 2945
					} -- 2945
				end -- 2945
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 2946
					return { -- 2946
						success = false, -- 2946
						message = "invalid commit" -- 2946
					} -- 2946
				end -- 2946
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 2947
				if not res.success then -- 2948
					return res -- 2948
				end -- 2948
				return { -- 2949
					success = true, -- 2949
					status = res.status, -- 2949
					data = res.status and res.status.data -- 2949
				} -- 2949
			end -- 2943
		end -- 2943
	end -- 2943
	return invalidArguments -- 2942
end) -- 2942
thread(function() -- 2951
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 2952
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 2953
	if Content:exist(doraWeb) then -- 2954
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 2955
		local heavyAssetsContent -- 2956
		if Content:exist(heavyAssets) then -- 2956
			heavyAssetsContent = Content:load(heavyAssets) -- 2956
		else -- 2956
			heavyAssetsContent = "" -- 2956
		end -- 2956
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 2957
		local runtimeIndexContent -- 2958
		if Content:exist(runtimeIndex) then -- 2958
			runtimeIndexContent = Content:load(runtimeIndex) -- 2958
		else -- 2958
			runtimeIndexContent = "" -- 2958
		end -- 2958
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) .. "\n" .. heavyAssetsContent .. "\n" .. runtimeIndexContent -- 2959
		local needReload -- 2960
		if Content:exist(doraReady) then -- 2960
			needReload = readyContent ~= Content:load(doraReady) -- 2961
		else -- 2962
			needReload = true -- 2962
		end -- 2960
		if needReload then -- 2963
			Content:remove(Path(Content.appPath, ".www")) -- 2964
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 2965
			Content:save(doraReady, readyContent) -- 2969
			print("Dora Dora is ready!") -- 2970
		end -- 2963
	end -- 2954
	if App.platform == "Emscripten" then -- 2971
		status.url = nil -- 2972
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 2973
	end -- 2971
	HttpServer:clearStaticCacheControls() -- 2974
	HttpServer:setStaticCacheControl("no-cache") -- 2975
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 2976
	if HttpServer:start(8866) then -- 2980
		local localIP = HttpServer.localIP -- 2981
		if localIP == "" then -- 2982
			localIP = "localhost" -- 2982
		end -- 2982
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 2983
		return HttpServer:startWS(8868) -- 2984
	else -- 2986
		status.url = nil -- 2986
		return print("8866 Port not available!") -- 2987
	end -- 2980
end) -- 2951
return _module_0 -- 1
