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
local _compilerRuntimeModules <const> = _compilerRuntimeModules -- 10
local _loveCompilerModules <const> = _loveCompilerModules -- 10
local Node <const> = Node -- 10
local Director <const> = Director -- 10
local next <const> = next -- 10
local Log <const> = Log -- 10
local yarncompile <const> = yarncompile -- 10
local once <const> = once -- 10
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
local LintYueGlobals, CheckTIC80Code, GetProjectSearchPaths, GetProjectScriptRoot -- 85
do -- 85
	local _obj_0 = require("Utils") -- 85
	LintYueGlobals, CheckTIC80Code, GetProjectSearchPaths, GetProjectScriptRoot = _obj_0.LintYueGlobals, _obj_0.CheckTIC80Code, _obj_0.GetProjectSearchPaths, _obj_0.GetProjectScriptRoot -- 85
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
local nativeExportFormats, nativeExportInfo -- 132
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
					return nativeExportInfo(projectRoot) -- 136
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
HttpServer:post("/engine-update/ignore", function() -- 1491
	return { -- 1491
		success = updater.ignoreUpdate() -- 1491
	} -- 1491
end) -- 1491
HttpServer:post("/engine-update/install", function(req) -- 1492
	return { -- 1492
		success = updater.installUpdate(req.body and req.body.confirmed == true) -- 1492
	} -- 1492
end) -- 1492
HttpServer:post("/info", function(req) -- 1494
	local Entry = require("Script.Dev.Entry") -- 1495
	local config = Entry.getConfig() -- 1496
	do -- 1497
		local _type_0 = type(req) -- 1497
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1497
		if _tab_0 then -- 1497
			local webIDETourCompleted -- 1497
			do -- 1497
				local _obj_0 = req.body -- 1497
				local _type_1 = type(_obj_0) -- 1497
				if "table" == _type_1 or "userdata" == _type_1 then -- 1497
					webIDETourCompleted = _obj_0.webIDETourCompleted -- 1497
				end -- 1497
			end -- 1497
			if webIDETourCompleted ~= nil then -- 1497
				config.webIDETourCompleted = webIDETourCompleted == true -- 1498
			end -- 1497
		end -- 1497
	end -- 1497
	local webProfiler, drawerWidth, webIDETourCompleted = config.webProfiler, config.drawerWidth, config.webIDETourCompleted -- 1499
	local engineDev = Entry.getEngineDev() -- 1500
	Entry.connectWebIDE(req.body and req.body.embedded == true) -- 1501
	return { -- 1503
		platform = App.platform, -- 1503
		locale = App.locale, -- 1504
		version = App.version, -- 1505
		debugging = App.debugging, -- 1505
		engineDev = engineDev, -- 1506
		webProfiler = webProfiler, -- 1507
		drawerWidth = drawerWidth, -- 1508
		webIDETourCompleted = webIDETourCompleted == true -- 1509
	} -- 1502
end) -- 1494
local ensureLLMConfigTable -- 1511
ensureLLMConfigTable = function() -- 1511
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 1512
	if columns and #columns > 0 then -- 1513
		local expected = { -- 1515
			id = true, -- 1515
			name = true, -- 1516
			url = true, -- 1517
			model = true, -- 1518
			api_key = true, -- 1519
			context_window = true, -- 1520
			temperature = true, -- 1521
			max_tokens = true, -- 1522
			reasoning_effort = true, -- 1523
			custom_options = true, -- 1524
			supports_function_calling = true, -- 1525
			active = true, -- 1526
			created_at = true, -- 1527
			updated_at = true -- 1528
		} -- 1514
		local existing = { } -- 1530
		local valid = true -- 1531
		for _index_0 = 1, #columns do -- 1532
			local row = columns[_index_0] -- 1532
			local columnName = tostring(row[2]) -- 1533
			existing[columnName] = true -- 1534
			if not expected[columnName] then -- 1535
				valid = false -- 1536
				break -- 1537
			end -- 1535
		end -- 1532
		if valid then -- 1538
			if not existing.context_window then -- 1539
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN context_window INTEGER NOT NULL DEFAULT 64000") -- 1540
			end -- 1539
			if not existing.temperature then -- 1541
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN temperature REAL NOT NULL DEFAULT 0.1") -- 1542
			end -- 1541
			if not existing.max_tokens then -- 1543
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 64000") -- 1544
			end -- 1543
			if not existing.reasoning_effort then -- 1545
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN reasoning_effort TEXT NOT NULL DEFAULT ''") -- 1546
			end -- 1545
			if not existing.custom_options then -- 1547
				DB:exec("ALTER TABLE LLMConfig ADD COLUMN custom_options TEXT NOT NULL DEFAULT ''") -- 1548
			end -- 1547
		else -- 1550
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 1550
		end -- 1538
	end -- 1513
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
	]]) -- 1551
	require("Agent.Config.LLMConfigMigration").upgradeLLMConfig() -- 1570
	return require("Agent.Config.LLMConfigNames").upgradeLLMConfigNames() -- 1571
end -- 1511
local normalizeContextWindow -- 1573
normalizeContextWindow = function(value) -- 1573
	local contextWindow = tonumber(value) -- 1574
	if contextWindow == nil or contextWindow < 64000 then -- 1575
		return 64000 -- 1576
	end -- 1575
	return math.max(64000, math.floor(contextWindow)) -- 1577
end -- 1573
local normalizeTemperature -- 1579
normalizeTemperature = function(value) -- 1579
	local temperature = tonumber(value) -- 1580
	if temperature == nil then -- 1581
		return 0.1 -- 1582
	end -- 1581
	return math.max(0, math.min(2, temperature)) -- 1583
end -- 1579
local normalizeMaxTokens -- 1585
normalizeMaxTokens = function(value) -- 1585
	local maxTokens = tonumber(value) -- 1586
	if maxTokens == nil or maxTokens < 1 then -- 1587
		return 64000 -- 1588
	end -- 1587
	return math.max(1, math.floor(maxTokens)) -- 1589
end -- 1585
local normalizeReasoningEffort -- 1591
normalizeReasoningEffort = function(value) -- 1591
	if value == nil then -- 1592
		return "" -- 1593
	end -- 1592
	local effort = tostring(value) -- 1594
	return effort:match("^%s*(.-)%s*$") or "" -- 1595
end -- 1591
local normalizeCustomOptions -- 1597
normalizeCustomOptions = function(value) -- 1597
	if value == nil then -- 1598
		return "" -- 1599
	end -- 1598
	local options = tostring(value) -- 1600
	options = options:match("^%s*(.-)%s*$") or "" -- 1601
	return options -- 1602
end -- 1597
local validateCustomOptions -- 1604
validateCustomOptions = function(value) -- 1604
	local options = normalizeCustomOptions(value) -- 1605
	if options == "" then -- 1606
		return true -- 1606
	end -- 1606
	if not options:match("^%s*{") then -- 1607
		return false -- 1607
	end -- 1607
	local decoded = json.decode(options) -- 1608
	return type(decoded) == "table" -- 1609
end -- 1604
HttpServer:post("/llm/list", function() -- 1611
	ensureLLMConfigTable() -- 1612
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options\n		from LLMConfig\n		order by id asc") -- 1613
	local items -- 1617
	if rows and #rows > 0 then -- 1617
		local _accum_0 = { } -- 1618
		local _len_0 = 1 -- 1618
		for _index_0 = 1, #rows do -- 1618
			local _des_0 = rows[_index_0] -- 1618
			local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8], _des_0[9], _des_0[10] -- 1618
			_accum_0[_len_0] = { -- 1619
				id = id, -- 1619
				name = name, -- 1619
				url = url, -- 1619
				model = model, -- 1619
				key = key, -- 1619
				contextWindow = normalizeContextWindow(contextWindow), -- 1619
				temperature = normalizeTemperature(temperature), -- 1619
				maxTokens = normalizeMaxTokens(maxTokens), -- 1619
				reasoningEffort = normalizeReasoningEffort(reasoningEffort), -- 1619
				customOptions = normalizeCustomOptions(customOptions) -- 1619
			} -- 1619
			_len_0 = _len_0 + 1 -- 1619
		end -- 1618
		items = _accum_0 -- 1617
	end -- 1617
	return { -- 1620
		success = true, -- 1620
		items = items -- 1620
	} -- 1620
end) -- 1611
HttpServer:post("/llm/create", function(req) -- 1622
	ensureLLMConfigTable() -- 1623
	do -- 1624
		local _type_0 = type(req) -- 1624
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1624
		if _tab_0 then -- 1624
			local body = req.body -- 1624
			if body ~= nil then -- 1624
				local name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions -- 1625
				local now = os.time() -- 1626
				if name == nil or url == nil or model == nil or key == nil then -- 1627
					return invalidArguments -- 1628
				end -- 1627
				local names = require("Agent.Config.LLMConfigNames") -- 1629
				name = names.normalizeLLMConfigName(name) -- 1630
				if not name then -- 1631
					return { -- 1631
						success = false, -- 1631
						code = "INVALID_LLM_CONFIG_NAME", -- 1631
						message = "LLM configuration name must be a non-empty string" -- 1631
					} -- 1631
				end -- 1631
				local nameCheck = names.checkLLMConfigName(name) -- 1632
				if not nameCheck.success then -- 1633
					return nameCheck -- 1633
				end -- 1633
				contextWindow = normalizeContextWindow(contextWindow) -- 1634
				temperature = normalizeTemperature(temperature) -- 1635
				maxTokens = normalizeMaxTokens(maxTokens) -- 1636
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1637
				customOptions = normalizeCustomOptions(customOptions) -- 1638
				if not validateCustomOptions(customOptions) then -- 1639
					return { -- 1639
						success = false, -- 1639
						message = "customOptions must be a JSON object" -- 1639
					} -- 1639
				end -- 1639
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 1646
					tostring(name), -- 1646
					tostring(url), -- 1647
					tostring(model), -- 1648
					tostring(key), -- 1649
					contextWindow, -- 1650
					temperature, -- 1651
					maxTokens, -- 1652
					reasoningEffort, -- 1653
					customOptions, -- 1654
					1, -- 1655
					now, -- 1656
					now -- 1657
				}) -- 1640
				if affected < 0 then -- 1659
					nameCheck = names.checkLLMConfigName(name) -- 1660
					if not nameCheck.success then -- 1661
						return nameCheck -- 1661
					end -- 1661
				end -- 1659
				return { -- 1662
					success = affected > 0 -- 1662
				} -- 1662
			end -- 1624
		end -- 1624
	end -- 1624
	return invalidArguments -- 1622
end) -- 1622
HttpServer:post("/llm/update", function(req) -- 1664
	ensureLLMConfigTable() -- 1665
	do -- 1666
		local _type_0 = type(req) -- 1666
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1666
		if _tab_0 then -- 1666
			local body = req.body -- 1666
			if body ~= nil then -- 1666
				local id, name, url, model, key, contextWindow, temperature, maxTokens, reasoningEffort, customOptions = body.id, body.name, body.url, body.model, body.key, body.contextWindow, body.temperature, body.maxTokens, body.reasoningEffort, body.customOptions -- 1667
				local now = os.time() -- 1668
				id = tonumber(id) -- 1669
				if id == nil or id <= 0 or id ~= math.floor(id) then -- 1670
					return invalidArguments -- 1670
				end -- 1670
				local names = require("Agent.Config.LLMConfigNames") -- 1671
				name = names.normalizeLLMConfigName(name) -- 1672
				if not name then -- 1673
					return { -- 1673
						success = false, -- 1673
						code = "INVALID_LLM_CONFIG_NAME", -- 1673
						message = "LLM configuration name must be a non-empty string" -- 1673
					} -- 1673
				end -- 1673
				local nameCheck = names.checkLLMConfigName(name, id) -- 1674
				if not nameCheck.success then -- 1675
					return nameCheck -- 1675
				end -- 1675
				contextWindow = normalizeContextWindow(contextWindow) -- 1676
				temperature = normalizeTemperature(temperature) -- 1677
				maxTokens = normalizeMaxTokens(maxTokens) -- 1678
				reasoningEffort = normalizeReasoningEffort(reasoningEffort) -- 1679
				customOptions = normalizeCustomOptions(customOptions) -- 1680
				if not validateCustomOptions(customOptions) then -- 1681
					return { -- 1681
						success = false, -- 1681
						message = "customOptions must be a JSON object" -- 1681
					} -- 1681
				end -- 1681
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, temperature = ?, max_tokens = ?, reasoning_effort = ?, custom_options = ?, updated_at = ?\n			where id = ?", { -- 1686
					tostring(name), -- 1686
					tostring(url), -- 1687
					tostring(model), -- 1688
					tostring(key), -- 1689
					contextWindow, -- 1690
					temperature, -- 1691
					maxTokens, -- 1692
					reasoningEffort, -- 1693
					customOptions, -- 1694
					now, -- 1695
					id -- 1696
				}) -- 1682
				if affected < 0 then -- 1698
					nameCheck = names.checkLLMConfigName(name, id) -- 1699
					if not nameCheck.success then -- 1700
						return nameCheck -- 1700
					end -- 1700
				end -- 1698
				return { -- 1701
					success = affected > 0 -- 1701
				} -- 1701
			end -- 1666
		end -- 1666
	end -- 1666
	return invalidArguments -- 1664
end) -- 1664
HttpServer:post("/llm/delete", function(req) -- 1703
	ensureLLMConfigTable() -- 1704
	do -- 1705
		local _type_0 = type(req) -- 1705
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1705
		if _tab_0 then -- 1705
			local id -- 1705
			do -- 1705
				local _obj_0 = req.body -- 1705
				local _type_1 = type(_obj_0) -- 1705
				if "table" == _type_1 or "userdata" == _type_1 then -- 1705
					id = _obj_0.id -- 1705
				end -- 1705
			end -- 1705
			if id ~= nil then -- 1705
				id = tonumber(id) -- 1706
				if id == nil then -- 1707
					return invalidArguments -- 1707
				end -- 1707
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 1708
					id -- 1708
				}) -- 1708
				return { -- 1709
					success = affected >= 0 -- 1709
				} -- 1709
			end -- 1705
		end -- 1705
	end -- 1705
	return invalidArguments -- 1703
end) -- 1703
HttpServer:post("/local-agent/list", function() -- 1711
	return { -- 1712
		success = true, -- 1712
		supported = AgentLocalAgent.isLocalAgentSupported(), -- 1712
		items = AgentLocalAgent.listConfigs() -- 1712
	} -- 1712
end) -- 1711
HttpServer:post("/local-agent/save", function(req) -- 1714
	do -- 1715
		local _type_0 = type(req) -- 1715
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1715
		if _tab_0 then -- 1715
			local body = req.body -- 1715
			if body ~= nil then -- 1715
				return AgentLocalAgent.saveConfig(body) -- 1716
			end -- 1715
		end -- 1715
	end -- 1715
	return invalidArguments -- 1714
end) -- 1714
HttpServer:post("/local-agent/delete", function(req) -- 1718
	do -- 1719
		local _type_0 = type(req) -- 1719
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1719
		if _tab_0 then -- 1719
			local id -- 1719
			do -- 1719
				local _obj_0 = req.body -- 1719
				local _type_1 = type(_obj_0) -- 1719
				if "table" == _type_1 or "userdata" == _type_1 then -- 1719
					id = _obj_0.id -- 1719
				end -- 1719
			end -- 1719
			if id ~= nil then -- 1719
				return AgentLocalAgent.deleteConfig(id) -- 1720
			end -- 1719
		end -- 1719
	end -- 1719
	return invalidArguments -- 1718
end) -- 1718
HttpServer:postSchedule("/local-agent/verify", function(req) -- 1722
	do -- 1723
		local _type_0 = type(req) -- 1723
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1723
		if _tab_0 then -- 1723
			local id -- 1723
			do -- 1723
				local _obj_0 = req.body -- 1723
				local _type_1 = type(_obj_0) -- 1723
				if "table" == _type_1 or "userdata" == _type_1 then -- 1723
					id = _obj_0.id -- 1723
				end -- 1723
			end -- 1723
			if id ~= nil then -- 1723
				return AgentLocalAgent.verifyConfig(id, req.body.projectRoot) -- 1724
			end -- 1723
		end -- 1723
	end -- 1723
	return invalidArguments -- 1722
end) -- 1722
HttpServer:post("/stat", function(req) -- 1726
	do -- 1727
		local _type_0 = type(req) -- 1727
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1727
		if _tab_0 then -- 1727
			local path -- 1727
			do -- 1727
				local _obj_0 = req.body -- 1727
				local _type_1 = type(_obj_0) -- 1727
				if "table" == _type_1 or "userdata" == _type_1 then -- 1727
					path = _obj_0.path -- 1727
				end -- 1727
			end -- 1727
			if path ~= nil then -- 1727
				if not Content:exist(path) then -- 1728
					return { -- 1729
						success = false, -- 1729
						message = "target not existed" -- 1729
					} -- 1729
				end -- 1728
				if Content:isdir(path) then -- 1730
					return { -- 1731
						success = false, -- 1731
						message = "failed to stat a directory" -- 1731
					} -- 1731
				end -- 1730
				local size, isBinary = Content:getAttr(path) -- 1732
				if size then -- 1732
					return { -- 1733
						success = true, -- 1733
						size = size, -- 1733
						isBinary = isBinary -- 1733
					} -- 1733
				end -- 1732
			end -- 1727
		end -- 1727
	end -- 1727
	return { -- 1726
		success = false, -- 1726
		message = "failed to stat" -- 1726
	} -- 1726
end) -- 1726
HttpServer:post("/new", function(req) -- 1735
	do -- 1736
		local _type_0 = type(req) -- 1736
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1736
		if _tab_0 then -- 1736
			local path -- 1736
			do -- 1736
				local _obj_0 = req.body -- 1736
				local _type_1 = type(_obj_0) -- 1736
				if "table" == _type_1 or "userdata" == _type_1 then -- 1736
					path = _obj_0.path -- 1736
				end -- 1736
			end -- 1736
			local content -- 1736
			do -- 1736
				local _obj_0 = req.body -- 1736
				local _type_1 = type(_obj_0) -- 1736
				if "table" == _type_1 or "userdata" == _type_1 then -- 1736
					content = _obj_0.content -- 1736
				end -- 1736
			end -- 1736
			local folder -- 1736
			do -- 1736
				local _obj_0 = req.body -- 1736
				local _type_1 = type(_obj_0) -- 1736
				if "table" == _type_1 or "userdata" == _type_1 then -- 1736
					folder = _obj_0.folder -- 1736
				end -- 1736
			end -- 1736
			if path ~= nil and content ~= nil and folder ~= nil then -- 1736
				if Content:exist(path) then -- 1737
					return { -- 1738
						success = false, -- 1738
						message = "TargetExisted" -- 1738
					} -- 1738
				end -- 1737
				local parent = Path:getPath(path) -- 1739
				local files = Content:getFiles(parent) -- 1740
				if folder then -- 1741
					local name = Path:getFilename(path):lower() -- 1742
					for _index_0 = 1, #files do -- 1743
						local file = files[_index_0] -- 1743
						if name == Path:getFilename(file):lower() then -- 1744
							return { -- 1745
								success = false, -- 1745
								message = "TargetExisted" -- 1745
							} -- 1745
						end -- 1744
					end -- 1743
					if Content:mkdir(path) then -- 1746
						return { -- 1747
							success = true -- 1747
						} -- 1747
					end -- 1746
				else -- 1749
					local name = Path:getName(path):lower() -- 1749
					local targetExt = Path:getExt(path) -- 1750
					for _index_0 = 1, #files do -- 1751
						local file = files[_index_0] -- 1751
						if name == Path:getName(file):lower() then -- 1752
							local ext = Path:getExt(file) -- 1753
							if not ("tl" == targetExt or "yue" == targetExt or "ts" == targetExt or "tsx" == targetExt or "vs" == targetExt or "bl" == targetExt or "xml" == targetExt or "lua" == targetExt) or not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 1754
								goto _continue_0 -- 1755
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 1756
								goto _continue_0 -- 1757
							end -- 1754
							return { -- 1758
								success = false, -- 1758
								message = "SourceExisted" -- 1758
							} -- 1758
						end -- 1752
						::_continue_0:: -- 1752
					end -- 1751
					if Content:save(path, content) then -- 1759
						return { -- 1760
							success = true -- 1760
						} -- 1760
					end -- 1759
				end -- 1741
			end -- 1736
		end -- 1736
	end -- 1736
	return { -- 1735
		success = false, -- 1735
		message = "Failed" -- 1735
	} -- 1735
end) -- 1735
local deleteAsset -- 1762
deleteAsset = function(path) -- 1762
	if not Content:exist(path) then -- 1763
		return false -- 1763
	end -- 1763
	local projectRoot -- 1764
	if Content:isdir(path) and isProjectRootDir(path) then -- 1764
		projectRoot = path -- 1764
	else -- 1764
		projectRoot = nil -- 1764
	end -- 1764
	local parent = Path:getPath(path) -- 1765
	local files = Content:getFiles(parent) -- 1766
	local name = Path:getName(path):lower() -- 1767
	local ext = Path:getExt(path) -- 1768
	for _index_0 = 1, #files do -- 1769
		local file = files[_index_0] -- 1769
		if name == Path:getName(file):lower() then -- 1770
			local _exp_0 = Path:getExt(file) -- 1771
			if "tl" == _exp_0 then -- 1771
				if ("vs" == ext) then -- 1771
					Content:remove(Path(parent, file)) -- 1772
				end -- 1771
			elseif "lua" == _exp_0 then -- 1773
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1773
					Content:remove(Path(parent, file)) -- 1774
				end -- 1773
			end -- 1771
		end -- 1770
	end -- 1769
	if Content:remove(path) then -- 1775
		if projectRoot then -- 1776
			AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 1777
		end -- 1776
		return true -- 1778
	end -- 1775
	return false -- 1779
end -- 1762
local moveAsset -- 1781
moveAsset = function(old, new) -- 1781
	if not (Content:exist(old) and not Content:exist(new)) then -- 1782
		return false -- 1782
	end -- 1782
	local renamedDir = Content:isdir(old) -- 1783
	local parent = Path:getPath(new) -- 1784
	local files = Content:getFiles(parent) -- 1785
	if renamedDir then -- 1786
		local name = Path:getFilename(new):lower() -- 1787
		for _index_0 = 1, #files do -- 1788
			local file = files[_index_0] -- 1788
			if name == Path:getFilename(file):lower() then -- 1789
				return false -- 1790
			end -- 1789
		end -- 1788
	else -- 1792
		local name = Path:getName(new):lower() -- 1792
		local ext = Path:getExt(new) -- 1793
		for _index_0 = 1, #files do -- 1794
			local file = files[_index_0] -- 1794
			if name == Path:getName(file):lower() then -- 1795
				local fileExt = Path:getExt(file) -- 1796
				if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) or not ("tl" == fileExt or "yue" == fileExt or "ts" == fileExt or "tsx" == fileExt or "vs" == fileExt or "bl" == fileExt or "xml" == fileExt or "lua" == fileExt) then -- 1797
					goto _continue_0 -- 1798
				elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 1799
					goto _continue_0 -- 1800
				end -- 1797
				return false -- 1801
			end -- 1795
			::_continue_0:: -- 1795
		end -- 1794
	end -- 1786
	if not Content:move(old, new) then -- 1802
		return false -- 1802
	end -- 1802
	if renamedDir then -- 1803
		AgentSession.renameSessionsByProjectRoot(old, new) -- 1804
	end -- 1803
	local newParent = Path:getPath(new) -- 1805
	parent = Path:getPath(old) -- 1806
	files = Content:getFiles(parent) -- 1807
	local newName = Path:getName(new) -- 1808
	local oldName = Path:getName(old) -- 1809
	local name = oldName:lower() -- 1810
	local ext = Path:getExt(old) -- 1811
	for _index_0 = 1, #files do -- 1812
		local file = files[_index_0] -- 1812
		if name == Path:getName(file):lower() then -- 1813
			local _exp_0 = Path:getExt(file) -- 1814
			if "tl" == _exp_0 then -- 1814
				if ("vs" == ext) then -- 1814
					Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 1815
				end -- 1814
			elseif "lua" == _exp_0 then -- 1816
				if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 1816
					Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 1817
				end -- 1816
			end -- 1814
		end -- 1813
	end -- 1812
	return true -- 1818
end -- 1781
HttpServer:post("/delete", function(req) -- 1820
	do -- 1821
		local _type_0 = type(req) -- 1821
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1821
		if _tab_0 then -- 1821
			local path -- 1821
			do -- 1821
				local _obj_0 = req.body -- 1821
				local _type_1 = type(_obj_0) -- 1821
				if "table" == _type_1 or "userdata" == _type_1 then -- 1821
					path = _obj_0.path -- 1821
				end -- 1821
			end -- 1821
			if path ~= nil then -- 1821
				if deleteAsset(path) then -- 1822
					return { -- 1822
						success = true -- 1822
					} -- 1822
				end -- 1822
			end -- 1821
		end -- 1821
	end -- 1821
	return { -- 1820
		success = false -- 1820
	} -- 1820
end) -- 1820
HttpServer:post("/rename", function(req) -- 1824
	do -- 1825
		local _type_0 = type(req) -- 1825
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1825
		if _tab_0 then -- 1825
			local old -- 1825
			do -- 1825
				local _obj_0 = req.body -- 1825
				local _type_1 = type(_obj_0) -- 1825
				if "table" == _type_1 or "userdata" == _type_1 then -- 1825
					old = _obj_0.old -- 1825
				end -- 1825
			end -- 1825
			local new -- 1825
			do -- 1825
				local _obj_0 = req.body -- 1825
				local _type_1 = type(_obj_0) -- 1825
				if "table" == _type_1 or "userdata" == _type_1 then -- 1825
					new = _obj_0.new -- 1825
				end -- 1825
			end -- 1825
			if old ~= nil and new ~= nil then -- 1825
				if moveAsset(old, new) then -- 1826
					return { -- 1826
						success = true -- 1826
					} -- 1826
				end -- 1826
			end -- 1825
		end -- 1825
	end -- 1825
	return { -- 1824
		success = false -- 1824
	} -- 1824
end) -- 1824
local normalizeAssetPaths -- 1828
normalizeAssetPaths = function(paths) -- 1828
	if not (type(paths) == "table") then -- 1829
		return nil -- 1829
	end -- 1829
	local unique = { } -- 1830
	local candidates = { } -- 1831
	for _index_0 = 1, #paths do -- 1832
		local path = paths[_index_0] -- 1832
		if not (type(path) == "string") then -- 1833
			return nil -- 1833
		end -- 1833
		local relative = relativeToRoot(path, Content.writablePath) -- 1834
		if relative == nil or relative == "" or not Content:exist(path) then -- 1835
			return nil -- 1835
		end -- 1835
		if not unique[path] then -- 1836
			unique[path] = true -- 1837
			candidates[#candidates + 1] = path -- 1838
		end -- 1836
	end -- 1832
	table.sort(candidates, function(a, b) -- 1839
		return #a < #b -- 1839
	end) -- 1839
	local result = { } -- 1840
	for _index_0 = 1, #candidates do -- 1841
		local path = candidates[_index_0] -- 1841
		local contained = false -- 1842
		for _index_1 = 1, #result do -- 1843
			local parent = result[_index_1] -- 1843
			if relativeToRoot(path, parent) ~= nil then -- 1844
				contained = true -- 1845
				break -- 1846
			end -- 1844
		end -- 1843
		if not contained then -- 1847
			result[#result + 1] = path -- 1847
		end -- 1847
	end -- 1841
	return result -- 1848
end -- 1828
HttpServer:postSchedule("/assets/batch", function(req) -- 1850
	do -- 1851
		local _type_0 = type(req) -- 1851
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1851
		if _tab_0 then -- 1851
			local operation -- 1851
			do -- 1851
				local _obj_0 = req.body -- 1851
				local _type_1 = type(_obj_0) -- 1851
				if "table" == _type_1 or "userdata" == _type_1 then -- 1851
					operation = _obj_0.operation -- 1851
				end -- 1851
			end -- 1851
			local sources -- 1851
			do -- 1851
				local _obj_0 = req.body -- 1851
				local _type_1 = type(_obj_0) -- 1851
				if "table" == _type_1 or "userdata" == _type_1 then -- 1851
					sources = _obj_0.sources -- 1851
				end -- 1851
			end -- 1851
			if operation ~= nil and sources ~= nil then -- 1851
				if not (("delete" == operation or "copy" == operation or "move" == operation)) then -- 1852
					return { -- 1852
						success = false, -- 1852
						message = "invalid operation" -- 1852
					} -- 1852
				end -- 1852
				sources = normalizeAssetPaths(sources) -- 1853
				if not (sources and #sources > 0) then -- 1854
					return { -- 1854
						success = false, -- 1854
						message = "invalid sources" -- 1854
					} -- 1854
				end -- 1854
				local target = req.body.target -- 1855
				local destinations = { } -- 1856
				if operation ~= "delete" then -- 1857
					if not (type(target) == "string") then -- 1858
						return { -- 1858
							success = false, -- 1858
							message = "invalid target" -- 1858
						} -- 1858
					end -- 1858
					local targetRelative = relativeToRoot(target, Content.writablePath) -- 1859
					if targetRelative == nil then -- 1860
						return { -- 1860
							success = false, -- 1860
							message = "invalid target" -- 1860
						} -- 1860
					end -- 1860
					if not (Content:exist(target) and Content:isdir(target)) then -- 1861
						return { -- 1861
							success = false, -- 1861
							message = "invalid target" -- 1861
						} -- 1861
					end -- 1861
					for _index_0 = 1, #sources do -- 1862
						local source = sources[_index_0] -- 1862
						if Content:isdir(source) and relativeToRoot(target, source) ~= nil then -- 1863
							return { -- 1864
								success = false, -- 1864
								message = "target inside source" -- 1864
							} -- 1864
						end -- 1863
						local destination = Path(target, Path:getFilename(source)) -- 1865
						if Content:exist(destination) then -- 1866
							return { -- 1866
								success = false, -- 1866
								message = "target existed" -- 1866
							} -- 1866
						end -- 1866
						if destinations[destination] then -- 1867
							return { -- 1867
								success = false, -- 1867
								message = "duplicate target" -- 1867
							} -- 1867
						end -- 1867
						destinations[destination] = true -- 1868
					end -- 1862
				end -- 1857
				local changes = { } -- 1869
				local affectedSet = { } -- 1870
				local affectedDirectories = { } -- 1871
				local addAffected -- 1872
				addAffected = function(dir) -- 1872
					if affectedSet[dir] then -- 1873
						return -- 1873
					end -- 1873
					affectedSet[dir] = true -- 1874
					affectedDirectories[#affectedDirectories + 1] = dir -- 1875
				end -- 1872
				if operation ~= "delete" then -- 1876
					addAffected(target) -- 1876
				end -- 1876
				for _index_0 = 1, #sources do -- 1877
					local source = sources[_index_0] -- 1877
					addAffected(Path:getPath(source)) -- 1878
					if operation == "delete" then -- 1879
						if not deleteAsset(source) then -- 1880
							return { -- 1880
								success = false, -- 1880
								message = "delete failed", -- 1880
								changes = changes, -- 1880
								affectedDirectories = affectedDirectories -- 1880
							} -- 1880
						end -- 1880
						changes[#changes + 1] = { -- 1881
							old = source -- 1881
						} -- 1881
					else -- 1883
						local destination = Path(target, Path:getFilename(source)) -- 1883
						local ok -- 1884
						if operation == "copy" then -- 1884
							ok = Content:copyAsync(source, destination) -- 1885
						else -- 1887
							ok = moveAsset(source, destination) -- 1887
						end -- 1884
						if not ok then -- 1888
							return { -- 1888
								success = false, -- 1888
								message = operation .. " failed", -- 1888
								changes = changes, -- 1888
								affectedDirectories = affectedDirectories -- 1888
							} -- 1888
						end -- 1888
						changes[#changes + 1] = { -- 1889
							old = source, -- 1889
							new = destination -- 1889
						} -- 1889
					end -- 1879
				end -- 1877
				return { -- 1890
					success = true, -- 1890
					changes = changes, -- 1890
					affectedDirectories = affectedDirectories -- 1890
				} -- 1890
			end -- 1851
		end -- 1851
	end -- 1851
	return { -- 1850
		success = false, -- 1850
		message = "invalid request" -- 1850
	} -- 1850
end) -- 1850
local projectFallbackPaths -- 1892
projectFallbackPaths = function(projectRoot, projFile) -- 1892
	local paths, seen = { }, { } -- 1893
	local add -- 1894
	add = function(dir) -- 1894
		if dir and dir ~= "" and not seen[dir] and Content:isdir(dir) then -- 1895
			seen[dir] = true -- 1896
			paths[#paths + 1] = dir -- 1897
		end -- 1895
	end -- 1894
	local addRoot -- 1898
	addRoot = function(root) -- 1898
		local roots = GetProjectSearchPaths(root) -- 1899
		for index = #roots, 1, -1 do -- 1900
			add(roots[index]) -- 1901
		end -- 1900
	end -- 1898
	addRoot(projectRoot) -- 1902
	if projFile and projFile ~= "" then -- 1903
		local projDir = getProjectDirFromFile(projFile) -- 1904
		if projDir then -- 1904
			addRoot(projDir) -- 1905
		else -- 1907
			add(Path:getPath(projFile)) -- 1907
		end -- 1904
	end -- 1903
	return paths -- 1908
end -- 1892
local withProjectSearchPaths -- 1910
withProjectSearchPaths = function(projectRoot, projFile, fn) -- 1910
	local fallbackPaths = projectFallbackPaths(projectRoot, projFile) -- 1911
	if not (#fallbackPaths > 0) then -- 1912
		return fn() -- 1912
	end -- 1912
	local searchPaths = Content.searchPaths -- 1913
	for _index_0 = 1, #fallbackPaths do -- 1914
		local dir = fallbackPaths[_index_0] -- 1914
		Content:addSearchPath(dir) -- 1914
	end -- 1914
	local _ <close> = setmetatable({ }, { -- 1915
		__close = function() -- 1915
			Content.searchPaths = searchPaths -- 1915
		end -- 1915
	}) -- 1915
	return fn() -- 1916
end -- 1910
HttpServer:post("/exist", function(req) -- 1917
	do -- 1918
		local _type_0 = type(req) -- 1918
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1918
		if _tab_0 then -- 1918
			local file -- 1918
			do -- 1918
				local _obj_0 = req.body -- 1918
				local _type_1 = type(_obj_0) -- 1918
				if "table" == _type_1 or "userdata" == _type_1 then -- 1918
					file = _obj_0.file -- 1918
				end -- 1918
			end -- 1918
			if file ~= nil then -- 1918
				return withProjectSearchPaths(req.body.projectRoot, req.body.projFile, function() -- 1919
					return { -- 1920
						success = Content:exist(file) -- 1920
					} -- 1920
				end) -- 1919
			end -- 1918
		end -- 1918
	end -- 1918
	return { -- 1917
		success = false -- 1917
	} -- 1917
end) -- 1917
HttpServer:postSchedule("/read", function(req) -- 1921
	do -- 1922
		local _type_0 = type(req) -- 1922
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1922
		if _tab_0 then -- 1922
			local path -- 1922
			do -- 1922
				local _obj_0 = req.body -- 1922
				local _type_1 = type(_obj_0) -- 1922
				if "table" == _type_1 or "userdata" == _type_1 then -- 1922
					path = _obj_0.path -- 1922
				end -- 1922
			end -- 1922
			if path ~= nil then -- 1922
				local readFile -- 1923
				readFile = function() -- 1923
					if Content:exist(path) and not Content:isdir(path) then -- 1924
						local content = Content:loadAsync(path) -- 1925
						if content then -- 1925
							return { -- 1926
								content = content, -- 1926
								success = true, -- 1926
								fullPath = Content:getFullPath(path) -- 1926
							} -- 1926
						end -- 1925
					end -- 1924
					return nil -- 1923
				end -- 1923
				local result = withProjectSearchPaths(req.body.projectRoot, req.body.projFile, readFile) -- 1927
				if result then -- 1927
					return result -- 1927
				end -- 1927
			end -- 1922
		end -- 1922
	end -- 1922
	return { -- 1921
		success = false -- 1921
	} -- 1921
end) -- 1921
local agentDocLanguage -- 1929
agentDocLanguage = function(language) -- 1929
	if language == "zh-Hans" then -- 1930
		return "zh" -- 1930
	else -- 1930
		return "en" -- 1930
	end -- 1930
end -- 1929
HttpServer:postSchedule("/doc/search", function(req) -- 1932
	local body = req.body or { } -- 1933
	local language = body.docLanguage -- 1934
	if not (("en" == language or "zh-Hans" == language)) then -- 1935
		return { -- 1935
			success = false, -- 1935
			message = "unsupported doc language" -- 1935
		} -- 1935
	end -- 1935
	local docType = body.docType -- 1936
	if not (("dora-tutorial" == docType or "dora-api" == docType or "love-api" == docType or "tic80-api" == docType)) then -- 1937
		return { -- 1937
			success = false, -- 1937
			message = "unsupported doc type" -- 1937
		} -- 1937
	end -- 1937
	local codeLanguage = body.programmingLanguage -- 1938
	if not (("ts" == codeLanguage or "tsx" == codeLanguage or "lua" == codeLanguage or "yue" == codeLanguage or "tl" == codeLanguage or "wa" == codeLanguage)) then -- 1939
		return { -- 1939
			success = false, -- 1939
			message = "unsupported programming language" -- 1939
		} -- 1939
	end -- 1939
	if not body.pattern then -- 1940
		return { -- 1940
			success = false, -- 1940
			message = "missing pattern" -- 1940
		} -- 1940
	end -- 1940
	local result = nil -- 1941
	AgentTools.searchDoraDocHttp({ -- 1943
		pattern = body.pattern, -- 1943
		docLanguage = agentDocLanguage(language), -- 1944
		docType = docType, -- 1945
		programmingLanguage = codeLanguage, -- 1946
		limit = body.limit, -- 1947
		useRegex = body.useRegex, -- 1948
		caseSensitive = body.caseSensitive, -- 1949
		includeContent = body.includeContent, -- 1950
		contentWindow = body.contentWindow -- 1951
	}, function(res) -- 1952
		result = res -- 1953
	end) -- 1942
	wait(function() -- 1954
		return result ~= nil -- 1954
	end) -- 1954
	if result and result.success then -- 1955
		result.docLanguage = language -- 1956
	end -- 1955
	if result then -- 1957
		return result -- 1958
	else -- 1960
		return { -- 1960
			success = false, -- 1960
			message = "doc search failed" -- 1960
		} -- 1960
	end -- 1957
	return { -- 1932
		success = false, -- 1932
		message = "invalid call" -- 1932
	} -- 1932
end) -- 1932
HttpServer:postSchedule("/doc/read", function(req) -- 1962
	local body = req.body or { } -- 1963
	local language = body.docLanguage -- 1964
	if not (("en" == language or "zh-Hans" == language)) then -- 1965
		return { -- 1965
			success = false, -- 1965
			message = "unsupported doc language" -- 1965
		} -- 1965
	end -- 1965
	if not body.file then -- 1966
		return { -- 1966
			success = false, -- 1966
			message = "missing file" -- 1966
		} -- 1966
	end -- 1966
	local result = AgentTools.readDoraDoc({ -- 1968
		docLanguage = agentDocLanguage(language), -- 1968
		file = body.file, -- 1969
		startLine = body.startLine, -- 1970
		endLine = body.endLine -- 1971
	}) -- 1967
	if result and result.success then -- 1972
		result.docLanguage = language -- 1973
	end -- 1972
	return result -- 1974
end) -- 1962
local readSyncFile -- 1976
readSyncFile = function(req) -- 1976
	do -- 1977
		local _type_0 = type(req) -- 1977
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1977
		if _tab_0 then -- 1977
			local params = req.params -- 1977
			if params ~= nil then -- 1977
				local path = params.path -- 1978
				if not (type(path) == "string" and path ~= "") then -- 1979
					return { -- 1979
						success = false, -- 1979
						message = "invalid path" -- 1979
					} -- 1979
				end -- 1979
				local exts -- 1980
				if params.exts then -- 1980
					local _accum_0 = { } -- 1981
					local _len_0 = 1 -- 1981
					for ext in params.exts:gmatch("[^|]*") do -- 1981
						_accum_0[_len_0] = ext -- 1981
						_len_0 = _len_0 + 1 -- 1981
					end -- 1981
					exts = _accum_0 -- 1981
				else -- 1982
					exts = { -- 1982
						"" -- 1982
					} -- 1982
				end -- 1980
				local readFileAt -- 1983
				readFileAt = function(targetPath) -- 1983
					if Content:exist(targetPath) then -- 1984
						local content = Content:load(targetPath) -- 1985
						if content then -- 1985
							return { -- 1986
								content = content, -- 1986
								success = true, -- 1986
								fullPath = Content:getFullPath(targetPath) -- 1986
							} -- 1986
						end -- 1985
					end -- 1984
					return nil -- 1983
				end -- 1983
				local readFile -- 1987
				readFile = function(fallbackPaths) -- 1987
					for _index_0 = 1, #exts do -- 1988
						local ext = exts[_index_0] -- 1988
						local targetPath = path .. ext -- 1989
						if not Content:isAbsolutePath(targetPath) then -- 1990
							for _index_1 = 1, #fallbackPaths do -- 1991
								local fallback = fallbackPaths[_index_1] -- 1991
								local fallbackResult = readFileAt(Path(fallback, targetPath)) -- 1992
								if fallbackResult then -- 1992
									return fallbackResult -- 1993
								end -- 1992
							end -- 1991
						end -- 1990
						local fileResult = readFileAt(targetPath) -- 1994
						if fileResult then -- 1994
							return fileResult -- 1995
						end -- 1994
					end -- 1988
					return nil -- 1987
				end -- 1987
				local readResult = readFile(projectFallbackPaths(params.projectRoot, params.projFile)) -- 1996
				if readResult then -- 1996
					return readResult -- 1997
				end -- 1996
			end -- 1977
		end -- 1977
	end -- 1977
	return { -- 1976
		success = false -- 1976
	} -- 1976
end -- 1976
HttpServer:get("/read-sync", readSyncFile) -- 1999
HttpServer:post("/read-sync", function(req) -- 2000
	return readSyncFile({ -- 2000
		params = req.body -- 2000
	}) -- 2000
end) -- 2000
local addGeneratedSourceHeader -- 2002
addGeneratedSourceHeader = function(codes, language, file, preserveTIC80) -- 2002
	if preserveTIC80 == nil then -- 2002
		preserveTIC80 = false -- 2002
	end -- 2002
	local header = "-- [" .. tostring(language) .. "]: " .. tostring(file) -- 2003
	if preserveTIC80 then -- 2004
		if codes:match("^%-%-[ \t]*tic80[ \t]*[\r\n]") then -- 2005
			return (codes:gsub("^([^\r\n]*\r?\n)", "%1" .. tostring(header) .. "\n", 1)) -- 2006
		end -- 2005
		return "-- tic80\n" .. tostring(header) .. "\n" .. tostring(codes) -- 2007
	end -- 2004
	return tostring(header) .. "\n" .. tostring(codes) -- 2008
end -- 2002
local compileFileAsync -- 2010
compileFileAsync = function(inputFile, sourceCodes, projectRoot) -- 2010
	if projectRoot == nil then -- 2010
		projectRoot = nil -- 2010
	end -- 2010
	local file = inputFile -- 2011
	local searchPath -- 2012
	if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2012
		file = relativeToRoot(inputFile, projectRoot) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2013
		searchPath = Path(projectRoot, "Script", "?.lua") .. ";" .. Path(projectRoot, "?.lua") -- 2016
	elseif not Content:isAbsolutePath(inputFile) then -- 2017
		searchPath = "" -- 2018
	else -- 2019
		local dir = getProjectDirFromFile(inputFile) -- 2019
		if dir then -- 2019
			file = relativeToRoot(inputFile, dir) or relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2020
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 2024
		else -- 2026
			file = relativeToRoot(inputFile, Content.writablePath) or relativeToRoot(inputFile, Content.assetPath) or inputFile -- 2026
			searchPath = "" -- 2029
		end -- 2019
	end -- 2012
	local outputFile = Path:replaceExt(inputFile, "lua") -- 2030
	local yueext = yue.options.extension -- 2031
	local resultCodes = nil -- 2032
	local resultError = nil -- 2033
	do -- 2034
		local _exp_0 = Path:getExt(inputFile) -- 2034
		if yueext == _exp_0 then -- 2034
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 2035
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 2036
				if not codes then -- 2037
					resultError = err -- 2038
					return -- 2039
				end -- 2037
				local extraGlobal -- 2040
				if isTIC80 then -- 2040
					extraGlobal = tic80APIs -- 2040
				else -- 2040
					extraGlobal = nil -- 2040
				end -- 2040
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 2041
				if not success then -- 2042
					local diagnostics -- 2043
					do -- 2043
						local _accum_0 = { } -- 2043
						local _len_0 = 1 -- 2043
						for _index_0 = 1, #message do -- 2043
							local _des_0 = message[_index_0] -- 2043
							local name, row, column = _des_0[1], _des_0[2], _des_0[3] -- 2043
							_accum_0[_len_0] = tostring(file) .. ":" .. tostring(row) .. ":" .. tostring(column) .. ": unknown global '" .. tostring(name) .. "'" -- 2044
							_len_0 = _len_0 + 1 -- 2044
						end -- 2043
						diagnostics = _accum_0 -- 2043
					end -- 2043
					resultError = table.concat(diagnostics, "\n") -- 2045
					return -- 2046
				end -- 2042
				if codes == "" then -- 2047
					resultCodes = "" -- 2048
					return nil -- 2049
				end -- 2047
				resultCodes = addGeneratedSourceHeader(codes, "yue", file, isTIC80) -- 2050
				return resultCodes -- 2051
			end, function(success) -- 2036
				if not success then -- 2052
					if resultCodes == nil then -- 2053
						resultCodes = false -- 2054
					elseif resultCodes ~= "" then -- 2055
						resultCodes = false -- 2056
						resultError = "failed to save " .. tostring(outputFile) -- 2057
					end -- 2053
				end -- 2052
			end) -- 2036
		elseif "tl" == _exp_0 then -- 2058
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 2059
			if isTIC80 then -- 2060
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 2061
			end -- 2060
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 2062
			if codes then -- 2063
				if isTIC80 then -- 2064
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 2065
				end -- 2064
				resultCodes = addGeneratedSourceHeader(codes, "tl", file, isTIC80) -- 2066
				if not Content:saveAsync(outputFile, resultCodes) then -- 2067
					resultCodes = false -- 2068
					resultError = "failed to save " .. tostring(outputFile) -- 2069
				end -- 2067
			else -- 2071
				resultCodes = false -- 2071
				resultError = err -- 2072
			end -- 2063
		elseif "xml" == _exp_0 then -- 2073
			local codes, err = xml.tolua(sourceCodes) -- 2074
			if codes then -- 2075
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 2076
				if not Content:saveAsync(outputFile, resultCodes) then -- 2077
					resultCodes = false -- 2078
					resultError = "failed to save " .. tostring(outputFile) -- 2079
				end -- 2077
			else -- 2081
				resultCodes = false -- 2081
				resultError = err -- 2082
			end -- 2075
		end -- 2034
	end -- 2034
	wait(function() -- 2083
		return resultCodes ~= nil -- 2083
	end) -- 2083
	if resultCodes then -- 2084
		return resultCodes -- 2085
	else -- 2087
		return nil, resultError -- 2087
	end -- 2084
	return nil -- 2010
end -- 2010
HttpServer:postSchedule("/write", function(req) -- 2089
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2090
	local buildSucceeded = false -- 2091
	local _ <close> = setmetatable({ }, { -- 2092
		__close = function() -- 2092
			return finishUpdate(buildSucceeded) -- 2092
		end -- 2092
	}) -- 2092
	do -- 2093
		local _type_0 = type(req) -- 2093
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2093
		if _tab_0 then -- 2093
			local path -- 2093
			do -- 2093
				local _obj_0 = req.body -- 2093
				local _type_1 = type(_obj_0) -- 2093
				if "table" == _type_1 or "userdata" == _type_1 then -- 2093
					path = _obj_0.path -- 2093
				end -- 2093
			end -- 2093
			local content -- 2093
			do -- 2093
				local _obj_0 = req.body -- 2093
				local _type_1 = type(_obj_0) -- 2093
				if "table" == _type_1 or "userdata" == _type_1 then -- 2093
					content = _obj_0.content -- 2093
				end -- 2093
			end -- 2093
			if path ~= nil and content ~= nil then -- 2093
				if Content:saveAsync(path, content) then -- 2094
					do -- 2095
						local _exp_0 = Path:getExt(path) -- 2095
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2095
							if '' == Path:getExt(Path:getName(path)) then -- 2096
								local resultCodes = compileFileAsync(path, content) -- 2097
								buildSucceeded = resultCodes ~= nil -- 2098
								return { -- 2099
									success = true, -- 2099
									resultCodes = resultCodes -- 2099
								} -- 2099
							end -- 2096
						end -- 2095
					end -- 2095
					buildSucceeded = true -- 2100
					return { -- 2101
						success = true -- 2101
					} -- 2101
				end -- 2094
			end -- 2093
		end -- 2093
	end -- 2093
	return { -- 2089
		success = false -- 2089
	} -- 2089
end) -- 2089
local getWaProjectDirFromFile = nil -- 2103
HttpServer:postSchedule("/build", function(req) -- 2105
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 2106
	local buildSucceeded = false -- 2107
	local _ <close> = setmetatable({ }, { -- 2108
		__close = function() -- 2108
			return finishUpdate(buildSucceeded) -- 2108
		end -- 2108
	}) -- 2108
	do -- 2109
		local _type_0 = type(req) -- 2109
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2109
		if _tab_0 then -- 2109
			local path -- 2109
			do -- 2109
				local _obj_0 = req.body -- 2109
				local _type_1 = type(_obj_0) -- 2109
				if "table" == _type_1 or "userdata" == _type_1 then -- 2109
					path = _obj_0.path -- 2109
				end -- 2109
			end -- 2109
			if path ~= nil then -- 2109
				local projectRoot = req.body.projectRoot -- 2110
				if Content:isdir(path) then -- 2111
					local projDir = getWaProjectDirFromFile(path) -- 2112
					if projDir then -- 2112
						local message = Wasm:buildWaAsync(projDir) -- 2113
						if message == "" then -- 2114
							return { -- 2115
								success = true -- 2115
							} -- 2115
						else -- 2117
							return { -- 2117
								success = false, -- 2117
								message = message -- 2117
							} -- 2117
						end -- 2114
					end -- 2112
				end -- 2111
				local _exp_0 = Path:getExt(path) -- 2118
				if "gd" == _exp_0 or "tscn" == _exp_0 or "tres" == _exp_0 or "gdshader" == _exp_0 or "gdshaderinc" == _exp_0 then -- 2119
					local content = Content:loadAsync(path) -- 2120
					if content then -- 2120
						local result = godotCheckAsync(path, content, false) -- 2121
						buildSucceeded = result.success and not result.skipped -- 2122
						return { -- 2123
							success = buildSucceeded, -- 2123
							resultCodes = "", -- 2123
							info = result.info -- 2123
						} -- 2123
					end -- 2120
				elseif "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 2124
					if '' == Path:getExt(Path:getName(path)) then -- 2125
						local content = Content:loadAsync(path) -- 2126
						if content then -- 2126
							local resultCodes, compileError = compileFileAsync(path, content, projectRoot) -- 2127
							if resultCodes then -- 2128
								buildSucceeded = true -- 2129
								return { -- 2130
									success = true, -- 2130
									resultCodes = resultCodes -- 2130
								} -- 2130
							end -- 2128
							return { -- 2131
								success = false, -- 2131
								message = compileError or "Compilation failed" -- 2131
							} -- 2131
						end -- 2126
					end -- 2125
				elseif "wa" == _exp_0 then -- 2132
					local projDir = getWaProjectDirFromFile(path) -- 2133
					if projDir then -- 2133
						local message = Wasm:buildWaAsync(projDir) -- 2134
						if message == "" then -- 2135
							return { -- 2136
								success = true -- 2136
							} -- 2136
						else -- 2138
							return { -- 2138
								success = false, -- 2138
								message = message -- 2138
							} -- 2138
						end -- 2135
					else -- 2140
						return { -- 2140
							success = false, -- 2140
							message = 'Wa file needs a project' -- 2140
						} -- 2140
					end -- 2133
				end -- 2118
			end -- 2109
		end -- 2109
	end -- 2109
	return { -- 2105
		success = false -- 2105
	} -- 2105
end) -- 2105
local extentionLevels = { -- 2143
	vs = 2, -- 2143
	bl = 2, -- 2144
	ts = 1, -- 2145
	tsx = 1, -- 2146
	tl = 1, -- 2147
	yue = 1, -- 2148
	xml = 1, -- 2149
	lua = 0 -- 2150
} -- 2142
local visitAssets -- 2152
visitAssets = function(path, workspace, builtin, recursive) -- 2152
	if recursive == nil then -- 2152
		recursive = true -- 2152
	end -- 2152
	local children = nil -- 2153
	local dirs = Content:getDirs(path) -- 2154
	for _index_0 = 1, #dirs do -- 2155
		local dir = dirs[_index_0] -- 2155
		if workspace then -- 2156
			if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir or ".godot" == dir or ".native-export" == dir or "node_modules" == dir) then -- 2157
				goto _continue_0 -- 2158
			end -- 2157
		elseif dir == ".git" or dir == ".godot" then -- 2159
			goto _continue_0 -- 2160
		end -- 2156
		if not children then -- 2161
			children = { } -- 2161
		end -- 2161
		local dirPath = Path(path, dir) -- 2162
		if recursive then -- 2163
			children[#children + 1] = visitAssets(dirPath, workspace, builtin) -- 2164
		else -- 2166
			children[#children + 1] = { -- 2167
				key = dirPath, -- 2167
				dir = true, -- 2168
				title = dir, -- 2169
				builtin = builtin, -- 2170
				isLeaf = false -- 2171
			} -- 2166
		end -- 2163
		::_continue_0:: -- 2156
	end -- 2155
	local files = Content:getFiles(path) -- 2173
	local names = { } -- 2174
	for _index_0 = 1, #files do -- 2175
		local file = files[_index_0] -- 2175
		if (".DS_Store" == file) then -- 2176
			goto _continue_1 -- 2177
		end -- 2176
		local ext = Path:getExt(file) -- 2178
		if not extentionLevels[ext] then -- 2179
			names[file] = "" -- 2180
			goto _continue_1 -- 2181
		end -- 2179
		local name = Path:getName(file) -- 2182
		ext = names[name] -- 2183
		if ext then -- 2183
			local lv1 -- 2184
			do -- 2184
				local _exp_0 = extentionLevels[ext] -- 2184
				if _exp_0 ~= nil then -- 2184
					lv1 = _exp_0 -- 2184
				else -- 2184
					lv1 = -1 -- 2184
				end -- 2184
			end -- 2184
			ext = Path:getExt(file) -- 2185
			local lv2 -- 2186
			do -- 2186
				local _exp_0 = extentionLevels[ext] -- 2186
				if _exp_0 ~= nil then -- 2186
					lv2 = _exp_0 -- 2186
				else -- 2186
					lv2 = -1 -- 2186
				end -- 2186
			end -- 2186
			if lv2 > lv1 then -- 2187
				names[name] = ext -- 2188
			elseif lv2 == lv1 then -- 2189
				names[name .. '.' .. ext] = "" -- 2190
			end -- 2187
		else -- 2192
			ext = Path:getExt(file) -- 2192
			if not extentionLevels[ext] then -- 2193
				names[file] = "" -- 2194
			else -- 2196
				names[name] = ext -- 2196
			end -- 2193
		end -- 2183
		::_continue_1:: -- 2176
	end -- 2175
	do -- 2197
		local _accum_0 = { } -- 2197
		local _len_0 = 1 -- 2197
		for name, ext in pairs(names) do -- 2197
			_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 2197
			_len_0 = _len_0 + 1 -- 2197
		end -- 2197
		files = _accum_0 -- 2197
	end -- 2197
	for _index_0 = 1, #files do -- 2198
		local file = files[_index_0] -- 2198
		if not children then -- 2199
			children = { } -- 2199
		end -- 2199
		children[#children + 1] = { -- 2201
			key = Path(path, file), -- 2201
			dir = false, -- 2202
			title = file, -- 2203
			builtin = builtin -- 2204
		} -- 2200
	end -- 2198
	if children then -- 2206
		table.sort(children, function(a, b) -- 2207
			if a.dir == b.dir then -- 2208
				return a.title < b.title -- 2209
			else -- 2211
				return a.dir -- 2211
			end -- 2208
		end) -- 2207
	end -- 2206
	return { -- 2213
		key = path, -- 2213
		dir = true, -- 2214
		title = Path:getFilename(path), -- 2215
		builtin = builtin, -- 2216
		isLeaf = not children, -- 2217
		children = children -- 2218
	} -- 2212
end -- 2152
HttpServer:post("/assets/children", function(req) -- 2221
	do -- 2222
		local _type_0 = type(req) -- 2222
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2222
		if _tab_0 then -- 2222
			local path -- 2222
			do -- 2222
				local _obj_0 = req.body -- 2222
				local _type_1 = type(_obj_0) -- 2222
				if "table" == _type_1 or "userdata" == _type_1 then -- 2222
					path = _obj_0.path -- 2222
				end -- 2222
			end -- 2222
			if path ~= nil then -- 2222
				local workspace, builtin = relativeToRoot(path, Content.writablePath) ~= nil, relativeToRoot(path, Content.assetPath) ~= nil -- 2223
				if not ((workspace or builtin) and Content:exist(path) and Content:isdir(path)) then -- 2224
					return { -- 2224
						success = false -- 2224
					} -- 2224
				end -- 2224
				local node = visitAssets(path, workspace, builtin, false) -- 2225
				return { -- 2226
					success = true, -- 2226
					children = node.children or { } -- 2226
				} -- 2226
			end -- 2222
		end -- 2222
	end -- 2222
	return { -- 2221
		success = false -- 2221
	} -- 2221
end) -- 2221
HttpServer:post("/assets/files", function(req) -- 2228
	do -- 2229
		local _type_0 = type(req) -- 2229
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2229
		if _tab_0 then -- 2229
			local path -- 2229
			do -- 2229
				local _obj_0 = req.body -- 2229
				local _type_1 = type(_obj_0) -- 2229
				if "table" == _type_1 or "userdata" == _type_1 then -- 2229
					path = _obj_0.path -- 2229
				end -- 2229
			end -- 2229
			if path ~= nil then -- 2229
				local workspace = relativeToRoot(path, Content.writablePath) ~= nil -- 2230
				local builtin = relativeToRoot(path, Content.assetPath) ~= nil -- 2231
				if not (workspace or builtin) then -- 2232
					return { -- 2232
						success = false -- 2232
					} -- 2232
				end -- 2232
				if not (Content:exist(path) and Content:isdir(path)) then -- 2233
					return { -- 2233
						success = false -- 2233
					} -- 2233
				end -- 2233
				local globs = { -- 2234
					"**", -- 2234
					"!**/.DS_Store", -- 2234
					"!**/.godot/**" -- 2234
				} -- 2234
				if workspace then -- 2235
					globs = { -- 2237
						"**", -- 2237
						"!**/.DS_Store", -- 2237
						"!**/.upload/**", -- 2238
						"!**/.download/**", -- 2238
						"!**/.www/**", -- 2239
						"!**/.build/**", -- 2239
						"!**/.git/**", -- 2240
						"!**/.cache/**", -- 2240
						"!**/.godot/**", -- 2241
						"!**/node_modules/**" -- 2242
					} -- 2236
				end -- 2235
				local files -- 2244
				do -- 2244
					local _accum_0 = { } -- 2244
					local _len_0 = 1 -- 2244
					local _list_0 = Content:glob(path, globs, extentionLevels) -- 2244
					for _index_0 = 1, #_list_0 do -- 2244
						local file = _list_0[_index_0] -- 2244
						_accum_0[_len_0] = Path(path, file) -- 2244
						_len_0 = _len_0 + 1 -- 2244
					end -- 2244
					files = _accum_0 -- 2244
				end -- 2244
				return { -- 2245
					success = true, -- 2245
					files = files -- 2245
				} -- 2245
			end -- 2229
		end -- 2229
	end -- 2229
	return { -- 2228
		success = false -- 2228
	} -- 2228
end) -- 2228
local _anon_func_6 = function(builtinChildren, workspace, zh) -- 2286
	local _tab_0 = { -- 2286
		{ -- 2287
			key = Path(Content.assetPath), -- 2287
			dir = true, -- 2288
			builtin = true, -- 2289
			title = zh and "内置资源" or "Built-in", -- 2290
			children = builtinChildren -- 2291
		} -- 2286
	} -- 2293
	local _obj_0 = workspace.children or { } -- 2293
	local _idx_0 = #_tab_0 + 1 -- 2293
	for _index_0 = 1, #_obj_0 do -- 2293
		local _value_0 = _obj_0[_index_0] -- 2293
		_tab_0[_idx_0] = _value_0 -- 2293
		_idx_0 = _idx_0 + 1 -- 2293
	end -- 2293
	return _tab_0 -- 2286
end -- 2286
HttpServer:post("/assets", function() -- 2247
	local Entry = require("Script.Dev.Entry") -- 2248
	local engineDev = Entry.getEngineDev() -- 2249
	local workspace = visitAssets(Content.writablePath, true, nil, false) -- 2250
	local zh = (App.locale:match("^zh") ~= nil) -- 2251
	local readme = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), false, true) -- 2252
	readme.title = zh and "说明文档" or "Readme" -- 2253
	local apiDoc = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), false, true) -- 2254
	apiDoc.title = zh and "接口文档" or "API Doc" -- 2255
	local tools = visitAssets((Path(Content.assetPath, "Script", "Tools")), false, true) -- 2256
	tools.title = zh and "开发工具" or "Tools" -- 2257
	local font = visitAssets((Path(Content.assetPath, "Font")), false, true) -- 2258
	font.title = zh and "字体" or "Font" -- 2259
	local lib = visitAssets((Path(Content.assetPath, "Script", "Lib")), false, true) -- 2260
	lib.title = zh and "程序库" or "Lib" -- 2261
	if engineDev then -- 2262
		local _list_0 = lib.children -- 2263
		for _index_0 = 1, #_list_0 do -- 2263
			local child = _list_0[_index_0] -- 2263
			if not (child.title == "Dora") then -- 2264
				goto _continue_0 -- 2264
			end -- 2264
			local title = zh and "zh-Hans" or "en" -- 2265
			do -- 2266
				local _accum_0 = { } -- 2266
				local _len_0 = 1 -- 2266
				local _list_1 = child.children -- 2266
				for _index_1 = 1, #_list_1 do -- 2266
					local c = _list_1[_index_1] -- 2266
					if c.title ~= title then -- 2266
						_accum_0[_len_0] = c -- 2266
						_len_0 = _len_0 + 1 -- 2266
					end -- 2266
				end -- 2266
				child.children = _accum_0 -- 2266
			end -- 2266
			break -- 2267
			::_continue_0:: -- 2264
		end -- 2263
	else -- 2269
		local _accum_0 = { } -- 2269
		local _len_0 = 1 -- 2269
		local _list_0 = lib.children -- 2269
		for _index_0 = 1, #_list_0 do -- 2269
			local child = _list_0[_index_0] -- 2269
			if child.title ~= "Dora" then -- 2269
				_accum_0[_len_0] = child -- 2269
				_len_0 = _len_0 + 1 -- 2269
			end -- 2269
		end -- 2269
		lib.children = _accum_0 -- 2269
	end -- 2262
	local builtinChildren = { -- 2270
		readme, -- 2270
		apiDoc, -- 2270
		tools, -- 2270
		font, -- 2270
		lib -- 2270
	} -- 2270
	if engineDev then -- 2271
		local dev = visitAssets((Path(Content.assetPath, "Script", "Dev")), false, true) -- 2272
		do -- 2273
			local _obj_0 = dev.children -- 2273
			_obj_0[#_obj_0 + 1] = { -- 2274
				key = Path(Content.assetPath, "Script", "init.yue"), -- 2274
				dir = false, -- 2275
				builtin = true, -- 2276
				title = "init.yue" -- 2277
			} -- 2273
		end -- 2273
		builtinChildren[#builtinChildren + 1] = dev -- 2279
	end -- 2271
	return { -- 2281
		key = Content.writablePath, -- 2281
		dir = true, -- 2282
		root = true, -- 2283
		title = "Assets", -- 2284
		children = _anon_func_6(builtinChildren, workspace, zh) -- 2285
	} -- 2280
end) -- 2247
HttpServer:post("/entry/list", function(req) -- 2297
	local Entry = require("Script.Dev.Entry") -- 2298
	local res = Entry.getLaunchEntries((req and req.body and req.body.refresh == true)) -- 2299
	res.success = true -- 2300
	return res -- 2301
end) -- 2297
HttpServer:post("/run/status", function() -- 2303
	local Entry = require("Script.Dev.Entry") -- 2304
	return Entry.getCurrentEntryStatus() -- 2305
end) -- 2303
HttpServer:postSchedule("/run", function(req) -- 2307
	do -- 2308
		local _type_0 = type(req) -- 2308
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2308
		if _tab_0 then -- 2308
			local file -- 2308
			do -- 2308
				local _obj_0 = req.body -- 2308
				local _type_1 = type(_obj_0) -- 2308
				if "table" == _type_1 or "userdata" == _type_1 then -- 2308
					file = _obj_0.file -- 2308
				end -- 2308
			end -- 2308
			local asProj -- 2308
			do -- 2308
				local _obj_0 = req.body -- 2308
				local _type_1 = type(_obj_0) -- 2308
				if "table" == _type_1 or "userdata" == _type_1 then -- 2308
					asProj = _obj_0.asProj -- 2308
				end -- 2308
			end -- 2308
			if file ~= nil and asProj ~= nil then -- 2308
				if not Content:isAbsolutePath(file) then -- 2309
					local devFile = Path(Content.writablePath, file) -- 2310
					if Content:exist(devFile) then -- 2311
						file = devFile -- 2311
					end -- 2311
				end -- 2309
				local Entry = require("Script.Dev.Entry") -- 2312
				local workDir -- 2313
				if asProj then -- 2314
					local projectRoot = req.body.projectRoot -- 2315
					if projectRoot and projectRoot ~= "" and Content:exist(projectRoot) and Content:isdir(projectRoot) then -- 2316
						workDir = projectRoot -- 2317
					else -- 2319
						workDir = getProjectDirFromFile(file) -- 2319
					end -- 2316
					if workDir then -- 2320
						Entry.allClear() -- 2321
						local target = Path(workDir, "init") -- 2322
						local runId = Entry.getCurrentEntryStatus().runId + 1 -- 2323
						local success, err = Entry.enterEntryAsync({ -- 2324
							entryName = "Project", -- 2324
							fileName = target, -- 2324
							workDir = workDir, -- 2324
							projectRoot = workDir, -- 2324
							runKind = "project" -- 2324
						}) -- 2324
						if success and not err and req.body.waitForFrame == true then -- 2325
							local RunTransition = require("Script.Dev.RunTransition") -- 2326
							success, err = RunTransition.waitForFrameAsync(Entry, runId, Content:exist(Path(workDir, "project.godot"))) -- 2327
						end -- 2325
						target = Path:getName(Path:getPath(target)) -- 2328
						return { -- 2329
							success = success, -- 2329
							target = target, -- 2329
							err = err -- 2329
						} -- 2329
					end -- 2320
				else -- 2331
					workDir = getProjectDirFromFile(file) -- 2331
					if not workDir and Path:getExt(file) == "wasm" then -- 2332
						local parent = Path:getPath(file) -- 2333
						if Content:exist(Path(parent, "wa.mod")) then -- 2334
							workDir = parent -- 2335
						end -- 2334
					end -- 2332
				end -- 2314
				Entry.allClear() -- 2336
				file = Path:replaceExt(file, "") -- 2337
				local entry = { -- 2339
					entryName = Path:getName(file), -- 2339
					fileName = file, -- 2340
					runKind = "file" -- 2341
				} -- 2338
				if workDir then -- 2342
					entry.workDir = workDir -- 2343
					entry.projectRoot = workDir -- 2344
				end -- 2342
				local runId = Entry.getCurrentEntryStatus().runId + 1 -- 2345
				local success, err = Entry.enterEntryAsync(entry) -- 2346
				if success and not err and req.body.waitForFrame == true then -- 2347
					local RunTransition = require("Script.Dev.RunTransition") -- 2348
					success, err = RunTransition.waitForFrameAsync(Entry, runId, workDir and Content:exist(Path(workDir, "project.godot"))) -- 2349
				end -- 2347
				return { -- 2350
					success = success, -- 2350
					err = err -- 2350
				} -- 2350
			end -- 2308
		end -- 2308
	end -- 2308
	return { -- 2307
		success = false -- 2307
	} -- 2307
end) -- 2307
local _anon_func_7 = function(result) -- 2392
	if result.success then -- 2392
		return nil -- 2392
	else -- 2392
		return "PREVIEW_FAILED" -- 2392
	end -- 2392
end -- 2392
HttpServer:postSchedule("/agent/preview", function(req) -- 2352
	local releaseAgent = AgentHost.acquire() -- 2353
	local _ <close> = setmetatable({ }, { -- 2354
		__close = function() -- 2354
			return releaseAgent() -- 2354
		end -- 2354
	}) -- 2354
	do -- 2355
		local _type_0 = type(req) -- 2355
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2355
		if _tab_0 then -- 2355
			local projectRoot -- 2355
			do -- 2355
				local _obj_0 = req.body -- 2355
				local _type_1 = type(_obj_0) -- 2355
				if "table" == _type_1 or "userdata" == _type_1 then -- 2355
					projectRoot = _obj_0.projectRoot -- 2355
				end -- 2355
			end -- 2355
			if projectRoot ~= nil then -- 2355
				if not getProjectSourceRoot(projectRoot) then -- 2356
					return { -- 2356
						success = false, -- 2356
						code = "INVALID_PROJECT", -- 2356
						message = "projectRoot must be an existing absolute directory" -- 2356
					} -- 2356
				end -- 2356
				local entryFile = req.body.entry or "init.lua" -- 2357
				if not (type(entryFile) == "string" and entryFile ~= "") then -- 2358
					return { -- 2358
						success = false, -- 2358
						code = "INVALID_ENTRY", -- 2358
						message = "entry must be a non-empty project-relative path" -- 2358
					} -- 2358
				end -- 2358
				local captureAtSeconds = req.body.captureAtSeconds or { -- 2359
					0.5 -- 2359
				} -- 2359
				local queueTimeoutSeconds = req.body.queueTimeoutSeconds or 30 -- 2360
				if not (type(queueTimeoutSeconds) == "number" and queueTimeoutSeconds >= 1 and queueTimeoutSeconds <= 300) then -- 2361
					return { -- 2361
						success = false, -- 2361
						code = "INVALID_QUEUE_TIMEOUT", -- 2361
						message = "queueTimeoutSeconds must be between 1 and 300" -- 2361
					} -- 2361
				end -- 2361
				local AgentEntryRunQueue = require("Agent.Tool.EntryRunQueue") -- 2362
				local AgentOperation = require("Agent.Tool.Operation") -- 2363
				local agentEntryRunQueue = AgentEntryRunQueue.sharedEntryRunQueue -- 2364
				local requestId = AgentOperation.createOperationId() -- 2365
				local enqueued = agentEntryRunQueue:enqueue(requestId) -- 2366
				if not enqueued.success then -- 2367
					return { -- 2367
						success = false, -- 2367
						code = "ENTRY_QUEUE_REJECTED", -- 2367
						message = enqueued.message -- 2367
					} -- 2367
				end -- 2367
				local queuedAt = App.runningTime -- 2368
				while not agentEntryRunQueue:tryAcquire(requestId) do -- 2369
					if App.runningTime - queuedAt >= queueTimeoutSeconds then -- 2370
						local state = agentEntryRunQueue:get(requestId) -- 2371
						agentEntryRunQueue:cancel(requestId) -- 2372
						return { -- 2374
							success = false, -- 2374
							code = "ENTRY_QUEUE_TIMEOUT", -- 2375
							message = "timed out waiting for the Dora entry runtime", -- 2376
							requestId = requestId, -- 2377
							queuePosition = state.position -- 2378
						} -- 2373
					end -- 2370
					sleep() -- 2379
				end -- 2369
				local queueWaitSeconds = App.runningTime - queuedAt -- 2380
				local _ <close> = setmetatable({ }, { -- 2381
					__close = function() -- 2381
						return agentEntryRunQueue:release(requestId) -- 2381
					end -- 2381
				}) -- 2381
				local AgentCommandPreview = require("Agent.Tool.CommandPreview") -- 2382
				local Entry = require("Script.Dev.Entry") -- 2383
				local preview = AgentCommandPreview.createPreviewGameInjection({ -- 2385
					workDir = projectRoot, -- 2385
					operationId = requestId, -- 2386
					print = function() end -- 2387
				}, Entry) -- 2384
				local result = preview({ -- 2389
					entry = entryFile, -- 2389
					captureAtSeconds = captureAtSeconds -- 2389
				}) -- 2389
				return { -- 2391
					success = result.success, -- 2391
					code = _anon_func_7(result), -- 2392
					message = result.message, -- 2393
					requestId = requestId, -- 2394
					queueWaitSeconds = queueWaitSeconds, -- 2395
					interruptedUserRun = result.interruptedUserRun, -- 2396
					files = result.files, -- 2397
					frames = result.frames -- 2398
				} -- 2390
			end -- 2355
		end -- 2355
	end -- 2355
	return { -- 2352
		success = false, -- 2352
		message = "invalid call" -- 2352
	} -- 2352
end) -- 2352
HttpServer:postSchedule("/agent/command", function(req) -- 2400
	local releaseAgent = AgentHost.acquire() -- 2401
	local _ <close> = setmetatable({ }, { -- 2402
		__close = function() -- 2402
			return releaseAgent() -- 2402
		end -- 2402
	}) -- 2402
	do -- 2403
		local _type_0 = type(req) -- 2403
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2403
		if _tab_0 then -- 2403
			local body = req.body -- 2403
			if body ~= nil then -- 2403
				local projectRoot = body.projectRoot -- 2404
				if not getProjectSourceRoot(projectRoot) then -- 2405
					return { -- 2405
						success = false, -- 2405
						code = "INVALID_PROJECT", -- 2405
						message = "projectRoot must be an existing absolute directory" -- 2405
					} -- 2405
				end -- 2405
				local AgentValidation = require("Agent.Tool.Validation") -- 2406
				local validated = AgentValidation.validateAgentToolInput("execute_command", body) -- 2407
				if not validated.success then -- 2408
					return { -- 2408
						success = false, -- 2408
						code = "INVALID_COMMAND", -- 2408
						message = validated.message -- 2408
					} -- 2408
				end -- 2408
				local input = validated.value -- 2409
				local AgentCommand = require("Agent.Tool.Command") -- 2410
				local result = nil -- 2411
				local failure = nil -- 2412
				local promise = AgentCommand.executeCommand({ -- 2414
					workDir = projectRoot, -- 2414
					mode = input.mode, -- 2415
					code = input.code, -- 2416
					command = input.command, -- 2417
					cwd = input.cwd, -- 2418
					timeoutSeconds = input.timeoutSeconds -- 2419
				}) -- 2413
				promise:addCallbacks((function(_, value) -- 2420
					result = value -- 2420
				end), (function(_, err) -- 2420
					failure = tostring(err) -- 2420
				end)) -- 2420
				wait(function() -- 2421
					return result ~= nil or failure ~= nil -- 2421
				end) -- 2421
				if failure then -- 2422
					return { -- 2422
						success = false, -- 2422
						code = "COMMAND_BRIDGE_FAILED", -- 2422
						message = failure -- 2422
					} -- 2422
				end -- 2422
				if not result.success then -- 2423
					result.code = "COMMAND_FAILED" -- 2424
				end -- 2423
				return result -- 2425
			end -- 2403
		end -- 2403
	end -- 2403
	return { -- 2400
		success = false, -- 2400
		code = "INVALID_COMMAND", -- 2400
		message = "invalid call" -- 2400
	} -- 2400
end) -- 2400
HttpServer:postSchedule("/stop", function() -- 2427
	local Entry = require("Script.Dev.Entry") -- 2428
	return { -- 2429
		success = Entry.stop() -- 2429
	} -- 2429
end) -- 2427
local minifyAsync -- 2431
minifyAsync = function(sourcePath, minifyPath) -- 2431
	if not Content:exist(sourcePath) then -- 2432
		return -- 2432
	end -- 2432
	local Entry = require("Script.Dev.Entry") -- 2433
	local errors = { } -- 2434
	local files = Entry.getAllFiles(sourcePath, { -- 2435
		"lua" -- 2435
	}, true) -- 2435
	do -- 2436
		local _accum_0 = { } -- 2436
		local _len_0 = 1 -- 2436
		for _index_0 = 1, #files do -- 2436
			local file = files[_index_0] -- 2436
			if file:sub(1, 1) ~= '.' then -- 2436
				_accum_0[_len_0] = file -- 2436
				_len_0 = _len_0 + 1 -- 2436
			end -- 2436
		end -- 2436
		files = _accum_0 -- 2436
	end -- 2436
	local paths -- 2437
	do -- 2437
		local _tbl_0 = { } -- 2437
		for _index_0 = 1, #files do -- 2437
			local file = files[_index_0] -- 2437
			_tbl_0[Path:getPath(file)] = true -- 2437
		end -- 2437
		paths = _tbl_0 -- 2437
	end -- 2437
	for path in pairs(paths) do -- 2438
		Content:mkdir(Path(minifyPath, path)) -- 2438
	end -- 2438
	local _ <close> = setmetatable({ }, { -- 2439
		__close = function() -- 2439
			package.loaded["luaminify.FormatMini"] = nil -- 2440
			package.loaded["luaminify.ParseLua"] = nil -- 2441
			package.loaded["luaminify.Scope"] = nil -- 2442
			package.loaded["luaminify.Util"] = nil -- 2443
		end -- 2439
	}) -- 2439
	local FormatMini -- 2444
	do -- 2444
		local _obj_0 = require("luaminify") -- 2444
		FormatMini = _obj_0.FormatMini -- 2444
	end -- 2444
	local fileCount = #files -- 2445
	local count = 0 -- 2446
	for _index_0 = 1, #files do -- 2447
		local file = files[_index_0] -- 2447
		thread(function() -- 2448
			local _ <close> = setmetatable({ }, { -- 2449
				__close = function() -- 2449
					count = count + 1 -- 2449
				end -- 2449
			}) -- 2449
			local input = Path(sourcePath, file) -- 2450
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 2451
			if Content:exist(input) then -- 2452
				local sourceCodes = Content:loadAsync(input) -- 2453
				local res, err = FormatMini(sourceCodes) -- 2454
				if res then -- 2455
					Content:saveAsync(output, res) -- 2456
					return print("Minify " .. tostring(file)) -- 2457
				else -- 2459
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 2459
				end -- 2455
			else -- 2461
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 2461
			end -- 2452
		end) -- 2448
		sleep() -- 2462
	end -- 2447
	wait(function() -- 2463
		return count == fileCount -- 2463
	end) -- 2463
	if #errors > 0 then -- 2464
		print(table.concat(errors, '\n')) -- 2465
	end -- 2464
	print("Obfuscation done.") -- 2466
	return files -- 2467
end -- 2431
local zipping = false -- 2469
HttpServer:postSchedule("/zip", function(req) -- 2470
	do -- 2471
		local _type_0 = type(req) -- 2471
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2471
		if _tab_0 then -- 2471
			local path -- 2471
			do -- 2471
				local _obj_0 = req.body -- 2471
				local _type_1 = type(_obj_0) -- 2471
				if "table" == _type_1 or "userdata" == _type_1 then -- 2471
					path = _obj_0.path -- 2471
				end -- 2471
			end -- 2471
			local zipFile -- 2471
			do -- 2471
				local _obj_0 = req.body -- 2471
				local _type_1 = type(_obj_0) -- 2471
				if "table" == _type_1 or "userdata" == _type_1 then -- 2471
					zipFile = _obj_0.zipFile -- 2471
				end -- 2471
			end -- 2471
			local obfuscated -- 2471
			do -- 2471
				local _obj_0 = req.body -- 2471
				local _type_1 = type(_obj_0) -- 2471
				if "table" == _type_1 or "userdata" == _type_1 then -- 2471
					obfuscated = _obj_0.obfuscated -- 2471
				end -- 2471
			end -- 2471
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 2471
				if zipping then -- 2472
					goto failed -- 2472
				end -- 2472
				zipping = true -- 2473
				local _ <close> = setmetatable({ }, { -- 2474
					__close = function() -- 2474
						zipping = false -- 2474
					end -- 2474
				}) -- 2474
				if not Content:exist(path) then -- 2475
					goto failed -- 2475
				end -- 2475
				Content:mkdir(Path:getPath(zipFile)) -- 2476
				if obfuscated then -- 2477
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 2478
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 2479
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 2480
					Content:remove(scriptPath) -- 2481
					Content:remove(obfuscatedPath) -- 2482
					Content:remove(tempPath) -- 2483
					Content:mkdir(scriptPath) -- 2484
					Content:mkdir(obfuscatedPath) -- 2485
					Content:mkdir(tempPath) -- 2486
					if not Content:copyAsync(path, tempPath) then -- 2487
						goto failed -- 2487
					end -- 2487
					local Entry = require("Script.Dev.Entry") -- 2488
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 2489
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 2490
						"tl", -- 2490
						"yue", -- 2490
						"lua", -- 2490
						"ts", -- 2490
						"tsx", -- 2490
						"vs", -- 2490
						"bl", -- 2490
						"xml", -- 2490
						"wa", -- 2490
						"mod" -- 2490
					}, true) -- 2490
					for _index_0 = 1, #scriptFiles do -- 2491
						local file = scriptFiles[_index_0] -- 2491
						Content:remove(Path(tempPath, file)) -- 2492
					end -- 2491
					for _index_0 = 1, #luaFiles do -- 2493
						local file = luaFiles[_index_0] -- 2493
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 2494
					end -- 2493
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 2495
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 2496
					end) then -- 2495
						goto failed -- 2495
					end -- 2495
					return { -- 2497
						success = true -- 2497
					} -- 2497
				else -- 2499
					return { -- 2499
						success = Content:zipAsync(path, zipFile, function(file) -- 2499
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 2500
						end) -- 2499
					} -- 2499
				end -- 2477
			end -- 2471
		end -- 2471
	end -- 2471
	::failed:: -- 2501
	return { -- 2470
		success = false -- 2470
	} -- 2470
end) -- 2470
HttpServer:postSchedule("/unzip", function(req) -- 2503
	do -- 2504
		local _type_0 = type(req) -- 2504
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2504
		if _tab_0 then -- 2504
			local zipFile -- 2504
			do -- 2504
				local _obj_0 = req.body -- 2504
				local _type_1 = type(_obj_0) -- 2504
				if "table" == _type_1 or "userdata" == _type_1 then -- 2504
					zipFile = _obj_0.zipFile -- 2504
				end -- 2504
			end -- 2504
			local path -- 2504
			do -- 2504
				local _obj_0 = req.body -- 2504
				local _type_1 = type(_obj_0) -- 2504
				if "table" == _type_1 or "userdata" == _type_1 then -- 2504
					path = _obj_0.path -- 2504
				end -- 2504
			end -- 2504
			if zipFile ~= nil and path ~= nil then -- 2504
				return { -- 2505
					success = Content:unzipAsync(zipFile, path, function(file) -- 2505
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 2506
					end) -- 2505
				} -- 2505
			end -- 2504
		end -- 2504
	end -- 2504
	return { -- 2503
		success = false -- 2503
	} -- 2503
end) -- 2503
HttpServer:post("/editing-info", function(req) -- 2508
	local Entry = require("Script.Dev.Entry") -- 2509
	local config = Entry.getConfig() -- 2510
	local _type_0 = type(req) -- 2511
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2511
	local _match_0 = false -- 2511
	if _tab_0 then -- 2511
		local editingInfo -- 2511
		do -- 2511
			local _obj_0 = req.body -- 2511
			local _type_1 = type(_obj_0) -- 2511
			if "table" == _type_1 or "userdata" == _type_1 then -- 2511
				editingInfo = _obj_0.editingInfo -- 2511
			end -- 2511
		end -- 2511
		if editingInfo ~= nil then -- 2511
			_match_0 = true -- 2511
			config.editingInfo = editingInfo -- 2512
			return { -- 2513
				success = true -- 2513
			} -- 2513
		end -- 2511
	end -- 2511
	if not _match_0 then -- 2511
		if not (config.editingInfo ~= nil) then -- 2515
			local folder -- 2516
			if App.locale:match('^zh') then -- 2516
				folder = 'zh-Hans' -- 2516
			else -- 2516
				folder = 'en' -- 2516
			end -- 2516
			config.editingInfo = json.encode({ -- 2518
				index = 0, -- 2518
				files = { -- 2520
					{ -- 2521
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 2521
						title = "welcome.md" -- 2522
					} -- 2520
				} -- 2519
			}) -- 2517
		end -- 2515
		return { -- 2526
			success = true, -- 2526
			editingInfo = config.editingInfo -- 2526
		} -- 2526
	end -- 2511
end) -- 2508
HttpServer:post("/command", function(req) -- 2528
	do -- 2529
		local _type_0 = type(req) -- 2529
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2529
		if _tab_0 then -- 2529
			local code -- 2529
			do -- 2529
				local _obj_0 = req.body -- 2529
				local _type_1 = type(_obj_0) -- 2529
				if "table" == _type_1 or "userdata" == _type_1 then -- 2529
					code = _obj_0.code -- 2529
				end -- 2529
			end -- 2529
			local log -- 2529
			do -- 2529
				local _obj_0 = req.body -- 2529
				local _type_1 = type(_obj_0) -- 2529
				if "table" == _type_1 or "userdata" == _type_1 then -- 2529
					log = _obj_0.log -- 2529
				end -- 2529
			end -- 2529
			if code ~= nil and log ~= nil then -- 2529
				emit("AppCommand", code, log) -- 2530
				return { -- 2531
					success = true -- 2531
				} -- 2531
			end -- 2529
		end -- 2529
	end -- 2529
	return { -- 2528
		success = false -- 2528
	} -- 2528
end) -- 2528
HttpServer:post("/log/save", function() -- 2533
	local folder = ".download" -- 2534
	local fullLogFile = "dora_full_logs.txt" -- 2535
	local fullFolder = Path(Content.writablePath, folder) -- 2536
	Content:mkdir(fullFolder) -- 2537
	local logPath = Path(fullFolder, fullLogFile) -- 2538
	if App:saveLog(logPath) then -- 2539
		return { -- 2540
			success = true, -- 2540
			path = Path(folder, fullLogFile) -- 2540
		} -- 2540
	end -- 2539
	return { -- 2533
		success = false -- 2533
	} -- 2533
end) -- 2533
local tailLines -- 2542
tailLines = function(text, count) -- 2542
	local lines = { } -- 2543
	text = text:gsub("\r\n", "\n") -- 2544
	for line in (text .. "\n"):gmatch("(.-)\n") do -- 2545
		lines[#lines + 1] = line -- 2546
	end -- 2545
	if #lines > 0 and lines[#lines] == "" and text:sub(#text) == "\n" then -- 2547
		table.remove(lines) -- 2548
	end -- 2547
	local start = math.max(1, #lines - count + 1) -- 2549
	local out = { } -- 2550
	for i = start, #lines do -- 2551
		out[#out + 1] = lines[i] -- 2552
	end -- 2551
	return table.concat(out, "\n") -- 2553
end -- 2542
HttpServer:post("/log", function(req) -- 2555
	local count = 100 -- 2556
	if req and req.body and req.body.count ~= nil then -- 2557
		count = req.body.count -- 2558
	end -- 2557
	if not (type(count) == "number" and count >= 1 and count == math.floor(count)) then -- 2559
		return { -- 2560
			success = false, -- 2560
			message = "count must be a positive integer" -- 2560
		} -- 2560
	end -- 2559
	local folder = ".download" -- 2561
	local fullLogFile = "dora_full_logs.txt" -- 2562
	local fullFolder = Path(Content.writablePath, folder) -- 2563
	Content:mkdir(fullFolder) -- 2564
	local logPath = Path(fullFolder, fullLogFile) -- 2565
	if App:saveLog(logPath) then -- 2566
		local text = Content:load(logPath) -- 2567
		if text then -- 2568
			return { -- 2569
				success = true, -- 2569
				log = tailLines(text, count) -- 2569
			} -- 2569
		else -- 2571
			return { -- 2571
				success = false, -- 2571
				message = "failed to read log" -- 2571
			} -- 2571
		end -- 2568
	else -- 2573
		return { -- 2573
			success = false, -- 2573
			message = "failed to save log" -- 2573
		} -- 2573
	end -- 2566
	return { -- 2555
		success = false -- 2555
	} -- 2555
end) -- 2555
HttpServer:post("/yarn/check", function(req) -- 2575
	local yarncompile = require("yarncompile") -- 2576
	do -- 2577
		local _type_0 = type(req) -- 2577
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2577
		if _tab_0 then -- 2577
			local code -- 2577
			do -- 2577
				local _obj_0 = req.body -- 2577
				local _type_1 = type(_obj_0) -- 2577
				if "table" == _type_1 or "userdata" == _type_1 then -- 2577
					code = _obj_0.code -- 2577
				end -- 2577
			end -- 2577
			if code ~= nil then -- 2577
				local jsonObject = json.decode(code) -- 2578
				if jsonObject then -- 2578
					local errors = { } -- 2579
					local _list_0 = jsonObject.nodes -- 2580
					for _index_0 = 1, #_list_0 do -- 2580
						local node = _list_0[_index_0] -- 2580
						local title, body = node.title, node.body -- 2581
						local luaCode, err = yarncompile(body) -- 2582
						if not luaCode then -- 2582
							errors[#errors + 1] = title .. ":" .. err -- 2583
						end -- 2582
					end -- 2580
					return { -- 2584
						success = true, -- 2584
						syntaxError = table.concat(errors, "\n\n") -- 2584
					} -- 2584
				end -- 2578
			end -- 2577
		end -- 2577
	end -- 2577
	return { -- 2575
		success = false -- 2575
	} -- 2575
end) -- 2575
HttpServer:post("/yarn/check-file", function(req) -- 2586
	local yarncompile = require("yarncompile") -- 2587
	do -- 2588
		local _type_0 = type(req) -- 2588
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2588
		if _tab_0 then -- 2588
			local code -- 2588
			do -- 2588
				local _obj_0 = req.body -- 2588
				local _type_1 = type(_obj_0) -- 2588
				if "table" == _type_1 or "userdata" == _type_1 then -- 2588
					code = _obj_0.code -- 2588
				end -- 2588
			end -- 2588
			if code ~= nil then -- 2588
				local res, _, err = yarncompile(code, true) -- 2589
				if not res then -- 2589
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 2590
					return { -- 2591
						success = false, -- 2591
						message = message, -- 2591
						line = line, -- 2591
						column = column, -- 2591
						node = node -- 2591
					} -- 2591
				end -- 2589
			end -- 2588
		end -- 2588
	end -- 2588
	return { -- 2586
		success = true -- 2586
	} -- 2586
end) -- 2586
getWaProjectDirFromFile = function(file) -- 2593
	local current -- 2594
	if Content:isdir(file) then -- 2594
		current = file -- 2594
	else -- 2594
		current = Path:getPath(file) -- 2594
	end -- 2594
	if current == "" then -- 2595
		return nil -- 2595
	end -- 2595
	repeat -- 2596
		local modPath = Path(current, "wa.mod") -- 2597
		if Content:exist(modPath) then -- 2598
			return current, modPath -- 2599
		end -- 2598
		local parent = Path:getPath(current) -- 2600
		if parent == "" or parent == current then -- 2601
			break -- 2601
		end -- 2601
		current = parent -- 2602
	until false -- 2596
	return nil -- 2604
end -- 2593
HttpServer:postSchedule("/wa/update_dora", function(req) -- 2606
	do -- 2607
		local _type_0 = type(req) -- 2607
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2607
		if _tab_0 then -- 2607
			local path -- 2607
			do -- 2607
				local _obj_0 = req.body -- 2607
				local _type_1 = type(_obj_0) -- 2607
				if "table" == _type_1 or "userdata" == _type_1 then -- 2607
					path = _obj_0.path -- 2607
				end -- 2607
			end -- 2607
			if path ~= nil then -- 2607
				local projDir = getWaProjectDirFromFile(path) -- 2608
				if projDir then -- 2608
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 2609
					if not Content:exist(sourceDoraPath) then -- 2610
						return { -- 2611
							success = false, -- 2611
							message = "missing dora template" -- 2611
						} -- 2611
					end -- 2610
					local targetVendorPath = Path(projDir, "vendor") -- 2612
					local targetDoraPath = Path(targetVendorPath, "dora") -- 2613
					if not Content:exist(targetVendorPath) then -- 2614
						if not Content:mkdir(targetVendorPath) then -- 2615
							return { -- 2616
								success = false, -- 2616
								message = "failed to create vendor folder" -- 2616
							} -- 2616
						end -- 2615
					elseif not Content:isdir(targetVendorPath) then -- 2617
						return { -- 2618
							success = false, -- 2618
							message = "vendor path is not a folder" -- 2618
						} -- 2618
					end -- 2614
					if Content:exist(targetDoraPath) then -- 2619
						if not Content:remove(targetDoraPath) then -- 2620
							return { -- 2621
								success = false, -- 2621
								message = "failed to remove old dora" -- 2621
							} -- 2621
						end -- 2620
					end -- 2619
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 2622
						return { -- 2623
							success = false, -- 2623
							message = "failed to copy dora" -- 2623
						} -- 2623
					end -- 2622
					return { -- 2624
						success = true -- 2624
					} -- 2624
				else -- 2626
					return { -- 2626
						success = false, -- 2626
						message = 'Wa file needs a project' -- 2626
					} -- 2626
				end -- 2608
			end -- 2607
		end -- 2607
	end -- 2607
	return { -- 2606
		success = false, -- 2606
		message = "invalid call" -- 2606
	} -- 2606
end) -- 2606
HttpServer:postSchedule("/wa/build", function(req) -- 2628
	do -- 2629
		local _type_0 = type(req) -- 2629
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2629
		if _tab_0 then -- 2629
			local path -- 2629
			do -- 2629
				local _obj_0 = req.body -- 2629
				local _type_1 = type(_obj_0) -- 2629
				if "table" == _type_1 or "userdata" == _type_1 then -- 2629
					path = _obj_0.path -- 2629
				end -- 2629
			end -- 2629
			if path ~= nil then -- 2629
				local projDir = getWaProjectDirFromFile(path) -- 2630
				if projDir then -- 2630
					local message = Wasm:buildWaAsync(projDir) -- 2631
					if message == "" then -- 2632
						return { -- 2633
							success = true -- 2633
						} -- 2633
					else -- 2635
						return { -- 2635
							success = false, -- 2635
							message = message -- 2635
						} -- 2635
					end -- 2632
				else -- 2637
					return { -- 2637
						success = false, -- 2637
						message = 'Wa file needs a project' -- 2637
					} -- 2637
				end -- 2630
			end -- 2629
		end -- 2629
	end -- 2629
	return { -- 2638
		success = false, -- 2638
		message = 'failed to build' -- 2638
	} -- 2638
end) -- 2628
HttpServer:postSchedule("/wa/format", function(req) -- 2640
	do -- 2641
		local _type_0 = type(req) -- 2641
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2641
		if _tab_0 then -- 2641
			local file -- 2641
			do -- 2641
				local _obj_0 = req.body -- 2641
				local _type_1 = type(_obj_0) -- 2641
				if "table" == _type_1 or "userdata" == _type_1 then -- 2641
					file = _obj_0.file -- 2641
				end -- 2641
			end -- 2641
			if file ~= nil then -- 2641
				local code = Wasm:formatWaAsync(file) -- 2642
				if code == "" then -- 2643
					return { -- 2644
						success = false -- 2644
					} -- 2644
				else -- 2646
					return { -- 2646
						success = true, -- 2646
						code = code -- 2646
					} -- 2646
				end -- 2643
			end -- 2641
		end -- 2641
	end -- 2641
	return { -- 2647
		success = false -- 2647
	} -- 2647
end) -- 2640
HttpServer:postSchedule("/wa/create", function(req) -- 2649
	do -- 2650
		local _type_0 = type(req) -- 2650
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2650
		if _tab_0 then -- 2650
			local path -- 2650
			do -- 2650
				local _obj_0 = req.body -- 2650
				local _type_1 = type(_obj_0) -- 2650
				if "table" == _type_1 or "userdata" == _type_1 then -- 2650
					path = _obj_0.path -- 2650
				end -- 2650
			end -- 2650
			if path ~= nil then -- 2650
				if not Content:exist(Path:getPath(path)) then -- 2651
					return { -- 2652
						success = false, -- 2652
						message = "target path not existed" -- 2652
					} -- 2652
				end -- 2651
				if Content:exist(path) then -- 2653
					return { -- 2654
						success = false, -- 2654
						message = "target project folder existed" -- 2654
					} -- 2654
				end -- 2653
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 2655
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 2656
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 2657
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 2658
					return { -- 2661
						success = false, -- 2661
						message = "missing template project" -- 2661
					} -- 2661
				end -- 2658
				if not Content:mkdir(path) then -- 2662
					return { -- 2663
						success = false, -- 2663
						message = "failed to create project folder" -- 2663
					} -- 2663
				end -- 2662
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 2664
					Content:remove(path) -- 2665
					return { -- 2666
						success = false, -- 2666
						message = "failed to copy template" -- 2666
					} -- 2666
				end -- 2664
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 2667
					Content:remove(path) -- 2668
					return { -- 2669
						success = false, -- 2669
						message = "failed to copy template" -- 2669
					} -- 2669
				end -- 2667
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 2670
					Content:remove(path) -- 2671
					return { -- 2672
						success = false, -- 2672
						message = "failed to copy template" -- 2672
					} -- 2672
				end -- 2670
				return { -- 2673
					success = true -- 2673
				} -- 2673
			end -- 2650
		end -- 2650
	end -- 2650
	return { -- 2649
		success = false, -- 2649
		message = "invalid call" -- 2649
	} -- 2649
end) -- 2649
local tsSnapshotGlobs = { -- 2676
	"**/*.ts", -- 2676
	"**/*.tsx", -- 2677
	"**/*.lua", -- 2678
	"!**/.*/**", -- 2679
	"!**/node_modules/**", -- 2680
	"!**/CMakeFiles/**" -- 2681
} -- 2675
local luaRuntimeModules -- 2683
do -- 2683
	local modules = { } -- 2684
	for name in pairs(_compilerRuntimeModules or { }) do -- 2685
		modules[#modules + 1] = name -- 2686
	end -- 2685
	local _list_0 = (_loveCompilerModules and _loveCompilerModules() or { }) -- 2687
	for _index_0 = 1, #_list_0 do -- 2687
		local name = _list_0[_index_0] -- 2687
		modules[#modules + 1] = name -- 2688
	end -- 2687
	table.sort(modules) -- 2689
	luaRuntimeModules = modules -- 2690
end -- 2683
HttpServer:post("/ts/runtime-modules", function() -- 2692
	return { -- 2692
		success = true, -- 2692
		luaRuntimeModules = luaRuntimeModules, -- 2692
		assetPath = Content.assetPath -- 2692
	} -- 2692
end) -- 2692
local compilerDeclarationRoot -- 2694
compilerDeclarationRoot = function() -- 2694
	local locale -- 2695
	if App.locale:match('^zh') then -- 2695
		locale = 'zh-Hans' -- 2695
	else -- 2695
		locale = 'en' -- 2695
	end -- 2695
	return Path(Content.assetPath, "Script", "Lib", "Dora", locale) -- 2696
end -- 2694
local compilerDefaultLib -- 2698
compilerDefaultLib = function() -- 2698
	return Path(compilerDeclarationRoot(), "Dora.d.ts") -- 2698
end -- 2698
local _anon_func_8 = function(file) -- 2726
	local _val_0 = Path:getExt(file) -- 2726
	return "ts" == _val_0 or "tsx" == _val_0 -- 2726
end -- 2726
local collectTSVirtualFiles -- 2700
collectTSVirtualFiles = function(sourceRoot) -- 2700
	local files = { } -- 2701
	local seen = { } -- 2702
	local addFile -- 2703
	addFile = function(file, moduleName, virtualFile) -- 2703
		if moduleName == nil then -- 2703
			moduleName = nil -- 2703
		end -- 2703
		if virtualFile == nil then -- 2703
			virtualFile = nil -- 2703
		end -- 2703
		local targetFile = virtualFile or file -- 2704
		do -- 2705
			local entry = seen[targetFile] -- 2705
			if entry then -- 2705
				if moduleName and moduleName ~= "" then -- 2706
					entry.moduleName = moduleName -- 2706
				end -- 2706
				return -- 2707
			end -- 2705
		end -- 2705
		local content = Content:load(file) -- 2708
		if content then -- 2708
			local entry = { -- 2709
				file = targetFile, -- 2709
				content = content -- 2709
			} -- 2709
			if virtualFile and Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2710
				entry.sourcePath = file -- 2710
			end -- 2710
			if moduleName and moduleName ~= "" then -- 2711
				entry.moduleName = moduleName -- 2711
			end -- 2711
			seen[targetFile] = entry -- 2712
			files[#files + 1] = entry -- 2713
		end -- 2708
	end -- 2703
	if sourceRoot and Content:exist(sourceRoot) and Content:isdir(sourceRoot) then -- 2714
		local builtinScriptRoot = Path(Content.assetPath, "Script") -- 2715
		local builtinPrefix -- 2717
		if relativeToRoot(sourceRoot, builtinScriptRoot) == "" then -- 2717
			builtinPrefix = "Script/" -- 2718
		elseif relativeToRoot(sourceRoot, Content.assetPath) == "" then -- 2719
			builtinPrefix = "" -- 2720
		else -- 2722
			builtinPrefix = nil -- 2722
		end -- 2717
		local _list_0 = Content:glob(sourceRoot, tsSnapshotGlobs, nil, false) -- 2723
		for _index_0 = 1, #_list_0 do -- 2723
			local subFile = _list_0[_index_0] -- 2723
			local file = Path(sourceRoot, subFile) -- 2724
			local moduleName = nil -- 2725
			if builtinPrefix and _anon_func_8(file) and Path:getExt(Path:getName(file)) ~= "d" then -- 2726
				local relative = relativeToRoot(file, builtinScriptRoot) -- 2727
				if relative then -- 2727
					moduleName = (builtinPrefix .. Path:replaceExt(relative, "")):gsub("\\", "/") -- 2728
				end -- 2727
			end -- 2726
			addFile(file, moduleName) -- 2729
		end -- 2723
		local libraryRoot = Path(Content.assetPath, "Script", "Lib") -- 2730
		if Content:isdir(libraryRoot) then -- 2731
			local _list_1 = Content:glob(libraryRoot, tsSnapshotGlobs, nil, false) -- 2732
			for _index_0 = 1, #_list_1 do -- 2732
				local subFile = _list_1[_index_0] -- 2732
				addFile(Path(libraryRoot, subFile), nil, Path(sourceRoot, subFile)) -- 2733
			end -- 2732
		end -- 2731
	end -- 2714
	local _list_0 = { -- 2734
		"Dev", -- 2734
		"Tools" -- 2734
	} -- 2734
	for _index_0 = 1, #_list_0 do -- 2734
		local namespace = _list_0[_index_0] -- 2734
		local builtinRoot = Path(Content.assetPath, "Script", namespace) -- 2735
		if Content:isdir(builtinRoot) then -- 2736
			local _list_1 = Content:glob(builtinRoot, tsSnapshotGlobs, nil, false) -- 2737
			for _index_1 = 1, #_list_1 do -- 2737
				local subFile = _list_1[_index_1] -- 2737
				local file = Path(builtinRoot, subFile) -- 2738
				addFile(file, nil, Path(sourceRoot, namespace, subFile)) -- 2739
				addFile(file, nil, Path(sourceRoot, "Script", namespace, subFile)) -- 2740
			end -- 2737
		end -- 2736
	end -- 2734
	local declarationRoot = compilerDeclarationRoot() -- 2741
	local _list_1 = Content:getFiles(declarationRoot) -- 2742
	for _index_0 = 1, #_list_1 do -- 2742
		local file = _list_1[_index_0] -- 2742
		if Path:getExt(file) == "ts" and Path:getExt(Path:getName(file)) == "d" then -- 2743
			local fullPath = Path(declarationRoot, file) -- 2744
			local moduleName = Path:getName(Path:getName(file)) -- 2745
			addFile(fullPath, moduleName) -- 2746
		end -- 2743
	end -- 2742
	local lualibBundle = Path(Content.assetPath, "Script", "Lib", "lualib_bundle.lua") -- 2747
	local lualibBundleTarget -- 2748
	if sourceRoot then -- 2748
		lualibBundleTarget = Path(sourceRoot, "lualib_bundle.lua") -- 2748
	else -- 2748
		lualibBundleTarget = "lualib_bundle.lua" -- 2748
	end -- 2748
	addFile(lualibBundle, nil, lualibBundleTarget) -- 2749
	local lualibRoot = Path(Content.assetPath, "Script", "Lib", "lualib") -- 2750
	local _list_2 = Content:getFiles(lualibRoot) -- 2751
	for _index_0 = 1, #_list_2 do -- 2751
		local file = _list_2[_index_0] -- 2751
		if Path:getExt(file) == "lua" then -- 2752
			local virtualFile -- 2753
			if sourceRoot then -- 2753
				virtualFile = Path(sourceRoot, "lualib", file) -- 2753
			else -- 2753
				virtualFile = Path("lualib", file) -- 2753
			end -- 2753
			addFile(Path(lualibRoot, file), nil, virtualFile) -- 2754
		end -- 2752
	end -- 2751
	return files -- 2755
end -- 2700
local supportsCompilerWebView -- 2757
supportsCompilerWebView = function() -- 2757
	local _val_0 = App.platform -- 2757
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 2757
end -- 2757
local projectCompilerScriptRoot -- 2758
projectCompilerScriptRoot = function(sourceRoot) -- 2758
	if not (sourceRoot and not relativeToRoot(sourceRoot, Content.assetPath)) then -- 2759
		return nil -- 2759
	end -- 2759
	return GetProjectScriptRoot(sourceRoot) -- 2760
end -- 2758
local _anon_func_9 = function(file) -- 2764
	local _val_0 = Path:getExt(file) -- 2764
	return "ts" == _val_0 or "tsx" == _val_0 -- 2764
end -- 2764
HttpServer:postSchedule("/ts/snapshot", function(req) -- 2762
	do -- 2763
		local _type_0 = type(req) -- 2763
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2763
		if _tab_0 then -- 2763
			local file -- 2763
			do -- 2763
				local _obj_0 = req.body -- 2763
				local _type_1 = type(_obj_0) -- 2763
				if "table" == _type_1 or "userdata" == _type_1 then -- 2763
					file = _obj_0.file -- 2763
				end -- 2763
			end -- 2763
			if file ~= nil then -- 2763
				if not (type(file) == "string" and Content:isAbsolutePath(file) and _anon_func_9(file)) then -- 2764
					return invalidArguments -- 2764
				end -- 2764
				file = Path(Path:getPath(file), Path:getFilename(file)) -- 2765
				local snapshotRoot = getProjectDirFromFile(file) or Path:getPath(file) -- 2766
				if not (relativeToRoot(snapshotRoot, Content.writablePath) or relativeToRoot(snapshotRoot, Content.assetPath)) then -- 2767
					return invalidArguments -- 2767
				end -- 2767
				return { -- 2769
					success = true, -- 2769
					projectRoot = snapshotRoot, -- 2770
					projectScriptRoot = projectCompilerScriptRoot(snapshotRoot), -- 2771
					files = collectTSVirtualFiles(snapshotRoot), -- 2772
					luaRuntimeModules = luaRuntimeModules, -- 2773
					assetPath = Content.assetPath, -- 2774
					defaultLibFileName = compilerDefaultLib() -- 2775
				} -- 2768
			end -- 2763
		end -- 2763
	end -- 2763
	return invalidArguments -- 2762
end) -- 2762
local webIDECompilerReady = false -- 2777
local webIDEConnectionGeneration = 0 -- 2778
local tsProbeId = 0 -- 2779
local probeWebIDECompiler -- 2781
probeWebIDECompiler = function(isCancelled) -- 2781
	if HttpServer.wsConnectionCount == 0 then -- 2782
		return false -- 2782
	end -- 2782
	tsProbeId = tsProbeId + 1 -- 2783
	local requestId = "compiler-probe-" .. tostring(tsProbeId) -- 2784
	local generation = webIDEConnectionGeneration -- 2785
	local done, ready = false, false -- 2786
	local responses, expectedResponses = 0, HttpServer.wsConnectionCount -- 2787
	local listener = Node() -- 2788
	listener:gslot("AppWS", function(event) -- 2789
		if event.type == "Receive" then -- 2790
			local res = json.decode(event.msg) -- 2791
			if res then -- 2791
				if res.name == "TranspileTSProbe" and res.id == requestId then -- 2792
					responses = responses + 1 -- 2793
					ready = ready or res.success == true -- 2794
					done = ready or responses >= expectedResponses -- 2795
				end -- 2792
			end -- 2791
		end -- 2790
	end) -- 2789
	emit("AppWS", "Send", json.encode({ -- 2796
		name = "TranspileTSProbe", -- 2796
		id = requestId -- 2796
	})) -- 2796
	local deadline = App.runningTime + 5 -- 2797
	wait(function() -- 2798
		return done or HttpServer.wsConnectionCount == 0 or generation ~= webIDEConnectionGeneration or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2798
	end) -- 2798
	listener:removeFromParent() -- 2799
	ready = ready and generation == webIDEConnectionGeneration and HttpServer.wsConnectionCount > 0 -- 2800
	if generation == webIDEConnectionGeneration then -- 2801
		webIDECompilerReady = ready -- 2801
	end -- 2801
	return ready -- 2802
end -- 2781
local compilerConnectionListener = Node() -- 2804
compilerConnectionListener:addTo(Director.systemUI) -- 2806
local _anon_func_10 = function(event) -- 2808
	local _val_0 = event.type -- 2808
	return "Open" == _val_0 or "Close" == _val_0 -- 2808
end -- 2808
compilerConnectionListener:gslot("AppWS", function(event) -- 2807
	if _anon_func_10(event) then -- 2808
		webIDEConnectionGeneration = webIDEConnectionGeneration + 1 -- 2809
		webIDECompilerReady = false -- 2810
		if HttpServer.wsConnectionCount > 0 then -- 2811
			return thread(function() -- 2812
				return probeWebIDECompiler() -- 2812
			end) -- 2812
		end -- 2811
	end -- 2808
end) -- 2807
local _anon_func_11 = function(res) -- 2837
	if res.success then -- 2837
		return "tool" -- 2837
	else -- 2837
		return res.failureKind -- 2837
	end -- 2837
end -- 2837
local transpileTSFileWithWebIDE -- 2814
do -- 2814
	local tsBuildRequestId = 0 -- 2815
	transpileTSFileWithWebIDE = function(file, content, sourceRoot, files, isCancelled) -- 2816
		if not probeWebIDECompiler(isCancelled) then -- 2817
			if isCancelled and isCancelled() then -- 2818
				return { -- 2819
					success = false, -- 2819
					file = file, -- 2819
					message = "build canceled", -- 2819
					interrupted = true -- 2819
				} -- 2819
			end -- 2818
			return { -- 2820
				success = false, -- 2820
				file = file, -- 2820
				message = "TypeScript transpiler is not ready", -- 2820
				failureKind = "tool" -- 2820
			} -- 2820
		end -- 2817
		tsBuildRequestId = tsBuildRequestId + 1 -- 2821
		local requestId = "server-build-" .. tostring(tsBuildRequestId) -- 2822
		local done = false -- 2823
		local result = nil -- 2824
		local listener = Node() -- 2825
		listener:gslot("AppWS", function(event) -- 2826
			if event.type == "Receive" then -- 2827
				local res = json.decode(event.msg) -- 2828
				if res then -- 2828
					if res.name == "TranspileTS" and res.id == requestId then -- 2829
						if res.success and type(res.luaCode) == "string" and res.luaCode:match("%S") then -- 2830
							local luaFile = Path:replaceExt(file, "lua") -- 2831
							if Content:save(luaFile, res.luaCode) then -- 2832
								result = { -- 2833
									success = true, -- 2833
									file = file -- 2833
								} -- 2833
							else -- 2835
								result = { -- 2835
									success = false, -- 2835
									file = file, -- 2835
									message = "failed to save " .. tostring(luaFile) -- 2835
								} -- 2835
							end -- 2832
						else -- 2837
							result = { -- 2837
								success = false, -- 2837
								file = file, -- 2837
								message = res.message or "Compiler returned no Lua output", -- 2837
								failureKind = _anon_func_11(res) -- 2837
							} -- 2837
						end -- 2830
						done = true -- 2838
					end -- 2829
				end -- 2828
			end -- 2827
		end) -- 2826
		emit("AppWS", "Send", json.encode({ -- 2839
			name = "TranspileTS", -- 2839
			id = requestId, -- 2839
			file = file, -- 2839
			content = content, -- 2839
			projectRoot = sourceRoot, -- 2839
			projectScriptRoot = projectCompilerScriptRoot(sourceRoot), -- 2839
			files = files, -- 2839
			luaRuntimeModules = luaRuntimeModules, -- 2839
			assetPath = Content.assetPath, -- 2839
			defaultLibFileName = compilerDefaultLib() -- 2839
		})) -- 2839
		local deadline = App.runningTime + 30 -- 2840
		wait(function() -- 2841
			return done or HttpServer.wsConnectionCount == 0 or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2841
		end) -- 2841
		listener:removeFromParent() -- 2842
		if not done then -- 2843
			webIDECompilerReady = false -- 2844
			if isCancelled and isCancelled() then -- 2845
				return { -- 2846
					success = false, -- 2846
					file = file, -- 2846
					message = "build canceled", -- 2846
					interrupted = true -- 2846
				} -- 2846
			end -- 2845
			return { -- 2847
				success = false, -- 2847
				file = file, -- 2847
				message = "TypeScript transpile timed out or Web IDE disconnected", -- 2847
				failureKind = "tool" -- 2847
			} -- 2847
		end -- 2843
		return result -- 2848
	end -- 2816
end -- 2814
local compilerReadyTimeout <const> = 15 -- 2850
local compilerBuildTimeout <const> = 30 -- 2851
local compilerIdleCloseSeconds <const> = 8 -- 2852
local compilerReady = false -- 2853
local compilerRequested = false -- 2854
local compilerFailure = nil -- 2855
local compilerUsers = 0 -- 2856
local compilerCloseGeneration = 0 -- 2857
local compilerJobId = 0 -- 2858
local compilerJobs = { } -- 2859
local compilerResults = { } -- 2860
local compilerInFlight = { } -- 2861
HttpServer:post("/compiler/ready", function() -- 2863
	if not compilerRequested then -- 2864
		return { -- 2864
			success = false -- 2864
		} -- 2864
	end -- 2864
	compilerReady = true -- 2865
	return { -- 2866
		success = true -- 2866
	} -- 2866
end) -- 2863
HttpServer:post("/compiler/failure", function(req) -- 2868
	if not compilerRequested then -- 2869
		return { -- 2869
			success = false -- 2869
		} -- 2869
	end -- 2869
	do -- 2870
		local _type_0 = type(req) -- 2870
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2870
		if _tab_0 then -- 2870
			local message -- 2870
			do -- 2870
				local _obj_0 = req.body -- 2870
				local _type_1 = type(_obj_0) -- 2870
				if "table" == _type_1 or "userdata" == _type_1 then -- 2870
					message = _obj_0.message -- 2870
				end -- 2870
			end -- 2870
			if message ~= nil then -- 2870
				if type(message) == "string" then -- 2871
					compilerFailure = message -- 2872
					compilerReady = false -- 2873
					return { -- 2874
						success = true -- 2874
					} -- 2874
				end -- 2871
			end -- 2870
		end -- 2870
	end -- 2870
	return { -- 2868
		success = false -- 2868
	} -- 2868
end) -- 2868
HttpServer:postSchedule("/compiler/poll", function() -- 2876
	if not compilerRequested then -- 2877
		return { -- 2877
			success = false -- 2877
		} -- 2877
	end -- 2877
	compilerReady = true -- 2878
	local deadline = App.runningTime + 5 -- 2879
	wait(function() -- 2880
		return #compilerJobs > 0 or not compilerRequested or compilerFailure or App.runningTime >= deadline -- 2880
	end) -- 2880
	if not (compilerRequested and not compilerFailure) then -- 2881
		return { -- 2881
			success = false -- 2881
		} -- 2881
	end -- 2881
	local job = table.remove(compilerJobs, 1) -- 2882
	if job then -- 2883
		compilerInFlight[job.id] = true -- 2884
	end -- 2883
	return { -- 2885
		success = true, -- 2885
		job = job -- 2885
	} -- 2885
end) -- 2876
HttpServer:post("/compiler/result", function(req) -- 2887
	do -- 2888
		local _type_0 = type(req) -- 2888
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 2888
		if _tab_0 then -- 2888
			local body = req.body -- 2888
			if body ~= nil then -- 2888
				local id = body.id -- 2889
				if not (id and compilerInFlight[id]) then -- 2890
					return { -- 2890
						success = false, -- 2890
						message = "invalid compiler job" -- 2890
					} -- 2890
				end -- 2890
				compilerInFlight[id] = nil -- 2891
				compilerResults[id] = body -- 2892
				return { -- 2893
					success = true -- 2893
				} -- 2893
			end -- 2888
		end -- 2888
	end -- 2888
	return { -- 2887
		success = false -- 2887
	} -- 2887
end) -- 2887
local acquireCompiler -- 2895
acquireCompiler = function() -- 2895
	compilerUsers = compilerUsers + 1 -- 2896
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2897
	if not compilerRequested then -- 2898
		compilerRequested = true -- 2899
		compilerReady = false -- 2900
		compilerFailure = nil -- 2901
		return emit("AppWebView", "/compiler.html", true) -- 2902
	end -- 2898
end -- 2895
local releaseCompiler -- 2904
releaseCompiler = function() -- 2904
	compilerUsers = math.max(compilerUsers - 1, 0) -- 2905
	compilerCloseGeneration = compilerCloseGeneration + 1 -- 2906
	if not (compilerUsers == 0) then -- 2907
		return -- 2907
	end -- 2907
	local closeGeneration = compilerCloseGeneration -- 2908
	return thread(function() -- 2909
		local closeDeadline = App.runningTime + compilerIdleCloseSeconds -- 2910
		wait(function() -- 2911
			return compilerUsers > 0 or compilerCloseGeneration ~= closeGeneration or webIDECompilerReady or compilerFailure or App.runningTime >= closeDeadline -- 2912
		end) -- 2911
		if compilerUsers == 0 and compilerCloseGeneration == closeGeneration and compilerRequested then -- 2917
			compilerRequested = false -- 2918
			compilerReady = false -- 2919
			return emit("AppWebView", "/compiler.html", false) -- 2920
		end -- 2917
	end) -- 2909
end -- 2904
local removeCompilerJob -- 2922
removeCompilerJob = function(id) -- 2922
	for index = #compilerJobs, 1, -1 do -- 2923
		if compilerJobs[index].id == id then -- 2924
			table.remove(compilerJobs, index) -- 2925
		end -- 2924
	end -- 2923
	compilerInFlight[id] = nil -- 2926
	compilerResults[id] = nil -- 2927
end -- 2922
local transpileTSFileWithCompiler -- 2929
transpileTSFileWithCompiler = function(file, content, sourceRoot, files, isCancelled) -- 2929
	acquireCompiler() -- 2930
	local readyDeadline = App.runningTime + compilerReadyTimeout -- 2931
	wait(function() -- 2932
		return compilerReady or compilerFailure or App.runningTime >= readyDeadline or (isCancelled and isCancelled()) -- 2932
	end) -- 2932
	if not compilerReady then -- 2933
		releaseCompiler() -- 2934
		if isCancelled and isCancelled() then -- 2935
			return { -- 2936
				success = false, -- 2936
				file = file, -- 2936
				message = "build canceled", -- 2936
				interrupted = true -- 2936
			} -- 2936
		end -- 2935
		return { -- 2937
			success = false, -- 2937
			file = file, -- 2937
			message = compilerFailure or "TypeScript compiler WebView is not ready", -- 2937
			failureKind = "tool" -- 2937
		} -- 2937
	end -- 2933
	compilerJobId = compilerJobId + 1 -- 2938
	local jobId = compilerJobId -- 2939
	compilerJobs[#compilerJobs + 1] = { -- 2941
		id = jobId, -- 2941
		file = file, -- 2942
		content = content, -- 2943
		projectRoot = sourceRoot, -- 2944
		projectScriptRoot = projectCompilerScriptRoot(sourceRoot), -- 2945
		files = files, -- 2946
		luaRuntimeModules = luaRuntimeModules, -- 2947
		assetPath = Content.assetPath, -- 2948
		defaultLibFileName = compilerDefaultLib() -- 2949
	} -- 2940
	local deadline = App.runningTime + compilerBuildTimeout -- 2950
	wait(function() -- 2951
		return compilerResults[jobId] or compilerFailure or App.runningTime >= deadline or (isCancelled and isCancelled()) -- 2951
	end) -- 2951
	local response = compilerResults[jobId] -- 2952
	removeCompilerJob(jobId) -- 2953
	releaseCompiler() -- 2954
	if not response then -- 2955
		if isCancelled and isCancelled() then -- 2956
			return { -- 2957
				success = false, -- 2957
				file = file, -- 2957
				message = "build canceled", -- 2957
				interrupted = true -- 2957
			} -- 2957
		end -- 2956
		return { -- 2958
			success = false, -- 2958
			file = file, -- 2958
			message = compilerFailure or "TypeScript transpile timed out", -- 2958
			failureKind = "tool" -- 2958
		} -- 2958
	end -- 2955
	if response.success and type(response.luaCode) == "string" and response.luaCode:match("%S") then -- 2959
		local luaFile = Path:replaceExt(file, "lua") -- 2960
		if Content:save(luaFile, response.luaCode) then -- 2961
			return { -- 2962
				success = true, -- 2962
				file = file -- 2962
			} -- 2962
		end -- 2961
		return { -- 2963
			success = false, -- 2963
			file = file, -- 2963
			message = "failed to save " .. tostring(luaFile) -- 2963
		} -- 2963
	end -- 2959
	return { -- 2964
		success = false, -- 2964
		file = file, -- 2964
		message = response.message or "TypeScript transpile failed" -- 2964
	} -- 2964
end -- 2929
local compilerFailureListener = Node() -- 2966
compilerFailureListener:gslot("AppCompilerFailure", function(message) -- 2967
	compilerFailure = message -- 2968
	compilerReady = false -- 2969
end) -- 2967
local transpileTSFile -- 2971
transpileTSFile = function(file, content, sourceRoot, files, isCancelled) -- 2971
	sourceRoot = sourceRoot or (getProjectDirFromFile(file) or Path:getPath(file)) -- 2972
	files = files or collectTSVirtualFiles(sourceRoot) -- 2973
	if HttpServer.wsConnectionCount > 0 then -- 2974
		local result = transpileTSFileWithWebIDE(file, content, sourceRoot, files, isCancelled) -- 2975
		if result.success or result.interrupted or result.failureKind ~= "tool" or not supportsCompilerWebView() then -- 2976
			return result -- 2976
		end -- 2976
		webIDECompilerReady = false -- 2977
	end -- 2974
	if supportsCompilerWebView() then -- 2978
		return transpileTSFileWithCompiler(file, content, sourceRoot, files, isCancelled) -- 2979
	end -- 2978
	return { -- 2980
		success = false, -- 2980
		file = file, -- 2980
		message = "Web IDE compiler not connected", -- 2980
		failureKind = "tool" -- 2980
	} -- 2980
end -- 2971
local buildTypeScriptFiles -- 2982
buildTypeScriptFiles = function(files, sourceRoot, isCancelled, onResult) -- 2982
	local messages = { } -- 2983
	local recordResult -- 2984
	recordResult = function(result) -- 2984
		messages[#messages + 1] = result -- 2985
		if onResult then -- 2986
			return onResult(result) -- 2986
		end -- 2986
	end -- 2984
	local fileData = { } -- 2987
	for _index_0 = 1, #files do -- 2988
		local file = files[_index_0] -- 2988
		if "d" == Path:getExt(Path:getName(file)) then -- 2989
			goto _continue_0 -- 2989
		end -- 2989
		local content = Content:load(file) -- 2990
		if content then -- 2990
			if content:match("^%s*<%?xml") then -- 2991
				goto _continue_0 -- 2991
			end -- 2991
			fileData[file] = content -- 2992
			emit("AppWS", "Send", json.encode({ -- 2993
				name = "UpdateFile", -- 2993
				file = file, -- 2993
				exists = true, -- 2993
				content = content, -- 2993
				projectRoot = sourceRoot -- 2993
			})) -- 2993
		else -- 2995
			recordResult({ -- 2995
				success = false, -- 2995
				file = file, -- 2995
				message = "failed to read file" -- 2995
			}) -- 2995
		end -- 2990
		::_continue_0:: -- 2989
	end -- 2988
	if next(fileData) then -- 2996
		local snapshot = collectTSVirtualFiles(sourceRoot) -- 2997
		for file, content in pairs(fileData) do -- 2998
			if isCancelled and isCancelled() then -- 2999
				break -- 2999
			end -- 2999
			recordResult(transpileTSFile(file, content, sourceRoot, snapshot, isCancelled)) -- 3000
		end -- 2998
	end -- 2996
	return messages -- 3001
end -- 2982
local _anon_func_12 = function(message, title) -- 3010
	if message then -- 3010
		return "Failed to build " .. tostring(title) .. "\n" .. tostring(message) -- 3010
	else -- 3010
		return "Failed to build " .. tostring(title) -- 3010
	end -- 3010
end -- 3010
local logTypeScriptBuildResult -- 3003
logTypeScriptBuildResult = function(result) -- 3003
	local file = result.file -- 3004
	local title = relativeToRoot(file, Content.writablePath) or relativeToRoot(file, Content.assetPath) or file -- 3005
	if result.success then -- 3006
		return Log("Info", "Built " .. tostring(title)) -- 3007
	else -- 3009
		local message = result.message -- 3009
		return Log("Error", _anon_func_12(message, title)) -- 3010
	end -- 3006
end -- 3003
local buildTypeScriptBatchWithLog -- 3012
buildTypeScriptBatchWithLog = function(files, sourceRoot) -- 3012
	if #files == 0 then -- 3013
		return { } -- 3013
	end -- 3013
	Log("Info", "Building TypeScript (" .. tostring(#files) .. " files)") -- 3014
	return buildTypeScriptFiles(files, sourceRoot, nil, logTypeScriptBuildResult) -- 3015
end -- 3012
local _anon_func_13 = function(getProjectDirFromFile, isDir, path) -- 3029
	if isDir then -- 3029
		return path -- 3029
	else -- 3029
		return getProjectDirFromFile(path) or Path:getPath(path) -- 3029
	end -- 3029
end -- 3029
local _anon_func_14 = function(path) -- 3032
	local _val_0 = Path:getExt(path) -- 3032
	return "ts" == _val_0 or "tsx" == _val_0 -- 3032
end -- 3032
local _anon_func_15 = function(file) -- 3037
	local _val_0 = Path:getExt(file) -- 3037
	return "ts" == _val_0 or "tsx" == _val_0 -- 3037
end -- 3037
local _anon_func_16 = function(file) -- 3043
	local _val_0 = Path:getExt(file) -- 3043
	return "ts" == _val_0 or "tsx" == _val_0 -- 3043
end -- 3043
HttpServer:postSchedule("/ts/build", function(req) -- 3017
	local finishUpdate = AgentHost.holdSourceUpdate((req.body or { }).path) -- 3018
	local buildSucceeded = false -- 3019
	local _ <close> = setmetatable({ }, { -- 3020
		__close = function() -- 3020
			return finishUpdate(buildSucceeded) -- 3020
		end -- 3020
	}) -- 3020
	do -- 3021
		local _type_0 = type(req) -- 3021
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3021
		if _tab_0 then -- 3021
			local path -- 3021
			do -- 3021
				local _obj_0 = req.body -- 3021
				local _type_1 = type(_obj_0) -- 3021
				if "table" == _type_1 or "userdata" == _type_1 then -- 3021
					path = _obj_0.path -- 3021
				end -- 3021
			end -- 3021
			if path ~= nil then -- 3021
				if not supportsCompilerWebView() and HttpServer.wsConnectionCount == 0 then -- 3022
					return { -- 3023
						success = false, -- 3023
						message = "Web IDE not connected" -- 3023
					} -- 3023
				end -- 3022
				local projectRoot = req.body.projectRoot -- 3024
				local sourceRoot = getProjectSourceRoot(projectRoot) -- 3025
				if not Content:exist(path) then -- 3026
					return { -- 3027
						success = false, -- 3027
						message = "path not existed" -- 3027
					} -- 3027
				end -- 3026
				local isDir = Content:isdir(path) -- 3028
				sourceRoot = sourceRoot or _anon_func_13(getProjectDirFromFile, isDir, path) -- 3029
				local messages = { } -- 3030
				if not isDir then -- 3031
					if not (_anon_func_14(path)) then -- 3032
						return { -- 3032
							success = false, -- 3032
							message = "expecting a TypeScript file" -- 3032
						} -- 3032
					end -- 3032
					messages = buildTypeScriptFiles({ -- 3033
						path -- 3033
					}, sourceRoot, nil, logTypeScriptBuildResult) -- 3033
				else -- 3034
					local selected = req.body.files -- 3034
					if selected then -- 3034
						if not (type(selected) == "table") then -- 3035
							return { -- 3035
								success = false, -- 3035
								message = "invalid TypeScript targets" -- 3035
							} -- 3035
						end -- 3035
						for _index_0 = 1, #selected do -- 3036
							local file = selected[_index_0] -- 3036
							if not (type(file) == "string" and Content:isAbsolutePath(file) and relativeToRoot(file, path) and _anon_func_15(file)) then -- 3037
								return { -- 3038
									success = false, -- 3038
									message = "TypeScript target must be inside the build directory" -- 3038
								} -- 3038
							end -- 3037
						end -- 3036
						messages = buildTypeScriptBatchWithLog(selected, sourceRoot) -- 3039
					else -- 3041
						local BuildPlan = require("Agent.Tool.BuildPlan") -- 3041
						local _list_0 = BuildPlan.planDirectoryBuild(path, sourceRoot, { -- 3042
							"!**/.*/**" -- 3042
						}) -- 3042
						for _index_0 = 1, #_list_0 do -- 3042
							local unit = _list_0[_index_0] -- 3042
							local files -- 3043
							do -- 3043
								local _accum_0 = { } -- 3043
								local _len_0 = 1 -- 3043
								local _list_1 = unit.files -- 3043
								for _index_1 = 1, #_list_1 do -- 3043
									local file = _list_1[_index_1] -- 3043
									if _anon_func_16(file) then -- 3043
										_accum_0[_len_0] = file -- 3043
										_len_0 = _len_0 + 1 -- 3043
									end -- 3043
								end -- 3043
								files = _accum_0 -- 3043
							end -- 3043
							local _list_1 = buildTypeScriptBatchWithLog(files, unit.projectRoot or sourceRoot) -- 3044
							for _index_1 = 1, #_list_1 do -- 3044
								local result = _list_1[_index_1] -- 3044
								messages[#messages + 1] = result -- 3045
							end -- 3044
						end -- 3042
					end -- 3034
				end -- 3031
				local success = true -- 3046
				for _index_0 = 1, #messages do -- 3047
					local item = messages[_index_0] -- 3047
					if not item.success then -- 3048
						success = false -- 3049
					end -- 3048
				end -- 3047
				local message = nil -- 3050
				if not success then -- 3051
					message = "TypeScript compilation failed" -- 3051
				end -- 3051
				buildSucceeded = success -- 3052
				return { -- 3053
					success = success, -- 3053
					messages = messages, -- 3053
					message = message -- 3053
				} -- 3053
			end -- 3021
		end -- 3021
	end -- 3021
	return { -- 3017
		success = false -- 3017
	} -- 3017
end) -- 3017
HttpServer:post("/download", function(req) -- 3055
	do -- 3056
		local _type_0 = type(req) -- 3056
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3056
		if _tab_0 then -- 3056
			local url -- 3056
			do -- 3056
				local _obj_0 = req.body -- 3056
				local _type_1 = type(_obj_0) -- 3056
				if "table" == _type_1 or "userdata" == _type_1 then -- 3056
					url = _obj_0.url -- 3056
				end -- 3056
			end -- 3056
			local target -- 3056
			do -- 3056
				local _obj_0 = req.body -- 3056
				local _type_1 = type(_obj_0) -- 3056
				if "table" == _type_1 or "userdata" == _type_1 then -- 3056
					target = _obj_0.target -- 3056
				end -- 3056
			end -- 3056
			if url ~= nil and target ~= nil then -- 3056
				local Entry = require("Script.Dev.Entry") -- 3057
				Entry.downloadFile(url, target) -- 3058
				return { -- 3059
					success = true -- 3059
				} -- 3059
			end -- 3056
		end -- 3056
	end -- 3056
	return { -- 3055
		success = false -- 3055
	} -- 3055
end) -- 3055
local isDesktopPlatform -- 3061
isDesktopPlatform = function() -- 3061
	local _val_0 = App.platform -- 3062
	return "Linux" == _val_0 or "Windows" == _val_0 or "macOS" == _val_0 -- 3062
end -- 3061
local nativeIDEState, nativeIDEMessage = "stopped", "" -- 3064
local nativeIDEListener = Node() -- 3065
nativeIDEListener:addTo(Director.systemUI) -- 3066
nativeIDEListener:gslot("AppIDEState", function(state, message) -- 3067
	nativeIDEState, nativeIDEMessage = state, message -- 3068
end) -- 3067
local _anon_func_17 = function() -- 3071
	local _val_0 = App.platform -- 3071
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 3071
end -- 3071
HttpServer:post("/ide", function(req) -- 3070
	if not (_anon_func_17()) then -- 3071
		return { -- 3071
			success = false, -- 3071
			message = "Native IDE is unavailable" -- 3071
		} -- 3071
	end -- 3071
	if not App.webIDEEnabled then -- 3072
		return { -- 3072
			success = false, -- 3072
			message = "Embedded Web IDE is disabled" -- 3072
		} -- 3072
	end -- 3072
	do -- 3073
		local _type_0 = type(req) -- 3073
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3073
		if _tab_0 then -- 3073
			local action -- 3073
			do -- 3073
				local _obj_0 = req.body -- 3073
				local _type_1 = type(_obj_0) -- 3073
				if "table" == _type_1 or "userdata" == _type_1 then -- 3073
					action = _obj_0.action -- 3073
				end -- 3073
			end -- 3073
			if action ~= nil then -- 3073
				if ("show" == action or "hide" == action or "stop" == action or "reload" == action or "toggle" == action) then -- 3074
					emit("AppWebView", "/ide/" .. action, true) -- 3075
					return { -- 3076
						success = true -- 3076
					} -- 3076
				end -- 3074
			end -- 3073
		end -- 3073
	end -- 3073
	return { -- 3070
		success = false, -- 3070
		message = "invalid IDE action" -- 3070
	} -- 3070
end) -- 3070
local _anon_func_18 = function() -- 3092
	local _val_0 = App.platform -- 3092
	return "Android" == _val_0 or "macOS" == _val_0 or "Windows" == _val_0 -- 3092
end -- 3092
local getServerStatus -- 3078
getServerStatus = function() -- 3078
	local Entry = require("Script.Dev.Entry") -- 3079
	local running = Entry.getCurrentEntryStatus() -- 3080
	local waTemplateReady = Content:exist(Path(Content.assetPath, "dora-wa", "wa.mod")) -- 3081
	local wsConnectionCount = HttpServer.wsConnectionCount -- 3082
	return { -- 3084
		success = true, -- 3084
		platform = App.platform, -- 3085
		locale = App.locale, -- 3086
		version = App.version, -- 3087
		url = "http://localhost:8866", -- 3088
		wsConnectionCount = wsConnectionCount, -- 3089
		webIDEConnected = wsConnectionCount > 0, -- 3090
		nativeIDE = { -- 3092
			supported = _anon_func_18(), -- 3092
			enabled = App.webIDEEnabled, -- 3093
			state = nativeIDEState, -- 3094
			message = nativeIDEMessage -- 3095
		}, -- 3091
		typescriptCompiler = { -- 3097
			webIDEReady = webIDECompilerReady, -- 3097
			webIDEGeneration = webIDEConnectionGeneration, -- 3098
			embeddedSupported = supportsCompilerWebView(), -- 3099
			embeddedRequested = compilerRequested, -- 3100
			embeddedReady = compilerReady, -- 3101
			users = compilerUsers, -- 3102
			queuedJobs = #compilerJobs, -- 3103
			failure = compilerFailure -- 3104
		}, -- 3096
		assetPath = Content.assetPath, -- 3105
		writablePath = Content.writablePath, -- 3106
		appPath = Content.appPath, -- 3107
		waTemplateReady = waTemplateReady, -- 3108
		running = running -- 3109
	} -- 3083
end -- 3078
HttpServer:post("/status", function() -- 3112
	return getServerStatus() -- 3113
end) -- 3112
HttpServer:postSchedule("/doctor/fix", function(req) -- 3115
	do -- 3116
		local _type_0 = type(req) -- 3116
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3116
		if _tab_0 then -- 3116
			local openWebIDE -- 3116
			do -- 3116
				local _obj_0 = req.body -- 3116
				local _type_1 = type(_obj_0) -- 3116
				if "table" == _type_1 or "userdata" == _type_1 then -- 3116
					openWebIDE = _obj_0.openWebIDE -- 3116
				end -- 3116
			end -- 3116
			if openWebIDE ~= nil then -- 3116
				if not openWebIDE then -- 3117
					return { -- 3118
						success = false, -- 3118
						message = "nothing to fix" -- 3118
					} -- 3118
				end -- 3117
				local status = getServerStatus() -- 3119
				if status.webIDEConnected then -- 3120
					return { -- 3121
						success = true, -- 3121
						fixed = false, -- 3121
						message = "Web IDE already connected.", -- 3121
						status = status -- 3121
					} -- 3121
				end -- 3120
				local waitSeconds = math.max(0, math.min(10, tonumber(req.body.waitSeconds) or 3)) -- 3122
				if waitSeconds > 0 then -- 3123
					local deadline = os.time() + waitSeconds -- 3124
					repeat -- 3125
						sleep(0.2) -- 3126
						status = getServerStatus() -- 3127
						if status.webIDEConnected then -- 3128
							return { -- 3129
								success = true, -- 3129
								fixed = false, -- 3129
								reconnected = true, -- 3129
								message = "Web IDE reconnected.", -- 3129
								status = status -- 3129
							} -- 3129
						end -- 3128
					until os.time() >= deadline -- 3125
				end -- 3123
				if not isDesktopPlatform() then -- 3131
					return { -- 3132
						success = false, -- 3132
						message = "opening Web IDE is only supported on desktop platforms", -- 3132
						status = status -- 3132
					} -- 3132
				end -- 3131
				local url = "http://localhost:8866" -- 3133
				App:openURL(url) -- 3134
				status.openedURL = url -- 3135
				return { -- 3136
					success = true, -- 3136
					fixed = true, -- 3136
					message = "Opened Web IDE in the local browser.", -- 3136
					url = url, -- 3136
					status = status -- 3136
				} -- 3136
			end -- 3116
		end -- 3116
	end -- 3116
	return { -- 3115
		success = false, -- 3115
		message = "invalid call" -- 3115
	} -- 3115
end) -- 3115
local status = { } -- 3138
_module_0 = status -- 3139
status.transpileTSFile = transpileTSFile -- 3141
status.buildTypeScriptFiles = buildTypeScriptFiles -- 3142
HttpServer:post("/build/plan", function(req) -- 3144
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
				if not (type(path) == "string" and Content:isAbsolutePath(path) and Content:isdir(path)) then -- 3146
					return invalidArguments -- 3146
				end -- 3146
				local BuildPlan = require("Agent.Tool.BuildPlan") -- 3147
				local project = getProjectDirFromFile(Path(path, "__dora_project_root_search__.lua")) -- 3148
				do -- 3149
					local _exp_0 = req.body.mode -- 3149
					if "editor" == _exp_0 then -- 3150
						if not (relativeToRoot(path, Content.writablePath) or relativeToRoot(path, Content.assetPath)) then -- 3151
							return invalidArguments -- 3151
						end -- 3151
						return { -- 3152
							success = true, -- 3152
							units = BuildPlan.planDirectoryBuild(path, project, nil, extentionLevels) -- 3152
						} -- 3152
					elseif "cli" == _exp_0 then -- 3153
						return { -- 3154
							success = true, -- 3154
							units = BuildPlan.planDirectoryBuild(path, project, { -- 3154
								"!**/API/**", -- 3154
								"!**/build/**", -- 3154
								"!**/dist/**", -- 3154
								"!**/target/**", -- 3154
								"!**/vendor/**" -- 3154
							}) -- 3154
						} -- 3154
					end -- 3149
				end -- 3149
				return { -- 3155
					success = true, -- 3155
					units = BuildPlan.planDirectoryBuild(path, project) -- 3155
				} -- 3155
			end -- 3145
		end -- 3145
	end -- 3145
	return invalidArguments -- 3144
end) -- 3144
HttpServer:postSchedule("/godot/project", function(req) -- 3158
	do -- 3159
		local _type_0 = type(req) -- 3159
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3159
		if _tab_0 then -- 3159
			local path -- 3159
			do -- 3159
				local _obj_0 = req.body -- 3159
				local _type_1 = type(_obj_0) -- 3159
				if "table" == _type_1 or "userdata" == _type_1 then -- 3159
					path = _obj_0.path -- 3159
				end -- 3159
			end -- 3159
			if path ~= nil then -- 3159
				if not (type(path) == "string" and Content:isAbsolutePath(path)) then -- 3160
					return invalidArguments -- 3160
				end -- 3160
				local releaseAgent = AgentHost.acquire() -- 3161
				local _ <close> = setmetatable({ }, { -- 3162
					__close = function() -- 3162
						return releaseAgent() -- 3162
					end -- 3162
				}) -- 3162
				local GodotBuild = require("Agent.Tool.GodotBuild") -- 3163
				local project = GodotBuild.findGodotProject(Content.writablePath, path) or GodotBuild.findGodotProject(Content.assetPath, path) -- 3164
				if not project then -- 3165
					return { -- 3165
						success = true, -- 3165
						found = false -- 3165
					} -- 3165
				end -- 3165
				if not (req.body.build == true) then -- 3166
					return { -- 3166
						success = true, -- 3166
						found = true, -- 3166
						projectRoot = project -- 3166
					} -- 3166
				end -- 3166
				local result -- 3167
				local promise = GodotBuild.buildGodotProject(project) -- 3168
				local onFulfilled -- 3169
				onFulfilled = function(_, value) -- 3169
					result = value -- 3170
				end -- 3169
				local onRejected -- 3171
				onRejected = function(_, err) -- 3171
					result = { -- 3172
						success = false, -- 3172
						message = tostring(err) -- 3172
					} -- 3172
				end -- 3171
				promise["then"](promise, onFulfilled, onRejected) -- 3173
				wait(function() -- 3174
					return result ~= nil -- 3174
				end) -- 3174
				result.found = true -- 3175
				result.projectRoot = project -- 3176
				return result -- 3177
			end -- 3159
		end -- 3159
	end -- 3159
	return invalidArguments -- 3158
end) -- 3158
status.buildAsync = function(path, projectRoot) -- 3179
	if projectRoot == nil then -- 3179
		projectRoot = nil -- 3179
	end -- 3179
	if not Content:exist(path) then -- 3180
		return { -- 3181
			success = false, -- 3181
			file = path, -- 3181
			message = "file not existed" -- 3181
		} -- 3181
	end -- 3180
	do -- 3182
		local _exp_0 = Path:getExt(path) -- 3182
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 3182
			if '' == Path:getExt(Path:getName(path)) then -- 3183
				local content = Content:loadAsync(path) -- 3184
				if content then -- 3184
					local resultCodes, err = compileFileAsync(path, content, projectRoot) -- 3185
					if resultCodes then -- 3186
						return { -- 3187
							success = true, -- 3187
							file = path -- 3187
						} -- 3187
					else -- 3189
						return { -- 3189
							success = false, -- 3189
							file = path, -- 3189
							message = err -- 3189
						} -- 3189
					end -- 3186
				end -- 3184
			end -- 3183
		elseif "lua" == _exp_0 then -- 3190
			local content = Content:loadAsync(path) -- 3191
			if content then -- 3191
				do -- 3192
					local isTIC80 = CheckTIC80Code(content) -- 3192
					if isTIC80 then -- 3192
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 3193
					end -- 3192
				end -- 3192
				local success, info -- 3194
				do -- 3194
					local _obj_0 = luaCheck(path, content) -- 3194
					success, info = _obj_0.success, _obj_0.info -- 3194
				end -- 3194
				if success then -- 3195
					return { -- 3196
						success = true, -- 3196
						file = path -- 3196
					} -- 3196
				elseif info and #info > 0 then -- 3197
					local messages = { } -- 3198
					for _index_0 = 1, #info do -- 3199
						local _des_0 = info[_index_0] -- 3199
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 3199
						local lineText = "" -- 3200
						if line then -- 3201
							local currentLine = 1 -- 3202
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3203
								if currentLine == line then -- 3204
									lineText = text -- 3205
									break -- 3206
								end -- 3204
								currentLine = currentLine + 1 -- 3207
							end -- 3203
						end -- 3201
						if line then -- 3208
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3209
						else -- 3211
							messages[#messages + 1] = message -- 3211
						end -- 3208
					end -- 3199
					return { -- 3212
						success = false, -- 3212
						file = path, -- 3212
						message = table.concat(messages, "\n") -- 3212
					} -- 3212
				else -- 3214
					return { -- 3214
						success = false, -- 3214
						file = path, -- 3214
						message = "lua check failed" -- 3214
					} -- 3214
				end -- 3195
			end -- 3191
		elseif "yarn" == _exp_0 then -- 3215
			local content = Content:loadAsync(path) -- 3216
			if content then -- 3216
				local res, _, err = yarncompile(content, true) -- 3217
				if res then -- 3217
					return { -- 3218
						success = true, -- 3218
						file = path -- 3218
					} -- 3218
				else -- 3220
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 3220
					local lineText = "" -- 3221
					if line then -- 3222
						local currentLine = 1 -- 3223
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 3224
							if currentLine == line then -- 3225
								lineText = text -- 3226
								break -- 3227
							end -- 3225
							currentLine = currentLine + 1 -- 3228
						end -- 3224
					end -- 3222
					if node ~= "" then -- 3229
						node = "node: " .. tostring(node) .. ", " -- 3230
					else -- 3231
						node = "" -- 3231
					end -- 3229
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 3232
					return { -- 3233
						success = false, -- 3233
						file = path, -- 3233
						message = message -- 3233
					} -- 3233
				end -- 3217
			end -- 3216
		end -- 3182
	end -- 3182
	return { -- 3234
		success = false, -- 3234
		file = path, -- 3234
		message = "invalid file to build" -- 3234
	} -- 3234
end -- 3179
HttpServer:postSchedule("/git/commit-files", function(req) -- 3236
	do -- 3237
		local _type_0 = type(req) -- 3237
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3237
		if _tab_0 then -- 3237
			local body = req.body -- 3237
			if body ~= nil then -- 3237
				local repoPath, commit = body.repoPath, body.commit -- 3238
				if gitInvalidRepoPath(repoPath) then -- 3239
					return { -- 3239
						success = false, -- 3239
						message = "invalid repoPath" -- 3239
					} -- 3239
				end -- 3239
				if not (type(commit) == "string" and commit:match("^[0-9a-fA-F]+$")) then -- 3240
					return { -- 3240
						success = false, -- 3240
						message = "invalid commit" -- 3240
					} -- 3240
				end -- 3240
				local res = gitRunSync(repoPath, "log --changed-files " .. tostring(gitQuote(commit)), nil, 10) -- 3241
				if not res.success then -- 3242
					return res -- 3242
				end -- 3242
				return { -- 3243
					success = true, -- 3243
					status = res.status, -- 3243
					data = res.status and res.status.data -- 3243
				} -- 3243
			end -- 3237
		end -- 3237
	end -- 3237
	return invalidArguments -- 3236
end) -- 3236
Director.systemScheduler:schedule(once(function() -- 3247
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 3248
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 3249
	if Content:exist(doraWeb) or Content:exist(doraWeb .. ".gz") then -- 3250
		local storedAsset -- 3253
		storedAsset = function(file) -- 3253
			if Content:exist(file) then -- 3254
				return Content:load(file) -- 3255
			elseif Content:exist(file .. ".gz") then -- 3256
				return Content:load(file .. ".gz") -- 3257
			else -- 3258
				return "" -- 3258
			end -- 3254
		end -- 3253
		local heavyAssets = Path(Content.assetPath, "www", "heavy-assets.json") -- 3259
		local runtimeIndex = Path(Content.assetPath, "www", "web-player", "runtime.json") -- 3260
		local compilerIndex = Path(Content.assetPath, "www", "compiler.html") -- 3261
		local manifest = Path(Content.assetPath, "www", "precompressed-assets.json") -- 3262
		local readyContent = table.concat({ -- 3264
			App.version, -- 3264
			storedAsset(doraWeb), -- 3265
			storedAsset(heavyAssets), -- 3266
			storedAsset(runtimeIndex), -- 3267
			storedAsset(compilerIndex), -- 3268
			storedAsset(manifest) -- 3269
		}, "\n") -- 3263
		local needReload -- 3271
		if Content:exist(doraReady) then -- 3271
			needReload = readyContent ~= Content:load(doraReady) -- 3272
		else -- 3273
			needReload = true -- 3273
		end -- 3271
		if needReload then -- 3274
			Content:remove(Path(Content.appPath, ".www")) -- 3275
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 3276
			Content:save(doraReady, readyContent) -- 3280
			print("Dora Dora is ready!") -- 3281
		end -- 3274
	end -- 3250
	if App.platform == "Emscripten" then -- 3282
		status.url = nil -- 3283
		return print("HttpServer is unavailable in the browser; use the hosting web server.") -- 3284
	end -- 3282
	HttpServer:clearStaticCacheControls() -- 3285
	HttpServer:setStaticCacheControl("no-cache") -- 3286
	HttpServer:addStaticCacheControl("^/((assets|monacoeditorwork)/.*|typescript)-[A-Za-z0-9_-]{8,}[.][^/]+$", "public, max-age=31536000, immutable") -- 3287
	if HttpServer:start(8866) then -- 3291
		local localIP = HttpServer.localIP -- 3292
		if localIP == "" then -- 3293
			localIP = "localhost" -- 3293
		end -- 3293
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 3294
		return HttpServer:startWS(8868) -- 3295
	else -- 3297
		status.url = nil -- 3297
		return print("8866 Port not available!") -- 3298
	end -- 3291
end)) -- 3247
nativeExportFormats = function(root) -- 3300
	local relative = relativeToRoot(root, Content.writablePath) -- 3301
	if not (relative and relative ~= "") then -- 3302
		return nil -- 3302
	end -- 3302
	for part in relative:gmatch("[^/\\]+") do -- 3304
		if part:sub(1, 1) == "." then -- 3305
			return nil -- 3305
		end -- 3305
	end -- 3304
	if App.platform == "Emscripten" then -- 3306
		return nil -- 3306
	end -- 3306
	return { -- 3307
		"windows", -- 3307
		"android" -- 3307
	} -- 3307
end -- 3300
nativeExportInfo = function(projectRoot) -- 3309
	local formats = nativeExportFormats(projectRoot) -- 3310
	local legacy -- 3311
	if formats then -- 3311
		local _exp_0 = App.platform -- 3312
		if "Windows" == _exp_0 then -- 3313
			legacy = "windows" -- 3313
		elseif "Android" == _exp_0 then -- 3314
			legacy = "android" -- 3314
		end -- 3312
	end -- 3311
	return { -- 3315
		success = true, -- 3315
		found = true, -- 3315
		projectRoot = projectRoot, -- 3315
		title = Path:getFilename(projectRoot), -- 3315
		nativeExports = formats, -- 3315
		nativeExport = legacy, -- 3315
		androidExportOnDevice = App.platform == "Android" -- 3315
	} -- 3315
end -- 3309
local nativeExporting = false -- 3318
local _anon_func_19 = function(format, formats) -- 3324
	for _index_0 = 1, #formats do -- 3324
		if formats[_index_0] == format then -- 3324
			return true -- 3324
		end -- 3324
	end -- 3324
	return false -- 3324
end -- 3324
local _anon_func_20 = function() -- 3326
	local _val_0 = App.platform -- 3326
	return "macOS" == _val_0 or "Windows" == _val_0 or "Linux" == _val_0 or "iOS" == _val_0 -- 3326
end -- 3326
local _anon_func_21 = function(file) -- 3338
	local _val_0 = Path:getExt(file) -- 3338
	return "lua" == _val_0 or "yue" == _val_0 or "tl" == _val_0 or "xml" == _val_0 or "wasm" == _val_0 -- 3338
end -- 3338
local exportGame -- 3319
exportGame = function(req, signing) -- 3319
	if signing == nil then -- 3319
		signing = false -- 3319
	end -- 3319
	do -- 3320
		local _type_0 = type(req) -- 3320
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 3320
		if _tab_0 then -- 3320
			local path -- 3320
			do -- 3320
				local _obj_0 = req.body -- 3320
				local _type_1 = type(_obj_0) -- 3320
				if "table" == _type_1 or "userdata" == _type_1 then -- 3320
					path = _obj_0.path -- 3320
				end -- 3320
			end -- 3320
			local format -- 3320
			do -- 3320
				local _obj_0 = req.body -- 3320
				local _type_1 = type(_obj_0) -- 3320
				if "table" == _type_1 or "userdata" == _type_1 then -- 3320
					format = _obj_0.format -- 3320
				end -- 3320
			end -- 3320
			if path ~= nil and format ~= nil then -- 3320
				if not (type(path) == "string" and Content:isAbsolutePath(path)) then -- 3321
					return invalidArguments -- 3321
				end -- 3321
				local formats = nativeExportFormats(path) -- 3322
				local web -- 3323
				web = ("html" == format or "http" == format) -- 3323
				if not (formats and (web or (#formats > 0 and _anon_func_19(format, formats))) and isProjectRootDir(path)) then -- 3324
					return invalidArguments -- 3324
				end -- 3324
				if signing then -- 3325
					if not (format == "android" and _anon_func_20()) then -- 3326
						return invalidArguments -- 3326
					end -- 3326
					local android = req.body.android -- 3327
					if not (type(android) == "table" and type(android.game) == "table") then -- 3328
						return invalidArguments -- 3328
					end -- 3328
					if not (type(android.password) == "string" and #android.password > 0 and #android.password <= 1024) then -- 3329
						return invalidArguments -- 3329
					end -- 3329
					if android.key ~= nil and (type(android.key) ~= "string" or #android.key > 1400000) then -- 3330
						return invalidArguments -- 3330
					end -- 3330
				elseif format == "android" and App.platform ~= "Android" then -- 3331
					return { -- 3332
						success = false, -- 3332
						message = "Use the local APK signing endpoint" -- 3332
					} -- 3332
				end -- 3325
				local zh = App.locale:match("^zh") -- 3333
				if nativeExporting then -- 3334
					return { -- 3335
						success = false, -- 3335
						message = zh and "正在导出游戏" or "A game export is in progress" -- 3335
					} -- 3335
				end -- 3334
				local entry -- 3336
				local _list_0 = Content:getFiles(path) -- 3337
				for _index_0 = 1, #_list_0 do -- 3337
					local file = _list_0[_index_0] -- 3337
					if Path:getName(file):lower() == "init" and _anon_func_21(file) then -- 3338
						entry = Path(path, Path:replaceExt(file, "")) -- 3339
						break -- 3340
					end -- 3338
				end -- 3337
				if not entry then -- 3341
					return { -- 3342
						success = false, -- 3342
						message = zh and "请先在 IDE 中编译游戏" or "Build the game in the IDE first" -- 3342
					} -- 3342
				end -- 3341
				nativeExporting = true -- 3343
				local _ <close> = setmetatable({ }, { -- 3344
					__close = function() -- 3344
						nativeExporting = false -- 3344
					end -- 3344
				}) -- 3344
				local title = Path:getFilename(path) -- 3345
				local exporter = require("Script.Dev.NativeGameExport") -- 3346
				if format == "android" and not signing then -- 3347
					local ok, result = pcall(exporter.exportAndroid, path, entry, title) -- 3348
					if ok then -- 3349
						return { -- 3349
							success = true -- 3349
						} -- 3349
					end -- 3349
					return { -- 3350
						success = false, -- 3350
						message = tostring(result) -- 3350
					} -- 3350
				end -- 3347
				local newId = require("dora.new_game_id") -- 3351
				local destination = Path(Content.writablePath, ".download", "native-" .. tostring(newId())) -- 3352
				if not Content:mkdir(destination) then -- 3353
					return { -- 3354
						success = false, -- 3354
						message = zh and "无法创建导出目录" or "Could not create the export directory" -- 3354
					} -- 3354
				end -- 3353
				local ok, result = pcall(function() -- 3355
					if format == "windows" then -- 3356
						local archive = exporter.exportWindows(path, entry, title, destination) -- 3357
						return { -- 3358
							success = true, -- 3358
							archive = archive -- 3358
						} -- 3358
					end -- 3356
					local archive, signingKey = exporter.exportPackage(format, path, entry, destination, req.body.android) -- 3359
					return { -- 3360
						success = true, -- 3360
						archive = archive, -- 3360
						signingKey = signingKey -- 3360
					} -- 3360
				end) -- 3355
				if ok then -- 3361
					return result -- 3361
				end -- 3361
				Content:remove(destination) -- 3362
				return { -- 3363
					success = false, -- 3363
					message = tostring(result) -- 3363
				} -- 3363
			end -- 3320
		end -- 3320
	end -- 3320
	return invalidArguments -- 3364
end -- 3319
HttpServer:postSchedule("/native-game/export", function(req) -- 3366
	return exportGame(req) -- 3366
end) -- 3366
HttpServer:postSchedule("/native-game/sign", function(req) -- 3367
	return exportGame(req, true) -- 3367
end) -- 3367
return _module_0 -- 1
