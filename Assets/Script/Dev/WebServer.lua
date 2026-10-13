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
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 64000") -- 1484
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
	]]) -- 1493
	return require("Agent.LLMConfigMigration").upgradeLLMConfig() -- 1512
end -- 1451
local normalizeContextWindow -- 1514
normalizeContextWindow = function(value) -- 1514
	local contextWindow = tonumber(value) -- 1515
	if contextWindow == nil or contextWindow < 64000 then -- 1516
		return 64000 -- 1517
	end -- 1516
	return math.max(64000, math.floor(contextWindow)) -- 1518
end -- 1514
local normalizeTemperature -- 1520
normalizeTemperature = function(value) -- 1520
	local temperature = tonumber(value) -- 1521
	if temperature == nil then -- 1522
		return 0.1 -- 1523
	end -- 1522
	return math.max(0, math.min(2, temperature)) -- 1524
end -- 1520
local normalizeMaxTokens -- 1526
normalizeMaxTokens = function(value) -- 1526
	local maxTokens = tonumber(value) -- 1527
	if maxTokens == nil or maxTokens < 1 then -- 1528
		return 64000 -- 1529
	end -- 1528
	return math.max(1, math.floor(maxTokens)) -- 1530
end -- 1526
local normalizeReasoningEffort -- 1532
normalizeReasoningEffort = function(value) -- 1532
	if value == nil then -- 1533
		return "" -- 1534
	end -- 1533
	local effort = tostring(value) -- 1535
	return effort:match("^%s*(.-)%s*$") or "" -- 1536
end -- 1532
local normalizeCustomOptions -- 1538
normalizeCustomOptions = function(value) -- 1538
	if value == nil then -- 1539
		return "" -- 1540
	end -- 1539
	local options = tostring(value) -- 1541
	options = options:match("^%s*(.-)%s*$") or "" -- 1542
	return options -- 1543
end -- 1538
local validateCustomOptions -- 1545
validateCustomOptions = function(value) -- 1545
	local options = normalizeCustomOptions(value) -- 1546
	if options == "" then -- 1547
		return true -- 1547
	end -- 1547
	if not options:match("^%s*{") then -- 1548
		return false -- 1548
	end -- 1548
	local decoded = json.decode(options) -- 1549
	return type(decoded) == "table" -- 1550
end -- 1545
HttpServer:post("/llm/list", function() -- 1552
	ensureLLMConfigTable() -- 1553
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling\n		from LLMConfig\n		order by id asc") -- 1554
	local items -- 1558
	if rows and #rows > 0 then -- 1558
		local _accum_0 = { } -- 1559
		local _len_0 = 1 -- 1559
		for _index_0 = 1, #rows do -- 1559
			local _des_0 = rows[_index_0] -- 1559
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10], _des_0[11] -- 1559
			_accum_0[_len_0] = { -- 1560
				id = id, -- 1560
				name = name, -- 1560
				url = url, -- 1560
				model = model, -- 1560
				key = key, -- 1560
				contextWindow = normalizeContextWindow(contextWindow), -- 1560
				temperature = normalizeTemperature(temperature), -- 1560
				maxTokens = normalizeMaxTokens(maxTokens), -- 1560
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1560
				customOptions = normalizeCustomOptions(customOptions), -- 1560
				supportsFunctionCalling = supportsFunctionCalling ~= 0 -- 1560
			} -- 1560
			_len_0 = _len_0 + 1 -- 1560
		end -- 1559
		items = _accum_0 -- 1558
	end -- 1558
	return { -- 1561
		success = true, -- 1561
		items = items -- 1561
	} -- 1561
end) -- 1552
HttpServer:post("/llm/create", function(req) -- 1563
	ensureLLMConfigTable() -- 1564
	do -- 1565
		local _type_0 = type(req) -- 1565
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1565
		if _tab_0 then -- 1565
			local body = req.body -- 1565
			if body ~= nil then -- 1565
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1566
				local now = os.time() -- 1567
				if name == nil or url == nil or model == nil or key == nil then -- 1568
					return invalidArguments -- 1569
				end -- 1568
				contextWindow = normalizeContextWindow(contextWindow) -- 1570
				temperature = normalizeTemperature(temperature) -- 1571
				maxTokens = normalizeMaxTokens(maxTokens) -- 1572
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1573
				customOptions = normalizeCustomOptions(customOptions) -- 1574
				if not validateCustomOptions(customOptions) then -- 1575
					return { -- 1575
						success = false, -- 1575
						message = "customOptions must be a JSON object" -- 1575
					} -- 1575
				end -- 1575
				if supportsFunctionCalling == false then -- 1576
					supportsFunctionCalling = 0 -- 1576
				else -- 1576
					supportsFunctionCalling = 1 -- 1576
				end -- 1576
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1583
					tostring(name), -- 1583
					tostring(url), -- 1584
					tostring(model), -- 1585
					tostring(key), -- 1586
					contextWindow, -- 1587
					temperature, -- 1588
					maxTokens, -- 1589
					reasoningEffort, -- 1590
					customOptions, -- 1591
					supportsFunctionCalling, -- 1592
					1, -- 1593
					now, -- 1594
					now -- 1595
				}) -- 1577
				return { -- 1597
					success = affected >= 0 -- 1597
				} -- 1597
			end -- 1565
		end -- 1565
	end -- 1565
	return invalidArguments -- 1563
end) -- 1563
HttpServer:post("/llm/update", function(req) -- 1599
	ensureLLMConfigTable() -- 1600
	do -- 1601
		local _type_0 = type(req) -- 1601
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1601
		if _tab_0 then -- 1601
			local body = req.body -- 1601
			if body ~= nil then -- 1601
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions, body.supportsFunctionCalling -- 1602
				local now = os.time() -- 1603
				id = tonumber(id) -- 1604
				if id == nil then -- 1605
					return invalidArguments -- 1605
				end -- 1605
				contextWindow = normalizeContextWindow(contextWindow) -- 1606
				temperature = normalizeTemperature(temperature) -- 1607
				maxTokens = normalizeMaxTokens(maxTokens) -- 1608
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1609
				customOptions = normalizeCustomOptions(customOptions) -- 1610
				if not validateCustomOptions(customOptions) then -- 1611
					return { -- 1611
						success = false, -- 1611
						message = "customOptions must be a JSON object" -- 1611
					} -- 1611
				end -- 1611
				if supportsFunctionCalling == false then -- 1612
					supportsFunctionCalling = 0 -- 1612
				else -- 1612
					supportsFunctionCalling = 1 -- 1612
				end -- 1612
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, supports_function_calling = ?, updated_at = ?\n			where id = ?", { -- 1617
					tostring(name), -- 1617
					tostring(url), -- 1618
					tostring(model), -- 1619
					tostring(key), -- 1620
					contextWindow, -- 1621
					temperature, -- 1622
					maxTokens, -- 1623
					reasoningEffort, -- 1624
					customOptions, -- 1625
					supportsFunctionCalling, -- 1626
					now, -- 1627
					id -- 1628
				}) -- 1613
				return { -- 1630
					success = affected >= 0 -- 1630
				} -- 1630
			end -- 1601
		end -- 1601
	end -- 1601
	return invalidArguments -- 1599
end) -- 1599
HttpServer:post("/llm/delete", function(req) -- 1632
	ensureLLMConfigTable() -- 1633
	do -- 1634
		local _type_0 = type(req) -- 1634
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1634
		if _tab_0 then -- 1634
			local id -- 1634
			do -- 1634
				local _obj_0 = req.body -- 1634
				local _type_1 = type(_obj_0) -- 1634
				if "table" == _type_1 or "userdata" == _type_1 then -- 1634
					id = _obj_0.id -- 1634
				end -- 1634
			end -- 1634
			if id ~= nil then -- 1634
				id = tonumber(id) -- 1635
				if id == nil then -- 1636
					return invalidArguments -- 1636
				end -- 1636
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1637
					id -- 1637
				}) -- 1637
				return { -- 1638
					success = affected >= 0 -- 1638
				} -- 1638
			end -- 1634
		end -- 1634
	end -- 1634
	return invalidArguments -- 1632
end) -- 1632
HttpServer:post("/local-agent/list", function() -- 1640
	return { -- 1641
		success = true, -- 1641
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1641
		items = AgentLocalAgent.listConfigs() -- 1641
	} -- 1641
end) -- 1640
HttpServer:post("/local-agent/save", function(req) -- 1643
	do -- 1644
		local _type_0 = type(req) -- 1644
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1644
		if _tab_0 then -- 1644
			local body = req.body -- 1644
			if body ~= nil then -- 1644
				return AgentLocalAgent.saveConfig(body) -- 1645
			end -- 1644
		end -- 1644
	end -- 1644
	return invalidArguments -- 1643
end) -- 1643
HttpServer:post("/local-agent/delete", function(req) -- 1647
	do -- 1648
		local _type_0 = type(req) -- 1648
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1648
		if _tab_0 then -- 1648
			local id -- 1648
			do -- 1648
				local _obj_0 = req.body -- 1648
				local _type_1 = type(_obj_0) -- 1648
				if "table" == _type_1 or "userdata" == _type_1 then -- 1648
					id = _obj_0.id -- 1648
				end -- 1648
			end -- 1648
			if id ~= nil then -- 1648
				return AgentLocalAgent.deleteConfig(id) -- 1649
			end -- 1648
		end -- 1648
	end -- 1648
	return invalidArguments -- 1647
end) -- 1647
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1651
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
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1653
			end -- 1652
		end -- 1652
	end -- 1652
	return invalidArguments -- 1651
end) -- 1651
HttpServer:post("/stat", function(req) -- 1655
	do -- 1656
		local _type_0 = type(req) -- 1656
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1656
		if _tab_0 then -- 1656
			local path -- 1656
			do -- 1656
				local _obj_0 = req.body -- 1656
				local _type_1 = type(_obj_0) -- 1656
				if "table" == _type_1 or "userdata" == _type_1 then -- 1656
					path = _obj_0.path -- 1656
				end -- 1656
			end -- 1656
			if path ~= nil then -- 1656
				if not Content:exist(path) then -- 1657
					return { -- 1658
						success = false, -- 1658
						message = "target not existed" -- 1658
					} -- 1658
				end -- 1657
				if Content:isdir(path) then -- 1659
					return { -- 1660
						success = false, -- 1660
						message = "failed to stat a directory" -- 1660
					} -- 1660
				end -- 1659
				local size, isBinary = Content:getAttr(path) -- 1661
				if size then -- 1661
					return { -- 1662
						success = true, -- 1662
						size = size, -- 1662
						isBinary = isBinary -- 1662
					} -- 1662
				end -- 1661
			end -- 1656
		end -- 1656
	end -- 1656
	return { -- 1655
		success = false, -- 1655
		message = "failed to stat" -- 1655
	} -- 1655
end) -- 1655
HttpServer:post("/new", function(req) -- 1664
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
			local content -- 1665
			do -- 1665
				local _obj_0 = req.body -- 1665
				local _type_1 = type(_obj_0) -- 1665
				if "table" == _type_1 or "userdata" == _type_1 then -- 1665
					content = _obj_0.content -- 1665
				end -- 1665
			end -- 1665
			local folder -- 1665
			do -- 1665
				local _obj_0 = req.body -- 1665
				local _type_1 = type(_obj_0) -- 1665
				if "table" == _type_1 or "userdata" == _type_1 then -- 1665
					folder = _obj_0.folder -- 1665
				end -- 1665
			end -- 1665
			if path ~= nil and content ~= nil and folder ~= nil then -- 1665
				if Content:exist(path) then -- 1666
					return { -- 1667
						success = false, -- 1667
						message = "TargetExisted" -- 1667
					} -- 1667
				end -- 1666
				local parent = Path:getPath(path) -- 1668
				local files = Content:getFiles(parent) -- 1669
				if folder then -- 1670
					local name = Path:getFilename(path):lower() -- 1671
					for _index_0 = 1, #files do -- 1672
						local file = files[_index_0] -- 1672
						if name == Path:getFilename(file):lower() then -- 1673
							return { -- 1674
								success = false, -- 1674
								message = "TargetExisted" -- 1674
							} -- 1674
						end -- 1673
					end -- 1672
					if Content:mkdir(path) then -- 1675
						return { -- 1676
							success = true -- 1676
						} -- 1676
					end -- 1675
				else -- 1678
					local name = Path:getName(path):lower() -- 1678
					for _index_0 = 1, #files do -- 1679
						local file = files[_index_0] -- 1679
						if name == Path:getName(file):lower() then -- 1680
							local ext = Path:getExt(file) -- 1681
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1682
								goto _continue_0 -- 1683
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1684
								goto _continue_0 -- 1685
							end -- 1682
							return { -- 1686
								success = false, -- 1686
								message = "SourceExisted" -- 1686
							} -- 1686
						end -- 1680
						::_continue_0:: -- 1680
					end -- 1679
					if Content:save(path, content) then -- 1687
						return { -- 1688
							success = true -- 1688
						} -- 1688
					end -- 1687
				end -- 1670
			end -- 1665
		end -- 1665
	end -- 1665
	return { -- 1664
		success = false, -- 1664
		message = "Failed" -- 1664
	} -- 1664
end) -- 1664
local deleteAsset -- 1690
deleteAsset = function(path) -- 1690
	if not Content:exist(path) then -- 1691
		return false -- 1691
	end -- 1691
	local projectRoot -- 1692
	if Content:isdir(path) and isProjectRootDir(path) then -- 1692
		projectRoot = path -- 1692
	else -- 1692
		projectRoot = nil -- 1692
	end -- 1692
	local parent = Path:getPath(path) -- 1693
	local files = Content:getFiles(parent) -- 1694
	local name = Path:getName(path):lower() -- 1695
	local ext = Path:getExt(path) -- 1696
	for _index_0 = 1, #files do -- 1697
		local file = files[_index_0] -- 1697
		if name == Path:getName(file):lower() then -- 1698
			local _exp_0 = Path:getExt(file) -- 1699
			if "tl" == _exp_0 then -- 1699
				if ("vs" == ext) then -- 1699
					Content:remove(Path(parent, file)) -- 1700
				end -- 1699
			elseif "lua" == _exp_0 then -- 1701
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1701
					Content:remove(Path(parent, file)) -- 1702
				end -- 1701
			end -- 1699
		end -- 1698
	end -- 1697
	if Content:remove(path) then -- 1703
		if projectRoot then -- 1704
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1705
		end -- 1704
		return true -- 1706
	end -- 1703
	return false -- 1707
end -- 1690
local moveAsset -- 1709
moveAsset = function(old, new) -- 1709
	if not (Content:exist(old) and not Content:exist(new)) then -- 1710
		return false -- 1710
	end -- 1710
	local renamedDir = Content:isdir(old) -- 1711
	local parent = Path:getPath(new) -- 1712
	local files = Content:getFiles(parent) -- 1713
	if renamedDir then -- 1714
		local name = Path:getFilename(new):lower() -- 1715
		for _index_0 = 1, #files do -- 1716
			local file = files[_index_0] -- 1716
			if name == Path:getFilename(file):lower() then -- 1717
				return false -- 1718
			end -- 1717
		end -- 1716
	else -- 1720
		local name = Path:getName(new):lower() -- 1720
		local ext = Path:getExt(new) -- 1721
		for _index_0 = 1, #files do -- 1722
			local file = files[_index_0] -- 1722
			if name == Path:getName(file):lower() then -- 1723
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1724
					goto _continue_0 -- 1725
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1726
					goto _continue_0 -- 1727
				end -- 1724
				return false -- 1728
			end -- 1723
			::_continue_0:: -- 1723
		end -- 1722
	end -- 1714
	if not Content:move(old, new) then -- 1729
		return false -- 1729
	end -- 1729
	if renamedDir then -- 1730
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1731
	end -- 1730
	local newParent = Path:getPath(new) -- 1732
	parent = Path:getPath(old) -- 1733
	files = Content:getFiles(parent) -- 1734
	local newName = Path:getName(new) -- 1735
	local oldName = Path:getName(old) -- 1736
	local name = oldName:lower() -- 1737
	local ext = Path:getExt(old) -- 1738
	for _index_0 = 1, #files do -- 1739
		local file = files[_index_0] -- 1739
		if name == Path:getName(file):lower() then -- 1740
			local _exp_0 = Path:getExt(file) -- 1741
			if "tl" == _exp_0 then -- 1741
				if ("vs" == ext) then -- 1741
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1742
				end -- 1741
			elseif "lua" == _exp_0 then -- 1743
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1743
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1744
				end -- 1743
			end -- 1741
		end -- 1740
	end -- 1739
	return true -- 1745
end -- 1709
HttpServer:post("/delete", function(req) -- 1747
	do -- 1748
		local _type_0 = type(req) -- 1748
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1748
		if _tab_0 then -- 1748
			local path -- 1748
			do -- 1748
				local _obj_0 = req.body -- 1748
				local _type_1 = type(_obj_0) -- 1748
				if "table" == _type_1 or "userdata" == _type_1 then -- 1748
					path = _obj_0.path -- 1748
				end -- 1748
			end -- 1748
			if path ~= nil then -- 1748
				if deleteAsset(path) then -- 1749
					return { -- 1749
						success = true -- 1749
					} -- 1749
				end -- 1749
			end -- 1748
		end -- 1748
	end -- 1748
	return { -- 1747
		success = false -- 1747
	} -- 1747
end) -- 1747
HttpServer:post("/rename", function(req) -- 1751
	do -- 1752
		local _type_0 = type(req) -- 1752
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1752
		if _tab_0 then -- 1752
			local old -- 1752
			do -- 1752
				local _obj_0 = req.body -- 1752
				local _type_1 = type(_obj_0) -- 1752
				if "table" == _type_1 or "userdata" == _type_1 then -- 1752
					old = _obj_0.old -- 1752
				end -- 1752
			end -- 1752
			local new -- 1752
			do -- 1752
				local _obj_0 = req.body -- 1752
				local _type_1 = type(_obj_0) -- 1752
				if "table" == _type_1 or "userdata" == _type_1 then -- 1752
					new = _obj_0.new -- 1752
				end -- 1752
			end -- 1752
			if old ~= nil and new ~= nil then -- 1752
				if moveAsset(old, new) then -- 1753
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
local normalizeAssetPaths -- 1755
normalizeAssetPaths = function(paths) -- 1755
	if not (type(paths) == "table") then -- 1756
		return nil -- 1756
	end -- 1756
	local unique = { } -- 1757
	local candidates = { } -- 1758
	for _index_0 = 1, #paths do -- 1759
		local path = paths[_index_0] -- 1759
		if not (type(path) == "string") then -- 1760
			return nil -- 1760
		end -- 1760
		local relative = relativeToRoot(path, Content.writablePath) -- 1761
		if relative == nil or relative == "" or not Content:exist(path) then -- 1762
			return nil -- 1762
		end -- 1762
		if not unique[path] then -- 1763
			unique[path] = true -- 1764
			candidates[#candidates + 1] = path -- 1765
		end -- 1763
	end -- 1759
	table.sort(candidates, function(a, b) -- 1766
		return #a < #b -- 1766
	end) -- 1766
	local result = { } -- 1767
	for _index_0 = 1, #candidates do -- 1768
		local path = candidates[_index_0] -- 1768
		local contained = false -- 1769
		for _index_1 = 1, #result do -- 1770
			local parent = result[_index_1] -- 1770
			if relativeToRoot(path, parent) ~= nil then -- 1771
				contained = true -- 1772
				break -- 1773
			end -- 1771
		end -- 1770
		if not contained then -- 1774
			result[#result + 1] = path -- 1774
		end -- 1774
	end -- 1768
	return result -- 1775
end -- 1755
HttpServer:postSchedule("/assets/batch", function(req) -- 1777
	do -- 1778
		local _type_0 = type(req) -- 1778
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1778
		if _tab_0 then -- 1778
			local operation -- 1778
			do -- 1778
				local _obj_0 = req.body -- 1778
				local _type_1 = type(_obj_0) -- 1778
				if "table" == _type_1 or "userdata" == _type_1 then -- 1778
					operation = _obj_0.operation -- 1778
				end -- 1778
			end -- 1778
			local sources -- 1778
			do -- 1778
				local _obj_0 = req.body -- 1778
				local _type_1 = type(_obj_0) -- 1778
				if "table" == _type_1 or "userdata" == _type_1 then -- 1778
					sources = _obj_0.sources -- 1778
				end -- 1778
			end -- 1778
			if operation ~= nil and sources ~= nil then -- 1778
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1779
					return { -- 1779
						success = false, -- 1779
						message = "invalid operation" -- 1779
					} -- 1779
				end -- 1779
				sources = normalizeAssetPaths(sources) -- 1780
				if not (sources and #sources > 0) then -- 1781
					return { -- 1781
						success = false, -- 1781
						message = "invalid sources" -- 1781
					} -- 1781
				end -- 1781
				local target = req.body.target -- 1782
				local destinations = { } -- 1783
				if operation ~= "delete" then -- 1784
					if not (type(target) == "string") then -- 1785
						return { -- 1785
							success = false, -- 1785
							message = "invalid target" -- 1785
						} -- 1785
					end -- 1785
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1786
					if targetRelative == nil then -- 1787
						return { -- 1787
							success = false, -- 1787
							message = "invalid target" -- 1787
						} -- 1787
					end -- 1787
					if not (Content:exist(target) and Content:isdir(target)) then -- 1788
						return { -- 1788
							success = false, -- 1788
							message = "invalid target" -- 1788
						} -- 1788
					end -- 1788
					for _index_0 = 1, #sources do -- 1789
						local source = sources[_index_0] -- 1789
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1790
							return { -- 1791
								success = false, -- 1791
								message = "target inside source" -- 1791
							} -- 1791
						end -- 1790
						local destination = Path(target, Path:getFilename(source)) -- 1792
						if Content:exist(destination) then -- 1793
							return { -- 1793
								success = false, -- 1793
								message = "target existed" -- 1793
							} -- 1793
						end -- 1793
						if destinations[destination] then -- 1794
							return { -- 1794
								success = false, -- 1794
								message = "duplicate target" -- 1794
							} -- 1794
						end -- 1794
						destinations[destination] = true -- 1795
					end -- 1789
				end -- 1784
				local changes = { } -- 1796
				local affectedSet = { } -- 1797
				local affectedDirectories = { } -- 1798
				local addAffected -- 1799
				addAffected = function(dir) -- 1799
					if affectedSet[dir] then -- 1800
						return -- 1800
					end -- 1800
					affectedSet[dir] = true -- 1801
					affectedDirectories[#affectedDirectories + 1] = dir -- 1802
				end -- 1799
				if operation ~= "delete" then -- 1803
					addAffected(target) -- 1803
				end -- 1803
				for _index_0 = 1, #sources do -- 1804
					local source = sources[_index_0] -- 1804
					addAffected(Path:getPath(source)) -- 1805
					if operation == "delete" then -- 1806
						if not deleteAsset(source) then -- 1807
							return { -- 1807
								success = false, -- 1807
								message = "delete failed", -- 1807
								changes = changes, -- 1807
								affectedDirectories = affectedDirectories -- 1807
							} -- 1807
						end -- 1807
						changes[#changes + 1] = { -- 1808
							old = source -- 1808
						} -- 1808
					else -- 1810
						local destination = Path(target, Path:getFilename(source)) -- 1810
						local ok -- 1811
						if operation == "copy" then -- 1811
							ok = Content:copyAsync(source, destination) -- 1812
						else -- 1814
							ok = moveAsset(source, destination) -- 1814
						end -- 1811
						if not ok then -- 1815
							return { -- 1815
								success = false, -- 1815
								message = operation .. " failed", -- 1815
								changes = changes, -- 1815
								affectedDirectories = affectedDirectories -- 1815
							} -- 1815
						end -- 1815
						changes[#changes + 1] = { -- 1816
							old = source, -- 1816
							new = destination -- 1816
						} -- 1816
					end -- 1806
				end -- 1804
				return { -- 1817
					success = true, -- 1817
					changes = changes, -- 1817
					affectedDirectories = affectedDirectories -- 1817
				} -- 1817
			end -- 1778
		end -- 1778
	end -- 1778
	return { -- 1777
		success = false, -- 1777
		message = "invalid request" -- 1777
	} -- 1777
end) -- 1777
local withProjectSearchPaths -- 1819
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1819
	local fallbackPaths = { } -- 1820
	local addFallback -- 1821
	addFallback = function(dir) -- 1821
		if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1821
			fallbackPaths[#fallbackPaths + 1] = dir -- 1821
		end -- 1821
	end -- 1821
	if projectRoot and projectRoot ~= "" then -- 1822
		addFallback(Path(projectRoot, "Script")) -- 1823
		addFallback(projectRoot) -- 1824
	end -- 1822
	if projFile then -- 1825
		local projDir = getProjectDirFromFile(projFile) -- 1826
		if projDir then -- 1826
			addFallback(Path(projDir, "Script")) -- 1827
			addFallback(projDir) -- 1828
		else -- 1830
			addFallback(Path:getPath(projFile)) -- 1830
		end -- 1826
	end -- 1825
	if not (#fallbackPaths > 0) then -- 1831
		return fn() -- 1831
	end -- 1831
	local searchPaths = Content.searchPaths -- 1832
	for _index_0 = 1, #fallbackPaths do -- 1833
		local dir = fallbackPaths[_index_0] -- 1833
		Content:addSearchPath(dir) -- 1833
	end -- 1833
	local _ <close> = setmetatable({ }, { -- 1834
		__close = function() -- 1834
			Content.searchPaths = searchPaths -- 1834
		end -- 1834
	}) -- 1834
	return fn() -- 1835
end -- 1819
HttpServer:post("/exist", function(req) -- 1836
	do -- 1837
		local _type_0 = type(req) -- 1837
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1837
		if _tab_0 then -- 1837
			local file -- 1837
			do -- 1837
				local _obj_0 = req.body -- 1837
				local _type_1 = type(_obj_0) -- 1837
				if "table" == _type_1 or "userdata" == _type_1 then -- 1837
					file = _obj_0.file -- 1837
				end -- 1837
			end -- 1837
			if file ~= nil then -- 1837
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1838
					return { -- 1839
						success = Content:exist(file) -- 1839
					} -- 1839
				end) -- 1838
			end -- 1837
		end -- 1837
	end -- 1837
	return { -- 1836
		success = false -- 1836
	} -- 1836
end) -- 1836
HttpServer:postSchedule("/read", function(req) -- 1840
	do -- 1841
		local _type_0 = type(req) -- 1841
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1841
		if _tab_0 then -- 1841
			local path -- 1841
			do -- 1841
				local _obj_0 = req.body -- 1841
				local _type_1 = type(_obj_0) -- 1841
				if "table" == _type_1 or "userdata" == _type_1 then -- 1841
					path = _obj_0.path -- 1841
				end -- 1841
			end -- 1841
			if path ~= nil then -- 1841
				local readFile -- 1842
				readFile = function() -- 1842
					if Content:exist(path) and not Content:isdir(path) then -- 1843
						local content = Content:loadAsync(path) -- 1844
						if content then -- 1844
							return { -- 1845
								content = content, -- 1845
								success = true, -- 1845
								fullPath = Content:getFullPath(path) -- 1845
							} -- 1845
						end -- 1844
					end -- 1843
					return nil -- 1842
				end -- 1842
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1846
				if result then -- 1846
					return result -- 1846
				end -- 1846
			end -- 1841
		end -- 1841
	end -- 1841
	return { -- 1840
		success = false -- 1840
	} -- 1840
end) -- 1840
local agentDocLanguage -- 1848
agentDocLanguage = function(language) -- 1848
	if language == "zh-Hans" then -- 1849
		return "zh" -- 1849
	else -- 1849
		return "en" -- 1849
	end -- 1849
end -- 1848
HttpServer:postSchedule("/doc/search", function(req) -- 1851
	local body = req.body or { } -- 1852
	local language = body.docLanguage -- 1853
	if not (("en" == language or "zh-Hans" == language)) then -- 1854
		return { -- 1854
			success = false, -- 1854
			message = "unsupported doc language" -- 1854
		} -- 1854
	end -- 1854
	local docType = body.docType -- 1855
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1856
		return { -- 1856
			success = false, -- 1856
			message = "unsupported doc type" -- 1856
		} -- 1856
	end -- 1856
	local codeLanguage = body.programmingLanguage -- 1857
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1858
		return { -- 1858
			success = false, -- 1858
			message = "unsupported programming language" -- 1858
		} -- 1858
	end -- 1858
	if not body.pattern then -- 1859
		return { -- 1859
			success = false, -- 1859
			message = "missing pattern" -- 1859
		} -- 1859
	end -- 1859
	local result = nil -- 1860
	AgentTools.searchDoraDocHttp({ -- 1862
		pattern = body.pattern, -- 1862
		docLanguage = agentDocLanguage(language), -- 1863
		docType = docType, -- 1864
		programmingLanguage = codeLanguage, -- 1865
		limit = body.limit, -- 1866
		useRegex = body.useRegex, -- 1867
		caseSensitive = body.caseSensitive, -- 1868
		includeContent = body.includeContent, -- 1869
		contentWindow = body.contentWindow -- 1870
	}, function(res) -- 1871
		result = res -- 1872
	end) -- 1861
	wait(function() -- 1873
		return result ~= nil -- 1873
	end) -- 1873
	if result and result.success then -- 1874
		result.docLanguage = language -- 1875
	end -- 1874
	if result then -- 1876
		return result -- 1877
	else -- 1879
		return { -- 1879
			success = false, -- 1879
			message = "doc search failed" -- 1879
		} -- 1879
	end -- 1876
	return { -- 1851
		success = false, -- 1851
		message = "invalid call" -- 1851
	} -- 1851
end) -- 1851
HttpServer:postSchedule("/doc/read", function(req) -- 1881
	local body = req.body or { } -- 1882
	local language = body.docLanguage -- 1883
	if not (("en" == language or "zh-Hans" == language)) then -- 1884
		return { -- 1884
			success = false, -- 1884
			message = "unsupported doc language" -- 1884
		} -- 1884
	end -- 1884
	if not body.file then -- 1885
		return { -- 1885
			success = false, -- 1885
			message = "missing file" -- 1885
		} -- 1885
	end -- 1885
	local result = AgentTools.readDoraDoc({ -- 1887
		docLanguage = agentDocLanguage(language), -- 1887
		file = body.file, -- 1888
		startLine = body.startLine, -- 1889
		endLine = body.endLine -- 1890
	}) -- 1886
	if result and result.success then -- 1891
		result.docLanguage = language -- 1892
	end -- 1891
	return result -- 1893
end) -- 1881
HttpServer:get("/read-sync", function(req) -- 1895
	do -- 1896
		local _type_0 = type(req) -- 1896
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1896
		if _tab_0 then -- 1896
			local params = req.params -- 1896
			if params ~= nil then -- 1896
				local path = params.path -- 1897
				local exts -- 1898
				if params.exts then -- 1898
					local _accum_0 = { } -- 1899
					local _len_0 = 1 -- 1899
					for ext in params.exts:gmatch("[^|]*") do -- 1899
						_accum_0[_len_0] = ext -- 1899
						_len_0 = _len_0 + 1 -- 1899
					end -- 1899
					exts = _accum_0 -- 1899
				else -- 1900
					exts = { -- 1900
						"" -- 1900
					} -- 1900
				end -- 1898
				local readFileAt -- 1901
				readFileAt = function(targetPath) -- 1901
					if Content:exist(targetPath) then -- 1902
						local content = Content:load(targetPath) -- 1903
						if content then -- 1903
							return { -- 1904
								content = content, -- 1904
								success = true, -- 1904
								fullPath = Content:getFullPath(targetPath) -- 1904
							} -- 1904
						end -- 1903
					end -- 1902
					return nil -- 1901
				end -- 1901
				local readFile -- 1905
				readFile = function(fallbackPaths) -- 1905
					for _index_0 = 1, #exts do -- 1906
						local ext = exts[_index_0] -- 1906
						local targetPath = path .. ext -- 1907
						if not Content:isAbsolutePath(targetPath) then -- 1908
							for _index_1 = 1, #fallbackPaths do -- 1909
								local fallback = fallbackPaths[_index_1] -- 1909
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1910
								if fallbackResult then -- 1910
									return fallbackResult -- 1911
								end -- 1910
							end -- 1909
						end -- 1908
						local fileResult = readFileAt(targetPath) -- 1912
						if fileResult then -- 1912
							return fileResult -- 1913
						end -- 1912
					end -- 1906
					return nil -- 1905
				end -- 1905
				local fallbackPaths = { } -- 1914
				local fallbackCandidates = { } -- 1915
				do -- 1916
					local projectRoot = req.params.projectRoot -- 1916
					if projectRoot then -- 1916
						if projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1917
							fallbackCandidates[#fallbackCandidates + 1] = Path(projectRoot, "Script") -- 1918
							fallbackCandidates[#fallbackCandidates + 1] = projectRoot -- 1919
						end -- 1917
					end -- 1916
				end -- 1916
				do -- 1920
					local projFile = req.params.projFile -- 1920
					if projFile then -- 1920
						local projDir = getProjectDirFromFile(projFile) -- 1921
						if projDir then -- 1921
							fallbackCandidates[#fallbackCandidates + 1] = Path(projDir, "Script") -- 1922
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1923
						else -- 1925
							projDir = Path:getPath(projFile) -- 1925
							fallbackCandidates[#fallbackCandidates + 1] = projDir -- 1926
						end -- 1921
					end -- 1920
				end -- 1920
				for _index_0 = 1, #fallbackCandidates do -- 1927
					local dir = fallbackCandidates[_index_0] -- 1927
					if dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir) then -- 1928
						local exists = false -- 1929
						for _index_1 = 1, #fallbackPaths do -- 1930
							local fallback = fallbackPaths[_index_1] -- 1930
							if fallback == dir then -- 1931
								exists = true -- 1932
								break -- 1933
							end -- 1931
						end -- 1930
						if not exists then -- 1934
							fallbackPaths[#fallbackPaths + 1] = dir -- 1934
						end -- 1934
					end -- 1928
				end -- 1927
				local readResult = readFile(fallbackPaths) -- 1935
				if readResult then -- 1935
					return readResult -- 1936
				end -- 1935
			end -- 1896
		end -- 1896
	end -- 1896
	return { -- 1895
		success = false -- 1895
	} -- 1895
end) -- 1895
local addGeneratedSourceHeader -- 1938
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 1938
	if preserveTIC80 == nil then -- 1938
		preserveTIC80 = false -- 1938
	end -- 1938
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 1939
	if preserveTIC80 then -- 1940
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 1941
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 1942
		end -- 1941
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 1943
	end -- 1940
	return tostring(header) .. "\n" .. tostring(codes) -- 1944
end -- 1938
local compileFileAsync -- 1946
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 1946
	if projectRoot == nil then -- 1946
		projectRoot = nil -- 1946
	end -- 1946
	local file = inputFile -- 1947
	local searchPath -- 1948
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 1948
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or relativeToRoot(inputFile, projectRoot) or inputFile -- 1949
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 1953
	elseif not Content:isAbsolutePath(inputFile) then -- 1954
		searchPath = "" -- 1955
	else -- 1956
		local dir = getProjectDirFromFile(inputFile) -- 1956
		if dir then -- 1956
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1957
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 1961
		else -- 1963
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 1963
			searchPath = "" -- 1966
		end -- 1956
	end -- 1948
	local outputFile = Path:replaceExt(inputFile, "lua") -- 1967
	local yueext = yue.options.extension -- 1968
	local resultCodes = nil -- 1969
	local resultError = nil -- 1970
	do -- 1971
		local _exp_0 = Path:getExt(inputFile) -- 1971
		if yueext == _exp_0 then -- 1971
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1972
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1973
				if not codes then -- 1974
					resultError = err -- 1975
					return -- 1976
				end -- 1974
				local extraGlobal -- 1977
				if isTIC80 then -- 1977
					extraGlobal = tic80APIs -- 1977
				else -- 1977
					extraGlobal = nil -- 1977
				end -- 1977
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1978
				if not success then -- 1979
					resultError = message -- 1980
					return -- 1981
				end -- 1979
				if codes == "" then -- 1982
					resultCodes = "" -- 1983
					return nil -- 1984
				end -- 1982
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 1985
				return resultCodes -- 1986
			end, function(success) -- 1973
				if not success then -- 1987
					Content:remove(outputFile) -- 1988
					if resultCodes == nil then -- 1989
						resultCodes = false -- 1990
					end -- 1989
				end -- 1987
			end) -- 1973
		elseif "tl" == _exp_0 then -- 1991
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1992
			if isTIC80 then -- 1993
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1994
			end -- 1993
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1995
			if codes then -- 1995
				if isTIC80 then -- 1996
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1997
				end -- 1996
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 1998
				Content:saveAsync(outputFile, resultCodes) -- 1999
			else -- 2001
				Content:remove(outputFile) -- 2001
				resultCodes = false -- 2002
				resultError = err -- 2003
			end -- 1995
		elseif "xml" == _exp_0 then -- 2004
			local codes, err = xml.tolua(sourceCodes) -- 2005
			if codes then -- 2005
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2006
				Content:saveAsync(outputFile, resultCodes) -- 2007
			else -- 2009
				Content:remove(outputFile) -- 2009
				resultCodes = false -- 2010
				resultError = err -- 2011
			end -- 2005
		end -- 1971
	end -- 1971
	wait(function() -- 2012
		return resultCodes ~= nil -- 2012
	end) -- 2012
	if resultCodes then -- 2013
		return resultCodes -- 2014
	else -- 2016
		return nil, resultError -- 2016
	end -- 2013
	return nil -- 1946
end -- 1946
HttpServer:postSchedule("/write", function(req) -- 2018
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2019
	local buildSucceeded = false -- 2020
	local _ <close> = setmetatable({ }, { -- 2021
		__close = function() -- 2021
			return finishUpdate(buildSucceeded) -- 2021
		end -- 2021
	}) -- 2021
	do -- 2022
		local _type_0 = type(req) -- 2022
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2022
		if _tab_0 then -- 2022
			local path -- 2022
			do -- 2022
				local _obj_0 = req.body -- 2022
				local _type_1 = type(_obj_0) -- 2022
				if "table" == _type_1 or "userdata" == _type_1 then -- 2022
					path = _obj_0.path -- 2022
				end -- 2022
			end -- 2022
			local content -- 2022
			do -- 2022
				local _obj_0 = req.body -- 2022
				local _type_1 = type(_obj_0) -- 2022
				if "table" == _type_1 or "userdata" == _type_1 then -- 2022
					content = _obj_0.content -- 2022
				end -- 2022
			end -- 2022
			if path ~= nil and content ~= nil then -- 2022
				if Content:saveAsync(path, content) then -- 2023
					do -- 2024
						local _exp_0 = Path:getExt(path) -- 2024
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2024
							if '' == Path:getExt(Path:getName(path)) then -- 2025
								local resultCodes = compileFileAsync(path, content) -- 2026
								buildSucceeded = resultCodes ~= nil -- 2027
								return { -- 2028
									success = true, -- 2028
									resultCodes = resultCodes -- 2028
								} -- 2028
							end -- 2025
						end -- 2024
					end -- 2024
					buildSucceeded = true -- 2029
					return { -- 2030
						success = true -- 2030
					} -- 2030
				end -- 2023
			end -- 2022
		end -- 2022
	end -- 2022
	return { -- 2018
		success = false -- 2018
	} -- 2018
end) -- 2018
local getWaProjectDirFromFile = nil -- 2032
HttpServer:postSchedule("/build", function(req) -- 2034
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2035
	local buildSucceeded = false -- 2036
	local _ <close> = setmetatable({ }, { -- 2037
		__close = function() -- 2037
			return finishUpdate(buildSucceeded) -- 2037
		end -- 2037
	}) -- 2037
	do -- 2038
		local _type_0 = type(req) -- 2038
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2038
		if _tab_0 then -- 2038
			local path -- 2038
			do -- 2038
				local _obj_0 = req.body -- 2038
				local _type_1 = type(_obj_0) -- 2038
				if "table" == _type_1 or "userdata" == _type_1 then -- 2038
					path = _obj_0.path -- 2038
				end -- 2038
			end -- 2038
			if path ~= nil then -- 2038
				local projectRoot = req.body.projectRoot -- 2039
				if Content:isdir(path) then -- 2040
					local projDir = getWaProjectDirFromFile(path) -- 2041
					if projDir then -- 2041
						local message = Wasm:buildWaAsync(projDir) -- 2042
						if message == "" then -- 2043
							return { -- 2044
								success = true -- 2044
							} -- 2044
						else -- 2046
							return { -- 2046
								success = false, -- 2046
								message = message -- 2046
							} -- 2046
						end -- 2043
					end -- 2041
				end -- 2040
				local _exp_0 = Path:getExt(path) -- 2047
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2048
					if '' == Path:getExt(Path:getName(path)) then -- 2049
						local content = Content:loadAsync(path) -- 2050
						if content then -- 2050
							local resultCodes = compileFileAsync(path, content, projectRoot) -- 2051
							if resultCodes then -- 2051
								buildSucceeded = true -- 2052
								return { -- 2053
									success = true, -- 2053
									resultCodes = resultCodes -- 2053
								} -- 2053
							end -- 2051
						end -- 2050
					end -- 2049
				elseif "wa" == _exp_0 then -- 2054
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
					else -- 2062
						return { -- 2062
							success = false, -- 2062
							message = 'Wa file needs a project' -- 2062
						} -- 2062
					end -- 2055
				end -- 2047
			end -- 2038
		end -- 2038
	end -- 2038
	return { -- 2034
		success = false -- 2034
	} -- 2034
end) -- 2034
local extentionLevels = { -- 2065
	vs = 2, -- 2065
	bl = 2, -- 2066
	ts = 1, -- 2067
	tsx = 1, -- 2068
	tl = 1, -- 2069
	yue = 1, -- 2070
	xml = 1, -- 2071
	lua = 0 -- 2072
} -- 2064
local visitAssets -- 2074
visitAssets = function(path, workspace, builtin, recursive) -- 2074
	if recursive == nil then -- 2074
		recursive = true -- 2074
	end -- 2074
	local children = nil -- 2075
	local dirs = Content:getDirs(path) -- 2076
	for _index_0 = 1, #dirs do -- 2077
		local dir = dirs[_index_0] -- 2077
		if workspace then -- 2078
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or "node_modules" == dir) then -- 2079
				goto _continue_0 -- 2080
			end -- 2079
		elseif dir == ".git" then -- 2081
			goto _continue_0 -- 2082
		end -- 2078
		if not children then -- 2083
			children = { } -- 2083
		end -- 2083
		local dirPath = Path(path, dir) -- 2084
		if recursive then -- 2085
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2086
		else -- 2088
			children[#children + 1] = { -- 2089
				key = dirPath, -- 2089
				dir = true, -- 2090
				title = dir, -- 2091
				builtin = builtin, -- 2092
				isLeaf = false -- 2093
			} -- 2088
		end -- 2085
		::_continue_0:: -- 2078
	end -- 2077
	local files = Content:getFiles(path) -- 2095
	local names = { } -- 2096
	for _index_0 = 1, #files do -- 2097
		local file = files[_index_0] -- 2097
		if (".DS_Store" == file) then -- 2098
			goto _continue_1 -- 2099
		end -- 2098
		local name = Path:getName(file) -- 2100
		local ext = names[name] -- 2101
		if ext then -- 2101
			local lv1 -- 2102
			do -- 2102
				local _exp_0 = extentionLevels[ext] -- 2102
				if _exp_0 ~= nil then -- 2102
					lv1 = _exp_0 -- 2102
				else -- 2102
					lv1 = -1 -- 2102
				end -- 2102
			end -- 2102
			ext = Path:getExt(file) -- 2103
			local lv2 -- 2104
			do -- 2104
				local _exp_0 = extentionLevels[ext] -- 2104
				if _exp_0 ~= nil then -- 2104
					lv2 = _exp_0 -- 2104
				else -- 2104
					lv2 = -1 -- 2104
				end -- 2104
			end -- 2104
			if lv2 > lv1 then -- 2105
				names[name] = ext -- 2106
			elseif lv2 == lv1 then -- 2107
				names[name .. '.' .. ext] = "" -- 2108
			end -- 2105
		else -- 2110
			ext = Path:getExt(file) -- 2110
			if not extentionLevels[ext] then -- 2111
				names[file] = "" -- 2112
			else -- 2114
				names[name] = ext -- 2114
			end -- 2111
		end -- 2101
		::_continue_1:: -- 2098
	end -- 2097
	do -- 2115
		local _accum_0 = { } -- 2115
		local _len_0 = 1 -- 2115
		for name, ext in pairs(names) do -- 2115
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2115
			_len_0 = _len_0 + 1 -- 2115
		end -- 2115
		files = _accum_0 -- 2115
	end -- 2115
	for _index_0 = 1, #files do -- 2116
		local file = files[_index_0] -- 2116
		if not children then -- 2117
			children = { } -- 2117
		end -- 2117
		children[#children + 1] = { -- 2119
			key = Path(path, file), -- 2119
			dir = false, -- 2120
			title = file, -- 2121
			builtin = builtin -- 2122
		} -- 2118
	end -- 2116
	if children then -- 2124
		table.sort(children, function(a, b) -- 2125
			if a.dir == b.dir then -- 2126
				return a.title < b.title -- 2127
			else -- 2129
				return a.dir -- 2129
			end -- 2126
		end) -- 2125
	end -- 2124
	return { -- 2131
		key = path, -- 2131
		dir = true, -- 2132
		title = Path:getFilename(path), -- 2133
		builtin = builtin, -- 2134
		isLeaf = not children, -- 2135
		children = children -- 2136
	} -- 2130
end -- 2074
HttpServer:post("/assets/children", function(req) -- 2139
	do -- 2140
		local _type_0 = type(req) -- 2140
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2140
		if _tab_0 then -- 2140
			local path -- 2140
			do -- 2140
				local _obj_0 = req.body -- 2140
				local _type_1 = type(_obj_0) -- 2140
				if "table" == _type_1 or "userdata" == _type_1 then -- 2140
					path = _obj_0.path -- 2140
				end -- 2140
			end -- 2140
			if path ~= nil then -- 2140
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2141
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2142
					return { -- 2142
						success = false -- 2142
					} -- 2142
				end -- 2142
				local node = visitAssets(path, workspace, builtin, false) -- 2143
				return { -- 2144
					success = true, -- 2144
					children = node.children or { } -- 2144
				} -- 2144
			end -- 2140
		end -- 2140
	end -- 2140
	return { -- 2139
		success = false -- 2139
	} -- 2139
end) -- 2139
HttpServer:post("/assets/files", function(req) -- 2146
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
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2148
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2149
				if not (workspace or builtin) then -- 2150
					return { -- 2150
						success = false -- 2150
					} -- 2150
				end -- 2150
				if not (Content:exist(path) and Content:isdir(path)) then -- 2151
					return { -- 2151
						success = false -- 2151
					} -- 2151
				end -- 2151
				local globs = { -- 2152
					"**", -- 2152
					"!**/.DS_Store" -- 2152
				} -- 2152
				if workspace then -- 2153
					globs = { -- 2155
						"**", -- 2155
						"!**/.DS_Store", -- 2155
						"!**/.upload/**", -- 2156
						"!**/.download/**", -- 2156
						"!**/.www/**", -- 2157
						"!**/.build/**", -- 2157
						"!**/.git/**", -- 2158
						"!**/.cache/**", -- 2158
						"!**/node_modules/**" -- 2159
					} -- 2154
				end -- 2153
				local files -- 2161
				do -- 2161
					local _accum_0 = { } -- 2161
					local _len_0 = 1 -- 2161
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2161
					for _index_0 = 1, #_list_0 do -- 2161
						local file = _list_0[_index_0] -- 2161
						_accum_0[_len_0] = Path(path, file) -- 2161
						_len_0 = _len_0 + 1 -- 2161
					end -- 2161
					files = _accum_0 -- 2161
				end -- 2161
				return { -- 2162
					success = true, -- 2162
					files = files -- 2162
				} -- 2162
			end -- 2147
		end -- 2147
	end -- 2147
	return { -- 2146
		success = false -- 2146
	} -- 2146
end) -- 2146
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2203
	local _tab_0 = { -- 2203
		{ -- 2204
			key = Path(Content.assetPath), -- 2204
			dir = true, -- 2205
			builtin = true, -- 2206
			title = zh and "内置资源" or "Built-in", -- 2207
			children = builtinChildren -- 2208
		} -- 2203
	} -- 2210
	local _obj_0 = workspace.children or { } -- 2210
	local _idx_0 = #_tab_0 + 1 -- 2210
	for _index_0 = 1, #_obj_0 do -- 2210
		local _value_0 = _obj_0[_index_0] -- 2210
		_tab_0[_idx_0] = _value_0 -- 2210
		_idx_0 = _idx_0 + 1 -- 2210
	end -- 2210
	return _tab_0 -- 2203
end -- 2203
HttpServer:post("/assets", function() -- 2164
	local Entry = require("Script.Dev.Entry") -- 2165
	local engineDev = Entry.getEngineDev() -- 2166
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2167
	local zh = (App.locale:match("^zh") ~= nil) -- 2168
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2169
	readme.title = zh and "说明文档" or "Readme" -- 2170
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2171
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2172
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2173
	tools.title = zh and "开发工具" or "Tools" -- 2174
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2175
	font.title = zh and "字体" or "Font" -- 2176
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2177
	lib.title = zh and "程序库" or "Lib" -- 2178
	if engineDev then -- 2179
		local _list_0 = lib.children -- 2180
		for _index_0 = 1, #_list_0 do -- 2180
			local child = _list_0[_index_0] -- 2180
			if not (child.title == "Dora") then -- 2181
				goto _continue_0 -- 2181
			end -- 2181
			local title = zh and "zh-Hans" or "en" -- 2182
			do -- 2183
				local _accum_0 = { } -- 2183
				local _len_0 = 1 -- 2183
				local _list_1 = child.children -- 2183
				for _index_1 = 1, #_list_1 do -- 2183
					local c = _list_1[_index_1] -- 2183
					if c.title ~= title then -- 2183
						_accum_0[_len_0] = c -- 2183
						_len_0 = _len_0 + 1 -- 2183
					end -- 2183
				end -- 2183
				child.children = _accum_0 -- 2183
			end -- 2183
			break -- 2184
			::_continue_0:: -- 2181
		end -- 2180
	else -- 2186
		local _accum_0 = { } -- 2186
		local _len_0 = 1 -- 2186
		local _list_0 = lib.children -- 2186
		for _index_0 = 1, #_list_0 do -- 2186
			local child = _list_0[_index_0] -- 2186
			if child.title ~= "Dora" then -- 2186
				_accum_0[_len_0] = child -- 2186
				_len_0 = _len_0 + 1 -- 2186
			end -- 2186
		end -- 2186
		lib.children = _accum_0 -- 2186
	end -- 2179
	local builtinChildren = { -- 2187
		readme, -- 2187
		apiDoc, -- 2187
		tools, -- 2187
		font, -- 2187
		lib -- 2187
	} -- 2187
	if engineDev then -- 2188
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2189
		do -- 2190
			local _obj_0 = dev.children -- 2190
			_obj_0[#_obj_0 + 1] = { -- 2191
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2191
				dir = false, -- 2192
				builtin = true, -- 2193
				title = "init.yue" -- 2194
			} -- 2190
		end -- 2190
		builtinChildren[#builtinChildren + 1] = dev -- 2196
	end -- 2188
	return { -- 2198
		key = Content.writablePath, -- 2198
		dir = true, -- 2199
		root = true, -- 2200
		title = "Assets", -- 2201
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2202
	} -- 2197
end) -- 2164
HttpServer:post("/entry/list", function(req) -- 2214
	local Entry = require("Script.Dev.Entry") -- 2215
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2216
	res.success = true -- 2217
	return res -- 2218
end) -- 2214
HttpServer:post("/run/status", function() -- 2220
	local Entry = require("Script.Dev.Entry") -- 2221
	return Entry.getCurrentEntryStatus() -- 2222
end) -- 2220
HttpServer:postSchedule("/run", function(req) -- 2224
	do -- 2225
		local _type_0 = type(req) -- 2225
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2225
		if _tab_0 then -- 2225
			local file -- 2225
			do -- 2225
				local _obj_0 = req.body -- 2225
				local _type_1 = type(_obj_0) -- 2225
				if "table" == _type_1 or "userdata" == _type_1 then -- 2225
					file = _obj_0.file -- 2225
				end -- 2225
			end -- 2225
			local asProj -- 2225
			do -- 2225
				local _obj_0 = req.body -- 2225
				local _type_1 = type(_obj_0) -- 2225
				if "table" == _type_1 or "userdata" == _type_1 then -- 2225
					asProj = _obj_0.asProj -- 2225
				end -- 2225
			end -- 2225
			if file ~= nil and asProj ~= nil then -- 2225
				if not Content:isAbsolutePath(file) then -- 2226
					local devFile = Path(Content.writablePath, file) -- 2227
					if Content:exist(devFile) then -- 2228
						file = devFile -- 2228
					end -- 2228
				end -- 2226
				local Entry = require("Script.Dev.Entry") -- 2229
				local workDir -- 2230
				if asProj then -- 2231
					local projectRoot = req.body.projectRoot -- 2232
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2233
						workDir = projectRoot -- 2234
					else -- 2236
						workDir = getProjectDirFromFile(file) -- 2236
					end -- 2233
					if workDir then -- 2237
						Entry.allClear() -- 2238
						local target = Path(workDir, "init") -- 2239
						local success, err = Entry.enterEntryAsync({ -- 2240
							entryName = "Project", -- 2240
							fileName = target, -- 2240
							workDir = workDir, -- 2240
							projectRoot = workDir, -- 2240
							runKind = "project" -- 2240
						}) -- 2240
						target = Path:getName(Path:getPath(target)) -- 2241
						return { -- 2242
							success = success, -- 2242
							target = target, -- 2242
							err = err -- 2242
						} -- 2242
					end -- 2237
				else -- 2244
					workDir = getProjectDirFromFile(file) -- 2244
					if not workDir and Path:getExt(file) == "wasm" then -- 2245
						local parent = Path:getPath(file) -- 2246
						if Content:exist(Path(parent, "wa.mod")) then -- 2247
							workDir = parent -- 2248
						end -- 2247
					end -- 2245
				end -- 2231
				Entry.allClear() -- 2249
				file = Path:replaceExt(file, "") -- 2250
				local entry = { -- 2252
					entryName = Path:getName(file), -- 2252
					fileName = file, -- 2253
					runKind = "file" -- 2254
				} -- 2251
				if workDir then -- 2255
					entry.workDir = workDir -- 2256
					entry.projectRoot = workDir -- 2257
				end -- 2255
				local success, err = Entry.enterEntryAsync(entry) -- 2258
				return { -- 2259
					success = success, -- 2259
					err = err -- 2259
				} -- 2259
			end -- 2225
		end -- 2225
	end -- 2225
	return { -- 2224
		success = false -- 2224
	} -- 2224
end) -- 2224
local _anon_func_7 = function(result) -- 2301
	if result.success then -- 2301
		return nil -- 2301
	else -- 2301
		return "PREVIEW_FAILED" -- 2301
	end -- 2301
end -- 2301
HttpServer:postSchedule("/agent/preview", function(req) -- 2261
	local releaseAgent = AgentHost.acquire() -- 2262
	local _ <close> = setmetatable({ }, { -- 2263
		__close = function() -- 2263
			return releaseAgent() -- 2263
		end -- 2263
	}) -- 2263
	do -- 2264
		local _type_0 = type(req) -- 2264
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2264
		if _tab_0 then -- 2264
			local projectRoot -- 2264
			do -- 2264
				local _obj_0 = req.body -- 2264
				local _type_1 = type(_obj_0) -- 2264
				if "table" == _type_1 or "userdata" == _type_1 then -- 2264
					projectRoot = _obj_0.projectRoot -- 2264
				end -- 2264
			end -- 2264
			if projectRoot ~= nil then -- 2264
				if not getProjectSourceRoot(projectRoot) then -- 2265
					return { -- 2265
						success = false, -- 2265
						code = "INVALID_PROJECT", -- 2265
						message = "projectRoot must be an existing absolute directory" -- 2265
					} -- 2265
				end -- 2265
				local entryFile = req.body.entry or "init.lua" -- 2266
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2267
					return { -- 2267
						success = false, -- 2267
						code = "INVALID_ENTRY", -- 2267
						message = "entry must be a non-empty project-relative path" -- 2267
					} -- 2267
				end -- 2267
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2268
					0.5 -- 2268
				} -- 2268
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2269
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2270
					return { -- 2270
						success = false, -- 2270
						code = "INVALID_QUEUE_TIMEOUT", -- 2270
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2270
					} -- 2270
				end -- 2270
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2271
				local AgentOperation = require("Agent.Tool.Operation") -- 2272
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2273
				local requestId = AgentOperation.createOperationId() -- 2274
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2275
				if not enqueued.success then -- 2276
					return { -- 2276
						success = false, -- 2276
						code = "ENTRY_QUEUE_REJECTED", -- 2276
						message = enqueued.message -- 2276
					} -- 2276
				end -- 2276
				local queuedAt = App.runningTime -- 2277
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2278
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2279
						local state = agentEntryRunQueue:get(requestId) -- 2280
						agentEntryRunQueue:cancel(requestId) -- 2281
						return { -- 2283
							success = false, -- 2283
							code = "ENTRY_QUEUE_TIMEOUT", -- 2284
							message = "timed out waiting for the Dora entry runtime", -- 2285
							requestId = requestId, -- 2286
							queuePosition = state.position -- 2287
						} -- 2282
					end -- 2279
					sleep() -- 2288
				end -- 2278
				local queueWaitSeconds = App.runningTime - queuedAt -- 2289
				local _ <close> = setmetatable({ }, { -- 2290
					__close = function() -- 2290
						return agentEntryRunQueue:release(requestId) -- 2290
					end -- 2290
				}) -- 2290
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2291
				local Entry = require("Script.Dev.Entry") -- 2292
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2294
					workDir = projectRoot, -- 2294
					operationId = requestId, -- 2295
					print = function() end -- 2296
				}, Entry) -- 2293
				local result = preview({ -- 2298
					entry = entryFile, -- 2298
					captureAtSeconds = captureAtSeconds -- 2298
				}) -- 2298
				return { -- 2300
					success = result.success, -- 2300
					code = _anon_func_7(result), -- 2301
					message = result.message, -- 2302
					requestId = requestId, -- 2303
					queueWaitSeconds = queueWaitSeconds, -- 2304
					interruptedUserRun = result.interruptedUserRun, -- 2305
					files = result.files, -- 2306
					frames = result.frames -- 2307
				} -- 2299
			end -- 2264
		end -- 2264
	end -- 2264
	return { -- 2261
		success = false, -- 2261
		message = "invalid call" -- 2261
	} -- 2261
end) -- 2261
HttpServer:postSchedule("/agent/command", function(req) -- 2309
	local releaseAgent = AgentHost.acquire() -- 2310
	local _ <close> = setmetatable({ }, { -- 2311
		__close = function() -- 2311
			return releaseAgent() -- 2311
		end -- 2311
	}) -- 2311
	do -- 2312
		local _type_0 = type(req) -- 2312
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2312
		if _tab_0 then -- 2312
			local body = req.body -- 2312
			if body ~= nil then -- 2312
				local projectRoot = body.projectRoot -- 2313
				if not getProjectSourceRoot(projectRoot) then -- 2314
					return { -- 2314
						success = false, -- 2314
						code = "INVALID_PROJECT", -- 2314
						message = "projectRoot must be an existing absolute directory" -- 2314
					} -- 2314
				end -- 2314
				local AgentValidation = require("Agent.Tool.Validation") -- 2315
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2316
				if not validated.success then -- 2317
					return { -- 2317
						success = false, -- 2317
						code = "INVALID_COMMAND", -- 2317
						message = validated.message -- 2317
					} -- 2317
				end -- 2317
				local input = validated.value -- 2318
				local AgentCommand = require("Agent.Tool.Command") -- 2319
				local result = nil -- 2320
				local failure = nil -- 2321
				local promise = AgentCommand.executeCommand({ -- 2323
					workDir = projectRoot, -- 2323
					mode = input.mode, -- 2324
					code = input.code, -- 2325
					command = input.command, -- 2326
					cwd = input.cwd, -- 2327
					timeoutSeconds = input.timeoutSeconds -- 2328
				}) -- 2322
				promise:addCallbacks((function(_, value) -- 2329
					result = value -- 2329
				end), (function(_, err) -- 2329
					failure = tostring(err) -- 2329
				end)) -- 2329
				wait(function() -- 2330
					return result ~= nil or failure ~= nil -- 2330
				end) -- 2330
				if failure then -- 2331
					return { -- 2331
						success = false, -- 2331
						code = "COMMAND_BRIDGE_FAILED", -- 2331
						message = failure -- 2331
					} -- 2331
				end -- 2331
				if not result.success then -- 2332
					result.code = "COMMAND_FAILED" -- 2333
				end -- 2332
				return result -- 2334
			end -- 2312
		end -- 2312
	end -- 2312
	return { -- 2309
		success = false, -- 2309
		code = "INVALID_COMMAND", -- 2309
		message = "invalid call" -- 2309
	} -- 2309
end) -- 2309
HttpServer:postSchedule("/stop", function() -- 2336
	local Entry = require("Script.Dev.Entry") -- 2337
	return { -- 2338
		success = Entry.stop() -- 2338
	} -- 2338
end) -- 2336
local minifyAsync -- 2340
minifyAsync = function(sourcePath, minifyPath) -- 2340
	if not Content:exist(sourcePath) then -- 2341
		return -- 2341
	end -- 2341
	local Entry = require("Script.Dev.Entry") -- 2342
	local errors = { } -- 2343
	local files = Entry.getAllFiles(sourcePath, { -- 2344
		"lua" -- 2344
	}, true) -- 2344
	do -- 2345
		local _accum_0 = { } -- 2345
		local _len_0 = 1 -- 2345
		for _index_0 = 1, #files do -- 2345
			local file = files[_index_0] -- 2345
			if file:sub(1, 1) ~= '.' then -- 2345
				_accum_0[_len_0] = file -- 2345
				_len_0 = _len_0 + 1 -- 2345
			end -- 2345
		end -- 2345
		files = _accum_0 -- 2345
	end -- 2345
	local paths -- 2346
	do -- 2346
		local _tbl_0 = { } -- 2346
		for _index_0 = 1, #files do -- 2346
			local file = files[_index_0] -- 2346
			_tbl_0[Path:getPath(file)] = true -- 2346
		end -- 2346
		paths = _tbl_0 -- 2346
	end -- 2346
	for path in pairs(paths) do -- 2347
		Content:mkdir(Path(minifyPath, path)) -- 2347
	end -- 2347
	local _ <close> = setmetatable({ }, { -- 2348
		__close = function() -- 2348
			package.loaded["luaminify.FormatMini"] = nil -- 2349
			package.loaded["luaminify.ParseLua"] = nil -- 2350
			package.loaded["luaminify.Scope"] = nil -- 2351
			package.loaded["luaminify.Util"] = nil -- 2352
		end -- 2348
	}) -- 2348
	local FormatMini -- 2353
	do -- 2353
		local _obj_0 = require("luaminify") -- 2353
		FormatMini = _obj_0.FormatMini -- 2353
	end -- 2353
	local fileCount = #files -- 2354
	local count = 0 -- 2355
	for _index_0 = 1, #files do -- 2356
		local file = files[_index_0] -- 2356
		thread(function() -- 2357
			local _ <close> = setmetatable({ }, { -- 2358
				__close = function() -- 2358
					count = count + 1 -- 2358
				end -- 2358
			}) -- 2358
			local input = Path(sourcePath, file) -- 2359
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2360
			if Content:exist(input) then -- 2361
				local sourceCodes = Content:loadAsync(input) -- 2362
				local res, err = FormatMini(sourceCodes) -- 2363
				if res then -- 2364
					Content:saveAsync(output, res) -- 2365
					return print("Minify " .. tostring(file)) -- 2366
				else -- 2368
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2368
				end -- 2364
			else -- 2370
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2370
			end -- 2361
		end) -- 2357
		sleep() -- 2371
	end -- 2356
	wait(function() -- 2372
		return count == fileCount -- 2372
	end) -- 2372
	if #errors > 0 then -- 2373
		print(table.concat(errors, '\n')) -- 2374
	end -- 2373
	print("Obfuscation done.") -- 2375
	return files -- 2376
end -- 2340
local zipping = false -- 2378
HttpServer:postSchedule("/zip", function(req) -- 2380
	do -- 2381
		local _type_0 = type(req) -- 2381
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2381
		if _tab_0 then -- 2381
			local path -- 2381
			do -- 2381
				local _obj_0 = req.body -- 2381
				local _type_1 = type(_obj_0) -- 2381
				if "table" == _type_1 or "userdata" == _type_1 then -- 2381
					path = _obj_0.path -- 2381
				end -- 2381
			end -- 2381
			local zipFile -- 2381
			do -- 2381
				local _obj_0 = req.body -- 2381
				local _type_1 = type(_obj_0) -- 2381
				if "table" == _type_1 or "userdata" == _type_1 then -- 2381
					zipFile = _obj_0.zipFile -- 2381
				end -- 2381
			end -- 2381
			local obfuscated -- 2381
			do -- 2381
				local _obj_0 = req.body -- 2381
				local _type_1 = type(_obj_0) -- 2381
				if "table" == _type_1 or "userdata" == _type_1 then -- 2381
					obfuscated = _obj_0.obfuscated -- 2381
				end -- 2381
			end -- 2381
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2381
				if zipping then -- 2382
					goto failed -- 2382
				end -- 2382
				zipping = true -- 2383
				local _ <close> = setmetatable({ }, { -- 2384
					__close = function() -- 2384
						zipping = false -- 2384
					end -- 2384
				}) -- 2384
				if not Content:exist(path) then -- 2385
					goto failed -- 2385
				end -- 2385
				Content:mkdir(Path:getPath(zipFile)) -- 2386
				if obfuscated then -- 2387
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2388
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2389
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2390
					Content:remove(scriptPath) -- 2391
					Content:remove(obfuscatedPath) -- 2392
					Content:remove(tempPath) -- 2393
					Content:mkdir(scriptPath) -- 2394
					Content:mkdir(obfuscatedPath) -- 2395
					Content:mkdir(tempPath) -- 2396
					if not Content:copyAsync(path, tempPath) then -- 2397
						goto failed -- 2397
					end -- 2397
					local Entry = require("Script.Dev.Entry") -- 2398
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2399
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2400
						"tl", -- 2400
						"yue", -- 2400
						"lua", -- 2400
						"ts", -- 2400
						"tsx", -- 2400
						"vs", -- 2400
						"bl", -- 2400
						"xml", -- 2400
						"wa", -- 2400
						"mod" -- 2400
					}, true) -- 2400
					for _index_0 = 1, #scriptFiles do -- 2401
						local file = scriptFiles[_index_0] -- 2401
						Content:remove(Path(tempPath, file)) -- 2402
					end -- 2401
					for _index_0 = 1, #luaFiles do -- 2403
						local file = luaFiles[_index_0] -- 2403
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2404
					end -- 2403
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2405
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2406
					end) then -- 2405
						goto failed -- 2405
					end -- 2405
					return { -- 2407
						success = true -- 2407
					} -- 2407
				else -- 2409
					return { -- 2409
						success = Content:zipAsync(path, zipFile, function(file) -- 2409
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2410
						end) -- 2409
					} -- 2409
				end -- 2387
			end -- 2381
		end -- 2381
	end -- 2381
	::failed:: -- 2411
	return { -- 2380
		success = false -- 2380
	} -- 2380
end) -- 2380
HttpServer:postSchedule("/unzip", function(req) -- 2413
	do -- 2414
		local _type_0 = type(req) -- 2414
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2414
		if _tab_0 then -- 2414
			local zipFile -- 2414
			do -- 2414
				local _obj_0 = req.body -- 2414
				local _type_1 = type(_obj_0) -- 2414
				if "table" == _type_1 or "userdata" == _type_1 then -- 2414
					zipFile = _obj_0.zipFile -- 2414
				end -- 2414
			end -- 2414
			local path -- 2414
			do -- 2414
				local _obj_0 = req.body -- 2414
				local _type_1 = type(_obj_0) -- 2414
				if "table" == _type_1 or "userdata" == _type_1 then -- 2414
					path = _obj_0.path -- 2414
				end -- 2414
			end -- 2414
			if zipFile ~= nil and path ~= nil then -- 2414
				return { -- 2415
					success = Content:unzipAsync(zipFile, path, function(file) -- 2415
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2416
					end) -- 2415
				} -- 2415
			end -- 2414
		end -- 2414
	end -- 2414
	return { -- 2413
		success = false -- 2413
	} -- 2413
end) -- 2413
HttpServer:post("/editing-info", function(req) -- 2418
	local Entry = require("Script.Dev.Entry") -- 2419
	local config = Entry.getConfig() -- 2420
	local _type_0 = type(req) -- 2421
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2421
	local _match_0 = false -- 2421
	if _tab_0 then -- 2421
		local editingInfo -- 2421
		do -- 2421
			local _obj_0 = req.body -- 2421
			local _type_1 = type(_obj_0) -- 2421
			if "table" == _type_1 or "userdata" == _type_1 then -- 2421
				editingInfo = _obj_0.editingInfo -- 2421
			end -- 2421
		end -- 2421
		if editingInfo ~= nil then -- 2421
			_match_0 = true -- 2421
			config.editingInfo = editingInfo -- 2422
			return { -- 2423
				success = true -- 2423
			} -- 2423
		end -- 2421
	end -- 2421
	if not _match_0 then -- 2421
		if not (config.editingInfo ~= nil) then -- 2425
			local folder -- 2426
			if App.locale:match('^zh') then -- 2426
				folder = 'zh-Hans' -- 2426
			else -- 2426
				folder = 'en' -- 2426
			end -- 2426
			config.editingInfo = json.encode({ -- 2428
				index = 0, -- 2428
				files = { -- 2430
					{ -- 2431
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2431
						title = "welcome.md" -- 2432
					} -- 2430
				} -- 2429
			}) -- 2427
		end -- 2425
		return { -- 2436
			success = true, -- 2436
			editingInfo = config.editingInfo -- 2436
		} -- 2436
	end -- 2421
end) -- 2418
HttpServer:post("/command", function(req) -- 2438
	do -- 2439
		local _type_0 = type(req) -- 2439
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2439
		if _tab_0 then -- 2439
			local code -- 2439
			do -- 2439
				local _obj_0 = req.body -- 2439
				local _type_1 = type(_obj_0) -- 2439
				if "table" == _type_1 or "userdata" == _type_1 then -- 2439
					code = _obj_0.code -- 2439
				end -- 2439
			end -- 2439
			local log -- 2439
			do -- 2439
				local _obj_0 = req.body -- 2439
				local _type_1 = type(_obj_0) -- 2439
				if "table" == _type_1 or "userdata" == _type_1 then -- 2439
					log = _obj_0.log -- 2439
				end -- 2439
			end -- 2439
			if code ~= nil and log ~= nil then -- 2439
				emit("AppCommand", code, log) -- 2440
				return { -- 2441
					success = true -- 2441
				} -- 2441
			end -- 2439
		end -- 2439
	end -- 2439
	return { -- 2438
		success = false -- 2438
	} -- 2438
end) -- 2438
HttpServer:post("/log/save", function() -- 2443
	local folder = ".download" -- 2444
	local fullLogFile = "dora_full_logs.txt" -- 2445
	local fullFolder = Path(Content.writablePath, folder) -- 2446
	Content:mkdir(fullFolder) -- 2447
	local logPath = Path(fullFolder, fullLogFile) -- 2448
	if App:saveLog(logPath) then -- 2449
		return { -- 2450
			success = true, -- 2450
			path = Path(folder, fullLogFile) -- 2450
		} -- 2450
	end -- 2449
	return { -- 2443
		success = false -- 2443
	} -- 2443
end) -- 2443
local tailLines -- 2452
tailLines = function(text, count) -- 2452
	local lines = { } -- 2453
	text = text:gsub("\r\n", "\n") -- 2454
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2455
		lines[#lines + 1] = line -- 2456
	end -- 2455
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2457
		table.remove(lines) -- 2458
	end -- 2457
	local start = math.max(1, #lines - count + 1) -- 2459
	local out = { } -- 2460
	for i = start, #lines do -- 2461
		out[#out + 1] = lines[i] -- 2462
	end -- 2461
	return table.concat(out, "\n") -- 2463
end -- 2452
HttpServer:post("/log", function(req) -- 2465
	local count = 100 -- 2466
	if req and req.body and req.body.count ~= nil then -- 2467
		count = req.body.count -- 2468
	end -- 2467
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2469
		return { -- 2470
			success = false, -- 2470
			message = "count must be a positive integer" -- 2470
		} -- 2470
	end -- 2469
	local folder = ".download" -- 2471
	local fullLogFile = "dora_full_logs.txt" -- 2472
	local fullFolder = Path(Content.writablePath, folder) -- 2473
	Content:mkdir(fullFolder) -- 2474
	local logPath = Path(fullFolder, fullLogFile) -- 2475
	if App:saveLog(logPath) then -- 2476
		local text = Content:load(logPath) -- 2477
		if text then -- 2478
			return { -- 2479
				success = true, -- 2479
				log = tailLines(text, count) -- 2479
			} -- 2479
		else -- 2481
			return { -- 2481
				success = false, -- 2481
				message = "failed to read log" -- 2481
			} -- 2481
		end -- 2478
	else -- 2483
		return { -- 2483
			success = false, -- 2483
			message = "failed to save log" -- 2483
		} -- 2483
	end -- 2476
	return { -- 2465
		success = false -- 2465
	} -- 2465
end) -- 2465
HttpServer:post("/yarn/check", function(req) -- 2485
	local yarncompile = require("yarncompile") -- 2486
	do -- 2487
		local _type_0 = type(req) -- 2487
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2487
		if _tab_0 then -- 2487
			local code -- 2487
			do -- 2487
				local _obj_0 = req.body -- 2487
				local _type_1 = type(_obj_0) -- 2487
				if "table" == _type_1 or "userdata" == _type_1 then -- 2487
					code = _obj_0.code -- 2487
				end -- 2487
			end -- 2487
			if code ~= nil then -- 2487
				local jsonObject = json.decode(code) -- 2488
				if jsonObject then -- 2488
					local errors = { } -- 2489
					local _list_0 = jsonObject.nodes -- 2490
					for _index_0 = 1, #_list_0 do -- 2490
						local node = _list_0[_index_0] -- 2490
						local title, body = node.title, node.body -- 2491
						local luaCode, err = yarncompile(body) -- 2492
						if not luaCode then -- 2492
							errors[#errors + 1] = title .. ":" .. err -- 2493
						end -- 2492
					end -- 2490
					return { -- 2494
						success = true, -- 2494
						syntaxError = table.concat(errors, "\n\n") -- 2494
					} -- 2494
				end -- 2488
			end -- 2487
		end -- 2487
	end -- 2487
	return { -- 2485
		success = false -- 2485
	} -- 2485
end) -- 2485
HttpServer:post("/yarn/check-file", function(req) -- 2496
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
				local res, _, err = yarncompile(code, true) -- 2499
				if not res then -- 2499
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2500
					return { -- 2501
						success = false, -- 2501
						message = message, -- 2501
						line = line, -- 2501
						column = column, -- 2501
						node = node -- 2501
					} -- 2501
				end -- 2499
			end -- 2498
		end -- 2498
	end -- 2498
	return { -- 2496
		success = true -- 2496
	} -- 2496
end) -- 2496
getWaProjectDirFromFile = function(file) -- 2503
	local current -- 2504
	if Content:isdir(file) then -- 2504
		current = file -- 2504
	else -- 2504
		current = Path:getPath(file) -- 2504
	end -- 2504
	if current == "" then -- 2505
		return nil -- 2505
	end -- 2505
	repeat -- 2506
		local modPath = Path(current, "wa.mod") -- 2507
		if Content:exist(modPath) then -- 2508
			return current, modPath -- 2509
		end -- 2508
		local parent = Path:getPath(current) -- 2510
		if parent == "" or parent == current then -- 2511
			break -- 2511
		end -- 2511
		current = parent -- 2512
	until false -- 2506
	return nil -- 2514
end -- 2503
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2516
	do -- 2517
		local _type_0 = type(req) -- 2517
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2517
		if _tab_0 then -- 2517
			local path -- 2517
			do -- 2517
				local _obj_0 = req.body -- 2517
				local _type_1 = type(_obj_0) -- 2517
				if "table" == _type_1 or "userdata" == _type_1 then -- 2517
					path = _obj_0.path -- 2517
				end -- 2517
			end -- 2517
			if path ~= nil then -- 2517
				local projDir = getWaProjectDirFromFile(path) -- 2518
				if projDir then -- 2518
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2519
					if not Content:exist(sourceDoraPath) then -- 2520
						return { -- 2521
							success = false, -- 2521
							message = "missing dora template" -- 2521
						} -- 2521
					end -- 2520
					local targetVendorPath = Path(projDir, "vendor") -- 2522
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2523
					if not Content:exist(targetVendorPath) then -- 2524
						if not Content:mkdir(targetVendorPath) then -- 2525
							return { -- 2526
								success = false, -- 2526
								message = "failed to create vendor folder" -- 2526
							} -- 2526
						end -- 2525
					elseif not Content:isdir(targetVendorPath) then -- 2527
						return { -- 2528
							success = false, -- 2528
							message = "vendor path is not a folder" -- 2528
						} -- 2528
					end -- 2524
					if Content:exist(targetDoraPath) then -- 2529
						if not Content:remove(targetDoraPath) then -- 2530
							return { -- 2531
								success = false, -- 2531
								message = "failed to remove old dora" -- 2531
							} -- 2531
						end -- 2530
					end -- 2529
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2532
						return { -- 2533
							success = false, -- 2533
							message = "failed to copy dora" -- 2533
						} -- 2533
					end -- 2532
					return { -- 2534
						success = true -- 2534
					} -- 2534
				else -- 2536
					return { -- 2536
						success = false, -- 2536
						message = 'Wa file needs a project' -- 2536
					} -- 2536
				end -- 2518
			end -- 2517
		end -- 2517
	end -- 2517
	return { -- 2516
		success = false, -- 2516
		message = "invalid call" -- 2516
	} -- 2516
end) -- 2516
HttpServer:postSchedule("/wa/build", function(req) -- 2538
	do -- 2539
		local _type_0 = type(req) -- 2539
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2539
		if _tab_0 then -- 2539
			local path -- 2539
			do -- 2539
				local _obj_0 = req.body -- 2539
				local _type_1 = type(_obj_0) -- 2539
				if "table" == _type_1 or "userdata" == _type_1 then -- 2539
					path = _obj_0.path -- 2539
				end -- 2539
			end -- 2539
			if path ~= nil then -- 2539
				local projDir = getWaProjectDirFromFile(path) -- 2540
				if projDir then -- 2540
					local message = Wasm:buildWaAsync(projDir) -- 2541
					if message == "" then -- 2542
						return { -- 2543
							success = true -- 2543
						} -- 2543
					else -- 2545
						return { -- 2545
							success = false, -- 2545
							message = message -- 2545
						} -- 2545
					end -- 2542
				else -- 2547
					return { -- 2547
						success = false, -- 2547
						message = 'Wa file needs a project' -- 2547
					} -- 2547
				end -- 2540
			end -- 2539
		end -- 2539
	end -- 2539
	return { -- 2548
		success = false, -- 2548
		message = 'failed to build' -- 2548
	} -- 2548
end) -- 2538
HttpServer:postSchedule("/wa/format", function(req) -- 2550
	do -- 2551
		local _type_0 = type(req) -- 2551
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2551
		if _tab_0 then -- 2551
			local file -- 2551
			do -- 2551
				local _obj_0 = req.body -- 2551
				local _type_1 = type(_obj_0) -- 2551
				if "table" == _type_1 or "userdata" == _type_1 then -- 2551
					file = _obj_0.file -- 2551
				end -- 2551
			end -- 2551
			if file ~= nil then -- 2551
				local code = Wasm:formatWaAsync(file) -- 2552
				if code == "" then -- 2553
					return { -- 2554
						success = false -- 2554
					} -- 2554
				else -- 2556
					return { -- 2556
						success = true, -- 2556
						code = code -- 2556
					} -- 2556
				end -- 2553
			end -- 2551
		end -- 2551
	end -- 2551
	return { -- 2557
		success = false -- 2557
	} -- 2557
end) -- 2550
HttpServer:postSchedule("/wa/create", function(req) -- 2559
	do -- 2560
		local _type_0 = type(req) -- 2560
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2560
		if _tab_0 then -- 2560
			local path -- 2560
			do -- 2560
				local _obj_0 = req.body -- 2560
				local _type_1 = type(_obj_0) -- 2560
				if "table" == _type_1 or "userdata" == _type_1 then -- 2560
					path = _obj_0.path -- 2560
				end -- 2560
			end -- 2560
			if path ~= nil then -- 2560
				if not Content:exist(Path:getPath(path)) then -- 2561
					return { -- 2562
						success = false, -- 2562
						message = "target path not existed" -- 2562
					} -- 2562
				end -- 2561
				if Content:exist(path) then -- 2563
					return { -- 2564
						success = false, -- 2564
						message = "target project folder existed" -- 2564
					} -- 2564
				end -- 2563
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2565
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2566
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2567
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2568
					return { -- 2571
						success = false, -- 2571
						message = "missing template project" -- 2571
					} -- 2571
				end -- 2568
				if not Content:mkdir(path) then -- 2572
					return { -- 2573
						success = false, -- 2573
						message = "failed to create project folder" -- 2573
					} -- 2573
				end -- 2572
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2574
					Content:remove(path) -- 2575
					return { -- 2576
						success = false, -- 2576
						message = "failed to copy template" -- 2576
					} -- 2576
				end -- 2574
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2577
					Content:remove(path) -- 2578
					return { -- 2579
						success = false, -- 2579
						message = "failed to copy template" -- 2579
					} -- 2579
				end -- 2577
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2580
					Content:remove(path) -- 2581
					return { -- 2582
						success = false, -- 2582
						message = "failed to copy template" -- 2582
					} -- 2582
				end -- 2580
				return { -- 2583
					success = true -- 2583
				} -- 2583
			end -- 2560
		end -- 2560
	end -- 2560
	return { -- 2559
		success = false, -- 2559
		message = "invalid call" -- 2559
	} -- 2559
end) -- 2559
local tsBuildGlobs = { -- 2586
	"**/*.ts", -- 2586
	"**/*.tsx", -- 2587
	"!**/.*/**", -- 2588
	"!**/node_modules/**" -- 2589
} -- 2585
local tsSnapshotGlobs = { -- 2592
	"**/*.ts", -- 2592
	"**/*.tsx", -- 2593
	"**/*.lua", -- 2594
	"!**/.*/**", -- 2595
	"!**/node_modules/**" -- 2596
} -- 2591
local collectTSVirtualFiles -- 2598
collectTSVirtualFiles = function(sourceRoot) -- 2598
	local files = { } -- 2599
	local seen = { } -- 2600
	local addFile -- 2601
	addFile = function(file, moduleName, virtualFile) -- 2601
		if moduleName == nil then -- 2601
			moduleName = nil -- 2601
		end -- 2601
		if virtualFile == nil then -- 2601
			virtualFile = nil -- 2601
		end -- 2601
		local targetFile = virtualFile or file -- 2602
		do -- 2603
			local entry = seen[targetFile] -- 2603
			if entry then -- 2603
				if moduleName and moduleName ~= "" then -- 2604
					entry.moduleName = moduleName -- 2604
				end -- 2604
				return -- 2605
			end -- 2603
		end -- 2603
		local content = Content:load(file) -- 2606
		if content then -- 2606
			local entry = { -- 2607
				file = targetFile, -- 2607
				content = content -- 2607
			} -- 2607
			if moduleName and moduleName ~= "" then -- 2608
				entry.moduleName = moduleName -- 2608
			end -- 2608
			seen[targetFile] = entry -- 2609
			files[#files + 1] = entry -- 2610
		end -- 2606
	end -- 2601
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2611
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs) -- 2612
		for _index_0 = 1, #_list_0 do -- 2612
			local subFile = _list_0[_index_0] -- 2612
			addFile(Path(sourceRoot, subFile)) -- 2613
		end -- 2612
		local libraryRoots = { -- 2615
			Path(sourceRoot, "Script", "Lib"), -- 2615
			Path(sourceRoot, "Lib"), -- 2616
			Path(Content.assetPath, "Script", "Lib") -- 2617
		} -- 2614
		for _index_0 = 1, #libraryRoots do -- 2618
			local libraryRoot = libraryRoots[_index_0] -- 2618
			if Content:exist(libraryRoot) and Content:isdir(libraryRoot) then -- 2619
				local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs) -- 2620
				for _index_1 = 1, #_list_1 do -- 2620
					local subFile = _list_1[_index_1] -- 2620
					local file = Path(libraryRoot, subFile) -- 2621
					local virtualFile = Path(sourceRoot, subFile) -- 2622
					addFile(file, nil, virtualFile) -- 2623
				end -- 2620
			end -- 2619
		end -- 2618
	end -- 2611
	local locale -- 2624
	if App.locale:match('^zh') then -- 2624
		locale = 'zh-Hans' -- 2624
	else -- 2624
		locale = 'en' -- 2624
	end -- 2624
	local declarationRoot = Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2625
	local _list_0 = Content:getFiles(declarationRoot) -- 2626
	for _index_0 = 1, #_list_0 do -- 2626
		local file = _list_0[_index_0] -- 2626
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2627
			local fullPath = Path(declarationRoot, file) -- 2628
			local moduleName = Path:getName(Path:getName(file)) -- 2629
			addFile(fullPath, moduleName) -- 2630
		end -- 2627
	end -- 2626
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2631
	local lualibBundleTarget -- 2632
	if sourceRoot then -- 2632
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2632
	else -- 2632
		lualibBundleTarget = "lualib_bundle.lua" -- 2632
	end -- 2632
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2633
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2634
	local _list_1 = Content:getFiles(lualibRoot) -- 2635
	for _index_0 = 1, #_list_1 do -- 2635
		local file = _list_1[_index_0] -- 2635
		if Path:getExt(file) == "lua" then -- 2636
			local virtualFile -- 2637
			if sourceRoot then -- 2637
				virtualFile = Path(sourceRoot, "lualib", file) -- 2637
			else -- 2637
				virtualFile = Path("lualib", file) -- 2637
			end -- 2637
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2638
		end -- 2636
	end -- 2635
	return files -- 2639
end -- 2598
local supportsCompilerWebView -- 2641
supportsCompilerWebView = function() -- 2641
	local _val_0 = App.platform -- 2641
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2641
end -- 2641
local webIDECompilerReady = false -- 2642
local webIDEConnectionGeneration = 0 -- 2643
local tsProbeId = 0 -- 2644
local probeWebIDECompiler -- 2646
probeWebIDECompiler = function(isCancelled) -- 2646
	if HttpServer.wsConnectionCount == 0 then -- 2647
		return false -- 2647
	end -- 2647
	tsProbeId = tsProbeId + 1 -- 2648
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2649
	local generation = webIDEConnectionGeneration -- 2650
	local done, ready = false, false -- 2651
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2652
	local listener = Node() -- 2653
	listener:gslot("AppWS", function(event) -- 2654
		if event.type == "Receive" then -- 2655
			local res = json.decode(event.msg) -- 2656
			if res then -- 2656
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2657
					responses = responses + 1 -- 2658
					ready = ready or res.success == true -- 2659
					done = ready or responses >= expectedResponses -- 2660
				end -- 2657
			end -- 2656
		end -- 2655
	end) -- 2654
	emit("AppWS", "Send", json.encode({ -- 2661
		name = "TranspileTSProbe", -- 2661
		id = requestId -- 2661
	})) -- 2661
	local deadline = App.runningTime + 5 -- 2662
	wait(function() -- 2663
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2663
	end) -- 2663
	listener:removeFromParent() -- 2664
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2665
	if generation == webIDEConnectionGeneration then -- 2666
		webIDECompilerReady = ready -- 2666
	end -- 2666
	return ready -- 2667
end -- 2646
local compilerConnectionListener = Node() -- 2669
local _anon_func_8 = function(event) -- 2671
	local _val_0 = event.type -- 2671
	return "Open" == _val_0 or "Close" == _val_0 -- 2671
end -- 2671
compilerConnectionListener:gslot("AppWS", function(event) -- 2670
	if _anon_func_8(event) then -- 2671
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2672
		webIDECompilerReady = false -- 2673
		if HttpServer.wsConnectionCount > 0 then -- 2674
			return thread(function() -- 2675
				return probeWebIDECompiler() -- 2675
			end) -- 2675
		end -- 2674
	end -- 2671
end) -- 2670
local _anon_func_9 = function(res) -- 2700
	if res.success then -- 2700
		return "tool" -- 2700
	else -- 2700
		return res.failureKind -- 2700
	end -- 2700
end -- 2700
local transpileTSFileWithWebIDE -- 2677
do -- 2677
	local tsBuildRequestId = 0 -- 2678
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2679
		if not probeWebIDECompiler(isCancelled) then -- 2680
			if isCancelled and isCancelled() then -- 2681
				return { -- 2682
					success = false, -- 2682
					file = file, -- 2682
					message = "build canceled", -- 2682
					interrupted = true -- 2682
				} -- 2682
			end -- 2681
			return { -- 2683
				success = false, -- 2683
				file = file, -- 2683
				message = "TypeScript transpiler is not ready", -- 2683
				failureKind = "tool" -- 2683
			} -- 2683
		end -- 2680
		tsBuildRequestId = tsBuildRequestId + 1 -- 2684
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2685
		local done = false -- 2686
		local result = nil -- 2687
		local listener = Node() -- 2688
		listener:gslot("AppWS", function(event) -- 2689
			if event.type == "Receive" then -- 2690
				local res = json.decode(event.msg) -- 2691
				if res then -- 2691
					if res.name == "TranspileTS" and res.id == requestId then -- 2692
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2693
							local luaFile = Path:replaceExt(file, "lua") -- 2694
							if Content:save(luaFile, res.luaCode) then -- 2695
								result = { -- 2696
									success = true, -- 2696
									file = file -- 2696
								} -- 2696
							else -- 2698
								result = { -- 2698
									success = false, -- 2698
									file = file, -- 2698
									message = "failed to save " .. tostring(luaFile) -- 2698
								} -- 2698
							end -- 2695
						else -- 2700
							result = { -- 2700
								success = false, -- 2700
								file = file, -- 2700
								message = res.message or "Compiler returned no Lua output", -- 2700
								failureKind = _anon_func_9(res) -- 2700
							} -- 2700
						end -- 2693
						done = true -- 2701
					end -- 2692
				end -- 2691
			end -- 2690
		end) -- 2689
		emit("AppWS", "Send", json.encode({ -- 2702
			name = "TranspileTS", -- 2702
			id = requestId, -- 2702
			file = file, -- 2702
			content = content, -- 2702
			projectRoot = sourceRoot, -- 2702
			files = files -- 2702
		})) -- 2702
		local deadline = App.runningTime + 30 -- 2703
		wait(function() -- 2704
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2704
		end) -- 2704
		listener:removeFromParent() -- 2705
		if not done then -- 2706
			webIDECompilerReady = false -- 2707
			if isCancelled and isCancelled() then -- 2708
				return { -- 2709
					success = false, -- 2709
					file = file, -- 2709
					message = "build canceled", -- 2709
					interrupted = true -- 2709
				} -- 2709
			end -- 2708
			return { -- 2710
				success = false, -- 2710
				file = file, -- 2710
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2710
				failureKind = "tool" -- 2710
			} -- 2710
		end -- 2706
		return result -- 2711
	end -- 2679
end -- 2677
local compilerReadyTimeout <const> = 15 -- 2713
local compilerBuildTimeout <const> = 30 -- 2714
local compilerIdleCloseSeconds <const> = 8 -- 2715
local compilerReady = false -- 2716
local compilerRequested = false -- 2717
local compilerFailure = nil -- 2718
local compilerUsers = 0 -- 2719
local compilerCloseGeneration = 0 -- 2720
local compilerJobId = 0 -- 2721
local compilerJobs = { } -- 2722
local compilerResults = { } -- 2723
local compilerInFlight = { } -- 2724
HttpServer:post("/compiler/ready", function() -- 2726
	if not compilerRequested then -- 2727
		return { -- 2727
			success = false -- 2727
		} -- 2727
	end -- 2727
	compilerReady = true -- 2728
	return { -- 2729
		success = true -- 2729
	} -- 2729
end) -- 2726
HttpServer:post("/compiler/failure", function(req) -- 2731
	if not compilerRequested then -- 2732
		return { -- 2732
			success = false -- 2732
		} -- 2732
	end -- 2732
	do -- 2733
		local _type_0 = type(req) -- 2733
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2733
		if _tab_0 then -- 2733
			local message -- 2733
			do -- 2733
				local _obj_0 = req.body -- 2733
				local _type_1 = type(_obj_0) -- 2733
				if "table" == _type_1 or "userdata" == _type_1 then -- 2733
					message = _obj_0.message -- 2733
				end -- 2733
			end -- 2733
			if message ~= nil then -- 2733
				if type(message) == "string" then -- 2734
					compilerFailure = message -- 2735
					compilerReady = false -- 2736
					return { -- 2737
						success = true -- 2737
					} -- 2737
				end -- 2734
			end -- 2733
		end -- 2733
	end -- 2733
	return { -- 2731
		success = false -- 2731
	} -- 2731
end) -- 2731
HttpServer:postSchedule("/compiler/poll", function() -- 2739
	if not compilerRequested then -- 2740
		return { -- 2740
			success = false -- 2740
		} -- 2740
	end -- 2740
	compilerReady = true -- 2741
	local deadline = App.runningTime + 5 -- 2742
	wait(function() -- 2743
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2743
	end) -- 2743
	if not (compilerRequested and not compilerFailure) then -- 2744
		return { -- 2744
			success = false -- 2744
		} -- 2744
	end -- 2744
	local job = table.remove(compilerJobs, 1) -- 2745
	if job then -- 2746
		compilerInFlight[job.id] = true -- 2747
	end -- 2746
	return { -- 2748
		success = true, -- 2748
		job = job -- 2748
	} -- 2748
end) -- 2739
HttpServer:post("/compiler/result", function(req) -- 2750
	do -- 2751
		local _type_0 = type(req) -- 2751
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2751
		if _tab_0 then -- 2751
			local body = req.body -- 2751
			if body ~= nil then -- 2751
				local id = body.id -- 2752
				if not (id and compilerInFlight[id]) then -- 2753
					return { -- 2753
						success = false, -- 2753
						message = "invalid compiler job" -- 2753
					} -- 2753
				end -- 2753
				compilerInFlight[id] = nil -- 2754
				compilerResults[id] = body -- 2755
				return { -- 2756
					success = true -- 2756
				} -- 2756
			end -- 2751
		end -- 2751
	end -- 2751
	return { -- 2750
		success = false -- 2750
	} -- 2750
end) -- 2750
local acquireCompiler -- 2758
acquireCompiler = function() -- 2758
	compilerUsers = compilerUsers + 1 -- 2759
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2760
	if not compilerRequested then -- 2761
		compilerRequested = true -- 2762
		compilerReady = false -- 2763
		compilerFailure = nil -- 2764
		return emit("AppWebView", "/compiler.html", true) -- 2765
	end -- 2761
end -- 2758
local releaseCompiler -- 2767
releaseCompiler = function() -- 2767
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2768
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2769
	if not (compilerUsers == 0) then -- 2770
		return -- 2770
	end -- 2770
	local closeGeneration = compilerCloseGeneration -- 2771
	return thread(function() -- 2772
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2773
		wait(function() -- 2774
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2775
		end) -- 2774
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2780
			compilerRequested = false -- 2781
			compilerReady = false -- 2782
			return emit("AppWebView", "/compiler.html", false) -- 2783
		end -- 2780
	end) -- 2772
end -- 2767
local removeCompilerJob -- 2785
removeCompilerJob = function(id) -- 2785
	for index = #compilerJobs, 1, -1 do -- 2786
		if compilerJobs[index].id == id then -- 2787
			table.remove(compilerJobs, index) -- 2788
		end -- 2787
	end -- 2786
	compilerInFlight[id] = nil -- 2789
	compilerResults[id] = nil -- 2790
end -- 2785
local transpileTSFileWithCompiler -- 2792
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2792
	acquireCompiler() -- 2793
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2794
	wait(function() -- 2795
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2795
	end) -- 2795
	if not compilerReady then -- 2796
		releaseCompiler() -- 2797
		if isCancelled and isCancelled() then -- 2798
			return { -- 2799
				success = false, -- 2799
				file = file, -- 2799
				message = "build canceled", -- 2799
				interrupted = true -- 2799
			} -- 2799
		end -- 2798
		return { -- 2800
			success = false, -- 2800
			file = file, -- 2800
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2800
			failureKind = "tool" -- 2800
		} -- 2800
	end -- 2796
	compilerJobId = compilerJobId + 1 -- 2801
	local jobId = compilerJobId -- 2802
	compilerJobs[#compilerJobs + 1] = { -- 2804
		id = jobId, -- 2804
		file = file, -- 2805
		content = content, -- 2806
		projectRoot = sourceRoot, -- 2807
		files = files -- 2808
	} -- 2803
	local deadline = App.runningTime + compilerBuildTimeout -- 2809
	wait(function() -- 2810
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2810
	end) -- 2810
	local response = compilerResults[jobId] -- 2811
	removeCompilerJob(jobId) -- 2812
	releaseCompiler() -- 2813
	if not response then -- 2814
		if isCancelled and isCancelled() then -- 2815
			return { -- 2816
				success = false, -- 2816
				file = file, -- 2816
				message = "build canceled", -- 2816
				interrupted = true -- 2816
			} -- 2816
		end -- 2815
		return { -- 2817
			success = false, -- 2817
			file = file, -- 2817
			message = compilerFailure or "TypeScript transpile timed out", -- 2817
			failureKind = "tool" -- 2817
		} -- 2817
	end -- 2814
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2818
		local luaFile = Path:replaceExt(file, "lua") -- 2819
		if Content:save(luaFile, response.luaCode) then -- 2820
			return { -- 2821
				success = true, -- 2821
				file = file -- 2821
			} -- 2821
		end -- 2820
		return { -- 2822
			success = false, -- 2822
			file = file, -- 2822
			message = "failed to save " .. tostring(luaFile) -- 2822
		} -- 2822
	end -- 2818
	return { -- 2823
		success = false, -- 2823
		file = file, -- 2823
		message = response.message or "TypeScript transpile failed" -- 2823
	} -- 2823
end -- 2792
local compilerFailureListener = Node() -- 2825
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2826
	compilerFailure = message -- 2827
	compilerReady = false -- 2828
end) -- 2826
local transpileTSFile -- 2830
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2830
	if supportsCompilerWebView() and not files then -- 2831
		files = collectTSVirtualFiles(sourceRoot or Path:getPath(file)) -- 2832
	end -- 2831
	if HttpServer.wsConnectionCount > 0 then -- 2833
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2834
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2835
			return result -- 2835
		end -- 2835
		webIDECompilerReady = false -- 2836
	end -- 2833
	if supportsCompilerWebView() then -- 2837
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2838
	end -- 2837
	return { -- 2839
		success = false, -- 2839
		file = file, -- 2839
		message = "Web IDE compiler not connected", -- 2839
		failureKind = "tool" -- 2839
	} -- 2839
end -- 2830
local _anon_func_10 = function(path) -- 2854
	local _val_0 = Path:getExt(path) -- 2854
	return "ts" == _val_0 or "tsx" == _val_0 -- 2854
end -- 2854
HttpServer:postSchedule("/ts/build", function(req) -- 2841
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2842
	local buildSucceeded = false -- 2843
	local _ <close> = setmetatable({ }, { -- 2844
		__close = function() -- 2844
			return finishUpdate(buildSucceeded) -- 2844
		end -- 2844
	}) -- 2844
	do -- 2845
		local _type_0 = type(req) -- 2845
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2845
		if _tab_0 then -- 2845
			local path -- 2845
			do -- 2845
				local _obj_0 = req.body -- 2845
				local _type_1 = type(_obj_0) -- 2845
				if "table" == _type_1 or "userdata" == _type_1 then -- 2845
					path = _obj_0.path -- 2845
				end -- 2845
			end -- 2845
			if path ~= nil then -- 2845
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 2846
					return { -- 2847
						success = false, -- 2847
						message = "Web IDE not connected" -- 2847
					} -- 2847
				end -- 2846
				local projectRoot = req.body.projectRoot -- 2848
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 2849
				if not Content:exist(path) then -- 2850
					return { -- 2851
						success = false, -- 2851
						message = "path not existed" -- 2851
					} -- 2851
				end -- 2850
				local messages = { } -- 2852
				if not Content:isdir(path) then -- 2853
					if not (_anon_func_10(path)) then -- 2854
						return { -- 2855
							success = false, -- 2855
							message = "expecting a TypeScript file" -- 2855
						} -- 2855
					end -- 2854
					local content = Content:load(path) -- 2856
					if not content then -- 2857
						return { -- 2858
							success = false, -- 2858
							message = "failed to read file" -- 2858
						} -- 2858
					end -- 2857
					emit("AppWS", "Send", json.encode({ -- 2859
						name = "UpdateFile", -- 2859
						file = path, -- 2859
						exists = true, -- 2859
						content = content, -- 2859
						projectRoot = sourceRoot -- 2859
					})) -- 2859
					if "d" ~= Path:getExt(Path:getName(path)) then -- 2860
						local files = collectTSVirtualFiles(sourceRoot or Path:getPath(path)) -- 2861
						messages[#messages + 1] = transpileTSFile(path, content, sourceRoot, files) -- 2862
					end -- 2860
				else -- 2864
					local fileData = { } -- 2864
					local _list_0 = Content:glob(path, tsBuildGlobs) -- 2865
					for _index_0 = 1, #_list_0 do -- 2865
						local subFile = _list_0[_index_0] -- 2865
						local file = Path(path, subFile) -- 2866
						local content = Content:load(file) -- 2867
						if content then -- 2867
							fileData[file] = content -- 2868
							emit("AppWS", "Send", json.encode({ -- 2869
								name = "UpdateFile", -- 2869
								file = file, -- 2869
								exists = true, -- 2869
								content = content, -- 2869
								projectRoot = sourceRoot -- 2869
							})) -- 2869
						else -- 2871
							messages[#messages + 1] = { -- 2871
								success = false, -- 2871
								file = file, -- 2871
								message = "failed to read file" -- 2871
							} -- 2871
						end -- 2867
					end -- 2865
					local files = collectTSVirtualFiles(sourceRoot or path) -- 2872
					for file, content in pairs(fileData) do -- 2873
						if "d" == Path:getExt(Path:getName(file)) then -- 2874
							goto _continue_0 -- 2874
						end -- 2874
						messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, files) -- 2875
						::_continue_0:: -- 2874
					end -- 2873
				end -- 2853
				local success = true -- 2876
				for _index_0 = 1, #messages do -- 2877
					local item = messages[_index_0] -- 2877
					if not item.success then -- 2878
						success = false -- 2878
					end -- 2878
				end -- 2877
				local message = nil -- 2879
				if not success then -- 2880
					message = "TypeScript compilation failed" -- 2880
				end -- 2880
				buildSucceeded = success -- 2881
				return { -- 2882
					success = success, -- 2882
					messages = messages, -- 2882
					message = message -- 2882
				} -- 2882
			end -- 2845
		end -- 2845
	end -- 2845
	return { -- 2841
		success = false -- 2841
	} -- 2841
end) -- 2841
HttpServer:post("/download", function(req) -- 2884
	do -- 2885
		local _type_0 = type(req) -- 2885
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2885
		if _tab_0 then -- 2885
			local url -- 2885
			do -- 2885
				local _obj_0 = req.body -- 2885
				local _type_1 = type(_obj_0) -- 2885
				if "table" == _type_1 or "userdata" == _type_1 then -- 2885
					url = _obj_0.url -- 2885
				end -- 2885
			end -- 2885
			local target -- 2885
			do -- 2885
				local _obj_0 = req.body -- 2885
				local _type_1 = type(_obj_0) -- 2885
				if "table" == _type_1 or "userdata" == _type_1 then -- 2885
					target = _obj_0.target -- 2885
				end -- 2885
			end -- 2885
			if url ~= nil and target ~= nil then -- 2885
				local Entry = require("Script.Dev.Entry") -- 2886
				Entry.downloadFile(url, target) -- 2887
				return { -- 2888
					success = true -- 2888
				} -- 2888
			end -- 2885
		end -- 2885
	end -- 2885
	return { -- 2884
		success = false -- 2884
	} -- 2884
end) -- 2884
local isDesktopPlatform -- 2890
isDesktopPlatform = function() -- 2890
	local _val_0 = App.platform -- 2891
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 2891
end -- 2890
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 2893
local nativeIDEListener = Node() -- 2894
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 2895
	nativeIDEState, nativeIDEMessage = state, message -- 2896
end) -- 2895
local _anon_func_11 = function() -- 2899
	local _val_0 = App.platform -- 2899
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2899
end -- 2899
HttpServer:post("/ide", function(req) -- 2898
	if not (_anon_func_11()) then -- 2899
		return { -- 2899
			success = false, -- 2899
			message = "Native IDE is unavailable" -- 2899
		} -- 2899
	end -- 2899
	do -- 2900
		local _type_0 = type(req) -- 2900
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2900
		if _tab_0 then -- 2900
			local action -- 2900
			do -- 2900
				local _obj_0 = req.body -- 2900
				local _type_1 = type(_obj_0) -- 2900
				if "table" == _type_1 or "userdata" == _type_1 then -- 2900
					action = _obj_0.action -- 2900
				end -- 2900
			end -- 2900
			if action ~= nil then -- 2900
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 2901
					emit("AppWebView", "/ide/" .. action, true) -- 2902
					return { -- 2903
						success = true -- 2903
					} -- 2903
				end -- 2901
			end -- 2900
		end -- 2900
	end -- 2900
	return { -- 2898
		success = false, -- 2898
		message = "invalid IDE action" -- 2898
	} -- 2898
end) -- 2898
local _anon_func_12 = function() -- 2919
	local _val_0 = App.platform -- 2919
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2919
end -- 2919
local getServerStatus -- 2905
getServerStatus = function() -- 2905
	local Entry = require("Script.Dev.Entry") -- 2906
	local running = Entry.getCurrentEntryStatus() -- 2907
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 2908
	local wsConnectionCount = HttpServer.wsConnectionCount -- 2909
	return { -- 2911
		success = true, -- 2911
		platform = App.platform, -- 2912
		locale = App.locale, -- 2913
		version = App.version, -- 2914
		url = "http://localhost:8866", -- 2915
		wsConnectionCount = wsConnectionCount, -- 2916
		webIDEConnected = wsConnectionCount > 0, -- 2917
		nativeIDE = { -- 2919
			supported = _anon_func_12(), -- 2919
			state = nativeIDEState, -- 2920
			message = nativeIDEMessage -- 2921
		}, -- 2918
		typescriptCompiler = { -- 2923
			webIDEReady = webIDECompilerReady, -- 2923
			webIDEGeneration = webIDEConnectionGeneration, -- 2924
			embeddedSupported = supportsCompilerWebView(), -- 2925
			embeddedRequested = compilerRequested, -- 2926
			embeddedReady = compilerReady, -- 2927
			users = compilerUsers, -- 2928
			queuedJobs = #compilerJobs, -- 2929
			failure = compilerFailure -- 2930
		}, -- 2922
		assetPath = Content.assetPath, -- 2931
		writablePath = Content.writablePath, -- 2932
		appPath = Content.appPath, -- 2933
		waTemplateReady = waTemplateReady, -- 2934
		running = running -- 2935
	} -- 2910
end -- 2905
HttpServer:post("/status", function() -- 2938
	return getServerStatus() -- 2939
end) -- 2938
HttpServer:postSchedule("/doctor/fix", function(req) -- 2941
	do -- 2942
		local _type_0 = type(req) -- 2942
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2942
		if _tab_0 then -- 2942
			local openWebIDE -- 2942
			do -- 2942
				local _obj_0 = req.body -- 2942
				local _type_1 = type(_obj_0) -- 2942
				if "table" == _type_1 or "userdata" == _type_1 then -- 2942
					openWebIDE = _obj_0.openWebIDE -- 2942
				end -- 2942
			end -- 2942
			if openWebIDE ~= nil then -- 2942
				if not openWebIDE then -- 2943
					return { -- 2944
						success = false, -- 2944
						message = "nothing to fix" -- 2944
					} -- 2944
				end -- 2943
				local status = getServerStatus() -- 2945
				if status.webIDEConnected then -- 2946
					return { -- 2947
						success = true, -- 2947
						fixed = false, -- 2947
						message = "Web IDE already connected.", -- 2947
						status = status -- 2947
					} -- 2947
				end -- 2946
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 2948
				if waitSeconds > 0 then -- 2949
					local deadline = os.time() + waitSeconds -- 2950
					repeat -- 2951
						sleep(0.2) -- 2952
						status = getServerStatus() -- 2953
						if status.webIDEConnected then -- 2954
							return { -- 2955
								success = true, -- 2955
								fixed = false, -- 2955
								reconnected = true, -- 2955
								message = "Web IDE reconnected.", -- 2955
								status = status -- 2955
							} -- 2955
						end -- 2954
					until os.time() >= deadline -- 2951
				end -- 2949
				if not isDesktopPlatform() then -- 2957
					return { -- 2958
						success = false, -- 2958
						message = "opening Web IDE is only supported on desktop platforms", -- 2958
						status = status -- 2958
					} -- 2958
				end -- 2957
				local url = "http://localhost:8866" -- 2959
				App:openURL(url) -- 2960
				status.openedURL = url -- 2961
				return { -- 2962
					success = true, -- 2962
					fixed = true, -- 2962
					message = "Opened Web IDE in the local browser.", -- 2962
					url = url, -- 2962
					status = status -- 2962
				} -- 2962
			end -- 2942
		end -- 2942
	end -- 2942
	return { -- 2941
		success = false, -- 2941
		message = "invalid call" -- 2941
	} -- 2941
end) -- 2941
local status = { } -- 2964
_module_0 = status -- 2965
status.transpileTSFile = transpileTSFile -- 2967
status.buildAsync = function(path) -- 2969
	if not Content:exist(path) then -- 2970
		return { -- 2971
			success = false, -- 2971
			file = path, -- 2971
			message = "file not existed" -- 2971
		} -- 2971
	end -- 2970
	do -- 2972
		local _exp_0 = Path:getExt(path) -- 2972
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2972
			if '' == Path:getExt(Path:getName(path)) then -- 2973
				local content = Content:loadAsync(path) -- 2974
				if content then -- 2974
					local resultCodes, err = compileFileAsync(path, content) -- 2975
					if resultCodes then -- 2975
						return { -- 2976
							success = true, -- 2976
							file = path -- 2976
						} -- 2976
					else -- 2978
						return { -- 2978
							success = false, -- 2978
							file = path, -- 2978
							message = err -- 2978
						} -- 2978
					end -- 2975
				end -- 2974
			end -- 2973
		elseif "lua" == _exp_0 then -- 2979
			local content = Content:loadAsync(path) -- 2980
			if content then -- 2980
				do -- 2981
					local isTIC80 = CheckTIC80Code(content) -- 2981
					if isTIC80 then -- 2981
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2982
					end -- 2981
				end -- 2981
				local success, info -- 2983
				do -- 2983
					local _obj_0 = luaCheck(path, content) -- 2983
					success, info = _obj_0.success, _obj_0.info -- 2983
				end -- 2983
				if success then -- 2984
					return { -- 2985
						success = true, -- 2985
						file = path -- 2985
					} -- 2985
				elseif info and #info > 0 then -- 2986
					local messages = { } -- 2987
					for _index_0 = 1, #info do -- 2988
						local _des_0 = info[_index_0] -- 2988
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 2988
						local lineText = "" -- 2989
						if line then -- 2990
							local currentLine = 1 -- 2991
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 2992
								if currentLine == line then -- 2993
									lineText = text -- 2994
									break -- 2995
								end -- 2993
								currentLine = currentLine + 1 -- 2996
							end -- 2992
						end -- 2990
						if line then -- 2997
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 2998
						else -- 3000
							messages[#messages + 1] = message -- 3000
						end -- 2997
					end -- 2988
					return { -- 3001
						success = false, -- 3001
						file = path, -- 3001
						message = table.concat(messages, "\n") -- 3001
					} -- 3001
				else -- 3003
					return { -- 3003
						success = false, -- 3003
						file = path, -- 3003
						message = "lua check failed" -- 3003
					} -- 3003
				end -- 2984
			end -- 2980
		elseif "yarn" == _exp_0 then -- 3004
			local content = Content:loadAsync(path) -- 3005
			if content then -- 3005
				local res, _, err = yarncompile(content, true) -- 3006
				if res then -- 3006
					return { -- 3007
						success = true, -- 3007
						file = path -- 3007
					} -- 3007
				else -- 3009
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3009
					local lineText = "" -- 3010
					if line then -- 3011
						local currentLine = 1 -- 3012
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3013
							if currentLine == line then -- 3014
								lineText = text -- 3015
								break -- 3016
							end -- 3014
							currentLine = currentLine + 1 -- 3017
						end -- 3013
					end -- 3011
					if node ~= "" then -- 3018
						node = "node: " .. tostring(node) .. ", " -- 3019
					else -- 3020
						node = "" -- 3020
					end -- 3018
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3021
					return { -- 3022
						success = false, -- 3022
						file = path, -- 3022
						message = message -- 3022
					} -- 3022
				end -- 3006
			end -- 3005
		end -- 2972
	end -- 2972
	return { -- 3023
		success = false, -- 3023
		file = path, -- 3023
		message = "invalid file to build" -- 3023
	} -- 3023
end -- 2969
HttpServer:postSchedule("/git/commit-files", function(req) -- 3025
	do -- 3026
		local _type_0 = type(req) -- 3026
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3026
		if _tab_0 then -- 3026
			local body = req.body -- 3026
			if body ~= nil then -- 3026
				local repoPath, commit = body.repoPath, body.commit -- 3027
				if gitInvalidRepoPath(repoPath) then -- 3028
					return { -- 3028
						success = false, -- 3028
						message = "invalid repoPath" -- 3028
					} -- 3028
				end -- 3028
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3029
					return { -- 3029
						success = false, -- 3029
						message = "invalid commit" -- 3029
					} -- 3029
				end -- 3029
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3030
				if not res.success then -- 3031
					return res -- 3031
				end -- 3031
				return { -- 3032
					success = true, -- 3032
					status = res.status, -- 3032
					data = res.status and res.status.data -- 3032
				} -- 3032
			end -- 3026
		end -- 3026
	end -- 3026
	return invalidArguments -- 3025
end) -- 3025
thread(function() -- 3034
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3035
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3036
	if Content:exist(doraWeb) then -- 3037
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3038
		local heavyAssetsContent -- 3039
		if Content:exist(heavyAssets) then -- 3039
			heavyAssetsContent = Content:load(heavyAssets) -- 3039
		else -- 3039
			heavyAssetsContent = "" -- 3039
		end -- 3039
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3040
		local runtimeIndexContent -- 3041
		if Content:exist(runtimeIndex) then -- 3041
			runtimeIndexContent = Content:load(runtimeIndex) -- 3041
		else -- 3041
			runtimeIndexContent = "" -- 3041
		end -- 3041
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3042
		local compilerIndexContent -- 3043
		if Content:exist(compilerIndex) then -- 3043
			compilerIndexContent = Content:load(compilerIndex) -- 3043
		else -- 3043
			compilerIndexContent = "" -- 3043
		end -- 3043
		local readyContent = App.version .. "\n" .. Content:load(doraWeb) .. "\n" .. heavyAssetsContent .. "\n" .. runtimeIndexContent .. "\n" .. compilerIndexContent -- 3044
		local needReload -- 3045
		if Content:exist(doraReady) then -- 3045
			needReload = readyContent ~= Content:load(doraReady) -- 3046
		else -- 3047
			needReload = true -- 3047
		end -- 3045
		if needReload then -- 3048
			Content:remove(Path(Content.appPath, ".www")) -- 3049
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3050
			Content:save(doraReady, readyContent) -- 3054
			print("Dora Dora is ready!") -- 3055
		end -- 3048
	end -- 3037
	if App.platform == "Emscripten" then -- 3056
		status.url = nil -- 3057
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3058
	end -- 3056
	HttpServer:clearStaticCacheControls() -- 3059
	HttpServer:setStaticCacheControl("no-cache") -- 3060
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3061
	if HttpServer:start(8866) then -- 3065
		local localIP = HttpServer.localIP -- 3066
		if localIP == "" then -- 3067
			localIP = "localhost" -- 3067
		end -- 3067
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3068
		return HttpServer:startWS(8868) -- 3069
	else -- 3071
		status.url = nil -- 3071
		return print("8866 Port not available!") -- 3072
	end -- 3065
end) -- 3034
return _module_0 -- 1
