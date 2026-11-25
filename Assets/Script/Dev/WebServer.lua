-- [yue]: Script/Dev/WebServer.yue
-- [yue]: Assets/Script/Dev/WebServer.yue
local _module_0 = nil -- 1
local _ENV = Dora -- 9
local require <const> = require -- 10
local HttpServer <const> = HttpServer -- 10
local Path <const> = Path -- 10
local Content <const> = Content -- 10
local table <const> = table -- 10
local string <const> = string -- 10
local math <const> = math -- 10
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
local _compilerRuntimeModules <const> = _compilerRuntimeModules -- 10
local _loveCompilerModules <const> = _loveCompilerModules -- 10
local Node <const> = Node -- 10
local Director <const> = Director -- 10
local next <const> = next -- 10
local Log <const> = Log -- 10
local yarncompile <const> = yarncompile -- 10
local once <const> = once -- 10
local ProjectSearch = require("ProjectSearch") -- 11
HttpServer:stop() -- 13
HttpServer.wwwPath = Path(Content.appPath, ".www") -- 15
HttpServer.authToken = "" -- 17
local authFailedCount = 0 -- 19
local authLockedUntil = 0.0 -- 20
local PendingTTL = 60 -- 22
local _anon_func_0 = function() -- 24
	local _accum_0 = { } -- 24
	local _len_0 = 1 -- 24
	for _ = 1, 4 do -- 24
		_accum_0[_len_0] = string.format("%08x", math.random(0, 0x7fffffff)) -- 25
		_len_0 = _len_0 + 1 -- 25
	end -- 24
	return _accum_0 -- 24
end -- 24
local genAuthToken -- 24
genAuthToken = function() -- 24
	return table.concat(_anon_func_0()) -- 24
end -- 24
local _anon_func_1 = function() -- 27
	local _accum_0 = { } -- 27
	local _len_0 = 1 -- 27
	for _ = 1, 2 do -- 27
		_accum_0[_len_0] = string.format("%08x", math.random(0, 0x7fffffff)) -- 28
		_len_0 = _len_0 + 1 -- 28
	end -- 27
	return _accum_0 -- 27
end -- 27
local genSessionId -- 27
genSessionId = function() -- 27
	return table.concat(_anon_func_1()) -- 27
end -- 27
local genConfirmCode -- 30
genConfirmCode = function() -- 30
	return string.format("%04d", math.random(0, 9999)) -- 30
end -- 30
HttpServer:post("/auth", function(req) -- 32
	local Entry = require("Script.Dev.Entry") -- 33
	local AuthSession = Entry.AuthSession -- 34
	local authCode = Entry.getAuthCode() -- 35
	local now = os.time() -- 36
	if now < authLockedUntil then -- 37
		return { -- 38
			success = false, -- 38
			message = "locked", -- 38
			retryAfter = authLockedUntil - now -- 38
		} -- 38
	end -- 37
	local code = nil -- 39
	do -- 41
		local _type_0 = type(req) -- 41
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 41
		if _tab_0 then -- 41
			do -- 41
				local _obj_0 = req.body -- 41
				local _type_1 = type(_obj_0) -- 41
				if "table" == _type_1 or "userdata" == _type_1 then -- 41
					code = _obj_0.code -- 41
				end -- 41
			end -- 41
			if code ~= nil then -- 41
				code = code -- 42
			end -- 41
		end -- 40
	end -- 40
	if code and tostring(code) == authCode then -- 43
		authFailedCount = 0 -- 44
		Entry.invalidateAuthCode() -- 45
		do -- 46
			local pending = AuthSession.getPending() -- 46
			if pending then -- 46
				if now < pending.expiresAt and not pending.approved then -- 47
					return { -- 48
						success = true, -- 48
						pending = true, -- 48
						sessionId = pending.sessionId, -- 48
						confirmCode = pending.confirmCode, -- 48
						expiresIn = pending.expiresAt - now -- 48
					} -- 48
				end -- 47
			end -- 46
		end -- 46
		local sessionId = genSessionId() -- 49
		local confirmCode = genConfirmCode() -- 50
		AuthSession.beginPending(sessionId, confirmCode, now + PendingTTL, PendingTTL) -- 51
		return { -- 52
			success = true, -- 52
			pending = true, -- 52
			sessionId = sessionId, -- 52
			confirmCode = confirmCode, -- 52
			expiresIn = PendingTTL -- 52
		} -- 52
	else -- 54
		authFailedCount = authFailedCount + 1 -- 54
		if authFailedCount >= 3 then -- 55
			authFailedCount = 0 -- 56
			authLockedUntil = now + 30 -- 57
			return { -- 58
				success = false, -- 58
				message = "locked", -- 58
				retryAfter = 30 -- 58
			} -- 58
		end -- 55
		return { -- 59
			success = false, -- 59
			message = "invalid code" -- 59
		} -- 59
	end -- 43
end) -- 32
HttpServer:post("/auth/confirm", function(req) -- 61
	local now = os.time() -- 62
	local sessionId = nil -- 63
	do -- 65
		local _type_0 = type(req) -- 65
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 65
		if _tab_0 then -- 65
			do -- 65
				local _obj_0 = req.body -- 65
				local _type_1 = type(_obj_0) -- 65
				if "table" == _type_1 or "userdata" == _type_1 then -- 65
					sessionId = _obj_0.sessionId -- 65
				end -- 65
			end -- 65
			if sessionId ~= nil then -- 65
				sessionId = sessionId -- 66
			end -- 65
		end -- 64
	end -- 64
	if not sessionId then -- 67
		return { -- 68
			success = false, -- 68
			message = "invalid session" -- 68
		} -- 68
	end -- 67
	local Entry = require("Script.Dev.Entry") -- 69
	local AuthSession = Entry.AuthSession -- 70
	do -- 71
		local pending = AuthSession.getPending() -- 71
		if pending then -- 71
			if pending.sessionId ~= sessionId then -- 72
				return { -- 73
					success = false, -- 73
					message = "invalid session" -- 73
				} -- 73
			end -- 72
			if now >= pending.expiresAt then -- 74
				AuthSession.clearPending() -- 75
				return { -- 76
					success = false, -- 76
					message = "expired" -- 76
				} -- 76
			end -- 74
			if pending.approved then -- 77
				local secret = genAuthToken() -- 78
				HttpServer.authToken = tostring(sessionId) .. ":" .. tostring(secret) -- 79
				AuthSession.setSession(sessionId, secret) -- 80
				AuthSession.clearPending() -- 81
				return { -- 82
					success = true, -- 82
					sessionId = sessionId, -- 82
					sessionSecret = secret -- 82
				} -- 82
			end -- 77
			return { -- 83
				success = false, -- 83
				message = "pending", -- 83
				retryAfter = 2 -- 83
			} -- 83
		end -- 71
	end -- 71
	return { -- 84
		success = false, -- 84
		message = "invalid session" -- 84
	} -- 84
end) -- 61
local LintYueGlobals, CheckTIC80Code -- 86
do -- 86
	local _obj_0 = require("Utils") -- 86
	LintYueGlobals, CheckTIC80Code = _obj_0.LintYueGlobals, _obj_0.CheckTIC80Code -- 86
end -- 86
local getProjectDirFromFile -- 88
getProjectDirFromFile = function(file) -- 88
	local writablePath, assetPath = Content.writablePath, Content.assetPath -- 89
	local parent, current -- 90
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 90
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 91
	elseif (".." ~= Path:getRelative(file, assetPath):sub(1, 2)) and assetPath == file:sub(1, #assetPath) then -- 92
		local dir = Path(assetPath, "Script") -- 93
		parent, current = dir, Path:getRelative(file, dir) -- 94
	else -- 96
		parent, current = nil, nil -- 96
	end -- 90
	if not current then -- 97
		return nil -- 97
	end -- 97
	repeat -- 98
		current = Path:getPath(current) -- 99
		if current == "" then -- 100
			break -- 100
		end -- 100
		local _list_0 = Content:getFiles(Path(parent, current)) -- 101
		for _index_0 = 1, #_list_0 do -- 101
			local f = _list_0[_index_0] -- 101
			if Path:getName(f):lower() == "init" then -- 102
				return Path(parent, current, Path:getPath(f)) -- 103
			end -- 102
		end -- 101
	until false -- 98
	return nil -- 105
end -- 88
local relativeToRoot -- 107
relativeToRoot = function(file, root) -- 107
	if not (file and file ~= "" and root and root ~= "") then -- 108
		return nil -- 108
	end -- 108
	local relative = Path:getRelative(file, root) -- 109
	if relative == "" or relative == ".." or relative:sub(1, 3) == "../" or relative:sub(1, 3) == "..\\" then -- 110
		return nil -- 110
	end -- 110
	if relative == "." then -- 111
		return "" -- 111
	end -- 111
	return relative -- 112
end -- 107
local getProjectSourceRoot -- 114
getProjectSourceRoot = function(projectRoot) -- 114
	if not (projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot)) then -- 115
		return nil -- 115
	end -- 115
	return projectRoot -- 116
end -- 114
local isProjectRootDir -- 118
isProjectRootDir = function(dir) -- 118
	if not (dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir)) then -- 119
		return false -- 119
	end -- 119
	local _list_0 = Content:getFiles(dir) -- 120
	for _index_0 = 1, #_list_0 do -- 120
		local f = _list_0[_index_0] -- 120
		if Path:getName(f):lower() == "init" then -- 121
			return true -- 122
		end -- 121
	end -- 120
	return false -- 123
end -- 118
local getProjectRootFromPath -- 125
getProjectRootFromPath = function(target, isDir) -- 125
	if isDir == nil then -- 125
		isDir = false -- 125
	end -- 125
	if not (target and target ~= "" and Content:isAbsolutePath(target)) then -- 126
		return nil, "invalid path" -- 126
	end -- 126
	if isDir then -- 127
		if target == Content.writablePath or isProjectRootDir(target) then -- 128
			return target -- 128
		end -- 128
		return getProjectDirFromFile(Path(target, "__dora_project_root_search__.lua"), "current directory does not belong to any project") -- 129
	end -- 127
	return getProjectDirFromFile(target, "current file does not belong to any project") -- 130
end -- 125
local invalidArguments = { -- 132
	success = false, -- 132
	message = "invalid arguments" -- 132
} -- 132
local nativeExportFormat -- 133
HttpServer:post("/agent/project-root", function(req) -- 134
	do -- 135
		local _type_0 = type(req) -- 135
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 135
		if _tab_0 then -- 135
			local path -- 135
			do -- 135
				local _obj_0 = req.body -- 135
				local _type_1 = type(_obj_0) -- 135
				if "table" == _type_1 or "userdata" == _type_1 then -- 135
					path = _obj_0.path -- 135
				end -- 135
			end -- 135
			local isDir -- 135
			do -- 135
				local _obj_0 = req.body -- 135
				local _type_1 = type(_obj_0) -- 135
				if "table" == _type_1 or "userdata" == _type_1 then -- 135
					isDir = _obj_0.isDir -- 135
				end -- 135
			end -- 135
			if path ~= nil and isDir ~= nil then -- 135
				local projectRoot, err = getProjectRootFromPath(path, isDir) -- 136
				if projectRoot then -- 136
					return { -- 137
						success = true, -- 137
						found = true, -- 137
						projectRoot = projectRoot, -- 137
						title = Path:getFilename(projectRoot), -- 137
						nativeExport = nativeExportFormat(projectRoot) -- 137
					} -- 137
				else -- 139
					return { -- 139
						success = true, -- 139
						found = false, -- 139
						message = err -- 139
					} -- 139
				end -- 136
			end -- 135
		end -- 135
	end -- 135
	return invalidArguments -- 134
end) -- 134
local AgentHost = require("Script.Dev.AgentHost") -- 141
local AgentTools = AgentHost.proxy("Agent.Tools") -- 142
local AgentSession = AgentHost.proxy("Agent.Session") -- 143
local AgentStorage = AgentHost.proxy("Agent.Storage.Database") -- 144
local AgentLocalAgent = AgentHost.proxy("Agent.Runtime.LocalAgent") -- 145
local AgentVisionAssets = AgentHost.proxy("Agent.Tool.VisionAssets") -- 146
HttpServer:post("/agent/runtime/status", function() -- 148
	return AgentHost.status() -- 148
end) -- 148
HttpServer:post("/agent/runtime/reload", function() -- 149
	return AgentHost.reload() -- 149
end) -- 149
HttpServer:post("/agent/runtime/automatic", function(req) -- 150
	do -- 151
		local _type_0 = type(req) -- 151
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 151
		if _tab_0 then -- 151
			local enabled -- 151
			do -- 151
				local _obj_0 = req.body -- 151
				local _type_1 = type(_obj_0) -- 151
				if "table" == _type_1 or "userdata" == _type_1 then -- 151
					enabled = _obj_0.enabled -- 151
				end -- 151
			end -- 151
			if enabled ~= nil then -- 151
				if type(enabled) == "boolean" then -- 152
					return AgentHost.setAutomatic(enabled) -- 152
				end -- 152
			end -- 151
		end -- 151
	end -- 151
	return invalidArguments -- 150
end) -- 150
local GitJobs = { } -- 154
local gitTerminalState -- 156
gitTerminalState = function(status) -- 156
	if not (status and status.state) then -- 157
		return false -- 157
	end -- 157
	local _val_0 = status.state -- 158
	return "done" == _val_0 or "error" == _val_0 or "canceled" == _val_0 -- 158
end -- 156
local GIT_JOB_TTL = 600 -- 160
local gitPruneJobs -- 162
gitPruneJobs = function() -- 162
	local time = os.time() -- 163
	for id, job in pairs(GitJobs) do -- 164
		if gitTerminalState(job.status) and time - (job.updatedAt or time) > GIT_JOB_TTL then -- 165
			GitJobs[id] = nil -- 166
		end -- 165
	end -- 164
end -- 162
local gitInvalidRepoPath -- 168
gitInvalidRepoPath = function(repoPath) -- 168
	if not (type(repoPath) == "string" and repoPath ~= "") then -- 169
		return true -- 169
	end -- 169
	return not Git:isRepoPathAllowed(repoPath) -- 170
end -- 168
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
		elseif ch == "\\" and quote ~= "'" then -- 182
			escape = true -- 183
		elseif quote then -- 184
			if ch == quote then -- 185
				quote = nil -- 186
			else -- 188
				current[#current + 1] = ch -- 188
			end -- 185
		elseif ch == "'" or ch == '"' then -- 189
			quote = ch -- 190
		elseif ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 191
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
	local text = tostring(url):gsub("/+$", "") -- 226
	text = text:match(".*:([^/]+)$") or text -- 227
	local name = Path:getFilename(text):gsub("%.git$", "") -- 228
	if name == "" or name == "." or name == ".." then -- 229
		return nil -- 229
	end -- 229
	return name -- 230
end -- 223
local gitCloneTargetPath -- 232
gitCloneTargetPath = function(repoPath, command) -- 232
	local args = gitShellSplit(command) -- 233
	if not (args[1] == "clone") then -- 234
		return nil -- 234
	end -- 234
	local url, target = nil, nil -- 235
	local index = 2 -- 236
	while index <= #args do -- 237
		local arg = args[index] -- 238
		if ("-b" == arg or "--branch" == arg or "--depth" == arg) then -- 239
			if not args[index + 1] then -- 240
				return nil -- 240
			end -- 240
			index = index + 2 -- 241
		else -- 243
			if arg:sub(1, 1) == "-" then -- 243
				return nil -- 243
			end -- 243
			if not url then -- 244
				url = arg -- 245
			elseif not target then -- 246
				target = arg -- 247
			else -- 249
				return nil -- 249
			end -- 244
			index = index + 1 -- 250
		end -- 239
	end -- 237
	if not url then -- 251
		return nil -- 251
	end -- 251
	target = target or gitCloneDirFromURL(url) -- 252
	return gitSafeChildPath(repoPath, target) -- 253
end -- 232
local gitPathInsideRepo -- 255
gitPathInsideRepo = function(repoPath, relPath) -- 255
	if not (repoPath and relPath and relPath ~= "") then -- 256
		return false -- 256
	end -- 256
	if relPath:sub(1, 1) == "/" or relPath:match("^%a:[/\\]") then -- 257
		return false -- 257
	end -- 257
	if relPath == "." or relPath:match("^%.%.[/\\]?" or relPath:match("[/\\]%.%.[/\\]")) then -- 258
		return false -- 258
	end -- 258
	local targetPath = Path(repoPath, relPath) -- 259
	local relative = Path:getRelative(targetPath, repoPath) -- 260
	return relative ~= ".." and relative:sub(1, 3) ~= "../" and relative:sub(1, 3) ~= "..\\" -- 261
end -- 255
local gitHostFromURL -- 263
gitHostFromURL = function(url) -- 263
	if not (url and url ~= "") then -- 264
		return nil -- 264
	end -- 264
	local text = tostring(url):match("^%s*(.-)%s*$") -- 265
	if text == "" then -- 266
		return nil -- 266
	end -- 266
	local host = text:match("^[%w_%-]+://([^/:]+)") -- 267
	if not host then -- 268
		host = text:match("@([^:/]+)[:/]") -- 268
	end -- 268
	if not host then -- 269
		host = text:match("^([^:/]+):[^/]") -- 269
	end -- 269
	if not (host and host ~= "") then -- 270
		return nil -- 270
	end -- 270
	return string.lower(host) -- 271
end -- 263
local ensureGitTables -- 273
ensureGitTables = function() -- 273
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
	]]) -- 274
	DB:exec("CREATE INDEX IF NOT EXISTS idx_git_credential_host ON GitCredential(host);") -- 287
	return DB:exec([[		CREATE TABLE IF NOT EXISTS GitProfile(
			id INTEGER PRIMARY KEY CHECK(id = 1),
			name TEXT NOT NULL DEFAULT '',
			email TEXT NOT NULL DEFAULT '',
			updated_at INTEGER
		);
	]]) -- 288
end -- 273
local gitCredentialToPublic -- 297
gitCredentialToPublic = function(row) -- 297
	local id, host, label, typeName, username, createdAt, updatedAt, lastUsedAt = row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8] -- 298
	return { -- 299
		id = id, -- 299
		host = host, -- 299
		label = label, -- 299
		type = typeName, -- 299
		username = username, -- 299
		createdAt = createdAt, -- 299
		updatedAt = updatedAt, -- 299
		lastUsedAt = lastUsedAt -- 299
	} -- 299
end -- 297
local gitLoadCredential -- 301
gitLoadCredential = function(id) -- 301
	ensureGitTables() -- 302
	local credentialId = tonumber(id) or 0 -- 303
	local rows = DB:query("select id, host, label, type, username, secret from GitCredential where id = ? limit 1", { -- 304
		credentialId -- 304
	}) -- 304
	if not (rows and rows[1]) then -- 305
		return nil -- 305
	end -- 305
	local row = rows[1] -- 306
	return { -- 307
		id = row[1], -- 307
		host = row[2], -- 307
		label = row[3], -- 307
		type = row[4], -- 307
		username = row[5], -- 307
		secret = row[6] -- 307
	} -- 307
end -- 301
local gitAuthOptionsJSON -- 309
gitAuthOptionsJSON = function(credential) -- 309
	if not credential then -- 310
		return nil -- 310
	end -- 310
	local auth -- 311
	if credential.type == "token" then -- 311
		auth = { -- 313
			type = "token", -- 313
			token = credential.secret, -- 314
			username = credential.username ~= "" and credential.username or "token" -- 315
		} -- 312
	else -- 318
		auth = { -- 319
			type = "basic", -- 319
			username = credential.username, -- 320
			password = credential.secret -- 321
		} -- 318
	end -- 311
	return json.encode({ -- 323
		auth = auth -- 323
	}) -- 323
end -- 309
local gitLoadProfile -- 325
gitLoadProfile = function() -- 325
	ensureGitTables() -- 326
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 327
	if not (rows and rows[1]) then -- 328
		return nil -- 328
	end -- 328
	local name = tostring(rows[1][1] or "") -- 329
	local email = tostring(rows[1][2] or "") -- 330
	if name == "" and email == "" then -- 331
		return nil -- 331
	end -- 331
	return { -- 332
		name = name, -- 332
		email = email -- 332
	} -- 332
end -- 325
local _anon_func_2 = function(args, gitQuote) -- 351
	local _accum_0 = { } -- 351
	local _len_0 = 1 -- 351
	for _index_0 = 1, #args do -- 351
		local arg = args[_index_0] -- 351
		_accum_0[_len_0] = gitQuote(arg) -- 351
		_len_0 = _len_0 + 1 -- 351
	end -- 351
	return _accum_0 -- 351
end -- 351
local gitApplyProfileToCommit -- 334
gitApplyProfileToCommit = function(command) -- 334
	local args = gitShellSplit(command) -- 335
	if not (args[1] == "commit") then -- 336
		return command -- 336
	end -- 336
	local hasName = false -- 337
	local hasEmail = false -- 338
	for _index_0 = 1, #args do -- 339
		local arg = args[_index_0] -- 339
		if arg == "--author-name" then -- 340
			hasName = true -- 340
		end -- 340
		if arg == "--author-email" then -- 341
			hasEmail = true -- 341
		end -- 341
	end -- 339
	if hasName and hasEmail then -- 342
		return command -- 342
	end -- 342
	local profile = gitLoadProfile() -- 343
	if not profile then -- 344
		return command -- 344
	end -- 344
	if not hasName and profile.name ~= "" then -- 345
		args[#args + 1] = "--author-name" -- 346
		args[#args + 1] = profile.name -- 347
	end -- 345
	if not hasEmail and profile.email ~= "" then -- 348
		args[#args + 1] = "--author-email" -- 349
		args[#args + 1] = profile.email -- 350
	end -- 348
	return table.concat(_anon_func_2(args, gitQuote), " ") -- 351
end -- 334
local gitStartJob -- 353
gitStartJob = function(repoPath, command, optionsJSON) -- 353
	if optionsJSON == nil then -- 353
		optionsJSON = nil -- 353
	end -- 353
	gitPruneJobs() -- 354
	if gitInvalidRepoPath(repoPath) then -- 355
		return nil, "invalid repoPath" -- 355
	end -- 355
	if not (command and command ~= "") then -- 356
		return nil, "invalid command" -- 356
	end -- 356
	if not optionsJSON then -- 357
		optionsJSON = "" -- 357
	end -- 357
	command = gitApplyProfileToCommit(command) -- 358
	do -- 359
		local targetPath = gitCloneTargetPath(repoPath, command) -- 359
		if targetPath then -- 359
			if gitInvalidRepoPath(targetPath) then -- 360
				return nil, "invalid clone target" -- 360
			end -- 360
			if gitDirNonEmpty(targetPath) then -- 361
				return nil, "clone target directory is not empty" -- 362
			end -- 361
		elseif (gitShellSplit(command))[1] == "clone" then -- 363
			return nil, "invalid clone target" -- 364
		end -- 359
	end -- 359
	local statusRef = nil -- 365
	local startGit -- 366
	startGit = function() -- 366
		return Git:run(repoPath, command, (function(status) -- 367
			statusRef = status -- 368
			GitJobs[status.id] = { -- 370
				command = command, -- 370
				status = status, -- 371
				updatedAt = os.time() -- 372
			} -- 369
		end), optionsJSON) -- 367
	end -- 366
	local success, jobId = pcall(startGit) -- 374
	if not success then -- 375
		return nil, tostring(jobId) -- 375
	end -- 375
	if not jobId then -- 376
		return nil, "Git.run did not return a job id" -- 376
	end -- 376
	GitJobs[jobId] = { -- 378
		command = command, -- 378
		status = statusRef or { -- 380
			id = jobId, -- 380
			state = "queued", -- 381
			kind = gitShellSplit(command)[1] or "status", -- 382
			repoPath = repoPath, -- 383
			progress = 0, -- 384
			message = "queued" -- 385
		}, -- 379
		updatedAt = os.time() -- 387
	} -- 377
	return jobId -- 388
end -- 353
local gitRunSync -- 390
gitRunSync = function(repoPath, command, optionsJSON, timeout) -- 390
	if optionsJSON == nil then -- 390
		optionsJSON = nil -- 390
	end -- 390
	if timeout == nil then -- 390
		timeout = 20 -- 390
	end -- 390
	local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 391
	if not jobId then -- 392
		return { -- 392
			success = false, -- 392
			message = err -- 392
		} -- 392
	end -- 392
	local startedAt = os.time() -- 393
	wait(function() -- 394
		local job = GitJobs[jobId] -- 395
		local status = job and job.status -- 396
		return gitTerminalState(status) or os.time() - startedAt >= timeout -- 397
	end) -- 394
	local status = GitJobs[jobId] and GitJobs[jobId].status -- 398
	if not gitTerminalState(status) then -- 399
		Git:cancel(jobId) -- 400
		return { -- 401
			success = false, -- 401
			message = "git command timed out", -- 401
			jobId = jobId, -- 401
			status = status -- 401
		} -- 401
	end -- 399
	return { -- 402
		success = status.state == "done", -- 402
		jobId = jobId, -- 402
		status = status, -- 402
		message = status.error or status.message -- 402
	} -- 402
end -- 390
local gitCredentialsForHost -- 404
gitCredentialsForHost = function(host) -- 404
	if not (host and host ~= "") then -- 405
		return { } -- 405
	end -- 405
	ensureGitTables() -- 406
	local rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by last_used_at desc, label asc, id asc", { -- 407
		host -- 407
	}) -- 407
	if rows then -- 408
		local _accum_0 = { } -- 409
		local _len_0 = 1 -- 409
		for _index_0 = 1, #rows do -- 409
			local row = rows[_index_0] -- 409
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 409
			_len_0 = _len_0 + 1 -- 409
		end -- 409
		return _accum_0 -- 409
	else -- 410
		return { } -- 410
	end -- 408
end -- 404
local gitFirstRemoteURL -- 412
gitFirstRemoteURL = function(repoPath, remoteName) -- 412
	if remoteName == nil then -- 412
		remoteName = nil -- 412
	end -- 412
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 10) -- 413
	local data = remoteRes.status and remoteRes.status.data -- 414
	if not (data and data.remotes) then -- 415
		return nil -- 415
	end -- 415
	local _list_0 = data.remotes -- 416
	for _index_0 = 1, #_list_0 do -- 416
		local remote = _list_0[_index_0] -- 416
		if (not remoteName or remote.name == remoteName) and remote.urls and remote.urls[1] then -- 417
			return remote.urls[1] -- 418
		end -- 417
	end -- 416
	return nil -- 419
end -- 412
local gitConfigRemoteURL -- 421
gitConfigRemoteURL = function(repoPath, remoteName) -- 421
	if remoteName == nil then -- 421
		remoteName = nil -- 421
	end -- 421
	if gitInvalidRepoPath(repoPath) then -- 422
		return nil -- 422
	end -- 422
	local configPath = Path(repoPath, ".git/config") -- 423
	if not Content:exist(configPath) then -- 424
		return nil -- 424
	end -- 424
	local content = Content:load(configPath) -- 425
	if not (content and content ~= "") then -- 426
		return nil -- 426
	end -- 426
	local currentRemote = nil -- 427
	for line in content:gmatch("[^\r\n]+") do -- 428
		local sectionRemote = line:match('^%s*%[remote%s+"([^"]+)"%]%s*$') -- 429
		if sectionRemote then -- 430
			currentRemote = sectionRemote -- 431
		elseif currentRemote and (not remoteName or currentRemote == remoteName) then -- 432
			local url = line:match("^%s*url%s*=%s*(.-)%s*$") -- 433
			if url and url ~= "" then -- 434
				return url -- 434
			end -- 434
		end -- 430
	end -- 428
	return nil -- 435
end -- 421
local gitCommandRemoteArg -- 437
gitCommandRemoteArg = function(args, startIndex) -- 437
	if startIndex == nil then -- 437
		startIndex = 2 -- 437
	end -- 437
	local index = startIndex -- 438
	while index <= #args do -- 439
		local arg = args[index] -- 440
		if ("-u" == arg or "--set-upstream" == arg or "-f" == arg or "--force" == arg or "--all" == arg or "--prune" == arg) then -- 441
			index = index + 1 -- 442
		elseif ("--depth" == arg or "-b" == arg or "--branch" == arg) then -- 443
			index = index + 2 -- 444
		elseif arg and arg:sub(1, 1) == "-" then -- 445
			index = index + 1 -- 446
		else -- 448
			return arg -- 448
		end -- 441
	end -- 439
	return nil -- 449
end -- 437
local gitCommandHost -- 451
gitCommandHost = function(repoPath, command) -- 451
	local args = gitShellSplit(command) -- 452
	if not args[1] then -- 453
		return nil -- 453
	end -- 453
	do -- 454
		local _exp_0 = args[1] -- 454
		if "clone" == _exp_0 or "ls-remote" == _exp_0 then -- 455
			return gitHostFromURL(args[2]) -- 456
		elseif "fetch" == _exp_0 or "pull" == _exp_0 or "push" == _exp_0 then -- 457
			local remoteArg = gitCommandRemoteArg(args, 2) -- 458
			if not remoteArg then -- 459
				return nil -- 459
			end -- 459
			local url = gitHostFromURL(remoteArg) -- 460
			if url then -- 461
				return url -- 461
			end -- 461
			return gitHostFromURL(gitConfigRemoteURL(repoPath, remoteArg)) -- 462
		end -- 454
	end -- 454
	return nil -- 463
end -- 451
local gitAuthSelectionForCommand -- 465
gitAuthSelectionForCommand = function(repoPath, command) -- 465
	local host = gitCommandHost(repoPath, command) -- 466
	if not host then -- 467
		return nil -- 467
	end -- 467
	local items = gitCredentialsForHost(host) -- 468
	if #items == 0 then -- 469
		return nil -- 469
	end -- 469
	return { -- 470
		host = host, -- 470
		items = items -- 470
	} -- 470
end -- 465
local gitDefaultRemote -- 472
gitDefaultRemote = function(remoteStatus) -- 472
	local data = remoteStatus and remoteStatus.data -- 473
	if not (data and data.remotes and data.remotes[1]) then -- 474
		return nil -- 474
	end -- 474
	return data.remotes[1] -- 475
end -- 472
local gitCurrentBranch -- 477
gitCurrentBranch = function(branchStatus) -- 477
	local data = branchStatus and branchStatus.data -- 478
	if data and data.current and data.current ~= "" then -- 479
		return data.current -- 480
	end -- 479
	if data and data.branches then -- 481
		local _list_0 = data.branches -- 482
		for _index_0 = 1, #_list_0 do -- 482
			local branch = _list_0[_index_0] -- 482
			if branch.current then -- 483
				return branch.name -- 483
			end -- 483
		end -- 482
	end -- 481
	return nil -- 484
end -- 477
local gitHeadBranch -- 486
gitHeadBranch = function(repoPath) -- 486
	if gitInvalidRepoPath(repoPath) then -- 487
		return nil -- 487
	end -- 487
	local headPath = Path(repoPath, ".git", "HEAD") -- 488
	if not Content:exist(headPath) then -- 489
		return nil -- 489
	end -- 489
	local head = Content:load(headPath) -- 490
	if not head then -- 491
		return nil -- 491
	end -- 491
	local branch = head:match("^ref:%s*refs/heads/(.-)%s*$") -- 492
	if branch and branch ~= "" then -- 493
		return branch -- 493
	end -- 493
	return nil -- 494
end -- 486
local gitBranchesWithHead -- 496
gitBranchesWithHead = function(branchStatus, currentBranch) -- 496
	local branches = branchStatus and branchStatus.data and branchStatus.data.branches or { } -- 497
	if not (currentBranch and currentBranch ~= "") then -- 498
		return branches -- 498
	end -- 498
	for _index_0 = 1, #branches do -- 499
		local branch = branches[_index_0] -- 499
		if branch.name == currentBranch then -- 500
			return branches -- 500
		end -- 500
	end -- 499
	local withHead -- 501
	do -- 501
		local _accum_0 = { } -- 501
		local _len_0 = 1 -- 501
		for _index_0 = 1, #branches do -- 501
			local branch = branches[_index_0] -- 501
			_accum_0[_len_0] = branch -- 501
			_len_0 = _len_0 + 1 -- 501
		end -- 501
		withHead = _accum_0 -- 501
	end -- 501
	withHead[#withHead + 1] = { -- 502
		name = currentBranch, -- 502
		current = true, -- 502
		unborn = true -- 502
	} -- 502
	return withHead -- 503
end -- 496
local gitStatusMeansNotRepo -- 505
gitStatusMeansNotRepo = function(statusRes) -- 505
	local message = statusRes and (statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message)) or "" -- 506
	message = tostring(message):lower() -- 507
	return message:find("repository does not exist", 1, true) or message:find("not a git repository", 1, true) -- 508
end -- 505
local gitSummary -- 510
gitSummary = function(repoPath) -- 510
	local statusRes = gitRunSync(repoPath, "status", nil, 120) -- 511
	if not statusRes.success then -- 512
		if gitStatusMeansNotRepo(statusRes) then -- 513
			return { -- 514
				success = true, -- 514
				isRepo = false, -- 514
				message = statusRes.message, -- 514
				status = statusRes.status -- 514
			} -- 514
		end -- 513
		return { -- 515
			success = false, -- 515
			message = statusRes.message or statusRes.status and (statusRes.status.error or statusRes.status.message) or "failed to check Git repository", -- 515
			status = statusRes.status -- 515
		} -- 515
	end -- 512
	local branchRes = gitRunSync(repoPath, "branch", nil, 120) -- 516
	local remoteRes = gitRunSync(repoPath, "remote -v", nil, 120) -- 517
	local status = statusRes.status -- 518
	local branchStatus = branchRes.status -- 519
	local remoteStatus = remoteRes.status -- 520
	local currentBranch = gitCurrentBranch(branchStatus) or gitHeadBranch(repoPath) -- 521
	local branches = gitBranchesWithHead(branchStatus, currentBranch) -- 522
	local logRes = gitRunSync(repoPath, "log --metadata-only -n 100", nil, 120) -- 523
	local logStatus -- 524
	if logRes.success then -- 524
		logStatus = logRes.status -- 525
	else -- 527
		logStatus = { -- 528
			state = "done", -- 528
			kind = "log", -- 529
			repoPath = repoPath, -- 530
			progress = 1, -- 531
			message = "git log completed", -- 532
			data = { -- 533
				commits = { } -- 533
			} -- 533
		} -- 527
	end -- 524
	local hasCommit = logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] ~= nil -- 535
	local tagStatus -- 536
	if hasCommit then -- 536
		tagStatus = (gitRunSync(repoPath, "tag", nil, 120)).status -- 537
	else -- 539
		tagStatus = { -- 540
			state = "done", -- 540
			kind = "tag", -- 541
			repoPath = repoPath, -- 542
			progress = 1, -- 543
			message = "git tag completed", -- 544
			data = { -- 545
				tags = { } -- 545
			} -- 545
		} -- 539
	end -- 536
	local defaultRemote = gitDefaultRemote(remoteStatus) -- 547
	local lastCommit = nil -- 548
	if logStatus and logStatus.data and logStatus.data.commits and logStatus.data.commits[1] then -- 549
		lastCommit = logStatus.data.commits[1] -- 550
	end -- 549
	return { -- 552
		success = true, -- 552
		isRepo = true, -- 553
		clean = status.data and status.data.clean or false, -- 554
		currentBranch = currentBranch, -- 555
		defaultRemote = defaultRemote, -- 556
		remotes = remoteStatus and remoteStatus.data and remoteStatus.data.remotes or { }, -- 557
		branches = branches, -- 558
		lastCommit = lastCommit, -- 559
		status = status, -- 560
		branchStatus = branchStatus, -- 561
		remoteStatus = remoteStatus, -- 562
		historyStatus = logStatus, -- 563
		tagStatus = tagStatus -- 564
	} -- 551
end -- 510
HttpServer:post("/git/run", function(req) -- 566
	do -- 567
		local _type_0 = type(req) -- 567
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 567
		if _tab_0 then -- 567
			local body = req.body -- 567
			if body ~= nil then -- 567
				local repoPath, command, authId, optionsJSON = body.repoPath, body.command, body.authId, body.optionsJSON -- 568
				if authId and not optionsJSON then -- 569
					local credential = gitLoadCredential(authId) -- 570
					if credential then -- 570
						optionsJSON = gitAuthOptionsJSON(credential) -- 571
						DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 572
							os.time(), -- 572
							credential.id -- 572
						}) -- 572
					end -- 570
				elseif not optionsJSON then -- 573
					local authOk, authSelection = pcall(gitAuthSelectionForCommand, repoPath, command) -- 574
					if not authOk then -- 575
						authSelection = nil -- 575
					end -- 575
					if authSelection then -- 576
						if #authSelection.items == 1 then -- 577
							local credential = gitLoadCredential(authSelection.items[1].id) -- 578
							optionsJSON = gitAuthOptionsJSON(credential) -- 579
							DB:exec("update GitCredential set last_used_at = ? where id = ?", { -- 580
								os.time(), -- 580
								credential.id -- 580
							}) -- 580
						else -- 582
							return { -- 582
								success = false, -- 582
								message = "select a Git credential", -- 582
								needsCredentialSelection = true, -- 582
								host = authSelection.host, -- 582
								credentials = authSelection.items -- 582
							} -- 582
						end -- 577
					end -- 576
				end -- 569
				local jobId, err = gitStartJob(repoPath, command, optionsJSON) -- 583
				if not jobId then -- 584
					return { -- 584
						success = false, -- 584
						message = err -- 584
					} -- 584
				end -- 584
				return { -- 585
					success = true, -- 585
					jobId = jobId -- 585
				} -- 585
			end -- 567
		end -- 567
	end -- 567
	return invalidArguments -- 566
end) -- 566
HttpServer:post("/git/status", function(req) -- 587
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
				local job = GitJobs[tonumber(jobId) or 0] -- 589
				if not job then -- 590
					return { -- 590
						success = false, -- 590
						message = "git job not found" -- 590
					} -- 590
				end -- 590
				return { -- 591
					success = true, -- 591
					status = job.status, -- 591
					command = job.command -- 591
				} -- 591
			end -- 588
		end -- 588
	end -- 588
	return invalidArguments -- 587
end) -- 587
HttpServer:post("/git/cancel", function(req) -- 593
	do -- 594
		local _type_0 = type(req) -- 594
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 594
		if _tab_0 then -- 594
			local jobId -- 594
			do -- 594
				local _obj_0 = req.body -- 594
				local _type_1 = type(_obj_0) -- 594
				if "table" == _type_1 or "userdata" == _type_1 then -- 594
					jobId = _obj_0.jobId -- 594
				end -- 594
			end -- 594
			if jobId ~= nil then -- 594
				local id = tonumber(jobId) -- 595
				if not id then -- 596
					return { -- 596
						success = false, -- 596
						message = "invalid jobId" -- 596
					} -- 596
				end -- 596
				return { -- 597
					success = Git:cancel(id) -- 597
				} -- 597
			end -- 594
		end -- 594
	end -- 594
	return invalidArguments -- 593
end) -- 593
HttpServer:postSchedule("/git/summary", function(req) -- 599
	do -- 600
		local _type_0 = type(req) -- 600
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 600
		if _tab_0 then -- 600
			local repoPath -- 600
			do -- 600
				local _obj_0 = req.body -- 600
				local _type_1 = type(_obj_0) -- 600
				if "table" == _type_1 or "userdata" == _type_1 then -- 600
					repoPath = _obj_0.repoPath -- 600
				end -- 600
			end -- 600
			if repoPath ~= nil then -- 600
				if gitInvalidRepoPath(repoPath) then -- 601
					return { -- 601
						success = false, -- 601
						message = "invalid repoPath" -- 601
					} -- 601
				end -- 601
				return gitSummary(repoPath) -- 602
			end -- 600
		end -- 600
	end -- 600
	return invalidArguments -- 599
end) -- 599
HttpServer:postSchedule("/git/status-files", function(req) -- 604
	do -- 605
		local _type_0 = type(req) -- 605
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 605
		if _tab_0 then -- 605
			local repoPath -- 605
			do -- 605
				local _obj_0 = req.body -- 605
				local _type_1 = type(_obj_0) -- 605
				if "table" == _type_1 or "userdata" == _type_1 then -- 605
					repoPath = _obj_0.repoPath -- 605
				end -- 605
			end -- 605
			if repoPath ~= nil then -- 605
				return gitRunSync(repoPath, "status", nil, 120) -- 606
			end -- 605
		end -- 605
	end -- 605
	return invalidArguments -- 604
end) -- 604
HttpServer:postSchedule("/git/discard-untracked", function(req) -- 608
	do -- 609
		local _type_0 = type(req) -- 609
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 609
		if _tab_0 then -- 609
			local body = req.body -- 609
			if body ~= nil then -- 609
				local repoPath, paths = body.repoPath, body.paths -- 610
				if gitInvalidRepoPath(repoPath) then -- 611
					return { -- 611
						success = false, -- 611
						message = "invalid repoPath" -- 611
					} -- 611
				end -- 611
				if not (type(paths) == "table") then -- 612
					return { -- 612
						success = false, -- 612
						message = "invalid paths" -- 612
					} -- 612
				end -- 612
				local statusRes = gitRunSync(repoPath, "status", nil, 10) -- 613
				if not statusRes.success then -- 614
					return statusRes -- 614
				end -- 614
				local untracked = { } -- 615
				local _list_0 = (statusRes.status.data and statusRes.status.data.files or { }) -- 616
				for _index_0 = 1, #_list_0 do -- 616
					local file = _list_0[_index_0] -- 616
					if file.staging == "?" or file.worktree == "?" then -- 617
						untracked[file.path] = true -- 618
					end -- 617
				end -- 616
				local removed = { } -- 619
				for _index_0 = 1, #paths do -- 620
					local relPath = paths[_index_0] -- 620
					relPath = tostring(relPath) -- 621
					if not gitPathInsideRepo(repoPath, relPath) then -- 622
						return { -- 622
							success = false, -- 622
							message = "unsafe path: " .. tostring(relPath) -- 622
						} -- 622
					end -- 622
					if not untracked[relPath] then -- 623
						return { -- 623
							success = false, -- 623
							message = "path is not untracked: " .. tostring(relPath) -- 623
						} -- 623
					end -- 623
				end -- 620
				for _index_0 = 1, #paths do -- 624
					local relPath = paths[_index_0] -- 624
					local targetPath = Path(repoPath, tostring(relPath)) -- 625
					if Content:exist(targetPath) then -- 626
						Content:remove(targetPath) -- 627
						removed[#removed + 1] = tostring(relPath) -- 628
					end -- 626
				end -- 624
				return { -- 629
					success = true, -- 629
					removed = removed -- 629
				} -- 629
			end -- 609
		end -- 609
	end -- 609
	return invalidArguments -- 608
end) -- 608
HttpServer:postSchedule("/git/file-diff", function(req) -- 631
	do -- 632
		local _type_0 = type(req) -- 632
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 632
		if _tab_0 then -- 632
			local body = req.body -- 632
			if body ~= nil then -- 632
				local repoPath, path, staged = body.repoPath, body.path, body.staged -- 633
				if gitInvalidRepoPath(repoPath) then -- 634
					return { -- 634
						success = false, -- 634
						message = "invalid repoPath" -- 634
					} -- 634
				end -- 634
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 635
					return { -- 635
						success = false, -- 635
						message = "unsafe path" -- 635
					} -- 635
				end -- 635
				local command -- 636
				if staged == true then -- 636
					command = "diff --staged -- " .. tostring(gitQuote(path)) -- 637
				else -- 639
					command = "diff -- " .. tostring(gitQuote(path)) -- 639
				end -- 636
				local res = gitRunSync(repoPath, command, nil, 10) -- 640
				if not res.success then -- 641
					return res -- 641
				end -- 641
				return { -- 642
					success = true, -- 642
					status = res.status, -- 642
					data = res.status and res.status.data -- 642
				} -- 642
			end -- 632
		end -- 632
	end -- 632
	return invalidArguments -- 631
end) -- 631
HttpServer:postSchedule("/git/commit-file-diff", function(req) -- 644
	do -- 645
		local _type_0 = type(req) -- 645
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 645
		if _tab_0 then -- 645
			local body = req.body -- 645
			if body ~= nil then -- 645
				local repoPath, commit, path = body.repoPath, body.commit, body.path -- 646
				if gitInvalidRepoPath(repoPath) then -- 647
					return { -- 647
						success = false, -- 647
						message = "invalid repoPath" -- 647
					} -- 647
				end -- 647
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 648
					return { -- 648
						success = false, -- 648
						message = "invalid commit" -- 648
					} -- 648
				end -- 648
				if not gitPathInsideRepo(repoPath, tostring(path)) then -- 649
					return { -- 649
						success = false, -- 649
						message = "unsafe path" -- 649
					} -- 649
				end -- 649
				local res = gitRunSync(repoPath, "diff " .. tostring(gitQuote(commit)) .. " -- " .. tostring(gitQuote(path)), nil, 10) -- 650
				if not res.success then -- 651
					return res -- 651
				end -- 651
				return { -- 652
					success = true, -- 652
					status = res.status, -- 652
					data = res.status and res.status.data -- 652
				} -- 652
			end -- 645
		end -- 645
	end -- 645
	return invalidArguments -- 644
end) -- 644
HttpServer:postSchedule("/git/history", function(req) -- 654
	do -- 655
		local _type_0 = type(req) -- 655
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 655
		if _tab_0 then -- 655
			local body = req.body -- 655
			if body ~= nil then -- 655
				local repoPath, limit = body.repoPath, body.limit -- 656
				limit = math.max(1, math.min(100, tonumber(limit) or 20)) -- 657
				return gitRunSync(repoPath, "log --metadata-only -n " .. tostring(limit), nil, 10) -- 658
			end -- 655
		end -- 655
	end -- 655
	return invalidArguments -- 654
end) -- 654
HttpServer:postSchedule("/git/remotes", function(req) -- 660
	do -- 661
		local _type_0 = type(req) -- 661
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 661
		if _tab_0 then -- 661
			local body = req.body -- 661
			if body ~= nil then -- 661
				local repoPath, command = body.repoPath, body.command -- 662
				command = command or "remote -v" -- 663
				return gitRunSync(repoPath, command, nil, 10) -- 664
			end -- 661
		end -- 661
	end -- 661
	return invalidArguments -- 660
end) -- 660
HttpServer:postSchedule("/git/branches", function(req) -- 666
	do -- 667
		local _type_0 = type(req) -- 667
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 667
		if _tab_0 then -- 667
			local body = req.body -- 667
			if body ~= nil then -- 667
				local repoPath, command = body.repoPath, body.command -- 668
				command = command or "branch" -- 669
				return gitRunSync(repoPath, command, nil, 10) -- 670
			end -- 667
		end -- 667
	end -- 667
	return invalidArguments -- 666
end) -- 666
HttpServer:postSchedule("/git/tags", function(req) -- 672
	do -- 673
		local _type_0 = type(req) -- 673
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 673
		if _tab_0 then -- 673
			local body = req.body -- 673
			if body ~= nil then -- 673
				local repoPath, command = body.repoPath, body.command -- 674
				command = command or "tag" -- 675
				return gitRunSync(repoPath, command, nil, 10) -- 676
			end -- 673
		end -- 673
	end -- 673
	return invalidArguments -- 672
end) -- 672
HttpServer:post("/git/profile/get", function() -- 678
	ensureGitTables() -- 679
	local rows = DB:query("select name, email from GitProfile where id = 1 limit 1") -- 680
	local profile -- 681
	if rows and rows[1] then -- 681
		profile = { -- 682
			name = rows[1][1], -- 682
			email = rows[1][2] -- 682
		} -- 682
	else -- 684
		profile = { -- 684
			name = "", -- 684
			email = "" -- 684
		} -- 684
	end -- 681
	return { -- 685
		success = true, -- 685
		profile = profile -- 685
	} -- 685
end) -- 678
HttpServer:post("/git/profile/save", function(req) -- 687
	do -- 688
		local _type_0 = type(req) -- 688
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 688
		if _tab_0 then -- 688
			local name -- 688
			do -- 688
				local _obj_0 = req.body -- 688
				local _type_1 = type(_obj_0) -- 688
				if "table" == _type_1 or "userdata" == _type_1 then -- 688
					name = _obj_0.name -- 688
				end -- 688
			end -- 688
			local email -- 688
			do -- 688
				local _obj_0 = req.body -- 688
				local _type_1 = type(_obj_0) -- 688
				if "table" == _type_1 or "userdata" == _type_1 then -- 688
					email = _obj_0.email -- 688
				end -- 688
			end -- 688
			if name ~= nil and email ~= nil then -- 688
				ensureGitTables() -- 689
				DB:exec("insert into GitProfile(id, name, email, updated_at) values(1, ?, ?, ?) on conflict(id) do update set name = excluded.name, email = excluded.email, updated_at = excluded.updated_at", { -- 691
					tostring(name or ""), -- 691
					tostring(email or ""), -- 692
					os.time() -- 693
				}) -- 690
				return { -- 695
					success = true -- 695
				} -- 695
			end -- 688
		end -- 688
	end -- 688
	return invalidArguments -- 687
end) -- 687
HttpServer:post("/git/auth/list", function(req) -- 697
	ensureGitTables() -- 698
	local host = nil -- 699
	do -- 700
		local _type_0 = type(req) -- 700
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 700
		if _tab_0 then -- 700
			local body = req.body -- 700
			if body ~= nil then -- 700
				host = body.host -- 701
			end -- 700
		end -- 700
	end -- 700
	local rows -- 702
	if host and host ~= "" then -- 702
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential where host = ? order by host asc, label asc, id asc", { -- 703
			tostring(host):lower() -- 703
		}) -- 703
	else -- 705
		rows = DB:query("select id, host, label, type, username, created_at, updated_at, last_used_at from GitCredential order by host asc, label asc, id asc") -- 705
	end -- 702
	local items -- 706
	if rows then -- 706
		local _accum_0 = { } -- 706
		local _len_0 = 1 -- 706
		for _index_0 = 1, #rows do -- 706
			local row = rows[_index_0] -- 706
			_accum_0[_len_0] = gitCredentialToPublic(row) -- 706
			_len_0 = _len_0 + 1 -- 706
		end -- 706
		items = _accum_0 -- 706
	else -- 706
		items = { } -- 706
	end -- 706
	return { -- 707
		success = true, -- 707
		items = items -- 707
	} -- 707
end) -- 697
HttpServer:postSchedule("/git/auth/match", function(req) -- 709
	do -- 710
		local _type_0 = type(req) -- 710
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 710
		if _tab_0 then -- 710
			local body = req.body -- 710
			if body ~= nil then -- 710
				if not (type(body) == "table") then -- 711
					return invalidArguments -- 711
				end -- 711
				local repoPath, command, url = body.repoPath, body.command, body.url -- 712
				if url ~= nil and type(url) ~= "string" then -- 713
					return invalidArguments -- 713
				end -- 713
				if not (type(url) == "string" and url ~= "") then -- 714
					if not (type(repoPath) == "string" and type(command) == "string") then -- 715
						return invalidArguments -- 715
					end -- 715
				end -- 714
				local host -- 716
				if url and url ~= "" then -- 716
					host = gitHostFromURL(url) -- 716
				else -- 716
					host = gitCommandHost(repoPath, command) -- 716
				end -- 716
				if not host then -- 717
					return { -- 717
						success = false, -- 717
						message = "git host is required" -- 717
					} -- 717
				end -- 717
				local items = gitCredentialsForHost(host) -- 718
				return { -- 719
					success = true, -- 719
					host = host, -- 719
					items = items, -- 719
					needsSelection = #items > 1, -- 719
					authId = (#items == 1 and items[1].id or nil) -- 719
				} -- 719
			end -- 710
		end -- 710
	end -- 710
	return invalidArguments -- 709
end) -- 709
HttpServer:post("/git/auth/save", function(req) -- 721
	do -- 722
		local _type_0 = type(req) -- 722
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 722
		if _tab_0 then -- 722
			local body = req.body -- 722
			if body ~= nil then -- 722
				local id, host, label, username, password, token = body.id, body.host, body.label, body.username, body.password, body.token -- 723
				host = tostring(host or ""):lower():match("^%s*(.-)%s*$") -- 724
				label = tostring(label or ""):match("^%s*(.-)%s*$") -- 725
				local credentialType = tostring(body.type or "token") -- 726
				username = tostring(username or "") -- 727
				local secret -- 728
				if credentialType == "basic" then -- 728
					secret = tostring(password or "") -- 728
				else -- 728
					secret = tostring(token or password or "") -- 728
				end -- 728
				if host == "" then -- 729
					return { -- 729
						success = false, -- 729
						message = "host is required" -- 729
					} -- 729
				end -- 729
				if label == "" then -- 730
					return { -- 730
						success = false, -- 730
						message = "label is required" -- 730
					} -- 730
				end -- 730
				if secret == "" then -- 731
					return { -- 731
						success = false, -- 731
						message = "secret is required" -- 731
					} -- 731
				end -- 731
				if not (("basic" == credentialType or "token" == credentialType)) then -- 732
					return { -- 732
						success = false, -- 732
						message = "invalid type" -- 732
					} -- 732
				end -- 732
				ensureGitTables() -- 733
				local now = os.time() -- 734
				if id then -- 735
					DB:exec("update GitCredential set host = ?, label = ?, type = ?, username = ?, secret = ?, updated_at = ? where id = ?", { -- 737
						host, -- 737
						label, -- 737
						credentialType, -- 737
						username, -- 737
						secret, -- 737
						now, -- 737
						(tonumber(id) or 0) -- 737
					}) -- 736
					return { -- 739
						success = true, -- 739
						id = tonumber(id) -- 739
					} -- 739
				else -- 741
					DB:exec("insert into GitCredential(host, label, type, username, secret, created_at, updated_at) values(?, ?, ?, ?, ?, ?, ?)", { -- 742
						host, -- 742
						label, -- 742
						credentialType, -- 742
						username, -- 742
						secret, -- 742
						now, -- 742
						now -- 742
					}) -- 741
					local rows = DB:query("select last_insert_rowid()") -- 744
					return { -- 745
						success = true, -- 745
						id = rows and rows[1] and rows[1][1] -- 745
					} -- 745
				end -- 735
			end -- 722
		end -- 722
	end -- 722
	return invalidArguments -- 721
end) -- 721
HttpServer:post("/git/auth/delete", function(req) -- 747
	do -- 748
		local _type_0 = type(req) -- 748
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 748
		if _tab_0 then -- 748
			local id -- 748
			do -- 748
				local _obj_0 = req.body -- 748
				local _type_1 = type(_obj_0) -- 748
				if "table" == _type_1 or "userdata" == _type_1 then -- 748
					id = _obj_0.id -- 748
				end -- 748
			end -- 748
			if id ~= nil then -- 748
				ensureGitTables() -- 749
				local credentialId = tonumber(id) or 0 -- 750
				DB:exec("delete from GitCredential where id = ?", { -- 751
					credentialId -- 751
				}) -- 751
				return { -- 752
					success = true -- 752
				} -- 752
			end -- 748
		end -- 748
	end -- 748
	return invalidArguments -- 747
end) -- 747
HttpServer:postSchedule("/git/auth/test", function(req) -- 754
	do -- 755
		local _type_0 = type(req) -- 755
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 755
		if _tab_0 then -- 755
			local body = req.body -- 755
			if body ~= nil then -- 755
				local repoPath, url, authId = body.repoPath, body.url, body.authId -- 756
				local credential = gitLoadCredential(authId) -- 757
				local optionsJSON = gitAuthOptionsJSON(credential) -- 758
				return gitRunSync(repoPath, "ls-remote " .. tostring(gitQuote(url)), optionsJSON, 20) -- 759
			end -- 755
		end -- 755
	end -- 755
	return invalidArguments -- 754
end) -- 754
HttpServer:post("/agent/storage/usage", function() -- 762
	return AgentStorage.getStorageUsage() -- 762
end) -- 762
HttpServer:post("/agent/session/create", function(req) -- 764
	do -- 765
		local _type_0 = type(req) -- 765
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 765
		if _tab_0 then -- 765
			local projectRoot -- 765
			do -- 765
				local _obj_0 = req.body -- 765
				local _type_1 = type(_obj_0) -- 765
				if "table" == _type_1 or "userdata" == _type_1 then -- 765
					projectRoot = _obj_0.projectRoot -- 765
				end -- 765
			end -- 765
			local title -- 765
			do -- 765
				local _obj_0 = req.body -- 765
				local _type_1 = type(_obj_0) -- 765
				if "table" == _type_1 or "userdata" == _type_1 then -- 765
					title = _obj_0.title -- 765
				end -- 765
			end -- 765
			if projectRoot ~= nil and title ~= nil then -- 765
				return AgentSession.createSession(projectRoot, title) -- 766
			end -- 765
		end -- 765
	end -- 765
	return invalidArguments -- 764
end) -- 764
HttpServer:post("/agent/session/create-sub", function(req) -- 768
	do -- 769
		local _type_0 = type(req) -- 769
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 769
		if _tab_0 then -- 769
			local parentSessionId -- 769
			do -- 769
				local _obj_0 = req.body -- 769
				local _type_1 = type(_obj_0) -- 769
				if "table" == _type_1 or "userdata" == _type_1 then -- 769
					parentSessionId = _obj_0.parentSessionId -- 769
				end -- 769
			end -- 769
			local title -- 769
			do -- 769
				local _obj_0 = req.body -- 769
				local _type_1 = type(_obj_0) -- 769
				if "table" == _type_1 or "userdata" == _type_1 then -- 769
					title = _obj_0.title -- 769
				end -- 769
			end -- 769
			if parentSessionId ~= nil and title ~= nil then -- 769
				return AgentSession.createSubSession(parentSessionId, title) -- 770
			end -- 769
		end -- 769
	end -- 769
	return invalidArguments -- 768
end) -- 768
HttpServer:post("/agent/session/get", function(req) -- 772
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
				return AgentSession.getSession(sessionId) -- 774
			end -- 773
		end -- 773
	end -- 773
	return invalidArguments -- 772
end) -- 772
HttpServer:post("/agent/vision/asset", function(req) -- 776
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
			local path -- 777
			do -- 777
				local _obj_0 = req.body -- 777
				local _type_1 = type(_obj_0) -- 777
				if "table" == _type_1 or "userdata" == _type_1 then -- 777
					path = _obj_0.path -- 777
				end -- 777
			end -- 777
			if sessionId ~= nil and path ~= nil then -- 777
				return AgentVisionAssets.getSessionVisionImageFromPath(sessionId, path) -- 778
			end -- 777
		end -- 777
	end -- 777
	return invalidArguments -- 776
end) -- 776
HttpServer:post("/agent/session/mode", function(req) -- 780
	do -- 781
		local _type_0 = type(req) -- 781
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 781
		if _tab_0 then -- 781
			local sessionId -- 781
			do -- 781
				local _obj_0 = req.body -- 781
				local _type_1 = type(_obj_0) -- 781
				if "table" == _type_1 or "userdata" == _type_1 then -- 781
					sessionId = _obj_0.sessionId -- 781
				end -- 781
			end -- 781
			local workMode -- 781
			do -- 781
				local _obj_0 = req.body -- 781
				local _type_1 = type(_obj_0) -- 781
				if "table" == _type_1 or "userdata" == _type_1 then -- 781
					workMode = _obj_0.workMode -- 781
				end -- 781
			end -- 781
			if sessionId ~= nil and workMode ~= nil then -- 781
				return AgentSession.setWorkMode(sessionId, workMode) -- 782
			end -- 781
		end -- 781
	end -- 781
	return invalidArguments -- 780
end) -- 780
HttpServer:post("/agent/session/send", function(req) -- 784
	do -- 785
		local _type_0 = type(req) -- 785
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 785
		if _tab_0 then -- 785
			local sessionId -- 785
			do -- 785
				local _obj_0 = req.body -- 785
				local _type_1 = type(_obj_0) -- 785
				if "table" == _type_1 or "userdata" == _type_1 then -- 785
					sessionId = _obj_0.sessionId -- 785
				end -- 785
			end -- 785
			local prompt -- 785
			do -- 785
				local _obj_0 = req.body -- 785
				local _type_1 = type(_obj_0) -- 785
				if "table" == _type_1 or "userdata" == _type_1 then -- 785
					prompt = _obj_0.prompt -- 785
				end -- 785
			end -- 785
			if sessionId ~= nil and prompt ~= nil then -- 785
				return AgentSession.sendPrompt(sessionId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId, nil, nil, req.body.submission) -- 786
			end -- 785
		end -- 785
	end -- 785
	return invalidArguments -- 784
end) -- 784
HttpServer:post("/agent/session/send-local", function(req) -- 788
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
			local prompt -- 789
			do -- 789
				local _obj_0 = req.body -- 789
				local _type_1 = type(_obj_0) -- 789
				if "table" == _type_1 or "userdata" == _type_1 then -- 789
					prompt = _obj_0.prompt -- 789
				end -- 789
			end -- 789
			local localAgentConfigId -- 789
			do -- 789
				local _obj_0 = req.body -- 789
				local _type_1 = type(_obj_0) -- 789
				if "table" == _type_1 or "userdata" == _type_1 then -- 789
					localAgentConfigId = _obj_0.localAgentConfigId -- 789
				end -- 789
			end -- 789
			if sessionId ~= nil and prompt ~= nil and localAgentConfigId ~= nil then -- 789
				return AgentSession.sendLocalPrompt(sessionId, prompt, localAgentConfigId, req.body.submission) -- 790
			end -- 789
		end -- 789
	end -- 789
	return invalidArguments -- 788
end) -- 788
HttpServer:post("/agent/session/local/new", function(req) -- 792
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
				return AgentLocalAgent.abandonSession(sessionId) -- 794
			end -- 793
		end -- 793
	end -- 793
	return invalidArguments -- 792
end) -- 792
HttpServer:post("/agent/session/local/info", function(req) -- 796
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
			if sessionId ~= nil then -- 797
				local info = AgentLocalAgent.getSessionInfo(sessionId) -- 798
				return { -- 799
					success = true, -- 799
					info = info -- 799
				} -- 799
			end -- 797
		end -- 797
	end -- 797
	return invalidArguments -- 796
end) -- 796
HttpServer:post("/agent/session/continue", function(req) -- 801
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
				return AgentSession.continuePrompt(sessionId, req.body.disabledAgentTools, req.body.llmConfigId) -- 803
			end -- 802
		end -- 802
	end -- 802
	return invalidArguments -- 801
end) -- 801
HttpServer:post("/agent/session/finish-handoff", function(req) -- 805
	do -- 806
		local _type_0 = type(req) -- 806
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 806
		if _tab_0 then -- 806
			local sessionId -- 806
			do -- 806
				local _obj_0 = req.body -- 806
				local _type_1 = type(_obj_0) -- 806
				if "table" == _type_1 or "userdata" == _type_1 then -- 806
					sessionId = _obj_0.sessionId -- 806
				end -- 806
			end -- 806
			if sessionId ~= nil then -- 806
				return AgentSession.finishSubSessionHandoff(sessionId, req.body.llmConfigId) -- 807
			end -- 806
		end -- 806
	end -- 806
	return invalidArguments -- 805
end) -- 805
HttpServer:post("/agent/session/resend", function(req) -- 809
	do -- 810
		local _type_0 = type(req) -- 810
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 810
		if _tab_0 then -- 810
			local sessionId -- 810
			do -- 810
				local _obj_0 = req.body -- 810
				local _type_1 = type(_obj_0) -- 810
				if "table" == _type_1 or "userdata" == _type_1 then -- 810
					sessionId = _obj_0.sessionId -- 810
				end -- 810
			end -- 810
			local messageId -- 810
			do -- 810
				local _obj_0 = req.body -- 810
				local _type_1 = type(_obj_0) -- 810
				if "table" == _type_1 or "userdata" == _type_1 then -- 810
					messageId = _obj_0.messageId -- 810
				end -- 810
			end -- 810
			local prompt -- 810
			do -- 810
				local _obj_0 = req.body -- 810
				local _type_1 = type(_obj_0) -- 810
				if "table" == _type_1 or "userdata" == _type_1 then -- 810
					prompt = _obj_0.prompt -- 810
				end -- 810
			end -- 810
			if sessionId ~= nil and messageId ~= nil and prompt ~= nil then -- 810
				return AgentSession.resendPrompt(sessionId, messageId, prompt, req.body.disabledAgentTools, req.body.workMode, req.body.llmConfigId) -- 811
			end -- 810
		end -- 810
	end -- 810
	return invalidArguments -- 809
end) -- 809
HttpServer:post("/agent/session/questionnaire/respond", function(req) -- 813
	do -- 814
		local _type_0 = type(req) -- 814
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 814
		if _tab_0 then -- 814
			local sessionId -- 814
			do -- 814
				local _obj_0 = req.body -- 814
				local _type_1 = type(_obj_0) -- 814
				if "table" == _type_1 or "userdata" == _type_1 then -- 814
					sessionId = _obj_0.sessionId -- 814
				end -- 814
			end -- 814
			local questionnaireId -- 814
			do -- 814
				local _obj_0 = req.body -- 814
				local _type_1 = type(_obj_0) -- 814
				if "table" == _type_1 or "userdata" == _type_1 then -- 814
					questionnaireId = _obj_0.questionnaireId -- 814
				end -- 814
			end -- 814
			local answers -- 814
			do -- 814
				local _obj_0 = req.body -- 814
				local _type_1 = type(_obj_0) -- 814
				if "table" == _type_1 or "userdata" == _type_1 then -- 814
					answers = _obj_0.answers -- 814
				end -- 814
			end -- 814
			if sessionId ~= nil and questionnaireId ~= nil and answers ~= nil then -- 814
				return AgentSession.respondQuestionnaire(sessionId, questionnaireId, answers, req.body.llmConfigId) -- 815
			end -- 814
		end -- 814
	end -- 814
	return invalidArguments -- 813
end) -- 813
HttpServer:post("/agent/session/questionnaire/cancel", function(req) -- 817
	do -- 818
		local _type_0 = type(req) -- 818
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 818
		if _tab_0 then -- 818
			local sessionId -- 818
			do -- 818
				local _obj_0 = req.body -- 818
				local _type_1 = type(_obj_0) -- 818
				if "table" == _type_1 or "userdata" == _type_1 then -- 818
					sessionId = _obj_0.sessionId -- 818
				end -- 818
			end -- 818
			local questionnaireId -- 818
			do -- 818
				local _obj_0 = req.body -- 818
				local _type_1 = type(_obj_0) -- 818
				if "table" == _type_1 or "userdata" == _type_1 then -- 818
					questionnaireId = _obj_0.questionnaireId -- 818
				end -- 818
			end -- 818
			if sessionId ~= nil and questionnaireId ~= nil then -- 818
				return AgentSession.cancelQuestionnaire(sessionId, questionnaireId, req.body.llmConfigId) -- 819
			end -- 818
		end -- 818
	end -- 818
	return invalidArguments -- 817
end) -- 817
HttpServer:post("/agent/task/status", function(req) -- 821
	do -- 822
		local _type_0 = type(req) -- 822
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 822
		if _tab_0 then -- 822
			local sessionId -- 822
			do -- 822
				local _obj_0 = req.body -- 822
				local _type_1 = type(_obj_0) -- 822
				if "table" == _type_1 or "userdata" == _type_1 then -- 822
					sessionId = _obj_0.sessionId -- 822
				end -- 822
			end -- 822
			if sessionId ~= nil then -- 822
				local res = AgentSession.getSession(sessionId) -- 823
				if not res.success then -- 824
					return res -- 824
				end -- 824
				local taskId = res.session.currentTaskId -- 825
				local checkpoints -- 826
				if taskId then -- 826
					checkpoints = AgentTools.listCheckpoints(taskId) -- 826
				else -- 826
					checkpoints = { } -- 826
				end -- 826
				return { -- 828
					success = true, -- 828
					session = res.session, -- 829
					relatedSessions = res.relatedSessions, -- 830
					spawnInfo = res.spawnInfo, -- 831
					messages = res.messages, -- 832
					steps = res.steps, -- 833
					checkpoints = checkpoints, -- 834
					pendingQuestionnaire = res.pendingQuestionnaire, -- 835
					hasActivePlan = res.hasActivePlan -- 836
				} -- 827
			end -- 822
		end -- 822
	end -- 822
	return invalidArguments -- 821
end) -- 821
HttpServer:post("/agent/task/running", function() -- 838
	local res = AgentSession.listRunningSessions() -- 839
	if res.success and #res.sessions == 0 then -- 840
		res.sessions = nil -- 841
	end -- 840
	return res -- 842
end) -- 838
HttpServer:post("/agent/task/stop", function(req) -- 844
	do -- 845
		local _type_0 = type(req) -- 845
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 845
		if _tab_0 then -- 845
			local sessionId -- 845
			do -- 845
				local _obj_0 = req.body -- 845
				local _type_1 = type(_obj_0) -- 845
				if "table" == _type_1 or "userdata" == _type_1 then -- 845
					sessionId = _obj_0.sessionId -- 845
				end -- 845
			end -- 845
			if sessionId ~= nil then -- 845
				return AgentSession.stopSessionTask(sessionId) -- 846
			end -- 845
		end -- 845
	end -- 845
	return invalidArguments -- 844
end) -- 844
HttpServer:post("/agent/checkpoint/list", function(req) -- 848
	do -- 849
		local _type_0 = type(req) -- 849
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 849
		if _tab_0 then -- 849
			local taskId -- 849
			do -- 849
				local _obj_0 = req.body -- 849
				local _type_1 = type(_obj_0) -- 849
				if "table" == _type_1 or "userdata" == _type_1 then -- 849
					taskId = _obj_0.taskId -- 849
				end -- 849
			end -- 849
			local sessionId -- 849
			do -- 849
				local _obj_0 = req.body -- 849
				local _type_1 = type(_obj_0) -- 849
				if "table" == _type_1 or "userdata" == _type_1 then -- 849
					sessionId = _obj_0.sessionId -- 849
				end -- 849
			end -- 849
			if sessionId ~= nil then -- 849
				if not taskId and sessionId then -- 850
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 851
				end -- 850
				if not taskId then -- 852
					return { -- 852
						success = false, -- 852
						message = "task not found" -- 852
					} -- 852
				end -- 852
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 853
				if not access.success then -- 854
					return access -- 854
				end -- 854
				return { -- 856
					success = true, -- 856
					taskId = taskId, -- 857
					checkpoints = AgentTools.listCheckpoints(taskId) -- 858
				} -- 855
			end -- 849
		end -- 849
	end -- 849
	return invalidArguments -- 848
end) -- 848
HttpServer:post("/agent/checkpoint/diff", function(req) -- 860
	do -- 861
		local _type_0 = type(req) -- 861
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 861
		if _tab_0 then -- 861
			local sessionId -- 861
			do -- 861
				local _obj_0 = req.body -- 861
				local _type_1 = type(_obj_0) -- 861
				if "table" == _type_1 or "userdata" == _type_1 then -- 861
					sessionId = _obj_0.sessionId -- 861
				end -- 861
			end -- 861
			local checkpointId -- 861
			do -- 861
				local _obj_0 = req.body -- 861
				local _type_1 = type(_obj_0) -- 861
				if "table" == _type_1 or "userdata" == _type_1 then -- 861
					checkpointId = _obj_0.checkpointId -- 861
				end -- 861
			end -- 861
			if sessionId ~= nil and checkpointId ~= nil then -- 861
				if not (checkpointId > 0) then -- 862
					return { -- 862
						success = false, -- 862
						message = "invalid checkpointId" -- 862
					} -- 862
				end -- 862
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 863
				if not access.success then -- 864
					return access -- 864
				end -- 864
				return AgentTools.getCheckpointDiff(checkpointId) -- 865
			end -- 861
		end -- 861
	end -- 861
	return invalidArguments -- 860
end) -- 860
HttpServer:post("/agent/task/diff", function(req) -- 867
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
				return AgentTools.getTaskChangeSetDiff(taskId) -- 872
			end -- 868
		end -- 868
	end -- 868
	return invalidArguments -- 867
end) -- 867
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 874
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
			local checkpointId -- 875
			do -- 875
				local _obj_0 = req.body -- 875
				local _type_1 = type(_obj_0) -- 875
				if "table" == _type_1 or "userdata" == _type_1 then -- 875
					checkpointId = _obj_0.checkpointId -- 875
				end -- 875
			end -- 875
			if sessionId ~= nil and checkpointId ~= nil then -- 875
				if not (checkpointId > 0) then -- 876
					return { -- 876
						success = false, -- 876
						message = "invalid checkpointId" -- 876
					} -- 876
				end -- 876
				local access = AgentSession.validateCheckpointAccess(sessionId, checkpointId) -- 877
				if not access.success then -- 878
					return access -- 878
				end -- 878
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, access.session.projectRoot) -- 879
				if not rollbackRes.success then -- 880
					return rollbackRes -- 880
				end -- 880
				return { -- 882
					success = true, -- 882
					checkpointId = rollbackRes.checkpointId -- 883
				} -- 881
			end -- 875
		end -- 875
	end -- 875
	return invalidArguments -- 874
end) -- 874
HttpServer:post("/agent/task/rollback", function(req) -- 885
	do -- 886
		local _type_0 = type(req) -- 886
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 886
		if _tab_0 then -- 886
			local sessionId -- 886
			do -- 886
				local _obj_0 = req.body -- 886
				local _type_1 = type(_obj_0) -- 886
				if "table" == _type_1 or "userdata" == _type_1 then -- 886
					sessionId = _obj_0.sessionId -- 886
				end -- 886
			end -- 886
			local taskId -- 886
			do -- 886
				local _obj_0 = req.body -- 886
				local _type_1 = type(_obj_0) -- 886
				if "table" == _type_1 or "userdata" == _type_1 then -- 886
					taskId = _obj_0.taskId -- 886
				end -- 886
			end -- 886
			if sessionId ~= nil and taskId ~= nil then -- 886
				if not (taskId > 0) then -- 887
					return { -- 887
						success = false, -- 887
						message = "invalid taskId" -- 887
					} -- 887
				end -- 887
				local access = AgentSession.validateTaskAccess(sessionId, taskId) -- 888
				if not access.success then -- 889
					return access -- 889
				end -- 889
				local rollbackRes = AgentTools.rollbackTaskChangeSet(taskId, access.session.projectRoot) -- 890
				if not rollbackRes.success then -- 891
					return rollbackRes -- 891
				end -- 891
				return { -- 893
					success = true, -- 893
					taskId = rollbackRes.taskId, -- 894
					checkpointId = rollbackRes.checkpointId, -- 895
					checkpointCount = rollbackRes.checkpointCount -- 896
				} -- 892
			end -- 886
		end -- 886
	end -- 886
	return invalidArguments -- 885
end) -- 885
local getSearchPath -- 898
getSearchPath = function(file) -- 898
	do -- 899
		local dir = getProjectDirFromFile(file) -- 899
		if dir then -- 899
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 900
		end -- 899
	end -- 899
	return "" -- 898
end -- 898
local getSearchFolders -- 902
getSearchFolders = function(file) -- 902
	do -- 903
		local dir = getProjectDirFromFile(file) -- 903
		if dir then -- 903
			return { -- 905
				Path(dir, "Script"), -- 905
				dir -- 906
			} -- 904
		end -- 903
	end -- 903
	return { } -- 902
end -- 902
local disabledCheckForLua = { -- 909
	"incompatible number of returns", -- 909
	"unknown", -- 910
	"cannot index", -- 911
	"module not found", -- 912
	"don't know how to resolve", -- 913
	"ContainerItem", -- 914
	"cannot resolve a type", -- 915
	"invalid key", -- 916
	"inconsistent index type", -- 917
	"cannot use operator", -- 918
	"attempting ipairs loop", -- 919
	"expects record or nominal", -- 920
	"variable is not being assigned", -- 921
	"<invalid type>", -- 922
	"<any type>", -- 923
	"using the '#' operator", -- 924
	"can't match a record", -- 925
	"redeclaration of variable", -- 926
	"cannot apply pairs", -- 927
	"not a function", -- 928
	"to%-be%-closed" -- 929
} -- 908
local yueCheck -- 931
yueCheck = function(file, content, lax) -- 931
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 932
	if isTIC80 then -- 933
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 934
	end -- 933
	local searchPath = getSearchPath(file) -- 935
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 936
	local info = { } -- 937
	local globals = { } -- 938
	for _index_0 = 1, #checkResult do -- 939
		local _des_0 = checkResult[_index_0] -- 939
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 939
		if "error" == t then -- 940
			info[#info + 1] = { -- 941
				"syntax", -- 941
				file, -- 941
				line, -- 941
				col, -- 941
				msg -- 941
			} -- 941
		elseif "global" == t then -- 942
			globals[#globals + 1] = { -- 943
				msg, -- 943
				line, -- 943
				col -- 943
			} -- 943
		end -- 940
	end -- 939
	if luaCodes then -- 944
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 945
		if success then -- 946
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 947
			if not (lintResult == "") then -- 948
				lintResult = lintResult .. "\n" -- 948
			end -- 948
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 949
		else -- 950
			for _index_0 = 1, #lintResult do -- 950
				local _des_0 = lintResult[_index_0] -- 950
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 950
				if isTIC80 and tic80APIs[name] then -- 951
					goto _continue_0 -- 951
				end -- 951
				info[#info + 1] = { -- 952
					"syntax", -- 952
					file, -- 952
					line, -- 952
					col, -- 952
					"invalid global variable" -- 952
				} -- 952
				::_continue_0:: -- 951
			end -- 950
		end -- 946
	end -- 944
	return luaCodes, info -- 953
end -- 931
local luaCheck -- 955
luaCheck = function(file, content) -- 955
	local res, err = load(content, "check") -- 956
	if not res then -- 957
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 958
		return { -- 959
			success = false, -- 959
			info = { -- 959
				{ -- 959
					"syntax", -- 959
					file, -- 959
					tonumber(line), -- 959
					0, -- 959
					msg -- 959
				} -- 959
			} -- 959
		} -- 959
	end -- 957
	local success, info = teal.checkAsync(content, file, true, "") -- 960
	if info then -- 961
		do -- 962
			local _accum_0 = { } -- 962
			local _len_0 = 1 -- 962
			for _index_0 = 1, #info do -- 962
				local item = info[_index_0] -- 962
				local useCheck = true -- 963
				if item[1] ~= "global" and not item[5]:match("unused") then -- 964
					for _index_1 = 1, #disabledCheckForLua do -- 965
						local check = disabledCheckForLua[_index_1] -- 965
						if item[5]:match(check) then -- 966
							useCheck = false -- 967
						end -- 966
					end -- 965
				end -- 964
				if not useCheck then -- 968
					goto _continue_0 -- 968
				end -- 968
				do -- 969
					local _exp_0 = item[1] -- 969
					if "global" == _exp_0 then -- 970
						item[1] = "syntax" -- 971
					elseif "type" == _exp_0 then -- 972
						item[1] = "warning" -- 973
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 974
						goto _continue_0 -- 975
					end -- 969
				end -- 969
				_accum_0[_len_0] = item -- 976
				_len_0 = _len_0 + 1 -- 963
				::_continue_0:: -- 963
			end -- 962
			info = _accum_0 -- 962
		end -- 962
		if #info == 0 then -- 977
			info = nil -- 978
			success = true -- 979
		end -- 977
	end -- 961
	return { -- 980
		success = success, -- 980
		info = info -- 980
	} -- 980
end -- 955
local luaCheckWithLineInfo -- 982
luaCheckWithLineInfo = function(file, luaCodes) -- 982
	local res = luaCheck(file, luaCodes) -- 983
	local info = { } -- 984
	if not res.success then -- 985
		local current = 1 -- 986
		local lastLine = 1 -- 987
		local lineMap = { } -- 988
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 989
			local num = lineCode:match("--%s*(%d+)%s*$") -- 990
			if num then -- 991
				lastLine = tonumber(num) -- 992
			end -- 991
			lineMap[current] = lastLine -- 993
			current = current + 1 -- 994
		end -- 989
		local _list_0 = res.info -- 995
		for _index_0 = 1, #_list_0 do -- 995
			local item = _list_0[_index_0] -- 995
			item[3] = lineMap[item[3]] or 0 -- 996
			item[4] = 0 -- 997
			info[#info + 1] = item -- 998
		end -- 995
		return false, info -- 999
	end -- 985
	return true, info -- 1000
end -- 982
local getCompiledYueLine -- 1002
getCompiledYueLine = function(content, line, row, file, lax) -- 1002
	local luaCodes = yueCheck(file, content, lax) -- 1003
	if not luaCodes then -- 1004
		return nil -- 1004
	end -- 1004
	local current = 1 -- 1005
	local lastLine = 1 -- 1006
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 1007
	local targetRow = nil -- 1008
	local lineMap = { } -- 1009
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 1010
		local num = lineCode:match("--%s*(%d+)%s*$") -- 1011
		if num then -- 1012
			lastLine = tonumber(num) -- 1012
		end -- 1012
		lineMap[current] = lastLine -- 1013
		if row <= lastLine and not targetRow then -- 1014
			targetRow = current -- 1015
			break -- 1016
		end -- 1014
		current = current + 1 -- 1017
	end -- 1010
	targetRow = current -- 1018
	if targetLine and targetRow then -- 1019
		return luaCodes, targetLine, targetRow, lineMap -- 1020
	else -- 1022
		return nil -- 1022
	end -- 1019
end -- 1002
local godotCheckAsync -- 1024
godotCheckAsync = function(file, content, coalesce) -- 1024
	if coalesce == nil then -- 1024
		coalesce = true -- 1024
	end -- 1024
	if not (type(file) == "string" and Content:isAbsolutePath(file) and type(content) == "string") then -- 1025
		return { -- 1025
			success = false, -- 1025
			info = { -- 1025
				{ -- 1025
					"syntax", -- 1025
					tostring(file), -- 1025
					1, -- 1025
					0, -- 1025
					"Invalid Godot check request" -- 1025
				} -- 1025
			} -- 1025
		} -- 1025
	end -- 1025
	local releaseAgent = AgentHost.acquire() -- 1026
	local _ <close> = setmetatable({ }, { -- 1027
		__close = function() -- 1027
			return releaseAgent() -- 1027
		end -- 1027
	}) -- 1027
	local GodotBuild = require("Agent.Tool.GodotBuild") -- 1028
	local project = GodotBuild.findGodotProject(Content.writablePath, file) or GodotBuild.findGodotProject(Content.assetPath, file) -- 1029
	if not project then -- 1030
		return { -- 1030
			success = false, -- 1030
			info = { -- 1030
				{ -- 1030
					"syntax", -- 1030
					file, -- 1030
					1, -- 1030
					0, -- 1030
					"Godot file does not belong to a project with project.godot" -- 1030
				} -- 1030
			} -- 1030
		} -- 1030
	end -- 1030
	local GodotCheck = require("Agent.Tool.GodotCheck") -- 1031
	local result -- 1032
	local onFulfilled -- 1033
	onFulfilled = function(_, value) -- 1033
		result = value -- 1033
	end -- 1033
	local onRejected -- 1034
	onRejected = function(_, err) -- 1034
		result = { -- 1034
			success = false, -- 1034
			info = { -- 1034
				{ -- 1034
					"tool", -- 1034
					file, -- 1034
					1, -- 1034
					0, -- 1034
					tostring(err) -- 1034
				} -- 1034
			} -- 1034
		} -- 1034
	end -- 1034
	local promise = GodotCheck.checkGodotFile(project, file, content, coalesce) -- 1035
	promise["then"](promise, onFulfilled, onRejected) -- 1036
	wait(function() -- 1037
		return result ~= nil -- 1037
	end) -- 1037
	return result -- 1038
end -- 1024
HttpServer:postSchedule("/check", function(req) -- 1040
	do -- 1041
		local _type_0 = type(req) -- 1041
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1041
		if _tab_0 then -- 1041
			local file -- 1041
			do -- 1041
				local _obj_0 = req.body -- 1041
				local _type_1 = type(_obj_0) -- 1041
				if "table" == _type_1 or "userdata" == _type_1 then -- 1041
					file = _obj_0.file -- 1041
				end -- 1041
			end -- 1041
			local content -- 1041
			do -- 1041
				local _obj_0 = req.body -- 1041
				local _type_1 = type(_obj_0) -- 1041
				if "table" == _type_1 or "userdata" == _type_1 then -- 1041
					content = _obj_0.content -- 1041
				end -- 1041
			end -- 1041
			if file ~= nil and content ~= nil then -- 1041
				local ext = Path:getExt(file) -- 1042
				if "gd" == ext or "tscn" == ext or "tres" == ext or "gdshader" == ext or "gdshaderinc" == ext then -- 1043
					return godotCheckAsync(file, content) -- 1044
				elseif "tl" == ext then -- 1045
					local searchPath = getSearchPath(file) -- 1046
					do -- 1047
						local isTIC80 = CheckTIC80Code(content) -- 1047
						if isTIC80 then -- 1047
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1048
						end -- 1047
					end -- 1047
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 1049
					return { -- 1050
						success = success, -- 1050
						info = info -- 1050
					} -- 1050
				elseif "lua" == ext then -- 1051
					do -- 1052
						local isTIC80 = CheckTIC80Code(content) -- 1052
						if isTIC80 then -- 1052
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1053
						end -- 1052
					end -- 1052
					return luaCheck(file, content) -- 1054
				elseif "yue" == ext then -- 1055
					local luaCodes, info = yueCheck(file, content, false) -- 1056
					local success = luaCodes ~= nil -- 1057
					if luaCodes then -- 1058
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 1059
						do -- 1060
							local _tab_1 = { } -- 1060
							local _idx_0 = #_tab_1 + 1 -- 1060
							for _index_0 = 1, #info do -- 1060
								local _value_0 = info[_index_0] -- 1060
								_tab_1[_idx_0] = _value_0 -- 1060
								_idx_0 = _idx_0 + 1 -- 1060
							end -- 1060
							local _idx_1 = #_tab_1 + 1 -- 1060
							for _index_0 = 1, #luaInfo do -- 1060
								local _value_0 = luaInfo[_index_0] -- 1060
								_tab_1[_idx_1] = _value_0 -- 1060
								_idx_1 = _idx_1 + 1 -- 1060
							end -- 1060
							info = _tab_1 -- 1060
						end -- 1060
						success = success and luaSuccess -- 1061
					end -- 1058
					if #info > 0 then -- 1062
						return { -- 1063
							success = success, -- 1063
							info = info -- 1063
						} -- 1063
					else -- 1065
						return { -- 1065
							success = success -- 1065
						} -- 1065
					end -- 1062
				elseif "xml" == ext then -- 1066
					local success, result = xml.check(content) -- 1067
					if success then -- 1068
						local info -- 1069
						success, info = luaCheckWithLineInfo(file, result) -- 1069
						if #info > 0 then -- 1070
							return { -- 1071
								success = success, -- 1071
								info = info -- 1071
							} -- 1071
						else -- 1073
							return { -- 1073
								success = success -- 1073
							} -- 1073
						end -- 1070
					else -- 1075
						local info -- 1075
						do -- 1075
							local _accum_0 = { } -- 1075
							local _len_0 = 1 -- 1075
							for _index_0 = 1, #result do -- 1075
								local _des_0 = result[_index_0] -- 1075
								local row, err = _des_0[1], _des_0[2] -- 1075
								_accum_0[_len_0] = { -- 1076
									"syntax", -- 1076
									file, -- 1076
									row, -- 1076
									0, -- 1076
									err -- 1076
								} -- 1076
								_len_0 = _len_0 + 1 -- 1076
							end -- 1075
							info = _accum_0 -- 1075
						end -- 1075
						return { -- 1077
							success = false, -- 1077
							info = info -- 1077
						} -- 1077
					end -- 1068
				end -- 1043
			end -- 1041
		end -- 1041
	end -- 1041
	return { -- 1040
		success = true -- 1040
	} -- 1040
end) -- 1040
HttpServer:post("/body/parse", function(req) -- 1079
	do -- 1080
		local _type_0 = type(req) -- 1080
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1080
		if _tab_0 then -- 1080
			local file -- 1080
			do -- 1080
				local _obj_0 = req.body -- 1080
				local _type_1 = type(_obj_0) -- 1080
				if "table" == _type_1 or "userdata" == _type_1 then -- 1080
					file = _obj_0.file -- 1080
				end -- 1080
			end -- 1080
			local content -- 1080
			do -- 1080
				local _obj_0 = req.body -- 1080
				local _type_1 = type(_obj_0) -- 1080
				if "table" == _type_1 or "userdata" == _type_1 then -- 1080
					content = _obj_0.content -- 1080
				end -- 1080
			end -- 1080
			if file ~= nil and content ~= nil then -- 1080
				if not (file:sub(-6) == ".b.lua") then -- 1081
					return { -- 1082
						success = false, -- 1082
						phase = "request", -- 1082
						message = "only .b.lua files can be converted" -- 1082
					} -- 1082
				end -- 1081
				local loader, err = load("_ENV = {}\n" .. content) -- 1083
				if not loader then -- 1084
					return { -- 1085
						success = false, -- 1085
						phase = "parse", -- 1085
						message = tostring(err) -- 1085
					} -- 1085
				end -- 1084
				local ok, data = pcall(loader) -- 1086
				if not ok then -- 1087
					return { -- 1088
						success = false, -- 1088
						phase = "execute", -- 1088
						message = tostring(data) -- 1088
					} -- 1088
				end -- 1087
				if not ("table" == type(data) and data[1] == "Array") then -- 1089
					return { -- 1090
						success = false, -- 1090
						phase = "validate", -- 1090
						message = "body lua root must be {\"Array\", ...}" -- 1090
					} -- 1090
				end -- 1089
				local text, jsonErr = json.encode(data, false, true) -- 1091
				if not text then -- 1092
					return { -- 1093
						success = false, -- 1093
						phase = "encode", -- 1093
						message = tostring(jsonErr) -- 1093
					} -- 1093
				end -- 1092
				return { -- 1094
					success = true, -- 1094
					json = text -- 1094
				} -- 1094
			end -- 1080
		end -- 1080
	end -- 1080
	return { -- 1079
		success = false, -- 1079
		phase = "request", -- 1079
		message = "invalid request" -- 1079
	} -- 1079
end) -- 1079
local updateInferedDesc -- 1096
updateInferedDesc = function(infered) -- 1096
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 1097
		return -- 1097
	end -- 1097
	local key, row = infered.key, infered.row -- 1098
	local codes = Content:loadAsync(key) -- 1099
	if codes then -- 1099
		local comments = { } -- 1100
		local line = 0 -- 1101
		local skipping = false -- 1102
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1103
			line = line + 1 -- 1104
			if line >= row then -- 1105
				break -- 1105
			end -- 1105
			if lineCode:match("^%s*%-%- @") then -- 1106
				skipping = true -- 1107
				goto _continue_0 -- 1108
			end -- 1106
			local result = lineCode:match("^%s*%-%- (.+)") -- 1109
			if result then -- 1109
				if not skipping then -- 1110
					comments[#comments + 1] = result -- 1110
				end -- 1110
			elseif #comments > 0 then -- 1111
				comments = { } -- 1112
				skipping = false -- 1113
			end -- 1109
			::_continue_0:: -- 1104
		end -- 1103
		infered.doc = table.concat(comments, "\n") -- 1114
	end -- 1099
end -- 1096
HttpServer:postSchedule("/infer", function(req) -- 1116
	do -- 1117
		local _type_0 = type(req) -- 1117
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1117
		if _tab_0 then -- 1117
			local lang -- 1117
			do -- 1117
				local _obj_0 = req.body -- 1117
				local _type_1 = type(_obj_0) -- 1117
				if "table" == _type_1 or "userdata" == _type_1 then -- 1117
					lang = _obj_0.lang -- 1117
				end -- 1117
			end -- 1117
			local file -- 1117
			do -- 1117
				local _obj_0 = req.body -- 1117
				local _type_1 = type(_obj_0) -- 1117
				if "table" == _type_1 or "userdata" == _type_1 then -- 1117
					file = _obj_0.file -- 1117
				end -- 1117
			end -- 1117
			local content -- 1117
			do -- 1117
				local _obj_0 = req.body -- 1117
				local _type_1 = type(_obj_0) -- 1117
				if "table" == _type_1 or "userdata" == _type_1 then -- 1117
					content = _obj_0.content -- 1117
				end -- 1117
			end -- 1117
			local line -- 1117
			do -- 1117
				local _obj_0 = req.body -- 1117
				local _type_1 = type(_obj_0) -- 1117
				if "table" == _type_1 or "userdata" == _type_1 then -- 1117
					line = _obj_0.line -- 1117
				end -- 1117
			end -- 1117
			local row -- 1117
			do -- 1117
				local _obj_0 = req.body -- 1117
				local _type_1 = type(_obj_0) -- 1117
				if "table" == _type_1 or "userdata" == _type_1 then -- 1117
					row = _obj_0.row -- 1117
				end -- 1117
			end -- 1117
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1117
				local searchPath = getSearchPath(file) -- 1118
				if "tl" == lang or "lua" == lang then -- 1119
					if CheckTIC80Code(content) then -- 1120
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1121
					end -- 1120
					local infered = teal.inferAsync(content, line, row, searchPath) -- 1122
					if (infered ~= nil) then -- 1123
						updateInferedDesc(infered) -- 1124
						return { -- 1125
							success = true, -- 1125
							infered = infered -- 1125
						} -- 1125
					end -- 1123
				elseif "yue" == lang then -- 1126
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 1127
					if not luaCodes then -- 1128
						return { -- 1128
							success = false -- 1128
						} -- 1128
					end -- 1128
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 1129
					if (infered ~= nil) then -- 1130
						local col -- 1131
						file, row, col = infered.file, infered.row, infered.col -- 1131
						if file == "" and row > 0 and col > 0 then -- 1132
							infered.row = lineMap[row] or 0 -- 1133
							infered.col = 0 -- 1134
						end -- 1132
						updateInferedDesc(infered) -- 1135
						return { -- 1136
							success = true, -- 1136
							infered = infered -- 1136
						} -- 1136
					end -- 1130
				end -- 1119
			end -- 1117
		end -- 1117
	end -- 1117
	return { -- 1116
		success = false -- 1116
	} -- 1116
end) -- 1116
local _anon_func_3 = function(doc) -- 1197
	local _accum_0 = { } -- 1197
	local _len_0 = 1 -- 1197
	local _list_0 = doc.params -- 1197
	for _index_0 = 1, #_list_0 do -- 1197
		local param = _list_0[_index_0] -- 1197
		_accum_0[_len_0] = param.name -- 1197
		_len_0 = _len_0 + 1 -- 1197
	end -- 1197
	return _accum_0 -- 1197
end -- 1197
local getParamDocs -- 1138
getParamDocs = function(signatures) -- 1138
	if not (signatures and #signatures > 0) then -- 1139
		return nil -- 1139
	end -- 1139
	local docs = { } -- 1140
	do -- 1141
		local codes = Content:loadAsync(signatures[1].file) -- 1141
		if codes then -- 1141
			local comments = { } -- 1142
			local params = { } -- 1143
			local line = 0 -- 1144
			local returnType = nil -- 1145
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 1146
				line = line + 1 -- 1147
				local needBreak = true -- 1148
				for i, _des_0 in ipairs(signatures) do -- 1149
					local row = _des_0.row -- 1149
					if line >= row and not (docs[i] ~= nil) then -- 1150
						if #comments > 0 or #params > 0 or returnType then -- 1151
							docs[i] = { -- 1153
								doc = table.concat(comments, "  \n"), -- 1153
								returnType = returnType -- 1154
							} -- 1152
							if #params > 0 then -- 1156
								docs[i].params = params -- 1156
							end -- 1156
						else -- 1158
							docs[i] = false -- 1158
						end -- 1151
					end -- 1150
					if not docs[i] then -- 1159
						needBreak = false -- 1159
					end -- 1159
				end -- 1149
				if needBreak then -- 1160
					break -- 1160
				end -- 1160
				local result = lineCode:match("%s*%-%- (.+)") -- 1161
				if result then -- 1161
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 1162
					if not name then -- 1163
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 1164
					end -- 1163
					if name then -- 1165
						local pname = name -- 1166
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 1167
							pname = pname .. "?" -- 1167
						end -- 1167
						params[#params + 1] = { -- 1169
							name = tostring(pname) .. ": " .. tostring(typ), -- 1169
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 1170
						} -- 1168
					else -- 1173
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 1173
						if typ then -- 1173
							if returnType then -- 1174
								returnType = returnType .. ", " .. typ -- 1175
							else -- 1177
								returnType = typ -- 1177
							end -- 1174
							result = result:gsub("@return", "**return:**") -- 1178
						end -- 1173
						comments[#comments + 1] = result -- 1179
					end -- 1165
				elseif #comments > 0 then -- 1180
					comments = { } -- 1181
					params = { } -- 1182
					returnType = nil -- 1183
				end -- 1161
			end -- 1146
		end -- 1141
	end -- 1141
	local results = { } -- 1184
	for i, signature in ipairs(signatures) do -- 1185
		local item = { -- 1187
			desc = signature.desc, -- 1187
			doc = "", -- 1188
			file = signature.file, -- 1189
			row = signature.row, -- 1190
			col = signature.col -- 1191
		} -- 1186
		do -- 1193
			local doc = docs[i] -- 1193
			if doc then -- 1193
				item.doc = doc.doc -- 1194
				if doc.params then -- 1195
					item.params = doc.params -- 1196
					item.desc = "function(" .. tostring(table.concat(_anon_func_3(doc), ', ')) .. ")" -- 1197
				elseif doc.returnType then -- 1198
					item.desc = "function()" -- 1199
				end -- 1195
				if doc.returnType then -- 1200
					item.desc = item.desc .. ": " .. tostring(doc.returnType) -- 1200
				end -- 1200
			end -- 1193
		end -- 1193
		results[#results + 1] = item -- 1201
	end -- 1185
	return results -- 1202
end -- 1138
HttpServer:postSchedule("/signature", function(req) -- 1204
	do -- 1205
		local _type_0 = type(req) -- 1205
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1205
		if _tab_0 then -- 1205
			local lang -- 1205
			do -- 1205
				local _obj_0 = req.body -- 1205
				local _type_1 = type(_obj_0) -- 1205
				if "table" == _type_1 or "userdata" == _type_1 then -- 1205
					lang = _obj_0.lang -- 1205
				end -- 1205
			end -- 1205
			local file -- 1205
			do -- 1205
				local _obj_0 = req.body -- 1205
				local _type_1 = type(_obj_0) -- 1205
				if "table" == _type_1 or "userdata" == _type_1 then -- 1205
					file = _obj_0.file -- 1205
				end -- 1205
			end -- 1205
			local content -- 1205
			do -- 1205
				local _obj_0 = req.body -- 1205
				local _type_1 = type(_obj_0) -- 1205
				if "table" == _type_1 or "userdata" == _type_1 then -- 1205
					content = _obj_0.content -- 1205
				end -- 1205
			end -- 1205
			local line -- 1205
			do -- 1205
				local _obj_0 = req.body -- 1205
				local _type_1 = type(_obj_0) -- 1205
				if "table" == _type_1 or "userdata" == _type_1 then -- 1205
					line = _obj_0.line -- 1205
				end -- 1205
			end -- 1205
			local row -- 1205
			do -- 1205
				local _obj_0 = req.body -- 1205
				local _type_1 = type(_obj_0) -- 1205
				if "table" == _type_1 or "userdata" == _type_1 then -- 1205
					row = _obj_0.row -- 1205
				end -- 1205
			end -- 1205
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1205
				local searchPath = getSearchPath(file) -- 1206
				if "tl" == lang or "lua" == lang then -- 1207
					if CheckTIC80Code(content) then -- 1208
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1209
					end -- 1208
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 1210
					if signatures then -- 1210
						signatures = getParamDocs(signatures) -- 1211
						if signatures then -- 1211
							return { -- 1212
								success = true, -- 1212
								signatures = signatures -- 1212
							} -- 1212
						end -- 1211
					end -- 1210
				elseif "yue" == lang then -- 1213
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 1214
					if not luaCodes then -- 1215
						return { -- 1215
							success = false -- 1215
						} -- 1215
					end -- 1215
					do -- 1216
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 1216
						if chainOp then -- 1216
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1217
							if withVar then -- 1217
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 1218
							end -- 1217
						end -- 1216
					end -- 1216
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 1219
					if signatures then -- 1219
						signatures = getParamDocs(signatures) -- 1220
						if signatures then -- 1220
							return { -- 1221
								success = true, -- 1221
								signatures = signatures -- 1221
							} -- 1221
						end -- 1220
					else -- 1222
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1222
						if signatures then -- 1222
							signatures = getParamDocs(signatures) -- 1223
							if signatures then -- 1223
								return { -- 1224
									success = true, -- 1224
									signatures = signatures -- 1224
								} -- 1224
							end -- 1223
						end -- 1222
					end -- 1219
				end -- 1207
			end -- 1205
		end -- 1205
	end -- 1205
	return { -- 1204
		success = false -- 1204
	} -- 1204
end) -- 1204
local luaKeywords = { -- 1227
	'and', -- 1227
	'break', -- 1228
	'do', -- 1229
	'else', -- 1230
	'elseif', -- 1231
	'end', -- 1232
	'false', -- 1233
	'for', -- 1234
	'function', -- 1235
	'goto', -- 1236
	'if', -- 1237
	'in', -- 1238
	'local', -- 1239
	'nil', -- 1240
	'not', -- 1241
	'or', -- 1242
	'repeat', -- 1243
	'return', -- 1244
	'then', -- 1245
	'true', -- 1246
	'until', -- 1247
	'while' -- 1248
} -- 1226
local tealKeywords = { -- 1252
	'record', -- 1252
	'as', -- 1253
	'is', -- 1254
	'type', -- 1255
	'embed', -- 1256
	'enum', -- 1257
	'global', -- 1258
	'any', -- 1259
	'boolean', -- 1260
	'integer', -- 1261
	'number', -- 1262
	'string', -- 1263
	'thread' -- 1264
} -- 1251
local yueKeywords = { -- 1268
	"and", -- 1268
	"break", -- 1269
	"do", -- 1270
	"else", -- 1271
	"elseif", -- 1272
	"false", -- 1273
	"for", -- 1274
	"goto", -- 1275
	"if", -- 1276
	"in", -- 1277
	"local", -- 1278
	"nil", -- 1279
	"not", -- 1280
	"or", -- 1281
	"repeat", -- 1282
	"return", -- 1283
	"then", -- 1284
	"true", -- 1285
	"until", -- 1286
	"while", -- 1287
	"as", -- 1288
	"class", -- 1289
	"continue", -- 1290
	"export", -- 1291
	"extends", -- 1292
	"from", -- 1293
	"global", -- 1294
	"import", -- 1295
	"macro", -- 1296
	"switch", -- 1297
	"try", -- 1298
	"unless", -- 1299
	"using", -- 1300
	"when", -- 1301
	"with" -- 1302
} -- 1267
local _anon_func_4 = function(f) -- 1338
	local _val_0 = Path:getExt(f) -- 1338
	return "ttf" == _val_0 or "otf" == _val_0 -- 1338
end -- 1338
local _anon_func_5 = function(suggestions) -- 1364
	local _tbl_0 = { } -- 1364
	for _index_0 = 1, #suggestions do -- 1364
		local item = suggestions[_index_0] -- 1364
		_tbl_0[item[1] .. item[2]] = item -- 1364
	end -- 1364
	return _tbl_0 -- 1364
end -- 1364
HttpServer:postSchedule("/complete", function(req) -- 1305
	do -- 1306
		local _type_0 = type(req) -- 1306
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1306
		if _tab_0 then -- 1306
			local lang -- 1306
			do -- 1306
				local _obj_0 = req.body -- 1306
				local _type_1 = type(_obj_0) -- 1306
				if "table" == _type_1 or "userdata" == _type_1 then -- 1306
					lang = _obj_0.lang -- 1306
				end -- 1306
			end -- 1306
			local file -- 1306
			do -- 1306
				local _obj_0 = req.body -- 1306
				local _type_1 = type(_obj_0) -- 1306
				if "table" == _type_1 or "userdata" == _type_1 then -- 1306
					file = _obj_0.file -- 1306
				end -- 1306
			end -- 1306
			local content -- 1306
			do -- 1306
				local _obj_0 = req.body -- 1306
				local _type_1 = type(_obj_0) -- 1306
				if "table" == _type_1 or "userdata" == _type_1 then -- 1306
					content = _obj_0.content -- 1306
				end -- 1306
			end -- 1306
			local line -- 1306
			do -- 1306
				local _obj_0 = req.body -- 1306
				local _type_1 = type(_obj_0) -- 1306
				if "table" == _type_1 or "userdata" == _type_1 then -- 1306
					line = _obj_0.line -- 1306
				end -- 1306
			end -- 1306
			local row -- 1306
			do -- 1306
				local _obj_0 = req.body -- 1306
				local _type_1 = type(_obj_0) -- 1306
				if "table" == _type_1 or "userdata" == _type_1 then -- 1306
					row = _obj_0.row -- 1306
				end -- 1306
			end -- 1306
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 1306
				local searchPath = getSearchPath(file) -- 1307
				repeat -- 1308
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 1309
					if lang == "yue" then -- 1310
						if not item then -- 1311
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 1311
						end -- 1311
						if not item then -- 1312
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 1312
						end -- 1312
					end -- 1310
					local searchType = nil -- 1313
					if not item then -- 1314
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1315
						if lang == "yue" then -- 1316
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 1317
						end -- 1316
						if (item ~= nil) then -- 1318
							searchType = "Image" -- 1318
						end -- 1318
					end -- 1314
					if not item then -- 1319
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 1320
						if lang == "yue" then -- 1321
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 1322
						end -- 1321
						if (item ~= nil) then -- 1323
							searchType = "Font" -- 1323
						end -- 1323
					end -- 1319
					if not item then -- 1324
						break -- 1324
					end -- 1324
					local searchPaths = Content.searchPaths -- 1325
					local _list_0 = getSearchFolders(file) -- 1326
					for _index_0 = 1, #_list_0 do -- 1326
						local folder = _list_0[_index_0] -- 1326
						searchPaths[#searchPaths + 1] = folder -- 1327
					end -- 1326
					if searchType then -- 1328
						searchPaths[#searchPaths + 1] = Content.assetPath -- 1328
					end -- 1328
					local tokens -- 1329
					do -- 1329
						local _accum_0 = { } -- 1329
						local _len_0 = 1 -- 1329
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 1329
							_accum_0[_len_0] = mod -- 1329
							_len_0 = _len_0 + 1 -- 1329
						end -- 1329
						tokens = _accum_0 -- 1329
					end -- 1329
					local suggestions = { } -- 1330
					for _index_0 = 1, #searchPaths do -- 1331
						local path = searchPaths[_index_0] -- 1331
						local sPath = Path(path, table.unpack(tokens)) -- 1332
						if not Content:exist(sPath) then -- 1333
							goto _continue_0 -- 1333
						end -- 1333
						if searchType == "Font" then -- 1334
							local fontPath = Path(sPath, "Font") -- 1335
							if Content:exist(fontPath) then -- 1336
								local _list_1 = Content:getFiles(fontPath) -- 1337
								for _index_1 = 1, #_list_1 do -- 1337
									local f = _list_1[_index_1] -- 1337
									if _anon_func_4(f) then -- 1338
										if "." == f:sub(1, 1) then -- 1339
											goto _continue_1 -- 1339
										end -- 1339
										suggestions[#suggestions + 1] = { -- 1340
											Path:getName(f), -- 1340
											"font", -- 1340
											"field" -- 1340
										} -- 1340
									end -- 1338
									::_continue_1:: -- 1338
								end -- 1337
							end -- 1336
						end -- 1334
						local _list_1 = Content:getFiles(sPath) -- 1341
						for _index_1 = 1, #_list_1 do -- 1341
							local f = _list_1[_index_1] -- 1341
							if "Image" == searchType then -- 1342
								do -- 1343
									local _exp_0 = Path:getExt(f) -- 1343
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 1343
										if "." == f:sub(1, 1) then -- 1344
											goto _continue_2 -- 1344
										end -- 1344
										suggestions[#suggestions + 1] = { -- 1345
											f, -- 1345
											"image", -- 1345
											"field" -- 1345
										} -- 1345
									end -- 1343
								end -- 1343
								goto _continue_2 -- 1346
							elseif "Font" == searchType then -- 1347
								do -- 1348
									local _exp_0 = Path:getExt(f) -- 1348
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 1348
										if "." == f:sub(1, 1) then -- 1349
											goto _continue_2 -- 1349
										end -- 1349
										suggestions[#suggestions + 1] = { -- 1350
											f, -- 1350
											"font", -- 1350
											"field" -- 1350
										} -- 1350
									end -- 1348
								end -- 1348
								goto _continue_2 -- 1351
							end -- 1342
							local _exp_0 = Path:getExt(f) -- 1352
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1352
								local name = Path:getName(f) -- 1353
								if "d" == Path:getExt(name) then -- 1354
									goto _continue_2 -- 1354
								end -- 1354
								if "." == name:sub(1, 1) then -- 1355
									goto _continue_2 -- 1355
								end -- 1355
								suggestions[#suggestions + 1] = { -- 1356
									name, -- 1356
									"module", -- 1356
									"field" -- 1356
								} -- 1356
							end -- 1352
							::_continue_2:: -- 1342
						end -- 1341
						local _list_2 = Content:getDirs(sPath) -- 1357
						for _index_1 = 1, #_list_2 do -- 1357
							local dir = _list_2[_index_1] -- 1357
							if "." == dir:sub(1, 1) then -- 1358
								goto _continue_3 -- 1358
							end -- 1358
							suggestions[#suggestions + 1] = { -- 1359
								dir, -- 1359
								"folder", -- 1359
								"variable" -- 1359
							} -- 1359
							::_continue_3:: -- 1358
						end -- 1357
						::_continue_0:: -- 1332
					end -- 1331
					if item == "" and not searchType then -- 1360
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1361
						for _index_0 = 1, #_list_1 do -- 1361
							local _des_0 = _list_1[_index_0] -- 1361
							local name = _des_0[1] -- 1361
							suggestions[#suggestions + 1] = { -- 1362
								name, -- 1362
								"dora module", -- 1362
								"function" -- 1362
							} -- 1362
						end -- 1361
					end -- 1360
					if #suggestions > 0 then -- 1363
						do -- 1364
							local _accum_0 = { } -- 1364
							local _len_0 = 1 -- 1364
							for _, v in pairs(_anon_func_5(suggestions)) do -- 1364
								_accum_0[_len_0] = v -- 1364
								_len_0 = _len_0 + 1 -- 1364
							end -- 1364
							suggestions = _accum_0 -- 1364
						end -- 1364
						return { -- 1365
							success = true, -- 1365
							suggestions = suggestions -- 1365
						} -- 1365
					else -- 1367
						return { -- 1367
							success = false -- 1367
						} -- 1367
					end -- 1363
				until true -- 1308
				if "tl" == lang or "lua" == lang then -- 1369
					do -- 1370
						local isTIC80 = CheckTIC80Code(content) -- 1370
						if isTIC80 then -- 1370
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1371
						end -- 1370
					end -- 1370
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 1372
					if not line:match("[%.:]$") then -- 1373
						local checkSet -- 1374
						do -- 1374
							local _tbl_0 = { } -- 1374
							for _index_0 = 1, #suggestions do -- 1374
								local _des_0 = suggestions[_index_0] -- 1374
								local name = _des_0[1] -- 1374
								_tbl_0[name] = true -- 1374
							end -- 1374
							checkSet = _tbl_0 -- 1374
						end -- 1374
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1375
						for _index_0 = 1, #_list_0 do -- 1375
							local item = _list_0[_index_0] -- 1375
							if not checkSet[item[1]] then -- 1376
								suggestions[#suggestions + 1] = item -- 1376
							end -- 1376
						end -- 1375
						for _index_0 = 1, #luaKeywords do -- 1377
							local word = luaKeywords[_index_0] -- 1377
							suggestions[#suggestions + 1] = { -- 1378
								word, -- 1378
								"keyword", -- 1378
								"keyword" -- 1378
							} -- 1378
						end -- 1377
						if lang == "tl" then -- 1379
							for _index_0 = 1, #tealKeywords do -- 1380
								local word = tealKeywords[_index_0] -- 1380
								suggestions[#suggestions + 1] = { -- 1381
									word, -- 1381
									"keyword", -- 1381
									"keyword" -- 1381
								} -- 1381
							end -- 1380
						end -- 1379
					end -- 1373
					if #suggestions > 0 then -- 1382
						return { -- 1383
							success = true, -- 1383
							suggestions = suggestions -- 1383
						} -- 1383
					end -- 1382
				elseif "yue" == lang then -- 1384
					local suggestions = { } -- 1385
					local gotGlobals = false -- 1386
					do -- 1387
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 1387
						if luaCodes then -- 1387
							gotGlobals = true -- 1388
							do -- 1389
								local chainOp = line:match("[^%w_]([%.\\])$") -- 1389
								if chainOp then -- 1389
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 1390
									if not withVar then -- 1391
										return { -- 1391
											success = false -- 1391
										} -- 1391
									end -- 1391
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 1392
								elseif line:match("^([%.\\])$") then -- 1393
									return { -- 1394
										success = false -- 1394
									} -- 1394
								end -- 1389
							end -- 1389
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 1395
							for _index_0 = 1, #_list_0 do -- 1395
								local item = _list_0[_index_0] -- 1395
								suggestions[#suggestions + 1] = item -- 1395
							end -- 1395
							if #suggestions == 0 then -- 1396
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 1397
								for _index_0 = 1, #_list_1 do -- 1397
									local item = _list_1[_index_0] -- 1397
									suggestions[#suggestions + 1] = item -- 1397
								end -- 1397
							end -- 1396
						end -- 1387
					end -- 1387
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 1398
						local checkSet -- 1399
						do -- 1399
							local _tbl_0 = { } -- 1399
							for _index_0 = 1, #suggestions do -- 1399
								local _des_0 = suggestions[_index_0] -- 1399
								local name = _des_0[1] -- 1399
								_tbl_0[name] = true -- 1399
							end -- 1399
							checkSet = _tbl_0 -- 1399
						end -- 1399
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 1400
						for _index_0 = 1, #_list_0 do -- 1400
							local item = _list_0[_index_0] -- 1400
							if not checkSet[item[1]] then -- 1401
								suggestions[#suggestions + 1] = item -- 1401
							end -- 1401
						end -- 1400
						if not gotGlobals then -- 1402
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 1403
							for _index_0 = 1, #_list_1 do -- 1403
								local item = _list_1[_index_0] -- 1403
								if not checkSet[item[1]] then -- 1404
									suggestions[#suggestions + 1] = item -- 1404
								end -- 1404
							end -- 1403
						end -- 1402
						for _index_0 = 1, #yueKeywords do -- 1405
							local word = yueKeywords[_index_0] -- 1405
							if not checkSet[word] then -- 1406
								suggestions[#suggestions + 1] = { -- 1407
									word, -- 1407
									"keyword", -- 1407
									"keyword" -- 1407
								} -- 1407
							end -- 1406
						end -- 1405
					end -- 1398
					if #suggestions > 0 then -- 1408
						return { -- 1409
							success = true, -- 1409
							suggestions = suggestions -- 1409
						} -- 1409
					end -- 1408
				elseif "xml" == lang then -- 1410
					local items = xml.complete(content) -- 1411
					if #items > 0 then -- 1412
						local suggestions -- 1413
						do -- 1413
							local _accum_0 = { } -- 1413
							local _len_0 = 1 -- 1413
							for _index_0 = 1, #items do -- 1413
								local _des_0 = items[_index_0] -- 1413
								local label, insertText = _des_0[1], _des_0[2] -- 1413
								_accum_0[_len_0] = { -- 1414
									label, -- 1414
									insertText, -- 1414
									"field" -- 1414
								} -- 1414
								_len_0 = _len_0 + 1 -- 1414
							end -- 1413
							suggestions = _accum_0 -- 1413
						end -- 1413
						return { -- 1415
							success = true, -- 1415
							suggestions = suggestions -- 1415
						} -- 1415
					end -- 1412
				end -- 1369
			end -- 1306
		end -- 1306
	end -- 1306
	return { -- 1305
		success = false -- 1305
	} -- 1305
end) -- 1305
local getUploadFilename -- 1417
getUploadFilename = function(req, multipartFilename) -- 1417
	local filename = req.params.name -- 1418
	if not (type(filename) == "string" and filename ~= "") then -- 1419
		filename = multipartFilename -- 1419
	end -- 1419
	if not (type(filename) == "string" and filename ~= "") then -- 1420
		return -- 1420
	end -- 1420
	if filename:sub(1, 1) == "/" or filename:sub(-1) == "/" or filename:find("//", 1, true) or filename:find("\\", 1, true) or filename:find(":", 1, true) or filename:find("\0", 1, true) then -- 1423
		return -- 1423
	end -- 1423
	local parts -- 1424
	do -- 1424
		local _accum_0 = { } -- 1424
		local _len_0 = 1 -- 1424
		for part in filename:gmatch("[^/]+") do -- 1424
			_accum_0[_len_0] = part -- 1424
			_len_0 = _len_0 + 1 -- 1424
		end -- 1424
		parts = _accum_0 -- 1424
	end -- 1424
	if #parts == 0 then -- 1425
		return -- 1425
	end -- 1425
	for _index_0 = 1, #parts do -- 1426
		local part = parts[_index_0] -- 1426
		if part == "." or part == ".." or part == "" then -- 1427
			return -- 1427
		end -- 1427
	end -- 1426
	return filename -- 1428
end -- 1417
HttpServer:upload("/upload", function(req, multipartFilename) -- 1432
	do -- 1433
		local _type_0 = type(req) -- 1433
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1433
		if _tab_0 then -- 1433
			local path -- 1433
			do -- 1433
				local _obj_0 = req.params -- 1433
				local _type_1 = type(_obj_0) -- 1433
				if "table" == _type_1 or "userdata" == _type_1 then -- 1433
					path = _obj_0.path -- 1433
				end -- 1433
			end -- 1433
			if path ~= nil then -- 1433
				local filename = getUploadFilename(req, multipartFilename) -- 1434
				if filename then -- 1434
					local uploadPath = Path(Content.writablePath, ".upload", "files") -- 1435
					if not Content:exist(uploadPath) then -- 1436
						Content:mkdir(uploadPath) -- 1437
					end -- 1436
					local targetPath = Path(uploadPath, filename) -- 1438
					Content:mkdir(Path:getPath(targetPath)) -- 1439
					return targetPath -- 1440
				end -- 1434
			end -- 1433
		end -- 1433
	end -- 1433
	return nil -- 1432
end, function(req, file) -- 1441
	do -- 1442
		local _type_0 = type(req) -- 1442
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1442
		if _tab_0 then -- 1442
			local path -- 1442
			do -- 1442
				local _obj_0 = req.params -- 1442
				local _type_1 = type(_obj_0) -- 1442
				if "table" == _type_1 or "userdata" == _type_1 then -- 1442
					path = _obj_0.path -- 1442
				end -- 1442
			end -- 1442
			if path ~= nil then -- 1442
				path = Path(Content.writablePath, path) -- 1443
				if Content:exist(path) then -- 1444
					local uploadPath = Path(Content.writablePath, ".upload", "files") -- 1445
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 1446
					Content:mkdir(Path:getPath(targetPath)) -- 1447
					if Content:move(file, targetPath) then -- 1448
						return true -- 1449
					end -- 1448
				end -- 1444
			end -- 1442
		end -- 1442
	end -- 1442
	return false -- 1441
end) -- 1430
HttpServer:post("/list", function(req) -- 1452
	do -- 1453
		local _type_0 = type(req) -- 1453
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1453
		if _tab_0 then -- 1453
			local path -- 1453
			do -- 1453
				local _obj_0 = req.body -- 1453
				local _type_1 = type(_obj_0) -- 1453
				if "table" == _type_1 or "userdata" == _type_1 then -- 1453
					path = _obj_0.path -- 1453
				end -- 1453
			end -- 1453
			if path ~= nil then -- 1453
				if Content:exist(path) then -- 1454
					local files = { } -- 1455
					local visitAssets -- 1456
					visitAssets = function(path, folder) -- 1456
						local dirs = Content:getDirs(path) -- 1457
						for _index_0 = 1, #dirs do -- 1458
							local dir = dirs[_index_0] -- 1458
							if dir:match("^%.") or dir == "node_modules" then -- 1459
								goto _continue_0 -- 1459
							end -- 1459
							local current -- 1460
							if folder == "" then -- 1460
								current = dir -- 1461
							else -- 1463
								current = Path(folder, dir) -- 1463
							end -- 1460
							files[#files + 1] = current -- 1464
							visitAssets(Path(path, dir), current) -- 1465
							::_continue_0:: -- 1459
						end -- 1458
						local fs = Content:getFiles(path) -- 1466
						for _index_0 = 1, #fs do -- 1467
							local f = fs[_index_0] -- 1467
							if (".DS_Store" == f) then -- 1468
								goto _continue_1 -- 1469
							end -- 1468
							if folder == "" then -- 1470
								files[#files + 1] = f -- 1471
							else -- 1473
								files[#files + 1] = Path(folder, f) -- 1473
							end -- 1470
							::_continue_1:: -- 1468
						end -- 1467
					end -- 1456
					visitAssets(path, "") -- 1474
					if #files == 0 then -- 1475
						files = nil -- 1475
					end -- 1475
					return { -- 1476
						success = true, -- 1476
						files = files -- 1476
					} -- 1476
				end -- 1454
			end -- 1453
		end -- 1453
	end -- 1453
	return { -- 1452
		success = false -- 1452
	} -- 1452
end) -- 1452
local updater = require("Tools.SelfUpdater.Service") -- 1479
HttpServer:post("/engine-update/state", function() -- 1480
	return require("Script.Dev.Entry").getUpdateState() -- 1480
end) -- 1480
HttpServer:post("/engine-update/check", function(req) -- 1481
	local source = req.body and req.body.source -- 1482
	if not (source == nil or ("AtomGit" == source or "GitHub" == source)) then -- 1483
		return { -- 1483
			success = false -- 1483
		} -- 1483
	end -- 1483
	return { -- 1484
		success = require("Script.Dev.Entry").checkForUpdates(true, source) -- 1484
	} -- 1484
end) -- 1481
HttpServer:post("/engine-update/download", function(req) -- 1485
	local target = req.body and req.body.platform -- 1486
	if target ~= nil then -- 1487
		if not (("windows-x64" == target or "windows-x64-opengl" == target or "windows-x64-msi" == target or "windows-x64-opengl-msi" == target)) then -- 1488
			return { -- 1488
				success = false -- 1488
			} -- 1488
		end -- 1488
	end -- 1487
	return { -- 1489
		success = updater.downloadUpdate(target) -- 1489
	} -- 1489
end) -- 1485
HttpServer:post("/engine-update/cancel", function() -- 1490
	return { -- 1490
		success = updater.cancelOperation() -- 1490
	} -- 1490
end) -- 1490
HttpServer:post("/engine-update/discard", function() -- 1491
	return { -- 1491
		success = updater.discardPrepared() -- 1491
	} -- 1491
end) -- 1491
HttpServer:post("/engine-update/ignore", function() -- 1492
	return { -- 1492
		success = updater.ignoreUpdate() -- 1492
	} -- 1492
end) -- 1492
HttpServer:post("/engine-update/install", function(req) -- 1493
	return { -- 1493
		success = updater.installUpdate(req.body and req.body.confirmed == true) -- 1493
	} -- 1493
end) -- 1493
HttpServer:post("/info", function(req) -- 1495
	local Entry = require("Script.Dev.Entry") -- 1496
	local config = Entry.getConfig() -- 1497
	do -- 1498
		local _type_0 = type(req) -- 1498
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1498
		if _tab_0 then -- 1498
			local webIDETourCompleted -- 1498
			do -- 1498
				local _obj_0 = req.body -- 1498
				local _type_1 = type(_obj_0) -- 1498
				if "table" == _type_1 or "userdata" == _type_1 then -- 1498
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1498
				end -- 1498
			end -- 1498
			if webIDETourCompleted ~= nil then -- 1498
				config.webIDETourCompleted = webIDETourCompleted == true -- 1499
			end -- 1498
		end -- 1498
	end -- 1498
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1500
	local engineDev = Entry.getEngineDev() -- 1501
	Entry.connectWebIDE(req.body and req.body.embedded == true) -- 1502
	return { -- 1504
		platform = App.platform, -- 1504
		locale = App.locale, -- 1505
		version = App.version, -- 1506
		debugging = App.debugging, -- 1506
		engineDev = engineDev, -- 1507
		webProfiler = webProfiler, -- 1508
		drawerWidth = drawerWidth, -- 1509
		webIDETourCompleted = webIDETourCompleted == true -- 1510
	} -- 1503
end) -- 1495
local ensureLLMConfigTable -- 1512
ensureLLMConfigTable = function() -- 1512
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1513
	if columns and #columns > 0 then -- 1514
		local expected = { -- 1516
			id = true, -- 1516
			name = true, -- 1517
			url = true, -- 1518
			model = true, -- 1519
			api_key = true, -- 1520
			context_window = true, -- 1521
			temperature = true, -- 1522
			max_tokens = true, -- 1523
			reasoning_effort = true, -- 1524
			custom_options = true, -- 1525
			supports_function_calling = true, -- 1526
			active = true, -- 1527
			created_at = true, -- 1528
			updated_at = true -- 1529
		} -- 1515
		local existing = { } -- 1531
		local valid = true -- 1532
		for _index_0 = 1, #columns do -- 1533
			local row = columns[_index_0] -- 1533
			local columnName = tostring(row[2]) -- 1534
			existing[columnName] = true -- 1535
			if not expected[columnName] then -- 1536
				valid = false -- 1537
				break -- 1538
			end -- 1536
		end -- 1533
		if valid then -- 1539
			if not existing.context_window then -- 1540
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1541
			end -- 1540
			if not existing.temperature then -- 1542
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1543
			end -- 1542
			if not existing.max_tokens then -- 1544
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 64000") -- 1545
			end -- 1544
			if not existing.reasoning_effort then -- 1546
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1547
			end -- 1546
			if not existing.custom_options then -- 1548
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1549
			end -- 1548
		else -- 1551
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1551
		end -- 1539
	end -- 1514
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
	]]) -- 1552
	require("Agent.Config.LLMConfigMigration").upgradeLLMConfig() -- 1571
	return require("Agent.Config.LLMConfigNames").upgradeLLMConfigNames() -- 1572
end -- 1512
local normalizeContextWindow -- 1574
normalizeContextWindow = function(value) -- 1574
	local contextWindow = tonumber(value) -- 1575
	if contextWindow == nil or contextWindow < 64000 then -- 1576
		return 64000 -- 1577
	end -- 1576
	return math.max(64000, math.floor(contextWindow)) -- 1578
end -- 1574
local normalizeTemperature -- 1580
normalizeTemperature = function(value) -- 1580
	local temperature = tonumber(value) -- 1581
	if temperature == nil then -- 1582
		return 0.1 -- 1583
	end -- 1582
	return math.max(0, math.min(2, temperature)) -- 1584
end -- 1580
local normalizeMaxTokens -- 1586
normalizeMaxTokens = function(value) -- 1586
	local maxTokens = tonumber(value) -- 1587
	if maxTokens == nil or maxTokens < 1 then -- 1588
		return 64000 -- 1589
	end -- 1588
	return math.max(1, math.floor(maxTokens)) -- 1590
end -- 1586
local normalizeReasoningEffort -- 1592
normalizeReasoningEffort = function(value) -- 1592
	if value == nil then -- 1593
		return "" -- 1594
	end -- 1593
	local effort = tostring(value) -- 1595
	return effort:match("^%s*(.-)%s*$") or "" -- 1596
end -- 1592
local normalizeCustomOptions -- 1598
normalizeCustomOptions = function(value) -- 1598
	if value == nil then -- 1599
		return "" -- 1600
	end -- 1599
	local options = tostring(value) -- 1601
	options = options:match("^%s*(.-)%s*$") or "" -- 1602
	return options -- 1603
end -- 1598
local validateCustomOptions -- 1605
validateCustomOptions = function(value) -- 1605
	local options = normalizeCustomOptions(value) -- 1606
	if options == "" then -- 1607
		return true -- 1607
	end -- 1607
	if not options:match("^%s*{") then -- 1608
		return false -- 1608
	end -- 1608
	local decoded = json.decode(options) -- 1609
	return type(decoded) == "table" -- 1610
end -- 1605
HttpServer:post("/llm/list", function() -- 1612
	ensureLLMConfigTable() -- 1613
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options\n		from LLMConfig\n		order by id asc") -- 1614
	local items -- 1618
	if rows and #rows > 0 then -- 1618
		local _accum_0 = { } -- 1619
		local _len_0 = 1 -- 1619
		for _index_0 = 1, #rows do -- 1619
			local _des_0 = rows[_index_0] -- 1619
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10] -- 1619
			_accum_0[_len_0] = { -- 1620
				id = id, -- 1620
				name = name, -- 1620
				url = url, -- 1620
				model = model, -- 1620
				key = key, -- 1620
				contextWindow = normalizeContextWindow(contextWindow), -- 1620
				temperature = normalizeTemperature(temperature), -- 1620
				maxTokens = normalizeMaxTokens(maxTokens), -- 1620
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1620
				customOptions = normalizeCustomOptions(customOptions) -- 1620
			} -- 1620
			_len_0 = _len_0 + 1 -- 1620
		end -- 1619
		items = _accum_0 -- 1618
	end -- 1618
	return { -- 1621
		success = true, -- 1621
		items = items -- 1621
	} -- 1621
end) -- 1612
HttpServer:post("/llm/create", function(req) -- 1623
	ensureLLMConfigTable() -- 1624
	do -- 1625
		local _type_0 = type(req) -- 1625
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1625
		if _tab_0 then -- 1625
			local body = req.body -- 1625
			if body ~= nil then -- 1625
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions -- 1626
				local now = os.time() -- 1627
				if name == nil or url == nil or model == nil or key == nil then -- 1628
					return invalidArguments -- 1629
				end -- 1628
				local names = require("Agent.Config.LLMConfigNames") -- 1630
				name = names.normalizeLLMConfigName(name) -- 1631
				if not name then -- 1632
					return { -- 1632
						success = false, -- 1632
						code = "INVALID_LLM_CONFIG_NAME", -- 1632
						message = "LLM configuration name must be a non-empty string" -- 1632
					} -- 1632
				end -- 1632
				local nameCheck = names.checkLLMConfigName(name) -- 1633
				if not nameCheck.success then -- 1634
					return nameCheck -- 1634
				end -- 1634
				contextWindow = normalizeContextWindow(contextWindow) -- 1635
				temperature = normalizeTemperature(temperature) -- 1636
				maxTokens = normalizeMaxTokens(maxTokens) -- 1637
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1638
				customOptions = normalizeCustomOptions(customOptions) -- 1639
				if not validateCustomOptions(customOptions) then -- 1640
					return { -- 1640
						success = false, -- 1640
						message = "customOptions must be a JSON object" -- 1640
					} -- 1640
				end -- 1640
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1647
					tostring(name), -- 1647
					tostring(url), -- 1648
					tostring(model), -- 1649
					tostring(key), -- 1650
					contextWindow, -- 1651
					temperature, -- 1652
					maxTokens, -- 1653
					reasoningEffort, -- 1654
					customOptions, -- 1655
					1, -- 1656
					now, -- 1657
					now -- 1658
				}) -- 1641
				if affected < 0 then -- 1660
					nameCheck = names.checkLLMConfigName(name) -- 1661
					if not nameCheck.success then -- 1662
						return nameCheck -- 1662
					end -- 1662
				end -- 1660
				return { -- 1663
					success = affected > 0 -- 1663
				} -- 1663
			end -- 1625
		end -- 1625
	end -- 1625
	return invalidArguments -- 1623
end) -- 1623
HttpServer:post("/llm/update", function(req) -- 1665
	ensureLLMConfigTable() -- 1666
	do -- 1667
		local _type_0 = type(req) -- 1667
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1667
		if _tab_0 then -- 1667
			local body = req.body -- 1667
			if body ~= nil then -- 1667
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions -- 1668
				local now = os.time() -- 1669
				id = tonumber(id) -- 1670
				if id == nil or id <= 0 or id ~= math.floor(id) then -- 1671
					return invalidArguments -- 1671
				end -- 1671
				local names = require("Agent.Config.LLMConfigNames") -- 1672
				name = names.normalizeLLMConfigName(name) -- 1673
				if not name then -- 1674
					return { -- 1674
						success = false, -- 1674
						code = "INVALID_LLM_CONFIG_NAME", -- 1674
						message = "LLM configuration name must be a non-empty string" -- 1674
					} -- 1674
				end -- 1674
				local nameCheck = names.checkLLMConfigName(name, id) -- 1675
				if not nameCheck.success then -- 1676
					return nameCheck -- 1676
				end -- 1676
				contextWindow = normalizeContextWindow(contextWindow) -- 1677
				temperature = normalizeTemperature(temperature) -- 1678
				maxTokens = normalizeMaxTokens(maxTokens) -- 1679
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1680
				customOptions = normalizeCustomOptions(customOptions) -- 1681
				if not validateCustomOptions(customOptions) then -- 1682
					return { -- 1682
						success = false, -- 1682
						message = "customOptions must be a JSON object" -- 1682
					} -- 1682
				end -- 1682
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, updated_at = ?\n			where id = ?", { -- 1687
					tostring(name), -- 1687
					tostring(url), -- 1688
					tostring(model), -- 1689
					tostring(key), -- 1690
					contextWindow, -- 1691
					temperature, -- 1692
					maxTokens, -- 1693
					reasoningEffort, -- 1694
					customOptions, -- 1695
					now, -- 1696
					id -- 1697
				}) -- 1683
				if affected < 0 then -- 1699
					nameCheck = names.checkLLMConfigName(name, id) -- 1700
					if not nameCheck.success then -- 1701
						return nameCheck -- 1701
					end -- 1701
				end -- 1699
				return { -- 1702
					success = affected > 0 -- 1702
				} -- 1702
			end -- 1667
		end -- 1667
	end -- 1667
	return invalidArguments -- 1665
end) -- 1665
HttpServer:post("/llm/delete", function(req) -- 1704
	ensureLLMConfigTable() -- 1705
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
				id = tonumber(id) -- 1707
				if id == nil then -- 1708
					return invalidArguments -- 1708
				end -- 1708
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1709
					id -- 1709
				}) -- 1709
				return { -- 1710
					success = affected >= 0 -- 1710
				} -- 1710
			end -- 1706
		end -- 1706
	end -- 1706
	return invalidArguments -- 1704
end) -- 1704
HttpServer:post("/local-agent/list", function() -- 1712
	return { -- 1713
		success = true, -- 1713
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1713
		items = AgentLocalAgent.listConfigs() -- 1713
	} -- 1713
end) -- 1712
HttpServer:post("/local-agent/save", function(req) -- 1715
	do -- 1716
		local _type_0 = type(req) -- 1716
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1716
		if _tab_0 then -- 1716
			local body = req.body -- 1716
			if body ~= nil then -- 1716
				return AgentLocalAgent.saveConfig(body) -- 1717
			end -- 1716
		end -- 1716
	end -- 1716
	return invalidArguments -- 1715
end) -- 1715
HttpServer:post("/local-agent/delete", function(req) -- 1719
	do -- 1720
		local _type_0 = type(req) -- 1720
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1720
		if _tab_0 then -- 1720
			local id -- 1720
			do -- 1720
				local _obj_0 = req.body -- 1720
				local _type_1 = type(_obj_0) -- 1720
				if "table" == _type_1 or "userdata" == _type_1 then -- 1720
					id = _obj_0.id -- 1720
				end -- 1720
			end -- 1720
			if id ~= nil then -- 1720
				return AgentLocalAgent.deleteConfig(id) -- 1721
			end -- 1720
		end -- 1720
	end -- 1720
	return invalidArguments -- 1719
end) -- 1719
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1723
	do -- 1724
		local _type_0 = type(req) -- 1724
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1724
		if _tab_0 then -- 1724
			local id -- 1724
			do -- 1724
				local _obj_0 = req.body -- 1724
				local _type_1 = type(_obj_0) -- 1724
				if "table" == _type_1 or "userdata" == _type_1 then -- 1724
					id = _obj_0.id -- 1724
				end -- 1724
			end -- 1724
			if id ~= nil then -- 1724
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1725
			end -- 1724
		end -- 1724
	end -- 1724
	return invalidArguments -- 1723
end) -- 1723
HttpServer:post("/stat", function(req) -- 1727
	do -- 1728
		local _type_0 = type(req) -- 1728
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1728
		if _tab_0 then -- 1728
			local path -- 1728
			do -- 1728
				local _obj_0 = req.body -- 1728
				local _type_1 = type(_obj_0) -- 1728
				if "table" == _type_1 or "userdata" == _type_1 then -- 1728
					path = _obj_0.path -- 1728
				end -- 1728
			end -- 1728
			if path ~= nil then -- 1728
				if not Content:exist(path) then -- 1729
					return { -- 1730
						success = false, -- 1730
						message = "target not existed" -- 1730
					} -- 1730
				end -- 1729
				if Content:isdir(path) then -- 1731
					return { -- 1732
						success = false, -- 1732
						message = "failed to stat a directory" -- 1732
					} -- 1732
				end -- 1731
				local size, isBinary = Content:getAttr(path) -- 1733
				if size then -- 1733
					return { -- 1734
						success = true, -- 1734
						size = size, -- 1734
						isBinary = isBinary -- 1734
					} -- 1734
				end -- 1733
			end -- 1728
		end -- 1728
	end -- 1728
	return { -- 1727
		success = false, -- 1727
		message = "failed to stat" -- 1727
	} -- 1727
end) -- 1727
HttpServer:post("/new", function(req) -- 1736
	do -- 1737
		local _type_0 = type(req) -- 1737
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1737
		if _tab_0 then -- 1737
			local path -- 1737
			do -- 1737
				local _obj_0 = req.body -- 1737
				local _type_1 = type(_obj_0) -- 1737
				if "table" == _type_1 or "userdata" == _type_1 then -- 1737
					path = _obj_0.path -- 1737
				end -- 1737
			end -- 1737
			local content -- 1737
			do -- 1737
				local _obj_0 = req.body -- 1737
				local _type_1 = type(_obj_0) -- 1737
				if "table" == _type_1 or "userdata" == _type_1 then -- 1737
					content = _obj_0.content -- 1737
				end -- 1737
			end -- 1737
			local folder -- 1737
			do -- 1737
				local _obj_0 = req.body -- 1737
				local _type_1 = type(_obj_0) -- 1737
				if "table" == _type_1 or "userdata" == _type_1 then -- 1737
					folder = _obj_0.folder -- 1737
				end -- 1737
			end -- 1737
			if path ~= nil and content ~= nil and folder ~= nil then -- 1737
				if Content:exist(path) then -- 1738
					return { -- 1739
						success = false, -- 1739
						message = "TargetExisted" -- 1739
					} -- 1739
				end -- 1738
				local parent = Path:getPath(path) -- 1740
				local files = Content:getFiles(parent) -- 1741
				if folder then -- 1742
					local name = Path:getFilename(path):lower() -- 1743
					for _index_0 = 1, #files do -- 1744
						local file = files[_index_0] -- 1744
						if name == Path:getFilename(file):lower() then -- 1745
							return { -- 1746
								success = false, -- 1746
								message = "TargetExisted" -- 1746
							} -- 1746
						end -- 1745
					end -- 1744
					if Content:mkdir(path) then -- 1747
						return { -- 1748
							success = true -- 1748
						} -- 1748
					end -- 1747
				else -- 1750
					local name = Path:getName(path):lower() -- 1750
					local targetExt = Path:getExt(path) -- 1751
					for _index_0 = 1, #files do -- 1752
						local file = files[_index_0] -- 1752
						if name == Path:getName(file):lower() then -- 1753
							local ext = Path:getExt(file) -- 1754
							if not ("tl" == targetExt or "yue" == targetExt or "ts" == targetExt or "tsx" == targetExt or "vs" == targetExt or "bl" == targetExt or "xml" == targetExt or "lua" == targetExt) or not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1755
								goto _continue_0 -- 1756
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1757
								goto _continue_0 -- 1758
							end -- 1755
							return { -- 1759
								success = false, -- 1759
								message = "SourceExisted" -- 1759
							} -- 1759
						end -- 1753
						::_continue_0:: -- 1753
					end -- 1752
					if Content:save(path, content) then -- 1760
						return { -- 1761
							success = true -- 1761
						} -- 1761
					end -- 1760
				end -- 1742
			end -- 1737
		end -- 1737
	end -- 1737
	return { -- 1736
		success = false, -- 1736
		message = "Failed" -- 1736
	} -- 1736
end) -- 1736
local deleteAsset -- 1763
deleteAsset = function(path) -- 1763
	if not Content:exist(path) then -- 1764
		return false -- 1764
	end -- 1764
	local projectRoot -- 1765
	if Content:isdir(path) and isProjectRootDir(path) then -- 1765
		projectRoot = path -- 1765
	else -- 1765
		projectRoot = nil -- 1765
	end -- 1765
	local parent = Path:getPath(path) -- 1766
	local files = Content:getFiles(parent) -- 1767
	local name = Path:getName(path):lower() -- 1768
	local ext = Path:getExt(path) -- 1769
	for _index_0 = 1, #files do -- 1770
		local file = files[_index_0] -- 1770
		if name == Path:getName(file):lower() then -- 1771
			local _exp_0 = Path:getExt(file) -- 1772
			if "tl" == _exp_0 then -- 1772
				if ("vs" == ext) then -- 1772
					Content:remove(Path(parent, file)) -- 1773
				end -- 1772
			elseif "lua" == _exp_0 then -- 1774
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1774
					Content:remove(Path(parent, file)) -- 1775
				end -- 1774
			end -- 1772
		end -- 1771
	end -- 1770
	if Content:remove(path) then -- 1776
		if projectRoot then -- 1777
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1778
		end -- 1777
		return true -- 1779
	end -- 1776
	return false -- 1780
end -- 1763
local moveAsset -- 1782
moveAsset = function(old, new) -- 1782
	if not (Content:exist(old) and not Content:exist(new)) then -- 1783
		return false -- 1783
	end -- 1783
	local renamedDir = Content:isdir(old) -- 1784
	local parent = Path:getPath(new) -- 1785
	local files = Content:getFiles(parent) -- 1786
	if renamedDir then -- 1787
		local name = Path:getFilename(new):lower() -- 1788
		for _index_0 = 1, #files do -- 1789
			local file = files[_index_0] -- 1789
			if name == Path:getFilename(file):lower() then -- 1790
				return false -- 1791
			end -- 1790
		end -- 1789
	else -- 1793
		local name = Path:getName(new):lower() -- 1793
		local ext = Path:getExt(new) -- 1794
		for _index_0 = 1, #files do -- 1795
			local file = files[_index_0] -- 1795
			if name == Path:getName(file):lower() then -- 1796
				local fileExt = Path:getExt(file) -- 1797
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) or not ("tl" == fileExt or "yue" == fileExt or "ts" == fileExt or "tsx" == fileExt or "vs" == fileExt or "bl" == fileExt or "xml" == fileExt or "lua" == fileExt) then -- 1798
					goto _continue_0 -- 1799
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1800
					goto _continue_0 -- 1801
				end -- 1798
				return false -- 1802
			end -- 1796
			::_continue_0:: -- 1796
		end -- 1795
	end -- 1787
	if not Content:move(old, new) then -- 1803
		return false -- 1803
	end -- 1803
	if renamedDir then -- 1804
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1805
	end -- 1804
	local newParent = Path:getPath(new) -- 1806
	parent = Path:getPath(old) -- 1807
	files = Content:getFiles(parent) -- 1808
	local newName = Path:getName(new) -- 1809
	local oldName = Path:getName(old) -- 1810
	local name = oldName:lower() -- 1811
	local ext = Path:getExt(old) -- 1812
	for _index_0 = 1, #files do -- 1813
		local file = files[_index_0] -- 1813
		if name == Path:getName(file):lower() then -- 1814
			local _exp_0 = Path:getExt(file) -- 1815
			if "tl" == _exp_0 then -- 1815
				if ("vs" == ext) then -- 1815
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1816
				end -- 1815
			elseif "lua" == _exp_0 then -- 1817
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1817
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1818
				end -- 1817
			end -- 1815
		end -- 1814
	end -- 1813
	return true -- 1819
end -- 1782
HttpServer:post("/delete", function(req) -- 1821
	do -- 1822
		local _type_0 = type(req) -- 1822
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1822
		if _tab_0 then -- 1822
			local path -- 1822
			do -- 1822
				local _obj_0 = req.body -- 1822
				local _type_1 = type(_obj_0) -- 1822
				if "table" == _type_1 or "userdata" == _type_1 then -- 1822
					path = _obj_0.path -- 1822
				end -- 1822
			end -- 1822
			if path ~= nil then -- 1822
				if deleteAsset(path) then -- 1823
					return { -- 1823
						success = true -- 1823
					} -- 1823
				end -- 1823
			end -- 1822
		end -- 1822
	end -- 1822
	return { -- 1821
		success = false -- 1821
	} -- 1821
end) -- 1821
HttpServer:post("/rename", function(req) -- 1825
	do -- 1826
		local _type_0 = type(req) -- 1826
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1826
		if _tab_0 then -- 1826
			local old -- 1826
			do -- 1826
				local _obj_0 = req.body -- 1826
				local _type_1 = type(_obj_0) -- 1826
				if "table" == _type_1 or "userdata" == _type_1 then -- 1826
					old = _obj_0.old -- 1826
				end -- 1826
			end -- 1826
			local new -- 1826
			do -- 1826
				local _obj_0 = req.body -- 1826
				local _type_1 = type(_obj_0) -- 1826
				if "table" == _type_1 or "userdata" == _type_1 then -- 1826
					new = _obj_0.new -- 1826
				end -- 1826
			end -- 1826
			if old ~= nil and new ~= nil then -- 1826
				if moveAsset(old, new) then -- 1827
					return { -- 1827
						success = true -- 1827
					} -- 1827
				end -- 1827
			end -- 1826
		end -- 1826
	end -- 1826
	return { -- 1825
		success = false -- 1825
	} -- 1825
end) -- 1825
local normalizeAssetPaths -- 1829
normalizeAssetPaths = function(paths) -- 1829
	if not (type(paths) == "table") then -- 1830
		return nil -- 1830
	end -- 1830
	local unique = { } -- 1831
	local candidates = { } -- 1832
	for _index_0 = 1, #paths do -- 1833
		local path = paths[_index_0] -- 1833
		if not (type(path) == "string") then -- 1834
			return nil -- 1834
		end -- 1834
		local relative = relativeToRoot(path, Content.writablePath) -- 1835
		if relative == nil or relative == "" or not Content:exist(path) then -- 1836
			return nil -- 1836
		end -- 1836
		if not unique[path] then -- 1837
			unique[path] = true -- 1838
			candidates[#candidates + 1] = path -- 1839
		end -- 1837
	end -- 1833
	table.sort(candidates, function(a, b) -- 1840
		return #a < #b -- 1840
	end) -- 1840
	local result = { } -- 1841
	for _index_0 = 1, #candidates do -- 1842
		local path = candidates[_index_0] -- 1842
		local contained = false -- 1843
		for _index_1 = 1, #result do -- 1844
			local parent = result[_index_1] -- 1844
			if relativeToRoot(path, parent) ~= nil then -- 1845
				contained = true -- 1846
				break -- 1847
			end -- 1845
		end -- 1844
		if not contained then -- 1848
			result[#result + 1] = path -- 1848
		end -- 1848
	end -- 1842
	return result -- 1849
end -- 1829
HttpServer:postSchedule("/assets/batch", function(req) -- 1851
	do -- 1852
		local _type_0 = type(req) -- 1852
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1852
		if _tab_0 then -- 1852
			local operation -- 1852
			do -- 1852
				local _obj_0 = req.body -- 1852
				local _type_1 = type(_obj_0) -- 1852
				if "table" == _type_1 or "userdata" == _type_1 then -- 1852
					operation = _obj_0.operation -- 1852
				end -- 1852
			end -- 1852
			local sources -- 1852
			do -- 1852
				local _obj_0 = req.body -- 1852
				local _type_1 = type(_obj_0) -- 1852
				if "table" == _type_1 or "userdata" == _type_1 then -- 1852
					sources = _obj_0.sources -- 1852
				end -- 1852
			end -- 1852
			if operation ~= nil and sources ~= nil then -- 1852
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1853
					return { -- 1853
						success = false, -- 1853
						message = "invalid operation" -- 1853
					} -- 1853
				end -- 1853
				sources = normalizeAssetPaths(sources) -- 1854
				if not (sources and #sources > 0) then -- 1855
					return { -- 1855
						success = false, -- 1855
						message = "invalid sources" -- 1855
					} -- 1855
				end -- 1855
				local target = req.body.target -- 1856
				local destinations = { } -- 1857
				if operation ~= "delete" then -- 1858
					if not (type(target) == "string") then -- 1859
						return { -- 1859
							success = false, -- 1859
							message = "invalid target" -- 1859
						} -- 1859
					end -- 1859
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1860
					if targetRelative == nil then -- 1861
						return { -- 1861
							success = false, -- 1861
							message = "invalid target" -- 1861
						} -- 1861
					end -- 1861
					if not (Content:exist(target) and Content:isdir(target)) then -- 1862
						return { -- 1862
							success = false, -- 1862
							message = "invalid target" -- 1862
						} -- 1862
					end -- 1862
					for _index_0 = 1, #sources do -- 1863
						local source = sources[_index_0] -- 1863
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1864
							return { -- 1865
								success = false, -- 1865
								message = "target inside source" -- 1865
							} -- 1865
						end -- 1864
						local destination = Path(target, Path:getFilename(source)) -- 1866
						if Content:exist(destination) then -- 1867
							return { -- 1867
								success = false, -- 1867
								message = "target existed" -- 1867
							} -- 1867
						end -- 1867
						if destinations[destination] then -- 1868
							return { -- 1868
								success = false, -- 1868
								message = "duplicate target" -- 1868
							} -- 1868
						end -- 1868
						destinations[destination] = true -- 1869
					end -- 1863
				end -- 1858
				local changes = { } -- 1870
				local affectedSet = { } -- 1871
				local affectedDirectories = { } -- 1872
				local addAffected -- 1873
				addAffected = function(dir) -- 1873
					if affectedSet[dir] then -- 1874
						return -- 1874
					end -- 1874
					affectedSet[dir] = true -- 1875
					affectedDirectories[#affectedDirectories + 1] = dir -- 1876
				end -- 1873
				if operation ~= "delete" then -- 1877
					addAffected(target) -- 1877
				end -- 1877
				for _index_0 = 1, #sources do -- 1878
					local source = sources[_index_0] -- 1878
					addAffected(Path:getPath(source)) -- 1879
					if operation == "delete" then -- 1880
						if not deleteAsset(source) then -- 1881
							return { -- 1881
								success = false, -- 1881
								message = "delete failed", -- 1881
								changes = changes, -- 1881
								affectedDirectories = affectedDirectories -- 1881
							} -- 1881
						end -- 1881
						changes[#changes + 1] = { -- 1882
							old = source -- 1882
						} -- 1882
					else -- 1884
						local destination = Path(target, Path:getFilename(source)) -- 1884
						local ok -- 1885
						if operation == "copy" then -- 1885
							ok = Content:copyAsync(source, destination) -- 1886
						else -- 1888
							ok = moveAsset(source, destination) -- 1888
						end -- 1885
						if not ok then -- 1889
							return { -- 1889
								success = false, -- 1889
								message = operation .. " failed", -- 1889
								changes = changes, -- 1889
								affectedDirectories = affectedDirectories -- 1889
							} -- 1889
						end -- 1889
						changes[#changes + 1] = { -- 1890
							old = source, -- 1890
							new = destination -- 1890
						} -- 1890
					end -- 1880
				end -- 1878
				return { -- 1891
					success = true, -- 1891
					changes = changes, -- 1891
					affectedDirectories = affectedDirectories -- 1891
				} -- 1891
			end -- 1852
		end -- 1852
	end -- 1852
	return { -- 1851
		success = false, -- 1851
		message = "invalid request" -- 1851
	} -- 1851
end) -- 1851
local projectFallbackPaths -- 1893
projectFallbackPaths = function(projectRoot, projFile) -- 1893
	local paths, seen = { }, { } -- 1894
	local add -- 1895
	add = function(dir) -- 1895
		if dir and dir ~= "" and not seen[dir] and Content:isdir(dir) then -- 1896
			seen[dir] = true -- 1897
			paths[#paths + 1] = dir -- 1898
		end -- 1896
	end -- 1895
	local addRoot -- 1899
	addRoot = function(root) -- 1899
		local roots = ProjectSearch(root) -- 1900
		for index = #roots, 1, -1 do -- 1901
			add(roots[index]) -- 1902
		end -- 1901
	end -- 1899
	addRoot(projectRoot) -- 1903
	if projFile and projFile ~= "" then -- 1904
		local projDir = getProjectDirFromFile(projFile) -- 1905
		if projDir then -- 1905
			addRoot(projDir) -- 1906
		else -- 1908
			add(Path:getPath(projFile)) -- 1908
		end -- 1905
	end -- 1904
	return paths -- 1909
end -- 1893
local withProjectSearchPaths -- 1911
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1911
	local fallbackPaths = projectFallbackPaths(projectRoot, projFile) -- 1912
	if not (#fallbackPaths > 0) then -- 1913
		return fn() -- 1913
	end -- 1913
	local searchPaths = Content.searchPaths -- 1914
	for _index_0 = 1, #fallbackPaths do -- 1915
		local dir = fallbackPaths[_index_0] -- 1915
		Content:addSearchPath(dir) -- 1915
	end -- 1915
	local _ <close> = setmetatable({ }, { -- 1916
		__close = function() -- 1916
			Content.searchPaths = searchPaths -- 1916
		end -- 1916
	}) -- 1916
	return fn() -- 1917
end -- 1911
HttpServer:post("/exist", function(req) -- 1918
	do -- 1919
		local _type_0 = type(req) -- 1919
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1919
		if _tab_0 then -- 1919
			local file -- 1919
			do -- 1919
				local _obj_0 = req.body -- 1919
				local _type_1 = type(_obj_0) -- 1919
				if "table" == _type_1 or "userdata" == _type_1 then -- 1919
					file = _obj_0.file -- 1919
				end -- 1919
			end -- 1919
			if file ~= nil then -- 1919
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1920
					return { -- 1921
						success = Content:exist(file) -- 1921
					} -- 1921
				end) -- 1920
			end -- 1919
		end -- 1919
	end -- 1919
	return { -- 1918
		success = false -- 1918
	} -- 1918
end) -- 1918
HttpServer:postSchedule("/read", function(req) -- 1922
	do -- 1923
		local _type_0 = type(req) -- 1923
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1923
		if _tab_0 then -- 1923
			local path -- 1923
			do -- 1923
				local _obj_0 = req.body -- 1923
				local _type_1 = type(_obj_0) -- 1923
				if "table" == _type_1 or "userdata" == _type_1 then -- 1923
					path = _obj_0.path -- 1923
				end -- 1923
			end -- 1923
			if path ~= nil then -- 1923
				local readFile -- 1924
				readFile = function() -- 1924
					if Content:exist(path) and not Content:isdir(path) then -- 1925
						local content = Content:loadAsync(path) -- 1926
						if content then -- 1926
							return { -- 1927
								content = content, -- 1927
								success = true, -- 1927
								fullPath = Content:getFullPath(path) -- 1927
							} -- 1927
						end -- 1926
					end -- 1925
					return nil -- 1924
				end -- 1924
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1928
				if result then -- 1928
					return result -- 1928
				end -- 1928
			end -- 1923
		end -- 1923
	end -- 1923
	return { -- 1922
		success = false -- 1922
	} -- 1922
end) -- 1922
local agentDocLanguage -- 1930
agentDocLanguage = function(language) -- 1930
	if language == "zh-Hans" then -- 1931
		return "zh" -- 1931
	else -- 1931
		return "en" -- 1931
	end -- 1931
end -- 1930
HttpServer:postSchedule("/doc/search", function(req) -- 1933
	local body = req.body or { } -- 1934
	local language = body.docLanguage -- 1935
	if not (("en" == language or "zh-Hans" == language)) then -- 1936
		return { -- 1936
			success = false, -- 1936
			message = "unsupported doc language" -- 1936
		} -- 1936
	end -- 1936
	local docType = body.docType -- 1937
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1938
		return { -- 1938
			success = false, -- 1938
			message = "unsupported doc type" -- 1938
		} -- 1938
	end -- 1938
	local codeLanguage = body.programmingLanguage -- 1939
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1940
		return { -- 1940
			success = false, -- 1940
			message = "unsupported programming language" -- 1940
		} -- 1940
	end -- 1940
	if not body.pattern then -- 1941
		return { -- 1941
			success = false, -- 1941
			message = "missing pattern" -- 1941
		} -- 1941
	end -- 1941
	local result = nil -- 1942
	AgentTools.searchDoraDocHttp({ -- 1944
		pattern = body.pattern, -- 1944
		docLanguage = agentDocLanguage(language), -- 1945
		docType = docType, -- 1946
		programmingLanguage = codeLanguage, -- 1947
		limit = body.limit, -- 1948
		useRegex = body.useRegex, -- 1949
		caseSensitive = body.caseSensitive, -- 1950
		includeContent = body.includeContent, -- 1951
		contentWindow = body.contentWindow -- 1952
	}, function(res) -- 1953
		result = res -- 1954
	end) -- 1943
	wait(function() -- 1955
		return result ~= nil -- 1955
	end) -- 1955
	if result and result.success then -- 1956
		result.docLanguage = language -- 1957
	end -- 1956
	if result then -- 1958
		return result -- 1959
	else -- 1961
		return { -- 1961
			success = false, -- 1961
			message = "doc search failed" -- 1961
		} -- 1961
	end -- 1958
	return { -- 1933
		success = false, -- 1933
		message = "invalid call" -- 1933
	} -- 1933
end) -- 1933
HttpServer:postSchedule("/doc/read", function(req) -- 1963
	local body = req.body or { } -- 1964
	local language = body.docLanguage -- 1965
	if not (("en" == language or "zh-Hans" == language)) then -- 1966
		return { -- 1966
			success = false, -- 1966
			message = "unsupported doc language" -- 1966
		} -- 1966
	end -- 1966
	if not body.file then -- 1967
		return { -- 1967
			success = false, -- 1967
			message = "missing file" -- 1967
		} -- 1967
	end -- 1967
	local result = AgentTools.readDoraDoc({ -- 1969
		docLanguage = agentDocLanguage(language), -- 1969
		file = body.file, -- 1970
		startLine = body.startLine, -- 1971
		endLine = body.endLine -- 1972
	}) -- 1968
	if result and result.success then -- 1973
		result.docLanguage = language -- 1974
	end -- 1973
	return result -- 1975
end) -- 1963
local readSyncFile -- 1977
readSyncFile = function(req) -- 1977
	do -- 1978
		local _type_0 = type(req) -- 1978
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1978
		if _tab_0 then -- 1978
			local params = req.params -- 1978
			if params ~= nil then -- 1978
				local path = params.path -- 1979
				if not (type(path) == "string" and path ~= "") then -- 1980
					return { -- 1980
						success = false, -- 1980
						message = "invalid path" -- 1980
					} -- 1980
				end -- 1980
				local exts -- 1981
				if params.exts then -- 1981
					local _accum_0 = { } -- 1982
					local _len_0 = 1 -- 1982
					for ext in params.exts:gmatch("[^|]*") do -- 1982
						_accum_0[_len_0] = ext -- 1982
						_len_0 = _len_0 + 1 -- 1982
					end -- 1982
					exts = _accum_0 -- 1982
				else -- 1983
					exts = { -- 1983
						"" -- 1983
					} -- 1983
				end -- 1981
				local readFileAt -- 1984
				readFileAt = function(targetPath) -- 1984
					if Content:exist(targetPath) then -- 1985
						local content = Content:load(targetPath) -- 1986
						if content then -- 1986
							return { -- 1987
								content = content, -- 1987
								success = true, -- 1987
								fullPath = Content:getFullPath(targetPath) -- 1987
							} -- 1987
						end -- 1986
					end -- 1985
					return nil -- 1984
				end -- 1984
				local readFile -- 1988
				readFile = function(fallbackPaths) -- 1988
					for _index_0 = 1, #exts do -- 1989
						local ext = exts[_index_0] -- 1989
						local targetPath = path .. ext -- 1990
						if not Content:isAbsolutePath(targetPath) then -- 1991
							for _index_1 = 1, #fallbackPaths do -- 1992
								local fallback = fallbackPaths[_index_1] -- 1992
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1993
								if fallbackResult then -- 1993
									return fallbackResult -- 1994
								end -- 1993
							end -- 1992
						end -- 1991
						local fileResult = readFileAt(targetPath) -- 1995
						if fileResult then -- 1995
							return fileResult -- 1996
						end -- 1995
					end -- 1989
					return nil -- 1988
				end -- 1988
				local readResult = readFile(projectFallbackPaths(params.projectRoot, params.projFile)) -- 1997
				if readResult then -- 1997
					return readResult -- 1998
				end -- 1997
			end -- 1978
		end -- 1978
	end -- 1978
	return { -- 1977
		success = false -- 1977
	} -- 1977
end -- 1977
HttpServer:get("/read-sync", readSyncFile) -- 2000
HttpServer:post("/read-sync", function(req) -- 2001
	return readSyncFile({ -- 2001
		params = req.body -- 2001
	}) -- 2001
end) -- 2001
local addGeneratedSourceHeader -- 2003
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 2003
	if preserveTIC80 == nil then -- 2003
		preserveTIC80 = false -- 2003
	end -- 2003
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 2004
	if preserveTIC80 then -- 2005
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 2006
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 2007
		end -- 2006
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 2008
	end -- 2005
	return tostring(header) .. "\n" .. tostring(codes) -- 2009
end -- 2003
local compileFileAsync -- 2011
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 2011
	if projectRoot == nil then -- 2011
		projectRoot = nil -- 2011
	end -- 2011
	local file = inputFile -- 2012
	local searchPath -- 2013
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2013
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2014
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 2017
	elseif not Content:isAbsolutePath(inputFile) then -- 2018
		searchPath = "" -- 2019
	else -- 2020
		local dir = getProjectDirFromFile(inputFile) -- 2020
		if dir then -- 2020
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2021
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 2025
		else -- 2027
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2027
			searchPath = "" -- 2030
		end -- 2020
	end -- 2013
	local outputFile = Path:replaceExt(inputFile, "lua") -- 2031
	local yueext = yue.options.extension -- 2032
	local resultCodes = nil -- 2033
	local resultError = nil -- 2034
	do -- 2035
		local _exp_0 = Path:getExt(inputFile) -- 2035
		if yueext == _exp_0 then -- 2035
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 2036
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 2037
				if not codes then -- 2038
					resultError = err -- 2039
					return -- 2040
				end -- 2038
				local extraGlobal -- 2041
				if isTIC80 then -- 2041
					extraGlobal = tic80APIs -- 2041
				else -- 2041
					extraGlobal = nil -- 2041
				end -- 2041
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 2042
				if not success then -- 2043
					local diagnostics -- 2044
					do -- 2044
						local _accum_0 = { } -- 2044
						local _len_0 = 1 -- 2044
						for _index_0 = 1, #message do -- 2044
							local _des_0 = message[_index_0] -- 2044
							local name, row, column = _des_0[1], _des_0[2], _des_0[3] -- 2044
							_accum_0[_len_0] = tostring(file) .. ":" .. tostring(row) .. ":" .. tostring(column) .. ": unknown global '" .. tostring(name) .. "'" -- 2045
							_len_0 = _len_0 + 1 -- 2045
						end -- 2044
						diagnostics = _accum_0 -- 2044
					end -- 2044
					resultError = table.concat(diagnostics, "\n") -- 2046
					return -- 2047
				end -- 2043
				if codes == "" then -- 2048
					resultCodes = "" -- 2049
					return nil -- 2050
				end -- 2048
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 2051
				return resultCodes -- 2052
			end, function(success) -- 2037
				if not success then -- 2053
					if resultCodes == nil then -- 2054
						resultCodes = false -- 2055
					elseif resultCodes ~= "" then -- 2056
						resultCodes = false -- 2057
						resultError = "failed to save " .. tostring(outputFile) -- 2058
					end -- 2054
				end -- 2053
			end) -- 2037
		elseif "tl" == _exp_0 then -- 2059
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 2060
			if isTIC80 then -- 2061
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2062
			end -- 2061
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2063
			if codes then -- 2064
				if isTIC80 then -- 2065
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2066
				end -- 2065
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2067
				if not Content:saveAsync(outputFile, resultCodes) then -- 2068
					resultCodes = false -- 2069
					resultError = "failed to save " .. tostring(outputFile) -- 2070
				end -- 2068
			else -- 2072
				resultCodes = false -- 2072
				resultError = err -- 2073
			end -- 2064
		elseif "xml" == _exp_0 then -- 2074
			local codes, err = xml.tolua(sourceCodes) -- 2075
			if codes then -- 2076
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2077
				if not Content:saveAsync(outputFile, resultCodes) then -- 2078
					resultCodes = false -- 2079
					resultError = "failed to save " .. tostring(outputFile) -- 2080
				end -- 2078
			else -- 2082
				resultCodes = false -- 2082
				resultError = err -- 2083
			end -- 2076
		end -- 2035
	end -- 2035
	wait(function() -- 2084
		return resultCodes ~= nil -- 2084
	end) -- 2084
	if resultCodes then -- 2085
		return resultCodes -- 2086
	else -- 2088
		return nil, resultError -- 2088
	end -- 2085
	return nil -- 2011
end -- 2011
HttpServer:postSchedule("/write", function(req) -- 2090
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2091
	local buildSucceeded = false -- 2092
	local _ <close> = setmetatable({ }, { -- 2093
		__close = function() -- 2093
			return finishUpdate(buildSucceeded) -- 2093
		end -- 2093
	}) -- 2093
	do -- 2094
		local _type_0 = type(req) -- 2094
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2094
		if _tab_0 then -- 2094
			local path -- 2094
			do -- 2094
				local _obj_0 = req.body -- 2094
				local _type_1 = type(_obj_0) -- 2094
				if "table" == _type_1 or "userdata" == _type_1 then -- 2094
					path = _obj_0.path -- 2094
				end -- 2094
			end -- 2094
			local content -- 2094
			do -- 2094
				local _obj_0 = req.body -- 2094
				local _type_1 = type(_obj_0) -- 2094
				if "table" == _type_1 or "userdata" == _type_1 then -- 2094
					content = _obj_0.content -- 2094
				end -- 2094
			end -- 2094
			if path ~= nil and content ~= nil then -- 2094
				if Content:saveAsync(path, content) then -- 2095
					do -- 2096
						local _exp_0 = Path:getExt(path) -- 2096
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2096
							if '' == Path:getExt(Path:getName(path)) then -- 2097
								local resultCodes = compileFileAsync(path, content) -- 2098
								buildSucceeded = resultCodes ~= nil -- 2099
								return { -- 2100
									success = true, -- 2100
									resultCodes = resultCodes -- 2100
								} -- 2100
							end -- 2097
						end -- 2096
					end -- 2096
					buildSucceeded = true -- 2101
					return { -- 2102
						success = true -- 2102
					} -- 2102
				end -- 2095
			end -- 2094
		end -- 2094
	end -- 2094
	return { -- 2090
		success = false -- 2090
	} -- 2090
end) -- 2090
local getWaProjectDirFromFile = nil -- 2104
HttpServer:postSchedule("/build", function(req) -- 2106
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2107
	local buildSucceeded = false -- 2108
	local _ <close> = setmetatable({ }, { -- 2109
		__close = function() -- 2109
			return finishUpdate(buildSucceeded) -- 2109
		end -- 2109
	}) -- 2109
	do -- 2110
		local _type_0 = type(req) -- 2110
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2110
		if _tab_0 then -- 2110
			local path -- 2110
			do -- 2110
				local _obj_0 = req.body -- 2110
				local _type_1 = type(_obj_0) -- 2110
				if "table" == _type_1 or "userdata" == _type_1 then -- 2110
					path = _obj_0.path -- 2110
				end -- 2110
			end -- 2110
			if path ~= nil then -- 2110
				local projectRoot = req.body.projectRoot -- 2111
				if Content:isdir(path) then -- 2112
					local projDir = getWaProjectDirFromFile(path) -- 2113
					if projDir then -- 2113
						local message = Wasm:buildWaAsync(projDir) -- 2114
						if message == "" then -- 2115
							return { -- 2116
								success = true -- 2116
							} -- 2116
						else -- 2118
							return { -- 2118
								success = false, -- 2118
								message = message -- 2118
							} -- 2118
						end -- 2115
					end -- 2113
				end -- 2112
				local _exp_0 = Path:getExt(path) -- 2119
				if "gd" == _exp_0 or "tscn" == _exp_0 or "tres" == _exp_0 or "gdshader" == _exp_0 or "gdshaderinc" == _exp_0 then -- 2120
					local content = Content:loadAsync(path) -- 2121
					if content then -- 2121
						local result = godotCheckAsync(path, content, false) -- 2122
						buildSucceeded = result.success and not result.skipped -- 2123
						return { -- 2124
							success = buildSucceeded, -- 2124
							resultCodes = "", -- 2124
							info = result.info -- 2124
						} -- 2124
					end -- 2121
				elseif "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2125
					if '' == Path:getExt(Path:getName(path)) then -- 2126
						local content = Content:loadAsync(path) -- 2127
						if content then -- 2127
							local resultCodes, compileError = compileFileAsync(path, content, projectRoot) -- 2128
							if resultCodes then -- 2129
								buildSucceeded = true -- 2130
								return { -- 2131
									success = true, -- 2131
									resultCodes = resultCodes -- 2131
								} -- 2131
							end -- 2129
							return { -- 2132
								success = false, -- 2132
								message = compileError or "Compilation failed" -- 2132
							} -- 2132
						end -- 2127
					end -- 2126
				elseif "wa" == _exp_0 then -- 2133
					local projDir = getWaProjectDirFromFile(path) -- 2134
					if projDir then -- 2134
						local message = Wasm:buildWaAsync(projDir) -- 2135
						if message == "" then -- 2136
							return { -- 2137
								success = true -- 2137
							} -- 2137
						else -- 2139
							return { -- 2139
								success = false, -- 2139
								message = message -- 2139
							} -- 2139
						end -- 2136
					else -- 2141
						return { -- 2141
							success = false, -- 2141
							message = 'Wa file needs a project' -- 2141
						} -- 2141
					end -- 2134
				end -- 2119
			end -- 2110
		end -- 2110
	end -- 2110
	return { -- 2106
		success = false -- 2106
	} -- 2106
end) -- 2106
local extentionLevels = { -- 2144
	vs = 2, -- 2144
	bl = 2, -- 2145
	ts = 1, -- 2146
	tsx = 1, -- 2147
	tl = 1, -- 2148
	yue = 1, -- 2149
	xml = 1, -- 2150
	lua = 0 -- 2151
} -- 2143
local visitAssets -- 2153
visitAssets = function(path, workspace, builtin, recursive) -- 2153
	if recursive == nil then -- 2153
		recursive = true -- 2153
	end -- 2153
	local children = nil -- 2154
	local dirs = Content:getDirs(path) -- 2155
	for _index_0 = 1, #dirs do -- 2156
		local dir = dirs[_index_0] -- 2156
		if workspace then -- 2157
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or ".godot" == dir or ".native-export" == dir or "node_modules" == dir) then -- 2158
				goto _continue_0 -- 2159
			end -- 2158
		elseif dir == ".git" or dir == ".godot" then -- 2160
			goto _continue_0 -- 2161
		end -- 2157
		if not children then -- 2162
			children = { } -- 2162
		end -- 2162
		local dirPath = Path(path, dir) -- 2163
		if recursive then -- 2164
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2165
		else -- 2167
			children[#children + 1] = { -- 2168
				key = dirPath, -- 2168
				dir = true, -- 2169
				title = dir, -- 2170
				builtin = builtin, -- 2171
				isLeaf = false -- 2172
			} -- 2167
		end -- 2164
		::_continue_0:: -- 2157
	end -- 2156
	local files = Content:getFiles(path) -- 2174
	local names = { } -- 2175
	for _index_0 = 1, #files do -- 2176
		local file = files[_index_0] -- 2176
		if (".DS_Store" == file) then -- 2177
			goto _continue_1 -- 2178
		end -- 2177
		local ext = Path:getExt(file) -- 2179
		if not extentionLevels[ext] then -- 2180
			names[file] = "" -- 2181
			goto _continue_1 -- 2182
		end -- 2180
		local name = Path:getName(file) -- 2183
		ext = names[name] -- 2184
		if ext then -- 2184
			local lv1 -- 2185
			do -- 2185
				local _exp_0 = extentionLevels[ext] -- 2185
				if _exp_0 ~= nil then -- 2185
					lv1 = _exp_0 -- 2185
				else -- 2185
					lv1 = -1 -- 2185
				end -- 2185
			end -- 2185
			ext = Path:getExt(file) -- 2186
			local lv2 -- 2187
			do -- 2187
				local _exp_0 = extentionLevels[ext] -- 2187
				if _exp_0 ~= nil then -- 2187
					lv2 = _exp_0 -- 2187
				else -- 2187
					lv2 = -1 -- 2187
				end -- 2187
			end -- 2187
			if lv2 > lv1 then -- 2188
				names[name] = ext -- 2189
			elseif lv2 == lv1 then -- 2190
				names[name .. '.' .. ext] = "" -- 2191
			end -- 2188
		else -- 2193
			ext = Path:getExt(file) -- 2193
			if not extentionLevels[ext] then -- 2194
				names[file] = "" -- 2195
			else -- 2197
				names[name] = ext -- 2197
			end -- 2194
		end -- 2184
		::_continue_1:: -- 2177
	end -- 2176
	do -- 2198
		local _accum_0 = { } -- 2198
		local _len_0 = 1 -- 2198
		for name, ext in pairs(names) do -- 2198
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2198
			_len_0 = _len_0 + 1 -- 2198
		end -- 2198
		files = _accum_0 -- 2198
	end -- 2198
	for _index_0 = 1, #files do -- 2199
		local file = files[_index_0] -- 2199
		if not children then -- 2200
			children = { } -- 2200
		end -- 2200
		children[#children + 1] = { -- 2202
			key = Path(path, file), -- 2202
			dir = false, -- 2203
			title = file, -- 2204
			builtin = builtin -- 2205
		} -- 2201
	end -- 2199
	if children then -- 2207
		table.sort(children, function(a, b) -- 2208
			if a.dir == b.dir then -- 2209
				return a.title < b.title -- 2210
			else -- 2212
				return a.dir -- 2212
			end -- 2209
		end) -- 2208
	end -- 2207
	return { -- 2214
		key = path, -- 2214
		dir = true, -- 2215
		title = Path:getFilename(path), -- 2216
		builtin = builtin, -- 2217
		isLeaf = not children, -- 2218
		children = children -- 2219
	} -- 2213
end -- 2153
HttpServer:post("/assets/children", function(req) -- 2222
	do -- 2223
		local _type_0 = type(req) -- 2223
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2223
		if _tab_0 then -- 2223
			local path -- 2223
			do -- 2223
				local _obj_0 = req.body -- 2223
				local _type_1 = type(_obj_0) -- 2223
				if "table" == _type_1 or "userdata" == _type_1 then -- 2223
					path = _obj_0.path -- 2223
				end -- 2223
			end -- 2223
			if path ~= nil then -- 2223
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2224
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2225
					return { -- 2225
						success = false -- 2225
					} -- 2225
				end -- 2225
				local node = visitAssets(path, workspace, builtin, false) -- 2226
				return { -- 2227
					success = true, -- 2227
					children = node.children or { } -- 2227
				} -- 2227
			end -- 2223
		end -- 2223
	end -- 2223
	return { -- 2222
		success = false -- 2222
	} -- 2222
end) -- 2222
HttpServer:post("/assets/files", function(req) -- 2229
	do -- 2230
		local _type_0 = type(req) -- 2230
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2230
		if _tab_0 then -- 2230
			local path -- 2230
			do -- 2230
				local _obj_0 = req.body -- 2230
				local _type_1 = type(_obj_0) -- 2230
				if "table" == _type_1 or "userdata" == _type_1 then -- 2230
					path = _obj_0.path -- 2230
				end -- 2230
			end -- 2230
			if path ~= nil then -- 2230
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2231
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2232
				if not (workspace or builtin) then -- 2233
					return { -- 2233
						success = false -- 2233
					} -- 2233
				end -- 2233
				if not (Content:exist(path) and Content:isdir(path)) then -- 2234
					return { -- 2234
						success = false -- 2234
					} -- 2234
				end -- 2234
				local globs = { -- 2235
					"**", -- 2235
					"!**/.DS_Store", -- 2235
					"!**/.godot/**" -- 2235
				} -- 2235
				if workspace then -- 2236
					globs = { -- 2238
						"**", -- 2238
						"!**/.DS_Store", -- 2238
						"!**/.upload/**", -- 2239
						"!**/.download/**", -- 2239
						"!**/.www/**", -- 2240
						"!**/.build/**", -- 2240
						"!**/.git/**", -- 2241
						"!**/.cache/**", -- 2241
						"!**/.godot/**", -- 2242
						"!**/node_modules/**" -- 2243
					} -- 2237
				end -- 2236
				local files -- 2245
				do -- 2245
					local _accum_0 = { } -- 2245
					local _len_0 = 1 -- 2245
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2245
					for _index_0 = 1, #_list_0 do -- 2245
						local file = _list_0[_index_0] -- 2245
						_accum_0[_len_0] = Path(path, file) -- 2245
						_len_0 = _len_0 + 1 -- 2245
					end -- 2245
					files = _accum_0 -- 2245
				end -- 2245
				return { -- 2246
					success = true, -- 2246
					files = files -- 2246
				} -- 2246
			end -- 2230
		end -- 2230
	end -- 2230
	return { -- 2229
		success = false -- 2229
	} -- 2229
end) -- 2229
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2287
	local _tab_0 = { -- 2287
		{ -- 2288
			key = Path(Content.assetPath), -- 2288
			dir = true, -- 2289
			builtin = true, -- 2290
			title = zh and "内置资源" or "Built-in", -- 2291
			children = builtinChildren -- 2292
		} -- 2287
	} -- 2294
	local _obj_0 = workspace.children or { } -- 2294
	local _idx_0 = #_tab_0 + 1 -- 2294
	for _index_0 = 1, #_obj_0 do -- 2294
		local _value_0 = _obj_0[_index_0] -- 2294
		_tab_0[_idx_0] = _value_0 -- 2294
		_idx_0 = _idx_0 + 1 -- 2294
	end -- 2294
	return _tab_0 -- 2287
end -- 2287
HttpServer:post("/assets", function() -- 2248
	local Entry = require("Script.Dev.Entry") -- 2249
	local engineDev = Entry.getEngineDev() -- 2250
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2251
	local zh = (App.locale:match("^zh") ~= nil) -- 2252
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2253
	readme.title = zh and "说明文档" or "Readme" -- 2254
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2255
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2256
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2257
	tools.title = zh and "开发工具" or "Tools" -- 2258
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2259
	font.title = zh and "字体" or "Font" -- 2260
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2261
	lib.title = zh and "程序库" or "Lib" -- 2262
	if engineDev then -- 2263
		local _list_0 = lib.children -- 2264
		for _index_0 = 1, #_list_0 do -- 2264
			local child = _list_0[_index_0] -- 2264
			if not (child.title == "Dora") then -- 2265
				goto _continue_0 -- 2265
			end -- 2265
			local title = zh and "zh-Hans" or "en" -- 2266
			do -- 2267
				local _accum_0 = { } -- 2267
				local _len_0 = 1 -- 2267
				local _list_1 = child.children -- 2267
				for _index_1 = 1, #_list_1 do -- 2267
					local c = _list_1[_index_1] -- 2267
					if c.title ~= title then -- 2267
						_accum_0[_len_0] = c -- 2267
						_len_0 = _len_0 + 1 -- 2267
					end -- 2267
				end -- 2267
				child.children = _accum_0 -- 2267
			end -- 2267
			break -- 2268
			::_continue_0:: -- 2265
		end -- 2264
	else -- 2270
		local _accum_0 = { } -- 2270
		local _len_0 = 1 -- 2270
		local _list_0 = lib.children -- 2270
		for _index_0 = 1, #_list_0 do -- 2270
			local child = _list_0[_index_0] -- 2270
			if child.title ~= "Dora" then -- 2270
				_accum_0[_len_0] = child -- 2270
				_len_0 = _len_0 + 1 -- 2270
			end -- 2270
		end -- 2270
		lib.children = _accum_0 -- 2270
	end -- 2263
	local builtinChildren = { -- 2271
		readme, -- 2271
		apiDoc, -- 2271
		tools, -- 2271
		font, -- 2271
		lib -- 2271
	} -- 2271
	if engineDev then -- 2272
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2273
		do -- 2274
			local _obj_0 = dev.children -- 2274
			_obj_0[#_obj_0 + 1] = { -- 2275
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2275
				dir = false, -- 2276
				builtin = true, -- 2277
				title = "init.yue" -- 2278
			} -- 2274
		end -- 2274
		builtinChildren[#builtinChildren + 1] = dev -- 2280
	end -- 2272
	return { -- 2282
		key = Content.writablePath, -- 2282
		dir = true, -- 2283
		root = true, -- 2284
		title = "Assets", -- 2285
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2286
	} -- 2281
end) -- 2248
HttpServer:post("/entry/list", function(req) -- 2298
	local Entry = require("Script.Dev.Entry") -- 2299
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2300
	res.success = true -- 2301
	return res -- 2302
end) -- 2298
HttpServer:post("/run/status", function() -- 2304
	local Entry = require("Script.Dev.Entry") -- 2305
	return Entry.getCurrentEntryStatus() -- 2306
end) -- 2304
HttpServer:postSchedule("/run", function(req) -- 2308
	do -- 2309
		local _type_0 = type(req) -- 2309
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2309
		if _tab_0 then -- 2309
			local file -- 2309
			do -- 2309
				local _obj_0 = req.body -- 2309
				local _type_1 = type(_obj_0) -- 2309
				if "table" == _type_1 or "userdata" == _type_1 then -- 2309
					file = _obj_0.file -- 2309
				end -- 2309
			end -- 2309
			local asProj -- 2309
			do -- 2309
				local _obj_0 = req.body -- 2309
				local _type_1 = type(_obj_0) -- 2309
				if "table" == _type_1 or "userdata" == _type_1 then -- 2309
					asProj = _obj_0.asProj -- 2309
				end -- 2309
			end -- 2309
			if file ~= nil and asProj ~= nil then -- 2309
				if not Content:isAbsolutePath(file) then -- 2310
					local devFile = Path(Content.writablePath, file) -- 2311
					if Content:exist(devFile) then -- 2312
						file = devFile -- 2312
					end -- 2312
				end -- 2310
				local Entry = require("Script.Dev.Entry") -- 2313
				local workDir -- 2314
				if asProj then -- 2315
					local projectRoot = req.body.projectRoot -- 2316
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2317
						workDir = projectRoot -- 2318
					else -- 2320
						workDir = getProjectDirFromFile(file) -- 2320
					end -- 2317
					if workDir then -- 2321
						Entry.allClear() -- 2322
						local target = Path(workDir, "init") -- 2323
						local runId = Entry.getCurrentEntryStatus().runId + 1 -- 2324
						local success, err = Entry.enterEntryAsync({ -- 2325
							entryName = "Project", -- 2325
							fileName = target, -- 2325
							workDir = workDir, -- 2325
							projectRoot = workDir, -- 2325
							runKind = "project" -- 2325
						}) -- 2325
						if success and not err and req.body.waitForFrame == true then -- 2326
							local RunTransition = require("Script.Dev.RunTransition") -- 2327
							success, err = RunTransition.waitForFrameAsync(Entry, runId, Content:exist(Path(workDir, "project.godot"))) -- 2328
						end -- 2326
						target = Path:getName(Path:getPath(target)) -- 2329
						return { -- 2330
							success = success, -- 2330
							target = target, -- 2330
							err = err -- 2330
						} -- 2330
					end -- 2321
				else -- 2332
					workDir = getProjectDirFromFile(file) -- 2332
					if not workDir and Path:getExt(file) == "wasm" then -- 2333
						local parent = Path:getPath(file) -- 2334
						if Content:exist(Path(parent, "wa.mod")) then -- 2335
							workDir = parent -- 2336
						end -- 2335
					end -- 2333
				end -- 2315
				Entry.allClear() -- 2337
				file = Path:replaceExt(file, "") -- 2338
				local entry = { -- 2340
					entryName = Path:getName(file), -- 2340
					fileName = file, -- 2341
					runKind = "file" -- 2342
				} -- 2339
				if workDir then -- 2343
					entry.workDir = workDir -- 2344
					entry.projectRoot = workDir -- 2345
				end -- 2343
				local runId = Entry.getCurrentEntryStatus().runId + 1 -- 2346
				local success, err = Entry.enterEntryAsync(entry) -- 2347
				if success and not err and req.body.waitForFrame == true then -- 2348
					local RunTransition = require("Script.Dev.RunTransition") -- 2349
					success, err = RunTransition.waitForFrameAsync(Entry, runId, workDir and Content:exist(Path(workDir, "project.godot"))) -- 2350
				end -- 2348
				return { -- 2351
					success = success, -- 2351
					err = err -- 2351
				} -- 2351
			end -- 2309
		end -- 2309
	end -- 2309
	return { -- 2308
		success = false -- 2308
	} -- 2308
end) -- 2308
local _anon_func_7 = function(result) -- 2393
	if result.success then -- 2393
		return nil -- 2393
	else -- 2393
		return "PREVIEW_FAILED" -- 2393
	end -- 2393
end -- 2393
HttpServer:postSchedule("/agent/preview", function(req) -- 2353
	local releaseAgent = AgentHost.acquire() -- 2354
	local _ <close> = setmetatable({ }, { -- 2355
		__close = function() -- 2355
			return releaseAgent() -- 2355
		end -- 2355
	}) -- 2355
	do -- 2356
		local _type_0 = type(req) -- 2356
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2356
		if _tab_0 then -- 2356
			local projectRoot -- 2356
			do -- 2356
				local _obj_0 = req.body -- 2356
				local _type_1 = type(_obj_0) -- 2356
				if "table" == _type_1 or "userdata" == _type_1 then -- 2356
					projectRoot = _obj_0.projectRoot -- 2356
				end -- 2356
			end -- 2356
			if projectRoot ~= nil then -- 2356
				if not getProjectSourceRoot(projectRoot) then -- 2357
					return { -- 2357
						success = false, -- 2357
						code = "INVALID_PROJECT", -- 2357
						message = "projectRoot must be an existing absolute directory" -- 2357
					} -- 2357
				end -- 2357
				local entryFile = req.body.entry or "init.lua" -- 2358
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2359
					return { -- 2359
						success = false, -- 2359
						code = "INVALID_ENTRY", -- 2359
						message = "entry must be a non-empty project-relative path" -- 2359
					} -- 2359
				end -- 2359
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2360
					0.5 -- 2360
				} -- 2360
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2361
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2362
					return { -- 2362
						success = false, -- 2362
						code = "INVALID_QUEUE_TIMEOUT", -- 2362
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2362
					} -- 2362
				end -- 2362
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2363
				local AgentOperation = require("Agent.Tool.Operation") -- 2364
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2365
				local requestId = AgentOperation.createOperationId() -- 2366
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2367
				if not enqueued.success then -- 2368
					return { -- 2368
						success = false, -- 2368
						code = "ENTRY_QUEUE_REJECTED", -- 2368
						message = enqueued.message -- 2368
					} -- 2368
				end -- 2368
				local queuedAt = App.runningTime -- 2369
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2370
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2371
						local state = agentEntryRunQueue:get(requestId) -- 2372
						agentEntryRunQueue:cancel(requestId) -- 2373
						return { -- 2375
							success = false, -- 2375
							code = "ENTRY_QUEUE_TIMEOUT", -- 2376
							message = "timed out waiting for the Dora entry runtime", -- 2377
							requestId = requestId, -- 2378
							queuePosition = state.position -- 2379
						} -- 2374
					end -- 2371
					sleep() -- 2380
				end -- 2370
				local queueWaitSeconds = App.runningTime - queuedAt -- 2381
				local _ <close> = setmetatable({ }, { -- 2382
					__close = function() -- 2382
						return agentEntryRunQueue:release(requestId) -- 2382
					end -- 2382
				}) -- 2382
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2383
				local Entry = require("Script.Dev.Entry") -- 2384
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2386
					workDir = projectRoot, -- 2386
					operationId = requestId, -- 2387
					print = function() end -- 2388
				}, Entry) -- 2385
				local result = preview({ -- 2390
					entry = entryFile, -- 2390
					captureAtSeconds = captureAtSeconds -- 2390
				}) -- 2390
				return { -- 2392
					success = result.success, -- 2392
					code = _anon_func_7(result), -- 2393
					message = result.message, -- 2394
					requestId = requestId, -- 2395
					queueWaitSeconds = queueWaitSeconds, -- 2396
					interruptedUserRun = result.interruptedUserRun, -- 2397
					files = result.files, -- 2398
					frames = result.frames -- 2399
				} -- 2391
			end -- 2356
		end -- 2356
	end -- 2356
	return { -- 2353
		success = false, -- 2353
		message = "invalid call" -- 2353
	} -- 2353
end) -- 2353
HttpServer:postSchedule("/agent/command", function(req) -- 2401
	local releaseAgent = AgentHost.acquire() -- 2402
	local _ <close> = setmetatable({ }, { -- 2403
		__close = function() -- 2403
			return releaseAgent() -- 2403
		end -- 2403
	}) -- 2403
	do -- 2404
		local _type_0 = type(req) -- 2404
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2404
		if _tab_0 then -- 2404
			local body = req.body -- 2404
			if body ~= nil then -- 2404
				local projectRoot = body.projectRoot -- 2405
				if not getProjectSourceRoot(projectRoot) then -- 2406
					return { -- 2406
						success = false, -- 2406
						code = "INVALID_PROJECT", -- 2406
						message = "projectRoot must be an existing absolute directory" -- 2406
					} -- 2406
				end -- 2406
				local AgentValidation = require("Agent.Tool.Validation") -- 2407
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2408
				if not validated.success then -- 2409
					return { -- 2409
						success = false, -- 2409
						code = "INVALID_COMMAND", -- 2409
						message = validated.message -- 2409
					} -- 2409
				end -- 2409
				local input = validated.value -- 2410
				local AgentCommand = require("Agent.Tool.Command") -- 2411
				local result = nil -- 2412
				local failure = nil -- 2413
				local promise = AgentCommand.executeCommand({ -- 2415
					workDir = projectRoot, -- 2415
					mode = input.mode, -- 2416
					code = input.code, -- 2417
					command = input.command, -- 2418
					cwd = input.cwd, -- 2419
					timeoutSeconds = input.timeoutSeconds -- 2420
				}) -- 2414
				promise:addCallbacks((function(_, value) -- 2421
					result = value -- 2421
				end), (function(_, err) -- 2421
					failure = tostring(err) -- 2421
				end)) -- 2421
				wait(function() -- 2422
					return result ~= nil or failure ~= nil -- 2422
				end) -- 2422
				if failure then -- 2423
					return { -- 2423
						success = false, -- 2423
						code = "COMMAND_BRIDGE_FAILED", -- 2423
						message = failure -- 2423
					} -- 2423
				end -- 2423
				if not result.success then -- 2424
					result.code = "COMMAND_FAILED" -- 2425
				end -- 2424
				return result -- 2426
			end -- 2404
		end -- 2404
	end -- 2404
	return { -- 2401
		success = false, -- 2401
		code = "INVALID_COMMAND", -- 2401
		message = "invalid call" -- 2401
	} -- 2401
end) -- 2401
HttpServer:postSchedule("/stop", function() -- 2428
	local Entry = require("Script.Dev.Entry") -- 2429
	return { -- 2430
		success = Entry.stop() -- 2430
	} -- 2430
end) -- 2428
local minifyAsync -- 2432
minifyAsync = function(sourcePath, minifyPath) -- 2432
	if not Content:exist(sourcePath) then -- 2433
		return -- 2433
	end -- 2433
	local Entry = require("Script.Dev.Entry") -- 2434
	local errors = { } -- 2435
	local files = Entry.getAllFiles(sourcePath, { -- 2436
		"lua" -- 2436
	}, true) -- 2436
	do -- 2437
		local _accum_0 = { } -- 2437
		local _len_0 = 1 -- 2437
		for _index_0 = 1, #files do -- 2437
			local file = files[_index_0] -- 2437
			if file:sub(1, 1) ~= '.' then -- 2437
				_accum_0[_len_0] = file -- 2437
				_len_0 = _len_0 + 1 -- 2437
			end -- 2437
		end -- 2437
		files = _accum_0 -- 2437
	end -- 2437
	local paths -- 2438
	do -- 2438
		local _tbl_0 = { } -- 2438
		for _index_0 = 1, #files do -- 2438
			local file = files[_index_0] -- 2438
			_tbl_0[Path:getPath(file)] = true -- 2438
		end -- 2438
		paths = _tbl_0 -- 2438
	end -- 2438
	for path in pairs(paths) do -- 2439
		Content:mkdir(Path(minifyPath, path)) -- 2439
	end -- 2439
	local _ <close> = setmetatable({ }, { -- 2440
		__close = function() -- 2440
			package.loaded["luaminify.FormatMini"] = nil -- 2441
			package.loaded["luaminify.ParseLua"] = nil -- 2442
			package.loaded["luaminify.Scope"] = nil -- 2443
			package.loaded["luaminify.Util"] = nil -- 2444
		end -- 2440
	}) -- 2440
	local FormatMini -- 2445
	do -- 2445
		local _obj_0 = require("luaminify") -- 2445
		FormatMini = _obj_0.FormatMini -- 2445
	end -- 2445
	local fileCount = #files -- 2446
	local count = 0 -- 2447
	for _index_0 = 1, #files do -- 2448
		local file = files[_index_0] -- 2448
		thread(function() -- 2449
			local _ <close> = setmetatable({ }, { -- 2450
				__close = function() -- 2450
					count = count + 1 -- 2450
				end -- 2450
			}) -- 2450
			local input = Path(sourcePath, file) -- 2451
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2452
			if Content:exist(input) then -- 2453
				local sourceCodes = Content:loadAsync(input) -- 2454
				local res, err = FormatMini(sourceCodes) -- 2455
				if res then -- 2456
					Content:saveAsync(output, res) -- 2457
					return print("Minify " .. tostring(file)) -- 2458
				else -- 2460
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2460
				end -- 2456
			else -- 2462
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2462
			end -- 2453
		end) -- 2449
		sleep() -- 2463
	end -- 2448
	wait(function() -- 2464
		return count == fileCount -- 2464
	end) -- 2464
	if #errors > 0 then -- 2465
		print(table.concat(errors, '\n')) -- 2466
	end -- 2465
	print("Obfuscation done.") -- 2467
	return files -- 2468
end -- 2432
local zipping = false -- 2470
HttpServer:postSchedule("/zip", function(req) -- 2472
	do -- 2473
		local _type_0 = type(req) -- 2473
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2473
		if _tab_0 then -- 2473
			local path -- 2473
			do -- 2473
				local _obj_0 = req.body -- 2473
				local _type_1 = type(_obj_0) -- 2473
				if "table" == _type_1 or "userdata" == _type_1 then -- 2473
					path = _obj_0.path -- 2473
				end -- 2473
			end -- 2473
			local zipFile -- 2473
			do -- 2473
				local _obj_0 = req.body -- 2473
				local _type_1 = type(_obj_0) -- 2473
				if "table" == _type_1 or "userdata" == _type_1 then -- 2473
					zipFile = _obj_0.zipFile -- 2473
				end -- 2473
			end -- 2473
			local obfuscated -- 2473
			do -- 2473
				local _obj_0 = req.body -- 2473
				local _type_1 = type(_obj_0) -- 2473
				if "table" == _type_1 or "userdata" == _type_1 then -- 2473
					obfuscated = _obj_0.obfuscated -- 2473
				end -- 2473
			end -- 2473
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2473
				if zipping then -- 2474
					goto failed -- 2474
				end -- 2474
				zipping = true -- 2475
				local _ <close> = setmetatable({ }, { -- 2476
					__close = function() -- 2476
						zipping = false -- 2476
					end -- 2476
				}) -- 2476
				if not Content:exist(path) then -- 2477
					goto failed -- 2477
				end -- 2477
				Content:mkdir(Path:getPath(zipFile)) -- 2478
				if obfuscated then -- 2479
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2480
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2481
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2482
					Content:remove(scriptPath) -- 2483
					Content:remove(obfuscatedPath) -- 2484
					Content:remove(tempPath) -- 2485
					Content:mkdir(scriptPath) -- 2486
					Content:mkdir(obfuscatedPath) -- 2487
					Content:mkdir(tempPath) -- 2488
					if not Content:copyAsync(path, tempPath) then -- 2489
						goto failed -- 2489
					end -- 2489
					local Entry = require("Script.Dev.Entry") -- 2490
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2491
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2492
						"tl", -- 2492
						"yue", -- 2492
						"lua", -- 2492
						"ts", -- 2492
						"tsx", -- 2492
						"vs", -- 2492
						"bl", -- 2492
						"xml", -- 2492
						"wa", -- 2492
						"mod" -- 2492
					}, true) -- 2492
					for _index_0 = 1, #scriptFiles do -- 2493
						local file = scriptFiles[_index_0] -- 2493
						Content:remove(Path(tempPath, file)) -- 2494
					end -- 2493
					for _index_0 = 1, #luaFiles do -- 2495
						local file = luaFiles[_index_0] -- 2495
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2496
					end -- 2495
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2497
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2498
					end) then -- 2497
						goto failed -- 2497
					end -- 2497
					return { -- 2499
						success = true -- 2499
					} -- 2499
				else -- 2501
					return { -- 2501
						success = Content:zipAsync(path, zipFile, function(file) -- 2501
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2502
						end) -- 2501
					} -- 2501
				end -- 2479
			end -- 2473
		end -- 2473
	end -- 2473
	::failed:: -- 2503
	return { -- 2472
		success = false -- 2472
	} -- 2472
end) -- 2472
HttpServer:postSchedule("/unzip", function(req) -- 2505
	do -- 2506
		local _type_0 = type(req) -- 2506
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2506
		if _tab_0 then -- 2506
			local zipFile -- 2506
			do -- 2506
				local _obj_0 = req.body -- 2506
				local _type_1 = type(_obj_0) -- 2506
				if "table" == _type_1 or "userdata" == _type_1 then -- 2506
					zipFile = _obj_0.zipFile -- 2506
				end -- 2506
			end -- 2506
			local path -- 2506
			do -- 2506
				local _obj_0 = req.body -- 2506
				local _type_1 = type(_obj_0) -- 2506
				if "table" == _type_1 or "userdata" == _type_1 then -- 2506
					path = _obj_0.path -- 2506
				end -- 2506
			end -- 2506
			if zipFile ~= nil and path ~= nil then -- 2506
				return { -- 2507
					success = Content:unzipAsync(zipFile, path, function(file) -- 2507
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2508
					end) -- 2507
				} -- 2507
			end -- 2506
		end -- 2506
	end -- 2506
	return { -- 2505
		success = false -- 2505
	} -- 2505
end) -- 2505
HttpServer:post("/editing-info", function(req) -- 2510
	local Entry = require("Script.Dev.Entry") -- 2511
	local config = Entry.getConfig() -- 2512
	local _type_0 = type(req) -- 2513
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2513
	local _match_0 = false -- 2513
	if _tab_0 then -- 2513
		local editingInfo -- 2513
		do -- 2513
			local _obj_0 = req.body -- 2513
			local _type_1 = type(_obj_0) -- 2513
			if "table" == _type_1 or "userdata" == _type_1 then -- 2513
				editingInfo = _obj_0.editingInfo -- 2513
			end -- 2513
		end -- 2513
		if editingInfo ~= nil then -- 2513
			_match_0 = true -- 2513
			config.editingInfo = editingInfo -- 2514
			return { -- 2515
				success = true -- 2515
			} -- 2515
		end -- 2513
	end -- 2513
	if not _match_0 then -- 2513
		if not (config.editingInfo ~= nil) then -- 2517
			local folder -- 2518
			if App.locale:match('^zh') then -- 2518
				folder = 'zh-Hans' -- 2518
			else -- 2518
				folder = 'en' -- 2518
			end -- 2518
			config.editingInfo = json.encode({ -- 2520
				index = 0, -- 2520
				files = { -- 2522
					{ -- 2523
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2523
						title = "welcome.md" -- 2524
					} -- 2522
				} -- 2521
			}) -- 2519
		end -- 2517
		return { -- 2528
			success = true, -- 2528
			editingInfo = config.editingInfo -- 2528
		} -- 2528
	end -- 2513
end) -- 2510
HttpServer:post("/command", function(req) -- 2530
	do -- 2531
		local _type_0 = type(req) -- 2531
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2531
		if _tab_0 then -- 2531
			local code -- 2531
			do -- 2531
				local _obj_0 = req.body -- 2531
				local _type_1 = type(_obj_0) -- 2531
				if "table" == _type_1 or "userdata" == _type_1 then -- 2531
					code = _obj_0.code -- 2531
				end -- 2531
			end -- 2531
			local log -- 2531
			do -- 2531
				local _obj_0 = req.body -- 2531
				local _type_1 = type(_obj_0) -- 2531
				if "table" == _type_1 or "userdata" == _type_1 then -- 2531
					log = _obj_0.log -- 2531
				end -- 2531
			end -- 2531
			if code ~= nil and log ~= nil then -- 2531
				emit("AppCommand", code, log) -- 2532
				return { -- 2533
					success = true -- 2533
				} -- 2533
			end -- 2531
		end -- 2531
	end -- 2531
	return { -- 2530
		success = false -- 2530
	} -- 2530
end) -- 2530
HttpServer:post("/log/save", function() -- 2535
	local folder = ".download" -- 2536
	local fullLogFile = "dora_full_logs.txt" -- 2537
	local fullFolder = Path(Content.writablePath, folder) -- 2538
	Content:mkdir(fullFolder) -- 2539
	local logPath = Path(fullFolder, fullLogFile) -- 2540
	if App:saveLog(logPath) then -- 2541
		return { -- 2542
			success = true, -- 2542
			path = Path(folder, fullLogFile) -- 2542
		} -- 2542
	end -- 2541
	return { -- 2535
		success = false -- 2535
	} -- 2535
end) -- 2535
local tailLines -- 2544
tailLines = function(text, count) -- 2544
	local lines = { } -- 2545
	text = text:gsub("\r\n", "\n") -- 2546
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2547
		lines[#lines + 1] = line -- 2548
	end -- 2547
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2549
		table.remove(lines) -- 2550
	end -- 2549
	local start = math.max(1, #lines - count + 1) -- 2551
	local out = { } -- 2552
	for i = start, #lines do -- 2553
		out[#out + 1] = lines[i] -- 2554
	end -- 2553
	return table.concat(out, "\n") -- 2555
end -- 2544
HttpServer:post("/log", function(req) -- 2557
	local count = 100 -- 2558
	if req and req.body and req.body.count ~= nil then -- 2559
		count = req.body.count -- 2560
	end -- 2559
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2561
		return { -- 2562
			success = false, -- 2562
			message = "count must be a positive integer" -- 2562
		} -- 2562
	end -- 2561
	local folder = ".download" -- 2563
	local fullLogFile = "dora_full_logs.txt" -- 2564
	local fullFolder = Path(Content.writablePath, folder) -- 2565
	Content:mkdir(fullFolder) -- 2566
	local logPath = Path(fullFolder, fullLogFile) -- 2567
	if App:saveLog(logPath) then -- 2568
		local text = Content:load(logPath) -- 2569
		if text then -- 2570
			return { -- 2571
				success = true, -- 2571
				log = tailLines(text, count) -- 2571
			} -- 2571
		else -- 2573
			return { -- 2573
				success = false, -- 2573
				message = "failed to read log" -- 2573
			} -- 2573
		end -- 2570
	else -- 2575
		return { -- 2575
			success = false, -- 2575
			message = "failed to save log" -- 2575
		} -- 2575
	end -- 2568
	return { -- 2557
		success = false -- 2557
	} -- 2557
end) -- 2557
HttpServer:post("/yarn/check", function(req) -- 2577
	local yarncompile = require("yarncompile") -- 2578
	do -- 2579
		local _type_0 = type(req) -- 2579
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2579
		if _tab_0 then -- 2579
			local code -- 2579
			do -- 2579
				local _obj_0 = req.body -- 2579
				local _type_1 = type(_obj_0) -- 2579
				if "table" == _type_1 or "userdata" == _type_1 then -- 2579
					code = _obj_0.code -- 2579
				end -- 2579
			end -- 2579
			if code ~= nil then -- 2579
				local jsonObject = json.decode(code) -- 2580
				if jsonObject then -- 2580
					local errors = { } -- 2581
					local _list_0 = jsonObject.nodes -- 2582
					for _index_0 = 1, #_list_0 do -- 2582
						local node = _list_0[_index_0] -- 2582
						local title, body = node.title, node.body -- 2583
						local luaCode, err = yarncompile(body) -- 2584
						if not luaCode then -- 2584
							errors[#errors + 1] = title .. ":" .. err -- 2585
						end -- 2584
					end -- 2582
					return { -- 2586
						success = true, -- 2586
						syntaxError = table.concat(errors, "\n\n") -- 2586
					} -- 2586
				end -- 2580
			end -- 2579
		end -- 2579
	end -- 2579
	return { -- 2577
		success = false -- 2577
	} -- 2577
end) -- 2577
HttpServer:post("/yarn/check-file", function(req) -- 2588
	local yarncompile = require("yarncompile") -- 2589
	do -- 2590
		local _type_0 = type(req) -- 2590
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2590
		if _tab_0 then -- 2590
			local code -- 2590
			do -- 2590
				local _obj_0 = req.body -- 2590
				local _type_1 = type(_obj_0) -- 2590
				if "table" == _type_1 or "userdata" == _type_1 then -- 2590
					code = _obj_0.code -- 2590
				end -- 2590
			end -- 2590
			if code ~= nil then -- 2590
				local res, _, err = yarncompile(code, true) -- 2591
				if not res then -- 2591
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2592
					return { -- 2593
						success = false, -- 2593
						message = message, -- 2593
						line = line, -- 2593
						column = column, -- 2593
						node = node -- 2593
					} -- 2593
				end -- 2591
			end -- 2590
		end -- 2590
	end -- 2590
	return { -- 2588
		success = true -- 2588
	} -- 2588
end) -- 2588
getWaProjectDirFromFile = function(file) -- 2595
	local current -- 2596
	if Content:isdir(file) then -- 2596
		current = file -- 2596
	else -- 2596
		current = Path:getPath(file) -- 2596
	end -- 2596
	if current == "" then -- 2597
		return nil -- 2597
	end -- 2597
	repeat -- 2598
		local modPath = Path(current, "wa.mod") -- 2599
		if Content:exist(modPath) then -- 2600
			return current, modPath -- 2601
		end -- 2600
		local parent = Path:getPath(current) -- 2602
		if parent == "" or parent == current then -- 2603
			break -- 2603
		end -- 2603
		current = parent -- 2604
	until false -- 2598
	return nil -- 2606
end -- 2595
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2608
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
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2611
					if not Content:exist(sourceDoraPath) then -- 2612
						return { -- 2613
							success = false, -- 2613
							message = "missing dora template" -- 2613
						} -- 2613
					end -- 2612
					local targetVendorPath = Path(projDir, "vendor") -- 2614
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2615
					if not Content:exist(targetVendorPath) then -- 2616
						if not Content:mkdir(targetVendorPath) then -- 2617
							return { -- 2618
								success = false, -- 2618
								message = "failed to create vendor folder" -- 2618
							} -- 2618
						end -- 2617
					elseif not Content:isdir(targetVendorPath) then -- 2619
						return { -- 2620
							success = false, -- 2620
							message = "vendor path is not a folder" -- 2620
						} -- 2620
					end -- 2616
					if Content:exist(targetDoraPath) then -- 2621
						if not Content:remove(targetDoraPath) then -- 2622
							return { -- 2623
								success = false, -- 2623
								message = "failed to remove old dora" -- 2623
							} -- 2623
						end -- 2622
					end -- 2621
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2624
						return { -- 2625
							success = false, -- 2625
							message = "failed to copy dora" -- 2625
						} -- 2625
					end -- 2624
					return { -- 2626
						success = true -- 2626
					} -- 2626
				else -- 2628
					return { -- 2628
						success = false, -- 2628
						message = 'Wa file needs a project' -- 2628
					} -- 2628
				end -- 2610
			end -- 2609
		end -- 2609
	end -- 2609
	return { -- 2608
		success = false, -- 2608
		message = "invalid call" -- 2608
	} -- 2608
end) -- 2608
HttpServer:postSchedule("/wa/build", function(req) -- 2630
	do -- 2631
		local _type_0 = type(req) -- 2631
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2631
		if _tab_0 then -- 2631
			local path -- 2631
			do -- 2631
				local _obj_0 = req.body -- 2631
				local _type_1 = type(_obj_0) -- 2631
				if "table" == _type_1 or "userdata" == _type_1 then -- 2631
					path = _obj_0.path -- 2631
				end -- 2631
			end -- 2631
			if path ~= nil then -- 2631
				local projDir = getWaProjectDirFromFile(path) -- 2632
				if projDir then -- 2632
					local message = Wasm:buildWaAsync(projDir) -- 2633
					if message == "" then -- 2634
						return { -- 2635
							success = true -- 2635
						} -- 2635
					else -- 2637
						return { -- 2637
							success = false, -- 2637
							message = message -- 2637
						} -- 2637
					end -- 2634
				else -- 2639
					return { -- 2639
						success = false, -- 2639
						message = 'Wa file needs a project' -- 2639
					} -- 2639
				end -- 2632
			end -- 2631
		end -- 2631
	end -- 2631
	return { -- 2640
		success = false, -- 2640
		message = 'failed to build' -- 2640
	} -- 2640
end) -- 2630
HttpServer:postSchedule("/wa/format", function(req) -- 2642
	do -- 2643
		local _type_0 = type(req) -- 2643
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2643
		if _tab_0 then -- 2643
			local file -- 2643
			do -- 2643
				local _obj_0 = req.body -- 2643
				local _type_1 = type(_obj_0) -- 2643
				if "table" == _type_1 or "userdata" == _type_1 then -- 2643
					file = _obj_0.file -- 2643
				end -- 2643
			end -- 2643
			if file ~= nil then -- 2643
				local code = Wasm:formatWaAsync(file) -- 2644
				if code == "" then -- 2645
					return { -- 2646
						success = false -- 2646
					} -- 2646
				else -- 2648
					return { -- 2648
						success = true, -- 2648
						code = code -- 2648
					} -- 2648
				end -- 2645
			end -- 2643
		end -- 2643
	end -- 2643
	return { -- 2649
		success = false -- 2649
	} -- 2649
end) -- 2642
HttpServer:postSchedule("/wa/create", function(req) -- 2651
	do -- 2652
		local _type_0 = type(req) -- 2652
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2652
		if _tab_0 then -- 2652
			local path -- 2652
			do -- 2652
				local _obj_0 = req.body -- 2652
				local _type_1 = type(_obj_0) -- 2652
				if "table" == _type_1 or "userdata" == _type_1 then -- 2652
					path = _obj_0.path -- 2652
				end -- 2652
			end -- 2652
			if path ~= nil then -- 2652
				if not Content:exist(Path:getPath(path)) then -- 2653
					return { -- 2654
						success = false, -- 2654
						message = "target path not existed" -- 2654
					} -- 2654
				end -- 2653
				if Content:exist(path) then -- 2655
					return { -- 2656
						success = false, -- 2656
						message = "target project folder existed" -- 2656
					} -- 2656
				end -- 2655
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2657
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2658
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2659
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2660
					return { -- 2663
						success = false, -- 2663
						message = "missing template project" -- 2663
					} -- 2663
				end -- 2660
				if not Content:mkdir(path) then -- 2664
					return { -- 2665
						success = false, -- 2665
						message = "failed to create project folder" -- 2665
					} -- 2665
				end -- 2664
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2666
					Content:remove(path) -- 2667
					return { -- 2668
						success = false, -- 2668
						message = "failed to copy template" -- 2668
					} -- 2668
				end -- 2666
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2669
					Content:remove(path) -- 2670
					return { -- 2671
						success = false, -- 2671
						message = "failed to copy template" -- 2671
					} -- 2671
				end -- 2669
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2672
					Content:remove(path) -- 2673
					return { -- 2674
						success = false, -- 2674
						message = "failed to copy template" -- 2674
					} -- 2674
				end -- 2672
				return { -- 2675
					success = true -- 2675
				} -- 2675
			end -- 2652
		end -- 2652
	end -- 2652
	return { -- 2651
		success = false, -- 2651
		message = "invalid call" -- 2651
	} -- 2651
end) -- 2651
local tsSnapshotGlobs = { -- 2678
	"**/*.ts", -- 2678
	"**/*.tsx", -- 2679
	"**/*.lua", -- 2680
	"!**/.*/**", -- 2681
	"!**/node_modules/**", -- 2682
	"!**/CMakeFiles/**" -- 2683
} -- 2677
local luaRuntimeModules -- 2685
do -- 2685
	local modules = { } -- 2686
	for name in pairs(_compilerRuntimeModules or { }) do -- 2687
		modules[#modules + 1] = name -- 2688
	end -- 2687
	local _list_0 = (_loveCompilerModules and _loveCompilerModules() or { }) -- 2689
	for _index_0 = 1, #_list_0 do -- 2689
		local name = _list_0[_index_0] -- 2689
		modules[#modules + 1] = name -- 2690
	end -- 2689
	table.sort(modules) -- 2691
	luaRuntimeModules = modules -- 2692
end -- 2685
HttpServer:post("/ts/runtime-modules", function() -- 2694
	return { -- 2694
		success = true, -- 2694
		luaRuntimeModules = luaRuntimeModules, -- 2694
		assetPath = Content.assetPath -- 2694
	} -- 2694
end) -- 2694
local compilerDeclarationRoot -- 2696
compilerDeclarationRoot = function() -- 2696
	local locale -- 2697
	if App.locale:match('^zh') then -- 2697
		locale = 'zh-Hans' -- 2697
	else -- 2697
		locale = 'en' -- 2697
	end -- 2697
	return Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2698
end -- 2696
local compilerDefaultLib -- 2700
compilerDefaultLib = function() -- 2700
	return Path(compilerDeclarationRoot(), "Dora.d.ts") -- 2700
end -- 2700
local _anon_func_8 = function(file) -- 2728
	local _val_0 = Path:getExt(file) -- 2728
	return "ts" == _val_0 or "tsx" == _val_0 -- 2728
end -- 2728
local collectTSVirtualFiles -- 2702
collectTSVirtualFiles = function(sourceRoot) -- 2702
	local files = { } -- 2703
	local seen = { } -- 2704
	local addFile -- 2705
	addFile = function(file, moduleName, virtualFile) -- 2705
		if moduleName == nil then -- 2705
			moduleName = nil -- 2705
		end -- 2705
		if virtualFile == nil then -- 2705
			virtualFile = nil -- 2705
		end -- 2705
		local targetFile = virtualFile or file -- 2706
		do -- 2707
			local entry = seen[targetFile] -- 2707
			if entry then -- 2707
				if moduleName and moduleName ~= "" then -- 2708
					entry.moduleName = moduleName -- 2708
				end -- 2708
				return -- 2709
			end -- 2707
		end -- 2707
		local content = Content:load(file) -- 2710
		if content then -- 2710
			local entry = { -- 2711
				file = targetFile, -- 2711
				content = content -- 2711
			} -- 2711
			if virtualFile and Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2712
				entry.sourcePath = file -- 2712
			end -- 2712
			if moduleName and moduleName ~= "" then -- 2713
				entry.moduleName = moduleName -- 2713
			end -- 2713
			seen[targetFile] = entry -- 2714
			files[#files + 1] = entry -- 2715
		end -- 2710
	end -- 2705
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2716
		local builtinScriptRoot = Path(Content.assetPath, "Script") -- 2717
		local builtinPrefix -- 2719
		if relativeToRoot(sourceRoot, builtinScriptRoot) == "" then -- 2719
			builtinPrefix = "Script/" -- 2720
		elseif relativeToRoot(sourceRoot, Content.assetPath) == "" then -- 2721
			builtinPrefix = "" -- 2722
		else -- 2724
			builtinPrefix = nil -- 2724
		end -- 2719
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs, nil, false) -- 2725
		for _index_0 = 1, #_list_0 do -- 2725
			local subFile = _list_0[_index_0] -- 2725
			local file = Path(sourceRoot, subFile) -- 2726
			local moduleName = nil -- 2727
			if builtinPrefix and _anon_func_8(file) and Path:getExt(Path:getName(file)) ~= "d" then -- 2728
				local relative = relativeToRoot(file, builtinScriptRoot) -- 2729
				if relative then -- 2729
					moduleName = (builtinPrefix .. Path:replaceExt(relative, "")):gsub("\\", "/") -- 2730
				end -- 2729
			end -- 2728
			addFile(file, moduleName) -- 2731
		end -- 2725
		local libraryRoot = Path(Content.assetPath, "Script", "Lib") -- 2732
		if Content:isdir(libraryRoot) then -- 2733
			local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs, nil, false) -- 2734
			for _index_0 = 1, #_list_1 do -- 2734
				local subFile = _list_1[_index_0] -- 2734
				addFile(Path(libraryRoot, subFile), nil, Path(sourceRoot, subFile)) -- 2735
			end -- 2734
		end -- 2733
	end -- 2716
	local _list_0 = { -- 2736
		"Dev", -- 2736
		"Tools" -- 2736
	} -- 2736
	for _index_0 = 1, #_list_0 do -- 2736
		local namespace = _list_0[_index_0] -- 2736
		local builtinRoot = Path(Content.assetPath, "Script", namespace) -- 2737
		if Content:isdir(builtinRoot) then -- 2738
			local _list_1 = Content:glob(builtinRoot, tsSnapshotGlobs, nil, false) -- 2739
			for _index_1 = 1, #_list_1 do -- 2739
				local subFile = _list_1[_index_1] -- 2739
				local file = Path(builtinRoot, subFile) -- 2740
				addFile(file, nil, Path(sourceRoot, namespace, subFile)) -- 2741
				addFile(file, nil, Path(sourceRoot, "Script", namespace, subFile)) -- 2742
			end -- 2739
		end -- 2738
	end -- 2736
	local declarationRoot = compilerDeclarationRoot() -- 2743
	local _list_1 = Content:getFiles(declarationRoot) -- 2744
	for _index_0 = 1, #_list_1 do -- 2744
		local file = _list_1[_index_0] -- 2744
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2745
			local fullPath = Path(declarationRoot, file) -- 2746
			local moduleName = Path:getName(Path:getName(file)) -- 2747
			addFile(fullPath, moduleName) -- 2748
		end -- 2745
	end -- 2744
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2749
	local lualibBundleTarget -- 2750
	if sourceRoot then -- 2750
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2750
	else -- 2750
		lualibBundleTarget = "lualib_bundle.lua" -- 2750
	end -- 2750
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2751
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2752
	local _list_2 = Content:getFiles(lualibRoot) -- 2753
	for _index_0 = 1, #_list_2 do -- 2753
		local file = _list_2[_index_0] -- 2753
		if Path:getExt(file) == "lua" then -- 2754
			local virtualFile -- 2755
			if sourceRoot then -- 2755
				virtualFile = Path(sourceRoot, "lualib", file) -- 2755
			else -- 2755
				virtualFile = Path("lualib", file) -- 2755
			end -- 2755
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2756
		end -- 2754
	end -- 2753
	return files -- 2757
end -- 2702
local supportsCompilerWebView -- 2759
supportsCompilerWebView = function() -- 2759
	local _val_0 = App.platform -- 2759
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2759
end -- 2759
local projectCompilerScriptRoot -- 2760
projectCompilerScriptRoot = function(sourceRoot) -- 2760
	if not (sourceRoot and not relativeToRoot(sourceRoot, Content.assetPath)) then -- 2761
		return nil -- 2761
	end -- 2761
	return (ProjectSearch(sourceRoot))[2] -- 2762
end -- 2760
local _anon_func_9 = function(file) -- 2766
	local _val_0 = Path:getExt(file) -- 2766
	return "ts" == _val_0 or "tsx" == _val_0 -- 2766
end -- 2766
HttpServer:postSchedule("/ts/snapshot", function(req) -- 2764
	do -- 2765
		local _type_0 = type(req) -- 2765
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2765
		if _tab_0 then -- 2765
			local file -- 2765
			do -- 2765
				local _obj_0 = req.body -- 2765
				local _type_1 = type(_obj_0) -- 2765
				if "table" == _type_1 or "userdata" == _type_1 then -- 2765
					file = _obj_0.file -- 2765
				end -- 2765
			end -- 2765
			if file ~= nil then -- 2765
				if not (type(file) == "string" and Content:isAbsolutePath(file) and _anon_func_9(file)) then -- 2766
					return invalidArguments -- 2766
				end -- 2766
				file = Path(Path:getPath(file), Path:getFilename(file)) -- 2767
				local snapshotRoot = getProjectDirFromFile(file) or Path:getPath(file) -- 2768
				if not (relativeToRoot(snapshotRoot, Content.writablePath) or relativeToRoot(snapshotRoot, Content.assetPath)) then -- 2769
					return invalidArguments -- 2769
				end -- 2769
				return { -- 2771
					success = true, -- 2771
					projectRoot = snapshotRoot, -- 2772
					projectScriptRoot = projectCompilerScriptRoot(snapshotRoot), -- 2773
					files = collectTSVirtualFiles(snapshotRoot), -- 2774
					luaRuntimeModules = luaRuntimeModules, -- 2775
					assetPath = Content.assetPath, -- 2776
					defaultLibFileName = compilerDefaultLib() -- 2777
				} -- 2770
			end -- 2765
		end -- 2765
	end -- 2765
	return invalidArguments -- 2764
end) -- 2764
local webIDECompilerReady = false -- 2779
local webIDEConnectionGeneration = 0 -- 2780
local tsProbeId = 0 -- 2781
local probeWebIDECompiler -- 2783
probeWebIDECompiler = function(isCancelled) -- 2783
	if HttpServer.wsConnectionCount == 0 then -- 2784
		return false -- 2784
	end -- 2784
	tsProbeId = tsProbeId + 1 -- 2785
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2786
	local generation = webIDEConnectionGeneration -- 2787
	local done, ready = false, false -- 2788
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2789
	local listener = Node() -- 2790
	listener:gslot("AppWS", function(event) -- 2791
		if event.type == "Receive" then -- 2792
			local res = json.decode(event.msg) -- 2793
			if res then -- 2793
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2794
					responses = responses + 1 -- 2795
					ready = ready or res.success == true -- 2796
					done = ready or responses >= expectedResponses -- 2797
				end -- 2794
			end -- 2793
		end -- 2792
	end) -- 2791
	emit("AppWS", "Send", json.encode({ -- 2798
		name = "TranspileTSProbe", -- 2798
		id = requestId -- 2798
	})) -- 2798
	local deadline = App.runningTime + 5 -- 2799
	wait(function() -- 2800
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2800
	end) -- 2800
	listener:removeFromParent() -- 2801
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2802
	if generation == webIDEConnectionGeneration then -- 2803
		webIDECompilerReady = ready -- 2803
	end -- 2803
	return ready -- 2804
end -- 2783
local compilerConnectionListener = Node() -- 2806
compilerConnectionListener:addTo(Director.systemUI) -- 2808
local _anon_func_10 = function(event) -- 2810
	local _val_0 = event.type -- 2810
	return "Open" == _val_0 or "Close" == _val_0 -- 2810
end -- 2810
compilerConnectionListener:gslot("AppWS", function(event) -- 2809
	if _anon_func_10(event) then -- 2810
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2811
		webIDECompilerReady = false -- 2812
		if HttpServer.wsConnectionCount > 0 then -- 2813
			return thread(function() -- 2814
				return probeWebIDECompiler() -- 2814
			end) -- 2814
		end -- 2813
	end -- 2810
end) -- 2809
local _anon_func_11 = function(res) -- 2839
	if res.success then -- 2839
		return "tool" -- 2839
	else -- 2839
		return res.failureKind -- 2839
	end -- 2839
end -- 2839
local transpileTSFileWithWebIDE -- 2816
do -- 2816
	local tsBuildRequestId = 0 -- 2817
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2818
		if not probeWebIDECompiler(isCancelled) then -- 2819
			if isCancelled and isCancelled() then -- 2820
				return { -- 2821
					success = false, -- 2821
					file = file, -- 2821
					message = "build canceled", -- 2821
					interrupted = true -- 2821
				} -- 2821
			end -- 2820
			return { -- 2822
				success = false, -- 2822
				file = file, -- 2822
				message = "TypeScript transpiler is not ready", -- 2822
				failureKind = "tool" -- 2822
			} -- 2822
		end -- 2819
		tsBuildRequestId = tsBuildRequestId + 1 -- 2823
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2824
		local done = false -- 2825
		local result = nil -- 2826
		local listener = Node() -- 2827
		listener:gslot("AppWS", function(event) -- 2828
			if event.type == "Receive" then -- 2829
				local res = json.decode(event.msg) -- 2830
				if res then -- 2830
					if res.name == "TranspileTS" and res.id == requestId then -- 2831
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2832
							local luaFile = Path:replaceExt(file, "lua") -- 2833
							if Content:save(luaFile, res.luaCode) then -- 2834
								result = { -- 2835
									success = true, -- 2835
									file = file -- 2835
								} -- 2835
							else -- 2837
								result = { -- 2837
									success = false, -- 2837
									file = file, -- 2837
									message = "failed to save " .. tostring(luaFile) -- 2837
								} -- 2837
							end -- 2834
						else -- 2839
							result = { -- 2839
								success = false, -- 2839
								file = file, -- 2839
								message = res.message or "Compiler returned no Lua output", -- 2839
								failureKind = _anon_func_11(res) -- 2839
							} -- 2839
						end -- 2832
						done = true -- 2840
					end -- 2831
				end -- 2830
			end -- 2829
		end) -- 2828
		emit("AppWS", "Send", json.encode({ -- 2841
			name = "TranspileTS", -- 2841
			id = requestId, -- 2841
			file = file, -- 2841
			content = content, -- 2841
			projectRoot = sourceRoot, -- 2841
			projectScriptRoot = projectCompilerScriptRoot(sourceRoot), -- 2841
			files = files, -- 2841
			luaRuntimeModules = luaRuntimeModules, -- 2841
			assetPath = Content.assetPath, -- 2841
			defaultLibFileName = compilerDefaultLib() -- 2841
		})) -- 2841
		local deadline = App.runningTime + 30 -- 2842
		wait(function() -- 2843
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2843
		end) -- 2843
		listener:removeFromParent() -- 2844
		if not done then -- 2845
			webIDECompilerReady = false -- 2846
			if isCancelled and isCancelled() then -- 2847
				return { -- 2848
					success = false, -- 2848
					file = file, -- 2848
					message = "build canceled", -- 2848
					interrupted = true -- 2848
				} -- 2848
			end -- 2847
			return { -- 2849
				success = false, -- 2849
				file = file, -- 2849
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2849
				failureKind = "tool" -- 2849
			} -- 2849
		end -- 2845
		return result -- 2850
	end -- 2818
end -- 2816
local compilerReadyTimeout <const> = 15 -- 2852
local compilerBuildTimeout <const> = 30 -- 2853
local compilerIdleCloseSeconds <const> = 8 -- 2854
local compilerReady = false -- 2855
local compilerRequested = false -- 2856
local compilerFailure = nil -- 2857
local compilerUsers = 0 -- 2858
local compilerCloseGeneration = 0 -- 2859
local compilerJobId = 0 -- 2860
local compilerJobs = { } -- 2861
local compilerResults = { } -- 2862
local compilerInFlight = { } -- 2863
HttpServer:post("/compiler/ready", function() -- 2865
	if not compilerRequested then -- 2866
		return { -- 2866
			success = false -- 2866
		} -- 2866
	end -- 2866
	compilerReady = true -- 2867
	return { -- 2868
		success = true -- 2868
	} -- 2868
end) -- 2865
HttpServer:post("/compiler/failure", function(req) -- 2870
	if not compilerRequested then -- 2871
		return { -- 2871
			success = false -- 2871
		} -- 2871
	end -- 2871
	do -- 2872
		local _type_0 = type(req) -- 2872
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2872
		if _tab_0 then -- 2872
			local message -- 2872
			do -- 2872
				local _obj_0 = req.body -- 2872
				local _type_1 = type(_obj_0) -- 2872
				if "table" == _type_1 or "userdata" == _type_1 then -- 2872
					message = _obj_0.message -- 2872
				end -- 2872
			end -- 2872
			if message ~= nil then -- 2872
				if type(message) == "string" then -- 2873
					compilerFailure = message -- 2874
					compilerReady = false -- 2875
					return { -- 2876
						success = true -- 2876
					} -- 2876
				end -- 2873
			end -- 2872
		end -- 2872
	end -- 2872
	return { -- 2870
		success = false -- 2870
	} -- 2870
end) -- 2870
HttpServer:postSchedule("/compiler/poll", function() -- 2878
	if not compilerRequested then -- 2879
		return { -- 2879
			success = false -- 2879
		} -- 2879
	end -- 2879
	compilerReady = true -- 2880
	local deadline = App.runningTime + 5 -- 2881
	wait(function() -- 2882
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2882
	end) -- 2882
	if not (compilerRequested and not compilerFailure) then -- 2883
		return { -- 2883
			success = false -- 2883
		} -- 2883
	end -- 2883
	local job = table.remove(compilerJobs, 1) -- 2884
	if job then -- 2885
		compilerInFlight[job.id] = true -- 2886
	end -- 2885
	return { -- 2887
		success = true, -- 2887
		job = job -- 2887
	} -- 2887
end) -- 2878
HttpServer:post("/compiler/result", function(req) -- 2889
	do -- 2890
		local _type_0 = type(req) -- 2890
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2890
		if _tab_0 then -- 2890
			local body = req.body -- 2890
			if body ~= nil then -- 2890
				local id = body.id -- 2891
				if not (id and compilerInFlight[id]) then -- 2892
					return { -- 2892
						success = false, -- 2892
						message = "invalid compiler job" -- 2892
					} -- 2892
				end -- 2892
				compilerInFlight[id] = nil -- 2893
				compilerResults[id] = body -- 2894
				return { -- 2895
					success = true -- 2895
				} -- 2895
			end -- 2890
		end -- 2890
	end -- 2890
	return { -- 2889
		success = false -- 2889
	} -- 2889
end) -- 2889
local acquireCompiler -- 2897
acquireCompiler = function() -- 2897
	compilerUsers = compilerUsers + 1 -- 2898
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2899
	if not compilerRequested then -- 2900
		compilerRequested = true -- 2901
		compilerReady = false -- 2902
		compilerFailure = nil -- 2903
		return emit("AppWebView", "/compiler.html", true) -- 2904
	end -- 2900
end -- 2897
local releaseCompiler -- 2906
releaseCompiler = function() -- 2906
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2907
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2908
	if not (compilerUsers == 0) then -- 2909
		return -- 2909
	end -- 2909
	local closeGeneration = compilerCloseGeneration -- 2910
	return thread(function() -- 2911
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2912
		wait(function() -- 2913
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2914
		end) -- 2913
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2919
			compilerRequested = false -- 2920
			compilerReady = false -- 2921
			return emit("AppWebView", "/compiler.html", false) -- 2922
		end -- 2919
	end) -- 2911
end -- 2906
local removeCompilerJob -- 2924
removeCompilerJob = function(id) -- 2924
	for index = #compilerJobs, 1, -1 do -- 2925
		if compilerJobs[index].id == id then -- 2926
			table.remove(compilerJobs, index) -- 2927
		end -- 2926
	end -- 2925
	compilerInFlight[id] = nil -- 2928
	compilerResults[id] = nil -- 2929
end -- 2924
local transpileTSFileWithCompiler -- 2931
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2931
	acquireCompiler() -- 2932
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2933
	wait(function() -- 2934
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2934
	end) -- 2934
	if not compilerReady then -- 2935
		releaseCompiler() -- 2936
		if isCancelled and isCancelled() then -- 2937
			return { -- 2938
				success = false, -- 2938
				file = file, -- 2938
				message = "build canceled", -- 2938
				interrupted = true -- 2938
			} -- 2938
		end -- 2937
		return { -- 2939
			success = false, -- 2939
			file = file, -- 2939
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2939
			failureKind = "tool" -- 2939
		} -- 2939
	end -- 2935
	compilerJobId = compilerJobId + 1 -- 2940
	local jobId = compilerJobId -- 2941
	compilerJobs[#compilerJobs + 1] = { -- 2943
		id = jobId, -- 2943
		file = file, -- 2944
		content = content, -- 2945
		projectRoot = sourceRoot, -- 2946
		projectScriptRoot = projectCompilerScriptRoot(sourceRoot), -- 2947
		files = files, -- 2948
		luaRuntimeModules = luaRuntimeModules, -- 2949
		assetPath = Content.assetPath, -- 2950
		defaultLibFileName = compilerDefaultLib() -- 2951
	} -- 2942
	local deadline = App.runningTime + compilerBuildTimeout -- 2952
	wait(function() -- 2953
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2953
	end) -- 2953
	local response = compilerResults[jobId] -- 2954
	removeCompilerJob(jobId) -- 2955
	releaseCompiler() -- 2956
	if not response then -- 2957
		if isCancelled and isCancelled() then -- 2958
			return { -- 2959
				success = false, -- 2959
				file = file, -- 2959
				message = "build canceled", -- 2959
				interrupted = true -- 2959
			} -- 2959
		end -- 2958
		return { -- 2960
			success = false, -- 2960
			file = file, -- 2960
			message = compilerFailure or "TypeScript transpile timed out", -- 2960
			failureKind = "tool" -- 2960
		} -- 2960
	end -- 2957
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2961
		local luaFile = Path:replaceExt(file, "lua") -- 2962
		if Content:save(luaFile, response.luaCode) then -- 2963
			return { -- 2964
				success = true, -- 2964
				file = file -- 2964
			} -- 2964
		end -- 2963
		return { -- 2965
			success = false, -- 2965
			file = file, -- 2965
			message = "failed to save " .. tostring(luaFile) -- 2965
		} -- 2965
	end -- 2961
	return { -- 2966
		success = false, -- 2966
		file = file, -- 2966
		message = response.message or "TypeScript transpile failed" -- 2966
	} -- 2966
end -- 2931
local compilerFailureListener = Node() -- 2968
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2969
	compilerFailure = message -- 2970
	compilerReady = false -- 2971
end) -- 2969
local transpileTSFile -- 2973
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2973
	sourceRoot = sourceRoot or (getProjectDirFromFile(file) or Path:getPath(file)) -- 2974
	files = files or collectTSVirtualFiles(sourceRoot) -- 2975
	if HttpServer.wsConnectionCount > 0 then -- 2976
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2977
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2978
			return result -- 2978
		end -- 2978
		webIDECompilerReady = false -- 2979
	end -- 2976
	if supportsCompilerWebView() then -- 2980
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2981
	end -- 2980
	return { -- 2982
		success = false, -- 2982
		file = file, -- 2982
		message = "Web IDE compiler not connected", -- 2982
		failureKind = "tool" -- 2982
	} -- 2982
end -- 2973
local buildTypeScriptFiles -- 2984
buildTypeScriptFiles = function(files, sourceRoot, isCancelled) -- 2984
	local messages = { } -- 2985
	local fileData = { } -- 2986
	for _index_0 = 1, #files do -- 2987
		local file = files[_index_0] -- 2987
		if "d" == Path:getExt(Path:getName(file)) then -- 2988
			goto _continue_0 -- 2988
		end -- 2988
		local content = Content:load(file) -- 2989
		if content then -- 2989
			if content:match("^%s*<%?xml") then -- 2990
				goto _continue_0 -- 2990
			end -- 2990
			fileData[file] = content -- 2991
			emit("AppWS", "Send", json.encode({ -- 2992
				name = "UpdateFile", -- 2992
				file = file, -- 2992
				exists = true, -- 2992
				content = content, -- 2992
				projectRoot = sourceRoot -- 2992
			})) -- 2992
		else -- 2994
			messages[#messages + 1] = { -- 2994
				success = false, -- 2994
				file = file, -- 2994
				message = "failed to read file" -- 2994
			} -- 2994
		end -- 2989
		::_continue_0:: -- 2988
	end -- 2987
	if next(fileData) then -- 2995
		local snapshot = collectTSVirtualFiles(sourceRoot) -- 2996
		for file, content in pairs(fileData) do -- 2997
			if isCancelled and isCancelled() then -- 2998
				break -- 2998
			end -- 2998
			messages[#messages + 1] = transpileTSFile(file, content, sourceRoot, snapshot, isCancelled) -- 2999
		end -- 2997
	end -- 2995
	return messages -- 3000
end -- 2984
local _anon_func_12 = function(getProjectDirFromFile, isDir, path) -- 3014
	if isDir then -- 3014
		return path -- 3014
	else -- 3014
		return getProjectDirFromFile(path) or Path:getPath(path) -- 3014
	end -- 3014
end -- 3014
local _anon_func_13 = function(path) -- 3017
	local _val_0 = Path:getExt(path) -- 3017
	return "ts" == _val_0 or "tsx" == _val_0 -- 3017
end -- 3017
local _anon_func_14 = function(file) -- 3022
	local _val_0 = Path:getExt(file) -- 3022
	return "ts" == _val_0 or "tsx" == _val_0 -- 3022
end -- 3022
local _anon_func_15 = function(file) -- 3028
	local _val_0 = Path:getExt(file) -- 3028
	return "ts" == _val_0 or "tsx" == _val_0 -- 3028
end -- 3028
HttpServer:postSchedule("/ts/build", function(req) -- 3002
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 3003
	local buildSucceeded = false -- 3004
	local _ <close> = setmetatable({ }, { -- 3005
		__close = function() -- 3005
			return finishUpdate(buildSucceeded) -- 3005
		end -- 3005
	}) -- 3005
	do -- 3006
		local _type_0 = type(req) -- 3006
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3006
		if _tab_0 then -- 3006
			local path -- 3006
			do -- 3006
				local _obj_0 = req.body -- 3006
				local _type_1 = type(_obj_0) -- 3006
				if "table" == _type_1 or "userdata" == _type_1 then -- 3006
					path = _obj_0.path -- 3006
				end -- 3006
			end -- 3006
			if path ~= nil then -- 3006
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 3007
					return { -- 3008
						success = false, -- 3008
						message = "Web IDE not connected" -- 3008
					} -- 3008
				end -- 3007
				local projectRoot = req.body.projectRoot -- 3009
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 3010
				if not Content:exist(path) then -- 3011
					return { -- 3012
						success = false, -- 3012
						message = "path not existed" -- 3012
					} -- 3012
				end -- 3011
				local isDir = Content:isdir(path) -- 3013
				sourceRoot = sourceRoot or _anon_func_12(getProjectDirFromFile, isDir, path) -- 3014
				local messages = { } -- 3015
				if not isDir then -- 3016
					if not (_anon_func_13(path)) then -- 3017
						return { -- 3017
							success = false, -- 3017
							message = "expecting a TypeScript file" -- 3017
						} -- 3017
					end -- 3017
					messages = buildTypeScriptFiles({ -- 3018
						path -- 3018
					}, sourceRoot) -- 3018
				else -- 3019
					local selected = req.body.files -- 3019
					if selected then -- 3019
						if not (type(selected) == "table") then -- 3020
							return { -- 3020
								success = false, -- 3020
								message = "invalid TypeScript targets" -- 3020
							} -- 3020
						end -- 3020
						for _index_0 = 1, #selected do -- 3021
							local file = selected[_index_0] -- 3021
							if not (type(file) == "string" and Content:isAbsolutePath(file) and relativeToRoot(file, path) and _anon_func_14(file)) then -- 3022
								return { -- 3023
									success = false, -- 3023
									message = "TypeScript target must be inside the build directory" -- 3023
								} -- 3023
							end -- 3022
						end -- 3021
						messages = buildTypeScriptFiles(selected, sourceRoot) -- 3024
					else -- 3026
						local BuildPlan = require("Agent.Tool.BuildPlan") -- 3026
						local _list_0 = BuildPlan.planDirectoryBuild(path, sourceRoot, { -- 3027
							"!**/.*/**" -- 3027
						}) -- 3027
						for _index_0 = 1, #_list_0 do -- 3027
							local unit = _list_0[_index_0] -- 3027
							local files -- 3028
							do -- 3028
								local _accum_0 = { } -- 3028
								local _len_0 = 1 -- 3028
								local _list_1 = unit.files -- 3028
								for _index_1 = 1, #_list_1 do -- 3028
									local file = _list_1[_index_1] -- 3028
									if _anon_func_15(file) then -- 3028
										_accum_0[_len_0] = file -- 3028
										_len_0 = _len_0 + 1 -- 3028
									end -- 3028
								end -- 3028
								files = _accum_0 -- 3028
							end -- 3028
							local _list_1 = buildTypeScriptFiles(files, unit.projectRoot or sourceRoot) -- 3029
							for _index_1 = 1, #_list_1 do -- 3029
								local result = _list_1[_index_1] -- 3029
								messages[#messages + 1] = result -- 3030
							end -- 3029
						end -- 3027
					end -- 3019
				end -- 3016
				local success = true -- 3031
				for _index_0 = 1, #messages do -- 3032
					local item = messages[_index_0] -- 3032
					if not item.success then -- 3033
						success = false -- 3034
						Log("Error", item.message or "Failed to build " .. tostring(item.file)) -- 3035
					end -- 3033
				end -- 3032
				local message = nil -- 3036
				if not success then -- 3037
					message = "TypeScript compilation failed" -- 3037
				end -- 3037
				buildSucceeded = success -- 3038
				return { -- 3039
					success = success, -- 3039
					messages = messages, -- 3039
					message = message -- 3039
				} -- 3039
			end -- 3006
		end -- 3006
	end -- 3006
	return { -- 3002
		success = false -- 3002
	} -- 3002
end) -- 3002
HttpServer:post("/download", function(req) -- 3041
	do -- 3042
		local _type_0 = type(req) -- 3042
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3042
		if _tab_0 then -- 3042
			local url -- 3042
			do -- 3042
				local _obj_0 = req.body -- 3042
				local _type_1 = type(_obj_0) -- 3042
				if "table" == _type_1 or "userdata" == _type_1 then -- 3042
					url = _obj_0.url -- 3042
				end -- 3042
			end -- 3042
			local target -- 3042
			do -- 3042
				local _obj_0 = req.body -- 3042
				local _type_1 = type(_obj_0) -- 3042
				if "table" == _type_1 or "userdata" == _type_1 then -- 3042
					target = _obj_0.target -- 3042
				end -- 3042
			end -- 3042
			if url ~= nil and target ~= nil then -- 3042
				local Entry = require("Script.Dev.Entry") -- 3043
				Entry.downloadFile(url, target) -- 3044
				return { -- 3045
					success = true -- 3045
				} -- 3045
			end -- 3042
		end -- 3042
	end -- 3042
	return { -- 3041
		success = false -- 3041
	} -- 3041
end) -- 3041
local isDesktopPlatform -- 3047
isDesktopPlatform = function() -- 3047
	local _val_0 = App.platform -- 3048
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 3048
end -- 3047
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 3050
local nativeIDEListener = Node() -- 3051
nativeIDEListener:addTo(Director.systemUI) -- 3052
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 3053
	nativeIDEState, nativeIDEMessage = state, message -- 3054
end) -- 3053
local _anon_func_16 = function() -- 3057
	local _val_0 = App.platform -- 3057
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 3057
end -- 3057
HttpServer:post("/ide", function(req) -- 3056
	if not (_anon_func_16()) then -- 3057
		return { -- 3057
			success = false, -- 3057
			message = "Native IDE is unavailable" -- 3057
		} -- 3057
	end -- 3057
	if not App.webIDEEnabled then -- 3058
		return { -- 3058
			success = false, -- 3058
			message = "Embedded Web IDE is disabled" -- 3058
		} -- 3058
	end -- 3058
	do -- 3059
		local _type_0 = type(req) -- 3059
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3059
		if _tab_0 then -- 3059
			local action -- 3059
			do -- 3059
				local _obj_0 = req.body -- 3059
				local _type_1 = type(_obj_0) -- 3059
				if "table" == _type_1 or "userdata" == _type_1 then -- 3059
					action = _obj_0.action -- 3059
				end -- 3059
			end -- 3059
			if action ~= nil then -- 3059
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 3060
					emit("AppWebView", "/ide/" .. action, true) -- 3061
					return { -- 3062
						success = true -- 3062
					} -- 3062
				end -- 3060
			end -- 3059
		end -- 3059
	end -- 3059
	return { -- 3056
		success = false, -- 3056
		message = "invalid IDE action" -- 3056
	} -- 3056
end) -- 3056
local _anon_func_17 = function() -- 3078
	local _val_0 = App.platform -- 3078
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 3078
end -- 3078
local getServerStatus -- 3064
getServerStatus = function() -- 3064
	local Entry = require("Script.Dev.Entry") -- 3065
	local running = Entry.getCurrentEntryStatus() -- 3066
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 3067
	local wsConnectionCount = HttpServer.wsConnectionCount -- 3068
	return { -- 3070
		success = true, -- 3070
		platform = App.platform, -- 3071
		locale = App.locale, -- 3072
		version = App.version, -- 3073
		url = "http://localhost:8866", -- 3074
		wsConnectionCount = wsConnectionCount, -- 3075
		webIDEConnected = wsConnectionCount > 0, -- 3076
		nativeIDE = { -- 3078
			supported = _anon_func_17(), -- 3078
			enabled = App.webIDEEnabled, -- 3079
			state = nativeIDEState, -- 3080
			message = nativeIDEMessage -- 3081
		}, -- 3077
		typescriptCompiler = { -- 3083
			webIDEReady = webIDECompilerReady, -- 3083
			webIDEGeneration = webIDEConnectionGeneration, -- 3084
			embeddedSupported = supportsCompilerWebView(), -- 3085
			embeddedRequested = compilerRequested, -- 3086
			embeddedReady = compilerReady, -- 3087
			users = compilerUsers, -- 3088
			queuedJobs = #compilerJobs, -- 3089
			failure = compilerFailure -- 3090
		}, -- 3082
		assetPath = Content.assetPath, -- 3091
		writablePath = Content.writablePath, -- 3092
		appPath = Content.appPath, -- 3093
		waTemplateReady = waTemplateReady, -- 3094
		running = running -- 3095
	} -- 3069
end -- 3064
HttpServer:post("/status", function() -- 3098
	return getServerStatus() -- 3099
end) -- 3098
HttpServer:postSchedule("/doctor/fix", function(req) -- 3101
	do -- 3102
		local _type_0 = type(req) -- 3102
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3102
		if _tab_0 then -- 3102
			local openWebIDE -- 3102
			do -- 3102
				local _obj_0 = req.body -- 3102
				local _type_1 = type(_obj_0) -- 3102
				if "table" == _type_1 or "userdata" == _type_1 then -- 3102
					openWebIDE = _obj_0.openWebIDE -- 3102
				end -- 3102
			end -- 3102
			if openWebIDE ~= nil then -- 3102
				if not openWebIDE then -- 3103
					return { -- 3104
						success = false, -- 3104
						message = "nothing to fix" -- 3104
					} -- 3104
				end -- 3103
				local status = getServerStatus() -- 3105
				if status.webIDEConnected then -- 3106
					return { -- 3107
						success = true, -- 3107
						fixed = false, -- 3107
						message = "Web IDE already connected.", -- 3107
						status = status -- 3107
					} -- 3107
				end -- 3106
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 3108
				if waitSeconds > 0 then -- 3109
					local deadline = os.time() + waitSeconds -- 3110
					repeat -- 3111
						sleep(0.2) -- 3112
						status = getServerStatus() -- 3113
						if status.webIDEConnected then -- 3114
							return { -- 3115
								success = true, -- 3115
								fixed = false, -- 3115
								reconnected = true, -- 3115
								message = "Web IDE reconnected.", -- 3115
								status = status -- 3115
							} -- 3115
						end -- 3114
					until os.time() >= deadline -- 3111
				end -- 3109
				if not isDesktopPlatform() then -- 3117
					return { -- 3118
						success = false, -- 3118
						message = "opening Web IDE is only supported on desktop platforms", -- 3118
						status = status -- 3118
					} -- 3118
				end -- 3117
				local url = "http://localhost:8866" -- 3119
				App:openURL(url) -- 3120
				status.openedURL = url -- 3121
				return { -- 3122
					success = true, -- 3122
					fixed = true, -- 3122
					message = "Opened Web IDE in the local browser.", -- 3122
					url = url, -- 3122
					status = status -- 3122
				} -- 3122
			end -- 3102
		end -- 3102
	end -- 3102
	return { -- 3101
		success = false, -- 3101
		message = "invalid call" -- 3101
	} -- 3101
end) -- 3101
local status = { } -- 3124
_module_0 = status -- 3125
status.transpileTSFile = transpileTSFile -- 3127
status.buildTypeScriptFiles = buildTypeScriptFiles -- 3128
HttpServer:post("/build/plan", function(req) -- 3130
	do -- 3131
		local _type_0 = type(req) -- 3131
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3131
		if _tab_0 then -- 3131
			local path -- 3131
			do -- 3131
				local _obj_0 = req.body -- 3131
				local _type_1 = type(_obj_0) -- 3131
				if "table" == _type_1 or "userdata" == _type_1 then -- 3131
					path = _obj_0.path -- 3131
				end -- 3131
			end -- 3131
			if path ~= nil then -- 3131
				if not (type(path) == "string" and Content:isAbsolutePath(path) and Content:isdir(path)) then -- 3132
					return invalidArguments -- 3132
				end -- 3132
				local BuildPlan = require("Agent.Tool.BuildPlan") -- 3133
				local project = getProjectDirFromFile(Path(path, "__dora_project_root_search__.lua")) -- 3134
				do -- 3135
					local _exp_0 = req.body.mode -- 3135
					if "editor" == _exp_0 then -- 3136
						if not (relativeToRoot(path, Content.writablePath) or relativeToRoot(path, Content.assetPath)) then -- 3137
							return invalidArguments -- 3137
						end -- 3137
						return { -- 3138
							success = true, -- 3138
							units = BuildPlan.planDirectoryBuild(path, project, nil, extentionLevels) -- 3138
						} -- 3138
					elseif "cli" == _exp_0 then -- 3139
						return { -- 3140
							success = true, -- 3140
							units = BuildPlan.planDirectoryBuild(path, project, { -- 3140
								"!**/API/**", -- 3140
								"!**/build/**", -- 3140
								"!**/dist/**", -- 3140
								"!**/target/**", -- 3140
								"!**/vendor/**" -- 3140
							}) -- 3140
						} -- 3140
					end -- 3135
				end -- 3135
				return { -- 3141
					success = true, -- 3141
					units = BuildPlan.planDirectoryBuild(path, project) -- 3141
				} -- 3141
			end -- 3131
		end -- 3131
	end -- 3131
	return invalidArguments -- 3130
end) -- 3130
HttpServer:postSchedule("/godot/project", function(req) -- 3144
	do -- 3145
		local _type_0 = type(req) -- 3145
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3145
		if _tab_0 then -- 3145
			local path -- 3145
			do -- 3145
				local _obj_0 = req.body -- 3145
				local _type_1 = type(_obj_0) -- 3145
				if "table" == _type_1 or "userdata" == _type_1 then -- 3145
					path = _obj_0.path -- 3145
				end -- 3145
			end -- 3145
			if path ~= nil then -- 3145
				if not (type(path) == "string" and Content:isAbsolutePath(path)) then -- 3146
					return invalidArguments -- 3146
				end -- 3146
				local releaseAgent = AgentHost.acquire() -- 3147
				local _ <close> = setmetatable({ }, { -- 3148
					__close = function() -- 3148
						return releaseAgent() -- 3148
					end -- 3148
				}) -- 3148
				local GodotBuild = require("Agent.Tool.GodotBuild") -- 3149
				local project = GodotBuild.findGodotProject(Content.writablePath, path) or GodotBuild.findGodotProject(Content.assetPath, path) -- 3150
				if not project then -- 3151
					return { -- 3151
						success = true, -- 3151
						found = false -- 3151
					} -- 3151
				end -- 3151
				if not (req.body.build == true) then -- 3152
					return { -- 3152
						success = true, -- 3152
						found = true, -- 3152
						projectRoot = project -- 3152
					} -- 3152
				end -- 3152
				local result -- 3153
				local promise = GodotBuild.buildGodotProject(project) -- 3154
				local onFulfilled -- 3155
				onFulfilled = function(_, value) -- 3155
					result = value -- 3156
				end -- 3155
				local onRejected -- 3157
				onRejected = function(_, err) -- 3157
					result = { -- 3158
						success = false, -- 3158
						message = tostring(err) -- 3158
					} -- 3158
				end -- 3157
				promise["then"](promise, onFulfilled, onRejected) -- 3159
				wait(function() -- 3160
					return result ~= nil -- 3160
				end) -- 3160
				result.found = true -- 3161
				result.projectRoot = project -- 3162
				return result -- 3163
			end -- 3145
		end -- 3145
	end -- 3145
	return invalidArguments -- 3144
end) -- 3144
status.buildAsync = function(path, projectRoot) -- 3165
	if projectRoot == nil then -- 3165
		projectRoot = nil -- 3165
	end -- 3165
	if not Content:exist(path) then -- 3166
		return { -- 3167
			success = false, -- 3167
			file = path, -- 3167
			message = "file not existed" -- 3167
		} -- 3167
	end -- 3166
	do -- 3168
		local _exp_0 = Path:getExt(path) -- 3168
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 3168
			if '' == Path:getExt(Path:getName(path)) then -- 3169
				local content = Content:loadAsync(path) -- 3170
				if content then -- 3170
					local resultCodes, err = compileFileAsync(path, content, projectRoot) -- 3171
					if resultCodes then -- 3172
						return { -- 3173
							success = true, -- 3173
							file = path -- 3173
						} -- 3173
					else -- 3175
						return { -- 3175
							success = false, -- 3175
							file = path, -- 3175
							message = err -- 3175
						} -- 3175
					end -- 3172
				end -- 3170
			end -- 3169
		elseif "lua" == _exp_0 then -- 3176
			local content = Content:loadAsync(path) -- 3177
			if content then -- 3177
				do -- 3178
					local isTIC80 = CheckTIC80Code(content) -- 3178
					if isTIC80 then -- 3178
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 3179
					end -- 3178
				end -- 3178
				local success, info -- 3180
				do -- 3180
					local _obj_0 = luaCheck(path, content) -- 3180
					success, info = _obj_0.success, _obj_0.info -- 3180
				end -- 3180
				if success then -- 3181
					return { -- 3182
						success = true, -- 3182
						file = path -- 3182
					} -- 3182
				elseif info and #info > 0 then -- 3183
					local messages = { } -- 3184
					for _index_0 = 1, #info do -- 3185
						local _des_0 = info[_index_0] -- 3185
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3185
						local lineText = "" -- 3186
						if line then -- 3187
							local currentLine = 1 -- 3188
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3189
								if currentLine == line then -- 3190
									lineText = text -- 3191
									break -- 3192
								end -- 3190
								currentLine = currentLine + 1 -- 3193
							end -- 3189
						end -- 3187
						if line then -- 3194
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3195
						else -- 3197
							messages[#messages + 1] = message -- 3197
						end -- 3194
					end -- 3185
					return { -- 3198
						success = false, -- 3198
						file = path, -- 3198
						message = table.concat(messages, "\n") -- 3198
					} -- 3198
				else -- 3200
					return { -- 3200
						success = false, -- 3200
						file = path, -- 3200
						message = "lua check failed" -- 3200
					} -- 3200
				end -- 3181
			end -- 3177
		elseif "yarn" == _exp_0 then -- 3201
			local content = Content:loadAsync(path) -- 3202
			if content then -- 3202
				local res, _, err = yarncompile(content, true) -- 3203
				if res then -- 3203
					return { -- 3204
						success = true, -- 3204
						file = path -- 3204
					} -- 3204
				else -- 3206
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3206
					local lineText = "" -- 3207
					if line then -- 3208
						local currentLine = 1 -- 3209
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3210
							if currentLine == line then -- 3211
								lineText = text -- 3212
								break -- 3213
							end -- 3211
							currentLine = currentLine + 1 -- 3214
						end -- 3210
					end -- 3208
					if node ~= "" then -- 3215
						node = "node: " .. tostring(node) .. ", " -- 3216
					else -- 3217
						node = "" -- 3217
					end -- 3215
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3218
					return { -- 3219
						success = false, -- 3219
						file = path, -- 3219
						message = message -- 3219
					} -- 3219
				end -- 3203
			end -- 3202
		end -- 3168
	end -- 3168
	return { -- 3220
		success = false, -- 3220
		file = path, -- 3220
		message = "invalid file to build" -- 3220
	} -- 3220
end -- 3165
HttpServer:postSchedule("/git/commit-files", function(req) -- 3222
	do -- 3223
		local _type_0 = type(req) -- 3223
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3223
		if _tab_0 then -- 3223
			local body = req.body -- 3223
			if body ~= nil then -- 3223
				local repoPath, commit = body.repoPath, body.commit -- 3224
				if gitInvalidRepoPath(repoPath) then -- 3225
					return { -- 3225
						success = false, -- 3225
						message = "invalid repoPath" -- 3225
					} -- 3225
				end -- 3225
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3226
					return { -- 3226
						success = false, -- 3226
						message = "invalid commit" -- 3226
					} -- 3226
				end -- 3226
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3227
				if not res.success then -- 3228
					return res -- 3228
				end -- 3228
				return { -- 3229
					success = true, -- 3229
					status = res.status, -- 3229
					data = res.status and res.status.data -- 3229
				} -- 3229
			end -- 3223
		end -- 3223
	end -- 3223
	return invalidArguments -- 3222
end) -- 3222
Director.systemScheduler:schedule(once(function() -- 3233
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3234
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3235
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3236
		local storedAsset -- 3239
		storedAsset = function(file) -- 3239
			if Content:exist(file) then -- 3240
				return Content:load(file) -- 3241
			elseif Content:exist(file .. ".gz") then -- 3242
				return Content:load(file .. ".gz") -- 3243
			else -- 3244
				return "" -- 3244
			end -- 3240
		end -- 3239
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3245
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3246
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3247
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3248
		local readyContent = table.concat({ -- 3250
			App.version, -- 3250
			storedAsset(doraWeb), -- 3251
			storedAsset(heavyAssets), -- 3252
			storedAsset(runtimeIndex), -- 3253
			storedAsset(compilerIndex), -- 3254
			storedAsset(manifest) -- 3255
		}, "\n") -- 3249
		local needReload -- 3257
		if Content:exist(doraReady) then -- 3257
			needReload = readyContent ~= Content:load(doraReady) -- 3258
		else -- 3259
			needReload = true -- 3259
		end -- 3257
		if needReload then -- 3260
			Content:remove(Path(Content.appPath, ".www")) -- 3261
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3262
			Content:save(doraReady, readyContent) -- 3266
			print("Dora Dora is ready!") -- 3267
		end -- 3260
	end -- 3236
	if App.platform == "Emscripten" then -- 3268
		status.url = nil -- 3269
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3270
	end -- 3268
	HttpServer:clearStaticCacheControls() -- 3271
	HttpServer:setStaticCacheControl("no-cache") -- 3272
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3273
	if HttpServer:start(8866) then -- 3277
		local localIP = HttpServer.localIP -- 3278
		if localIP == "" then -- 3279
			localIP = "localhost" -- 3279
		end -- 3279
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3280
		return HttpServer:startWS(8868) -- 3281
	else -- 3283
		status.url = nil -- 3283
		return print("8866 Port not available!") -- 3284
	end -- 3277
end)) -- 3233
nativeExportFormat = function(root) -- 3286
	local relative = relativeToRoot(root, Content.writablePath) -- 3287
	if not (relative and relative ~= "") then -- 3288
		return nil -- 3288
	end -- 3288
	for part in relative:gmatch("[^/\\]+") do -- 3290
		if part:sub(1, 1) == "." then -- 3291
			return nil -- 3291
		end -- 3291
	end -- 3290
	local _exp_0 = App.platform -- 3292
	if "Windows" == _exp_0 then -- 3293
		return "windows" -- 3293
	elseif "Android" == _exp_0 then -- 3294
		return "android" -- 3294
	end -- 3292
end -- 3286
local nativeExporting = false -- 3296
local _anon_func_18 = function(file) -- 3306
	local _val_0 = Path:getExt(file) -- 3306
	return "lua" == _val_0 or "yue" == _val_0 or "tl" == _val_0 or "xml" == _val_0 or "wasm" == _val_0 -- 3306
end -- 3306
HttpServer:postSchedule("/native-game/export", function(req) -- 3297
	do -- 3298
		local _type_0 = type(req) -- 3298
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3298
		if _tab_0 then -- 3298
			local path -- 3298
			do -- 3298
				local _obj_0 = req.body -- 3298
				local _type_1 = type(_obj_0) -- 3298
				if "table" == _type_1 or "userdata" == _type_1 then -- 3298
					path = _obj_0.path -- 3298
				end -- 3298
			end -- 3298
			local format -- 3298
			do -- 3298
				local _obj_0 = req.body -- 3298
				local _type_1 = type(_obj_0) -- 3298
				if "table" == _type_1 or "userdata" == _type_1 then -- 3298
					format = _obj_0.format -- 3298
				end -- 3298
			end -- 3298
			if path ~= nil and format ~= nil then -- 3298
				if not (type(path) == "string" and Content:isAbsolutePath(path)) then -- 3299
					return invalidArguments -- 3299
				end -- 3299
				if not (nativeExportFormat(path) == format and isProjectRootDir(path)) then -- 3300
					return invalidArguments -- 3300
				end -- 3300
				local zh = App.locale:match("^zh") -- 3301
				if nativeExporting then -- 3302
					return { -- 3303
						success = false, -- 3303
						message = zh and "正在导出游戏" or "A game export is in progress" -- 3303
					} -- 3303
				end -- 3302
				local entry -- 3304
				local _list_0 = Content:getFiles(path) -- 3305
				for _index_0 = 1, #_list_0 do -- 3305
					local file = _list_0[_index_0] -- 3305
					if Path:getName(file):lower() == "init" and _anon_func_18(file) then -- 3306
						entry = Path(path, Path:replaceExt(file, "")) -- 3307
						break -- 3308
					end -- 3306
				end -- 3305
				if not entry then -- 3309
					return { -- 3310
						success = false, -- 3310
						message = zh and "请先在 IDE 中编译游戏" or "Build the game in the IDE first" -- 3310
					} -- 3310
				end -- 3309
				nativeExporting = true -- 3311
				local _ <close> = setmetatable({ }, { -- 3312
					__close = function() -- 3312
						nativeExporting = false -- 3312
					end -- 3312
				}) -- 3312
				local title = Path:getFilename(path) -- 3313
				local exporter = require("Script.Dev.NativeGameExport") -- 3314
				if format == "android" then -- 3315
					local ok, result = pcall(exporter.exportAndroid, path, entry, title) -- 3316
					if ok then -- 3317
						return { -- 3317
							success = true -- 3317
						} -- 3317
					end -- 3317
					return { -- 3318
						success = false, -- 3318
						message = tostring(result) -- 3318
					} -- 3318
				end -- 3315
				local newId = require("dora.new_game_id") -- 3319
				local destination = Path(Content.writablePath, ".download", "native-" .. tostring(newId())) -- 3320
				if not Content:mkdir(destination) then -- 3321
					return { -- 3322
						success = false, -- 3322
						message = zh and "无法创建导出目录" or "Could not create the export directory" -- 3322
					} -- 3322
				end -- 3321
				local ok, result = pcall(exporter.exportWindows, path, entry, title, destination) -- 3323
				if ok then -- 3324
					return { -- 3324
						success = true, -- 3324
						archive = result -- 3324
					} -- 3324
				end -- 3324
				Content:remove(destination) -- 3325
				return { -- 3326
					success = false, -- 3326
					message = tostring(result) -- 3326
				} -- 3326
			end -- 3298
		end -- 3298
	end -- 3298
	return invalidArguments -- 3297
end) -- 3297
return _module_0 -- 1
