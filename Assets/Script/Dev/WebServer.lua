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
local yue <const> = yue -- 10
local load <const> = load -- 10
local tonumber <const> = tonumber -- 10
local teal <const> = teal -- 10
local xml <const> = xml -- 10
local ipairs <const> = ipairs -- 10
local pairs <const> = pairs -- 10
local App <const> = App -- 10
local DB <const> = DB -- 10
local setmetatable <const> = setmetatable -- 10
local wait <const> = wait -- 10
local package <const> = package -- 10
local thread <const> = thread -- 10
local print <const> = print -- 10
local sleep <const> = sleep -- 10
local json <const> = json -- 10
local emit <const> = emit -- 10
local Wasm <const> = Wasm -- 10
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
local isProjectRootDir -- 106
isProjectRootDir = function(dir) -- 106
	if not (dir and dir ~= "" and Content:exist(dir) and Content:isdir(dir)) then -- 107
		return false -- 107
	end -- 107
	local _list_0 = Content:getFiles(dir) -- 108
	for _index_0 = 1, #_list_0 do -- 108
		local f = _list_0[_index_0] -- 108
		if Path:getName(f):lower() == "init" then -- 109
			return true -- 110
		end -- 109
	end -- 108
	return false -- 111
end -- 106
local getProjectRootFromPath -- 113
getProjectRootFromPath = function(target, isDir) -- 113
	if isDir == nil then -- 113
		isDir = false -- 113
	end -- 113
	if not (target and target ~= "" and Content:isAbsolutePath(target)) then -- 114
		return nil, "invalid path" -- 114
	end -- 114
	if isDir then -- 115
		if isProjectRootDir(target) then -- 116
			return target -- 116
		end -- 116
		return getProjectDirFromFile(Path(target, "__dora_project_root_search__.lua"), "current directory does not belong to any project") -- 117
	end -- 115
	return getProjectDirFromFile(target, "current file does not belong to any project") -- 118
end -- 113
local invalidArguments = { -- 120
	success = false, -- 120
	message = "invalid arguments" -- 120
} -- 120
HttpServer:post("/agent/project-root", function(req) -- 122
	do -- 123
		local _type_0 = type(req) -- 123
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 123
		if _tab_0 then -- 123
			local path -- 123
			do -- 123
				local _obj_0 = req.body -- 123
				local _type_1 = type(_obj_0) -- 123
				if "table" == _type_1 or "userdata" == _type_1 then -- 123
					path = _obj_0.path -- 123
				end -- 123
			end -- 123
			local isDir -- 123
			do -- 123
				local _obj_0 = req.body -- 123
				local _type_1 = type(_obj_0) -- 123
				if "table" == _type_1 or "userdata" == _type_1 then -- 123
					isDir = _obj_0.isDir -- 123
				end -- 123
			end -- 123
			if path ~= nil and isDir ~= nil then -- 123
				local projectRoot, err = getProjectRootFromPath(path, isDir) -- 124
				if projectRoot then -- 124
					return { -- 125
						success = true, -- 125
						found = true, -- 125
						projectRoot = projectRoot, -- 125
						title = Path:getFilename(projectRoot) -- 125
					} -- 125
				else -- 127
					return { -- 127
						success = true, -- 127
						found = false, -- 127
						message = err -- 127
					} -- 127
				end -- 124
			end -- 123
		end -- 123
	end -- 123
	return invalidArguments -- 122
end) -- 122
local AgentTools = require("Agent.Tools") -- 129
local AgentSession = require("Agent.AgentSession") -- 130
HttpServer:post("/agent/session/create", function(req) -- 132
	do -- 133
		local _type_0 = type(req) -- 133
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 133
		if _tab_0 then -- 133
			local projectRoot -- 133
			do -- 133
				local _obj_0 = req.body -- 133
				local _type_1 = type(_obj_0) -- 133
				if "table" == _type_1 or "userdata" == _type_1 then -- 133
					projectRoot = _obj_0.projectRoot -- 133
				end -- 133
			end -- 133
			local title -- 133
			do -- 133
				local _obj_0 = req.body -- 133
				local _type_1 = type(_obj_0) -- 133
				if "table" == _type_1 or "userdata" == _type_1 then -- 133
					title = _obj_0.title -- 133
				end -- 133
			end -- 133
			if projectRoot ~= nil and title ~= nil then -- 133
				return AgentSession.createSession(projectRoot, title) -- 134
			end -- 133
		end -- 133
	end -- 133
	return invalidArguments -- 132
end) -- 132
HttpServer:post("/agent/session/create-sub", function(req) -- 136
	do -- 137
		local _type_0 = type(req) -- 137
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 137
		if _tab_0 then -- 137
			local parentSessionId -- 137
			do -- 137
				local _obj_0 = req.body -- 137
				local _type_1 = type(_obj_0) -- 137
				if "table" == _type_1 or "userdata" == _type_1 then -- 137
					parentSessionId = _obj_0.parentSessionId -- 137
				end -- 137
			end -- 137
			local title -- 137
			do -- 137
				local _obj_0 = req.body -- 137
				local _type_1 = type(_obj_0) -- 137
				if "table" == _type_1 or "userdata" == _type_1 then -- 137
					title = _obj_0.title -- 137
				end -- 137
			end -- 137
			if parentSessionId ~= nil and title ~= nil then -- 137
				return AgentSession.createSubSession(parentSessionId, title) -- 138
			end -- 137
		end -- 137
	end -- 137
	return invalidArguments -- 136
end) -- 136
HttpServer:post("/agent/session/get", function(req) -- 140
	do -- 141
		local _type_0 = type(req) -- 141
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 141
		if _tab_0 then -- 141
			local sessionId -- 141
			do -- 141
				local _obj_0 = req.body -- 141
				local _type_1 = type(_obj_0) -- 141
				if "table" == _type_1 or "userdata" == _type_1 then -- 141
					sessionId = _obj_0.sessionId -- 141
				end -- 141
			end -- 141
			if sessionId ~= nil then -- 141
				return AgentSession.getSession(sessionId) -- 142
			end -- 141
		end -- 141
	end -- 141
	return invalidArguments -- 140
end) -- 140
HttpServer:post("/agent/session/send", function(req) -- 144
	do -- 145
		local _type_0 = type(req) -- 145
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 145
		if _tab_0 then -- 145
			local sessionId -- 145
			do -- 145
				local _obj_0 = req.body -- 145
				local _type_1 = type(_obj_0) -- 145
				if "table" == _type_1 or "userdata" == _type_1 then -- 145
					sessionId = _obj_0.sessionId -- 145
				end -- 145
			end -- 145
			local prompt -- 145
			do -- 145
				local _obj_0 = req.body -- 145
				local _type_1 = type(_obj_0) -- 145
				if "table" == _type_1 or "userdata" == _type_1 then -- 145
					prompt = _obj_0.prompt -- 145
				end -- 145
			end -- 145
			if sessionId ~= nil and prompt ~= nil then -- 145
				return AgentSession.sendPrompt(sessionId, prompt) -- 146
			end -- 145
		end -- 145
	end -- 145
	return invalidArguments -- 144
end) -- 144
HttpServer:post("/agent/task/status", function(req) -- 148
	do -- 149
		local _type_0 = type(req) -- 149
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 149
		if _tab_0 then -- 149
			local sessionId -- 149
			do -- 149
				local _obj_0 = req.body -- 149
				local _type_1 = type(_obj_0) -- 149
				if "table" == _type_1 or "userdata" == _type_1 then -- 149
					sessionId = _obj_0.sessionId -- 149
				end -- 149
			end -- 149
			if sessionId ~= nil then -- 149
				local res = AgentSession.getSession(sessionId) -- 150
				if not res.success then -- 151
					return res -- 151
				end -- 151
				local taskId = res.session.currentTaskId -- 152
				local checkpoints -- 153
				if taskId then -- 153
					checkpoints = AgentTools.listCheckpoints(taskId) -- 153
				else -- 153
					checkpoints = { } -- 153
				end -- 153
				return { -- 155
					success = true, -- 155
					session = res.session, -- 156
					relatedSessions = res.relatedSessions, -- 157
					spawnInfo = res.spawnInfo, -- 158
					messages = res.messages, -- 159
					steps = res.steps, -- 160
					checkpoints = checkpoints -- 161
				} -- 154
			end -- 149
		end -- 149
	end -- 149
	return invalidArguments -- 148
end) -- 148
HttpServer:post("/agent/task/running", function() -- 163
	return AgentSession.listRunningSessions() -- 163
end) -- 163
HttpServer:post("/agent/task/stop", function(req) -- 165
	do -- 166
		local _type_0 = type(req) -- 166
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 166
		if _tab_0 then -- 166
			local sessionId -- 166
			do -- 166
				local _obj_0 = req.body -- 166
				local _type_1 = type(_obj_0) -- 166
				if "table" == _type_1 or "userdata" == _type_1 then -- 166
					sessionId = _obj_0.sessionId -- 166
				end -- 166
			end -- 166
			if sessionId ~= nil then -- 166
				return AgentSession.stopSessionTask(sessionId) -- 167
			end -- 166
		end -- 166
	end -- 166
	return invalidArguments -- 165
end) -- 165
HttpServer:post("/agent/checkpoint/list", function(req) -- 169
	do -- 170
		local _type_0 = type(req) -- 170
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 170
		if _tab_0 then -- 170
			local taskId -- 170
			do -- 170
				local _obj_0 = req.body -- 170
				local _type_1 = type(_obj_0) -- 170
				if "table" == _type_1 or "userdata" == _type_1 then -- 170
					taskId = _obj_0.taskId -- 170
				end -- 170
			end -- 170
			local sessionId -- 170
			do -- 170
				local _obj_0 = req.body -- 170
				local _type_1 = type(_obj_0) -- 170
				if "table" == _type_1 or "userdata" == _type_1 then -- 170
					sessionId = _obj_0.sessionId -- 170
				end -- 170
			end -- 170
			if sessionId ~= nil then -- 170
				if not taskId and sessionId then -- 171
					taskId = AgentSession.getCurrentTaskId(sessionId) -- 172
				end -- 171
				if not taskId then -- 173
					return { -- 173
						success = false, -- 173
						message = "task not found" -- 173
					} -- 173
				end -- 173
				return { -- 175
					success = true, -- 175
					taskId = taskId, -- 176
					checkpoints = AgentTools.listCheckpoints(taskId) -- 177
				} -- 174
			end -- 170
		end -- 170
	end -- 170
	return invalidArguments -- 169
end) -- 169
HttpServer:post("/agent/checkpoint/diff", function(req) -- 179
	do -- 180
		local _type_0 = type(req) -- 180
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 180
		if _tab_0 then -- 180
			local checkpointId -- 180
			do -- 180
				local _obj_0 = req.body -- 180
				local _type_1 = type(_obj_0) -- 180
				if "table" == _type_1 or "userdata" == _type_1 then -- 180
					checkpointId = _obj_0.checkpointId -- 180
				end -- 180
			end -- 180
			if checkpointId ~= nil then -- 180
				if not (checkpointId > 0) then -- 181
					return { -- 181
						success = false, -- 181
						message = "invalid checkpointId" -- 181
					} -- 181
				end -- 181
				return AgentTools.getCheckpointDiff(checkpointId) -- 182
			end -- 180
		end -- 180
	end -- 180
	return invalidArguments -- 179
end) -- 179
HttpServer:post("/agent/checkpoint/rollback", function(req) -- 184
	do -- 185
		local _type_0 = type(req) -- 185
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 185
		if _tab_0 then -- 185
			local sessionId -- 185
			do -- 185
				local _obj_0 = req.body -- 185
				local _type_1 = type(_obj_0) -- 185
				if "table" == _type_1 or "userdata" == _type_1 then -- 185
					sessionId = _obj_0.sessionId -- 185
				end -- 185
			end -- 185
			local checkpointId -- 185
			do -- 185
				local _obj_0 = req.body -- 185
				local _type_1 = type(_obj_0) -- 185
				if "table" == _type_1 or "userdata" == _type_1 then -- 185
					checkpointId = _obj_0.checkpointId -- 185
				end -- 185
			end -- 185
			if sessionId ~= nil and checkpointId ~= nil then -- 185
				if not (checkpointId > 0) then -- 186
					return { -- 186
						success = false, -- 186
						message = "invalid checkpointId" -- 186
					} -- 186
				end -- 186
				local res = AgentSession.getSession(sessionId) -- 187
				if not res.success then -- 188
					return res -- 188
				end -- 188
				local rollbackRes = AgentTools.rollbackCheckpoint(checkpointId, res.session.projectRoot) -- 189
				if not rollbackRes.success then -- 190
					return rollbackRes -- 190
				end -- 190
				return { -- 192
					success = true, -- 192
					checkpointId = rollbackRes.checkpointId -- 193
				} -- 191
			end -- 185
		end -- 185
	end -- 185
	return invalidArguments -- 184
end) -- 184
local getSearchPath -- 195
getSearchPath = function(file) -- 195
	do -- 196
		local dir = getProjectDirFromFile(file) -- 196
		if dir then -- 196
			return Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 197
		end -- 196
	end -- 196
	return "" -- 195
end -- 195
local getSearchFolders -- 199
getSearchFolders = function(file) -- 199
	do -- 200
		local dir = getProjectDirFromFile(file) -- 200
		if dir then -- 200
			return { -- 202
				Path(dir, "Script"), -- 202
				dir -- 203
			} -- 201
		end -- 200
	end -- 200
	return { } -- 199
end -- 199
local disabledCheckForLua = { -- 206
	"incompatible number of returns", -- 206
	"unknown", -- 207
	"cannot index", -- 208
	"module not found", -- 209
	"don't know how to resolve", -- 210
	"ContainerItem", -- 211
	"cannot resolve a type", -- 212
	"invalid key", -- 213
	"inconsistent index type", -- 214
	"cannot use operator", -- 215
	"attempting ipairs loop", -- 216
	"expects record or nominal", -- 217
	"variable is not being assigned", -- 218
	"<invalid type>", -- 219
	"<any type>", -- 220
	"using the '#' operator", -- 221
	"can't match a record", -- 222
	"redeclaration of variable", -- 223
	"cannot apply pairs", -- 224
	"not a function", -- 225
	"to%-be%-closed" -- 226
} -- 205
local yueCheck -- 228
yueCheck = function(file, content, lax) -- 228
	local isTIC80, tic80APIs = CheckTIC80Code(content) -- 229
	if isTIC80 then -- 230
		content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 231
	end -- 230
	local searchPath = getSearchPath(file) -- 232
	local checkResult, luaCodes = yue.checkAsync(content, searchPath, lax) -- 233
	local info = { } -- 234
	local globals = { } -- 235
	for _index_0 = 1, #checkResult do -- 236
		local _des_0 = checkResult[_index_0] -- 236
		local t, msg, line, col = _des_0[1], _des_0[2], _des_0[3], _des_0[4] -- 236
		if "error" == t then -- 237
			info[#info + 1] = { -- 238
				"syntax", -- 238
				file, -- 238
				line, -- 238
				col, -- 238
				msg -- 238
			} -- 238
		elseif "global" == t then -- 239
			globals[#globals + 1] = { -- 240
				msg, -- 240
				line, -- 240
				col -- 240
			} -- 240
		end -- 237
	end -- 236
	if luaCodes then -- 241
		local success, lintResult = LintYueGlobals(luaCodes, globals, false) -- 242
		if success then -- 243
			luaCodes = luaCodes:gsub("%s*local%s*_ENV%s*=%s*Dora%([^%)]-%)[^\n\r]+[\n\r%s]*", "\n") -- 244
			if not (lintResult == "") then -- 245
				lintResult = lintResult .. "\n" -- 245
			end -- 245
			luaCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(lintResult) .. luaCodes -- 246
		else -- 247
			for _index_0 = 1, #lintResult do -- 247
				local _des_0 = lintResult[_index_0] -- 247
				local name, line, col = _des_0[1], _des_0[2], _des_0[3] -- 247
				if isTIC80 and tic80APIs[name] then -- 248
					goto _continue_0 -- 248
				end -- 248
				info[#info + 1] = { -- 249
					"syntax", -- 249
					file, -- 249
					line, -- 249
					col, -- 249
					"invalid global variable" -- 249
				} -- 249
				::_continue_0:: -- 248
			end -- 247
		end -- 243
	end -- 241
	return luaCodes, info -- 250
end -- 228
local luaCheck -- 252
luaCheck = function(file, content) -- 252
	local res, err = load(content, "check") -- 253
	if not res then -- 254
		local line, msg = err:match(".*:(%d+):%s*(.*)") -- 255
		return { -- 256
			success = false, -- 256
			info = { -- 256
				{ -- 256
					"syntax", -- 256
					file, -- 256
					tonumber(line), -- 256
					0, -- 256
					msg -- 256
				} -- 256
			} -- 256
		} -- 256
	end -- 254
	local success, info = teal.checkAsync(content, file, true, "") -- 257
	if info then -- 258
		do -- 259
			local _accum_0 = { } -- 259
			local _len_0 = 1 -- 259
			for _index_0 = 1, #info do -- 259
				local item = info[_index_0] -- 259
				local useCheck = true -- 260
				if not item[5]:match("unused") then -- 261
					for _index_1 = 1, #disabledCheckForLua do -- 262
						local check = disabledCheckForLua[_index_1] -- 262
						if item[5]:match(check) then -- 263
							useCheck = false -- 264
						end -- 263
					end -- 262
				end -- 261
				if not useCheck then -- 265
					goto _continue_0 -- 265
				end -- 265
				do -- 266
					local _exp_0 = item[1] -- 266
					if "type" == _exp_0 then -- 267
						item[1] = "warning" -- 268
					elseif "parsing" == _exp_0 or "syntax" == _exp_0 then -- 269
						goto _continue_0 -- 270
					end -- 266
				end -- 266
				_accum_0[_len_0] = item -- 271
				_len_0 = _len_0 + 1 -- 260
				::_continue_0:: -- 260
			end -- 259
			info = _accum_0 -- 259
		end -- 259
		if #info == 0 then -- 272
			info = nil -- 273
			success = true -- 274
		end -- 272
	end -- 258
	return { -- 275
		success = success, -- 275
		info = info -- 275
	} -- 275
end -- 252
local luaCheckWithLineInfo -- 277
luaCheckWithLineInfo = function(file, luaCodes) -- 277
	local res = luaCheck(file, luaCodes) -- 278
	local info = { } -- 279
	if not res.success then -- 280
		local current = 1 -- 281
		local lastLine = 1 -- 282
		local lineMap = { } -- 283
		for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 284
			local num = lineCode:match("--%s*(%d+)%s*$") -- 285
			if num then -- 286
				lastLine = tonumber(num) -- 287
			end -- 286
			lineMap[current] = lastLine -- 288
			current = current + 1 -- 289
		end -- 284
		local _list_0 = res.info -- 290
		for _index_0 = 1, #_list_0 do -- 290
			local item = _list_0[_index_0] -- 290
			item[3] = lineMap[item[3]] or 0 -- 291
			item[4] = 0 -- 292
			info[#info + 1] = item -- 293
		end -- 290
		return false, info -- 294
	end -- 280
	return true, info -- 295
end -- 277
local getCompiledYueLine -- 297
getCompiledYueLine = function(content, line, row, file, lax) -- 297
	local luaCodes = yueCheck(file, content, lax) -- 298
	if not luaCodes then -- 299
		return nil -- 299
	end -- 299
	local current = 1 -- 300
	local lastLine = 1 -- 301
	local targetLine = line:gsub("::", "\\"):gsub(":", "="):gsub("\\", ":"):match("[%w_%.:]+$") -- 302
	local targetRow = nil -- 303
	local lineMap = { } -- 304
	for lineCode in luaCodes:gmatch("([^\r\n]*)\r?\n?") do -- 305
		local num = lineCode:match("--%s*(%d+)%s*$") -- 306
		if num then -- 307
			lastLine = tonumber(num) -- 307
		end -- 307
		lineMap[current] = lastLine -- 308
		if row <= lastLine and not targetRow then -- 309
			targetRow = current -- 310
			break -- 311
		end -- 309
		current = current + 1 -- 312
	end -- 305
	targetRow = current -- 313
	if targetLine and targetRow then -- 314
		return luaCodes, targetLine, targetRow, lineMap -- 315
	else -- 317
		return nil -- 317
	end -- 314
end -- 297
HttpServer:postSchedule("/check", function(req) -- 319
	do -- 320
		local _type_0 = type(req) -- 320
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 320
		if _tab_0 then -- 320
			local file -- 320
			do -- 320
				local _obj_0 = req.body -- 320
				local _type_1 = type(_obj_0) -- 320
				if "table" == _type_1 or "userdata" == _type_1 then -- 320
					file = _obj_0.file -- 320
				end -- 320
			end -- 320
			local content -- 320
			do -- 320
				local _obj_0 = req.body -- 320
				local _type_1 = type(_obj_0) -- 320
				if "table" == _type_1 or "userdata" == _type_1 then -- 320
					content = _obj_0.content -- 320
				end -- 320
			end -- 320
			if file ~= nil and content ~= nil then -- 320
				local ext = Path:getExt(file) -- 321
				if "tl" == ext then -- 322
					local searchPath = getSearchPath(file) -- 323
					do -- 324
						local isTIC80 = CheckTIC80Code(content) -- 324
						if isTIC80 then -- 324
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 325
						end -- 324
					end -- 324
					local success, info = teal.checkAsync(content, file, false, searchPath) -- 326
					return { -- 327
						success = success, -- 327
						info = info -- 327
					} -- 327
				elseif "lua" == ext then -- 328
					do -- 329
						local isTIC80 = CheckTIC80Code(content) -- 329
						if isTIC80 then -- 329
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 330
						end -- 329
					end -- 329
					return luaCheck(file, content) -- 331
				elseif "yue" == ext then -- 332
					local luaCodes, info = yueCheck(file, content, false) -- 333
					local success = false -- 334
					if luaCodes then -- 335
						local luaSuccess, luaInfo = luaCheckWithLineInfo(file, luaCodes) -- 336
						do -- 337
							local _tab_1 = { } -- 337
							local _idx_0 = #_tab_1 + 1 -- 337
							for _index_0 = 1, #info do -- 337
								local _value_0 = info[_index_0] -- 337
								_tab_1[_idx_0] = _value_0 -- 337
								_idx_0 = _idx_0 + 1 -- 337
							end -- 337
							local _idx_1 = #_tab_1 + 1 -- 337
							for _index_0 = 1, #luaInfo do -- 337
								local _value_0 = luaInfo[_index_0] -- 337
								_tab_1[_idx_1] = _value_0 -- 337
								_idx_1 = _idx_1 + 1 -- 337
							end -- 337
							info = _tab_1 -- 337
						end -- 337
						success = success and luaSuccess -- 338
					end -- 335
					if #info > 0 then -- 339
						return { -- 340
							success = success, -- 340
							info = info -- 340
						} -- 340
					else -- 342
						return { -- 342
							success = success -- 342
						} -- 342
					end -- 339
				elseif "xml" == ext then -- 343
					local success, result = xml.check(content) -- 344
					if success then -- 345
						local info -- 346
						success, info = luaCheckWithLineInfo(file, result) -- 346
						if #info > 0 then -- 347
							return { -- 348
								success = success, -- 348
								info = info -- 348
							} -- 348
						else -- 350
							return { -- 350
								success = success -- 350
							} -- 350
						end -- 347
					else -- 352
						local info -- 352
						do -- 352
							local _accum_0 = { } -- 352
							local _len_0 = 1 -- 352
							for _index_0 = 1, #result do -- 352
								local _des_0 = result[_index_0] -- 352
								local row, err = _des_0[1], _des_0[2] -- 352
								_accum_0[_len_0] = { -- 353
									"syntax", -- 353
									file, -- 353
									row, -- 353
									0, -- 353
									err -- 353
								} -- 353
								_len_0 = _len_0 + 1 -- 353
							end -- 352
							info = _accum_0 -- 352
						end -- 352
						return { -- 354
							success = false, -- 354
							info = info -- 354
						} -- 354
					end -- 345
				end -- 322
			end -- 320
		end -- 320
	end -- 320
	return { -- 319
		success = true -- 319
	} -- 319
end) -- 319
local updateInferedDesc -- 356
updateInferedDesc = function(infered) -- 356
	if not infered.key or infered.key == "" or infered.desc:match("^polymorphic function %(with types ") then -- 357
		return -- 357
	end -- 357
	local key, row = infered.key, infered.row -- 358
	local codes = Content:loadAsync(key) -- 359
	if codes then -- 359
		local comments = { } -- 360
		local line = 0 -- 361
		local skipping = false -- 362
		for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 363
			line = line + 1 -- 364
			if line >= row then -- 365
				break -- 365
			end -- 365
			if lineCode:match("^%s*%-%- @") then -- 366
				skipping = true -- 367
				goto _continue_0 -- 368
			end -- 366
			local result = lineCode:match("^%s*%-%- (.+)") -- 369
			if result then -- 369
				if not skipping then -- 370
					comments[#comments + 1] = result -- 370
				end -- 370
			elseif #comments > 0 then -- 371
				comments = { } -- 372
				skipping = false -- 373
			end -- 369
			::_continue_0:: -- 364
		end -- 363
		infered.doc = table.concat(comments, "\n") -- 374
	end -- 359
end -- 356
HttpServer:postSchedule("/infer", function(req) -- 376
	do -- 377
		local _type_0 = type(req) -- 377
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 377
		if _tab_0 then -- 377
			local lang -- 377
			do -- 377
				local _obj_0 = req.body -- 377
				local _type_1 = type(_obj_0) -- 377
				if "table" == _type_1 or "userdata" == _type_1 then -- 377
					lang = _obj_0.lang -- 377
				end -- 377
			end -- 377
			local file -- 377
			do -- 377
				local _obj_0 = req.body -- 377
				local _type_1 = type(_obj_0) -- 377
				if "table" == _type_1 or "userdata" == _type_1 then -- 377
					file = _obj_0.file -- 377
				end -- 377
			end -- 377
			local content -- 377
			do -- 377
				local _obj_0 = req.body -- 377
				local _type_1 = type(_obj_0) -- 377
				if "table" == _type_1 or "userdata" == _type_1 then -- 377
					content = _obj_0.content -- 377
				end -- 377
			end -- 377
			local line -- 377
			do -- 377
				local _obj_0 = req.body -- 377
				local _type_1 = type(_obj_0) -- 377
				if "table" == _type_1 or "userdata" == _type_1 then -- 377
					line = _obj_0.line -- 377
				end -- 377
			end -- 377
			local row -- 377
			do -- 377
				local _obj_0 = req.body -- 377
				local _type_1 = type(_obj_0) -- 377
				if "table" == _type_1 or "userdata" == _type_1 then -- 377
					row = _obj_0.row -- 377
				end -- 377
			end -- 377
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 377
				local searchPath = getSearchPath(file) -- 378
				if "tl" == lang or "lua" == lang then -- 379
					if CheckTIC80Code(content) then -- 380
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 381
					end -- 380
					local infered = teal.inferAsync(content, line, row, searchPath) -- 382
					if (infered ~= nil) then -- 383
						updateInferedDesc(infered) -- 384
						return { -- 385
							success = true, -- 385
							infered = infered -- 385
						} -- 385
					end -- 383
				elseif "yue" == lang then -- 386
					local luaCodes, targetLine, targetRow, lineMap = getCompiledYueLine(content, line, row, file, true) -- 387
					if not luaCodes then -- 388
						return { -- 388
							success = false -- 388
						} -- 388
					end -- 388
					local infered = teal.inferAsync(luaCodes, targetLine, targetRow, searchPath) -- 389
					if (infered ~= nil) then -- 390
						local col -- 391
						file, row, col = infered.file, infered.row, infered.col -- 391
						if file == "" and row > 0 and col > 0 then -- 392
							infered.row = lineMap[row] or 0 -- 393
							infered.col = 0 -- 394
						end -- 392
						updateInferedDesc(infered) -- 395
						return { -- 396
							success = true, -- 396
							infered = infered -- 396
						} -- 396
					end -- 390
				end -- 379
			end -- 377
		end -- 377
	end -- 377
	return { -- 376
		success = false -- 376
	} -- 376
end) -- 376
local _anon_func_2 = function(doc) -- 447
	local _accum_0 = { } -- 447
	local _len_0 = 1 -- 447
	local _list_0 = doc.params -- 447
	for _index_0 = 1, #_list_0 do -- 447
		local param = _list_0[_index_0] -- 447
		_accum_0[_len_0] = param.name -- 447
		_len_0 = _len_0 + 1 -- 447
	end -- 447
	return _accum_0 -- 447
end -- 447
local getParamDocs -- 398
getParamDocs = function(signatures) -- 398
	do -- 399
		local codes = Content:loadAsync(signatures[1].file) -- 399
		if codes then -- 399
			local comments = { } -- 400
			local params = { } -- 401
			local line = 0 -- 402
			local docs = { } -- 403
			local returnType = nil -- 404
			for lineCode in codes:gmatch("([^\r\n]*)\r?\n?") do -- 405
				line = line + 1 -- 406
				local needBreak = true -- 407
				for i, _des_0 in ipairs(signatures) do -- 408
					local row = _des_0.row -- 408
					if line >= row and not (docs[i] ~= nil) then -- 409
						if #comments > 0 or #params > 0 or returnType then -- 410
							docs[i] = { -- 412
								doc = table.concat(comments, "  \n"), -- 412
								returnType = returnType -- 413
							} -- 411
							if #params > 0 then -- 415
								docs[i].params = params -- 415
							end -- 415
						else -- 417
							docs[i] = false -- 417
						end -- 410
					end -- 409
					if not docs[i] then -- 418
						needBreak = false -- 418
					end -- 418
				end -- 408
				if needBreak then -- 419
					break -- 419
				end -- 419
				local result = lineCode:match("%s*%-%- (.+)") -- 420
				if result then -- 420
					local name, typ, desc = result:match("^@param%s*([%w_]+)%s*%(([^%)]-)%)%s*(.+)") -- 421
					if not name then -- 422
						name, typ, desc = result:match("^@param%s*(%.%.%.)%s*%(([^%)]-)%)%s*(.+)") -- 423
					end -- 422
					if name then -- 424
						local pname = name -- 425
						if desc:match("%[optional%]") or desc:match("%[可选%]") then -- 426
							pname = pname .. "?" -- 426
						end -- 426
						params[#params + 1] = { -- 428
							name = tostring(pname) .. ": " .. tostring(typ), -- 428
							desc = "**" .. tostring(name) .. "**: " .. tostring(desc) -- 429
						} -- 427
					else -- 432
						typ = result:match("^@return%s*%(([^%)]-)%)") -- 432
						if typ then -- 432
							if returnType then -- 433
								returnType = returnType .. ", " .. typ -- 434
							else -- 436
								returnType = typ -- 436
							end -- 433
							result = result:gsub("@return", "**return:**") -- 437
						end -- 432
						comments[#comments + 1] = result -- 438
					end -- 424
				elseif #comments > 0 then -- 439
					comments = { } -- 440
					params = { } -- 441
					returnType = nil -- 442
				end -- 420
			end -- 405
			local results = { } -- 443
			for _index_0 = 1, #docs do -- 444
				local doc = docs[_index_0] -- 444
				if not doc then -- 445
					goto _continue_0 -- 445
				end -- 445
				if doc.params then -- 446
					doc.desc = "function(" .. tostring(table.concat(_anon_func_2(doc), ', ')) .. ")" -- 447
				else -- 449
					doc.desc = "function()" -- 449
				end -- 446
				if doc.returnType then -- 450
					doc.desc = doc.desc .. ": " .. tostring(doc.returnType) -- 451
					doc.returnType = nil -- 452
				end -- 450
				results[#results + 1] = doc -- 453
				::_continue_0:: -- 445
			end -- 444
			if #results > 0 then -- 454
				return results -- 454
			else -- 454
				return nil -- 454
			end -- 454
		end -- 399
	end -- 399
	return nil -- 398
end -- 398
HttpServer:postSchedule("/signature", function(req) -- 456
	do -- 457
		local _type_0 = type(req) -- 457
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 457
		if _tab_0 then -- 457
			local lang -- 457
			do -- 457
				local _obj_0 = req.body -- 457
				local _type_1 = type(_obj_0) -- 457
				if "table" == _type_1 or "userdata" == _type_1 then -- 457
					lang = _obj_0.lang -- 457
				end -- 457
			end -- 457
			local file -- 457
			do -- 457
				local _obj_0 = req.body -- 457
				local _type_1 = type(_obj_0) -- 457
				if "table" == _type_1 or "userdata" == _type_1 then -- 457
					file = _obj_0.file -- 457
				end -- 457
			end -- 457
			local content -- 457
			do -- 457
				local _obj_0 = req.body -- 457
				local _type_1 = type(_obj_0) -- 457
				if "table" == _type_1 or "userdata" == _type_1 then -- 457
					content = _obj_0.content -- 457
				end -- 457
			end -- 457
			local line -- 457
			do -- 457
				local _obj_0 = req.body -- 457
				local _type_1 = type(_obj_0) -- 457
				if "table" == _type_1 or "userdata" == _type_1 then -- 457
					line = _obj_0.line -- 457
				end -- 457
			end -- 457
			local row -- 457
			do -- 457
				local _obj_0 = req.body -- 457
				local _type_1 = type(_obj_0) -- 457
				if "table" == _type_1 or "userdata" == _type_1 then -- 457
					row = _obj_0.row -- 457
				end -- 457
			end -- 457
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 457
				local searchPath = getSearchPath(file) -- 458
				if "tl" == lang or "lua" == lang then -- 459
					if CheckTIC80Code(content) then -- 460
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 461
					end -- 460
					local signatures = teal.getSignatureAsync(content, line, row, searchPath) -- 462
					if signatures then -- 462
						signatures = getParamDocs(signatures) -- 463
						if signatures then -- 463
							return { -- 464
								success = true, -- 464
								signatures = signatures -- 464
							} -- 464
						end -- 463
					end -- 462
				elseif "yue" == lang then -- 465
					local luaCodes, targetLine, targetRow, _lineMap = getCompiledYueLine(content, line, row, file, true) -- 466
					if not luaCodes then -- 467
						return { -- 467
							success = false -- 467
						} -- 467
					end -- 467
					do -- 468
						local chainOp, chainCall = line:match("[^%w_]([%.\\])([^%.\\]+)$") -- 468
						if chainOp then -- 468
							local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 469
							if withVar then -- 469
								targetLine = withVar .. (chainOp == '\\' and ':' or '.') .. chainCall -- 470
							end -- 469
						end -- 468
					end -- 468
					local signatures = teal.getSignatureAsync(luaCodes, targetLine, targetRow, searchPath) -- 471
					if signatures then -- 471
						signatures = getParamDocs(signatures) -- 472
						if signatures then -- 472
							return { -- 473
								success = true, -- 473
								signatures = signatures -- 473
							} -- 473
						end -- 472
					else -- 474
						signatures = teal.getSignatureAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 474
						if signatures then -- 474
							signatures = getParamDocs(signatures) -- 475
							if signatures then -- 475
								return { -- 476
									success = true, -- 476
									signatures = signatures -- 476
								} -- 476
							end -- 475
						end -- 474
					end -- 471
				end -- 459
			end -- 457
		end -- 457
	end -- 457
	return { -- 456
		success = false -- 456
	} -- 456
end) -- 456
local luaKeywords = { -- 479
	'and', -- 479
	'break', -- 480
	'do', -- 481
	'else', -- 482
	'elseif', -- 483
	'end', -- 484
	'false', -- 485
	'for', -- 486
	'function', -- 487
	'goto', -- 488
	'if', -- 489
	'in', -- 490
	'local', -- 491
	'nil', -- 492
	'not', -- 493
	'or', -- 494
	'repeat', -- 495
	'return', -- 496
	'then', -- 497
	'true', -- 498
	'until', -- 499
	'while' -- 500
} -- 478
local tealKeywords = { -- 504
	'record', -- 504
	'as', -- 505
	'is', -- 506
	'type', -- 507
	'embed', -- 508
	'enum', -- 509
	'global', -- 510
	'any', -- 511
	'boolean', -- 512
	'integer', -- 513
	'number', -- 514
	'string', -- 515
	'thread' -- 516
} -- 503
local yueKeywords = { -- 520
	"and", -- 520
	"break", -- 521
	"do", -- 522
	"else", -- 523
	"elseif", -- 524
	"false", -- 525
	"for", -- 526
	"goto", -- 527
	"if", -- 528
	"in", -- 529
	"local", -- 530
	"nil", -- 531
	"not", -- 532
	"or", -- 533
	"repeat", -- 534
	"return", -- 535
	"then", -- 536
	"true", -- 537
	"until", -- 538
	"while", -- 539
	"as", -- 540
	"class", -- 541
	"continue", -- 542
	"export", -- 543
	"extends", -- 544
	"from", -- 545
	"global", -- 546
	"import", -- 547
	"macro", -- 548
	"switch", -- 549
	"try", -- 550
	"unless", -- 551
	"using", -- 552
	"when", -- 553
	"with" -- 554
} -- 519
local _anon_func_3 = function(f) -- 590
	local _val_0 = Path:getExt(f) -- 590
	return "ttf" == _val_0 or "otf" == _val_0 -- 590
end -- 590
local _anon_func_4 = function(suggestions) -- 616
	local _tbl_0 = { } -- 616
	for _index_0 = 1, #suggestions do -- 616
		local item = suggestions[_index_0] -- 616
		_tbl_0[item[1] .. item[2]] = item -- 616
	end -- 616
	return _tbl_0 -- 616
end -- 616
HttpServer:postSchedule("/complete", function(req) -- 557
	do -- 558
		local _type_0 = type(req) -- 558
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 558
		if _tab_0 then -- 558
			local lang -- 558
			do -- 558
				local _obj_0 = req.body -- 558
				local _type_1 = type(_obj_0) -- 558
				if "table" == _type_1 or "userdata" == _type_1 then -- 558
					lang = _obj_0.lang -- 558
				end -- 558
			end -- 558
			local file -- 558
			do -- 558
				local _obj_0 = req.body -- 558
				local _type_1 = type(_obj_0) -- 558
				if "table" == _type_1 or "userdata" == _type_1 then -- 558
					file = _obj_0.file -- 558
				end -- 558
			end -- 558
			local content -- 558
			do -- 558
				local _obj_0 = req.body -- 558
				local _type_1 = type(_obj_0) -- 558
				if "table" == _type_1 or "userdata" == _type_1 then -- 558
					content = _obj_0.content -- 558
				end -- 558
			end -- 558
			local line -- 558
			do -- 558
				local _obj_0 = req.body -- 558
				local _type_1 = type(_obj_0) -- 558
				if "table" == _type_1 or "userdata" == _type_1 then -- 558
					line = _obj_0.line -- 558
				end -- 558
			end -- 558
			local row -- 558
			do -- 558
				local _obj_0 = req.body -- 558
				local _type_1 = type(_obj_0) -- 558
				if "table" == _type_1 or "userdata" == _type_1 then -- 558
					row = _obj_0.row -- 558
				end -- 558
			end -- 558
			if lang ~= nil and file ~= nil and content ~= nil and line ~= nil and row ~= nil then -- 558
				local searchPath = getSearchPath(file) -- 559
				repeat -- 560
					local item = line:match("require%s*%(%s*['\"]([%w%d-_%./ ]*)$") -- 561
					if lang == "yue" then -- 562
						if not item then -- 563
							item = line:match("require%s*['\"]([%w%d-_%./ ]*)$") -- 563
						end -- 563
						if not item then -- 564
							item = line:match("import%s*['\"]([%w%d-_%.]*)$") -- 564
						end -- 564
					end -- 562
					local searchType = nil -- 565
					if not item then -- 566
						item = line:match("Sprite%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 567
						if lang == "yue" then -- 568
							item = line:match("Sprite%s*['\"]([%w%d-_/ ]*)$") -- 569
						end -- 568
						if (item ~= nil) then -- 570
							searchType = "Image" -- 570
						end -- 570
					end -- 566
					if not item then -- 571
						item = line:match("Label%s*%(%s*['\"]([%w%d-_/ ]*)$") -- 572
						if lang == "yue" then -- 573
							item = line:match("Label%s*['\"]([%w%d-_/ ]*)$") -- 574
						end -- 573
						if (item ~= nil) then -- 575
							searchType = "Font" -- 575
						end -- 575
					end -- 571
					if not item then -- 576
						break -- 576
					end -- 576
					local searchPaths = Content.searchPaths -- 577
					local _list_0 = getSearchFolders(file) -- 578
					for _index_0 = 1, #_list_0 do -- 578
						local folder = _list_0[_index_0] -- 578
						searchPaths[#searchPaths + 1] = folder -- 579
					end -- 578
					if searchType then -- 580
						searchPaths[#searchPaths + 1] = Content.assetPath -- 580
					end -- 580
					local tokens -- 581
					do -- 581
						local _accum_0 = { } -- 581
						local _len_0 = 1 -- 581
						for mod in item:gmatch("([%w%d-_ ]+)[%./]") do -- 581
							_accum_0[_len_0] = mod -- 581
							_len_0 = _len_0 + 1 -- 581
						end -- 581
						tokens = _accum_0 -- 581
					end -- 581
					local suggestions = { } -- 582
					for _index_0 = 1, #searchPaths do -- 583
						local path = searchPaths[_index_0] -- 583
						local sPath = Path(path, table.unpack(tokens)) -- 584
						if not Content:exist(sPath) then -- 585
							goto _continue_0 -- 585
						end -- 585
						if searchType == "Font" then -- 586
							local fontPath = Path(sPath, "Font") -- 587
							if Content:exist(fontPath) then -- 588
								local _list_1 = Content:getFiles(fontPath) -- 589
								for _index_1 = 1, #_list_1 do -- 589
									local f = _list_1[_index_1] -- 589
									if _anon_func_3(f) then -- 590
										if "." == f:sub(1, 1) then -- 591
											goto _continue_1 -- 591
										end -- 591
										suggestions[#suggestions + 1] = { -- 592
											Path:getName(f), -- 592
											"font", -- 592
											"field" -- 592
										} -- 592
									end -- 590
									::_continue_1:: -- 590
								end -- 589
							end -- 588
						end -- 586
						local _list_1 = Content:getFiles(sPath) -- 593
						for _index_1 = 1, #_list_1 do -- 593
							local f = _list_1[_index_1] -- 593
							if "Image" == searchType then -- 594
								do -- 595
									local _exp_0 = Path:getExt(f) -- 595
									if "clip" == _exp_0 or "jpg" == _exp_0 or "png" == _exp_0 or "dds" == _exp_0 or "pvr" == _exp_0 or "ktx" == _exp_0 then -- 595
										if "." == f:sub(1, 1) then -- 596
											goto _continue_2 -- 596
										end -- 596
										suggestions[#suggestions + 1] = { -- 597
											f, -- 597
											"image", -- 597
											"field" -- 597
										} -- 597
									end -- 595
								end -- 595
								goto _continue_2 -- 598
							elseif "Font" == searchType then -- 599
								do -- 600
									local _exp_0 = Path:getExt(f) -- 600
									if "ttf" == _exp_0 or "otf" == _exp_0 then -- 600
										if "." == f:sub(1, 1) then -- 601
											goto _continue_2 -- 601
										end -- 601
										suggestions[#suggestions + 1] = { -- 602
											f, -- 602
											"font", -- 602
											"field" -- 602
										} -- 602
									end -- 600
								end -- 600
								goto _continue_2 -- 603
							end -- 594
							local _exp_0 = Path:getExt(f) -- 604
							if "lua" == _exp_0 or "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 604
								local name = Path:getName(f) -- 605
								if "d" == Path:getExt(name) then -- 606
									goto _continue_2 -- 606
								end -- 606
								if "." == name:sub(1, 1) then -- 607
									goto _continue_2 -- 607
								end -- 607
								suggestions[#suggestions + 1] = { -- 608
									name, -- 608
									"module", -- 608
									"field" -- 608
								} -- 608
							end -- 604
							::_continue_2:: -- 594
						end -- 593
						local _list_2 = Content:getDirs(sPath) -- 609
						for _index_1 = 1, #_list_2 do -- 609
							local dir = _list_2[_index_1] -- 609
							if "." == dir:sub(1, 1) then -- 610
								goto _continue_3 -- 610
							end -- 610
							suggestions[#suggestions + 1] = { -- 611
								dir, -- 611
								"folder", -- 611
								"variable" -- 611
							} -- 611
							::_continue_3:: -- 610
						end -- 609
						::_continue_0:: -- 584
					end -- 583
					if item == "" and not searchType then -- 612
						local _list_1 = teal.completeAsync("", "Dora.", 1, searchPath) -- 613
						for _index_0 = 1, #_list_1 do -- 613
							local _des_0 = _list_1[_index_0] -- 613
							local name = _des_0[1] -- 613
							suggestions[#suggestions + 1] = { -- 614
								name, -- 614
								"dora module", -- 614
								"function" -- 614
							} -- 614
						end -- 613
					end -- 612
					if #suggestions > 0 then -- 615
						do -- 616
							local _accum_0 = { } -- 616
							local _len_0 = 1 -- 616
							for _, v in pairs(_anon_func_4(suggestions)) do -- 616
								_accum_0[_len_0] = v -- 616
								_len_0 = _len_0 + 1 -- 616
							end -- 616
							suggestions = _accum_0 -- 616
						end -- 616
						return { -- 617
							success = true, -- 617
							suggestions = suggestions -- 617
						} -- 617
					else -- 619
						return { -- 619
							success = false -- 619
						} -- 619
					end -- 615
				until true -- 560
				if "tl" == lang or "lua" == lang then -- 621
					do -- 622
						local isTIC80 = CheckTIC80Code(content) -- 622
						if isTIC80 then -- 622
							content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 623
						end -- 622
					end -- 622
					local suggestions = teal.completeAsync(content, line, row, searchPath) -- 624
					if not line:match("[%.:]$") then -- 625
						local checkSet -- 626
						do -- 626
							local _tbl_0 = { } -- 626
							for _index_0 = 1, #suggestions do -- 626
								local _des_0 = suggestions[_index_0] -- 626
								local name = _des_0[1] -- 626
								_tbl_0[name] = true -- 626
							end -- 626
							checkSet = _tbl_0 -- 626
						end -- 626
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 627
						for _index_0 = 1, #_list_0 do -- 627
							local item = _list_0[_index_0] -- 627
							if not checkSet[item[1]] then -- 628
								suggestions[#suggestions + 1] = item -- 628
							end -- 628
						end -- 627
						for _index_0 = 1, #luaKeywords do -- 629
							local word = luaKeywords[_index_0] -- 629
							suggestions[#suggestions + 1] = { -- 630
								word, -- 630
								"keyword", -- 630
								"keyword" -- 630
							} -- 630
						end -- 629
						if lang == "tl" then -- 631
							for _index_0 = 1, #tealKeywords do -- 632
								local word = tealKeywords[_index_0] -- 632
								suggestions[#suggestions + 1] = { -- 633
									word, -- 633
									"keyword", -- 633
									"keyword" -- 633
								} -- 633
							end -- 632
						end -- 631
					end -- 625
					if #suggestions > 0 then -- 634
						return { -- 635
							success = true, -- 635
							suggestions = suggestions -- 635
						} -- 635
					end -- 634
				elseif "yue" == lang then -- 636
					local suggestions = { } -- 637
					local gotGlobals = false -- 638
					do -- 639
						local luaCodes, targetLine, targetRow = getCompiledYueLine(content, line, row, file, true) -- 639
						if luaCodes then -- 639
							gotGlobals = true -- 640
							do -- 641
								local chainOp = line:match("[^%w_]([%.\\])$") -- 641
								if chainOp then -- 641
									local withVar = luaCodes:match("([%w_]+)%.___DUMMY_CALL___%(%)") -- 642
									if not withVar then -- 643
										return { -- 643
											success = false -- 643
										} -- 643
									end -- 643
									targetLine = tostring(withVar) .. tostring(chainOp == '\\' and ':' or '.') -- 644
								elseif line:match("^([%.\\])$") then -- 645
									return { -- 646
										success = false -- 646
									} -- 646
								end -- 641
							end -- 641
							local _list_0 = teal.completeAsync(luaCodes, targetLine, targetRow, searchPath) -- 647
							for _index_0 = 1, #_list_0 do -- 647
								local item = _list_0[_index_0] -- 647
								suggestions[#suggestions + 1] = item -- 647
							end -- 647
							if #suggestions == 0 then -- 648
								local _list_1 = teal.completeAsync(luaCodes, "Dora." .. tostring(targetLine), targetRow, searchPath) -- 649
								for _index_0 = 1, #_list_1 do -- 649
									local item = _list_1[_index_0] -- 649
									suggestions[#suggestions + 1] = item -- 649
								end -- 649
							end -- 648
						end -- 639
					end -- 639
					if not line:match("[%.:\\][%w_]+[%.\\]?$") and not line:match("[%.\\]$") then -- 650
						local checkSet -- 651
						do -- 651
							local _tbl_0 = { } -- 651
							for _index_0 = 1, #suggestions do -- 651
								local _des_0 = suggestions[_index_0] -- 651
								local name = _des_0[1] -- 651
								_tbl_0[name] = true -- 651
							end -- 651
							checkSet = _tbl_0 -- 651
						end -- 651
						local _list_0 = teal.completeAsync("", "Dora.", 1, searchPath) -- 652
						for _index_0 = 1, #_list_0 do -- 652
							local item = _list_0[_index_0] -- 652
							if not checkSet[item[1]] then -- 653
								suggestions[#suggestions + 1] = item -- 653
							end -- 653
						end -- 652
						if not gotGlobals then -- 654
							local _list_1 = teal.completeAsync("", "x", 1, searchPath) -- 655
							for _index_0 = 1, #_list_1 do -- 655
								local item = _list_1[_index_0] -- 655
								if not checkSet[item[1]] then -- 656
									suggestions[#suggestions + 1] = item -- 656
								end -- 656
							end -- 655
						end -- 654
						for _index_0 = 1, #yueKeywords do -- 657
							local word = yueKeywords[_index_0] -- 657
							if not checkSet[word] then -- 658
								suggestions[#suggestions + 1] = { -- 659
									word, -- 659
									"keyword", -- 659
									"keyword" -- 659
								} -- 659
							end -- 658
						end -- 657
					end -- 650
					if #suggestions > 0 then -- 660
						return { -- 661
							success = true, -- 661
							suggestions = suggestions -- 661
						} -- 661
					end -- 660
				elseif "xml" == lang then -- 662
					local items = xml.complete(content) -- 663
					if #items > 0 then -- 664
						local suggestions -- 665
						do -- 665
							local _accum_0 = { } -- 665
							local _len_0 = 1 -- 665
							for _index_0 = 1, #items do -- 665
								local _des_0 = items[_index_0] -- 665
								local label, insertText = _des_0[1], _des_0[2] -- 665
								_accum_0[_len_0] = { -- 666
									label, -- 666
									insertText, -- 666
									"field" -- 666
								} -- 666
								_len_0 = _len_0 + 1 -- 666
							end -- 665
							suggestions = _accum_0 -- 665
						end -- 665
						return { -- 667
							success = true, -- 667
							suggestions = suggestions -- 667
						} -- 667
					end -- 664
				end -- 621
			end -- 558
		end -- 558
	end -- 558
	return { -- 557
		success = false -- 557
	} -- 557
end) -- 557
HttpServer:upload("/upload", function(req, filename) -- 671
	do -- 672
		local _type_0 = type(req) -- 672
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 672
		if _tab_0 then -- 672
			local path -- 672
			do -- 672
				local _obj_0 = req.params -- 672
				local _type_1 = type(_obj_0) -- 672
				if "table" == _type_1 or "userdata" == _type_1 then -- 672
					path = _obj_0.path -- 672
				end -- 672
			end -- 672
			if path ~= nil then -- 672
				local uploadPath = Path(Content.writablePath, ".upload") -- 673
				if not Content:exist(uploadPath) then -- 674
					Content:mkdir(uploadPath) -- 675
				end -- 674
				local targetPath = Path(uploadPath, filename) -- 676
				Content:mkdir(Path:getPath(targetPath)) -- 677
				return targetPath -- 678
			end -- 672
		end -- 672
	end -- 672
	return nil -- 671
end, function(req, file) -- 679
	do -- 680
		local _type_0 = type(req) -- 680
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 680
		if _tab_0 then -- 680
			local path -- 680
			do -- 680
				local _obj_0 = req.params -- 680
				local _type_1 = type(_obj_0) -- 680
				if "table" == _type_1 or "userdata" == _type_1 then -- 680
					path = _obj_0.path -- 680
				end -- 680
			end -- 680
			if path ~= nil then -- 680
				path = Path(Content.writablePath, path) -- 681
				if Content:exist(path) then -- 682
					local uploadPath = Path(Content.writablePath, ".upload") -- 683
					local targetPath = Path(path, Path:getRelative(file, uploadPath)) -- 684
					Content:mkdir(Path:getPath(targetPath)) -- 685
					if Content:move(file, targetPath) then -- 686
						return true -- 687
					end -- 686
				end -- 682
			end -- 680
		end -- 680
	end -- 680
	return false -- 679
end) -- 669
HttpServer:post("/list", function(req) -- 690
	do -- 691
		local _type_0 = type(req) -- 691
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 691
		if _tab_0 then -- 691
			local path -- 691
			do -- 691
				local _obj_0 = req.body -- 691
				local _type_1 = type(_obj_0) -- 691
				if "table" == _type_1 or "userdata" == _type_1 then -- 691
					path = _obj_0.path -- 691
				end -- 691
			end -- 691
			if path ~= nil then -- 691
				if Content:exist(path) then -- 692
					local files = { } -- 693
					local visitAssets -- 694
					visitAssets = function(path, folder) -- 694
						local dirs = Content:getDirs(path) -- 695
						for _index_0 = 1, #dirs do -- 696
							local dir = dirs[_index_0] -- 696
							if dir:match("^%.") then -- 697
								goto _continue_0 -- 697
							end -- 697
							local current -- 698
							if folder == "" then -- 698
								current = dir -- 699
							else -- 701
								current = Path(folder, dir) -- 701
							end -- 698
							files[#files + 1] = current -- 702
							visitAssets(Path(path, dir), current) -- 703
							::_continue_0:: -- 697
						end -- 696
						local fs = Content:getFiles(path) -- 704
						for _index_0 = 1, #fs do -- 705
							local f = fs[_index_0] -- 705
							if f:match("^%.") then -- 706
								goto _continue_1 -- 706
							end -- 706
							if folder == "" then -- 707
								files[#files + 1] = f -- 708
							else -- 710
								files[#files + 1] = Path(folder, f) -- 710
							end -- 707
							::_continue_1:: -- 706
						end -- 705
					end -- 694
					visitAssets(path, "") -- 711
					if #files == 0 then -- 712
						files = nil -- 712
					end -- 712
					return { -- 713
						success = true, -- 713
						files = files -- 713
					} -- 713
				end -- 692
			end -- 691
		end -- 691
	end -- 691
	return { -- 690
		success = false -- 690
	} -- 690
end) -- 690
HttpServer:post("/info", function() -- 715
	local Entry = require("Script.Dev.Entry") -- 716
	local webProfiler, drawerWidth -- 717
	do -- 717
		local _obj_0 = Entry.getConfig() -- 717
		webProfiler, drawerWidth = _obj_0.webProfiler, _obj_0.drawerWidth -- 717
	end -- 717
	local engineDev = Entry.getEngineDev() -- 718
	Entry.connectWebIDE() -- 719
	return { -- 721
		platform = App.platform, -- 721
		locale = App.locale, -- 722
		version = App.version, -- 723
		engineDev = engineDev, -- 724
		webProfiler = webProfiler, -- 725
		drawerWidth = drawerWidth -- 726
	} -- 720
end) -- 715
local ensureLLMConfigTable -- 728
ensureLLMConfigTable = function() -- 728
	local columns = DB:query("PRAGMA table_info(LLMConfig)") -- 729
	if columns and #columns > 0 then -- 730
		local expected = { -- 732
			id = true, -- 732
			name = true, -- 733
			url = true, -- 734
			model = true, -- 735
			api_key = true, -- 736
			context_window = true, -- 737
			supports_function_calling = true, -- 738
			active = true, -- 739
			created_at = true, -- 740
			updated_at = true -- 741
		} -- 731
		local valid = #columns == 10 -- 743
		if valid then -- 744
			for _index_0 = 1, #columns do -- 745
				local row = columns[_index_0] -- 745
				local columnName = tostring(row[2]) -- 746
				if not expected[columnName] then -- 747
					valid = false -- 748
					break -- 749
				end -- 747
			end -- 745
		end -- 744
		if not valid then -- 750
			DB:exec("DROP TABLE IF EXISTS LLMConfig") -- 751
		end -- 750
	end -- 730
	return DB:exec([[		CREATE TABLE IF NOT EXISTS LLMConfig(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			name TEXT NOT NULL,
			url TEXT NOT NULL,
			model TEXT NOT NULL,
			api_key TEXT NOT NULL,
			context_window INTEGER NOT NULL DEFAULT 64000,
			supports_function_calling INTEGER NOT NULL DEFAULT 1,
			active INTEGER NOT NULL DEFAULT 1,
			created_at INTEGER,
			updated_at INTEGER
		);
	]]) -- 752
end -- 728
local normalizeContextWindow -- 767
normalizeContextWindow = function(value) -- 767
	local contextWindow = tonumber(value) -- 768
	if contextWindow == nil or contextWindow < 4000 then -- 769
		return 64000 -- 770
	end -- 769
	return math.max(4000, math.floor(contextWindow)) -- 771
end -- 767
HttpServer:post("/llm/list", function() -- 773
	ensureLLMConfigTable() -- 774
	local rows = DB:query("\n		select id, name, url, model, api_key, context_window, supports_function_calling, active\n		from LLMConfig\n		order by id asc") -- 775
	local items -- 779
	if rows and #rows > 0 then -- 779
		local _accum_0 = { } -- 780
		local _len_0 = 1 -- 780
		for _index_0 = 1, #rows do -- 780
			local _des_0 = rows[_index_0] -- 780
			local id, name, url, model, key, contextWindow, supportsFunctionCalling, active = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5], _des_0[6], _des_0[7], _des_0[8] -- 780
			_accum_0[_len_0] = { -- 781
				id = id, -- 781
				name = name, -- 781
				url = url, -- 781
				model = model, -- 781
				key = key, -- 781
				contextWindow = normalizeContextWindow(contextWindow), -- 781
				supportsFunctionCalling = supportsFunctionCalling ~= 0, -- 781
				active = active ~= 0 -- 781
			} -- 781
			_len_0 = _len_0 + 1 -- 781
		end -- 780
		items = _accum_0 -- 779
	end -- 779
	return { -- 782
		success = true, -- 782
		items = items -- 782
	} -- 782
end) -- 773
HttpServer:post("/llm/create", function(req) -- 784
	ensureLLMConfigTable() -- 785
	do -- 786
		local _type_0 = type(req) -- 786
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 786
		if _tab_0 then -- 786
			local body = req.body -- 786
			if body ~= nil then -- 786
				local name, url, model, key, active, contextWindow, supportsFunctionCalling = body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.supportsFunctionCalling -- 787
				local now = os.time() -- 788
				if name == nil or url == nil or model == nil or key == nil then -- 789
					return { -- 790
						success = false, -- 790
						message = "invalid" -- 790
					} -- 790
				end -- 789
				contextWindow = normalizeContextWindow(contextWindow) -- 791
				if supportsFunctionCalling == false then -- 792
					supportsFunctionCalling = 0 -- 792
				else -- 792
					supportsFunctionCalling = 1 -- 792
				end -- 792
				if active then -- 793
					active = 1 -- 793
				else -- 793
					active = 0 -- 793
				end -- 793
				local affected = DB:exec("\n			insert into LLMConfig (\n				name, url, model, api_key, context_window, supports_function_calling, active, created_at, updated_at\n			) values (\n				?, ?, ?, ?, ?, ?, ?, ?, ?\n			)", { -- 800
					tostring(name), -- 800
					tostring(url), -- 801
					tostring(model), -- 802
					tostring(key), -- 803
					contextWindow, -- 804
					supportsFunctionCalling, -- 805
					active, -- 806
					now, -- 807
					now -- 808
				}) -- 794
				return { -- 810
					success = affected >= 0 -- 810
				} -- 810
			end -- 786
		end -- 786
	end -- 786
	return { -- 784
		success = false, -- 784
		message = "invalid" -- 784
	} -- 784
end) -- 784
HttpServer:post("/llm/update", function(req) -- 812
	ensureLLMConfigTable() -- 813
	do -- 814
		local _type_0 = type(req) -- 814
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 814
		if _tab_0 then -- 814
			local body = req.body -- 814
			if body ~= nil then -- 814
				local id, name, url, model, key, active, contextWindow, supportsFunctionCalling = body.id, body.name, body.url, body.model, body.key, body.active, body.contextWindow, body.supportsFunctionCalling -- 815
				local now = os.time() -- 816
				id = tonumber(id) -- 817
				if id == nil then -- 818
					return { -- 819
						success = false, -- 819
						message = "invalid" -- 819
					} -- 819
				end -- 818
				contextWindow = normalizeContextWindow(contextWindow) -- 820
				if supportsFunctionCalling == false then -- 821
					supportsFunctionCalling = 0 -- 821
				else -- 821
					supportsFunctionCalling = 1 -- 821
				end -- 821
				if active then -- 822
					active = 1 -- 822
				else -- 822
					active = 0 -- 822
				end -- 822
				local affected = DB:exec("\n			update LLMConfig\n			set name = ?, url = ?, model = ?, api_key = ?, context_window = ?, supports_function_calling = ?, active = ?, updated_at = ?\n			where id = ?", { -- 827
					tostring(name), -- 827
					tostring(url), -- 828
					tostring(model), -- 829
					tostring(key), -- 830
					contextWindow, -- 831
					supportsFunctionCalling, -- 832
					active, -- 833
					now, -- 834
					id -- 835
				}) -- 823
				return { -- 837
					success = affected >= 0 -- 837
				} -- 837
			end -- 814
		end -- 814
	end -- 814
	return { -- 812
		success = false, -- 812
		message = "invalid" -- 812
	} -- 812
end) -- 812
HttpServer:post("/llm/delete", function(req) -- 839
	ensureLLMConfigTable() -- 840
	do -- 841
		local _type_0 = type(req) -- 841
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 841
		if _tab_0 then -- 841
			local id -- 841
			do -- 841
				local _obj_0 = req.body -- 841
				local _type_1 = type(_obj_0) -- 841
				if "table" == _type_1 or "userdata" == _type_1 then -- 841
					id = _obj_0.id -- 841
				end -- 841
			end -- 841
			if id ~= nil then -- 841
				id = tonumber(id) -- 842
				if id == nil then -- 843
					return { -- 844
						success = false, -- 844
						message = "invalid" -- 844
					} -- 844
				end -- 843
				local affected = DB:exec("delete from LLMConfig where id = ?", { -- 845
					id -- 845
				}) -- 845
				return { -- 846
					success = affected >= 0 -- 846
				} -- 846
			end -- 841
		end -- 841
	end -- 841
	return { -- 839
		success = false, -- 839
		message = "invalid" -- 839
	} -- 839
end) -- 839
HttpServer:post("/new", function(req) -- 848
	do -- 849
		local _type_0 = type(req) -- 849
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 849
		if _tab_0 then -- 849
			local path -- 849
			do -- 849
				local _obj_0 = req.body -- 849
				local _type_1 = type(_obj_0) -- 849
				if "table" == _type_1 or "userdata" == _type_1 then -- 849
					path = _obj_0.path -- 849
				end -- 849
			end -- 849
			local content -- 849
			do -- 849
				local _obj_0 = req.body -- 849
				local _type_1 = type(_obj_0) -- 849
				if "table" == _type_1 or "userdata" == _type_1 then -- 849
					content = _obj_0.content -- 849
				end -- 849
			end -- 849
			local folder -- 849
			do -- 849
				local _obj_0 = req.body -- 849
				local _type_1 = type(_obj_0) -- 849
				if "table" == _type_1 or "userdata" == _type_1 then -- 849
					folder = _obj_0.folder -- 849
				end -- 849
			end -- 849
			if path ~= nil and content ~= nil and folder ~= nil then -- 849
				if Content:exist(path) then -- 850
					return { -- 851
						success = false, -- 851
						message = "TargetExisted" -- 851
					} -- 851
				end -- 850
				local parent = Path:getPath(path) -- 852
				local files = Content:getFiles(parent) -- 853
				if folder then -- 854
					local name = Path:getFilename(path):lower() -- 855
					for _index_0 = 1, #files do -- 856
						local file = files[_index_0] -- 856
						if name == Path:getFilename(file):lower() then -- 857
							return { -- 858
								success = false, -- 858
								message = "TargetExisted" -- 858
							} -- 858
						end -- 857
					end -- 856
					if Content:mkdir(path) then -- 859
						return { -- 860
							success = true -- 860
						} -- 860
					end -- 859
				else -- 862
					local name = Path:getName(path):lower() -- 862
					for _index_0 = 1, #files do -- 863
						local file = files[_index_0] -- 863
						if name == Path:getName(file):lower() then -- 864
							local ext = Path:getExt(file) -- 865
							if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 866
								goto _continue_0 -- 867
							elseif ("d" == Path:getExt(name)) and (ext ~= Path:getExt(path)) then -- 868
								goto _continue_0 -- 869
							end -- 866
							return { -- 870
								success = false, -- 870
								message = "SourceExisted" -- 870
							} -- 870
						end -- 864
						::_continue_0:: -- 864
					end -- 863
					if Content:save(path, content) then -- 871
						return { -- 872
							success = true -- 872
						} -- 872
					end -- 871
				end -- 854
			end -- 849
		end -- 849
	end -- 849
	return { -- 848
		success = false, -- 848
		message = "Failed" -- 848
	} -- 848
end) -- 848
HttpServer:post("/delete", function(req) -- 874
	do -- 875
		local _type_0 = type(req) -- 875
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 875
		if _tab_0 then -- 875
			local path -- 875
			do -- 875
				local _obj_0 = req.body -- 875
				local _type_1 = type(_obj_0) -- 875
				if "table" == _type_1 or "userdata" == _type_1 then -- 875
					path = _obj_0.path -- 875
				end -- 875
			end -- 875
			if path ~= nil then -- 875
				if Content:exist(path) then -- 876
					local projectRoot -- 877
					if Content:isdir(path) and isProjectRootDir(path) then -- 877
						projectRoot = path -- 877
					else -- 877
						projectRoot = nil -- 877
					end -- 877
					local parent = Path:getPath(path) -- 878
					local files = Content:getFiles(parent) -- 879
					local name = Path:getName(path):lower() -- 880
					local ext = Path:getExt(path) -- 881
					for _index_0 = 1, #files do -- 882
						local file = files[_index_0] -- 882
						if name == Path:getName(file):lower() then -- 883
							local _exp_0 = Path:getExt(file) -- 884
							if "tl" == _exp_0 then -- 884
								if ("vs" == ext) then -- 884
									Content:remove(Path(parent, file)) -- 885
								end -- 884
							elseif "lua" == _exp_0 then -- 886
								if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 886
									Content:remove(Path(parent, file)) -- 887
								end -- 886
							end -- 884
						end -- 883
					end -- 882
					if Content:remove(path) then -- 888
						if projectRoot then -- 889
							AgentSession.deleteSessionsByProjectRoot(projectRoot) -- 890
						end -- 889
						return { -- 891
							success = true -- 891
						} -- 891
					end -- 888
				end -- 876
			end -- 875
		end -- 875
	end -- 875
	return { -- 874
		success = false -- 874
	} -- 874
end) -- 874
HttpServer:post("/rename", function(req) -- 893
	do -- 894
		local _type_0 = type(req) -- 894
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 894
		if _tab_0 then -- 894
			local old -- 894
			do -- 894
				local _obj_0 = req.body -- 894
				local _type_1 = type(_obj_0) -- 894
				if "table" == _type_1 or "userdata" == _type_1 then -- 894
					old = _obj_0.old -- 894
				end -- 894
			end -- 894
			local new -- 894
			do -- 894
				local _obj_0 = req.body -- 894
				local _type_1 = type(_obj_0) -- 894
				if "table" == _type_1 or "userdata" == _type_1 then -- 894
					new = _obj_0.new -- 894
				end -- 894
			end -- 894
			if old ~= nil and new ~= nil then -- 894
				if Content:exist(old) and not Content:exist(new) then -- 895
					local renamedDir = Content:isdir(old) -- 896
					local parent = Path:getPath(new) -- 897
					local files = Content:getFiles(parent) -- 898
					if renamedDir then -- 899
						local name = Path:getFilename(new):lower() -- 900
						for _index_0 = 1, #files do -- 901
							local file = files[_index_0] -- 901
							if name == Path:getFilename(file):lower() then -- 902
								return { -- 903
									success = false -- 903
								} -- 903
							end -- 902
						end -- 901
					else -- 905
						local name = Path:getName(new):lower() -- 905
						local ext = Path:getExt(new) -- 906
						for _index_0 = 1, #files do -- 907
							local file = files[_index_0] -- 907
							if name == Path:getName(file):lower() then -- 908
								if not ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext or "lua" == ext) then -- 909
									goto _continue_0 -- 910
								elseif ("d" == Path:getExt(name)) and (Path:getExt(file) ~= ext) then -- 911
									goto _continue_0 -- 912
								end -- 909
								return { -- 913
									success = false -- 913
								} -- 913
							end -- 908
							::_continue_0:: -- 908
						end -- 907
					end -- 899
					if Content:move(old, new) then -- 914
						if renamedDir then -- 915
							AgentSession.renameSessionsByProjectRoot(old, new) -- 916
						end -- 915
						local newParent = Path:getPath(new) -- 917
						parent = Path:getPath(old) -- 918
						files = Content:getFiles(parent) -- 919
						local newName = Path:getName(new) -- 920
						local oldName = Path:getName(old) -- 921
						local name = oldName:lower() -- 922
						local ext = Path:getExt(old) -- 923
						for _index_0 = 1, #files do -- 924
							local file = files[_index_0] -- 924
							if name == Path:getName(file):lower() then -- 925
								local _exp_0 = Path:getExt(file) -- 926
								if "tl" == _exp_0 then -- 926
									if ("vs" == ext) then -- 926
										Content:move(Path(parent, file), Path(newParent, newName .. ".tl")) -- 927
									end -- 926
								elseif "lua" == _exp_0 then -- 928
									if ("tl" == ext or "yue" == ext or "ts" == ext or "tsx" == ext or "vs" == ext or "bl" == ext or "xml" == ext) then -- 928
										Content:move(Path(parent, file), Path(newParent, newName .. ".lua")) -- 929
									end -- 928
								end -- 926
							end -- 925
						end -- 924
						return { -- 930
							success = true -- 930
						} -- 930
					end -- 914
				end -- 895
			end -- 894
		end -- 894
	end -- 894
	return { -- 893
		success = false -- 893
	} -- 893
end) -- 893
HttpServer:post("/exist", function(req) -- 932
	do -- 933
		local _type_0 = type(req) -- 933
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 933
		if _tab_0 then -- 933
			local file -- 933
			do -- 933
				local _obj_0 = req.body -- 933
				local _type_1 = type(_obj_0) -- 933
				if "table" == _type_1 or "userdata" == _type_1 then -- 933
					file = _obj_0.file -- 933
				end -- 933
			end -- 933
			if file ~= nil then -- 933
				do -- 934
					local projFile = req.body.projFile -- 934
					if projFile then -- 934
						local projDir = getProjectDirFromFile(projFile) -- 935
						if projDir then -- 935
							local scriptDir = Path(projDir, "Script") -- 936
							local searchPaths = Content.searchPaths -- 937
							if Content:exist(scriptDir) then -- 938
								Content:addSearchPath(scriptDir) -- 938
							end -- 938
							if Content:exist(projDir) then -- 939
								Content:addSearchPath(projDir) -- 939
							end -- 939
							local _ <close> = setmetatable({ }, { -- 940
								__close = function() -- 940
									Content.searchPaths = searchPaths -- 940
								end -- 940
							}) -- 940
							return { -- 941
								success = Content:exist(file) -- 941
							} -- 941
						end -- 935
					end -- 934
				end -- 934
				return { -- 942
					success = Content:exist(file) -- 942
				} -- 942
			end -- 933
		end -- 933
	end -- 933
	return { -- 932
		success = false -- 932
	} -- 932
end) -- 932
HttpServer:postSchedule("/read", function(req) -- 944
	do -- 945
		local _type_0 = type(req) -- 945
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 945
		if _tab_0 then -- 945
			local path -- 945
			do -- 945
				local _obj_0 = req.body -- 945
				local _type_1 = type(_obj_0) -- 945
				if "table" == _type_1 or "userdata" == _type_1 then -- 945
					path = _obj_0.path -- 945
				end -- 945
			end -- 945
			if path ~= nil then -- 945
				local readFile -- 946
				readFile = function() -- 946
					if Content:exist(path) then -- 947
						local content = Content:loadAsync(path) -- 948
						if content then -- 948
							return { -- 949
								content = content, -- 949
								success = true -- 949
							} -- 949
						end -- 948
					end -- 947
					return nil -- 946
				end -- 946
				do -- 950
					local projFile = req.body.projFile -- 950
					if projFile then -- 950
						local projDir = getProjectDirFromFile(projFile) -- 951
						if projDir then -- 951
							local scriptDir = Path(projDir, "Script") -- 952
							local searchPaths = Content.searchPaths -- 953
							if Content:exist(scriptDir) then -- 954
								Content:addSearchPath(scriptDir) -- 954
							end -- 954
							if Content:exist(projDir) then -- 955
								Content:addSearchPath(projDir) -- 955
							end -- 955
							local _ <close> = setmetatable({ }, { -- 956
								__close = function() -- 956
									Content.searchPaths = searchPaths -- 956
								end -- 956
							}) -- 956
							local result = readFile() -- 957
							if result then -- 957
								return result -- 957
							end -- 957
						end -- 951
					end -- 950
				end -- 950
				local result = readFile() -- 958
				if result then -- 958
					return result -- 958
				end -- 958
			end -- 945
		end -- 945
	end -- 945
	return { -- 944
		success = false -- 944
	} -- 944
end) -- 944
HttpServer:get("/read-sync", function(req) -- 960
	do -- 961
		local _type_0 = type(req) -- 961
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 961
		if _tab_0 then -- 961
			local params = req.params -- 961
			if params ~= nil then -- 961
				local path = params.path -- 962
				local exts -- 963
				if params.exts then -- 963
					local _accum_0 = { } -- 964
					local _len_0 = 1 -- 964
					for ext in params.exts:gmatch("[^|]*") do -- 964
						_accum_0[_len_0] = ext -- 965
						_len_0 = _len_0 + 1 -- 965
					end -- 964
					exts = _accum_0 -- 963
				else -- 966
					exts = { -- 966
						"" -- 966
					} -- 966
				end -- 963
				local readFile -- 967
				readFile = function() -- 967
					for _index_0 = 1, #exts do -- 968
						local ext = exts[_index_0] -- 968
						local targetPath = path .. ext -- 969
						if Content:exist(targetPath) then -- 970
							local content = Content:load(targetPath) -- 971
							if content then -- 971
								return { -- 972
									content = content, -- 972
									success = true, -- 972
									fullPath = Content:getFullPath(targetPath) -- 972
								} -- 972
							end -- 971
						end -- 970
					end -- 968
					return nil -- 967
				end -- 967
				local searchPaths = Content.searchPaths -- 973
				local _ <close> = setmetatable({ }, { -- 974
					__close = function() -- 974
						Content.searchPaths = searchPaths -- 974
					end -- 974
				}) -- 974
				do -- 975
					local projFile = req.params.projFile -- 975
					if projFile then -- 975
						local projDir = getProjectDirFromFile(projFile) -- 976
						if projDir then -- 976
							local scriptDir = Path(projDir, "Script") -- 977
							if Content:exist(scriptDir) then -- 978
								Content:addSearchPath(scriptDir) -- 978
							end -- 978
							if Content:exist(projDir) then -- 979
								Content:addSearchPath(projDir) -- 979
							end -- 979
						else -- 981
							projDir = Path:getPath(projFile) -- 981
							if Content:exist(projDir) then -- 982
								Content:addSearchPath(projDir) -- 982
							end -- 982
						end -- 976
					end -- 975
				end -- 975
				local result = readFile() -- 983
				if result then -- 983
					return result -- 983
				end -- 983
			end -- 961
		end -- 961
	end -- 961
	return { -- 960
		success = false -- 960
	} -- 960
end) -- 960
local compileFileAsync -- 985
compileFileAsync = function(inputFile, sourceCodes) -- 985
	local file = inputFile -- 986
	local searchPath -- 987
	do -- 987
		local dir = getProjectDirFromFile(inputFile) -- 987
		if dir then -- 987
			file = Path:getRelative(inputFile, Path(Content.writablePath, dir)) -- 988
			searchPath = Path(dir, "Script", "?.lua") .. ";" .. Path(dir, "?.lua") -- 989
		else -- 991
			file = Path:getRelative(inputFile, Content.writablePath) -- 991
			if file:sub(1, 2) == ".." then -- 992
				file = Path:getRelative(inputFile, Content.assetPath) -- 993
			end -- 992
			searchPath = "" -- 994
		end -- 987
	end -- 987
	local outputFile = Path:replaceExt(inputFile, "lua") -- 995
	local yueext = yue.options.extension -- 996
	local resultCodes = nil -- 997
	local resultError = nil -- 998
	do -- 999
		local _exp_0 = Path:getExt(inputFile) -- 999
		if yueext == _exp_0 then -- 999
			local isTIC80, tic80APIs = CheckTIC80Code(sourceCodes) -- 1000
			yue.compile(inputFile, outputFile, searchPath, function(codes, err, globals) -- 1001
				if not codes then -- 1002
					resultError = err -- 1003
					return -- 1004
				end -- 1002
				local extraGlobal -- 1005
				if isTIC80 then -- 1005
					extraGlobal = tic80APIs -- 1005
				else -- 1005
					extraGlobal = nil -- 1005
				end -- 1005
				local success, message = LintYueGlobals(codes, globals, true, extraGlobal) -- 1006
				if not success then -- 1007
					resultError = message -- 1008
					return -- 1009
				end -- 1007
				if codes == "" then -- 1010
					resultCodes = "" -- 1011
					return nil -- 1012
				end -- 1010
				resultCodes = "-- [yue]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1013
				return resultCodes -- 1014
			end, function(success) -- 1001
				if not success then -- 1015
					Content:remove(outputFile) -- 1016
					if resultCodes == nil then -- 1017
						resultCodes = false -- 1018
					end -- 1017
				end -- 1015
			end) -- 1001
		elseif "tl" == _exp_0 then -- 1019
			local isTIC80 = CheckTIC80Code(sourceCodes) -- 1020
			if isTIC80 then -- 1021
				sourceCodes = sourceCodes:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1022
			end -- 1021
			local codes, err = teal.toluaAsync(sourceCodes, file, searchPath) -- 1023
			if codes then -- 1023
				if isTIC80 then -- 1024
					codes = codes:gsub("^require%(\"tic80\"%)", "-- tic80") -- 1025
				end -- 1024
				resultCodes = codes -- 1026
				Content:saveAsync(outputFile, codes) -- 1027
			else -- 1029
				Content:remove(outputFile) -- 1029
				resultCodes = false -- 1030
				resultError = err -- 1031
			end -- 1023
		elseif "xml" == _exp_0 then -- 1032
			local codes, err = xml.tolua(sourceCodes) -- 1033
			if codes then -- 1033
				resultCodes = "-- [xml]: " .. tostring(file) .. "\n" .. tostring(codes) -- 1034
				Content:saveAsync(outputFile, resultCodes) -- 1035
			else -- 1037
				Content:remove(outputFile) -- 1037
				resultCodes = false -- 1038
				resultError = err -- 1039
			end -- 1033
		end -- 999
	end -- 999
	wait(function() -- 1040
		return resultCodes ~= nil -- 1040
	end) -- 1040
	if resultCodes then -- 1041
		return resultCodes -- 1042
	else -- 1044
		return nil, resultError -- 1044
	end -- 1041
	return nil -- 985
end -- 985
HttpServer:postSchedule("/write", function(req) -- 1046
	do -- 1047
		local _type_0 = type(req) -- 1047
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1047
		if _tab_0 then -- 1047
			local path -- 1047
			do -- 1047
				local _obj_0 = req.body -- 1047
				local _type_1 = type(_obj_0) -- 1047
				if "table" == _type_1 or "userdata" == _type_1 then -- 1047
					path = _obj_0.path -- 1047
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
			if path ~= nil and content ~= nil then -- 1047
				if Content:saveAsync(path, content) then -- 1048
					do -- 1049
						local _exp_0 = Path:getExt(path) -- 1049
						if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1049
							if '' == Path:getExt(Path:getName(path)) then -- 1050
								local resultCodes = compileFileAsync(path, content) -- 1051
								return { -- 1052
									success = true, -- 1052
									resultCodes = resultCodes -- 1052
								} -- 1052
							end -- 1050
						end -- 1049
					end -- 1049
					return { -- 1053
						success = true -- 1053
					} -- 1053
				end -- 1048
			end -- 1047
		end -- 1047
	end -- 1047
	return { -- 1046
		success = false -- 1046
	} -- 1046
end) -- 1046
HttpServer:postSchedule("/build", function(req) -- 1055
	do -- 1056
		local _type_0 = type(req) -- 1056
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1056
		if _tab_0 then -- 1056
			local path -- 1056
			do -- 1056
				local _obj_0 = req.body -- 1056
				local _type_1 = type(_obj_0) -- 1056
				if "table" == _type_1 or "userdata" == _type_1 then -- 1056
					path = _obj_0.path -- 1056
				end -- 1056
			end -- 1056
			if path ~= nil then -- 1056
				local _exp_0 = Path:getExt(path) -- 1057
				if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1057
					if '' == Path:getExt(Path:getName(path)) then -- 1058
						local content = Content:loadAsync(path) -- 1059
						if content then -- 1059
							local resultCodes = compileFileAsync(path, content) -- 1060
							if resultCodes then -- 1060
								return { -- 1061
									success = true, -- 1061
									resultCodes = resultCodes -- 1061
								} -- 1061
							end -- 1060
						end -- 1059
					end -- 1058
				end -- 1057
			end -- 1056
		end -- 1056
	end -- 1056
	return { -- 1055
		success = false -- 1055
	} -- 1055
end) -- 1055
local extentionLevels = { -- 1064
	vs = 2, -- 1064
	bl = 2, -- 1065
	ts = 1, -- 1066
	tsx = 1, -- 1067
	tl = 1, -- 1068
	yue = 1, -- 1069
	xml = 1, -- 1070
	lua = 0 -- 1071
} -- 1063
HttpServer:post("/assets", function() -- 1073
	local Entry = require("Script.Dev.Entry") -- 1076
	local engineDev = Entry.getEngineDev() -- 1077
	local visitAssets -- 1078
	visitAssets = function(path, tag) -- 1078
		local isWorkspace = tag == "Workspace" -- 1079
		local builtin -- 1080
		if tag == "Builtin" then -- 1080
			builtin = true -- 1080
		else -- 1080
			builtin = nil -- 1080
		end -- 1080
		local children = nil -- 1081
		local dirs = Content:getDirs(path) -- 1082
		for _index_0 = 1, #dirs do -- 1083
			local dir = dirs[_index_0] -- 1083
			if isWorkspace then -- 1084
				if (".upload" == dir or ".download" == dir or ".www" == dir or ".build" == dir or ".git" == dir or ".cache" == dir) then -- 1085
					goto _continue_0 -- 1086
				end -- 1085
			elseif dir == ".git" then -- 1087
				goto _continue_0 -- 1088
			end -- 1084
			if not children then -- 1089
				children = { } -- 1089
			end -- 1089
			children[#children + 1] = visitAssets(Path(path, dir)) -- 1090
			::_continue_0:: -- 1084
		end -- 1083
		local files = Content:getFiles(path) -- 1091
		local names = { } -- 1092
		for _index_0 = 1, #files do -- 1093
			local file = files[_index_0] -- 1093
			if file:match("^%.") then -- 1094
				goto _continue_1 -- 1094
			end -- 1094
			local name = Path:getName(file) -- 1095
			local ext = names[name] -- 1096
			if ext then -- 1096
				local lv1 -- 1097
				do -- 1097
					local _exp_0 = extentionLevels[ext] -- 1097
					if _exp_0 ~= nil then -- 1097
						lv1 = _exp_0 -- 1097
					else -- 1097
						lv1 = -1 -- 1097
					end -- 1097
				end -- 1097
				ext = Path:getExt(file) -- 1098
				local lv2 -- 1099
				do -- 1099
					local _exp_0 = extentionLevels[ext] -- 1099
					if _exp_0 ~= nil then -- 1099
						lv2 = _exp_0 -- 1099
					else -- 1099
						lv2 = -1 -- 1099
					end -- 1099
				end -- 1099
				if lv2 > lv1 then -- 1100
					names[name] = ext -- 1101
				elseif lv2 == lv1 then -- 1102
					names[name .. '.' .. ext] = "" -- 1103
				end -- 1100
			else -- 1105
				ext = Path:getExt(file) -- 1105
				if not extentionLevels[ext] then -- 1106
					names[file] = "" -- 1107
				else -- 1109
					names[name] = ext -- 1109
				end -- 1106
			end -- 1096
			::_continue_1:: -- 1094
		end -- 1093
		do -- 1110
			local _accum_0 = { } -- 1110
			local _len_0 = 1 -- 1110
			for name, ext in pairs(names) do -- 1110
				_accum_0[_len_0] = ext == '' and name or name .. '.' .. ext -- 1110
				_len_0 = _len_0 + 1 -- 1110
			end -- 1110
			files = _accum_0 -- 1110
		end -- 1110
		for _index_0 = 1, #files do -- 1111
			local file = files[_index_0] -- 1111
			if not children then -- 1112
				children = { } -- 1112
			end -- 1112
			children[#children + 1] = { -- 1114
				key = Path(path, file), -- 1114
				dir = false, -- 1115
				title = file, -- 1116
				builtin = builtin -- 1117
			} -- 1113
		end -- 1111
		if children then -- 1119
			table.sort(children, function(a, b) -- 1120
				if a.dir == b.dir then -- 1121
					return a.title < b.title -- 1122
				else -- 1124
					return a.dir -- 1124
				end -- 1121
			end) -- 1120
		end -- 1119
		if isWorkspace and children then -- 1125
			return children -- 1126
		else -- 1128
			return { -- 1129
				key = path, -- 1129
				dir = true, -- 1130
				title = Path:getFilename(path), -- 1131
				builtin = builtin, -- 1132
				children = children -- 1133
			} -- 1128
		end -- 1125
	end -- 1078
	local zh = (App.locale:match("^zh") ~= nil) -- 1135
	return { -- 1137
		key = Content.writablePath, -- 1137
		dir = true, -- 1138
		root = true, -- 1139
		title = "Assets", -- 1140
		children = (function() -- 1142
			local _tab_0 = { -- 1142
				{ -- 1143
					key = Path(Content.assetPath), -- 1143
					dir = true, -- 1144
					builtin = true, -- 1145
					title = zh and "内置资源" or "Built-in", -- 1146
					children = { -- 1148
						(function() -- 1148
							local _with_0 = visitAssets((Path(Content.assetPath, "Doc", zh and "zh-Hans" or "en")), "Builtin") -- 1148
							_with_0.title = zh and "说明文档" or "Readme" -- 1149
							return _with_0 -- 1148
						end)(), -- 1148
						(function() -- 1150
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib", "Dora", zh and "zh-Hans" or "en")), "Builtin") -- 1150
							_with_0.title = zh and "接口文档" or "API Doc" -- 1151
							return _with_0 -- 1150
						end)(), -- 1150
						(function() -- 1152
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Tools")), "Builtin") -- 1152
							_with_0.title = zh and "开发工具" or "Tools" -- 1153
							return _with_0 -- 1152
						end)(), -- 1152
						(function() -- 1154
							local _with_0 = visitAssets((Path(Content.assetPath, "Font")), "Builtin") -- 1154
							_with_0.title = zh and "字体" or "Font" -- 1155
							return _with_0 -- 1154
						end)(), -- 1154
						(function() -- 1156
							local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Lib")), "Builtin") -- 1156
							_with_0.title = zh and "程序库" or "Lib" -- 1157
							if engineDev then -- 1158
								local _list_0 = _with_0.children -- 1159
								for _index_0 = 1, #_list_0 do -- 1159
									local child = _list_0[_index_0] -- 1159
									if not (child.title == "Dora") then -- 1160
										goto _continue_0 -- 1160
									end -- 1160
									local title = zh and "zh-Hans" or "en" -- 1161
									do -- 1162
										local _accum_0 = { } -- 1162
										local _len_0 = 1 -- 1162
										local _list_1 = child.children -- 1162
										for _index_1 = 1, #_list_1 do -- 1162
											local c = _list_1[_index_1] -- 1162
											if c.title ~= title then -- 1162
												_accum_0[_len_0] = c -- 1162
												_len_0 = _len_0 + 1 -- 1162
											end -- 1162
										end -- 1162
										child.children = _accum_0 -- 1162
									end -- 1162
									break -- 1163
									::_continue_0:: -- 1160
								end -- 1159
							else -- 1165
								local _accum_0 = { } -- 1165
								local _len_0 = 1 -- 1165
								local _list_0 = _with_0.children -- 1165
								for _index_0 = 1, #_list_0 do -- 1165
									local child = _list_0[_index_0] -- 1165
									if child.title ~= "Dora" then -- 1165
										_accum_0[_len_0] = child -- 1165
										_len_0 = _len_0 + 1 -- 1165
									end -- 1165
								end -- 1165
								_with_0.children = _accum_0 -- 1165
							end -- 1158
							return _with_0 -- 1156
						end)(), -- 1156
						(function() -- 1166
							if engineDev then -- 1166
								local _with_0 = visitAssets((Path(Content.assetPath, "Script", "Dev")), "Builtin") -- 1167
								local _obj_0 = _with_0.children -- 1168
								_obj_0[#_obj_0 + 1] = { -- 1169
									key = Path(Content.assetPath, "Script", "init.yue"), -- 1169
									dir = false, -- 1170
									builtin = true, -- 1171
									title = "init.yue" -- 1172
								} -- 1168
								return _with_0 -- 1167
							end -- 1166
						end)() -- 1166
					} -- 1147
				} -- 1142
			} -- 1176
			local _obj_0 = visitAssets(Content.writablePath, "Workspace") -- 1176
			local _idx_0 = #_tab_0 + 1 -- 1176
			for _index_0 = 1, #_obj_0 do -- 1176
				local _value_0 = _obj_0[_index_0] -- 1176
				_tab_0[_idx_0] = _value_0 -- 1176
				_idx_0 = _idx_0 + 1 -- 1176
			end -- 1176
			return _tab_0 -- 1142
		end)() -- 1141
	} -- 1136
end) -- 1073
HttpServer:postSchedule("/run", function(req) -- 1180
	do -- 1181
		local _type_0 = type(req) -- 1181
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1181
		if _tab_0 then -- 1181
			local file -- 1181
			do -- 1181
				local _obj_0 = req.body -- 1181
				local _type_1 = type(_obj_0) -- 1181
				if "table" == _type_1 or "userdata" == _type_1 then -- 1181
					file = _obj_0.file -- 1181
				end -- 1181
			end -- 1181
			local asProj -- 1181
			do -- 1181
				local _obj_0 = req.body -- 1181
				local _type_1 = type(_obj_0) -- 1181
				if "table" == _type_1 or "userdata" == _type_1 then -- 1181
					asProj = _obj_0.asProj -- 1181
				end -- 1181
			end -- 1181
			if file ~= nil and asProj ~= nil then -- 1181
				if not Content:isAbsolutePath(file) then -- 1182
					local devFile = Path(Content.writablePath, file) -- 1183
					if Content:exist(devFile) then -- 1184
						file = devFile -- 1184
					end -- 1184
				end -- 1182
				local Entry = require("Script.Dev.Entry") -- 1185
				local workDir -- 1186
				if asProj then -- 1187
					workDir = getProjectDirFromFile(file) -- 1188
					if workDir then -- 1188
						Entry.allClear() -- 1189
						local target = Path(workDir, "init") -- 1190
						local success, err = Entry.enterEntryAsync({ -- 1191
							entryName = "Project", -- 1191
							fileName = target -- 1191
						}) -- 1191
						target = Path:getName(Path:getPath(target)) -- 1192
						return { -- 1193
							success = success, -- 1193
							target = target, -- 1193
							err = err -- 1193
						} -- 1193
					end -- 1188
				else -- 1195
					workDir = getProjectDirFromFile(file) -- 1195
				end -- 1187
				Entry.allClear() -- 1196
				file = Path:replaceExt(file, "") -- 1197
				local success, err = Entry.enterEntryAsync({ -- 1199
					entryName = Path:getName(file), -- 1199
					fileName = file, -- 1200
					workDir = workDir -- 1201
				}) -- 1198
				return { -- 1202
					success = success, -- 1202
					err = err -- 1202
				} -- 1202
			end -- 1181
		end -- 1181
	end -- 1181
	return { -- 1180
		success = false -- 1180
	} -- 1180
end) -- 1180
HttpServer:postSchedule("/stop", function() -- 1204
	local Entry = require("Script.Dev.Entry") -- 1205
	return { -- 1206
		success = Entry.stop() -- 1206
	} -- 1206
end) -- 1204
local minifyAsync -- 1208
minifyAsync = function(sourcePath, minifyPath) -- 1208
	if not Content:exist(sourcePath) then -- 1209
		return -- 1209
	end -- 1209
	local Entry = require("Script.Dev.Entry") -- 1210
	local errors = { } -- 1211
	local files = Entry.getAllFiles(sourcePath, { -- 1212
		"lua" -- 1212
	}, true) -- 1212
	do -- 1213
		local _accum_0 = { } -- 1213
		local _len_0 = 1 -- 1213
		for _index_0 = 1, #files do -- 1213
			local file = files[_index_0] -- 1213
			if file:sub(1, 1) ~= '.' then -- 1213
				_accum_0[_len_0] = file -- 1213
				_len_0 = _len_0 + 1 -- 1213
			end -- 1213
		end -- 1213
		files = _accum_0 -- 1213
	end -- 1213
	local paths -- 1214
	do -- 1214
		local _tbl_0 = { } -- 1214
		for _index_0 = 1, #files do -- 1214
			local file = files[_index_0] -- 1214
			_tbl_0[Path:getPath(file)] = true -- 1214
		end -- 1214
		paths = _tbl_0 -- 1214
	end -- 1214
	for path in pairs(paths) do -- 1215
		Content:mkdir(Path(minifyPath, path)) -- 1215
	end -- 1215
	local _ <close> = setmetatable({ }, { -- 1216
		__close = function() -- 1216
			package.loaded["luaminify.FormatMini"] = nil -- 1217
			package.loaded["luaminify.ParseLua"] = nil -- 1218
			package.loaded["luaminify.Scope"] = nil -- 1219
			package.loaded["luaminify.Util"] = nil -- 1220
		end -- 1216
	}) -- 1216
	local FormatMini -- 1221
	do -- 1221
		local _obj_0 = require("luaminify") -- 1221
		FormatMini = _obj_0.FormatMini -- 1221
	end -- 1221
	local fileCount = #files -- 1222
	local count = 0 -- 1223
	for _index_0 = 1, #files do -- 1224
		local file = files[_index_0] -- 1224
		thread(function() -- 1225
			local _ <close> = setmetatable({ }, { -- 1226
				__close = function() -- 1226
					count = count + 1 -- 1226
				end -- 1226
			}) -- 1226
			local input = Path(sourcePath, file) -- 1227
			local output = Path(minifyPath, Path:replaceExt(file, "lua")) -- 1228
			if Content:exist(input) then -- 1229
				local sourceCodes = Content:loadAsync(input) -- 1230
				local res, err = FormatMini(sourceCodes) -- 1231
				if res then -- 1232
					Content:saveAsync(output, res) -- 1233
					return print("Minify " .. tostring(file)) -- 1234
				else -- 1236
					errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\n" .. tostring(err) -- 1236
				end -- 1232
			else -- 1238
				errors[#errors + 1] = "Minify errors in " .. tostring(file) .. ".\nTarget file is not exist!" -- 1238
			end -- 1229
		end) -- 1225
		sleep() -- 1239
	end -- 1224
	wait(function() -- 1240
		return count == fileCount -- 1240
	end) -- 1240
	if #errors > 0 then -- 1241
		print(table.concat(errors, '\n')) -- 1242
	end -- 1241
	print("Obfuscation done.") -- 1243
	return files -- 1244
end -- 1208
local zipping = false -- 1246
HttpServer:postSchedule("/zip", function(req) -- 1248
	do -- 1249
		local _type_0 = type(req) -- 1249
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1249
		if _tab_0 then -- 1249
			local path -- 1249
			do -- 1249
				local _obj_0 = req.body -- 1249
				local _type_1 = type(_obj_0) -- 1249
				if "table" == _type_1 or "userdata" == _type_1 then -- 1249
					path = _obj_0.path -- 1249
				end -- 1249
			end -- 1249
			local zipFile -- 1249
			do -- 1249
				local _obj_0 = req.body -- 1249
				local _type_1 = type(_obj_0) -- 1249
				if "table" == _type_1 or "userdata" == _type_1 then -- 1249
					zipFile = _obj_0.zipFile -- 1249
				end -- 1249
			end -- 1249
			local obfuscated -- 1249
			do -- 1249
				local _obj_0 = req.body -- 1249
				local _type_1 = type(_obj_0) -- 1249
				if "table" == _type_1 or "userdata" == _type_1 then -- 1249
					obfuscated = _obj_0.obfuscated -- 1249
				end -- 1249
			end -- 1249
			if path ~= nil and zipFile ~= nil and obfuscated ~= nil then -- 1249
				if zipping then -- 1250
					goto failed -- 1250
				end -- 1250
				zipping = true -- 1251
				local _ <close> = setmetatable({ }, { -- 1252
					__close = function() -- 1252
						zipping = false -- 1252
					end -- 1252
				}) -- 1252
				if not Content:exist(path) then -- 1253
					goto failed -- 1253
				end -- 1253
				Content:mkdir(Path:getPath(zipFile)) -- 1254
				if obfuscated then -- 1255
					local scriptPath = Path(Content.writablePath, ".download", ".script") -- 1256
					local obfuscatedPath = Path(Content.writablePath, ".download", ".obfuscated") -- 1257
					local tempPath = Path(Content.writablePath, ".download", ".temp") -- 1258
					Content:remove(scriptPath) -- 1259
					Content:remove(obfuscatedPath) -- 1260
					Content:remove(tempPath) -- 1261
					Content:mkdir(scriptPath) -- 1262
					Content:mkdir(obfuscatedPath) -- 1263
					Content:mkdir(tempPath) -- 1264
					if not Content:copyAsync(path, tempPath) then -- 1265
						goto failed -- 1265
					end -- 1265
					local Entry = require("Script.Dev.Entry") -- 1266
					local luaFiles = minifyAsync(tempPath, obfuscatedPath) -- 1267
					local scriptFiles = Entry.getAllFiles(tempPath, { -- 1268
						"tl", -- 1268
						"yue", -- 1268
						"lua", -- 1268
						"ts", -- 1268
						"tsx", -- 1268
						"vs", -- 1268
						"bl", -- 1268
						"xml", -- 1268
						"wa", -- 1268
						"mod" -- 1268
					}, true) -- 1268
					for _index_0 = 1, #scriptFiles do -- 1269
						local file = scriptFiles[_index_0] -- 1269
						Content:remove(Path(tempPath, file)) -- 1270
					end -- 1269
					for _index_0 = 1, #luaFiles do -- 1271
						local file = luaFiles[_index_0] -- 1271
						Content:move(Path(obfuscatedPath, file), Path(tempPath, file)) -- 1272
					end -- 1271
					if not Content:zipAsync(tempPath, zipFile, function(file) -- 1273
						return not (file:match('^%.') or file:match("[\\/]%.")) -- 1274
					end) then -- 1273
						goto failed -- 1273
					end -- 1273
					return { -- 1275
						success = true -- 1275
					} -- 1275
				else -- 1277
					return { -- 1277
						success = Content:zipAsync(path, zipFile, function(file) -- 1277
							return not (file:match('^%.') or file:match("[\\/]%.")) -- 1278
						end) -- 1277
					} -- 1277
				end -- 1255
			end -- 1249
		end -- 1249
	end -- 1249
	::failed:: -- 1279
	return { -- 1248
		success = false -- 1248
	} -- 1248
end) -- 1248
HttpServer:postSchedule("/unzip", function(req) -- 1281
	do -- 1282
		local _type_0 = type(req) -- 1282
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1282
		if _tab_0 then -- 1282
			local zipFile -- 1282
			do -- 1282
				local _obj_0 = req.body -- 1282
				local _type_1 = type(_obj_0) -- 1282
				if "table" == _type_1 or "userdata" == _type_1 then -- 1282
					zipFile = _obj_0.zipFile -- 1282
				end -- 1282
			end -- 1282
			local path -- 1282
			do -- 1282
				local _obj_0 = req.body -- 1282
				local _type_1 = type(_obj_0) -- 1282
				if "table" == _type_1 or "userdata" == _type_1 then -- 1282
					path = _obj_0.path -- 1282
				end -- 1282
			end -- 1282
			if zipFile ~= nil and path ~= nil then -- 1282
				return { -- 1283
					success = Content:unzipAsync(zipFile, path, function(file) -- 1283
						return not (file:match('^%.') or file:match("[\\/]%.") or file:match("__MACOSX")) -- 1284
					end) -- 1283
				} -- 1283
			end -- 1282
		end -- 1282
	end -- 1282
	return { -- 1281
		success = false -- 1281
	} -- 1281
end) -- 1281
HttpServer:post("/editing-info", function(req) -- 1286
	local Entry = require("Script.Dev.Entry") -- 1287
	local config = Entry.getConfig() -- 1288
	local _type_0 = type(req) -- 1289
	local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1289
	local _match_0 = false -- 1289
	if _tab_0 then -- 1289
		local editingInfo -- 1289
		do -- 1289
			local _obj_0 = req.body -- 1289
			local _type_1 = type(_obj_0) -- 1289
			if "table" == _type_1 or "userdata" == _type_1 then -- 1289
				editingInfo = _obj_0.editingInfo -- 1289
			end -- 1289
		end -- 1289
		if editingInfo ~= nil then -- 1289
			_match_0 = true -- 1289
			config.editingInfo = editingInfo -- 1290
			return { -- 1291
				success = true -- 1291
			} -- 1291
		end -- 1289
	end -- 1289
	if not _match_0 then -- 1289
		if not (config.editingInfo ~= nil) then -- 1293
			local folder -- 1294
			if App.locale:match('^zh') then -- 1294
				folder = 'zh-Hans' -- 1294
			else -- 1294
				folder = 'en' -- 1294
			end -- 1294
			config.editingInfo = json.encode({ -- 1296
				index = 0, -- 1296
				files = { -- 1298
					{ -- 1299
						key = Path(Content.assetPath, 'Doc', folder, 'welcome.md'), -- 1299
						title = "welcome.md" -- 1300
					} -- 1298
				} -- 1297
			}) -- 1295
		end -- 1293
		return { -- 1304
			success = true, -- 1304
			editingInfo = config.editingInfo -- 1304
		} -- 1304
	end -- 1289
end) -- 1286
HttpServer:post("/command", function(req) -- 1306
	do -- 1307
		local _type_0 = type(req) -- 1307
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1307
		if _tab_0 then -- 1307
			local code -- 1307
			do -- 1307
				local _obj_0 = req.body -- 1307
				local _type_1 = type(_obj_0) -- 1307
				if "table" == _type_1 or "userdata" == _type_1 then -- 1307
					code = _obj_0.code -- 1307
				end -- 1307
			end -- 1307
			local log -- 1307
			do -- 1307
				local _obj_0 = req.body -- 1307
				local _type_1 = type(_obj_0) -- 1307
				if "table" == _type_1 or "userdata" == _type_1 then -- 1307
					log = _obj_0.log -- 1307
				end -- 1307
			end -- 1307
			if code ~= nil and log ~= nil then -- 1307
				emit("AppCommand", code, log) -- 1308
				return { -- 1309
					success = true -- 1309
				} -- 1309
			end -- 1307
		end -- 1307
	end -- 1307
	return { -- 1306
		success = false -- 1306
	} -- 1306
end) -- 1306
HttpServer:post("/log/save", function() -- 1311
	local folder = ".download" -- 1312
	local fullLogFile = "dora_full_logs.txt" -- 1313
	local fullFolder = Path(Content.writablePath, folder) -- 1314
	Content:mkdir(fullFolder) -- 1315
	local logPath = Path(fullFolder, fullLogFile) -- 1316
	if App:saveLog(logPath) then -- 1317
		return { -- 1318
			success = true, -- 1318
			path = Path(folder, fullLogFile) -- 1318
		} -- 1318
	end -- 1317
	return { -- 1311
		success = false -- 1311
	} -- 1311
end) -- 1311
HttpServer:post("/yarn/check", function(req) -- 1320
	local yarncompile = require("yarncompile") -- 1321
	do -- 1322
		local _type_0 = type(req) -- 1322
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1322
		if _tab_0 then -- 1322
			local code -- 1322
			do -- 1322
				local _obj_0 = req.body -- 1322
				local _type_1 = type(_obj_0) -- 1322
				if "table" == _type_1 or "userdata" == _type_1 then -- 1322
					code = _obj_0.code -- 1322
				end -- 1322
			end -- 1322
			if code ~= nil then -- 1322
				local jsonObject = json.decode(code) -- 1323
				if jsonObject then -- 1323
					local errors = { } -- 1324
					local _list_0 = jsonObject.nodes -- 1325
					for _index_0 = 1, #_list_0 do -- 1325
						local node = _list_0[_index_0] -- 1325
						local title, body = node.title, node.body -- 1326
						local luaCode, err = yarncompile(body) -- 1327
						if not luaCode then -- 1327
							errors[#errors + 1] = title .. ":" .. err -- 1328
						end -- 1327
					end -- 1325
					return { -- 1329
						success = true, -- 1329
						syntaxError = table.concat(errors, "\n\n") -- 1329
					} -- 1329
				end -- 1323
			end -- 1322
		end -- 1322
	end -- 1322
	return { -- 1320
		success = false -- 1320
	} -- 1320
end) -- 1320
HttpServer:post("/yarn/check-file", function(req) -- 1331
	local yarncompile = require("yarncompile") -- 1332
	do -- 1333
		local _type_0 = type(req) -- 1333
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1333
		if _tab_0 then -- 1333
			local code -- 1333
			do -- 1333
				local _obj_0 = req.body -- 1333
				local _type_1 = type(_obj_0) -- 1333
				if "table" == _type_1 or "userdata" == _type_1 then -- 1333
					code = _obj_0.code -- 1333
				end -- 1333
			end -- 1333
			if code ~= nil then -- 1333
				local res, _, err = yarncompile(code, true) -- 1334
				if not res then -- 1334
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1335
					return { -- 1336
						success = false, -- 1336
						message = message, -- 1336
						line = line, -- 1336
						column = column, -- 1336
						node = node -- 1336
					} -- 1336
				end -- 1334
			end -- 1333
		end -- 1333
	end -- 1333
	return { -- 1331
		success = true -- 1331
	} -- 1331
end) -- 1331
local getWaProjectDirFromFile -- 1338
getWaProjectDirFromFile = function(file) -- 1338
	local writablePath = Content.writablePath -- 1339
	local parent, current -- 1340
	if (".." ~= Path:getRelative(file, writablePath):sub(1, 2)) and writablePath == file:sub(1, #writablePath) then -- 1340
		parent, current = writablePath, Path:getRelative(file, writablePath) -- 1341
	else -- 1343
		parent, current = nil, nil -- 1343
	end -- 1340
	if not current then -- 1344
		return nil -- 1344
	end -- 1344
	repeat -- 1345
		current = Path:getPath(current) -- 1346
		if current == "" then -- 1347
			break -- 1347
		end -- 1347
		local _list_0 = Content:getFiles(Path(parent, current)) -- 1348
		for _index_0 = 1, #_list_0 do -- 1348
			local f = _list_0[_index_0] -- 1348
			if Path:getFilename(f):lower() == "wa.mod" then -- 1349
				return Path(parent, current, Path:getPath(f)) -- 1350
			end -- 1349
		end -- 1348
	until false -- 1345
	return nil -- 1352
end -- 1338
HttpServer:postSchedule("/wa/update_dora", function(req) -- 1354
	do -- 1355
		local _type_0 = type(req) -- 1355
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1355
		if _tab_0 then -- 1355
			local path -- 1355
			do -- 1355
				local _obj_0 = req.body -- 1355
				local _type_1 = type(_obj_0) -- 1355
				if "table" == _type_1 or "userdata" == _type_1 then -- 1355
					path = _obj_0.path -- 1355
				end -- 1355
			end -- 1355
			if path ~= nil then -- 1355
				local projDir = getWaProjectDirFromFile(path) -- 1356
				if projDir then -- 1356
					local sourceDoraPath = Path(Content.assetPath, "dora-wa", "vendor", "dora") -- 1357
					if not Content:exist(sourceDoraPath) then -- 1358
						return { -- 1359
							success = false, -- 1359
							message = "missing dora template" -- 1359
						} -- 1359
					end -- 1358
					local targetVendorPath = Path(projDir, "vendor") -- 1360
					local targetDoraPath = Path(targetVendorPath, "dora") -- 1361
					if not Content:exist(targetVendorPath) then -- 1362
						if not Content:mkdir(targetVendorPath) then -- 1363
							return { -- 1364
								success = false, -- 1364
								message = "failed to create vendor folder" -- 1364
							} -- 1364
						end -- 1363
					elseif not Content:isdir(targetVendorPath) then -- 1365
						return { -- 1366
							success = false, -- 1366
							message = "vendor path is not a folder" -- 1366
						} -- 1366
					end -- 1362
					if Content:exist(targetDoraPath) then -- 1367
						if not Content:remove(targetDoraPath) then -- 1368
							return { -- 1369
								success = false, -- 1369
								message = "failed to remove old dora" -- 1369
							} -- 1369
						end -- 1368
					end -- 1367
					if not Content:copyAsync(sourceDoraPath, targetDoraPath) then -- 1370
						return { -- 1371
							success = false, -- 1371
							message = "failed to copy dora" -- 1371
						} -- 1371
					end -- 1370
					return { -- 1372
						success = true -- 1372
					} -- 1372
				else -- 1374
					return { -- 1374
						success = false, -- 1374
						message = 'Wa file needs a project' -- 1374
					} -- 1374
				end -- 1356
			end -- 1355
		end -- 1355
	end -- 1355
	return { -- 1354
		success = false, -- 1354
		message = "invalid call" -- 1354
	} -- 1354
end) -- 1354
HttpServer:postSchedule("/wa/build", function(req) -- 1376
	do -- 1377
		local _type_0 = type(req) -- 1377
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1377
		if _tab_0 then -- 1377
			local path -- 1377
			do -- 1377
				local _obj_0 = req.body -- 1377
				local _type_1 = type(_obj_0) -- 1377
				if "table" == _type_1 or "userdata" == _type_1 then -- 1377
					path = _obj_0.path -- 1377
				end -- 1377
			end -- 1377
			if path ~= nil then -- 1377
				local projDir = getWaProjectDirFromFile(path) -- 1378
				if projDir then -- 1378
					local message = Wasm:buildWaAsync(projDir) -- 1379
					if message == "" then -- 1380
						return { -- 1381
							success = true -- 1381
						} -- 1381
					else -- 1383
						return { -- 1383
							success = false, -- 1383
							message = message -- 1383
						} -- 1383
					end -- 1380
				else -- 1385
					return { -- 1385
						success = false, -- 1385
						message = 'Wa file needs a project' -- 1385
					} -- 1385
				end -- 1378
			end -- 1377
		end -- 1377
	end -- 1377
	return { -- 1386
		success = false, -- 1386
		message = 'failed to build' -- 1386
	} -- 1386
end) -- 1376
HttpServer:postSchedule("/wa/format", function(req) -- 1388
	do -- 1389
		local _type_0 = type(req) -- 1389
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1389
		if _tab_0 then -- 1389
			local file -- 1389
			do -- 1389
				local _obj_0 = req.body -- 1389
				local _type_1 = type(_obj_0) -- 1389
				if "table" == _type_1 or "userdata" == _type_1 then -- 1389
					file = _obj_0.file -- 1389
				end -- 1389
			end -- 1389
			if file ~= nil then -- 1389
				local code = Wasm:formatWaAsync(file) -- 1390
				if code == "" then -- 1391
					return { -- 1392
						success = false -- 1392
					} -- 1392
				else -- 1394
					return { -- 1394
						success = true, -- 1394
						code = code -- 1394
					} -- 1394
				end -- 1391
			end -- 1389
		end -- 1389
	end -- 1389
	return { -- 1395
		success = false -- 1395
	} -- 1395
end) -- 1388
HttpServer:postSchedule("/wa/create", function(req) -- 1397
	do -- 1398
		local _type_0 = type(req) -- 1398
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1398
		if _tab_0 then -- 1398
			local path -- 1398
			do -- 1398
				local _obj_0 = req.body -- 1398
				local _type_1 = type(_obj_0) -- 1398
				if "table" == _type_1 or "userdata" == _type_1 then -- 1398
					path = _obj_0.path -- 1398
				end -- 1398
			end -- 1398
			if path ~= nil then -- 1398
				if not Content:exist(Path:getPath(path)) then -- 1399
					return { -- 1400
						success = false, -- 1400
						message = "target path not existed" -- 1400
					} -- 1400
				end -- 1399
				if Content:exist(path) then -- 1401
					return { -- 1402
						success = false, -- 1402
						message = "target project folder existed" -- 1402
					} -- 1402
				end -- 1401
				local srcPath = Path(Content.assetPath, "dora-wa", "src") -- 1403
				local vendorPath = Path(Content.assetPath, "dora-wa", "vendor") -- 1404
				local modPath = Path(Content.assetPath, "dora-wa", "wa.mod") -- 1405
				if not Content:exist(srcPath) or not Content:exist(vendorPath) or not Content:exist(modPath) then -- 1406
					return { -- 1409
						success = false, -- 1409
						message = "missing template project" -- 1409
					} -- 1409
				end -- 1406
				if not Content:mkdir(path) then -- 1410
					return { -- 1411
						success = false, -- 1411
						message = "failed to create project folder" -- 1411
					} -- 1411
				end -- 1410
				if not Content:copyAsync(srcPath, Path(path, "src")) then -- 1412
					Content:remove(path) -- 1413
					return { -- 1414
						success = false, -- 1414
						message = "failed to copy template" -- 1414
					} -- 1414
				end -- 1412
				if not Content:copyAsync(vendorPath, Path(path, "vendor")) then -- 1415
					Content:remove(path) -- 1416
					return { -- 1417
						success = false, -- 1417
						message = "failed to copy template" -- 1417
					} -- 1417
				end -- 1415
				if not Content:copyAsync(modPath, Path(path, "wa.mod")) then -- 1418
					Content:remove(path) -- 1419
					return { -- 1420
						success = false, -- 1420
						message = "failed to copy template" -- 1420
					} -- 1420
				end -- 1418
				return { -- 1421
					success = true -- 1421
				} -- 1421
			end -- 1398
		end -- 1398
	end -- 1398
	return { -- 1397
		success = false, -- 1397
		message = "invalid call" -- 1397
	} -- 1397
end) -- 1397
local _anon_func_5 = function(path) -- 1430
	local _val_0 = Path:getExt(path) -- 1430
	return "ts" == _val_0 or "tsx" == _val_0 -- 1430
end -- 1430
local _anon_func_6 = function(f) -- 1460
	local _val_0 = Path:getExt(f) -- 1460
	return "ts" == _val_0 or "tsx" == _val_0 -- 1460
end -- 1460
HttpServer:postSchedule("/ts/build", function(req) -- 1423
	do -- 1424
		local _type_0 = type(req) -- 1424
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1424
		if _tab_0 then -- 1424
			local path -- 1424
			do -- 1424
				local _obj_0 = req.body -- 1424
				local _type_1 = type(_obj_0) -- 1424
				if "table" == _type_1 or "userdata" == _type_1 then -- 1424
					path = _obj_0.path -- 1424
				end -- 1424
			end -- 1424
			if path ~= nil then -- 1424
				if HttpServer.wsConnectionCount == 0 then -- 1425
					return { -- 1426
						success = false, -- 1426
						message = "Web IDE not connected" -- 1426
					} -- 1426
				end -- 1425
				if not Content:exist(path) then -- 1427
					return { -- 1428
						success = false, -- 1428
						message = "path not existed" -- 1428
					} -- 1428
				end -- 1427
				if not Content:isdir(path) then -- 1429
					if not (_anon_func_5(path)) then -- 1430
						return { -- 1431
							success = false, -- 1431
							message = "expecting a TypeScript file" -- 1431
						} -- 1431
					end -- 1430
					local messages = { } -- 1432
					local content = Content:load(path) -- 1433
					if not content then -- 1434
						return { -- 1435
							success = false, -- 1435
							message = "failed to read file" -- 1435
						} -- 1435
					end -- 1434
					emit("AppWS", "Send", json.encode({ -- 1436
						name = "UpdateFile", -- 1436
						file = path, -- 1436
						exists = true, -- 1436
						content = content -- 1436
					})) -- 1436
					if "d" ~= Path:getExt(Path:getName(path)) then -- 1437
						local done = false -- 1438
						do -- 1439
							local _with_0 = Node() -- 1439
							_with_0:gslot("AppWS", function(event) -- 1440
								if event.type == "Receive" then -- 1441
									local res = json.decode(event.msg) -- 1442
									if res then -- 1442
										if res.name == "TranspileTS" and res.file == path then -- 1443
											_with_0:removeFromParent() -- 1444
											if res.success then -- 1445
												local luaFile = Path:replaceExt(path, "lua") -- 1446
												Content:save(luaFile, res.luaCode) -- 1447
												messages[#messages + 1] = { -- 1448
													success = true, -- 1448
													file = path -- 1448
												} -- 1448
											else -- 1450
												messages[#messages + 1] = { -- 1450
													success = false, -- 1450
													file = path, -- 1450
													message = res.message -- 1450
												} -- 1450
											end -- 1445
											done = true -- 1451
										end -- 1443
									end -- 1442
								end -- 1441
							end) -- 1440
						end -- 1439
						emit("AppWS", "Send", json.encode({ -- 1452
							name = "TranspileTS", -- 1452
							file = path, -- 1452
							content = content -- 1452
						})) -- 1452
						wait(function() -- 1453
							return done -- 1453
						end) -- 1453
					end -- 1437
					return { -- 1454
						success = true, -- 1454
						messages = messages -- 1454
					} -- 1454
				else -- 1456
					local files = Content:getAllFiles(path) -- 1456
					local fileData = { } -- 1457
					local messages = { } -- 1458
					for _index_0 = 1, #files do -- 1459
						local f = files[_index_0] -- 1459
						if not (_anon_func_6(f)) then -- 1460
							goto _continue_0 -- 1460
						end -- 1460
						local file = Path(path, f) -- 1461
						local content = Content:load(file) -- 1462
						if content then -- 1462
							fileData[file] = content -- 1463
							emit("AppWS", "Send", json.encode({ -- 1464
								name = "UpdateFile", -- 1464
								file = file, -- 1464
								exists = true, -- 1464
								content = content -- 1464
							})) -- 1464
						else -- 1466
							messages[#messages + 1] = { -- 1466
								success = false, -- 1466
								file = file, -- 1466
								message = "failed to read file" -- 1466
							} -- 1466
						end -- 1462
						::_continue_0:: -- 1460
					end -- 1459
					for file, content in pairs(fileData) do -- 1467
						if "d" == Path:getExt(Path:getName(file)) then -- 1468
							goto _continue_1 -- 1468
						end -- 1468
						local done = false -- 1469
						do -- 1470
							local _with_0 = Node() -- 1470
							_with_0:gslot("AppWS", function(event) -- 1471
								if event.type == "Receive" then -- 1472
									local res = json.decode(event.msg) -- 1473
									if res then -- 1473
										if res.name == "TranspileTS" and res.file == file then -- 1474
											_with_0:removeFromParent() -- 1475
											if res.success then -- 1476
												local luaFile = Path:replaceExt(file, "lua") -- 1477
												Content:save(luaFile, res.luaCode) -- 1478
												messages[#messages + 1] = { -- 1479
													success = true, -- 1479
													file = file -- 1479
												} -- 1479
											else -- 1481
												messages[#messages + 1] = { -- 1481
													success = false, -- 1481
													file = file, -- 1481
													message = res.message -- 1481
												} -- 1481
											end -- 1476
											done = true -- 1482
										end -- 1474
									end -- 1473
								end -- 1472
							end) -- 1471
						end -- 1470
						emit("AppWS", "Send", json.encode({ -- 1483
							name = "TranspileTS", -- 1483
							file = file, -- 1483
							content = content -- 1483
						})) -- 1483
						wait(function() -- 1484
							return done -- 1484
						end) -- 1484
						::_continue_1:: -- 1468
					end -- 1467
					return { -- 1485
						success = true, -- 1485
						messages = messages -- 1485
					} -- 1485
				end -- 1429
			end -- 1424
		end -- 1424
	end -- 1424
	return { -- 1423
		success = false -- 1423
	} -- 1423
end) -- 1423
HttpServer:post("/download", function(req) -- 1487
	do -- 1488
		local _type_0 = type(req) -- 1488
		local _tab_0 = "table" == _type_0 or "userdata" == _type_0 -- 1488
		if _tab_0 then -- 1488
			local url -- 1488
			do -- 1488
				local _obj_0 = req.body -- 1488
				local _type_1 = type(_obj_0) -- 1488
				if "table" == _type_1 or "userdata" == _type_1 then -- 1488
					url = _obj_0.url -- 1488
				end -- 1488
			end -- 1488
			local target -- 1488
			do -- 1488
				local _obj_0 = req.body -- 1488
				local _type_1 = type(_obj_0) -- 1488
				if "table" == _type_1 or "userdata" == _type_1 then -- 1488
					target = _obj_0.target -- 1488
				end -- 1488
			end -- 1488
			if url ~= nil and target ~= nil then -- 1488
				local Entry = require("Script.Dev.Entry") -- 1489
				Entry.downloadFile(url, target) -- 1490
				return { -- 1491
					success = true -- 1491
				} -- 1491
			end -- 1488
		end -- 1488
	end -- 1488
	return { -- 1487
		success = false -- 1487
	} -- 1487
end) -- 1487
local status = { } -- 1493
_module_0 = status -- 1494
status.buildAsync = function(path) -- 1496
	if not Content:exist(path) then -- 1497
		return { -- 1498
			success = false, -- 1498
			file = path, -- 1498
			message = "file not existed" -- 1498
		} -- 1498
	end -- 1497
	do -- 1499
		local _exp_0 = Path:getExt(path) -- 1499
		if "tl" == _exp_0 or "yue" == _exp_0 or "xml" == _exp_0 then -- 1499
			if '' == Path:getExt(Path:getName(path)) then -- 1500
				local content = Content:loadAsync(path) -- 1501
				if content then -- 1501
					local resultCodes, err = compileFileAsync(path, content) -- 1502
					if resultCodes then -- 1502
						return { -- 1503
							success = true, -- 1503
							file = path -- 1503
						} -- 1503
					else -- 1505
						return { -- 1505
							success = false, -- 1505
							file = path, -- 1505
							message = err -- 1505
						} -- 1505
					end -- 1502
				end -- 1501
			end -- 1500
		elseif "lua" == _exp_0 then -- 1506
			local content = Content:loadAsync(path) -- 1507
			if content then -- 1507
				do -- 1508
					local isTIC80 = CheckTIC80Code(content) -- 1508
					if isTIC80 then -- 1508
						content = content:gsub("^%-%-[ \t]*tic80[ \t]*", "require(\"tic80\")") -- 1509
					end -- 1508
				end -- 1508
				local success, info -- 1510
				do -- 1510
					local _obj_0 = luaCheck(path, content) -- 1510
					success, info = _obj_0.success, _obj_0.info -- 1510
				end -- 1510
				if success then -- 1511
					return { -- 1512
						success = true, -- 1512
						file = path -- 1512
					} -- 1512
				elseif info and #info > 0 then -- 1513
					local messages = { } -- 1514
					for _index_0 = 1, #info do -- 1515
						local _des_0 = info[_index_0] -- 1515
						local _type, _file, line, column, message = _des_0[1], _des_0[2], _des_0[3], _des_0[4], _des_0[5] -- 1515
						local lineText = "" -- 1516
						if line then -- 1517
							local currentLine = 1 -- 1518
							for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1519
								if currentLine == line then -- 1520
									lineText = text -- 1521
									break -- 1522
								end -- 1520
								currentLine = currentLine + 1 -- 1523
							end -- 1519
						end -- 1517
						if line then -- 1524
							messages[#messages + 1] = "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1525
						else -- 1527
							messages[#messages + 1] = message -- 1527
						end -- 1524
					end -- 1515
					return { -- 1528
						success = false, -- 1528
						file = path, -- 1528
						message = table.concat(messages, "\n") -- 1528
					} -- 1528
				else -- 1530
					return { -- 1530
						success = false, -- 1530
						file = path, -- 1530
						message = "lua check failed" -- 1530
					} -- 1530
				end -- 1511
			end -- 1507
		elseif "yarn" == _exp_0 then -- 1531
			local content = Content:loadAsync(path) -- 1532
			if content then -- 1532
				local res, _, err = yarncompile(content, true) -- 1533
				if res then -- 1533
					return { -- 1534
						success = true, -- 1534
						file = path -- 1534
					} -- 1534
				else -- 1536
					local message, line, column, node = err[1], err[2], err[3], err[4] -- 1536
					local lineText = "" -- 1537
					if line then -- 1538
						local currentLine = 1 -- 1539
						for text in content:gmatch("([^\r\n]*)\r?\n?") do -- 1540
							if currentLine == line then -- 1541
								lineText = text -- 1542
								break -- 1543
							end -- 1541
							currentLine = currentLine + 1 -- 1544
						end -- 1540
					end -- 1538
					if node ~= "" then -- 1545
						node = "node: " .. tostring(node) .. ", " -- 1546
					else -- 1547
						node = "" -- 1547
					end -- 1545
					message = tostring(node) .. "line " .. tostring(line) .. ", col " .. tostring(column) .. ": " .. tostring(lineText) .. "\nerror: " .. tostring(message) -- 1548
					return { -- 1549
						success = false, -- 1549
						file = path, -- 1549
						message = message -- 1549
					} -- 1549
				end -- 1533
			end -- 1532
		end -- 1499
	end -- 1499
	return { -- 1550
		success = false, -- 1550
		file = path, -- 1550
		message = "invalid file to build" -- 1550
	} -- 1550
end -- 1496
thread(function() -- 1552
	local doraWeb = Path(Content.assetPath, "www", "index.html") -- 1553
	local doraReady = Path(Content.appPath, ".www", "dora-ready") -- 1554
	if Content:exist(doraWeb) then -- 1555
		local needReload -- 1556
		if Content:exist(doraReady) then -- 1556
			needReload = App.version ~= Content:load(doraReady) -- 1557
		else -- 1558
			needReload = true -- 1558
		end -- 1556
		if needReload then -- 1559
			Content:remove(Path(Content.appPath, ".www")) -- 1560
			Content:copyAsync(Path(Content.assetPath, "www"), Path(Content.appPath, ".www")) -- 1561
			Content:save(doraReady, App.version) -- 1565
			print("Dora Dora is ready!") -- 1566
		end -- 1559
	end -- 1555
	if HttpServer:start(8866) then -- 1567
		local localIP = HttpServer.localIP -- 1568
		if localIP == "" then -- 1569
			localIP = "localhost" -- 1569
		end -- 1569
		status.url = "http://" .. tostring(localIP) .. ":8866" -- 1570
		return HttpServer:startWS(8868) -- 1571
	else -- 1573
		status.url = nil -- 1573
		return print("8866 Port not available!") -- 1574
	end -- 1567
end) -- 1552
return _module_0 -- 1
